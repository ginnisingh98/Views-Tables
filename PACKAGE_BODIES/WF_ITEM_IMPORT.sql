--------------------------------------------------------
--  DDL for Package Body WF_ITEM_IMPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_ITEM_IMPORT" as
/* $Header: WFHAIMPB.pls 120.2 2005/10/18 12:44:55 mfisher ship $ */

-- Removes all trace of rows related to X_Item_type/X_Item_key from
-- Runtime tables

procedure erase(X_Item_type VARCHAR2, X_Item_key VARCHAR2) is

begin
   -- wf_notification_attributes
   delete from wf_notification_attributes
   where rowid in
      (select row_id
	 from wf_ha_ntfa_v v
        where v.Item_type = X_Item_type
	  and v.Item_key = X_Item_key);

   -- wf_notifications
   delete from wf_notifications
   where rowid in
      (select row_id
         from wf_ha_ntf_v v
        where v.Item_type = X_Item_type
          and v.Item_key = X_Item_key);

   -- wf_item_activity_statuses
   delete from wf_item_activity_statuses
   where Item_type = X_Item_type
     and Item_key = X_Item_key;

   -- wf_item_activity_statuses_h
   delete from wf_item_activity_statuses_h
   where Item_type = X_Item_type
     and Item_key = X_Item_key;

   -- wf_item_attributes
   delete from wf_item_attribute_values
      where Item_type = X_Item_type
     and Item_key = X_Item_key;

   -- wf_items
   delete from wf_items
      where Item_type = X_Item_type
     and Item_key = X_Item_key;
end;


-- repopulates WF_ITEMS
procedure import_item_row(
 X_ITEM_TYPE VARCHAR2,
 X_ITEM_KEY  VARCHAR2,
 X_ROOT_ACTIVITY VARCHAR2,
 X_ROOT_ACTIVITY_VERSION NUMBER,
 X_OWNER_ROLE VARCHAR2,
 X_PARENT_ITEM_TYPE VARCHAR2,
 X_PARENT_ITEM_KEY VARCHAR2,
 X_PARENT_CONTEXT VARCHAR2,
 X_BEGIN_DATE DATE,
 X_END_DATE DATE,
 X_USER_KEY VARCHAR2,
 X_HA_MIGRATION_FLAG VARCHAR2) is

begin
    insert into WF_ITEMS
    (ITEM_TYPE, ITEM_KEY, ROOT_ACTIVITY, ROOT_ACTIVITY_VERSION,
     OWNER_ROLE, PARENT_ITEM_TYPE, PARENT_ITEM_KEY, PARENT_CONTEXT,
     BEGIN_DATE, END_DATE, USER_KEY, HA_MIGRATION_FLAG)
     select X_ITEM_TYPE, X_ITEM_KEY, X_ROOT_ACTIVITY, X_ROOT_ACTIVITY_VERSION,
     X_OWNER_ROLE, X_PARENT_ITEM_TYPE, X_PARENT_ITEM_KEY, X_PARENT_CONTEXT,
     X_BEGIN_DATE, X_END_DATE, X_USER_KEY, X_HA_MIGRATION_FLAG
     from dual;
end;

-- repopulates WF_ITEM_ATTRIBUTE_VALUES
procedure import_item_attr_row(
 X_ITEM_TYPE VARCHAR2,
 X_ITEM_KEY  VARCHAR2,
 X_NAME      VARCHAR2,
 X_TEXT_VALUE VARCHAR2,
 X_NUMBER_VALUE NUMBER,
 X_DATE_VALUE   DATE,
 X_EVENT_VALUE  WF_EVENT_T) is

begin
    insert into WF_ITEM_ATTRIBUTE_VALUES
    (ITEM_TYPE, ITEM_KEY, NAME, TEXT_VALUE, NUMBER_VALUE, DATE_VALUE,
	EVENT_VALUE)
    select X_ITEM_TYPE, X_ITEM_KEY, X_NAME, X_TEXT_VALUE, X_NUMBER_VALUE,
     X_DATE_VALUE, X_EVENT_VALUE
     from dual;
end;

