--------------------------------------------------------
--  DDL for Package Body RG_ROW_SEGMENT_SEQUENCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RG_ROW_SEGMENT_SEQUENCES_PKG" AS
/* $Header: rgirssqb.pls 120.3 2005/02/14 23:53:35 ticheng ship $ */
  --
  --
  -- PUBLIC FUNCTIONS
  --
  --

  FUNCTION new_row_segment_sequence_id
                  RETURN        NUMBER
  IS
	new_sequence_number     NUMBER;
  BEGIN
        SELECT rg_row_segment_sequences_s.nextval
        INTO   new_sequence_number
        FROM   dual;

        RETURN(new_sequence_number);
  END new_row_segment_sequence_id;

  FUNCTION check_dup_sequence(cur_row_order_id              IN  NUMBER,
                              cur_row_segment_sequence_id   IN  NUMBER,
                              new_sequence                  IN  NUMBER)
                  RETURN        BOOLEAN
  IS
	rec_returned	NUMBER;
  BEGIN
     SELECT count(*)
     INTO   rec_returned
     FROM   rg_row_segment_sequences
     WHERE  row_order_id = cur_row_order_id
     AND    row_segment_sequence_id <> cur_row_segment_sequence_id
     AND    segment_sequence = new_sequence;

     IF rec_returned > 0 THEN
            RETURN(TRUE);
     ELSE
            RETURN(FALSE);
     END IF;
  END check_dup_sequence;


  FUNCTION check_dup_appl_col_name(cur_row_order_id              IN  NUMBER,
                                   cur_row_segment_sequence_id   IN  NUMBER,
                                   new_application_column_name   IN  VARCHAR2)
                  RETURN        BOOLEAN
  IS
	rec_returned	NUMBER;
  BEGIN
     SELECT count(*)
     INTO   rec_returned
     FROM   rg_row_segment_sequences
     WHERE  row_order_id = cur_row_order_id
     AND    row_segment_sequence_id <> cur_row_segment_sequence_id
     AND    application_column_name = new_application_column_name;

     IF rec_returned > 0 THEN
            RETURN(TRUE);
     ELSE
            RETURN(FALSE);
     END IF;
  END check_dup_appl_col_name;

-- *********************************************************************
-- The following procedures are necessary to handle the base view form.

PROCEDURE insert_row(X_rowid                   IN OUT NOCOPY VARCHAR2,
                     X_application_id                 NUMBER,
                     X_row_order_id                   NUMBER,
                     X_row_segment_sequence_id        NUMBER,
                     X_segment_sequence               NUMBER,
                     X_seg_order_type                 VARCHAR2,
                     X_seg_display_type               VARCHAR2,
                     X_structure_id                   NUMBER,
                     X_application_column_name        VARCHAR2,
                     X_segment_width                  NUMBER,
                     X_creation_date                  DATE,
                     X_created_by                     NUMBER,
                     X_last_update_date               DATE,
                     X_last_updated_by                NUMBER,
                     X_last_update_login              NUMBER,
                     X_context                        VARCHAR2,
                     X_attribute1                     VARCHAR2,
                     X_attribute2                     VARCHAR2,
                     X_attribute3                     VARCHAR2,
                     X_attribute4                     VARCHAR2,
                     X_attribute5                     VARCHAR2,
                     X_attribute6                     VARCHAR2,
                     X_attribute7                     VARCHAR2,
                     X_attribute8                     VARCHAR2,
                     X_attribute9                     VARCHAR2,
                     X_attribute10                    VARCHAR2,
                     X_attribute11                    VARCHAR2,
                     X_attribute12                    VARCHAR2,
                     X_attribute13                    VARCHAR2,
                     X_attribute14                    VARCHAR2,
                     X_attribute15                    VARCHAR2
                     ) IS
  CURSOR C IS SELECT rowid FROM rg_row_segment_sequences
              WHERE row_segment_sequence_id = X_row_segment_sequence_id;
  BEGIN
    INSERT INTO rg_row_segment_sequences
    (application_id            ,
     row_order_id              ,
     row_segment_sequence_id   ,
     segment_sequence          ,
     seg_order_type            ,
     seg_display_type          ,
     structure_id              ,
     application_column_name   ,
     segment_width             ,
     creation_date             ,
     created_by                ,
     last_update_date          ,
     last_updated_by           ,
     last_update_login         ,
     context                   ,
     attribute1                ,
     attribute2                ,
     attribute3                ,
     attribute4                ,
     attribute5                ,
     attribute6                ,
     attribute7                ,
     attribute8                ,
     attribute9                ,
     attribute10               ,
     attribute11               ,
     attribute12               ,
     attribute13               ,
     attribute14               ,
     attribute15               )
     VALUES
    (X_application_id             ,
     X_row_order_id               ,
     X_row_segment_sequence_id    ,
     X_segment_sequence           ,
     X_seg_order_type             ,
     X_seg_display_type           ,
     X_structure_id               ,
     X_application_column_name    ,
     X_segment_width              ,
     X_creation_date              ,
     X_created_by                 ,
     X_last_update_date           ,
     X_last_updated_by            ,
     X_last_update_login          ,
     X_context                    ,
     X_attribute1                 ,
     X_attribute2                 ,
     X_attribute3                 ,
     X_attribute4                 ,
     X_attribute5                 ,
     X_attribute6                 ,
     X_attribute7                 ,
     X_attribute8                 ,
     X_attribute9                 ,
     X_attribute10                ,
     X_attribute11                ,
     X_attribute12                ,
     X_attribute13                ,
     X_attribute14                ,
     X_attribute15                );

  OPEN C;
  FETCH C INTO X_rowid;
  IF (C%NOTFOUND) THEN
    CLOSE C;
    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE C;
