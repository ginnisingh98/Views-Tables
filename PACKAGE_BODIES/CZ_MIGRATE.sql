--------------------------------------------------------
--  DDL for Package Body CZ_MIGRATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CZ_MIGRATE" AS
/*	$Header: czmigrb.pls 120.5 2006/04/27 03:19:41 kdande ship $		*/

  G_OA_UI_STYLE      VARCHAR2(1) := '7';
  G_OA_UIMT_STYLE    VARCHAR2(1) := '5';

  thisMessageId      PLS_INTEGER;
  thisRunId          PLS_INTEGER;
  thisStatusCode     PLS_INTEGER;

  dbLinkName         user_db_links.db_link%TYPE;
  serverLocalName    cz_servers.local_name%TYPE;
  serverLocalId      cz_servers.server_local_id%TYPE;
  NoIntegrityCheck   BOOLEAN;

  PROCEDURE          adjust_specific_control;
  FUNCTION           verify_target_database RETURN PLS_INTEGER;
  TYPE ref_cursor IS REF CURSOR;

---------------------------------------------------------------------------------------
PROCEDURE setup_migration_cp(errbuf        OUT NOCOPY VARCHAR2,
                             retcode       OUT NOCOPY NUMBER,
                             p_source_name IN  VARCHAR2,
                             p_force_run   IN  VARCHAR2 DEFAULT 'NO') IS

  RunId      PLS_INTEGER;
  xError     PLS_INTEGER;
BEGIN

  retcode := CONCURRENT_SUCCESS;
  errbuf := '';
  xError := migrate_setup(RunId, p_source_name, p_force_run);

  IF(xError = FATAL_ERROR)THEN

    retcode := CONCURRENT_ERROR;

    --'Migration setup cannot continue due to the previous errors. Please see log for details.'
    errbuf := CZ_UTILS.GET_TEXT('CZ_MIGR_CANNOT_SETUP');
    report(errbuf, URGENCY_ERROR);

  ELSIF(xError = SKIPPABLE_ERROR)THEN

    --'Migration setup completed successfully with warnings. Please see log for details.'
    errbuf := CZ_UTILS.GET_TEXT('CZ_MIGR_WARNING_SETUP');
    report(errbuf, URGENCY_WARNING);
  END IF;

 DBMS_APPLICATION_INFO.SET_MODULE('','');
END setup_migration_cp;
---------------------------------------------------------------------------------------
PROCEDURE run_migration_cp(errbuf      OUT NOCOPY VARCHAR2,
                           retcode     OUT NOCOPY NUMBER,
                           p_force_run IN  VARCHAR2 DEFAULT 'NO') IS

  RunId      PLS_INTEGER;
  xError     PLS_INTEGER;
BEGIN

  retcode := CONCURRENT_SUCCESS;
  errbuf := '';
  xError := migrate(RunId, p_force_run,
                    500, 0, 0, 0, 0, 0, 0); -- defaults

  IF(xError = FATAL_ERROR)THEN

    retcode := CONCURRENT_ERROR;

    --'Migration cannot continue due to the previous errors. Please see log for details.'
    errbuf := CZ_UTILS.GET_TEXT('CZ_MIGR_CANNOT_CONTINUE');
    report(errbuf, URGENCY_ERROR);

  ELSIF(xError = SKIPPABLE_ERROR)THEN

    --'Migration completed successfully with warnings. Please see log for details.'
    errbuf := CZ_UTILS.GET_TEXT('CZ_MIGR_WARNING_RUN');
    report(errbuf, URGENCY_WARNING);
  END IF;

 DBMS_APPLICATION_INFO.SET_MODULE('','');
END run_migration_cp;
---------------------------------------------------------------------------------------
FUNCTION verify_server_entry(p_local_name IN VARCHAR2, x_link_name IN OUT NOCOPY VARCHAR2)
RETURN INTEGER IS
BEGIN

  SELECT server_local_id, fndnam_link_name INTO serverLocalId, x_link_name
  FROM cz_servers WHERE UPPER(local_name) = UPPER(p_local_name);

  IF(x_link_name IS NULL)THEN
    --'No database link is associated with the specified server name ''%LOCALNAME''.'
    report(CZ_UTILS.GET_TEXT('CZ_MIGR_EMPTY_LINK', 'LOCALNAME', p_local_name), URGENCY_ERROR);
    RETURN FATAL_ERROR;
  END IF;

  RETURN NO_ERROR;
EXCEPTION
  WHEN OTHERS THEN
    --'Unable to retrieve database link name for the specified server name ''%LOCALNAME'': %ERRORTEXT.'
    report(CZ_UTILS.GET_TEXT('CZ_MIGR_NO_DATABASE_LINK', 'LOCALNAME', p_local_name, 'ERRORTEXT', SQLERRM), URGENCY_ERROR);
    RETURN FATAL_ERROR;
END;
---------------------------------------------------------------------------------------
FUNCTION verify_database_link(p_link_name IN VARCHAR2)
RETURN INTEGER IS
BEGIN

  EXECUTE IMMEDIATE 'SELECT SYSDATE FROM DUAL@' || p_link_name;
  RETURN NO_ERROR;

EXCEPTION
  WHEN OTHERS THEN
    --'Database link ''%LINKNAME'' is not functional: %ERRORTEXT.'
    report(CZ_UTILS.GET_TEXT('CZ_MIGR_BAD_DATABASE_LINK', 'LINKNAME', p_link_name, 'ERRORTEXT', SQLERRM), URGENCY_ERROR);
    RETURN FATAL_ERROR;
END;
---------------------------------------------------------------------------------------
FUNCTION migrate_setup(x_run_id     IN OUT NOCOPY PLS_INTEGER,
                       p_local_name IN VARCHAR2,
                       p_force_run  IN VARCHAR2)
RETURN INTEGER IS

  xError          INTEGER;
  errorFlag       PLS_INTEGER;
  MigrationStatus cz_db_settings.value%TYPE;
BEGIN

  thisMessageId := MESSAGE_START_ID;
  thisStatusCode := SETUP_STATUS_CODE;
  thisRunId := NVL(x_run_id, GENERIC_RUN_ID);
  NoIntegrityCheck := FALSE;

  BEGIN
    IF(x_run_id IS NULL OR x_run_id = 0)THEN
      SELECT cz_xfr_run_infos_s.NEXTVAL INTO x_run_id FROM DUAL;
    END IF;
    thisRunId := x_run_id;
  EXCEPTION
    WHEN OTHERS THEN
      --'Unable to generate identification number for this process, database objects are missing or invalid: %ERRORTEXT.'
      report(CZ_UTILS.GET_TEXT('CZ_MIGR_NO_RUN_ID', 'ERRORTEXT', SQLERRM), URGENCY_ERROR);
      RETURN FATAL_ERROR;
  END;

  --Check for other running migration/setup sessions.

  FOR c_running IN (SELECT action FROM v$session WHERE module IN (
                      'CZMIGRATION',
                      'CZ_PB_MGR',
                      'CZ_MODEL_MIGRATION',
                      'CZIMPORT',
                      CZ_PUBL_SYNC_CRASH.pbSourceClone,
                      CZ_PUBL_SYNC_CRASH.pbTargetClone,
                      CZ_PUBL_SYNC_CRASH.pbSourceCrash,
                      CZ_PUBL_SYNC_CRASH.pbTargetCrash,
                      CZ_RULE_IMPORT.CZRI_MODULE_NAME)) LOOP

    --'Unable to start a new migration session because another migration session or an incompatible concurrent'
    --'program is currently running.'
    report(CZ_UTILS.GET_TEXT('CZ_MIGR_SESSION_EXISTS'), URGENCY_ERROR);
    RETURN FATAL_ERROR;
  END LOOP;

  DBMS_APPLICATION_INFO.SET_MODULE('CZMIGRATION', TO_CHAR(x_run_id));

  BEGIN
   SELECT value INTO MigrationStatus FROM cz_db_settings
   WHERE UPPER(section_name) = 'MIGRATE' AND UPPER(setting_id) = 'MIGRATIONSTATUS';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      --No setting is normal.
      NULL;
    WHEN OTHERS THEN
      --'Unable to read the migration status because of %ERRORTEXT.'
      report(CZ_UTILS.GET_TEXT('CZ_MIGR_NO_STATUS', 'ERRORTEXT', SQLERRM), URGENCY_ERROR);
      RETURN FATAL_ERROR;
  END;

  IF(verify_server_entry(p_local_name, dbLinkName) = FATAL_ERROR)THEN RETURN FATAL_ERROR; END IF;
  IF(verify_database_link(dbLinkName) = FATAL_ERROR)THEN RETURN FATAL_ERROR; END IF;

  --Check for the emptiness of the target database. FATAL_ERROR, can be overridden with p_force_run.

  BEGIN

    xError := verify_target_database;

    IF(xError = SKIPPABLE_ERROR)THEN
      IF(UPPER(MigrationStatus) IN ('STARTED', 'COMPLETED'))THEN

        --'Migration setup cannot be started after the migration has been run.'
        report(CZ_UTILS.GET_TEXT('CZ_MIGR_CANNOT_RUN_SETUP'), URGENCY_ERROR);
        RETURN FATAL_ERROR;
      ELSIF(UPPER(p_force_run) = 'NO')THEN

        --'The target database is not a fresh installed Applications database, running migration may cause data corruption.'
        report(CZ_UTILS.GET_TEXT('CZ_MIGR_TARGET_NOT_EMPTY'), URGENCY_ERROR);
        RETURN FATAL_ERROR;
      END IF;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      --'Unable to verify the target database: %ERRORTEXT.'
      report(CZ_UTILS.GET_TEXT('CZ_MIGR_TARGET_VERIFY', 'ERRORTEXT', SQLERRM), URGENCY_ERROR);
      RETURN FATAL_ERROR;
  END;

  xError := compare_versions;

  IF(xError <> NO_ERROR)THEN RETURN FATAL_ERROR; END IF;

  --Populate the control table.

  BEGIN

    DELETE FROM cz_xfr_tables WHERE UPPER(xfr_group) IN
     ('OVERRIDE', 'SLOWREFRESH', 'MIGRATE', 'REFRESH', 'FORCESLOW', 'TRIGGERS', 'SEQUENCES');

    INSERT INTO cz_xfr_tables (order_seq, xfr_group, disabled, dst_table, pk_useexpansion)
    SELECT ROWNUM, 'OVERRIDE', '0', table_name, DECODE(logging, 'YES', 'Y', 'NO', 'N', 'N')
      FROM all_tables
     WHERE owner = 'CZ';

    INSERT INTO cz_xfr_tables (order_seq, xfr_group, disabled, dst_table)
    SELECT ROWNUM, 'TRIGGERS', '0', trigger_name
      FROM user_triggers
     WHERE status = 'ENABLED'
       AND trigger_name LIKE 'CZ/_%' ESCAPE '/';

    adjust_specific_control;

  EXCEPTION
    WHEN OTHERS THEN
     ROLLBACK;
     --'Unable to populate migration control table: %ERRORTEXT.'
     report(CZ_UTILS.GET_TEXT('CZ_MIGR_CONTROL_ERROR', 'ERRORTEXT', SQLERRM), URGENCY_ERROR);
     RETURN FATAL_ERROR;
  END;

  errorFlag := 0;

  FOR c_tables IN (SELECT dst_table FROM cz_xfr_tables
                    WHERE xfr_group in ('OVERRIDE', 'SLOWREFRESH', 'MIGRATE', 'REFRESH', 'FORCESLOW')
                      AND disabled = '0') LOOP

    xError := compare_columns(c_tables.dst_table);
    IF(xError <> NO_ERROR)THEN errorFlag := 1; END IF;
  END LOOP;

  IF(errorFlag = 1)THEN ROLLBACK; RETURN FATAL_ERROR; END IF;

  BEGIN
    INSERT INTO cz_db_settings (section_name, setting_id, data_type, value)
    SELECT 'MIGRATE', 'SourceServer', 4, p_local_name FROM DUAL WHERE NOT EXISTS
      (SELECT NULL FROM cz_db_settings
        WHERE UPPER(section_name) = 'MIGRATE' and UPPER(setting_id) = 'SOURCESERVER');

    UPDATE cz_db_settings SET value = p_local_name
    WHERE UPPER(section_name) = 'MIGRATE' AND UPPER(setting_id) = 'SOURCESERVER';

    INSERT INTO cz_db_settings (section_name, setting_id, data_type, value)
    SELECT 'MIGRATE', 'MigrationStatus', 4, 'INSTALLED' FROM DUAL WHERE NOT EXISTS
      (SELECT NULL FROM cz_db_settings
        WHERE UPPER(section_name) = 'MIGRATE' and UPPER(setting_id) = 'MIGRATIONSTATUS');

    UPDATE cz_db_settings SET value = 'INSTALLED'
    WHERE UPPER(section_name) = 'MIGRATE' AND UPPER(setting_id) = 'MIGRATIONSTATUS';

    COMMIT;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      --'Unable to update the migration status because of %ERRORTEXT.'
      report(CZ_UTILS.GET_TEXT('CZ_MIGR_NO_STATUS_UPDATE', 'ERRORTEXT', SQLERRM), URGENCY_ERROR);
      RETURN FATAL_ERROR;
  END;
 RETURN NO_ERROR;
END migrate_setup;

---------------------------------------------------------------------------------------
/* defaults
   p_force_run            IN VARCHAR2 DEFAULT 'NO',
   CommitSize             in pls_integer default 500,
   StopOnSkippable        in number default 0,
   ForceSlowMode          in number default 0,
   AllowDifferentVersions in number default 0,
   AllowRefresh           in number default 0,
   ForceProcess           in number default 0,
   DeleteDbLink           in number default 0
*/
FUNCTION migrate(x_run_id               IN OUT NOCOPY PLS_INTEGER,
                 p_force_run            IN VARCHAR2,
                 CommitSize             in pls_integer,
                 StopOnSkippable        in number,
                 ForceSlowMode          in number,
                 AllowDifferentVersions in number,
                 AllowRefresh           in number,
                 ForceProcess           in number,
                 DeleteDbLink           in number)
RETURN INTEGER IS

  xError         INTEGER;
  xMsgCount      INTEGER;
  xReturnStatus  VARCHAR2(255);
  xMsgData       VARCHAR2(32000);

  MigrationStatus cz_db_settings.value%TYPE;
  sourceMaxId     cz_servers.server_local_id%TYPE;
  targetMaxId     cz_servers.server_local_id%TYPE;
  srcPbSessionCnt NUMBER := 0;
  l_src_sessn_cur REF_CURSOR;
