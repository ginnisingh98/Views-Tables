--------------------------------------------------------
--  DDL for Package Body MSD_DEMAND_PLAN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_DEMAND_PLAN_PKG" AS
/* $Header: msddplnb.pls 120.1 2006/03/31 08:24:53 brampall noship $ */

/* Public Procedures */

PROCEDURE LOAD_ROW(P_DEMAND_PLAN_NAME           in VARCHAR2,
                            P_OWNER                      in VARCHAR2,
                            P_DESCRIPTION                in VARCHAR2,
                            P_BASE_UOM                   in VARCHAR2,
                            P_LOWEST_PERIOD_TYPE         in VARCHAR2,
                            P_LAST_UPDATE_DATE           in VARCHAR2,
                            P_VALID_FLAG                 in VARCHAR2,
                            P_ENABLE_FCST_EXPLOSION      in VARCHAR2,
                            P_ROUNDOFF_THREASHOLD        in VARCHAR2,
                            P_ROUNDOFF_DECIMAL_PLACES    in VARCHAR2,
                            P_AMT_THRESHOLD              in VARCHAR2,
                            P_AMT_DECIMAL_PLACES         in VARCHAR2,
                            P_G_MIN_TIM_LVL_ID           in VARCHAR2,
                            P_M_MIN_TIM_LVL_ID           in VARCHAR2,
                            P_F_MIN_TIM_LVL_ID           in VARCHAR2,
                            P_C_MIN_TIM_LVL_ID           in VARCHAR2,
                            P_USE_ORG_SPECIFIC_BOM_FLAG  in VARCHAR2,
                            P_TEMPLATE_FLAG        in VARCHAR2,
			    P_ORGANIZATION_ID            in VARCHAR2,
			    P_SR_INSTANCE_ID             in VARCHAR2,
			    P_PLAN_TYPE                  in VARCHAR2,
                            P_DEFAULT_TEMPLATE           in VARCHAR2,
                            P_STRIPE_STREAM_NAME				 in VARCHAR2,
			    P_CUSTOM_MODE              in VARCHAR2)
IS

l_demand_plan_id number;
f_luby    number;  -- entity owner in file
f_ludate  date;    -- entity update date in file
db_luby   number;  -- entity owner in db
db_ludate date;    -- entity update date in db


BEGIN


        -- Translate owner to file_last_updated_by
        f_luby := fnd_load_util.owner_id(P_OWNER);

        -- Translate char last_update_date to date
        f_ludate := nvl(to_date(P_LAST_UPDATE_DATE, 'YYYY/MM/DD'), sysdate);
        begin
          select LAST_UPDATED_BY, LAST_UPDATE_DATE
          into db_luby, db_ludate
          from msd_demand_plans
          where DEMAND_PLAN_NAME = p_demand_plan_name;

	  -- Test for customization and version
          if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                        db_ludate, P_CUSTOM_MODE)) then
	    -- Update existing row
            update msd_demand_plans
	    set  organization_id = p_organization_id,
            sr_instance_id = p_sr_instance_id,
	    plan_type = p_plan_type,
            default_template = p_default_template,
	    description = p_description     ,
            base_uom = p_base_uom        ,
            lowest_period_type = p_lowest_period_type ,
            valid_flag = p_valid_flag,
            enable_fcst_explosion = p_enable_fcst_explosion,
            roundoff_threashold = p_roundoff_threashold  ,
            roundoff_decimal_places = p_roundoff_decimal_places,
            amt_threshold = p_amt_threshold   ,
            amt_decimal_places = p_amt_decimal_places       ,
            g_min_tim_lvl_id = p_g_min_tim_lvl_id,
            m_min_tim_lvl_id = p_m_min_tim_lvl_id,
            f_min_tim_lvl_id = p_f_min_tim_lvl_id,
            c_min_tim_lvl_id = p_c_min_tim_lvl_id,
            use_org_specific_bom_flag = p_use_org_specific_bom_flag,
            template_flag = p_template_flag        ,
            stripe_stream_name = p_stripe_stream_name,
	    last_update_date = f_ludate            ,
	    last_updated_by = f_luby             ,
	    last_update_login = 0
	    where demand_plan_name = p_demand_plan_name;

	    begin
               -- translate values to IDs
              select DEMAND_PLAN_ID
              into l_demand_plan_id
              from MSD_DEMAND_PLANS
              where DEMAND_PLAN_NAME = P_DEMAND_PLAN_NAME;

	    -- Update existing row
	    update msd_demand_plans_tl
	    set description       = p_description,
            last_update_date  = f_ludate,
            last_updated_by   = f_luby,
            last_update_login = 0,
            source_lang       = userenv('LANG')
	    where demand_plan_id = l_demand_plan_id
	    and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

	     exception
               when no_data_found then

               -- Record doesn't exist - insert in all cases
               insert into msd_demand_plans_tl
	       (
               demand_plan_id,
               description,
    	       language,
               source_lang,
               created_by,
               creation_date,
               last_updated_by,
               last_update_date ,
               last_update_login
	       )
	       Select
               l_demand_plan_id,
               p_description,
               l.language_code,
   	       userenv('LANG'),
               f_luby,
               f_ludate,
               f_luby,
               f_ludate,
               0
               from fnd_languages l
               where l.installed_flag in ('I','B');

	    end;

          end if;
        exception
          when no_data_found then

	    select msd_demand_plan_s.nextval into l_demand_plan_id from dual;

            -- Record doesn't exist - insert in all cases
            insert into msd_demand_plans
            (DEMAND_PLAN_ID            ,
	     TEMPLATE_ID,
	     DEMAND_PLAN_NAME  ,
             DESCRIPTION     ,
             BASE_UOM        ,
             LOWEST_PERIOD_TYPE ,
             VALID_FLAG      ,
             ENABLE_FCST_EXPLOSION,
             ROUNDOFF_THREASHOLD  ,
             ROUNDOFF_DECIMAL_PLACES  ,
             AMT_THRESHOLD   ,
             AMT_DECIMAL_PLACES       ,
             G_MIN_TIM_LVL_ID,
             M_MIN_TIM_LVL_ID,
             F_MIN_TIM_LVL_ID,
             C_MIN_TIM_LVL_ID,
             USE_ORG_SPECIFIC_BOM_FLAG,
             TEMPLATE_FLAG        ,
	     ORGANIZATION_ID,
             SR_INSTANCE_ID      ,
	     PLAN_TYPE           ,
             DEFAULT_TEMPLATE ,
             STRIPE_STREAM_NAME,
	     CREATION_DATE	       ,
             CREATED_BY                  ,
             LAST_UPDATE_DATE            ,
             LAST_UPDATED_BY             ,
             LAST_UPDATE_LOGIN
            )
            values
            (l_demand_plan_id            ,
	     l_demand_plan_id            ,
	     P_DEMAND_PLAN_NAME  ,
             P_DESCRIPTION     ,
             P_BASE_UOM        ,
             P_LOWEST_PERIOD_TYPE ,
             P_VALID_FLAG      ,
             P_ENABLE_FCST_EXPLOSION,
             P_ROUNDOFF_THREASHOLD  ,
             P_ROUNDOFF_DECIMAL_PLACES  ,
             P_AMT_THRESHOLD   ,
             P_AMT_DECIMAL_PLACES       ,
             P_G_MIN_TIM_LVL_ID,
             P_M_MIN_TIM_LVL_ID,
             P_F_MIN_TIM_LVL_ID,
             P_C_MIN_TIM_LVL_ID,
             P_USE_ORG_SPECIFIC_BOM_FLAG,
             P_TEMPLATE_FLAG        ,
	     P_ORGANIZATION_ID,
             P_SR_INSTANCE_ID      ,
	     P_PLAN_TYPE           ,
             P_DEFAULT_TEMPLATE ,
             P_STRIPE_STREAM_NAME ,
	     f_ludate	       ,
 	     f_luby                  ,
	     f_ludate            ,
	     f_luby             ,
	     0
	    );

               insert into msd_demand_plans_tl
	       (
               demand_plan_id,
               description,
    	       language,
               source_lang,
               created_by,
               creation_date,
               last_updated_by,
               last_update_date ,
               last_update_login
	       )
	       Select
               l_demand_plan_id,
               p_description,
               l.language_code,
   	       userenv('LANG'),
               f_luby,
               f_ludate,
               f_luby,
               f_ludate,
               0
               from fnd_languages l
               where l.installed_flag in ('I','B');

        end;

