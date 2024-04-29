--------------------------------------------------------
--  DDL for Package GL_DAILY_RATES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_DAILY_RATES_PKG" AUTHID CURRENT_USER as
/* $Header: glirtdys.pls 120.7 2005/05/05 01:21:14 kvora ship $ */
--
-- Package
--   gl_daily_rates_pkg
-- Purpose
--   To contain validation and insertion routines for gl_daily_rates
-- History
--   07-29-97	W Wong		Created

  --
  -- Procedure
  --  Insert_Row
  --
  -- Purpose
  --   Inserts two rows into gl_daily_rates:
  --   one for the original conversion rate ( From Currency -> To Currency )
  --   one for the inverse conversion rate  ( To Currency   -> From Currency )
  --
  -- History
  --   07-29-97	W Wong		Created
  --
  -- Arguments
  --   All the columns of the table GL_DAILY_RATES and
  --   X_Average_Balances_Used	 		Average Balances Used
  --   X_Euro_Currency				Currency Code of EURO
  --
  -- Example
  --   gl_daily_rates.Insert_Row(....);
  --
  -- Notes
  --
PROCEDURE Insert_Row(X_Rowid                         IN OUT NOCOPY VARCHAR2,
		     X_Inverse_Rowid                 IN OUT NOCOPY VARCHAR2,
                     X_From_Currency                        VARCHAR2,
                     X_To_Currency                          VARCHAR2,
                     X_Conversion_Date                      DATE,
                     X_Conversion_Type                      VARCHAR2,
                     X_Conversion_Rate                      NUMBER,
                     X_Inverse_Conversion_Rate              NUMBER,
		     X_Status_Code        	     IN OUT NOCOPY VARCHAR2,
                     X_Creation_Date                        DATE,
                     X_Created_By                           NUMBER,
                     X_Last_Update_Date                     DATE,
                     X_Last_Updated_By                      NUMBER,
                     X_Last_Update_Login                    NUMBER,
                     X_Context                              VARCHAR2,
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
                     X_Attribute11                          VARCHAR2,
                     X_Attribute12                          VARCHAR2,
                     X_Attribute13                          VARCHAR2,
                     X_Attribute14                          VARCHAR2,
                     X_Attribute15                          VARCHAR2,
		     X_Average_Balances_Used		    VARCHAR2,
		     X_Euro_Currency			    VARCHAR2
                     );
  --
  -- Procedure
  --  Lock_Row
  --
  -- Purpose
  --   Locks a pair of rows in gl_daily_rates
  --
  -- History
  --   07-29-97	W Wong		Created
  --
  -- Arguments
  --   All the columns of the table GL_DAILY_RATES
  --
  -- Example
  --   gl_daily_rates.Lock_Row(....);
  --
  -- Notes
  --
PROCEDURE Lock_Row(X_Rowid                                VARCHAR2,
		   X_Inverse_Rowid			  VARCHAR2,
                   X_From_Currency                        VARCHAR2,
                   X_To_Currency                          VARCHAR2,
                   X_Conversion_Date                      DATE,
                   X_Conversion_Type                      VARCHAR2,
                   X_Conversion_Rate                      NUMBER,
                   X_Inverse_Conversion_Rate              NUMBER,
		   X_Status_Code        		  VARCHAR2,
                   X_Creation_Date                        DATE,
                   X_Created_By                           NUMBER,
                   X_Last_Update_Date                     DATE,
                   X_Last_Updated_By                      NUMBER,
                   X_Last_Update_Login                    NUMBER,
                   X_Context                              VARCHAR2,
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
                   X_Attribute11                          VARCHAR2,
                   X_Attribute12                          VARCHAR2,
                   X_Attribute13                          VARCHAR2,
                   X_Attribute14                          VARCHAR2,
                   X_Attribute15                          VARCHAR2
                   );
  --
  -- Procedure
  --
  --  Update_Row
  --
  -- Purpose
  --   Updates a pair of rows in gl_daily_rates.
  --
  -- History
  --   07-29-97	W Wong		Created
  --
  -- Arguments
  --   All the columns of the table GL_DAILY_RATES and
  --   X_Average_Balances_Used	 		Average Balances Used
  --   X_Euro_Currency				Currency Code of EURO
  --
  -- Example
  --   gl_daily_rates.Update_Row(....);
  --
  -- Notes
  --
