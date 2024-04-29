--------------------------------------------------------
--  DDL for Package Body CAC_SR_PERIOD_CATS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CAC_SR_PERIOD_CATS_PKG" as
/* $Header: cacsrperiodcatb.pls 120.2 2006/03/01 02:03:04 sbarat noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_PERIOD_CATEGORY_ID in NUMBER,
  X_FREE_BUSY_TYPE in VARCHAR2,
  X_DISPLAY_COLOR in VARCHAR2,
  X_SHOW_PERIOD_DETAILS in VARCHAR2,
  X_PERIOD_CATEGORY_NAME in VARCHAR2,
  X_PERIOD_CATEGORY_DESC in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from CAC_SR_PERIOD_CATS_B
    where PERIOD_CATEGORY_ID = X_PERIOD_CATEGORY_ID
    ;
begin
  insert into CAC_SR_PERIOD_CATS_B (
    PERIOD_CATEGORY_ID,
    FREE_BUSY_TYPE,
    DISPLAY_COLOR,
    SHOW_PERIOD_DETAILS,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_PERIOD_CATEGORY_ID,
    X_FREE_BUSY_TYPE,
    X_DISPLAY_COLOR,
    X_SHOW_PERIOD_DETAILS,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into CAC_SR_PERIOD_CATS_TL (
    PERIOD_CATEGORY_ID,
    PERIOD_CATEGORY_NAME,
    PERIOD_CATEGORY_DESC,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_PERIOD_CATEGORY_ID,
    X_PERIOD_CATEGORY_NAME,
    X_PERIOD_CATEGORY_DESC,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from CAC_SR_PERIOD_CATS_TL T
    where T.PERIOD_CATEGORY_ID = X_PERIOD_CATEGORY_ID
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
  X_PERIOD_CATEGORY_ID in NUMBER,
  X_FREE_BUSY_TYPE in VARCHAR2,
  X_DISPLAY_COLOR in VARCHAR2,
  X_SHOW_PERIOD_DETAILS in VARCHAR2,
  X_PERIOD_CATEGORY_NAME in VARCHAR2,
  X_PERIOD_CATEGORY_DESC in VARCHAR2
) is
  cursor c is select
      FREE_BUSY_TYPE,
      DISPLAY_COLOR,
      SHOW_PERIOD_DETAILS
    from CAC_SR_PERIOD_CATS_B
    where PERIOD_CATEGORY_ID = X_PERIOD_CATEGORY_ID
    for update of PERIOD_CATEGORY_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      PERIOD_CATEGORY_NAME,
      PERIOD_CATEGORY_DESC,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from CAC_SR_PERIOD_CATS_TL
    where PERIOD_CATEGORY_ID = X_PERIOD_CATEGORY_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of PERIOD_CATEGORY_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.FREE_BUSY_TYPE = X_FREE_BUSY_TYPE)
      AND (recinfo.DISPLAY_COLOR = X_DISPLAY_COLOR)
      AND (recinfo.SHOW_PERIOD_DETAILS = X_SHOW_PERIOD_DETAILS)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.PERIOD_CATEGORY_NAME = X_PERIOD_CATEGORY_NAME)
          AND ((tlinfo.PERIOD_CATEGORY_DESC = X_PERIOD_CATEGORY_DESC)
               OR ((tlinfo.PERIOD_CATEGORY_DESC is null) AND (X_PERIOD_CATEGORY_DESC is null)))
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
  X_PERIOD_CATEGORY_ID in NUMBER,
  X_FREE_BUSY_TYPE in VARCHAR2,
  X_DISPLAY_COLOR in VARCHAR2,
  X_SHOW_PERIOD_DETAILS in VARCHAR2,
  X_PERIOD_CATEGORY_NAME in VARCHAR2,
  X_PERIOD_CATEGORY_DESC in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update CAC_SR_PERIOD_CATS_B set
    FREE_BUSY_TYPE = X_FREE_BUSY_TYPE,
    DISPLAY_COLOR = X_DISPLAY_COLOR,
    SHOW_PERIOD_DETAILS = X_SHOW_PERIOD_DETAILS,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where PERIOD_CATEGORY_ID = X_PERIOD_CATEGORY_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update CAC_SR_PERIOD_CATS_TL set
    PERIOD_CATEGORY_NAME = X_PERIOD_CATEGORY_NAME,
    PERIOD_CATEGORY_DESC = X_PERIOD_CATEGORY_DESC,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where PERIOD_CATEGORY_ID = X_PERIOD_CATEGORY_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_PERIOD_CATEGORY_ID in NUMBER
) is
begin
  delete from CAC_SR_PERIOD_CATS_TL
  where PERIOD_CATEGORY_ID = X_PERIOD_CATEGORY_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from CAC_SR_PERIOD_CATS_B
  where PERIOD_CATEGORY_ID = X_PERIOD_CATEGORY_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from CAC_SR_PERIOD_CATS_TL T
  where not exists
    (select NULL
    from CAC_SR_PERIOD_CATS_B B
    where B.PERIOD_CATEGORY_ID = T.PERIOD_CATEGORY_ID
    );

  update CAC_SR_PERIOD_CATS_TL T set (
      PERIOD_CATEGORY_NAME,
      PERIOD_CATEGORY_DESC
    ) = (select
      B.PERIOD_CATEGORY_NAME,
      B.PERIOD_CATEGORY_DESC
    from CAC_SR_PERIOD_CATS_TL B
    where B.PERIOD_CATEGORY_ID = T.PERIOD_CATEGORY_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.PERIOD_CATEGORY_ID,
      T.LANGUAGE
  ) in (select
      SUBT.PERIOD_CATEGORY_ID,
      SUBT.LANGUAGE
    from CAC_SR_PERIOD_CATS_TL SUBB, CAC_SR_PERIOD_CATS_TL SUBT
    where SUBB.PERIOD_CATEGORY_ID = SUBT.PERIOD_CATEGORY_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.PERIOD_CATEGORY_NAME <> SUBT.PERIOD_CATEGORY_NAME
      or SUBB.PERIOD_CATEGORY_DESC <> SUBT.PERIOD_CATEGORY_DESC
      or (SUBB.PERIOD_CATEGORY_DESC is null and SUBT.PERIOD_CATEGORY_DESC is not null)
      or (SUBB.PERIOD_CATEGORY_DESC is not null and SUBT.PERIOD_CATEGORY_DESC is null)
  ));

  insert into CAC_SR_PERIOD_CATS_TL (
    PERIOD_CATEGORY_ID,
    PERIOD_CATEGORY_NAME,
    PERIOD_CATEGORY_DESC,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.PERIOD_CATEGORY_ID,
    B.PERIOD_CATEGORY_NAME,
    B.PERIOD_CATEGORY_DESC,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from CAC_SR_PERIOD_CATS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from CAC_SR_PERIOD_CATS_TL T
    where T.PERIOD_CATEGORY_ID = B.PERIOD_CATEGORY_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

/************ Start of addition by SBARAT on 01/03/2006 for bug# 5031486 ***********/
PROCEDURE TRANSLATE_ROW(
  X_PERIOD_CATEGORY_ID    IN NUMBER,
  X_PERIOD_CATEGORY_NAME  IN VARCHAR2,
  X_PERIOD_CATEGORY_DESC  IN VARCHAR2,
  X_OWNER                 IN VARCHAR2)
