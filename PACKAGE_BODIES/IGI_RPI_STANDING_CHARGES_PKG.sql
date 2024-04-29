--------------------------------------------------------
--  DDL for Package Body IGI_RPI_STANDING_CHARGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_RPI_STANDING_CHARGES_PKG" as
--- $Header: igirstcb.pls 120.7.12000000.1 2007/08/31 05:53:44 mbremkum ship $

  l_debug_level number:=FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  l_state_level number:=FND_LOG.LEVEL_STATEMENT;
  l_proc_level number:=FND_LOG.LEVEL_PROCEDURE;
  l_event_level number:=FND_LOG.LEVEL_EVENT;
  l_excep_level number:=FND_LOG.LEVEL_EXCEPTION;
  l_error_level number:=FND_LOG.LEVEL_ERROR;
  l_unexp_level number:=FND_LOG.LEVEL_UNEXPECTED;

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Standing_Charge_Id             IN OUT NOCOPY NUMBER,
                       X_Charge_Reference               VARCHAR2,
                       X_Set_Of_Books_Id                NUMBER,
                       X_Standing_Charge_Date           DATE,
                       X_Status                         VARCHAR2,
                       X_Bill_To_Customer_Id            NUMBER,
                       X_Bill_To_Site_Use_Id            NUMBER,
                       X_Batch_Source_Id                NUMBER,
                       X_Cust_Trx_Type_Id               NUMBER,
                       X_Salesrep_Id                    NUMBER,
                       X_Advance_Arrears_Ind            VARCHAR2,
                       X_Period_Name                    VARCHAR2,
                       X_Start_Date                     DATE,
                       X_Next_Due_Date                  DATE,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Bill_To_Contact_Id             NUMBER,
                       X_Ship_To_Customer_Id            NUMBER,
                       X_Ship_To_Site_Use_Id            NUMBER,
                       X_Ship_To_Contact_Id             NUMBER,
                       X_Reminder_Days                  NUMBER,
                       X_Receipt_Method_Id              NUMBER,
                       X_Bank_Account_Id                NUMBER,
                       X_Generate_Sequence              NUMBER,
                       X_End_Date                       DATE,
                       X_Review_Date                    DATE,
                       X_Previous_Due_Date              DATE,
                       X_Suppress_Inv_Print             VARCHAR2,
                       X_Comments                       VARCHAR2,
                       X_Description                    VARCHAR2,
                       X_Ship_To_Address_Id             NUMBER,
                       X_Bill_To_Address_Id             NUMBER,
                       X_term_id                        NUMBER,
                       X_Currency_code                  VARCHAR2,
                       X_Default_Invoicing_Rule		VARCHAR2,
  /*Added for MOAC Impact Bug No 5905216 - Start*/
		       X_Org_Id				NUMBER,
		       X_Legal_Entity_Id		NUMBER,
		       X_Payment_Trxn_Extension_Id	NUMBER
  /*MOAC Impact Bug No 5905216 - End*/
  ) IS
    CURSOR C IS SELECT rowid FROM IGI_RPI_STANDING_CHARGES
                 WHERE standing_charge_id = X_Standing_Charge_Id;
      CURSOR C2 IS SELECT igi_rpi_standing_charges_s.nextval FROM sys.dual;
   BEGIN
      if (X_Standing_Charge_Id is NULL) then
        OPEN C2;
        FETCH C2 INTO X_Standing_Charge_Id;
        CLOSE C2;
      end if;
       INSERT INTO IGI_RPI_STANDING_CHARGES(
              standing_charge_id,
              charge_reference,
              set_of_books_id,
              standing_charge_date,
              status,
              bill_to_customer_id,
              bill_to_site_use_id,
              batch_source_id,
              cust_trx_type_id,
              salesrep_id,
              advance_arrears_ind,
              period_name,
              start_date,
              next_due_date,
              creation_date,
              created_by,
              last_update_date,
              last_updated_by,
              last_update_login,
              bill_to_contact_id,
              ship_to_customer_id,
              ship_to_site_use_id,
              ship_to_contact_id,
              reminder_days,
              receipt_method_id,
              bank_account_id,
              generate_sequence,
              end_date,
              review_date,
              previous_due_date,
              suppress_inv_print,
              comments,
              description,
              ship_to_address_id,
              bill_to_address_id,
              term_id,
              currency_code,
              default_invoicing_rule,
/*MOAC Impact Bug No 5905216 - Start*/
	      org_id,
	      legal_entity_id,
	      payment_trxn_extension_id
/*MOAC Impact Bug No 5905216 - End*/
             ) VALUES (
              X_Standing_Charge_Id,
              X_Charge_Reference,
              X_Set_Of_Books_Id,
              X_Standing_Charge_Date,
              X_Status,
              X_Bill_To_Customer_Id,
              X_Bill_To_Site_Use_Id,
              X_Batch_Source_Id,
              X_Cust_Trx_Type_Id,
              X_Salesrep_Id,
              X_Advance_Arrears_Ind,
              X_Period_Name,
              X_Start_Date,
              X_Next_Due_Date,
              X_Creation_Date,
              X_Created_By,
              X_Last_Update_Date,
              X_Last_Updated_By,
              X_Last_Update_Login,
              X_Bill_To_Contact_Id,
              X_Ship_To_Customer_Id,
              X_Ship_To_Site_Use_Id,
              X_Ship_To_Contact_Id,
              X_Reminder_Days,
              X_Receipt_Method_Id,
              X_Bank_Account_Id,
              X_Generate_Sequence,
              X_End_Date,
              X_Review_Date,
              X_Previous_Due_Date,
              X_Suppress_Inv_Print,
              X_Comments,
              X_Description,
              X_Ship_To_Address_Id,
              X_Bill_To_Address_Id,
              X_term_id,
              X_currency_code,
              X_Default_Invoicing_Rule,
/*MOAC Impact Bug No 5905216 - Start*/
	      X_Org_id,
	      X_Legal_Entity_Id,
	      X_Payment_Trxn_Extension_Id
/*MOAC Impact bug No 5905216 - End*/
             );

    OPEN C;
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;
  END Insert_Row;


  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Standing_Charge_Id               NUMBER,
                     X_Charge_Reference                 VARCHAR2,
                     X_Set_Of_Books_Id                  NUMBER,
                     X_Standing_Charge_Date             DATE,
                     X_Status                           VARCHAR2,
                     X_Bill_To_Customer_Id              NUMBER,
                     X_Bill_To_Site_Use_Id              NUMBER,
                     X_Batch_Source_Id                  NUMBER,
                     X_Cust_Trx_Type_Id                 NUMBER,
                     X_Salesrep_Id                      NUMBER,
                     X_Advance_Arrears_Ind              VARCHAR2,
                     X_Period_Name                      VARCHAR2,
                     X_Start_Date                       DATE,
                     X_Next_Due_Date                    DATE,
                     X_Bill_To_Contact_Id               NUMBER,
                     X_Ship_To_Customer_Id              NUMBER,
                     X_Ship_To_Site_Use_Id              NUMBER,
                     X_Ship_To_Contact_Id               NUMBER,
                     X_Reminder_Days                    NUMBER,
                     X_Receipt_Method_Id                NUMBER,
                     X_Bank_Account_Id                  NUMBER,
                     X_Generate_Sequence                NUMBER,
                     X_End_Date                         DATE,
                     X_Review_Date                      DATE,
                     X_Previous_Due_Date                DATE,
                     X_Suppress_Inv_Print               VARCHAR2,
                     X_Comments                         VARCHAR2,
                     X_Description                      VARCHAR2,
                     X_Ship_To_Address_Id               NUMBER,
                     X_Bill_To_Address_Id               NUMBER,
                     X_term_id                        NUMBER,
                     X_Currency_code                  VARCHAR2,
                     X_Default_Invoicing_Rule		VARCHAR2,
		     /*MOAC Impact Bug No 5905216 - Start*/
		     X_Legal_Entity_Id			NUMBER,
		     X_Payment_Trxn_Extension_Id	NUMBER
		     /*MOAC Impact Bug No 5905216 - End*/
  ) IS
    CURSOR C IS
        SELECT *
        FROM   IGI_RPI_STANDING_CHARGES
        WHERE  rowid = X_Rowid
        FOR UPDATE of Standing_Charge_Id NOWAIT;
    Recinfo C%ROWTYPE;


  BEGIN
   BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      --Bug 3199481 (start)
      If (l_unexp_level >= l_debug_level) then
         FND_LOG.MESSAGE(l_unexp_level,'igi.plsql.igi_rpi_standing_charges_pkg.lock_row.Msg1',FALSE);
      End if;
      --Bug 3199481 (end)
      APP_EXCEPTION.Raise_Exception;
    end if;
    CLOSE C;
   EXCEPTION WHEN OTHERS THEN IF C%ISOPEN THEN
                                 CLOSE C;
                              END IF;
                      return;
   END;
    if (
               (Recinfo.standing_charge_id =  X_Standing_Charge_Id)
           AND (Recinfo.charge_reference =  X_Charge_Reference)
           AND (Recinfo.set_of_books_id =  X_Set_Of_Books_Id)
/* Added the null condn check by Panaraya for bug 2439363 */
           AND ((Recinfo.standing_charge_date =  X_Standing_Charge_Date) OR
		(Recinfo.standing_charge_date IS NULL AND X_Standing_Charge_Date IS NULL))
           AND (Recinfo.status =  X_Status)
           AND (Recinfo.bill_to_customer_id =  X_Bill_To_Customer_Id)
           AND (Recinfo.bill_to_site_use_id =  X_Bill_To_Site_Use_Id)
           AND (Recinfo.batch_source_id =  X_Batch_Source_Id)
           AND (Recinfo.cust_trx_type_id =  X_Cust_Trx_Type_Id)
           AND (Recinfo.salesrep_id =  X_Salesrep_Id)
           AND (Recinfo.period_name =  X_Period_Name)
           AND (Recinfo.start_date =  X_Start_Date)
           AND (Recinfo.next_due_date =  X_Next_Due_Date)
           AND (Recinfo.term_id       =  X_term_id)
           AND (Recinfo.currency_code =  X_currency_code)
	  /*MOAC Impact Bug No 5905216 - Start*/
	   AND (Recinfo.legal_entity_id = X_Legal_Entity_Id)
	  /*MOAC Impact Bug No 5905216 - End*/
	   AND (   (Recinfo.payment_trxn_extension_id =  X_Payment_Trxn_Extension_Id)
                OR (  (Recinfo.payment_trxn_extension_id IS NULL )
                    AND (X_Payment_Trxn_Extension_Id is NULL)))
           AND (   (Recinfo.advance_arrears_ind =  X_Advance_Arrears_Ind)
                OR (  (Recinfo.advance_arrears_ind IS NULL )
                    AND (X_Advance_Arrears_Ind is NULL)))
           AND (   (Recinfo.bill_to_contact_id =  X_Bill_To_Contact_Id)
                OR (    (Recinfo.bill_to_contact_id IS NULL)
                    AND (X_Bill_To_Contact_Id IS NULL)))
           AND (   (Recinfo.ship_to_customer_id =  X_Ship_To_Customer_Id)
                OR (    (Recinfo.ship_to_customer_id IS NULL)
                    AND (X_Ship_To_Customer_Id IS NULL)))
           AND (   (Recinfo.ship_to_site_use_id =  X_Ship_To_Site_Use_Id)
                OR (    (Recinfo.ship_to_site_use_id IS NULL)
                    AND (X_Ship_To_Site_Use_Id IS NULL)))
           AND (   (Recinfo.ship_to_contact_id =  X_Ship_To_Contact_Id)
                OR (    (Recinfo.ship_to_contact_id IS NULL)
                    AND (X_Ship_To_Contact_Id IS NULL)))
           AND (   (Recinfo.reminder_days =  X_Reminder_Days)
                OR (    (Recinfo.reminder_days IS NULL)
                    AND (X_Reminder_Days IS NULL)))
           AND (   (Recinfo.receipt_method_id =  X_Receipt_Method_Id)
                OR (    (Recinfo.receipt_method_id IS NULL)
                    AND (X_Receipt_Method_Id IS NULL)))
           AND (   (Recinfo.bank_account_id =  X_Bank_Account_Id)
                OR (    (Recinfo.bank_account_id IS NULL)
                    AND (X_Bank_Account_Id IS NULL)))
           AND (   (Recinfo.generate_sequence =  X_Generate_Sequence)
                OR (    (Recinfo.generate_sequence IS NULL)
                    AND (X_Generate_Sequence IS NULL)))
           AND (   (Recinfo.end_date =  X_End_Date)
                OR (    (Recinfo.end_date IS NULL)
                    AND (X_End_Date IS NULL)))
           AND (   (Recinfo.review_date =  X_Review_Date)
                OR (    (Recinfo.review_date IS NULL)
                    AND (X_Review_Date IS NULL)))
           AND (   (Recinfo.previous_due_date =  X_Previous_Due_Date)
                OR (    (Recinfo.previous_due_date IS NULL)
                    AND (X_Previous_Due_Date IS NULL)))
           AND (   (Recinfo.suppress_inv_print =  X_Suppress_Inv_Print)
                OR (    (Recinfo.suppress_inv_print IS NULL)
                    AND (X_Suppress_Inv_Print IS NULL)))
           AND (   (Recinfo.comments =  X_Comments)
                OR (    (Recinfo.comments IS NULL)
                    AND (X_Comments IS NULL)))
           AND (   (Recinfo.description =  X_Description)
                OR (    (Recinfo.description IS NULL)
                    AND (X_Description IS NULL)))
           AND (   (Recinfo.ship_to_address_id =  X_Ship_To_Address_Id)
                OR (    (Recinfo.ship_to_address_id IS NULL)
                    AND (X_Ship_To_Address_Id IS NULL)))
           AND (   (Recinfo.bill_to_address_id =  X_Bill_To_Address_Id)
                OR (    (Recinfo.bill_to_address_id IS NULL)
                    AND (X_Bill_To_Address_Id IS NULL)))
           AND (   (Recinfo.default_invoicing_rule =  X_Default_Invoicing_Rule)
                OR (    (Recinfo.default_invoicing_rule IS NULL)
                    AND (X_Default_Invoicing_Rule IS NULL)))

      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      --Bug 3199481 (start)
      If (l_unexp_level >= l_debug_level) then
         FND_LOG.MESSAGE(l_unexp_level,'igi.plsql.igi_rpi_standing_charges_pkg.lock_row.Msg2',FALSE);
      End if;
      --Bug 3199481 (end)
      APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_Row;



  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Standing_Charge_Id             NUMBER,
                       X_Charge_Reference               VARCHAR2,
                       X_Set_Of_Books_Id                NUMBER,
                       X_Standing_Charge_Date           DATE,
                       X_Status                         VARCHAR2,
                       X_Bill_To_Customer_Id            NUMBER,
                       X_Bill_To_Site_Use_Id            NUMBER,
                       X_Batch_Source_Id                NUMBER,
                       X_Cust_Trx_Type_Id               NUMBER,
                       X_Salesrep_Id                    NUMBER,
                       X_Advance_Arrears_Ind            VARCHAR2,
                       X_Period_Name                    VARCHAR2,
                       X_Start_Date                     DATE,
                       X_Next_Due_Date                  DATE,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Bill_To_Contact_Id             NUMBER,
                       X_Ship_To_Customer_Id            NUMBER,
                       X_Ship_To_Site_Use_Id            NUMBER,
                       X_Ship_To_Contact_Id             NUMBER,
                       X_Reminder_Days                  NUMBER,
                       X_Receipt_Method_Id              NUMBER,
                       X_Bank_Account_Id                NUMBER,
                       X_Generate_Sequence              NUMBER,
                       X_End_Date                       DATE,
                       X_Review_Date                    DATE,
                       X_Previous_Due_Date              DATE,
                       X_Suppress_Inv_Print             VARCHAR2,
                       X_Comments                       VARCHAR2,
                       X_Description                    VARCHAR2,
                       X_Ship_To_Address_Id             NUMBER,
                       X_Bill_To_Address_Id             NUMBER,
                       X_term_id                        NUMBER,
                       X_Currency_code                  VARCHAR2,
                       X_Default_Invoicing_Rule		VARCHAR2,
  /*MOAC Impact Bug No 5905216 - Start*/
		       X_Legal_Entity_Id		NUMBER,
		       X_Payment_Trxn_Extension_Id	NUMBER
  /*MOAC Impact Bug No 5905216 - End*/
  ) IS
  BEGIN
    UPDATE IGI_RPI_STANDING_CHARGES
    SET
       standing_charge_id              =     X_Standing_Charge_Id,
       charge_reference                =     X_Charge_Reference,
       set_of_books_id                 =     X_Set_Of_Books_Id,
       standing_charge_date            =     X_Standing_Charge_Date,
       status                          =     X_Status,
       bill_to_customer_id             =     X_Bill_To_Customer_Id,
       bill_to_site_use_id             =     X_Bill_To_Site_Use_Id,
       batch_source_id                 =     X_Batch_Source_Id,
       cust_trx_type_id                =     X_Cust_Trx_Type_Id,
       salesrep_id                     =     X_Salesrep_Id,
       advance_arrears_ind             =     X_Advance_Arrears_Ind,
       period_name                     =     X_Period_Name,
       start_date                      =     X_Start_Date,
       next_due_date                   =     X_Next_Due_Date,
       last_update_date                =     X_Last_Update_Date,
       last_updated_by                 =     X_Last_Updated_By,
       last_update_login               =     X_Last_Update_Login,
       bill_to_contact_id              =     X_Bill_To_Contact_Id,
       ship_to_customer_id             =     X_Ship_To_Customer_Id,
       ship_to_site_use_id             =     X_Ship_To_Site_Use_Id,
       ship_to_contact_id              =     X_Ship_To_Contact_Id,
       reminder_days                   =     X_Reminder_Days,
       receipt_method_id               =     X_Receipt_Method_Id,
       bank_account_id                 =     X_Bank_Account_Id,
       generate_sequence               =     X_Generate_Sequence,
       end_date                        =     X_End_Date,
       review_date                     =     X_Review_Date,
       previous_due_date               =     X_Previous_Due_Date,
       suppress_inv_print              =     X_Suppress_Inv_Print,
       comments                        =     X_Comments,
       description                     =     X_Description,
       ship_to_address_id              =     X_Ship_To_Address_Id,
       bill_to_address_id              =     X_Bill_To_Address_Id,
       Currency_code                   =     X_currency_code,
       term_id                         =     X_term_id,
       default_invoicing_rule	       =     X_Default_Invoicing_Rule,
	/*MOAC Impact Bug No 5905216 - Start*/
       legal_entity_id		       =     X_Legal_Entity_Id,
       payment_trxn_extension_id       =     X_Payment_Trxn_Extension_Id
	/*MOAC Impact Bug No 5905216 - End*/
    WHERE rowid = X_Rowid;
    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Update_Row;

  PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
  BEGIN
    DELETE FROM IGI_RPI_STANDING_CHARGES
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Row;


END IGI_RPI_STANDING_CHARGES_PKG;

/
