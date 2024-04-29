--------------------------------------------------------
--  DDL for Package Body QASPSET_TABLE_HANDLER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QASPSET_TABLE_HANDLER_PKG" as
/* $Header: qaspsetb.plb 115.3 2002/11/27 19:20:26 jezheng ship $ */

PROCEDURE insert_plan_header_row(
      X_Rowid                IN OUT NOCOPY VARCHAR2,
      X_Sampling_Plan_id     IN OUT NOCOPY NUMBER,
      X_Sampling_Plan_Code   VARCHAR2,
      X_Description          VARCHAR2,
      X_Insp_Level_Code      VARCHAR2,
      X_Sampling_Std_Code    NUMBER,
      X_AQL                  NUMBER,
      X_Org_id		     NUMBER,
      X_Last_Update_Date     DATE,
      X_Last_Updated_By      NUMBER,
      X_Creation_Date        DATE,
      X_Created_By           NUMBER,
      X_Last_Update_Login    NUMBER
) IS

   CURSOR C1 IS SELECT rowid FROM qa_sampling_plans
               WHERE sampling_plan_id = X_Sampling_Plan_id;

   CURSOR C2 IS SELECT qa_sampling_plan_s.nextval FROM dual;

BEGIN

   if (X_Sampling_Plan_id is NULL) then
      OPEN C2;
      FETCH C2 INTO X_Sampling_Plan_id;
      CLOSE C2;
   end if;

   INSERT INTO QA_SAMPLING_PLANS(
      sampling_plan_id,
      sampling_plan_code,
      description,
      insp_level_code,
      sampling_std_code,
      aql,
      organization_id,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login
   )
   values(
      X_Sampling_Plan_id,
      X_Sampling_Plan_Code,
      X_Description,
      X_Insp_Level_Code,
      X_Sampling_Std_Code,
      X_AQL,
      X_Org_id,
      X_Last_Update_Date,
      X_Last_Updated_By,
      X_Creation_Date,
      X_Created_By,
      X_Last_Update_Login
   );

   --commit;

   OPEN C1;
   FETCH C1 INTO X_Rowid;
   if (C1%NOTFOUND) then
     CLOSE C1;
     Raise NO_DATA_FOUND;
   end if;
   CLOSE C1;

END insert_plan_header_row;



PROCEDURE insert_customized_rules_row(
      X_Rowid                IN OUT NOCOPY VARCHAR2,
      X_Rule_id              IN OUT NOCOPY NUMBER,
      X_Sampling_Plan_id     NUMBER,
      X_Min_Lot_Size         NUMBER,
      X_Max_Lot_Size         NUMBER,
      X_Sample_Size          NUMBER,
      X_Last_Update_Date     DATE,
      X_Last_Updated_By      NUMBER,
      X_Creation_Date        DATE,
      X_Created_By           NUMBER,
      X_Last_Update_Login    NUMBER
) IS

   CURSOR C1 IS SELECT rowid FROM qa_sampling_custom_rules
               WHERE rule_id = X_Rule_id;

   CURSOR C2 IS SELECT qa_sampling_rules_s.nextval FROM dual;

BEGIN
null;

   if (X_Rule_id is NULL) then
      OPEN C2;
      FETCH C2 INTO X_Rule_id;
      CLOSE C2;
   end if;

   INSERT INTO QA_SAMPLING_CUSTOM_RULES(
      rule_id,
      sampling_plan_id,
      min_lot_size,
      max_lot_size,
      sample_size,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login
   )
   values(
      X_Rule_id,
      X_Sampling_Plan_id,
      X_Min_Lot_Size,
      X_Max_Lot_Size,
      X_Sample_Size,
      X_Last_Update_Date,
      X_Last_Updated_By,
      X_Creation_Date,
      X_Created_By,
      X_Last_Update_Login
   );

   --commit;


   OPEN C1;
   FETCH C1 INTO X_Rowid;
   if (C1%NOTFOUND) then
     CLOSE C1;
     Raise NO_DATA_FOUND;
   end if;
   CLOSE C1;

