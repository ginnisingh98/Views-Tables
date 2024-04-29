--------------------------------------------------------
--  DDL for Package Body QA_PC_PLAN_REL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QA_PC_PLAN_REL_PKG" as
/* $Header: qapcplnb.pls 115.5 2003/09/16 00:17:53 rkaza ship $ */

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Plan_Relationship_Id    IN OUT NOCOPY NUMBER,
                       X_Parent_Plan_Id                 NUMBER,
                       X_Child_Plan_id                  NUMBER,
                       X_Plan_Relationship_Type         NUMBER,
                       X_Data_Entry_Mode                NUMBER,
                       X_Layout_mode                    NUMBER,
                       X_Auto_Row_Count                 NUMBER,
                       X_Default_Parent_Spec            NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER
 ) IS
     CURSOR C IS SELECT rowid FROM QA_PC_PLAN_RELATIONSHIP
		 WHERE plan_relationship_id = X_Plan_Relationship_Id;
     CURSOR C2 IS SELECT qa_pc_plan_relationship_s.nextval FROM dual;

    BEGIN
      if (X_Plan_Relationship_Id is NULL) then
        OPEN C2;
        FETCH C2 INTO X_Plan_Relationship_Id;
        CLOSE C2;
      end if;

       INSERT INTO QA_PC_PLAN_RELATIONSHIP(
                   plan_relationship_id,
                   parent_plan_id,
                   child_plan_id,
                   plan_relationship_type,
                   data_entry_mode,
                   layout_mode,
                   auto_row_count,
                   default_parent_spec,
                   last_update_date,
                   last_updated_by,
                   creation_date,
                   created_by,
                   last_update_login
                 ) VALUES (
                   X_Plan_Relationship_Id,
                   X_Parent_Plan_Id,
                   X_Child_Plan_id,
                   X_Plan_Relationship_Type,
                   X_Data_Entry_Mode,
                   X_Layout_Mode,
                   X_Auto_Row_Count,
                   X_Default_Parent_Spec,
                   X_Last_Update_Date,
                   X_Last_Updated_By,
                   X_Creation_Date,
                   X_Created_By,
                   X_Last_Update_Login
                );
    OPEN C;
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;
  END Insert_Row;


 PROCEDURE Lock_Row(   X_Rowid                          VARCHAR2,
                       X_Plan_Relationship_Id           NUMBER,
                       X_Parent_Plan_Id                 NUMBER,
                       X_Child_Plan_id                  NUMBER,
                       X_Plan_Relationship_Type         NUMBER,
                       X_Data_Entry_Mode                NUMBER,
                       X_Layout_mode                    NUMBER,
                       X_Auto_Row_Count                 NUMBER,
                       X_Default_Parent_Spec            NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER
 )  IS
    CURSOR C IS
        SELECT *
        FROM   QA_PC_PLAN_RELATIONSHIP
        WHERE  rowid = X_Rowid
        FOR UPDATE of plan_relationship_id NOWAIT;
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
               (Recinfo.plan_relationship_id =  X_Plan_Relationship_Id)
           AND (Recinfo.parent_plan_id = X_Parent_Plan_Id)
           AND (Recinfo.child_plan_id = X_Child_Plan_Id)
           AND (Recinfo.plan_relationship_type = X_Plan_Relationship_Type)
           AND (Recinfo.data_entry_mode = X_Data_Entry_Mode)
           AND (Recinfo.layout_mode = X_Layout_Mode)
           AND (Recinfo.auto_row_count = X_Auto_Row_Count)
	   AND (Recinfo.default_parent_spec = X_Default_Parent_Spec)
           AND (Recinfo.last_update_date =  X_Last_Update_Date)
           AND (Recinfo.last_updated_by =  X_Last_Updated_By)
           AND (Recinfo.creation_date =  X_Creation_Date)
           AND (Recinfo.created_by =  X_Created_By)
        ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;

  END Lock_Row;


 PROCEDURE Update_Row( X_Rowid                          VARCHAR2,
                       X_Plan_Relationship_Id           NUMBER,
                       X_Parent_Plan_Id                 NUMBER,
                       X_Child_Plan_id                  NUMBER,
                       X_Plan_Relationship_Type         NUMBER,
                       X_Data_Entry_Mode                NUMBER,
                       X_Layout_mode                    NUMBER,
                       X_Auto_Row_Count                 NUMBER,
                       X_Default_Parent_Spec            NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER
  ) IS
  BEGIN
    UPDATE QA_PC_PLAN_RELATIONSHIP
    SET
      plan_relationship_id         = X_Plan_Relationship_Id,
      parent_plan_id               = X_Parent_Plan_Id,
      child_plan_id                = X_Child_Plan_id,
      plan_relationship_type       = X_Plan_Relationship_Type,
      data_entry_mode              = X_Data_Entry_Mode,
      layout_mode                  = X_Layout_Mode,
      auto_row_count               = X_Auto_Row_Count,
      default_parent_spec          = X_Default_Parent_Spec,
      last_update_date             = X_Last_Update_Date,
      last_updated_by              = X_Last_Updated_By,
      creation_date                = X_Creation_Date,
      created_by                   = X_Created_By,
      last_update_login            = X_Last_Update_Login

    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Update_Row;

  PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
  BEGIN
    DELETE FROM QA_PC_PLAN_RELATIONSHIP
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Row;


END QA_PC_PLAN_REL_PKG;

/
