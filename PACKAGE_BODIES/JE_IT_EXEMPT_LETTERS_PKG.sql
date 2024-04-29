--------------------------------------------------------
--  DDL for Package Body JE_IT_EXEMPT_LETTERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JE_IT_EXEMPT_LETTERS_PKG" as
/* $Header: jeitexlb.pls 120.6 2006/05/31 05:44:38 samalhot ship $ */

 PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
		       X_Legal_Entity_Id		NUMBER,
                       X_Set_of_Books_Id                NUMBER,
                       X_Vendor_Id                      NUMBER,
                       X_Effective_From                 DATE,
                       X_Effective_To                   DATE,
                       X_Year                           NUMBER,
                       X_Exemption_Letter_Id            NUMBER,
                       X_Print_Flag                     VARCHAR2,
                       X_Issue_Flag                     VARCHAR2,
                       X_Custom_Flag                    VARCHAR2,
                       X_Letter_Type                    VARCHAR2,
                       X_Limit_Amount                   NUMBER,
                       X_Clause_Ref                     VARCHAR2,
                       X_Issue_Date                     DATE,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER
  ) IS
    CURSOR C IS SELECT rowid FROM JE_IT_EXEMPT_LETTERS
                 WHERE vendor_id = X_Vendor_Id
                 AND   effective_from = X_Effective_From
                 AND   effective_to = X_Effective_To;

   CURSOR c_alc_ledger (p_ledger_id IN NUMBER) IS
          SELECT ledger_id, currency_code
          FROM   gl_alc_ledger_rships_v
          WHERE  primary_ledger_id         = p_ledger_id
          AND    application_id            = 222
	  AND	 org_id			   = MO_GLOBAL.get_current_org_id
