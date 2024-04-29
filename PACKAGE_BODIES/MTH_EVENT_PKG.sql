--------------------------------------------------------
--  DDL for Package Body MTH_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MTH_EVENT_PKG" AS
/*$Header: mthevntb.pls 120.9.12010000.8 2009/09/03 06:01:53 yfeng noship $ */

p_event_actions ActionHandlerTableType;
p_action_statuses ActionStatusTableType;
num_status_rec NUMBER;

PROCEDURE handle_event(p_equipment_fk_key IN NUMBER,
                       p_event_type IN VARCHAR2,
                       p_Shift_workday_fk_key IN NUMBER,
                       p_Workorder_fk_key IN NUMBER,
                       p_Reading_time IN DATE,
                       p_reason_code IN VARCHAR2,
                       p_equip_status IN NUMBER,
                       p_event_description IN VARCHAR2)
AS
   l_event_id NUMBER := 0;

   BEGIN
     init_action_handler_rec;

     l_event_id := create_mth_event(p_equipment_fk_key,
                                    p_event_type,
                                    p_Shift_workday_fk_key,
                                    p_Workorder_fk_key,
                                    p_Reading_time,
                                    p_reason_code,
                                    p_equip_status,
                                    p_event_description);

     IF l_event_id = 0 THEN
        raise_application_error(-20001,'Fail to create event in MTH_EVENTS_D');
     END IF;

     action_handler_lookup(p_equipment_fk_key, p_event_type, p_reason_code, p_event_actions);

     IF p_event_actions.Count <> 0 THEN
        FOR j IN p_event_actions.FIRST .. p_event_actions.LAST
        LOOP

           init_action_status_rec;
           ACTION_HANDLER_DISPATCHER(l_event_id, p_event_actions(j), p_action_statuses);
           update_mth_event_action(l_event_id, p_action_statuses);
        END LOOP;
     END IF;

  exception
     when OTHERS
        then raise_application_error(-20000,'Unknown Exception in create_mth_event');

END handle_event;

PROCEDURE init_action_handler_rec
AS

BEGIN
  p_event_actions := ActionHandlerTableType();
END init_action_handler_rec;

PROCEDURE init_action_status_rec
AS

BEGIN
  p_action_statuses := ActionStatusTableType();
  num_status_rec:= 0;
END init_action_status_rec;


FUNCTION create_mth_event(p_equipment_fk_key IN NUMBER,
                          p_event_type IN VARCHAR2,
                          p_Shift_workday_fk_key IN NUMBER,
                          p_Workorder_fk_key IN NUMBER,
                          p_Reading_time IN DATE,
                          p_reason_code IN VARCHAR2,
                          p_equip_status IN NUMBER,
                          p_event_description IN VARCHAR2) RETURN NUMBER
AS
  l_event_id NUMBER := 0;

  BEGIN
     INSERT INTO MTH.MTH_EVENTS
       (EVENT_ID,EVENT_TYPE,EVENT_DESCRIPTION,REASON_CODE,TAG_READING_TIME,EQUIPMENT_FK_KEY,
        SHIFT_WORKDAY_FK_KEY,WORKORDER_FK_KEY,EQUIP_STATUS,
        CREATION_DATE, LAST_UPDATE_DATE,CREATION_SYSTEM_ID,LAST_UPDATE_SYSTEM_ID,CREATED_BY,
        LAST_UPDATE_LOGIN,LAST_UPDATED_BY)
     VALUES (mth.mth_events_d_seq.nextval, p_event_type, p_event_description, p_reason_code, p_reading_time, p_equipment_fk_key,
             p_shift_workday_fk_key, p_workorder_fk_key, p_equip_status, SYSDATE, SYSDATE, -1, -99999, -1,
             -99999, -99999);

     -- l_event_id := mth.mth_events_d_seq.CURRVAL;
     SELECT mth.mth_events_d_seq.CURRVAL INTO l_event_id FROM dual;


     -- commit the event generation no matter what SQL error caught
     COMMIT;
  RETURN l_event_id;

  exception
     when OTHERS THEN
        raise_application_error(-20001,'Unknown Exception in create_mth_event');
        RETURN l_event_id;

END create_mth_event;

