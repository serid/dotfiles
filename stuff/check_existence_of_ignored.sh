# this script checks if git repo contains any untracked files that are ignored by git
# so that user can remove them and get a "clean" repo

for k in `cat .gitignore`; do
    if [ -e "./$k" ]; then
        echo "found ignored file ./$k"
    fi
done

exit 0

# useful jdk commands

# configure
sh configure --with-jtreg=jtreg --with-debug-level=fastdebug --build=x86_64-unknown-linux-gnu --host=x86_64-unknown-linux-gnu
# build jdk and run tests
make run-test-tier1
# remove ./build
rm -rf ./build
