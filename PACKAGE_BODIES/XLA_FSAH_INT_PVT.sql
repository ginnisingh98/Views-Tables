--------------------------------------------------------
--  DDL for Package Body XLA_FSAH_INT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_FSAH_INT_PVT" AS
/* $Header: xlafsipvt.pkb 120.27.12010000.2 2009/08/05 11:41:49 karamakr noship $ */
/*================================================================================+
| FILENAME                                                                        |
|    xlafsipvt.pkb                                                                |
|                                                                                 |
| PACKAGE NAME                                                                    |
|    xla_fsah_int_pvt                                                             |
|                                                                                 |
| DESCRIPTION                                                                     |
|    This is a XLA private package, which contains all the fucntions and          |
|    procedures which required to update and reprocess the successfull and        |
|    non-succesfull transactions                                                  |
|    and tranfermations to people soft General Ledger.                            |
|                                                                                 |
|    Also API Return The new group_id for the further Successfull Update          |
|                                                                                 |
|                                                                                 |
|    Note:                                                                        |
|       - the APIs do not execute any COMMIT or ROLLBACK.                         |
|                                                                                 |
| HISTORY                                                                         |
| -------                                                                         |
| 26-Jun-08    JAGAN KODURI                                                       |
| 30-Dec-08    JAGAN KODURI Updating the Original Event status to 'I' and 'U'     |                                                                        |                                                                                 |
|                                                                                 |
| PARAMETER DESCRIPTION                                                           |
| ---------------------                                                           |
|                                                                                 |
| SET_GROUP_ID                                                                    |
| ------------                                                                    |
| p_ledger_short_name         :in parameter                                       |
|                                                                                 |
| SET_TRANSFER_STATUS                                                             |
| --------------------                                                            |
| p_group_id         :in parameter (xla_fsah_int_pvt.group_id)                    |
| p_batch_status     :in parameter (F/S)                                          |
| p_api_version      :in parameter (Default API version 1.0)                      |
| p_return_status    :out parameter (Use to Return Process Successfull Status)    |
| p_msg_data         :out parameter (Default API out to Error count)              |
| p_msg_count        :out parameter (return New Group Id for New Process Update)  |
|                                                                                 |
+================================================================================*/

   --==================================================================================
-- global declaration
--==================================================================================
      TYPE t_je_info IS RECORD (
      header_id                        INTEGER,
      ledger_id                        INTEGER,
      legal_entity_id                  INTEGER,
      application_id                   INTEGER,
      entity_id                        INTEGER,
      event_id                         INTEGER,
      gl_date                          DATE,
      status_code                      VARCHAR2 (30),
      type_code                        VARCHAR2 (30),
      description                      VARCHAR2 (2400),
      balance_type_code                VARCHAR2 (30),
      budget_version_id                INTEGER,
      reference_date                   DATE,
      funds_status_code                VARCHAR2 (30),
      je_category_name                 VARCHAR2 (80),
      packet_id                        INTEGER,
      amb_context_code                 VARCHAR2 (30),
      event_type_code                  VARCHAR2 (30),
      completed_date                   DATE,
      gl_transfer_status_code          VARCHAR2 (30),
      accounting_batch_id              INTEGER,
      period_name                      VARCHAR2 (15),
      product_rule_code                VARCHAR2 (30),
      product_rule_type_code           VARCHAR2 (30),
      product_rule_version             VARCHAR2 (30),
      gl_transfer_date                 DATE,
      doc_sequence_id                  INTEGER,
      doc_sequence_value               VARCHAR2 (240),
      close_acct_seq_version_id        INTEGER,
      close_acct_seq_value             VARCHAR2 (240),
      close_acct_seq_assign_id         INTEGER,
      completion_acct_seq_version_id   INTEGER,
      completion_acct_seq_value        VARCHAR2 (240),
      completion_acct_seq_assign_id    INTEGER,
      accrual_reversal_flag            VARCHAR2 (1),
      budgetary_control_flag           VARCHAR2 (1),
      attribute_category               VARCHAR2 (30),
      attribute1                       VARCHAR2 (150),
      attribute2                       VARCHAR2 (150),
      attribute3                       VARCHAR2 (150),
      attribute4                       VARCHAR2 (150),
      attribute5                       VARCHAR2 (150),
      attribute6                       VARCHAR2 (150),
      attribute7                       VARCHAR2 (150),
      attribute8                       VARCHAR2 (150),
      attribute9                       VARCHAR2 (150),
      attribute10                      VARCHAR2 (150),
      attribute11                      VARCHAR2 (150),
      attribute12                      VARCHAR2 (150),
      attribute13                      VARCHAR2 (150),
      attribute14                      VARCHAR2 (150),
      attribute15                      VARCHAR2 (150)
   );

--=============================================================================
--               *********** LOCAL TRACE ROUTINE **********
--=============================================================================
   TYPE t_array_integer IS TABLE OF INTEGER
      INDEX BY BINARY_INTEGER;

   TYPE t_array_char1 IS TABLE OF VARCHAR2 (1)
      INDEX BY BINARY_INTEGER;

   TYPE t_array_char30 IS TABLE OF VARCHAR2 (30)
      INDEX BY BINARY_INTEGER;

   c_level_statement           CONSTANT NUMBER      := fnd_log.level_statement;
   c_level_procedure           CONSTANT NUMBER      := fnd_log.level_procedure;
   c_level_event               CONSTANT NUMBER         := fnd_log.level_event;
   c_level_exception           CONSTANT NUMBER      := fnd_log.level_exception;
   c_level_error               CONSTANT NUMBER         := fnd_log.level_error;
   c_level_unexpected          CONSTANT NUMBER     := fnd_log.level_unexpected;
   c_level_log_disabled        CONSTANT NUMBER         := 99;
   c_default_module            CONSTANT VARCHAR2 (240)
                                              := 'XLA.PLSQL.XLA_FSAH_INT_PVT';
--=============================================================================
--               *********** PRIVATE GLOBAL CONSTANT **********
--=============================================================================
   c_status_final_code         CONSTANT VARCHAR2 (1)   := 'F';
   c_entity_type_code_manual   CONSTANT VARCHAR2 (30)  := 'MANUAL';
   c_reversal_switch_dr_cr     CONSTANT VARCHAR2 (30)  := 'SIDE';
   c_event_type_code_manual    CONSTANT VARCHAR2 (30)  := 'MANUAL';
   c_event_class_code_manual   CONSTANT VARCHAR2 (30)  := 'MANUAL';
   c_gl_application_id         CONSTANT INTEGER        := 101;
   c_ae_status_incomplete      CONSTANT VARCHAR2 (30)  := 'N';
   c_gl_transfer_mode_no       CONSTANT VARCHAR2 (30)  := 'N';
   g_log_level                          NUMBER;
   g_log_enabled                        BOOLEAN;
   g_msg_mode                           VARCHAR2 (200)
                                 DEFAULT xla_exceptions_pkg.c_standard_message;

----------------------------------------------------------------------------
-- FOLLOWING IS FOR FND LOG.
----------------------------------------------------------------------------
   PROCEDURE TRACE (p_msg IN VARCHAR2, p_module IN VARCHAR2, p_level IN NUMBER)
   IS
   BEGIN
      IF (p_msg IS NULL AND p_level >= g_log_level)
      THEN
         fnd_log.MESSAGE (p_level, p_module);
      ELSIF p_level >= g_log_level
      THEN
         fnd_log.STRING (p_level, p_module, p_msg);
      END IF;
   EXCEPTION
      WHEN xla_exceptions_pkg.application_exception
      THEN
         RAISE;
      WHEN OTHERS
      THEN
         xla_exceptions_pkg.raise_message (p_location      => 'XLA_FSAH_INT_PVT.TRACE'
                                          );
   END TRACE;

--=============================================================================
--
-- NAME         : GET_HEADER_INFO
-- DESCRIPTION  : RETRIEVE HEADER INFORMATION.
-- RETURN       : T_JE_INFO
--
--=============================================================================
   FUNCTION get_header_info (
      p_ae_header_id     IN   INTEGER,
      p_application_id   IN   INTEGER,
      p_msg_mode         IN   VARCHAR2
   )
      RETURN t_je_info
   IS
      CURSOR c_header
      IS
         SELECT     xah.ae_header_id, xah.ledger_id, xte.legal_entity_id,
                    xah.application_id, xah.entity_id, xah.event_id,
                    xah.accounting_date, xah.accounting_entry_status_code,
                    xah.accounting_entry_type_code, xah.description,
                    xah.balance_type_code, xah.budget_version_id,
                    xah.reference_date, xah.funds_status_code,
                    xah.je_category_name, xah.packet_id,
                    xah.amb_context_code, xah.event_type_code,
                    xah.completed_date, xah.gl_transfer_status_code,
                    xah.accounting_batch_id, xah.period_name,
                    xah.product_rule_code, xah.product_rule_type_code,
                    xah.product_rule_version, xah.gl_transfer_date,
                    xah.doc_sequence_id, xah.doc_sequence_value,
                    xah.close_acct_seq_version_id, xah.close_acct_seq_value,
                    xah.close_acct_seq_assign_id,
                    xah.completion_acct_seq_version_id,
                    xah.completion_acct_seq_value,
                    xah.completion_acct_seq_assign_id,
                    NVL (xah.accrual_reversal_flag, 'N'),
                    xe.budgetary_control_flag, xah.attribute_category,
                    xah.attribute1, xah.attribute2, xah.attribute3,
                    xah.attribute4, xah.attribute5, xah.attribute6,
                    xah.attribute7, xah.attribute8, xah.attribute9,
                    xah.attribute10, xah.attribute11, xah.attribute12,
                    xah.attribute13, xah.attribute14, xah.attribute15
               FROM xla_ae_headers xah,
                    xla_events xe,
                    xla_transaction_entities xte
              WHERE xte.entity_id = xah.entity_id
                AND xte.application_id = xah.application_id
                AND xe.event_id = xah.event_id
                AND xe.application_id = xah.application_id
                AND xah.ae_header_id = p_ae_header_id
                AND xah.application_id = p_application_id
         FOR UPDATE NOWAIT;

      l_info         t_je_info;
      l_log_module   VARCHAR2 (240);
   BEGIN
      ------FND_LOG---------
      IF g_log_enabled
      THEN
         l_log_module := c_default_module || '.get_header_info';
      END IF;

      IF (c_level_procedure >= g_log_level)
      THEN
         TRACE (p_msg         => 'BEGIN of get_header_info',
                p_level       => c_level_procedure,
                p_module      => l_log_module
               );
      END IF;

