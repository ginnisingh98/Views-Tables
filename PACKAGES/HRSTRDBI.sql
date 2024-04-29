--------------------------------------------------------
--  DDL for Package HRSTRDBI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRSTRDBI" AUTHID CURRENT_USER as
/* $Header: pestrdbi.pkh 115.4 2002/12/09 13:57:04 eumenyio ship $ */
/*
--
-- Copyright (c) Oracle Corporation 1991, 1992, 1993. All rights reserved.
--
/*
   NAME
      pestrdbi.pkh
--
   DESCRIPTION
      Procedures used for creating the start up data for database items,
      namely the routes and the appropriate contexts, for personnel.
--
  MODIFIED (DD-MON-YYYY)
     divicker   02-APR-2002 - New routine insert_monetary_units
     alogue     26-APR-1999 - New routine insert_user_tables.
     alogue     12-MAR-1999 - New routines insert_functions + insert_formula.
     mwcallag   22-JUL-1993 - Routine split into 2 procedures for easier
                              re-building.
     mwcallag   24-MAY-1993 - created.
*/
--
procedure insert_context;
--
PROCEDURE insert_routes_db_items;
--
PROCEDURE insert_functions;
--
PROCEDURE insert_formula;
--
PROCEDURE insert_user_tables;
--
PROCEDURE insert_monetary_units;
--
PROCEDURE create_dbi_startup;
--
end hrstrdbi;

 

/
