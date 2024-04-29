--------------------------------------------------------
--  DDL for Package Body RG_REPORT_DISPLAYS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RG_REPORT_DISPLAYS_PKG" AS
/*  $Header: rgirdspb.pls 120.2 2002/11/14 03:01:21 djogg ship $  */
  --
  -- PUBLIC FUNCTIONS
  --

  PROCEDURE check_unique( X_rowid VARCHAR2,
                          X_report_display_set_id NUMBER,
                          X_sequence  NUMBER ) IS
    dummy    NUMBER;
  BEGIN
    select 1 into dummy from dual
    where not exists
      (select 1 from rg_report_displays
       where report_display_set_id = nvl(X_report_display_set_id,-1)
         and sequence = X_sequence
         and ((X_rowid IS NULL) OR (rowid <> X_rowid)));
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        fnd_message.set_name('RG','RG_FORMS_DUP_OBJECT_SEQUENCES');
        fnd_message.set_token('OBJECT','RG_REPORT_DISPLAY_SET',TRUE);
        app_exception.raise_exception;
  END check_unique;

  FUNCTION get_unique_id RETURN NUMBER IS
    next_id NUMBER;
  BEGIN
    select rg_report_displays_s.nextval
    into next_id
    from dual;

    RETURN (next_id);
  END get_unique_id;


PROCEDURE insert_row(X_rowid                         IN OUT NOCOPY VARCHAR2,
                     X_report_display_id                    NUMBER,
                     X_report_display_set_id                NUMBER,
                     X_sequence                             NUMBER,
                     X_display_flag                         VARCHAR2,
                     X_row_group_id                         NUMBER,
                     X_column_group_id                      NUMBER,
                     X_description                          VARCHAR2,
                     X_creation_date                        DATE,
                     X_created_by                           NUMBER,
                     X_last_update_date                     DATE,
                     X_last_updated_by                      NUMBER,
                     X_last_update_login                    NUMBER,
                     X_context                              VARCHAR2,
                     X_attribute1                           VARCHAR2,
                     X_attribute2                           VARCHAR2,
                     X_attribute3                           VARCHAR2,
                     X_attribute4                           VARCHAR2,
                     X_attribute5                           VARCHAR2,
                     X_attribute6                           VARCHAR2,
                     X_attribute7                           VARCHAR2,
                     X_attribute8                           VARCHAR2,
                     X_attribute9                           VARCHAR2,
                     X_attribute10                          VARCHAR2,
                     X_attribute11                          VARCHAR2,
                     X_attribute12                          VARCHAR2,
                     X_attribute13                          VARCHAR2,
                     X_attribute14                          VARCHAR2,
                     X_attribute15                          VARCHAR2) IS
  CURSOR C IS SELECT rowid FROM rg_report_displays
              WHERE report_display_id = X_report_display_id;
  BEGIN
    INSERT INTO RG_REPORT_DISPLAYS
    (report_display_id             ,
     report_display_set_id         ,
     sequence                      ,
     display_flag                  ,
     row_group_id                  ,
     column_group_id               ,
     description                   ,
     creation_date                 ,
     created_by                    ,
     last_update_date              ,
     last_updated_by               ,
     last_update_login             ,
     context                       ,
     attribute1                    ,
     attribute2                    ,
     attribute3                    ,
     attribute4                    ,
     attribute5                    ,
     attribute6                    ,
     attribute7                    ,
     attribute8                    ,
     attribute9                    ,
     attribute10                   ,
     attribute11                   ,
     attribute12                   ,
     attribute13                   ,
     attribute14                   ,
     attribute15                   )
     VALUES
    (X_report_display_id             ,
     X_report_display_set_id         ,
     X_sequence                      ,
     X_display_flag                  ,
     X_row_group_id                  ,
     X_column_group_id               ,
     X_description                   ,
     X_creation_date                 ,
     X_created_by                    ,
     X_last_update_date              ,
     X_last_updated_by               ,
     X_last_update_login             ,
     X_context                       ,
     X_attribute1                    ,
     X_attribute2                    ,
     X_attribute3                    ,
     X_attribute4                    ,
     X_attribute5                    ,
     X_attribute6                    ,
     X_attribute7                    ,
     X_attribute8                    ,
     X_attribute9                    ,
     X_attribute10                   ,
     X_attribute11                   ,
     X_attribute12                   ,
     X_attribute13                   ,
     X_attribute14                   ,
     X_attribute15                   );

  OPEN C;
  FETCH C INTO X_rowid;
  IF (C%NOTFOUND) THEN
    CLOSE C;
    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE C;
END insert_row;

