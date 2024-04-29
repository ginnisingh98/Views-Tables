--------------------------------------------------------
--  DDL for Package Body XLA_RETRIVE_CCID_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_RETRIVE_CCID_PKG" AS
/* $Header: xlarccid.pkb 120.1.12010000.2 2009/08/05 12:38:47 karamakr noship $ */
/*===========================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         ALL rights reserved.                               |
+============================================================================+
| PACKAGE NAME                                                               |
|     xla_retrive_ccid_pkg                                                   |
|                                                                            |
| DESCRIPTION                                                                |
|     Package body for the Retrive CCID's Program.                           |
|                                                                            |
| HISTORY                                                                    |
|     04/08/2008    T.V.Vamsi Krishna    Created                             |
+===========================================================================*/

   --=============================================================================
--               *********** Local Trace Line **********
--=============================================================================
   c_level_statement      CONSTANT NUMBER         := fnd_log.level_statement;
   c_level_procedure      CONSTANT NUMBER         := fnd_log.level_procedure;
   c_level_event          CONSTANT NUMBER         := fnd_log.level_event;
   c_level_exception      CONSTANT NUMBER         := fnd_log.level_exception;
   c_level_error          CONSTANT NUMBER         := fnd_log.level_error;
   c_level_unexpected     CONSTANT NUMBER         := fnd_log.level_unexpected;
   c_level_log_disabled   CONSTANT NUMBER         := 99;
   c_default_module       CONSTANT VARCHAR2 (240)
                                          := 'xla.plsql.xla_retrive_ccid_pkg';
   g_log_level                     NUMBER;
   g_log_enabled                   BOOLEAN;
   c_log_size             CONSTANT NUMBER         := 2000;
   c_ccid_unprocessed     CONSTANT VARCHAR2 (30)  := 'UNPROCESSED';
   c_ccid_processed       CONSTANT VARCHAR2 (30)  := 'PROCESSED';
   c_ccid_fail            CONSTANT VARCHAR2 (30)  := 'FAILED';
   c_ccid_success         CONSTANT VARCHAR2 (30)  := 'SUCCESSED';
   g_tot_ccid                      NUMBER;
   g_seq_context_value             t_array_number;

   PROCEDURE wait_for_requests (
      p_array_request_id   IN              t_array_number,
      p_error_status       OUT NOCOPY      VARCHAR2,
      p_warning_status     OUT NOCOPY      VARCHAR2
   );

   PROCEDURE wait_for_sing_req (
      p_request_id       IN              NUMBER,
      p_error_status     OUT NOCOPY      VARCHAR2,
      p_warning_status   OUT NOCOPY      VARCHAR2
   );

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
         xla_exceptions_pkg.raise_message
                                  (p_location      => 'xla_retrive_ccid_pkg.trace');
   END TRACE;

--=============================================================================
--                   ******* Print Log File **********
--=============================================================================
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
         xla_exceptions_pkg.raise_message
                          (p_location      => 'xla_retrive_ccid_pkg.print_logfile');
   END print_logfile;

--========================================================================================
-- Procedure to collect ccids and split them into ranges
--========================================================================================
   PROCEDURE collect_ccid_inf (
      p_application_id       IN   NUMBER,
      p_acc_batch_id         IN   NUMBER,
      p_ledger_id            IN   NUMBER,
      p_parent_request_id    IN   NUMBER,
      p_parallel_processes   IN   NUMBER
   )
   IS
      l_count             NUMBER         := 0;
      l_loop_count        NUMBER         := 0;
      l_parll_proc_size   NUMBER;
      l_log_module        VARCHAR2 (240);
      l_rec_count         NUMBER;
   BEGIN
      print_logfile (   TO_CHAR (SYSDATE, 'DD-MON-YYYY HH24:MI:SS')
                     || ' - Starting of the Collect CCID Information'
                    );

      IF g_log_enabled
      THEN
         l_log_module := c_default_module || '.collect_ccid_inf';
      END IF;

      IF (c_level_procedure >= g_log_level)
      THEN
         TRACE (p_msg         => 'BEGIN of procedure COLLECT_CCID_INF',
                p_level       => c_level_procedure,
                p_module      => l_log_module
               );
         TRACE (p_msg         =>    'p_application_id = '
                                 || TO_CHAR (p_application_id),
                p_level       => c_level_procedure,
                p_module      => l_log_module
               );
         TRACE (p_msg         => 'p_ledger_id = ' || TO_CHAR (p_ledger_id),
                p_level       => c_level_procedure,
                p_module      => l_log_module
               );
         TRACE (p_msg         =>    'p_accounting_batch_id = '
                                 || TO_CHAR (p_acc_batch_id),
                p_level       => c_level_procedure,
                p_module      => l_log_module
               );
         TRACE (p_msg         =>    'p_parent_request_id = '
                                 || TO_CHAR (p_parent_request_id),
                p_level       => c_level_procedure,
                p_module      => l_log_module
               );
         TRACE (p_msg         =>    'p_parallel_processes = '
                                 || TO_CHAR (p_parallel_processes),
                p_level       => c_level_procedure,
                p_module      => l_log_module
               );
      END IF;

