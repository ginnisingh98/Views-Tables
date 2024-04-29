--------------------------------------------------------
--  DDL for Package Body IGI_RPI_LINE_DETAILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_RPI_LINE_DETAILS_PKG" as
--- $Header: igirldeb.pls 120.5.12000000.1 2007/08/31 05:52:59 mbremkum ship $

  l_debug_level number:=FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  l_state_level number:=FND_LOG.LEVEL_STATEMENT;
  l_proc_level number:=FND_LOG.LEVEL_PROCEDURE;
  l_event_level number:=FND_LOG.LEVEL_EVENT;
  l_excep_level number:=FND_LOG.LEVEL_EXCEPTION;
  l_error_level number:=FND_LOG.LEVEL_ERROR;
  l_unexp_level number:=FND_LOG.LEVEL_UNEXPECTED;

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Standing_Charge_Id             NUMBER,
                       X_Line_Item_Id                   IN OUT NOCOPY NUMBER,
                       X_Charge_Item_Number             NUMBER,
                       X_Item_Id                        NUMBER,
                       X_Price                          NUMBER,
                       X_Quantity                       NUMBER,
                       X_Period_Name                    VARCHAR2,
                       X_Current_Effective_Date         DATE,
                       X_Description                    VARCHAR2,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Revised_Effective_Date         DATE,
                       X_Revised_Price                  NUMBER,
                       X_Previous_Price                 NUMBER,
                       X_Previous_Effective_Date        DATE,
                       X_Vat_Tax_Id                     NUMBER,
                       X_Revenue_Code_Combination_Id    NUMBER,
                       X_Receivable_Code_Combo_Id       NUMBER,
                       X_Additional_Reference           VARCHAR2,
                       X_Accounting_rule_id             NUMBER,
                       X_Start_date                     DATE,
                       X_Duration                       NUMBER,
		       X_Legal_Entity_Id		NUMBER,	--Added for MOAC Impact Bug No 5905216
		       X_Org_Id				NUMBER	--Added for MOAC Impact Bug No 5905216
  ) IS
    CURSOR C IS SELECT rowid FROM IGI_RPI_LINE_DETAILS
                 WHERE line_item_id = X_Line_Item_Id;
      CURSOR C2 IS SELECT igi_rpi_line_details_s.nextval FROM sys.dual;
   BEGIN
      if (X_Line_Item_Id is NULL) then
        OPEN C2;
        FETCH C2 INTO X_Line_Item_Id;
        CLOSE C2;
      end if;

