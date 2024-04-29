--------------------------------------------------------
--  DDL for Package Body ITA_SETUP_APPLICATION_EXT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ITA_SETUP_APPLICATION_EXT_PKG" as
/* $Header: itatapxb.pls 120.0 2005/06/15 18:06:09 appldev noship $ */


procedure INSERT_ROW (
  X_APPLICATION_ID in NUMBER,
  X_MIN_HIERARCHY_LEVEL in VARCHAR2,
  X_SECURITY_GROUP_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  insert into ITA_SETUP_APPLICATION_EXT (
    APPLICATION_ID,
    MIN_HIERARCHY_LEVEL,
    SECURITY_GROUP_ID,
    OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_APPLICATION_ID,
    X_MIN_HIERARCHY_LEVEL,
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
  X_APPLICATION_ID in NUMBER,
  X_MIN_HIERARCHY_LEVEL in VARCHAR2,
  X_SECURITY_GROUP_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER
) is
  cursor c is select
      MIN_HIERARCHY_LEVEL,
      SECURITY_GROUP_ID,
      OBJECT_VERSION_NUMBER
    from ITA_SETUP_APPLICATION_EXT
    where APPLICATION_ID = X_APPLICATION_ID
    for update of APPLICATION_ID nowait;
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
  if (    (recinfo.MIN_HIERARCHY_LEVEL = X_MIN_HIERARCHY_LEVEL
	     OR (recinfo.MIN_HIERARCHY_LEVEL is null AND X_MIN_HIERARCHY_LEVEL is null))
      AND (recinfo.SECURITY_GROUP_ID = X_SECURITY_GROUP_ID
           OR (recinfo.SECURITY_GROUP_ID is null AND X_SECURITY_GROUP_ID is null))
      AND (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER
           OR (recinfo.OBJECT_VERSION_NUMBER is null AND X_OBJECT_VERSION_NUMBER is null))
  ) then
    null;

  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  return;
end LOCK_ROW;


procedure UPDATE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_MIN_HIERARCHY_LEVEL in VARCHAR2,
  X_SECURITY_GROUP_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update ITA_SETUP_APPLICATION_EXT set
    APPLICATION_ID = X_APPLICATION_ID,
    MIN_HIERARCHY_LEVEL = X_MIN_HIERARCHY_LEVEL,
    SECURITY_GROUP_ID = X_SECURITY_GROUP_ID,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where APPLICATION_ID = X_APPLICATION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;


procedure DELETE_ROW (
  X_APPLICATION_ID in NUMBER
) is
begin
  delete from ITA_SETUP_APPLICATION_EXT
  where APPLICATION_ID = X_APPLICATION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;


procedure LOAD_ROW(
  X_APPLICATION_ID in NUMBER,
  X_MIN_HIERARCHY_LEVEL in VARCHAR2,
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

	select last_updated_by, last_update_date into db_luby, db_ludate
	from ITA_SETUP_APPLICATION_EXT
	where application_id = X_APPLICATION_ID;

	if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby, db_ludate, X_CUSTOM_MODE))
	then ITA_SETUP_APPLICATION_EXT_PKG.UPDATE_ROW(
		X_APPLICATION_ID			=> X_APPLICATION_ID,
		X_MIN_HIERARCHY_LEVEL		=> X_MIN_HIERARCHY_LEVEL,
		X_SECURITY_GROUP_ID		=> null,
		X_OBJECT_VERSION_NUMBER		=> 1,
		X_LAST_UPDATE_DATE		=> f_ludate,
		X_LAST_UPDATED_BY			=> f_luby,
		X_LAST_UPDATE_LOGIN		=> 0);
	end if;
	exception when NO_DATA_FOUND
	then ITA_SETUP_APPLICATION_EXT_PKG.INSERT_ROW(
		X_APPLICATION_ID			=> X_APPLICATION_ID,
		X_MIN_HIERARCHY_LEVEL		=> X_MIN_HIERARCHY_LEVEL,
		X_SECURITY_GROUP_ID		=> null,
		X_OBJECT_VERSION_NUMBER		=> 1,
		X_CREATION_DATE			=> f_ludate,
		X_CREATED_BY			=> f_luby,
		X_LAST_UPDATE_DATE		=> f_ludate,
		X_LAST_UPDATED_BY			=> f_luby,
		X_LAST_UPDATE_LOGIN		=> 0);
end LOAD_ROW;


end ITA_SETUP_APPLICATION_EXT_PKG;

/