PROCEDURE ACTION_HANDLER_LOOKUP (p_equipment_fk_key IN NUMBER,
                                 p_event_type IN VARCHAR2,
                                 p_reason_code IN VARCHAR2,
               	                 p_event_actions OUT NOCOPY ActionHandlerTableType)
AS
   l_event_actions ActionHandlerTableType := ActionHandlerTableType();
   l_event_action_rec ActionHandlerRec;
   l_rec NUMBER := 0;

   CURSOR cur
   IS
      SELECT A.PERSONNEL_FK_KEY, A.EMAIL_NOTIFICATION, A.MOBILE_NOTIFICATION,
             A.ACTION_TYPE_CODE,
             CASE WHEN  A.ACTION_HANDLER_CODE IS NOT NULL THEN
                      DECODE( A.ACTION_HANDLER_CODE, A.ACTION_HANDLER_CODE,
                             (SELECT B.DESCRIPTION FROM FND_LOOKUPS B
                              WHERE B.LOOKUP_CODE = A.ACTION_HANDLER_CODE
                              AND B.LOOKUP_TYPE IN ('MTH_CUSTOM_PLSQL_API','MTH_CUSTOM_WS_API') ))
            END AS ACTION_HANLDER_API, A.DOMAIN_NAME
       FROM MTH.MTH_EVENT_ACTION_SETUP A, MTH.MTH_EVENT_SETUP C, MTH.MTH_PERSONNEL_D D
      WHERE A.EVENT_SETUP_ID = C.EVENT_SETUP_ID
        AND C.EVENT_TYPE_CODE = p_event_type
        AND C.EQUIPMENT_FK_KEY = p_equipment_fk_key
        AND A.PERSONNEL_FK_KEY = D.PERSONNEL_PK_KEY (+)
        AND SYSDATE BETWEEN Nvl(D.EFFECTIVE_START_DATE, SYSDATE) AND Nvl(D.EFFECTIVE_END_DATE, SYSDATE)
        AND Nvl(C.REASON_CODE,'x') = Nvl(p_reason_code,'x');

   BEGIN
      OPEN cur;
      LOOP
          FETCH cur INTO l_event_action_rec;
          EXIT WHEN cur%NOTFOUND;
          l_event_actions.extend;
          l_rec := l_rec + 1;
          l_event_actions(l_rec) := l_event_action_rec;

      END LOOP;
      CLOSE cur;
      p_event_actions := l_event_actions;

EXCEPTION
    WHEN OTHERS THEN
       raise_application_error(-20002,'Unknown Exception to get Action Handler');

END ACTION_HANDLER_LOOKUP;


PROCEDURE ACTION_HANDLER_DISPATCHER (p_event_id IN NUMBER,
                                     p_event_action_rec IN ActionHandlerRec,
                                     p_action_statuses OUT NOCOPY ActionStatusTableType)
AS
   plsql_method_not_defined EXCEPTION;
   l_action_statuses ActionStatusTableType := ActionStatusTableType();
   l_action_status_rec ActionStatusRec;

BEGIN
   CASE p_event_action_rec.action_type_code
       WHEN 'NOTIFICATION' THEN
            BEGIN
                INVOKE_EVENT_NOTIFICATION(p_event_id, p_event_action_rec, p_action_statuses);
            END;
       WHEN 'EAM_WR' THEN
            BEGIN
                INVOKE_EVENT_EAM_WR(p_event_id, p_event_action_rec, p_action_statuses);
            END;
       WHEN 'PLSQL_API' THEN
            IF p_event_action_rec.action_handler_api IS NULL OR
                Length(p_event_action_rec.Action_Handler_API) = 0 THEN
               RAISE plsql_method_not_defined;
            ELSE
               BEGIN
                 INVOKE_EVENT_PLSQL_API(p_event_id, p_event_action_rec, p_action_statuses);
               END;
            END IF;
       WHEN 'BPEL' THEN
            IF p_event_action_rec.action_handler_api IS NULL OR
                Length(p_event_action_rec.Action_Handler_API) = 0 THEN
               RAISE plsql_method_not_defined;
            ELSE
               BEGIN
                  INVOKE_EVENT_BPEL(p_event_id, p_event_action_rec, p_action_statuses);
               END;
            END IF;
       ELSE
            RAISE plsql_method_not_defined;
     END CASE;

