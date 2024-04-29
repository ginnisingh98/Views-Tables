--------------------------------------------------------
--  DDL for Package Body XLA_ACCOUNTING_DUMP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_ACCOUNTING_DUMP_PKG" AS
-- $Header: xlaapdmp.pkb 120.5 2008/01/17 12:23:27 kapkumar ship $
/*===========================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| PACKAGE NAME                                                               |
|     xla_accounting_dump_pkg                                                |
|                                                                            |
| DESCRIPTION                                                                |
|     Package Body for the Accounting Program Disgnostics.                   |
|                                                                            |
| HISTORY                                                                    |
|     24/08/2004     K. Boussema     Created                                 |
|     11/09/2004     K. Boussema     Reviewed to include data model changes  |
|     20/12/2004     K. Boussema     Reviewed the purge                      |
+===========================================================================*/

--=============================================================================
--           ****************  declaraions  ********************
--=============================================================================
-------------------------------------------------------------------------------
-- declaring private constants
-------------------------------------------------------------------------------
C_MAXSIZE                    CONSTANT NUMBER        := 4000;
C_HEADER                     CONSTANT VARCHAR2(30) := 'HEADER'       ;
C_MLS_HEADER                 CONSTANT VARCHAR2(30) := 'HEADER_MLS'   ;
C_LINE                       CONSTANT VARCHAR2(30) := 'LINE'         ;
C_BC_LINE                    CONSTANT VARCHAR2(30) := 'LINE_BASE_CUR';
C_MLS_LINE                   CONSTANT VARCHAR2(30) := 'LINE_MLS'     ;


C_CHR_NEWLINE                CONSTANT VARCHAR2(10):= xla_environment_pkg.g_chr_newline;

-------------------------------------------------------------------------------
-- declaring private structures
-------------------------------------------------------------------------------
TYPE t_array_number      IS TABLE OF NUMBER            INDEX BY BINARY_INTEGER;
TYPE t_array_date        IS TABLE OF DATE              INDEX BY BINARY_INTEGER;
TYPE t_array_char4000    IS TABLE OF VARCHAR2(4000)    INDEX BY BINARY_INTEGER;
TYPE t_array_char2000    IS TABLE OF VARCHAR2(2000)    INDEX BY BINARY_INTEGER;
TYPE t_array_char200     IS TABLE OF VARCHAR2(200)     INDEX BY BINARY_INTEGER;
TYPE t_array_char240     IS TABLE OF VARCHAR2(240)     INDEX BY BINARY_INTEGER;
TYPE t_array_char80      IS TABLE OF VARCHAR2(80)      INDEX BY BINARY_INTEGER;
TYPE t_array_char30      IS TABLE OF VARCHAR2(30)      INDEX BY BINARY_INTEGER;
TYPE t_array_char1       IS TABLE OF VARCHAR2(1)       INDEX BY BINARY_INTEGER;

TYPE r_diagnostic_event IS RECORD
   ( event_id                    t_array_number
   , primary_ledger_id           t_array_number
   , ledger_id                   t_array_number
   , ledger_name                 t_array_char80
   , transaction_number          t_array_char240
   , event_number                t_array_number
   , event_date                  t_array_date
   , entity_code                 t_array_char30
   , event_class_code            t_array_char30
   , event_type_code             t_array_char30
   , event_class_name            t_array_char80
   , event_type_name             t_array_char80
   , reference_num_1             t_array_number
   , reference_num_2             t_array_number
   , reference_num_3             t_array_number
   , reference_num_4             t_array_number
   , reference_char_1            t_array_char240
   , reference_char_2            t_array_char240
   , reference_char_3            t_array_char240
   , reference_char_4            t_array_char240
   , reference_date_1            t_array_date
   , reference_date_2            t_array_date
   , reference_date_3            t_array_date
   , reference_date_4            t_array_date
   );


-------------------------------------------------------------------------------
-- declaring private variables
-------------------------------------------------------------------------------
--
-- parametrers
--
g_application_id               PLS_INTEGER;
g_primary_ledger_id            PLS_INTEGER;
g_transaction_number           VARCHAR2(240);
g_event_number                 NUMBER;
g_event_type_code              VARCHAR2(30);
g_event_class_code             VARCHAR2(30);
g_entity_code                  VARCHAR2(30);
g_request_id                   NUMBER;
g_from_line_number             NUMBER;
g_to_line_number               NUMBER;
g_errors_only                  VARCHAR2(1);
g_source_name                  VARCHAR2(1);
g_acctg_attribute              VARCHAR2(1);

g_array_events                 r_diagnostic_event;

g_html_file                    t_array_char4000;
-------------------------------------------------------------------------------
-- forward declarion of private procedures and functions
-------------------------------------------------------------------------------


PROCEDURE write_html_file
       (p_msg                        IN VARCHAR2)
;

PROCEDURE write_fnd_log_attachment
;

PROCEDURE write_output
;

PROCEDURE write_logfile
       (p_msg                        IN VARCHAR2)
;

PROCEDURE write_title
;

PROCEDURE write_header
;

PROCEDURE write_footer
;

PROCEDURE write_warning_msg(
   p_appli_s_name                 IN  VARCHAR2
  ,p_msg_name                     IN  VARCHAR2
  ,p_token_1                      IN  VARCHAR2
  ,p_value_1                      IN  VARCHAR2
  ,p_token_2                      IN  VARCHAR2
  ,p_value_2                      IN  VARCHAR2
  ,p_token_3                      IN  VARCHAR2
  ,p_value_3                      IN  VARCHAR2
);

PROCEDURE initialize
       (p_application_id             IN NUMBER
       ,p_ledger_id                  IN NUMBER
       ,p_event_class_code           IN VARCHAR2
       ,p_event_type_code            IN VARCHAR2
       ,p_transaction_number         IN VARCHAR2
       ,p_event_number               IN NUMBER
       ,p_from_line_number           IN NUMBER
       ,p_to_line_number             IN NUMBER
       ,p_request_id                 IN NUMBER
       ,p_errors_only                IN VARCHAR2
       ,p_source_name                IN VARCHAR2
       ,p_acctg_attribute            IN VARCHAR2)
;

PROCEDURE get_diagnostic_events
;


PROCEDURE dump_diagnostic_events
;

PROCEDURE dump_diagnostic_Ledgers
;

PROCEDURE dump_transaction_objects(
                                 p_event_id         IN NUMBER
                               , p_ledger_id        IN NUMBER
                               , p_ledger_name      IN VARCHAR2
                               );

PROCEDURE dump_diagnostic_sources
;

PROCEDURE dump_source_names (  p_event_id          IN NUMBER
                             , p_ledger_id         IN NUMBER
                             , p_ledger_name       IN VARCHAR2
                             , p_object_name       IN VARCHAR2
                             , p_object_type_code  IN VARCHAR2
                               )
;

PROCEDURE dump_source_values ( p_event_id                 IN NUMBER
                             , p_ledger_id                IN NUMBER
                             , p_ledger_name              IN VARCHAR2
                             , p_object_name              IN VARCHAR2
                             , p_object_type_code         IN VARCHAR2
                             )
;

PROCEDURE dump_acctg_attributes(  p_event_id         IN NUMBER
                                , p_ledger_id        IN NUMBER
                                , p_ledger_name      IN VARCHAR2
                               )
;

PROCEDURE dump_hdr_attributes(    p_event_id         IN NUMBER
                                , p_ledger_id        IN NUMBER
                                , p_ledger_name      IN VARCHAR2
                               )
;

PROCEDURE dump_line_attributes(   p_event_id         IN NUMBER
                                , p_ledger_id        IN NUMBER
                                , p_ledger_name      IN VARCHAR2
                               )
;
--=============================================================================
--               *********** Local Trace Routine **********
--=============================================================================

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
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.xla_accounting_dump_pkg';

g_log_level           NUMBER;
g_log_enabled         BOOLEAN;

PROCEDURE trace
           (p_msg                        IN VARCHAR2
           ,p_level                      IN NUMBER
           ,p_module                     IN VARCHAR2 )
IS
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
             (p_location   => 'XLA_CMP_EVENT_TYPE_PKG.trace');
END trace;


/*======================================================================+
|                                                                       |
| Private Procedure                                                     |
|                                                                       |
| write_fnd_log_attachment                                              |
|                                                                       |
|                                                                       |
+======================================================================*/
PROCEDURE write_fnd_log_attachment
IS
l_log_module                      VARCHAR2(240);
l_attachment_id                   NUMBER;
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.write_fnd_log_attachment';
END IF;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of procedure write_fnd_log_attachment'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

