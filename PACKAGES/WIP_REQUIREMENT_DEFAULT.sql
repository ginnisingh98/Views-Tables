--------------------------------------------------------
--  DDL for Package WIP_REQUIREMENT_DEFAULT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_REQUIREMENT_DEFAULT" AUTHID CURRENT_USER as
/* $Header: wiprqdfs.pls 120.2 2005/07/01 13:40:30 seli noship $ */

   Procedure Default_Requirement(
		p_group_id		in number,
		p_wip_entity_id 	in number,
		p_organization_id 	in number,
                p_substitution_type     in number,
		p_operation_seq_num	in number,
		p_inventory_item_id_old	in number,
		p_inventory_item_id_new	in number,
		p_quantity_per_assembly in number,
                p_basis_type            in  number, /* LBM Project */
                p_component_yield_factor in number,/*Component Yield Enhancement(Bug 4369064)*/
                p_err_code              out NOCOPY varchar2,
                p_err_msg               out NOCOPY varchar2);


END WIP_REQUIREMENT_DEFAULT;

 

/
