--------------------------------------------------------
--  DDL for Package Body CZ_IMP_ALL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CZ_IMP_ALL" AS
/*	$Header: cziallb.pls 120.4 2007/11/26 07:59:44 kdande ship $		*/
------------------------------------------------------------------------------------------
FUNCTION isTracingEnabled RETURN BOOLEAN IS
   nEnableTrace VARCHAR2(1) := '0';
   v_settings_id      VARCHAR2(40);
   v_section_name     VARCHAR2(30);
BEGIN

  v_settings_id := 'ENABLETRACE';
  v_section_name := 'IMPORT';

  SELECT decode(upper(VALUE),'TRUE','1','FALSE','0','T','1','F','0','1','1',
                 '0','0','YES','1','NO','0','Y','1', 'N', '0','0')
  INTO nEnableTrace FROM CZ_DB_SETTINGS
  WHERE upper(SETTING_ID)=v_settings_id AND SECTION_NAME=v_section_name;
  RETURN (nEnableTrace = '1');
EXCEPTION
  WHEN OTHERS THEN
   RETURN FALSE;
END isTracingEnabled;
------------------------------------------------------------------------------------------
FUNCTION isTimingLogEnabled RETURN BOOLEAN IS
   nEnableLog VARCHAR2(1) := '0';
   v_settings_id      VARCHAR2(40);
   v_section_name     VARCHAR2(30);
BEGIN

  v_settings_id := 'TIMEIMPORT';
  v_section_name := 'IMPORT';

  SELECT decode(upper(VALUE),'TRUE','1','FALSE','0','T','1','F','0','1','1',
                 '0','0','YES','1','NO','0','Y','1', 'N', '0','0')
  INTO nEnableLog FROM CZ_DB_SETTINGS
  WHERE upper(SETTING_ID)=v_settings_id AND SECTION_NAME=v_section_name;
  RETURN (nEnableLog='1');
EXCEPTION
  WHEN OTHERS THEN
   RETURN FALSE;
END isTimingLogEnabled;
------------------------------------------------------------------------------------------
PROCEDURE go_cp(errbuf OUT NOCOPY VARCHAR2,retcode OUT NOCOPY NUMBER) IS
 xERROR       BOOLEAN:=FALSE;
BEGIN
  go(errbuf,retcode);
  errbuf:='';
  retcode:=0;
EXCEPTION
  WHEN CZ_ADMIN.IMP_ACTIVE_SESSION_EXISTS THEN
    retcode:=2;
    errbuf:=CZ_UTILS.GET_TEXT('CZ_IMP_ACTIVE_SESSION_EXISTS');
    xERROR:=cz_utils.log_report(errbuf,1,'CZ_IMP_ALL.go_cp',11276,NULL);
    RAISE;
  WHEN CZ_ADMIN.IMP_MAXERR_REACHED THEN
    retcode:=2;
    errbuf:=CZ_UTILS.GET_TEXT('CZ_IMP_MAXERR_REACHED');
    xERROR:=cz_utils.log_report(errbuf,1,'CZ_IMP_ALL.go_cp',11276,NULL);
    RAISE;
  WHEN OTHERS THEN
    retcode:=2;
    errbuf:=CZ_UTILS.GET_TEXT('CZ_IMP_OPERATION_FAILED', 'ERRORTEXT', SQLERRM);
    xERROR:=cz_utils.log_report(errbuf,1,'CZ_IMP_ALL.go_cp',11276,NULL);
    RAISE;
END go_cp;

------------------------------------------------------------------------------------------
PROCEDURE setReturnCode(retcode IN NUMBER, errbuf IN VARCHAR2) IS
BEGIN
  IF(retcode > CZ_ORAAPPS_INTEGRATE.mRETCODE)THEN

    CZ_ORAAPPS_INTEGRATE.mRETCODE := retcode;
    CZ_ORAAPPS_INTEGRATE.mERRBUF := errbuf;
  END IF;
END setReturnCode;
------------------------------------------------------------------------------------------
PROCEDURE goSingleBill_cp
(errbuf IN OUT NOCOPY VARCHAR2,retcode IN OUT NOCOPY NUMBER,nORG_ID IN NUMBER,nTOP_ID IN NUMBER,
                       COPY_CHILD_MODELS IN VARCHAR2 DEFAULT '0',
                       REFRESH_MODEL_ID  IN NUMBER DEFAULT -1,
				       COPY_ROOT_MODEL   IN VARCHAR2 DEFAULT '0') IS

 xERROR       BOOLEAN:=FALSE;
 l_run_id     NUMBER;

BEGIN

  CZ_ORAAPPS_INTEGRATE.mERRBUF := '';
  CZ_ORAAPPS_INTEGRATE.mRETCODE := 0;

  /* Log a message if the bill being imported (not refreshed) refers to a common bill */
  IF (REFRESH_MODEL_ID = -1) THEN
	  check_for_common_bill(errbuf,retcode,nORG_ID,nTOP_ID);
  END IF;
  goSingleBill(nORG_ID,nTOP_ID,COPY_CHILD_MODELS,REFRESH_MODEL_ID, '0', l_run_id);

  errbuf := CZ_ORAAPPS_INTEGRATE.mERRBUF;
  retcode := CZ_ORAAPPS_INTEGRATE.mRETCODE;

EXCEPTION
  WHEN CZ_ADMIN.IMP_ACTIVE_SESSION_EXISTS THEN
    retcode:=2;
    errbuf:=CZ_UTILS.GET_TEXT('CZ_IMP_ACTIVE_SESSION_EXISTS');
    xERROR:=cz_utils.log_report(errbuf,1,'CZ_IMP_ALL.goSingleBill_cp',11276,NULL);
    RAISE;
  WHEN CZ_ADMIN.IMP_MAXERR_REACHED THEN
    retcode:=2;
    errbuf:=CZ_UTILS.GET_TEXT('CZ_IMP_MAXERR_REACHED');
    xERROR:=cz_utils.log_report(errbuf,1,'CZ_IMP_ALL.goSingleBill_cp',11276,NULL);
    RAISE;
   WHEN CZ_ADMIN.IMP_UNEXP_SQL_ERROR THEN
     RAISE;
  WHEN OTHERS THEN
    retcode:=2;
    errbuf:=CZ_UTILS.GET_TEXT('CZ_IMP_OPERATION_FAILED','ERRORTEXT',SQLERRM);
    xERROR:=cz_utils.log_report(errbuf,1,'CZ_IMP_ALL.goSingleBill_cp',11276,NULL);
    RAISE;
END goSingleBill_cp;
------------------------------------------------------------------------------------------
PROCEDURE go(errbuf IN OUT NOCOPY VARCHAR2,retcode IN OUT NOCOPY NUMBER) IS

 xERROR       BOOLEAN:=FALSE;
 nTop_ID      CZ_XFR_PROJECT_BILLS.TOP_ITEM_ID%TYPE;
 nOrg_ID      CZ_XFR_PROJECT_BILLS.ORGANIZATION_ID%TYPE;
 sExplType    CZ_XFR_PROJECT_BILLS.EXPLOSION_TYPE%TYPE;
 sCopyModels  CZ_XFR_PROJECT_BILLS.copy_addl_child_models%TYPE;
 nModelId     CZ_XFR_PROJECT_BILLS.model_ps_node_id%TYPE;
 nServerId    cz_servers.server_local_id%TYPE;

