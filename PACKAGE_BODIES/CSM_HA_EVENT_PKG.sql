--------------------------------------------------------
--  DDL for Package Body CSM_HA_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_HA_EVENT_PKG" AS
/* $Header: csmehab.pls 120.0.12010000.21 2010/06/25 06:39:01 saradhak noship $*/
g_debug_level           NUMBER; -- debug level
G_IS_END_TRACKING_CALL BOOLEAN := FALSE;

PROCEDURE GET_XML_PAYLOAD
( p_TABLE_NAME    IN VARCHAR2,
  p_PK_NAME_LIST  IN  CSM_VARCHAR_LIST,
  p_PK_TYPE_LIST  IN  CSM_VARCHAR_LIST,
  p_PK_CHAR_LIST  IN  CSM_VARCHAR_LIST,
  x_XML_PAYLOAD OUT NOCOPY CLOB,
  x_XML_CONTEXT OUT NOCOPY CLOB,
  x_RETURN_STATUS OUT NOCOPY VARCHAR2,
  x_ERROR_MESSAGE OUT NOCOPY VARCHAR2
)
AS
 l_QUERY_TEXT1 VARCHAR2(4000);
 l_xml         CLOB;
 qrycontext   DBMS_XMLGEN.ctxHandle;

BEGIN
    CSM_UTIL_PKG.LOG
      ( 'Entering GET_XML_PAYLOAD for TAble Name : ' || p_TABLE_NAME  ,
        FND_LOG.LEVEL_PROCEDURE);

    --Query Execution status update
      l_QUERY_TEXT1 := 'SELECT * FROM ' || p_TABLE_NAME ||' WHERE ';

      FOR i in 1..p_PK_NAME_LIST.COUNT LOOP
         IF(i >1) THEN
           l_QUERY_TEXT1 := l_QUERY_TEXT1 || ' AND ';
         END IF;
         IF p_PK_TYPE_LIST(i) = 'NUMBER' THEN
            l_QUERY_TEXT1 := l_QUERY_TEXT1 || p_PK_NAME_LIST(i) || ' = ' || p_PK_CHAR_LIST(i) || ' ';
         ELSE
           l_QUERY_TEXT1 := l_QUERY_TEXT1 || p_PK_NAME_LIST(i) || ' = ''' ||p_PK_CHAR_LIST(i)|| '''  ';
         END IF;
      END LOOP;

      --Execute the SQL query
      qrycontext := DBMS_XMLGEN.newcontext(l_QUERY_TEXT1) ;

      DBMS_XMLGEN.setnullhandling (qrycontext, DBMS_XMLGEN.empty_tag);
      l_xml := DBMS_XMLGEN.getxml (qrycontext);
	  dbms_xmlgen.closeContext(qrycontext);
      x_XML_PAYLOAD := l_xml;

      qrycontext := DBMS_XMLGEN.newcontext('SELECT FND_GLOBAL.user_id,FND_GLOBAL.resp_id,FND_GLOBAL.resp_appl_id,FND_GLOBAL.server_id FROM DUAL') ;
      DBMS_XMLGEN.setnullhandling (qrycontext, DBMS_XMLGEN.empty_tag);
      l_xml := DBMS_XMLGEN.getxml (qrycontext);
	  dbms_xmlgen.closeContext(qrycontext);

      x_XML_CONTEXT := l_xml;

      x_return_status := FND_API.G_RET_STS_SUCCESS;
      x_error_message := 'XML Retrieving Successfully completed ';
     CSM_UTIL_PKG.LOG
      ( 'Leaving GET_XML_PAYLOAD after successfully Executing Query-> ' || l_QUERY_TEXT1 , 'CSM_HA_EVENT_PKG.GET_XML_PAYLOAD',
        FND_LOG.LEVEL_PROCEDURE);


EXCEPTION WHEN OTHERS THEN
  /*** catch and log exceptions ***/
  CSM_UTIL_PKG.LOG
  ( 'Exception occurred in GET_XML_PAYLOAD for Query : ' || l_QUERY_TEXT1  ||  SUBSTR(SQLERRM,1,3000), 'CSM_HA_EVENT_PKG.GET_XML_PAYLOAD',
    FND_LOG.LEVEL_EXCEPTION);
  x_return_status := FND_API.G_RET_STS_ERROR;
  x_error_message := 'XML Retrieve Failed With Message : ' || SUBSTR(SQLERRM,1,3000) ;
END GET_XML_PAYLOAD;

FUNCTION get_stringfrom_list (pk_list IN CSM_VARCHAR_LIST)
           RETURN VARCHAR2
IS
l_string VARCHAR2(1000):='';
BEGIN
 FOR I in 1..pk_list.COUNT
 LOOP
  IF(I=1) THEN
   l_string:=l_string ||pk_list(I);
  ELSE
   l_string:=l_string ||','||pk_list(I);
  END IF;
 END LOOP;

RETURN l_string;
END get_stringfrom_list;


PROCEDURE TRACK_TABLE(p_table_name IN VARCHAR2,p_PK_NAME_LIST IN CSM_VARCHAR_LIST,
 p_PK_TYPE_LIST CSM_VARCHAR_LIST,p_mobile_data IN VARCHAR2)
IS
 l_stmt VARCHAR2(4000);
 l_pk_names VARCHAR2(1000);
 type t_curs is ref cursor;
 cur t_curs;
 l_cnt NUMBER;
 p_pk_value_list CSM_VARCHAR_LIST:=CSM_VARCHAR_LIST();

BEGIN

 CSM_UTIL_PKG.LOG
      ( 'Tracking entire table : '|| p_TABLE_NAME , 'CSM_HA_EVENT_PKG.TRACK_TABLE', FND_LOG.LEVEL_PROCEDURE);

 l_pk_names:=get_stringfrom_list(p_PK_NAME_LIST);
 l_cnt := p_PK_NAME_LIST.COUNT;

 p_pk_value_list.EXTEND(l_cnt);

 OPEN cur FOR 'SELECT '||l_pk_names||' FROM '||p_table_name;
 LOOP
   IF(l_cnt=1) THEN
    FETCH cur INTO p_pk_value_list(1);
   ELSIF(l_cnt=2) THEN
    FETCH cur INTO p_pk_value_list(1),p_pk_value_list(2);
   ELSIF(l_cnt=3) THEN
    FETCH cur INTO p_pk_value_list(1),p_pk_value_list(2),p_pk_value_list(3);
   ELSIF(l_cnt=4) THEN
    FETCH cur INTO p_pk_value_list(1),p_pk_value_list(2),p_pk_value_list(3),p_pk_value_list(4);
   ELSE
    RAISE_APPLICATION_ERROR(-20222,'HA Table Tracking failed since incompatible number of PKs passed');
   END IF;

   EXIT WHEN cur%NOTFOUND;

   TRACK_HA_RECORD(p_table_name,p_pk_name_list,p_pk_type_list,p_pk_value_list,'U',p_mobile_data);

 END LOOP;
END TRACK_TABLE;

/*
This api is used internally and it is called only by RECORD_MFS_DATA api
to handle the corner case involved in tracking SDQ data that is still
pending for download to Mobile Users at the end of the HA recording session.
'Cos of this api we need not process all access tables/SDQ XML Payloads.
*/
PROCEDURE TRACK_MFS_REC_NO_PLD(p_TABLE_NAME VARCHAR2,p_pk_value VARCHAR2)
IS
 l_pld_id NUMBER;
BEGIN

    SELECT CSM_HA_PAYLOAD_DATA_S.nextval INTO l_pld_id FROM DUAL;

    INSERT INTO CSM_HA_PAYLOAD_DATA(HA_PAYLOAD_ID ,OBJECT_NAME, PK_VALUE, PARENT_PAYLOAD_ID,DML_TYPE ,MOBILE_DATA, PROCESSED ,
	CREATION_DATE , CREATED_BY , LAST_UPDATE_DATE  ,LAST_UPDATED_BY,LAST_UPDATE_LOGIN)
    VALUES(l_pld_id,p_TABLE_NAME,p_pk_value,l_pld_id,'I','Y','N',SYSDATE,1,SYSDATE,1,1);

	CSM_HA_AUDIT_PKG.AUDIT_RECORD(l_pld_id,'RECORD');

END TRACK_MFS_REC_NO_PLD;

PROCEDURE RECORD_CSM_TABLES
IS
 l_PK_NAME_LIST  CSM_VARCHAR_LIST:=CSM_VARCHAR_LIST('');
 l_PK_TYPE_LIST  CSM_VARCHAR_LIST:=CSM_VARCHAR_LIST('');
 l_pk_value_list  CSM_VARCHAR_LIST:=CSM_VARCHAR_LIST('');

 type t_curs is ref cursor;
 cur t_curs;
BEGIN

 /**************CSM_AUTO_SYNC_NFN *************/
  CSM_UTIL_PKG.LOG
      ( 'Record CSM_AUTO_SYNC_NFN' , 'CSM_HA_EVENT_PKG.RECORD_CSM_TABLES', FND_LOG.LEVEL_PROCEDURE);

  l_pk_name_list(1):= 'NOTIFICATION_ID';  l_pk_type_list(1):= 'NUMBER';

  FOR rec IN (SELECT NOTIFICATION_ID FROM CSM_AUTO_SYNC_NFN
              WHERE CREATION_DATE >= G_HA_START_TIME)
  LOOP
   l_pk_value_list(1):=rec.NOTIFICATION_ID;
   TRACK_HA_RECORD('CSM_AUTO_SYNC_NFN',l_pk_name_list,l_pk_type_list,l_pk_value_list,'I','Y');
  END LOOP;


 /**************CSM_DEFERRED_NFN_INFO *************/
  CSM_UTIL_PKG.LOG
      ( 'Record CSM_DEFERRED_NFN_INFO' , 'CSM_HA_EVENT_PKG.RECORD_CSM_TABLES', FND_LOG.LEVEL_PROCEDURE);

  l_pk_name_list(1):= 'TRACKING_ID';  l_pk_type_list(1):= 'NUMBER';

  FOR rec IN (SELECT TRACKING_ID FROM CSM_DEFERRED_NFN_INFO
              WHERE CREATION_DATE >= G_HA_START_TIME)
  LOOP
   l_pk_value_list(1):=rec.TRACKING_ID;
   TRACK_HA_RECORD('CSM_DEFERRED_NFN_INFO',l_pk_name_list,l_pk_type_list,l_pk_value_list,'I','Y');
  END LOOP;

 /**************CSM_SYNC_ERROR_NFN_INFO *************/
  CSM_UTIL_PKG.LOG
      ( 'Record CSM_SYNC_ERROR_NFN_INFO' , 'CSM_HA_EVENT_PKG.RECORD_CSM_TABLES', FND_LOG.LEVEL_PROCEDURE);

  l_pk_name_list(1):= 'NOTIFICATION_ID';  l_pk_type_list(1):= 'NUMBER';

  OPEN cur FOR ' SELECT NOTIFICATION_ID FROM CSM_SYNC_ERROR_NFN_INFO '||
               ' WHERE SYNC_SESSION_ID IN (SELECT SESSION_ID FROM '||asg_base.G_OLITE_SCHEMA||'.C$SYNC_HISTORY '||
               ' WHERE START_TIME >= :1)' USING G_HA_START_TIME;
  LOOP
   FETCH cur INTO l_pk_value_list(1);
   EXIT WHEN cur%NOTFOUND;
   TRACK_HA_RECORD('CSM_SYNC_ERROR_NFN_INFO',l_pk_name_list,l_pk_type_list,l_pk_value_list,'I','Y');
  END LOOP;
  CLOSE cur;

 /**************CSM INQ tables *************/

--Copy ALL INQ DATA that are DEFERRED in Standby-  3-PK

 CSM_UTIL_PKG.LOG
      ( 'Tracking ALL INQ HA records' ,
	  'CSM_HA_EVENT_PKG.RECORD_CSM_TABLES', FND_LOG.LEVEL_PROCEDURE);

  l_pk_name_list.extend(2);l_pk_type_list.extend(2);l_pk_value_list.extend(2);
  l_pk_name_list(1):= 'CLID$$CS'; l_pk_name_list(2):= 'TRANID$$';  l_pk_name_list(3):= 'SEQNO$$';
  l_pk_type_list(1):= 'VARCHAR'; l_pk_type_list(2):= 'NUMBER';  l_pk_type_list(3):= 'NUMBER';


  FOR rec IN (SELECT INQ_OWNER,INQ_NAME, DEVICE_USER_NAME, DEFERRED_TRAN_ID,SEQUENCE
              FROM ASG_DEFERRED_TRANINFO info, ASG_PUB_ITEM pi
              WHERE info.OBJECT_NAME = pi.ITEM_ID
			  AND INQ_NAME IS NOT NULL
              AND info.CREATION_DATE >=  G_HA_START_TIME)
  LOOP
   l_pk_value_list(1):= rec.DEVICE_USER_NAME;
   l_pk_value_list(2):= to_char(rec.DEFERRED_TRAN_ID);
   l_pk_value_list(3):= to_char(rec.SEQUENCE);
   TRACK_HA_RECORD(rec.INQ_OWNER||'.'||rec.INQ_NAME,l_pk_name_list,l_pk_type_list,l_pk_value_list,'I','Y');
  END LOOP;


END RECORD_CSM_TABLES;

PROCEDURE RECORD_MFS_DATA
IS
 l_PK_NAME_LIST  CSM_VARCHAR_LIST:=CSM_VARCHAR_LIST();
 l_PK_TYPE_LIST  CSM_VARCHAR_LIST:=CSM_VARCHAR_LIST();
 l_pk_value_list  CSM_VARCHAR_LIST:=CSM_VARCHAR_LIST();
 type t_curs is ref cursor;
 cur t_curs;

BEGIN

  RECORD_CSM_TABLES;   --Record CSM business Tables


/*********************************Record MAF Tables***************************************/

---------------- TRACK ENTIRE TABLES ------------------
  l_PK_NAME_LIST.EXTEND(1);   l_pk_type_list.EXTEND(1);

/*C$ALL_CLIENTS 1-PK */
 CSM_UTIL_PKG.LOG
      ( 'Record MOBILEADMIN.C$ALL_CLIENTS' , 'CSM_HA_EVENT_PKG.RECORD_MFS_DATA', FND_LOG.LEVEL_PROCEDURE);
  l_pk_name_list(1):= 'CLIENTID';  l_pk_type_list(1):= 'VARCHAR';
  TRACK_TABLE('MOBILEADMIN.C$ALL_CLIENTS',l_pk_name_list,l_pk_type_list,'Y');


/* ASG_USER 1-PK */
 CSM_UTIL_PKG.LOG
      ( 'Record ASG_USER' , 'CSM_HA_EVENT_PKG.RECORD_MFS_DATA', FND_LOG.LEVEL_PROCEDURE);
  l_pk_name_list(1):= 'USER_NAME'; l_pk_type_list(1):= 'VARCHAR';
  TRACK_TABLE('ASG_USER',l_pk_name_list,l_pk_type_list,'Y');


 /* ASG_SEQUENCE_PARTITIONS 2-PK */

  l_PK_NAME_LIST.EXTEND(1); l_pk_type_list.EXTEND(1);
  CSM_UTIL_PKG.LOG
      ( 'Record ASG_SEQUENCE_PARTITIONS' , 'CSM_HA_EVENT_PKG.RECORD_MFS_DATA', FND_LOG.LEVEL_PROCEDURE);
   l_pk_name_list(1):= 'CLIENTID'; l_pk_name_list(2):= 'NAME';
   l_pk_type_list(1):= 'VARCHAR'; l_pk_type_list(2):= 'VARCHAR';
   TRACK_TABLE('ASG_SEQUENCE_PARTITIONS',l_pk_name_list,l_pk_type_list,'Y');


-----------------TRACK SPECIFIC RECORDS-------------------

/*Track Specific MFS records in ASG_DEFERRED_TRANINFO, ASG_USERS_INQINFO,ASG_USERS_INQARCHIVE */
 CSM_UTIL_PKG.LOG
      ( 'Track ASG_DEFERRED_TRANINFO HA records' ,
	  'CSM_HA_EVENT_PKG.RECORD_MFS_DATA', FND_LOG.LEVEL_PROCEDURE);



--ASG_DEFERRED_TRANINFO   -- 3PKS

  l_pk_name_list.DELETE;l_pk_type_list.DELETE; l_pk_value_list.DELETE;
  l_pk_name_list.EXTEND(3);l_pk_type_list.EXTEND(3); l_pk_value_list.EXTEND(3);

  l_pk_name_list(1):= 'DEVICE_USER_NAME'; l_pk_name_list(2):= 'DEFERRED_TRAN_ID';  l_pk_name_list(3):= 'SEQUENCE';
  l_pk_type_list(1):= 'VARCHAR'; l_pk_type_list(2):= 'NUMBER';  l_pk_type_list(3):= 'NUMBER';

  FOR rec IN (SELECT DEVICE_USER_NAME,DEFERRED_TRAN_ID,SEQUENCE
              FROM ASG_DEFERRED_TRANINFO
              WHERE CREATION_DATE >= G_HA_START_TIME)
  LOOP
   l_pk_value_list(1):=rec.DEVICE_USER_NAME;
   l_pk_value_list(2):=rec.DEFERRED_TRAN_ID;
   l_pk_value_list(3):=rec.SEQUENCE;
   TRACK_HA_RECORD('ASG_DEFERRED_TRANINFO',l_pk_name_list,l_pk_type_list,l_pk_value_list,'I','Y');
  END LOOP;

--ASG_USERS_INQINFO and ASG_USERS_INQARCHIVE --2 PKS

 CSM_UTIL_PKG.LOG
      ( 'Track ASG_USERS_INQINFO and ASG_USERS_INQARCHIVE HA records' ,
	  'CSM_HA_EVENT_PKG.RECORD_MFS_DATA', FND_LOG.LEVEL_PROCEDURE);

 l_pk_name_list.DELETE;l_pk_type_list.DELETE; l_pk_value_list.DELETE;
 l_pk_name_list.extend(2);l_pk_type_list.extend(2);l_pk_value_list.extend(2);

 l_pk_name_list(1):= 'DEVICE_USER_NAME'; l_pk_name_list(2):= 'TRANID';
 l_pk_type_list(1):= 'VARCHAR'; l_pk_type_list(2):= 'NUMBER';

  FOR rec IN (SELECT DEVICE_USER_NAME,TRANID
              FROM ASG_USERS_INQINFO
              WHERE CREATION_DATE >= G_HA_START_TIME)
  LOOP
   l_pk_value_list(1):=rec.DEVICE_USER_NAME;
   l_pk_value_list(2):=rec.TRANID;
   TRACK_HA_RECORD('ASG_USERS_INQINFO',l_pk_name_list,l_pk_type_list,l_pk_value_list,'I','Y');
   TRACK_HA_RECORD('ASG_USERS_INQARCHIVE',l_pk_name_list,l_pk_type_list,l_pk_value_list,'I','Y');
  END LOOP;

--MOBILEADMIN.C$SYNC_HISTORY 1-PK

 CSM_UTIL_PKG.LOG
      ( 'Tracking MOBILEADMIN.C$SYNC_HISTORY HA records' ,
	  'CSM_HA_EVENT_PKG.RECORD_MFS_DATA', FND_LOG.LEVEL_PROCEDURE);

  l_pk_name_list.DELETE;l_pk_type_list.DELETE; l_pk_value_list.DELETE;
  l_pk_name_list.EXTEND(1);l_pk_type_list.EXTEND(1); l_pk_value_list.EXTEND(1);

  l_pk_name_list(1):= 'SESSION_ID';
  l_pk_type_list(1):= 'NUMBER';

  OPEN cur FOR 'SELECT SESSION_ID FROM '||asg_base.G_OLITE_SCHEMA||'.C$SYNC_HISTORY '
                ||'WHERE START_TIME >= :1' USING G_HA_START_TIME;
  LOOP
   FETCH cur INTO l_pk_value_list(1);
   EXIT WHEN cur%NOTFOUND;
   TRACK_HA_RECORD('MOBILEADMIN.C$SYNC_HISTORY',l_pk_name_list,l_pk_type_list,l_pk_value_list,'I','Y');
  END LOOP;
  CLOSE cur;


--MOBILEADMIN.C$SYNC_HIS_PUB_ITEMS 3-PK

 CSM_UTIL_PKG.LOG
      ( 'Tracking MOBILEADMIN.C$SYNC_HIS_PUB_ITEMS HA records' ,
	  'CSM_HA_EVENT_PKG.RECORD_MFS_DATA', FND_LOG.LEVEL_PROCEDURE);

  l_pk_name_list.DELETE;l_pk_type_list.DELETE; l_pk_value_list.DELETE;
  l_pk_name_list.EXTEND(3);l_pk_type_list.EXTEND(3); l_pk_value_list.EXTEND(3);

  l_pk_name_list(1):= 'SESSION_ID'; l_pk_name_list(2):= 'PUB_ITEM';  l_pk_name_list(3):= 'PHASE';
  l_pk_type_list(1):= 'NUMBER'; l_pk_type_list(2):= 'VARCHAR'; l_pk_type_list(3):= 'VARCHAR';

  OPEN cur FOR 'SELECT SESSION_ID,PUB_ITEM,PHASE FROM '
               ||asg_base.G_OLITE_SCHEMA||'.C$SYNC_HIS_PUB_ITEMS '
               ||'WHERE ROWNUM<2 AND START_TIME >= :1' USING G_HA_START_TIME;
  LOOP
   FETCH cur INTO l_pk_value_list(1),l_pk_value_list(2),l_pk_value_list(3);
   EXIT WHEN cur%NOTFOUND;
   TRACK_HA_RECORD('MOBILEADMIN.C$SYNC_HIS_PUB_ITEMS',l_pk_name_list,l_pk_type_list,l_pk_value_list,'I','Y');
  END LOOP;
  CLOSE cur;

-- Process ASG_SYSTEM_DIRTY_QUEUE - pending download data
 CSM_UTIL_PKG.LOG
      ( 'No Pld Track of ASG_SYSTEM_DIRTY_QUEUE' , 'CSM_HA_EVENT_PKG.RECORD_MFS_DATA', FND_LOG.LEVEL_PROCEDURE);

 FOR rec IN (SELECT DISTINCT USER_ID,HA_PARENT_PAYLOAD_ID
             FROM ASG_SYSTEM_DIRTY_QUEUE a, ASG_USER b
             WHERE HA_PARENT_PAYLOAD_ID IS NOT NULL
             AND (DOWNLOAD_FLAG IS NULL OR TRANSACTION_ID IS NULL)
             AND a.CLIENT_ID=b.USER_NAME)
 LOOP
  TRACK_MFS_REC_NO_PLD('ASG_SYSTEM_DIRTY_QUEUE', rec.HA_PARENT_PAYLOAD_ID||','||rec.USER_ID);
 END LOOP;

END RECORD_MFS_DATA;

PROCEDURE ASSIGN_HA_RESPONSIBILITIES
IS
BEGIN
 /*
  Activate all HA responsibilities mentioned in CSM_HA_RESP_MAPPINGS table
   -> remove the end-date if present
   -> reset future start_dates back to sysdate-1
 */
   UPDATE FND_RESPONSIBILITY SET END_DATE=null
   WHERE (APPLICATION_ID,RESPONSIBILITY_ID) IN (SELECT HA_APPLICATION_ID,HA_RESPONSIBILITY_ID
                                                FROM CSM_HA_RESP_MAPPINGS)
   AND END_DATE IS NOT NULL;

   UPDATE FND_RESPONSIBILITY SET START_DATE=sysdate-1
   WHERE (APPLICATION_ID,RESPONSIBILITY_ID) IN (SELECT HA_APPLICATION_ID,HA_RESPONSIBILITY_ID
                                                FROM CSM_HA_RESP_MAPPINGS)
   AND NVL(START_DATE,SYSDATE-1) > SYSDATE;


 /*
   Assign HA responsibility to users mapped to corresponding non-HA responsibility
 */
   FOR rec IN (SELECT  usr.USER_NAME,app.APPLICATION_SHORT_NAME app_name,mapp.HA_RESP_KEY resp_key
               FROM FND_USER_RESP_GROUPS usr_rsp,
                    CSM_HA_RESP_MAPPINGS mapp,
                    FND_APPLICATION app,
                    FND_USER usr
               WHERE SYSDATE BETWEEN nvl(usr_rsp.START_DATE,SYSDATE-1) AND nvl(usr_rsp.END_DATE,SYSDATE+1)
               AND  usr_rsp.USER_ID=usr.USER_ID
               AND  usr_rsp.RESPONSIBILITY_ID=mapp.RESPONSIBILITY_ID
               AND  usr_rsp.RESPONSIBILITY_APPLICATION_ID= mapp.APPLICATION_ID
               AND  mapp.HA_APPLICATION_ID=app.APPLICATION_ID
               AND NOT EXISTS (SELECT 1 FROM FND_USER_RESP_GROUPS
                               WHERE USER_ID=usr.USER_ID
                               AND RESPONSIBILITY_ID=mapp.HA_RESPONSIBILITY_ID
							   AND RESPONSIBILITY_APPLICATION_ID=mapp.HA_APPLICATION_ID))
   LOOP
     FND_USER_PKG.ADDRESP(rec.USER_NAME,rec.APP_NAME,rec.RESP_KEY,'STANDARD',NULL,sysdate,null);
   END LOOP;

END ASSIGN_HA_RESPONSIBILITIES;

PROCEDURE DEACTIVATE_NON_HA_RESPS
IS
BEGIN

  UPDATE FND_RESPONSIBILITY SET END_DATE=SYSDATE-1
  WHERE (APPLICATION_ID,RESPONSIBILITY_ID) NOT IN (SELECT HA_APPLICATION_ID,HA_RESPONSIBILITY_ID
                                                   FROM CSM_HA_RESP_MAPPINGS)
  AND NVL(END_DATE, SYSDATE+1) > SYSDATE-1
  AND APPLICATION_ID not in (0,1);

END DEACTIVATE_NON_HA_RESPS;

PROCEDURE MANAGE_CONCURRENT_PROGRAMS
IS
l_app_id NUMBER;
l_grp_id NUMBER;
BEGIN

/*following SQL used only while development as new HA conc progs can be added*/
--------------------------------------------------------
 UPDATE FND_CONCURRENT_PROGRAMS SET ENABLED_FLAG='Y'
 WHERE (APPLICATION_ID,CONCURRENT_PROGRAM_ID) IN
	   (SELECT APPLICATION_ID,CONCURRENT_PROGRAM_ID FROM CSM_HA_ACTIVE_CONC_DATA);
------------------------------------------------------

/*
--Choose: Api call or the below direct update
 FOR rec in (SELECT B.APPLICATION_SHORT_NAME APP_NAME, CONCURRENT_PROGRAM_NAME
             FROM FND_CONCURRENT_PROGRAMS a, FND_APPLICATION b
             WHERE (APPLICATION_ID,CONCURRENT_PROGRAM_ID) NOT IN
  	  	           (SELECT APPLICATION_ID,CONCURRENT_PROGRAM_ID FROM CSM_HA_ACTIVE_CONC_DATA)
             AND APPLICATION_ID NOT IN (0,1)   -- non AOL
             AND a.APPLICATION_ID = b.APPLICATION_ID)
  LOOP
   FND_PROGRAM.enable_program(rec.CONCURRENT_PROGRAM_NAME,rec.APP_NAME,'N');
  END LOOP;
*/

--direct update

 UPDATE FND_CONCURRENT_PROGRAMS SET ENABLED_FLAG='N'
 WHERE (APPLICATION_ID,CONCURRENT_PROGRAM_ID) NOT IN
	   (SELECT APPLICATION_ID,CONCURRENT_PROGRAM_ID FROM CSM_HA_ACTIVE_CONC_DATA)
 AND APPLICATION_ID NOT IN (0,1);  -- non AOL


  --create a resp group and assign all active concurrent programs to it
  IF NOT FND_PROGRAM.request_group_exists('CSM_HA_REQUEST_GROUP','CSM') THEN
    FND_PROGRAM.request_group('CSM_HA_REQUEST_GROUP','CSM');
  END IF;

  SELECT application_id,request_group_id INTO l_app_id,l_grp_id from fnd_request_groups
  where request_group_name='CSM_HA_REQUEST_GROUP';

  FOR rec in (SELECT B.APPLICATION_SHORT_NAME APP_NAME, CONCURRENT_PROGRAM_NAME
              FROM CSM_HA_ACTIVE_CONC_DATA a, FND_APPLICATION b
              WHERE a.APPLICATION_ID = b.APPLICATION_ID
              AND a.APPLICATION_ID NOT IN (0,1)
              AND NOT EXISTS (SELECT 1 FROM FND_REQUEST_GROUP_UNITS
                              WHERE UNIT_APPLICATION_ID=a.APPLICATION_ID
                              AND  REQUEST_UNIT_ID=a.CONCURRENT_PROGRAM_ID
                              AND  APPLICATION_ID=l_app_id
                              AND  REQUEST_GROUP_ID=l_grp_id))
  LOOP
    FND_PROGRAM.add_to_group(rec.CONCURRENT_PROGRAM_NAME,rec.APP_NAME,'CSM_HA_REQUEST_GROUP','CSM');
  END LOOP;

  --assign this request grp to all active non-FND resps
  UPDATE FND_RESPONSIBILITY SET GROUP_APPLICATION_ID=l_app_id, REQUEST_GROUP_ID=l_grp_id
  WHERE APPLICATION_ID NOT IN (0,1)
  AND SYSDATE BETWEEN nvl(START_DATE,SYSDATE-1) AND nvl(END_DATE,SYSDATE+1)
  AND REQUEST_GROUP_ID<>l_grp_id;

END MANAGE_CONCURRENT_PROGRAMS;


-- Copy of wfrmitt.sql
PROCEDURE WFRMITT(p_item_type IN VARCHAR2)
IS
BEGIN
    delete from WF_ITEM_ACTIVITY_STATUSES_H
    where  PROCESS_ACTIVITY in
               (select INSTANCE_ID from WF_PROCESS_ACTIVITIES
                where  PROCESS_ITEM_TYPE = p_item_type
                or     ACTIVITY_ITEM_TYPE = p_item_type);

    delete from WF_ITEM_ACTIVITY_STATUSES
    where  PROCESS_ACTIVITY in
               (select INSTANCE_ID from WF_PROCESS_ACTIVITIES
                where  PROCESS_ITEM_TYPE = p_item_type
                or     ACTIVITY_ITEM_TYPE = p_item_type);

    delete from wf_item_attribute_values
    where  ITEM_TYPE = p_item_type;

    delete from wf_items
    where  ITEM_TYPE = p_item_type;

    delete from wf_notification_attributes NA
    where exists (select 'X' from wf_notifications N
                  where N.notification_id = NA.notification_id
                  and N.message_type = p_item_type);

    delete from wf_comments WC
    where exists (select 'X' from wf_notifications N
                  where N.notification_id = WC.notification_id
                  and N.message_type = p_item_type);

    delete from wf_notifications
    where message_type = p_item_type;

    delete from wf_routing_rule_attributes RA
    where exists (select 'X' from wf_routing_rules R
                  where R.rule_id = RA.rule_id
                  and R.message_type = p_item_type);

    delete from wf_routing_rules
    where message_type = p_item_type;

    delete from wf_activity_transitions PAT
    where  exists (select 'X' from wf_process_activities PAC
                   where  PAT.FROM_PROCESS_ACTIVITY = PAC.instance_id
                   and    PAC.PROCESS_ITEM_TYPE = p_item_type);

    delete from wf_activity_attr_values ATV
    where  exists (select 'X' from wf_process_activities PAC
                   where  ATV.PROCESS_ACTIVITY_ID = PAC.instance_id
                   and    PAC.PROCESS_ITEM_TYPE = p_item_type);

    delete from wf_process_activities
    where  PROCESS_ITEM_TYPE = p_item_type;

    delete from wf_activity_attributes_tl
    where  ACTIVITY_ITEM_TYPE = p_item_type;

    delete from wf_activity_attributes
    where  ACTIVITY_ITEM_TYPE = p_item_type;

    delete from wf_activities_tl ACTL
    where  ACTL.ITEM_TYPE = p_item_type
    and  not exists(select 'X' from wf_process_activities PAC
                               where PAC.ACTIVITY_ITEM_TYPE='WFSTD'
                   and   PAC.ACTIVITY_ITEM_TYPE=p_item_type
                   and   PAC.ACTIVITY_NAME = ACTL.NAME);

    delete from wf_activities ACT
    where  ACT.ITEM_TYPE = p_item_type
    and  not exists(select 'X' from wf_process_activities PAC
                               where PAC.ACTIVITY_ITEM_TYPE='WFSTD'
                   and   PAC.ACTIVITY_ITEM_TYPE=p_item_type
                   and   PAC.ACTIVITY_NAME = ACT.NAME);

    delete from wf_message_attributes_tl
    where  message_type = p_item_type;

    delete from wf_message_attributes
    where  message_type = p_item_type;

    delete from wf_messages_tl
    where  type = p_item_type;

    delete from wf_messages
    where  type = p_item_type;

    delete from wf_item_attributes_tl
    where  ITEM_TYPE = p_item_type;

    delete from wf_item_attributes
    where  ITEM_TYPE = p_item_type;

    delete from wf_lookups_tl LUC
    where  exists (select 'X' from WF_LOOKUP_TYPES_TL LUT
                   where  LUT.ITEM_TYPE = p_item_type
                   and    LUT.LOOKUP_TYPE = LUC.LOOKUP_TYPE);

    delete from wf_lookup_types_tl
    where  ITEM_TYPE = p_item_type;

    delete from wf_item_types_tl
    where  NAME = p_item_type;

    delete from wf_item_types
    where  NAME = p_item_type;

END WFRMITT;


PROCEDURE DEACTIVATE_WF_COMPONENTS
IS
l_t NUMBER;
BEGIN
 FOR rec IN (SELECT WF_ITEM_TYPE,WF_EVENT_NAME,WF_EVENT_SUBSCRIPTION_GUID
             FROM CSM_HA_ACTIVE_WF_COMPONENTS
			 WHERE AUTO_DISABLE_FLAG='Y' AND ENABLED_ON_RECORD='N')
 LOOP
   IF rec.WF_EVENT_NAME IS NOT NULL THEN
    IF rec.WF_EVENT_SUBSCRIPTION_GUID IS NULL THEN
	  UPDATE wf_events SET STATUS='DISABLED' WHERE lower(name)=lower(rec.WF_EVENT_NAME);
	ELSE
	  UPDATE wf_event_subscriptions SET STATUS='DISABLED'
	  WHERE GUID=rec.WF_EVENT_SUBSCRIPTION_GUID
	  AND EVENT_FILTER_GUID = (select guid from wf_events where lower(name)=lower(rec.WF_EVENT_NAME));
	END IF;
   END IF;

  IF rec.WF_ITEM_TYPE IS NOT NULL THEN
   BEGIN
    SELECT 1 into l_t
    from wf_item_types
    where  upper(NAME) = upper(rec.WF_ITEM_TYPE);

    WFRMITT(rec.WF_ITEM_TYPE);
--	COMMIT;  --as the volume of data might be huge
   EXCEPTION
   WHEN OTHERS THEN
    NULL;
   END;
  END IF;
 END LOOP;
END DEACTIVATE_WF_COMPONENTS;

PROCEDURE SET_HA_PROFILE(p_value IN VARCHAR2)
IS
PRAGMA AUTONOMOUS_TRANSACTION;
x boolean;
BEGIN

CSM_UTIL_PKG.LOG('Setting HA Profile to value :'||p_value,
                    'CSM_HA_EVENT_PKG.SET_HA_PROFILE', FND_LOG.LEVEL_PROCEDURE);

x:=FND_PROFILE.SAVE('CSM_HA_MODE',p_value,'SITE');
COMMIT;
END SET_HA_PROFILE;

FUNCTION GET_HA_PROFILE_VALUE return VARCHAR2
IS
l_prf VARCHAR2(20);
BEGIN

 BEGIN
  SELECT trim(PROFILE_OPTION_VALUE)  INTO l_prf
  FROM FND_PROFILE_OPTION_VALUES
  WHERE  (APPLICATION_ID,PROFILE_OPTION_ID) IN (SELECT APPLICATION_ID,PROFILE_OPTION_ID
                                                FROM FND_PROFILE_OPTIONS
                                                WHERE PROFILE_OPTION_NAME ='CSM_HA_MODE')
  AND LEVEL_ID=10001 AND LEVEL_VALUE=0;
 EXCEPTION
 WHEN NO_DATA_FOUND THEN
  l_prf:=NULL;
 END;

 CSM_UTIL_PKG.LOG('Current HA Profile value :'||l_prf,
                    'CSM_HA_EVENT_PKG.GET_HA_PROFILE_VALUE', FND_LOG.LEVEL_PROCEDURE);

 return l_prf;
END GET_HA_PROFILE_VALUE;

PROCEDURE SET_SESSION(p_create_flag boolean:=true)
IS
 CURSOR c_get_session
 IS
 SELECT CSM_HA_SESSION_INFO_S.NEXTVAL FROM DUAL;

 l_ha_session_id NUMBER;
BEGIN

   CSM_UTIL_PKG.LOG('Setting Date format to DD-MON-RR HH24:MI:SS',
                    'CSM_HA_EVENT_PKG.SET_SESSION', FND_LOG.LEVEL_PROCEDURE);
   EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT=''DD-MON-RR HH24:MI:SS''';



  BEGIN
   SELECT session_id,session_start_time,ha_payload_start
          INTO G_HA_SESSION_SEQUENCE,G_HA_START_TIME,G_HA_PAYLOAD_SEQUENCE_START
   FROM CSM_HA_SESSION_INFO
   WHERE SESSION_ID = (SELECT MIN(SESSION_ID) FROM CSM_HA_SESSION_INFO WHERE SESSION_END_TIME IS NULL);


   IF p_create_flag THEN  -- concurrent request case : to reuse existing session

     CSM_UTIL_PKG.LOG('Re-Using session id '||G_HA_SESSION_SEQUENCE||' created by a concurrent race condition.',
                    'CSM_HA_EVENT_PKG.SET_SESSION', FND_LOG.LEVEL_PROCEDURE);

     G_HA_START_TIME             :=  SYSTIMESTAMP;
     SELECT CSM_HA_PAYLOAD_DATA_S.nextval INTO G_HA_PAYLOAD_SEQUENCE_START FROM DUAL;

	 UPDATE CSM_HA_SESSION_INFO
	 SET SESSION_START_TIME=G_HA_START_TIME,
	     HA_PAYLOAD_START=G_HA_PAYLOAD_SEQUENCE_START
     WHERE SESSION_ID=G_HA_SESSION_SEQUENCE;
   END IF;

   CSM_UTIL_PKG.LOG('Current Session set to Id :'||G_HA_SESSION_SEQUENCE,
                    'CSM_HA_EVENT_PKG.SET_SESSION', FND_LOG.LEVEL_PROCEDURE);

   RETURN;
  EXCEPTION
   WHEN NO_DATA_FOUND THEN
    NULL;
  END;

  IF NOT p_create_flag THEN
    CSM_UTIL_PKG.LOG('No open session found.Leaving without creating session since session creation is switched OFF',
                      'CSM_HA_EVENT_PKG.SET_SESSION', FND_LOG.LEVEL_PROCEDURE);
    RETURN;
  END IF;

  OPEN  c_get_session;
  FETCH c_get_session INTO l_ha_session_id;
  CLOSE c_get_session;

  CSM_UTIL_PKG.LOG('Creating new Session with Id :'||l_ha_session_id,
                    'CSM_HA_EVENT_PKG.SET_SESSION', FND_LOG.LEVEL_PROCEDURE);

  --Set Session Variables
  G_HA_SESSION_SEQUENCE       := l_ha_session_id;
  G_HA_START_TIME             :=  SYSTIMESTAMP;
  G_HA_END_TIME               :=  NULL;

  SELECT CSM_HA_PAYLOAD_DATA_S.nextval INTO G_HA_PAYLOAD_SEQUENCE_START FROM DUAL;

  G_HA_PAYLOAD_SEQUENCE_END   := NULL;


  INSERT INTO CSM_HA_SESSION_INFO(SESSION_ID,       SESSION_START_TIME, SESSION_END_TIME,
                                  HA_PAYLOAD_START, HA_PAYLOAD_END,     STATUS,
                                  COMMENTS,         CREATION_DATE,      CREATED_BY,
                                  LAST_UPDATE_DATE, LAST_UPDATED_BY,LAST_UPDATE_LOGIN)
                          VALUES( G_HA_SESSION_SEQUENCE,       G_HA_START_TIME, G_HA_END_TIME,
                                  G_HA_PAYLOAD_SEQUENCE_START, G_HA_PAYLOAD_SEQUENCE_END, 'STARTED',
                                  'HA Session in Progress',    SYSDATE,   1,
                                  SYSDATE,                     1,1);

