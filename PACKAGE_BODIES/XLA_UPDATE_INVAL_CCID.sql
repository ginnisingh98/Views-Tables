--------------------------------------------------------
--  DDL for Package Body XLA_UPDATE_INVAL_CCID
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_UPDATE_INVAL_CCID" AS
/*$Header: xlaudccid.pkb 120.1.12010000.2 2009/08/05 09:41:22 karamakr noship $
============================================================================+
|             COPYRIGHT (C) 2001-2002 ORACLE CORPORATION                     |
|                       REDWOOD SHORES, CA, USA                              |
|                         ALL RIGHTS RESERVED.                               |
+============================================================================+
| PACKAGE NAME                                                               |
|     xla_update_inval_ccid                                                  |
|                                                                            |
| DESCRIPTION                                                                |
|     PACKAGE BODY FOR Update Invalid CCIDS program                          |
|     This Api Will be called from the Java Layer once the BPEL              |
|     returns the invalid ccids java cp will call this API to Update         |
|     Accounting Entries with the invalid status                             |
|                                                                            |
| HISTORY                                                                    |
|     04/08/2008    Jagan Koduri         CREATED                             |
+===========================================================================*/

   -------------------------------------------------------------------------------
--               *********** LOCAL TRACE ROUTINE **********
-------------------------------------------------------------------------------
   c_level_statement      CONSTANT NUMBER         := fnd_log.level_statement;
   c_level_procedure      CONSTANT NUMBER         := fnd_log.level_procedure;
   c_level_event          CONSTANT NUMBER         := fnd_log.level_event;
   c_level_exception      CONSTANT NUMBER         := fnd_log.level_exception;
   c_level_error          CONSTANT NUMBER         := fnd_log.level_error;
   c_level_unexpected     CONSTANT NUMBER         := fnd_log.level_unexpected;
   c_level_log_disabled   CONSTANT NUMBER         := 99;
   c_default_module       CONSTANT VARCHAR2 (240)
                                         := 'XLA.PLSQL.XLA_UPDATE_INVAL_CCID';
   g_log_level                     NUMBER;
   g_log_enabled                   BOOLEAN;
   c_log_size             CONSTANT NUMBER         := 2000;

   PROCEDURE TRACE (
      p_msg      IN   VARCHAR2,
      p_level    IN   NUMBER,
      p_module   IN   VARCHAR2 DEFAULT c_default_module
   )
   IS
      l_max   NUMBER;
      l_pos   NUMBER := 1;
   BEGIN
      l_pos := 1;

      IF (p_msg IS NULL AND p_level >= g_log_level)
      THEN
         fnd_log.MESSAGE (p_level, p_module);
      ELSIF p_level >= g_log_level
      THEN
         l_max := LENGTH (p_msg);

         IF l_max <= c_log_size
         THEN
            fnd_log.STRING (p_level, p_module, p_msg);
         ELSE
            WHILE (l_pos - 1) * c_log_size <= l_max
            LOOP
               fnd_log.STRING (p_level,
                               p_module,
                               SUBSTR (p_msg,
                                         (l_pos - 1) * c_log_size + 1,
                                       c_log_size
                                      )
                              );
               l_pos := l_pos + 1;
            END LOOP;
         END IF;
      END IF;
   EXCEPTION
      WHEN xla_exceptions_pkg.application_exception
      THEN
         RAISE;
      WHEN OTHERS
      THEN
         xla_exceptions_pkg.raise_message (p_location      => 'xla_update_inval_ccid.trace'
                                          );
   END TRACE;

-------------------------------------------------------------------------------
--                   ******* Print Log File **********
-------------------------------------------------------------------------------
   PROCEDURE print_logfile (p_msg IN VARCHAR2)
   IS
   BEGIN
      fnd_file.put_line (fnd_file.LOG, p_msg);
   EXCEPTION
      WHEN xla_exceptions_pkg.application_exception
      THEN
         RAISE;
      WHEN OTHERS
      THEN
         xla_exceptions_pkg.raise_message (p_location      => 'xla_update_inval_ccid.print_logfile'
                                          );
   END print_logfile;