-----------------------
      OPEN c_header;
      FETCH c_header INTO l_info.header_id,
       l_info.ledger_id,
       l_info.legal_entity_id,
       l_info.application_id,
       l_info.entity_id,
       l_info.event_id,
       l_info.gl_date,
       l_info.status_code,
       l_info.type_code,
       l_info.description,
       l_info.balance_type_code,
       l_info.budget_version_id,
       l_info.reference_date,
       l_info.funds_status_code,
       l_info.je_category_name,
       l_info.packet_id,
       l_info.amb_context_code,
       l_info.event_type_code,
       l_info.completed_date,
       l_info.gl_transfer_status_code,
       l_info.accounting_batch_id,
       l_info.period_name,
       l_info.product_rule_code,
       l_info.product_rule_type_code,
       l_info.product_rule_version,
       l_info.gl_transfer_date,
       l_info.doc_sequence_id,
       l_info.doc_sequence_value,
       l_info.close_acct_seq_version_id,
       l_info.close_acct_seq_value,
       l_info.close_acct_seq_assign_id,
       l_info.completion_acct_seq_version_id,
       l_info.completion_acct_seq_value,
       l_info.completion_acct_seq_assign_id,
       l_info.accrual_reversal_flag,
       l_info.budgetary_control_flag,
       l_info.attribute_category,
       l_info.attribute1,
       l_info.attribute2,
       l_info.attribute3,
       l_info.attribute4,
       l_info.attribute5,
       l_info.attribute6,
       l_info.attribute7,
       l_info.attribute8,
       l_info.attribute9,
       l_info.attribute10,
       l_info.attribute11,
       l_info.attribute12,
       l_info.attribute13,
       l_info.attribute14,
       l_info.attribute15;
      CLOSE c_header;

      IF (l_info.ledger_id IS NULL)
      THEN
         xla_exceptions_pkg.raise_message (p_appli_s_name      => 'XLA',
                                           p_msg_name          => 'XLA_MJE_INVALID_HEADER_ID',
                                           p_msg_mode          => p_msg_mode
                                          );
      END IF;

      IF (c_level_procedure >= g_log_level)
      THEN
         TRACE (p_msg         => 'END of get_header_info',
                p_level       => c_level_procedure,
                p_module      => l_log_module
               );
      END IF;
      RETURN l_info;
   EXCEPTION
      WHEN xla_exceptions_pkg.application_exception
      THEN
         IF (c_header%ISOPEN)
         THEN
            CLOSE c_header;
         END IF;

         RAISE;
      WHEN OTHERS
      THEN
         IF (c_header%ISOPEN)
         THEN
            CLOSE c_header;
         END IF;

         xla_exceptions_pkg.raise_message (p_location      => 'XLA_FSAH_INT_PVT.GET_HEADER_INFO'
                                          );
   END get_header_info;

------------------------------------------------------------------------------------
-- Procedure (create_reversal_distr_link)
------------------------------------------------------------------------------------
   PROCEDURE create_reversal_distr_link (
      p_application_id     IN   INTEGER,
      p_ae_header_id       IN   INTEGER,
      p_ref_ae_header_id   IN   INTEGER,
      p_ref_event_id       IN   INTEGER
   )
   IS
      l_ref_event_id   INTEGER;
      l_log_module     VARCHAR2 (240);
   BEGIN

      IF g_log_enabled
      THEN
         l_log_module := c_default_module || '.create_reversal_distr_link';
      END IF;

      IF (c_level_procedure >= g_log_level)
      THEN
         TRACE (p_msg         => 'BEGIN of create_reversal_distr_link',
                p_level       => c_level_procedure,
                p_module      => l_log_module
               );
      END IF;

      IF p_ref_event_id IS NOT NULL
      THEN
         --
         -- CALLED FROM CREATE_MRC_REVERSAL_ENTRY
         --
         l_ref_event_id := p_ref_event_id;
      ELSE
         --
         -- CALLED FROM CREATE_REVERSAL_ENTRY
         --
         SELECT event_id
           INTO l_ref_event_id
           FROM xla_ae_headers
          WHERE application_id = p_application_id
            AND ae_header_id = p_ref_ae_header_id;
      END IF;

      INSERT INTO xla_distribution_links
                  (application_id, event_id, ae_header_id, ae_line_num,
                   source_distribution_type, statistical_amount,
                   ref_ae_header_id, ref_temp_line_num, merge_duplicate_code,
                   temp_line_num, ref_event_id, event_class_code,
                   event_type_code, unrounded_entered_dr,
                   unrounded_entered_cr, unrounded_accounted_dr,
                   unrounded_accounted_cr)
         SELECT p_application_id, xah.event_id, p_ae_header_id, ae_line_num,
                'XLA_REVERSAL' -- SOURCE DISTRIBUTION TYPE
                               ,
                xal.statistical_amount -- STATISTICAL AMOUNT
                                       ,
                p_ref_ae_header_id -- REF AE HEADER ID
                                   ,
                ae_line_num -- REF TEMP LINE NUM
                            , 'N' -- MERGE DUPLICATE CODE
                                  ,
                -1 * ae_line_num -- TEMP LINE NUM
                                 ,
                l_ref_event_id -- REF EVENT ID
                               ,
                c_event_class_code_manual -- EVENT CLASS CODE
                                          ,
                c_event_type_code_manual -- EVENT TYPE CODE
                                         ,
                xal.unrounded_entered_dr, xal.unrounded_entered_cr,
                xal.unrounded_accounted_dr, xal.unrounded_accounted_cr
           FROM xla_ae_headers xah, xla_ae_lines xal
          WHERE xah.application_id = p_application_id
            AND xah.ae_header_id = p_ae_header_id
            AND xal.application_id = xah.application_id
            AND xal.ae_header_id = xah.ae_header_id;

      ---------FND_LOG---------
      IF (c_level_procedure >= g_log_level)
      THEN
         TRACE (p_msg         => 'END of create_reversal_distr_link',
                p_level       => c_level_procedure,
                p_module      => l_log_module
               );
      END IF;
-------------------------
   EXCEPTION
      WHEN xla_exceptions_pkg.application_exception
      THEN
         RAISE;
      WHEN OTHERS
      THEN
         xla_exceptions_pkg.raise_message (p_location      => 'XLA_FSAH_INT_PVT.CREATE_REVERSAL_DISTR_LINK'
                                          );
   END create_reversal_distr_link;

--=============================================================================
--
-- NAME         : GET_PERIOD_NAME
-- DESCRIPTION  : RETRIEVE THE PERIOD NAME OF AN ACCOUNTING DATE FOR A LEDGER,
--                AND ITS STATUS AND PERIOD TYPE.
--
--=============================================================================
   FUNCTION get_period_name (
      p_ledger_id         IN              INTEGER,
      p_accounting_date   IN              DATE,
      p_closing_status    OUT NOCOPY      VARCHAR2,
      p_period_type       OUT NOCOPY      VARCHAR2
   )
      RETURN VARCHAR2
   IS
      CURSOR c
      IS
         SELECT closing_status, period_name, period_type
           FROM gl_period_statuses
          WHERE application_id = c_gl_application_id
            AND ledger_id = p_ledger_id
            AND adjustment_period_flag = 'N'
            AND TRUNC (p_accounting_date) BETWEEN start_date AND end_date;

      l_period_name   VARCHAR2 (25);
      l_log_module    VARCHAR2 (240);
   BEGIN

      IF g_log_enabled
      THEN
         l_log_module := c_default_module || '.get_period_name';
      END IF;

      IF (c_level_procedure >= g_log_level)
      THEN
         TRACE (p_msg         => 'BEGIN of get_period_name',
                p_level       => c_level_procedure,
                p_module      => l_log_module
               );
      END IF;


      OPEN c;
      FETCH c INTO p_closing_status, l_period_name, p_period_type;
      CLOSE c;

      IF (c_level_procedure >= g_log_level)
      THEN
         TRACE (p_msg         => 'END of get_period_name',
                p_level       => c_level_procedure,
                p_module      => l_log_module
               );
      END IF;

      RETURN l_period_name;
   EXCEPTION
      WHEN xla_exceptions_pkg.application_exception
      THEN
         IF (c%ISOPEN)
         THEN
            CLOSE c;
         END IF;

         RAISE;
      WHEN OTHERS
      THEN
         IF (c%ISOPEN)
         THEN
            CLOSE c;
         END IF;

         xla_exceptions_pkg.raise_message (p_location      => 'XLA_FSAH_INT_PVT.GET_PERIOD_NAME'
                                          );
   END get_period_name;

