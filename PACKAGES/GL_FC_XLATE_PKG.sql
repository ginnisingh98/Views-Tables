--------------------------------------------------------
--  DDL for Package GL_FC_XLATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_FC_XLATE_PKG" AUTHID CURRENT_USER AS
/* $Header: glfcxlts.pls 120.4 2005/05/05 02:05:26 kvora ship $ */

  -- FUNCTION
  --   get_unique_name
  -- PURPOSE
  --   This funtion will generate the unique target ledger name
  -- HISTORY
  --   03/18/03          C Ma               Created
  -- ARGUMENTS
  --   ldg_name
  --   ldg_id
  --   tcurr_code
  FUNCTION get_unique_name(ldg_name IN VARCHAR2,
                      ldg_id IN NUMBER,
                      tcurr_code IN VARCHAR2) RETURN VARCHAR2;

  -- FUNCTION
  --   get_unique_short_name
  -- PURPOSE
  --   This funtion will generate the unique target ledger short name
  -- HISTORY
  --   03/18/03          C Ma               Created
  -- ARGUMENTS
  --   ldg_name
  --   ldg_id
  --   tcurr_code
  FUNCTION get_unique_short_name(ldg_short_name IN VARCHAR2,
                                 ldg_id IN NUMBER,
                                 tcurr_code IN VARCHAR2) RETURN VARCHAR2;

  -- FUNCTION
  --   get_ledger_name
  -- PURPOSE
  --   This funtion gets the ledger name for a particular ledger and currency,
  --   or creates one using get_unique_name and returns it.
  -- HISTORY
  --   05/02/03          M Ward             Created
  -- ARGUMENTS
  --   ldg_name
  --   ldg_id
  --   tcurr_code
  FUNCTION get_ledger_name(ldg_name IN VARCHAR2,
                      ldg_id IN NUMBER,
                      tcurr_code IN VARCHAR2) RETURN VARCHAR2;

  -- FUNCTION
  --   get_ledger_short_name
  -- PURPOSE
  --   This funtion gets the short name for a particular ledger and currency,
  --   or creates one using get_unique_short_name and returns it.
  -- HISTORY
  --   05/02/03          M Ward             Created
  -- ARGUMENTS
  --   ldg_name
  --   ldg_id
  --   tcurr_code
  FUNCTION get_ledger_short_name(ldg_short_name IN VARCHAR2,
                                 ldg_id IN NUMBER,
                                 tcurr_code IN VARCHAR2) RETURN VARCHAR2;

  -- FUNCTION
  --   relation_exist
  -- PURPOSE
  --   This funtion will check whether a translation ALC relationship
  --   has been created for the ledger and the target currency.
  -- HISTORY
  --   03/18/03          C Ma               Created
  -- ARGUMENTS
  --   ldg_id
  --   tcurr_code
  FUNCTION relation_exist(ldg_id IN NUMBER,
                          tcurr_code IN VARCHAR2) RETURN VARCHAR2;

  -- FUNCTION
  --   xlated_ever
  -- PURPOSE
  --   This funtion will check whether a ledger has been translated before.
  -- HISTORY
  --   03/18/03          C Ma               Created
  -- ARGUMENTS
  --   ldg_id
  --   tcurr_code
  --   bal_seg_val
  FUNCTION xlated_ever(ldg_id IN NUMBER,
                       tcurr_code IN VARCHAR2,
                       bal_seg_val IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;


 --
  -- Function
  --    FIRST_EVER_PERIOD_CHECK
  -- Purpose
  --   This procedure checks whether the period is first ever period in the calendar
  --    If it is the first ever period defined in the calendar, then it displays a message.
  -- History
  --   10-FEB-2005   Srini Pala     Created.
  -- Arguments
  --   Ledger_ID and Period_Name.
  -- Example
  --   TRANSLATION.FIRST_EVER_PERIOD_CHECK(120, 'Jan-02');
  -- Notes
  --

   FUNCTION FIRST_EVER_PERIOD_CHECK(x_ledger_id   NUMBER, x_period VARCHAR2)
                     RETURN BOOLEAN;


END GL_FC_XLATE_PKG;

 

/
