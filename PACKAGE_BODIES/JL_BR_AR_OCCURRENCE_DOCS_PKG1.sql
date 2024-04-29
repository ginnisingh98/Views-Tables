--------------------------------------------------------
--  DDL for Package Body JL_BR_AR_OCCURRENCE_DOCS_PKG1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_BR_AR_OCCURRENCE_DOCS_PKG1" as
/* $Header: jlbrri2b.pls 120.2 2005/02/23 23:28:30 vsidhart noship $ */

PROCEDURE Lock_Row(X_Rowid                        VARCHAR2,
                   X_Occurrence_Id    	          NUMBER,
                   X_Document_Id         	      NUMBER,
                   X_Bank_Occurrence_Code         NUMBER,
                   --X_Bank_Number                VARCHAR2,
                   X_Bank_Party_Id                NUMBER,
                   X_Bank_Occurrence_Type         VARCHAR2,
                   X_Occurrence_Date              DATE     DEFAULT NULL,
                   X_Occurrence_Status            VARCHAR2 DEFAULT NULL,
                   X_Original_Remittance_Media    VARCHAR2 DEFAULT NULL,
                   X_Remittance_Media             VARCHAR2 DEFAULT NULL,
                   X_Selection_Date          	  DATE     DEFAULT NULL,
                   X_Bordero_Id             	  NUMBER   DEFAULT NULL,
                   X_Portfolio_Code               NUMBER   DEFAULT NULL,
                   X_Trade_Note_Number     	      VARCHAR2 DEFAULT NULL,
                   X_Due_Date             	      DATE     DEFAULT NULL,
                   X_Document_Amount       	      NUMBER   DEFAULT NULL,
                   X_Bank_Instruction_Code1  	  NUMBER   DEFAULT NULL,
                   X_Bank_Instruction_Code2       NUMBER   DEFAULT NULL,
                   X_Num_Days_Instruction   	  NUMBER   DEFAULT NULL,
                   X_Interest_Percent      	      NUMBER   DEFAULT NULL,
                   X_Interest_Period       	      NUMBER   DEFAULT NULL,
                   X_Interest_Amount         	  NUMBER   DEFAULT NULL,
                   X_Grace_Days              	  NUMBER   DEFAULT NULL,
                   X_Discount_Limit_Date    	  DATE     DEFAULT NULL,
                   X_Discount_Amount        	  NUMBER   DEFAULT NULL,
                   X_Customer_Id             	  NUMBER   DEFAULT NULL,
                   X_Site_Use_Id             	  NUMBER   DEFAULT NULL,
                   X_Abatement_Amount        	  NUMBER   DEFAULT NULL,
                   X_Flag_Post_Gl            	  VARCHAR2 DEFAULT NULL,
                   X_Gl_Date                 	  DATE     DEFAULT NULL,
                   X_Gl_Posted_Date          	  DATE     DEFAULT NULL,
                   X_Endorsement_Credit_Ccid      NUMBER   DEFAULT NULL,
                   X_Endorsement_Debit_Ccid 	  NUMBER   DEFAULT NULL,
                   X_Endorsement_Debit_Amount     NUMBER   DEFAULT NULL,
                   X_Endorsement_Credit_Amount    NUMBER   DEFAULT NULL,
                   X_Bank_Charge_Amount  	      NUMBER   DEFAULT NULL,
                   X_Bank_Charges_Credit_Ccid     NUMBER   DEFAULT NULL,
                   X_Bank_Charges_Debit_Ccid      NUMBER   DEFAULT NULL,
                   X_Bank_Charges_Credit_Amount   NUMBER   DEFAULT NULL,
                   X_Bank_Charges_Debit_Amount    NUMBER   DEFAULT NULL,
                   X_Request_Id            	      NUMBER   DEFAULT NULL,
                   X_Return_Info           	      VARCHAR2 DEFAULT NULL,
                   X_Interest_Indicator    	      VARCHAR2 DEFAULT NULL,
                   X_Return_Request_Id     	      NUMBER   DEFAULT NULL,
                   X_Gl_Cancel_Date         	  DATE     DEFAULT NULL,
                   X_Attribute_Category     	  VARCHAR2 DEFAULT NULL,
                   X_Attribute1            	      VARCHAR2 DEFAULT NULL,
                   X_Attribute2            	      VARCHAR2 DEFAULT NULL,
                   X_Attribute3            	      VARCHAR2 DEFAULT NULL,
                   X_Attribute4              	  VARCHAR2 DEFAULT NULL,
                   X_Attribute5              	  VARCHAR2 DEFAULT NULL,
                   X_Attribute6              	  VARCHAR2 DEFAULT NULL,
                   X_Attribute7             	  VARCHAR2 DEFAULT NULL,
                   X_Attribute8             	  VARCHAR2 DEFAULT NULL,
                   X_Attribute9                	  VARCHAR2 DEFAULT NULL,
                   X_Attribute10               	  VARCHAR2 DEFAULT NULL,
                   X_Attribute11               	  VARCHAR2 DEFAULT NULL,
                   X_Attribute12              	  VARCHAR2 DEFAULT NULL,
                   X_Attribute13              	  VARCHAR2 DEFAULT NULL,
                   X_Attribute14              	  VARCHAR2 DEFAULT NULL,
                   X_Attribute15             	  VARCHAR2 DEFAULT NULL,
                   X_Last_Update_Date        	  DATE,
                   X_Last_Updated_By        	  NUMBER,
                   X_Creation_Date        	      DATE     DEFAULT NULL,
                   X_Created_By            	      NUMBER,
                   X_Last_Update_Login      	  NUMBER   DEFAULT NULL,
                   X_calling_sequence		      VARCHAR2) IS
