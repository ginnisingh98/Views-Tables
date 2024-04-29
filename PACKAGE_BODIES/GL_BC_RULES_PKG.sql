--------------------------------------------------------
--  DDL for Package Body GL_BC_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_BC_RULES_PKG" as
/* $Header: glibcrlb.pls 120.3 2005/05/05 01:00:03 kvora ship $ */
--
-- Package
--   gl_bc_rules_pkg
-- Purpose
--   To contain validation, insertion, and update routines for gl_bc_rules
-- History
--   09-12-94   Sharif Rahman 	Created

PROCEDURE check_unique_bc_rules( X_rowid VARCHAR2,
                        X_bc_option_id NUMBER,
                        X_je_source_name VARCHAR2,
                        X_je_category_name VARCHAR2 ) IS
  dummy   NUMBER;
BEGIN
  SELECT 1 INTO dummy FROM dual
    WHERE NOT EXISTS
      (SELECT 1 FROM gl_bc_option_details
       WHERE bc_option_id = X_bc_option_id
         AND je_source_name = X_je_source_name
         AND je_category_name = X_je_category_name
         AND ((X_rowid IS NULL) OR (rowid <> X_rowid)));
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      FND_MESSAGE.set_name('SQLGL', 'GL_DUPLICATE_BC_RULE');
      APP_EXCEPTION.raise_exception;
END check_unique_bc_rules;

PROCEDURE insert_row(X_rowid                         IN OUT NOCOPY VARCHAR2 ,
                     X_bc_option_id                         NUMBER   ,
                     X_last_update_date                     DATE     ,
                     X_last_updated_by                      NUMBER   ,
                     X_last_update_login                    NUMBER   ,
                     X_je_source_name                       VARCHAR2 ,
                     X_je_category_name                     VARCHAR2 ,
                     X_funds_check_level_code               VARCHAR2 ,
                     X_creation_date                        DATE     ,
                     X_created_by                           NUMBER   ,
                     X_override_amount                      NUMBER   ,
                     X_tolerance_percentage                 NUMBER   ,
                     X_tolerance_amount                     NUMBER   ,
                     X_context                              VARCHAR2 ,
                     X_attribute1                           VARCHAR2 ,
                     X_attribute2                           VARCHAR2 ,
                     X_attribute3                           VARCHAR2 ,
                     X_attribute4                           VARCHAR2 ,
                     X_attribute5                           VARCHAR2 ,
                     X_attribute6                           VARCHAR2 ,
                     X_attribute7                           VARCHAR2 ,
                     X_attribute8                           VARCHAR2 ,
                     X_attribute9                           VARCHAR2 ,
                     X_attribute10                          VARCHAR2 ,
                     X_attribute11                          VARCHAR2 ,
                     X_attribute12                          VARCHAR2 ,
                     X_attribute13                          VARCHAR2 ,
                     X_attribute14                          VARCHAR2 ,
                     X_attribute15                          VARCHAR2 ) IS
  CURSOR C IS SELECT rowid FROM gl_bc_option_details
    WHERE bc_option_id = X_bc_option_id
      AND je_source_name = X_je_source_name
      AND je_category_name = X_je_category_name;
