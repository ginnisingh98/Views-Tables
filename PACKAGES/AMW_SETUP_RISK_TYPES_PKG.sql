--------------------------------------------------------
--  DDL for Package AMW_SETUP_RISK_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMW_SETUP_RISK_TYPES_PKG" AUTHID CURRENT_USER AS
/* $Header: amwtrtps.pls 120.2 2006/08/23 19:05:46 npanandi noship $ */


-- ===============================================================
-- Package name
--          AMW_SETUP_RISK_TYPES_PKG
-- Purpose
--
-- History
-- 		  	07/06/2004    tsho     Creates
-- ===============================================================


-- ===============================================================
-- Procedure name
--          INSERT_ROW
-- Purpose
-- 		  	create new compliance environment
--          in AMW_SETUP_RISK_TYPES_B and AMW_SETUP_RISK_TYPES_TL
-- ===============================================================
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_SETUP_RISK_TYPE_ID in NUMBER,
  X_RISK_TYPE_CODE in VARCHAR2,
  X_PARENT_SETUP_RISK_TYPE_ID in NUMBER,
  X_START_DATE in DATE,
  X_END_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_CREATION_DATE in DATE,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_TAG in VARCHAR2,
  X_SETUP_RISK_TYPE_NAME in VARCHAR2,
  X_SETUP_RISK_TYPE_DESCRIPTION in VARCHAR2);



-- ===============================================================
-- Procedure name
--          LOCK_ROW
-- Purpose
--
-- ===============================================================
procedure LOCK_ROW (
  X_SETUP_RISK_TYPE_ID in NUMBER,
  X_RISK_TYPE_CODE in VARCHAR2,
  X_PARENT_SETUP_RISK_TYPE_ID in NUMBER,
  X_START_DATE in DATE,
  X_END_DATE in DATE,
  X_SECURITY_GROUP_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_TAG in VARCHAR2,
  X_SETUP_RISK_TYPE_NAME in VARCHAR2,
  X_SETUP_RISK_TYPE_DESCRIPTION in VARCHAR2);



-- ===============================================================
-- Procedure name
--          UPDATE_ROW
-- Purpose
--          update AMW_SETUP_RISK_TYPES_B and AMW_SETUP_RISK_TYPES_TL
-- ===============================================================
procedure UPDATE_ROW (
  X_SETUP_RISK_TYPE_ID in NUMBER,
  X_RISK_TYPE_CODE in VARCHAR2,
  X_PARENT_SETUP_RISK_TYPE_ID in NUMBER,
  X_START_DATE in DATE,
  X_END_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_TAG in VARCHAR2,
  X_SETUP_RISK_TYPE_NAME in VARCHAR2,
  X_SETUP_RISK_TYPE_DESCRIPTION in VARCHAR2);


-- ===============================================================
-- Procedure name
--          LOAD_ROW
-- Purpose
--          load AMW_SETUP_RISK_TYPE to AMW_SETUP_RISK_TYPES_B(_TL)
-- ===============================================================
procedure LOAD_ROW (
  X_SETUP_RISK_TYPE_ID in NUMBER,
  X_RISK_TYPE_CODE in VARCHAR2,
  X_PARENT_SETUP_RISK_TYPE_ID in NUMBER,
  X_START_DATE in DATE,
  X_END_DATE in DATE,
  X_SECURITY_GROUP_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_TAG in VARCHAR2,
  X_SETUP_RISK_TYPE_NAME in VARCHAR2,
  X_SETUP_RISK_TYPE_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2,
  /** 08.23.2006 npanandi: bug 5486153 fix -- no need to pass
      X_PARENT_SETUP_RISK_TYPE_NAME, as it creates translation issues
  X_PARENT_SETUP_RISK_TYPE_NAME in VARCHAR2,
  **/
  X_COMPLIANCE_ENV_ID in NUMBER);


-- ===============================================================
-- Procedure name
--          DELETE_ROW
-- Purpose
--
-- ===============================================================
procedure DELETE_ROW (
  X_SETUP_RISK_TYPE_ID in NUMBER,
  X_PARENT_SETUP_RISK_TYPE_ID  in NUMBER);



-- ===============================================================
-- Procedure name
--          ADD_LANGUAGE
-- Purpose
--
-- ===============================================================
procedure ADD_LANGUAGE;

/**05.31.2006 npanandi: bug 5259681 fix, added translate row***/
-- ===============================================================
-- Procedure name
--          TRANSLATE_ROW
-- Purpose
--          translate a row for MLS enabled DB environments
-- ===============================================================
procedure TRANSLATE_ROW(
	X_SETUP_RISK_TYPE_ID		  in NUMBER,
	X_SETUP_RISK_TYPE_NAME        in VARCHAR2,
    X_SETUP_RISK_TYPE_DESCRIPTION in VARCHAR2,
	X_LAST_UPDATE_DATE    	      in VARCHAR2,
	X_OWNER			              in VARCHAR2,
	X_CUSTOM_MODE		          in VARCHAR2);
/**05.31.2006 npanandi: bug 5259681 fix ends***/

-- ----------------------------------------------------------------------
end AMW_SETUP_RISK_TYPES_PKG;

 

/