IF (C_LEVEL_STATEMENT  >= g_log_level) THEN

   trace
         (p_msg      => 'number of lines to write in fnd logfile ='||g_html_file.COUNT
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

   trace
         (p_msg      => 'Call fnd_log.message_with_attachment API'
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
END IF;

IF (C_LEVEL_UNEXPECTED  >= g_log_level) THEN

   FND_MESSAGE.SET_NAME('XLA','XLA_DIAGNOSTICS_OUTPUT');

   l_attachment_id:= FND_LOG.MESSAGE_WITH_ATTACHMENT(
                         C_LEVEL_UNEXPECTED,
                         l_log_module,
                         TRUE,
                        'ascii',
                        'text/html',
                         NULL,
                         NULL,
                         'html',
                         'Accounting Event Extract Diagnostics Output'
                         );

ELSE

  l_attachment_id := -1;

END IF;

IF (C_LEVEL_STATEMENT  >= g_log_level) THEN

   trace
        (p_msg      => 'l_attachment_id ='||l_attachment_id
        ,p_level    => C_LEVEL_STATEMENT
        ,p_module   => l_log_module);

END IF;

IF l_attachment_id <> -1 AND g_html_file.COUNT > 0 THEN

       IF (C_LEVEL_STATEMENT  >= g_log_level) THEN
         trace
         (p_msg      => 'Call FND_LOG_ATTACHMENT.WRITE() API'
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
       END IF;


      FOR Idx IN g_html_file.FIRST .. g_html_file.LAST LOOP

         IF g_html_file.EXISTS(Idx) AND g_html_file(Idx) IS NOT NULL THEN

            FND_LOG_ATTACHMENT.WRITE(l_attachment_id,g_html_file(Idx));

         END IF;

      END LOOP;

      IF (C_LEVEL_STATEMENT  >= g_log_level) THEN
         trace
         (p_msg      => 'Call FND_LOG_ATTACHMENT.CLOSE()'
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
       END IF;

      FND_LOG_ATTACHMENT.CLOSE(l_attachment_id);

END IF;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of procedure write_fnd_log_attachment'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
         (p_location   => 'xla_accounting_dump_pkg.write_fnd_log_attachment');
END write_fnd_log_attachment;

--=============================================================================
--               *********** Concurrent Program routines **********
--=============================================================================

/*======================================================================+
|                                                                       |
| Private Procedure                                                     |
|                                                                       |
| write_logfile                                                         |
|                                                                       |
| Printer the string in fnd log file                                    |
|                                                                       |
+======================================================================*/
PROCEDURE write_logfile
       (p_msg                        IN VARCHAR2) IS
BEGIN

   fnd_file.put_line(fnd_file.log,p_msg);

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
         (p_location   => 'xla_accounting_dump_pkg.write_logfile');
END write_logfile;

/*======================================================================+
|                                                                       |
| Private Procedure                                                     |
|                                                                       |
| write_output                                                          |
|                                                                       |
| Printer the string in fnd output file                                 |
|                                                                       |
+======================================================================*/
PROCEDURE write_output IS
l_log_module                      VARCHAR2(240);
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.write_output';
END IF;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of procedure write_output'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;

IF g_html_file.COUNT > 0 THEN

     FOR Idx IN g_html_file.FIRST .. g_html_file.LAST LOOP

         IF g_html_file.EXISTS(Idx) AND g_html_file(Idx) IS NOT NULL THEN

            fnd_file.put_line(fnd_file.output,g_html_file(Idx));

         END IF;

      END LOOP;

END IF;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of procedure write_output'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
         (p_location   => 'xla_accounting_dump_pkg.write_output');
END write_output;


/*======================================================================+
|                                                                       |
| Private Procedure                                                     |
|                                                                       |
| write_html_file                                                       |
|                                                                       |
| Printer the string in fnd output file                                 |
|                                                                       |
+======================================================================*/
PROCEDURE write_html_file
       (p_msg                        IN VARCHAR2) IS
BEGIN

   g_html_file(NVL(g_html_file.LAST,0) +1 ):= SUBSTR(p_msg,1,C_MAXSIZE);

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
         (p_location   => 'xla_accounting_dump_pkg.write_html_file');
END write_html_file;

--=============================================================================
--          *********** Accounting Program Diagnostics routine **********
--=============================================================================


/*======================================================================+
|                                                                       |
| Private Procedure                                                     |
|                                                                       |
| write_title                                                           |
|                                                                       |
| Printer the title                                                     |
|                                                                       |
+======================================================================*/
PROCEDURE write_title
IS
l_log_module                      VARCHAR2(240);
l_request_id                      NUMBER;
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.write_title';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of procedure write_title'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   l_request_id                := fnd_global.conc_request_id();
   write_html_file('<html>');
   write_html_file('<head>');
   write_html_file('<title> Accounting Program Diagnostics ( request id: '||l_request_id||')</title>');
   write_html_file('</head>');
   write_html_file('<body>');
   write_html_file('<h2 align="center"> Transaction Objects Diagnostic Output </h2>');
   write_html_file('<div style="text-align: center;"> Request Id '||TO_CHAR(l_request_id)
                ||' run at System time: '||TO_CHAR(sysdate,'fmDD-MON-YYYY fmHH24:MI:SS'));
   write_html_file('</div>');
   write_html_file('<br>');
   write_html_file('<br><br>');


   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of procedure write_title'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

   END IF;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_accounting_dump_pkg.write_title');
END write_title;
/*======================================================================+
|                                                                       |
| Private Procedure                                                     |
|                                                                       |
| write_header                                                          |
|                                                                       |
| Printer the standard header                                           |
|                                                                       |
+======================================================================*/
PROCEDURE write_header
IS
l_log_module                VARCHAR2(240);
l_application_name          VARCHAR2(80);
l_application_id            NUMBER;
l_ledger_name               VARCHAR2(80);
l_event_class_name          VARCHAR2(80);
l_event_type_name           VARCHAR2(80);
l_transaction_number        VARCHAR2(240);
l_event_number              VARCHAR2(80);
l_from_line_number          VARCHAR2(80);
l_to_line_number            VARCHAR2(80);
l_parent_request_id         VARCHAR2(80);
l_error_only                VARCHAR2(80);
l_source_name               VARCHAR2(80);
l_acctg_attribute           VARCHAR2(80);
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.write_header';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of procedure write_header'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;
--======================================================================
-- set local variables
--======================================================================
l_transaction_number        := g_transaction_number;
l_event_number              := TO_CHAR(g_event_number);
l_from_line_number          := TO_CHAR(g_from_line_number);
l_to_line_number            := TO_CHAR(g_to_line_number);
l_parent_request_id         := TO_CHAR(g_request_id) ;
l_error_only                := g_errors_only;
l_source_name               := g_source_name;
l_acctg_attribute           := g_acctg_attribute ;

BEGIN
--
--
--
 SELECT DISTINCT
       a.application_id                                         application_id
     , nvl(a2.application_name, TO_CHAR(g_application_id))      application_name
     , nvl(b.name,TO_CHAR(g_primary_ledger_id))                 ledger_name
     , nvl(d.name,g_event_class_code )                          event_class_name
     , nvl(e.name,g_event_type_code)                            event_type_name
 INTO  l_application_id
    ,  l_application_name
    ,  l_ledger_name
    ,  l_event_class_name
    ,  l_event_type_name
 FROM  fnd_application_tl      a
     , fnd_application_tl      a2
     , xla_subledger_options_v b
     , xla_event_classes_tl    d
     , xla_event_types_tl      e
 WHERE a.application_id      = g_application_id
   AND a2.application_id  (+)= a.application_id
   AND a2.language        (+)= USERENV('LANG')
   AND b.ledger_id        (+)= nvl(g_primary_ledger_id,-99)
   AND b.application_id   (+)= a.application_id
   AND d.entity_code      (+)= nvl(g_entity_code,'#')
   AND d.event_class_code (+)= nvl(g_event_class_code,'#')
   AND d.application_id   (+)= a.application_id
   AND d.language         (+)= USERENV('LANG')
   AND e.entity_code      (+)= nvl(g_entity_code,'#')
   AND e.event_class_code (+)= nvl(g_event_class_code,'#')
   AND e.event_type_code  (+)= nvl(g_event_type_code,'#')
   AND e.application_id   (+)= a.application_id
   AND e.language         (+)= USERENV('LANG')
;


EXCEPTION

  WHEN OTHERS THEN

    l_application_name := TO_CHAR(g_application_id);
    l_ledger_name      := TO_CHAR(g_primary_ledger_id);
    l_event_class_name := g_event_class_code;
    l_event_type_name  := g_event_type_code;

END;


BEGIN

  SELECT x1.meaning ,
         x2.meaning ,
         x3.meaning
    INTO l_error_only         ,
         l_source_name        ,
         l_acctg_attribute
    FROM XLA_LOOKUPS x1,
         XLA_LOOKUPS x2,
         XLA_LOOKUPS x3
   WHERE x1.lookup_type = 'XLA_YES_NO'
     and x1.lookup_type = x2.lookup_type
     and x1.lookup_type = x3.lookup_type
     and x1.lookup_code = g_errors_only
     and x2.lookup_code = g_source_name
     and x3.lookup_code = g_acctg_attribute
    ;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    l_error_only        :=   g_errors_only;
    l_source_name       :=   g_acctg_attribute;
    l_acctg_attribute   :=   g_source_name;
  WHEN OTHERS THEN
    l_error_only        :=   g_errors_only;
    l_source_name       :=   g_acctg_attribute;
    l_acctg_attribute   :=   g_source_name;
END;


   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'Write Search criteria'
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
   END IF;

   write_html_file('<b> Search Criteria </b>');
   write_html_file('<br><br>');
   write_html_file('<table border="0"><tbody>');

   write_html_file('<tr style="background-color: #cccc99">');
   write_html_file('<th style="text-align: left;"> Application Name </th>');
   write_html_file('<td style="background-color: #f7f7e7" valign="top">'||l_application_name||'</td>');
   write_html_file('</tr>');

   write_html_file('<tr style="background-color: #cccc99">');
   write_html_file('<th style="text-align: left;"> Ledger Name </th>');
   write_html_file('<td style="background-color: #f7f7e7" valign="top">'||l_ledger_name||'</td>');
   write_html_file('</tr>');

   write_html_file('<tr style="background-color: #cccc99">');
   write_html_file('<th style="text-align: left;"> Event Class Name </th>');
   write_html_file('<td style="background-color: #f7f7e7" valign="top">'||l_event_class_name||'</td>');
   write_html_file('</tr>');

   write_html_file('<tr style="background-color: #cccc99">');
   write_html_file('<th style="text-align: left;"> Event Type Name </th>');
   write_html_file('<td style="background-color: #f7f7e7" valign="top">'||l_event_type_name||'</td>');
   write_html_file('</tr>');

   write_html_file('<tr style="background-color: #cccc99">');
   write_html_file('<th style="text-align: left;"> Transaction number </th>');
   write_html_file('<td style="background-color: #f7f7e7" valign="top">'||l_transaction_number||'</td>');
   write_html_file('</tr>');

   write_html_file('<tr style="background-color: #cccc99">');
   write_html_file('<th style="text-align: left;"> Event Number </th>');
   write_html_file('<td style="background-color: #f7f7e7" valign="top">'||l_event_number||'</td>');
   write_html_file('</tr>');

   write_html_file('<tr style="background-color: #cccc99">');
   write_html_file('<th style="text-align: left;"> From Distribution Line Number </th>');
   write_html_file('<td style="background-color: #f7f7e7" valign="top">'||l_from_line_number||'</td>');
   write_html_file('</tr>');

   write_html_file('<tr style="background-color: #cccc99">');
   write_html_file('<th style="text-align: left;"> To Distribution Line Number </th>');
   write_html_file('<td style="background-color: #f7f7e7" valign="top">'||l_to_line_number||'</td>');
   write_html_file('</tr>');

   write_html_file('<tr style="background-color: #cccc99">');
   write_html_file('<th style="text-align: left;"> Accounting Program Request id </th>');
   write_html_file('<td style="background-color: #f7f7e7" valign="top">'||l_parent_request_id||'</td>');
   write_html_file('</tr>');

   write_html_file('<tr style="background-color: #cccc99">');
   write_html_file('<th style="text-align: left;"> Errors Only </th>');
   write_html_file('<td style="background-color: #f7f7e7" valign="top">'||l_error_only||'</td>');
   write_html_file('</tr>');

   write_html_file('<tr style="background-color: #cccc99">');
   write_html_file('<th style="text-align: left;"> Display Source Name </th>');
   write_html_file('<td style="background-color: #f7f7e7" valign="top">'||l_source_name||'</td>');
   write_html_file('</tr>');

   write_html_file('<tr style="background-color: #cccc99">');
   write_html_file('<th style="text-align: left;"> Display Accounting Attributes </th>');
   write_html_file('<td style="background-color: #f7f7e7" valign="top">'||l_acctg_attribute||'</td>');
   write_html_file('</tr>');

   write_html_file('</tbody>');
   write_html_file('</table>');

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of procedure write_header'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_accounting_dump_pkg.write_header');
END write_header;

/*======================================================================+
|                                                                       |
| Private Procedure                                                     |
|                                                                       |
| write_warning_msg                                                     |
|                                                                       |
| Printer the warnig message                                            |
|                                                                       |
+======================================================================*/
--
-- to review in order to remove the message hard coded
--
PROCEDURE write_warning_msg(
   p_appli_s_name                 IN  VARCHAR2
  ,p_msg_name                     IN  VARCHAR2
  ,p_token_1                      IN  VARCHAR2
  ,p_value_1                      IN  VARCHAR2
  ,p_token_2                      IN  VARCHAR2
  ,p_value_2                      IN  VARCHAR2
  ,p_token_3                      IN  VARCHAR2
  ,p_value_3                      IN  VARCHAR2
)
IS
l_new_line                  VARCHAR2(200);
l_tab                       VARCHAR2(200);
l_log_module                VARCHAR2(240);
l_message                   VARCHAR2(4000);
l_message_number            NUMBER;
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.write_warning_msg';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of procedure write_warning_msg'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

   END IF;
   --
   l_tab      := '&'||'nbsp;'||'&'||'nbsp;'||'&'||'nbsp;';
   l_new_line := '<br>';
   --

   fnd_message.set_name(p_appli_s_name ,p_msg_name);

   IF p_token_1 IS NOT NULL THEN fnd_message.set_token(p_token_1 ,p_value_1); END IF;

   IF p_token_2 IS NOT NULL THEN fnd_message.set_token(p_token_2,p_value_2);  END IF;

   IF p_token_3 IS NOT NULL THEN fnd_message.set_token(p_token_3,p_value_3);  END IF;

   l_message := SUBSTR(fnd_message.get,1,2000);

   l_message := REPLACE(l_message, C_CHR_NEWLINE,l_new_line || l_tab );

   write_html_file(l_new_line||l_tab);
   write_html_file(l_message);
   write_html_file('<br><br>');

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of procedure write_warning_msg'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_accounting_dump_pkg.write_warning_msg');
END write_warning_msg;

/*======================================================================+
|                                                                       |
| Private Procedure                                                     |
|                                                                       |
| write_footer                                                          |
|                                                                       |
| Printer the standard footer                                           |
|                                                                       |
+======================================================================*/
PROCEDURE write_footer
IS
l_log_module                      VARCHAR2(240);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.write_footer';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of procedure write_footer'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   write_html_file('</body>');
   write_html_file('</html>');

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of procedure write_footer'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

   END IF;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_accounting_dump_pkg.write_footer');
END write_footer;

--=============================================================================
--
--
--
--=============================================================================
PROCEDURE initialize
       (p_application_id             IN NUMBER
       ,p_ledger_id                  IN NUMBER
       ,p_event_class_code           IN VARCHAR2
       ,p_event_type_code            IN VARCHAR2
       ,p_transaction_number         IN VARCHAR2
       ,p_event_number               IN NUMBER
       ,p_from_line_number           IN NUMBER
       ,p_to_line_number             IN NUMBER
       ,p_request_id                 IN NUMBER
       ,p_errors_only                IN VARCHAR2
       ,p_source_name                IN VARCHAR2
       ,p_acctg_attribute            IN VARCHAR2) IS

l_log_module                      VARCHAR2(240);
l_array_null_events               r_diagnostic_event;
l_null_html_file                  t_array_char4000;
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.initialize';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of procedure initialize'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_application_id = '||p_application_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_ledger_id = '||p_ledger_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_event_class_code = '||p_event_class_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_event_type_code = '||p_event_type_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_transaction_number = '||p_transaction_number
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_event_number = '||p_event_number
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_from_line_number = '||p_from_line_number
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_to_line_number = '||p_to_line_number
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_request_id = '||p_request_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
         (p_msg      => 'p_errors_only = '||p_errors_only
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
         (p_msg      => 'p_source_name = '||p_source_name
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

    trace
         (p_msg      => 'p_acctg_attribute = '||p_acctg_attribute
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

   END IF;

   ----------------------------------------------------------------------------
   -- Initializing global variables
   ----------------------------------------------------------------------------

   g_application_id                  :=  p_application_id;
   g_primary_ledger_id               :=  p_ledger_id;
   g_transaction_number              :=  p_transaction_number;
   g_event_number                    :=  p_event_number;
   g_event_type_code                 :=  p_event_type_code;
   g_event_class_code                :=  p_event_class_code;
   g_entity_code                     :=  NULL;
   g_request_id                      :=  p_request_id;
   g_errors_only                     :=  p_errors_only;
   g_source_name                     :=  p_source_name;
   g_acctg_attribute                 :=  p_acctg_attribute;
   g_from_line_number                :=  p_from_line_number;
   g_to_line_number                  :=  p_to_line_number ;

   g_array_events                    := l_array_null_events;

   g_html_file                       := l_null_html_file;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of procedure initialize'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_accounting_dump_pkg.initialize');
END initialize;   -- end of procedure

--=============================================================================
--
--
--
--=============================================================================
PROCEDURE get_diagnostic_events  IS

l_log_module                      VARCHAR2(240);
l_array_null_events               r_diagnostic_event;
BEGIN

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.get_diagnostic_events';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of procedure get_diagnostic_events'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   BEGIN

     SELECT DISTINCT
            xde.event_id
           ,xde.ledger_id
           ,xde.transaction_number
           ,xde.event_number
           ,xde.entity_code
           ,xde.event_class_code
           ,xde.event_type_code
           ,xde.event_date
           ,xdl.ledger_id
           ,nvl(xsov.name,TO_CHAR(xdl.ledger_id))
           ,xe.reference_num_1
           ,xe.reference_num_2
           ,xe.reference_num_3
           ,xe.reference_num_4
           ,xe.reference_char_1
           ,xe.reference_char_2
           ,xe.reference_char_3
           ,xe.reference_char_4
           ,xe.reference_date_1
           ,xe.reference_date_2
           ,xe.reference_date_3
           ,xe.reference_date_4
           ,nvl(xect.name,xde.event_class_code )
           ,nvl(xett.name,xde.event_type_code)
       BULK COLLECT
       INTO g_array_events.event_id,
            g_array_events.primary_ledger_id,
            g_array_events.transaction_number,
            g_array_events.event_number,
            g_array_events.entity_code,
            g_array_events.event_class_code,
            g_array_events.event_type_code,
            g_array_events.event_date,
            g_array_events.ledger_id,
            g_array_events.ledger_name,
            g_array_events.reference_num_1,
            g_array_events.reference_num_2,
            g_array_events.reference_num_3,
            g_array_events.reference_num_4,
            g_array_events.reference_char_1,
            g_array_events.reference_char_2,
            g_array_events.reference_char_3,
            g_array_events.reference_char_4,
            g_array_events.reference_date_1,
            g_array_events.reference_date_2,
            g_array_events.reference_date_3,
            g_array_events.reference_date_4,
            g_array_events.event_class_name,
            g_array_events.event_type_name
       FROM xla_events              xe
          , xla_diag_events         xde
          , xla_diag_ledgers        xdl
          , xla_subledger_options_v xsov
          , xla_event_classes_tl    xect
          , xla_event_types_tl      xett
      WHERE xe.application_id      = xde.application_id
        AND xe.event_type_code     = xde.event_type_code
        AND xe.event_id            = xde.event_id
        AND xe.event_number        = xde.event_number
        AND xde.application_id     = xdl.application_id
        AND xde.ledger_id          = xdl.primary_ledger_id
        AND xde.request_id         = xdl.accounting_request_id
        AND xdl.application_id     = xsov.application_id (+)
        AND xdl.ledger_id          = xsov.ledger_id(+)
        AND xde.ledger_id          = nvl(g_primary_ledger_id,xde.ledger_id)
        AND xde.event_number       = nvl(g_event_number, xde.event_number)
        AND xde.transaction_number = nvl(g_transaction_number,xde.transaction_number)
        AND xde.event_class_code   = nvl(g_event_class_code,xde.event_class_code)
        AND xde.event_type_code    = DECODE(g_event_type_code
                                            ,NULL,xde.event_type_code
                                            ,g_event_type_code)
        AND xde.request_id             = nvl(g_request_id,xde.request_id)
        AND xe.process_status_code     = DECODE(g_errors_only,
                                             'Y', DECODE(xe.process_status_code,
                                                         'I','I',
                                                         'R','R',
                                                         'E')
                                            , xe.process_status_code)
        AND xde.application_id     = g_application_id
        AND xect.entity_code      (+)= xde.entity_code
        AND xect.event_class_code (+)= xde.event_class_code
        AND xect.application_id   (+)= xde.application_id
        AND xect.language         (+)= USERENV('LANG')
        AND xett.entity_code      (+)= xde.entity_code
        AND xett.event_class_code (+)= xde.event_class_code
        AND xett.event_type_code  (+)= xde.event_type_code
        AND xett.application_id   (+)= xde.application_id
        AND xett.language         (+)= USERENV('LANG')
      ;

  EXCEPTION

     WHEN OTHERS THEN
        g_array_events            :=l_array_null_events;
  END;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
            (p_msg      => 'number of rows retrieved = '||g_array_events.event_id.COUNT
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of procedure get_diagnostic_events'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_accounting_dump_pkg.get_diagnostic_events');
END get_diagnostic_events;   -- end of procedure

 --
/*======================================================================+
|                                                                       |
| Private Procedure                                                     |
|                                                                       |
| dump_diagnostic_events                                                |
|                                                                       |
|                                                                       |
+======================================================================*/
PROCEDURE dump_diagnostic_events
IS
l_log_module                VARCHAR2(240);
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.dump_diagnostic_events';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of procedure dump_diagnostic_events'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   write_html_file('<a NAME=getreturntothetop></a>');
   write_html_file('<br>');
   write_html_file('<b> Search Results </b>');
   write_html_file('<br><br>');
   write_html_file('<table border="0"><tbody>');
   write_html_file('<tr style="background-color: #cccc99">');
   write_html_file('<th> Event id </th>');
   write_html_file('<th> Ledger </th>');
   write_html_file('<th> Ledger Id </th>');
   write_html_file('<th> Transaction number </th>');
   write_html_file('<th> Event Number </th>');
   write_html_file('<th> Event Class Name</th>');
   write_html_file('<th> Event Type Name </th>');
   write_html_file('<th> Event Date </th>');
   write_html_file('</tr>');

FOR event_cur IN (

SELECT DISTINCT
         xde.event_id                                       event_id
       , xde.event_number                                   event_number
       , xde.event_date                                     event_date
       , xde.transaction_number                             transaction_number
       , xde.ledger_id                                      ledger_id
       , nvl(xsov.name,TO_CHAR(xde.ledger_id))              ledger_name
       , xde.entity_code                                    entity_code
       , nvl(xecv.name,xde.event_class_code )               event_class_name
       , xde.event_class_code                               event_class_code
       , nvl(xtv.name,xde.event_type_code)                  event_type_name
       , xde.event_type_code                                event_type_code
  FROM xla_events              xe
     , xla_diag_events         xde
     , xla_subledger_options_v xsov
     , xla_event_classes_tl    xecv
     , xla_event_types_tl      xtv
 WHERE xe.application_id         = xde.application_id
   AND xe.event_type_code        = xde.event_type_code
   AND xe.event_id               = xde.event_id
   AND xe.event_number           = xde.event_number
   AND xde.ledger_id             = nvl(g_primary_ledger_id,xde.ledger_id)
   AND xsov.ledger_id         (+)= xde.ledger_id
   AND xsov.application_id    (+)= xde.application_id
   AND xde.event_number          = nvl(g_event_number, xde.event_number)
   AND xde.transaction_number    = nvl(g_transaction_number,xde.transaction_number)
   AND xde.event_class_code      = nvl(g_event_class_code,xde.event_class_code)
   AND xecv.entity_code       (+)= xde.entity_code
   AND xecv.event_class_code  (+)= xde.event_class_code
   AND xecv.application_id    (+)= xde.application_id
   AND xecv.language          (+)= USERENV('LANG')
   AND xde.event_type_code       = DECODE(g_event_type_code
                                            ,NULL,xde.event_type_code
                                            ,xde.event_class_code||'_ALL',xde.event_type_code
                                            ,g_event_type_code)
   AND xtv.entity_code        (+)= xde.entity_code
   AND xtv.event_class_code   (+)= xde.event_class_code
   AND xtv.event_type_code    (+)= xde.event_type_code
   AND xtv.application_id     (+)= xde.application_id
   AND xtv.language           (+)= USERENV('LANG')
   AND xde.request_id             = nvl(g_request_id,xde.request_id)
   AND xe.process_status_code     = DECODE(g_errors_only,
                                             'Y', DECODE(xe.process_status_code,
                                                         'I','I',
                                                         'R','R',
                                                         'E')
                                            , xe.process_status_code)
   AND xde.application_id        = g_application_id
)

LOOP


   write_html_file('<tr style="background-color: #f7f7e7" valign="top">');
   write_html_file('<td><a href="#get'||TO_CHAR(event_cur.event_id)||'">'||TO_CHAR(event_cur.event_id)||'</a></td>');
   write_html_file('<td>'||event_cur.ledger_name||'</td>');
   write_html_file('<td style="text-align: right;">'||TO_CHAR(event_cur.ledger_id)||'</td>');
   write_html_file('<td>'||event_cur.transaction_number||'</td>');
   write_html_file('<td style="text-align: right;">'||TO_CHAR(event_cur.event_number) ||'</td>');
   write_html_file('<td>'||event_cur.event_class_name||'</td>');
   write_html_file('<td>'||event_cur.event_type_name||'</td>');
   write_html_file('<td>'||TO_CHAR(event_cur.event_date)||'</td>');
   write_html_file('</tr>');


END LOOP;

   write_html_file('</tbody>');
   write_html_file('</table>');
   write_html_file('<a href=#getreturntothetop>Return to the top</a>');
   write_html_file('<br><br>');


   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of procedure dump_diagnostic_events'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_accounting_dump_pkg.dump_diagnostic_events');
END dump_diagnostic_events;


/*======================================================================+
|                                                                       |
| Private Procedure                                                     |
|                                                                       |
| dump_diagnostic_Ledgers                                               |
|                                                                       |
|                                                                       |
+======================================================================*/
PROCEDURE dump_diagnostic_Ledgers
IS
l_log_module                VARCHAR2(240);
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.dump_diagnostic_Ledgers';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of procedure dump_diagnostic_Ledgers'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   write_html_file('<b> Ledger information </b>');
   write_html_file('<br><br>');
   write_html_file('<table border="0"><tbody>');
   write_html_file('<tr style="background-color: #cccc99">');
   write_html_file('<th> Ledger </th>');
   write_html_file('<th> Ledger Id</th>');
   write_html_file('<th> Primary Ledger </th>');
   write_html_file('<th> Primary Ledger Id</th>');
   write_html_file('<th> SLA ledger </th>');
   write_html_file('<th> SLA ledger Id</th>');
   write_html_file('<th> Description Language </th>');
   write_html_file('<th> Currency Code </th>');
   write_html_file('<th> Accounting Application Definition </th>');
   write_html_file('<th> Accounting Application Definition Owner</th>');
   write_html_file('<th> AMB Context code </th>');
   write_html_file('<th> Start Date Active</th>');
   write_html_file('<th> End Date Active </th>');
   write_html_file('</tr>');


FOR ledger_cur IN ( SELECT DISTINCT
                          xdl.ledger_id                                      ledger_id
                        , xdl.primary_ledger_id                              primary_ledger_id
                        , xdl.sla_ledger_id                                  sla_ledger_id
                        , nvl(xso1.name,TO_CHAR(xdl.ledger_id))              ledger_name
                        , nvl(xso2.name,TO_CHAR(xdl.primary_ledger_id))      primary_ledger_name
                        , nvl(xso3.name,TO_CHAR(xdl.sla_ledger_id))          sla_ledger_name
                        , xdl.description_language                           description_language
                        , xdl.currency_code                                  currency_code
                        , nvl(xpr.name,xpr.product_rule_code)                aad_name
                        , xdl.product_rule_code                              aad_code
                        , xdl.product_rule_type_code                         aad_owner
                        , xdl.amb_context_code                               amb_context
                        , xdl.start_date_active                              start_date
                        , xdl.end_date_active                                end_date
 FROM  xla_events              xe
     , xla_diag_events      xde
     , xla_diag_ledgers     xdl
     , xla_subledger_options_v xso1
     , xla_subledger_options_v xso2
     , xla_subledger_options_v xso3
     , xla_product_rules_tl    xpr
 WHERE xe.application_id             = xde.application_id
   AND xe.event_id                   = xde.event_id
   AND xe.event_type_code            = xde.event_type_code
   AND xe.event_number               = xde.event_number
   AND xde.application_id            = xdl.application_id
   AND xde.ledger_id                 = xdl.primary_ledger_id
   AND xde.request_id                = xdl.accounting_request_id
   AND xdl.primary_ledger_id         = nvl(g_primary_ledger_id,xdl.primary_ledger_id)
   AND xpr.application_id         (+)= xdl.application_id
   AND xpr.product_rule_code      (+)= xdl.product_rule_code
   AND xpr.product_rule_type_code (+)= xdl.product_rule_type_code
   AND xpr.amb_context_code       (+)= xdl.amb_context_code
   AND xso1.ledger_id             (+)= xdl.ledger_id
   AND xso1.application_id        (+)= xdl.application_id
   AND xso2.ledger_id             (+)= xdl.primary_ledger_id
   AND xso2.application_id        (+)= xdl.application_id
   AND xso3.ledger_id             (+)= xdl.sla_ledger_id
   AND xso3.application_id        (+)= xdl.application_id
   AND xde.event_number              = nvl(g_event_number, xde.event_number)
   AND xde.transaction_number        = nvl(g_transaction_number,xde.transaction_number)
   AND xde.event_class_code          = nvl(g_event_class_code,xde.event_class_code)
   AND xde.event_type_code           = DECODE(g_event_type_code
                                            ,NULL,xde.event_type_code
                                            ,xde.event_class_code||'_ALL',xde.event_type_code
                                            ,g_event_type_code)
   AND xde.request_id                = nvl(g_request_id,xde.request_id)
   AND xe.process_status_code        = DECODE(g_errors_only,
                                             'Y', DECODE(xe.process_status_code,
                                                         'I','I',
                                                         'R','R',
                                                         'E')
                                            , xe.process_status_code)
   AND xde.application_id            = g_application_id
)

LOOP

   write_html_file('<tr style="background-color: #f7f7e7" valign="top">');
   write_html_file('<td>'||ledger_cur.ledger_name||'</td>');
   write_html_file('<td style="text-align: right;"><a NAME=get'||TO_CHAR(ledger_cur.ledger_id)||'>'||TO_CHAR(ledger_cur.ledger_id)||'</a></td>');
   write_html_file('<td>'||ledger_cur.primary_ledger_name||'</td>');
   write_html_file('<td style="text-align: right;">'||TO_CHAR(ledger_cur.primary_ledger_id)||'</td>');
   write_html_file('<td>'||ledger_cur.sla_ledger_name ||'</td>');
   write_html_file('<td style="text-align: right;">'||TO_CHAR(ledger_cur.sla_ledger_id)||'</td>');
   write_html_file('<td>'||ledger_cur.description_language||'</td>');
   write_html_file('<td>'||ledger_cur.currency_code||'</td>');
   write_html_file('<td>'||ledger_cur.aad_name||'</td>');
   write_html_file('<td>'||xla_lookups_pkg.get_meaning(
                               'XLA_OWNER_TYPE',
                                ledger_cur.aad_owner)||'</td>');
   write_html_file('<td>'||ledger_cur.amb_context||'</td>');
   write_html_file('<td>'||ledger_cur.start_date||'</td>');
   write_html_file('<td>'||ledger_cur.end_date||'</td>');
   write_html_file('</tr>');



END LOOP;

   write_html_file('</tbody>');
   write_html_file('</table>');
   write_html_file('<a href=#getreturntothetop>Return to the top</a>');
   write_html_file('<br><br>');

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of procedure dump_diagnostic_Ledgers'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_accounting_dump_pkg.dump_diagnostic_Ledgers');
END dump_diagnostic_Ledgers;

/*======================================================================+
|                                                                       |
| Private Procedure                                                     |
|                                                                       |
| dump_diagnostic_sources                                               |
|                                                                       |
|                                                                       |
+======================================================================*/
PROCEDURE dump_diagnostic_sources
IS
l_log_module                VARCHAR2(240);
l_event_id                  NUMBER;
l_transaction_id            NUMBER;

l_transction_id_col_name    t_array_char30;



BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.dump_diagnostic_sources';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of procedure dump_diagnostic_sources'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   l_event_id:= -1;

   FOR Idx IN g_array_events.event_id.FIRST .. g_array_events.event_id.LAST LOOP

        IF g_array_events.event_id.EXISTS(Idx) AND
           g_array_events.event_id(Idx) IS NOT NULL AND
           g_array_events.event_id(Idx) <> l_event_id THEN

           l_event_id:= g_array_events.event_id(Idx);
          --

          write_html_file('<a NAME=get'||TO_CHAR(g_array_events.event_id(Idx))||'></a><b> Transaction Objects Diagnostics For </b>');
          write_html_file('<br><br>');
          write_html_file('<table border="0"><tbody>');
          write_html_file('<tr style="background-color: #cccc99">');
          write_html_file('<th style="text-align: left;"> Transaction number </th>');
          write_html_file('<td style="background-color: #f7f7e7" valign="top">'
                           ||g_array_events.transaction_number(Idx)||'</td>');
          write_html_file('</tr>');

          write_html_file('<tr style="background-color: #cccc99">');
          write_html_file('<th style="text-align: left;"> Event Id </th>');
          write_html_file('<td style="background-color: #f7f7e7" valign="top"text-align: right;">'
                           ||TO_CHAR(g_array_events.event_id(Idx))||'</td>');
          write_html_file('</tr>');

          write_html_file('<tr style="background-color: #cccc99">');
          write_html_file('<th style="text-align: left;"> Event Number </th>');
          write_html_file('<td style="background-color: #f7f7e7" valign="top"text-align: right;">'
                            ||TO_CHAR(g_array_events.event_number(Idx))||'</td>');
          write_html_file('</tr>');


          write_html_file('<tr style="background-color: #cccc99">');
          write_html_file('<th style="text-align: left;"> Event Date </th>');
          write_html_file('<td style="background-color: #f7f7e7" valign="top">'
                            ||TO_CHAR(g_array_events.event_date(Idx))||'</td>');
          write_html_file('</tr>');

          write_html_file('<tr style="background-color: #cccc99">');
          write_html_file('<th style="text-align: left;"> Event Class Name </th>');
          write_html_file('<td style="background-color: #f7f7e7" valign="top">'
                         ||g_array_events.event_class_name(Idx)||'</td>');
          write_html_file('</tr>');

          write_html_file('<tr style="background-color: #cccc99">');
          write_html_file('<th style="text-align: left;"> Event Class Code </th>');
          write_html_file('<td style="background-color: #f7f7e7" valign="top">'
                         ||g_array_events.event_class_code(Idx)||'</td>');
          write_html_file('</tr>');

          write_html_file('<tr style="background-color: #cccc99">');
          write_html_file('<th style="text-align: left;"> Event Type Name </th>');
          write_html_file('<td style="background-color: #f7f7e7" valign="top">'
                         ||g_array_events.event_type_name(Idx)||'</td>');
          write_html_file('</tr>');

          write_html_file('<tr style="background-color: #cccc99">');
          write_html_file('<th style="text-align: left;"> Event Type Code </th>');
          write_html_file('<td style="background-color: #f7f7e7" valign="top">'
                         ||g_array_events.event_type_code(Idx)||'</td>');
          write_html_file('</tr>');

          l_transaction_id:= 1;

          BEGIN

              SELECT transaction_id_col_name_1
                   , transaction_id_col_name_2
                   , transaction_id_col_name_3
                   , transaction_id_col_name_4
                INTO l_transction_id_col_name(1)
                   , l_transction_id_col_name(2)
                   , l_transction_id_col_name(3)
                   , l_transction_id_col_name(4)
                FROM xla_entity_id_mappings
               WHERE application_id = g_application_id
                 AND entity_code    = g_array_events.entity_code(Idx)
                 GROUP BY transaction_id_col_name_1
                        , transaction_id_col_name_2
                        , transaction_id_col_name_3
                        , transaction_id_col_name_4
              ;

           EXCEPTION
            WHEN OTHERS THEN
                    l_transction_id_col_name(1):='Transaction Identifier 1';
                    l_transction_id_col_name(2):='Transaction Identifier 2';
                    l_transction_id_col_name(3):='Transaction Identifier 3';
                    l_transction_id_col_name(4):='Transaction Identifier 4';
           END;

          IF g_array_events.reference_num_1(Idx) IS NOT NULL THEN

              write_html_file('<tr style="background-color: #cccc99">');
              write_html_file('<th style="text-align: left;"> '||l_transction_id_col_name(l_transaction_id)||' </th>');
              write_html_file('<td style="background-color: #f7f7e7" valign="top">'
                         ||g_array_events.reference_num_1(Idx)||'</td>');
              write_html_file('</tr>');

              l_transaction_id := l_transaction_id + 1 ;

          END IF;

         IF g_array_events.reference_num_2(Idx) IS NOT NULL THEN

              write_html_file('<tr style="background-color: #cccc99">');
              write_html_file('<th style="text-align: left;"> '||l_transction_id_col_name(l_transaction_id)||' </th>');
              write_html_file('<td style="background-color: #f7f7e7" valign="top">'
                         ||g_array_events.reference_num_2(Idx)||'</td>');
              write_html_file('</tr>');

              l_transaction_id := l_transaction_id +1 ;

          END IF;

         IF g_array_events.reference_num_3(Idx) IS NOT NULL THEN

              write_html_file('<tr style="background-color: #cccc99">');
              write_html_file('<th style="text-align: left;"> '||l_transction_id_col_name(l_transaction_id)||' </th>');
              write_html_file('<td style="background-color: #f7f7e7" valign="top">'
                         ||g_array_events.reference_num_3(Idx)||'</td>');
              write_html_file('</tr>');

              l_transaction_id := l_transaction_id +1 ;

          END IF;

         IF g_array_events.reference_num_4(Idx) IS NOT NULL THEN

              write_html_file('<tr style="background-color: #cccc99">');
              write_html_file('<th style="text-align: left;"> '||l_transction_id_col_name(l_transaction_id)||' </th>');
              write_html_file('<td style="background-color: #f7f7e7" valign="top">'
                         ||g_array_events.reference_num_4(Idx)||'</td>');
              write_html_file('</tr>');

              l_transaction_id := l_transaction_id + 1 ;

          END IF;

         IF g_array_events.reference_char_1(Idx) IS NOT NULL THEN

              write_html_file('<tr style="background-color: #cccc99">');
              write_html_file('<th style="text-align: left;"> '||l_transction_id_col_name(l_transaction_id)||' </th>');
              write_html_file('<td style="background-color: #f7f7e7" valign="top">'
                         ||g_array_events.reference_char_1(Idx)||'</td>');
              write_html_file('</tr>');

              l_transaction_id := l_transaction_id + 1 ;

          END IF;

         IF g_array_events.reference_char_2(Idx) IS NOT NULL THEN

              write_html_file('<tr style="background-color: #cccc99">');
              write_html_file('<th style="text-align: left;"> '||l_transction_id_col_name(l_transaction_id)||' </th>');
              write_html_file('<td style="background-color: #f7f7e7" valign="top">'
                         ||g_array_events.reference_char_2(Idx)||'</td>');
              write_html_file('</tr>');

              l_transaction_id := l_transaction_id +1 ;

          END IF;

         IF g_array_events.reference_char_3(Idx) IS NOT NULL THEN

              write_html_file('<tr style="background-color: #cccc99">');
              write_html_file('<th style="text-align: left;"> '||l_transction_id_col_name(l_transaction_id)||' </th>');
              write_html_file('<td style="background-color: #f7f7e7" valign="top">'
                         ||g_array_events.reference_char_3(Idx)||'</td>');
              write_html_file('</tr>');

              l_transaction_id := l_transaction_id +1 ;

          END IF;

         IF g_array_events.reference_char_4(Idx) IS NOT NULL THEN

              write_html_file('<tr style="background-color: #cccc99">');
              write_html_file('<th style="text-align: left;"> '||l_transction_id_col_name(l_transaction_id)||' </th>');
              write_html_file('<td style="background-color: #f7f7e7" valign="top">'
                         ||g_array_events.reference_char_4(Idx)||'</td>');
              write_html_file('</tr>');

              l_transaction_id := l_transaction_id +1 ;

          END IF;

        IF g_array_events.reference_date_1(Idx) IS NOT NULL THEN

              write_html_file('<tr style="background-color: #cccc99">');
              write_html_file('<th style="text-align: left;"> '||l_transction_id_col_name(l_transaction_id)||' </th>');
              write_html_file('<td style="background-color: #f7f7e7" valign="top">'
                         ||g_array_events.reference_date_1(Idx)||'</td>');
              write_html_file('</tr>');

              l_transaction_id := l_transaction_id +1 ;

          END IF;

         IF g_array_events.reference_date_2(Idx) IS NOT NULL THEN

              write_html_file('<tr style="background-color: #cccc99">');
              write_html_file('<th style="text-align: left;"> '||l_transction_id_col_name(l_transaction_id)||' </th>');
              write_html_file('<td style="background-color: #f7f7e7" valign="top">'
                         ||g_array_events.reference_date_2(Idx)||'</td>');
              write_html_file('</tr>');

              l_transaction_id := l_transaction_id +1 ;

          END IF;

         IF g_array_events.reference_date_3(Idx) IS NOT NULL THEN

              write_html_file('<tr style="background-color: #cccc99">');
              write_html_file('<th style="text-align: left;"> '||l_transction_id_col_name(l_transaction_id)||' </th>');
              write_html_file('<td style="background-color: #f7f7e7" valign="top">'
                         ||g_array_events.reference_date_3(Idx)||'</td>');
              write_html_file('</tr>');

              l_transaction_id := l_transaction_id +1 ;

          END IF;

         IF g_array_events.reference_date_4(Idx) IS NOT NULL THEN

              write_html_file('<tr style="background-color: #cccc99">');
              write_html_file('<th style="text-align: left;"> '||l_transction_id_col_name(l_transaction_id)||' </th>');
              write_html_file('<td style="background-color: #f7f7e7" valign="top">'
                         ||g_array_events.reference_date_4(Idx)||'</td>');
              write_html_file('</tr>');

              l_transaction_id := l_transaction_id +1 ;

          END IF;

          write_html_file('</tbody>');
          write_html_file('</table>');

           --
           -- dump list of accounting ledgers
           --
           write_html_file('<ul>');

           FOR Jdx IN g_array_events.ledger_id.FIRST ..g_array_events.ledger_id.LAST LOOP

               IF g_array_events.event_id.EXISTS(Jdx) AND
                  g_array_events.event_id(Jdx) IS NOT NULL AND
                  g_array_events.event_id(Idx) = g_array_events.event_id(Jdx) THEN

                  write_html_file('<li><a href=#get'||TO_CHAR(g_array_events.event_id(Idx))
                               ||TO_CHAR(g_array_events.ledger_id(Jdx))||'>Extract Source values for '
                               ||g_array_events.ledger_name(Jdx)||' ledger </a></li>');


               END IF;

           END LOOP;

           IF g_acctg_attribute = 'Y' THEN

             FOR Jdx IN g_array_events.ledger_id.FIRST ..g_array_events.ledger_id.LAST LOOP

                IF g_array_events.event_id.EXISTS(Jdx) AND
                   g_array_events.event_id(Jdx) IS NOT NULL AND
                   g_array_events.event_id(Idx) = g_array_events.event_id(Jdx) THEN

                    write_html_file('<li><a href=#get'||TO_CHAR(g_array_events.event_id(Idx))
                               ||TO_CHAR(g_array_events.ledger_id(Jdx))||'ATTRIBUTE'||'> Accounting Attribute values for '
                               ||g_array_events.ledger_name(Jdx)||' ledger </a></li>');

                END IF;

             END LOOP;

           END IF;

           write_html_file('<br><br>');
           write_html_file('<a href=#getreturntothetop>Return to the top</a>');
           write_html_file('</ul>');


        END IF;


        write_html_file('<b> <a NAME=get'||TO_CHAR(g_array_events.event_id(Idx))
                      || TO_CHAR(g_array_events.ledger_id(Idx))||'> Extract Source Values for '
                      ||g_array_events.ledger_name(Idx)||' ledger ( </a></b>');
        write_html_file('<b> <a href="#get'||TO_CHAR(g_array_events.ledger_id(Idx))||'">'||TO_CHAR(g_array_events.ledger_id(Idx))||'</a></b>');
        write_html_file('<b> ) </b>');
        write_html_file('<br><br>');

        --
        -- dump extract object for each accounting ledger
        --
        dump_transaction_objects(  p_event_id         => g_array_events.event_id(Idx)
                             , p_ledger_id        => g_array_events.ledger_id(Idx)
                             , p_ledger_name      => g_array_events.ledger_name(Idx)
                            );

        IF g_acctg_attribute = 'Y' THEN

                 dump_acctg_attributes(  p_event_id       => g_array_events.event_id(Idx)
                                       , p_ledger_id      => g_array_events.ledger_id(Idx)
                                       , p_ledger_name    => g_array_events.ledger_name(Idx)
                                      );
        END IF;

   END LOOP;


   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of procedure dump_diagnostic_sources'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_accounting_dump_pkg.dump_diagnostic_sources');
END dump_diagnostic_sources;


/*======================================================================+
|                                                                       |
| Private Procedure                                                     |
|                                                                       |
|    dump_acctg_attributes                                              |
|                                                                       |
|                                                                       |
+======================================================================*/
PROCEDURE dump_acctg_attributes(  p_event_id         IN NUMBER
                                , p_ledger_id        IN NUMBER
                                , p_ledger_name      IN VARCHAR2
                               )
IS
l_log_module                VARCHAR2(240);
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.dump_acctg_attributes';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of procedure dump_acctg_attributes'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

-- Accounting Attribute Values

        write_html_file('<b> <a NAME=get'||TO_CHAR(p_event_id)
                      || TO_CHAR(p_ledger_id)||'ATTRIBUTE'||'> Accounting Attribute Values for '
                      ||p_ledger_name||' ledger  </a></b>');

        write_html_file('<br><br>');
        write_html_file('<ul>');

-- Header  Accounting Attribute values
        write_html_file('<li><a href=#get'||TO_CHAR(p_event_id)
                      ||TO_CHAR(p_ledger_id)||'ATTRIBUTE_H'
                      ||'> Journal Entry Header Accounting Attribute Values </a></li>');

-- Line  Accounting Attribute values
        write_html_file('<li><a href=#get'||TO_CHAR(p_event_id)
                      ||TO_CHAR(p_ledger_id)||'ATTRIBUTE_L'
                      ||'> Journal Entry Line Accounting Attribute Values </a></li>');

        write_html_file('</ul>');


        dump_hdr_attributes(      p_event_id    =>  p_event_id
                                , p_ledger_id   =>  p_ledger_id
                                , p_ledger_name =>  p_ledger_name
                               );


        dump_line_attributes(     p_event_id    =>  p_event_id
                                , p_ledger_id   =>  p_ledger_id
                                , p_ledger_name =>  p_ledger_name
                               );



   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of procedure dump_acctg_attributes'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_accounting_dump_pkg.dump_acctg_attributes');