--=============================================================================
-- PROCEDURE    :CREATE_REVERSAL_ENTRY
-- DESCRIPTION  :CREATE REVERSAL ENTRY FOR A JOURNAL ENTRY
--
--=============================================================================
   PROCEDURE create_reversal_entry (
      p_info              IN              t_je_info,
      p_reversal_method   IN              VARCHAR2,
      p_gl_date           IN              DATE,
      p_msg_mode          IN              VARCHAR2
            DEFAULT xla_exceptions_pkg.c_standard_message,
      p_rev_header_id     OUT NOCOPY      INTEGER,
      p_rev_event_id      OUT NOCOPY      INTEGER
   )
   IS
      TYPE t_ae_header_id IS TABLE OF xla_ae_headers.ae_header_id%TYPE;

      l_event_source_info   xla_events_pub_pkg.t_event_source_info;
      l_entity_id           INTEGER;
      l_period_name         VARCHAR2 (30);
      l_closing_status      VARCHAR2 (30);
      l_validate_period     INTEGER;
      l_result              INTEGER;
      l_period_type         VARCHAR2 (30);
      l_reversal_label      VARCHAR2 (240);
      l_last_updated_by     INTEGER;
      l_last_update_login   INTEGER;
      l_log_module          VARCHAR2 (240);
      l_info                t_je_info;
      l_ae_header_id        t_ae_header_id;
   BEGIN
      IF g_log_enabled
      THEN
         l_log_module := c_default_module || '.create_reversal_entry';
         --DBMS_OUTPUT.put_line ('Begin of create_reversal_entry');
      END IF;

      IF (c_level_procedure >= g_log_level)
      THEN
         TRACE (p_msg         => 'BEGIN of create_reversal_entry',
                p_level       => c_level_procedure,
                p_module      => l_log_module
               );
      END IF;


      --DBMS_OUTPUT.put_line ('Getting the Period name ');

      IF (c_level_procedure >= g_log_level)
      THEN
         TRACE (p_msg         => 'Getting the Period name',
                p_level       => c_level_procedure,
                p_module      => l_log_module
               );
      END IF;

      l_period_name :=
         get_period_name (p_ledger_id            => p_info.ledger_id,
                          p_accounting_date      => p_gl_date,
                          p_closing_status       => l_closing_status,
                          p_period_type          => l_period_type
                         );

      IF (l_period_name IS NULL)
      THEN
         --DBMS_OUTPUT.put_line ('Period name  is null ');

         IF (c_level_procedure >= g_log_level)
         THEN
            TRACE (p_msg         => 'Period name  is null',
                   p_level       => c_level_procedure,
                   p_module      => l_log_module
                  );
         END IF;

         xla_exceptions_pkg.raise_message (p_appli_s_name      => 'XLA',
                                           p_msg_name          => 'XLA_AP_INVALID_GL_DATE',
                                           p_msg_mode          => p_msg_mode
                                          );
      END IF;

      --
      -- CREATE EVENT FOR THE REVERSAL ENTRY
      --
      l_event_source_info.application_id := p_info.application_id;
      l_event_source_info.legal_entity_id := p_info.legal_entity_id;
      l_event_source_info.ledger_id := p_info.ledger_id;
      l_event_source_info.entity_type_code := c_entity_type_code_manual;

      IF (c_level_procedure >= g_log_level)
      THEN
         TRACE (p_msg         => 'Before Creating the Event for the reversal entry',
                p_level       => c_level_procedure,
                p_module      => l_log_module
               );
      END IF;

      p_rev_event_id :=
         xla_events_pkg.create_manual_event (p_event_source_info           => l_event_source_info,
                                             p_event_type_code             => c_event_type_code_manual,
                                             p_event_date                  => p_gl_date,
                                             p_event_status_code           => xla_events_pub_pkg.c_event_unprocessed,
                                             p_process_status_code         => xla_events_pkg.c_internal_unprocessed,
                                             p_event_number                => 1,
                                             p_budgetary_control_flag      => p_info.budgetary_control_flag
                                            );
      --DBMS_OUTPUT.put_line ('After Creating the Event for the reversal entry ');

      IF (c_level_procedure >= g_log_level)
      THEN
         TRACE (p_msg         => 'After Creating the Event for the reversal entry',
                p_level       => c_level_procedure,
                p_module      => l_log_module
               );
      END IF;

      BEGIN
         SELECT entity_id
           INTO l_entity_id
           FROM xla_events
          WHERE event_id = p_rev_event_id;
      EXCEPTION
         WHEN OTHERS
         THEN
            IF (c_level_procedure >= g_log_level)
            THEN
               TRACE (p_msg         => SQLERRM,
                      p_level       => c_level_procedure,
                      p_module      => l_log_module
                     );
            END IF;

            --DBMS_OUTPUT.put_line (SQLERRM);
      END;

     -- DBMS_OUTPUT.put_line ('Reversal Event Id ' || l_entity_id);
      fnd_message.set_name ('XLA', 'XLA_MJE_LABEL_REVERSAL');
      l_reversal_label := fnd_message.get ();
      l_last_updated_by := NVL (xla_environment_pkg.g_usr_id, -1);
      l_last_update_login := NVL (xla_environment_pkg.g_login_id, -1);

      --
      -- CREATE A NEW JOURNAL ENTRY HEADER
      --
      BEGIN
         SELECT ae_header_id
         BULK COLLECT INTO l_ae_header_id
           FROM xla_ae_headers
          WHERE event_id = p_info.event_id;
      EXCEPTION
         WHEN OTHERS
         THEN
            IF (c_level_procedure >= g_log_level)
            THEN
               TRACE (p_msg         => SQLERRM,
                      p_level       => c_level_procedure,
                      p_module      => l_log_module
                     );
            END IF;

            --DBMS_OUTPUT.put_line (SQLERRM);
      END;

      FOR i IN 1 .. l_ae_header_id.COUNT
      LOOP
         xla_security_pkg.set_security_context (602);
         l_info :=
            get_header_info (l_ae_header_id (i),
                             p_info.application_id,
                             g_msg_mode
                            );

         INSERT INTO xla_ae_headers
                     (ae_header_id, application_id,
                      ledger_id, entity_id, event_id,
                      event_type_code, accounting_date, period_name,
                      reference_date, balance_type_code,
                      budget_version_id, gl_transfer_status_code,
                      je_category_name, accounting_entry_status_code,
                      accounting_entry_type_code,
                      description,
                      creation_date, created_by, last_update_date,
                      last_updated_by, last_update_login,
                      accrual_reversal_flag
                     )
              VALUES (xla_ae_headers_s.NEXTVAL, l_info.application_id,
                      l_info.ledger_id, l_entity_id, p_rev_event_id,
                      c_event_type_code_manual,trunc(p_gl_date), l_period_name,
                      l_info.reference_date, l_info.balance_type_code,
                      l_info.budget_version_id, c_gl_transfer_mode_no,
                      l_info.je_category_name, c_status_final_code,
                      l_info.type_code,
                      'DATA FIX REVERSAL ENTRY: AE_HEADER_ID OF '||l_info.header_id,
                      SYSDATE, l_last_updated_by, SYSDATE,
                      l_last_updated_by, l_last_update_login,
                      NVL (l_info.accrual_reversal_flag, 'N')
                     ) -- 4262811 ACCRUAL_REVERSAL_FLAG
           RETURNING ae_header_id
                INTO p_rev_header_id;

         --
         -- COPY HEADER ANALYTICAL CRITERIA FROM THE ORIGINAL ENTRY TO THE REVERSAL ENTRY
         --
         INSERT INTO xla_ae_header_acs
                     (ae_header_id, analytical_criterion_code,
                      analytical_criterion_type_code, amb_context_code, ac1,
                      ac2, ac3, ac4, ac5, object_version_number)
            SELECT p_rev_header_id, analytical_criterion_code,
                   analytical_criterion_type_code, amb_context_code, ac1, ac2,
                   ac3, ac4, ac5, 1
              FROM xla_ae_header_acs
             WHERE ae_header_id = l_info.header_id;

         --
         -- CREATE JOURNAL ENTRY LINES FOR THE REVERSAL JOURNAL ENTRY
         --
         INSERT INTO xla_ae_lines
                     (application_id, ae_header_id, ae_line_num,
                      displayed_line_number, code_combination_id,
                      gl_transfer_mode_code, creation_date, created_by,
                      last_update_date, last_updated_by, last_update_login,
                      party_id, party_site_id, party_type_code, entered_dr,
                      entered_cr, accounted_dr, accounted_cr,
                      unrounded_entered_dr, unrounded_entered_cr,
                      unrounded_accounted_dr, unrounded_accounted_cr,
                      description, statistical_amount, currency_code,
                      currency_conversion_type, currency_conversion_date,
                      currency_conversion_rate, accounting_class_code,
                      jgzz_recon_ref, gl_sl_link_id,gl_sl_link_table, attribute_category,
                      encumbrance_type_id, attribute1, attribute2, attribute3,
                      attribute4, attribute5, attribute6, attribute7,
                      attribute8, attribute9, attribute10, attribute11,
                      attribute12, attribute13, attribute14, attribute15,
                      gain_or_loss_flag, ledger_id, accounting_date,
                      mpa_accrual_entry_flag)
            SELECT application_id, p_rev_header_id, ae_line_num,
                   displayed_line_number, code_combination_id,
                   gl_transfer_mode_code, SYSDATE, l_last_updated_by, SYSDATE,
                   l_last_updated_by, l_last_update_login, party_id,
                   party_site_id, party_type_code,
                   DECODE (p_reversal_method,
                           c_reversal_switch_dr_cr, entered_cr,
                           -entered_dr
                          ),
                   DECODE (p_reversal_method,
                           c_reversal_switch_dr_cr, entered_dr,
                           -entered_cr
                          ),
                   DECODE (p_reversal_method,
                           c_reversal_switch_dr_cr, accounted_cr,
                           -accounted_dr
                          ),
                   DECODE (p_reversal_method,
                           c_reversal_switch_dr_cr, accounted_dr,
                           -accounted_cr
                          ) -- 5109240 UNROUNDED AMOUNTS
                            ,
                   DECODE (p_reversal_method,
                           c_reversal_switch_dr_cr, unrounded_entered_cr,
                           -unrounded_entered_dr
                          ),
                   DECODE (p_reversal_method,
                           c_reversal_switch_dr_cr, unrounded_entered_dr,
                           -unrounded_entered_cr
                          ),
                   DECODE (p_reversal_method,
                           c_reversal_switch_dr_cr, unrounded_accounted_cr,
                           -unrounded_accounted_dr
                          ),
                   DECODE (p_reversal_method,
                           c_reversal_switch_dr_cr, unrounded_accounted_dr,
                           -unrounded_accounted_cr
                          ),
                   'DATA FIX REVERSAL ENTRY: AE_HEADER_ID OF '||l_info.header_id, statistical_amount, currency_code,
                   currency_conversion_type, currency_conversion_date,
                   currency_conversion_rate, accounting_class_code,
                   jgzz_recon_ref,xla_gl_sl_link_id_s.NEXTVAL, 'XLAJEL', attribute_category,
                   encumbrance_type_id, attribute1, attribute2, attribute3,
                   attribute4, attribute5, attribute6, attribute7, attribute8,
                   attribute9, attribute10, attribute11, attribute12,
                   attribute13, attribute14, attribute15, gain_or_loss_flag,
                   l_info.ledger_id,trunc(p_gl_date),
                   NVL (mpa_accrual_entry_flag, 'N')
              -- 4262811 MPA_ACCRUAL_ENTRY_FLAG
            FROM   xla_ae_lines
             WHERE application_id = l_info.application_id
               AND ae_header_id = l_info.header_id;

         create_reversal_distr_link (p_application_id        => l_info.application_id,
                                     p_ae_header_id          => p_rev_header_id,
                                     p_ref_ae_header_id      => l_info.header_id -- ORIGINAL AE HEADER
                                                                                 ,
                                     p_ref_event_id          => NULL
                                    );

         --
         -- COPY THE JOURNAL ENTRY LINES' ANALYTICAL CRITERIA FROM THE ORIGINAL ENTRY TO
         -- THE REVERSAL ENTRY
         --
         INSERT INTO xla_ae_line_acs
                     (ae_header_id, ae_line_num, analytical_criterion_code,
                      analytical_criterion_type_code, amb_context_code, ac1,
                      ac2, ac3, ac4, ac5, object_version_number)
            SELECT p_rev_header_id, ae_line_num, analytical_criterion_code,
                   analytical_criterion_type_code, amb_context_code, ac1, ac2,
                   ac3, ac4, ac5, 1
              FROM xla_ae_line_acs
             WHERE ae_header_id = l_info.header_id;
      END LOOP;

      ---------FND_LOG---------
      IF (c_level_procedure >= g_log_level)
      THEN
         TRACE (p_msg         => 'END of create_reversal_entry',
                p_level       => c_level_procedure,
                p_module      => l_log_module
               );
      END IF;
