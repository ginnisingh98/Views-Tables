--------------------------------------------------------
--  DDL for Package Body CS_CF_SOURCE_CXT_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_CF_SOURCE_CXT_TYPES_PKG" as
/* $Header: CSCFCTYB.pls 120.0 2005/06/01 11:06:00 appldev noship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_SOURCE_CONTEXT_TYPE_ID in NUMBER,
  X_SOURCE_CODE in VARCHAR2,
  X_CONTEXT_TYPE in VARCHAR2,
  X_PRIORITY in NUMBER,
  X_SOURCE_TYPE in VARCHAR2,
  X_PURPOSE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from CS_CF_SOURCE_CXT_TYPES
    where SOURCE_CONTEXT_TYPE_ID = X_SOURCE_CONTEXT_TYPE_ID
    ;
begin
  insert into CS_CF_SOURCE_CXT_TYPES (
    SOURCE_CONTEXT_TYPE_ID,
    SOURCE_CODE,
    CONTEXT_TYPE,
    PRIORITY,
    SOURCE_TYPE,
    PURPOSE,
    OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_SOURCE_CONTEXT_TYPE_ID,
    X_SOURCE_CODE,
    X_CONTEXT_TYPE,
    X_PRIORITY,
    X_SOURCE_TYPE,
    X_PURPOSE,
    X_OBJECT_VERSION_NUMBER,
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

end INSERT_ROW;

procedure LOCK_ROW (
  X_SOURCE_CONTEXT_TYPE_ID in NUMBER,
  X_SOURCE_CODE in VARCHAR2,
  X_CONTEXT_TYPE in VARCHAR2,
  X_PRIORITY in NUMBER,
  X_SOURCE_TYPE in VARCHAR2,
  X_PURPOSE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER
) is
  cursor c is select
      SOURCE_CODE,
      CONTEXT_TYPE,
      PRIORITY,
      SOURCE_TYPE,
	 PURPOSE,
      OBJECT_VERSION_NUMBER
    from CS_CF_SOURCE_CXT_TYPES
    where SOURCE_CONTEXT_TYPE_ID = X_SOURCE_CONTEXT_TYPE_ID
    for update of SOURCE_CONTEXT_TYPE_ID nowait;
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
  if (    ((recinfo.SOURCE_CODE = X_SOURCE_CODE)
           OR ((recinfo.SOURCE_CODE is null) AND (X_SOURCE_CODE is null)))
      AND ((recinfo.CONTEXT_TYPE = X_CONTEXT_TYPE)
           OR ((recinfo.CONTEXT_TYPE is null) AND (X_CONTEXT_TYPE is null)))
      AND ((recinfo.PRIORITY = X_PRIORITY)
           OR ((recinfo.PRIORITY is null) AND (X_PRIORITY is null)))
      AND ((recinfo.SOURCE_TYPE = X_SOURCE_TYPE)
           OR ((recinfo.SOURCE_TYPE is null) AND (X_SOURCE_TYPE is null)))
      AND ((recinfo.PURPOSE = X_PURPOSE)
           OR ((recinfo.PURPOSE is null) AND (X_PURPOSE is null)))
      AND ((recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
           OR ((recinfo.OBJECT_VERSION_NUMBER is null) AND (X_OBJECT_VERSION_NUMBER is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_SOURCE_CONTEXT_TYPE_ID in NUMBER,
  X_SOURCE_CODE in VARCHAR2,
  X_CONTEXT_TYPE in VARCHAR2,
  X_PRIORITY in NUMBER,
  X_SOURCE_TYPE in VARCHAR2,
  X_PURPOSE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update CS_CF_SOURCE_CXT_TYPES set
    SOURCE_CODE = X_SOURCE_CODE,
    CONTEXT_TYPE = X_CONTEXT_TYPE,
    PRIORITY = X_PRIORITY,
    SOURCE_TYPE = X_SOURCE_TYPE,
    PURPOSE = X_PURPOSE,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where SOURCE_CONTEXT_TYPE_ID = X_SOURCE_CONTEXT_TYPE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW;

procedure DELETE_ROW (
  X_SOURCE_CONTEXT_TYPE_ID in NUMBER
) is
begin

  delete from CS_CF_SOURCE_CXT_TYPES
  where SOURCE_CONTEXT_TYPE_ID = X_SOURCE_CONTEXT_TYPE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure LOAD_ROW (
  X_SOURCE_CONTEXT_TYPE_ID in NUMBER,
  X_SOURCE_CODE in VARCHAR2,
  X_CONTEXT_TYPE in VARCHAR2,
  X_PRIORITY in NUMBER,
  X_SOURCE_TYPE in VARCHAR2,
  X_PURPOSE in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_CUSTOM_MODE in VARCHAR2
) IS

  f_luby number ; -- entity owner in file
  f_ludate date ; -- entity update date in file
  db_luby  number; -- entity owner in db
  db_ludate date; -- entity update date in db

  l_object_version_number number := 1;
  l_rowid varchar2(50);

begin

  f_luby := fnd_load_util.owner_id(X_OWNER);
  f_ludate := nvl(X_LAST_UPDATE_DATE, sysdate);

  select LAST_UPDATED_BY, LAST_UPDATE_DATE
  into db_luby, db_ludate
  from CS_CF_SOURCE_CXT_TYPES
  where source_context_type_id = X_SOURCE_CONTEXT_TYPE_ID;

  if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby, db_ludate, X_CUSTOM_MODE)) then
    -- Update existing row
    SELECT object_version_number, rowid
    INTO l_object_version_number, l_rowid
    FROM CS_CF_SOURCE_CXT_TYPES
    WHERE source_context_type_id = X_SOURCE_CONTEXT_TYPE_ID
    FOR UPDATE;

    CS_CF_SOURCE_CXT_TYPES_PKG.Update_Row(
	 X_SOURCE_CONTEXT_TYPE_ID => X_SOURCE_CONTEXT_TYPE_ID,
	 X_SOURCE_CODE => X_SOURCE_CODE,
	 X_CONTEXT_TYPE => X_CONTEXT_TYPE,
	 X_PRIORITY => X_PRIORITY,
	 X_SOURCE_TYPE => X_SOURCE_TYPE,
	 X_PURPOSE => X_PURPOSE,
	 X_OBJECT_VERSION_NUMBER => l_object_version_number + 1,
	 X_LAST_UPDATE_DATE => f_ludate,
	 X_LAST_UPDATED_BY => f_luby,
	 X_LAST_UPDATE_LOGIN => 0);
  end if;
  exception
    when no_data_found then
	 -- Record doesn't exist - insert in all cases
	 CS_CF_SOURCE_CXT_TYPES_PKG.Insert_Row(
	   X_ROWID => l_rowid,
	   X_SOURCE_CONTEXT_TYPE_ID => X_SOURCE_CONTEXT_TYPE_ID,
	   X_SOURCE_CODE => X_SOURCE_CODE,
	   X_CONTEXT_TYPE => X_CONTEXT_TYPE,
	   X_PRIORITY => X_PRIORITY,
	   X_SOURCE_TYPE => X_SOURCE_TYPE,
	   X_PURPOSE => X_PURPOSE,
	   X_OBJECT_VERSION_NUMBER => l_object_version_number,
	   X_CREATION_DATE => sysdate,
	   X_CREATED_BY => f_luby,
	   X_LAST_UPDATE_DATE => f_ludate,
	   X_LAST_UPDATED_BY => f_luby,
	   X_LAST_UPDATE_LOGIN => 0);
end LOAD_ROW;

end CS_CF_SOURCE_CXT_TYPES_PKG;

/
