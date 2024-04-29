--------------------------------------------------------
--  DDL for Package GL_PERIOD_SETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_PERIOD_SETS_PKG" AUTHID CURRENT_USER AS
/* $Header: gliprses.pls 120.9 2005/05/05 01:18:32 kvora ship $ */
--
-- Package
--   gl_period_sets_pkg
-- Purpose
--   To contain validation and insertion routines for gl_period_sets
-- History
--   10-07-93  	D. J. Ogg	Created
  --
  -- Procedure
  --   check_unique
  -- Purpose
  --   Checks to make sure that the name of the calendar
  --   is unique.
  -- History
  --   10-01-93  D. J. Ogg    Created
  -- Arguments
  --   calendar_name 	The name of the calendar
  --   row_id		The current rowid
  -- Example
  --   gl_period_sets_pkg.check_unique('Standard', 'ABCDEDF');
  -- Notes
  --
  PROCEDURE check_unique(calendar_name VARCHAR2, row_id VARCHAR2);


  --
  -- Procedure
  --   get_unique_id
  -- Purpose
  --   Gets a unique calendar id
  -- History
  --   06-10-03  D. J. Ogg    Created
  -- Arguments
  --   none
  -- Example
  --   bid := gl_period_sets_pkg.get_unique_id;
  -- Notes
  --
  FUNCTION get_unique_id RETURN NUMBER;

  --
  -- Procedure
  --   Insert_Row
  -- Purpose
  --   Inserts a row in the gl_period_sets table.
  -- History
  --   10-09-02  N Kasu    Created
  -- Example
  --   gl_period_sets_pkg.Insert_Row(...);
  -- Notes
  --
  PROCEDURE Insert_Row(X_Rowid           IN OUT NOCOPY VARCHAR2,
                       X_Period_Set_Name               VARCHAR2,
                       X_Security_Flag                 VARCHAR2,
                       X_Creation_Date                 DATE,
                       X_Created_By                    NUMBER,
                       X_Last_Updated_By               NUMBER,
                       X_Last_Update_Login             NUMBER,
                       X_Last_Update_Date              DATE,
                       X_Description                   VARCHAR2,
                       X_Context                       VARCHAR2,
                       X_Attribute1                    VARCHAR2,
                       X_Attribute2                    VARCHAR2,
                       X_Attribute3                    VARCHAR2,
                       X_Attribute4                    VARCHAR2,
                       X_Attribute5                    VARCHAR2);

  --
  -- Procedure
  --   Update_Row
  -- Purpose
  --   Updates a row in the gl_period_sets table.
  -- History
  --   10-09-02  N Kasu    Created
  -- Example
  --   gl_period_sets_pkg.Update_Row(...);
  -- Notes
  --
  PROCEDURE Update_Row(X_Rowid                         VARCHAR2,
                       X_Period_Set_Name               VARCHAR2,
                       X_Security_Flag                 VARCHAR2,
                       X_Last_Updated_By               NUMBER,
                       X_Last_Update_Login             NUMBER,
                       X_Last_Update_Date              DATE,
                       X_Description                   VARCHAR2,
                       X_Context                       VARCHAR2,
                       X_Attribute1                    VARCHAR2,
                       X_Attribute2                    VARCHAR2,
                       X_Attribute3                    VARCHAR2,
                       X_Attribute4                    VARCHAR2,
                       X_Attribute5                    VARCHAR2);

  --
  -- Procedure
  --   Load_Row
  -- Purpose
  --   Loads a row in the gl_period_sets table.
  -- History
  --   10-09-02  N Kasu    Created
  -- Example
  --   gl_period_sets_pkg.Load_Row(...);
  -- Notes
  --
  PROCEDURE Load_Row(X_Period_Set_Name                 VARCHAR2,
                     X_Owner                           VARCHAR2,
                     X_Description                     VARCHAR2,
                     X_Context                         VARCHAR2,
                     X_Attribute1                      VARCHAR2,
                     X_Attribute2                      VARCHAR2,
                     X_Attribute3                      VARCHAR2,
                     X_Attribute4                      VARCHAR2,
                     X_Attribute5                      VARCHAR2);

  --
  -- Procedure
  --   Lock_Row
  -- Purpose
  --   used to lock a period set record
  -- History
  --   10/21/02   C Ma           Created
  -- Notes
  --
  PROCEDURE Lock_Row(X_Rowid                IN OUT NOCOPY VARCHAR2,
                     X_Period_Set_Name             VARCHAR2,
                     X_Last_Update_Date            DATE,
                     X_Last_Updated_By             NUMBER,
                     X_Creation_Date               DATE,
                     X_Created_By                  NUMBER,
                     X_Last_Update_Login           NUMBER,
                     X_Description                 VARCHAR2,
                     X_Attribute1                  VARCHAR2,
                     X_Attribute2                  VARCHAR2,
                     X_Attribute3                  VARCHAR2,
                     X_Attribute4                  VARCHAR2,
                     X_Attribute5                  VARCHAR2,
                     X_Context                     VARCHAR2,
                     X_Security_Flag               VARCHAR2);

  --
  -- Function
  --   submit_concurrent
  -- Purpose
  --   Submit the Calendar Validation report.
  --   Created specifically for the Calendar BC4J API.
  -- History
  --   05/09/03		T Cheng 	Created
  -- Arguments
  --   ledger_id	GL ledger ID.
  --   period_set_name  Calendar to be validated.
  -- Example
  --   req_id = gl_period_sets_pkg.submit_concurrent(p_ledger_id, p_cal_name);
  -- Notes
  --   Ledger id is used for the report header. If there is no
  --   ledger context, pass in -1 is fine.
  --
  FUNCTION submit_concurrent(ledger_id       NUMBER,
                             period_set_name VARCHAR2) RETURN NUMBER;

END gl_period_sets_pkg;

 

/
