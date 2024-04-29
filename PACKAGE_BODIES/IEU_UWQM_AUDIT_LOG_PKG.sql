--------------------------------------------------------
--  DDL for Package Body IEU_UWQM_AUDIT_LOG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEU_UWQM_AUDIT_LOG_PKG" as
/* $Header: IEUVUALB.pls 120.0 2005/06/02 15:54:02 appldev noship $ */
procedure INSERT_ROW (
P_ACTION_KEY			IN VARCHAR2,
P_EVENT_KEY			IN VARCHAR2,
P_MODULE			IN VARCHAR2,
P_WS_CODE			IN VARCHAR2,
P_APPLICATION_ID		IN VARCHAR2,
P_WORKITEM_PK_ID		IN VARCHAR2,
P_WORKITEM_OBJ_CODE		IN VARCHAR2,
P_WORK_ITEM_STATUS_PREV		IN VARCHAR2,
P_WORK_ITEM_STATUS_CURR		IN VARCHAR2,
P_OWNER_ID_PREV			IN NUMBER,
P_OWNER_ID_CURR			IN NUMBER,
P_OWNER_TYPE_PREV		IN VARCHAR2,
P_OWNER_TYPE_CURR		IN VARCHAR2,
P_ASSIGNEE_ID_PREV		IN NUMBER,
P_ASSIGNEE_ID_CURR		IN NUMBER,
P_ASSIGNEE_TYPE_PREV		IN VARCHAR2,
P_ASSIGNEE_TYPE_CURR		IN VARCHAR2,
P_SOURCE_OBJECT_ID_PREV		IN NUMBER,
P_SOURCE_OBJECT_ID_CURR		IN NUMBER,
P_SOURCE_OBJECT_TYPE_CODE_PREV  IN VARCHAR2,
P_SOURCE_OBJECT_TYPE_CODE_CURR  IN VARCHAR2,
P_PARENT_WORKITEM_STATUS_PREV	IN VARCHAR2,
P_PARENT_WORKITEM_STATUS_CURR	IN VARCHAR2,
P_PARENT_DIST_STATUS_PREV	IN VARCHAR2,
P_PARENT_DIST_STATUS_CURR	IN VARCHAR2,
P_WORKITEM_DIST_STATUS_PREV	IN VARCHAR2,
P_WORKITEM_DIST_STATUS_CURR	IN VARCHAR2,
P_PRIORITY_PREV			IN VARCHAR2,
P_PRIORITY_CURR			IN VARCHAR2,
P_DUE_DATE_PREV			IN DATE,
P_DUE_DATE_CURR			IN DATE,
P_RESCHEDULE_TIME_PREV		IN DATE,
P_RESCHEDULE_TIME_CURR		IN DATE,
P_IEU_COMMENT_CODE1		IN VARCHAR2,
P_IEU_COMMENT_CODE2		IN VARCHAR2,
P_IEU_COMMENT_CODE3		IN VARCHAR2,
P_IEU_COMMENT_CODE4		IN VARCHAR2,
P_IEU_COMMENT_CODE5		IN VARCHAR2,
P_WORKITEM_COMMENT_CODE1	IN VARCHAR2,
P_WORKITEM_COMMENT_CODE2	IN VARCHAR2,
P_WORKITEM_COMMENT_CODE3	IN VARCHAR2,
P_WORKITEM_COMMENT_CODE4	IN VARCHAR2,
P_WORKITEM_COMMENT_CODE5	IN VARCHAR2,
P_STATUS			IN VARCHAR2,
P_ERROR_CODE			IN VARCHAR2,
X_AUDIT_LOG_ID			OUT NOCOPY NUMBER,
x_msg_data			OUT NOCOPY VARCHAR2,
x_return_status			OUT NOCOPY VARCHAR2

) is

l_work_item_number VARCHAR2(100);
l_audit_log_val VARCHAR2(100);

