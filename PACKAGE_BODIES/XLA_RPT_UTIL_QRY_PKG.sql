--------------------------------------------------------
--  DDL for Package Body XLA_RPT_UTIL_QRY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_RPT_UTIL_QRY_PKG" AS
-- $Header: xlarput2.pkb 120.1.12010000.1 2009/11/10 23:46:11 nksurana noship $
/*===========================================================================+
|  Copyright (c) 2003 Oracle Corporation BelmFont, California, USA           |
|                          ALL rights reserved.                              |
+============================================================================+
| FILENAME                                                                   |
|    xlarput2.pkb                                                            |
|                                                                            |
| PACKAGE NAME                                                               |
|     xla_rpt_util_qry_pkg                                                   |
|                                                                            |
| DESCRIPTION                                                                |
|     Package body. This calls the various Application/Report  specific      |
|     hooks to get their Custom Query for SLA wrapper Reports.               |
| HISTORY                                                                    |
|     08/13/2009  nksurana       Created                                     |
|                                                                            |
+===========================================================================*/
--
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
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240):= 'xla.plsql.xla_rpt_util_qry_pkg';

g_log_level           NUMBER;
g_log_enabled         BOOLEAN;

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
         (p_location   => 'xla_rpt_util_qry_pkg.trace');
END trace;

--=============================================================================
--               *********** Custom Query Routine **********
--=============================================================================
PROCEDURE get_custom_query(p_application_id      IN  NUMBER,
                           p_custom_query_flag   IN  VARCHAR2,
                           p_custom_header_query OUT NOCOPY VARCHAR2,
                           p_custom_line_query   OUT NOCOPY VARCHAR2) IS

l_log_module               VARCHAR2(240);
l_component_name           VARCHAR2(30);
l_custom_header_query      VARCHAR2(32000);
l_custom_line_query        VARCHAR2(32000);

BEGIN

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.get_custom_query';
   END IF;
   --
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of get_custom_query'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg   => 'Concurrent Request Id = '||FND_GLOBAL.CONC_REQUEST_ID
         ,p_level => C_LEVEL_STATEMENT
         ,p_module=> l_log_module );
   END IF;

   BEGIN
   	select fac.component_name
   	into l_component_name
   	from fnd_concurrent_requests fcr,fnd_app_components_vl fac
   	where fcr.request_id = FND_GLOBAL.CONC_REQUEST_ID
    	  and fcr.concurrent_program_id = fac.component_id;
   EXCEPTION
   	when others then
	IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      	   trace
             (p_msg   => 'Could not find the Component Name for Request Id : '||FND_GLOBAL.CONC_REQUEST_ID
             ,p_level => C_LEVEL_STATEMENT
             ,p_module=> l_log_module );
	END IF;
   END;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg   => 'p_component_name = '||l_component_name
         ,p_level => C_LEVEL_STATEMENT
         ,p_module=> l_log_module );

       trace
         (p_msg   => 'p_custom_query_flag = '||p_custom_query_flag
         ,p_level => C_LEVEL_STATEMENT
         ,p_module=> l_log_module );

   END IF;

   case
    when l_component_name like 'AP%' then
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg   => 'Calling Payables hook'
         ,p_level => C_LEVEL_STATEMENT
         ,p_module=> l_log_module );
      END IF;

      null;
    when l_component_name like 'AR%' then
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg   => 'Calling Receivables hook'
         ,p_level => C_LEVEL_STATEMENT
         ,p_module=> l_log_module );
      END IF;

      AR_XLA_REPORTS_PKG.JE_REPORT_HOOK
              ( p_application_id      => p_application_id
               ,p_component_name      => l_component_name
               ,p_custom_query_flag   => p_custom_query_flag
               ,p_custom_header_query => l_custom_header_query
               ,p_custom_line_query   => l_custom_line_query) ;
    when l_component_name like 'CLA%' then
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg   => 'Calling APAC Consulting Localizations hook'
         ,p_level => C_LEVEL_STATEMENT
         ,p_module=> l_log_module );
      END IF;

      null;
    when l_component_name like 'CLE%' then
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg   => 'Calling EMEA Consulting Localizations hook'
         ,p_level => C_LEVEL_STATEMENT
         ,p_module=> l_log_module );
      END IF;

      null;
    when l_component_name like 'CST%' then
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg   => 'Calling Cost Management hook'
         ,p_level => C_LEVEL_STATEMENT
         ,p_module=> l_log_module );
      END IF;

      null;
    when l_component_name like 'JG%' then
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg   => 'Calling Regional Localizations hook'
         ,p_level => C_LEVEL_STATEMENT
         ,p_module=> l_log_module );
      END IF;

      null;
    when l_component_name like 'XLA%' then
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg   => 'Calling Subledger Accounting hook'
         ,p_level => C_LEVEL_STATEMENT
         ,p_module=> l_log_module );
      END IF;

      null;
    else   null;
   end case;

p_custom_header_query  := l_custom_header_query;
p_custom_line_query    := l_custom_line_query;

 IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
       (p_msg      => 'END of get_custom_query'
       ,p_level    => C_LEVEL_PROCEDURE
       ,p_module   => l_log_module);
 END IF;

EXCEPTION
   WHEN OTHERS                                   THEN
     fnd_file.put_line(fnd_file.LOG,'The hook for Component : '
                                     ||l_component_name
                                     ||' is erroneous.'
                                     ||'Continuing without any custom query.');

END get_custom_query;


BEGIN

   g_log_level      := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   g_log_enabled    := fnd_log.test
                          (log_level  => g_log_level
                          ,MODULE     => C_DEFAULT_MODULE);

   IF NOT g_log_enabled  THEN
      g_log_level := C_LEVEL_LOG_DISABLED;
   END IF;

END xla_rpt_util_qry_pkg;

/
