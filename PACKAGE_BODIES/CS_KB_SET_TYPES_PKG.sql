--------------------------------------------------------
--  DDL for Package Body CS_KB_SET_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_KB_SET_TYPES_PKG" AS
/* $Header: cskbstb.pls 115.16 2003/11/19 23:39:10 mkettle ship $ */
/*======================================================================+
 |                Copyright (c) 1999 Oracle Corporation                 |
 |                   Redwood Shores, California, USA                    |
 |                        All rights reserved.                          |
 +======================================================================+
 | HISTORY                                                              |
 |  18-OCT-1999 A. WONG Created                                         |
 |  01-DEC-1999 ALAM    Added parameter name to create/update func.     |
 |  01-JAN-2000 ALAM    Added translate_row and load_row procedure.     |
 |  28-JAN-2000 ALAM    Modified delete_set_type function.              |
 |  25-APR-2001 SKLEONG Modified the delete_set_type function.          |
 |  14-AUG-2002 KLOU  (SEDATE)                                          |
 |              1. Add logic to handle new columns start_date_active and|
 |                 end_date_active.                                     |
 +======================================================================*/

FUNCTION Create_Set_Type(
  p_name in varchar2,
  p_desc in varchar2,
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
  P_ATTRIBUTE15 in VARCHAR2,
  P_START_DATE  in DATE,
  P_END_DATE    in DATE
) return number is
  l_date  date;
  l_created_by number;
  l_login number;
  l_count pls_integer;
  l_id number;
  l_rowid varchar2(30);
begin

  -- Check params
  if(p_desc is null or p_name is null) then
    goto error_found;
  end if;


  --prepare data, then insert new set_type
  select cs_kb_set_types_s.nextval into l_id from dual;
  l_date := sysdate;
  l_created_by := fnd_global.user_id;
  l_login := fnd_global.login_id;

  CS_KB_SET_TYPES_PKG.Insert_Row(
    X_Rowid => l_rowid,
    X_Set_Type_Id => l_id,
    X_Name => p_name,
    X_Description => p_desc,
    X_Creation_Date => l_date,
    X_Created_By => l_created_by,
    X_Last_Update_Date => l_date,
    X_Last_Updated_By => l_created_by,
    X_Last_Update_Login => l_login,
    X_Set_Type_Name => null,
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
    X_ATTRIBUTE15 => P_ATTRIBUTE15,
    X_START_DATE  => P_START_DATE,
    X_END_DATE    => P_END_DATE

);
  return l_id;

  <<error_found>>
  return ERROR_STATUS;
end Create_Set_Type;



-- Update Set_Type data
--
FUNCTION Update_Set_Type(
  p_set_type_id in number,
  p_name in varchar2,
  p_desc in varchar2,
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
  P_ATTRIBUTE15 in VARCHAR2,
  P_START_DATE  in DATE,
  P_END_DATE    in DATE
) return number is
  l_ret number;
  l_date  date;
  l_updated_by number;
  l_login number;
  l_count pls_integer;
begin

  -- validate params
  if(p_set_type_id is null) then
    goto error_found;
  end if;

  --prepare data, then insert new set_type
  l_date := sysdate;
  l_updated_by := fnd_global.user_id;
  l_login := fnd_global.login_id;

  CS_KB_SET_TYPES_PKG.Update_Row(
    X_Set_Type_Id => p_set_type_id,
    X_Name => p_name,
    X_Description => p_desc,
    X_Last_Update_Date => l_date,
    X_Last_Updated_By => l_updated_by,
    X_Last_Update_Login => l_login,
    X_Set_Type_Name => null,
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
    X_ATTRIBUTE15 => P_ATTRIBUTE15,
    X_START_DATE  => P_START_DATE,
    X_END_DATE    => P_END_DATE);

  return OKAY_STATUS;
  <<error_found>>
  return ERROR_STATUS;
exception
  when others then
    return ERROR_STATUS;
end Update_Set_Type;

--
-- Delete set type

FUNCTION Delete_Set_Type(
  p_set_type_id in number
) return number is
  l_ret number;
  l_count pls_integer;