END dump_acctg_attributes;


/*======================================================================+
|                                                                       |
| Private Procedure                                                     |
|                                                                       |
|    dump_hdr_attributes                                                |
|                                                                       |
|                                                                       |
+======================================================================*/
PROCEDURE dump_hdr_attributes(    p_event_id         IN NUMBER
                                , p_ledger_id        IN NUMBER
                                , p_ledger_name      IN VARCHAR2
                               )
IS
l_log_module                VARCHAR2(240);
l_count                     NUMBER;
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.dump_hdr_attributes';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of procedure dump_hdr_attributes'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;


     -- Header  Accounting Attribute values

      write_html_file('<b><a NAME=get'||TO_CHAR(p_event_id )
                      || TO_CHAR(p_ledger_id)||'ATTRIBUTE_H'||'> Journal Entry Header Accounting Attribute Values for '
                      ||p_ledger_name||' ledger </a></b>');

      l_count := 0;
      FOR header_attr_rec IN (
       SELECT DISTINCT
                nvl(xaat.name,xals.accounting_attribute_code)        attribute_name
              , nvl(xstl.name,xals.source_code)                      source_name
              , nvl(xds.source_value,' ')                            source_value
              , nvl(xds.source_meaning,' ')                          source_meaning
          FROM   xla_evt_class_acct_attrs    xals
               , xla_acct_attributes_b       xaa
               , xla_acct_attributes_tl      xaat
               , xla_sources_tl              xstl
               , xla_diag_sources            xds
               , xla_diag_events             xde
               , xla_diag_ledgers            xdl
         WHERE  xde.event_id                      = xds.event_id
           AND  xds.ledger_id                     = xdl.ledger_id
           AND  xde.ledger_id                     = xdl.primary_ledger_id
           AND  xde.request_id                    = xdl.accounting_request_id
           AND  xds.source_application_id         = xdl.application_id
           AND  xaa.assignment_level_code         = 'EVT_CLASS_ONLY'
           AND  xaa.accounting_attribute_code     = xals.accounting_attribute_code
           AND  xaa.journal_entry_level_code      = 'H'
           AND  xaat.accounting_attribute_code (+)= xaa.accounting_attribute_code
           AND  xaat.language                  (+)= USERENV('LANG')
           AND  xstl.application_id            (+)= xals.source_application_id
           AND  xstl.source_type_code          (+)= xals.source_type_code
           AND  xstl.source_code               (+)= xals.source_code
           AND  xstl.language                  (+)= USERENV('LANG')
           AND  xals.default_flag                 = 'Y'
           AND  xals.application_id               = xdl.application_id
           AND  xals.event_class_code             = xde.event_class_code
           AND  xds.source_type_code              = xals.source_type_code
           AND  xds.source_code                   = xals.source_code
           AND  xdl.application_id                = xals.application_id
           AND xds.event_id                       = p_event_id
           AND xds.ledger_id                      = p_ledger_id
           AND xdl.application_id                 = g_application_id
        UNION
        SELECT DISTINCT
                nvl(xaat.name,aha.accounting_attribute_code)         attribute_name
              , nvl(xst.name, aha.source_code)                       source_name
              , nvl(xds.source_value,' ')                            source_value
              , nvl(xds.source_meaning,' ')                          source_meaning
          FROM xla_aad_hdr_acct_attrs      aha
             , xla_acct_attributes_b       xaa
             , xla_acct_attributes_tl      xaat
             , xla_sources_tl              xst
             , xla_diag_sources         xds
             , xla_diag_events          xde
             , xla_diag_ledgers         xdl
        WHERE  xde.event_id                  = xds.event_id
           AND xds.ledger_id                 = xdl.ledger_id
           AND xde.ledger_id                 = xdl.primary_ledger_id
           AND xde.request_id                = xdl.accounting_request_id
           AND xds.source_application_id     = xdl.application_id
           AND xde.event_date   BETWEEN nvl(xdl.start_date_active, xde.event_date) AND
                                        nvl (xdl.end_date_active, xde.event_date)
           AND aha.application_id             = xdl.application_id
           AND aha.amb_context_code           = xdl.amb_context_code
           AND aha.product_rule_type_code     = xdl.product_rule_type_code
           AND aha.product_rule_code          = xdl.product_rule_code
           AND aha.event_class_code           = xde.event_class_code
           AND aha.event_type_code            = xde.event_type_code
           AND aha.application_id             = xds.source_application_id
           AND aha.source_type_code           = xds.source_type_code
           AND aha.source_code                = xds.source_code
           AND xaa.accounting_attribute_code  = aha.accounting_attribute_code
           AND xaa.assignment_level_code       IN ('AAD_ONLY','EVT_CLASS_AAD')
           AND xaat.accounting_attribute_code  (+)= xaa.accounting_attribute_code
           AND xaat.language                   (+)= USERENV('LANG')
           AND xst.application_id              (+)= aha.source_application_id
           AND xst.source_type_code            (+)= aha.source_type_code
           AND xst.source_code                 (+)= aha.source_code
           AND xst.language                    (+)= USERENV('LANG')
           AND xds.event_id                    = p_event_id
           AND xds.ledger_id                   = p_ledger_id
           AND xdl.application_id              = g_application_id
       )
  LOOP

   IF (l_count = 0) THEN

      write_html_file('<br><br>');
      write_html_file('<table border="0"><tbody>');
      write_html_file('<tr style="background-color: #cccc99">');
      write_html_file('<th> Accounting Attribute Name </th>');
      write_html_file('<th> Source Name</th>');
      write_html_file('<th> Source Value </th>');
      write_html_file('<th> Source Meaning</th>');

   END IF;

      write_html_file('</tr>');
      write_html_file('<tr style="background-color: #f7f7e7" valign="top">');
      write_html_file('<td>'||header_attr_rec.attribute_name||'</td>');
      write_html_file('<td>'||header_attr_rec.source_name   ||'</td>');
      write_html_file('<td>'||header_attr_rec.source_value  ||'</td>');
      write_html_file('<td>'||header_attr_rec.source_meaning||'</td>');
      write_html_file('</tr>');


      l_count:= l_count + 1;

  END LOOP;

  IF l_count > 0 THEN

     write_html_file('</tbody>');
     write_html_file('</table>');

  ELSE

         write_html_file('<br>');
         write_warning_msg(   p_appli_s_name => 'XLA'
                            , p_msg_name     => 'XLA_DMP_NO_ACCTG_ATTR'
                            , p_token_1      => 'EXTRACT_OBJECT_LEVEL'
                            , p_value_1      => xla_lookups_pkg.get_meaning(
                                                      p_lookup_type    => 'XLA_EXTRACT_OBJECT_TYPE'
                                                    , p_lookup_code    =>  'HEADER'
                                                  )
                            , p_token_2      => 'EVENT_ID'
                            , p_value_2      => p_event_id
                            , p_token_3      => 'LEDGER_ID'
                            , p_value_3      => p_ledger_id
        );
  END IF;

  write_html_file('<a href=#getreturntothetop>Return to the top</a>');
  write_html_file('<br><br>');

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of procedure dump_hdr_attributes'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
  END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_accounting_dump_pkg.dump_hdr_attributes');
