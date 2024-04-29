--------------------------------------------------------
--  DDL for Package Body RG_REPORT_AXIS_SETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RG_REPORT_AXIS_SETS_PKG" AS
/* $Header: rgiraxsb.pls 120.9 2006/11/09 20:28:29 ticheng ship $ */
-- Name
--   rg_report_axis_sets_pkg
-- Purpose
--   to include all server side procedures and packages for table
--   rg_report_axis_sets
-- Notes
--
-- History
--   11/01/93	A Chen	Created
--
-- PRIVATE VARIABLES
--   None.
--
-- PRIVATE FUNCTIONS
--   None.
--
-- PUBLIC FUNCTIONS
--
  PROCEDURE select_row(recinfo IN OUT NOCOPY rg_report_axis_sets%ROWTYPE) IS
  BEGIN
    select * INTO recinfo
    from rg_report_axis_sets
    where axis_set_id = recinfo.axis_set_id;
  END select_row;

  PROCEDURE select_columns(X_axis_set_id NUMBER,
                           X_name IN OUT NOCOPY VARCHAR2) IS
    recinfo rg_report_axis_sets%ROWTYPE;
  BEGIN
    recinfo.axis_set_id := X_axis_set_id;
    select_row(recinfo);
    X_name := recinfo.name;
  END select_columns;

  PROCEDURE update_structure_info(X_axis_set_id NUMBER,
                       X_id_flex_code VARCHAR2,
                       X_structure_id NUMBER) IS
  BEGIN
    UPDATE rg_report_axis_sets
    SET    id_flex_code = X_id_flex_code,
           structure_id = X_structure_id
    WHERE  axis_set_id = NVL( X_axis_set_id, -1);
  END update_structure_info;

  FUNCTION check_unique(X_rowid VARCHAR2,
                         X_name VARCHAR2,
                         X_axis_set_type VARCHAR2,
                         X_application_id NUMBER) RETURN BOOLEAN IS
     dummy   NUMBER;
  BEGIN
    select 1 into dummy from dual
    where not exists
      (select 1 from rg_report_axis_sets
       where name = X_name
         and axis_set_type = X_axis_set_type
         and application_id = X_application_id
         and ((X_rowid IS NULL) OR (rowid <> X_rowid)));

    RETURN (TRUE);

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN (FALSE);
  END check_unique;

  PROCEDURE check_references(X_axis_set_id NUMBER, X_axis_set_type VARCHAR2) IS
    object_name  VARCHAR2(80);
    dummy        NUMBER;
  BEGIN
    IF (X_axis_set_type = 'R') THEN

      SELECT 1 INTO dummy FROM sys.dual
      WHERE NOT EXISTS
        (  SELECT 1
           FROM   rg_reports
           WHERE  row_set_id = X_axis_set_id
         UNION
           SELECT 1
           FROM   rg_report_display_sets
           WHERE  row_set_id = X_axis_set_id
         UNION
           SELECT 1
           FROM   rg_report_display_groups
           WHERE  row_set_id = X_axis_set_id
        );

    ELSE

      SELECT 1 INTO dummy FROM sys.dual
      WHERE NOT EXISTS
        (  SELECT 1
           FROM   rg_reports
           WHERE  column_set_id = X_axis_set_id
         UNION
           SELECT 1
           FROM   rg_report_display_sets
           WHERE  column_set_id = X_axis_set_id
         UNION
           SELECT 1
           FROM   rg_report_display_groups
           WHERE  column_set_id = X_axis_set_id
        );

    END IF;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        fnd_message.set_name('RG','RG_FORMS_REF_OBJECT_AXS');
        IF (X_axis_set_type = 'R') THEN
          fnd_message.set_token('OBJECT', 'RG_ROW_SET',TRUE);
        ELSE
          fnd_message.set_token('OBJECT', 'RG_COLUMN_SET',TRUE);
        END IF;
        app_exception.raise_exception;
  END check_references;

  FUNCTION get_nextval return number IS
    next_group_id  NUMBER;
  BEGIN
    select rg_report_axis_sets_s.nextval
    into   next_group_id
    from   dual;

    RETURN (next_group_id);
  END get_nextval;