-- repopulates WF_ITEM_ATTRIBUTES
procedure import_item_attr_row(
 X_ITEM_TYPE VARCHAR2,
 X_ITEM_KEY  VARCHAR2,
 X_NAME      VARCHAR2,
 X_TEXT_VALUE VARCHAR2,
 X_NUMBER_VALUE NUMBER,
 X_DATE_VALUE   DATE,
 X_EVENT_VALUE  Number)  -- overload hack until we support events

is

begin
    insert into WF_ITEM_ATTRIBUTE_VALUES
    (ITEM_TYPE, ITEM_KEY, NAME, TEXT_VALUE, NUMBER_VALUE, DATE_VALUE)
    select X_ITEM_TYPE, X_ITEM_KEY, X_NAME, X_TEXT_VALUE, X_NUMBER_VALUE,
     X_DATE_VALUE
     from dual;
end;

-- repopulates WF_ITEM_ACTIVITY_STATUSES
procedure import_ias_row(
 X_ITEM_TYPE             VARCHAR2,
 X_ITEM_KEY              VARCHAR2,
 X_PROCESS_ACTIVITY      NUMBER,
 X_ACTIVITY_STATUS       VARCHAR2,
 X_ACTIVITY_RESULT_CODE  VARCHAR2,
 X_ASSIGNED_USER         VARCHAR2,
 X_NOTIFICATION_ID       NUMBER,
 X_BEGIN_DATE            DATE,
 X_END_DATE              DATE,
 X_EXECUTION_TIME        NUMBER,
 X_ERROR_NAME            VARCHAR2,
 X_ERROR_MESSAGE         VARCHAR2,
 X_ERROR_STACK           VARCHAR2,
 X_OUTBOUND_QUEUE_ID     VARCHAR2,
 X_DUE_DATE              DATE) is

begin
    insert into WF_ITEM_ACTIVITY_STATUSES
    (ITEM_TYPE, ITEM_KEY, PROCESS_ACTIVITY, ACTIVITY_STATUS,
     ACTIVITY_RESULT_CODE, ASSIGNED_USER, NOTIFICATION_ID, BEGIN_DATE,
     END_DATE, EXECUTION_TIME, ERROR_NAME, ERROR_MESSAGE,
     ERROR_STACK, OUTBOUND_QUEUE_ID, DUE_DATE)
    select X_ITEM_TYPE, X_ITEM_KEY, X_PROCESS_ACTIVITY, X_ACTIVITY_STATUS,
     X_ACTIVITY_RESULT_CODE, X_ASSIGNED_USER, X_NOTIFICATION_ID, X_BEGIN_DATE,
     X_END_DATE, X_EXECUTION_TIME, X_ERROR_NAME, X_ERROR_MESSAGE,
     X_ERROR_STACK, hextoraw(X_OUTBOUND_QUEUE_ID), X_DUE_DATE
    from dual;
end;

-- repopulates WF_ITEM_ACTIVITY_STATUSES_H
procedure import_iash_row(
 X_ITEM_TYPE            VARCHAR2,
 X_ITEM_KEY             VARCHAR2,
 X_PROCESS_ACTIVITY     NUMBER,
 X_ACTIVITY_STATUS      VARCHAR2,
 X_ACTIVITY_RESULT_CODE VARCHAR2,
 X_ASSIGNED_USER        VARCHAR2,
 X_NOTIFICATION_ID      NUMBER,
 X_BEGIN_DATE           DATE,
 X_END_DATE             DATE,
 X_EXECUTION_TIME       NUMBER,
 X_ERROR_NAME           VARCHAR2,
 X_ERROR_MESSAGE        VARCHAR2,
 X_ERROR_STACK          VARCHAR2,
 X_OUTBOUND_QUEUE_ID    VARCHAR2,
 X_DUE_DATE             DATE) is