END insert_row;

PROCEDURE update_row(X_rowid                   IN OUT NOCOPY VARCHAR2,
                     X_application_id                 NUMBER,
                     X_row_order_id                   NUMBER,
                     X_row_segment_sequence_id        NUMBER,
                     X_segment_sequence               NUMBER,
                     X_seg_order_type                 VARCHAR2,
                     X_seg_display_type	              VARCHAR2,
                     X_structure_id                   NUMBER,
                     X_application_column_name        VARCHAR2,
                     X_segment_width                  NUMBER,
                     X_last_update_date               DATE,
                     X_last_updated_by                NUMBER,
                     X_last_update_login              NUMBER,
                     X_context                        VARCHAR2,
                     X_attribute1                     VARCHAR2,
                     X_attribute2                     VARCHAR2,
                     X_attribute3                     VARCHAR2,
                     X_attribute4                     VARCHAR2,
                     X_attribute5                     VARCHAR2,
                     X_attribute6                     VARCHAR2,
                     X_attribute7                     VARCHAR2,
                     X_attribute8                     VARCHAR2,
                     X_attribute9                     VARCHAR2,
                     X_attribute10                    VARCHAR2,
                     X_attribute11                    VARCHAR2,
                     X_attribute12                    VARCHAR2,
                     X_attribute13                    VARCHAR2,
                     X_attribute14                    VARCHAR2,
                     X_attribute15                    VARCHAR2
                     ) IS
BEGIN
  UPDATE rg_row_segment_sequences
  SET application_id            =  X_application_id             ,
      row_order_id              =  X_row_order_id               ,
      row_segment_sequence_id   =  X_row_segment_sequence_id    ,
      segment_sequence          =  X_segment_sequence           ,
      seg_order_type            =  X_seg_order_type             ,
      seg_display_type          =  X_seg_display_type           ,
      structure_id              =  X_structure_id               ,
      application_column_name   =  X_application_column_name    ,
      segment_width             =  X_segment_width              ,
      last_update_date          =  X_last_update_date           ,
      last_updated_by           =  X_last_updated_by            ,
      last_update_login         =  X_last_update_login          ,
      context                   =  X_context                    ,
      attribute1                =  X_attribute1                 ,
      attribute2                =  X_attribute2                 ,
      attribute3                =  X_attribute3                 ,
      attribute4                =  X_attribute4                 ,
      attribute5                =  X_attribute5                 ,
      attribute6                =  X_attribute6                 ,
      attribute7                =  X_attribute7                 ,
      attribute8                =  X_attribute8                 ,
      attribute9                =  X_attribute9                 ,
      attribute10               =  X_attribute10                ,
      attribute11               =  X_attribute11                ,
      attribute12               =  X_attribute12                ,
      attribute13               =  X_attribute13                ,
      attribute14               =  X_attribute14                ,
      attribute15               =  X_attribute15
  WHERE rowid = X_rowid;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;
END update_row;

PROCEDURE lock_row(X_rowid                     IN OUT NOCOPY VARCHAR2,
                   X_application_id                   NUMBER,
                   X_row_order_id                     NUMBER,
                   X_row_segment_sequence_id          NUMBER,
                   X_segment_sequence                 NUMBER,
                   X_seg_order_type                   VARCHAR2,
                   X_seg_display_type                 VARCHAR2,
                   X_structure_id                     NUMBER,
                   X_application_column_name          VARCHAR2,
                   X_segment_width                    NUMBER,
                   X_context                          VARCHAR2,
                   X_attribute1                       VARCHAR2,
                   X_attribute2                       VARCHAR2,
                   X_attribute3                       VARCHAR2,
                   X_attribute4                       VARCHAR2,
                   X_attribute5                       VARCHAR2,
                   X_attribute6                       VARCHAR2,
                   X_attribute7                       VARCHAR2,
                   X_attribute8                       VARCHAR2,
                   X_attribute9                       VARCHAR2,
                   X_attribute10                      VARCHAR2,
                   X_attribute11                      VARCHAR2,
                   X_attribute12                      VARCHAR2,
                   X_attribute13                      VARCHAR2,
                   X_attribute14                      VARCHAR2,
                   X_attribute15                      VARCHAR2
                   ) IS
  CURSOR C IS
      SELECT *
      FROM   rg_row_segment_sequences
      WHERE  rowid = X_rowid
      FOR UPDATE OF segment_sequence  NOWAIT;
  Recinfo C%ROWTYPE;
