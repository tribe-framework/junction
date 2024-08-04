FILE=.flame
if test -f "$FILE"; then
    rm -r applications/junction;
    mkdir applications/junction;
    cd applications/junction;
    ember init;
    yes | ember install ember-tribe;
    yes | ember install ember-junction;
else
    echo "This is not a Flame folder."
fi