EXCEPTION
    WHEN plsql_method_not_defined THEN
       l_action_status_rec.action_type_code := p_event_action_rec.action_type_code;
       l_action_status_rec.action_status := 'Failed to process action due to API not found';
       l_action_status_rec.action_handler_api := p_event_action_rec.action_handler_api;
       l_action_statuses.extend;
       num_status_rec:=num_status_rec+1;
       l_action_statuses(num_status_rec) := l_action_status_rec;
       p_action_statuses := l_action_statuses;

    WHEN OTHERS THEN
       l_action_status_rec.action_type_code := p_event_action_rec.action_type_code;
       l_action_status_rec.action_status := 'Failed to process Custom API. An error was encountered - '||SQLCODE||' -ERROR- '||SQLERRM;
       l_action_status_rec.action_handler_api := p_event_action_rec.action_handler_api;
       l_action_statuses.extend;
       num_status_rec:=num_status_rec+1;
       l_action_statuses(num_status_rec) := l_action_status_rec;
       p_action_statuses := l_action_statuses;


END  ACTION_HANDLER_DISPATCHER;


PROCEDURE UPDATE_MTH_EVENT_ACTION (p_event_id IN NUMBER,
                                   p_action_statuses IN ActionStatusTableType)
AS
   l_action_status_rec ActionStatusRec;

BEGIN

   IF p_action_statuses.Count <> 0 THEN

      FOR j IN p_action_statuses.FIRST .. p_action_statuses.LAST
      LOOP
          l_action_status_rec := p_action_statuses(j);

          INSERT INTO MTH.MTH_EVENT_ACTIONS
             (EVENT_ID, ACTION_TYPE_CODE, LINE_NUM, NOTIFICATION_ID, NOTIFICATION_CONTENT, ACTION_REFERENCE_ID,
              ACTION_STATUS, ACTION_HANDLER_API, CREATION_DATE, LAST_UPDATE_DATE, CREATION_SYSTEM_ID, LAST_UPDATE_SYSTEM_ID)
          VALUES (p_event_id, l_action_status_rec.action_type_code, j,
                  l_action_status_rec.notification_id,
                  l_action_status_rec.notification_content,
                  l_action_status_rec.action_reference_id,
                  l_action_status_rec.action_status,
                  l_action_status_rec.action_handler_api,
                  SYSDATE, SYSDATE, -99999,-99999);

      END LOOP;
   END IF;

   -- commit the event actions
   COMMIT;

  EXCEPTION
      WHEN OTHERS THEN
         raise_application_error(-20003,'Unknown Exception to Insert MTH_EVENT_ACTIONS');

END UPDATE_MTH_EVENT_ACTION;


PROCEDURE INVOKE_EVENT_NOTIFICATION(p_event_id IN NUMBER,
                                    p_event_action_rec IN ActionHandlerRec,
                                    p_action_statuses OUT NOCOPY ActionStatusTableType)
AS
   l_email_id MTH.MTH_EVENT_ACTIONS.NOTIFICATION_ID%TYPE;
   l_mobile_id MTH.MTH_EVENT_ACTIONS.NOTIFICATION_ID%TYPE;
   l_subject VARCHAR2(100);
   l_content VARCHAR2(1000);
   l_status VARCHAR2(1024);
   l_equip_name VARCHAR2(60);
   l_event_type VARCHAR2(120);
   l_event_description VARCHAR2(1024);
   l_event_time VARCHAR2(24);
   l_action_statuses ActionStatusTableType := ActionStatusTableType();
   l_action_status_rec ActionStatusRec;
   mailaddress_not_defined EXCEPTION;

