--------------------------------------------------------
--  DDL for Package Body PA_FIN_PLAN_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FIN_PLAN_TYPES_PKG" as
/* $Header: PAFPTYPB.pls 120.4 2007/02/06 10:11:49 dthakker noship $ */
procedure INSERT_ROW (
  X_ROWID                             in out NOCOPY ROWID, --File.Sql.39 bug 4440895
  X_FIN_PLAN_TYPE_ID                  in NUMBER,
  X_FIN_PLAN_TYPE_CODE                in VARCHAR2,
  X_PRE_DEFINED_FLAG                  in VARCHAR2,
  X_GENERATED_FLAG                    in VARCHAR2,
  X_EDIT_GENERATED_AMT_FLAG           in VARCHAR2,
  X_USED_IN_BILLING_FLAG              in VARCHAR2,
  X_ENABLE_WF_FLAG                    in VARCHAR2,
  X_START_DATE_ACTIVE                 in DATE,
  X_END_DATE_ACTIVE                   in DATE,
  X_RECORD_VERSION_NUMBER             in NUMBER,
  X_NAME                              in VARCHAR2,
  X_DESCRIPTION                       in VARCHAR2,
  X_PLAN_CLASS_CODE                   in VARCHAR2 ,
  X_APPROVED_COST_PLAN_TYPE_FLAG      in VARCHAR2 ,
  X_APPROVED_REV_PLAN_TYPE_FLAG       in VARCHAR2 ,
  X_PROJFUNC_COST_RATE_TYPE           in VARCHAR2 ,
  X_PROJFUNC_COST_RATE_DATE_TYPE      in VARCHAR2 ,
  X_PROJFUNC_COST_RATE_DATE           in DATE     ,
  X_PROJFUNC_REV_RATE_TYPE            in VARCHAR2 ,
  X_PROJFUNC_REV_RATE_DATE_TYPE       in VARCHAR2 ,
  X_PROJFUNC_REV_RATE_DATE            in DATE     ,
  X_PROJECT_COST_RATE_TYPE            in VARCHAR2 ,
  X_PROJECT_COST_RATE_DATE_TYPE       in VARCHAR2 ,
  X_PROJECT_COST_RATE_DATE            in DATE     ,
  X_PROJECT_REV_RATE_TYPE             in VARCHAR2 ,
  X_PROJECT_REV_RATE_DATE_TYPE        in VARCHAR2 ,
  X_PROJECT_REV_RATE_DATE             in DATE     ,
  X_ATTRIBUTE_CATEGORY                in VARCHAR2 ,
  X_ATTRIBUTE1                        in VARCHAR2 ,
  X_ATTRIBUTE2                        in VARCHAR2 ,
  X_ATTRIBUTE3                        in VARCHAR2 ,
  X_ATTRIBUTE4                        in VARCHAR2 ,
  X_ATTRIBUTE5                        in VARCHAR2 ,
  X_ATTRIBUTE6                        in VARCHAR2 ,
  X_ATTRIBUTE7                        in VARCHAR2 ,
  X_ATTRIBUTE8                        in VARCHAR2 ,
  X_ATTRIBUTE9                        in VARCHAR2 ,
  X_ATTRIBUTE10                       in VARCHAR2 ,
  X_ATTRIBUTE11                       in VARCHAR2 ,
  X_ATTRIBUTE12                       in VARCHAR2 ,
  X_ATTRIBUTE13                       in VARCHAR2 ,
  X_ATTRIBUTE14                       in VARCHAR2 ,
  X_ATTRIBUTE15                       in VARCHAR2 ,
  X_CREATION_DATE                     in DATE     ,
  X_CREATED_BY                        in NUMBER   ,
  X_LAST_UPDATE_DATE                  in DATE     ,
  X_LAST_UPDATED_BY                   in NUMBER   ,
  X_LAST_UPDATE_LOGIN                 in NUMBER   ,
  X_MIGRATED_FRM_BDGT_TYP_CODE         in VARCHAR2 default null,
  /* dbora --- FP M --13-NOV-03 :Introduced the following additional parameters to check for different set up options
  */
  X_ENABLE_PARTIAL_IMPL_FLAG         IN   PA_FIN_PLAN_TYPES_B.ENABLE_PARTIAL_IMPL_FLAG%TYPE,
  X_PRIMARY_COST_FORECAST_FLAG       IN   PA_FIN_PLAN_TYPES_B.PRIMARY_COST_FORECAST_FLAG%TYPE,
  X_PRIMARY_REV_FORECAST_FLAG        IN   PA_FIN_PLAN_TYPES_B.PRIMARY_REV_FORECAST_FLAG%TYPE,
  X_EDIT_AFTER_BASELINE_FLAG         IN   PA_FIN_PLAN_TYPES_B.EDIT_AFTER_BASELINE_FLAG%TYPE,
  X_USE_FOR_WORKPLAN_FLAG            IN   PA_FIN_PLAN_TYPES_B.USE_FOR_WORKPLAN_FLAG%TYPE)
  is

  l_fin_plan_type_id pa_Fin_plan_types_b.fin_plan_type_id%type;

  nc_ROWID                           ROWID;

  cursor C is select ROWID from PA_FIN_PLAN_TYPES_B
    where FIN_PLAN_TYPE_ID = L_FIN_PLAN_TYPE_ID;
