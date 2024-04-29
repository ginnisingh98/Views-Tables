--------------------------------------------------------
--  DDL for Package Body MSD_DP_DOC_DIM_SELECTION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_DP_DOC_DIM_SELECTION_PKG" AS
/* $Header: msddpddsb.pls 120.0 2005/05/26 01:25:35 appldev noship $ */

/* Public Procedures */

PROCEDURE LOAD_ROW(P_DEMAND_PLAN_NAME in varchar2
         ,P_DOCUMENT_NAME	in varchar2
         ,P_DIMENSION_CODE	in varchar2
         ,P_SELECTION_SEQUENCE	in varchar2
         ,P_OWNER            in varchar2
         ,P_ENABLED_FLAG      in varchar2
         ,P_MANDATORY_FLAG    in varchar2
         ,P_SELECTION_TYPE    in varchar2
         ,P_SELECTION_COMPONENT in varchar2
         ,P_SELECTION_VALUE   in varchar2
         ,P_SUPPLY_PLAN_FLAG  in varchar2
         ,P_SUPPLY_PLAN_NAME  in varchar2
	 ,P_LAST_UPDATE_DATE in varchar2
         ,P_CUSTOM_MODE in varchar2
	 )
is

l_demand_plan_id number;
l_document_id number;
f_luby    number;  -- entity owner in file
f_ludate  date;    -- entity update date in file
db_luby   number;  -- entity owner in db
db_ludate date;    -- entity update date in db


BEGIN

        -- translate values to IDs
        select DEMAND_PLAN_ID
        into l_demand_plan_id
        from MSD_DEMAND_PLANS
        where DEMAND_PLAN_NAME = P_DEMAND_PLAN_NAME;

	select DOCUMENT_ID
	into l_document_id
	from MSD_DP_SEEDED_DOCUMENTS
	where DEMAND_PLAN_ID = l_demand_plan_id
	and DOCUMENT_NAME = P_DOCUMENT_NAME;


        -- Translate owner to file_last_updated_by
        f_luby := fnd_load_util.owner_id(P_OWNER);

        -- Translate char last_update_date to date
        f_ludate := nvl(to_date(P_LAST_UPDATE_DATE, 'YYYY/MM/DD'), sysdate);
        begin
          select LAST_UPDATED_BY, LAST_UPDATE_DATE
          into db_luby, db_ludate
          from msd_dp_doc_dim_selections
          where DEMAND_PLAN_ID = l_demand_plan_id
          and DOCUMENT_ID  = l_document_id
	  and DIMENSION_CODE = P_DIMENSION_CODE
	  and SELECTION_SEQUENCE = P_SELECTION_SEQUENCE;

	  -- Test for customization and version
          if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                        db_ludate, P_CUSTOM_MODE)) then
	    -- Update existing row
            update msd_dp_doc_dim_selections
	    set  enabled_flag = p_enabled_flag
            ,mandatory_flag = p_mandatory_flag
            ,selection_type = p_selection_type
            ,selection_component = p_selection_component
            ,selection_value = p_selection_value
            ,supply_plan_flag = p_supply_plan_flag
            ,supply_plan_name = p_supply_plan_name
	    ,last_update_date = f_ludate            ,
	    last_updated_by = f_luby             ,
	    last_update_login = 0
            where demand_plan_id = l_demand_plan_id
            and document_id  = l_document_id
            and dimension_code = p_dimension_code
      	    and selection_sequence = p_selection_sequence;

          end if;
        exception
          when no_data_found then
            -- Record doesn't exist - insert in all cases
            insert into msd_dp_doc_dim_selections
            (DEMAND_PLAN_ID
             ,DOCUMENT_ID
	     ,DIMENSION_CODE
	     ,SELECTION_SEQUENCE
             ,ENABLED_FLAG
             ,MANDATORY_FLAG
             ,SELECTION_TYPE
             ,SELECTION_COMPONENT
             ,SELECTION_VALUE
             ,SUPPLY_PLAN_FLAG
             ,SUPPLY_PLAN_NAME          ,
	     CREATION_DATE	       ,
             CREATED_BY                  ,
             LAST_UPDATE_DATE            ,
             LAST_UPDATED_BY             ,
             LAST_UPDATE_LOGIN
            )
            values
            (l_demand_plan_id
             ,l_document_id
	     ,P_DIMENSION_CODE
	     ,P_SELECTION_SEQUENCE
             ,P_ENABLED_FLAG
             ,P_MANDATORY_FLAG
             ,P_SELECTION_TYPE
             ,P_SELECTION_COMPONENT
             ,P_SELECTION_VALUE
             ,P_SUPPLY_PLAN_FLAG
             ,P_SUPPLY_PLAN_NAME          ,
            f_ludate	       ,
	    f_luby                  ,
	    f_ludate            ,
	    f_luby             ,
	    0
	    );
        end;

END;

END msd_dp_doc_dim_selection_pkg ;

/
