--------------------------------------------------------
--  DDL for Package Body FND_STATS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_STATS" AS
                /* $Header: AFSTATSB.pls 120.12.12010000.20 2014/04/14 20:03:26 msaleem ship $ */
                db_versn           NUMBER :=81;
		-- changes done for bug 11835452
		def_estimate_pcnt  NUMBER;
                request_from       VARCHAR2(7) DEFAULT 'U';
                MAX_ERRORS_PRINTED NUMBER       := 20 ;         -- The max nof. allowable errors.
                STD_GRANULARITY    VARCHAR2(15) := 'DEFAULT' ;  -- Global/partion
                PART_GRANULARITY   VARCHAR2(15) := 'PARTITION' ;-- Granularity is partition level.
                ALL_GRANULARITY    VARCHAR2(15) := 'ALL' ;      -- Granularity is ALL.
                INDEX_LEVEL        NUMBER       := 1 ;                /* default ind_level for fudged ind. stats,
                came to this value so that optimizer
                prefers index access */
                fnd_stattab       VARCHAR2(30) := 'FND_STATTAB'; -- Name of the backup table
                fnd_statown       VARCHAR2(30) := 'APPLSYS';     -- Owner of the backup table
                stat_tab_exist    BOOLEAN      := false;
                dummy1            VARCHAR2(30);
                dummy2            VARCHAR2(30);
                dummybool         BOOLEAN ;
                cur_request_id    NUMBER(15) DEFAULT NULL;
                call_from_sqlplus BOOLEAN :=false;
                fm_first_flag     BOOLEAN :=true; -- Flush_monitoring first time call flag
                stathist          VARCHAR2(8);
                def_degree        NUMBER; -- default degree for parallel
                g_Errors Error_Out;
                -- New cursort to support MVs
                CURSOR schema_cur IS
                        SELECT upper(oracle_username) sname
                        FROM   fnd_oracle_userid
                        WHERE  oracle_id BETWEEN 900 AND 999
                           AND read_only_flag = 'U'

                        UNION ALL

                        SELECT DISTINCT upper(oracle_username) sname
                        FROM            fnd_oracle_userid a,
                                        fnd_product_installations b
                        WHERE           a.oracle_id = b.oracle_id
			AND EXISTS -- sub query added for bug 17189881
              (SELECT 'x'
                 FROM dba_tables
                WHERE owner = UPPER (oracle_username))
                        ORDER BY        sname;

        /************************************************************************/
        /* Function : GET_BLOCKS                                                */
        /* Desciption: Gets the size in blocks of the given table.              */
        /************************************************************************/
FUNCTION GET_BLOCKS(schemaname  IN VARCHAR2,
                    object_name IN VARCHAR2,
                    object_type IN VARCHAR2)
        RETURN NUMBER
IS
        total_blocks   NUMBER;
        total_bytes    NUMBER;
        unused_blocks  NUMBER;
        unused_bytes   NUMBER;
        last_extf      NUMBER;
        last_extb      NUMBER;
        last_usedblock NUMBER;
BEGIN
        DBMS_SPACE.UNUSED_SPACE(upper(schemaname),upper(object_name),upper(object_type),total_blocks, total_bytes,unused_blocks,unused_bytes,last_extf,last_extb, last_usedblock);
        RETURN total_blocks-unused_blocks;
EXCEPTION
WHEN OTHERS THEN
        -- For partitioned tables, we will get an exception as it unused space
        -- expects a partition spec. If table is partitioned, we definitely
        -- do not want to do serial, so will return thold+1000.
        RETURN fnd_stats.SMALL_TAB_FOR_PAR_THOLD+1000;
END;
/************************************************************************/
/* Procedure:  SCHEMA_MONITORING                                        */
/* Desciption: Non Public procedure that is called by                   */
/* ENABLE_SCHEMA_MONITORING or DISABLE_SCHEMA_MONITORING                */
/************************************************************************/
PROCEDURE SCHEMA_MONITORING(mmode      IN VARCHAR2,
                            schemaname IN VARCHAR2)
IS
TYPE name_tab
IS
        TABLE OF dba_tables.table_name%TYPE;
        tmp_str VARCHAR2(200);
        names name_tab;
        num_tables NUMBER := 0;
        modeval    VARCHAR2(5);
        modbool    VARCHAR2(6);
BEGIN
        IF mmode        ='ENABLE' THEN
                modeval:='YES';
                modbool:='TRUE';
        ELSE
                modeval:='NO';
                modbool:='FALSE';
        END IF;
        IF (( db_versn > 80) AND
                (
                        db_versn < 90
                )
                ) THEN
                -- 8i does not have the ALTER_SCHEMA_TAB_MONITORING function,
                -- therefore this has to be taken care of manually.
                IF schemaname         ='ALL' THEN -- call itself with the schema name
                        FOR c_schema IN schema_cur
                        LOOP
                                FND_STATS.SCHEMA_MONITORING(mmode,c_schema.sname);
                        END LOOP;
                        /* schema_cur */
                ELSE -- schemaname<>'ALL'
                        SELECT table_name BULK COLLECT
                        INTO   names
                        FROM   dba_tables
                        WHERE  owner = upper(schemaname)
                           AND
                               (
                                      iot_type <> 'IOT_OVERFLOW'
                                   OR iot_type IS NULL
                               )
                           AND TEMPORARY  <> 'Y'
                           AND monitoring <> modeval; -- skip table that already have the selected mode
                        num_tables        := SQL%ROWCOUNT;
                        FOR i             IN 1..num_tables
                        LOOP
                                IF mmode        ='ENABLE' THEN
                                        tmp_str:='ALTER TABLE '
                                        ||upper(schemaname)
                                        ||'.'
                                        ||names(i)
                                        ||' MONITORING';
                                elsif mmode     ='DISABLE' THEN
                                        tmp_str:='ALTER TABLE '
                                        ||upper(schemaname)
                                        ||'.'
                                        ||names(i)
                                        ||' NOMONITORING';
                                END IF;
                                EXECUTE IMMEDIATE tmp_str;
                                dbms_output.put_line(tmp_str);
                        END LOOP;
                END IF; -- if schemaname ='ALL'
        elsif ((db_versn > 90 ) AND
                (
                        db_versn < 100
                )
                ) THEN
                -- 8i does not have the ALTER_SCHEMA_TAB_MONITORING function,
                -- therefore 9i specific function calls have to be dynamic sql.
                IF schemaname   ='ALL' THEN
                        tmp_str:='BEGIN dbms_stats.ALTER_DATABASE_TAB_MONITORING(monitoring=>'
                        ||modbool
                        ||',sysobjs=>FALSE); END;';
                        EXECUTE IMMEDIATE tmp_str;
                ELSE
                        tmp_str:='BEGIN dbms_stats.ALTER_SCHEMA_TAB_MONITORING(ownname=>:SCHEMANAME,monitoring=>'
                        ||modbool
                        ||'); END;';
                        EXECUTE IMMEDIATE tmp_str USING schemaname;
                END IF;
        ELSE -- db version is 10, do nothing as it is taken care of by default.
                -- db_versn is a 2 char code, which is 10 for 10g.
                NULL;
        END IF;
END;
/************************************************************************/
/* Procedure: ENABLE_SCHEMA_MONITORING                                  */
/* Desciption: Enables MONITORING option for all tables in the          */
/* given schema. If schemaname is not specified, defaults to 'ALL'.     */
/************************************************************************/
PROCEDURE ENABLE_SCHEMA_MONITORING(schemaname IN VARCHAR2)
IS
BEGIN
        SCHEMA_MONITORING('ENABLE',schemaname);
END;
/************************************************************************/
/* Procedure: ENABLE_SCHEMA_MONITORING                                  */
/* Desciption: Enables MONITORING option for all tables in the          */
/* given schema. If schemaname is not specified, defaults to 'ALL'.     */
/************************************************************************/
PROCEDURE DISABLE_SCHEMA_MONITORING(schemaname IN VARCHAR2)
IS
BEGIN
        SCHEMA_MONITORING('DISABLE',schemaname);
END;
/************************************************************************/
/* Procedure: GET_PARALLEL                                              */
/* Desciption: Gets the min between number of parallel max servers      */
/* and the cpu_count. This number is used as a default degree of        */
/* parallelism is none is specified.                                    */
/************************************************************************/
PROCEDURE GET_PARALLEL(parallel IN OUT NOCOPY NUMBER)
IS
BEGIN
        SELECT MIN(to_number(value))
        INTO   parallel
        FROM   v$parameter
        WHERE  name ='parallel_max_servers'
            OR name ='cpu_count';

END;
/************************************************************************/
/* Function: GET_REQUEST_ID                                             */
/* Desciption: Gets the current request_id                              */
/* If the call is thru a concurrent program, the conc request id is     */
/* returned, which can be later over-ridden if restart case.            */
/* If is is not thru a concurrent program, a user request id is         */
/* generated.                                                           */
/************************************************************************/
FUNCTION GET_REQUEST_ID  RETURN NUMBER
IS
        str_request_id VARCHAR2(30);
        request_id_l   NUMBER(15);
        l_message      VARCHAR2(1000);
BEGIN
        --      FND_PROFILE.GET('CONC_REQUEST_ID', str_request_id);
        --        if str_request_id is not null then  -- call is via a conc program
        IF FND_GLOBAL.CONC_REQUEST_ID > 0 THEN                      -- call is via a conc program
                request_from         :='C';                         -- set request type C for CONC
                request_id_l         := FND_GLOBAL.CONC_REQUEST_ID; -- set request id to conc request id
        elsif ( FND_GLOBAL.USER_ID    > 0) THEN                     -- check if call from apps program
                request_from         :='P';                         -- P for PROG , cal by program
                -- generate it from sequence
                SELECT fnd_stats_hist_s.nextval
                INTO   request_id_l
                FROM   dual;

        ELSE                       -- call not from within apps context, maybe sqlplus
                request_from:='U'; -- U for USER, called from sqlplus etc
                -- generate it from sequence
                SELECT fnd_stats_hist_s.nextval
                INTO   request_id_l
                FROM   dual;

        END IF;
        -- dbms_output.put_line('Request_id is '||request_id);
        -- dbms_output.put_line('Effective Request_id is '||request_id_l);
        -- l_message := 'Request_id is '||cur_request_id|| 'Effective Request_id is '||request_id_l;
        -- FND_FILE.put_line(FND_FILE.log,l_message);
        RETURN request_id_l;
