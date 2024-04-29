--------------------------------------------------------
--  DDL for Package Body CZ_ADMIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CZ_ADMIN" as
/*	$Header: czcadmnb.pls 115.18 2003/10/31 19:49:48 qmao ship $	  */
PROCEDURE VALIDATE_END_USERS IS
   CURSOR C_GET_USER IS
    SELECT LOGIN_NAME FROM CZ_END_USERS;
   sLogin_name   CZ_END_USERS.LOGIN_NAME%TYPE;

BEGIN
   OPEN C_GET_USER;

   LOOP
    FETCH C_GET_USER INTO sLogin_name;
    EXIT WHEN C_GET_USER%NOTFOUND;
    IF(sLogin_name IS NULL)THEN
      -- xERROR:=CZ_UTILS.REPORT(CZ_UTILS.GET_TEXT('CZ_IMP_INVALID_LOGIN_NAME'),1,'CZ_ADMIN.VALIDATE_END_USER',11276);
      cz_utils.log_report('CZ_ADMIN', 'VALIDATE_END_USERS', null,
                        CZ_UTILS.GET_TEXT('CZ_IMP_INVALID_LOGIN_NAME'),
                        fnd_log.LEVEL_ERROR);
    END IF;
   END LOOP;
   CLOSE C_GET_USER;

EXCEPTION
  WHEN OTHERS THEN
    CLOSE C_GET_USER;
    -- xERROR:=CZ_UTILS.REPORT(SQLERRM,1,'CZ_ADMIN.VALIDATE_END_USER',11276);
    cz_utils.log_report('CZ_ADMIN', 'VALIDATE_END_USERS', null,
                        SQLERRM, fnd_log.LEVEL_UNEXPECTED);
END VALIDATE_END_USERS;
------------------------------------------------------------------------------------------
PROCEDURE ENABLE_END_USERS IS
   CURSOR C_CHECK_USER(sUser_name VARCHAR2) IS
    SELECT USER_ID FROM ALL_USERS WHERE USERNAME=sUser_name;
   CURSOR C_GET_USER IS
    SELECT UPPER(LOGIN_NAME) FROM CZ_END_USERS;
   CURSOR C_GET_ROLE IS
    SELECT VALUE FROM CZ_DB_SETTINGS
    WHERE SECTION_NAME='DB_USER_ROLES' AND SETTING_ID='0';
   CURSOR C_GET_DEFAULT IS
    SELECT VALUE FROM CZ_DB_SETTINGS
    WHERE SECTION_NAME='SCHEMA' AND SETTING_ID='SpxDefaultTablespace';
   CURSOR C_GET_TEMPORY IS
    SELECT VALUE FROM CZ_DB_SETTINGS
    WHERE SECTION_NAME='SCHEMA' AND SETTING_ID='SpxTemporaryTablespace';
   DC_CURSOR     INTEGER;
   sLogin_name   CZ_END_USERS.LOGIN_NAME%TYPE;
   sDefault_role CZ_DB_SETTINGS.VALUE%TYPE := 'SPX_USER';
   sDefault_tspc CZ_DB_SETTINGS.VALUE%TYPE := NULL;
   sTempory_tspc CZ_DB_SETTINGS.VALUE%TYPE := NULL;
   sCommand      VARCHAR2(255);
   nUserID       NUMBER;
   RESULT        INTEGER;

