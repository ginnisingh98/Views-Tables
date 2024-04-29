--------------------------------------------------------
--  DDL for Package Body XLA_ACCT_SETUP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_ACCT_SETUP_PKG" AS
-- $Header: xlasuaoi.pkb 120.17.12000000.2 2007/07/24 15:22:31 jlarre ship $
/*===========================================================================+
|             Copyright (c) 1995-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| PACKAGE NAME                                                               |
|    xla_acct_setup_pkg                                                      |
|                                                                            |
| DESCRIPTION                                                                |
|    XLA Accounting Options Setup                                            |
|    The package defaults values for the accounting setup options.           |
|                                                                            |
| HISTORY                                                                    |
|    06-Feb-03 Dimple Shah    Created                                        |
|    12-Jun-03 S. Singhania   Fixed FND messages (bug #  3001156)            |
|    15-Jun-03 S. Singhania   Fixed the FETCH statement for c_applications in|
|                               setup_options.                               |
|    10-Jul-03 S. Singhania   Changed table name from XLA_EVENT_CLASSES_ATTR |
|                               to XLA_EVENT_CLASS_ATTRS                     |
|    21-Aug-03 S. Joshi       Removed COPY_DOC_SEQUENCE_FLAG                 |
|    05-Sep-03 S. Singhania   Fix for bug # 3128896. Modified the procedure  |
|                               INSERT_LEDGER_OPTIONS to set correct default |
|                               for the option 'General Ledger Journal Entry |
|                               Summarization'                               |
|    28-Sep-03 S. Singhania   Made changes for enhancing the package to      |
|                               include APIs for event_class setups (3151792)|
|                               - Added global variables and the API         |
|                                   SET_DEFAULT_VALUES                       |
|                               - Added APIs PERFORM_EVENT_CLASS_SETUP and   |
|                                   DELETE_EVENT_CLASS_SETUP                 |
|                               - Modified following procedures:             |
|                                   INSERT_JE_CATEGORY, SETUP_OPTIONS        |
|                             Minor changes in following procedures:         |
|                               SETUP_LEDGER_OPTIONS, INSERT_LAUNCH_OPTIONS, |
|                               INSERT_LEDGER_OPTIONS                        |
|    18-Nov-03 S. Singhania   Changed the default values for 'g_porcesses'   |
|                               and 'g_processing_unit_size' to 1 and 1000   |
|                               respectively in routine SET_DEFAULT_VALUES.  |
|                               (Bug # 3259247).                             |
|    10-Dec-03 S. Singhania   Added the API PERFORM_APPLICATION_SETUP_CP for |
|                               the concurrent program. (Bug 3229146).       |
|    17-Jun-04 S. Singhania   Added UPGRADE_LEDGER_OPTIONS API for AX upgrade|
|    17-JUN-04 S. Singhania   Fixed GSCC warnings for  File.Sql.35           |
|    18-JUN-04 S. Singhania   Added more validations to the API              |
|                               UPGRADE_LEDGER_OPTIONS                       |
|    01-NOV-04 S. Singhania   Made changes for Valuation Method Enhancements:|
|                               - Added g_capture_event_flag                 |
|                               - Modified SET_DEFAULT_VALUES, SETUP_OPTIONS,|
|                                 INSERT_LEDGER_OPTIONS and                  |
|                                 PERFORM_APPLICATION_SETUP_CP               |
|    19-Aug-05 V.Swapna       Removed alc_enabled_flag(bug #4364830)         |
|    24-JUL-2007 Jorge Larre  Bug 5582560                                    |
|     The program loops on applications and sets the global variable         |
|     g_capture_event_flag based on the valuation method. This is done in a  |
|     simple IF with no else clause for the other case, so after the first   |
|     application meets the condition, the global variable remains set for   |
|     all the other applications. Solution: add an ELSE clause to the IF.    |
+===========================================================================*/

--=============================================================================
--           ****************  declaraions  ********************
--=============================================================================
g_accounting_mode_code             VARCHAR2(1);
g_acctg_mode_override_flag         VARCHAR2(1);
g_summary_report_flag              VARCHAR2(1);
g_summary_report_override_flag     VARCHAR2(1);
g_submit_transfer_to_gl_flag       VARCHAR2(1);
g_submit_xfer_override_flag        VARCHAR2(1);
g_submit_gl_post_flag              VARCHAR2(1);
g_submit_gl_post_override_flag     VARCHAR2(1);
g_error_limit                      NUMBER;
g_processes                        NUMBER;
g_processing_unit_size             NUMBER;

g_transfer_to_gl_mode_code         VARCHAR2(1);
g_acct_reversal_option_code        VARCHAR2(30);
g_enabled_flag                     VARCHAR2(1);
g_capture_event_flag               VARCHAR2(1);

-------------------------------------------------------------------------------
-- forward declarion of private procedures and functions
-------------------------------------------------------------------------------

PROCEDURE insert_launch_options
       (p_ledger_id                  IN NUMBER
       ,p_application_id             IN NUMBER);

PROCEDURE insert_ledger_options
       (p_ledger_id                  IN NUMBER
       ,p_application_id             IN NUMBER);

PROCEDURE insert_je_category
       (p_ledger_id                  IN NUMBER
       ,p_application_id             IN NUMBER
       ,p_event_class_code           IN VARCHAR2);

PROCEDURE check_primary_ledger_options
       (p_primary_ledger_id          IN NUMBER
       ,p_application_id             IN NUMBER);

FUNCTION check_ledger_currency
       (p_primary_ledger_id          IN NUMBER
       ,p_ledger_id                  IN NUMBER
       ,p_application_id             IN NUMBER)
RETURN BOOLEAN;

PROCEDURE setup_options
       (p_primary_ledger_id          IN NUMBER
       ,p_ledger_id                  IN NUMBER
       ,p_application_id             IN NUMBER
       ,p_valuation_method_flag      IN VARCHAR2
       ,p_event_class_code           IN VARCHAR2);

PROCEDURE set_default_values;

--=============================================================================
--               *********** Local Trace Routine **********
--=============================================================================
g_debug_flag      VARCHAR2(1);

PROCEDURE trace
       (p_msg                        IN VARCHAR2
       ,p_level                      IN NUMBER) IS
BEGIN
   IF g_debug_flag = 'Y' THEN
      xla_utility_pkg.trace
         (p_msg
         ,p_level);
   END IF;
EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
         (p_location   => 'xla_acct_setup_pub_pkg.trace');
END trace;


--=============================================================================
--          *********** public procedures and functions **********
--=============================================================================
--=============================================================================
--
--
--
--
--
--
--
--
--
--
-- Following are the public routines
--
--    1.    setup_ledger_options
--    2.    check_acctg_method_for_ledger
--    3.    perform_event_class_setup
--    4.    delete_event_class_setup
--    5.    perform_application_setup_cp
--
--
--
--
--
--
--
--
--
--
--
--
--=============================================================================

--=============================================================================
--
-- Sets up ledger options for all subledger applications and given ledger
--
--=============================================================================
PROCEDURE setup_ledger_options
       (p_primary_ledger_id          IN NUMBER
       ,p_ledger_id                  IN NUMBER) IS

CURSOR csr_applications IS
   SELECT application_id
         ,valuation_method_flag
   FROM xla_subledgers;

