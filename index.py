import logging

logging.basicConfig(format="%(asctime)s: %(levelname)s: %(message)s")
LOG = logging.getLogger("main")
LOG.setLevel(logging.INFO)


def main(event, context):
    LOG.info("init main: hello")
    print("simple print")
