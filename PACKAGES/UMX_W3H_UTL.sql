--------------------------------------------------------
--  DDL for Package UMX_W3H_UTL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."UMX_W3H_UTL" AUTHID CURRENT_USER AS
/* $Header: UMXW3HUTLS.pls 120.3 2008/05/23 07:45:22 kkasibha noship $ */

  --  Function
  --  getObjectDetails
  --
  -- Description
  -- This method takes in the name of permission set for the corresponding
  -- database security object and returns the list for the
  -- permission set
  -- IN
  -- p_menu_name - takes in FND_MENUS.MENU_NAME%TYPE object
  -- RETURNS
  -- List for the permission set

function getObjectDetails(
      p_menu_name in FND_MENUS.MENU_NAME%TYPE) return varchar2;
/***************************************************************************************/

  -- Function
  -- isFunctionAccessible
  --
  -- Description
  -- This method takes in user name and role name for the a list of functions
  -- for a user and returns true or false for accessibility
  -- IN
  -- p_user_name - varchar2 (takes the user_name)
  -- p_role_name - varchar2 (takes the role_name)
  -- RETURNS
  -- result as true or false
function isFunctionAccessible(
      p_user_name in varchar2,p_role_name in varchar2) return varchar2;
/***************************************************************************************/


  -- Function
  -- get_excluded_function_list
  --
  -- Description
  -- This method takes in the name of the responsibility, gets all the excluded function for the resps in its hierarchy and places them in a associative array
  -- IN
  -- p_resp_name - varchar2 (name of the responsibility)
  -- RETURNS
  -- result as Success on success, error message on failure
FUNCTION get_excluded_function_list(
	p_resp_name WF_ROLES.NAME%TYPE) RETURN VARCHAR2;
/***************************************************************************************/


  -- Function
  -- is_function_menu_excluded
  --
  -- Description
  -- This method takes in the name of the function to find
  -- and the responsibility name under which the function is to be searched for accssiblity
  -- IN
  -- func_to_find - varchar2 (name of the function to find)
  -- resp_name - varchar2 (responsibility name)
  -- RETURNS
  -- result as Yes or No

FUNCTION is_function_menu_excluded(
	 func_to_find FND_FORM_FUNCTIONS.FUNCTION_NAME%TYPE,resp_name WF_LOCAL_ROLES.NAME%TYPE) RETURN varchar2;
/***************************************************************************************/

end UMX_W3H_UTL;

/
