--------------------------------------------------------
--  DDL for Package Body XLA_CONTROL_ACCOUNTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_CONTROL_ACCOUNTS_PKG" AS
/* $Header: xlabacta.pkb 120.13.12010000.2 2010/03/02 13:40:20 rajose ship $ */
/*======================================================================+
|             Copyright (c) 1995-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_control_accounts_pkg                                           |
|                                                                       |
| DESCRIPTION                                                           |
|    XLA Control Accounts Package                                       |
|                                                                       |
| HISTORY                                                               |
|    27-AUG-02 A. Quaglia     Created                                   |
|    15-NOV-02 A. Quaglia     'N' not allowed for balance_flags         |
|    03-DEC-02 A. Quaglia     update_balance_flag: decoupled update     |
|                             statements. Locking removed.              |
|    10-DEC-02 A. Quaglia     Overloaded update_balance_flag with       |
|                             p_event_id,p_entity_id,p_application_id   |
|    11-DEC-02 A. Quaglia     update_balance_flag added where condition |
|                             on accounting_entry_status_code and       |
|                             balance_type_code.                        |
|    12-DEC-02 A. Quaglia     update_balance_flag: added parameter      |
|                             p_application_id where missing, added     |
|                             NOT NULL check.                           |
|    27-MAY-03 A. Quaglia     replaced XLA_95100_COMMON_ERROR with      |
|                             XLA_COMMON_ERROR.                         |
|    05-MAR-04 A.Quaglia      Changed trace handling as per Sandeep's   |
|                             code.                                     |
|    25-MAR-04 A.Quaglia      Fixed debug changes issues:               |
|                               -Replaced global variable for trace     |
|                                with local one                         |
|                               -Fixed issue with SQL%ROWCOUNT which is |
|                                modified after calling debug proc      |
+======================================================================*/

--Generic Procedure/Function template
/*======================================================================+
|                                                                       |
| Private Function                                                      |
|                                                                       |
| Description                                                           |
| -----------                                                           |
|                                                                       |
|                                                                       |
| Pseudo-code                                                           |
| -----------                                                           |
|                                                                       |
|                                                                       |
| Open issues                                                           |
| -----------                                                           |
|                                                                       |
|                                                                       |
+======================================================================*/

   --
   -- Private exceptions
   --
   le_resource_busy                   EXCEPTION;
   PRAGMA exception_init(le_resource_busy, -00054);
   --
   -- Private constants
   --

   --
   -- Private variables
   --

   --
   -- Cursor declarations
   --

--=============================================================================
--               *********** Local Trace Routine **********
--=============================================================================
C_LEVEL_STATEMENT     CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
C_LEVEL_PROCEDURE     CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
C_LEVEL_EVENT         CONSTANT NUMBER := FND_LOG.LEVEL_EVENT;
C_LEVEL_EXCEPTION     CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
C_LEVEL_ERROR         CONSTANT NUMBER := FND_LOG.LEVEL_ERROR;
C_LEVEL_UNEXPECTED    CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;

C_LEVEL_LOG_DISABLED  CONSTANT NUMBER := 99;
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.xla_control_accounts_pkg';

g_log_level           NUMBER;
g_log_enabled         BOOLEAN;

--1-STATEMENT, 2-PROCEDURE, 3-EVENT, 4-EXCEPTION, 5-ERROR, 6-UNEXPECTED

PROCEDURE trace
       ( p_module                     IN VARCHAR2
        ,p_msg                        IN VARCHAR2
        ,p_level                      IN NUMBER
        ) IS
BEGIN
   IF (p_msg IS NULL AND p_level >= g_log_level) THEN
      fnd_log.message(p_level, p_module);
   ELSIF p_level >= g_log_level THEN
      fnd_log.string(p_level, p_module, p_msg);
   END IF;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
         (p_location   => 'xla_control_accounts_pkg.trace');
END trace;



FUNCTION is_control_account
  ( p_code_combination_id     IN INTEGER
   ,p_natural_account         IN VARCHAR2
   ,p_ledger_id               IN INTEGER
   ,p_application_id          IN INTEGER
  ) RETURN INTEGER
IS
l_qualifier_value      VARCHAR2(25);
l_je_source_name       VARCHAR2(30);
l_chart_of_accounts_id INTEGER;