END SET_SESSION;

--Actions
--'A' Apply
--'R' Record
PROCEDURE SAVE_SEQUENCE(p_session_id   IN NUMBER, p_action IN VARCHAR2,
                        p_payload_start IN NUMBER  ,p_payload_end IN NUMBER)
AS

CURSOR c_get_limits(b_session_id NUMBER)
IS
 SELECT HA_PAYLOAD_START,HA_PAYLOAD_END FROM CSM_HA_SESSION_INFO WHERE SESSION_ID = b_session_id;

CURSOR c_get_sequences(b_payload_start NUMBER,b_payload_end NUMBER)
IS
    SELECT SEQ_MAPPING_ID,SEQUENCE_OWNER||'.'||SEQUENCE_NAME ,INCREMENT_BY
    FROM CSM_HA_SEQ_MAPPINGS
    WHERE BUSINESS_OBJECT_NAME IN (SELECT OBJECT_NAME
	                               FROM CSM_HA_PAYLOAD_DATA
                                   WHERE  HA_PAYLOAD_ID between b_payload_start AND b_payload_end
		                           AND DML_TYPE='I');

l_start_seq_value NUMBER;
l_end_seq_value   NUMBER :=0;
l_inc_by_value   NUMBER :=0;
L_SQL_QUERY      varchar2(4000);

