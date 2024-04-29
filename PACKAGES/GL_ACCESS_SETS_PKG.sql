--------------------------------------------------------
--  DDL for Package GL_ACCESS_SETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_ACCESS_SETS_PKG" AUTHID CURRENT_USER AS
/* $Header: glistaxs.pls 120.7 2005/05/05 01:22:48 kvora ship $ */
--
-- Package
--   gl_access_sets_pkg
-- Purpose
--   Server routines related to table gl_access_sets
-- History
--   02/19/2001   T Cheng      Created

  --
  -- Function
  --   get_unique_id
  -- Purpose
  --   retrieves the unique access set id from sequence gl_access_sets_s
  -- History
  --   02-19-2001   T Cheng      Created
  -- Arguments
  --   None
  -- Notes
  --
  FUNCTION get_unique_id RETURN NUMBER;

  --
  -- Function
  --   has_details_in_db
  -- Purpose
  --   checks whether there are access details for the access set
  --   in the database
  -- History
  --   02-19-2001   T Cheng      Created
  -- Arguments
  --   X_Access_Set_Id       access set id
  -- Notes
  --
  FUNCTION has_details_in_db (X_Access_Set_Id  NUMBER) RETURN BOOLEAN;

  --
  -- Function
  --   maintain_def_ledger_assign
  -- Purpose
  --   Check if a default ledger detail is assigned to the data access set.
  --   Insert the assignment if necessary and return TRUE, else return FALSE.
  -- History
  --   08-29-2003    T Cheng      Created
  -- Arguments
  --   X_Access_Set_Id       accesst set id
  -- Notes
  --
  FUNCTION maintain_def_ledger_assign(X_Access_Set_Id NUMBER) RETURN BOOLEAN;

  --
  -- Function
  --   get_value_set_id
  -- Purpose
  --   get the value set id for the given chart of account and segment
  -- History
  --   02-19-2001   T Cheng      Created
  -- Arguments
  --   X_Access_Set_Id       access set id
  --   X_Segment_Type        segment qualifier name
  -- Notes
  --
  FUNCTION get_value_set_id(X_Chart_Of_Accounts_Id   NUMBER,
                            X_Segment_Type           VARCHAR2) RETURN NUMBER;

  --
  -- Procedure
  --   select_columns
  -- Purpose
  --   Used to select data for a given access_set_id.
  -- History
  --   06-26-2001    T Cheng   Created
  -- Arguments
  --   X_access_set_id		Id of access set to be found
  --   X_name			Name of the access set
  --   X_security_segment_code	Security segment code
  --   X_coa_id			Chart of accounts id
  --   X_period_set_name	Period set name
  --   X_accounted_period_type  Accounted period type
  --   X_auto_created_flag      Automatically created flag
  -- Notes
  --
  PROCEDURE select_columns(X_access_set_id			 NUMBER,
			   X_name		   IN OUT NOCOPY VARCHAR2,
			   X_security_segment_code IN OUT NOCOPY VARCHAR2,
			   X_coa_id		   IN OUT NOCOPY NUMBER,
			   X_period_set_name	   IN OUT NOCOPY VARCHAR2,
			   X_accounted_period_type IN OUT NOCOPY VARCHAR2,
			   X_auto_created_flag	   IN OUT NOCOPY VARCHAR2);

  --
  -- Function
  --   Create_Implicit_Access_Set
  -- Purpose
  --   Create implicit access set for ledgers created.
  -- History
  --   04-27-2001    T Cheng	Added. Code provided by O Monnier.
  --   10-15-2001    T Cheng    Added X_Security_Segment_Code and
  --                            X_Secured_Seg_Value_Set_Id.
  --   11-09-2001    T Cheng    Added parameter X_default_ledger_id.
  -- Arguments
  --   X_Name				access set name
  --   X_Security_Segment_Code          security segment code
  --   X_Chart_Of_Accounts_Id		chart of accounts id
  --   X_Period_Set_Name		period set name
  --   X_Accounted_Period_Type		accounted period type
  --   X_Secured_Seg_Value_Set_Id       security segment value set id
  --   X_default_ledger_id              default ledger id
  --   X_Last_Updated_By		created by/initial last updated by
  --   X_Last_Update_Login		last update login
  --   X_Creation_Date			creation date/initial last update date
  --   X_Description			description
  -- Notes
  --
  FUNCTION Create_Implicit_Access_Set(
		X_Name                     VARCHAR2,
		X_Security_Segment_Code    VARCHAR2,
		X_Chart_Of_Accounts_Id     NUMBER,
		X_Period_Set_Name          VARCHAR2,
		X_Accounted_Period_Type    VARCHAR2,
		X_Secured_Seg_Value_Set_Id NUMBER,
                X_Default_Ledger_Id        NUMBER,
		X_Last_Updated_By          NUMBER,
		X_Last_Update_Login        NUMBER,
		X_Creation_Date            DATE,
		X_Description              VARCHAR2) RETURN NUMBER;

  --
  -- Function
  --   Update_Implicit_Access_Set
  -- Purpose
  --   Update the Implicit Access Set Name when the Ledger Name is updated.
  -- History
  --   10-14-2002    O Monnier	Added.
  -- Arguments
  --   X_Access_Set_Id                  implicit access set ID
  --   X_Name				access set name
  --   X_Last_update_Date               last update date
  --   X_Last_Updated_By		created by/initial last updated by
  --   X_Last_Update_Login		last update login
  -- Notes
  --
  PROCEDURE Update_Implicit_Access_Set(X_Access_Set_Id            NUMBER,
                                       X_Name                     VARCHAR2,
                                       X_Last_Update_Date         DATE,
                                       X_Last_Updated_By          NUMBER,
                                       X_Last_Update_Login        NUMBER);

  --
  -- Procedure
  --   Insert_Row
  -- Purpose
  --   used to insert an access set row
  -- History
  --   02-19-2001   T Cheng      Created
  --   11-12-2001   T Cheng      Add X_Default_Ledger_Id
  -- Notes
  --
  PROCEDURE Insert_Row(
                       X_Rowid         IN OUT NOCOPY VARCHAR2,
                       X_Access_Set_Id               NUMBER,
                       X_Name                        VARCHAR2,
                       X_Security_Segment_Code       VARCHAR2,
                       X_Enabled_Flag                VARCHAR2,
                       X_Chart_Of_Accounts_Id        NUMBER,
                       X_Period_Set_Name             VARCHAR2,
                       X_Accounted_Period_Type       VARCHAR2,
                       X_Automatically_Created_Flag  VARCHAR2,
		       X_Secured_Seg_Value_Set_Id    NUMBER,
		       X_Default_Ledger_Id           NUMBER,
                       X_User_Id                     NUMBER,
                       X_Login_Id                    NUMBER,
                       X_Date                        DATE,
                       X_Description                 VARCHAR2 DEFAULT NULL,
                       X_Context                     VARCHAR2 DEFAULT NULL,
                       X_Attribute1                  VARCHAR2 DEFAULT NULL,
                       X_Attribute2                  VARCHAR2 DEFAULT NULL,
                       X_Attribute3                  VARCHAR2 DEFAULT NULL,
                       X_Attribute4                  VARCHAR2 DEFAULT NULL,
                       X_Attribute5                  VARCHAR2 DEFAULT NULL,
                       X_Attribute6                  VARCHAR2 DEFAULT NULL,
                       X_Attribute7                  VARCHAR2 DEFAULT NULL,
                       X_Attribute8                  VARCHAR2 DEFAULT NULL,
                       X_Attribute9                  VARCHAR2 DEFAULT NULL,
                       X_Attribute10                 VARCHAR2 DEFAULT NULL,
                       X_Attribute11                 VARCHAR2 DEFAULT NULL,
                       X_Attribute12                 VARCHAR2 DEFAULT NULL,
                       X_Attribute13                 VARCHAR2 DEFAULT NULL,
                       X_Attribute14                 VARCHAR2 DEFAULT NULL,
                       X_Attribute15                 VARCHAR2 DEFAULT NULL);

  --
  -- Procedure
  --   Update_Row
  -- Purpose
  --   used to update an access set row
  -- History
  --   02-19-2001   T Cheng      Created
  --   11-12-2001   T Cheng      Add X_Default_Ledger_Id
  -- Notes
  --
  PROCEDURE Update_Row(
                       X_Rowid                       VARCHAR2,
                       X_Access_Set_Id               NUMBER,
                       X_Name                        VARCHAR2,
                       X_Security_Segment_Code       VARCHAR2,
                       X_Enabled_Flag                VARCHAR2,
                       X_Chart_Of_Accounts_Id        NUMBER,
                       X_Period_Set_Name             VARCHAR2,
                       X_Accounted_Period_Type       VARCHAR2,
                       X_Automatically_Created_Flag  VARCHAR2,
		       X_Secured_Seg_Value_Set_Id    NUMBER,
		       X_Default_Ledger_Id           NUMBER,
                       X_User_Id                     NUMBER,
                       X_Login_Id                    NUMBER,
                       X_Date                        DATE,
                       X_Description                 VARCHAR2 DEFAULT NULL,
                       X_Context                     VARCHAR2 DEFAULT NULL,
                       X_Attribute1                  VARCHAR2 DEFAULT NULL,
                       X_Attribute2                  VARCHAR2 DEFAULT NULL,
                       X_Attribute3                  VARCHAR2 DEFAULT NULL,
                       X_Attribute4                  VARCHAR2 DEFAULT NULL,
                       X_Attribute5                  VARCHAR2 DEFAULT NULL,
                       X_Attribute6                  VARCHAR2 DEFAULT NULL,
                       X_Attribute7                  VARCHAR2 DEFAULT NULL,
                       X_Attribute8                  VARCHAR2 DEFAULT NULL,
                       X_Attribute9                  VARCHAR2 DEFAULT NULL,
                       X_Attribute10                 VARCHAR2 DEFAULT NULL,
                       X_Attribute11                 VARCHAR2 DEFAULT NULL,
                       X_Attribute12                 VARCHAR2 DEFAULT NULL,
                       X_Attribute13                 VARCHAR2 DEFAULT NULL,
                       X_Attribute14                 VARCHAR2 DEFAULT NULL,
                       X_Attribute15                 VARCHAR2 DEFAULT NULL);

  --
  -- Procedure
  --   Lock_Row
  -- Purpose
  --   used to lock an access set row
  -- History
  --   02-19-2001   T Cheng      Created
  --   11-12-2001   T Cheng      Add X_Default_Ledger_Id
  -- Notes
  --
  PROCEDURE Lock_Row(
                       X_Rowid                       VARCHAR2,
                       X_Access_Set_Id               NUMBER,
                       X_Name                        VARCHAR2,
                       X_Security_Segment_Code       VARCHAR2,
                       X_Enabled_Flag                VARCHAR2,
                       X_Chart_Of_Accounts_Id        NUMBER,
                       X_Period_Set_Name             VARCHAR2,
                       X_Accounted_Period_Type       VARCHAR2,
                       X_Automatically_Created_Flag  VARCHAR2,
		       X_Secured_Seg_Value_Set_Id    NUMBER,
		       X_Default_Ledger_Id           NUMBER,
                       X_Last_Update_Date            DATE,
                       X_Last_Updated_By             NUMBER,
                       X_Creation_Date               DATE,
                       X_Created_By                  NUMBER,
                       X_Last_Update_Login           NUMBER,
                       X_Description                 VARCHAR2 DEFAULT NULL,
                       X_Context                     VARCHAR2 DEFAULT NULL,
                       X_Attribute1                  VARCHAR2 DEFAULT NULL,
                       X_Attribute2                  VARCHAR2 DEFAULT NULL,
                       X_Attribute3                  VARCHAR2 DEFAULT NULL,
                       X_Attribute4                  VARCHAR2 DEFAULT NULL,
                       X_Attribute5                  VARCHAR2 DEFAULT NULL,
                       X_Attribute6                  VARCHAR2 DEFAULT NULL,
                       X_Attribute7                  VARCHAR2 DEFAULT NULL,
                       X_Attribute8                  VARCHAR2 DEFAULT NULL,
                       X_Attribute9                  VARCHAR2 DEFAULT NULL,
                       X_Attribute10                 VARCHAR2 DEFAULT NULL,
                       X_Attribute11                 VARCHAR2 DEFAULT NULL,
                       X_Attribute12                 VARCHAR2 DEFAULT NULL,
                       X_Attribute13                 VARCHAR2 DEFAULT NULL,
                       X_Attribute14                 VARCHAR2 DEFAULT NULL,
                       X_Attribute15                 VARCHAR2 DEFAULT NULL);

END gl_access_sets_pkg;

 

/
