--------------------------------------------------------
--  DDL for Package Body XLA_PERIOD_CLOSE_EXP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_PERIOD_CLOSE_EXP_PKG" AS
-- $Header: xlarppcl.pkb 120.38.12010000.6 2009/08/07 04:29:26 karamakr ship $
/*===========================================================================+
|  Copyright (c) 2003 Oracle Corporation Belmont, California, USA            |
|                          ALL rights reserved.                              |
+============================================================================+
| FILENAME                                                                   |
|    xlarppcl.pkb                                                            |
|                                                                            |
| PACKAGE NAME                                                               |
|     xla_period_close_exp_pkg                                               |
|                                                                            |
| DESCRIPTION                                                                |
| This package generates an XML extract for the Period Close Validation      |
| program unit. A dynamic query is created based on the parameters that are  |
| input and the data template is used to generate XML. The extract is        |
| called either when the user submits a concurrent request or when a General |
| Ledger Period is closed.                                                   |
|                                                                            |
| HISTORY                                                                    |
|     26/07/2005  VS Koushik            Created                              |
|     15/02/2006  VamsiKrishna Kasina   Changed the package to use           |
|                                       Data Template.                       |
|     7/12/2007   ssawhney              6613827, perf fix changed NOT IN     |
|                                       to IN in C_EVENTS_WO_AAD             |
|     7/2/2008    vkasina               removed the event_date filter in     |
|                                       C_EVENTS_WO_AAD                      |
|     08/02/2008  sasingha              bug 6805286:                         |
|                                          STAMP_EVENTS_WO_AAD is more needed|
|                                          and call to it are removed.       |
|     24/04/2008  schodava              bug 6981926:                         |
|                                          Perf fix, added hint of index in  |
|                                          procedure get_transaction_id      |
+===========================================================================*/

TYPE t_rec IS RECORD
    (f1               VARCHAR2(80)
    ,f2               VARCHAR2(80));
TYPE t_array IS TABLE OF t_rec INDEX BY BINARY_INTEGER;

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
   C_DEFAULT_MODULE      CONSTANT VARCHAR2(240)
                         := 'xla.plsql.xla_period_close_exp_pkg';

   g_log_level           NUMBER;
   g_log_enabled         BOOLEAN;
   g_use_ledger_security VARCHAR2(1) :=
                         nvl(fnd_profile.value('XLA_USE_LEDGER_SECURITY'), 'N');
   g_access_set_id       PLS_INTEGER := fnd_profile.value('GL_ACCESS_SET_ID');
   g_sec_access_set_id   PLS_INTEGER :=
                         fnd_profile.value('XLA_GL_SECONDARY_ACCESS_SET_ID');

   PROCEDURE  param_list_sql
      (p_application_id                  IN  NUMBER
      ,p_ledger_id                       IN  NUMBER
      ,p_object_type_code                OUT NOCOPY VARCHAR2
      ,p_je_source_name                  OUT NOCOPY VARCHAR2);

   PROCEDURE build_query_sql
      (p_application_id                  IN NUMBER
      ,p_ledger_id                       IN NUMBER
      ,p_period_from                     IN VARCHAR2
      ,p_period_to                       IN VARCHAR2
      ,p_event_class                     IN VARCHAR2
      ,p_je_category                     IN VARCHAR2
      ,p_object_type_code                IN VARCHAR2
      ,p_je_source_name                  IN VARCHAR2
      ,p_mode                            IN VARCHAR2);

   PROCEDURE trace
       (p_msg                        IN VARCHAR2
       ,p_level                      IN NUMBER
       ,p_module                     IN VARCHAR2) IS
   BEGIN
      IF (p_msg IS NULL AND p_level >= g_log_level) THEN
         fnd_log.message(p_level, NVL(p_module,C_DEFAULT_MODULE));
      ELSIF p_level >= g_log_level THEN
         fnd_log.string(p_level, NVL(p_module,C_DEFAULT_MODULE), p_msg);
      END IF;

   EXCEPTION
      WHEN xla_exceptions_pkg.application_exception THEN
         RAISE;
      WHEN OTHERS THEN
         xla_exceptions_pkg.raise_message
            (p_location   => 'xla_period_close_exp_pkg.trace');
   END trace;

--=============================================================================
--          *********** public procedures and functions **********
--=============================================================================
--    1.  run_report
--=============================================================================
   PROCEDURE RUN_REPORT
       (p_errbuf                          OUT NOCOPY VARCHAR2
       ,p_retcode                         OUT NOCOPY NUMBER
       ,p_application_id                  IN NUMBER
       ,p_ledger_id                       IN NUMBER
       ,p_period_from                     IN VARCHAR2
       ,p_period_to                       IN VARCHAR2
       ,p_event_class                     IN VARCHAR2
       ,p_je_category                     IN VARCHAR2
       ,p_mode                            IN VARCHAR2) IS

        l_log_module                    VARCHAR2(240);

        l_object_type_code              gl_ledgers.object_type_code%TYPE;
        l_je_source_name                gl_je_sources.je_source_name%TYPE;

   BEGIN
      IF g_log_enabled THEN
         l_log_module := C_DEFAULT_MODULE||'.run_report';
      END IF;

      IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
         trace('run_report.Begin',C_LEVEL_PROCEDURE,l_log_module);
      END IF;

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace('p_application_id = '|| to_char(p_application_id),
               C_LEVEL_STATEMENT, l_log_module);
         trace('p_ledger_id = '|| to_char(p_ledger_id),
               C_LEVEL_STATEMENT, l_log_module);
         trace('p_period_from = '|| p_period_from,
               C_LEVEL_STATEMENT,l_log_module);
         trace('p_period_to = '|| p_period_to,
               C_LEVEL_STATEMENT, l_log_module);
         trace('p_mode      = '|| p_mode,
               C_LEVEL_STATEMENT, l_log_module);
         trace('p_event_class      = '|| p_event_class,
               C_LEVEL_STATEMENT, l_log_module);
         trace('p_je_category      = '|| p_je_category,
               C_LEVEL_STATEMENT, l_log_module);
      END IF;

   ----------------------------------------------------------------------------
   -- Following sets the Security Context for the execution. This enables the
   -- event API to respect the transaction security implementation
   ----------------------------------------------------------------------------

   IF p_application_id = 101 THEN
      xla_security_pkg.set_security_context(602);
   ELSE
      xla_security_pkg.set_security_context(p_application_id);
   END IF;

      param_list_sql
         (p_application_id                  => p_application_id
         ,p_ledger_id                       => p_ledger_id
         ,p_object_type_code                => l_object_type_code
         ,p_je_source_name                  => l_je_source_name);

       build_query_sql
         (p_application_id                  => p_application_id
         ,p_ledger_id                       => p_ledger_id
         ,p_period_from                     => p_period_from
         ,p_period_to                       => p_period_to
         ,p_event_class                     => p_event_class
         ,p_je_category                     => p_je_category
         ,p_object_type_code                => l_object_type_code
         ,p_je_source_name                  => l_je_source_name
         ,p_mode                            => p_mode);

      IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
         trace('run_report.End',C_LEVEL_PROCEDURE,l_Log_module);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN

         xla_exceptions_pkg.raise_message
            (p_location       => 'xla_period_close_exp_pkg.run_report ');
   END run_report;


--------------------------------------------------------------------
-- The following is procedure is actually no more needed and
-- can be removed.
-- There is no call to this procedure and this change is
-- made as part of bug fix 6805286
--------------------------------------------------------------------
   PROCEDURE stamp_events_wo_aad
        (p_application_id IN NUMBER
        ,p_ledger_id      IN VARCHAR2 -- 4949921
        ,p_start_date     IN DATE
        ,p_end_date       IN DATE) IS

   l_set                NUMBER;
   l_return_status      VARCHAR2(10);
   l_log_module         VARCHAR2(240);
   l_stamp_query        VARCHAR2(32000);
   l_percl_query        VARCHAR2(10000);
   l_filters            VARCHAR2(1000);
   l_application_id     xla_events.application_id%TYPE;

   C_EVENTS_WO_AAD CONSTANT VARCHAR2(10000) :=
