# remember to run '. setup.sh'
PS3="Select action: "
select option in Setup Reset Exit
do
    case $option in
        "Setup")
            export PATH=$PATH:/workspace/bannerbrawl/run
            break;;
        "Reset")
            export PATH=$(echo "$PATH" | sed -e 's/:\/workspace\/bannerbrawl\/run//')
            break;;
        "Exit")
            echo "exit"
            break;;
        *)
            echo "Please select an action.";;
    esac
done
