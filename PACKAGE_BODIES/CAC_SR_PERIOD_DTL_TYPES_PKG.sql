--------------------------------------------------------
--  DDL for Package Body CAC_SR_PERIOD_DTL_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CAC_SR_PERIOD_DTL_TYPES_PKG" as
/* $Header: cacsrprddtltypb.pls 120.1 2006/03/01 02:04:20 sbarat noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_PERIOD_DTL_TYPE_ID in NUMBER,
  X_DISPLAY_COLOR in VARCHAR2,
  X_PERIOD_DTL_TYPE_NAME in VARCHAR2,
  X_PERIOD_DTL_TYPE_DESC in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from CAC_SR_PERIOD_DTL_TYPES_B
    where PERIOD_DTL_TYPE_ID = X_PERIOD_DTL_TYPE_ID
    ;
begin
  insert into CAC_SR_PERIOD_DTL_TYPES_B (
    PERIOD_DTL_TYPE_ID,
    DISPLAY_COLOR,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_PERIOD_DTL_TYPE_ID,
    X_DISPLAY_COLOR,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into CAC_SR_PERIOD_DTL_TYPES_TL (
    PERIOD_DTL_TYPE_ID,
    PERIOD_DTL_TYPE_NAME,
    PERIOD_DTL_TYPE_DESC,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_PERIOD_DTL_TYPE_ID,
    X_PERIOD_DTL_TYPE_NAME,
    X_PERIOD_DTL_TYPE_DESC,
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
    from CAC_SR_PERIOD_DTL_TYPES_TL T
    where T.PERIOD_DTL_TYPE_ID = X_PERIOD_DTL_TYPE_ID
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
  X_PERIOD_DTL_TYPE_ID in NUMBER,
  X_DISPLAY_COLOR in VARCHAR2,
  X_PERIOD_DTL_TYPE_NAME in VARCHAR2,
  X_PERIOD_DTL_TYPE_DESC in VARCHAR2
) is
  cursor c is select
      DISPLAY_COLOR
    from CAC_SR_PERIOD_DTL_TYPES_B
    where PERIOD_DTL_TYPE_ID = X_PERIOD_DTL_TYPE_ID
    for update of PERIOD_DTL_TYPE_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      PERIOD_DTL_TYPE_NAME,
      PERIOD_DTL_TYPE_DESC,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from CAC_SR_PERIOD_DTL_TYPES_TL
    where PERIOD_DTL_TYPE_ID = X_PERIOD_DTL_TYPE_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of PERIOD_DTL_TYPE_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.DISPLAY_COLOR = X_DISPLAY_COLOR)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.PERIOD_DTL_TYPE_NAME = X_PERIOD_DTL_TYPE_NAME)
          AND ((tlinfo.PERIOD_DTL_TYPE_DESC = X_PERIOD_DTL_TYPE_DESC)
               OR ((tlinfo.PERIOD_DTL_TYPE_DESC is null) AND (X_PERIOD_DTL_TYPE_DESC is null)))
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
  X_PERIOD_DTL_TYPE_ID in NUMBER,
  X_DISPLAY_COLOR in VARCHAR2,
  X_PERIOD_DTL_TYPE_NAME in VARCHAR2,
  X_PERIOD_DTL_TYPE_DESC in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update CAC_SR_PERIOD_DTL_TYPES_B set
    DISPLAY_COLOR = X_DISPLAY_COLOR,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where PERIOD_DTL_TYPE_ID = X_PERIOD_DTL_TYPE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update CAC_SR_PERIOD_DTL_TYPES_TL set
    PERIOD_DTL_TYPE_NAME = X_PERIOD_DTL_TYPE_NAME,
    PERIOD_DTL_TYPE_DESC = X_PERIOD_DTL_TYPE_DESC,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where PERIOD_DTL_TYPE_ID = X_PERIOD_DTL_TYPE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_PERIOD_DTL_TYPE_ID in NUMBER
) is
begin
  delete from CAC_SR_PERIOD_DTL_TYPES_TL
  where PERIOD_DTL_TYPE_ID = X_PERIOD_DTL_TYPE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from CAC_SR_PERIOD_DTL_TYPES_B
  where PERIOD_DTL_TYPE_ID = X_PERIOD_DTL_TYPE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from CAC_SR_PERIOD_DTL_TYPES_TL T
  where not exists
    (select NULL
    from CAC_SR_PERIOD_DTL_TYPES_B B
    where B.PERIOD_DTL_TYPE_ID = T.PERIOD_DTL_TYPE_ID
    );

  update CAC_SR_PERIOD_DTL_TYPES_TL T set (
      PERIOD_DTL_TYPE_NAME,
      PERIOD_DTL_TYPE_DESC
    ) = (select
      B.PERIOD_DTL_TYPE_NAME,
      B.PERIOD_DTL_TYPE_DESC
    from CAC_SR_PERIOD_DTL_TYPES_TL B
    where B.PERIOD_DTL_TYPE_ID = T.PERIOD_DTL_TYPE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.PERIOD_DTL_TYPE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.PERIOD_DTL_TYPE_ID,
      SUBT.LANGUAGE
    from CAC_SR_PERIOD_DTL_TYPES_TL SUBB, CAC_SR_PERIOD_DTL_TYPES_TL SUBT
    where SUBB.PERIOD_DTL_TYPE_ID = SUBT.PERIOD_DTL_TYPE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.PERIOD_DTL_TYPE_NAME <> SUBT.PERIOD_DTL_TYPE_NAME
      or SUBB.PERIOD_DTL_TYPE_DESC <> SUBT.PERIOD_DTL_TYPE_DESC
      or (SUBB.PERIOD_DTL_TYPE_DESC is null and SUBT.PERIOD_DTL_TYPE_DESC is not null)
      or (SUBB.PERIOD_DTL_TYPE_DESC is not null and SUBT.PERIOD_DTL_TYPE_DESC is null)
  ));

  insert into CAC_SR_PERIOD_DTL_TYPES_TL (
    PERIOD_DTL_TYPE_ID,
    PERIOD_DTL_TYPE_NAME,
    PERIOD_DTL_TYPE_DESC,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.PERIOD_DTL_TYPE_ID,
    B.PERIOD_DTL_TYPE_NAME,
    B.PERIOD_DTL_TYPE_DESC,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from CAC_SR_PERIOD_DTL_TYPES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from CAC_SR_PERIOD_DTL_TYPES_TL T
    where T.PERIOD_DTL_TYPE_ID = B.PERIOD_DTL_TYPE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

/************ Start of addition by SBARAT on 01/03/2006 for bug# 5031486 ***********/
PROCEDURE TRANSLATE_ROW(
  X_PERIOD_DTL_TYPE_ID    IN NUMBER,
  X_PERIOD_DTL_TYPE_NAME  IN VARCHAR2,
  X_PERIOD_DTL_TYPE_DESC  IN VARCHAR2,
  X_OWNER                 IN VARCHAR2)