END insert_customized_rules_row;




PROCEDURE update_plan_header_row(
      X_Rowid                VARCHAR2,
      X_Sampling_Plan_id     NUMBER,
      X_Sampling_Plan_Code   VARCHAR2,
      X_Description          VARCHAR2,
      X_Insp_Level_Code      VARCHAR2,
      X_Sampling_Std_Code    NUMBER,
      X_AQL                  NUMBER,
      X_Org_id		     NUMBER,
      X_Last_Update_Date     DATE,
      X_Last_Updated_By      NUMBER,
      X_Creation_Date        DATE,
      X_Created_By           NUMBER,
      X_Last_Update_Login    NUMBER
) IS

BEGIN

   UPDATE QA_SAMPLING_PLANS
   SET
      sampling_plan_id           =       X_Sampling_Plan_id,
      sampling_plan_code         =       X_Sampling_Plan_Code,
      description                =       X_Description,
      insp_level_code            =       X_Insp_Level_Code,
      sampling_std_code          =       X_Sampling_Std_Code,
      aql                        =       X_AQL,
      organization_id		 =	 X_Org_id,
      last_update_date           =       X_Last_Update_Date,
      last_updated_by            =       X_Last_Updated_By,
      creation_date              =       X_Creation_Date,
      created_by                 =       X_Created_By,
      last_update_login          =       X_Last_Update_Login
   WHERE rowid = X_Rowid;

   --commit;

   if (SQL%NOTFOUND) then
     Raise NO_DATA_FOUND;
   end if;

END update_plan_header_row;




PROCEDURE update_customized_rules_row(
      X_Rowid                VARCHAR2,
      X_Rule_id              NUMBER,
      X_Sampling_Plan_id     NUMBER,
      X_Min_Lot_Size         NUMBER,
      X_Max_Lot_Size         NUMBER,
      X_Sample_Size          NUMBER,
      X_Last_Update_Date     DATE,
      X_Last_Updated_By      NUMBER,
      X_Creation_Date        DATE,
      X_Created_By           NUMBER,
      X_Last_Update_Login    NUMBER
) IS

BEGIN

    UPDATE QA_SAMPLING_CUSTOM_RULES
    SET
      rule_id                =       X_Rule_id,
      sampling_plan_id       =       X_Sampling_Plan_id,
      min_lot_size           =       X_Min_Lot_Size,
      max_lot_size           =       X_Max_Lot_Size,
      sample_size            =       X_Sample_Size,
      last_update_date       =       X_Last_Update_Date,
      last_updated_by        =       X_Last_Updated_By,
      creation_date          =       X_Creation_Date,
      created_by             =       X_Created_By,
      last_update_login      =       X_Last_Update_Login
   WHERE rowid = X_Rowid;

   --commit;

   if (SQL%NOTFOUND) then
     Raise NO_DATA_FOUND;
   end if;

END update_customized_rules_row;





