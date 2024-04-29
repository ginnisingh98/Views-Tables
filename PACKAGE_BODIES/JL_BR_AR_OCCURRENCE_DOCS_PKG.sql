--------------------------------------------------------
--  DDL for Package Body JL_BR_AR_OCCURRENCE_DOCS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_BR_AR_OCCURRENCE_DOCS_PKG" as
/* $Header: jlbrriob.pls 120.5 2003/09/15 21:56:33 vsidhart ship $ */

PROCEDURE Insert_Row(X_Rowid                 IN OUT NOCOPY VARCHAR2,
                     X_Occurrence_Id    	        NUMBER,
                     X_Document_Id         	        NUMBER,
                     X_Bank_Occurrence_Code         NUMBER,
                     --X_Bank_Number                VARCHAR2,
                     X_Bank_Party_Id                NUMBER,
                     X_Bank_Occurrence_Type         VARCHAR2,
                     X_Occurrence_Date              DATE     ,
                     X_Occurrence_Status            VARCHAR2 ,
                     X_Original_Remittance_Media    VARCHAR2 ,
                     X_Remittance_Media             VARCHAR2 ,
                     X_Selection_Date          	    DATE     ,
                     X_Bordero_Id             	    NUMBER   ,
                     X_Portfolio_Code               NUMBER   ,
                     X_Trade_Note_Number     	    VARCHAR2 ,
                     X_Due_Date             	    DATE     ,
                     X_Document_Amount       	    NUMBER   ,
                     X_Bank_Instruction_Code1  	    NUMBER   ,
                     X_Bank_Instruction_Code2       NUMBER   ,
                     X_Num_Days_Instruction   	    NUMBER   ,
                     X_Interest_Percent      	    NUMBER   ,
                     X_Interest_Period       	    NUMBER   ,
                     X_Interest_Amount       	    NUMBER   ,
                     X_Grace_Days            	    NUMBER   ,
                     X_Discount_Limit_Date   	    DATE     ,
                     X_Discount_Amount       	    NUMBER   ,
                     X_Customer_Id           	    NUMBER   ,
                     X_Site_Use_Id           	    NUMBER   ,
                     X_Abatement_Amount      	    NUMBER   ,
                     X_Flag_Post_Gl          	    VARCHAR2 ,
                     X_Gl_Date               	    DATE     ,
                     X_Gl_Posted_Date        	    DATE     ,
                     X_Endorsement_Credit_Ccid      NUMBER   ,
                     X_Endorsement_Debit_Ccid 	    NUMBER   ,
                     X_Endorsement_Debit_Amount     NUMBER   ,
                     X_Endorsement_Credit_Amount    NUMBER   ,
                     X_Bank_Charge_Amount  	    NUMBER   ,
                     X_Bank_Charges_Credit_Ccid     NUMBER   ,
                     X_Bank_Charges_Debit_Ccid      NUMBER   ,
                     X_Bank_Charges_Credit_Amount   NUMBER   ,
                     X_Bank_Charges_Debit_Amount    NUMBER   ,
                     X_Request_Id                   NUMBER   ,
                     X_Return_Info           	    VARCHAR2 ,
                     X_Interest_Indicator    	    VARCHAR2 ,
                     X_Return_Request_Id     	    NUMBER   ,
                     X_Gl_Cancel_Date         	    DATE     ,
                     X_Attribute_Category     	    VARCHAR2 ,
                     X_Attribute1            	    VARCHAR2 ,
                     X_Attribute2            	    VARCHAR2 ,
                     X_Attribute3            	    VARCHAR2 ,
                     X_Attribute4            	    VARCHAR2 ,
                     X_Attribute5            	    VARCHAR2 ,
                     X_Attribute6            	    VARCHAR2 ,
                     X_Attribute7            	    VARCHAR2 ,
                     X_Attribute8            	    VARCHAR2 ,
                     X_Attribute9            	    VARCHAR2 ,
                     X_Attribute10           	    VARCHAR2 ,
                     X_Attribute11           	    VARCHAR2 ,
                     X_Attribute12          	    VARCHAR2 ,
                     X_Attribute13           	    VARCHAR2 ,
                     X_Attribute14           	    VARCHAR2 ,
                     X_Attribute15           	    VARCHAR2 ,
                     X_Last_Update_Date      	    DATE,
                     X_Last_Updated_By      	    NUMBER,
                     X_Creation_Date        	    DATE     ,
                     X_Created_By            	    NUMBER,
                     X_Last_Update_Login      	    NUMBER   ,
                     X_calling_sequence	      IN    VARCHAR2,
                     X_ORG_ID                       NUMBER) IS
