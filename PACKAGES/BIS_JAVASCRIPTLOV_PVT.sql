--------------------------------------------------------
--  DDL for Package BIS_JAVASCRIPTLOV_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_JAVASCRIPTLOV_PVT" AUTHID CURRENT_USER AS
/* $Header: BISVJLOS.pls 115.8 2004/02/18 00:27:28 ankgoel noship $ */
--  +==========================================================================+
--  |     Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA       |
--  |                           All rights reserved.                           |
--  +==========================================================================+
--  | FILENAME                                                                 |
--  |    BISVJLOB.pls                                                          |
--  |                                                                          |
--  | DESCRIPTION                                                              |
--  |    Package Specification File for Javascript LOV                         |
--  | NOTES                                                                    |
--  |                                                                          |
--  | HISTORY                                                                  |
--  |                                           			       |
--  |21-Mar-2001  mdamle  Created					       |
--  |									       |
--  +==========================================================================+

G_PERF_MEAS_S_LOV CONSTANT 		varchar2(4) := 'PM_S';
G_PERF_MEAS_R_LOV CONSTANT 		varchar2(4) := 'PM_R';
G_TARGET_LEVEL_S_LOV CONSTANT 		varchar2(4) := 'TL_S'; /* No more used */
G_TARGET_LEVEL_R_LOV CONSTANT 		varchar2(4) := 'TL_R';
G_OWNERS_LOV  CONSTANT      		varchar2(32000) := 'OWNER';
G_RESPS_LOV   CONSTANT  		varchar2(5) := 'RESPS';

PROCEDURE showLOV (p_lov_type           in varchar2
		  ,p_form_name          in varchar2
		  ,p_param_field   	in varchar2
		  ,p_param_id_field   	in varchar2 default NULL
		  ,p_filter             in varchar2 default ''
		  ,p_parameter1   	in varchar2 default NULL
		  ,p_parameter2   	in varchar2 default NULL
		  ,p_parameter3   	in varchar2 default NULL
		  ,p_parameter4   	in varchar2 default NULL
		  ,p_parameter5   	in varchar2 default NULL
		  ,p_callback_function  in varchar2 default NULL);


FUNCTION getLOVSQL (p_lov_type          in varchar2
		    ,p_filter           in varchar2 default ''
		    ,p_parameter1   	in varchar2 default NULL
		    ,p_parameter2   	in varchar2 default NULL
		    ,p_parameter3   	in varchar2 default NULL
		    ,p_parameter4   	in varchar2 default NULL
		    ,p_parameter5   	in varchar2 default NULL) return varchar;


END BIS_JAVASCRIPTLOV_PVT;

 

/