----------------------------------------------------------------------------
-- Getting ledger ids that will be used/cached in this run of accounting
-- program
----------------------------------------------------------------------------
      SELECT xlr.ledger_id
      BULK COLLECT INTO g_seq_context_value
        FROM xla_ledger_relationships_v xlr, xla_subledger_options_v xso
       WHERE xlr.relationship_enabled_flag = 'Y'
         AND xlr.ledger_category_code IN ('ALC', 'PRIMARY', 'SECONDARY')
         AND DECODE (xso.valuation_method_flag,
                     'N', xlr.primary_ledger_id,
                     DECODE (xlr.ledger_category_code,
                             'ALC', xlr.primary_ledger_id,
                             xlr.ledger_id
                            )
                    ) = p_ledger_id
         AND xso.application_id = p_application_id
         AND xso.ledger_id =
                DECODE (xlr.ledger_category_code,
                        'ALC', xlr.primary_ledger_id,
                        xlr.ledger_id
                       )
         AND xso.enabled_flag = 'Y';

      print_logfile (   'Number of ledgers generated for this run = '
                     || g_seq_context_value.COUNT
                    );

      IF (c_level_statement >= g_log_level)
      THEN
         TRACE (p_msg         =>    'Number of ledgers generated for this run = '
                                 || g_seq_context_value.COUNT,
                p_level       => c_level_statement,
                p_module      => l_log_module
               );
      END IF;

-- Count total number of CCIDs for Primary and Secondary Ledgers
      BEGIN
         FOR i IN g_seq_context_value.FIRST .. g_seq_context_value.LAST
         LOOP
            SELECT NVL (MAX (ROWNUM), 0)
              INTO l_loop_count
              FROM gl_code_combinations gcc
             WHERE gcc.code_combination_id IN (
                      SELECT code_combination_id
                        FROM xla_ae_lines
                       WHERE ae_header_id IN (
                                SELECT ae_header_id
                                  FROM xla_ae_headers
                                 WHERE accounting_batch_id = p_acc_batch_id
                                   AND application_id = p_application_id
                                   AND ledger_id = g_seq_context_value (i)));

            l_count := l_count + NVL (l_loop_count, 0);
         END LOOP;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;
      END;

      g_tot_ccid := l_count;
      print_logfile ('Number of Distinct CCIDs :' || l_count);

      BEGIN
         IF p_parallel_processes <> 0 AND l_count <> 0
         THEN
            l_parll_proc_size := CEIL (l_count / p_parallel_processes);

            IF l_parll_proc_size <> 0
            THEN
               FOR i IN g_seq_context_value.FIRST .. g_seq_context_value.LAST
               LOOP
                  SELECT NVL (MAX (ROWNUM), 0)
                    INTO l_rec_count
                    FROM xla_ae_headers
                   WHERE accounting_batch_id = p_acc_batch_id
                     AND application_id = p_application_id
                     AND ledger_id = g_seq_context_value (i);

                  IF l_rec_count <> 0
                  THEN
                     INSERT INTO xla_fsah_ccid_ranges
                                 (parent_request_id, request_id, batch_id,
                                  application_id, ledger_id, from_ccid,
                                  to_ccid, status_code)
                        SELECT   p_parent_request_id, NULL, p_acc_batch_id,
                                 p_application_id, g_seq_context_value (i),
                                 MIN (code_combination_id),
                                 MAX (code_combination_id),
                                 c_ccid_unprocessed
                            FROM (SELECT   gcc.code_combination_id,
                                           CEIL
                                              (  SUM (COUNT (*)) OVER (ORDER BY gcc.code_combination_id ROWS UNBOUNDED PRECEDING)
                                               / l_parll_proc_size
                                              ) wu
                                      FROM gl_code_combinations gcc
                                     WHERE gcc.code_combination_id IN (
                                              SELECT code_combination_id
                                                FROM xla_ae_lines
                                               WHERE ae_header_id IN (
                                                        SELECT   ae_header_id
                                                            FROM xla_ae_headers
                                                           WHERE accounting_batch_id =
                                                                    p_acc_batch_id
                                                             AND application_id =
                                                                    p_application_id
                                                             AND ledger_id =
                                                                    g_seq_context_value
                                                                           (i)
                                                        GROUP BY ae_header_id))
                                  GROUP BY gcc.code_combination_id)
                        GROUP BY wu;
                  END IF;
               END LOOP;

               COMMIT;
            ELSE
               print_logfile ('No CCIDs are available for process');
            END IF;
         END IF;
      EXCEPTION
         WHEN OTHERS
         THEN
            NULL;
      END;

      print_logfile (   TO_CHAR (SYSDATE, 'DD-MON-YYYY HH24:MI:SS')
                     || ' - End of the Collect CCID Information'
                    );
   EXCEPTION
      WHEN xla_exceptions_pkg.application_exception
      THEN
         RAISE;
      WHEN OTHERS
      THEN
         xla_accounting_err_pkg.build_message
                                     (p_appli_s_name      => 'XLA',
                                      p_msg_name          => 'XLA_AP_TECHNICAL_ERROR',
                                      p_token_1           => 'APPLICATION_NAME',
                                      p_value_1           => 'SLA',
                                      p_entity_id         => NULL,
                                      p_event_id          => NULL
                                     );
         print_logfile ('Error occured in collect_ccid_inf');
         xla_exceptions_pkg.raise_message
                        (p_location      => 'xla_retrive_ccid_pkg.collect_ccid_inf');
   END collect_ccid_inf;