END dump_hdr_attributes;

/*======================================================================+
|                                                                       |
| Private Procedure                                                     |
|                                                                       |
|    dump_line_attributes                                               |
|                                                                       |
|                                                                       |
+======================================================================*/
PROCEDURE dump_line_attributes(   p_event_id         IN NUMBER
                                , p_ledger_id        IN NUMBER
                                , p_ledger_name      IN VARCHAR2
                               )
IS
l_log_module                VARCHAR2(240);
l_count                     NUMBER;
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.dump_line_attributes';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of procedure dump_line_attributes'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

    -- Line Accounting Attribute values

    l_count:=0;

    write_html_file('<b> <a NAME=get'||TO_CHAR(p_event_id)
                      || TO_CHAR(p_ledger_id)||'ATTRIBUTE_L'||'> Journal Entry Line Accounting Attribute Values for '
                      ||p_ledger_name||' ledger </a></b>');


    FOR line_attr_rec IN (
        SELECT  DISTINCT
                 nvl(xaltt.name , xldj.accounting_line_code)       jlt_name
               , nvl(lkp.meaning, xldj.accounting_line_type_code)  jlt_owner
               , nvl(xds.line_number,0)                            line_number
               , nvl(xaat.name,xals.accounting_attribute_code)     attribute_name
               , nvl(xst.name, xds.source_code)                    source_name
               , xds.source_value                                  source_value
               , xds.source_meaning                                source_meaning
           FROM  xla_diag_events           xde
               , xla_diag_ledgers          xdl
               , xla_diag_sources          xds
               , xla_sources_tl            xst
               , xla_aad_line_defn_assgns  xald
               , xla_line_defn_jlt_assgns  xldj
               , xla_prod_acct_headers     xpah
               , xla_acct_line_types_tl    xaltt
               , fnd_lookup_values         lkp
               , xla_jlt_acct_attrs        xals
               , xla_acct_attributes_tl    xaat
          WHERE  xst.application_id            (+)= xds.source_application_id
            AND  xst.source_type_code          (+)= xds.source_type_code
            AND  xst.source_code               (+)= xds.source_code
            AND  xst.language                  (+)= USERENV('LANG')
            --
            AND  xaat.accounting_attribute_code(+)= xals.accounting_attribute_code
            AND  xaat.language                 (+)=USERENV('LANG')
            --
            AND  xde.event_id                     = xds.event_id
            AND  xds.ledger_id                    = xdl.ledger_id
            AND  xde.ledger_id                    = xdl.primary_ledger_id
            AND  xds.source_application_id        = xdl.application_id
            AND  xde.event_date     BETWEEN nvl(xdl.start_date_active, xde.event_date) AND
                                    nvl (xdl.end_date_active, xde.event_date)
            AND  xpah.application_id              = xdl.application_id
            AND  xpah.product_rule_type_code      = xdl.product_rule_type_code
            AND  xpah.product_rule_code           = xdl.product_rule_code
            AND  xpah.amb_context_code            = xdl.amb_context_code
            --
            AND  xpah.entity_code                 = xde.entity_code
            AND  xpah.event_class_code            = xde.event_class_code
            AND  xpah.event_type_code             = xde.event_type_code
            --
            AND  xds.source_code                  = xals.source_code
            AND  xds.source_type_code             = xals.source_type_code
            AND  xds.source_application_id        = xals.source_application_id
            --
            AND  xals.application_id              = xldj.application_id
            AND  xals.accounting_line_code        = xldj.accounting_line_code
            AND  xals.accounting_line_type_code   = xldj.accounting_line_type_code
            AND  xals.amb_context_code            = xldj.amb_context_code
            AND  xals.event_class_code            = xldj.event_class_code
            AND  xldj.active_flag                 = 'Y'
            --
            AND  xldj.application_id              = xald.application_id
            AND  xldj.amb_context_code            = xald.amb_context_code
            AND  xldj.event_class_code            = xald.event_class_code
            AND  xldj.event_type_code             = xald.event_type_code
            AND  xldj.line_definition_owner_code  = xald.line_definition_owner_code
            AND  xldj.line_definition_code        = xald.line_definition_code
            --
            AND  xald.application_id              = xpah.application_id
            AND  xald.amb_context_code            = xpah.amb_context_code
            AND  xald.product_rule_type_code      = xpah.product_rule_type_code
            AND  xald.product_rule_code           = xpah.product_rule_code
            AND  xald.event_class_code            = xpah.event_class_code
            AND  xald.event_type_code             = xpah.event_type_code
            AND  xpah.accounting_required_flag    = 'Y'
            --
            AND  xldj.application_id              = xaltt.application_id           (+)
            AND  xldj.amb_context_code            = xaltt.amb_context_code         (+)
            AND  xldj.accounting_line_code        = xaltt.accounting_line_code     (+)
            AND  xldj.accounting_line_type_code   = xaltt.accounting_line_type_code(+)
            AND  xldj.event_class_code            = xaltt.event_class_code         (+)
            AND  xaltt.language               (+) = USERENV('LANG')
            --
            AND  lkp.lookup_type              (+) = 'XLA_OWNER_TYPE'
            AND  lkp.lookup_code              (+) = xldj.accounting_line_type_code
            AND  lkp.view_application_id      (+) = 602
            AND  lkp.language                 (+) = USERENV('LANG')
            AND  lkp.enabled_flag             (+) = 'Y'
            AND  xde.event_date BETWEEN  nvl(lkp.start_date_active,xde.event_date)
            AND                          nvl (lkp.end_date_active, xde.event_date)
            --
            AND  xde.request_id                   = xdl.accounting_request_id
            AND  xds.event_id                     = p_event_id
            AND  xds.ledger_id                    = p_ledger_id
            AND  xdl.application_id               = g_application_id

          UNION
        SELECT DISTINCT
               nvl(xaltt.name , xldj.accounting_line_code)       jlt_name
             , nvl(lkp.meaning, xldj.accounting_line_type_code)  jlt_owner
             , nvl(xds.line_number,0)                            line_number
             , nvl(xaat.name,xals.accounting_attribute_code)     attribute_name
             , nvl(xstl.name,xals.source_code)                   source_name
             , xds.source_value                                  source_value
             , xds.source_meaning                                source_meaning
         FROM   xla_evt_class_acct_attrs    xals
              , xla_acct_attributes_b       xaa
              , xla_acct_attributes_tl      xaat
              , xla_sources_tl              xstl
              , xla_diag_sources            xds
              , xla_diag_events             xde
              , xla_diag_ledgers            xdl
              , xla_aad_line_defn_assgns    xald
              , xla_line_defn_jlt_assgns    xldj
              , xla_prod_acct_headers       xpah
              , xla_acct_line_types_tl      xaltt
              , fnd_lookup_values           lkp
        WHERE  xde.event_id                       = xds.event_id
          AND  xds.ledger_id                      = xdl.ledger_id
          AND  xde.ledger_id                      = xdl.primary_ledger_id
          AND  xds.source_application_id          = xdl.application_id
          AND  xaa.assignment_level_code          = 'EVT_CLASS_ONLY'
          AND  xaa.accounting_attribute_code      = xals.accounting_attribute_code
          AND  xaa.journal_entry_level_code       IN ('L', 'C')
          --
          AND  xaat.accounting_attribute_code (+) = xaa.accounting_attribute_code
          AND  xaat.language                  (+) = USERENV('LANG')
          --
          AND  xstl.application_id            (+) = xals.source_application_id
          AND  xstl.source_type_code          (+) = xals.source_type_code
          AND  xstl.source_code               (+) = xals.source_code
          AND  xstl.language                  (+) = USERENV('LANG')
          --
          AND  xals.default_flag                  = 'Y'
          AND  xals.application_id                = xdl.application_id
          AND  xals.event_class_code              = xde.event_class_code
          --
          AND  xds.source_type_code               = xals.source_type_code
          AND  xds.source_code                    = xals.source_code
          AND  xdl.application_id                 = xals.application_id
          --
          AND  xpah.product_rule_type_code        = xdl.product_rule_type_code
          AND  xpah.product_rule_code             = xdl.product_rule_code
          AND  xpah.amb_context_code              = xdl.amb_context_code
          --
          AND  xpah.entity_code                   = xde.entity_code
          AND  xpah.event_class_code              = xde.event_class_code
          AND  xpah.event_type_code               = xde.event_type_code
          --
          AND  xald.application_id                = xpah.application_id
          AND  xald.amb_context_code              = xpah.amb_context_code
          AND  xald.product_rule_type_code        = xpah.product_rule_type_code
          AND  xald.product_rule_code             = xpah.product_rule_code
          AND  xald.event_class_code              = xpah.event_class_code
          AND  xald.event_type_code               = xpah.event_type_code
          --
          AND  xldj.application_id                = xald.application_id
          AND  xldj.amb_context_code              = xald.amb_context_code
          AND  xldj.line_definition_owner_code    = xald.line_definition_owner_code
          AND  xldj.line_definition_code          = xald.line_definition_code
          AND  xldj.event_class_code              = xald.event_class_code
          AND  xldj.event_type_code               = xald.event_type_code
          AND  xldj.active_flag                   = 'Y'
          --
          AND  xldj.application_id                = xaltt.application_id           (+)
          AND  xldj.amb_context_code              = xaltt.amb_context_code         (+)
          AND  xldj.accounting_line_code          = xaltt.accounting_line_code     (+)
          AND  xldj.accounting_line_type_code     = xaltt.accounting_line_type_code(+)
          AND  xldj.event_class_code              = xaltt.event_class_code         (+)
          AND  xaltt.language               (+)   = USERENV('LANG')
          --
          AND  xpah.accounting_required_flag      = 'Y'
          AND  lkp.lookup_type              (+)   = 'XLA_OWNER_TYPE'
          AND  lkp.lookup_code              (+)   = xldj.accounting_line_type_code
          AND  lkp.view_application_id      (+)   = 602
          AND  lkp.language                 (+)   = USERENV('LANG')
          AND  lkp.enabled_flag             (+)   = 'Y'
          AND  xde.event_date BETWEEN  nvl(lkp.start_date_active,xde.event_date)
          AND                          nvl (lkp.end_date_active, xde.event_date)
          --
          AND  xde.request_id                     = xdl.accounting_request_id
          AND  xds.event_id                       = p_event_id
          AND  xds.ledger_id                      = p_ledger_id
          AND  xdl.application_id                 = g_application_id
     ORDER BY line_number, jlt_name, jlt_owner,  attribute_name
            ) LOOP
     --dump Line acctg attributes


      IF l_count = 0 THEN
       write_html_file('<br><br>');
       write_html_file('<table border="0"><tbody>');
       write_html_file('<tr style="background-color: #cccc99">');
       write_html_file('<th> Distribution Line Number </th>');
       write_html_file('<th> Journal Entry Line Name </th>');
       write_html_file('<th> Journal Entry Line Owner </th>');
       write_html_file('<th> Accounting Attribute Name </th>');
       write_html_file('<th> Source Name</th>');
       write_html_file('<th> Source Value </th>');
       write_html_file('<th> Source Meaning</th>');
      END IF;

      write_html_file('</tr>');
      write_html_file('<tr style="background-color: #f7f7e7" valign="top">');
      IF line_attr_rec.line_number <> 0 THEN
       write_html_file('<td style="text-align: right;">'||TO_CHAR(line_attr_rec.line_number)||'</td>');
      ELSE
       write_html_file('<td style="text-align: right;">'||' '||'</td>');
      END IF;
      write_html_file('<td>'||nvl(line_attr_rec.jlt_name ,'All')||'</td>');
      write_html_file('<td>'||nvl(line_attr_rec.jlt_owner,'All')||'</td>');
      write_html_file('<td>'||line_attr_rec.attribute_name||'</td>');
      write_html_file('<td>'||line_attr_rec.source_name   ||'</td>');
      write_html_file('<td>'||line_attr_rec.source_value  ||'</td>');
      write_html_file('<td>'||line_attr_rec.source_meaning||'</td>');

     l_count:= l_count +1;

    END LOOP;
    IF l_count > 0 THEN

       write_html_file('</tbody>');
       write_html_file('</table>');

    ELSE
       write_html_file('<br>');
         write_warning_msg(   p_appli_s_name => 'XLA'
                            , p_msg_name     => 'XLA_DMP_NO_ACCTG_ATTR'
                            , p_token_1      => 'EXTRACT_OBJECT_LEVEL'
                            , p_value_1      => xla_lookups_pkg.get_meaning(
                                                      p_lookup_type    => 'XLA_EXTRACT_OBJECT_TYPE'
                                                    , p_lookup_code    =>  'LINE'
                                                  )
                            , p_token_2      => 'EVENT_ID'
                            , p_value_2      => p_event_id
                            , p_token_3      => 'LEDGER_ID'
                            , p_value_3      => p_ledger_id
        );

    END IF;

    write_html_file('<a href=#getreturntothetop>Return to the top</a>');
    write_html_file('<br><br>');
    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of procedure dump_line_attributes'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
    END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_accounting_dump_pkg.dump_line_attributes');
