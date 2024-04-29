--------------------------------------------------------
--  DDL for Package IBU_ADMIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBU_ADMIN" AUTHID CURRENT_USER as
/* $Header: ibuadmns.pls 115.6.1158.2 2002/07/24 23:42:16 jamose ship $ */

	    procedure ibu_get_subscribe_details (app_Id           NUMBER,
									 lang_code        VARCHAR2,
									 userId           VARCHAR2,
									 header       out VARCHAR2,
									 footer       out VARCHAR2,
									 subject      out VARCHAR2,
									 lstupdt      in  DATE);

	   procedure ibu_get_subscribe_interval (app_Id           NUMBER,
									  prof_name        VARCHAR2,
									  e_interval   out VARCHAR2);

        procedure ibu_replace_cluewords (userId varchar2,
							       str in  out varchar2,
								  lstupdt date);

	   procedure ibu_get_cnews_filter (app_Id           NUMBER,
							      filter_list out IBU_HOME_PAGE_PVT.Filter_Data_List_Type);
        function getCompanyData ( perzDataName varchar2) return varchar2;

end ibu_admin;

 

/
