--------------------------------------------------------
--  DDL for Package Body JTF_DAC_CRITERIA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_DAC_CRITERIA_PKG" AS
/* $Header: jtfaacb.pls 120.2 2005/10/25 05:09:52 psanyal ship $ */

procedure INSERT_ROW(
  X_ROWID IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
  x_criteria_id in number,
  x_role_perm_id in number,
  x_property_name in varchar2,
  x_operator in varchar2,
  x_property_value in varchar2,
  x_property_value_type in varchar2,
  x_object_version_number in number,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) IS

  cursor C is select ROWID from JTF_DAC_CRITERIA
    where CRITERIA_ID = X_CRITERIA_ID;
BEGIN

  insert into JTF_DAC_CRITERIA(
    CRITERIA_ID,
    ROLE_PERM_ID,
    PROPERTY_NAME,
    OPERATOR,
    PROPERTY_VALUE,
    PROPERTY_VALUE_TYPE,
    OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    x_criteria_id,
    x_role_perm_id,
    x_property_name,
    x_operator,
    x_property_value,
    x_property_value_type,
    x_object_version_number,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
    );

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

END INSERT_ROW;




procedure UPDATE_ROW (
  x_criteria_id in number,
  x_role_perm_id in number,
  x_property_name in varchar2,
  x_operator in varchar2,
  x_property_value in varchar2,
  x_property_value_type in varchar2,
  x_object_version_number in number,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin

  update JTF_DAC_CRITERIA set
    CRITERIA_ID = X_CRITERIA_ID,
    ROLE_PERM_ID = X_ROLE_PERM_ID,
    PROPERTY_NAME = X_PROPERTY_NAME,
    OPERATOR = X_OPERATOR,
    PROPERTY_VALUE = X_PROPERTY_VALUE,
    PROPERTY_VALUE_TYPE = X_PROPERTY_VALUE_TYPE,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN

  where CRITERIA_ID = X_CRITERIA_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW;


PROCEDURE TRANSLATE_ROW(
  x_criteria_id in number,
  x_role_perm_id in number,
  x_property_name in varchar2,
  x_operator in varchar2,
  x_property_value in varchar2,
  x_property_value_type in varchar2,
  x_object_version_number in number,
  x_owner in varchar2
) is

   l_user_id number;

begin

    if (x_owner = 'SEED') then
           l_user_id := 1;
    else
           l_user_id := 0;
    end if;

    JTF_DAC_CRITERIA_PKG.Update_Row(
    X_CRITERIA_ID => X_CRITERIA_ID,
    X_ROLE_PERM_ID => X_ROLE_PERM_ID,
    X_PROPERTY_NAME => X_PROPERTY_NAME,
    X_OPERATOR => X_OPERATOR,
    X_PROPERTY_VALUE => X_PROPERTY_VALUE,
    X_PROPERTY_VALUE_TYPE => X_PROPERTY_VALUE_TYPE,
    X_OBJECT_VERSION_NUMBER => X_OBJECT_VERSION_NUMBER,
    X_Last_Update_Date => sysdate,
    X_Last_Updated_By => l_user_id,
    X_Last_Update_Login => 0);

    exception
      when no_data_found then null;

end;


PROCEDURE LOAD_ROW(
  x_criteria_id in number,
  x_role_perm_id in number,
  x_property_name in varchar2,
  x_operator in varchar2,
  x_property_value in varchar2,
  x_property_value_type in varchar2,
  x_object_version_number in number,
  x_owner in varchar2
) is
    l_user_id number;
    l_rowid varchar2(100);
begin

    if (x_owner = 'SEED') then
           l_user_id := 1;
    else
           l_user_id := 0;
    end if;

   JTF_DAC_CRITERIA_PKG.Update_Row(
    X_CRITERIA_ID => X_CRITERIA_ID,
    X_ROLE_PERM_ID => X_ROLE_PERM_ID,
    X_PROPERTY_NAME => X_PROPERTY_NAME,
    X_OPERATOR => X_OPERATOR,
    X_PROPERTY_VALUE => X_PROPERTY_VALUE,
    X_PROPERTY_VALUE_TYPE => X_PROPERTY_VALUE_TYPE,
    X_OBJECT_VERSION_NUMBER => X_OBJECT_VERSION_NUMBER,
    X_Last_Update_Date => sysdate,
    X_Last_Updated_By => l_user_id,
    X_Last_Update_Login => 0);

     exception
      when no_data_found then
        	JTF_DAC_CRITERIA_PKG.Insert_Row(
       		X_Rowid => l_rowid,
                X_CRITERIA_ID => X_CRITERIA_ID,
                X_ROLE_PERM_ID => X_ROLE_PERM_ID,
                X_PROPERTY_NAME => X_PROPERTY_NAME,
                X_OPERATOR => X_OPERATOR,
                X_PROPERTY_VALUE => X_PROPERTY_VALUE,
                X_PROPERTY_VALUE_TYPE => X_PROPERTY_VALUE_TYPE,
                X_OBJECT_VERSION_NUMBER => X_OBJECT_VERSION_NUMBER,
    		X_Creation_Date => sysdate,
    		X_Created_By => l_user_id,
    		X_Last_Update_Date => sysdate,
    		X_Last_Updated_By => l_user_id,
    		X_Last_Update_Login => 0);

end;



end JTF_DAC_CRITERIA_PKG;

/