-------------------------
   EXCEPTION
      WHEN xla_exceptions_pkg.application_exception
      THEN
         ROLLBACK;
         RAISE;
      WHEN OTHERS
      THEN
         ROLLBACK;
         xla_exceptions_pkg.raise_message (p_location      => 'XLA_FSAH_INT_PVT.CREATE_REVERSAL_ENTRY'
                                          );
   END create_reversal_entry;

/*=== LOGIC ====================================================================
1) FIND THE AE_HEADER_ID OF THE PRIMARY LEDGER (AND ORIGINAL PARENT ENTRY OF
   MPA/ACCRUAL REVERSAL ENTRY, IF EXISTS) FOR THE ORIGINAL P_EVENT_ID
2) CALLS REVERSE_JOURNAL_ENTRY WITH THE AE_HEADER_ID
   A) DELETE THE INCOMPLETE MPA
   B) CREATE A NEW EVENT AND ENTITY, AND MAP THE ORIGINAL ENTRY TO THE NEW
      EVENT ID AND ENTITY ID.
   C) CALLS CREATE_REVERSAL_ENTRY OF THE AE_HEADER_ID TO CREATE THE REVERSAL OF
      THE ORIGINAL ENTRY, RETURNING THE NEW REV_AE_HEADER_ID AND REV_EVENT_ID
      I) CALLS COMPLETE_JOURNAL_ENTRY WITH REV_AE_HEADER_ID, P_EVENT_ID AND
         P_REV_FLAG = 'Y' TO VALIDATE THE REVERSAL ENTRY REV_AE_HEADER_ID AND ON
         SUCCESS,
         -> CALLS CREATE_MRC_REVERSAL_ENTRY TO CREATE REVERSAL OF ALL OTHER
            LEDGERS AND ENTRIES RELATED TO THE ORIGINAL ENTRY P_EVENT_ID.

==============================================================================*/
   PROCEDURE reverse_journal_entries (
      p_api_version        IN              NUMBER,
      p_init_msg_list      IN              VARCHAR2,
      p_application_id     IN              INTEGER,
      p_event_id           IN              INTEGER,
      p_reversal_method    IN              VARCHAR2,
      p_gl_date            IN              DATE,
      p_post_to_gl_flag    IN              VARCHAR2,
      x_return_status      OUT NOCOPY      VARCHAR2,
      x_msg_count          OUT NOCOPY      NUMBER,
      x_msg_data           OUT NOCOPY      VARCHAR2,
      x_rev_ae_header_id   OUT NOCOPY      INTEGER,
      x_rev_event_id       OUT NOCOPY      INTEGER,
      x_rev_entity_id      OUT NOCOPY      INTEGER,
      x_new_event_id       OUT NOCOPY      INTEGER,
      x_new_entity_id      OUT NOCOPY      INTEGER
   )
   IS
      l_api_name      CONSTANT VARCHAR2 (30)     := 'REVERSE_JOURNAL_ENTRIES';
      l_api_version   CONSTANT NUMBER                                 := 1.0;
      l_info                   t_je_info;

--        l_ae_header_id_count     number;

      ---------------------------------------------------------------
-- IN ORDER TO REVERSE, THEY MUST BE FINAL AND TRANSFERRED.
---------------------------------------------------------------
      CURSOR c_orig_je
      IS
         SELECT xgl.currency_code, xsu.je_source_name, xah.entity_id,
                xah.ae_header_id, xah.accounting_date, xah.ledger_id,
                e.legal_entity_id, xah.accrual_reversal_flag,
                xe.budgetary_control_flag
           FROM xla_gl_ledgers_v xgl,
                xla_ae_headers xah,
                xla_subledgers xsu,
                xla_transaction_entities e,
                xla_events xe
          WHERE xgl.ledger_id = xah.ledger_id
            AND xsu.application_id = xah.application_id
            AND xah.event_id = p_event_id
            AND xah.application_id = p_application_id
            AND ledger_category_code = 'PRIMARY'
            AND e.application_id = xah.application_id
            AND e.entity_id = xah.entity_id
            AND xe.application_id = xah.application_id
            AND xe.event_id = xah.event_id
            AND xah.accounting_entry_status_code = c_status_final_code
            AND xah.parent_ae_header_id IS NULL
            AND NOT EXISTS (
                   SELECT 1
                     FROM xla_ae_headers xah2
                    WHERE xah2.application_id = p_application_id
                      AND xah2.event_id = p_event_id
                      AND xah2.accounting_entry_status_code =
                                                           c_status_final_code
                      AND NVL (xah2.gl_transfer_status_code, 'N') IN
                                                                  ('N', 'NT'));

      -- CAN BE REVERSED ONLY IF IT IS TRANSFERRED
      l_functional_curr        xla_gl_ledgers_v.currency_code%TYPE;
      l_je_source_name         xla_subledgers.je_source_name%TYPE;
      l_entity_id              INTEGER;
      l_pri_ae_header_id       INTEGER;
      l_pri_gl_date            DATE;
      l_ledger_id              INTEGER;
      l_legal_entity_id        INTEGER;
      l_mpa_acc_rev_flag       VARCHAR2 (1);
      l_bc_flag                VARCHAR2 (1);
      l_transfer_request_id    INTEGER;

      TYPE t_ae_header_id IS TABLE OF xla_ae_headers.ae_header_id%TYPE;

      l_ae_header_id           INTEGER;
      l_event_source_info      xla_events_pub_pkg.t_event_source_info;
      l_array_ae_header_id     t_array_integer;
      l_retcode                INTEGER;
      l_log_module             VARCHAR2 (240);
      l_completion_option      VARCHAR2 (1);
      l_completion_retcode     VARCHAR2 (30);
   BEGIN
      -----FND_LOG-----------
      IF g_log_enabled
      THEN
         l_log_module := c_default_module || '.reverse_journal_entries';
         --DBMS_OUTPUT.put_line ('BEGIN of reverse_journal_entries');
      END IF;

      IF (c_level_procedure >= g_log_level)
      THEN
         TRACE (p_msg         => 'BEGIN of reverse_journal_entries',
                p_level       => c_level_procedure,
                p_module      => l_log_module
               );
         TRACE (p_msg         => 'p_application_id'||to_char(p_application_id),
                p_level       => c_level_procedure,
                p_module      => l_log_module
               );

         TRACE (p_msg         => 'p_event_id '||to_char(p_event_id),
                p_level       => c_level_procedure,
                p_module      => l_log_module
               );

         TRACE (p_msg         => 'p_reversal_method '||p_reversal_method,
                p_level       => c_level_procedure,
                p_module      => l_log_module
               );

         TRACE (p_msg         => 'p_gl_date '||to_char(p_gl_date),
                p_level       => c_level_procedure,
                p_module      => l_log_module
               );

      END IF;

----------------------
      IF (fnd_api.to_boolean (p_init_msg_list))
      THEN
         fnd_msg_pub.initialize;
      END IF;

      --DBMS_OUTPUT.put_line ('fnd_api.to_boolean got initialized');

      IF (c_level_procedure >= g_log_level)
      THEN
         TRACE (p_msg         => 'fnd_api.to_boolean got initialized',
                p_level       => c_level_procedure,
                p_module      => l_log_module
               );
      END IF;

      -- STANDARD CALL TO CHECK FOR CALL COMPATIBILITY.
      IF (NOT fnd_api.compatible_api_call (p_current_version_number      => l_api_version,
                                           p_caller_version_number       => p_api_version,
                                           p_api_name                    => l_api_name,
                                           p_pkg_name                    => c_default_module
                                          )
         )
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      --  INITIALIZE GLOBAL VARIABLES
      x_return_status := fnd_api.g_ret_sts_success;
      --DBMS_OUTPUT.put_line (x_return_status);

      IF (c_level_procedure >= g_log_level)
      THEN
         TRACE (p_msg         => x_return_status,
                p_level       => c_level_procedure,
                p_module      => l_log_module
               );
      END IF;

-- VALIDATION -------------------------------------------------------
      OPEN c_orig_je;
      FETCH c_orig_je INTO l_functional_curr,
       l_je_source_name,
       l_entity_id,
       l_pri_ae_header_id,
       l_pri_gl_date,
       l_ledger_id,
       l_legal_entity_id,
       l_mpa_acc_rev_flag,
       l_bc_flag;
      --DBMS_OUTPUT.put_line ('cursor c_orig_je is opend');

      IF (c_level_procedure >= g_log_level)
      THEN
         TRACE (p_msg         => 'cursor c_orig_je is opend',
                p_level       => c_level_procedure,
                p_module      => l_log_module
               );
      END IF;

      IF c_orig_je%NOTFOUND
      THEN
         CLOSE c_orig_je;
      END IF;

      CLOSE c_orig_je;
      --DBMS_OUTPUT.put_line ('cursor c_orig_je closed');

      IF (c_level_procedure >= g_log_level)
      THEN
         TRACE (p_msg         => 'cursor c_orig_je is closed',
                p_level       => c_level_procedure,
                p_module      => l_log_module
               );
      END IF;

-----------------------------------------------------------------
-- CREATE NEW EVENT AND ENTITY, SAME DETAILS AS ORIGINAL ENTRY
-----------------------------------------------------------------
      l_event_source_info.application_id := p_application_id;
      l_event_source_info.legal_entity_id := l_legal_entity_id;
      l_event_source_info.ledger_id := l_ledger_id;
      l_event_source_info.entity_type_code := 'MANUAL';
