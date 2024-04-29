--------------------------------------------------------
--  DDL for Package Body CS_KB_ELEMENT_LINKS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_KB_ELEMENT_LINKS_PKG" AS
/* $Header: cskbellb.pls 120.0 2005/06/01 14:43:12 appldev noship $ */

function Create_Element_Link(
  P_LINK_TYPE in VARCHAR,
  P_OBJECT_CODE in VARCHAR,
  P_ELEMENT_ID in NUMBER,
  P_OTHER_ID in NUMBER,
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
BEGIN

  -- Check params
  if(P_OBJECT_CODE is null OR P_ELEMENT_ID is NULL OR
     (P_OTHER_ID is null
     )) then
    fnd_message.set_name('CS', 'CS_KB_C_MISS_PARAM');
    fnd_msg_pub.Add;
    goto error_found;
  end if;

  --prepare data, then insert new element

  select cs_kb_element_links_s.nextval into l_id from dual;
  l_date := sysdate;
  l_created_by := fnd_global.user_id;
  l_login := fnd_global.login_id;

  CS_KB_ELEMENT_LINKS_PKG.Insert_Row(
    X_Rowid => l_rowid,
    X_Link_Id => l_id,
    X_Link_type => p_link_type,
    X_Object_Code => p_object_code,
    X_Element_Id => p_element_id,
    X_Other_Id => p_other_id,
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

   return l_id;

  <<error_found>>
  return ERROR_STATUS;

END Create_Element_Link;


function Update_Element_Link(
  P_LINK_ID in NUMBER,
  P_LINK_TYPE in VARCHAR,
  P_OBJECT_CODE in VARCHAR,
  P_ELEMENT_ID in NUMBER,
  P_OTHER_ID in NUMBER,
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
  if(P_LINK_ID is null or
     P_OBJECT_CODE is null OR P_ELEMENT_ID is NULL OR
     (P_OTHER_ID is null
     )) then
    fnd_message.set_name('CS', 'CS_KB_C_MISS_PARAM');
    fnd_msg_pub.Add;
    goto error_found;
  end if;

  --prepare data, then insert new element
  l_date := sysdate;
  l_updated_by := fnd_global.user_id;
  l_login := fnd_global.login_id;

  CS_KB_ELEMENT_LINKS_PKG.Update_Row(
    X_Link_Id => p_link_id,
    X_Link_type => p_link_type,
    X_Object_Code => p_object_code,
    X_Element_Id => p_element_id,
    X_Other_Id => p_other_id,
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
end Update_Element_Link;

function Delete_Element_Link_W_Obj_Code(
  p_element_id    in Number,
  p_object_code   in Varchar2,
  p_other_id      in Number
) return number is

begin
  if(P_ELEMENT_ID is null or
     P_OBJECT_CODE is null OR P_OTHER_ID is NULL ) then

    if fnd_msg_pub.Check_Msg_Level( fnd_msg_pub.G_MSG_LVL_ERROR) then
      fnd_message.set_name('CS', 'CS_KB_C_MISS_PARAM');
      fnd_msg_pub.Add;
    end if;
    raise FND_API.G_EXC_ERROR;
    --goto error_found;
  end if;


  DELETE FROM CS_KB_ELEMENT_LINKS where Element_Id = p_element_id
   and Object_Code = p_object_code
   and Other_Id = p_other_id;

   return OKAY_STATUS;
  <<error_found>>
  return ERROR_STATUS;

end Delete_Element_Link_W_Obj_Code;


function Delete_Element_Link(
  P_LINK_ID in NUMBER
) return number is

begin
  if (P_LINK_ID is null ) then return ERROR_STATUS;  end if;

  delete from CS_KB_ELEMENT_LINKS
  where LINK_ID = P_LINK_ID;

  return OKAY_STATUS;
  <<error_found>>
  return ERROR_STATUS;

end Delete_Element_Link;

procedure INSERT_ROW (
  X_ROWID in OUT NOCOPY VARCHAR2,
  X_LINK_ID in NUMBER,
  X_LINK_TYPE in VARCHAR2,
  X_OBJECT_CODE in VARCHAR2,
  X_ELEMENT_ID in NUMBER,
  X_OTHER_ID in NUMBER,
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

  cursor C is select ROWID from CS_KB_ELEMENT_LINKS where LINK_ID = X_LINK_ID;


BEGIN

  insert into CS_KB_ELEMENT_LINKS (
    LINK_ID,
    LINK_TYPE,
    OBJECT_CODE,
    ELEMENT_ID,
    OTHER_ID,
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
    X_LINK_ID,
    X_LINK_TYPE,
    X_OBJECT_CODE,
    X_ELEMENT_ID,
    X_OTHER_ID,
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
  X_LINK_TYPE in VARCHAR2,
  X_OBJECT_CODE in VARCHAR2,
  X_ELEMENT_ID in NUMBER,
  X_OTHER_ID in NUMBER,
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
) IS

BEGIN

  update CS_KB_ELEMENT_LINKS set

    LINK_TYPE = X_LINK_TYPE,
    OBJECT_CODE = X_OBJECT_CODE,
    ELEMENT_ID = X_ELEMENT_ID,
    OTHER_ID  = X_OTHER_ID,
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


end CS_KB_ELEMENT_LINKS_PKG;

/
