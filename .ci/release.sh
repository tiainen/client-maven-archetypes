#!/usr/bin/env bash

# Decrypt encrypted files
openssl aes-256-cbc -K $encrypted_2c2ee1f6355b_key -iv $encrypted_2c2ee1f6355b_iv -in .ci/gpg_keys.tar.enc -out gpg_keys.tar -d
if [[ ! -s gpg_keys.tar ]]
   then echo "Decryption failed."
   exit 1
fi
tar xvf gpg_keys.tar

# Release artifacts
cp .travis.settings.xml $HOME/.m2/settings.xml && mvn deploy -DskipTests=true -B -U -Prelease

# Update version by 1
newVersion=${TRAVIS_TAG%.*}.$((${TRAVIS_TAG##*.} + 1))

# Replace first occurrence of TRAVIS_TAG with newVersion appended with SNAPSHOT
sed -i "0,/<revision>$TRAVIS_TAG/s//<revision>$newVersion-SNAPSHOT/" pom.xml

git commit pom.xml -m "Upgrade version to $newVersion-SNAPSHOT" --author "Github Bot <githubbot@gluonhq.com>"
git push https://gluon-bot:$GITHUB_PASSWORD@github.com/gluonhq/client-maven-archetypes HEAD:master