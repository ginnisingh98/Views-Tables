--------------------------------------------------------
--  DDL for Package IEU_UWQ_LOGIN_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEU_UWQ_LOGIN_RULES_PKG" AUTHID CURRENT_USER as
/* $Header: IEULRULS.pls 120.1 2005/06/16 02:31:46 appldev  $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_SVR_LOGIN_RULE_ID IN NUMBER,
  X_LOGIN_RULE_TYPE IN VARCHAR2,
  X_LOGIN_RULE IN VARCHAR2,
  X_LOGIN_RULE_NAME IN VARCHAR2,
  X_LOGIN_RULE_DESC IN VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);

procedure LOCK_ROW (
  X_SVR_LOGIN_RULE_ID IN NUMBER,
  X_LOGIN_RULE_TYPE IN VARCHAR2,
  X_LOGIN_RULE IN VARCHAR2,
  X_LOGIN_RULE_NAME IN VARCHAR2,
  X_LOGIN_RULE_DESC IN VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER
);

procedure UPDATE_ROW (
  X_SVR_LOGIN_RULE_ID IN NUMBER,
  X_LOGIN_RULE_TYPE IN VARCHAR2,
  X_LOGIN_RULE IN VARCHAR2,
  X_LOGIN_RULE_NAME IN VARCHAR2,
  X_LOGIN_RULE_DESC IN VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);

procedure DELETE_ROW (
  X_SVR_LOGIN_RULE_ID IN NUMBER
);

procedure ADD_LANGUAGE;

procedure LOAD_ROW (
  X_SVR_LOGIN_RULE_ID IN NUMBER,
  X_LOGIN_RULE_TYPE IN VARCHAR2,
  X_LOGIN_RULE IN VARCHAR2,
  X_LOGIN_RULE_NAME IN VARCHAR2,
  X_LOGIN_RULE_DESC IN VARCHAR2,
  X_OWNER in VARCHAR2
);

procedure TRANSLATE_ROW (
  X_SVR_LOGIN_RULE_ID IN NUMBER,
  X_LOGIN_RULE_NAME IN VARCHAR2,
  X_LOGIN_RULE_DESC IN VARCHAR2,
  X_OWNER in VARCHAR2
);

procedure LOAD_SEED_ROW (
  X_UPLOAD_MODE IN VARCHAR2,
  X_SVR_LOGIN_RULE_ID IN NUMBER,
  X_LOGIN_RULE_TYPE IN VARCHAR2,
  X_LOGIN_RULE IN VARCHAR2,
  X_LOGIN_RULE_NAME IN VARCHAR2,
  X_LOGIN_RULE_DESC IN VARCHAR2,
  X_OWNER in VARCHAR2
);


end IEU_UWQ_LOGIN_RULES_PKG;

 

/