l_sequence_list    CSM_VARCHAR_LIST;
l_curr_seq_value number;
L_APPLIED_SEQUENCE_VALUE NUMBER;

TYPE l_num_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
l_seq_map_list  l_num_type;
l_inc_list l_num_type;

l_payload_start NUMBER:=p_payload_start;
l_payload_end NUMBER:=p_payload_end;

BEGIN

  IF p_payload_end IS NULL THEN
    OPEN  c_get_limits (p_session_id);
    FETCH c_get_limits INTO l_payload_start,l_payload_end;
    CLOSE c_get_limits;
  END IF;

  OPEN  c_get_sequences(l_payload_start,l_payload_end);
  FETCH c_get_sequences BULK COLLECT INTO l_seq_map_list,l_sequence_list,l_inc_list;
  CLOSE c_get_sequences;


  IF l_seq_map_list.COUNT = 0 THEN
	CSM_UTIL_PKG.log( 'No Business Object Sequence seems to have been updated in this recording session',
                      'CSM_HA_EVENT_PKG.SAVE_SEQUENCE', FND_LOG.LEVEL_STATEMENT);
    RETURN;
  END IF;

  FOR j in 1..l_seq_map_list.COUNT
  LOOP

      IF p_action ='R' THEN
	    execute immediate 'SELECT  ' ||l_sequence_list(j) || '.NEXTVAL - '||l_inc_list(j)||' FROM dual'
        INTO l_curr_seq_value;

	     CSM_UTIL_PKG.log( 'RECORD: SESSION_ID: ' || P_SESSION_ID || ' SEQUENCE_NAME: '
                       ||l_sequence_list(j) || ' Sequence Value: ' || l_curr_seq_value,
                        'CSM_HA_EVENT_PKG.SAVE_SEQUENCE', FND_LOG.LEVEL_STATEMENT);

	    BEGIN
	      INSERT INTO CSM_HA_SESSION_SEQ_VALUES(SESSION_ID,SEQ_MAPPING_ID,
		  RECORDED_SEQUENCE,CREATION_DATE,CREATED_BY,LAST_UPDATE_DATE,LAST_UPDATED_BY,LAST_UPDATE_LOGIN)
		  VALUES(p_session_id,l_seq_map_list(j),l_curr_seq_value,sysdate,1,sysdate,1,1);
		EXCEPTION
        WHEN Others THEN
		  CSM_UTIL_PKG.log('Rare Case: Caused by concurrent calls - mostly reported by QA'
		                  ,'CSM_HA_EVENT_PKG.SAVE_SEQUENCE', FND_LOG.LEVEL_STATEMENT);
            UPDATE CSM_HA_SESSION_SEQ_VALUES
            SET RECORDED_SEQUENCE    = l_curr_seq_value
            WHERE  SESSION_ID=p_session_id
            AND    SEQ_MAPPING_ID  = L_SEQ_MAP_LIST(J)
            AND RECORDED_SEQUENCE   < l_curr_seq_value;
        END;

      ELSE
	    execute immediate 'SELECT  ' ||l_sequence_list(j) || '.NEXTVAL FROM dual'
        INTO l_curr_seq_value;

	    CSM_UTIL_PKG.log( 'APPLY: SESSION_ID: ' || P_SESSION_ID || ' SEQUENCE_NAME: '
                        ||l_sequence_list(j) || ' Sequence Value: ' || l_curr_seq_value,
                         'CSM_HA_EVENT_PKG.SAVE_SEQUENCE', FND_LOG.LEVEL_STATEMENT);

        UPDATE CSM_HA_SESSION_SEQ_VALUES
        SET APPLY_SEQUENCE    = l_curr_seq_value
        WHERE  SESSION_ID=p_session_id
        and    SEQ_MAPPING_ID  = L_SEQ_MAP_LIST(J)
		RETURNING APPLY_SEQUENCE,RECORDED_SEQUENCE INTO l_start_seq_value,l_end_seq_value;

        l_inc_by_value := l_end_seq_value - l_start_seq_value;

        IF(l_inc_by_value > 0) THEN
          L_SQL_QUERY := 'ALTER SEQUENCE '||L_SEQUENCE_LIST(J) ||' INCREMENT BY ' || l_inc_by_value;
          CSM_UTIL_PKG.log(L_SQL_QUERY, 'CSM_HA_EVENT_PKG.SAVE_SEQUENCE', FND_LOG.LEVEL_STATEMENT);
          execute immediate L_SQL_QUERY;

          /* This select actually increments the sequence value */
          execute immediate 'SELECT ' ||L_SEQUENCE_LIST(J) || '.NEXTVAL  FROM dual'
          into L_APPLIED_SEQUENCE_VALUE;

          CSM_UTIL_PKG.log('Sequence: ' || L_SEQUENCE_LIST(J) ||
          ' Modified Sequence Value: ' || l_applied_sequence_value,
          'CSM_HA_EVENT_PKG.SAVE_SEQUENCE', FND_LOG.LEVEL_STATEMENT);

          UPDATE CSM_HA_SESSION_SEQ_VALUES
          set AFTER_APPLY_SEQUENCE   = L_APPLIED_SEQUENCE_VALUE
          WHERE  SESSION_ID=p_session_id
          and    SEQ_MAPPING_ID  = L_SEQ_MAP_LIST(J);

          /* Set the increment_by back to what it was */
          L_SQL_QUERY := 'ALTER SEQUENCE '||L_SEQUENCE_LIST(J) ||' INCREMENT BY ' || l_inc_list(J);
          CSM_UTIL_PKG.log(L_SQL_QUERY, 'CSM_HA_EVENT_PKG.SAVE_SEQUENCE',FND_LOG.LEVEL_STATEMENT);
          execute immediate L_SQL_QUERY;

        end if;
      END IF;

  END LOOP;

