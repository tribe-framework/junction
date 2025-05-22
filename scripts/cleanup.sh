FILE=.flame
if test -f "$FILE"; then
    # take backup of .env file
    [[ -f "applications/junction/.env" ]] && cp applications/junction/.env applications/.junction.env

    rm -r applications/junction;
    mkdir applications/junction;
    cd applications/junction;

    ember init;
    yes | ember install ember-tribe;
    yes | ember install ember-junction;

    ln -s applications/.junction.env applications/junction/.env
else
    echo "This is not a Flame folder."
fi