'   UPDATE xla_events xle
      SET xle.event_status_code = ''P''
         ,xle.process_status_code = ''P''
         ,xle.last_update_date = sysdate
         ,xle.last_updated_by = fnd_global.user_id
         ,xle.last_update_login = fnd_global.login_id
         ,xle.program_id = fnd_global.conc_program_id
         ,xle.request_id = nvl(fnd_global.conc_request_id,0)
         ,xle.program_application_id = fnd_global.prog_appl_id
    WHERE event_type_code NOT IN (''MANUAL'',''REVERSAL'') --FSAH-PSFT FP
      AND event_type_code in
        (SELECT xetb.event_type_code
           FROM gl_ledgers glg,
                xla_acctg_methods_b xam,
                xla_acctg_method_rules xamr,
                xla_prod_acct_headers xpah,
                xla_event_types_b xetb
          WHERE glg.sla_accounting_method_code = xam.accounting_method_code
            AND glg.sla_accounting_method_type = xam.accounting_method_type_code
            AND xam.accounting_method_code     = xamr.accounting_method_code
            AND xam.accounting_method_type_code =
                xamr.accounting_method_type_code
            AND xamr.application_id            = xle.application_id
            AND xetb.application_id            = xpah.application_id
            AND xetb.entity_code               = xpah.entity_code
            AND xetb.event_class_code          = xpah.event_class_code
            AND (substr(xpah.event_type_code,-4) = ''_ALL''
                 OR xetb.event_type_code       = xpah.event_type_code)
            AND (NVL(xam.enabled_flag,''N'') <> ''Y''
--                 OR xle.event_date < xamr.start_date_active
--                 OR xle.event_date >  xamr.end_date_active
                 OR NVL(xpah.accounting_required_flag,''N'') <> ''Y'')
            AND xpah.application_id = xamr.application_id
            AND xpah.product_rule_type_code = xamr.product_rule_type_code
            AND xpah.product_rule_code = xamr.product_rule_code
            AND xpah.amb_context_code = xamr.amb_context_code
            AND xpah.amb_context_code =
                NVL(xla_profiles_pkg.get_value(''XLA_AMB_CONTEXT''),''DEFAULT'')
            AND glg.ledger_id IN ($ledger_ids$))
      AND   xle.event_status_code IN ( ''U'',''I'')
      AND   xle.process_status_code IN (''I'',''U'',''R'',''D'',''E'')
      AND   $filters$';