EXCEPTION WHEN OTHERS THEN
  /*** catch and log exceptions ***/
  CSM_UTIL_PKG.LOG
  ( 'Exception occurred in SAVE_SEQUENCE : ' ||   SUBSTR(SQLERRM,1,3000), 'CSM_HA_EVENT_PKG.SAVE_SEQUENCE',
    FND_LOG.LEVEL_EXCEPTION);
  RAISE;
END SAVE_SEQUENCE;

PROCEDURE MANAGE_MFS_CONC
IS
BEGIN

 UPDATE JTM_CON_REQUEST_DATA
 SET EXECUTE_FLAG='N'
 WHERE PRODUCT_CODE='CSM'
 AND CATEGORY='LOOKUP'
 AND (PACKAGE_NAME,PROCEDURE_NAME) NOT IN
  (('CSM_LOBS_EVENT_PKG','CONC_DOWNLOAD_ATTACHMENTS'));

END MANAGE_MFS_CONC;

PROCEDURE RECORD_MISC_DATA
IS
  l_PK_NAME_LIST  CSM_VARCHAR_LIST:=CSM_VARCHAR_LIST('');
  l_PK_TYPE_LIST  CSM_VARCHAR_LIST:=CSM_VARCHAR_LIST('');
  l_pk_value_list  CSM_VARCHAR_LIST:=CSM_VARCHAR_LIST('');

