--------------------------------------------------------
--  DDL for Package JTF_TASK_RECUR_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TASK_RECUR_RULES_PKG" AUTHID CURRENT_USER as
/* $Header: jtftkrrs.pls 115.16 2002/12/04 22:12:27 cjang ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_RECURRENCE_RULE_ID in NUMBER,
  X_OCCURS_WHICH in NUMBER,
  X_DAY_OF_WEEK in NUMBER,
  X_DATE_OF_MONTH in NUMBER,
  X_OCCURS_MONTH in NUMBER,
  X_OCCURS_EVERY in NUMBER,
  X_OCCURS_NUMBER in NUMBER,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
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
  X_OCCURS_UOM in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  x_sunday                  IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
  x_monday                  IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
  x_tuesday                 IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
  x_wednesday               IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
  x_thursday                IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
  x_friday                  IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
  x_saturday                IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
  x_date_selected           IN       VARCHAR2 default null
  );
procedure LOCK_ROW (
  X_RECURRENCE_RULE_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER
);
procedure UPDATE_ROW (
  X_RECURRENCE_RULE_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_OCCURS_WHICH in NUMBER,
  X_DAY_OF_WEEK in NUMBER,
  X_DATE_OF_MONTH in NUMBER,
  X_OCCURS_MONTH in NUMBER,
  X_OCCURS_EVERY in NUMBER,
  X_OCCURS_NUMBER in NUMBER,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
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
  X_OCCURS_UOM in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  x_sunday                  IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
  x_monday                  IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
  x_tuesday                 IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
  x_wednesday               IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
  x_thursday                IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
  x_friday                  IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
  x_saturday                IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
  x_date_selected           IN       VARCHAR2 default null
  );
procedure DELETE_ROW (
  X_RECURRENCE_RULE_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER
);
end ;

 

/
