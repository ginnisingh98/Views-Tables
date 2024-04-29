--------------------------------------------------------
--  DDL for Package Body RG_REPORT_DISPLAY_GROUPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RG_REPORT_DISPLAY_GROUPS_PKG" AS
/*  $Header: rgirdpgb.pls 120.2 2002/11/14 03:00:51 djogg ship $  */
  --
  -- PUBLIC FUNCTIONS
  --

  PROCEDURE check_unique( X_rowid VARCHAR2,
                          X_name  VARCHAR2 ) IS
    dummy    NUMBER;
  BEGIN
    select 1 into dummy from dual
    where not exists
      (select 1 from rg_report_display_groups
       where name = X_name
         and ((X_rowid IS NULL) OR (rowid <> X_rowid)));
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        fnd_message.set_name('RG','RG_FORMS_OBJECT_EXISTS');
        fnd_message.set_token('OBJECT','RG_DISPLAY_GROUP',TRUE);
        app_exception.raise_exception;
  END check_unique;

  PROCEDURE check_references(X_report_display_group_id NUMBER) IS
    dummy NUMBER;
  BEGIN
    select 1 into dummy from dual
    where not exists
      (select 1 from rg_report_displays
       where row_group_id = X_report_display_group_id
          or column_group_id = X_report_display_group_id);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        fnd_message.set_name('RG','RG_FORMS_REF_OBJECT');
        fnd_message.set_token('OBJECT','RG_DISPLAY_GROUP',TRUE);
        app_exception.raise_exception;
  END check_references;

  FUNCTION get_unique_id RETURN NUMBER IS
    next_id NUMBER;
  BEGIN
    select rg_report_display_groups_s.nextval
    into next_id
    from dual;

    RETURN (next_id);
  END get_unique_id;


PROCEDURE insert_row(X_rowid                         IN OUT NOCOPY VARCHAR2,
                     X_report_display_group_id              NUMBER,
                     X_name                                 VARCHAR2,
                     X_description                          VARCHAR2,
                     X_row_set_id                           NUMBER,
                     X_column_set_id                        NUMBER,
                     X_from_sequence                        NUMBER,
                     X_to_sequence                          NUMBER,
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
  CURSOR C IS SELECT rowid FROM rg_report_display_groups
              WHERE report_display_group_id = X_report_display_group_id;
  BEGIN
    INSERT INTO rg_report_display_groups
    (report_display_group_id       ,
     name                          ,
     description                   ,
     row_set_id                    ,
     column_set_id                 ,
     from_sequence                 ,
     to_sequence                   ,
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
    (X_report_display_group_id         ,
     X_name                          ,
     X_description                   ,
     X_row_set_id                    ,
     X_column_set_id                 ,
     X_from_sequence                 ,
     X_to_sequence                   ,
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

PROCEDURE lock_row(X_rowid                         IN OUT NOCOPY VARCHAR2,
                   X_report_display_group_id              NUMBER,
                   X_name                                 VARCHAR2,
                   X_description                          VARCHAR2,
                   X_row_set_id                           NUMBER,
                   X_column_set_id                        NUMBER,
                   X_from_sequence                        NUMBER,
                   X_to_sequence                          NUMBER,
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
      FROM   rg_report_display_groups
      WHERE  rowid = X_rowid
      FOR UPDATE OF name       NOWAIT;
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
          (   (Recinfo.report_display_group_id = X_report_display_group_id)
           OR (    (Recinfo.report_display_group_id IS NULL)
               AND (X_report_display_group_id IS NULL)))
      AND (   (Recinfo.name = X_name)
           OR (    (Recinfo.name IS NULL)
               AND (X_name IS NULL)))
      AND (   (Recinfo.description = X_description)
           OR (    (Recinfo.description IS NULL)
               AND (X_description IS NULL)))
      AND (   (Recinfo.row_set_id = X_row_set_id)
           OR (    (Recinfo.row_set_id IS NULL)
               AND (X_row_set_id IS NULL)))
      AND (   (Recinfo.column_set_id = X_column_set_id)
           OR (    (Recinfo.column_set_id IS NULL)
               AND (X_column_set_id IS NULL)))
      AND (   (Recinfo.from_sequence = X_from_sequence)
           OR (    (Recinfo.from_sequence IS NULL)
               AND (X_from_sequence IS NULL)))
      AND (   (Recinfo.to_sequence = X_to_sequence)
           OR (    (Recinfo.to_sequence IS NULL)
               AND (X_to_sequence IS NULL)))
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

PROCEDURE update_row(X_rowid                         IN OUT NOCOPY VARCHAR2,
                     X_report_display_group_id              NUMBER,
                     X_name                                 VARCHAR2,
                     X_description                          VARCHAR2,
                     X_row_set_id                           NUMBER,
                     X_column_set_id                        NUMBER,
                     X_from_sequence                        NUMBER,
                     X_to_sequence                          NUMBER,
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
  UPDATE rg_report_display_groups
  SET report_display_group_id    =   X_report_display_group_id       ,
      name                     =   X_name                        ,
      description              =   X_description                 ,
      row_set_id               =   X_row_set_id                  ,
      column_set_id            =   X_column_set_id               ,
      from_sequence            =   X_from_sequence               ,
      to_sequence              =   X_to_sequence                 ,
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

PROCEDURE delete_row(X_rowid VARCHAR2) IS
BEGIN
  DELETE FROM rg_report_display_groups
  WHERE  rowid = X_rowid;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;
END delete_row;

END RG_REPORT_DISPLAY_GROUPS_PKG;

/
