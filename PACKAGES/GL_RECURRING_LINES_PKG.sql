--------------------------------------------------------
--  DDL for Package GL_RECURRING_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_RECURRING_LINES_PKG" AUTHID CURRENT_USER AS
/* $Header: glirecls.pls 120.3 2005/05/05 01:20:17 kvora ship $ */
--
-- Package
--   GL_RECURRING_LINES_PKG
-- Purpose
--   To group all the procedures/functions for GL_RECURRING_LINES_PKG.
-- History
--   20-FEB-1994  ERumanan  Created.
--


  --
  -- Procedure
  --   check_unique
  -- Purpose
  --   Ensure new recurring formula name is unique.
  -- History
  --   20-FEB-1994  ERumanan  Created.
  -- Arguments
  --   x_rowid    	The ID of the row to be checked
  --   x_line_num	The recurring line number to be checked
  --   x_header_id	The recurring header id to be checked
  -- Example
  --   GL_RECURRING_LINES_PKG.check_unique( '12345', 1, 100 );
  -- Notes
  --
  PROCEDURE check_unique( x_rowid      VARCHAR2,
                          x_line_num   NUMBER,
                          x_header_id  NUMBER );

  --
  -- Procedure
  --   check_dup_budget_acct
  -- Purpose
  --   Ensure a budget batch has unique line account because budget formula
  --   replaces account balances.
  -- History
  --   12-SEP-1997  Charmaine Wang  Created.
  -- Arguments
  --   x_rowid    	The ID of the gl_iea_recur_lines row to be checked
  --   x_ccid           The account id
  --   x_batch_id	The recurring batch id
  -- Example
  --   GL_RECURRING_LINES_PKG.check_dup_budget_acct( '12345', 100, 1 );
  -- Notes
  --
  PROCEDURE check_dup_budget_acct( x_rowid     VARCHAR2,
                                   x_ccid      NUMBER,
                                   x_batch_id  NUMBER );


  --
  -- Procedure
  --   delete_rows
  -- Purpose
  --   Delete rows for all the detail blocks.
  -- History
  --   20-MAR-1994  ERumanan  Created.
  -- Arguments
  --   x_header_id  The recurring header id.
  -- Example
  --   GL_RECURRING_LINES_PKG.delete_rows( 10 );
  -- Notes
  --
  PROCEDURE delete_rows( x_header_id    NUMBER );




------------------------------------


  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Recurring_Header_Id            NUMBER,
                       X_Recurring_Line_Num             NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Code_Combination_Id            NUMBER,
                       X_Entered_Currency_Code          VARCHAR2,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Description                    VARCHAR2,
                       X_Entered_Dr                     NUMBER,
                       X_Entered_Cr                     NUMBER,
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
                       X_Context                        VARCHAR2,
                       X_Budget_Flag                    VARCHAR2,
                       X_Batch_Id                       NUMBER
                      );

  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Recurring_Header_Id              NUMBER,
                     X_Recurring_Line_Num               NUMBER,
                     X_Code_Combination_Id              NUMBER,
                     X_Entered_Currency_Code            VARCHAR2,
                     X_Description                      VARCHAR2,
                     X_Entered_Dr                       NUMBER,
                     X_Entered_Cr                       NUMBER,
                     X_Attribute1                       VARCHAR2,
                     X_Attribute2                       VARCHAR2,
                     X_Attribute3                       VARCHAR2,
                     X_Attribute4                       VARCHAR2,
                     X_Attribute5                       VARCHAR2,
                     X_Attribute6                       VARCHAR2,
                     X_Attribute7                       VARCHAR2,
                     X_Attribute8                       VARCHAR2,
                     X_Attribute9                       VARCHAR2,
                     X_Attribute10                      VARCHAR2,
                     X_Context                          VARCHAR2
                    );



  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Recurring_Header_Id            NUMBER,
                       X_Recurring_Line_Num             NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Code_Combination_Id            NUMBER,
                       X_Entered_Currency_Code          VARCHAR2,
                       X_Last_Update_Login              NUMBER,
                       X_Description                    VARCHAR2,
                       X_Entered_Dr                     NUMBER,
                       X_Entered_Cr                     NUMBER,
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
                       X_Context                        VARCHAR2,
                       X_Budget_Flag                    VARCHAR2,
                       X_Batch_Id                       NUMBER
                      );

  PROCEDURE Delete_Row(X_Rowid VARCHAR2);


------------------------------------



END GL_RECURRING_LINES_PKG;

 

/
