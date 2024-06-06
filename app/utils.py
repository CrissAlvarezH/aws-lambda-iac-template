import requests

def get_pokemon_abilities(name: str):
    res = requests.get(f"https://pokeapi.co/api/v2/pokemon/{name}")

    return [a.get("ability").get("name") for a in res.json().get("abilities", [])]


def get_specie_happiness(specie: str):
    res = requests.get(f"https://pokeapi.co/api/v2/pokemon-species/{specie}")
    return res.json().get("base_happiness")