begin
  nc_ROWID := X_ROWID;

  select nvl(X_FIN_PLAN_TYPE_ID,PA_FIN_PLAN_TYPES_S.nextval)
  into   L_FIN_PLAN_TYPE_ID
  from   dual;

  insert into PA_FIN_PLAN_TYPES_B (
    FIN_PLAN_TYPE_ID              ,
    FIN_PLAN_TYPE_CODE            ,
    PRE_DEFINED_FLAG              ,
    GENERATED_FLAG                ,
    EDIT_GENERATED_AMT_FLAG       ,
    USED_IN_BILLING_FLAG          ,
    ENABLE_WF_FLAG                ,
    START_DATE_ACTIVE             ,
    END_DATE_ACTIVE               ,
    RECORD_VERSION_NUMBER         ,
    PLAN_CLASS_CODE               ,
    APPROVED_COST_PLAN_TYPE_FLAG  ,
    APPROVED_REV_PLAN_TYPE_FLAG   ,
    PROJFUNC_COST_RATE_TYPE       ,
    PROJFUNC_COST_RATE_DATE_TYPE  ,
    PROJFUNC_COST_RATE_DATE       ,
    PROJFUNC_REV_RATE_TYPE        ,
    PROJFUNC_REV_RATE_DATE_TYPE   ,
    PROJFUNC_REV_RATE_DATE        ,
    PROJECT_COST_RATE_TYPE        ,
    PROJECT_COST_RATE_DATE_TYPE   ,
    PROJECT_COST_RATE_DATE        ,
    PROJECT_REV_RATE_TYPE         ,
    PROJECT_REV_RATE_DATE_TYPE    ,
    PROJECT_REV_RATE_DATE         ,
    ATTRIBUTE_CATEGORY            ,
    ATTRIBUTE1                    ,
    ATTRIBUTE2                    ,
    ATTRIBUTE3                    ,
    ATTRIBUTE4                    ,
    ATTRIBUTE5                    ,
    ATTRIBUTE6                    ,
    ATTRIBUTE7                    ,
    ATTRIBUTE8                    ,
    ATTRIBUTE9                    ,
    ATTRIBUTE10                   ,
    ATTRIBUTE11                   ,
    ATTRIBUTE12                   ,
    ATTRIBUTE13                   ,
    ATTRIBUTE14                   ,
    ATTRIBUTE15                   ,
    CREATION_DATE                 ,
    CREATED_BY                    ,
    LAST_UPDATE_DATE              ,
    LAST_UPDATED_BY               ,
    LAST_UPDATE_LOGIN             ,
    MIGRATED_FRM_BDGT_TYP_CODE,
    /* dbora --- FP M - 13-NOV-03
     */
    ENABLE_PARTIAL_IMPL_FLAG ,
    PRIMARY_COST_FORECAST_FLAG,
    PRIMARY_REV_FORECAST_FLAG,
    EDIT_AFTER_BASELINE_FLAG,
    USE_FOR_WORKPLAN_FLAG
  ) values (
    L_FIN_PLAN_TYPE_ID                   ,
    X_FIN_PLAN_TYPE_CODE                 ,
    X_PRE_DEFINED_FLAG                   ,
    X_GENERATED_FLAG                     ,
    decode(X_GENERATED_FLAG,'N','N',X_EDIT_GENERATED_AMT_FLAG),
    X_USED_IN_BILLING_FLAG               ,
    X_ENABLE_WF_FLAG                     ,
    X_START_DATE_ACTIVE                  ,
    X_END_DATE_ACTIVE                    ,
    1                                    ,
    X_PLAN_CLASS_CODE                    ,
    X_APPROVED_COST_PLAN_TYPE_FLAG       ,
    X_APPROVED_REV_PLAN_TYPE_FLAG        ,
    X_PROJFUNC_COST_RATE_TYPE            ,
    X_PROJFUNC_COST_RATE_DATE_TYPE       ,
    X_PROJFUNC_COST_RATE_DATE            ,
    X_PROJFUNC_REV_RATE_TYPE             ,
    X_PROJFUNC_REV_RATE_DATE_TYPE        ,
    X_PROJFUNC_REV_RATE_DATE             ,
    X_PROJECT_COST_RATE_TYPE             ,
    X_PROJECT_COST_RATE_DATE_TYPE        ,
    X_PROJECT_COST_RATE_DATE             ,
    X_PROJECT_REV_RATE_TYPE              ,
    X_PROJECT_REV_RATE_DATE_TYPE         ,
    X_PROJECT_REV_RATE_DATE              ,
    X_ATTRIBUTE_CATEGORY                 ,
    X_ATTRIBUTE1                         ,
    X_ATTRIBUTE2                         ,
    X_ATTRIBUTE3                         ,
    X_ATTRIBUTE4                         ,
    X_ATTRIBUTE5                         ,
    X_ATTRIBUTE6                         ,
    X_ATTRIBUTE7                         ,
    X_ATTRIBUTE8                         ,
    X_ATTRIBUTE9                         ,
    X_ATTRIBUTE10                        ,
    X_ATTRIBUTE11                        ,
    X_ATTRIBUTE12                        ,
    X_ATTRIBUTE13                        ,
    X_ATTRIBUTE14                        ,
    X_ATTRIBUTE15                        ,
    X_CREATION_DATE                      ,
    X_CREATED_BY                         ,
    X_LAST_UPDATE_DATE                   ,
    X_LAST_UPDATED_BY                    ,
    X_LAST_UPDATE_LOGIN                  ,
    X_MIGRATED_FRM_BDGT_TYP_CODE,
    /* dbora --- FP M - 13-NOV-03
     */
    NVL (X_ENABLE_PARTIAL_IMPL_FLAG , 'N'),
    NVL (X_PRIMARY_COST_FORECAST_FLAG,'N'),
    NVL (X_PRIMARY_REV_FORECAST_FLAG, 'N'),
    NVL (X_EDIT_AFTER_BASELINE_FLAG,'N'),
    NVL (X_USE_FOR_WORKPLAN_FLAG,     'N')
  );

  insert into PA_FIN_PLAN_TYPES_TL (
    LAST_UPDATE_LOGIN,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    FIN_PLAN_TYPE_ID,
    NAME,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_LAST_UPDATE_LOGIN,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    L_FIN_PLAN_TYPE_ID,
    X_NAME,
    X_DESCRIPTION,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from PA_FIN_PLAN_TYPES_TL T
    where T.FIN_PLAN_TYPE_ID = L_FIN_PLAN_TYPE_ID
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
	    X_ROWID := nc_ROWID;
        RAISE;

end INSERT_ROW;

procedure LOCK_ROW (
  X_FIN_PLAN_TYPE_ID                  in NUMBER,
  X_FIN_PLAN_TYPE_CODE                in VARCHAR2 default null,
  X_PRE_DEFINED_FLAG                  in VARCHAR2 default null,
  X_GENERATED_FLAG                    in VARCHAR2 default null,
  X_EDIT_GENERATED_AMT_FLAG           in VARCHAR2 default null,
  X_USED_IN_BILLING_FLAG              in VARCHAR2 default null,
  X_ENABLE_WF_FLAG                    in VARCHAR2 default null,
  X_START_DATE_ACTIVE                 in DATE default null,
  X_END_DATE_ACTIVE                   in DATE default null,
  X_RECORD_VERSION_NUMBER             in NUMBER,
  X_NAME                              in VARCHAR2 default null,
  X_DESCRIPTION                       in VARCHAR2 default null,
  X_PLAN_CLASS_CODE                   in VARCHAR2 default null,
  X_APPROVED_COST_PLAN_TYPE_FLAG      in VARCHAR2 default null,
  X_APPROVED_REV_PLAN_TYPE_FLAG       in VARCHAR2 default null,
  X_PROJFUNC_COST_RATE_TYPE           in VARCHAR2 default null,
  X_PROJFUNC_COST_RATE_DATE_TYPE      in VARCHAR2 default null,
  X_PROJFUNC_COST_RATE_DATE           in DATE     default null,
  X_PROJFUNC_REV_RATE_TYPE            in VARCHAR2 default null,
  X_PROJFUNC_REV_RATE_DATE_TYPE       in VARCHAR2 default null,
  X_PROJFUNC_REV_RATE_DATE            in DATE     default null,
  X_PROJECT_COST_RATE_TYPE            in VARCHAR2 default null,
  X_PROJECT_COST_RATE_DATE_TYPE       in VARCHAR2 default null,
  X_PROJECT_COST_RATE_DATE            in DATE     default null,
  X_PROJECT_REV_RATE_TYPE             in VARCHAR2 default null,
  X_PROJECT_REV_RATE_DATE_TYPE        in VARCHAR2 default null,
  X_PROJECT_REV_RATE_DATE             in DATE     default null,
  X_ATTRIBUTE_CATEGORY                in VARCHAR2 default null,
  X_ATTRIBUTE1                        in VARCHAR2 default null,
  X_ATTRIBUTE2                        in VARCHAR2 default null,
  X_ATTRIBUTE3                        in VARCHAR2 default null,
  X_ATTRIBUTE4                        in VARCHAR2 default null,
  X_ATTRIBUTE5                        in VARCHAR2 default null,
  X_ATTRIBUTE6                        in VARCHAR2 default null,
  X_ATTRIBUTE7                        in VARCHAR2 default null,
  X_ATTRIBUTE8                        in VARCHAR2 default null,
  X_ATTRIBUTE9                        in VARCHAR2 default null,
  X_ATTRIBUTE10                       in VARCHAR2 default null,
  X_ATTRIBUTE11                       in VARCHAR2 default null,
  X_ATTRIBUTE12                       in VARCHAR2 default null,
  X_ATTRIBUTE13                       in VARCHAR2 default null,
  X_ATTRIBUTE14                       in VARCHAR2 default null,
  X_ATTRIBUTE15                       in VARCHAR2 default null,
  X_MIGRATED_FRM_BDGT_TYP_CODE        in VARCHAR2 default null,
  /* dbora --- FP M --13-NOV-03 :Introduced the following additional parameters to check for different set up options
   */
  X_ENABLE_PARTIAL_IMPL_FLAG          IN  PA_FIN_PLAN_TYPES_B.ENABLE_PARTIAL_IMPL_FLAG%TYPE,
  X_PRIMARY_COST_FORECAST_FLAG        IN  PA_FIN_PLAN_TYPES_B.PRIMARY_COST_FORECAST_FLAG%TYPE,
  X_PRIMARY_REV_FORECAST_FLAG         IN  PA_FIN_PLAN_TYPES_B.PRIMARY_REV_FORECAST_FLAG%TYPE,
  X_EDIT_AFTER_BASELINE_FLAG          IN  PA_FIN_PLAN_TYPES_B.EDIT_AFTER_BASELINE_FLAG%TYPE,
  X_USE_FOR_WORKPLAN_FLAG             IN  PA_FIN_PLAN_TYPES_B.USE_FOR_WORKPLAN_FLAG%TYPE)
  is
  cursor c is select
      FIN_PLAN_TYPE_CODE,
      PRE_DEFINED_FLAG,
      GENERATED_FLAG,
      EDIT_GENERATED_AMT_FLAG,
      USED_IN_BILLING_FLAG,
      ENABLE_WF_FLAG,
      START_DATE_ACTIVE,
      END_DATE_ACTIVE,
      RECORD_VERSION_NUMBER
    from PA_FIN_PLAN_TYPES_B
    where FIN_PLAN_TYPE_ID = X_FIN_PLAN_TYPE_ID
    for update of FIN_PLAN_TYPE_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from PA_FIN_PLAN_TYPES_TL
    where FIN_PLAN_TYPE_ID = X_FIN_PLAN_TYPE_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of FIN_PLAN_TYPE_ID nowait;
begin

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  Please note that the only parameters used are
  FIN_PLAN_TYPE_ID and RECORD_VERSION_NUMBER. The other parameters are
  retained since the setup plan types page is built based on the _VL entity
  and would expect the spec of the table handlers to comply standards
  with all the paramters.

  Commented since RECORD_VERSION_NUMBER logic is implemented

  if (    (recinfo.FIN_PLAN_TYPE_CODE = X_FIN_PLAN_TYPE_CODE)
      AND ((recinfo.PRE_DEFINED_FLAG = X_PRE_DEFINED_FLAG)
           OR ((recinfo.PRE_DEFINED_FLAG is null) AND (X_PRE_DEFINED_FLAG is null)))
      AND ((recinfo.GENERATED_FLAG = X_GENERATED_FLAG)
           OR ((recinfo.GENERATED_FLAG is null) AND (X_GENERATED_FLAG is null)))
      AND ((recinfo.EDIT_GENERATED_AMT_FLAG= X_EDIT_GENERATED_AMT_FLAG)
           OR ((recinfo.EDIT_GENERATED_AMT_FLAG is null) AND (X_EDIT_GENERATED_AMT_FLAG is null)))
      AND ((recinfo.USED_IN_BILLING_FLAG = X_USED_IN_BILLING_FLAG)
           OR ((recinfo.USED_IN_BILLING_FLAG is null) AND (X_USED_IN_BILLING_FLAG is null)))
      AND ((recinfo.ENABLE_WF_FLAG= X_ENABLE_WF_FLAG)
           OR ((recinfo.ENABLE_WF_FLAG is null) AND (X_ENABLE_WF_FLAG is null)))
      AND ((recinfo.START_DATE_ACTIVE = X_START_DATE_ACTIVE)
           OR ((recinfo.START_DATE_ACTIVE is null) and (X_START_DATE_ACTIVE is null)))
      AND ((recinfo.END_DATE_ACTIVE = X_END_DATE_ACTIVE)
           OR ((recinfo.END_DATE_ACTIVE is null) and (X_END_DATE_ACTIVE is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.NAME = X_NAME)
          AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
               OR ((tlinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
      ) then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
    end if;
  end loop;

  End of comment - Commented since RECORD_VERSION_NUMBER logic is included
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;

  if recinfo.RECORD_VERSION_NUMBER = X_RECORD_VERSION_NUMBER then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  return;

end LOCK_ROW;

procedure UPDATE_ROW (
  X_FIN_PLAN_TYPE_ID                  in NUMBER,
  X_FIN_PLAN_TYPE_CODE                in VARCHAR2 ,
  X_PRE_DEFINED_FLAG                  in VARCHAR2 ,
  X_GENERATED_FLAG                    in VARCHAR2 ,
  X_EDIT_GENERATED_AMT_FLAG           in VARCHAR2 ,
  X_USED_IN_BILLING_FLAG              in VARCHAR2 ,
  X_ENABLE_WF_FLAG                    in VARCHAR2 ,
  X_START_DATE_ACTIVE                 in DATE   ,
  X_END_DATE_ACTIVE                   in DATE   ,
  X_RECORD_VERSION_NUMBER             in NUMBER ,
  X_NAME                              in VARCHAR2 ,
  X_DESCRIPTION                       in VARCHAR2 ,
  X_PLAN_CLASS_CODE                   in VARCHAR2 ,
  X_APPROVED_COST_PLAN_TYPE_FLAG      in VARCHAR2 ,
  X_APPROVED_REV_PLAN_TYPE_FLAG       in VARCHAR2 ,
  X_PROJFUNC_COST_RATE_TYPE           in VARCHAR2 ,
  X_PROJFUNC_COST_RATE_DATE_TYPE      in VARCHAR2 ,
  X_PROJFUNC_COST_RATE_DATE           in DATE     ,
  X_PROJFUNC_REV_RATE_TYPE            in VARCHAR2 ,
  X_PROJFUNC_REV_RATE_DATE_TYPE       in VARCHAR2 ,
  X_PROJFUNC_REV_RATE_DATE            in DATE     ,
  X_PROJECT_COST_RATE_TYPE            in VARCHAR2 ,
  X_PROJECT_COST_RATE_DATE_TYPE       in VARCHAR2 ,
  X_PROJECT_COST_RATE_DATE            in DATE     ,
  X_PROJECT_REV_RATE_TYPE             in VARCHAR2 ,
  X_PROJECT_REV_RATE_DATE_TYPE        in VARCHAR2 ,
  X_PROJECT_REV_RATE_DATE             in DATE     ,
  X_ATTRIBUTE_CATEGORY                in VARCHAR2 ,
  X_ATTRIBUTE1                        in VARCHAR2 ,
  X_ATTRIBUTE2                        in VARCHAR2 ,
  X_ATTRIBUTE3                        in VARCHAR2 ,
  X_ATTRIBUTE4                        in VARCHAR2 ,
  X_ATTRIBUTE5                        in VARCHAR2 ,
  X_ATTRIBUTE6                        in VARCHAR2 ,
  X_ATTRIBUTE7                        in VARCHAR2 ,
  X_ATTRIBUTE8                        in VARCHAR2 ,
  X_ATTRIBUTE9                        in VARCHAR2 ,
  X_ATTRIBUTE10                       in VARCHAR2 ,
  X_ATTRIBUTE11                       in VARCHAR2 ,
  X_ATTRIBUTE12                       in VARCHAR2 ,
  X_ATTRIBUTE13                       in VARCHAR2 ,
  X_ATTRIBUTE14                       in VARCHAR2 ,
  X_ATTRIBUTE15                       in VARCHAR2 ,
  X_LAST_UPDATE_DATE                  in DATE ,
  X_LAST_UPDATED_BY                   in NUMBER ,
  X_LAST_UPDATE_LOGIN                 in NUMBER ,
  X_MIGRATED_FRM_BDGT_TYP_CODE        in VARCHAR2 default null,
 /* dbora --- FP M --13-NOV-03 :Introduced the following additional parameters to check for different set up options
  */
  X_ENABLE_PARTIAL_IMPL_FLAG          IN   PA_FIN_PLAN_TYPES_B.ENABLE_PARTIAL_IMPL_FLAG%TYPE,
  X_PRIMARY_COST_FORECAST_FLAG        IN   PA_FIN_PLAN_TYPES_B.PRIMARY_COST_FORECAST_FLAG%TYPE,
  X_PRIMARY_REV_FORECAST_FLAG         IN   PA_FIN_PLAN_TYPES_B.PRIMARY_REV_FORECAST_FLAG%TYPE,
  X_EDIT_AFTER_BASELINE_FLAG          IN   PA_FIN_PLAN_TYPES_B.EDIT_AFTER_BASELINE_FLAG%TYPE,
  X_USE_FOR_WORKPLAN_FLAG             IN   PA_FIN_PLAN_TYPES_B.USE_FOR_WORKPLAN_FLAG%TYPE)
  is
begin
  update PA_FIN_PLAN_TYPES_B set
    FIN_PLAN_TYPE_CODE = X_FIN_PLAN_TYPE_CODE,
    PRE_DEFINED_FLAG = X_PRE_DEFINED_FLAG,
    GENERATED_FLAG = X_GENERATED_FLAG,
    EDIT_GENERATED_AMT_FLAG =
              decode(X_GENERATED_FLAG,'N','N',X_EDIT_GENERATED_AMT_FLAG),
    USED_IN_BILLING_FLAG = X_USED_IN_BILLING_FLAG,
    ENABLE_WF_FLAG = X_ENABLE_WF_FLAG,
    START_DATE_ACTIVE = X_START_DATE_ACTIVE,
    END_DATE_ACTIVE = X_END_DATE_ACTIVE,
    RECORD_VERSION_NUMBER = RECORD_VERSION_NUMBER + 1,
    PLAN_CLASS_CODE                 =   X_PLAN_CLASS_CODE                ,
    APPROVED_COST_PLAN_TYPE_FLAG    =   X_APPROVED_COST_PLAN_TYPE_FLAG   ,
    APPROVED_REV_PLAN_TYPE_FLAG     =   X_APPROVED_REV_PLAN_TYPE_FLAG    ,
    PROJFUNC_COST_RATE_TYPE         =   X_PROJFUNC_COST_RATE_TYPE        ,
    PROJFUNC_COST_RATE_DATE_TYPE    =   X_PROJFUNC_COST_RATE_DATE_TYPE   ,
    PROJFUNC_COST_RATE_DATE         =   X_PROJFUNC_COST_RATE_DATE        ,
    PROJFUNC_REV_RATE_TYPE          =   X_PROJFUNC_REV_RATE_TYPE         ,
    PROJFUNC_REV_RATE_DATE_TYPE     =   X_PROJFUNC_REV_RATE_DATE_TYPE    ,
    PROJFUNC_REV_RATE_DATE          =   X_PROJFUNC_REV_RATE_DATE         ,
    PROJECT_COST_RATE_TYPE          =   X_PROJECT_COST_RATE_TYPE         ,
    PROJECT_COST_RATE_DATE_TYPE     =   X_PROJECT_COST_RATE_DATE_TYPE    ,
    PROJECT_COST_RATE_DATE          =   X_PROJECT_COST_RATE_DATE         ,
    PROJECT_REV_RATE_TYPE           =   X_PROJECT_REV_RATE_TYPE          ,
    PROJECT_REV_RATE_DATE_TYPE      =   X_PROJECT_REV_RATE_DATE_TYPE     ,
    PROJECT_REV_RATE_DATE           =   X_PROJECT_REV_RATE_DATE          ,
    ATTRIBUTE_CATEGORY              =   X_ATTRIBUTE_CATEGORY             ,
    ATTRIBUTE1                      =   X_ATTRIBUTE1                     ,
    ATTRIBUTE2                      =   X_ATTRIBUTE2                     ,
    ATTRIBUTE3                      =   X_ATTRIBUTE3                     ,
    ATTRIBUTE4                      =   X_ATTRIBUTE4                     ,
    ATTRIBUTE5                      =   X_ATTRIBUTE5                     ,
    ATTRIBUTE6                      =   X_ATTRIBUTE6                     ,
    ATTRIBUTE7                      =   X_ATTRIBUTE7                     ,
    ATTRIBUTE8                      =   X_ATTRIBUTE8                     ,
    ATTRIBUTE9                      =   X_ATTRIBUTE9                     ,
    ATTRIBUTE10                     =   X_ATTRIBUTE10                    ,
    ATTRIBUTE11                     =   X_ATTRIBUTE11                    ,
    ATTRIBUTE12                     =   X_ATTRIBUTE12                    ,
    ATTRIBUTE13                     =   X_ATTRIBUTE13                    ,
    ATTRIBUTE14                     =   X_ATTRIBUTE14                    ,
    ATTRIBUTE15                     =   X_ATTRIBUTE15                    ,
    LAST_UPDATE_DATE                =   X_LAST_UPDATE_DATE               ,
    LAST_UPDATED_BY                 =   X_LAST_UPDATED_BY                ,
    LAST_UPDATE_LOGIN               =   X_LAST_UPDATE_LOGIN              ,
    MIGRATED_FRM_BDGT_TYP_CODE      =   NVL(X_MIGRATED_FRM_BDGT_TYP_CODE,MIGRATED_FRM_BDGT_TYP_CODE),
    /* dbora --- FP M - 13-NOV-03
     */
    ENABLE_PARTIAL_IMPL_FLAG        = NVL (X_ENABLE_PARTIAL_IMPL_FLAG , 'N'),
    PRIMARY_COST_FORECAST_FLAG      = NVL (X_PRIMARY_COST_FORECAST_FLAG,'N'),
    PRIMARY_REV_FORECAST_FLAG       = NVL (X_PRIMARY_REV_FORECAST_FLAG, 'N'),
    EDIT_AFTER_BASELINE_FLAG        = NVL (X_EDIT_AFTER_BASELINE_FLAG,  'N'),
    USE_FOR_WORKPLAN_FLAG           = NVL (X_USE_FOR_WORKPLAN_FLAG,     'N')


  where FIN_PLAN_TYPE_ID              = X_FIN_PLAN_TYPE_ID
  and   decode(pre_defined_flag,'Y',0,nvl(RECORD_VERSION_NUMBER,0) )  =
              decode(pre_defined_flag,'Y',0,
                     nvl(X_RECORD_VERSION_NUMBER,nvl(RECORD_VERSION_NUMBER,0)));

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update PA_FIN_PLAN_TYPES_TL set
    NAME = X_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where FIN_PLAN_TYPE_ID = X_FIN_PLAN_TYPE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_FIN_PLAN_TYPE_ID in NUMBER
) is
begin
  delete from PA_FIN_PLAN_TYPES_TL
  where FIN_PLAN_TYPE_ID = X_FIN_PLAN_TYPE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from PA_FIN_PLAN_TYPES_B
  where FIN_PLAN_TYPE_ID = X_FIN_PLAN_TYPE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from PA_FIN_PLAN_TYPES_TL T
  where not exists
    (select NULL
    from PA_FIN_PLAN_TYPES_B B
    where B.FIN_PLAN_TYPE_ID = T.FIN_PLAN_TYPE_ID
    );

  update PA_FIN_PLAN_TYPES_TL T set (
      NAME,
      DESCRIPTION
    ) = (select
      B.NAME,
      B.DESCRIPTION
    from PA_FIN_PLAN_TYPES_TL B
    where B.FIN_PLAN_TYPE_ID = T.FIN_PLAN_TYPE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.FIN_PLAN_TYPE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.FIN_PLAN_TYPE_ID,
      SUBT.LANGUAGE
    from PA_FIN_PLAN_TYPES_TL SUBB, PA_FIN_PLAN_TYPES_TL SUBT
    where SUBB.FIN_PLAN_TYPE_ID = SUBT.FIN_PLAN_TYPE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into PA_FIN_PLAN_TYPES_TL (
    LAST_UPDATE_LOGIN,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    FIN_PLAN_TYPE_ID,
    NAME,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.LAST_UPDATE_LOGIN,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.FIN_PLAN_TYPE_ID,
    B.NAME,
    B.DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from PA_FIN_PLAN_TYPES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from PA_FIN_PLAN_TYPES_TL T
    where T.FIN_PLAN_TYPE_ID = B.FIN_PLAN_TYPE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure TRANSLATE_ROW(
  X_FIN_PLAN_TYPE_ID                  in NUMBER   ,
  X_OWNER                             in VARCHAR2 ,
  X_NAME                              in VARCHAR2 ,
  X_DESCRIPTION                       in VARCHAR2
) is
begin

  update PA_FIN_PLAN_TYPES_TL set
    NAME = X_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE  = sysdate,
    LAST_UPDATED_BY   = decode(X_OWNER, 'SEED', 1, 0),
    LAST_UPDATE_LOGIN = 0,
    source_lang       = userenv('LANG')
  where FIN_PLAN_TYPE_ID = X_FIN_PLAN_TYPE_ID
    and USERENV('LANG') IN ( LANGUAGE , SOURCE_LANG );

  if (sql%notfound) then
    raise no_data_found;
  end if;

end TRANSLATE_ROW;

procedure LOAD_ROW(
  X_FIN_PLAN_TYPE_ID                in NUMBER,
  X_FIN_PLAN_TYPE_CODE              in VARCHAR2,
  X_PRE_DEFINED_FLAG                in VARCHAR2,
  X_GENERATED_FLAG                  in VARCHAR2,
  X_EDIT_GENERATED_AMT_FLAG         in VARCHAR2,
  X_USED_IN_BILLING_FLAG            in VARCHAR2,
  X_ENABLE_WF_FLAG                  in VARCHAR2,
  X_START_DATE_ACTIVE               in DATE,
  X_END_DATE_ACTIVE                 in DATE,
  X_RECORD_VERSION_NUMBER           in NUMBER,
  X_NAME                            in VARCHAR2,
  X_DESCRIPTION                     in VARCHAR2,
  X_PLAN_CLASS_CODE                 in VARCHAR2 ,
  X_APPROVED_COST_PLAN_TYPE_FLAG    in VARCHAR2 ,
  X_APPROVED_REV_PLAN_TYPE_FLAG     in VARCHAR2 ,
  X_PROJFUNC_COST_RATE_TYPE         in VARCHAR2 ,
  X_PROJFUNC_COST_RATE_DATE_TYPE    in VARCHAR2 ,
  X_PROJFUNC_COST_RATE_DATE         in DATE     ,
  X_PROJFUNC_REV_RATE_TYPE          in VARCHAR2 ,
  X_PROJFUNC_REV_RATE_DATE_TYPE     in VARCHAR2 ,
  X_PROJFUNC_REV_RATE_DATE          in DATE     ,
  X_PROJECT_COST_RATE_TYPE          in VARCHAR2 ,
  X_PROJECT_COST_RATE_DATE_TYPE     in VARCHAR2 ,
  X_PROJECT_COST_RATE_DATE          in DATE     ,
  X_PROJECT_REV_RATE_TYPE           in VARCHAR2 ,
  X_PROJECT_REV_RATE_DATE_TYPE      in VARCHAR2 ,
  X_PROJECT_REV_RATE_DATE           in DATE     ,
  X_ATTRIBUTE_CATEGORY              in VARCHAR2 ,
  X_ATTRIBUTE1                      in VARCHAR2 ,
  X_ATTRIBUTE2                      in VARCHAR2 ,
  X_ATTRIBUTE3                      in VARCHAR2 ,
  X_ATTRIBUTE4                      in VARCHAR2 ,
  X_ATTRIBUTE5                      in VARCHAR2 ,
  X_ATTRIBUTE6                      in VARCHAR2 ,
  X_ATTRIBUTE7                      in VARCHAR2 ,
  X_ATTRIBUTE8                      in VARCHAR2 ,
  X_ATTRIBUTE9                      in VARCHAR2 ,
  X_ATTRIBUTE10                     in VARCHAR2 ,
  X_ATTRIBUTE11                     in VARCHAR2 ,
  X_ATTRIBUTE12                     in VARCHAR2 ,
  X_ATTRIBUTE13                     in VARCHAR2 ,
  X_ATTRIBUTE14                     in VARCHAR2 ,
  X_ATTRIBUTE15                     in VARCHAR2 ,
  X_MIGRATED_FRM_BDGT_TYP_CODE       in VARCHAR2 default null ,
  X_OWNER                           in VARCHAR2,
  /* dbora --- FP M --13-NOV-03 :Introduced the following additional parameters to check for different set up options
   */
  X_ENABLE_PARTIAL_IMPL_FLAG         IN  PA_FIN_PLAN_TYPES_B.ENABLE_PARTIAL_IMPL_FLAG%TYPE,
  X_PRIMARY_COST_FORECAST_FLAG       IN  PA_FIN_PLAN_TYPES_B.PRIMARY_COST_FORECAST_FLAG%TYPE,
  X_PRIMARY_REV_FORECAST_FLAG        IN  PA_FIN_PLAN_TYPES_B.PRIMARY_REV_FORECAST_FLAG%TYPE,
  X_EDIT_AFTER_BASELINE_FLAG         IN  PA_FIN_PLAN_TYPES_B.EDIT_AFTER_BASELINE_FLAG%TYPE,
  X_USE_FOR_WORKPLAN_FLAG            IN  PA_FIN_PLAN_TYPES_B.USE_FOR_WORKPLAN_FLAG%TYPE)
  is

  user_id NUMBER;
  X_ROWID VARCHAR2(64);
  l_wp_plan_type_id   pa_fin_plan_types_b.fin_plan_type_id%TYPE; --Bug 5437529.
  l_use_for_workplan_flag   pa_fin_plan_types_b.use_for_workplan_flag%TYPE; --Bug 5437529.

begin

  if (X_OWNER = 'SEED')then
   user_id := 1;
  else
   user_id :=0;
  end if;
  /* Start of code changes for bug 5437529.Code changes are done to take care the following issue.
     When the customer changes some other plan type other than the seeded plan type(fin_plan_type_id = '10')
     as the workplan plan type and, if the ldt pafpptyp.ldt is reuploaded then use_for_workplan_flag
     will bet set as 'Y' for the seeded plan type. So, there will be two plan types with use_for_workplan_flag as 'Y'.
     So, need to make the X_USE_FOR_WORKPLAN_FLAG as 'N' if
     - the plan type being uploaded is 10 AND
     - the plan type being used for WORKPLAN is different
  */
    BEGIN
        SELECT fin_plan_type_id
        INTO   l_wp_plan_type_id
        FROM   pa_fin_plan_types_b
        WHERE  use_for_workplan_flag = 'Y';
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
        --The seeded plan type is not yet created in the instance. Assign the id of of the seeded plan
        --type in this case since eventually it will be used as workplan plan type.
          l_wp_plan_type_id := 10;
    END;

    l_use_for_workplan_flag := X_USE_FOR_WORKPLAN_FLAG;
    IF (X_FIN_PLAN_TYPE_ID = 10) AND (l_wp_plan_type_id <> 10) THEN
       l_use_for_workplan_flag := 'N';
    END IF;
  /* End of code changes for bug 5437529 */

  PA_FIN_PLAN_TYPES_PKG.UPDATE_ROW (
    X_FIN_PLAN_TYPE_ID                  =>    X_FIN_PLAN_TYPE_ID              ,
    X_FIN_PLAN_TYPE_CODE                =>    X_FIN_PLAN_TYPE_CODE            ,
    X_PRE_DEFINED_FLAG                  =>    X_PRE_DEFINED_FLAG              ,
    X_GENERATED_FLAG                    =>    X_GENERATED_FLAG                ,
    X_EDIT_GENERATED_AMT_FLAG           =>    X_EDIT_GENERATED_AMT_FLAG       ,
    X_USED_IN_BILLING_FLAG              =>    X_USED_IN_BILLING_FLAG          ,
    X_ENABLE_WF_FLAG                    =>    X_ENABLE_WF_FLAG                ,
    X_START_DATE_ACTIVE                 =>    X_START_DATE_ACTIVE             ,
    X_END_DATE_ACTIVE                   =>    X_END_DATE_ACTIVE               ,
    X_RECORD_VERSION_NUMBER             =>    X_RECORD_VERSION_NUMBER         ,
    X_NAME                              =>    X_NAME                          ,
    X_DESCRIPTION                       =>    X_DESCRIPTION                   ,
    X_PLAN_CLASS_CODE                   =>    X_PLAN_CLASS_CODE               ,
    X_APPROVED_COST_PLAN_TYPE_FLAG      =>    X_APPROVED_COST_PLAN_TYPE_FLAG  ,
    X_APPROVED_REV_PLAN_TYPE_FLAG       =>    X_APPROVED_REV_PLAN_TYPE_FLAG   ,
    X_PROJFUNC_COST_RATE_TYPE           =>    X_PROJFUNC_COST_RATE_TYPE       ,
    X_PROJFUNC_COST_RATE_DATE_TYPE      =>    X_PROJFUNC_COST_RATE_DATE_TYPE  ,
    X_PROJFUNC_COST_RATE_DATE           =>    X_PROJFUNC_COST_RATE_DATE       ,
    X_PROJFUNC_REV_RATE_TYPE            =>    X_PROJFUNC_REV_RATE_TYPE        ,
    X_PROJFUNC_REV_RATE_DATE_TYPE       =>    X_PROJFUNC_REV_RATE_DATE_TYPE   ,
    X_PROJFUNC_REV_RATE_DATE            =>    X_PROJFUNC_REV_RATE_DATE        ,
    X_PROJECT_COST_RATE_TYPE            =>    X_PROJECT_COST_RATE_TYPE        ,
    X_PROJECT_COST_RATE_DATE_TYPE       =>    X_PROJECT_COST_RATE_DATE_TYPE   ,
    X_PROJECT_COST_RATE_DATE            =>    X_PROJECT_COST_RATE_DATE        ,
    X_PROJECT_REV_RATE_TYPE             =>    X_PROJECT_REV_RATE_TYPE         ,
    X_PROJECT_REV_RATE_DATE_TYPE        =>    X_PROJECT_REV_RATE_DATE_TYPE    ,
    X_PROJECT_REV_RATE_DATE             =>    X_PROJECT_REV_RATE_DATE         ,
    X_ATTRIBUTE_CATEGORY                =>    X_ATTRIBUTE_CATEGORY            ,
    X_ATTRIBUTE1                        =>    X_ATTRIBUTE1                    ,
    X_ATTRIBUTE2                        =>    X_ATTRIBUTE2                    ,
    X_ATTRIBUTE3                        =>    X_ATTRIBUTE3                    ,
    X_ATTRIBUTE4                        =>    X_ATTRIBUTE4                    ,
    X_ATTRIBUTE5                        =>    X_ATTRIBUTE5                    ,
    X_ATTRIBUTE6                        =>    X_ATTRIBUTE6                    ,
    X_ATTRIBUTE7                        =>    X_ATTRIBUTE7                    ,
    X_ATTRIBUTE8                        =>    X_ATTRIBUTE8                    ,
    X_ATTRIBUTE9                        =>    X_ATTRIBUTE9                    ,
    X_ATTRIBUTE10                       =>    X_ATTRIBUTE10                   ,
    X_ATTRIBUTE11                       =>    X_ATTRIBUTE11                   ,
    X_ATTRIBUTE12                       =>    X_ATTRIBUTE12                   ,
    X_ATTRIBUTE13                       =>    X_ATTRIBUTE13                   ,
    X_ATTRIBUTE14                       =>    X_ATTRIBUTE14                   ,
    X_ATTRIBUTE15                       =>    X_ATTRIBUTE15                   ,
    X_LAST_UPDATE_DATE                  =>    sysdate                         ,
    X_LAST_UPDATED_BY                   =>    user_id                         ,
    X_LAST_UPDATE_LOGIN                 =>    0                               ,
    X_MIGRATED_FRM_BDGT_TYP_CODE        =>    X_MIGRATED_FRM_BDGT_TYP_CODE,
    /* dbora --- FP M - 13-NOV-03
     */
    X_ENABLE_PARTIAL_IMPL_FLAG          =>    NVL (X_ENABLE_PARTIAL_IMPL_FLAG,  'N'),
    X_PRIMARY_COST_FORECAST_FLAG        =>    NVL (X_PRIMARY_COST_FORECAST_FLAG,'N'),
    X_PRIMARY_REV_FORECAST_FLAG         =>    NVL (X_PRIMARY_REV_FORECAST_FLAG, 'N'),
    X_EDIT_AFTER_BASELINE_FLAG          =>    NVL (X_EDIT_AFTER_BASELINE_FLAG,  'N'),
    X_USE_FOR_WORKPLAN_FLAG             =>    NVL (l_use_for_workplan_flag,     'N'));  --Bug 5437529.

  EXCEPTION
    WHEN no_data_found then
        PA_FIN_PLAN_TYPES_PKG.INSERT_ROW (
          X_ROWID                           =>  X_ROWID                             ,
          X_FIN_PLAN_TYPE_ID                =>  X_FIN_PLAN_TYPE_ID                  ,
          X_FIN_PLAN_TYPE_CODE              =>  X_FIN_PLAN_TYPE_CODE                ,
          X_PRE_DEFINED_FLAG                =>  X_PRE_DEFINED_FLAG                  ,
          X_GENERATED_FLAG                  =>  X_GENERATED_FLAG                    ,
          X_EDIT_GENERATED_AMT_FLAG         =>  X_EDIT_GENERATED_AMT_FLAG           ,
          X_USED_IN_BILLING_FLAG            =>  X_USED_IN_BILLING_FLAG              ,
          X_ENABLE_WF_FLAG                  =>  X_ENABLE_WF_FLAG                    ,
          X_START_DATE_ACTIVE               =>  X_START_DATE_ACTIVE                 ,
          X_END_DATE_ACTIVE                 =>  X_END_DATE_ACTIVE                   ,
          X_RECORD_VERSION_NUMBER           =>  X_RECORD_VERSION_NUMBER             ,
          X_NAME                            =>  X_NAME                              ,
          X_DESCRIPTION                     =>  X_DESCRIPTION                       ,
          X_PLAN_CLASS_CODE                 =>  X_PLAN_CLASS_CODE                   ,
          X_APPROVED_COST_PLAN_TYPE_FLAG    =>  X_APPROVED_COST_PLAN_TYPE_FLAG      ,
          X_APPROVED_REV_PLAN_TYPE_FLAG     =>  X_APPROVED_REV_PLAN_TYPE_FLAG       ,
          X_PROJFUNC_COST_RATE_TYPE         =>  X_PROJFUNC_COST_RATE_TYPE           ,
          X_PROJFUNC_COST_RATE_DATE_TYPE    =>  X_PROJFUNC_COST_RATE_DATE_TYPE      ,
          X_PROJFUNC_COST_RATE_DATE         =>  X_PROJFUNC_COST_RATE_DATE           ,
          X_PROJFUNC_REV_RATE_TYPE          =>  X_PROJFUNC_REV_RATE_TYPE            ,
          X_PROJFUNC_REV_RATE_DATE_TYPE     =>  X_PROJFUNC_REV_RATE_DATE_TYPE       ,
          X_PROJFUNC_REV_RATE_DATE          =>  X_PROJFUNC_REV_RATE_DATE            ,
          X_PROJECT_COST_RATE_TYPE          =>  X_PROJECT_COST_RATE_TYPE            ,
          X_PROJECT_COST_RATE_DATE_TYPE     =>  X_PROJECT_COST_RATE_DATE_TYPE       ,
          X_PROJECT_COST_RATE_DATE          =>  X_PROJECT_COST_RATE_DATE            ,
          X_PROJECT_REV_RATE_TYPE           =>  X_PROJECT_REV_RATE_TYPE             ,
          X_PROJECT_REV_RATE_DATE_TYPE      =>  X_PROJECT_REV_RATE_DATE_TYPE        ,
          X_PROJECT_REV_RATE_DATE           =>  X_PROJECT_REV_RATE_DATE             ,
          X_ATTRIBUTE_CATEGORY              =>  X_ATTRIBUTE_CATEGORY                ,
          X_ATTRIBUTE1                      =>  X_ATTRIBUTE1                        ,
          X_ATTRIBUTE2                      =>  X_ATTRIBUTE2                        ,
          X_ATTRIBUTE3                      =>  X_ATTRIBUTE3                        ,
          X_ATTRIBUTE4                      =>  X_ATTRIBUTE4                        ,
          X_ATTRIBUTE5                      =>  X_ATTRIBUTE5                        ,
          X_ATTRIBUTE6                      =>  X_ATTRIBUTE6                        ,
          X_ATTRIBUTE7                      =>  X_ATTRIBUTE7                        ,
          X_ATTRIBUTE8                      =>  X_ATTRIBUTE8                        ,
          X_ATTRIBUTE9                      =>  X_ATTRIBUTE9                        ,
          X_ATTRIBUTE10                     =>  X_ATTRIBUTE10                       ,
          X_ATTRIBUTE11                     =>  X_ATTRIBUTE11                       ,
          X_ATTRIBUTE12                     =>  X_ATTRIBUTE12                       ,
          X_ATTRIBUTE13                     =>  X_ATTRIBUTE13                       ,
          X_ATTRIBUTE14                     =>  X_ATTRIBUTE14                       ,
          X_ATTRIBUTE15                     =>  X_ATTRIBUTE15                       ,
          X_CREATION_DATE                   =>  sysdate                             ,
          X_CREATED_BY                      =>  user_id                             ,
          X_LAST_UPDATE_DATE                =>  sysdate                             ,
          X_LAST_UPDATED_BY                 =>  user_id                             ,
          X_LAST_UPDATE_LOGIN               =>  0                                   ,
          X_MIGRATED_FRM_BDGT_TYP_CODE      =>  X_MIGRATED_FRM_BDGT_TYP_CODE,
          /* dbora --- FP M - 13-NOV-03
           */
          X_ENABLE_PARTIAL_IMPL_FLAG        =>  NVL (X_ENABLE_PARTIAL_IMPL_FLAG,  'N'),
          X_PRIMARY_COST_FORECAST_FLAG      =>  NVL (X_PRIMARY_COST_FORECAST_FLAG,'N'),
          X_PRIMARY_REV_FORECAST_FLAG       =>  NVL (X_PRIMARY_REV_FORECAST_FLAG, 'N'),
          X_EDIT_AFTER_BASELINE_FLAG        =>  NVL (X_EDIT_AFTER_BASELINE_FLAG,  'N'),
          X_USE_FOR_WORKPLAN_FLAG           =>  NVL (l_use_for_workplan_flag,     'N')); --Bug 5437529.

  end LOAD_ROW;

end PA_FIN_PLAN_TYPES_PKG;

/
