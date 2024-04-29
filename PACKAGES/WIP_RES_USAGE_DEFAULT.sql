--------------------------------------------------------
--  DDL for Package WIP_RES_USAGE_DEFAULT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_RES_USAGE_DEFAULT" AUTHID CURRENT_USER as
/* $Header: wiprudfs.pls 115.6 2002/11/29 13:02:51 simishra ship $ */

Procedure Default_Resource_Usages(p_group_id 		in number,
                                   p_parent_header_id   in number := null,
                                   p_wip_entity_id 	in number,
                                   p_organization_id 	in number,
                                   x_err_code 	 out nocopy varchar2,
                                   x_err_msg 	 out nocopy varchar2,
                                   x_return_status  out nocopy varchar2) ;

Procedure Default_Res_Usage ( p_group_id 		in number,
				   p_parent_header_id   in number := null,
                                   p_wip_entity_id 	in number,
                                   p_organization_id 	in number,
                                   p_operation_seq_num 	in number,
                                   p_resource_seq_num 	in number,
                                   p_substitution_type 	in number,
                                   x_err_code 	 out nocopy varchar2,
                                   x_err_msg 	 out nocopy varchar2,
                                   x_return_status  out nocopy varchar2);

END WIP_RES_USAGE_DEFAULT;


 

/