---------------------------------------------------------------------------------------------
-- CURRENTLY, XLA_EVENTS_PKG.VALIDATE_EVENT_TYPE_CODE FAILES IF NOT MANUAL EVENT TYPE
---------------------------------------------------------------------------------------------

      --DBMS_OUTPUT.put_line ('Creating the Reversal Event');

      IF (c_level_procedure >= g_log_level)
      THEN
         TRACE (p_msg         => 'Creating the Reversal Event',
                p_level       => c_level_procedure,
                p_module      => l_log_module
               );
      END IF;

      x_new_event_id :=
         xla_events_pkg.create_manual_event (p_event_source_info           => l_event_source_info,
                                             p_event_type_code             => 'MANUAL',
                                             p_event_date                  => l_pri_gl_date,
                                             p_event_status_code           => xla_events_pub_pkg.c_event_unprocessed,
                                             p_process_status_code         => xla_events_pkg.c_internal_unprocessed,
                                             p_event_number                => 1,
                                             p_budgetary_control_flag      => l_bc_flag
                                            );
      /*DBMS_OUTPUT.put_line (   'RETURNED FROM XLA_EVENTS_PKG.CREATE_MANUAL_EVENT = EVENT ID '
                            || x_new_event_id
                           );*/

      IF (c_level_procedure >= g_log_level)
      THEN
         TRACE (p_msg         =>    'RETURNED FROM XLA_EVENTS_PKG.CREATE_MANUAL_EVENT = EVENT ID '
                                 || x_new_event_id,
                p_level       => c_level_procedure,
                p_module      => l_log_module
               );
      END IF;

-----------------------------------------------------
-- UPDATE NEW EVENT_ID AND ENTITY_ID
-----------------------------------------------------
      --DBMS_OUTPUT.put_line ('Before Updating the xla_events');

      IF (c_level_procedure >= g_log_level)
      THEN
         TRACE (p_msg         => 'Before Updating the xla_events',
                p_level       => c_level_procedure,
                p_module      => l_log_module
               );
      END IF;

      xla_security_pkg.set_security_context (602);

      UPDATE    xla_events
            SET event_status_code = xla_events_pub_pkg.c_event_processed,
                process_status_code = xla_events_pub_pkg.c_event_processed,
                (event_type_code, event_date, reference_num_1,
                 reference_num_2, reference_num_3, reference_num_4,
                 reference_char_1, reference_char_2, reference_char_3,
                 reference_char_4, reference_date_1, reference_date_2,
                 reference_date_3, reference_date_4, on_hold_flag,
                 upg_batch_id, upg_source_application_id, upg_valid_flag,
                 transaction_date, budgetary_control_flag,
                 merge_event_set_id -- EVENT_NUMBER
                                    , creation_date, created_by,
                 last_update_date, last_updated_by, last_update_login,
                 program_update_date, program_application_id, program_id,
                 request_id) =
                   (SELECT 'REVERSAL' -- EVENT_TYPE_CODE
                                      , event_date, reference_num_1,
                           reference_num_2, reference_num_3, reference_num_4,
                           reference_char_1, reference_char_2,
                           reference_char_3, reference_char_4,
                           reference_date_1, reference_date_2,
                           reference_date_3, reference_date_4, on_hold_flag,
                           upg_batch_id, upg_source_application_id,
                           upg_valid_flag, transaction_date,
                           budgetary_control_flag,
                           merge_event_set_id -- EVENT_NUMBER
                                              , SYSDATE, fnd_global.user_id,
                           SYSDATE, fnd_global.user_id, fnd_global.user_id,
                           SYSDATE, -1, -1, -1
                      FROM xla_events
                     WHERE application_id = p_application_id
                       AND event_id = p_event_id)
          WHERE application_id = p_application_id
                AND event_id = x_new_event_id
      RETURNING entity_id
           INTO x_new_entity_id;

      --DBMS_OUTPUT.put_line ('After Updating the xla_events');

      IF (c_level_procedure >= g_log_level)
      THEN
         TRACE (p_msg         => 'After Updating the xla_events',
                p_level       => c_level_procedure,
                p_module      => l_log_module
               );
      END IF;

      --DBMS_OUTPUT.put_line ('Before Updating the xla_transaction_entities');

      IF (c_level_procedure >= g_log_level)
      THEN
         TRACE (p_msg         => 'Before Updating the xla_transaction_entities',
                p_level       => c_level_procedure,
                p_module      => l_log_module
               );
      END IF;

      xla_security_pkg.set_security_context (602);

      UPDATE xla_transaction_entities
         SET (entity_code, source_id_int_1, source_id_char_1,
              security_id_int_1, security_id_int_2, security_id_int_3,
              security_id_char_1, security_id_char_2, security_id_char_3,
              source_id_int_2, source_id_char_2, source_id_int_3,
              source_id_char_3, source_id_int_4, source_id_char_4,
              valuation_method, source_application_id, upg_batch_id,
              upg_source_application_id, upg_valid_flag -- TRANSACTION_NUMBER
                                                        -- LEGAL_ENTITY_ID
                                                        -- LEDGER_ID
                                                        ,
              creation_date, created_by, last_update_date, last_updated_by,
              last_update_login) =
                (SELECT 'REVERSAL', -- ENTITY_CODE  THIS ALSO PREVENTS TRANSACTION TO BE USED IN BFLOW.
                                    source_id_int_1,
                        source_id_char_1, security_id_int_1,
                        security_id_int_2, security_id_int_3,
                        security_id_char_1, security_id_char_2,
                        security_id_char_3, source_id_int_2, source_id_char_2,
                        source_id_int_3, source_id_char_3, source_id_int_4,
                        source_id_char_4, valuation_method,
                        source_application_id, upg_batch_id,
                        upg_source_application_id,
                        upg_valid_flag -- TRANSACTION_NUMBER
                                       -- LEGAL_ENTITY_ID
                                       -- LEDGER_ID
                                       , SYSDATE, fnd_global.user_id, SYSDATE,
                        fnd_global.user_id, fnd_global.user_id
                   FROM xla_transaction_entities
                  WHERE application_id = p_application_id
                    AND entity_id = l_entity_id)
       WHERE application_id = p_application_id AND entity_id = x_new_entity_id;

      IF (c_level_procedure >= g_log_level)
      THEN
         TRACE (p_msg         => 'After Updating the the xla_transaction_entities',
                p_level       => c_level_procedure,
                p_module      => l_log_module
               );
      END IF;

      --DBMS_OUTPUT.put_line ('After Updating the xla_transaction_entities');
------------------------------------------------------------------------------
-- HEADERS TABLE UPDATE
------------------------------------------------------------------------------
      --DBMS_OUTPUT.put_line ('Before  Updating the xla_ae_headers');

      IF (c_level_procedure >= g_log_level)
      THEN
         TRACE (p_msg         => 'Before  Updating the xla_ae_headers',
                p_level       => c_level_procedure,
                p_module      => l_log_module
               );
      END IF;

      UPDATE    xla_ae_headers
            SET entity_id = x_new_entity_id,
                event_id = x_new_event_id,
                event_type_code = 'REVERSAL',
                description = 'DATA FIX ENTRY: EVENT_ID OF ' || p_event_id
          WHERE application_id = p_application_id AND event_id = p_event_id
      RETURNING         ae_header_id
      BULK COLLECT INTO l_array_ae_header_id;

      IF (c_level_procedure >= g_log_level)
      THEN
         TRACE (p_msg         => 'After  Updating the xla_ae_headers',
                p_level       => c_level_procedure,
                p_module      => l_log_module
               );
      END IF;

      --DBMS_OUTPUT.put_line ('After Updating the xla_ae_headers1');
------------------------------------------------------------------------------
-- LINES TABLE UPDATE
------------------------------------------------------------------------------
      --DBMS_OUTPUT.put_line ('Before  Updating the xla_ae_lines');

      IF (c_level_procedure >= g_log_level)
      THEN
         TRACE (p_msg         => 'Before  Updating Updating the xla_ae_lines',
                p_level       => c_level_procedure,
                p_module      => l_log_module
               );
      END IF;

      FORALL i IN 1 .. l_array_ae_header_id.COUNT
         UPDATE xla_ae_lines
            SET description = 'DATA FIX ENTRY: EVENT_ID OF ' || p_event_id
          WHERE application_id = p_application_id
            AND ae_header_id = l_array_ae_header_id (i);
------------------------------------------------------------------------------
-- DISTRIBUTION LINKS TABLE UPDATE
------------------------------------------------------------------------------
      --DBMS_OUTPUT.put_line ('after  Updating the xla_ae_lines');

      IF (c_level_procedure >= g_log_level)
      THEN
         TRACE (p_msg         => 'After  Updating Updating the xla_ae_lines',
                p_level       => c_level_procedure,
                p_module      => l_log_module
               );
      END IF;

      FORALL i IN 1 .. l_array_ae_header_id.COUNT
         UPDATE xla_distribution_links
            SET event_id = x_new_event_id
          WHERE application_id = p_application_id
            AND ae_header_id = l_array_ae_header_id (i);
---------------------------------------------------------
-- SET ORIGINAL EVENT TO UNPROCESSED
---------------------------------------------------------
      --DBMS_OUTPUT.put_line ('Before  Updating the xla_events');

      IF (c_level_procedure >= g_log_level)
      THEN
         TRACE (p_msg         => 'Before  Updating Updating the xla_events',
                p_level       => c_level_procedure,
                p_module      => l_log_module
               );
      END IF;

      UPDATE xla_events
         SET event_status_code = xla_events_pub_pkg.C_EVENT_INCOMPLETE,
             process_status_code = xla_events_pkg.c_internal_unprocessed
       WHERE application_id = p_application_id AND event_id = p_event_id;

      IF (c_level_procedure >= g_log_level)
      THEN
         TRACE (p_msg         => 'After  Updating Updating the xla_events',
                p_level       => c_level_procedure,
                p_module      => l_log_module
               );
      END IF;

      --DBMS_OUTPUT.put_line ('after  Updating the xla_events');
-----------------------------------------------------------------------------------
     -- CURRENTLY, XLA_JOURNAL_ENTRIES_PKG.REVERSE_JOURNAL_ENTRY ONLY PROCESS REVERSAL ENTRY
