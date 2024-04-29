--------------------------------------------------------
--  DDL for Package PAY_DBI_STARTUP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_DBI_STARTUP_PKG" AUTHID CURRENT_USER as
/* $Header: pystrdbi.pkh 115.0 99/07/17 06:35:39 porting ship $ */
/*
--
-- Copyright (c) Oracle Corporation 1991, 1992, 1993. All rights reserved.
--
/*
   NAME
      pystrdbi.pkh
--
   DESCRIPTION
      Procedures used for creating the start up data for database items,
      namely the routes and the appropriate contexts.  The procedure
      create_dbi_startup is called from the main start up file.
--
  MODIFIED (DD-MON-YYYY)
     mwcallag   27-APR-1993 - created.
     rfine      05-OCT-1994 - renamed package to pay_dbi_startup_pkg.
*/
--
PROCEDURE create_dbi_startup;
--
end pay_dbi_startup_pkg;

 

/