begin

 l_audit_log_val := FND_PROFILE.VALUE('IEU_WR_DIST_AUDIT_LOG');

  BEGIN

    SELECT WORK_ITEM_NUMBER
    INTO   L_WORK_ITEM_NUMBER
    FROM   IEU_UWQM_ITEMS
    WHERE  WORKITEM_PK_ID = P_WORKITEM_PK_ID
    AND    WORKITEM_OBJ_CODE = P_WORKITEM_OBJ_CODE;

  EXCEPTION
     WHEN OTHERS THEN
      l_work_item_number := null;
  END;

  insert into IEU_UWQM_AUDIT_LOG
  (	AUDIT_LOG_ID,
        OBJECT_VERSION_NUMBER,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN,
	ACTION_KEY,
	EVENT_KEY,
	MODULE,
	WS_CODE,
	APPLICATION_ID,
	WORKITEM_PK_ID,
	WORKITEM_OBJ_CODE,
	WORK_ITEM_NUMBER,
	WORKITEM_STATUS_ID_PREV,
	WORKITEM_STATUS_ID_CURR,
	OWNER_ID_PREV,
	OWNER_ID_CURR,
	OWNER_TYPE_PREV,
	OWNER_TYPE_CURR,
	ASSIGNEE_ID_PREV,
	ASSIGNEE_ID_CURR,
	ASSIGNEE_TYPE_PREV,
	ASSIGNEE_TYPE_CURR,
	SOURCE_OBJECT_ID_PREV,
	SOURCE_OBJECT_ID_CURR,
	SOURCE_OBJECT_TYPE_CODE_PREV,
	SOURCE_OBJECT_TYPE_CODE_CURR,
	PARENT_WORKITEM_STATUS_ID_PREV,
	PARENT_WORKITEM_STATUS_ID_CURR,
	PARENT_DIST_STATUS_ID_PREV,
	PARENT_DIST_STATUS_ID_CURR,
	WORKITEM_DIST_STATUS_ID_PREV,
	WORKITEM_DIST_STATUS_ID_CURR,
	PRIORITY_ID_PREV,
	PRIORITY_ID_CURR,
	DUE_DATE_PREV,
	DUE_DATE_CURR,
	RESCHEDULE_TIME_PREV,
	RESCHEDULE_TIME_CURR,
	IEU_COMMENT_CODE1,
	IEU_COMMENT_CODE2,
	IEU_COMMENT_CODE3,
	IEU_COMMENT_CODE4,
	IEU_COMMENT_CODE5,
	WORKITEM_COMMENT_CODE1,
	WORKITEM_COMMENT_CODE2,
	WORKITEM_COMMENT_CODE3,
	WORKITEM_COMMENT_CODE4,
	WORKITEM_COMMENT_CODE5,
	RETURN_STATUS,
	ERROR_CODE,
	LOGGING_LEVEL)
  values
	(
	IEU_UWQM_AUDIT_LOG_S1.NEXTVAL,
        1,
        FND_GLOBAL.USER_ID,
        SYSDATE,
        FND_GLOBAL.USER_ID,
        SYSDATE,
        FND_GLOBAL.LOGIN_ID,
	P_ACTION_KEY,
	P_EVENT_KEY,
	P_MODULE,
	P_WS_CODE,
	P_APPLICATION_ID,
	P_WORKITEM_PK_ID,
	P_WORKITEM_OBJ_CODE,
	L_WORK_ITEM_NUMBER,
	P_WORK_ITEM_STATUS_PREV,
	P_WORK_ITEM_STATUS_CURR,
	P_OWNER_ID_PREV,
	P_OWNER_ID_CURR,
	P_OWNER_TYPE_PREV,
	P_OWNER_TYPE_CURR,
	P_ASSIGNEE_ID_PREV,
	P_ASSIGNEE_ID_CURR,
	P_ASSIGNEE_TYPE_PREV,
	P_ASSIGNEE_TYPE_CURR,
	P_SOURCE_OBJECT_ID_PREV,
	P_SOURCE_OBJECT_ID_CURR,
	P_SOURCE_OBJECT_TYPE_CODE_PREV,
	P_SOURCE_OBJECT_TYPE_CODE_CURR,
	P_PARENT_WORKITEM_STATUS_PREV,
	P_PARENT_WORKITEM_STATUS_CURR,
	P_PARENT_DIST_STATUS_PREV,
	P_PARENT_DIST_STATUS_CURR,
	P_WORKITEM_DIST_STATUS_PREV,
	P_WORKITEM_DIST_STATUS_CURR,
	P_PRIORITY_PREV,
	P_PRIORITY_CURR,
	P_DUE_DATE_PREV,
	P_DUE_DATE_CURR,
	P_RESCHEDULE_TIME_PREV,
	P_RESCHEDULE_TIME_CURR,
	P_IEU_COMMENT_CODE1,
	P_IEU_COMMENT_CODE2,
	P_IEU_COMMENT_CODE3,
	P_IEU_COMMENT_CODE4,
	P_IEU_COMMENT_CODE5,
	P_WORKITEM_COMMENT_CODE1,
	P_WORKITEM_COMMENT_CODE2,
	P_WORKITEM_COMMENT_CODE3,
	P_WORKITEM_COMMENT_CODE4,
	P_WORKITEM_COMMENT_CODE5,
	P_STATUS,
	P_ERROR_CODE,
	l_audit_log_val) RETURNING AUDIT_LOG_ID INTO X_AUDIT_LOG_ID;


