--------------------------------------------------------
--  DDL for Package Body ZX_DET_FACTOR_TEMPL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_DET_FACTOR_TEMPL_PKG" as
/* $Header: zxddetfactorb.pls 120.4 2005/03/14 10:26:04 scsharma ship $ */

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_DET_FACTOR_TEMPL_ID in NUMBER,
  X_DET_FACTOR_TEMPL_CODE in VARCHAR2,
  X_TAX_REGIME_CODE in VARCHAR2,
  X_LEDGER_ID in NUMBER,
  X_CHART_OF_ACCOUNTS_ID in NUMBER,
  X_Template_Usage_Code in VARCHAR2,
  X_Record_Type_Code in VARCHAR2,
  X_REQUEST_ID in NUMBER,
  X_DET_FACTOR_TEMPL_NAME in VARCHAR2,
  X_DET_FACTOR_TEMPL_DESC in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_PROGRAM_APPLICATION_ID in NUMBER,
  X_PROGRAM_ID in NUMBER,
  X_PROGRAM_LOGIN_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER) is

  cursor C is select ROWID from ZX_DET_FACTOR_TEMPL_B
    where DET_FACTOR_TEMPL_ID = X_DET_FACTOR_TEMPL_ID;
begin
  insert into ZX_DET_FACTOR_TEMPL_B (
    DET_FACTOR_TEMPL_ID,
    DET_FACTOR_TEMPL_CODE,
    TAX_REGIME_CODE,
    LEDGER_ID,
    CHART_OF_ACCOUNTS_ID,
    Template_Usage_Code,
    Record_Type_Code,
    REQUEST_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    PROGRAM_APPLICATION_ID,
    PROGRAM_ID,
    PROGRAM_LOGIN_ID,
    OBJECT_VERSION_NUMBER)
  values (
    X_DET_FACTOR_TEMPL_ID,
    X_DET_FACTOR_TEMPL_CODE,
    X_TAX_REGIME_CODE,
    X_LEDGER_ID,
    X_CHART_OF_ACCOUNTS_ID,
    X_Template_Usage_Code,
    X_Record_Type_Code,
    X_REQUEST_ID,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_PROGRAM_APPLICATION_ID,
    X_PROGRAM_ID,
    X_PROGRAM_LOGIN_ID,
    X_OBJECT_VERSION_NUMBER);

  insert into ZX_DET_FACTOR_TEMPL_TL (
    DET_FACTOR_TEMPL_ID,
    DET_FACTOR_TEMPL_NAME,
    DET_FACTOR_TEMPL_DESC,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG)
  select
    X_DET_FACTOR_TEMPL_ID,
    X_DET_FACTOR_TEMPL_NAME,
    X_DET_FACTOR_TEMPL_DESC,
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
    from ZX_DET_FACTOR_TEMPL_TL T
    where T.DET_FACTOR_TEMPL_ID = X_DET_FACTOR_TEMPL_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

 EXCEPTION
      WHEN OTHERS THEN
        APP_EXCEPTION.RAISE_EXCEPTION;

end INSERT_ROW;

procedure LOCK_ROW (
  X_DET_FACTOR_TEMPL_ID in NUMBER,
  X_DET_FACTOR_TEMPL_CODE in VARCHAR2,
  X_TAX_REGIME_CODE in VARCHAR2,
  X_LEDGER_ID in NUMBER,
  X_CHART_OF_ACCOUNTS_ID in NUMBER,
  X_Template_Usage_Code in VARCHAR2,
  X_Record_Type_Code in VARCHAR2,
  X_REQUEST_ID in NUMBER,
  X_PROGRAM_APPLICATION_ID in NUMBER,
  X_PROGRAM_ID in NUMBER,
  X_PROGRAM_LOGIN_ID in NUMBER,
  X_DET_FACTOR_TEMPL_NAME in VARCHAR2,
  X_DET_FACTOR_TEMPL_DESC in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER) is

  cursor c is select DET_FACTOR_TEMPL_CODE,
                     TAX_REGIME_CODE,
                     LEDGER_ID,
                     CHART_OF_ACCOUNTS_ID,
                     Template_Usage_Code,
                     Record_Type_Code,
                     REQUEST_ID,
                     PROGRAM_APPLICATION_ID,
                     PROGRAM_ID,
                     PROGRAM_LOGIN_ID
                from ZX_DET_FACTOR_TEMPL_B
               where DET_FACTOR_TEMPL_ID = X_DET_FACTOR_TEMPL_ID
                 for update of DET_FACTOR_TEMPL_ID nowait;

  recinfo c%rowtype;

  cursor c1 is select DET_FACTOR_TEMPL_NAME,
                      DET_FACTOR_TEMPL_DESC,
                      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
                 from ZX_DET_FACTOR_TEMPL_TL
                where DET_FACTOR_TEMPL_ID = X_DET_FACTOR_TEMPL_ID
                  and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
                  for update of DET_FACTOR_TEMPL_ID nowait;
