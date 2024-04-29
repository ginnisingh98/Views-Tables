--------------------------------------------------------
--  DDL for Package GMS_MULTI_FUNDING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMS_MULTI_FUNDING" AUTHID CURRENT_USER AS
-- $Header: gmsmfaps.pls 120.0.12010000.2 2008/10/30 11:55:27 rrambati ship $

p_msg_count NUMBER;

Procedure CREATE_AWARD_PROJECT( X_Project_Name                 IN VARCHAR2,
                                X_Project_Number               IN VARCHAR2,
                                X_Customer_Id                  IN NUMBER,
                                X_Bill_to_Customer_Id                  IN NUMBER,
                                X_Carrying_Out_Organization_Id IN NUMBER,
                                X_Award_Id                     IN NUMBER,
                                X_IDC_Schedule_Id              IN NUMBER,
                                X_IDC_Schedule_Fixed_Date      IN DATE,
                                X_Labor_Invoice_Format_Id      IN NUMBER,
                                X_Non_Labor_Invoice_Format_Id  IN NUMBER,
                                X_Person_Id                    IN NUMBER,
                                X_Term_Id                      IN NUMBER,
                                X_Start_Date                   IN DATE,
                                X_End_Date                     IN DATE,
                                X_Close_Date                   IN DATE,
                                X_Agreement_Type               IN VARCHAR2,
				X_Revenue_Limit_Flag	       IN VARCHAR2,
				X_Invoice_Limit_Flag           IN VARCHAR2, /*Bug 6642901*/
				X_Billing_Frequency	       IN VARCHAR2,
				X_billing_Cycle_Id             IN NUMBER,
				X_Billing_Offset               IN NUMBER,
                                X_Bill_To_Address_Id_IN        IN  NUMBER,
                                X_Ship_To_Address_Id_IN        IN  NUMBER,
                                X_Bill_To_Contact_Id_IN        IN  NUMBER,
                                X_Ship_To_Contact_Id_IN        IN  NUMBER,
                                X_output_tax_code              IN  VARCHAR2,
                                X_retention_tax_code           IN  VARCHAR2,
				X_ORG_ID		       IN  NUMBER,  --Shared Service Enhancement
                                X_Award_Project_Id             OUT NOCOPY NUMBER,
                                X_Agreement_Id                 OUT NOCOPY NUMBER,
				X_Bill_To_Address_Id_OUT       OUT NOCOPY NUMBER,
				X_Ship_To_Address_Id_OUT       OUT NOCOPY NUMBER,
                                X_App_Short_Name               OUT NOCOPY VARCHAR2,
				X_Msg_Count  		       OUT NOCOPY NUMBER,
                                RETCODE                        OUT NOCOPY VARCHAR2,
                                ERRBUF                         OUT NOCOPY VARCHAR2);

-- Bug Fix 2994625
-- PA.K rollup patch has a new functionality that allows users to store billi to customer
-- seperately from project customers.
-- Now we can store our LOC customer information in the bill_to_customer column of pa_project_customer
-- table.
-- Adding a new parameter to pass the LOC customer id seperately from the funding source id

Procedure UPDATE_AWARD_PROJECT(X_Award_Id         IN NUMBER,
                               X_Award_Project_Id IN NUMBER,
                               X_Agreement_Id     IN NUMBER,
                               X_Project_Number   IN VARCHAR2,
                               X_Project_Name     IN VARCHAR2,
                               X_Customer_Id      IN NUMBER,
                               X_Bill_to_customer_id      IN NUMBER,
                               X_Carrying_Out_Organization_Id IN NUMBER,
                               X_IDC_Schedule_Id  IN NUMBER,
                               X_IDC_Schedule_Fixed_Date IN DATE,
                               X_Labor_Invoice_Format_Id IN NUMBER,
                               X_Non_Labor_Invoice_Format_Id IN NUMBER,
                               X_Person_Id_Old    IN NUMBER,
 			       X_Person_Id_New    IN NUMBER,
                               X_Term_Id          IN NUMBER,
                               X_Start_Date       IN DATE,
                               X_End_Date         IN DATE,
                               X_Close_Date       IN DATE,
                               X_Agreement_Type   IN VARCHAR2,
			       X_Revenue_Limit_Flag IN VARCHAR2,
			       X_Invoice_Limit_Flag IN VARCHAR2, /*Bug 6642901*/
                               X_Billing_Frequency IN VARCHAR2,
			       X_Billing_Cycle_ID       IN NUMBER,
			       X_Billing_Offset         IN NUMBER,
			       X_Bill_To_Address_Id_IN  IN NUMBER,
			       X_Ship_To_Address_Id_IN	IN NUMBER,
                               X_output_tax_code              IN  VARCHAR2,
                               X_retention_tax_code           IN  VARCHAR2,
			       X_Bill_To_Address_Id_OUT  OUT NOCOPY NUMBER,
			       X_Ship_To_Address_Id_OUT	 OUT NOCOPY NUMBER,
                               X_App_Short_Name   OUT NOCOPY VARCHAR2,
			       X_Msg_Count        OUT NOCOPY NUMBER,
                               RETCODE            OUT NOCOPY VARCHAR2,
                               ERRBUF             OUT NOCOPY VARCHAR2) ;

