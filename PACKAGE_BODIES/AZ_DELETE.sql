--------------------------------------------------------
--  DDL for Package Body AZ_DELETE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AZ_DELETE" AS
/* $Header: azdeleteb.pls 120.1.12000000.2 2007/02/23 06:32:11 lmathur noship $ */
COMMIT_BATCH_SIZE NUMBER;
v_dml_count       NUMBER := 0;
/**********************************************************/
--Procedure to delete all records irrespective to the 'source'
PROCEDURE delete_all(p_request_id IN NUMBER,
          	 p_table_name IN VARCHAR2) IS


v_source_list         TYP_NEST_TAB_VARCHAR;
v_id_list             TYP_NEST_TAB_NUMBER;

BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=''SIMILAR''';
        COMMIT_BATCH_SIZE := FND_PROFILE.VALUE('AZ_COMMIT_ROWCOUNT');
        COMMIT_BATCH_SIZE := COMMIT_BATCH_SIZE*2; --can take more records for deletion
	--gather stats on the table from which the records are to be deleted
	FND_STATS.GATHER_TABLE_STATS('AZ',p_table_name);
        execute immediate 'select distinct(source) from '||p_table_name||
                          ' where request_id='||p_request_id
                          BULK COLLECT INTO v_source_list;

        IF v_source_list.COUNT >0 THEN
                 FOR i IN 1 .. v_source_list.COUNT LOOP
                     BEGIN
                        delete_source(p_request_id,v_source_list(i),p_table_name);
                        EXCEPTION

                       WHEN OTHERS THEN
                            raise_application_error(-20001,
                            'DELETE_ALL: Error while deleting records for a given source:'||v_source_list(i));
                     END;
                 END LOOP; -- loop
              END IF; -- the number of distinct source > 0

        COMMIT;

EXCEPTION

    WHEN OTHERS THEN
     raise_application_error(-20001,
                'Error occurred while deleting records for request id:'||p_request_id);
FND_STATS.GATHER_TABLE_STATS('AZ',p_table_name);
END delete_all;


-- procedure to delete all the records for a given source
PROCEDURE delete_source(p_request_id IN NUMBER,p_source IN VARCHAR2,p_table_name IN VARCHAR2)
IS
v_id_list             TYP_NEST_TAB_NUMBER;
TYPE cur_type IS REF CURSOR;
cur_id cur_type;

BEGIN
    open cur_id for 'select id from '||p_table_name||
                    ' where request_id=:1 and source=:2'
                    USING p_request_id,p_source;
    LOOP
    FETCH cur_id BULK COLLECT INTO v_id_list LIMIT COMMIT_BATCH_SIZE;

    FORALL i IN 1..v_id_list.COUNT
    execute immediate 'delete from '||p_table_name||' where
                        request_id=:1 and source=:2 and
                        id=:3' using p_request_id,p_source,v_id_list(i);
    COMMIT;
    EXIT WHEN cur_id%NOTFOUND;
    END LOOP;
    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
     raise_application_error(-20001,
                'Error in deletion for source:'||p_source);
END delete_source;


END;

/
