--------------------------------------------------------
--  DDL for Package GL_PERIODS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_PERIODS_PKG" AUTHID CURRENT_USER AS
/* $Header: gliprdes.pls 120.6 2005/05/05 01:17:52 kvora ship $ */
--
-- Package
--   gl_period_sets_pkg
-- Purpose
--   To contain validation and insertion routines for gl_periods
-- History
--   10-07-93  	D. J. Ogg	Created

  --
  -- Procedure
  --   check_unique_num
  -- Purpose
  --   Checks to make sure that the period type/year/
  --   number combination is unique within the current
  --   calendar.
  -- History
  --   10-04-93  D. J. Ogg    Created
  -- Arguments
  --   calendar_name		Name of the calendar
  --				containing the period
  --   period_type		Type of the period
  --   period_year		Year containing the period
  --   period_num		Number of the period
  --   row_id 			The id of the row
  --				containing the period
  -- Example
  --   periods.check_unique_num('Standard', 'Month', 1993,
  --                            2, 'AA01');
  -- Notes
  --
  PROCEDURE check_unique_num(calendar_name VARCHAR2,
                             period_type VARCHAR2,
                             period_year NUMBER,
                             period_num NUMBER,
                             row_id     VARCHAR2);

  --
  -- Procedure
  --   check_unique_name
  -- Purpose
  --   Checks to make sure that the period name
  --   is unique within the current calendar.
  -- History
  --   10-04-93  D. J. Ogg    Created
  -- Arguments
  --   calendar_name		Name of the calendar
  --				containing the period
  --   period_name		Name of the period
  --   row_id 			The id of the row
  --				containing the period
  -- Example
  --   periods.check_unique_name('Standard', 'JAN-91',
  -- 				 'AA01');
  -- Notes
  --
  PROCEDURE check_unique_name(calendar_name VARCHAR2,
                              period_name VARCHAR2,
                              row_id VARCHAR2);

  --
  -- Procedure
  --   check_period_used
  -- Purpose
  --   Returns TRUE if the period has been used, or FALSE
  --   otherwise.  Calling this function always causes a
  --   check of the database to be done.  This is
  --   different from the period_used function, that only
  --   does the check the first time it is called for a
  --   given record.
  -- History
  --   10-04-93  D. J. Ogg    Created
  -- Arguments
  --   row_id           The rowid of the period to be checked
  -- Example
  --   options.check_period_used('0121.102')
  -- Notes
  --
  FUNCTION check_period_used(row_id VARCHAR2) RETURN BOOLEAN;

  --
  -- Procedure
  --   check_overlapping_period
  -- Purpose
  --   Returns TRUE if the given start and end date overlaps with
  --   some period that is not an adjustment period.
  -- History
  --   24-AUG-94  D. J. Ogg    Created
  -- Arguments
  --   x_period_set_name  The name of the calendar to be checked
  --   x_period_type      The name of the period type to be checked
  --   x_start_date	  The start date of the range
  --   x_end_date         The end date of the range
  --   row_id             The rowid of the period with the given
  --                      start and end dates
  -- Example
  --   options.check_period_used('0121.102')
  -- Notes
  --
  FUNCTION overlapping_period(x_period_set_name VARCHAR2,
			      x_period_type     VARCHAR2,
			      x_start_date      DATE,
			      x_end_date        DATE,
			      row_id            VARCHAR2) RETURN BOOLEAN;

  --
  -- Procedure
  --   period_changed
  -- Purpose
  --   Returns TRUE if some field of the  period has been changed,
  --   other than the descriptive flexfield or the adjustment period
  --   flag.
  -- History
  --   12-27-93  D. J. Ogg    Created
  -- Notes
  --
  FUNCTION period_changed(
                   X_Rowid                                  VARCHAR2,
                   X_Period_Set_Name                        VARCHAR2,
                   X_Period_Name                            VARCHAR2,
                   X_Start_Date                             DATE,
                   X_End_Date                               DATE,
                   X_Period_Type                            VARCHAR2,
                   X_Period_Year                            NUMBER,
                   X_Period_Num                             NUMBER,
                   X_Quarter_Num                            NUMBER,
                   X_Entered_Period_Name                    VARCHAR2,
                   X_Description                            VARCHAR2
                   ) RETURN BOOLEAN;

