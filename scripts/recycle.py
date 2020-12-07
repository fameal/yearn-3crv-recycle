import click
from brownie import Recycle, interface, accounts, history, rpc


def main():
    user = (
        accounts[-1] if rpc.is_active() else accounts.load(input("brownie account: "))
    )

    recycle = Recycle.at("0x3f1C19b09b474f7b7a8B09488Fc8648b278930cc")

    dai = interface.ERC20("0x6B175474E89094C44Da98b954EedeAC495271d0F")
    usdc = interface.ERC20("0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48")
    usdt = interface.USDT("0xdAC17F958D2ee523a2206206994597C13D831ec7")
    token3crv = interface.ERC20("0x6c3F90f043a72FA612cbac8115EE7e52BDe6E490")
    y3crv = interface.ERC20("0x9cA85572E6A3EbF24dEDd195623F188735A5179f")

    coins = [dai, usdc, usdt, y3crv]
    symbols = {token3crv: "3CRV", y3crv: "y3CRV"}

    balances = {
        symbols.get(coin, coin.symbol()): coin.balanceOf(user) / 10 ** coin.decimals()
        for coin in coins
    }
    balances = {name: balance for name, balance in balances.items() if balance > 0}

    print(f"Recycling...")
    for coin, balance in balances.items():
        print(f"  {coin} = {balance}")

    if not click.confirm("Continue?"):
        return

    for coin in coins:
        if coin.balanceOf(user) > coin.allowance(user, recycle):
            print(f"Approving {coin.name()}")
            coin.approve(recycle, 2 ** 256 - 1, {"from": user})

    tx = recycle.recycle({"from": user})
    print(
        "Got", tx.events["Recycled"]["received_y3crv"] / 10 ** y3crv.decimals(), "y3CRV"
    )
