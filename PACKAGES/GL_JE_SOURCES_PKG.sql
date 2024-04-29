--------------------------------------------------------
--  DDL for Package GL_JE_SOURCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_JE_SOURCES_PKG" AUTHID CURRENT_USER AS
/* $Header: glijesrs.pls 120.4 2004/12/22 00:21:55 djogg ship $ */
--
-- Package
--   gl_je_sources_pkg
-- Purpose
--   To contain validation and insertion routines for gl_je_sources
-- History
--   12-21-93  	D. J. Ogg	Created

  --
  -- Procedure
  --   select_columns
  -- Purpose
  --   Used to select the user_je_source_name for a given je_source_name
  -- History
  --   12-21-93  D. J. Ogg    Created
  -- Arguments
  --   x_je_source_name			Source name to be found
  --   x_user_je_source_name		User name for the source
  -- Example
  --   gl_je_sources_pkg.select_columns('Recurring', user_name);
  -- Notes
  --
  PROCEDURE select_columns(
			x_je_source_name		       VARCHAR2,
			x_user_je_source_name		IN OUT NOCOPY VARCHAR2,
			x_effective_date_rule_code	IN OUT NOCOPY VARCHAR2,
		    	x_frozen_source_flag		IN OUT NOCOPY VARCHAR2,
                        x_journal_approval_flag         IN OUT NOCOPY VARCHAR2);

  --
  -- Procedure
  --   check_unique_name
  -- Purpose
  --   Checks to make sure that je_source_name is unique.
  -- History
  --   06-23-94  Kai Pigg	Created
  -- Arguments
  --   x_je_source_name		Name of Journal Entry Source (Hidden Id)
  --   row_id           	The row ID
  -- Example
  --   gl_je_sources_pkg.check_unique('1', 'ABD02334');
  -- Notes
  --
  PROCEDURE check_unique_name(x_je_source_name VARCHAR2,
                              x_row_id VARCHAR2);

  --
  -- Procedure
  --   check_unique_user_name
  -- Purpose
  --   Checks to make sure that user_je_source_name is unique.
  -- History
  --   06-23-94  Kai Pigg	Created
  -- Arguments
  --   x_user_je_source_name	Name of Journal Entry Source (Displayed)
  --   row_id           	The row ID
  -- Example
  --   gl_je_sources_pkg.check_unique('Testing', 'ABD02334');
  -- Notes
  --
  PROCEDURE check_unique_user_name(x_user_je_source_name VARCHAR2,
                                   x_row_id VARCHAR2);

  --
  -- Procedure
  --   check_unique_key
  -- Purpose
  --   Checks to make sure that je_source_key is unique.
  -- History
  --   21-DEC-2004  Kai Pigg	Created
  -- Arguments
  --   x_je_source_key		Journal source key
  --   row_id           	The row ID
  -- Example
  --   gl_je_sources_pkg.check_unique('Testing', 'ABD02334');
  -- Notes
  --
  PROCEDURE check_unique_key(x_je_source_key VARCHAR2,
                             x_row_id VARCHAR2);

  --
  -- Procedure
  --   get_unique_id
  -- Purpose
  --   Gets a unique header id
  -- History
  --   06-22-94  Kai Pigg	Created
  -- Arguments
  --   none
  -- Example
  --   bid := gl_je_sources_pkg.get_unique_id;
  -- Notes
  --
  FUNCTION get_unique_id RETURN NUMBER;


  --
  -- Procedure
  --   is_sla_source
  -- Purpose
  --   Returns TRUE if this is an SLA source
  --   and FALSE otherwise
  -- History
  --   11-20-03		D J Ogg		Created
  -- Arguments
  --   X_je_source	Source name
  -- Example
  --   IF (gl_je_sources_pkg.is_sla_source('Payables'))
  -- Notes
  --
  FUNCTION is_sla_source(X_je_source VARCHAR2) RETURN BOOLEAN;


  --
  -- Procedure
  --  Insert_Row
  -- Purpose
  --   Inserts a row into gl_je_sources
  -- History
  --   06-22-94  Kai Pigg	Created
  -- Arguments
  -- all the columns of the table GL_JE_SOURCES
  -- Example
  --   gl_je_sources_pkg.Insert_Row(....;
  -- Notes
  --
  PROCEDURE Insert_Row(X_Rowid                    IN OUT NOCOPY   VARCHAR2,
                     X_Je_Source_Name             IN OUT NOCOPY   VARCHAR2,
                     X_Language	                  IN OUT NOCOPY   VARCHAR2,
                     X_Source_Lang                IN OUT NOCOPY   VARCHAR2,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Override_Edits_Flag                 VARCHAR2,
                     X_User_Je_Source_Name                 VARCHAR2,
                     X_Je_Source_Key                       VARCHAR2,
                     X_Journal_Reference_Flag              VARCHAR2,
                     X_Journal_Approval_Flag               VARCHAR2,
                     X_Effective_Date_Rule_Code            VARCHAR2,
                     X_Import_Using_Key_Flag               VARCHAR2,
                     X_Creation_Date                       DATE,
                     X_Last_Update_Login                   NUMBER,
                     X_Description                         VARCHAR2,
                     X_Attribute1                          VARCHAR2,
                     X_Attribute2                          VARCHAR2,
                     X_Attribute3                          VARCHAR2,
                     X_Attribute4                          VARCHAR2,
                     X_Attribute5                          VARCHAR2,
                     X_Context                             VARCHAR2);

  --
  -- Procedure
  --  Update_Row
  -- Purpose
  --   Updates a row into gl_je_sources
  -- History
  --   06-22-94  Kai Pigg	Created
  -- Arguments
  -- all the columns of the table GL_JE_SOURCES
  -- Example
  --   gl_je_sources_pkg.Update_Row(....;
  -- Notes
  --
  PROCEDURE Update_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
                     X_Je_Source_Name                      VARCHAR2,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Override_Edits_Flag                 VARCHAR2,
                     X_User_Je_Source_Name                 VARCHAR2,
                     X_Je_Source_Key                       VARCHAR2,
                     X_Journal_Reference_Flag              VARCHAR2,
  		     X_Journal_Approval_Flag               VARCHAR2,
                     X_Effective_Date_Rule_Code            VARCHAR2,
                     X_Import_Using_Key_Flag               VARCHAR2,
                     X_Creation_Date                       DATE,
                     X_Last_Update_Login                   NUMBER,
                     X_Description                         VARCHAR2,
                     X_Attribute1                          VARCHAR2,
                     X_Attribute2                          VARCHAR2,
                     X_Attribute3                          VARCHAR2,
                     X_Attribute4                          VARCHAR2,
                     X_Attribute5                          VARCHAR2,
                     X_Context                             VARCHAR2);

  --
  -- Procedure
  --  Lock_Row
  -- Purpose
  --   Locks a row into gl_je_sources
  -- History
  --   06-22-94  Kai Pigg	Created
  -- Arguments
  -- all the columns of the table GL_JE_SOURCES
  -- Example
  --   gl_je_sources_pkg.Lock_Row(....;
  -- Notes
  --
  PROCEDURE Lock_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
                     X_Je_Source_Name                      VARCHAR2,
                     X_Override_Edits_Flag                 VARCHAR2,
                     X_User_Je_Source_Name                 VARCHAR2,
                     X_Je_Source_Key                       VARCHAR2,
                     X_Journal_Reference_Flag              VARCHAR2,
                     X_Journal_Approval_Flag               VARCHAR2,
                     X_Effective_Date_Rule_Code            VARCHAR2,
                     X_Import_Using_Key_Flag               VARCHAR2,
                     X_Description                         VARCHAR2,
                     X_Attribute1                          VARCHAR2,
                     X_Attribute2                          VARCHAR2,
                     X_Attribute3                          VARCHAR2,
                     X_Attribute4                          VARCHAR2,
                     X_Attribute5                          VARCHAR2,
                     X_Context                             VARCHAR2);
  --
  -- Procedure
  --  Delete_Row
  -- Purpose
  --   Deletes a row from gl_je_sources
  -- History
  --   06-22-94  Kai Pigg	Created
  -- Arguments
  -- 	x_rowid		Rowid of a row
  -- Example
  --   gl_je_sources_pkg.delete_row('ajfdshj');
  -- Notes
  --
  PROCEDURE Delete_Row(X_Je_Source_Name VARCHAR2);


  --
  -- Procedure
  --  Load_Row
  -- Purpose
  --   Called from loader config file to upload a multi-lingual entity
  -- History
  --   07-07-99  M C Hui	Created
  -- Arguments
  -- all the columns of the view GL_JE_SOURCES
  -- Example
  --   gl_je_sources_pkg.Load_Row(....;
  -- Notes
  --
  PROCEDURE Load_Row(
                     X_Je_Source_Name             IN OUT NOCOPY   VARCHAR2,
                     X_Override_Edits_Flag                 VARCHAR2,
                     X_User_Je_Source_Name                 VARCHAR2,
                     X_Je_Source_Key                       VARCHAR2,
                     X_Journal_Reference_Flag              VARCHAR2,
                     X_Journal_Approval_Flag               VARCHAR2,
                     X_Effective_Date_Rule_Code            VARCHAR2,
                     X_Import_Using_Key_Flag               VARCHAR2,
                     X_Description                         VARCHAR2,
                     X_Attribute1                          VARCHAR2,
                     X_Attribute2                          VARCHAR2,
                     X_Attribute3                          VARCHAR2,
                     X_Attribute4                          VARCHAR2,
                     X_Attribute5                          VARCHAR2,
                     X_Context                             VARCHAR2,
		     X_Owner				   VARCHAR2,
		     X_Force_Edits			   VARCHAR2 );

  --
  -- Procedure
  --  Translate_Row
  -- Purpose
  --  Called from loader config file to upload translations.
  -- History
  --   07-07-99  M C Hui	Created
  -- Arguments
  --   X_Je_Source_Name		Journal entry source name
  --   X_User_Je_Source_Name	Journal entry source user defined name
  --   X_Description		Journal entry source description
  --   X_Owner			Can be 'SEED' or other values
  --   X_Force_Edits		Force update to be performed
  -- Example
  --   gl_je_sources_pkg.Translate_Row(
  --	'Assets', 'Assets', 'SEED', 'Fixed Assets System');
  -- Notes
  --
  PROCEDURE Translate_Row(
                     X_Je_Source_Name                      VARCHAR2,
                     X_User_Je_Source_Name                 VARCHAR2,
                     X_Description                         VARCHAR2,
		     X_Owner				   VARCHAR2,
		     X_Force_Edits			   VARCHAR2 );

  --
  -- Procedure
  --  Add_Language
  -- Purpose
  --   To add a new language row to the gl_je_categories_b
  -- History
  --   24-NOV-98  M C Hui       Created
  -- Arguments
  --    None
  -- Example
  --   gl_je_categories_pkg.Add_Language(....;
  -- Notes
  --
procedure ADD_LANGUAGE;


END
GL_JE_SOURCES_PKG;

 

/
