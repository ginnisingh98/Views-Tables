--------------------------------------------------------
--  DDL for Package Body CS_TP_TEMPLATES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_TP_TEMPLATES_PKG" as
/* $Header: cstptemb.pls 115.9 2002/12/04 18:52:53 wzli noship $ */
/*==========================================================================+
 |  Copyright (c) 1997 Oracle Corporation Redwood Shores, California, USA   |
 |                            All rights reserved.                          |
 +==========================================================================+
 | FILENAME                                                                 |
 | DESCRIPTION                                                              |
 |   PL/SQL body for package:  CS_TP_TEMPLATES_PKG                          |
 |                                                                          |
 | HISTORY                                                                  |
 |   03-11-2002   Adding two new column: UNI_QUESTION_NOTE_FLAG,            |
 |                                       UNI_QUESTION_NOTE_TYPE             |
 |   12-APR-2002 KLOU                                                       |
 |              1. Modify Update_Row to check fnd_api.g_miss_XXX and null   |
 |                 when updating the table.                                 |
 |   15-MAY-2002 KLOU                                                       |
 |              1. Modify Insert_Row to null into uni_question_note_flag    |
 |                 and uni_question_note_type if they are                   |
 |                 fnd_api.g_miss_char.                                     |
 |  115.9   03-DEC-2002 WZLI changed OUT and IN OUT calls to use NOCOPY hint|
 |                           to enable pass by reference.                   |
 |                                                                          |
 +==========================================================================*/
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_TEMPLATE_ID in NUMBER,
  X_DEFAULT_FLAG in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
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

  X_UNI_QUESTION_NOTE_FLAG in VARCHAR2 DEFAULT NULL,
  X_UNI_QUESTION_NOTE_TYPE in VARCHAR2 DEFAULT NULL,

  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from CS_TP_TEMPLATES_B
    where TEMPLATE_ID = X_TEMPLATE_ID
    ;
begin
  insert into CS_TP_TEMPLATES_B (
    TEMPLATE_ID,
    DEFAULT_FLAG,
    START_DATE_ACTIVE,
    END_DATE_ACTIVE,
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

    UNI_QUESTION_NOTE_FLAG ,
    UNI_QUESTION_NOTE_TYPE ,

    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_TEMPLATE_ID,
    X_DEFAULT_FLAG,
    X_START_DATE_ACTIVE,
    X_END_DATE_ACTIVE,
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
    decode(X_UNI_QUESTION_NOTE_FLAG, fnd_api.g_miss_char, null, X_UNI_QUESTION_NOTE_FLAG),
    decode(X_UNI_QUESTION_NOTE_TYPE, fnd_api.g_miss_char, null, X_UNI_QUESTION_NOTE_TYPE),
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into CS_TP_TEMPLATES_TL (
    TEMPLATE_ID,
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
    X_TEMPLATE_ID,
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
    from CS_TP_TEMPLATES_TL T
    where T.TEMPLATE_ID = X_TEMPLATE_ID
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
  X_TEMPLATE_ID in NUMBER,
  X_DEFAULT_FLAG in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
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

  X_UNI_QUESTION_NOTE_FLAG in VARCHAR2 DEFAULT NULL,
  X_UNI_QUESTION_NOTE_TYPE in VARCHAR2 DEFAULT NULL,

  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      DEFAULT_FLAG,
      START_DATE_ACTIVE,
      END_DATE_ACTIVE,
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

      UNI_QUESTION_NOTE_FLAG ,
	 UNI_QUESTION_NOTE_TYPE

    from CS_TP_TEMPLATES_B
    where TEMPLATE_ID = X_TEMPLATE_ID
    for update of TEMPLATE_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from CS_TP_TEMPLATES_TL
    where TEMPLATE_ID = X_TEMPLATE_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of TEMPLATE_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.DEFAULT_FLAG = X_DEFAULT_FLAG)
           OR ((recinfo.DEFAULT_FLAG is null) AND (X_DEFAULT_FLAG is null)))
      AND ((recinfo.START_DATE_ACTIVE = X_START_DATE_ACTIVE)
           OR ((recinfo.START_DATE_ACTIVE is null) AND (X_START_DATE_ACTIVE is null)))
      AND ((recinfo.END_DATE_ACTIVE = X_END_DATE_ACTIVE)
           OR ((recinfo.END_DATE_ACTIVE is null) AND (X_END_DATE_ACTIVE is null)))
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

      AND ((recinfo.UNI_QUESTION_NOTE_FLAG = X_UNI_QUESTION_NOTE_FLAG)
		 OR ((recinfo.UNI_QUESTION_NOTE_FLAG is null) AND (X_UNI_QUESTION_NOTE_FLAG is null)))
	 AND ((recinfo.UNI_QUESTION_NOTE_TYPE = X_UNI_QUESTION_NOTE_TYPE)
		 OR ((recinfo.UNI_QUESTION_NOTE_TYPE is null) AND (X_UNI_QUESTION_NOTE_TYPE is null)))


  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.NAME = X_NAME)
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
  X_TEMPLATE_ID in NUMBER,
  X_DEFAULT_FLAG in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
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

  X_UNI_QUESTION_NOTE_FLAG in VARCHAR2 DEFAULT NULL,
  X_UNI_QUESTION_NOTE_TYPE in VARCHAR2 DEFAULT NULL,

  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