--===================================================================================
--Procedure for Update table xla_fsah_ccid_ranges with status
--===================================================================================
   PROCEDURE update_ccid_inf (
      p_parent_request_id   IN              NUMBER,
      p_from_ccid           OUT NOCOPY      NUMBER,
      p_to_ccid             OUT NOCOPY      NUMBER,
      p_ledger_id           OUT NOCOPY      NUMBER
   )
   IS
      l_log_module   VARCHAR2 (240);
   BEGIN
      print_logfile (   TO_CHAR (SYSDATE, 'DD-MON-YYYY HH24:MI:SS')
                     || ' - Starting of the Update CCID Information'
                    );

      IF g_log_enabled
      THEN
         l_log_module := c_default_module || '.update_ccid_inf';
      END IF;

      IF (c_level_procedure >= g_log_level)
      THEN
         TRACE (p_msg         => 'BEGIN of procedure UPDATE_CCID_INF',
                p_level       => c_level_procedure,
                p_module      => l_log_module
               );
         TRACE (p_msg         =>    'p_parent_request_id = '
                                 || TO_CHAR (p_parent_request_id),
                p_level       => c_level_procedure,
                p_module      => l_log_module
               );
         TRACE (p_msg         => 'p_from_ccid = ' || TO_CHAR (p_from_ccid),
                p_level       => c_level_procedure,
                p_module      => l_log_module
               );
         TRACE (p_msg         => 'p_to_ccid = ' || TO_CHAR (p_to_ccid),
                p_level       => c_level_procedure,
                p_module      => l_log_module
               );
      END IF;

      UPDATE    xla_fsah_ccid_ranges
            SET status_code = c_ccid_processed
          WHERE parent_request_id = p_parent_request_id
            AND status_code = c_ccid_unprocessed
            AND ROWNUM = 1
      RETURNING from_ccid, to_ccid, ledger_id
           INTO p_from_ccid, p_to_ccid, p_ledger_id;

      print_logfile (   TO_CHAR (SYSDATE, 'DD-MON-YYYY HH24:MI:SS')
                     || ' - End of the Update CCID Information'
                    );
   EXCEPTION
      WHEN xla_exceptions_pkg.application_exception
      THEN
         RAISE;
      WHEN OTHERS
      THEN
         xla_accounting_err_pkg.build_message
                                     (p_appli_s_name      => 'XLA',
                                      p_msg_name          => 'XLA_AP_TECHNICAL_ERROR',
                                      p_token_1           => 'APPLICATION_NAME',
                                      p_value_1           => 'SLA',
                                      p_entity_id         => NULL,
                                      p_event_id          => NULL
                                     );
         print_logfile ('Error occured in update_ccid_inf');
         xla_exceptions_pkg.raise_message
                         (p_location      => 'xla_retrive_ccid_pkg.update_ccid_inf');
   END update_ccid_inf;

--============================================================================================
   -- Procedure for getting CCID Information, CP which is called from Create Accounting Program
   -- and calls Java Concurrent Program based on number of Parallel Processors
