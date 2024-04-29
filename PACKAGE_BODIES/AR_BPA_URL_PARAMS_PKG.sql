--------------------------------------------------------
--  DDL for Package Body AR_BPA_URL_PARAMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_BPA_URL_PARAMS_PKG" as
/* $Header: ARBPURPB.pls 120.1 2004/12/03 01:45:27 orashid noship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_URL_PARAM_ID in NUMBER,
  X_URL_ID in NUMBER,
  X_PARAM_TYPE in VARCHAR2,
  X_PARAM_NAME in VARCHAR2,
  X_PARAM_VALUE in VARCHAR2,
  X_ITEM_ID in NUMBER,
  X_ENCRYPTED_FLAG in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from AR_BPA_URL_PARAMS
    where URL_PARAM_ID = X_URL_PARAM_ID
    ;
begin
  insert into AR_BPA_URL_PARAMS (
    URL_PARAM_ID,
    URL_ID,
    PARAM_TYPE,
    PARAM_NAME,
    PARAM_VALUE,
    ITEM_ID,
    ENCRYPTED_FLAG,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN
  ) select
    X_URL_PARAM_ID,
    X_URL_ID,
    X_PARAM_TYPE,
    X_PARAM_NAME,
    X_PARAM_VALUE,
    X_ITEM_ID,
    X_ENCRYPTED_FLAG,
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
  X_URL_PARAM_ID in NUMBER,
  X_URL_ID in NUMBER,
  X_PARAM_TYPE in VARCHAR2,
  X_PARAM_NAME in VARCHAR2,
  X_PARAM_VALUE in VARCHAR2,
  X_ITEM_ID in NUMBER,
  X_ENCRYPTED_FLAG in VARCHAR2
) is
  cursor c is select
      URL_PARAM_ID,
      URL_ID,
      PARAM_TYPE,
      PARAM_NAME,
      PARAM_VALUE,
      ITEM_ID,
      ENCRYPTED_FLAG
    from AR_BPA_URL_PARAMS
    where URL_PARAM_ID = X_URL_PARAM_ID
    for update of URL_PARAM_ID nowait;
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
  if (    (recinfo.URL_PARAM_ID = X_URL_PARAM_ID)
      AND (recinfo.URL_ID = X_URL_ID)
      AND (recinfo.PARAM_TYPE = X_PARAM_TYPE)
      AND ((recinfo.PARAM_NAME = X_PARAM_NAME)
           OR ((recinfo.PARAM_NAME is null) AND (X_PARAM_NAME is null)))
      AND ((recinfo.PARAM_VALUE = X_PARAM_VALUE)
           OR ((recinfo.PARAM_VALUE is null) AND (X_PARAM_VALUE is null)))
      AND ((recinfo.ITEM_ID = X_ITEM_ID)
           OR ((recinfo.ITEM_ID is null) AND (X_ITEM_ID is null)))
      AND ((recinfo.ENCRYPTED_FLAG = X_ENCRYPTED_FLAG)
           OR ((recinfo.ENCRYPTED_FLAG is null) AND (X_ENCRYPTED_FLAG is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_URL_PARAM_ID in NUMBER,
  X_URL_ID in NUMBER,
  X_PARAM_TYPE in VARCHAR2,
  X_PARAM_NAME in VARCHAR2,
  X_PARAM_VALUE in VARCHAR2,
  X_ITEM_ID in NUMBER,
  X_ENCRYPTED_FLAG in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update AR_BPA_URL_PARAMS set
    URL_PARAM_ID = X_URL_PARAM_ID,
    URL_ID = X_URL_ID,
    PARAM_TYPE = X_PARAM_TYPE,
    PARAM_NAME = X_PARAM_NAME,
    PARAM_VALUE = X_PARAM_VALUE,
    ITEM_ID = X_ITEM_ID,
    ENCRYPTED_FLAG = X_ENCRYPTED_FLAG,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where URL_PARAM_ID = X_URL_PARAM_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_URL_PARAM_ID in NUMBER
) is
begin
  delete from AR_BPA_URL_PARAMS
  where URL_PARAM_ID = X_URL_PARAM_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

procedure LOAD_ROW (
  X_URL_PARAM_ID in NUMBER,
  X_URL_ID in NUMBER,
  X_PARAM_TYPE in VARCHAR2,
  X_PARAM_NAME in VARCHAR2,
  X_PARAM_VALUE in VARCHAR2,
  X_ITEM_ID in NUMBER,
  X_ENCRYPTED_FLAG in VARCHAR2,
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

    AR_BPA_URL_PARAMS_PKG.UPDATE_ROW (
        X_URL_PARAM_ID 		=> X_URL_PARAM_ID,
        X_URL_ID 			=> X_URL_ID,
        X_PARAM_TYPE		=> X_PARAM_TYPE,
        X_PARAM_NAME		=> X_PARAM_NAME,
        X_PARAM_VALUE		=> X_PARAM_VALUE,
        X_ITEM_ID			=> X_ITEM_ID,
        X_ENCRYPTED_FLAG	=> X_ENCRYPTED_FLAG,
        X_LAST_UPDATE_DATE 		=> sysdate,
        X_LAST_UPDATED_BY 		=> user_id,
        X_LAST_UPDATE_LOGIN 	=> 0);
    exception
       when NO_DATA_FOUND then
           AR_BPA_URL_PARAMS_PKG.INSERT_ROW (
                X_ROWID 				=> row_id,
		        X_URL_PARAM_ID 			=> X_URL_PARAM_ID,
		        X_URL_ID 				=> X_URL_ID,
		        X_PARAM_TYPE			=> X_PARAM_TYPE,
		        X_PARAM_NAME			=> X_PARAM_NAME,
		        X_PARAM_VALUE			=> X_PARAM_VALUE,
		        X_ITEM_ID				=> X_ITEM_ID,
		        X_ENCRYPTED_FLAG		=> X_ENCRYPTED_FLAG,
				X_CREATION_DATE 		=> sysdate,
                X_CREATED_BY 			=> user_id,
                X_LAST_UPDATE_DATE 		=> sysdate,
                X_LAST_UPDATED_BY 		=> user_id,
                X_LAST_UPDATE_LOGIN 	=> 0);
    end;
end LOAD_ROW;

end AR_BPA_URL_PARAMS_PKG;

/
