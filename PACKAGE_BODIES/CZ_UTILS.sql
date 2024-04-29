--------------------------------------------------------
--  DDL for Package Body CZ_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CZ_UTILS" AS
/*	$Header: czcutilb.pls 120.3 2006/01/20 02:14:02 amdixit ship $		*/

PROCEDURE get_App_Info(p_app_short_name IN VARCHAR2,
                       x_oracle_schema  OUT NOCOPY VARCHAR2) IS

  v_status            VARCHAR2(255);
  v_industry          VARCHAR2(255);
  v_ret               BOOLEAN;
BEGIN
  v_ret := FND_INSTALLATION.GET_APP_INFO(APPLICATION_SHORT_NAME => p_app_short_name,
                                         STATUS                 => v_status,
                                         INDUSTRY               => v_industry,
                                         ORACLE_SCHEMA          => x_oracle_schema);
END;

/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<o>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
FUNCTION REPORT (Msg in VARCHAR2, Urgency in NUMBER, ByCaller in VARCHAR2, StatusCode in NUMBER)
			RETURN BOOLEAN IS

		PRAGMA AUTONOMOUS_TRANSACTION;

		/* This calls a reporting function and runs it as an autonomous transation.
		   Autonomous transactions will not work in distributed environment */

		BEGIN
		   DECLARE
			x_check_log_report_f			BOOLEAN:=FALSE;
			BEGIN
				x_check_log_report_f := log_report(Msg, urgency, ByCaller, StatusCode);

				IF (x_check_log_report_f) THEN
					commit;
					RETURN TRUE;
				ELSE
					rollback;
					RETURN FALSE;
				END IF;
			END;
END REPORT;

/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<o>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
FUNCTION LOG_REPORT (Msg in VARCHAR2, Urgency in NUMBER, ByCaller in VARCHAR2, StatusCode in NUMBER)
			RETURN BOOLEAN IS
BEGIN
     RETURN LOG_REPORT(Msg,Urgency,ByCaller,StatusCode,NULL);
END;

/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<o>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
FUNCTION LOG_REPORT (Msg in VARCHAR2, Urgency in NUMBER, ByCaller in VARCHAR2, StatusCode in NUMBER, RunId in NUMBER)
			RETURN BOOLEAN IS
  v_oracle_schema VARCHAR2(255);
  l_msg VARCHAR2(2000);
BEGIN

  IF FND_GLOBAL.CONC_REQUEST_ID > 0 THEN
    l_msg:=SUBSTR(RunId||':'||ByCaller||'.'||StatusCode||':'||Msg,1,2000);
    FND_FILE.PUT_LINE(FND_FILE.LOG,l_msg);
  END IF;

  IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    fnd_log.string(fnd_log.LEVEL_ERROR, ByCaller || '.' || StatusCode, RunId||':'||Msg);
  END IF;

		/* Reporting function. This does not the commit the changes.
		   The calling function should commit or rollback the changes explicitly */

			DECLARE

			x_get_dbsettings_debug_f	BOOLEAN:=FALSE;
			x_get_dbsettings_report_f	BOOLEAN:=FALSE;
			p_error_flag			CHAR(1):='';
			sLogConst				CZ_DB_SETTINGS.SETTING_ID%TYPE;

			  CURSOR	get_dbsettings IS
					SELECT VALUE FROM CZ_DB_SETTINGS WHERE SETTING_ID = sLogConst;

			-- Make sure that the DataSet exists
			BEGIN

				/* If the nDebugLevel or nReportLevel are not set */
				/* Then read these values from the Dbase */
				IF( nDebugLevel IS NULL ) THEN
					/* Get the DBMS Output report level */
					sLogConst:='LOG_MINIMUMDEBUGLEVEL';
					OPEN get_dbsettings;
					FETCH get_dbsettings INTO nDebugLevel;
					x_get_dbsettings_debug_f := get_dbsettings%FOUND;
					CLOSE get_dbsettings;
				END IF;

				IF( nReportLevel IS NULL) THEN
					sLogConst:='LOG_MINIMUMREPORTLEVEL';
					OPEN get_dbsettings;
					FETCH get_dbsettings INTO nReportLevel;
					x_get_dbsettings_report_f := get_dbsettings%FOUND;
					CLOSE get_dbsettings;
				END IF;

				IF( (nDebugLevel IS NULL AND nReportLevel IS NULL ) OR
					 (URGENCY < nDebugLevel AND  URGENCY < nReportLevel )) THEN
					return TRUE;
				END IF;

                        get_App_Info('CZ',v_oracle_schema);

				/* Output To DB_LOG table if URGENCY is above the threshold */
				IF (nReportLevel IS NOT NULL AND URGENCY >= nReportLevel ) THEN
					BEGIN
						BEGIN
						INSERT INTO  CZ_DB_LOGS (LOGTIME, LOGUSER, URGENCY, CALLER, STATUSCODE, MESSAGE, RUN_ID)
								VALUES(SYSDATE, USER, URGENCY, ByCaller, StatusCode, Msg, RunId);
						EXCEPTION
							WHEN OTHERS THEN
								RETURN FALSE;
						END;
					END;
				END IF;

				/* Output To screen If URGENCY is above the threshold */
				IF (nDebugLevel IS NOT NULL AND URGENCY >= nDebugLevel  ) THEN
                              NULL;
					--dbms_output.put_line(TO_CHAR(SYSDATE,'MON-DD-YYYY')||
                              --' : User=('||USER||') '||'Urgency=('||URGENCY||') '||
                              --'Caller=('||ByCaller||') '||'StatusCode=('||TO_CHAR(StatusCode)||')');
				END IF;

			END;
			RETURN TRUE;
