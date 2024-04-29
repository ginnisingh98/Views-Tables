--------------------------------------------------------
--  DDL for Package Body FND_REQUEST_SETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_REQUEST_SETS_PKG" as
/* $Header: AFRSFRSB.pls 120.2.12010000.2 2014/01/17 19:02:48 ckclark ship $ */

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_REQUEST_SET_ID in NUMBER,
  X_APPLICATION_ID in NUMBER,
  X_REQUEST_SET_NAME in VARCHAR2,
  X_ALLOW_CONSTRAINTS_FLAG in VARCHAR2,
  X_PRINT_TOGETHER_FLAG in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_START_STAGE in NUMBER,
  X_END_DATE_ACTIVE in DATE,
  X_CONCURRENT_PROGRAM_ID in NUMBER,
  X_OWNER in NUMBER,
  X_PRINTER in VARCHAR2,
  X_PRINT_STYLE in VARCHAR2,
  X_ICON_NAME in VARCHAR2,
  X_RECALC_PARAMETERS in VARCHAR2,
  X_USER_REQUEST_SET_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from FND_REQUEST_SETS
    where REQUEST_SET_ID = X_REQUEST_SET_ID
    and APPLICATION_ID = X_APPLICATION_ID
    ;
begin
  insert into FND_REQUEST_SETS (
    APPLICATION_ID,
    REQUEST_SET_ID,
    REQUEST_SET_NAME,
    ALLOW_CONSTRAINTS_FLAG,
    PRINT_TOGETHER_FLAG,
    START_DATE_ACTIVE,
    START_STAGE,
    END_DATE_ACTIVE,
    CONCURRENT_PROGRAM_ID,
    OWNER,
    PRINTER,
    PRINT_STYLE,
    ICON_NAME,
    RECALC_PARAMETERS,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_APPLICATION_ID,
    X_REQUEST_SET_ID,
    X_REQUEST_SET_NAME,
    X_ALLOW_CONSTRAINTS_FLAG,
    X_PRINT_TOGETHER_FLAG,
    X_START_DATE_ACTIVE,
    X_START_STAGE,
    X_END_DATE_ACTIVE,
    X_CONCURRENT_PROGRAM_ID,
    X_OWNER,
    X_PRINTER,
    X_PRINT_STYLE,
    X_ICON_NAME,
    X_RECALC_PARAMETERS,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into FND_REQUEST_SETS_TL (
    APPLICATION_ID,
    REQUEST_SET_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    USER_REQUEST_SET_NAME,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_APPLICATION_ID,
    X_REQUEST_SET_ID,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_USER_REQUEST_SET_NAME,
    X_DESCRIPTION,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from FND_REQUEST_SETS_TL T
    where T.REQUEST_SET_ID = X_REQUEST_SET_ID
    and T.APPLICATION_ID = X_APPLICATION_ID
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
  X_REQUEST_SET_ID in NUMBER,
  X_APPLICATION_ID in NUMBER,
  X_REQUEST_SET_NAME in VARCHAR2,
  X_ALLOW_CONSTRAINTS_FLAG in VARCHAR2,
  X_PRINT_TOGETHER_FLAG in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_START_STAGE in NUMBER,
  X_END_DATE_ACTIVE in DATE,
  X_CONCURRENT_PROGRAM_ID in NUMBER,
  X_OWNER in NUMBER,
  X_PRINTER in VARCHAR2,
  X_PRINT_STYLE in VARCHAR2,
  X_ICON_NAME in VARCHAR2,
  X_RECALC_PARAMETERS in VARCHAR2,
  X_USER_REQUEST_SET_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      REQUEST_SET_NAME,
      ALLOW_CONSTRAINTS_FLAG,
      PRINT_TOGETHER_FLAG,
      START_DATE_ACTIVE,
      START_STAGE,
      END_DATE_ACTIVE,
      CONCURRENT_PROGRAM_ID,
      OWNER,
      PRINTER,
      PRINT_STYLE,
      ICON_NAME,
      RECALC_PARAMETERS
    from FND_REQUEST_SETS
    where REQUEST_SET_ID = X_REQUEST_SET_ID
    and APPLICATION_ID = X_APPLICATION_ID
    for update of REQUEST_SET_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      USER_REQUEST_SET_NAME,
      DESCRIPTION
    from FND_REQUEST_SETS_TL
    where REQUEST_SET_ID = X_REQUEST_SET_ID
    and APPLICATION_ID = X_APPLICATION_ID
    and LANGUAGE = userenv('LANG')
    for update of REQUEST_SET_ID nowait;
  tlinfo c1%rowtype;

begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.REQUEST_SET_NAME = X_REQUEST_SET_NAME)
      AND (recinfo.ALLOW_CONSTRAINTS_FLAG = X_ALLOW_CONSTRAINTS_FLAG)
      AND (recinfo.PRINT_TOGETHER_FLAG = X_PRINT_TOGETHER_FLAG)
      AND (recinfo.START_DATE_ACTIVE = X_START_DATE_ACTIVE)
      AND ((recinfo.START_STAGE = X_START_STAGE)
           OR ((recinfo.START_STAGE is null) AND (X_START_STAGE is null)))
      AND ((recinfo.END_DATE_ACTIVE = X_END_DATE_ACTIVE)
           OR ((recinfo.END_DATE_ACTIVE is null) AND (X_END_DATE_ACTIVE is null)))
      AND ((recinfo.CONCURRENT_PROGRAM_ID = X_CONCURRENT_PROGRAM_ID)
           OR ((recinfo.CONCURRENT_PROGRAM_ID is null) AND (X_CONCURRENT_PROGRAM_ID is null)))
      AND ((recinfo.OWNER = X_OWNER)
           OR ((recinfo.OWNER is null) AND (X_OWNER is null)))
      AND ((recinfo.PRINTER = X_PRINTER)
           OR ((recinfo.PRINTER is null) AND (X_PRINTER is null)))
      AND ((recinfo.PRINT_STYLE = X_PRINT_STYLE)
           OR ((recinfo.PRINT_STYLE is null) AND (X_PRINT_STYLE is null)))
      AND ((recinfo.ICON_NAME = X_ICON_NAME)
           OR ((recinfo.ICON_NAME is null) AND (X_ICON_NAME is null)))
      AND ((recinfo.RECALC_PARAMETERS = X_RECALC_PARAMETERS)
           OR ((recinfo.RECALC_PARAMETERS is null) AND (X_RECALC_PARAMETERS is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    close c1;
    return;
  end if;
  close c1;

  if (    (tlinfo.USER_REQUEST_SET_NAME = X_USER_REQUEST_SET_NAME)
      AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
           OR ((tlinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_REQUEST_SET_ID in NUMBER,
  X_APPLICATION_ID in NUMBER,
  X_REQUEST_SET_NAME in VARCHAR2,
  X_ALLOW_CONSTRAINTS_FLAG in VARCHAR2,
  X_PRINT_TOGETHER_FLAG in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_START_STAGE in NUMBER,
  X_END_DATE_ACTIVE in DATE,
  X_CONCURRENT_PROGRAM_ID in NUMBER,
  X_OWNER in NUMBER,
  X_PRINTER in VARCHAR2,
  X_PRINT_STYLE in VARCHAR2,
  X_ICON_NAME in VARCHAR2,
  X_RECALC_PARAMETERS in VARCHAR2,
  X_USER_REQUEST_SET_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update FND_REQUEST_SETS set
    REQUEST_SET_NAME = X_REQUEST_SET_NAME,
    ALLOW_CONSTRAINTS_FLAG = X_ALLOW_CONSTRAINTS_FLAG,
    PRINT_TOGETHER_FLAG = X_PRINT_TOGETHER_FLAG,
    START_DATE_ACTIVE = X_START_DATE_ACTIVE,
    START_STAGE = X_START_STAGE,
    END_DATE_ACTIVE = X_END_DATE_ACTIVE,
    CONCURRENT_PROGRAM_ID = X_CONCURRENT_PROGRAM_ID,
    OWNER = X_OWNER,
    PRINTER = X_PRINTER,
    PRINT_STYLE = X_PRINT_STYLE,
    ICON_NAME = X_ICON_NAME,
    RECALC_PARAMETERS = X_RECALC_PARAMETERS,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where REQUEST_SET_ID = X_REQUEST_SET_ID
  and APPLICATION_ID = X_APPLICATION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update FND_REQUEST_SETS_TL set
    USER_REQUEST_SET_NAME = X_USER_REQUEST_SET_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where REQUEST_SET_ID = X_REQUEST_SET_ID
  and APPLICATION_ID = X_APPLICATION_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;



procedure DELETE_ROW (
  X_REQUEST_SET_ID in NUMBER,
  X_APPLICATION_ID in NUMBER
) is
begin

  -- Disable the concurrent program (if any).
  begin
    update fnd_concurrent_programs
       set enabled_flag='N'
     where application_id = x_application_id
       and concurrent_program_id in
           (select concurrent_program_id
              from fnd_request_sets
             where application_id = x_application_id
               and request_set_id = x_request_set_id
               and concurrent_program_id is not null);
  exception
    when no_data_found then -- We don't care.
      null;
  end;

  delete from FND_REQUEST_SETS
  where APPLICATION_ID = X_APPLICATION_ID
  and REQUEST_SET_ID = X_REQUEST_SET_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from FND_REQUEST_SETS_TL
  where APPLICATION_ID = X_APPLICATION_ID
  and REQUEST_SET_ID = X_REQUEST_SET_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  /* Do not raise no_data_found on the following rows! */

  delete from FND_STAGE_FN_PARAMETER_VALUES
  where SET_APPLICATION_ID = X_APPLICATION_ID
  and REQUEST_SET_ID = X_REQUEST_SET_ID;

  delete from FND_REQUEST_SET_STAGES
  where SET_APPLICATION_ID = X_APPLICATION_ID
  and REQUEST_SET_ID = X_REQUEST_SET_ID;

  delete from FND_REQUEST_SET_STAGES_TL
  where SET_APPLICATION_ID = X_APPLICATION_ID
  and REQUEST_SET_ID = X_REQUEST_SET_ID;

  delete from FND_REQUEST_SET_PROGRAMS
  where SET_APPLICATION_ID = X_APPLICATION_ID
  and REQUEST_SET_ID = X_REQUEST_SET_ID;

  delete from FND_REQUEST_SET_PROGRAM_ARGS
  where APPLICATION_ID = X_APPLICATION_ID
  and REQUEST_SET_ID = X_REQUEST_SET_ID;

end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
/* Mar/19/03 requested by Ric Ginsberg */
/* The following delete and update statements are commented out */
/* as a quick workaround to fix the time-consuming table handler issue */
/* Eventually we'll need to turn them into a separate fix_language procedure */
/*

  delete from FND_REQUEST_SETS_TL T
  where not exists
    (select NULL
    from FND_REQUEST_SETS B
    where B.REQUEST_SET_ID = T.REQUEST_SET_ID
    and B.APPLICATION_ID = T.APPLICATION_ID
    );

  update FND_REQUEST_SETS_TL T set (
      USER_REQUEST_SET_NAME,
      DESCRIPTION
    ) = (select
      B.USER_REQUEST_SET_NAME,
      B.DESCRIPTION
    from FND_REQUEST_SETS_TL B
    where B.REQUEST_SET_ID = T.REQUEST_SET_ID
    and B.APPLICATION_ID = T.APPLICATION_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.REQUEST_SET_ID,
      T.APPLICATION_ID,
      T.LANGUAGE
  ) in (select
      SUBT.REQUEST_SET_ID,
      SUBT.APPLICATION_ID,
      SUBT.LANGUAGE
    from FND_REQUEST_SETS_TL SUBB, FND_REQUEST_SETS_TL SUBT
    where SUBB.REQUEST_SET_ID = SUBT.REQUEST_SET_ID
    and SUBB.APPLICATION_ID = SUBT.APPLICATION_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.USER_REQUEST_SET_NAME <> SUBT.USER_REQUEST_SET_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));
*/

  insert into FND_REQUEST_SETS_TL (
    APPLICATION_ID,
    REQUEST_SET_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    USER_REQUEST_SET_NAME,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.APPLICATION_ID,
    B.REQUEST_SET_ID,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.USER_REQUEST_SET_NAME,
    B.DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from FND_REQUEST_SETS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from FND_REQUEST_SETS_TL T
    where T.REQUEST_SET_ID = B.REQUEST_SET_ID
    and T.APPLICATION_ID = B.APPLICATION_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end FND_REQUEST_SETS_PKG;

/
