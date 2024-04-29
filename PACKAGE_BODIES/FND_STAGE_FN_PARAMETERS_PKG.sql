--------------------------------------------------------
--  DDL for Package Body FND_STAGE_FN_PARAMETERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_STAGE_FN_PARAMETERS_PKG" as
/* $Header: AFCPSFPB.pls 120.2 2005/08/19 14:36:26 susghosh ship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_FUNCTION_ID in NUMBER,
  X_PARAMETER_ID in NUMBER,
  X_PARAMETER_NAME in VARCHAR2,
  X_USER_PARAMETER_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from FND_STAGE_FN_PARAMETERS_TL
    where APPLICATION_ID = X_APPLICATION_ID
    and FUNCTION_ID = X_FUNCTION_ID
    and PARAMETER_ID = X_PARAMETER_ID
    and LANGUAGE = userenv('LANG')
    ;
begin
  insert into FND_STAGE_FN_PARAMETERS_TL (
    APPLICATION_ID,
    FUNCTION_ID,
    PARAMETER_ID,
    PARAMETER_NAME,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    USER_PARAMETER_NAME,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_APPLICATION_ID,
    X_FUNCTION_ID,
    X_PARAMETER_ID,
    X_PARAMETER_NAME,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_USER_PARAMETER_NAME,
    X_DESCRIPTION,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from FND_STAGE_FN_PARAMETERS_TL T
    where T.APPLICATION_ID = X_APPLICATION_ID
    and T.FUNCTION_ID = X_FUNCTION_ID
    and T.PARAMETER_ID = X_PARAMETER_ID
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
  X_APPLICATION_ID in NUMBER,
  X_FUNCTION_ID in NUMBER,
  X_PARAMETER_ID in NUMBER,
  X_PARAMETER_NAME in VARCHAR2,
  X_USER_PARAMETER_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c1 is select
      PARAMETER_NAME,
      USER_PARAMETER_NAME,
      DESCRIPTION
    from FND_STAGE_FN_PARAMETERS_TL
    where APPLICATION_ID = X_APPLICATION_ID
    and FUNCTION_ID = X_FUNCTION_ID
    and PARAMETER_ID = X_PARAMETER_ID
    and LANGUAGE = userenv('LANG')
    for update of APPLICATION_ID nowait;
  tlinfo c1%rowtype;

begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    close c1;
    return;
  end if;
  close c1;

  if (    (tlinfo.USER_PARAMETER_NAME = X_USER_PARAMETER_NAME)
      AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
           OR ((tlinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
      AND (tlinfo.PARAMETER_NAME = X_PARAMETER_NAME)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_FUNCTION_ID in NUMBER,
  X_PARAMETER_ID in NUMBER,
  X_PARAMETER_NAME in VARCHAR2,
  X_USER_PARAMETER_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update FND_STAGE_FN_PARAMETERS_TL set
    PARAMETER_NAME = X_PARAMETER_NAME,
    USER_PARAMETER_NAME = X_USER_PARAMETER_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where APPLICATION_ID = X_APPLICATION_ID
  and FUNCTION_ID = X_FUNCTION_ID
  and PARAMETER_ID = X_PARAMETER_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_FUNCTION_ID in NUMBER,
  X_PARAMETER_ID in NUMBER
) is
begin
  delete from FND_STAGE_FN_PARAMETERS_TL
  where APPLICATION_ID = X_APPLICATION_ID
  and FUNCTION_ID = X_FUNCTION_ID
  and PARAMETER_ID = X_PARAMETER_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
/* Mar/19/03 requested by Ric Ginsberg */
/* The following update statements are commented out */
/* as a quick workaround to fix the time-consuming table handler issue */
/* Eventually we'll need to turn them into a separate fix_language procedure */
/*

  update FND_STAGE_FN_PARAMETERS_TL T set (
      USER_PARAMETER_NAME,
      DESCRIPTION
    ) = (select
      B.USER_PARAMETER_NAME,
      B.DESCRIPTION
    from FND_STAGE_FN_PARAMETERS_TL B
    where B.APPLICATION_ID = T.APPLICATION_ID
    and B.FUNCTION_ID = T.FUNCTION_ID
    and B.PARAMETER_ID = T.PARAMETER_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.APPLICATION_ID,
      T.FUNCTION_ID,
      T.PARAMETER_ID,
      T.LANGUAGE
  ) in (select
      SUBT.APPLICATION_ID,
      SUBT.FUNCTION_ID,
      SUBT.PARAMETER_ID,
      SUBT.LANGUAGE
    from FND_STAGE_FN_PARAMETERS_TL SUBB, FND_STAGE_FN_PARAMETERS_TL SUBT
    where SUBB.APPLICATION_ID = SUBT.APPLICATION_ID
    and SUBB.FUNCTION_ID = SUBT.FUNCTION_ID
    and SUBB.PARAMETER_ID = SUBT.PARAMETER_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.USER_PARAMETER_NAME <> SUBT.USER_PARAMETER_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));
*/

  insert into FND_STAGE_FN_PARAMETERS_TL (
    APPLICATION_ID,
    FUNCTION_ID,
    PARAMETER_ID,
    PARAMETER_NAME,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    USER_PARAMETER_NAME,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.APPLICATION_ID,
    B.FUNCTION_ID,
    B.PARAMETER_ID,
    B.PARAMETER_NAME,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.USER_PARAMETER_NAME,
    B.DESCRIPTION,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_STAGE_FN_PARAMETERS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from FND_STAGE_FN_PARAMETERS_TL T
    where T.APPLICATION_ID = B.APPLICATION_ID
    and T.FUNCTION_ID = B.FUNCTION_ID
    and T.PARAMETER_ID = B.PARAMETER_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end FND_STAGE_FN_PARAMETERS_PKG;

/
