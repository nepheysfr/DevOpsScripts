NEXUS_URL=<NEXUS_URL>		#A modifier
USERNAME=<ADMIN_LOGIN>		#A modifier
PASSWORD=<ADMIN_PWD>		#A modifier

# Définition des dossiers de travail
WORKDIR=./
LISTREPOS=listerepos.txt
LISTDIR=$WORKDIR/list
DATADIR=$WORKDIR/data
DATEVAR=$(date +"%Y%m%d-%Hh%M")
LOGFILE=$WORKDIR/import-$DATEVAR.log

if [ -d "$LISTDIR" ]; then
        :
else
        mkdir $LISTDIR
fi

if [ -d "$DATADIR" ]; then
        :
else
        mkdir $DATADIR
fi

# Faire la liste des repos si elle n'est pas fournie
if [ -f "$WORKDIR/$LISTREPOS" ]; then
        LISTREPOSNB=$(cat $WORKDIR/$LISTREPOS | wc -l)
        echo "La liste de repos existe déja et comporte $LISTREPOSNB repos"
        echo "La liste de repos existe déja et comporte $LISTREPOSNB repos" >> $LOGFILE
else
        curl -k -s -u $USERNAME:$PASSWORD -XGET $NEXUS_URL/service/rest/v1/repositories | grep name | cut -d'"' -f4 | sort > $WORKDIR/$LISTREPOS
        LISTREPOSNB=$(cat $WORKDIR/$LISTREPOS | wc -l)
        echo "La liste de repos existe et comporte $LISTREPOSNB repos"
        echo "La liste de repos existe et comporte $LISTREPOSNB repos" >> $LOGFILE
fi

# Faire la liste des components de chaque repo
LISTNB=0
for repo in $(cat "$WORKDIR/$LISTREPOS"); do
        LISTNB=$((LISTNB + 1))
        echo "[$LISTNB/$LISTREPOSNB] - $repo"
        echo "[$LISTNB/$LISTREPOSNB] - $repo" >> $LOGFILE
        REPOFILE=$repo.txt
        find $DATADIR/$repo -type f | cut -d'/' -f 5- > $LISTDIR/$REPOFILE

        LISTCOMPONENTNB=0
        LISTFILENB=$(cat $LISTDIR/$REPOFILE | wc -l)
        while IFS= read -r components; do
                LISTCOMPONENTNB=$((LISTCOMPONENTNB + 1))
                VARPATH=$(echo $components | awk 'BEGIN{FS=OFS="/"}{NF--; print}')
                VARFILE=$(echo $components | awk -F/ '{print $NF}')
                echo "[$LISTNB/$LISTREPOSNB] - $repo - [$LISTCOMPONENTNB/$LISTFILENB] - $VARPATH/$VARFILE"
                echo "[$LISTNB/$LISTREPOSNB] - $repo - [$LISTCOMPONENTNB/$LISTFILENB] - $VARPATH/$VARFILE" >> $LOGFILE

                if [ -z "$VARPATH" ]; then
                        curl -k -s -u $USERNAME:$PASSWORD --upload-file "$DATADIR/$repo/$VARFILE" "$NEXUS_URL/repository/$repo/$VARFILE"
                else
                        curl -k -s -u $USERNAME:$PASSWORD --upload-file "$DATADIR/$repo/$VARPATH/$VARFILE" "$NEXUS_URL/repository/$repo/$VARPATH/$VARFILE"
                fi
        done < $LISTDIR/$REPOFILE
        echo "[$LISTNB/$LISTREPOSNB] - $repo - [$LISTCOMPONENTNB/$LISTFILENB] - $(find $DATADIR/$repo -type f | wc -l) files uploaded in data folder"
        echo "[$LISTNB/$LISTREPOSNB] - $repo - [$LISTCOMPONENTNB/$LISTFILENB] - $(find $DATADIR/$repo -type f | wc -l) files uploaded in data folder" >> $LOGFILE
done