END LOG_REPORT;


FUNCTION TODATE (fromString in VARCHAR2) return DATE
is
	outdate date;
begin
 begin
	outdate := TO_DATE (fromstring, 'MM-DD-YYYY HH24:MI:SS');
	return outdate;
 exception
	when others THEN null;
 end;
 begin
	outdate := TO_DATE (fromstring, 'YYYY-MM-DD HH24:MI:SS');
	return outdate;
 exception
	when others THEN null;
 end;
 begin
	outdate := TO_DATE (fromstring, 'YYYY/MM/DD HH24:MI:SS');
	return outdate;
 exception
	when others then null;
 end;

 outdate := TO_DATE (fromstring, 'MM/DD/YYYY HH24:MI:SS');
 return outdate;
end TODATE;

FUNCTION GET_PK_USEEXPANSION_FLAG(TABLE_NAME IN VARCHAR2,
                                  inXFR_GROUP IN VARCHAR2)
RETURN NUMBER IS
BEGIN
 DECLARE
  PK_USEEXPANSION_FLAG  NUMBER;
 BEGIN
  SELECT DECODE(PK_USEEXPANSION,NULL,0,'0',0,1) INTO PK_USEEXPANSION_FLAG
  FROM CZ_XFR_TABLES WHERE DST_TABLE=TABLE_NAME AND XFR_GROUP=inXFR_GROUP
  AND ROWNUM=1;

  RETURN PK_USEEXPANSION_FLAG;
 EXCEPTION
   WHEN OTHERS THEN
     -- x_error:=CZ_UTILS.REPORT(SQLERRM,1,'CZ_UTILS.GET_PK_USEEXPANSION_FLAG',11276);
    log_report('cz_utils', 'GET_PK_USEEXPANSION_FLAG', 1, SQLERRM, fnd_log.LEVEL_UNEXPECTED);
     RETURN 0;
 END;
END GET_PK_USEEXPANSION_FLAG;

FUNCTION GET_NOUPDATE_FLAG(TABLE_NAME IN VARCHAR2,
                           COLUMN_NAME IN VARCHAR2,
                           inXFR_GROUP IN VARCHAR2)
RETURN NUMBER IS
BEGIN
 DECLARE
  NOUPDATE_FLAG  CZ_XFR_FIELDS.NOUPDATE%TYPE;
 BEGIN
  SELECT NOUPDATE INTO NOUPDATE_FLAG
  FROM CZ_XFR_FIELDS,CZ_XFR_TABLES
  WHERE CZ_XFR_TABLES.DST_TABLE=TABLE_NAME AND CZ_XFR_FIELDS.DST_FIELD=COLUMN_NAME
  AND CZ_XFR_TABLES.ORDER_SEQ=CZ_XFR_FIELDS.ORDER_SEQ
  AND CZ_XFR_TABLES.XFR_GROUP=CZ_XFR_FIELDS.XFR_GROUP
  AND CZ_XFR_FIELDS.XFR_GROUP=inXFR_GROUP AND ROWNUM=1;

  RETURN TO_NUMBER(NVL(NOUPDATE_FLAG,'0'));

  EXCEPTION
    WHEN OTHERS THEN
      -- x_error:=CZ_UTILS.REPORT(SQLERRM,0,'CZ_UTILS.GET_NOUPDATE_FLAG',11276);
      log_report('cz_utils', 'GET_NOUPDATE_FLAG', 1, SQLERRM, fnd_log.LEVEL_UNEXPECTED);
      RETURN 0;
  END;
