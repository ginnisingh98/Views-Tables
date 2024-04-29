--------------------------------------------------------
--  DDL for Package Body CS_KB_ELE_TYPE_LINKS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_KB_ELE_TYPE_LINKS_PKG" AS
/* $Header: cskbetlb.pls 115.13 2003/12/08 23:22:03 alawang ship $ */


function Create_Element_Type_Link(
  P_LINK_TYPE in VARCHAR2,
  P_OBJECT_CODE in VARCHAR2,
  P_ELEMENT_TYPE_ID in NUMBER,
  P_OTHER_ID in NUMBER,
  P_OTHER_CODE in VARCHAR2,
  P_ATTRIBUTE_CATEGORY in VARCHAR2,
  P_ATTRIBUTE1 in VARCHAR2,
  P_ATTRIBUTE2 in VARCHAR2,
  P_ATTRIBUTE3 in VARCHAR2,
  P_ATTRIBUTE4 in VARCHAR2,
  P_ATTRIBUTE5 in VARCHAR2,
  P_ATTRIBUTE6 in VARCHAR2,
  P_ATTRIBUTE7 in VARCHAR2,
  P_ATTRIBUTE8 in VARCHAR2,
  P_ATTRIBUTE9 in VARCHAR2,
  P_ATTRIBUTE10 in VARCHAR2,
  P_ATTRIBUTE11 in VARCHAR2,
  P_ATTRIBUTE12 in VARCHAR2,
  P_ATTRIBUTE13 in VARCHAR2,
  P_ATTRIBUTE14 in VARCHAR2,
  P_ATTRIBUTE15 in VARCHAR2
) return number IS
  l_date  date;
  l_created_by number;
  l_login number;
  l_count pls_integer;
  l_id number;
  l_rowid varchar2(30);

  CURSOR Check_Link_Exists IS
  select count(*)
    from cs_kb_ele_type_links
    where object_code = p_object_code
    and   element_type_id = p_element_type_id
    and   other_code = p_other_code
    and   (other_id = p_other_id or (other_id is null and p_other_id is null));

  CURSOR Get_Current_Link_ID IS
  select link_id
    from cs_kb_ele_type_links
    where object_code = p_object_code
    and   element_type_id = p_element_type_id
    and   other_code = p_other_code
    and   (other_id = p_other_id or (other_id is null and p_other_id is null));
BEGIN

  -- Check params
  if(P_OBJECT_CODE is null OR P_ELEMENT_TYPE_ID is NULL OR
     (P_OTHER_ID is null and P_OTHER_CODE is null)) then
    goto error_found;
  end if;

  select count(*) into l_count
    from cs_kb_element_types_b
    where element_type_id = p_element_type_id;
  if(l_count <= 0) then goto error_found; end if;

  -- Check for duplication
  OPEN  Check_Link_Exists;
  FETCH Check_Link_Exists INTO l_count;
  CLOSE Check_Link_Exists;

  if(l_count <= 0) then
  begin
      --prepare data, then insert new element

      select cs_kb_ele_type_links_s.nextval into l_id from dual;
      l_date := sysdate;
      l_created_by := fnd_global.user_id;
      l_login := fnd_global.login_id;

      CS_KB_ELE_TYPE_LINKS_PKG.Insert_Row(
        X_Rowid => l_rowid,
        X_Link_Id => l_id,
        X_Link_type => p_link_type,
        X_Object_Code => p_object_code,
        X_Element_Type_Id => p_element_type_id,
        X_Other_Id => p_other_id,
        X_Other_Code => p_other_code,
        X_Creation_Date => l_date,
        X_Created_By => l_created_by,
        X_Last_Update_Date => l_date,
        X_Last_Updated_By => l_created_by,
        X_Last_Update_Login => l_login,
        X_ATTRIBUTE_CATEGORY => P_ATTRIBUTE_CATEGORY,
        X_ATTRIBUTE1 => P_ATTRIBUTE1,
        X_ATTRIBUTE2 => P_ATTRIBUTE2,
        X_ATTRIBUTE3 => P_ATTRIBUTE3,
        X_ATTRIBUTE4 => P_ATTRIBUTE4,
        X_ATTRIBUTE5 => P_ATTRIBUTE5,
        X_ATTRIBUTE6 => P_ATTRIBUTE6,
        X_ATTRIBUTE7 => P_ATTRIBUTE7,
        X_ATTRIBUTE8 => P_ATTRIBUTE8,
        X_ATTRIBUTE9 => P_ATTRIBUTE9,
        X_ATTRIBUTE10 => P_ATTRIBUTE10,
        X_ATTRIBUTE11 => P_ATTRIBUTE11,
        X_ATTRIBUTE12 => P_ATTRIBUTE12,
        X_ATTRIBUTE13 => P_ATTRIBUTE13,
        X_ATTRIBUTE14 => P_ATTRIBUTE14,
        X_ATTRIBUTE15 => P_ATTRIBUTE15
       );
  end;
  else
      -- If duplicated, return the id of exsiting one.
      OPEN  Get_Current_Link_ID;
      FETCH Get_Current_Link_ID INTO l_id;
      CLOSE Get_Current_Link_ID;
  end if;

  return l_id;

  <<error_found>>
  return ERROR_STATUS;

