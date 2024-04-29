--------------------------------------------------------
--  DDL for Package GMF_GET_OPM_CODE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_GET_OPM_CODE" AUTHID CURRENT_USER as
/*       $Header: gmfopmcs.pls 115.1 99/10/29 09:39:49 porting ship  $ */
function generate_code(p_original_code varchar2,
	               p_table_code    varchar2)
                       return varchar2;
function delete_session_codes_tab return number ;

function delrow_session_tab(p_original_code varchar2)
                            return number ;
end gmf_get_opm_code;

 

/