END GET_NOUPDATE_FLAG;

/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<o>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
FUNCTION ISNUM(nVALUE IN VARCHAR2) RETURN BOOLEAN IS
BEGIN
	DECLARE xVALUE VARCHAR2(255);
	BEGIN
		SELECT TO_NUMBER(nVALUE) INTO xVALUE FROM DUAL;
		RETURN TRUE;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN FALSE;
	END;
END;
/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<o>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
PROCEDURE GET_USER_NAME (forSPXID IN NUMBER, outNAME OUT NOCOPY VARCHAR2) IS
  sUSER ALL_USERS.USERNAME%TYPE;
  sFND FND_USER.USER_NAME%TYPE;

BEGIN
	IF forSPXID<0 THEN
		SELECT DISTINCT USERNAME INTO sUSER
			FROM ALL_USERS
			WHERE USER_ID=-forSPXID;
		outNAME:=sUSER;
	ELSE
		SELECT USER_NAME INTO sFND
			FROM FND_USER
			WHERE USER_ID=forSPXID;
		outNAME:=sFND;
	END IF;
EXCEPTION
  WHEN OTHERS THEN
    -- X_ERROR:=CZ_UTILS.REPORT(SQLERRM,1,'CZ_UTILS.GET_USER_NAME',11276);
    log_report('cz_utils', 'GET_USER_NAME', 1, SQLERRM, fnd_log.LEVEL_UNEXPECTED);
END GET_USER_NAME;

/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<o>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
function conv_num(str varchar2)
return number is
begin
    return conv_num(str, '9999999999999999D99999999');
end conv_num;
/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<o>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
function conv_num(str varchar2, format varchar2)
return number is
begin
    return to_number(str, format);
exception
  when value_error then
  return null;
end conv_num;
/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<o>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/

FUNCTION SPX_UID RETURN INTEGER IS
RET INTEGER:=-2;
BEGIN
IF FND_GLOBAL.USER_ID<>-1 THEN
   RET:=FND_GLOBAL.USER_ID;
ELSE
   RET:=(-1*UID);
END IF;
RETURN RET;
EXCEPTION
WHEN OTHERS THEN
RETURN RET;
END;
/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<o>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
FUNCTION SPX_LOGIN_TYPE RETURN CHAR IS
RET CHAR(1):='*';
BEGIN
IF FND_GLOBAL.USER_ID<>-1 THEN
   RET:='A';
ELSE
   RET:='D';
END IF;
RETURN RET;
EXCEPTION
WHEN OTHERS THEN
RETURN RET;
END;

/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<o>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/

FUNCTION EPOCH_BEGIN RETURN DATE IS
BEGIN
RETURN EPOCH_BEGIN_;
END;
/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<o>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/

FUNCTION EPOCH_END RETURN DATE IS
BEGIN
RETURN EPOCH_END_;
END;
/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<o>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/

FUNCTION GET_TEXT(inMessageName IN VARCHAR2) RETURN VARCHAR2 IS
  v_String  VARCHAR2(2000);
BEGIN
  FND_MESSAGE.SET_NAME('CZ', inMessageName);
  v_String := FND_MESSAGE.GET;

  RETURN v_String;
END;

FUNCTION GET_TEXT(inMessageName IN VARCHAR2,
                  inToken1 IN VARCHAR2, inValue1 IN VARCHAR2) RETURN VARCHAR2 IS
  v_String  VARCHAR2(2000);
BEGIN
  FND_MESSAGE.SET_NAME('CZ', inMessageName);
  FND_MESSAGE.SET_TOKEN(inToken1, inValue1);
  v_String := FND_MESSAGE.GET;

  RETURN v_String;
END;

FUNCTION GET_TEXT(inMessageName IN VARCHAR2,
                  inToken1 IN VARCHAR2, inValue1 IN VARCHAR2,
                  inToken2 IN VARCHAR2, inValue2 IN VARCHAR2) RETURN VARCHAR2 IS
  v_String  VARCHAR2(2000);