--          AND    nvl(org_id,-99)           = NVL(NVL(rtrim(substr(userenv('CLIENT_INFO'),1,10)),-99),-99)
          AND    relationship_enabled_flag = 'Y';

   BEGIN
      declare
          exchange_rate  NUMBER;
          c_ledger_id NUMBER;
      begin
          INSERT INTO JE_IT_EXEMPT_LETTERS(
	      legal_entity_id,
              set_of_books_id,
              vendor_id,
              effective_from,
              effective_to,
              year,
              exemption_letter_id,
              print_flag,
              issue_flag,
              custom_flag,
              letter_type,
              limit_amount,
              clause_ref,
              issue_date,
              last_update_date,
              last_updated_by,
              creation_date,
              created_by
             ) VALUES (
              X_Legal_Entity_Id,
              X_Set_of_Books_Id,
              X_Vendor_Id,
              X_Effective_From,
              X_Effective_To,
              X_Year,
              X_Exemption_Letter_Id,
              X_Print_Flag,
              X_Issue_Flag,
              X_Custom_Flag,
              X_Letter_Type,
              X_Limit_Amount,
              X_Clause_Ref,
              X_Issue_Date,
              X_Last_Update_Date,
              X_Last_Updated_By,
              X_Creation_Date,
              X_Created_By
             );
      -- We also need to insert a row for each additional ledger
       -- Loop for each Additional Ledger
   for rledger_rec in c_alc_ledger(c_ledger_id)
     loop

          -- get exchange rate for the additional ledger currency
             exchange_rate := gl_currency_api.get_rate_sql (rledger_rec.ledger_id,
                              rledger_rec.currency_code,NULL,NULL);


       INSERT INTO JE_IT_EXEMPT_LETTERS(
	      legal_entity_id,
              set_of_books_id,
              vendor_id,
              effective_from,
              effective_to,
              year,
              exemption_letter_id,
              print_flag,
              issue_flag,
              custom_flag,
              letter_type,
              limit_amount,
              clause_ref,
              issue_date,
              last_update_date,
              last_updated_by,
              creation_date,
              created_by
             ) VALUES (
              X_Legal_Entity_Id,
              X_Set_of_Books_Id,
              X_Vendor_Id,
              X_Effective_From,
              X_Effective_To,
              X_Year,
              X_Exemption_Letter_Id,
              X_Print_Flag,
              X_Issue_Flag,
              X_Custom_Flag,
              X_Letter_Type,
              X_Limit_Amount/exchange_rate,
              X_Clause_Ref,
              X_Issue_Date,
              X_Last_Update_Date,
              X_Last_Updated_By,
              X_Creation_Date,
              X_Created_By
             );
    end loop;
    OPEN C;
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;
  end;
 END Insert_Row;


 PROCEDURE Lock_Row(X_Rowid                             VARCHAR2,
	             X_Legal_Entity_Id			NUMBER,
        	     X_Set_of_Books_Id			NUMBER,
                     X_Vendor_Id                        NUMBER,
                     X_Effective_From                   DATE,
                     X_Effective_To                     DATE,
                     X_Year                             NUMBER,
                     X_Exemption_Letter_Id              NUMBER,
                     X_Print_Flag                       VARCHAR2,
                     X_Issue_Flag                       VARCHAR2,
                     X_Custom_Flag                      VARCHAR2,
                     X_Letter_Type                      VARCHAR2,
                     X_Limit_Amount                     NUMBER,
                     X_Clause_Ref                       VARCHAR2,
                     X_Issue_Date                       DATE,
                     X_Last_Update_Date                 DATE,
                     X_Last_Updated_By                  NUMBER,
                     X_Creation_Date                    DATE,
                     X_Created_By                       NUMBER
                     ) IS
    CURSOR C IS
        SELECT *
        FROM   JE_IT_EXEMPT_LETTERS
        WHERE  rowid = X_Rowid
        FOR UPDATE of Vendor_Id NOWAIT;
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
    if (       (Recinfo.legal_entity_id = X_Legal_Entity_Id)
	   AND (Recinfo.set_of_books_id =  X_Set_of_Books_Id)
           AND (Recinfo.vendor_id =  X_Vendor_Id)
           AND (Recinfo.effective_from =  X_Effective_From)
           AND (Recinfo.effective_to =  X_Effective_To)
           AND (Recinfo.year =  X_Year)
           AND (Recinfo.exemption_letter_id =  X_Exemption_Letter_Id)
           AND (Recinfo.print_flag =  X_Print_Flag)
           AND (Recinfo.issue_flag =  X_Issue_Flag)
           AND (Recinfo.custom_flag =  X_Custom_Flag)
           AND (Recinfo.letter_type = X_Letter_Type)
           AND (Recinfo.limit_amount = X_Limit_Amount)
           AND (Recinfo.clause_ref =  X_Clause_Ref)
           AND (   (trunc(Recinfo.issue_date) =  X_Issue_Date)
                OR (    (Recinfo.issue_date IS NULL)
                    AND (X_Issue_Date IS NULL)))
       ) then

      return;
   else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
   end if;
 END Lock_Row;


 PROCEDURE Update_Row(X_Rowid                           VARCHAR2,
	               X_Legal_Entity_Id		NUMBER,
        	       X_Set_of_Books_Id		NUMBER,
                       X_Vendor_Id                      NUMBER,
                       X_Effective_From                 DATE,
                       X_Effective_To                   DATE,
                       X_Year                           NUMBER,
                       X_Exemption_Letter_Id            NUMBER,
                       X_Print_Flag                     VARCHAR2,
                       X_Issue_Flag                     VARCHAR2,
                       X_Custom_Flag                    VARCHAR2,
                       X_Letter_Type                    VARCHAR2,
                       X_Limit_Amount                   NUMBER,
                       X_Clause_Ref                     VARCHAR2,
                       X_Issue_Date                     DATE,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER
                       ) IS
         CURSOR c_alc_ledger (p_ledger_id in number) is
         SELECT ledger_id, currency_code
         FROM  	gl_alc_ledger_rships_v
         WHERE 	primary_ledger_id        = p_ledger_id
         AND   	application_id           = 222
	 AND	org_id			 = MO_GLOBAL.get_current_org_id
