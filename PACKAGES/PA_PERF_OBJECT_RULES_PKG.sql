--------------------------------------------------------
--  DDL for Package PA_PERF_OBJECT_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PERF_OBJECT_RULES_PKG" AUTHID CURRENT_USER as
/* $Header: PAPEORTS.pls 120.1 2005/08/19 16:39:10 mwasowic noship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  X_OBJECT_RULE_ID in NUMBER,
  X_OBJECT_TYPE in VARCHAR2,
  X_OBJECT_ID in NUMBER,
  X_RULE_ID in NUMBER,
  X_RECORD_VERSION_NUMBER in NUMBER DEFAULT 1,
  X_CREATION_DATE in DATE DEFAULT sysdate ,
  X_CREATED_BY in NUMBER DEFAULT fnd_global.user_id,
  X_LAST_UPDATE_DATE in DATE DEFAULT sysdate,
  X_LAST_UPDATED_BY in NUMBER DEFAULT fnd_global.user_id,
  X_LAST_UPDATE_LOGIN in NUMBER DEFAULT fnd_global.login_id
);

procedure LOCK_ROW (
  X_OBJECT_RULE_ID in NUMBER,
  X_RECORD_VERSION_NUMBER in NUMBER
);

procedure UPDATE_ROW (
  X_OBJECT_RULE_ID in NUMBER,
  X_OBJECT_TYPE in VARCHAR2,
  X_OBJECT_ID in NUMBER,
  X_RULE_ID in NUMBER,
  X_RECORD_VERSION_NUMBER in NUMBER,
  X_LAST_UPDATE_DATE in DATE  DEFAULT sysdate,
  X_LAST_UPDATED_BY in NUMBER DEFAULT fnd_global.user_id,
  X_LAST_UPDATE_LOGIN in NUMBER  DEFAULT fnd_global.login_id
);

procedure DELETE_ROW (
  X_OBJECT_RULE_ID in NUMBER
);

end PA_PERF_OBJECT_RULES_PKG;

 

/