IS
   l_user_id                 NUMBER := 0;
BEGIN
    IF x_owner = 'SEED'
    THEN
        l_user_id := 1;
    END IF;

    UPDATE cac_sr_period_dtl_types_tl
      SET period_dtl_type_name = NVL(X_PERIOD_DTL_TYPE_NAME, period_dtl_type_name ) ,
          period_dtl_type_desc = NVL(X_PERIOD_DTL_TYPE_DESC, period_dtl_type_desc),
          last_updated_by      = l_user_id,
          last_update_date     = sysdate,
          last_update_login    = 0,
          source_lang          = USERENV ('LANG')
      WHERE period_dtl_type_id = x_period_dtl_type_id
        And USERENV('LANG') In (LANGUAGE, SOURCE_LANG);

    IF (SQL%NOTFOUND)
    THEN
        Raise NO_DATA_FOUND;
    END IF;

END TRANSLATE_ROW;


PROCEDURE LOAD_ROW (
    X_PERIOD_DTL_TYPE_ID              IN NUMBER,
    X_DISPLAY_COLOR                   IN VARCHAR2,
    X_PERIOD_DTL_TYPE_NAME            IN VARCHAR2,
    X_PERIOD_DTL_TYPE_DESC            IN VARCHAR2,
    X_OWNER                           IN VARCHAR2
    )
IS
    l_user_id                 NUMBER := 0;
    l_period_dtl_type_id      NUMBER;
    l_rowid                   ROWID;
BEGIN

    IF x_owner = 'SEED'
    THEN
        l_user_id := 1;
    END IF;


    SELECT period_dtl_type_id
       INTO l_period_dtl_type_id
       FROM cac_sr_period_dtl_types_b
          WHERE period_dtl_type_id = x_period_dtl_type_id;


     UPDATE cac_sr_period_dtl_types_b
       SET display_color         = x_display_color,
           last_updated_by       = l_user_id,
           last_update_date      = sysdate,
           last_update_login     = 0
       WHERE period_dtl_type_id  = l_period_dtl_type_id;

     UPDATE cac_sr_period_dtl_types_tl
       SET period_dtl_type_name = x_period_dtl_type_name,
           period_dtl_type_desc = x_period_dtl_type_desc,
           last_updated_by      = l_user_id,
           last_update_date     = sysdate,
           last_update_login    = 0,
           source_lang          = USERENV ('LANG')
       WHERE period_dtl_type_id = l_period_dtl_type_id
         And USERENV ('LANG') In (LANGUAGE, SOURCE_LANG);

EXCEPTION
   WHEN no_data_found THEN
     CAC_SR_PERIOD_DTL_TYPES_PKG.INSERT_ROW
           (
            x_rowid                => l_rowid ,
            x_period_dtl_type_id   => x_period_dtl_type_id,
            x_display_color        => x_display_color,
            x_period_dtl_type_name => x_period_dtl_type_name,
            x_period_dtl_type_desc => x_period_dtl_type_desc,
            x_creation_date        => SYSDATE,
            x_created_by           => l_user_id,
            x_last_update_date     => SYSDATE,
            x_last_updated_by      => l_user_id,
            x_last_update_login    => 0
          );

END LOAD_ROW ;
/************ End of addition by SBARAT on 01/03/2006 for bug# 5031486 ***********/

end CAC_SR_PERIOD_DTL_TYPES_PKG;

/
