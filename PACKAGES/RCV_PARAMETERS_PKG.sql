--------------------------------------------------------
--  DDL for Package RCV_PARAMETERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCV_PARAMETERS_PKG" AUTHID CURRENT_USER as
/* $Header: RCVTIRPS.pls 120.0 2005/06/01 23:15:48 appldev noship $ */

/* Bug 3124881- Added the x_rma_routing_id parameter in the procedures Insert_row,lock_row and Update_row.
*/

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Organization_Id                NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Updated_Login             NUMBER,
                       X_Qty_Rcv_Tolerance              NUMBER,
                       X_Qty_Rcv_Exception_Code         VARCHAR2,
                       X_Enforce_Ship_To_Loc_Code   	VARCHAR2,
                       X_Allow_Express_Del_Flag    	VARCHAR2,
                       X_Days_Early_Rec_Allowed     	NUMBER,
                       X_Days_Late_Rec_Allowed      	NUMBER,
                       X_Rec_Days_Exception_Code    	VARCHAR2,
                       X_Receiving_Routing_Id           NUMBER,
                       X_RMA_routing_id                 NUMBER DEFAULT 1,
                       X_Allow_Substitute_Rec_Flag   	VARCHAR2,
                       X_Allow_Unordered_Rec_Flag   	VARCHAR2,
                       X_Blind_Receiving_Flag           VARCHAR2,
		       X_Request_Id			NUMBER,
		       X_Program_Application_ID		NUMBER,
		       X_Program_Id			NUMBER,
		       X_Program_Update_Date		DATE,
                       X_Receiving_Account_Id           NUMBER,
                       X_Adjustment_Account_Id          NUMBER,
                       X_Clearing_Account_Id            NUMBER,
		       X_Allow_Cascade_Trans		VARCHAR2,
                       X_Receipt_Asn_Exists_Code        VARCHAR2,
                       X_Receipt_Num_Code 		VARCHAR2,
		       X_Manual_Receipt_Num_Type	VARCHAR2,
		       X_Next_Receipt_Num		NUMBER,
                       X_Enforce_RMA_Serial_Num         VARCHAR2 DEFAULT NULL,
                       X_Enforce_RMA_Lot_Num            VARCHAR2 DEFAULT NULL   --INVCONV
                      );


  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Organization_Id                  NUMBER,
		     X_Last_Update_Date                 DATE,
                     X_Last_Updated_By                  NUMBER,
                     X_Creation_Date                    DATE,
                     X_Created_By                       NUMBER,
                     X_Last_Updated_Login               NUMBER,
                     X_Qty_Rcv_Tolerance                NUMBER,
                     X_Qty_Rcv_Exception_Code           VARCHAR2,
                     X_Enforce_Ship_To_Loc_Code    	VARCHAR2,
                     X_Allow_Express_Del_Flag     	VARCHAR2,
                     X_Days_Early_Rec_Allowed     	NUMBER,
                     X_Days_Late_Rec_Allowed        	NUMBER,
                     X_Rec_Days_Exception_Code      	VARCHAR2,
                     X_Receiving_Routing_Id             NUMBER,
                     X_RMA_routing_id                   NUMBER , /* 3124881 */
                     X_Allow_Substitute_Rec_Flag   	VARCHAR2,
                     X_Allow_Unordered_Rec_Flag    	VARCHAR2,
                     X_Blind_Receiving_Flag             VARCHAR2,
		     X_Request_Id			NUMBER,
		     X_Program_Application_ID		NUMBER,
		     X_Program_Id			NUMBER,
		     X_Program_Update_Date		DATE,
                     X_Receiving_Account_Id             NUMBER,
                     X_Adjustment_Account_Id            NUMBER,
                     X_Clearing_Account_Id              NUMBER,
		     X_Allow_Cascade_Trans		VARCHAR2,
                     X_Receipt_Asn_Exists_Code          VARCHAR2,
                     X_Receipt_Num_Code 		VARCHAR2,
	             X_Manual_Receipt_Num_Type		VARCHAR2,
		     X_Next_Receipt_Num			NUMBER,
                     X_Enforce_RMA_Serial_Num           VARCHAR2 DEFAULT NULL,
                     X_Enforce_RMA_Lot_Num            VARCHAR2 DEFAULT NULL  --INVCONV
                    );

  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Organization_Id                NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Updated_Login             NUMBER,
                       X_Qty_Rcv_Tolerance              NUMBER,
                       X_Qty_Rcv_Exception_Code         VARCHAR2,
                       X_Enforce_Ship_To_Loc_Code  	VARCHAR2,
                       X_Allow_Express_Del_Flag    	VARCHAR2,
                       X_Days_Early_Rec_Allowed     	NUMBER,
                       X_Days_Late_Rec_Allowed      	NUMBER,
                       X_Rec_Days_Exception_Code    	VARCHAR2,
                       X_Receiving_Routing_Id           NUMBER,
                       X_RMA_routing_id                 NUMBER DEFAULT 1,
                       X_Allow_Substitute_Rec_Flag 	VARCHAR2,
                       X_Allow_Unordered_Rec_Flag  	VARCHAR2,
                       X_Blind_Receiving_Flag           VARCHAR2,
		       X_Request_Id			NUMBER,
		       X_Program_Application_ID		NUMBER,
		       X_Program_Id			NUMBER,
		       X_Program_Update_Date		DATE,
                       X_Receiving_Account_Id           NUMBER,
                       X_Adjustment_Account_Id          NUMBER,
                       X_Clearing_Account_Id            NUMBER,
		       X_Allow_Cascade_Trans		VARCHAR2,
                       X_Receipt_Asn_Exists_Code        VARCHAR2,
                       X_Receipt_Num_Code 		VARCHAR2,
	               X_Manual_Receipt_Num_Type	VARCHAR2,
		       X_Next_Receipt_Num		NUMBER,
                       X_Enforce_RMA_Serial_Num         VARCHAR2 DEFAULT NULL,
                       X_Enforce_RMA_Lot_Num            VARCHAR2 DEFAULT NULL  --INVCONV
                      );


  PROCEDURE Delete_Row(X_Rowid VARCHAR2);

END RCV_PARAMETERS_PKG;

 

/
