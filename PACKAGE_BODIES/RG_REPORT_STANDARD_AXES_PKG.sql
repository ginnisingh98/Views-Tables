--------------------------------------------------------
--  DDL for Package Body RG_REPORT_STANDARD_AXES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RG_REPORT_STANDARD_AXES_PKG" AS
/* $Header: rgirstdb.pls 120.6 2004/09/20 06:19:35 adesu ship $ */
-- Name
--   rg_report_standard_axes_pkg
-- Purpose
--   to include all sever side procedures and packages for table
--   rg_report_standard_axes
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
  PROCEDURE select_row(recinfo IN OUT NOCOPY rg_report_standard_axes_tl%ROWTYPE) IS
  BEGIN
    select * INTO recinfo
    from rg_report_standard_axes_tl
    where standard_axis_id = recinfo.standard_axis_id;
  END select_row;

  PROCEDURE select_columns(X_standard_axis_id NUMBER,
                           X_name IN OUT NOCOPY VARCHAR2) IS
    recinfo rg_report_standard_axes_tl%ROWTYPE;
  BEGIN
    recinfo.standard_axis_id := X_standard_axis_id;
    select_row(recinfo);
    X_name := recinfo.standard_axis_name;
  END select_columns;

  --
  -- Name
  --   insert_row
  -- Purpose
  --   Insert a row into RG_REPORT_STANDARD_AXES_B , RGE_REPORT_STANDARD_AXES_TL
  --
  PROCEDURE insert_row(X_rowid                 IN OUT NOCOPY   VARCHAR2,
		       X_application_id			NUMBER,
                       X_last_update_date               DATE,
                       X_last_updated_by                NUMBER,
                       X_last_update_login              NUMBER,
                       X_creation_date                  DATE,
                       X_created_by                     NUMBER,
		       X_standard_axis_id		NUMBER,
  		       X_standard_axis_name		VARCHAR2,
  		       X_class				VARCHAR2,
     		       X_display_in_std_list_flag 	VARCHAR2,
                       X_precedence_level		NUMBER,
  		       X_database_column		VARCHAR2,
  		       X_simple_where_name		VARCHAR2,
  		       X_period_query			VARCHAR2,
  		       X_standard_axis1_id		NUMBER,
  		       X_axis1_operator			VARCHAR2,
                       X_standard_axis2_id		NUMBER,
  		       X_axis2_operator			VARCHAR2,
                       X_constant			NUMBER,
  		       X_variance_flag 			VARCHAR2,
		       X_sign_flag			VARCHAR2,
 		       X_description	                VARCHAR2
   	) IS
  BEGIN

    INSERT INTO RG_REPORT_STANDARD_AXES_B (
	application_id,
	standard_axis_id,
	last_update_date,
	last_updated_by,
	last_update_login,
 	creation_date,
	created_by,
	class,
	display_in_standard_list_flag,
	precedence_level,
	database_column,
	simple_where_name,
	period_query,
	standard_axis1_id,
	axis1_operator,
	standard_axis2_id,
	axis2_operator,
	constant,
	variance_flag,
	sign_flag )
    VALUES
    (   X_application_id,
	X_standard_axis_id,
        X_last_update_date,
	X_last_updated_by,
	X_last_update_login,
	X_creation_date,
	X_created_by,
  	X_class,
     	X_display_in_std_list_flag,
        X_precedence_level,
  	X_database_column,
  	X_simple_where_name,
  	X_period_query,
  	X_standard_axis1_id,
  	X_axis1_operator,
        X_standard_axis2_id,
  	X_axis2_operator,
        X_constant,
  	X_variance_flag,
	X_sign_flag
    );


   INSERT INTO RG_REPORT_STANDARD_AXES_TL
    (
      STANDARD_AXIS_ID,
      LANGUAGE,
      SOURCE_LANG,
      STANDARD_AXIS_NAME,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN,
      CREATION_DATE,
      CREATED_BY,
      DESCRIPTION
    )
    SELECT
            X_standard_axis_id,
            L.language_code,
            userenv('LANG'),
            X_standard_axis_name,
            X_last_update_date,
            X_last_updated_by,
            X_last_update_login,
            X_creation_date,
            X_created_by,
            X_description
    FROM   FND_LANGUAGES L
    WHERE  L.installed_flag IN ('I', 'B')
    AND NOT EXISTS
           ( SELECT NULL
	     FROM   RG_REPORT_STANDARD_AXES_TL R
	     WHERE  R.standard_axis_id   =  X_standard_axis_id
	     AND    R.language           =  L.language_code );


  END insert_row;

  --
  -- Name
  --   update_row
  -- Purpose
  --   Update a row in RG_REPORT_STANDARD_AXES
  --
  PROCEDURE update_row(X_rowid                   IN OUT NOCOPY VARCHAR2,
	               X_application_id			NUMBER,
		       X_standard_axis_id		NUMBER,
  		       X_standard_axis_name		VARCHAR2,
                       X_last_update_date        	DATE,
                       X_last_updated_by                NUMBER,
                       X_last_update_login              NUMBER,
  		       X_class				VARCHAR2,
     		       X_display_in_std_list_flag 	VARCHAR2,
                       X_precedence_level		NUMBER,
  		       X_database_column		VARCHAR2,
  		       X_simple_where_name		VARCHAR2,
  		       X_period_query			VARCHAR2,
  		       X_standard_axis1_id		NUMBER,
  		       X_axis1_operator			VARCHAR2,
                       X_standard_axis2_id		NUMBER,
  		       X_axis2_operator			VARCHAR2,
                       X_constant			NUMBER,
  		       X_variance_flag 			VARCHAR2,
		       X_sign_flag			VARCHAR2,
 		       X_description	                VARCHAR2
   	) IS
  BEGIN

    UPDATE RG_REPORT_STANDARD_AXES_B
    SET
	application_id                = X_application_id,
	standard_axis_id              = X_standard_axis_id,
        last_update_date              = X_last_update_date,
        last_updated_by               = X_last_updated_by,
        last_update_login             = X_last_update_login,
        class                         = X_class,
	display_in_standard_list_flag = X_display_in_std_list_flag,
	precedence_level              = X_precedence_level,
        database_column               = X_database_column,
        simple_where_name             = X_simple_where_name,
        period_query	              = X_period_query,
        standard_axis1_id             = X_standard_axis1_id,
	axis1_operator                = X_axis1_operator,
        standard_axis2_id             = X_standard_axis2_id ,
        axis2_operator	              = X_axis2_operator,
        constant                      = X_constant,
        variance_flag                 = X_variance_flag,
        sign_flag                     = X_sign_flag
    WHERE standard_axis_id = X_standard_axis_id;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

    -- update non-translatable columns

    UPDATE RG_REPORT_STANDARD_AXES_TL
    SET
      STANDARD_AXIS_ID          =  X_standard_axis_id,
      LAST_UPDATE_DATE          =  X_last_update_date,
      LAST_UPDATED_BY           =  X_last_updated_by,
      LAST_UPDATE_LOGIN         =  X_last_update_login
   WHERE  standard_axis_id      =  X_standard_axis_id;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

    -- update translatable columns

    UPDATE RG_REPORT_STANDARD_AXES_TL
    SET  DESCRIPTION          =  X_description,
         STANDARD_AXIS_NAME   =  X_standard_axis_name,
         SOURCE_LANG          =  userenv('LANG')
    WHERE standard_axis_id    =  X_standard_axis_id
    AND   userenv('LANG') in (LANGUAGE, SOURCE_LANG);

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END update_row;

  --
  -- Name
  --   Load_Row
  -- Purpose
  --   Load a row in RG_REPORT_STANDARD_AXES for NLS support
  --
  PROCEDURE Load_Row ( X_Application_Id			NUMBER,
		       X_Standard_Axis_Id		NUMBER,
  		       X_Class				VARCHAR2,
     		       X_Display_In_Std_List_Flag 	VARCHAR2,
                       X_Precedence_Level		NUMBER,
  		       X_Database_Column		VARCHAR2,
  		       X_Simple_Where_Name		VARCHAR2,
  		       X_Period_Query			VARCHAR2,
  		       X_Standard_Axis1_Id		NUMBER,
  		       X_Axis1_Operator			VARCHAR2,
                       X_Standard_Axis2_Id		NUMBER,
  		       X_Axis2_Operator			VARCHAR2,
                       X_Constant			NUMBER,
  		       X_Variance_Flag 			VARCHAR2,
		       X_Sign_Flag			VARCHAR2,
  		       X_Standard_Axis_Name		VARCHAR2,
 		       X_Description                    VARCHAR2,
		       X_Owner				VARCHAR2,
		       X_Force_Edits			VARCHAR2 ) IS

    user_id number := 0;
    v_creation_date date;
    v_rowid rowid := null;

  BEGIN
    /* Validate that primary key is not null */
    IF (X_Standard_Axis_Id IS NULL ) THEN
      fnd_message.set_name('SQLGL', 'GL_LOAD_ROW_NO_DATA');
      app_exception.raise_exception;
    END IF;

    /* Set user id for seeded data */
    IF (X_Owner = 'SEED') THEN
      user_id := 1;
    END IF;

    BEGIN

      /* Retrieve creation date from existing rows */
	SELECT creation_date, rowid
	INTO   v_creation_date, v_rowid
	FROM   RG_REPORT_STANDARD_AXES_B
	WHERE  Standard_Axis_Id = X_Standard_Axis_Id;

       /*
        * Update only if force_edits is 'Y' OR user_id is 'SEED'.
        */
	IF ( user_id = 1 or X_Force_Edits = 'Y' ) THEN
	  RG_REPORT_STANDARD_AXES_PKG.update_row(
            X_rowid                         => v_rowid,
	    X_application_id		    => X_Application_Id,
	    X_standard_axis_id		    => X_Standard_Axis_Id,
  	    X_standard_axis_name	    => X_Standard_Axis_Name,
	    X_last_update_date              => sysdate,
	    X_last_updated_by               => user_id,
	    X_last_update_login             => 0,
 	    X_class			    => X_Class,
            X_display_in_std_list_flag      => X_Display_In_Std_List_Flag,
            X_precedence_level		    => X_Precedence_Level,
  	    X_database_column		    => X_Database_Column,
  	    X_simple_where_name		    => X_Simple_Where_Name,
  	    X_period_query		    => X_Period_Query,
  	    X_standard_axis1_id		    => X_Standard_Axis1_Id,
  	    X_axis1_operator		    => X_Axis1_Operator,
            X_standard_axis2_id		    => X_Standard_Axis2_Id,
            X_axis2_operator		    => X_Axis2_Operator,
            X_constant			    => X_Constant,
            X_variance_flag 		    => X_Variance_Flag,
	    X_sign_flag		   	    => X_Sign_Flag,
 	    X_description                   => X_Description
          );
        END IF;

    EXCEPTION
    WHEN NO_DATA_FOUND THEN
	/*
	 * If the row doesn't exist yet, call Insert_Row().
         */
	RG_REPORT_STANDARD_AXES_PKG.insert_row(
            X_rowid                         => v_rowid,
	    X_application_id		    => X_Application_Id,
	    X_last_update_date              => sysdate,
	    X_last_updated_by               => user_id,
	    X_last_update_login             => 0,
	    X_creation_date                 => sysdate,
	    X_created_by                    => user_id,
	    X_standard_axis_id		    => X_Standard_Axis_Id,
  	    X_standard_axis_name	    => X_Standard_Axis_Name,
 	    X_class			    => X_Class,
            X_display_in_std_list_flag      => X_Display_In_Std_List_Flag,
            X_precedence_level		    => X_Precedence_Level,
  	    X_database_column		    => X_Database_Column,
  	    X_simple_where_name		    => X_Simple_Where_Name,
  	    X_period_query		    => X_Period_Query,
  	    X_standard_axis1_id		    => X_Standard_Axis1_Id,
  	    X_axis1_operator		    => X_Axis1_Operator,
            X_standard_axis2_id		    => X_Standard_Axis2_Id,
            X_axis2_operator		    => X_Axis2_Operator,
            X_constant			    => X_Constant,
            X_variance_flag 		    => X_Variance_Flag,
	    X_sign_flag		   	    => X_Sign_Flag,
 	    X_description                   => X_Description
        );
    END;

  END Load_Row;


  --
  -- Name
  --   Translate_Row
  -- Purpose
  --   Translate a row in RG_REPORT_STANDARD_AXES for NLS support
  --
  PROCEDURE Translate_Row (
                       X_Standard_Axis_Name VARCHAR2,
                       X_Description        VARCHAR2,
	               X_Standard_Axis_Id   NUMBER,
                       X_Owner              VARCHAR2,
	               X_Force_Edits        VARCHAR2
    ) IS

    user_id number := 0;

  BEGIN
    IF (X_OWNER = 'SEED') THEN
      user_id := 1;
    END IF;

    /*
     * Update only if force_edits is 'Y' OR user_id is 'SEED'.
     */
    IF ( user_id = 1 or X_Force_Edits = 'Y' ) THEN
 	UPDATE RG_REPORT_STANDARD_AXES_TL
        SET
	    standard_axis_name = X_Standard_Axis_Name,
	    description        = X_Description,
	    source_lang        = userenv('LANG'),
	    last_update_date   = sysdate,
            last_updated_by    = user_id,
            last_update_login  = 0
        WHERE
	    standard_axis_id = X_Standard_Axis_Id
	AND
            userenv('LANG')  IN (LANGUAGE, SOURCE_LANG);
        /*If base language is not set to the language being uploaded, then do nothing*/
        IF (SQL%NOTFOUND) THEN
          NULL;
        END IF;
    END IF;
