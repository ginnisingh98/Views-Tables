--------------------------------------------------------
--  DDL for Package WIP_RES_USAGE_SUBSTITUTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_RES_USAGE_SUBSTITUTIONS" AUTHID CURRENT_USER as
/* $Header: wiprusts.pls 115.6 2002/11/29 17:42:50 simishra ship $ */

Procedure Substitution_Res_Usages (p_group_id 		in number,
                                  p_wip_entity_id 	in number,
                                  p_organization_id 	in number,
                                  x_err_code 	 out nocopy varchar2,
                                  x_err_msg 	 out nocopy varchar2,
                                  x_return_status  out nocopy varchar2);


Procedure Sub_Usage (p_group_id 		in number,
                              p_wip_entity_id 		in number,
                              p_organization_id 	in number,
                              p_operation_seq_num 	in number,
                              p_resource_seq_num 	in number,
                              x_err_code 	 out nocopy varchar2,
                              x_err_msg 	 out nocopy varchar2,
                              x_return_status 	 out nocopy varchar2);

END WIP_RES_USAGE_SUBSTITUTIONS;


 

/
