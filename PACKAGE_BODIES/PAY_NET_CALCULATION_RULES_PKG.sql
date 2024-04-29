--------------------------------------------------------
--  DDL for Package Body PAY_NET_CALCULATION_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_NET_CALCULATION_RULES_PKG" as
/* $Header: pyapncr.pkb 115.1 99/07/17 05:42:06 porting ship $ */


PROCEDURE Insert_Row(X_Rowid                        IN OUT VARCHAR2,
                     X_Net_Calculation_Rule_Id             IN OUT NUMBER,
                     X_Accrual_Plan_Id                     NUMBER,
                     X_Business_Group_Id                   NUMBER,
                     X_Input_Value_Id                      NUMBER,
                     X_Add_Or_Subtract                     VARCHAR2
 ) IS
   CURSOR C IS SELECT rowid FROM PAY_NET_CALCULATION_RULES

             WHERE net_calculation_rule_id = X_Net_Calculation_Rule_Id;





    CURSOR C2 IS SELECT pay_net_calculation_rules_s.nextval FROM sys.dual;
BEGIN

   if (X_Net_Calculation_Rule_Id is NULL) then
     OPEN C2;
     FETCH C2 INTO X_Net_Calculation_Rule_Id;
     CLOSE C2;
   end if;
  INSERT INTO PAY_NET_CALCULATION_RULES(
          net_calculation_rule_id,
          accrual_plan_id,
          business_group_id,
          input_value_id,
          add_or_subtract
         ) VALUES (
          X_Net_Calculation_Rule_Id,
          X_Accrual_Plan_Id,
          X_Business_Group_Id,
          X_Input_Value_Id,
          X_Add_Or_Subtract
  );

  OPEN C;
  FETCH C INTO X_Rowid;
  if (C%NOTFOUND) then
    CLOSE C;
    RAISE NO_DATA_FOUND;
  end if;
  CLOSE C;
END Insert_Row;
PROCEDURE Lock_Row(X_Rowid                                 VARCHAR2,
                   X_Net_Calculation_Rule_Id               NUMBER,
                   X_Accrual_Plan_Id                       NUMBER,
                   X_Business_Group_Id                     NUMBER,
                   X_Input_Value_Id                        NUMBER,
                   X_Add_Or_Subtract                       VARCHAR2
) IS
  CURSOR C IS
      SELECT *
      FROM   PAY_NET_CALCULATION_RULES
      WHERE  rowid = X_Rowid
      FOR UPDATE of Net_Calculation_Rule_Id NOWAIT;
  Recinfo C%ROWTYPE;
BEGIN
  OPEN C;
  FETCH C INTO Recinfo;
  if (C%NOTFOUND) then
    CLOSE C;
    RAISE NO_DATA_FOUND;
  end if;
  CLOSE C;
  if (
          (   (Recinfo.net_calculation_rule_id = X_Net_Calculation_Rule_Id)
           OR (    (Recinfo.net_calculation_rule_id IS NULL)
               AND (X_Net_Calculation_Rule_Id IS NULL)))
      AND (   (Recinfo.accrual_plan_id = X_Accrual_Plan_Id)
           OR (    (Recinfo.accrual_plan_id IS NULL)
               AND (X_Accrual_Plan_Id IS NULL)))
      AND (   (Recinfo.business_group_id = X_Business_Group_Id)
           OR (    (Recinfo.business_group_id IS NULL)
               AND (X_Business_Group_Id IS NULL)))
      AND (   (Recinfo.input_value_id = X_Input_Value_Id)
           OR (    (Recinfo.input_value_id IS NULL)
               AND (X_Input_Value_Id IS NULL)))
      AND (   (Recinfo.add_or_subtract = X_Add_Or_Subtract)
           OR (    (Recinfo.add_or_subtract IS NULL)
               AND (X_Add_Or_Subtract IS NULL)))
          ) then
    return;
  else
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
END Lock_Row;

PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Net_Calculation_Rule_Id             NUMBER,
                     X_Accrual_Plan_Id                     NUMBER,
                     X_Business_Group_Id                   NUMBER,
                     X_Input_Value_Id                      NUMBER,
                     X_Add_Or_Subtract                     VARCHAR2
) IS
BEGIN
  UPDATE PAY_NET_CALCULATION_RULES
  SET
    net_calculation_rule_id                   =    X_Net_Calculation_Rule_Id,
    accrual_plan_id                           =    X_Accrual_Plan_Id,
    business_group_id                         =    X_Business_Group_Id,
    input_value_id                            =    X_Input_Value_Id,
    add_or_subtract                           =    X_Add_Or_Subtract
  WHERE rowid = X_rowid;

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;

END Update_Row;

PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
BEGIN
  DELETE FROM PAY_NET_CALCULATION_RULES
  WHERE  rowid = X_Rowid;

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;
END Delete_Row;

PROCEDURE DUP_INPUT_VALUE(p_accrual_plan_id         IN number,
                          p_input_value_id          IN number,
                          p_net_calculation_rule_id IN number) IS
--
   l_comb_exists VARCHAR2(2);
--
   CURSOR dup_rec IS
   select 'Y'
   from   pay_net_calculation_rules
   where
        ((p_net_calculation_rule_id is null)
     or  (p_net_calculation_rule_id is not null
      and net_calculation_rule_id <>  p_net_calculation_rule_id))
   and    accrual_plan_id = p_accrual_plan_id
   and    input_value_id = p_input_value_id;
--
BEGIN
--
   l_comb_exists := 'N';
--
-- open fetch and close the cursor - if a record is found then the local
-- variable will be set to 'Y', otherwise it will remain 'N'
--
   OPEN dup_rec;
   FETCH dup_rec INTO l_comb_exists;
   CLOSE dup_rec;
--
-- go ahead and check the value of the local variable - if it's 'Y' then this
-- record is duplicated
--
   IF (l_comb_exists = 'Y') THEN
      hr_utility.set_message(801, 'HR_13162_PTO_DUP_INP_VAL');
      hr_utility.raise_error;
   END IF;
--
END DUP_INPUT_VALUE;

END PAY_NET_CALCULATION_RULES_PKG;

/
