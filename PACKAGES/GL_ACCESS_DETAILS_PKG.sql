--------------------------------------------------------
--  DDL for Package GL_ACCESS_DETAILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_ACCESS_DETAILS_PKG" AUTHID CURRENT_USER AS
/* $Header: glistads.pls 120.6 2005/05/05 01:22:06 kvora ship $ */
--
-- Package
--   gl_access_details_pkg
-- Purpose
--   Server routines related to gl_access_set_norm_assign
-- History
--   02/19/2001   T Cheng      Created

  --
  -- Function
  --   get_record_id
  -- Purpose
  --   retrieves the unique record id from sequence gl_access_set_norm_assign_s
  -- History
  --   05-15-2001   T Cheng     Created
  -- Notes
  --
  FUNCTION get_record_id RETURN NUMBER;

  --
  -- Procedure
  --   is_ledger_set
  -- Purpose
  --   used to determine, given a ledger id, if it is a ledger set
  -- History
  --   03-28-2001   T Cheng      Created
  -- Notes
  --
  FUNCTION is_ledger_set(X_Ledger_Id NUMBER) RETURN BOOLEAN;

  --
  -- Procedure
  --   Insert_Row
  -- Purpose
  --   used to insert an access detail record
  -- History
  --   02-19-2001   T Cheng      Created
  --   10-23-2001   T Cheng      Change parameters
  -- Notes
  --
  PROCEDURE Insert_Row(
                       X_Rowid              IN OUT NOCOPY VARCHAR2,
                       X_Access_Set_Id             NUMBER,
                       X_Ledger_Id                 NUMBER,
                       X_All_Segment_Value_Flag    VARCHAR2,
                       X_Segment_Value_Type_Code   VARCHAR2,
                       X_Access_Privilege_Code     VARCHAR2,
                       X_Record_Id                 NUMBER,
                       X_User_Id                   NUMBER,
                       X_Login_Id                  NUMBER,
                       X_Date                      DATE,
                       X_Segment_Value             VARCHAR2 DEFAULT NULL,
                       X_Start_Date                DATE     DEFAULT NULL,
                       X_End_Date                  DATE     DEFAULT NULL,
                       X_Status_Code               VARCHAR2 DEFAULT NULL,
                       X_Link_Id                   NUMBER   DEFAULT NULL,
                       X_Request_Id                NUMBER   DEFAULT NULL,
                       X_Context                   VARCHAR2 DEFAULT NULL,
                       X_Attribute1                VARCHAR2 DEFAULT NULL,
                       X_Attribute2                VARCHAR2 DEFAULT NULL,
                       X_Attribute3                VARCHAR2 DEFAULT NULL,
                       X_Attribute4                VARCHAR2 DEFAULT NULL,
                       X_Attribute5                VARCHAR2 DEFAULT NULL,
                       X_Attribute6                VARCHAR2 DEFAULT NULL,
                       X_Attribute7                VARCHAR2 DEFAULT NULL,
                       X_Attribute8                VARCHAR2 DEFAULT NULL,
                       X_Attribute9                VARCHAR2 DEFAULT NULL,
                       X_Attribute10               VARCHAR2 DEFAULT NULL,
                       X_Attribute11               VARCHAR2 DEFAULT NULL,
                       X_Attribute12               VARCHAR2 DEFAULT NULL,
                       X_Attribute13               VARCHAR2 DEFAULT NULL,
                       X_Attribute14               VARCHAR2 DEFAULT NULL,
                       X_Attribute15               VARCHAR2 DEFAULT NULL);

  --
  -- Procedure
  --   Lock_Row
  -- Purpose
  --   used to lock an access detail record
  -- History
  --   02-19-2001   T Cheng      Created
  --   10-23-2001   T Cheng      Change parameters
  -- Notes
  --
  PROCEDURE Lock_Row(
                       X_Rowid                     VARCHAR2,
                       X_Access_Set_Id             NUMBER,
                       X_Ledger_Id                 NUMBER,
                       X_All_Segment_Value_Flag    VARCHAR2,
                       X_Segment_Value_Type_Code   VARCHAR2,
                       X_Access_Privilege_Code     VARCHAR2,
                       X_Record_Id                 NUMBER,
                       X_Last_Update_Date          DATE,
                       X_Last_Updated_By           NUMBER,
                       X_Creation_Date             DATE,
                       X_Created_By                NUMBER,
                       X_Last_Update_Login         NUMBER,
                       X_Segment_Value             VARCHAR2 DEFAULT NULL,
                       X_Start_Date                DATE     DEFAULT NULL,
                       X_End_Date                  DATE     DEFAULT NULL,
                       X_Status_Code               VARCHAR2 DEFAULT NULL,
                       X_Link_Id                   NUMBER   DEFAULT NULL,
                       X_Request_Id                NUMBER   DEFAULT NULL,
                       X_Context                   VARCHAR2 DEFAULT NULL,
                       X_Attribute1                VARCHAR2 DEFAULT NULL,
                       X_Attribute2                VARCHAR2 DEFAULT NULL,
                       X_Attribute3                VARCHAR2 DEFAULT NULL,
                       X_Attribute4                VARCHAR2 DEFAULT NULL,
                       X_Attribute5                VARCHAR2 DEFAULT NULL,
                       X_Attribute6                VARCHAR2 DEFAULT NULL,
                       X_Attribute7                VARCHAR2 DEFAULT NULL,
                       X_Attribute8                VARCHAR2 DEFAULT NULL,
                       X_Attribute9                VARCHAR2 DEFAULT NULL,
                       X_Attribute10               VARCHAR2 DEFAULT NULL,
                       X_Attribute11               VARCHAR2 DEFAULT NULL,
                       X_Attribute12               VARCHAR2 DEFAULT NULL,
                       X_Attribute13               VARCHAR2 DEFAULT NULL,
                       X_Attribute14               VARCHAR2 DEFAULT NULL,
                       X_Attribute15               VARCHAR2 DEFAULT NULL);

  --
  -- Procedure
  --   Delete_Row
  -- Purpose
  --   used to mark that an access detail record is to be deleted by
  --   setting its status_code to 'D'
  -- History
  --   02-19-2001   T Cheng      Created
  -- Notes
  --
  PROCEDURE Delete_Row(X_Rowid  VARCHAR2);

  --
  -- Procedure
  --   check_duplicate
  -- Purpose
  --   used to prevent a user to assign the same ledger/ledger set with the
  --   same privilege to the same data access set.
  -- History
  --   08-27-2003   C Ma         Created
  -- Notes
  --
  PROCEDURE check_duplicate(
                            X_Access_Set_Id             NUMBER,
                            X_Ledger_Id                 NUMBER,
                            X_All_Segment_Value_Flag    VARCHAR2,
                            X_Segment_Value_Type_Code   VARCHAR2,
                            X_Access_Privilege_Code     VARCHAR2,
                            X_Segment_Value		VARCHAR2);

  --
  -- Procedure
  --   validate_access_detail
  -- Purpose
  --   For iSetup API: validate the access detail assignment
  -- History
  --   05-04-2004   T Cheng     Created
  -- Notes
  --
  PROCEDURE validate_access_detail(X_Das_Coa_Id              NUMBER,
                                   X_Das_Period_Set_Name     VARCHAR2,
                                   X_Das_Period_Type         VARCHAR2,
                                   X_Das_Security_Code       VARCHAR2,
                                   X_Das_Value_Set_Id        NUMBER,
                                   X_Ledger_Id               NUMBER,
                                   X_All_Segment_Value_Flag  VARCHAR2,
                                   X_Segment_Value           VARCHAR2,
                                   X_Segment_Value_Type_Code VARCHAR2);


END gl_access_details_pkg;

 

/