BEGIN
   trace('> xla_acct_setup_pkg.setup_ledger_options'   , 10);
   trace('ledger_id              = '||p_ledger_id     , 20);
   trace('primary_ledger_id      = '||p_primary_ledger_id     , 20);

   ----------------------------------------------------------------------------
   -- Call routine to set the default values.
   ----------------------------------------------------------------------------
   set_default_values;

   ----------------------------------------------------------------------------
   -- Check if accounting method is valid for the ledger
   ----------------------------------------------------------------------------
   check_acctg_method_for_ledger
      (p_primary_ledger_id   => p_primary_ledger_id
      ,p_ledger_id           => p_ledger_id);

   ----------------------------------------------------------------------------
   -- Loop through all applications
   ----------------------------------------------------------------------------
   FOR c1 IN csr_applications LOOP
      -------------------------------------------------------------------------
      -- Validate and setup the ledger options for each application
      -------------------------------------------------------------------------
      setup_options
         (p_primary_ledger_id     => p_primary_ledger_id
         ,p_ledger_id             => p_ledger_id
         ,p_application_id        => c1.application_id
         ,p_valuation_method_flag => c1.valuation_method_flag
         ,p_event_class_code      => NULL);

   END LOOP;

   trace('< xla_acct_setup_pkg.setup_ledger_options'    , 10);

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location   => 'xla_acct_setup_pkg.setup_ledger_options');

END setup_ledger_options;



--=============================================================================
--
-- Checks if a valid accounting method is attached to the ledger
--
--=============================================================================
PROCEDURE check_acctg_method_for_ledger
       (p_primary_ledger_id          IN NUMBER
       ,p_ledger_id                  IN NUMBER) IS

l_primary_ledger_id        NUMBER(38);
l_ledger_id                NUMBER(38);
l_ledger_name              VARCHAR2(30) := NULL;
l_pr_ledger_name           VARCHAR2(30) := NULL;
l_accounting_method_name   VARCHAR2(80) := NULL;
l_accounting_method_type   VARCHAR2(80) := NULL;

CURSOR c_ledger IS
   SELECT chart_of_accounts_id, sla_accounting_method_code, sla_accounting_method_type
     FROM xla_gl_ledgers_v
    WHERE ledger_id = p_ledger_id;

l_ledger                   c_ledger%rowtype;

CURSOR c_trx_coa IS
   SELECT transaction_coa_id
     FROM xla_acctg_methods_b
    WHERE accounting_method_type_code = l_ledger.sla_accounting_method_type
      AND accounting_method_code      = l_ledger.sla_accounting_method_code;

l_trx_coa                  c_trx_coa%rowtype;

CURSOR c_pr_ledger_coa IS
   SELECT chart_of_accounts_id
     FROM xla_gl_ledgers_v
    WHERE ledger_id = p_primary_ledger_id;

l_pr_ledger_coa            c_pr_ledger_coa%rowtype;

BEGIN
   trace('> xla_acct_setup_pkg.check_acctg_method_for_ledger'   , 10);
   trace('ledger_id              = '||p_ledger_id     , 20);
   trace('primary_ledger_id      = '||p_primary_ledger_id     , 20);

   l_primary_ledger_id        := p_primary_ledger_id;
   l_ledger_id                := p_ledger_id;


   OPEN c_ledger;
   FETCH c_ledger INTO l_ledger;

   IF c_ledger%notfound or l_ledger.sla_accounting_method_code is NULL THEN
      xla_validations_pkg.get_ledger_name
         (p_ledger_id       => l_ledger_id
         ,p_ledger_name     => l_ledger_name);

      -------------------------------------------------------------------------
      -- Raise error
      -------------------------------------------------------------------------
      xla_exceptions_pkg.raise_message
         (p_appli_s_name  => 'XLA'
         ,p_msg_name      => 'XLA_SU_NO_SLA_METHOD'
         ,p_token_1       => 'LEDGER_NAME'
         ,p_value_1       => l_ledger_name);
   ELSE
      OPEN c_trx_coa;
      FETCH c_trx_coa INTO l_trx_coa;
      CLOSE c_trx_coa;

      IF l_trx_coa.transaction_coa_id is not null THEN
         IF p_ledger_id = p_primary_ledger_id THEN
            -------------------------------------------------------------------
            -- Following should never happen. If this happens this is a bug.
            -- That's the reason this is does not have a proper messge.
            -------------------------------------------------------------------
            IF l_trx_coa.transaction_coa_id <> l_ledger.chart_of_accounts_id THEN

               xla_validations_pkg.get_ledger_name
                 (p_ledger_id    => l_primary_ledger_id
                 ,p_ledger_name  => l_pr_ledger_name);

               xla_validations_pkg.get_accounting_method_info
                 (p_accounting_method_type_code    => l_ledger.sla_accounting_method_type
                 ,p_accounting_method_code         => l_ledger.sla_accounting_method_code
                 ,p_accounting_method_name         => l_accounting_method_name
                 ,p_accounting_method_type         => l_accounting_method_type);

               ----------------------------------------------------------------
               -- Raise error
               ----------------------------------------------------------------
               xla_exceptions_pkg.raise_message
                  (p_appli_s_name  => 'XLA'
                  ,p_msg_name      => 'XLA_COMMON_ERROR'
                  ,p_token_1       => 'ERROR'
                  ,p_value_1       => 'Transaction COA mismatched with ledger COA for '||l_pr_ledger_name
                  ,p_token_2       => 'LOCATION'
                  ,p_value_2       => 'xla_acct_setup_pkgcheck_acctg_method_for_ledger');
            END IF;
         ELSE
            -------------------------------------------------------------------
            -- Ledger is secondary, so check the chart of accounts of primary
            -- ledger
            -------------------------------------------------------------------
            OPEN c_pr_ledger_coa;
            FETCH c_pr_ledger_coa INTO l_pr_ledger_coa;
            CLOSE c_pr_ledger_coa;

            -------------------------------------------------------------------
            -- Following should never happen. If this happens this is a bug.
            -- That's the reason this is does not have a proper messge.
            -------------------------------------------------------------------
            IF l_trx_coa.transaction_coa_id <> l_pr_ledger_coa.chart_of_accounts_id THEN

               xla_validations_pkg.get_ledger_name
                  (p_ledger_id    => l_ledger_id
                  ,p_ledger_name  => l_ledger_name);

               xla_validations_pkg.get_ledger_name
                  (p_ledger_id    => l_primary_ledger_id
                  ,p_ledger_name  => l_pr_ledger_name);

               xla_validations_pkg.get_accounting_method_info
                 (p_accounting_method_type_code    => l_ledger.sla_accounting_method_type
                 ,p_accounting_method_code         => l_ledger.sla_accounting_method_code
                 ,p_accounting_method_name         => l_accounting_method_name
                 ,p_accounting_method_type         => l_accounting_method_type);

               ----------------------------------------------------------------
               -- Raise error
               ----------------------------------------------------------------
               xla_exceptions_pkg.raise_message
                  (p_appli_s_name  => 'XLA'
                  ,p_msg_name      => 'XLA_COMMON_ERROR'
                  ,p_token_1       => 'ERROR'
                  ,p_value_1       => 'Transaction COA mismatched with the primary ledger COA for '||l_ledger_name
                  ,p_token_2       => 'LOCATION'
                  ,p_value_2       => 'xla_acct_setup_pkgcheck_acctg_method_for_ledger');
            END IF;
         END IF;
      END IF;
   END IF;
   CLOSE c_ledger;

   trace('< xla_acct_setup_pkg.check_acctg_method_for_ledger'    , 10);

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   IF c_ledger%ISOPEN THEN
      CLOSE c_ledger;
   END IF;
   IF c_trx_coa%ISOPEN THEN
      CLOSE c_trx_coa;
   END IF;
   IF c_pr_ledger_coa%ISOPEN THEN
      CLOSE c_pr_ledger_coa;
   END IF;
   RAISE;