-----------------------------------------------------------------------------------

      --DBMS_OUTPUT.put_line ('Before  Updating the xla_ae_headers2');

      IF (c_level_procedure >= g_log_level)
      THEN
         TRACE (p_msg         => 'Before  Updating the xla_ae_headers2',
                p_level       => c_level_procedure,
                p_module      => l_log_module
               );
      END IF;

      UPDATE xla_ae_headers
         SET accounting_entry_type_code = 'REVERSAL'
       WHERE application_id = p_application_id AND event_id = x_new_event_id;

      IF (c_level_procedure >= g_log_level)
      THEN
         TRACE (p_msg         => 'After  Updating the xla_ae_headers2',
                p_level       => c_level_procedure,
                p_module      => l_log_module
               );
      END IF;

      --DBMS_OUTPUT.put_line ('After  Updating the xla_ae_headers2');
--------------------------------------------------------
-- REVERSE JOURNAL ENTRIES
--------------------------------------------------------
      --DBMS_OUTPUT.put_line ('x_new_event_id ' || x_new_event_id);

      IF (c_level_procedure >= g_log_level)
      THEN
         TRACE (p_msg         => 'x_new_event_id ' || x_new_event_id,
                p_level       => c_level_procedure,
                p_module      => l_log_module
               );
      END IF;

/*select count(*) into
l_ae_header_id_count
from xla_ae_headers where event_id = x_new_event_id ;

        --DBMS_OUTPUT.put_line ('l_ae_header_id_count ' || l_ae_header_id_count);*/
      BEGIN
         SELECT ae_header_id
           INTO l_ae_header_id
           FROM xla_ae_headers
          WHERE event_id = x_new_event_id AND ROWNUM = 1;
      EXCEPTION
         WHEN OTHERS
         THEN
            IF (c_level_procedure >= g_log_level)
            THEN
               TRACE (p_msg         => SQLERRM,
                      p_level       => c_level_procedure,
                      p_module      => l_log_module
                     );
            END IF;

            --DBMS_OUTPUT.put_line (SQLERRM);
      END;

      l_info := get_header_info (l_ae_header_id, p_application_id, g_msg_mode);
      --DBMS_OUTPUT.put_line ('Call to  create_reversal_entry ');

      IF (c_level_procedure >= g_log_level)
      THEN
         TRACE (p_msg         => 'Call to  create_reversal_entry ',
                p_level       => c_level_procedure,
                p_module      => l_log_module
               );
      END IF;

      create_reversal_entry (p_info                 => l_info,
                             p_reversal_method      => p_reversal_method,
                             p_gl_date              => p_gl_date,
                             p_rev_header_id        => x_rev_ae_header_id,
                             p_rev_event_id         => x_rev_event_id
                            );
   --   DBMS_OUTPUT.put_line ('After Call to  create_reversal_entry ');

      IF (c_level_procedure >= g_log_level)
      THEN
         TRACE (p_msg         => 'After Call to  create_reversal_entry ',
                p_level       => c_level_procedure,
                p_module      => l_log_module
               );
      END IF;

      IF l_completion_retcode <> 'S' OR x_rev_ae_header_id IS NULL
      THEN
         IF (c_level_statement >= g_log_level)
         THEN
            TRACE (p_msg         => 'FAILURE IN XLA_JOURNAL_ENTRIES_PKG.REVERSE_JOURNAL_ENTRY. PLEASE VERIFY LOG FILE.',
                   p_module      => l_log_module,
                   p_level       => c_level_statement
                  );
         END IF;
      END IF;

-------------------------------------------------------------------------------
-- UPDATE DESCRIPTION FOR REVERSE ENTRIES
-------------------------------------------------------------------------------
      IF (c_level_statement >= g_log_level)
      THEN
         TRACE (p_msg         => 'UPDATE DESCRIPTIONS',
                p_module      => l_log_module,
                p_level       => c_level_statement
               );
      END IF;


      IF (c_level_statement >= g_log_level)
      THEN
         TRACE (p_msg         => 'Updating the xla_ae_headers3 with the Description',
                p_module      => l_log_module,
                p_level       => c_level_statement
               );
      END IF;

      UPDATE xla_events
         SET event_type_code = 'REVERSAL',
             event_status_code = 'P',
             process_status_code = 'P'
       WHERE event_id = x_rev_event_id;

      UPDATE    xla_ae_headers
            SET /*description =
                      'DATA FIX REVERSAL ENTRY: EVENT_ID OF '
                      || p_event_id,*/
                event_type_code = 'REVERSAL'
          WHERE application_id = p_application_id
                AND event_id = x_rev_event_id
      RETURNING         ae_header_id
      BULK COLLECT INTO l_array_ae_header_id;

      IF (c_level_statement >= g_log_level)
      THEN
         TRACE (p_msg         => 'After Updating the xla_ae_headers3 with the Description',
                p_module      => l_log_module,
                p_level       => c_level_statement
               );
      END IF;

      IF (c_level_statement >= g_log_level)
      THEN
         TRACE (p_msg         => 'Updating the xla_ae_lines with the Description ',
                p_module      => l_log_module,
                p_level       => c_level_statement
               );
      END IF;

    FORALL i IN 1 .. l_array_ae_header_id.COUNT
         UPDATE xla_ae_lines
            SET description =description||' Original Event_id '|| p_event_id
          WHERE application_id = p_application_id
            AND ae_header_id = l_array_ae_header_id (i);

      IF (c_level_statement >= g_log_level)
      THEN
         TRACE (p_msg         => 'After Updating the xla_ae_lines with the Description ',
                p_module      => l_log_module,
                p_level       => c_level_statement
               );
      END IF;

      ---------FND_LOG---------
      IF (c_level_procedure >= g_log_level)
      THEN
         TRACE (p_msg         => 'END of reverse_journal_entries',
                p_level       => c_level_procedure,
                p_module      => l_log_module
               );
      END IF;
-------------------------
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         ROLLBACK;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );
      WHEN xla_exceptions_pkg.application_exception
      THEN
         RAISE;
      WHEN OTHERS
      THEN
         --DBMS_OUTPUT.put_line (SQLERRM);

         IF (c_level_statement >= g_log_level)
         THEN
            TRACE (p_msg         => SQLERRM,
                   p_module      => l_log_module,
                   p_level       => c_level_statement
                  );
         END IF;

         ROLLBACK;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (c_default_module, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );
         xla_exceptions_pkg.raise_message (p_location      => 'XLA_FSAH_INT_PVT.reverse_journal_entries'
                                          );
   END reverse_journal_entries;

-------------------------------------------------------------------------------
-- UPDATE DESCRIPTION FOR REV_JOUR_ENTRY
-------------------------------------------------------------------------------
   PROCEDURE rev_jour_entry (
      p_ae_header_id    IN              NUMBER,
      p_return_status   OUT NOCOPY      VARCHAR2,
      p_error_msg       OUT NOCOPY      VARCHAR2
   )
   AS
      -- variables declarations
      l_event_id            NUMBER;
      l_api_version         NUMBER;
      l_init_msg_list       VARCHAR2 (300);
      l_application_id      INTEGER;
      l_reversal_method     VARCHAR2 (300);
      l_post_to_gl_flag     VARCHAR2 (10);
      l_gl_date             DATE;
      x_return_status       VARCHAR2 (300);
      x_msg_count           NUMBER;
      x_msg_data            VARCHAR2 (4000);
      x_rev_ae_header_id    INTEGER;
      x_rev_event_id        INTEGER;
      x_rev_entity_id       INTEGER;
      x_new_event_id        INTEGER;
      x_new_entity_id       INTEGER;
      l_log_module          VARCHAR2 (240);
      l_security_id_int_1   NUMBER;
   BEGIN
      -----FND_LOG-----------
      IF g_log_enabled
      THEN
         l_log_module := c_default_module || '.rev_jour_entry';
      END IF;

      IF (c_level_procedure >= g_log_level)
      THEN
         TRACE (p_msg         => 'BEGIN of rev_jour_entry',
                p_level       => c_level_procedure,
                p_module      => l_log_module
               );
      END IF;

----------------------
      l_api_version := 1.0;
      l_init_msg_list := fnd_api.g_true;
      l_application_id := 200;
      l_reversal_method := 'SIDE';
     -- l_gl_date := SYSDATE;
      l_post_to_gl_flag := 'Y';

      -- collecting the data for reversal
      BEGIN
         SELECT event_id, application_id,accounting_date
           INTO l_event_id, l_application_id,l_gl_date
           FROM xla_ae_headers
          WHERE ae_header_id = p_ae_header_id;
      EXCEPTION
         WHEN OTHERS
         THEN
            fnd_file.put_line (fnd_file.LOG,
                                SQLERRM || ' Selection of Application Id '
                              );
      END;

      /* BEGIN
           SELECT xte.security_id_int_1
            INTO l_security_id_int_1
            FROM xla_ae_headers xah,
                 xla_events xe,
                 xla_transaction_entities xte
           WHERE xah.ae_header_id = p_ae_header_id
             AND xah.event_id = xe.event_id
             AND xah.application_id = xe.application_id
             AND xe.application_id = xte.application_id
             AND xe.entity_id = xte.entity_id;
       EXCEPTION
           WHEN OTHERS
           THEN
               fnd_file.put_line (fnd_file.LOG,
                                      SQLERRM
                                   || ' Problem in setting the security Context '
                                 );
       END;*/

      -- mo_global.set_policy_context ('S', l_security_id_int_1);
      xla_security_pkg.set_security_context (602);

      IF (c_level_procedure >= g_log_level)
      THEN
         TRACE (p_msg         => 'Security_context set ',
                p_level       => c_level_procedure,
                p_module      => l_log_module
               );
      END IF;

      -- calling the reversal
      reverse_journal_entries (l_api_version,
                               l_init_msg_list,
                               l_application_id,
                               l_event_id,
                               l_reversal_method,
                               l_gl_date,
                               l_post_to_gl_flag,
                               x_return_status,
                               x_msg_count,
                               x_msg_data,
                               x_rev_ae_header_id,
                               x_rev_event_id,
                               x_rev_entity_id,
                               x_new_event_id,
                               x_new_entity_id
                              );
      p_return_status := x_return_status;          /*|| ' x_rev_ae_header_id '
                    || x_rev_ae_header_id
                    || 'x_rev_event_id '
                    || x_rev_event_id
                    || 'x_new_event_id '
                    || x_new_event_id;
               p_error_msg :=  ;*/

      ---------FND_LOG---------
      IF (c_level_procedure >= g_log_level)
      THEN
         TRACE (p_msg         => 'END of rev_jour_entry',
                p_level       => c_level_procedure,
                p_module      => l_log_module
               );
      END IF;
