--------------------------------------------------------
--  DDL for Package Body GL_TRANS_DATES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_TRANS_DATES_PKG" as
/* $Header: gligctdb.pls 120.3 2005/05/05 01:08:26 kvora ship $ */


--
--
-- Package
--  gl_trans_date_pkg
--
-- Purpose
--  Obtains business days pattern from
--  transaction calendar.
--
  --
  -- Procedure
  --  get_business_days_pattern
  -- Purpose
  --  Uses transaction_calendar_id and start and end dates
  --  to obtain which days are business days in the form of a
  --  binary VARCHAR pattern.
  --  A typical pattern could be '1121221212221211212'
  --  Each character represents whether the day is a business day or not.
  --  '1' represents a business day and
  --  '2' represents a nonbusiness day.
  --
  -- Arguments
  --  X_transaction_cal_id
  --  X_start_date
  --  X_end_date
  --  X_bus_days_pattern
  --
PROCEDURE get_business_days_pattern(X_transaction_cal_id     IN NUMBER,
			            X_start_date             IN DATE,
                                    X_end_date               IN DATE,
			            X_bus_days_pattern       IN OUT NOCOPY VARCHAR2) IS

CURSOR GETPAT IS
 SELECT
	to_char(sum(decode(business_day_flag, 'Y', 1, 'N', 2) *
  	            power(10, transaction_date - X_start_date)))
 FROM
       	GL_TRANSACTION_DATES
 WHERE
	transaction_calendar_id = X_transaction_cal_id
    AND transaction_date between X_start_date and X_end_date;


BEGIN

 OPEN GETPAT;
 FETCH GETPAT INTO X_bus_days_pattern;
 CLOSE GETPAT;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    app_exception.raise_exception;

END get_business_days_pattern;

  --
  -- Procedure
  --  get_big_bus_days_pattern
  -- Purpose
  --  Uses transaction_calendar_id and start and end dates
  --  to obtain which days are business days in the form of a
  --  binary VARCHAR pattern.
  --  A typical pattern could be '1121221212221211212'
  --  Each character represents whether the day is a business day or not.
  --  '1' represents a business day and
  --  '2' represents a nonbusiness day.
  --
  -- Arguments
  --  X_transaction_cal_id
  --  X_start_date
  --  X_end_date
  --  X_bus_days_pattern
  --
  PROCEDURE get_big_bus_days_pattern(X_transaction_cal_id     IN NUMBER,
			             X_start_date             IN DATE,
                                     X_end_date               IN DATE,
			             X_bus_days_pattern       IN OUT NOCOPY VARCHAR2
  ) IS

    current_date DATE;
    next_pattern VARCHAR2(100);
  BEGIN

    current_date := X_end_date;
    X_bus_days_pattern := '';
    next_pattern := '';

    WHILE (current_date - 34 > X_start_date) LOOP

      get_business_days_pattern(X_transaction_cal_id,
                                current_date - 34,
                                current_date,
                                next_pattern);

      X_bus_days_pattern := X_bus_days_pattern || next_pattern;

      current_date := current_date - 35;

    END LOOP;

    get_business_days_pattern(X_transaction_cal_id,
                              X_start_date,
			      current_date,
                              next_pattern);

    X_bus_days_pattern := X_bus_days_pattern || next_pattern;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      app_exception.raise_exception;

  END get_big_bus_days_pattern;

END GL_TRANS_DATES_PKG;


/
