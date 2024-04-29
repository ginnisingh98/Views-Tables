--------------------------------------------------------
--  DDL for Package PA_PERF_BZ_MEASURES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PERF_BZ_MEASURES_PKG" AUTHID CURRENT_USER as
/* $Header: PAPEBZTS.pls 120.1 2005/08/19 16:38:13 mwasowic noship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  X_MEASURE_ID in NUMBER,
  X_BZ_EVENT_CODE in VARCHAR2,
  X_CREATION_DATE in DATE DEFAULT sysdate,
  X_CREATED_BY in NUMBER DEFAULT fnd_global.user_id,
  X_LAST_UPDATE_DATE in DATE DEFAULT sysdate,
  X_LAST_UPDATED_BY in NUMBER DEFAULT fnd_global.user_id,
  X_LAST_UPDATE_LOGIN in NUMBER DEFAULT fnd_global.login_id
);

procedure UPDATE_ROW (
  X_MEASURE_ID in NUMBER,
  X_BZ_EVENT_CODE in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE  DEFAULT sysdate,
  X_LAST_UPDATED_BY in NUMBER DEFAULT fnd_global.user_id,
  X_LAST_UPDATE_LOGIN in NUMBER  DEFAULT fnd_global.login_id
);

procedure DELETE_ROW (
  X_MEASURE_ID in NUMBER
);

end PA_PERF_BZ_MEASURES_PKG;

 

/
