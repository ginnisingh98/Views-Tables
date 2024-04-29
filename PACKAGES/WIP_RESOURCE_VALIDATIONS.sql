--------------------------------------------------------
--  DDL for Package WIP_RESOURCE_VALIDATIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_RESOURCE_VALIDATIONS" AUTHID CURRENT_USER AS
/* $Header: wiprsvds.pls 120.0 2005/05/25 08:07:09 appldev noship $ */

   x_statement varchar2(2000);


/**************** DELETE RESOURCES ************************************/

/* resource_seq_num, resource_id_old must not be null when delete resource */
Procedure Del_Res_Info_Exist(p_group_id  	number,
			p_wip_entity_id 	number,
			p_organization_id 	number,
			p_substitution_type	number,
			p_operation_seq_num	number);


/* job/operations/resource_seq/resource_id_old all match and exist;
   called when Delete Resources  */
Procedure RES_JOB_Match (p_group_id  		number,
			p_wip_entity_id 	number,
			p_organization_id 	number,
			p_substitution_type	number,
			p_operation_seq_num	number,
			p_resource_seq_num	number,
			p_resource_id_old	number);

/* check WCTI, WT for job/ops/resource match */
Procedure Safe_Delete (p_group_id  		number,
			p_wip_entity_id 	number,
			p_organization_id 	number,
			p_substitution_type	number,
			p_operation_seq_num	number,
			p_resource_seq_num	number,
			p_resource_id_old	number);

/* outside processing; called by Delete */
Procedure Safe_PO (p_group_id  			number,
			p_wip_entity_id 	number,
			p_organization_id 	number,
			p_substitution_type	number,
			p_operation_seq_num	number,
			p_resource_seq_num	number,
			p_resource_id_old	number);

/* main procedure, call the above four */
Procedure Delete_Resource (p_group_id           number,
                        p_wip_entity_id         number,
                        p_organization_id       number,
                        p_substitution_type     number);

/***********************ADD RESOURCES ***********************************/
/* when add resources, resource_seq_num, resource_id_new and
   usage_rate_or_amount can not be null */
Procedure Add_Res_Info_Exist(p_group_id  	number,
			p_wip_entity_id 	number,
			p_organization_id 	number,
			p_substitution_type	number,
			p_operation_seq_num	number);

/* called when Add; resource-to-be-added should be valid */
Procedure Valid_Resource(p_group_id  		number,
			p_wip_entity_id 	number,
			p_organization_id 	number,
			p_substitution_type	number,
			p_operation_seq_num	number,
			p_resource_seq_num	number,
			p_resource_id_new	number);


/* called when Add; resource_seq_num shouldn't exist */
Procedure Resource_Seq_Num(p_group_id 		number,
			p_wip_entity_id 	number,
			p_organization_id 	number,
			p_substitution_type	number,
			p_operation_seq_num	number,
			p_resource_seq_num	number);

/* called when Add; should be greater than or equal to 0 */
Procedure Usage_Rate_Or_Amount(p_group_id  	number,
			p_wip_entity_id 	number,
			p_organization_id 	number,
			p_substitution_type	number,
			p_operation_seq_num	number,
			p_resource_seq_num	number,
			p_resource_id_new	number,
			p_usage_rate_or_amount	number);

/* bug 2951776 - Check that Assigned_Units is greater than 0 */
Procedure Assigned_Units(p_group_id        number,
                         p_wip_entity_id   number,
                         p_organization_id number,
                         p_load_type  number,
                         p_substitution_type number,
                         p_operation_seq_num number,
                         p_resource_seq_num number);

/* main procedure to add resource, call the above */
Procedure Add_Resource(p_group_id               number,
                        p_wip_entity_id         number,
                        p_organization_id       number,
                        p_substitution_type     number);

/**************** CAHNGE RESOURCES ************************************/

Procedure Change_Resource(p_group_id            number,
                        p_wip_entity_id         number,
                        p_organization_id       number,
                        p_substitution_type     number);

Procedure Validate_Assigned_Units(p_group_id        number,
                   p_wip_entity_id              number,
                   p_organization_id            number,
                   p_substitution_type          number,
                   p_operation_seq_num          number,
                   p_resource_seq_num           number);


Procedure Chng_Res_Info_Exist(p_group_id	number,
                   p_wip_entity_id		number,
                   p_organization_id		number,
                   p_substitution_type		number,
                   p_operation_seq_num		number);

Procedure Check_Res_Substitution(p_group_id        number,
                      p_wip_entity_id              number,
                      p_organization_id            number,
                      p_substitution_type          number,
                      p_operation_seq_num          number,
                      p_resource_seq_num           number,
                      p_resource_id_old            number);

/********************** ERROR HANDLING *********************************/
/* Is there errors for the previous validations? It doesn't pass more resource
   parameters, because it is unique up to resource_seq_num */
function IS_Error(p_group_id            number,
                        p_wip_entity_id         number,
                        p_organization_id       number,
                        p_substitution_type     number,
			p_operation_seq_num	number,
			p_resource_seq_num	number) return number;

/* Check errors occurred when there could be NULL data */
function Info_Missing(p_group_id		number,
                   p_wip_entity_id		number,
                   p_organization_id		number,
                   p_substitution_type		number,
                   p_operation_seq_num		number) return number;



/**************** Validation for substitute resources ******************/
Procedure Substitute_Info (p_group_id              number,
                     p_wip_entity_id               number,
                     p_organization_id             number,
		     p_substitution_type           number,
		     p_operation_seq_num           number,
		     p_resource_seq_num            number);

Procedure Delete_Sub_Resource (p_group_id           number,
                        p_wip_entity_id         number,
                        p_organization_id       number,
                        p_substitution_type     number);

Procedure Add_Sub_Resource(p_group_id               number,
                        p_wip_entity_id         number,
                        p_organization_id       number,
                        p_substitution_type     number);

Procedure Change_Sub_Resource(p_group_id            number,
                        p_wip_entity_id         number,
                        p_organization_id       number,
                        p_substitution_type     number);

Procedure Check_Sub_Groups (p_group_id NUMBER,
                                                               p_organization_id NUMBER,
                                                               p_wip_entity_id NUMBER);


END WIP_RESOURCE_VALIDATIONS;

 

/
