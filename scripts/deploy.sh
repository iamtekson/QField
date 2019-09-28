#!/bin/bash
set -e

source scripts/travis_env.sh

if [[ ${TRAVIS_SECURE_ENV_VARS} = true ]]; then
  if [ ${TRAVIS_PULL_REQUEST} != false ]; then
    echo -e "\e[31mDeploying app to pull request\e[0m"
    curl -u m-kuhn:${GITHUB_API_TOKEN} -X POST --data '{"body": "Uploaded test apks for [armv7](https://download.opengis.ch/qfield/ci-builds/qfield-dev-'${UPLOAD_ARTIFACT_ID}'-'${TRAVIS_COMMIT}'-armv7-X.apk) and [x86](https://download.opengis.ch/qfield/ci-builds/qfield-dev-'${UPLOAD_ARTIFACT_ID}'-'${TRAVIS_COMMIT}'-x86-X.apk) (Android 5: [armv7](https://download.opengis.ch/qfield/ci-builds/qfield-dev-'${UPLOAD_ARTIFACT_ID}'-'${TRAVIS_COMMIT}'-armv7-5.apk) and [x86](https://download.opengis.ch/qfield/ci-builds/qfield-dev-'${UPLOAD_ARTIFACT_ID}'-'${TRAVIS_COMMIT}'-x86-5.apk))"}' https://api.github.com/repos/opengisch/QField/issues/${TRAVIS_PULL_REQUEST}/comments
  elif [[ -n ${TRAVIS_TAG} ]]; then
    echo -e "\e[93;1mStarting to deploy a new release\e[0m"
    openssl aes-256-cbc -K $encrypted_play_upload_key -iv $encrypted_play_upload_iv -in .ci/play_developer.p12.enc -out .ci/play_developer.p12 -d
    echo -e "\e[93m * Collecting apks to upload...\e[0m"
    curl -L -s -S -o /tmp/qfield-${TRAVIS_TAG}-armv7.apk https://download.opengis.ch/qfield/ci-builds/qfield-dev-${UPLOAD_ARTIFACT_ID}-${TRAVIS_COMMIT}-armv7-X.apk
    curl -L -s -S -o /tmp/qfield-${TRAVIS_TAG}-x86.apk https://download.opengis.ch/qfield/ci-builds/qfield-dev-${UPLOAD_ARTIFACT_ID}-${TRAVIS_COMMIT}-x86-X.apk
    curl -L -s -S -o /tmp/qfield-${TRAVIS_TAG}-armv7-Android-5.apk https://download.opengis.ch/qfield/ci-builds/qfield-dev-${UPLOAD_ARTIFACT_ID}-${TRAVIS_COMMIT}-armv7-5.apk
    curl -L -s -S -o /tmp/qfield-${TRAVIS_TAG}-x86-Android-5.apk https://download.opengis.ch/qfield/ci-builds/qfield-dev-${UPLOAD_ARTIFACT_ID}-${TRAVIS_COMMIT}-x86-5.apk

    echo -e "\e[93m * Deploying app to github release...\e[0m"
    ./scripts/upload_release_asset.py /tmp/qfield-${TRAVIS_TAG}-armv7.apk ${TRAVIS_TAG}
    ./scripts/upload_release_asset.py /tmp/qfield-${TRAVIS_TAG}-x86.apk ${TRAVIS_TAG}
    ./scripts/upload_release_asset.py /tmp/qfield-${TRAVIS_TAG}-armv7-Android-5.apk ${TRAVIS_TAG}
    ./scripts/upload_release_asset.py /tmp/qfield-${TRAVIS_TAG}-x86-Android-5.apk ${TRAVIS_TAG}

    echo -e "\e[93m * Deploying app to google play (beta)...\e[0m"
    ./scripts/basic_upload_apks_service_account.py ch.opengis.qfield /tmp/qfield-${TRAVIS_TAG}-armv7-Android-5.apk ch.opengis.qfield /tmp/qfield-${TRAVIS_TAG}-x86-Android-5.apk /tmp/qfield-${TRAVIS_TAG}-armv7.apk ch.opengis.qfield /tmp/qfield-${TRAVIS_TAG}-x86.apk

  elif [[ ${TRAVIS_BRANCH} = master ]]; then
    # we are on a standard commit on master branch
    curl -u m-kuhn:${GITHUB_API_TOKEN} -X POST --data '{"body": "Uploaded test apks for [armv7](https://download.opengis.ch/qfield/ci-builds/qfield-dev-'${UPLOAD_ARTIFACT_ID}'-'${TRAVIS_COMMIT}'-armv7-X.apk) and [x86](https://download.opengis.ch/qfield/ci-builds/qfield-dev-'${UPLOAD_ARTIFACT_ID}'-'${TRAVIS_COMMIT}'-x86-X.apk) (Android 5 versions [armv7](https://download.opengis.ch/qfield/ci-builds/qfield-dev-'${UPLOAD_ARTIFACT_ID}'-'${TRAVIS_COMMIT}'-armv7-5.apk) and [x86](https://download.opengis.ch/qfield/ci-builds/qfield-dev-'${UPLOAD_ARTIFACT_ID}'-'${TRAVIS_COMMIT}'-x86-5.apk) "}' https://api.github.com/repos/opengisch/QField/commits/${TRAVIS_COMMIT}/comments
  fi
fi