l_log_module                 VARCHAR2 (2000);

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.is_control_account';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module   => l_log_module
         ,p_msg      => 'BEGIN ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         ( p_module => l_log_module
          ,p_msg   => 'p_code_combination_id :' ||  p_code_combination_id
          ,p_level => C_LEVEL_STATEMENT
         );
      trace
         ( p_module => l_log_module
          ,p_msg   => 'p_natural_account     :' ||  p_natural_account
          ,p_level => C_LEVEL_STATEMENT
         );
      trace
         ( p_module => l_log_module
          ,p_msg   => 'p_ledger_id           :' ||  p_ledger_id
          ,p_level => C_LEVEL_STATEMENT
         );
      trace
         ( p_module => l_log_module
          ,p_msg   => 'p_application_id      :' ||  p_application_id
          ,p_level => C_LEVEL_STATEMENT
         );
   END IF;

   IF  p_code_combination_id IS NOT NULL
   AND p_natural_account IS NULL
--   AND p_ledger_id IS NULL
   THEN
      BEGIN
         SELECT gcc.reference3
           INTO l_qualifier_value
           FROM gl_code_combinations gcc
          WHERE gcc.code_combination_id = p_code_combination_id;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
               trace
                  ( p_module => l_log_module
                   ,p_msg   => 'EXCEPTION: ' ||
'Code combination id '||p_code_combination_id ||
' not found. in the table gl_code_combinations'
                   ,p_level => C_LEVEL_EXCEPTION
            );
            END IF;
            xla_exceptions_pkg.raise_message
               ('XLA'
               ,'XLA_COMMON_ERROR'
               ,'ERROR'
               ,'Code combination id '||p_code_combination_id || ' not found.'
                || ' in the table gl_code_combinations'
               ,'LOCATION'
               ,'xla_control_accounts_pkg.is_control_account');
         WHEN OTHERS                                   THEN
            xla_exceptions_pkg.raise_message
               (p_location => 'xla_control_accounts_pkg.is_control_account');
      END;

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
            ( p_module => l_log_module
             ,p_msg   => 'Qualifier value: ' ||  l_qualifier_value
             ,p_level => C_LEVEL_STATEMENT
            );
      END IF;

      IF NVL(l_qualifier_value, 'N') = 'N'
         OR NVL(l_qualifier_value, 'N') = 'R' -- added condition for 8490178
      THEN
         IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
            trace
               ( p_module   => l_log_module
                ,p_msg      => 'END ' || l_log_module
                ,p_level    => C_LEVEL_PROCEDURE);
         END IF;
         RETURN C_NOT_CONTROL_ACCOUNT;
      END IF;
      IF p_application_id IS NOT NULL
      THEN
         BEGIN
            SELECT xsl.control_account_type_code
              INTO l_je_source_name
              FROM xla_subledgers xsl
             WHERE xsl.application_id = p_application_id;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
                  trace
                  ( p_module => l_log_module
                   ,p_msg   => 'EXCEPTION: ' ||
'Application id '|| p_application_id || ' not found.' ||
' in the table xla_subledgers'
                   ,p_level    => C_LEVEL_EXCEPTION
                  );
               END IF;
               xla_exceptions_pkg.raise_message
                  ('XLA'
                  ,'XLA_COMMON_ERROR'
                  ,'ERROR'
                  ,'Application id '||p_application_id || ' not found.'
                   || ' in the table xla_subledgers'
                  ,'LOCATION'
                  ,'xla_control_accounts_pkg.is_control_account');
            WHEN OTHERS                                   THEN
               xla_exceptions_pkg.raise_message
               (p_location => 'xla_control_accounts_pkg.is_control_account');
         END;

         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
            trace
               ( p_module => l_log_module
                ,p_msg   => 'Source name: ' ||  l_je_source_name
                ,p_level => C_LEVEL_STATEMENT
               );
         END IF;

         IF (l_qualifier_value = l_je_source_name
             OR (l_qualifier_value = 'Y' and nvl(l_je_source_name, 'N') <> 'N')
             or l_je_source_name = 'Y' )
         THEN
            IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
               trace
               ( p_module => l_log_module
                ,p_msg      => 'END ' || l_log_module
                ,p_level    => C_LEVEL_PROCEDURE);
            END IF;
            RETURN C_IS_CONTROL_ACCOUNT;
         ELSE
            IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
               trace
               ( p_module => l_log_module
                ,p_msg      => 'END ' || l_log_module
                ,p_level    => C_LEVEL_PROCEDURE);
            END IF;
            RETURN C_IS_CONTROL_ACCOUNT_OTHER_APP;
         END IF;
      ELSE --p_application_id IS NULL
         IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
            trace
               ( p_module => l_log_module
                ,p_msg      => 'END ' || l_log_module
                ,p_level    => C_LEVEL_PROCEDURE);
         END IF;
         RETURN C_IS_CONTROL_ACCOUNT;
      END IF;

   ELSIF p_natural_account IS NOT NULL
   AND   p_code_combination_id IS NULL
   THEN
     xla_exceptions_pkg.raise_message
               ('XLA'
               ,'XLA_COMMON_ERROR'
               ,'ERROR'
               ,'p_natural_account NOT NULL: functionality not implemented'
               ,'LOCATION'
               ,'xla_control_accounts_pkg.is_control_account');
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         ( p_module => l_log_module
          ,p_msg      => 'END ' || l_log_module
          ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_control_accounts_pkg.is_control_account');
END is_control_account;


FUNCTION update_balance_flag ( p_application_id IN INTEGER
                              ,p_ae_header_id   IN INTEGER
                              ,p_ae_line_num    IN INTEGER
                             )
RETURN BOOLEAN
IS
l_log_module                 VARCHAR2 (2000);

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.update_balance_flag';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         ( p_module => l_log_module
          ,p_msg      => 'BEGIN ' || l_log_module
          ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   IF p_application_id IS NULL
   OR p_ae_header_id   IS NULL
   THEN
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            ( p_module => l_log_module
             ,p_msg   => 'EXCEPTION' ||
               'The foll. params cannot be NULL:'
             ,p_level => C_LEVEL_EXCEPTION
            );
         trace
            ( p_module => l_log_module
             ,p_msg   => 'EXCEPTION' ||
               'p_application_id: ' || p_application_id
             ,p_level => C_LEVEL_EXCEPTION
            );
         trace
            ( p_module => l_log_module
             ,p_msg   => 'EXCEPTION' ||
               'p_ae_header_id  : ' || p_ae_header_id
             ,p_level => C_LEVEL_EXCEPTION
            );
      END IF;
      xla_exceptions_pkg.raise_message
            (p_location => 'xla_control_accounts_pkg.update_balance_flag');
   END IF;

   IF p_ae_line_num IS NULL
   THEN
      --WARNING: This is 1 of 3 similar update statements
      --         Ensure changes are propagated
      UPDATE xla_ae_lines xal
         SET xal.control_balance_flag    = C_CONTROL_BALANCE_FLAG_PENDING
       WHERE xal.ROWID IN
        (  SELECT ael.ROWID
             FROM xla_ae_headers       aeh
                 ,gl_ledgers           xgl
                 ,xla_subledgers       xsb
                 ,xla_ae_lines         ael
                 ,gl_code_combinations gcc
            WHERE aeh.ae_header_id                 =  p_ae_header_id
              AND aeh.application_id               =  p_application_id
              AND aeh.balance_type_code            =  'A'
              AND aeh.accounting_entry_status_code IN ('D', 'F')
              AND ael.ae_header_id                 =  aeh.ae_header_id
              AND ael.application_id               =  aeh.application_id
              AND ael.party_type_code              IS NOT NULL
              AND ael.party_id                     IS NOT NULL
              AND ael.control_balance_flag         IS NULL
              AND xgl.ledger_id                    =  aeh.ledger_id
              AND xsb.application_id               =  aeh.application_id
              AND nvl(xsb.control_account_type_code, 'N') <>  'N'
              AND gcc.chart_of_accounts_id         =  xgl.chart_of_accounts_id
              AND gcc.code_combination_id          =  ael.code_combination_id
              AND gcc.reference3                   =  xsb.control_account_type_code
         );
   ELSE
      --WARNING: This is 2 of 3 similar update statements
      --         Ensure changes are propagated
      UPDATE xla_ae_lines xal
         SET xal.control_balance_flag    = C_CONTROL_BALANCE_FLAG_PENDING
       WHERE xal.ROWID IN
        (  SELECT ael.ROWID
             FROM xla_ae_headers       aeh
                 ,gl_ledgers     xgl
                 ,xla_subledgers       xsb
                 ,xla_ae_lines         ael
                 ,gl_code_combinations gcc
            WHERE aeh.ae_header_id                 =  p_ae_header_id
              AND aeh.application_id               =  p_application_id
              AND aeh.balance_type_code            =  'A'
              AND aeh.accounting_entry_status_code IN ('D', 'F')
              AND ael.ae_header_id                 =  aeh.ae_header_id
              AND ael.application_id               =  aeh.application_id
              AND ael.ae_line_num                  =  p_ae_line_num
              AND ael.party_type_code              IS NOT NULL
              AND ael.party_id                     IS NOT NULL
              AND ael.control_balance_flag         IS NULL
              AND xgl.ledger_id                    =  aeh.ledger_id
              AND xsb.application_id               =  aeh.application_id
              AND nvl(xsb.control_account_type_code, 'N') <>  'N'
              AND gcc.chart_of_accounts_id         =  xgl.chart_of_accounts_id
              AND gcc.code_combination_id          =  ael.code_combination_id
              AND gcc.reference3                   =  xsb.control_account_type_code
         );
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         ( p_module => l_log_module
          ,p_msg      => 'END ' || l_log_module
          ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   RETURN TRUE;

EXCEPTION

WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_control_accounts_pkg.update_balance_flag');
END update_balance_flag;


FUNCTION update_balance_flag ( p_event_id        IN INTEGER
                              ,p_entity_id       IN INTEGER
                              ,p_application_id  IN INTEGER
                             )
RETURN BOOLEAN
IS
l_log_module                 VARCHAR2 (2000);

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.update_balance_flag';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         ( p_module => l_log_module
          ,p_msg      => 'BEGIN ' || l_log_module
          ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   IF p_event_id       IS NULL
   OR p_entity_id      IS NULL
   OR p_application_id IS NULL
   THEN
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            ( p_module => l_log_module
             ,p_msg   => 'EXCEPTION' ||
               'The foll. params cannot be NULL:'
             ,p_level => C_LEVEL_EXCEPTION
            );
         trace
            ( p_module => l_log_module
             ,p_msg   => 'EXCEPTION' ||
               'p_event_id      : ' || p_event_id
             ,p_level => C_LEVEL_EXCEPTION
            );
         trace
            ( p_module => l_log_module
             ,p_msg   => 'EXCEPTION' ||
               'p_entity_id     : ' || p_entity_id
             ,p_level => C_LEVEL_EXCEPTION
            );
         trace
            ( p_module => l_log_module
             ,p_msg   => 'EXCEPTION' ||
               'p_application_id: ' || p_application_id
             ,p_level => C_LEVEL_EXCEPTION
            );
      END IF;
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_control_accounts_pkg.update_balance_flag');
   END IF;

   --WARNING: This is 3 of 3 similar update statements
   --         Ensure changes are propagated
   UPDATE xla_ae_lines xal
      SET xal.control_balance_flag    = C_CONTROL_BALANCE_FLAG_PENDING
    WHERE xal.ROWID IN
        (  SELECT ael.ROWID
             FROM xla_ae_headers       aeh
                 ,gl_ledgers     xgl
                 ,xla_subledgers       xsb
                 ,xla_ae_lines         ael
                 ,gl_code_combinations gcc
            WHERE aeh.event_id                     =  p_event_id
              AND aeh.entity_id                    =  p_entity_id
              AND aeh.application_id               =  p_application_id
              AND aeh.balance_type_code            =  'A'
              AND aeh.accounting_entry_status_code IN ('D', 'F')
              AND ael.ae_header_id                 =  aeh.ae_header_id
              AND ael.application_id               =  aeh.application_id
              AND ael.party_type_code              IS NOT NULL
              AND ael.party_id                     IS NOT NULL
              AND ael.control_balance_flag         IS NULL
              AND xgl.ledger_id                    =  aeh.ledger_id
              AND xsb.application_id               =  aeh.application_id
              AND nvl(xsb.control_account_type_code, 'N') <>  'N'
              AND gcc.code_combination_id          =  ael.code_combination_id
              AND gcc.reference3                   =  xsb.control_account_type_code
         );

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         ( p_module => l_log_module
          ,p_msg      => 'END ' || l_log_module
          ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   RETURN TRUE;

EXCEPTION

WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_control_accounts_pkg.update_balance_flag');
END update_balance_flag;

BEGIN
   g_log_level      := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   g_log_enabled    := fnd_log.test
                          (log_level  => g_log_level
                          ,module     => C_DEFAULT_MODULE);

   IF NOT g_log_enabled  THEN
      g_log_level := C_LEVEL_LOG_DISABLED;
   END IF;

END xla_control_accounts_pkg;

/