--============================================================================================
   PROCEDURE get_ccid_information (
      errbuf                OUT NOCOPY      VARCHAR2,
      retcode               OUT NOCOPY      VARCHAR2,
      p_application_id      IN              NUMBER,
      p_acc_batch_id        IN              NUMBER,
      p_ledger_id           IN              NUMBER,
      p_parent_request_id   IN              NUMBER
   )
   IS
      l_array_ccid               t_array_ccid;
      l_javacp_request_id        t_array_number;
      l_javacp_request_id_sing   NUMBER;
      l_tot_ccid                 NUMBER (5);
      l_batch_count              NUMBER (4)
                               := fnd_profile.VALUE ('XLA_FSAH_EXT_THRD_CNT');
      l_parallel_processes       NUMBER
                              := fnd_profile.VALUE ('XLA_FSAH_EXT_THRD_SIZE');
      l_start_index              NUMBER (10);
      l_end_index                NUMBER (10);
      l_num_proc                 NUMBER (4)     := 0;
      l_seq_num                  NUMBER         := 0;
      l_error_status             VARCHAR2 (1)   := 'N';
      l_warning_status           VARCHAR2 (1)   := 'N';
      l_log_module               VARCHAR2 (240);
      l_application_id           NUMBER         := p_application_id;
      l_acc_batch_id             NUMBER         := p_acc_batch_id;
      l_ledger_id                NUMBER         := p_ledger_id;
      l_parent_request_id        NUMBER         := p_parent_request_id;
      l_ledger_id_i              NUMBER;
      l_callstatus               BOOLEAN;
      l_phase                    VARCHAR2 (30);
      l_status                   VARCHAR2 (30);
      l_dev_phase                VARCHAR2 (30);
      l_message                  VARCHAR2 (240);
      l_dev_status               VARCHAR2 (30);
      n                          NUMBER         := 0;
   BEGIN
      print_logfile (   TO_CHAR (SYSDATE, 'DD-MON-YYYY HH24:MI:SS')
                     || ' - Starting of the Retrive CCID Information'
                    );

      IF g_log_enabled
      THEN
         l_log_module := c_default_module || '.get_ccid_information';
      END IF;

      IF (c_level_procedure >= g_log_level)
      THEN
         TRACE (p_msg         => 'BEGIN of procedure GET_CCID_INFORMATION',
                p_level       => c_level_procedure,
                p_module      => l_log_module
               );
         TRACE (p_msg         =>    'p_application_id = '
                                 || TO_CHAR (p_application_id),
                p_level       => c_level_procedure,
                p_module      => l_log_module
               );
         TRACE (p_msg         => 'p_ledger_id = ' || TO_CHAR (p_ledger_id),
                p_level       => c_level_procedure,
                p_module      => l_log_module
               );
         TRACE (p_msg         =>    'p_accounting_batch_id = '
                                 || TO_CHAR (p_acc_batch_id),
                p_level       => c_level_procedure,
                p_module      => l_log_module
               );
      END IF;

      collect_ccid_inf (p_application_id          => l_application_id,
                        p_acc_batch_id            => l_acc_batch_id,
                        p_ledger_id               => l_ledger_id,
                        p_parent_request_id       => l_parent_request_id,
                        p_parallel_processes      => l_parallel_processes
                       );

      BEGIN
      IF g_tot_ccid <> 0 then
         IF g_tot_ccid <= l_parallel_processes
         THEN
            FOR i IN g_seq_context_value.FIRST .. g_seq_context_value.LAST
            LOOP
               l_javacp_request_id_sing :=
                  fnd_request.submit_request
                                        (application      => 'XLA',
                                         program          => 'XLAFSAHJCP',
                                         description      => NULL,
                                         start_time       => NULL,
                                         sub_request      => FALSE,
                                         argument1        => l_batch_count,
                                         argument2        => 0,
                                         argument3        => 0,
                                         argument4        => p_application_id,
                                         argument5        => p_acc_batch_id,
                                         argument6        => g_seq_context_value
                                                                           (i),
                                         -- ledger value
                                         argument7        => p_parent_request_id
                                        );
               COMMIT;
               wait_for_sing_req (p_request_id          => l_javacp_request_id_sing,
                                  p_error_status        => l_error_status,
                                  p_warning_status      => l_warning_status
                                 );
            END LOOP;
         ELSE
            FOR i IN g_seq_context_value.FIRST .. g_seq_context_value.LAST
            LOOP
               BEGIN
                  --print_logfile('Ledger Id from main loop: '||' '||g_seq_context_value(i));
                  LOOP
                     SELECT ledger_id, from_ccid
                       INTO l_ledger_id_i, l_start_index
                       FROM xla_fsah_ccid_ranges
                      WHERE parent_request_id = p_parent_request_id
                        AND status_code = 'UNPROCESSED'
                        AND ROWNUM = 1;

                     --  print_logfile('Ledger Id from table: '||' '||l_ledger_id_i);
                     EXIT WHEN l_start_index IS NULL
                           OR l_start_index = 0
                           OR g_seq_context_value (i) <> l_ledger_id_i;
                     update_ccid_inf
                                  (p_parent_request_id      => l_parent_request_id,
                                   p_from_ccid              => l_start_index,
                                   p_to_ccid                => l_end_index,
                                   p_ledger_id              => l_ledger_id_i
                                  );
                     l_javacp_request_id_sing :=
                        fnd_request.submit_request
                                             (application      => 'XLA',
                                              program          => 'XLAFSAHJCP',
                                              description      => NULL,
                                              start_time       => NULL,
                                              sub_request      => FALSE,
                                              argument1        => l_batch_count,
                                              argument2        => l_start_index,
                                              argument3        => l_end_index,
                                              argument4        => p_application_id,
                                              argument5        => p_acc_batch_id,
                                              argument6        => l_ledger_id_i,
                                              argument7        => p_parent_request_id
                                             );

                     UPDATE xla_fsah_ccid_ranges
                        SET request_id = l_javacp_request_id_sing
                      WHERE parent_request_id = p_parent_request_id
                        AND from_ccid = l_start_index
                        AND to_ccid = l_end_index;

                     IF l_javacp_request_id_sing = 0
                     THEN
                        xla_accounting_err_pkg.build_message
                                     (p_appli_s_name      => 'XLA',
                                      p_msg_name          => 'XLA_AP_TECHNICAL_ERROR',
                                      p_token_1           => 'APPLICATION_NAME',
                                      p_value_1           => 'SLA',
                                      p_entity_id         => NULL,
                                      p_event_id          => NULL
                                     );
                        print_logfile
                           ('Technical Error : Unable to submit Java Concurrent Program request'
                           );
                        xla_exceptions_pkg.raise_message
                                      (p_appli_s_name      => 'XLA',
                                       p_msg_name          => 'XLA_AP_TECHNICAL_ERROR',
                                       p_token_1           => 'APPLICATION_NAME',
                                       p_value_1           => 'SLA'
                                      );
                     ELSE
                        n := n + 1;
                        l_javacp_request_id (n) := l_javacp_request_id_sing;
                     END IF;
                  END LOOP;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     NULL;

               END;

               COMMIT;
               wait_for_requests (p_array_request_id      => l_javacp_request_id,
                                  p_error_status          => l_error_status,
                                  p_warning_status        => l_warning_status
                                 );
               print_logfile (   'Number of java cp launched for Ledger '
                              || g_seq_context_value (i)
                              || ' '
                              || 'is/are :::'
                              || ' '
                              || l_javacp_request_id.COUNT
                             );
               l_javacp_request_id.DELETE;
               n := 0;
            END LOOP;
         END IF;
       END IF;
      EXCEPTION
         WHEN OTHERS
         THEN
            print_logfile (SQLERRM);
      END;

/*-------------------------------------------------------------------------
-- Commit is required after fnd_request.submit_request
-------------------------------------------------------------------------
      COMMIT;
-------------------------------------------------------------------------
-- wait for requests to complete
-------------------------------------------------------------------------
      wait_for_requests (p_array_request_id      => l_javacp_request_id,
                         p_error_status          => l_error_status,
                         p_warning_status        => l_warning_status
                        );
---------------------------------------------------------------------------
-- Delete rows from table for ranges which are having status 'SUCCESSFUL'
--------------------------------------------------------------------------- */
      DELETE FROM xla_fsah_ccid_ranges
            WHERE status_message = 'SUCCESSFUL';

      COMMIT;
      print_logfile (   TO_CHAR (SYSDATE, 'DD-MON-YYYY HH24:MI:SS')
                     || ' - Ending of the Retrive CCID Information'
                    );
   EXCEPTION
      WHEN xla_exceptions_pkg.application_exception
      THEN
         RAISE;
      WHEN OTHERS
      THEN
         xla_accounting_err_pkg.build_message
                                     (p_appli_s_name      => 'XLA',
                                      p_msg_name          => 'XLA_AP_TECHNICAL_ERROR',
                                      p_token_1           => 'APPLICATION_NAME',
                                      p_value_1           => 'SLA',
                                      p_entity_id         => NULL,
                                      p_event_id          => NULL
                                     );
         print_logfile ('Error occured in get_ccid_information');
         xla_exceptions_pkg.raise_message
                    (p_location      => 'xla_retrive_ccid_pkg.get_ccid_information');
   END get_ccid_information;