end INSERT_ROW;

procedure UPDATE_ROW (
P_AUDIT_LOG_ID			IN NUMBER,
P_ACTION_KEY			IN VARCHAR2,
P_EVENT_KEY			IN VARCHAR2,
P_MODULE			IN VARCHAR2,
P_WS_CODE			IN VARCHAR2,
P_APPLICATION_ID		IN VARCHAR2,
P_WORKITEM_PK_ID		IN VARCHAR2,
P_WORKITEM_OBJ_CODE		IN VARCHAR2,
P_WORK_ITEM_STATUS_PREV		IN VARCHAR2,
P_WORK_ITEM_STATUS_CURR		IN VARCHAR2,
P_OWNER_ID_PREV			IN NUMBER,
P_OWNER_ID_CURR			IN NUMBER,
P_OWNER_TYPE_PREV		IN VARCHAR2,
P_OWNER_TYPE_CURR		IN VARCHAR2,
P_ASSIGNEE_ID_PREV		IN NUMBER,
P_ASSIGNEE_ID_CURR		IN NUMBER,
P_ASSIGNEE_TYPE_PREV		IN VARCHAR2,
P_ASSIGNEE_TYPE_CURR		IN VARCHAR2,
P_SOURCE_OBJECT_ID_PREV		IN NUMBER,
P_SOURCE_OBJECT_ID_CURR		IN NUMBER,
P_SOURCE_OBJECT_TYPE_CODE_PREV  IN VARCHAR2,
P_SOURCE_OBJECT_TYPE_CODE_CURR  IN VARCHAR2,
P_PARENT_WORKITEM_STATUS_PREV	IN VARCHAR2,
P_PARENT_WORKITEM_STATUS_CURR	IN VARCHAR2,
P_PARENT_DIST_STATUS_PREV	IN VARCHAR2,
P_PARENT_DIST_STATUS_CURR	IN VARCHAR2,
P_WORKITEM_DIST_STATUS_PREV	IN VARCHAR2,
P_WORKITEM_DIST_STATUS_CURR	IN VARCHAR2,
P_PRIORITY_PREV			IN VARCHAR2,
P_PRIORITY_CURR			IN VARCHAR2,
P_DUE_DATE_PREV			IN DATE,
P_DUE_DATE_CURR			IN DATE,
P_RESCHEDULE_TIME_PREV		IN DATE,
P_RESCHEDULE_TIME_CURR		IN DATE,
P_IEU_COMMENT_CODE1		IN VARCHAR2,
P_IEU_COMMENT_CODE2		IN VARCHAR2,
P_IEU_COMMENT_CODE3		IN VARCHAR2,
P_IEU_COMMENT_CODE4		IN VARCHAR2,
P_IEU_COMMENT_CODE5		IN VARCHAR2,
P_WORKITEM_COMMENT_CODE1	IN VARCHAR2,
P_WORKITEM_COMMENT_CODE2	IN VARCHAR2,
P_WORKITEM_COMMENT_CODE3	IN VARCHAR2,
P_WORKITEM_COMMENT_CODE4	IN VARCHAR2,
P_WORKITEM_COMMENT_CODE5	IN VARCHAR2,
P_STATUS			IN VARCHAR2,
P_ERROR_CODE			IN VARCHAR2
) is

l_audit_log_val VARCHAR2(100);