-------------------------------------------------------------------------------
--                   ******* Print Log File **********
-------------------------------------------------------------------------------
   PROCEDURE xla_update_inval_ccid_api (
      p_accounting_batch_id   IN   NUMBER,
      p_ledger_id             IN   NUMBER,
      p_application_id        IN   NUMBER,
      p_ccid                  IN   t_ccid_table,
      p_status                IN   NUMBER,
      p_err_msg               IN   VARCHAR2
   )
   AS
      TYPE t_ae_header_id IS TABLE OF xla_ae_headers.ae_header_id%TYPE;

      TYPE t_event_id IS TABLE OF xla_ae_headers.event_id%TYPE;

      l_ae_header_id            t_ae_header_id;
      l_ccid                    t_ccid_table;
      l_event_id                t_event_id;
      l_log_module              VARCHAR2 (240);
      l_entity_id               NUMBER;
      l_e_header_id             NUMBER;
      l_vent_id                 NUMBER;
      l_err_msg                 VARCHAR2 (3000);
      --for sus
      l_suspense_allowed_flag   VARCHAR2 (3);
      l_suspense_ccid           NUMBER;
      l_bal_seg_column_name     VARCHAR2 (100);
      l_ledger_id               NUMBER;
      l_ledger_name             VARCHAR2 (100);
      l_found                   BOOLEAN                   := FALSE;
      l_found_sus               BOOLEAN                   := FALSE;
      l_found_invalid           BOOLEAN                   := FALSE;
      l_segments_sus            fnd_flex_ext.segmentarray;
      l_segments_invalid        fnd_flex_ext.segmentarray;
      l_numofsegments           NUMBER;
      l_balancesegnum           NUMBER;
      l_structnum               NUMBER;
      l_invalid_ccid            NUMBER;
      p_new_ccid                NUMBER;
   --for sus
   BEGIN
      print_logfile (   TO_CHAR (SYSDATE, 'DD-MON-YYYY HH24:MI:SS')
                     || ' - Starting of the Update Invalid CCID Information'
                    );

