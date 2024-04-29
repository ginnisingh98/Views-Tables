--------------------------------------------------------
--  DDL for Package GL_RECURRING_HEADERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_RECURRING_HEADERS_PKG" AUTHID CURRENT_USER AS
/* $Header: glirechs.pls 120.4 2005/05/05 01:20:03 kvora ship $ */
--
-- Package
--   GL_RECURRING_HEADERS_PKG
-- Purpose
--   To group all the procedures/functions for gl_recurring_headers_pkg.
-- History
--   01.08.94   E. Rumanang   Created
--

  --
  -- Procedure
  --   is_valid_header_exist
  -- Purpose
  --   Check if the batch has valid headers.  If it has return TRUE,
  --   else return FALSE.
  -- History
  --   01.08.94   E. Rumanang   Created
  -- Arguments
  --   x_set_of_books_id        The set of books to be checked
  --   x_recurring_batch_id	The batch of the headers.
  -- Example
  --   GL_RECURRING_HEADERS_PKG.is_valid_header_exist( 10, 100 );
  -- Notes
  --
  FUNCTION is_valid_header_exist(
    x_ledger_id NUMBER,
    x_recurring_batch_id NUMBER ) RETURN BOOLEAN;




  --
  -- Procedure
  --   check_unique
  -- Purpose
  --   Ensure new recurring entry name is unique.
  -- History
  --   20-FEB-1994  ERumanan  Created.
  -- Arguments
  --   x_rowid    The ID of the row to be checked
  --   x_name     The recurring entry name to be checked
  --   x_batchid  The recurring batch id to be checked
  -- Example
  --   GL_RECURRING_HEADERS_PKG.check_unique( 12345, 'Nascar Formula 1' );
  -- Notes
  --
  PROCEDURE check_unique( x_rowid    VARCHAR2,
                          x_name     VARCHAR2,
                          x_batchid  NUMBER );



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
  --   :REC_BATCH.recurring_batch_id := GL_RECURRING_HEADERS_PKG.get_unique_id;
  -- Notes
  --
  FUNCTION get_unique_id RETURN NUMBER;




  --
  -- Procedure
  --   delete_rows
  -- Purpose
  --   Delete rows for all the detail blocks.
  -- History
  --   20-MAR-1994  ERumanan  Created.
  -- Arguments
  --   x_batch_id  The recurring batch id.
  -- Example
  --   GL_RECURRING_HEADERS_PKG.delete_rows( 12345 );
  -- Notes
  --
  PROCEDURE delete_rows( x_batch_id    NUMBER );





-- *************************************************************************

PROCEDURE Insert_Row(X_Rowid                 IN OUT  NOCOPY VARCHAR2,
                     X_Recurring_Header_Id    IN OUT NOCOPY NUMBER,
                     X_Last_Update_Date                     DATE,
                     X_Last_Updated_By                      NUMBER,
                     X_Ledger_Id                            NUMBER,
                     X_Name                                 VARCHAR2,
                     X_Je_Category_Name                     VARCHAR2,
                     X_Enabled_Flag                         VARCHAR2,
                     X_Allocation_Flag                      VARCHAR2,
                     X_Currency_Code                        VARCHAR2,
                     X_Currency_Conversion_Type             VARCHAR2,
                     X_Creation_Date                        DATE,
                     X_Created_By                           NUMBER,
                     X_Last_Update_Login                    NUMBER,
                     X_Recurring_Batch_Id                   NUMBER,
                     X_Period_Type                          VARCHAR2,
                     X_Last_Executed_Period_Name            VARCHAR2,
                     X_Last_Executed_Date                   DATE,
                     X_Start_Date_Active                    DATE,
                     X_End_Date_Active                      DATE,
                     X_Attribute1                           VARCHAR2,
                     X_Attribute2                           VARCHAR2,
                     X_Attribute3                           VARCHAR2,
                     X_Attribute4                           VARCHAR2,
                     X_Attribute5                           VARCHAR2,
                     X_Attribute6                           VARCHAR2,
                     X_Attribute7                           VARCHAR2,
                     X_Attribute8                           VARCHAR2,
                     X_Attribute9                           VARCHAR2,
                     X_Attribute10                          VARCHAR2,
                     X_Context                              VARCHAR2
                     );




PROCEDURE Lock_Row(X_Rowid                                  VARCHAR2,
                   X_Recurring_Header_Id                    NUMBER,
                   X_Ledger_Id                              NUMBER,
                   X_Name                                   VARCHAR2,
                   X_Je_Category_Name                       VARCHAR2,
                   X_Enabled_Flag                           VARCHAR2,
                   X_Allocation_Flag                        VARCHAR2,
                   X_Currency_Code                          VARCHAR2,
                   X_Currency_Conversion_Type               VARCHAR2,
                   X_Recurring_Batch_Id                     NUMBER,
                   X_Period_Type                            VARCHAR2,
                   X_Last_Executed_Period_Name              VARCHAR2,
                   X_Last_Executed_Date                     DATE,
                   X_Start_Date_Active                      DATE,
                   X_End_Date_Active                        DATE,
                   X_Attribute1                             VARCHAR2,
                   X_Attribute2                             VARCHAR2,
                   X_Attribute3                             VARCHAR2,
                   X_Attribute4                             VARCHAR2,
                   X_Attribute5                             VARCHAR2,
                   X_Attribute6                             VARCHAR2,
                   X_Attribute7                             VARCHAR2,
                   X_Attribute8                             VARCHAR2,
                   X_Attribute9                             VARCHAR2,
                   X_Attribute10                            VARCHAR2,
                   X_Context                                VARCHAR2
                   );




PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Recurring_Header_Id                 NUMBER,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Ledger_Id                           NUMBER,
                     X_Name                                VARCHAR2,
                     X_Je_Category_Name                    VARCHAR2,
                     X_Enabled_Flag                        VARCHAR2,
                     X_Allocation_Flag                     VARCHAR2,
                     X_Currency_Code                       VARCHAR2,
                     X_Currency_Conversion_Type            VARCHAR2,
                     X_Last_Update_Login                   NUMBER,
                     X_Recurring_Batch_Id                  NUMBER,
                     X_Period_Type                         VARCHAR2,
                     X_Last_Executed_Period_Name           VARCHAR2,
                     X_Last_Executed_Date                  DATE,
                     X_Start_Date_Active                   DATE,
                     X_End_Date_Active                     DATE,
                     X_Attribute1                          VARCHAR2,
                     X_Attribute2                          VARCHAR2,
                     X_Attribute3                          VARCHAR2,
                     X_Attribute4                          VARCHAR2,
                     X_Attribute5                          VARCHAR2,
                     X_Attribute6                          VARCHAR2,
                     X_Attribute7                          VARCHAR2,
                     X_Attribute8                          VARCHAR2,
                     X_Attribute9                          VARCHAR2,
                     X_Attribute10                         VARCHAR2,
                     X_Context                             VARCHAR2
  --                   Currency_Changed       IN OUT NOCOPY VARCHAR2
                     );




PROCEDURE Delete_Row(X_Rowid VARCHAR2);





END GL_RECURRING_HEADERS_PKG;

 

/
