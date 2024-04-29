--------------------------------------------------------
--  DDL for Package CS_AR_FEEDER_PROGRAM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_AR_FEEDER_PROGRAM" AUTHID CURRENT_USER AS
/* $Header: csctfdrs.pls 115.1 99/07/16 08:52:41 porting ship $ */


FUNCTION Main_Procedure RETURN NUMBER;


FUNCTION 	Get_Interface_Lines RETURN number;


FUNCTION  Update_CS_Cont_Bill_Iface RETURN number;

FUNCTION Process_Invoice(
						 p_created_by 				IN NUMBER,
						 p_contracts_interface_id	IN NUMBER,
						 p_contract_id 			IN NUMBER,
						 p_cp_service_transaction_id 	IN NUMBER,
						 p_cp_service_id 			IN NUMBER,
						 p_contract_billing_id 		IN NUMBER,
						 p_trx_start_date 			IN DATE,
						 p_trx_end_date 			IN DATE,
						 p_trx_date 				IN DATE,
						 p_trx_amount 				IN NUMBER,
						 p_reason_code 			IN VARCHAR2,
						 p_reason_comments 			IN VARCHAR2,
						 p_cp_quantity 			IN NUMBER,
						 p_ar_trx_type				IN VARCHAR2
				)RETURN NUMBER ;


FUNCTION Process_Credit_Memo(
						 p_created_by 				IN NUMBER,
						 p_contracts_interface_id	IN NUMBER,
						 p_contract_id 			IN NUMBER,
						 p_cp_service_transaction_id 	IN NUMBER,
						 p_cp_service_id 			IN NUMBER,
						 p_contract_billing_id 		IN NUMBER,
						 p_trx_start_date 			IN DATE,
						 p_trx_end_date 			IN DATE,
						 p_trx_date 				IN DATE,
						 p_trx_amount 				IN NUMBER,
						 p_reason_code 			IN VARCHAR2,
						 p_reason_comments 			IN VARCHAR2,
						 p_cp_quantity 			IN NUMBER,
						 p_ar_trx_type				IN VARCHAR2
				)RETURN NUMBER ;




FUNCTION multi_line_cm(
					 p_cp_service_transaction_id       IN NUMBER,
					 p_cp_service_id   				IN NUMBER,
					 p_contract_id 				IN NUMBER,
					 p_reason_code 				IN VARCHAR2,
					 p_reason_comments 				IN VARCHAR2,
					 p_trx_start_date 				IN DATE,
					 p_trx_end_date 				IN DATE,
					 p_created_by 					IN NUMBER
					)RETURN NUMBER ;



PROCEDURE  reset_cs_cont_bill_iface
					(p_contracts_interface_id IN NUMBER);

FUNCTION  Delete_cs_cont_bill_iface
					(p_contracts_interface_id IN NUMBER)
		RETURN number;

FUNCTION 	Check_duplicate_txn_Lines(
				p_duplicate 				OUT VARCHAR2,
				p_trx_start_date 			IN  DATE,
				p_cp_service_transaction_id 	IN  NUMBER
				)RETURN NUMBER ;


FUNCTION	 update_cs_cp_services
		    		(p_cp_service_id NUMBER)RETURN NUMBER ;




FUNCTION update_cs_cp_service_trans
		    (
				p_cp_service_id 			IN  NUMBER,
				p_trx_start_date 			IN  DATE,
				p_created_by 				IN  NUMBER,
				p_cp_service_transaction_id 	IN  NUMBER
			)return NUMBER;


FUNCTION  insert_cs_cp_service_trans
		(
		   p_cp_service_transaction_id 	IN NUMBER,
		   p_cp_service_id 				IN NUMBER,
		   p_contract_id 				IN NUMBER,
		   p_reason_code 				IN VARCHAR2,
		   p_reason_comments 			IN VARCHAR2,
		   p_trx_start_date				IN DATE,
		   p_trx_end_date 				IN DATE
				) return NUMBER ;



FUNCTION  insert_cs_contracts_billing
					(
						p_contract_id     IN  NUMBER,
						p_cp_service_id   IN  NUMBER,
						p_trx_end_date    IN  DATE,
						p_trx_type        IN  VARCHAR2
					)return NUMBER ;


FUNCTION insert_ra_interface_lines
				(
				 p_cp_service_transaction_id 	IN NUMBER,
				 p_contract_id 		 	IN NUMBER,
				 p_cp_service_id 		 	IN NUMBER,
				 p_contract_billing_id   	IN NUMBER,
				 p_current_billing_id	   	IN NUMBER,
				 p_trx_start_date 			IN DATE,
				 p_trx_end_date 			IN DATE,
				 p_trx_date				IN DATE,
				 p_trx_amount	 			IN NUMBER,
				 p_cp_quantity	 			IN NUMBER,
				 p_ar_trx_type	 			IN VARCHAR2
				 )
				 return NUMBER ;

PROCEDURE print_Error;

END CS_AR_FEEDER_PROGRAM;


 

/