BEGIN

  CSM_UTIL_PKG.LOG('Recording Incident Links','CSM_HA_EVENT_PKG.RECORD_MISC_DATA', FND_LOG.LEVEL_PROCEDURE);
--CS_INCIDENT_LINKS

  l_pk_name_list(1):= 'LINK_ID';
  l_pk_type_list(1):= 'NUMBER';

  FOR rec IN (SELECT LINK_ID
              FROM CS_INCIDENT_LINKS
              WHERE CREATION_DATE >= G_HA_START_TIME)
  LOOP
   l_pk_value_list(1):=rec.LINK_ID;
   TRACK_HA_RECORD('CS_INCIDENT_LINKS',l_pk_name_list,l_pk_type_list,l_pk_value_list,'I','N');
  END LOOP;

  FOR rec IN (SELECT LINK_ID
              FROM CS_INCIDENT_LINKS
              WHERE CREATION_DATE < G_HA_START_TIME
			  AND LAST_UPDATE_DATE >= G_HA_START_TIME)
  LOOP
   l_pk_value_list(1):=rec.LINK_ID;
   TRACK_HA_RECORD('CS_INCIDENT_LINKS',l_pk_name_list,l_pk_type_list,l_pk_value_list,'U','N');
  END LOOP;

  CSM_UTIL_PKG.LOG('Recording Related Objects','CSM_HA_EVENT_PKG.RECORD_MISC_DATA', FND_LOG.LEVEL_PROCEDURE);