BEGIN
   OPEN C_GET_ROLE;
   FETCH C_GET_ROLE INTO sDefault_role;
   CLOSE C_GET_ROLE;
   OPEN C_GET_DEFAULT;
   FETCH C_GET_DEFAULT INTO sDefault_tspc;
   CLOSE C_GET_DEFAULT;
   OPEN C_GET_TEMPORY;
   FETCH C_GET_TEMPORY INTO sTempory_tspc;
   CLOSE C_GET_TEMPORY;

   OPEN C_GET_USER;

   LOOP
    FETCH C_GET_USER INTO sLogin_name;
    EXIT WHEN C_GET_USER%NOTFOUND;

    IF(sLogin_name IS NULL)THEN
      -- xERROR:=CZ_UTILS.REPORT('Invalid login name',1,'CZ_ADMIN.ENABLE_END_USER',11276);
      cz_utils.log_report('CZ_ADMIN', 'ENABLE_END_USER', null,
                        'Invalid login name', fnd_log.LEVEL_ERROR);
    ELSE
       BEGIN

         DC_CURSOR:=DBMS_SQL.OPEN_CURSOR;
         sCommand:='CREATE USER '||sLogin_name||' IDENTIFIED BY '||sLogin_name;
         IF(sDefault_tspc IS NOT NULL)THEN
          sCommand:=sCommand||' DEFAULT TABLESPACE '||sDefault_tspc;
         END IF;
         IF(sTempory_tspc IS NOT NULL)THEN
          sCommand:=sCommand||' TEMPORARY TABLESPACE '||sTempory_tspc;
         END IF;
         DBMS_SQL.PARSE(DC_CURSOR,sCommand,DBMS_SQL.NATIVE);
         RESULT:=DBMS_SQL.EXECUTE(DC_CURSOR);
         DBMS_SQL.CLOSE_CURSOR(DC_CURSOR);

       EXCEPTION
         WHEN OTHERS THEN
           DBMS_SQL.CLOSE_CURSOR(DC_CURSOR);
           -- xERROR:=CZ_UTILS.REPORT(SQLERRM,1,'CZ_ADMIN.ENABLE_END_USER',11276);
           cz_utils.log_report('CZ_ADMIN', 'ENABLE_END_USER', null,
                        SQLERRM, fnd_log.LEVEL_UNEXPECTED);
       END;

       BEGIN

         DC_CURSOR:=DBMS_SQL.OPEN_CURSOR;
         DBMS_SQL.PARSE(DC_CURSOR,'GRANT "CONNECT" TO '||sLogin_name,DBMS_SQL.NATIVE);
         RESULT:=DBMS_SQL.EXECUTE(DC_CURSOR);
         DBMS_SQL.CLOSE_CURSOR(DC_CURSOR);

       EXCEPTION
         WHEN OTHERS THEN
           DBMS_SQL.CLOSE_CURSOR(DC_CURSOR);
           -- xERROR:=CZ_UTILS.REPORT(SQLERRM,1,'CZ_ADMIN.ENABLE_END_USER',11276);
           cz_utils.log_report('CZ_ADMIN', 'ENABLE_END_USER', null,
                        SQLERRM, fnd_log.LEVEL_UNEXPECTED);
       END;

       BEGIN

         DC_CURSOR:=DBMS_SQL.OPEN_CURSOR;
         DBMS_SQL.PARSE(DC_CURSOR,'GRANT '||sDefault_role||' TO '||sLogin_name,DBMS_SQL.NATIVE);
         RESULT:=DBMS_SQL.EXECUTE(DC_CURSOR);
         DBMS_SQL.CLOSE_CURSOR(DC_CURSOR);

       EXCEPTION
         WHEN OTHERS THEN
           DBMS_SQL.CLOSE_CURSOR(DC_CURSOR);
           -- xERROR:=CZ_UTILS.REPORT(SQLERRM,1,'CZ_ADMIN.ENABLE_END_USER',11276);
           cz_utils.log_report('CZ_ADMIN', 'ENABLE_END_USER', null,
                        SQLERRM, fnd_log.LEVEL_UNEXPECTED);
       END;

      nUserID:=NULL;
      OPEN C_CHECK_USER(sLogin_name);
      FETCH C_CHECK_USER INTO nUserID;
      CLOSE C_CHECK_USER;

      BEGIN
        UPDATE CZ_END_USERS SET DBMS_ID=nUserID WHERE UPPER(LOGIN_NAME)=sLogin_name;
      EXCEPTION
        WHEN OTHERS THEN
          -- xERROR:=CZ_UTILS.REPORT(SQLERRM,1,'CZ_ADMIN.ENABLE_END_USER',11276);
          cz_utils.log_report('CZ_ADMIN', 'ENABLE_END_USER', null,
                        SQLERRM, fnd_log.LEVEL_UNEXPECTED);
      END;
    END IF;
   END LOOP;
   CLOSE C_GET_USER;
   COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    CLOSE C_GET_USER;
    -- xERROR:=CZ_UTILS.REPORT(SQLERRM,1,'CZ_ADMIN.ENABLE_END_USER',11276);
    cz_utils.log_report('CZ_ADMIN', 'ENABLE_END_USER', null,
                        SQLERRM, fnd_log.LEVEL_UNEXPECTED);
