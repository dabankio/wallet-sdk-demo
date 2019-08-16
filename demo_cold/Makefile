fmt:
	flutter format lib/* -l 120
buildApk:
	flutter build apk --target-platform android-arm --split-per-abi

macCleanGradleCache:
	rm -rf ~/.gradle/caches
	cd android && gradle cleanBuildCache