-- *********************************************************************

-- The following procedures are necessary to handle the base view form.

PROCEDURE insert_row(X_rowid                  IN OUT NOCOPY VARCHAR2,
		     X_application_id    		    NUMBER,
 		     X_axis_set_id	      IN OUT NOCOPY NUMBER,
      		     X_name				    VARCHAR2,
 		     X_axis_set_type			    VARCHAR2,
		     X_security_flag                        VARCHAR2,
		     X_display_in_list_flag	            VARCHAR2,
 		     X_period_set_name			    VARCHAR2,
		     X_description		            VARCHAR2,
                     X_column_set_header                    VARCHAR2,
		     X_segment_name		            VARCHAR2,
		     X_id_flex_code		            VARCHAR2,
		     X_structure_id			    NUMBER,
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
                     X_attribute15                          VARCHAR2,
                     X_taxonomy_id                          NUMBER) IS
  CURSOR C IS SELECT rowid FROM rg_report_axis_sets
              WHERE axis_set_id = X_axis_set_id;
  BEGIN
    IF (NOT check_unique(X_rowid,
                         X_name,
                         X_axis_set_type,
                         X_application_id)) THEN
      FND_MESSAGE.set_name('RG','RG_FORMS_OBJECT_EXISTS');
      IF (X_axis_set_type = 'R') THEN
        FND_MESSAGE.set_token('OBJECT','RG_ROW_SET',TRUE);
      ELSE
        FND_MESSAGE.set_token('OBJECT','RG_COLUMN_SET',TRUE);
      END IF;
      APP_EXCEPTION.raise_exception;
    END IF;

    IF (X_axis_set_id IS NULL) THEN
      X_axis_set_id := get_nextval;
    END IF;

    INSERT INTO rg_report_axis_sets
    (application_id                ,
     axis_set_id                   ,
     name                          ,
     axis_set_type                 ,
     security_flag                 ,
     display_in_list_flag          ,
     period_set_name               ,
     description                   ,
     column_set_header             ,
     segment_name                  ,
     id_flex_code                  ,
     structure_id                  ,
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
     attribute15                   ,
     taxonomy_id)
     VALUES
    (X_application_id                ,
     X_axis_set_id                   ,
     X_name                          ,
     X_axis_set_type                 ,
     X_security_flag                 ,
     X_display_in_list_flag          ,
     X_period_set_name               ,
     X_description                   ,
     X_column_set_header             ,
     X_segment_name                  ,
     X_id_flex_code                  ,
     X_structure_id                  ,
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
     X_attribute15                   ,
     X_taxonomy_id);

  OPEN C;
  FETCH C INTO X_rowid;
  IF (C%NOTFOUND) THEN
    CLOSE C;
    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE C;
END insert_row;

