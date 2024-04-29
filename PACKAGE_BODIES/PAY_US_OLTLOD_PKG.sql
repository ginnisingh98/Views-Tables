--------------------------------------------------------
--  DDL for Package Body PAY_US_OLTLOD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_OLTLOD_PKG" as
/* $Header: pyusoltl.pkb 115.4 2002/02/05 11:33:23 pkm ship      $ */
/*
   Copyright (c) Oracle Corporation 1991,1992,1993. All rights reserved
--
   Name        :This package defines the cursors needed for OLT to run Multi-Threaded
                This loads all the records that will appear in the report. This
                data is being stored in pay_us_rpt_totals table.
--
   Change List
   -----------
   Date         Name        Vers   Description
   -----------  ----------  -----  -----------------------------------
   30-NOV-2001  irgonzal    115.0   created
   20-DEC-2001  meshah      115.1   changed hr_locations to hr_locations_all
                                    for bug 2157065.
   04-FEB-2002  meshah      115.2   removed all the code as it is now
                                    included in pyusoltx.pkh and pkb.
   05-FEB-2002  meshah      115.3   Added checkfile entry to the file.
*/

--
procedure load_data
(
   pactid     in     varchar2,     /* payroll action id */
   chnkno     in     number,
   ppa_finder in     varchar2
) is

--
--------------------------- M A I N -------------------------------------
begin

    null;


end load_data;
--------------------------end load data-----------------------------
end pay_us_oltlod_pkg;

/