begin

  thisMessageId := MESSAGE_START_ID;
  thisStatusCode := MIGRATE_STATUS_CODE;
  thisRunId := NVL(x_run_id, GENERIC_RUN_ID);
  NoIntegrityCheck := TRUE;

  BEGIN
    IF(x_run_id IS NULL OR x_run_id = 0)THEN
      SELECT cz_xfr_run_infos_s.NEXTVAL INTO x_run_id FROM DUAL;
    END IF;
    thisRunId := x_run_id;
  EXCEPTION
    WHEN OTHERS THEN
      --'Unable to generate identification number for this process, database objects are missing or invalid: %ERRORTEXT.'
      report(CZ_UTILS.GET_TEXT('CZ_MIGR_NO_RUN_ID', 'ERRORTEXT', SQLERRM), URGENCY_ERROR);
      RETURN FATAL_ERROR;
  END;

  --Check for other running migration/setup sessions.

  FOR c_running IN (SELECT action FROM v$session WHERE module IN (
                      'CZMIGRATION',
                      'CZ_PB_MGR',
                      'CZ_MODEL_MIGRATION',
                      'CZIMPORT',
                      CZ_PUBL_SYNC_CRASH.pbSourceClone,
                      CZ_PUBL_SYNC_CRASH.pbTargetClone,
                      CZ_PUBL_SYNC_CRASH.pbSourceCrash,
                      CZ_PUBL_SYNC_CRASH.pbTargetCrash,
                      CZ_RULE_IMPORT.CZRI_MODULE_NAME)) LOOP

    --'Unable to start a new migration session because another migration session or an incompatible concurrent'
    --'program is currently running.'
    report(CZ_UTILS.GET_TEXT('CZ_MIGR_SESSION_EXISTS'), URGENCY_ERROR);
    RETURN FATAL_ERROR;
  END LOOP;

  DBMS_APPLICATION_INFO.SET_MODULE('CZMIGRATION', TO_CHAR(x_run_id));

  BEGIN
    SELECT value INTO MigrationStatus FROM cz_db_settings
     WHERE UPPER(section_name) = 'MIGRATE' AND UPPER(setting_id) = 'MIGRATIONSTATUS';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      --'Unable to read the migration status, no record exists. Please make sure the migration setup
      -- concurrent program has been properly run.'
      report(CZ_UTILS.GET_TEXT('CZ_MIGR_NO_STATUS_DATA'), URGENCY_ERROR);
      RETURN FATAL_ERROR;
    WHEN OTHERS THEN
      --'Unable to read the migration status because of %ERRORTEXT.'
      report(CZ_UTILS.GET_TEXT('CZ_MIGR_NO_STATUS', 'ERRORTEXT', SQLERRM), URGENCY_ERROR);
      RETURN FATAL_ERROR;
  END;

  BEGIN
    SELECT value INTO serverLocalName FROM cz_db_settings
     WHERE UPPER(section_name) = 'MIGRATE' and UPPER(setting_id) = 'SOURCESERVER';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      --'Unable to read the source server name, no record exists. Please make sure the migration setup
      -- concurrent program has been properly run.'
      report(CZ_UTILS.GET_TEXT('CZ_MIGR_NO_SERVER_NAME'), URGENCY_ERROR);
      RETURN FATAL_ERROR;
    WHEN OTHERS THEN
      --'Unable to read the source server name because of %ERRORTEXT.'
      report(CZ_UTILS.GET_TEXT('CZ_MIGR_NO_SERVER', 'ERRORTEXT', SQLERRM), URGENCY_ERROR);
      RETURN FATAL_ERROR;
  END;

  IF(verify_server_entry(serverLocalName, dbLinkName) = FATAL_ERROR)THEN RETURN FATAL_ERROR; END IF;
  IF(verify_database_link(dbLinkName) = FATAL_ERROR)THEN RETURN FATAL_ERROR; END IF;

  --Check for the emptiness of the target database. FATAL_ERROR, can be overridden with p_force_run.

  BEGIN

    xError := verify_target_database;

    IF(xError = SKIPPABLE_ERROR)THEN
      IF(UPPER(MigrationStatus) = 'COMPLETED')THEN

        --'Migration has successfully completed for this database. Running the migration again may cause data corruption.'
        report(CZ_UTILS.GET_TEXT('CZ_MIGR_COMPLETED_BEFORE'), URGENCY_ERROR);
        RETURN FATAL_ERROR;
      ELSIF(UPPER(p_force_run) = 'NO')THEN

        --'The target database is not a fresh installed Applications database, running migration may cause data corruption.'
        report(CZ_UTILS.GET_TEXT('CZ_MIGR_TARGET_NOT_EMPTY'), URGENCY_ERROR);
        RETURN FATAL_ERROR;
      END IF;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      --'Unable to verify the target database: %ERRORTEXT.'
      report(CZ_UTILS.GET_TEXT('CZ_MIGR_TARGET_VERIFY', 'ERRORTEXT', SQLERRM), URGENCY_ERROR);
      RETURN FATAL_ERROR;
  END;

  begin
   update cz_db_settings set value = 'STARTED'
   where UPPER(section_name) = 'MIGRATE' and UPPER(setting_id) = 'MIGRATIONSTATUS';
  exception
    when others then
      --'Unable to update the migration status because of %ERRORTEXT.'
      report(CZ_UTILS.GET_TEXT('CZ_MIGR_NO_STATUS_UPDATE', 'ERRORTEXT', SQLERRM), URGENCY_ERROR);
      RETURN FATAL_ERROR;
  end;

  xError := compare_versions;

  if(xError = FATAL_ERROR OR (xError = SKIPPABLE_ERROR and AllowDifferentVersions = 0))then

    RETURN FATAL_ERROR;
  end if;

  xError := disable_triggers(StopOnSkippable);

  if(xError = FATAL_ERROR OR (xError = SKIPPABLE_ERROR and StopOnSkippable = 1))then

    RETURN FATAL_ERROR;
  end if;

  --Start of the table-specific data preparation section----------------------------------------------------

  --CZ_SERVERS: we need to make sure that the current server entry would not conflict with a server entry in
  --the source table. Do this only if CZ_SERVERS is on the processing list and only for 'MIGRATE' operation.

  FOR c_table IN (SELECT NULL FROM cz_xfr_tables
                   WHERE UPPER(dst_table) = 'CZ_SERVERS'
                     AND UPPER(xfr_group) = 'MIGRATE'
                     AND disabled = '0'
                     AND ROWNUM = 1) LOOP

    BEGIN

      EXECUTE IMMEDIATE 'SELECT MAX(server_local_id) FROM cz_servers' INTO targetMaxId;
      EXECUTE IMMEDIATE 'SELECT MAX(server_local_id) FROM cz_servers@' || dbLinkName INTO sourceMaxId;

      UPDATE cz_servers SET
        server_local_id = GREATEST(NVL(sourceMaxId, 0), NVL(targetMaxId, 0))
      WHERE server_local_id = serverLocalId
      RETURNING server_local_id INTO serverLocalId;

    EXCEPTION
      WHEN OTHERS THEN

        --'Error in table-specific data preparation for the table ''%TABLENAME'': %ERRORTEXT.'
        report(CZ_UTILS.GET_TEXT('CZ_MIGR_PREPARE_ERROR', 'TABLENAME', 'CZ_SERVERS', 'ERRORTEXT', SQLERRM), URGENCY_WARNING);

        IF(StopOnSkippable = 1)THEN RETURN FATAL_ERROR; END IF;
    END;
  END LOOP;

  --End of the table-specific data preparation section------------------------------------------------------

  FOR c_tables IN (SELECT dst_table FROM cz_xfr_tables
                    WHERE xfr_group IN ('OVERRIDE', 'SLOWREFRESH', 'MIGRATE', 'REFRESH', 'FORCESLOW')
                      AND disabled = '0' AND pk_useexpansion = 'Y') LOOP

    EXECUTE IMMEDIATE 'ALTER TABLE ' || CONFIGURATOR_SCHEMA || '.' || c_tables.dst_table || ' NOLOGGING';
  END LOOP;

  xError := copy_all_tables(CommitSize, StopOnSkippable, AllowRefresh, ForceSlowMode, ForceProcess);

  FOR c_tables IN (SELECT dst_table FROM cz_xfr_tables
                    WHERE xfr_group IN ('OVERRIDE', 'SLOWREFRESH', 'MIGRATE', 'REFRESH', 'FORCESLOW')
                      AND disabled = '0' AND pk_useexpansion = 'Y') LOOP

    EXECUTE IMMEDIATE 'ALTER TABLE ' || CONFIGURATOR_SCHEMA || '.' || c_tables.dst_table || ' LOGGING';
  END LOOP;

  if(xError = FATAL_ERROR or (xError = SKIPPABLE_ERROR and StopOnSkippable = 1))then

    xError := enable_triggers(StopOnSkippable);

    if(xError = FATAL_ERROR OR (xError = SKIPPABLE_ERROR and StopOnSkippable = 1))then

      RETURN FATAL_ERROR;
    end if;

    RETURN FATAL_ERROR;
  end if;

  xError := enable_triggers(StopOnSkippable);

  if(xError = FATAL_ERROR OR (xError = SKIPPABLE_ERROR and StopOnSkippable = 1))then

    RETURN FATAL_ERROR;
  end if;

  xError := adjust_all_sequences(StopOnSkippable);

  if(xError = FATAL_ERROR OR (xError = SKIPPABLE_ERROR and StopOnSkippable = 1))then

    RETURN FATAL_ERROR;
  end if;

  --
  -- copy JRAD documents associated with a given ui_def_id +++
  --

  ----check if a pub sync or publishing process is running on the instance
  ----from which the data is being migrated.
 OPEN l_src_sessn_cur FOR 'SELECT count(*) FROM  v$session@'||dbLinkName|| ' t where t.module = ''PUBLISH_MODEL''';
 LOOP
  FETCH l_src_sessn_cur INTO srcPbSessionCnt;
  EXIT WHEN l_src_sessn_cur%NOTFOUND;
  IF (srcPbSessionCnt > 0) THEN
    ----'An existing sync or publishing process is in progress. Re run after these processes complete.'
    report(CZ_UTILS.GET_TEXT('CZ_PB_SYNC_PROCESS_EXISTS'), URGENCY_ERROR);
    RETURN FATAL_ERROR;
  END IF;
 END LOOP;
 CLOSE l_src_sessn_cur;

EXECUTE IMMEDIATE
 'begin DBMS_APPLICATION_INFO.SET_MODULE@'||dbLinkName||'(:1, :2);  end;' USING 'PUBLISH_MODEL',TO_CHAR(x_run_id) ;

  FOR i IN(SELECT ui_def_id FROM CZ_UI_DEFS
           WHERE deleted_flag='0' AND ui_style IN(G_OA_UIMT_STYLE,G_OA_UI_STYLE))
  LOOP
     import_jrad_docs (p_ui_def_id     => i.ui_def_id,
                       p_link_name     => dbLinkName,
                       x_return_status => xReturnStatus,
                       x_msg_count     => xMsgCount,
                       x_msg_data      => xMsgData);

    IF(xReturnStatus = FND_API.G_RET_STS_ERROR)THEN

      --Bug #4058286 - do not stop if a jrad document is missing.

      report(xMsgData, URGENCY_WARNING);

    ELSIF(xReturnStatus = FND_API.G_RET_STS_UNEXP_ERROR)THEN

       report(xMsgData, URGENCY_ERROR);
       RETURN FATAL_ERROR;
    END IF;
  END LOOP;

  import_template_jrad_docs (p_link_name     => dbLinkName,
                                       x_return_status => xReturnStatus,
                                       x_msg_count     => xMsgCount,
                                       x_msg_data      => xMsgData);

    IF(xReturnStatus = FND_API.G_RET_STS_ERROR)THEN

      --Bug #4058286 - do not stop if a jrad document is missing.

      report(xMsgData, URGENCY_WARNING);

    ELSIF(xReturnStatus = FND_API.G_RET_STS_UNEXP_ERROR)THEN

       report(xMsgData, URGENCY_ERROR);
       RETURN FATAL_ERROR;
    END IF;

   -----reset module info on the target
   EXECUTE IMMEDIATE
   'begin DBMS_APPLICATION_INFO.SET_MODULE@'||dbLinkName||'(:1, :2); end;' USING '','' ;

  begin
   update cz_db_settings set value='COMPLETED'
   where section_name='MIGRATE' and setting_id='MigrationStatus';
  exception
    when others then
      --'Migration was unable to update the migration status because of %ERRORTEXT.'
      report(CZ_UTILS.GET_TEXT('CZ_MIGR_NO_STATUS_COMPLETE', 'ERRORTEXT', SQLERRM), URGENCY_WARNING);
      RETURN SKIPPABLE_ERROR;
  end;

  if(DeleteDbLink = 1)then
   declare
     cdyn  integer;
     rdyn  integer;
   begin
     cdyn := dbms_sql.open_cursor;
     dbms_sql.parse(cdyn,'drop database link '||dbLinkName,dbms_sql.native);
     rdyn := dbms_sql.execute(cdyn);
     dbms_sql.close_cursor(cdyn);
   exception
     when others then
       if(dbms_sql.is_open(cdyn))then dbms_sql.close_cursor(cdyn); end if;
       --'Migration was unable to delete the database link because of %ERRORTEXT.'
       report(CZ_UTILS.GET_TEXT('CZ_MIGR_NO_LINK_DELETE', 'ERRORTEXT', SQLERRM), URGENCY_WARNING);
       RETURN SKIPPABLE_ERROR;
   end;
  end if;
 RETURN NO_ERROR;
end;
------------------------------------------------------------------------------------------------------------
FUNCTION compare_versions RETURN INTEGER IS

  tMajorVersion  cz_db_settings.value%TYPE;
  tMinorVersion  cz_db_settings.value%TYPE;
  sMajorVersion  cz_db_settings.value%TYPE;
  sMinorVersion  cz_db_settings.value%TYPE;

