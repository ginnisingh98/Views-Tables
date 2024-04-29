--------------------------------------------------------
--  DDL for Package GL_LEDGER_NORM_SEG_VALS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_LEDGER_NORM_SEG_VALS_PKG" AUTHID CURRENT_USER AS
/* $Header: glistsvs.pls 120.5 2003/04/24 01:35:38 djogg noship $ */
--
-- Package
--   GL_LEDGER_NORM_SEG_VALS_PKG
-- Purpose
--   To create GL_LEDGER_NORM_SEG_VALS_PKG package.
-- History
--   02/08/01    O Monnier      Created.
--

  --
  -- Procedure
  --   Get_Record_Id
  -- Purpose
  --   Get the record id for this row.
  -- History
  --   02/08/01    O Monnier      Created
  -- Arguments
  --   none
  -- Example
  --   Record_Id := GL_LEDGER_NORM_SEG_VALS_PKG.Get_Record_Id;
  -- Notes
  --
  FUNCTION Get_Record_Id RETURN NUMBER;

  -- *********************************************************************

  --
  -- Procedure
  --   Check_Unique
  -- Purpose
  --   Ensure the Segment Value is only specified once for the interval of dates specified.
  -- History
  --   02/08/01    O Monnier      Created
  -- Arguments
  --   X_Rowid                     The ID of the row to be checked
  --   X_Ledger_Id                 The ledger id
  --   X_Segment_Value             The segment value to be checked
  --   X_Segment_Type_Code         The segment type code
  --   X_Start_Date                The start date for the combination
  --   X_End_Date                  The end date for the combination
  -- Example
  --   GL_LEDGER_NORM_SEG_VALS_PKG.Check_Unique( '12345', 1, 'T', 'B', null, null );
  -- Notes
  --
  PROCEDURE Check_Unique(X_Rowid                          VARCHAR2,
                         X_Ledger_Id                      NUMBER,
                         X_Segment_Value                  VARCHAR2,
                         X_Segment_Type_Code              VARCHAR2,
                         X_Start_Date                     DATE,
                         X_End_Date                       DATE);

  -- *********************************************************************

  --
  -- Procedure
  --   Check_Exist
  -- Purpose
  --   Ensure at least one Segment Value is specified when deleting a Segment Value.
  -- History
  --   02/08/01    O Monnier      Created
  -- Arguments
  --   X_Ledger_Id                 The ledger id
  --   X_Segment_Type_Code         The segment type code
  -- Example
  --   test := GL_LEDGER_NORM_SEG_VALS_PKG.Check_Exist( 1, 'B' );
  -- Notes
  --
  FUNCTION Check_Exist(X_Ledger_Id                      NUMBER,
                       X_Segment_Type_Code              VARCHAR2) RETURN BOOLEAN;

  -- *********************************************************************

  --
  -- Procedure
  --   Check_Concurrency_With_Flat
  -- Purpose
  --   Ensure that none of the Segment Values are currently being
  --   processed by the flattening program. We need to check this
  --   before deleting all the segment values.
  -- History
  --   10/29/01    O Monnier      Created
  -- Arguments
  --   X_Ledger_Id                 The ledger id
  --   X_Segment_Type_Code         The segment type code
  -- Example
  --   test := GL_LEDGER_NORM_SEG_VALS_PKG.Check_Conc_With_Flat( 1, 'B' );
  -- Notes
  --
  FUNCTION Check_Conc_With_Flat(X_Ledger_Id           NUMBER,
                                X_Segment_Type_Code   VARCHAR2) RETURN BOOLEAN;

  -- *********************************************************************

  -- The following procedures are necessary to handle the base view form.

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Ledger_Id                      NUMBER,
                       X_Segment_Type_Code              VARCHAR2,
                       X_Segment_Value                  VARCHAR2,
                       X_Segment_Value_Type_Code        VARCHAR2,
                       X_Record_Id                      NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Start_Date                     DATE,
                       X_End_Date                       DATE,
                       X_Context                        VARCHAR2,
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
                       X_Request_Id                     NUMBER
                      );

  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Ledger_Id                        NUMBER,
                     X_Segment_Type_Code                VARCHAR2,
                     X_Segment_Value                    VARCHAR2,
                     X_Segment_Value_Type_Code          VARCHAR2,
                     X_Record_Id                        NUMBER,
                     X_Start_Date                       DATE,
                     X_End_Date                         DATE,
                     X_Context                          VARCHAR2,
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
                     X_Attribute11                      VARCHAR2,
                     X_Attribute12                      VARCHAR2,
                     X_Attribute13                      VARCHAR2,
                     X_Attribute14                      VARCHAR2,
                     X_Attribute15                      VARCHAR2,
                     X_Request_Id                       NUMBER
                    );

  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Ledger_Id                      NUMBER,
                       X_Segment_Type_Code              VARCHAR2,
                       X_Segment_Value                  VARCHAR2,
                       X_Segment_Value_Type_Code        VARCHAR2,
                       X_Record_Id                      NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Start_Date                     DATE,
                       X_End_Date                       DATE,
                       X_Context                        VARCHAR2,
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
                       X_Request_Id                     NUMBER
                      );

  PROCEDURE Delete_Row(X_Rowid              VARCHAR2);

  --
  -- Procedure
  --   Delete_All_Rows
  -- Purpose
  --   Delete all specified segment values when changing the segment option
  --   from 'Specify Individual' to 'Include All'.
  -- History
  --   02/08/01    O Monnier      Created
  -- Arguments
  --   X_Ledger_Id                 The ledger id
  --   X_Segment_Type_Code         The segment type code
  -- Example
  --   GL_LEDGER_NORM_SEG_VALS_PKG.Delete_All_Rows( 1, 'B' );
  -- Notes
  --
  PROCEDURE Delete_All_Rows(X_Ledger_Id NUMBER,
                            X_Segment_Type_Code VARCHAR2);

END GL_LEDGER_NORM_SEG_VALS_PKG;


 

/