END dump_line_attributes;

/*======================================================================+
|                                                                       |
| Private Procedure                                                     |
|                                                                       |
| dump_transaction_objects                                              |
|                                                                       |
|                                                                       |
+======================================================================*/
PROCEDURE dump_transaction_objects(  p_event_id         IN NUMBER
                                   , p_ledger_id        IN NUMBER
                                   , p_ledger_name      IN VARCHAR2
                               )
IS

CURSOR object_cur (p_event_id  NUMBER
                  ,p_ledger_id NUMBER)
IS
SELECT  object_name
      , object_type_code
  FROM xla_diag_sources
 WHERE event_id  = p_event_id
   AND ledger_id = p_ledger_id
 GROUP BY object_name  , object_type_code
 ORDER BY DECODE(object_type_code, C_HEADER ,1
                                    , C_MLS_HEADER,2
                                    , C_LINE,3
                                    , C_BC_LINE,4
                                    , C_MLS_LINE,5
                                   )
;
l_log_module                VARCHAR2(240);
l_array_object_name         t_array_char30;
l_array_object_type         t_array_char30;
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.dump_transaction_objects';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of procedure dump_transaction_objects'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;


   OPEN object_cur( p_event_id           => p_event_id
                  , p_ledger_id          => p_ledger_id
                  );
   --
   --
   FETCH object_cur BULK COLLECT INTO l_array_object_name
                                    , l_array_object_type
                                    ;
   --
   --
   CLOSE object_cur;
   --
   IF l_array_object_name.COUNT > 0 THEN

     write_html_file('<ul>');

     FOR Idx IN l_array_object_name.FIRST .. l_array_object_name.LAST LOOP

       IF l_array_object_type.EXISTS(Idx) AND
          l_array_object_type(Idx) IS NOT NULL AND
          l_array_object_type(Idx) IN (C_HEADER,C_MLS_HEADER) THEN

          write_html_file('<li><b> Header source values retrieved from the extract object '
                      ||l_array_object_name(Idx)||'</b></li>');

       ELSIF l_array_object_type.EXISTS(Idx) AND
             l_array_object_type(Idx) IS NOT NULL AND
             l_array_object_type(Idx) IN (C_LINE,C_MLS_LINE,C_BC_LINE) THEN

          write_html_file('<li><b> Line source values retrieved from the extract object '
                      ||l_array_object_name(Idx)||'</b></li>');

       END IF;

       write_html_file('<br><br>');
       dump_source_names  ( p_event_id          => p_event_id
                          , p_ledger_id         => p_ledger_id
                          , p_ledger_name       => p_ledger_name
                          , p_object_name       => l_array_object_name(Idx)
                          , p_object_type_code  => l_array_object_type(Idx)
                          );

       write_html_file('<br>');

     END LOOP;

     write_html_file('</ul>');

   ELSE

        write_warning_msg(   p_appli_s_name => 'XLA'
                           , p_msg_name     => 'XLA_DMP_NO_EXTRACT_ROWS'
                           , p_token_1      => NULL
                           , p_value_1      => NULL
                           , p_token_2      => NULL
                           , p_value_2      => NULL
                           , p_token_3      => NULL
                           , p_value_3      => NULL
                          );

       write_html_file('&'||'nbsp;'||'&'||'nbsp;'||'&'||'nbsp;');
       write_html_file('<a href=#getreturntothetop>Return to the top</a>');
       write_html_file('<br><br>');

   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of procedure dump_transaction_objects'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_accounting_dump_pkg.dump_transaction_objects');
