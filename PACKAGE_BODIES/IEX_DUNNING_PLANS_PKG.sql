--------------------------------------------------------
--  DDL for Package Body IEX_DUNNING_PLANS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_DUNNING_PLANS_PKG" as
/* $Header: iextdplb.pls 120.0 2005/07/09 21:55:04 ctlee noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  x_dunning_plan_id in NUMBER,
  x_name in VARCHAR2,
  x_description in VARCHAR2,
  x_start_date in date,
  x_end_date in date,
  x_ENABLED_FLAG in VARCHAR2,
  x_aging_bucket_id in number,
  x_score_id in number,
  x_dunning_level in VARCHAR2,
  x_object_version_number in number,
  x_CREATION_DATE in  DATE,
  x_CREATED_BY in      NUMBER,
  x_LAST_UPDATE_DATE in DATE,
  x_LAST_UPDATED_BY in  NUMBER,
  x_LAST_UPDATE_LOGIN in NUMBER,
  x_PROGRAM_APPLICATION_ID in  NUMBER,
  x_PROGRAM_ID in NUMBER,
  x_PROGRAM_UPDATE_DATE in DATE
) is
  cursor l_insert is
    select ROWID from iex_dunning_plans_b
    where dunning_plan_id = x_dunning_plan_id ;
  l_rowid varchar2(2000);
begin

  insert into iex_dunning_plans_b (
     DUNNING_PLAN_ID,
     START_DATE,
     END_DATE,
     ENABLED_FLAG,
     AGING_BUCKET_ID,
     SCORE_ID,
     DUNNING_LEVEL,
     OBJECT_VERSION_NUMBER,
     CREATED_BY,
     CREATION_DATE,
     LAST_UPDATE_DATE,
     LAST_UPDATED_BY,
     LAST_UPDATE_LOGIN,
     PROGRAM_APPLICATION_ID,
     PROGRAM_ID,
     PROGRAM_UPDATE_DATE
  ) values (
     x_dunning_plan_id,
     x_START_DATE,
     x_END_DATE,
     x_ENABLED_FLAG,
     x_AGING_BUCKET_ID,
     x_SCORE_ID,
     x_DUNNING_LEVEL,
     1.0,
     fnd_global.user_id,
     sysdate,
     sysdate,
     fnd_global.user_id,
     fnd_global.user_id,
     to_number(null),
     to_number(null),
     to_date(null)
  );


  insert into iex_dunning_plans_tl (
     DUNNING_PLAN_ID,
     NAME,
     DESCRIPTION,
     LANGUAGE,
     SOURCE_LANG,
     CREATED_BY,
     CREATION_DATE,
     LAST_UPDATE_DATE,
     LAST_UPDATED_BY,
     LAST_UPDATE_LOGIN
  ) select
     x_DUNNING_PLAN_ID,
     x_NAME,
     x_DESCRIPTION,
     L.LANGUAGE_CODE,
     userenv('LANG'),
     fnd_global.user_id,
     sysdate,
     sysdate,
     fnd_global.user_id,
     fnd_global.user_id
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from iex_dunning_plans_tl T
    where T.dunning_plan_id = x_dunning_plan_id
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open l_insert;
  fetch l_insert into l_rowid;
  if (l_insert%notfound) then
    close l_insert;
    raise no_data_found;
  end if;
  close l_insert;

end INSERT_ROW;

procedure LOCK_ROW (
  x_dunning_plan_id in NUMBER,
  x_name in VARCHAR2,
  x_description in VARCHAR2,
  x_start_date in date,
  x_end_date in date,
  x_ENABLED_FLAG in VARCHAR2,
  x_aging_bucket_id in number,
  x_score_id in number,
  x_dunning_level in VARCHAR2,
  x_object_version_number in number,
  -- x_CREATION_DATE in  DATE,
  -- x_CREATED_BY in      NUMBER,
  -- x_LAST_UPDATE_DATE in DATE,
  -- x_LAST_UPDATED_BY in  NUMBER,
  -- x_LAST_UPDATE_LOGIN in NUMBER,
  x_PROGRAM_APPLICATION_ID in  NUMBER,
  x_PROGRAM_ID in NUMBER,
  x_PROGRAM_UPDATE_DATE in DATE
) is
  cursor c is select
    DUNNING_PLAN_ID,
    START_DATE,
    END_DATE,
    ENABLED_FLAG,
    AGING_BUCKET_ID,
    SCORE_ID,
    DUNNING_LEVEL
    from iex_dunning_plans_b
    where dunning_plan_id = x_dunning_plan_id
    for update of dunning_plan_id nowait;

  recinfo c%rowtype;

  cursor c1 is select
    NAME,
    DESCRIPTION,
    decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from iex_dunning_plans_tl
    where dunning_plan_id = x_dunning_plan_id
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of dunning_plan_id nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;

  if (    ((recinfo.start_date = x_start_date)
           OR ((recinfo.start_date is null) AND (x_start_date is null)))
      AND ((recinfo.end_date = x_end_date)
           OR ((recinfo.end_date is null) AND (x_end_date is null)))
      AND ((recinfo.enabled_flag = x_enabled_flag)
           OR ((recinfo.enabled_flag is null) AND (x_enabled_flag is null)))
      AND ((recinfo.aging_bucket_id = x_aging_bucket_id)
           OR ((recinfo.aging_bucket_id is null) AND (x_aging_bucket_id is null)))
      AND ((recinfo.score_id = x_score_id)
           OR ((recinfo.score_id is null) AND (x_score_id is null)))
      AND ((recinfo.dunning_level = x_dunning_level)
           OR ((recinfo.dunning_level is null) AND (x_dunning_level is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.name = x_name)
               OR ((tlinfo.name is null) AND (x_name is null)))
          AND ((tlinfo.description = x_description)
               OR ((tlinfo.description is null) AND (x_description is null)))
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
  x_dunning_plan_id in NUMBER,
  x_name in VARCHAR2,
  x_description in VARCHAR2,
  x_start_date in date,
  x_end_date in date,
  x_ENABLED_FLAG in VARCHAR2,
  x_aging_bucket_id in number,
  x_score_id in number,
  x_dunning_level in VARCHAR2,
  x_object_version_number in number,
  -- x_CREATION_DATE in  DATE,
  -- x_CREATED_BY in      NUMBER,
  x_LAST_UPDATE_DATE in DATE,
  x_LAST_UPDATED_BY in  NUMBER,
  x_LAST_UPDATE_LOGIN in NUMBER,
  x_PROGRAM_APPLICATION_ID in  NUMBER,
  x_PROGRAM_ID in NUMBER,
  x_PROGRAM_UPDATE_DATE in DATE
) is
begin
  update iex_dunning_plans_b set
    START_DATE = x_start_date,
    END_DATE = x_end_date,
    ENABLED_FLAG = x_enabled_flag,
    AGING_BUCKET_ID = x_aging_bucket_id,
    SCORE_ID = x_score_id,
    DUNNING_LEVEL = x_dunning_level,
    OBJECT_VERSION_NUMBER  = object_version_number + 1.0,
    LAST_UPDATE_DATE = sysdate,
    LAST_UPDATED_BY = fnd_global.user_id,
    LAST_UPDATE_LOGIN = fnd_global.user_id
  where dunning_plan_id = x_dunning_plan_id;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update iex_dunning_plans_tl set
    name = x_name,
    description = x_description,
    LAST_UPDATE_DATE = sysdate,
    LAST_UPDATED_BY = fnd_global.user_id,
    LAST_UPDATE_LOGIN = fnd_global.user_id,
    SOURCE_LANG = userenv('LANG')
  where dunning_plan_id = x_dunning_plan_id
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  x_dunning_plan_id in NUMBER
) is
begin
  delete from iex_dunning_plans_tl
  where dunning_plan_id = x_dunning_plan_id;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from iex_dunning_plans_b
  where dunning_plan_id = x_dunning_plan_id;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from iex_ag_dn_xref
  where dunning_plan_id = x_dunning_plan_id;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from iex_dunning_plans_tl T
  where not exists
    (select NULL
    from iex_dunning_plans_b B
    where B.dunning_plan_id = T.dunning_plan_id
    );

  update iex_dunning_plans_tl T set (
      name,
      description
    ) = (select
      B.name,
      B.description
    from iex_dunning_plans_tl B
    where B.dunning_plan_id = T.dunning_plan_id
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.dunning_plan_id,
      T.LANGUAGE
  ) in (select
      SUBT.dunning_plan_id,
      SUBT.LANGUAGE
    from iex_dunning_plans_tl SUBB, iex_dunning_plans_tl SUBT
    where SUBB.dunning_plan_id = SUBT.dunning_plan_id
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.name <> SUBT.name
      or (SUBB.name is null and SUBT.name is not null)
      or (SUBB.name is not null and SUBT.name is null)
      or SUBB.description <> SUBT.description
      or (SUBB.description is null and SUBT.description is not null)
      or (SUBB.description is not null and SUBT.description is null)
  ));

  insert into iex_dunning_plans_tl (
    dunning_plan_id,
    name,
    description,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.dunning_plan_id,
    B.name,
    B.description,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from iex_dunning_plans_tl B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from iex_dunning_plans_tl T
    where T.dunning_plan_id = B.dunning_plan_id
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure TRANSLATE_ROW (
  x_dunning_plan_id in NUMBER,
  x_name in VARCHAR2,
  x_description in VARCHAR2
) is
begin
    update iex_dunning_plans_tl
      set name = x_name,
          description = x_description,
          source_lang = userenv('LANG'),
          last_update_date = sysdate,
          last_updated_by = fnd_global.user_id,
          last_update_login = 0
    where dunning_plan_id = x_dunning_plan_id
    and   userenv('LANG') in (language, source_lang);

end TRANSLATE_ROW;

procedure LOAD_ROW (
  x_dunning_plan_id in NUMBER,
  x_name in VARCHAR2,
  x_description in VARCHAR2,
  x_start_date in date,
  x_end_date in date,
  x_ENABLED_FLAG in VARCHAR2,
  x_aging_bucket_id in number,
  x_score_id in number,
  x_dunning_level in VARCHAR2,
  x_object_version_number in number,
  x_PROGRAM_APPLICATION_ID in  NUMBER,
  x_PROGRAM_ID in NUMBER,
  x_PROGRAM_UPDATE_DATE in DATE
) IS
  begin
   declare
     user_id            number := 0;
     row_id             varchar2(64);
     l_dunning_plan_id NUMBER;
   begin

    iex_dunning_plans_pkg.UPDATE_ROW (
      x_dunning_plan_id => x_dunning_plan_id,
      x_name => x_name,
      x_description => x_description,
      x_START_DATE => x_start_date,
      x_END_DATE => x_end_date,
      x_ENABLED_FLAG => x_enabled_flag,
      x_AGING_BUCKET_ID => x_aging_bucket_id,
      x_SCORE_ID => x_score_id,
      x_DUNNING_LEVEL => x_dunning_level,
      x_object_version_number => to_number(null),
      -- x_CREATION_DATE => to_date(null),
      -- x_CREATED_BY => to_number(null),
      x_LAST_UPDATE_DATE => to_date(null),
      x_LAST_UPDATED_BY => to_number(null),
      x_LAST_UPDATE_LOGIN => to_number(null),
      x_PROGRAM_APPLICATION_ID => to_number(null),
      x_PROGRAM_ID => to_number(null),
      x_PROGRAM_UPDATE_DATE => to_date(null)
    );
    exception
       when NO_DATA_FOUND then
           l_dunning_plan_id := x_dunning_plan_id;
           iex_dunning_plans_pkg.INSERT_ROW (
              x_rowid => row_id,
              x_dunning_plan_id => l_dunning_plan_id,
              x_name => x_name,
              x_description => x_description,
              x_START_DATE => x_start_date,
              x_END_DATE => x_end_date,
              x_ENABLED_FLAG => x_enabled_flag,
              x_AGING_BUCKET_ID => x_aging_bucket_id,
              x_SCORE_ID => x_score_id,
              x_DUNNING_LEVEL => x_dunning_level,
              x_object_version_number => to_number(null),
              x_CREATION_DATE => to_date(null),
              x_CREATED_BY => to_number(null),
              x_LAST_UPDATE_DATE => to_date(null),
              x_LAST_UPDATED_BY => to_number(null),
              x_LAST_UPDATE_LOGIN => to_number(null),
              x_PROGRAM_APPLICATION_ID => to_number(null),
              x_PROGRAM_ID => to_number(null),
              x_PROGRAM_UPDATE_DATE => to_date(null)
       );

    end;
end LOAD_ROW;

end iex_dunning_plans_pkg;

/
