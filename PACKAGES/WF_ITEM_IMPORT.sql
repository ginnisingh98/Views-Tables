--------------------------------------------------------
--  DDL for Package WF_ITEM_IMPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_ITEM_IMPORT" AUTHID CURRENT_USER as
/* $Header: WFHAIMPS.pls 120.2 2005/10/18 12:44:22 mfisher ship $ */

-- Removes all trace of rows related to X_Item_type/X_Item_key from
-- Runtime tables

procedure erase(X_Item_type VARCHAR2, X_Item_key VARCHAR2);

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
 X_HA_MIGRATION_FLAG VARCHAR2);

-- repopulates WF_ITEM_ATTRIBUTES
procedure import_item_attr_row(
 X_ITEM_TYPE VARCHAR2,
 X_ITEM_KEY  VARCHAR2,
 X_NAME      VARCHAR2,
 X_TEXT_VALUE VARCHAR2,
 X_NUMBER_VALUE NUMBER,
 X_DATE_VALUE   DATE,
 X_EVENT_VALUE  WF_EVENT_T);

-- repopulates WF_ITEM_ATTRIBUTES
procedure import_item_attr_row(
 X_ITEM_TYPE VARCHAR2,
 X_ITEM_KEY  VARCHAR2,
 X_NAME      VARCHAR2,
 X_TEXT_VALUE VARCHAR2,
 X_NUMBER_VALUE NUMBER,
 X_DATE_VALUE   DATE,
 X_EVENT_VALUE  Number);  -- overload hack until we support events

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
 X_DUE_DATE              DATE);

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
 X_DUE_DATE             DATE);

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
 X_MORE_INFO_ROLE  VARCHAR2);

-- repopulates WF_NOTIFICATION_ATTRIBUTES
procedure import_ntf_attr_row(
 X_NOTIFICATION_ID NUMBER,
 X_NAME            VARCHAR2,
 X_TEXT_VALUE      VARCHAR2,
 X_NUMBER_VALUE    NUMBER,
 X_DATE_VALUE      DATE);


-- helper function to get around limitation of maps
procedure raw2hex(myraw in raw, myhex out nocopy varchar2);

end;

 

/