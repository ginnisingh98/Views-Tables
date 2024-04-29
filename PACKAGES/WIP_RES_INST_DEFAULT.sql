--------------------------------------------------------
--  DDL for Package WIP_RES_INST_DEFAULT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_RES_INST_DEFAULT" AUTHID CURRENT_USER as
/* $Header: wipridfs.pls 120.0 2005/05/25 07:41:45 appldev noship $ */


   Procedure Default_Res_Instance(p_group_id in number,
		p_wip_entity_id  	number,
		p_organization_id 	number,
		p_substitution_type	number,
		p_operation_seq_num	number,
		p_resource_seq_num	in out nocopy number,
		p_resource_id           number,
		p_instance_id    	number,
                p_parent_seq_num        number,
                p_rowid                 ROWID,
                p_err_code              out nocopy varchar2,
                p_err_msg               out nocopy varchar2);


END WIP_RES_INST_DEFAULT;

 

/