IS
   l_user_id                 NUMBER := 0;
BEGIN
    IF x_owner = 'SEED'
    THEN
        l_user_id := 1;
    END IF;

    UPDATE cac_sr_period_cats_tl
      SET period_category_name = NVL(X_PERIOD_CATEGORY_NAME, period_category_name ) ,
          period_category_desc = NVL(X_PERIOD_CATEGORY_DESC, period_category_desc),
          last_updated_by      = l_user_id,
          last_update_date     = sysdate,
          last_update_login    = 0,
          source_lang          = USERENV ('LANG')
      WHERE period_category_id = x_period_category_id
        And USERENV('LANG') In (LANGUAGE, SOURCE_LANG);

    IF (SQL%NOTFOUND)
    THEN
        Raise NO_DATA_FOUND;
    END IF;

END TRANSLATE_ROW;


PROCEDURE LOAD_ROW (
 X_PERIOD_CATEGORY_ID              IN NUMBER,
 X_FREE_BUSY_TYPE                  IN VARCHAR2,
 X_DISPLAY_COLOR                   IN VARCHAR2,
 X_SHOW_PERIOD_DETAILS             IN VARCHAR2,
 X_PERIOD_CATEGORY_NAME            IN VARCHAR2,
 X_PERIOD_CATEGORY_DESC            IN VARCHAR2,
 X_OWNER                           IN VARCHAR2
 )
IS
    l_user_id                 NUMBER := 0;
    l_period_category_id      NUMBER;
    l_rowid                   ROWID;
BEGIN

    IF x_owner = 'SEED'
    THEN
        l_user_id := 1;
    END IF;


    SELECT period_category_id
       INTO l_period_category_id
       FROM cac_sr_period_cats_b
          WHERE period_category_id = x_period_category_id;


     UPDATE cac_sr_period_cats_b
       SET free_busy_type        = x_free_busy_type,
           display_color         = x_display_color,
           show_period_details   = x_show_period_details,
           last_updated_by       = l_user_id,
           last_update_date      = sysdate,
           last_update_login     = 0
       WHERE period_category_id  = l_period_category_id;

     UPDATE cac_sr_period_cats_tl
       SET period_category_name = x_period_category_name,
           period_category_desc = x_period_category_desc,
           last_updated_by      = l_user_id,
           last_update_date     = sysdate,
           last_update_login    = 0,
           source_lang          = USERENV ('LANG')
       WHERE period_category_id = l_period_category_id
         And USERENV ('LANG') In (LANGUAGE, SOURCE_LANG);

EXCEPTION
   WHEN no_data_found THEN
     CAC_SR_PERIOD_CATS_PKG.INSERT_ROW
           (
            x_rowid                => l_rowid ,
            x_period_category_id   => x_period_category_id,
            x_free_busy_type       => x_free_busy_type,
            x_display_color        => x_display_color,
            x_show_period_details  => x_show_period_details,
            x_period_category_name => x_period_category_name,
            x_period_category_desc => x_period_category_desc,
            x_creation_date        => SYSDATE,
            x_created_by           => l_user_id,
            x_last_update_date     => SYSDATE,
            x_last_updated_by      => l_user_id,
            x_last_update_login    => 0
          );

END LOAD_ROW ;
/************ End of addition by SBARAT on 01/03/2006 for bug# 5031486 ***********/

end CAC_SR_PERIOD_CATS_PKG;

/
