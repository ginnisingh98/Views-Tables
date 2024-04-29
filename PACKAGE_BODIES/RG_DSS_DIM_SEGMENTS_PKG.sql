--------------------------------------------------------
--  DDL for Package Body RG_DSS_DIM_SEGMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RG_DSS_DIM_SEGMENTS_PKG" AS
/* $Header: rgiddsmb.pls 120.2 2002/11/14 02:58:11 djogg ship $ */
--
-- Name
--   RG_DSS_DIM_SEGMENTS_PKG
-- Purpose
--   to include all server side procedures AND packages for table
--   rg_dss_DIM_SEGMENTS
-- Notes
--
-- History
--   06/16/95	A Chen	Created
--
--
-- PRIVATE VARIABLES
--   None.
--
-- PRIVATE FUNCTIONS
--   None.
--
-- PUBLIC FUNCTIONS
--

PROCEDURE check_unique_sequence(X_rowid VARCHAR2,
                               X_dimension_id NUMBER,
                               X_sequence NUMBER) IS
     dummy NUMBER;
BEGIN
  SELECT    1
  INTO      dummy
  FROM      dual
  WHERE     NOT EXISTS
             (SELECT    1
              FROM      rg_dss_dim_segments
              WHERE     dimension_id = X_dimension_id
              AND       sequence = X_sequence
              AND       ((X_rowid IS NULL) OR (rowid <> X_rowid))
             );

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      FND_MESSAGE.set_name('RG', 'RG_FORMS_OBJECT_EXISTS_FOR');
      FND_MESSAGE.set_token('OBJECT1', 'RG_DSS_SEQUENCE', TRUE);
      FND_MESSAGE.set_token('OBJECT2', 'RG_DSS_DIMENSION', TRUE);
      APP_EXCEPTION.raise_exception;
END check_unique_sequence;


PROCEDURE check_unique_segment(X_rowid VARCHAR2,
                              X_dimension_id NUMBER,
                              X_application_column_name VARCHAR2) IS
  dummy  NUMBER;
BEGIN
  SELECT    1
  INTO      dummy
  FROM      dual
  WHERE     NOT EXISTS
             (SELECT    1
              FROM      rg_dss_dim_segments
              WHERE     dimension_id = X_dimension_id
              AND       application_column_name = X_application_column_name
              AND       ((X_rowid IS NULL) OR (rowid <> X_rowid))
             );

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      FND_MESSAGE.set_name('RG', 'RG_FORMS_OBJECT_EXISTS_FOR');
      FND_MESSAGE.set_token('OBJECT1', 'RG_DSS_SEGMENT', TRUE);
      FND_MESSAGE.set_token('OBJECT2', 'RG_DSS_DIMENSION', TRUE);
      APP_EXCEPTION.raise_exception;
END check_unique_segment;


FUNCTION number_of_dim_segments(X_dimension_id NUMBER) RETURN NUMBER IS
   num_of_dim_segs NUMBER;
BEGIN
  SELECT count(sequence)
    INTO num_of_dim_segs
    FROM rg_dss_dim_segments
   WHERE dimension_id = X_dimension_id;

   RETURN num_of_dim_segs;
END number_of_dim_segments;

-- *********************************************************************
-- The following procedures are necessary to hANDle the base view form.

PROCEDURE insert_row(X_master_dimension_id           IN OUT NOCOPY NUMBER,
		     X_rowid                         IN OUT NOCOPY VARCHAR2,
		     X_dimension_id                  IN OUT NOCOPY NUMBER,
 		     X_sequence		  	            NUMBER,
      		     X_application_column_name		    VARCHAR2,
		     X_id_flex_code		            VARCHAR2,
		     X_id_flex_num			    NUMBER,
                     X_max_desc_size                        NUMBER,
                     X_creation_date                        DATE,
                     X_created_by                           NUMBER,
                     X_last_update_date                     DATE,
                     X_last_updated_by                      NUMBER,
                     X_last_update_login                    NUMBER,
		     X_range_set_id			    NUMBER,
		     X_account_type			    VARCHAR2,
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
                     X_attribute15                          VARCHAR2
                     ) IS
  CURSOR C IS SELECT rowid FROM rg_dss_dim_segments
              WHERE dimension_id = X_dimension_id
                AND sequence = X_sequence;
