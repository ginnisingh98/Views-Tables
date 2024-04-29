--------------------------------------------------------
--  DDL for Package Body PA_CI_IMPACT_TYPE_USAGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CI_IMPACT_TYPE_USAGE_PKG" as
/* $Header: PACIIMTB.pls 120.0.12010000.2 2009/06/08 18:52:07 cklee ship $ */
procedure INSERT_ROW (
  X_ROWID out NOCOPY VARCHAR2,
  X_CI_IMPACT_TYPE_USAGE_ID out NOCOPY NUMBER,

  x_impact_type_code IN varchar2,
  x_ci_type_class_code IN VARCHAR2,
  X_CI_TYPE_ID in NUMBER,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
--start:|   16-FEB-2009  cklee  R12.1.2 setup ehancement
  X_IMPACT_TYPE_CODE_ORDER IN NUMBER  default null
--end:|   16-FEB-2009  cklee  R12.1.2 setup ehancement

) is
  cursor C is select ROWID from PA_CI_IMPACT_TYPE_USAGE
    where CI_IMPACT_TYPE_USAGE_ID = X_CI_IMPACT_TYPE_USAGE_ID
    ;
begin
  SELECT pa_ci_impact_type_usage_s.NEXTVAL
  INTO X_CI_IMPACT_TYPE_USAGE_ID
  FROM sys.dual;

  insert into PA_CI_IMPACT_TYPE_USAGE (
				       CI_IMPACT_TYPE_USAGE_ID ,
				       impact_type_code  ,
				       ci_type_class_code ,
				       CI_TYPE_ID ,
				       CREATION_DATE ,
				       CREATED_BY ,
				       LAST_UPDATE_DATE ,
				       LAST_UPDATED_BY,
				       LAST_UPDATE_LOGIN,
--start:|   16-FEB-2009  cklee  R12.1.2 setup ehancement
                       IMPACT_TYPE_CODE_ORDER
--end:|   16-FEB-2009  cklee  R12.1.2 setup ehancement
  ) values (
	    X_CI_IMPACT_TYPE_USAGE_ID ,
	    x_impact_type_code ,
	    x_ci_type_class_code ,
	    X_CI_TYPE_ID ,
	    nvl(X_CREATION_DATE, sysdate),
            nvl(X_CREATED_BY, fnd_global.user_id),
            nvl(X_LAST_UPDATE_DATE, sysdate),
            nvl(X_LAST_UPDATED_BY, fnd_global.user_id),
	    nvl(X_LAST_UPDATE_LOGIN, fnd_global.login_id),
--start:|   16-FEB-2009  cklee  R12.1.2 setup ehancement
        X_IMPACT_TYPE_CODE_ORDER
--end:|   16-FEB-2009  cklee  R12.1.2 setup ehancement
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
  X_CI_IMPACT_TYPE_USAGE_ID in NUMBER,
  x_impact_type_code IN varchar2,
  x_ci_type_class_code IN VARCHAR2,
  X_CI_TYPE_ID in NUMBER,
--start:|   16-FEB-2009  cklee  R12.1.2 setup ehancement
  X_IMPACT_TYPE_CODE_ORDER IN NUMBER  default null
--end:|   16-FEB-2009  cklee  R12.1.2 setup ehancement
) is
  cursor c is select
      impact_type_code,
      ci_type_class_code,
      ci_type_id
    from PA_CI_IMPACT_TYPE_USAGE
    where ci_impact_type_usage_id = X_CI_IMPACT_TYPE_USAGE_ID
    for update of CI_impact_TYPE_USAGE_ID nowait;
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
  if (    (recinfo.impact_type_code = x_impact_type_code)
	  AND (recinfo.ci_type_class_code = x_ci_type_class_code)
	  AND (recinfo.CI_TYPE_ID = X_CI_TYPE_ID)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_CI_IMPACT_TYPE_USAGE_ID in NUMBER,
  X_IMPACT_TYPE_CODE_ORDER IN NUMBER
) is
begin
  update PA_CI_IMPACT_TYPE_USAGE set
    IMPACT_TYPE_CODE_ORDER = X_IMPACT_TYPE_CODE_ORDER
  where CI_IMPACT_TYPE_USAGE_ID = X_CI_IMPACT_TYPE_USAGE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW;


procedure DELETE_ROW (
  X_CI_IMPACT_TYPE_USAGE_ID in NUMBER
) is
begin
  delete from PA_CI_IMPACT_TYPE_USAGE
  where CI_IMPACT_TYPE_USAGE_ID = X_CI_IMPACT_TYPE_USAGE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;


end PA_CI_IMPACT_TYPE_USAGE_PKG;

/
