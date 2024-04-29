--------------------------------------------------------
--  DDL for Package Body XDO_CONFIG_KEYS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XDO_CONFIG_KEYS_PKG" as
/* $Header: XDOCFGKB.pls 120.0 2005/09/01 20:26:12 bokim noship $ */

procedure INSERT_ROW (
          P_VALUE_ID in NUMBER,
          P_VALUE_KEY in RAW,
          P_CREATION_DATE in DATE,
          P_CREATED_BY in NUMBER,
          P_LAST_UPDATE_DATE in DATE,
          P_LAST_UPDATED_BY in NUMBER,
          P_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  insert into XDO_CONFIG_KEYS (
           VALUE_ID,
           VALUE_KEY,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_LOGIN
  ) values (
          P_VALUE_ID,
          P_VALUE_KEY,
          P_CREATION_DATE,
          P_CREATED_BY,
          P_LAST_UPDATE_DATE,
          P_LAST_UPDATED_BY,
          P_LAST_UPDATE_LOGIN
  );
end INSERT_ROW;



procedure UPDATE_ROW (
          P_VALUE_ID in NUMBER,
          P_VALUE_KEY in RAW,
          P_LAST_UPDATE_DATE in DATE,
          P_LAST_UPDATED_BY in NUMBER,
          P_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update XDO_CONFIG_KEYS
     set VALUE_KEY = P_VALUE_KEY,
         LAST_UPDATE_DATE = P_LAST_UPDATE_DATE,
         LAST_UPDATED_BY = P_LAST_UPDATED_BY,
         LAST_UPDATE_LOGIN = P_LAST_UPDATE_LOGIN
  where VALUE_ID = P_VALUE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW;


procedure DELETE_ROW (
          P_VALUE_ID in NUMBER
) is
begin

  delete from XDO_CONFIG_KEYS
   where VALUE_ID = P_VALUE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;



procedure LOAD_ROW (
          P_VALUE_ID in NUMBER,
          P_VALUE_KEY in RAW,
          P_LAST_UPDATE_DATE in DATE,
          P_LAST_UPDATED_BY in NUMBER,
          P_LAST_UPDATE_LOGIN in NUMBER
) is

begin

  begin

     UPDATE_ROW (
          P_VALUE_ID,
          P_VALUE_KEY,
          P_LAST_UPDATE_DATE,
          P_LAST_UPDATED_BY,
          P_LAST_UPDATE_LOGIN
     );

  exception when no_data_found then

      INSERT_ROW (
          P_VALUE_ID,
          P_VALUE_KEY,
          P_LAST_UPDATE_DATE,
          P_LAST_UPDATED_BY,
          P_LAST_UPDATE_DATE,
          P_LAST_UPDATED_BY,
          P_LAST_UPDATE_LOGIN
      );

  end;

end LOAD_ROW;

end XDO_CONFIG_KEYS_PKG;

/