BEGIN
  FND_MESSAGE.SET_NAME('CZ', inMessageName);
  FND_MESSAGE.SET_TOKEN(inToken1, inValue1);
  FND_MESSAGE.SET_TOKEN(inToken2, inValue2);
  v_String := FND_MESSAGE.GET;

  RETURN v_String;
END;

FUNCTION GET_TEXT(inMessageName IN VARCHAR2,
                  inToken1 IN VARCHAR2, inValue1 IN VARCHAR2,
                  inToken2 IN VARCHAR2, inValue2 IN VARCHAR2,
                  inToken3 IN VARCHAR2, inValue3 IN VARCHAR2) RETURN VARCHAR2 IS
  v_String  VARCHAR2(2000);
BEGIN
  FND_MESSAGE.SET_NAME('CZ', inMessageName);
  FND_MESSAGE.SET_TOKEN(inToken1, inValue1);
  FND_MESSAGE.SET_TOKEN(inToken2, inValue2);
  FND_MESSAGE.SET_TOKEN(inToken3, inValue3);
  v_String := FND_MESSAGE.GET;

  RETURN v_String;
END;

FUNCTION GET_TEXT(inMessageName IN VARCHAR2,
                  inToken1 IN VARCHAR2, inValue1 IN VARCHAR2,
                  inToken2 IN VARCHAR2, inValue2 IN VARCHAR2,
                  inToken3 IN VARCHAR2, inValue3 IN VARCHAR2,
                  inToken4 IN VARCHAR2, inValue4 IN VARCHAR2) RETURN VARCHAR2 IS
  v_String  VARCHAR2(2000);
BEGIN
  FND_MESSAGE.SET_NAME('CZ', inMessageName);
  FND_MESSAGE.SET_TOKEN(inToken1, inValue1);
  FND_MESSAGE.SET_TOKEN(inToken2, inValue2);
  FND_MESSAGE.SET_TOKEN(inToken3, inValue3);
  FND_MESSAGE.SET_TOKEN(inToken4, inValue4);
  v_String := FND_MESSAGE.GET;

  RETURN v_String;
END;

FUNCTION GET_TEXT(inMessageName IN VARCHAR2,
                  inToken1 IN VARCHAR2, inValue1 IN VARCHAR2,
                  inToken2 IN VARCHAR2, inValue2 IN VARCHAR2,
                  inToken3 IN VARCHAR2, inValue3 IN VARCHAR2,
                  inToken4 IN VARCHAR2, inValue4 IN VARCHAR2,
                  inToken5 IN VARCHAR2, inValue5 IN VARCHAR2) RETURN VARCHAR2 IS
  v_String  VARCHAR2(2000);
BEGIN
  FND_MESSAGE.SET_NAME('CZ', inMessageName);
  FND_MESSAGE.SET_TOKEN(inToken1, inValue1);
  FND_MESSAGE.SET_TOKEN(inToken2, inValue2);
  FND_MESSAGE.SET_TOKEN(inToken3, inValue3);
  FND_MESSAGE.SET_TOKEN(inToken4, inValue4);
  FND_MESSAGE.SET_TOKEN(inToken5, inValue5);
  v_String := FND_MESSAGE.GET;

  RETURN v_String;
END;

FUNCTION GET_TEXT(inMessageName IN VARCHAR2,
                  inToken1 IN VARCHAR2, inValue1 IN VARCHAR2,
                  inToken2 IN VARCHAR2, inValue2 IN VARCHAR2,
                  inToken3 IN VARCHAR2, inValue3 IN VARCHAR2,
                  inToken4 IN VARCHAR2, inValue4 IN VARCHAR2,
                  inToken5 IN VARCHAR2, inValue5 IN VARCHAR2,
                  inToken6 IN VARCHAR2, inValue6 IN VARCHAR2) RETURN VARCHAR2 IS
  v_String  VARCHAR2(2000);
BEGIN
  FND_MESSAGE.SET_NAME('CZ', inMessageName);
  FND_MESSAGE.SET_TOKEN(inToken1, inValue1);
  FND_MESSAGE.SET_TOKEN(inToken2, inValue2);
  FND_MESSAGE.SET_TOKEN(inToken3, inValue3);
  FND_MESSAGE.SET_TOKEN(inToken4, inValue4);
  FND_MESSAGE.SET_TOKEN(inToken5, inValue5);
  FND_MESSAGE.SET_TOKEN(inToken6, inValue6);
  v_String := FND_MESSAGE.GET;

  RETURN v_String;
