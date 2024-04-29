--------------------------------------------------------
--  DDL for Package Body IGI_SLS_OBJECTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_SLS_OBJECTS_PKG" AS
--$Header: igislsob.pls 120.5.12000000.5 2007/11/08 07:32:09 vspuli ship $

	l_debug_level NUMBER	:=	FND_LOG.G_CURRENT_RUNTIME_LEVEL;
	l_state_level NUMBER	:=	FND_LOG.LEVEL_STATEMENT;
	l_proc_level  NUMBER	:=	FND_LOG.LEVEL_PROCEDURE;
	l_event_level NUMBER	:=	FND_LOG.LEVEL_EVENT;
	l_excep_level NUMBER	:=	FND_LOG.LEVEL_EXCEPTION;
	l_error_level NUMBER	:=	FND_LOG.LEVEL_ERROR;
	l_unexp_level NUMBER	:=	FND_LOG.LEVEL_UNEXPECTED;
	l_path        VARCHAR2(50)  :=  'IGI.PLSQL.igislsob.igi_sls_objects_pkg.';


/*PROCEDURE write_to_log(p_message IN VARCHAR2)
IS

BEGIN
FND_FILE.put_line(FND_FILE.log,p_message);

END write_to_log;*/


PROCEDURE write_to_log(p_level IN NUMBER, p_path IN VARCHAR2, p_mesg IN VARCHAR2)
IS
BEGIN
	IF (p_level >=  l_debug_level ) THEN
             FND_LOG.STRING  (p_level , l_path || p_path , p_mesg );
        END IF;
END write_to_log;


PROCEDURE create_sls_tab(sls_tab 	IN  VARCHAR2,
                         schema_name    IN  VARCHAR2,
			 errbuf 	OUT NOCOPY VARCHAR2,
			 retcode 	OUT NOCOPY NUMBER)
IS

  check_ts_mode          varchar2(100);
  check_tspace_exists    varchar2(100);
  physical_tspace_name   varchar2(100);
  l_sql_stat             varchar2(300);
  l_sql_grt              VARCHAR2(300);
  already_exists         EXCEPTION;

  l_user                   varchar2(5);
  PRAGMA EXCEPTION_INIT(already_exists, -00955);

  l_sql_mls_syn VARCHAR2(300);

BEGIN

  l_user  := 'IGI';
errbuf  := 'Normal Completion';
retcode := 0;

ad_tspace_util.is_new_ts_mode(check_ts_mode);
ad_tspace_util.get_tablespace_name('IGI', 'TRANSACTION_TABLES', 'Y', check_tspace_exists, physical_tspace_name);

If (check_ts_mode = 'Y') and (check_tspace_exists = 'Y') THEN


     l_sql_stat:='BEGIN ' || l_user || '.apps_ddl.apps_ddl('||'''CREATE TABLE '||sls_tab||'(SLS_ROWID ROWID CONSTRAINT '||sls_tab ||
               '_PK PRIMARY KEY,SLS_SEC_GRP VARCHAR2(30),PREV_SLS_SEC_GRP VARCHAR2(30), CHANGE_DATE DATE) TABLESPACE '||
               physical_tspace_name||''''||');END;';

Else

   l_sql_stat:='BEGIN ' || l_user || '.apps_ddl.apps_ddl('||'''CREATE TABLE '||sls_tab||'(SLS_ROWID ROWID CONSTRAINT '||sls_tab ||'_PK PRIMARY KEY,SLS_SEC_GRP VARCHAR2(30),PREV_SLS_SEC_GRP VARCHAR2(30), CHANGE_DATE DATE)'''||');END;';

End If;

EXECUTE IMMEDIATE l_sql_stat;

l_sql_grt:= 'BEGIN ' || l_user || '.apps_ddl.apps_ddl ('||'''GRANT ALL ON '||sls_tab||' TO ' || schema_name || ' WITH GRANT OPTION'''||');END;';

EXECUTE IMMEDIATE l_sql_grt;


EXCEPTION

WHEN already_exists
   THEN NULL;
      igi_sls_objects_pkg.write_to_log(l_excep_level, 'create_sls_tab', 'END igi_sls_objects_pkg.create_sls_tab '||sls_tab||' TABLE ALREADY EXISTS');

WHEN OTHERS THEN
     FND_MESSAGE.SET_NAME('IGI', 'IGI_LOGGING_USER_ERROR'); -- Seeded Message
     retcode := 2;
     errbuf :=  Fnd_message.get;
     igi_sls_objects_pkg .write_to_log(l_excep_level, 'create_sls_tab','END igi_sls_objects_pkg.create_sls_tab - failed with error ' || SQLERRM );

RETURN;

END create_sls_tab;

---------------------------------------------------------------------------
--  Procedure to create index dynamically   				 --
---------------------------------------------------------------------------

PROCEDURE create_sls_inx(sls_tab 	IN VARCHAR2,
			errbuf 		OUT NOCOPY VARCHAR2,
			retcode 	OUT NOCOPY NUMBER)
IS

  l_user                   varchar2(5);
  check_ts_mode            varchar2(100);
  check_tspace_exists      varchar2(100);
  physical_tspace_name     varchar2(100);
  l_sql_inx                VARCHAR2(500);

  already_exists           EXCEPTION;
  col_indexed              EXCEPTION;

  PRAGMA EXCEPTION_INIT(already_exists, -00955);
  PRAGMA EXCEPTION_INIT(col_indexed, -01408);

BEGIN

   l_user  := 'IGI';
   errbuf  :='Normal Completion';
   retcode := 0;

   ad_tspace_util.is_new_ts_mode(check_ts_mode);
   ad_tspace_util.get_tablespace_name('IGI', 'TRANSACTION_INDEXES', 'Y', check_tspace_exists, physical_tspace_name);

   If (check_ts_mode = 'Y') and (check_tspace_exists = 'Y') THEN

      l_sql_inx:='BEGIN '||l_user||'.apps_ddl.apps_ddl ('||'''CREATE INDEX '||sls_tab||'_N1 ON '||l_user||'.'||sls_tab||' (SLS_SEC_GRP) TABLESPACE '||physical_tspace_name||''''||');END;';

   Else

      l_sql_inx:='BEGIN '||l_user||'.apps_ddl.apps_ddl ('||'''CREATE INDEX '||sls_tab||'_N1 ON '||l_user||'.'||sls_tab||' (SLS_SEC_GRP)'''||');END;';

   End If;

   BEGIN
      EXECUTE IMMEDIATE l_sql_inx;

      EXCEPTION
      WHEN already_exists
      THEN
          NULL;
      WHEN col_indexed
      THEN
          NULL;
   END;

   -- Added for Enhancement Request 2263845
   -- Bidisha S, 14 mar 2002
   -- Removed for bug 2257594. Instead of creating an unique index
   -- primary key is being created for sls_rowid.
   -- Bidisha S, 26 mar 2002
