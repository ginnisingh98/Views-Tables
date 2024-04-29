--------------------------------------------------------
--  DDL for Package Body IGI_SLS_UPG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_SLS_UPG_PKG" AS
-- $Header: igislsub.pls 120.0 2008/01/17 21:52:27 vspuli noship $

       l_debug_level NUMBER	:=	FND_LOG.G_CURRENT_RUNTIME_LEVEL;
       l_state_level NUMBER	:=	FND_LOG.LEVEL_STATEMENT;
       l_proc_level  NUMBER	:=	FND_LOG.LEVEL_PROCEDURE;
       l_event_level NUMBER	:=	FND_LOG.LEVEL_EVENT;
       l_excep_level NUMBER	:=	FND_LOG.LEVEL_EXCEPTION;
       l_error_level NUMBER	:=	FND_LOG.LEVEL_ERROR;
       l_unexp_level NUMBER	:=	FND_LOG.LEVEL_UNEXPECTED;

       l_path        VARCHAR2(50)  := 'PLSQL.igi_sls_upg_pkg.';

      /*-----------------------------------------------------------------
      This procedure writes to the error log.
      -----------------------------------------------------------------*/
       PROCEDURE Write_To_Log (p_level IN NUMBER, p_path IN VARCHAR2, p_mesg IN VARCHAR2) IS
       BEGIN
    	IF (p_level >=  l_debug_level ) THEN
                      FND_LOG.STRING  (p_level , l_path || p_path , p_mesg );
            END IF;
       END Write_To_Log;


       /*********** This procedure populates the temp table with all the info needed by us.....***********/
       procedure populate_temp_table_old is
       begin

         /*** Note the where clause.. we are taking care of tables that are secured and allocated to
         security groups, and not tables that are seucred and have no allocations.. ***/
         INSERT INTO igi_sls_upg_itf(SELECT a.table_name, a.owner , a.sls_table_name, NULL,NULL,NULL,get_sls_grps(a.table_name),NULL,NULL
            FROM igi_sls_secure_tables a
            WHERE a.table_name IN( 'PO_VENDORS','PO_VENDOR_CONTACTS', 'PO_VENDOR_SITES_ALL')
            AND  A.table_name NOT IN (SELECT old_table_name FROM igi_sls_upg_itf)
            AND  a.table_name IN (SELECT sls_allocation FROM igi_sls_allocations));

       END populate_temp_table_old;


       FUNCTION get_changed_secured_list  RETURN list_of_old_tables AS
       l_list list_of_old_tables;
       BEGIN

         SELECT distinct old_table_name  BULK COLLECT INTO l_list
         FROM igi_sls_upg_itf ORDER BY old_table_name;

         write_to_log (l_excep_level, 'get_changed_secured_list',SQL%ROWCOUNT ||' rows picked and ' );
         -- Now work with data in the collections
         RETURN l_list;

       END get_changed_secured_list;

       FUNCTION get_new_secured_list  RETURN list_of_old_tables AS
       l_list list_of_old_tables;
       BEGIN
         SELECT new_table_name  BULK COLLECT INTO l_list FROM igi_sls_upg_itf ORDER BY new_table_name;

         write_to_log (l_excep_level, 'get_new_secured_list',SQL%ROWCOUNT ||' rows picked and ' );

        -- Now work with data in the collections
        RETURN l_list;
       END get_new_secured_list;

       /********* Function to form the security groups list dynamically.. ****/
       FUNCTION get_sls_grps(p_table_name varchar2) RETURN VARCHAR2 IS
       l_count NUMBER;
       l_dummy VARCHAR2(2000);
       BEGIN
         SELECT COUNT(*) INTO l_count FROM igi_sls_allocations WHERE sls_allocation = p_table_name  ;

         FOR sec_grp_rec IN
    	  (SELECT sls_group  FROM igi_sls_allocations WHERE sls_allocation = p_table_name)
    	 LOOP
    		IF l_count=1 THEN
    			l_dummy:= l_dummy || sec_grp_rec.sls_group;
    		RETURN l_dummy;
    		ELSIF l_count>1   THEN
    			l_dummy:= l_dummy || sec_grp_rec.sls_group;
    			l_dummy:= l_dummy || ', ';
    			l_count:=l_count-1;
            ELSE  /** This will never occur **/
            return NULL;

    		END IF;
    	 END LOOP;

         EXCEPTION WHEN others THEN
          RETURN NULL;
           /**
           This is an error condition..
           **/

       END get_sls_grps;


       /********* Function to form the security groups list dynamically.. ****/
       /********** Procedure to retrieve the stored security groups list *****/
       PROCEDURE get_security_groups_list(param1 IN list_of_old_tables, param2 OUT NOCOPY list_of_secured_groups) IS
       BEGIN
          FOR indx IN param1.FIRST .. param1.LAST
          LOOP

          SELECT sls_groups INTO param2(indx) FROM igi_sls_upg_itf WHERE  old_table_name=param1(indx);

          END LOOP;


       END get_security_groups_list;

       /********** Procedure to retrieve the stored security groups list *****/


       /******** This proc. popluates the remaining entries of the interface table ****/
       PROCEDURE populate_temp_table_new(param1 IN list_of_old_tables, param2 IN list_of_new_tables, ret_code OUT NOCOPY NUMBER ) is
       BEGIN
          ret_code:=0;
          set_sls_tables_data(param1, param2);
          set_sls_allocations_data(param1, param2);


       EXCEPTION WHEN OTHERS THEN
             ret_code:=1;
             write_to_log (l_excep_level, 'set_sls_tables_data',SQLCODE );
             write_to_log (l_excep_level, 'set_sls_tables_data',SQLERRM );
             write_to_log (l_excep_level, 'set_sls_tables_data','Error in insertion... Please note.. :)' );


       END populate_temp_table_new;


    /******** This proc. popluates the remaining entries of the interface table ****/
    /*********** This procedure sets data in the table IGI_SLS_SECURE_TABLES***********/

       PROCEDURE set_sls_tables_data(param1 IN list_of_old_tables,
       param2 IN list_of_new_tables)
       IS
       l_owner VARCHAR2(5) ;
       l_count NUMBER;
       l_old_table_name VARCHAR2(50);
       l_table_name VARCHAR2(50);
       l_sls_table_name VARCHAR2(50) ;
       l_optimise_sql VARCHAR2(1);
       BEGIN

           FOR indx IN param2.FIRST .. param2.LAST
           LOOP
           l_table_name:=param2(indx);
           l_old_table_name := param1(indx);

         /* To check if this entry is already there in the igi_sls_secure_tables table
         So as to prevent duplicate entry*/
            SELECT COUNT(*) INTO l_count FROM igi_sls_secure_tables WHERE table_name =l_table_name ;
            write_to_log (l_excep_level, 'set_sls_tables_data','Count: '||l_count );


            IF  l_count=0 THEN

           /** First select the owner of this table **/
            SELECT owner INTO l_owner FROM all_objects WHERE object_name=UPPER(l_table_name)
                     AND object_type='TABLE' AND owner IN('AP', 'AR', 'PO', 'XLA','ICX','IBY');
            write_to_log (l_excep_level, 'set_sls_tables_data','Owner: '||l_owner );


            SELECT 'IGI_SLS_' || TO_CHAR(igi_sls_extended_table_s.nextval)
               INTO   l_sls_table_name  FROM   dual;

            write_to_log (l_excep_level, 'set_sls_tables_data','l_sls_table_name: '||l_sls_table_name );


            SELECT OPTIMISE_SQL    INTO l_optimise_sql FROM igi_sls_secure_tables WHERE table_name =l_old_table_name;
            write_to_log (l_excep_level, 'set_sls_tables_data','l_optimise_sql: '||l_optimise_sql );


            write_to_log (l_excep_level, 'set_sls_tables_data','Before insert' );

            /* insert statement... core to this procedure..*/
            INSERT INTO igi_sls_secure_tables(owner, table_name, sls_table_name, update_allowed, creation_date, created_by,
            last_update_login,last_update_date, last_updated_by, optimise_sql) VALUES(l_owner, l_table_name,l_sls_table_name, 'N', sysdate,1,1,sysdate,1, l_optimise_sql );

              write_to_log (l_excep_level, 'set_sls_tables_data','After Insert..' ||SQL%ROWCOUNT ||'row inserted');

             UPDATE igi_sls_upg_itf SET new_table_name=l_table_name,new_owner=l_owner, new_allocation=l_sls_table_name WHERE old_table_name = l_old_table_name;

             END IF;
             END LOOP;


        END set_sls_tables_data;

        /*********** This procedure sets data in the table IGI_SLS_SECURE_TABLES***********/




        /***** Procedure to set data in IGI_SLS_ALLOCATIONS ***/
        PROCEDURE set_sls_allocations_data( param1 IN list_of_old_tables, param2 IN list_of_new_tables) is
          l_old_table_name VARCHAR2(50);
          l_table_name VARCHAR2(50);
          l_sls_group  VARCHAR2(50);
          l_list row_id_list;
          l_rowid ROWID;
          l_count NUMBER;
        BEGIN

             FOR indx IN param2.FIRST .. param2.LAST
             LOOP
             l_table_name:=param2(indx);
             l_old_table_name := param1(indx);


            /** This table has a index attached on 4 columns and no primary key.. hence using rowid to
            uniquely picking up rows */

            SELECT ROWID BULK COLLECT INTO l_list FROM igi_sls_allocations WHERE sls_allocation =l_old_table_name;

            FOR indx1 IN l_list.FIRST .. l_list.LAST
            LOOP
            l_rowid:=l_list(indx1);
            SELECT sls_group INTO l_sls_group FROM igi_sls_allocations WHERE ROWID=l_rowid;

            /** Check if this entry is already there in the table **/
            SELECT COUNT(*) INTO l_count  FROM igi_sls_allocations WHERE sls_group=l_sls_group
            AND sls_allocation = l_table_name;

            /** Insert only if the entry is not present.. */
            IF(l_count =0)THEN
            INSERT INTO igi_sls_allocations (SELECT SLS_GROUP ,SLS_GROUP_TYPE ,l_table_name ,SLS_ALLOCATION_TYPE,
            SYSDATE ,null,null,null,SYSDATE ,CREATED_BY,1,sysdate,1 FROM
            igi_sls_allocations WHERE ROWID=l_rowid) ;

            END IF;
            END LOOP;

        END LOOP;
        END set_sls_allocations_data;

        /***** Procedure to set data in IGI_SLS_ALLOCATIONS ***/



        /********** Very imp. procedure... Final Steps that are to be done...******/
        /**** Make a few changes needed in R12*************/
        PROCEDURE disable_old_tables IS
        BEGIN

        update igi_sls_secure_tables set table_name='PO_VENDORS_OBS'
                                                        where table_name='PO_VENDORS';
        update igi_sls_secure_tables set table_name='PO_VENDOR_CONTACTS_OBS'
                                                        where table_name='PO_VENDOR_CONTACTS';
        update igi_sls_secure_tables set table_name='PO_VENDOR_SITES_OBS'
                                                        where table_name='PO_VENDOR_SITES_ALL';
        update igi_sls_allocations set sls_allocation='PO_VENDORS_OBS'
                                                        where sls_allocation='PO_VENDORS';
        update igi_sls_allocations set sls_allocation='PO_VENDOR_CONTACTS_OBS'
                                                        where sls_allocation='PO_VENDOR_CONTACTS';
        update igi_sls_allocations set sls_allocation='PO_VENDOR_SITES_OBS'
                                                        where sls_allocation='PO_VENDOR_SITES_ALL';

        delete from  IGI_GCC_INST_OPTIONS_ALL where OPTION_NAME='SLS';

        END disable_old_tables;
        /********** Very imp. procedure... Disabling the security for the old tables...******/




        /******** Set data useful in forming main query ********/
        PROCEDURE set_query_data(param1 in list_of_old_tables , param2 in list_of_from, param3 in list_of_where) IS
        BEGIN
        FOR indx IN param1.FIRST .. param2.LAST
        LOOP
        UPDATE igi_sls_upg_itf SET from_clause=param2(indx) , where_clause=param3(indx)
            WHERE old_table_name=param1(indx) AND param3(indx) IS NOT NULL;

         write_to_log (l_excep_level, 'set_query_data',SQL%ROWCOUNT ||' rows updated' );

        END LOOP;

        END;

        /******** Set data useful in forming main query ********/


        /*********** Procedure that migrates data ************/
         PROCEDURE migrate_data(param1 IN list_of_old_tables, param2 IN list_of_new_tables,
                param3 IN list_of_from, param4 IN list_of_where) IS
         l_sls_tab_old VARCHAR2(50);
         l_sls_tab_new VARCHAR2(50);
         l_old_table VARCHAR2(50);
         l_new_table VARCHAR2(50);

         l_query VARCHAR2(3500);
         l_select VARCHAR2(3000);
         l_from VARCHAR2(500);

         BEGIN

            FOR indx IN param1.FIRST .. param1.LAST
            LOOP

               SELECT old_allocation, new_allocation INTO l_sls_tab_old, l_sls_tab_new FROM igi_sls_upg_itf
               WHERE old_table_name=param1(indx);

               l_old_table := param1(indx);
               l_new_table := param2(indx);


               IF l_old_table = 'PO_VENDORS' THEN
                  l_old_table := 'PO_VENDORS_OBS';
               ELSIF l_old_table = 'PO_VENDOR_CONTACTS' THEN
                  l_old_table := 'PO_VENDOR_CONTACTS_OBS';
               ELSIF l_old_table = 'PO_VENDOR_SITES_ALL' THEN
                  l_old_table := 'PO_VENDOR_SITES_OBS';
               END IF;



               l_from:=param3(indx);

               IF(l_from IS NULL) THEN
               l_from:=l_old_table ||' a , '|| l_new_table || ' b , '||l_sls_tab_old ||' c ';
               ELSE
               l_from:= l_old_table ||' a , '|| l_new_table || ' b , '||l_sls_tab_old ||' c '||', '||l_from;
               END IF;

               l_select := ' SELECT DISTINCT b.ROWID , c.SLS_SEC_GRP , ' ||
               ' c.PREV_SLS_SEC_GRP , c.CHANGE_DATE FROM '|| l_from ||  ' WHERE a.ROWID=c.SLS_ROWID AND '|| param4(indx) ||
                ' AND NOT EXISTS (SELECT ''X''' || ' FROM ' || l_sls_tab_new ||' e '|| ' WHERE  b.rowid = e.sls_rowid )';

               write_to_log (l_excep_level, 'migrate_data','Select Statement Executed'||l_select );

               l_query:= ' INSERT INTO '|| l_sls_tab_new ||'(' || l_select ||')';

               write_to_log (l_excep_level, 'migrate_data','Query Executed'||l_query );



               /*
               INSERT INTO new_allocation( SELECT DISTINCT b.ROWID , c.sls_sec_group,
               c.PREV_SLS_SEC_GRP , c.CHANGE_DATE FROM
               param1(indx) a ,param2(indx) b , old_allocation c
               WHERE a.ROWID=c.row_id) AND param3(indx));
               */
               EXECUTE IMMEDIATE l_query;
               write_to_log (l_excep_level, 'migrate_data',SQL%ROWCOUNT ||' rows inserted' );

           END LOOP;

           EXCEPTION WHEN OTHERS THEN
             write_to_log (l_excep_level, 'migrate_data',SQLCODE );
             write_to_log (l_excep_level, 'migrate_data',SQLERRM );
             write_to_log (l_excep_level, 'migrate_data','Error in insertion... Please note.. :)' );
           END migrate_data;
      /*********** Procedure that migrates data ************/



      /*********** Procedure for providing concurrency ******/

      PROCEDURE fnd_wait_for_request(req_id IN NUMBER, dev_status OUT NOCOPY VARCHAR2, dev_phase OUT NOCOPY VARCHAR2) IS
      l_ret BOOLEAN;
      l_reqid NUMBER;
      l_phase VARCHAR2(500);
      l_status VARCHAR2(500);
      l_devphase VARCHAR2(500);
      l_devstatus VARCHAR2(500);
      l_message VARCHAR2(500);
      l_count NUMBER;
      BEGIN
      l_reqid:=req_id;

      l_ret := fnd_concurrent.wait_for_request(l_reqid,5,0,l_phase,l_status,l_devphase,l_devstatus,l_message);

      IF l_ret THEN
       write_to_log (l_excep_level, 'fnd_wait_for_request','l_ret: True' );
       ELSE
       write_to_log (l_excep_level, 'fnd_wait_for_request','l_ret: False' );
      END IF;
      l_count:=0;


      LOOP

       dev_status := l_devstatus;
       dev_phase := l_devphase;

       EXIT WHEN  UPPER(dev_phase)='COMPLETE' AND UPPER(dev_status)='NORMAL' ;
       l_count:=l_count +1;
       END LOOP;

       write_to_log (l_excep_level, 'fnd_wait_for_request','l_count: '||l_count );
       write_to_log (l_excep_level, 'fnd_wait_for_request','l_req: '||l_reqid );
       write_to_log (l_excep_level, 'fnd_wait_for_request','l_phase: ' ||l_phase );
       write_to_log (l_excep_level, 'fnd_wait_for_request','l_status: '||l_status );
       write_to_log (l_excep_level, 'fnd_wait_for_request','l_devphase: '||l_devphase );
       write_to_log (l_excep_level, 'fnd_wait_for_request','l_devstatus: '||l_devstatus );
       write_to_log (l_excep_level, 'fnd_wait_for_request','l_message: '||l_message );


      END fnd_wait_for_request;


      /*********** Procedure for providing concurrency ******/

    END igi_sls_upg_pkg ;


/