PROCEDURE lock_row(X_rowid                                VARCHAR2,
		   X_application_id    		          NUMBER,
 		   X_axis_set_id			  NUMBER,
      		   X_name			          VARCHAR2,
 	           X_axis_set_type			  VARCHAR2,
		   X_security_flag                        VARCHAR2,
		   X_display_in_list_flag	          VARCHAR2,
 		   X_period_set_name			  VARCHAR2,
		   X_description		          VARCHAR2,
                   X_column_set_header                    VARCHAR2,
		   X_segment_name		          VARCHAR2,
		   X_id_flex_code		          VARCHAR2,
		   X_structure_id			  NUMBER,
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
                   X_attribute15                          VARCHAR2,
                   X_taxonomy_id                          NUMBER) IS
  CURSOR C IS
      SELECT *
      FROM   rg_report_axis_sets
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
          (   (Recinfo.application_id = X_application_id)
           OR (    (Recinfo.application_id IS NULL)
               AND (X_application_id IS NULL)))
      AND (   (Recinfo.axis_set_id = X_axis_set_id)
           OR (    (Recinfo.axis_set_id IS NULL)
               AND (X_axis_set_id IS NULL)))
      AND (   (Recinfo.name = X_name)
           OR (    (Recinfo.name IS NULL)
               AND (X_name IS NULL)))
      AND (   (Recinfo.axis_set_type = X_axis_set_type)
           OR (    (Recinfo.axis_set_type IS NULL)
               AND (X_axis_set_type IS NULL)))
      AND (   (Recinfo.security_flag = X_security_flag)
           OR (    (Recinfo.security_flag IS NULL)
               AND (X_security_flag IS NULL)))
      AND (   (Recinfo.display_in_list_flag = X_display_in_list_flag)
           OR (    (Recinfo.display_in_list_flag IS NULL)
               AND (X_display_in_list_flag IS NULL)))
      AND (   (Recinfo.period_set_name = X_period_set_name)
           OR (    (Recinfo.period_set_name IS NULL)
               AND (X_period_set_name IS NULL)))
      AND (   (Recinfo.description = X_description)
           OR (    (Recinfo.description IS NULL)
               AND (X_description IS NULL)))
      AND (   (rtrim(Recinfo.column_set_header) = X_column_set_header)
           OR (    (rtrim(Recinfo.column_set_header) IS NULL)
               AND (X_column_set_header IS NULL)))
      AND (   (Recinfo.segment_name = X_segment_name)
           OR (    (Recinfo.segment_name IS NULL)
               AND (X_segment_name IS NULL)))
      AND (   (Recinfo.id_flex_code = X_id_flex_code)
           OR (    (Recinfo.id_flex_code IS NULL)
               AND (X_id_flex_code IS NULL)))
      AND (   (Recinfo.structure_id = X_structure_id)
           OR (    (Recinfo.structure_id IS NULL)
               AND (X_structure_id IS NULL)))
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
           OR (    (Recinfo.attribute14 IS NULL)
               AND (X_attribute14 IS NULL)))
      AND (   (Recinfo.attribute15 = X_attribute15)
           OR (    (Recinfo.attribute15 IS NULL)
               AND (X_attribute15 IS NULL)))
      AND (   (Recinfo.taxonomy_id = X_taxonomy_id)
           OR (    (Recinfo.taxonomy_id IS NULL)
               AND (X_taxonomy_id IS NULL)))
          ) THEN
    RETURN;
  ELSE
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  END IF;
END lock_row;

PROCEDURE update_row(X_rowid                  IN OUT NOCOPY VARCHAR2,
		     X_application_id    		    NUMBER,
 		     X_axis_set_id			    NUMBER,
      		     X_name				    VARCHAR2,
 		     X_axis_set_type			    VARCHAR2,
		     X_security_flag                        VARCHAR2,
		     X_display_in_list_flag	            VARCHAR2,
 		     X_period_set_name			    VARCHAR2,
		     X_description		            VARCHAR2,
                     X_column_set_header                    VARCHAR2,
		     X_segment_name		            VARCHAR2,
		     X_id_flex_code		            VARCHAR2,
		     X_structure_id			    NUMBER,
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
                     X_attribute15                          VARCHAR2,
                     X_taxonomy_id                          NUMBER) IS
BEGIN
  UPDATE rg_report_axis_sets
  SET application_id           =   X_application_id              ,
      axis_set_id              =   X_axis_set_id                 ,
      name                     =   X_name                        ,
      axis_set_type            =   X_axis_set_type               ,
      security_flag            =   X_security_flag               ,
      display_in_list_flag     =   X_display_in_list_flag        ,
      period_set_name          =   X_period_set_name             ,
      description              =   X_description                 ,
      column_set_header        =   X_column_set_header           ,
      segment_name             =   X_segment_name                ,
      id_flex_code             =   X_id_flex_code                ,
      structure_id             =   X_structure_id                ,
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
      attribute15              =   X_attribute15                 ,
      taxonomy_id              =   X_taxonomy_id
  WHERE rowid = X_rowid;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;
END update_row;