/*
   l_sql_inx:='BEGIN igi.apps_ddl.apps_ddl ('||'''CREATE UNIQUE INDEX '||sls_tab||'_U1 ON igi.'||sls_tab||' (SLS_ROWID)'''||');END;';

   BEGIN
      EXECUTE IMMEDIATE l_sql_inx;

      EXCEPTION
      WHEN already_exists
      THEN
          NULL;
   END;
*/

   EXCEPTION
   WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('IGI', 'IGI_LOGGING_USER_ERROR'); -- Seeded Message
    retcode := 2;
    errbuf :=  Fnd_message.get;
    igi_sls_objects_pkg .write_to_log(l_excep_level, 'create_sls_inx','END igi_sls_objects_pkg.create_sls_tab - failed with error ' || SQLERRM );

    RETURN;

END create_sls_inx;

------------------------------------------------------------------------------
--  Create APPS synonym
-----------------------------------------------------------------------------

PROCEDURE create_sls_apps_syn(sls_tab 		IN VARCHAR2,
                              schema_name       IN VARCHAR2,
			      errbuf 		OUT NOCOPY VARCHAR2,
			      retcode 		OUT NOCOPY NUMBER)

IS

l_user varchar2(5);
l_sql_apps_syn VARCHAR2(300);
already_exists EXCEPTION;
PRAGMA EXCEPTION_INIT(already_exists, -00955);

BEGIN

l_user:='IGI';
errbuf :='Normal Completion';
retcode := 0;

l_sql_apps_syn:= 'BEGIN '||schema_name||'.apps_ddl.apps_ddl('||'''CREATE SYNONYM '||sls_tab||' FOR '||l_user||'.'||sls_tab||'''); END;';

EXECUTE IMMEDIATE l_sql_apps_syn;


EXCEPTION

WHEN already_exists
   THEN NULL;
      igi_sls_objects_pkg.write_to_log(l_excep_level, 'create_sls_apps_syn','END igi_sls_objects_pkg.create_sls_tab '||sls_tab||' SYNONYM ALREADY EXISTS ON THE '|| schema_name ||' SCHEMA');

WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('IGI', 'IGI_LOGGING_USER_ERROR'); -- Seeded Message
    retcode := 2;
    errbuf :=  Fnd_message.get;
    igi_sls_objects_pkg.write_to_log(l_excep_level, 'create_sls_apps_syn','END igi_sls_objects_pkg.create_sls_tab - failed with error ' || SQLERRM );

RETURN;

END create_sls_apps_syn;

--------------------------------------------------------------------------
--      Procedure to create synonym for MLS schema                        --
--------------------------------------------------------------------------

PROCEDURE create_sls_mls_syn(sls_tab 		IN VARCHAR2,
			     mls_schemaname 	IN VARCHAR2,
			     errbuf 		OUT NOCOPY VARCHAR2,
			     retcode 		OUT NOCOPY NUMBER)

IS

l_user         varchar2(5);
l_sql_mls_syn  VARCHAR2(300);
already_exists EXCEPTION ;

PRAGMA EXCEPTION_INIT(already_exists, -00955);

BEGIN

l_user  := 'IGI';
errbuf  :='Normal Completion';
retcode := 0;

IF mls_schemaname IS NOT NULL
   THEN l_sql_mls_syn := 'BEGIN '||mls_schemaname||'.apps_ddl.apps_ddl('||'''CREATE SYNONYM '||sls_tab||' FOR '||l_user||'.'||sls_tab||'''); END;';

EXECUTE IMMEDIATE l_sql_mls_syn;

END IF;


EXCEPTION

WHEN already_exists
   THEN NULL;
      igi_sls_objects_pkg.write_to_log(l_excep_level, 'create_sls_mls_syn','END igi_sls_objects_pkg.create_sls_tab '||sls_tab||' SYNONYM ALREADY EXISTS ON THE MLS SCHEMA');

WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('IGI', 'IGI_LOGGING_USER_ERROR'); -- Seeded Message
    retcode := 2;
    errbuf :=  Fnd_message.get;
    igi_sls_objects_pkg .write_to_log(l_excep_level, 'create_sls_mls_syn','END igi_sls_objects_pkg.create_sls_tab - failed with error ' || SQLERRM );

RETURN;

END create_sls_mls_syn;


------------------------------------------------------------------------------
-- Procedure to create mrc synonym dynamically
------------------------------------------------------------------------------
PROCEDURE create_sls_mrc_syn(sls_tab 		IN VARCHAR2,
			     mrc_schemaname 	IN VARCHAR2,
			     errbuf 		OUT NOCOPY VARCHAR2,
			     retcode 		OUT NOCOPY NUMBER)

IS

l_user         varchar2(5);
already_exists EXCEPTION;

PRAGMA EXCEPTION_INIT(already_exists, -00955);

l_sql_mrc_syn VARCHAR2(300);

BEGIN

l_user  := 'IGI';
errbuf  :='Normal Completion';
retcode := 0;

IF mrc_schemaname IS NOT NULL
   THEN l_sql_mrc_syn := 'BEGIN '||mrc_schemaname||'.apps_ddl.apps_ddl('||'''CREATE SYNONYM '||sls_tab||' FOR '||l_user||'.'||sls_tab||'''); END;';

EXECUTE IMMEDIATE l_sql_mrc_syn;
END IF;


EXCEPTION

WHEN already_exists
   THEN NULL;
   igi_sls_objects_pkg.write_to_log(l_excep_level, 'create_sls_mrc_syn','END igi_sls_objects_pkg.create_sls_tab '||sls_tab||' SYNONYM ALREADY EXISTS ON THE MRC SCHEMA');

WHEN OTHERS THEN
   FND_MESSAGE.SET_NAME('IGI', 'IGI_LOGGING_USER_ERROR'); -- Seeded Message
   retcode := 2;
   errbuf :=  Fnd_message.get;
   igi_sls_objects_pkg .write_to_log(l_excep_level, 'create_sls_mrc_syn','END igi_sls_objects_pkg.create_sls_tab - failed with error ' || SQLERRM );