begin
    insert into WF_ITEM_ACTIVITY_STATUSES_H
    (ITEM_TYPE, ITEM_KEY, PROCESS_ACTIVITY, ACTIVITY_STATUS,
     ACTIVITY_RESULT_CODE, ASSIGNED_USER, NOTIFICATION_ID, BEGIN_DATE,
     END_DATE, EXECUTION_TIME, ERROR_NAME, ERROR_MESSAGE,
     ERROR_STACK, OUTBOUND_QUEUE_ID, DUE_DATE)
    select X_ITEM_TYPE, X_ITEM_KEY, X_PROCESS_ACTIVITY, X_ACTIVITY_STATUS,
     X_ACTIVITY_RESULT_CODE, X_ASSIGNED_USER, X_NOTIFICATION_ID, X_BEGIN_DATE,
     X_END_DATE, X_EXECUTION_TIME, X_ERROR_NAME, X_ERROR_MESSAGE,
     X_ERROR_STACK, hextoraw(X_OUTBOUND_QUEUE_ID), X_DUE_DATE
    from dual;
end;

-- repopulates WF_NOTIFICATIONS
procedure import_ntf_row(
 X_NOTIFICATION_ID NUMBER,
 X_GROUP_ID        NUMBER,
 X_MESSAGE_TYPE    VARCHAR2,
 X_MESSAGE_NAME    VARCHAR2,
 X_RECIPIENT_ROLE  VARCHAR2,
 X_STATUS          VARCHAR2,
 X_ACCESS_KEY      VARCHAR2,
 X_MAIL_STATUS     VARCHAR2,
 X_PRIORITY        NUMBER,
 X_BEGIN_DATE      DATE,
 X_END_DATE        DATE,
 X_DUE_DATE        DATE,
 X_RESPONDER       VARCHAR2,
 X_USER_COMMENT    VARCHAR2,
 X_CALLBACK        VARCHAR2,
 X_CONTEXT         VARCHAR2,
 X_ORIGINAL_RECIPIENT VARCHAR2,
 X_FROM_USER       VARCHAR2,
 X_TO_USER         VARCHAR2,
 X_SUBJECT         VARCHAR2,
 X_LANGUAGE        VARCHAR2,
 X_MORE_INFO_ROLE  VARCHAR2) is

begin
    insert into WF_NOTIFICATIONS
    (NOTIFICATION_ID, GROUP_ID, MESSAGE_TYPE, MESSAGE_NAME,
     RECIPIENT_ROLE, STATUS, ACCESS_KEY, MAIL_STATUS, PRIORITY,
     BEGIN_DATE, END_DATE, DUE_DATE, RESPONDER, USER_COMMENT,
     CALLBACK, CONTEXT, ORIGINAL_RECIPIENT, FROM_USER, TO_USER,
     SUBJECT, LANGUAGE, MORE_INFO_ROLE)
    select X_NOTIFICATION_ID, X_GROUP_ID, X_MESSAGE_TYPE, X_MESSAGE_NAME,
     X_RECIPIENT_ROLE, X_STATUS, X_ACCESS_KEY, X_MAIL_STATUS, X_PRIORITY,
     X_BEGIN_DATE, X_END_DATE, X_DUE_DATE, X_RESPONDER, X_USER_COMMENT,
     X_CALLBACK, X_CONTEXT, X_ORIGINAL_RECIPIENT, X_FROM_USER, X_TO_USER,
     X_SUBJECT, X_LANGUAGE, X_MORE_INFO_ROLE
    from dual;
end;



-- repopulates WF_NOTIFICATION_ATTRIBUTES
procedure import_ntf_attr_row(
 X_NOTIFICATION_ID NUMBER,
 X_NAME            VARCHAR2,
 X_TEXT_VALUE      VARCHAR2,
 X_NUMBER_VALUE    NUMBER,
 X_DATE_VALUE      DATE) is

begin
    insert into WF_NOTIFICATION_ATTRIBUTES
    (NOTIFICATION_ID, NAME, TEXT_VALUE, NUMBER_VALUE, DATE_VALUE)
    select X_NOTIFICATION_ID, X_NAME, X_TEXT_VALUE, X_NUMBER_VALUE,
	X_DATE_VALUE
    from dual;
end;

-- helper function to get around limitation of maps
procedure raw2hex(myraw in raw, myhex out nocopy varchar2) is
begin
	myhex := rawtohex(myraw);
end;

end;

/
