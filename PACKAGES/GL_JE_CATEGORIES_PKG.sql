--------------------------------------------------------
--  DDL for Package GL_JE_CATEGORIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_JE_CATEGORIES_PKG" AUTHID CURRENT_USER AS
/*  $Header: glijects.pls 120.6 2005/05/05 01:09:34 kvora ship $  */
--
-- Package
--   GL_JE_CATEGORIES_PKG
-- Purpose
--   To create GL_JE_CATEGORIES_PKG package.
-- History
--   10.16.93   E. Rumanang   Created
--   28-MAR-94  D J Ogg       Added select_columns

  --
  -- Procedure
  --   check_unique
  -- Purpose
  --   Checks to make sure the given user_je_category_name
  --   is unique within gl_je_categories table.
  -- History
  --   10.16.93   E. Rumanang   Created
  -- Arguments
  --   x_rowid    The ID of the row to be checked
  --   x_name     The category name to be checked
  -- Example
  --   GL_JE_CATEGORIES_PKG.check_unique( '123:A:456', 'ALLOCATION' );
  -- Notes
  --
  PROCEDURE check_unique( x_rowid  VARCHAR2,
                          x_name   VARCHAR2 );

  --
  -- Procedure
  --   check_unique_key
  -- Purpose
  --   Checks to make sure the given je_category_key
  --   is unique within gl_je_categories table.
  -- History
  --   20-DEC-2004   D J Ogg   Created
  -- Arguments
  --   x_rowid    The ID of the row to be checked
  --   x_key      The category key to be checked
  -- Example
  --   GL_JE_CATEGORIES_PKG.check_unique_key( '123:A:456', 'ALLOCATION' );
  -- Notes
  --
  PROCEDURE check_unique_key( x_rowid  VARCHAR2,
                              x_key   VARCHAR2 );


  --
  -- Procedure
  --   get_unique_id
  -- Purpose
  --   Gets a unique id for a new category.
  -- History
  --   10.16.93   E. Rumanang   Created
  -- Arguments
  --   none
  -- Example
  --   je_category_name := GL_JE_CATEGORIES_PKG.get_unique_id;
  -- Notes
  --
  FUNCTION get_unique_id RETURN NUMBER;


  --
  -- Procedure
  --   insert_fnd_cat
  -- Purpose
  --   Insert into FND_DOC_SEQUENCE_CATEGORIES table for each
  --   new created category.
  -- History
  --   10.16.93   E. Rumanang   Created
  -- Arguments
  --   x_je_category_name         The category name id
  --   x_user_je_category_name    The user category name
  --   x_description              The description
  --   x_last_updated_by          The last person id who update the row
  --   x_created_by               The person id who create the row
  --   x_last_update_login        The person id who last login
  -- Example
  --   GL_JE_CATEGORIES_PKG.insert_fnd_cat(
  --     'id1', 'Allocation', 'alloc desc', 1, 1 );
  -- Notes
  --
  PROCEDURE insert_fnd_cat( x_je_category_name       VARCHAR2,
                            x_user_je_category_name  VARCHAR2,
                            x_description            VARCHAR2,
                            x_last_updated_by        NUMBER,
                            x_created_by             NUMBER,
                            x_last_update_login      NUMBER );


  --
  -- Procedure
  --   update_fnd_cat
  -- Purpose
  --   Update FND_DOC_SEQUENCE_CATEGORIES table for each
  --   new updated category.
  -- History
  --   10.16.93   E. Rumanang   Created
  -- Arguments
  --   x_je_category_name         The category name id
  --   x_user_je_category_name    The category name id
  --   x_description              The description
  --   x_last_updated_by          The last person id who update the row
  -- Example
  --   GL_JE_CATEGORIES_PKG.update_fnd_cat(
  --     'id1', 'alloc desc', 1 );
  -- Notes
  --

  PROCEDURE update_fnd_cat( x_je_category_name       VARCHAR2,
                            x_user_je_category_name  VARCHAR2,
                            x_description            VARCHAR2,
                            x_last_updated_by        NUMBER );



  -- Procedure
  --   update_fnd_cat_all
  -- Purpose
  --   Update FND_DOC_SEQUENCE_CATEGORIES table for all
  --   new updated categories. Only categories with new
  --   user_je_category_name defined in the base language
  --   will be updated.
  -- History
  --   07-14-99   M C Hui   Created
  -- Arguments
  --   x_last_updated_by          The last person id who update the row
  -- Example
  --   GL_JE_CATEGORIES_PKG.update_fnd_cat(1);
  -- Notes
  --

  PROCEDURE update_fnd_cat_all( x_last_updated_by        NUMBER );


  --
  -- Procedure
  --   insert_other_cat
  -- Purpose
  --   insert other tables which has journal category as its key column.
  -- History
  --   06-JUN-98   Charmaine Wang   Created

  PROCEDURE insert_other_cat( x_je_category_name       VARCHAR2,
                            x_user_je_category_name  VARCHAR2,
                            x_description            VARCHAR2,
                            x_last_updated_by        NUMBER,
                            x_created_by             NUMBER,
                            x_last_update_login      NUMBER );


  --
  -- Procedure
  --   select_columns
  -- Purpose
  --   Used to select the user_je_category_name for a given je_category_name
  -- History
  --   28-MAR-93  D. J. Ogg    Created
  -- Arguments
  --   x_je_category_name		Category name to be found
  --   x_user_je_category_name		User name for the category
  -- Example
  --   gl_je_categories_pkg.select_columns('Budget', user_name);
  -- Notes
  --
  PROCEDURE select_columns(
			x_je_category_name		       VARCHAR2,
			x_user_je_category_name		IN OUT NOCOPY VARCHAR2 );

  --
  -- Procedure
  --  Load_Row
  -- Purpose
  --   Called from loader config file to upload a multi-lingual entity
  -- History
  --   07-12-99  M C Hui        Created
  -- Arguments
  -- all the columns of the view GL_JE_CATEGORIES
  -- Example
  --   gl_je_categories_pkg.Load_Row(....;
  -- Notes
  --
  PROCEDURE Load_Row(
                     X_Je_Category_Name           IN OUT NOCOPY   VARCHAR2,
                     X_Je_Category_Key                     VARCHAR2,
                     X_User_Je_Category_Name               VARCHAR2,
                     X_Description                         VARCHAR2,
                     X_Attribute1                          VARCHAR2,
                     X_Attribute2                          VARCHAR2,
                     X_Attribute3                          VARCHAR2,
                     X_Attribute4                          VARCHAR2,
                     X_Attribute5                          VARCHAR2,
                     X_Context                             VARCHAR2,
                     X_Owner                               VARCHAR2,
		     X_Force_Edits			   VARCHAR2);


  --
  -- Procedure
  --  Translate_Row
  -- Purpose
  --  Called from loader config file to upload translations.
  -- History
  --   07-12-99  M C Hui        Created
  -- Arguments
  --   X_Je_Category_Name       Journal entry category name
  --   X_User_Je_Category_Name  Journal entry category user defined name
  --   X_Description            Journal entry category description
  --   X_Owner
  -- Example
  --   gl_je_category_pkg.Translate_Row(
  --    'Adjustment', 'Adjustment', 'SEED', 'Adjustment Journal Entry');
  -- Notes
  --
  PROCEDURE Translate_Row(
                     X_Je_Category_Name                    VARCHAR2,
                     X_User_Je_Category_Name               VARCHAR2,
                     X_Description                         VARCHAR2,
                     X_Owner                               VARCHAR2,
		     X_Force_Edits			   VARCHAR2 );

  --
  -- Procedure
  --  Add_Language
  -- Purpose
  --   To add a new language row to the gl_je_categories_b
  -- History
  --   24-NOV-98  M C Hui	Created
  -- Arguments
  -- 	None
  -- Example
  --   gl_je_categories_pkg.Add_Language(....;
  -- Notes
  --
procedure ADD_LANGUAGE;


  --
  -- Procedure
  --  Insert_Row
  -- Purpose
  --   Insert rows into gl_je_categories_tl
  --   Added for the Consolidation Enhancements projects.
  -- History
  --   16-AUG-01  O Monnier	Created
  -- Arguments
  --   All the columns of the table GL_JE_CATEGORIES_TL
  -- Example
  --   gl_je_categories_pkg.Insert_Row(....;
  -- Notes
  --
  PROCEDURE Insert_Row(X_Rowid               IN OUT NOCOPY   VARCHAR2,
                       X_Je_Category_Name    IN OUT NOCOPY   VARCHAR2,
                       X_Language            IN OUT NOCOPY   VARCHAR2,
                       X_Source_Lang         IN OUT NOCOPY   VARCHAR2,
                       X_Last_Update_Date                    DATE,
                       X_Last_Updated_By                     NUMBER,
                       X_User_Je_Category_Name               VARCHAR2,
                       X_Je_Category_Key                     VARCHAR2,
                       X_Creation_Date                       DATE,
                       X_Created_By                          NUMBER,
                       X_Last_Update_Login                   NUMBER,
                       X_Description                         VARCHAR2,
                       X_Attribute1                          VARCHAR2,
                       X_Attribute2                          VARCHAR2,
                       X_Attribute3                          VARCHAR2,
                       X_Attribute4                          VARCHAR2,
                       X_Attribute5                          VARCHAR2,
                       X_Context                             VARCHAR2,
                       X_Consolidation_Flag                  VARCHAR2);

  --
  -- Procedure
  --  Update_Row
  -- Purpose
  --   Updates a row into gl_je_categories_tl
  --   Added for the Consolidation Enhancements projects.
  -- History
  --   16-AUG-01  O Monnier 	Created
  -- Arguments
  --   All the columns of the table GL_JE_CATEGORIES_TL
  -- Example
  --   gl_je_categories_pkg.Update_Row(....;
  -- Notes
  --
  PROCEDURE Update_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
                       X_Je_Category_Name                    VARCHAR2,
                       X_Last_Update_Date                    DATE,
                       X_Last_Updated_By                     NUMBER,
                       X_User_Je_Category_Name               VARCHAR2,
                       X_Je_Category_Key	             VARCHAR2,
                       X_Creation_Date                       DATE,
                       X_Last_Update_Login                   NUMBER,
                       X_Description                         VARCHAR2,
                       X_Attribute1                          VARCHAR2,
                       X_Attribute2                          VARCHAR2,
                       X_Attribute3                          VARCHAR2,
                       X_Attribute4                          VARCHAR2,
                       X_Attribute5                          VARCHAR2,
                       X_Context                             VARCHAR2,
                       X_Consolidation_Flag                  VARCHAR2);

  --
  -- Procedure
  --  Lock_Row
  -- Purpose
  --   Locks a row into gl_je_categories_tl
  --   Added for the Consolidation Enhancements projects.
  -- History
  --   16-AUG-01  O Monnier	Created
  -- Arguments
  --   All the columns of the table GL_JE_CATEGORIES_TL
  -- Example
  --   gl_je_categories_pkg.Lock_Row(....;
  -- Notes
  --
  PROCEDURE Lock_Row(X_Rowid                 IN OUT NOCOPY VARCHAR2,
                     X_Je_Category_Name                    VARCHAR2,
                     X_User_Je_Category_Name               VARCHAR2,
                     X_Je_Category_Key                     VARCHAR2,
                     X_Description                         VARCHAR2,
                     X_Attribute1                          VARCHAR2,
                     X_Attribute2                          VARCHAR2,
                     X_Attribute3                          VARCHAR2,
                     X_Attribute4                          VARCHAR2,
                     X_Attribute5                          VARCHAR2,
                     X_Context                             VARCHAR2,
                     X_Consolidation_Flag                  VARCHAR2);


END GL_JE_CATEGORIES_PKG;

 

/