--============================================================================================
-- Procedure for getting CCIDs for the given range i.e CCIDs between min_num and max_num
-- This procedure is calling from Java Concurrent Program
--============================================================================================
   PROCEDURE get_thread_ccid_inf (
      p_min_num             IN              NUMBER,
      p_max_num             IN              NUMBER,
      p_out_ccid            OUT NOCOPY      t_xla_array_ccid_inf,
      p_application_id      IN              NUMBER,
      p_acc_batch_id        IN              NUMBER,
      p_ledger_id           IN              NUMBER,
      p_parent_request_id   IN              NUMBER
   )
   IS
      l_thread_ccid_inf   t_xla_array_ccid_inf;
      l_log_module        VARCHAR2 (240);
   BEGIN
      print_logfile (   TO_CHAR (SYSDATE, 'DD-MON-YYYY HH24:MI:SS')
                     || ' - Starting of the Retrive Thread CCID Information'
                    );

      IF g_log_enabled
      THEN
         l_log_module := c_default_module || '.get_thread_ccid_inf ';
      END IF;

      IF (c_level_procedure >= g_log_level)
      THEN
         TRACE (p_msg         => 'BEGIN of procedure GET_THREAD_CCID_INF',
                p_level       => c_level_procedure,
                p_module      => l_log_module
               );
         TRACE (p_msg         => 'p_min_num = ' || TO_CHAR (p_min_num),
                p_level       => c_level_procedure,
                p_module      => l_log_module
               );
         TRACE (p_msg         => 'p_max_num = ' || TO_CHAR (p_max_num),
                p_level       => c_level_procedure,
                p_module      => l_log_module
               );
         TRACE (p_msg         =>    'application_id = '
                                 || TO_CHAR (p_application_id),
                p_level       => c_level_procedure,
                p_module      => l_log_module
               );
         TRACE (p_msg         => 'ledger_id = ' || TO_CHAR (p_ledger_id),
                p_level       => c_level_procedure,
                p_module      => l_log_module
               );
         TRACE (p_msg         =>    'accounting_batch_id = '
                                 || TO_CHAR (p_acc_batch_id),
                p_level       => c_level_procedure,
                p_module      => l_log_module
               );
      END IF;

      IF (p_min_num <> 0 AND p_max_num <> 0)
      THEN
         SELECT xla_array_ccid_inf (e.id_flex_structure_name,
                                    e.chart_of_accounts_id,
                                    e.code_combination_id,
                                    e.segment1,
                                    e.seg1_name,
                                    e.segment2,
                                    e.seg2_name,
                                    e.segment3,
                                    e.seg3_name,
                                    e.segment4,
                                    e.seg4_name,
                                    e.segment5,
                                    e.seg5_name,
                                    e.segment6,
                                    e.seg6_name,
                                    e.segment7,
                                    e.seg7_name,
                                    e.segment8,
                                    e.seg8_name,
                                    e.segment9,
                                    e.seg9_name,
                                    e.segment10,
                                    e.seg10_name,
                                    e.segment11,
                                    e.seg11_name,
                                    e.segment12,
                                    e.seg12_name,
                                    e.segment13,
                                    e.seg13_name,
                                    e.segment14,
                                    e.seg14_name,
                                    e.segment15,
                                    e.seg15_name,
                                    e.segment16,
                                    e.seg16_name,
                                    e.segment17,
                                    e.seg17_name,
                                    e.segment18,
                                    e.seg18_name,
                                    e.segment19,
                                    e.seg19_name,
                                    e.segment20,
                                    e.seg20_name,
                                    e.segment21,
                                    e.seg21_name,
                                    e.segment22,
                                    e.seg22_name,
                                    e.segment23,
                                    e.seg23_name,
                                    e.segment24,
                                    e.seg24_name,
                                    e.segment25,
                                    e.seg25_name,
                                    e.segment26,
                                    e.seg26_name,
                                    e.segment27,
                                    e.seg27_name,
                                    e.segment28,
                                    e.seg28_name,
                                    e.segment29,
                                    e.seg29_name,
                                    e.segment30,
                                    e.seg30_name
                                   )
         BULK COLLECT INTO l_thread_ccid_inf
           FROM (SELECT ffsv.id_flex_structure_name, gcc.chart_of_accounts_id,
                        gcc.code_combination_id, gcc.segment1,
                        'SEGMENT1' seg1_name, gcc.segment2,
                        'SEGMENT2' seg2_name, gcc.segment3,
                        'SEGMENT3' seg3_name, gcc.segment4,
                        'SEGMENT4' seg4_name, gcc.segment5,
                        'SEGMENT5' seg5_name, gcc.segment6,
                        'SEGMENT6' seg6_name, gcc.segment7,
                        'SEGMENT7' seg7_name, gcc.segment8,
                        'SEGMENT8' seg8_name, gcc.segment9,
                        'SEGMENT9' seg9_name, gcc.segment10,
                        'SEGMENT10' seg10_name, gcc.segment11,
                        'SEGMENT11' seg11_name, gcc.segment12,
                        'SEGMENT12' seg12_name, gcc.segment13,
                        'SEGMENT13' seg13_name, gcc.segment14,
                        'SEGMENT14' seg14_name, gcc.segment15,
                        'SEGMENT15' seg15_name, gcc.segment16,
                        'SEGMENT16' seg16_name, gcc.segment17,
                        'SEGMENT17' seg17_name, gcc.segment18,
                        'SEGMENT18' seg18_name, gcc.segment19,
                        'SEGMENT19' seg19_name, gcc.segment20,
                        'SEGMENT20' seg20_name, gcc.segment21,
                        'SEGMENT21' seg21_name, gcc.segment22,
                        'SEGMENT22' seg22_name, gcc.segment23,
                        'SEGMENT23' seg23_name, gcc.segment24,
                        'SEGMENT24' seg24_name, gcc.segment25,
                        'SEGMENT25' seg25_name, gcc.segment26,
                        'SEGMENT26' seg26_name, gcc.segment27,
                        'SEGMENT27' seg27_name, gcc.segment28,
                        'SEGMENT28' seg28_name, gcc.segment29,
                        'SEGMENT29' seg29_name, gcc.segment30,
                        'SEGMENT30' seg30_name
                   FROM gl_code_combinations gcc,
                        fnd_id_flex_structures_vl ffsv
                  WHERE gcc.chart_of_accounts_id = ffsv.id_flex_num
                    AND ffsv.application_id = 101
                    AND ffsv.id_flex_code = 'GL#'
                    AND gcc.code_combination_id IN (
                           SELECT code_combination_id
                             FROM xla_ae_lines
                            WHERE ae_header_id IN (
                                     SELECT ae_header_id
                                       FROM xla_ae_headers
                                      WHERE accounting_batch_id =
                                                                p_acc_batch_id
                                        AND application_id = p_application_id
                                        AND ledger_id = p_ledger_id))) e
          WHERE e.code_combination_id BETWEEN p_min_num AND p_max_num;
      ELSE
         SELECT xla_array_ccid_inf (e.id_flex_structure_name,
                                    e.chart_of_accounts_id,
                                    e.code_combination_id,
                                    e.segment1,
                                    e.seg1_name,
                                    e.segment2,
                                    e.seg2_name,
                                    e.segment3,
                                    e.seg3_name,
                                    e.segment4,
                                    e.seg4_name,
                                    e.segment5,
                                    e.seg5_name,
                                    e.segment6,
                                    e.seg6_name,
                                    e.segment7,
                                    e.seg7_name,
                                    e.segment8,
                                    e.seg8_name,
                                    e.segment9,
                                    e.seg9_name,
                                    e.segment10,
                                    e.seg10_name,
                                    e.segment11,
                                    e.seg11_name,
                                    e.segment12,
                                    e.seg12_name,
                                    e.segment13,
                                    e.seg13_name,
                                    e.segment14,
                                    e.seg14_name,
                                    e.segment15,
                                    e.seg15_name,
                                    e.segment16,
                                    e.seg16_name,
                                    e.segment17,
                                    e.seg17_name,
                                    e.segment18,
                                    e.seg18_name,
                                    e.segment19,
                                    e.seg19_name,
                                    e.segment20,
                                    e.seg20_name,
                                    e.segment21,
                                    e.seg21_name,
                                    e.segment22,
                                    e.seg22_name,
                                    e.segment23,
                                    e.seg23_name,
                                    e.segment24,
                                    e.seg24_name,
                                    e.segment25,
                                    e.seg25_name,
                                    e.segment26,
                                    e.seg26_name,
                                    e.segment27,
                                    e.seg27_name,
                                    e.segment28,
                                    e.seg28_name,
                                    e.segment29,
                                    e.seg29_name,
                                    e.segment30,
                                    e.seg30_name
                                   )
         BULK COLLECT INTO l_thread_ccid_inf
           FROM (SELECT ffsv.id_flex_structure_name, gcc.chart_of_accounts_id,
                        gcc.code_combination_id, gcc.segment1,
                        'SEGMENT1' seg1_name, gcc.segment2,
                        'SEGMENT2' seg2_name, gcc.segment3,
                        'SEGMENT3' seg3_name, gcc.segment4,
                        'SEGMENT4' seg4_name, gcc.segment5,
                        'SEGMENT5' seg5_name, gcc.segment6,
                        'SEGMENT6' seg6_name, gcc.segment7,
                        'SEGMENT7' seg7_name, gcc.segment8,
                        'SEGMENT8' seg8_name, gcc.segment9,
                        'SEGMENT9' seg9_name, gcc.segment10,
                        'SEGMENT10' seg10_name, gcc.segment11,
                        'SEGMENT11' seg11_name, gcc.segment12,
                        'SEGMENT12' seg12_name, gcc.segment13,
                        'SEGMENT13' seg13_name, gcc.segment14,
                        'SEGMENT14' seg14_name, gcc.segment15,
                        'SEGMENT15' seg15_name, gcc.segment16,
                        'SEGMENT16' seg16_name, gcc.segment17,
                        'SEGMENT17' seg17_name, gcc.segment18,
                        'SEGMENT18' seg18_name, gcc.segment19,
                        'SEGMENT19' seg19_name, gcc.segment20,
                        'SEGMENT20' seg20_name, gcc.segment21,
                        'SEGMENT21' seg21_name, gcc.segment22,
                        'SEGMENT22' seg22_name, gcc.segment23,
                        'SEGMENT23' seg23_name, gcc.segment24,
                        'SEGMENT24' seg24_name, gcc.segment25,
                        'SEGMENT25' seg25_name, gcc.segment26,
                        'SEGMENT26' seg26_name, gcc.segment27,
                        'SEGMENT27' seg27_name, gcc.segment28,
                        'SEGMENT28' seg28_name, gcc.segment29,
                        'SEGMENT29' seg29_name, gcc.segment30,
                        'SEGMENT30' seg30_name
                   FROM gl_code_combinations gcc,
                        fnd_id_flex_structures_vl ffsv
                  WHERE gcc.chart_of_accounts_id = ffsv.id_flex_num
                    AND ffsv.application_id = 101
                    AND ffsv.id_flex_code = 'GL#'
                    AND gcc.code_combination_id IN (
                           SELECT code_combination_id
                             FROM xla_ae_lines
                            WHERE ae_header_id IN (
                                     SELECT ae_header_id
                                       FROM xla_ae_headers
                                      WHERE accounting_batch_id =
                                                                p_acc_batch_id
                                        AND application_id = p_application_id
                                        AND ledger_id = p_ledger_id))) e;
      END IF;

      p_out_ccid := l_thread_ccid_inf;
      print_logfile (   TO_CHAR (SYSDATE, 'DD-MON-YYYY HH24:MI:SS')
                     || ' - End of the Retrive Thread CCID Information'
                    );
   EXCEPTION
      WHEN xla_exceptions_pkg.application_exception
      THEN
         RAISE;
      WHEN OTHERS
      THEN
         xla_accounting_err_pkg.build_message
                                     (p_appli_s_name      => 'XLA',
                                      p_msg_name          => 'XLA_AP_TECHNICAL_ERROR',
                                      p_token_1           => 'APPLICATION_NAME',
                                      p_value_1           => 'SLA',
                                      p_entity_id         => NULL,
                                      p_event_id          => NULL
                                     );
         print_logfile ('Error occured in get_thread_ccid_inf');
         xla_exceptions_pkg.raise_message
                     (p_location      => 'xla_retrive_ccid_pkg.get_thread_ccid_inf');
   END get_thread_ccid_inf;