PROCEDURE Insert_Row(X_Rowid                         IN OUT NOCOPY VARCHAR2,

                     X_Period_Set_Name                      VARCHAR2,
                     X_Period_Name                          VARCHAR2,
                     X_Last_Update_Date                     DATE,
                     X_Last_Updated_By                      NUMBER,
                     X_Start_Date                           DATE,
                     X_End_Date                             DATE,
                     X_Period_Type                          VARCHAR2,
                     X_Period_Year                          NUMBER,
                     X_Period_Num                           NUMBER,
                     X_Quarter_Num                          NUMBER,
                     X_Entered_Period_Name                  VARCHAR2,
                     X_Creation_Date                        DATE,
                     X_Created_By                           NUMBER,
                     X_Last_Update_Login                    NUMBER,
                     X_Description                          VARCHAR2,
                     X_Attribute1                           VARCHAR2,
                     X_Attribute2                           VARCHAR2,
                     X_Attribute3                           VARCHAR2,
                     X_Attribute4                           VARCHAR2,
                     X_Attribute5                           VARCHAR2,
                     X_Attribute6                           VARCHAR2,
                     X_Attribute7                           VARCHAR2,
                     X_Attribute8                           VARCHAR2,
                     X_Context                              VARCHAR2,
                     X_Adjustment_Period_Flag               VARCHAR2
                     );

PROCEDURE Lock_Row(X_Rowid                                  VARCHAR2,
                   X_Period_Set_Name                        VARCHAR2,
                   X_Period_Name                            VARCHAR2,
                   X_Start_Date                             DATE,
                   X_End_Date                               DATE,
                   X_Period_Type                            VARCHAR2,
                   X_Period_Year                            NUMBER,
                   X_Period_Num                             NUMBER,
                   X_Quarter_Num                            NUMBER,
                   X_Entered_Period_Name                    VARCHAR2,
                   X_Description                            VARCHAR2,
                   X_Attribute1                             VARCHAR2,
                   X_Attribute2                             VARCHAR2,
                   X_Attribute3                             VARCHAR2,
                   X_Attribute4                             VARCHAR2,
                   X_Attribute5                             VARCHAR2,
                   X_Attribute6                             VARCHAR2,
                   X_Attribute7                             VARCHAR2,
                   X_Attribute8                             VARCHAR2,
                   X_Context                                VARCHAR2,
                   X_Adjustment_Period_Flag                 VARCHAR2
                   );

PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Period_Set_Name                     VARCHAR2,
                     X_Period_Name                         VARCHAR2,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Start_Date                          DATE,
                     X_End_Date                            DATE,
                     X_Period_Type                         VARCHAR2,
                     X_Period_Year                         NUMBER,
                     X_Period_Num                          NUMBER,
                     X_Quarter_Num                         NUMBER,
                     X_Entered_Period_Name                 VARCHAR2,
                     X_Last_Update_Login                   NUMBER,
                     X_Description                         VARCHAR2,
                     X_Attribute1                          VARCHAR2,
                     X_Attribute2                          VARCHAR2,
                     X_Attribute3                          VARCHAR2,
                     X_Attribute4                          VARCHAR2,
                     X_Attribute5                          VARCHAR2,
                     X_Attribute6                          VARCHAR2,
                     X_Attribute7                          VARCHAR2,
                     X_Attribute8                          VARCHAR2,
                     X_Context                             VARCHAR2,
                     X_Adjustment_Period_Flag              VARCHAR2
                     );

PROCEDURE Delete_Row(X_Rowid VARCHAR2);

  --
  -- Procedure
  --   Load_Row
  -- Purpose
  --   Loads A row into the gl_periods table. Created for Bug Fix: 2523133
  -- History
  --   10-10-02   N Kasu    Created
  -- Notes
  --