WHEN OTHERS THEN
   IF c_ledger%ISOPEN THEN
      CLOSE c_ledger;
   END IF;
   IF c_trx_coa%ISOPEN THEN
      CLOSE c_trx_coa;
   END IF;
   IF c_pr_ledger_coa%ISOPEN THEN
      CLOSE c_pr_ledger_coa;
   END IF;
   xla_exceptions_pkg.raise_message
      (p_location   => 'xla_acct_setup_pkg.check_acctg_method_for_ledger');
END check_acctg_method_for_ledger;



--=============================================================================
--
--
--
--=============================================================================
PROCEDURE perform_event_class_setup
       (p_application_id             IN NUMBER
       ,p_event_class_code           IN VARCHAR2) IS
CURSOR csr_ledgers IS
   SELECT xlr.ledger_id                        ledger_id
         ,xlr.primary_ledger_id                primary_ledger_id
         ,DECODE(xlo.ledger_id,NULL,'N','Y')   ledger_setup_flag
     FROM xla_ledger_relationships_v  xlr
         ,xla_ledger_options          xlo
    WHERE xlr.ledger_category_code IN ('PRIMARY','SECONDARY')
      AND xlr.sla_accounting_method_code IS NOT NULL
      AND xlo.application_id(+)    =  p_application_id
      AND xlo.ledger_id     (+)    =  xlr.ledger_id
   ORDER BY xlr.ledger_category_code;
l_valutation_method_flag   VARCHAR2(1);

BEGIN
   trace('> xla_acct_setup_pkg.perform_event_class_setup'    , 10);
   trace('p_event_class_code  = '||p_event_class_code     , 20);
   trace('p_application_id    = '||p_application_id       , 20);

   SELECT valuation_method_flag
     INTO l_valutation_method_flag
     FROM xla_subledgers
    WHERE application_id = p_application_id;

   trace('valuation_method_flag  = '||l_valutation_method_flag     , 40);


   FOR c1 IN csr_ledgers LOOP
      IF c1.ledger_setup_flag = 'N' THEN
         ----------------------------------------------------------------------
         -- Call routine to set the default values.
         ----------------------------------------------------------------------
         set_default_values;

         ----------------------------------------------------------------------
         -- Check if accounting method is valid for the ledger
         ----------------------------------------------------------------------
         check_acctg_method_for_ledger
            (p_primary_ledger_id     => c1.primary_ledger_id
            ,p_ledger_id             => c1.ledger_id);

         ----------------------------------------------------------------------
         -- Call API to perform the setup of options.
         ----------------------------------------------------------------------
         setup_options
            (p_primary_ledger_id     => c1.primary_ledger_id
            ,p_ledger_id             => c1.ledger_id
            ,p_application_id        => p_application_id
            ,p_valuation_method_flag => l_valutation_method_flag
            ,p_event_class_code      => p_event_class_code);
      ELSE
         insert_je_category
            (p_ledger_id           => c1.ledger_id
            ,p_application_id      => p_application_id
            ,p_event_class_code    => p_event_class_code);
      END IF;

   END LOOP;
   trace('< xla_acct_setup_pkg.perform_event_class_setup'    , 10);
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location   => 'xla_acct_setup_pkg.perform_event_class_setup');
END perform_event_class_setup;


--=============================================================================
--
--
--
--=============================================================================
PROCEDURE delete_event_class_setup
       (p_application_id             IN NUMBER
       ,p_event_class_code           IN VARCHAR2) IS
BEGIN
   trace('> xla_acct_setup_pkg.delete_event_class_setup'     , 10);
   trace('p_event_class_code  = '||p_event_class_code     , 20);
   trace('p_application_id    = '||p_application_id       , 20);

   ----------------------------------------------------------------------------
   -- Delete from xla_je_categories table.
   ----------------------------------------------------------------------------
   DELETE FROM xla_je_categories
         WHERE application_id    = p_application_id
           AND event_class_code  = p_event_class_code;
   trace('Number of rows deleted    = '||SQL%ROWCOUNT        , 40);

   trace('< xla_acct_setup_pkg.delete_event_class_setup'     , 10);
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location   => 'xla_acct_setup_pkg.delete_event_class_setup');
END delete_event_class_setup;



--=============================================================================
--
-- This API is a registered concurrent program that can be executed for one/all
-- applications registered with XLA, to compelete the subledger's accounting
-- setup for defined ledgers.
-- It performs following tasks for the application(s):
--    1.   Deletes from xla_je_categories the event classes that do not
--         exist in xla_event_classes.
--    2.   Inserts into xla_launch_options for ledgers that do not exist there.
--    3.   Inserts into xla_ledger_options for ledgers that do not exist there.
--    4.   Inserts into xla_je_categories the event classes that were not setup
--         earlier.
--
--=============================================================================
PROCEDURE perform_application_setup_cp
       (p_errbuf                     OUT NOCOPY VARCHAR2
       ,p_retcode                    OUT NOCOPY NUMBER
       ,p_application_id             IN  NUMBER) IS
CURSOR csr_applications IS
   SELECT application_id
         ,application_name
     FROM xla_subledgers_fvl
    WHERE application_id = NVL(p_application_id,application_id);

