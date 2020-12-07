# @version 0.2.4
from vyper.interfaces import ERC20

interface USDT:
    def transferFrom(_from: address, _to: address, _value: uint256): nonpayable
    def approve(_spender: address, _value: uint256): nonpayable

interface I3CurveDeposit:
    def add_liquidity(amounts: uint256[3], min_mint_amount: uint256): nonpayable

interface yVault:
    def deposit(amount: uint256): nonpayable

event Recycled:
    user: indexed(address)
    sent_dai: uint256
    sent_usdc: uint256
    sent_usdt: uint256
    sent_3crv: uint256
    received_y3crv: uint256

deposit3crv: constant(address) = 0xbEbc44782C7dB0a1A60Cb6fe97d0b483032FF1C7
token3crv: constant(address) = 0x6c3F90f043a72FA612cbac8115EE7e52BDe6E490
y3crv: constant(address) = 0x9cA85572E6A3EbF24dEDd195623F188735A5179f #this is V1

dai: constant(address) = 0x6B175474E89094C44Da98b954EedeAC495271d0F
usdc: constant(address) = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48
usdt: constant(address) = 0xdAC17F958D2ee523a2206206994597C13D831ec7


@external
def __init__():
    ERC20(dai).approve(deposit3crv, MAX_UINT256)
    ERC20(usdc).approve(deposit3crv, MAX_UINT256)
    USDT(usdt).approve(deposit3crv, MAX_UINT256)
    ERC20(token3crv).approve(y3crv, MAX_UINT256)


@internal
def recycle_exact_amounts(sender: address, _dai: uint256, _usdc: uint256, _usdt: uint256, _3crv: uint256):
    if _dai > 0:
        ERC20(dai).transferFrom(sender, self, _dai)
    if _usdc > 0:
        ERC20(usdc).transferFrom(sender, self, _usdc)
    if _usdt > 0:
        USDT(usdt).transferFrom(sender, self, _usdt)
    if _3crv > 0:
        ERC20(token3crv).transferFrom(sender, self, _3crv)

    deposit_amounts: uint256[3] = [_dai, _usdc, _usdt]
    if _dai + _usdc + _usdt > 0:
        I3CurveDeposit(deposit3crv).add_liquidity(deposit_amounts, 0)

    token3crv_balance: uint256 = ERC20(token3crv).balanceOf(self)       
    if token3crv_balance > 0:
        yVault(y3crv).deposit(token3crv_balance)

    _y3crv: uint256 = ERC20(y3crv).balanceOf(self)
    ERC20(y3crv).transfer(sender, _y3crv)

    assert ERC20(y3crv).balanceOf(self) == 0, "leftover yUSD balance"

    log Recycled(sender, _dai, _usdc, _usdt, _3crv, _y3crv)


@external
def recycle():
    _dai: uint256 = min(ERC20(dai).balanceOf(msg.sender), ERC20(dai).allowance(msg.sender, self))
    _usdc: uint256 = min(ERC20(usdc).balanceOf(msg.sender), ERC20(usdc).allowance(msg.sender, self))
    _usdt: uint256 = min(ERC20(usdt).balanceOf(msg.sender), ERC20(usdt).allowance(msg.sender, self))
    _3crv: uint256 = min(ERC20(token3crv).balanceOf(msg.sender), ERC20(token3crv).allowance(msg.sender, self))

    self.recycle_exact_amounts(msg.sender, _dai, _usdc, _usdt, _3crv)


@external
def recycle_exact(_dai: uint256, _usdc: uint256, _usdt: uint256, _3crv: uint256):
    self.recycle_exact_amounts(msg.sender, _dai, _usdc, _usdt, _3crv)
