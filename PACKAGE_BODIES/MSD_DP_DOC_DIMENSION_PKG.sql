--------------------------------------------------------
--  DDL for Package Body MSD_DP_DOC_DIMENSION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_DP_DOC_DIMENSION_PKG" AS
/* $Header: msddpsddb.pls 120.0 2005/05/25 20:11:20 appldev noship $ */

/* Public Procedures */

PROCEDURE LOAD_ROW(P_DEMAND_PLAN_NAME in varchar2
         ,P_DOCUMENT_NAME	in varchar2
         ,P_DIMENSION_CODE	in varchar2
         ,P_OWNER             in varchar2
         ,P_SEQUENCE_NUMBER    in varchar2
         ,P_AXIS               in varchar2
         ,P_HIERARCHY_ID       in varchar2
         ,P_SELECTION_TYPE     in varchar2
         ,P_SELECTION_SCRIPT   in varchar2
         ,P_ENABLED_FLAG       in varchar2
         ,P_MANDATORY_FLAG     in varchar2
	 ,P_LAST_UPDATE_DATE  in varchar2
         ,P_CUSTOM_MODE  in varchar2
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
          from msd_dp_seeded_doc_dimensions
          where DEMAND_PLAN_ID = l_demand_plan_id
          and DOCUMENT_ID = l_document_id
	  and DIMENSION_CODE = P_DIMENSION_CODE;

	  -- Test for customization and version
          if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                        db_ludate, P_CUSTOM_MODE)) then
	    -- Update existing row
            update msd_dp_seeded_doc_dimensions
	    set  sequence_number = p_sequence_number
            ,axis = p_axis
            ,hierarchy_id = p_hierarchy_id
            ,selection_type = p_selection_type
            ,selection_script = p_selection_script
            ,enabled_flag = p_enabled_flag
            ,mandatory_flag = p_mandatory_flag    ,
	    last_update_date = f_ludate            ,
	    last_updated_by = f_luby             ,
	    last_update_login = 0
            where demand_plan_id = l_demand_plan_id
            and document_id = l_document_id
   	    and dimension_code = p_dimension_code;

          end if;
        exception
          when no_data_found then
            -- Record doesn't exist - insert in all cases
            insert into msd_dp_seeded_doc_dimensions
            (DEMAND_PLAN_ID
            ,DOCUMENT_ID
            ,DIMENSION_CODE
            ,SEQUENCE_NUMBER
            ,AXIS
            ,HIERARCHY_ID
            ,SELECTION_TYPE
            ,SELECTION_SCRIPT
            ,ENABLED_FLAG
            ,MANDATORY_FLAG     ,
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
            ,P_SEQUENCE_NUMBER
            ,P_AXIS
            ,P_HIERARCHY_ID
            ,P_SELECTION_TYPE
            ,P_SELECTION_SCRIPT
            ,P_ENABLED_FLAG
            ,P_MANDATORY_FLAG     ,
            f_ludate	       ,
	    f_luby                  ,
	    f_ludate            ,
	    f_luby             ,
	    0
	    );
        end;

END;

END msd_dp_doc_dimension_pkg ;

/
