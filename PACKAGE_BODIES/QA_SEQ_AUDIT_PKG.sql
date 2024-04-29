--------------------------------------------------------
--  DDL for Package Body QA_SEQ_AUDIT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QA_SEQ_AUDIT_PKG" as
/* $Header: qaseqadb.pls 115.0 2003/08/26 13:50:31 rponnusa noship $ */

  PROCEDURE Insert_Row(P_Rowid                  IN OUT NOCOPY VARCHAR2,
                       P_Plan_Id                NUMBER,
                       P_Collection_Id          NUMBER,
                       P_Occurrence             NUMBER,
                       P_Char_Id                NUMBER,
                       P_Txn_Header_Id          NUMBER,
                       P_Sequence_Value         VARCHAR2,
                       P_User_Id                NUMBER,
                       P_Source_Code            VARCHAR2,
                       P_Source_Id              NUMBER,
                       P_Audit_Type             VARCHAR2,
                       P_Audit_Date             DATE,
                       P_Last_Update_Date       DATE,
                       P_Last_Updated_By        NUMBER,
                       P_Creation_Date          DATE,
                       P_Created_By             NUMBER,
                       P_Last_Update_Login      NUMBER
                      ) IS

  CURSOR C IS SELECT rowid FROM QA_SEQ_AUDIT_HISTORY
             WHERE char_id = P_Char_Id
             AND   plan_id = P_Plan_Id
             AND   collection_id = P_Collection_Id
             AND   occurrence = P_Occurrence;

  BEGIN
    INSERT INTO QA_SEQ_AUDIT_HISTORY(
                   plan_id,
                   collection_id,
                   occurrence,
                   char_id,
                   txn_header_id,
                   sequence_value,
                   user_id,
                   source_code,
                   source_id,
                   audit_type,
                   audit_date,
                   last_update_date,
                   last_updated_by,
                   creation_date,
                   created_by,
                   last_update_login
   )VALUES(
                   P_Plan_Id,
                   P_Collection_Id,
                   P_Occurrence,
                   P_Char_Id,
                   P_Txn_Header_Id,
                   P_Sequence_Value,
                   P_User_Id,
                   P_Source_Code,
                   P_Source_Id,
                   P_Audit_Type,
                   P_Audit_Date,
                   P_Last_Update_Date,
                   P_Last_Updated_By,
                   P_Creation_Date,
                   P_Created_By,
                   P_Last_Update_Login
    );
   OPEN C;
   FETCH C INTO P_Rowid;

   IF (C%NOTFOUND) THEN
     CLOSE C;
     Raise NO_DATA_FOUND;
   END IF;

   CLOSE C;

  END Insert_Row;

  PROCEDURE Lock_Row  (P_Rowid                  VARCHAR2,
                       P_Plan_Id                NUMBER,
                       P_Collection_Id          NUMBER,
                       P_Occurrence             NUMBER,
                       P_Char_Id                NUMBER,
                       P_Txn_Header_Id          NUMBER,
                       P_Sequence_Value         VARCHAR2,
                       P_User_Id                NUMBER,
                       P_Source_Code            VARCHAR2,
                       P_Source_Id              NUMBER,
                       P_Audit_Type             VARCHAR2,
                       P_Audit_Date             DATE,
                       P_Last_Update_Date       DATE,
                       P_Last_Updated_By        NUMBER,
                       P_Creation_Date          DATE,
                       P_Created_By             NUMBER,
                       P_Last_Update_Login      NUMBER
                      ) IS

    CURSOR C IS
        SELECT *
        FROM   QA_SEQ_AUDIT_HISTORY
        WHERE  rowid = P_Rowid
        FOR UPDATE of char_id NOWAIT;

    Recinfo C%ROWTYPE;

  BEGIN
    OPEN C;
    FETCH C INTO Recinfo;

    IF (C%NOTFOUND) then
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    END IF;

    CLOSE C;

    IF (
               (Recinfo.plan_id          = P_Plan_Id)
           AND (Recinfo.collection_id    = P_Collection_Id)
           AND (Recinfo.occurrence       = P_Occurrence)
           AND (Recinfo.char_id          = P_Char_Id)
           AND (Recinfo.txn_header_id    = P_Txn_Header_Id
                  OR (Recinfo.txn_header_id IS NULL
                     AND P_Txn_Header_Id IS NULL))
           AND (Recinfo.sequence_value   = P_Sequence_Value)
           AND (Recinfo.user_id          = P_User_Id)
           AND (Recinfo.source_code      = P_Source_Code
                  OR (Recinfo.source_code IS NULL
                      AND P_Source_Code IS NULL))
           AND (Recinfo.source_id        = P_Source_Id
                  OR (Recinfo.source_id IS NULL
                      AND P_Source_Id IS NULL))
           AND (Recinfo.audit_type       = P_Audit_Type)
           AND (Recinfo.audit_date       = P_Audit_Date)
           AND (Recinfo.last_update_date = P_Last_Update_Date)
           AND (Recinfo.last_updated_by  = P_Last_Updated_By)
           AND (Recinfo.creation_date    = P_Creation_Date)
           AND (Recinfo.created_by       = P_Created_By)
        ) THEN
      return;
    ELSE
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    END IF;

  END Lock_Row;

  PROCEDURE Update_Row(P_Rowid                  VARCHAR2,
                       P_Plan_Id                NUMBER,
                       P_Collection_Id          NUMBER,
                       P_Occurrence             NUMBER,
                       P_Char_Id                NUMBER,
                       P_Txn_Header_Id          NUMBER,
                       P_Sequence_Value         VARCHAR2,
                       P_User_Id                NUMBER,
                       P_Source_Code            VARCHAR2,
                       P_Source_Id              NUMBER,
                       P_Audit_Type             VARCHAR2,
                       P_Audit_Date             DATE,
                       P_Last_Update_Date       DATE,
                       P_Last_Updated_By        NUMBER,
                       P_Creation_Date          DATE,
                       P_Created_By             NUMBER,
                       P_Last_Update_Login      NUMBER
                      )IS
  BEGIN
    UPDATE QA_SEQ_AUDIT_HISTORY
    SET
         plan_id                      = P_Plan_Id,
         collection_id                = P_Collection_Id,
         occurrence                   = P_Occurrence,
         char_id                      = P_Char_Id,
         txn_header_id                = P_Txn_Header_Id,
         sequence_value               = P_Sequence_Value,
         user_id                      = P_User_Id,
         source_code                  = P_Source_Code,
         source_id                    = P_Source_Id,
         audit_type                   = P_Audit_Type,
         audit_date                   = P_Audit_Date,
         last_update_date             = P_Last_Update_Date,
         last_updated_by              = P_Last_Updated_By,
         creation_date                = P_Creation_Date,
         created_by                   = P_Created_By,
         last_update_login            = P_Last_Update_Login
    WHERE rowid = P_Rowid;

    IF (SQL%NOTFOUND) THEN
      Raise NO_DATA_FOUND;
    END IF;

  END Update_Row;

  PROCEDURE Delete_Row(P_Rowid VARCHAR2) IS
  BEGIN
    DELETE FROM QA_SEQ_AUDIT_HISTORY
    WHERE rowid = P_Rowid;

    IF (SQL%NOTFOUND) THEN
      Raise NO_DATA_FOUND;
    END IF;

  END Delete_Row;

END QA_SEQ_AUDIT_PKG;

/