PROCEDURE update_row(X_rowid                         IN OUT NOCOPY VARCHAR2,
                     X_report_display_id                    NUMBER,
                     X_report_display_set_id                NUMBER,
                     X_sequence                             NUMBER,
                     X_display_flag                         VARCHAR2,
                     X_row_group_id                         NUMBER,
                     X_column_group_id                      NUMBER,
                     X_description                          VARCHAR2,
                     X_last_update_date                     DATE,
                     X_last_updated_by                      NUMBER,
                     X_last_update_login                    NUMBER,
                     X_context                              VARCHAR2,
                     X_attribute1                           VARCHAR2,
                     X_attribute2                           VARCHAR2,
                     X_attribute3                           VARCHAR2,
                     X_attribute4                           VARCHAR2,
                     X_attribute5                           VARCHAR2,
                     X_attribute6                           VARCHAR2,
                     X_attribute7                           VARCHAR2,
                     X_attribute8                           VARCHAR2,
                     X_attribute9                           VARCHAR2,
                     X_attribute10                          VARCHAR2,
                     X_attribute11                          VARCHAR2,
                     X_attribute12                          VARCHAR2,
                     X_attribute13                          VARCHAR2,
                     X_attribute14                          VARCHAR2,
                     X_attribute15                          VARCHAR2) IS
BEGIN
  UPDATE RG_REPORT_DISPLAYS
  SET report_display_id        =   X_report_display_id           ,
      report_display_set_id    =   X_report_display_set_id       ,
      sequence                 =   X_sequence                    ,
      display_flag             =   X_display_flag                ,
      row_group_id             =   X_row_group_id                ,
      column_group_id          =   X_column_group_id             ,
      description              =   X_description                 ,
      last_update_date         =   X_last_update_date            ,
      last_updated_by          =   X_last_updated_by             ,
      last_update_login        =   X_last_update_login           ,
      context                  =   X_context                     ,
      attribute1               =   X_attribute1                  ,
      attribute2               =   X_attribute2                  ,
      attribute3               =   X_attribute3                  ,
      attribute4               =   X_attribute4                  ,
      attribute5               =   X_attribute5                  ,
      attribute6               =   X_attribute6                  ,
      attribute7               =   X_attribute7                  ,
      attribute8               =   X_attribute8                  ,
      attribute9               =   X_attribute9                  ,
      attribute10              =   X_attribute10                 ,
      attribute11              =   X_attribute11                 ,
      attribute12              =   X_attribute12                 ,
      attribute13              =   X_attribute13                 ,
      attribute14              =   X_attribute14                 ,
      attribute15              =   X_attribute15
  WHERE rowid = X_rowid;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;
END update_row;

PROCEDURE lock_row(X_rowid                         IN OUT NOCOPY VARCHAR2,
                   X_report_display_id                    NUMBER,
                   X_report_display_set_id                NUMBER,
                   X_sequence                             NUMBER,
                   X_display_flag                         VARCHAR2,
                   X_row_group_id                         NUMBER,
                   X_column_group_id                      NUMBER,
                   X_description                          VARCHAR2,
                   X_context                              VARCHAR2,
                   X_attribute1                           VARCHAR2,
                   X_attribute2                           VARCHAR2,
                   X_attribute3                           VARCHAR2,
                   X_attribute4                           VARCHAR2,
                   X_attribute5                           VARCHAR2,
                   X_attribute6                           VARCHAR2,
                   X_attribute7                           VARCHAR2,
                   X_attribute8                           VARCHAR2,
                   X_attribute9                           VARCHAR2,
                   X_attribute10                          VARCHAR2,
                   X_attribute11                          VARCHAR2,
                   X_attribute12                          VARCHAR2,
                   X_attribute13                          VARCHAR2,
                   X_attribute14                          VARCHAR2,
                   X_attribute15                          VARCHAR2) IS
  CURSOR C IS
      SELECT *
      FROM   rg_report_displays
      WHERE  rowid = X_rowid
      FOR UPDATE OF sequence       NOWAIT;
  Recinfo C%ROWTYPE;
BEGIN
  OPEN C;
  FETCH C INTO Recinfo;
  IF (C%NOTFOUND) THEN
    CLOSE C;
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  END IF;
  CLOSE C;

  IF (
          (   (Recinfo.report_display_id = X_report_display_id)
           OR (    (Recinfo.report_display_id IS NULL)
               AND (X_report_display_id IS NULL)))
      AND (   (Recinfo.report_display_set_id = X_report_display_set_id)
           OR (    (Recinfo.report_display_set_id IS NULL)
               AND (X_report_display_set_id IS NULL)))
      AND (   (Recinfo.sequence = X_sequence)
           OR (    (Recinfo.sequence IS NULL)
               AND (X_sequence IS NULL)))
      AND (   (Recinfo.display_flag = X_display_flag)
           OR (    (Recinfo.display_flag IS NULL)
               AND (X_display_flag IS NULL)))
      AND (   (Recinfo.row_group_id = X_row_group_id)
           OR (    (Recinfo.row_group_id IS NULL)
               AND (X_row_group_id IS NULL)))
      AND (   (Recinfo.column_group_id = X_column_group_id)
           OR (    (Recinfo.column_group_id IS NULL)
               AND (X_column_group_id IS NULL)))
      AND (   (Recinfo.description = X_description)
           OR (    (Recinfo.description IS NULL)
               AND (X_description IS NULL)))
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
  DELETE FROM rg_report_displays
  WHERE  rowid = X_rowid;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;
END delete_row;

END RG_REPORT_DISPLAYS_PKG;

/