-------------------------
   EXCEPTION
      /* WHEN xla_exceptions_pkg.application_exception
       THEN
           RAISE;*/
      WHEN OTHERS
      THEN
         --DBMS_OUTPUT.put_line (SQLERRM);

         IF (c_level_statement >= g_log_level)
         THEN
            TRACE (p_msg         => SQLERRM,
                   p_module      => l_log_module,
                   p_level       => c_level_statement
                  );
         END IF;
   /* xla_exceptions_pkg.raise_message (p_location       => 'XLA_FSAH_INT_PVT.rev_jour_entry'
                                     );*/
   END rev_jour_entry;

   PROCEDURE rev_jour_entry_list (
      p_list_ae_header_id   IN              fnd_table_of_number,
      p_return_status       OUT NOCOPY      VARCHAR2,
      p_error_msg           OUT NOCOPY      VARCHAR2
   )
   AS
      --l_table_of_headers   fnd_table_of_number;
      l_first_ledger_id   NUMBER;
      l_ledger_id         NUMBER;
      l_ledger_category   VARCHAR2 (100);
      l_log_module        VARCHAR2 (240);
      l_return_status     VARCHAR2 (2);
      l_error_msg         VARCHAR2 (240);
      l_cont_flag         VARCHAR2 (1)   := 'Y';
   BEGIN
      IF g_log_enabled
      THEN
         l_log_module := c_default_module || '.rev_jour_entry_list';
      END IF;

      IF (c_level_procedure >= g_log_level)
      THEN
         TRACE (p_msg         => 'BEGIN of rev_jour_entry_list',
                p_level       => c_level_procedure,
                p_module      => l_log_module
               );
      END IF;

      -- validating the all the accounting headers having the same ledger or not
      FOR i IN p_list_ae_header_id.FIRST .. p_list_ae_header_id.LAST
      LOOP
         SELECT ledger_id
           INTO l_first_ledger_id
           FROM xla_ae_headers
          WHERE ae_header_id = p_list_ae_header_id (i);
      END LOOP;

      FOR j IN p_list_ae_header_id.FIRST .. p_list_ae_header_id.LAST
      LOOP
         SELECT ledger_id
           INTO l_ledger_id
           FROM xla_ae_headers
          WHERE ae_header_id = p_list_ae_header_id (j);

         IF l_ledger_id <> l_first_ledger_id
         THEN
            l_cont_flag := 'N';

            IF (c_level_procedure >= g_log_level)
            THEN
               TRACE (p_msg         => 'Given Accounting headers belongs to different Ledgers ',
                      p_level       => c_level_procedure,
                      p_module      => l_log_module
                     );
            END IF;

            EXIT;
         END IF;
      END LOOP;

      IF l_cont_flag = 'Y'
      THEN
         -- validating the ledger belongs to primary ledger or not
         BEGIN
            SELECT ledger_category_code
              INTO l_ledger_category
              FROM gl_ledgers
             WHERE ledger_id = l_first_ledger_id;
         END;

         IF l_ledger_category <> 'PRIMARY'
         THEN
            IF (c_level_procedure >= g_log_level)
            THEN
               TRACE (p_msg         => 'Ledger Is Not A Primary Ledger ',
                      p_level       => c_level_procedure,
                      p_module      => l_log_module
                     );
            END IF;

            --DBMS_OUTPUT.put_line ('LEDGER IS NOT A PRIMARY LEDGER ');
         ELSE
            FOR k IN p_list_ae_header_id.FIRST .. p_list_ae_header_id.LAST
            LOOP
               IF (c_level_statement >= g_log_level)
               THEN
                  TRACE (p_msg         => 'Before Calling the rev_jour_entry',
                         p_module      => l_log_module,
                         p_level       => c_level_statement
                        );
               END IF;

               IF (c_level_procedure >= g_log_level)
               THEN
                  TRACE (p_msg         =>    'Creating Reversal for the accounting header'
                                          || p_list_ae_header_id (k),
                         p_level       => c_level_procedure,
                         p_module      => l_log_module
                        );
               END IF;

               /*--DBMS_OUTPUT.put_line
                      (   'Processing the Reversal for the accounting header '
                       || p_list_ae_header_id (k)
                      );*/
               rev_jour_entry (p_ae_header_id       => p_list_ae_header_id (k),
                               p_return_status      => l_return_status,
                               p_error_msg          => l_error_msg
                              );

               IF (c_level_procedure >= g_log_level)
               THEN
                  TRACE (p_msg         =>    'Status for the accounting header '
                                          || p_list_ae_header_id (k)
                                          || l_return_status,
                         p_level       => c_level_procedure,
                         p_module      => l_log_module
                        );
               END IF;

               /*DBMS_OUTPUT.put_line
                            (
                            );*/
               IF l_return_status <> 'S'
               THEN
                  ROLLBACK;
                  EXIT;
               END IF;

               p_return_status := l_return_status;
               p_error_msg := l_error_msg;

               IF (c_level_statement >= g_log_level)
               THEN
                  TRACE (p_msg         => 'After  rev_jour_entry',
                         p_module      => l_log_module,
                         p_level       => c_level_statement
                        );
               END IF;
            END LOOP;
         END IF;
      ELSE
         p_return_status := 'E';
         p_error_msg := l_error_msg;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         IF (c_level_procedure >= g_log_level)
         THEN
            TRACE (p_msg         => SQLERRM,
                   p_level       => c_level_procedure,
                   p_module      => l_log_module
                  );
         END IF;
   END rev_jour_entry_list;

----------------------------------------------------------------------------------
-- Function (GET_GROUP_ID) To Get the Group ID
----------------------------------------------------------------------------------
   FUNCTION get_group_id (
      p_ledger_short_name     IN   VARCHAR2,
      p_appl_short_name       IN   VARCHAR2,
      p_end_date              IN   DATE,
      p_accounting_batch_id   IN   NUMBER,
      p_init_msg_list         IN   VARCHAR2 DEFAULT fnd_api.g_true,
      p_api_version           IN   NUMBER DEFAULT 1.0
   )
      RETURN NUMBER
   IS
--Declaring Process Variables
      l_group_id         xla_ae_headers.GROUP_ID%TYPE;
      l_log_module       VARCHAR2 (240);
      l_pro_records      NUMBER;
      l_ledger_status    VARCHAR2 (100);
      l_primary          VARCHAR2 (100);
      l_ledger_id        NUMBER;
      l_application_id   NUMBER;

      TYPE tab_ae_header_id IS TABLE OF NUMBER
         INDEX BY BINARY_INTEGER;

      l_arry_ae_hdr_id   tab_ae_header_id;
   BEGIN
      IF g_log_enabled
      THEN
         l_log_module := c_default_module || '.get_group_id';
      END IF;

      IF (c_level_procedure >= g_log_level)
      THEN
         TRACE (p_msg         => 'BEGIN of get_group_id',
                p_level       => c_level_procedure,
                p_module      => l_log_module
               );
      END IF;

      BEGIN
         SELECT application_id
           INTO l_application_id
           FROM fnd_application
          WHERE application_short_name = p_appl_short_name;
      EXCEPTION
         WHEN xla_exceptions_pkg.application_exception
         THEN
            RAISE;
         WHEN OTHERS
         THEN
            /*  p_err_message :=
                      ' Application short name  is not a Valid Value'
                   || p_appl_short_name;*/
            l_group_id := -2;
            xla_exceptions_pkg.raise_message (p_location      => 'xla_fsah_int_pvt.set_group_id'
                                             );
      END;

      BEGIN
         SELECT glc.completion_status_code, gll.ledger_category_code,
                gll.ledger_id
           INTO l_ledger_status, l_primary,
                l_ledger_id
           FROM gl_ledgers gll, gl_ledger_configurations glc
          WHERE gll.short_name = p_ledger_short_name AND gll.NAME = glc.NAME;
      EXCEPTION
         WHEN xla_exceptions_pkg.application_exception
         THEN
            RAISE;
         WHEN OTHERS
         THEN
            l_group_id := -2;
            xla_exceptions_pkg.raise_message (p_location      => 'xla_fsah_int_pvt.Get_group_id'
                                             );
      END;

      IF UPPER (l_ledger_status) = 'CONFIRMED'
      THEN
         IF UPPER (l_primary) = 'PRIMARY'
         THEN
            IF (c_level_statement >= g_log_level)
            THEN
               TRACE (p_msg         =>    'Ledger short name  '
                                       || p_ledger_short_name,
                      p_module      => l_log_module,
                      p_level       => c_level_statement
                     );
            END IF;

            SELECT ae_header_id
            BULK COLLECT INTO l_arry_ae_hdr_id
              FROM xla_ae_headers
             WHERE gl_transfer_status_code = 'N'
               AND accounting_entry_status_code = 'F'
               AND application_id = l_application_id
               AND accounting_date <= p_end_date
               -- AND accounting_batch_id = p_accounting_batch_id -- excluded so as in the next run records failed to transfer to PSFT will pick again
               AND ledger_id IN (
                      SELECT DISTINCT target_ledger_id
                                 FROM gl_ledger_relationships
                                WHERE source_ledger_id = l_ledger_id
                                  AND NVL (relationship_enabled_flag, 'N') =
                                                                           'Y');

            IF l_arry_ae_hdr_id.COUNT = 0
            THEN
               IF (c_level_statement >= g_log_level)
               THEN
                  TRACE (p_msg         =>    'No. of Records need  updated  are zero   '
                                          || p_ledger_short_name,
                         p_module      => l_log_module,
                         p_level       => c_level_statement
                        );
               END IF;

               l_group_id := -1;
            ELSE
               IF (c_level_statement >= g_log_level)
               THEN
                  TRACE (p_msg         => 'Before Updating the group_id and Status  in xla_ae_headers',
                         p_module      => l_log_module,
                         p_level       => c_level_statement
                        );
               END IF;

              /* DBMS_OUTPUT.put_line ('Before Updating the group_id and Status  in xla_ae_headers'
                                    );*/

               SELECT gl_journal_import_s.NEXTVAL
                 INTO l_group_id
                 FROM DUAL;
            END IF;
         ELSE
            l_group_id := -2;
         END IF;
      ELSE
         l_group_id := -2;
      END IF;

      --DBMS_OUTPUT.put_line ('new_group_id  ' || l_group_id);

      IF (c_level_statement >= g_log_level)
      THEN
         TRACE (p_msg         => 'new_group_id  ' || l_group_id,
                p_module      => l_log_module,
                p_level       => c_level_statement
               );
      END IF;

        ---------FND_LOG---------
      /*  IF (c_level_procedure >= g_log_level)
        THEN
            TRACE (p_msg          => 'END of get_group_id',
                   p_level        => c_level_procedure,
                   p_module       => l_log_module
                  );
        END IF;*/
      RETURN l_group_id;
   EXCEPTION
      WHEN xla_exceptions_pkg.application_exception
      THEN
         RAISE;
      WHEN OTHERS
      THEN
         --DBMS_OUTPUT.put_line (SQLERRM);

         IF (c_level_statement >= g_log_level)
         THEN
            TRACE (p_msg         => SQLERRM,
                   p_module      => l_log_module,
                   p_level       => c_level_statement
                  );
         END IF;

         xla_exceptions_pkg.raise_message (p_location      => 'XLA_FSAH_INT_PVT.get_group_id'
                                          );
   END get_group_id;

