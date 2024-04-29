--------------------------------------------------------
--  DDL for Package Body IGI_SLS_IMP_EXP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_SLS_IMP_EXP" AS
--$Header: igislseb.pls 120.2.12010000.2 2008/08/04 13:07:19 sasukuma ship $

PROCEDURE create_sls_datafix  (errbuf out nocopy varchar2,retcode out nocopy number,request_type  in varchar2)
   IS
--       retcode number(1);
--       errbuf  varchar2(30);
       already_exists EXCEPTION;
       l_excep_level number(1);
       l_sql_str varchar2(300);
       l_sql_trun varchar2(300);
       l_count_rec varchar2(300);
       l_num_rec number;
       l_sql_ins varchar2(300);
       l_Start_Time varchar2(100);
       l_End_Time varchar2(100);
       session varchar2(5) := 'IGI';


   CURSOR c_get_enab_sectab IS
          SELECT  owner,
                  table_name,
                  sls_table_name,
                  date_enabled,
                  date_disabled,
                  date_removed,
                  date_security_applied,
                  update_allowed
          FROM    igi_sls_secure_tables
          WHERE   date_removed IS NULL
          AND     date_object_created IS NOT NULL;


   BEGIN

       retcode := 0;
       errbuf  := 'Normal Completion';

    --   select to_char(sysdate, 'Dy DD-Mon-YYYY HH24:MI:SS') into  l_Start_Time  from dual;
      -- dbms_output.put_line(l_Start_Time||' Start time');


       -- Create addiotional column in SLS secured  tables --
       FOR rt_c_get_enab_sectab IN c_get_enab_sectab
       LOOP
              --  dbms_output.put_line(rt_c_get_enab_sectab.table_name||' Before count');
              l_count_rec :=('select count(*) from '||rt_c_get_enab_sectab.sls_table_name);
              EXECUTE IMMEDIATE l_count_rec into l_num_rec;
              --  dbms_output.put_line(rt_c_get_enab_sectab.table_name||' After Count'||l_num_rec);

         IF request_type = 'PRE-EXPORT' THEN
            IF l_num_rec <> 0 THEN
            --  dbms_output.put_line(rt_c_get_enab_sectab.table_name||' Inside Condition');
              -- Call procedure to create additional column in to core tables
               igi_sls_objects_pkg.create_sls_col
                     (sec_tab         => rt_c_get_enab_sectab.table_name,
                      schema_name     => rt_c_get_enab_sectab.owner,
                      errbuf         => errbuf,
                      retcode        => retcode);


            -- Populate New column with SLS group from SLS Tables

                 l_sql_str :=('UPDATE '||
                        rt_c_get_enab_sectab.owner||'.'||rt_c_get_enab_sectab.table_name||' a '
                        ||'SET a.igi_sls_sec_group =' ||
                        '(SELECT b.sls_sec_grp from '|| rt_c_get_enab_sectab.sls_table_name||' b '||
                        'WHERE a.rowid = b.sls_rowid) WHERE EXISTS (SELECT '||'''x''' ||' from '
                       || rt_c_get_enab_sectab.sls_table_name||' c where c.sls_rowid = a.rowid)');

                     EXECUTE IMMEDIATE l_sql_str;
                        COMMIT;
             END IF;
         ELSIF request_type = 'PRE-EXPORT-UNDO' OR request_type ='POST-IMPORT' THEN

             IF request_type ='POST-IMPORT' THEN
                IF l_num_rec <> 0 THEN
                   -- Truncate SLS tables
                   l_sql_trun := 'BEGIN'||' IGI.apps_ddl.apps_ddl('||''''||'TRUNCATE TABLE '||session||'.'||rt_c_get_enab_sectab.sls_table_name||''''||');END;';


                   EXECUTE IMMEDIATE l_sql_trun;
                END IF;
                -- Copy data(new rowid and SLS group name)  to SLS tables
                IGI_SLS_IMP_EXP.insert_sls_data(rt_c_get_enab_sectab.sls_table_name,
                                              rt_c_get_enab_sectab.owner,
                                              rt_c_get_enab_sectab.table_name);

             END IF;
                 -- Drop column in core tables

               igi_sls_objects_pkg.drop_sls_col (sec_tab         => rt_c_get_enab_sectab.table_name,
                                                   schema_name     => rt_c_get_enab_sectab.owner,
                                                   errbuf         => errbuf,
                                                   retcode        => retcode);





          END IF;

       END LOOP;

    --   select to_char(sysdate, 'Dy DD-Mon-YYYY HH24:MI:SS') into  l_End_Time  from dual;
    --   dbms_output.put_line(l_End_Time||' End time');

       EXCEPTION

          WHEN already_exists
          THEN  NULL;

           WHEN OTHERS
           THEN
           FND_MESSAGE.SET_NAME('IGI', 'IGI_LOGGING_USER_ERROR'); -- Seeded Message
           l_excep_level :=1;
           retcode := 2;
           errbuf :=  Fnd_message.get;
           igi_sls_objects_pkg .write_to_log(l_excep_level, 'create_sls_col','END igi_sls_objects_pkg.create_sls_col - failed with error ' || SQLERRM );
          -- dbms_output.put_line(SQLERRM);
           RETURN;

END create_sls_datafix;


PROCEDURE insert_sls_data(sls_tab IN VARCHAR2,schema_name IN VARCHAR2,core_tab in varchar2)IS
l_sql_ins varchar2(300);
already_exists EXCEPTION;
PRAGMA EXCEPTION_INIT(already_exists, -00904);
BEGIN

     l_sql_ins :=('Insert into '||sls_tab||'(SLS_ROWID,SLS_SEC_GRP) '||
                '(select a.rowid,a.IGI_SLS_SEC_GROUP from '||schema_name||'.'||core_tab||' a'||' where a.IGI_SLS_SEC_GROUP is not null)');
     EXECUTE IMMEDIATE l_sql_ins;
     COMMIT;
EXCEPTION
  WHEN already_exists
  THEN null;
END insert_sls_data;

END IGI_SLS_IMP_EXP;

/