BEGIN
  INSERT INTO gl_bc_option_details(
                 bc_option_id             ,
                 last_update_date         ,
                 last_updated_by          ,
                 last_update_login        ,
                 je_source_name           ,
                 je_category_name         ,
                 funds_check_level_code   ,
                 creation_date            ,
                 created_by               ,
                 override_amount          ,
                 tolerance_percentage     ,
                 tolerance_amount         ,
                 context                  ,
                 attribute1               ,
                 attribute2               ,
                 attribute3               ,
                 attribute4               ,
                 attribute5               ,
                 attribute6               ,
                 attribute7               ,
                 attribute8               ,
                 attribute9               ,
                 attribute10              ,
                 attribute11              ,
                 attribute12              ,
                 attribute13              ,
                 attribute14              ,
                 attribute15              )
  VALUES
                (X_bc_option_id           ,
                 X_last_update_date       ,
                 X_last_updated_by        ,
                 X_last_update_login      ,
                 X_je_source_name         ,
                 X_je_category_name       ,
                 X_funds_check_level_code ,
                 X_creation_date          ,
                 X_created_by             ,
                 X_override_amount        ,
                 X_tolerance_percentage   ,
                 X_tolerance_amount       ,
                 X_context                ,
                 X_attribute1             ,
                 X_attribute2             ,
                 X_attribute3             ,
                 X_attribute4             ,
                 X_attribute5             ,
                 X_attribute6             ,
                 X_attribute7             ,
                 X_attribute8             ,
                 X_attribute9             ,
                 X_attribute10            ,
                 X_attribute11            ,
                 X_attribute12            ,
                 X_attribute13            ,
                 X_attribute14            ,
                 X_attribute15            );
  OPEN C;
  FETCH C INTO X_rowid;
  IF (C%NOTFOUND) THEN
    CLOSE C;
    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE C;
END insert_row;


PROCEDURE update_row(X_rowid                         IN OUT NOCOPY VARCHAR2 ,
                     X_bc_option_id                         NUMBER   ,
                     X_last_update_date                     DATE     ,
                     X_last_updated_by                      NUMBER   ,
                     X_last_update_login                    NUMBER   ,
                     X_je_source_name                       VARCHAR2 ,
                     X_je_category_name                     VARCHAR2 ,
                     X_funds_check_level_code               VARCHAR2 ,
                     X_override_amount                      NUMBER   ,
                     X_tolerance_percentage                 NUMBER   ,
                     X_tolerance_amount                     NUMBER   ,
                     X_context                              VARCHAR2 ,
                     X_attribute1                           VARCHAR2 ,
                     X_attribute2                           VARCHAR2 ,
                     X_attribute3                           VARCHAR2 ,
                     X_attribute4                           VARCHAR2 ,
                     X_attribute5                           VARCHAR2 ,
                     X_attribute6                           VARCHAR2 ,
                     X_attribute7                           VARCHAR2 ,
                     X_attribute8                           VARCHAR2 ,
                     X_attribute9                           VARCHAR2 ,
                     X_attribute10                          VARCHAR2 ,
                     X_attribute11                          VARCHAR2 ,
                     X_attribute12                          VARCHAR2 ,
                     X_attribute13                          VARCHAR2 ,
                     X_attribute14                          VARCHAR2 ,
                     X_attribute15                          VARCHAR2 ) IS
BEGIN
  UPDATE gl_bc_option_details
  SET
    bc_option_id             =   X_bc_option_id           ,
    last_update_date         =   X_last_update_date       ,
    last_updated_by          =   X_last_updated_by        ,
    last_update_login        =   X_last_update_login      ,
    je_source_name           =   X_je_source_name         ,
    je_category_name         =   X_je_category_name       ,
    funds_check_level_code   =   X_funds_check_level_code ,
    override_amount          =   X_override_amount        ,
    tolerance_percentage     =   X_tolerance_percentage   ,
    tolerance_amount         =   X_tolerance_amount       ,
    context                  =   X_context                ,
    attribute1               =   X_attribute1             ,
    attribute2              =   X_attribute2             ,
    attribute3               =   X_attribute3             ,
    attribute4               =   X_attribute4             ,
    attribute5               =   X_attribute5             ,
    attribute6               =   X_attribute6             ,
    attribute7               =   X_attribute7             ,
    attribute8               =   X_attribute8             ,
    attribute9               =   X_attribute9             ,
    attribute10              =   X_attribute10            ,
    attribute11              =   X_attribute11            ,
    attribute12              =   X_attribute12            ,
    attribute13              =   X_attribute13            ,
    attribute14              =   X_attribute14            ,
    attribute15              =   X_attribute15
  WHERE rowid = X_rowid;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;
END update_row;