begin

 l_audit_log_val := FND_PROFILE.VALUE('IEU_WR_DIST_AUDIT_LOG');

  UPDATE IEU_UWQM_AUDIT_LOG
  SET
        CREATED_BY		    =   FND_GLOBAL.USER_ID,
        CREATION_DATE		    =   SYSDATE,
        LAST_UPDATED_BY		    =   FND_GLOBAL.USER_ID,
        LAST_UPDATE_DATE	    =   SYSDATE,
        LAST_UPDATE_LOGIN	    =   FND_GLOBAL.LOGIN_ID,
        OBJECT_VERSION_NUMBER	    =   OBJECT_VERSION_NUMBER + 1,
	ACTION_KEY                  =   P_ACTION_KEY,
	EVENT_KEY                   =   P_EVENT_KEY,
	MODULE                      =   P_MODULE,
	WS_CODE                     =   P_WS_CODE,
	APPLICATION_ID              =   P_APPLICATION_ID,
	WORKITEM_STATUS_ID_PREV     =   P_WORK_ITEM_STATUS_PREV,
	WORKITEM_STATUS_ID_CURR     =   P_WORK_ITEM_STATUS_CURR,
	OWNER_ID_PREV               =   P_OWNER_ID_PREV	,
	OWNER_ID_CURR               =   P_OWNER_ID_CURR,
	OWNER_TYPE_PREV             =   P_OWNER_TYPE_PREV,
	OWNER_TYPE_CURR             =   P_OWNER_TYPE_CURR,
	ASSIGNEE_ID_PREV            =   P_ASSIGNEE_ID_PREV,
	ASSIGNEE_ID_CURR            =   P_ASSIGNEE_ID_CURR,
	ASSIGNEE_TYPE_PREV          =   P_ASSIGNEE_TYPE_PREV,
	ASSIGNEE_TYPE_CURR          =   P_ASSIGNEE_TYPE_CURR,
	SOURCE_OBJECT_ID_PREV       =   P_SOURCE_OBJECT_ID_PREV,
	SOURCE_OBJECT_ID_CURR       =   P_SOURCE_OBJECT_ID_CURR,
	SOURCE_OBJECT_TYPE_CODE_PREV =   P_SOURCE_OBJECT_TYPE_CODE_PREV,
	SOURCE_OBJECT_TYPE_CODE_CURR =   P_SOURCE_OBJECT_TYPE_CODE_CURR,
	PARENT_WORKITEM_STATUS_ID_PREV =   P_PARENT_WORKITEM_STATUS_PREV,
	PARENT_WORKITEM_STATUS_ID_CURR =   P_PARENT_WORKITEM_STATUS_CURR,
	PARENT_DIST_STATUS_ID_PREV  =   P_PARENT_DIST_STATUS_PREV,
	PARENT_DIST_STATUS_ID_CURR  =   P_PARENT_DIST_STATUS_CURR,
	WORKITEM_DIST_STATUS_ID_PREV   =   P_WORKITEM_DIST_STATUS_PREV,
	WORKITEM_DIST_STATUS_ID_CURR   =   P_WORKITEM_DIST_STATUS_CURR,
	PRIORITY_ID_PREV               =   P_PRIORITY_PREV,
	PRIORITY_ID_CURR               =   P_PRIORITY_CURR,
	DUE_DATE_PREV               =   P_DUE_DATE_PREV,
	DUE_DATE_CURR               =   P_DUE_DATE_CURR,
	RESCHEDULE_TIME_PREV        =   P_RESCHEDULE_TIME_PREV,
	RESCHEDULE_TIME_CURR        =   P_RESCHEDULE_TIME_CURR,
	IEU_COMMENT_CODE1           =   P_IEU_COMMENT_CODE1,
	IEU_COMMENT_CODE2           =   P_IEU_COMMENT_CODE2,
	IEU_COMMENT_CODE3           =   P_IEU_COMMENT_CODE3,
	IEU_COMMENT_CODE4           =   P_IEU_COMMENT_CODE4,
	IEU_COMMENT_CODE5           =   P_IEU_COMMENT_CODE5,
	WORKITEM_COMMENT_CODE1      =   P_WORKITEM_COMMENT_CODE1,
	WORKITEM_COMMENT_CODE2      =   P_WORKITEM_COMMENT_CODE2,
	WORKITEM_COMMENT_CODE3      =   P_WORKITEM_COMMENT_CODE3,
	WORKITEM_COMMENT_CODE4      =   P_WORKITEM_COMMENT_CODE4,
	WORKITEM_COMMENT_CODE5      =   P_WORKITEM_COMMENT_CODE5,
	RETURN_STATUS               =   P_STATUS,
	ERROR_CODE                  =   P_ERROR_CODE,
	LOGGING_LEVEL		    =   L_AUDIT_LOG_VAL
   WHERE
        AUDIT_LOG_ID		    =   P_AUDIT_LOG_ID
   AND	WORKITEM_PK_ID              =   P_WORKITEM_PK_ID
   AND  WORKITEM_OBJ_CODE	    =   P_WORKITEM_OBJ_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

