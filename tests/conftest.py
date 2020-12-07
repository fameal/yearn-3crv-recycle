import pytest
from brownie import *


@pytest.fixture(scope="function")
def recycle(Recycle, accounts):
    return Recycle.deploy({"from": accounts[0]})


@pytest.fixture(scope="module")
def uniswap(interface):
    return interface.UniswapV2Router02("0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D")


@pytest.fixture(scope="module")
def curve(interface):
    return interface.Curve3Pool("0xbEbc44782C7dB0a1A60Cb6fe97d0b483032FF1C7")


@pytest.fixture(scope="module")
def coins(interface):
    return [
        interface.ERC20("0x6B175474E89094C44Da98b954EedeAC495271d0F"),
        interface.ERC20("0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48"),
        interface.USDT("0xdAC17F958D2ee523a2206206994597C13D831ec7"),
        interface.ERC20("0x6c3F90f043a72FA612cbac8115EE7e52BDe6E490"),
    ]


@pytest.fixture(scope="module")
def coins_us(interface):
    return [
        interface.ERC20("0x6B175474E89094C44Da98b954EedeAC495271d0F"),
        interface.ERC20("0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48"),
        interface.USDT("0xdAC17F958D2ee523a2206206994597C13D831ec7"),
        # interface.ERC20("0x6c3F90f043a72FA612cbac8115EE7e52BDe6E490"), #3crv pair not available on uniswap
    ]


@pytest.fixture(scope="module")
def y3crv(interface):
    return interface.ERC20("0x9cA85572E6A3EbF24dEDd195623F188735A5179f")