PROCEDURE delete_row(X_rowid VARCHAR2,
                      X_axis_set_id NUMBER) IS
BEGIN
  rg_report_axes_pkg.delete_rows(X_axis_set_id);

  DELETE FROM rg_report_axis_sets
  WHERE  rowid = X_rowid;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;
END delete_row;

PROCEDURE Load_Row(
	   X_Application_Id  		        NUMBER,
           X_Seeded_Name                        VARCHAR2,
      	   X_Name		                VARCHAR2,
 	   X_Axis_Set_Type                      VARCHAR2,
	   X_Display_In_List_Flag               VARCHAR2,
	   X_Description                        VARCHAR2,
           X_Column_Set_Header                  VARCHAR2,
	   X_Segment_Name                       VARCHAR2,
	   X_Id_Flex_Code                       VARCHAR2,
           X_Structure_Id                       NUMBER,
	   X_Context                            VARCHAR2,
           X_Attribute1                         VARCHAR2,
           X_Attribute2                         VARCHAR2,
           X_Attribute3                         VARCHAR2,
           X_Attribute4                         VARCHAR2,
           X_Attribute5                         VARCHAR2,
           X_Attribute6                         VARCHAR2,
           X_Attribute7                         VARCHAR2,
           X_Attribute8                         VARCHAR2,
           X_Attribute9                         VARCHAR2,
           X_Attribute10                        VARCHAR2,
           X_Attribute11                        VARCHAR2,
           X_Attribute12                        VARCHAR2,
           X_Attribute13                        VARCHAR2,
           X_Attribute14                        VARCHAR2,
           X_Attribute15                        VARCHAR2,
	   X_Owner                              VARCHAR2,
           X_Force_Edits                        VARCHAR2 ) IS

  user_id           NUMBER := 0;
  v_axis_set_id     NUMBER(15);
  v_creation_date   DATE;
  v_last_updated_by NUMBER;
  v_rowid           ROWID := null;
  v_security_flag   VARCHAR2(1);
BEGIN
    /* Make sure primary key is not null */
