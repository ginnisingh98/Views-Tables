--------------------------------------------------------
--  DDL for Package AMW_COMPLIANCE_ENVS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMW_COMPLIANCE_ENVS_PKG" AUTHID CURRENT_USER AS
/* $Header: amwtenvs.pls 120.1 2006/05/31 23:33:50 npanandi noship $ */


-- ===============================================================
-- Package name
--          AMW_COMPLIANCE_ENVS_PKG
-- Purpose
--
-- History
-- 		  	06/24/2004    tsho     Creates
-- ===============================================================


-- ===============================================================
-- Procedure name
--          INSERT_ROW
-- Purpose
-- 		  	create new compliance environment
--          in AMW_COMPLIANCE_ENVS_B and AMW_COMPLIANCE_ENVS_TL
-- ===============================================================
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_COMPLIANCE_ENV_ID in NUMBER,
  X_START_DATE in DATE,
  X_END_DATE in DATE,
  X_ENABLED_FLAG in VARCHAR2,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_CREATION_DATE in DATE,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
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
  X_COMPLIANCE_ENV_NAME in VARCHAR2,
  X_COMPLIANCE_ENV_ALIAS in VARCHAR2,
  X_COMPLIANCE_ENV_DESCRIPTION in VARCHAR2);



-- ===============================================================
-- Procedure name
--          LOCK_ROW
-- Purpose
--
-- ===============================================================
procedure LOCK_ROW (
  X_COMPLIANCE_ENV_ID in NUMBER,
  X_START_DATE in DATE,
  X_END_DATE in DATE,
  X_ENABLED_FLAG in VARCHAR2,
  X_SECURITY_GROUP_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
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
  X_COMPLIANCE_ENV_NAME in VARCHAR2,
  X_COMPLIANCE_ENV_ALIAS in VARCHAR2,
  X_COMPLIANCE_ENV_DESCRIPTION in VARCHAR2);



-- ===============================================================
-- Procedure name
--          UPDATE_ROW
-- Purpose
--          update AMW_COMPLIANCE_ENVS_B and AMW_COMPLIANCE_ENVS_TL
-- ===============================================================
procedure UPDATE_ROW (
  X_COMPLIANCE_ENV_ID in NUMBER,
  X_START_DATE in DATE,
  X_END_DATE in DATE,
  X_ENABLED_FLAG in VARCHAR2,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
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
  X_COMPLIANCE_ENV_NAME in VARCHAR2,
  X_COMPLIANCE_ENV_ALIAS in VARCHAR2,
  X_COMPLIANCE_ENV_DESCRIPTION in VARCHAR2);


-- ===============================================================
-- Procedure name
--          LOAD_ROW
-- Purpose
--          load data to AMW_COMPLIANCE_ENVS_B and AMW_COMPLIANCE_ENVS_TL
-- ===============================================================
procedure LOAD_ROW (
  X_COMPLIANCE_ENV_ID in NUMBER,
  X_START_DATE in DATE,
  X_END_DATE in DATE,
  X_ENABLED_FLAG in VARCHAR2,
  X_SECURITY_GROUP_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
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
  X_COMPLIANCE_ENV_NAME in VARCHAR2,
  X_COMPLIANCE_ENV_ALIAS in VARCHAR2,
  X_COMPLIANCE_ENV_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2);


-- ===============================================================
-- Procedure name
--          DELETE_ROW
-- Purpose
--
-- ===============================================================
procedure DELETE_ROW (
  X_COMPLIANCE_ENV_ID in NUMBER);



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
	X_COMPLIANCE_ENV_ID		      in NUMBER,
	X_COMPLIANCE_ENV_NAME	      in VARCHAR2,
	X_COMPLIANCE_ENV_DESCRIPTION  In VARCHAR2,
	X_COMPLIANCE_ENV_ALIAS        in VARCHAR2,
	X_LAST_UPDATE_DATE    	      in VARCHAR2,
	X_OWNER			              in VARCHAR2,
	X_CUSTOM_MODE		          in VARCHAR2);
/**05.31.2006 npanandi: bug 5259681 fix ends***/

-- ----------------------------------------------------------------------
end AMW_COMPLIANCE_ENVS_PKG;

 

/
