--------------------------------------------------------
--  DDL for Package Body MSD_DP_SEEDED_DOCUMENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_DP_SEEDED_DOCUMENT_PKG" AS
/* $Header: msddpsdb.pls 120.0 2005/05/25 20:15:13 appldev noship $ */

/* Public Procedures */

PROCEDURE LOAD_ROW(P_DEMAND_PLAN_NAME in varchar2
         ,P_DOCUMENT_NAME	in varchar2
         ,P_OWNER            in varchar2
         ,P_DESCRIPTION       in varchar2
         ,P_TYPE              in varchar2
         ,P_OPEN_ON_STARTUP   in varchar2
         ,P_SCRIPT_CLEANUP    in varchar2
         ,P_SCRIPT_INIT       in varchar2
         ,P_SCRIPT_PREPAGE    in varchar2
         ,P_SCRIPT_POSTPAGE   in varchar2
         ,P_VALID_FLAG        in varchar2
 	 ,P_LAST_UPDATE_DATE  in varchar2
	 ,P_SUB_TYPE          in varchar2
         ,P_CUSTOM_MODE     in varchar2
	 )
is

l_demand_plan_id number;
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



        -- Translate owner to file_last_updated_by
        f_luby := fnd_load_util.owner_id(P_OWNER);

        -- Translate char last_update_date to date
        f_ludate := nvl(to_date(P_LAST_UPDATE_DATE, 'YYYY/MM/DD'), sysdate);
        begin
          select LAST_UPDATED_BY, LAST_UPDATE_DATE
          into db_luby, db_ludate
          from msd_dp_seeded_documents
          where DEMAND_PLAN_ID = l_demand_plan_id
          and DOCUMENT_NAME = P_DOCUMENT_NAME;

	  -- Test for customization and version
          if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                        db_ludate, P_CUSTOM_MODE)) then
	    -- Update existing row
            update msd_dp_seeded_documents
	    set  description = p_description
	    ,type = p_type
            ,open_on_startup = p_open_on_startup
            ,script_cleanup = p_script_cleanup
            ,script_init = p_script_init
            ,script_prepage = p_script_prepage
            ,script_postpage = p_script_postpage
            ,valid_flag = p_valid_flag ,
	    sub_type = p_sub_type    ,
	    last_update_date = f_ludate            ,
	    last_updated_by = f_luby             ,
	    last_update_login = 0
            where demand_plan_id = l_demand_plan_id
            and document_name = p_document_name;

          end if;
        exception
          when no_data_found then
            -- Record doesn't exist - insert in all cases
            insert into msd_dp_seeded_documents
            (DEMAND_PLAN_ID
	    ,DOCUMENT_ID
	    ,DOCUMENT_NAME
            ,DESCRIPTION
            ,TYPE
            ,OPEN_ON_STARTUP
            ,SCRIPT_CLEANUP
            ,SCRIPT_INIT
            ,SCRIPT_PREPAGE
            ,SCRIPT_POSTPAGE
            ,VALID_FLAG  ,
	    SUB_TYPE                  ,
            CREATION_DATE	       ,
            CREATED_BY                  ,
            LAST_UPDATE_DATE            ,
            LAST_UPDATED_BY             ,
            LAST_UPDATE_LOGIN
            )
            values
            (l_demand_plan_id
            ,msd_dp_seeded_doc_s.nextval
	    ,P_DOCUMENT_NAME
	    ,p_description
            ,p_type
            ,p_open_on_startup
            ,p_script_cleanup
            ,p_script_init
            ,p_script_prepage
            ,p_script_postpage
            ,p_valid_flag   ,
	    p_sub_type        ,
            f_ludate	       ,
	    f_luby                  ,
	    f_ludate            ,
	    f_luby             ,
	    0
	    );
        end;


END;

END msd_dp_seeded_document_pkg ;

/