--============================================================================================
-- Procedure for getting CCID Sequence Numbers
-- This Procedure is calling from Java Concurrent program
--============================================================================================
   PROCEDURE get_ccid_seq (
      p_coa_num        IN              NUMBER,
      p_ccid_seq_out   OUT NOCOPY      t_xla_array_ccid_seq_inf
   )
   IS
      l_log_module   VARCHAR2 (240);
   BEGIN
      print_logfile (   TO_CHAR (SYSDATE, 'DD-MON-YYYY HH24:MI:SS')
                     || ' - Starting of the Retrive CCID Sequence Information'
                    );

      IF g_log_enabled
      THEN
         l_log_module := c_default_module || '.get_ccid_seq ';
      END IF;

      IF (c_level_procedure >= g_log_level)
      THEN
         TRACE (p_msg         => 'BEGIN of procedure GET_CCID_SEQ',
                p_level       => c_level_procedure,
                p_module      => l_log_module
               );
         TRACE (p_msg         => 'p_coa_num = ' || TO_CHAR (p_coa_num),
                p_level       => c_level_procedure,
                p_module      => l_log_module
               );
      END IF;

      SELECT xla_array_ccid_seq_inf (e.application_column_name, e.segment_num)
      BULK COLLECT INTO p_ccid_seq_out
        FROM fnd_id_flex_segments e
       WHERE e.id_flex_code = 'GL#' AND e.id_flex_num = p_coa_num;

      print_logfile (   TO_CHAR (SYSDATE, 'DD-MON-YYYY HH24:MI:SS')
                     || ' - Ending of the Retrive CCID Sequence Information'
                    );
   EXCEPTION
      WHEN xla_exceptions_pkg.application_exception
      THEN
         RAISE;
      WHEN OTHERS
      THEN
         xla_accounting_err_pkg.build_message
                                     (p_appli_s_name      => 'XLA',
                                      p_msg_name          => 'XLA_AP_TECHNICAL_ERROR',
                                      p_token_1           => 'APPLICATION_NAME',
                                      p_value_1           => 'SLA',
                                      p_entity_id         => NULL,
                                      p_event_id          => NULL
                                     );
         print_logfile ('Error occured in get_ccid_seq');
         xla_exceptions_pkg.raise_message
                            (p_location      => 'xla_retrive_ccid_pkg.get_ccid_seq');
   END get_ccid_seq;

