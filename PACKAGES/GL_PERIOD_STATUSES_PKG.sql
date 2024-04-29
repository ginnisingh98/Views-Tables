--------------------------------------------------------
--  DDL for Package GL_PERIOD_STATUSES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_PERIOD_STATUSES_PKG" AUTHID CURRENT_USER AS
/* $Header: glipstas.pls 120.6 2006/08/11 12:31:06 aktelang ship $ */
--
-- Package
--   gl_period_statuses_pkg
-- Purpose
--   To contain validation and insertion routines for gl_period_statuses
-- History
--   10-07-93  	D. J. Ogg	Created
--   01-10-94   D. J. Ogg       Modified select_columns to also return the
--                              period number and year

  --
  -- Procedure
  --   default_actual_period
  -- Purpose
  --   Finds the default period for actual batches in the given
  --   ledger
  -- History
  --   12-30-93  D. J. Ogg    Created
  -- Arguments
  --   acc_id           The current access set id
  --   led_id		The ledger to find the default period
  --                    for.
  -- Example
  --   default_period := gl_je_batches_pkg.default_actual_period(2);
  -- Notes
  --
  FUNCTION default_actual_period(acc_id NUMBER, led_id NUMBER) RETURN VARCHAR2;

  --
  -- Procedure
  --   get_next_period
  -- Purpose
  --   To get the next open period and return it in x_next_period.
  -- History
  --   01-06-94  E. Rumanang  Created
  -- Arguments
  --   x_ledger_id        Ledger id
  --   x_period			Last executed period
  --   x_next_period            Next open period
  -- Example
  --   gl_period_statuses_pkg.get_next_period(
  --     :block.ledger_id,
  --     :block.period,
  --     :block.next_period );
  -- Notes
  --
PROCEDURE get_next_period(
	x_ledger_id       NUMBER,
       	x_period		VARCHAR2,
        x_next_period	IN OUT NOCOPY 	VARCHAR2 );


  --
  -- Procedure
  --   insert_led_ps
  -- Purpose
  --   Used to insert records into gl_period_statuses
  --   for a new ledger.
  -- History
  --   12-06-93	E. Rumanang  	Created
  -- Arguments
  --   x_ledger_id	ID of new created ledger
  --   x_period_set_name	Name of the calendar
  --   x_accounted_period_type  Name of the period type
  --   x_last_update_date	The user's data who create/update the row
  --   x_last_updated_by
  --   x_last_update_login
  --   x_creation_date
  --   x_created_by
  -- Example
  --   gl_period_statuses_pkg.insert_led_ps(
  --     '1', 'Standard', 'Month', '01-JAN-93', 100, 100, '01-JAN-93', 100)
  -- Notes
  --
PROCEDURE insert_led_ps(
                        x_ledger_id       NUMBER,
                        x_period_set_name       VARCHAR2,
                        x_accounted_period_type VARCHAR2,
                        x_last_update_date      DATE,
                        x_last_updated_by       NUMBER,
                        x_last_update_login     NUMBER,
                        x_creation_date         DATE,
                        x_created_by            NUMBER );


  --
  -- Procedure
  --   insert_ps_api
  -- Purpose
  --   API for inserting period statuses records for non-GL
  --   products that need to maintain statuses for non-accounting
  --   calendars, i.e. period_set_name different from that of led.
  -- History
  --   08-06-96 U. Thimmappa 	Created
  -- Arguments
  --   x_appl_id		Applcation ID
  --   x_ledger_id	        Ledger ID
  --   x_period_name	        Name of the period
  --   x_status	                Status of the period
  --   x_period_set_name	Name of the calendar
  --   x_user_id		User ID
  --   x_login_id		Login ID
  -- Example
  --   1. gl_period_statuses_pkg.insert_ps_api(
  --        275, 1, 'JAN-93', 'O','', 1034, 1034 )
  --   2. gl_period_statuses_pkg.insert_ps_api(
  --        275, 1, 'JAN-93', 'O', 'Standard', 1034, 1034 )
  -- Notes
  --   1. If x_period_set_name is NULL, period_set_name
  --      from led will be used.
  --   2. This api is only used by PA in 10.7.
  --
