# SUI Contract Development Challenge
## Overview
In this task, you are supposed to create an asset bank contract on Sul Move that will allow a user to deposit any assets into it and, in return, provide them an NFT as a receipt for the deposit. Users can return the NFT at any time and claim their
deposited tunds
## Description
You need to create a module named bikinove, that upon its deployment (tip: int method) will generate an asset bank and share it publicly so that anyone can provide it as input to a contract call. The asset bank will have the following properties:
* It will carry an 1s that will make it a Sui object (Note: a struct or object without sui ID is not a SUl object Le. it can not be looked up on block explorer as it does not have a sui unique identified)
* A counter indicating the number of deposits made to the bank.
* A counter indicating the current number of active NFTs (deposits)

 

The module will expose a method called a method positet»(bank) deut Asseth
  that any user
  can invoke to deposit funds into the bank. Note that the type is generic which means any coin i.e. SUI, USDC, USDT etc. can be deposited into the bank.
  The method will:
* Revert if the balance of the provided coin object is ZERO
* Take user coin and deposit it in the bank object
* Create an NFT receipt and transfer it to the caller
* Increase the number of deposits
* Increase the number of active NFTs
* Emit an appropriate deposit event

The receipt NFT will have the following structure:
* An ID to that makes this receipt a SUI object ( can be searched on block explorer using this ID)
* An integer indicating the number of this NFT (1st, 2nd, …. nth)
* It will have the address of the depositor
* The amount of tokens deposited
* If will be of a generic type weceiptst where the T is the type of token deposited by the user (USDC, SUI).
  Once a user has been issued an NFT, they should not be able to transfer it to someone else, and no one other than the NFT holder can use it for any purpose.
  The module will also expose a public method to withdraw funds from the bank by returning the minted NFT.
 

 
The method

* Remove the balance equal to reciipc.ucuit from the asset bank of the coin type r
* Convert the balance into a Coin and transfer it to reseipt.depesiter address
* Decrease the number of active NFTs (depositors) |
* Destroy the receipt object.
* Emit an appropriate withdrawal event
## Deliverables:
  A Github repository, with:
* A clear ReadMe for anyone to get started
* A emk
  ove module that implements the above requirements
* Some unit tests written using sui move test suite to validate the working of the contract.