BEGIN

   SELECT b.equipment_name, a.event_type, a.event_description, To_Char(a.creation_date,'yyyy.mm.dd hh24:mi:ss')
     INTO l_equip_name, l_event_type, l_event_description, l_event_time
     FROM MTH.MTH_EVENTS a, MTH.MTH_EQUIPMENTS_D b
    WHERE a.event_id = p_event_id
      AND a.equipment_fk_key = b.equipment_pk_key;

   IF p_event_action_rec.person_fk_key IS NOT NULL
   THEN
       IF p_event_action_rec.email_notification = 'Y' OR
            p_event_action_rec.email_notification = '1'
       THEN
          SELECT email_address
           INTO l_email_id
           FROM MTH_PERSONNEL_D
          WHERE personnel_pk_key = p_event_action_rec.person_fk_key;

          l_subject := 'Alert! Equipment :'|| l_equip_name ||' , ' || 'Event Type : ' || l_event_type ;
	        l_content := 'Event condition :' || l_event_description || ' and Time of event : ' || l_event_time ;

          IF l_email_id IS NULL OR Length(l_email_id) = 0 OR InStr(l_email_id,'@') = 0
          THEN
             RAISE mailaddress_not_defined;
          ELSE
             l_status := send_notification(l_email_id, l_subject, l_content);
             l_action_status_rec.action_type_code := p_event_action_rec.action_type_code;
             l_action_status_rec.notification_id := l_email_id;
             l_action_status_rec.notification_content := l_content;
             l_action_status_rec.action_status := l_status;
             l_action_status_rec.action_handler_api := 'MTH_EVENT_PKG.INVOKE_EVENT_NOTIFICATION';
             l_action_statuses.extend;
             num_status_rec := num_status_rec + 1;
             l_action_statuses(num_status_rec) := l_action_status_rec;
          END IF;
       END IF;

       IF p_event_action_rec.mobile_notification = 'Y' OR
            p_event_action_rec.mobile_notification = '1'
       THEN
          SELECT mobile_phone_number
           INTO l_mobile_id
           FROM MTH_PERSONNEL_D
          WHERE personnel_pk_key = p_event_action_rec.person_fk_key;

          IF l_mobile_id IS NULL OR Length(l_mobile_id) = 0
          THEN
             RAISE mailaddress_not_defined;
          ELSE
             l_mobile_id := l_mobile_id||p_event_action_rec.domain_name;
             l_status := send_notification(l_mobile_id, l_subject, l_content);
             l_action_status_rec.action_type_code := p_event_action_rec.action_type_code;
             l_action_status_rec.notification_id := l_mobile_id;
             l_action_status_rec.notification_content := l_content;
             l_action_status_rec.action_status := l_status;
             l_action_status_rec.action_handler_api := 'MTH_EVENT_PKG.INVOKE_EVENT_NOTIFICATION';
             l_action_statuses.extend;
             num_status_rec := num_status_rec + 1;
             l_action_statuses(num_status_rec) := l_action_status_rec;
          END IF;
       END IF;
   END IF;
   p_action_statuses := l_action_statuses;

   EXCEPTION
     WHEN mailaddress_not_defined THEN
       l_action_status_rec.action_type_code := p_event_action_rec.action_type_code;
       l_action_status_rec.action_status := 'Failed to process notification. Please setup email address or mobile number.';
       l_action_status_rec.action_handler_api := 'MTH_EVENT_PKG.INVOKE_EVENT_NOTIFICATION';
       l_action_statuses.extend;
       num_status_rec:=num_status_rec+1;
       l_action_statuses(num_status_rec) := l_action_status_rec;
       p_action_statuses := l_action_statuses;

     WHEN OTHERS THEN
        raise_application_error(-20003,'An error was encountered - '||SQLCODE||' -ERROR- '||SQLERRM);

END INVOKE_EVENT_NOTIFICATION;

FUNCTION SEND_NOTIFICATION(p_send_to varchar2,
                           p_subject varchar2,
                           p_text varchar2 ) RETURN VARCHAR2
AS
   --l_mailhost    VARCHAR2(64) := 'mail.oracle.com';
   --l_mailport    NUMBER := 25;
   l_mailhost    VARCHAR2(64) := fnd_profile.value('MTH_MAIL_SERVER_NAME');
   /* The defaul mail server port usually is 25 by industry standard.
      If port number is not set, should not affect sending notification.*/
   l_mailport    NUMBER := Nvl(fnd_profile.value('MTH_MAIL_SERVER_PORT'),25);
   l_mail_conn   UTL_SMTP.connection;
   l_mesg        VARCHAR2(1000);
   l_flag        NUMBER := 0;
   crlf          CONSTANT VARCHAR2(2):= fnd_global.local_chr(13) ||
                                        fnd_global.local_chr(10);