print_logfile ('p_status '||p_status);

      IF g_log_enabled
      THEN
         l_log_module := c_default_module || 'xla_update_inval_ccid_api';
      END IF;

      IF (c_level_procedure >= g_log_level)
      THEN
         TRACE (p_msg         => 'BEGIN of procedure XLA_UPDATE_INVAL_CCID',
                p_level       => c_level_procedure,
                p_module      => l_log_module
               );
         TRACE (p_msg         =>    'p_application_id = '
                                 || TO_CHAR (p_application_id),
                p_level       => c_level_procedure,
                p_module      => l_log_module
               );
         TRACE (p_msg         => 'p_ledger_id = ' || p_ledger_id,
                p_level       => c_level_procedure,
                p_module      => l_log_module
               );
         TRACE (p_msg         =>    'p_accounting_batch_id = '
                                 || p_accounting_batch_id,
                p_level       => c_level_procedure,
                p_module      => l_log_module
               );
      END IF;

      l_ccid := p_ccid;

      -- Finding the info weather the suspense accounting is allowed for this ledger or not
      SELECT suspense_allowed_flag, suspense_ccid, bal_seg_column_name,
             ledger_id, chart_of_accounts_id
        INTO l_suspense_allowed_flag, l_suspense_ccid, l_bal_seg_column_name,
             l_ledger_id, l_structnum
        FROM gl_ledgers_v
       WHERE ledger_id = p_ledger_id;

      l_invalid_ccid := l_ccid (1);

      print_logfile ('l_suspense_allowed_flag    ' || l_suspense_allowed_flag);
      print_logfile ('l_suspense_ccid            ' || l_suspense_ccid);
      print_logfile ('l_bal_seg_column_name      ' || l_bal_seg_column_name);
      print_logfile ('l_ledger_name              ' || l_ledger_name);
      print_logfile ('l_structnum                ' || l_structnum);
      print_logfile ('l_numofsegments            ' || l_numofsegments);

      IF l_suspense_allowed_flag = 'Y' AND l_suspense_ccid IS NOT NULL
      THEN
         -- confirming that suspense account is exist
         print_logfile ('Inside Suspense Loop ');
         l_found_sus :=
            fnd_flex_ext.get_segments ('SQLGL',
                                       'GL#',
                                       l_structnum,
                                       l_suspense_ccid,
                                       l_numofsegments,
                                       l_segments_sus
                                      );
         print_logfile ('l_numofsegments l_found_sus ' || l_numofsegments);
         print_logfile ('l_ccid.first ' || l_ccid.FIRST);
         l_found_invalid :=
            fnd_flex_ext.get_segments ('SQLGL',
                                       'GL#',
                                       l_structnum,
                                       l_invalid_ccid,
                                       l_numofsegments,
                                       l_segments_invalid
                                      );
         print_logfile ('l_numofsegments l_found_invalid ' || l_numofsegments);

         --print_logfile (  'l_found_sus '||l_found_sus);
         --print_logfile (  'l_found_invalid '||l_found_invalid);


         IF l_found_sus AND l_found_invalid
         THEN
            print_logfile ('Getting the balancingsegment number');
            -- getting the balancing segment number


            l_found :=
               fnd_flex_apis.get_qualifier_segnum (101,
                                                   'GL#',
                                                   l_structnum,
                                                   'GL_BALANCING',
                                                   l_balancesegnum
                                                  );
            print_logfile ('l_balancesegnum' || l_balancesegnum);

            IF l_segments_sus (l_balancesegnum) =
                                          l_segments_invalid (l_balancesegnum)
            THEN
               print_logfile ('Balancing segments are equal ');
               p_new_ccid := l_suspense_ccid;
            ELSE
               print_logfile ('Balancing segments are not equal generating new CCID with the combination'
                             );
               l_segments_sus (l_balancesegnum) :=
                                          l_segments_invalid (l_balancesegnum);
               print_logfile (   l_segments_sus (l_balancesegnum)
                              || 'New balancing segment for getting the new ccid'
                             );
               l_found :=
                  fnd_flex_ext.get_combination_id ('SQLGL',
                                                   'GL#',
                                                   l_structnum,
                                                   SYSDATE,
                                                   l_numofsegments,
                                                   l_segments_sus,
                                                   p_new_ccid
                                                  );
               print_logfile (p_new_ccid || ' p_new_ccid');
            END IF;
         END IF;