PROCEDURE lock_plan_header_row(
      X_Rowid                VARCHAR2,
      X_Sampling_Plan_id     NUMBER,
      X_Sampling_Plan_Code   VARCHAR2,
      X_Description          VARCHAR2,
      X_Insp_Level_Code      VARCHAR2,
      X_Sampling_Std_Code    NUMBER,
      X_AQL                  NUMBER,
      X_Org_id		     NUMBER,
      X_Last_Update_Date     DATE,
      X_Last_Updated_By      NUMBER,
      X_Creation_Date        DATE,
      X_Created_By           NUMBER,
      X_Last_Update_Login    NUMBER
) IS

  CURSOR C IS
     SELECT *
     FROM   QA_SAMPLING_PLANS
     WHERE  rowid = X_Rowid
     FOR UPDATE of sampling_plan_id NOWAIT;

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
       (Recinfo.sampling_plan_id =  X_Sampling_Plan_id)
       AND (Recinfo.sampling_plan_code =  X_Sampling_Plan_Code)
       AND (   (Recinfo.description =  X_Description)
               OR (    (Recinfo.description IS NULL)
                        AND (X_Description IS NULL)))
       AND (   (Recinfo.insp_level_code =  X_Insp_Level_Code)
               OR (    (Recinfo.insp_level_code IS NULL)
                        AND (X_Insp_Level_Code IS NULL)))
       AND (Recinfo.sampling_std_code =  X_Sampling_Std_Code)
       AND (   (Recinfo.aql =  X_AQL)
               OR (    (Recinfo.aql IS NULL)
                        AND (X_AQL IS NULL)))
       AND (Recinfo.organization_id =  X_Org_id)
       AND (Recinfo.last_update_date =  X_Last_Update_Date)
       AND (Recinfo.last_updated_by =  X_Last_Updated_By)
       AND (Recinfo.creation_date =  X_Creation_Date)
       AND (Recinfo.created_by =  X_Created_By)
       AND (   (Recinfo.last_update_login =  X_Last_Update_Login)
               OR (    (Recinfo.last_update_login IS NULL)
                        AND (X_Last_Update_Login IS NULL)))

  ) then
    null;
   return;

  else
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.Raise_Exception;

  end if;

END lock_plan_header_row;




PROCEDURE lock_customized_rules_row(
      X_Rowid                VARCHAR2,
      X_Rule_id              NUMBER,
      X_Sampling_Plan_id     NUMBER,
      X_Min_Lot_Size         NUMBER,
      X_Max_Lot_Size         NUMBER,
      X_Sample_Size          NUMBER,
      X_Last_Update_Date     DATE,
      X_Last_Updated_By      NUMBER,
      X_Creation_Date        DATE,
      X_Created_By           NUMBER,
      X_Last_Update_Login    NUMBER
) IS

  CURSOR C IS
     SELECT *
     FROM   QA_SAMPLING_CUSTOM_RULES
     WHERE  rowid = X_Rowid
     FOR UPDATE of rule_id NOWAIT;

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
       (Recinfo.rule_id =  X_Rule_id)
       AND (Recinfo.sampling_plan_id =  X_Sampling_Plan_id)
       AND (Recinfo.min_lot_size =  X_Min_Lot_Size)
       AND (   (Recinfo.max_lot_size =  X_Max_Lot_Size)
               OR (    (Recinfo.max_lot_size IS NULL)
                        AND (X_Max_Lot_Size IS NULL)))
       AND (Recinfo.sample_size =  X_Sample_Size)
       AND (Recinfo.last_update_date =  X_Last_Update_Date)
       AND (Recinfo.last_updated_by =  X_Last_Updated_By)
       AND (Recinfo.creation_date =  X_Creation_Date)
       AND (Recinfo.created_by =  X_Created_By)
       AND (   (Recinfo.last_update_login =  X_Last_Update_Login)
               OR (    (Recinfo.last_update_login IS NULL)
                        AND (X_Last_Update_Login IS NULL)))

  ) then

    return;

  else
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.Raise_Exception;

  end if;

END lock_customized_rules_row;





PROCEDURE delete_plan_header_row(X_Rowid VARCHAR2) IS

BEGIN
  delete from QA_SAMPLING_PLANS
  where rowid = X_Rowid;

  if (SQL%NOTFOUND) then
     Raise NO_DATA_FOUND;
  end if;

END delete_plan_header_row;




PROCEDURE delete_customized_rules_row(X_Rowid VARCHAR2) IS

BEGIN
  delete from QA_SAMPLING_CUSTOM_RULES
  where rowid = X_Rowid;

  if (SQL%NOTFOUND) then
     Raise NO_DATA_FOUND;
  end if;

END delete_customized_rules_row;






END QASPSET_TABLE_HANDLER_PKG;

/
