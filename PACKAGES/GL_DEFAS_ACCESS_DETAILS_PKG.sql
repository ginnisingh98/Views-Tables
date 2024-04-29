--------------------------------------------------------
--  DDL for Package GL_DEFAS_ACCESS_DETAILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_DEFAS_ACCESS_DETAILS_PKG" AUTHID CURRENT_USER AS
/* $Header: glistdds.pls 120.4 2005/05/05 01:23:16 kvora ship $ */
--
-- Package
--   gl_defas_access_details_pkg
-- Purpose
--   Server routines related to view gl_defas_norm_assign_v
-- History
--   06/07/2002   C Ma           Created

  --
  -- Procedure
  --   get_query_component
  -- Purpose
  --   used to get the parameters to create the record group query
  -- History
  --   06/07/02   C Ma           Created
  -- Notes
  --
  PROCEDURE get_query_component( X_Object_Type         VARCHAR2,
                                 X_Id_Column    IN OUT NOCOPY VARCHAR2,
                                 X_Name_Column  IN OUT NOCOPY VARCHAR2,
                                 X_Desc_Column  IN OUT NOCOPY VARCHAR2,
                                 X_Where_Clause IN OUT NOCOPY VARCHAR2,
                                 X_Table_Name   IN OUT NOCOPY VARCHAR2);
  --
  -- Procedure
  --   get_object_name
  -- Purpose
  --   used to get the object name
  -- History
  --   06/07/02   C Ma           Created
  -- Notes
  --
  FUNCTION get_object_name(  X_Obj_Type VARCHAR2,
                             X_Obj_Key  VARCHAR2) RETURN VARCHAR2;

  --
  -- Procedure
  --   get_object_key
  -- Purpose
  --   used to get the object key. called by iSetup API.
  -- History
  --   04/07/04   C Ma           Created
  -- Notes
  --
  FUNCTION get_object_key(   X_Obj_Type VARCHAR2,
                             X_Obj_Name  VARCHAR2) RETURN VARCHAR2;

  --
  -- Procedure
  --   secure_object
  -- Purpose
  --   used to secure an object.called from the API.
  -- History
  --   04/08/04   C Ma           Created
  -- Notes
  --
  PROCEDURE secure_object (  X_Obj_Type VARCHAR2,
                             X_Obj_Key  VARCHAR2);


  --
  -- Procedure
  --   Insert_Row
  -- Purpose
  --   used to insert a definition access detail record
  -- History
  --   06/07/02   C Ma           Created
  -- Notes
  --
  PROCEDURE Insert_Row(
                       X_Rowid              IN OUT NOCOPY VARCHAR2,
                       X_Definition_Access_Set_Id  NUMBER,
                       X_Object_Type               VARCHAR2,
                       X_Object_Key                VARCHAR2,
                       X_View_Access_Flag          VARCHAR2,
                       X_Use_Access_Flag            VARCHAR2,
                       X_Modify_Access_Flag        VARCHAR2,
                       X_User_Id                   NUMBER,
                       X_Login_Id                  NUMBER,
                       X_Date                      DATE,
                       X_Status_Code               VARCHAR2 DEFAULT NULL,
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
                       X_Attribute15               VARCHAR2 DEFAULT NULL,
                       X_Request_Id                NUMBER);


  --
  -- Procedure
  --   Update_Row
  -- Purpose
  --   used to update a definition access detail record
  -- History
  --   06/07/02   C Ma           Created
  -- Notes
  --
  PROCEDURE Update_Row(
                       X_Rowid              IN OUT NOCOPY VARCHAR2,
                       X_View_Access_Flag          VARCHAR2,
                       X_Use_Access_Flag            VARCHAR2,
                       X_Modify_Access_Flag        VARCHAR2,
                       X_Last_Update_Date          DATE,
                       X_Last_Updated_By           NUMBER,
                       X_Last_Update_Login         NUMBER,
                       X_Request_Id                NUMBER,
                       X_Status_Code               VARCHAR2,
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
  --   used to lock a definition access detail record
  -- History
  --   06/07/02   C Ma           Created
  -- Notes
  --
  PROCEDURE Lock_Row(
                       X_Rowid              IN OUT NOCOPY VARCHAR2,
                       X_Definition_Access_Set_Id  NUMBER,
                       X_Object_Type               VARCHAR2,
                       X_Object_Key                VARCHAR2,
                       X_View_Access_Flag          VARCHAR2,
                       X_Use_Access_Flag            VARCHAR2,
                       X_Modify_Access_Flag        VARCHAR2,
                       X_Last_Update_Date          DATE,
                       X_Last_Updated_By           NUMBER,
                       X_Creation_Date             DATE,
                       X_Created_By                NUMBER,
                       X_Last_Update_Login         NUMBER,
                       X_Status_Code               VARCHAR2 DEFAULT NULL,
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
                       X_Attribute15               VARCHAR2 DEFAULT NULL,
                       X_Request_Id                NUMBER);


 --
  -- Procedure
  --   Delete_Row
  -- Purpose
  --   used to delete a definition access detail record
  -- History
  --   06/07/02   C Ma           Created
  -- Notes
  --
  PROCEDURE Delete_Row(X_Rowid       VARCHAR2,
                       X_Status_Code VARCHAR2);

  --
  -- Procedure
  --   check_unique_name
  -- Purpose
  --   check whether the definition has already be included in the set
  -- History
  --   06-07-2001   C Ma           Created
  -- Arguments
  --   None
  -- Notes
  --
  PROCEDURE check_unique_name(X_Definition_Access_Set_Id NUMBER,
                              X_Object_Type  VARCHAR2,
                              X_Object_Key   VARCHAR2);

  --
  -- Function
  --  Submit_Conc_Request
  --
  -- Purpose
  --   Launch Conversion Rate Change concurrent program for
  --   Ispeed Daily Rates API
  --
  -- History
  --   04/16/04   C Ma      Created
  --
  -- Arguments
  --
  --
  -- Example
  --   gl_daily_rates_pkg.Submit_Conc_Request(....);
  --
  -- Notes
  --
  FUNCTION submit_conc_request RETURN NUMBER;

END gl_defas_access_details_pkg;

 

/