PROCEDURE Load_Row(X_Period_Set_Name                      VARCHAR2,
                     X_Period_Name                          VARCHAR2,
		     X_Owner			            VARCHAR2,
                     X_Start_Date                           VARCHAR2,
                     X_End_Date                             VARCHAR2,
                     X_Period_Type                          VARCHAR2,
                     X_Period_Year                          NUMBER,
                     X_Period_Num                           NUMBER,
                     X_Quarter_Num                          NUMBER,
                     X_Entered_Period_Name                  VARCHAR2,
                     X_Description                          VARCHAR2,
                     X_Attribute1                           VARCHAR2,
                     X_Attribute2                           VARCHAR2,
                     X_Attribute3                           VARCHAR2,
                     X_Attribute4                           VARCHAR2,
                     X_Attribute5                           VARCHAR2,
                     X_Attribute6                           VARCHAR2,
                     X_Attribute7                           VARCHAR2,
                     X_Attribute8                           VARCHAR2,
                     X_Context                              VARCHAR2,
                     X_Adjustment_Period_Flag               VARCHAR2
  );





  --
  -- Procedure
  --   maintain_quarter_start_date
  -- Purpose
  --   maintains quarter_start date in the GL_PERIODS and GL_PERIOD_STATUSES
  -- History
  -- 12-04-95  	E Weinstein  	Created
  -- Arguments
  --   x_period_set_name	Name of the calendar
  --				containing the period
  --   x_period_type		Type of the period
  --   x_period_year		accounting period year
  --   x_quarter_num		quarter number
  --   x_operation		UPDATE or INSERT for Update_Row or Insert_Row
  --   x_quarter_start_date	returns new quarter_start_date
  -- Example
  --  maintain_quarter_start_date('Barclays','Month',1993,2,
  --  TO_DATE('01-04-1993', 'DD-MM-YYYY'),'UPDATE');
  -- Notes
  --
    PROCEDURE maintain_quarter_start_date
			(
			x_period_set_name 	VARCHAR2,
			x_period_type     	VARCHAR2,
			x_period_year		NUMBER,
			x_quarter_num		NUMBER,
			x_start_date		DATE,
			x_operation		VARCHAR2,
			x_quarter_start_date	IN OUT NOCOPY DATE
			);

  --
  -- Procedure
  --   maintain_year_start_date
  -- Purpose
  --   maintains year_start_date in the GL_PERIODS and GL_PERIOD_STATUSES
  -- History
  -- 12-04-95  	E Weinstein  	Created
  -- Arguments
  --   x_period_set_name	Name of the calendar
  --				containing the period
  --   x_period_type		Type of the period
  --   x_period_year		accounting period year
  --   x_operation		UPDATE or INSERT for Update_Row or Insert_Row
  --   x_year_start_date	returns new year_start_date
  -- Example
  --  maintain_year_start_date('Barclays','Month',1993,2,
  --  TO_DATE('01-04-1993', 'DD-MM-YYYY'),'UPDATE');
  -- Notes
  --
    PROCEDURE maintain_year_start_date
			(
			x_period_set_name 	VARCHAR2,
			x_period_type     	VARCHAR2,
			x_period_year		NUMBER,
			x_start_date		DATE,
			x_operation		VARCHAR2,
			x_year_start_date	IN OUT NOCOPY DATE
			);
  --
  -- Function
  --   period_set_with_AB
  -- Purpose
  --   returns YES if this period_set_name is being used by
  -- set of books with Average Balancing enabled. otherwise returns NO
  -- History
  -- 12-04-95  	E Weinstein  	Created
  -- Arguments
  --   x_period_set_name	Name of the calendar
  -- Example
  -- period_set_with_AB('Barclays');
  -- Notes
  --
    FUNCTION period_set_with_AB
			(
			x_period_set_name 	VARCHAR2
			)  RETURN VARCHAR2;

  --
  -- Procedure
  --   maintain_AB_data
  -- Purpose
  --   higher level procedure which calls other AB-related functions and is
  --   being called from Insert_Row/Update_Row (gl_period_pkg)
  -- History
  -- 12-04-95  	E Weinstein  	Created
  -- Arguments
  --   x_operation		UPDATE or INSERT for Update_Row or Insert_Row
  --   x_period_set_name	Name of the calendar
  --				containing the period
  --   x_period_type		Type of the period
  --   x_period_year		accounting period year
  --   x_adjust_period_flag	calendar period adjustment status
  --   x_start_date_old		previous start date for this period
  --   x_start_date_new		new start date for this period
  --   x_end_date		date on which accounting period ends
  --   x_period_name		accounting period name
  --   x_period_year_old	previous period_year for this period
  --   x_period_year_new	new period_year for this period
  --   x_quarter_num_old	previous quarter_num for this period
  --   x_quarter_num_new	new quarter_num for this period
  --   x_quarter_start_date	returns new quarter_start_date
  --   x_year_start_date	returns new year_start_date
  -- Example
  --  maintain_quarter_start_date('Barclays','Month',1993,2,
  --  TO_DATE('01-04-1993', 'DD-MM-YYYY'),'UPDATE');
  -- Notes
  --
    PROCEDURE maintain_AB_data
			(
			x_operation		VARCHAR2,
			x_period_set_name 	VARCHAR2,
			x_period_type     	VARCHAR2,
			x_adjust_period_flag	VARCHAR2,
			x_start_date_old	DATE,
			x_start_date_new	DATE,
			x_end_date		DATE,
			x_period_name		VARCHAR2,
			x_period_year_old	NUMBER,
			x_period_year_new	NUMBER,
			x_quarter_num_old	NUMBER,
			x_quarter_num_new	NUMBER,
			x_quarter_start_date	IN OUT NOCOPY DATE,
			x_year_start_date	IN OUT NOCOPY DATE,
			x_CREATION_DATE		DATE,
			x_CREATED_BY		NUMBER,
			x_LAST_UPDATE_DATE	DATE,
			x_LAST_UPDATED_BY	NUMBER,
			x_LAST_UPDATE_LOGIN	NUMBER
			);

