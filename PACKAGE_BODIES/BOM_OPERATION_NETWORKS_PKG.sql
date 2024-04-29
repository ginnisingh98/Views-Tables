--------------------------------------------------------
--  DDL for Package Body BOM_OPERATION_NETWORKS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_OPERATION_NETWORKS_PKG" as
/* $Header: BOMOPNWB.pls 115.1 99/07/16 05:14:36 porting ship $ */

  PROCEDURE INSERT_ROW(X_ROW_ID IN OUT VARCHAR2,
              x_from_op_seq_id         NUMBER,
              x_to_op_seq_id           NUMBER,
              x_transition_type        NUMBER,
              x_planning_pct           NUMBER,
              x_last_updated_by        NUMBER,
              x_creation_date          DATE,
              x_last_update_date       DATE,
              x_created_by             NUMBER,
              x_last_update_login      NUMBER,
              x_attribute_category     VARCHAR2,
              x_attribute1             VARCHAR2,
              x_attribute2             VARCHAR2,
              x_attribute3             VARCHAR2,
              x_attribute4             VARCHAR2,
              x_attribute5             VARCHAR2,
              x_attribute6             VARCHAR2,
              x_attribute7             VARCHAR2,
              x_attribute8             VARCHAR2,
              x_attribute9             VARCHAR2,
              x_attribute10            VARCHAR2,
              x_attribute11            VARCHAR2,
              x_attribute12            VARCHAR2,
              x_attribute13            VARCHAR2,
              x_attribute14            VARCHAR2,
              x_attribute15            VARCHAR2
         ) IS
  CURSOR C IS SELECT rowid FROM BOM_OPERATION_NETWORKS
              WHERE  FROM_OP_SEQ_ID = X_FROM_OP_SEQ_ID
              AND    TO_OP_SEQ_ID =  X_TO_OP_SEQ_ID;

   BEGIN

   INSERT INTO BOM_OPERATION_NETWORKS(
              from_op_seq_id,
              to_op_seq_id,
              transition_type,
              planning_pct,
              last_updated_by,
              creation_date,
              last_update_date,
              created_by,
              last_update_login,
              attribute_category,
              attribute1,
              attribute2,
              attribute3,
              attribute4,
              attribute5,
              attribute6,
              attribute7,
              attribute8,
              attribute9,
              attribute10,
              attribute11,
              attribute12,
              attribute13,
              attribute14,
              attribute15
             ) VALUES (
              x_from_op_seq_id,
              x_to_op_seq_id  ,
              x_transition_type,
              x_planning_pct   ,
              x_last_updated_by,
              x_creation_date,
              x_last_update_date,
              x_created_by,
              x_last_update_login,
              x_attribute_category,
              x_attribute1,
              x_attribute2,
              x_attribute3,
              x_attribute4,
              x_attribute5,
              x_attribute6,
              x_attribute7,
              x_attribute8,
              x_attribute9,
              x_attribute10,
              x_attribute11,
              x_attribute12,
              x_attribute13,
              x_attribute14,
              x_attribute15
             );
  OPEN C;
  FETCH C INTO x_row_id;
  IF (C%NOTFOUND) THEN
    CLOSE C;
    Raise NO_DATA_FOUND;
  END IF;
  CLOSE C;

  END INSERT_ROW;

