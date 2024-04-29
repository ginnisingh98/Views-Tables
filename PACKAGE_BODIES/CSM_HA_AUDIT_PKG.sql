--------------------------------------------------------
--  DDL for Package Body CSM_HA_AUDIT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_HA_AUDIT_PKG" AS
/* $Header: csmhadtb.pls 120.0.12010000.1 2010/04/08 06:38:17 saradhak noship $*/

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

PROCEDURE AUDIT_RECORD(p_ha_payload_id IN NUMBER, p_audit_type IN VARCHAR2)
IS
PRAGMA AUTONOMOUS_TRANSACTION;
  l_audit_id NUMBER;
  l_XML_PAYLOAD CLOB :=NULL;
  l_session_id NUMBER;
  l_tab_name VARCHAR2(100);
  l_XML_CONTEXT CLOB:=NULL;
  l_dml VARCHAR2(1);
  l_mobile_data VARCHAR2(1);
  l_RETURN_STATUS VARCHAR2(100);
  l_ERROR_MESSAGE VARCHAR2(4000):='';

 CURSOR c_get_sess
 IS
 SELECT SESSION_ID FROM CSM_HA_SESSION_INFO
 WHERE p_ha_payload_id BETWEEN HA_PAYLOAD_START AND HA_PAYLOAD_END;

 CURSOR c_get_details
 IS
 SELECT OBJECT_NAME,PK_VALUE,DML_TYPE,MOBILE_DATA
 FROM CSM_HA_PAYLOAD_DATA
 WHERE HA_PAYLOAD_ID=p_ha_payload_id;

 l_PK_NAME_LIST  CSM_VARCHAR_LIST:=CSM_VARCHAR_LIST();
 l_PK_TYPE_LIST  CSM_VARCHAR_LIST:=CSM_VARCHAR_LIST();
 l_pk_value_list  CSM_VARCHAR_LIST:=CSM_VARCHAR_LIST();

 l_pk_name VARCHAR2(500);
 l_pk_value VARCHAR2(1000);
BEGIN

 select CSM_HA_AUDIT_S.nextval INTO l_audit_id from dual;

 IF p_audit_type='APPLY' THEN
    OPEN c_get_sess;
	FETCH c_get_sess INTO l_session_id;
	CLOSE c_get_sess;

    OPEN c_get_details;
	FETCH c_get_details INTO l_tab_name,l_pk_value,l_dml,l_mobile_data;
	CLOSE c_get_details;

    IF l_dml='U' AND l_mobile_data='N' THEN
	  l_pk_name:=CSM_HA_EVENT_PKG.GET_PK_COLUMN_NAME(l_tab_name);
	  l_pk_name_list := get_listfrom_String(l_pk_name);
	  l_pk_value_list:= get_listfrom_String(l_pk_value);
	  l_pk_type_list.extend(l_pk_name_list.COUNT);

	  FOR I IN 1..l_pk_name_list.COUNT
	  LOOP
	  	  l_pk_type_list(I):='VARCHAR';
	  END LOOP;

      IF l_pk_name_list.COUNT =0 THEN
	    CSM_UTIL_PKG.log('COULD NOT EXTRACT OLD PAYLOAD as no PK column name found for ' || l_tab_name
    	                 , 'CSM_HA_AUDIT_PKG.AUDIT_RECORD', FND_LOG.LEVEL_PROCEDURE);
	  ELSE
        CSM_HA_EVENT_PKG.GET_XML_PAYLOAD(l_tab_name,l_PK_NAME_LIST,l_PK_TYPE_LIST,l_PK_VALUE_LIST,
                   l_XML_PAYLOAD,l_XML_CONTEXT,l_RETURN_STATUS,l_ERROR_MESSAGE);
      END IF;
    END IF;

 ELSE
   l_session_id:=CSM_HA_EVENT_PKG.G_HA_SESSION_SEQUENCE;
 END IF;

 INSERT INTO CSM_HA_AUDIT(HA_AUDIT_ID,SESSION_ID,HA_PAYLOAD_ID, AUDIT_TYPE, AUDIT_TIMESTAMP,OLD_PAYLOAD,
 CREATION_DATE,CREATED_BY,LAST_UPDATE_DATE,LAST_UPDATED_BY,LAST_UPDATE_LOGIN)
 VALUES(l_audit_id,l_session_id,p_ha_payload_id,p_audit_type,systimestamp,DECODE(p_audit_type,'APPLY',xmltype(l_xml_payload)),sysdate,1,sysdate,1,1);

 COMMIT;
EXCEPTION
 WHEN OTHERS THEN
 l_ERROR_MESSAGE :=SUBSTR(SQLERRM,1,3000)||SUBSTR(l_ERROR_MESSAGE,1,999);
CSM_UTIL_PKG.LOG('Exception occurred in AUDIT_RECORD -'  ||l_ERROR_MESSAGE ,
   'CSM_HA_EVENT_PKG.AUDIT_RECORD',FND_LOG.LEVEL_EXCEPTION);
  COMMIT;
  RAISE;
END AUDIT_RECORD;

END CSM_HA_AUDIT_PKG;


/