-- Procedure
--  Insert_Period
-- Purpose
--  Insert into gl_periods table. Called by the Calendar iSpeed API.
-- History
--  15-JAN-01  O Monnier     Created
-- Arguments
--
PROCEDURE Insert_Period(Y_Rowid                         IN OUT NOCOPY VARCHAR2,
                        Y_Period_Set_Name                      VARCHAR2,
                        Y_Period_Name                          VARCHAR2,
                        Y_Last_Update_Date                     DATE,
                        Y_Last_Updated_By                      NUMBER,
                        Y_Start_Date                           DATE,
                        Y_End_Date                             DATE,
                        Y_Period_Type                          VARCHAR2,
                        Y_Period_Year                          NUMBER,
                        Y_Period_Num                           NUMBER,
                        Y_Quarter_Num                          NUMBER,
                        Y_Entered_Period_Name                  VARCHAR2,
                        Y_Creation_Date                        DATE,
                        Y_Created_By                           NUMBER,
                        Y_Last_Update_Login                    NUMBER,
                        Y_Description                          VARCHAR2,
                        Y_Attribute1                           VARCHAR2,
                        Y_Attribute2                           VARCHAR2,
                        Y_Attribute3                           VARCHAR2,
                        Y_Attribute4                           VARCHAR2,
                        Y_Attribute5                           VARCHAR2,
                        Y_Attribute6                           VARCHAR2,
                        Y_Attribute7                           VARCHAR2,
                        Y_Attribute8                           VARCHAR2,
                        Y_Context                              VARCHAR2,
                        Y_Adjustment_Period_Flag               VARCHAR2
                        );

-- Procedure
--  Update_Period
-- Purpose
--  Update gl_periods table. Called by the Calendar iSpeed API.
-- History
--  15-JAN-01  O Monnier     Created
-- Arguments
--
PROCEDURE Update_Period(Y_Rowid                         IN OUT NOCOPY VARCHAR2,
                        Y_Period_Set_Name                      VARCHAR2,
                        Y_Period_Name                          VARCHAR2,
                        Y_Last_Update_Date                     DATE,
                        Y_Last_Updated_By                      NUMBER,
                        Y_Start_Date                           DATE,
                        Y_End_Date                             DATE,
                        Y_Period_Type                          VARCHAR2,
                        Y_Period_Year                          NUMBER,
                        Y_Period_Num                           NUMBER,
                        Y_Quarter_Num                          NUMBER,
                        Y_Entered_Period_Name                  VARCHAR2,
                        Y_Last_Update_Login                    NUMBER,
                        Y_Description                          VARCHAR2,
                        Y_Attribute1                           VARCHAR2,
                        Y_Attribute2                           VARCHAR2,
                        Y_Attribute3                           VARCHAR2,
                        Y_Attribute4                           VARCHAR2,
                        Y_Attribute5                           VARCHAR2,
                        Y_Attribute6                           VARCHAR2,
                        Y_Attribute7                           VARCHAR2,
                        Y_Attribute8                           VARCHAR2,
                        Y_Context                              VARCHAR2,
                        Y_Adjustment_Period_Flag               VARCHAR2
                        );

END gl_periods_pkg;

 

/
