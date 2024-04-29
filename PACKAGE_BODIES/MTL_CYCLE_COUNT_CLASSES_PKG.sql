--------------------------------------------------------
--  DDL for Package Body MTL_CYCLE_COUNT_CLASSES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MTL_CYCLE_COUNT_CLASSES_PKG" as
/* $Header: INVADC3B.pls 120.1 2005/06/19 05:07:35 appldev  $ */
--Added NOCOPY hint to X_Rowid IN OUT parameter to comply with
--GSCC standard File.Sql.39. BUg:4410902
  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Abc_Class_Id                          NUMBER,
                       X_Cycle_Count_Header_Id                 NUMBER,
                       X_Organization_Id                       NUMBER,
                       X_Last_Update_Date                      DATE,
                       X_Last_Updated_By                       NUMBER,
                       X_Creation_Date                         DATE,
                       X_Created_By                            NUMBER,
                       X_Last_Update_Login                     NUMBER,
                       X_Num_Counts_Per_Year                   NUMBER,
                       X_Approval_Tolerance_Positive           NUMBER,
                       X_Approval_Tolerance_Negative           NUMBER,
                       X_Cost_Tolerance_Positive               NUMBER,
                       X_Cost_Tolerance_Negative               NUMBER,
                       X_Hit_Miss_Tolerance_Positive           NUMBER,
                       X_Hit_Miss_Tolerance_Negative           NUMBER,
                       X_Abc_Assignment_Group_Id               NUMBER
  ) IS
    CURSOR C IS SELECT rowid FROM mtl_cycle_count_classes
                 WHERE (   (cycle_count_header_id = X_Cycle_Count_Header_Id)
                        or (cycle_count_header_id is NULL and X_Cycle_Count_Header_Id is NULL));

   BEGIN

       INSERT INTO mtl_cycle_count_classes(
              abc_class_id,
              cycle_count_header_id,
              organization_id,
              last_update_date,
              last_updated_by,
              creation_date,
              created_by,
              last_update_login,
              num_counts_per_year,
              approval_tolerance_positive,
              approval_tolerance_negative,
              cost_tolerance_positive,
              cost_tolerance_negative,
              hit_miss_tolerance_positive,
              hit_miss_tolerance_negative,
              abc_assignment_group_id
             ) VALUES (
              X_Abc_Class_Id,
              X_Cycle_Count_Header_Id,
              X_Organization_Id,
              X_Last_Update_Date,
              X_Last_Updated_By,
              X_Creation_Date,
              X_Created_By,
              X_Last_Update_Login,
              X_Num_Counts_Per_Year,
              X_Approval_Tolerance_Positive,
              X_Approval_Tolerance_Negative,
              X_Cost_Tolerance_Positive,
              X_Cost_Tolerance_Negative,
              X_Hit_Miss_Tolerance_Positive,
              X_Hit_Miss_Tolerance_Negative,
              X_Abc_Assignment_Group_Id
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
                     X_Abc_Class_Id                     NUMBER,
                     X_Cycle_Count_Header_Id            NUMBER,
                     X_Organization_Id                  NUMBER,
                     X_Num_Counts_Per_Year              NUMBER,
                     X_Approval_Tolerance_Positive      NUMBER,
                     X_Approval_Tolerance_Negative      NUMBER,
                     X_Cost_Tolerance_Positive          NUMBER,
                     X_Cost_Tolerance_Negative          NUMBER,
                     X_Hit_Miss_Tolerance_Positive      NUMBER,
                     X_Hit_Miss_Tolerance_Negative      NUMBER,
                     X_Abc_Assignment_Group_Id          NUMBER
  ) IS
    CURSOR C IS
        SELECT *
        FROM   mtl_cycle_count_classes
        WHERE  rowid = X_Rowid
        FOR UPDATE of Cycle_Count_Header_Id NOWAIT;
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
               (Recinfo.abc_class_id =  X_Abc_Class_Id)
           AND (   (Recinfo.cycle_count_header_id =  X_Cycle_Count_Header_Id)
                OR (    (Recinfo.cycle_count_header_id IS NULL)
                    AND (X_Cycle_Count_Header_Id IS NULL)))
           AND (Recinfo.organization_id =  X_Organization_Id)
           AND (   (Recinfo.num_counts_per_year =  X_Num_Counts_Per_Year)
                OR (    (Recinfo.num_counts_per_year IS NULL)
                    AND (X_Num_Counts_Per_Year IS NULL)))
           AND (   (Recinfo.approval_tolerance_positive =  X_Approval_Tolerance_Positive)
                OR (    (Recinfo.approval_tolerance_positive IS NULL)
                    AND (X_Approval_Tolerance_Positive IS NULL)))
           AND (   (Recinfo.approval_tolerance_negative =  X_Approval_Tolerance_Negative)
                OR (    (Recinfo.approval_tolerance_negative IS NULL)
                    AND (X_Approval_Tolerance_Negative IS NULL)))
           AND (   (Recinfo.cost_tolerance_positive =  X_Cost_Tolerance_Positive)
                OR (    (Recinfo.cost_tolerance_positive IS NULL)
                    AND (X_Cost_Tolerance_Positive IS NULL)))
           AND (   (Recinfo.cost_tolerance_negative =  X_Cost_Tolerance_Negative)
                OR (    (Recinfo.cost_tolerance_negative IS NULL)
                    AND (X_Cost_Tolerance_Negative IS NULL)))
           AND (   (Recinfo.hit_miss_tolerance_positive =  X_Hit_Miss_Tolerance_Positive)
                OR (    (Recinfo.hit_miss_tolerance_positive IS NULL)
                    AND (X_Hit_Miss_Tolerance_Positive IS NULL)))
           AND (   (Recinfo.hit_miss_tolerance_negative =  X_Hit_Miss_Tolerance_Negative)
                OR (    (Recinfo.hit_miss_tolerance_negative IS NULL)
                    AND (X_Hit_Miss_Tolerance_Negative IS NULL)))
           AND (   (Recinfo.abc_assignment_group_id =  X_Abc_Assignment_Group_Id)
                OR (    (Recinfo.abc_assignment_group_id IS NULL)
                    AND (X_Abc_Assignment_Group_Id IS NULL)))
      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_Row;


  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Abc_Class_Id                   NUMBER,
                       X_Cycle_Count_Header_Id          NUMBER,
                       X_Organization_Id                NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Num_Counts_Per_Year            NUMBER,
                       X_Approval_Tolerance_Positive    NUMBER,
                       X_Approval_Tolerance_Negative    NUMBER,
                       X_Cost_Tolerance_Positive        NUMBER,
                       X_Cost_Tolerance_Negative        NUMBER,
                       X_Hit_Miss_Tolerance_Positive    NUMBER,
                       X_Hit_Miss_Tolerance_Negative    NUMBER,
                       X_Abc_Assignment_Group_Id        NUMBER
  ) IS
  BEGIN
    UPDATE mtl_cycle_count_classes
    SET
       abc_class_id                    =     X_Abc_Class_Id,
       cycle_count_header_id           =     X_Cycle_Count_Header_Id,
       organization_id                 =     X_Organization_Id,
       last_update_date                =     X_Last_Update_Date,
       last_updated_by                 =     X_Last_Updated_By,
       last_update_login               =     X_Last_Update_Login,
       num_counts_per_year             =     X_Num_Counts_Per_Year,
       approval_tolerance_positive     =     X_Approval_Tolerance_Positive,
       approval_tolerance_negative     =     X_Approval_Tolerance_Negative,
       cost_tolerance_positive         =     X_Cost_Tolerance_Positive,
       cost_tolerance_negative         =     X_Cost_Tolerance_Negative,
       hit_miss_tolerance_positive     =     X_Hit_Miss_Tolerance_Positive,
       hit_miss_tolerance_negative     =     X_Hit_Miss_Tolerance_Negative,
       abc_assignment_group_id         =     X_Abc_Assignment_Group_Id
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Update_Row;
  PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
  BEGIN
    DELETE FROM mtl_cycle_count_classes
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Row;


END MTL_CYCLE_COUNT_CLASSES_PKG;

/
