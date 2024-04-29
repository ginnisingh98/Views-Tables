--------------------------------------------------------
--  DDL for Package Body PA_CI_IMPACTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CI_IMPACTS_PKG" as
/* $Header: PACIIPTB.pls 120.0 2005/06/03 13:37:12 appldev noship $ */
procedure INSERT_ROW (
  X_ROWID out NOCOPY VARCHAR2,
  X_CI_IMPACT_ID out NOCOPY NUMBER,

  x_ci_id IN NUMBER,
  x_impact_type_code IN varchar2,
  x_status_code IN VARCHAR2,
  x_description IN VARCHAR2,
  x_implementation_date IN DATE,
  x_implemented_by IN NUMBER,
  x_implementation_comment IN VARCHAR2,
  x_impacted_task_id IN number,

  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
		      ) is
  cursor C is select ROWID from PA_CI_IMPACTS
    where CI_IMPACT_ID = X_CI_IMPACT_ID
    ;
begin
  SELECT pa_ci_impacts_s.NEXTVAL
  INTO X_CI_IMPACT_ID
  FROM sys.dual;

  insert into PA_CI_IMPACTS (
            ci_impact_id	,
	    CI_ID ,
	    impact_type_code ,
	    status_code ,
	    description ,
	    implementation_date ,
            implemented_by ,
	    implementation_comment ,
	    impacted_task_id,
	    CREATION_DATE ,
	    CREATED_BY ,
	    LAST_UPDATE_DATE ,
	    LAST_UPDATED_BY ,
	    last_update_login,
	    record_version_number		     ) values (
	    x_ci_impact_id,
	    x_ci_id ,
            x_impact_type_code ,
            x_status_code ,
            x_description ,
            x_implementation_date ,
            x_implemented_by ,
            x_implementation_comment ,
            x_impacted_task_id,
            nvl(X_CREATION_DATE, sysdate) ,
            nvl(X_CREATED_BY, fnd_global.user_id) ,
            nvl(X_LAST_UPDATE_DATE, sysdate),
            nvl(X_LAST_UPDATED_BY, fnd_global.user_id),
	    nvl(X_LAST_UPDATE_LOGIN, fnd_global.login_id),
	    1
				       );

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

/*
procedure LOCK_ROW (
		    X_CI_IMPACT_ID in NUMBER,
		    x_record_version_number) is
		       cursor c is select
			 impact_type_code,
			 ci_id
			 from PA_CI_IMPACTS
			 where ci_impact_id
			 = x_ci_impact_id
			 AND record_version_number = x_record_version_number
			 for update of CI_impact_ID nowait;
		       recinfo c%rowtype;

begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
  close c;


  return;
end LOCK_ROW;
*/

procedure DELETE_ROW (
		      X_CI_IMPACT_ID in NUMBER,
		      X_record_version_number in NUMBER
) is
begin
  delete from PA_CI_IMPACTS
    where CI_IMPACT_ID = x_ci_impact_id
    AND record_version_number =x_record_version_number;

 -- if (sql%notfound) then
 --   raise no_data_found;
 -- end if;
end DELETE_ROW;


procedure UPDATE_ROW (
  X_CI_IMPACT_ID NUMBER,

  x_ci_id IN NUMBER,
  x_impact_type_code IN varchar2,
  x_status_code IN VARCHAR2,
  x_description IN VARCHAR2,
  x_implementation_date IN DATE,
  x_implemented_by IN NUMBER,
  x_implementation_comment IN VARCHAR2,
  x_impacted_task_id IN NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  x_record_version_number IN number
		      ) is
begin


  update PA_CI_IMPACTS SET
	    CI_ID = Nvl(x_ci_id, ci_id),
	    impact_type_code = Nvl(x_impact_type_code,impact_type_code),
    status_code = Nvl(x_status_code,status_code),
        description = x_description,
	    implementation_date = x_implementation_date,
            implemented_by = x_implemented_by,
            implementation_comment = x_implementation_comment,
            impacted_task_id = x_impacted_task_id,
	    LAST_UPDATE_DATE = sysdate,
	    LAST_UPDATED_BY = fnd_global.user_id,
	    last_update_login = fnd_global.login_id,
    record_version_number = record_version_number +1
    WHERE ci_impact_id = x_ci_impact_id
    AND record_version_number = Nvl(x_record_version_number, record_version_number);
   if (sql%notfound) then
      raise no_data_found;
   end if;

    /*
    description = Decode(x_description, fnd_api.g_miss_char,
			 NULL, Nvl(x_description,description)),
	    implementation_date = Decode(x_implementation_date, fnd_api.g_miss_date,
			 NULL, x_implementation_date),
            implemented_by = Decode(x_implemented_by, fnd_api.g_miss_num,
			 NULL, x_implemented_by),
            implementation_comment = Decode(x_implementation_comment, fnd_api.g_miss_char,
			 NULL, nvl(x_implementation_comment,implementation_comment)),
            impacted_task_id = Decode(x_impacted_task_id,  fnd_api.g_miss_num,
    NULL,  x_impacted_task_id),
    */

end UPDATE_ROW;

end PA_CI_IMPACTS_PKG;

/