END;
/************************************************************************/
/* Procedure: CREATE_STAT_TABLE                                         */
/* Desciption: Create stats table to hold statistics. Default parameters*/
/* are used for tablename and owner.                                    */
/************************************************************************/
PROCEDURE CREATE_STAT_TABLE
IS
        PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
        -- if stat_tab has already been created, do not recreate
        BEGIN
                dummy1:='N';
                EXECUTE immediate 'select ''Y'' from all_tables '
                || ' where owner='''
                ||fnd_statown
                || ''' and table_name='''
                ||fnd_stattab
                ||'''' INTO dummy1;
        EXCEPTION
        WHEN OTHERS THEN
                stat_tab_exist:=false;
        END;
        IF dummy1               ='Y' THEN
                stat_tab_exist := true;
        END IF;
        IF stat_tab_exist = false THEN
                DBMS_STATS.CREATE_STAT_TABLE(fnd_statown,fnd_stattab);
                stat_tab_exist := true;
        END IF;
EXCEPTION
WHEN OTHERS THEN
        raise;
END ;
/* CREATE_STAT_TABLE */
/************************************************************************/
/* Procedure: CREATE_STAT_TABLE                                         */
/* Desciption: Create stats table to hold statistics. Caller can specify*/
/* cusotm values for schema, tablename or tablespace name               */
/************************************************************************/
PROCEDURE CREATE_STAT_TABLE( schemaname IN VARCHAR2,
                             tabname    IN VARCHAR2,
                             tblspcname IN VARCHAR2 DEFAULT NULL)
IS
        PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
        DBMS_STATS.CREATE_STAT_TABLE(schemaname,tabname,tblspcname);
EXCEPTION
WHEN OTHERS THEN
        raise;
END;
/* CREATE_STAT_TABLE(,,) */
/**
*  procedure TRANSFER_STATS : Wrapper around backup/restore stats procedures,
*                             required for the new "Backup/Restore Statistics"
*                             conc program.
*/
PROCEDURE TRANSFER_STATS( errbuf OUT NOCOPY  VARCHAR2,
                          retcode OUT NOCOPY VARCHAR2,
                          action     IN          VARCHAR2,
                          schemaname IN          VARCHAR2,
                          tabname    IN          VARCHAR2,
                          stattab    IN          VARCHAR2 DEFAULT 'FND_STATTAB',
                          statid     IN          VARCHAR2 )
IS
        exist_insufficient EXCEPTION;
        pragma exception_init(exist_insufficient,-20000);
        l_message VARCHAR2(1000);
BEGIN
        BEGIN
                create_stat_table(schemaname,stattab);
        EXCEPTION
        WHEN OTHERS THEN
                NULL;
        END;
        IF(upper(action) = 'BACKUP') THEN
                IF(tabname IS NULL) THEN
                        BACKUP_SCHEMA_STATS( schemaname , statid );
                ELSE
                        BACKUP_TABLE_STATS( schemaname , tabname , statid ) ;
                END IF;
        elsif(upper(action) = 'RESTORE') THEN
                IF(tabname IS NULL) THEN
                        RESTORE_SCHEMA_STATS( schemaname , statid );
                ELSE
                        RESTORE_TABLE_STATS(schemaname , tabname , statid );
                END IF;
        END IF;
EXCEPTION
WHEN exist_insufficient THEN
        errbuf    := sqlerrm ;
        retcode   := '2';
        l_message := errbuf;
        FND_FILE.put_line(FND_FILE.log,l_message);
        raise;
WHEN OTHERS THEN
        errbuf    := sqlerrm ;
        retcode   := '2';
        l_message := errbuf;
        FND_FILE.put_line(FND_FILE.log,l_message);
        raise;
END;
/************************************************************************/
/* Procedure: BACKUP_SCHEMA_STATS                                       */
/* Desciption: Copies schema statistics to fnd_stattab table. If schema */
/* name is 'ALL', copies all schema stats. Statistics stored with       */
/* a particular stat id.                                                */
/************************************************************************/
PROCEDURE BACKUP_SCHEMA_STATS( schemaname IN VARCHAR2,
                               statid     IN VARCHAR2)
IS
        exist_insufficient EXCEPTION;
        pragma exception_init(exist_insufficient,-20002);
BEGIN
        -- First create the FND_STATTAB if it doesn't exist.
        BEGIN
                FND_STATS.CREATE_STAT_TABLE();
        EXCEPTION
        WHEN exist_insufficient THEN
                NULL;
        END;
        IF (upper(schemaname) <> 'ALL') THEN
                DBMS_STATS.EXPORT_SCHEMA_STATS(schemaname, fnd_stattab, statid, fnd_statown);
        ELSE
                FOR c_schema IN schema_cur
                LOOP
                        DBMS_STATS.EXPORT_SCHEMA_STATS(c_schema.sname, fnd_stattab, statid, fnd_statown);
                END LOOP;
                /* schema_cur */
        END IF;
END;
/* BACKUP_SCHEMA_STATS() */
/************************************************************************/
/* Procedure: BACKUP_TABLE_STATS                                        */
/* Desciption: Copies table statistics along with index and column      */
/* stats if cascade is true. Procedure is called from concurrent program*/
/* manager.                                                             */
/************************************************************************/
PROCEDURE BACKUP_TABLE_STATS( errbuf OUT NOCOPY  VARCHAR2,
                              retcode OUT NOCOPY VARCHAR2,
                              schemaname IN      VARCHAR2,
                              tabname    IN      VARCHAR2,
                              statid     IN      VARCHAR2 DEFAULT 'BACKUP',
                              partname   IN      VARCHAR2 DEFAULT NULL,
                              CASCADE    IN      BOOLEAN DEFAULT true )
IS
        exist_insufficient EXCEPTION;
        pragma exception_init(exist_insufficient,-20000);
        l_message VARCHAR2(1000);
BEGIN
        FND_STATS.BACKUP_TABLE_STATS(schemaname, tabname, statid, partname, CASCADE);
EXCEPTION
WHEN exist_insufficient THEN
        errbuf    := sqlerrm ;
        retcode   := '2';
        l_message := errbuf;
        FND_FILE.put_line(FND_FILE.log,l_message);
        raise;
WHEN OTHERS THEN
        errbuf    := sqlerrm ;
        retcode   := '2';
        l_message := errbuf;
        FND_FILE.put_line(FND_FILE.log,l_message);
        raise;
END;
/*   BACKUP_TABLE_STATS */
/************************************************************************/
/* Procedure: BACKUP_TABLE_STATS                                        */
/* Desciption: Copies table statistics along with index and column      */
/* stats if cascade is true. Procedure is called by the concurrent      */
/* program manager version of BACKUP_TABLE_STATS. Procedure can also be */
/* called from sqlplus                                                  */
/************************************************************************/
PROCEDURE BACKUP_TABLE_STATS( schemaname IN VARCHAR2,
                              tabname    IN VARCHAR2,
                              statid     IN VARCHAR2 DEFAULT 'BACKUP',
                              partname   IN VARCHAR2 DEFAULT NULL,
                              CASCADE    IN BOOLEAN DEFAULT true )
IS
        exist_insufficient EXCEPTION;
        pragma exception_init(exist_insufficient,-20002);
BEGIN
        -- First create the FND_STATTAB if it doesn't exist.
        BEGIN
                FND_STATS.CREATE_STAT_TABLE();
        EXCEPTION
        WHEN exist_insufficient THEN
                NULL;
        END;
        DBMS_STATS.EXPORT_TABLE_STATS(schemaname, tabname, partname, fnd_stattab, statid, CASCADE, fnd_statown) ;
END;
/* BACKUP_TABLE_STATS() */
/************************************************************************/
/* Procedure: RESTORE_SCHEMA_STATS                                      */
/* Desciption: Retores schema statistics from fnd_stattab table. If     */
/* schema name is 'ALL', copies all schema stats. Statistics restored   */
/* with a particular stat id.                                           */
/************************************************************************/
PROCEDURE RESTORE_SCHEMA_STATS(schemaname IN VARCHAR2,
                               statid     IN VARCHAR2 DEFAULT NULL)
IS
BEGIN
        IF (upper(schemaname) <> 'ALL') THEN
                DBMS_STATS.IMPORT_SCHEMA_STATS(schemaname, fnd_stattab, statid, fnd_statown);
        ELSE
                FOR c_schema IN schema_cur
                LOOP
                        DBMS_STATS.IMPORT_SCHEMA_STATS(c_schema.sname, fnd_stattab, statid, fnd_statown);
                END LOOP;
                /* schema_cur */
        END IF;
END;
/* RESTORE_SCHEMA_STATS() */
/************************************************************************/
/* Procedure: RESTORE_TABLE_STATS                                       */
/* Desciption: Retores table statistics from fnd_stattab table. If      */
/* cascase is true, restores column as well as index stats too. This    */
/* procedure is called from concurrent program manager.                 */
/************************************************************************/
PROCEDURE RESTORE_TABLE_STATS(errbuf OUT NOCOPY  VARCHAR2,
                              retcode OUT NOCOPY VARCHAR2,
                              ownname  IN         VARCHAR2,
                              tabname  IN         VARCHAR2,
                              statid   IN         VARCHAR2 DEFAULT NULL,
                              partname IN         VARCHAR2 DEFAULT NULL,
                              CASCADE  IN         BOOLEAN DEFAULT true )
IS
        exist_insufficient EXCEPTION;
        exist_invalid      EXCEPTION;
        pragma exception_init(exist_insufficient,-20000);
        pragma exception_init(exist_invalid,-20001);
        l_message VARCHAR2(1000);
BEGIN
        FND_STATS.RESTORE_TABLE_STATS(ownname,tabname,statid,partname,CASCADE);
EXCEPTION
WHEN exist_insufficient THEN
        errbuf    := sqlerrm;
        retcode   := '2';
        l_message := errbuf;
        FND_FILE.put_line(FND_FILE.log,l_message);
        raise;
WHEN exist_invalid THEN
        errbuf := 'ORA-20001: Invalid or inconsistent values in the user stattab ='
        ||fnd_stattab
        ||' statid='
        ||statid ;
        retcode   := '2';
        l_message := errbuf;
        FND_FILE.put_line(FND_FILE.log,l_message);
        raise;
WHEN OTHERS THEN
        errbuf    := sqlerrm ;
        retcode   := '2';
        l_message := errbuf;
        FND_FILE.put_line(FND_FILE.log,l_message);
        raise;
END;
/* RESTORE_TABLE_STATS */
/************************************************************************/
/* Procedure: RESTORE_TABLE_STATS                                       */
/* Desciption: Retores table statistics from fnd_stattab table. If      */
/* cascase is true, restores column as well as index stats too. This    */
/* procedure is called from the concurrent program manager version of   */
/* RESTORE_TABLE_STATS as well as from sqlplus                          */
/************************************************************************/
PROCEDURE RESTORE_TABLE_STATS(ownname  IN VARCHAR2,
                              tabname  IN VARCHAR2,
                              statid   IN VARCHAR2 DEFAULT NULL,
                              partname IN VARCHAR2 DEFAULT NULL,
                              CASCADE  IN BOOLEAN DEFAULT true )
IS
BEGIN
        DBMS_STATS.IMPORT_TABLE_STATS(ownname,tabname,partname, fnd_stattab,statid,CASCADE,fnd_statown);
END;
/* RESTORE_TABLE_STATS */
/************************************************************************/
/* Procedure: RESTORE_INDEX_STATS                                       */
/* Desciption: Retores index statistics from fnd_stattab table for a    */
/* particular table.                                                    */
/************************************************************************/
PROCEDURE RESTORE_INDEX_STATS(ownname  IN VARCHAR2,
                              indname  IN VARCHAR2,
                              statid   IN VARCHAR2 DEFAULT NULL,
                              partname IN VARCHAR2 DEFAULT NULL)
IS
BEGIN
        DBMS_STATS.IMPORT_INDEX_STATS(ownname,indname,partname,fnd_stattab, statid,fnd_statown) ;
END;
/* RESTORE_INDEX_STATS */
/************************************************************************/
/* Procedure: RESTORE_COLUMN_STATS                                      */
/* Desciption: Retores column statistics from fnd_stattab table for a   */
/* particular column.                                                   */
/************************************************************************/
PROCEDURE RESTORE_COLUMN_STATS(ownname  IN VARCHAR2,
                               tabname  IN VARCHAR2,
                               colname  IN VARCHAR2,
                               partname IN VARCHAR2 DEFAULT NULL,
                               statid   IN VARCHAR2 DEFAULT NULL)
IS
BEGIN
        DBMS_STATS.IMPORT_COLUMN_STATS(ownname, tabname, colname, partname, fnd_stattab, statid, fnd_statown) ;
END;
/* RESTORE_COLUMN_STATS() */
/************************************************************************/
/* Procedure: RESTORE_COLUMN_STATS                                      */
/* Desciption: Retores column statistics from fnd_stattab table for all */
/* columns seeded in the fnd_histogram_cols table.                      */
/************************************************************************/
PROCEDURE RESTORE_COLUMN_STATS(statid IN VARCHAR2 DEFAULT NULL)
IS
        /* cursor col_cursor is
        select upper(b.oracle_username) ownname ,
        a.table_name tabname,
        a.column_name colname,
        a.partition partname
        from   FND_HISTOGRAM_COLS a,
        FND_ORACLE_USERID b,
        FND_PRODUCT_INSTALLATIONS c
        where  a.application_id = c.application_id
        and    c.oracle_id  = b.oracle_id
        order by ownname, tabname, column_name;
        */
        -- New cursor to support MVs
        CURSOR col_cursor IS
                SELECT   NVL(upper(b.oracle_username), a.owner) ownname ,
                         a.table_name tabname                           ,
                         a.column_name colname                          ,
                         a.partition partname
                FROM     FND_HISTOGRAM_COLS a,
                         FND_ORACLE_USERID b ,
                         FND_PRODUCT_INSTALLATIONS c
                WHERE    a.application_id = c.application_id (+)
                     AND c.oracle_id      = b.oracle_id (+)
                ORDER BY ownname,
                         tabname,
                         colname;

BEGIN
        FOR c_rec IN col_cursor
        LOOP
                DBMS_STATS.IMPORT_COLUMN_STATS(c_rec.ownname,c_rec.tabname, c_rec.colname,c_rec.partname, fnd_stattab,statid,fnd_statown);
        END LOOP;
END;
/* RESTORE_COLUMN_STATS */
/************************************************************************/
/* Procedure: DLOG                                                      */
/* Desciption: Writes out log messages to the conc program log.         */
/************************************************************************/
PROCEDURE dlog(p_str IN VARCHAR2)
IS
BEGIN
        dbms_output.put_line(SUBSTR(p_str,1,250));
        FND_FILE.put_line(FND_FILE.log,p_str);
END dlog;
/************************************************************************/
/* Procedure: GATHER_TABLE_STATS_PVT                                    */
/* Desciption: Private package that now calls dbms_stats dynamically    */
/*             depending upon the version of the database. For 8i,      */
/*             dbms_stats is called as before, for higher versions, it  */
/*             is called with the no_invalidate flag.                   */
/************************************************************************/
PROCEDURE GATHER_TABLE_STATS_PVT(ownname          IN VARCHAR2,
                                 tabname          IN VARCHAR2,
                                 estimate_percent IN NUMBER DEFAULT NULL,
                                 degree           IN NUMBER DEFAULT NULL,
                                 method_opt          VARCHAR2 DEFAULT 'FOR ALL COLUMNS SIZE 1',
                                 partname    IN         VARCHAR2 DEFAULT NULL,
                                 CASCADE     IN         BOOLEAN DEFAULT true,
                                 granularity IN         VARCHAR2 DEFAULT 'DEFAULT',
                                 stattab                VARCHAR2 DEFAULT NULL,
                                 statown                VARCHAR2 DEFAULT NULL,
                                 invalidate IN          VARCHAR2 DEFAULT 'Y' )
IS
        l_tmp_str     VARCHAR2(600);
        no_invalidate VARCHAR2(1);
BEGIN
        IF ((upper(invalidate) ='Y') OR
                (
                        upper(invalidate) ='YES'
                )
                ) THEN
                no_invalidate:='N';
        ELSE
                no_invalidate:='Y';
        END IF;
        -- If db version is < 9iR2, OR it is 92 and no_inv is false OR it is > 92
        -- and no_inv is true,   calls dbms_stats statically, else ...
        IF ( (db_versn <= 92) OR
                (
                        db_versn=92 AND no_invalidate='N'
                )
                OR
                (
                        db_versn>=100 AND no_invalidate='Y'
                )
                ) THEN
		-- changes done for bug 11835452
                DBMS_STATS.GATHER_TABLE_STATS( ownname => ownname ,
		tabname => tabname , estimate_percent => nvl(estimate_percent,def_estimate_pcnt) , degree => degree ,
		method_opt => method_opt , block_sample => FALSE , partname => partname ,
		CASCADE => CASCADE , granularity => granularity , stattab => stattab , statown => statown );
        ELSE
                l_tmp_str:= 'BEGIN DBMS_STATS.GATHER_TABLE_STATS( ownname => :ownname ,'
                || ' tabname => :tabname ,'
                || ' estimate_percent => :estimate_percent ,'
                || ' degree => :degree ,'
                || ' method_opt => :method_opt ,'
                || ' block_sample => FALSE ,'
                || ' partname => :partname ,'
                || ' granularity => :granularity ,'
                || ' stattab => :stattab ,'
                || ' statown => :statown, ';
                IF (no_invalidate ='Y') THEN
                        l_tmp_str:=l_tmp_str
                        || '               no_invalidate => TRUE ,';
                ELSE
                        l_tmp_str:=l_tmp_str
                        || '               no_invalidate => FALSE ,';
                END IF;
                IF (CASCADE) THEN
                        l_tmp_str:=l_tmp_str
                        || '               cascade => TRUE ';
                ELSE
                        l_tmp_str:=l_tmp_str
                        || '               cascade => FALSE ';
                END IF;
                l_tmp_str:=l_tmp_str
                || '              ); end;';
                EXECUTE IMMEDIATE l_tmp_str USING ownname , tabname , estimate_percent , degree , method_opt , partname , granularity , stattab , statown;
        END IF;
EXCEPTION
WHEN OTHERS THEN
        raise;
END;
/* GATHER_TABLE_STATS_PVT */
/************************************************************************/
/* Procedure: GATHER_INDEX_STATS_PVT                                    */
/* Desciption: Private package that now calls dbms_stats dynamically    */
/*             depending upon the version of the database. For 8i,      */
/*             dbms_stats is called as before, for higher versions, it  */
/*             is called with the invalidate flag.                   */
/************************************************************************/
PROCEDURE GATHER_INDEX_STATS_PVT(ownname          IN VARCHAR2,
                                 indname          IN VARCHAR2,
                                 estimate_percent IN NUMBER DEFAULT NULL,
                                 degree           IN NUMBER DEFAULT NULL,
                                 partname         IN VARCHAR2 DEFAULT NULL,
                                 invalidate       IN VARCHAR2 DEFAULT 'Y' )
IS
        l_tmp_str     VARCHAR2(600);
        no_invalidate VARCHAR2(1);
BEGIN
        IF ((upper(invalidate) ='Y') OR
                (
                        upper(invalidate) ='YES'
                )
                ) THEN
                no_invalidate:='N';
        ELSE
                no_invalidate:='Y';
        END IF;
        -- If db version is < 9iR2,  calls dbms_stats statically, else ...
        IF (db_versn <= 92) THEN
		-- changes done for bug 11835452
                DBMS_STATS.GATHER_INDEX_STATS( ownname => ownname , indname => indname , estimate_percent => nvl(estimate_percent,def_estimate_pcnt) , partname => partname );
        ELSE
                l_tmp_str:= 'BEGIN DBMS_STATS.GATHER_INDEX_STATS( ownname => :ownname ,'
                || '               indname => :indname ,'
                || '               estimate_percent => :estimate_percent ,'
                || '               degree => :degree ,'
                || '               partname => :partname ,';
                IF (no_invalidate ='Y') THEN
                        l_tmp_str:=l_tmp_str
                        || '               no_invalidate => TRUE ';
                ELSE
                        l_tmp_str:=l_tmp_str
                        || '               no_invalidate => FALSE ';
                END IF;
                l_tmp_str:=l_tmp_str
                ||'              ); END;';
                EXECUTE IMMEDIATE l_tmp_str USING ownname , indname , estimate_percent , degree , partname ;
        END IF;
END;
/* GATHER_INDEX_STATS_PVT */
/************************************************************************/
/* Procedure: GATHER_SCHEMA_STATS                                       */
/* Desciption: Gather schema statistics. This is the concurrent program */
/* manager version.                                                     */
/************************************************************************/
PROCEDURE GATHER_SCHEMA_STATS(errbuf OUT NOCOPY  VARCHAR2,
                              retcode OUT NOCOPY VARCHAR2,
                              schemaname       IN      VARCHAR2,
                              estimate_percent IN      NUMBER,
                              degree           IN      NUMBER ,
                              internal_flag    IN      VARCHAR2,
                              request_id       IN      NUMBER,
                              hmode            IN      VARCHAR2 DEFAULT 'LASTRUN',
                              OPTIONS          IN      VARCHAR2 DEFAULT 'GATHER',
                              modpercent       IN      NUMBER DEFAULT 10,
                              invalidate       IN      VARCHAR2 DEFAULT 'Y' )
IS
        exist_insufficient EXCEPTION;
        bad_input          EXCEPTION;
        pragma exception_init(exist_insufficient,-20000);
        pragma exception_init(bad_input,-20001);
        l_message     VARCHAR2(1000);
        Error_counter NUMBER := 0;
        --Errors Error_Out; -- commented for bug error handling
        -- num_request_id number(15);
        conc_request_id NUMBER(15);
        degree_parallel NUMBER(4);
BEGIN
        -- Set the package body variable.
        stathist := hmode;
        -- check first if degree is null
        IF degree IS NULL THEN
                degree_parallel:=def_degree;
        ELSE
                degree_parallel := degree;
        END IF;
        l_message := 'In GATHER_SCHEMA_STATS , schema_name= '
        || schemaname
        || ' percent= '
        || TO_CHAR(estimate_percent)
        || ' degree = '
        || TO_CHAR(degree_parallel)
        || ' internal_flag= '
        || internal_flag ;
        FND_FILE.put_line(FND_FILE.log,l_message);
        BEGIN
                FND_STATS.GATHER_SCHEMA_STATS(schemaname, estimate_percent, degree_parallel, internal_flag , request_id,stathist, OPTIONS,modpercent,invalidate); -- removed errors parameter for error handling
        EXCEPTION
        WHEN exist_insufficient THEN
                errbuf    := sqlerrm ;
                retcode   := '2';
                l_message := errbuf;
                FND_FILE.put_line(FND_FILE.log,l_message);
                raise;
        WHEN bad_input THEN
                errbuf    := sqlerrm ;
                retcode   := '2';
                l_message := errbuf;
                FND_FILE.put_line(FND_FILE.log,l_message);
                raise;
        WHEN OTHERS THEN
                errbuf    := sqlerrm ;
                retcode   := '2';
                l_message := errbuf;
                FND_FILE.put_line(FND_FILE.log,l_message);
                raise;
        END;
        FOR i IN 0..MAX_ERRORS_PRINTED
        LOOP
                EXIT
        WHEN g_Errors(i) IS NULL;
                Error_counter:=i+1;
                FND_FILE.put_line(FND_FILE.log,'Error #'
                ||Error_counter
                || ': '
                ||g_Errors(i));
                -- added to send back status to concurrent program manager bug 2625022
                errbuf  := sqlerrm ;
                retcode := '2';
        END LOOP;
END;
/* GATHER_SCHEMA_STATS */
/************************************************************************/
/* Procedure: GATHER_SCHEMA_STATISTICS                                  */
/* Desciption: Gather schema statistics. This is the sqlplus version. It*/
/* does not have any o/p parameters                                     */
/************************************************************************/
PROCEDURE GATHER_SCHEMA_STATISTICS(schemaname       IN VARCHAR2,
                                   estimate_percent IN NUMBER ,
                                   degree           IN NUMBER ,
                                   internal_flag    IN VARCHAR2,
                                   request_id       IN NUMBER,
                                   hmode            IN VARCHAR2 DEFAULT 'LASTRUN',
                                   OPTIONS          IN VARCHAR2 DEFAULT 'GATHER',
                                   modpercent       IN NUMBER DEFAULT 10,
                                   invalidate       IN VARCHAR2 DEFAULT 'Y' )
IS
        Errors Error_Out;
BEGIN
        call_from_sqlplus:=true;
        FND_STATS.GATHER_SCHEMA_STATS_SQLPLUS(schemaname, estimate_percent, degree,internal_flag, Errors, request_id,hmode,OPTIONS ,modpercent,invalidate);
END;
/* end of GATHER_SCHEMA_STATISTICS */
/************************************************************************/
/* Procedure: GATHER_SCHEMA_STATS_SQLPLUS                               */
/* Desciption: Gather schema statistics. This is called by concurrent   */
/* manager version of GATHER_SCHEMA_STATS.                              */
/* Notes: internal_flag='INTERNAL' will call dbms_utility.analyze_schema*/
/* insead of dbms_stats.gather_schema_stats                             */
/* internal_flag='NOBACKUP'  will bypass dbms_stats.export_schema_stats */
/************************************************************************/
PROCEDURE GATHER_SCHEMA_STATS_SQLPLUS(schemaname       IN VARCHAR2,
                                      estimate_percent IN NUMBER ,
                                      degree           IN NUMBER ,
                                      internal_flag    IN VARCHAR2 ,
                                      Errors OUT NOCOPY Error_Out,
                                      request_id IN NUMBER DEFAULT NULL,
                                      hmode      IN VARCHAR2 DEFAULT 'LASTRUN',
                                      OPTIONS    IN VARCHAR2 DEFAULT 'GATHER',
                                      modpercent IN NUMBER DEFAULT 10,
                                      invalidate IN VARCHAR2 DEFAULT 'Y' )
IS
TYPE name_tab
IS
        TABLE OF dba_tables.table_name%TYPE;
TYPE partition_tab
IS
        TABLE OF sys.dba_tab_modifications.partition_name%TYPE;
TYPE partition_type_tab
IS
        TABLE OF dba_tables.partitioned%TYPE;
        part_flag partition_type_tab;
        names name_tab;
        pnames partition_tab;
        num_tables         NUMBER := 0;
        l_message          VARCHAR2(1000) ;
        granularity        VARCHAR2(12);
        exist_insufficient EXCEPTION;
        pragma exception_init(exist_insufficient,-20002);
        err_cnt BINARY_INTEGER := 0;
        degree_parallel NUMBER(4);
        str_request_id  VARCHAR(30);
        -- Cursor to get list of tables and indexes with no stats
        CURSOR empty_cur(schemaname VARCHAR2)
        IS
                SELECT   type ,
                         owner,
                         name
                FROM
                         ( SELECT 'TABLE' type,
                                 owner        ,
                                 table_name name
                         FROM    dba_tables dt
                         WHERE   owner=upper(schemaname)
                             AND
                                 (
                                         iot_type <> 'IOT_OVERFLOW'
                                      OR iot_type IS NULL
                                 )
                             AND TEMPORARY <> 'Y'
                             AND last_analyzed IS NULL
			     AND table_name not like 'DR$%' -- added for Bug 8452962
			     AND table_name not like 'DR#%' -- added for Bug 8452962
			      -- leave alone if excluded table
                             AND NOT EXISTS
                                 (SELECT NULL
                                 FROM    fnd_exclude_table_stats fets,
                                         fnd_oracle_userid fou       ,
                                         fnd_product_installations fpi
                                 WHERE   fou.oracle_username=upper(schemaname)
                                     AND fou.oracle_id      =fpi.oracle_id
                                     AND fpi.application_id = fets.application_id
                                     AND dt.table_name      = fets.table_name
                                 )
				  AND NOT EXISTS
                        (SELECT NULL
                        FROM    dba_external_tables de
                        WHERE   de.table_name=dt.table_name
                            AND de.owner     =dt.owner
                        ) -- added this to avoid externale tables being selected
                         UNION ALL

                         SELECT 'INDEX' type,
                                owner       ,
                                index_name name
                         FROM   dba_indexes
                         WHERE
                                (
                                       table_owner=upper(schemaname)
                                    OR owner      =upper(schemaname)
                                )
                            AND index_type <> 'LOB'
                            AND index_type <>'DOMAIN'
                            AND TEMPORARY  <> 'Y'
			    AND generated <> 'Y' -- change done by saleem for bug 9542112
                            AND last_analyzed IS NULL
                         )
         ORDER BY type ,
                  owner,
                  name ;
         CURSOR nomon_tab(schemaname VARCHAR2)
         IS
                 SELECT owner,
                        table_name
                 FROM   dba_tables dt
                 WHERE  owner=upper(schemaname)
                    AND
                        (
                               iot_type <> 'IOT_OVERFLOW'
                            OR iot_type IS NULL
                        )
                    AND TEMPORARY <> 'Y'
                    AND monitoring ='NO'
		    AND TABLE_NAME NOT LIKE 'DR$%' -- added for Bug 8452962
		    AND table_name not like 'DR#%' -- added for Bug 8452962
                    AND NOT EXISTS
                        (SELECT NULL
                        FROM    dba_external_tables de
                        WHERE   de.table_name=dt.table_name
                            AND de.owner     =dt.owner
                        );-- added this to avoid externale tables being selected
	$IF DBMS_DB_VERSION.VER_LE_9_2 $THEN
	 $ELSE
         CURSOR nomon_tab_lt(schemaname VARCHAR2) -- this is for locking stats on table
         IS
                 SELECT owner,
                        table_name
                 FROM   dba_tables dt
                 WHERE  owner=upper(schemaname)
                    AND
                        (
                               iot_type <> 'IOT_OVERFLOW'
                            OR iot_type IS NULL
                        )
                    AND TEMPORARY <> 'Y'
                    AND monitoring ='NO'
		    AND TABLE_NAME NOT LIKE 'DR$%' -- added for Bug 8452962
		    AND table_name not like 'DR#%' -- added for Bug 8452962
                    AND NOT EXISTS
                        (SELECT NULL
                        FROM    dba_external_tables de
                        WHERE   de.table_name=dt.table_name
                            AND de.owner     =dt.owner
                        )-- added this to avoid externale tables being selected
            AND NOT EXISTS
                ( SELECT NULL
                FROM    dba_tab_statistics dts
                WHERE   dts.stattype_locked IS NOT NULL
                    AND dts.table_name=dt.table_name
                    AND dts.owner     =dt.owner
                );  -- added by saleem to avoid locked objects
		CURSOR empty_cur_ten(schemaname VARCHAR2)
		-- new cursro for excluding tables with empty stats and locked stats
		-- will get execte only for 10g and above
        IS
                SELECT   type ,
                         owner,
                         name
                FROM
                         ( SELECT 'TABLE' type,
                                 owner        ,
                                 table_name name
                         FROM    dba_tables dt
                         WHERE   owner=upper(schemaname)
                             AND
                                 (
                                         iot_type <> 'IOT_OVERFLOW'
                                      OR iot_type IS NULL
                                 )
                             AND TEMPORARY <> 'Y'
                             AND last_analyzed IS NULL
			     AND table_name not like 'DR$%' -- added for Bug 8452962
			     AND table_name not like 'DR#%' -- added for Bug 8452962
			      -- leave alone if excluded table
                             AND NOT EXISTS
                                 (SELECT NULL
                                 FROM    fnd_exclude_table_stats fets,
                                         fnd_oracle_userid fou       ,
                                         fnd_product_installations fpi
                                 WHERE   fou.oracle_username=upper(schemaname)
                                     AND fou.oracle_id      =fpi.oracle_id
                                     AND fpi.application_id = fets.application_id
                                     AND dt.table_name      = fets.table_name
                                 )
				  AND NOT EXISTS
                        (SELECT NULL
                        FROM    dba_external_tables de
                        WHERE   de.table_name=dt.table_name
                            AND de.owner     =dt.owner
                        ) -- added this to avoid externale tables being selected
			AND NOT EXISTS
			( SELECT NULL
                FROM    dba_tab_statistics dts
                WHERE   dts.stattype_locked IS NOT NULL
                    AND dts.table_name=dt.table_name
                    AND dts.owner     =dt.owner
                )
                         UNION ALL

                         SELECT 'INDEX' type,
                                owner       ,
                                index_name name
                         FROM   dba_indexes
                         WHERE
                                (
                                       table_owner=upper(schemaname)
                                    OR owner      =upper(schemaname)
                                )
                            AND index_type <> 'LOB'
                            AND index_type <>'DOMAIN'
                            AND TEMPORARY  <> 'Y'
			    AND generated <> 'Y' -- change done by saleem for bug 9542112
                            AND last_analyzed IS NULL
                         )
         ORDER BY type ,
                  owner,
                  name ;

             $END
	     $IF DBMS_DB_VERSION.VER_LE_9_2 $THEN
	   $ELSE
         CURSOR lock_stats_tab(schemaname VARCHAR2)
         IS -- cursor added by saleem to display the warning message for tables with  locked stats
                 SELECT table_name
                 FROM   dba_tab_statistics
                 WHERE  stattype_locked IS NOT NULL
                    AND owner=upper(schemaname);  -- added to display the warning for locked stats
		    $END
  BEGIN
          -- Set the package body variable.
          stathist := hmode;
          -- if request id (restart case) is provided, then this is the cur_request_id
          -- valid for both conc program and sql plus case.
          IF request_id IS NOT NULL THEN
                  cur_request_id := request_id;
          END IF;
          -- get degree of parallelism
          IF degree IS NULL THEN
                  degree_parallel:=def_degree;
          ELSE
                  degree_parallel := degree;
          END IF;
          -- Initialize the TABLE Errors
          Errors(0)   := NULL;
          granularity := FND_STATS.ALL_GRANULARITY; -- granularity will be ALL for all tables
          err_cnt     := 0;
          -- If a specific schema is given
          IF (upper(schemaname)         <> 'SYS') THEN
                  IF (upper(schemaname) <> 'ALL') THEN
                          -- Insert/update the fnd_stats_hist table
                          IF(upper(stathist)<> 'NONE') THEN
                                  BEGIN
                                          --            if(cur_request_id is null) then
                                          --             cur_request_id := GET_REQUEST_ID(request_id);
                                          --            end if;
					  -- changes done for bug 11835452
				FND_STATS.UPDATE_HIST(schemaname=>schemaname, objectname=>schemaname, objecttype=>'SCHEMA', partname=>NULL, columntablename=>NULL, degree=>degree_parallel,
				upd_ins_flag=>'S', percent=>NVL(estimate_percent,def_estimate_pcnt));
                                  END;
                          END IF; --if(upper(stathist)<> 'NONE')
                          -- backup the existing schema stats
                          IF ( (upper(internal_flag) = 'BACKUP') ) THEN
                                  FND_STATS.BACKUP_SCHEMA_STATS( schemaname );
                          END IF;
			  $IF DBMS_DB_VERSION.VER_LE_9_2 $THEN --checkingf or dbversion for lock stats
			   --If db_versn < 100 THEN
			  IF(upper(OPTIONS)='GATHER') THEN
			        SELECT   table_name ,
                                           partitioned BULK COLLECT
                                  INTO     names,
                                           part_flag
                                  FROM     dba_tables dt
                                  WHERE    owner = upper(schemaname)
                                       AND
                                           (
                                                    iot_type <> 'IOT_OVERFLOW'
                                                 OR iot_type IS NULL
                                           )
                                       AND TEMPORARY <> 'Y' -- Bypass if temporary tables for bug#1108002
				       AND TABLE_NAME NOT LIKE 'DR$%' -- added for Bug 8452962
				       AND table_name not like 'DR#%' -- added for Bug 8452962
                                       AND NOT EXISTS
                                           (SELECT NULL
                                           FROM    fnd_stats_hist fsh
                                           WHERE   dt.owner        =fsh.schema_name
                                               AND fsh.REQUEST_ID  = cur_request_id
                                               AND fsh.object_type ='CASCADE'
                                               AND fsh.history_mode=stathist
                                               AND dt.table_name   = fsh.object_name
                                               AND LAST_GATHER_END_TIME IS NOT NULL
                                           )
                                       AND NOT EXISTS
                                           (SELECT NULL
                                           FROM    fnd_exclude_table_stats fets,
                                                   fnd_oracle_userid fou       ,
                                                   fnd_product_installations fpi
                                           WHERE   fou.oracle_username=upper(schemaname)
                                               AND fou.oracle_id      =fpi.oracle_id
                                               AND fpi.application_id = fets.application_id
                                               AND dt.table_name      = fets.table_name
                                           ) -- added by saleem for bug 7479909
					     AND NOT EXISTS
                        (SELECT NULL
                        FROM    dba_external_tables de
                        WHERE   de.table_name=dt.table_name
                            AND de.owner     =dt.owner
                        ) -- added this to avoid externale tables being selected
                                       ORDER BY table_name;
                                  num_tables := SQL%ROWCOUNT;
                                  FOR i      IN 1..num_tables
                                  LOOP
                                          IF ( part_flag(i)    = 'YES' ) THEN
                                                  granularity := FND_STATS.ALL_GRANULARITY ;
                                          ELSE
                                                  granularity := FND_STATS.STD_GRANULARITY;
                                          END IF;
                                          BEGIN
						-- changes done for bug 11835452
                                                FND_STATS.GATHER_TABLE_STATS(ownname => schemaname,
						tabname => names(i), percent => NVL(estimate_percent,def_estimate_pcnt),
						degree => degree_parallel, partname=>NULL, CASCADE => TRUE,
						granularity => granularity, hmode => stathist,
						invalidate=> invalidate );
                                          EXCEPTION
                                          WHEN OTHERS THEN
                                                  Errors(err_cnt) := 'ERROR: While GATHER_TABLE_STATS:
object_name='
                                                  ||schemaname
                                                  ||'.'
                                                  ||names(i)
                                                  ||'***'
                                                  ||SQLERRM
                                                  ||'***' ;
                                                  Errors(err_cnt+1) := NULL;
                                                  err_cnt           := err_cnt+1;
                                          END;
                                  END LOOP;
                                  /* end of individual tables */
				elsif ( (upper(OPTIONS)='GATHER AUTO') OR
                                  (
                                          upper(OPTIONS)='LIST AUTO'
                                  )
                                  ) THEN
                                  -- if db_versn > 81 then call flush, else use whatever
                                  -- data is available in dtm
                                  IF db_versn > 81 THEN
                                          IF(fm_first_flag) THEN
                                                  EXECUTE IMMEDIATE 'BEGIN DBMS_STATS.FLUSH_DATABASE_MONITORING_INFO; END;' ;
                                                  fm_first_flag := false;
                                          END IF;
                                  END IF;
                                  -- gather stats for stale tables/partitions. Potentially, there
                                  -- could be some redundent stats gathering, if for eg the table
                                  -- and one of its partitions, both are statle. gather_table_stats
                                  -- would get called twice, once for the table ( which would gather
                                  -- stats for the partitions too, and the partition by itself. The
                                  -- probability of this happening is small, and even if that happens
                                  -- on a rare occasion, the overhead should not be that high, so
                                  -- leaving it as it is for the moment. This can be revisited if
                                  -- tests and experience show that that is not the case.
                                  SELECT   iv.table_name,
                                           iv.partition_name -- ,subpartition_name
                                           BULK COLLECT
                                  INTO     names,
                                           pnames -- ,spnames
                                  FROM
                                           ( SELECT dtm.table_name,
                                                   dtm.partition_name
                                           FROM    sys.dba_tab_modifications dtm
                                           WHERE   dtm.table_owner = upper(schemaname)
                                               AND dtm.partition_name IS NULL
					       AND dtm.TABLE_NAME NOT LIKE 'DR$%' -- added for Bug 8452962
				       AND dtm.table_name not like 'DR#%' -- added for Bug 8452962
                                               AND EXISTS
                                                   ( SELECT NULL
                                                   FROM    dba_tables dt
                                                   WHERE   dt.owner     =dtm.table_owner
                                                       AND dt.table_name=dtm.table_name
                                                       AND
                                                           (
                                                                   NVL(dtm.inserts,0)+NVL(dtm.updates,0)+NVL(dtm.deletes,0)
                                                           )
                                                           > (modpercent*NVL(dt.num_rows,0))/100
                                                   )
                                           UNION ALL

                                           SELECT dtm.table_name,
                                                  dtm.partition_name
                                           FROM   sys.dba_tab_modifications dtm
                                           WHERE  dtm.table_owner = upper(schemaname)
                                              AND dtm.partition_name IS NOT NULL
					      AND dtm.TABLE_NAME NOT LIKE 'DR$%' -- added for Bug 8452962
				         AND dtm.table_name not like 'DR#%' -- added for Bug 8452962
                                        AND EXISTS
                                                  ( SELECT NULL
                                                  FROM    dba_tab_partitions dtp
                                                  WHERE   dtp.table_owner   =dtm.table_owner
                                                      AND dtp.table_name    =dtm.table_name
                                                      AND dtp.partition_name=dtm.partition_name
                                                      AND
                                                          (
                                                                  NVL(dtm.inserts,0)+NVL(dtm.updates,0)+NVL(dtm.deletes,0)
                                                          )
                                                          > (modpercent*NVL(dtp.num_rows,0))/100
                                                  )
					     ) iv
                                  ORDER BY table_name;

                                  num_tables := SQL%ROWCOUNT;
                                  FOR i      IN 1..num_tables
                                  LOOP
                                          BEGIN
                                                  IF (upper(OPTIONS)='GATHER AUTO') THEN
						     -- changes done for bug 11835452
                                                     FND_STATS.GATHER_TABLE_STATS(ownname => schemaname,
						tabname => names(i), percent => NVL(estimate_percent,def_estimate_pcnt),
						 degree => degree_parallel, partname=>pnames(i),
						CASCADE => TRUE, granularity => granularity,
						hmode => stathist, invalidate=> invalidate );
                                                  ELSE
                                                          dlog('Statistics on '
                                                          ||schemaname
                                                          ||'.'
                                                          ||names(i)
                                                          ||'Partition '
                                                          ||NVL(pnames(i),'n/a')
                                                          ||' are Stale');
                                                  END IF;
                                          EXCEPTION
                                          WHEN OTHERS THEN
                                                  Errors(err_cnt) := 'ERROR: While GATHER_TABLE_STATS:
object_name='
                                                  ||schemaname
                                                  ||'.'
                                                  ||names(i)
                                                  ||'***'
                                                  ||SQLERRM
                                                  ||'***' ;
                                                  Errors(err_cnt+1) := NULL;
                                                  err_cnt           := err_cnt+1;
                                          END;
                                  END LOOP;
                                  /* end of individual tables */
                                  -- GATHER AUTO includes GATHER EMPTY, so gather stats
                                  -- on any unalalyzed tables and/or indexes.
                                  FOR c_rec IN empty_cur(upper(schemaname))
                                  LOOP
                                          IF c_rec.type             = 'TABLE' THEN
                                                  IF (upper(OPTIONS)='GATHER AUTO') THEN
						      -- changes done for bug 11835452
	                                              FND_STATS.GATHER_TABLE_STATS(ownname => c_rec.owner, tabname => c_rec.name,
percent => NVL(estimate_percent,def_estimate_pcnt),
degree => degree_parallel, partname=>NULL, CASCADE => TRUE, granularity => granularity,
hmode => stathist, invalidate=> invalidate );
                                                  ELSE
                                                          dlog('Table '
                                                          ||c_rec.owner
                                                          ||'.'
                                                          ||c_rec.name
                                                          ||' is missing statistics.');
                                                  END IF;
                                          elsif c_rec.type          ='INDEX' THEN
                                                  IF (upper(OPTIONS)='GATHER AUTO') THEN
							  -- changes done for bug 11835452
                                                          fnd_stats.gather_index_stats(ownname=>c_rec.owner, indname=>c_rec.name, percent=>NVL(estimate_percent,def_estimate_pcnt), invalidate=>invalidate);
                                                  ELSE
                                                          dlog('Index '
                                                          ||c_rec.owner
                                                          ||'.'
                                                          ||c_rec.name
                                                          ||' is missing statistics! ');
                                                  END IF;
                                          END IF;
                                  END LOOP;
                                  -- Check if there are any tables in the schema which does not have
                                  -- monitoring enabled. If yes, gather stats for them using 10% and
                                  -- enable monitoring for such tables so that we have data for them
                                  -- in dba_tab_modifications for next time.
                                  FOR c_rec IN nomon_tab(upper(schemaname))
                                  LOOP
                                          IF (upper(OPTIONS)='GATHER AUTO') THEN
						  -- changes done for bug 11835452
                                                  FND_STATS.GATHER_TABLE_STATS(ownname => c_rec.owner,
tabname => c_rec.table_name, percent => NVL(estimate_percent,def_estimate_pcnt), degree => degree_parallel,
partname=>NULL, CASCADE => TRUE, granularity => granularity, hmode => stathist, invalidate=> invalidate );
                                                  EXECUTE IMMEDIATE 'alter table '
                                                  ||c_rec.owner
                                                  ||'.'
                                                  ||c_rec.table_name
                                                  ||' monitoring';
                                                  dlog('Monitoring has now been enabled for Table '
                                                  ||c_rec.owner
                                                  ||'.'
                                                  ||c_rec.table_name
                                                  ||'. Stats were gathered.' );
                                          ELSE
                                                  dlog('Monitoring is not enabled for Table '
                                                  ||c_rec.owner
                                                  ||'.'
                                                  ||c_rec.table_name );
                                          END IF;
                                  END LOOP; -- nomon_tab
                          elsif ( (upper(OPTIONS)='GATHER EMPTY') OR
                                  (
                                          upper(OPTIONS)='LIST EMPTY'
                                  )
                                  ) THEN
                                  FOR c_rec IN empty_cur(upper(schemaname))
                                  LOOP
                                          IF c_rec.type             = 'TABLE' THEN
                                                  IF (upper(OPTIONS)='GATHER EMPTY') THEN
							  -- changes done for bug 11835452
                                                          FND_STATS.GATHER_TABLE_STATS(ownname => c_rec.owner, tabname => c_rec.name,
percent => NVL(estimate_percent,def_estimate_pcnt), degree => degree_parallel, partname=>NULL, CASCADE => TRUE,
granularity => granularity, hmode => stathist, invalidate=> invalidate );
                                                  ELSE
                                                          dlog('Table '
                                                          ||c_rec.owner
                                                          ||'.'
                                                          ||c_rec.name
                                                          ||' is missing statistics! ');
                                                  END IF;
                                          elsif c_rec.type          ='INDEX' THEN
                                                  IF (upper(OPTIONS)='GATHER EMPTY') THEN
							  -- changes done for bug 11835452
                                                          fnd_stats.gather_index_stats(ownname=>c_rec.owner, indname=>c_rec.name, percent=>NVL(estimate_percent,def_estimate_pcnt), invalidate=>invalidate);
                                                  ELSE
                                                          dlog('Statistics for Index '
                                                          ||c_rec.owner
                                                          ||'.'
                                                          ||c_rec.name
                                                          ||' are Empty');
                                                  END IF;
                                          END IF;
                                  END LOOP;
                               END IF;
			  /* end of if upper(options)=  */
                         $ELSE -- for db version 10g and above
			   --ELSE  -- for db version 10g and above
			    IF(upper(OPTIONS)='GATHER') THEN
			        SELECT   table_name ,
                                           partitioned BULK COLLECT
                                  INTO     names,
                                           part_flag
                                  FROM     dba_tables dt
                                  WHERE    owner = upper(schemaname)
                                       AND
                                           (
                                                    iot_type <> 'IOT_OVERFLOW'
                                                 OR iot_type IS NULL
                                           )
                                       AND TEMPORARY <> 'Y' -- Bypass if temporary tables for bug#1108002
				       AND TABLE_NAME NOT LIKE 'DR$%' -- added for Bug 8452962
				       AND table_name not like 'DR#%' -- added for Bug 8452962
                                       AND NOT EXISTS
                                           (SELECT NULL
                                           FROM    fnd_stats_hist fsh
                                           WHERE   dt.owner        =fsh.schema_name
                                               AND fsh.REQUEST_ID  = cur_request_id
                                               AND fsh.object_type ='CASCADE'
                                               AND fsh.history_mode=stathist
                                               AND dt.table_name   = fsh.object_name
                                               AND LAST_GATHER_END_TIME IS NOT NULL
                                           )
                                       AND NOT EXISTS
                                           (SELECT NULL
                                           FROM    fnd_exclude_table_stats fets,
                                                   fnd_oracle_userid fou       ,
                                                   fnd_product_installations fpi
                                           WHERE   fou.oracle_username=upper(schemaname)
                                               AND fou.oracle_id      =fpi.oracle_id
                                               AND fpi.application_id = fets.application_id
                                               AND dt.table_name      = fets.table_name
                                           ) -- added by saleem for bug 7479909
                                       AND NOT EXISTS
                                           ( SELECT NULL
                                           FROM    dba_tab_statistics dts
                                           WHERE   dts.stattype_locked IS NOT NULL
                                               AND dts.table_name=dt.table_name
                                               AND dts.owner     =dt.owner
                                           )
                                      AND NOT EXISTS -- to avoid external tables
                        (SELECT NULL
                        FROM    dba_external_tables de
                        WHERE   de.table_name=dt.table_name
                            AND de.owner     =dt.owner
                        ) -- added this to avoid externale tables being selected
                                  ORDER BY table_name;

                                  num_tables := SQL%ROWCOUNT;
                                  FOR i      IN 1..num_tables
                                  LOOP
                                          IF ( part_flag(i)    = 'YES' ) THEN
                                                  granularity := FND_STATS.ALL_GRANULARITY ;
                                          ELSE
                                                  granularity := FND_STATS.STD_GRANULARITY;
                                          END IF;
                                          BEGIN
						-- changes done for bug 11835452
                                                FND_STATS.GATHER_TABLE_STATS(ownname => schemaname,
						tabname => names(i), percent => NVL(estimate_percent,def_estimate_pcnt),
						degree => degree_parallel, partname=>NULL, CASCADE => TRUE,
						granularity => granularity, hmode => stathist,
						invalidate=> invalidate );
                                          EXCEPTION
                                          WHEN OTHERS THEN
                                                  Errors(err_cnt) := 'ERROR: While GATHER_TABLE_STATS:
object_name='
                                                  ||schemaname
                                                  ||'.'
                                                  ||names(i)
                                                  ||'***'
                                                  ||SQLERRM
                                                  ||'***' ;
                                                  Errors(err_cnt+1) := NULL;
                                                  err_cnt           := err_cnt+1;
                                          END;
                                  END LOOP;
                                  /* end of individual tables */
				 FOR rec_cur IN lock_stats_tab(upper(schemaname)) -- added by saleem to display warning for tables with locked stats
                                  LOOP
                                          dbms_output.put_line('stats on table '
                                          || rec_cur.table_name
                                          || 'is locked ');
					   dlog('stats on table '
                                          || rec_cur.table_name
                                          || ' is locked ');
                                          --fnd_file.put_line(FND_FILE.log,s_message);
                                  END LOOP;
                          elsif ( (upper(OPTIONS)='GATHER AUTO') OR
                                  (
                                          upper(OPTIONS)='LIST AUTO'
                                  )
                                  ) THEN
                                  -- if db_versn > 81 then call flush, else use whatever
                                  -- data is available in dtm
                                  IF db_versn > 81 THEN
                                          IF(fm_first_flag) THEN
                                                  EXECUTE IMMEDIATE 'BEGIN DBMS_STATS.FLUSH_DATABASE_MONITORING_INFO; END;' ;
                                                  fm_first_flag := false;
                                          END IF;
                                  END IF;
                                  -- gather stats for stale tables/partitions. Potentially, there
                                  -- could be some redundent stats gathering, if for eg the table
                                  -- and one of its partitions, both are statle. gather_table_stats
                                  -- would get called twice, once for the table ( which would gather
                                  -- stats for the partitions too, and the partition by itself. The
                                  -- probability of this happening is small, and even if that happens
                                  -- on a rare occasion, the overhead should not be that high, so
                                  -- leaving it as it is for the moment. This can be revisited if
                                  -- tests and experience show that that is not the case.
                                  SELECT   iv.table_name,
                                           iv.partition_name -- ,subpartition_name
                                           BULK COLLECT
                                  INTO     names,
                                           pnames -- ,spnames
                                  FROM
                                           ( SELECT dtm.table_name,
                                                   dtm.partition_name
                                           FROM    sys.dba_tab_modifications dtm
                                           WHERE   dtm.table_owner = upper(schemaname)
                                               AND dtm.partition_name IS NULL
					       AND dtm.TABLE_NAME NOT LIKE 'DR$%' -- added for Bug 8452962
				       AND dtm.table_name not like 'DR#%' -- added for Bug 8452962
                                               AND EXISTS
                                                   ( SELECT NULL
                                                   FROM    dba_tables dt
                                                   WHERE   dt.owner     =dtm.table_owner
                                                       AND dt.table_name=dtm.table_name
                                                       AND
                                                           (
                                                                   NVL(dtm.inserts,0)+NVL(dtm.updates,0)+NVL(dtm.deletes,0)
                                                           )
                                                           > (modpercent*NVL(dt.num_rows,0))/100
                                                   )
						   AND NOT EXISTS
                                           ( SELECT NULL
                                           FROM    dba_tab_statistics dts
                                           WHERE   dts.stattype_locked IS NOT NULL
                                               AND dts.table_name=dtm.table_name
                                               AND dts.owner     =dtm.table_owner
                                           )

                                           UNION ALL

                                           SELECT dtm.table_name,
                                                  dtm.partition_name
                                           FROM   sys.dba_tab_modifications dtm
                                           WHERE  dtm.table_owner = upper(schemaname)
                                              AND dtm.partition_name IS NOT NULL
					       AND dtm.TABLE_NAME NOT LIKE 'DR$%' -- added for Bug 8452962
				       AND dtm.table_name not like 'DR#%' -- added for Bug 8452962
				       AND dtm.table_name not like 'BIN$%' -- added for Bug 9542112
				          AND EXISTS
                                                  ( SELECT NULL
                                                  FROM    dba_tab_partitions dtp
                                                  WHERE   dtp.table_owner   =dtm.table_owner
                                                      AND dtp.table_name    =dtm.table_name
                                                      AND dtp.partition_name=dtm.partition_name
                                                      AND
                                                          (
                                                                  NVL(dtm.inserts,0)+NVL(dtm.updates,0)+NVL(dtm.deletes,0)
                                                          )
                                                          > (modpercent*NVL(dtp.num_rows,0))/100
                                                  )
						  AND NOT EXISTS
                                           ( SELECT NULL
                                           FROM    dba_tab_statistics dts
                                           WHERE   dts.stattype_locked IS NOT NULL
                                               AND dts.table_name=dtm.table_name
                                               AND dts.owner     =dtm.table_owner
                                           )
                                           ) iv
                                  ORDER BY table_name;

                                  num_tables := SQL%ROWCOUNT;
                                  FOR i      IN 1..num_tables
                                  LOOP
                                          BEGIN
                                                  IF (upper(OPTIONS)='GATHER AUTO') THEN
						     -- changes done for bug 11835452
                                                     FND_STATS.GATHER_TABLE_STATS(ownname => schemaname,
						tabname => names(i), percent => NVL(estimate_percent,def_estimate_pcnt),
						 degree => degree_parallel, partname=>pnames(i),
						CASCADE => TRUE, granularity => granularity,
						hmode => stathist, invalidate=> invalidate );
                                                  ELSE
                                                          dlog('Statistics on '
                                                          ||schemaname
                                                          ||'.'
                                                          ||names(i)
                                                          ||'Partition '
                                                          ||NVL(pnames(i),'n/a')
                                                          ||' are Stale');
                                                  END IF;
                                          EXCEPTION
                                          WHEN OTHERS THEN
                                                  Errors(err_cnt) := 'ERROR: While GATHER_TABLE_STATS:
object_name='
                                                  ||schemaname
                                                  ||'.'
                                                  ||names(i)
                                                  ||'***'
                                                  ||SQLERRM
                                                  ||'***' ;
                                                  Errors(err_cnt+1) := NULL;
                                                  err_cnt           := err_cnt+1;
                                          END;
                                  END LOOP;
                                  /* end of individual tables */
                                  FOR rec_cur IN lock_stats_tab(upper(schemaname)) -- added by saleem to display warning for tables with locked stats
                                  LOOP
                                          dbms_output.put_line('stats on table '
                                          || rec_cur.table_name
                                          || 'is locked ');
					  dlog('stats on table '
                                          || rec_cur.table_name
                                          || ' is locked ');
                                          --fnd_file.put_line(FND_FILE.log,s_message);
                                  END LOOP;
                                  -- GATHER AUTO includes GATHER EMPTY, so gather stats
                                  -- on any unalalyzed tables and/or indexes.
                                  FOR c_rec IN empty_cur_ten(upper(schemaname))
                                  LOOP
                                          IF c_rec.type             = 'TABLE' THEN
                                                  IF (upper(OPTIONS)='GATHER AUTO') THEN
						      -- changes done for bug 11835452
	                                              FND_STATS.GATHER_TABLE_STATS(ownname => c_rec.owner, tabname => c_rec.name,
percent => NVL(estimate_percent,def_estimate_pcnt),
degree => degree_parallel, partname=>NULL, CASCADE => TRUE, granularity => granularity,
hmode => stathist, invalidate=> invalidate );
                                                  ELSE
                                                          dlog('Table '
                                                          ||c_rec.owner
                                                          ||'.'
                                                          ||c_rec.name
                                                          ||' is missing statistics.');
                                                  END IF;
                                          elsif c_rec.type          ='INDEX' THEN
                                                  IF (upper(OPTIONS)='GATHER AUTO') THEN
							  -- changes done for bug 11835452
                                                          fnd_stats.gather_index_stats(ownname=>c_rec.owner, indname=>c_rec.name, percent=>NVL(estimate_percent,def_estimate_pcnt), invalidate=>invalidate);
                                                  ELSE
                                                          dlog('Index '
                                                          ||c_rec.owner
                                                          ||'.'
                                                          ||c_rec.name
                                                          ||' is missing statistics! ');
                                                  END IF;
                                          END IF;
                                  END LOOP;
                                  -- Check if there are any tables in the schema which does not have
                                  -- monitoring enabled. If yes, gather stats for them using 10% and
                                  -- enable monitoring for such tables so that we have data for them
                                  -- in dba_tab_modifications for next time.
                                  FOR c_rec IN nomon_tab_lt(upper(schemaname))
                                  LOOP
                                          IF (upper(OPTIONS)='GATHER AUTO') THEN
						  -- changes done for bug 11835452
                                                  FND_STATS.GATHER_TABLE_STATS(ownname => c_rec.owner,
tabname => c_rec.table_name, percent => NVL(estimate_percent,def_estimate_pcnt), degree => degree_parallel,
partname=>NULL, CASCADE => TRUE, granularity => granularity, hmode => stathist, invalidate=> invalidate );
                                                  EXECUTE IMMEDIATE 'alter table '
                                                  ||c_rec.owner
                                                  ||'.'
                                                  ||c_rec.table_name
                                                  ||' monitoring';
                                                  dlog('Monitoring has now been enabled for Table '
                                                  ||c_rec.owner
                                                  ||'.'
                                                  ||c_rec.table_name
                                                  ||'. Stats were gathered.' );
                                          ELSE
                                                  dlog('Monitoring is not enabled for Table '
                                                  ||c_rec.owner
                                                  ||'.'
                                                  ||c_rec.table_name );
                                          END IF;
                                  END LOOP; -- nomon_tab
                          elsif ( (upper(OPTIONS)='GATHER EMPTY') OR
                                  (
                                          upper(OPTIONS)='LIST EMPTY'
                                  )
                                  ) THEN
                                  FOR c_rec IN empty_cur_ten(upper(schemaname))
                                  LOOP
                                          IF c_rec.type             = 'TABLE' THEN
                                                  IF (upper(OPTIONS)='GATHER EMPTY') THEN
							  -- changes done for bug 11835452
                                                          FND_STATS.GATHER_TABLE_STATS(ownname => c_rec.owner, tabname => c_rec.name,
percent => NVL(estimate_percent,def_estimate_pcnt), degree => degree_parallel, partname=>NULL, CASCADE => TRUE,
granularity => granularity, hmode => stathist, invalidate=> invalidate );
                                                  ELSE
                                                          dlog('Table '
                                                          ||c_rec.owner
                                                          ||'.'
                                                          ||c_rec.name
                                                          ||' is missing statistics! ');
                                                  END IF;
                                          elsif c_rec.type          ='INDEX' THEN
                                                  IF (upper(OPTIONS)='GATHER EMPTY') THEN
							  -- changes done for bug 11835452
                                                          fnd_stats.gather_index_stats(ownname=>c_rec.owner, indname=>c_rec.name, percent=>NVL(estimate_percent,def_estimate_pcnt), invalidate=>invalidate);
                                                  ELSE
                                                          dlog('Statistics for Index '
                                                          ||c_rec.owner
                                                          ||'.'
                                                          ||c_rec.name
                                                          ||' are Empty');
                                                  END IF;
                                          END IF;
                                  END LOOP;
                                  FOR rec_cur IN lock_stats_tab(upper(schemaname)) -- added by saleem to display warning for tables with locked stats
                                  LOOP
                                          dbms_output.put_line('stats on table '
                                          || rec_cur.table_name
                                          || ' is locked ');
					  dlog('stats on table '
                                          || rec_cur.table_name
                                          || ' is locked ');
                                          --fnd_file.put_line(FND_FILE.log,s_message);
                                  END LOOP;
                          END IF;
			       $END
                         -- ENDI IF;
			  /* end of if upper(options)=  */
                          -- End timestamp
                          IF(upper(stathist) <> 'NONE') THEN
                                  BEGIN
                                          FND_STATS.UPDATE_HIST(schemaname=>schemaname, objectname=>schemaname, objecttype=>'SCHEMA', partname=>NULL, columntablename=>NULL, degree=>degree_parallel, upd_ins_flag=>'E' );
                                  END;
                          END IF;
                  ELSE
                          /* This is for ALL schema */
                          FOR c_schema IN schema_cur
                          LOOP
                                  --dbms_output.put_line('start of schema = '|| c_schema.sname);
                                  -- make a recursive call to gather_schema_stats
				  -- changes done for bug 11835452
                                  GATHER_SCHEMA_STATS_SQLPLUS(schemaname=>c_schema.sname , estimate_percent=>NVL(estimate_percent,def_estimate_pcnt) ,
degree=>degree , internal_flag=>internal_flag , Errors=> Errors , request_id=>request_id , hmode=>stathist ,
OPTIONS=>OPTIONS , modpercent=>modpercent , invalidate=> invalidate );
                                  /* for rec_cur in lock_stats_tab -- added by saleem
                                  loop
                                  dbms_output.put_line('stats on table ' || rec_cur.table_name || 'is locked ');
                                  dlog('stats on table ' || rec_cur.table_name || 'is locked ');
                                  s_message := 'stats on table ' || rec_cur.table_name || ' is locked ' ;
                                  fnd_file.put_line(FND_FILE.log,s_message);
                                  end loop; */
                          END LOOP;
                          /* schema_cur */
                  END IF;
          ELSE -- schema is SYS, print message in log.
                  dlog('Gathering statistics on the SYS schema using FND_STATS is not allowed.');
                  dlog('Please use DBMS_STATS package to gather stats on SYS objects.');
          END IF; -- end of schema<> SYS
  END;
  /* GATHER_SCHEMA_STATS_SQLPLUS */
  /************************************************************************/
  /* Procedure: GATHER_SCHEMA_STATS                                       */
  /* Desciption: Gather schema statistics. This is called by concurrent   */
  /* manager version of GATHER_SCHEMA_STATS.                              */
  /* Notes: internal_flag='INTERNAL' will call dbms_utility.analyze_schema*/
  /* insead of dbms_stats.gather_schema_stats                             */
  /* internal_flag='NOBACKUP'  will bypass dbms_stats.export_schema_stats */
  /************************************************************************/
PROCEDURE GATHER_SCHEMA_STATS(schemaname       IN VARCHAR2,
                              estimate_percent IN NUMBER ,
                              degree           IN NUMBER ,
                              internal_flag    IN VARCHAR2 ,
                              --Errors        OUT NOCOPY  Error_Out,-- commented for handling errors
                              request_id IN NUMBER DEFAULT NULL,
                              hmode      IN VARCHAR2 DEFAULT 'LASTRUN',
                              OPTIONS    IN VARCHAR2 DEFAULT 'GATHER',
                              modpercent IN NUMBER DEFAULT 10,
                              invalidate IN VARCHAR2 DEFAULT 'Y' )
IS
TYPE name_tab
IS
        TABLE OF dba_tables.table_name%TYPE;
TYPE partition_tab
IS
        TABLE OF sys.dba_tab_modifications.partition_name%TYPE;
TYPE partition_type_tab
IS
        TABLE OF dba_tables.partitioned%TYPE;
        part_flag partition_type_tab;
        names name_tab;
        pnames partition_tab;
        num_tables         NUMBER := 0;
        l_message          VARCHAR2(1000) ;
        granularity        VARCHAR2(12);
        exist_insufficient EXCEPTION;
        pragma exception_init(exist_insufficient,-20002);
        err_cnt BINARY_INTEGER := 0;
        degree_parallel NUMBER(4);
	mod_percent number (4); -- added by saleem for modpercent for bug 8558775/9182943
        str_request_id  VARCHAR(30);
        -- Cursor to get list of tables and indexes with no stats
        CURSOR empty_cur(schemaname VARCHAR2)
        IS
                SELECT   type ,
                         owner,
                         name
                FROM
                         ( SELECT 'TABLE' type,
                                 owner        ,
                                 table_name name
                         FROM    dba_tables dt
                         WHERE   owner=upper(schemaname)
                             AND
                                 (
                                         iot_type <> 'IOT_OVERFLOW'
                                      OR iot_type IS NULL
                                 )
                             AND TEMPORARY <> 'Y'
                             AND last_analyzed IS NULL
			     AND TABLE_NAME NOt LIKE 'DR$%' -- added for Bug 8452962
			     AND table_name not like 'DR#%' -- added for Bug 8452962
                                 -- leave alone if excluded table
                             AND NOT EXISTS
                                 (SELECT NULL
                                 FROM    fnd_exclude_table_stats fets,
                                         fnd_oracle_userid fou       ,
                                         fnd_product_installations fpi
                                 WHERE   fou.oracle_username=upper(schemaname)
                                     AND fou.oracle_id      =fpi.oracle_id
                                     AND fpi.application_id = fets.application_id
                                     AND dt.table_name      = fets.table_name
                                 )
				   AND NOT EXISTS
                        (SELECT NULL
                        FROM    dba_external_tables de
                        WHERE   de.table_name=dt.table_name
                            AND de.owner     =dt.owner
                        ) -- added this to avoid externale tables being selected

                         UNION

                         SELECT DISTINCT 'TABLE' type     ,
                                         table_owner owner,
                                         table_name name
                         FROM            dba_indexes di
                         WHERE
                                         (
                                                         di.table_owner=upper(schemaname)
                                                      OR di.owner      =upper(schemaname)
                                         )
                                     AND di.index_type <> 'LOB'
                                     AND di.temporary  <> 'Y'
				     AND di.generated <> 'Y' -- change done by saleem for bug 9542112
                                     AND di.last_analyzed IS NULL
                                     AND NOT EXISTS
                                         (SELECT NULL
                                         FROM    fnd_exclude_table_stats fets,
                                                 fnd_oracle_userid fou       ,
                                                 fnd_product_installations fpi
                                         WHERE   fou.oracle_username=upper(schemaname)
                                             AND fou.oracle_id      =fpi.oracle_id
                                             AND fpi.application_id =fets.application_id
                                             AND di.table_name      =fets.table_name
                                         )
                         )
                ORDER BY type ,
                         owner,
                         name ;

                CURSOR nomon_tab(schemaname VARCHAR2)
                IS
                 SELECT owner,
                        table_name
                 FROM   dba_tables dt
                 WHERE  owner=upper(schemaname)
                    AND
                        (
                               iot_type <> 'IOT_OVERFLOW'
                            OR iot_type IS NULL
                        )
                    AND TEMPORARY <> 'Y'
                    AND monitoring ='NO'
		    AND TABLE_NAME NOT LIKE 'DR$%' -- added for Bug 8452962
		    AND table_name not like 'DR#%' -- added for Bug 8452962
                    AND NOT EXISTS
                        (SELECT NULL
                        FROM    dba_external_tables de
                        WHERE   de.table_name=dt.table_name
                            AND de.owner     =dt.owner
                        );-- added this to avoid externale tables being selected
	$IF DBMS_DB_VERSION.VER_LE_9_2 $THEN
	 $ELSE
         CURSOR nomon_tab_lt(schemaname VARCHAR2) -- this is for locking stats on table
         IS
                 SELECT owner,
                        table_name
                 FROM   dba_tables dt
                 WHERE  owner=upper(schemaname)
                    AND
                        (
                               iot_type <> 'IOT_OVERFLOW'
                            OR iot_type IS NULL
                        )
                    AND TEMPORARY <> 'Y'
                    AND monitoring ='NO'
		    AND TABLE_NAME NOT LIKE 'DR$%' -- added for Bug 8452962
		    AND table_name not like 'DR#%' -- added for Bug 8452962
                    AND NOT EXISTS
                        (SELECT NULL
                        FROM    dba_external_tables de
                        WHERE   de.table_name=dt.table_name
                            AND de.owner     =dt.owner
                        )-- added this to avoid externale tables being selected
            AND NOT EXISTS
                ( SELECT NULL
                FROM    dba_tab_statistics dts
                WHERE   dts.stattype_locked IS NOT NULL
                    AND dts.table_name=dt.table_name
                    AND dts.owner     =dt.owner
                );  -- added by saleem to avoid locked objects
             CURSOR empty_cur_ten(schemaname VARCHAR2)
		-- new cursro for excluding tables with empty stats and locked stats
		-- will get execte only for 10g and above
        IS
                SELECT   type ,
                         owner,
                         name
                FROM
                         ( SELECT 'TABLE' type,
                                 owner        ,
                                 table_name name
                         FROM    dba_tables dt
                         WHERE   owner=upper(schemaname)
                             AND
                                 (
                                         iot_type <> 'IOT_OVERFLOW'
                                      OR iot_type IS NULL
                                 )
                             AND TEMPORARY <> 'Y'
                             AND last_analyzed IS NULL
			     AND table_name not like 'DR$%' -- added for Bug 8452962
			     AND table_name not like 'DR#%' -- added for Bug 8452962
			      -- leave alone if excluded table
                             AND NOT EXISTS
                                 (SELECT NULL
                                 FROM    fnd_exclude_table_stats fets,
                                         fnd_oracle_userid fou       ,
                                         fnd_product_installations fpi
                                 WHERE   fou.oracle_username=upper(schemaname)
                                     AND fou.oracle_id      =fpi.oracle_id
                                     AND fpi.application_id = fets.application_id
                                     AND dt.table_name      = fets.table_name
                                 )
				  AND NOT EXISTS
                        (SELECT NULL
                        FROM    dba_external_tables de
                        WHERE   de.table_name=dt.table_name
                            AND de.owner     =dt.owner
                        ) -- added this to avoid externale tables being selected
			AND NOT EXISTS
			( SELECT NULL
                FROM    dba_tab_statistics dts
                WHERE   dts.stattype_locked IS NOT NULL
                    AND dts.table_name=dt.table_name
                    AND dts.owner     =dt.owner
                )
                         UNION ALL

                         SELECT 'INDEX' type,
                                owner       ,
                                index_name name
                         FROM   dba_indexes
                         WHERE
                                (
                                       table_owner=upper(schemaname)
                                    OR owner      =upper(schemaname)
                                )
                            AND index_type <> 'LOB'
                            AND index_type <>'DOMAIN'
                            AND TEMPORARY  <> 'Y'
			    AND generated <> 'Y' -- change done by saleem for bug 9542112
                            AND last_analyzed IS NULL
                         )
         ORDER BY type ,
                  owner,
                  name ;
             $END
	     $IF DBMS_DB_VERSION.VER_LE_9_2 $THEN
	   $ELSE
         CURSOR lock_stats_tab(schemaname VARCHAR2)
         IS -- cursor added by saleem to display the warning message for tables with  locked stats
                 SELECT table_name
                 FROM   dba_tab_statistics
                 WHERE  stattype_locked IS NOT NULL
                    AND owner=upper(schemaname);  -- added to display the warning for locked stats
		    $END
         BEGIN
                 -- Set the package body variable.
                 stathist := hmode;
                 -- if request id (restart case) is provided, then this is the cur_request_id
                 -- valid for both conc program and sql plus case.
                 IF request_id IS NOT NULL THEN
                         cur_request_id := request_id;
                 END IF;
                 -- get degree of parallelism
                 IF degree IS NULL THEN
                         degree_parallel:=def_degree;
                 ELSE
                         degree_parallel := degree;
                 END IF;
		 IF modpercent is null THEN -- added by saleem to check modpercent
		     mod_percent := 10;
                 ELSE
		     mod_percent :=modpercent;
		 END IF;
                 -- Initialize the TABLE Errors
                 --Errors(0) := NULL; -- commented the initialization so that the errors will not be cleared
                 granularity := FND_STATS.ALL_GRANULARITY; -- granularity will be ALL for all tables
                 err_cnt     := 0;
                 -- If a specific schema is given
                 IF (upper(schemaname)         <> 'SYS') THEN
                         IF (upper(schemaname) <> 'ALL') THEN
                                 -- Insert/update the fnd_stats_hist table
                                 IF(upper(stathist)<> 'NONE') THEN
                                         BEGIN
                                                 --            if(cur_request_id is null) then
                                                 --             cur_request_id := GET_REQUEST_ID(request_id);
                                                 --            end if;
						 -- changes done for bug 11835452
                                                 FND_STATS.UPDATE_HIST(schemaname=>schemaname, objectname=>schemaname,
objecttype=>'SCHEMA', partname=>NULL, columntablename=>NULL, degree=>degree_parallel, upd_ins_flag=>'S',
percent=>NVL(estimate_percent,def_estimate_pcnt));
                                         END;
                                 END IF; --if(upper(stathist)<> 'NONE')
                                 -- backup the existing schema stats
                                 IF ( (upper(internal_flag) = 'BACKUP') ) THEN
                                         FND_STATS.BACKUP_SCHEMA_STATS( schemaname );
                                 END IF;
			$IF DBMS_DB_VERSION.VER_LE_9_2 $THEN --checkingf or dbversion for lock stats
                                 IF(upper(OPTIONS)='GATHER') THEN
                                         SELECT   table_name ,
                                                  partitioned BULK COLLECT
                                         INTO     names,
                                                  part_flag
                                         FROM     dba_tables dt
                                         WHERE    owner = upper(schemaname)
                                              AND
                                                  (
                                                           iot_type <> 'IOT_OVERFLOW'
                                                        OR iot_type IS NULL
                                                  )
                                              AND TEMPORARY <> 'Y' -- Bypass if temporary tables for bug#1108002
					      AND TABLE_NAME NOT LIKE 'DR$%' -- added for Bug 8452962
                                              AND TABLE_NAME NOT LIKE 'DR#%' -- added for Bug 8452962
                                              AND NOT EXISTS
                                                  (SELECT NULL
                                                  FROM    fnd_stats_hist fsh
                                                  WHERE   dt.owner        =fsh.schema_name
                                                      AND fsh.REQUEST_ID  = cur_request_id
                                                      AND fsh.object_type ='CASCADE'
                                                      AND fsh.history_mode=stathist
                                                      AND dt.table_name   = fsh.object_name
                                                      AND LAST_GATHER_END_TIME IS NOT NULL
                                                  )
                                                  -- leave alone if excluded table
                                              AND NOT EXISTS
                                                  (SELECT NULL
                                                  FROM    fnd_exclude_table_stats fets,
                                                          fnd_oracle_userid fou       ,
                                                          fnd_product_installations fpi
                                                  WHERE   fou.oracle_username=upper(schemaname)
                                                      AND fou.oracle_id      =fpi.oracle_id
                                                      AND fpi.application_id = fets.application_id
                                                      AND dt.table_name      = fets.table_name
                                                  )
                                          AND NOT EXISTS -- to avoid extrnal tables
                        (SELECT NULL
                        FROM    dba_external_tables de
                        WHERE   de.table_name=dt.table_name
                            AND de.owner     =dt.owner
                        ) -- added this to avoid externale tables being selected
                                              ORDER BY table_name;
                                         num_tables := SQL%ROWCOUNT;
                                         FOR i      IN 1..num_tables
                                         LOOP
                                                 IF ( part_flag(i)    = 'YES' ) THEN
                                                         granularity := FND_STATS.ALL_GRANULARITY ;
                                                 ELSE
                                                         granularity := FND_STATS.STD_GRANULARITY;
                                                 END IF;
                                                 BEGIN
							 -- changes done for bug 11835452
                                                         FND_STATS.GATHER_TABLE_STATS(ownname => schemaname, tabname => names(i),
percent => NVL(estimate_percent,def_estimate_pcnt), degree => degree_parallel, partname=>NULL, CASCADE => TRUE,
granularity => granularity, hmode => stathist, invalidate=> invalidate );
                                                 EXCEPTION
                                                 WHEN OTHERS THEN
                                                         g_Errors(err_cnt) := 'ERROR: While GATHER_TABLE_STATS:
object_name='
                                                         ||schemaname
                                                         ||'.'
                                                         ||names(i)
                                                         ||'***'
                                                         ||SQLERRM
                                                         ||'***' ;
                                                         g_Errors(err_cnt+1) := NULL;
                                                         err_cnt             := err_cnt+1;
                                                 END;
                                         END LOOP;
                                         /* end of individual tables */
                                 elsif ( (upper(OPTIONS)='GATHER AUTO') OR
                                         (
                                                 upper(OPTIONS)='LIST AUTO'
                                         )
                                         ) THEN
                                         -- if db_versn > 81 then call flush, else use whatever
                                         -- data is available in dtm
                                         IF db_versn > 81 THEN
                                                 IF(fm_first_flag) THEN
                                                         EXECUTE IMMEDIATE 'BEGIN DBMS_STATS.FLUSH_DATABASE_MONITORING_INFO; END;' ;
                                                         fm_first_flag := false;
                                                 END IF;
                                         END IF;
                                         -- gather stats for stale tables/partitions. Potentially, there
                                         -- could be some redundent stats gathering, if for eg the table
                                         -- and one of its partitions, both are statle. gather_table_stats
                                         -- would get called twice, once for the table ( which would gather
                                         -- stats for the partitions too, and the partition by itself. The
                                         -- probability of this happening is small, and even if that happens
                                         -- on a rare occasion, the overhead should not be that high, so
                                         -- leaving it as it is for the moment. This can be revisited if
                                         -- tests and experience show that that is not the case.
                                         SELECT   iv.table_name,
                                                  iv.partition_name -- ,subpartition_name
                                                  BULK COLLECT
                                         INTO     names,
                                                  pnames -- ,spnames
                                         FROM
                                                  ( SELECT dtm.table_name,
                                                          dtm.partition_name
                                                  FROM    sys.dba_tab_modifications dtm
                                                  WHERE   dtm.table_owner = upper(schemaname)
                                                      AND dtm.partition_name IS NULL
						      AND dtm.TABLE_NAME NOT LIKE 'DR$%' -- added for Bug 8452962
                                                  AND dtm.table_name not like 'DR#%' -- added for Bug 8452962
                                                      AND EXISTS
                                                          ( SELECT NULL
                                                          FROM    dba_tables dt
                                                          WHERE   dt.owner      =dtm.table_owner
                                                              AND dt.table_name =dtm.table_name
                                                              AND dt.partitioned='NO'
                                                              AND
                                                                  (
                                                                          NVL(dtm.inserts,0)+NVL(dtm.updates,0)+NVL(dtm.deletes,0)
                                                                  )
                                                                  > (mod_percent*NVL(dt.num_rows,0))/100
                                                          )
					        UNION ALL
                                                  SELECT dtm.table_name,
                                                         dtm.partition_name
                                                  FROM   sys.dba_tab_modifications dtm
                                                  WHERE  dtm.table_owner = upper(schemaname)
                                                     AND dtm.partition_name IS NOT NULL
						     AND dtm.TABLE_NAME NOT LIKE 'DR$%' -- added for Bug 8452962
						   AND dtm.table_name not like 'DR#%' -- added for Bug 8452962
                                                     AND EXISTS
                                                         ( SELECT NULL
                                                         FROM    dba_tab_partitions dtp
                                                         WHERE   dtp.table_owner   =dtm.table_owner
                                                             AND dtp.table_name    =dtm.table_name
                                                             AND dtp.partition_name=dtm.partition_name
                                                             AND
                                                                 (
                                                                         NVL(dtm.inserts,0)+NVL(dtm.updates,0)+NVL(dtm.deletes,0)
                                                                 )
                                                                 > (mod_percent*NVL(dtp.num_rows,0))/100
                                                         )
                                                  ) iv
                                         ORDER BY table_name;

                                         num_tables := SQL%ROWCOUNT;
                                         FOR i      IN 1..num_tables
                                         LOOP
                                                 BEGIN
                                                         IF (upper(OPTIONS)='GATHER AUTO') THEN
								 -- changes done for bug 11835452
                                                                 FND_STATS.GATHER_TABLE_STATS(ownname => schemaname,
tabname => names(i), percent => NVL(estimate_percent,def_estimate_pcnt), degree => degree_parallel, partname=>pnames(i),
CASCADE => TRUE, granularity => granularity, hmode => stathist, invalidate=> invalidate );
                                                         ELSE
                                                                 dlog('Statistics on '
                                                                 ||schemaname
                                                                 ||'.'
                                                                 ||names(i)
                                                                 ||'Partition '
                                                                 ||NVL(pnames(i),'n/a')
                                                                 ||' are Stale');
                                                         END IF;
                                                 EXCEPTION
                                                 WHEN OTHERS THEN
                                                         g_Errors(err_cnt) := 'ERROR: While GATHER_TABLE_STATS:
object_name='
                                                         ||schemaname
                                                         ||'.'
                                                         ||names(i)
                                                         ||'***'
                                                         ||SQLERRM
                                                         ||'***' ;
                                                         g_Errors(err_cnt+1) := NULL;
                                                         err_cnt             := err_cnt+1;
                                                 END;
                                         END LOOP;
                                         /* end of individual tables */
                                         -- GATHER AUTO includes GATHER EMPTY, so gather stats
                                         -- on any unalalyzed tables and/or indexes.
                                         FOR c_rec IN empty_cur(upper(schemaname))
                                         LOOP
                                                 IF c_rec.type             = 'TABLE' THEN
                                                         IF (upper(OPTIONS)='GATHER AUTO') THEN
								 -- changes done for bug 11835452
                                                                 FND_STATS.GATHER_TABLE_STATS(ownname => c_rec.owner,
tabname => c_rec.name, percent => NVL(estimate_percent,def_estimate_pcnt), degree => degree_parallel, partname=>NULL,
CASCADE => TRUE, granularity => granularity, hmode => stathist, invalidate=> invalidate );
                                                         ELSE
                                                                 dlog('Table '
                                                                 ||c_rec.owner
                                                                 ||'.'
                                                                 ||c_rec.name
                                                                 ||' is missing statistics.');
                                                         END IF;
                                                 END IF;
                                         END LOOP;
                                         -- Check if there are any tables in the schema which does not have
                                         -- monitoring enabled. If yes, gather stats for them using 10% and
                                         -- enable monitoring for such tables so that we have data for them
                                         -- in dba_tab_modifications for next time.
                                         FOR c_rec IN nomon_tab(upper(schemaname))
                                         LOOP
                                                 IF (upper(OPTIONS)='GATHER AUTO') THEN
							 -- changes done for bug 11835452
                                                         FND_STATS.GATHER_TABLE_STATS(ownname => c_rec.owner, tabname => c_rec.table_name,
percent => NVL(estimate_percent,def_estimate_pcnt), degree => degree_parallel, partname=>NULL, CASCADE => TRUE,
granularity => granularity, hmode => stathist, invalidate=> invalidate );
                                                         EXECUTE IMMEDIATE 'alter table '
                                                         ||c_rec.owner
                                                         ||'.'
                                                         ||c_rec.table_name
                                                         ||' monitoring';
                                                         dlog('Monitoring has now been enabled for Table '
                                                         ||c_rec.owner
                                                         ||'.'
                                                         ||c_rec.table_name
                                                         ||'. Stats were gathered.' );
                                                 ELSE
                                                         dlog('Monitoring is not enabled for Table '
                                                         ||c_rec.owner
                                                         ||'.'
                                                         ||c_rec.table_name );
                                                 END IF;
                                         END LOOP; -- nomon_tab
                                 elsif ( (upper(OPTIONS)='GATHER EMPTY') OR
                                         (
                                                 upper(OPTIONS)='LIST EMPTY'
                                         )
                                         ) THEN
                                         FOR c_rec IN empty_cur(upper(schemaname))
                                         LOOP
                                                 IF c_rec.type             = 'TABLE' THEN
                                                         IF (upper(OPTIONS)='GATHER EMPTY') THEN
								 -- changes done for bug 11835452
                                                                 FND_STATS.GATHER_TABLE_STATS(ownname => c_rec.owner, tabname => c_rec.name,
percent => NVL(estimate_percent,def_estimate_pcnt), degree => degree_parallel, partname=>NULL, CASCADE => TRUE,
granularity => granularity, hmode => stathist, invalidate=> invalidate );
                                                         ELSE
                                                                 dlog('Table '
                                                                 ||c_rec.owner
                                                                 ||'.'
                                                                 ||c_rec.name
                                                                 ||' is missing statistics! ');
                                                         END IF;
                                                 END IF;
                                         END LOOP;
					 END IF;
				 /* end of if upper(options)=  */
				 $ELSE -- for DB version 10g and above
				 IF(upper(OPTIONS)='GATHER') THEN
                                         SELECT   table_name ,
                                                  partitioned BULK COLLECT
                                         INTO     names,
                                                  part_flag
                                         FROM     dba_tables dt
                                         WHERE    owner = upper(schemaname)
                                              AND
                                                  (
                                                           iot_type <> 'IOT_OVERFLOW'
                                                        OR iot_type IS NULL
                                                  )
                                              AND TEMPORARY <> 'Y' -- Bypass if temporary tables for bug#1108002
					      AND TABLE_NAME NOT LIKE 'DR$%' -- added for Bug 8452962
                                              AND TABLE_NAME NOT LIKE 'DR#%' -- added for Bug 8452962
                                              AND NOT EXISTS
                                                  (SELECT NULL
                                                  FROM    fnd_stats_hist fsh
                                                  WHERE   dt.owner        =fsh.schema_name
                                                      AND fsh.REQUEST_ID  = cur_request_id
                                                      AND fsh.object_type ='CASCADE'
                                                      AND fsh.history_mode=stathist
                                                      AND dt.table_name   = fsh.object_name
                                                      AND LAST_GATHER_END_TIME IS NOT NULL
                                                  )
                                                  -- leave alone if excluded table
                                              AND NOT EXISTS
                                                  (SELECT NULL
                                                  FROM    fnd_exclude_table_stats fets,
                                                          fnd_oracle_userid fou       ,
                                                          fnd_product_installations fpi
                                                  WHERE   fou.oracle_username=upper(schemaname)
                                                      AND fou.oracle_id      =fpi.oracle_id
                                                      AND fpi.application_id = fets.application_id
                                                      AND dt.table_name      = fets.table_name
                                                  )
                                              AND NOT EXISTS
                                                  ( SELECT NULL
                                                  FROM    dba_tab_statistics dts
                                                  WHERE   dts.stattype_locked IS NOT NULL
                                                      AND dts.table_name=dt.table_name
                                                      AND dts.owner     =dt.owner
                                                  )
                                              AND NOT EXISTS -- to avoid external tables
                        (SELECT NULL
                        FROM    dba_external_tables de
                        WHERE   de.table_name=dt.table_name
                            AND de.owner     =dt.owner
                        ) -- added this to avoid externale tables being selected
                                         ORDER BY table_name;

                                         num_tables := SQL%ROWCOUNT;
                                         FOR i      IN 1..num_tables
                                         LOOP
                                                 IF ( part_flag(i)    = 'YES' ) THEN
                                                         granularity := FND_STATS.ALL_GRANULARITY ;
                                                 ELSE
                                                         granularity := FND_STATS.STD_GRANULARITY;
                                                 END IF;
                                                 BEGIN
							 -- changes done for bug 11835452
                                                         FND_STATS.GATHER_TABLE_STATS(ownname => schemaname, tabname => names(i),
percent => NVL(estimate_percent,def_estimate_pcnt), degree => degree_parallel, partname=>NULL, CASCADE => TRUE,
granularity => granularity, hmode => stathist, invalidate=> invalidate );
                                                 EXCEPTION
                                                 WHEN OTHERS THEN
                                                         g_Errors(err_cnt) := 'ERROR: While GATHER_TABLE_STATS:
object_name='
                                                         ||schemaname
                                                         ||'.'
                                                         ||names(i)
                                                         ||'***'
                                                         ||SQLERRM
                                                         ||'***' ;
                                                         g_Errors(err_cnt+1) := NULL;
                                                         err_cnt             := err_cnt+1;
                                                 END;
                                         END LOOP;
                                         /* end of individual tables */
                                         FOR rec_cur IN lock_stats_tab(upper(schemaname)) -- added by saleem to display warning for tables with locked stats
                                         LOOP
                                                 dbms_output.put_line('stats on table '
                                                 || rec_cur.table_name
                                                 || 'is locked ');
                                                 dlog('stats on table '
                                                 || rec_cur.table_name
                                                 || ' is locked ');
                                                 -- s_message := 'stats on table ' || rec_cur.table_name || ' is locked ' ;
                                                 --fnd_file.put_line(FND_FILE.log,s_message);
                                         END LOOP;
                                 elsif ( (upper(OPTIONS)='GATHER AUTO') OR
                                         (
                                                 upper(OPTIONS)='LIST AUTO'
                                         )
                                         ) THEN
                                         -- if db_versn > 81 then call flush, else use whatever
                                         -- data is available in dtm
                                         IF db_versn > 81 THEN
                                                 IF(fm_first_flag) THEN
                                                         EXECUTE IMMEDIATE 'BEGIN DBMS_STATS.FLUSH_DATABASE_MONITORING_INFO; END;' ;
                                                         fm_first_flag := false;
                                                 END IF;
                                         END IF;
                                         -- gather stats for stale tables/partitions. Potentially, there
                                         -- could be some redundent stats gathering, if for eg the table
                                         -- and one of its partitions, both are statle. gather_table_stats
                                         -- would get called twice, once for the table ( which would gather
                                         -- stats for the partitions too, and the partition by itself. The
                                         -- probability of this happening is small, and even if that happens
                                         -- on a rare occasion, the overhead should not be that high, so
                                         -- leaving it as it is for the moment. This can be revisited if
                                         -- tests and experience show that that is not the case.
                                         SELECT   iv.table_name,
                                                  iv.partition_name -- ,subpartition_name
                                                  BULK COLLECT
                                         INTO     names,
                                                  pnames -- ,spnames
                                         FROM
                                                  ( SELECT dtm.table_name,
                                                          dtm.partition_name
                                                  FROM    sys.dba_tab_modifications dtm
                                                  WHERE   dtm.table_owner = upper(schemaname)
                                                      AND dtm.partition_name IS NULL
						      AND dtm.TABLE_NAME NOT LIKE 'DR$%' -- added for Bug 8452962
                                                  AND dtm.table_name not like 'DR#%' -- added for Bug 8452962
                                                      AND EXISTS
                                                          ( SELECT NULL
                                                          FROM    dba_tables dt
                                                          WHERE   dt.owner      =dtm.table_owner
                                                              AND dt.table_name =dtm.table_name
                                                              AND dt.partitioned='NO'
                                                              AND
                                                                  (
                                                                          NVL(dtm.inserts,0)+NVL(dtm.updates,0)+NVL(dtm.deletes,0)
                                                                  )
                                                                  > (mod_percent*NVL(dt.num_rows,0))/100
                                                          )
							     AND NOT EXISTS
                                           ( SELECT NULL
                                           FROM    dba_tab_statistics dts
                                           WHERE   dts.stattype_locked IS NOT NULL
                                               AND dts.table_name=dtm.table_name
                                               AND dts.owner     =dtm.table_owner
                                           )
                                               UNION ALL
                                               SELECT dtm.table_name,
                                                      dtm.partition_name
                                                FROM   sys.dba_tab_modifications dtm
                                                WHERE  dtm.table_owner = upper(schemaname)
                                                   AND dtm.partition_name IS NOT NULL
					      AND dtm.TABLE_NAME NOT LIKE 'DR$%' -- added for Bug 8452962
					      AND dtm.table_name not like 'DR#%' -- added for Bug 8452962
					      AND dtm.table_name not like 'BIN$%' -- added for Bug 9542112
					     AND EXISTS
                                                 ( SELECT NULL
                                                    FROM    dba_tab_partitions dtp
                                                    WHERE   dtp.table_owner   =dtm.table_owner
                                                     AND dtp.table_name    =dtm.table_name
                                                     AND dtp.partition_name=dtm.partition_name
                                                     AND
                                                         (
                                                       NVL(dtm.inserts,0)+NVL(dtm.updates,0)+NVL(dtm.deletes,0)
                                                         )
                                                       > (mod_percent*NVL(dtp.num_rows,0))/100
                                                        )
					    AND NOT EXISTS
                                           ( SELECT NULL
                                           FROM    dba_tab_statistics dts
                                           WHERE   dts.stattype_locked IS NOT NULL
                                               AND dts.table_name=dtm.table_name
                                               AND dts.owner     =dtm.table_owner
                                           )
                                                  ) iv
                                         ORDER BY table_name;

                                         num_tables := SQL%ROWCOUNT;
                                         FOR i      IN 1..num_tables
                                         LOOP
                                                 BEGIN
                                                         IF (upper(OPTIONS)='GATHER AUTO') THEN
								 -- changes done for bug 11835452
                                                                 FND_STATS.GATHER_TABLE_STATS(ownname => schemaname,
tabname => names(i), percent => NVL(estimate_percent,def_estimate_pcnt), degree => degree_parallel, partname=>pnames(i),
CASCADE => TRUE, granularity => granularity, hmode => stathist, invalidate=> invalidate );
                                                         ELSE
                                                                 dlog('Statistics on '
                                                                 ||schemaname
                                                                 ||'.'
                                                                 ||names(i)
                                                                 ||'Partition '
                                                                 ||NVL(pnames(i),'n/a')
                                                                 ||' are Stale');
                                                         END IF;
                                                 EXCEPTION
                                                 WHEN OTHERS THEN
                                                         g_Errors(err_cnt) := 'ERROR: While GATHER_TABLE_STATS:
object_name='
                                                         ||schemaname
                                                         ||'.'
                                                         ||names(i)
                                                         ||'***'
                                                         ||SQLERRM
                                                         ||'***' ;
                                                         g_Errors(err_cnt+1) := NULL;
                                                         err_cnt             := err_cnt+1;
                                                 END;
                                         END LOOP;
                                         /* end of individual tables */
                                         FOR rec_cur IN lock_stats_tab(upper(schemaname)) -- added by saleem to display warning for tables with locked stats
                                         LOOP
                                                 dbms_output.put_line('stats on table '
                                                 || rec_cur.table_name
                                                 || ' is locked ');
                                                 dlog('stats on table '
                                                 || rec_cur.table_name
                                                 || ' is locked ');
                                                 -- s_message := 'stats on table ' || rec_cur.table_name || ' is locked ' ;
                                                 --fnd_file.put_line(FND_FILE.log,s_message);
                                         END LOOP;
                                         -- GATHER AUTO includes GATHER EMPTY, so gather stats
                                         -- on any unalalyzed tables and/or indexes.
                                         FOR c_rec IN empty_cur_ten(upper(schemaname))
                                         LOOP
                                                 IF c_rec.type             = 'TABLE' THEN
                                                         IF (upper(OPTIONS)='GATHER AUTO') THEN
								 -- changes done for bug 11835452
                                                                 FND_STATS.GATHER_TABLE_STATS(ownname => c_rec.owner,
tabname => c_rec.name, percent => NVL(estimate_percent,def_estimate_pcnt), degree => degree_parallel, partname=>NULL,
CASCADE => TRUE, granularity => granularity, hmode => stathist, invalidate=> invalidate );
                                                         ELSE
                                                                 dlog('Table '
                                                                 ||c_rec.owner
                                                                 ||'.'
                                                                 ||c_rec.name
                                                                 ||' is missing statistics.');
                                                         END IF;
                                                 END IF;
                                         END LOOP;
                                         -- Check if there are any tables in the schema which does not have
                                         -- monitoring enabled. If yes, gather stats for them using 10% and
                                         -- enable monitoring for such tables so that we have data for them
                                         -- in dba_tab_modifications for next time.
                                         FOR c_rec IN nomon_tab(upper(schemaname))
                                         LOOP
                                                 IF (upper(OPTIONS)='GATHER AUTO') THEN
							 -- changes done for bug 11835452
                                                         FND_STATS.GATHER_TABLE_STATS(ownname => c_rec.owner, tabname => c_rec.table_name,
percent => NVL(estimate_percent,def_estimate_pcnt), degree => degree_parallel, partname=>NULL, CASCADE => TRUE,
granularity => granularity, hmode => stathist, invalidate=> invalidate );
                                                         EXECUTE IMMEDIATE 'alter table '
                                                         ||c_rec.owner
                                                         ||'.'
                                                         ||c_rec.table_name
                                                         ||' monitoring';
                                                         dlog('Monitoring has now been enabled for Table '
                                                         ||c_rec.owner
                                                         ||'.'
                                                         ||c_rec.table_name
                                                         ||'. Stats were gathered.' );
                                                 ELSE
                                                         dlog('Monitoring is not enabled for Table '
                                                         ||c_rec.owner
                                                         ||'.'
                                                         ||c_rec.table_name );
                                                 END IF;
                                         END LOOP; -- nomon_tab
                                 elsif ( (upper(OPTIONS)='GATHER EMPTY') OR
                                         (
                                                 upper(OPTIONS)='LIST EMPTY'
                                         )
                                         ) THEN
                                         FOR c_rec IN empty_cur_ten(upper(schemaname))
                                         LOOP
                                                 IF c_rec.type             = 'TABLE' THEN
                                                         IF (upper(OPTIONS)='GATHER EMPTY') THEN
								 -- changes done for bug 11835452
                                                                 FND_STATS.GATHER_TABLE_STATS(ownname => c_rec.owner, tabname => c_rec.name,
percent => NVL(estimate_percent,def_estimate_pcnt), degree => degree_parallel, partname=>NULL, CASCADE => TRUE,
granularity => granularity, hmode => stathist, invalidate=> invalidate );
                                                         ELSE
                                                                 dlog('Table '
                                                                 ||c_rec.owner
                                                                 ||'.'
                                                                 ||c_rec.name
                                                                 ||' is missing statistics! ');
                                                         END IF;
                                                 END IF;
                                         END LOOP;
                                         FOR rec_cur IN lock_stats_tab(upper(schemaname)) -- added by saleem to display warning for tables with locked stats
                                         LOOP
                                                 dbms_output.put_line('stats on table '
                                                 || rec_cur.table_name
                                                 || ' is locked ');
                                                 dlog('stats on table '
                                                 || rec_cur.table_name
                                                 || ' is locked ');
                                                 -- s_message := 'stats on table ' || rec_cur.table_name || ' is locked ' ;
                                                 --fnd_file.put_line(FND_FILE.log,s_message);
                                         END LOOP;
                                 END IF;
				 $END
                                 -- End timestamp
                                 IF(upper(stathist) <> 'NONE') THEN
                                         BEGIN
                                                 FND_STATS.UPDATE_HIST(schemaname=>schemaname, objectname=>schemaname, objecttype=>'SCHEMA', partname=>NULL, columntablename=>NULL, degree=>degree_parallel, upd_ins_flag=>'E' );
                                         END;
                                 END IF;
                         ELSE
                                 /* This is for ALL schema */
                                 FOR c_schema IN schema_cur
                                 LOOP
                                         --dbms_output.put_line('start of schema = '|| c_schema.sname);
                                         -- make a recursive call to gather_schema_stats
					 -- changes done for bug 11835452
                                         GATHER_SCHEMA_STATS(schemaname=>c_schema.sname , estimate_percent=>NVL(estimate_percent,def_estimate_pcnt) , degree=>degree , internal_flag=>internal_flag ,
                                         --Errors=> Errors   ,-- commented for error handling
                                         request_id=>request_id , hmode=>stathist , OPTIONS=>OPTIONS , modpercent=>modpercent , invalidate=> invalidate );
                                 END LOOP;
                                 /* schema_cur */
                         END IF;
                 ELSE -- schema is SYS, print message in log.
                         dlog('Gathering statistics on the SYS schema using FND_STATS is not allowed.');
                         dlog('Please use DBMS_STATS package to gather stats on SYS objects.');
                 END IF; -- end of schema<> SYS
         END;
         /* GATHER_SCHEMA_STATS */
         /************************************************************************/
         /* Procedure: GATHER_INDEX_STATS                                        */
         /* Desciption: Gathers stats for a particular index.                    */
         /************************************************************************/
 PROCEDURE GATHER_INDEX_STATS(ownname     IN VARCHAR2,
                              indname     IN VARCHAR2,
                              percent     IN NUMBER DEFAULT NULL,
                              degree      IN NUMBER DEFAULT NULL,
                              partname    IN VARCHAR2 DEFAULT NULL,
                              backup_flag IN VARCHAR2 ,
                              hmode       IN VARCHAR2 DEFAULT 'LASTRUN',
                              invalidate  IN VARCHAR2 DEFAULT 'Y' )
 IS
         num_blks           NUMBER;
         adj_percent        NUMBER ; -- adjusted percent based on table blocks.
         exist_insufficient EXCEPTION;
         pragma exception_init(exist_insufficient,-20002);
         degree_parallel NUMBER(4) ;
 BEGIN
         -- Set the package body variable.
         stathist := hmode;
         num_blks := fnd_stats.get_blocks(ownname,indname,'INDEX');
         -- In 8i, you cannot provide a degree for an index, in 9iR2 we can.
         IF num_blks            <= SMALL_IND_FOR_PAR_THOLD THEN
                 degree_parallel:=1;
         ELSE
                 IF degree IS NULL THEN
                         degree_parallel:=def_degree;
                 ELSE
                         degree_parallel :=degree;
                 END IF;
         END IF;
         -- For better stats, indexes smaller than small_ind_for_est_thold
         -- should be gathered at 100%.
         IF num_blks         <= SMALL_IND_FOR_EST_THOLD THEN
                 IF ((db_versn>80) AND
                         (
                                 db_versn < 90
                         )
                         ) THEN -- w/a for bug 1998176
                         adj_percent:=99.99;
                 ELSE
                         adj_percent:=100;
                 END IF;
         ELSE
                 adj_percent:=percent;
         END IF;
         -- Insert/update the fnd_stat_hist table
         IF(upper(stathist) <> 'NONE') THEN
                 BEGIN
			 -- changes done for bug 11835452
                         FND_STATS.UPDATE_HIST(schemaname=>upper(ownname), objectname=>upper(indname), objecttype=>'INDEX', partname=>upper(partname), columntablename=>NULL, degree=>degree_parallel,
			 upd_ins_flag=>'S', percent=>NVL(adj_percent,def_estimate_pcnt));
                 END;
         END IF;
         -- backup the existing index stats
         IF ( upper(NVL(backup_flag,'NOBACKUP')) = 'BACKUP' ) THEN
                 -- First create the FND_STATTAB if it doesn't exist.
                 BEGIN
                         FND_STATS.CREATE_STAT_TABLE();
                 EXCEPTION
                 WHEN exist_insufficient THEN
                         NULL;
                 END;
                 DBMS_STATS.EXPORT_INDEX_STATS( ownname, indname, NULL, fnd_stattab, NULL, fnd_statown );
         END IF;
	 -- changes done for bug 11835452
         FND_STATS.GATHER_INDEX_STATS_PVT(ownname => ownname, indname => indname, partname => partname, estimate_percent => NVL(adj_percent,def_estimate_pcnt), degree=>degree_parallel, invalidate => invalidate ) ;
         -- End timestamp
         IF(upper(stathist) <> 'NONE') THEN
                 BEGIN
                         -- update fnd_stats_hist for completed stats
                         FND_STATS.UPDATE_HIST(schemaname=>upper(ownname), objectname=>upper(indname), objecttype=>'INDEX', partname=>upper(partname), columntablename=>NULL, degree=>degree_parallel, upd_ins_flag=>'E' );
                 END;
         END IF;
 END ;
 /* GATHER_INDEX_STATS */
 /************************************************************************/
 /* Procedure: GATHER_TABLE_STATS                                        */
 /* Desciption: Gathers stats for a particular table. Concurrent program */
 /* version.                                                             */
 /************************************************************************/
PROCEDURE GATHER_TABLE_STATS(errbuf OUT NOCOPY  VARCHAR2,
                             retcode OUT NOCOPY VARCHAR2,
                             ownname     IN         VARCHAR2,
                             tabname     IN         VARCHAR2,
                             percent     IN         NUMBER,
                             degree      IN         NUMBER,
                             partname    IN         VARCHAR2,
                             backup_flag IN         VARCHAR2,
                             granularity IN         VARCHAR2,
                             hmode       IN         VARCHAR2 DEFAULT 'LASTRUN',
                             invalidate  IN         VARCHAR2 DEFAULT 'Y' )
IS
        exist_insufficient EXCEPTION;
        pragma exception_init(exist_insufficient,-20000);
        l_message VARCHAR2(1000);
BEGIN
        FND_STATS.GATHER_TABLE_STATS(ownname, tabname, percent, degree, partname, backup_flag, true,
granularity,hmode,invalidate);
EXCEPTION
WHEN exist_insufficient THEN
        errbuf    := sqlerrm ;
        retcode   := '2';
        l_message := errbuf;
        FND_FILE.put_line(FND_FILE.log,l_message);
        raise;
WHEN OTHERS THEN
        errbuf    := sqlerrm ;
        retcode   := '2';
        l_message := errbuf;
        FND_FILE.put_line(FND_FILE.log,l_message);
        raise;
END;
/* GATHER_TABLE_STATS */
/************************************************************************/
/* Procedure: GATHER_TABLE_STATS                                        */
/* Desciption: Gathers stats for a particular table. Called by          */
/* Concurrent program version.                                          */
/************************************************************************/
PROCEDURE GATHER_TABLE_STATS(ownname     IN VARCHAR2,
                             tabname     IN VARCHAR2,
                             percent     IN NUMBER,
                             degree      IN NUMBER,
                             partname    IN VARCHAR2,
                             backup_flag IN VARCHAR2,
                             CASCADE     IN BOOLEAN,
                             granularity IN VARCHAR2,
                             hmode       IN VARCHAR2 DEFAULT 'LASTRUN',
                             invalidate  IN VARCHAR2 DEFAULT 'Y' )
IS
        cascade_true       BOOLEAN := TRUE;
        approx_num_rows    NUMBER ;
        num_blks           NUMBER;
        adj_percent        NUMBER ; -- adjusted percent based on table blocks.
        num_ind_rows       NUMBER;
        obj_type           VARCHAR2(7);
        method             VARCHAR2(2000) ;
        exist_insufficient EXCEPTION;
        pragma exception_init(exist_insufficient,-20002);
        -- New cursor to support MVs
        CURSOR col_cursor (ownname VARCHAR2, tabname VARCHAR2, partname VARCHAR2)
        IS
                SELECT   a.column_name,
                         NVL(a.hsize,254) hsize
                FROM     FND_HISTOGRAM_COLS a
                WHERE    a.table_name = upper(tabname)
                     AND
                         (
                                  a.partition = upper(partname)
                               OR partname IS NULL
                         )
                     AND -- added this condition to fix bug 13779426
                         (
                                  a.owner = ownname
                               OR a.application_id IN
                                   (SELECT c.application_id
                                    FROM FND_ORACLE_USERID b,
                                         FND_PRODUCT_INSTALLATIONS c
                                    WHERE c.oracle_id = b.oracle_id
                                      AND b.oracle_username = ownname)
                         )
                ORDER BY a.column_name;

       CURSOR ind_cursor(ownname VARCHAR2,tabname VARCHAR2)
       IS
               SELECT   a.index_name indname,
                        a.owner indowner    ,
                        a.uniqueness uniq
               FROM     dba_indexes a
               WHERE    table_name = upper(tabname)
                    AND table_owner= upper(ownname)
               ORDER BY index_name;
        -- New cursor for 11g extended stats
	  $IF DBMS_DB_VERSION.VER_LE_9_2 $THEN
	   $ELSE
	  $IF DBMS_DB_VERSION.VER_LE_10_2 $THEN
          $ELSE
	CURSOR  extenstats_cursor (ownname VARCHAR2, tabname VARCHAR2, partname VARCHAR2)
         IS
                SELECT   a.COLUMN_NAME1,
		         a.COLUMN_NAME2,
			 a.COLUMN_NAME3,
			 a.COLUMN_NAME4,
                         NVL(a.hsize,254) hsize
                FROM     FND_EXTNSTATS_COLS a
                WHERE    a.table_name = upper(tabname)
                     AND
                         (
                                  a.partition = upper(partname)
                               OR partname IS NULL
                         )
          ORDER BY a.column_name1;
	  $END
	  $END

      degree_parallel NUMBER(4);
BEGIN
        -- Set the package body variable.
        stathist := hmode;
        num_blks :=fnd_stats.get_blocks(ownname,tabname,'TABLE');
        -- For better performance, tables smaller than small_tab_for_par_thold should be gathered in serial.
        IF num_blks            <= SMALL_TAB_FOR_PAR_THOLD THEN
                degree_parallel:=1;
        elsif degree IS NULL THEN -- degree will not be null when called from gather_schema_stats
                degree_parallel:=def_degree;
        ELSE
                degree_parallel := degree;
        END IF;
        -- For better stats, tables smaller than small_tab_for_est_thold
        -- should be gathered at 100%.
        IF num_blks         <= SMALL_TAB_FOR_EST_THOLD THEN
                IF ((db_versn>80) AND
                        (
                                db_versn < 90
                        )
                        ) THEN -- w/a for bug 1998176
                        adj_percent:=99.99;
                ELSE
                        adj_percent:=100;
                END IF;
        ELSE
                adj_percent:=percent;
        END IF;
        -- Insert/update the fnd_stat_hist table
        -- change to call update_hist for autonomous_transaction
        IF (CASCADE) THEN
                obj_type:='CASCADE';
        ELSE
                obj_type := 'TABLE';
        END IF;
        IF(upper(stathist) <> 'NONE') THEN
                BEGIN
                        --        if(cur_request_id is null) then
                        --         cur_request_id := GET_REQUEST_ID(null); -- for gather table stats, we will not have a request_id
                        --        end if;
			-- changes done for bug 11835452
                        FND_STATS.UPDATE_HIST(schemaname=>ownname, objectname=>tabname, objecttype=>obj_type, partname=>partname, columntablename=>NULL, degree=>degree_parallel, upd_ins_flag=>'S', percent=>NVL(adj_percent,def_estimate_pcnt));
                EXCEPTION
                WHEN OTHERS THEN
                        raise;
                END;
        END IF;
        -- backup the existing table stats
        IF ( upper(NVL(backup_flag,'NOBACKUP')) = 'BACKUP' ) THEN
                BEGIN
                        -- First create the FND_STATTAB if it doesn't exist.
                        BEGIN
                                FND_STATS.CREATE_STAT_TABLE();
                        EXCEPTION
                        WHEN exist_insufficient THEN
                                NULL;
                        END;
                        DBMS_STATS.EXPORT_TABLE_STATS(ownname, tabname, partname, fnd_stattab,NULL,CASCADE,fnd_statown );
                EXCEPTION
                WHEN OTHERS THEN
                        raise;
                END;
        END IF;
        IF (db_versn >= 92) THEN
                --Build up the method_opt if histogram cols are present
                method    := ' FOR COLUMNS ' ;
                FOR c_rec IN col_cursor(ownname,tabname,partname)
                LOOP
                        method := method
                        ||' '
                        || c_rec.column_name
                        ||'  SIZE '
                        || c_rec.hsize ;
                END LOOP;
		dbms_output.put_line(method);
               -- code from this  line to next 55lines is for building method_opt for extnstats
	    $IF DBMS_DB_VERSION.VER_LE_9_2 $THEN
        NULL;
	$ELSE
       $IF DBMS_DB_VERSION.VER_LE_10_2 $THEN
          NULL;
         $ELSE
	--IF (db_versn >= 110) THEN
	   dbms_output.put_line('getting into extended stats');
         --Build up the method_opt if extended stats cols are present
                method    := method ;
                FOR c_rec IN extenstats_cursor(ownname,tabname,partname)
                LOOP
		     method := method ;
                     IF c_rec.COLUMN_NAME3 is NULL THEN
		      method := method
                       || '(' ||' '
                        || c_rec.COLUMN_NAME1 || ','
                        || ' '
                        || c_rec.COLUMN_NAME2
                        || ' '
                        || c_rec.COLUMN_NAME3
                        || ' '
                        || c_rec.COLUMN_NAME4 || ')'
                        ||'  SIZE '
                        || c_rec.hsize ;
			END IF;
              IF c_rec.COLUMN_NAME3 is not null and c_rec.COLUMN_NAME4 is null THEN
                       method := method
                       || '(' ||' '
                        || c_rec.COLUMN_NAME1 || ','
                        || ' '
                        || c_rec.COLUMN_NAME2 || ','
                        || ' '
                        || c_rec.COLUMN_NAME3
                        || ' '
                        || c_rec.COLUMN_NAME4 || ')'
                        ||'  SIZE '
                        || c_rec.hsize ;
                   END IF;
            IF c_rec.COLUMN_NAME3 is not null and c_rec.COLUMN_NAME4 is not null THEN                       method := method
                       || '(' ||' '
                        || c_rec.COLUMN_NAME1 || ','
                        || ' '
                        || c_rec.COLUMN_NAME2 || ','
                        || ' '
                        || c_rec.COLUMN_NAME3 || ','
                        || ' '
                        || c_rec.COLUMN_NAME4 || ')'
                        ||'  SIZE '
                        || c_rec.hsize ;
                   END IF;

                END LOOP;
		$END
		$END
                -- If no histogram cols then  nullify method ;
                IF method       = ' FOR COLUMNS ' THEN
                        method := 'FOR ALL COLUMNS SIZE 1' ;
                END IF;
                IF (method = 'FOR ALL COLUMNS SIZE 1') THEN
                        BEGIN
                                --dbms_output.put_line('SINGLE:'||method||'granularity='||granularity);
				-- changes done for bug 11835452
                                FND_STATS.GATHER_TABLE_STATS_PVT(ownname => ownname, tabname => tabname,
partname => partname, method_opt => method, estimate_percent => NVL(adj_percent,def_estimate_pcnt), degree => degree_parallel,
CASCADE => CASCADE, granularity => granularity, invalidate=> invalidate );
                        EXCEPTION
                        WHEN OTHERS THEN
                                -- dbms_output.put_line('about to raise'||sqlcode||' --- '||sqlerrm);
                                -- Error code for external table error is ora-20000 which is the same as the code
                                -- for exist_insufficient error. Because of that, we have to resort to the following
                                -- if check on the error message.
                                IF(SUBSTR(sqlerrm,instr(sqlerrm,',')+2)= 'sampling on external table is not supported') THEN
                                        NULL; -- Ignore this error because apps does not use External tables.
                                ELSE
                                        raise;
                                END IF;
                        END;
                ELSE -- call it with histogram cols.
                        BEGIN
                                -- dbms_output.put_line('FOR ALL COLUMNS SIZE 1 '||method);
				-- changes done for bug 11835452
                                FND_STATS.GATHER_TABLE_STATS_PVT(ownname => ownname, tabname => tabname, partname => partname, method_opt => 'FOR ALL COLUMNS SIZE 1 '
                                ||method, estimate_percent => NVL(adj_percent,def_estimate_pcnt), degree => degree_parallel, CASCADE => CASCADE, granularity => granularity, invalidate=> invalidate );
                        EXCEPTION
                        WHEN OTHERS THEN
                                raise;
                        END;
                END IF;
        ELSE -- version is pre 9.2, use the old method of calling twice.
                --Build up the method_opt if histogram cols are present
                method    := ' FOR COLUMNS ' ;
                FOR c_rec IN col_cursor(ownname,tabname,partname)
                LOOP
                        IF method      <> ' FOR COLUMNS ' THEN
                                method := method
                                || ',' ;
                        END IF;
                        method := method
                        ||' '
                        || c_rec.column_name
                        ||'  SIZE '
                        || c_rec.hsize ;
                END LOOP;
                -- If no histogram cols then  nullify method ;
                IF method       = ' FOR COLUMNS ' THEN
                        method := 'FOR ALL COLUMNS SIZE 1' ;
                END IF;
                -- Due to the limitations of in DBMS_STATS in 8i we need to call
                -- FND_STATS.GATHER_TABLE_STATS twice, once for histogram
                -- and once for just the table stats.
                IF (method = 'FOR ALL COLUMNS SIZE 1') THEN
                        BEGIN
                                --dbms_output.put_line('SINGLE:'||method||'granularity='||granularity);
				-- changes done for bug 11835452
                                FND_STATS.GATHER_TABLE_STATS_PVT(ownname => ownname, tabname => tabname,
partname => partname, method_opt => method, estimate_percent => NVL(adj_percent,def_estimate_pcnt), degree => degree_parallel,
CASCADE => CASCADE, granularity => granularity, invalidate=> invalidate );
                        EXCEPTION
                        WHEN OTHERS THEN
                                raise;
                        END;
                ELSE -- call it twice
                        BEGIN
                                --dbms_output.put_line('DOUBLE 1:'||method||'granularity='||granularity);
				-- changes done for bug 11835452
                                FND_STATS.GATHER_TABLE_STATS_PVT(ownname => ownname, tabname => tabname,
partname => partname, method_opt => 'FOR ALL COLUMNS SIZE 1', estimate_percent => NVL(adj_percent,def_estimate_pcnt),
degree => degree_parallel, CASCADE => CASCADE, granularity => granularity, invalidate=> invalidate );
                        EXCEPTION
                        WHEN OTHERS THEN
                                raise;
                        END;
                        BEGIN
                                --dbms_output.put_line('DOUBLE 2:'||method||'granularity='||granularity);
				-- changes done for bug 11835452
                                FND_STATS.GATHER_TABLE_STATS_PVT(ownname => ownname, tabname => tabname,
partname => partname, method_opt => method, estimate_percent => NVL(adj_percent,def_estimate_pcnt), degree => degree_parallel,
CASCADE => FALSE, granularity => granularity, invalidate=> invalidate );
                        EXCEPTION
                        WHEN OTHERS THEN
                                raise;
                        END;
                END IF;
        END IF; -- db_versn  is 8i
      /*	-- changes for 11g optimizer
       -- $IF DBMS_DB_VERSION.VER_LE_11 $THEN
       $IF DBMS_DB_VERSION.VER_LE_9_2 $THEN
        NULL;
	$ELSE
       $IF DBMS_DB_VERSION.VER_LE_10_2 $THEN
          NULL;
         $ELSE
	--IF (db_versn >= 110) THEN
         --Build up the method_opt if extended stats cols are present
                method    := ' FOR COLUMNS ' ;
                FOR c_rec IN extenstats_cursor(ownname,tabname,partname)
                LOOP
                         method := method
                        ||' '
                        || c_rec.COLUMN_NAME1
                        || ' '
                        || c_rec.COLUMN_NAME2
                        || ' '
                        || c_rec.COLUMN_NAME3
                        || ' '
                        || c_rec.COLUMN_NAME4
                        ||'  SIZE '
                        || c_rec.hsize ;
                END LOOP;
  IF (method = 'FOR ALL COLUMNS SIZE 1') THEN
     BEGIN
                                -- dbms_output.put_line('FOR ALL COLUMNS SIZE 1 '||method);
				-- changes done for bug 11835452
                                FND_STATS.GATHER_TABLE_STATS_PVT(ownname => ownname, tabname => tabname, partname => partname, method_opt => 'FOR ALL COLUMNS SIZE 1 '
                                ||method, estimate_percent => NVL(adj_percent,def_estimate_pcnt), degree => degree_parallel, CASCADE => CASCADE, granularity => granularity, invalidate=> invalidate );
                        EXCEPTION
                        WHEN OTHERS THEN
                                raise;
                        END;
                END IF;
		--END IF;	--db_versn is 11g
		$END
		$END */
        -- End timestamp
        -- change to call update_hist for autonomous_transaction
        IF(upper(stathist) <> 'NONE') THEN
                BEGIN
                        FND_STATS.UPDATE_HIST(schemaname=>ownname, objectname=>tabname, objecttype=>obj_type, partname=>partname, columntablename=>NULL, degree=>degree_parallel, upd_ins_flag=>'E' );
                EXCEPTION
                WHEN OTHERS THEN
                        raise;
                END;
        END IF;
END ;
/* GATHER_TABLE_STATS */
/************************************************************************/
/* Procedure: GATHER_COLUMN_STATS                                       */
/* Desciption: Gathers stats for all columns in FND_HISTOGRAM_COLS table*/
/************************************************************************/
PROCEDURE GATHER_COLUMN_STATS(appl_id     IN NUMBER DEFAULT NULL,
                              percent     IN NUMBER DEFAULT NULL,
                              degree      IN NUMBER DEFAULT NULL,
                              backup_flag IN VARCHAR2 ,
                              --Errors OUT NOCOPY  Error_Out, -- commented for errorhandling
                              hmode      IN VARCHAR2 DEFAULT 'LASTRUN',
                              invalidate IN VARCHAR2 DEFAULT 'Y' )
IS
        -- New cursor to support MVs
        CURSOR tab_cursor (appl_id NUMBER)
        IS
                SELECT DISTINCT a.application_id,
                                a.table_name    ,
                                a.partition
                FROM            FND_HISTOGRAM_COLS a
                WHERE
                                (
                                                a.application_id = appl_id
                                             OR appl_id IS NULL
                                )
                ORDER BY        a.application_id,
                                a.table_name;

-- New cursor to support MVs
CURSOR col_cursor (appl_id NUMBER, tabname VARCHAR2, partname VARCHAR2)
IS
        SELECT   a.column_name         ,
                 NVL(a.hsize,254) hsize,
                 NVL(a.owner, upper(b.oracle_username)) ownname
        FROM     FND_HISTOGRAM_COLS a,
                 FND_ORACLE_USERID b ,
                 FND_PRODUCT_INSTALLATIONS c
        WHERE    a.application_id = appl_id
             AND a.application_id = c.application_id (+)
             AND c.oracle_id      = b.oracle_id (+)
             AND a.table_name     = upper(tabname)
             AND
                 (
                          a.partition = upper(partname)
                       OR partname IS NULL
                 )
        ORDER BY a.column_name;

exist_insufficient EXCEPTION;
pragma exception_init(exist_insufficient,-20002);
owner VARCHAR2(30);
i BINARY_INTEGER := 0;
method          VARCHAR2(2000);
degree_parallel NUMBER (4);
/* defind variables for the bulk fetch */
TYPE num_list
IS
        TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER;
TYPE char_list
IS
        TABLE OF VARCHAR2(64) INDEX BY BINARY_INTEGER;
        list_column_name char_list;
        list_hsize num_list;
        list_ownname char_list;
BEGIN
        -- Set the package body variable.
        stathist := hmode;
        IF degree IS NULL THEN
                degree_parallel:=def_degree;
        ELSE
                degree_parallel := degree;
        END IF;
        -- Initialize the TABLE Errors
        --Errors(0) := NULL; -- commented for stopping the initialization
        FOR t_rec IN tab_cursor(appl_id)
        LOOP
                method := ' FOR COLUMNS ';
                /* initialize method_opt variable */
                /* Bulk fetch data from col_cursor and loop through it */
                OPEN col_cursor (t_rec.application_id,t_rec.table_name, t_rec.partition);
                FETCH col_cursor BULK COLLECT
                INTO  list_column_name,
                      list_hsize      ,
                      list_ownname;

                CLOSE col_cursor;
                FOR i IN 1..list_column_name.last
                LOOP
                        IF(upper(stathist) <> 'NONE') THEN
                                BEGIN
                                        FND_STATS.UPDATE_HIST(schemaname=>list_ownname(i), objectname=>list_column_name(i), objecttype=>'COLUMN', partname=>t_rec.partition, columntablename=>t_rec.table_name, degree=>degree_parallel, upd_ins_flag=>'S' );
                                END;
                        END IF;
                        -- First export the col stats depending on backup-flag
                        IF ( upper(NVL(backup_flag,'NOBACKUP')) = 'BACKUP') THEN
                                BEGIN
                                        -- First create the FND_STATTAB if it doesn't exist.
                                        BEGIN
                                                FND_STATS.CREATE_STAT_TABLE();
                                        EXCEPTION
                                        WHEN exist_insufficient THEN
                                                NULL;
                                        END;
                                        DBMS_STATS.EXPORT_COLUMN_STATS(list_ownname(i), t_rec.table_name, list_column_name(i), t_rec.partition, fnd_stattab, NULL, fnd_statown);
                                END;
                        END IF;
                        -- Build up the method_opt variable
                        IF (method     <> ' FOR COLUMNS ') THEN
                                method := method
                                || ',';
                        END IF;
                        method := method
                        || list_column_name(i)
                        ||' SIZE '
                        || list_hsize(i);
                        owner := list_ownname(i);
                END LOOP;
                /* end of c_rec */
                BEGIN
			-- changes done for bug 11835452
                        FND_STATS.GATHER_TABLE_STATS_PVT(ownname => owner, tabname => t_rec.table_name,
partname => t_rec.partition, estimate_percent => NVL(percent,def_estimate_pcnt), method_opt => method,
degree => degree_parallel, CASCADE => FALSE, invalidate=> invalidate, stattab => fnd_stattab,
statown => fnd_statown);
                        -- now that histograms are collected update fnd_stats_hist
                        IF(upper(stathist) <> 'NONE') THEN
                                FOR i      IN 1..list_column_name.last
                                LOOP
                                        FND_STATS.UPDATE_HIST(schemaname=>list_ownname(i), objectname=>list_column_name(i), objecttype=>'COLUMN', partname=>t_rec.partition, columntablename=>t_rec.table_name, degree=>degree_parallel, upd_ins_flag=>'E' );
                                END LOOP;
                        END IF;
                EXCEPTION
                WHEN OTHERS THEN
                        g_Errors(i) := 'ERROR: In GATHER_COLUMN_STATS: '
                        ||SQLERRM ;
                        g_Errors(i+1) := NULL;
                        i             := i+1;
                END;
                /* end of FND_STATS.GATHER_TABLE_STATS_PVT call */
        END LOOP;
        /* end of t_rec */
END;
/* end of procedure GATHER_COLUMN_STATS */
/************************************************************************/
/* Procedure: GATHER_ALL_COLUMN_STATS                                   */
/* Desciption: Gathers cols stats for a given schema                    */
/* or if ownname = 'ALL' then for ALL apps schema                       */
/************************************************************************/
PROCEDURE GATHER_ALL_COLUMN_STATS(ownname    IN VARCHAR2,
                                  percent    IN NUMBER DEFAULT NULL,
                                  degree     IN NUMBER DEFAULT NULL,
                                  hmode      IN VARCHAR2 DEFAULT 'LASTRUN',
                                  invalidate IN VARCHAR2 DEFAULT 'Y' )
IS
        -- New cursor for MVs
        CURSOR tab_cursor (ownname VARCHAR2)
        IS
                SELECT DISTINCT a.table_name,
                                a.application_id
                FROM            FND_HISTOGRAM_COLS a,
                                FND_ORACLE_USERID b ,
                                FND_PRODUCT_INSTALLATIONS c
                WHERE
                                (
                                                b.oracle_username= upper(ownname)
                                             OR a.owner          =upper(ownname)
                                )
                            AND a.application_id = c.application_id (+)
                            AND c.oracle_id      = b.oracle_id (+)
                ORDER BY        2 ,
                                1;

CURSOR col_cursor (appl_id NUMBER, tabname VARCHAR2)
IS
        SELECT   column_name,
                 NVL(hsize,254) hsize
        FROM     FND_HISTOGRAM_COLS a
        WHERE    a.application_id = appl_id
             AND a.table_name     = upper(tabname)
        ORDER BY 1 ;

method          VARCHAR2(2000) ;
degree_parallel NUMBER (4);
BEGIN
        -- Set the package body variable.
        stathist := hmode;
        IF degree IS NULL THEN
                degree_parallel:=def_degree;
        ELSE
                degree_parallel := degree;
        END IF;
        -- If a specific schema is given
        IF (upper(ownname) <> 'ALL') THEN
                -- get the tables for the given schema
                FOR t_rec IN tab_cursor(ownname)
                LOOP
                        -- Insert/update the fnd_stats_hist table
                        --dbms_output.put_line('appl_id = '||t_rec.application_id||',table='||t_rec.table_name);
                        IF(upper(stathist) <> 'NONE') THEN
                                BEGIN
                                        FND_STATS.UPDATE_HIST(schemaname=>ownname, objectname=>ownname, objecttype=>'HIST', partname=>NULL, columntablename=>NULL, degree=>degree_parallel, upd_ins_flag=>'S' );
                                END;
                        END IF;
                        -- get the column list and build up the METHOD_OPT
                        method    := ' FOR COLUMNS ';
                        FOR c_rec IN col_cursor(t_rec.application_id, t_rec.table_name)
                        LOOP
                                -- Build up the method_opt variable
                                IF (method     <> ' FOR COLUMNS ') THEN
                                        method := method
                                        || ',';
                                END IF;
                                method := method
                                || c_rec.column_name
                                ||' SIZE '
                                || c_rec.hsize;
                        END LOOP ;
                        /* c_rec */
                        --dbms_output.put_line('     method =  '|| method);
                        BEGIN
				-- changes done for bug 11835452
                                FND_STATS.GATHER_TABLE_STATS_PVT ( ownname => ownname, tabname => t_rec.table_name, estimate_percent => NVL(percent,def_estimate_pcnt),
				method_opt => method, degree => degree_parallel, CASCADE => FALSE, invalidate => invalidate );
                        EXCEPTION
                        WHEN OTHERS THEN
                                raise;
                        END;
                        /* end of FND_STATS.GATHER_TABLE_STATS_PVT call */
                        -- End timestamp
                        IF(upper(stathist) <> 'NONE') THEN
                                BEGIN
                                        FND_STATS.UPDATE_HIST(schemaname=>ownname, objectname=>ownname, objecttype=>'HIST', partname=>NULL, columntablename=>NULL, degree=>degree_parallel, upd_ins_flag=>'E' );
                                END;
                        END IF;
                END LOOP ;
                /* t_rec */
        ELSE
                /* ownname = 'ALL' */
                FOR s_rec IN schema_cur
                LOOP
                        --dbms_output.put_line('start of schema = '|| s_rec.sname);
                        -- get the tables for the given schema
                        FOR t_rec IN tab_cursor(s_rec.sname)
                        LOOP
                                -- Insert/update the fnd_stat_hist table
                                --dbms_output.put_line('appl_id = '||t_rec.application_id||',table='||t_rec.table_name);
                                IF(upper(stathist) <> 'NONE') THEN
                                        BEGIN
                                                FND_STATS.UPDATE_HIST(schemaname=>s_rec.sname, objectname=>s_rec.sname, objecttype=>'HIST', partname=>NULL, columntablename=>NULL, degree=>degree_parallel, upd_ins_flag=>'S' );
                                        END;
                                END IF;
                                -- get the column list and build up the METHOD_OPT
                                method    := ' FOR COLUMNS ';
                                FOR c_rec IN col_cursor(t_rec.application_id, t_rec.table_name)
                                LOOP
                                        -- Build up the method_opt variable
                                        IF (method     <> ' FOR COLUMNS ') THEN
                                                method := method
                                                || ',';
                                        END IF;
                                        method := method
                                        || c_rec.column_name
                                        ||' SIZE '
                                        || c_rec.hsize;
                                END LOOP ;
                                /* c_rec */
                                --dbms_output.put_line('     method =  '|| method);
                                BEGIN
					-- changes done for bug 11835452
                                        FND_STATS.GATHER_TABLE_STATS_PVT ( ownname => s_rec.sname,
tabname => t_rec.table_name, estimate_percent => NVL(percent,def_estimate_pcnt), method_opt => method,
degree => degree_parallel, CASCADE => FALSE, invalidate => invalidate );
                                EXCEPTION
                                WHEN OTHERS THEN
                                        raise;
                                END;
                                /* end of FND_STATS.GATHER_TABLE_STATS_PVT call */
                                -- End timestamp
                                IF(upper(stathist) <> 'NONE') THEN
                                        BEGIN
                                                FND_STATS.UPDATE_HIST(schemaname=>s_rec.sname, objectname=>s_rec.sname, objecttype=>'HIST', partname=>NULL, columntablename=>NULL, degree=>degree_parallel, upd_ins_flag=>'S' );
                                        END;
                                END IF;
                        END LOOP ;
                        /* t_rec */
                END LOOP ;
                /* s_rec */
        END IF ;
        /* end of ownname='ALL' */
END;
/* end of GATHER_ALL_COLUMN_STATS */
/************************************************************************/
/* Procedure: GATHER_ALL_COLUMN_STATS                                   */
/* Desciption: Gathers cols stats for a given schema                    */
/* or if ownname = 'ALL' then for ALL apps schema. This the concurrent  */
/* program manager version                                              */
/************************************************************************/
PROCEDURE GATHER_ALL_COLUMN_STATS(errbuf OUT NOCOPY  VARCHAR2,
                                  retcode OUT NOCOPY VARCHAR2,
                                  ownname    IN         VARCHAR2,
                                  percent    IN         NUMBER DEFAULT NULL,
                                  degree     IN         NUMBER DEFAULT NULL,
                                  hmode      IN         VARCHAR2 DEFAULT 'LASTRUN',
                                  invalidate IN         VARCHAR2 DEFAULT 'Y' )
IS
        l_message VARCHAR2(2000);
BEGIN
        -- Set the package body variable.
        stathist := hmode;
        FND_STATS.GATHER_ALL_COLUMN_STATS(ownname=>ownname,percent=>percent,degree=>degree,hmode=>stathist,invalidate=>invalidate);
EXCEPTION
WHEN OTHERS THEN
        errbuf    := sqlerrm ;
        retcode   := '2';
        l_message := errbuf;
        FND_FILE.put_line(FND_FILE.log,l_message);
        raise;
END;
/* end of conc mgr GATHER_ALL_COLUMN_STATS */
/************************************************************************/
/* Procedure: GATHER_COLUMN_STATS                                       */
/* Desciption: Gathers cols stats This the concurrent program manager   */
/* version                                                              */
/************************************************************************/
PROCEDURE GATHER_COLUMN_STATS(errbuf OUT NOCOPY  VARCHAR2,
                              retcode OUT NOCOPY VARCHAR2,
                              ownname     IN         VARCHAR2,
                              tabname     IN         VARCHAR2,
                              colname     IN         VARCHAR2,
                              percent     IN         NUMBER DEFAULT NULL,
                              degree      IN         NUMBER DEFAULT NULL,
                              hsize       IN         NUMBER DEFAULT 254,
                              backup_flag IN         VARCHAR2 ,
                              partname    IN         VARCHAR2 DEFAULT NULL,
                              hmode       IN         VARCHAR2 DEFAULT 'LASTRUN',
                              invalidate  IN         VARCHAR2 DEFAULT 'Y' )
IS
        exist_insufficient EXCEPTION;
        pragma exception_init(exist_insufficient,-20000);
        l_message VARCHAR2(1000);
BEGIN
        -- Set the package body variable.
        stathist  := hmode;
        l_message := 'In GATHER_COLUMN_STATS , column is '
        || ownname
        ||'.'
        ||tabname
        ||'.'
        ||colname
        ||' backup_flag= '
        || backup_flag ;
        FND_FILE.put_line(FND_FILE.log,l_message);
        dlog(l_message);
        BEGIN
                dlog('about to g c s');
                FND_STATS.GATHER_COLUMN_STATS(ownname,tabname,colname,percent,degree ,hsize,backup_flag,partname,hmode,invalidate);
        EXCEPTION
        WHEN exist_insufficient THEN
                errbuf    := sqlerrm ;
                retcode   := '2';
                l_message := errbuf;
                FND_FILE.put_line(FND_FILE.log,l_message);
                raise;
        WHEN OTHERS THEN
                errbuf    := sqlerrm ;
                retcode   := '2';
                l_message := errbuf;
                FND_FILE.put_line(FND_FILE.log,l_message);
                raise;
        END;
END;
/* end of GATHER_COLUMN_STATS for conc. job */
/************************************************************************/
/* Procedure: GATHER_COLUMN_STATS                                       */
/* Desciption: Gathers cols stats.                                      */
/************************************************************************/
PROCEDURE GATHER_COLUMN_STATS(ownname     IN VARCHAR2,
                              tabname     IN VARCHAR2,
                              colname     IN VARCHAR2,
                              percent     IN NUMBER DEFAULT NULL,
                              degree      IN NUMBER DEFAULT NULL,
                              hsize       IN NUMBER DEFAULT 254,
                              backup_flag IN VARCHAR2 ,
                              partname    IN VARCHAR2 DEFAULT NULL,
                              hmode       IN VARCHAR2 DEFAULT 'LASTRUN',
                              invalidate  IN VARCHAR2 DEFAULT 'Y' )
IS
        method             VARCHAR2(200);
        exist_insufficient EXCEPTION;
        pragma exception_init(exist_insufficient,-20002);
        degree_parallel NUMBER (4);
BEGIN
        dlog('about to g c s no cm version');
        -- Set the package body variable.
        stathist := hmode;
        IF degree IS NULL THEN
                degree_parallel:=def_degree;
        ELSE
                degree_parallel := degree;
        END IF;
        -- Insert/update the fnd_stat_hist table
        IF(upper(stathist) <> 'NONE') THEN
                BEGIN
                        FND_STATS.UPDATE_HIST(schemaname=>ownname, objectname=>colname, objecttype=>'COLUMN', partname=>partname, columntablename=>tabname, degree=>degree_parallel, upd_ins_flag=>'S' );
                END;
        END IF;
        -- First export the col stats depending on the backup_flag
        IF ( upper(NVL(backup_flag,'NOBACKUP')) = 'BACKUP' ) THEN
                BEGIN
                        -- First create the FND_STATTAB if it doesn't exist.
                        BEGIN
                                FND_STATS.CREATE_STAT_TABLE();
                        EXCEPTION
                        WHEN exist_insufficient THEN
                                NULL;
                        END;
                        DBMS_STATS.EXPORT_COLUMN_STATS ( ownname, tabname, colname, partname, fnd_stattab, NULL, fnd_statown );
                END;
        END IF;
        -- Now gather statistics
        method := 'FOR COLUMNS SIZE '
        || hsize
        || ' '
        || colname;
	-- changes done for bug 11835452
        FND_STATS.GATHER_TABLE_STATS_PVT ( ownname => ownname, tabname => tabname, partname =>partname,
estimate_percent => NVL(percent,def_estimate_pcnt), method_opt => method, degree => degree_parallel, CASCADE => FALSE,
stattab => fnd_stattab, statown => fnd_statown, invalidate => invalidate);
        -- End timestamp
        IF(upper(stathist) <> 'NONE') THEN
                BEGIN
                        FND_STATS.UPDATE_HIST(schemaname=>ownname, objectname=>colname, objecttype=>'COLUMN', partname=>NULL, columntablename=>tabname, degree=>degree_parallel, upd_ins_flag=>'E' );
                END;
        END IF;
END;
/* GATHER_COLUMN_STATS */
/************************************************************************/
/* Procedure: SET_TABLE_STATS                                           */
/* Desciption: Sets table stats to certain values.                      */
/************************************************************************/
PROCEDURE SET_TABLE_STATS(ownname  IN VARCHAR2,
                          tabname  IN VARCHAR2,
                          numrows  IN NUMBER,
                          numblks  IN NUMBER,
                          avgrlen  IN NUMBER,
                          partname IN VARCHAR2 DEFAULT NULL )
IS
        --  PRAGMA AUTONOMOUS_TRANSACTION ;
BEGIN
        DBMS_STATS.SET_TABLE_STATS(ownname, tabname, partname, NULL, NULL, numrows, numblks, avgrlen, NULL, NULL);
END;
/* SET_TABLE_STATS */
/************************************************************************/
/* Procedure: SET_INDEX_STATS                                           */
/* Desciption: Sets index stats to certain values.                      */
/************************************************************************/
PROCEDURE SET_INDEX_STATS(ownname  IN VARCHAR2,
                          indname  IN VARCHAR2,
                          numrows  IN NUMBER,
                          numlblks IN NUMBER,
                          numdist  IN NUMBER,
                          avglblk  IN NUMBER,
                          avgdblk  IN NUMBER,
                          clstfct  IN NUMBER,
                          indlevel IN NUMBER,
                          partname IN VARCHAR2 DEFAULT NULL)
IS
        l_iot     VARCHAR2(5):='FALSE';
        l_clstfct NUMBER     :=clstfct;
BEGIN
        /* add this to fix bug # .....
        when the index is of type IOT, set clustering factor to zero
        */
        /* added to fix bug 2239903 */
        SELECT DECODE(index_type,'IOT - TOP', 'TRUE', 'FALSE')
        INTO   l_iot
        FROM   dba_indexes
        WHERE  owner      = ownname
           AND index_name = indname;

        IF (l_iot          = 'TRUE') THEN
                l_clstfct := 0;
        END IF;
        DBMS_STATS.SET_INDEX_STATS(ownname, indname, partname, NULL, NULL, numrows, numlblks, numdist, avglblk, avgdblk, l_clstfct, indlevel, NULL, NULL);
EXCEPTION
WHEN OTHERS THEN
        NULL;
END;
/* SET_INDEX_STATS */
/******************************************************************************/
/* Procedure: LOAD_XCLUD_TAB                                                  */
/* Desciption: This procedure was deprecated, but 11.5.2CU2 onwards           */
/*             we are reuseing it for a different purpose. This procedure     */
/*             will be used to populate fnd_exclude_table_stats table , which */
/*             which contains the list of tables which should be skipped      */
/*             by the gather schema stats program.                            */
/******************************************************************************/
PROCEDURE LOAD_XCLUD_TAB(action  IN VARCHAR2,
                         appl_id IN NUMBER,
                         tabname IN VARCHAR2)
IS
        exist_flag VARCHAR2(6) := NULL;
BEGIN
        IF ((Upper(action) = 'INSERT') OR
                (
                        Upper(action) = 'INS'
                )
                OR
                (
                        Upper(action) = 'I'
                )
                ) THEN
                -- Check for existence of the table first in FND Dictionary
                -- then in data dictionary
                -- break out if it doesn't exist
                BEGIN
                        SELECT 'EXIST'
                        INTO   exist_flag
                        FROM   fnd_tables a
                        WHERE  a.table_name     = upper(tabname)
                           AND a.application_id = appl_id ;

                EXCEPTION
                WHEN no_data_found THEN
                        BEGIN
                                SELECT 'EXIST'
                                INTO   exist_flag
                                FROM   dba_tables
                                WHERE  table_name = upper(tabname)
                                   AND owner      =
                                       ( SELECT b.oracle_username
                                       FROM    fnd_product_installations a,
                                               fnd_oracle_userid b
                                       WHERE   a.application_id = appl_id
                                           AND b.oracle_id      = a.oracle_id
                                       );

                        EXCEPTION
                        WHEN no_data_found THEN
                                raise_application_error(-20000, 'Table '
                                || tabname
                                || ' does not exist in fnd_tables/dba_tables for the
given application ');
                        END;
                END;
                -- Now insert
                INSERT
                INTO   FND_EXCLUDE_TABLE_STATS
                       (
                              APPLICATION_ID  ,
                              TABLE_NAME      ,
                              CREATION_DATE   ,
                              CREATED_BY      ,
                              LAST_UPDATE_DATE,
                              LAST_UPDATED_BY ,
                              LAST_UPDATE_LOGIN
                       )
                       VALUES
                       (
                              appl_id       ,
                              upper(tabname),
                              sysdate       ,
                              1             ,
                              sysdate       ,
                              1             ,
                              NULL
                       ) ;

        elsif ((Upper(action) = 'DELETE') OR
                (
                        Upper(action) = 'DEL'
                )
                OR
                (
                        Upper(action) = 'D'
                )
                ) THEN
                DELETE
                FROM   FND_EXCLUDE_TABLE_STATS
                WHERE  table_name     = upper(tabname)
                   AND application_id = appl_id;

        END IF;
        COMMIT;
END;
/* LOAD_XCLUD_TAB */
/************************************************************************/
/* Procedure: LOAD_HISTOGRAM_COLS                                       */
/* Desciption: This is for internal purpose only. For loading into      */
/* SEED database                                                        */
/************************************************************************/
PROCEDURE LOAD_HISTOGRAM_COLS(action      IN VARCHAR2,
                              appl_id     IN NUMBER,
                              tabname     IN VARCHAR2,
                              colname     IN VARCHAR2,
                              partname    IN VARCHAR2 DEFAULT NULL,
                              hsize       IN NUMBER DEFAULT 254,
                              commit_flag IN VARCHAR2 DEFAULT 'Y')
IS
        exist_flag VARCHAR2(5) := NULL;
BEGIN
        IF upper(action) = 'INSERT' THEN
                 BEGIN
                        -- Check for existence of the table first
                        -- break out if it doesn't exist
                        BEGIN
                                SELECT DISTINCT('EXIST')
                                INTO            exist_flag
                                FROM            dba_tab_columns a  ,
                                                fnd_oracle_userid b,
                                                fnd_product_installations c
                                WHERE           a.table_name     = upper(tabname)
                                            AND a.column_name    = upper(colname)
                                            AND c.application_id = appl_id
                                            AND c.oracle_id      = b.oracle_id
                                            AND a.owner          = b.oracle_username;

                        EXCEPTION
                        WHEN no_data_found THEN
                                raise_application_error(-20000, 'Column '
                                || tabname
                                ||'.'
                                || colname
                                || ' does not exist in dba_tab_columns for the given application ');
                        WHEN OTHERS THEN
                                raise_application_error(-20001, 'Error in reading dictionary info. for column  '
                                || tabname
                                ||'.'
                                || colname );
                        END;
                        BEGIN
                                INSERT
                                INTO   FND_HISTOGRAM_COLS
                                       (
                                              APPLICATION_ID  ,
                                              TABLE_NAME      ,
                                              COLUMN_NAME     ,
                                              PARTITION       ,
                                              HSIZE           ,
                                              CREATION_DATE   ,
                                              CREATED_BY      ,
                                              LAST_UPDATE_DATE,
                                              LAST_UPDATED_BY ,
                                              LAST_UPDATE_LOGIN
                                       )
                                       VALUES
                                       (
                                              appl_id        ,
                                              upper(tabname) ,
                                              upper(colname) ,
                                              upper(partname),
                                              hsize          ,
                                              sysdate        ,
                                              1              ,
                                              sysdate        ,
                                              1              ,
                                              NULL
                                       ) ;

                        EXCEPTION
                        WHEN DUP_VAL_ON_INDEX THEN
                                NULL;
                        END;
                END;
        elsif upper(action) = 'DELETE' THEN
                BEGIN
                        DELETE
                        FROM   FND_HISTOGRAM_COLS
                        WHERE  application_id = appl_id
                           AND table_name     = upper(tabname)
                           AND column_name    = upper(colname)
                           AND
                               (
                                      partition = upper(partname)
                                   OR partition IS NULL
                               );

                END;
        END IF;
        IF ( commit_flag = 'Y') THEN
                /* for remote db operation */
                COMMIT;
        END IF;
END;
/* LOAD_HISTOGRAM_COLS */
/************************************************************************/
/* Procedure: LOAD_HISTOGRAM_COLS                                       */
/* Desciption: This is for internal purpose only. For loading into      */
/* SEED database                                                        */
/************************************************************************/
PROCEDURE LOAD_HISTOGRAM_COLS_MV(action      IN VARCHAR2,
                                 ownername   IN VARCHAR2,
                                 tabname     IN VARCHAR2,
                                 colname     IN VARCHAR2,
                                 partname    IN VARCHAR2 DEFAULT NULL,
                                 hsize       IN NUMBER DEFAULT 254,
                                 commit_flag IN VARCHAR2 DEFAULT 'Y')
IS
        exist_flag VARCHAR2(5) := NULL;
BEGIN
        IF upper(action) = 'INSERT' THEN
                BEGIN
                        -- Check for existence of the table first
                        -- break out if it doesn't exist
                        BEGIN
                                SELECT DISTINCT('EXIST')
                                INTO            exist_flag
                                FROM            dba_tab_columns a
                                WHERE           a.table_name  = upper(tabname)
                                            AND a.column_name = upper(colname)
                                            AND a.owner       = upper(ownername);

                        EXCEPTION
                        WHEN no_data_found THEN
                                raise_application_error(-20000, 'Column '
                                || tabname
                                ||'.'
                                || colname
                                || ' does not exist in dba_tab_columns for the given owner ');
                        WHEN OTHERS THEN
                                raise_application_error(-20001, 'Error in reading dictionary info. for column  '
                                || tabname
                                ||'.'
                                || colname );
                        END;
                        BEGIN
                                INSERT
                                INTO   FND_HISTOGRAM_COLS
                                       (
                                              application_id  ,
                                              OWNER           ,
                                              TABLE_NAME      ,
                                              COLUMN_NAME     ,
                                              PARTITION       ,
                                              HSIZE           ,
                                              CREATION_DATE   ,
                                              CREATED_BY      ,
                                              LAST_UPDATE_DATE,
                                              LAST_UPDATED_BY ,
                                              LAST_UPDATE_LOGIN
                                       )
                                       VALUES
                                       (
                                              -1              ,
                                              upper(ownername),
                                              upper(tabname)  ,
                                              upper(colname)  ,
                                              upper(partname) ,
                                              hsize           ,
                                              sysdate         ,
                                              1               ,
                                              sysdate         ,
                                              1               ,
                                              NULL
                                       ) ;

                        EXCEPTION
                        WHEN DUP_VAL_ON_INDEX THEN
                                NULL;
                        END;
                END;
        elsif upper(action) = 'DELETE' THEN
                BEGIN
                        DELETE
                        FROM   FND_HISTOGRAM_COLS
                        WHERE  owner       = upper(ownername)
                           AND table_name  = upper(tabname)
                           AND column_name = upper(colname)
                           AND
                               (
                                      partition = upper(partname)
                                   OR partition IS NULL
                               );

                END;
        END IF;
        IF ( commit_flag = 'Y') THEN
                /* for remote db operation */
                COMMIT;
        END IF;
END;
/* LOAD_HISTOGRAM_COLS_MV */
/************************************************************************/
/* Procedure: LOAD_XCLUD_STATS                                          */
/* Desciption: This will artificially pump the                          */
/*  stats with some value so that the CBO                               */
/* goes for index scans instead of full table scans.  The idea behind   */
/* this is that during a gather_schema_stats the interface tables may   */
/* not have data and hence the stats for such tables will be of no use  */
/* and hence we need to pump some artificial stats for such tables.     */
/* Ideally a customer has to run gather_table_stats on the interface    */
/* tables after populating with data. This will give them accurate data.*/
/* A good methodology would be gather_table_stats once for the interface*/
/* table populated with good ammount of data and for all the consecutive*/
/* runs use restore_table_data procedure to restore the stats.          */
/* The simplified algorith for calculations are:                        */
/* BLOCKS = num_rows*1/20,                                              */
/* AVG_ROW_LENGTH = 50% of Total max row_length                         */
/* Clustering factor = num. of blocks                                   */
/* num. of leaf blks =                                                  */
/*      (cardinality)/((db_block_size -overhead 200)/key_size)          */
/*     revised to the following as per Amozes to alway prefer index scan*/
/* num. of leaf blks = 100/num of table blks                            */
/* index_level = 1                                                      */
/* Distinct keys = num of rows                                          */
/************************************************************************/
PROCEDURE LOAD_XCLUD_STATS(schemaname IN VARCHAR2)
IS
BEGIN
        -- This procedure has been deprecated. Stub is being retained for now
        -- so that it does not break compilation in case it is still being called.
        NULL;
END ;
/* LOAD_XCLUD_STATS  */
/************************************************************************/
/* Procedure: LOAD_XCLUD_STATS                                          */
/* Desciption: This one is for a particular INTERFACE TABLE             */
/************************************************************************/
PROCEDURE LOAD_XCLUD_STATS(schemaname IN VARCHAR2,
                           tablename  IN VARCHAR2)
IS
BEGIN
        -- This procedure has been deprecated. Stub is being retained for now
        -- so that it does not break compilation in case it is still being called.
        NULL;
END ;
/* LOAD_XCLUD_STATS  */
/************************************************************************/
/* Procedure: CHECK_HISTOGRAM_COLS                                      */
/* Desciption: For a given list of comma seperated tables,              */
/*  this procedure checks the                                           */
/*   data in all the leading columns of all the non-unique indexes of   */
/*   those tables and figures out if histogram needs to be created for  */
/*   those columns. The algorithm is as follows :                       */
/*   select decode(floor(sum(tot)/(max(cnt)*75)),0,'YES','NO') HIST     */
/*   from (select count(col) cnt , count(*) tot                         */
/*         from tab sample (S)                                          */
/*         where col is not null                                        */
/*         group by col);                                               */
/*   The decode says whether or not a single value occupies 1/75th or   */
/*   more of the sample.                                                */
/*   If sum(cnt) is very small (a small non-null sample), the results   */
/*   may be inaccurate. A count(*) of atleast 3000 is recommended .     */
/************************************************************************/
PROCEDURE CHECK_HISTOGRAM_COLS(tablelist IN VARCHAR2,
                               factor    IN INTEGER,
                               percent   IN NUMBER,
                               degree    IN NUMBER DEFAULT NULL)
IS
BEGIN
        DECLARE
                CURSOR column_cur(tname VARCHAR2)
                IS
                        SELECT DISTINCT column_name col ,
                                        b.table_name tab,
                                        b.table_owner own
                        FROM            dba_ind_columns a,
                                        dba_indexes b
                        WHERE           b.table_owner = upper(SUBSTR(tname,1,instr(tname,'.')-1))
                                    AND
                                        (
                                                        b.table_name = upper(SUBSTR(tname,instr(tname,'.')+1))
                                                     OR b.table_name LIKE upper(SUBSTR(tname,instr(tname,'.')+1))
                                        )
                                    AND b.uniqueness      = 'NONUNIQUE'
                                    AND b.index_type      = 'NORMAL'
                                    AND a.index_owner     = b.owner
                                    AND a.index_name      = b.index_name
                                    AND a.column_position = 1
                        ORDER BY        3 ,
                                        2 ,
                                        1 ;

TYPE List
IS
        TABLE OF VARCHAR2(62) INDEX BY BINARY_INTEGER;
        Table_List List;
        MAX_NOF_TABLES NUMBER  := 32768;
        table_counter  INTEGER := 0 ;
        sql_string     VARCHAR2(2000);
        mytablelist    VARCHAR2(4000);
        hist           VARCHAR2(3);
        abs_tablename  VARCHAR2(61);
        total_cnt      INTEGER;
        max_cnt        INTEGER;
BEGIN
        -- initialize Table_list
        Table_List(0) := NULL;
        mytablelist   := REPLACE(tablelist,' ','');
        IF (percent    < 0 OR percent > 100) THEN
                raise_application_error(-20001,'percent must be between 0 and 100');
        END IF;
        dbms_output.put_line('Table-Name                                   Column-Name                   Histogram Tot-Count  Max-Count');
        dbms_output.put_line('==========================================================================================================');
        WHILE (instr(mytablelist,',') > 0)
        LOOP
                Table_List(table_counter)   := SUBSTR(mytablelist,1,instr(mytablelist,',') - 1) ;
                Table_List(table_counter+1) := NULL;
                table_counter               := table_counter + 1;
                mytablelist                 := SUBSTR(mytablelist,instr(mytablelist,',')+1) ;
                EXIT
        WHEN table_counter = MAX_NOF_TABLES;
        END LOOP;
        -- This gets the last table_name in a comma separated list
        Table_List(table_counter)   := mytablelist ;
        Table_List(table_counter+1) := NULL;
        FOR i                       IN 0..MAX_NOF_TABLES
        LOOP
                EXIT
        WHEN Table_List(i) IS NULL;
                FOR c_rec IN column_cur(Table_List(i))
                LOOP
                        --Build up the dynamic sql
                        sql_string := 'select ';
                        sql_string := sql_string
                        || '/*+ PARALLEL (tab,';
                        sql_string := sql_string
                        || degree
                        || ') */';
                        sql_string := sql_string
                        || ' decode(floor(sum(tot)/(max(cnt)*'
                        ||factor
                        ||')),0,''YES'',''NO'') , nvl(sum(tot),0), nvl(max(cnt),0) ';
                        sql_string := sql_string
                        || ' from (select count('
                        ||c_rec.col
                        ||') cnt, count(*) tot from ';
                        sql_string := sql_string
                        || c_rec.own
                        ||'.'
                        ||c_rec.tab
                        || ' sample (';
                        sql_string := sql_string
                        || percent
                        ||') tab ';
                        sql_string := sql_string
                        || ' group by '
                        ||c_rec.col
                        ||' )' ;
                        BEGIN
                                EXECUTE IMMEDIATE sql_string INTO hist,total_cnt,max_cnt;
                        EXCEPTION
                        WHEN zero_divide THEN
                                hist := 'NO';
                        END;
                        abs_tablename := c_rec.own
                        ||'.'
                        ||c_rec.tab;
                        dbms_output.put_line(rpad(upper(abs_tablename),40,' ')
                        ||rpad(c_rec.col,30,' ')
                        || rpad(hist,10,' ')
                        ||lpad(TO_CHAR(total_cnt),9,' ')
                        ||lpad(TO_CHAR(max_cnt),9,' '));
                END LOOP;
        END LOOP;
END;
END ;
/* end of CHECK_HISTOGRAM_COLS */
/************************************************************************/
/* Procedure: ANALYZE_ALL_COLUMNS                                       */
/* Desciption: This is to create histograms on all leading cols of      */
/* non-unique indexes of all the tables in a given schema               */
/************************************************************************/
PROCEDURE ANALYZE_ALL_COLUMNS(ownname IN VARCHAR2,
                              percent IN NUMBER,
                              hsize   IN NUMBER,
                              hmode   IN VARCHAR2 DEFAULT 'LASTRUN' )
IS
BEGIN
        -- This procedure has been deprecated. Stub is being retained for now
        -- so that it does not break compilation in case it is still being called.
        NULL;
END;
/*end of ANALYZE_ALL_COLUMNS*/
/************************************************************************/
/* Procedure: ANALYZE_ALL_COLUMNS                                       */
/* Desciption: conc. job version of ANALYZE_ALL_COLUMNS                 */
/************************************************************************/
PROCEDURE ANALYZE_ALL_COLUMNS(errbuf OUT NOCOPY  VARCHAR2,
                              retcode OUT NOCOPY VARCHAR2,
                              ownname IN         VARCHAR2,
                              percent IN         NUMBER ,
                              hsize   IN         NUMBER ,
                              hmode   IN         VARCHAR2 DEFAULT 'LASTRUN' )
IS
BEGIN
        -- This procedure has been deprecated. Stub is being retained for now
        -- so that it does not break compilation in case it is still being called.
        NULL;
END;
/* end of ANALYZE_ALL_COLUMNS */
/************************************************************************/
/* Procedure: UPDATE_HIST                                               */
/* Desciption: Internal procedure to insert or update entries in table  */
/* fnd_stats_hist. These values are used later if restartability is     */
/* needed.                                                              */
/************************************************************************/
PROCEDURE UPDATE_HIST(schemaname    VARCHAR2,
                      objectname      IN VARCHAR2,
                      objecttype      IN VARCHAR2,
                      partname        IN VARCHAR2,
                      columntablename IN VARCHAR2,
                      degree          IN NUMBER,
                      upd_ins_flag    IN VARCHAR2,
                      percent         IN NUMBER)
IS
        PRAGMA AUTONOMOUS_TRANSACTION ;
        cascade_true VARCHAR2(1);
unique_constraint_detected  EXCEPTION;
PRAGMA EXCEPTION_INIT(unique_constraint_detected , -00001);
BEGIN
        -- if request_id is null then we cannot do it in FULL mode, defaults to LASTRUN
        --- if(stathist='FULL') then
        --- stathist:='LASTRUN';
        --- end if;
        IF(stathist = 'LASTRUN') THEN -- retaining the old behavior as default
                -- S (Start) is when the entry is already in fnd_stats_hist and statistics
                -- were gathering is going to start for that particular object
                IF (upd_ins_flag = 'S') THEN
                        UPDATE FND_STATS_HIST
                        SET    parallel               = degree        ,
                               request_id             = cur_request_id,
                               request_type           = request_from  ,
                               last_gather_start_time = sysdate       ,
                               last_gather_date       = ''            ,
                               last_gather_end_time   = ''            ,
                               est_percent            =percent
                        WHERE  schema_name            = upper(schemaname)
                           AND object_name            = upper(objectname)
                           AND
                               (
                                      partition = upper(partname)
                                   OR partname IS NULL
                               )
                           AND
                               (
                                      column_table_name = upper(columntablename)
                                   OR columntablename IS NULL
                               )
                           AND object_type = upper(objecttype)
                               --    and request_id=cur_request_id -- commented this line for the bug 5648754
                           AND history_mode='L';
                        /* Added by mo, this segment checks if an entry was updated or not.
                        If not, a new entry will be added. */
                        IF SQL%ROWCOUNT = 0 THEN
                                INSERT
                                INTO   FND_STATS_HIST
                                       (
                                              SCHEMA_NAME           ,
                                              OBJECT_NAME           ,
                                              OBJECT_TYPE           ,
                                              PARTITION             ,
                                              COLUMN_TABLE_NAME     ,
                                              LAST_GATHER_DATE      ,
                                              LAST_GATHER_START_TIME,
                                              LAST_GATHER_END_TIME  ,
                                              PARALLEL              ,
                                              REQUEST_ID            ,
                                              REQUEST_type          ,
                                              HISTORY_MODE          ,
                                              EST_PERCENT
                                       )
                                       VALUES
                                       (
                                              upper(schemaname),
                                              upper(objectname),
                                              upper(objecttype),
                                              upper(partname)  ,
                                              columntablename  ,
                                              ''               ,
                                              sysdate          ,
                                              ''               ,
                                              degree           ,
                                              cur_request_id   ,
                                              request_from     ,
                                              'L'              ,
                                              percent
                                       );
                        END IF;
                END IF;
                -- E (End) is when the entry is already in fnd_stats_hist and statistics
                -- gathering finished successfully for that particular object
                IF (upd_ins_flag = 'E') THEN
                        UPDATE FND_STATS_HIST
                        SET    last_gather_date     = sysdate,
                               last_gather_end_time = sysdate
                        WHERE  schema_name          = upper(schemaname)
                           AND object_name          = upper(objectname)
                           AND
                               (
                                      partition = upper(partname)
                                   OR partname IS NULL
                               )
                           AND
                               (
                                      column_table_name = upper(columntablename)
                                   OR columntablename IS NULL
                               )
                           AND object_type = upper(objecttype)
                           AND request_id  =cur_request_id
                           AND history_mode='L';
                END IF;
        elsif (stathist          = 'FULL') THEN -- new option, old hist will not be updated
                IF (upd_ins_flag = 'S') THEN
                        UPDATE FND_STATS_HIST
                        SET    parallel               = degree        ,
                               request_id             = cur_request_id,
                               request_type           = request_from  ,
                               last_gather_start_time = sysdate       ,
                               last_gather_date       = ''            ,
                               last_gather_end_time   = ''            ,
                               est_percent            =percent
                        WHERE  schema_name            = upper(schemaname)
                           AND object_name            = upper(objectname)
                           AND
                               (
                                      partition = upper(partname)
                                   OR partname IS NULL
                               )
                           AND
                               (
                                      column_table_name = upper(columntablename)
                                   OR columntablename IS NULL
                               )
                           AND object_type = upper(objecttype)
                           AND history_mode='F' -- F for FULL mode
                           AND request_id  =cur_request_id;

                        -- commenting out because it is not part of unique cons criteria
                        -- and request_type=request_from;
                        /* This segment checks if an entry was updated or not. This is still required even for
                        FULL mode, because multiple calls for the same object from the same session will have
                        the same cur_request_id. If not, a new entry will be added. */
                        IF SQL%ROWCOUNT = 0 THEN
                                INSERT
                                INTO   FND_STATS_HIST
                                       (
                                              SCHEMA_NAME           ,
                                              OBJECT_NAME           ,
                                              OBJECT_TYPE           ,
                                              PARTITION             ,
                                              COLUMN_TABLE_NAME     ,
                                              LAST_GATHER_DATE      ,
                                              LAST_GATHER_START_TIME,
                                              LAST_GATHER_END_TIME  ,
                                              PARALLEL              ,
                                              REQUEST_ID            ,
                                              REQUEST_type          ,
                                              HISTORY_MODE          ,
                                              EST_PERCENT
                                       )
                                       VALUES
                                       (
                                              upper(schemaname),
                                              upper(objectname),
                                              upper(objecttype),
                                              upper(partname)  ,
                                              columntablename  ,
                                              ''               ,
                                              sysdate          ,
                                              ''               ,
                                              degree           ,
                                              cur_request_id   ,
                                              request_from     ,
                                              'F'              ,
                                              percent
                                       );

                        END IF;
                END IF;
                -- E (End) is when the entry is already in fnd_stats_hist and statistics
                -- gathering finished successfully for that particular object
                IF (upd_ins_flag = 'E') THEN
                        UPDATE FND_STATS_HIST
                        SET    last_gather_date     = sysdate,
                               last_gather_end_time = sysdate
                        WHERE  schema_name          = upper(schemaname)
                           AND object_name          = upper(objectname)
                           AND
                               (
                                      partition = upper(partname)
                                   OR partname IS NULL
                               )
                           AND
                               (
                                      column_table_name = upper(columntablename)
                                   OR columntablename IS NULL
                               )
                           AND object_type = upper(objecttype)
                           AND history_mode='F'
                           AND request_id  =cur_request_id;

                        -- commenting out because it is not part of unique cons criteria
                        -- and request_type=request_from;
                END IF;
        END IF;
        COMMIT;
EXCEPTION
when unique_constraint_detected then
delete from fnd_stats_hist where object_name like upper(objectname) and schema_name like upper(schemaname);
            commit;
END;
/* end of UPDATE_HIST */
/************************************************************************/
/* Procedure: PURGE_STAT_HISTORY                                        */
/* Desciption: Purges the fnd_stat_hist table based on the FROM_REQ_ID  */
/* and TO_REQ_ID provided.                                              */
/************************************************************************/
PROCEDURE PURGE_STAT_HISTORY(from_req_id IN NUMBER,
                             to_req_id   IN NUMBER)
IS
        PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
        DELETE
        FROM   fnd_stats_hist
        WHERE  request_id BETWEEN from_req_id AND to_req_id;

        COMMIT;
END;
/************************************************************************/
/* Procedure: PURGE_STAT_HISTORY                                        */
/* Desciption: Purges the fnd_stat_hist table based on the FROM_DATE    */
/* and TO_DATE provided. Date should be provided in DD-MM-YY format    */
/************************************************************************/
PROCEDURE PURGE_STAT_HISTORY(purge_from_date IN VARCHAR2,
                             purge_to_date   IN VARCHAR2)
IS
        PRAGMA AUTONOMOUS_TRANSACTION;
        purge_from_date_l VARCHAR2(15);
        purge_to_date_l   VARCHAR2(15);
BEGIN
        -- If from_date is null then from_date is sysdate-One year
        IF (purge_from_date IS NULL ) THEN
                purge_from_date_l:=TO_CHAR(sysdate-365,'DD-MM-YY');
        ELSE
                purge_from_date_l:=purge_from_date;
        END IF;
        -- If to_date is null then to_date is sysdate-One week
        IF (purge_to_date IS NULL ) THEN
                purge_to_date_l:=TO_CHAR(sysdate-7,'DD-MM-YY');
        ELSE
                purge_to_date_l:=purge_to_date;
        END IF;
        DELETE
        FROM   fnd_stats_hist
        WHERE  last_gather_date BETWEEN to_date(purge_from_date_l,'DD-MM-YY') AND to_date(purge_to_date_l,'DD-MM-YY');

        COMMIT;
END;
/**************************************************************************/
/* Procedure: PURGE_STAT_HISTORY Conc Program version                     */
/* Desciption: Purges the fnd_stat_hist table based on the Mode parameter.*/
/**************************************************************************/
PROCEDURE PURGE_STAT_HISTORY(errbuf OUT NOCOPY  VARCHAR2,
                             retcode OUT NOCOPY VARCHAR2,
                             purge_mode IN      VARCHAR2,
                             from_value IN      VARCHAR2,
                             to_value   IN      VARCHAR2 )
IS
BEGIN
        IF upper(purge_mode) = 'DATE' THEN
                PURGE_STAT_HISTORY(from_value,to_value);
        elsif upper(purge_mode)='REQUEST' THEN
                PURGE_STAT_HISTORY(to_number(from_value),to_number(to_value));
        END IF;
EXCEPTION
WHEN OTHERS THEN
        errbuf  := sqlerrm ;
        retcode := '2';
        FND_FILE.put_line(FND_FILE.log,errbuf);
        raise;
END;
/************************************************************************/
/* Procedure: table_stats                                               */
/* Desciption: Internal procedures used by verify_stats. Gets info about*/
/* table stats.                                                         */
/************************************************************************/
PROCEDURE table_stats(schema    VARCHAR2,
                      tableName VARCHAR2)
IS
        last_analyzed dba_tables.last_analyzed%type;
        sample_size dba_tables.sample_size%type;
        num_rows dba_tables.num_rows%type;
        blocks dba_tables.blocks%type;
BEGIN
        SELECT last_analyzed  ,
               sample_size    ,
               TRUNC(num_rows),
               blocks
        INTO   last_analyzed,
               sample_size  ,
               num_rows     ,
               blocks
        FROM   dba_tables
        WHERE  table_name = tableName
           AND owner      = schema;

        dbms_output.put_line('===================================================================================================');
        dbms_output.put_line('            Table   '
        || tableName);
        dbms_output.put_line('===================================================================================================');
        dbms_output.put_line(rpad('last analyzed', 18, ' ')
        || rpad('sample_size', 12, ' ')
        ||rpad('num_rows', 20, ' ')
        ||rpad('blocks', 10, ' '));
        dbms_output.put_line(rpad(TO_CHAR(last_analyzed, 'MM-DD-YYYY hh24:mi'), 18, ' ')
        || rpad(sample_size, 12, ' ')
        || rpad(num_rows, 20, ' ')
        ||blocks);
        dbms_output.put_line(' ');
EXCEPTION
WHEN no_data_found THEN
        dbms_output.put_line('=================================================================================================');
        dbms_output.put_line('Table not found; Owner: '
        || schema
        ||', name: '
        || tableName);
        dbms_output.put_line('=================================================================================================');
END table_stats;
/************************************************************************/
/* Procedure: index_stats                                               */
/* Desciption: Internal procedures used by verify_stats. Gets info about*/
/* index stats.                                                         */
/************************************************************************/
PROCEDURE index_stats(lowner    VARCHAR2,
                      indexName VARCHAR2)
IS
        last_analyzed dba_indexes.last_analyzed%type;
        num_rows dba_indexes.num_rows%type;
        leaf_blocks dba_indexes.leaf_blocks%type;
        distinct_keys dba_indexes.distinct_keys%type;
        avg_leaf_blocks_per_key dba_indexes.avg_leaf_blocks_per_key%type;
        avg_data_blocks_per_key dba_indexes.avg_data_blocks_per_key%type;
        clustering_factor dba_indexes.clustering_factor%type;
        uniqueness dba_indexes.uniqueness%type;
        val1 VARCHAR2(255);
        val2 VARCHAR2(255);
        val3 VARCHAR2(255);
        val4 VARCHAR2(255);
BEGIN
        SELECT last_analyzed          ,
               TRUNC(num_rows)        ,
               leaf_blocks            ,
               distinct_keys          ,
               avg_leaf_blocks_per_key,
               avg_data_blocks_per_key,
               clustering_factor      ,
               uniqueness
        INTO   last_analyzed          ,
               num_rows               ,
               leaf_blocks            ,
               distinct_keys          ,
               avg_leaf_blocks_per_key,
               avg_data_blocks_per_key,
               clustering_factor      ,
               uniqueness
        FROM   dba_indexes
        WHERE  owner      = lowner
           AND index_name = indexName;

        val1:= rpad(indexname, 30, ' ')
        || rpad(TO_CHAR(last_analyzed, 'MM-DD-YYYY hh24:mi'), 18,' ');
        val2:= rpad(num_rows, 10, ' ')
        ||rpad(leaf_blocks, 8, ' ');
        val3:= rpad(distinct_keys, 9, ' ')
        || rpad(avg_leaf_blocks_per_key, 8, ' ');
        val4:= rpad(avg_data_blocks_per_key, 8, ' ')
        || rpad(clustering_factor, 9, ' ');
        dbms_output.put_line(val1
        || val2
        || val3
        || val4);
END index_stats;
/************************************************************************/
/* Procedure: histo_header                                              */
/* Desciption: Internal procedures used by verify_stats. Prints header  */
/* for histograms in the o/p file                                       */
/************************************************************************/
PROCEDURE histo_header
IS
BEGIN
        dbms_output.put_line('----------------------------------------------------------------------------------------------------');
        dbms_output.put_line('       Histogram  Stats');
        dbms_output.put_line(rpad('Schema', 15, ' ')
        ||rpad('Table Name', 31, ' ')
        ||rpad('Status', 12, ' ')
        ||rpad('last analyzed', 18, ' ')
        || 'Column Name');
        dbms_output.put_line('----------------------------------------------------------------------------------------------------');
END;
/************************************************************************/
/* Procedure: index_header                                              */
/* Desciption: Internal procedures used by verify_stats. Prints header  */
/* for indexes in the o/p file                                          */
/************************************************************************/
PROCEDURE index_header
IS
        val1 VARCHAR2(255);
        val2 VARCHAR2(255);
        val3 VARCHAR2(255);
        val4 VARCHAR2(255);
BEGIN
        val1 := rpad('Index name', 30, ' ')
        || rpad('last analyzed', 18, ' ');
        val2 := rpad('num_rows', 10, ' ')
        || rpad('LB', 8, ' ');
        val3 := rpad('DK', 9, ' ')
        || rpad('LB/key', 8, ' ');
        val4 := rpad('DB/key', 8, ' ')
        ||rpad('CF', 9, ' ');
        dbms_output.put_line(val1
        || val2
        || val3
        || val4);
        dbms_output.put_line('----------------------------------------------------------------------------------------------------');
END;
/************************************************************************/
/* Procedure: histo_stats                                               */
/* Desciption: Internal procedures used by verify_stats. Gets info about*/
/* about histogram stats.                                               */
/************************************************************************/
PROCEDURE histo_stats(schema     VARCHAR2,
                      tableName  VARCHAR2,
                      columnName VARCHAR2)
IS
        found0 BOOLEAN      := false;
        found1 BOOLEAN      := false;
        status VARCHAR2(64) := 'not present';
        last_analyzed dba_tab_columns.last_analyzed%type;
        CURSOR histo_details(schema VARCHAR2, tableName VARCHAR2, columnName VARCHAR2)
        IS
                SELECT endpoint_number,
                       last_analyzed
                FROM   dba_histograms a,
                       dba_tab_columns b
                WHERE  a.owner              = schema
                   AND a.table_name         = tableName
                   AND a.column_name        = columnName
                   AND a.owner              = b.owner
                   AND a.table_name         = b.table_name
                   AND a.column_name        = b.column_name
                   AND endpoint_number NOT IN (0,
                                               1);

 BEGIN
         FOR each_histo IN histo_details(schema, tableName, columnName)
         LOOP
                 last_analyzed := each_histo.last_analyzed;
                 status        := 'present';
                 EXIT;
         END LOOP;
         dbms_output.put_line(rpad(schema, 15, ' ')
         || rpad(tableName, 31, ' ')
         || rpad(status, 12, ' ')
         || rpad(TO_CHAR(last_analyzed, 'DD-MM-YYYY hh24:mi'), 18, ' ')
         || columnName);
 EXCEPTION
 WHEN no_data_found THEN
         dbms_output.put_line('=================================================================================================');
         dbms_output.put_line('Histogram not found; Owner: '
         || schema
         ||', name: '
         || tableName
         || ', column name: '
         || columnName);
         dbms_output.put_line('=================================================================================================');
 END histo_stats;
 /************************************************************************/
 /* Procedure: file_tail                                                 */
 /* Desciption: Internal procedures used by verify_stats. Prints legend  */
 /* in the o/p file                                                      */
 /************************************************************************/
PROCEDURE file_tail
IS
BEGIN
        dbms_output.put_line(' ');
        dbms_output.put_line(' ');
        dbms_output.put_line('Legend:');
        dbms_output.put_line('LB : Leaf Blocks');
        dbms_output.put_line('DK : Distinct Keys');
        dbms_output.put_line('DB : Data Blocks');
        dbms_output.put_line('CF : Clustering Factor');
END;
/************************************************************************/
/* Procedure: column_stats                                              */
/* Desciption: Internal procedures used by verify_stats. Gets info about*/
/* about column stats.                                                  */
/************************************************************************/
PROCEDURE column_stats(column_name dba_tab_columns.column_name%type,
                       num_distinct dba_tab_columns.num_distinct%type,
                       num_nulls dba_tab_columns.num_nulls%type,
                       density dba_tab_columns.density%type,
                       sample_size dba_tab_columns.sample_size%type,
                       last_analyzed dba_tab_columns.last_analyzed%type,
                       first_col BOOLEAN)
IS
        val1 VARCHAR2(255);
        val2 VARCHAR2(255);
        val3 VARCHAR2(255);
BEGIN
        IF (first_col = true) THEN
                dbms_output.put_line('----------------------------------------------------------------------------------------------------');
                dbms_output.put_line('       Column  Stats');
                val1 := rpad('Column name', 31, ' ')
                || rpad('sample_size', 12, ' ');
                val2 := rpad('num_distinct', 14, ' ')
                || rpad('num_nulls', 14, ' ');
                val3 := rpad('density', 12, ' ')
                || rpad('last analyzed', 18, ' ');
                dbms_output.put_line(val1
                ||val2
                ||val3);
                dbms_output.put_line('----------------------------------------------------------------------------------------------------');
        END IF;
        val1 := rpad(column_name, 31, ' ')
        || rpad(sample_size, 12, ' ');
        val2 := rpad(num_distinct, 14, ' ')
        || rpad(TRUNC(num_nulls), 14, ' ');
        val3 := rpad(TRUNC(density, 9), 12, ' ')
        || rpad(TO_CHAR(last_analyzed, 'MM-DD-YYYY hh24:mi'), 18, ' ');
        dbms_output.put_line(val1
        || val2
        || val3);
END;

/************************************************************************/
/* Procedure: LOAD_EXTNSTATS_COLS                                       */
/* Desciption: This is for internal purpose only. For loading into      */
/* SEED database                                                        */
/************************************************************************/
PROCEDURE LOAD_EXTNSTATS_COLS(action      IN VARCHAR2,
                              appl_id     IN NUMBER,
			      owner       IN VARCHAR2,
                              tabname     IN VARCHAR2,
                              colname1    IN VARCHAR2,
                              colname2    IN VARCHAR2,
                              colname3    IN VARCHAR2 DEFAULT NULL,
                              colname4    IN VARCHAR2 DEFAULT NULL,
                              partname    IN VARCHAR2 DEFAULT NULL,
                              hsize       IN NUMBER DEFAULT 254,
                              commit_flag IN VARCHAR2 DEFAULT 'Y')
IS
        exist_flag VARCHAR2(5) := NULL;
	l_cg_name  VARCHAR2(30) := NULL;
	--owner varchar2(30) := NULL;
	extntn varchar2(50);
BEGIN
        $IF DBMS_DB_VERSION.VER_LE_9_2 $THEN
	   NULL;
	   $ELSE
        $IF DBMS_DB_VERSION.VER_LE_10_2 $THEN
             NULL;
         $ELSE
                 If upper(colname3) is not null and upper(colname4) is null THEN
                      extntn := '(' || upper(colname1) || ',' || upper(colname2) || ',' || upper(colname3) || ')' ;
                       elsif
                      upper(colname4) is not null then
                       extntn :='(' || upper(colname1) || ',' || upper(colname2) || ',' || upper(colname3) || ',' || upper(colname4) ||')' ;
                        Else
                       extntn:='(' || upper(colname1) || ',' || upper(colname2) || ')';
                   END IF ;
		  dbms_output.put_line(extntn);
        IF upper(action) = 'INSERT' THEN
                BEGIN
                        -- Check for existence of the table first
                        -- break out if it doesn't exist
                         BEGIN

			SELECT DISTINCT('EXIST')
                        INTO            exist_flag
			FROM dba_tab_columns a1  , dba_tab_columns a2,
			     dba_tab_columns a3, dba_tab_columns a4,
			     fnd_oracle_userid b,
			     fnd_product_installations c
			WHERE  a1.table_name     = upper(tabname)
			       AND a2.table_name     = upper(tabname)
			       AND a3.table_name     = upper(tabname)
			       AND a4.table_name     = upper(tabname)
			       AND a1.column_name    = upper(colname1)
			       AND a2.column_name    = upper(colname2)
			       AND a3.column_name    = NVL(upper(colname3), a3.column_name)
			       AND a4.column_name    = NVL(upper(colname3), a4.column_name)
			       AND c.application_id  = appl_id
			       AND c.oracle_id       = b.oracle_id
			       AND a1.owner          = b.oracle_username
			       AND a2.owner          = b.oracle_username
			       AND a3.owner          = b.oracle_username
			       AND a4.owner          = b.oracle_username;
                        EXCEPTION
                        WHEN no_data_found THEN
                                raise_application_error(-20000, 'Column '
                                || tabname
                                ||'.'
                                || colname1
                                || ' does not exist in dba_tab_columns for the given application ');
                        WHEN OTHERS THEN
                                raise_application_error(-20001, 'Error in reading dictionary info. for column  '
                                || tabname
                                ||'.'
                                || colname1 );
                        END;
                        BEGIN
			       INSERT
                                INTO   FND_EXTNSTATS_COLS
                                       (
                                              APPLICATION_ID  ,
                                              TABLE_NAME      ,
                                              COLUMN_NAME1    ,
                                              COLUMN_NAME2    ,
                                              COLUMN_NAME3    ,
                                              COLUMN_NAME4    ,
                                              PARTITION       ,
                                              HSIZE           ,
                                              CREATION_DATE   ,
                                              CREATED_BY      ,
                                              LAST_UPDATE_DATE,
                                              LAST_UPDATED_BY ,
                                              LAST_UPDATE_LOGIN
                                       )
                                       VALUES
                                       (
                                              appl_id        ,
                                              upper(tabname) ,
                                              upper(colname1) ,
                                              upper(colname2) ,
                                              NVL(upper(colname3), NULL) ,
                                              NVL(upper(colname4), NULL) ,
                                              upper(partname),
                                              hsize          ,
                                              sysdate        ,
                                              1              ,
                                              sysdate        ,
                                              1              ,
                                              NULL
                                       ) ;
				  /* If upper(colname3) is not null then
                                 extntn := '(' || upper(colname1) || ',' || upper(colname2) || ',' || upper(colname3) || ')' ;
                                 elsif
                                upper(colname4) is not null then
                              extntn :='(' || upper(colname1) || ',' || upper(colname2) || ',' || upper(colname3) || ',' || upper(colname4) ||')' ;
                               Else
                               extntn:='(' || upper(colname1) || ',' || upper(colname2) || ')';
                                END IF ; */
				l_cg_name := DBMS_STATS.create_extended_stats(ownname   => owner,
						tabname   => tabname,
						extension => extntn);
				DBMS_OUTPUT.PUT_LINE(l_cg_name);
                        EXCEPTION
                        WHEN DUP_VAL_ON_INDEX THEN
                                NULL;
                        END;
                END;
        elsif upper(action) = 'DELETE' THEN
                BEGIN
                        DELETE
                        FROM   FND_EXTNSTATS_COLS
                        WHERE  application_id = appl_id
                           AND table_name     = upper(tabname)
                           AND column_name1    = upper(colname1)
                           AND column_name2    = upper(colname2)
			   AND nvl(column_name3,'-99')    = nvl(upper(colname3),'-99')
			   AND nvl(column_name4,'-99')    = nvl(upper(colname4),'-99')
                           AND
                               (
                                      partition = upper(partname)
                                   OR partition IS NULL
                               );
                        DBMS_STATS.DROP_EXTENDED_STATS( OWNNAME   => owner,
			TABNAME   => tabname,
			EXTENSION => extntn);

                END;
        END IF;
        IF ( commit_flag = 'Y') THEN
                /* for remote db operation */
                COMMIT;
        END IF;
	$END
	$END
END;
/* LOAD_EXTNSTATS_COLS */

/************************************************************************/
/* Procedure: verify_stats                                              */
/* Desciption: Checks stats for database objects depending on input.    */
/* Sends its output to the screen. Should be called from SQL prompt, and*/
/* o/p should be spooled to a file. Can be used to check all tables in  */
/* schema, or particular tables. Column stats can also be checked.      */
/************************************************************************/
PROCEDURE verify_stats(schemaName  VARCHAR2 DEFAULT NULL,
                       tableList   VARCHAR2 DEFAULT NULL,
                       days_old    NUMBER DEFAULT NULL,
                       column_stat BOOLEAN DEFAULT false)
IS
        CURSOR all_tables(schema VARCHAR2)
        IS
                SELECT   table_name,
                         owner
                FROM     dba_tables dt
                WHERE    owner = schema
                     AND
                         (
                                  iot_type <> 'IOT_OVERFLOW'
                               OR iot_type IS NULL
                         )
                     AND
                         (
                                  (
                                           sysdate - NVL(last_analyzed, to_date('01-01-1900', 'MM-DD-YYYY'))
                                  )
                                  >days_old
                               OR days_old IS NULL
                         )
                ORDER BY table_name;

       CURSOR all_indexes(schema VARCHAR2, tableName VARCHAR2)
       IS
               SELECT   index_name,
                        owner
               FROM     dba_indexes
               WHERE    table_owner = schema
                    AND table_name  = tableName
               ORDER BY index_name;

      /*cursor all_histograms(schema varchar2, tableName varchar2) is
      select a.column_name
      from fnd_histogram_cols a,
      fnd_oracle_userid b,
      fnd_product_installations c
      where a.application_id = c.application_id
      and   c.oracle_id = b.oracle_id
      and   b.oracle_username = schema
      and   a.table_name = tableName
      order by a.column_name;*/
      CURSOR all_histograms(schema VARCHAR2, tableName VARCHAR2)
      IS
              SELECT   a.column_name
              FROM     fnd_histogram_cols a
              WHERE    a.table_name = tableName
              ORDER BY a.column_name;

     CURSOR all_columns(schema VARCHAR2, tableName VARCHAR2)
     IS
             SELECT   COLUMN_NAME ,
                      NUM_DISTINCT,
                      NUM_NULLS   ,
                      DENSITY     ,
                      SAMPLE_SIZE ,
                      LAST_ANALYZED
             FROM     dba_tab_columns
             WHERE    owner      = schema
                  AND table_name = tableName
             ORDER BY column_name;

    MyTableList VARCHAR2(4000);
    MySchema    VARCHAR2(255);
TYPE List
IS
        TABLE OF VARCHAR2(64) INDEX BY BINARY_INTEGER;
        Table_Name List;
        Table_Owner List;
        table_counter          INTEGER     := 1;
        MAX_NOF_TABLES         NUMBER      := 32768;
        operation              VARCHAR2(64):= '';
        ownerIndex             NUMBER(1);
        first_histo            BOOLEAN;
        first_index            BOOLEAN;
        first_col              BOOLEAN;
        verify_stats_exception EXCEPTION;
BEGIN
        dbms_output.enable(1000000);
        -- read all input params into plsql vars
        MySchema    := upper(schemaName);
        MyTableList := REPLACE(upper(TableList), ' ', '');
        -- clean up input data
        -- start with the tables list
        IF MyTableList IS NULL THEN
                -- user wants to inspect all tables in schema
                IF MySchema IS NOT NULL THEN
                        operation := 'schema';
                END IF;
        ELSE
                operation := 'table';
        END IF;
        Table_Name(1)  := NULL;
        Table_Owner(1) := NULL;
        -- check operation flag and process accordingly
        IF operation = 'table' THEN
                -- initialize Table_list
                WHILE (instr(MyTableList,',') > 0)
                LOOP
                        dbms_output.put_line('MyTableList '
                        || mytableList);
                        Table_Name(table_counter)         := SUBSTR(mytablelist,1,instr(mytablelist,',') - 1) ;
                        ownerIndex                        := instr(Table_Name(table_counter), '.');
                        IF ownerIndex                     <> 0 THEN
                                Table_Owner(table_counter):= SUBSTR(Table_Name(table_counter), 1, ownerIndex-1);
                                Table_Name(table_counter) := SUBSTR(Table_Name(table_counter), ownerIndex+1);
                        ELSE
                                Table_Owner(table_counter):= MySchema;
                        END IF;
                        table_counter              := table_counter + 1;
                        Table_Name(table_counter)  := NULL;
                        Table_Owner(table_counter) := NULL;
                        MyTableList                := SUBSTR(MyTableList,instr(MyTableList,',')+1) ;
                        EXIT
                WHEN table_counter = MAX_NOF_TABLES;
                END LOOP;
                -- This gets the last table_name in a comma separated list
                Table_Name(table_counter) := MyTableList ;
                -- check if owner is specified on command line or not
                OwnerIndex                        := instr(Table_Name(table_counter), '.');
                IF ownerIndex                     <> 0 THEN
                        Table_Owner(table_counter):= SUBSTR(Table_Name(table_counter), 1, ownerIndex-1);
                        Table_Name(table_counter) := SUBSTR(Table_Name(table_counter), ownerIndex+1);
                ELSE
                        Table_Owner(table_counter):= MySchema;
                END IF;
                Table_Name(table_counter+1)  := NULL;
                Table_Owner(table_counter+1) := NULL;
        elsif operation                       = 'schema' THEN
                -- retrieve all tables for schema and continue with processing
                OPEN all_tables(MySchema);
                FETCH all_tables BULK COLLECT
                INTO  Table_Name,
                      Table_Owner LIMIT MAX_NOF_TABLES;

                CLOSE all_tables;
        ELSE -- error occurred
                raise verify_stats_exception;
        END IF;
        -- loop all the tables and check their stats and indexes
        FOR i IN 1..Table_Name.last
        LOOP
                EXIT
        WHEN Table_Name(i) IS NULL;
                first_histo := true;
                first_index := true;
                first_col   := true;
                -- get table stats first
                table_stats(Table_Owner(i), Table_Name(i));
                -- do the stats for all table columns if flag is yes
                IF (column_stat      = true) THEN
                        FOR col_rec IN all_columns(Table_Owner(i), Table_Name(i))
                        LOOP
                                column_stats(col_rec.column_name, col_rec.num_distinct, col_rec.num_nulls, col_rec.density, col_rec.sample_size, col_rec.last_analyzed, first_col);
                                first_col:= false;
                        END LOOP;
                END IF;
                -- do the stats for all table indexes
                FOR index_rec IN all_indexes(Table_Owner(i), Table_Name(i))
                LOOP
                        IF first_index = true THEN
                                index_header();
                                first_index := false;
                        END IF;
                        index_stats(index_rec.owner, index_rec.index_Name);
                END LOOP;
                -- do the stats for all table histograms
                FOR histo_rec IN all_histograms(Table_Owner(i), Table_Name(i))
                LOOP
                        IF first_histo = true THEN
                                histo_header();
                                first_histo:= false;
                        END IF;
                        histo_stats(Table_Owner(i), Table_Name(i), histo_rec.column_name);
                END LOOP;
        END LOOP;
        file_tail();
EXCEPTION
WHEN verify_stats_exception THEN
        dbms_output.put_line('verify_stats(schema_name varchar2 default null,
table_list varchar2 default null, days_old number default null,
column_stats boolean defualt false)');
END ;
/* end of verify_stats*/
BEGIN
        -- Get the default DOP that will be used if none is provided.
        GET_PARALLEL(def_degree);
        dummybool := fnd_installation.get_app_info('FND',dummy1,dummy2,fnd_statown);
        --     select substr(version,1,instr(version,'.')-1)
        SELECT REPLACE(SUBSTR(version,1,instr(version,'.',1,2)-1),'.')
        INTO   db_versn
        FROM   v$instance;

	-- changes done for bug 11835452
	IF db_versn < 111 then
		def_estimate_pcnt := 10;
	else
		def_estimate_pcnt := dbms_stats.auto_sample_size;
	end if;

        -- Initialize cur_request_id
        cur_request_id:=GET_REQUEST_ID;
        --    dbms_output.put_line('Database version is '||db_versn);
EXCEPTION
WHEN OTHERS THEN
        db_versn:=81; -- Just in case, default it to 8i
END FND_STATS;

/
