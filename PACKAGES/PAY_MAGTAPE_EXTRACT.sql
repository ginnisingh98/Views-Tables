--------------------------------------------------------
--  DDL for Package PAY_MAGTAPE_EXTRACT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_MAGTAPE_EXTRACT" AUTHID CURRENT_USER AS
-- $Header: pymagext.pkh 120.1 2005/10/10 16:54:16 meshah noship $
--
-- Copyright (c) Oracle Corporation 1995 All rights reserved
/*
PRODUCT
  Oracle*Payroll
--
NAME
  pymagext.pkb   - PL/SQL
--
DESCRIPTION
  This package contains the procedures to process a magtape payroll action
  and create archive items for any archive database items contained in the
  magtape report format. The rollback routine will rollback these items
  before rolling back the payroll action itself.
--
MODIFIED (DD-MON-YYYY)
  cadams    12-Feb-1996   Created
  rsirigir  13-Aug-2002   Bug 2484696, included dbdrv commands to
                          conform to GSCC compliance


*/
  PROCEDURE arch_main (p_runmode           VARCHAR2,
                       p_payroll_action_id NUMBER);
--
  PROCEDURE arch_rolbk (p_errmsg            OUT nocopy VARCHAR2,
                        p_errcode           OUT nocopy NUMBER,
                        p_payroll_action_id     NUMBER);
--
END pay_magtape_extract;

 

/
