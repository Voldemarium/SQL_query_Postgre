cat $(ls -v undo.*.sql) \
    | psql --username=postgres \
           --echo-errors \
           --set="ON_ERROR_STOP=1" \
           --dbname=test
