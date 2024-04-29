--------------------------------------------------------
--  DDL for Package ITA_SETUP_REC_VALUES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ITA_SETUP_REC_VALUES_PKG" AUTHID CURRENT_USER as
/* $Header: itatrevs.pls 120.6.12000000.1 2007/01/18 08:50:36 appldev ship $ */


procedure INSERT_ROW (
  X_REC_VALUE_ID in NUMBER,
  X_PARAMETER_CODE in VARCHAR2,
  X_CONTEXT_ORG_ID in NUMBER,
  X_CONTEXT_ORG_NAME in VARCHAR2,
  X_RECOMMENDED_VALUE in VARCHAR2,
  X_DEFAULT_FLAG in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_PK1_VALUE in VARCHAR2,
  X_PK2_VALUE in VARCHAR2,
  X_REC_INTERFACE_ID NUMBER
);


procedure UPDATE_ROW (
  X_REC_VALUE_ID in NUMBER,
  X_PARAMETER_CODE in VARCHAR2,
  X_CONTEXT_ORG_ID in NUMBER,
  X_CONTEXT_ORG_NAME in VARCHAR2,
  X_RECOMMENDED_VALUE in VARCHAR2,
  X_DEFAULT_FLAG in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_PK1_VALUE in VARCHAR2,
  X_PK2_VALUE in VARCHAR2,
  X_REC_INTERFACE_ID NUMBER
);


procedure LOAD_ROW (
  X_REC_VALUE_ID in NUMBER,
  X_PARAMETER_CODE in VARCHAR2,
  X_CONTEXT_ORG_ID in NUMBER,
  X_CONTEXT_ORG_NAME in VARCHAR2,
  X_RECOMMENDED_VALUE in VARCHAR2,
  X_DEFAULT_FLAG in VARCHAR2,
  X_LAST_UPDATE_DATE in VARCHAR2,
  X_PK1_VALUE in VARCHAR2,
  X_PK2_VALUE in VARCHAR2,
  X_REC_INTERFACE_ID NUMBER,
  X_OWNER in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2
);


procedure LOAD_ROW_FOR_IMPORT (
  X_REC_VALUE_ID in NUMBER,
  X_PARAMETER_CODE in VARCHAR2,
  X_CONTEXT_ORG_ID in NUMBER,
  X_CONTEXT_ORG_NAME in VARCHAR2,
  X_RECOMMENDED_VALUE in VARCHAR2,
  X_DEFAULT_FLAG in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_PK1_VALUE in VARCHAR2,
  X_PK2_VALUE in VARCHAR2,
  X_REC_INTERFACE_ID NUMBER
);


procedure ADD_LANGUAGE;


procedure GetParameterCode  (p_parameter_name    IN VARCHAR2,
		             p_setup_group_code IN VARCHAR2,
			     X_PARAMETER_CODE OUT NOCOPY VARCHAR2);

procedure IMPORT (
  BATCH_ID in NUMBER,
  CREATED_BY in NUMBER
);

procedure getContextInfo(
			X_CONTEXT_ID OUT NOCOPY NUMBER,
			P_CONTEXT_NAME IN VARCHAR2,
			P_SETUP_GROUP_NAME IN VARCHAR2
);


-- *****************************************
-- FUNCTION
--   getRecValueCode
-- Input Parameters
--   context_org_id
--   parameter_code
-- Return Values
--   varchar2   recommended_value for
--              the org and parameter code
-- *****************************************
FUNCTION getRecValueCode(
   p_context_org_id     IN   VARCHAR2,
   p_parameter_code     IN   VARCHAR2
)
return VARCHAR2;

-- *****************************************
-- FUNCTION
--   getRecValueMeaning
-- Input Parameters
--   context_org_id
--   parameter_code
-- Return Values
--   varchar2   recommended_value meaning for
--              the org and parameter code
-- *****************************************
FUNCTION getRecValueMeaning(
   p_context_org_id     IN   VARCHAR2,
   p_parameter_code     IN   VARCHAR2
)
return VARCHAR2;


end ITA_SETUP_REC_VALUES_PKG;

 

/
