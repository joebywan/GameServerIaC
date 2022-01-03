This repo is creating a terraform script to automate the manual steps outlined here: https://github.com/doctorray117/minecraft-ondemand

The idea is to be able to make it as generic as possible, so I can automate creating game servers for any game I can get/make a container for.

At the moment my plans are:
1. Build all in one file <- currently here
2. Get working & tested
3. Split into seperate files
4. Work at making it generic enough with extra variables & any restructuring required

Current status:
File deploys fine if I manually create the zip file of the lambda function script.  Need to figure out how to automate it correctly.
