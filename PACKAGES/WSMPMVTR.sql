--------------------------------------------------------
--  DDL for Package WSMPMVTR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSMPMVTR" AUTHID CURRENT_USER AS
/* $Header: WSMMVTRS.pls 115.4 2002/02/22 18:03:01 sbhaskar ship $ */
/* obsoleted no longer needed, comment out all lines, dgosain
FUNCTION CUSTOM_VALIDATION(
p_transaction_id 		IN 	NUMBER,
p_transaction_quantity 		IN 	NUMBER,
p_transaction_uom 		IN 	VARCHAR2,
p_transaction_type 		IN 	NUMBER,
p_fm_operation_seq_num 		IN 	NUMBER,
p_fm_operation_code 		IN 	VARCHAR2,
p_fm_intraoperation_step_type	IN 	NUMBER,
p_to_operation_seq_num 		IN 	NUMBER,
p_to_operation_code 		IN 	VARCHAR2,
p_to_intraoperation_step_type 	IN 	NUMBER,
p_wip_entity_name 		IN 	VARCHAR2,
p_organization_code 		IN 	VARCHAR2,
p_new_name 			OUT 	VARCHAR2,
x_error_code                    OUT     NUMBER,
x_error_msg                     OUT     VARCHAR2
) RETURN NUMBER;
*/
END WSMPMVTR;

 

/