TYPE tOrgId    IS TABLE OF cz_xfr_project_bills.organization_id%TYPE INDEX BY BINARY_INTEGER;
TYPE tTopItemId    IS TABLE OF cz_xfr_project_bills.top_item_id%TYPE INDEX BY BINARY_INTEGER;
TYPE tExplType    IS TABLE OF cz_xfr_project_bills.explosion_type%TYPE INDEX BY BINARY_INTEGER;
TYPE tCopyChildModel    IS TABLE OF cz_xfr_project_bills.copy_addl_child_models%TYPE INDEX BY BINARY_INTEGER;
TYPE tModelId    IS TABLE OF cz_xfr_project_bills.model_ps_node_id%TYPE INDEX BY BINARY_INTEGER;

orgId			tOrgId;
topItemId		tTopItemId ;
explType 		tExplType;
copyChildModel 	tCopyChildModel;
modelId 		tModelId;
l_run_id          NUMBER; -- sselahi: added to pass to the call to CZ_IMP_SINGLE.ImportSingleBill

v_enabled         VARCHAR2(1) := '1';
BEGIN

 BEGIN
  SELECT server_local_id INTO nServerId
    FROM cz_servers
   WHERE import_enabled = v_enabled;
 EXCEPTION
   WHEN TOO_MANY_ROWS THEN
     retcode:=2;
     errbuf:=CZ_UTILS.GET_TEXT('CZ_IMP_TOO_MANY_SERVERS');
     xERROR:=cz_utils.log_report(errbuf,1,'CZ_IMP_ALL.go',11276,NULL);
     RAISE;
   WHEN NO_DATA_FOUND THEN
     retcode:=2;
     errbuf:=CZ_UTILS.GET_TEXT('CZ_IMP_NO_SERVERS');
     xERROR:=cz_utils.log_report(errbuf,1,'CZ_IMP_ALL.go',11276,NULL);
     RAISE;
 END;

SELECT organization_id, top_item_id, explosion_type, NVL(copy_addl_child_models, '0'), model_ps_node_id
BULK COLLECT INTO
orgId,topItemId,explType,copyChildModel,modelId
FROM cz_xfr_project_bills
WHERE deleted_flag = '0'
   AND source_server = nServerId;

IF(orgId.COUNT = 0)THEN
  retcode:=2;
  errbuf:=CZ_UTILS.GET_TEXT('CZ_IMP_NO_IMPORTED_MODELS');
  xERROR:=cz_utils.log_report(errbuf,1,'CZ_IMP_ALL.GO',11276,NULL);
  RETURN;
END IF;

FOR i IN orgId.FIRST .. orgId.LAST
 LOOP
  /* Log a message if the bill being imported (not refreshed) refers to a common bill */
  check_for_common_bill(errbuf,retcode,orgId(i), topItemId(i));
  CZ_IMP_SINGLE.ImportSingleBill(orgId(i), topItemId(i), copyChildModel(i), modelId(i), '0', explType(i), SYSDATE, l_run_id); -- sselahi: added l_run_id
 END LOOP;
 COMMIT;
EXCEPTION
   WHEN CZ_ADMIN.IMP_UNEXP_SQL_ERROR THEN
     RAISE;
  WHEN OTHERS THEN
    retcode:=2;
    errbuf:=CZ_UTILS.GET_TEXT('CZ_IMP_OPERATION_FAILED','ERRORTEXT',SQLERRM);
    xERROR:=cz_utils.log_report(errbuf,1,'CZ_IMP_ALL.GO',11276,NULL);
    RAISE;
END go;
------------------------------------------------------------------------------------------
PROCEDURE go_generic(outRun_ID IN OUT NOCOPY PLS_INTEGER,
                     inRun_ID IN PLS_INTEGER DEFAULT NULL, p_rp_folder_id IN NUMBER) IS
   genRun_ID        PLS_INTEGER;
   nCommit_size     PLS_INTEGER DEFAULT 1;
   nMax_err         PLS_INTEGER DEFAULT 10000;
   sTableName       CZ_XFR_TABLES.DST_TABLE%TYPE;
   sSrcTableName    CZ_XFR_TABLES.SRC_TABLE%TYPE;
   xERROR           BOOLEAN:=FALSE;
   bAutoCreateUsers CZ_DB_SETTINGS.VALUE%TYPE:='NO';
   bRunExploder     CZ_DB_SETTINGS.VALUE%TYPE:='NO';
   outGrp_ID        NUMBER;
   outError_code    NUMBER;
   outErr_msg       VARCHAR2(255);
   d_str            varchar2(255);
   l_failed         NUMBER :=0;

   CURSOR C_IMPORT_ORDER IS
    SELECT DST_TABLE,SRC_TABLE FROM CZ_XFR_TABLES
    WHERE XFR_GROUP='GENERIC' AND DISABLED='0'
    ORDER BY ORDER_SEQ;

   v_settings_id      VARCHAR2(40);
   v_section_name     VARCHAR2(30);

BEGIN

  CZ_ADMIN.SPX_SYNC_IMPORTSESSIONS;
  DBMS_APPLICATION_INFO.SET_MODULE('CZIMPORT','');

----1) Insert new record into XFR_RUN_INFO and get the generated Run_ID for this import

       IF(inRun_ID IS NOT NULL)THEN
         genRun_ID:=inRun_ID;
         INSERT INTO CZ_XFR_RUN_INFOS (RUN_ID,STARTED,LAST_ACTIVITY,COMPLETED)
         SELECT genRun_ID,SYSDATE,SYSDATE,'0' FROM DUAL WHERE NOT EXISTS
         (SELECT 1 FROM CZ_XFR_RUN_INFOS WHERE RUN_ID=genRun_ID);
         UPDATE CZ_XFR_RUN_INFOS SET
           STARTED=SYSDATE,LAST_ACTIVITY=SYSDATE,COMPLETED='0'
         WHERE RUN_ID=genRun_ID;
         COMMIT;

         OPEN C_IMPORT_ORDER;
         LOOP
          BEGIN
           FETCH C_IMPORT_ORDER INTO sTableName,sSrcTableName;
           EXIT WHEN C_IMPORT_ORDER%NOTFOUND;
           setRecStatus(genRun_ID,sSrcTableName);
           EXCEPTION
             WHEN OTHERS THEN
               d_str:=CZ_UTILS.GET_TEXT('CZ_IMP_OPERATION_FAILED', 'ERRORTEXT', SQLERRM);
               xERROR:=cz_utils.log_report(d_str,1,'GO_GENERIC.SETRECSTATUS',11276,genRun_ID);
               RAISE;
          END;
         END LOOP;
         CLOSE C_IMPORT_ORDER;
       ELSE
         SELECT CZ_XFR_RUN_INFOS_S.NEXTVAL INTO genRun_ID FROM DUAL;
         INSERT INTO CZ_XFR_RUN_INFOS (RUN_ID,STARTED,LAST_ACTIVITY,COMPLETED)
         SELECT genRun_ID,SYSDATE,SYSDATE,'0' FROM DUAL WHERE NOT EXISTS
         (SELECT 1 FROM CZ_XFR_RUN_INFOS WHERE RUN_ID=genRun_ID);
         UPDATE CZ_XFR_RUN_INFOS SET
           STARTED=SYSDATE,LAST_ACTIVITY=SYSDATE,COMPLETED='0'
         WHERE RUN_ID=genRun_ID;
         COMMIT;

         OPEN C_IMPORT_ORDER;
         LOOP
          BEGIN
           FETCH C_IMPORT_ORDER INTO sTableName,sSrcTableName;
           EXIT WHEN C_IMPORT_ORDER%NOTFOUND;
           setRunID(genRun_ID,sSrcTableName);
           EXCEPTION
             WHEN OTHERS THEN
               d_str:=CZ_UTILS.GET_TEXT('CZ_IMP_OPERATION_FAILED', 'ERRORTEXT', SQLERRM);
               xERROR:=cz_utils.log_report(d_str,1,'GO_GENERIC.SETRUNID',11276,genRun_ID);
               RAISE;
          END;
         END LOOP;
         CLOSE C_IMPORT_ORDER;
       END IF;
       outRun_ID:=genRun_ID;
       COMMIT;

