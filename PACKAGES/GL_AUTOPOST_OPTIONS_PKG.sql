--------------------------------------------------------
--  DDL for Package GL_AUTOPOST_OPTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_AUTOPOST_OPTIONS_PKG" AUTHID CURRENT_USER AS
/* $Header: glistaps.pls 120.4 2005/05/05 01:22:21 kvora ship $ */
--
-- Package
--   gl_autopost_options_pkg
-- Purpose
--   To contain validation and insertion routines for
--   gl_automatic_posting_options
-- History
--   10-20-93  	D. J. Ogg	Created

  --
  -- Procedure
  --   check_unique
  -- Purpose
  --   Checks to make sure that the ledger, period name, source, category and
  --   actual flag combination is unique for the autopost set.
  -- History
  --   10-20-93  D. J. Ogg    Created
  --   07-24-97  U. Thimmappa Modified to include Release 11 changes.
  --   12-30-02  K  Vora      Ledger Architecture changes
  -- Arguments
  --   x_autopost_set_id	The autopost set ID
  --   x_ledger_id              The ledger ID
  --   x_actual_flag		The actual flag
  --   x_period_name		The name of the period
  --   x_source_name  	  	The name of the journal source
  --   x_category_name    	The name of the category
  --   row_id			The current rowid
  --

  PROCEDURE check_unique(x_autopost_set_id NUMBER,
                         x_ledger_id     NUMBER,
			 x_actual_flag   VARCHAR2,
			 x_period_name   VARCHAR2,
			 x_source_name   VARCHAR2,
			 x_category_name VARCHAR2,
			 row_id VARCHAR2);

PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                     X_Autopost_Set_Id                       NUMBER,
                     X_Ledger_Id                             NUMBER,
                     X_Actual_Flag                           VARCHAR2,
                     X_Period_Name                           VARCHAR2,
                     X_Je_Source_Name                        VARCHAR2,
                     X_Je_Category_Name                      VARCHAR2,
                     X_Posting_Priority                      NUMBER,
                     X_Last_Update_Date                      DATE,
                     X_Last_Updated_By                       NUMBER,
                     X_Creation_Date                         DATE,
                     X_Created_By                            NUMBER,
                     X_Last_Update_Login                     NUMBER,
                     X_Attribute1                            VARCHAR2,
                     X_Attribute2                            VARCHAR2,
                     X_Attribute3                            VARCHAR2,
                     X_Attribute4                            VARCHAR2,
                     X_Attribute5                            VARCHAR2,
                     X_Attribute6                            VARCHAR2,
                     X_Attribute7                            VARCHAR2,
                     X_Attribute8                            VARCHAR2,
                     X_Attribute9                            VARCHAR2,
                     X_Attribute10                           VARCHAR2,
                     X_Attribute11                           VARCHAR2,
                     X_Attribute12                           VARCHAR2,
                     X_Attribute13                           VARCHAR2,
                     X_Attribute14                           VARCHAR2,
                     X_Attribute15                           VARCHAR2,
                     X_Context                               VARCHAR2
                     );

PROCEDURE Lock_Row(X_Rowid                                   VARCHAR2,
                   X_Autopost_Set_ID                         NUMBER,
                   X_Ledger_Id                               NUMBER,
                   X_Actual_Flag                             VARCHAR2,
                   X_Period_Name                             VARCHAR2,
                   X_Je_Source_Name                          VARCHAR2,
                   X_Je_Category_Name                        VARCHAR2,
                   X_Posting_Priority                        NUMBER,
                   X_Attribute1                              VARCHAR2,
                   X_Attribute2                              VARCHAR2,
                   X_Attribute3                              VARCHAR2,
                   X_Attribute4                              VARCHAR2,
                   X_Attribute5                              VARCHAR2,
                   X_Attribute6                              VARCHAR2,
                   X_Attribute7                              VARCHAR2,
                   X_Attribute8                              VARCHAR2,
                   X_Attribute9                              VARCHAR2,
                   X_Attribute10                             VARCHAR2,
                   X_Attribute11                             VARCHAR2,
                   X_Attribute12                             VARCHAR2,
                   X_Attribute13                             VARCHAR2,
                   X_Attribute14                             VARCHAR2,
                   X_Attribute15                             VARCHAR2,
                   X_Context                                 VARCHAR2
                   );

PROCEDURE Update_Row(X_Rowid                                 VARCHAR2,
                     X_Autopost_Set_ID                       NUMBER,
                     X_Ledger_Id                             NUMBER,
                     X_Actual_Flag                           VARCHAR2,
                     X_Period_Name                           VARCHAR2,
                     X_Je_Source_Name                        VARCHAR2,
                     X_Je_Category_Name                      VARCHAR2,
                     X_Posting_Priority                      NUMBER,
                     X_Last_Update_Date                      DATE,
                     X_Last_Updated_By                       NUMBER,
                     X_Last_Update_Login                     NUMBER,
                     X_Attribute1                            VARCHAR2,
                     X_Attribute2                            VARCHAR2,
                     X_Attribute3                            VARCHAR2,
                     X_Attribute4                            VARCHAR2,
                     X_Attribute5                            VARCHAR2,
                     X_Attribute6                            VARCHAR2,
                     X_Attribute7                            VARCHAR2,
                     X_Attribute8                            VARCHAR2,
                     X_Attribute9                            VARCHAR2,
                     X_Attribute10                           VARCHAR2,
                     X_Attribute11                           VARCHAR2,
                     X_Attribute12                           VARCHAR2,
                     X_Attribute13                           VARCHAR2,
                     X_Attribute14                           VARCHAR2,
                     X_Attribute15                           VARCHAR2,
                     X_Context                               VARCHAR2
                     );

PROCEDURE Delete_Row(X_Rowid VARCHAR2);

END gl_autopost_options_pkg;

 

/
