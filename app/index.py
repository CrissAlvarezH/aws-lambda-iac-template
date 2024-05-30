import logging

import requests

logging.basicConfig(format="%(asctime)s: %(levelname)s: %(message)s")
LOG = logging.getLogger("main")
LOG.setLevel(logging.INFO)


def main(event, context):
    LOG.info("init main: hello")
    LOG.debug("debug log")
    print("simple print")

    res = requests.get("https://pokeapi.co/api/v2/pokemon/ditto")

    ditto_abilities = [a.get("ability").get("name") for a in res.json().get("abilities", [])]
    LOG.info("Ditto abilities: "+str(ditto_abilities))