BEGIN
  OPEN C;
  FETCH C INTO Recinfo;
  IF (C%NOTFOUND) THEN
    CLOSE C;
    FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  END IF;
  CLOSE C;

  IF (
          (   (Recinfo.application_id = X_application_id)
           OR (    (Recinfo.application_id IS NULL)
               AND (X_application_id IS NULL)))
      AND (   (Recinfo.row_order_id = X_row_order_id)
           OR (    (Recinfo.row_order_id IS NULL)
               AND (X_row_order_id IS NULL)))
      AND (   (Recinfo.row_segment_sequence_id = X_row_segment_sequence_id)
           OR (    (Recinfo.row_segment_sequence_id IS NULL)
               AND (X_row_segment_sequence_id IS NULL)))
      AND (   (Recinfo.segment_sequence = X_segment_sequence)
           OR (    (Recinfo.segment_sequence IS NULL)
               AND (X_segment_sequence IS NULL)))
      AND (   (Recinfo.seg_order_type = X_seg_order_type)
           OR (    (Recinfo.seg_order_type IS NULL)
               AND (X_seg_order_type IS NULL)))
      AND (   (Recinfo.seg_display_type = X_seg_display_type)
           OR (    (Recinfo.seg_display_type IS NULL)
               AND (X_seg_display_type IS NULL)))
      AND (   (Recinfo.structure_id  = X_structure_id )
           OR (    (Recinfo.structure_id  IS NULL)
               AND (X_structure_id  IS NULL)))
      AND (   (Recinfo.application_column_name = X_application_column_name)
           OR (    (Recinfo.application_column_name IS NULL)
               AND (X_application_column_name IS NULL)))
      AND (   (Recinfo.segment_width = X_segment_width)
           OR (    (Recinfo.segment_width IS NULL)
               AND (X_segment_width IS NULL)))
      AND (   (Recinfo.context = X_context)
           OR (    (Recinfo.context IS NULL)
               AND (X_context IS NULL)))
      AND (   (Recinfo.attribute1 = X_attribute1)
           OR (    (Recinfo.attribute1 IS NULL)
               AND (X_attribute1 IS NULL)))
      AND (   (Recinfo.attribute2 = X_attribute2)
           OR (    (Recinfo.attribute2 IS NULL)
               AND (X_attribute2 IS NULL)))
      AND (   (Recinfo.attribute3 = X_attribute3)
           OR (    (Recinfo.attribute3 IS NULL)
               AND (X_attribute3 IS NULL)))
      AND (   (Recinfo.attribute4 = X_attribute4)
           OR (    (Recinfo.attribute4 IS NULL)
               AND (X_attribute4 IS NULL)))
      AND (   (Recinfo.attribute5 = X_attribute5)
           OR (    (Recinfo.attribute5 IS NULL)
               AND (X_attribute5 IS NULL)))
      AND (   (Recinfo.attribute6 = X_attribute6)
           OR (    (Recinfo.attribute6 IS NULL)
               AND (X_attribute6 IS NULL)))
      AND (   (Recinfo.attribute7 = X_attribute7)
           OR (    (Recinfo.attribute7 IS NULL)
               AND (X_attribute7 IS NULL)))
      AND (   (Recinfo.attribute8 = X_attribute8)
           OR (    (Recinfo.attribute8 IS NULL)
               AND (X_attribute8 IS NULL)))
      AND (   (Recinfo.attribute9 = X_attribute9)
           OR (    (Recinfo.attribute9 IS NULL)
               AND (X_attribute9 IS NULL)))
      AND (   (Recinfo.attribute10 = X_attribute10)
           OR (    (Recinfo.attribute10 IS NULL)
               AND (X_attribute10 IS NULL)))
      AND (   (Recinfo.attribute11 = X_attribute11)
           OR (    (Recinfo.attribute11 IS NULL)
               AND (X_attribute11 IS NULL)))
      AND (   (Recinfo.attribute12 = X_attribute12)
           OR (    (Recinfo.attribute12 IS NULL)
               AND (X_attribute12 IS NULL)))
      AND (   (Recinfo.attribute13 = X_attribute13)
           OR (    (Recinfo.attribute13 IS NULL)
               AND (X_attribute13 IS NULL)))
      AND (   (Recinfo.attribute14 = X_attribute14)
           OR (    (Recinfo.attribute4 IS NULL)
               AND (X_attribute14 IS NULL)))
      AND (   (Recinfo.attribute15 = X_attribute15)
           OR (    (Recinfo.attribute15 IS NULL)
               AND (X_attribute15 IS NULL)))
          ) THEN
    RETURN;
  ELSE
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  END IF;
END lock_row;

PROCEDURE delete_row(X_rowid VARCHAR2) IS
BEGIN
  DELETE FROM rg_row_segment_sequences
  WHERE  rowid = X_rowid;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;
END delete_row;

END RG_ROW_SEGMENT_SEQUENCES_PKG;

/
