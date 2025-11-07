"""
Script pour supprimer le background des images .ico, .jpg, .jpeg et les convertir en PNG transparent
Usage: python remove_background.py
"""
import sys
import os
from pathlib import Path

try:
    from PIL import Image, ImageChops
except ImportError:
    print("Installation de Pillow...")
    os.system(f"{sys.executable} -m pip install Pillow")
    from PIL import Image, ImageChops

def remove_background(image_path, output_path):
    """Supprime le background d'une image (.ico, .jpg, .jpeg) et la convertit en PNG transparent"""
    try:
        # Ouvrir l'image
        img = Image.open(image_path)
        
        # Convertir en RGBA si pas déjà
        if img.mode != 'RGBA':
            img = img.convert('RGBA')
        
        # Obtenir les données des pixels
        data = list(img.getdata())
        
        # Créer une nouvelle image avec transparence
        new_data = []
        
        # Vérifier si l'image a déjà de la transparence
        has_transparency = any(len(pixel) == 4 and pixel[3] < 255 for pixel in data)
        
        if has_transparency:
            # L'image a déjà de la transparence, la conserver
            new_data = data
        else:
            # Détecter la couleur du background (généralement dans les coins)
            if img.width > 0 and img.height > 0:
                # Échantillonner les coins de l'image pour détecter le background
                corner_samples = []
                sample_positions = [
                    (0, 0),  # Coin haut-gauche
                    (img.width - 1, 0),  # Coin haut-droite
                    (0, img.height - 1),  # Coin bas-gauche
                    (img.width - 1, img.height - 1),  # Coin bas-droite
                ]
                
                for x, y in sample_positions:
                    try:
                        pixel = img.getpixel((x, y))
                        if len(pixel) >= 3:
                            corner_samples.append(pixel[:3])
                    except:
                        pass
                
                # Si on a des échantillons, déterminer la couleur de background moyenne
                if corner_samples:
                    avg_r = sum(p[0] for p in corner_samples) // len(corner_samples)
                    avg_g = sum(p[1] for p in corner_samples) // len(corner_samples)
                    avg_b = sum(p[2] for p in corner_samples) // len(corner_samples)
                    bg_color = (avg_r, avg_g, avg_b)
                else:
                    # Fallback: blanc
                    bg_color = (255, 255, 255)
            else:
                bg_color = (255, 255, 255)
            
            # Seuil de tolérance pour détecter les pixels de background
            threshold = 40
            
            # Traiter chaque pixel
            for pixel in data:
                if len(pixel) >= 3:
                    r, g, b = pixel[0], pixel[1], pixel[2]
                    a = pixel[3] if len(pixel) == 4 else 255
                    
                    # Calculer la distance de couleur par rapport au background
                    color_diff = abs(r - bg_color[0]) + abs(g - bg_color[1]) + abs(b - bg_color[2])
                    
                    # Si le pixel est très proche du background ou très clair, le rendre transparent
                    if color_diff <= threshold or (r > 240 and g > 240 and b > 240):
                        new_data.append((r, g, b, 0))  # Transparent
                    else:
                        new_data.append((r, g, b, 255))  # Opaque
                else:
                    # Pixel invalide, le rendre transparent
                    new_data.append((0, 0, 0, 0))
        
        # Créer la nouvelle image
        img.putdata(new_data)
        
        # Sauvegarder en PNG
        img.save(output_path, 'PNG')
        print(f"[OK] Converti: {image_path.name} -> {output_path.name}")
        return True
        
    except Exception as e:
        print(f"[ERREUR] Erreur avec {image_path.name}: {str(e)}")
        import traceback
        traceback.print_exc()
        return False

def main():
    assets_dir = Path("assets/images")
    
    if not assets_dir.exists():
        print(f"[ERREUR] Dossier {assets_dir} non trouve")
        return
    
    # Chercher tous les fichiers image supportés
    image_extensions = ['*.ico', '*.jpg', '*.jpeg']
    image_files = []
    for ext in image_extensions:
        image_files.extend(list(assets_dir.glob(ext)))
    
    if not image_files:
        print("[INFO] Aucun fichier image (.ico, .jpg, .jpeg) trouve dans assets/images")
        return
    
    print(f"[INFO] Trouve {len(image_files)} fichier(s) image")
    print("=" * 60)
    
    for image_file in image_files:
        # Créer le nom de sortie (même nom mais .png)
        output_file = image_file.with_suffix('.png')
        
        # Si un PNG existe déjà avec le même nom, créer un nouveau nom avec _transparent
        if output_file.exists() and output_file != image_file:
            output_file = image_file.with_name(f"{image_file.stem}_transparent.png")
        
        remove_background(image_file, output_file)
    
    print("=" * 60)
    print("[INFO] Conversion terminee")
    print("\nLes nouveaux fichiers PNG avec transparence ont ete crees.")
    print("Vous pouvez maintenant utiliser ces PNG dans votre application.")

if __name__ == "__main__":
    main()
