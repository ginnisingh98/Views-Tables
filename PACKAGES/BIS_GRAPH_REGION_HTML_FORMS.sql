--------------------------------------------------------
--  DDL for Package BIS_GRAPH_REGION_HTML_FORMS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_GRAPH_REGION_HTML_FORMS" AUTHID CURRENT_USER AS
/* $Header: BISCHRFS.pls 120.1 2006/02/02 02:05:33 nbarik noship $ */
---  Copyright (c) 2000 Oracle Corporation, Redwood Shores, CA, USA
---  All rights reserved.
---
---==========================================================================
---  FILENAME
---
---     BISCHRFS.pls
---
---  DESCRIPTION
---     Package Specification File for displaying the three
---     html forms in which to
---     enter parameters to be stored for a PHP Chart
---
---  NOTES
---
---  HISTORY
---
---  20-Jun-2000 Walid.Nasrallah Created
---  05-Oct-2000 Walid.Nasrallah moved "WHO" column defintion to database
---  11-Oct-2000 Walid.Nasrallah added security_group_id argument to
---                              specify_parameter_render procedure
---  06-Feb-2001 mdamle          Wrapper routine to return Resp & lists to java
---  11-May-2001 mdamle		 Created a new get_accessible_functions routine
---  29-May-2001 mdamle		 Added hasFunctionAccess function
---  03-Jul-2001 mdamle   	 Added flag to get_accessible_functions and hasFunctionAccess
---  28-Dec-2001 mdamle 	 Added flag to get_accessible_functions
---===========================================================================
g_graph_title         varchar2(200);

--- *********************************************
--- Type declarations
--- *****************************************

TYPE t_resp_rec IS RECORD(
			  responsibility_name
			  fnd_responsibility_vl.responsibility_name%TYPE
			  , responsibility_id
			   fnd_responsibility.responsibility_id%TYPE
			  , application_id
			  fnd_responsibility.application_id%TYPE
			  , security_group_id
			  fnd_user_resp_groups.security_group_id%TYPE
			  );

TYPE t_resp_tbl_type IS TABLE OF t_resp_rec;


TYPE t_func_rec IS RECORD(menu_name
			   fnd_menu_entries_vl.prompt%TYPE
			   ,web_html_call
			  fnd_form_functions.web_html_call%TYPE
			  ,web_args
			  fnd_form_functions.web_html_call%TYPE
			  ,parameters
			  fnd_form_functions.parameters%TYPE
			  ,function_id
			  fnd_form_functions.function_id%TYPE
			  ,function_name
			  fnd_form_functions.function_name%TYPE
			  -- mdamle 03/21/2001
			  ,menu_id
			  fnd_menu_entries.menu_id%TYPE
			  );


TYPE t_func_tbl_type IS TABLE OF t_func_rec;

TYPE t_menu_tbl_type IS TABLE OF fnd_responsibility.menu_id%TYPE;

PROCEDURE Review_Chart_Render
  (   p_user_id             in  PLS_INTEGER
    , p_parameter_string    in  VARCHAR2
     );

FUNCTION get_graph_title return varchar2;

-- mdamle 05/29/2001 - Added function to check if user has access to this function
-- mdamle 07/03/2001 - Added pCheckPMVSpecific flag
function hasFunctionAccess(pUserId 		in varchar2
			 , pFunctionName	in varchar2
			 , pCheckPMVSpecific    in varchar2 default 'Y') return boolean;

END BIS_GRAPH_REGION_HTML_FORMS;

 

/