--CS_INCIDENT_LINKS_EXT

  l_pk_name_list(1):= 'LINK_ID';
  l_pk_type_list(1):= 'NUMBER';

  FOR rec IN (SELECT LINK_ID
              FROM CS_INCIDENT_LINKS_EXT
              WHERE CREATION_DATE >= G_HA_START_TIME)
  LOOP
   l_pk_value_list(1):=rec.LINK_ID;
   TRACK_HA_RECORD('CS_INCIDENT_LINKS_EXT',l_pk_name_list,l_pk_type_list,l_pk_value_list,'I','N');
  END LOOP;

  FOR rec IN (SELECT LINK_ID
              FROM CS_INCIDENT_LINKS
              WHERE CREATION_DATE < G_HA_START_TIME
			  AND LAST_UPDATE_DATE >= G_HA_START_TIME)
  LOOP
   l_pk_value_list(1):=rec.LINK_ID;
   TRACK_HA_RECORD('CS_INCIDENT_LINKS_EXT',l_pk_name_list,l_pk_type_list,l_pk_value_list,'U','N');
  END LOOP;


  CSM_UTIL_PKG.LOG('Recording CUG INCIDENT ATTRIBUTES Data','CSM_HA_EVENT_PKG.RECORD_MISC_DATA', FND_LOG.LEVEL_PROCEDURE);
--  CUG_INCIDNT_ATTR_VALS_B
  l_pk_name_list(1):= 'INCIDNT_ATTR_VAL_ID';
  l_pk_type_list(1):= 'NUMBER';

  FOR rec IN (SELECT INCIDNT_ATTR_VAL_ID
              FROM CUG_INCIDNT_ATTR_VALS_B
              WHERE CREATION_DATE >= G_HA_START_TIME)
  LOOP
   l_pk_value_list(1):=rec.INCIDNT_ATTR_VAL_ID;
   TRACK_HA_RECORD('CUG_INCIDNT_ATTR_VALS_B',l_pk_name_list,l_pk_type_list,l_pk_value_list,'I','N');
  END LOOP;

  FOR rec IN (SELECT INCIDNT_ATTR_VAL_ID
              FROM CUG_INCIDNT_ATTR_VALS_B
              WHERE CREATION_DATE < G_HA_START_TIME
			  AND LAST_UPDATE_DATE >= G_HA_START_TIME)
  LOOP
   l_pk_value_list(1):=rec.INCIDNT_ATTR_VAL_ID;
   TRACK_HA_RECORD('CUG_INCIDNT_ATTR_VALS_B',l_pk_name_list,l_pk_type_list,l_pk_value_list,'U','N');
  END LOOP;

  CSM_UTIL_PKG.LOG('Recording Access Hours','CSM_HA_EVENT_PKG.RECORD_MISC_DATA', FND_LOG.LEVEL_PROCEDURE);
--CSF_ACCESS_HOURS_B

  l_pk_name_list(1):= 'ACCESS_HOUR_ID';
  l_pk_type_list(1):= 'NUMBER';

  FOR rec IN (SELECT ACCESS_HOUR_ID
              FROM CSF_ACCESS_HOURS_B
              WHERE CREATION_DATE >= G_HA_START_TIME)
  LOOP
   l_pk_value_list(1):=rec.ACCESS_HOUR_ID;
   TRACK_HA_RECORD('CSF_ACCESS_HOURS_B',l_pk_name_list,l_pk_type_list,l_pk_value_list,'I','N');
  END LOOP;

  FOR rec IN (SELECT ACCESS_HOUR_ID
              FROM CSF_ACCESS_HOURS_B
              WHERE CREATION_DATE < G_HA_START_TIME
			  AND LAST_UPDATE_DATE >= G_HA_START_TIME)
  LOOP
   l_pk_value_list(1):=rec.ACCESS_HOUR_ID;
   TRACK_HA_RECORD('CSF_ACCESS_HOURS_B',l_pk_name_list,l_pk_type_list,l_pk_value_list,'U','N');
  END LOOP;

  CSM_UTIL_PKG.LOG('Recording Required Skills','CSM_HA_EVENT_PKG.RECORD_MISC_DATA', FND_LOG.LEVEL_PROCEDURE);
--CSF_REQUIRED_SKILLS_B

  l_pk_name_list(1):= 'REQUIRED_SKILL_ID';
  l_pk_type_list(1):= 'NUMBER';

  FOR rec IN (SELECT REQUIRED_SKILL_ID
              FROM CSF_REQUIRED_SKILLS_B
              WHERE CREATION_DATE >= G_HA_START_TIME)
  LOOP
   l_pk_value_list(1):=rec.REQUIRED_SKILL_ID;
   TRACK_HA_RECORD('CSF_REQUIRED_SKILLS_B',l_pk_name_list,l_pk_type_list,l_pk_value_list,'I','N');
  END LOOP;

  FOR rec IN (SELECT REQUIRED_SKILL_ID
              FROM CSF_REQUIRED_SKILLS_B
              WHERE CREATION_DATE < G_HA_START_TIME
			  AND LAST_UPDATE_DATE >= G_HA_START_TIME)
  LOOP
   l_pk_value_list(1):=rec.REQUIRED_SKILL_ID;
   TRACK_HA_RECORD('CSF_REQUIRED_SKILLS_B',l_pk_name_list,l_pk_type_list,l_pk_value_list,'U','N');
  END LOOP;

  CSM_UTIL_PKG.LOG('Recording MFS Data','CSM_HA_EVENT_PKG.RECORD_MISC_DATA', FND_LOG.LEVEL_PROCEDURE);

  RECORD_MFS_DATA;

END RECORD_MISC_DATA;

PROCEDURE END_SESSION
IS
BEGIN
    G_HA_SESSION_SEQUENCE := NULL;

    UPDATE CSM_HA_SESSION_INFO
    SET    SESSION_END_TIME = SYSTIMESTAMP,
           HA_PAYLOAD_END   = G_HA_PAYLOAD_SEQUENCE_END,
           STATUS           = 'COMPLETED',
           COMMENTS         = 'HA Recording session successfully completed.',
          LAST_UPDATE_DATE = SYSDATE,
          LAST_UPDATED_BY  = 1
    WHERE SESSION_ID = (SELECT MIN(SESSION_ID) FROM CSM_HA_SESSION_INFO WHERE SESSION_END_TIME IS NULL);

END END_SESSION;

PROCEDURE BEGIN_HA_TRACKING(x_RETURN_STATUS OUT NOCOPY VARCHAR2,
                            x_ERROR_MESSAGE OUT NOCOPY VARCHAR2)
IS
l_module VARCHAR2(500) :='Init';
BEGIN

   x_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
   x_ERROR_MESSAGE := 'HA Recording Successfully Started';

  IF GET_HA_PROFILE_VALUE = 'HA_RECORD' THEN
   CSM_UTIL_PKG.LOG( 'Call End HA Tracking to end existing session.',
                    'CSM_HA_EVENT_PKG.BEGIN_HA_TRACKING', FND_LOG.LEVEL_PROCEDURE);
   x_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
   x_ERROR_MESSAGE := 'Another Start HA Recording session is already in progress.';
   RETURN;
  END IF;

/* To limit concurrent requests: moved this to TOP */
   l_module := 'Setting HA profile to Record';
   SET_HA_PROFILE('HA_RECORD');

  /* SetUp recording*/
  CSM_UTIL_PKG.LOG( 'Assigning HA Responsibilities to FND Users with non-HA responsibilities',
                    'CSM_HA_EVENT_PKG.BEGIN_HA_TRACKING', FND_LOG.LEVEL_PROCEDURE);
  l_module := 'Assigning HA Responsibilities';

   ASSIGN_HA_RESPONSIBILITIES;
   COMMIT;


  CSM_UTIL_PKG.LOG( 'Deactivating non-HA and non-FND Responsibilities',
                    'CSM_HA_EVENT_PKG.BEGIN_HA_TRACKING', FND_LOG.LEVEL_PROCEDURE);
  l_module := 'Deactivating non-HA Responsibilities';

  DEACTIVATE_NON_HA_RESPS;
  COMMIT;

   CSM_UTIL_PKG.LOG('Managing Concurrent Programs',
                    'CSM_HA_EVENT_PKG.BEGIN_HA_TRACKING', FND_LOG.LEVEL_PROCEDURE);
  l_module := 'Managing HA Concurrent Programs';

  MANAGE_CONCURRENT_PROGRAMS;
  COMMIT;

   CSM_UTIL_PKG.LOG('Deactivating non-HA WF Components',
                    'CSM_HA_EVENT_PKG.BEGIN_HA_TRACKING', FND_LOG.LEVEL_PROCEDURE);
   l_module := 'Deactivating non-HA WF Components';

   DEACTIVATE_WF_COMPONENTS;
   COMMIT;


   CSM_UTIL_PKG.LOG('Managing JTM Concurrent Programs',
                    'CSM_HA_EVENT_PKG.BEGIN_HA_TRACKING', FND_LOG.LEVEL_PROCEDURE);
   l_module := 'Managing MFS Concurrent Programs';

   MANAGE_MFS_CONC;
   COMMIT;

   l_module := 'Creating a new HA session';
   SET_SESSION;

   COMMIT;
