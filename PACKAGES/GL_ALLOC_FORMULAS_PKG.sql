--------------------------------------------------------
--  DDL for Package GL_ALLOC_FORMULAS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_ALLOC_FORMULAS_PKG" AUTHID CURRENT_USER AS
/* $Header: glimafms.pls 120.5.12010000.2 2009/07/13 06:22:33 sommukhe ship $ */
--
-- Package
--   gl_alloc_formulas_pkg
-- Purpose
--   To contain validation and insertion routines for gl_alloc_formulas
-- History
--   10-07-93  	D. J. Ogg	Created
  --
  -- Procedure
  --   check_unique
  -- Purpose
  --   Checks to make sure that the name of the formula
  --   is unique within that batch.
  -- History
  --   10-01-93  D. J. Ogg    Created
  -- Arguments
  --   batch_id		The ID of the containing batch
  --   formula_name 	The name of the formula
  --   row_id		The current rowid
  -- Example
  --   gl_alloc_formulas_pkg.check_unique(123, 'Testing', 'ABD02334');
  -- Notes
  --
  PROCEDURE check_unique(batch_id NUMBER, formula_name VARCHAR2,
			 row_id VARCHAR2);

  --
  -- Procedure
  --   get_unique_id
  -- Purpose
  --   Gets a unique allocation formula id
  -- History
  --   11-09-93  D. J. Ogg    Created
  -- Arguments
  --   none
  -- Example
  --   abid := gl_alloc_formulas_pkg.get_unique_id;
  -- Notes
  --
  FUNCTION get_unique_id RETURN NUMBER;

  --
  -- Procedure
  --   delete_rows
  -- Purpose
  --   Deletes all of the formulas in a batch
  -- History
  --   09-JUN-94  D. J. Ogg    Created
  -- Arguments
  --   batch_id		The ID of the batch to delete
  -- Example
  --   gl_alloc_formulas_pkg.delete_rows(5);
  -- Notes
  --
  PROCEDURE delete_rows(batch_id NUMBER);

PROCEDURE Insert_Row(X_Rowid                         IN OUT NOCOPY VARCHAR2,
                     X_Allocation_Formula_Id         IN OUT NOCOPY NUMBER,
                     X_Allocation_Batch_Id           IN OUT NOCOPY NUMBER,
                     X_Name                                 VARCHAR2,
                     X_Run_Sequence                         NUMBER,
                     X_Je_Category_Name                     VARCHAR2,
                     X_Full_Allocation_Flag                 VARCHAR2,
                     X_Conversion_Method_Code               VARCHAR2,
                     X_Currency_Conversion_Type             VARCHAR2,
                     X_Last_Update_Date                     DATE,
                     X_Last_Updated_By                      NUMBER,
                     X_Creation_Date                        DATE,
                     X_Created_By                           NUMBER,
                     X_Last_Update_Login                    NUMBER,
                     X_Description                          VARCHAR2,
                     X_Actual_Flag                          VARCHAR2,
		     X_Validation_Status                    VARCHAR2
                     );

PROCEDURE Lock_Row(X_Rowid                                  VARCHAR2,
                   X_Allocation_Formula_Id                  NUMBER,
                   X_Allocation_Batch_Id                    NUMBER,
                   X_Name                                   VARCHAR2,
                   X_Run_Sequence                           NUMBER,
                   X_Je_Category_Name                       VARCHAR2,
                   X_Full_Allocation_Flag                   VARCHAR2,
                   X_Conversion_Method_Code                 VARCHAR2,
                   X_Currency_Conversion_Type               VARCHAR2,
                   X_Description                            VARCHAR2,
		   X_Validation_Status                    VARCHAR2
                   );

PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Allocation_Formula_Id               NUMBER,
                     X_Allocation_Batch_Id                 NUMBER,
                     X_Name                                VARCHAR2,
                     X_Run_Sequence                        NUMBER,
                     X_Je_Category_Name                    VARCHAR2,
                     X_Full_Allocation_Flag                VARCHAR2,
                     X_Conversion_Method_Code              VARCHAR2,
                     X_Currency_Conversion_Type            VARCHAR2,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Last_Update_Login                   NUMBER,
                     X_Description                         VARCHAR2,
                     X_Actual_Flag                         VARCHAR2,
		     X_Transaction_Currency		   VARCHAR2,
		     Currency_Changed      IN OUT NOCOPY   VARCHAR2,
		     X_Validation_Status                    VARCHAR2
                     );

PROCEDURE Delete_Row(Allocation_Formula_id NUMBER, X_Rowid VARCHAR2);


END gl_alloc_formulas_pkg;

/