END dump_transaction_objects;

/*======================================================================+
|                                                                       |
| Private Procedure                                                     |
|                                                                       |
| dump_source_names                                                     |
|                                                                       |
|                                                                       |
+======================================================================*/
PROCEDURE dump_source_names  ( p_event_id          IN NUMBER
                             , p_ledger_id         IN NUMBER
                             , p_ledger_name       IN VARCHAR2
                             , p_object_name       IN VARCHAR2
                             , p_object_type_code  IN VARCHAR2
                               )
IS

CURSOR source_cur (p_event_id         NUMBER
                  ,p_ledger_id        NUMBER
                  ,p_object_name      VARCHAR2
                  ,p_object_type_code VARCHAR2)
IS
SELECT
        xds.source_code
      , xds.source_type_code
      , xds.source_application_id
      , DECODE(xsb.view_application_id,
                NULL, DECODE(xsb.flex_value_set_id,
                             NULL,'N',
                             'Y')
                , 'Y')
      , nvl(xst.name,xds.source_code)
  FROM  xla_diag_sources     xds
     ,  xla_sources_b        xsb
     ,  xla_sources_tl       xst
 WHERE xsb.application_id   (+)= xds.source_application_id
   AND xsb.source_type_code (+)= xds.source_type_code
   AND xsb.source_code      (+)= xds.source_code
   AND xds.event_id            = p_event_id
   AND xds.ledger_id           = p_ledger_id
   AND xds.object_name         = p_object_name
   AND xds.object_type_code    = p_object_type_code
   AND xst.application_id   (+)= xds.source_application_id
   AND xst.source_type_code (+)= xds.source_type_code
   AND xst.source_code      (+)= xds.source_code
   AND xst.language         (+)= USERENV('LANG')
   AND xds.line_number =  (SELECT max(line_number)
                             FROM xla_diag_sources    xds2
                            WHERE xds2.event_id            = p_event_id
                              AND xds2.ledger_id           = p_ledger_id
                              AND xds2.object_name         = p_object_name
                              AND xds2.object_type_code    = p_object_type_code
                          )
 ORDER BY xds.source_application_id, xds.source_type_code, xds.source_code
