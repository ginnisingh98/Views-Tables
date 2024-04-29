--------------------------------------------------------
--  DDL for Package CS_CONTRACT_BILLING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_CONTRACT_BILLING" AUTHID CURRENT_USER as
/* $Header: csctbils.pls 115.0 99/07/16 08:48:58 porting ship  $ */

 PROCEDURE generate_billing_lines(
                               ERRBUF    OUT   VARCHAR2,
                               RETCODE    OUT   NUMBER,
                               P_DEFAULT_DATE    IN   DATE,
                               P_WINDOW	         IN  NUMBER,
                               P_CONTRACT_NUMBER	         IN  NUMBER
                                );

 FUNCTION get_billing_lines(
                               P_DATE_RANGE    IN   DATE,
                               P_CONTRACT_NUMBER	         IN  NUMBER
                           ) RETURN NUMBER;

PROCEDURE Process_And_Insert_Records
			    (
				P_BILLED_UNTIL_DATE     		IN OUT DATE,
				P_NEXT_BILL_DATE     		IN OUT DATE,
				P_BILL_ON 				IN OUT NUMBER,
				P_FIRST_BILL_DATE     		IN DATE,
				P_START_DATE_ACTIVE     		IN DATE,
				P_END_DATE_ACTIVE       		IN DATE,
				P_CONTRACT_ID	      		IN NUMBER,
				P_CP_SERVICE_ID      		IN NUMBER,
				P_INVOICE_AMOUNT      		IN NUMBER,
				P_EXTENDED_PRICE      		IN NUMBER,
				P_DURATION_QUANTITY    		IN NUMBER,
				P_SERVICE_INVENTORY_ITEM_ID 	IN NUMBER,
				P_UNIT_OF_MEASURE_CODE  		IN VARCHAR2,
				P_BILLING_FREQUENCY_PERIOD  	IN VARCHAR2
 			     ) ;

 FUNCTION Process_Billing_records
		   (
				P_BILLING_AMOUNT     		OUT NUMBER,
				P_BILLED_FROM_DATE  		OUT DATE   ,
				P_BILLED_UNTIL_DATE  		IN OUT DATE   ,
				P_NEXT_BILL_DATE     		IN OUT DATE 	,
				P_BILL_ON				 	IN OUT NUMBER ,
				P_FIRST_BILL_DATE    		IN DATE 	,
				P_START_DATE_ACTIVE  		IN DATE   ,
				P_END_DATE_ACTIVE    		IN DATE   ,
				P_INVOICE_AMOUNT     		IN NUMBER 	,
				P_EXTENDED_PRICE     		IN NUMBER 	,
				P_DURATION_QUANTITY  		IN NUMBER  	,
				P_SERVICE_INVENTORY_ITEM_ID 	IN NUMBER ,
				P_UNIT_OF_MEASURE_CODE 		IN VARCHAR2 ,
				P_BILLING_FREQUENCY_PERIOD 	IN VARCHAR2
				)RETURN NUMBER;

 FUNCTION Process_First_Bill_Date
		   (
				P_BILLING_AMOUNT     			OUT NUMBER,
				P_BILLED_FROM_DATE  			OUT DATE   ,
				P_BILLED_UNTIL_DATE  			IN OUT DATE   ,
				P_NEXT_BILL_DATE     			IN OUT DATE 	,
				P_BILL_ON					 	IN OUT NUMBER ,
				P_FIRST_BILL_DATE    			IN DATE 	,
				P_START_DATE_ACTIVE  			IN DATE   ,
				P_END_DATE_ACTIVE  		  		IN DATE   ,
				P_EXTENDED_PRICE     			IN NUMBER 	,
				P_DURATION_QUANTITY  			IN NUMBER  	,
				P_SERVICE_INVENTORY_ITEM_ID 		IN NUMBER ,
				P_UNIT_OF_MEASURE_CODE 			IN VARCHAR2 ,
				P_BILLING_FREQUENCY_PERIOD 		IN VARCHAR2
				)RETURN NUMBER;

 FUNCTION Process_Next_Bill_Date
		   (
				P_BILLING_AMOUNT     			OUT NUMBER,
				P_BILLED_FROM_DATE  			OUT DATE   ,
				P_BILLED_UNTIL_DATE  			IN OUT DATE   ,
				P_NEXT_BILL_DATE     			IN OUT DATE 	,
				P_BILL_ON					 	IN OUT NUMBER ,
				P_FIRST_BILL_DATE    			IN DATE 	,
				P_START_DATE_ACTIVE  			IN DATE   ,
				P_END_DATE_ACTIVE    			IN DATE   ,
				P_INVOICE_AMOUNT   		  		IN NUMBER 	,
				P_EXTENDED_PRICE     			IN NUMBER 	,
				P_DURATION_QUANTITY  			IN NUMBER  	,
				P_SERVICE_INVENTORY_ITEM_ID 		IN NUMBER ,
				P_UNIT_OF_MEASURE_CODE 			IN VARCHAR2 ,
				P_BILLING_FREQUENCY_PERIOD 		IN VARCHAR2
				)RETURN NUMBER;