END;

----function that checks if installed languages are the same on the source and target server
----returns 0 if correct validation else 1

FUNCTION check_installed_lang(p_server_id		IN NUMBER)
RETURN NUMBER AS

  TYPE ref_cursor IS REF CURSOR;

  v_db_link            VARCHAR2(128);
  tgt_lang_cur 	     ref_cursor;
  v_return             NUMBER;
  x_error              BOOLEAN:=FALSE;

BEGIN

  v_db_link := retrieve_db_link(p_server_id);

  IF(p_server_id <> 0 AND v_db_link IS NULL)THEN RETURN 1; END IF;

  OPEN tgt_lang_cur FOR
    'SELECT NULL FROM fnd_languages' || v_db_link || ' remote ' ||
    ' WHERE installed_flag IN (''B'', ''I'') AND NOT EXISTS ' ||
    '  (SELECT NULL FROM fnd_languages local ' ||
    '    WHERE local.language_code = remote.language_code ' ||
    '      AND local.installed_flag = remote.installed_flag) ' ||
    'UNION ' ||
    'SELECT NULL FROM fnd_languages local ' ||
    ' WHERE installed_flag IN (''B'', ''I'') AND NOT EXISTS ' ||
    '  (SELECT NULL FROM fnd_languages' || v_db_link || ' remote ' ||
    '    WHERE local.language_code = remote.language_code ' ||
    '      AND local.installed_flag = remote.installed_flag)';

   LOOP
     FETCH tgt_lang_cur INTO v_return;
     EXIT WHEN tgt_lang_cur%NOTFOUND;

     RETURN 1;
   END LOOP;

   RETURN 0;

EXCEPTION
  WHEN OTHERS THEN
    -- x_error:=CZ_UTILS.REPORT(SQLERRM,1,'CZ_UTILS.CHECK_INSTALLED_LANG',11276);
    log_report('cz_utils', 'check_installed_lang', 1, SQLERRM, fnd_log.LEVEL_UNEXPECTED);
    RETURN 1;
END check_installed_lang;

