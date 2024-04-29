--------------------------------------------------------
--  DDL for Package Body FA_XLA_ACCOUNTING_MAIN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_XLA_ACCOUNTING_MAIN_PKG" AS
/* $Header: FAXLAXMB.pls 120.10.12010000.4 2009/10/29 12:45:36 bridgway ship $ */

G_CURRENT_RUNTIME_LEVEL        NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

G_LEVEL_STATEMENT     CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
G_LEVEL_PROCEDURE     CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
G_LEVEL_EVENT         CONSTANT NUMBER := FND_LOG.LEVEL_EVENT;
G_LEVEL_EXCEPTION     CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
G_LEVEL_ERROR         CONSTANT NUMBER := FND_LOG.LEVEL_ERROR;
G_LEVEL_UNEXPECTED    CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;

G_MODULE_NAME         CONSTANT VARCHAR2(50):= 'fa.plsql.fa_xla_accounting_main_pkg.';


--------------------------------------------------------------------------------
--
-- Workflow Subscription for pre-processing - used to lock the
-- assets requiring it in FA...
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

   IF p_application_id = 140 THEN

      if not fa_cache_pkg.fazprof then
         null;
      end if;

      fa_xla_extract_util_pkg.lock_assets
         (p_book_type_code => p_valuation_method,
          p_ledger_id      => p_ledger_id);


      -- BUG# 4439932
      -- the following is for setting istatus on non-accountable events

      fa_xla_extract_util_pkg.update_nonaccountable_events
         (p_book_type_code   => p_valuation_method,
          p_process_category => p_process_category,
          p_ledger_id        => p_ledger_id);

   END IF;

EXCEPTION
   WHEN OTHERS THEN
        IF (G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL ) THEN
           fnd_message.set_name('OFA','FA_SHARED_ORACLE_ERR');
           fnd_message.set_token('ORACLE_ERR',SQLERRM);
           FND_LOG.MESSAGE (G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_procedure_name,TRUE);
        END IF;
        raise;

END preaccounting;

--------------------------------------------------------------------------------
--
-- Workflow Subscription for main-processing - used to extract
-- all accounting for the events
--
--------------------------------------------------------------------------------


PROCEDURE extract
   (p_application_id     IN number,
    p_accounting_mode    IN varchar2) IS

   l_procedure_name  varchar2(80) := 'extract';

BEGIN

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN

      fnd_log.string(G_LEVEL_PROCEDURE,
                     G_MODULE_NAME||l_procedure_name||'.begin',
                     'Beginning of procedure');

   END IF;


   IF p_application_id = 140 THEN

      if not fa_cache_pkg.fazprof then
         null;
      end if;

      fa_xla_extract_util_pkg.extract(p_accounting_mode => p_accounting_mode);

   END IF;

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN

      fnd_log.string(G_LEVEL_PROCEDURE,
                     G_MODULE_NAME||l_procedure_name||'.end',
                     'End of procedure');

   END IF;


EXCEPTION
   WHEN OTHERS THEN
        IF (G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL ) THEN
           fnd_message.set_name('OFA','FA_SHARED_ORACLE_ERR');
           fnd_message.set_token('ORACLE_ERR',SQLERRM);
           FND_LOG.MESSAGE (G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_procedure_name,TRUE);
        END IF;
        raise;

END extract;

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

   IF p_application_id = 140 THEN

      if not fa_cache_pkg.fazprof then
         null;
      end if;

      fa_xla_extract_util_pkg.unlock_assets
        (p_book_type_code => p_valuation_method,
         p_ledger_id      => p_ledger_id);

   END IF;

EXCEPTION
   WHEN OTHERS THEN
        IF (G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL ) THEN
           fnd_message.set_name('OFA','FA_SHARED_ORACLE_ERR');
           fnd_message.set_token('ORACLE_ERR',SQLERRM);
           FND_LOG.MESSAGE (G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_procedure_name,TRUE);
        END IF;
        raise;


END postaccounting;

--------------------------------------------------------------------------------

PROCEDURE postprocessing
   (p_application_id     IN number,
    p_accounting_mode    IN varchar2) IS

BEGIN

  NULL;

END postprocessing;

--------------------------------------------------------------------------------

END fa_xla_accounting_main_pkg;

/