l_sysdate        DATE;
BEGIN
   xla_utility_pkg.activate('SRS_DBP', 'xla_acct_setup_pkg.perform_application_setup_cp');

   trace('> xla_acct_setup_pkg.perform_application_setup_cp', 20);
   trace('p_application_id        = '||p_application_id,20);

   xla_environment_pkg.refresh;

   l_sysdate        := sysdate;

   ----------------------------------------------------------------------------
   -- Calling the API to set the default values for the different options
   ----------------------------------------------------------------------------
   set_default_values;

   FOR c1 IN csr_applications LOOP

      trace('Updating Subledger Accounting Options for application = '||
            c1.application_name, 20);

      -------------------------------------------------------------------------
      -- Deleting from xla_je_categories all the event classes for the
      -- application that has been deleted from AMB tables.
      -------------------------------------------------------------------------
      trace('Deleting orphan rows from xla_je_categories for event classes '||
            'that do not exist.....',20);

      DELETE
         FROM xla_je_categories         xjc
        WHERE application_id         =  c1.application_id
          AND NOT EXISTS
              (SELECT 1
                 FROM xla_event_classes_b
                WHERE application_id          = xjc.application_id
                  AND event_class_code        = xjc.event_class_code);

      trace('Number of rows deleted      = '||SQL%ROWCOUNT,30);


      -------------------------------------------------------------------------
      -- Inserting into xla_launch_options table rows for the application and
      -- all the eligible ledgers.
      -------------------------------------------------------------------------
      trace('Inserting rows in xla_launch_options for the ledgers '||
            'that are not already setup',20);

      INSERT INTO xla_launch_options
        (application_id
        ,ledger_id
        ,accounting_mode_code
        ,accounting_mode_override_flag
        ,summary_report_flag
        ,summary_report_override_flag
        ,submit_transfer_to_gl_flag
        ,submit_transfer_override_flag
        ,submit_gl_post_flag
        ,submit_gl_post_override_flag
        ,error_limit
        ,processes
        ,processing_unit_size
        ,creation_date
        ,created_by
        ,last_update_date
        ,last_updated_by
        ,last_update_login)
      (SELECT DISTINCT
         c1.application_id
        ,xlr.ledger_id
        ,g_accounting_mode_code
        ,g_acctg_mode_override_flag
        ,g_summary_report_flag
        ,g_summary_report_override_flag
        ,g_submit_transfer_to_gl_flag
        ,g_submit_xfer_override_flag
        ,g_submit_gl_post_flag
        ,g_submit_gl_post_override_flag
        ,g_error_limit
        ,g_processes
        ,g_processing_unit_size
        ,l_sysdate
        ,xla_environment_pkg.g_usr_id
        ,l_sysdate
        ,xla_environment_pkg.g_usr_id
        ,xla_environment_pkg.g_login_id
      FROM
         xla_ledger_relationships_v           xlr
        ,xla_subledgers                       xsl
        ,xla_acctg_methods_b                  xam
        ,gl_ledgers                           gll
      WHERE
          xlr.ledger_category_code          IN ('PRIMARY','SECONDARY')
      AND xlr.sla_accounting_method_code    IS NOT NULL
      AND xsl.application_id                 = c1.application_id
      AND xlr.ledger_category_code           = DECODE(xsl.valuation_method_flag
                                                     ,'N','PRIMARY'
                                                     ,'Y',xlr.ledger_category_code)
      AND xam.accounting_method_code         = xlr.sla_accounting_method_code
      AND xam.accounting_method_type_code    = xlr.sla_accounting_method_type
      AND gll.ledger_id                      = xlr.primary_ledger_id
      AND NVL(xam.transaction_coa_id
             ,gll.chart_of_accounts_id)      = gll.chart_of_accounts_id
      AND NOT EXISTS (SELECT 1
                        FROM xla_launch_options
                       WHERE ledger_id               = xlr.ledger_id
                         AND application_id          = xsl.application_id));

      trace('Number of rows inserted      = '||SQL%ROWCOUNT,30);



      -------------------------------------------------------------------------
      -- Inserting into xla_ledger_options table rows for the application and
      -- all the eligible ledgers.
      -------------------------------------------------------------------------
      trace('Inserting rows in xla_ledger_options for the ledgers '||
            'that are not already setup',20);

      -------------------------------------------------------------------------
      -- The value of 'transfer_to_gl_mode_code' is decided based on the value
      -- of column gl_ledgers.net_income_code_combination_id, which decides if
      -- 'Daily Balances' are enabled for the ledger or not. (Bug 3128896).
      -------------------------------------------------------------------------
      INSERT INTO xla_ledger_options
        (application_id
        ,ledger_id
        ,transfer_to_gl_mode_code
        ,acct_reversal_option_code
        ,capture_event_flag
        ,rounding_rule_code
        ,enabled_flag
        ,creation_date
        ,created_by
        ,last_update_date
        ,last_updated_by
        ,last_update_login
        --,merge_acct_option_code
        )
      (SELECT DISTINCT
         c1.application_id
        ,xlr.ledger_id
        ,decode(gl2.net_income_code_combination_id,NULL,'P','A')
        ,g_acct_reversal_option_code
        ,DECODE(xsl.valuation_method_flag
               ,'Y','Y'
               ,DECODE(xlr.ledger_category_code
                      ,'PRIMARY', 'Y'
                      ,'N')
               )
        ,'NEAREST'
        ,g_enabled_flag
        ,l_sysdate
        ,xla_environment_pkg.g_usr_id
        ,l_sysdate
        ,xla_environment_pkg.g_usr_id
        ,xla_environment_pkg.g_login_id
        --,'NONE'
      FROM
         xla_ledger_relationships_v           xlr
        ,xla_subledgers                       xsl
        ,xla_acctg_methods_b                  xam
        ,gl_ledgers                           gll
        ,gl_ledgers                           gl2
      WHERE
          xlr.ledger_category_code          IN ('PRIMARY','SECONDARY')
      AND xlr.sla_accounting_method_code    IS NOT NULL
      AND xsl.application_id                 = c1.application_id
      AND xam.accounting_method_code         = xlr.sla_accounting_method_code
      AND xam.accounting_method_type_code    = xlr.sla_accounting_method_type
      AND gll.ledger_id                      = xlr.primary_ledger_id
      AND gl2.ledger_id                      = xlr.ledger_id
      AND NVL(xam.transaction_coa_id
             ,gll.chart_of_accounts_id)      = gll.chart_of_accounts_id
      AND NOT EXISTS (SELECT 1
                        FROM xla_ledger_options
                       WHERE ledger_id               = xlr.ledger_id
                         AND application_id          = xsl.application_id));

      trace('Number of rows inserted      = '||SQL%ROWCOUNT,30);



      -------------------------------------------------------------------------
      -- Inserting into xla_je_categories table rows for all the eligible
      -- classes for the application and all the eligible ledgers.
      -------------------------------------------------------------------------
      trace('Inserting rows in xla_je_categories for the event classes and ledgers '||
            'that are not already setup',20);

      INSERT INTO xla_je_categories
        (application_id
        ,ledger_id
        ,entity_code
        ,event_class_code
        ,je_category_name
        ,creation_date
        ,created_by
        ,last_update_date
        ,last_updated_by
        ,last_update_login)
      (SELECT DISTINCT
         c1.application_id
        ,xlr.ledger_id
        ,xec.entity_code
        ,xec.event_class_code
        ,xec.je_category_name
        ,l_sysdate
        ,xla_environment_pkg.g_usr_id
        ,l_sysdate
        ,xla_environment_pkg.g_usr_id
        ,xla_environment_pkg.g_login_id
      FROM
         xla_ledger_relationships_v           xlr
        ,xla_subledgers                       xsl
        ,xla_acctg_methods_b                  xam
        ,gl_ledgers                           gll
        ,xla_event_class_attrs                xec
      WHERE
          xlr.ledger_category_code          IN ('PRIMARY','SECONDARY')
      AND xlr.sla_accounting_method_code    IS NOT NULL
      AND xsl.application_id                 = c1.application_id
      AND xam.accounting_method_code         = xlr.sla_accounting_method_code
      AND xam.accounting_method_type_code    = xlr.sla_accounting_method_type
      AND gll.ledger_id                      = xlr.primary_ledger_id
      AND NVL(xam.transaction_coa_id
             ,gll.chart_of_accounts_id)      = gll.chart_of_accounts_id
      AND xec.application_id                 = xsl.application_id
      AND NOT EXISTS (SELECT 1
                        FROM xla_je_categories
                       WHERE application_id          = xsl.application_id
                         AND ledger_id               = xlr.ledger_id
                         AND entity_code             = xec.entity_code
                         AND event_class_code        = xec.event_class_code));

      trace('Number of rows inserted      = '||SQL%ROWCOUNT,30);

   END LOOP;

   COMMIT;
   ----------------------------------------------------------------------------
   -- set out variables
   ----------------------------------------------------------------------------
   p_retcode             := 0;
   p_errbuf              := NULL;

   trace('< xla_acct_setup_pkg.perform_application_setup_cp', 20);
   xla_utility_pkg.deactivate('xla_acct_setup_pkg.perform_application_setup_cp');
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   ----------------------------------------------------------------------------
   -- set out variables
   ----------------------------------------------------------------------------
   p_retcode                := 2;
   p_errbuf                 := xla_messages_pkg.get_message;

   xla_utility_pkg.print_logfile(p_errbuf);
   trace('< xla_acct_setup_pkg.perform_application_setup_cp (exception)', 20);
   xla_utility_pkg.deactivate('xla_acct_setup_pkg.perform_application_setup_cp');
WHEN OTHERS                                   THEN
   ----------------------------------------------------------------------------
   -- set out variables
   ----------------------------------------------------------------------------
   p_retcode                := 2;
   p_errbuf                 := sqlerrm;

   xla_utility_pkg.print_logfile(p_errbuf);
   trace('< xla_acct_setup_pkg.perform_application_setup_cp (exception)', 20);
   xla_utility_pkg.deactivate('xla_acct_setup_pkg.perform_application_setup_cp');