PROCEDURE insert_ps_api(
                        x_appl_id               NUMBER,
                        x_ledger_id       NUMBER,
                        x_period_name           VARCHAR2,
                        x_status                VARCHAR2,
                        x_period_set_name       VARCHAR2,
                        x_user_id	        NUMBER,
                        x_login_id	        NUMBER );
  --
  -- Procedure
  --   insert_period
  -- Purpose
  --   Used to insert records into gl_period_statuses
  --   for a new period.
  -- History
  --   10-07-93  D. J. Ogg    Created
  -- Arguments
  --   x_calendar_name 		Name of the calendar the
  --				period is in
  --   x_period_name		Name of the period
  --   x_start_date		Start date of period
  --   x_end_date		End date of period
  --   x_period_type		Type of period
  --   x_period_year		Year of period
  --   x_period_num		Number of period
  --   x_quarter_num		Number of quarter that
  --				the period belongs in
  --   x_adj_period_flag	Adjustment period flag
  --   x_last_updated_by	User ID of last person to
  --				update the period
  --   x_last_update_login	Login ID of the last person
  --				to update the period
  -- Example
  --   gl_period_statuses_pkg.insert_period(
  --     'Standard', 'JAN-93', '01-JAN-93', '31-JAN-93', 'Month',
  --     1993, 1, 1, 'N', 0, 0);
  -- Notes
  --
  PROCEDURE insert_period(
			x_calendar_name		VARCHAR2,
                      	x_period_name 		VARCHAR2,
			x_start_date		DATE,
			x_end_date		DATE,
 			x_period_type 		VARCHAR2,
                     	x_period_year 		NUMBER,
                       	x_period_num  		NUMBER,
			x_quarter_num 		NUMBER,
			x_adj_period_flag 	VARCHAR2,
			x_last_updated_by	NUMBER,
			x_last_update_login	NUMBER,
			x_quarter_start_date	DATE,
      			x_year_start_date	DATE);

  --
  -- Procedure
  --   update_period
  -- Purpose
  --   Updates the entries in gl_period_statuses associated with a given
  --   period.
  -- History
  --   10-07-93  D. J. Ogg    Created
  -- Arguments
  --   x_calendar_name 		Name of the calendar the
  --				period is in
  --   x_old_period_name	Name of the period before
  --				the update
  --   x_period_name		Name of the period after
  --				the update
  --   x_start_date		Start date of period
  --   x_end_date		End date of period
  --   x_period_type		Type of period
  --   x_period_year		Year of period
  --   x_period_num		Number of period
  --   x_quarter_num		Number of quarter that
  --				the period belongs in
  --   x_adj_period_flag	Adjustment period flag
  --   x_last_updated_by	User ID of last person to
  --				update the period
  --   x_last_update_login	Login ID of the last person
  --				to update the period
  -- Example
  --   options.update_period('Standard', 'Jan-91', 'JAN-91', '01-JAN-91',
  --                         '31-JAN-91', 'Month', 1991, 1, 1, 'N', 0, 0);
  -- Notes
  --
  PROCEDURE update_period(
			x_calendar_name		VARCHAR2,
			x_old_period_name	VARCHAR2,
                      	x_period_name 		VARCHAR2,
			x_start_date		DATE,
			x_end_date		DATE,
 			x_period_type 		VARCHAR2,
                     	x_period_year 		NUMBER,
                       	x_period_num  		NUMBER,
			x_quarter_num 		NUMBER,
			x_adj_period_flag 	VARCHAR2,
			x_last_updated_by	NUMBER,
			x_last_update_login	NUMBER);

  --
  -- Procedure
  --   delete_period
  -- Purpose
  --   Deletes the rows in gl_period_statuses associated with
  --   a period.
  -- History
  --   10-07-93  D. J. Ogg    Created
  -- Arguments
  --   x_calendar_name 		Name of the calendar the
  --				period is in
  --   x_old_period_name	Name of the period before
  --				the update
  -- Example
  --   options.delete_period('Standard', 'JAN-91');
  -- Notes
  --
  PROCEDURE delete_period(
			x_calendar_name		VARCHAR2,
			x_old_period_name	VARCHAR2);

  --
  -- Procedure
  --   select_row
  -- Purpose
  --   Gets the row from gl_period_statuses associated with
  --   the given period.
  -- History
  --   11-05-93  E. Rumanang  Created
  -- Arguments
  --   recinfo gl_period_statuses
  -- Example
  --   select_row.recinfo;
  -- Notes
  --
  PROCEDURE select_row( recinfo IN OUT NOCOPY gl_period_statuses%ROWTYPE );

  --
  -- Procedure
  --   select_columns
  -- Purpose
  --   Gets the value for closing_status, start_date, end_date, period_num,
  --   and period_year columns from gl_period_statuses associated with
  --   the given period.
  -- History
  --   11-05-93  E. Rumanang  Created
  --   01-10-94  D J Ogg      Added arguments for period num and period year
  -- Arguments
  --   x_application_id          Application id of the product
  --   x_ledger_id               Ledger id
  --   x_period_name             Name of the period
  --   x_closing_status          Status of the period
  --   x_start_date              Start date of the period
  --   x_end_date                End date of the period
  --   x_period_num              Number of the period
  --   x_period_year             Year containing the period
  -- Example
  --   gl_period_statuses_pkg.select_columns( :block.application_id,
  --     :block.ledger_id, :block.period_name, :block.closing_status,
  --     :block.start_date, :block.end_date, :block.pnum, :block.pyear );
  -- Notes
  --
  PROCEDURE select_columns(
              x_application_id            NUMBER,
              x_ledger_id           NUMBER,
              x_period_name               VARCHAR2,
              x_closing_status    IN OUT NOCOPY  VARCHAR2,
              x_start_date        IN OUT NOCOPY  DATE,
              x_end_date          IN OUT NOCOPY  DATE,
              x_period_num        IN OUT NOCOPY  NUMBER,
              x_period_year       IN OUT NOCOPY  NUMBER );


  --
  -- Procedure
  --   initialize_period_statuses
  -- Purpose
  --   Initialize the open or future enterable period statuses.
  -- History
  --   11-08-93  E. Rumanang  Created
  -- Arguments
  --   x_application_id          Application id of the product
  --   x_ledger_id               Ledger id
  --   x_period_year             period year
  --   x_period_num              period number
  --   x_user_id                 User Id
  -- Example
  --   gl_period_statuses_pkg.initialize_period_statuses(
  --     :block.application_id,
  --     :block.ledger_id,
  --     :block.period_year,
  --     :block.period_num,
  --     :block.user_id  )
  -- Notes
  --
  PROCEDURE initialize_period_statuses(
              x_application_id            NUMBER,
              x_ledger_id           NUMBER,
              x_period_year               NUMBER,
              x_period_num                NUMBER,
              x_user_id                   NUMBER );


  --
  -- Procedure
  --   select_encumbrance_periods
  -- Purpose
  --   selects 2 period_names:
  --   PS2 is the first period of year, which is prior to
  --   latest_encumbrance_year in ledgers.
  --   PS1 is prior closed/permanently closed period prior to PS2.
  -- History
  --   06-14-94  Kai Pigg	  Created
  -- Arguments
  --   x_application_id           Application id of the product
  --   x_ledger_id                Ledger id
  --   x_first_period		  PS1.period_name
  --   x_first_period_start_date  PS1.start_date
  --   x_second_period		  PS2.period_name
  --   x_second_period_year	  PS2.period_year
  --   x_second_period_start_date PS2.start_date
  -- Example
  --   gl_period_statuses_pkg.select_encumbrance_periods
  --     :block.application_id,
  --     :block.ledger_id,
  --	 :block.first_period,
  --	 :block.first_start,
  --	 :block.second_period,
  --	 :block.second_year
  --	 :block.second_start
  -- Notes
  --
  PROCEDURE select_encumbrance_periods (
              x_application_id            NUMBER,
              x_ledger_id           NUMBER,
	      x_first_period              IN OUT NOCOPY  VARCHAR2,
              x_first_period_start_date   IN OUT NOCOPY  DATE,
              x_second_period             IN OUT NOCOPY  VARCHAR2,
              x_second_period_year        IN OUT NOCOPY  NUMBER,
              x_second_period_start_date  IN OUT NOCOPY  DATE);
  --
  -- Procedure
  --   select_prior_year_1st_period
  -- Purpose
  --   selects prior years first period
  -- History
  --   06-14-94  Kai Pigg	Created
  -- Arguments
  --   x_application_id          Application id of the product
  --   x_ledger_id               Ledger id
  --   x_period_year	         Period Year
  --   x_period_name	         Period Name
  -- Example
  --   gl_period_statuses_pkg.select_prior_year_1st_period
  --     :block.application_id,
  --     :block.ledger_id,
  --	 :block.period_year,
  --	 :block.period_name)
  -- Notes
  --
  PROCEDURE select_prior_year_1st_period(
              x_application_id            NUMBER,
              x_ledger_id           NUMBER,
              x_period_year               NUMBER,
	      x_period_name	IN OUT NOCOPY	  VARCHAR2);

  --
  -- Procedure
  --   select_year_1st_period
  -- Purpose
  --   selects years first period
  -- History
  --   06-SEP-94  ERumanan  Created.
  -- Arguments
  --   x_application_id          Application id of the product
  --   x_ledger_id               Ledger id
  --   x_period_year             Period Year
  --   x_period_name             Period Name
  -- Example
  --   gl_period_statuses_pkg.select_year_1st_period
  --     :block.application_id,
  --     :block.ledger_id,
  --     :block.period_year,
  --     :block.period_name)
  -- Notes
  --
