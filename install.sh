if ls /bannerbrawl
then
    git clone https://github.com/jlrzhen/bannerbrawl.git /bannerbrawl
    export PATH=$PATH:/bannerbrawl/run
else
    rm -r /bannerbrawl
    PATH=$(echo "$PATH" | sed -e 's/:\/bannerbrawl\/run//')
fi
