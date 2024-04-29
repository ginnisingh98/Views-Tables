--------------------------------------------------------
--  DDL for Package Body PAY_US_GARN_FEE_RULES_F_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_GARN_FEE_RULES_F_PKG" as
/* $Header: pygfr01t.pkb 115.1.1150.1 2000/02/10 15:53:37 pkm ship     $ */

  PROCEDURE Insert_Row(X_Rowid                   IN OUT VARCHAR2,
                       X_Fee_Rule_Id                    IN OUT NUMBER,
                       X_Effective_Start_Date           DATE,
                       X_Effective_End_Date             DATE,
                       X_Garn_Category                  VARCHAR2,
                       X_State_Code                     VARCHAR2,
                       X_Addl_Garn_Fee_Amount           NUMBER,
                       X_Correspondence_Fee             NUMBER,
                       X_Creator_Type                   VARCHAR2,
                       X_Fee_Amount                     NUMBER,
                       X_Fee_Rule                       VARCHAR2,
                       X_Max_Fee_Amount                 NUMBER,
                       X_Pct_Current                    NUMBER,
							  X_Take_Fee_On_Proration          VARCHAR2,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Created_By                     NUMBER,
                       X_Creation_Date                  DATE
  ) IS
    CURSOR C IS SELECT rowid FROM PAY_US_GARN_FEE_RULES_F
                 WHERE fee_rule_id = X_Fee_Rule_Id;
      CURSOR C2 IS SELECT pay_us_garn_fee_rules_s.nextval FROM sys.dual;
   BEGIN
      if (X_Fee_Rule_Id is NULL) then
        OPEN C2;
        FETCH C2 INTO X_Fee_Rule_Id;
        CLOSE C2;
      end if;

       INSERT INTO PAY_US_GARN_FEE_RULES_F(

              fee_rule_id,
              effective_start_date,
              effective_end_date,
              garn_category,
              state_code,
              addl_garn_fee_amount,
              correspondence_fee,
              creator_type,
              fee_amount,
              fee_rule,
              max_fee_amount,
              pct_current,
				  take_fee_on_proration,
              last_update_date,
              last_updated_by,
              last_update_login,
              created_by,
              creation_date
             ) VALUES (

              X_Fee_Rule_Id,
              X_Effective_Start_Date,
              X_Effective_End_Date,
              X_Garn_Category,
              X_State_Code,
              X_Addl_Garn_Fee_Amount,
              X_Correspondence_Fee,
              X_Creator_Type,
              X_Fee_Amount,
              X_Fee_Rule,
              X_Max_Fee_Amount,
              X_Pct_Current,
				  X_Take_Fee_On_Proration,
              X_Last_Update_Date,
              X_Last_Updated_By,
              X_Last_Update_Login,
              X_Created_By,
              X_Creation_Date

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
                     X_Fee_Rule_Id                      NUMBER,
                     X_Effective_Start_Date             DATE,
                     X_Effective_End_Date               DATE,
                     X_Garn_Category                    VARCHAR2,
                     X_State_Code                       VARCHAR2,
                     X_Addl_Garn_Fee_Amount             NUMBER,
                     X_Correspondence_Fee               NUMBER,
                     X_Creator_Type                     VARCHAR2,
                     X_Fee_Amount                       NUMBER,
                     X_Fee_Rule                         VARCHAR2,
                     X_Max_Fee_Amount                   NUMBER,
                     X_Pct_Current                      NUMBER,
							X_Take_Fee_On_Proration            VARCHAR2
  ) IS
    CURSOR C IS
        SELECT *
        FROM   PAY_US_GARN_FEE_RULES_F
        WHERE  rowid = X_Rowid
        FOR UPDATE of Fee_Rule_Id NOWAIT;
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

               (Recinfo.fee_rule_id =  X_Fee_Rule_Id)
           AND (Recinfo.effective_start_date =  X_Effective_Start_Date)
           AND (Recinfo.effective_end_date =  X_Effective_End_Date)
           AND (Recinfo.garn_category =  X_Garn_Category)
           AND (Recinfo.state_code =  X_State_Code)
           AND (   (Recinfo.addl_garn_fee_amount =  X_Addl_Garn_Fee_Amount)
                OR (    (Recinfo.addl_garn_fee_amount IS NULL)
                    AND (X_Addl_Garn_Fee_Amount IS NULL)))
           AND (   (Recinfo.correspondence_fee =  X_Correspondence_Fee)
                OR (    (Recinfo.correspondence_fee IS NULL)
                    AND (X_Correspondence_Fee IS NULL)))
           AND (   (Recinfo.creator_type =  X_Creator_Type)
                OR (    (Recinfo.creator_type IS NULL)
                    AND (X_Creator_Type IS NULL)))
           AND (   (Recinfo.fee_amount =  X_Fee_Amount)
                OR (    (Recinfo.fee_amount IS NULL)
                    AND (X_Fee_Amount IS NULL)))
           AND (   (Recinfo.fee_rule =  X_Fee_Rule)
                OR (    (Recinfo.fee_rule IS NULL)
                    AND (X_Fee_Rule IS NULL)))
           AND (   (Recinfo.max_fee_amount =  X_Max_Fee_Amount)
                OR (    (Recinfo.max_fee_amount IS NULL)
                    AND (X_Max_Fee_Amount IS NULL)))
           AND (   (Recinfo.pct_current =  X_Pct_Current)
                OR (    (Recinfo.pct_current IS NULL)
                    AND (X_Pct_Current IS NULL)))
		     AND (   (Recinfo.take_fee_on_proration =  X_Take_Fee_On_Proration)
					 OR (    (Recinfo.take_fee_on_proration IS NULL)
					     AND (X_take_fee_on_proration IS NULL)))
      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_Row;



  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Fee_Rule_Id                    NUMBER,
                       X_Effective_Start_Date           DATE,
                       X_Effective_End_Date             DATE,
                       X_Garn_Category                  VARCHAR2,
                       X_State_Code                     VARCHAR2,
                       X_Addl_Garn_Fee_Amount           NUMBER,
                       X_Correspondence_Fee             NUMBER,
                       X_Creator_Type                   VARCHAR2,
                       X_Fee_Amount                     NUMBER,
                       X_Fee_Rule                       VARCHAR2,
                       X_Max_Fee_Amount                 NUMBER,
                       X_Pct_Current                    NUMBER,
							  X_Take_Fee_On_Proration			  VARCHAR2,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER

  ) IS
  BEGIN
    UPDATE PAY_US_GARN_FEE_RULES_F
    SET
       fee_rule_id                     =     X_Fee_Rule_Id,
       effective_start_date            =     X_Effective_Start_Date,
       effective_end_date              =     X_Effective_End_Date,
       garn_category                   =     X_Garn_Category,
       state_code                      =     X_State_Code,
       addl_garn_fee_amount            =     X_Addl_Garn_Fee_Amount,
       correspondence_fee              =     X_Correspondence_Fee,
       creator_type                    =     X_Creator_Type,
       fee_amount                      =     X_Fee_Amount,
       fee_rule                        =     X_Fee_Rule,
       max_fee_amount                  =     X_Max_Fee_Amount,
       pct_current                     =     X_Pct_Current,
		 take_fee_on_proration           =     X_Take_Fee_On_Proration,
       last_update_date                =     X_Last_Update_Date,
       last_updated_by                 =     X_Last_Updated_By,
       last_update_login               =     X_Last_Update_Login
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Update_Row;
  PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
  BEGIN
    DELETE FROM PAY_US_GARN_FEE_RULES_F
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Row;

  PROCEDURE Check_Unique( X_State_Code                     VARCHAR2,
                          X_Garn_Category                  VARCHAR2
  ) IS
    DUMMY NUMBER;

  BEGIN

     SELECT  count(1)
     INTO    DUMMY
     FROM    pay_us_garn_fee_rules_f
     WHERE   state_code = X_State_Code
     AND     GARN_CATEGORY = X_Garn_Category;

     IF (DUMMY >= 1) then
         hr_utility.set_message(801, 'PAY_51332_GFR_CHECK_UNIQUE');
         hr_utility.raise_error;
     END IF;

  END check_unique;


END PAY_US_GARN_FEE_RULES_F_PKG;

/