PROCEDURE LOAD_ROW (
P_AUDIT_LOG_ID			IN NUMBER,
P_ACTION_KEY			IN VARCHAR2,
P_EVENT_KEY			IN VARCHAR2,
P_MODULE			IN VARCHAR2,
P_WS_CODE			IN VARCHAR2,
P_APPLICATION_ID		IN VARCHAR2,
P_WORKITEM_PK_ID		IN VARCHAR2,
P_WORKITEM_OBJ_CODE		IN VARCHAR2,
P_WORK_ITEM_STATUS_PREV		IN VARCHAR2,
P_WORK_ITEM_STATUS_CURR		IN VARCHAR2,
P_OWNER_ID_PREV			IN NUMBER,
P_OWNER_ID_CURR			IN NUMBER,
P_OWNER_TYPE_PREV		IN VARCHAR2,
P_OWNER_TYPE_CURR		IN VARCHAR2,
P_ASSIGNEE_ID_PREV		IN NUMBER,
P_ASSIGNEE_ID_CURR		IN NUMBER,
P_ASSIGNEE_TYPE_PREV		IN VARCHAR2,
P_ASSIGNEE_TYPE_CURR		IN VARCHAR2,
P_SOURCE_OBJECT_ID_PREV		IN NUMBER,
P_SOURCE_OBJECT_ID_CURR		IN NUMBER,
P_SOURCE_OBJECT_TYPE_CODE_PREV  IN VARCHAR2,
P_SOURCE_OBJECT_TYPE_CODE_CURR  IN VARCHAR2,
P_PARENT_WORKITEM_STATUS_PREV	IN VARCHAR2,
P_PARENT_WORKITEM_STATUS_CURR	IN VARCHAR2,
P_PARENT_DIST_STATUS_PREV	IN VARCHAR2,
P_PARENT_DIST_STATUS_CURR	IN VARCHAR2,
P_WORKITEM_DIST_STATUS_PREV	IN VARCHAR2,
P_WORKITEM_DIST_STATUS_CURR	IN VARCHAR2,
P_PRIORITY_PREV			IN VARCHAR2,
P_PRIORITY_CURR			IN VARCHAR2,
P_DUE_DATE_PREV			IN DATE,
P_DUE_DATE_CURR			IN DATE,
P_RESCHEDULE_TIME_PREV		IN DATE,
P_RESCHEDULE_TIME_CURR		IN DATE,
P_IEU_COMMENT_CODE1		IN VARCHAR2,
P_IEU_COMMENT_CODE2		IN VARCHAR2,
P_IEU_COMMENT_CODE3		IN VARCHAR2,
P_IEU_COMMENT_CODE4		IN VARCHAR2,
P_IEU_COMMENT_CODE5		IN VARCHAR2,
P_WORKITEM_COMMENT_CODE1	IN VARCHAR2,
P_WORKITEM_COMMENT_CODE2	IN VARCHAR2,
P_WORKITEM_COMMENT_CODE3	IN VARCHAR2,
P_WORKITEM_COMMENT_CODE4	IN VARCHAR2,
P_WORKITEM_COMMENT_CODE5	IN VARCHAR2,
P_STATUS			IN VARCHAR2,
P_ERROR_CODE			IN VARCHAR2,
x_msg_data			OUT NOCOPY VARCHAR2,
x_return_status			OUT NOCOPY VARCHAR2
) is