PROCEDURE Lock_Row(X_ROW_ID    VARCHAR2,
              x_from_op_seq_id     NUMBER,
              x_to_op_seq_id       NUMBER,
              x_transition_type    NUMBER,
              x_planning_pct       NUMBER,
              x_effectivity_date   DATE,
              x_disable_date       DATE,
              x_last_updated_by    NUMBER,
              x_creation_date      DATE,
              x_last_update_date   DATE,
              x_created_by         NUMBER,
              x_last_update_login  NUMBER,
              x_attribute_category VARCHAR2,
              x_attribute1         VARCHAR2,
              x_attribute2         VARCHAR2,
              x_attribute3         VARCHAR2,
              x_attribute4         VARCHAR2,
              x_attribute5         VARCHAR2,
              x_attribute6         VARCHAR2,
              x_attribute7         VARCHAR2,
              x_attribute8         VARCHAR2,
              x_attribute9         VARCHAR2,
              x_attribute10         VARCHAR2,
              x_attribute11         VARCHAR2,
              x_attribute12         VARCHAR2,
              x_attribute13         VARCHAR2,
              x_attribute14         VARCHAR2,
              x_attribute15         VARCHAR2
         ) IS
  CURSOR C IS SELECT
              from_op_seq_id,
              to_op_seq_id,
              transition_type,
              planning_pct,
              effectivity_date,
              disable_date,
              last_updated_by,
              creation_date,
              last_update_date,
              created_by,
              last_update_login,
              attribute_category,
              attribute1,
              attribute2,
              attribute3,
              attribute4,
              attribute5,
              attribute6,
              attribute7,
              attribute8,
              attribute9,
              attribute10,
              attribute11,
              attribute12,
              attribute13,
              attribute14,
              attribute15
        FROM BOM_OPERATION_NETWORKS
        WHERE rowid = x_row_id
        FOR UPDATE of from_op_seq_id NOWAIT;
  Recinfo C%ROWTYPE;
 BEGIN
      OPEN C;
      FETCH C INTO Recinfo;
      IF (C%NOTFOUND) THEN
        CLOSE C;
        FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
        APP_EXCEPTION.Raise_Exception;
      END IF;
      CLOSE C;
      IF ((Recinfo.from_op_seq_id = x_from_op_seq_id)
           AND (Recinfo.to_op_seq_id = x_to_op_seq_id)
           AND ((Recinfo.attribute_category = x_attribute_category)
                OR ((Recinfo.attribute_category IS NULL)
                    AND (x_attribute_category IS NULL)))
           AND ((Recinfo.attribute1 = x_attribute1)
                OR ((Recinfo.attribute1 IS NULL)
                    AND (x_attribute1 IS NULL)))
           AND ((Recinfo.attribute2 = x_attribute2)
                OR ((Recinfo.attribute2 IS NULL)
                    AND (x_attribute2 IS NULL)))
           AND ((Recinfo.attribute3 = x_attribute3)
                OR ((Recinfo.attribute3 IS NULL)
                    AND (x_attribute3 IS NULL)))
           AND ((Recinfo.attribute4 = x_attribute4)
                OR ((Recinfo.attribute4 IS NULL)
                    AND (x_attribute4 IS NULL)))
           AND ((Recinfo.attribute5 = x_attribute5)
                OR ((Recinfo.attribute5 IS NULL)
                    AND (x_attribute5 IS NULL)))
           AND ((Recinfo.attribute6 = x_attribute6)
                OR ((Recinfo.attribute6 IS NULL)
                    AND (x_attribute6 IS NULL)))
           AND ((Recinfo.attribute7 = x_attribute7)
                OR ((Recinfo.attribute7 IS NULL)
                    AND (x_attribute7 IS NULL)))
           AND ((Recinfo.attribute8 = x_attribute8)
                OR ((Recinfo.attribute8 IS NULL)
                    AND (x_attribute8 IS NULL)))
           AND ((Recinfo.attribute9 = x_attribute9)
                OR ((Recinfo.attribute9 IS NULL)
                    AND (x_attribute9 IS NULL)))
           AND ((Recinfo.attribute10 = x_attribute10)
                OR ((Recinfo.attribute10 IS NULL)
                    AND (x_attribute10 IS NULL)))
           AND ((Recinfo.attribute11 = x_attribute11)
                OR ((Recinfo.attribute11 IS NULL)
                    AND (x_attribute11 IS NULL)))
           AND ((Recinfo.attribute12 = x_attribute12)
                OR ((Recinfo.attribute12 IS NULL)
                    AND (x_attribute12 IS NULL)))
           AND ((Recinfo.attribute13 = x_attribute13)
                OR ((Recinfo.attribute13 IS NULL)
                    AND (x_attribute13 IS NULL)))
           AND ((Recinfo.attribute14 = x_attribute14)
                OR ((Recinfo.attribute14 IS NULL)
                    AND (x_attribute14 IS NULL)))
           AND ((Recinfo.attribute15 = x_attribute15)
                OR ((Recinfo.attribute15 IS NULL)
                    AND (x_Attribute15 IS NULL)))
         ) THEN
          return;
      ELSE
        FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
        APP_EXCEPTION.Raise_Exception;
      END IF;

 END Lock_Row;

