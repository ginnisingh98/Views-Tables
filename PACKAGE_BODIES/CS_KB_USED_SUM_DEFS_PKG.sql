--------------------------------------------------------
--  DDL for Package Body CS_KB_USED_SUM_DEFS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_KB_USED_SUM_DEFS_PKG" AS
/* $Header: cskbusdb.pls 115.9 2002/12/02 23:04:12 mkettle ship $ */


--
-- Create a new empty Used_Sum_Def and returns id.
--
FUNCTION Create_Used_Sum_Def(
  p_days            in NUMBER,
  p_default_flag    in VARCHAR2,
  p_activated_flag  in VARCHAR2,
  p_name            in varchar2,
  p_desc            in varchar2,
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
  l_date  date;
  l_created_by number;
  l_login number;
  l_count pls_integer;
  l_id number;
  l_rowid varchar2(30);
begin

  -- Check params
  if(p_desc is null OR p_name is NULL) then
    goto error_found;
  end if;


  --prepare data, then insert new def
  select cs_kb_used_sum_defs_s.nextval into l_id from dual;
  l_date := sysdate;
  l_created_by := fnd_global.user_id;
  l_login := fnd_global.login_id;

  CS_KB_USED_SUM_DEFS_PKG.Insert_Row(
    X_Rowid => l_rowid,
    X_Def_Id => l_id,
    X_days => p_days,
    X_Default_Flag => p_default_flag,
    X_Activated_Flag => p_activated_flag,
    X_Name => p_name,
    X_Description => p_desc,
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
end Create_Used_Sum_Def;



-- Update Used_Sum_Def data
--
FUNCTION Update_Used_Sum_Def(
  p_def_id 	    in number,
  p_days            in NUMBER,
  p_default_flag    in VARCHAR2,
  p_activated_flag  in VARCHAR2,
  p_name            in varchar2,
  p_desc            in varchar2,
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
  if(p_def_id is null) then
    goto error_found;
  end if;

  --prepare data, then insert
  l_date := sysdate;
  l_updated_by := fnd_global.user_id;
  l_login := fnd_global.login_id;

  CS_KB_USED_SUM_DEFS_PKG.Update_Row(
    X_def_Id => p_def_id,
    X_days => p_days,
    X_Default_Flag => p_default_flag,
    X_Activated_Flag => p_activated_flag,
    X_Name => p_name,
    X_Description => p_desc,
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
end Update_Used_Sum_Def;

--
-- Delete

FUNCTION Delete_Used_Sum_Def(
  p_def_id in number
) return number is
  l_ret number;
  l_count pls_integer;
begin
  if p_def_id is null or p_def_id <= 0 then return ERROR_STATUS; end if;

  select count(*) into l_count
    from cs_kb_used_sum_defs_b
    where def_id = p_def_id;
  if(l_count <= 0) then return ERROR_STATUS; end if;

  CS_KB_USED_SUM_DEFS_PKG.Delete_Row(
    X_Def_Id => p_def_id);

   return OKAY_STATUS;
  <<error_found>>
  return ERROR_STATUS;

exception
  WHEN OTHERS THEN
    return ERROR_STATUS;
end Delete_Used_Sum_Def;


procedure INSERT_ROW (
  X_ROWID in OUT NOCOPY VARCHAR2,
  X_DEF_ID in NUMBER,
  X_DAYS in NUMBER,
  X_DEFAULT_FLAG in VARCHAR2,
  X_ACTIVATED_FLAG in VARCHAR2,
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
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from CS_KB_USED_SUM_DEFS_B
    where DEF_ID = X_DEF_ID
    ;
begin
  insert into CS_KB_USED_SUM_DEFS_B (
    DEF_ID,
    DAYS,
    DEFAULT_FLAG,
    ACTIVATED_FLAG,
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
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_DEF_ID,
    X_DAYS,
    X_DEFAULT_FLAG,
    X_ACTIVATED_FLAG,
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
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into CS_KB_USED_SUM_DEFS_TL (
    DEF_ID,
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
    X_DEF_ID,
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
    from CS_KB_USED_SUM_DEFS_TL T
    where T.DEF_ID = X_DEF_ID
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
  X_DEF_ID in NUMBER,
  X_DAYS in NUMBER,
  X_DEFAULT_FLAG in VARCHAR2,
  X_ACTIVATED_FLAG in VARCHAR2,
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
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      DAYS,
      DEFAULT_FLAG,
      ACTIVATED_FLAG,
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
    from CS_KB_USED_SUM_DEFS_B
    where DEF_ID = X_DEF_ID
    for update of DEF_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from CS_KB_USED_SUM_DEFS_TL
    where DEF_ID = X_DEF_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of DEF_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.DAYS = X_DAYS)
           OR ((recinfo.DAYS is null) AND (X_DAYS is null)))
      AND ((recinfo.DEFAULT_FLAG = X_DEFAULT_FLAG)
           OR ((recinfo.DEFAULT_FLAG is null) AND (X_DEFAULT_FLAG is null)))
      AND ((recinfo.ACTIVATED_FLAG = X_ACTIVATED_FLAG)
           OR ((recinfo.ACTIVATED_FLAG is null) AND (X_ACTIVATED_FLAG is null)))
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
  X_DEF_ID in NUMBER,
  X_DAYS in NUMBER,
  X_DEFAULT_FLAG in VARCHAR2,
  X_ACTIVATED_FLAG in VARCHAR2,
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
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update CS_KB_USED_SUM_DEFS_B set
    DAYS = X_DAYS,
    DEFAULT_FLAG = X_DEFAULT_FLAG,
    ACTIVATED_FLAG = X_ACTIVATED_FLAG,
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
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where DEF_ID = X_DEF_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update CS_KB_USED_SUM_DEFS_TL set
    NAME = X_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where DEF_ID = X_DEF_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_DEF_ID in NUMBER
) is
begin
  delete from CS_KB_USED_SUM_DEFS_TL
  where DEF_ID = X_DEF_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from CS_KB_USED_SUM_DEFS_B
  where DEF_ID = X_DEF_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from CS_KB_USED_SUM_DEFS_TL T
  where not exists
    (select NULL
    from CS_KB_USED_SUM_DEFS_B B
    where B.DEF_ID = T.DEF_ID
    );

  update CS_KB_USED_SUM_DEFS_TL T set (
      NAME,
      DESCRIPTION
    ) = (select
      B.NAME,
      B.DESCRIPTION
    from CS_KB_USED_SUM_DEFS_TL B
    where B.DEF_ID = T.DEF_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.DEF_ID,
      T.LANGUAGE
  ) in (select
      SUBT.DEF_ID,
      SUBT.LANGUAGE
    from CS_KB_USED_SUM_DEFS_TL SUBB, CS_KB_USED_SUM_DEFS_TL SUBT
    where SUBB.DEF_ID = SUBT.DEF_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or (SUBB.NAME is null and SUBT.NAME is not null)
      or (SUBB.NAME is not null and SUBT.NAME is null)
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into CS_KB_USED_SUM_DEFS_TL (
    DEF_ID,
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
    B.DEF_ID,
    B.NAME,
    B.DESCRIPTION,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from CS_KB_USED_SUM_DEFS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from CS_KB_USED_SUM_DEFS_TL T
    where T.DEF_ID = B.DEF_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

PROCEDURE TRANSLATE_ROW(
        x_def_id in number,
        x_days in number,
        x_default_flag in varchar,
        x_activated_flag in varchar,
        x_owner in varchar2,
        x_name in varchar2,
        x_description in varchar2) is

begin

    update CS_KB_USED_SUM_DEFS_TL set
            NAME = x_name,
            DESCRIPTION = x_description,
            LAST_UPDATE_DATE = sysdate,
            LAST_UPDATED_BY = decode(x_owner, 'SEED',1, 0),
            LAST_UPDATE_LOGIN = 0,
            SOURCE_LANG = userenv('LANG')

          where userenv('LANG') in (LANGUAGE,SOURCE_LANG)
          and DEF_ID = X_DEF_ID;


          if (sql%notfound) then
            raise no_data_found;
          end if;

end;

PROCEDURE LOAD_ROW(
        x_def_id in number,
        x_days in number,
        x_default_flag in varchar,
        x_activated_flag in varchar,
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

    CS_KB_USED_SUM_DEFS_PKG.Update_Row(
    X_Def_Id => x_def_id,
    X_Days => x_days,
    X_Default_Flag => x_default_flag,
    X_Activated_Flag => x_activated_flag,
    X_Attribute_Category => null,
    X_Attribute1 => null,
    X_Attribute2 => null,
    X_Attribute3 => null,
    X_Attribute4 => null,
    X_Attribute5 => null,
    X_Attribute6 => null,
    X_Attribute7 => null,
    X_Attribute8 => null,
    X_Attribute9 => null,
    X_Attribute10 => null,
    X_Attribute11 => null,
    X_Attribute12 => null,
    X_Attribute13 => null,
    X_Attribute14 => null,
    X_Attribute15 => null,
    X_Name => x_name,
    X_Description => x_description,
    X_Last_Update_Date => sysdate,
    X_Last_Updated_By => l_user_id,
    X_Last_Update_Login => 0);

     exception
      when no_data_found then
        	CS_KB_USED_SUM_DEFS_PKG.Insert_Row(
       		X_Rowid => l_rowid,
            X_Def_Id => x_def_id,
            X_Days => x_days,
            X_Default_Flag => x_default_flag,
            X_Activated_Flag => x_activated_flag,
            X_Attribute_Category => null,
            X_Attribute1 => null,
            X_Attribute2 => null,
            X_Attribute3 => null,
            X_Attribute4 => null,
            X_Attribute5 => null,
            X_Attribute6 => null,
            X_Attribute7 => null,
            X_Attribute8 => null,
            X_Attribute9 => null,
            X_Attribute10 => null,
            X_Attribute11 => null,
            X_Attribute12 => null,
            X_Attribute13 => null,
            X_Attribute14 => null,
            X_Attribute15 => null,
            X_Name => x_name,
            X_Description => x_description,
    		X_Creation_Date => sysdate,
    		X_Created_By => l_user_id,
    		X_Last_Update_Date => sysdate,
    		X_Last_Updated_By => l_user_id,
    		X_Last_Update_Login => 0);

end;


end CS_KB_USED_SUM_DEFS_PKG;

/
