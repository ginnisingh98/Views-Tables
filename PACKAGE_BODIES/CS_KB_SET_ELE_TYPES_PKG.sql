--------------------------------------------------------
--  DDL for Package Body CS_KB_SET_ELE_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_KB_SET_ELE_TYPES_PKG" AS
/* $Header: cskbsetb.pls 115.15 2003/11/19 23:39:36 mkettle ship $ */

function Create_Set_Ele_Type(
  P_SET_TYPE_ID in NUMBER,
  P_ELEMENT_TYPE_ID in NUMBER,
  P_ELEMENT_TYPE_ORDER in NUMBER,
  P_OPTIONAL_FLAG in VARCHAR2,
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
BEGIN

  -- Check params
  if(P_SET_TYPE_ID is null OR P_ELEMENT_TYPE_ID is NULL) then
    goto error_found;
  end if;

  l_date := sysdate;
  l_created_by := fnd_global.user_id;
  l_login := fnd_global.login_id;

  insert into CS_KB_SET_ELE_TYPES (
    SET_TYPE_ID,
    ELEMENT_TYPE_ID,
    ELEMENT_TYPE_ORDER,
    OPTIONAL_FLAG,
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
    P_SET_TYPE_ID,
    P_ELEMENT_TYPE_ID,
    P_ELEMENT_TYPE_ORDER,
    P_OPTIONAL_FLAG,
    l_date,
    l_created_by,
    l_date,
    l_created_by,
    l_login,
    P_ATTRIBUTE_CATEGORY,
    P_ATTRIBUTE1,
    P_ATTRIBUTE2,
    P_ATTRIBUTE3,
    P_ATTRIBUTE4,
    P_ATTRIBUTE5,
    P_ATTRIBUTE6,
    P_ATTRIBUTE7,
    P_ATTRIBUTE8,
    P_ATTRIBUTE9,
    P_ATTRIBUTE10,
    P_ATTRIBUTE11,
    P_ATTRIBUTE12,
    P_ATTRIBUTE13,
    P_ATTRIBUTE14,
    P_ATTRIBUTE15
    );

  return OKAY_STATUS;
  <<error_found>>
  return ERROR_STATUS;

END Create_Set_Ele_Type;


function Update_Set_Ele_Type(
  P_SET_TYPE_ID in NUMBER,
  P_ELEMENT_TYPE_ID in NUMBER,
  P_ELEMENT_TYPE_ORDER in NUMBER,
  P_OPTIONAL_FLAG in VARCHAR2,
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
begin

  -- validate params
  if(P_SET_TYPE_ID is null OR P_ELEMENT_TYPE_ID is null) then
    goto error_found;
  end if;

  l_date := sysdate;
  l_updated_by := fnd_global.user_id;
  l_login := fnd_global.login_id;

  update CS_KB_SET_ELE_TYPES set
    ELEMENT_TYPE_ORDER = P_ELEMENT_TYPE_ORDER,
    OPTIONAL_FLAG = P_OPTIONAL_FLAG,
    LAST_UPDATE_DATE = l_date,
    LAST_UPDATED_BY = l_updated_by,
    LAST_UPDATE_LOGIN = l_login,
    ATTRIBUTE_CATEGORY = P_ATTRIBUTE_CATEGORY,
    ATTRIBUTE1 = P_ATTRIBUTE1,
    ATTRIBUTE2 = P_ATTRIBUTE2,
    ATTRIBUTE3 = P_ATTRIBUTE3,
    ATTRIBUTE4 = P_ATTRIBUTE4,
    ATTRIBUTE5 = P_ATTRIBUTE5,
    ATTRIBUTE6 = P_ATTRIBUTE6,
    ATTRIBUTE7 = P_ATTRIBUTE7,
    ATTRIBUTE8 = P_ATTRIBUTE8,
    ATTRIBUTE9 = P_ATTRIBUTE9,
    ATTRIBUTE10 = P_ATTRIBUTE10,
    ATTRIBUTE11 = P_ATTRIBUTE11,
    ATTRIBUTE12 = P_ATTRIBUTE12,
    ATTRIBUTE13 = P_ATTRIBUTE13,
    ATTRIBUTE14 = P_ATTRIBUTE14,
    ATTRIBUTE15 = P_ATTRIBUTE15
  where SET_TYPE_ID = P_SET_TYPE_ID
  and ELEMENT_TYPE_ID = P_ELEMENT_TYPE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  return OKAY_STATUS;
  <<error_found>>
  return ERROR_STATUS;
exception
  when others then
    return ERROR_STATUS;
end Update_Set_Ele_Type;

function Delete_Set_Ele_Type (
  P_SET_TYPE_ID in NUMBER,
  P_ELEMENT_TYPE_ID in NUMBER
) return number is
l_count number;
begin
  if (P_SET_TYPE_ID is null or P_ELEMENT_TYPE_ID is null) then return ERROR_STATUS;  end if;

--  select count(*) into l_count
--    from cs_kb_set_eles where Set_Id In (
--    Select e.Set_Id from cs_kb_set_eles e, cs_kb_sets_b s, cs_kb_elements_b t
--    where t.element_type_id = p_element_type_id and s.set_type_id = p_set_type_id and
--    e.Set_Id = s.Set_Id and e.Element_Id = t.Element_Id);
  select /*+ INDEX(s) */ count(*) into l_count
    from cs_kb_sets_b s
    where s.set_type_id = p_set_type_id
    and s.status <> 'OBS'
    and (s.latest_version_flag = 'Y' OR s.viewable_version_flag = 'Y')
    and exists (select 'x'
                from cs_kb_set_eles se,
                     cs_kb_elements_b e
                where se.element_id = e.element_id
                and se.set_id = s.set_id
                and e.element_type_id = p_element_type_id
                and e.status <> 'OBS');
  if(l_count > 0) then
    fnd_message.set_name('CS', 'CS_KB_C_SET_TYPE_WITH_SET');
 --   fnd_msg_pub.Add;
 --   raise FND_API.G_EXC_ERROR;
    return ERROR_STATUS;
  end if;

  delete from CS_KB_SET_ELE_TYPES
  where SET_TYPE_ID = P_SET_TYPE_ID
  and ELEMENT_TYPE_ID = P_ELEMENT_TYPE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
   return OKAY_STATUS;
  <<error_found>>
  return ERROR_STATUS;

end Delete_Set_Ele_Type;

procedure INSERT_ROW (
  X_ROWID in OUT NOCOPY VARCHAR2,
  X_SET_TYPE_ID in NUMBER,
  X_ELEMENT_TYPE_ID in NUMBER,
  X_ELEMENT_TYPE_ORDER in NUMBER,
  X_OPTIONAL_FLAG in VARCHAR2,
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

  cursor C is select ROWID from CS_KB_SET_ELE_TYPES where SET_TYPE_ID = X_SET_TYPE_ID
                                                    AND   ELEMENT_TYPE_ID = X_ELEMENT_TYPE_ID;

BEGIN


  insert into CS_KB_SET_ELE_TYPES (
    SET_TYPE_ID,
    ELEMENT_TYPE_ID,
    ELEMENT_TYPE_ORDER,
    OPTIONAL_FLAG,
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
    X_SET_TYPE_ID,
    X_ELEMENT_TYPE_ID,
    X_ELEMENT_TYPE_ORDER,
    X_OPTIONAL_FLAG,
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
  X_SET_TYPE_ID in NUMBER,
  X_ELEMENT_TYPE_ID in NUMBER,
  X_ELEMENT_TYPE_ORDER in NUMBER,
  X_OPTIONAL_FLAG in VARCHAR2,
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

  update CS_KB_SET_ELE_TYPES set

    ELEMENT_TYPE_ORDER = X_ELEMENT_TYPE_ORDER,
    OPTIONAL_FLAG = X_OPTIONAL_FLAG,
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
  where SET_TYPE_ID = X_SET_TYPE_ID
  and ELEMENT_TYPE_ID = X_ELEMENT_TYPE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

END UPDATE_ROW;

PROCEDURE LOAD_ROW(
        x_set_type_id in number,
        x_element_type_id in number,
        x_element_type_order in number,
        x_optional_flag in varchar2,
	x_owner in varchar2) IS
   l_user_id number;
   l_rowid varchar2(100);
begin

    if (x_owner = 'SEED') then
           l_user_id := 1;
    else
           l_user_id := 0;
    end if;

    CS_KB_SET_ELE_TYPES_PKG.Update_Row(
    X_Set_Type_Id => x_set_type_id,
    X_Element_Type_Id => x_element_type_id,
    X_ELEMENT_TYPE_ORDER => x_element_type_order,
    X_OPTIONAL_FLAG => x_optional_flag,
    X_LAST_UPDATE_DATE => sysdate,
    X_LAST_UPDATED_BY => l_user_id,
    X_LAST_UPDATE_LOGIN => 0);

    exception
      when no_data_found then
  	CS_KB_SET_ELE_TYPES_PKG.Insert_Row(
    		X_Rowid => l_rowid,
    		X_SET_TYPE_ID => x_set_type_id,
                X_ELEMENT_TYPE_ID => x_element_type_id,
	        X_ELEMENT_TYPE_ORDER => x_element_type_order,
	        X_OPTIONAL_FLAG => x_optional_flag,
	        X_CREATION_DATE => sysdate,
	        X_CREATED_BY => l_user_id,
		X_LAST_UPDATE_DATE => sysdate,
	        X_LAST_UPDATED_BY => l_user_id,
                X_LAST_UPDATE_LOGIN => 0);

end;

end CS_KB_SET_ELE_TYPES_PKG;

/