BEGIN
   IF l_mailhost IS NOT NULL AND Length(l_mailhost) <> 0
   THEN
       l_mail_conn := UTL_SMTP.open_connection(l_mailhost, l_mailport);
       l_mesg := 'Date: ' || TO_CHAR( SYSDATE, 'dd Mon yy hh24:mi:ss') || crlf ||
                 'From: '|| NVL(fnd_profile.value('MTH_NOTIFICATION_DISPLAY_NAME'), 'Default User') || crlf ||
                 'Subject: '|| p_subject || crlf ||
                 'To: '||p_send_to || crlf || '' || crlf || p_text;

       UTL_SMTP.helo(l_mail_conn, l_mailhost);
       UTL_SMTP.mail(l_mail_conn, p_send_to);
       UTL_SMTP.rcpt(l_mail_conn, p_send_to);
       utl_smtp.open_data(l_mail_conn);
       utl_smtp.write_data(l_mail_conn, l_mesg);
       utl_smtp.close_data(l_mail_conn);
       UTL_SMTP.quit(l_mail_conn);

       RETURN 'Succeeded';
   ELSE
       RETURN 'Failed to send notification due to no configruation of mail server.';
   END IF;

  EXCEPTION
     WHEN UTL_SMTP.INVALID_OPERATION THEN
          RETURN 'Failed due to Invalid Operation in Mail attempt using UTL_SMTP.';
     WHEN UTL_SMTP.TRANSIENT_ERROR THEN
          RETURN 'Failed due to Temporary e-mail issue - try again';
     WHEN UTL_SMTP.PERMANENT_ERROR THEN
          RETURN 'Failed due to Permanent Error Encountered.';
     WHEN OTHERS THEN
          RETURN 'Failed due to Other errors occurs.';

END SEND_NOTIFICATION;

PROCEDURE INVOKE_EVENT_EAM_WR(p_event_id IN NUMBER,
                              p_event_action_rec IN ActionHandlerRec,
                              p_action_statuses OUT NOCOPY ActionStatusTableType)
AS
   l_work_request_id NUMBER;
   l_return_status VARCHAR2(50);
   l_msg_count NUMBER;
   l_msg_data VARCHAR2(50);
   l_api_version NUMBER := 1.0;
   l_init_msg_list VARCHAR2(100) := FND_API.G_FALSE;
   l_commit VARCHAR2(100) := FND_API.G_TRUE;
   l_validation_level NUMBER := FND_API.G_VALID_LEVEL_FULL;
   l_mode VARCHAR2(50) := 'CREATE';
   l_request_log VARCHAR2(10) := '';
   l_user_id NUMBER := -1;
   l_serial_number MTH_ASSET_MST.SERIAL_NUMBER%TYPE;
   l_organization_id WIP_EAM_WORK_REQUESTS.ORGANIZATION_ID%TYPE;
   l_asset_number WIP_EAM_WORK_REQUESTS.ASSET_NUMBER%TYPE;
   l_asset_group WIP_EAM_WORK_REQUESTS.ASSET_GROUP%TYPE;
   l_action_statuses ActionStatusTableType := ActionStatusTableType();
   l_action_status_rec ActionStatusRec;
   serial_number_not_found EXCEPTION;
   asset_info_not_found EXCEPTION;
   source_service_not_found EXCEPTION;
   l_source_location  VARCHAR2(100) := fnd_profile.value('MTH_OWB_SOURCE_LOCATION');
   l_source_service VARCHAR2(100) := fnd_profile.value('MTH_SOURCE_DB_SERVICE_NAME');
   l_dblink VARCHAR2(400);
   l_sql VARCHAR2(4000);
   l_schema_name VARCHAR2(50);

   CURSOR cur_wr
   IS
     SELECT b.serial_number, d.ebs_organization_id, c.ASSET_NUMBER, c.ASSET_GROUP_ID
       FROM MTH.MTH_EVENTS a, MTH.MTH_EQUIPMENTS_D b, MTH.MTH_ASSET_MST c, MTH.MTH_ORGANIZATIONS_L d
      WHERE a.event_id = p_event_id
        AND a.equipment_fk_key = b.equipment_pk_key
        AND d.ORGANIZATION_CODE = c.maintenance_org_code
        AND b.serial_number = c.serial_number (+);

   CURSOR get_db_link (source_service VARCHAR2, source_location VARCHAR2)
   IS
       SELECT db_link
       FROM user_db_links
       WHERE Upper(db_link) like Upper(source_service||'%@'||source_location);