PROCEDURE lock_row ( X_rowid                         IN OUT NOCOPY VARCHAR2 ,
                     X_bc_option_id                         NUMBER   ,
                     X_je_source_name                       VARCHAR2 ,
                     X_je_category_name                     VARCHAR2 ,
                     X_funds_check_level_code               VARCHAR2 ,
                     X_override_amount                      NUMBER   ,
                     X_tolerance_percentage                 NUMBER   ,
                     X_tolerance_amount                     NUMBER   ,
                     X_context                              VARCHAR2 ,
                     X_attribute1                           VARCHAR2 ,
                     X_attribute2                           VARCHAR2 ,
                     X_attribute3                           VARCHAR2 ,
                     X_attribute4                           VARCHAR2 ,
                     X_attribute5                           VARCHAR2 ,
                     X_attribute6                           VARCHAR2 ,
                     X_attribute7                           VARCHAR2 ,
                     X_attribute8                           VARCHAR2 ,
                     X_attribute9                           VARCHAR2 ,
                     X_attribute10                          VARCHAR2 ,
                     X_attribute11                          VARCHAR2 ,
                     X_attribute12                          VARCHAR2 ,
                     X_attribute13                          VARCHAR2 ,
                     X_attribute14                          VARCHAR2 ,
                     X_attribute15                          VARCHAR2 ) IS
  CURSOR C IS
    SELECT *
    FROM gl_bc_option_details
    WHERE rowid = X_rowid
    FOR UPDATE OF bc_option_id NOWAIT;
  RecInfo C%ROWTYPE;
BEGIN
  OPEN C;
  FETCH C INTO RecInfo;
  IF (C%NOTFOUND) THEN
    CLOSE C;
    FND_MESSAGE.set_name('FND', 'FORM_RECORD_DELETED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  END IF;
  CLOSE C;

  IF (
          (   (Recinfo.bc_option_id = X_bc_option_id)
           OR (    (Recinfo.bc_option_id IS NULL)
               AND (X_bc_option_id IS NULL)))
      AND (   (Recinfo.je_source_name = X_je_source_name)
           OR (    (Recinfo.je_source_name IS NULL)
               AND (X_je_source_name IS NULL)))
      AND (   (Recinfo.je_category_name = X_je_category_name)
           OR (    (Recinfo.je_category_name IS NULL)
               AND (X_je_category_name IS NULL)))
      AND (   (Recinfo.funds_check_level_code = X_funds_check_level_code)
           OR (    (Recinfo.funds_check_level_code IS NULL)
               AND (X_funds_check_level_code IS NULL)))
      AND (   (Recinfo.override_amount = X_override_amount)
           OR (    (Recinfo.override_amount IS NULL)
               AND (X_override_amount IS NULL)))
      AND (   (Recinfo.tolerance_percentage = X_tolerance_percentage)
           OR (    (Recinfo.tolerance_percentage IS NULL)
               AND (X_tolerance_percentage IS NULL)))
      AND (   (Recinfo.tolerance_amount = X_tolerance_amount)
           OR (    (Recinfo.tolerance_amount IS NULL)
               AND (X_tolerance_amount IS NULL)))
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
    FND_MESSAGE.set_name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  END IF;
END lock_row;


PROCEDURE delete_row(X_rowid VARCHAR2) IS
BEGIN
  DELETE FROM gl_bc_option_details
  WHERE rowid = X_rowid;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;
END delete_row;


FUNCTION default_source_name RETURN VARCHAR2 IS
  name  gl_je_sources.user_je_source_name%TYPE;
BEGIN
  SELECT user_je_source_name
    INTO name
    FROM gl_je_sources
    WHERE je_source_name = 'Other';
  RETURN (name);
END default_source_name;


FUNCTION default_category_name RETURN VARCHAR2 IS
  name  gl_je_categories.user_je_category_name%TYPE;
BEGIN
  SELECT user_je_category_name
    INTO name
    FROM gl_je_categories
    WHERE je_category_name = 'Other';
  RETURN (name);
END default_category_name;


END GL_BC_RULES_PKG;

/
