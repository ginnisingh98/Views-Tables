--------------------------------------------------------
--  DDL for Package Body GMD_GRADES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_GRADES_PKG" as
/* $Header: GMDGIGRB.pls 115.0 2002/03/12 12:57:12 pkm ship        $ */
procedure INSERT_ROW (
  X_ROWID in out VARCHAR2,
  X_QC_GRADE in VARCHAR2,
  X_DELETE_MARK in NUMBER,
  X_TEXT_CODE in NUMBER,
  X_TRANS_CNT in NUMBER,
  X_QC_GRADE_DESC in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from GMD_GRADES_B
    where QC_GRADE = X_QC_GRADE
    ;
begin
  insert into GMD_GRADES_B (
    QC_GRADE,
    DELETE_MARK,
    TEXT_CODE,
    TRANS_CNT,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_QC_GRADE,
    X_DELETE_MARK,
    X_TEXT_CODE,
    X_TRANS_CNT,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into GMD_GRADES_TL (
    QC_GRADE,
    QC_GRADE_DESC,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_QC_GRADE,
    X_QC_GRADE_DESC,
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
    from GMD_GRADES_TL T
    where T.QC_GRADE = X_QC_GRADE
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
  X_QC_GRADE in VARCHAR2,
  X_DELETE_MARK in NUMBER,
  X_TEXT_CODE in NUMBER,
  X_TRANS_CNT in NUMBER,
  X_QC_GRADE_DESC in VARCHAR2
) is
  cursor c is select
      DELETE_MARK,
      TEXT_CODE,
      TRANS_CNT
    from GMD_GRADES_B
    where QC_GRADE = X_QC_GRADE
    for update of QC_GRADE nowait;
  recinfo c%rowtype;

  cursor c1 is select
      QC_GRADE_DESC,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from GMD_GRADES_TL
    where QC_GRADE = X_QC_GRADE
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of QC_GRADE nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.DELETE_MARK = X_DELETE_MARK)
      AND ((recinfo.TEXT_CODE = X_TEXT_CODE)
           OR ((recinfo.TEXT_CODE is null) AND (X_TEXT_CODE is null)))
      AND ((recinfo.TRANS_CNT = X_TRANS_CNT)
           OR ((recinfo.TRANS_CNT is null) AND (X_TRANS_CNT is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.QC_GRADE_DESC = X_QC_GRADE_DESC)
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
  X_QC_GRADE in VARCHAR2,
  X_DELETE_MARK in NUMBER,
  X_TEXT_CODE in NUMBER,
  X_TRANS_CNT in NUMBER,
  X_QC_GRADE_DESC in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update GMD_GRADES_B set
    DELETE_MARK = X_DELETE_MARK,
    TEXT_CODE = X_TEXT_CODE,
    TRANS_CNT = X_TRANS_CNT,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where QC_GRADE = X_QC_GRADE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update GMD_GRADES_TL set
    QC_GRADE_DESC = X_QC_GRADE_DESC,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where QC_GRADE = X_QC_GRADE
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_QC_GRADE in VARCHAR2
) is
begin
  delete from GMD_GRADES_TL
  where QC_GRADE = X_QC_GRADE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from GMD_GRADES_B
  where QC_GRADE = X_QC_GRADE;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from GMD_GRADES_TL T
  where not exists
    (select NULL
    from GMD_GRADES_B B
    where B.QC_GRADE = T.QC_GRADE
    );

  update GMD_GRADES_TL T set (
      QC_GRADE_DESC
    ) = (select
      B.QC_GRADE_DESC
    from GMD_GRADES_TL B
    where B.QC_GRADE = T.QC_GRADE
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.QC_GRADE,
      T.LANGUAGE
  ) in (select
      SUBT.QC_GRADE,
      SUBT.LANGUAGE
    from GMD_GRADES_TL SUBB, GMD_GRADES_TL SUBT
    where SUBB.QC_GRADE = SUBT.QC_GRADE
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.QC_GRADE_DESC <> SUBT.QC_GRADE_DESC
  ));

  insert into GMD_GRADES_TL (
    QC_GRADE,
    QC_GRADE_DESC,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.QC_GRADE,
    B.QC_GRADE_DESC,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from GMD_GRADES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from GMD_GRADES_TL T
    where T.QC_GRADE = B.QC_GRADE
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end GMD_GRADES_PKG;

/