----2) Get the COMMIT_SIZE and MAX_ERR values from CZ_DB_SETTINGS

       v_settings_id := 'CommitSize';
       v_section_name := 'IMPORT';

       BEGIN
        SELECT VALUE INTO nCommit_size FROM CZ_DB_SETTINGS
        WHERE SETTING_ID=v_settings_id AND SECTION_NAME=v_section_name;
       EXCEPTION
         WHEN NO_DATA_FOUND THEN
           d_str:=CZ_UTILS.GET_TEXT('CZ_IMP_NO_COMMITSIZE');
           xERROR:=cz_utils.log_report(d_str,1,'GO_GENERIC.CZ_DB_SETTINGS',11276,genRun_ID);
         WHEN OTHERS THEN
           xERROR:=cz_utils.log_report(SQLERRM,1,'GO_GENERIC.CZ_DB_SETTINGS.COMMITSIZE',11276,genRun_ID);
           RAISE CZ_ADMIN.IMP_UNEXP_SQL_ERROR;
       END;

       v_settings_id := 'MaximumErrors';
       v_section_name := 'IMPORT';

       BEGIN
        SELECT VALUE INTO nMax_err FROM CZ_DB_SETTINGS
        WHERE SETTING_ID=v_settings_id AND SECTION_NAME=v_section_name;
       EXCEPTION
         WHEN NO_DATA_FOUND THEN
           d_str:=CZ_UTILS.GET_TEXT('CZ_IMP_NO_MAX_ERR');
           xERROR:=cz_utils.log_report(d_str,1,'GO_GENERIC.CZ_DB_SETTINGS',11276,genRun_ID);
         WHEN OTHERS THEN
           xERROR:=cz_utils.log_report(SQLERRM,1,'GO_GENERIC.CZ_DB_SETTINGS.MAXERRORS',11276,genRun_ID);
           RAISE CZ_ADMIN.IMP_UNEXP_SQL_ERROR;
       END;

----3) Call all the import procedures in the order specified by ORDER_SEQ field of
-----  CZ_XFR_TABLES with XFR_GROUP='IMPORT'

       import_before_start;

       OPEN C_IMPORT_ORDER;
       LOOP
        BEGIN
         FETCH C_IMPORT_ORDER INTO sTableName,sSrcTableName;
         EXIT WHEN C_IMPORT_ORDER%NOTFOUND;

         populate_table(genRun_ID,sTableName,nCommit_size,nMax_err,'GENERIC', p_rp_folder_id, l_failed);

         EXCEPTION
           WHEN CZ_ADMIN.IMP_UNEXP_SQL_ERROR THEN
             RAISE;
           WHEN OTHERS THEN
             d_str:=CZ_UTILS.GET_TEXT('CZ_IMP_OPERATION_FAILED', 'ERRORTEXT', SQLERRM);
             xERROR:=cz_utils.log_report(d_str,1,'GO_GENERIC.IMPORT',11276,NULL);
             RAISE CZ_ADMIN.IMP_UNEXP_SQL_ERROR;
        END;
       END LOOP;
       CLOSE C_IMPORT_ORDER;

       import_after_complete(genRun_ID);

----4) Finally update the (LAST_ACTIVITY,COMPLETED) fields of CZ_XFR_RUN_INFOS

       UPDATE CZ_XFR_RUN_INFOS SET
        LAST_ACTIVITY=SYSDATE,
        COMPLETED='1'
       WHERE RUN_ID=genRun_ID;
       COMMIT;

----5) and create database users if necessary

       v_settings_id := 'AUTOCREATE_IMPORTED_USERS';
       v_section_name := 'ORAAPPS_INTEGRATE';

       BEGIN
         SELECT VALUE INTO bAutoCreateUsers FROM CZ_DB_SETTINGS
         WHERE SETTING_ID=v_settings_id AND SECTION_NAME=v_section_name;
       EXCEPTION
         WHEN OTHERS THEN
           bAutoCreateUsers:='NO';
           xERROR:=cz_utils.log_report(CZ_UTILS.GET_TEXT('CZ_IMP_NO_AUTOCREATE_SETTING'),1,'GO_GENERIC',11276,genRun_ID);
       END;
         IF(bAutoCreateUsers='YES' OR bAutoCreateUsers='NAMED_ONLY')THEN
          CZ_ADMIN.ENABLE_END_USERS;
         ELSE
          CZ_ADMIN.VALIDATE_END_USERS;
         END IF;

       --DBMS_OUTPUT.PUT_LINE(CZ_UTILS.GET_TEXT('CZ_IMP_IMPORT_COMPLETED','RUNID',TO_CHAR(genRun_ID)));

    COMMIT;
    DBMS_APPLICATION_INFO.SET_MODULE('','');

EXCEPTION
  WHEN CZ_ADMIN.IMP_ACTIVE_SESSION_EXISTS THEN
    xERROR:=cz_utils.log_report(CZ_UTILS.GET_TEXT('CZ_IMP_ACTIVE_SESSION_EXISTS'),1,'GO_GENERIC',11276,genRun_ID);
    DBMS_APPLICATION_INFO.SET_MODULE('','');
    RAISE;
  WHEN CZ_ADMIN.IMP_UNEXP_SQL_ERROR THEN
    DBMS_APPLICATION_INFO.SET_MODULE('','');
    RAISE;
  WHEN OTHERS THEN
    d_str:=CZ_UTILS.GET_TEXT('CZ_IMP_OPERATION_FAILED', 'ERRORTEXT', SQLERRM);
    xERROR:=cz_utils.log_report(d_str,1,'CZ_IMP_ALL.GO_GENERIC',11276,NULL);
    DBMS_APPLICATION_INFO.SET_MODULE('','');
    RAISE;
END go_generic;
------------------------------------------------------------------------------------------
PROCEDURE populate_table(inRun_ID    IN PLS_INTEGER,
                         table_name  IN VARCHAR2,
                         commit_size IN PLS_INTEGER,
                         max_err     IN PLS_INTEGER,
                         inXFR_GROUP IN VARCHAR2,
                         p_rp_folder_id IN NUMBER,
                         x_failed       IN OUT NOCOPY NUMBER)
