--------------------------------------------------------
--  DDL for Package PA_ALLOC_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_ALLOC_UTILS" AUTHID CURRENT_USER AS
/* $Header: PAXALUTS.pls 120.1 2005/08/10 13:45:05 dlanka noship $ */

------------------------------------------------------------------------
---  is_resource_in_alloc_rules
-----This function returns 'Y' if a resource list member is used in allocations
------------------------------------------------------------------------
FUNCTION  is_resource_in_rules(p_resource_list_member_id IN NUMBER)
                                           RETURN varchar2  ;
PRAGMA RESTRICT_REFERENCES(is_resource_in_rules, WNDS, WNPS) ;

------------------------------------------------------------------------
---  is_resource_list_in_alloc_rules
---- This function returns 'Y' if a resouce list is used in allocations
------------------------------------------------------------------------
FUNCTION  is_resource_list_in_rules(p_resource_list_id IN NUMBER)
                                                 RETURN varchar2  ;
PRAGMA RESTRICT_REFERENCES(is_resource_list_in_rules, WNDS, WNPS) ;

------------------------------------------------------------------------
---  is_project_in_allocations
---- This function returns 'Y' if a project is used in allocations
------------------------------------------------------------------------
FUNCTION  is_project_in_allocations(p_project_id IN NUMBER)
                                                 RETURN varchar2  ;
PRAGMA RESTRICT_REFERENCES(is_project_in_allocations, WNDS, WNPS) ;

------------------------------------------------------------------------
---  is_task_in_allocations
---- This function returns 'Y' if a task is used in allocations
------------------------------------------------------------------------
FUNCTION  is_task_in_allocations(p_task_id IN NUMBER)
                                                 RETURN varchar2  ;
PRAGMA RESTRICT_REFERENCES(is_task_in_allocations, WNDS, WNPS) ;

------------------------------------------------------------------------
---  is_task_lowest_in_allocations
---  This function returns 'Y' if a task is used as target or offset, or if
---- a task is a non top level task and used as source in allocations
------------------------------------------------------------------------
FUNCTION is_task_lowest_in_allocations(p_task_id IN NUMBER) RETURN varchar2;
PRAGMA RESTRICT_REFERENCES(is_task_lowest_in_allocations, WNDS, WNPS) ;


------------------------------------------------------------------------
--- Is_Budget_Type_In_allocations
---- This function returns 'Y' if a budget_type is used in allocations
------------------------------------------------------------------------
FUNCTION Is_Budget_Type_In_allocations(p_budget_type_code IN varchar2)
                                                 RETURN varchar2  ;
PRAGMA RESTRICT_REFERENCES(Is_Budget_Type_In_allocations, WNDS, WNPS) ;

/*------------------------------------------------------------------------
--- Is_Bem_In_allocations
---- This function returns 'Y' if a budget entry method is used in allocations
------------------------------------------------------------------------
FUNCTION Is_Bem_In_allocations(p_bem_code IN varchar2)
                                                 RETURN varchar2  ;
PRAGMA RESTRICT_REFERENCES(Is_Bem_In_allocations, WNDS, WNPS) ;*/


/*
 API Name : Is_RBS_In_Rules
 API Desc : Return 'Y' if RBS is used in Allocations.
 API Created Date : 19-Mar-04
 API Created By : Vthakkar
*/

FUNCTION Is_RBS_In_Rules ( P_RBS_ID IN pa_rbs_headers_v.RBS_HEADER_ID%Type ) RETURN VARCHAR2;

/*
 API Name : Is_RBS_In_Rules
 API Desc : Return 'Y' if RBS Element is used in Allocations.
 API Created Date : 19-Mar-04
 API Created By : Vthakkar
*/

FUNCTION Is_RBS_Element_In_Rules ( P_RBS_ELEMENT_ID IN pa_rbs_elements.RBS_ELEMENT_ID%type ) RETURN VARCHAR2;

/*
 API Name : Resource_Name
 API Desc : This function will be return the name of the resource id depending upon the Allocation Type and
			If Resource ID is member of Resource List or RBS Structure.
 API Created Date : 19-Mar-04
 API Created By : Vthakkar
*/

Function Resource_Name (
						p_alloc_type	IN  Varchar2 ,
						p_resource_id	IN  pa_rbs_elements.RBS_ELEMENT_ID%type   ,
						p_rule_id		IN  pa_alloc_rules.rule_id%type
					   ) Return Varchar2;

/*
 API Name : ASSOCIATE_RBS_TO_ALLOC_RULE
 API Desc : This procedure will be update the new element id to the allocation rules's source resource list member's id
			and basis resource list member's id when new version of RBS is created
 API Created Date : 02-Apr-04
 API Created By : Vthakkar
*/

Procedure ASSOCIATE_RBS_TO_ALLOC_RULE (
										p_rbs_header_id		IN NUMBER    ,
										p_rbs_version_id	IN NUMBER	 ,
										x_return_status     OUT NOCOPY VARCHAR2 ,
										x_error_code        OUT NOCOPY VARCHAR2
									  );

/*
 API Name : RESOURCE_LIST_NAME
 API Desc : This function will return name of Resource List or Resource Breakdown Structure Header Name depending Upon
			Rule contains Resource List or Resource Structure.
 API Created Date : 06-Apr-04
 API Created By : Vthakkar
*/

Function RESOURCE_LIST_NAME (
							 p_resource_list_id In Number ,
							 p_resource_struct_type in Varchar2
						    ) Return Varchar2;

/*
 API Name : GET_CONCATENATED_NAME
 API Desc : This function will return name of Resource List Member attached with parent member name like e.g self.parent
 API Created Date : 03-May-04
 API Created By : Vthakkar
*/
Function GET_CONCATENATED_NAME (p_resource_id in Number , p_struct_type in Varchar2 ) Return
Varchar2 ;

/*
 API Name : Get_Rbs_Version_Name
 API Desc : This function will return name of RBS Version Name provided rbs_version_id
 API Created Date : 11-May-2004
 API Created By : Vthakkar
*/

Function Get_Rbs_Version_Name (p_rbs_ver_id in Number) Return Varchar2;

/*
 API Name : Get_Resource_Name_TL
 API Desc : This function will return name of RBS Name translated in the respective language
 API Created Date : 13-May-2004
 API Created By : Vthakkar
*/

Function Get_Resource_Name_TL ( p_rbs_element_name_id in Number ) Return Varchar2;

END PA_ALLOC_UTILS ;

 

/