L_AUDIT_LOG_ID NUMBER;

 begin
   UPDATE_ROW(
	P_AUDIT_LOG_ID,
	P_ACTION_KEY,
	P_EVENT_KEY,
	P_MODULE,
	P_WS_CODE,
	P_APPLICATION_ID,
	P_WORKITEM_PK_ID,
	P_WORKITEM_OBJ_CODE,
	P_WORK_ITEM_STATUS_PREV,
	P_WORK_ITEM_STATUS_CURR,
	P_OWNER_ID_PREV,
	P_OWNER_ID_CURR,
	P_OWNER_TYPE_PREV,
	P_OWNER_TYPE_CURR,
	P_ASSIGNEE_ID_PREV,
	P_ASSIGNEE_ID_CURR,
	P_ASSIGNEE_TYPE_PREV,
	P_ASSIGNEE_TYPE_CURR,
	P_SOURCE_OBJECT_ID_PREV,
	P_SOURCE_OBJECT_ID_CURR,
	P_SOURCE_OBJECT_TYPE_CODE_PREV,
	P_SOURCE_OBJECT_TYPE_CODE_CURR,
	P_PARENT_WORKITEM_STATUS_PREV,
	P_PARENT_WORKITEM_STATUS_CURR,
	P_PARENT_DIST_STATUS_PREV,
	P_PARENT_DIST_STATUS_CURR,
	P_WORKITEM_DIST_STATUS_PREV,
	P_WORKITEM_DIST_STATUS_CURR,
	P_PRIORITY_PREV,
	P_PRIORITY_CURR,
	P_DUE_DATE_PREV,
	P_DUE_DATE_CURR,
	P_RESCHEDULE_TIME_PREV,
	P_RESCHEDULE_TIME_CURR,
	P_IEU_COMMENT_CODE1,
	P_IEU_COMMENT_CODE2,
	P_IEU_COMMENT_CODE3,
	P_IEU_COMMENT_CODE4,
	P_IEU_COMMENT_CODE5,
	P_WORKITEM_COMMENT_CODE1,
	P_WORKITEM_COMMENT_CODE2,
	P_WORKITEM_COMMENT_CODE3,
	P_WORKITEM_COMMENT_CODE4,
	P_WORKITEM_COMMENT_CODE5,
	P_STATUS,
	P_ERROR_CODE
	);

   If SQL%NOTFOUND then
     raise no_data_found;
   end if;
 Exception
   when no_data_found then
   INSERT_ROW(
	P_ACTION_KEY,
	P_EVENT_KEY,
	P_MODULE,
	P_WS_CODE,
	P_APPLICATION_ID,
	P_WORKITEM_PK_ID,
	P_WORKITEM_OBJ_CODE,
	P_WORK_ITEM_STATUS_PREV,
	P_WORK_ITEM_STATUS_CURR,
	P_OWNER_ID_PREV,
	P_OWNER_ID_CURR,
	P_OWNER_TYPE_PREV,
	P_OWNER_TYPE_CURR,
	P_ASSIGNEE_ID_PREV,
	P_ASSIGNEE_ID_CURR,
	P_ASSIGNEE_TYPE_PREV,
	P_ASSIGNEE_TYPE_CURR,
	P_SOURCE_OBJECT_ID_PREV,
	P_SOURCE_OBJECT_ID_CURR,
	P_SOURCE_OBJECT_TYPE_CODE_PREV,
	P_SOURCE_OBJECT_TYPE_CODE_CURR,
	P_PARENT_WORKITEM_STATUS_PREV,
	P_PARENT_WORKITEM_STATUS_CURR,
	P_PARENT_DIST_STATUS_PREV,
	P_PARENT_DIST_STATUS_CURR,
	P_WORKITEM_DIST_STATUS_PREV,
	P_WORKITEM_DIST_STATUS_CURR,
	P_PRIORITY_PREV,
	P_PRIORITY_CURR,
	P_DUE_DATE_PREV,
	P_DUE_DATE_CURR,
	P_RESCHEDULE_TIME_PREV,
	P_RESCHEDULE_TIME_CURR,
	P_IEU_COMMENT_CODE1,
	P_IEU_COMMENT_CODE2,
	P_IEU_COMMENT_CODE3,
	P_IEU_COMMENT_CODE4,
	P_IEU_COMMENT_CODE5,
	P_WORKITEM_COMMENT_CODE1,
	P_WORKITEM_COMMENT_CODE2,
	P_WORKITEM_COMMENT_CODE3,
	P_WORKITEM_COMMENT_CODE4,
	P_WORKITEM_COMMENT_CODE5,
	P_STATUS,
	P_ERROR_CODE,
	L_AUDIT_LOG_ID,
	x_msg_data,
        x_return_status
	);

END LOAD_ROW;

procedure DELETE_ROW (
 P_WS_CODE IN VARCHAR2
) is
begin
  delete from IEU_UWQM_AUDIT_LOG
  where WS_CODE = P_WS_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

end IEU_UWQM_AUDIT_LOG_PKG;

/