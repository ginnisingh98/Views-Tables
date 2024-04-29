--------------------------------------------------------
--  DDL for Package GL_HISTORICAL_RATES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_HISTORICAL_RATES_PKG" AUTHID CURRENT_USER as
/* $Header: glirthts.pls 120.5 2005/06/19 16:55:37 mgowda ship $ */

   TYPE SegmentArray IS TABLE OF VARCHAR2(200)
      INDEX BY BINARY_INTEGER;
  --
  -- Procedure
  --   check_unique
  -- Purpose
  --   Make sure the new row is unique.
  -- History
  --   14-APR-94  ERumanan  Created.
  -- Arguments
  --   x_rowid
  --   x_ledger_id
  --   x_code_combination_id
  --   x_period_name
  --   x_target_currency
  --   x_usage_code
  -- Example
  --   GL_HISTORICAL_RATES_PKG.check_unique( '12345', 1, 10000, 'JAN-94', 'USD', 'S' );
  -- Notes
  --
  PROCEDURE check_unique( x_rowid  VARCHAR2,
                          x_ledger_id   NUMBER,
                          x_code_combination_id   NUMBER,
                          x_period_name   VARCHAR2,
                          x_target_currency   VARCHAR2,
			  x_usage_code 	VARCHAR2);




PROCEDURE Insert_Row(X_Rowid                         IN OUT NOCOPY VARCHAR2,
                     X_Ledger_Id                            NUMBER,
                     X_Period_Name                          VARCHAR2,
                     X_Period_Num                           NUMBER,
                     X_Period_Year                          NUMBER,
                     X_Code_Combination_Id                  NUMBER,
                     X_Target_Currency                      VARCHAR2,
                     X_Update_Flag                          VARCHAR2,
                     X_Last_Update_Date                     DATE,
                     X_Last_Updated_By                      NUMBER,
                     X_Creation_Date                        DATE,
                     X_Created_By                           NUMBER,
                     X_Last_Update_Login                    NUMBER,
                     X_Rate_Type                            VARCHAR2,
                     X_Translated_Rate                      NUMBER,
                     X_Translated_Amount                    NUMBER,
                     X_Account_Type                         VARCHAR2,
                     X_Attribute1                           VARCHAR2,
                     X_Attribute2                           VARCHAR2,
                     X_Attribute3                           VARCHAR2,
                     X_Attribute4                           VARCHAR2,
                     X_Attribute5                           VARCHAR2,
                     X_Context                              VARCHAR2,
		     X_Usage_Code			    VARCHAR2,
		     X_Chart_of_Accounts_Id		    NUMBER
                     );

PROCEDURE Lock_Row(X_Rowid                                  VARCHAR2,
                   X_Ledger_Id                              NUMBER,
                   X_Period_Name                            VARCHAR2,
                   X_Period_Num                             NUMBER,
                   X_Period_Year                            NUMBER,
                   X_Code_Combination_Id                    NUMBER,
                   X_Target_Currency                        VARCHAR2,
                   X_Update_Flag                            VARCHAR2,
                   X_Rate_Type                              VARCHAR2,
                   X_Translated_Rate                        NUMBER,
                   X_Translated_Amount                      NUMBER,
                   X_Account_Type                           VARCHAR2,
                   X_Attribute1                             VARCHAR2,
                   X_Attribute2                             VARCHAR2,
                   X_Attribute3                             VARCHAR2,
                   X_Attribute4                             VARCHAR2,
                   X_Attribute5                             VARCHAR2,
                   X_Context                                VARCHAR2,
		   X_Usage_Code			    	    VARCHAR2
                   );

PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Ledger_Id                           NUMBER,
                     X_Period_Name                         VARCHAR2,
                     X_Period_Num                          NUMBER,
                     X_Period_Year                         NUMBER,
                     X_Code_Combination_Id                 NUMBER,
                     X_Target_Currency                     VARCHAR2,
                     X_Update_Flag                         VARCHAR2,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Last_Update_Login                   NUMBER,
                     X_Rate_Type                           VARCHAR2,
                     X_Translated_Rate                     NUMBER,
                     X_Translated_Amount                   NUMBER,
                     X_Account_Type                        VARCHAR2,
                     X_Attribute1                          VARCHAR2,
                     X_Attribute2                          VARCHAR2,
                     X_Attribute3                          VARCHAR2,
                     X_Attribute4                          VARCHAR2,
                     X_Attribute5                          VARCHAR2,
                     X_Context                             VARCHAR2,
		     X_Usage_Code			   VARCHAR2,
		     X_Chart_of_Accounts_Id		   NUMBER
                     );

