--------------------------------------------------------
--  DDL for Package GL_AUTOREV_CRITERIA_SETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_AUTOREV_CRITERIA_SETS_PKG" AUTHID CURRENT_USER as
/* $Header: glistcss.pls 120.0 2003/09/22 17:10:55 spala noship $ */


  -- Procedure
  --   insert_criteria_set
  -- Purpose
  --   insert a row for each new criteria set created in the Journal
  --   Reversal Criteria form.
  -- Access
  --   Called from the Journal Reversal Criteria set form
  --

  PROCEDURE insert_row(X_Criteria_Set_Id                NUMBER,
                       X_Criteria_Set_Name              VARCHAR2,
                       X_Criteria_Set_Desc              VARCHAR2,
		       X_Creation_Date                  DATE,
                       X_Last_Update_Date               DATE,
		       X_Created_By                     NUMBER,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute15                    VARCHAR2,
                       X_Context                        VARCHAR2,
	               X_Security_Flag                  VARCHAR2);


  -- Function
  --   get_criteria_set_id
  -- Purpose
  --   Gets a new Criteria set id for each new criteria set created from
  --   Journal Reversal Criteria Set form
  --   Reversal Criteria form.
  -- Access
  --   Called from the Journal Reversal Criteria Set
  --

  Function get_criteria_set_id RETURN NUMBER;

  -- Procedure
  --   Delete_row
  -- Purpose
  --   Deltes detail rows from the gl_autoreverse_options table when a
  --   Criteria set is being deleted from gl_autorev_criteria_set
  -- (master table)
  --   Reversal Criteria form.
  -- Access
  --   Called from the Journal Reversal Criteria Set
  --


  PROCEDURE Delete_row( X_Criteria_set_Id NUMBER);

  -- Procedure
  --   Check_Ledger_Assign
  -- Purpose
  --  This function checks whether the criteria set is assigned to any ledger
  --  If so that criteria set can not be deleted.
  --   Reversal Criteria form.
  -- Access
  --   Called from the Journal Reversal Criteria Set
  --

  Function Check_Ledger_Assign( X_Criteria_set_Id NUMBER) Return Boolean;


END GL_AUTOREV_CRITERIA_SETS_PKG;

 

/
