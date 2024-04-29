--------------------------------------------------------
--  DDL for Package GL_STAT_ACCOUNT_UOM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_STAT_ACCOUNT_UOM_PKG" AUTHID CURRENT_USER as
/* $Header: glisuoms.pls 120.5 2005/05/05 01:28:35 kvora ship $ */

--
-- Package
--   gl_stat_account_uom_pkg
-- Purpose
--   To contain routines for the gl_stat_account_uom table
-- History
--   01-18-94  	S. Leotin	Created
--   01-20-94   D. J. Ogg       Added select_columns routine

  --
  -- Procedure
  --   select_columns
  -- Purpose
  --   Used to select the unit of measure for a given account
  --   segment value and chart of accounts.
  -- History
  --   01-20-94  D. J. Ogg    Created
  --   05-05-94  R  Ng	      Added description to select_columns
  -- Arguments
  --   x_chart_of_accounts_id		Chart of Accounts ID
  --   x_account_segment_value		Accounting segment value
  --   x_unit_of_measure                Resulting unit of measure
  --   x_description                	Description of Unit
  -- Example
  --   gl_stat_account_uom_pkg.select_columns(101, '00', uom);
  -- Notes
  --
  PROCEDURE select_columns(
			x_chart_of_accounts_id		IN OUT NOCOPY NUMBER,
			x_account_segment_value		IN OUT NOCOPY VARCHAR2,
			x_unit_of_measure		IN OUT NOCOPY VARCHAR2,
			x_description			IN OUT NOCOPY VARCHAR2);

PROCEDURE Insert_Row(X_Rowid                         IN OUT NOCOPY VARCHAR2,

                     X_Account_Segment_Value                VARCHAR2,
                     X_Unit_Of_Measure                      VARCHAR2,
                     X_Chart_Of_Accounts_Id                 NUMBER,
                     X_Description                          VARCHAR2 DEFAULT NULL,
                     X_Last_Update_Date                     DATE DEFAULT NULL,
                     X_Last_Updated_By                      NUMBER DEFAULT NULL,
                     X_Creation_Date                        DATE DEFAULT NULL,
                     X_Created_By                           NUMBER DEFAULT NULL,
                     X_Last_Update_Login                    NUMBER DEFAULT NULL
                     );

PROCEDURE Lock_Row(X_Rowid                                  VARCHAR2,
                   X_Account_Segment_Value                  VARCHAR2,
                   X_Unit_Of_Measure                        VARCHAR2,
                   X_Chart_Of_Accounts_Id                   NUMBER,
                   X_Description                            VARCHAR2 DEFAULT NULL
                   );

PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Account_Segment_Value               VARCHAR2,
                     X_Unit_Of_Measure                     VARCHAR2,
                     X_Chart_Of_Accounts_Id                NUMBER,
                     X_Description                         VARCHAR2 DEFAULT NULL,
                     X_Last_Update_Date                    DATE DEFAULT NULL,
                     X_Last_Updated_By                     NUMBER DEFAULT NULL,
                     X_Last_Update_Login                   NUMBER DEFAULT NULL
                     );

PROCEDURE Delete_Row(X_Rowid VARCHAR2);

PROCEDURE Check_Unique(X_Rowid				VARCHAR2,
                       X_Account_Segment_Value		VARCHAR2,
                       X_Chart_Of_Accounts_Id		NUMBER
                       );

END GL_STAT_ACCOUNT_UOM_PKG;

 

/