begin
  if p_set_type_id is null or p_set_type_id <= 0 then
     fnd_message.set_name('CS', 'CS_KB_C_INVALID_SET_TYPE_ID');
     return ERROR_STATUS;
  end if;

  --
  --
  select count(*) into l_count
    from cs_kb_set_types_b
    where set_type_id = p_set_type_id;
  if(l_count <= 0) then
    fnd_message.set_name('CS', 'CS_KB_C_INVALID_SET_TYPE_ID');
    return ERROR_STATUS;
  end if;

  -- Check element links
  --
  select count(*) into l_count
    from cs_kb_set_ele_types
    where set_type_id = p_set_type_id;
  if(l_count > 0) then
    fnd_message.set_name('CS', 'CS_KB_C_SET_TYPE_WITH_ELE_TYPE');
    return ERROR_STATUS; end if;

  -- Check external links
  --
  select count(*) into l_count
    from cs_kb_set_type_links
    where set_type_id = p_set_type_id;
  if(l_count > 0) then
    fnd_message.set_name('CS', 'CS_KB_C_SET_TYPE_WITH_LINK');
    return ERROR_STATUS; end if;

  -- Check sets with defined set type
  --
  -- Commented 19-Nov-2003 - Duplicate code with below
  --  select count(*) into l_count
  --    from cs_kb_sets_vl
  --    where set_type_id = p_set_type_id;
  --  if(l_count > 0) then
  --    fnd_message.set_name('CS', 'CS_KB_C_SET_TYPE_WITH_SET');
  --    return ERROR_STATUS; end if;

  select /*+ INDEX(s) */ count(*) into l_count
    from cs_kb_sets_b s
    where s.set_type_id = p_set_type_id
    and (s.latest_version_flag = 'Y' OR s.viewable_version_flag = 'Y')
    and s.status <> 'OBS';
  if(l_count > 0) then
    fnd_message.set_name('CS', 'CS_KB_C_SET_TYPE_WITH_SET');
    return ERROR_STATUS; end if;


  CS_KB_SET_TYPES_PKG.Delete_Row(
    X_Set_Type_Id => p_set_type_id);

   return OKAY_STATUS;
  <<error_found>>
  return ERROR_STATUS;

exception
  WHEN OTHERS THEN
    return ERROR_STATUS;
end Delete_Set_Type;


procedure INSERT_ROW (
  X_ROWID in OUT NOCOPY VARCHAR2,
  X_SET_TYPE_ID in NUMBER,
  X_SET_TYPE_NAME in VARCHAR2,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
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
  X_ATTRIBUTE15 in VARCHAR2,
  X_START_DATE  in DATE,
  X_END_DATE    in DATE
) is
  cursor C is select ROWID from CS_KB_SET_TYPES_B
    where SET_TYPE_ID = X_SET_TYPE_ID
    ;