PROCEDURE Update_Row(X_ROW_ID    VARCHAR2,
              x_from_op_seq_id     NUMBER,
              x_to_op_seq_id       NUMBER,
              x_transition_type    NUMBER,
              x_planning_pct       NUMBER,
              x_effectivity_date   DATE,
              x_disable_date       DATE,
              x_last_updated_by    NUMBER,
              x_creation_date      DATE,
              x_last_update_date   DATE,
              x_created_by         NUMBER,
              x_last_update_login  NUMBER,
              x_attribute_category VARCHAR2,
              x_attribute1         VARCHAR2,
              x_attribute2         VARCHAR2,
              x_attribute3         VARCHAR2,
              x_attribute4         VARCHAR2,
              x_attribute5         VARCHAR2,
              x_attribute6         VARCHAR2,
              x_attribute7         VARCHAR2,
              x_attribute8         VARCHAR2,
              x_attribute9         VARCHAR2,
              x_attribute10         VARCHAR2,
              x_attribute11         VARCHAR2,
              x_attribute12         VARCHAR2,
              x_attribute13         VARCHAR2,
              x_attribute14         VARCHAR2,
              x_attribute15         VARCHAR2
         ) IS
BEGIN
   UPDATE BOM_OPERATION_NETWORKS SET
    from_op_seq_id                  = x_from_op_seq_id,
    to_op_seq_id                    = x_to_op_seq_id,
    transition_type                 = x_transition_type,
    planning_pct                    = x_planning_pct,
    effectivity_date                = x_effectivity_date,
    created_by                      = x_created_by,
    creation_date                   = x_creation_date,
    disable_date                    = x_disable_date,
    last_update_date                = SYSDATE,
    last_updated_by                 = x_last_updated_by,
    last_update_login               = x_last_update_login,
    attribute_category              = x_attribute_category,
    attribute1                      = x_attribute1,
    attribute2                      = x_attribute2,
    attribute3                      = x_attribute3,
    attribute4                      = x_attribute4,
    attribute5                      = x_attribute5,
    attribute6                      = x_attribute6,
    attribute7                      = x_attribute7,
    attribute8                      = x_attribute8,
    attribute9                      =  x_attribute9,
    attribute10                     =  x_attribute10,
    attribute11                     =  x_attribute11,
    attribute12                     =  x_attribute12,
    attribute13                     =  x_attribute13,
    attribute14                     =  x_attribute14,
    attribute15                     =  x_attribute15
  WHERE rowid = x_row_id;
  IF (SQL%NOTFOUND) THEN
    Raise NO_DATA_FOUND;
  END IF;

END;

PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
BEGIN
 DELETE FROM BOM_OPERATION_NETWORKS
 WHERE rowid=x_rowid;
END Delete_Row;

PROCEDURE CHECK_UNIQUE_LINK(X_ROWID VARCHAR2,
                            X_FROM_OP_SEQ_ID NUMBER,
                            X_TO_OP_SEQ_ID NUMBER) IS
dummy NUMBER;
from_op_seq_num NUMBER;
to_op_seq_num NUMBER;
BEGIN
	SELECT operation_seq_num
	INTO   from_op_seq_num
	FROM   bom_operation_sequences
	WHERE  operation_sequence_id = x_from_op_seq_id;

	SELECT operation_seq_num
	INTO   to_op_seq_num
	FROM   bom_operation_sequences
	WHERE  operation_sequence_id = x_to_op_seq_id;

  SELECT 1 INTO dummy FROM DUAL WHERE NOT EXISTS
    (SELECT 1 FROM BOM_OPERATION_NETWORKS
     WHERE from_op_seq_id = X_From_Op_Seq_Id
     AND   To_Op_Seq_Id = X_To_Op_Seq_Id
     AND  ((X_Rowid IS NULL) OR (ROWID <> X_Rowid))
    );
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      FND_MESSAGE.SET_NAME('BOM','BOM_LINK_ALREADY_EXISTS');
      FND_MESSAGE.SET_TOKEN('FROM_OP_SEQ_ID',to_char(from_op_seq_num), FALSE);
      FND_MESSAGE.SET_TOKEN('TO_OP_SEQ_ID',to_char(to_op_seq_num), FALSE);
      APP_EXCEPTION.RAISE_EXCEPTION;
END;

END BOM_OPERATION_NETWORKS_PKG;

/