/*
  update CS_TP_TEMPLATES_B set
    DEFAULT_FLAG = X_DEFAULT_FLAG,
    START_DATE_ACTIVE = X_START_DATE_ACTIVE,
    END_DATE_ACTIVE = X_END_DATE_ACTIVE,
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
    UNI_QUESTION_NOTE_FLAG = X_UNI_QUESTION_NOTE_FLAG,
    UNI_QUESTION_NOTE_TYPE = X_UNI_QUESTION_NOTE_TYPE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where TEMPLATE_ID = X_TEMPLATE_ID;
*/
Update CS_TP_TEMPLATES_B set
DEFAULT_FLAG       = DECODE(NVL(X_DEFAULT_FLAG,FND_API.G_MISS_CHAR),
                            FND_API.G_MISS_CHAR, DEFAULT_FLAG, X_DEFAULT_FLAG),
START_DATE_ACTIVE  = DECODE(NVL(X_START_DATE_ACTIVE, FND_API.G_MISS_DATE),
                            FND_API.G_MISS_DATE, START_DATE_ACTIVE, X_START_DATE_ACTIVE),
END_DATE_ACTIVE    = DECODE(NVL(X_END_DATE_ACTIVE, FND_API.G_MISS_DATE),
                            FND_API.G_MISS_DATE,  END_DATE_ACTIVE, X_END_DATE_ACTIVE),
ATTRIBUTE_CATEGORY = DECODE(NVL(X_ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR),
                            FND_API.G_MISS_CHAR, ATTRIBUTE_CATEGORY, X_ATTRIBUTE_CATEGORY),
ATTRIBUTE1  = DECODE(NVL(X_ATTRIBUTE1,  FND_API.G_MISS_CHAR),
                    FND_API.G_MISS_CHAR, ATTRIBUTE1, X_ATTRIBUTE1 ),
ATTRIBUTE2  = DECODE(NVL(X_ATTRIBUTE2,  FND_API.G_MISS_CHAR),
                    FND_API.G_MISS_CHAR, ATTRIBUTE2, X_ATTRIBUTE2 ),
ATTRIBUTE3  = DECODE(NVL(X_ATTRIBUTE3,  FND_API.G_MISS_CHAR),
                    FND_API.G_MISS_CHAR, ATTRIBUTE3, X_ATTRIBUTE3 ),
ATTRIBUTE4  = DECODE(NVL(X_ATTRIBUTE4,  FND_API.G_MISS_CHAR),
                    FND_API.G_MISS_CHAR, ATTRIBUTE4, X_ATTRIBUTE4 ),
ATTRIBUTE5  = DECODE(NVL(X_ATTRIBUTE5,  FND_API.G_MISS_CHAR),
                    FND_API.G_MISS_CHAR, ATTRIBUTE5, X_ATTRIBUTE5 ),
ATTRIBUTE6  = DECODE(NVL(X_ATTRIBUTE6,  FND_API.G_MISS_CHAR),
                    FND_API.G_MISS_CHAR, ATTRIBUTE6, X_ATTRIBUTE6 ),
ATTRIBUTE7  = DECODE(NVL(X_ATTRIBUTE7,  FND_API.G_MISS_CHAR),
                    FND_API.G_MISS_CHAR, ATTRIBUTE7, X_ATTRIBUTE7 ),
ATTRIBUTE8  = DECODE(NVL(X_ATTRIBUTE8,  FND_API.G_MISS_CHAR),
                    FND_API.G_MISS_CHAR, ATTRIBUTE8, X_ATTRIBUTE8 ),