END Create_Element_Type_Link;


function Update_Element_Type_Link(
  P_LINK_ID in NUMBER,
  P_LINK_TYPE in VARCHAR2,
  P_OBJECT_CODE in VARCHAR2,
  P_ELEMENT_TYPE_ID in NUMBER,
  P_OTHER_ID in NUMBER,
  P_OTHER_CODE in VARCHAR2,
  P_ATTRIBUTE_CATEGORY in VARCHAR2,
  P_ATTRIBUTE1 in VARCHAR2,
  P_ATTRIBUTE2 in VARCHAR2,
  P_ATTRIBUTE3 in VARCHAR2,
  P_ATTRIBUTE4 in VARCHAR2,
  P_ATTRIBUTE5 in VARCHAR2,
  P_ATTRIBUTE6 in VARCHAR2,
  P_ATTRIBUTE7 in VARCHAR2,
  P_ATTRIBUTE8 in VARCHAR2,
  P_ATTRIBUTE9 in VARCHAR2,
  P_ATTRIBUTE10 in VARCHAR2,
  P_ATTRIBUTE11 in VARCHAR2,
  P_ATTRIBUTE12 in VARCHAR2,
  P_ATTRIBUTE13 in VARCHAR2,
  P_ATTRIBUTE14 in VARCHAR2,
  P_ATTRIBUTE15 in VARCHAR2
) return number is
  l_ret number;
  l_date  date;
  l_updated_by number;
  l_login number;
  l_count pls_integer;
begin

  -- validate params
  if(P_LINK_ID is null ) then
    goto error_found;
  end if;

  --prepare data, then insert new element
  l_date := sysdate;
  l_updated_by := fnd_global.user_id;
  l_login := fnd_global.login_id;

  CS_KB_ELE_TYPE_LINKS_PKG.Update_Row(
    X_Link_Id => p_link_id,
    X_Link_type => p_link_type,
    X_Object_Code => p_object_code,
    X_Element_Type_Id => p_element_type_id,
    X_Other_Id => p_other_id,
    X_Other_Code => p_other_code,
    X_Last_Update_Date => l_date,
    X_Last_Updated_By => l_updated_by,
    X_Last_Update_Login => l_login,
    X_ATTRIBUTE_CATEGORY => P_ATTRIBUTE_CATEGORY,
    X_ATTRIBUTE1 => P_ATTRIBUTE1,
    X_ATTRIBUTE2 => P_ATTRIBUTE2,
    X_ATTRIBUTE3 => P_ATTRIBUTE3,
    X_ATTRIBUTE4 => P_ATTRIBUTE4,
    X_ATTRIBUTE5 => P_ATTRIBUTE5,
    X_ATTRIBUTE6 => P_ATTRIBUTE6,
    X_ATTRIBUTE7 => P_ATTRIBUTE7,
    X_ATTRIBUTE8 => P_ATTRIBUTE8,
    X_ATTRIBUTE9 => P_ATTRIBUTE9,
    X_ATTRIBUTE10 => P_ATTRIBUTE10,
    X_ATTRIBUTE11 => P_ATTRIBUTE11,
    X_ATTRIBUTE12 => P_ATTRIBUTE12,
    X_ATTRIBUTE13 => P_ATTRIBUTE13,
    X_ATTRIBUTE14 => P_ATTRIBUTE14,
    X_ATTRIBUTE15 => P_ATTRIBUTE15);

  return OKAY_STATUS;
  <<error_found>>
    return ERROR_STATUS;
exception
  when others then
    return ERROR_STATUS;
end Update_Element_Type_Link;


function Delete_Element_Type_Link(
  P_LINK_ID in NUMBER
) return number is

begin
  if (P_LINK_ID is null ) then return ERROR_STATUS;  end if;

  delete from CS_KB_ELE_TYPE_LINKS
  where LINK_ID = P_LINK_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
   return OKAY_STATUS;
  <<error_found>>
  return ERROR_STATUS;

end Delete_Element_Type_Link;


procedure INSERT_ROW (
  X_ROWID in OUT NOCOPY VARCHAR2,
  X_LINK_ID in NUMBER,
  X_LINK_TYPE in varchar2,
  X_OBJECT_CODE in varchar2,
  X_ELEMENT_TYPE_ID in NUMBER,
  X_OTHER_ID in NUMBER,
  X_OTHER_CODE in varchar2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2) IS

  cursor C is select ROWID from CS_KB_ELE_TYPE_LINKS where LINK_ID = X_LINK_ID;