--
  CURSOR C IS
    SELECT rowid
    FROM   JL_BR_AR_OCCURRENCE_DOCS
    WHERE  document_id = X_Document_Id;
--
  current_calling_sequence  VARCHAR2(2000);
  debug_info                VARCHAR2(100);
--
BEGIN
  -- Update the calling sequence
  current_calling_sequence := 'JL_BR_AR_OCCURRENCE_DOCS_PKG.INSERT_ROW<-' ||
                               X_calling_sequence;

  debug_info := 'Insert into JL_BR_AR_OCCURRENCE_DOCS';
  INSERT INTO JL_BR_AR_OCCURRENCE_DOCS(
               occurrence_id,
	       document_id,
               bank_occurrence_code,
	       --bank_number,
               bank_party_id,
               bank_occurrence_type,
               occurrence_date,
	       occurrence_status,
	       original_remittance_media,
               remittance_media,
	       selection_date,
	       bordero_id,
               portfolio_code,
               trade_note_number,
               due_date,
	       document_amount,
	       bank_instruction_code1,
	       bank_instruction_code2,
	       num_days_instruction,
	       interest_percent,
               interest_period,
               interest_amount,
               grace_days,
               discount_limit_date,
               discount_amount,
               customer_id,
               site_use_id,
               abatement_amount,
               flag_post_gl,
               gl_date,
               gl_posted_date,
               endorsement_credit_ccid,
               endorsement_debit_ccid,
               endorsement_debit_amount,
               endorsement_credit_amount,
               bank_charge_amount,
               bank_charges_credit_ccid,
               bank_charges_debit_ccid,
               bank_charges_credit_amount,
               bank_charges_debit_amount,
               request_id,
               return_info,
               interest_indicator,
               return_request_id,
               gl_cancel_date,
               attribute_category,
               attribute1,
               attribute2,
               attribute3,
               attribute4,
               attribute5,
               attribute6,
               attribute7,
               attribute8,
               attribute9,
               attribute10,
               attribute11,
               attribute12,
               attribute13,
               attribute14,
               attribute15,
               last_update_date,
               last_updated_by,
               creation_date,
               created_by,
               last_update_login,
               org_id)
  VALUES (
               X_Occurrence_Id,
    	       X_Document_Id,
	       X_Bank_Occurrence_Code,
	       --X_Bank_Number,
               X_bank_Party_Id,
               X_Bank_Occurrence_Type,
               X_Occurrence_Date,
	       X_Occurrence_Status,
	       X_Original_Remittance_Media,
               X_Remittance_Media,
	       X_Selection_Date,
	       X_Bordero_Id,
               X_Portfolio_Code,
               X_Trade_Note_Number,
               X_Due_Date,
	       X_Document_Amount,
	       X_Bank_Instruction_Code1,
	       X_Bank_Instruction_Code2,
	       X_Num_Days_Instruction,
	       X_Interest_Percent,
               X_Interest_Period,
               X_Interest_Amount,
               X_Grace_Days,
               X_Discount_Limit_Date,
               X_Discount_Amount,
               X_Customer_Id,
               X_Site_Use_Id,
               X_Abatement_Amount,
               X_Flag_Post_Gl,
               X_Gl_Date,
               X_Gl_Posted_Date,
               X_Endorsement_Credit_Ccid,
               X_Endorsement_Debit_Ccid,
               X_Endorsement_Debit_Amount,
               X_Endorsement_Credit_Amount,
               X_Bank_Charge_Amount,
               X_Bank_Charges_Credit_Ccid,
               X_Bank_Charges_Debit_Ccid,
               X_Bank_Charges_Credit_Amount,
               X_Bank_Charges_Debit_Amount,
               X_Request_Id,
               X_Return_Info,
               X_Interest_Indicator,
               X_Return_Request_Id,
               X_Gl_Cancel_Date,
               X_Attribute_Category,
               X_Attribute1,
               X_Attribute2,
               X_Attribute3,
               X_Attribute4,
               X_Attribute5,
               X_Attribute6,
               X_Attribute7,
               X_Attribute8,
               X_Attribute9,
               X_Attribute10,
               X_Attribute11,
               X_Attribute12,
               X_Attribute13,
               X_Attribute14,
               X_Attribute15,
               X_Last_Update_Date,
               X_Last_Updated_By,
               X_Creation_Date,
               X_Created_By,
               X_Last_Update_Login,
               X_Org_Id);
  --
  debug_info := 'Open cursor C';
  OPEN C;
  debug_info := 'Fetch cursor C';
  FETCH C INTO X_Rowid;
  IF (C%NOTFOUND) THEN
    debug_info := 'Close cursor C - DATA NOTFOUND';
    CLOSE C;
    RAISE NO_DATA_FOUND;
  END IF;
  debug_info := 'Close cursor C';
  CLOSE C;
  --
  EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS','DOCUMENT_ID = ' ||
                              X_Document_Id);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
      END IF;
      APP_EXCEPTION.RAISE_EXCEPTION;
  --
