--------------------------------------------------------
--  DDL for Package PA_PERF_CMTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PERF_CMTS_PKG" AUTHID CURRENT_USER as
/* $Header: PAPEECTS.pls 120.1 2005/08/19 16:38:28 mwasowic noship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  X_COMMENT_ID in NUMBER,
  X_PERF_TXN_ID in NUMBER,
  X_COMMENT_TEXT in VARCHAR2,
  X_COMMENTED_BY in NUMBER,
  X_COMMENT_DATE in DATE,
  X_CREATION_DATE in DATE DEFAULT sysdate,
  X_CREATED_BY in NUMBER DEFAULT fnd_global.user_id,
  X_LAST_UPDATE_DATE in DATE DEFAULT sysdate,
  X_LAST_UPDATED_BY in NUMBER DEFAULT fnd_global.user_id,
  X_LAST_UPDATE_LOGIN in NUMBER DEFAULT fnd_global.login_id
);

procedure UPDATE_ROW (
  X_COMMENT_ID in NUMBER,
  X_PERF_TXN_ID in NUMBER,
  X_COMMENT_TEXT in VARCHAR2,
  X_COMMENTED_BY in NUMBER,
  X_COMMENT_DATE in DATE,
  X_LAST_UPDATE_DATE in DATE  DEFAULT sysdate,
  X_LAST_UPDATED_BY in NUMBER DEFAULT fnd_global.user_id,
  X_LAST_UPDATE_LOGIN in NUMBER  DEFAULT fnd_global.login_id
);

procedure DELETE_ROW (
  X_COMMENT_ID in NUMBER
);

end PA_PERF_CMTS_PKG;


 

/