BEGIN


  insert into CS_KB_ELE_TYPE_LINKS (
    LINK_ID,
    LINK_TYPE,
    OBJECT_CODE,
    ELEMENT_TYPE_ID,
    OTHER_ID,
    OTHER_CODE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    ATTRIBUTE_CATEGORY,
    ATTRIBUTE1,
    ATTRIBUTE2,
    ATTRIBUTE3,
    ATTRIBUTE4,
    ATTRIBUTE5,
    ATTRIBUTE6,
    ATTRIBUTE7,
    ATTRIBUTE8,
    ATTRIBUTE9,
    ATTRIBUTE10,
    ATTRIBUTE11,
    ATTRIBUTE12,
    ATTRIBUTE13,
    ATTRIBUTE14,
    ATTRIBUTE15
  ) values (
    x_link_id,
    x_link_type,
    x_object_code,
    x_element_type_id,
    x_other_id,
    x_other_code,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_ATTRIBUTE_CATEGORY,
    X_ATTRIBUTE1,
    X_ATTRIBUTE2,
    X_ATTRIBUTE3,
    X_ATTRIBUTE4,
    X_ATTRIBUTE5,
    X_ATTRIBUTE6,
    X_ATTRIBUTE7,
    X_ATTRIBUTE8,
    X_ATTRIBUTE9,
    X_ATTRIBUTE10,
    X_ATTRIBUTE11,
    X_ATTRIBUTE12,
    X_ATTRIBUTE13,
    X_ATTRIBUTE14,
    X_ATTRIBUTE15
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
  X_LINK_ID in NUMBER,
  X_LINK_TYPE in varchar2,
  X_OBJECT_CODE in varchar2,
  X_ELEMENT_TYPE_ID in NUMBER,
  X_OTHER_ID in NUMBER,
  X_OTHER_CODE in varchar2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2
)IS

BEGIN

  update CS_KB_ELE_TYPE_LINKS set

    LINK_TYPE = X_LINK_TYPE,
    OBJECT_CODE = X_OBJECT_CODE,
    ELEMENT_TYPE_ID = X_ELEMENT_TYPE_ID,
    OTHER_ID = X_OTHER_ID,
    OTHER_CODE = X_OTHER_CODE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY =  X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY,
    ATTRIBUTE1 = X_ATTRIBUTE1,
    ATTRIBUTE2 = X_ATTRIBUTE2,
    ATTRIBUTE3 = X_ATTRIBUTE3,
    ATTRIBUTE4 = X_ATTRIBUTE4,
    ATTRIBUTE5 = X_ATTRIBUTE5,
    ATTRIBUTE6 = X_ATTRIBUTE6,
    ATTRIBUTE7 = X_ATTRIBUTE7,
    ATTRIBUTE8 = X_ATTRIBUTE8,
    ATTRIBUTE9 = X_ATTRIBUTE9,
    ATTRIBUTE10 = X_ATTRIBUTE10,
    ATTRIBUTE11 = X_ATTRIBUTE11,
    ATTRIBUTE12 = X_ATTRIBUTE12,
    ATTRIBUTE13 = X_ATTRIBUTE13,
    ATTRIBUTE14 = X_ATTRIBUTE14,
    ATTRIBUTE15 = X_ATTRIBUTE15

  where LINK_ID = X_LINK_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

END UPDATE_ROW;

PROCEDURE LOAD_ROW(
        X_LINK_ID in NUMBER,
        X_LINK_TYPE in varchar2,
        X_OBJECT_CODE in varchar2,
        X_ELEMENT_TYPE_ID in NUMBER,
        X_OTHER_ID in NUMBER,
        X_OTHER_CODE in varchar2,
	x_owner in varchar2) IS
   l_user_id number;
   l_rowid varchar2(100);
begin

    if (x_owner = 'SEED') then
           l_user_id := 1;
    else
           l_user_id := 0;
    end if;

      CS_KB_ELE_TYPE_LINKS_PKG.Update_Row(
          X_LINK_ID => X_LINK_ID,
	  X_LINK_TYPE => X_LINK_TYPE,
	  X_OBJECT_CODE => X_OBJECT_CODE,
	  X_ELEMENT_TYPE_ID => X_ELEMENT_TYPE_ID,
	  X_OTHER_ID => X_OTHER_ID,
	  X_OTHER_CODE => X_OTHER_CODE,
	  X_LAST_UPDATE_DATE => sysdate,
	  X_LAST_UPDATED_BY => l_user_id,
	  X_LAST_UPDATE_LOGIN => 0);

    exception
      when no_data_found then
  	CS_KB_ELE_TYPE_LINKS_PKG.Insert_Row(
    		X_Rowid => l_rowid,
    		X_Link_ID => x_link_id,
                X_Link_Type => x_link_type,
                X_Object_Code => x_object_code,
                X_Element_Type_Id => x_element_type_id,
                X_Other_Id => x_other_id,
                X_Other_Code => x_other_code,
	        X_CREATION_DATE => sysdate,
	        X_CREATED_BY => l_user_id,
		X_LAST_UPDATE_DATE => sysdate,
	        X_LAST_UPDATED_BY => l_user_id,
                X_LAST_UPDATE_LOGIN => 0);

end;

end CS_KB_ELE_TYPE_LINKS_PKG;

/