END Insert_Row;

PROCEDURE Update_Row(X_Rowid                        VARCHAR2,
                     X_Occurrence_Id    	        NUMBER,
                     X_Document_Id          	    NUMBER,
                     X_Bank_Occurrence_Code         NUMBER,
                     --X_Bank_Number                VARCHAR2,
                     X_bank_Party_Id                NUMBER,
                     X_Bank_Occurrence_Type         VARCHAR2,
                     X_Occurrence_Date              DATE     ,
                     X_Occurrence_Status            VARCHAR2 ,
                     X_Original_Remittance_Media    VARCHAR2 ,
                     X_Remittance_Media             VARCHAR2 ,
                     X_Selection_Date          	    DATE     ,
                     X_Bordero_Id             	    NUMBER   ,
                     X_Portfolio_Code               NUMBER   ,
                     X_Trade_Note_Number     	    VARCHAR2 ,
                     X_Due_Date             	    DATE     ,
                     X_Document_Amount       	    NUMBER   ,
	             X_Bank_Instruction_Code1  	    NUMBER   ,
                     X_Bank_Instruction_Code2       NUMBER   ,
        	     X_Num_Days_Instruction   	    NUMBER   ,
        	     X_Interest_Percent      	    NUMBER   ,
                     X_Interest_Period       	    NUMBER   ,
                     X_Interest_Amount       	    NUMBER   ,
                     X_Grace_Days            	    NUMBER   ,
                     X_Discount_Limit_Date   	    DATE     ,
                     X_Discount_Amount       	    NUMBER   ,
                     X_Customer_Id           	    NUMBER   ,
                     X_Site_Use_Id           	    NUMBER   ,
                     X_Abatement_Amount      	    NUMBER   ,
                     X_Flag_Post_Gl          	    VARCHAR2 ,
                     X_Gl_Date               	    DATE     ,
                     X_Gl_Posted_Date        	    DATE     ,
                     X_Endorsement_Credit_Ccid      NUMBER   ,
                     X_Endorsement_Debit_Ccid 	    NUMBER   ,
                     X_Endorsement_Debit_Amount     NUMBER   ,
                     X_Endorsement_Credit_Amount    NUMBER   ,
                     X_Bank_Charge_Amount  	    NUMBER   ,
                     X_Bank_Charges_Credit_Ccid     NUMBER   ,
                     X_Bank_Charges_Debit_Ccid      NUMBER   ,
                     X_Bank_Charges_Credit_Amount   NUMBER   ,
                     X_Bank_Charges_Debit_Amount    NUMBER   ,
                     X_Request_Id            	    NUMBER   ,
                     X_Return_Info           	    VARCHAR2 ,
                     X_Interest_Indicator    	    VARCHAR2 ,
                     X_Return_Request_Id     	    NUMBER   ,
                     X_Gl_Cancel_Date         	    DATE     ,
                     X_Attribute_Category     	    VARCHAR2 ,
                     X_Attribute1            	    VARCHAR2 ,
                     X_Attribute2            	    VARCHAR2 ,
                     X_Attribute3            	    VARCHAR2 ,
                     X_Attribute4            	    VARCHAR2 ,
                     X_Attribute5            	    VARCHAR2 ,
                     X_Attribute6            	    VARCHAR2 ,
                     X_Attribute7            	    VARCHAR2 ,
                     X_Attribute8            	    VARCHAR2 ,
                     X_Attribute9            	    VARCHAR2 ,
                     X_Attribute10           	    VARCHAR2 ,
                     X_Attribute11           	    VARCHAR2 ,
                     X_Attribute12          	    VARCHAR2 ,
                     X_Attribute13           	    VARCHAR2 ,
                     X_Attribute14           	    VARCHAR2 ,
                     X_Attribute15           	    VARCHAR2 ,
                     X_Last_Update_Date      	    DATE,
                     X_Last_Updated_By      	    NUMBER,
                     X_Creation_Date        	    DATE     ,
                     X_Created_By            	    NUMBER,
                     X_Last_Update_Login      	    NUMBER   ,
	             X_calling_sequence	    IN	    VARCHAR2) IS
--
  current_calling_sequence    VARCHAR2(2000);
  debug_info                  VARCHAR2(100);
