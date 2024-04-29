--------------------------------------------------------
--  DDL for Package Body CS_CF_FLOW_TYPE_PAGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_CF_FLOW_TYPE_PAGES_PKG" as
/* $Header: CSCFFTYB.pls 120.0 2005/06/01 12:32:33 appldev noship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_FLOW_TYPE_PAGE_ID in NUMBER,
  X_FLOW_TYPE_CODE in VARCHAR2,
  X_PAGE_CODE in VARCHAR2,
  X_SEQUENCE in NUMBER,
  X_FUNCTION_NAME in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from CS_CF_FLOW_TYPE_PAGES
    where FLOW_TYPE_PAGE_ID = X_FLOW_TYPE_PAGE_ID
    ;
begin
  insert into CS_CF_FLOW_TYPE_PAGES (
    FLOW_TYPE_PAGE_ID,
    FLOW_TYPE_CODE,
    PAGE_CODE,
    SEQUENCE,
    FUNCTION_NAME,
    OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_FLOW_TYPE_PAGE_ID,
    X_FLOW_TYPE_CODE,
    X_PAGE_CODE,
    X_SEQUENCE,
    X_FUNCTION_NAME,
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
  X_FLOW_TYPE_PAGE_ID in NUMBER,
  X_FLOW_TYPE_CODE in VARCHAR2,
  X_PAGE_CODE in VARCHAR2,
  X_SEQUENCE in NUMBER,
  X_FUNCTION_NAME in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER
) is
  cursor c is select
      FLOW_TYPE_CODE,
      PAGE_CODE,
      SEQUENCE,
      FUNCTION_NAME,
      OBJECT_VERSION_NUMBER
    from CS_CF_FLOW_TYPE_PAGES
    where FLOW_TYPE_PAGE_ID = X_FLOW_TYPE_PAGE_ID
    for update of FLOW_TYPE_PAGE_ID nowait;
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
  if (    ((recinfo.FLOW_TYPE_CODE = X_FLOW_TYPE_CODE)
           OR ((recinfo.FLOW_TYPE_CODE is null) AND (X_FLOW_TYPE_CODE is null)))
      AND ((recinfo.PAGE_CODE = X_PAGE_CODE)
           OR ((recinfo.PAGE_CODE is null) AND (X_PAGE_CODE is null)))
      AND ((recinfo.SEQUENCE = X_SEQUENCE)
           OR ((recinfo.SEQUENCE is null) AND (X_SEQUENCE is null)))
      AND ((recinfo.FUNCTION_NAME = X_FUNCTION_NAME)
           OR ((recinfo.FUNCTION_NAME is null) AND (X_FUNCTION_NAME is null)))
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
  X_FLOW_TYPE_PAGE_ID in NUMBER,
  X_FLOW_TYPE_CODE in VARCHAR2,
  X_PAGE_CODE in VARCHAR2,
  X_SEQUENCE in NUMBER,
  X_FUNCTION_NAME in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update CS_CF_FLOW_TYPE_PAGES set
    FLOW_TYPE_CODE = X_FLOW_TYPE_CODE,
    PAGE_CODE = X_PAGE_CODE,
    SEQUENCE = X_SEQUENCE,
    FUNCTION_NAME = X_FUNCTION_NAME,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where FLOW_TYPE_PAGE_ID = X_FLOW_TYPE_PAGE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW;

procedure DELETE_ROW (
  X_FLOW_TYPE_PAGE_ID in NUMBER
) is
begin

  delete from CS_CF_FLOW_TYPE_PAGES
  where FLOW_TYPE_PAGE_ID = X_FLOW_TYPE_PAGE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;


procedure LOAD_ROW (
  X_FLOW_TYPE_PAGE_ID in NUMBER,
  X_FLOW_TYPE_CODE in VARCHAR2,
  X_PAGE_CODE in VARCHAR2,
  X_SEQUENCE in NUMBER,
  X_FUNCTION_NAME in VARCHAR2,
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
  from CS_CF_FLOW_TYPE_PAGES
  where flow_type_page_id = X_FLOW_TYPE_PAGE_ID;

  if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby, db_ludate, X_CUSTOM_MODE)) then
    -- Update existing row
    SELECT object_version_number, rowid
    INTO l_object_version_number, l_rowid
    FROM CS_CF_FLOW_TYPE_PAGES
    WHERE flow_type_page_id = X_FLOW_TYPE_PAGE_ID
    FOR UPDATE ;

    CS_CF_FLOW_TYPE_PAGES_PKG.Update_Row(
	 X_FLOW_TYPE_PAGE_ID => X_FLOW_TYPE_PAGE_ID,
	 X_FLOW_TYPE_CODE => X_FLOW_TYPE_CODE,
	 X_PAGE_CODE => X_PAGE_CODE,
	 X_SEQUENCE => X_SEQUENCE,
	 X_FUNCTION_NAME => X_FUNCTION_NAME,
	 X_OBJECT_VERSION_NUMBER => l_object_version_number + 1,
	 X_LAST_UPDATE_DATE => f_ludate,
	 X_LAST_UPDATED_BY => f_luby,
	 X_LAST_UPDATE_LOGIN => 0);
  end if;
  exception
    when no_data_found then
	 -- Record doesn't exist - insert in all cases
	 CS_CF_FLOW_TYPE_PAGES_PKG.Insert_Row(
	   X_ROWID => l_rowid,
	   X_FLOW_TYPE_PAGE_ID => X_FLOW_TYPE_PAGE_ID,
	   X_FLOW_TYPE_CODE => X_FLOW_TYPE_CODE,
	   X_PAGE_CODE => X_PAGE_CODE,
	   X_SEQUENCE => X_SEQUENCE,
	   X_FUNCTION_NAME => X_FUNCTION_NAME,
	   X_OBJECT_VERSION_NUMBER => l_object_version_number,
	   X_CREATION_DATE => sysdate,
	   X_CREATED_BY => f_luby,
	   X_LAST_UPDATE_DATE => f_ludate,
	   X_LAST_UPDATED_BY => f_luby,
	   X_LAST_UPDATE_LOGIN => 0);
end LOAD_ROW;

end CS_CF_FLOW_TYPE_PAGES_PKG;

/