IS
  lower_table_name  VARCHAR2(50) := LOWER(table_name);
  xERROR            BOOLEAN:=FALSE;
  Inserts  PLS_INTEGER;
  Updates  PLS_INTEGER;
  Failed   PLS_INTEGER;
  Dups     PLS_INTEGER;
  d_str    varchar2(255);
BEGIN
  --DBMS_OUTPUT.ENABLE;
  --DBMS_OUTPUT.PUT_LINE('IMPORTING TABLE: ' || lower_table_name);
  IF(lower_table_name='cz_item_masters') THEN
     CZ_IMP_IM_MAIN.MAIN_ITEM_MASTER(inRun_ID, commit_size, max_err,
                                  Inserts, Updates, x_failed, Dups, inXFR_GROUP);
  ELSIF(lower_table_name='cz_ps_nodes') THEN
     CZ_IMP_PS_NODE.MAIN_PS_NODE(inRun_ID, commit_size, max_err,
                                     Inserts, Updates, x_failed, Dups, inXFR_GROUP);
  ELSIF(lower_table_name='cz_customers') THEN
     CZ_IMP_AC_MAIN.MAIN_CUSTOMER(inRun_ID, commit_size, max_err,
                              Inserts, Updates, x_failed, Dups, inXFR_GROUP);
  ELSIF(lower_table_name='cz_customer_end_users') THEN
     CZ_IMP_AC_MAIN.MAIN_CUSTOMER_END_USER(inRun_ID, commit_size, max_err,
                                       Inserts, Updates, x_failed, Dups, inXFR_GROUP);
  ELSIF(lower_table_name='cz_addresses') THEN
     CZ_IMP_AC_MAIN.MAIN_ADDRESS(inRun_ID, commit_size, max_err,
                              Inserts, Updates, x_failed, Dups, inXFR_GROUP);
  ELSIF(lower_table_name='cz_address_uses') THEN
     CZ_IMP_AC_MAIN.MAIN_ADDRESS_USES(inRun_ID, commit_size, max_err,
                                   Inserts, Updates, x_failed, Dups, inXFR_GROUP);
  ELSIF(lower_table_name='cz_contacts') THEN
     CZ_IMP_AC_MAIN.MAIN_CONTACT(inRun_ID, commit_size, max_err,
                              Inserts, Updates, x_failed, Dups, inXFR_GROUP);
  ELSIF(lower_table_name='cz_prices') THEN
     CZ_IMP_PR_MAIN.MAIN_PRICE(inRun_ID, commit_size, max_err,
                            Inserts, Updates, x_failed, Dups, inXFR_GROUP);
  ELSIF(lower_table_name='cz_price_groups') THEN
     CZ_IMP_PR_MAIN.MAIN_PRICE_GROUP(inRun_ID, commit_size, max_err,
                                  Inserts, Updates, x_failed, Dups, inXFR_GROUP);
  ELSIF(lower_table_name='cz_localized_texts') THEN
     CZ_IMP_PS_NODE.MAIN_INTL_TEXT(inRun_ID, commit_size, max_err,
                                       Inserts, Updates, x_failed, Dups, inXFR_GROUP);
  ELSIF(lower_table_name='cz_devl_projects') THEN
     CZ_IMP_PS_NODE.MAIN_DEVL_PROJECT(inRun_ID, commit_size, max_err,
                                      Inserts, Updates, x_failed, Dups,
                                      inXFR_GROUP, p_rp_folder_id); -- sselahi rpf
  ELSIF(lower_table_name='cz_end_users') THEN
     CZ_IMP_AC_MAIN.MAIN_END_USER(inRun_ID, commit_size, max_err,
                               Inserts, Updates, x_failed, Dups, inXFR_GROUP);
  ELSIF(lower_table_name='cz_end_user_groups') THEN
     CZ_IMP_AC_MAIN.MAIN_END_USER_GROUP(inRun_ID, commit_size, max_err,
                                     Inserts, Updates, x_failed, Dups, inXFR_GROUP);
  ELSIF(lower_table_name='cz_item_property_values') THEN
     CZ_IMP_IM_MAIN.MAIN_ITEM_PROPERTY_VALUE(inRun_ID, commit_size, max_err,
                                          Inserts, Updates, x_failed, Dups, inXFR_GROUP);
  ELSIF(lower_table_name='cz_item_types') THEN
     CZ_IMP_IM_MAIN.MAIN_ITEM_TYPE(inRun_ID, commit_size, max_err,
                                Inserts, Updates, x_failed, Dups, inXFR_GROUP);
  ELSIF(lower_table_name='cz_item_type_properties') THEN
     CZ_IMP_IM_MAIN.MAIN_ITEM_TYPE_PROPERTY(inRun_ID, commit_size, max_err,
                                         Inserts, Updates, x_failed, Dups, inXFR_GROUP);
  ELSIF(lower_table_name='cz_properties') THEN
     CZ_IMP_IM_MAIN.MAIN_PROPERTY(inRun_ID, commit_size, max_err,
                               Inserts, Updates, x_failed, Dups, inXFR_GROUP, p_rp_folder_id);
  ELSIF(lower_table_name='cz_user_groups') THEN
     CZ_IMP_AC_MAIN.MAIN_USER_GROUP(inRun_ID, commit_size, max_err,
                                 Inserts, Updates, x_failed, Dups, inXFR_GROUP);
  ELSE
     --DBMS_OUTPUT.PUT_LINE(CZ_UTILS.GET_TEXT('CZ_IMP_INVALID_TABLE_IMPORT','TABLENAME',table_name));
     xERROR:=cz_utils.log_report(CZ_UTILS.GET_TEXT('CZ_IMP_INVALID_TABLE_IMPORT','TABLENAME',table_name),1,'CZ_IMP_ALL.POPULATE_TABLE',11276,inRun_ID);
  END IF;
  --DBMS_OUTPUT.PUT_LINE('INSERTS:    '||to_char(Inserts));
  --DBMS_OUTPUT.PUT_LINE('UPDATES:    '||to_char(Updates));
  --DBMS_OUTPUT.PUT_LINE('FAILED:     '||to_char(x_failed));
  --DBMS_OUTPUT.PUT_LINE('DUPLICATES: '||to_char(Dups));
EXCEPTION
  WHEN CZ_ADMIN.IMP_UNEXP_SQL_ERROR THEN
    RAISE;
 WHEN OTHERS THEN
    d_str:=CZ_UTILS.GET_TEXT('CZ_IMP_OPERATION_FAILED', 'ERRORTEXT', SQLERRM);
    xERROR:=cz_utils.log_report(d_str,1,'CZ_IMP_ALL.POPULATE_TABLE',11276,inRun_ID);
    RAISE CZ_ADMIN.IMP_UNEXP_SQL_ERROR;
END populate_table;
------------------------------------------------------------------------------------------
PROCEDURE import_before_start IS
  CURSOR C_GET_ID(nPriceGroupID number) IS
    SELECT substr(ORIG_SYS_REF,1,instr(ORIG_SYS_REF,'.')-1)
    FROM CZ_PRICE_GROUPS
    WHERE to_number(substr(ORIG_SYS_REF,instr(ORIG_SYS_REF,'.')+1))=nPriceGroupID
    AND instr(ORIG_SYS_REF,'.')<>0;
  CURSOR C_SET_ID IS
    SELECT PRICE_GROUP_ID FROM CZ_PRICE_GROUPS
    WHERE ORIG_SYS_REF IS NULL FOR UPDATE;

  nPriceGroupID  CZ_PRICE_GROUPS.PRICE_GROUP_ID%TYPE;
  sOrigSysRef    CZ_PRICE_GROUPS.ORIG_SYS_REF%TYPE;
  bIdFound       BOOLEAN := FALSE;
  xERROR         BOOLEAN := FALSE;

