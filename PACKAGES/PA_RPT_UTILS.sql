--------------------------------------------------------
--  DDL for Package PA_RPT_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_RPT_UTILS" AUTHID CURRENT_USER AS
/* $Header: PARPUTLS.pls 115.2 99/10/28 14:13:27 porting ship  $ */

---------------------------
--  GLOBAL VARIABLES
--
Class_Category1 PA_CLASS_CATEGORIES.CLASS_CATEGORY%type;
Class_Category2 PA_CLASS_CATEGORIES.CLASS_CATEGORY%type;
Class_Category3 PA_CLASS_CATEGORIES.CLASS_CATEGORY%type;
Role_Type1 PA_PROJECT_ROLE_TYPES.PROJECT_ROLE_TYPE%type;
Role_Type2 PA_PROJECT_ROLE_TYPES.PROJECT_ROLE_TYPE%type;
Role_Type3 PA_PROJECT_ROLE_TYPES.PROJECT_ROLE_TYPE%type;
Cost_Budget_TypeCode1 PA_Budget_Types.Budget_type_code%type;
Cost_Budget_TypeCode2 PA_Budget_Types.Budget_type_code%type;
Revenue_Budget_TypeCode1 PA_Budget_Types.Budget_type_code%type;
Revenue_Budget_TypeCode2 PA_Budget_Types.Budget_type_code%type;
Unassigned_txt Varchar2(2000);
PA_Start_Date  Date;
PA_End_Date    Date;


----------------------------
--  PROCEDURES AND FUNCTIONS
--
--
--  1. Procedure Name:	DISCOVERER_INIT
--  	Usage:		Populates data in tables : PA_PROJ_RPT_ATTRIBS_TEMP
--                      Reads the profiles for the responsibility,
--                      and accordingly creates records.
Procedure DISCOVERER_INIT;

-----------------------------------------------------------------------
-- 2.  Function Name:   PROJECT_RPT_CLASS
--     Usage:           Returns the Class_Code assigned to the project
--                      for the given Class_Category.
Function PROJECT_RPT_CLASS ( x_Project_ID Number,
                             x_Class_Category Varchar2 )
Return Varchar2;

------------------------------------------------------------------------
-- 3.  Function Name:   PROJECT_RPT_KEYMEMBER
--     Usage:           Returns the Key member assigned to the project
--                      for the given Project Role Type.
Function PROJECT_RPT_KEYMEMBER ( x_Project_ID Number,
                                 x_Project_Role_Type Varchar2 )
Return Varchar2;

-------------------------------------------------------------------------
-- 4.  Function Name:    GET_RPT_CLASS_CATEGORY
--     Usage:            Returns the reporting class category attributes
--                       Returns the corresponding value.
Function GET_RPT_CLASS_CATEGORY ( x_number Number )
Return Varchar2;

-------------------------------------------------------------------------
-- 5.  Function Name:    GET_RPT_ROLE_TYPE
--     Usage:            Returns the reporting project role type attributes
--                       Returns the corresponding value.
Function GET_RPT_ROLE_TYPE ( x_number Number )
Return Varchar2;

-------------------------------------------------------------------------
-- 6.  Function Name:    GET_RPT_BUDGET_TYPE
--     Usage:            Returns the reporting budget type attributes
--                       Returns the corresponding value.
Function GET_RPT_BUDGET_TYPE ( x_type varchar2,
                             x_number Number )
Return Varchar2;

-------------------------------------------------------------------------

END PA_RPT_UTILS;

 

/
