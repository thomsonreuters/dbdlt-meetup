Getting started with Hyperledger Fabric
==================================================

The purpose of this project is to demonstrate how to build a Hyperledger Fabric network environment and interact through code via a sample web application.


Getting started
--------------------------------------
- Requirements to build, tools required:
  - [Docker](https://www.docker.com/)
  - [NodeJS](https://nodejs.org/en/)
  
- Setup and Running
  - Ensure docker is running.
  - ```install-prereqs.sh``` to pre-install required docker images.
  - ```./create.sh``` to setup the Hyperledger Fabric network.
  - ```cd ./app``` to change into the application root.
  - ```npm install && npm start``` to run the application.
  - browse to ```http://localhost:3000``` to try it out.

- Additional scripts
  - ```./network/regen-artifacts.sh``` will regenerate . the crypto certs used by the network. Note: if doing this, don't forget to update the dockerfile(s)

- Additional documentation
  - [https://hyperledger-fabric.readthedocs.io](https://hyperledger-fabric.readthedocs.io)


Other Information
--------------------------------------
Presentation: ```./presentation/presentation.md``` created with deckset.

[https://www.meetup.com/dbdlt-meetup/](Dallas Blockchain & Distributed Ledger Meetup)

License
--------------------------------------
All code not covered under a seprate license is tentively covered under MIT License.