RETURN;

END create_sls_mrc_syn;

---------------------------------------------------------------
-- Procedure to drop sls table dynamically		     --
---------------------------------------------------------------

PROCEDURE drop_sls_tab(sls_tab 		IN VARCHAR2,
		       errbuf 		OUT NOCOPY VARCHAR2,
		       retcode 		OUT NOCOPY NUMBER)
IS

l_sql_stat	VARCHAR2(300);
no_table EXCEPTION;
PRAGMA EXCEPTION_INIT(no_table, -00942);

BEGIN

errbuf :='Normal Completion';
retcode := 0;


l_sql_stat:= 'BEGIN igi.apps_ddl.apps_ddl('||'''DROP TABLE '||sls_tab||''');END;';

EXECUTE IMMEDIATE l_sql_stat;


EXCEPTION

WHEN no_table
   THEN NULL;
   igi_sls_objects_pkg.write_to_log(l_excep_level, 'drop_sls_tab','END igi_sls_objects_pkg.drop_sls_tab '||sls_tab||' NO TABLE TO DROP');

WHEN OTHERS THEN
   FND_MESSAGE.SET_NAME('IGI', 'IGI_LOGGING_USER_ERROR'); -- Seeded Message
   retcode := 2;
   errbuf :=  Fnd_message.get;
   igi_sls_objects_pkg .write_to_log(l_excep_level, 'drop_sls_tab','END igi_sls_objects_pkg.drop_sls_tab  - failed with error ' || SQLERRM );

RETURN;

END drop_sls_tab;

---------------------------------------------------------------------
-- Procedure to drop apps synonym dynamically
--------------------------------------------------------------------

PROCEDURE drop_sls_apps_syn(sls_tab 		IN VARCHAR2,
                            schema_name       IN VARCHAR2,
		       	    errbuf 		OUT NOCOPY VARCHAR2,
		            retcode 		OUT NOCOPY NUMBER)
IS

l_sql_apps_syn 	VARCHAR2(300);

no_synonym EXCEPTION;
PRAGMA EXCEPTION_INIT(no_synonym, -01434);

BEGIN

errbuf :='Normal Completion';
retcode := 0;


l_sql_apps_syn:= 'BEGIN '||schema_name|| '.apps_ddl.apps_ddl('||'''DROP SYNONYM '||sls_tab||''');END;';

EXECUTE IMMEDIATE l_sql_apps_syn;


EXCEPTION

WHEN no_synonym
THEN NULL;
   igi_sls_objects_pkg.write_to_log(l_excep_level, 'drop_sls_apps_syn','END igi_sls_objects_pkg.drop_sls_apps_syn '||sls_tab||' NO SYNONYM TO DROP FROM THE '|| schema_name || 'SCHEMA');

WHEN OTHERS THEN
   FND_MESSAGE.SET_NAME('IGI', 'IGI_LOGGING_USER_ERROR'); -- Seeded Message
   retcode := 2;
   errbuf :=  Fnd_message.get;
   igi_sls_objects_pkg .write_to_log(l_excep_level, 'drop_sls_apps_syn','END igi_sls_objects_pkg.drop_sls_apps_syn - failed with error ' || SQLERRM );

RETURN;

END drop_sls_apps_syn;

------------------------------------------------------------------
-- Procedure to drop mls synonym dynamically			--
------------------------------------------------------------------

PROCEDURE drop_sls_mls_syn(sls_tab 		IN VARCHAR2,
		           mls_schemaname 	IN VARCHAR2,
		           errbuf 		OUT NOCOPY VARCHAR2,
		           retcode 		OUT NOCOPY NUMBER)

IS

l_sql_mls_syn 	VARCHAR2(300);
no_synonym EXCEPTION;
PRAGMA EXCEPTION_INIT(no_synonym, -01434);

l_sql_mrc_syn VARCHAR2(300);

BEGIN

errbuf :='Normal Completion';
retcode := 0;

IF mls_schemaname IS NOT NULL
   THEN l_sql_mls_syn:= 'BEGIN '||mls_schemaname||'.apps_ddl.apps_ddl('||'''DROP SYNONYM '||sls_tab||''');END;';

     EXECUTE IMMEDIATE l_sql_mls_syn;

END IF;


EXCEPTION

WHEN no_synonym
   THEN NULL;
   igi_sls_objects_pkg.write_to_log(l_excep_level, 'drop_sls_mls_syn','END igi_sls_objects_pkg.drop_sls_mls_syn '||sls_tab||' NO SYNONYM TO DROP FROM THE MLS SCHEMA');

WHEN OTHERS THEN
   FND_MESSAGE.SET_NAME('IGI', 'IGI_LOGGING_USER_ERROR'); -- Seeded Message
   retcode := 2;
   errbuf :=  Fnd_message.get;
   igi_sls_objects_pkg .write_to_log(l_excep_level, 'drop_sls_mls_syn','END igi_sls_objects_pkg. drop_sls_mls_syn - failed with error ' || SQLERRM );

RETURN;

END drop_sls_mls_syn;

------------------------------------------------------------------
-- Procedure to drop mrc synonym dynamically
------------------------------------------------------------------
PROCEDURE drop_sls_mrc_syn(sls_tab 		IN VARCHAR2,
		           mrc_schemaname 	IN VARCHAR2,
		           errbuf 		OUT NOCOPY VARCHAR2,
		           retcode 		OUT NOCOPY NUMBER)

IS

l_sql_mrc_syn 	VARCHAR2(300);

no_synonym EXCEPTION;
PRAGMA EXCEPTION_INIT(no_synonym, -01434);

BEGIN

errbuf :='Normal Completion';
retcode := 0;

IF mrc_schemaname IS NOT NULL
   THEN l_sql_mrc_syn:= 'BEGIN '||mrc_schemaname||'.apps_ddl.apps_ddl('||'''DROP SYNONYM '||sls_tab||''');END;';

    EXECUTE IMMEDIATE l_sql_mrc_syn;

END IF;


EXCEPTION

WHEN no_synonym
   THEN NULL;
   igi_sls_objects_pkg.write_to_log(l_excep_level, 'drop_sls_mrc_syn','END igi_sls_objects_pkg.drop_sls_mrc_syn '||sls_tab||' NO SYNONYM TO DROP FROM THE MRC SCHEMA');

WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('IGI', 'IGI_LOGGING_USER_ERROR'); -- Seeded Message
      retcode := 2;
      errbuf :=  Fnd_message.get;
      igi_sls_objects_pkg .write_to_log(l_excep_level, 'drop_sls_mrc_syn','END igi_sls_objects_pkg.drop_sls_mrc_syn - failed with error ' || SQLERRM );

RETURN;

END drop_sls_mrc_syn;

---------------------------------------------------------------
-- Procedure to Create sls trigger			     --
---------------------------------------------------------------

PROCEDURE create_sls_trg(sls_tab 	IN VARCHAR2,
			 sec_tab 	IN VARCHAR2,
			 errbuf 	OUT NOCOPY VARCHAR2,
			 retcode 	OUT NOCOPY NUMBER)

IS

l_sql_trg VARCHAR2(5000);
l_user    varchar2(5);

BEGIN

l_user  := 'IGI';
errbuf  :='Normal Completion';
retcode := 0;

-- Cannot use igi_sls_security_group_alloc because we want the trigger
-- to insert even if tha table is disabled.

l_sql_trg:= 'CREATE OR REPLACE TRIGGER '||sls_tab||'_TRG AFTER INSERT OR DELETE ON '||sec_tab ||' FOR EACH ROW

DECLARE

