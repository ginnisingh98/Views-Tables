--------------------------------------------------------
--  DDL for Package Body PA_CI_TYPE_USAGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CI_TYPE_USAGE_PKG" as
/* $Header: PACITUTB.pls 120.2 2005/08/22 05:14:57 sukhanna noship $ */
procedure INSERT_ROW (
  X_ROWID out NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  X_CI_TYPE_USAGE_ID out NOCOPY NUMBER, --File.Sql.39 bug 4440895
  X_PROJECT_TYPE_ID in NUMBER,
  X_CI_TYPE_ID in NUMBER,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from PA_CI_TYPE_USAGE
    where CI_TYPE_USAGE_ID = X_CI_TYPE_USAGE_ID
    ;
begin
  SELECT pa_ci_type_usage_s.NEXTVAL
  INTO X_CI_TYPE_USAGE_ID
  FROM sys.dual;

  insert into PA_CI_TYPE_USAGE (
    CI_TYPE_USAGE_ID,
    PROJECT_TYPE_ID,
    CI_TYPE_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_CI_TYPE_USAGE_ID,
    X_PROJECT_TYPE_ID,
    X_CI_TYPE_ID,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );
  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

  exception --Added for bug 4565156
      when others then
       x_rowid := null;
       x_ci_type_usage_id := null;
       raise;

end INSERT_ROW;

procedure UPDATE_ROW (
  X_CI_TYPE_USAGE_ID in NUMBER,
  X_PROJECT_TYPE_ID in NUMBER,
  X_CI_TYPE_ID in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update PA_CI_TYPE_USAGE set
    PROJECT_TYPE_ID = X_PROJECT_TYPE_ID,
    CI_TYPE_ID = X_CI_TYPE_ID,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ci_type_usage_id = X_CI_TYPE_USAGE_ID;
end UPDATE_ROW;

procedure LOCK_ROW (
  X_CI_TYPE_USAGE_ID in NUMBER,
  X_PROJECT_TYPE_ID in NUMBER,
  X_CI_TYPE_ID in NUMBER
) is
  cursor c is select
      PROJECT_TYPE_ID,
      CI_TYPE_ID
    from PA_CI_TYPE_USAGE
    where CI_TYPE_USAGE_ID = X_CI_TYPE_USAGE_ID
    for update of CI_TYPE_USAGE_ID nowait;
  recinfo c%rowtype;

begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.PROJECT_TYPE_ID = X_PROJECT_TYPE_ID)
      AND (recinfo.CI_TYPE_ID = X_CI_TYPE_ID)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  return;
end LOCK_ROW;


procedure DELETE_ROW (
  X_CI_TYPE_USAGE_ID in NUMBER
) is
begin
  delete from PA_CI_TYPE_USAGE
  where CI_TYPE_USAGE_ID = X_CI_TYPE_USAGE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;


end PA_CI_TYPE_USAGE_PKG;

/
