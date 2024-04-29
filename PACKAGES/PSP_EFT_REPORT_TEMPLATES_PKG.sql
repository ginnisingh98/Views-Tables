--------------------------------------------------------
--  DDL for Package PSP_EFT_REPORT_TEMPLATES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_EFT_REPORT_TEMPLATES_PKG" AUTHID CURRENT_USER as
 /* $Header: PSPERTES.pls 115.8 2002/11/18 09:17:00 lveerubh ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_TEMPLATE_ID in NUMBER,
  X_TEMPLATE_NAME in VARCHAR2,
  X_EFFORT_REPORT_PERIOD_NAME in VARCHAR2,
  X_BEGIN_DATE in DATE,
  X_END_DATE in DATE,
  X_PEOPLE_GROUP_ID in NUMBER,
  X_PERSON_ID in NUMBER,
  X_EFFECTIVE_START_DATE in DATE,
  X_EFFECTIVE_END_DATE in DATE,
  X_SUPERVISOR_ID in NUMBER,
  X_GL_CODE_COMBINATION_ID in NUMBER,
  X_EXPENDITURE_TYPE in VARCHAR2,
  X_TASK_ID in NUMBER,
  X_PROJECT_TYPE_CLASS_CODE in VARCHAR2,
  X_PROJECT_TYPE in VARCHAR2,
  X_AWARD_TYPE in VARCHAR2,
  X_FUNDING_SOURCE_ID in NUMBER,
  X_ELEMENT_TYPE_ID in NUMBER,
  X_ENABLE_WORKFLOW_FLAG in VARCHAR2,
  X_USER_TEMPLATE_FLAG in VARCHAR2,
  X_REPORT_TYPE in VARCHAR2,
  X_REPORT_INITIATOR_ID in NUMBER,
  X_INITIATOR_APPS_NAME in VARCHAR2,
  X_ERROR_DATE_TIME in DATE,
  X_BUSINESS_GROUP_ID in VARCHAR2,
  X_SET_OF_BOOKS_ID in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
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
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_TEMPLATE_ID in NUMBER,
  X_TEMPLATE_NAME in VARCHAR2,
  X_EFFORT_REPORT_PERIOD_NAME in VARCHAR2,
  X_BEGIN_DATE in DATE,
  X_END_DATE in DATE,
  X_PEOPLE_GROUP_ID in NUMBER,
  X_PERSON_ID in NUMBER,
  X_EFFECTIVE_START_DATE in DATE,
  X_EFFECTIVE_END_DATE in DATE,
  X_SUPERVISOR_ID in NUMBER,
  X_GL_CODE_COMBINATION_ID in NUMBER,
  X_EXPENDITURE_TYPE in VARCHAR2,
  X_TASK_ID in NUMBER,
  X_PROJECT_TYPE_CLASS_CODE in VARCHAR2,
  X_PROJECT_TYPE in VARCHAR2,
  X_AWARD_TYPE in VARCHAR2,
  X_FUNDING_SOURCE_ID in NUMBER,
  X_ELEMENT_TYPE_ID in NUMBER,
  X_ENABLE_WORKFLOW_FLAG in VARCHAR2,
  X_USER_TEMPLATE_FLAG in VARCHAR2,
  X_REPORT_TYPE in VARCHAR2,
  X_REPORT_INITIATOR_ID in NUMBER,
  X_INITIATOR_APPS_NAME in VARCHAR2,
  X_ERROR_DATE_TIME in DATE,
  X_BUSINESS_GROUP_ID in VARCHAR2,
  X_SET_OF_BOOKS_ID in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
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
  X_ATTRIBUTE15 in VARCHAR2
);
procedure UPDATE_ROW (
  X_TEMPLATE_ID in NUMBER,
  X_TEMPLATE_NAME in VARCHAR2,
  X_EFFORT_REPORT_PERIOD_NAME in VARCHAR2,
  X_BEGIN_DATE in DATE,
  X_END_DATE in DATE,
  X_PEOPLE_GROUP_ID in NUMBER,
  X_PERSON_ID in NUMBER,
  X_EFFECTIVE_START_DATE in DATE,
  X_EFFECTIVE_END_DATE in DATE,
  X_SUPERVISOR_ID in NUMBER,
  X_GL_CODE_COMBINATION_ID in NUMBER,
  X_EXPENDITURE_TYPE in VARCHAR2,
  X_TASK_ID in NUMBER,
  X_PROJECT_TYPE_CLASS_CODE in VARCHAR2,
  X_PROJECT_TYPE in VARCHAR2,
  X_AWARD_TYPE in VARCHAR2,
  X_FUNDING_SOURCE_ID in NUMBER,
  X_ELEMENT_TYPE_ID in NUMBER,
  X_ENABLE_WORKFLOW_FLAG in VARCHAR2,
  X_USER_TEMPLATE_FLAG in VARCHAR2,
  X_REPORT_TYPE in VARCHAR2,
  X_REPORT_INITIATOR_ID in NUMBER,
  X_INITIATOR_APPS_NAME in VARCHAR2,
  X_ERROR_DATE_TIME in DATE,
  X_BUSINESS_GROUP_ID in VARCHAR2,
  X_SET_OF_BOOKS_ID in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
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
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_TEMPLATE_ID in NUMBER,
  X_TEMPLATE_NAME in VARCHAR2,
  X_EFFORT_REPORT_PERIOD_NAME in VARCHAR2,
  X_BEGIN_DATE in DATE,
  X_END_DATE in DATE,
  X_PEOPLE_GROUP_ID in NUMBER,
  X_PERSON_ID in NUMBER,
  X_EFFECTIVE_START_DATE in DATE,
  X_EFFECTIVE_END_DATE in DATE,
  X_SUPERVISOR_ID in NUMBER,
  X_GL_CODE_COMBINATION_ID in NUMBER,
  X_EXPENDITURE_TYPE in VARCHAR2,
  X_TASK_ID in NUMBER,
  X_PROJECT_TYPE_CLASS_CODE in VARCHAR2,
  X_PROJECT_TYPE in VARCHAR2,
  X_AWARD_TYPE in VARCHAR2,
  X_FUNDING_SOURCE_ID in NUMBER,
  X_ELEMENT_TYPE_ID in NUMBER,
  X_ENABLE_WORKFLOW_FLAG in VARCHAR2,
  X_USER_TEMPLATE_FLAG in VARCHAR2,
  X_REPORT_TYPE in VARCHAR2,
  X_REPORT_INITIATOR_ID in NUMBER,
  X_INITIATOR_APPS_NAME in VARCHAR2,
  X_ERROR_DATE_TIME in DATE,
  X_BUSINESS_GROUP_ID in VARCHAR2,
  X_SET_OF_BOOKS_ID in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
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
  X_MODE in VARCHAR2 default 'R'
  );
procedure DELETE_ROW (
  X_TEMPLATE_ID in NUMBER
);
end PSP_EFT_REPORT_TEMPLATES_PKG;

 

/