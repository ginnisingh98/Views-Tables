--------------------------------------------------------
--  DDL for Package JL_BR_AR_VARIABLES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_BR_AR_VARIABLES" AUTHID CURRENT_USER AS
/* $Header: jlbrrvas.pls 120.4 2006/12/02 00:10:39 appradha ship $*/

company_code	NUMBER;
company_name	VARCHAR2(80);
generation_date	DATE;
bank_number	VARCHAR2(80);
--bank_party_id   NUMBER;

END jl_br_ar_variables;

/
