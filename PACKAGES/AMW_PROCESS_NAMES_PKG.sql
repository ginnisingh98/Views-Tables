--------------------------------------------------------
--  DDL for Package AMW_PROCESS_NAMES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMW_PROCESS_NAMES_PKG" AUTHID CURRENT_USER as
/*$Header: amwprnms.pls 120.1 2005/06/28 14:27:03 appldev noship $*/

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PROCESS_REV_ID in NUMBER,
  X_CLASSIFICATION in NUMBER,
  X_PROCESS_CODE in VARCHAR2,
  X_REVISION_NUMBER in NUMBER,
  X_START_DATE in DATE,
  X_APPROVAL_DATE in DATE,
  X_APPROVAL_END_DATE in DATE,
  X_END_DATE in DATE,
  X_DELETION_DATE in DATE,
  X_PROCESS_TYPE in VARCHAR2,
  X_CONTROL_ACTIVITY_TYPE in VARCHAR2,
  X_RISK_COUNT_LATEST in NUMBER,
  X_CONTROL_COUNT_LATEST in NUMBER,
  X_STANDARD_VARIATION in NUMBER,
  X_SIGNIFICANT_PROCESS_FLAG in VARCHAR2,
  X_STANDARD_PROCESS_FLAG in VARCHAR2,
  X_APPROVAL_STATUS in VARCHAR2,
  X_CERTIFICATION_STATUS in VARCHAR2,
  X_PROCESS_CATEGORY in VARCHAR2,
  X_PROCESS_OWNER_ID in NUMBER,
  X_PROCESS_ID in NUMBER,
  X_ITEM_TYPE in VARCHAR2,
  X_NAME in VARCHAR2,
  X_CREATED_FROM in VARCHAR2,
  X_REQUEST_ID in NUMBER,
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
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_CONTROL_COUNT in NUMBER,
  X_RISK_COUNT in NUMBER,
  X_ORG_COUNT in NUMBER,
  X_FINANCE_OWNER_ID in NUMBER,
  X_APPLICATION_OWNER_ID in NUMBER,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);

procedure LOCK_ROW (
  X_PROCESS_REV_ID in NUMBER,
  X_CLASSIFICATION in NUMBER,
  X_PROCESS_CODE in VARCHAR2,
  X_REVISION_NUMBER in NUMBER,
  X_START_DATE in DATE,
  X_APPROVAL_DATE in DATE,
  X_APPROVAL_END_DATE in DATE,
  X_END_DATE in DATE,
  X_DELETION_DATE in DATE,
  X_PROCESS_TYPE in VARCHAR2,
  X_CONTROL_ACTIVITY_TYPE in VARCHAR2,
  X_RISK_COUNT_LATEST in NUMBER,
  X_CONTROL_COUNT_LATEST in NUMBER,
  X_STANDARD_VARIATION in NUMBER,
  X_SIGNIFICANT_PROCESS_FLAG in VARCHAR2,
  X_STANDARD_PROCESS_FLAG in VARCHAR2,
  X_APPROVAL_STATUS in VARCHAR2,
  X_CERTIFICATION_STATUS in VARCHAR2,
  X_PROCESS_CATEGORY in VARCHAR2,
  X_PROCESS_OWNER_ID in NUMBER,
  X_PROCESS_ID in NUMBER,
  X_ITEM_TYPE in VARCHAR2,
  X_NAME in VARCHAR2,
  X_CREATED_FROM in VARCHAR2,
  X_REQUEST_ID in NUMBER,
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
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_CONTROL_COUNT in NUMBER,
  X_RISK_COUNT in NUMBER,
  X_ORG_COUNT in NUMBER,
  X_FINANCE_OWNER_ID in NUMBER,
  X_APPLICATION_OWNER_ID in NUMBER,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
);
procedure UPDATE_ROW (
  X_PROCESS_REV_ID in NUMBER,
  X_CLASSIFICATION in NUMBER,
  X_PROCESS_CODE in VARCHAR2,
  X_REVISION_NUMBER in NUMBER,
  X_START_DATE in DATE,
  X_APPROVAL_DATE in DATE,
  X_APPROVAL_END_DATE in DATE,
  X_END_DATE in DATE,
  X_DELETION_DATE in DATE,
  X_PROCESS_TYPE in VARCHAR2,
  X_CONTROL_ACTIVITY_TYPE in VARCHAR2,
  X_RISK_COUNT_LATEST in NUMBER,
  X_CONTROL_COUNT_LATEST in NUMBER,
  X_STANDARD_VARIATION in NUMBER,
  X_SIGNIFICANT_PROCESS_FLAG in VARCHAR2,
  X_STANDARD_PROCESS_FLAG in VARCHAR2,
  X_APPROVAL_STATUS in VARCHAR2,
  X_CERTIFICATION_STATUS in VARCHAR2,
  X_PROCESS_CATEGORY in VARCHAR2,
  X_PROCESS_OWNER_ID in NUMBER,
  X_PROCESS_ID in NUMBER,
  X_ITEM_TYPE in VARCHAR2,
  X_NAME in VARCHAR2,
  X_CREATED_FROM in VARCHAR2,
  X_REQUEST_ID in NUMBER,
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
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_CONTROL_COUNT in NUMBER,
  X_RISK_COUNT in NUMBER,
  X_ORG_COUNT in NUMBER,
  X_FINANCE_OWNER_ID in NUMBER,
  X_APPLICATION_OWNER_ID in NUMBER,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);
procedure DELETE_ROW (
  X_PROCESS_REV_ID in NUMBER
);
procedure ADD_LANGUAGE;

procedure load_seed_data (x_owner in varchar2,
			  x_last_update_date in varchar2,
			  x_display_name in varchar2,
			  x_description in varchar2,
			  x_process_rev_id in number,
			  x_process_code in varchar2);

end AMW_PROCESS_NAMES_PKG;

 

/