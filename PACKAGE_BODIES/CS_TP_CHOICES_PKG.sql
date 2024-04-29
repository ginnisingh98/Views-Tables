--------------------------------------------------------
--  DDL for Package Body CS_TP_CHOICES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_TP_CHOICES_PKG" as
/* $Header: cstpchb.pls 115.7 2002/12/04 01:26:00 wzli noship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_CHOICE_ID in NUMBER,
  X_LOOKUP_ID in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
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
  X_SCORE in NUMBER,
  X_VALUE in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
 ,X_DEFAULT_FLAG in VARCHAR2 DEFAULT NULL
) is
  cursor C is select ROWID from CS_TP_CHOICES_B
    where CHOICE_ID = X_CHOICE_ID
    ;
begin
  insert into CS_TP_CHOICES_B (
    CHOICE_ID,
    LOOKUP_ID,
    SEQUENCE_NUMBER,
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
    SCORE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
    ,DEFAULT_CHOICE_FLAG
  ) values (
    X_CHOICE_ID,
    X_LOOKUP_ID,
    X_SEQUENCE_NUMBER,
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
    X_SCORE,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
    ,X_DEFAULT_FLAG
  );

  insert into CS_TP_CHOICES_TL (
    CHOICE_ID,
    VALUE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_CHOICE_ID,
    X_VALUE,
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
    from CS_TP_CHOICES_TL T
    where T.CHOICE_ID = X_CHOICE_ID
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
  X_CHOICE_ID in NUMBER,
  X_LOOKUP_ID in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
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
  X_SCORE in NUMBER,
  X_VALUE in VARCHAR2

  ,X_DEFAULT_FLAG in VARCHAR2 DEFAULT NULL
) is
  cursor c is select
      LOOKUP_ID,
      SEQUENCE_NUMBER,
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
      SCORE

      ,default_choice_flag
    from CS_TP_CHOICES_B
    where CHOICE_ID = X_CHOICE_ID
    for update of CHOICE_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      VALUE,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from CS_TP_CHOICES_TL
    where CHOICE_ID = X_CHOICE_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of CHOICE_ID nowait;
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
      AND ((recinfo.SEQUENCE_NUMBER = X_SEQUENCE_NUMBER)
           OR ((recinfo.SEQUENCE_NUMBER is null) AND (X_SEQUENCE_NUMBER is null)))
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
      AND ((recinfo.SCORE = X_SCORE)
           OR ((recinfo.SCORE is null) AND (X_SCORE is null)))

      AND ((recinfo.DEFAULT_CHOICE_FLAG = X_DEFAULT_FLAG)
	   OR ((recinfo.DEFAULT_CHOICE_FLAG is null) AND (X_DEFAULT_FLAG is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.VALUE = X_VALUE)
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
  X_CHOICE_ID in NUMBER,
  X_LOOKUP_ID in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
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
  X_SCORE in NUMBER,
  X_VALUE in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER

  ,X_DEFAULT_FLAG in VARCHAR2 DEFAULT NULL
) is
begin
  update CS_TP_CHOICES_B set
    LOOKUP_ID = X_LOOKUP_ID,
    SEQUENCE_NUMBER = X_SEQUENCE_NUMBER,
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
    SCORE = X_SCORE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN

    ,DEFAULT_CHOICE_FLAG = X_DEFAULT_FLAG
  where CHOICE_ID = X_CHOICE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update CS_TP_CHOICES_TL set
    VALUE = X_VALUE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where CHOICE_ID = X_CHOICE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_CHOICE_ID in NUMBER
) is
begin
  delete from CS_TP_CHOICES_TL
  where CHOICE_ID = X_CHOICE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from CS_TP_CHOICES_B
  where CHOICE_ID = X_CHOICE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from CS_TP_CHOICES_TL T
  where not exists
    (select NULL
    from CS_TP_CHOICES_B B
    where B.CHOICE_ID = T.CHOICE_ID
    );

  update CS_TP_CHOICES_TL T set (
      VALUE
    ) = (select
      B.VALUE
    from CS_TP_CHOICES_TL B
    where B.CHOICE_ID = T.CHOICE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.CHOICE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.CHOICE_ID,
      SUBT.LANGUAGE
    from CS_TP_CHOICES_TL SUBB, CS_TP_CHOICES_TL SUBT
    where SUBB.CHOICE_ID = SUBT.CHOICE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.VALUE <> SUBT.VALUE
  ));

  insert into CS_TP_CHOICES_TL (
    CHOICE_ID,
    VALUE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.CHOICE_ID,
    B.VALUE,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from CS_TP_CHOICES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from CS_TP_CHOICES_TL T
    where T.CHOICE_ID = B.CHOICE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;


PROCEDURE LOAD_ROW(
        x_choice_id in number,
        x_owner in varchar2,
        x_value in varchar2,
        x_lookup_id in number,
        x_sequence_number in number,
        x_start_date_active in date,
        x_end_date_active in date,
        x_score in number ) is

       l_user_id number;
       l_rowid varchar(30);
       l_value varchar(240);
begin

     if (x_owner = 'SEED') then
            l_user_id := 1;
     else
            l_user_id := 0;
     end if;

     l_value := x_value;

     CS_TP_CHOICES_PKG.Update_Row(
     X_CHOICE_ID => x_choice_id,
     X_LOOKUP_ID => x_lookup_id,
     X_SEQUENCE_NUMBER => x_sequence_number,
     X_START_DATE_ACTIVE => x_start_date_active,
     X_END_DATE_ACTIVE => x_end_date_active,
     x_score => x_score,
     x_value => l_value,
     X_Last_Update_Date => sysdate,
     X_Last_Updated_By => l_user_id,
     X_Last_Update_Login => 0);

     exception
      when no_data_found then
            CS_TP_CHOICES_PKG.Insert_Row(
             X_ROWID => l_rowid,
             X_CHOICE_ID => x_choice_id,
             X_LOOKUP_ID => x_lookup_id,
             X_SEQUENCE_NUMBER => x_sequence_number,
             X_START_DATE_ACTIVE => x_start_date_active,
             X_END_DATE_ACTIVE => x_end_date_active,
             X_SCORE => x_score,
             X_VALUE => l_value,
             X_CREATION_DATE => sysdate,
             X_CREATED_BY => 0,
             X_Last_Update_Date => sysdate,
             X_Last_Updated_By => l_user_id,
             X_Last_Update_Login => 0);


end;


PROCEDURE TRANSLATE_ROW(
        x_choice_id in number,
    	x_owner in varchar2,
        x_value in varchar2) is

begin

     update CS_TP_CHOICES_TL set
	last_update_date  = sysdate,
        last_updated_by   = decode(X_OWNER, 'SEED', 1, 0),
        last_update_login = 0,
        source_lang       = userenv('LANG')
      where CHOICE_ID = to_number(X_CHOICE_ID)
      and userenv('LANG') in (language, source_lang);

      exception
       when no_data_found then null;

end;

end CS_TP_CHOICES_PKG;

/
