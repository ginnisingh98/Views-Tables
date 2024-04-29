--------------------------------------------------------
--  DDL for Package AMW_CONSTRAINTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMW_CONSTRAINTS_PKG" AUTHID CURRENT_USER AS
/* $Header: amwtcsts.pls 120.3 2005/11/28 14:48:13 appldev noship $ */

-- ===============================================================
-- Package name
--          AMW_CONSTRAINTS_PKG
-- Purpose
--
-- History
-- 		  	11/03/2003    tsho     Creates
-- 		  	10/01/2004    tsho     Add column: Approal_Status
--          09/27/2005    tsho     Add column: Control_Id
-- ===============================================================


-- ===============================================================
-- Procedure name
--          INSERT_ROW
-- Purpose
-- 		  	create new constraint
--          in AMW_CONSTRAINTS_B and AMW_CONSTRAINTS_TL
-- ===============================================================
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_CONSTRAINT_ID in NUMBER,
  X_CONSTRAINT_REV_ID in NUMBER,
  X_START_DATE in DATE,
  X_END_DATE in DATE,
  X_ENTERED_BY_ID in NUMBER,
  X_TYPE_CODE in VARCHAR2,
  X_RISK_ID in NUMBER,
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
  X_CONSTRAINT_NAME in VARCHAR2,
  X_CONSTRAINT_DESCRIPTION in VARCHAR2,
  X_APPROVAL_STATUS in VARCHAR2 := NULL,
  X_CLASSIFICATION in VARCHAR2 := NULL,
  X_OBJECTIVE_CODE in VARCHAR2 := NULL,
  X_CONTROL_ID in NUMBER := NULL);



-- ===============================================================
-- Procedure name
--          LOCK_ROW
-- Purpose
--
-- ===============================================================
procedure LOCK_ROW (
  X_CONSTRAINT_ID in NUMBER,
  X_CONSTRAINT_REV_ID in NUMBER,
  X_START_DATE in DATE,
  X_END_DATE in DATE,
  X_ENTERED_BY_ID in NUMBER,
  X_TYPE_CODE in VARCHAR2,
  X_RISK_ID in NUMBER,
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
  X_CONSTRAINT_NAME in VARCHAR2,
  X_CONSTRAINT_DESCRIPTION in VARCHAR2,
  X_APPROVAL_STATUS in VARCHAR2 := NULL,
  X_CLASSIFICATION in VARCHAR2 := NULL,
  X_OBJECTIVE_CODE in VARCHAR2 := NULL,
  X_CONTROL_ID in NUMBER := NULL);



-- ===============================================================
-- Procedure name
--          UPDATE_ROW
-- Purpose
-- 		  	update AMW_CONSTRAINTS_B and AMW_CONSTRAINTS_TL
-- ===============================================================
procedure UPDATE_ROW (
  X_CONSTRAINT_ID in NUMBER,
  X_CONSTRAINT_REV_ID in NUMBER,
  X_START_DATE in DATE,
  X_END_DATE in DATE,
  X_ENTERED_BY_ID in NUMBER,
  X_TYPE_CODE in VARCHAR2,
  X_RISK_ID in NUMBER,
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
  X_CONSTRAINT_NAME in VARCHAR2,
  X_CONSTRAINT_DESCRIPTION in VARCHAR2,
  X_APPROVAL_STATUS in VARCHAR2 := NULL,
  X_CLASSIFICATION in VARCHAR2 := NULL,
  X_OBJECTIVE_CODE in VARCHAR2 := NULL,
  X_CONTROL_ID in NUMBER := NULL);


-- ===============================================================
-- Procedure name
--          DELETE_ROW
-- Purpose
--
-- ===============================================================
procedure DELETE_ROW (
  X_CONSTRAINT_ID in NUMBER);



-- ===============================================================
-- Procedure name
--          ADD_LANGUAGE
-- Purpose
--
-- ===============================================================
procedure ADD_LANGUAGE;

-- ----------------------------------------------------------------------
end AMW_CONSTRAINTS_PKG;

 

/
