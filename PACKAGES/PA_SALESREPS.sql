--------------------------------------------------------
--  DDL for Package PA_SALESREPS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_SALESREPS" AUTHID CURRENT_USER AS
/* $Header: PAXITSCS.pls 120.1 2005/08/19 17:15:08 mwasowic noship $ */

------------
--  OVERVIEW
--
--  This package inserts rows into RA_INTERFACE_SALESREPS for
--  transfer of SalesCredits from PA to AR. It is called by the 'Transfer
--  Invoice' process.

---------
--  USAGE
--
--  In Transfer Invoices to AR, we will call process_project once for each
--  project. This will insert salescredit rows for all transferred invoice
--  lines for that project.

----------------------------
--  PROCEDURES AND FUNCTIONS
--
--  1. process_project:    Inserts appropriate credit receiver rows into
--  	  		   ra_interface_salescredits for a project, for all
--  			   transferred invoice lines (uses insert_salescredit)

    PROCEDURE process_project(	pj_id number, req_id number);

------------
--  Procedure : validate_sales_credit_type
--  USAGE
--
--  In Transfer Invoices to AR, we will call validate_sales_credit_type once
--  for each project. This will validate the sales credit type code.

----------------------------
    PROCEDURE validate_sales_credit_type ( pj_id     IN NUMBER,
                                           rej_code OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

END pa_salesreps;

 

/