PROCEDURE Delete_Row(X_Rowid VARCHAR2);



   --
   -- Procedure
   --   valdiate_seg_2
   -- Purpose
   --   This is the PL/SQL API will be used in the download SQL of
   --   Historical Rates Web ADI Spreadsheet.
   -- History
   --   09-May-2003  Alan Wen  Created.
   -- Arguments
   --   2
   -- Example
   --
   -- Notes
   --

   FUNCTION valdiate_seg_2(x_chart_of_accounts_id NUMBER,
      x_concat_segments VARCHAR2)
      RETURN NUMBER;

   --
   -- Procedure
   --   valdiate_seg
   -- Purpose
   --   This is the PL/SQL API will be used in the download SQL of
   --   Historical Rates Web ADI Spreadsheet.
   -- History
   --   09-May-2003  Alan Wen  Created.
   -- Arguments
   --   2
   -- Example
   --
   -- Notes
   --

   FUNCTION valdiate_seg(x_chart_of_accounts_id NUMBER,
      x_combination_id NUMBER)
      RETURN NUMBER;

   --
   -- Procedure
   --   Insert_Row_WebADI_Wrapper
   -- Purpose
   --   This is the PL/SQL interface for the Web ADI spreadsheet interface
   --   of Historical Rates. The spreadsheet upload data to this interface
   --   and this interface will insert data to gl_historical_rates table.
   -- History
   --   14-Jan-03  Alan Wen  Created.
   -- Arguments
   --   39
   -- Example
   --
   -- Notes
   --

   PROCEDURE Insert_Row_WebADI_Wrapper(X_Ledger IN VARCHAR2,
      X_Functional_Currency IN VARCHAR2, X_Target_Currency IN VARCHAR2,
      X_PERIOD_NAME IN VARCHAR2, X_Value_Type IN VARCHAR2, X_Value IN NUMBER,
      X_Rate_Type IN VARCHAR2, X_Usage_Code IN VARCHAR2,
      X_Segment1 IN VARCHAR2, X_Segment2 IN VARCHAR2, X_Segment3 IN VARCHAR2,
      X_Segment4 IN VARCHAR2, X_Segment5 IN VARCHAR2, X_Segment6 IN VARCHAR2,
      X_Segment7 IN VARCHAR2, X_Segment8 IN VARCHAR2, X_Segment9 IN VARCHAR2,
      X_Segment10 IN VARCHAR2, X_Segment11 IN VARCHAR2,
      X_Segment12 IN VARCHAR2, X_Segment13 IN VARCHAR2,
      X_Segment14 IN VARCHAR2, X_Segment15 IN VARCHAR2,
      X_Segment16 IN VARCHAR2, X_Segment17 IN VARCHAR2,
      X_Segment18 IN VARCHAR2, X_Segment19 IN VARCHAR2,
      X_Segment20 IN VARCHAR2, X_Segment21 IN VARCHAR2,
      X_Segment22 IN VARCHAR2, X_Segment23 IN VARCHAR2,
      X_Segment24 IN VARCHAR2, X_Segment25 IN VARCHAR2,
      X_Segment26 IN VARCHAR2, X_Segment27 IN VARCHAR2,
      X_Segment28 IN VARCHAR2, X_Segment29 IN VARCHAR2,
      X_Segment30 IN VARCHAR2);

   --
   -- Procedure
   --   get_bal_seg
   -- Purpose
   --   Given COA, the function returns the balance segment number
   -- History
   --   14-Jan-03  Alan Wen  Created.
   -- Arguments
   --   x_chart_of_accounts_id
   -- Example
   --
   -- Notes
   --

   FUNCTION get_bal_seg(x_chart_of_accounts_id NUMBER)
      RETURN NUMBER;

END GL_HISTORICAL_RATES_PKG;

 

/