--=============================================================================
--
-- Procedure for Wait for request
--
--=============================================================================
   PROCEDURE wait_for_requests (
      p_array_request_id   IN              t_array_number,
      p_error_status       OUT NOCOPY      VARCHAR2,
      p_warning_status     OUT NOCOPY      VARCHAR2
   )
   IS
      l_phase        VARCHAR2 (30);
      l_status       VARCHAR2 (30);
      l_dphase       VARCHAR2 (30);
      l_dstatus      VARCHAR2 (30);
      l_message      VARCHAR2 (240);
      l_btemp        BOOLEAN;
      l_log_module   VARCHAR2 (240);
   BEGIN
      IF g_log_enabled
      THEN
         l_log_module := c_default_module || '.wait_for_requests';
      END IF;

      IF (c_level_procedure >= g_log_level)
      THEN
         TRACE (p_msg         => 'BEGIN of procedure WAIT_FOR_REQUESTS',
                p_level       => c_level_procedure,
                p_module      => l_log_module
               );
      END IF;

----------------------------------------------------------------------------
-- Waiting for active/pending requests to complete
----------------------------------------------------------------------------
      IF p_array_request_id.COUNT > 0
      THEN
         FOR i IN 1 .. p_array_request_id.COUNT
         LOOP
            IF (c_level_statement >= g_log_level)
            THEN
               TRACE (p_msg         =>    'waiting for request id = '
                                       || p_array_request_id (i),
                      p_level       => c_level_statement,
                      p_module      => l_log_module
                     );
            END IF;

            l_btemp :=
               fnd_concurrent.wait_for_request
                                         (request_id      => p_array_request_id
                                                                           (i),
                                          INTERVAL        => 30,
                                          phase           => l_phase,
                                          status          => l_status,
                                          dev_phase       => l_dphase,
                                          dev_status      => l_dstatus,
                                          MESSAGE         => l_message
                                         );

            UPDATE xla_fsah_ccid_ranges
               SET status_message = l_message
             WHERE request_id = p_array_request_id (i);

            IF NOT l_btemp
            THEN
               xla_accounting_err_pkg.build_message
                                     (p_appli_s_name      => 'XLA',
                                      p_msg_name          => 'XLA_AP_TECHNICAL_ERROR',
                                      p_token_1           => 'APPLICATION_NAME',
                                      p_value_1           => 'SLA',
                                      p_entity_id         => NULL,
                                      p_event_id          => NULL
                                     );
               print_logfile
                  (   'Technical problem : FND_CONCURRENT.WAIT_FOR_REQUEST returned FALSE '
                   || 'while executing for request id '
                   || p_array_request_id (i)
                  );
            ELSE
               IF (c_level_event >= g_log_level)
               THEN
                  TRACE (p_msg         =>    'request completed with status = '
                                          || l_status,
                         p_level       => c_level_event,
                         p_module      => l_log_module
                        );
               END IF;

               IF l_dstatus = 'WARNING'
               THEN
                  p_warning_status := 'Y';

                  UPDATE xla_fsah_ccid_ranges
                     SET status_message = l_message
                   WHERE request_id = p_array_request_id (i);
               ELSIF l_dstatus = 'ERROR'
               THEN
                  p_error_status := 'Y';

                  UPDATE xla_fsah_ccid_ranges
                     SET status_message = l_message
                   WHERE request_id = p_array_request_id (i);
               END IF;

               COMMIT;
            END IF;
         END LOOP;
      END IF;

      IF (c_level_procedure >= g_log_level)
      THEN
         TRACE (p_msg         => 'END of procedure WAIT_FOR_REQUESTS',
                p_level       => c_level_procedure,
                p_module      => l_log_module
               );
      END IF;
   EXCEPTION
      WHEN xla_exceptions_pkg.application_exception
      THEN
         RAISE;
      WHEN OTHERS
      THEN
         xla_exceptions_pkg.raise_message
                        (p_location      => 'xla_accounting_pkg.wait_for_requests');
   END wait_for_requests;