begin

  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;

  if (  (recinfo.DET_FACTOR_TEMPL_CODE = X_DET_FACTOR_TEMPL_CODE)
      AND ((recinfo.TAX_REGIME_CODE = X_TAX_REGIME_CODE)
           OR ((recinfo.TAX_REGIME_CODE is null) AND (X_TAX_REGIME_CODE is null)))
      AND ((recinfo.LEDGER_ID = X_LEDGER_ID)
           OR ((recinfo.LEDGER_ID is null) AND (X_LEDGER_ID is null)))
      AND ((recinfo.CHART_OF_ACCOUNTS_ID = X_CHART_OF_ACCOUNTS_ID)
           OR ((recinfo.CHART_OF_ACCOUNTS_ID is null) AND (X_CHART_OF_ACCOUNTS_ID is null)))
      AND (recinfo.Template_Usage_Code = X_Template_Usage_Code)
      AND (recinfo.Record_Type_Code = X_Record_Type_Code)
      AND ((recinfo.REQUEST_ID = X_REQUEST_ID)
           OR ((recinfo.REQUEST_ID is null) AND (X_REQUEST_ID is null)))
      AND ((recinfo.PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID)
           OR ((recinfo.PROGRAM_APPLICATION_ID is null) AND (X_PROGRAM_APPLICATION_ID is null)))
      AND ((recinfo. PROGRAM_ID = X_PROGRAM_ID)
           OR ((recinfo.PROGRAM_ID is null) AND (X_PROGRAM_ID is null)))
      AND ((recinfo.PROGRAM_LOGIN_ID = X_PROGRAM_LOGIN_ID)
           OR ((recinfo.PROGRAM_LOGIN_ID is null) AND (X_PROGRAM_LOGIN_ID is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.DET_FACTOR_TEMPL_NAME = X_DET_FACTOR_TEMPL_NAME)
          AND ((tlinfo.DET_FACTOR_TEMPL_DESC = X_DET_FACTOR_TEMPL_DESC)
               OR ((tlinfo.DET_FACTOR_TEMPL_DESC is null) AND (X_DET_FACTOR_TEMPL_DESC is null)))
      ) then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
    end if;
  end loop;
  return;

 EXCEPTION
      WHEN OTHERS THEN
        APP_EXCEPTION.RAISE_EXCEPTION;

end LOCK_ROW;

procedure UPDATE_ROW (
  X_DET_FACTOR_TEMPL_ID in NUMBER,
  X_DET_FACTOR_TEMPL_CODE in VARCHAR2,
  X_TAX_REGIME_CODE in VARCHAR2,
  X_LEDGER_ID in NUMBER,
  X_CHART_OF_ACCOUNTS_ID in NUMBER,
  X_Template_Usage_Code in VARCHAR2,
  X_Record_Type_Code in VARCHAR2,
  X_REQUEST_ID in NUMBER,
  X_DET_FACTOR_TEMPL_NAME in VARCHAR2,
  X_DET_FACTOR_TEMPL_DESC in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_PROGRAM_APPLICATION_ID in NUMBER,
  X_PROGRAM_ID in NUMBER,
  X_PROGRAM_LOGIN_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER) is
begin

  update ZX_DET_FACTOR_TEMPL_B set
    DET_FACTOR_TEMPL_CODE  = X_DET_FACTOR_TEMPL_CODE,
    TAX_REGIME_CODE        = X_TAX_REGIME_CODE,
    LEDGER_ID              = X_LEDGER_ID,
    CHART_OF_ACCOUNTS_ID   = X_CHART_OF_ACCOUNTS_ID,
    Template_Usage_Code         = X_Template_Usage_Code,
    Record_Type_Code            = X_Record_Type_Code,
    REQUEST_ID             = X_REQUEST_ID,
    LAST_UPDATE_DATE       = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY        = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN      = X_LAST_UPDATE_LOGIN,
    PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
    PROGRAM_ID             = X_PROGRAM_ID,
    PROGRAM_LOGIN_ID       = X_PROGRAM_LOGIN_ID,
    OBJECT_VERSION_NUMBER  = X_OBJECT_VERSION_NUMBER
  where DET_FACTOR_TEMPL_ID = X_DET_FACTOR_TEMPL_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update ZX_DET_FACTOR_TEMPL_TL set
    DET_FACTOR_TEMPL_NAME = X_DET_FACTOR_TEMPL_NAME,
    DET_FACTOR_TEMPL_DESC = X_DET_FACTOR_TEMPL_DESC,
    LAST_UPDATE_DATE      = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY       = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN     = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG           = userenv('LANG')
  where DET_FACTOR_TEMPL_ID = X_DET_FACTOR_TEMPL_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;

 EXCEPTION
      WHEN OTHERS THEN
        APP_EXCEPTION.RAISE_EXCEPTION;

end UPDATE_ROW;

procedure DELETE_ROW (
  X_DET_FACTOR_TEMPL_ID in NUMBER) is
begin

  delete from ZX_DET_FACTOR_TEMPL_TL
  where DET_FACTOR_TEMPL_ID = X_DET_FACTOR_TEMPL_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from ZX_DET_FACTOR_TEMPL_B
  where DET_FACTOR_TEMPL_ID = X_DET_FACTOR_TEMPL_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

 EXCEPTION
      WHEN OTHERS THEN
        APP_EXCEPTION.RAISE_EXCEPTION;

end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin

  delete from ZX_DET_FACTOR_TEMPL_TL T
  where not exists (select NULL
                      from ZX_DET_FACTOR_TEMPL_B B
                     where B.DET_FACTOR_TEMPL_ID = T.DET_FACTOR_TEMPL_ID);

  update ZX_DET_FACTOR_TEMPL_TL T
     set (DET_FACTOR_TEMPL_NAME, DET_FACTOR_TEMPL_DESC) =
             (select B.DET_FACTOR_TEMPL_NAME,
                     B.DET_FACTOR_TEMPL_DESC
                from ZX_DET_FACTOR_TEMPL_TL B
               where B.DET_FACTOR_TEMPL_ID = T.DET_FACTOR_TEMPL_ID
                 and B.LANGUAGE = T.SOURCE_LANG)
  where (T.DET_FACTOR_TEMPL_ID, T.LANGUAGE) in
 (select SUBT.DET_FACTOR_TEMPL_ID,
         SUBT.LANGUAGE
    from ZX_DET_FACTOR_TEMPL_TL SUBB, ZX_DET_FACTOR_TEMPL_TL SUBT
   where SUBB.DET_FACTOR_TEMPL_ID = SUBT.DET_FACTOR_TEMPL_ID
     and SUBB.LANGUAGE = SUBT.SOURCE_LANG
     and (SUBB.DET_FACTOR_TEMPL_NAME <> SUBT.DET_FACTOR_TEMPL_NAME
          or SUBB.DET_FACTOR_TEMPL_DESC <> SUBT.DET_FACTOR_TEMPL_DESC
          or (SUBB.DET_FACTOR_TEMPL_DESC is null
         and SUBT.DET_FACTOR_TEMPL_DESC is not null)
      or (SUBB.DET_FACTOR_TEMPL_DESC is not null
         and SUBT.DET_FACTOR_TEMPL_DESC is null)));

  insert into ZX_DET_FACTOR_TEMPL_TL (DET_FACTOR_TEMPL_ID,
                                      DET_FACTOR_TEMPL_NAME,
                                      DET_FACTOR_TEMPL_DESC,
                                      CREATION_DATE,
                                      CREATED_BY,
                                      LAST_UPDATE_DATE,
                                      LAST_UPDATED_BY,
                                      LAST_UPDATE_LOGIN,
                                      LANGUAGE,
                                      SOURCE_LANG)
                               select B.DET_FACTOR_TEMPL_ID,
                                      B.DET_FACTOR_TEMPL_NAME,
                                      B.DET_FACTOR_TEMPL_DESC,
                                      B.CREATION_DATE,
                                      B.CREATED_BY,
                                      B.LAST_UPDATE_DATE,
                                      B.LAST_UPDATED_BY,
                                      B.LAST_UPDATE_LOGIN,
                                      L.LANGUAGE_CODE,
                                      B.SOURCE_LANG
                                 from ZX_DET_FACTOR_TEMPL_TL B,
                                      FND_LANGUAGES L
                                where L.INSTALLED_FLAG in ('I', 'B')
                                  and B.LANGUAGE = userenv('LANG')
                                  and not exists
                                     (select NULL
                                        from ZX_DET_FACTOR_TEMPL_TL T
                                       where T.DET_FACTOR_TEMPL_ID =
                                                        B.DET_FACTOR_TEMPL_ID
                                        and T.LANGUAGE = L.LANGUAGE_CODE);

 EXCEPTION
      WHEN OTHERS THEN
        APP_EXCEPTION.RAISE_EXCEPTION;

end ADD_LANGUAGE;

procedure bulk_insert_det_factor_templ (
  X_DET_FACTOR_TEMPL_ID       IN t_det_factor_templ_id,
  X_DET_FACTOR_TEMPL_CODE     IN t_det_factor_templ_code,
  X_TAX_REGIME_CODE           IN t_tax_regime_code,
  X_LEDGER_ID                 IN t_ledger_id,
  X_CHART_OF_ACCOUNTS_ID      IN t_chart_of_accounts_id,
  X_Template_Usage_Code            IN t_template_usage,
  X_Record_Type_Code               IN t_record_type,
  X_DET_FACTOR_TEMPL_NAME     IN t_det_factor_templ_name,
  X_DET_FACTOR_TEMPL_DESC     IN t_det_factor_templ_desc) is

begin

  if x_det_factor_templ_id.count <> 0 then
     forall i in x_det_factor_templ_id.first..x_det_factor_templ_id.last
       insert into ZX_DET_FACTOR_TEMPL_B (DET_FACTOR_TEMPL_ID,
                                          DET_FACTOR_TEMPL_CODE,
                                          TAX_REGIME_CODE,
                                          LEDGER_ID,
                                          CHART_OF_ACCOUNTS_ID,
                                          Template_Usage_Code,
                                          Record_Type_Code,
                                          CREATED_BY             ,
                                          CREATION_DATE          ,
                                          LAST_UPDATED_BY        ,
                                          LAST_UPDATE_DATE       ,
                                          LAST_UPDATE_LOGIN      ,
                                          REQUEST_ID             ,
                                          PROGRAM_APPLICATION_ID ,
                                          PROGRAM_ID             ,
                                          PROGRAM_LOGIN_ID)
                                  values (X_DET_FACTOR_TEMPL_ID(i),
                                          X_DET_FACTOR_TEMPL_CODE(i),
                                          X_TAX_REGIME_CODE(i),
                                          X_LEDGER_ID(i),
                                          X_CHART_OF_ACCOUNTS_ID(i),
                                          X_Template_Usage_Code(i),
                                          X_Record_Type_Code(i),
                                          fnd_global.user_id         ,
                                          sysdate                    ,
                                          fnd_global.user_id         ,
                                          sysdate                    ,
                                          fnd_global.conc_login_id   ,
                                          fnd_global.conc_request_id ,
                                          fnd_global.prog_appl_id    ,
                                          fnd_global.conc_program_id ,
                                          fnd_global.conc_login_id
                                          );

     forall i in x_det_factor_templ_id.first..x_det_factor_templ_id.last
       insert into ZX_DET_FACTOR_TEMPL_TL (DET_FACTOR_TEMPL_ID,
                                           DET_FACTOR_TEMPL_NAME,
                                           DET_FACTOR_TEMPL_DESC,
                                           LANGUAGE,
                                           SOURCE_LANG,
                                           CREATED_BY             ,
                                           CREATION_DATE          ,
                                           LAST_UPDATED_BY        ,
                                           LAST_UPDATE_DATE       ,
                                           LAST_UPDATE_LOGIN)
                                    select X_DET_FACTOR_TEMPL_ID(i),
                                           X_DET_FACTOR_TEMPL_NAME(i),
                                           X_DET_FACTOR_TEMPL_DESC(i),
                                           L.LANGUAGE_CODE,
                                           userenv('LANG'),
                                           fnd_global.user_id         ,
                                           sysdate                    ,
                                           fnd_global.user_id         ,
                                           sysdate                    ,
                                           fnd_global.conc_login_id
                                      from FND_LANGUAGES L
                                     where L.INSTALLED_FLAG in ('I', 'B')
                                       and not exists
                                         (select NULL
                                            from ZX_DET_FACTOR_TEMPL_TL T
                                           where T.DET_FACTOR_TEMPL_ID =
                                                   X_DET_FACTOR_TEMPL_ID(i)
                                             and T.LANGUAGE = L.LANGUAGE_CODE);
  end if;

 EXCEPTION
      WHEN OTHERS THEN
        APP_EXCEPTION.RAISE_EXCEPTION;

end bulk_insert_det_factor_templ;

end ZX_DET_FACTOR_TEMPL_PKG;

/