ATTRIBUTE9  = DECODE(NVL(X_ATTRIBUTE9,  FND_API.G_MISS_CHAR),
                    FND_API.G_MISS_CHAR, ATTRIBUTE9, X_ATTRIBUTE9 ),
ATTRIBUTE10 = DECODE(NVL(X_ATTRIBUTE10, FND_API.G_MISS_CHAR),
                    FND_API.G_MISS_CHAR, ATTRIBUTE10, X_ATTRIBUTE10),
ATTRIBUTE11 = DECODE(NVL(X_ATTRIBUTE11, FND_API.G_MISS_CHAR),
                     FND_API.G_MISS_CHAR, ATTRIBUTE11, X_ATTRIBUTE11),
ATTRIBUTE12 = DECODE(NVL(X_ATTRIBUTE12, FND_API.G_MISS_CHAR),
                    FND_API.G_MISS_CHAR, ATTRIBUTE12, X_ATTRIBUTE12),
ATTRIBUTE13 = DECODE(NVL(X_ATTRIBUTE13, FND_API.G_MISS_CHAR),
                     FND_API.G_MISS_CHAR, ATTRIBUTE13, X_ATTRIBUTE13),
ATTRIBUTE14 = DECODE(NVL(X_ATTRIBUTE14, FND_API.G_MISS_CHAR),
                     FND_API.G_MISS_CHAR, ATTRIBUTE14, X_ATTRIBUTE14),
ATTRIBUTE15 = DECODE(NVL(X_ATTRIBUTE15, FND_API.G_MISS_CHAR),
                     FND_API.G_MISS_CHAR, ATTRIBUTE15, X_ATTRIBUTE15),
UNI_QUESTION_NOTE_FLAG = DECODE(NVL(X_UNI_QUESTION_NOTE_FLAG, FND_API.G_MISS_CHAR),
                                    FND_API.G_MISS_CHAR, UNI_QUESTION_NOTE_FLAG,
                                    X_UNI_QUESTION_NOTE_FLAG),
UNI_QUESTION_NOTE_TYPE = DECODE(NVL(X_UNI_QUESTION_NOTE_TYPE,FND_API.G_MISS_CHAR),
                         FND_API.G_MISS_CHAR, UNI_QUESTION_NOTE_TYPE, X_UNI_QUESTION_NOTE_TYPE),
LAST_UPDATE_DATE  = DECODE(NVL(X_LAST_UPDATE_DATE, FND_API.G_MISS_DATE),
                           FND_API.G_MISS_DATE, LAST_UPDATE_DATE, X_LAST_UPDATE_DATE),
LAST_UPDATED_BY   = DECODE(NVL(X_LAST_UPDATED_BY, FND_API.G_MISS_NUM),
                           FND_API.G_MISS_NUM, LAST_UPDATED_BY, X_LAST_UPDATED_BY  ),
LAST_UPDATE_LOGIN = DECODE(NVL(X_LAST_UPDATE_LOGIN,FND_API.G_MISS_NUM),
                           FND_API.G_MISS_NUM, LAST_UPDATE_LOGIN, X_LAST_UPDATE_LOGIN)
Where TEMPLATE_ID = X_TEMPLATE_ID;

if (sql%notfound) then
    raise no_data_found;
