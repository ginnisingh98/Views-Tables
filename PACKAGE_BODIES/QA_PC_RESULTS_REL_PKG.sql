--------------------------------------------------------
--  DDL for Package Body QA_PC_RESULTS_REL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QA_PC_RESULTS_REL_PKG" as
/* $Header: qapcresb.pls 120.0.12010000.2 2009/03/19 06:12:44 skolluku ship $ */
 PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Parent_Plan_Id                 NUMBER,
                       X_Parent_Collection_Id           NUMBER,
                       X_Parent_Occurrence              NUMBER,
                       X_Child_Plan_Id                  NUMBER,
                       X_Child_Collection_Id            NUMBER,
                       X_Child_Occurrence               NUMBER,
                       X_Enabled_Flag                   NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Child_Txn_Header_Id            NUMBER
  ) IS
     CURSOR C IS SELECT rowid FROM QA_PC_RESULTS_RELATIONSHIP
                 WHERE parent_plan_id = X_Parent_Plan_Id
                 AND   parent_collection_id = X_Parent_Collection_Id
                 AND   parent_occurrence = X_Parent_Occurrence
                 AND   child_plan_id = X_Child_Plan_Id
                 AND   child_collection_id = X_Child_Collection_Id
                 AND   child_occurrence = X_Child_Occurrence;
 BEGIN

       --
       -- Bug 8273401
       -- Checking if a record for this combination already exists.
       -- If it does, then do not insert one more row and exit.
       -- This would avoid duplicate entries from being entered into
       -- the qa_pc_results_relationship table.
       -- skolluku
       --
       OPEN C;
       FETCH C INTO X_Rowid;
       if (C%FOUND) then
         CLOSE C;
         return;
       end if;
       CLOSE C;

       INSERT INTO QA_PC_RESULTS_RELATIONSHIP(
                   parent_plan_id,
                   parent_collection_id,
                   parent_occurrence,
                   child_plan_id,
                   child_collection_id,
                   child_occurrence,
                   enabled_flag,
                   last_update_date,
                   last_updated_by,
                   creation_date,
                   created_by,
                   last_update_login,
                   child_txn_header_id
          )VALUES(
                   X_Parent_Plan_Id,
                   X_Parent_Collection_Id,
                   X_Parent_Occurrence,
                   X_Child_Plan_Id,
                   X_Child_Collection_Id,
                   X_Child_Occurrence,
                   X_Enabled_Flag,
                   X_Last_Update_Date,
                   X_Last_Updated_By,
                   X_Creation_Date,
                   X_Created_By,
                   X_Last_Update_Login,
                   X_Child_Txn_Header_Id
      );
    OPEN C;
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;
  END Insert_Row;


 PROCEDURE Lock_Row(X_Rowid                             VARCHAR2,
                       X_Parent_Plan_Id                 NUMBER,
                       X_Parent_Collection_Id           NUMBER,
                       X_Parent_Occurrence              NUMBER,
                       X_Child_Plan_Id                  NUMBER,
                       X_Child_Collection_Id            NUMBER,
                       X_Child_Occurrence               NUMBER,
                       X_Enabled_Flag                   NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Child_Txn_Header_Id            NUMBER

 ) IS
    CURSOR C IS
        SELECT *
        FROM   QA_PC_RESULTS_RELATIONSHIP
        WHERE  rowid = X_Rowid
        FOR UPDATE of Child_Occurrence NOWAIT;
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
               (Recinfo.parent_plan_id =  X_Parent_Plan_Id)
           AND (Recinfo.parent_collection_id = X_Parent_Collection_Id)
           AND (Recinfo.parent_occurrence = X_Parent_Occurrence)
           AND (Recinfo.child_plan_id = X_Child_Plan_Id)
           AND (Recinfo.child_collection_id = X_Child_Collection_Id)
           AND (Recinfo.child_occurrence = X_Child_Occurrence)
           AND (Recinfo.enabled_flag = X_Enabled_Flag)
           AND (Recinfo.last_update_date =  X_Last_Update_Date)
           AND (Recinfo.last_updated_by =  X_Last_Updated_By)
           AND (Recinfo.creation_date =  X_Creation_Date)
           AND (Recinfo.created_by =  X_Created_By)
           AND (Recinfo.child_txn_header_id = X_Child_Txn_Header_Id)
        ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;

  END Lock_Row;

 PROCEDURE Update_Row(X_Rowid                           VARCHAR2,
                       X_Parent_Plan_Id                 NUMBER,
                       X_Parent_Collection_Id           NUMBER,
                       X_Parent_Occurrence              NUMBER,
                       X_Child_Plan_Id                  NUMBER,
                       X_Child_Collection_Id            NUMBER,
                       X_Child_Occurrence               NUMBER,
                       X_Enabled_Flag                   NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Child_Txn_Header_Id            NUMBER

  ) IS
  BEGIN
    UPDATE QA_PC_RESULTS_RELATIONSHIP
    SET
         parent_plan_id               = X_Parent_Plan_Id,
         parent_collection_id         = X_Parent_Collection_Id,
         parent_occurrence            = X_Parent_Occurrence,
         child_plan_id                = X_Child_Plan_Id,
         child_collection_id          = X_Child_Collection_Id,
         child_occurrence             = X_Child_Occurrence,
         enabled_flag                 = X_Enabled_Flag,
         last_update_date             = X_Last_Update_Date,
         last_updated_by              = X_Last_Updated_By,
         creation_date                = X_Creation_Date,
         created_by                   = X_Created_By,
         last_update_login            = X_Last_Update_Login,
         child_txn_header_id          = X_Child_Txn_Header_Id
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Update_Row;

  PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
  BEGIN
    DELETE FROM QA_PC_RESULTS_RELATIONSHIP
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Row;


END QA_PC_RESULTS_REL_PKG;

/
