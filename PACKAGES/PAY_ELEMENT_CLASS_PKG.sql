--------------------------------------------------------
--  DDL for Package PAY_ELEMENT_CLASS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ELEMENT_CLASS_PKG" AUTHID CURRENT_USER as
/* $Header: pydec.pkh 115.9 2003/09/29 05:39:08 kkawol ship $ */
--------------------------------------------------------------------------------
function NAME_NOT_UNIQUE (	p_classification_name	varchar2,
				p_legislation_code	varchar2,
                                p_business_group_id     number,
				p_rowid			varchar2)
return BOOLEAN;
--------------------------------------------------------------------------------
PROCEDURE set_translation_globals(p_business_group_id IN NUMBER,
				  p_legislation_code IN VARCHAR2);
--------------------------------------------------------------------------------
procedure validate_TRANSLATION (classification_id IN    number,
				language IN             varchar2,
                                classification_name IN  varchar2,
				description IN VARCHAR2,
				p_business_group_id IN NUMBER DEFAULT NULL,
			        p_legislation_code IN VARCHAR2 DEFAULT NULL);
--------------------------------------------------------------------------------
function DELETION_ALLOWED (p_classification_id	varchar2) return boolean;
--------------------------------------------------------------------------------
function USER_CAN_MODIFY_PRIMARY ( p_legislation_code varchar2) return boolean;
--------------------------------------------------------------------------------
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_CLASSIFICATION_ID in NUMBER,
  X_BUSINESS_GROUP_ID in NUMBER,
  X_LEGISLATION_CODE in VARCHAR2,
  X_LEGISLATION_SUBGROUP in VARCHAR2,
  X_COSTABLE_FLAG in VARCHAR2,
  X_DEFAULT_HIGH_PRIORITY in NUMBER,
  X_DEFAULT_LOW_PRIORITY in NUMBER,
  X_DEFAULT_PRIORITY in NUMBER,
  X_DISTRIBUTABLE_OVER_FLAG in VARCHAR2,
  X_NON_PAYMENTS_FLAG in VARCHAR2,
  X_COSTING_DEBIT_OR_CREDIT in VARCHAR2,
  X_PARENT_CLASSIFICATION_ID in NUMBER,
  X_CREATE_BY_DEFAULT_FLAG in VARCHAR2,
  X_BALANCE_INITIALIZATION_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_CLASSIFICATION_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_FREQ_RULE_ENABLED in VARCHAR2 default null);
--------------------------------------------------------------------------------
procedure LOCK_ROW (
  X_CLASSIFICATION_ID in NUMBER,
  X_BUSINESS_GROUP_ID in NUMBER,
  X_LEGISLATION_CODE in VARCHAR2,
  X_LEGISLATION_SUBGROUP in VARCHAR2,
  X_COSTABLE_FLAG in VARCHAR2,
  X_DEFAULT_HIGH_PRIORITY in NUMBER,
  X_DEFAULT_LOW_PRIORITY in NUMBER,
  X_DEFAULT_PRIORITY in NUMBER,
  X_DISTRIBUTABLE_OVER_FLAG in VARCHAR2,
  X_NON_PAYMENTS_FLAG in VARCHAR2,
  X_COSTING_DEBIT_OR_CREDIT in VARCHAR2,
  X_PARENT_CLASSIFICATION_ID in NUMBER,
  X_CREATE_BY_DEFAULT_FLAG in VARCHAR2,
  X_BALANCE_INITIALIZATION_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_CLASSIFICATION_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_FREQ_RULE_ENABLED in VARCHAR2 default null
);
--------------------------------------------------------------------------------
procedure UPDATE_ROW (
  X_CLASSIFICATION_ID in NUMBER,
  X_BUSINESS_GROUP_ID in NUMBER,
  X_LEGISLATION_CODE in VARCHAR2,
  X_LEGISLATION_SUBGROUP in VARCHAR2,
  X_COSTABLE_FLAG in VARCHAR2,
  X_DEFAULT_HIGH_PRIORITY in NUMBER,
  X_DEFAULT_LOW_PRIORITY in NUMBER,
  X_DEFAULT_PRIORITY in NUMBER,
  X_DISTRIBUTABLE_OVER_FLAG in VARCHAR2,
  X_NON_PAYMENTS_FLAG in VARCHAR2,
  X_COSTING_DEBIT_OR_CREDIT in VARCHAR2,
  X_PARENT_CLASSIFICATION_ID in NUMBER,
  X_CREATE_BY_DEFAULT_FLAG in VARCHAR2,
  X_BALANCE_INITIALIZATION_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_CLASSIFICATION_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_MESG_FLG          out nocopy Boolean,
  X_FREQ_RULE_ENABLED in VARCHAR2 default null
);
--------------------------------------------------------------------------------
procedure DELETE_ROW (
  X_CLASSIFICATION_ID in NUMBER
);
--------------------------------------------------------------------------------
procedure ADD_LANGUAGE;
--------------------------------------------------------------------------------
procedure TRANSLATE_ROW (
  X_E_CLASSIFICATION_NAME in VARCHAR2,
  X_E_LEGISLATION_CODE in VARCHAR2,
  X_CLASSIFICATION_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2
);
--------------------------------------------------------------------------------
end PAY_ELEMENT_CLASS_PKG;

 

/