END LOAD_ROW;


PROCEDURE TRANSLATE_ROW(P_DEMAND_PLAN_NAME in varchar2,
                        P_DESCRIPTION in varchar2,
			P_OWNER  in varchar2)
IS

f_luby    number;  -- entity owner in file

BEGIN

        -- Translate owner to file_last_updated_by
        f_luby := fnd_load_util.owner_id(P_OWNER);


     update msd_demand_plans_tl set
        description       = p_description,
        LAST_UPDATE_DATE  = sysdate,
        LAST_UPDATED_BY   = f_luby,
        LAST_UPDATE_LOGIN = 0,
        SOURCE_LANG       = userenv('LANG')
      where
          demand_plan_id    =   (select demand_plan_id from msd_demand_plans where demand_plan_name = p_demand_plan_name)
          and userenv('LANG') in (LANGUAGE, SOURCE_LANG);
END;

Procedure ADD_LANGUAGE
is
begin
  delete from MSD_DEMAND_PLANS_TL T
  where not exists
    (select NULL
    from MSD_DEMAND_PLANS B
    where B.DEMAND_PLAN_ID = T.DEMAND_PLAN_ID
    );

  update MSD_DEMAND_PLANS_TL T set (
      DESCRIPTION
    ) = (select
      B.DESCRIPTION
    from MSD_DEMAND_PLANS_TL B
    where B.DEMAND_PLAN_ID = T.DEMAND_PLAN_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.DEMAND_PLAN_ID,
      T.LANGUAGE
  ) in (select
      SUBT.DEMAND_PLAN_ID,
      SUBT.LANGUAGE
    from MSD_DEMAND_PLANS_TL SUBB, MSD_DEMAND_PLANS_TL SUBT
    where SUBB.DEMAND_PLAN_ID = SUBT.DEMAND_PLAN_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DESCRIPTION <> SUBT.DESCRIPTION
  ));

  insert into MSD_DEMAND_PLANS_TL (
    DEMAND_PLAN_ID,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    REQUEST_ID,
    PROGRAM_APPLICATION_ID,
    PROGRAM_ID,
    PROGRAM_UPDATE_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.DEMAND_PLAN_ID,
    B.DESCRIPTION,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.REQUEST_ID,
    B.PROGRAM_APPLICATION_ID,
    B.PROGRAM_ID,
    B.PROGRAM_UPDATE_DATE,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from MSD_DEMAND_PLANS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from MSD_DEMAND_PLANS_TL T
    where T.DEMAND_PLAN_ID = B.DEMAND_PLAN_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

End ADD_LANGUAGE;

END msd_demand_plan_pkg ;

/
