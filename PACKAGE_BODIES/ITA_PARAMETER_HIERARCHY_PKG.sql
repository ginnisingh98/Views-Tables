--------------------------------------------------------
--  DDL for Package Body ITA_PARAMETER_HIERARCHY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ITA_PARAMETER_HIERARCHY_PKG" as
/* $Header: itatovrb.pls 120.0 2005/08/17 17:38 anmalhot noship $ */


procedure INSERT_ROW (
  x_parameter_code IN VARCHAR2,
  x_override_parameter_code IN VARCHAR2,
  x_override_level IN NUMBER,
  x_creation_date IN DATE,
  x_created_by IN NUMBER,
  x_last_update_date IN DATE,
  x_last_updated_by IN NUMBER,
  x_last_update_login IN NUMBER
)
is
  l_check_par_code NUMBER;
  l_check_override_code NUMBER;
begin

  select 1
  into l_check_par_code
  from ita_setup_parameters_b
  where parameter_code = x_parameter_code;

  select 1
  into l_check_override_code
  from ita_setup_parameters_b
  where parameter_code = x_override_parameter_code;

  if ((l_check_par_code =1) and (l_check_override_code = 1)) then
        insert into ITA_PARAMETER_HIERARCHY(
      	parameter_code,
      	override_parameter_code,
  		override_level,
  		creation_date,
  		created_by,
  		last_update_date,
  		last_updated_by,
  		last_update_login
   	) values (
      	x_parameter_code ,
      	x_override_parameter_code ,
      	x_override_level ,
      	x_creation_date ,
      	x_created_by ,
      	x_last_update_date ,
      	x_last_updated_by ,
      	x_last_update_login );
   end if;
EXCEPTION
   when no_data_found then
     fnd_file.put_line(fnd_file.log,'The parameter or override parameter does not exist');

end INSERT_ROW;


procedure LOCK_ROW (
  x_parameter_code IN VARCHAR2,
  x_override_parameter_code IN VARCHAR2,
  x_override_level IN NUMBER,
  x_creation_date IN DATE,
  x_created_by IN NUMBER,
  x_last_update_date IN DATE,
  x_last_updated_by IN NUMBER,
  x_last_update_login IN NUMBER
) is
  cursor c is select
      override_level
    from ITA_PARAMETER_HIERARCHY
    where parameter_code = x_parameter_code
    and override_parameter_code = x_override_parameter_code
    for update of parameter_code,override_parameter_code nowait;
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
  if (recinfo.override_level = x_override_level
	     OR (recinfo.override_level is null AND x_override_level is null))
  then
    null;

  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  return;
end LOCK_ROW;


procedure UPDATE_ROW (
  x_parameter_code IN VARCHAR2,
  x_override_parameter_code IN VARCHAR2,
  x_override_level IN NUMBER,
  x_last_update_date IN DATE,
  x_last_updated_by IN NUMBER,
  x_last_update_login IN NUMBER
)
 is
begin
  update ita_parameter_hierarchy
  set
    override_level = x_override_level,
    last_update_date = x_last_update_date,
    last_updated_by = x_last_updated_by,
    last_update_login = x_last_update_login
  where parameter_code = x_parameter_code
   and  override_parameter_code = x_override_parameter_code;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;


procedure DELETE_ROW (
  x_parameter_code IN VARCHAR2,
  x_override_parameter_code IN VARCHAR2
) is
begin
  delete from ITA_PARAMETER_HIERARCHY
  where parameter_code = x_parameter_code
  and override_parameter_code = x_override_parameter_code;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;


procedure LOAD_ROW(
            x_parameter_code in VARCHAR2,
            x_override_parameter_code in VARCHAR2,
		x_override_level in NUMBER,
		x_last_update_date in VARCHAR2,
		x_owner in VARCHAR2,
		x_custom_mode in VARCHAR2
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
	from ITA_PARAMETER_HIERARCHY
	where parameter_code = x_parameter_code
        and override_parameter_code = x_override_parameter_code;

	if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby, db_ludate, X_CUSTOM_MODE))
	then ITA_PARAMETER_HIERARCHY_PKG.UPDATE_ROW(
            x_parameter_code => x_parameter_code,
            x_override_parameter_code => x_override_parameter_code,
            x_override_level => x_override_level,
            x_last_update_date => f_ludate,
            x_last_updated_by => f_luby,
            x_last_update_login => 0);
	end if;

	exception when NO_DATA_FOUND
	then ITA_PARAMETER_HIERARCHY_PKG.INSERT_ROW(
            x_parameter_code => x_parameter_code,
            x_override_parameter_code => x_override_parameter_code,
            x_override_level => x_override_level,
            x_creation_date => f_ludate,
            x_created_by => f_luby,
            x_last_update_date => f_ludate,
            x_last_updated_by => f_luby,
            x_last_update_login => 0);
end LOAD_ROW;


end ITA_PARAMETER_HIERARCHY_PKG;

/