-- end of procedure

   --=============================================================================
--
--
--
--=============================================================================
   PROCEDURE wait_for_sing_req (
      p_request_id       IN              NUMBER,
      p_error_status     OUT NOCOPY      VARCHAR2,
      p_warning_status   OUT NOCOPY      VARCHAR2
   )
   IS
      l_phase        VARCHAR2 (30);
      l_status       VARCHAR2 (30);
      l_dphase       VARCHAR2 (30);
      l_dstatus      VARCHAR2 (30);
      l_message      VARCHAR2 (240);
      l_btemp        BOOLEAN;
      l_log_module   VARCHAR2 (240);
   BEGIN
      IF g_log_enabled
      THEN
         l_log_module := c_default_module || '.wait_for_combo_edit_req';
      END IF;

      IF (c_level_procedure >= g_log_level)
      THEN
         TRACE (p_msg         => 'BEGIN of procedure WAIT_FOR_COMBO_EDIT_REQ',
                p_level       => c_level_procedure,
                p_module      => l_log_module
               );
      END IF;

----------------------------------------------------------------------------
-- Waiting for active/pending requests to complete
----------------------------------------------------------------------------
      IF p_request_id <> 0
      THEN
         l_btemp :=
            fnd_concurrent.wait_for_request (request_id      => p_request_id,
                                             INTERVAL        => 30,
                                             phase           => l_phase,
                                             status          => l_status,
                                             dev_phase       => l_dphase,
                                             dev_status      => l_dstatus,
                                             MESSAGE         => l_message
                                            );

         IF NOT l_btemp
         THEN
            xla_accounting_err_pkg.build_message
                                     (p_appli_s_name      => 'XLA',
                                      p_msg_name          => 'XLA_AP_TECHNICAL_ERROR',
                                      p_token_1           => 'APPLICATION_NAME',
                                      p_value_1           => 'SLA',
                                      p_entity_id         => NULL,
                                      p_event_id          => NULL
                                     );
            print_logfile
               (   'Technical problem : FND_CONCURRENT.WAIT_FOR_REQUEST returned FALSE '
                || 'while executing for request id '
                || p_request_id
               );
         ELSE
            IF (c_level_event >= g_log_level)
            THEN
               TRACE (p_msg         =>    'request completed with status = '
                                       || l_status,
                      p_level       => c_level_event,
                      p_module      => l_log_module
                     );
            END IF;

            IF l_dstatus = 'WARNING'
            THEN
               p_warning_status := 'Y';
            ELSIF l_dstatus = 'ERROR'
            THEN
               p_error_status := 'Y';
            END IF;
         END IF;
      END IF;

      IF (c_level_procedure >= g_log_level)
      THEN
         TRACE (p_msg         => 'END of procedure WAIT_FOR_SING_REQUESTS',
                p_level       => c_level_procedure,
                p_module      => l_log_module
               );
      END IF;
   EXCEPTION
      WHEN xla_exceptions_pkg.application_exception
      THEN
         RAISE;
      WHEN OTHERS
      THEN
         xla_exceptions_pkg.raise_message
                  (p_location      => 'xla_accounting_pkg.wait_for_combo_edit_req');
   END wait_for_sing_req;                                  -- end of procedure
BEGIN
   g_log_level := fnd_log.g_current_runtime_level;
   g_log_enabled :=
          fnd_log.TEST (log_level      => g_log_level,
                        module         => c_default_module);

   IF NOT g_log_enabled
   THEN
      g_log_level := c_level_log_disabled;
   END IF;
END xla_retrive_ccid_pkg;

/