end if;

  update CS_TP_TEMPLATES_TL set
    NAME =  decode(nvl(X_NAME, fnd_api.g_miss_char),
                   fnd_api.g_miss_char, name, x_name),
    DESCRIPTION = decode(nvl(X_DESCRIPTION, fnd_api.g_miss_char),
                   fnd_api.g_miss_char, description, x_description),
    LAST_UPDATE_DATE = decode(nvl(X_LAST_UPDATE_DATE, fnd_api.g_miss_date),
                       fnd_api.g_miss_date, last_update_date, x_last_update_date),
    LAST_UPDATED_BY = decode(nvl(X_LAST_UPDATED_BY, fnd_api.g_miss_num),
                       fnd_api.g_miss_num, last_updated_by, x_last_updated_by),
    LAST_UPDATE_LOGIN = decode(nvl(X_LAST_UPDATE_LOGIN, fnd_api.g_miss_num),
                        fnd_api.g_miss_num, last_update_login, x_last_update_login),
    SOURCE_LANG = userenv('LANG')
  where TEMPLATE_ID = X_TEMPLATE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_TEMPLATE_ID in NUMBER
) is
begin
  delete from CS_TP_TEMPLATES_TL
  where TEMPLATE_ID = X_TEMPLATE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from CS_TP_TEMPLATES_B
  where TEMPLATE_ID = X_TEMPLATE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from CS_TP_TEMPLATES_TL T
  where not exists
    (select NULL
    from CS_TP_TEMPLATES_B B
    where B.TEMPLATE_ID = T.TEMPLATE_ID
    );

  update CS_TP_TEMPLATES_TL T set (
      NAME,
      DESCRIPTION
    ) = (select
      B.NAME,
      B.DESCRIPTION
    from CS_TP_TEMPLATES_TL B
    where B.TEMPLATE_ID = T.TEMPLATE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.TEMPLATE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.TEMPLATE_ID,
      SUBT.LANGUAGE
    from CS_TP_TEMPLATES_TL SUBB, CS_TP_TEMPLATES_TL SUBT
    where SUBB.TEMPLATE_ID = SUBT.TEMPLATE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into CS_TP_TEMPLATES_TL (
    TEMPLATE_ID,
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
    B.TEMPLATE_ID,
    B.NAME,
    B.DESCRIPTION,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from CS_TP_TEMPLATES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from CS_TP_TEMPLATES_TL T
    where T.TEMPLATE_ID = B.TEMPLATE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

PROCEDURE LOAD_ROW(
        x_template_id in number,
        x_owner in varchar2,
        x_name in varchar2,
        x_description in varchar2,
        x_default_flag in varchar2,
        x_start_date_active in  date,
        x_end_date_active in date ,
	   x_uni_question_note_flag in varchar2,
	   x_uni_question_note_type in varchar2 ) is

    l_default_flag varchar2(1);
    l_start_date_active date;
    l_end_date_active date;
    l_user_id number;
    l_rowid varchar(30);

begin

     if (x_owner = 'SEED') then
           l_user_id := 1;
     else
           l_user_id := 0;
     end if;

     l_default_flag := x_default_flag;
     l_start_date_active := x_start_date_active;
     l_end_date_active := x_end_date_active;

     CS_TP_TEMPLATES_PKG.Update_Row(
     X_TEMPLATE_ID  => x_template_id,
     X_DEFAULT_FLAG => l_default_flag,
     X_START_DATE_ACTIVE => l_start_date_active ,
     X_END_DATE_ACTIVE => l_end_date_active,
     X_Name => x_name,
     X_Description => x_description,
     X_Last_Update_Date => sysdate,
     X_Last_Updated_By => l_user_id,
     X_Last_Update_Login => 0,
	X_UNI_QUESTION_NOTE_FLAG => X_UNI_QUESTION_NOTE_FLAG,
	X_UNI_QUESTION_NOTE_TYPE => X_UNI_QUESTION_NOTE_TYPE );

     exception
      when no_data_found then
             CS_TP_TEMPLATES_PKG.Insert_Row(
             X_Rowid => l_rowid,
             X_TEMPLATE_ID => x_template_id,
             X_DEFAULT_FLAG => l_default_flag,
             X_START_DATE_ACTIVE => l_start_date_active,
             X_END_DATE_ACTIVE => l_end_date_active,
             X_NAME => x_name,
             X_DESCRIPTION => x_description,
             X_CREATION_DATE => sysdate,
             X_CREATED_BY => l_user_id,
             X_LAST_UPDATE_DATE => sysdate,
             X_LAST_UPDATED_BY => l_user_id,
             X_LAST_UPDATE_LOGIN => 0 ,
		   X_UNI_QUESTION_NOTE_FLAG => X_UNI_QUESTION_NOTE_FLAG,
		   X_UNI_QUESTION_NOTE_TYPE => X_UNI_QUESTION_NOTE_TYPE
            );

end;

PROCEDURE TRANSLATE_ROW(
        x_template_id in number,
    	x_owner in varchar2,
        x_name in varchar2,
        x_description in varchar2) is

    l_name varchar2(500) := null;
    l_description varchar2(30) := null;

begin

     l_name := x_name;
     l_description := x_description;

   -- Update translated  portions for specified language
     update CS_TP_TEMPLATES_TL set
        name = l_name,
        description = l_description,
	last_update_date  = sysdate,
        last_updated_by   = decode(X_OWNER, 'SEED', 1, 0),
        last_update_login = 0,
        source_lang       = userenv('LANG')
      where TEMPLATE_ID = to_number(X_TEMPLATE_ID)
      and userenv('LANG') in (language, source_lang);

     exception
      when no_data_found then null;

end;

end CS_TP_TEMPLATES_PKG;

/
