# Définition des dossiers de travail
WORKDIR=./
LISTREPOS=listerepos.txt
LISTDIR=$WORKDIR/list
DATADIR=$WORKDIR/data
COMPDIR=$WORKDIR/compare
DATEVAR=$(date +"%Y%m%d-%Hh%M")
LOGFILE=$WORKDIR/check-$DATEVAR.log

if [ -d "$COMPDIR" ]; then
        :
else
        mkdir $COMPDIR
fi


# Faire la liste des components de chaque repo
LISTNB=0
for repo in $(cat "$WORKDIR/$LISTREPOS"); do
        LISTNB=$((LISTNB + 1))
        echo "[$LISTNB/$LISTREPOSNB] - $repo"
        echo "[$LISTNB/$LISTREPOSNB] - $repo" >> $LOGFILE
        REPOFILE=$repo.txt

        find $DATADIR/$repo -type f | cut -d'/' -f 5- | sort > $COMPDIR/$repo-local.txt
        cat $LISTDIR/$repo.txt | sort > $COMPDIR/$repo-nexus.txt
        diff $COMPDIR/$repo-local.txt $COMPDIR/$repo-nexus.txt > $COMPDIR/$repo-diff.txt



done