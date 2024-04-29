--------------------------------------------------------
--  DDL for Package PAY_TRGL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_TRGL_PKG" AUTHID CURRENT_USER AS
/* $Header: pytrangl.pkh 120.1.12010000.1 2008/07/27 23:45:50 appldev ship $ */
--
/*
 * ***************************************************************************
--
  Copyright (c) Oracle Corporation (UK) Ltd 1993,1994.
  All Rights Reserved.
--
  PRODUCT
    Oracle*Payroll
--
  NAME
    PAY_TRGL_PKG  - Procedure to transfer pay costs to General Ledger.
--
--
  DESCRIPTION
    The procedure sums are costs for each cost centre for all payroll runs
    which occurr within the tansfer period. The costs are summed across
    assignments but distinct entries are created for debit and credit for
    each currency.

  MODIFIED      (DD-MON-YYYY)
     A.Frith	14-May-1994	Created
     J.ALLOUN   30-JUL-1996     Added error handling.
     A.Logue    25-AUG-1998     Multi-Threaded Implementation.
     A.Logue    07-OCT-2005     Support of Sub Ledger Accouting (SLA).
--
*/
--
PROCEDURE trans_pay_costs
	(i_payroll_action_id NUMBER) ;
--
PROCEDURE trans_pay_costs_mt
	(i_payroll_action_id NUMBER) ;
--
PROCEDURE trans_ass_costs
	(i_assignment_action_id NUMBER,
         sla_mode               NUMBER) ;
--
END pay_trgl_pkg;

/
