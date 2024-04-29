--------------------------------------------------------
--  DDL for Package GL_DEFAS_ACCESS_SETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_DEFAS_ACCESS_SETS_PKG" AUTHID CURRENT_USER AS
/* $Header: glistdas.pls 120.4 2005/05/05 01:23:02 kvora ship $ */
--
-- Package
--   gl_defas_access_sets_pkg
-- Purpose
--   Server routines related to table gl_defas_access_sets
-- History
--   06/07/2002   C Ma           Created

  --
  -- Function
  --   get_unique_id
  -- Purpose
  --   retrieves the unique definition access set id from sequence
  --   gl_defas_access_sets_s
  -- History
  --   06-07-2001   C Ma           Created
  -- Arguments
  --   None
  -- Notes
  --
  FUNCTION get_unique_id RETURN NUMBER;

  --
  -- Function
  --   get_dbname_id
  -- Purpose
  --   retrieves the unique id for the definition_access_set column from
  --   sequence gl_defas_dbname_s
  -- History
  --   10/08/2001   C Ma              Created
  -- Arguments
  --   None
  -- Notes
  --
  FUNCTION get_dbname_id RETURN NUMBER;

  --
  -- Procedure
  --   check_unique_name
  -- Purpose
  --   check whether the definition access set name already exists
  -- History
  --   06-07-2001   C Ma           Created
  -- Arguments
  --   None
  -- Notes
  --
  PROCEDURE check_unique_name(x_name  IN VARCHAR2);

  --
  -- Procedure
  --   check_assign
  -- Purpose
  --   check whether the definition access set has been assigned to any
  --   responsibilities.
  -- History
  --   07-17-2002   C Ma           Created
  -- Arguments
  --   None
  -- Notes
  --
  PROCEDURE check_assign (X_Definition_Access_Set_Id   IN NUMBER,
                          X_Assign_Flag                IN OUT NOCOPY VARCHAR2);

  --
  -- Procedure
  --   translate_row
  -- Purpose
  --   procedure called by the confirgration file to upload the Super
  --   User Definition Access Set.
  -- History
  --   03-24-2003   C Ma           Created
  -- Arguments
  --   None
  -- Notes
  --
  PROCEDURE translate_row(X_Definition_Access_Set      VARCHAR2,
                            X_User_Definition_Access_Set VARCHAR2,
                            X_Description                VARCHAR2,
                            X_Owner                      VARCHAR2,
                            X_Force_Edits                VARCHAR2);

  --
  -- Procedure
  --   load_row
  -- Purpose
  --   procedure called by the confirgration file to upload the Super
  --   User Definition Access Set.
  -- History
  --   03-24-2003   C Ma           Created
  -- Arguments
  --   None
  -- Notes
  --
  PROCEDURE load_row(X_Definition_Access_Set      VARCHAR2,
                     X_User_Definition_Access_Set VARCHAR2,
                     X_Description                VARCHAR2,
                     X_Attribute1                 VARCHAR2,
                     X_Attribute2                 VARCHAR2,
                     X_Attribute3                 VARCHAR2,
                     X_Attribute4                 VARCHAR2,
                     X_Attribute5                 VARCHAR2,
                     X_Attribute6                 VARCHAR2,
                     X_Attribute7                 VARCHAR2,
                     X_Attribute8                 VARCHAR2,
                     X_Attribute9                 VARCHAR2,
                     X_Attribute10                VARCHAR2,
                     X_Attribute11                VARCHAR2,
                     X_Attribute12                VARCHAR2,
                     X_Attribute13                VARCHAR2,
                     X_Attribute14                VARCHAR2,
                     X_Attribute15                VARCHAR2,
                     X_Context                    VARCHAR2,
                     X_Owner                      VARCHAR2,
                     X_Force_Edits                VARCHAR2);


END gl_defas_access_sets_pkg;

 

/