PROCEDURE Update_Row(X_Rowid                                VARCHAR2,
                     X_Inverse_Rowid                        VARCHAR2,
                     X_From_Currency                        VARCHAR2,
                     X_To_Currency                          VARCHAR2,
                     X_Conversion_Date                      DATE,
                     X_Conversion_Type                      VARCHAR2,
                     X_Conversion_Rate                      NUMBER,
                     X_Inverse_Conversion_Rate              NUMBER,
		     X_Status_Code        	     IN OUT NOCOPY VARCHAR2,
                     X_Creation_Date                        DATE,
                     X_Created_By                           NUMBER,
                     X_Last_Update_Date                     DATE,
                     X_Last_Updated_By                      NUMBER,
                     X_Last_Update_Login                    NUMBER,
                     X_Context                              VARCHAR2,
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
                     X_Attribute11                          VARCHAR2,
                     X_Attribute12                          VARCHAR2,
                     X_Attribute13                          VARCHAR2,
                     X_Attribute14                          VARCHAR2,
                     X_Attribute15                          VARCHAR2,
		     X_Average_Balances_Used		    VARCHAR2,
		     X_Euro_Currency			    VARCHAR2
                     );
  --
  -- Procedure
  --
  --  Delete_Row
  --
  -- Purpose
  --   Deletes a row from gl_daily_rates
  --
  -- History
  --   07-29-97	W Wong		Created
  --
  -- Arguments
  --    X_Rowid         	Rowid of the row with conversion rate
  --    X_Inverse_Rowid		Rowid of the row with inverse conversion rate
  --    X_From_Currency		From Currency
  --    X_To_Currency		To Currency
  --    X_Conversion_Type	Conversion Type
  --    X_Conversion_Date	Conversion Date
  --    X_Status_Code		Status Code
  --    X_Average_Balances_Used Average Balance Used Flag
  --    X_Euro_Currency		Currency code of the Euro currency
  --
  -- Example
  --   gl_daily_rates.delete_row('...');
  --
  -- Notes
  --
PROCEDURE Delete_Row(X_Rowid    	                    VARCHAR2,
                     X_Inverse_Rowid	                    VARCHAR2,
		     X_From_Currency			    VARCHAR2,
		     X_To_Currency			    VARCHAR2,
		     X_Conversion_Type			    VARCHAR2,
		     X_Conversion_Date			    DATE,
		     X_Status_Code        	     IN OUT NOCOPY VARCHAR2,
		     X_Average_Balances_Used		    VARCHAR2,
		     X_Euro_Currency			    VARCHAR2
		     );

  --
  -- Procedure
  --   Check_Unique
  --
  -- Purpose
  --   Checks to make sure that gl_daily_rates is unique.
  --
  -- History
  --   07-29-97	W Wong		Created
  --
  -- Arguments
  --   X_Rowid                   	The row ID
  --   X_From_Currency			From Currency
  --   X_To_Currency			To Currency
  --   X_Conversion_Date		Conversion Date
  --   X_Conversion_Type		Conversion Type
  --
  -- Example
  --   gl_daily_rates.check_unique(...);
  --
  -- Notes
  --
PROCEDURE Check_Unique(X_Rowid                  VARCHAR2,
                       X_From_Currency          VARCHAR2,
                       X_To_Currency            VARCHAR2,
                       X_Conversion_Date        DATE,
                       X_Conversion_Type        VARCHAR2);

  --
  -- Function
  --   Used_In_Ledger
  --
  -- Purpose
  --   Checks if the specified currency and conversion type is
  --   being used by any average ledgers.
  --
  -- History
  --   08-06-97	W Wong	Created
  --
  -- Arguments
  --   X_From_Currency                  From Currency
  --   X_To_Currency                    To Currency
  --   X_Conversion_Type                Conversion Type
  --   X_Euro_Currency			Currency code for the EURO currency
  --   X_Conversion_Date		Conversion Date
  --
  -- Example
  --   gl_daily_rates.used_in_ledger(...)
  --
  -- Notes
  --
FUNCTION Used_In_Ledger( X_From_Currency          VARCHAR2,
		         X_To_Currency            VARCHAR2,
                         X_Conversion_Type        VARCHAR2,
			 X_Euro_Currency          VARCHAR2,
			 X_Conversion_Date        DATE ) RETURN BOOLEAN;


 --
  -- Procedure
  --  Insert_DateRange
  --
  -- Purpose
  --   Inserts rows into gl_daily_rates_interface:
  --
  -- History
  --   09-07-00	K Chang		Created
  --
  -- Arguments
  --   All the columns of the table GL_DAILY_RATES_INTERFACE
  --
  -- Example
  --   gl_daily_rates.Insert_DateRange(....);
  --
  -- Notes
  --
