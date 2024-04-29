--------------------------------------------------------
--  DDL for Package GL_ALLOC_BATCHES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_ALLOC_BATCHES_PKG" AUTHID CURRENT_USER AS
/* $Header: glimabas.pls 120.5.12010000.2 2009/07/13 06:24:28 sommukhe ship $ */
--
-- Package
--   gl_alloc_batches_pkg
-- Purpose
--   To contain validation and insertion routines for gl_alloc_batches
-- History
--   10-07-93  	D. J. Ogg	Created

  --
  -- Procedure
  --   check_unique
  -- Purpose
  --   Checks to make sure that the name of the batch
  --   is unique.
  -- History
  --   10-01-93  D. J. Ogg    Created
  -- Arguments
  --   batch_name 	The name of the batch
  --   row_id		The current rowid
  -- Example
  --   gl_alloc_batches_pkg.check_unique('Testing', 'ABD02334');
  -- Notes
  --
  PROCEDURE check_unique(batch_name VARCHAR2, row_id VARCHAR2,
			 coa_id NUMBER);

  --
  -- Procedure
  --   get_unique_id
  -- Purpose
  --   Gets a unique allocation batch id
  -- History
  --   11-09-93  D. J. Ogg    Created
  -- Arguments
  --   none
  -- Example
  --   abid := gl_alloc_batches_pkg.get_unique_id;
  -- Notes
  --
  FUNCTION get_unique_id RETURN NUMBER;

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Allocation_Batch_Id     IN OUT NOCOPY NUMBER,
                       X_Name                           VARCHAR2,
                       X_Chart_Of_Accounts_Id           NUMBER,
                       X_Actual_Flag                    VARCHAR2,
                       X_Security_Flag                  VARCHAR2,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Description                    VARCHAR2,
		       X_Validation_Status              VARCHAR2,
		       X_Validation_Request_Id          NUMBER
                      );


  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Allocation_Batch_Id              NUMBER,
                     X_Name                             VARCHAR2,
                     X_Chart_Of_Accounts_Id             NUMBER,
                     X_Actual_Flag                      VARCHAR2,
                     X_Security_Flag                    VARCHAR2,
                     X_Description                      VARCHAR2,
		     X_Validation_Status              VARCHAR2,
		     X_Validation_Request_Id          NUMBER
                    );

  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Allocation_Batch_Id            NUMBER,
                       X_Name                           VARCHAR2,
                       X_Chart_Of_Accounts_Id           NUMBER,
                       X_Actual_Flag                    VARCHAR2,
                       X_Security_Flag                  VARCHAR2,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Description                    VARCHAR2,
		       X_Validation_Status              VARCHAR2,
		       X_Validation_Request_Id          NUMBER
                      );


  PROCEDURE Delete_Row(Allocation_Batch_Id NUMBER, X_Rowid VARCHAR2);


  --
  -- Procedure
  --   Autocopy
  -- Purpose
  --   Copy the mass allocation formulas and formula lines
  --   from the given source batch to target batch.
  -- History
  --   18-MAR-1997  Mehmet Demirkol   Created.
  -- Arguments
  --   x_src_batch_id	Source allocation batch id.
  --   x_trg_batch_id   Target allocation batch id.
  --   x_Last_Updated_By Who Information
  --   X_Last_Update_Login
  -- Example
  --   gl_alloc_batches_pkg.Autocopy(
  --
     PROCEDURE Autocopy(    X_Src_Batch_Id      NUMBER,
                            X_Trg_Batch_Id 	NUMBER,
                            X_Last_Updated_By   NUMBER,
                            X_Last_Update_Login NUMBER);

   --
  -- Procedure
  --   Check_Batch
  -- Purpose
  --   Check that the batch is not used in any AutoAllocation set
  -- History
  --   14-AUG-2003  K Chang   Created.
  -- Arguments
  --   x_allocation_batch_id	Source allocation batch id.
  -- Example
  --   gl_alloc_batches_pkg.check_batch(
  --
     PROCEDURE Check_Batch( X_Alloc_Batch_Id      NUMBER);


END gl_alloc_batches_pkg;

/
