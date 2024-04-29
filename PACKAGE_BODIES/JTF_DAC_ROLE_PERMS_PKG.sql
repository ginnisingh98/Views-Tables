--------------------------------------------------------
--  DDL for Package Body JTF_DAC_ROLE_PERMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_DAC_ROLE_PERMS_PKG" AS
/* $Header: jtfarpb.pls 120.2 2005/10/25 05:15:20 psanyal ship $ */

procedure INSERT_ROW(
  X_ROWID IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
  x_role_perm_id in number,
  x_role_id in number,
  x_permission_id in number,
  x_base_object in varchar2,
  x_base_object_type in varchar2,
  x_start_active_date in date,
  x_end_active_date in date,
  x_object_version_number in number,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
)IS

  cursor C is select ROWID from JTF_DAC_ROLE_PERMS
    where ROLE_PERM_ID = X_ROLE_PERM_ID;
BEGIN

  insert into JTF_DAC_ROLE_PERMS(
    ROLE_PERM_ID,
    ROLE_ID,
    PERMISSION_ID,
    BASE_OBJECT,
    BASE_OBJECT_TYPE,
    START_ACTIVE_DATE,
    END_ACTIVE_DATE,
    OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    x_role_perm_id,
    x_role_id,
    x_permission_id,
    x_base_object,
    x_base_object_type,
    x_start_active_date,
    x_end_active_date,
    x_object_version_number ,
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
  x_role_perm_id in number,
  x_role_id in number,
  x_permission_id in number,
  x_base_object in varchar2,
  x_base_object_type in varchar2,
  x_start_active_date in date,
  x_end_active_date in date,
  x_object_version_number in number,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin

  update JTF_DAC_ROLE_PERMS set
    ROLE_PERM_ID =  x_role_perm_id,
    ROLE_ID =  x_role_id,
    PERMISSION_ID =  x_permission_id,
    BASE_OBJECT = x_base_object,
    BASE_OBJECT_TYPE = x_base_object_type,
    START_ACTIVE_DATE = x_start_active_date,
    END_ACTIVE_DATE = x_end_active_date,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN

  where ROLE_PERM_ID = X_ROLE_PERM_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW;


PROCEDURE TRANSLATE_ROW(
  x_role_perm_id in number,
  x_role_id in number,
  x_permission_id in number,
  x_base_object in varchar2,
  x_base_object_type in varchar2,
  x_start_active_date in date,
  x_end_active_date in date,
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

    JTF_DAC_ROLE_PERMS_PKG.Update_Row(
    X_ROLE_PERM_ID => X_ROLE_PERM_ID,
    x_role_id => x_role_id,
    x_permission_id => x_permission_id,
    x_base_object => x_base_object,
    x_base_object_type => x_base_object_type,
    x_start_active_date => x_start_active_date,
    x_end_active_date => x_end_active_date,
    X_OBJECT_VERSION_NUMBER => X_OBJECT_VERSION_NUMBER,
    X_Last_Update_Date => sysdate,
    X_Last_Updated_By => l_user_id,
    X_Last_Update_Login => 0);

    exception
      when no_data_found then null;

end;


PROCEDURE LOAD_ROW(
  x_role_perm_id in number,
  x_role_id in number,
  x_permission_id in number,
  x_base_object in varchar2,
  x_base_object_type in varchar2,
  x_start_active_date in date,
  x_end_active_date in date,
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

   JTF_DAC_ROLE_PERMS_PKG.Update_Row(
    X_ROLE_PERM_ID => X_ROLE_PERM_ID,
    x_role_id => x_role_id,
    x_permission_id => x_permission_id,
    x_base_object => x_base_object,
    x_base_object_type => x_base_object_type,
    x_start_active_date => x_start_active_date,
    x_end_active_date => x_end_active_date,
    X_OBJECT_VERSION_NUMBER => X_OBJECT_VERSION_NUMBER,
    X_Last_Update_Date => sysdate,
    X_Last_Updated_By => l_user_id,
    X_Last_Update_Login => 0);

     exception
      when no_data_found then
        	JTF_DAC_ROLE_PERMS_PKG.Insert_Row(
       		X_Rowid => l_rowid,
                X_ROLE_PERM_ID => X_ROLE_PERM_ID,
                x_role_id => x_role_id,
                x_permission_id => x_permission_id,
                x_base_object => x_base_object,
                x_base_object_type => x_base_object_type,
                x_start_active_date => x_start_active_date,
                x_end_active_date => x_end_active_date,
                X_OBJECT_VERSION_NUMBER => X_OBJECT_VERSION_NUMBER,
    		X_Creation_Date => sysdate,
    		X_Created_By => l_user_id,
    		X_Last_Update_Date => sysdate,
    		X_Last_Updated_By => l_user_id,
    		X_Last_Update_Login => 0);

end;


end JTF_DAC_ROLE_PERMS_PKG;

/
