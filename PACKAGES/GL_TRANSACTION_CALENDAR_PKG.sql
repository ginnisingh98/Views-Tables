--------------------------------------------------------
--  DDL for Package GL_TRANSACTION_CALENDAR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_TRANSACTION_CALENDAR_PKG" AUTHID CURRENT_USER AS
  /* $Header: glitrcls.pls 120.5 2003/12/05 18:56:12 cma ship $ */
--
-- Package
--  gl_transaction_calendar_pkg
-- Purpose
--   To contain procedures for maintaining of the GL_TRANSACTION_DATES table
-- History
--   12-11-95  	E Weinstein	Created

  --
  -- Procedure
  --   check_unique
  -- Purpose
  --   Checks to make sure that the name of the calendar
  --   is unique.
  -- History
  --   12-11-95  	E Weinstein	Created
  -- Arguments
  --   calendar_name    The name of the calendar
  --   row_id           The current rowid
  -- Example
  --   gl_transaction_calendar_pkg.check_unique('Standard', 'ABCDEDF');
  -- Notes
  --
  PROCEDURE check_unique(x_name VARCHAR2, row_id VARCHAR2);

  --
  -- Procedure
  --   lock_row
  -- Purpose
  --   lock row of GL_TRANSACTION_CALENDAR
  -- History
  --   07-07-2003  	psahay       Created
  -- Arguments
  --   all table columns except WHO columns
  --
PROCEDURE lock_row
       (X_Rowid                   	IN OUT NOCOPY VARCHAR2,
        x_transaction_calendar_id	NUMBER,
 	x_name				VARCHAR2,
 	x_sun_business_day_flag		VARCHAR2,
 	x_mon_business_day_flag		VARCHAR2,
 	x_tue_business_day_flag		VARCHAR2,
 	x_wed_business_day_flag		VARCHAR2,
 	x_thu_business_day_flag		VARCHAR2,
 	x_fri_business_day_flag		VARCHAR2,
 	x_sat_business_day_flag		VARCHAR2,
 	x_security_flag                 VARCHAR2,
 	x_description			VARCHAR2,
 	x_context			VARCHAR2,
 	x_attribute1			VARCHAR2,
 	x_attribute2			VARCHAR2,
 	x_attribute3			VARCHAR2,
 	x_attribute4			VARCHAR2,
 	x_attribute5			VARCHAR2,
 	x_attribute6			VARCHAR2,
 	x_attribute7			VARCHAR2,
 	x_attribute8			VARCHAR2,
 	x_attribute9			VARCHAR2,
 	x_attribute10			VARCHAR2,
 	x_attribute11			VARCHAR2,
 	x_attribute12			VARCHAR2,
 	x_attribute13			VARCHAR2,
 	x_attribute14			VARCHAR2,
 	x_attribute15			VARCHAR2
 	);

  --
  -- Procedure
  --   insert_row
  -- Purpose
  --   insert record into the GL_TRANSACTION_CALENDAR
  -- History
  --   12-11-95  	E Weinstein	Created
  --   07-07-03         PSAHAY          Added x_security_flag
  -- Arguments
  --   all table columns
  --
 PROCEDURE insert_row
  	(X_Rowid                   	IN OUT NOCOPY VARCHAR2,
  	x_transaction_calendar_id	IN OUT NOCOPY NUMBER,
 	x_name				VARCHAR2,
 	x_sun_business_day_flag		VARCHAR2,
 	x_mon_business_day_flag		VARCHAR2,
 	x_tue_business_day_flag		VARCHAR2,
 	x_wed_business_day_flag		VARCHAR2,
 	x_thu_business_day_flag		VARCHAR2,
 	x_fri_business_day_flag		VARCHAR2,
 	x_sat_business_day_flag		VARCHAR2,
 	x_security_flag                 VARCHAR2,
 	x_creation_date			DATE,
 	x_created_by			NUMBER,
 	x_last_update_date		DATE,
 	x_last_updated_by		NUMBER,
 	x_last_update_login		NUMBER,
 	x_description			VARCHAR2,
 	x_context			VARCHAR2,
 	x_attribute1			VARCHAR2,
 	x_attribute2			VARCHAR2,
 	x_attribute3			VARCHAR2,
 	x_attribute4			VARCHAR2,
 	x_attribute5			VARCHAR2,
 	x_attribute6			VARCHAR2,
 	x_attribute7			VARCHAR2,
 	x_attribute8			VARCHAR2,
 	x_attribute9			VARCHAR2,
 	x_attribute10			VARCHAR2,
 	x_attribute11			VARCHAR2,
 	x_attribute12			VARCHAR2,
 	x_attribute13			VARCHAR2,
 	x_attribute14			VARCHAR2,
 	x_attribute15			VARCHAR2
 	);

  --
  -- Procedure
  --   delete_row
  -- Purpose
  --   delete record from the GL_TRANSACTION_CALENDAR and GL_TRANSACTION_DATES
  -- History
  --   12-15-95  	E Weinstein	Created
  -- Arguments
  --   x_transaction_calendar_id	Transaction calendar ID
  --
  PROCEDURE delete_row(x_transaction_calendar_id	NUMBER);

  --
  -- Procedure
  --   check_calendar
  -- Purpose
  --   check that the calendar is not being used in any of the Ledgers
  -- History
  --   12-15-95  	E Weinstein	Created
  -- Arguments
  --   x_transaction_calendar_id	Transaction calendar ID
  --
  PROCEDURE check_calendar(x_transaction_calendar_id	NUMBER);

END gl_transaction_calendar_pkg;

 

/
