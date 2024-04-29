--------------------------------------------------------
--  DDL for Package Body RG_REPORT_DISPLAY_SETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RG_REPORT_DISPLAY_SETS_PKG" AS
/*  $Header: rgirdpsb.pls 120.2 2002/11/14 03:01:06 djogg ship $  */
  --
  -- PUBLIC FUNCTIONS
  --

  PROCEDURE check_unique( X_rowid VARCHAR2,
                          X_name  VARCHAR2 ) IS
    dummy    NUMBER;
  BEGIN
    select 1 into dummy from dual
    where not exists
      (select 1 from rg_report_display_sets
       where name = X_name
         and ((X_rowid IS NULL) OR (rowid <> X_rowid)));
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        fnd_message.set_name('RG','RG_FORMS_OBJECT_EXISTS');
        fnd_message.set_token('OBJECT','RG_REPORT_DISPLAY_SET',TRUE);
        app_exception.raise_exception;
  END check_unique;

  PROCEDURE check_references(X_report_display_set_id NUMBER) IS
    dummy NUMBER;
  BEGIN
    select 1 into dummy from dual
    where not exists
      (select 1 from rg_reports
       where report_display_set_id = X_report_display_set_id);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        fnd_message.set_name('RG','RG_FORMS_REF_OBJECT');
        fnd_message.set_token('OBJECT','RG_REPORT_DISPLAY_SET', TRUE);
        app_exception.raise_exception;
  END check_references;

  FUNCTION check_display_exists(X_report_display_set_id NUMBER)
  RETURN BOOLEAN IS
    dummy NUMBER;
  BEGIN
    select 1 into dummy from dual
    where not exists
      (select 1
       from rg_report_displays
       where report_display_set_id = X_report_display_set_id);
    RETURN (FALSE);

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN (TRUE);
  END check_display_exists;

  FUNCTION check_displays_row_set(X_rowid VARCHAR2,
                                  X_report_display_set_id NUMBER,
                                  X_row_set_id_saved NUMBER)
  RETURN BOOLEAN IS
    dummy NUMBER;
  BEGIN
--  check whether at least one of the display options of this display
--  set uses a row group which references the same row set as this
--  display set does.
    select 1 into dummy from dual
    where not exists
     (select 1
      from rg_report_displays       dpo,
           rg_report_display_groups dpg
      where dpo.row_group_id = dpg.report_display_group_id
        and dpo.report_display_set_id = X_report_display_set_id
        and dpg.row_set_id = nvl(X_row_set_id_saved,-1)
        and X_rowid IS NOT NULL);
    RETURN (FALSE);

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN (TRUE);
  END check_displays_row_set;

  FUNCTION check_reports_row_set(X_rowid VARCHAR2,
                                  X_report_display_set_id NUMBER,
                                  X_row_set_id NUMBER,
                                  X_row_set_id_saved NUMBER)
  RETURN BOOLEAN IS
    dummy NUMBER;
  BEGIN
--  check if there is any report that uses this display set uses
--  the old row set and if any report that references a row set
--  other than the new row set
--
    select 1 into dummy from dual
    where not exists
     (select 1
      from rg_reports
      where report_display_set_id = X_report_display_set_id
        and row_set_id = nvl(X_row_set_id_saved,row_set_id)
        and row_set_id <> nvl(X_row_set_id,row_set_id)
        and X_rowid IS NOT NULL);
    RETURN (FALSE);

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
          RETURN (TRUE);
  END check_reports_row_set;

  FUNCTION check_displays_column_set(X_rowid VARCHAR2,
                                    X_report_display_set_id NUMBER,
                                    X_column_set_id_saved NUMBER)
  RETURN BOOLEAN IS
    dummy NUMBER;
  BEGIN
--  check whether at least one of the display options of this display
--  set uses a column group which references the same column set as this
--  display set does.  If so, column set
--  update is not allowed
--
    select 1 into dummy from dual
    where not exists
     (select 1
      from rg_report_displays       dpo,
           rg_report_display_groups dpg
      where dpo.column_group_id = dpg.report_display_group_id
        and dpo.report_display_set_id = X_report_display_set_id
        and dpg.column_set_id = nvl(X_column_set_id_saved,-1)
        and X_rowid IS NOT NULL);
      RETURN (FALSE);

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN (TRUE);
  END check_displays_column_set;


  FUNCTION check_reports_column_set(X_rowid VARCHAR2,
                                    X_report_display_set_id NUMBER,
                                    X_column_set_id NUMBER,
                                    X_column_set_id_saved NUMBER)
  RETURN BOOLEAN IS
    dummy NUMBER;
  BEGIN
--  check if there is any report that uses this display set uses
--  the old column set and if any report that references a column set
--  other than the new column set.  If so,
--  column set update is not allowed
--
    select 1 into dummy from dual
    where not exists
     (select 1
      from rg_reports
      where report_display_set_id = X_report_display_set_id
        and column_set_id = nvl(X_column_set_id_saved,column_set_id)
        and column_set_id <> nvl(X_column_set_id,column_set_id)
        and X_rowid IS NOT NULL);
    RETURN (FALSE);

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN (TRUE);
  END check_reports_column_set;

  FUNCTION get_unique_id RETURN NUMBER IS
    next_id NUMBER;
  BEGIN
    select rg_report_display_sets_s.nextval
    into next_id
    from dual;

    RETURN (next_id);
  END get_unique_id;


PROCEDURE insert_row(X_rowid                         IN OUT NOCOPY VARCHAR2,
                     X_report_display_set_id                NUMBER,
                     X_name                                 VARCHAR2,
                     X_description                          VARCHAR2,
                     X_row_set_id                           NUMBER,
                     X_column_set_id                        NUMBER,
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
  CURSOR C IS SELECT rowid FROM rg_report_display_sets
              WHERE report_display_set_id = X_report_display_set_id;
  BEGIN
    INSERT INTO rg_report_display_sets
    (report_display_set_id         ,
     name                          ,
     description                   ,
     row_set_id                    ,
     column_set_id                 ,
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
    (X_report_display_set_id         ,
     X_name                          ,
     X_description                   ,
     X_row_set_id                    ,
     X_column_set_id                 ,
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
                   X_report_display_set_id                NUMBER,
                   X_name                                 VARCHAR2,
                   X_description                          VARCHAR2,
                   X_row_set_id                           NUMBER,
                   X_column_set_id                        NUMBER,
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
      FROM   rg_report_display_sets
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
          (   (Recinfo.report_display_set_id = X_report_display_set_id)
           OR (    (Recinfo.report_display_set_id IS NULL)
               AND (X_report_display_set_id IS NULL)))
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
                     X_report_display_set_id                NUMBER,
                     X_name                                 VARCHAR2,
                     X_description                          VARCHAR2,
                     X_row_set_id                           NUMBER,
                     X_column_set_id                        NUMBER,
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
  UPDATE rg_report_display_sets
  SET report_display_set_id    =   X_report_display_set_id       ,
      name                     =   X_name                        ,
      description              =   X_description                 ,
      row_set_id               =   X_row_set_id                  ,
      column_set_id            =   X_column_set_id               ,
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
  DELETE FROM rg_report_display_sets
  WHERE  rowid = X_rowid;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;
END delete_row;

END RG_REPORT_DISPLAY_SETS_PKG;

/