BEGIN
 OPEN C_SET_ID;
  LOOP
    FETCH C_SET_ID INTO nPriceGroupID;
    EXIT WHEN C_SET_ID%NOTFOUND;

    OPEN C_GET_ID(nPriceGroupID);
    FETCH C_GET_ID INTO sOrigSysRef;
    bIdFound := C_GET_ID%FOUND;
    CLOSE C_GET_ID;

    IF(bIdFound) THEN
      BEGIN
        UPDATE CZ_PRICE_GROUPS SET ORIG_SYS_REF=sOrigSysRef WHERE CURRENT OF C_SET_ID;
      EXCEPTION
        WHEN OTHERS THEN
          xERROR:=cz_utils.log_report(SQLERRM,1,'CZ_IMP_ALL.IMPORT_BEFORE_START',11276);
      END;
    END IF;

  END LOOP;
 CLOSE C_SET_ID;
 COMMIT;
END import_before_start;
------------------------------------------------------------------------------------------
PROCEDURE import_after_complete(inRUN_ID IN PLS_INTEGER) IS
  CURSOR C_GET_RELATED(sOrigSysRef CZ_PRICE_GROUPS.ORIG_SYS_REF%TYPE) IS
    SELECT PRICE_GROUP_ID FROM CZ_PRICE_GROUPS
    WHERE instr(ORIG_SYS_REF,'.')<>0 AND
          substr(ORIG_SYS_REF,1,instr(ORIG_SYS_REF,'.')-1)=sOrigSysRef;
  CURSOR C_GET_HOST IS
    SELECT * FROM CZ_PRICE_GROUPS
    WHERE ORIG_SYS_REF IS NOT NULL AND instr(ORIG_SYS_REF,'.')=0
    FOR UPDATE;
  P_GET_HOST  C_GET_HOST%ROWTYPE;

  nPriceGroupID    CZ_PRICE_GROUPS.PRICE_GROUP_ID%TYPE;
  bRelatedFound    BOOLEAN := FALSE;
  xERROR           BOOLEAN := FALSE;
  nAllocateBlock   PLS_INTEGER:=1;
  nAllocateCounter PLS_INTEGER;
  nNextValue       NUMBER;

  v_settings_id      VARCHAR2(40);
  v_section_name     VARCHAR2(30);

BEGIN

declare

  cursor c_listcontrol is
    select price_list_id from cz_xfr_price_lists
    where deleted_flag='0';
   cursor c_pricegroup(nPriceListId number) is
     select desc_text from cz_price_groups
     where orig_sys_ref=to_char(nPriceListId)
     and deleted_flag='0';

   nPriceListId   cz_xfr_price_lists.price_list_id%type;
   sDescription   cz_price_groups.desc_text%type;
   sDisabled      cz_xfr_tables.disabled%type;
   xERROR         BOOLEAN := FALSE;

begin

   begin
    select disabled into sDisabled
    from cz_xfr_tables where dst_table='CZ_PRICE_GROUPS' and xfr_group='IMPORT';
   exception
     when others then
       sDisabled:='1';
   end;

   if(sDisabled='0')then
   open c_listcontrol;
   loop

     fetch c_listcontrol into nPriceListId;
     exit when c_listcontrol%notfound;

     open c_pricegroup(nPriceListId);
     fetch c_pricegroup into sDescription;
       begin
         if(c_pricegroup%found)then
          update cz_xfr_price_lists set
           description=sDescription,
           last_import_run_id=inRUN_ID,
           last_import_date=sysdate
          where
           price_list_id=nPriceListId;
         else
          update cz_xfr_price_lists set
           source_price_deleted='1'
          where
           price_list_id=nPriceListId;
         end if;
       exception
         when others then
           xERROR:=cz_utils.log_report(SQLERRM,1,'CZ_IMP_ALL.IMPORT_AFTER_COMPLETE',11276,inRUN_ID);
       end;
     close c_pricegroup;
   end loop;
   close c_listcontrol;
   commit;
   end if;
end;

 OPEN C_GET_HOST;

 v_settings_id := 'OracleSequenceIncr';
 v_section_name := 'SCHEMA';

 BEGIN
   SELECT VALUE INTO nAllocateBlock FROM CZ_DB_SETTINGS
   WHERE SETTING_ID=v_settings_id AND SECTION_NAME=v_section_name;
 EXCEPTION
   WHEN OTHERS THEN
     nAllocateBlock:=1;
 END;
 nAllocateCounter:=nAllocateBlock-1;

  LOOP
    FETCH C_GET_HOST INTO P_GET_HOST;
    EXIT WHEN C_GET_HOST%NOTFOUND;

    OPEN C_GET_RELATED(P_GET_HOST.ORIG_SYS_REF);
    FETCH C_GET_RELATED INTO nPriceGroupID;
    bRelatedFound := C_GET_RELATED%FOUND;
    CLOSE C_GET_RELATED;

    IF(bRelatedFound)THEN
      BEGIN
        UPDATE CZ_PRICE_GROUPS SET
          DESC_TEXT=P_GET_HOST.DESC_TEXT,
          CURRENCY=P_GET_HOST.CURRENCY,
          NAME=P_GET_HOST.NAME,
          USER_NUM01=P_GET_HOST.USER_NUM01,
          USER_NUM02=P_GET_HOST.USER_NUM02,
          USER_NUM03=P_GET_HOST.USER_NUM03,
          USER_NUM04=P_GET_HOST.USER_NUM04,
          USER_STR01=P_GET_HOST.USER_STR01,
          USER_STR02=P_GET_HOST.USER_STR02,
          USER_STR03=P_GET_HOST.USER_STR03,
          USER_STR04=P_GET_HOST.USER_STR04,
          CREATION_DATE=P_GET_HOST.CREATION_DATE,
          LAST_UPDATE_DATE=P_GET_HOST.LAST_UPDATE_DATE,
          DELETED_FLAG=P_GET_HOST.DELETED_FLAG,
          CREATED_BY=P_GET_HOST.CREATED_BY,
          LAST_UPDATED_BY=P_GET_HOST.LAST_UPDATED_BY,
          SECURITY_MASK=P_GET_HOST.SECURITY_MASK,
          CHECKOUT_USER=P_GET_HOST.CHECKOUT_USER
       WHERE PRICE_GROUP_ID=nPriceGroupID;
       UPDATE CZ_PRICE_GROUPS SET ORIG_SYS_REF=NULL
       WHERE CURRENT OF C_GET_HOST;
      EXCEPTION
        WHEN OTHERS THEN
          xERROR:=cz_utils.log_report(SQLERRM,1,'CZ_IMP_ALL.IMPORT_AFTER_COMPLETE',11276,inRUN_ID);
      END;
    ELSE
      BEGIN
        nAllocateCounter:=nAllocateCounter+1;
        IF(nAllocateCounter=nAllocateBlock)THEN
          nAllocateCounter:=0;
          SELECT CZ_PRICE_GROUPS_S.NEXTVAL INTO nNextValue FROM DUAL;
        END IF;
        INSERT INTO CZ_PRICE_GROUPS
          (PRICE_GROUP_ID,DESC_TEXT,CURRENCY,ORIG_SYS_REF,
           NAME,USER_NUM01,USER_NUM02,USER_NUM03,USER_NUM04,
           USER_STR01,USER_STR02,USER_STR03,USER_STR04,DELETED_FLAG,
           SECURITY_MASK,CHECKOUT_USER,
           CREATION_DATE,LAST_UPDATE_DATE,CREATED_BY,LAST_UPDATED_BY)
        VALUES
          (nNextValue+nAllocateCounter,P_GET_HOST.DESC_TEXT,P_GET_HOST.CURRENCY,
           P_GET_HOST.ORIG_SYS_REF||'.'||P_GET_HOST.PRICE_GROUP_ID,P_GET_HOST.NAME,
           P_GET_HOST.USER_NUM01,P_GET_HOST.USER_NUM02,
           P_GET_HOST.USER_NUM03,P_GET_HOST.USER_NUM04,
           P_GET_HOST.USER_STR01,P_GET_HOST.USER_STR02,
           P_GET_HOST.USER_STR03,P_GET_HOST.USER_STR04,P_GET_HOST.DELETED_FLAG,
           P_GET_HOST.SECURITY_MASK,
           P_GET_HOST.CHECKOUT_USER,
           SYSDATE,SYSDATE,1,1);
        UPDATE CZ_PRICE_GROUPS SET ORIG_SYS_REF=NULL
        WHERE CURRENT OF C_GET_HOST;
      EXCEPTION
        WHEN OTHERS THEN
          xERROR:=cz_utils.log_report(SQLERRM,1,'CZ_IMP_ALL.IMPORT_AFTER_COMPLETE',11276,inRUN_ID);
      END;
    END IF;

  END LOOP;
 CLOSE C_GET_HOST;
 COMMIT;