Procedure DELETE_AWARD_PROJECT(X_Award_Id         IN NUMBER,
                               X_Award_Project_Id IN NUMBER,
                               X_Agreement_Id     IN NUMBER,
                               X_App_Short_Name   OUT NOCOPY VARCHAR2,
			       X_Msg_Count        OUT NOCOPY NUMBER,
                               RETCODE            OUT NOCOPY VARCHAR2,
                               ERRBUF             OUT NOCOPY VARCHAR2) ;

Procedure CREATE_AWARD_FUNDING( X_Installment_Id IN NUMBER,
                                X_Allocated_Amount IN NUMBER,
                                X_Date_Allocated IN DATE,
                                X_GMS_Project_Funding_Id IN NUMBER,
                                X_Project_Funding_Id  OUT NOCOPY NUMBER,
                                X_App_Short_Name OUT NOCOPY VARCHAR2,
			        X_Msg_Count        OUT NOCOPY NUMBER,
                                RETCODE OUT NOCOPY VARCHAR2,
                                ERRBUF OUT NOCOPY VARCHAR2);

Procedure UPDATE_AWARD_FUNDING(	   X_Project_Funding_Id IN NUMBER,
                                   X_Installment_Id IN NUMBER,
                                   X_Old_Allocated_Amount IN NUMBER,
                                   X_New_Allocated_Amount IN NUMBER,
                                   X_Old_Date_Allocated IN DATE,
                                   X_New_Date_Allocated IN DATE,
                                   X_App_Short_Name OUT NOCOPY VARCHAR2,
			           X_Msg_Count        OUT NOCOPY NUMBER,
                                   RETCODE OUT NOCOPY VARCHAR2,
                                   ERRBUF OUT NOCOPY VARCHAR2);
Procedure DELETE_AWARD_FUNDING(X_Project_Funding_Id IN NUMBER,
                                   X_Installment_Id IN NUMBER,
                                   X_Allocated_Amount IN NUMBER,
                                   X_App_Short_Name  OUT NOCOPY VARCHAR2,
			           X_Msg_Count        OUT NOCOPY NUMBER,
                                   RETCODE OUT NOCOPY  VARCHAR2,
                                   ERRBUF OUT NOCOPY VARCHAR2);

Procedure CREATE_AGREEMENT(X_Row_Id OUT NOCOPY VARCHAR2,
                           X_Agreement_Id OUT NOCOPY NUMBER,
                           X_Customer_Id IN NUMBER,
                           X_Agreement_Num IN VARCHAR2,
                           X_Agreement_Type IN VARCHAR2,
			   X_Revenue_Limit_Flag IN VARCHAR2 DEFAULT 'N',-- Bug 2498348 , changed the default value from 'Y' to 'N'
			   X_Invoice_Limit_Flag IN VARCHAR2 DEFAULT 'N', /*Bug 6642901*/
                           X_Owned_By_Person_Id IN NUMBER,
                           X_Term_Id IN NUMBER,
                           X_Close_Date IN DATE,
			   X_Org_Id	IN NUMBER, --Shared Service Enhancement
                           RETCODE OUT NOCOPY VARCHAR2,
                           ERRBUF OUT NOCOPY VARCHAR2);

Procedure DELETE_AGREEMENT(X_Agreement_Id IN NUMBER,
                           RETCODE OUT NOCOPY VARCHAR2,
                           ERRBUF OUT NOCOPY VARCHAR2);

Procedure UPDATE_AGREEMENT(X_Agreement_Id IN NUMBER,
                           X_Agreement_Num IN VARCHAR2 DEFAULT NULL,
                           X_Agreement_Type IN VARCHAR2 DEFAULT NULL,
                           X_Revenue_Limit_Flag IN VARCHAR2 DEFAULT NULL,
                           X_Invoice_Limit_Flag IN VARCHAR2 DEFAULT NULL, /*Bug 6642901*/
                           X_Customer_Id IN NUMBER DEFAULT NULL,
                           X_Owned_By_Person_Id IN NUMBER DEFAULT NULL,
                           X_Term_Id IN NUMBER DEFAULT NULL,
                           X_Amount IN NUMBER DEFAULT 0,
                           X_Close_Date IN DATE DEFAULT NULL,
                           RETCODE OUT NOCOPY VARCHAR2,
                           ERRBUF  OUT NOCOPY VARCHAR2) ;

END GMS_MULTI_FUNDING;

/
