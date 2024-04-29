--------------------------------------------------------
--  DDL for Package GL_DEFAS_RESP_ASSIGN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_DEFAS_RESP_ASSIGN_PKG" AUTHID CURRENT_USER AS
/* $Header: glistras.pls 120.5 2005/09/02 10:35:26 adesu ship $ */
--
-- Package
--   gl_defas_resp_assign_pkg
-- Purpose
--   Server routines related to view gl_defas_resp_assign_v
-- History
--   07/15/2002   C Ma           Created

  --
  -- Procedure
  --   Insert_Row
  -- Purpose
  --   used to insert a definition access assignment record
  -- History
  --   07/15/02   C Ma           Created
  -- Notes
  --
  PROCEDURE Insert_Row(
                       X_Rowid                 IN OUT NOCOPY VARCHAR2,
                       X_Definition_Access_Set_Id   IN NUMBER,
                       X_Security_Group_Id     IN NUMBER,
                       X_Responsibility_Id     IN NUMBER,
                       X_Application_Id        IN NUMBER,
                       X_Last_Update_Date      IN DATE,
                       X_Last_Updated_By       IN NUMBER,
                       X_Last_Update_Login     IN NUMBER,
                       X_Creation_Date         IN DATE,
                       X_Created_By            IN NUMBER,
                       X_Status_Code           IN VARCHAR2,
                       X_Request_Id            IN VARCHAR2,
                       X_Attribute1            IN VARCHAR2,
                       X_Attribute2            IN VARCHAR2,
                       X_Attribute3            IN VARCHAR2,
                       X_Attribute4            IN VARCHAR2,
                       X_Attribute5            IN VARCHAR2,
                       X_Attribute6            IN VARCHAR2,
                       X_Attribute7            IN VARCHAR2,
                       X_Attribute8            IN VARCHAR2,
                       X_Attribute9            IN VARCHAR2,
                       X_Attribute10           IN VARCHAR2,
                       X_Attribute11           IN VARCHAR2,
                       X_Attribute12           IN VARCHAR2,
                       X_Attribute13           IN VARCHAR2,
                       X_Attribute14           IN VARCHAR2,
                       X_Attribute15           IN VARCHAR2,
                       X_Context               IN VARCHAR2,
                       X_Default_Flag          IN VARCHAR2,
                       X_Default_View_Flag     IN VARCHAR2,
                       X_Default_Use_Flag      IN VARCHAR2,
                       X_Default_Modify_Flag   IN VARCHAR2
                      );

  --
  -- Procedure
  --   Lock_Row
  -- Purpose
  --   used to lock a definition access assignment record
  -- History
  --   06/07/02   C Ma           Created
  -- Notes
  --
  PROCEDURE Lock_Row(
                       X_Rowid                 IN OUT NOCOPY VARCHAR2,
                       X_Definition_Access_Set_Id   IN NUMBER,
                       X_Security_Group_Id     IN NUMBER,
                       X_Responsibility_Id     IN NUMBER,
                       X_Application_Id        IN NUMBER,
                       X_Last_Update_Date      IN DATE,
                       X_Last_Updated_By       IN NUMBER,
                       X_Last_Update_Login     IN NUMBER,
                       X_Creation_Date         IN DATE,
                       X_Created_By            IN NUMBER,
                       X_Status_Code           IN VARCHAR2,
                       X_Request_Id            IN VARCHAR2,
                       X_Attribute1            IN VARCHAR2,
                       X_Attribute2            IN VARCHAR2,
                       X_Attribute3            IN VARCHAR2,
                       X_Attribute4            IN VARCHAR2,
                       X_Attribute5            IN VARCHAR2,
                       X_Attribute6            IN VARCHAR2,
                       X_Attribute7            IN VARCHAR2,
                       X_Attribute8            IN VARCHAR2,
                       X_Attribute9            IN VARCHAR2,
                       X_Attribute10           IN VARCHAR2,
                       X_Attribute11           IN VARCHAR2,
                       X_Attribute12           IN VARCHAR2,
                       X_Attribute13           IN VARCHAR2,
                       X_Attribute14           IN VARCHAR2,
                       X_Attribute15           IN VARCHAR2,
                       X_Context               IN VARCHAR2,
                       X_Default_Flag          IN VARCHAR2,
                       X_Default_View_Flag     IN VARCHAR2,
                       X_Default_Use_Flag      IN VARCHAR2,
                       X_Default_Modify_Flag   IN VARCHAR2
                      );


  --
  -- Procedure
  --   Update_Row
  -- Purpose
  --   used to update a definition access assignment record
  -- History
  --   06/07/02   C Ma           Created
  -- Notes
  --
  PROCEDURE Update_Row(
                       X_Rowid                 IN OUT NOCOPY VARCHAR2,
                       X_Last_Update_Date      IN DATE,
                       X_Last_Updated_By       IN NUMBER,
                       X_Last_Update_Login     IN NUMBER,
                       X_Status_Code           IN VARCHAR2,
                       X_Request_Id            IN VARCHAR2,
                       X_Attribute1            IN VARCHAR2,
                       X_Attribute2            IN VARCHAR2,
                       X_Attribute3            IN VARCHAR2,
                       X_Attribute4            IN VARCHAR2,
                       X_Attribute5            IN VARCHAR2,
                       X_Attribute6            IN VARCHAR2,
                       X_Attribute7            IN VARCHAR2,
                       X_Attribute8            IN VARCHAR2,
                       X_Attribute9            IN VARCHAR2,
                       X_Attribute10           IN VARCHAR2,
                       X_Attribute11           IN VARCHAR2,
                       X_Attribute12           IN VARCHAR2,
                       X_Attribute13           IN VARCHAR2,
                       X_Attribute14           IN VARCHAR2,
                       X_Attribute15           IN VARCHAR2,
                       X_Context               IN VARCHAR2,
                       X_Default_Flag          IN VARCHAR2,
                       X_Default_View_Flag     IN VARCHAR2,
                       X_Default_Use_Flag      IN VARCHAR2,
                       X_Default_Modify_Flag   IN VARCHAR2
                      );

 --
  -- Procedure
  --   Delete_Row
  -- Purpose
  --   used to delete a definition access assignment record
  -- History
  --   06/07/02   C Ma           Created
  -- Notes
  --
  PROCEDURE Delete_Row(X_Rowid       VARCHAR2);

  --
  -- Procedure
  --   check_unique_set
  -- Purpose
  --   check whether the definition access set has already be assigned
  --   to the responsibility
  -- History
  --   06-07-2001   C Ma           Created
  -- Arguments
  --   None
  -- Notes
  --
  PROCEDURE check_unique_set(X_Definition_Access_Set_Id NUMBER,
                             X_Application_Id         NUMBER,
                             X_Responsibility_Id      NUMBER,
                             X_Security_Group_Id      NUMBER);

END gl_defas_resp_assign_pkg;

 

/