;

l_log_module                VARCHAR2(240);
l_array_source_code         t_array_char30;
l_array_source_name         t_array_char80;
l_array_meaning_flag        t_array_char1;
l_array_source_type_code    t_array_char1;
l_array_source_appl_id      t_array_number;

BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.dump_source_names ';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of procedure dump_source_names '
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;


   OPEN source_cur ( p_event_id           => p_event_id
                   , p_ledger_id          => p_ledger_id
                   , p_object_name        => p_object_name
                   , p_object_type_code   => p_object_type_code
                   );
   --
   --
   FETCH source_cur BULK COLLECT INTO l_array_source_code
                                    , l_array_source_type_code
                                    , l_array_source_appl_id
                                    , l_array_meaning_flag
                                    , l_array_source_name
                                    ;
   --
   --
   CLOSE source_cur;
   --
   IF l_array_source_code.COUNT > 0 THEN


     write_html_file('<table border="0"><tbody>');
     write_html_file('<tr style="background-color: #cccc99">');

     IF p_object_type_code IN (C_LINE,C_BC_LINE,C_MLS_LINE ) THEN
        write_html_file('<th> Distribution line number </th>');
     END IF;

     FOR Idx IN l_array_source_code.FIRST .. l_array_source_code.LAST LOOP

       IF g_source_name = 'Y' THEN
          write_html_file('<th> '||l_array_source_name(Idx)||' </th>');
       ELSE
          write_html_file('<th> '||l_array_source_code(Idx)||' </th>');
       END IF;

       IF ( l_array_meaning_flag(Idx) = 'Y' ) THEN

          IF g_source_name = 'Y' THEN
              write_html_file('<th> '||l_array_source_name(Idx)||' meaning </th>');
          ELSE
              write_html_file('<th> '||l_array_source_code(Idx)||' meaning </th>');
          END IF;

       END IF;

     END LOOP;

     write_html_file('</tr>');

     dump_source_values (  p_event_id                 => p_event_id
                         , p_ledger_id                => p_ledger_id
                         , p_ledger_name              => p_ledger_name
                         , p_object_name              => p_object_name
                         , p_object_type_code         => p_object_type_code
                        );

     write_html_file('</tbody>');
     write_html_file('</table>');
     write_html_file('<a href=#getreturntothetop>Return to the top</a>');
     write_html_file('<br><br>');

   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of procedure dump_source_names '
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_accounting_dump_pkg.dump_source_names ');
END dump_source_names ;

/*======================================================================+
|                                                                       |
| Private Procedure                                                     |
|                                                                       |
| dump_source_values                                                    |
|                                                                       |
|                                                                       |
+======================================================================*/
PROCEDURE dump_source_values ( p_event_id                 IN NUMBER
                             , p_ledger_id                IN NUMBER
                             , p_ledger_name              IN VARCHAR2
                             , p_object_name              IN VARCHAR2
                             , p_object_type_code         IN VARCHAR2
                             )
IS

CURSOR source_cur( p_event_id         NUMBER
                  ,p_ledger_id        NUMBER
                  ,p_object_name      VARCHAR2
                  ,p_object_type_code VARCHAR2)
IS
SELECT  xds.source_code
      , xds.source_type_code
      , xds.source_application_id
      , nvl(TO_CHAR(xds.source_value),' ')
      , nvl(TO_CHAR(xds.source_meaning),' ')
      , xds.line_number                     AS line_number
      , DECODE(xsb.datatype_code
               ,'C','N'
               ,'D','N'
               ,'Y')
      , DECODE(xsb.view_application_id,
                NULL, DECODE(xsb.flex_value_set_id, NULL,'N','Y'), 'Y')
  FROM  xla_diag_sources     xds
      , xla_sources_b        xsb
 WHERE xsb.application_id   (+)= xds.source_application_id
   AND xsb.source_type_code (+)= xds.source_type_code
   AND xsb.source_code      (+)= xds.source_code
   AND xds.event_id         = p_event_id
   AND xds.ledger_id        = p_ledger_id
   AND xds.object_name      = p_object_name
   AND xds.object_type_code = p_object_type_code
   AND (xds.line_number = 0 OR
        xds.line_number  BETWEEN NVL(g_from_line_number,xds.line_number) AND
                                 NVL(g_to_line_number,xds.line_number))
 ORDER BY line_number, xds.source_application_id, xds.source_type_code, xds.source_code
;

l_log_module                VARCHAR2(240);
l_array_source_code         t_array_char30;
l_array_source_type_code    t_array_char1;
l_array_meaning_flag        t_array_char1;
l_array_numeric_flag        t_array_char1;
l_array_source_appl_id      t_array_number;
l_array_line_number         t_array_number;
l_array_source_meaning      t_array_char2000;
l_array_source_value        t_array_char2000;
l_curr_line_number          NUMBER;

BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.dump_source_values';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of procedure dump_source_values'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;


   OPEN source_cur ( p_event_id          => p_event_id
                   , p_ledger_id          => p_ledger_id
                   , p_object_name        => p_object_name
                   , p_object_type_code   => p_object_type_code
                   );
   --
   --
   FETCH source_cur BULK COLLECT INTO l_array_source_code
                                    , l_array_source_type_code
                                    , l_array_source_appl_id
                                    , l_array_source_value
                                    , l_array_source_meaning
                                    , l_array_line_number
                                    , l_array_numeric_flag
                                    , l_array_meaning_flag
                                    ;
   --
   --
   CLOSE source_cur;

   --
   l_curr_line_number:= -1;
   --
   IF l_array_source_code.COUNT > 0 THEN

     FOR Idx IN l_array_source_code.FIRST .. l_array_source_code.LAST LOOP

       IF (l_curr_line_number <> l_array_line_number(Idx) ) THEN

         IF ( l_curr_line_number <> -1 ) THEN
           write_html_file('</tr>');
         END IF;

         write_html_file('<tr style="background-color: #f7f7e7" valign="top">');
         IF p_object_type_code IN (C_LINE,C_BC_LINE,C_MLS_LINE ) THEN
            write_html_file('<td style="text-align: right;">'||TO_CHAR(l_array_line_number(Idx))||'</td>');
         END IF;
         l_curr_line_number:= l_array_line_number(Idx);

       END IF;

       IF l_array_numeric_flag(Idx) ='Y' THEN

         write_html_file('<td style="text-align: right;">'||l_array_source_value(Idx)||'</td>');

       ELSE

          write_html_file('<td> '||l_array_source_value(Idx) ||' </td>');

       END IF;

       IF ( l_array_meaning_flag(Idx)='Y')
       THEN
           write_html_file('<td> '||l_array_source_meaning(Idx)||' </td>');
       END IF;

     END LOOP;

     IF ( l_curr_line_number <> -1 ) THEN
           write_html_file('</tr>');
     END IF;

   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of procedure dump_source_values'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_accounting_dump_pkg.dump_source_values');
END dump_source_values;

--============================================================================
--
-- PUBLIC PROCEDURE
--     transaction_objects_diag
--
--============================================================================
PROCEDURE transaction_objects_diag
        (p_errbuf                    OUT NOCOPY VARCHAR2
       ,p_retcode                    OUT NOCOPY NUMBER
       ,p_application_id             IN NUMBER
       ,p_dummy_parameter_1          IN VARCHAR2
       ,p_ledger_id                  IN NUMBER
       ,p_dummy_parameter_2          IN VARCHAR2
       ,p_event_class_code           IN VARCHAR2
       ,p_dummy_parameter_3          IN VARCHAR2
       ,p_event_type_code            IN VARCHAR2
       ,p_dummy_parameter_4          IN VARCHAR2
       ,p_transaction_number         IN VARCHAR2
       ,p_dummy_parameter_5          IN VARCHAR2
       ,p_event_number               IN NUMBER
       ,p_dummy_parameter_6          IN VARCHAR2
       ,p_from_line_number           IN NUMBER
       ,p_dummy_parameter_7          IN VARCHAR2
       ,p_to_line_number             IN NUMBER
       ,p_request_id                 IN NUMBER
       ,p_errors_only                IN VARCHAR2
       ,p_source_name                IN VARCHAR2
       ,p_acctg_attribute            IN VARCHAR2)