END import_after_complete;
------------------------------------------------------------------------------------------
PROCEDURE goSingleBill(nOrg_ID IN NUMBER,nTop_ID IN NUMBER,
                       COPY_CHILD_MODELS IN VARCHAR2,
                       REFRESH_MODEL_ID  IN NUMBER,
  				       COPY_ROOT_MODEL   IN VARCHAR2,
                       x_run_id OUT NOCOPY NUMBER) IS -- sselahi: added x_run_id
   xERROR  		BOOLEAN:=FALSE;
   imp_st  		number;
   imp_end 		number;
   d_str   		varchar2(255);
   nLogTime  	BOOLEAN := FALSE;
   nEnableTrace  	BOOLEAN := FALSE;
BEGIN

   nLogTime := isTimingLogEnabled;
   nEnableTrace := isTracingEnabled;

   if (nLogTime) then
	get_time := TRUE;
   end if;

   if (get_time) then
	imp_st := dbms_utility.get_time();
   end if;

  CZ_IMP_SINGLE.ImportSingleBill(nOrg_ID,nTop_ID,COPY_CHILD_MODELS,REFRESH_MODEL_ID,'0', 'OPTIONAL', sysdate, x_run_id); -- sselahi:added x_run_id
   if (get_time) then
 	imp_end := dbms_utility.get_time();
	d_str := 'Import (' || nTop_Id || ') :' || (imp_end-imp_st)/100.00;
        xERROR:=cz_utils.log_report(d_str,1,'IMPORT',11299,NULL);
   end if;
EXCEPTION
  WHEN CZ_ADMIN.IMP_UNEXP_SQL_ERROR THEN
    RAISE;
  WHEN OTHERS THEN
    d_str:=CZ_UTILS.GET_TEXT('CZ_IMP_OPERATION_FAILED','ERRORTEXT',SQLERRM);
    xERROR:=cz_utils.log_report(d_str,1,'CZ_IMP_ALL.goSingleBill',11276,NULL);
    RAISE;
END goSingleBill;
------------------------------------------------------------------------------------------
PROCEDURE AddBillToImport(errbuf OUT NOCOPY VARCHAR2,retcode OUT NOCOPY NUMBER,nOrg_ID IN NUMBER,nTop_ID IN NUMBER,
                          COPY_CHILD_MODELS IN VARCHAR2) IS
 xERROR     BOOLEAN:=FALSE;
 server_id  cz_servers.server_local_id%TYPE;
 v_enabled  VARCHAR2(1) := '1';

BEGIN
 retcode:=0;
 errbuf:='';

 BEGIN
  SELECT server_local_id INTO server_id
    FROM cz_servers
   WHERE import_enabled = v_enabled;
 EXCEPTION
   WHEN TOO_MANY_ROWS THEN
     retcode:=2;
     errbuf:=CZ_UTILS.GET_TEXT('CZ_IMP_TOO_MANY_SERVERS');
     xERROR:=cz_utils.log_report(errbuf,1,'CZ_IMP_ALL.ADDBILLTOIMPORT',11276,NULL);
     RAISE;
   WHEN NO_DATA_FOUND THEN
     retcode:=2;
     errbuf:=CZ_UTILS.GET_TEXT('CZ_IMP_NO_SERVERS');
     xERROR:=cz_utils.log_report(errbuf,1,'CZ_IMP_ALL.ADDBILLTOIMPORT',11276,NULL);
     RAISE;
 END;

 insert into cz_xfr_project_bills (top_item_id,organization_id,deleted_flag,explosion_type,model_ps_node_id,
     copy_addl_child_models,source_server)
 select nTop_ID,nOrg_ID,'0','OPTIONAL',cz_xfr_project_bills_s.NEXTVAL,COPY_CHILD_MODELS,server_id
    from dual where not exists
 (select 1 from cz_xfr_project_bills where organization_id=nOrg_ID and
  top_item_id=nTop_ID and explosion_type='OPTIONAL' and source_server = server_id);
 update cz_xfr_project_bills set deleted_flag='0',copy_addl_child_models = COPY_CHILD_MODELS
  where organization_id=nOrg_ID and
  top_item_id=nTop_ID and explosion_type='OPTIONAL' and source_server = server_id;
 COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    retcode:=2;
    errbuf:=CZ_UTILS.GET_TEXT('CZ_IMP_OPERATION_FAILED','ERRORTEXT',SQLERRM);
    xERROR:=cz_utils.log_report(errbuf,1,'CZ_IMP_ALL.ADDBILLTOIMPORT',11276,NULL);
    RAISE;
END;
------------------------------------------------------------------------------------------
PROCEDURE SetSingleBillState(errbuf OUT NOCOPY VARCHAR2,retcode OUT NOCOPY NUMBER,nOrg_ID IN NUMBER,nTop_ID IN NUMBER,sState IN VARCHAR2) IS
 xERROR     BOOLEAN:=FALSE;
 server_id  cz_servers.server_local_id%TYPE;
 v_enabled  VARCHAR2(1) := '1';

