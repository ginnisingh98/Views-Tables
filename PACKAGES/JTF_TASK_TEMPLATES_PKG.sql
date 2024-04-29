--------------------------------------------------------
--  DDL for Package JTF_TASK_TEMPLATES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TASK_TEMPLATES_PKG" AUTHID CURRENT_USER as
/* $Header: jtftktes.pls 120.1 2005/07/02 01:28:21 appldev ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_TASK_TEMPLATE_ID in NUMBER,
  X_ALARM_ON in VARCHAR2,
  X_ALARM_COUNT in NUMBER,
  X_ALARM_INTERVAL in NUMBER,
  X_ALARM_INTERVAL_UOM in VARCHAR2,
  X_DELETED_FLAG in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_HOLIDAY_FLAG in VARCHAR2,
  X_BILLABLE_FLAG in VARCHAR2,
  X_RECURRENCE_RULE_ID in NUMBER,
  X_NOTIFICATION_FLAG in VARCHAR2,
  X_NOTIFICATION_PERIOD in NUMBER,
  X_NOTIFICATION_PERIOD_UOM in VARCHAR2,
  X_ALARM_START in NUMBER,
  X_ALARM_START_UOM in VARCHAR2,
  X_PRIVATE_FLAG in VARCHAR2,
  X_PUBLISH_FLAG in VARCHAR2,
  X_RESTRICT_CLOSURE_FLAG in VARCHAR2,
  X_MULTI_BOOKED_FLAG in VARCHAR2,
  X_MILESTONE_FLAG in VARCHAR2,
  X_TASK_GROUP_ID in NUMBER,
  X_TASK_NUMBER in VARCHAR2,
  X_TASK_TYPE_ID in NUMBER,
  X_TASK_STATUS_ID in NUMBER,
  X_TASK_PRIORITY_ID in NUMBER,
  X_DURATION in NUMBER,
  X_DURATION_UOM in VARCHAR2,
  X_PLANNED_EFFORT in NUMBER,
  X_PLANNED_EFFORT_UOM in VARCHAR2,
  X_TASK_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_TASK_CONFIRMATION_STATUS in	 VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);
procedure LOCK_ROW (
  X_TASK_TEMPLATE_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER
);
procedure UPDATE_ROW (
  X_TASK_TEMPLATE_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ALARM_ON in VARCHAR2,
  X_ALARM_COUNT in NUMBER,
  X_ALARM_INTERVAL in NUMBER,
  X_ALARM_INTERVAL_UOM in VARCHAR2,
  X_DELETED_FLAG in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_HOLIDAY_FLAG in VARCHAR2,
  X_BILLABLE_FLAG in VARCHAR2,
  X_RECURRENCE_RULE_ID in NUMBER,
  X_NOTIFICATION_FLAG in VARCHAR2,
  X_NOTIFICATION_PERIOD in NUMBER,
  X_NOTIFICATION_PERIOD_UOM in VARCHAR2,
  X_ALARM_START in NUMBER,
  X_ALARM_START_UOM in VARCHAR2,
  X_PRIVATE_FLAG in VARCHAR2,
  X_PUBLISH_FLAG in VARCHAR2,
  X_RESTRICT_CLOSURE_FLAG in VARCHAR2,
  X_MULTI_BOOKED_FLAG in VARCHAR2,
  X_MILESTONE_FLAG in VARCHAR2,
  X_TASK_GROUP_ID in NUMBER,
  X_TASK_NUMBER in VARCHAR2,
  X_TASK_TYPE_ID in NUMBER,
  X_TASK_STATUS_ID in NUMBER,
  X_TASK_PRIORITY_ID in NUMBER,
  X_DURATION in NUMBER,
  X_DURATION_UOM in VARCHAR2,
  X_PLANNED_EFFORT in NUMBER,
  X_PLANNED_EFFORT_UOM in VARCHAR2,
  X_TASK_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_TASK_CONFIRMATION_STATUS in	 VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);
procedure DELETE_ROW (
  X_TASK_TEMPLATE_ID in NUMBER

);
procedure ADD_LANGUAGE;

procedure TRANSLATE_ROW(
  X_task_Template_ID in number,
  X_task_NAME in varchar2,
  X_DESCRIPTION in varchar2,
  x_owner in varchar2) ;

end JTF_TASK_TEMPLATES_PKG;

 

/
