tmux kill-session -t "InlineCli"
tmux kill-session -t "InlineApi"

tmux new-session -d -s "InlineCli" "./cli.sh"
tmux detach -s "InlineCli"
echo "Inline now Running!"
echo "Waiting 5 sec for runing Inline api!"
sleep 5
tmux new-session -d -s "InlineApi" "./api.sh"
tmux detach -s "InlineApi"
echo "InlineApi now Running!"