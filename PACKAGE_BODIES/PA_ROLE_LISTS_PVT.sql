--------------------------------------------------------
--  DDL for Package Body PA_ROLE_LISTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_ROLE_LISTS_PVT" AS
 /* $Header: PARLTPVB.pls 120.1 2005/08/19 16:55:54 mwasowic noship $ */
------------------------------------------------------------------------------
procedure INSERT_ROW (
  P_ROWID in out NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  P_ROLE_LIST_ID NUMBER,
  P_NAME VARCHAR2,
  P_START_DATE_ACTIVE DATE,
  P_END_DATE_ACTIVE DATE,
  P_DESCRIPTION VARCHAR2,
  P_ATTRIBUTE_CATEGORY VARCHAR2,
  P_ATTRIBUTE1 VARCHAR2,
  P_ATTRIBUTE2 VARCHAR2,
  P_ATTRIBUTE3 VARCHAR2,
  P_ATTRIBUTE4 VARCHAR2,
  P_ATTRIBUTE5 VARCHAR2,
  P_ATTRIBUTE6 VARCHAR2,
  P_ATTRIBUTE7 VARCHAR2,
  P_ATTRIBUTE8 VARCHAR2,
  P_ATTRIBUTE9 VARCHAR2,
  P_ATTRIBUTE10 VARCHAR2,
  P_ATTRIBUTE11 VARCHAR2,
  P_ATTRIBUTE12 VARCHAR2,
  P_ATTRIBUTE13 VARCHAR2,
  P_ATTRIBUTE14 VARCHAR2,
  P_ATTRIBUTE15 VARCHAR2,
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
  PA_DEBUG.init_err_stack('PA_ROLE_LISTS_PVT.INSERT_ROW');

  -- Check for duplicate row list names
  PA_ROLE_UTILS.CHECK_DUP_ROLE_LIST_NAME(
    p_name,
    X_RETURN_STATUS,
    X_MSG_DATA);

  if X_RETURN_STATUS = FND_API.G_RET_STS_SUCCESS then
    --call table handler to insert the row
    PA_ROLE_LISTS_PKG.INSERT_ROW(
      P_ROWID,
      P_ROLE_LIST_ID,
      P_NAME,
      P_START_DATE_ACTIVE,
      P_END_DATE_ACTIVE,
      P_DESCRIPTION,
      P_ATTRIBUTE_CATEGORY,
      P_ATTRIBUTE1,
      P_ATTRIBUTE2,
      P_ATTRIBUTE3,
      P_ATTRIBUTE4,
      P_ATTRIBUTE5,
      P_ATTRIBUTE6,
      P_ATTRIBUTE7,
      P_ATTRIBUTE8,
      P_ATTRIBUTE9,
      P_ATTRIBUTE10,
      P_ATTRIBUTE11,
      P_ATTRIBUTE12,
      P_ATTRIBUTE13,
      P_ATTRIBUTE14,
      P_ATTRIBUTE15,
      P_CREATION_DATE,
      P_CREATED_BY,
      P_LAST_UPDATE_DATE,
      P_LAST_UPDATED_BY,
      P_LAST_UPDATE_LOGIN);

    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
    X_MSG_COUNT := 0;
    X_MSG_DATA := NULL;
    PA_DEBUG.reset_err_stack;
  else
    X_MSG_COUNT := 1;
    FND_MSG_PUB.add_exc_msg(
      p_pkg_name => 'PA_ROLE_LISTS_PVT',
      p_procedure_name => PA_DEBUG.G_err_stack,
      p_error_text => X_MSG_DATA);
  end if;

exception
  when others then
    X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
    X_MSG_COUNT := 1;
    X_MSG_DATA := substr(SQLERRM, 1, 240);
    FND_MSG_PUB.add_exc_msg(
      p_pkg_name => 'PA_ROLE_LISTS_PVT',
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
  PA_DEBUG.init_err_stack('PA_ROLE_LISTS_PVT.LOCK_ROW');
  --any validation to be added here ?
  --call table handler to lock the row
  PA_ROLE_LISTS_PKG.LOCK_ROW(
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
      p_pkg_name => 'PA_ROLE_LISTS_PVT',
      p_procedure_name => PA_DEBUG.G_err_stack,
      p_error_text => X_MSG_DATA);
end;

------------------------------------------------------------------------------
procedure UPDATE_ROW (
  P_ROWID in out NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  P_ROLE_LIST_ID NUMBER,
  P_NAME VARCHAR2,
  P_START_DATE_ACTIVE DATE,
  P_END_DATE_ACTIVE DATE,
  P_DESCRIPTION VARCHAR2,
  P_ATTRIBUTE_CATEGORY VARCHAR2,
  P_ATTRIBUTE1 VARCHAR2,
  P_ATTRIBUTE2 VARCHAR2,
  P_ATTRIBUTE3 VARCHAR2,
  P_ATTRIBUTE4 VARCHAR2,
  P_ATTRIBUTE5 VARCHAR2,
  P_ATTRIBUTE6 VARCHAR2,
  P_ATTRIBUTE7 VARCHAR2,
  P_ATTRIBUTE8 VARCHAR2,
  P_ATTRIBUTE9 VARCHAR2,
  P_ATTRIBUTE10 VARCHAR2,
  P_ATTRIBUTE11 VARCHAR2,
  P_ATTRIBUTE12 VARCHAR2,
  P_ATTRIBUTE13 VARCHAR2,
  P_ATTRIBUTE14 VARCHAR2,
  P_ATTRIBUTE15 VARCHAR2,
  P_CREATION_DATE DATE,
  P_CREATED_BY NUMBER,
  P_LAST_UPDATE_DATE DATE,
  P_LAST_UPDATED_BY NUMBER,
  P_LAST_UPDATE_LOGIN NUMBER,
  X_RETURN_STATUS out NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  X_MSG_COUNT out NOCOPY NUMBER, --File.Sql.39 bug 4440895
  X_MSG_DATA out NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) is
  v_name  PA_ROLE_LISTS.name%TYPE;
begin
  PA_DEBUG.init_err_stack('PA_ROLE_LISTS_PVT.UPDATE_ROW');

  select name
  into v_name
  from pa_role_lists
  where rowid = p_rowid;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  if v_name <> p_name then
    -- Check for duplicate row list names
    PA_ROLE_UTILS.CHECK_DUP_ROLE_LIST_NAME(
      p_name,
      X_RETURN_STATUS,
      X_MSG_DATA);
  end if;

  if X_RETURN_STATUS = FND_API.G_RET_STS_SUCCESS then
    --call table handler to update the row
    PA_ROLE_LISTS_PKG.UPDATE_ROW(
      P_ROWID,
      P_ROLE_LIST_ID,
      P_NAME,
      P_START_DATE_ACTIVE,
      P_END_DATE_ACTIVE,
      P_DESCRIPTION,
      P_ATTRIBUTE_CATEGORY,
      P_ATTRIBUTE1,
      P_ATTRIBUTE2,
      P_ATTRIBUTE3,
      P_ATTRIBUTE4,
      P_ATTRIBUTE5,
      P_ATTRIBUTE6,
      P_ATTRIBUTE7,
      P_ATTRIBUTE8,
      P_ATTRIBUTE9,
      P_ATTRIBUTE10,
      P_ATTRIBUTE11,
      P_ATTRIBUTE12,
      P_ATTRIBUTE13,
      P_ATTRIBUTE14,
      P_ATTRIBUTE15,
      P_CREATION_DATE,
      P_CREATED_BY,
      P_LAST_UPDATE_DATE,
      P_LAST_UPDATED_BY,
      P_LAST_UPDATE_LOGIN);

    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
    X_MSG_COUNT := 0;
    X_MSG_DATA := NULL;
    PA_DEBUG.reset_err_stack;
  else
    X_MSG_COUNT := 1;
    FND_MSG_PUB.add_exc_msg(
      p_pkg_name => 'PA_ROLE_LISTS_PVT',
      p_procedure_name => PA_DEBUG.G_err_stack,
      p_error_text => X_MSG_DATA);
  end if;

exception
  when others then
    X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
    X_MSG_COUNT := 1;
    X_MSG_DATA := substr(SQLERRM, 1, 240);
    FND_MSG_PUB.add_exc_msg(
      p_pkg_name => 'PA_ROLE_LISTS_PVT',
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
  PA_DEBUG.init_err_stack('PA_ROLE_LISTS_PVT.DELETE_ROW');
  --validate if the role list can be deleted or not
  select role_list_id
  into v_role_list_id
  from pa_role_lists
  where rowid = P_ROWID;

  PA_ROLE_UTILS.CHECK_DELETE_ROLE_LIST_OK(
    v_role_list_id,
    X_RETURN_STATUS,
    X_MSG_DATA);

  if X_RETURN_STATUS = FND_API.G_RET_STS_SUCCESS then
    ----call the table handler to delete role list
    PA_ROLE_LISTS_PKG.DELETE_ROW(P_ROWID);

    delete from PA_ROLE_LIST_MEMBERS
    where ROLE_LIST_ID = v_role_list_id;

    X_MSG_COUNT := 0;
    X_MSG_DATA := NULL;
    PA_DEBUG.reset_err_stack;

  else
    X_MSG_COUNT := 1;
    FND_MSG_PUB.add_exc_msg(
      p_pkg_name => 'PA_ROLE_LISTS_PVT',
      p_procedure_name => PA_DEBUG.G_err_stack,
      p_error_text => X_MSG_DATA);
  end if;

exception
  when others then
    X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
    X_MSG_COUNT := 1;
    X_MSG_DATA := substr(SQLERRM, 1, 240);
    FND_MSG_PUB.add_exc_msg(
      p_pkg_name => 'PA_ROLE_LISTS_PVT',
      p_procedure_name => PA_DEBUG.G_err_stack,
      p_error_text => X_MSG_DATA);
end;

end PA_ROLE_LISTS_PVT;

/