BEGIN
  --  Update the calling sequence
  --
  current_calling_sequence := 'JL_BR_AR_OCCURRENCE_DOCS_PKG.UPDATE_ROW<-' ||
                              X_calling_sequence;
  debug_info := 'Update JL_BR_AR_OCCURRENCE_DOCS';
  UPDATE JL_BR_AR_OCCURRENCE_DOCS
  SET    Occurrence_Id 			=     X_Occurrence_Id,
         Document_Id   			=     X_Document_Id,
         bank_occurrence_Code    	=     X_Bank_Occurrence_Code,
         --Bank_Number 			=     X_Bank_Number,
         Bank_Party_Id                  =     X_bank_Party_Id,
         Bank_Occurrence_type	        =     X_Bank_Occurrence_Type,
         occurrence_date 		=     X_Occurrence_Date,
         occurrence_status	   	=     X_Occurrence_Status,
         original_remittance_media 	= X_Original_Remittance_Media,
         remittance_media 		=     X_Remittance_Media,
         selection_date	         	=     X_Selection_Date,
         bordero_id 			=     X_Bordero_Id,
         portfolio_code                 =     X_Portfolio_Code,
         trade_note_number              =     X_Trade_Note_Number,
         due_date                       =     X_Due_Date,
         document_amount	        =     X_Document_Amount,
         bank_instruction_code1         =     X_Bank_Instruction_Code1,
         bank_instruction_code2         =     X_Bank_Instruction_Code2,
         num_days_instruction      	=     X_Num_Days_Instruction,
         interest_percent 		=     X_Interest_Percent,
         interest_period 		=     X_Interest_Period,
         interest_amount 		=     X_Interest_Amount,
         grace_days 			=     X_Grace_Days,
         discount_limit_date 	        =     X_Discount_Limit_Date,
         discount_amount       	        =     X_Discount_Amount,
         customer_id 			=     X_Customer_Id,
         site_use_id 			=     X_Site_Use_Id,
         abatement_amount 		=     X_Abatement_Amount,
         flag_post_gl 			=     X_Flag_Post_Gl,
         gl_date 		     	=     X_Gl_Date,
         gl_posted_date 		=     X_Gl_Posted_Date,
         endorsement_credit_ccid 	=     X_Endorsement_Credit_Ccid,
         endorsement_debit_ccid 	=     X_Endorsement_Debit_Ccid,
         endorsement_debit_amount 	=     X_Endorsement_Debit_Amount,
         endorsement_credit_amount 	=     X_Endorsement_Credit_Amount,
         bank_charge_amount 		=     X_Bank_Charge_Amount,
         bank_charges_credit_ccid 	=     X_Bank_Charges_Credit_Ccid,
         bank_charges_debit_ccid 	=     X_Bank_Charges_Debit_Ccid,
         bank_charges_credit_amount     =     X_Bank_Charges_Credit_Amount,
         bank_charges_debit_amount 	=     X_Bank_Charges_Debit_Amount,
         request_id 			=     X_Request_Id,
         return_info 			=     X_Return_Info,
         interest_indicator 	        =     X_Interest_Indicator,
         return_request_id 		=     X_Return_Request_Id,
         gl_cancel_date 		=     X_Gl_Cancel_Date,
         attribute_category             =     X_Attribute_Category,
         attribute1                     =     X_Attribute1,
         attribute2                     =     X_Attribute2,
         attribute3                     =     X_Attribute3,
         attribute4                     =     X_Attribute4,
         attribute5                     =     X_Attribute5,
         attribute6                     =     X_Attribute6,
         attribute7                     =     X_Attribute7,
         attribute8                     =     X_Attribute8,
         attribute9                     =     X_Attribute9,
         attribute10                    =     X_Attribute10,
         attribute11                    =     X_Attribute11,
         attribute12                    =     X_Attribute12,
         attribute13                    =     X_Attribute13,
         attribute14                    =     X_Attribute14,
         attribute15                    =     X_Attribute15,
         last_update_date 		=     X_Last_Update_Date,
         last_updated_by  		=     X_Last_Updated_By,
         creation_date 			=     X_Creation_Date,
         created_by 			=     X_Created_By,
         last_update_login 		=     X_Last_Update_Login
  WHERE  rowid = X_Rowid;
--
  IF (SQL%NOTFOUND) THEN
     RAISE NO_DATA_FOUND;
  END IF;
--
  EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
         FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
         FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
         FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
         FND_MESSAGE.SET_TOKEN('PARAMETERS','DOCUMENT_ID = ' ||
                               X_Document_Id);
         FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
      END IF;
      APP_EXCEPTION.RAISE_EXCEPTION;
--
END Update_Row;
END JL_BR_AR_OCCURRENCE_DOCS_PKG;

/
