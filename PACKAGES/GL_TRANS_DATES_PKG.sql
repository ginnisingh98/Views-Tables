--------------------------------------------------------
--  DDL for Package GL_TRANS_DATES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_TRANS_DATES_PKG" AUTHID CURRENT_USER as
/* $Header: gligctds.pls 120.3 2005/05/05 01:08:33 kvora ship $ */
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
  --  to obtain which days are business in the form of a
  --  binary VARCHAR pattern.
  -- Arguments
  --  X_transaction_cal_id
  --  X_start_date
  --  X_end_date
  --  X_bus_days_pattern
  --
PROCEDURE get_business_days_pattern(X_transaction_cal_id     IN NUMBER,
			            X_start_date             IN DATE,
                                    X_end_date               IN DATE,
			            X_bus_days_pattern       IN OUT NOCOPY VARCHAR2);

  --
  -- Procedure
  --  get_big_bus_days_pattern
  -- Purpose
  --  Uses transaction_calendar_id and start and end dates
  --  to obtain which days are business in the form of a
  --  binary VARCHAR pattern.
  -- Arguments
  --  X_transaction_cal_id
  --  X_start_date
  --  X_end_date
  --  X_bus_days_pattern
  --
PROCEDURE get_big_bus_days_pattern(X_transaction_cal_id     IN NUMBER,
		                   X_start_date             IN DATE,
                                   X_end_date               IN DATE,
			           X_bus_days_pattern       IN OUT NOCOPY VARCHAR2);

END GL_TRANS_DATES_PKG;


 

/
