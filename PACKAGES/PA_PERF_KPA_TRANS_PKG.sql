--------------------------------------------------------
--  DDL for Package PA_PERF_KPA_TRANS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PERF_KPA_TRANS_PKG" AUTHID CURRENT_USER as
/* $Header: PAPEKPTS.pls 120.1 2005/08/19 16:38:57 mwasowic noship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  X_KPA_SUMMARY_DET_ID in NUMBER,
  X_PERF_TXN_ID in NUMBER,
  X_CREATION_DATE in DATE ,
  X_CREATED_BY in NUMBER ,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER ,
  X_LAST_UPDATE_LOGIN in NUMBER
);

procedure UPDATE_ROW (
  X_KPA_SUMMARY_DET_ID in NUMBER,
  X_PERF_TXN_ID in NUMBER,
  X_LAST_UPDATE_DATE in DATE  ,
  X_LAST_UPDATED_BY in NUMBER ,
  X_LAST_UPDATE_LOGIN in NUMBER
);

procedure DELETE_ROW (
  X_KPA_SUMMARY_DET_ID in NUMBER,
  X_PERF_TXN_ID in NUMBER
);

end PA_PERF_KPA_TRANS_PKG;

 

/