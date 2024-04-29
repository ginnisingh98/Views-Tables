--------------------------------------------------------
--  DDL for Package Body PJI_PAGE_LAYOUTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJI_PAGE_LAYOUTS" as
/*  $Header: PJIPGLYTB.pls 120.0 2005/05/29 12:31:01 appldev noship $  */
--Function for returning page_id
FUNCTION PJI_PAGE_ID(
			p_project_id IN Number,
			p_page_type_code IN varchar2
			)  return number
        IS
		l_page_id	number ;

		CURSOR c_get_page_id is
			SELECT 	page_id
			FROM  	pa_page_layouts play,
					pa_projects_all proj,
					pa_project_types_all ptype
			WHERE 1=1
			AND proj.PROJECT_ID =p_project_id
			AND play.PAGE_TYPE_CODE =p_page_type_code
			AND proj.PROJECT_TYPE = ptype.PROJECT_TYPE
			AND play.PERS_FUNCTION_NAME = 'PJI_REP_PP_' || ptype.PROJECT_TYPE_CLASS_CODE
			AND proj.ORG_ID = ptype.ORG_ID
			AND play.page_id < 1000;

        Begin
			if (p_project_id = null  OR p_page_type_code = null ) then
				 return null;
			end if;

			Open  c_get_page_id;
			Fetch  c_get_page_id into l_page_id;
			Close c_get_page_id;

			  return l_page_id;

			EXCEPTION
				WHEN OTHERS THEN
				return null;



	END PJI_PAGE_ID;

-- Function for returning page_name
	FUNCTION PJI_PAGE_NAME(
			p_project_id IN Number,
			p_page_type_code IN varchar2
			)  return varchar2
        IS
		l_page_name	varchar2(300);

		CURSOR c_get_page_name is
			SELECT 	page_name
			FROM  	pa_page_layouts play,
					pa_projects_all proj,
					pa_project_types_all ptype
			WHERE 1=1
			AND proj.PROJECT_ID =p_project_id
			AND play.PAGE_TYPE_CODE =p_page_type_code
			AND proj.PROJECT_TYPE = ptype.PROJECT_TYPE
			AND play.PERS_FUNCTION_NAME = 'PJI_REP_PP_' || ptype.PROJECT_TYPE_CLASS_CODE
			AND proj.ORG_ID = ptype.ORG_ID
			AND play.page_id < 1000;

        Begin
			if (p_project_id = null  OR p_page_type_code = null ) then
				 return null;
			end if;

			Open  c_get_page_name;
			Fetch  c_get_page_name into l_page_name;
			Close c_get_page_name;

			return l_page_name;

			EXCEPTION
				WHEN OTHERS THEN
				return null;

	END PJI_PAGE_NAME;

END PJI_PAGE_LAYOUTS;

/
