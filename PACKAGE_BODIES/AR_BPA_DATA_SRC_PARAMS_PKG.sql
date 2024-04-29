--------------------------------------------------------
--  DDL for Package Body AR_BPA_DATA_SRC_PARAMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_BPA_DATA_SRC_PARAMS_PKG" as
/* $Header: ARBPDSPB.pls 120.1 2004/12/03 01:45:06 orashid noship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_DATA_SOURCE_ID in NUMBER,
  X_PARAM_ID in NUMBER,
  X_PARAM_NAME in VARCHAR2,
  X_PARAM_SEQUENCE in NUMBER,
  X_PARAM_TYPE in VARCHAR2,
  X_PARAM_VALUE_SOURCE in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_ITEM_ID in NUMBER
) is
  cursor C is select ROWID from AR_BPA_DATA_SRC_PARAMS
    where PARAM_ID = X_PARAM_ID
    ;
begin
  insert into AR_BPA_DATA_SRC_PARAMS (
    PARAM_ID,
    DATA_SOURCE_ID,
    PARAM_NAME,
    PARAM_TYPE,
    PARAM_SEQUENCE,
    PARAM_VALUE_SOURCE,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    ITEM_ID
  ) select
    X_PARAM_ID,
    X_DATA_SOURCE_ID,
    X_PARAM_NAME,
    X_PARAM_TYPE,
    X_PARAM_SEQUENCE,
    X_PARAM_VALUE_SOURCE,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_ITEM_ID
  from dual;

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure UPDATE_ROW (
  X_DATA_SOURCE_ID in NUMBER,
  X_PARAM_ID in NUMBER,
  X_PARAM_NAME in VARCHAR2,
  X_PARAM_SEQUENCE in NUMBER,
  X_PARAM_TYPE in VARCHAR2,
  X_PARAM_VALUE_SOURCE in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_ITEM_ID in NUMBER
) is
begin
  update AR_BPA_DATA_SRC_PARAMS set
    DATA_SOURCE_ID = X_DATA_SOURCE_ID,
    PARAM_NAME = X_PARAM_NAME,
    PARAM_TYPE = X_PARAM_TYPE,
    PARAM_SEQUENCE = X_PARAM_SEQUENCE,
    PARAM_VALUE_SOURCE = X_PARAM_VALUE_SOURCE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    ITEM_ID = X_ITEM_ID
  where PARAM_ID = X_PARAM_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_PARAM_ID in NUMBER
) is
begin
  delete from AR_BPA_DATA_SRC_PARAMS
  where PARAM_ID = X_PARAM_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

procedure LOAD_ROW (
        X_DATA_SOURCE_ID                 IN NUMBER,
        X_PARAM_ID                       IN NUMBER,
        X_PARAM_NAME                     IN VARCHAR2,
        X_PARAM_SEQUENCE                 IN NUMBER,
        X_PARAM_TYPE                     IN VARCHAR2,
        X_PARAM_VALUE_SOURCE             IN VARCHAR2,
        X_ITEM_ID 						 IN NUMBER,
        X_OWNER                 IN VARCHAR2
) IS
  begin
   declare
     user_id            number := 0;
     row_id             varchar2(64);
   begin
     if (X_OWNER = 'SEED') then
        user_id := 1;
    end if;

    AR_BPA_DATA_SRC_PARAMS_PKG.UPDATE_ROW (
        X_DATA_SOURCE_ID                 => X_DATA_SOURCE_ID,
        X_PARAM_ID                       => X_PARAM_ID,
        X_PARAM_NAME                     => X_PARAM_NAME,
        X_PARAM_SEQUENCE                 => X_PARAM_SEQUENCE,
        X_PARAM_TYPE                     => X_PARAM_TYPE,
        X_PARAM_VALUE_SOURCE             => X_PARAM_VALUE_SOURCE,
        X_LAST_UPDATE_DATE 	=> sysdate,
         X_LAST_UPDATED_BY 	=> user_id,
         X_LAST_UPDATE_LOGIN 	=> 0,
        X_ITEM_ID 						 => X_ITEM_ID);
    exception
       when NO_DATA_FOUND then
           AR_BPA_DATA_SRC_PARAMS_PKG.INSERT_ROW (
                 X_ROWID => row_id,
                X_DATA_SOURCE_ID                 => X_DATA_SOURCE_ID,
                X_PARAM_ID                       => X_PARAM_ID,
                X_PARAM_NAME                     => X_PARAM_NAME,
                X_PARAM_SEQUENCE                 => X_PARAM_SEQUENCE,
                X_PARAM_TYPE                     => X_PARAM_TYPE,
                X_PARAM_VALUE_SOURCE             => X_PARAM_VALUE_SOURCE,
		X_CREATION_DATE 	=> sysdate,
                X_CREATED_BY 		=> user_id,
                X_LAST_UPDATE_DATE 	=> sysdate,
                X_LAST_UPDATED_BY 	=> user_id,
                X_LAST_UPDATE_LOGIN 	=> 0,
                X_ITEM_ID 						 => X_ITEM_ID);
    end;
end LOAD_ROW;

end AR_BPA_DATA_SRC_PARAMS_PKG;

/
