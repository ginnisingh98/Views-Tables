--------------------------------------------------------
--  DDL for Package WIP_RESOURCE_DEFAULT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_RESOURCE_DEFAULT" AUTHID CURRENT_USER as
/* $Header: wiprsdfs.pls 120.0.12010000.1 2008/07/24 05:25:46 appldev ship $ */

   Procedure Default_Resource(p_group_id in number,
		p_wip_entity_id  	number,
		p_organization_id 	number,
		p_substitution_type	number,
		p_operation_seq_num	number,
		p_resource_seq_num	number,
		p_resource_id_new	number,
                p_err_code              out nocopy varchar2,
                p_err_msg               out nocopy varchar2);


END WIP_RESOURCE_DEFAULT;

/
