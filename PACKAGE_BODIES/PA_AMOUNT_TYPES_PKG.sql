--------------------------------------------------------
--  DDL for Package Body PA_AMOUNT_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_AMOUNT_TYPES_PKG" as
/* $Header: PARRATLB.pls 120.1 2005/08/19 16:59:43 mwasowic noship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  X_AMOUNT_TYPE_ID in NUMBER,
  X_PLAN_ADJ_AMOUNT_FLAG in VARCHAR2,
  X_PLAN_ADJUSTABLE_FLAG in VARCHAR2,
  X_AMOUNT_TYPE_CODE in VARCHAR2,
  X_AMOUNT_TYPE_CLASS in VARCHAR2,
  X_AMOUNT_TYPE_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from PA_AMOUNT_TYPES_B
    where AMOUNT_TYPE_ID = X_AMOUNT_TYPE_ID
    ;
begin
  insert into PA_AMOUNT_TYPES_B (
    PLAN_ADJ_AMOUNT_FLAG,
    PLAN_ADJUSTABLE_FLAG,
    AMOUNT_TYPE_ID,
    AMOUNT_TYPE_CODE,
    AMOUNT_TYPE_CLASS,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_PLAN_ADJ_AMOUNT_FLAG,
    X_PLAN_ADJUSTABLE_FLAG,
    X_AMOUNT_TYPE_ID,
    X_AMOUNT_TYPE_CODE,
    X_AMOUNT_TYPE_CLASS,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into PA_AMOUNT_TYPES_TL (
    AMOUNT_TYPE_ID,
    AMOUNT_TYPE_NAME,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_AMOUNT_TYPE_ID,
    X_AMOUNT_TYPE_NAME,
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
    from PA_AMOUNT_TYPES_TL T
    where T.AMOUNT_TYPE_ID = X_AMOUNT_TYPE_ID
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
  X_AMOUNT_TYPE_ID in NUMBER,
  X_PLAN_ADJ_AMOUNT_FLAG in VARCHAR2,
  X_PLAN_ADJUSTABLE_FLAG in VARCHAR2,
  X_AMOUNT_TYPE_CODE in VARCHAR2,
  X_AMOUNT_TYPE_CLASS in VARCHAR2,
  X_AMOUNT_TYPE_NAME in VARCHAR2
) is
  cursor c is select
      PLAN_ADJ_AMOUNT_FLAG,
      PLAN_ADJUSTABLE_FLAG,
      AMOUNT_TYPE_CODE,
      AMOUNT_TYPE_CLASS
    from PA_AMOUNT_TYPES_B
    where AMOUNT_TYPE_ID = X_AMOUNT_TYPE_ID
    for update of AMOUNT_TYPE_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      AMOUNT_TYPE_NAME,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from PA_AMOUNT_TYPES_TL
    where AMOUNT_TYPE_ID = X_AMOUNT_TYPE_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of AMOUNT_TYPE_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.PLAN_ADJ_AMOUNT_FLAG = X_PLAN_ADJ_AMOUNT_FLAG)
           OR ((recinfo.PLAN_ADJ_AMOUNT_FLAG is null) AND (X_PLAN_ADJ_AMOUNT_FLAG is null)))
      AND ((recinfo.PLAN_ADJUSTABLE_FLAG = X_PLAN_ADJUSTABLE_FLAG)
           OR ((recinfo.PLAN_ADJUSTABLE_FLAG is null) AND (X_PLAN_ADJUSTABLE_FLAG is null)))
      AND (recinfo.AMOUNT_TYPE_CODE = X_AMOUNT_TYPE_CODE)
      AND (recinfo.AMOUNT_TYPE_CLASS = X_AMOUNT_TYPE_CLASS)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.AMOUNT_TYPE_NAME = X_AMOUNT_TYPE_NAME)
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
  X_AMOUNT_TYPE_ID in NUMBER,
  X_PLAN_ADJ_AMOUNT_FLAG in VARCHAR2,
  X_PLAN_ADJUSTABLE_FLAG in VARCHAR2,
  X_AMOUNT_TYPE_CODE in VARCHAR2,
  X_AMOUNT_TYPE_CLASS in VARCHAR2,
  X_AMOUNT_TYPE_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update PA_AMOUNT_TYPES_B set
    PLAN_ADJ_AMOUNT_FLAG = X_PLAN_ADJ_AMOUNT_FLAG,
    PLAN_ADJUSTABLE_FLAG = X_PLAN_ADJUSTABLE_FLAG,
    AMOUNT_TYPE_CODE = X_AMOUNT_TYPE_CODE,
    AMOUNT_TYPE_CLASS = X_AMOUNT_TYPE_CLASS,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where AMOUNT_TYPE_ID = X_AMOUNT_TYPE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update PA_AMOUNT_TYPES_TL set
    AMOUNT_TYPE_NAME = X_AMOUNT_TYPE_NAME,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where AMOUNT_TYPE_ID = X_AMOUNT_TYPE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_AMOUNT_TYPE_ID in NUMBER
) is
begin
  delete from PA_AMOUNT_TYPES_TL
  where AMOUNT_TYPE_ID = X_AMOUNT_TYPE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from PA_AMOUNT_TYPES_B
  where AMOUNT_TYPE_ID = X_AMOUNT_TYPE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from PA_AMOUNT_TYPES_TL T
  where not exists
    (select NULL
    from PA_AMOUNT_TYPES_B B
    where B.AMOUNT_TYPE_ID = T.AMOUNT_TYPE_ID
    );

  update PA_AMOUNT_TYPES_TL T set (
      AMOUNT_TYPE_NAME
    ) = (select
      B.AMOUNT_TYPE_NAME
    from PA_AMOUNT_TYPES_TL B
    where B.AMOUNT_TYPE_ID = T.AMOUNT_TYPE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.AMOUNT_TYPE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.AMOUNT_TYPE_ID,
      SUBT.LANGUAGE
    from PA_AMOUNT_TYPES_TL SUBB, PA_AMOUNT_TYPES_TL SUBT
    where SUBB.AMOUNT_TYPE_ID = SUBT.AMOUNT_TYPE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.AMOUNT_TYPE_NAME <> SUBT.AMOUNT_TYPE_NAME
  ));

  insert into PA_AMOUNT_TYPES_TL (
    AMOUNT_TYPE_ID,
    AMOUNT_TYPE_NAME,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.AMOUNT_TYPE_ID,
    B.AMOUNT_TYPE_NAME,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from PA_AMOUNT_TYPES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from PA_AMOUNT_TYPES_TL T
    where T.AMOUNT_TYPE_ID = B.AMOUNT_TYPE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure TRANSLATE_ROW(
  X_AMOUNT_TYPE_NAME in VARCHAR2,
  X_AMOUNT_TYPE_ID in NUMBER,
  X_OWNER in VARCHAR2
) is
begin

  update PA_AMOUNT_TYPES_TL set
    AMOUNT_TYPE_NAME = X_AMOUNT_TYPE_NAME,
    LAST_UPDATE_DATE  = sysdate,
    LAST_UPDATED_BY   = decode(X_OWNER, 'SEED', 1, 0),
    LAST_UPDATE_LOGIN = 0,
    SOURCE_LANG       = USERENV('LANG')
  where AMOUNT_TYPE_ID = X_AMOUNT_TYPE_ID
    and USERENV('LANG') IN ( LANGUAGE , SOURCE_LANG );

  if (sql%notfound) then
    raise no_data_found;
  end if;
end TRANSLATE_ROW;

procedure LOAD_ROW(
  X_AMOUNT_TYPE_ID in NUMBER,
  X_PLAN_ADJ_AMOUNT_FLAG in VARCHAR2,
  X_PLAN_ADJUSTABLE_FLAG in VARCHAR2,
  X_AMOUNT_TYPE_CODE in VARCHAR2,
  X_AMOUNT_TYPE_CLASS in VARCHAR2,
  X_AMOUNT_TYPE_NAME in VARCHAR2,
  X_OWNER in VARCHAR2
) is

  user_id NUMBER;
  X_ROWID VARCHAR2(64);

begin

  if (X_OWNER = 'SEED')then
   user_id := 1;
  else
   user_id := 0;
  end if;

  pa_amount_types_pkg.UPDATE_ROW(
          X_AMOUNT_TYPE_ID => X_AMOUNT_TYPE_ID,
          X_PLAN_ADJ_AMOUNT_FLAG => X_PLAN_ADJ_AMOUNT_FLAG,
          X_PLAN_ADJUSTABLE_FLAG => X_PLAN_ADJUSTABLE_FLAG,
          X_AMOUNT_TYPE_CODE => X_AMOUNT_TYPE_CODE,
          X_AMOUNT_TYPE_CLASS => X_AMOUNT_TYPE_CLASS,
          X_AMOUNT_TYPE_NAME => X_AMOUNT_TYPE_NAME,
          X_LAST_UPDATE_DATE => sysdate,
          X_LAST_UPDATED_BY => user_id,
          X_LAST_UPDATE_LOGIN => 0
          );
exception
when NO_DATA_FOUND then
  pa_amount_types_pkg.INSERT_ROW(
          X_ROWID => X_ROWID,
          X_AMOUNT_TYPE_ID => X_AMOUNT_TYPE_ID,
          X_PLAN_ADJ_AMOUNT_FLAG => X_PLAN_ADJ_AMOUNT_FLAG,
          X_PLAN_ADJUSTABLE_FLAG => X_PLAN_ADJUSTABLE_FLAG,
          X_AMOUNT_TYPE_CODE => X_AMOUNT_TYPE_CODE,
          X_AMOUNT_TYPE_CLASS => X_AMOUNT_TYPE_CLASS,
          X_AMOUNT_TYPE_NAME => X_AMOUNT_TYPE_NAME,
          X_CREATION_DATE => sysdate,
          X_CREATED_BY => user_id,
          X_LAST_UPDATE_DATE => sysdate,
          X_LAST_UPDATED_BY => user_id,
          X_LAST_UPDATE_LOGIN => 0
          );
end LOAD_ROW;

end PA_AMOUNT_TYPES_PKG;

/
