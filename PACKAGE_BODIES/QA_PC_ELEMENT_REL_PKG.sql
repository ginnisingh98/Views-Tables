--------------------------------------------------------
--  DDL for Package Body QA_PC_ELEMENT_REL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QA_PC_ELEMENT_REL_PKG" as
/* $Header: qapceleb.pls 120.2 2005/12/19 04:05:42 srhariha noship $ */
 PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Element_Relationship_Id        IN OUT NOCOPY NUMBER,
                       X_Plan_Relationship_Id           NUMBER,
                       X_Parent_Char_id                 NUMBER,
                       X_Child_Char_id                  NUMBER,
                       X_Element_Relationship_Type      NUMBER,
                       X_Link_Flag                      NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER
  ) IS
     CURSOR C IS SELECT rowid FROM QA_PC_ELEMENT_RELATIONSHIP
                 WHERE  element_relationship_id = X_Element_Relationship_Id;
     CURSOR C2 IS SELECT qa_pc_element_relationship_s.nextval FROM dual;

   BEGIN
      if (X_Element_Relationship_Id is NULL) then
        OPEN C2;
        FETCH C2 INTO X_Element_Relationship_Id;
        CLOSE C2;
      end if;
      INSERT INTO QA_PC_ELEMENT_RELATIONSHIP(
                  element_relationship_id,
                   plan_relationship_id,
                   parent_char_id,
                   child_char_id,
                   element_relationship_type,
                   link_flag,
                   last_update_date,
                   last_updated_by,
                   creation_date,
                   created_by,
                   last_update_login
                 ) VALUES (
                    X_Element_Relationship_Id,
                    X_Plan_Relationship_Id,
                    X_Parent_Char_id,
                    X_Child_Char_id,
                    X_Element_Relationship_Type,
                    X_Link_Flag,
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
                       X_Element_Relationship_Id        NUMBER,
                       X_Plan_Relationship_Id           NUMBER,
                       X_Parent_Char_id                 NUMBER,
                       X_Child_Char_id                  NUMBER,
                       X_Element_Relationship_Type      NUMBER,
                       X_Link_Flag                      NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER
 )  IS
    CURSOR C IS
        SELECT *
        FROM   QA_PC_ELEMENT_RELATIONSHIP
        WHERE  rowid = X_Rowid
        FOR UPDATE of element_relationship_id NOWAIT;
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
               (Recinfo.element_relationship_id =  X_Element_Relationship_Id)
           AND (Recinfo.plan_relationship_id = X_Plan_Relationship_Id)
           AND (Recinfo.parent_char_id = X_Parent_Char_id)
           AND (Recinfo.child_char_id = X_Child_Char_id)
           AND (Recinfo.element_relationship_type = X_Element_Relationship_Type)
           AND (Recinfo.link_flag = X_Link_Flag)
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

PROCEDURE Update_Row (X_Rowid                           VARCHAR2,
                       X_Element_Relationship_Id        NUMBER,
                       X_Plan_Relationship_Id           NUMBER,
                       X_Parent_Char_id                 NUMBER,
                       X_Child_Char_id                  NUMBER,
                       X_Element_Relationship_Type      NUMBER,
                       X_Link_Flag                      NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER
 ) IS

   BEGIN
    UPDATE QA_PC_ELEMENT_RELATIONSHIP
    SET
        element_relationship_id   = X_Element_Relationship_Id,
        plan_relationship_id      = X_Plan_Relationship_Id,
        parent_char_id            = X_Parent_Char_id,
        child_char_id             = X_Child_Char_id,
        element_relationship_type = X_Element_Relationship_Type,
        link_flag                 = X_Link_Flag,
        last_update_date          = X_Last_Update_Date,
        last_updated_by           = X_Last_Updated_By,
        creation_date             = X_Creation_Date,
        created_by                = X_Created_By,
        last_update_login         = X_Last_Update_Login

      WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Update_Row;

  PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
  BEGIN
    DELETE FROM QA_PC_ELEMENT_RELATIONSHIP
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Row;


END QA_PC_ELEMENT_REL_PKG;

/