END perform_application_setup_cp;



--=============================================================================
--          *********** private procedures and functions **********
--=============================================================================
--=============================================================================
--
--
--
--
--
--
--
--
--
--
-- Following are the private routines
--
--    1.    insert_launch_options
--    2.    insert_ledger_options
--    3.    insert_je_category
--    4.    check_primary_ledger_options
--    5.    check_ledger_currency
--    6.    setup_options
--    7.    set_default_values
--
--
--
--
--
--
--
--
--
--
--
--
--=============================================================================
--=============================================================================
--
--
--
--=============================================================================
PROCEDURE insert_launch_options
       (p_ledger_id                  IN NUMBER
       ,p_application_id             IN NUMBER) IS

l_exist                           VARCHAR2(1);

CURSOR c_launch_options IS
   SELECT 'x'
     FROM xla_launch_options
    WHERE application_id   = p_application_id
      AND ledger_id        = p_ledger_id;

BEGIN
   trace('> xla_acct_setup_pkg.insert_launch_options'   , 10);
   trace('ledger_id          = '||p_ledger_id     , 20);
   trace('application_id     = '||p_application_id     , 20);

   OPEN c_launch_options;
   FETCH c_launch_options INTO l_exist ;

   IF c_launch_options%NOTFOUND THEN
      INSERT INTO xla_launch_options
        (application_id
        ,ledger_id
        ,accounting_mode_code
        ,accounting_mode_override_flag
        ,summary_report_flag
        ,summary_report_override_flag
        ,submit_transfer_to_gl_flag
        ,submit_transfer_override_flag
        ,submit_gl_post_flag
        ,submit_gl_post_override_flag
        ,error_limit
        ,processes
        ,processing_unit_size
        ,creation_date
        ,created_by
        ,last_update_date
        ,last_updated_by
        ,last_update_login)
      VALUES
        (p_application_id
        ,p_ledger_id
        ,g_accounting_mode_code
        ,g_acctg_mode_override_flag
        ,g_summary_report_flag
        ,g_summary_report_override_flag
        ,g_submit_transfer_to_gl_flag
        ,g_submit_xfer_override_flag
        ,g_submit_gl_post_flag
        ,g_submit_gl_post_override_flag
        ,g_error_limit
        ,g_processes
        ,g_processing_unit_size
        ,sysdate
        ,xla_environment_pkg.g_usr_id
        ,sysdate
        ,xla_environment_pkg.g_usr_id
        ,xla_environment_pkg.g_login_id);
   END IF;

   CLOSE c_launch_options;

   trace('< xla_acct_setup_pkg.insert_launch_options'    , 10);
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   IF c_launch_options%ISOPEN THEN
      CLOSE c_launch_options;
   END IF;
   RAISE;
WHEN OTHERS THEN
   IF c_launch_options%ISOPEN THEN
      CLOSE c_launch_options;
   END IF;
   xla_exceptions_pkg.raise_message
      (p_location   => 'xla_acct_setup_pkg.insert_launch_options');
END insert_launch_options;


--=============================================================================
--
-- Insert into ledger options
--
--=============================================================================
PROCEDURE insert_ledger_options
       (p_ledger_id                  IN NUMBER
       ,p_application_id             IN NUMBER) IS
l_exist                           VARCHAR2(1);

CURSOR c_ledger_options IS
   SELECT 'x'
     FROM xla_ledger_options
    WHERE application_id   = p_application_id
      AND ledger_id        = p_ledger_id;

BEGIN
   trace('> xla_acct_setup_pkg.insert_ledger_options'   , 10);
   trace('ledger_id        = '||p_ledger_id          , 20);
   trace('application_id   = '||p_application_id     , 20);

   OPEN c_ledger_options;
   FETCH c_ledger_options INTO l_exist ;

   IF c_ledger_options%notfound THEN
      -------------------------------------------------------------------------
      -- Added following to decide the default value for the
      -- 'General Ledger Journal Entry Summarization' option based on if the
      -- Daily Balance is enabled or not for the ledger. (bug # 3128896)
      -------------------------------------------------------------------------
      IF g_transfer_to_gl_mode_code IS NULL THEN
         SELECT decode(net_income_code_combination_id,NULL,'P','A')
           INTO g_transfer_to_gl_mode_code
           FROM gl_ledgers
          WHERE ledger_id = p_ledger_id;
      END IF;

      INSERT INTO xla_ledger_options
        (application_id
        ,ledger_id
        ,transfer_to_gl_mode_code
        ,acct_reversal_option_code
        ,capture_event_flag
        ,rounding_rule_code
        ,enabled_flag
        ,creation_date
        ,created_by
        ,last_update_date
        ,last_updated_by
        ,last_update_login
        --,merge_acct_option_code
        )
      VALUES
        (p_application_id
        ,p_ledger_id
        ,g_transfer_to_gl_mode_code
        ,g_acct_reversal_option_code
        ,g_capture_event_flag
        ,'NEAREST'
        ,g_enabled_flag
        ,sysdate
        ,xla_environment_pkg.g_usr_id
        ,sysdate
        ,xla_environment_pkg.g_usr_id
        ,xla_environment_pkg.g_login_id
        --,'NONE'
        );
   END IF;
   CLOSE c_ledger_options;

   trace('< xla_acct_setup_pkg.insert_ledger_options'    , 10);
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   IF c_ledger_options%ISOPEN THEN
      CLOSE c_ledger_options;
   END IF;
   RAISE;
WHEN OTHERS                                   THEN
   IF c_ledger_options%ISOPEN THEN
      CLOSE c_ledger_options;
   END IF;
   xla_exceptions_pkg.raise_message
     (p_location   => 'xla_acct_setup_pkg.insert_ledger_options');
END insert_ledger_options;


--=============================================================================
--
-- Insert into je category
--
--=============================================================================
PROCEDURE insert_je_category
       (p_ledger_id                  IN NUMBER
       ,p_application_id             IN NUMBER
       ,p_event_class_code           IN VARCHAR2) IS
CURSOR csr_event_classes IS
   SELECT xeca.entity_code
         ,xeca.event_class_code
         ,xeca.je_category_name
     FROM xla_event_class_attrs   xeca
    WHERE xeca.application_id      = p_application_id
      AND xeca.event_class_code    = NVL(p_event_class_code,xeca.event_class_code)
      AND xeca.event_class_code    NOT IN
                  (SELECT event_class_code
                     FROM xla_je_categories    xjc
                    WHERE xjc.application_id   = p_application_id
                      AND xjc.ledger_id        = p_ledger_id);

BEGIN
   trace('> xla_acct_setup_pkg.insert_je_category'              , 10);
   trace('p_ledger_id             = '||p_ledger_id           , 20);
   trace('p_application_id        = '||p_application_id      , 20);
   trace('p_event_class_code      = '||p_event_class_code    , 20);

   FOR c1 IN csr_event_classes LOOP
      INSERT INTO xla_je_categories
        (application_id
        ,ledger_id
        ,entity_code
        ,event_class_code
        ,je_category_name
        ,creation_date
        ,created_by
        ,last_update_date
        ,last_updated_by
        ,last_update_login)
      VALUES
        (p_application_id
        ,p_ledger_id
        ,c1.entity_code
        ,c1.event_class_code
        ,c1.je_category_name
        ,sysdate
        ,xla_environment_pkg.g_usr_id
        ,sysdate
        ,xla_environment_pkg.g_usr_id
        ,xla_environment_pkg.g_login_id);
   END LOOP;

   trace('< xla_acct_setup_pkg.insert_je_category'              , 10);

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location   => 'xla_acct_setup_pkg.insert_je_category');
END insert_je_category;