--
CURSOR C IS
  SELECT *
  FROM   JL_BR_AR_OCCURRENCE_DOCS
  WHERE  rowid = X_Rowid
  FOR UPDATE of Document_Id NOWAIT;
  Recinfo C%ROWTYPE;
--
  current_calling_sequence    VARCHAR2(2000);
  debug_info                  VARCHAR2(100);

BEGIN
  --  Update the calling sequence
  current_calling_sequence := 'JL_BR_AR_OCCURRENCE_DOCS_PKG.LOCK_ROW<-' ||
                               X_calling_sequence;
  debug_info := 'Open cursor C';
  OPEN C;
  debug_info := 'Fetch cursor C';
  FETCH C INTO Recinfo;
  IF (C%NOTFOUND) THEN
     debug_info := 'Close cursor C - DATA NOTFOUND';
     CLOSE C;
     FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
     APP_EXCEPTION.Raise_Exception;
  END IF;
  debug_info := 'Close cursor C';
  CLOSE C;
  IF ((Recinfo.document_id =  X_Document_Id)
     AND (Recinfo.occurrence_id =  X_Occurrence_Id)
     AND (Recinfo.bank_occurrence_code =  X_Bank_Occurrence_Code)
     --AND (Recinfo.bank_number =  X_Bank_Number)
     AND (Recinfo.bank_party_id =  X_bank_party_id)
     AND (Recinfo.bank_occurrence_type =  X_Bank_Occurrence_Type)
     AND ((Recinfo.occurrence_date =  X_Occurrence_Date)
         OR ((Recinfo.occurrence_date IS NULL)
         AND (X_Occurrence_Date IS NULL)))
     AND ((Recinfo.occurrence_status =  X_Occurrence_Status)
         OR ((Recinfo.occurrence_status IS NULL)
         AND (X_Occurrence_Status IS NULL)))
     AND ((Recinfo.original_remittance_media =  X_Original_Remittance_Media)
         OR ((Recinfo.original_remittance_media IS NULL)
         AND (X_Original_Remittance_Media IS NULL)))
     AND ((Recinfo.remittance_media =  X_Remittance_Media)
         OR ((Recinfo.remittance_media IS NULL)
         AND (X_Remittance_Media IS NULL)))
     AND ((Recinfo.selection_date =  X_Selection_Date)
         OR ((Recinfo.selection_date IS NULL)
         AND (X_Selection_Date IS NULL)))
     AND ((Recinfo.bordero_id =  X_Bordero_Id)
         OR ((Recinfo.bordero_id IS NULL)
         AND (X_Bordero_Id IS NULL)))
     AND ((Recinfo.portfolio_code =  X_Portfolio_Code)
         OR ((Recinfo.portfolio_code IS NULL)
         AND (X_Portfolio_Code IS NULL)))
     AND ((Recinfo.trade_note_number =  X_Trade_Note_Number)
         OR ((Recinfo.trade_note_number IS NULL)
         AND (X_Trade_Note_Number IS NULL)))
     AND ((Recinfo.due_date =  X_Due_Date)
         OR ((Recinfo.due_date IS NULL)
         AND (X_Due_Date IS NULL)))
     AND ((Recinfo.document_amount =  X_Document_Amount)
         OR ((Recinfo.document_amount IS NULL)
         AND (X_Document_Amount IS NULL)))
     AND ((Recinfo.bank_instruction_code1 =  X_Bank_Instruction_Code1)
         OR ((Recinfo.bank_instruction_code1 IS NULL)
         AND (X_Bank_Instruction_Code1 IS NULL)))
     AND ((Recinfo.bank_instruction_code2 =  X_Bank_Instruction_Code2)
         OR ((Recinfo.bank_instruction_code2 IS NULL)
         AND (X_Bank_Instruction_Code2 IS NULL)))
     AND ((Recinfo.num_days_instruction =  X_Num_Days_Instruction)
         OR ((Recinfo.num_days_instruction IS NULL)
         AND (X_Num_Days_Instruction IS NULL)))
     AND ((Recinfo.interest_percent =  X_Interest_Percent)
         OR ((Recinfo.interest_percent IS NULL)
         AND (X_Interest_Percent IS NULL)))
     AND ((Recinfo.interest_period =  X_Interest_Period)
         OR ((Recinfo.interest_period IS NULL)
         AND (X_Interest_Period IS NULL)))
     AND ((Recinfo.interest_amount =  X_Interest_Amount)
         OR ((Recinfo.interest_amount IS NULL)
         AND (X_Interest_Amount IS NULL)))
     AND ((Recinfo.grace_days =  X_Grace_Days)
         OR ((Recinfo.grace_days IS NULL)
         AND (X_Grace_Days IS NULL)))
     AND ((Recinfo.discount_limit_date =  X_Discount_Limit_Date)
         OR ((Recinfo.discount_limit_date IS NULL)
         AND (X_Discount_Limit_Date IS NULL)))
     AND ((Recinfo.discount_amount =  X_Discount_Amount)
         OR ((Recinfo.discount_amount IS NULL)
         AND (X_Discount_Amount IS NULL)))
     AND ((Recinfo.customer_id =  X_Customer_Id)
         OR ((Recinfo.customer_id IS NULL)
         AND (X_Customer_Id IS NULL)))
     AND ((Recinfo.site_use_id =  X_Site_Use_Id)
         OR ((Recinfo.site_use_id IS NULL)
         AND (X_Site_Use_Id IS NULL)))
     AND ((Recinfo.abatement_amount =  X_Abatement_Amount)
         OR ((Recinfo.abatement_amount IS NULL)
         AND (X_Abatement_Amount IS NULL)))
     AND ((Recinfo.flag_post_gl =  X_Flag_Post_Gl)
         OR ((Recinfo.flag_post_gl IS NULL)
         AND (X_Flag_Post_Gl IS NULL)))
     AND ((Recinfo.gl_date =  X_Gl_Date)
         OR ((Recinfo.gl_date IS NULL)
         AND (X_Gl_Date IS NULL)))
     AND ((Recinfo.gl_posted_date =  X_Gl_Posted_Date)
         OR ((Recinfo.gl_posted_date IS NULL)
         AND (X_Gl_Posted_Date IS NULL)))
     AND ((Recinfo.endorsement_credit_ccid =  X_Endorsement_Credit_Ccid)
         OR ((Recinfo.endorsement_credit_ccid IS NULL)
         AND (X_Endorsement_Credit_Ccid IS NULL)))
     AND ((Recinfo.endorsement_debit_ccid =  X_Endorsement_Debit_Ccid)
         OR ((Recinfo.endorsement_debit_ccid IS NULL)
         AND (X_Endorsement_Debit_Ccid IS NULL)))
     AND ((Recinfo.endorsement_debit_amount =  X_Endorsement_Debit_Amount)
         OR ((Recinfo.endorsement_debit_amount IS NULL)
         AND (X_Endorsement_Debit_Amount IS NULL)))
     AND ((Recinfo.endorsement_credit_amount =  X_Endorsement_Credit_Amount)
         OR ((Recinfo.endorsement_credit_amount IS NULL)
         AND (X_Endorsement_Credit_Amount IS NULL)))
     AND ((Recinfo.bank_charge_amount =  X_Bank_Charge_Amount)
         OR ((Recinfo.bank_charge_amount IS NULL)
         AND (X_Bank_Charge_Amount IS NULL)))
     AND ((Recinfo.bank_charges_credit_ccid =  X_Bank_Charges_Credit_Ccid)
         OR ((Recinfo.bank_charges_credit_ccid IS NULL)
         AND (X_Bank_Charges_Credit_Ccid IS NULL)))
     AND ((Recinfo.bank_charges_debit_ccid =  X_Bank_Charges_Debit_Ccid)
         OR ((Recinfo.bank_charges_debit_ccid IS NULL)
         AND (X_Bank_Charges_Debit_Ccid IS NULL)))
     AND ((Recinfo.bank_charges_credit_amount =  X_Bank_Charges_Credit_Amount)
         OR ((Recinfo.bank_charges_credit_amount IS NULL)
         AND (X_Bank_Charges_Credit_Amount IS NULL)))
     AND ((Recinfo.bank_charges_debit_amount =  X_Bank_Charges_Debit_Amount)
         OR ((Recinfo.bank_charges_debit_amount IS NULL)
         AND (X_Bank_Charges_Debit_Amount IS NULL)))
     AND ((Recinfo.request_id =  X_Request_Id)
         OR ((Recinfo.request_id IS NULL)
         AND (X_Request_Id IS NULL)))
     AND ((Recinfo.return_info =  X_Return_Info)
         OR ((Recinfo.return_info IS NULL)
         AND (X_Return_Info IS NULL)))
     AND ((Recinfo.interest_indicator =  X_Interest_Indicator)
         OR ((Recinfo.interest_indicator IS NULL)
         AND (X_Interest_Indicator IS NULL)))
     AND ((Recinfo.return_request_id =  X_Return_Request_Id)
         OR ((Recinfo.return_request_id IS NULL)
         AND (X_Return_Request_Id IS NULL)))
     AND ((Recinfo.gl_cancel_date =  X_Gl_Cancel_Date)
         OR ((Recinfo.gl_cancel_date IS NULL)
         AND (X_Gl_Cancel_Date IS NULL)))
     AND ((Recinfo.attribute_category =  X_Attribute_Category)
         OR ((Recinfo.attribute_category IS NULL)
         AND (X_Attribute_Category IS NULL)))
     AND ((Recinfo.attribute1 =  X_Attribute1)
         OR ((Recinfo.attribute1 IS NULL)
         AND (X_Attribute1 IS NULL)))
     AND ((Recinfo.attribute2 =  X_Attribute2)
         OR ((Recinfo.attribute2 IS NULL)
         AND (X_Attribute2 IS NULL)))
     AND ((Recinfo.attribute3 =  X_Attribute3)
         OR ((Recinfo.attribute3 IS NULL)
         AND (X_Attribute3 IS NULL)))
     AND ((Recinfo.attribute4 =  X_Attribute4)
         OR ((Recinfo.attribute4 IS NULL)
         AND (X_Attribute4 IS NULL)))
     AND ((Recinfo.attribute5 =  X_Attribute5)
         OR ((Recinfo.attribute5 IS NULL)
         AND (X_Attribute5 IS NULL)))
     AND ((Recinfo.attribute6 =  X_Attribute6)
         OR ((Recinfo.attribute6 IS NULL)
         AND (X_Attribute6 IS NULL)))
     AND ((Recinfo.attribute7 =  X_Attribute7)
         OR ((Recinfo.attribute7 IS NULL)
         AND (X_Attribute7 IS NULL)))
     AND ((Recinfo.attribute8 =  X_Attribute8)
         OR ((Recinfo.attribute8 IS NULL)
         AND (X_Attribute8 IS NULL)))
     AND ((Recinfo.attribute9 =  X_Attribute9)
         OR ((Recinfo.attribute9 IS NULL)
         AND (X_Attribute9 IS NULL)))
     AND ((Recinfo.attribute10 =  X_Attribute10)
         OR ((Recinfo.attribute10 IS NULL)
         AND (X_Attribute10 IS NULL)))
     AND ((Recinfo.attribute11 =  X_Attribute11)
         OR ((Recinfo.attribute11 IS NULL)
         AND (X_Attribute11 IS NULL)))
     AND ((Recinfo.attribute12 =  X_Attribute12)
         OR ((Recinfo.attribute12 IS NULL)
         AND (X_Attribute12 IS NULL)))
     AND ((Recinfo.attribute13 =  X_Attribute13)
         OR ((Recinfo.attribute13 IS NULL)
         AND (X_Attribute13 IS NULL)))
     AND ((Recinfo.attribute14 =  X_Attribute14)
         OR ((Recinfo.attribute14 IS NULL)
         AND (X_Attribute14 IS NULL)))
     AND ((Recinfo.attribute15 =  X_Attribute15)
         OR ((Recinfo.attribute15 IS NULL)
         AND (X_Attribute15 IS NULL)))
     AND ((Recinfo.creation_date =  X_Creation_Date)
         OR ((Recinfo.creation_date IS NULL)
         AND (X_Creation_Date IS NULL)))
     AND ((Recinfo.created_by =  X_Created_By)
         OR ((Recinfo.created_by IS NULL)
         AND (X_Created_By IS NULL)))) THEN
     return;
   ELSE
     FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
     APP_EXCEPTION.Raise_Exception;
   END IF;
   --
   EXCEPTION
     WHEN OTHERS THEN
       IF (SQLCODE <> -20001) THEN
          IF (SQLCODE = -54) THEN
             FND_MESSAGE.SET_NAME('SQLAP','AP_RESOURCE_BUSY');
          ELSE
             FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
             FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
             FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
             FND_MESSAGE.SET_TOKEN('PARAMETERS','DOCUMENT_ID = ' ||
                                   X_Document_Id);
             FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
          END IF;
       END IF;
       APP_EXCEPTION.RAISE_EXCEPTION;
  --
END Lock_Row;

PROCEDURE Delete_Row(X_Rowid 		   VARCHAR2,
                     X_calling_sequence	IN VARCHAR2) IS
--
  current_calling_sequence    VARCHAR2(2000);
  debug_info                  VARCHAR2(100);
BEGIN
  --  Update the calling sequence
  --
  current_calling_sequence := 'JL_BR_AR_OCCURRENCE_DOCS_PKG.DELETE_ROW<-' ||
                               X_calling_sequence;
  debug_info := 'Delete from JL_BR_AR_OCCURRENCE_DOCS';
  DELETE FROM JL_BR_AR_OCCURRENCE_DOCS
  WHERE       rowid = X_Rowid;
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
         FND_MESSAGE.SET_TOKEN('PARAMETERS','ROWID = ' || X_Rowid);
         FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
      END IF;
      APP_EXCEPTION.RAISE_EXCEPTION;
  --
END Delete_Row;

END JL_BR_AR_OCCURRENCE_DOCS_PKG1;

/
