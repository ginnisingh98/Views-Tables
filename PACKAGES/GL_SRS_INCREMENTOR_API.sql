--------------------------------------------------------
--  DDL for Package GL_SRS_INCREMENTOR_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_SRS_INCREMENTOR_API" AUTHID CURRENT_USER AS
/* $Header: gluschps.pls 120.7 2005/05/05 01:43:38 kvora ship $ */

-- Public Variables
   error_buffer                  VARCHAR2(500);


------------------------------------------------------
-- Functions processing increment : made public for debugging
------------------------------------------------------

-- Purpose: Increment Journal date by business days offset method
--          then find corresponding period.
--          This method is used for ADB ledgeres.
   FUNCTION increment_bus_date(
      x_ledger_id                   NUMBER,
      x_last_anchor_date            DATE,
      x_last_para_date              DATE,
      x_new_anchor_date             DATE,
      x_new_para_date      IN OUT NOCOPY   DATE,
      x_new_para_period    IN OUT NOCOPY   VARCHAR2)
      RETURN NUMBER;


-- Purpose: Increment Period using journals days offset method
--          This method is used for Non-ADB and ADB consolidation
--          ledgers.
   FUNCTION inc_period_by_days_offset(
      x_ledger_id                     NUMBER,
      x_start_date_last_run            DATE,
      x_period_last_run                VARCHAR2,
      x_start_date_this_run            DATE,
      x_period_this_run       IN OUT NOCOPY   VARCHAR2)
      RETURN NUMBER;


------------------------------------------------------
-- Function that handles specific ledger
------------------------------------------------------
-- Purpose: Handles Period Increment for Standard (Non-ADB) ledger
   PROCEDURE increment_period(
      x_ledger_id     NUMBER,
      x_period_para   VARCHAR2);


-- Purpose: Handles GL Date and Period Increment for Standard ADB ledger
   PROCEDURE increment_adb(
      x_ledger_id           NUMBER,
      x_period_para      VARCHAR2,
      x_je_date_para     VARCHAR2,
      x_calc_date_para   VARCHAR2,
      x_date_format      VARCHAR2);


------------------------------------------------------
-- Function to be called by SRS
------------------------------------------------------
--   PROCEDURE increment_period;

   PROCEDURE increment_parameters;

   PROCEDURE increment_date(
      x_date_para     VARCHAR2,
      x_period_flag   VARCHAR2,
      x_period_para   VARCHAR2,
      x_ledger_id     NUMBER);


-- Purpose: Get a random ledger from a batch or an allocation set
--          that contains no ADB or consolidation ledgers

   FUNCTION get_random_ledger(
      x_batch_type            VARCHAR2,
      x_ledger_id             NUMBER,
      x_batch_id              NUMBER) RETURN NUMBER;


END gl_srs_incrementor_api;

 

/
