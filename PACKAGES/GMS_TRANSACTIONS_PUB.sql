--------------------------------------------------------
--  DDL for Package GMS_TRANSACTIONS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMS_TRANSACTIONS_PUB" AUTHID CURRENT_USER AS
-- $Header: gmstpubs.pls 120.1 2005/07/26 14:38:44 appldev ship $

	-- -------------------------------------------------------------
	-- Common Table handler for Table GMS_transaction Interface all
	-- -------------------------------------------------------------

	PROCEDURE LOAD_GMS_XFACE_API ( 	p_rec gms_transaction_interface_all%ROWTYPE
					,P_OUTCOME OUT NOCOPY varchar2 ) ;

	PROCEDURE UPDATE_GMS_XFACE_API ( 	p_rec gms_transaction_interface_all%ROWTYPE
						, P_OUTCOME OUT NOCOPY varchar2 ) ;

	PROCEDURE DELETE_GMS_XFACE_API ( 	p_rec gms_transaction_interface_all%ROWTYPE
						, P_OUTCOME OUT NOCOPY  varchar2 ) ;

	PROCEDURE validate_transaction( P_project_id        	    IN NUMBER
           				,  P_task_id                IN NUMBER
	   				,  P_award_id		    IN NUMBER
           				,  P_expenditure_type       IN VARCHAR2
           				,  P_expenditure_item_date  IN DATE
					,  P_calling_module	    IN varchar2
           				,  P_OUTCOME                OUT NOCOPY VARCHAR2) ;

--  This function is used by Procedure validate_award. Procedure Validate_award is used by
--  GMS_OIE_INT_PKG (OIE Integration Validation Package)

	FUNCTION Is_Sponsored_Project(x_project_id	IN NUMBER) RETURN BOOLEAN;

--  This procedure is called from the validation package for Internet Expenses.
--  This is called if Grants is implemented and after pressing the Submit for the Expense Report.
--  All validations for the Award entered are done and the status code is returned indicating success
--  or failure. If there is a failure, then the error message is returned via x_err_msg.

        PROCEDURE validate_award ( X_project_id         	IN NUMBER,
                                   X_task_id            	IN NUMBER,
                                   X_award_id           	IN NUMBER,
                                   X_award_number       	IN VARCHAR2,
                                   X_expenditure_type   	IN VARCHAR2,
                                   X_expenditure_item_date 	IN DATE,
                                   X_calling_module     	IN VARCHAR2,
                                   X_status             	IN OUT NOCOPY VARCHAR2,
                                   X_err_msg            	OUT NOCOPY VARCHAR2 );

END GMS_TRANSACTIONS_PUB;

 

/
