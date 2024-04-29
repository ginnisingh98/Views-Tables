--------------------------------------------------------
--  DDL for Package Body JTF_DAC_ROLE_PERM_CRIT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_DAC_ROLE_PERM_CRIT_PKG" AS
/* $Header: jtfapcb.pls 120.2 2005/10/25 05:14:19 psanyal ship $ */

procedure INSERT_ROW(
  X_ROWID IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
  x_role_perm_crit_id in number,
  x_role_perm_id in number,
  x_criteria_id in number,
  x_jtf_auth_principal_id in number,
  x_jtf_auth_permission_id in number,
  x_principal_name in varchar2,
  x_permission_name in varchar2,
  x_base_object in varchar2,
  x_base_object_type in varchar2,
  x_start_active_date in date,
  x_end_active_date in date,
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

  cursor C is select ROWID from JTF_DAC_ROLE_PERM_CRIT
    where ROLE_PERM_CRIT_ID = X_ROLE_PERM_CRIT_ID;
BEGIN

  insert into JTF_DAC_ROLE_PERM_CRIT(
    ROLE_PERM_CRIT_ID,
    ROLE_PERM_ID,
    CRITERIA_ID,
    JTF_AUTH_PRINCIPAL_ID,
    JTF_AUTH_PERMISSION_ID,
    PRINCIPAL_NAME,
    PERMISSION_NAME,
    BASE_OBJECT,
    BASE_OBJECT_TYPE,
    START_ACTIVE_DATE,
    END_ACTIVE_DATE,
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
   x_role_perm_crit_id,
   x_role_perm_id,
   x_criteria_id,
   x_jtf_auth_principal_id,
   x_jtf_auth_permission_id,
   x_principal_name,
   x_permission_name,
   x_base_object,
   x_base_object_type,
   x_start_active_date,
   x_end_active_date,
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
  x_role_perm_crit_id in number,
  x_role_perm_id in number,
  x_criteria_id in number,
  x_jtf_auth_principal_id in number,
  x_jtf_auth_permission_id in number,
  x_principal_name in varchar2,
  x_permission_name in varchar2,
  x_base_object in varchar2,
  x_base_object_type in varchar2,
  x_start_active_date in date,
  x_end_active_date in date,
  x_property_name in varchar2,
  x_operator in varchar2,
  x_property_value in varchar2,
  x_property_value_type in varchar2,
  x_object_version_number in number,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
)is
begin

  update JTF_DAC_ROLE_PERM_CRIT set
    role_perm_crit_id = x_role_perm_crit_id,
    role_perm_id = x_role_perm_id,
    criteria_id = x_criteria_id,
    jtf_auth_principal_id = x_jtf_auth_principal_id,
    jtf_auth_permission_id = x_jtf_auth_permission_id,
    principal_name = x_principal_name,
    permission_name = x_permission_name,
    base_object = x_base_object,
    base_object_type = x_base_object,
    start_active_date = x_start_active_date,
    end_active_date = x_end_active_date,
    property_name = x_property_name,
    operator = x_operator,
    property_value = x_property_value,
    property_value_type = x_property_value_type,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN

    where ROLE_PERM_CRIT_ID = X_ROLE_PERM_CRIT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW;


PROCEDURE TRANSLATE_ROW(
  x_role_perm_crit_id in number,
  x_role_perm_id in number,
  x_criteria_id in number,
  x_jtf_auth_principal_id in number,
  x_jtf_auth_permission_id in number,
  x_principal_name in varchar2,
  x_permission_name in varchar2,
  x_base_object in varchar2,
  x_base_object_type in varchar2,
  x_start_active_date in date,
  x_end_active_date in date,
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

    JTF_DAC_ROLE_PERM_CRIT_PKG.Update_Row(
    x_role_perm_crit_id => x_role_perm_crit_id,
    x_role_perm_id => x_role_perm_id,
    x_criteria_id => x_criteria_id,
    x_jtf_auth_principal_id => x_jtf_auth_principal_id,
    x_jtf_auth_permission_id => x_jtf_auth_permission_id,
    x_principal_name => x_principal_name,
    x_permission_name => x_permission_name,
    x_base_object => x_base_object,
    x_base_object_type => x_base_object_type,
    x_start_active_date => x_start_active_date,
    x_end_active_date => x_end_active_date,
    x_property_name => x_property_name,
    x_operator => x_operator,
    x_property_value => x_property_value,
    x_property_value_type => x_property_value_type,
    X_OBJECT_VERSION_NUMBER => X_OBJECT_VERSION_NUMBER,
    X_Last_Update_Date => sysdate,
    X_Last_Updated_By => l_user_id,
    X_Last_Update_Login => 0);

    exception
      when no_data_found then null;

end;


PROCEDURE LOAD_ROW(
  x_role_perm_crit_id in number,
  x_role_perm_id in number,
  x_criteria_id in number,
  x_jtf_auth_principal_id in number,
  x_jtf_auth_permission_id in number,
  x_principal_name in varchar2,
  x_permission_name in varchar2,
  x_base_object in varchar2,
  x_base_object_type in varchar2,
  x_start_active_date in date,
  x_end_active_date in date,
  x_property_name in varchar2,
  x_operator in varchar2,
  x_property_value in varchar2,
  x_property_value_type in varchar2,
  x_object_version_number in number,
  x_owner in varchar2
)is
    l_user_id number;
    l_rowid varchar2(100);
begin

    if (x_owner = 'SEED') then
           l_user_id := 1;
    else
           l_user_id := 0;
    end if;

   JTF_DAC_ROLE_PERM_CRIT_PKG.Update_Row(
    x_role_perm_crit_id => x_role_perm_crit_id,
    x_role_perm_id => x_role_perm_id,
    x_criteria_id => x_criteria_id,
    x_jtf_auth_principal_id => x_jtf_auth_principal_id,
    x_jtf_auth_permission_id => x_jtf_auth_permission_id,
    x_principal_name => x_principal_name,
    x_permission_name => x_permission_name,
    x_base_object => x_base_object,
    x_base_object_type => x_base_object_type,
    x_start_active_date => x_start_active_date,
    x_end_active_date => x_end_active_date,
    x_property_name => x_property_name,
    x_operator => x_operator,
    x_property_value => x_property_value,
    x_property_value_type => x_property_value_type,
    X_OBJECT_VERSION_NUMBER => X_OBJECT_VERSION_NUMBER,
    X_Last_Update_Date => sysdate,
    X_Last_Updated_By => l_user_id,
    X_Last_Update_Login => 0);
     exception
      when no_data_found then
        	JTF_DAC_ROLE_PERM_CRIT_PKG.Insert_Row(
       		X_Rowid => l_rowid,
                x_role_perm_crit_id => x_role_perm_crit_id,
                x_role_perm_id => x_role_perm_id,
                x_criteria_id => x_criteria_id,
                x_jtf_auth_principal_id => x_jtf_auth_principal_id,
                x_jtf_auth_permission_id => x_jtf_auth_permission_id,
                x_principal_name => x_principal_name,
                x_permission_name => x_permission_name,
                x_base_object => x_base_object,
                x_base_object_type => x_base_object_type,
                x_start_active_date => x_start_active_date,
                x_end_active_date => x_end_active_date,
                x_property_name => x_property_name,
                x_operator => x_operator,
                x_property_value => x_property_value,
                x_property_value_type => x_property_value_type,
                X_OBJECT_VERSION_NUMBER => X_OBJECT_VERSION_NUMBER,
    		X_Creation_Date => sysdate,
    		X_Created_By => l_user_id,
    		X_Last_Update_Date => sysdate,
    		X_Last_Updated_By => l_user_id,
    		X_Last_Update_Login => 0);

end;



end JTF_DAC_ROLE_PERM_CRIT_PKG;

/