----------------------------------------------------------------------------------
-- Procedure (SET_GROUP_ID) To Setting Up Group ID
----------------------------------------------------------------------------------
   PROCEDURE set_group_id (
      p_ledger_short_name     IN   VARCHAR2,
      p_appl_short_name       IN   VARCHAR2,
      p_end_date              IN   DATE,
      p_accounting_batch_id   IN   NUMBER,
      p_group_id              IN   NUMBER,
      p_init_msg_list         IN   VARCHAR2 DEFAULT fnd_api.g_true,
      p_api_version           IN   NUMBER DEFAULT 1.0,
      p_commit                IN   BOOLEAN DEFAULT TRUE
   )
   IS
--Declaring Process Variables
      l_pro_records          NUMBER;
      l_ledger_status        VARCHAR2 (100);
      l_primary              VARCHAR2 (100);
      l_ledger_id            NUMBER;

      TYPE tab_ae_header_id IS TABLE OF NUMBER
         INDEX BY BINARY_INTEGER;

      l_arry_ae_hdr_id_set   tab_ae_header_id;
      l_log_module           VARCHAR2 (240);
      l_application_id       NUMBER;
   BEGIN
    -----FND_LOG-----------
--  IF g_log_enabled THEN
      l_log_module := c_default_module || '.set_group_id';

--  END IF;
      IF (c_level_procedure >= g_log_level)
      THEN
         TRACE (p_msg         => 'BEGIN of set_group_id',
                p_level       => c_level_procedure,
                p_module      => l_log_module
               );
      END IF;

      BEGIN
         SELECT ledger_id
           INTO l_ledger_id
           FROM gl_ledgers
          WHERE short_name = p_ledger_short_name;
      EXCEPTION
         WHEN xla_exceptions_pkg.application_exception
         THEN
            RAISE;
         WHEN OTHERS
         THEN
            --DBMS_OUTPUT.put_line ('Invalid Application');

            IF (c_level_statement >= g_log_level)
            THEN
               TRACE (p_msg         => 'Invalid Ledger',
                      p_module      => l_log_module,
                      p_level       => c_level_statement
                     );
            END IF;
      END;

      BEGIN
         SELECT application_id
           INTO l_application_id
           FROM fnd_application
          WHERE application_short_name = p_appl_short_name;
      EXCEPTION
         WHEN xla_exceptions_pkg.application_exception
         THEN
            RAISE;
         WHEN OTHERS
         THEN
            IF (c_level_statement >= g_log_level)
            THEN
               TRACE (p_msg         => 'Invalid Ledger',
                      p_module      => l_log_module,
                      p_level       => c_level_statement
                     );
            END IF;
      /*  p_err_message :=
                ' Application short name  is not a Valid Value'
             || p_appl_short_name;
  xla_exceptions_pkg.raise_message (p_location       => 'Invalid Application ID'
                                       );*/
      END;

      -- Identifying the records to update
      SELECT ae_header_id
      BULK COLLECT INTO l_arry_ae_hdr_id_set
        FROM xla_ae_headers
       WHERE gl_transfer_status_code = 'N'
         AND accounting_entry_status_code = 'F'
         AND application_id = l_application_id
         AND accounting_date <= p_end_date
         -- AND accounting_batch_id = p_accounting_batch_id -- excluded so as in the next run records failed to transfer to PSFT will pick again
         AND ledger_id IN (
                SELECT DISTINCT target_ledger_id
                           FROM gl_ledger_relationships
                          WHERE source_ledger_id = l_ledger_id
                            AND NVL (relationship_enabled_flag, 'N') = 'Y');

-- Updating the records with group id

      /*DBMS_OUTPUT.put_line (   'Total records identified to Updated = '
                            || l_arry_ae_hdr_id_set.COUNT
                           );*/
      FORALL i IN l_arry_ae_hdr_id_set.FIRST .. l_arry_ae_hdr_id_set.LAST
         UPDATE xla_ae_headers
            SET gl_transfer_status_code = 'S',
                GROUP_ID = p_group_id
          WHERE ae_header_id = l_arry_ae_hdr_id_set (i);

--dbms_output.put_line('Total records Updated = ' || SQL%BULK_ROWCOUNT);

      ---------FND_LOG---------
      IF (c_level_procedure >= g_log_level)
      THEN
         TRACE (p_msg         => 'END of set_group_id',
                p_level       => c_level_procedure,
                p_module      => l_log_module
               );
      END IF;
   END set_group_id;

------------------------------------------------------------------------------------
-- Procedure (SET_TRANSFER_STATUS)
------------------------------------------------------------------------------------
-- Used to data setup for the new transfermation
   PROCEDURE set_transfer_status (
      p_group_id        IN              NUMBER,
      p_batch_status    IN              VARCHAR2,
      p_api_version     IN              NUMBER DEFAULT 1.0,
      p_return_status   OUT NOCOPY      VARCHAR2,
      p_err_msg         OUT NOCOPY      VARCHAR2
   )
   IS
------------------------------------------------------------------------------------
-- Declaring Local Variabls
------------------------------------------------------------------------------------
      l_group_id          xla_ae_headers.GROUP_ID%TYPE;
      l_batch_status      VARCHAR2 (10);
      l_records_updated   NUMBER;
      l_return_status     VARCHAR2 (100);
      l_msg_data          VARCHAR2 (100);
      l_msg_count         NUMBER;
      l_log_module        VARCHAR2 (240);
   BEGIN
      -----FND_LOG-----------
      IF g_log_enabled
      THEN
         l_log_module := c_default_module || '.set_transfer_status';
      END IF;

      IF (c_level_procedure >= g_log_level)
      THEN
         TRACE (p_msg         => 'BEGIN of set_transfer_status',
                p_level       => c_level_procedure,
                p_module      => l_log_module
               );
      END IF;

----------------------
      fnd_global.apps_initialize (1001530, 20419, 200);
------------------------------------------------------------------------------------
--Local Variable Values
------------------------------------------------------------------------------------
      l_group_id := p_group_id;
      l_batch_status := p_batch_status;

------------------------------------------------------------------------------------
--CONDITIONAL UPDATE FOR REPROCESSING DATA
------------------------------------------------------------------------------------
      IF l_batch_status = 'Y' AND l_group_id IS NOT NULL
      THEN
------------------------------------------------------------------------------------
--Condition Sucess
------------------------------------------------------------------------------------
         UPDATE xla_ae_headers
            SET gl_transfer_status_code = 'Y',
                gl_transfer_date = TO_CHAR (SYSDATE, 'DD-MON-YYYY'),
                last_update_date = TO_CHAR (SYSDATE, 'DD-MON-YYYY'),
                last_updated_by = fnd_profile.VALUE ('USER_ID'),
                last_update_login = fnd_profile.VALUE ('LOGIN_ID')
          WHERE GROUP_ID = l_group_id
            AND accounting_entry_status_code = 'F'
            AND gl_transfer_status_code = 'S';

         IF SQL%ROWCOUNT > 0
         THEN
            l_return_status := 'Y';
            l_msg_data :=
                        'SETTING UP TRANSFER STATUS IS SUCESSFULLY COMPLETED';
            l_msg_count := '0';
         ELSE
            l_return_status := 'N';
            l_msg_data := 'Validation Failure';
            l_msg_count := '0';
         END IF;
      ELSIF l_batch_status = 'F' AND l_group_id IS NOT NULL
      THEN
------------------------------------------------------------------------------------
--Condition Failure
------------------------------------------------------------------------------------
         UPDATE xla_ae_headers
            SET GROUP_ID = NULL,
                gl_transfer_status_code = 'N',
                last_update_date = TO_CHAR (SYSDATE, 'DD-MON-YYYY'),
                last_updated_by = fnd_profile.VALUE ('USER_ID'),
                last_update_login = fnd_profile.VALUE ('LOGIN_ID')
          WHERE GROUP_ID = l_group_id
            AND accounting_entry_status_code = 'F'
            AND gl_transfer_status_code = 'S';

         IF SQL%ROWCOUNT > 0
         THEN
            l_return_status := 'Y';
            l_msg_data :=
                        'SETTING UP TRANSFER STATUS IS SUCESSFULLY COMPLETED';
            l_msg_count := '0';
         ELSE
            l_return_status := 'N';
            l_msg_data := 'Validation Failure';
            l_msg_count := '0';
         END IF;

         COMMIT;
      END IF;

      ---------FND_LOG---------
      IF (c_level_procedure >= g_log_level)
      THEN
         TRACE (p_msg         => 'END of set_transfer_status',
                p_level       => c_level_procedure,
                p_module      => l_log_module
               );
      END IF;

        -------------------------
------------------------------------------------------------------------------------
--Setting Up Out Parameters
------------------------------------------------------------------------------------
      p_return_status := l_return_status;
      p_err_msg := l_msg_data;
      /*  p_msg_count := l_msg_count;*/
------------------------------------------------------------------------------------
--Exception
------------------------------------------------------------------------------------
   EXCEPTION
      WHEN xla_exceptions_pkg.application_exception
      THEN
         RAISE;
      WHEN OTHERS
      THEN
         NULL;
         xla_exceptions_pkg.raise_message (p_location      => 'xla_fsah_int_pvt.set_transfer_status'
                                          );
   END set_transfer_status;
BEGIN
   g_log_level := fnd_log.g_current_runtime_level;
   g_log_enabled :=
          fnd_log.test (log_level      => g_log_level,
                        module         => c_default_module);

   IF NOT g_log_enabled
   THEN
      g_log_level := c_level_log_disabled;
   END IF;
END xla_fsah_int_pvt;

/
