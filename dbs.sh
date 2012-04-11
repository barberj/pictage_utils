#! /bin/bash
# Scripts to refresh/dump databases
# All database files are kept in sql directory

#BASEPATH to store sql files
BASEPATH=~/Dropbox/Pictage/sql
#DEBUG=True

get_qualified_path()
{
    QP=$1
    if [ ! -f $QP ]; then
        if [ -f $QP.sql ]; then
            QP=$QP.sql
            if [ "$DEBUG" ]; then echo 'Passed qualifed file name without extension'; fi
        fi

        if [ -f $BASEPATH/$QP ]; then
            QP=$BASEPATH/$QP
            if [ "$DEBUG" ]; then echo 'Passed the file name, but not qualified'; fi
        fi

        if [ -f $BASEPATH/$QP.sql ]; then
            QP=$BASEPATH/$QP.sql
            if [ "$DEBUG" ]; then echo 'Passed unqualified file name without extension'; fi
        fi
    else
        if [ "$DEBUG" ]; then echo "Passed the fully qualified path $QP"; fi
    fi
    echo $QP
}

if [ "$DEBUG" ]; then
    get_qualified_path atrium
    get_qualified_path ~/Dropbox/Pictage/jobs/atrium
    get_qualified_path ~/Dropbox/Pictage/jobs/atrium.sql
fi

test_activate()
{
    echo 'TEst'
}

refresh_pqsl()
{
    DATABASE=$1
    SQLFILE=${2-$BASEPATH/$DATABASE.sql}
    dropdb $DATABASE 
    createdb $DATABASE
    psql $DATABASE -f $SQLFILE
}

refresh_mysql()
{
    DATABASE=$1
    SQLFILE=${2-$BASEPATH/$DATABASE.sql}

    # check if fully qualified path
    # update if just a date was passed
    # update if relative file name was passed 
    mysql $DATABASE < $SQLFILE
}

refresh_all()
{
    refresh_pqsl atrium
    refresh_pqsl nimbus
    refresh_mysql shootq
}

archive_sql()
{
    DATABASE=$1
    cp $BASEPATH/$DATABASE.sql $BASEPATH/`date "+%Y%m%d"`$DATABASE.sql
}

dump_pqsl()
{
    DATABASE=$1
    pg_dump $DATABASE -cf $BASEPATH/$DATABASE.sql

    # copy the results to date file for historical reference
    archive_sql $DATABASE
}

dump_mysql()
{
    DATABASE=$1
    mysqldump --single-transaction $DATABASE > $BASEPATH/$DATABASE.sql
    archive_sql $DATABASE
}

dump_all()
{
    dump_pqsl atrium
    dump_pqsl nimbus
    dump_mysql shootq
}
