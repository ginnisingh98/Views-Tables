--------------------------------------------------------
--  DDL for Package GL_RECURRING_BATCHES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_RECURRING_BATCHES_PKG" AUTHID CURRENT_USER AS
/* $Header: glirecbs.pls 120.5 2005/05/05 01:19:49 kvora ship $ */
--
-- Package
--   GL_RECURRING_BATCHES_PKG
-- Purpose
--   To group all the procedures/functions for gl_recurring_batches_pkg.
-- History
--   20-FEB-1994  ERumanan  Created.
--


  --
  -- Procedure
  --   check_unique
  -- Purpose
  --   Ensure new recurring batch name is unique.
  -- History
  --   20-FEB-1994  ERumanan  Created.
  -- Arguments
  --   x_rowid    The ID of the row to be checked
  --   x_name     The recurring formula name to be checked
  --   x_coaid
  --   x_period_set_name
  --   x_accounted_period_type
  -- Example
  --
  -- Notes
  --
  PROCEDURE check_unique( x_rowid VARCHAR2,
                          x_name  VARCHAR2,
                          x_coaid NUMBER,
                          x_period_set_name      VARCHAR2,
                          x_accounted_period_type VARCHAR2);

  --
  -- Procedure
  --   get_unique_id
  -- Purpose
  --   Get a new sequence unique id for a new recurring formula.
  -- History
  --   20-FEB-1994  ERumanan  Created.
  -- Arguments
  --   none
  -- Example
  --   :REC_BATCH.recurring_batch_id := GL_RECURRING_BATCHES_PKG.get_unique_id;
  -- Notes
  --
  FUNCTION get_unique_id RETURN NUMBER;



  --
  -- Procedure
  --   copy_recurring
  -- Purpose
  --   Copy the recurring formula journal or budget formula
  --   from the given source batch to target batch.
  -- History
  --   18-MAR-1994  ERumanan  Created.
  -- Arguments
  --   x_src_batch_id	Source recurring batch id.
  --   x_trg_batch_id   Target recurring batch id.
  --   x_trg_batch_name Target recurring batch name.
  --   x_trg_batch_desc Target recurring batch description.
  -- Example
  --   gl_recurring_batches_pkg.copy_recurring( 12345,
  --      'New Batch', 'This batch is copied from batch bla bla bla' );
  -- Notes
  --
  PROCEDURE copy_recurring( X_Src_Batch_Id      NUMBER,
                            X_Trg_Batch_Id    	NUMBER,
                            X_Created_By        NUMBER,
                            X_Last_Updated_By   NUMBER,
                            X_Last_Update_Login NUMBER
                           );


  --
  -- Procedure
  --   insert_row
  -- Purpose
  -- History
  --   08-MAR-1995  CSCHALK  Created.
  -- Arguments
  --
  -- Example
  --
  -- Notes
  --


  PROCEDURE Insert_Row(  X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Recurring_Batch_Id        IN OUT NOCOPY NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Ledger_Id                      NUMBER,
                       X_Chart_Of_Accounts_Id           NUMBER,
                       X_Period_Set_Name                VARCHAR2,
                       X_Accounted_Period_Type          VARCHAR2,
                       X_Recurring_Batch_Type           VARCHAR2,
                       X_Security_Flag                  VARCHAR2,
                       X_Name                           VARCHAR2,
                       X_Budget_Flag                    VARCHAR2,
                       X_Allocation_Flag                VARCHAR2,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Budget_In_Formula_Flag         VARCHAR2,
                       X_Description                    VARCHAR2,
                       X_Period_Type                    VARCHAR2,
                       X_Last_Executed_Period_Name      VARCHAR2,
                       X_Last_Executed_Date             DATE,
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
                       X_Context                        VARCHAR2
                      );



--*******************************************************************


  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Recurring_Batch_Id               NUMBER,
                     X_Ledger_Id                        NUMBER,
                     X_Chart_Of_Accounts_Id             NUMBER,
                     X_Period_Set_Name                  VARCHAR2,
                     X_Accounted_Period_Type            VARCHAR2,
                     X_Recurring_Batch_Type             VARCHAR2,
                     X_Security_Flag                    VARCHAR2,
                     X_Name                             VARCHAR2,
                     X_Budget_Flag                      VARCHAR2,
                     X_Allocation_Flag                  VARCHAR2,
                     X_Budget_In_Formula_Flag           VARCHAR2,
                     X_Description                      VARCHAR2,
                     X_Period_Type                      VARCHAR2,
                     X_Last_Executed_Period_Name        VARCHAR2,
                     X_Last_Executed_Date               DATE,
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
                       X_Recurring_Batch_Id             NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Ledger_Id                      NUMBER,
                       X_Chart_Of_Accounts_Id           NUMBER,
                       X_Period_Set_Name                VARCHAR2,
                       X_Accounted_Period_Type          VARCHAR2,
                       X_Recurring_Batch_Type           VARCHAR2,
                       X_Security_Flag                  VARCHAR2,
                       X_Name                           VARCHAR2,
                       X_Budget_Flag                    VARCHAR2,
                       X_Allocation_Flag                VARCHAR2,
                       X_Last_Update_Login              NUMBER,
                       X_Budget_In_Formula_Flag         VARCHAR2,
                       X_Description                    VARCHAR2,
                       X_Period_Type                    VARCHAR2,
                       X_Last_Executed_Period_Name      VARCHAR2,
                       X_Last_Executed_Date             DATE,
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
                       X_Context                        VARCHAR2
                      );


  PROCEDURE Delete_Row(X_Rowid VARCHAR2);


  --
  -- Procedure
  --   Check_Batch
  -- Purpose
  --   Check that the batch is not used in any AutoAllocation set
  -- History
  --   14-AUG-2003  K Chang   Created.
  -- Arguments
  --   x_recurring_batch_id	Source recurring batch id.
  -- Example
  --   gl_recurring_batches_pkg.check_batch(
  --
     PROCEDURE Check_Batch( X_Recurring_Batch_Id      NUMBER);



--*******************************************************************

END GL_RECURRING_BATCHES_PKG;

 

/
