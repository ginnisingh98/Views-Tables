--------------------------------------------------------
--  DDL for Package Body PA_OBJ_STATUS_LISTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_OBJ_STATUS_LISTS_PKG" as
/* $Header: PAOBSLTB.pls 120.1 2005/08/19 16:36:53 mwasowic noship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  X_OBJ_STATUS_LIST_ID in NUMBER,
  X_OBJECT_TYPE in VARCHAR2,
  X_OBJECT_ID in NUMBER,
  X_STATUS_LIST_ID in NUMBER,
  X_STATUS_TYPE in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from PA_OBJ_STATUS_LISTS
    where OBJ_STATUS_LIST_ID = X_OBJ_STATUS_LIST_ID
    ;
begin
  insert into PA_OBJ_STATUS_LISTS (
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    LAST_UPDATE_DATE,
    CREATION_DATE,
    OBJ_STATUS_LIST_ID,
    OBJECT_TYPE,
    OBJECT_ID,
    STATUS_LIST_ID,
    STATUS_TYPE
  ) values (
    nvl(X_LAST_UPDATED_BY,fnd_global.user_id),
    nvl(X_LAST_UPDATE_LOGIN,fnd_global.login_id),
    nvl(X_CREATED_BY,fnd_global.user_id),
    nvl(X_LAST_UPDATE_DATE,sysdate),
    nvl(X_CREATION_DATE,sysdate),
    X_OBJ_STATUS_LIST_ID,
    X_OBJECT_TYPE,
    X_OBJECT_ID,
    X_STATUS_LIST_ID,
    X_STATUS_TYPE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_OBJ_STATUS_LIST_ID in NUMBER,
  X_OBJECT_TYPE in VARCHAR2,
  X_OBJECT_ID in NUMBER,
  X_STATUS_LIST_ID in NUMBER,
  X_STATUS_TYPE in VARCHAR2
) is
  cursor c1 is select
      OBJECT_TYPE,
      OBJECT_ID,
      STATUS_LIST_ID,
      STATUS_TYPE,
      OBJ_STATUS_LIST_ID
    from PA_OBJ_STATUS_LISTS
    where OBJ_STATUS_LIST_ID = X_OBJ_STATUS_LIST_ID
    for update of OBJ_STATUS_LIST_ID nowait;
begin
  for tlinfo in c1 loop
      if (    ((tlinfo.OBJ_STATUS_LIST_ID = X_OBJ_STATUS_LIST_ID)
               OR ((tlinfo.OBJ_STATUS_LIST_ID is null) AND (X_OBJ_STATUS_LIST_ID is null)))
          AND ((tlinfo.OBJECT_TYPE = X_OBJECT_TYPE)
               OR ((tlinfo.OBJECT_TYPE is null) AND (X_OBJECT_TYPE is null)))
          AND ((tlinfo.OBJECT_ID = X_OBJECT_ID)
               OR ((tlinfo.OBJECT_ID is null) AND (X_OBJECT_ID is null)))
          AND ((tlinfo.STATUS_LIST_ID = X_STATUS_LIST_ID)
               OR ((tlinfo.STATUS_LIST_ID is null) AND (X_STATUS_LIST_ID is null)))
          AND ((tlinfo.STATUS_TYPE = X_STATUS_TYPE)
               OR ((tlinfo.STATUS_TYPE is null) AND (X_STATUS_TYPE is null)))
      ) then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
  end loop;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_OBJ_STATUS_LIST_ID in NUMBER,
  X_OBJECT_TYPE in VARCHAR2,
  X_OBJECT_ID in NUMBER,
  X_STATUS_LIST_ID in NUMBER,
  X_STATUS_TYPE in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update PA_OBJ_STATUS_LISTS set
    OBJECT_TYPE = X_OBJECT_TYPE,
    OBJECT_ID = X_OBJECT_ID,
    STATUS_LIST_ID = X_STATUS_LIST_ID,
    STATUS_TYPE = X_STATUS_TYPE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where OBJ_STATUS_LIST_ID = X_OBJ_STATUS_LIST_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_OBJ_STATUS_LIST_ID in NUMBER
) is
begin
  delete from PA_OBJ_STATUS_LISTS
  where OBJ_STATUS_LIST_ID = X_OBJ_STATUS_LIST_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

end PA_OBJ_STATUS_LISTS_PKG;

/