EXCEPTION
 WHEN OTHERS THEN
  /*** catch and log exceptions ***/
  CSM_UTIL_PKG.LOG
  ( 'Exception occurred in BEGIN_HA_TRACKING while '||l_module||':'||  SUBSTR(SQLERRM,1,3000), 'CSM_HA_EVENT_PKG.BEGIN_HA_TRACKING',
    FND_LOG.LEVEL_EXCEPTION);
  x_return_status := FND_API.G_RET_STS_ERROR;
  x_error_message := 'BEGIN_HA_TRACKING failed while '||l_module||' with error:' || SUBSTR(SQLERRM,1,3000) ;
  ROLLBACK;
  SET_HA_PROFILE('HA_STOP');
  RAISE;
END BEGIN_HA_TRACKING;

PROCEDURE END_HA_TRACKING(x_RETURN_STATUS OUT NOCOPY VARCHAR2,
                          x_ERROR_MESSAGE OUT NOCOPY VARCHAR2)
IS
l_module VARCHAR2(500):='Init';
BEGIN

    x_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
    x_ERROR_MESSAGE := 'Stop HA Recording Successfully Completed';
    G_IS_END_TRACKING_CALL := TRUE;

/*to limit concurrent requests: setting profile first */
   IF GET_HA_PROFILE_VALUE = 'HA_STOP' THEN
     CSM_UTIL_PKG.LOG('Another End recording is already in progress..',
                    'CSM_HA_EVENT_PKG.END_HA_TRACKING', FND_LOG.LEVEL_PROCEDURE);
     x_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
     x_ERROR_MESSAGE := 'Another Stop HA Recording is already in progress..';
	 RETURN;
   END IF;

    l_module := 'Setting HA profile to STOP';
    SET_HA_PROFILE('HA_STOP');

    SET_SESSION(false); -- to set global variables if not set in this DB session

    CSM_UTIL_PKG.LOG('Tracking FND attachments missed by LOOKUP program',
                    'CSM_HA_EVENT_PKG.END_HA_TRACKING', FND_LOG.LEVEL_PROCEDURE);
    l_module := 'Tracking FND attachments missed by LOOKUP program';

    TRACK_HA_ATTACHMENTS;   --it commits while end_tracking to improve perf

    CSM_UTIL_PKG.LOG('Recording Miscellaneous Data',
                    'CSM_HA_EVENT_PKG.END_HA_TRACKING', FND_LOG.LEVEL_PROCEDURE);
    l_module := 'Tracking Miscellaneous Data';

	RECORD_MISC_DATA;

    l_module := 'Saving Sequence Values of Business Objects';

    SELECT CSM_HA_PAYLOAD_DATA_S.nextval INTO G_HA_PAYLOAD_SEQUENCE_END FROM DUAL;

    SAVE_SEQUENCE(G_HA_SESSION_SEQUENCE,'R',G_HA_PAYLOAD_SEQUENCE_START,G_HA_PAYLOAD_SEQUENCE_END);


    CSM_UTIL_PKG.LOG('End Session with Id: '||G_HA_SESSION_SEQUENCE,
                    'CSM_HA_EVENT_PKG.END_HA_TRACKING', FND_LOG.LEVEL_PROCEDURE);
    l_module := 'Terminating Current Session';
    END_SESSION;

    G_IS_END_TRACKING_CALL := FALSE;
    COMMIT;
EXCEPTION
 WHEN OTHERS THEN
  /*** catch and log exceptions ***/
  CSM_UTIL_PKG.LOG
  ( 'Exception occurred in END_HA_TRACKING while '||l_module||':'||  SUBSTR(SQLERRM,1,3000), 'CSM_HA_EVENT_PKG.END_HA_TRACKING',
    FND_LOG.LEVEL_EXCEPTION);
  x_return_status := FND_API.G_RET_STS_ERROR;
  x_error_message := 'END_HA_TRACKING failed while '||l_module||' with error:' || SUBSTR(SQLERRM,1,3000) ;
  ROLLBACK;
  G_IS_END_TRACKING_CALL := FALSE;
  SET_HA_PROFILE('HA_RECORD');
  RAISE;
END END_HA_TRACKING;

FUNCTION get_listfrom_String(p_object_name IN VARCHAR2) return CSM_VARCHAR_LIST
IS
 l_temp VARCHAR2(1000);
 list CSM_VARCHAR_LIST:=CSM_VARCHAR_LIST();
 l_item1 VARCHAR2(500);
 l_item2 VARCHAR2(500);
 l_cnt NUMBER :=1;
BEGIN
 l_temp:=p_object_name;
 IF instr(l_temp,',') > 0 THEN
  LOOP
   l_item1 := trim(substr(l_temp,1,instr(l_temp,',')-1));
   list.extend(1);
   list(l_cnt) := l_item1;
   l_cnt := l_cnt+1;
   l_item2 := trim(substr(l_temp,instr(l_temp,',')+1));
   l_temp:= l_item2;
   EXIT WHEN instr(l_temp,',') = 0;
  END LOOP;
 ELSE
   l_item2:=l_temp;
 END IF;

  IF(length(l_item2)>0) THEN
   list.extend(1);
   list(l_cnt) := l_item2;
  END IF;

 RETURN list;

END get_listfrom_String;

FUNCTION get_pk_column_name(p_object_name IN VARCHAR2) return VARCHAR2
IS
CURSOR c_pk
 IS
 SELECT FOREIGN_KEY_COLUMN
 FROM CSM_HA_AUX_MAPPINGS
 WHERE BO_TABLE_NAME=AO_TABLE_NAME
 AND BO_TABLE_NAME=p_object_name
 AND AUX='N';

 l_pk VARCHAR2(500);
BEGIN

  OPEN c_pk;
  FETCH c_pk INTO l_pk;
  CLOSE c_pk;

  IF l_pk IS NOT NULL THEN
   RETURN l_pk;
  END IF;

  IF SUBSTR(p_object_name,-4)='_INQ' THEN
   RETURN 'CLID$$CS,TRANID$$,SEQNO$$';
  ELSIF p_object_name='CSM_AUTO_SYNC_NFN' THEN
   RETURN 'NOTIFICATION_ID';
  ELSIF p_object_name='CSM_DEFERRED_NFN_INFO' THEN
   RETURN 'TRACKING_ID';
  ELSIF p_object_name='CSM_SYNC_ERROR_NFN_INFO' THEN
   RETURN 'NOTIFICATION_ID';
  ELSIF p_object_name='MOBILEADMIN.C$ALL_CLIENTS' THEN
   RETURN 'CLIENTID';
  ELSIF p_object_name='MOBILEADMIN.C$SYNC_HISTORY' THEN
   RETURN 'SESSION_ID';
  ELSIF p_object_name='MOBILEADMIN.C$SYNC_HIS_PUB_ITEMS' THEN
   RETURN 'SESSION_ID,PUB_ITEM,PHASE';
  ELSIF p_object_name='ASG_USER' THEN
   RETURN 'USER_NAME';
  ELSIF p_object_name='ASG_DEFERRED_TRANINFO' THEN
   RETURN 'DEVICE_USER_NAME,DEFERRED_TRAN_ID,SEQUENCE';
  ELSIF p_object_name='ASG_USERS_INQINFO' THEN
   RETURN 'DEVICE_USER_NAME,TRANID';
  ELSIF p_object_name='ASG_USERS_INQARCHIVE' THEN
   RETURN 'DEVICE_USER_NAME,TRANID';
  ELSIF p_object_name='ASG_SEQUENCE_PARTITIONS' THEN
   RETURN 'CLIENTID,NAME';
  END IF;

RETURN NULL;

END get_pk_column_name;

FUNCTION get_predicate_clause(p_cols IN VARCHAR2,p_values IN VARCHAR2) return VARCHAR2
IS
 l_pk_col_list CSM_VARCHAR_LIST;
 l_pk_value_list CSM_VARCHAR_LIST;
 l_clause VARCHAR2(3000);
