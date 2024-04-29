--------------------------------------------------------
--  DDL for Package PA_ROLE_LIST_MEMBERS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_ROLE_LIST_MEMBERS_PVT" AUTHID CURRENT_USER AS
 /* $Header: PARLMPVS.pls 120.1 2005/08/19 16:55:24 mwasowic noship $ */
------------------------------------------------------------------------------
procedure INSERT_ROW (
  P_ROWID in out NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  P_ROLE_LIST_ID NUMBER,
  P_PROJECT_ROLE_ID NUMBER,
  P_CREATION_DATE DATE,
  P_CREATED_BY NUMBER,
  P_LAST_UPDATE_DATE DATE,
  P_LAST_UPDATED_BY NUMBER,
  P_LAST_UPDATE_LOGIN NUMBER,
  X_RETURN_STATUS out NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  X_MSG_COUNT out NOCOPY NUMBER, --File.Sql.39 bug 4440895
  X_MSG_DATA out NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
);
------------------------------------------------------------------------------
procedure LOCK_ROW (
  P_ROWID in out NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  P_RECORD_VERSION_NUMBER NUMBER,
  X_RETURN_STATUS out NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  X_MSG_COUNT out NOCOPY NUMBER, --File.Sql.39 bug 4440895
  X_MSG_DATA out NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);
------------------------------------------------------------------------------
procedure UPDATE_ROW (
  P_ROWID in out NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  P_ROLE_LIST_ID NUMBER,
  P_PROJECT_ROLE_ID VARCHAR2,
  P_CREATION_DATE DATE,
  P_CREATED_BY NUMBER,
  P_LAST_UPDATE_DATE DATE,
  P_LAST_UPDATED_BY NUMBER,
  P_LAST_UPDATE_LOGIN NUMBER,
  X_RETURN_STATUS out NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  X_MSG_COUNT out NOCOPY NUMBER, --File.Sql.39 bug 4440895
  X_MSG_DATA out NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);
------------------------------------------------------------------------------
procedure DELETE_ROW (
  P_ROWID VARCHAR2,
  X_RETURN_STATUS out NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  X_MSG_COUNT out NOCOPY NUMBER, --File.Sql.39 bug 4440895
  X_MSG_DATA out NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

end PA_ROLE_LIST_MEMBERS_PVT;
 

/
