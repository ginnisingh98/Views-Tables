--------------------------------------------------------
--  DDL for Package CS_CALCULATE_CREDIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_CALCULATE_CREDIT" AUTHID CURRENT_USER as
/* $Header: csxstsvs.pls 115.1 99/07/16 09:09:17 porting shi $ */


PROCEDURE CS_CALCULATE_CREDIT (x_cp_service_id   	   IN NUMBER,
				x_terminate_effective_date IN DATE,
				x_first_cp_service_txn_id  IN OUT NUMBER,
				x_first_amount		   IN OUT NUMBER,
			        x_total_credit_amount      IN OUT NUMBER,
				x_total_credit_percent     IN OUT NUMBER,
				x_multi_txns		   IN OUT VARCHAR2
			       );


PROCEDURE CREATE_INTERACTION_FROM_FORM(control_user_id       IN  NUMBER,
							    cp_cp_service_id      IN NUMBER,
							    parent_interaction_id IN VARCHAR2,
							    cp_last_update_login  IN NUMBER,
							    cp_bill_to_contact_id IN NUMBER,
							    return_status         OUT VARCHAR2,
							    return_msg            OUT VARCHAR2);
END CS_CALCULATE_CREDIT;

 

/