--    IF ( X_Axis_Set_Id is null ) THEN
--      fnd_message.set_name('SQLGL', 'GL_LOAD_ROW_NO_DATA');
--      app_exception.raise_exception;
--    END IF;

    /* Make sure to only load Seeded data */
    IF (X_Seeded_Name IS NULL) THEN
      fnd_message.set_name ('SQLGL','GL_LOAD_ROW_NO_DATA');
      app_exception.raise_exception;
    END IF;

    /* Set user id for seeded data */
    IF (X_OWNER = 'SEED') THEN
      user_id := 1;
    END IF;

    BEGIN

      /* Retrieve creation date from existing rows */
      SELECT axis_set_id, creation_date, last_updated_by,
             rowid, security_flag
      INTO   v_axis_set_id, v_creation_date, v_last_updated_by,
             v_rowid, v_security_flag
      FROM   RG_REPORT_AXIS_SETS
      WHERE  SEEDED_NAME = X_Seeded_Name;

      /* Do not overwrite if it has been customized */
      IF (v_last_updated_by <> 1) THEN
        RETURN;
      END IF;

      /*
       * Update only if force_edits is 'Y' or owner = 'SEED'
       */
      IF ( user_id = 1 OR X_Force_Edits = 'Y' )  THEN
        RG_REPORT_AXIS_SETS_PKG.update_row(
	    X_rowid	                  => v_rowid,
   	    X_application_id              => X_Application_Id,
	    X_axis_set_id                 => v_axis_set_id,
	    X_security_flag               => v_security_flag,
	    X_name			  => X_Name,
            X_axis_set_type               => X_Axis_Set_Type,
            X_display_in_list_flag	  => X_Display_In_List_Flag,
            X_period_set_name		  => null,
            X_description		  => X_Description,
            X_column_set_header           => X_Column_Set_Header,
            X_segment_name		  => X_Segment_Name,
            X_id_flex_code		  => X_Id_Flex_Code,
	    X_structure_id		  => X_Structure_Id,
            X_last_update_date            => sysdate,
            X_last_updated_by             => user_id,
            X_last_update_login           => 0,
            X_context                     => X_Context,
            X_attribute1                  => X_Attribute1,
            X_attribute2                  => X_Attribute2,
            X_attribute3                  => X_Attribute3,
            X_attribute4                  => X_Attribute4,
            X_attribute5                  => X_Attribute5,
            X_attribute6                  => X_Attribute6,
            X_attribute7                  => X_Attribute7,
            X_attribute8                  => X_Attribute8,
            X_attribute9                  => X_Attribute9,
            X_attribute10                 => X_Attribute10,
            X_attribute11                 => X_Attribute11,
            X_attribute12                 => X_Attribute12,
            X_attribute13                 => X_Attribute13,
            X_attribute14                 => X_Attribute14,
            X_attribute15                 => X_Attribute15,
            X_taxonomy_id                 => null
          );
      END IF;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        /*
	 * If the row doesn't exist yet, call Insert_Row().
         */
        RG_REPORT_AXIS_SETS_PKG.insert_row(
           X_rowid                => v_rowid,
	   X_application_id       => X_Application_Id,
	   X_axis_set_id	  => v_axis_set_id,
	   X_security_flag        => 'N',
      	   X_name		  => X_Name,
 	   X_axis_set_type        => X_Axis_Set_Type,
	   X_display_in_list_flag => X_Display_In_List_Flag,
 	   X_period_set_name      => null,
	   X_description          => X_Description,
           X_column_set_header    => X_Column_Set_Header,
	   X_segment_name         => X_Segment_Name,
	   X_id_flex_code         => X_Id_Flex_Code,
           X_structure_id         => X_Structure_Id,
           X_creation_date        => sysdate,
           X_created_by           => user_id,
           X_last_update_date     => sysdate,
           X_last_updated_by      => user_id,
           X_last_update_login    => 0,
           X_context              => X_Context,
           X_attribute1           => X_Attribute1,
           X_attribute2           => X_Attribute2,
           X_attribute3           => X_Attribute3,
           X_attribute4           => X_Attribute4,
           X_attribute5           => X_Attribute5,
           X_attribute6           => X_Attribute6,
           X_attribute7           => X_Attribute7,
           X_attribute8           => X_Attribute8,
           X_attribute9           => X_Attribute9,
           X_attribute10          => X_Attribute10,
           X_attribute11          => X_Attribute11,
           X_attribute12          => X_Attribute12,
           X_attribute13          => X_Attribute13,
           X_attribute14          => X_Attribute14,
           X_attribute15          => X_Attribute15,
           X_taxonomy_id          => null);

      /* Bug 5648378: Make sure to also populate the seeded_name column
       * for seeded data. */
      UPDATE RG_REPORT_AXIS_SETS
      SET SEEDED_NAME = X_Seeded_Name
      WHERE rowid = v_rowid;
    END;
END Load_Row;


PROCEDURE Translate_Row (
    X_Name           VARCHAR2,
    X_Description    VARCHAR2,
    X_Seeded_Name    VARCHAR2,
    X_Owner          VARCHAR2,
    X_Force_Edits    VARCHAR2 ) IS
  user_id number := 0;
BEGIN

    IF (X_OWNER = 'SEED') THEN
      user_id := 1;
    END IF;

    /*
     * Update only if force_edits is 'Y' or owner = 'SEED'
     */
    IF ( user_id = 1 or X_Force_Edits = 'Y' ) THEN
      UPDATE RG_REPORT_AXIS_SETS
      SET
          name              = X_Name,
	  description       = X_Description,
          last_update_date  = sysdate,
	  last_updated_by   = user_id,
	  last_Update_login = 0
      WHERE
          seeded_name = X_Seeded_Name
      AND
          userenv('LANG') =
          ( SELECT language_code
            FROM  FND_LANGUAGES
            WHERE  installed_flag = 'B' );

    END IF;

END Translate_Row;

END RG_REPORT_AXIS_SETS_PKG;

/
