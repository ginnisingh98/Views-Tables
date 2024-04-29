--------------------------------------------------------
--  DDL for Package HRUSERDT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRUSERDT" AUTHID CURRENT_USER as
/* $Header: pyuserdt.pkh 115.4 2002/07/17 11:30:52 alogue ship $ */
--
/*
--
-- Copyright (c) Oracle Corporation 1991,1992,1993. All rights reserved
/*
PRODUCT
    Oracle*Payroll
--
NAME
    pyuserdt.pkh       - Function for retrieving from USER Defined Tables
--
DESCRIPTION
--
MODIFIED (DD-MON-YYYY)
    mwcallag   12-NOV-1993 - Created (G37).
    wkerr      03-Mar-1999 - Added PRAGMA for use in euro work
    ccarter    12-OCT-1999 - Bug 1027169, removed pragma restriction
                             from get_table_value
    vborhade   10-JUL-2002 - Added function get_row_value
    alogue     17-JUL-2002 - Added set_g_effective_date and
                             unset_g_effective_date procedures.
                             Remove get_row_value function.

*/
procedure set_g_effective_date(p_effective_date in date);

procedure unset_g_effective_date;

function get_table_value (p_bus_group_id      in number,
                          p_table_name        in varchar2,
                          p_col_name          in varchar2,
                          p_row_value         in varchar2,
                          p_effective_date    in date  default null)
         return varchar2;

--
   --PRAGMA   RESTRICT_REFERENCES(get_table_value,WNDS);
--
END hruserdt;

 

/