BEGIN

   l_schema_name := USER;

   OPEN cur_wr;
   LOOP
       FETCH cur_wr INTO l_serial_number, l_organization_id, l_asset_number, l_asset_group;
       EXIT WHEN cur_wr%NOTFOUND;

       IF l_serial_number IS NULL THEN
          RAISE serial_number_not_found;
       END IF;

       IF l_asset_number IS NULL OR
          l_organization_id IS NULL OR
          l_asset_group IS NULL
       THEN
          RAISE asset_info_not_found;
       END IF;

       OPEN  get_db_link(l_source_service, l_source_location);
       FETCH  get_db_link INTO l_dblink;
       CLOSE get_db_link;

       IF l_dblink IS NULL THEN
          RAISE source_service_not_found;
       END IF;

       EXECUTE IMMEDIATE
              'BEGIN MSC_MTH_INCR_LOAD_PKG.MTH_INVOKE_EAM_WORK_REQUEST@'||l_dblink||'(:1, :2, :3, :4); END; '
           USING p_event_id, l_asset_number, l_asset_group, l_organization_id;

       l_sql := 'SELECT WORK_REQUEST_ID ' ||
                ' FROM WIP_EAM_WORK_REQUESTS@'||l_dblink||
                ' WHERE ASSET_NUMBER = :1 ' ||
                ' AND ASSET_GROUP = :2 ' ||
                ' AND ORGANIZATION_ID = :3 ' ||
                ' AND DESCRIPTION = :4 ';

       BEGIN
         EXECUTE IMMEDIATE l_sql INTO l_work_request_id
            USING l_asset_number, l_asset_group,  l_organization_id, 'moc_event_id_'||p_event_id;
       EXCEPTION
          WHEN No_Data_Found THEN
            l_return_status := 'Failed';
       END;

       IF l_work_request_id IS NOT NULL THEN
          l_return_status := 'Succeeded';
       ELSE
          l_return_status := 'Failed';
       END IF;

       l_action_status_rec.action_type_code := p_event_action_rec.action_type_code;
       l_action_status_rec.action_reference_id := l_work_request_id;
       l_action_status_rec.action_status := l_return_status;
       l_action_status_rec.action_handler_api := 'WIP_EAM_WORKREQUEST_PUB.WORK_REQUEST_IMPORT';
       l_action_statuses.extend;
       num_status_rec := num_status_rec + 1;
       l_action_statuses(num_status_rec) := l_action_status_rec;
   END LOOP;
   CLOSE cur_wr;
   p_action_statuses := l_action_statuses;

