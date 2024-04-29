--------------------------------------------------------
--  DDL for Package PAY_CA_BALANCE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CA_BALANCE_PKG" AUTHID CURRENT_USER AS
/* $Header: pycabals.pkh 115.13 2002/10/21 23:54:47 tclewis ship $ */
/*  +======================================================================+
 |                Copyright (c) 1997 Oracle Corporation                 |
 |                   Redwood Shores, California, USA                    |
 |                        All rights reserved.                          |
 +======================================================================+
 Package Header Name :  pay_ca_balance_pkg
 Package File Name   :  pycabals.pkh
 Description : This package declares functions which are
                         call_ca_balance_get_value

 Change List:
 ------------

 Name           Date       Version Bug     Text
 -------------- ---------- ------- ------- ------------------------------
 RThirlby       23-0ct-98    110.0         Initial Version
 RThirlby	   17-Nov-98    110.1         Added jurisdiction_code
                                           and removed p_tax_unit.
 RThirlby       18-Mar-99    110.2         Changed default for
					      p_business_group to 0, so that
		      session variable doesn't have to
					      be set by
 JARTHURT       24-NOV-99    110.3         Added get_current balance function
 jgoswami       06-DEC-1999  110.4         Overloading of
                                           call_ca_balance_get_value function
                                           with parameter p_source_id
 JARTHURT       26-JAN-99    110.5         Added get_current balance function
 RThirlby       11-FEB-2000  115.6         Added payments_balance_required
                                           function. This is copied from
                                           pyustxbv.pkb.
 RThirlby       05-JUN-2000  115.7         Added turn_off_dimension function
                                           and turn_off_report_dimension
                                           procedure. To help SOE view
                                           performance.
 mmukherj       17-JAN-2002  115.8         Changed the default value for
                                           p_business_group_id to NULL.
                                           Otherwise the pacakge body
                                           does not get compiled in 9i db.
 MMUKHERJ      25-JAN-01   115.9           dbdrv command added
 TCLEWIS        12-sep-2002  115.10        Per Ankur removed pragma to
                                           call_ca_balance_get_value.
 TCLEWIS        21-OCT-2002  115.11        removed pragma on get_current_balance
 ========================================================================
*/
/*
FUNCTION call_ca_balance_get_value (p_balance_name   IN VARCHAR2
                           ,p_time_period            IN VARCHAR2
                           ,p_assignment_action_id   IN NUMBER   DEFAULT NULL
                           ,p_assignment_id          IN NUMBER   DEFAULT NULL
                           ,p_virtual_date           IN DATE     DEFAULT NULL
                           ,p_report_level           IN VARCHAR2 DEFAULT NULL
                           ,p_gre_id                 IN NUMBER   DEFAULT NULL
                           ,p_business_group_id      IN NUMBER   DEFAULT NULL
                           ,p_jurisdiction_code      IN VARCHAR2 DEFAULT NULL)
RETURN NUMBER;
--PRAGMA RESTRICT_REFERENCES(call_ca_balance_get_value, WNDS);
*/
-----------------------------------------------------------------------------
-- FUNCTION call_ca_balance_get_value - Overloaded version using source_id
-----------------------------------------------------------------------------
FUNCTION call_ca_balance_get_value (p_balance_name   IN VARCHAR2
                           ,p_time_period            IN VARCHAR2
                           ,p_assignment_action_id   IN NUMBER   DEFAULT NULL
                           ,p_assignment_id          IN NUMBER   DEFAULT NULL
                           ,p_virtual_date           IN DATE     DEFAULT NULL
                           ,p_report_level           IN VARCHAR2 DEFAULT NULL
                           ,p_gre_id                 IN NUMBER   DEFAULT NULL
                           ,p_business_group_id      IN NUMBER   DEFAULT NULL
                           ,p_jurisdiction_code      IN VARCHAR2 DEFAULT NULL
                           ,p_source_id              IN NUMBER   DEFAULT NULL )
RETURN NUMBER;
--
--PRAGMA RESTRICT_REFERENCES(call_ca_balance_get_value, WNDS);
-----------------------------------------------------------------------------
-- FUNCTION get_current_balance
-----------------------------------------------------------------------------
FUNCTION get_current_balance (p_defined_balance_id NUMBER
                             ,p_run_action_id      NUMBER)
RETURN NUMBER;
--PRAGMA RESTRICT_REFERENCES(get_current_balance, WNDS);
-----------------------------------------------------------------------------
-- FUNCTION payments_balance_required
-----------------------------------------------------------------------------
FUNCTION payments_balance_required(p_assignment_action_id NUMBER)
RETURN boolean;
PRAGMA RESTRICT_REFERENCES(payments_balance_required, WNDS);
-----------------------------------------------------------------------------
-- FUNCTION turn_off_dimension
-----------------------------------------------------------------------------
FUNCTION turn_off_dimension (p_dimension varchar2)
RETURN boolean;
PRAGMA RESTRICT_REFERENCES(turn_off_dimension, WNDS);
-----------------------------------------------------------------------------
-- PROCEDURE turn_off_report_dimension
-----------------------------------------------------------------------------
PROCEDURE turn_off_report_dimension(p_report_name varchar2);
-----------------------------------------------------------------------------
END pay_ca_balance_pkg;

 

/