-- For 6613827 changed the NOT IN from P,N to IN U and I.
-- For 6784591 added process_status_code filter.

   BEGIN

   IF g_log_enabled THEN
     l_log_module := C_DEFAULT_MODULE||'.stamp_events_wo_aad';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
        trace
           ( p_msg      => 'BEGIN of procedure stamp_events_wo_aad'
            ,p_level    => C_LEVEL_PROCEDURE
            ,p_module   => l_log_module);
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace('p_application_id = '       ||
         to_char(p_application_id), C_LEVEL_STATEMENT, l_log_module);
      trace('p_ledger_id = '||
         p_ledger_id, C_LEVEL_STATEMENT, l_log_module);
      trace('p_start_date = '||
         to_char(p_start_date,'DD-MON-YYYY'), C_LEVEL_STATEMENT, l_log_module);
      trace('p_end_date = '||
         to_char(p_end_date,'DD-MON-YYYY'), C_LEVEL_STATEMENT, l_log_module);
   END IF;

   l_percl_query := C_EVENTS_WO_AAD;

   l_filters :=  'xle.event_date between '''|| p_start_date ||''' and '''
                 || p_end_date||'''';

   IF p_application_id <> 101 then
        l_filters := l_filters || ' AND   xle.application_id = '
                || p_application_id;
   END IF;

   l_percl_query := REPLACE(l_percl_query, '$ledger_ids$',p_ledger_id);
   l_percl_query := REPLACE(l_percl_query, '$filters$', l_filters);

    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
        trace
           ( p_msg      => 'l_percl_query'||l_percl_query
            ,p_level    => C_LEVEL_PROCEDURE
            ,p_module   => l_log_module);
   END IF;

   EXECUTE IMMEDIATE l_percl_query;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
        trace
           ( p_msg      => 'Number of events updated'||SQL%ROWCOUNT
            ,p_level    => C_LEVEL_PROCEDURE
            ,p_module   => l_log_module);
   END IF;

   EXCEPTION
       WHEN NO_DATA_FOUND THEN
          NULL;
       WHEN xla_exceptions_pkg.application_exception THEN
          IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
             trace( p_msg      => 'End of procedure stamp_events_wo_aad'
                   ,p_level    => C_LEVEL_PROCEDURE
                   ,p_module   => l_log_module);
          END IF;
       RAISE;
   END stamp_events_wo_aad;



   PROCEDURE param_list_sql
      (p_application_id                  IN  NUMBER
      ,p_ledger_id                       IN  NUMBER
      ,p_object_type_code                OUT NOCOPY VARCHAR2
      ,p_je_source_name                  OUT NOCOPY VARCHAR2) IS

      l_log_module               VARCHAR2(240);
   BEGIN

      IF g_log_enabled THEN
         l_log_module := C_DEFAULT_MODULE||'.param_list_sql';
      END IF;
      IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
         trace('param_list_sql.Begin',C_LEVEL_PROCEDURE,l_Log_module);
      END IF;

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace('p_application_id = '|| to_char(p_application_id),
                C_LEVEL_STATEMENT,l_log_module);
         trace('p_ledger_id = '|| to_char(p_ledger_id),
                C_LEVEL_STATEMENT,l_log_module);
      END IF;

     --
     -- Getting Translated value for all ID and codes
     --

      p_object_type_code := xla_report_utility_pkg.
                       get_ledger_object_type(p_ledger_id);

      IF p_application_id = 101 THEN
          p_je_source_name := NULL;
      ELSE
         SELECT gjst.je_source_name
           INTO p_je_source_name
           FROM xla_subledgers xls, gl_je_sources_tl gjst
          WHERE xls.application_id = p_application_id
            AND xls.je_source_name = gjst.je_source_name
            AND gjst.language = USERENV('LANG');
      END IF;

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace('p_object_type_code = '|| p_object_type_code,
                C_LEVEL_STATEMENT,l_log_module);
         trace('p_je_source_name = '|| p_je_source_name,
                C_LEVEL_STATEMENT,l_log_module);
      END IF;


      IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
         trace('param_list_sql.End',C_LEVEL_PROCEDURE,l_Log_module);
      END IF;

   EXCEPTION
      WHEN OTHERS THEN
         -- trace mesg
         xla_exceptions_pkg.raise_message
           (p_location       => 'xla_period_close_exp_pkg.param_list_sql');
   END param_list_sql;

  PROCEDURE get_period_start_end_dates
     ( p_ledger_id      IN  NUMBER
      ,p_period_from    IN  VARCHAR2
      ,p_period_to      IN  VARCHAR2
      ,p_start_date     OUT NOCOPY  DATE
      ,p_end_date       OUT NOCOPY  DATE ) IS

  l_log_module VARCHAR2(240);
  gl_appl_id   NUMBER := 101;

  BEGIN

    IF g_log_enabled THEN
         l_log_module := C_DEFAULT_MODULE||'.get_period_start_end_dates';
    END IF;

    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
         trace('get_period_start_end_dates.Begin'
               ,C_LEVEL_PROCEDURE, l_log_module);
    END IF;

    IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace('p_ledger_id = '|| to_char(p_ledger_id),
                C_LEVEL_STATEMENT,l_log_module);
         trace('p_period_from = '|| p_period_from,
                C_LEVEL_STATEMENT,l_log_module);
         trace('p_period_to = '|| p_period_to,
                C_LEVEL_STATEMENT,l_log_module);
    END IF;

    SELECT start_date, end_date
        INTO p_start_date, p_end_date
        FROM gl_period_statuses glp
       WHERE glp.period_name     = p_period_from
        AND  glp.ledger_id       = p_ledger_id
        AND  glp.adjustment_period_flag = 'N'
        AND  glp.application_id = gl_appl_id ;

    IF p_period_from <> p_period_to THEN
       SELECT end_date
         INTO p_end_date
         FROM gl_period_statuses glp
        WHERE glp.period_name     = p_period_to
          AND glp.ledger_id       = p_ledger_id
          AND glp.adjustment_period_flag = 'N'
          AND glp.application_id = gl_appl_id ;
    END IF;

    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
         trace('get_period_start_end_dates.End'
               ,C_LEVEL_PROCEDURE, l_log_module);
    END IF;

  EXCEPTION
  WHEN OTHERS THEN
    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
         trace('get_period_start_end_dates.End with Error'
               ,C_LEVEL_PROCEDURE, l_log_module);
    END IF;
     xla_exceptions_pkg.raise_message
           (p_location       =>
                'xla_period_close_exp_pkg.get_period_start_end_dates');
  END get_period_start_end_dates ;


PROCEDURE build_xml_sql IS
    l_log_module VARCHAR2(240);
BEGIN

    IF g_log_enabled THEN
         l_log_module := C_DEFAULT_MODULE||'.build_xml_sql';
    END IF;

    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
         trace('build_xml_sql.Begin'
               ,C_LEVEL_PROCEDURE, l_log_module);
    END IF;

C_EVENTS_COLS_QUERY :=
   ' SELECT ent.ledger_id                                 LEDGER_ID
           ,gld.short_name                                LEDGER_SHORT_NAME
           ,gld.name                                      LEDGER_NAME
           ,gld.description                               LEDGER_DESCRIPTION
           ,gld.currency_code                             LEDGER_CURRENCY
           ,gps.period_year                               PERIOD_YEAR
           ,gps.period_num                                PERIOD_NUMBER
           ,gps.period_name                               PERIOD_NAME
           ,xle.application_id                            APPLICATION_ID
           ,gjt.je_source_name                            JOURNAL_SOURCE
           ,gjt.user_je_source_name                       USER_JE_SOURCE
           ,xcl.event_class_code                          EVENT_CLASS_CODE
           ,xcl.name                                      EVENT_CLASS_NAME
           ,gjct.je_category_name                         JOURNAL_CATEGORY_NAME
           ,gjct.user_je_category_name                    USER_JE_CATEGORY_NAME
           ,to_char(xle.event_date,''YYYY-MM-DD'')        EVENT_DATE
           ,xle.event_id                                  EVENT_ID
           ,xle.event_number                              EVENT_NUMBER
           ,fnu.user_id                                   CREATED_BY
           ,fnu.user_name                                 USER_NAME
           ,to_char(xle.last_update_date,''YYYY-MM-DD'')  LAST_UPDATE_DATE
           ,to_char(xle.creation_date,''YYYY-MM-DD'')     CREATION_DATE
           ,ent.transaction_number                        TRANSACTION_NUMBER
           ,to_char(xle.transaction_date,''YYYY-MM-DD'')  TRANSACTION_DATE
           ,xle.on_hold_flag                              ON_HOLD_FLAG
           ,xlo2.meaning                                  ON_HOLD
           ,xtt.event_type_code                           EVENT_TYPE_CODE
           ,xtt.name                                      EVENT_TYPE_NAME
           ,NULL                                          BALANCE_TYPE_CODE
           ,NULL                                          BALANCE_TYPE
           ,xlo1.meaning                                  PRINT_STATUS ';

C_EVENTS_FROM_QUERY :=
    ' FROM XLA_EVENTS                          XLE
          ,XLA_TRANSACTION_ENTITIES            ENT
          ,XLA_SUBLEDGERS                      XLS
          ,FND_USER                            FNU
          ,GL_PERIOD_STATUSES                  GPS
          ,GL_LEDGERS                          GLD
          ,GL_JE_SOURCES_TL                    GJT
          ,GL_JE_CATEGORIES_TL                 GJCT
          ,XLA_EVENT_CLASSES_TL                XCL
          ,XLA_EVENT_TYPES_B                   XET
          ,XLA_EVENT_TYPES_TL                  XTT
          ,XLA_EVENT_CLASS_ATTRS               XECA
          ,XLA_LOOKUPS                         XLO1
          ,XLA_LOOKUPS                         XLO2
          ,XLA_LEDGER_OPTIONS                  XLP
     WHERE xls.application_id                   = xle.application_id
       AND xle.event_status_code                IN (''I'',''U'')
       AND xle.process_status_code              IN (''U'',''D'',''E'',''R'',''I'')
       AND xle.entity_id                        = ent.entity_id
       AND ent.application_id                   = xle.application_id
       AND ent.ledger_id                        = gps.ledger_id
       AND gps.application_id                   = 101
       AND xle.event_date BETWEEN gps.start_date AND gps.end_date
       AND gps.adjustment_period_flag           <> ''Y''  -- Added by krsankar for bug 8212297
       AND gld.ledger_id                        = ent.ledger_id
       AND gjt.je_source_name                   = xls.je_source_name
       AND gjt.LANGUAGE                         = USERENV(''LANG'')
       AND fnu.user_id                          = xle.created_by
       AND xet.application_id                   = xle.application_id
       AND xet.event_type_code                  = xle.event_type_code
       AND xtt.application_id                   = xet.application_id
       AND xtt.event_type_code                  = xet.event_type_code
       AND xtt.event_class_code                 = xet.event_class_code
       AND xtt.entity_code                      = xet.entity_code
       AND xtt.LANGUAGE                         = USERENV(''LANG'')
       AND xcl.application_id                   = xet.application_id
       AND xcl.entity_code                      = xet.entity_code
       AND xcl.event_class_code                 = xet.event_class_code
       AND xcl.application_id                   = ent.application_id
       AND xcl.entity_code                      = ent.entity_code
       AND xcl.LANGUAGE                         = USERENV(''LANG'')
       AND xeca.application_id                  = xcl.application_id
       AND xeca.entity_code                     = xcl.entity_code
       AND xeca.event_class_code                = xcl.event_class_code
       AND xeca.je_category_name                = gjct.je_category_name
       AND gjct.language                        = USERENV(''LANG'')
       AND xlo1.lookup_type                     = ''XLA_EVENT_STATUS''
       AND xlo1.lookup_code                     = xle.event_status_code
       AND xlo2.lookup_type                     = ''XLA_YES_NO''
       AND xlo2.lookup_code                     = xle.on_hold_flag
       AND ent.ledger_id                        = xlp.ledger_id
       AND ent.application_id                   = xlp.application_id
       AND xlp.capture_event_flag               = ''Y''
       AND NOT EXISTS (SELECT aeh.event_id
                         FROM XLA_AE_HEADERS aeh
                        WHERE aeh.application_id = xle.application_id
                          AND aeh.event_id       = xle.event_id
                       )
       AND ent.ledger_id                        IN ';

C_HEADERS_COLS_QUERY :=
' SELECT  /*+ leading(aeh) */ aeh.ledger_id           LEDGER_ID
        ,gld.short_name                                LEDGER_SHORT_NAME
        ,gld.name                                      LEDGER_NAME
        ,gld.description                               LEDGER_DESCRIPTION
        ,gld.currency_code                             LEDGER_CURRENCY
        ,gps.period_year                               PERIOD_YEAR
        ,gps.period_num                                PERIOD_NUMBER
        ,gps.period_name                               PERIOD_NAME
        ,xle.application_id                            APPLICATION_ID
        ,gjt.je_source_name                            JOURNAL_SOURCE
        ,gjt.user_je_source_name                       USER_JE_SOURCE
        ,xcl.event_class_code                          EVENT_CLASS_CODE
        ,xcl.name                                      EVENT_CLASS_NAME
        ,gjct.je_category_name                         JOURNAL_CATEGORY_NAME
        ,gjct.user_je_category_name                    USER_JE_CATEGORY_NAME
        ,to_char(aeh.accounting_date,''YYYY-MM-DD'')   EVENT_DATE
        ,xle.event_id                                  EVENT_ID
        ,xle.event_number                              EVENT_NUMBER
        ,fnu.user_id                                   CREATED_BY
        ,fnu.user_name                                 USER_NAME
        ,to_char(aeh.last_update_date,''YYYY-MM-DD'')  LAST_UPDATE_DATE
        ,to_char(aeh.creation_date,''YYYY-MM-DD'')     CREATION_DATE
        ,ent.transaction_number                        TRANSACTION_NUMBER
        ,to_char(xle.transaction_date,''YYYY-MM-DD'')  TRANSACTION_DATE
        ,xle.on_hold_flag                              ON_HOLD_FLAG
        ,xlo2.meaning                                  ON_HOLD
        ,xet.event_type_code                           EVENT_TYPE_CODE
        ,xtt.name                                      EVENT_TYPE_NAME
        ,aeh.balance_type_code                         BALANCE_TYPE_CODE
        ,xlo5.meaning                                  BALANCE_TYPE
        ,xlo4.meaning                                  PRINT_STATUS ';

C_HEADERS_FROM_QUERY :=
  ' FROM  XLA_AE_HEADERS                     AEH
         ,XLA_EVENTS                         XLE
         ,XLA_TRANSACTION_ENTITIES           ENT
         ,XLA_SUBLEDGERS                     XLS
         ,FND_USER                           FNU
         ,GL_PERIOD_STATUSES                 GPS
         ,GL_LEDGERS                         GLD
         ,GL_JE_SOURCES_TL                   GJT
         ,GL_JE_CATEGORIES_TL                GJCT
         ,XLA_EVENT_TYPES_B                  XET
         ,XLA_EVENT_TYPES_TL                 XTT
         ,XLA_EVENT_CLASSES_TL               XCL
         ,XLA_LOOKUPS                        XLO2
         ,XLA_LOOKUPS                        XLO4
         ,XLA_LOOKUPS                        XLO5
   WHERE xls.application_id                  = aeh.application_id
     AND aeh.event_id                        = xle.event_id
     AND aeh.application_id                  = xle.application_id
     AND xle.entity_id                       = ent.entity_id
     AND xle.application_id                  = ent.application_id
     AND aeh.period_name                     = gps.period_name
     AND aeh.ledger_id                       = gps.ledger_id
     AND gps.application_id                  = 101
     AND gld.ledger_id                       = aeh.ledger_id
     AND fnu.user_id                         = aeh.created_by
     AND gjt.je_source_name                  = xls.je_source_name
     AND gjt.LANGUAGE                        = USERENV(''LANG'')
     AND xet.application_id                  = xle.application_id
     AND xet.event_type_code                 = aeh.event_type_code
     AND xtt.application_id                  = xet.application_id
     AND xtt.event_type_code                 = xet.event_type_code
     AND xtt.entity_code                     = xet.entity_code
     AND xtt.event_class_code                = xet.event_class_code
     AND xtt.LANGUAGE                        = USERENV(''LANG'')
     AND xcl.application_id                  = xtt.application_id
     AND xcl.entity_code                     = xtt.entity_code
     AND xcl.event_class_code                = xtt.event_class_code
     AND xcl.application_id                  = ent.application_id
     AND xcl.entity_code                     = ent.entity_code
     AND xcl.LANGUAGE                        = USERENV(''LANG'')
     AND gjct.je_category_name               = aeh.je_category_name
     AND gjct.LANGUAGE                       = USERENV(''LANG'')
     AND aeh.gl_transfer_status_code         IN (''N'',''E'')
     AND xlo2.lookup_type                    = ''XLA_YES_NO''
     AND xlo2.lookup_code                    = xle.on_hold_flag
     AND xlo4.lookup_type                    = ''XLA_ACCOUNTING_ENTRY_STATUS''
     AND xlo4.lookup_code                    = aeh.accounting_entry_status_code
     AND xlo5.lookup_type                    = ''XLA_BALANCE_TYPE''
     AND xlo5.lookup_code                    = aeh.balance_type_code
     AND aeh.ledger_id                        IN ';

    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
         trace('build_xml_sql.End'
               ,C_LEVEL_PROCEDURE, l_log_module);
    END IF;

  EXCEPTION
  WHEN OTHERS THEN
    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
         trace('build_xml_sql.End with Error'
               ,C_LEVEL_PROCEDURE, l_log_module);
    END IF;
     xla_exceptions_pkg.raise_message
           (p_location       =>
                'xla_period_close_exp_pkg.build_xml_sql');
END build_xml_sql;

--changed Function get_transaction_id returning varchar2 to a procedure preeti/6204675

procedure get_transaction_id
            (p_ledger_ids      IN VARCHAR2
            ,p_event_filter    IN VARCHAR2
            ,p_header_filter   IN VARCHAR2)  IS

    C_EVENTS_HEADERS_QUERY  VARCHAR2(8000) :=
         'SELECT /*+ index(ent XLA_TRANSACTION_ENTITIES_U1) */ DISTINCT
                  xle.application_id        APPLICATION_ID
                 ,xcl.entity_code           ENTITY_CODE
                 ,xcl.event_class_code      EVENT_CLASS_CODE
                 ,gjct.reporting_view_name  REPORTING_VIEW_NAME
           FROM   xla_events                xle
                 ,xla_event_types_b         xcl
                 ,xla_event_class_attrs     gjct
                 ,xla_transaction_entities  ent
                 ,xla_ledger_options        xlo
          WHERE   ent.entity_id          =  xle.entity_id
            AND   ent.application_id     =  xle.application_id
            AND   ent.ledger_id          =  xlo.ledger_id
            AND   ent.application_id     =  xlo.application_id
            AND   xlo.capture_event_flag =  ''Y''
            AND   xcl.application_id     =  xle.application_id
            AND   xcl.event_type_code    =  xle.event_type_code
            AND   xcl.entity_code  NOT IN (''MANUAL'',''THIRD_PARTY_MERGE'',''REVERSAL'') -- FSAH-PSFT FP
            AND   gjct.application_id    =  xcl.application_id
            AND   gjct.entity_code       =  xcl.entity_code
            AND   gjct.event_class_code  =  xcl.event_class_code
            AND   xle.event_status_code    IN (''I'',''U'')
            AND   xle.process_status_code  IN (''U'',''D'',''E'',''R'',''I'')
            AND   ent.ledger_id          IN $ledger_ids$
            $event_filter$
            UNION ALL
            SELECT  DISTINCT
                   aeh.application_id      APPLICATION_ID
                  ,xcl.entity_code         ENTITY_CODE
                  ,xcl.event_class_code    EVENT_CLASS_CODE
                  ,gjct.reporting_view_name REPORTING_VIEW_NAME
            FROM  xla_ae_headers             aeh
                  ,xla_event_types_b         xcl
                  ,xla_event_class_attrs     gjct
                  ,xla_transaction_entities  ent
           WHERE  xcl.application_id      = aeh.application_id
             AND  xcl.event_type_code     = aeh.event_type_code
             AND  gjct.application_id     = xcl.application_id
             AND  gjct.entity_code        = xcl.entity_code
             AND  gjct.event_class_code   = xcl.event_class_code
             AND  ent.entity_id           = aeh.entity_id
             AND  ent.application_id      = aeh.application_id
         AND  xcl.entity_code  NOT IN (''MANUAL'',''THIRD_PARTY_MERGE'',''REVERSAL'')   --FSAH-PSFT FP bug 6896350
         AND  aeh.gl_transfer_status_code IN (''N'',''E'')                 -- bug 6896350
             AND  aeh.ledger_id           IN $ledger_ids$
             $header_filter$';

    cursor c1 is
       SELECT application_id
             ,entity_code
             ,event_class_code
             ,reporting_view_name
         FROM xla_event_class_attrs;

    TYPE l_event_class_tab IS TABLE of c1%ROWTYPE;
    l_event_class_set         l_event_class_tab;

    l_col_array           t_array;
    l_null_col_array      t_array;
    l_trx_id_str          VARCHAR2(32000):=NULL;
    l_trx_id_str_temp     VARCHAR2(32000):=NULL;
    l_col_string          VARCHAR2(10000)   := NULL;
    l_view_name           VARCHAR2(800);
    l_join_string         VARCHAR2(10000)   := NULL;
    l_index               INTEGER;
    l_outerjoin           VARCHAR2(300);
    l_log_module          VARCHAR2(240);
    l_id_num              number:=1;
BEGIN
    IF g_log_enabled THEN
       l_log_module := C_DEFAULT_MODULE||'.get_transaction_id';
    END IF;
    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
       trace
          (p_msg      => 'BEGIN of function GET_TRANSACTION_ID'
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   => l_log_module);
       trace
          (p_msg      => 'p_ledger_ids = '||p_ledger_ids
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   => l_log_module);
       trace
          (p_msg      => 'p_event_filter = '||p_event_filter
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   => l_log_module);
       trace
          (p_msg      => 'p_header_filter = '||p_header_filter
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   => l_log_module);
    END IF;
    l_trx_id_str := ',CASE WHEN 1<1 THEN NULL';

    C_EVENTS_HEADERS_QUERY := replace(C_EVENTS_HEADERS_QUERY,
                                      '$ledger_ids$',p_ledger_ids);
    C_EVENTS_HEADERS_QUERY := replace(C_EVENTS_HEADERS_QUERY,
                                      '$event_filter$',p_event_filter);
    C_EVENTS_HEADERS_QUERY := replace(C_EVENTS_HEADERS_QUERY,
                                      '$header_filter$',p_header_filter);

    IF (C_LEVEL_STATEMENT >= g_log_level) THEN
        trace
             (p_msg      => 'C_EVENTS_HEADERS_QUERY = '||C_EVENTS_HEADERS_QUERY
             ,p_level    => C_LEVEL_STATEMENT
             ,p_module   => l_log_module);
    END IF;


    EXECUTE IMMEDIATE C_EVENTS_HEADERS_QUERY
    BULK COLLECT INTO l_event_class_set;

    IF l_event_class_set.count > 0 THEN
       FOR k in l_event_class_set.FIRST .. l_event_class_set.LAST
       LOOP

        IF (C_LEVEL_STATEMENT >= g_log_level) THEN
               trace
                  (p_msg      => 'inside loop count = '||k
                  ,p_level    => C_LEVEL_STATEMENT
                  ,p_module   => l_log_module);
        END IF;

         l_col_string    := NULL;
         l_view_name     := NULL;
         l_join_string   := NULL;


         --
         -- creating a dummy array that contains "NULL" strings
         --


          FOR i IN 1..10 LOOP
              l_null_col_array(i).f1 := 'NULL';
              l_null_col_array(i).f2 := 'NULL';
          END LOOP;
            --
            -- initiating the array that contains name of the columns to be
            -- selected from the TID View.
            --
          l_col_array := l_null_col_array;

            --
            -- creating SELECT,FROM and WHERE clause strings when the reporting
            -- view is defined for an Event Class.
            --

          IF l_event_class_set(k).reporting_view_name IS NOT NULL THEN
            --
            -- creating string to be added to FROM clause
            --

             IF (C_LEVEL_STATEMENT >= g_log_level) THEN
               trace
                  (p_msg      => 'Inside when reporting view name is not null'
                  ,p_level    => C_LEVEL_STATEMENT
                  ,p_module   => l_log_module);
             END IF;

               l_view_name   := l_event_class_set(k).reporting_view_name
                                || '    TIV';

             IF (C_LEVEL_STATEMENT >= g_log_level) THEN
               trace
                  (p_msg      => 'length of l_view_name = '||length(l_view_name)
                  ,p_level    => C_LEVEL_STATEMENT
                  ,p_module   => l_log_module);
             END IF;

             l_index := 0;

             FOR cols_csr IN
               (SELECT  xid.transaction_id_col_name_1   trx_col_1
                       ,xid.transaction_id_col_name_2   trx_col_2
                       ,xid.transaction_id_col_name_3   trx_col_3
                       ,xid.transaction_id_col_name_4   trx_col_4
                       ,xid.source_id_col_name_1        src_col_1
                       ,xid.source_id_col_name_2        src_col_2
                       ,xid.source_id_col_name_3        src_col_3
                       ,xid.source_id_col_name_4        src_col_4
                       ,xem.column_name                 column_name
                       ,xem.column_title                PROMPT
                       ,utc.data_type                   data_type
                FROM  xla_entity_id_mappings   xid
                     ,xla_event_mappings_vl    xem
                     ,user_tab_columns         utc
                WHERE xid.application_id = l_event_class_set(k).application_id
                AND xid.entity_code = l_event_class_set(k).entity_code
                AND xem.application_id = l_event_class_set(k).application_id
                AND xem.entity_code = l_event_class_set(k).entity_code
                AND xem.event_class_code = l_event_class_set(k).event_class_code
                AND utc.table_name = l_event_class_set(k).reporting_view_name
                AND utc.column_name = xem.column_name
                ORDER BY xem.user_sequence)
              LOOP

                  l_index := l_index + 1;
                  --
                  -- creating string to be added to WHERE clause
                  --
                  IF l_index = 1 THEN
                     -----------------------------------------------------------
                     -- Bug 3389175
                     -- Following logic is build to make sure all events are
                     -- reported if debug is enabled evenif there is no data for
                     -- the event in the transaction id view.
                     -- if log enabled  then
                     --        outer join to TID view
                     -- endif
                     -----------------------------------------------------------
                     IF g_log_level <> C_LEVEL_LOG_DISABLED THEN
                        l_outerjoin := '(+)';
                     ELSE
                        l_outerjoin := NULL;
                     END IF;

                     IF cols_csr.trx_col_1 IS NOT NULL THEN
                        l_join_string := l_join_string ||
                                        '  TIV.'|| cols_csr.trx_col_1 ||
                                        l_outerjoin ||
                                        ' = ENT.'|| cols_csr.src_col_1;
                     END IF;
                     IF cols_csr.trx_col_2 IS NOT NULL THEN
                        l_join_string := l_join_string ||
                                       ' AND TIV.'|| cols_csr.trx_col_2 ||
                                       l_outerjoin ||
                                       ' = ENT.'|| cols_csr.src_col_2;
                     END IF;
                     IF cols_csr.trx_col_3 IS NOT NULL THEN
                        l_join_string := l_join_string ||
                                       ' AND TIV.'|| cols_csr.trx_col_3 ||
                                       l_outerjoin ||
                                       ' = ENT.'|| cols_csr.src_col_3;
                     END IF;
                     IF cols_csr.trx_col_4 IS NOT NULL THEN
                        l_join_string := l_join_string ||
                                      ' AND TIV.'|| cols_csr.trx_col_4 ||
                                      l_outerjoin ||
                                      ' = ENT.'|| cols_csr.src_col_4;
                     END IF;

                     IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                     trace
                      (p_msg      => 'length of l_join_string = '||length(l_join_string)
                      ,p_level    => C_LEVEL_STATEMENT
                      ,p_module   => l_log_module);
                     END IF;

                  END IF;
                  --
                  -- getting the PROMPTs to be displayed
                  --
                  --l_col_array(l_index).f1 := ''''||cols_csr.PROMPT||'''';
                  l_col_array(l_index).f1 := ''''||REPLACE (cols_csr.PROMPT,'''','''''')||'''';  -- bug 6755287

                  ---
                  -- getting the columns to be displayed
                  ---
                 IF cols_csr.data_type = 'VARCHAR2' THEN
                    l_col_array(l_index).f2 := 'TIV.'|| cols_csr.column_name;
                 ELSE
                    l_col_array(l_index).f2 := 'to_char(TIV.'||
                                               cols_csr.column_name||')';
                 END IF;
              END LOOP;
          END IF;
            --------------------------------------------------------------------
            -- building the string to be added to the SELECT clause
            --------------------------------------------------------------------
          l_col_string := l_col_string ||
                            l_col_array(1).f1||'||''|''||'||l_col_array(1).f2;

          FOR i IN 2..l_col_array.count LOOP
               l_col_string := l_col_string ||'||''|''||'||l_col_array(i).f1
                               ||'||''|''||'||l_col_array(i).f2;
          END LOOP;


         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
               trace
                  (p_msg      => 'length of l_col_string = '||length(l_col_string)
                  ,p_level    => C_LEVEL_STATEMENT
                  ,p_module   => l_log_module);
         END IF;

        l_trx_id_str_temp := l_trx_id_str||' WHEN xet.event_class_code = '''
                          ||l_event_class_set(k).event_class_code||
                          ''' THEN  ( SELECT '||l_col_string
                          ||'  FROM  '||l_view_name ||' WHERE '|| l_join_string
                          ||' )' ;
       IF (C_LEVEL_STATEMENT >= g_log_level) THEN
               trace
                  (p_msg      => 'length of l_trx_id_str_temp = '||length(l_trx_id_str_temp)
                  ,p_level    => C_LEVEL_STATEMENT
                  ,p_module   => l_log_module);
       END IF;

      IF  length(l_trx_id_str_temp)<=25000 then
        l_trx_id_str := l_trx_id_str_temp;

      ELSE
        IF l_id_num = 1 then
          p_trx_identifiers_1 := l_trx_id_str;
          l_trx_id_str_temp:=NULL;
          l_trx_id_str:=NULL;
        END IF;
        IF l_id_num = 2 then
          p_trx_identifiers_2 := l_trx_id_str;
          l_trx_id_str_temp:=NULL;
          l_trx_id_str:=NULL;
        END IF;
        IF l_id_num = 3 then
          p_trx_identifiers_3 := l_trx_id_str;
          l_trx_id_str_temp:=NULL;
          l_trx_id_str:=NULL;
        END IF;
        IF l_id_num = 4 then
          p_trx_identifiers_4 := l_trx_id_str;
          l_trx_id_str_temp:=NULL;
          l_trx_id_str:=NULL;
        END IF;
       IF l_id_num = 5 then
          p_trx_identifiers_5 := l_trx_id_str;
          l_trx_id_str_temp:=NULL;
          l_trx_id_str:=NULL;
       END IF;
       l_trx_id_str_temp := ' WHEN xet.event_class_code = '''
                          ||l_event_class_set(k).event_class_code||
                          ''' THEN  ( SELECT '||l_col_string
                          ||'  FROM  '||l_view_name ||' WHERE '|| l_join_string
                          ||' )' ;
                          l_trx_id_str:=l_trx_id_str_temp;
       IF (C_LEVEL_STATEMENT >= g_log_level) THEN
               trace
                  (p_msg      => 'inside length of l_trx_id_str_temp = '||length(l_trx_id_str_temp)
                  ,p_level    => C_LEVEL_STATEMENT
                  ,p_module   => l_log_module);
       END IF;

       l_id_num := l_id_num + 1;

     END IF;




           IF (C_LEVEL_STATEMENT >= g_log_level) THEN
               trace
                  (p_msg      => 'length of l_trx_id_str = '||length(l_trx_id_str)
                  ,p_level    => C_LEVEL_STATEMENT
                  ,p_module   => l_log_module);
           END IF;




       END LOOP;
    END IF;

    l_trx_id_str := l_trx_id_str ||' END  '||' USERIDS';

    if l_id_num = 1 then
         p_trx_identifiers_1 := l_trx_id_str;
    elsif l_id_num = 2 then
         p_trx_identifiers_2 := l_trx_id_str;
    elsif l_id_num = 3 then
         p_trx_identifiers_3 := l_trx_id_str;
    elsif l_id_num = 4 then
         p_trx_identifiers_4 := l_trx_id_str;
    elsif l_id_num = 5 then
         p_trx_identifiers_5 := l_trx_id_str;
    end if;

    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
         trace('get_transaction_id .End'
               ,C_LEVEL_PROCEDURE, l_log_module);
    END IF;


EXCEPTION
WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location       => 'xla_period_close_exp_pkg.get_transaction_id ');

END get_transaction_id;


FUNCTION get_ledger_ids(p_ledger_id            IN NUMBER) RETURN VARCHAR2 IS
   CURSOR cur_primary_ledger( p_ledger_id NUMBER) IS
          select distinct glr1.target_ledger_id ledger_id
            from gl_ledger_relationships glr1
                ,gl_ledger_relationships glr2
           where glr1.source_ledger_id = glr2.source_ledger_id
             and glr1.application_id = glr2.application_id
             and glr2.target_ledger_id = p_ledger_id
             and glr2.application_id = 101
             and (g_use_ledger_security = 'N'
                  or glr1.target_ledger_id in
                     (select led.ledger_id
                        from gl_ledgers led, gl_access_set_assignments aset
                       where aset.ledger_id = led.ledger_id
                         and aset.access_set_id in
                             (g_access_set_id, g_sec_access_set_id)));

   CURSOR cur_ledger ( p_ledger_id NUMBER) IS
          SELECT distinct glr2.target_ledger_id ledger_id
            FROM gl_ledger_set_assignments gla
                ,gl_ledger_relationships glr1
                ,gl_ledger_relationships glr2
           WHERE gla.ledger_id = glr1.target_ledger_id
             AND glr1.source_ledger_id = glr2.source_ledger_id
             and glr1.application_id = glr2.application_id
             AND gla.ledger_set_id = p_ledger_id
             AND gla.ledger_id <> gla.ledger_set_id
             AND glr1.application_id = 101
             AND (g_use_ledger_security = 'N'
                  or glr2.target_ledger_id in
                     (SELECT led.ledger_id
                        FROM gl_ledgers led, gl_access_set_assignments aset
                       WHERE aset.ledger_id = led.ledger_id
                         AND aset.access_set_id in
                             (g_access_set_id, g_sec_access_set_id)));

   l_log_module               VARCHAR2(240);
   l_ledger_ids               VARCHAR2(2000);
   l_object_type_code         VARCHAR2(1);

BEGIN
    IF g_log_enabled THEN
       l_log_module := C_DEFAULT_MODULE||'.get_ledger_ids';
    END IF;

    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
       trace('get_ledger_ids.Begin',C_LEVEL_PROCEDURE,l_log_module);
    END IF;

    IF (C_LEVEL_STATEMENT >= g_log_level) THEN
       trace('p_ledger_id = '|| to_char(p_ledger_id),
                C_LEVEL_STATEMENT ,l_log_module);
       trace('g_access_set_id = '|| to_char(g_access_set_id),
                C_LEVEL_STATEMENT ,l_log_module);
       trace('g_sec_access_set_id = '|| to_char(g_sec_access_set_id),
                C_LEVEL_STATEMENT ,l_log_module);
       trace('g_use_ledger_security = '|| g_use_ledger_security,
                C_LEVEL_STATEMENT ,l_log_module);
    END IF;

    l_object_type_code := xla_report_utility_pkg.get_ledger_object_type
                                                          (p_ledger_id);

    IF (C_LEVEL_STATEMENT >= g_log_level) THEN
       trace('l_object_type_code = '|| l_object_type_code,
                C_LEVEL_STATEMENT ,l_log_module);
    END IF;

    IF l_object_type_code = 'S' THEN
       FOR l_set IN cur_ledger(p_ledger_id)
       LOOP
           l_ledger_ids := l_ledger_ids || l_set.ledger_id ||',';
       END LOOP;

    ELSIF l_object_type_code = 'L' THEN

       FOR l_set IN cur_primary_ledger(p_ledger_id)
       LOOP
          l_ledger_ids := l_ledger_ids || l_set.ledger_id || ',';
    IF (C_LEVEL_STATEMENT >= g_log_level) THEN
       trace('l_ledger_ids = '|| l_ledger_ids,
                C_LEVEL_STATEMENT ,l_log_module);
       trace('l_set.ledger_id = '|| to_char(l_set.ledger_id),
                C_LEVEL_STATEMENT ,l_log_module);
    END IF;
       END LOOP;
    END IF;

    IF (C_LEVEL_STATEMENT >= g_log_level) THEN
       trace('l_ledger_ids = '|| l_ledger_ids,
                C_LEVEL_STATEMENT ,l_log_module);
    END IF;

    l_ledger_ids := substr(l_ledger_ids,0,length(l_ledger_ids)-1);

    IF (C_LEVEL_STATEMENT >= g_log_level) THEN
       trace('l_ledger_ids = '|| l_ledger_ids,
                C_LEVEL_STATEMENT ,l_log_module);
    END IF;

    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
       trace('get_ledger_ids.End',C_LEVEL_PROCEDURE,l_log_module);
    END IF;
    RETURN l_ledger_ids;
EXCEPTION
    WHEN OTHERS THEN
       xla_exceptions_pkg.raise_message
           (p_location       => 'xla_period_close_exp_pkg.get_ledger_ids');
END get_ledger_ids;

   PROCEDURE build_query_sql
      (p_application_id                  IN NUMBER
      ,p_ledger_id                       IN NUMBER
      ,p_period_from                     IN VARCHAR2
      ,p_period_to                       IN VARCHAR2
      ,p_event_class                     IN VARCHAR2
      ,p_je_category                     IN VARCHAR2
      ,p_object_type_code                IN VARCHAR2
      ,p_je_source_name                  IN VARCHAR2
      ,p_mode                            IN VARCHAR2) IS

      l_event_filter             VARCHAR2(4000) := ' ';

      l_header_filter            VARCHAR2(4000) := ' ';
      l_application_filter_evt   VARCHAR2(150);
      l_application_filter_aeh   VARCHAR2(200);
      l_je_source_filter         VARCHAR2(200) := ' ';
      l_je_category_filter       VARCHAR2(200);
      l_date_filter_evt          VARCHAR2(200);
      l_date_filter_aeh          VARCHAR2(200);
      l_ledger_ids               VARCHAR2(2000);
      l_event_class_filter       VARCHAR2(200);

      l_start_date               DATE;
      l_end_date                 DATE;

      l_log_module               VARCHAR2(240);
      l_period_ledger_id         GL_LEDGERS.ledger_id%TYPE;
      l_index                    NUMBER;




   BEGIN

      IF g_log_enabled THEN
         l_log_module := C_DEFAULT_MODULE||'.build_query_sql';
      END IF;

      IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
         trace('build_query_sql.Begin',C_LEVEL_PROCEDURE,l_log_module);
      END IF;

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace('p_ledger_id  ='   || p_ledger_id,C_LEVEL_STATEMENT,
                                                 l_log_module);
         trace('period_from =' || p_period_from,C_LEVEL_STATEMENT,l_log_module);
         trace('period_to = '|| p_period_to,C_LEVEL_STATEMENT,l_Log_module);
         trace('p_event_class = '|| p_event_class,
                C_LEVEL_STATEMENT ,l_log_module);
         trace('p_je_category = '|| p_je_category,
                C_LEVEL_STATEMENT, l_log_module);
         trace('p_object_type_code = '|| p_object_type_code,
                C_LEVEL_STATEMENT, l_log_module);
         trace('p_je_source_name = '|| p_je_source_name,
                C_LEVEL_STATEMENT, l_log_module);
      END IF;


      build_xml_sql;

   ----------------------------------------------------------------------------
   -- build filter condition based on parameters
   ----------------------------------------------------------------------------

      l_ledger_ids := get_ledger_ids(p_ledger_id);


      IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
         trace('l_ledger_ids = '|| l_ledger_ids,
                C_LEVEL_STATEMENT, l_log_module);
      END IF;


      IF p_object_type_code = 'S' THEN
         SELECT ledger_id
           INTO l_period_ledger_id
           FROM gl_ledger_set_assignments
          WHERE ledger_set_id = p_ledger_id
            AND ledger_id <> p_ledger_id
            AND ROWNUM = 1;
     ELSE
        l_period_ledger_id := p_ledger_id ;
     END IF;


      IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
          trace('l_period_ledger_id = '|| l_period_ledger_id,
                C_LEVEL_STATEMENT, l_log_module);
      END IF;

      get_period_start_end_dates(l_period_ledger_id
                                ,p_period_from
                                ,p_period_to
                                ,l_start_date
                                ,l_end_date);

      IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
         trace('l_start_date = '|| to_char(l_start_date,'DD-MON-YYYY'),
                C_LEVEL_STATEMENT, l_log_module);
         trace('l_end_date = '|| to_char(l_end_date,'DD-MON-YYYY'),
                C_LEVEL_STATEMENT, l_log_module);
      END IF;

      l_ledger_ids := nvl(l_ledger_ids,'NULL');

--------------------------------------------------------------------
-- the following is removed (commented) as part of bug fix 6805286
--------------------------------------------------------------------
--      IF p_mode <> 'W' THEN
--
--          stamp_events_wo_aad(p_application_id
--                             ,l_ledger_ids
--                             ,l_start_date
--                             ,l_end_date);
--      END IF;

      l_ledger_ids := '(' || l_ledger_ids  ||')';

      IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
         trace('l_ledger_ids = '|| l_ledger_ids,
                C_LEVEL_STATEMENT, l_log_module);
      END IF;

      IF p_application_id <> 101 THEN
         l_application_filter_evt := l_application_filter_evt ||
               ' AND xle.application_id = '|| to_char(p_application_id) ;
         l_application_filter_aeh := l_application_filter_aeh ||
               ' AND aeh.application_id = '|| to_char(p_application_id) ;
      END IF;

      IF p_je_source_name is NOT NULL THEN
         l_je_source_filter := ' AND xls.je_source_name =
                               ' ||''''|| p_je_source_name||'''' ;
      END IF;

      IF p_je_category is NOT NULL THEN
         l_je_category_filter := ' AND gjct.je_category_name = ' ||''''||
                                 p_je_category||'''';
      END IF;

      IF p_event_class is NOT NULL THEN
         l_event_class_filter := ' AND xcl.event_class_code = ' ||''''||
                                p_event_class||'''' ;
      END IF;

      l_date_filter_evt :=
                 ' AND xle.event_date BETWEEN '''||l_start_date|| ''' '||
                                      'AND '''||l_end_date||''' ';

      l_date_filter_aeh :=
                 ' AND aeh.accounting_date BETWEEN '''||l_start_date|| ''' '||
                                           'AND '''||l_end_date||''' ';

      l_event_filter  := l_application_filter_evt || l_date_filter_evt ||
                         l_je_category_filter || l_event_class_filter ;
      l_header_filter := l_application_filter_aeh || l_date_filter_aeh ||
                         l_je_category_filter || l_event_class_filter ;

      -- l_application_filter_evt needs to be combined with
      -- l_application_filter_aeh to be replaced in l_percl_query
      -- but the same cannot be used from l_user_trx_query
      -- so joining with l_je_source_filter which will be used for l_percl_query


     get_transaction_id(l_ledger_ids,l_event_filter,l_header_filter);


  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
         trace('p_trx_identifiers_1='||substr(p_trx_identifiers_1,1,3000),C_LEVEL_PROCEDURE, l_log_module);
END IF;
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
         trace('p_trx_identifiers_2='||substr(p_trx_identifiers_2,1,3000),C_LEVEL_PROCEDURE, l_log_module);
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
         trace('p_trx_identifiers_3='||substr(p_trx_identifiers_3,1,3000),C_LEVEL_PROCEDURE, l_log_module);
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
         trace('p_trx_identifiers_4='||substr(p_trx_identifiers_4,1,3000),C_LEVEL_PROCEDURE, l_log_module);
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
         trace('p_trx_identifiers_5='||substr(p_trx_identifiers_5,1,3000),C_LEVEL_PROCEDURE, l_log_module);
END IF;




       xla_period_close_exp_pkg.p_ledger_ids := l_ledger_ids;
      xla_period_close_exp_pkg.p_event_filter := l_event_filter;
      xla_period_close_exp_pkg.p_header_filter := l_header_filter;
      xla_period_close_exp_pkg.p_je_source_filter := l_je_source_filter;
      xla_period_close_exp_pkg.p_object_type_code := p_object_type_code;
      xla_period_close_exp_pkg.p_je_source_name := p_je_source_name;

    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
         trace('build_query_sql.End'
               ,C_LEVEL_PROCEDURE, l_log_module);
    END IF;

   EXCEPTION
     WHEN NO_DATA_FOUND THEN
        NULL;
     WHEN OTHERS THEN
        xla_exceptions_pkg.raise_message
           (p_location       => 'xla_period_close_exp_pkg.build_query_sql');
   END build_query_sql ;

FUNCTION check_period_close(p_application_id   IN NUMBER
                           ,p_period_name      IN VARCHAR2
                           ,p_ledger_id        IN NUMBER) RETURN NUMBER IS
   l_log_module              VARCHAR2(240);
   l_period_start_date       DATE;
   l_period_end_date         DATE;
   l_unprocessed             NUMBER DEFAULT 0;
   l_ledger_ids              VARCHAR2(2000);
BEGIN
    IF g_log_enabled THEN
       l_log_module := C_DEFAULT_MODULE||'.check_period_close';
    END IF;

    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
       trace('check_period_close.Begin',C_LEVEL_PROCEDURE,l_log_module);
    END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
       trace('p_application_id = '|| to_char(p_application_id),
                C_LEVEL_STATEMENT ,l_log_module);
       trace('p_period_name = '|| p_period_name,
                C_LEVEL_STATEMENT ,l_log_module);
       trace('p_ledger_id = '|| to_char(p_ledger_id),
                C_LEVEL_STATEMENT ,l_log_module);
   END IF;
   get_period_start_end_dates(p_ledger_id
                             ,p_period_name
                             ,p_period_name
                             ,l_period_start_date
                             ,l_period_end_date);

   l_ledger_ids := nvl(get_ledger_ids(p_ledger_id),'NULL');

--------------------------------------------------------------------
-- the following is removed (commented) as part of bug fix 6805286
--------------------------------------------------------------------
--   stamp_events_wo_aad(p_application_id
--                      ,l_ledger_ids
--                      ,l_period_start_date
--                      ,l_period_end_date);


   IF p_application_id = 101 THEN


     BEGIN

     SELECT   1
     INTO     l_unprocessed
     FROM     dual
     WHERE EXISTS(select 1
                  FROM   xla_events xle
                  ,xla_transaction_entities xte
                 ,gl_ledger_relationships glr1
                 ,gl_ledger_relationships glr2
                 ,xla_ledger_options xlo
                  WHERE   xle.entity_id = xte.entity_id
                  AND   xle.application_id = xte.application_id
                  AND   xle.event_date BETWEEN l_period_start_date and l_period_end_date
                  AND   glr2.target_ledger_id = p_ledger_id
                  AND   glr2.source_ledger_id = glr1.source_ledger_id
                  AND   glr2.application_id = glr1.application_id
                  AND   glr1.target_ledger_id = xlo.ledger_id
                  AND   xle.application_id = xlo.application_id
                  AND   xlo.capture_event_flag = 'Y'
                  AND   (glr1.target_ledger_id = xte.ledger_id OR
                        glr1.primary_ledger_id = xte.ledger_id )
                  AND   (glr1.relationship_type_code = 'SUBLEDGER' OR
                        (glr1.target_ledger_category_code = 'PRIMARY'
                        AND glr1.relationship_type_code = 'NONE'))
                  AND   glr2.application_id  = 101
                  AND   xle.event_status_code IN ('I','U')
                  AND   xle.process_status_code IN ('I','U','R','D','E'));


        EXCEPTION WHEN no_data_found THEN

            --IF l_unprocessed = 0 THEN
              SELECT  count(*)
              INTO  l_unprocessed
              FROM  xla_ae_headers aeh
                ,xla_transaction_entities xte
                ,gl_ledger_relationships glr1
                ,gl_ledger_relationships glr2
              WHERE  aeh.ledger_id = glr2.target_ledger_id
              AND  glr2.source_ledger_id = glr1.source_ledger_id
              AND  glr2.application_id = glr1.application_id
              AND  glr1.target_ledger_id = p_ledger_id
              AND  glr1.application_id = 101
              AND  xte.entity_id = aeh.entity_id
              AND  xte.application_id = aeh.application_id
              AND  aeh.gl_transfer_status_code   IN ('N','E')
              AND  aeh.accounting_date BETWEEN
                     l_period_start_date AND l_period_end_date
              AND  rownum = 1;
           --END IF;


      END;


    ELSE


     BEGIN

          SELECT   1
          INTO     l_unprocessed
          FROM     dual
          WHERE EXISTS(select 1
                       FROM   xla_events xle
                       ,xla_transaction_entities xte
                       ,gl_ledger_relationships glr1
                       ,gl_ledger_relationships glr2
                       ,xla_ledger_options xlo
                       WHERE xle.entity_id = xte.entity_id
                       AND   xle.application_id = xte.application_id
                       AND   xle.event_date BETWEEN l_period_start_date and l_period_end_date
                       AND   xle.application_id = p_application_id
                       AND   xle.event_status_code IN ('I','U')
                       AND   xle.process_status_code IN ('I','U','R','D','E')
                       AND   glr2.target_ledger_id = p_ledger_id
                       AND   glr2.source_ledger_id = glr1.source_ledger_id
                       AND   glr2.application_id = glr1.application_id
                       AND   glr1.target_ledger_id = xlo.ledger_id
                       AND   xle.application_id = xlo.application_id
                       AND   xlo.capture_event_flag = 'Y'
                       AND   (glr1.target_ledger_id = xte.ledger_id OR
                             glr1.primary_ledger_id = xte.ledger_id )
                       AND   (glr1.relationship_type_code = 'SUBLEDGER' OR
                             (glr1.target_ledger_category_code = 'PRIMARY'
                             AND glr1.relationship_type_code = 'NONE'))
                       AND   glr2.application_id  = 101
                       AND   xte.application_id = p_application_id
                       );

                       --6784591 added process_status_code check.


      EXCEPTION WHEN no_data_found THEN

        --IF l_unprocessed = 0 THEN
         SELECT  count(*)
           INTO  l_unprocessed
           FROM  xla_ae_headers aeh
                ,xla_transaction_entities xte
                ,gl_ledger_relationships glr1
                ,gl_ledger_relationships glr2
          WHERE  aeh.ledger_id = glr2.target_ledger_id
            AND  glr2.source_ledger_id = glr1.source_ledger_id
            AND  glr2.application_id = glr1.application_id
            AND  glr1.target_ledger_id = p_ledger_id
            AND  glr1.application_id = 101
            AND  xte.entity_id = aeh.entity_id
            AND  xte.application_id = aeh.application_id
            AND  aeh.gl_transfer_status_code   IN ('N','E')
            AND  aeh.accounting_date BETWEEN
                     l_period_start_date AND l_period_end_date
            AND  xte.application_id = p_application_id
            AND  rownum = 1;
        --END IF;


      END;

    END IF;

    IF (C_LEVEL_STATEMENT >= g_log_level) THEN
       trace('l_unprocessed = '|| to_char(l_unprocessed),
                C_LEVEL_STATEMENT ,l_log_module);
    END IF;

    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
       trace('check_period_close.End',C_LEVEL_PROCEDURE,l_log_module);
    END IF;

   RETURN l_unprocessed;
EXCEPTION
    WHEN OTHERS THEN
       xla_exceptions_pkg.raise_message
           (p_location       => 'xla_period_close_exp_pkg.check_period_close');

END check_period_close;

FUNCTION beforeReport  RETURN BOOLEAN IS
   l_errbuf                  VARCHAR2(2000);
   l_log_module              VARCHAR2(240);
BEGIN
   IF g_log_enabled THEN
        l_log_module := C_DEFAULT_MODULE||'.beforeReport';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
        trace('beforeReport.Begin',C_LEVEL_PROCEDURE,l_log_module);
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN

        trace('p_application_id = '|| to_char(p_application_id),
               C_LEVEL_STATEMENT, l_log_module);
        trace('p_je_source = '|| p_je_source,
               C_LEVEL_STATEMENT, l_log_module);
        trace('p_dummy_param_1 = '|| to_char(p_dummy_param_1),
               C_LEVEL_STATEMENT, l_log_module);
        trace('p_dummy_param_2 = '|| to_char(p_dummy_param_2),
               C_LEVEL_STATEMENT, l_log_module);
        trace('p_ledger_id = '|| to_char(p_ledger_id),
               C_LEVEL_STATEMENT, l_log_module);
        trace('p_ledger = '|| p_ledger,
               C_LEVEL_STATEMENT, l_log_module);
        trace('p_period_from = '|| p_period_from,
               C_LEVEL_STATEMENT,l_log_module);
        trace('p_period_to = '|| p_period_to,
               C_LEVEL_STATEMENT, l_log_module);
        trace('p_event_class = '|| p_event_class,
               C_LEVEL_STATEMENT, l_log_module);
        trace('p_event_class_code = '|| p_event_class_code,
               C_LEVEL_STATEMENT, l_log_module);
        trace('p_je_category = '|| p_je_category,
               C_LEVEL_STATEMENT, l_log_module);
        trace('p_je_category_name = '|| p_je_category_name,
               C_LEVEL_STATEMENT, l_log_module);
        trace('p_mode      = '|| p_mode,
               C_LEVEL_STATEMENT, l_log_module);
   END IF;

   run_report(p_errbuf          => l_errbuf
             ,p_retcode         => xla_period_close_exp_pkg.C_RETURN_CODE
             ,p_application_id  => xla_period_close_exp_pkg.p_application_id
             ,p_ledger_id       => xla_period_close_exp_pkg.p_ledger_id
             ,p_period_from     => xla_period_close_exp_pkg.p_period_from
             ,p_period_to       => xla_period_close_exp_pkg.p_period_to
             ,p_event_class     => xla_period_close_exp_pkg.p_event_class_code
             ,p_je_category     => xla_period_close_exp_pkg.p_je_category_name
             ,p_mode            => xla_period_close_exp_pkg.p_mode);

    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
         trace('beforeReport.End'
               ,C_LEVEL_PROCEDURE, l_log_module);
    END IF;

   RETURN TRUE;

EXCEPTION
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
         (p_location  => 'xla_period_close_exp_pkg.beforeReport ');

END beforeReport;

BEGIN
   g_log_level      := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   g_log_enabled    := fnd_log.test
                       (log_level  => g_log_level
                       ,MODULE     => C_DEFAULT_MODULE);

   IF NOT g_log_enabled  THEN
      g_log_level := C_LEVEL_LOG_DISABLED;
   END IF;

END xla_period_close_exp_pkg;

/