END Translate_Row;

PROCEDURE ADD_LANGUAGE
is
begin

    UPDATE RG_REPORT_STANDARD_AXES_TL T
    set  ( standard_axis_name,
           description)
    =    ( select
                 B.standard_axis_name,
		 B.description
           from  rg_report_standard_axes_tl B
	   where B.standard_axis_id = T.standard_axis_id
	   and   B.language         = T.source_lang)
    where ( T.standard_axis_id,
            T.language ) in
           ( select
	         SUBT.standard_axis_id ,
		 SUBT.language
              from  rg_report_standard_axes_tl SUBB,
	            rg_report_standard_axes_tl SUBT
              where SUBB.standard_axis_id = SUBT.standard_axis_id
	      and   SUBB.language         =  SUBT.source_lang
	      and  (  SUBB.standard_axis_name <> SUBT.standard_axis_name
	             or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      		or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      		or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null))
  	);


 INSERT INTO RG_REPORT_STANDARD_AXES_TL
    (
      STANDARD_AXIS_ID,
      LANGUAGE,
      SOURCE_LANG,
      STANDARD_AXIS_NAME,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN,
      CREATION_DATE,
      CREATED_BY,
      DESCRIPTION
    )
    SELECT
            B.standard_axis_id,
            L.language_code,
            B.source_lang,
            B.standard_axis_name,
            B.last_update_date,
            B.last_updated_by,
            B.last_update_login,
            B.creation_date,
            B.created_by,
            B.description
    FROM   rg_report_standard_axes_tl B, FND_LANGUAGES L
    WHERE  L.installed_flag IN ('I', 'B')
    AND    B.language  = USERENV('LANG')
    AND NOT EXISTS
           ( SELECT NULL
	     FROM   RG_REPORT_STANDARD_AXES_TL R
	     WHERE  R.standard_axis_id   =  B.standard_axis_id
	     AND    R.language           =  L.language_code );

end ADD_LANGUAGE;

END RG_REPORT_STANDARD_AXES_PKG;

/