-- Updateing with the new ccid
         print_logfile (p_new_ccid || ' p_new_ccid');
         FORALL i IN l_ccid.FIRST .. l_ccid.LAST
            UPDATE xla_ae_lines xal
               SET xal.code_combination_id = p_new_ccid
             WHERE application_id = p_application_id
               AND ae_header_id IN (
                      SELECT ae_header_id
                        FROM xla_ae_headers
                       WHERE accounting_batch_id = p_accounting_batch_id
                         AND application_id = p_application_id
                         AND ledger_id = p_ledger_id)
               AND code_combination_id = l_ccid (i);
         print_logfile (SQL%ROWCOUNT ||'No. Records Updated');
         COMMIT;
      ELSE
         print_logfile (   TO_CHAR (SYSDATE, 'DD-MON-YYYY HH24:MI:SS')
                        || ' - Starting of Update Invalid CCID '
                       );
         print_logfile (   'No. of Distinct CCID required to update  '
                        || p_ccid.COUNT
                       );

         IF p_ccid.COUNT > 0
         THEN
            print_logfile (':::CCIDs :::');

            FOR i IN l_ccid.FIRST .. l_ccid.LAST
            LOOP
               print_logfile (l_ccid (i));
            END LOOP;

            FORALL i IN l_ccid.FIRST .. l_ccid.LAST
               UPDATE    xla_ae_lines xal
                     SET xal.code_combination_id = p_status -- -2
                   WHERE application_id = p_application_id
                     AND ae_header_id IN (
                            SELECT ae_header_id
                              FROM xla_ae_headers
                             WHERE accounting_batch_id = p_accounting_batch_id
                               AND application_id = p_application_id
                               AND ledger_id = p_ledger_id)
                     AND code_combination_id = l_ccid (i)
               RETURNING         ae_header_id
               BULK COLLECT INTO l_ae_header_id;
            print_logfile ('No. of xla_ae_lines Records  ' || SQL%ROWCOUNT);
            FORALL j IN l_ae_header_id.FIRST .. l_ae_header_id.LAST
               UPDATE    xla_ae_headers
                     SET accounting_entry_status_code = 'I'
                   WHERE application_id = p_application_id
                     AND accounting_batch_id = p_accounting_batch_id
                     AND ae_header_id = l_ae_header_id (j)
               RETURNING         event_id
               BULK COLLECT INTO l_event_id;
            print_logfile ('No. of xla_ae_headers Records  ' || SQL%ROWCOUNT);
            FORALL k IN l_event_id.FIRST .. l_event_id.LAST
               UPDATE xla_ae_headers
                  SET accounting_entry_status_code = 'R'
                WHERE event_id = l_event_id (k)
                  AND application_id = p_application_id
                  AND accounting_batch_id = p_accounting_batch_id
                  AND accounting_entry_status_code <> 'I';
            print_logfile (   'No. of Related xla_ae_headers Records  '
                           || SQL%ROWCOUNT
                          );
            FORALL l IN l_event_id.FIRST .. l_event_id.LAST
               UPDATE xla_events
                  SET event_status_code = 'U',
                      process_status_code = 'I'
                WHERE application_id = p_application_id
                  AND event_id = l_event_id (l);
            print_logfile ('No. of xla_events Records  ' || SQL%ROWCOUNT);
         END IF;

----------------------------------------------------------------------------
-- Building the error message of the ccid invalid with the psft validation
----------------------------------------------------------------------------
    l_err_msg := nvl(substr(p_err_msg,1,240),'failed validation with external system');

         FOR n IN l_ae_header_id.FIRST .. l_ae_header_id.LAST
         LOOP
            SELECT ledger_id, entity_id, event_id
              INTO l_ledger_id, l_entity_id, l_vent_id
              FROM xla_ae_headers
             WHERE ae_header_id = l_ae_header_id (n);

----------------------------------------------------------------------------
 -- As the BPEL Prcoess faild to process the ccids with external system
 -- on the report).
 ----------------------------------------------------------------------------
            IF p_status = -3
            THEN
               xla_accounting_err_pkg.build_message (p_appli_s_name      => 'XLA',
                                                     p_msg_name          => 'XLA_EXT_SYS_CCID_VAL_FAIL',
                                                     p_token_1           => 'ERR_MEG',
                                                     p_value_1           => l_err_msg,
                                                     p_entity_id         => l_entity_id,
                                                     p_event_id          => l_vent_id,
                                                     p_ledger_id         => l_ledger_id,
                                                     p_ae_header_id      => l_ae_header_id (n
                                                                                           )
                                                    );
            ELSIF p_status = -2
            THEN
               xla_accounting_err_pkg.build_message (p_appli_s_name      => 'XLA',
                                                     p_msg_name          => 'XLA_EXT_VAL_FAIL_CCID',
                                                     p_entity_id         => l_entity_id,
                                                     p_event_id          => l_vent_id,
                                                     p_ledger_id         => l_ledger_id,
                                                     p_ae_header_id      => l_ae_header_id (n
                                                                                           )
                                                    );
            END IF;
         END LOOP;

----------------------------------------------------------------------------
 -- insert any errors that were build in this session (for them to appear
 -- on the report).
 ----------------------------------------------------------------------------
         xla_accounting_err_pkg.insert_errors;
         COMMIT;
      END IF; -- for sus
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END;
BEGIN
   g_log_level := fnd_log.g_current_runtime_level;
   g_log_enabled :=
          fnd_log.test (log_level      => g_log_level,
                        module         => c_default_module);

   IF NOT g_log_enabled
   THEN
      g_log_level := c_level_log_disabled;
   END IF;
END xla_update_inval_ccid;

/
