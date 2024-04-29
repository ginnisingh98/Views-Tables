--------------------------------------------------------
--  DDL for Package Body CS_KB_HISTORIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_KB_HISTORIES_PKG" AS
/* $Header: cskbhib.pls 115.10 2002/12/02 21:57:35 mkettle ship $ */


FUNCTION Create_History(
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

  --prepare data, then insert new def
  select cs_kb_histories_s.nextval into l_id from dual;
  l_date := sysdate;
  l_created_by := fnd_global.user_id;
  l_login := fnd_global.login_id;

  CS_KB_HISTORIES_PKG.Insert_Row(
    X_Rowid => l_rowid,
    X_History_Id => l_id,
    X_history_name => null,
    X_user_id => l_created_by,
    X_entry_date => sysdate,
    X_name => p_name,
    X_description => p_desc,
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

end Create_History;



--
-- Delete

FUNCTION Delete_History(
  p_history_id in number
) return number is
  l_ret number;
  l_count pls_integer;
begin
  if p_history_id is null or p_history_id <= 0 then return ERROR_STATUS; end if;

  select count(*) into l_count
    from cs_kb_histories_b
    where history_id = p_history_id;
  if(l_count <= 0) then return ERROR_STATUS; end if;

  CS_KB_HISTORIES_PKG.Delete_Row(
    X_History_Id => p_history_id);

   return OKAY_STATUS;
  <<error_found>>
  return ERROR_STATUS;

exception
  WHEN OTHERS THEN
    return ERROR_STATUS;
end Delete_History;



procedure INSERT_ROW (
  X_ROWID in OUT NOCOPY VARCHAR2,
  X_HISTORY_ID in NUMBER,
  X_HISTORY_NAME in VARCHAR2,
  X_USER_ID in NUMBER,
  X_ENTRY_DATE in DATE,
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
  X_ATTRIBUTE15 in VARCHAR2
) is
  cursor C is select ROWID from CS_KB_HISTORIES_B
    where HISTORY_ID = X_HISTORY_ID
    ;
begin
  insert into CS_KB_HISTORIES_B (
    HISTORY_ID,
    HISTORY_NAME,
    USER_ID,
    ENTRY_DATE,
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
    X_HISTORY_ID,
    X_HISTORY_NAME,
    X_USER_ID,
    X_ENTRY_DATE,
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

  insert into CS_KB_HISTORIES_TL (
    HISTORY_ID,
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
    X_HISTORY_ID,
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
    from CS_KB_HISTORIES_TL T
    where T.HISTORY_ID = X_HISTORY_ID
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
  X_HISTORY_ID in NUMBER,
  X_HISTORY_NAME in VARCHAR2,
  X_USER_ID in NUMBER,
  X_ENTRY_DATE in DATE,
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
  X_ATTRIBUTE15 in VARCHAR2
) is
  cursor c is select
      HISTORY_ID,
      HISTORY_NAME,
      USER_ID,
      ENTRY_DATE,
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
    from CS_KB_HISTORIES_B
    where HISTORY_ID = X_HISTORY_ID
    for update of HISTORY_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from CS_KB_HISTORIES_TL
    where HISTORY_ID = X_HISTORY_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of HISTORY_ID nowait;
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
          ((recinfo.HISTORY_ID = X_HISTORY_ID)
           OR ((recinfo.HISTORY_ID is null) AND (X_HISTORY_ID is null)))
      AND ((recinfo.HISTORY_NAME = X_HISTORY_NAME)
           OR ((recinfo.HISTORY_NAME is null) AND (X_HISTORY_NAME is null)))
      AND ((recinfo.USER_ID = X_USER_ID)
           OR ((recinfo.USER_ID is null) AND (X_USER_ID is null)))
      AND ((recinfo.ENTRY_DATE = X_ENTRY_DATE)
           OR ((recinfo.ENTRY_DATE is null) AND (X_ENTRY_DATE is null)))
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
  X_HISTORY_ID in NUMBER,
  X_HISTORY_NAME in VARCHAR2,
  X_USER_ID in NUMBER,
  X_ENTRY_DATE in DATE,
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
  X_ATTRIBUTE15 in VARCHAR2
) is
begin
  update CS_KB_HISTORIES_B set
    HISTORY_NAME = X_HISTORY_NAME,
    USER_ID = X_USER_ID,
    ENTRY_DATE = X_ENTRY_DATE,
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
    ATTRIBUTE15 = X_ATTRIBUTE15
  where HISTORY_ID = X_HISTORY_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update CS_KB_HISTORIES_TL set
    NAME = X_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where HISTORY_ID = X_HISTORY_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_HISTORY_ID in NUMBER
) is
begin
  delete from CS_KB_HISTORIES_TL
  where HISTORY_ID = X_HISTORY_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from CS_KB_HISTORIES_B
  where HISTORY_ID = X_HISTORY_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from CS_KB_HISTORIES_TL T
  where not exists
    (select NULL
    from CS_KB_HISTORIES_B B
    where B.HISTORY_ID = T.HISTORY_ID
    );

  update CS_KB_HISTORIES_TL T set (
      NAME,
      DESCRIPTION
    ) = (select
      B.NAME,
      B.DESCRIPTION
    from CS_KB_HISTORIES_TL B
    where B.HISTORY_ID = T.HISTORY_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.HISTORY_ID,
      T.LANGUAGE
  ) in (select
      SUBT.HISTORY_ID,
      SUBT.LANGUAGE
    from CS_KB_HISTORIES_TL SUBB, CS_KB_HISTORIES_TL SUBT
    where SUBB.HISTORY_ID = SUBT.HISTORY_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or (SUBB.NAME is null and SUBT.NAME is not null)
      or (SUBB.NAME is not null and SUBT.NAME is null)
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into CS_KB_HISTORIES_TL (
    HISTORY_ID,
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
    B.HISTORY_ID,
    B.NAME,
    B.DESCRIPTION,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from CS_KB_HISTORIES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from CS_KB_HISTORIES_TL T
    where T.HISTORY_ID = B.HISTORY_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure TRANSLATE_ROW (
     X_HISTORY_ID		  	in 	VARCHAR2,
     X_NAME	 			in	VARCHAR2,
     X_DESCRIPTION 	 		in   	VARCHAR2,
     X_OWNER				in	VARCHAR2
) is
begin
     update CS_KB_HISTORIES_TL set
	NAME = X_NAME,
	DESCRIPTION=X_DESCRIPTION,
	last_update_date  = sysdate,
     last_updated_by   = decode(X_OWNER, 'SEED', 1, 0),
     last_update_login = 0,
     source_lang       = userenv('LANG')
      where HISTORY_ID = to_number(X_HISTORY_ID)
      and userenv('LANG') in (language, source_lang);
end TRANSLATE_ROW;

end CS_KB_HISTORIES_PKG;

/