EXCEPTION
   WHEN serial_number_not_found THEN
       l_action_status_rec.action_type_code := p_event_action_rec.action_type_code;
       l_action_status_rec.action_status := 'Failed to invoke EAM_WR due to Serial Number Not Found.';
       l_action_status_rec.action_handler_api := 'MTH_EVENT_PKG.INVOKE_EVENT_EAM_WR';
       l_action_statuses.extend;
       num_status_rec := num_status_rec + 1;
       l_action_statuses(num_status_rec) := l_action_status_rec;
       p_action_statuses := l_action_statuses;

   WHEN asset_info_not_found THEN
       l_action_status_rec.action_type_code := p_event_action_rec.action_type_code;
       l_action_status_rec.action_status := 'Failed to invoke EAM_WR due to Asset Information Not Found.';
       l_action_status_rec.action_handler_api := 'MTH_EVENT_PKG.INVOKE_EVENT_EAM_WR';
       l_action_statuses.extend;
       num_status_rec := num_status_rec + 1;
       l_action_statuses(num_status_rec) := l_action_status_rec;
       p_action_statuses := l_action_statuses;

   WHEN source_service_not_found THEN
       l_action_status_rec.action_type_code := p_event_action_rec.action_type_code;
       l_action_status_rec.action_status := 'Failed to creat EAM WR due to Source Service is not available.';
       l_action_status_rec.action_handler_api := 'MTH_EVENT_PKG.INVOKE_EVENT_EAM_WR';
       l_action_statuses.extend;
       num_status_rec := num_status_rec + 1;
       l_action_statuses(num_status_rec) := l_action_status_rec;
       p_action_statuses := l_action_statuses;

  WHEN OTHERS THEN
       l_action_status_rec.action_type_code := p_event_action_rec.action_type_code;
       l_action_status_rec.action_status := 'An error was encountered - '||SQLCODE||' -ERROR- '||SQLERRM;
       l_action_status_rec.action_handler_api := 'MTH_EVENT_PKG.INVOKE_EVENT_EAM_WR';
       l_action_statuses.extend;
       num_status_rec := num_status_rec + 1;
       l_action_statuses(num_status_rec) := l_action_status_rec;
       p_action_statuses := l_action_statuses;

END INVOKE_EVENT_EAM_WR;

PROCEDURE INVOKE_EVENT_PLSQL_API(p_event_id IN NUMBER,
                                 p_event_action_rec IN ActionHandlerRec,
                                 p_action_statuses OUT NOCOPY ActionStatusTableType)
AS
   l_action_statuses ActionStatusTableType := ActionStatusTableType();
   l_action_status_rec ActionStatusRec;
   l_return_status VARCHAR2(1024);

BEGIN

   EXECUTE IMMEDIATE
         'BEGIN ' ||
             p_event_action_rec.action_handler_api || '(:1, :2); END;'
       USING IN p_event_id, OUT l_return_status;

   l_action_status_rec.action_type_code := p_event_action_rec.action_type_code;
   l_action_status_rec.action_status := l_return_status;
   l_action_status_rec.action_handler_api := p_event_action_rec.action_handler_api;
   l_action_statuses.extend;
   num_status_rec := num_status_rec + 1;
   l_action_statuses(num_status_rec) := l_action_status_rec;
   p_action_statuses := l_action_statuses;

EXCEPTION
   WHEN OTHERS THEN
       l_action_status_rec.action_type_code := p_event_action_rec.action_type_code;
       l_action_status_rec.action_status := 'An error was encountered - '||SQLCODE||' -ERROR- '||SQLERRM;
       l_action_status_rec.action_handler_api := p_event_action_rec.action_handler_api;
       l_action_statuses.extend;
       num_status_rec := num_status_rec + 1;
       l_action_statuses(num_status_rec) := l_action_status_rec;
       p_action_statuses := l_action_statuses;


END INVOKE_EVENT_PLSQL_API;

PROCEDURE INVOKE_EVENT_BPEL(p_event_id IN NUMBER,
                            p_event_action_rec IN ActionHandlerRec,
                            p_action_statuses OUT NOCOPY ActionStatusTableType)
AS
   l_action_statuses ActionStatusTableType := ActionStatusTableType();
   l_action_status_rec ActionStatusRec;
   l_return    VARCHAR2(30000);
   l_url          VARCHAR2(30000);
   l_namespace    VARCHAR2(30000);
   l_action       VARCHAR2(30000);
   l_ws_operation NUMBER;