/*Modified the Insert to include ORG_ID and LEGAL_ENTITY_ID for MOAC Impact R12 Uptake Bug No 5905216*/

       INSERT INTO IGI_RPI_LINE_DETAILS(
              standing_charge_id,
              line_item_id,
              charge_item_number,
              item_id,
              price,
              quantity,
              period_name,
              current_effective_date,
              description,
              creation_date,
              created_by,
              last_update_date,
              last_updated_by,
              last_update_login,
              revised_effective_date,
              revised_price,
              previous_price,
              previous_effective_date,
              vat_tax_id,
              revenue_code_combination_id,
              receivable_code_combination_id,
              additional_reference,
              accounting_rule_id,
              start_date,
              duration,
	      legal_entity_id,
	      org_id
             ) VALUES (
              X_Standing_Charge_Id,
              X_Line_Item_Id,
              X_Charge_Item_Number,
              X_Item_Id,
              X_Price,
              X_Quantity,
              X_Period_Name,
              X_Current_Effective_Date,
              X_Description,
              X_Creation_Date,
              X_Created_By,
              X_Last_Update_Date,
              X_Last_Updated_By,
              X_Last_Update_Login,
              X_Revised_Effective_Date,
              X_Revised_Price,
              X_Previous_Price,
              X_Previous_Effective_Date,
              X_Vat_Tax_Id,
              X_Revenue_Code_Combination_Id,
              X_Receivable_Code_Combo_Id,
              X_Additional_Reference,
              X_Accounting_Rule_id,
              X_Start_Date,
              X_Duration,
	      X_Legal_Entity_Id,
	      X_Org_Id
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
                     X_Line_Item_Id                     NUMBER,
                     X_Charge_Item_Number               NUMBER,
                     X_Item_Id                          NUMBER,
                     X_Price                            NUMBER,
                     X_Quantity                         NUMBER,
                     X_Period_Name                      VARCHAR2,
                     X_Current_Effective_Date           DATE,
                     X_Description                      VARCHAR2,
                     X_Revised_Effective_Date           DATE,
                     X_Revised_Price                    NUMBER,
                     X_Previous_Price                   NUMBER,
                     X_Previous_Effective_Date          DATE,
                     X_Vat_Tax_Id                       NUMBER,
                     X_Revenue_Code_Combination_Id      NUMBER,
                     X_Receivable_Code_Combo_Id         NUMBER,
                     X_Additional_Reference             VARCHAR2,
                     X_accounting_rule_id               NUMBER,
                     X_start_date                       DATE,
                     X_duration                         NUMBER,
--		     X_Legal_Entity_Id			NUMBER,  --Added for MOAC Impact Bug No 5905216
		     X_Org_Id				NUMBER   --Added for MOAC Impact Bug No 5905216
  ) IS
    CURSOR C IS
        SELECT *
        FROM   IGI_RPI_LINE_DETAILS
        WHERE  rowid = X_Rowid
        FOR UPDATE of Line_Item_Id NOWAIT;
    Recinfo C%ROWTYPE;


  BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      --Bug 3199481 (start)
      If (l_unexp_level >= l_debug_level) then
         FND_LOG.MESSAGE(l_unexp_level,'igi.plsql.igi_rpi_line_details_pkg.lock_row.Msg1',FALSE);
      End if;
      --Bug 3199481 (end)
      APP_EXCEPTION.Raise_Exception;
    end if;
    CLOSE C;
    if (
               (Recinfo.standing_charge_id =  X_Standing_Charge_Id)
           AND (Recinfo.line_item_id =  X_Line_Item_Id)
           AND (Recinfo.charge_item_number =  X_Charge_Item_Number)
           AND (Recinfo.item_id =  X_Item_Id)
           AND (Recinfo.price =  X_Price)
           AND (Recinfo.quantity =  X_Quantity)
           AND (Recinfo.period_name =  X_Period_Name)
           AND (Recinfo.current_effective_date =  X_Current_Effective_Date)
           AND (Recinfo.description =  X_Description)
	   /*Added for MOAC Impact R12 Uptake bug No 5905216 - Start*/
	   AND (Recinfo.org_id = X_Org_Id)
--	   AND (Recinfo.legal_entity_id = X_Legal_Entity_Id)
	   /*Added for MOAC Impact R12 Uptake bug No 5905216 - End*/
           AND (   (Recinfo.revised_effective_date =  X_Revised_Effective_Date)
                OR (    (Recinfo.revised_effective_date IS NULL)
                    AND (X_Revised_Effective_Date IS NULL)))
           AND (   (Recinfo.revised_price =  X_Revised_Price)
                OR (    (Recinfo.revised_price IS NULL)
                    AND (X_Revised_Price IS NULL)))
           AND (   (Recinfo.previous_price =  X_Previous_Price)
                OR (    (Recinfo.previous_price IS NULL)
                    AND (X_Previous_Price IS NULL)))
           AND (   (Recinfo.previous_effective_date = X_Previous_Effective_Date)
                OR (    (Recinfo.previous_effective_date IS NULL)
                    AND (X_Previous_effective_date IS NULL)))
           AND (   (Recinfo.vat_tax_id =  X_Vat_Tax_Id)
                OR (    (Recinfo.vat_tax_id IS NULL)
                    AND (X_Vat_Tax_Id IS NULL)))
           AND ((Recinfo.revenue_code_combination_id =  X_Revenue_Code_Combination_Id)
                OR (    (Recinfo.revenue_code_combination_id IS NULL)
                    AND (X_Revenue_Code_Combination_Id IS NULL)))
           AND ((Recinfo.receivable_code_combination_id = X_Receivable_Code_Combo_Id) OR (    (Recinfo.receivable_code_combination_id IS NULL)
                    AND (X_Receivable_Code_Combo_Id IS NULL)))
           AND (   (Recinfo.additional_reference =  X_Additional_Reference)
                OR (    (Recinfo.additional_reference IS NULL)
                    AND (X_Additional_Reference IS NULL)))
           AND (   (Recinfo.accounting_rule_id =  X_accounting_rule_id)
                OR (    (Recinfo.accounting_rule_id IS NULL)
                    AND (X_accounting_rule_id IS NULL)))
           AND (   (Recinfo.start_date =  X_start_date)
                OR (    (Recinfo.start_date IS NULL)
                    AND (X_start_date IS NULL)))
           AND (   (Recinfo.duration =  X_duration)
                OR (    (Recinfo.duration IS NULL)
                    AND (X_duration IS NULL)))

      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      --Bug 3199481 (start)
      If (l_unexp_level >= l_debug_level) then
         FND_LOG.MESSAGE(l_unexp_level,'igi.plsql.igi_rpi_line_details_pkg.lock_row.Msg2',FALSE);
      End if;
      --Bug 3199481 (end)
      APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_Row;



  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Standing_Charge_Id             NUMBER,
                       X_Line_Item_Id                   NUMBER,
                       X_Charge_Item_Number             NUMBER,
                       X_Item_Id                        NUMBER,
                       X_Price                          NUMBER,
                       X_Quantity                       NUMBER,
                       X_Period_Name                    VARCHAR2,
                       X_Current_Effective_Date         DATE,
                       X_Description                    VARCHAR2,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Revised_Effective_Date         DATE,
                       X_Revised_Price                  NUMBER,
                       X_Previous_Price                 NUMBER,
                       X_Previous_Effective_Date        DATE,
                       X_Vat_Tax_Id                     NUMBER,
                       X_Revenue_Code_Combination_Id    NUMBER,
                       X_Receivable_Code_Combo_Id       NUMBER,
                       X_Additional_Reference           VARCHAR2,
                       X_accounting_rule_id             NUMBER,
                       X_start_date                     DATE,
                       X_Duration                       NUMBER,
		       X_Legal_Entity_Id		NUMBER,  --Added for MOAC Impact Bug No 5905216
		       X_Org_Id				NUMBER   --Added for MOAC Impact Bug No 5905216
  ) IS
  BEGIN
    UPDATE IGI_RPI_LINE_DETAILS
    SET
       standing_charge_id              =     X_Standing_Charge_Id,
       line_item_id                    =     X_Line_Item_Id,
       charge_item_number              =     X_Charge_Item_Number,
       item_id                         =     X_Item_Id,
       price                           =     X_Price,
       quantity                        =     X_Quantity,
       period_name                     =     X_Period_Name,
       current_effective_date          =     X_Current_Effective_Date,
       description                     =     X_Description,
       last_update_date                =     X_Last_Update_Date,
       last_updated_by                 =     X_Last_Updated_By,
       last_update_login               =     X_Last_Update_Login,
       revised_effective_date          =     X_Revised_Effective_Date,
       revised_price                   =     X_Revised_Price,
       previous_price                  =     X_Previous_Price,
       previous_effective_date         =     X_Previous_Effective_Date,
       vat_tax_id                      =     X_Vat_Tax_Id,
       revenue_code_combination_id     =     X_Revenue_Code_Combination_Id,
       receivable_code_combination_id  =     X_Receivable_Code_Combo_Id,
       additional_reference            =     X_Additional_Reference,
       accounting_rule_id              =     X_accounting_rule_id,
       start_date                      =     X_start_date,
       duration                        =     X_duration,
       org_id			       =     X_Org_Id,
       legal_entity_id		       =     X_Legal_Entity_Id
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Update_Row;

  PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
  BEGIN
    DELETE FROM IGI_RPI_LINE_DETAILS
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Row;


END IGI_RPI_LINE_DETAILS_PKG;

/
