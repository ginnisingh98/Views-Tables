--------------------------------------------------------
--  DDL for Package FA_XLA_ACCOUNTING_MAIN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_XLA_ACCOUNTING_MAIN_PKG" AUTHID CURRENT_USER AS
/* $Header: FAXLAXMS.pls 120.1.12010000.2 2009/07/19 14:12:58 glchen ship $ */


--------------------------------------------------------------------------------
--
-- pre-processing - used to lock the assets requiring it in FA...
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
-- extract-processing - used to extract
-- all accounting for the events
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
-- post-processing - used to extract
--
--------------------------------------------------------------------------------

PROCEDURE postprocessing
   (p_application_id     IN number,
    p_accounting_mode    IN varchar2);


--------------------------------------------------------------------------------

END fa_xla_accounting_main_pkg;

/