END ENABLE_END_USERS;
------------------------------------------------------------------------------------------
PROCEDURE SPX_WAIT(nSeconds IN NUMBER DEFAULT 0) IS
BEGIN
  IF(nSeconds IS NOT NULL AND nSeconds > 0)THEN
    DBMS_LOCK.SLEEP(nSeconds);
  END IF;
END;
------------------------------------------------------------------------------------------
FUNCTION SPX_IMPORTSESSIONS RETURN INTEGER IS
  nRet  INTEGER;
BEGIN
  BEGIN
   SELECT 1 INTO nRet FROM V$SESSION WHERE MODULE='CZIMPORT';
  EXCEPTION
   WHEN NO_DATA_FOUND THEN
    nRet:=0;
  END;
 RETURN nRet;
END;
------------------------------------------------------------------------------------------
PROCEDURE SPX_SYNC_IMPORTSESSIONS IS
  nSeconds  NUMBER;
  nCounter  PLS_INTEGER;
BEGIN
  BEGIN
   SELECT NVL(to_number(VALUE),0) INTO nSeconds FROM CZ_DB_SETTINGS
   WHERE SETTING_ID='MULTISESSION' AND SECTION_NAME='IMPORT';
  EXCEPTION
    WHEN OTHERS THEN
      nSeconds:=0;
  END;
  IF(nSeconds < 0 OR SPX_IMPORTSESSIONS = 0)THEN RETURN; END IF;

  nCounter:=0;
  WHILE nCounter < nSeconds LOOP
   SPX_WAIT(1);
   IF(SPX_IMPORTSESSIONS = 0)THEN RETURN; END IF;
   nCounter:=nCounter+1;
  END LOOP;

  RAISE IMP_ACTIVE_SESSION_EXISTS;
END;
------------------------------------------------------------------------------------------
FUNCTION SPX_PUBLISHSESSIONS RETURN INTEGER IS
  nRet  INTEGER;
BEGIN
  BEGIN
   SELECT 1 INTO nRet FROM V$SESSION WHERE MODULE like 'CZ_SYNC%';
  EXCEPTION
   WHEN NO_DATA_FOUND THEN
    nRet:=0;
  END;
 RETURN nRet;
END;
------------------------------------------------------------------------------------------
PROCEDURE SPX_SYNC_PUBLISHSESSIONS IS
  nSeconds  NUMBER;
  nCounter  PLS_INTEGER;
BEGIN
  BEGIN
   SELECT NVL(to_number(VALUE),0) INTO nSeconds FROM CZ_DB_SETTINGS
   WHERE SETTING_ID='MULTISESSION' AND SECTION_NAME='CZPUBLISH';
  EXCEPTION
    WHEN OTHERS THEN
      nSeconds:=0;
  END;
  IF(nSeconds < 0 OR SPX_PUBLISHSESSIONS = 0)THEN RETURN; END IF;

  nCounter:=0;
  WHILE nCounter < nSeconds LOOP
   SPX_WAIT(1);
   IF(SPX_PUBLISHSESSIONS = 0)THEN RETURN; END IF;
   nCounter:=nCounter+1;
  END LOOP;

  RAISE IMP_ACTIVE_SESSION_EXISTS;
END;
------------------------------------------------------------------------------------------

END CZ_ADMIN;

/