--=============================================================================
--
-- Checks if the primary ledger options have been inserted for the application
--
--=============================================================================
PROCEDURE check_primary_ledger_options
       (p_primary_ledger_id          IN NUMBER
       ,p_application_id             IN NUMBER) IS
l_exist             VARCHAR2(1)   := null;
l_application_name  VARCHAR2(240) := null;
l_pr_ledger_name    VARCHAR2(30)  := null;
l_application_id    NUMBER(38);

CURSOR c_launch_options IS
   SELECT 'x'
     FROM xla_launch_options
    WHERE application_id   = p_application_id
      AND ledger_id        = p_primary_ledger_id;

BEGIN
   trace('> xla_acct_setup_pkg.check_primary_ledger_options'   , 10);
   trace('primary_ledger_id  = '||p_primary_ledger_id     , 20);
   trace('application_id     = '||p_application_id     , 20);

   l_application_id    := p_application_id;

   OPEN c_launch_options;
   FETCH c_launch_options INTO l_exist;
   IF c_launch_options%notfound THEN

      xla_validations_pkg.get_ledger_name
        (p_ledger_id    => p_primary_ledger_id
        ,p_ledger_name  => l_pr_ledger_name);

      xla_validations_pkg.get_application_name
        (p_application_id    => l_application_id
        ,p_application_name  => l_application_name);

      -------------------------------------------------------------------------
      -- Raise error
      -------------------------------------------------------------------------
      xla_exceptions_pkg.raise_message
        (p_appli_s_name  => 'XLA'
        ,p_msg_name      => 'XLA_SU_NO_PRIMARY_SETUP'
        ,p_token_1       => 'APPLICATION_NAME'
        ,p_value_1       => l_application_name);

   END IF;
   CLOSE c_launch_options;

   trace('< xla_acct_setup_pkg.check_primary_ledger_options'    , 10);

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   IF c_launch_options%ISOPEN THEN
      CLOSE c_launch_options;
   END IF;
   RAISE;
WHEN OTHERS                                   THEN
   IF c_launch_options%ISOPEN THEN
      CLOSE c_launch_options;
   END IF;
   xla_exceptions_pkg.raise_message
      (p_location   => 'xla_acct_setup_pkg.check_primary_ledger_options');
END check_primary_ledger_options;


--=============================================================================
--
-- Checks if the ledger currency is same as primary ledger currency
--
--=============================================================================
FUNCTION check_ledger_currency
       (p_primary_ledger_id          IN NUMBER
       ,p_ledger_id                  IN NUMBER
       ,p_application_id             IN NUMBER)
RETURN BOOLEAN IS

l_primary_ledger_id     NUMBER(38);
l_ledger_id             NUMBER(38);
l_application_id        NUMBER(38);
l_return                BOOLEAN;
l_pr_currency_code      VARCHAR2(15) := null;
l_currency_code         VARCHAR2(15) := null;

CURSOR c_ledger_currency(p_ledger_id  IN NUMBER) IS
   SELECT currency_code
     FROM xla_gl_ledgers_v
    WHERE ledger_id        = p_ledger_id;

BEGIN
   trace('> xla_acct_setup_pkg.check_ledger_currency'   , 10);
   trace('primary_ledger_id  = '||p_primary_ledger_id     , 20);
   trace('ledger_id  = '||p_ledger_id     , 20);

   l_primary_ledger_id     := p_primary_ledger_id;
   l_ledger_id             := p_ledger_id;
   l_application_id        := p_application_id;
   l_return                := FALSE;

   OPEN c_ledger_currency(p_ledger_id  => l_primary_ledger_id);
   FETCH c_ledger_currency INTO l_pr_currency_code;
   CLOSE c_ledger_currency;

   OPEN c_ledger_currency(p_ledger_id  => l_ledger_id);
   FETCH c_ledger_currency INTO l_currency_code;
   CLOSE c_ledger_currency;

   IF l_currency_code <> l_pr_currency_code THEN
      l_return := FALSE;
   ELSE
      l_return := TRUE;
   END IF;

   trace('< xla_acct_setup_pkg.check_ledger_currency'    , 10);

   RETURN l_return;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location   => 'xla_acct_setup_pkg.check_ledger_currency');
END check_ledger_currency;


--=============================================================================
--
--  Sets up ledger options for a subledger application and ledger
--
--=============================================================================

PROCEDURE setup_options
       (p_primary_ledger_id          IN NUMBER
       ,p_ledger_id                  IN NUMBER
       ,p_application_id             IN NUMBER
       ,p_valuation_method_flag      IN VARCHAR2
       ,p_event_class_code           IN VARCHAR2) IS
BEGIN
   trace('> xla_acct_setup_pkg.setup_options'                     , 10);
   trace('p_ledger_id          = '||p_ledger_id                , 20);
   trace('p_primary_ledger_id  = '||p_primary_ledger_id        , 20);
   trace('p_application_id     = '||p_application_id           , 20);

   ----------------------------------------------------------------------------
   -- The default value for g_capture_event_flag is changed to 'N' for
   -- secondary ledgers and standard applications.
   -- Add the ELSE clause to reset the value to its default in case it has
   -- been changed for the previous application.
   ----------------------------------------------------------------------------
   IF p_ledger_id <> p_primary_ledger_id  AND
      p_valuation_method_flag = 'N'
   THEN
      g_capture_event_flag := 'N';
   ELSE
      g_capture_event_flag := 'Y';
   END IF;

   ----------------------------------------------------------------------------
   -- Check if ledger is primary or secondary
   ----------------------------------------------------------------------------
   IF p_primary_ledger_id = p_ledger_id THEN
      -------------------------------------------------------------------------
      -- Ledger is primary, so insert into xla_launch_options
      -------------------------------------------------------------------------
      insert_launch_options
         (p_ledger_id        => p_ledger_id
         ,p_application_id   => p_application_id);

      -------------------------------------------------------------------------
      -- Insert into xla_ledger_options
      -------------------------------------------------------------------------
      insert_ledger_options
         (p_ledger_id        => p_ledger_id
         ,p_application_id   => p_application_id);

      -------------------------------------------------------------------------
      -- Insert into xla_je_categories
      -------------------------------------------------------------------------
      insert_je_category
         (p_ledger_id        => p_ledger_id
         ,p_application_id   => p_application_id
         ,p_event_class_code => p_event_class_code);
   ELSE
      -------------------------------------------------------------------------
      -- Ledger is secondary, check if primary ledger is inserted
      -------------------------------------------------------------------------
      check_primary_ledger_options
         (p_primary_ledger_id   => p_primary_ledger_id
         ,p_application_id      => p_application_id);

         IF p_valuation_method_flag = 'Y' THEN
            -------------------------------------------------------------------
            -- Consider secondary ledger as primary, insert into
            -- xla_launch_options
            -------------------------------------------------------------------
            insert_launch_options
               (p_ledger_id      => p_ledger_id
               ,p_application_id => p_application_id);
         END IF;

         ----------------------------------------------------------------------
         -- Insert into xla_ledger_options
         ----------------------------------------------------------------------
         insert_ledger_options
            (p_ledger_id        => p_ledger_id
            ,p_application_id   => p_application_id);

         ----------------------------------------------------------------------
         -- Insert into xla_je_categories
         ----------------------------------------------------------------------
         insert_je_category
            (p_ledger_id        => p_ledger_id
            ,p_application_id   => p_application_id
            ,p_event_class_code => p_event_class_code);
  END IF;


   trace('< xla_acct_setup_pkg.setup_options'    , 10);

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location   => 'xla_acct_setup_pkg.setup_options');
END setup_options;



