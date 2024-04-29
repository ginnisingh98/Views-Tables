--------------------------------------------------------
--  DDL for Package AMW_ASSESSMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMW_ASSESSMENTS_PKG" AUTHID CURRENT_USER as
/* $Header: amwvasss.pls 120.0 2005/05/31 20:33:50 appldev noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_ASSESSMENT_ID in NUMBER,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_SECURITY_GROUP_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_EFFECTIVE_COMPLETION_DATE in DATE,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ASSESSMENT_TYPE_CODE in VARCHAR2,
  X_ASSESSMENT_OWNER_ID in NUMBER,
  X_IES_SURVEY_ID in NUMBER,
  X_IES_CYCLE_ID in NUMBER,
  X_IES_DEPLOYMENT_ID in NUMBER,
  X_ASSESSMENT_STATUS_CODE in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_START_DATE in DATE,
  X_PERIOD_NAME in VARCHAR2
);
procedure LOCK_ROW (
  X_ASSESSMENT_ID in NUMBER,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_SECURITY_GROUP_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_EFFECTIVE_COMPLETION_DATE in DATE,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ASSESSMENT_TYPE_CODE in VARCHAR2,
  X_ASSESSMENT_OWNER_ID in NUMBER,
  X_IES_SURVEY_ID in NUMBER,
  X_IES_CYCLE_ID in NUMBER,
  X_IES_DEPLOYMENT_ID in NUMBER,
  X_ASSESSMENT_STATUS_CODE in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_START_DATE in DATE,
  X_PERIOD_NAME in VARCHAR2
);
procedure UPDATE_ROW (
  X_ASSESSMENT_ID in NUMBER,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_SECURITY_GROUP_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_EFFECTIVE_COMPLETION_DATE in DATE,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ASSESSMENT_TYPE_CODE in VARCHAR2,
  X_ASSESSMENT_OWNER_ID in NUMBER,
  X_IES_SURVEY_ID in NUMBER,
  X_IES_CYCLE_ID in NUMBER,
  X_IES_DEPLOYMENT_ID in NUMBER,
  X_ASSESSMENT_STATUS_CODE in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_START_DATE in DATE,
  X_PERIOD_NAME in VARCHAR2
);
procedure DELETE_ROW (
  X_ASSESSMENT_ID in NUMBER
);
procedure ADD_LANGUAGE;
end AMW_ASSESSMENTS_PKG;


 

/