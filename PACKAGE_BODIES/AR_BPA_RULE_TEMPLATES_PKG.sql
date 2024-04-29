--------------------------------------------------------
--  DDL for Package Body AR_BPA_RULE_TEMPLATES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_BPA_RULE_TEMPLATES_PKG" as
/* $Header: ARBPRTMB.pls 120.1 2004/12/03 01:45:16 orashid noship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_RULE_TEMPLATE_ID in NUMBER,
  X_TEMPLATE_ID in NUMBER,
  X_RULE_ID in NUMBER,
  X_EFFECTIVE_FROM_DATE in DATE,
  X_EFFECTIVE_TO_DATE in DATE,
  X_ASSIGNED_TEMPLATE_PURPOSE IN VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from AR_BPA_RULE_TEMPLATES
    where RULE_TEMPLATE_ID = X_RULE_TEMPLATE_ID
    ;
begin
  insert into AR_BPA_RULE_TEMPLATES (
    RULE_TEMPLATE_ID,
    TEMPLATE_ID,
    RULE_ID,
    EFFECTIVE_FROM_DATE,
    EFFECTIVE_TO_DATE,
    ASSIGNED_TEMPLATE_PURPOSE,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN
  ) select
    X_RULE_TEMPLATE_ID,
    X_TEMPLATE_ID,
    X_RULE_ID,
    X_EFFECTIVE_FROM_DATE,
    X_EFFECTIVE_TO_DATE,
    X_ASSIGNED_TEMPLATE_PURPOSE,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN
  from dual;

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_RULE_TEMPLATE_ID in NUMBER,
  X_TEMPLATE_ID in NUMBER,
  X_RULE_ID in NUMBER,
  X_EFFECTIVE_FROM_DATE in DATE,
  X_EFFECTIVE_TO_DATE in DATE,
  X_ASSIGNED_TEMPLATE_PURPOSE IN VARCHAR2
) is
  cursor c is select
      RULE_TEMPLATE_ID,
      TEMPLATE_ID,
      RULE_ID,
      EFFECTIVE_FROM_DATE,
      EFFECTIVE_TO_DATE,
      ASSIGNED_TEMPLATE_PURPOSE
    from AR_BPA_RULE_TEMPLATES
    where RULE_TEMPLATE_ID = X_RULE_TEMPLATE_ID
    for update of RULE_TEMPLATE_ID nowait;
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
  if (    (recinfo.RULE_TEMPLATE_ID = X_RULE_TEMPLATE_ID)
      AND (recinfo.TEMPLATE_ID = X_TEMPLATE_ID)
      AND (recinfo.RULE_ID = X_RULE_ID)
      AND (recinfo.EFFECTIVE_FROM_DATE = X_EFFECTIVE_FROM_DATE)
      AND ((recinfo.EFFECTIVE_TO_DATE = X_EFFECTIVE_TO_DATE)
           OR ((recinfo.EFFECTIVE_TO_DATE is null) AND (X_EFFECTIVE_TO_DATE is null)))
      AND ( recinfo.ASSIGNED_TEMPLATE_PURPOSE = X_ASSIGNED_TEMPLATE_PURPOSE )

  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_RULE_TEMPLATE_ID in NUMBER,
  X_TEMPLATE_ID in NUMBER,
  X_RULE_ID in NUMBER,
  X_EFFECTIVE_FROM_DATE in DATE,
  X_EFFECTIVE_TO_DATE in DATE,
  X_ASSIGNED_TEMPLATE_PURPOSE IN VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update AR_BPA_RULE_TEMPLATES set
    RULE_TEMPLATE_ID = X_RULE_TEMPLATE_ID,
    TEMPLATE_ID = X_TEMPLATE_ID,
    RULE_ID = X_RULE_ID,
    EFFECTIVE_FROM_DATE = X_EFFECTIVE_FROM_DATE,
    EFFECTIVE_TO_DATE = X_EFFECTIVE_TO_DATE,
    ASSIGNED_TEMPLATE_PURPOSE = X_ASSIGNED_TEMPLATE_PURPOSE ,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where RULE_TEMPLATE_ID = X_RULE_TEMPLATE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_RULE_TEMPLATE_ID in NUMBER
) is
begin
  delete from AR_BPA_RULE_TEMPLATES
  where RULE_TEMPLATE_ID = X_RULE_TEMPLATE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

procedure LOAD_ROW (
  X_RULE_TEMPLATE_ID in NUMBER,
  X_TEMPLATE_ID in NUMBER,
  X_RULE_ID in NUMBER,
  X_EFFECTIVE_FROM_DATE in DATE,
  X_EFFECTIVE_TO_DATE in DATE,
  X_ASSIGNED_TEMPLATE_PURPOSE IN VARCHAR2,
  X_OWNER IN VARCHAR2
) IS
  begin
   declare
     user_id            number := 0;
     row_id             varchar2(64);
   begin
     if (X_OWNER = 'SEED') then
        user_id := 1;
    end if;

    AR_BPA_RULE_TEMPLATES_PKG.UPDATE_ROW (
        X_RULE_TEMPLATE_ID 		=> X_RULE_TEMPLATE_ID,
        X_TEMPLATE_ID 			=> X_TEMPLATE_ID,
        X_RULE_ID 				=> X_RULE_ID,
        X_EFFECTIVE_FROM_DATE 	=> X_EFFECTIVE_FROM_DATE,
        X_EFFECTIVE_TO_DATE 	=> X_EFFECTIVE_TO_DATE,
        X_ASSIGNED_TEMPLATE_PURPOSE =>   X_ASSIGNED_TEMPLATE_PURPOSE ,
        X_LAST_UPDATE_DATE 		=> sysdate,
        X_LAST_UPDATED_BY 		=> user_id,
        X_LAST_UPDATE_LOGIN 	=> 0);
    exception
       when NO_DATA_FOUND then
           AR_BPA_RULE_TEMPLATES_PKG.INSERT_ROW (
                X_ROWID 				=> row_id,
		        X_RULE_TEMPLATE_ID 		=> X_RULE_TEMPLATE_ID,
		        X_TEMPLATE_ID 			=> X_TEMPLATE_ID,
		        X_RULE_ID 				=> X_RULE_ID,
		        X_EFFECTIVE_FROM_DATE 	=> X_EFFECTIVE_FROM_DATE,
		        X_EFFECTIVE_TO_DATE 	=> X_EFFECTIVE_TO_DATE,
                    X_ASSIGNED_TEMPLATE_PURPOSE =>   X_ASSIGNED_TEMPLATE_PURPOSE ,
				X_CREATION_DATE 		=> sysdate,
                X_CREATED_BY 			=> user_id,
                X_LAST_UPDATE_DATE 		=> sysdate,
                X_LAST_UPDATED_BY 		=> user_id,
                X_LAST_UPDATE_LOGIN 	=> 0);
    end;
end LOAD_ROW;

end AR_BPA_RULE_TEMPLATES_PKG;

/
