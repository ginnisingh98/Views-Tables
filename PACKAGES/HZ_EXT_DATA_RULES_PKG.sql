--------------------------------------------------------
--  DDL for Package HZ_EXT_DATA_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_EXT_DATA_RULES_PKG" AUTHID CURRENT_USER AS
/* $Header: ARHEDRTS.pls 120.2 2005/10/30 03:52:09 appldev noship $ */

PROCEDURE INSERT_ROW (
  X_RULE_ID                         IN NUMBER,
  X_RULE_TYPE                       IN VARCHAR2,
  X_RULE_NAME                       IN VARCHAR2
);

PROCEDURE LOCK_ROW (
  X_RULE_ID                         IN NUMBER,
  X_RULE_TYPE                       IN VARCHAR2,
  X_RULE_NAME                       IN VARCHAR2
);

PROCEDURE UPDATE_ROW (
  X_RULE_ID                         IN NUMBER,
  X_RULE_NAME                       IN VARCHAR2
);

PROCEDURE DELETE_ROW (
  X_RULE_ID                         IN NUMBER
);

PROCEDURE ADD_LANGUAGE;

END HZ_EXT_DATA_RULES_PKG;

 

/
