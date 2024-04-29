--------------------------------------------------------
--  DDL for Package Body IGW_QUESTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGW_QUESTIONS_PKG" as
-- $Header: igwstqub.pls 115.8 2002/11/15 00:47:34 ashkumar ship $

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_QUESTION_NUMBER in VARCHAR2,
  X_APPLIES_TO in VARCHAR2,
  X_EXPLANATION_FOR_YES_FLAG in VARCHAR2,
  X_EXPLANATION_FOR_NO_FLAG in VARCHAR2,
  X_DATE_FOR_YES_FLAG in VARCHAR2,
  X_DATE_FOR_NO_FLAG in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_EXPLANATION in VARCHAR2,
  X_POLICY in VARCHAR2,
  X_REGULATION in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from IGW_QUESTIONS
    where QUESTION_NUMBER = X_QUESTION_NUMBER
    ;
begin
  insert into IGW_QUESTIONS (
    QUESTION_NUMBER,
    APPLIES_TO,
    EXPLANATION_FOR_YES_FLAG,
    EXPLANATION_FOR_NO_FLAG,
    DATE_FOR_YES_FLAG,
    DATE_FOR_NO_FLAG,
    START_DATE_ACTIVE,
    END_DATE_ACTIVE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_QUESTION_NUMBER,
    X_APPLIES_TO,
    X_EXPLANATION_FOR_YES_FLAG,
    X_EXPLANATION_FOR_NO_FLAG,
    X_DATE_FOR_YES_FLAG,
    X_DATE_FOR_NO_FLAG,
    X_START_DATE_ACTIVE,
    X_END_DATE_ACTIVE,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into IGW_QUESTIONS_TL (
    QUESTION_NUMBER,
    DESCRIPTION,
    EXPLANATION,
    POLICY,
    REGULATION,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_QUESTION_NUMBER,
    X_DESCRIPTION,
    X_EXPLANATION,
    X_POLICY,
    X_REGULATION,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from IGW_QUESTIONS_TL T
    where T.QUESTION_NUMBER = X_QUESTION_NUMBER
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
  X_QUESTION_NUMBER in VARCHAR2,
  X_APPLIES_TO in VARCHAR2,
  X_EXPLANATION_FOR_YES_FLAG in VARCHAR2,
  X_EXPLANATION_FOR_NO_FLAG in VARCHAR2,
  X_DATE_FOR_YES_FLAG in VARCHAR2,
  X_DATE_FOR_NO_FLAG in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_EXPLANATION in VARCHAR2,
  X_POLICY in VARCHAR2,
  X_REGULATION in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      APPLIES_TO,
      EXPLANATION_FOR_YES_FLAG,
      EXPLANATION_FOR_NO_FLAG,
      DATE_FOR_YES_FLAG,
      DATE_FOR_NO_FLAG,
      START_DATE_ACTIVE,
      END_DATE_ACTIVE
    from IGW_QUESTIONS
    where QUESTION_NUMBER = X_QUESTION_NUMBER
    for update of QUESTION_NUMBER nowait;
  recinfo c%rowtype;

  cursor c1 is select
      DESCRIPTION,
      EXPLANATION,
      POLICY,
      REGULATION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from IGW_QUESTIONS_TL
    where QUESTION_NUMBER = X_QUESTION_NUMBER
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of QUESTION_NUMBER nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.APPLIES_TO = X_APPLIES_TO)
      AND (recinfo.EXPLANATION_FOR_YES_FLAG = X_EXPLANATION_FOR_YES_FLAG)
      AND (recinfo.EXPLANATION_FOR_NO_FLAG = X_EXPLANATION_FOR_NO_FLAG)
      AND (recinfo.DATE_FOR_YES_FLAG = X_DATE_FOR_YES_FLAG)
      AND (recinfo.DATE_FOR_NO_FLAG = X_DATE_FOR_NO_FLAG)
      AND (recinfo.START_DATE_ACTIVE = X_START_DATE_ACTIVE)
      AND ((recinfo.END_DATE_ACTIVE = X_END_DATE_ACTIVE)
           OR ((recinfo.END_DATE_ACTIVE is null) AND (X_END_DATE_ACTIVE is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.DESCRIPTION = X_DESCRIPTION)
         AND ((tlinfo.EXPLANATION = X_EXPLANATION)
              OR ((tlinfo.EXPLANATION is null) AND (X_EXPLANATION is null)))
         AND ((tlinfo.POLICY = X_POLICY)
              OR ((tlinfo.POLICY is null) AND (X_POLICY is null)))
         AND ((tlinfo.REGULATION = X_REGULATION)
           OR ((tlinfo.REGULATION is null) AND (X_REGULATION is null)))
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
  X_QUESTION_NUMBER in VARCHAR2,
  X_APPLIES_TO in VARCHAR2,
  X_EXPLANATION_FOR_YES_FLAG in VARCHAR2,
  X_EXPLANATION_FOR_NO_FLAG in VARCHAR2,
  X_DATE_FOR_YES_FLAG in VARCHAR2,
  X_DATE_FOR_NO_FLAG in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_EXPLANATION in VARCHAR2,
  X_POLICY in VARCHAR2,
  X_REGULATION in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update IGW_QUESTIONS set
    APPLIES_TO = X_APPLIES_TO,
    EXPLANATION_FOR_YES_FLAG = X_EXPLANATION_FOR_YES_FLAG,
    EXPLANATION_FOR_NO_FLAG = X_EXPLANATION_FOR_NO_FLAG,
    DATE_FOR_YES_FLAG = X_DATE_FOR_YES_FLAG,
    DATE_FOR_NO_FLAG = X_DATE_FOR_NO_FLAG,
    START_DATE_ACTIVE = X_START_DATE_ACTIVE,
    END_DATE_ACTIVE = X_END_DATE_ACTIVE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where QUESTION_NUMBER = X_QUESTION_NUMBER;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update IGW_QUESTIONS_TL set
    DESCRIPTION = X_DESCRIPTION,
    EXPLANATION = X_EXPLANATION,
    POLICY = X_POLICY,
    REGULATION = X_REGULATION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where QUESTION_NUMBER = X_QUESTION_NUMBER
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_QUESTION_NUMBER in VARCHAR2
) is
begin
  delete from IGW_QUESTIONS_TL
  where QUESTION_NUMBER = X_QUESTION_NUMBER;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from IGW_QUESTIONS
  where QUESTION_NUMBER = X_QUESTION_NUMBER;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from IGW_QUESTIONS_TL T
  where not exists
    (select NULL
    from IGW_QUESTIONS B
    where B.QUESTION_NUMBER = T.QUESTION_NUMBER
    );

  update IGW_QUESTIONS_TL T set (
      DESCRIPTION,
      EXPLANATION,
      POLICY,
      REGULATION
    ) = (select
      B.DESCRIPTION,
      B.EXPLANATION,
      B.POLICY,
      B.REGULATION
    from IGW_QUESTIONS_TL B
    where B.QUESTION_NUMBER = T.QUESTION_NUMBER
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.QUESTION_NUMBER,
      T.LANGUAGE
  ) in (select
      SUBT.QUESTION_NUMBER,
      SUBT.LANGUAGE
    from IGW_QUESTIONS_TL SUBB, IGW_QUESTIONS_TL SUBT
    where SUBB.QUESTION_NUMBER = SUBT.QUESTION_NUMBER
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DESCRIPTION <> SUBT.DESCRIPTION
     OR (SUBB.EXPLANATION <> SUBT.EXPLANATION)
     OR (SUBB.EXPLANATION is null and SUBT.EXPLANATION is not null)
     OR (SUBB.EXPLANATION is not null and SUBT.EXPLANATION is null)
     OR (SUBB.POLICY <> SUBT.POLICY)
     OR (SUBB.POLICY is null and SUBT.POLICY is not null)
     OR (SUBB.POLICY is not null and SUBT.POLICY is null)
     OR (SUBB.REGULATION <> SUBT.REGULATION)
     OR (SUBB.REGULATION is null and SUBT.REGULATION is not null)
     OR (SUBB.REGULATION is not null and SUBT.REGULATION is null))
  );

  insert into IGW_QUESTIONS_TL (
    QUESTION_NUMBER,
    DESCRIPTION,
    EXPLANATION,
    POLICY,
    REGULATION,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.QUESTION_NUMBER,
    B.DESCRIPTION,
    B.EXPLANATION,
    B.POLICY,
    B.REGULATION,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from IGW_QUESTIONS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from IGW_QUESTIONS_TL T
    where T.QUESTION_NUMBER = B.QUESTION_NUMBER
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure TRANSLATE_ROW (
  X_QUESTION_NUMBER in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_EXPLANATION in VARCHAR2,
  X_POLICY  in VARCHAR2,
  X_REGULATION in VARCHAR2,
  X_OWNER in VARCHAR2) is
begin
   update igw_questions_tl set
     DESCRIPTION = nvl(X_DESCRIPTION, DESCRIPTION),
     EXPLANATION = nvl(X_EXPLANATION, EXPLANATION),
     POLICY = nvl(X_POLICY, POLICY),
     REGULATION = nvl(X_REGULATION, REGULATION),
     LAST_UPDATE_DATE = sysdate,
     LAST_UPDATED_BY = decode(X_OWNER, 'SEED', 1, 0),
     LAST_UPDATE_LOGIN = 0,
     SOURCE_LANG = userenv('LANG')
   where question_number = X_QUESTION_NUMBER  and
         userenv('LANG') in (language, source_lang);

 end TRANSLATE_ROW;

end IGW_QUESTIONS_PKG;


/
