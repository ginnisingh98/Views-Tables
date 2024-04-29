--------------------------------------------------------
--  DDL for Package Body SO_RESULTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."SO_RESULTS_PKG" as
/* $Header: OEXRSLTB.pls 115.4 99/08/13 11:23:30 porting shi $ */
procedure INSERT_ROW (
  X_ROWID in out VARCHAR2,
  X_RESULT_ID in NUMBER,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_CONTEXT in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from SO_RESULTS_B
    where RESULT_ID = X_RESULT_ID
    ;
begin
  insert into SO_RESULTS_B (
    ATTRIBUTE10,
    ATTRIBUTE11,
    ATTRIBUTE12,
    ATTRIBUTE13,
    ATTRIBUTE14,
    ATTRIBUTE15,
    RESULT_ID,
    START_DATE_ACTIVE,
    END_DATE_ACTIVE,
    CONTEXT,
    ATTRIBUTE1,
    ATTRIBUTE2,
    ATTRIBUTE3,
    ATTRIBUTE4,
    ATTRIBUTE5,
    ATTRIBUTE6,
    ATTRIBUTE7,
    ATTRIBUTE8,
    ATTRIBUTE9,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_ATTRIBUTE10,
    X_ATTRIBUTE11,
    X_ATTRIBUTE12,
    X_ATTRIBUTE13,
    X_ATTRIBUTE14,
    X_ATTRIBUTE15,
    X_RESULT_ID,
    X_START_DATE_ACTIVE,
    X_END_DATE_ACTIVE,
    X_CONTEXT,
    X_ATTRIBUTE1,
    X_ATTRIBUTE2,
    X_ATTRIBUTE3,
    X_ATTRIBUTE4,
    X_ATTRIBUTE5,
    X_ATTRIBUTE6,
    X_ATTRIBUTE7,
    X_ATTRIBUTE8,
    X_ATTRIBUTE9,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into SO_RESULTS_TL (
    RESULT_ID,
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
    X_RESULT_ID,
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
    from SO_RESULTS_TL T
    where T.RESULT_ID = X_RESULT_ID
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
  X_RESULT_ID in NUMBER,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_CONTEXT in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      ATTRIBUTE10,
      ATTRIBUTE11,
      ATTRIBUTE12,
      ATTRIBUTE13,
      ATTRIBUTE14,
      ATTRIBUTE15,
      START_DATE_ACTIVE,
      END_DATE_ACTIVE,
      CONTEXT,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE6,
      ATTRIBUTE7,
      ATTRIBUTE8,
      ATTRIBUTE9
    from SO_RESULTS_B
    where RESULT_ID = X_RESULT_ID
    for update of RESULT_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from SO_RESULTS_TL
    where RESULT_ID = X_RESULT_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of RESULT_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.ATTRIBUTE10 = X_ATTRIBUTE10)
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
      AND ((recinfo.CONTEXT = X_CONTEXT)
           OR ((recinfo.CONTEXT is null) AND (X_CONTEXT is null)))
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
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.NAME = X_NAME)
          AND (tlinfo.DESCRIPTION = X_DESCRIPTION)
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
  X_RESULT_ID in NUMBER,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_CONTEXT in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update SO_RESULTS_B set
    ATTRIBUTE10 = X_ATTRIBUTE10,
    ATTRIBUTE11 = X_ATTRIBUTE11,
    ATTRIBUTE12 = X_ATTRIBUTE12,
    ATTRIBUTE13 = X_ATTRIBUTE13,
    ATTRIBUTE14 = X_ATTRIBUTE14,
    ATTRIBUTE15 = X_ATTRIBUTE15,
    START_DATE_ACTIVE = X_START_DATE_ACTIVE,
    END_DATE_ACTIVE = X_END_DATE_ACTIVE,
    CONTEXT = X_CONTEXT,
    ATTRIBUTE1 = X_ATTRIBUTE1,
    ATTRIBUTE2 = X_ATTRIBUTE2,
    ATTRIBUTE3 = X_ATTRIBUTE3,
    ATTRIBUTE4 = X_ATTRIBUTE4,
    ATTRIBUTE5 = X_ATTRIBUTE5,
    ATTRIBUTE6 = X_ATTRIBUTE6,
    ATTRIBUTE7 = X_ATTRIBUTE7,
    ATTRIBUTE8 = X_ATTRIBUTE8,
    ATTRIBUTE9 = X_ATTRIBUTE9,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where RESULT_ID = X_RESULT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update SO_RESULTS_TL set
    NAME = X_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where RESULT_ID = X_RESULT_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure TRANSLATE_ROW (
X_NAME		in	VARCHAR2,
X_OWNER		in	VARCHAR2,
X_DESCRIPTION	in	VARCHAR2
) is
begin
  update so_results_tl set
    description              = X_DESCRIPTION,
    source_lang              = userenv('LANG'),
    last_update_date         = sysdate,
    last_updated_by          = decode(X_OWNER, 'SEED', 1, 0),
    last_update_login        = 0
  where name = X_NAME
  and userenv('LANG') in (language, source_lang);

end TRANSLATE_ROW;

procedure LOAD_ROW (
X_NAME				in	VARCHAR2,
X_RESULT_ID			in	VARCHAR2,
X_OWNER				in	VARCHAR2,
X_START_DATE_ACTIVE		in	VARCHAR2,
X_END_DATE_ACTIVE		in	VARCHAR2,
X_CONTEXT			in	VARCHAR2,
X_ATTRIBUTE1			in	VARCHAR2,
X_ATTRIBUTE2			in	VARCHAR2,
X_ATTRIBUTE3			in	VARCHAR2,
X_ATTRIBUTE4			in	VARCHAR2,
X_ATTRIBUTE5			in	VARCHAR2,
X_ATTRIBUTE6			in	VARCHAR2,
X_ATTRIBUTE7			in	VARCHAR2,
X_ATTRIBUTE8			in	VARCHAR2,
X_ATTRIBUTE9			in	VARCHAR2,
X_ATTRIBUTE10			in	VARCHAR2,
X_ATTRIBUTE11			in	VARCHAR2,
X_ATTRIBUTE12			in	VARCHAR2,
X_ATTRIBUTE13			in	VARCHAR2,
X_ATTRIBUTE14			in	VARCHAR2,
X_ATTRIBUTE15			in	VARCHAR2,
X_DESCRIPTION			in	VARCHAR2
) is
BEGIN
  DECLARE
     user_id    number := 0;
     result_id	number := 0;
     row_id 	varchar2(64);
  BEGIN
     if (X_OWNER = 'SEED') then
       user_id := 1;
     end if;

  so_results_pkg.UPDATE_ROW (
  X_RESULT_ID		=>	X_RESULT_ID,
  X_ATTRIBUTE10		=>	X_ATTRIBUTE10,
  X_ATTRIBUTE11		=>	X_ATTRIBUTE11,
  X_ATTRIBUTE12 	=>	X_ATTRIBUTE12,
  X_ATTRIBUTE13 	=>	X_ATTRIBUTE13,
  X_ATTRIBUTE14 	=>	X_ATTRIBUTE14,
  X_ATTRIBUTE15 	=>	X_ATTRIBUTE15,
  X_START_DATE_ACTIVE 	=>	to_date(X_START_DATE_ACTIVE, 'YYYY/MM/DD'),
  X_END_DATE_ACTIVE 	=>	to_date(X_END_DATE_ACTIVE, 'YYYY/MM/DD'),
  X_CONTEXT 		=>	X_CONTEXT,
  X_ATTRIBUTE1		=>	X_ATTRIBUTE1,
  X_ATTRIBUTE2		=>	X_ATTRIBUTE2,
  X_ATTRIBUTE3		=>	X_ATTRIBUTE3,
  X_ATTRIBUTE4		=>	X_ATTRIBUTE4,
  X_ATTRIBUTE5		=>	X_ATTRIBUTE5,
  X_ATTRIBUTE6		=>	X_ATTRIBUTE6,
  X_ATTRIBUTE7		=>	X_ATTRIBUTE7,
  X_ATTRIBUTE8		=>	X_ATTRIBUTE8,
  X_ATTRIBUTE9		=>	X_ATTRIBUTE9,
  X_NAME 		=>	x_NAME,
  X_DESCRIPTION 	=>	X_DESCRIPTION,
  X_LAST_UPDATE_DATE 	=>	sysdate,
  X_LAST_UPDATED_BY 	=>	user_id,
  X_LAST_UPDATE_LOGIN 	=>	0
);

  exception
     when NO_DATA_FOUND then

       select so_results_s.nextval into result_id from dual;

  so_results_pkg.INSERT_ROW (
  X_ROWID 		=>		row_id,
    X_RESULT_ID		=>	X_RESULT_ID,
  X_ATTRIBUTE10		=>	X_ATTRIBUTE10,
  X_ATTRIBUTE11		=>	X_ATTRIBUTE11,
  X_ATTRIBUTE12 	=>	X_ATTRIBUTE12,
  X_ATTRIBUTE13 	=>	X_ATTRIBUTE13,
  X_ATTRIBUTE14 	=>	X_ATTRIBUTE14,
  X_ATTRIBUTE15 	=>	X_ATTRIBUTE15,
  X_START_DATE_ACTIVE 	=>	to_date(X_START_DATE_ACTIVE, 'YYYY/MM/DD'),
  X_END_DATE_ACTIVE 	=>	to_date(X_END_DATE_ACTIVE, 'YYYY/MM/DD'),
  X_CONTEXT 		=>	X_CONTEXT,
  X_ATTRIBUTE1		=>	X_ATTRIBUTE1,
  X_ATTRIBUTE2		=>	X_ATTRIBUTE2,
  X_ATTRIBUTE3		=>	X_ATTRIBUTE3,
  X_ATTRIBUTE4		=>	X_ATTRIBUTE4,
  X_ATTRIBUTE5		=>	X_ATTRIBUTE5,
  X_ATTRIBUTE6		=>	X_ATTRIBUTE6,
  X_ATTRIBUTE7		=>	X_ATTRIBUTE7,
  X_ATTRIBUTE8		=>	X_ATTRIBUTE8,
  X_ATTRIBUTE9		=>	X_ATTRIBUTE9,
  X_NAME 		=>	x_NAME,
  X_DESCRIPTION 	=>	X_DESCRIPTION,
  X_CREATION_DATE	=>	sysdate,
  X_CREATED_BY		=>	user_id,
  X_LAST_UPDATE_DATE 	=>	sysdate,
  X_LAST_UPDATED_BY 	=>	user_id,
  X_LAST_UPDATE_LOGIN 	=>	0
);

END;
END LOAD_ROW;


procedure DELETE_ROW (
  X_RESULT_ID in NUMBER
) is
begin
  delete from SO_RESULTS_TL
  where RESULT_ID = X_RESULT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from SO_RESULTS_B
  where RESULT_ID = X_RESULT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from SO_RESULTS_TL T
  where not exists
    (select NULL
    from SO_RESULTS_B B
    where B.RESULT_ID = T.RESULT_ID
    );

  update SO_RESULTS_TL T set (
      NAME,
      DESCRIPTION
    ) = (select
      B.NAME,
      B.DESCRIPTION
    from SO_RESULTS_TL B
    where B.RESULT_ID = T.RESULT_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.RESULT_ID,
      T.LANGUAGE
  ) in (select
      SUBT.RESULT_ID,
      SUBT.LANGUAGE
    from SO_RESULTS_TL SUBB, SO_RESULTS_TL SUBT
    where SUBB.RESULT_ID = SUBT.RESULT_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
  ));

  insert into SO_RESULTS_TL (
    RESULT_ID,
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
    B.RESULT_ID,
    B.NAME,
    B.DESCRIPTION,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from SO_RESULTS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from SO_RESULTS_TL T
    where T.RESULT_ID = B.RESULT_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end SO_RESULTS_PKG;

/
