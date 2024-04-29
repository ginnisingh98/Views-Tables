--------------------------------------------------------
--  DDL for Package IGI_XLA_ACCOUNTING_MAIN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_XLA_ACCOUNTING_MAIN_PKG" AUTHID CURRENT_USER AS
/* $Header: igixlahs.pls 120.0.12000000.1 2007/09/03 07:57:20 npandya noship $ */
--------------------------------------------------------------------------------
--
-- pre-processing -
--
--------------------------------------------------------------------------------

PROCEDURE preaccounting
   (p_application_id     IN number,
    p_ledger_id          IN number,
    p_process_category   IN varchar2,
    p_end_date           IN date,
    p_accounting_mode    IN varchar2,
    p_valuation_method   IN varchar2,
    p_security_id_int_1  IN number,
    p_security_id_int_2  IN number,
    p_security_id_int_3  IN number,
    p_security_id_char_1 IN varchar2,
    p_security_id_char_2 IN varchar2,
    p_security_id_char_3 IN varchar2,
    p_report_request_id  IN number);

--------------------------------------------------------------------------------
--
-- extract-processing - used to extract all accounting for the events
--
--------------------------------------------------------------------------------

PROCEDURE extract
   (p_application_id     IN number,
    p_accounting_mode    IN varchar2);

----------------------------------------------------------------------------------
-- post-accounting
--
--------------------------------------------------------------------------------

PROCEDURE postaccounting
   (p_application_id     IN number,
    p_ledger_id          IN number,
    p_process_category   IN varchar2,
    p_end_date           IN date,
    p_accounting_mode    IN varchar2,
    p_valuation_method   IN varchar2,
    p_security_id_int_1  IN number,
    p_security_id_int_2  IN number,
    p_security_id_int_3  IN number,
    p_security_id_char_1 IN varchar2,
    p_security_id_char_2 IN varchar2,
    p_security_id_char_3 IN varchar2,
    p_report_request_id  IN number);

----------------------------------------------------------------------------------
-- post-processing
--
--------------------------------------------------------------------------------

PROCEDURE postprocessing
   (p_application_id     IN number,
    p_accounting_mode    IN varchar2);


--------------------------------------------------------------------------------

END IGI_XLA_ACCOUNTING_MAIN_PKG;

 

/