--         AND  NVL(org_id,-99)          = NVL(NVL(rtrim(substr(userenv('CLIENT_INFO'),1,10)),-99), -99)
         AND  relationship_enabled_flag  = 'Y' ;

  BEGIN
   declare
     update_exemption_letter_id JE_IT_EXEMPT_LETTERS.exemption_letter_id%TYPE;
     update_vendor_id  JE_IT_EXEMPT_LETTERS.vendor_id%TYPE;
     exchange_rate     NUMBER;
     c_ledger_id NUMBER;
   begin
     SELECT vendor_id,exemption_letter_id
     INTO update_vendor_id, update_exemption_letter_id
     FROM je_it_exempt_letters
     WHERE rowid =x_rowid;

     UPDATE JE_IT_EXEMPT_LETTERS
     SET
       legal_entity_id		       =     X_Legal_Entity_Id,
       set_of_books_id                 =     X_Set_of_Books_Id,
       vendor_id                       =     X_Vendor_Id,
       effective_from                  =     X_Effective_From,
       effective_to                    =     X_Effective_To,
       year                            =     X_Year,
       exemption_letter_id             =     X_Exemption_Letter_Id,
       print_flag                      =     X_Print_Flag,
       issue_flag                      =     X_Issue_Flag,
       custom_flag                     =     X_Custom_Flag,
       letter_type                     =     X_Letter_Type,
       limit_amount                    =     X_Limit_Amount,
       clause_ref                      =     X_Clause_Ref,
       issue_date                      =     X_Issue_Date,
       last_update_date                =     X_Last_Update_Date,
       last_updated_by                 =     X_Last_Updated_By,
       creation_date		       =     X_Creation_Date,
       created_by		       =     X_Created_By
    WHERE rowid = X_Rowid;

     -- We also need to update a row for each additional ledger.

     -- Loop for each Additional ledger
     For rledger_rec IN c_alc_ledger(c_ledger_id)
     loop
         -- get exchange rate for the additional ledger currency
            exchange_rate :=gl_currency_api.get_rate_sql(rledger_rec.ledger_id,
                            rledger_rec.currency_code,NULL,NULL);

     UPDATE JE_IT_EXEMPT_LETTERS
     SET
       legal_entity_id		       =     X_Legal_Entity_Id,
       set_of_books_id                 =     rledger_rec.ledger_id,
       vendor_id                       =     X_Vendor_Id,
       effective_from                  =     X_Effective_From,
       effective_to                    =     X_Effective_To,
       year                            =     X_Year,
       exemption_letter_id             =     X_Exemption_Letter_Id,
       print_flag                      =     X_Print_Flag,
       issue_flag                      =     X_Issue_Flag,
       custom_flag                     =     X_Custom_Flag,
       letter_type                     =     X_Letter_Type,
       limit_amount                    =     X_Limit_Amount/exchange_rate,
       clause_ref                      =     X_Clause_Ref,
       issue_date                      =     X_Issue_Date,
       last_update_date                =     X_Last_Update_Date,
       last_updated_by                 =     X_Last_Updated_By,
       creation_date		       =     X_Creation_Date,
       created_by		       =     X_Created_By
     WHERE set_of_books_id = rledger_rec.ledger_id
     AND   vendor_id= update_vendor_id
     AND   exemption_letter_id = update_exemption_letter_id;
    end loop;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  end;
 END Update_Row;


 PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS

         CURSOR c_alc_ledger (p_ledger_id in number) is
         SELECT ledger_id, currency_code
         FROM  gl_alc_ledger_rships_v
         WHERE primary_ledger_id 	= p_ledger_id
         AND  application_id 		= 222
	 AND	org_id			 = MO_GLOBAL.get_current_org_id
--         AND  NVL(org_id,-99)		= NVL(NVL(rtrim(substr(userenv('CLIENT_INFO'),1,10)),-99), -99)
         AND  relationship_enabled_flag = 'Y' ;


 BEGIN
    declare
     delete_exemption_letter_id JE_IT_EXEMPT_LETTERS.exemption_letter_id%TYPE;
     delete_vendor_id  JE_IT_EXEMPT_LETTERS.vendor_id%TYPE;
     exchange_rate     	NUMBER;
     c_ledger_id  NUMBER;
    begin
     SELECT vendor_id,exemption_letter_id
     INTO delete_vendor_id, delete_exemption_letter_id
     FROM je_it_exempt_letters
     WHERE rowid = x_rowid;


     DELETE FROM JE_IT_EXEMPT_LETTERS
     WHERE rowid = X_Rowid;

     FOR rledger_rec IN c_alc_ledger(c_ledger_id)
     loop

       DELETE FROM JE_IT_EXEMPT_LETTERS
       WHERE set_of_books_id = rledger_rec.ledger_id
       AND   vendor_id = delete_vendor_id
       AND   exemption_letter_id = delete_exemption_letter_id;

     end loop;
     if (SQL%NOTFOUND) then
         Raise NO_DATA_FOUND;
     end if;
    end;
 END Delete_Row;


END JE_IT_EXEMPT_LETTERS_PKG;

/