BEGIN

  BEGIN

    SELECT UPPER(value) INTO tMajorVersion FROM cz_db_settings
     WHERE UPPER(section_name) = 'SCHEMA'
       AND UPPER(setting_id) = 'MAJOR_VERSION';

    SELECT UPPER(value) INTO tMinorVersion FROM cz_db_settings
     WHERE UPPER(section_name) = 'SCHEMA'
       AND UPPER(setting_id) = 'MINOR_VERSION';

  EXCEPTION
    WHEN OTHERS THEN
      --'Unable to read the target schema version settings because of %ERRORTEXT.'
      report(CZ_UTILS.GET_TEXT('CZ_MIGR_NO_TARGET_VERSION', 'ERRORTEXT', SQLERRM), URGENCY_WARNING);
      return SKIPPABLE_ERROR;
  END;

  BEGIN

    EXECUTE IMMEDIATE 'SELECT UPPER(value) FROM cz_db_settings@' || dbLinkName ||
                      ' WHERE UPPER(section_name) = ''SCHEMA''' ||
                      '   AND UPPER(setting_id) = ''MAJOR_VERSION''' INTO sMajorVersion;


    EXECUTE IMMEDIATE 'SELECT UPPER(value) FROM cz_db_settings@' || dbLinkName ||
                      ' WHERE UPPER(section_name) = ''SCHEMA''' ||
                      '   AND UPPER(setting_id) = ''MINOR_VERSION''' INTO sMinorVersion;

  EXCEPTION
    WHEN OTHERS THEN
      --'Unable to read the source schema version settings because of %ERRORTEXT.'
      report(CZ_UTILS.GET_TEXT('CZ_MIGR_NO_SOURCE_VERSION', 'ERRORTEXT', SQLERRM), URGENCY_WARNING);
      return SKIPPABLE_ERROR;
  END;

  IF(NOT((sMajorVersion IS NOT NULL) AND (tMajorVersion IS NOT NULL) AND
         (sMinorVersion IS NOT NULL) AND (tMinorVersion IS NOT NULL) AND
         (sMajorVersion = tMajorVersion) AND
            (
              (sMinorVersion = tMinorVersion) OR
                 (
                    sMajorVersion = 14 AND
                      (
                        (sMinorVersion = 'C' AND tMinorVersion = 'D') OR
                        (sMinorVersion = 'C' AND tMinorVersion = 'B')
                      )
                 )
            )
  ))THEN
      --'The source and target schema versions are incompatible. The source schema is at
      -- version ''%SOURCEVERSION''; the target schema is at version ''%TARGETVERSION''.'
      report(CZ_UTILS.GET_TEXT('CZ_MIGR_DIFFERENT_VERSIONS', 'SOURCEVERSION', sMajorVersion || LOWER(sMinorVersion),
                                                             'TARGETVERSION', tMajorVersion || LOWER(tMinorVersion)), URGENCY_WARNING);
      return SKIPPABLE_ERROR;
  END IF;

  return NO_ERROR;

  EXCEPTION
    WHEN OTHERS THEN
      --'Unable to compare schema versions because of %ERRORTEXT.'
      report(CZ_UTILS.GET_TEXT('CZ_MIGR_NO_VERSIONS', 'ERRORTEXT', SQLERRM), URGENCY_ERROR);
      return FATAL_ERROR;
END;
------------------------------------------------------------------------------------------------------------
function compare_columns(inTableName in varchar2)
return integer is
  cdyn           integer;
  rdyn           integer;
  rpkc           integer;
  ColumnName     dbms_sql.varchar2_table;
  DataType       dbms_sql.varchar2_table;
  Nullable       dbms_sql.varchar2_table;
  DataLength     dbms_sql.number_table;
