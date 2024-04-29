--------------------------------------------------------
--  DDL for Package Body AMW_OBJECT_OPINION_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMW_OBJECT_OPINION_TYPES_PKG" as
/*$Header: amwtopob.pls 115.3 2003/11/04 01:21:33 cpetriuc noship $*/

procedure INSERT_ROW (
  X_OBJECT_OPINION_TYPE_ID in NUMBER,
  X_OBJECT_ID in NUMBER,
  X_OPINION_TYPE_ID in NUMBER,
  X_VIEW_FUNCTION_ID in NUMBER,
  X_PERFORM_FUNCTION_ID in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  insert into AMW_OBJECT_OPINION_TYPES (
    OBJECT_OPINION_TYPE_ID,
    OBJECT_ID,
    OPINION_TYPE_ID,
    VIEW_FUNCTION_ID,
    PERFORM_FUNCTION_ID,
    SECURITY_GROUP_ID,
    OBJECT_VERSION_NUMBER,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN
  ) values (
    X_OBJECT_OPINION_TYPE_ID,
    X_OBJECT_ID,
    X_OPINION_TYPE_ID,
    X_VIEW_FUNCTION_ID,
    X_PERFORM_FUNCTION_ID,
    X_SECURITY_GROUP_ID,
    X_OBJECT_VERSION_NUMBER,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN
  );
end INSERT_ROW;

procedure UPDATE_ROW (
  X_OBJECT_OPINION_TYPE_ID in NUMBER,
  X_OBJECT_ID in NUMBER,
  X_OPINION_TYPE_ID in NUMBER,
  X_VIEW_FUNCTION_ID in NUMBER,
  X_PERFORM_FUNCTION_ID in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update AMW_OBJECT_OPINION_TYPES set
    OBJECT_ID = X_OBJECT_ID,
    OPINION_TYPE_ID = X_OPINION_TYPE_ID,
    VIEW_FUNCTION_ID = X_VIEW_FUNCTION_ID,
    PERFORM_FUNCTION_ID = X_PERFORM_FUNCTION_ID,
    SECURITY_GROUP_ID = X_SECURITY_GROUP_ID,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where OBJECT_OPINION_TYPE_ID = X_OBJECT_OPINION_TYPE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_OBJECT_OPINION_TYPE_ID in NUMBER
) is
begin
  delete from AMW_OBJECT_OPINION_TYPES
  where OBJECT_OPINION_TYPE_ID = X_OBJECT_OPINION_TYPE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure LOAD_ROW(
	X_OBJECT_OPINION_TYPE_ID		in NUMBER,
	X_OBJECT_NAME				in VARCHAR2,
	X_OPINION_TYPE_ID				in NUMBER,
	X_VIEW_FUNCTION_ID			in NUMBER,
	X_PERFORM_FUNCTION_ID			in NUMBER,
	X_LAST_UPDATE_DATE    			in VARCHAR2,
	X_OWNER					in VARCHAR2,
	X_CUSTOM_MODE				in VARCHAR2) is

f_luby	number;	-- entity owner in file
f_ludate	date;		-- entity update date in file
db_luby	number;	-- entity owner in db
db_ludate	date;		-- entity update date in db

oid		number;

begin
	-- Translate owner to file_last_updated_by
	f_luby := fnd_load_util.owner_id(X_OWNER);

	-- Translate char last_update_date to date
	f_ludate := nvl(to_date(X_LAST_UPDATE_DATE, 'YYYY/MM/DD'), sysdate);

	select object_id into oid
	from FND_OBJECTS
	where obj_name = X_OBJECT_NAME;

	select aoot.last_updated_by, aoot.last_update_date into db_luby, db_ludate
	from AMW_OBJECT_OPINION_TYPES aoot
	where object_opinion_type_id = X_OBJECT_OPINION_TYPE_ID;

	if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby, db_ludate, X_CUSTOM_MODE))
	then AMW_OBJECT_OPINION_TYPES_PKG.UPDATE_ROW(
		X_OBJECT_OPINION_TYPE_ID	=> X_OBJECT_OPINION_TYPE_ID,
		X_OBJECT_ID				=> oid,
		X_OPINION_TYPE_ID			=> X_OPINION_TYPE_ID,
		X_VIEW_FUNCTION_ID		=> X_VIEW_FUNCTION_ID,
		X_PERFORM_FUNCTION_ID		=> X_PERFORM_FUNCTION_ID,
		X_SECURITY_GROUP_ID		=> null,
		X_OBJECT_VERSION_NUMBER		=> 1,
		X_LAST_UPDATE_DATE		=> f_ludate,
		X_LAST_UPDATED_BY			=> f_luby,
		X_LAST_UPDATE_LOGIN		=> 0);
	end if;
	exception when NO_DATA_FOUND
	then AMW_OBJECT_OPINION_TYPES_PKG.INSERT_ROW(
		X_OBJECT_OPINION_TYPE_ID	=> X_OBJECT_OPINION_TYPE_ID,
		X_OBJECT_ID				=> oid,
		X_OPINION_TYPE_ID			=> X_OPINION_TYPE_ID,
		X_VIEW_FUNCTION_ID		=> X_VIEW_FUNCTION_ID,
		X_PERFORM_FUNCTION_ID		=> X_PERFORM_FUNCTION_ID,
		X_SECURITY_GROUP_ID		=> null,
		X_OBJECT_VERSION_NUMBER		=> 1,
		X_CREATION_DATE			=> f_ludate,
		X_CREATED_BY			=> f_luby,
		X_LAST_UPDATE_DATE		=> f_ludate,
		X_LAST_UPDATED_BY			=> f_luby,
		X_LAST_UPDATE_LOGIN		=> 0);
end LOAD_ROW;

end AMW_OBJECT_OPINION_TYPES_PKG;

/
