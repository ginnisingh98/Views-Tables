--------------------------------------------------------
--  DDL for Package Body RCV_PARAMETERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCV_PARAMETERS_PKG" as
/* $Header: RCVTIRPB.pls 120.0 2005/06/01 15:50:17 appldev noship $ */


  PROCEDURE Insert_Row(	X_Rowid                  IN OUT NOCOPY VARCHAR2,
                       	X_Organization_Id               NUMBER,
                       	X_Last_Update_Date              DATE,
                       	X_Last_Updated_By               NUMBER,
                       	X_Creation_Date                 DATE,
                       	X_Created_By                    NUMBER,
                       	X_Last_Updated_Login            NUMBER,
                       	X_Qty_Rcv_Tolerance             NUMBER,
                       	X_Qty_Rcv_Exception_Code        VARCHAR2,
                       	X_Enforce_Ship_To_Loc_Code   	VARCHAR2,
                       	X_Allow_Express_Del_Flag    	VARCHAR2,
                       	X_Days_Early_Rec_Allowed     	NUMBER,
                       	X_Days_Late_Rec_Allowed      	NUMBER,
                       	X_Rec_Days_Exception_Code    	VARCHAR2,
                       	X_Receiving_Routing_Id          NUMBER,
                        X_RMA_routing_id                 NUMBER DEFAULT 1,
                       	X_Allow_Substitute_Rec_Flag   	VARCHAR2,
                       	X_Allow_Unordered_Rec_Flag   	VARCHAR2,
                       	X_Blind_Receiving_Flag          VARCHAR2,
			X_Request_Id			NUMBER,
			X_Program_Application_ID	NUMBER,
			X_Program_Id			NUMBER,
			X_Program_Update_Date		DATE,
                       	X_Receiving_Account_Id          NUMBER,
                        X_Adjustment_Account_Id         NUMBER,
                        X_Clearing_Account_Id           NUMBER,
		       	X_Allow_Cascade_Trans		VARCHAR2,
                        X_Receipt_Asn_Exists_Code       VARCHAR2,
                        X_Receipt_Num_Code		VARCHAR2,
                        X_Manual_Receipt_Num_Type	VARCHAR2,
                        X_Next_Receipt_Num		NUMBER,
                        X_Enforce_RMA_Serial_Num	VARCHAR2 DEFAULT NULL,
                        X_Enforce_RMA_Lot_Num            VARCHAR2 DEFAULT NULL --INVCONV

   ) IS
     CURSOR C IS SELECT rowid FROM RCV_PARAMETERS
                 WHERE organization_id = X_Organization_Id;




    BEGIN


       INSERT INTO RCV_PARAMETERS(
               	organization_id,
               	last_update_date,
               	last_updated_by,
               	creation_date,
               	created_by,
               	last_updated_login,
               	qty_rcv_tolerance,
               	qty_rcv_exception_code,
               	enforce_ship_to_location_code,
               	allow_express_delivery_flag,
               	days_early_receipt_allowed,
               	days_late_receipt_allowed,
               	receipt_days_exception_code,
               	receiving_routing_id,
                rma_receipt_routing_id, /* 3124881 */
               	allow_substitute_receipts_flag,
               	allow_unordered_receipts_flag,
               	blind_receiving_flag,
		request_id,
		program_application_id,
		program_id,
		program_update_date,
               	receiving_account_id,
                retroprice_adj_account_id,
                clearing_account_id,
	       	allow_cascade_transactions,
                receipt_asn_exists_code,
                user_defined_receipt_num_code,
		manual_receipt_num_type,
		next_receipt_num,
                enforce_rma_serial_num,
                enforce_rma_lot_num		 --INVCONV
             ) VALUES (
               	X_Organization_Id,
               	X_Last_Update_Date,
               	X_Last_Updated_By,
               	X_Creation_Date,
               	X_Created_By,
               	X_Last_Updated_Login,
               	X_Qty_Rcv_Tolerance,
               	X_Qty_Rcv_Exception_Code,
               	X_Enforce_Ship_To_Loc_Code,
               	X_Allow_Express_Del_Flag,
               	X_Days_Early_Rec_Allowed,
               	X_Days_Late_Rec_Allowed,
               	X_Rec_Days_Exception_Code,
               	X_Receiving_Routing_Id,
                X_RMA_routing_id, /*3124881 */
               	X_Allow_Substitute_Rec_Flag,
               	X_Allow_Unordered_Rec_Flag,
               	X_Blind_Receiving_Flag,
		X_Request_Id,
		X_Program_Application_Id,
		X_Program_Id,
		X_Program_Update_date,
               	X_Receiving_Account_Id,
                X_Adjustment_Account_Id,
                X_Clearing_Account_Id,
	       	X_Allow_Cascade_Trans,
                X_receipt_asn_exists_code,
                X_Receipt_Num_Code,
                X_Manual_Receipt_Num_Type,
                X_Next_Receipt_Num,
                X_Enforce_RMA_Serial_Num,
                X_Enforce_RMA_Lot_Num	 --INVCONV
             );

    OPEN C;
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;
  END Insert_Row;



  PROCEDURE Lock_Row	(X_Rowid                    	VARCHAR2,
                     	X_Organization_Id               NUMBER,
			X_Last_Update_Date              DATE,
                       	X_Last_Updated_By               NUMBER,
                       	X_Creation_Date                 DATE,
                       	X_Created_By                    NUMBER,
                       	X_Last_Updated_Login            NUMBER,
                       	X_Qty_Rcv_Tolerance             NUMBER,
                       	X_Qty_Rcv_Exception_Code        VARCHAR2,
                       	X_Enforce_Ship_To_Loc_Code   	VARCHAR2,
                       	X_Allow_Express_Del_Flag    	VARCHAR2,
                       	X_Days_Early_Rec_Allowed     	NUMBER,
                       	X_Days_Late_Rec_Allowed      	NUMBER,
                       	X_Rec_Days_Exception_Code    	VARCHAR2,
                       	X_Receiving_Routing_Id          NUMBER,
                        X_RMA_routing_id                NUMBER, /* 3124881 */
                       	X_Allow_Substitute_Rec_Flag   	VARCHAR2,
                       	X_Allow_Unordered_Rec_Flag   	VARCHAR2,
                       	X_Blind_Receiving_Flag          VARCHAR2,
			X_Request_Id			NUMBER,
			X_Program_Application_ID	NUMBER,
			X_Program_Id			NUMBER,
			X_Program_Update_Date		DATE,
                       	X_Receiving_Account_Id          NUMBER,
                        X_Adjustment_Account_Id         NUMBER,
                        X_Clearing_Account_Id           NUMBER,
		       	X_Allow_Cascade_Trans		VARCHAR2,
                        X_receipt_asn_exists_code       VARCHAR2,
                        X_Receipt_Num_Code		VARCHAR2,
                        X_Manual_Receipt_Num_Type	VARCHAR2,
                        X_Next_Receipt_Num		NUMBER,
                        X_Enforce_RMA_Serial_Num        VARCHAR2 DEFAULT NULL ,
                        X_Enforce_RMA_Lot_Num            VARCHAR2 DEFAULT NULL --INVCONV

  ) IS
    CURSOR C IS
        SELECT *
        FROM   RCV_PARAMETERS
        WHERE  rowid = X_Rowid
        FOR UPDATE of Organization_Id NOWAIT;
    Recinfo C%ROWTYPE;
  BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    end if;
    CLOSE C;
    if (

               (Recinfo.organization_id = X_Organization_Id)
           AND (   (Recinfo.last_updated_login = X_Last_Updated_Login)
                OR (    (Recinfo.last_updated_login IS NULL)
                    AND (X_Last_Updated_Login IS NULL)))
           AND (   (Recinfo.qty_rcv_tolerance = X_Qty_Rcv_Tolerance)
                OR (    (Recinfo.qty_rcv_tolerance IS NULL)
                    AND (X_Qty_Rcv_Tolerance IS NULL)))
           AND (   (Recinfo.qty_rcv_exception_code = X_Qty_Rcv_Exception_Code)
                OR (    (Recinfo.qty_rcv_exception_code IS NULL)
                    AND (X_Qty_Rcv_Exception_Code IS NULL)))
           AND (   (Recinfo.enforce_ship_to_location_code = X_Enforce_Ship_To_Loc_Code)
                OR (    (Recinfo.enforce_ship_to_location_code IS NULL)
                    AND (X_Enforce_Ship_To_Loc_Code IS NULL)))
           AND (   (Recinfo.allow_express_delivery_flag = X_Allow_Express_Del_Flag)
                OR (    (Recinfo.allow_express_delivery_flag IS NULL)
                    AND (X_Allow_Express_Del_Flag IS NULL)))
           AND (   (Recinfo.days_early_receipt_allowed = X_Days_Early_Rec_Allowed)
                OR (    (Recinfo.days_early_receipt_allowed IS NULL)
                    AND (X_Days_Early_Rec_Allowed IS NULL)))
           AND (   (Recinfo.days_late_receipt_allowed = X_Days_Late_Rec_Allowed)
                OR (    (Recinfo.days_late_receipt_allowed IS NULL)
                    AND (X_Days_Late_Rec_Allowed IS NULL)))
           AND (   (Recinfo.receipt_days_exception_code = X_Rec_Days_Exception_Code)
                OR (    (Recinfo.receipt_days_exception_code IS NULL)
                    AND (X_Rec_Days_Exception_Code IS NULL)))
           AND (   (Recinfo.receiving_routing_id = X_Receiving_Routing_Id)
                OR (    (Recinfo.receiving_routing_id IS NULL)
                    AND (X_Receiving_Routing_Id IS NULL)))
           AND (   (Recinfo.rma_receipt_routing_id = X_rma_Routing_Id)
                OR (    (Recinfo.rma_receipt_routing_id IS NULL)
                    AND (X_rma_Routing_Id IS NULL)))
           AND (   (Recinfo.allow_substitute_receipts_flag = X_Allow_Substitute_Rec_Flag)
                OR (    (Recinfo.allow_substitute_receipts_flag IS NULL)
                    AND (X_Allow_Substitute_Rec_Flag IS NULL)))
           AND (   (Recinfo.allow_unordered_receipts_flag = X_Allow_Unordered_Rec_Flag)
                OR (    (Recinfo.allow_unordered_receipts_flag IS NULL)
                    AND (X_Allow_Unordered_Rec_Flag IS NULL)))
           AND (   (Recinfo.blind_receiving_flag = X_Blind_Receiving_Flag)
                OR (    (Recinfo.blind_receiving_flag IS NULL)
                    AND (X_Blind_Receiving_Flag IS NULL)))
           AND (   (Recinfo.receiving_account_id = X_Receiving_Account_Id)
                OR (    (Recinfo.receiving_account_id IS NULL)
                    AND (X_Receiving_Account_Id IS NULL)))
           AND (   (Recinfo.retroprice_adj_account_id = X_Adjustment_Account_Id)
                OR (    (Recinfo.retroprice_adj_account_id IS NULL)
                    AND (X_Adjustment_Account_Id IS NULL)))
           AND (   (Recinfo.clearing_account_id = X_Clearing_Account_Id)
                OR (    (Recinfo.clearing_account_id IS NULL)
                    AND (X_Clearing_Account_Id IS NULL)))
	   AND (   (Recinfo.allow_cascade_transactions = X_Allow_Cascade_Trans)
		OR (	(Recinfo.allow_cascade_transactions IS NULL)
		    AND (X_Allow_Cascade_Trans IS NULL)))
	   AND (   (Recinfo.receipt_asn_exists_code = X_Receipt_Asn_Exists_Code)
		OR (	(Recinfo.receipt_asn_exists_code IS NULL)
		    AND (X_Receipt_Asn_Exists_Code IS NULL)))
	   AND (   (Recinfo.user_defined_receipt_num_code = X_Receipt_Num_Code)
		OR (	(Recinfo.user_defined_receipt_num_code IS NULL)
		    AND (X_Receipt_Num_Code IS NULL)))
	   AND (   (Recinfo.manual_receipt_num_type = X_Manual_Receipt_Num_Type)
		OR (	(Recinfo.manual_receipt_num_type IS NULL)
		    AND (X_Manual_Receipt_Num_Type IS NULL)))
	   AND (   (Recinfo.next_receipt_num = X_Next_Receipt_Num)
		OR (	(Recinfo.next_receipt_num IS NULL)
		    AND (X_Next_Receipt_Num IS NULL)))
           AND (   (Recinfo.enforce_rma_serial_num = X_Enforce_RMA_Serial_Num)
                OR (    (Recinfo.enforce_rma_serial_num IS NULL)
                    AND (X_Enforce_RMA_Serial_Num IS NULL)))
           AND (   (Recinfo.enforce_rma_lot_num = X_Enforce_RMA_Lot_Num) --INVCONV
                OR (    (Recinfo.enforce_rma_lot_num IS NULL)
                    AND (X_Enforce_RMA_Lot_Num IS NULL)))
            ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.RAISE_EXCEPTION;
    end if;
  END Lock_Row;



  PROCEDURE Update_Row(	X_Rowid                         VARCHAR2,
                       	X_Organization_Id               NUMBER,
                       	X_Last_Update_Date              DATE,
                       	X_Last_Updated_By               NUMBER,
                       	X_Last_Updated_Login            NUMBER,
                       	X_Qty_Rcv_Tolerance             NUMBER,
                       	X_Qty_Rcv_Exception_Code        VARCHAR2,
                       	X_Enforce_Ship_To_Loc_Code  	VARCHAR2,
                       	X_Allow_Express_Del_Flag    	VARCHAR2,
                       	X_Days_Early_Rec_Allowed     	NUMBER,
                       	X_Days_Late_Rec_Allowed      	NUMBER,
                       	X_Rec_Days_Exception_Code    	VARCHAR2,
                      	X_Receiving_Routing_Id          NUMBER,
                        X_RMA_routing_id                NUMBER DEFAULT 1,
                       	X_Allow_Substitute_Rec_Flag 	VARCHAR2,
                       	X_Allow_Unordered_Rec_Flag  	VARCHAR2,
                       	X_Blind_Receiving_Flag          VARCHAR2,
			X_Request_Id			NUMBER,
			X_Program_Application_ID	NUMBER,
			X_Program_Id			NUMBER,
			X_Program_Update_Date		DATE,
                       	X_Receiving_Account_Id          NUMBER,
                        X_Adjustment_Account_Id         NUMBER,
                        X_Clearing_Account_Id           NUMBER,
		       	X_Allow_Cascade_Trans		VARCHAR2,
                        X_Receipt_Asn_Exists_Code       VARCHAR2,
                        X_Receipt_Num_Code		VARCHAR2,
                        X_Manual_Receipt_Num_Type	VARCHAR2,
                        X_Next_Receipt_Num		NUMBER,
                        X_Enforce_RMA_Serial_Num        VARCHAR2 DEFAULT NULL,
                        X_Enforce_RMA_Lot_Num            VARCHAR2 DEFAULT NULL --INVCONV

 ) IS
 BEGIN
   UPDATE RCV_PARAMETERS
   SET
     organization_id                   =     X_Organization_Id,
     last_update_date                  =     X_Last_Update_Date,
     last_updated_by                   =     X_Last_Updated_By,
     last_updated_login                =     X_Last_Updated_Login,
     qty_rcv_tolerance                 =     X_Qty_Rcv_Tolerance,
     qty_rcv_exception_code            =     X_Qty_Rcv_Exception_Code,
     enforce_ship_to_location_code     =     X_Enforce_Ship_To_Loc_Code,
     allow_express_delivery_flag       =     X_Allow_Express_Del_Flag,
     days_early_receipt_allowed        =     X_Days_Early_Rec_Allowed,
     days_late_receipt_allowed         =     X_Days_Late_Rec_Allowed,
     receipt_days_exception_code       =     X_Rec_Days_Exception_Code,
     receiving_routing_id              =     X_Receiving_Routing_Id,
     rma_receipt_routing_id            =     X_RMA_routing_id, /* 3124881 */
     allow_substitute_receipts_flag    =     X_Allow_Substitute_Rec_Flag,
     allow_unordered_receipts_flag     =     X_Allow_Unordered_Rec_Flag,
     blind_receiving_flag              =     X_Blind_Receiving_Flag,
     request_id			       =     X_Request_Id,
     program_application_id	       =     X_Program_Application_Id,
     program_id  		       =     X_Program_Id,
     program_update_date	       =     X_Program_Update_Date,
     receiving_account_id              =     X_Receiving_Account_Id,
     retroprice_adj_account_id         =     X_Adjustment_Account_Id,
     clearing_account_id               =     X_Clearing_Account_Id,
     allow_cascade_transactions	       =     X_Allow_Cascade_Trans,
     receipt_asn_exists_code           =     X_Receipt_Asn_Exists_Code,
     user_defined_receipt_num_code     =     X_Receipt_Num_Code,
     manual_receipt_num_type	       =     X_Manual_Receipt_Num_Type,
     next_receipt_num		       =     X_Next_Receipt_Num,
     enforce_rma_serial_num            =     X_Enforce_RMA_Serial_Num,
     enforce_rma_lot_num               =     X_Enforce_RMA_Lot_Num --INVCONV
   WHERE rowid = X_rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

  END Update_Row;

  PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
  BEGIN
    DELETE FROM RCV_PARAMETERS
    WHERE  rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Row;

END RCV_PARAMETERS_PKG;

/
