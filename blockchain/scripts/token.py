#!/usr/bin/python3

from brownie import Token, accounts

def main():
    return accounts[0].deploy(Token)
