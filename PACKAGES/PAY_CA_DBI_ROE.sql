--------------------------------------------------------
--  DDL for Package PAY_CA_DBI_ROE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CA_DBI_ROE" AUTHID CURRENT_USER as
/* $Header: pycamagd.pkh 120.1 2006/06/09 04:39:08 ssmukher noship $ */

 /*===========================================================================+
 |               Copyright (c) 1995 Oracle Corporation                        |
 |                  Redwood Shores, California, USA                           |
 |                       All rights reserved.                                 |
 +============================================================================+

     Date             Name                 Description
     ----             ----                 -----------
     27-AUG-1999      P. Ganguly           Created.
     23-NOV-1999      J. Goswami           Added function create_format_item
     09-Jun-2006      ssmukher             Added the dbdrv line for removing
                                           the check_gscc error.
 ============================================================================*/

 function create_route(p_route_name 			varchar2,
			p_description	    		varchar2,
			p_text		    		varchar2)
			return number;

 function create_user_entities(p_user_entity_name	varchar2,
			        p_route_id		number,
				p_notfound_allowed_flag	varchar2,
				p_entity_description	varchar2)
				return number;

 function create_route_parameters(p_route_id		  number,
        			  p_parameter_name        varchar2,
        			  p_sequence_no           number,
        			  p_data_type             varchar2)
				return number;

 procedure create_route_parameter_values(p_route_parameter_id  number,
        			  	p_user_entity_id      number,
        			        p_parameter_value     varchar2);

 procedure create_route_context(p_route_id		number,
				p_context_name		varchar2,
				p_sequence_no		number);

 function create_database_item(p_user_name		varchar2,
			 	p_user_entity_id	number,
				p_data_type		varchar2,
				p_definition_text	varchar2,
				p_null_allowed_flag	varchar2,
				p_description		varchar2) return number;

function create_format_item(p_user_name		varchar2,
			 	p_display_sequence	number) return number;

end pay_ca_dbi_roe;


 

/
