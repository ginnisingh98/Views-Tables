--------------------------------------------------------
--  DDL for Package Body PA_ROLE_LIST_MEMBERS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_ROLE_LIST_MEMBERS_PVT" AS
 /* $Header: PARLMPVB.pls 120.1 2005/08/19 16:55:21 mwasowic noship $ */
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
) is
begin
  PA_DEBUG.init_err_stack('PA_ROLE_LIST_MEMBERS_PVT.INSERT_ROW');
  --any validation to be added here ?
  --call table handler to insert the row
  PA_ROLE_LIST_MEMBERS_PKG.INSERT_ROW(
    P_ROWID,
    P_ROLE_LIST_ID,
    P_PROJECT_ROLE_ID,
    P_CREATION_DATE,
    P_CREATED_BY,
    P_LAST_UPDATE_DATE,
    P_LAST_UPDATED_BY,
    P_LAST_UPDATE_LOGIN);

  X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
  X_MSG_COUNT := 0;
  X_MSG_DATA := NULL;
  PA_DEBUG.reset_err_stack;

exception
  when others then
    X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
    X_MSG_COUNT := 1;
    X_MSG_DATA := substr(SQLERRM, 1, 240);
    FND_MSG_PUB.add_exc_msg(
      p_pkg_name => 'PA_ROLE_LIST_MEMBERS_PVT',
      p_procedure_name => PA_DEBUG.G_err_stack,
      p_error_text => X_MSG_DATA);
end;

------------------------------------------------------------------------------
procedure LOCK_ROW (
  P_ROWID in out NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  P_RECORD_VERSION_NUMBER NUMBER,
  X_RETURN_STATUS out NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  X_MSG_COUNT out NOCOPY NUMBER, --File.Sql.39 bug 4440895
  X_MSG_DATA out NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) is
begin
  PA_DEBUG.init_err_stack('PA_ROLE_LIST_MEMBERS_PVT.LOCK_ROW');
  --any validation to be added here ?
  --call table handler to lock the row
  PA_ROLE_LIST_MEMBERS_PKG.LOCK_ROW(
    P_ROWID,
    P_RECORD_VERSION_NUMBER);

  X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
  X_MSG_COUNT := 0;
  X_MSG_DATA := NULL;
  PA_DEBUG.reset_err_stack;

exception
  when others then
    X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
    X_MSG_COUNT := 1;
    X_MSG_DATA := substr(SQLERRM, 1, 240);
    FND_MSG_PUB.add_exc_msg(
      p_pkg_name => 'PA_ROLE_LIST_MEMBERS_PVT',
      p_procedure_name => PA_DEBUG.G_err_stack,
      p_error_text => X_MSG_DATA);
end;

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
) is
begin
  PA_DEBUG.init_err_stack('PA_ROLE_LIST_MEMBERS_PVT.UPDATE_ROW');
  --any validation to be added here ?
  --call table handler to update the row
  PA_ROLE_LIST_MEMBERS_PKG.UPDATE_ROW(
    P_ROWID,
    P_ROLE_LIST_ID,
    P_PROJECT_ROLE_ID,
    P_CREATION_DATE,
    P_CREATED_BY,
    P_LAST_UPDATE_DATE,
    P_LAST_UPDATED_BY,
    P_LAST_UPDATE_LOGIN);

  X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
  X_MSG_COUNT := 0;
  X_MSG_DATA := NULL;
  PA_DEBUG.reset_err_stack;

exception
  when others then
    X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
    X_MSG_COUNT := 1;
    X_MSG_DATA := substr(SQLERRM, 1, 240);
    FND_MSG_PUB.add_exc_msg(
      p_pkg_name => 'PA_ROLE_LIST_MEMBERS_PVT',
      p_procedure_name => PA_DEBUG.G_err_stack,
      p_error_text => X_MSG_DATA);
end;

------------------------------------------------------------------------------
procedure DELETE_ROW (
  P_ROWID VARCHAR2,
  X_RETURN_STATUS out NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  X_MSG_COUNT out NOCOPY NUMBER, --File.Sql.39 bug 4440895
  X_MSG_DATA out NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) is
 v_role_list_id  number;
begin
  PA_DEBUG.init_err_stack('PA_ROLE_LIST_MEMBERS_PVT.DELETE_ROW');
  --any validation to be added here ?
  --call table handler to delete the row
  PA_ROLE_LIST_MEMBERS_PKG.DELETE_ROW(P_ROWID);

  X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
  X_MSG_COUNT := 0;
  X_MSG_DATA := NULL;
  PA_DEBUG.reset_err_stack;

exception
  when others then
    X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
    X_MSG_COUNT := 1;
    X_MSG_DATA := substr(SQLERRM, 1, 240);
    FND_MSG_PUB.add_exc_msg(
      p_pkg_name => 'PA_ROLE_LIST_MEMBERS_PVT',
      p_procedure_name => PA_DEBUG.G_err_stack,
      p_error_text => X_MSG_DATA);
end;

end PA_ROLE_LIST_MEMBERS_PVT;

/
