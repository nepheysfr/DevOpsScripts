NEXUS_URL=<NEXUS_URL>		#A modifier
USERNAME=<ADMIN_LOGIN>		#A modifier
PASSWORD=<ADMIN_PWD>		#A modifier

# Définition des dossiers de travail
WORKDIR=./
LISTREPOS=listerepos.txt
LISTDIR=$WORKDIR/list
DATADIR=$WORKDIR/data
DATEVAR=$(date +"%Y%m%d-%Hh%M")
LOGFILE=$WORKDIR/export-$DATEVAR.log

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
#sleep 1000
# Faire la liste des components de chaque repo
LISTNB=0
for repo in $(cat "$WORKDIR/$LISTREPOS"); do
        LISTNB=$((LISTNB + 1))
        echo "[$LISTNB/$LISTREPOSNB] - $repo"
        echo "[$LISTNB/$LISTREPOSNB] - $repo" >> $LOGFILE
        REPOFILE=$repo.txt
        curl -s -k -u $USERNAME:$PASSWORD -XGET "$NEXUS_URL/service/rest/v1/components?repository=$repo" | grep path | cut -d'"' -f 4 | sort > $LISTDIR/$REPOFILE
        CTOKEN=$(curl -k -s -u $USERNAME:$PASSWORD -XGET "$NEXUS_URL/service/rest/v1/components?repository=$repo" | grep continuationToken | cut -d '"' -f 4)
        while [ ! -z $CTOKEN ]
        do
                curl -k -s -u $USERNAME:$PASSWORD -XGET "$NEXUS_URL/service/rest/v1/components?repository=$repo&continuationToken=$CTOKEN" | grep path | cut -d'"' -f 4 | sort >> $LISTDIR/$REPOFILE
                CTOKEN=$(curl -k -s -u $USERNAME:$PASSWORD -XGET "$NEXUS_URL/service/rest/v1/components?repository=$repo&continuationToken=$CTOKEN" | grep continuationToken | cut -d '"' -f 4)
        done

        LISTCOMPONENTNB=0
        LISTFILENB=$(cat $LISTDIR/$REPOFILE | wc -l)
        mkdir -p $DATADIR/$repo
        #for components in $(cat "$LISTDIR/$REPOFILE"); do
        while IFS= read -r components
                do
                LISTCOMPONENTNB=$((LISTCOMPONENTNB + 1))
                VARPATH=$(echo $components | awk 'BEGIN{FS=OFS="/"}{NF--; print}')
                VARFILE=$(echo $components | awk -F/ '{print $NF}')
                echo "[$LISTNB/$LISTREPOSNB] - $repo - [$LISTCOMPONENTNB/$LISTFILENB] - $VARPATH/$VARFILE"
                echo "[$LISTNB/$LISTREPOSNB] - $repo - [$LISTCOMPONENTNB/$LISTFILENB] - $VARPATH/$VARFILE" >> $LOGFILE
                #echo varpath $VARPATH
                #echo varfile $VARFILE

                mkdir -p $DATADIR/$repo/$VARPATH
                if [ -z "$VARPATH" ]; then
                        curl -k -s -u $USERNAME:$PASSWORD -XGET "$NEXUS_URL/repository/$repo/$VARFILE" -o "$DATADIR/$repo/$VARFILE"
                else
                        curl -k -s -u $USERNAME:$PASSWORD -XGET "$NEXUS_URL/repository/$repo/$VARPATH/$VARFILE" -o "$DATADIR/$repo/$VARPATH/$VARFILE"
                fi
        done < $LISTDIR/$REPOFILE
        echo "[$LISTNB/$LISTREPOSNB] - $repo - [$LISTCOMPONENTNB/$LISTFILENB] - $(find $DATADIR/$repo -type f | wc -l) files downloaded in data folder"
        echo "[$LISTNB/$LISTREPOSNB] - $repo - [$LISTCOMPONENTNB/$LISTFILENB] - $(find $DATADIR/$repo -type f | wc -l) files downloaded in data folder" >> $LOGFILE
done