PROCEDURE select_year_1st_period(
        x_application_id                        NUMBER,
        x_ledger_id                       NUMBER,
        x_period_year                           NUMBER,
        x_period_name           IN OUT NOCOPY          VARCHAR2);


  -- Procedure
  --   get_extended_quarter
  -- Purpose
  --   Get extended quarter period.
  -- History
  --   06-SEP-94  ERumanan  Created.
  -- Arguments
  --   x_application_id
  --   x_ledger_id
  --   x_period_year
  --   x_period_name
  --   x_period_set_name
  --   x_accounted_period_type
  --   x_period_used_for_ext_actuals
  --   x_num_used_for_ext_actuals
  --   x_year_used_for_ext_actuals
  --   x_quarter_used_for_ext_actuals
  --
  PROCEDURE get_extended_quarter(
              x_application_id                       NUMBER,
              x_ledger_id                      NUMBER,
              x_period_year                          NUMBER,
              x_period_name                          VARCHAR2,
              x_period_set_name                      VARCHAR2,
              x_accounted_period_type                VARCHAR2,
              x_period_used_for_ext_actuals   IN OUT NOCOPY VARCHAR2,
              x_num_used_for_ext_actuals      IN OUT NOCOPY NUMBER,
              x_year_used_for_ext_actuals     IN OUT NOCOPY NUMBER,
              x_quarter_used_for_ext_actuals  IN OUT NOCOPY NUMBER );



  -- Procedure
  --   get_extended_year
  -- Purpose
  --   Get extended year period.
  -- History
  --   07-SEP-94  ERumanan  Created.
  -- Arguments
  --   x_application_id
  --   x_ledger_id
  --   x_period_year
  --   x_accounted_period_type
  --   x_period_used_for_ext_actuals
  --   x_num_used_for_ext_actuals
  --   x_year_used_for_ext_actuals
  --   x_quarter_used_for_ext_actuals

  PROCEDURE get_extended_year(
              x_application_id                       NUMBER,
              x_ledger_id                      NUMBER,
              x_period_year                          NUMBER,
              x_accounted_period_type                VARCHAR2,
              x_period_used_for_ext_actuals   IN OUT NOCOPY VARCHAR2,
              x_num_used_for_ext_actuals      IN OUT NOCOPY NUMBER,
              x_year_used_for_ext_actuals     IN OUT NOCOPY NUMBER,
              x_quarter_used_for_ext_actuals  IN OUT NOCOPY NUMBER );



