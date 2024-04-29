--------------------------------------------------------
--  DDL for Package PAY_FR_OVERTIME_MAPPING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_FR_OVERTIME_MAPPING" AUTHID CURRENT_USER as
/* $Header: pyfromap.pkh 115.2 2002/11/22 11:46:14 sfmorris noship $ */
/*
+======================================================================+
|              Copyright (c) 1997 Oracle Corporation UK Ltd            |
|                        Reading, Berkshire, England                   |
|                           All rights reserved.                       |
+======================================================================+
Package Body Name : pay_fr_overtime_mapping
Package File Name : pyfromap.pkh
Description : This package contains procedures to support the PYFROMAP
              concurrent process

Change List:
------------

Name           Date       Version Bug     Text
-------------- ---------- ------- ------- ------------------------------
J.Rhodes       02-May-01  115.0           Initial Version
J.Rhodes       21-Nov-02  115.1           NOCOPY Changes
S.Morrison     22-Nov-02  115.2           Fixed GSCC Errors
========================================================================
*/

/* ---------------------------------------------------------------------
 NAME
   generate
 DESCRIPTION
   This procedure generate a mapping of overtime weeks onto the payroll
   period in which they will be paid
  --------------------------------------------------------------------- */
procedure generate
(errbuf out nocopy varchar2
,retcode out nocopy number
,p_overtime_payroll_id number
,p_start_ot_period_id number
,p_end_ot_period_id number default null
,p_payroll_id number
,p_start_py_period_id number
,p_end_py_period_id number default null
,p_pattern varchar2
,p_override varchar2 default null);
end pay_fr_overtime_mapping;

 

/
