--------------------------------------------------------
--  DDL for Package PAY_US_OLTLOD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_OLTLOD_PKG" AUTHID CURRENT_USER as
/* $Header: pyusoltl.pkh 115.1 2002/02/05 11:33:24 pkm ship      $ */
/*
   Copyright (c) Oracle Corporation 1991,1992,1993,2001. All rights reserved
--
   Name        :This package defines the routines needed for Over Limit Report to run
                Multi-Threaded. These procedures load data into pay_us_rpt_totals
                table.
--
   Change List
   -----------
   Date         Name        Vers   Description
   -----------  ----------  -----  -----------------------------------
   30-NOV-2001  irgonzal    115.0   created
   05-FEB-2002  meshah      115.1   Added checkfile entry to the file.
--
*/
procedure load_data
(
   pactid   in     varchar2,     /* payroll action id */
   chnkno   in     number,
   ppa_finder in varchar2
);
end pay_us_oltlod_pkg;

 

/
