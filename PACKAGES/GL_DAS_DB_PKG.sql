--------------------------------------------------------
--  DDL for Package GL_DAS_DB_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_DAS_DB_PKG" AUTHID CURRENT_USER AS
/* $Header: gldefacs.pls 120.4 2005/05/05 02:03:34 kvora ship $ */

  --
  -- Procedure
  --   Insert_Super
  -- Purpose
  --   used to assign the definition to the Super User Definition Access Set.
  -- History
  --   10/15/02   C Ma           Created
  -- Notes
  --
  PROCEDURE Insert_Super (
                       P_Rowid       IN OUT NOCOPY VARCHAR2,
                       P_Definition_Access_Set_Id  NUMBER,
                       P_Object_Type               VARCHAR2,
                       P_Object_Key                VARCHAR2,
                       P_User_Id                   NUMBER,
                       P_Login_Id                  NUMBER,
                       P_Date                      DATE);

  --
  -- Procedure
  --   Insert_Default
  -- Purpose
  --   used to assign the definition to the default definition access sets
  --   of the current responsibility.
  -- History
  --   10/15/02   C Ma           Created
  -- Notes
  --
  PROCEDURE Insert_Default (
                       X_Object_Type               VARCHAR2,
                       X_Object_Key                VARCHAR2,
                       X_User_Id                   NUMBER,
                       X_Login_Id                  NUMBER,
                       X_Date                      DATE);


  --
  -- Procedure
  --   submit_req
  -- Purpose
  --   used to submit the definition access set flattening program.
  -- History
  --   10/15/02   C Ma           Created
  -- Notes
  --
  FUNCTION Submit_Req RETURN NUMBER;

END gl_das_db_pkg;

 

/