l_sec_grp VARCHAR2(30);
l_status  VARCHAR2(5);
l_history VARCHAR2(30):='||'''IGI_SLS_MAINTAIN_HISTORY'''||';
l_value	  VARCHAR2(5);
l_valid1  NUMBER;
l_valid2  NUMBER;

CURSOR C1 (c_l_sec_grp VARCHAR2)IS
           SELECT 1
           FROM igi_sls_allocations
           WHERE sls_group = c_l_sec_grp
           AND sls_allocation = '||''''||sec_tab||''''||'
           AND date_removed IS NULL ;

CURSOR C2 (c_l_sec_grp VARCHAR2)IS
             SELECT 1
             FROM igi_sls_allocations a,igi_sls_allocations b
             WHERE a.sls_allocation = b.sls_group
             AND a.sls_group =  c_l_sec_grp
             AND a.sls_group_type = '||'''S'''||'
             AND b.sls_group_type = '||'''P'''||'
             AND a.sls_allocation_type = '||'''P'''||'
             AND b.sls_allocation_type = '||'''T'''||'
             AND b.sls_allocation = '||''''||sec_tab||''''||'
             AND a.date_removed IS NULL
             AND b.date_removed IS NULL;

BEGIN
IF INSERTING THEN
   BEGIN
       IF SYS_CONTEXT('||'''IGI'''||','||'''SLS_RESPONSIBILITY'''||')='||'''Y'''||' THEN
           l_sec_grp:=SYS_CONTEXT('||'''IGI'''||','||'''SLS_SECURITY_GROUP'''||');
	   IF l_sec_grp IS NOT NULL AND l_sec_grp != '||'''CEN'''||' THEN

              OPEN C1(l_sec_grp);
              FETCH C1 INTO l_valid1;
              IF C1%NOTFOUND THEN
                 l_valid1 := 0;
              END IF;
              CLOSE C1;
              IF l_valid1 = 0 THEN
                 OPEN C2(l_sec_grp);
                 FETCH C2 INTO l_valid2;
                 IF C2%NOTFOUND THEN
                    l_valid2 := 0;
                 END IF;
                 CLOSE C2;
              END IF;

              IF l_valid1 = 1 OR l_valid2 = 1 THEN

                 l_status:= SYS_CONTEXT('||'''IGI'''||','||'''SLS_GROUP_STATUS'''||');
		 IF l_status = '||'''N'''||'  THEN
		    l_value := Nvl(FND_PROFILE.VALUE(l_history),'||'''N'''||');
                 END IF;
 		 IF l_value = '||'''Y'''||' OR l_status = '||'''Y'''||' THEN
                    INSERT INTO '||l_user||'.'||sls_tab||' (SLS_ROWID, SLS_SEC_GRP)
                    VALUES(:new.ROWID,l_sec_grp);
		 END IF;
	      END IF; 	-- Secure Table
          END IF; -- Not CEN Group
       END IF; -- SLS Enabled
    END;
END IF; -- Inserting
IF DELETING THEN
   BEGIN
      delete from '||l_user||'.'||sls_tab||' where sls_rowid=:old.rowid;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN NULL;
   END;
END IF;
END;';


EXECUTE IMMEDIATE l_sql_trg;


EXCEPTION
  WHEN OTHERS THEN
     FND_MESSAGE.SET_NAME('IGI', 'IGI_LOGGING_USER_ERROR'); -- Seeded Message
     retcode := 2;
     errbuf :=  Fnd_message.get;
     igi_sls_objects_pkg.write_to_log(l_excep_level, 'create_sls_trg','END igi_sls_objects_pkg.create sls trigger - failed with error ' || SQLERRM );

RETURN;

END create_sls_trg;

---------------------------------------------------------------
-- Procedure drop the sls trigger			     --
---------------------------------------------------------------
PROCEDURE drop_sls_trg(sls_tab 	IN VARCHAR2,
		       errbuf 	OUT NOCOPY VARCHAR2,
		       retcode 	OUT NOCOPY NUMBER)
IS
no_trigger EXCEPTION;
PRAGMA EXCEPTION_INIT(no_trigger, -04080);
l_sql_mrc_syn VARCHAR2(300);

BEGIN

errbuf :='Normal Completion';
retcode := 0;


EXECUTE IMMEDIATE 'DROP TRIGGER '||sls_tab||'_TRG';


EXCEPTION

WHEN no_trigger
   THEN NULL;
   igi_sls_objects_pkg.write_to_log(l_excep_level, 'drop_sls_trg','END igi_sls_objects_pkg.drop sls trigger'||sls_tab||'_TRG -  NO TRIGGER TO DROP');
  WHEN OTHERS THEN
     FND_MESSAGE.SET_NAME('IGI', 'IGI_LOGGING_USER_ERROR'); -- Seeded Message
     retcode := 2;
     errbuf :=  Fnd_message.get;
     igi_sls_objects_pkg.write_to_log(l_excep_level, 'drop_sls_trg','END igi_sls_objects_pkg.drop sls trigger - failed with error ' || SQLERRM );

RETURN;

END drop_sls_trg;

-----------------------------------------------------------------------------
--  Procedure to create the policy function				   --
-----------------------------------------------------------------------------


PROCEDURE cre_pol_function(sec_tab 	IN VARCHAR2,
			   sls_tab 	IN VARCHAR2,
			   errbuf 	OUT NOCOPY VARCHAR2,
			   retcode 	OUT NOCOPY NUMBER)
IS

  l_sql_stat  VARCHAR2(2000);
  l_sql_grant VARCHAR2(100);

BEGIN

  errbuf :='Normal Completion';
  retcode := 0;


  l_sql_stat:=
  'CREATE OR REPLACE FUNCTION '||sls_tab||'_FUN (D1 VARCHAR2, D2 VARCHAR2) RETURN VARCHAR2 AS
     l_valid               NUMBER;
     d_predicate           VARCHAR2(2000) := NULL;
     l_enable              VARCHAR2(10);
     l_sls_security_group  VARCHAR2(30);
     l_status              VARCHAR2(5);
     l_sls_responsibility  VARCHAR2(50);

     CURSOR c1 (c_sls_security_group varchar2)
     IS
      SELECT 1 FROM igi_sls_security_group_alloc
      WHERE table_name = '||''''||sec_tab||''''||'
      AND   sls_security_group = c_sls_security_group;

   BEGIN

     l_enable := NVL(SYS_CONTEXT('||'''IGI'''||','||'''SLS_RESPONSIBILITY'''||'),'||'''N'''||');

     IF l_enable = '||'''Y'''||' THEN
        l_sls_security_group :=SYS_CONTEXT('||'''IGI'''||','||'''SLS_SECURITY_GROUP'''||');
        l_status:=SYS_CONTEXT('||'''IGI'''||','||'''SLS_GROUP_STATUS'''||');

        IF l_status = '||'''Y'''||' THEN

           IF l_sls_security_group != '||'''CEN'''||' and l_sls_security_group is not null THEN
              OPEN c1(l_sls_security_group);
              FETCH c1 INTO l_valid;
              IF c1%NOTFOUND THEN
                 l_valid:= 0;
              END IF;
              CLOSE c1;';

    IF sec_tab = 'AR_PAYMENT_SCHEDULES_ALL' THEN
       l_sql_stat := l_sql_stat ||
             'IF l_valid = 1 THEN
                 d_predicate:='||''' (payment_schedule_id < 0 OR ROWID = (SELECT SLS_ROWID FROM '||sls_tab||' WHERE sls_rowid = '||sec_tab||'.rowid and sls_sec_grp = '||'''||''''''''||l_sls_security_group||''''''''||'''||'))'';
              END IF;';
    ELSE
       l_sql_stat := l_sql_stat ||
             'IF l_valid = 1 THEN
                 d_predicate:='||''' ROWID = (SELECT SLS_ROWID FROM '||sls_tab||' WHERE sls_rowid = '||sec_tab||'.rowid and sls_sec_grp = '||'''||''''''''||l_sls_security_group||''''''''||'''||')'';
              END IF;';
    END IF;



       l_sql_stat := l_sql_stat ||
          ' ELSIF l_sls_security_group IS NULL THEN
                  d_predicate:= '||'''ROWNUM < 1'''||';
            ELSIF l_sls_security_group = '||'''CEN'''||' THEN
                  d_predicate:= NULL;
            END IF;
        ELSE
            d_predicate:='||'''ROWNUM < 1'''||';
        END IF;
    END IF;
    RETURN d_predicate;
   END;';


 l_sql_grant:= 'GRANT EXECUTE ON '||sls_tab||'_FUN to PUBLIC';


 EXECUTE IMMEDIATE l_sql_stat;
 EXECUTE IMMEDIATE l_sql_grant;


EXCEPTION

 WHEN OTHERS THEN
     FND_MESSAGE.SET_NAME('IGI', 'IGI_LOGGING_USER_ERROR'); -- Seeded Message
     retcode := 2;
     errbuf :=  Fnd_message.get;
     igi_sls_objects_pkg .write_to_log(l_excep_level, 'cre_pol_function','END igi_sls_objects_pkg.create policy function - failed with error ' || SQLERRM );

     RETURN;

END cre_pol_function;

---------------------------------------------------------------
-- Now do the drop policy function procedure		     --
---------------------------------------------------------------
PROCEDURE drop_pol_function(sls_tab 	IN  VARCHAR2,
			    errbuf 	OUT NOCOPY VARCHAR2,
			    retcode 	OUT NOCOPY NUMBER)
IS

sql_stat VARCHAR2(2000);

no_function EXCEPTION;
PRAGMA EXCEPTION_INIT(no_function, -04043);

BEGIN

errbuf :='Normal Completion';
retcode := 0;


sql_stat:='DROP FUNCTION '||sls_tab||'_FUN';

EXECUTE IMMEDIATE sql_stat;


EXCEPTION

WHEN no_function
   THEN NULL;
   igi_sls_objects_pkg.write_to_log(l_excep_level, 'drop_pol_function','END igi_sls_objects_pkg.drop_pol_function'||sls_tab||'NO FUNCTION TO DROP');

WHEN OTHERS THEN
    	FND_MESSAGE.SET_NAME('IGI', 'IGI_LOGGING_USER_ERROR'); -- Seeded Message
	retcode := 2;
	errbuf :=  Fnd_message.get;
	igi_sls_objects_pkg .write_to_log(l_excep_level, 'drop_pol_function','END igi_sls_objects_pkg.drop_pol_function - failed with error ' || SQLERRM );

RETURN;

END drop_pol_function;

--------------------------------------------------------------
---- Now do the Add policy procedure			    --
--------------------------------------------------------------

PROCEDURE sls_add_pol(object_schema 	IN VARCHAR2,
		     table_name    	IN VARCHAR2,
		     policy_name   	IN VARCHAR2,
		     function_owner	IN VARCHAR2,
		     policy_function    IN VARCHAR2,
		     statement_types 	IN VARCHAR2,
		     errbuf 		OUT NOCOPY VARCHAR2,
		     retcode 		OUT NOCOPY NUMBER)
IS

policy_exists EXCEPTION;
PRAGMA EXCEPTION_INIT(policy_exists, -28101);

BEGIN

errbuf :='Normal Completion';
retcode := 0;

DBMS_RLS.ADD_POLICY (object_schema,
   	             table_name,
   		     policy_name,
   		     function_owner,
   		     policy_function,
   		     statement_types);


EXCEPTION

WHEN policy_exists
   THEN NULL;
igi_sls_objects_pkg.write_to_log(l_excep_level, 'sls_add_pol','END igi_sls_objects_pkg.sls_add_pol '||table_name||'POLICY ALREADY EXISTS ON THIS TABLE');

WHEN OTHERS THEN
     FND_MESSAGE.SET_NAME('IGI', 'IGI_LOGGING_USER_ERROR'); -- Seeded Message
     retcode := 2;
     errbuf :=  Fnd_message.get;
     igi_sls_objects_pkg.write_to_log(l_excep_level, 'sls_add_pol','END igi_sls_objects_pkg.sls_add_pol - failed with error ' || SQLERRM );

RETURN;

END sls_add_pol;

------------------------------------------------------------------
-- Now add the drop policy procedure				--
------------------------------------------------------------------

PROCEDURE sls_drop_pol (object_schema 	IN VARCHAR2,
			table_name    	IN VARCHAR2,
			policy_name   	IN VARCHAR2,
			errbuf	 	OUT NOCOPY VARCHAR2,
			retcode 	OUT NOCOPY NUMBER)
IS
no_policy  EXCEPTION;
PRAGMA EXCEPTION_INIT(no_policy,-28102);

BEGIN

errbuf :='Normal Completion';
retcode := 0;

DBMS_RLS.DROP_POLICY (object_schema,
          	      table_name,
       		      policy_name);


EXCEPTION

WHEN no_policy THEN NULL;

  WHEN OTHERS THEN
     FND_MESSAGE.SET_NAME('IGI', 'IGI_LOGGING_USER_ERROR'); -- Seeded Message
     retcode := 2;
     errbuf :=  Fnd_message.get;
     igi_sls_objects_pkg.write_to_log(l_excep_level, 'sls_drop_pol','END igi_sls_objects_pkg.sls_drop_pol - failed with error ' || SQLERRM );

RETURN;

END sls_drop_pol;

---------------------------------------------------------------
-- Now add the refresh policy				     --
---------------------------------------------------------------

PROCEDURE sls_refresh_pol(object_schema IN VARCHAR2,
			 table_name    	IN VARCHAR2,
			 policy_name   	IN VARCHAR2,
			 errbuf 	OUT NOCOPY VARCHAR2,
			 retcode 	OUT NOCOPY NUMBER)
IS

no_policy  EXCEPTION;
PRAGMA EXCEPTION_INIT(no_policy,-28102);

BEGIN

errbuf :='Normal Completion';
retcode := 0;

DBMS_RLS.REFRESH_POLICY (object_schema,
   			 table_name,
   		         policy_name);



EXCEPTION
  WHEN OTHERS THEN
     FND_MESSAGE.SET_NAME('IGI', 'IGI_LOGGING_USER_ERROR'); -- Seeded Message
     retcode := 2;
     errbuf :=  Fnd_message.get;
     igi_sls_objects_pkg.write_to_log(l_excep_level, 'sls_refresh_pol','END igi_sls_objects_pkg.sls_refresh_pol - failed with error ' || SQLERRM );

RETURN;

END sls_refresh_pol;

--------------------------------------------------------------
-- IF ACTION IS ENABLE THEN ENABLE THE POLICY		    --
--------------------------------------------------------------

PROCEDURE sls_enable_pol(object_schema 	IN VARCHAR2,
			table_name    	IN VARCHAR2,
			policy_name   	IN VARCHAR2,
			enable		IN BOOLEAN,
			errbuf 		OUT NOCOPY VARCHAR2,
			retcode 	OUT NOCOPY NUMBER)
IS

BEGIN

errbuf :='Normal Completion';
retcode := 0;

DBMS_RLS.ENABLE_POLICY (object_schema,
   			table_name,
   			policy_name,
   			enable);


EXCEPTION
  WHEN OTHERS THEN
     FND_MESSAGE.SET_NAME('IGI', 'IGI_LOGGING_USER_ERROR'); -- Seeded Message
     retcode := 2;
     errbuf :=  Fnd_message.get;
     igi_sls_objects_pkg.write_to_log(l_excep_level, 'sls_enable_pol','END igi_sls_objects_pkg.sls_enable_pol - failed with error ' || SQLERRM );

RETURN;


END sls_enable_pol;

----------------------------------------------------------
-- Now do the disable policy  procedure				--
----------------------------------------------------------

PROCEDURE sls_disable_pol
			(object_schema 	IN VARCHAR2,
			table_name    	IN VARCHAR2,
			policy_name   	IN VARCHAR2,
			enable 		IN BOOLEAN,
			errbuf 		OUT NOCOPY VARCHAR2,
			retcode 	OUT NOCOPY NUMBER)
IS

no_policy  EXCEPTION;
PRAGMA EXCEPTION_INIT(no_policy,-28102);

BEGIN

errbuf :='Normal Completion';
retcode := 0;

DBMS_RLS.ENABLE_POLICY (object_schema,
   			table_name,
   			policy_name,
   			FALSE);

EXCEPTION
WHEN no_policy
  THEN NULL;

WHEN OTHERS THEN
     FND_MESSAGE.SET_NAME('IGI', 'IGI_LOGGING_USER_ERROR'); -- Seeded Message
     retcode := 2;
     errbuf :=  Fnd_message.get;
     igi_sls_objects_pkg.write_to_log(l_excep_level, 'sls_disable_pol','END igi_sls_objects_pkg.sls_disable_pol - failed with error ' || SQLERRM );

RETURN;

END sls_disable_pol;

-- Start of alernate solution Code
-- Bidisha , 27 Mar 2002
PROCEDURE create_sls_col (sec_tab       IN VARCHAR,
                          schema_name   IN VARCHAR2,
                          errbuf        OUT NOCOPY VARCHAR2,
                          retcode       OUT NOCOPY NUMBER)
IS
   l_sql_stat varchar2(300);
   already_exists EXCEPTION;
   PRAGMA EXCEPTION_INIT(already_exists, -01430);


BEGIN

   errbuf :='Normal Completion';
   retcode := 0;

   l_sql_stat := 'BEGIN '||schema_name||'.apps_ddl.apps_ddl('||'''ALTER TABLE '||schema_name||'.'||sec_tab||' ADD (IGI_SLS_SEC_GROUP VARCHAR2(30))'''||');END;';

   EXECUTE IMMEDIATE l_sql_stat;


EXCEPTION

   WHEN already_exists
   THEN
       NULL;

   WHEN OTHERS
   THEN
      FND_MESSAGE.SET_NAME('IGI', 'IGI_LOGGING_USER_ERROR'); -- Seeded Message
      retcode := 2;
      errbuf :=  Fnd_message.get;
      igi_sls_objects_pkg .write_to_log(l_excep_level, 'create_sls_col','END igi_sls_objects_pkg.create_sls_col - failed with error ' || SQLERRM );

       RETURN;

END create_sls_col;

PROCEDURE create_sls_core_inx
                       (sec_tab         IN  VARCHAR2,
                        sls_tab         IN  VARCHAR2,
                        schema_name     IN  VARCHAR2,
                        errbuf          OUT NOCOPY VARCHAR2,
                        retcode         OUT NOCOPY NUMBER)

IS

   check_ts_mode varchar2(100);
   check_tspace_exists varchar2(100);
   physical_tspace_name varchar2(100);
   l_app_short_name varchar2(100);
   l_app_id number;
   l_sql_inx           VARCHAR2(500);
   already_exists      EXCEPTION;
   col_indexed         EXCEPTION;
   PRAGMA EXCEPTION_INIT(already_exists, -00955);
   PRAGMA EXCEPTION_INIT(col_indexed, -01408);

BEGIN

   errbuf :='Normal Completion';
   retcode := 0;

   select fpi.application_id
   into l_app_id
   from fnd_product_installations fpi, fnd_oracle_userid foui
   where foui.oracle_id = fpi.oracle_id
   and foui.oracle_username = schema_name;

   ad_tspace_util.is_new_ts_mode(check_ts_mode);
   l_app_short_name := ad_tspace_util.get_product_short_name(l_app_id);
   ad_tspace_util.get_tablespace_name(l_app_short_name, 'TRANSACTION_INDEXES', 'Y', check_tspace_exists, physical_tspace_name);

   If (check_ts_mode = 'Y') and (check_tspace_exists = 'Y') THEN

      l_sql_inx:= 'BEGIN '||schema_name||'.apps_ddl.apps_ddl ('||'''CREATE INDEX '||sls_tab||'_GRP_N1 ON '||schema_name||'.'||sec_tab||' (IGI_SLS_SEC_GROUP) TABLESPACE '||physical_tspace_name||''''||');END;';

   Else

      l_sql_inx:= 'BEGIN '||schema_name||'.apps_ddl.apps_ddl ('||'''CREATE INDEX '||sls_tab||'_GRP_N1 ON '||schema_name||'.'||sec_tab||' (IGI_SLS_SEC_GROUP)'''||');END;';

   End If;

   EXECUTE IMMEDIATE l_sql_inx;

   EXCEPTION
      WHEN already_exists
      THEN
          NULL;

      WHEN col_indexed
      THEN
          NULL;
   WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('IGI', 'IGI_LOGGING_USER_ERROR'); -- Seeded Message
    retcode := 2;
    errbuf :=  Fnd_message.get;
    igi_sls_objects_pkg .write_to_log(l_excep_level, 'create_sls_core_inx','END igi_sls_objects_pkg.create_sls_core_inx - failed with error ' || SQLERRM );

    RETURN;

END create_sls_core_inx;

PROCEDURE drop_sls_col (sec_tab         IN  VARCHAR,
                        schema_name     IN  VARCHAR2,
                        errbuf          OUT NOCOPY VARCHAR2,
                        retcode         OUT NOCOPY NUMBER)
IS
   l_sql_stat	VARCHAR2(300);
   no_column    EXCEPTION;
   PRAGMA EXCEPTION_INIT(no_column, -00904);

BEGIN

   errbuf :='Normal Completion';
   retcode := 0;

   l_sql_stat:= 'BEGIN '||schema_name||'.apps_ddl.apps_ddl('||'''ALTER TABLE '||schema_name||'.'||sec_tab||' DROP (IGI_SLS_SEC_GROUP)'');END;';

   EXECUTE IMMEDIATE l_sql_stat;


EXCEPTION

   WHEN no_column
   THEN NULL;

   WHEN OTHERS
   THEN
	FND_MESSAGE.SET_NAME('IGI', 'IGI_LOGGING_USER_ERROR'); -- Seeded Message
	retcode := 2;
      	errbuf :=  Fnd_message.get;
        igi_sls_objects_pkg .write_to_log(l_excep_level, 'drop_sls_col','END igi_sls_objects_pkg.drop_sls_col  - failed with error ' || SQLERRM );

RETURN;

END drop_sls_col;

---------------------------------------------------------------
-- Procedure to Create sls trigger			     --
---------------------------------------------------------------

PROCEDURE create_sls_col_trg(sls_tab 	IN VARCHAR2,
			 sec_tab 	IN VARCHAR2,
			 errbuf 	OUT NOCOPY VARCHAR2,
			 retcode 	OUT NOCOPY NUMBER)

IS
l_user    varchar2(5);
l_sql_trg VARCHAR2(5000);

BEGIN

l_user  := 'IGI';
errbuf  :='Normal Completion';
retcode := 0;


l_sql_trg:= 'CREATE OR REPLACE TRIGGER '||sls_tab||'_TRG BEFORE INSERT OR DELETE ON '||sec_tab ||' FOR EACH ROW

DECLARE

l_sec_grp VARCHAR2(30);
l_status  VARCHAR2(5);
l_history VARCHAR2(30):='||'''IGI_SLS_MAINTAIN_HISTORY'''||';
l_value	  VARCHAR2(5);
l_valid1  NUMBER;
l_valid2  NUMBER;

CURSOR C1 (c_l_sec_grp VARCHAR2)IS
           SELECT 1
           FROM igi_sls_allocations
           WHERE sls_group = c_l_sec_grp
           AND sls_allocation = '||''''||sec_tab||''''||'
           AND date_removed IS NULL ;

CURSOR C2 (c_l_sec_grp VARCHAR2)IS
             SELECT 1
             FROM igi_sls_allocations a,igi_sls_allocations b
             WHERE a.sls_allocation = b.sls_group
             AND a.sls_group =  c_l_sec_grp
             AND a.sls_group_type = '||'''S'''||'
             AND b.sls_group_type = '||'''P'''||'
             AND a.sls_allocation_type = '||'''P'''||'
             AND b.sls_allocation_type = '||'''T'''||'
             AND b.sls_allocation = '||''''||sec_tab||''''||'
             AND a.date_removed IS NULL
             AND b.date_removed IS NULL;
BEGIN
IF INSERTING THEN
   BEGIN
      IF SYS_CONTEXT('||'''IGI'''||','||'''SLS_RESPONSIBILITY'''||')='||'''Y'''||' THEN
           l_sec_grp:=SYS_CONTEXT('||'''IGI'''||','||'''SLS_SECURITY_GROUP'''||');
	   IF l_sec_grp IS NOT NULL AND l_sec_grp != '||'''CEN'''||' THEN
              OPEN C1(l_sec_grp);
              FETCH C1 INTO l_valid1;
              IF C1%NOTFOUND THEN
                 l_valid1 := 0;
              END IF;
              CLOSE C1;
              IF l_valid1 = 0 THEN
                 OPEN C2(l_sec_grp);
                 FETCH C2 INTO l_valid2;
                 IF C2%NOTFOUND THEN
                    l_valid2 := 0;
                 END IF;
                 CLOSE C2;
              END IF;
              IF l_valid1 = 1 OR l_valid2 = 1 THEN

                 l_status:= SYS_CONTEXT('||'''IGI'''||','||'''SLS_GROUP_STATUS'''||');
		 IF l_status = '||'''N'''||' THEN
                    l_value := Nvl(FND_PROFILE.VALUE(l_history),'||'''N'''||');
                 END IF;
 		 IF l_value = '||'''Y'''||' OR l_status = '||'''Y'''||' THEN
                    :NEW.IGI_SLS_SEC_GROUP := l_sec_grp;
		 END IF;
	      END IF; -- Secure Table
	   END IF; -- Not CEN group
        END IF; -- SLS Enabled / SLS Responsibility
    END;
END IF; -- If Inserting
IF DELETING THEN
   BEGIN
      delete from '||l_user||'.'||sls_tab||' where sls_rowid=:old.rowid;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN NULL;
      WHEN OTHERS THEN NULL;
   END;
END IF;
END;'; -- If deleting


EXECUTE IMMEDIATE l_sql_trg;


EXCEPTION
  WHEN OTHERS THEN
     FND_MESSAGE.SET_NAME('IGI', 'IGI_LOGGING_USER_ERROR'); -- Seeded Message
     retcode := 2;
     errbuf :=  Fnd_message.get;
     igi_sls_objects_pkg.write_to_log(l_excep_level, 'create_sls_col_trg','END igi_sls_objects_pkg.create sls col trigger - failed with error ' || SQLERRM );

RETURN;

END create_sls_col_trg;

PROCEDURE cre_ext_col_pol_func(sec_tab  IN VARCHAR2,
                           sls_tab      IN VARCHAR2,
                           errbuf       OUT NOCOPY VARCHAR2,
                           retcode      OUT NOCOPY NUMBER)

IS

   l_sql_stat  VARCHAR2(2000);
   l_sql_grant VARCHAR2(100);

BEGIN

  errbuf :='Normal Completion';
  retcode := 0;


  l_sql_stat :=
  'CREATE OR REPLACE FUNCTION '||sls_tab||'_FUN (D1 VARCHAR2, D2 VARCHAR2)
   RETURN VARCHAR2 AS
    l_valid               NUMBER;
    d_predicate           VARCHAR2(2000) := NULL;
    l_enable              VARCHAR2(10);
    l_sls_security_group  VARCHAR2(30);
    l_status              VARCHAR2(5);
    l_sls_responsibility  VARCHAR2(50);

    CURSOR c1 (c_sls_security_group varchar2)
    IS
     SELECT 1
     FROM igi_sls_security_group_alloc
     WHERE table_name = '||''''||sec_tab||''''||'
     AND sls_security_group = c_sls_security_group;

   BEGIN

     l_enable := NVL(SYS_CONTEXT('||'''IGI'''||','||'''SLS_RESPONSIBILITY'''||'),'||'''N'''||');

     IF l_enable = '||'''Y'''||' THEN

      l_sls_security_group :=SYS_CONTEXT('||'''IGI'''||','||'''SLS_SECURITY_GROUP'''||');
      l_status:=SYS_CONTEXT('||'''IGI'''||','||'''SLS_GROUP_STATUS'''||');

      IF l_status = '||'''Y'''||' THEN

         IF l_sls_security_group != '||'''CEN'''||' and l_sls_security_group is not null THEN
            OPEN c1(l_sls_security_group);
            FETCH c1 INTO l_valid;
            IF c1%NOTFOUND THEN
               l_valid:= 0;
            END IF;
            CLOSE c1;
            ';


    IF sec_tab = 'AR_PAYMENT_SCHEDULES_ALL' THEN
       l_sql_stat := l_sql_stat ||
           'IF l_valid = 1 THEN
               d_predicate:= '||''' (payment_schedule_id < 0 OR IGI_SLS_SEC_GROUP = '''||'||''''''''||l_sls_security_group||''''''''||'||''')'''||' ;
            END IF;
           ';
    ELSE
       l_sql_stat := l_sql_stat ||
           'IF l_valid = 1 THEN
               d_predicate:='||''' IGI_SLS_SEC_GROUP = '||'''||''''''''||l_sls_security_group||'''''''';
            END IF;
           ';
    END IF;

    l_sql_stat := l_sql_stat ||
       ' ELSIF l_sls_security_group IS NULL THEN
               d_predicate:= '||'''ROWNUM < 1'''||';
         ELSIF  l_sls_security_group = '||'''CEN'''||' THEN
              d_predicate:= NULL;
         END IF;
     ELSE
        d_predicate:='||'''ROWNUM < 1'''||';
     END IF;
   END IF;

   RETURN d_predicate;
   END;';

 l_sql_grant:= 'GRANT EXECUTE ON '||sls_tab||'_FUN to PUBLIC';

 EXECUTE IMMEDIATE l_sql_stat;
 EXECUTE IMMEDIATE l_sql_grant;

EXCEPTION

WHEN OTHERS THEN
     	FND_MESSAGE.SET_NAME('IGI', 'IGI_LOGGING_USER_ERROR'); -- Seeded Message
        retcode := 2;
        errbuf :=  Fnd_message.get;
	igi_sls_objects_pkg .write_to_log(l_excep_level, 'cre_ext_col_pol_func','END igi_sls_objects_pkg.create policy function - failed with error ' || SQLERRM );

RETURN;


END cre_ext_col_pol_func;

END igi_sls_objects_pkg;

/