--=============================================================================
--
--
--
--=============================================================================
PROCEDURE set_default_values IS
BEGIN
   trace('> xla_acct_setup_pkg.set_default_values'                   , 10);

   g_accounting_mode_code               := 'F';
   g_acctg_mode_override_flag           := 'Y';
   g_summary_report_flag                := 'N';
   g_summary_report_override_flag       := 'Y';
   g_submit_transfer_to_gl_flag         := 'Y';
   g_submit_xfer_override_flag          := 'Y';
   g_submit_gl_post_flag                := 'N';
   g_submit_gl_post_override_flag       := 'Y';
   g_capture_event_flag                 := 'Y';
   g_error_limit                        := NULL;

   ----------------------------------------------------------------------------
   -- The value for g_processes and g_processing_unit_size is initilaized to
   -- 1 and 1000 respectively. (Bug # 3259247)
   ----------------------------------------------------------------------------
   g_processes                          := 1;
   g_processing_unit_size               := 1000;

   ----------------------------------------------------------------------------
   -- g_transfer_to_gl_mode_code should be set to null here because its value
   -- is determined based on gl_ledgers.net_income_code_combination_id in the
   -- routine INSERT_LEDGER_OPTIONS.
   ----------------------------------------------------------------------------
   g_transfer_to_gl_mode_code           := NULL;
   g_acct_reversal_option_code          := 'SIDE';
   g_enabled_flag                       := 'Y';

   trace('< xla_acct_setup_pkg.set_default_values'                   , 10);
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location   => 'xla_acct_setup_pkg.set_default_values');
END set_default_values;



--=============================================================================
--
--
--
--=============================================================================
PROCEDURE upgrade_ledger_options
       (p_application_id                    IN NUMBER
       ,p_ledger_id                         IN NUMBER
       ,p_acct_mode_code                    IN VARCHAR2
       ,p_acct_mode_override_flag           IN VARCHAR2
       ,p_summary_report_flag               IN VARCHAR2
       ,p_summary_report_override_flag      IN VARCHAR2
       ,p_submit_xfer_to_gl_flag            IN VARCHAR2
       ,p_submit_xfer_override_flag         IN VARCHAR2
       ,p_submit_gl_post_flag               IN VARCHAR2
       ,p_submit_gl_post_override_flag      IN VARCHAR2
       ,p_stop_on_error                     IN VARCHAR2
       ,p_error_limit                       IN NUMBER
       ,p_processes                         IN NUMBER
       ,p_processing_unit_size              IN NUMBER
       ,p_transfer_to_gl_mode_code          IN VARCHAR2
       ,p_acct_reversal_option_code         IN VARCHAR2) IS