FUNCTION get_invoiced_amount(
                               P_INVOICED_SERVICE_AMOUNT    OUT   NUMBER,
                               P_BILLED_UNTIL_DATE    OUT   DATE,
                               P_CONTRACT_ID	         IN  NUMBER,
                               P_CP_SERVICE_ID	    IN  NUMBER
                                ) return NUMBER;

PROCEDURE Print_Error;

FUNCTION Insert_cs_cont_bill_iface
			(
				P_BILLING_AMOUNT     	IN NUMBER,
				P_billed_from_date     	IN DATE,
				P_billed_until_date     	IN DATE,
				P_transaction_date     	IN DATE,
				P1_CONTRACT_ID     		IN NUMBER,
				P1_CP_SERVICE_ID    		IN NUMBER,
				P_quantity    		IN NUMBER
			) RETURN NUMBER;

FUNCTION Update_CS_CP_Services
			(
				P_CONTRACT_ID     		IN NUMBER,
				P_CP_SERVICE_ID    		IN NUMBER,
				P_NEXT_BILL_DATE     	IN DATE
			) RETURN NUMBER;



 PROCEDURE Calc_Actual_Next_Bill_date(
                               P_NEXT_BILL_DATE    IN OUT  DATE,
                               P_BILL_ON	      IN OUT NUMBER
                                );

 FUNCTION Calculate_Next_Bill_date(
                               P_LAST_TXN_DATE     IN  DATE,
                               P_END_DATE_ACTIVE 	 IN  DATE,
                               P_BILL_ON	      IN OUT NUMBER,
                               P_INVENTORY_ITEM_ID IN  NUMBER,
                               P_FROM_UNIT         IN  VARCHAR2
                                )RETURN DATE;

 FUNCTION Get_Final_Adjustment(
                               P_CONC_PROGRAM      IN  VARCHAR2,
                               P_TXN_START_DATE    IN  DATE,
                               P_TXN_END_DATE      IN  DATE,
                               P_SERVICE_AMOUNT    IN  NUMBER,
                               P_SERVICE_DURATION  IN  NUMBER,
                               P_INVENTORY_ITEM_ID IN  NUMBER,
                               P_SERVICE_PERIOD    IN  VARCHAR2,
                               P_BILL_FREQUENCY    IN  VARCHAR2
                                )RETURN NUMBER;

 FUNCTION Calculate_Txn_Amount(
                               P_CONC_PROGRAM      IN  VARCHAR2,
                               P_TXN_START_DATE    IN  DATE,
                               P_TXN_END_DATE      IN  DATE,
                               P_SERVICE_AMOUNT    IN  NUMBER,
                               P_SERVICE_DURATION  IN  NUMBER,
                               P_INVENTORY_ITEM_ID IN  NUMBER,
                               P_SERVICE_PERIOD    IN  VARCHAR2,
                               P_BILL_FREQUENCY    IN  VARCHAR2
                                )RETURN NUMBER;

 FUNCTION Calculate_Average_Amount(
                               P_CONC_PROGRAM      IN  VARCHAR2,
                               P_SERVICE_AMOUNT    IN  NUMBER,
                               P_SERVICE_DURATION  IN  NUMBER,
                               P_INVENTORY_ITEM_ID IN  NUMBER,
                               P_FROM_UNIT         IN  VARCHAR2,
                               P_TO_UNIT           IN  VARCHAR2
                                ) RETURN NUMBER;
 FUNCTION Convert_Duration(
                               P_CONC_PROGRAM      IN  VARCHAR2,
                               P_SERVICE_DURATION  IN  NUMBER,
                               P_INVENTORY_ITEM_ID IN  NUMBER,
                               P_FROM_UNIT         IN  VARCHAR2,
                               P_TO_UNIT           IN  VARCHAR2
                                )RETURN NUMBER;


END CS_CONTRACT_BILLING;

 

/