BEGIN

   IF p_event_action_rec.action_handler_api IS NOT NULL OR Length(p_event_action_rec.action_handler_api) <> 0
   THEN
      l_url := SubStr(p_event_action_rec.action_handler_api,
                      InStr(p_event_action_rec.action_handler_api, 'URL=')+4,
                      InStr(p_event_action_rec.action_handler_api,',')-(InStr(p_event_action_rec.action_handler_api, 'URL=')+4));
      l_namespace := SubStr(p_event_action_rec.action_handler_api, InStr(p_event_action_rec.action_handler_api, 'NameSpace=')+10);
      l_ws_operation := InStr(p_event_action_rec.action_handler_api, 'Operation=');

      IF l_ws_operation = 0 THEN
         l_action := 'process';
      ELSE
         l_action := SubStr(p_event_action_rec.action_handler_api, InStr(p_event_action_rec.action_handler_api, 'Operation=')+10);
      END IF;


      IF (l_url IS NOT NULL AND Length(l_url) <> 0) AND
          (l_namespace IS NOT NULL AND Length(l_namespace) <> 0)
      THEN
         -- invoke HTTP Request
         l_return := invoke_http_request(p_event_id => p_event_id,
                                         p_url     => l_url,
                                         p_namespace  => l_namespace,
                                         p_action => l_action);

         l_action_status_rec.action_type_code := p_event_action_rec.action_type_code;
         l_action_status_rec.action_status := l_return;
         l_action_status_rec.action_handler_api := p_event_action_rec.action_handler_api;
         l_action_statuses.extend;
         num_status_rec := num_status_rec + 1;
         l_action_statuses(num_status_rec) := l_action_status_rec;
      END IF;
   END IF;
   p_action_statuses := l_action_statuses;

END INVOKE_EVENT_BPEL;

FUNCTION invoke_http_request(p_event_id   IN NUMBER,
                             p_url        IN VARCHAR2,
                             p_namespace  IN VARCHAR2,
                             p_action     IN VARCHAR2) RETURN VARCHAR2
AS
-- ---------------------------------------------------------------------
  soap_request varchar2(30000);
  soap_respond varchar2(30000);
  l_proxy_server VARCHAR2(100) := fnd_profile.value('MTH_SOA_PROXY_SERVER');
  --l_proxy_server VARCHAR2(100) := 'www-proxy.us.oracle.com';
  l_action VARCHAR2(100);
  http_req utl_http.req;
  http_resp utl_http.resp;
  launch_url varchar2(240) ;
  l_returned_status varchar2(1024);
  l_from NUMBER;
  l_end NUMBER;

BEGIN
  -- Set proxy details if no direct net connection.
  IF l_proxy_server IS NULL THEN
     RETURN 'Failed to process BPEL due to no proxy server setting.';
  END IF;

  UTL_HTTP.set_proxy(l_proxy_server, NULL);
  --UTL_HTTP.set_persistent_conn_support(TRUE);

  soap_request:= '<?xml version="1.0" encoding="UTF-8"?>
                 <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
                 <soap:Header/>
                 <soap:Body xmlns:ns1="'||p_namespace||'">'||
                 '<ns1:event_id>'||To_Char(p_event_id)||'</ns1:event_id>'||
                 '</soap:Body></soap:Envelope>';

  http_req:= utl_http.begin_request(p_url,'POST','HTTP/1.0');
  utl_http.set_header(http_req, 'Content-Type', 'text/xml') ;
  utl_http.set_header(http_req, 'Content-Length', length(soap_request)) ;

  --utl_http.set_header(http_req, 'SOAPAction', 'initiate');
  utl_http.set_header(http_req, 'SOAPAction', p_action);
  utl_http.write_text(http_req, soap_request) ;
  http_resp:= utl_http.get_response(http_req) ;
  utl_http.read_text(http_resp, soap_respond) ;
  utl_http.end_response(http_resp) ;

  soap_respond := REPLACE(soap_respond,' ','');

  l_from := InStr(SubStr(soap_respond, instr (soap_respond, '<return_status')), '>');
  l_end := instr(SubStr(soap_respond, instr (soap_respond, '<return_status')), '</return_status>');

  l_returned_status := SubStr(SubStr(soap_respond, instr (soap_respond, '<return_status')),l_from+1,l_end-l_from-1);

  IF l_returned_status IS NULL OR Length(l_returned_status) = 0 THEN
     l_returned_status := 'Failed';
  END IF;

  RETURN l_returned_status;

  EXCEPTION
     WHEN UTL_HTTP.INIT_FAILED THEN
          RETURN 'Initialization of the HTTP-callout subsystem fails.';
     WHEN UTL_HTTP.REQUEST_FAILED THEN
          RETURN 'The HTTP call fails due to Network problem.';
     WHEN OTHERS THEN
          RETURN 'Failed to process HTTP Request due to Other errors occurs.';

END invoke_http_request;

END MTH_EVENT_PKG;

/