PROCEDURE Insert_DateRange(X_From_Currency                        VARCHAR2,
                           X_To_Currency                          VARCHAR2,
                           X_From_Conversion_Date                 DATE,
                           X_To_Conversion_Date                   DATE,
                           X_User_Conversion_Type                 VARCHAR2,
                           X_Conversion_Rate                      NUMBER,
                           X_Mode_Flag                            VARCHAR2,
                     	   X_Inverse_Conversion_Rate              NUMBER,
                     	   X_User_Id                              NUMBER,
                     	   X_Launch_Rate_Change                   VARCHAR2,
                     	   X_Error_Code                           VARCHAR2,
                     	   X_Context                              VARCHAR2,
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
                     	   X_Attribute11                          VARCHAR2,
                     	   X_Attribute12                          VARCHAR2,
                     	   X_Attribute13                          VARCHAR2,
                     	   X_Attribute14                          VARCHAR2,
                     	   X_Attribute15                          VARCHAR2,
		     	   X_Used_For_AB_Translation		  VARCHAR2
                     );

  --
  -- Procedure
  --  Validate_DailyRates
  --
  -- Purpose
  --   This procedure is created for Ispeed Daily Rates API.
  --   It validate the following:
  --   o From_Currency and To_Currency are not the same
  --   o From_Currency and To_Currency:
  --     a. Currency exists in the FND_CURRENCIES table
  --     b. Currency is enabled
  --     c. Currency is not out of date
  --     d. Currency is not an EMU currency
  --   o Range of dates specified does not exceeds 366 days
  --
  -- History
  --   09-06-00	K Chang		Created
  --
  -- Arguments
  --  X_From_Currency		From Currency
  --  X_To_Currency		To Currency
  --  X_Converson_Date          Conversion Date
  --  X_Conversion_Type         Conversion Type
  --  X_From_Conversion_Date    From Conversion Date
  --  X_To_Conversion_Date      To Conversion Date
  --
  -- Example
  --   gl_daily_rates_pkg.Validate_DailyRates(....);
  --
  -- Notes
  --
  PROCEDURE Validate_DailyRates(X_From_Currency             VARCHAR2,
                     X_To_Currency                          VARCHAR2,
		     X_Conversion_Date                      DATE,
                     X_Conversion_Type                      VARCHAR2,
		     X_From_Conversion_Date		    DATE,
                     X_To_Conversion_Date  		    DATE
 );

  --
  -- Function
  --  Submit_Conc_Request
  --
  -- Purpose
  --   Launch Conversion Rate Change concurrent program for
  --   Ispeed Daily Rates API
  --
  -- History
  --   09-06-00	K Chang		Created
  --
  -- Arguments
  --
  --
  -- Example
  --   gl_daily_rates_pkg.Submit_Conc_Request(....);
  --
  -- Notes
  --
  FUNCTION submit_conc_request RETURN NUMBER;

  --
  -- Procedure
  --  Upload_Row
  --
  -- Purpose
  --   Inserts two rows into gl_daily_rates for Ispeed daily rates API:
  --   one for the original conversion rate ( From Currency -> To Currency )
  --   one for the inverse conversion rate  ( To Currency   -> From Currency )
  --
  -- History
  --   09-21-00	K Chang		Created
  --
  -- Arguments
  --   All the columns of the table GL_DAILY_RATES and
  --   X_Average_Balances_Used	 		Average Balances Used
  --   X_Euro_Currency				Currency Code of EURO
  --
  -- Example
  --   gl_daily_rates.Upload_Row(....);
  --
  -- Notes
  --
PROCEDURE Upload_Row(X_Rowid                         IN OUT NOCOPY VARCHAR2,
		     X_Inverse_Rowid                 IN OUT NOCOPY VARCHAR2,
                     X_From_Currency                        VARCHAR2,
                     X_To_Currency                          VARCHAR2,
                     X_Conversion_Date                      DATE,
                     X_Conversion_Type                      VARCHAR2,
                     X_Conversion_Rate                      NUMBER,
                     X_Inverse_Conversion_Rate              NUMBER,
		     X_Status_Code        	     IN OUT NOCOPY VARCHAR2,
                     X_Creation_Date                        DATE,
                     X_Created_By                           NUMBER,
                     X_Last_Update_Date                     DATE,
                     X_Last_Updated_By                      NUMBER,
                     X_Last_Update_Login                    NUMBER,
                     X_Context                              VARCHAR2,
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
                     X_Attribute11                          VARCHAR2,
                     X_Attribute12                          VARCHAR2,
                     X_Attribute13                          VARCHAR2,
                     X_Attribute14                          VARCHAR2,
                     X_Attribute15                          VARCHAR2,
		     X_Average_Balances_Used		    VARCHAR2,
		     X_Euro_Currency			    VARCHAR2
                     );

END GL_DAILY_RATES_PKG;

 

/
