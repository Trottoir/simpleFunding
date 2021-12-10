from brownie import FundMe, config, network, MockV3Aggregator
from scripts.helper_scripts import (
    get_account,
    deploy_mocks,
    LOCAL_BLOCKCHAIN_ENVIRONMENTS,
)


def deploy_fund_me():

    account = get_account()
    # if on rinkeby use real network
    # else deploy mocks
    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        price_feed_address = config["networks"][network.show_active()][
            "eth_usd_price_feed_address"
        ]
    else:
        deploy_mocks()
        price_feed_address = MockV3Aggregator[-1].address

    print("coucou")
    fund_me = FundMe.deploy(
        price_feed_address,
        {"from": account},
        publish_source=config["networks"][network.show_active()]["verify"],
    )
    print(f"Contract deplyed to {fund_me.address}")
    return fund_me


def main():
    deploy_fund_me()