BEGIN
   trace('> xla_acct_setup_pkg.upgrade_ledger_options'   , 10);
   trace('ledger_id              = '||p_ledger_id     , 20);
   trace('p_application_id       = '||p_application_id     , 20);

   ----------------------------------------------------------------------------
   -- Validate parameters
   ----------------------------------------------------------------------------
   IF p_acct_mode_code IS NOT NULL AND p_acct_mode_code NOT IN ('D','F') THEN
      xla_exceptions_pkg.raise_message
         (p_appli_s_name  => 'XLA'
         ,p_msg_name      => 'XLA_COMMON_ERROR'
         ,p_token_1       => 'LOCATION'
         ,p_value_1       => 'upgrade_ledger_options'
         ,p_token_2       => 'ERROR'
         ,p_value_2       => 'The value '||p_acct_mode_code||' is invalid for p_acct_mode_code');
   END IF;

   IF (p_acct_mode_override_flag IS NOT NULL AND p_acct_mode_override_flag NOT IN ('Y','N'))
   THEN
      xla_exceptions_pkg.raise_message
         (p_appli_s_name  => 'XLA'
         ,p_msg_name      => 'XLA_COMMON_ERROR'
         ,p_token_1       => 'LOCATION'
         ,p_value_1       => 'upgrade_ledger_options'
         ,p_token_2       => 'ERROR'
         ,p_value_2       => 'The value '||p_acct_mode_override_flag||
                             ' is invalid for p_acct_mode_override_flag');
   END IF;

   IF p_summary_report_flag IS NOT NULL AND p_summary_report_flag NOT IN ('D','S','N') THEN
      xla_exceptions_pkg.raise_message
         (p_appli_s_name  => 'XLA'
         ,p_msg_name      => 'XLA_COMMON_ERROR'
         ,p_token_1       => 'LOCATION'
         ,p_value_1       => 'upgrade_ledger_options'
         ,p_token_2       => 'ERROR'
         ,p_value_2       => 'The value '||p_summary_report_flag||' is invalid for p_summary_report_flag');
   END IF;

   IF (p_summary_report_override_flag IS NOT NULL AND p_summary_report_override_flag NOT IN ('Y','N'))
   THEN
      xla_exceptions_pkg.raise_message
         (p_appli_s_name  => 'XLA'
         ,p_msg_name      => 'XLA_COMMON_ERROR'
         ,p_token_1       => 'LOCATION'
         ,p_value_1       => 'upgrade_ledger_options'
         ,p_token_2       => 'ERROR'
         ,p_value_2       => 'The value '||p_summary_report_override_flag||
                             ' is invalid for p_summary_report_override_flag');
   END IF;

   IF (p_submit_xfer_to_gl_flag IS NOT NULL AND p_submit_xfer_to_gl_flag NOT IN ('Y','N'))
   THEN
      xla_exceptions_pkg.raise_message
         (p_appli_s_name  => 'XLA'
         ,p_msg_name      => 'XLA_COMMON_ERROR'
         ,p_token_1       => 'LOCATION'
         ,p_value_1       => 'upgrade_ledger_options'
         ,p_token_2       => 'ERROR'
         ,p_value_2       => 'The value '||p_submit_xfer_to_gl_flag||
                             ' is invalid for p_submit_xfer_to_gl_flag');
   END IF;

   IF (p_submit_xfer_override_flag IS NOT NULL AND p_submit_xfer_override_flag NOT IN ('Y','N'))
   THEN
      xla_exceptions_pkg.raise_message
         (p_appli_s_name  => 'XLA'
         ,p_msg_name      => 'XLA_COMMON_ERROR'
         ,p_token_1       => 'LOCATION'
         ,p_value_1       => 'upgrade_ledger_options'
         ,p_token_2       => 'ERROR'
         ,p_value_2       => 'The value '||p_submit_xfer_override_flag||
                             ' is invalid for p_submit_xfer_override_flag');
   END IF;

   IF (p_submit_gl_post_flag IS NOT NULL AND p_submit_gl_post_flag NOT IN ('Y','N'))
   THEN
      xla_exceptions_pkg.raise_message
         (p_appli_s_name  => 'XLA'
         ,p_msg_name      => 'XLA_COMMON_ERROR'
         ,p_token_1       => 'LOCATION'
         ,p_value_1       => 'upgrade_ledger_options'
         ,p_token_2       => 'ERROR'
         ,p_value_2       => 'The value '||p_submit_gl_post_flag||
                             ' is invalid for p_submit_gl_post_flag');
   END IF;

   IF (p_submit_gl_post_override_flag IS NOT NULL AND p_submit_gl_post_override_flag NOT IN ('Y','N'))
   THEN
      xla_exceptions_pkg.raise_message
         (p_appli_s_name  => 'XLA'
         ,p_msg_name      => 'XLA_COMMON_ERROR'
         ,p_token_1       => 'LOCATION'
         ,p_value_1       => 'upgrade_ledger_options'
         ,p_token_2       => 'ERROR'
         ,p_value_2       => 'The value '||p_submit_gl_post_override_flag||
                             ' is invalid for p_submit_gl_post_override_flag');
   END IF;

   IF (p_stop_on_error IS NOT NULL AND p_stop_on_error NOT IN ('Y','N'))
   THEN
      xla_exceptions_pkg.raise_message
         (p_appli_s_name  => 'XLA'
         ,p_msg_name      => 'XLA_COMMON_ERROR'
         ,p_token_1       => 'LOCATION'
         ,p_value_1       => 'upgrade_ledger_options'
         ,p_token_2       => 'ERROR'
         ,p_value_2       => 'The value '||p_stop_on_error||' is invalid for p_stop_on_error');
   END IF;

   IF (p_stop_on_error = 'Y' AND (p_error_limit IS NULL OR p_error_limit < 1))
   THEN
      xla_exceptions_pkg.raise_message
         (p_appli_s_name  => 'XLA'
         ,p_msg_name      => 'XLA_COMMON_ERROR'
         ,p_token_1       => 'LOCATION'
         ,p_value_1       => 'upgrade_ledger_options'
         ,p_token_2       => 'ERROR'
         ,p_value_2       => 'With p_stop_on_error = Y, a positive integer value should be '||
                             'passed for p_error_limit');
   END IF;

   IF (p_stop_on_error = 'N' AND p_error_limit IS NOT NULL)
   THEN
      xla_exceptions_pkg.raise_message
         (p_appli_s_name  => 'XLA'
         ,p_msg_name      => 'XLA_COMMON_ERROR'
         ,p_token_1       => 'LOCATION'
         ,p_value_1       => 'upgrade_ledger_options'
         ,p_token_2       => 'ERROR'
         ,p_value_2       => 'With p_stop_on_error = N, a NULL value should be '||
                             'passed for p_error_limit');
   END IF;

   IF p_processes < 1 THEN
      xla_exceptions_pkg.raise_message
         (p_appli_s_name  => 'XLA'
         ,p_msg_name      => 'XLA_COMMON_ERROR'
         ,p_token_1       => 'LOCATION'
         ,p_value_1       => 'upgrade_ledger_options'
         ,p_token_2       => 'ERROR'
         ,p_value_2       => 'The value '||p_processes||' is invalid for p_processes');
   END IF;

   IF p_processing_unit_size < 1 THEN
      xla_exceptions_pkg.raise_message
         (p_appli_s_name  => 'XLA'
         ,p_msg_name      => 'XLA_COMMON_ERROR'
         ,p_token_1       => 'LOCATION'
         ,p_value_1       => 'upgrade_ledger_options'
         ,p_token_2       => 'ERROR'
         ,p_value_2       => 'The value '||p_processing_unit_size||' is invalid for p_processing_unit_size');
   END IF;

   IF (p_transfer_to_gl_mode_code IS NOT NULL AND p_transfer_to_gl_mode_code NOT IN ('A','D','P'))
   THEN
      xla_exceptions_pkg.raise_message
         (p_appli_s_name  => 'XLA'
         ,p_msg_name      => 'XLA_COMMON_ERROR'
         ,p_token_1       => 'LOCATION'
         ,p_value_1       => 'upgrade_ledger_options'
         ,p_token_2       => 'ERROR'
         ,p_value_2       => 'The value '||p_transfer_to_gl_mode_code||
                             ' is invalid for p_transfer_to_gl_mode_code');
   END IF;

   IF (p_acct_reversal_option_code IS NOT NULL AND p_acct_reversal_option_code NOT IN ('SIDE','SIGN'))
   THEN
      xla_exceptions_pkg.raise_message
         (p_appli_s_name  => 'XLA'
         ,p_msg_name      => 'XLA_COMMON_ERROR'
         ,p_token_1       => 'LOCATION'
         ,p_value_1       => 'upgrade_ledger_options'
         ,p_token_2       => 'ERROR'
         ,p_value_2       => 'The value '||p_acct_reversal_option_code||
                             ' is invalid for p_acct_reversal_option_code');
   END IF;

   ----------------------------------------------------------------------------
   -- Update launch options, if there is already launch options for the
   -- ledger and the application
   ----------------------------------------------------------------------------
   UPDATE xla_launch_options SET
      accounting_mode_code           = NVL(p_acct_mode_code, accounting_mode_code)
     ,accounting_mode_override_flag  = NVL(p_acct_mode_override_flag, accounting_mode_override_flag)
     ,summary_report_flag            = NVL(p_summary_report_flag, summary_report_flag)
     ,summary_report_override_flag   = NVL(p_summary_report_override_flag, summary_report_override_flag)
     ,submit_transfer_to_gl_flag     = NVL(p_submit_xfer_to_gl_flag, submit_transfer_to_gl_flag)
     ,submit_transfer_override_flag  = NVL(p_submit_xfer_override_flag, submit_transfer_override_flag)
     ,submit_gl_post_flag            = NVL(p_submit_gl_post_flag, submit_gl_post_flag)
     ,submit_gl_post_override_flag   = NVL(p_submit_gl_post_override_flag,submit_gl_post_override_flag)
     ,error_limit                    = DECODE(p_stop_on_error, null, error_limit, p_error_limit)
     ,processes                      = NVL(p_processes, processes)
     ,processing_unit_size           = NVL(p_processing_unit_size, processing_unit_size)
     ,last_update_date               = sysdate
     ,last_updated_by                = xla_environment_pkg.g_usr_id
     ,last_update_login              = xla_environment_pkg.g_login_id
   WHERE ledger_id = p_ledger_id
     AND application_id = p_application_id;

   ----------------------------------------------------------------------------
   -- Update ledger options, if there is already ledger options for the
   -- ledger and the application
   ----------------------------------------------------------------------------
   UPDATE xla_ledger_options SET
      transfer_to_gl_mode_code       = NVL(p_transfer_to_gl_mode_code, transfer_to_gl_mode_code)
     ,acct_reversal_option_code      = NVL(p_acct_reversal_option_code, acct_reversal_option_code)
     ,last_update_date               = sysdate
     ,last_updated_by                = xla_environment_pkg.g_usr_id
     ,last_update_login              = xla_environment_pkg.g_login_id
   WHERE ledger_id = p_ledger_id
     AND application_id = p_application_id;

   ----------------------------------------------------------------------------
   -- raise exception if no row in ledger opitons is updated. The reason:
   -- a.   invalid application or
   -- b.   invalid ledger
   ----------------------------------------------------------------------------
   IF SQL%ROWCOUNT = 0 THEN
      xla_exceptions_pkg.raise_message
         (p_appli_s_name  => 'XLA'
         ,p_msg_name      => 'XLA_COMMON_ERROR'
         ,p_token_1       => 'LOCATION'
         ,p_value_1       => 'upgrade_ledger_options'
         ,p_token_2       => 'ERROR'
         ,p_value_2       => 'Either the application is not registered or '||
                             'setups are missing for the ledger and application');
   END IF;

   trace('< xla_acct_setup_pkg.upgrade_ledger_options'    , 10);

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location   => 'xla_acct_setup_pkg.upgrade_ledger_options');
END upgrade_ledger_options;


--=============================================================================
--
--
--
--
--
--
--
--
--
--
-- Following gets executed when the package body is loaded first time
--
--
--
--
--
--
--
--
--
--
--
--
--
--=============================================================================
BEGIN
   g_debug_flag      := NVL(fnd_profile.value('XLA_DEBUG_TRACE'),'N');


END xla_acct_setup_pkg;

/
