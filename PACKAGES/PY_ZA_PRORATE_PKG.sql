--------------------------------------------------------
--  DDL for Package PY_ZA_PRORATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PY_ZA_PRORATE_PKG" AUTHID CURRENT_USER AS
/* $Header: pyzapror.pkh 120.4.12010000.2 2009/04/29 06:57:42 rbabla ship $ */
/* +=======================================================================+
   | Copyright (c) 2001 Oracle Corporation Redwood Shores, California, USA |
   |                       All rights reserved.                            |
   +=======================================================================+

   PRODUCT
      Oracle Payroll - ZA Localisation

   NAME
      py_za_prorate_pkg.pkh

   DESCRIPTION
      This package contains functions that can be used in proration
      functionality.

   PUBLIC FUNCTIONS
      get_workdays
      .
      pro_rate
      .
      pro_rate_days
         Returns the number of days worked in the pay period
         as a fraction of the total number of days in the pay period.
         This function can be called through fast formula

   NOTES
      .

   MODIFICATION HISTORY
      Person      Date(DD-MM-YYYY)   Version   Comments
      ---------   ----------------   -------   -----------------------------
      J.N. Louw   07-09-2001         115.2     Updated pro_rate_days
      A.Stander   19-11-1998         110.0     Initial version
*/


FUNCTION get_workdays
   ( period_1 IN date
   , period_2 IN date
   ) RETURN NUMBER;
pragma restrict_references(get_workdays,WNDS);

FUNCTION pro_rate
   ( payroll_action_id  IN number
    ,assignment_id     IN number
   ) RETURN NUMBER;

pragma restrict_references(pro_rate,WNDS);

FUNCTION pro_rate_days
   ( PAYROLL_ACTION_ID IN NUMBER
   , ASSIGNMENT_ID     IN NUMBER
   ) RETURN NUMBER;

END py_za_prorate_pkg;

/