BEGIN
  IF (X_Master_Dimension_Id IS NULL) THEN
    X_Master_Dimension_Id := RG_DSS_DIMENSIONS_PKG.get_new_id;
  END IF;
  X_dimension_id := X_Master_Dimension_Id;

  IF (RG_DSS_DIMENSIONS_PKG.used_in_frozen_system(X_Dimension_Id) = 1) THEN
    -- can't modify a dimension that is used in a frozen system
    FND_MESSAGE.set_name('RG', 'RG_DSS_FROZEN_SYSTEM');
    FND_MESSAGE.set_token('OBJECT', 'RG_DSS_DIMENSION', TRUE);
    APP_EXCEPTION.raise_exception;
  END IF;

  check_unique_sequence(X_rowid, X_dimension_id, X_sequence);
  check_unique_segment(X_rowid, X_dimension_id, X_application_column_name);

  INSERT INTO rg_dss_dim_segments
    (dimension_id             ,
     sequence                 ,
     application_column_name  ,
     id_flex_code             ,
     id_flex_num              ,
     max_desc_size            ,
     creation_date            ,
     created_by               ,
     last_update_date         ,
     last_updated_by          ,
     last_update_login        ,
     range_set_id             ,
     account_type             ,
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
    (X_dimension_id             ,
     X_sequence                 ,
     X_application_column_name  ,
     X_id_flex_code             ,
     X_id_flex_num              ,
     X_max_desc_size            ,
     X_creation_date            ,
     X_created_by               ,
     X_last_update_date         ,
     X_last_updated_by          ,
     X_last_update_login        ,
     X_range_set_id             ,
     X_account_type             ,
     X_context                  ,
     X_attribute1               ,
     X_attribute2               ,
     X_attribute3               ,
     X_attribute4               ,
     X_attribute5               ,
     X_attribute6               ,
     X_attribute7               ,
     X_attribute8               ,
     X_attribute9               ,
     X_attribute10              ,
     X_attribute11              ,
     X_attribute12              ,
     X_attribute13              ,
     X_attribute14              ,
     X_attribute15              );

  OPEN C;
  FETCH C INTO X_rowid;
  IF (C%NOTFOUND) THEN
    CLOSE C;
    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE C;
END insert_row;


PROCEDURE update_row(X_rowid                         IN OUT NOCOPY VARCHAR2,
		     X_dimension_id    		  	    NUMBER,
 		     X_sequence		  	            NUMBER,
      		     X_application_column_name		    VARCHAR2,
		     X_id_flex_code		            VARCHAR2,
		     X_id_flex_num			    NUMBER,
                     X_max_desc_size                        NUMBER,
                     X_last_update_date                     DATE,
                     X_last_updated_by                      NUMBER,
                     X_last_update_login                    NUMBER,
		     X_range_set_id			    NUMBER,
		     X_account_type			    VARCHAR2,
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
                     X_attribute15                          VARCHAR2
                     ) IS
BEGIN
  IF (RG_DSS_DIMENSIONS_PKG.used_in_frozen_system(X_Dimension_Id) = 1) THEN
    -- can't modify a dimension that is used in a frozen system
    FND_MESSAGE.set_name('RG', 'RG_DSS_FROZEN_SYSTEM');
    FND_MESSAGE.set_token('OBJECT', 'RG_DSS_DIMENSION', TRUE);
    APP_EXCEPTION.raise_exception;
  END IF;

  UPDATE rg_dss_dim_segments
     SET dimension_id             = X_dimension_id             ,
	 sequence                 = X_sequence                 ,
	 application_column_name  = X_application_column_name  ,
	 id_flex_code             = X_id_flex_code             ,
	 id_flex_num              = X_id_flex_num              ,
	 max_desc_size            = X_max_desc_size            ,
	 last_update_date         = X_last_update_date         ,
	 last_updated_by          = X_last_updated_by          ,
	 last_update_login        = X_last_update_login        ,
	 range_set_id             = X_range_set_id             ,
	 account_type             = X_account_type             ,
	 context                  = X_context                  ,
	 attribute1               = X_attribute1               ,
	 attribute2               = X_attribute2               ,
	 attribute3               = X_attribute3               ,
	 attribute4               = X_attribute4               ,
	 attribute5               = X_attribute5               ,
	 attribute6               = X_attribute6               ,
	 attribute7               = X_attribute7               ,
	 attribute8               = X_attribute8               ,
	 attribute9               = X_attribute9               ,
	 attribute10              = X_attribute10              ,
	 attribute11              = X_attribute11              ,
	 attribute12              = X_attribute12              ,
	 attribute13              = X_attribute13              ,
	 attribute14              = X_attribute14              ,
	 attribute15              = X_attribute15
  WHERE rowid = X_rowid;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

END update_row;

PROCEDURE lock_row(X_rowid                         IN OUT NOCOPY VARCHAR2,
		   X_dimension_id    		  	    NUMBER,
 		   X_sequence		  	            NUMBER,
      		   X_application_column_name		    VARCHAR2,
		   X_id_flex_code		            VARCHAR2,
		   X_id_flex_num			    NUMBER,
                   X_max_desc_size                        NUMBER,
		   X_range_set_id			    NUMBER,
		   X_account_type			    VARCHAR2,
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
                   X_attribute15                          VARCHAR2
                   ) IS
 CURSOR C IS
      SELECT *
      FROM   rg_dss_dim_segments
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
          (   (Recinfo.dimension_id = X_dimension_id)
           OR (    (Recinfo.dimension_id IS NULL)
               AND (X_dimension_id IS NULL)))
      AND (   (Recinfo.sequence = X_sequence)
           OR (    (Recinfo.sequence IS NULL)
               AND (X_sequence IS NULL)))
      AND (   (Recinfo.application_column_name = X_application_column_name)
           OR (    (Recinfo.application_column_name IS NULL)
               AND (X_application_column_name IS NULL)))
      AND (   (Recinfo.id_flex_code = X_id_flex_code)
           OR (    (Recinfo.id_flex_code IS NULL)
               AND (X_id_flex_code IS NULL)))
      AND (   (Recinfo.id_flex_num = X_id_flex_num)
           OR (    (Recinfo.id_flex_num IS NULL)
               AND (X_id_flex_num IS NULL)))
      AND (   (Recinfo.max_desc_size = X_max_desc_size)
           OR (    (Recinfo.max_desc_size IS NULL)
               AND (X_max_desc_size IS NULL)))
      AND (   (Recinfo.range_set_id = X_range_set_id)
           OR (    (Recinfo.range_set_id IS NULL)
               AND (X_range_set_id IS NULL)))
      AND (   (Recinfo.account_type = X_account_type)
           OR (    (Recinfo.account_type IS NULL)
               AND (X_account_type IS NULL)))
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

PROCEDURE delete_row(
            X_rowid VARCHAR2,
            X_Dimension_Id NUMBER) IS
BEGIN
  IF (RG_DSS_DIMENSIONS_PKG.used_in_frozen_system(X_Dimension_Id) = 1) THEN
    -- can't modify a dimension that is used in a frozen system
    FND_MESSAGE.set_name('RG', 'RG_DSS_FROZEN_SYSTEM');
    FND_MESSAGE.set_token('OBJECT', 'RG_DSS_DIMENSION', TRUE);
    APP_EXCEPTION.raise_exception;
  END IF;

  DELETE FROM rg_dss_dim_segments
  WHERE  rowid = X_rowid;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;
END delete_row;


END RG_DSS_DIM_SEGMENTS_PKG;

/
