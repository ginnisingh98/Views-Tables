--------------------------------------------------------
--  DDL for Package Body CS_TP_QUESTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_TP_QUESTIONS_PKG" as
/* $Header: cstpqueb.pls 115.8 2002/12/04 18:15:32 wzli noship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_QUESTION_ID in NUMBER,
  X_LOOKUP_ID in NUMBER,
  X_MANDTORY_FLAG in VARCHAR2,
  X_SCORING_FLAG in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE1 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE2 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE3 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE4 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE5 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE6 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE7 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE8 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE9 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE10 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE11 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE12 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE13 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE14 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE15 in VARCHAR2 DEFAULT NULL,

  X_NOTE_TYPE in VARCHAR2 DEFAULT NULL,
  X_SHOW_ON_CREATION_FLAG in VARCHAR2 DEFAULT NULL,

  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_NAME in VARCHAR2,
  X_TEXT in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from CS_TP_QUESTIONS_B
    where QUESTION_ID = X_QUESTION_ID
    ;
begin
  insert into CS_TP_QUESTIONS_B (
    QUESTION_ID,
    LOOKUP_ID,
    MANDTORY_FLAG,
    SCORING_FLAG,
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
    END_DATE_ACTIVE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,

    NOTE_TYPE                 ,
    SHOW_ON_CREATION_FLAG

  ) values (
    X_QUESTION_ID,
    X_LOOKUP_ID,
    X_MANDTORY_FLAG,
    X_SCORING_FLAG,
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
    X_START_DATE_ACTIVE,
    X_END_DATE_ACTIVE,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,

    X_NOTE_TYPE               ,
    X_SHOW_ON_CREATION_FLAG
  );

  insert into CS_TP_QUESTIONS_TL (
    QUESTION_ID,
    NAME,
    TEXT,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_QUESTION_ID,
    X_NAME,
    X_TEXT,
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
    from CS_TP_QUESTIONS_TL T
    where T.QUESTION_ID = X_QUESTION_ID
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
  X_QUESTION_ID in NUMBER,
  X_LOOKUP_ID in NUMBER,
  X_MANDTORY_FLAG in VARCHAR2,
  X_SCORING_FLAG in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE1 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE2 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE3 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE4 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE5 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE6 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE7 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE8 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE9 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE10 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE11 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE12 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE13 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE14 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE15 in VARCHAR2 DEFAULT NULL,

  X_NOTE_TYPE in VARCHAR2 DEFAULT NULL,
  X_SHOW_ON_CREATION_FLAG in VARCHAR2 DEFAULT NULL,

  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_NAME in VARCHAR2,
  X_TEXT in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      LOOKUP_ID,
      MANDTORY_FLAG,
      SCORING_FLAG,
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

	 NOTE_TYPE,
	 SHOW_ON_CREATION_FLAG,

      START_DATE_ACTIVE,
      END_DATE_ACTIVE
    from CS_TP_QUESTIONS_B
    where QUESTION_ID = X_QUESTION_ID
    for update of QUESTION_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      NAME,
      TEXT,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from CS_TP_QUESTIONS_TL
    where QUESTION_ID = X_QUESTION_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of QUESTION_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.LOOKUP_ID = X_LOOKUP_ID)
      AND ((recinfo.MANDTORY_FLAG = X_MANDTORY_FLAG)
           OR ((recinfo.MANDTORY_FLAG is null) AND (X_MANDTORY_FLAG is null)))
      AND ((recinfo.SCORING_FLAG = X_SCORING_FLAG)
           OR ((recinfo.SCORING_FLAG is null) AND (X_SCORING_FLAG is null)))
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
      AND ((recinfo.START_DATE_ACTIVE = X_START_DATE_ACTIVE)
           OR ((recinfo.START_DATE_ACTIVE is null) AND (X_START_DATE_ACTIVE is null)))
      AND ((recinfo.END_DATE_ACTIVE = X_END_DATE_ACTIVE)
           OR ((recinfo.END_DATE_ACTIVE is null) AND (X_END_DATE_ACTIVE is null)))

      AND ((recinfo.NOTE_TYPE = X_NOTE_TYPE)
           OR ((recinfo.NOTE_TYPE is null) AND (X_NOTE_TYPE is null)))
	 AND ((recinfo.SHOW_ON_CREATION_FLAG = X_SHOW_ON_CREATION_FLAG)
           OR ((recinfo.SHOW_ON_CREATION_FLAG is null) AND (X_SHOW_ON_CREATION_FLAG is null)))

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
          AND (tlinfo.TEXT = X_TEXT)
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
  X_QUESTION_ID in NUMBER,
  X_LOOKUP_ID in NUMBER,
  X_MANDTORY_FLAG in VARCHAR2,
  X_SCORING_FLAG in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE1 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE2 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE3 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE4 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE5 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE6 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE7 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE8 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE9 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE10 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE11 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE12 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE13 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE14 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE15 in VARCHAR2 DEFAULT NULL,

  X_NOTE_TYPE in VARCHAR2 DEFAULT NULL,
  X_SHOW_ON_CREATION_FLAG in VARCHAR2 DEFAULT NULL,

  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_NAME in VARCHAR2,
  X_TEXT in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update CS_TP_QUESTIONS_B set
    lookup_id     = decode(nvl(x_lookup_id,fnd_api.g_miss_num), fnd_api.g_miss_num, lookup_id, x_lookup_id),
    mandtory_flag = decode(nvl(x_mandtory_flag, fnd_api.g_miss_char), fnd_api.g_miss_char , mandtory_flag, x_mandtory_flag),
    scoring_flag  = decode(nvl(x_scoring_flag,fnd_api.g_miss_char), fnd_api.g_miss_char ,  scoring_flag, x_scoring_flag),
    attribute_category = decode(nvl(x_attribute_category,fnd_api.g_miss_char),
                   fnd_api.g_miss_char, attribute_category, x_attribute_category),
    attribute1  = decode(nvl(x_attribute1, fnd_api.g_miss_char), fnd_api.g_miss_char, attribute1 , x_attribute1 ),
    attribute2  = decode(nvl(x_attribute2, fnd_api.g_miss_char), fnd_api.g_miss_char, attribute2 , x_attribute2 ),
    attribute3  = decode(nvl(x_attribute3, fnd_api.g_miss_char), fnd_api.g_miss_char, attribute3 , x_attribute3 ),
    attribute4  = decode(nvl(x_attribute4, fnd_api.g_miss_char), fnd_api.g_miss_char, attribute4 , x_attribute4 ),
    attribute5  = decode(nvl(x_attribute5, fnd_api.g_miss_char), fnd_api.g_miss_char, attribute5 , x_attribute5 ),
    attribute6  = decode(nvl(x_attribute6, fnd_api.g_miss_char), fnd_api.g_miss_char, attribute6 , x_attribute6 ),
    attribute7  = decode(nvl(x_attribute7, fnd_api.g_miss_char), fnd_api.g_miss_char, attribute7 , x_attribute7 ),
    attribute8  = decode(nvl(x_attribute8, fnd_api.g_miss_char), fnd_api.g_miss_char, attribute8 , x_attribute8 ),
    attribute9  = decode(nvl(x_attribute9, fnd_api.g_miss_char), fnd_api.g_miss_char, attribute9 , x_attribute9 ),
    attribute10 = decode(nvl(x_attribute10,fnd_api.g_miss_char), fnd_api.g_miss_char, attribute10, x_attribute10),
    attribute11 = decode(nvl(x_attribute11,fnd_api.g_miss_char), fnd_api.g_miss_char, attribute11, x_attribute11),
    attribute12 = decode(nvl(x_attribute12,fnd_api.g_miss_char), fnd_api.g_miss_char, attribute12, x_attribute12),
    attribute13 = decode(nvl(x_attribute13,fnd_api.g_miss_char), fnd_api.g_miss_char, attribute13, x_attribute13),
    attribute14 = decode(nvl(x_attribute14,fnd_api.g_miss_char), fnd_api.g_miss_char, attribute14, x_attribute14),
    attribute15 = decode(nvl(x_attribute15,fnd_api.g_miss_char), fnd_api.g_miss_char, attribute15, x_attribute15),
    note_type   = decode(nvl(x_note_type, fnd_api.g_miss_char), fnd_api.g_miss_char, note_type, x_note_type),
    show_on_creation_flag = decode(nvl(x_show_on_creation_flag, fnd_api.g_miss_char), fnd_api.g_miss_char,
                            show_on_creation_flag, x_show_on_creation_flag),
    start_date_active     = decode(nvl(x_start_date_active, fnd_api.g_miss_date), fnd_api.g_miss_date,
                            start_date_active, x_start_date_active),
    end_date_active       = decode(nvl(x_end_date_active, fnd_api.g_miss_date), fnd_api.g_miss_date,
                            end_date_active, x_end_date_active),
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where QUESTION_ID = X_QUESTION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update CS_TP_QUESTIONS_TL set
    name = decode(nvl(x_name, fnd_api.g_miss_char), fnd_api.g_miss_char, name,x_name),
    text = decode(nvl(x_text, fnd_api.g_miss_char), fnd_api.g_miss_char, text,x_text),
    description = decode(nvl(x_description, fnd_api.g_miss_char), fnd_api.g_miss_char,description, x_description),
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where QUESTION_ID = X_QUESTION_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_QUESTION_ID in NUMBER
) is
begin
  delete from CS_TP_QUESTIONS_TL
  where QUESTION_ID = X_QUESTION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from CS_TP_QUESTIONS_B
  where QUESTION_ID = X_QUESTION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from CS_TP_QUESTIONS_TL T
  where not exists
    (select NULL
    from CS_TP_QUESTIONS_B B
    where B.QUESTION_ID = T.QUESTION_ID
    );

  update CS_TP_QUESTIONS_TL T set (
      NAME,
      TEXT,
      DESCRIPTION
    ) = (select
      B.NAME,
      B.TEXT,
      B.DESCRIPTION
    from CS_TP_QUESTIONS_TL B
    where B.QUESTION_ID = T.QUESTION_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.QUESTION_ID,
      T.LANGUAGE
  ) in (select
      SUBT.QUESTION_ID,
      SUBT.LANGUAGE
    from CS_TP_QUESTIONS_TL SUBB, CS_TP_QUESTIONS_TL SUBT
    where SUBB.QUESTION_ID = SUBT.QUESTION_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or (SUBB.NAME is null and SUBT.NAME is not null)
      or (SUBB.NAME is not null and SUBT.NAME is null)
      or SUBB.TEXT <> SUBT.TEXT
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into CS_TP_QUESTIONS_TL (
    QUESTION_ID,
    NAME,
    TEXT,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.QUESTION_ID,
    B.NAME,
    B.TEXT,
    B.DESCRIPTION,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from CS_TP_QUESTIONS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from CS_TP_QUESTIONS_TL T
    where T.QUESTION_ID = B.QUESTION_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

PROCEDURE LOAD_ROW(
        x_question_id in number,
        x_owner in varchar2,
        x_name in varchar2,
        x_text in varchar2,
        x_description in varchar2,
        x_mandatory_flag in varchar2,
        x_scoring_flag in varchar2,
        x_lookup_id in number,
        x_start_date_active in date,
        x_end_date_active in date,
	   X_NOTE_TYPE in VARCHAR2,
	   X_SHOW_ON_CREATION_FLAG in VARCHAR2 ) is

    l_mandatory_flag varchar2(1);
    l_scoring_flag varchar2(1);
    l_user_id number;
    l_rowid varchar(30);
begin

     if (x_owner = 'SEED') then
            l_user_id := 1;
     else
            l_user_id := 0;
     end if;

     l_mandatory_flag := x_mandatory_flag;
     l_scoring_flag := x_mandatory_flag;

     CS_TP_QUESTIONS_PKG.Update_Row(
     X_QUESTION_ID => x_question_id,
     X_LOOKUP_ID => x_lookup_id,
     X_MANDTORY_FLAG => l_mandatory_flag,
     X_SCORING_FLAG => l_scoring_flag,
     X_Name => x_name,
     X_Text => x_text,
     X_Description => x_description,
     x_start_date_active => x_start_date_active,
     x_end_date_active => x_end_date_active,
     X_Last_Update_Date => sysdate,
     X_Last_Updated_By => l_user_id,
     X_Last_Update_Login => 0,
	X_NOTE_TYPE => x_note_type,
	X_SHOW_ON_CREATION_FLAG => X_SHOW_ON_CREATION_FLAG );

     exception
      when no_data_found then
             CS_TP_QUESTIONS_PKG.Insert_Row(
             X_Rowid => l_rowid,
             X_QUESTION_ID => x_question_id,
             X_LOOKUP_ID => x_lookup_id,
             X_MANDTORY_FLAG => l_mandatory_flag,
             X_SCORING_FLAG => l_scoring_flag,
             X_START_DATE_ACTIVE => x_start_date_active,
             X_END_DATE_ACTIVE => x_end_date_active,
             X_NAME => x_name,
             X_Text => x_text,
             X_DESCRIPTION => x_description,
             X_CREATION_DATE => sysdate,
             X_CREATED_BY => l_user_id,
             X_LAST_UPDATE_DATE => sysdate,
             X_LAST_UPDATED_BY => l_user_id,
             X_LAST_UPDATE_LOGIN => 0,
             X_NOTE_TYPE => x_note_type,
		   X_SHOW_ON_CREATION_FLAG => X_SHOW_ON_CREATION_FLAG
            );

end;


PROCEDURE TRANSLATE_ROW(
        x_question_id in number,
    	x_owner in varchar2,
        x_name in varchar2,
        x_text in varchar2,
        x_description in varchar2) is

        l_user_id number;
        l_offset number;
        l_amt    number;
begin

     -- Update translated non-clob portions for specified language
     update CS_TP_QUESTIONS_TL set
	name = x_name,
        text = x_text,
        description = x_description,
	last_update_date  = sysdate,
        last_updated_by   = decode(X_OWNER, 'SEED', 1, 0),
        last_update_login = 0,
        source_lang       = userenv('LANG')
      where QUESTION_ID = to_number(X_QUESTION_ID)
      and userenv('LANG') in (language, source_lang);

    exception
      when no_data_found then null;

end;


end CS_TP_QUESTIONS_PKG;

/
