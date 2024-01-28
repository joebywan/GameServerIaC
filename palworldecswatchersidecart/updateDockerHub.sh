#!/bin/bash

# Set variables
USERNAME="joebywan"
REPO="palworldecswatchersidecart"
VERSION="0.1"  # Replace with your actual version number

# Build the Docker image with a version tag
echo "Building Docker image with version tag..."
docker build -t $USERNAME/$REPO:$VERSION .

# Check if build was successful
if [ $? -eq 0 ]; then
    echo "Build successful. Pushing version tag to DockerHub..."
    docker push $USERNAME/$REPO:$VERSION

    # Check if push was successful
    if [ $? -eq 0 ]; then
        echo "Push successful. Tagging image as latest..."
        docker tag $USERNAME/$REPO:$VERSION $USERNAME/$REPO:latest

        echo "Pushing latest tag to DockerHub..."
        docker push $USERNAME/$REPO:latest

        if [ $? -eq 0 ]; then
            echo "Latest tag pushed successfully."
        else
            echo "Error pushing latest tag."
        fi
    else
        echo "Error pushing version tag."
    fi
else
    echo "Error building image."
fi
