--------------------------------------------------------
--  DDL for Package GL_AUTOPOST_SETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_AUTOPOST_SETS_PKG" AUTHID CURRENT_USER AS
/* $Header: glistass.pls 120.4 2005/05/05 01:22:35 kvora ship $ */
--
-- Package
--   gl_autopost_sets_pkg
-- Purpose
--   To contain validation and insertion routines for
--   gl_automatic_posting_sets
  --
  -- Procedure
  --   check_unique
  -- Purpose
  --   Checks to make sure that the autopost set name is unique for the
  --   chart of accounts, calendar and period type combination.
  -- Arguments
  --   x_autopost_set_id	The autopost set ID
  --   x_chart_of_accounts_id   The chart of accounts ID
  --   x_period_set_name     	The period set name
  --   x_accounted_period_type	The accounted period type
  --   row_id			The current rowid
  --
PROCEDURE check_unique(x_autopost_set_name                   VARCHAR2,
		       x_chart_of_accounts_id                NUMBER,
                       x_period_set_name                     VARCHAR2,
                       x_accounted_period_type               VARCHAR2,
		       row_id VARCHAR2);

PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
		     X_Autopost_Set_Id         IN OUT NOCOPY NUMBER,
                     X_Autopost_Set_Name                     VARCHAR2,
                     X_Chart_Of_Accounts_Id                  NUMBER,
                     X_Period_Set_Name                       VARCHAR2,
                     X_Accounted_Period_Type                 VARCHAR2,
                     X_Enabled_Flag                          VARCHAR2,
                     X_Security_Flag                         VARCHAR2,
                     X_Submit_All_Priorities_Flag            VARCHAR2,
                     X_Last_Update_Date                      DATE,
                     X_Last_Updated_By                       NUMBER,
                     X_Creation_Date                         DATE,
                     X_Created_By                            NUMBER,
                     X_Last_Update_Login                     NUMBER,
                     X_Description                           VARCHAR2,
                     X_Num_Of_Priority_Options               NUMBER,
                     X_Effective_Days_Before                 NUMBER,
                     X_Effective_Days_After                  NUMBER,
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

PROCEDURE   Lock_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                     X_Autopost_Set_ID         IN OUT NOCOPY NUMBER,
                     X_Autopost_Set_Name                     VARCHAR2,
                     X_Chart_Of_Accounts_Id                  NUMBER,
                     X_Period_Set_Name                       VARCHAR2,
                     X_Accounted_Period_Type                 VARCHAR2,
                     X_Enabled_Flag                          VARCHAR2,
                     X_Security_Flag                         VARCHAR2,
                     X_Submit_All_Priorities_Flag            VARCHAR2,
                     X_Description                           VARCHAR2,
                     X_Num_Of_Priority_Options               NUMBER,
                     X_Effective_Days_Before                 NUMBER,
                     X_Effective_Days_After                  NUMBER,
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

PROCEDURE Update_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                     X_Autopost_Set_ID         IN OUT NOCOPY NUMBER,
                     X_Autopost_Set_Name                     VARCHAR2,
                     X_Chart_Of_Accounts_Id                  NUMBER,
                     X_Period_Set_Name                       VARCHAR2,
                     X_Accounted_Period_Type                 VARCHAR2,
                     X_Enabled_Flag                          VARCHAR2,
                     X_Security_Flag                         VARCHAR2,
                     X_Submit_All_Priorities_Flag            VARCHAR2,
                     X_Last_Update_Date                      DATE,
                     X_Last_Updated_By                       NUMBER,
                     X_Last_Update_Login                     NUMBER,
                     X_Creation_Date                         DATE,
                     X_Created_By                            NUMBER,
                     X_Description                           VARCHAR2,
                     X_Num_Of_Priority_Options               NUMBER,
                     X_Effective_Days_Before                 NUMBER,
                     X_Effective_Days_After                  NUMBER,
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

PROCEDURE Delete_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
		     X_Autopost_Set_Id         IN OUT NOCOPY NUMBER);

  --
  -- Procedure
  -- submit_request
  -- Purpose
  --    To submit concurrent request
  -- Arguments:
  --	X_access_set_id          NUMBER,
  --	X_autopost_set_id	 NUMBER

    FUNCTION submit_request (
	X_access_set_id 	NUMBER,
	X_autopost_set_id	NUMBER ) RETURN NUMBER;

END gl_autopost_sets_pkg;

 

/