-------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- Currently this procedure is not used at all. It is commented out because of
-- bug 3451160. If we do need this procdure later on, we will need to move it
-- to other package.
PROCEDURE report_html_tags IS
/*
  TYPE StringTable IS TABLE OF VARCHAR2(10);

  --Modify the list to include/exclude html tags to report. Tags in the list
  --must be in capital letters.

  searchList  StringTable := StringTable('<APPLET',
                                         '<SCRIPT',
                                         '<OBJECT',
                                         '<EMBED');

  --Predefined reporting parameters, modify here if necessary.

  defStatusCode  NUMBER :=       17000;
  defUrgency     NUMBER :=       1;
  defCaller      VARCHAR2(40) := 'report_html_tags';

  textString     VARCHAR2(2000);

  PROCEDURE REPORT(inMessage IN VARCHAR2) IS
  BEGIN
    log_report('CZ_UTILS', defCaller, defStatusCode, inMessage, fnd_log.LEVEL_STATEMENT);
    -- INSERT INTO cz_db_logs (message, statuscode, caller, urgency, logtime)
    -- VALUES (inMessage, defStatusCode, defCaller, defUrgency, SYSDATE);

  END;
*/
BEGIN
/*
  --Checks for the DELETED_FLAG are intentionally omitted to make the search
  --more extensive.

  --cz_localized_text...

  FOR c IN (SELECT intl_text_id, localized_str, language FROM cz_localized_texts
            -- WHERE deleted_flag = '0'
           ) LOOP

    textString := UPPER(c.localized_str);
    FOR i IN 1..searchList.COUNT LOOP

      IF(INSTR(textString, searchList(i)) > 0)THEN

        REPORT('HTML tag ' || searchList(i) ||
               ' found in CZ_LOCALIZED_TEXTS table for INTL_TEXT_ID = ' || c.intl_text_id ||
               ', LANGUAGE = ' || c.language ||
               ': ' || c.localized_str);
      END IF;
    END LOOP;
  END LOOP;

  --cz_ps_nodes...

  FOR c IN (SELECT ps_node_id, name FROM cz_ps_nodes
            -- WHERE deleted_flag = '0'
           ) LOOP

    textString := UPPER(c.name);
    FOR i IN 1..searchList.COUNT LOOP

      IF(INSTR(textString, searchList(i)) > 0)THEN

        REPORT('HTML tag ' || searchList(i) ||
               ' found in CZ_PS_NODES table for PS_NODE_ID = ' || c.ps_node_id ||
               ': ' || c.name);
      END IF;
    END LOOP;
  END LOOP;

  --fnd_new_messages...

  FOR c IN (SELECT message_name, message_text FROM fnd_new_messages
             WHERE application_id = 708) LOOP

    textString := UPPER(c.message_text);
    FOR i IN 1..searchList.COUNT LOOP

      IF(INSTR(textString, searchList(i)) > 0)THEN

        REPORT('HTML tag ' || searchList(i) ||
               ' found in FND_NEW_MESSAGES table for MESSAGE_NAME = ' || c.message_name ||
               ': ' || c.message_text);
      END IF;
    END LOOP;
  END LOOP;

  --cz_config_inputs...

  FOR c IN (SELECT config_hdr_id, config_rev_nbr, config_input_id, input_val
              FROM cz_config_inputs
             WHERE input_type_code = 2
            --   AND deleted_flag = '0'
           ) LOOP

    textString := UPPER(c.input_val);
    FOR i IN 1..searchList.COUNT LOOP

      IF(INSTR(textString, searchList(i)) > 0)THEN

        REPORT('HTML tag ' || searchList(i) ||
               ' found in CZ_CONFIG_INPUTS for CONFIG_HDR_ID = ' || c.config_hdr_id ||
               ', CONFIG_REV_NBR = ' || c.config_rev_nbr ||
               ', CONFIG_INPUT_ID = ' || c.config_input_id ||
               ': ' || c.input_val);
      END IF;
    END LOOP;
  END LOOP;

  --cz_config_items...

  FOR c IN (SELECT config_hdr_id, config_rev_nbr, config_item_id, item_val
              FROM cz_config_items
             WHERE value_type_code = 2
            --   AND deleted_flag = '0'
           ) LOOP


    textString := UPPER(c.item_val);
    FOR i IN 1..searchList.COUNT LOOP

      IF(INSTR(textString, searchList(i)) > 0)THEN

        REPORT('HTML tag ' || searchList(i) ||
               ' found in CZ_CONFIG_ITEMS for CONFIG_HDR_ID = ' || c.config_hdr_id ||
               ', CONFIG_REV_NBR = ' || c.config_rev_nbr ||
               ', CONFIG_ITEM_ID = ' || c.config_item_id ||
               ': ' || c.item_val);
      END IF;
    END LOOP;
  END LOOP;
*/ NULL;
END report_html_tags;

-------------------------------------------------
PROCEDURE LOG_REPORT(p_pkg_name  VARCHAR2,
                     p_routine   VARCHAR2,
                     p_ndebug    NUMBER,
                     p_msg       VARCHAR2,
                     p_log_level NUMBER)
IS
PRAGMA AUTONOMOUS_TRANSACTION;

  l_module_name VARCHAR2(2000);

