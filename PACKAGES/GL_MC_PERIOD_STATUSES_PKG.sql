--------------------------------------------------------
--  DDL for Package GL_MC_PERIOD_STATUSES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_MC_PERIOD_STATUSES_PKG" AUTHID CURRENT_USER AS
/* $Header: glmcpers.pls 120.2 2003/07/25 23:06:37 lpoon ship $*/

 n_application_id                           NUMBER(15);
 n_set_of_books_id                          NUMBER(15);
 n_closing_status                           VARCHAR2(1);
 n_period_name                              VARCHAR2(15);
 n_start_date                               DATE;
 n_end_date                                 DATE;

 -- All SOBs are converted to Ledgers in R11i.x and a new column LEDGER_ID
 -- is added to GL_PERIOD_STATUSES
 n_ledger_id                                NUMBER(15);

END gl_mc_period_statuses_pkg;

 

/
