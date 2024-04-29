--------------------------------------------------------
--  DDL for Package Body XDO_CONFIG_VALUES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XDO_CONFIG_VALUES_PKG" as
/* $Header: XDOCFGVB.pls 120.0 2005/09/01 20:26:16 bokim noship $ */

procedure INSERT_ROW (
          P_VALUE_ID in NUMBER,
          P_CONFIG_LEVEL in NUMBER,
          P_APPLICATION_SHORT_NAME in VARCHAR2,
          P_DATA_SOURCE_CODE in VARCHAR2,
          P_TEMPLATE_CODE in VARCHAR2,
          P_PROPERTY_CODE in VARCHAR2,
          P_VALUE in VARCHAR2,
          P_BVALUE in RAW,
          P_CREATION_DATE in DATE,
          P_CREATED_BY in NUMBER,
          P_LAST_UPDATE_DATE in DATE,
          P_LAST_UPDATED_BY in NUMBER,
          P_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  insert into XDO_CONFIG_VALUES (
           VALUE_ID,
           CONFIG_LEVEL,
           APPLICATION_SHORT_NAME,
           DATA_SOURCE_CODE,
           TEMPLATE_CODE,
           PROPERTY_CODE,
           VALUE,
           BVALUE,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_LOGIN
  ) values (
          P_VALUE_ID,
          P_CONFIG_LEVEL,
          P_APPLICATION_SHORT_NAME,
          P_DATA_SOURCE_CODE,
          P_TEMPLATE_CODE,
          P_PROPERTY_CODE,
          P_VALUE,
          P_BVALUE,
          P_CREATION_DATE,
          P_CREATED_BY,
          P_LAST_UPDATE_DATE,
          P_LAST_UPDATED_BY,
          P_LAST_UPDATE_LOGIN
  );
end INSERT_ROW;



procedure UPDATE_ROW (
          P_CONFIG_LEVEL in NUMBER,
          P_APPLICATION_SHORT_NAME in VARCHAR2,
          P_DATA_SOURCE_CODE in VARCHAR2,
          P_TEMPLATE_CODE in VARCHAR2,
          P_PROPERTY_CODE in VARCHAR2,
          P_VALUE in VARCHAR2,
          P_BVALUE in RAW,
          P_LAST_UPDATE_DATE in DATE,
          P_LAST_UPDATED_BY in NUMBER,
          P_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update XDO_CONFIG_VALUES
     set VALUE = P_VALUE,
         BVALUE = P_BVALUE,
         LAST_UPDATE_DATE = P_LAST_UPDATE_DATE,
         LAST_UPDATED_BY = P_LAST_UPDATED_BY,
         LAST_UPDATE_LOGIN = P_LAST_UPDATE_LOGIN
  where CONFIG_LEVEL = P_CONFIG_LEVEL
    and (   (APPLICATION_SHORT_NAME is null and P_APPLICATION_SHORT_NAME is null)
         or (APPLICATION_SHORT_NAME = P_APPLICATION_SHORT_NAME))
    and (   (DATA_SOURCE_CODE is null and P_DATA_SOURCE_CODE is null)
         or (DATA_SOURCE_CODE = P_DATA_SOURCE_CODE))
    and (   (TEMPLATE_CODE is null and P_TEMPLATE_CODE is null)
         or (TEMPLATE_CODE = P_TEMPLATE_CODE))
    and PROPERTY_CODE = P_PROPERTY_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW;

function GET_VALUE_ID (
          P_CONFIG_LEVEL in NUMBER,
          P_APPLICATION_SHORT_NAME in VARCHAR2,
          P_DATA_SOURCE_CODE in VARCHAR2,
          P_TEMPLATE_CODE in VARCHAR2,
          P_PROPERTY_CODE in VARCHAR2
) return number is

  m_value_id number;

begin
  select value_id
    into m_value_id
   from xdo_config_values
  where CONFIG_LEVEL = P_CONFIG_LEVEL
    and (   (APPLICATION_SHORT_NAME is null and P_APPLICATION_SHORT_NAME is null)
         or (APPLICATION_SHORT_NAME = P_APPLICATION_SHORT_NAME))
    and (   (DATA_SOURCE_CODE is null and P_DATA_SOURCE_CODE is null)
         or (DATA_SOURCE_CODE = P_DATA_SOURCE_CODE))
    and (   (TEMPLATE_CODE is null and P_TEMPLATE_CODE is null)
         or (TEMPLATE_CODE = P_TEMPLATE_CODE))
    and PROPERTY_CODE = P_PROPERTY_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  return m_value_id;

end GET_VALUE_ID;


procedure DELETE_ROW (
          P_CONFIG_LEVEL in NUMBER,
          P_APPLICATION_SHORT_NAME in VARCHAR2,
          P_DATA_SOURCE_CODE in VARCHAR2,
          P_TEMPLATE_CODE in VARCHAR2,
          P_PROPERTY_CODE in VARCHAR2
) is

  m_value_id number;

begin

  select value_id
    into m_value_id
    from xdo_config_values
  where CONFIG_LEVEL = P_CONFIG_LEVEL
    and (   (APPLICATION_SHORT_NAME is null and P_APPLICATION_SHORT_NAME is null)
         or (APPLICATION_SHORT_NAME = P_APPLICATION_SHORT_NAME))
    and (   (DATA_SOURCE_CODE is null and P_DATA_SOURCE_CODE is null)
         or (DATA_SOURCE_CODE = P_DATA_SOURCE_CODE))
    and (   (TEMPLATE_CODE is null and P_TEMPLATE_CODE is null)
         or (TEMPLATE_CODE = P_TEMPLATE_CODE))
    and PROPERTY_CODE = P_PROPERTY_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  begin
    xdo_config_keys_pkg.delete_row(m_value_id);
  exception when no_data_found then
    null;
  end;

  delete from XDO_CONFIG_VALUES
   where value_id = m_value_id;

end DELETE_ROW;



procedure LOAD_ROW (
          P_CONFIG_LEVEL in NUMBER,
          P_APPLICATION_SHORT_NAME in VARCHAR2,
          P_DATA_SOURCE_CODE in VARCHAR2,
          P_TEMPLATE_CODE in VARCHAR2,
          P_PROPERTY_CODE in VARCHAR2,
          P_VALUE in VARCHAR2,
          P_LAST_UPDATE_DATE in DATE,
          P_LAST_UPDATED_BY in NUMBER,
          P_LAST_UPDATE_LOGIN in NUMBER
) is

  value_id number;

begin

  begin

     UPDATE_ROW (
          P_CONFIG_LEVEL,
          P_APPLICATION_SHORT_NAME,
          P_DATA_SOURCE_CODE,
          P_TEMPLATE_CODE,
          P_PROPERTY_CODE,
          P_VALUE,
          null,
          P_LAST_UPDATE_DATE,
          P_LAST_UPDATED_BY,
          P_LAST_UPDATE_LOGIN
     );

  exception when no_data_found then

      select xdo_config_values_seq.nextval into value_id from dual;

      INSERT_ROW (
          value_id,
          P_CONFIG_LEVEL,
          P_APPLICATION_SHORT_NAME,
          P_DATA_SOURCE_CODE,
          P_TEMPLATE_CODE,
          P_PROPERTY_CODE,
          P_VALUE,
          null,
          P_LAST_UPDATE_DATE,
          P_LAST_UPDATED_BY,
          P_LAST_UPDATE_DATE,
          P_LAST_UPDATED_BY,
          P_LAST_UPDATE_LOGIN
      );

  end;

end LOAD_ROW;

end XDO_CONFIG_VALUES_PKG;

/
