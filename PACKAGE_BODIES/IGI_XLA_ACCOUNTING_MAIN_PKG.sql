--------------------------------------------------------
--  DDL for Package Body IGI_XLA_ACCOUNTING_MAIN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_XLA_ACCOUNTING_MAIN_PKG" AS
/* $Header: igixlahb.pls 120.0.12000000.2 2007/10/19 14:00:09 npandya noship $ */
G_CURRENT_RUNTIME_LEVEL        NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
G_LEVEL_STATEMENT     CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
G_LEVEL_PROCEDURE     CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
G_LEVEL_EVENT         CONSTANT NUMBER := FND_LOG.LEVEL_EVENT;
G_LEVEL_EXCEPTION     CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
G_LEVEL_ERROR         CONSTANT NUMBER := FND_LOG.LEVEL_ERROR;
G_LEVEL_UNEXPECTED    CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;
G_MODULE_NAME         CONSTANT VARCHAR2(50):= 'igi.plsql.igi_xla_accounting_main_pkg.';

--------------------------------------------------------------------------------
--
-- pre-processing
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
    p_report_request_id  IN number) IS

   l_procedure_name  varchar2(80) := 'preaccounting';

BEGIN
  null;
END preaccounting;

--------------------------------------------------------------------------------
--
-- extract-processing - used to extract all accounting for the events
--
--------------------------------------------------------------------------------

PROCEDURE extract
   (p_application_id     IN number,
    p_accounting_mode    IN varchar2) IS

   l_procedure_name  varchar2(80) := 'extract';

BEGIN
   if p_application_id in (140,8400) then
     IGI_IAC_EXTRACT_PKG.extract(p_application_id,p_accounting_mode);
   end if;
END extract;

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
    p_report_request_id  IN number) IS

   l_procedure_name  varchar2(80) := 'postaccounting';

BEGIN
  null;
END postaccounting;

----------------------------------------------------------------------------------
-- post-processing
--
--------------------------------------------------------------------------------

PROCEDURE postprocessing
   (p_application_id     IN number,
    p_accounting_mode    IN varchar2) IS

BEGIN
  null;
END postprocessing;

--------------------------------------------------------------------------------

END IGI_XLA_ACCOUNTING_MAIN_PKG;

/
