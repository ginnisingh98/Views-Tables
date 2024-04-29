--------------------------------------------------------
--  DDL for Package PY_ZA_TX_UTL_01032002
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PY_ZA_TX_UTL_01032002" AUTHID CURRENT_USER AS
/* $Header: pyzatu04.pkh 115.5 2003/05/09 04:36:57 nragavar noship $ */
/* Copyright (c) Oracle Corporation 2000. All rights reserved. */
/*
   PRODUCT
      Oracle Payroll - ZA Localisation Tax Module

   NAME
      py_za_tx_utl_01032002.pkh

   DESCRIPTION
      This is the ZA Tax Module utility package.  It contains
      functions and procedures used by the main tax package.

   PUBLIC FUNCTIONS
      GlbVal
         Returns the value of a Oracle Application Global
         date effectively
      NegPtd
         Boolean function returns true if any current PTD
         total balance value is negative
      LatePayPeriod
         Boolean function returns true if the current period
         is a Late Payment Period, i.e. a payment over the
         tax year boundary.
      LstPeriod
         Boolean function returns true if current period is the
         last period in the current tax year.
      EmpTermInPeriod
         Boolean function returns true if the assignment was terminated
         in the current pay period.
      EmpTermPrePeiod
         Boolean function returns true if the assignment was terminated
         before the current period.
      PreErnPeriod
         Boolean function returns true if this run is deemed to be
         a Pre-Earnings Calculation Run.
         For a complete description see the tax module design document.
      SitePeriod
         Boolean function returns true if it is a tax site period.
         For a complete description see the tax module design document.
      Annualise
         Returns annualised value to the calling object.
         For a complete description see the tax module design document.
      TaxLiability
         Returns the gross tax liability on passed value.
         For a complete description see the tax module design document.
      DeAnnualise
         Returns the de-annualised value to the calling object.
         For a complete description see the tax module design document.
      DaysWorked
         Returns the number of days worked for the assignment.
         For a complete description see the tax module design document.

   PUBLIC PROCEDURES
      StartHrTrace
         Sets package global that determines if extra trace information
         will be written to file - hr_utility
      StopHrTrace
         Stops trace information from being written to file
      WriteHrTrace
         Writes extra trace information to file if global
         has been set
      PeriodFactor
         Calculates the period factor for the assignment.
         For a complete description see the tax module design document.
      PossiblePeriodsFactor
         Calculates the possible period factor for the assignment.
         For a complete description see the tax module design document.
      SetRebates
         Calculate tax Rebate and Threshold values.
         For a complete description see the tax module design document.
      Abatements
         Calculates all necessary abatements.
         For a complete description see the tax module design document.
      ArrearExcess
         Calculates the arrear excess figure to 'effectively' update the
         Asg_Itd dimension of the arrear excess pension and retirement
         annuity balances.  Will only fire on siteperiod.
      TrvAll
         Calculates the taxable travel allowance over a period of
         time based on the effective global values at the time.
         For a complete description see the tax module design document.
      ValidateTaxOns
         Validates the calculated category liabilities.
         For a complete description see the tax module design document.
      SitPaySplit
         Calculates the site paye split of tax liabilities.
         For a complete description see the tax module design document.
      Trace
         Traces the tax calculation.
         For a complete description see the tax module design document.
      ClearGlobals
         Clears any set package globals.
         For a complete description see the tax module design document.

   PRIVATE FUNCTIONS
      see package body

   PRIVATE PROCEDURES
      see package body

   NOTES
      .

   MODIFICATION HISTORY
      Person      Date               Version   Comments
      ---------   ----------------   -------   -----------------------------------
      Nageswara   09/05/2003         115.5     Removed Serveroutput ON - GSCC
      J.N. Louw   15/04/2002         115.4     Removed SPOOL commands
      J.N. Louw   31/08/2001         115.3     Bug 2224332
                                               Directors Remuneration
      J.N. Louw   10/04/2002         115.2     Added dbdrv / gscc
      J.N. Louw   31/08/2001         115.1     Corrected Spool File
      J.N. Louw   29/08/2001         115.0     Next Version of Main ZA Tax
                                                Package.
                                                For detail history see
                                                py_za_tx_utl_01082000
*/

-------------------------------------------------------------------------------
--                           PACKAGE GLOBAL AREA                             --
-------------------------------------------------------------------------------
-- hr_utility wrapper globals
  g_HrTraceEnabled  BOOLEAN DEFAULT FALSE;
  g_HrTracePipeName VARCHAR2(30);

   -- Tax Specific Subtypes
   SUBTYPE t_balance IS NUMBER(15,2);
-------------------------------------------------------------------------------
--                           PACKAGE SPECIFICATION                           --
-------------------------------------------------------------------------------

-- StartHrTrace
-- Wrapper for hr_utility.trace_on
PROCEDURE StartHrTrace;

-- StopHrTrace
-- Wrapper for hr_utility.trace_off
PROCEDURE StopHrTrace;

-- WriteHrTrace
-- Wrapper for hr_utility.trace
PROCEDURE WriteHrTrace(
   p_Buffer VARCHAR2
   );



-- Tax Utility Functions
--

FUNCTION GlbVal
   (p_GlbNme ff_globals_f.global_name%TYPE
   ,p_EffDte DATE
   ) RETURN ff_globals_f.global_value%TYPE;

FUNCTION NegPtd RETURN BOOLEAN;

FUNCTION LatePayPeriod RETURN BOOLEAN;

FUNCTION LstPeriod RETURN BOOLEAN;

FUNCTION EmpTermInPeriod RETURN BOOLEAN;

FUNCTION EmpTermPrePeriod RETURN BOOLEAN;

FUNCTION PreErnPeriod RETURN BOOLEAN;

FUNCTION SitePeriod RETURN BOOLEAN;

PROCEDURE PeriodFactor;


PROCEDURE PossiblePeriodsFactor;


FUNCTION Annualise
   (p_YtdInc IN NUMBER
   ,p_PtdInc IN NUMBER
   ) RETURN NUMBER;

PROCEDURE SetRebates;

PROCEDURE Abatements;

PROCEDURE ArrearExcess;

FUNCTION TaxLiability
   (p_Amt  IN NUMBER
   )RETURN  NUMBER;


FUNCTION DeAnnualise
   (p_Liab IN NUMBER
   ,p_TxOnYtd IN NUMBER
   ,p_TxOnPtd IN NUMBER
   ) RETURN NUMBER;


PROCEDURE TrvAll;



PROCEDURE ValidateTaxOns(
   p_Rf IN BOOLEAN DEFAULT FALSE -- Refund Allowed Regardless
   );


-- DaysWorked
/*  Returns the number of days that the person has worked
    This could be a negative number that would indicate
    a LatePayePeriod
*/
FUNCTION DaysWorked RETURN NUMBER;


PROCEDURE SitPaySplit;


-- Trace Function
--
PROCEDURE Trace;

PROCEDURE ClearGlobals;

END py_za_tx_utl_01032002;


 

/