BEGIN
 l_pk_col_list:=get_listfrom_String(p_cols);
 l_pk_value_list:=get_listfrom_String(p_values);

 IF l_pk_col_list.COUNT=0 THEN
  RETURN NULL;
 END IF;

 l_clause:= ' WHERE '||l_pk_col_list(1)||'='''||l_pk_value_list(1)||''' ';

 FOR j IN 2..l_pk_col_list.COUNT
 LOOP
  l_clause:= l_clause||' AND '||l_pk_col_list(j)||'='''||l_pk_value_list(j)||''' ';
 END LOOP;

 RETURN l_clause;
END get_predicate_clause;

PROCEDURE TRACK_AUX_TABLE_RECORDS(p_parent_payload_id IN NUMBER)
IS
 l_ax_pk_column VARCHAR2(100);
 l_ax_pk_value  VARCHAR2(100);
 type t_curs is ref cursor;
 cur t_curs;

 l_bo_name VARCHAR2(100);
 l_pk_value VARCHAR2(100);

 l_PK_NAME_LIST  CSM_VARCHAR_LIST:=CSM_VARCHAR_LIST();
 l_PK_TYPE_LIST  CSM_VARCHAR_LIST:=CSM_VARCHAR_LIST();
 l_pk_value_list  CSM_VARCHAR_LIST:=CSM_VARCHAR_LIST();

BEGIN

 SELECT OBJECT_NAME,PK_VALUE INTO l_bo_name,l_pk_value
 FROM CSM_HA_PAYLOAD_DATA
 WHERE HA_PAYLOAD_ID=p_parent_payload_id;

 CSM_UTIL_PKG.LOG
       ( 'Check for aux with parent payload Id:'||p_parent_payload_id
	      ||' of TAB/PK:'||l_bo_name||'/'||l_pk_value,
        'CSM_HA_EVENT_PKG.TRACK_AUX_TABLE_RECORDS', FND_LOG.LEVEL_PROCEDURE);

 FOR rec IN (SELECT AO_TABLE_NAME,FETCH_SQL
             FROM CSM_HA_AUX_MAPPINGS
			 WHERE BO_TABLE_NAME=l_bo_name
			 AND AUX='Y'
			 AND BO_TABLE_NAME <> AO_TABLE_NAME
			 AND FETCH_SQL IS NOT NULL
			 AND ENABLED_FLAG='Y' ORDER BY AUX_MAPPING_ID)
 LOOP

      l_ax_pk_column := get_pk_column_name(rec.AO_TABLE_NAME);

      l_pk_name_list:=get_listfrom_String(l_ax_pk_column);
	  l_pk_type_list.extend(l_pk_name_list.COUNT);
	  FOR J IN 1..l_pk_name_list.COUNT
	  LOOP
       l_pk_type_list(J):='VARCHAR';
	  END LOOP;

      OPEN CUR FOR rec.FETCH_SQL USING l_pk_value;
      LOOP
        FETCH CUR INTO l_ax_pk_value;
        EXIT WHEN CUR%NOTFOUND;

        CSM_UTIL_PKG.LOG
        ( 'Tracking Aux table:'||rec.AO_TABLE_NAME||' with ('||l_ax_pk_column||')=('||l_ax_pk_value||')',
         'CSM_HA_EVENT_PKG.TRACK_AUX_TABLE_RECORDS', FND_LOG.LEVEL_PROCEDURE);

         l_pk_value_list := get_listfrom_String(l_ax_pk_value);

         TRACK_HA_RECORD(rec.AO_TABLE_NAME ,l_pk_name_list,l_pk_type_list,l_pk_value_list,'I','N',p_parent_payload_id);
      END LOOP;
	  CLOSE cur;
 END LOOP;

END TRACK_AUX_TABLE_RECORDS;

PROCEDURE TRACK_HA_RECORD(p_TABLE_NAME VARCHAR2,p_PK_NAME_LIST CSM_VARCHAR_LIST, p_PK_TYPE_LIST CSM_VARCHAR_LIST,p_PK_VALUE_LIST CSM_VARCHAR_LIST,
                          p_dml_type VARCHAR2,p_mobile_data VARCHAR2,p_parent_payload_id IN NUMBER)
IS
  l_XML_PAYLOAD CLOB;
  l_XML_CONTEXT CLOB;
  l_RETURN_STATUS VARCHAR2(100);
  l_ERROR_MESSAGE VARCHAR2(4000);
  l_tracking_ON varchar2(20);
  l_pk_values VARCHAR2(1000);
  l_pld_id NUMBER;
BEGIN


  l_pk_values:=get_stringfrom_list(p_PK_VALUE_LIST);

  CSM_UTIL_PKG.LOG
      ( 'Entering TRACK_HA_RECORD with '||p_TABLE_NAME||'-'||l_pk_values||'-'||p_dml_type||'-'||p_mobile_data||'-'||p_parent_payload_id ,
        'CSM_HA_EVENT_PKG.TRACK_HA_RECORD', FND_LOG.LEVEL_PROCEDURE);


  l_tracking_ON := GET_HA_PROFILE_VALUE;

  IF (NOT G_IS_END_TRACKING_CALL) AND (l_tracking_ON IS NULL OR l_tracking_ON <> 'HA_RECORD') THEN
       CSM_UTIL_PKG.LOG
      ( 'Leaving TRACK_HA_RECORD as tracking is switched OFF' , 'CSM_HA_EVENT_PKG.TRACK_HA_RECORD', FND_LOG.LEVEL_PROCEDURE);
	 RETURN;
  END IF;

  SET_SESSION(false);

  IF(G_HA_SESSION_SEQUENCE IS NULL) THEN   -- never happens
   CSM_UTIL_PKG.LOG
      ( 'No Open session found. Leaving without tracking.' ,
        'CSM_HA_EVENT_PKG.TRACK_HA_RECORD', FND_LOG.LEVEL_PROCEDURE);
   RETURN;
  END IF;

  GET_XML_PAYLOAD(p_TABLE_NAME,p_PK_NAME_LIST,p_PK_TYPE_LIST,p_PK_VALUE_LIST,l_XML_PAYLOAD,l_XML_CONTEXT,l_RETURN_STATUS,l_ERROR_MESSAGE);

  IF(l_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE_APPLICATION_ERROR(-20222,'HA Tracking failed :'||l_ERROR_MESSAGE);
  ELSE
    IF (l_XML_PAYLOAD IS NULL) THEN
     CSM_UTIL_PKG.LOG('PAYLOAD IS NULL', 'CSM_HA_EVENT_PKG.TRACK_HA_RECORD',FND_LOG.LEVEL_PROCEDURE);
     RAISE_APPLICATION_ERROR(-20222,'HA Tracking failed : XML Payload is null');
    END IF;


    SELECT CSM_HA_PAYLOAD_DATA_S.nextval INTO l_pld_id FROM DUAL;

    INSERT INTO CSM_HA_PAYLOAD_DATA(HA_PAYLOAD_ID ,OBJECT_NAME , PK_VALUE, PARENT_PAYLOAD_ID,DML_TYPE , PAYLOAD, CONTEXT ,MOBILE_DATA, PROCESSED ,
	STATUS ,COMMENTS ,CREATION_DATE , CREATED_BY , LAST_UPDATE_DATE  ,LAST_UPDATED_BY,LAST_UPDATE_LOGIN)
    VALUES(l_pld_id,p_TABLE_NAME,l_pk_values,NVL(p_parent_payload_id,l_pld_id),p_dml_type,xmltype(l_XML_PAYLOAD),xmltype(l_XML_CONTEXT),p_mobile_data,'N',NULL,NULL,SYSDATE,1,SYSDATE,1,1);

	CSM_HA_AUDIT_PKG.AUDIT_RECORD(l_pld_id,'RECORD');

	IF p_parent_payload_id IS NULL THEN
	 G_CURRENT_PAYLOAD_ID:=l_pld_id;
	END IF;

    IF(p_mobile_data='N' and p_PK_NAME_LIST.count=1) THEN
	 TRACK_AUX_TABLE_RECORDS(l_pld_id);
	END IF;
  END IF;

EXCEPTION
WHEN OTHERS THEN
   CSM_UTIL_PKG.LOG
  ( 'Exception occurred in TRACK_HA_RECORD -'  ||  SUBSTR(SQLERRM,1,3000), 'CSM_HA_EVENT_PKG.TRACK_HA_RECORD',FND_LOG.LEVEL_EXCEPTION);
   RAISE;
END TRACK_HA_RECORD;

PROCEDURE TRACK_HA_ATTACHMENTS
IS
 l_PK_NAME_LIST  CSM_VARCHAR_LIST:=CSM_VARCHAR_LIST('');
 l_PK_TYPE_LIST  CSM_VARCHAR_LIST:=CSM_VARCHAR_LIST('');
 l_pk_value_list  CSM_VARCHAR_LIST:=CSM_VARCHAR_LIST('');

 CURSOR c_last_run_date
 IS
  SELECT NVL(last_run_date,to_date(1,'J'))
  FROM jtm_con_request_data
  WHERE package_name =  'CSM_LOBS_EVENT_PKG'
  AND   procedure_name = 'CONC_DOWNLOAD_ATTACHMENTS';

 l_last_run_date DATE;

BEGIN

 SET_SESSION(false);
 IF G_HA_SESSION_SEQUENCE IS NULL THEN
   RETURN;
 END IF;

 OPEN c_last_run_date;
 FETCH c_last_run_date INTO l_last_run_date;
 CLOSE c_last_run_date;

 IF G_HA_START_TIME > l_last_run_date THEN
   l_last_run_date:= G_HA_START_TIME;
 END IF;

 FOR rec IN (SELECT DOCUMENT_ID FROM FND_DOCUMENTS a WHERE CREATION_DATE > l_last_run_date
             AND NOT EXISTS(SELECT 1 FROM CSM_HA_PAYLOAD_DATA b
			                WHERE HA_PAYLOAD_ID > G_HA_PAYLOAD_SEQUENCE_START
							AND   OBJECT_NAME='FND_DOCUMENTS'
							AND   PK_VALUE=to_char(a.DOCUMENT_ID)
							AND   DML_TYPE='I'))
 LOOP
  l_PK_NAME_LIST(1):='DOCUMENT_ID'; l_PK_TYPE_LIST(1):='NUMBER'; l_pk_value_list(1):= to_char(rec.DOCUMENT_ID);
  CSM_HA_EVENT_PKG.TRACK_HA_RECORD('FND_DOCUMENTS',l_PK_NAME_LIST,l_PK_TYPE_LIST,l_pk_value_list,'I');
 END LOOP;

 FOR rec IN (SELECT DOCUMENT_ID FROM FND_DOCUMENTS a WHERE CREATION_DATE < l_last_run_date
             AND LAST_UPDATE_DATE > l_last_run_date
             AND NOT EXISTS(SELECT 1 FROM CSM_HA_PAYLOAD_DATA b
			                WHERE HA_PAYLOAD_ID > G_HA_PAYLOAD_SEQUENCE_START
							AND   OBJECT_NAME='FND_DOCUMENTS'
							AND   PK_VALUE=to_char(a.DOCUMENT_ID)
							AND   DML_TYPE='U'))
 LOOP
  l_PK_NAME_LIST(1):='DOCUMENT_ID'; l_PK_TYPE_LIST(1):='NUMBER'; l_pk_value_list(1):= to_char(rec.DOCUMENT_ID);
  CSM_HA_EVENT_PKG.TRACK_HA_RECORD('FND_DOCUMENTS',l_PK_NAME_LIST,l_PK_TYPE_LIST,l_pk_value_list,'U');
 END LOOP;

 IF(G_IS_END_TRACKING_CALL) THEN
  COMMIT;
 END IF;

END TRACK_HA_ATTACHMENTS;

END CSM_HA_EVENT_PKG;

/