BEGIN
 retcode:=0;
 errbuf:='';

 BEGIN
  SELECT server_local_id INTO server_id
    FROM cz_servers
   WHERE import_enabled = v_enabled;
 EXCEPTION
   WHEN TOO_MANY_ROWS THEN
     retcode:=2;
     errbuf:=CZ_UTILS.GET_TEXT('CZ_IMP_TOO_MANY_SERVERS');
     xERROR:=cz_utils.log_report(errbuf,1,'CZ_IMP_ALL.SETSINGLEBILLSTATE',11276,NULL);
     RAISE;
   WHEN NO_DATA_FOUND THEN
     retcode:=2;
     errbuf:=CZ_UTILS.GET_TEXT('CZ_IMP_NO_SERVERS');
     xERROR:=cz_utils.log_report(errbuf,1,'CZ_IMP_ALL.SETSINGLEBILLSTATE',11276,NULL);
     RAISE;
 END;

 update cz_xfr_project_bills set
  deleted_flag=DECODE(UPPER(sState),'0','1','OFF','1','NO','1','DISABLE','1',
   '1','0','ON','0','YES','0','ENABLE','0',DELETED_FLAG)
 where organization_id=nOrg_ID and top_item_id=nTop_ID and explosion_type='OPTIONAL' AND
   source_server = server_id;
 COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    retcode:=2;
    errbuf:=CZ_UTILS.GET_TEXT('CZ_IMP_OPERATION_FAILED','ERRORTEXT',SQLERRM);
    xERROR:=cz_utils.log_report(errbuf,1,'CZ_IMP_ALL.SETSINGLEBILLSTATE',11276,NULL);
END;
------------------------------------------------------------------------------------------
PROCEDURE RemoveModel(errbuf OUT NOCOPY VARCHAR2,retcode OUT NOCOPY NUMBER,sOrg_ID IN VARCHAR2,
                      dsOrg_ID IN VARCHAR2,sTop_ID IN VARCHAR2) IS

 xERROR    BOOLEAN:=FALSE;
 nTop_ID   CZ_XFR_PROJECT_BILLS.TOP_ITEM_ID%TYPE;
 nOrg_ID   CZ_XFR_PROJECT_BILLS.ORGANIZATION_ID%TYPE;
 server_id cz_servers.server_local_id%TYPE;
 v_enabled VARCHAR2(1) := '1';

BEGIN
 retcode:=0;
 errbuf:='';

 BEGIN
  SELECT server_local_id INTO server_id
    FROM cz_servers
   WHERE import_enabled = v_enabled;
 EXCEPTION
   WHEN TOO_MANY_ROWS THEN
     retcode:=2;
     errbuf:=CZ_UTILS.GET_TEXT('CZ_IMP_TOO_MANY_SERVERS');
     xERROR:=cz_utils.log_report(errbuf,1,'CZ_IMP_ALL.RemoveModel',11276,NULL);
     RAISE;
   WHEN NO_DATA_FOUND THEN
     retcode:=2;
     errbuf:=CZ_UTILS.GET_TEXT('CZ_IMP_NO_SERVERS');
     xERROR:=cz_utils.log_report(errbuf,1,'CZ_IMP_ALL.RemoveModel',11276,NULL);
     RAISE;
 END;

 SELECT ORGANIZATION_ID INTO nOrg_ID FROM CZ_EXV_ORGANIZATIONS
 WHERE ORGANIZATION_CODE = sOrg_ID;

 SELECT inventory_item_id INTO nTop_ID
 FROM cz_exv_mtl_system_items
 WHERE bom_item_type = 1
   AND organization_id = nOrg_ID
   AND concatenated_segments = sTop_ID
   AND rownum = 1;

 update cz_xfr_project_bills set
  deleted_flag='1'
 where organization_id=nOrg_ID and top_item_id=nTop_ID
   and source_server = server_id;

 COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    retcode:=2;
    errbuf:=CZ_UTILS.GET_TEXT('CZ_IMP_OPERATION_FAILED','ERRORTEXT',SQLERRM);
    xERROR:=cz_utils.log_report(errbuf,1,'CZ_IMP_ALL.RemoveModel',11276,NULL);
END;
------------------------------------------------------------------------------------------
PROCEDURE PopulateModels_cp(errbuf OUT NOCOPY VARCHAR2,retcode OUT NOCOPY NUMBER,
                         sOrg_ID IN VARCHAR2,dsOrg_ID IN VARCHAR2,
                         sFrom IN VARCHAR2,sTo IN VARCHAR,
                         COPY_CHILD_MODELS IN VARCHAR2 DEFAULT '0') IS
 CURSOR C_GETMODELS(Org_ID NUMBER) IS
   SELECT A.ASSEMBLY_ITEM_ID FROM CZ_EXV_BILL_OF_MATERIALS A,CZ_EXV_MTL_SYSTEM_ITEMS B
   WHERE A.ASSEMBLY_ITEM_ID=B.INVENTORY_ITEM_ID
	AND A.ORGANIZATION_ID=B.ORGANIZATION_ID
	AND B.BOM_ITEM_TYPE=1
	AND A.ORGANIZATION_ID=Org_ID
	AND B.CONCATENATED_SEGMENTS BETWEEN sFrom AND NVL(sTo,sFrom);

 xERROR    BOOLEAN:=FALSE;
 nTop_ID   CZ_XFR_PROJECT_BILLS.TOP_ITEM_ID%TYPE;
 nOrg_ID   CZ_XFR_PROJECT_BILLS.ORGANIZATION_ID%TYPE;
 v_copy_child_models CHAR(1);
 l_run_id  NUMBER; -- sselahi: added to pass to call goSingleBill
BEGIN

 CZ_ORAAPPS_INTEGRATE.mERRBUF := '';
 CZ_ORAAPPS_INTEGRATE.mRETCODE := 0;

 SELECT DECODE(COPY_CHILD_MODELS,'Y','0','N','1','YES','0','NO','1','TRUE','0','FALSE','1','T','0','F','1','1','1','0') into v_copy_child_models from dual;

 SELECT ORGANIZATION_ID INTO nOrg_ID FROM CZ_EXV_ORGANIZATIONS
 WHERE ORGANIZATION_CODE = sOrg_ID;

 OPEN C_GETMODELS(nOrg_ID);
 LOOP
  FETCH C_GETMODELS INTO nTop_ID;
  EXIT WHEN C_GETMODELS%NOTFOUND;

  /* Log a message if the bill being imported (not refreshed) refers to a common bill */
  check_for_common_bill(errbuf,retcode,nORG_ID,nTOP_ID);
  goSingleBill(nOrg_ID,nTop_ID,v_COPY_CHILD_MODELS,-1, '0',l_run_id); -- sselahi: added l_run_id

  IF(CZ_ORAAPPS_INTEGRATE.mRETCODE = 2)THEN
    errbuf := CZ_ORAAPPS_INTEGRATE.mERRBUF;
    retcode := CZ_ORAAPPS_INTEGRATE.mRETCODE;
    RETURN;
  END IF;

 END LOOP;
 CLOSE C_GETMODELS;
 COMMIT;

 errbuf := CZ_ORAAPPS_INTEGRATE.mERRBUF;
 retcode := CZ_ORAAPPS_INTEGRATE.mRETCODE;