IS
l_log_module                      VARCHAR2(240);
BEGIN
   IF g_log_enabled THEN

      l_log_module := C_DEFAULT_MODULE||'.transaction_objects_diag';

   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of procedure transaction_objects_diag'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

   END IF;


  initialize
       (p_application_id       => p_application_id
       ,p_ledger_id            => p_ledger_id
       ,p_event_class_code     => p_event_class_code
       ,p_event_type_code      => p_event_type_code
       ,p_transaction_number   => p_transaction_number
       ,p_event_number         => p_event_number
       ,p_from_line_number     => p_from_line_number
       ,p_to_line_number       => p_to_line_number
       ,p_request_id           => p_request_id
       ,p_errors_only          => p_errors_only
       ,p_source_name          => p_source_name
       ,p_acctg_attribute      => p_acctg_attribute
       );
   --
   -- build the HTML file
   --

   write_title();

   write_header();

   get_diagnostic_events();

   IF g_array_events.event_id.COUNT = 0 THEN

         write_warning_msg(  p_appli_s_name => 'XLA'
                           , p_msg_name     => 'XLA_DMP_NO_DATA_FOUND'
                           , p_token_1      => NULL
                           , p_value_1      => NULL
                           , p_token_2      => NULL
                           , p_value_2      => NULL
                           , p_token_3      => NULL
                           , p_value_3      => NULL
                         );
         p_retcode             := 1;
         p_errbuf              := 'Transaction Objects Diagnostics ended in Warning'
                                 || ' because no data match the search criteria';

   ELSE

         dump_diagnostic_events();
         dump_diagnostic_Ledgers();
         dump_diagnostic_sources();

         p_retcode             := 0;
         p_errbuf              := 'Transaction Objects Diagnostics completed Normal';

   END IF;

   write_footer();

   --
   -- write HTML file into the request output file
   --

   write_output();


   --
   -- write HTML file into the FND log attachment
   --

   IF (C_LEVEL_UNEXPECTED >= g_log_level) THEN

       write_fnd_log_attachment();

   END IF;


   IF (C_LEVEL_STATEMENT >= g_log_level) THEN

       trace
                (p_msg      => 'p_retcode = '||p_retcode
                ,p_level    => C_LEVEL_STATEMENT
                ,p_module   => l_log_module);
       trace
                (p_msg      => 'p_errbuf = '||p_errbuf
                ,p_level    => C_LEVEL_STATEMENT
                ,p_module   => l_log_module);

   END IF;

 IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of procedure transaction_objects_diag'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

 END IF;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   ----------------------------------------------------------------------------
   -- set out variables
   ----------------------------------------------------------------------------
   p_retcode                := 2;
   p_errbuf                 := xla_messages_pkg.get_message;


   write_html_file(p_errbuf);
   write_logfile(p_errbuf);

   IF (C_LEVEL_ERROR >= g_log_level) THEN
      trace
         (p_msg      => NULL
         ,p_level    => C_LEVEL_ERROR
         ,p_module   => l_log_module);
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'p_retcode = '||p_retcode
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_errbuf = '||p_errbuf
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'END of procedure transaction_objects_diag'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;
WHEN OTHERS THEN
   ----------------------------------------------------------------------------
   -- set out variables
   ----------------------------------------------------------------------------
   p_retcode                := 2;
   p_errbuf                 := sqlerrm;

   write_html_file(p_errbuf);
   write_logfile(p_errbuf);

   IF (C_LEVEL_UNEXPECTED >= g_log_level) THEN
      trace
         (p_msg      => NULL
         ,p_level    => C_LEVEL_UNEXPECTED
         ,p_module   => l_log_module);
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'p_retcode = '||p_retcode
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_errbuf = '||p_errbuf
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'END of procedure transaction_objects_diag'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;
END transaction_objects_diag;   -- end of procedure
--
--
--============================================================================
--
-- PUBLIC PROCEDURE: acctg_event_extract_log
--
-- DESCRIPTION     : write the Accounting Event Extract Diagnostics
--                   result into FND Logging large attachment.
--
-- PARAMETERS      :
--============================================================================
PROCEDURE acctg_event_extract_log
      ( p_application_id             IN NUMBER
       ,p_request_id                 IN NUMBER)IS
l_log_module                      VARCHAR2(240);
BEGIN
   IF g_log_enabled THEN

      l_log_module := C_DEFAULT_MODULE||'.acctg_event_extract_log';

   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of procedure acctg_event_extract_log'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

   END IF;

 IF (C_LEVEL_UNEXPECTED >= g_log_level) THEN

  initialize
       (p_application_id       => p_application_id
       ,p_ledger_id            => NULL
       ,p_event_class_code     => NULL
       ,p_event_type_code      => NULL
       ,p_transaction_number   => NULL
       ,p_event_number         => NULL
       ,p_from_line_number     => NULL
       ,p_to_line_number       => NULL
       ,p_request_id           => p_request_id
       ,p_errors_only          => 'N'
       ,p_source_name          => 'N'
       ,p_acctg_attribute      => 'N'
       );

   write_title();

   write_header();

   get_diagnostic_events();

   IF g_array_events.event_id.COUNT = 0 THEN

          write_warning_msg(  p_appli_s_name => 'XLA'
                            , p_msg_name     => 'XLA_DMP_NO_DATA_FOUND'
                            , p_token_1      => NULL
                            , p_value_1      => NULL
                            , p_token_2      => NULL
                            , p_value_2      => NULL
                            , p_token_3      => NULL
                            , p_value_3      => NULL
                          );

   ELSE

         dump_diagnostic_events();
         dump_diagnostic_Ledgers();
         dump_diagnostic_sources();

   END IF;

   write_footer();

   write_fnd_log_attachment();

 END IF;

 IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of procedure acctg_event_extract_log'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

 END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN

   IF (C_LEVEL_ERROR >= g_log_level) THEN
      trace
         (p_msg      => 'ERROR ='||xla_messages_pkg.get_message
         ,p_level    => C_LEVEL_ERROR
         ,p_module   => l_log_module);
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of procedure acctg_event_extract_log'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;
   RAISE;
WHEN OTHERS THEN

   IF (C_LEVEL_UNEXPECTED >= g_log_level) THEN
      trace
         (p_msg      => 'ERROR =' ||sqlerrm
         ,p_level    => C_LEVEL_UNEXPECTED
         ,p_module   => l_log_module);
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of procedure acctg_event_extract_log'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;
 xla_exceptions_pkg.raise_message
      (p_location => 'xla_accounting_dump_pkg.acctg_event_extract_log');
END acctg_event_extract_log;   -- end of procedure


--============================================================================
--
-- PUBLIC PROCEDURE
--     purge
--
--============================================================================
PROCEDURE purge
       (p_errbuf                     OUT NOCOPY VARCHAR2
       ,p_retcode                    OUT NOCOPY NUMBER
       ,p_application_id             IN NUMBER
       ,p_up_to_date                 IN DATE
       ,p_request_id                 IN NUMBER
             )
IS
l_log_module                      VARCHAR2(240);
l_count                           NUMBER;
l_rownum                          NUMBER;
l_up_to_date                      DATE;
BEGIN

   IF g_log_enabled THEN

      l_log_module := C_DEFAULT_MODULE||'.purge';

   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of procedure purge'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

   END IF;

   SAVEPOINT purgeDATA;

   l_rownum     := 0;
   l_up_to_date := TRUNC(p_up_to_date);
   write_logfile('**Parameters ** ');
   write_logfile('Application Id = '||TO_CHAR(p_application_id));
   write_logfile('End Date = '||TO_CHAR(l_up_to_date));
   write_logfile('Accounting Program Request Id= '||TO_CHAR(p_request_id));

    IF l_up_to_date IS NOT NULL AND p_request_id IS NOT NULL THEN

          SELECT count(*)
          INTO l_count
          FROM xla_diag_sources
         WHERE source_application_id = p_application_id
           AND creation_date <= l_up_to_date
           AND request_id    =  p_request_id
         ;

   ELSIF l_up_to_date IS NULL AND p_request_id IS NOT NULL THEN

        SELECT count(*)
          INTO l_count
          FROM xla_diag_sources
         WHERE source_application_id = p_application_id
           AND request_id    =  p_request_id
         ;


   ELSIF l_up_to_date IS NOT NULL AND p_request_id IS NULL THEN

          SELECT count(*)
          INTO l_count
          FROM xla_diag_sources
         WHERE source_application_id = p_application_id
           AND creation_date <= l_up_to_date
         ;

   ELSE

          SELECT count(*)
          INTO l_count
          FROM xla_diag_sources
         WHERE source_application_id = p_application_id
         ;

   END IF;


   IF l_count  = 0 THEN

         p_retcode             := 1;
         p_errbuf              := 'Transaction Objects Diagnostics purge ended in Warning'
                                 || ' because no data match the selection criteria';

   ELSE


     write_logfile('**Start** purge of xla_diag_events');

     IF l_up_to_date IS NOT NULL AND p_request_id IS NOT NULL THEN

          DELETE FROM xla_diag_events
           WHERE event_id IN
                    (SELECT event_id FROM xla_diag_events
                      WHERE application_id = p_application_id
                        AND creation_date <= l_up_to_date
                        AND request_id    = p_request_id)
          ;

     ELSIF l_up_to_date IS NULL AND p_request_id IS NOT NULL THEN

          DELETE FROM xla_diag_events
           WHERE event_id IN
                    (SELECT event_id FROM xla_diag_events
                      WHERE application_id = p_application_id
                        AND request_id    = p_request_id)
          ;

     ELSIF l_up_to_date IS NOT NULL AND p_request_id IS NULL THEN

          DELETE FROM xla_diag_events
           WHERE event_id IN
                    (SELECT event_id FROM xla_diag_events
                      WHERE application_id = p_application_id
                        AND creation_date <= l_up_to_date)
          ;

     ELSE

          DELETE FROM xla_diag_events
           WHERE event_id IN
                    (SELECT event_id FROM xla_diag_events
                      WHERE application_id = p_application_id )
          ;

     END IF;

     l_rownum := l_rownum + SQL%ROWCOUNT;
     IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'Number of rows deleted = '||SQL%ROWCOUNT
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
     END IF;

    write_logfile('Number of rows deleted ='||SQL%ROWCOUNT);
    write_logfile('** End ** purge of xla_diag_events');
    write_logfile('**Start** purge of xla_diag_ledgers');


     DELETE FROM xla_diag_ledgers
      WHERE application_id = p_application_id
        AND primary_ledger_id NOT IN
              (SELECT ledger_id
                 FROM xla_diag_events
                WHERE application_id        = p_application_id
             )
      ;

     l_rownum := l_rownum + SQL%ROWCOUNT;
     IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'Number of rows deleted = '||SQL%ROWCOUNT
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
     END IF;
    write_logfile('Number of rows deleted ='||SQL%ROWCOUNT);
    write_logfile('** End ** purge of xla_diag_ledgers');
    write_logfile('**Start** purge of xla_diag_sources');

     IF l_up_to_date IS NOT NULL AND p_request_id IS NOT NULL THEN

         DELETE FROM xla_diag_sources
          WHERE source_application_id = p_application_id
            AND creation_date        <= l_up_to_date
            AND request_id            = p_request_id
          ;


     ELSIF l_up_to_date IS NULL AND p_request_id IS NOT NULL THEN

         DELETE FROM xla_diag_sources
          WHERE source_application_id = p_application_id
            AND request_id            = p_request_id
          ;

     ELSIF l_up_to_date IS NOT NULL AND p_request_id IS NULL THEN

         DELETE FROM xla_diag_sources
          WHERE source_application_id = p_application_id
            AND creation_date        <= l_up_to_date
          ;

     ELSE

         DELETE FROM xla_diag_sources
          WHERE source_application_id = p_application_id
          ;

     END IF;

     l_rownum := l_rownum + SQL%ROWCOUNT;
     IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'Number of rows deleted = '||SQL%ROWCOUNT
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
     END IF;
     write_logfile('Number of rows deleted ='||SQL%ROWCOUNT);
     write_logfile('**END** purge of xla_diag_sources');

     IF l_rownum > 0 THEN
          write_logfile('**COMMIT** purge of Transaction Objects Diagnostics');
          COMMIT;
     END IF;
     p_retcode             := 0;
     p_errbuf              := 'Transaction Objects Diagnostics purge completed Normal';

   null;
   END IF;


   IF (C_LEVEL_STATEMENT >= g_log_level) THEN

       trace
                (p_msg      => 'p_retcode = '||p_retcode
                ,p_level    => C_LEVEL_STATEMENT
                ,p_module   => l_log_module);
       trace
                (p_msg      => 'p_errbuf = '||p_errbuf
                ,p_level    => C_LEVEL_STATEMENT
                ,p_module   => l_log_module);

   END IF;

 IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of procedure purge'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

 END IF;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN

   ROLLBACK TO  purgeDATA;
   ----------------------------------------------------------------------------
   -- set out variables
   ----------------------------------------------------------------------------
   p_retcode                := 2;
   p_errbuf                 := xla_messages_pkg.get_message;

   write_logfile(p_errbuf);

   IF (C_LEVEL_ERROR >= g_log_level) THEN
      trace
         (p_msg      => NULL
         ,p_level    => C_LEVEL_ERROR
         ,p_module   => l_log_module);
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'p_retcode = '||p_retcode
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_errbuf = '||p_errbuf
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'END of procedure purge'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;
WHEN OTHERS THEN

   ROLLBACK TO  purgeDATA;
   ----------------------------------------------------------------------------
   -- set out variables
   ----------------------------------------------------------------------------
   p_retcode                := 2;
   p_errbuf                 := sqlerrm;


   write_logfile(p_errbuf);

   IF (C_LEVEL_UNEXPECTED >= g_log_level) THEN
      trace
         (p_msg      => NULL
         ,p_level    => C_LEVEL_UNEXPECTED
         ,p_module   => l_log_module);
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'p_retcode = '||p_retcode
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_errbuf = '||p_errbuf
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'END of procedurepurge'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;
END purge;   -- end of procedure
--
--
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
-- Following code is executed when the package body is referenced for the first
-- time
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

   g_log_level      := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   g_log_enabled    := fnd_log.test
                          (log_level  => g_log_level
                          ,module     => C_DEFAULT_MODULE);

   IF NOT g_log_enabled  THEN
      g_log_level := C_LEVEL_LOG_DISABLED;
   END IF;
   --
END xla_accounting_dump_pkg; -- end of package spec.

/