-- The following procedures are necessary to handle the base view form.

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Application_Id                 NUMBER,
                       X_Ledger_Id                NUMBER,
                       X_Period_Name                    VARCHAR2,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Closing_Status                 VARCHAR2,
                       X_Start_Date                     DATE,
                       X_End_Date                       DATE,
                       X_Period_Type                    VARCHAR2,
                       X_Period_Year                    NUMBER,
                       X_Period_Num                     NUMBER,
                       X_Quarter_Num                    NUMBER,
                       X_Adjustment_Period_Flag         VARCHAR2,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Context                        VARCHAR2
                      );



  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Application_Id                   NUMBER,
                     X_Ledger_Id                  NUMBER,
                     X_Period_Name                      VARCHAR2,
                     X_Closing_Status                   VARCHAR2,
                     X_Start_Date                       DATE,
                     X_End_Date                         DATE,
                     X_Period_Type                      VARCHAR2,
                     X_Period_Year                      NUMBER,
                     X_Period_Num                       NUMBER,
                     X_Quarter_Num                      NUMBER,
                     X_Adjustment_Period_Flag           VARCHAR2,
                     X_Attribute1                       VARCHAR2,
                     X_Attribute2                       VARCHAR2,
                     X_Attribute3                       VARCHAR2,
                     X_Attribute4                       VARCHAR2,
                     X_Attribute5                       VARCHAR2,
                     X_Context                          VARCHAR2
                    );

  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Application_Id                 NUMBER,
                       X_Ledger_Id                NUMBER,
                       X_Period_Name                    VARCHAR2,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Closing_Status                 VARCHAR2,
                       X_Start_Date                     DATE,
                       X_End_Date                       DATE,
                       X_Period_Type                    VARCHAR2,
                       X_Period_Year                    NUMBER,
                       X_Period_Num                     NUMBER,
                       X_Quarter_Num                    NUMBER,
                       X_Adjustment_Period_Flag         VARCHAR2,
                       X_Last_Update_Login              NUMBER,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Context                        VARCHAR2
                      );


  PROCEDURE Delete_Row(X_Rowid VARCHAR2);

  --
  -- Procedure
  --   update_row_dff
  -- Purpose
  --   Updates the value for attribute columns of
  --   gl_period_statuses associated with the given period of the supplied rowid.
  -- History
  --   08/10/06	aktelang  Created
  -- Arguments
  --   X_rowid                  Row id for the period
  --   X_attribute1              Attribute column
  --   X_attribute2              Attribute column
  --   X_attribute3              Attribute column
  --   X_attribute4              Attribute column
  --   X_attribute5              Attribute column
  --   X_context                 Context column
  --   X_Last_Update_Date        Who column
  --   X_Last_Updated_By         Who column
  --   X_Last_Update_Login       Who column

  -- Example
  --   gl_period_statuses_pkg.update_row_dff( :block.rowid,
  --     :block.attribute1, :block.attribute2,
  --     :block.attribute3, :block.attribute4,
  --     :block.attribute4, :block.context,
  --     :block.Last_Update_Date, :block.Last_Updated_By,
  --     :block.Last_Update_Login)
  -- Notes
  --
  PROCEDURE update_row_dff(
  		X_rowid	                   VARCHAR2,
  		X_attribute1	                   VARCHAR2,
  		X_attribute2	                   VARCHAR2,
  		X_attribute3	                   VARCHAR2,
		X_attribute4	                   VARCHAR2,
		X_attribute5	                   VARCHAR2,
		X_context	                   VARCHAR2,
                X_Last_Update_Date                 DATE,
                X_Last_Updated_By                  NUMBER,
                X_Last_Update_Login                NUMBER );

  --
  -- Procedure
  --   get_period_by_date
  -- Purpose
  --   Gets the value for closing_status, period_name from
  --   gl_period_statuses associated with the given date.
  -- History
  --   07/31/95	Eugene Weinstein  Created
  -- Arguments
  --   x_application_id          Application id of the product
  --   x_ledger_id               Ledger id
  --   x_given_date		 the date which being analyzed
  --   x_period_name             Name of the period
  --   x_closing_status          Status of the period
  -- Example
  --   gl_period_statuses_pkg.get_period_by_date( :block.application_id,
  --     :block.ledger_id, :block.x_given_date,
  --     :block.period_name, :block.closing_status);
  -- Notes
  --
  PROCEDURE get_period_by_date(
  		x_application_id	NUMBER,
  		x_ledger_id	NUMBER,
  		x_given_date		DATE,
  		x_period_name	 IN OUT NOCOPY	VARCHAR2,
		x_closing_status IN OUT NOCOPY	VARCHAR2,
		x_period_year	 IN OUT NOCOPY	NUMBER,
		x_period_num	 IN OUT NOCOPY NUMBER,
		x_period_type	 IN OUT NOCOPY	VARCHAR2);


  --
  -- Procedure
  --   get_calendar_range
  -- Purpose
  --   Gets the minimum start date and maximum end date for the
  --   first ever opened period and the latest future enterable period
  --   for a given ledger.
  -- History
  --   25-APR-96  R Goyal Created
  -- Arguments
  --   x_ledger_id               Ledger id
  --   x_start_date              Start date for the range
  --   x_end_date                End date for the range
  -- Example
  --   gl_period_statuses_pkg.get_calendar_range(:led_id, :start_date, :end_date)
  -- Notes
  --
  PROCEDURE get_calendar_range(
  		x_ledger_id	NUMBER,
  		x_start_date	 IN OUT NOCOPY	DATE,
  		x_end_date	 IN OUT NOCOPY	DATE);


  --
  -- Procedure
  --   get_open_closed_calendar_range
  -- Purpose
  --   Gets the minimum start date and maximum end date for periods
  --   with a status in 'O', 'P', 'C' for a given ledger.
  -- History
  --   06-MAR-97  R Goyal Created
  -- Arguments
  --   x_ledger_id               Ledger id
  --   x_start_date              Start date for the range
  --   x_end_date                End date for the range
  -- Example
  --   gl_period_statuses_pkg.get_open_closed_calendar_range(:led_id,
  --                                          :start_date, :end_date)
  -- Notes
  --
  PROCEDURE get_open_closed_calendar_range(
  		x_ledger_id	NUMBER,
  		x_start_date	 IN OUT NOCOPY	DATE,
  		x_end_date	 IN OUT NOCOPY	DATE);



  --
  -- Procedure
  --   get_journal_range
  -- Purpose
  --   Gets the minimum start date and maximum end date for all open
  --   or future enterable periods
  -- History
  --   19-JUN-96  D J Ogg  Created
  -- Arguments
  --   x_ledger_id               Ledger id
  --   x_start_date              Start date for the range
  --   x_end_date                End date for the range
  -- Example
  --   gl_period_statuses_pkg.get_journal_range(:led_id,:start_date,:end_date)
  -- Notes
  --
  PROCEDURE get_journal_range(
  		x_ledger_id	NUMBER,
  		x_start_date	 IN OUT NOCOPY	DATE,
  		x_end_date	 IN OUT NOCOPY	DATE);

END gl_period_statuses_pkg;

 

/