BEGIN
  IF (p_log_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    l_module_name := 'cz.plsql.'||p_pkg_name||'.'||p_routine||'.'||p_ndebug;
    FND_LOG.STRING(p_log_level,l_module_name,p_msg);
  END IF;
  COMMIT;
END LOG_REPORT;

-------------------------------
FUNCTION retrieve_db_link(p_server_id IN PLS_INTEGER)
RETURN   VARCHAR2
IS
v_db_link cz_servers.fndnam_link_name%TYPE;

BEGIN
  IF (p_server_id = 0) THEN
	v_db_link := ' ';
  ELSE
	SELECT FNDNAM_LINK_NAME
      INTO   v_db_link
      FROM   cz_servers
      WHERE  cz_servers.server_local_id = p_server_id;
      v_db_link := '@'||v_db_link||' ';
  END IF;
  RETURN v_db_link ;
EXCEPTION
WHEN NO_DATA_FOUND THEN
   RETURN '-1';
WHEN OTHERS THEN
  RETURN '-1';
END retrieve_db_link;

---------------------------------------------

/* use this procedure to add an error message
   to the stack.  In some cases, the return status needs to be set,
   use the statement x_return_status := FND_API.G_RET_STS_ERROR;
   to set the error condition before calling this routine
*/
PROCEDURE add_error_message_to_stack(p_message_name IN VARCHAR2,
                            p_token_name1   IN VARCHAR2 ,
                            p_token_value1  IN VARCHAR2 ,
                            p_token_name2   IN VARCHAR2 ,
                            p_token_value2  IN VARCHAR2 ,
                            p_token_name3   IN VARCHAR2 ,
                            p_token_value3  IN VARCHAR2 ,
                            x_msg_count     IN OUT NOCOPY NUMBER,
                            x_msg_data     IN OUT NOCOPY VARCHAR2) IS

BEGIN
  FND_MESSAGE.SET_NAME('CZ', p_message_name);
  IF p_token_name1 IS NOT NULL THEN
    FND_MESSAGE.SET_TOKEN(p_token_name1, p_token_value1);
  END IF;
  IF p_token_name2 IS NOT NULL THEN
    FND_MESSAGE.SET_TOKEN(p_token_name2, p_token_value2);
  END IF;
  IF p_token_name3 IS NOT NULL THEN
    FND_MESSAGE.SET_TOKEN(p_token_name3, p_token_value3);
  END IF;
  FND_MSG_PUB.ADD;
  FND_MSG_PUB.count_and_get(p_count => x_msg_count,
                            p_data  => x_msg_data);
END add_error_message_to_stack;



/* use this procedure to add an error message
   to the stack.  In some cases, the return status needs to be set,
   use the statement x_return_status := FND_API.G_RET_STS_ERROR;
   to set the error condition before calling this routine
*/
PROCEDURE add_error_message_to_stack(p_message_name IN VARCHAR2,
                            p_token_name1   IN VARCHAR2 ,
                            p_token_value1  IN VARCHAR2 ,
                            x_msg_count     IN OUT NOCOPY NUMBER,
                            x_msg_data     IN OUT NOCOPY VARCHAR2) IS

BEGIN
  FND_MESSAGE.SET_NAME('CZ', p_message_name);
  IF p_token_name1 IS NOT NULL THEN
    FND_MESSAGE.SET_TOKEN(p_token_name1, p_token_value1);
  END IF;
  FND_MSG_PUB.ADD;
  FND_MSG_PUB.count_and_get(p_count => x_msg_count,
                            p_data  => x_msg_data);
END add_error_message_to_stack;



/* use this procedure to add an error message
   to the stack.  In some cases, the return status needs to be set,
   use the statement x_return_status := FND_API.G_RET_STS_ERROR;
   to set the error condition before calling this routine
*/
PROCEDURE add_error_message_to_stack(p_message_name IN VARCHAR2,
                            p_token_name1   IN VARCHAR2 ,
                            p_token_value1  IN VARCHAR2 ,
                            p_token_name2   IN VARCHAR2 ,
                            p_token_value2  IN VARCHAR2 ,
                            x_msg_count     IN OUT NOCOPY NUMBER,
                            x_msg_data     IN OUT NOCOPY VARCHAR2) IS

BEGIN
  FND_MESSAGE.SET_NAME('CZ', p_message_name);
  IF p_token_name1 IS NOT NULL THEN
    FND_MESSAGE.SET_TOKEN(p_token_name1, p_token_value1);
  END IF;
  IF p_token_name2 IS NOT NULL THEN
    FND_MESSAGE.SET_TOKEN(p_token_name2, p_token_value2);
  END IF;
  FND_MSG_PUB.ADD;
  FND_MSG_PUB.count_and_get(p_count => x_msg_count,
                            p_data  => x_msg_data);
END add_error_message_to_stack;



/* use this procedure to add an error message
   to the stack.  In some cases, the return status needs to be set,
   use the statement return_status := FND_API.G_RET_STS_ERROR, and
   add msg_count := 1 to initialize the message coutnt
   to set the error condition before calling this routine
*/

PROCEDURE add_exc_msg_to_fndstack
(p_package_name IN VARCHAR2,
 p_procedure_name IN  VARCHAR2,
 p_error_message  IN  VARCHAR2)
IS
    l_msg_data VARCHAR2(32000);
BEGIN
    fnd_msg_pub.add_exc_msg(p_package_name, p_procedure_name, p_error_message);
END add_exc_msg_to_fndstack;
---------------------------------------------

END CZ_UTILS;

/
