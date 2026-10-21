import json
import os
import urllib.parse
from io import BytesIO
from pathlib import Path
from PIL import Image
from rembg import remove
import requests

# Ścieżki do plików
SCRIPT_DIR = Path(__file__).resolve().parent
JSON_PATH = SCRIPT_DIR / "initial_database.json"
OUTPUT_DIR = SCRIPT_DIR.parent / "images" / "animals"

TARGET_MAX_SIZE = 256  # Max rozmiar spryta w pikselach dla gry


def generate_and_save_sprite_flux(prompt, output_filename):
  save_path = OUTPUT_DIR / output_filename
  if save_path.exists():
    print(f"⏩ Pomijam (już istnieje): {output_filename}")
    return

  print(f"🎨 Generowanie (FLUX.1 AI): {output_filename}...")

  # Kodowanie promptu i wymuszenie modelu FLUX
  encoded_prompt = urllib.parse.quote(prompt)
  url = f"https://image.pollinations.ai/prompt/{encoded_prompt}?model=flux&width=1024&height=1024&nologo=true&seed=42"

  try:
    response = requests.get(url, timeout=60)

    if response.status_code != 200:
      print(f"❌ Błąd serwera ({response.status_code})\n")
      return

    input_image = Image.open(BytesIO(response.content))

    print(f"✂️  Usuwanie tła (rembg): {output_filename}...")
    output_image = remove(input_image)

    # Autocrop - docięcie pustej przestrzeni
    bbox = output_image.getbbox()
    if bbox:
      output_image = output_image.crop(bbox)

    # Skalowanie do rozdzielczości gry (256px)
    output_image.thumbnail(
        (TARGET_MAX_SIZE, TARGET_MAX_SIZE), Image.Resampling.LANCZOS
    )

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    output_image.save(save_path, "PNG", optimize=True)
    print(f"✅ Zapisano sprite: {save_path}\n")

  except Exception as e:
    print(f"❌ Błąd przy generowaniu {output_filename}: {e}\n")


def main():
  print(f"📂 Wczytywanie pliku: {JSON_PATH}")

  if not JSON_PATH.exists():
    print(f"❌ BŁĄD: Nie znaleziono pliku {JSON_PATH}")
    return

  with open(JSON_PATH, "r", encoding="utf-8") as f:
    db = json.load(f)

  animals = db.get("animals", [])
  print(f"Znaleziono {len(animals)} gatunków zwierząt do przetworzenia.\n")

  # Styl dostosowany pod model FLUX (czysta grafika 2D na białym tle)
  base_style = "2D mobile game asset sprite, flat side profile view, clean vibrant vector illustration style, sharp crisp outlines, isolated on a solid plain white background, no drop shadows, UI asset."

  for animal in animals:
    animal_id = animal["id"]
    name = animal["nazwa"]
    has_dimorphism = animal.get("hasDimorphism", False)

    if has_dimorphism:
      prompt_male = f"{base_style} MALE {name} ({animal_id}), vibrant colorful body, swimming facing left."
      generate_and_save_sprite_flux(prompt_male, f"{animal_id}_male.png")

      prompt_female = f"{base_style} FEMALE {name} ({animal_id}), rounder body, paler natural colors, swimming facing left."
      generate_and_save_sprite_flux(prompt_female, f"{animal_id}_female.png")
    else:
      prompt_single = f"{base_style} {name} ({animal_id}), facing left."
      generate_and_save_sprite_flux(prompt_single, f"{animal_id}.png")

  print("🎉 Zakończono generowanie wszystkich grafik!")


if __name__ == "__main__":
  main()