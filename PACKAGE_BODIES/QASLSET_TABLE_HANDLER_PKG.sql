--------------------------------------------------------
--  DDL for Package Body QASLSET_TABLE_HANDLER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QASLSET_TABLE_HANDLER_PKG" as
/* $Header: qaslsetb.plb 115.4 2002/11/27 19:18:54 jezheng ship $ */

PROCEDURE insert_process_row(
      X_Rowid                IN OUT NOCOPY VARCHAR2,
      X_Process_id           IN OUT NOCOPY NUMBER,
      X_Process_Code         VARCHAR2,
      X_Description          VARCHAR2,
      X_Disqualification_Lots NUMBER	default 1,
      X_Disqualification_Days NUMBER,
      X_Org_id		     NUMBER,
      X_Last_Update_Date     DATE,
      X_Last_Updated_By      NUMBER,
      X_Creation_Date        DATE,
      X_Created_By           NUMBER,
      X_Last_Update_Login    NUMBER
) IS

   CURSOR C1 IS SELECT rowid FROM qa_skiplot_processes
               WHERE process_id = X_Process_id;

   CURSOR C2 IS SELECT qa_skiplot_processes_s.nextval FROM dual;

BEGIN

   if (X_Process_id is NULL) then
      OPEN C2;
      FETCH C2 INTO X_Process_id;
      CLOSE C2;
   end if;

   INSERT INTO QA_SKIPLOT_PROCESSES(
      process_id,
      process_code,
      description,
      disqualification_lots,
      disqualification_days,
      organization_id,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login
   )
   values(
      X_Process_id,
      X_Process_Code,
      X_Description,
      nvl(X_Disqualification_Lots, 1),
      X_Disqualification_Days,
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

END insert_process_row;



PROCEDURE insert_process_plans_row(
      X_Rowid                IN OUT NOCOPY VARCHAR2,
      X_Process_Plan_id      IN OUT NOCOPY NUMBER,
      X_Process_id           NUMBER,
      X_Plan_id              NUMBER,
      X_Alternate_Plan_id    NUMBER,
      X_Last_Update_Date     DATE,
      X_Last_Updated_By      NUMBER,
      X_Creation_Date        DATE,
      X_Created_By           NUMBER,
      X_Last_Update_Login    NUMBER
) IS

   CURSOR C1 IS SELECT rowid FROM qa_skiplot_process_plans
               WHERE process_plan_id = X_Process_Plan_id;

   CURSOR C2 IS SELECT qa_skiplot_process_plans_s.nextval FROM dual;

BEGIN

   if (X_Process_Plan_id is NULL) then
      OPEN C2;
      FETCH C2 INTO X_Process_Plan_id;
      CLOSE C2;
   end if;

   INSERT INTO QA_SKIPLOT_PROCESS_PLANS(
      process_plan_id,
      process_id,
      plan_id,
      alternate_plan_id,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login
   )
   values(
      X_Process_Plan_id,
      X_Process_id,
      X_Plan_id,
      X_Alternate_Plan_id,
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

END insert_process_plans_row;




PROCEDURE insert_process_plan_rules_row(
      X_Rowid                IN OUT NOCOPY VARCHAR2,
      X_Process_Plan_Rule_id IN OUT NOCOPY NUMBER,
      X_Process_Plan_id      NUMBER,
      X_Rule_Seq             NUMBER,
      X_Frequency_Num        NUMBER,
      X_Frequency_Denom      NUMBER,
      X_Rounds               NUMBER,
      X_Days_Span            NUMBER,
      X_Last_Update_Date     DATE,
      X_Last_Updated_By      NUMBER,
      X_Creation_Date        DATE,
      X_Created_By           NUMBER,
      X_Last_Update_Login    NUMBER
) IS


   CURSOR C1 IS SELECT rowid FROM qa_skiplot_process_plan_rules
               WHERE process_plan_id = X_Process_Plan_id and
               rule_seq = X_Rule_Seq;

   CURSOR C2 IS SELECT qa_skiplot_pp_rules_s.nextval FROM dual;


BEGIN

   if (X_Process_Plan_Rule_id is NULL) then
      OPEN C2;
      FETCH C2 INTO X_Process_Plan_Rule_id;
      CLOSE C2;
   end if;


   INSERT INTO QA_SKIPLOT_PROCESS_PLAN_RULES(
      process_plan_rule_id,
      process_plan_id,
      rule_seq,
      frequency_num,
      frequency_denom,
      rounds,
      days_span,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login
   )
   values(
      X_Process_Plan_Rule_id,
      X_Process_Plan_id,
      X_Rule_Seq,
      X_Frequency_Num,
      X_Frequency_Denom,
      X_Rounds,
      X_Days_Span,
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


END insert_process_plan_rules_row;





PROCEDURE update_process_row(
      X_Rowid                VARCHAR2,
      X_Process_id           NUMBER,
      X_Process_Code         VARCHAR2,
      X_Description          VARCHAR2,
      X_Disqualification_Lots NUMBER	default 1,
      X_Disqualification_Days NUMBER,
      X_Qualification_Lots NUMBER,
      X_Qualification_Days NUMBER,
      X_Org_id		     NUMBER,
      X_Last_Update_Date     DATE,
      X_Last_Updated_By      NUMBER,
      X_Creation_Date        DATE,
      X_Created_By           NUMBER,
      X_Last_Update_Login    NUMBER
) IS

  CURSOR C IS
    SELECT process_plan_rule_id
    FROM QA_SKIPLOT_PROCESSES p, QA_SKIPLOT_PROCESS_PLANS pp, QA_SKIPLOT_PROCESS_PLAN_RULES ppr
    WHERE p.process_id = X_Process_id
          and p.process_id = pp.process_id
          and pp.process_plan_id = ppr.process_plan_id
          and ppr.rule_seq = 0;

    ppr_id NUMBER;

BEGIN

   UPDATE QA_SKIPLOT_PROCESSES
   SET
      process_id                 =       X_Process_id,
      process_code               =       X_Process_Code,
      description                =       X_Description,
      disqualification_lots      =       nvl(X_Disqualification_Lots, 1),
      disqualification_days      =       X_Disqualification_Days,
      organization_id            =       X_Org_id,
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

   OPEN C;

   LOOP
    FETCH C into ppr_id;
    EXIT WHEN C%NOTFOUND;
    UPDATE QA_SKIPLOT_PROCESS_PLAN_RULES
    SET
      rounds                 =       X_Qualification_Lots,
      days_span              =       X_Qualification_Days,
      last_update_date       =       X_Last_Update_Date,
      last_updated_by        =       X_Last_Updated_By,
      creation_date          =       X_Creation_Date,
      created_by             =       X_Created_By,
      last_update_login      =       X_Last_Update_Login
   WHERE process_plan_rule_id = ppr_id;
   END LOOP;

END update_process_row;



PROCEDURE update_process_plans_row(
      X_Rowid                VARCHAR2,
      X_Process_Plan_id      NUMBER,
      X_Process_id           NUMBER,
      X_Plan_id              NUMBER,
      X_Alternate_Plan_id    NUMBER,
      X_Last_Update_Date     DATE,
      X_Last_Updated_By      NUMBER,
      X_Creation_Date        DATE,
      X_Created_By           NUMBER,
      X_Last_Update_Login    NUMBER
) IS

BEGIN

   UPDATE QA_SKIPLOT_PROCESS_PLANS
   SET
      process_plan_id           =       X_Process_Plan_id,
      process_id                =       X_Process_id,
      plan_id                   =       X_Plan_id,
      alternate_plan_id         =       X_Alternate_Plan_id,
      last_update_date          =       X_Last_Update_Date,
      last_updated_by           =       X_Last_Updated_By,
      creation_date             =       X_Creation_Date,
      created_by                =       X_Created_By,
      last_update_login         =       X_Last_Update_Login
   WHERE rowid = X_Rowid;

   --commit;

   if (SQL%NOTFOUND) then
     Raise NO_DATA_FOUND;
   end if;

END update_process_plans_row;




PROCEDURE update_process_plan_rules_row(
      X_Rowid                VARCHAR2,
      X_Process_Plan_Rule_id NUMBER,
      X_Process_Plan_id      NUMBER,
      X_Rule_Seq             NUMBER,
      X_Frequency_Num        NUMBER,
      X_Frequency_Denom      NUMBER,
      X_Rounds               NUMBER,
      X_Days_Span            NUMBER,
      X_Last_Update_Date     DATE,
      X_Last_Updated_By      NUMBER,
      X_Creation_Date        DATE,
      X_Created_By           NUMBER,
      X_Last_Update_Login    NUMBER
) IS

BEGIN

    UPDATE QA_SKIPLOT_PROCESS_PLAN_RULES
    SET
      process_plan_rule_id   =       X_Process_Plan_Rule_id,
      process_plan_id        =       X_Process_Plan_id,
      rule_seq               =       X_Rule_Seq,
      frequency_num          =       X_Frequency_Num,
      frequency_denom        =       X_Frequency_Denom,
      rounds                 =       X_Rounds,
      days_span              =       X_Days_Span,
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

END update_process_plan_rules_row;





PROCEDURE lock_process_row(
      X_Rowid                VARCHAR2,
      X_Process_id           NUMBER,
      X_Process_Code         VARCHAR2,
      X_Description          VARCHAR2,
      X_Disqualification_Lots NUMBER	default 1,
      X_Disqualification_Days NUMBER,
      X_Qualification_Lots    NUMBER,
      X_Qualification_Days    NUMBER,
      X_Org_id		     NUMBER,
      X_Last_Update_Date     DATE,
      X_Last_Updated_By      NUMBER,
      X_Creation_Date        DATE,
      X_Created_By           NUMBER,
      X_Last_Update_Login    NUMBER
) IS

  CURSOR C IS
     SELECT *
     FROM   QA_SKIPLOT_PROCESSES
     WHERE  rowid = X_Rowid
     FOR UPDATE of process_id NOWAIT;

     Recinfo C%ROWTYPE;


  CURSOR C1 IS
     SELECT ppr.rounds qualification_lots, ppr.days_span qualification_days
     FROM   QA_SKIPLOT_PROCESSES p, QA_SKIPLOT_PROCESS_PLANS pp, QA_SKIPLOT_PROCESS_PLAN_RULES ppr
     WHERE  p.process_id = X_Process_id and p.process_id = pp.process_id and pp.process_plan_id = ppr.process_plan_id and ppr.rule_seq = 0
     FOR UPDATE of ppr.process_plan_id, ppr.process_plan_rule_id NOWAIT;

     Recinfo1 C1%ROWTYPE;


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
       (Recinfo.process_id =  X_Process_id)
       AND (Recinfo.process_code =  X_Process_Code)
       AND (   (Recinfo.description =  X_Description)
               OR (    (Recinfo.description IS NULL)
                        AND (X_Description IS NULL)))
       AND (Recinfo.disqualification_lots =  X_Disqualification_Lots)
       AND (   (Recinfo.disqualification_days =  X_Disqualification_Days)
               OR (    (Recinfo.disqualification_days IS NULL)
                        AND (X_Disqualification_Days IS NULL)))
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
   -- return;

  else
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.Raise_Exception;

  end if;

  -- locking default rule rows with rule_seq =0;

  OPEN C1;
  /* notice that checking only one row because the default rows all contain the same values for qualification lots and qualification days. and the other columns are unaccessible to the user and hence not checked.*/

  FETCH C1 INTO Recinfo1;

  if (C1%NOTFOUND) then
      CLOSE C1;
  else

  if (
           (   (Recinfo1.qualification_lots =  X_Qualification_Lots)
               OR (    (Recinfo1.qualification_lots IS NULL)
                        AND (X_Qualification_lots IS NULL)))
       AND (   (Recinfo1.qualification_days =  X_Qualification_Days)
               OR (    (Recinfo1.qualification_days IS NULL)
                        AND (X_Qualification_Days IS NULL)))
  ) then

    return;

  else
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.Raise_Exception;

  end if;

  end if;
  CLOSE C1;

END lock_process_row;



PROCEDURE lock_process_plans_row(
      X_Rowid                VARCHAR2,
      X_Process_Plan_id      NUMBER,
      X_Process_id           NUMBER,
      X_Plan_id              NUMBER,
      X_Alternate_Plan_id    NUMBER,
      X_Last_Update_Date     DATE,
      X_Last_Updated_By      NUMBER,
      X_Creation_Date        DATE,
      X_Created_By           NUMBER,
      X_Last_Update_Login    NUMBER
) IS

  CURSOR C IS
     SELECT *
     FROM   QA_SKIPLOT_PROCESS_PLANS
     WHERE  rowid = X_Rowid
     FOR UPDATE of process_plan_id NOWAIT;

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
       (Recinfo.process_plan_id =  X_Process_Plan_id)
       AND (Recinfo.process_id =  X_Process_id)
       AND (Recinfo.plan_id =  X_Plan_id)
       AND (   (Recinfo.alternate_plan_id =  X_Alternate_Plan_id)
               OR (    (Recinfo.alternate_plan_id IS NULL)
                        AND (X_Alternate_Plan_id IS NULL)))
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

END lock_process_plans_row;




PROCEDURE lock_process_plan_rules_row(
      X_Rowid                VARCHAR2,
      X_Process_Plan_Rule_id NUMBER,
      X_Process_Plan_id      NUMBER,
      X_Rule_Seq             NUMBER,
      X_Frequency_Num        NUMBER,
      X_Frequency_Denom      NUMBER,
      X_Rounds               NUMBER,
      X_Days_Span            NUMBER,
      X_Last_Update_Date     DATE,
      X_Last_Updated_By      NUMBER,
      X_Creation_Date        DATE,
      X_Created_By           NUMBER,
      X_Last_Update_Login    NUMBER
) IS

  CURSOR C IS
     SELECT *
     FROM   QA_SKIPLOT_PROCESS_PLAN_RULES
     WHERE  rowid = X_Rowid
     FOR UPDATE of process_plan_rule_id NOWAIT;

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
       (Recinfo.process_plan_rule_id =  X_Process_Plan_Rule_id)
       AND (Recinfo.process_plan_id =  X_Process_Plan_id)
       AND (Recinfo.rule_seq =  X_Rule_Seq)
       AND (Recinfo.frequency_num =  X_Frequency_Num)
       AND (Recinfo.frequency_denom =  X_Frequency_Denom)
       AND (   (Recinfo.rounds =  X_Rounds)
               OR (    (Recinfo.rounds IS NULL)
                        AND (X_Rounds IS NULL)))
       AND (   (Recinfo.days_span =  X_Days_Span)
               OR (    (Recinfo.days_span IS NULL)
                        AND (X_Days_Span IS NULL)))
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

END lock_process_plan_rules_row;





PROCEDURE delete_process_row(X_Rowid VARCHAR2) IS

BEGIN

  delete from QA_SKIPLOT_PROCESSES
  where rowid = X_Rowid;

  if (SQL%NOTFOUND) then
     Raise NO_DATA_FOUND;
  end if;

END delete_process_row;




PROCEDURE delete_process_plans_row(X_Rowid VARCHAR2) IS

BEGIN

  delete from QA_SKIPLOT_PROCESS_PLANS
  where rowid = X_Rowid;

  if (SQL%NOTFOUND) then
     Raise NO_DATA_FOUND;
  end if;

END delete_process_plans_row;





PROCEDURE delete_process_plan_rules_row(X_Rowid VARCHAR2) IS

BEGIN
  delete from QA_SKIPLOT_PROCESS_PLAN_RULES
  where rowid = X_Rowid;

  if (SQL%NOTFOUND) then
     Raise NO_DATA_FOUND;
  end if;

END delete_process_plan_rules_row;






END QASLSET_TABLE_HANDLER_PKG;

/
