--------------------------------------------------------
--  DDL for Package POA_SAVINGS_ACCT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POA_SAVINGS_ACCT" AUTHID CURRENT_USER AS
/* $Header: poasvp5s.pls 115.0 99/07/15 20:06:29 porting shi $ */

  PROCEDURE get_cac_info(p_ccid IN NUMBER, p_set_of_books_id IN NUMBER,
                         p_cost_center_id OUT VARCHAR2,
                         p_account_id OUT VARCHAR2,
                         p_company_id OUT VARCHAR2);

END poa_savings_acct;

 

/
