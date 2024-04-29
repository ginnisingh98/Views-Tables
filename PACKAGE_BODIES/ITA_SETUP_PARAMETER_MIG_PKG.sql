--------------------------------------------------------
--  DDL for Package Body ITA_SETUP_PARAMETER_MIG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ITA_SETUP_PARAMETER_MIG_PKG" as
/* $Header: itatmigb.pls 120.1 2005/09/19 17:08:36 cpetriuc noship $ */


procedure INSERT_ROW (
  X_MIGRATION_ID in NUMBER,
  X_OLD_PARAMETER_CODE in VARCHAR2,
  X_NEW_PARAMETER_CODE in VARCHAR2,
  X_START_DATE in DATE,
  X_END_DATE in DATE,
  X_SECURITY_GROUP_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  insert into ITA_SETUP_PARAMETER_MIG (
    MIGRATION_ID,
    OLD_PARAMETER_CODE,
    NEW_PARAMETER_CODE,
    START_DATE,
    END_DATE,
    SECURITY_GROUP_ID,
    OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_MIGRATION_ID,
    X_OLD_PARAMETER_CODE,
    X_NEW_PARAMETER_CODE,
    X_START_DATE,
    X_END_DATE,
    X_SECURITY_GROUP_ID,
    X_OBJECT_VERSION_NUMBER,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );
end INSERT_ROW;


procedure LOCK_ROW (
  X_MIGRATION_ID in NUMBER,
  X_OLD_PARAMETER_CODE in VARCHAR2,
  X_NEW_PARAMETER_CODE in VARCHAR2,
  X_START_DATE in DATE,
  X_END_DATE in DATE,
  X_SECURITY_GROUP_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER
) is
  cursor c is select
      MIGRATION_ID,
      OLD_PARAMETER_CODE,
      NEW_PARAMETER_CODE,
      START_DATE,
      END_DATE,
      SECURITY_GROUP_ID,
      OBJECT_VERSION_NUMBER
    from ITA_SETUP_PARAMETER_MIG
    where MIGRATION_ID = X_MIGRATION_ID
    for update of MIGRATION_ID nowait;
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
  if (    (recinfo.MIGRATION_ID = X_MIGRATION_ID)
      and ((recinfo.OLD_PARAMETER_CODE = X_OLD_PARAMETER_CODE)
           or ((recinfo.OLD_PARAMETER_CODE is null) and (X_OLD_PARAMETER_CODE is null)))
      and ((recinfo.NEW_PARAMETER_CODE = X_NEW_PARAMETER_CODE)
           or ((recinfo.NEW_PARAMETER_CODE is null) and (X_NEW_PARAMETER_CODE is null)))
      and ((recinfo.START_DATE = X_START_DATE)
           or ((recinfo.START_DATE is null) and (X_START_DATE is null)))
      and ((recinfo.END_DATE = X_END_DATE)
           or ((recinfo.END_DATE is null) and (X_END_DATE is null)))
      and ((recinfo.SECURITY_GROUP_ID = X_SECURITY_GROUP_ID)
           or ((recinfo.SECURITY_GROUP_ID is null) and (X_SECURITY_GROUP_ID is null)))
      and ((recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
           or ((recinfo.OBJECT_VERSION_NUMBER is null) and (X_OBJECT_VERSION_NUMBER is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  return;
end LOCK_ROW;


procedure UPDATE_ROW (
  X_MIGRATION_ID in NUMBER,
  X_OLD_PARAMETER_CODE in VARCHAR2,
  X_NEW_PARAMETER_CODE in VARCHAR2,
  X_START_DATE in DATE,
  X_END_DATE in DATE,
  X_SECURITY_GROUP_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update ITA_SETUP_PARAMETER_MIG set
    OLD_PARAMETER_CODE = X_OLD_PARAMETER_CODE,
    NEW_PARAMETER_CODE = X_NEW_PARAMETER_CODE,
    START_DATE = nvl(START_DATE, X_START_DATE),
    END_DATE = nvl(END_DATE, X_END_DATE),
    SECURITY_GROUP_ID = X_SECURITY_GROUP_ID,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where MIGRATION_ID = X_MIGRATION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW;


procedure DELETE_ROW (
  X_MIGRATION_ID in NUMBER
) is
begin
  delete from ITA_SETUP_PARAMETER_MIG
  where MIGRATION_ID = X_MIGRATION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;


procedure LOAD_ROW (
  X_MIGRATION_ID in NUMBER,
  X_OLD_PARAMETER_CODE in VARCHAR2,
  X_NEW_PARAMETER_CODE in VARCHAR2,
  X_START_DATE in DATE,
  X_END_DATE in DATE,
  X_LAST_UPDATE_DATE in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2
) is

f_luby	number;	-- entity owner in file
f_ludate	date;		-- entity update date in file
db_luby	number;	-- entity owner in db
db_ludate	date;		-- entity update date in db

begin
	-- Translate owner to file_last_updated_by
	f_luby := fnd_load_util.owner_id(X_OWNER);

	-- Translate char last_update_date to date
	f_ludate := nvl(to_date(X_LAST_UPDATE_DATE, 'YYYY/MM/DD'), sysdate);

	select LAST_UPDATED_BY, LAST_UPDATE_DATE into db_luby, db_ludate
	from ITA_SETUP_PARAMETER_MIG
	where MIGRATION_ID = X_MIGRATION_ID;

	if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby, db_ludate, X_CUSTOM_MODE))
	then ITA_SETUP_PARAMETER_MIG_PKG.UPDATE_ROW (
		X_MIGRATION_ID			=> X_MIGRATION_ID,
		X_OLD_PARAMETER_CODE		=> X_OLD_PARAMETER_CODE,
		X_NEW_PARAMETER_CODE		=> X_NEW_PARAMETER_CODE,
		X_START_DATE			=> X_START_DATE,
		X_END_DATE				=> X_END_DATE,
		X_SECURITY_GROUP_ID		=> null,
		X_OBJECT_VERSION_NUMBER		=> 1,
		X_LAST_UPDATE_DATE		=> f_ludate,
		X_LAST_UPDATED_BY			=> f_luby,
		X_LAST_UPDATE_LOGIN		=> 0);
	end if;
	exception when NO_DATA_FOUND
	then ITA_SETUP_PARAMETER_MIG_PKG.INSERT_ROW (
		X_MIGRATION_ID			=> X_MIGRATION_ID,
		X_OLD_PARAMETER_CODE		=> X_OLD_PARAMETER_CODE,
		X_NEW_PARAMETER_CODE		=> X_NEW_PARAMETER_CODE,
		X_START_DATE			=> X_START_DATE,
		X_END_DATE				=> X_END_DATE,
		X_SECURITY_GROUP_ID		=> null,
		X_OBJECT_VERSION_NUMBER		=> 1,
		X_CREATION_DATE			=> f_ludate,
		X_CREATED_BY			=> f_luby,
		X_LAST_UPDATE_DATE		=> f_ludate,
		X_LAST_UPDATED_BY			=> f_luby,
		X_LAST_UPDATE_LOGIN		=> 0);
end LOAD_ROW;


end ITA_SETUP_PARAMETER_MIG_PKG;

/
