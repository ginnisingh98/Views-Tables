--------------------------------------------------------
--  DDL for Package HZ_CREDIT_USAGE_RULE_SETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_CREDIT_USAGE_RULE_SETS_PKG" AUTHID CURRENT_USER AS
/* $Header: ARHCRUSS.pls 115.6 2003/08/18 17:56:47 rajkrish ship $ */
--======================================================================
--CONSTANTS
--======================================================================
G_PKG_NAME CONSTANT VARCHAR2(30)    :='HZ_CREDIT_USAGE_RULE_SETS_PKG';


---------------------------
-- PROCEDURES AND FUNCTIONS
---------------------------
--========================================================================
-- PROCEDURE : Insert_row                   PUBLIC
-- COMMENT   : Procedure inserts record into the table HZ_CREDIT_USAGE_RULE_SETS_B
--             and  HZ_CREDIT_USAGE_RULE_SETS_TL
--========================================================================
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_CREDIT_USAGE_RULE_SET_ID in NUMBER,
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
  X_REQUEST_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_GLOBAL_EXPOSURE_FLAG IN VARCHAR2);
--========================================================================
-- PROCEDURE : Lock_row                     PUBLIC
-- COMMENT   : Procedure locks record in the table HZ_CREDIT_USAGE_RULE_SETS_B
--             and  HZ_CREDIT_USAGE_RULE_SETS_TL
--========================================================================
procedure LOCK_ROW (
  X_CREDIT_USAGE_RULE_SET_ID in NUMBER,
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
  X_REQUEST_ID in NUMBER,
  X_NAME in VARCHAR2
);
--========================================================================
-- PROCEDURE : Update_row                   PUBLIC
-- COMMENT   : Procedure updates record in the table HZ_CREDIT_USAGE_RULE_SETS_B
--             and  HZ_CREDIT_USAGE_RULE_SETS_TL
--========================================================================
procedure UPDATE_ROW (
  X_CREDIT_USAGE_RULE_SET_ID in NUMBER,
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
  X_REQUEST_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_GLOBAL_EXPOSURE_FLAG IN VARCHAR2
);
--========================================================================
-- PROCEDURE : Delete_row             		 PUBLIC
-- COMMENT   : Procedure deletes record from the table HZ_CREDIT_USAGE_RULE_SETS_B
--             and  HZ_CREDIT_USAGE_RULE_SETS_TL
--========================================================================
PROCEDURE DELETE_ROW (
  X_CREDIT_USAGE_RULE_SET_ID in NUMBER
);
--========================================================================
-- PROCEDURE : ADD_LANGUAGE            		 PUBLIC
--
-- COMMENT   : Procedure adds new language
--========================================================================
PROCEDURE ADD_LANGUAGE;

END HZ_CREDIT_USAGE_RULE_SETS_PKG;

 

/