begin
  insert into CS_KB_SET_TYPES_B (
    SET_TYPE_ID,
    SET_TYPE_NAME,
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
    ATTRIBUTE15,
    START_DATE_ACTIVE,
    END_DATE_ACTIVE
  ) values (
    X_SET_TYPE_ID,
    X_SET_TYPE_NAME,
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
    X_ATTRIBUTE15,
    X_START_DATE,
    X_END_DATE
  );

  insert into CS_KB_SET_TYPES_TL (
    SET_TYPE_ID,
    NAME,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_SET_TYPE_ID,
    X_NAME,
    X_DESCRIPTION,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from CS_KB_SET_TYPES_TL T
    where T.SET_TYPE_ID = X_SET_TYPE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_SET_TYPE_ID in NUMBER,
  X_SET_TYPE_NAME in VARCHAR2,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
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
  X_ATTRIBUTE15 in VARCHAR2,
  X_START_DATE  in DATE,
  X_END_DATE    in DATE
) is
  cursor c is select
      SET_TYPE_ID,
      SET_TYPE_NAME,
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
      ATTRIBUTE15,
      START_DATE_ACTIVE,
      END_DATE_ACTIVE
    from CS_KB_SET_TYPES_B
    where SET_TYPE_ID = X_SET_TYPE_ID
    for update of SET_TYPE_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from CS_KB_SET_TYPES_TL
    where SET_TYPE_ID = X_SET_TYPE_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of SET_TYPE_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (
          ((recinfo.SET_TYPE_ID = X_SET_TYPE_ID)
           OR ((recinfo.SET_TYPE_ID is null) AND (X_SET_TYPE_ID is null)))
      AND ((recinfo.SET_TYPE_NAME = X_SET_TYPE_NAME)
           OR ((recinfo.SET_TYPE_NAME is null) AND (X_SET_TYPE_NAME is null)))
      AND ((recinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
           OR ((recinfo.ATTRIBUTE_CATEGORY is null) AND (X_ATTRIBUTE_CATEGORY is null)))
      AND ((recinfo.ATTRIBUTE1 = X_ATTRIBUTE1)
           OR ((recinfo.ATTRIBUTE1 is null) AND (X_ATTRIBUTE1 is null)))
      AND ((recinfo.ATTRIBUTE2 = X_ATTRIBUTE2)
           OR ((recinfo.ATTRIBUTE2 is null) AND (X_ATTRIBUTE2 is null)))
      AND ((recinfo.ATTRIBUTE3 = X_ATTRIBUTE3)
           OR ((recinfo.ATTRIBUTE3 is null) AND (X_ATTRIBUTE3 is null)))
      AND ((recinfo.ATTRIBUTE4 = X_ATTRIBUTE4)
           OR ((recinfo.ATTRIBUTE4 is null) AND (X_ATTRIBUTE4 is null)))
      AND ((recinfo.ATTRIBUTE5 = X_ATTRIBUTE5)
           OR ((recinfo.ATTRIBUTE5 is null) AND (X_ATTRIBUTE5 is null)))
      AND ((recinfo.ATTRIBUTE6 = X_ATTRIBUTE6)
           OR ((recinfo.ATTRIBUTE6 is null) AND (X_ATTRIBUTE6 is null)))
      AND ((recinfo.ATTRIBUTE7 = X_ATTRIBUTE7)
           OR ((recinfo.ATTRIBUTE7 is null) AND (X_ATTRIBUTE7 is null)))
      AND ((recinfo.ATTRIBUTE8 = X_ATTRIBUTE8)
           OR ((recinfo.ATTRIBUTE8 is null) AND (X_ATTRIBUTE8 is null)))
      AND ((recinfo.ATTRIBUTE9 = X_ATTRIBUTE9)
           OR ((recinfo.ATTRIBUTE9 is null) AND (X_ATTRIBUTE9 is null)))
      AND ((recinfo.ATTRIBUTE10 = X_ATTRIBUTE10)
           OR ((recinfo.ATTRIBUTE10 is null) AND (X_ATTRIBUTE10 is null)))
      AND ((recinfo.ATTRIBUTE11 = X_ATTRIBUTE11)
           OR ((recinfo.ATTRIBUTE11 is null) AND (X_ATTRIBUTE11 is null)))
      AND ((recinfo.ATTRIBUTE12 = X_ATTRIBUTE12)
           OR ((recinfo.ATTRIBUTE12 is null) AND (X_ATTRIBUTE12 is null)))
      AND ((recinfo.ATTRIBUTE13 = X_ATTRIBUTE13)
           OR ((recinfo.ATTRIBUTE13 is null) AND (X_ATTRIBUTE13 is null)))
      AND ((recinfo.ATTRIBUTE14 = X_ATTRIBUTE14)
           OR ((recinfo.ATTRIBUTE14 is null) AND (X_ATTRIBUTE14 is null)))
      AND ((recinfo.ATTRIBUTE15 = X_ATTRIBUTE15)
           OR ((recinfo.ATTRIBUTE15 is null) AND (X_ATTRIBUTE15 is null)))
      AND ((recinfo.START_DATE_ACTIVE = X_START_DATE)
           OR ((recinfo.START_DATE_ACTIVE is null) AND (X_START_DATE is null)))
      AND ((recinfo.END_DATE_ACTIVE = X_END_DATE)
           OR ((recinfo.END_DATE_ACTIVE is null) AND (X_END_DATE is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.NAME = X_NAME)
               OR ((tlinfo.NAME is null) AND (X_NAME is null)))
          AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
               OR ((tlinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
      ) then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
    end if;
  end loop;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_SET_TYPE_ID in NUMBER,
  X_SET_TYPE_NAME in VARCHAR2,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
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
  X_ATTRIBUTE15 in VARCHAR2,
  X_START_DATE  in DATE,
  X_END_DATE    in DATE
) is
begin
  update CS_KB_SET_TYPES_B set
    SET_TYPE_NAME = X_SET_TYPE_NAME,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
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
    ATTRIBUTE15 = X_ATTRIBUTE15,
    START_DATE_ACTIVE  = X_START_DATE,
    END_DATE_ACTIVE    = X_END_DATE
  where SET_TYPE_ID = X_SET_TYPE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update CS_KB_SET_TYPES_TL set
    NAME = X_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where SET_TYPE_ID = X_SET_TYPE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_SET_TYPE_ID in NUMBER
) is
begin
  delete from CS_KB_SET_TYPES_TL
  where SET_TYPE_ID = X_SET_TYPE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from CS_KB_SET_TYPES_B
  where SET_TYPE_ID = X_SET_TYPE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from CS_KB_SET_TYPES_TL T
  where not exists
    (select NULL
    from CS_KB_SET_TYPES_B B
    where B.SET_TYPE_ID = T.SET_TYPE_ID
    );

  update CS_KB_SET_TYPES_TL T set (
      NAME,
      DESCRIPTION
    ) = (select
      B.NAME,
      B.DESCRIPTION
    from CS_KB_SET_TYPES_TL B
    where B.SET_TYPE_ID = T.SET_TYPE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.SET_TYPE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.SET_TYPE_ID,
      SUBT.LANGUAGE
    from CS_KB_SET_TYPES_TL SUBB, CS_KB_SET_TYPES_TL SUBT
    where SUBB.SET_TYPE_ID = SUBT.SET_TYPE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or (SUBB.NAME is null and SUBT.NAME is not null)
      or (SUBB.NAME is not null and SUBT.NAME is null)
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into CS_KB_SET_TYPES_TL (
    SET_TYPE_ID,
    NAME,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.SET_TYPE_ID,
    B.NAME,
    B.DESCRIPTION,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from CS_KB_SET_TYPES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from CS_KB_SET_TYPES_TL T
    where T.SET_TYPE_ID = B.SET_TYPE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;


PROCEDURE TRANSLATE_ROW(
        x_set_type_id in number,
	x_owner in varchar2,
        x_name in varchar2,
        x_description in varchar2) is
   l_user_id number;

begin

     update CS_KB_SET_TYPES_TL set
	NAME = X_NAME,
	DESCRIPTION=X_DESCRIPTION,
	last_update_date  = sysdate,
     last_updated_by   = decode(X_OWNER, 'SEED', 1, 0),
     last_update_login = 0,
     source_lang       = userenv('LANG')
      where SET_TYPE_ID = to_number(X_SET_TYPE_ID)
      and userenv('LANG') in (language, source_lang);

end;



PROCEDURE LOAD_ROW(
        x_set_type_id in number,
	x_owner in varchar2,
        x_name in varchar2,
        x_description in varchar2) is
   l_user_id number;
   l_rowid varchar2(100);
begin

    if (x_owner = 'SEED') then
           l_user_id := 1;
    else
           l_user_id := 0;
    end if;

    CS_KB_SET_TYPES_PKG.Update_Row(
    X_Set_Type_Id => x_set_type_id,
    X_Name => x_name,
    X_Description => x_description,
    X_Last_Update_Date => sysdate,
    X_Last_Updated_By => l_user_id,
    X_Last_Update_Login => 0,
    X_Set_Type_Name => null);
    exception
      when no_data_found then
  	CS_KB_SET_TYPES_PKG.Insert_Row(
    		X_Rowid => l_rowid,
    		X_Set_Type_Id => x_set_type_id,
    		X_Name => x_name,
    		X_Description => x_description,
    		X_Creation_Date => sysdate,
    		X_Created_By => l_user_id,
    		X_Last_Update_Date => sysdate,
    		X_Last_Updated_By => l_user_id,
    		X_Last_Update_Login => 0,
    		X_Set_Type_Name => null);

end;



end CS_KB_SET_TYPES_PKG;

/
