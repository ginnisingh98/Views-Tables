--------------------------------------------------------
--  DDL for Package WIP_REQUIREMENT_VALIDATIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_REQUIREMENT_VALIDATIONS" AUTHID CURRENT_USER AS
/* $Header: wiprqvds.pls 120.0 2005/05/25 07:33:52 appldev noship $ */

   x_statement varchar2(2000);


/******************* DELETE REQUIREMENT ****************************/
/* inventory_item_id must not be null if load_type is 2, for DELETE */
Procedure Del_Req_Info_Exist(p_group_id 	in number,
			p_wip_entity_id		in number,
			p_organization_id	in number,
			p_substitution_type	in number,
			p_operation_seq_num	in number);


/* operations, resources, should all match and exist; for delete */
Procedure REQ_JOB_Match (p_group_id  		in number,
			p_wip_entity_id		in number,
			p_organization_id	in number,
			p_substitution_type	in number,
			p_operation_seq_num	in number,
			p_inventory_item_id_old	in number);

/* for delete only */
Procedure Safe_Delete (p_group_id  		in number,
			p_wip_entity_id		in number,
			p_organization_id	in number,
			p_substitution_type	in number,
			p_operation_seq_num	in number,
			p_inventory_item_id_old	in number);


/* main delete, call the above three */
Procedure Delete_Req(p_group_id               in number,
                        p_wip_entity_id         in number,
                        p_organization_id       in number,
                        p_substitution_type     in number);


/************************ ADD REQUIREMENT ******************/

/* inventory_item_id, quantity_per_assembly  must not be null
   if load_type is 2, for ADD */
Procedure Add_Req_Info_Exist(p_group_id 	in number,
			p_wip_entity_id		in number,
			p_organization_id	in number,
			p_substitution_type	in number,
			p_operation_seq_num	in number);

/* operations, resources, should NOT exist; for add */
Procedure REQ_JOB_NOT_EXIST (p_group_id  	in number,
			p_wip_entity_id		in number,
			p_organization_id	in number,
			p_substitution_type	in number,
			p_operation_seq_num	in number,
			p_inventory_item_id_new	in number);


/* for add only */
Procedure Valid_Requirement(p_group_id  	in number,
			p_wip_entity_id		in number,
			p_organization_id	in number,
			p_substitution_type	in number,
			p_operation_seq_num	in number,
			p_inventory_item_id_new	in number);

/* main add, call the above three */
Procedure add_Req(p_group_id               in number,
                        p_wip_entity_id         in number,
                        p_organization_id       in number,
                        p_substitution_type     in number);


/* called after defaulting */
Procedure Post_Default(p_group_id  	number,
			p_wip_entity_id 	number,
			p_organization_id 	number,
			p_substitution_type	number,
			p_operation_seq_num	number,
			p_inventory_item_id_new	number);

/************************ CHANGE REQUIREMENT ******************/
Procedure Change_Req(p_group_id               in number,
                        p_wip_entity_id         in number,
                        p_organization_id       in number,
                        p_substitution_type     in number);

Procedure Chng_Req_Info_Exist(p_group_id	number,
                   p_wip_entity_id		number,
                   p_organization_id		number,
                   p_substitution_type		number,
                   p_operation_seq_num		number);


/**************** Utilities for ERROR ***********************/

/* all required columns are not null */
function IS_Error(p_group_id            number,
                        p_wip_entity_id         number,
                        p_organization_id       number,
                        p_substitution_type     number,
			p_operation_seq_num	number,
			p_inventory_item_id_old	number,
			p_inventory_item_id_new	number) return number;

/* culomns could be null */
function Info_Missing(p_group_id                number,
                   p_wip_entity_id              number,
                   p_organization_id            number,
                   p_substitution_type          number,
                   p_operation_seq_num          number) return number;


END WIP_REQUIREMENT_VALIDATIONS;

 

/
