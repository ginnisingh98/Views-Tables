--------------------------------------------------------
--  DDL for Package WIP_JOB_DTLS_VALIDATIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_JOB_DTLS_VALIDATIONS" AUTHID CURRENT_USER AS
/* $Header: wipjdvds.pls 115.8 2003/04/11 23:08:18 rseela ship $ */

x_statement VARCHAR2(2000);

/********* check each job in a given group ********************************/

/* Jobs must exist */
Procedure Jobs (p_group_id  number,
                p_parent_header_id number);

/* job must be in status unreleased, released, complete, hold */
Procedure Job_Status(p_group_id number,
                     p_parent_header_id number);

/* Job must be NOT firmed */
Procedure Is_Firm(p_group_id	number,
                  p_parent_header_id number);

/****** Check for each load_type/substitution_type in a given job **********/

/* operation_seq_num must exist in that job */
Procedure OP_Seq_Num(p_group_id            number,
                     p_parent_header_id    number,
                          p_wip_entity_id       number,
                          p_organization_id     number);

/* Load_type must be 1(resource) or 2 (Requirement),
   Substitution type must be 1(delete) or 2 (add) or 3 Delete) */
Procedure Load_Sub_Types (p_group_id 		number,
                          p_parent_header_id    number,
	 		  p_wip_entity_id	number,
			  p_organization_id  	number);

/* must be created and updated by valid user */
PROCEDURE Last_Updated_By(p_group_id 		number,
                          p_parent_header_id    number,
	 		  p_wip_entity_id	number,
			  p_organization_id  	number);

PROCEDURE Created_By(p_group_id 		number,
                     p_parent_header_id         number,
	 		  p_wip_entity_id	number,
			  p_organization_id  	number);


/*********** Utilites to detect and display errors *********************/

/* If any row for a discrete job fails, all rows for that job will fail */
Procedure ERROR_ALL_IF_ANY(p_group_id 		number,
                           p_parent_header_id   number,
			   P_wip_entity_id	number,
			   p_organization_id	number);

END WIP_JOB_DTLS_VALIDATIONS;

 

/