EXCEPTION
  WHEN CZ_ADMIN.IMP_UNEXP_SQL_ERROR THEN
    RAISE;
  WHEN CZ_ADMIN.IMP_ACTIVE_SESSION_EXISTS THEN
    retcode:=2;
    errbuf:=CZ_UTILS.GET_TEXT('CZ_IMP_ACTIVE_SESSION_EXISTS');
    xERROR:=cz_utils.log_report(errbuf,1,'CZ_IMP_ALL.PopulateModels_cp',11276,NULL);
    RAISE;
  WHEN CZ_ADMIN.IMP_MAXERR_REACHED THEN
    retcode:=2;
    errbuf:=CZ_UTILS.GET_TEXT('CZ_IMP_MAXERR_REACHED');
    xERROR:=cz_utils.log_report(errbuf,1,'CZ_IMP_ALL.PopulateModels_cp',11276,NULL);
    RAISE;
  WHEN OTHERS THEN
    retcode:=2;
    errbuf:=CZ_UTILS.GET_TEXT('CZ_IMP_OPERATION_FAILED','ERRORTEXT',SQLERRM);
    xERROR:=cz_utils.log_report(errbuf,1,'CZ_IMP_ALL.PopulateModels_cp',11276,NULL);
    RAISE;
END;
------------------------------------------------------------------------------------------
PROCEDURE RefreshModels(errbuf OUT NOCOPY VARCHAR2,retcode OUT NOCOPY NUMBER) IS
BEGIN
  CZ_ORAAPPS_INTEGRATE.go_cp(errbuf, retcode);
END;
------------------------------------------------------------------------------------------
PROCEDURE setRunID(inRun_ID IN PLS_INTEGER,table_name IN VARCHAR2) IS
  DC_CURSOR         INTEGER;
  RESULT            INTEGER;
BEGIN
  DC_CURSOR:=DBMS_SQL.OPEN_CURSOR;
  DBMS_SQL.PARSE(DC_CURSOR,'UPDATE '||table_name||' SET RUN_ID='||inRun_ID||
                 ',REC_STATUS=NULL,DISPOSITION=NULL WHERE RUN_ID IS NULL',DBMS_SQL.NATIVE);
  RESULT:=DBMS_SQL.EXECUTE(DC_CURSOR);
  DBMS_SQL.CLOSE_CURSOR(DC_CURSOR);
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_SQL.CLOSE_CURSOR(DC_CURSOR);
END;
------------------------------------------------------------------------------------------
PROCEDURE setRecStatus(inRun_ID IN PLS_INTEGER,table_name IN VARCHAR2) IS
  DC_CURSOR         INTEGER;
  RESULT            INTEGER;
BEGIN
  DC_CURSOR:=DBMS_SQL.OPEN_CURSOR;
  DBMS_SQL.PARSE(DC_CURSOR,'UPDATE '||table_name||
                 ' SET REC_STATUS=NULL,DISPOSITION=NULL WHERE RUN_ID='||inRun_ID,DBMS_SQL.NATIVE);
  RESULT:=DBMS_SQL.EXECUTE(DC_CURSOR);
  DBMS_SQL.CLOSE_CURSOR(DC_CURSOR);
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_SQL.CLOSE_CURSOR(DC_CURSOR);
END;
------------------------------------------------------------------------------------------

PROCEDURE check_for_common_bill
(errbuf             OUT NOCOPY VARCHAR2,
 retcode            OUT NOCOPY NUMBER,
 nORG_ID 		  IN NUMBER,
 nTOP_ID 		  IN NUMBER)
IS
 commonInvId  CZ_XFR_PROJECT_BILLS.TOP_ITEM_ID%TYPE;
 commonOrgId  CZ_XFR_PROJECT_BILLS.ORGANIZATION_ID%TYPE;
 xERROR       BOOLEAN:=FALSE;
BEGIN
  	errbuf:='';
  	retcode:=0;

  	/* Log a message if the bill being imported (not refreshed) refers to a common bill */
	SELECT ORGANIZATION_ID, ASSEMBLY_ITEM_ID
	INTO commonOrgId, commonInvId
	FROM CZ_EXV_BILL_OF_MATERIALS
	WHERE BILL_SEQUENCE_ID in
				(SELECT COMMON_BILL_SEQUENCE_ID FROM CZ_EXV_BILL_OF_MATERIALS
							WHERE ORGANIZATION_ID = nOrg_ID
	   						AND ASSEMBLY_ITEM_ID = nTop_ID);
	IF ((commonOrgId <> nOrg_ID) or (commonInvId <> nTop_ID)) THEN
          retcode := 1;
          errbuf := CZ_UTILS.get_text('CZ_HAS_COMMON_BILL','ORGID',nOrg_ID,'INVID',nTop_ID,'C_ORGID',commonOrgId,'C_INVID',commonInvId);
          xERROR:=cz_utils.log_report(errbuf,1,'CZ_IMP_ALL:CZ_COMMON_BILL_CHECK',11276,NULL);
	END IF;
  EXCEPTION
	WHEN NO_DATA_FOUND THEN
		retcode := 2;
		errbuf := CZ_UTILS.get_text('CZ_IMP_BOM_NO_DATA');
		xERROR:=cz_utils.log_report(errbuf,1,'CZ_IMP_ALL:CZ_COMMON_BILL_CHECK',11276,NULL);
	WHEN OTHERS THEN
		retcode := 2;
		errbuf := 'CZ_IMP_ALL:COMMON_BILL_CHECK' || SQLERRM;
		xERROR:=cz_utils.log_report(errbuf,1,'CZ_IMP_ALL:COMMON_BILL_CHECK',11276,NULL);
                RAISE;
  END check_for_common_bill;

------------------------------------------------------------------------------------------
FUNCTION REPORT (Msg in VARCHAR2, Urgency in NUMBER, ByCaller in VARCHAR2,
                 StatusCode in NUMBER) 	RETURN BOOLEAN IS
  xError Boolean;
  l_msg VARCHAR2(2000);
BEGIN
  -- log msg to both fnd and cz tables
  xError := cz_utils.log_report(Msg, urgency, ByCaller, StatusCode);
  IF (xError) THEN
    commit;
  ELSE
    rollback;
  END IF;

  RETURN xError;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RETURN FALSE;
END REPORT;
------------------------------------------------------------------------------------------
PROCEDURE go_generic_cp(errbuf OUT NOCOPY VARCHAR2,
                        retcode OUT NOCOPY NUMBER,
                        inRun_iD IN PLS_INTEGER,
                        p_rp_folder_id IN NUMBER) IS

 outRun_id     PLS_INTEGER;
 xERROR        BOOLEAN:=FALSE;
 l_success_msg VARCHAR2(255);

BEGIN
  go_generic(outRun_ID,inRun_ID, p_rp_folder_id);
  l_success_msg:=CZ_UTILS.get_text('CZ_IMP_GENIMP_SUCCESS_RUNID', 'OUT_RUN_ID', outRun_ID);
EXCEPTION
  WHEN OTHERS THEN
    retcode:=2;
    errbuf:=CZ_UTILS.GET_TEXT('CZ_IMP_OPERATION_FAILED','ERRORTEXT',SQLERRM);
    xERROR:=cz_utils.log_report(errbuf,1,'CZ_IMP_ALL.generic_import',11276,NULL);
END go_generic_cp;
------------------------------------------------------------------------------------------
END CZ_IMP_ALL;

/
