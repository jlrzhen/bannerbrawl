spin_list=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")
spinner() {
    for spin in "${spin_list[@]}"; do
        echo -ne "$spin Waiting for containers to respond...\r"
        sleep 0.05
    done
}