begin

 if(NoIntegrityCheck)then return NO_ERROR; end if;

 cdyn := dbms_sql.open_cursor;
 dbms_sql.parse(cdyn,
  '(SELECT column_name, data_type, nullable, data_length ' ||
  '    FROM all_tab_columns ' ||
  '   WHERE table_name = ''' || upper(inTableName) || '''' ||
  '    AND owner = ''' || CONFIGURATOR_SCHEMA || '''' ||
  ' MINUS ' ||
  ' SELECT column_name, data_type, nullable, data_length ' ||
  '    FROM all_tab_columns@' || dbLinkName ||
  '  WHERE table_name = '''|| upper(inTableName) || '''' ||
  '    AND owner = ''' || CONFIGURATOR_SCHEMA || ''')' ||
  ' UNION ' ||
  '(SELECT column_name, data_type, nullable, data_length ' ||
  '    FROM all_tab_columns@' || dbLinkName ||
  '  WHERE table_name = ''' || upper(inTableName) || ''''||
  '    AND owner = ''' || CONFIGURATOR_SCHEMA || '''' ||
  ' MINUS ' ||
  ' SELECT column_name, data_type, nullable, data_length ' ||
  '    FROM all_tab_columns ' ||
  '   WHERE table_name = ''' || upper(inTableName) || '''' ||
  '    AND owner = ''' || CONFIGURATOR_SCHEMA || ''')',
  dbms_sql.native);
 dbms_sql.define_array(cdyn,1,ColumnName,100,1);
 dbms_sql.define_array(cdyn,2,DataType,100,1);
 dbms_sql.define_array(cdyn,3,Nullable,100,1);
 dbms_sql.define_array(cdyn,4,DataLength,100,1);
 rdyn := dbms_sql.execute_and_fetch(cdyn);
 dbms_sql.column_value(cdyn,1,ColumnName);
 dbms_sql.column_value(cdyn,2,DataType);
 dbms_sql.column_value(cdyn,3,Nullable);
 dbms_sql.column_value(cdyn,4,DataLength);
 dbms_sql.close_cursor(cdyn);

 if(rdyn > 0)then

  --'Definition of the table ''%TABLENAME'' is different in source and target schema.'
  report(CZ_UTILS.GET_TEXT('CZ_MIGR_DIFFERENT_TABLES', 'TABLENAME', inTableName), URGENCY_WARNING);
  --'Start of the list of differences for the table ''%TABLENAME'':'
  report(CZ_UTILS.GET_TEXT('CZ_MIGR_LIST_START', 'TABLENAME', inTableName), URGENCY_WARNING);

  for i in 1..rdyn loop

    --'Column name: ''%COLUMNNAME'', data type: ''%DATATYPE'', nullable: ''%NULLABLE'', data length: ''%DATALENGTH''.'
    report(CZ_UTILS.GET_TEXT('CZ_MIGR_COLUMNS_DIFF', 'COLUMNNAME', ColumnName(i), 'DATATYPE', DataType(i), 'NULLABLE', Nullable(i), 'DATALENGTH', TO_CHAR(DataLength(i))), URGENCY_WARNING);
  end loop;

  --'End of the list of differences for the table ''%TABLENAME'':'
  report(CZ_UTILS.GET_TEXT('CZ_MIGR_LIST_END', 'TABLENAME', inTableName), URGENCY_WARNING);
 end if;

 rpkc := compare_pk_columns(inTableName);

 if(rpkc = FATAL_ERROR)then return FATAL_ERROR; end if;
 if((rpkc = SKIPPABLE_ERROR) or (rdyn > 0))then return SKIPPABLE_ERROR; end if;
 return NO_ERROR;

exception
  when others then
    if(dbms_sql.is_open(cdyn))then dbms_sql.close_cursor(cdyn); end if;
    --'Unable to compare columns for the table ''%TABLENAME'': %ERRORTEXT.'
    report(CZ_UTILS.GET_TEXT('CZ_MIGR_COLUMNS_COMPARE', 'TABLENAME', inTableName, 'ERRORTEXT', SQLERRM), URGENCY_ERROR);
    return FATAL_ERROR;
end;
------------------------------------------------------------------------------------------------------------
function get_table_columns(inTableName in varchar2, outNamesArray OUT NOCOPY ColumnNameArray)
return integer is
 cursor c_getcolumns is
  SELECT column_name FROM all_tab_columns
   WHERE table_name = upper(inTableName)
     AND owner = CONFIGURATOR_SCHEMA;
 nCounter  integer := 1;
begin
 outNamesArray.delete;

 open c_getcolumns;
 loop
   fetch c_getcolumns into outNamesArray(nCounter);
   exit when c_getcolumns%notfound;
   nCounter := nCounter + 1;
 end loop;

 close c_getcolumns;
 return(nCounter - 1);

exception
  when others then
    if(c_getcolumns%isopen)then close c_getcolumns; end if;
    --'Unable to retrieve the list of columns for the table ''%TABLENAME'': %ERRORTEXT.'
    report(CZ_UTILS.GET_TEXT('CZ_MIGR_COLUMNS_UNABLE', 'TABLENAME', inTableName, 'ERRORTEXT', SQLERRM), URGENCY_ERROR);
    return FATAL_ERROR;
end;
------------------------------------------------------------------------------------------------------------
function compare_pk_columns(inTableName in varchar2)
return integer is
  cdyn           integer;
  rdyn           integer;
  xerr           boolean;
  pkName         all_constraints.constraint_name%type;
  ColumnName     dbms_sql.varchar2_table;
  cursor c_getpkname is
    SELECT constraint_name FROM all_constraints
     WHERE table_name = upper(inTableName)
       AND owner = CONFIGURATOR_SCHEMA
       AND constraint_type = 'P';
begin
  open c_getpkname;
  fetch c_getpkname into pkName;
  xerr := c_getpkname%found;
  close c_getpkname;

  rdyn := 0;

  if(xerr)then
   cdyn := dbms_sql.open_cursor;
   dbms_sql.parse(cdyn,
    '(SELECT column_name FROM all_cons_columns ' ||
    '   WHERE constraint_name = ''' || pkName || '''' ||
    '    AND owner = ''' || CONFIGURATOR_SCHEMA || '''' ||
    ' MINUS '||
    'SELECT column_name FROM all_cons_columns@' || dbLinkName ||
    ' WHERE constraint_name = ''' || pkName || '''' ||
    '   AND owner = ''' || CONFIGURATOR_SCHEMA || ''')' ||
    ' UNION '||
    '(SELECT column_name FROM all_cons_columns@' || dbLinkName ||
    '  WHERE constraint_name = ''' || pkName || '''' ||
    '    AND owner = ''' || CONFIGURATOR_SCHEMA || '''' ||
    ' MINUS '||
    'SELECT column_name FROM all_cons_columns ' ||
    '  WHERE constraint_name = ''' || pkName || '''' ||
    '   AND owner = ''' || CONFIGURATOR_SCHEMA || ''')',
    dbms_sql.native);
   dbms_sql.define_array(cdyn,1,ColumnName,100,1);
   rdyn := dbms_sql.execute_and_fetch(cdyn);
   dbms_sql.column_value(cdyn,1,ColumnName);
   dbms_sql.close_cursor(cdyn);
  end if;

 if(rdyn > 0)then

  --'Primary key definition for the table ''%TABLENAME'' is different in source and target schema.'
  report(CZ_UTILS.GET_TEXT('CZ_MIGR_DIFFERENT_PK', 'TABLENAME', inTableName), URGENCY_WARNING);
  --'Start of the list of primary key differences for the table ''%TABLENAME'':'
  report(CZ_UTILS.GET_TEXT('CZ_MIGR_PK_START', 'TABLENAME', inTableName), URGENCY_WARNING);

  for i in 1..rdyn loop

    --'The following column is missing from the primary key: ''%COLUMNNAME''.'
    report(CZ_UTILS.GET_TEXT('CZ_MIGR_PK_DIFF', 'COLUMNNAME', ColumnName(i)), URGENCY_WARNING);
  end loop;

  --'End of the list of primary key differences for the table ''%TABLENAME'':'
  report(CZ_UTILS.GET_TEXT('CZ_MIGR_PK_END', 'TABLENAME', inTableName), URGENCY_WARNING);
  return SKIPPABLE_ERROR;
 end if;

 return NO_ERROR;

exception
  when others then
    if(dbms_sql.is_open(cdyn))then dbms_sql.close_cursor(cdyn); end if;
    --'Unable to compare primary key columns for the table ''%TABLENAME'': %ERRORTEXT.'
    report(CZ_UTILS.GET_TEXT('CZ_MIGR_PK_COMPARE', 'TABLENAME', inTableName, 'ERRORTEXT', SQLERRM), URGENCY_ERROR);
    return FATAL_ERROR;
end;
------------------------------------------------------------------------------------------------------------
function get_table_pk_columns(inTableName in varchar2, outNamesArray OUT NOCOPY PkColumnNameArray)
return integer is
 cursor c_getpkcolumns is
  SELECT column_name FROM all_cons_columns
   WHERE owner = CONFIGURATOR_SCHEMA
     AND constraint_name =
      (SELECT constraint_name FROM all_constraints
        WHERE table_name = upper(inTableName)
          AND owner = CONFIGURATOR_SCHEMA
          AND constraint_type='P');
 nCounter  integer := 1;
begin
 outNamesArray.delete;

 open c_getpkcolumns;
 loop
   fetch c_getpkcolumns into outNamesArray(nCounter);
   exit when c_getpkcolumns%notfound;
   nCounter := nCounter + 1;
 end loop;

 close c_getpkcolumns;
 return(nCounter - 1);

exception
  when others then
    if(c_getpkcolumns%isopen)then close c_getpkcolumns; end if;
    --'Unable to retrieve the list of primary key columns for the table ''%TABLENAME'': %ERRORTEXT.'
    report(CZ_UTILS.GET_TEXT('CZ_MIGR_PK_UNABLE', 'TABLENAME', inTableName, 'ERRORTEXT', SQLERRM), URGENCY_ERROR);
    return FATAL_ERROR;
end;
------------------------------------------------------------------------------------------------------------
function copy_table(inTableName       in varchar2,
                    inCommitSize      in pls_integer,
                    inStopOnSkippable in number,
                    inRefreshable     in number,
                    inForceSlowMode   in number,
                    inForceProcess    in number)
return integer is
  nCountLocal  number;
  nCountRemote number;
  cdyn         integer;
  rdyn         integer;
begin

 begin
  cdyn := dbms_sql.open_cursor;
  dbms_sql.parse(cdyn,'select count(*) from '||inTableName,dbms_sql.native);
  dbms_sql.define_column(cdyn, 1, nCountLocal);
  rdyn := dbms_sql.execute_and_fetch(cdyn);
  dbms_sql.column_value(cdyn, 1, nCountLocal);
  dbms_sql.close_cursor(cdyn);
 exception
   when others then
     if(dbms_sql.is_open(cdyn))then dbms_sql.close_cursor(cdyn); end if;
     --'Verification of the table ''%TABLENAME'' in the target schema failed: %ERRORTEXT.'
     report(CZ_UTILS.GET_TEXT('CZ_MIGR_TARGET_TABLE', 'TABLENAME', inTableName, 'ERRORTEXT', SQLERRM), URGENCY_WARNING);
     return SKIPPABLE_ERROR;
 end;

 begin
  cdyn := dbms_sql.open_cursor;
  dbms_sql.parse(cdyn,'select count(*) from '||inTableName||'@'||dbLinkName,dbms_sql.native);
  dbms_sql.define_column(cdyn, 1, nCountRemote);
  rdyn := dbms_sql.execute_and_fetch(cdyn);
  dbms_sql.column_value(cdyn, 1, nCountRemote);
  dbms_sql.close_cursor(cdyn);
 exception
   when others then
     if(dbms_sql.is_open(cdyn))then dbms_sql.close_cursor(cdyn); end if;
     --'Verification of the table ''%TABLENAME'' in the source schema failed: %ERRORTEXT.'
     report(CZ_UTILS.GET_TEXT('CZ_MIGR_SOURCE_TABLE', 'TABLENAME', inTableName, 'ERRORTEXT', SQLERRM), URGENCY_WARNING);
     return SKIPPABLE_ERROR;
 end;

 if((nCountLocal = nCountRemote) and (inForceProcess = 0))then

   --'Table ''%TABLENAME'' has the same number of records in the source and target schema, the table will be skipped.'
   report(CZ_UTILS.GET_TEXT('CZ_MIGR_SKIP_TABLE', 'TABLENAME', inTableName), URGENCY_MESSAGE);
   return NO_ERROR;
 end if;

 if((nCountLocal = 0) and (inForceSlowMode = 0))then

   --'Fast copy mode is selected for the table ''%TABLENAME''. Number of records in the source table: %SOURCERECORDS.'
   report(CZ_UTILS.GET_TEXT('CZ_MIGR_COPY_FAST', 'TABLENAME', inTableName, 'SOURCERECORDS', TO_CHAR(nCountRemote)), URGENCY_MESSAGE);
   return copy_table_fastmode(inTableName,inStopOnskippable);
 end if;

 if((inRefreshable = 0) and (inForceSlowMode = 0))then

   --'Fast copy mode without refresh is selected for the table ''%TABLENAME''. Number of records in the source table: %SOURCERECORDS.
   -- Number of records in the target table: %TARGETRECORDS.'
   report(CZ_UTILS.GET_TEXT('CZ_MIGR_COPY_FASTNOREFRESH', 'TABLENAME', inTableName, 'SOURCERECORDS', TO_CHAR(nCountRemote), 'TARGETRECORDS', TO_CHAR(nCountLocal)), URGENCY_MESSAGE);
   return copy_table_fastnorefresh(inTableName,inStopOnskippable);
 end if;

 if((inRefreshable = 1) and (inForceSlowMode = 0))then

   --'Override mode is selected for the table ''%TABLENAME''. Number of records in the source table: %SOURCERECORDS.
   -- Number of records in the target table: %TARGETRECORDS.'
   report(CZ_UTILS.GET_TEXT('CZ_MIGR_COPY_FASTREFRESH', 'TABLENAME', inTableName, 'SOURCERECORDS', TO_CHAR(nCountRemote), 'TARGETRECORDS', TO_CHAR(nCountLocal)), URGENCY_MESSAGE);
   return copy_table_fastrefresh(inTableName,inStopOnskippable);
 end if;

 --'Slow copy mode is selected for the table ''%TABLENAME''. Number of records in the source table: %SOURCERECORDS.
 -- Number of records in the target table: %TARGETRECORDS.'
 report(CZ_UTILS.GET_TEXT('CZ_MIGR_COPY_SLOW', 'TABLENAME', inTableName, 'SOURCERECORDS', TO_CHAR(nCountRemote), 'TARGETRECORDS', TO_CHAR(nCountLocal)), URGENCY_MESSAGE);
 return copy_table_slowmode(inTableName,inCommitSize,inStopOnskippable,inRefreshable);

exception
  when others then
    --'Unable to copy the table ''%TABLENAME'' : %ERRORTEXT.'
    report(CZ_UTILS.GET_TEXT('CZ_MIGR_TABLE_ERROR', 'TABLENAME', inTableName, 'ERRORTEXT', SQLERRM), URGENCY_ERROR);
    return FATAL_ERROR;
end;
------------------------------------------------------------------------------------------------------------
FUNCTION copy_table_override(inTableName       IN VARCHAR2,
                             inStopOnSkippable IN NUMBER)
RETURN INTEGER IS

  nCountTarget NUMBER;
  nCountSource NUMBER;
BEGIN

  BEGIN
    EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || inTableName INTO nCountTarget;
  EXCEPTION
    WHEN OTHERS THEN
      --'Verification of the table ''%TABLENAME'' in the target schema failed: %ERRORTEXT.'
      report(CZ_UTILS.GET_TEXT('CZ_MIGR_TARGET_TABLE', 'TABLENAME', inTableName, 'ERRORTEXT', SQLERRM), URGENCY_WARNING);
     return SKIPPABLE_ERROR;
 END;

  BEGIN
    EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || inTableName || '@' || dbLinkName INTO nCountSource;
  EXCEPTION
    WHEN OTHERS THEN
     --'Verification of the table ''%TABLENAME'' in the source schema failed: %ERRORTEXT.'
     report(CZ_UTILS.GET_TEXT('CZ_MIGR_SOURCE_TABLE', 'TABLENAME', inTableName, 'ERRORTEXT', SQLERRM), URGENCY_WARNING);
     return SKIPPABLE_ERROR;
 END;

 IF(nCountTarget = 0 AND nCountSource = 0)THEN

   --'Table ''%TABLENAME'' has no data in the source and target schema, the table will be skipped.'
   report(CZ_UTILS.GET_TEXT('CZ_MIGR_TABLE_NO_DATA', 'TABLENAME', inTableName), URGENCY_MESSAGE);
   return NO_ERROR;

 ELSIF(nCountTarget = 0)THEN

   --'Fast copy mode is selected for the table ''%TABLENAME''. Number of records in the source table: %SOURCERECORDS.'
   report(CZ_UTILS.GET_TEXT('CZ_MIGR_COPY_FAST', 'TABLENAME', inTableName, 'SOURCERECORDS', TO_CHAR(nCountSource)), URGENCY_MESSAGE);
   return copy_table_fastmode(inTableName, inStopOnskippable);
 ELSE

   --'Override mode is selected for the table ''%TABLENAME''. Number of records in the source table: %SOURCERECORDS.
   -- Number of records in the target table: %TARGETRECORDS.'
   report(CZ_UTILS.GET_TEXT('CZ_MIGR_COPY_FASTREFRESH', 'TABLENAME', inTableName, 'SOURCERECORDS', TO_CHAR(nCountSource), 'TARGETRECORDS', TO_CHAR(nCountTarget)), URGENCY_MESSAGE);
   return copy_table_fastrefresh(inTableName, inStopOnskippable);
 END IF;

EXCEPTION
  WHEN OTHERS THEN
    --'Unable to copy the table ''%TABLENAME'' : %ERRORTEXT.'
    report(CZ_UTILS.GET_TEXT('CZ_MIGR_TABLE_ERROR', 'TABLENAME', inTableName, 'ERRORTEXT', SQLERRM), URGENCY_ERROR);
    return FATAL_ERROR;
END copy_table_override;
------------------------------------------------------------------------------------------------------------
function copy_all_tables(inCommitSize      in pls_integer,
                         inStopOnSkippable in number,
                         inRefreshable     in number,
                         inForceSlowMode   in number,
                         inForceProcess    in number)
return integer is
  xError  integer;
begin
  for c_tables in (select dst_table from cz_xfr_tables where xfr_group='OVERRIDE' and disabled='0') loop
    xError := copy_table_override(c_tables.dst_table, inStopOnSkippable);
    if(xError = FATAL_ERROR or (xError = SKIPPABLE_ERROR and inStopOnSkippable = 1))then
      return xError;
    end if;
  end loop;
  for c_tables in (select dst_table from cz_xfr_tables where xfr_group='MIGRATE' and disabled='0') loop
    xError := copy_table(c_tables.dst_table, inCommitSize, inStopOnSkippable, inRefreshable, inForceSlowMode, inForceProcess);
    if(xError = FATAL_ERROR or (xError = SKIPPABLE_ERROR and inStopOnSkippable = 1))then
      return xError;
    end if;
  end loop;
  for c_tables in (select dst_table from cz_xfr_tables where xfr_group='REFRESH' and disabled='0') loop
    xError := copy_table(c_tables.dst_table, inCommitSize, inStopOnSkippable, 1, inForceSlowMode, 1);
    if(xError = FATAL_ERROR or (xError = SKIPPABLE_ERROR and inStopOnSkippable = 1))then
      return xError;
    end if;
  end loop;
  for c_tables in (select dst_table from cz_xfr_tables where xfr_group='FORCESLOW' and disabled='0') loop
    xError := copy_table(c_tables.dst_table, inCommitSize, inStopOnSkippable, inRefreshable, 1, inForceProcess);
    if(xError = FATAL_ERROR or (xError = SKIPPABLE_ERROR and inStopOnSkippable = 1))then
      return xError;
    end if;
  end loop;
  for c_tables in (select dst_table from cz_xfr_tables where xfr_group='SLOWREFRESH' and disabled='0') loop
    xError := copy_table(c_tables.dst_table, inCommitSize, inStopOnSkippable, 1, 1, 1);
    if(xError = FATAL_ERROR or (xError = SKIPPABLE_ERROR and inStopOnSkippable = 1))then
      return xError;
    end if;
  end loop;
 return NO_ERROR;
exception
  when others then
    --'Error while migrating data: %ERRORTEXT.'
    report(CZ_UTILS.GET_TEXT('CZ_MIGR_MIGRATE_ERROR', 'ERRORTEXT', SQLERRM), URGENCY_ERROR);
    return FATAL_ERROR;
end;
------------------------------------------------------------------------------------------------------------
function copy_table_slowmode(inTableName       in varchar2,
                             inCommitSize      in pls_integer,
                             inStopOnSkippable in number,
                             inRefreshable     in number)
return integer is
  ColumnNames    ColumnNameArray;
  PkColumnNames  PkColumnNameArray;
  cdyn           integer;
  rdyn           integer;
  tableInsertStatement  varchar2(5120);
  tableUpdateStatement  varchar2(5120);
begin

 rdyn := compare_columns(inTableName);
 if(rdyn = FATAL_ERROR or (rdyn = SKIPPABLE_ERROR and inStopOnSkippable = 1))then return rdyn; end if;

 rdyn := get_table_columns(inTableName, ColumnNames);
 if(rdyn = FATAL_ERROR)then return rdyn; end if;
 if(rdyn = 0)then return SKIPPABLE_ERROR; end if;

 tableInsertStatement := ' insert into '||inTableName||' (';
 for i in ColumnNames.first..ColumnNames.last - 1 loop
  tableInsertStatement := tableInsertStatement||ColumnNames(i)||',';
 end loop;
 tableInsertStatement := tableInsertStatement||ColumnNames(ColumnNames.last)||') values (';
 for i in ColumnNames.first..ColumnNames.last - 1 loop
  tableInsertStatement := tableInsertStatement||'c_row.'||ColumnNames(i)||',';
 end loop;
 tableInsertStatement := tableInsertStatement||'c_row.'||ColumnNames(ColumnNames.last)||'); ';

 tableUpdateStatement := ' NULL; ';

 if(inRefreshable = 1)then

  rdyn := get_table_pk_columns(inTableName, PkColumnNames);
  if(rdyn = FATAL_ERROR)then return rdyn; end if;

  if(rdyn > 0)then
   tableUpdateStatement := ' update '||inTableName||' set ';
   for i in ColumnNames.first..ColumnNames.last - 1 loop
    tableUpdateStatement := tableUpdateStatement||ColumnNames(i)||'=c_row.'||ColumnNames(i)||',';
   end loop;
   tableUpdateStatement := tableUpdateStatement||ColumnNames(ColumnNames.last)||'=c_row.'||ColumnNames(ColumnNames.last)||' where ';
   for i in PkColumnNames.first..PkColumnNames.last - 1 loop
    tableUpdateStatement := tableUpdateStatement||PkColumnNames(i)||'=c_row.'||PkColumnNames(i)||' and ';
   end loop;
   tableUpdateStatement := tableUpdateStatement||PkColumnNames(PkColumnNames.last)||'=c_row.'||PkColumnNames(PkColumnNames.last)||'; ';
  end if;
 end if;

 cdyn := dbms_sql.open_cursor;
 dbms_sql.parse(cdyn,
  'declare '||
  '  nUpdates  number := 0; '||
  '  nInserts  number := 0; '||
  '  nCommitCount pls_integer:=0; '||
  'begin '||
  'for c_row in (select * from '||inTableName||'@'||dbLinkName||') loop '||
  ' begin '||
  '  if(nCommitCount>=:CommitSize)then '||
  '    commit; '||
  '    nCommitCount:=0; '||
  '  else '||
  '    nCommitCount:=nCommitCount+1; '||
  '  end if; '||
    tableInsertStatement||
  ' nInserts := nInserts + 1; '||
  ' exception '||
  '   when others then '||
  '     if((sqlcode between -999 and -900) or '||
  '        (sqlcode between -1489 and -1400) or '||
  '        sqlcode = -1)then '||
  '      if(:Refreshable = 1)then '||
  '        begin '||
            tableUpdateStatement||
  '         nUpdates := nUpdates + 1; '||
  '        exception '||
  '          when others then '||
  '            cz_migrate.report(CZ_UTILS.GET_TEXT(''CZ_MIGR_UNABLE_UPDATE'', ''TABLENAME'', ''' || inTableName || ''', ''ERRORTEXT'', SQLERRM), cz_migrate.URGENCY_WARNING); ' ||
  '            if((sqlcode between -999 and -900) or '||
  '               (sqlcode between -1489 and -1400) or '||
  '               sqlcode = -1)then '||
  '              if(:StopOnSkippable = 1)then raise cz_migrate.CZ_MIGR_SKIPPABLE_EXCEPTION; end if; '||
  '            else '||
  '              raise cz_migrate.CZ_MIGR_FATAL_EXCEPTION; '||
  '            end if; '||
  '        end; '||
  '      else '||
  '       cz_migrate.report(CZ_UTILS.GET_TEXT(''CZ_MIGR_UNABLE_INSERT'', ''TABLENAME'', ''' || inTableName || ''', ''ERRORTEXT'', SQLERRM), cz_migrate.URGENCY_WARNING); ' ||
  '       if(:StopOnSkippable = 1)then raise cz_migrate.CZ_MIGR_SKIPPABLE_EXCEPTION; end if; '||
  '      end if; '||
  '     else '||
  '       raise cz_migrate.CZ_MIGR_FATAL_EXCEPTION; '||
  '     end if; '||
  ' end; '||
  ' end loop; '||
  ' commit; '||
  ' cz_migrate.report(CZ_UTILS.GET_TEXT(''CZ_MIGR_COPY_SUCCESS'', ''TABLENAME'', ''' || inTableName || ''', ''INSERTROWS'', TO_CHAR(nInserts), ''UPDATEROWS'', TO_CHAR(nUpdates)), cz_migrate.URGENCY_MESSAGE); ' ||
  'end;',
  dbms_sql.native);

 dbms_sql.bind_variable(cdyn, ':Refreshable', inRefreshable);
 dbms_sql.bind_variable(cdyn, ':StopOnSkippable', inStopOnSkippable);
 dbms_sql.bind_variable(cdyn, ':CommitSize', inCommitSize);
 rdyn := dbms_sql.execute(cdyn);
 dbms_sql.close_cursor(cdyn);
 commit;
 return NO_ERROR;

exception
  when CZ_MIGR_SKIPPABLE_EXCEPTION then
    if(dbms_sql.is_open(cdyn))then dbms_sql.close_cursor(cdyn); end if;
    return SKIPPABLE_ERROR;
  when CZ_MIGR_FATAL_EXCEPTION then
    if(dbms_sql.is_open(cdyn))then dbms_sql.close_cursor(cdyn); end if;
    return FATAL_ERROR;
  when OTHERS then
    if(dbms_sql.is_open(cdyn))then dbms_sql.close_cursor(cdyn); end if;
    --'Unable to copy the table ''%TABLENAME'' in the selected mode: %ERRORTEXT.'
    report(CZ_UTILS.GET_TEXT('CZ_MIGR_COPY_ERROR', 'TABLENAME', inTableName, 'ERRORTEXT', SQLERRM), URGENCY_ERROR);
    return FATAL_ERROR;
end;
------------------------------------------------------------------------------------------------------------
function copy_table_fastmode(inTableName       in varchar2,
                             inStopOnSkippable in number)
return integer is
  ColumnNames    ColumnNameArray;
  cdyn           integer;
  rdyn           integer;
  tableInsertStatement  varchar2(5120);
begin

 rdyn := compare_columns(inTableName);
 if(rdyn = FATAL_ERROR or (rdyn = SKIPPABLE_ERROR and inStopOnSkippable = 1))then return rdyn; end if;

 rdyn := get_table_columns(inTableName, ColumnNames);
 if(rdyn = FATAL_ERROR)then return rdyn; end if;
 if(rdyn = 0)then return SKIPPABLE_ERROR; end if;

 tableInsertStatement := ColumnNames(ColumnNames.first);
 for i in ColumnNames.first + 1..ColumnNames.last loop
  tableInsertStatement := tableInsertStatement||','||ColumnNames(i);
 end loop;

 tableInsertStatement := ' insert /*+ APPEND */ into '||inTableName||' ('||
  tableInsertStatement||') select '||tableInsertStatement||' from '||
  inTableName||'@'||dbLinkName;

 cdyn := dbms_sql.open_cursor;
 dbms_sql.parse(cdyn,tableInsertStatement,dbms_sql.native);
 rdyn := dbms_sql.execute(cdyn);
 dbms_sql.close_cursor(cdyn);
 commit;

 --'Source records are successfully inserted into the target table ''%TABLENAME''.'
 report(CZ_UTILS.GET_TEXT('CZ_MIGR_FAST_INSERTED', 'TABLENAME', inTableName), URGENCY_MESSAGE);
 return NO_ERROR;

exception
  when OTHERS then
    if(dbms_sql.is_open(cdyn))then dbms_sql.close_cursor(cdyn); end if;
    --'Unable to copy the table ''%TABLENAME'' in the selected mode: %ERRORTEXT.'
    report(CZ_UTILS.GET_TEXT('CZ_MIGR_COPY_ERROR', 'TABLENAME', inTableName, 'ERRORTEXT', SQLERRM), URGENCY_WARNING);
    if((sqlcode between -999 and -900) or (sqlcode between -1489 and -1400) or sqlcode = -1)then
     return SKIPPABLE_ERROR;
    else
     return FATAL_ERROR;
    end if;
end;
------------------------------------------------------------------------------------------------------------
function copy_table_fastnorefresh(inTableName       in varchar2,
                                  inStopOnSkippable in number)
return integer is
  ColumnNames    ColumnNameArray;
  PkColumnNames  PkColumnNameArray;
  cdyn           integer;
  rdyn           integer;
  tableInsertStatement  varchar2(5120);
  PkString              varchar2(5120);
begin

 rdyn := compare_columns(inTableName);
 if(rdyn = FATAL_ERROR or (rdyn = SKIPPABLE_ERROR and inStopOnSkippable = 1))then return rdyn; end if;

 rdyn := get_table_columns(inTableName, ColumnNames);
 if(rdyn = FATAL_ERROR)then return rdyn; end if;
 if(rdyn = 0)then return SKIPPABLE_ERROR; end if;

 tableInsertStatement := ColumnNames(ColumnNames.first);
 for i in ColumnNames.first + 1..ColumnNames.last loop
  tableInsertStatement := tableInsertStatement||','||ColumnNames(i);
 end loop;

 tableInsertStatement := ' insert /*+ APPEND */ into '||inTableName||' ('||
  tableInsertStatement||') select '||tableInsertStatement||' from '||
  inTableName||'@'||dbLinkName;

  rdyn := get_table_pk_columns(inTableName, PkColumnNames);
  if(rdyn = FATAL_ERROR)then return rdyn; end if;

  if(rdyn > 0)then
   PkString := PkColumnNames(PkColumnNames.first)||'=remote.'||PkColumnNames(PkColumnNames.first);
   for i in PkColumnNames.first + 1..PkColumnNames.last loop
    PkString := PkString||' and '||PkColumnNames(i)||'=remote.'||PkColumnNames(i);
   end loop;
   tableInsertStatement := tableInsertStatement||
    ' remote where not exists (select null from '||
    inTableName||' where '||PkString||')';
  end if;

 cdyn := dbms_sql.open_cursor;
 dbms_sql.parse(cdyn,tableInsertStatement,dbms_sql.native);
 rdyn := dbms_sql.execute(cdyn);
 dbms_sql.close_cursor(cdyn);
 commit;

 --'%INSERTROWS records successfully inserted into the target table ''%TABLENAME''.'
 report(CZ_UTILS.GET_TEXT('CZ_MIGR_INSERT_SUCCESS', 'TABLENAME', inTableName, 'INSERTROWS', TO_CHAR(rdyn)), URGENCY_MESSAGE);
 return NO_ERROR;

exception
  when OTHERS then
    if(dbms_sql.is_open(cdyn))then dbms_sql.close_cursor(cdyn); end if;
    --'Unable to copy the table ''%TABLENAME'' in the selected mode: %ERRORTEXT.'
    report(CZ_UTILS.GET_TEXT('CZ_MIGR_COPY_ERROR', 'TABLENAME', inTableName, 'ERRORTEXT', SQLERRM), URGENCY_WARNING);
    if((sqlcode between -999 and -900) or (sqlcode between -1489 and -1400) or sqlcode = -1)then
     return SKIPPABLE_ERROR;
    else
     return FATAL_ERROR;
    end if;
end;
------------------------------------------------------------------------------------------------------------
function copy_table_fastrefresh(inTableName       in varchar2,
                                inStopOnSkippable in number)
return integer is
  cdyn           integer;
  rdyn           integer;
begin

 cdyn := dbms_sql.open_cursor;
 dbms_sql.parse(cdyn, 'TRUNCATE TABLE ' || CONFIGURATOR_SCHEMA || '.' || inTableName, dbms_sql.native);
 rdyn := dbms_sql.execute(cdyn);
 dbms_sql.close_cursor(cdyn);
 commit;

 return copy_table_fastmode(inTableName, inStopOnSkippable);

exception
  when OTHERS then
    if(dbms_sql.is_open(cdyn))then dbms_sql.close_cursor(cdyn); end if;
    --'Unable to copy the table ''%TABLENAME'' in the selected mode: %ERRORTEXT.'
    report(CZ_UTILS.GET_TEXT('CZ_MIGR_COPY_ERROR', 'TABLENAME', inTableName, 'ERRORTEXT', SQLERRM), URGENCY_WARNING);
    if((sqlcode between -999 and -900) or (sqlcode between -1489 and -1400) or sqlcode = -1)then
     return SKIPPABLE_ERROR;
    else
     return FATAL_ERROR;
    end if;
end;
------------------------------------------------------------------------------------------------------------
function disable_triggers(inStopOnSkippable in number)
return integer is
  cdyn   integer;
  rdyn   integer;
begin
  for c_triggers in (select dst_table from cz_xfr_tables where xfr_group='TRIGGERS' and disabled='0') loop
    begin
     cdyn := dbms_sql.open_cursor;
     dbms_sql.parse(cdyn,'alter trigger '||c_triggers.dst_table||' disable',dbms_sql.native);
     rdyn := dbms_sql.execute(cdyn);
     dbms_sql.close_cursor(cdyn);
    exception
      when others then
        if(dbms_sql.is_open(cdyn))then dbms_sql.close_cursor(cdyn); end if;
        --'Error while disabling triggers: %ERRORTEXT.'
        report(CZ_UTILS.GET_TEXT('CZ_MIGR_TRIGGERS_ERROR', 'ERRORTEXT', SQLERRM), URGENCY_WARNING);
        if(inStopOnSkippable = 1)then return SKIPPABLE_ERROR; end if;
    end;
  end loop;
 return NO_ERROR;
end;
------------------------------------------------------------------------------------------------------------
function enable_triggers(inStopOnSkippable in number)
return integer is
  cdyn   integer;
  rdyn   integer;
begin
  for c_triggers in (select dst_table from cz_xfr_tables where xfr_group='TRIGGERS' and disabled='0') loop
    begin
     cdyn := dbms_sql.open_cursor;
     dbms_sql.parse(cdyn,'alter trigger '||c_triggers.dst_table||' enable',dbms_sql.native);
     rdyn := dbms_sql.execute(cdyn);
     dbms_sql.close_cursor(cdyn);
    exception
      when others then
        if(dbms_sql.is_open(cdyn))then dbms_sql.close_cursor(cdyn); end if;
        --'Error while enabling triggers: %ERRORTEXT.'
        report(CZ_UTILS.GET_TEXT('CZ_MIGR_ENABLE_ERROR', 'ERRORTEXT', SQLERRM), URGENCY_WARNING);
        if(inStopOnSkippable = 1)then return SKIPPABLE_ERROR; end if;
    end;
  end loop;
 return NO_ERROR;
end;
------------------------------------------------------------------------------------------------------------
FUNCTION adjust_sequence(sequenceName IN VARCHAR2, tableName IN VARCHAR2, inPkName IN VARCHAR2, p_increment IN NUMBER)
RETURN INTEGER IS
  cdyn           integer;
  rdyn           integer;
  nMaximum       NUMBER;
  Operator       VARCHAR2(4) := 'MAX';
  nextValue      NUMBER;
BEGIN

 IF(p_increment < 0)THEN Operator := 'MIN'; END IF;

 begin
  cdyn := dbms_sql.open_cursor;
  dbms_sql.parse(cdyn,'SELECT ' || Operator || '(' || inPkName || ') FROM ' || tableName, dbms_sql.native);
  dbms_sql.define_column(cdyn, 1, nMaximum);
  rdyn := dbms_sql.execute_and_fetch(cdyn);
  dbms_sql.column_value(cdyn, 1, nMaximum);
  dbms_sql.close_cursor(cdyn);
 exception
   when others then
     if(dbms_sql.is_open(cdyn))then dbms_sql.close_cursor(cdyn); end if;
     --'Skipping sequence ''%SEQUENCENAME'', unable to retrieve the last primary key value: %ERRORTEXT.'
     report(CZ_UTILS.GET_TEXT('CZ_MIGR_SEQUENCE_MAX', 'SEQUENCENAME', sequenceName, 'ERRORTEXT', SQLERRM), URGENCY_WARNING);
     return SKIPPABLE_ERROR;
 end;

 IF((p_increment = 0) OR (nMaximum is null))THEN

   --'Skipping sequence ''%SEQUENCENAME'', no adjustment is required.'
   report(CZ_UTILS.GET_TEXT('CZ_MIGR_SEQUENCE_SKIP', 'SEQUENCENAME', sequenceName), URGENCY_MESSAGE);
   return NO_ERROR;
 END IF;

 BEGIN
   EXECUTE IMMEDIATE 'SELECT ' || CONFIGURATOR_SCHEMA || '.' || sequenceName || '.NEXTVAL FROM DUAL' INTO nextValue;

   IF(SIGN(p_increment) * (nextValue - nMaximum) < 0)THEN

     EXECUTE IMMEDIATE 'ALTER SEQUENCE ' || CONFIGURATOR_SCHEMA || '.' || sequenceName || ' INCREMENT BY ' || (p_increment * CEIL(ABS((nextValue - nMaximum) / p_increment)));
     EXECUTE IMMEDIATE 'SELECT ' || CONFIGURATOR_SCHEMA || '.' || sequenceName || '.NEXTVAL FROM DUAL' INTO nextValue;
     EXECUTE IMMEDIATE 'ALTER SEQUENCE ' || CONFIGURATOR_SCHEMA || '.' || sequenceName || ' INCREMENT BY ' || p_increment;
   END IF;
 EXCEPTION
   WHEN OTHERS THEN
     --'Skipping sequence ''%SEQUENCENAME'', unable to adjust: %ERRORTEXT.'
     report(CZ_UTILS.GET_TEXT('CZ_MIGR_SEQUENCE_ADJUST', 'SEQUENCENAME', sequenceName, 'ERRORTEXT', SQLERRM), URGENCY_WARNING);
     RETURN SKIPPABLE_ERROR;
 END;

 COMMIT;

 --'Sequence ''%SEQUENCENAME'' adjusted.'
 report(CZ_UTILS.GET_TEXT('CZ_MIGR_SEQUENCE_READY', 'SEQUENCENAME', sequenceName), URGENCY_MESSAGE);
 RETURN NO_ERROR;

exception
  when others then
    --'Fatal error while adjusting sequence ''%SEQUENCENAME'': %ERRORTEXT.'
    report(CZ_UTILS.GET_TEXT('CZ_MIGR_SEQUENCE_ERROR', 'SEQUENCENAME', sequenceName, 'ERRORTEXT', SQLERRM), URGENCY_ERROR);
    return FATAL_ERROR;
END;
------------------------------------------------------------------------------------------------------------
FUNCTION adjust_all_sequences(inStopOnSkippable IN NUMBER)
RETURN INTEGER IS
  xError  INTEGER;
BEGIN

  --CZ_XFR_TABLES:
  --  SRC_TABLE - sequence name;
  --  DST_TABLE - corresponding table name;
  --  DST_SUBSCHEMA - corresponding table column name (the sequence is used to generate values for this column);
  --  FILTERSYNTAX - character representation of the sequence increment.

  FOR c_seq IN (SELECT src_table, dst_table, dst_subschema, filtersyntax FROM cz_xfr_tables
                 WHERE xfr_group = 'SEQUENCES' AND disabled = '0') LOOP

    xError := adjust_sequence(c_seq.src_table, c_seq.dst_table, c_seq.dst_subschema, TO_NUMBER(c_seq.filtersyntax));
    IF(xError = FATAL_ERROR OR (xError = SKIPPABLE_ERROR AND inStopOnSkippable = 1))THEN RETURN xError; END IF;
  END LOOP;

 RETURN NO_ERROR;
END adjust_all_sequences;
------------------------------------------------------------------------------------------------------------
PROCEDURE report(inMessage IN VARCHAR2, inUrgency IN PLS_INTEGER) IS
BEGIN
  cz_utils.log_report('cz_migrate', null, thisStatusCode, inMessage, fnd_log.LEVEL_ERROR);

  --Bug #4347347.

  IF(FND_GLOBAL.CONC_REQUEST_ID > 0)THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, inMessage);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RAISE CZ_MIGR_UNABLE_TO_REPORT;
END report;
------------------------------------------------------------------------------------------------------------
--This procedure is not dynamic and significantly uses the specifics of the CZ database.
--In general, any change to this procedure will require a matching change in the
--verify_target_database procedure. Please review both procedures for any change.

PROCEDURE adjust_specific_control IS

  migrateConfigData  PLS_INTEGER;
BEGIN

    --Bug #2458532 - read the db setting.

    BEGIN
      SELECT DECODE(UPPER(value), '1', 1, 'ON',  1, 'Y', 1, 'YES', 1,'TRUE',  1, 'ENABLE',  1,
                                  '0', 0, 'OFF', 0, 'N', 0, 'NO',  0,'FALSE', 0, 'DISABLE', 0,
                                  0) --the default value.
        INTO migrateConfigData FROM cz_db_settings
       WHERE UPPER(section_name) = 'MIGRATE' and UPPER(setting_id) = 'MIGRATECONFIGDATA';
    EXCEPTION
      WHEN OTHERS THEN
        migrateConfigData := 0; --the default behaviour.
    END;

--A. Tsyaston 14-Oct-2004 BUG 3937232 - List revised.

    UPDATE cz_xfr_tables SET disabled = '1'
    WHERE UPPER(xfr_group) = 'OVERRIDE'
      AND UPPER(dst_table) IN
       ('CZ_XFR_TABLES', 'CZ_ATP_REQUESTS', 'CZ_DB_LOGS', 'CZ_EXP_TMP_LINES', 'CZ_TERMINATE_MSGS',
        'CZ_PRICING_STRUCTURES', 'CZ_ITEM_PARENTS', 'CZ_INTL_TEXTS', 'CZ_LOOKUP_VALUES_TL',
        'CZ_LOOKUP_VALUES', 'CZ_TYPE_RELATIONSHIPS');

    UPDATE cz_xfr_tables SET disabled = '1'
    WHERE UPPER(xfr_group) = 'OVERRIDE'
      AND UPPER(dst_table) LIKE 'CZ/_IMP/_%' ESCAPE '/';

    UPDATE cz_xfr_tables SET disabled = '1'
    WHERE UPPER(xfr_group) = 'OVERRIDE'
      AND UPPER(dst_table) NOT LIKE 'CZ/_%' ESCAPE '/';

    --Bug #2458532 - disable migrating of the configuration data. Just disable copying the table data,
    --do not worry about sequences and triggers.

    IF(migrateConfigData = 0)THEN

      UPDATE cz_xfr_tables SET disabled = '1'
       WHERE UPPER(xfr_group) = 'OVERRIDE'
         AND UPPER(dst_table) IN
      ('CZ_CONFIG_ATTRIBUTES', 'CZ_CONFIG_EXT_ATTRIBUTES', 'CZ_CONFIG_HDRS', 'CZ_CONFIG_INPUTS',
       'CZ_CONFIG_ITEMS', 'CZ_CONFIG_MESSAGES', 'CZ_CONFIG_USAGES');
    END IF;

    --CZ_XFR_FIELDS moved to the 'SLOWREFRESH' group, bug #3620255 (original #3283062).

    UPDATE cz_xfr_tables SET xfr_group = 'SLOWREFRESH'
    WHERE UPPER(xfr_group) = 'OVERRIDE'
      AND UPPER(dst_table) IN ('CZ_DB_SETTINGS', 'CZ_XFR_FIELDS');

    UPDATE cz_xfr_tables SET xfr_group = 'MIGRATE'
    WHERE UPPER(xfr_group) = 'OVERRIDE'
      AND UPPER(dst_table) = 'CZ_SERVERS';

    UPDATE cz_xfr_tables SET disabled = '1'
    WHERE UPPER(xfr_group) = 'TRIGGERS'
      AND UPPER(dst_table) NOT LIKE 'CZ/_%' ESCAPE '/';

    INSERT INTO cz_xfr_tables
     (order_seq, xfr_group, disabled, src_table, dst_table, dst_subschema, filtersyntax)
    VALUES
     (1, 'SEQUENCES', '0', 'CZ_ADDRESSES_S', 'CZ_ADDRESSES', 'ADDRESS_ID', '20');

    INSERT INTO cz_xfr_tables
     (order_seq, xfr_group, disabled, src_table, dst_table, dst_subschema, filtersyntax)
    VALUES
     (2, 'SEQUENCES', '0', 'CZ_ADDRESS_USES_S', 'CZ_ADDRESS_USES', 'ADDRESS_USE_ID', '20');

    INSERT INTO cz_xfr_tables
     (order_seq, xfr_group, disabled, src_table, dst_table, dst_subschema, filtersyntax)
    VALUES
     (4, 'SEQUENCES', '0', 'CZ_COMBO_FEATURES_S', 'CZ_COMBO_FEATURES', 'FEATURE_ID', '20');

    INSERT INTO cz_xfr_tables
     (order_seq, xfr_group, disabled, src_table, dst_table, dst_subschema, filtersyntax)
    VALUES
     (5, 'SEQUENCES', '0', 'CZ_CONFIG_HDRS_S', 'CZ_CONFIG_HDRS', 'CONFIG_HDR_ID', '20');

    INSERT INTO cz_xfr_tables
     (order_seq, xfr_group, disabled, src_table, dst_table, dst_subschema, filtersyntax)
    VALUES
     (6, 'SEQUENCES', '0', 'CZ_CONFIG_INPUTS_S', 'CZ_CONFIG_INPUTS', 'CONFIG_INPUT_ID', '20');

    INSERT INTO cz_xfr_tables
     (order_seq, xfr_group, disabled, src_table, dst_table, dst_subschema, filtersyntax)
    VALUES
     (7, 'SEQUENCES', '0', 'CZ_CONFIG_ITEMS_S', 'CZ_CONFIG_ITEMS', 'CONFIG_ITEM_ID', '20');

    INSERT INTO cz_xfr_tables
     (order_seq, xfr_group, disabled, src_table, dst_table, dst_subschema, filtersyntax)
    VALUES
     (8, 'SEQUENCES', '0', 'CZ_CONFIG_MESSAGES_S', 'CZ_CONFIG_MESSAGES', 'MESSAGE_SEQ', '20');

    INSERT INTO cz_xfr_tables
     (order_seq, xfr_group, disabled, src_table, dst_table, dst_subschema, filtersyntax)
    VALUES
     (9, 'SEQUENCES', '0', 'CZ_CONTACTS_S', 'CZ_CONTACTS', 'CONTACT_ID', '20');

    INSERT INTO cz_xfr_tables
     (order_seq, xfr_group, disabled, src_table, dst_table, dst_subschema, filtersyntax)
    VALUES
     (10, 'SEQUENCES', '0', 'CZ_CUSTOMERS_S', 'CZ_CUSTOMERS', 'CUSTOMER_ID', '20');

    INSERT INTO cz_xfr_tables
     (order_seq, xfr_group, disabled, src_table, dst_table, dst_subschema, filtersyntax)
    VALUES
     (13, 'SEQUENCES', '0', 'CZ_DEVL_PROJECTS_S', 'CZ_DEVL_PROJECTS', 'DEVL_PROJECT_ID', '20');

    INSERT INTO cz_xfr_tables
     (order_seq, xfr_group, disabled, src_table, dst_table, dst_subschema, filtersyntax)
    VALUES
     (14, 'SEQUENCES', '0', 'CZ_DRILL_DOWN_ITEMS_S', 'CZ_DRILL_DOWN_ITEMS', 'DD_SEQ_NBR', '20');

    INSERT INTO cz_xfr_tables
     (order_seq, xfr_group, disabled, src_table, dst_table, dst_subschema, filtersyntax)
    VALUES
     (15, 'SEQUENCES', '0', 'CZ_EFFECTIVITY_SETS_S', 'CZ_EFFECTIVITY_SETS', 'EFFECTIVITY_SET_ID', '20');

    INSERT INTO cz_xfr_tables
     (order_seq, xfr_group, disabled, src_table, dst_table, dst_subschema, filtersyntax)
    VALUES
     (16, 'SEQUENCES', '0', 'CZ_END_USERS_S', 'CZ_END_USERS', 'END_USER_ID', '20');

    INSERT INTO cz_xfr_tables
     (order_seq, xfr_group, disabled, src_table, dst_table, dst_subschema, filtersyntax)
    VALUES
     (18, 'SEQUENCES', '0', 'CZ_EXPRESSIONS_S', 'CZ_EXPRESSIONS', 'EXPRESS_ID', '20');

    INSERT INTO cz_xfr_tables
     (order_seq, xfr_group, disabled, src_table, dst_table, dst_subschema, filtersyntax)
    VALUES
     (19, 'SEQUENCES', '0', 'CZ_EXPRESSION_NODES_S', 'CZ_EXPRESSION_NODES', 'EXPR_NODE_ID', '20');

    INSERT INTO cz_xfr_tables
     (order_seq, xfr_group, disabled, src_table, dst_table, dst_subschema, filtersyntax)
    VALUES
     (20, 'SEQUENCES', '0', 'CZ_FILTER_SETS_S', 'CZ_FILTER_SETS', 'FILTER_SET_ID', '20');

    INSERT INTO cz_xfr_tables
     (order_seq, xfr_group, disabled, src_table, dst_table, dst_subschema, filtersyntax)
    VALUES
     (22, 'SEQUENCES', '0', 'CZ_FUNC_COMP_SPECS_S', 'CZ_FUNC_COMP_SPECS', 'FUNC_COMP_ID', '20');

    INSERT INTO cz_xfr_tables
     (order_seq, xfr_group, disabled, src_table, dst_table, dst_subschema, filtersyntax)
    VALUES
     (23, 'SEQUENCES', '0', 'CZ_GRID_CELLS_S', 'CZ_GRID_CELLS', 'GRID_CELL_ID', '20');

    INSERT INTO cz_xfr_tables
     (order_seq, xfr_group, disabled, src_table, dst_table, dst_subschema, filtersyntax)
    VALUES
     (24, 'SEQUENCES', '0', 'CZ_GRID_COLS_S', 'CZ_GRID_COLS', 'GRID_COL_ID', '20');

    INSERT INTO cz_xfr_tables
     (order_seq, xfr_group, disabled, src_table, dst_table, dst_subschema, filtersyntax)
    VALUES
     (25, 'SEQUENCES', '0', 'CZ_GRID_DEFS_S', 'CZ_GRID_DEFS', 'GRID_ID', '20');

    INSERT INTO cz_xfr_tables
     (order_seq, xfr_group, disabled, src_table, dst_table, dst_subschema, filtersyntax)
    VALUES
     (26, 'SEQUENCES', '0', 'CZ_INTL_TEXTS_S', 'CZ_LOCALIZED_TEXTS', 'INTL_TEXT_ID', '20');

    INSERT INTO cz_xfr_tables
     (order_seq, xfr_group, disabled, src_table, dst_table, dst_subschema, filtersyntax)
    VALUES
     (27, 'SEQUENCES', '0', 'CZ_ITEM_MASTERS_S', 'CZ_ITEM_MASTERS', 'ITEM_ID', '20');

    INSERT INTO cz_xfr_tables
     (order_seq, xfr_group, disabled, src_table, dst_table, dst_subschema, filtersyntax)
    VALUES
     (30, 'SEQUENCES', '0', 'CZ_ITEM_TYPES_S', 'CZ_ITEM_TYPES', 'ITEM_TYPE_ID', '20');

    INSERT INTO cz_xfr_tables
     (order_seq, xfr_group, disabled, src_table, dst_table, dst_subschema, filtersyntax)
    VALUES
     (32, 'SEQUENCES', '0', 'CZ_LCE_HEADERS_S', 'CZ_LCE_HEADERS', 'LCE_HEADER_ID', '20');

    INSERT INTO cz_xfr_tables
     (order_seq, xfr_group, disabled, src_table, dst_table, dst_subschema, filtersyntax)
    VALUES
     (33, 'SEQUENCES', '0', 'CZ_LCE_LINES_S', 'CZ_LCE_LINES', 'LCE_LINE_ID', '20');

    INSERT INTO cz_xfr_tables
     (order_seq, xfr_group, disabled, src_table, dst_table, dst_subschema, filtersyntax)
    VALUES
     (34, 'SEQUENCES', '0', 'CZ_LCE_OPERANDS_S', 'CZ_LCE_OPERANDS', 'OPERAND_SEQ', '20');

    INSERT INTO cz_xfr_tables
     (order_seq, xfr_group, disabled, src_table, dst_table, dst_subschema, filtersyntax)
    VALUES
     (35, 'SEQUENCES', '0', 'CZ_LOCALES_S', 'CZ_LOCALES', 'LOCALE_ID', '20');

    INSERT INTO cz_xfr_tables
     (order_seq, xfr_group, disabled, src_table, dst_table, dst_subschema, filtersyntax)
    VALUES
     (37, 'SEQUENCES', '0', 'CZ_MODEL_PUBLICATIONS_S', 'CZ_MODEL_PUBLICATIONS', 'PUBLICATION_ID', '20');

    INSERT INTO cz_xfr_tables
     (order_seq, xfr_group, disabled, src_table, dst_table, dst_subschema, filtersyntax)
    VALUES
     (38, 'SEQUENCES', '0', 'CZ_MODEL_REF_EXPLS_S', 'CZ_MODEL_REF_EXPLS', 'MODEL_REF_EXPL_ID', '20');

    INSERT INTO cz_xfr_tables
     (order_seq, xfr_group, disabled, src_table, dst_table, dst_subschema, filtersyntax)
    VALUES
     (39, 'SEQUENCES', '0', 'CZ_MODEL_USAGES_S', 'CZ_MODEL_USAGES', 'MODEL_USAGE_ID', '1');

    INSERT INTO cz_xfr_tables
     (order_seq, xfr_group, disabled, src_table, dst_table, dst_subschema, filtersyntax)
    VALUES
     (40, 'SEQUENCES', '0', 'CZ_OPPORTUNITY_HDRS_S', 'CZ_OPPORTUNITY_HDRS', 'OPPORTUNITY_HDR_ID', '20');

    INSERT INTO cz_xfr_tables
     (order_seq, xfr_group, disabled, src_table, dst_table, dst_subschema, filtersyntax)
    VALUES
     (42, 'SEQUENCES', '0', 'CZ_PB_MODEL_EXPORTS_S', 'CZ_PB_MODEL_EXPORTS', 'EXPORT_ID', '1');

    INSERT INTO cz_xfr_tables
     (order_seq, xfr_group, disabled, src_table, dst_table, dst_subschema, filtersyntax)
    VALUES
     (43, 'SEQUENCES', '0', 'CZ_POPULATORS_S', 'CZ_POPULATORS', 'POPULATOR_ID', '20');

    INSERT INTO cz_xfr_tables
     (order_seq, xfr_group, disabled, src_table, dst_table, dst_subschema, filtersyntax)
    VALUES
     (44, 'SEQUENCES', '0', 'CZ_POPULATOR_MAPS_S', 'CZ_POPULATOR_MAPS', 'POP_MAP_ID', '20');

    INSERT INTO cz_xfr_tables
     (order_seq, xfr_group, disabled, src_table, dst_table, dst_subschema, filtersyntax)
    VALUES
     (46, 'SEQUENCES', '0', 'CZ_PRICE_GROUPS_S', 'CZ_PRICE_GROUPS', 'PRICE_GROUP_ID', '20');

    INSERT INTO cz_xfr_tables
     (order_seq, xfr_group, disabled, src_table, dst_table, dst_subschema, filtersyntax)
    VALUES
     (47, 'SEQUENCES', '0', 'CZ_PROPERTIES_S', 'CZ_PROPERTIES', 'PROPERTY_ID', '20');

    INSERT INTO cz_xfr_tables
     (order_seq, xfr_group, disabled, src_table, dst_table, dst_subschema, filtersyntax)
    VALUES
     (48, 'SEQUENCES', '0', 'CZ_PROPOSAL_HDRS_S', 'CZ_PROPOSAL_HDRS', 'PROPOSAL_HDR_ID', '20');

    INSERT INTO cz_xfr_tables
     (order_seq, xfr_group, disabled, src_table, dst_table, dst_subschema, filtersyntax)
    VALUES
     (50, 'SEQUENCES', '0', 'CZ_PSNODE_PROPCOMPAT_GENS_S', 'CZ_PSNODE_PROPCOMPAT_GENS', 'COMPAT_RUN', '20');

    INSERT INTO cz_xfr_tables
     (order_seq, xfr_group, disabled, src_table, dst_table, dst_subschema, filtersyntax)
    VALUES
     (51, 'SEQUENCES', '0', 'CZ_PS_NODES_S', 'CZ_PS_NODES', 'PS_NODE_ID', '20');

    INSERT INTO cz_xfr_tables
     (order_seq, xfr_group, disabled, src_table, dst_table, dst_subschema, filtersyntax)
    VALUES
     (53, 'SEQUENCES', '0', 'CZ_QUOTE_HDRS_S', 'CZ_QUOTE_HDRS', 'QUOTE_HDR_ID', '20');

    INSERT INTO cz_xfr_tables
     (order_seq, xfr_group, disabled, src_table, dst_table, dst_subschema, filtersyntax)
    VALUES
     (56, 'SEQUENCES', '0', 'CZ_QUOTE_SPARES_S', 'CZ_QUOTE_SPARES', 'SEQ_NUMBER', '20');

    INSERT INTO cz_xfr_tables
     (order_seq, xfr_group, disabled, src_table, dst_table, dst_subschema, filtersyntax)
    VALUES
     (57, 'SEQUENCES', '0', 'CZ_QUOTE_SPECIAL_ITEMS_S', 'CZ_QUOTE_SPECIAL_ITEMS', 'SEQ_NUMBER', '20');

    INSERT INTO cz_xfr_tables
     (order_seq, xfr_group, disabled, src_table, dst_table, dst_subschema, filtersyntax)
    VALUES
     (58, 'SEQUENCES', '0', 'CZ_REL_TYPES_S', 'CZ_REL_TYPES', 'REL_TYPE_ID', '20');

    INSERT INTO cz_xfr_tables
     (order_seq, xfr_group, disabled, src_table, dst_table, dst_subschema, filtersyntax)
    VALUES
     (59, 'SEQUENCES', '0', 'CZ_RP_ENTRIES_S', 'CZ_RP_ENTRIES', 'OBJECT_ID', '20');

    INSERT INTO cz_xfr_tables
     (order_seq, xfr_group, disabled, src_table, dst_table, dst_subschema, filtersyntax)
    VALUES
     (60, 'SEQUENCES', '0', 'CZ_RULES_S', 'CZ_RULES', 'RULE_ID', '20');

    INSERT INTO cz_xfr_tables
     (order_seq, xfr_group, disabled, src_table, dst_table, dst_subschema, filtersyntax)
    VALUES
     (61, 'SEQUENCES', '0', 'CZ_RULE_FOLDERS_S', 'CZ_RULE_FOLDERS', 'RULE_FOLDER_ID', '20');

    INSERT INTO cz_xfr_tables
     (order_seq, xfr_group, disabled, src_table, dst_table, dst_subschema, filtersyntax)
    VALUES
     (62, 'SEQUENCES', '0', 'CZ_SERVERS_S', 'CZ_SERVERS', 'SERVER_LOCAL_ID', '20');

    INSERT INTO cz_xfr_tables
     (order_seq, xfr_group, disabled, src_table, dst_table, dst_subschema, filtersyntax)
    VALUES
     (63, 'SEQUENCES', '0', 'CZ_SPARES_SPECIALS_S', 'CZ_SPARES_SPECIALS', 'PACKAGE_SEQ', '20');

    INSERT INTO cz_xfr_tables
     (order_seq, xfr_group, disabled, src_table, dst_table, dst_subschema, filtersyntax)
    VALUES
     (64, 'SEQUENCES', '0', 'CZ_SUB_CON_SETS_S', 'CZ_SUB_CON_SETS', 'SUB_CONS_ID', '20');

    INSERT INTO cz_xfr_tables
     (order_seq, xfr_group, disabled, src_table, dst_table, dst_subschema, filtersyntax)
    VALUES
     (65, 'SEQUENCES', '0', 'CZ_TERMINATE_MSGS_S', 'CZ_TERMINATE_MSGS', 'MSG_ID', '20');

    INSERT INTO cz_xfr_tables
     (order_seq, xfr_group, disabled, src_table, dst_table, dst_subschema, filtersyntax)
    VALUES
     (66, 'SEQUENCES', '0', 'CZ_UI_DEFS_S', 'CZ_UI_DEFS', 'UI_DEF_ID', '20');

    INSERT INTO cz_xfr_tables
     (order_seq, xfr_group, disabled, src_table, dst_table, dst_subschema, filtersyntax)
    VALUES
     (67, 'SEQUENCES', '0', 'CZ_UI_NODES_S', 'CZ_UI_NODES', 'UI_NODE_ID', '20');

    INSERT INTO cz_xfr_tables
     (order_seq, xfr_group, disabled, src_table, dst_table, dst_subschema, filtersyntax)
    VALUES
     (70, 'SEQUENCES', '0', 'CZ_USER_GROUPS_S', 'CZ_USER_GROUPS', 'USER_GROUP_ID', '20');

    INSERT INTO cz_xfr_tables
     (order_seq, xfr_group, disabled, src_table, dst_table, dst_subschema, filtersyntax)
    VALUES
     (71, 'SEQUENCES', '0', 'CZ_XFR_PROJECT_BILLS_S', 'CZ_XFR_PROJECT_BILLS', 'MODEL_PS_NODE_ID', '-1');

    INSERT INTO cz_xfr_tables
     (order_seq, xfr_group, disabled, src_table, dst_table, dst_subschema, filtersyntax)
    VALUES
     (72, 'SEQUENCES', '0', 'CZ_XFR_RUN_INFOS_S', 'CZ_XFR_RUN_INFOS', 'RUN_ID', '1');

--A. Tsyaston 14-Oct-2004 BUG 3937232 - Sequences added for synchronization.

    INSERT INTO cz_xfr_tables
     (order_seq, xfr_group, disabled, src_table, dst_table, dst_subschema, filtersyntax)
    VALUES
     (73, 'SEQUENCES', '0', 'CZ_ARCHIVES_S', 'CZ_ARCHIVES', 'ARCHIVE_ID', '20');

    INSERT INTO cz_xfr_tables
     (order_seq, xfr_group, disabled, src_table, dst_table, dst_subschema, filtersyntax)
    VALUES
     (74, 'SEQUENCES', '0', 'CZ_SIGNATURES_S', 'CZ_SIGNATURES', 'SIGNATURE_ID', '20');

    INSERT INTO cz_xfr_tables
     (order_seq, xfr_group, disabled, src_table, dst_table, dst_subschema, filtersyntax)
    VALUES
     (75, 'SEQUENCES', '0', 'CZ_UI_ACTIONS_S', 'CZ_UI_ACTIONS', 'UI_ACTION_ID', '20');

    INSERT INTO cz_xfr_tables
     (order_seq, xfr_group, disabled, src_table, dst_table, dst_subschema, filtersyntax)
    VALUES
     (76, 'SEQUENCES', '0', 'CZ_UI_PAGES_S', 'CZ_UI_PAGES', 'PAGE_ID', '20');

    INSERT INTO cz_xfr_tables
     (order_seq, xfr_group, disabled, src_table, dst_table, dst_subschema, filtersyntax)
    VALUES
     (77, 'SEQUENCES', '0', 'CZ_UI_PAGE_ELEMENTS_S', 'CZ_UI_PAGE_ELEMENTS', 'ELEMENT_ID', '20');

    INSERT INTO cz_xfr_tables
     (order_seq, xfr_group, disabled, src_table, dst_table, dst_subschema, filtersyntax)
    VALUES
     (78, 'SEQUENCES', '0', 'CZ_UI_PAGE_REFS_S', 'CZ_UI_PAGE_REFS', 'PAGE_REF_ID', '20');

    INSERT INTO cz_xfr_tables
     (order_seq, xfr_group, disabled, src_table, dst_table, dst_subschema, filtersyntax)
    VALUES
     (79, 'SEQUENCES', '0', 'CZ_UI_PAGE_SETS_S', 'CZ_UI_PAGE_SETS', 'PAGE_SET_ID', '20');

    INSERT INTO cz_xfr_tables
     (order_seq, xfr_group, disabled, src_table, dst_table, dst_subschema, filtersyntax)
    VALUES
     (80, 'SEQUENCES', '0', 'CZ_UI_TEMPLATES_S', 'CZ_UI_TEMPLATES', 'TEMPLATE_ID', '20');

END adjust_specific_control;
------------------------------------------------------------------------------------------------------------
--This procedure is not dynamic and significantly uses the specifics of the CZ database.
--In general, any change to this procedure will require a matching change in the
--adjust_specific_control procedure. Please review both procedures for any change.

FUNCTION verify_target_database RETURN PLS_INTEGER IS

  TYPE tabTableName IS TABLE OF all_tables.table_name%TYPE;

--A. Tsyaston 14-Oct-2004 BUG 3937232 - List revised.
--These tables must be empty:

  noRecords   tabTableName :=
    tabTableName(
'CZ_ADDRESSES', 'CZ_ADDRESS_USES', 'CZ_ARCHIVES', 'CZ_ARCHIVE_REFS', 'CZ_COMBO_FEATURES', 'CZ_CONFIG_ATTRIBUTES',
'CZ_CONFIG_EXT_ATTRIBUTES', 'CZ_CONFIG_HDRS', 'CZ_CONFIG_INPUTS', 'CZ_CONFIG_MESSAGES', 'CZ_CONFIG_USAGES',
'CZ_CONTACTS', 'CZ_CUSTOMER_END_USERS', 'CZ_DB_SIZES', 'CZ_DES_CHART_CELLS', 'CZ_DES_CHART_COLUMNS',
'CZ_DES_CHART_FEATURES', 'CZ_DEVL_PRJ_USER_GROUPS', 'CZ_DRILL_DOWN_ITEMS', 'CZ_EFFECTIVITY_SETS', 'CZ_EXPRESSIONS',
'CZ_FILTER_SETS', 'CZ_FUNC_COMP_REFS', 'CZ_FUNC_COMP_SPECS', 'CZ_GRID_CELLS', 'CZ_GRID_COLS', 'CZ_GRID_DEFS',
'CZ_ITEM_MASTERS', 'CZ_ITEM_PROPERTY_VALUES', 'CZ_ITEM_TYPE_PROPERTIES', 'CZ_JRAD_CHUNKS', 'CZ_LCE_CLOBS',
'CZ_LCE_HEADERS', 'CZ_LCE_LINES', 'CZ_LCE_LOAD_SPECS', 'CZ_LCE_OPERANDS', 'CZ_LCE_TEXTS', 'CZ_LOCALES',
'CZ_LOCK_HISTORY', 'CZ_MODEL_PUBLICATIONS', 'CZ_MODEL_REF_EXPLS', 'CZ_OPP_HDR_CONTACTS', 'CZ_PB_CLIENT_APPS',
'CZ_PB_LANGUAGES', 'CZ_PB_MODEL_EXPORTS', 'CZ_PB_TEMP_IDS', 'CZ_POPULATOR_MAPS', 'CZ_PRICES', 'CZ_PROPERTIES',
'CZ_PROPOSAL_HDRS', 'CZ_PROP_QUOTE_HDRS', 'CZ_PSNODE_PROPCOMPAT_GENS', 'CZ_PS_NODES', 'CZ_PS_PROP_VALS',
'CZ_PUBLICATION_USAGES', 'CZ_QUOTE_HDRS', 'CZ_QUOTE_MAIN_ITEMS', 'CZ_QUOTE_ORDERS', 'CZ_QUOTE_SPARES',
'CZ_QUOTE_SPECIAL_ITEMS', 'CZ_REL_TYPES', 'CZ_SPARES_SPECIALS', 'CZ_SUB_CON_SETS', 'CZ_UI_NODES',
'CZ_UI_NODE_PROPS', 'CZ_UI_PAGE_ELEMENTS', 'CZ_UI_PAGE_REFS', 'CZ_UI_PAGE_SETS', 'CZ_UI_PROPERTIES', 'CZ_UI_REFS',
'CZ_UI_TEMPLATE_ELEMENTS', 'CZ_UI_XMLS', 'CZ_XFR_FIELD_REQUIRES', 'CZ_XFR_PRICE_LISTS', 'CZ_XFR_PROJECT_BILLS',
'CZ_XFR_RUN_INFOS', 'CZ_XFR_RUN_RESULTS', 'CZ_XFR_STATUS_CODES');

  nCount     NUMBER;
  errorFlag  PLS_INTEGER := 0;
BEGIN

  FOR i IN 1..noRecords.COUNT LOOP
    EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || noRecords(i) INTO nCount;
    IF(nCount > 0)THEN

      --'Table ''%TABLENAME'' is not empty, %RECORDCOUNT records found.'
      report(CZ_UTILS.GET_TEXT('CZ_MIGR_TABLE_NOT_EMPTY', 'TABLENAME', noRecords(i), 'RECORDCOUNT', nCount), URGENCY_MESSAGE);
      errorFlag := 1;
    END IF;
  END LOOP;

--A. Tsyaston 14-Oct-2004 BUG 3937232.
--It does not add a lot of value to verify tables by number of seeded records. Besides, it makes the
--migration code relatively high maintainance. Removing these verifications as a part of the fix.

  IF(errorFlag = 1)THEN RETURN SKIPPABLE_ERROR; END IF;
  RETURN NO_ERROR;
END verify_target_database;

---------------------------
----This procedure retrieves the XML chunks (from the source instance)
----of the JRAD docs that are migrated to the target instance
----params:
----p_ui_def_id  : ui_def_id of the UI or that in the cz_ui_templates table
----p_template_id : template id in cz_ui_templates
----If template id is NULL then the JRAD docs of UI pages passed are extracted
----If both template_id and ui_def_id are passed in then the JRAD docs of UI templates
----are extracted
PROCEDURE get_xml_chunks (p_ui_def_id  IN NUMBER,
			     p_template_id IN NUMBER)
IS

l_length         BINARY_INTEGER;
l_buffer         VARCHAR2(32767);
firstChunk       VARCHAR2(32767);
DOCUMENT_IS_NULL EXCEPTION;
l_msg		 VARCHAR2(2000);
l_sql_code       NUMBER := 0;
l_seq_nbr        NUMBER := 0;

TYPE chunk_record IS RECORD (jrad_doc  VARCHAR2(255),
               seq_nbr   NUMBER,xml_chunk VARCHAR2(32767));

TYPE chunk_record_tbl IS TABLE OF chunk_record INDEX BY BINARY_INTEGER;
l_chunk_tbl     chunk_record_tbl;
l_jrad_doc_tbl  jraddoc_type_tbl;
l_exportfinished BOOLEAN;
BEGIN
   ----collect jrad docs for UI or templates
   BEGIN
     IF (p_template_id IS NULL) THEN
       SELECT jrad_doc
       BULK
       COLLECT
       INTO   l_jrad_doc_tbl
       FROM   cz_ui_pages
       WHERE  ui_def_id = p_ui_def_id
        AND   deleted_flag = '0';
     ELSE
       SELECT jrad_doc
       BULK
       COLLECT
       INTO   l_jrad_doc_tbl
       FROM   cz_ui_templates
       WHERE  cz_ui_templates.ui_def_id = p_ui_def_id
	AND   cz_ui_templates.template_id = p_template_id
        AND   cz_ui_templates.seeded_flag  =  '0'
        AND   cz_ui_templates.deleted_flag = '0';
     END IF;
   EXCEPTION
   WHEN NO_DATA_FOUND THEN
      NULL; ---do nothing
   END;

   IF (l_jrad_doc_tbl.COUNT > 0) THEN
      FOR I IN l_jrad_doc_tbl.FIRST..l_jrad_doc_tbl.LAST
	LOOP
	  BEGIN
          l_seq_nbr := 0;
          jdr_docbuilder.refresh;
          IF (l_jrad_doc_tbl(i) IS NULL) THEN
	       RAISE DOCUMENT_IS_NULL;
          END IF;
	    firstChunk := jdr_utils.EXPORTDOCUMENT(l_jrad_doc_tbl(i),l_exportfinished);
	   IF (firstChunk IS NULL) THEN
		RAISE DOCUMENT_IS_NULL;
	   END IF;

	   l_buffer := LTRIM(RTRIM(firstChunk));
	   IF (l_buffer IS NOT NULL) THEN
	     l_seq_nbr := l_seq_nbr + 1;
	     l_chunk_tbl(l_seq_nbr).jrad_doc  := l_jrad_doc_tbl(i);
	     l_chunk_tbl(l_seq_nbr).seq_nbr   := l_seq_nbr;
	     l_chunk_tbl(l_seq_nbr).xml_chunk := l_buffer;
	   END IF;

   	   LOOP
	     l_buffer := jdr_utils.EXPORTDOCUMENT(NULL,l_exportfinished);
	     l_buffer   := LTRIM(RTRIM(l_buffer));
	     EXIT WHEN l_buffer IS NULL;
	     IF (l_buffer IS NOT NULL) THEN
      	  l_seq_nbr := l_seq_nbr + 1;
	        l_chunk_tbl(l_seq_nbr).jrad_doc  := l_jrad_doc_tbl(i);
      	  l_chunk_tbl(l_seq_nbr).seq_nbr   := l_seq_nbr;
	        l_chunk_tbl(l_seq_nbr).xml_chunk := l_buffer;
	     END IF;
	   END LOOP;

	   IF (l_chunk_tbl.COUNT > 0) THEN
            FOR I IN 1..l_seq_nbr
	      LOOP
  		insert into cz_jrad_chunks(jrad_doc,seq_nbr,xml_chunk)
      	        values (l_chunk_tbl(i).jrad_doc,l_chunk_tbl(i).seq_nbr,l_chunk_tbl(i).xml_chunk);
	      END LOOP;
	   END IF;
	   commit;
	   jdr_docbuilder.refresh;
	EXCEPTION
	WHEN DOCUMENT_IS_NULL THEN
	   NULL;  --- if no documnet exists, then it is OK, do not raise an error
 	WHEN OTHERS THEN
	   RAISE;
	END;
    END LOOP;
  END IF;
  COMMIT;
END get_xml_chunks ;

----------------------------------------------------------------------
-----This procedure imports the JRAD docs
-----of a UI from the source to the target instance
PROCEDURE import_jrad_docs (p_ui_def_id IN NUMBER,
			    p_link_name IN VARCHAR2,
			    x_return_status OUT NOCOPY VARCHAR2,
			    x_msg_count  OUT NOCOPY NUMBER,
			    x_msg_data   OUT NOCOPY VARCHAR2)
IS
l_link_name     cz_servers.fndnam_link_name%TYPE;
l_ref_cursor    ref_cursor;
l_jrad_doc      cz_jrad_chunks.jrad_doc%TYPE;
l_seq_nbr       cz_jrad_chunks.seq_nbr%TYPE;
l_XML_CHUNK     VARCHAR2(32767);
l_template_id   cz_ui_templates.template_id%TYPE := NULL;
BEGIN
   ----initialize link name
   IF (p_link_name IS NULL) THEN  l_link_name := ' ';
      ELSE l_link_name     := '@'||p_link_name;
   END IF;

   ----delete from temp table on target and source
   EXECUTE IMMEDIATE
    ' begin delete from cz_jrad_chunks'||l_link_name||'; commit; end; ';
      delete from cz_jrad_chunks; commit;

   ----get XML chunks from the target to be imported
   EXECUTE IMMEDIATE 'begin cz_migrate.get_xml_chunks'||l_link_name||'(:1,:2); end;'
   USING p_ui_def_id,l_template_id;

   ----insert XML chunks from the target to the cz_jrad_chunks table on the source
   OPEN l_ref_cursor FOR 'SELECT JRAD_DOC,SEQ_NBR,XML_CHUNK
	                  FROM cz_jrad_chunks'||l_link_name;
   LOOP
     FETCH l_ref_cursor INTO l_jrad_doc,l_seq_nbr,l_XML_CHUNK;
     EXIT WHEN l_ref_cursor%NOTFOUND;
     insert into cz_jrad_chunks (JRAD_DOC,SEQ_NBR,XML_CHUNK)
	values (l_jrad_doc,l_seq_nbr,l_XML_CHUNK);
    END LOOP;
    COMMIT;
    CLOSE l_ref_cursor;

    -----upload the XML to the jrad repository
    cz_pb_mgr.insert_jrad_docs;

    ----delete from temp table on target and source
    EXECUTE IMMEDIATE
    ' begin delete from cz_jrad_chunks'||l_link_name||'; commit; end; ';
     delete from cz_jrad_chunks; commit;
EXCEPTION
WHEN NO_DATA_FOUND THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   x_msg_count := 1;
   x_msg_data := CZ_UTILS.GET_TEXT('CZ_NO_JRADDOC_EXISTS','DOC',p_ui_def_id );
WHEN EXPLORETREE_ERROR THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   x_msg_count := 1;

   fnd_message.set_name('FND', 'FND_AS_UNEXPECTED_ERROR');
   fnd_message.set_token('ERROR_TEXT', SQLERRM);
   fnd_message.set_token('PKG_NAME', 'CZ_PB_MGR');
   fnd_message.set_token('PROCEDURE_NAME', 'INSERT_JRAD_DOCS');

   x_msg_data := fnd_message.get;
WHEN OTHERS THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   x_msg_count := 1;
   x_msg_data := CZ_UTILS.GET_TEXT('CZ_JRADDOC_EXPERR', 'ERR', SQLERRM);
END import_jrad_docs;

----------------------------------
-----This procedure imports all the JRAD docs
-----of a UI templates from the source to the target instance
PROCEDURE import_template_jrad_docs (p_link_name IN VARCHAR2,
				    x_return_status OUT NOCOPY VARCHAR2,
				    x_msg_count  OUT NOCOPY NUMBER,
				    x_msg_data   OUT NOCOPY VARCHAR2)
IS
TYPE t_ref IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
l_ui_def_id_tbl   t_ref;
l_template_id_tbl t_ref;
l_link_name       cz_servers.fndnam_link_name%TYPE;
l_ref_cursor      ref_cursor;
l_jrad_doc	      cz_jrad_chunks.jrad_doc%TYPE;
l_seq_nbr         cz_jrad_chunks.seq_nbr%TYPE;
l_XML_CHUNK       VARCHAR2(32767);

BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF (p_link_name IS NULL) THEN l_link_name := ' ';
       ELSE l_link_name := '@'||p_link_name;
    END IF;

    SELECT  ui_def_id, template_id
    BULK
    COLLECT
    INTO    l_ui_def_id_tbl,l_template_id_tbl
    FROM    cz_ui_templates
    WHERE   cz_ui_templates.deleted_flag = '0'
    AND     cz_ui_templates.seeded_flag = '0'
    AND     cz_ui_templates.ui_def_id = 0
    OR      cz_ui_templates.ui_def_id  IN  (SELECT ui_def_id
                                            FROM   cz_ui_defs
				                    WHERE  cz_ui_defs.deleted_flag = '0');

   IF (l_ui_def_id_tbl.COUNT > 0) THEN
      FOR I IN l_ui_def_id_tbl.FIRST..l_ui_def_id_tbl.LAST
      LOOP
	 ----delete from temp table on target and source
         EXECUTE IMMEDIATE
         ' begin delete from cz_jrad_chunks'||l_link_name||'; commit; end; ';
         delete from cz_jrad_chunks; commit;

        ----get XML chunks from the target to be imported
        EXECUTE IMMEDIATE
                'begin cz_migrate.get_xml_chunks'||l_link_name||'(:1,:2); end;'
	  USING l_ui_def_id_tbl(i),l_template_id_tbl(i);

        ----insert XML chunks from the target to the cz_jrad_chunks table on the source
        OPEN l_ref_cursor FOR 'SELECT JRAD_DOC,SEQ_NBR,XML_CHUNK
	                  FROM cz_jrad_chunks'||l_link_name;
        LOOP
           FETCH l_ref_cursor INTO l_jrad_doc,l_seq_nbr,l_XML_CHUNK;
           EXIT WHEN l_ref_cursor%NOTFOUND;
           insert into cz_jrad_chunks (JRAD_DOC,SEQ_NBR,XML_CHUNK)
	   values (l_jrad_doc,l_seq_nbr,l_XML_CHUNK);
        END LOOP;
        COMMIT;
        CLOSE l_ref_cursor;

        -----upload the XML to the jrad repository
        cz_pb_mgr.insert_jrad_docs;

        ----delete from temp table on target and source
        EXECUTE IMMEDIATE
        ' begin delete from cz_jrad_chunks'||l_link_name||'; commit; end; ';
         delete from cz_jrad_chunks; commit;
     END LOOP;
  END IF;
EXCEPTION
WHEN NO_DATA_FOUND THEN
   NULL;
WHEN EXPLORETREE_ERROR THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   x_msg_count := 1;

   fnd_message.set_name('FND', 'FND_AS_UNEXPECTED_ERROR');
   fnd_message.set_token('ERROR_TEXT', SQLERRM);
   fnd_message.set_token('PKG_NAME', 'CZ_PB_MGR');
   fnd_message.set_token('PROCEDURE_NAME', 'INSERT_JRAD_DOCS');

   x_msg_data := fnd_message.get;
WHEN OTHERS THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   x_msg_data      := SQLERRM;
END import_template_jrad_docs ;
------------------------------------------------------------------------------------------------------------
END cz_migrate;

/
