--------------------------------------------------------
--  DDL for Package Body FUN_SEQ_BATCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FUN_SEQ_BATCH" AS
/* $Header: funsqbtb.pls 120.43.12010000.4 2010/01/18 12:17:35 degoel ship $ */
--
-- For debuggin
--
   g_module   CONSTANT VARCHAR2(30) :=  'fun.plsql.fun_seq_batch';
-- added global variable for sort by GL Date at posting event
   g_sort_option_code           fun_seq_contexts.sort_option%TYPE;
-- PROCEDURE NAME:
--   Batch_Init
--   *** For XLA Accounting Program ***
-- DESCRIPTION:
--   Populate Sequencing setup data in fun_seq_request
--   This procedure is called from Accounting and Reporting Sequencing
--   Program.
-- INPUT:
--    - p_application_id
--      Application Id of your Sequence Entity.
--    - p_table_name
--      Table Name of your Sequence Entity.
--    - p_event_code
--      Sequence Event Code
--    - p_context_type
--      Sequence Context Type.  Only 'LEDGER_AND_CURRENCY' is supported
--      for Accounting Sequencing.
--    - p_context_value_tbl
--      Sequence Context Value. Only Ledger ID is supported for
--      Accounting Sequencing.
--    - p_request_id
--      the request ID of current process
-- OUTPUT:
--    - x_status
--      the status of current processing
--        SUCCESS       - At least one active sequencing context was locked
--        NO_SEQUENCING - No sequencing context was found for the input
--    - x_seq_context_id
--      Sequence Context ID found based on the provided input.
--      Meaningful  only when a single context value is passed in.
--
PROCEDURE Batch_Init(
            p_application_id        IN  NUMBER,
            p_table_name            IN  VARCHAR2,
            p_event_code            IN  VARCHAR2,
            p_context_type          IN  VARCHAR2,
            p_context_value_tbl     IN  context_value_tbl_type,
            p_request_id            IN  NUMBER,
            x_status                OUT NOCOPY VARCHAR2,
            x_seq_context_id        OUT NOCOPY NUMBER)
IS
  PRAGMA AUTONOMOUS_TRANSACTION;
  l_seq_context_id         fun_seq_contexts.seq_context_id%TYPE;
  l_control_date_type      fun_seq_contexts.date_type%TYPE;
  l_req_assign_flag        fun_seq_contexts.require_assign_flag%TYPE;
  l_sort_option_code       fun_seq_contexts.sort_option%TYPE;
  l_sequence_type          fun_seq_headers.gapless_flag%TYPE;

  l_seq_context_found      BOOLEAN DEFAULT FALSE;
  l_module                 CONSTANT VARCHAR2(100) DEFAULT
                                        g_module || '.' || 'batch_init';
BEGIN
  --
  -- Debug Info Begin
  --
  IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(
      log_level => fnd_log.level_procedure,
      module    => l_module || '.' || 'begin',
      message   =>
       'p_application_id => ' || p_application_id || ', ' ||
       'p_table_name => '     || p_table_name     || ', ' ||
       'p_event_code => '     || p_event_code     || ', ' ||
       'p_context_type => '   || p_context_type   || ', ' ||
       'p_context_value => '  || p_context_value_tbl.FIRST || ', ' ||
       'p_request_id => '     || p_request_id);
  END IF;
  --
  -- Release the lock of Sequencing Setup Data
  -- of completed concurrent requests
  --
  delete_seq_requests (p_request_id => null);
  --
  -- Retrieve Sequencing Context Information
  --
  IF p_context_value_tbl.COUNT > 0 THEN
    FOR i IN p_context_value_tbl.FIRST .. p_context_value_tbl.LAST LOOP
      fun_seq.get_assign_context_info(
        p_context_type           => p_context_type,
        p_context_value          => p_context_value_tbl(i),
        p_application_id         => p_application_id,
        p_table_name             => p_table_name,
        p_event_code             => p_event_code,
        p_request_id             => p_request_id,
        x_seq_context_id         => l_seq_context_id,
        x_control_date_type      => l_control_date_type,
        x_req_assign_flag        => l_req_assign_flag,
        x_sort_option_code       => l_sort_option_code);

      --
      -- Create Sequencing Setup Records in FUN_SEQ_REQUESTS
      --
      IF l_seq_context_id IS NOT NULL THEN
        --
        -- Make Sequencing Setup pages display only
        --
        populate_seq_requests(
          p_request_id     => p_request_id,
          p_seq_context_id => l_seq_context_id);

        IF NOT l_seq_context_found THEN
          l_seq_context_found := TRUE;
        END IF;

      END IF;
    END LOOP;
  END IF;  -- p_context_value_tbl.COUNT > 0

  --
  -- Set return values
  --
  IF l_seq_context_found THEN
    x_status         := 'SUCCESS';
    x_seq_context_id := l_seq_context_id;
  ELSE
    x_status := 'NO_SEQUENCING';
  END IF;
  --
  -- Autonomous Commit
  --
  COMMIT;
  --
  -- Debug Info End
  --
  IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(
      log_level => fnd_log.level_procedure,
      module    => l_module || '.' || 'end',
      message   => 'x_status => '         || x_status  || ', ' ||
                   'x_seq_context_id => ' || x_seq_context_id);
  END IF;
EXCEPTION
WHEN OTHERS THEN
  --
  -- Logging
  --
  IF fnd_log.level_error >= fnd_log.g_current_runtime_level THEN
    fnd_log.string (
      log_level => fnd_log.level_error,
      module    => l_module,
      message   => 'SQLERRM: ' || SQLERRM);
  END IF;
  --
  -- Raise Exception
  --
  app_exception.raise_exception;
END Batch_Init;

-- PROCEDURE NAME:
--   Batch_Init
-- DESCRIPTION:
--   Populate Sequencing setup data in fun_seq_request
--   **** For GL Posting Program ****
PROCEDURE Batch_Init(
            p_request_id            IN  NUMBER,
            p_ledgers_tbl           IN  num15_tbl_type,
            x_ledgers_locked_tbl    OUT NOCOPY num15_tbl_type,
            x_ledgers_locked_cnt    OUT NOCOPY NUMBER) IS

  PRAGMA AUTONOMOUS_TRANSACTION;
  l_seq_context_id    fun_seq_contexts.seq_context_id%TYPE;
  l_date_type         fun_seq_contexts.date_type%TYPE;
  l_req_assign_flag   fun_seq_contexts.require_assign_flag%TYPE;
  l_sort_option_code  fun_seq_contexts.sort_option%TYPE;
  l_assign_id_tbl     assign_id_tbl_type;
  l_seq_type_tbl      seq_type_tbl_type;
  l_seq_head_id_tbl   seq_head_id_tbl_type;

  l_module            CONSTANT VARCHAR2(100) DEFAULT
                                     g_module || '.' || 'batch_init';
BEGIN
  --
  -- Debug Info
  --
  IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(
      log_level => fnd_log.level_procedure,
      module    => l_module || '.'    || 'begin',
      message   => 'p_request_id => ' || p_request_id);
  END IF;
  --
  -- Release the lock of Sequencing Setup Data
  -- of completed concurrent requests
  --
  delete_seq_requests (p_request_id => null);
  --
  --
  --
  IF p_ledgers_tbl.COUNT > 0 THEN
    FOR i IN p_ledgers_tbl.FIRST .. p_ledgers_tbl.LAST LOOP
      --
      -- Retrieve Sequencing Context Information
      --
      fun_seq.get_assign_context_info(
        p_context_type       => 'LEDGER_AND_CURRENCY',
        p_context_value      => p_ledgers_tbl(i),
        p_application_id     => 101,
        p_table_name         => 'GL_JE_HEADERS',
        p_event_code         => 'POSTING',
        p_request_id         => NULL,  -- Don't use cache. Not locked yet.
        x_seq_context_id     => l_seq_context_id,
        x_control_date_type  => l_date_type,
        x_req_assign_flag    => l_req_assign_flag,
        x_sort_option_code   => l_sort_option_code);

      --
      -- If a valid sequencing context is found,
      -- insert a record into fun_seq_requests.
      --
      IF l_seq_context_id IS NOT NULL THEN
        populate_seq_requests (
          p_request_id     => p_request_id,
          p_seq_context_id => l_seq_context_id);
        --
        -- Set the locked Ledger Ids to the parameter
        --
        x_ledgers_locked_tbl(i) := p_ledgers_tbl(i);
      END IF;
    END LOOP;
  END IF;

  --
  -- Set the number of locked Ledgers to the parameter
  --
  x_ledgers_locked_cnt := x_ledgers_locked_tbl.COUNT;

  COMMIT;
  --
  -- Debug Info
  --
  IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(
      log_level => fnd_log.level_procedure,
      module    => l_module || '.'    || 'end',
      message   => 'x_ledgers_locked_cnt => ' || x_ledgers_locked_cnt);
  END IF;
EXCEPTION
WHEN OTHERS THEN
  --
  -- Logging
  --
  IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(
      log_level => fnd_log.level_exception,
      module    => l_module,
      message   => 'p_request_id: '     || p_request_id     || ', ' ||
                   'SQLERRM: '          || SQLERRM);
  END IF;
  --
  -- Rollback transctions. As the autonomous transaction pragma is
  -- specified, transactions outside this procedure are not affected.
  --
  ROLLBACK;
  --
  -- Raise Exception
  --
  app_exception.raise_exception;
END Batch_Init;

--
-- Procedure Name: Batch_Exit
-- Description:
--   Unlocks setup data by deleting records from fun_seq_requests
--   The exception in this program is not considered critical.
--   So, even if the caller receives 'FAILURE', they should not
--   raise an exception.
--   INPUT
--     p_request_id
--       the request ID of current process
--   OUTPUT
--     x_status
--       the status of current processing
--         SUCCESS setup data were unlocked successfully
--         FAILURE unexpected error occured during unlocking
PROCEDURE Batch_Exit(
            p_request_id            IN  NUMBER,
            x_status                OUT NOCOPY  VARCHAR2)
  IS
    PRAGMA AUTONOMOUS_TRANSACTION;

  l_module  CONSTANT VARCHAR2(100) DEFAULT g_module || '.' || 'batch_exit';

BEGIN
  --
  -- Debug Info - Begin
  --
  IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(
      log_level => fnd_log.level_procedure,
      module    => l_module || '.'    || 'begin',
      message   => 'p_request_id => ' || p_request_id);
  END IF;
  --
  -- Release the lock of Sequencing Setup Data
  -- of completed concurrent requests
  --
  delete_seq_requests (p_request_id => p_request_id);
  --
  -- Return Status
  --
  x_status := 'SUCCESS';
  --
  -- Automnomous Commit
  --
  COMMIT;

  -- Debug Info - End
  --
  IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(
      log_level => fnd_log.level_procedure,
      module    => l_module || '.'|| 'end',
      message   => 'x_status => ' || x_status);
  END IF;
EXCEPTION
WHEN OTHERS THEN
  --
  -- Logging
  --
  IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(
      log_level => fnd_log.level_exception,
      module    => l_module,
      message   => 'p_request_id: '     || p_request_id     || ', ' ||
                   'SQLERRM: '          || SQLERRM);
  END IF;
  --
  -- Send Alert to the OAM and set the request status to Warning
  --
  x_status := 'FAILURE';
END Batch_Exit;

--
-- PROCEDURE NAME:
--   Generate_Bulk_Numbers
-- 1. returns the sequence numbers and ae_header_IDs for records with the same
--    assignment ID and sequence version ID
-- 2. updates the current number for the sequence version
--
-- Used in Subledger Accounting Program and GL Posting Program
--
-- UNIT 1
-- Ae_header_Id  Seq_Ver_Id Assignment_Id
-- 1               2            200
-- 2               2            200
-- UNIT 2
-- 3               3            100
-- 4               3            100
-- 5               3            100
-- UNIT 3
-- 6               3            300

PROCEDURE Generate_Bulk_Numbers(
            p_request_id           IN  NUMBER,
            p_seq_ver_id_tbl       IN  seq_ver_id_tbl_type,
            p_assign_id_tbl        IN  assign_id_tbl_type,
            x_seq_value_tbl        OUT NOCOPY  seq_value_tbl_type,
            x_seq_date_tbl         OUT NOCOPY  date_tbl_type) IS

  ind_prior         BINARY_INTEGER;
  ind_next          BINARY_INTEGER;

  l_seq_ver_id_tbl  seq_ver_id_tbl_type;
  l_assign_id_tbl   assign_id_tbl_type;

  l_current_value   fun_seq_versions.current_value%TYPE;
  l_sequenced_date  DATE;
  l_error_code      VARCHAR2(30);

  l_module          CONSTANT VARCHAR2(100) DEFAULT
                               g_module || '.' || 'generate_bulk_numbers';

BEGIN
  --
  -- Debug Information
  --
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(
      FND_LOG.LEVEL_PROCEDURE,
      'fun.plsql.fun_seq_batch.generate_bulk_numbers.begin',
      'Beginning of generate_bulk_numbers');
  END IF;
  --
  -- Hold parameters in local variables
  --
  l_seq_ver_id_tbl := p_seq_ver_id_tbl;
  l_assign_id_tbl  := p_assign_id_tbl;
  --
  -- Loop for Accounting Entries
  --
  IF l_seq_ver_id_tbl.COUNT > 0 THEN
    FOR i in l_seq_ver_id_tbl.FIRST .. l_seq_ver_id_tbl.LAST LOOP
      ind_prior := l_assign_id_tbl.PRIOR(i);
      ind_next  := l_assign_id_tbl.NEXT(i);
      --
      -- Call Generate Sequence Number for the first record
      -- ,or when Assignment ID or Sequence Version ID is different
      -- from the prior record
      --
      -- !! Warning !!
      --  Evaluate "IS NULL" first. l_assign_id_tbl(null) gives an exception
      IF (ind_prior IS NULL) OR
         (l_assign_id_tbl(ind_prior)  <> l_assign_id_tbl(i) OR
          l_seq_ver_id_tbl(ind_prior) <> l_seq_ver_id_tbl(i))
      THEN
       fun_seq.generate_sequence_number(
                  p_assignment_id    => l_assign_id_tbl(i),
                  p_seq_version_id   => l_seq_ver_id_tbl(i),
                  p_sequence_type    => 'G',
                  p_request_id       => NVL(p_request_id,-99),
                  x_sequence_number  => l_current_value,
                  x_sequenced_date   => l_sequenced_date,
                  x_error_code       => l_error_code) ;
        x_seq_value_tbl(i) := l_current_value;
        x_seq_date_tbl(i)  := l_sequenced_date;
      ELSE
        --
        -- Same Assignment ID and Sequence Version ID
        -- Increment current value
        --
        l_current_value := l_current_value + 1;
        x_seq_value_tbl(i) := l_current_value;
        x_seq_date_tbl(i)  := l_sequenced_date; -- Number/Date Correlation
        --
        -- If this is the last record (ind_next is NULL) of the input parameter
        -- or of the unit then update DB Current Value of the Sequence
        -- Version ID.
        --
        -- !! Warning !!
        --  Evaluate "IS NULL" first. l_assign_id_tbl(null) gives an exception
        --
        IF  ind_next IS NULL OR
           (l_assign_id_tbl(ind_next)  <> l_assign_id_tbl(i) OR
            l_seq_ver_id_tbl(ind_next) <> l_seq_ver_id_tbl(i))
        THEN
          --
          -- Update the current_value
          --
          UPDATE fun_seq_versions
             SET current_value = l_current_value
           WHERE seq_version_id = l_seq_ver_id_tbl(i);
        END IF;  -- Update the Last Used Number or Not
      END IF; -- Call Generate Sequence Number or Not
    END LOOP;
  END IF;
  --
  -- Debug Information
  --
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(
      FND_LOG.LEVEL_PROCEDURE,
      'fun.plsql.fun_seq_batch.generate_bulk_numbers.end',
      'Generate_bulk_numbers completes successfully.');
  END IF;
EXCEPTION
WHEN OTHERS THEN
  --
  -- Logging
  --
  IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(
      log_level => fnd_log.level_exception,
      module    => l_module,
      message   => 'p_request_id: '     || p_request_id    ||', ' ||
                   'SQLERRM: '          || SQLERRM);
  END IF;
  --
  -- Raise Exception
  --
  app_exception.raise_exception;
END Generate_Bulk_Numbers;

--
-- PROCEDURE NAME:
--   Populate_Acct_Seq_Info  *** For XLA Accounting Program ***
-- DESCRIPTION
--
PROCEDURE Populate_Acct_Seq_Info(
            p_calling_program IN  VARCHAR2,
            p_request_id      IN  NUMBER) IS

  no_assigned_seq_info         EXCEPTION;

BEGIN
  --
  -- Debug Information
  --
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(
       FND_LOG.LEVEL_PROCEDURE,
      'fun.plsql.fun_seq_batch.populate_acct_seq_info.begin',
      'Calling fun_seq_batch.populate_acct_seq_info:'||
      'p_calling_program => ' || p_calling_program ||', ' ||
      'p_request_id => ' || p_request_id );
  END IF;

  --
  -- Populate Sequencing information in Accounting and Reporting
  -- Sequence Database Objects
  --
  IF p_calling_program = 'ACCOUNTING' THEN
    Populate_Acct_Seq_Prog_View (p_request_id);
  ELSIF p_calling_program = 'REPORTING' THEN
    Populate_Rep_Seq_Prog_Gt (p_request_id);
  END IF;

  --
  -- Debug Information
  --
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(
       FND_LOG.LEVEL_PROCEDURE,
      'fun.plsql.fun_seq_batch.populate_acct_seq_info.end',
      'Calling fun_seq_batch.populate_acct_seq_info:'||
      'p_calling_program => ' || p_calling_program ||', ' ||
      'p_request_id => ' || p_request_id );
  END IF;
EXCEPTION
WHEN no_assigned_seq_info THEN
  --
  -- Logging
  --
  IF fnd_log.level_error >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(
      log_level => fnd_log.level_error,
      module
        => 'fun.plsql.fun_seq_batch.populate_acct_seq_info.error',
      message   => 'p_request_id: '  || p_request_id ||', ' ||
                    'SQLERRM: '       || SQLERRM);
  END IF;
  --
  -- Raise Exception
  --
  fnd_message.set_name  ('FUN','FUN_SEQ_NO_ACTIVE_ASSGN_FOUND');
  fnd_message.set_token ('SEQ_CONTEXT_NAME',
                          fun_seq.get_seq_context_name(null));
  app_exception.raise_exception;
WHEN OTHERS THEN
  --
  -- Logging
  --
  IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(
      log_level => fnd_log.level_exception,
      module
        => 'fun.plsql.fun_seq_batch.populate_acct_seq_info.exception',
      message   => 'p_request_id: '  || p_request_id ||', ' ||
                   'SQLERRM: '       || SQLERRM);
  END IF;
  --
  -- Raise Exception
  --
  app_exception.raise_exception;
END Populate_Acct_Seq_Info;
--
-- PROCEDURE NAME:
--   Populate_Seq_Info  *** For GL Posting Program ***
-- DESCRIPTION
--
PROCEDURE Populate_Seq_Info IS

  l_ledger_id_tbl        ledger_id_tbl_type;
  l_je_header_id_tbl     je_header_id_tbl_type;
  l_actual_flag_tbl      actual_flag_tbl_type;
  l_je_source_tbl        je_source_tbl_type;
  l_je_category_tbl      je_category_tbl_type;
  l_gl_date_tbl          date_tbl_type;

  l_ctrl_attr_rec        fun_seq.control_attribute_rec_type;
  l_ctrl_date_tbl        fun_seq.control_date_tbl_type
                           := fun_seq.control_date_tbl_type();

  l_seq_ver_id_tbl       seq_ver_id_tbl_type;
  l_assign_id_tbl        assign_id_tbl_type;
  l_out_ctrl_dt_tbl      date_tbl_type;
  l_req_assign_flag_tbl  req_assign_flag_tbl_type;
  l_error_code_tbl       error_code_tbl_type;
  l_dummy_tbl            vc30_tbl_type;  -- For Sort Option

  l_dummy                fun_seq_headers.gapless_flag%TYPE;
  no_assigned_seq_info   EXCEPTION;

  l_debug_je_header_id   NUMBER;
BEGIN
  --
  -- Debug Information
  --
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(
        FND_LOG.LEVEL_PROCEDURE,
        'fun.plsql.fun_seq_batch.populate_seq_info.begin',
        'Beginning of Populate_Seq_Info');
  END IF;
  --
  -- GL date is the only Sequence Control Date Type
  -- avaialbe for GL Posting Program
  --
  l_ctrl_date_tbl.EXTEND(1);
  l_ctrl_date_tbl(1).date_type  := 'GL_DATE';
  -- gl date is populated within the loop

  --
  -- Bulk Collect Journal Entry Information from fun_seq_batch_gt
  --
  SELECT jh.ledger_id,
         bg.source_id,
         jh.actual_flag,
         jh.je_source,
         jh.je_category,
         jh.default_effective_date
    BULK COLLECT
    INTO l_ledger_id_tbl,
         l_je_header_id_tbl,
         l_actual_flag_tbl,
         l_je_source_tbl,
         l_je_category_tbl,
         l_gl_date_tbl
    FROM fun_seq_batch_gt bg,
         gl_je_headers    jh
   WHERE bg.source_id = jh.je_header_id;
  --
  -- Loop for journal entries in fun_seq_batch_gt
  --
  FOR i IN l_je_header_id_tbl.FIRST .. l_je_header_id_tbl.LAST LOOP
    l_debug_je_header_id := l_je_header_id_tbl(i);
    --
    -- Set Local Variables
    --
    l_ctrl_attr_rec.balance_type     := l_actual_flag_tbl(i);
    l_ctrl_attr_rec.journal_source   := l_je_source_tbl(i);
    l_ctrl_attr_rec.journal_category := l_je_category_tbl(i);
    l_ctrl_date_tbl(1).date_value    := l_gl_date_tbl(i);
    --
    -- Debug Information
    --
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(
         FND_LOG.LEVEL_PROCEDURE,
        'fun.plsql.fun_seq_batch.populate_seq_info.config',
        'Calling fun_seq.get_assigned_sequence_info... '
        ||', '||
        'l_debug_je_header_id: '
            || l_debug_je_header_id                  ||', '||
        'l_ctrl_date_tbl(1).date_value (GL_DATE): '
            || l_ctrl_date_tbl(1).date_value         ||', '||
        'l_ctrl_attr_rec.balance_type: '
            || l_ctrl_attr_rec.balance_type          ||', '||
        'l_ctrl_attr_rec.journal_source: '
            || l_ctrl_attr_rec.journal_source        ||', '||
        'l_ctrl_attr_rec.journal_category: '
            || l_ctrl_attr_rec.journal_category
          );
    END IF;
    --
    -- Get Sequencing Context and Assignment Information
    --
    fun_seq.get_assigned_sequence_info(
      p_context_type             => 'LEDGER_AND_CURRENCY',
      p_context_value            => l_ledger_id_tbl(i),
      p_application_Id           => 101,
      p_table_name               => 'GL_JE_HEADERS',
      p_event_code               => 'POSTING',
      p_control_attribute_rec    => l_ctrl_attr_rec,
      p_control_date_tbl         => l_ctrl_date_tbl,
      p_request_id               => -1,  -- Use Cache
      p_suppress_error           => 'Y',
      x_sequence_type            => l_dummy,
      x_seq_version_id           => l_seq_ver_id_tbl(i),
      x_assignment_id            => l_assign_id_tbl(i),
      x_control_date_value       => l_out_ctrl_dt_tbl(i),     -- Not Used
      x_req_assign_flag          => l_req_assign_flag_tbl(i), -- Not Used
      x_sort_option_code         => g_sort_option_code,
      x_error_code               => l_error_code_tbl(i));

    --
    -- Debug Information
    --
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(
         FND_LOG.LEVEL_PROCEDURE,
        'fun.plsql.fun_seq_batch.populate_seq_info.config',
        'Returning from fun_seq.get_assigned_sequence_info... '
        ||', '||
        'l_seq_ver_id_tbl(i): ' || l_seq_ver_id_tbl(i) ||', '||
        'l_assign_id_tbl(i): '  || l_assign_id_tbl(i)  ||', '||
        'l_out_ctrl_dt_tbl(i): '|| l_out_ctrl_dt_tbl(i)||', '||
        'l_req_assign_flag_tbl(i): '
                    || l_req_assign_flag_tbl(i)        ||', '||
        'l_error_code_tbl(i): ' || l_error_code_tbl(i)
        );
    END IF;
    --
    -- Check Status Code
    -- Meaning of each Status
    -- [No action is required]
    -- NO_ASSIGN_CONTEXT
    -- NO_ASSIGNMENT
    -- [Update GL_JE_HEADERS with the information in FUN_SEQ_BATCH_GT
    -- DO_NOT_SEQUENCE
    -- SEQ_VER_FOUND
    -- [Critical Error]
    -- ENFORCE_NO_ASSIGNMENT
    IF l_error_code_tbl(i) = 'ENFORCED_NO_ASSIGNMENT' THEN
      -- may use fnd_message.raise_error (automatically log the message)
      RAISE no_assigned_seq_info;
    END IF;
  END LOOP;
  --
  -- Bulk Update fun_seq_batch_gt
  --
  IF l_assign_id_tbl.COUNT > 0 THEN
    FORALL i IN l_assign_id_tbl.FIRST .. l_assign_id_tbl.LAST
      UPDATE fun_seq_batch_gt
         SET assignment_id  = l_assign_id_tbl(i),
             seq_version_id = l_seq_ver_id_tbl(i),
             status_code    = l_error_code_tbl(i)
       WHERE source_id      = l_je_header_id_tbl(i);
  END IF;
  --
  -- Debug Information
  --
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(
      FND_LOG.LEVEL_PROCEDURE,
     'fun.plsql.fun_seq_batch.populate_seq_info.end',
     'Populate_Seq_Info completes successfully.');
  END IF;
EXCEPTION
WHEN no_assigned_seq_info THEN
  --
  -- Logging
  --
  IF fnd_log.level_error >= fnd_log.g_current_runtime_level THEN
    -- Retrieve FUN_SEQ_NO_ACTIVE_ASSGN_FOUND from the message stack
    -- and clear the message from the message stack.
    -- See fun_seq.get_assigned_seq_info.
    -- This is necessary to use the shorter version of the message
    -- for concurrent program logs of posting program. Message text
    -- longer than 70 chars is not allowed in Pro*C code.
    -- The longer version is stored in the database via FND logging.
    fnd_log.string (
      log_level => fnd_log.level_error,
      module
        => 'fun.plsql.fun_seq_batch.populate_seq_info.exception',
      message
        => 'EXCEPTION: no_assigned_seq_info'  || ', ' ||
           fnd_message.get); -- Retrive mesg from the stack
  END IF;
  --
  -- Set the shorter version of the error message on the stack
  --
  fnd_message.set_name ('FUN','FUN_SEQ_NO_ACTIVE_ASSGN_SHORT');
  --
  -- Raise Exception
  --
  app_exception.raise_exception;
WHEN OTHERS THEN
  --
  -- Logging
  --
  IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(
      log_level => fnd_log.level_exception,
      module    => 'fun.plsql.fun_seq_batch.populate_seq_info',
      message   => 'SQLERRM: '          || SQLERRM);
  END IF;
  --
  -- Raise Exception
  --
  app_exception.raise_exception;
END Populate_Seq_Info;

--
-- PROCEDURE NAME:
--   Populate_Numbers  *** For GL Posting Program ***
-- DESCRIPTION
--   Return the system date at the end of this API
--   GL Posting Program update posting date of
--   selected batches with the system date.
--
FUNCTION Populate_Numbers RETURN DATE IS

  l_source_id_tbl      num_tbl_type;
  l_seq_ver_id_tbl     seq_ver_id_tbl_type;
  l_assign_id_tbl      assign_id_tbl_type;
  l_seq_value_tbl      seq_value_tbl_type;
  l_seq_date_tbl       date_tbl_type;
BEGIN
  --
  -- Debug Information
  --
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(
      FND_LOG.LEVEL_PROCEDURE,
      'fun.plsql.fun_seq_batch.populate_numbers.begin',
      'Beginning of populate_numbers');
  END IF;
  --
  --  Bulk Collect Sequence Info. for GL Journal Entries
  --  Sequence version / sequence number / posting date
  --  must correlate.
  --
  -- Sorting Option can be GL Date or none for Posting
  IF g_sort_option_code ='GL_DATE' THEN
    SELECT bg.source_id,
         bg.seq_version_id,
         bg.assignment_id
    BULK COLLECT
    INTO l_source_id_tbl,
         l_seq_ver_id_tbl,
         l_assign_id_tbl
    FROM fun_seq_batch_gt bg,
    gl_je_headers jh
   WHERE jh.je_header_id =bg.source_id and
   bg.status_code = 'SEQ_VER_FOUND'
   ORDER BY bg.seq_version_id,
            bg.assignment_id,
            jh.default_effective_date;
  ELSE
    SELECT source_id,
         seq_version_id,
         assignment_id
    BULK COLLECT
    INTO l_source_id_tbl,
         l_seq_ver_id_tbl,
         l_assign_id_tbl
    FROM fun_seq_batch_gt
   WHERE status_code = 'SEQ_VER_FOUND'
   ORDER BY seq_version_id,
            assignment_id;
  END IF;

  --
  -- Call Generate_Bulk_Numbers
  --
  Generate_Bulk_Numbers(
    p_request_id        => -1,
    p_seq_ver_id_tbl    => l_seq_ver_id_tbl,
    p_assign_id_tbl     => l_assign_id_tbl,
    x_seq_value_tbl     => l_seq_value_tbl,
    x_seq_date_tbl      => l_seq_date_tbl); -- Not used here
  --
  -- Bulk Update fun_seq_batch_gt
  --
  IF l_source_id_tbl.COUNT > 0 THEN
    FORALL i IN l_source_id_tbl.FIRST..l_source_id_tbl.LAST
      UPDATE fun_seq_batch_gt gt
         SET gt.seq_version_id = l_seq_ver_id_tbl(i),
             gt.assignment_id  = l_assign_id_tbl(i),
             gt.seq_value = l_seq_value_tbl(i)
       WHERE gt.source_id = l_source_id_tbl(i);
  END IF;
  --
  -- Debug Information
  --
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(
      FND_LOG.LEVEL_PROCEDURE,
      'fun.plsql.fun_seq_batch.populate_numbers.end',
      'Populate_numbers completes successfully.');
  END IF;
  --
  -- Return posting date
  --
  RETURN SYSDATE;
EXCEPTION
WHEN OTHERS THEN
  --
  -- Logging
  --
  IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
    fnd_log.string (
      log_level => fnd_log.level_exception,
      module    => 'fun.plsql.fun_seq_batch.populate_numbers.exception',
      message   => 'SQLERRM: '          || SQLERRM);
  END IF;
  --
  -- Raise Exception
  --
  app_exception.raise_exception;
END Populate_Numbers;

--
-- *** Do not change the order of parameters of this procedure ***
-- *** Do not change the name of the parameters ***
--
PROCEDURE Release_Lock (
           errbuf         OUT NOCOPY VARCHAR2,  -- Required by Conc Manager
           retcode        OUT NOCOPY NUMBER,    -- Required by Conc Manager
           p_request_id   IN  NUMBER) IS

  l_module   CONSTANT VARCHAR2(100) DEFAULT g_module || '.' || 'release_lock';
BEGIN
  --
  -- Parameters passed from Concurrent Manager
  --
  fnd_file.put_line(fnd_file.log, 'p_request_id: ' ||
                                   NVL(TO_CHAR(p_request_id),'NULL'));
  --
  -- Debug Information
  --
  fnd_file.put_line(fnd_file.log, 'Starting Release_Lock... ');
  --
  -- If p_request_id is null, delete all complete requests from
  -- fun_seq_requests
  --
  delete_seq_requests(p_request_id => p_request_id);
  --
  -- Populate Return Values 'SUCCESS'
  --
  retcode := 0;
  --
  -- Debug Information
  --
  fnd_file.put_line(fnd_file.log, 'Release_Lock completes successfully.');
EXCEPTION
WHEN OTHERS THEN
  --
  -- Logging
  --
  IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(
      log_level => fnd_log.level_exception,
      module    => l_module,
      message   => 'p_request_id: ' || p_request_id || ', ' ||
                   'SQLERRM: ' || SQLERRM);
  END IF;
  --
  -- Concurrent Program Standard
  --
  errbuf  := 'p_request_id: ' || p_request_id || ', ' || 'SQLERRM: ' || SQLERRM;
  retcode := 2;
END Release_Lock;
------------------------------------------------------------------------------
-- Supporting Procedures.  Do not call them without consulting with SSMOA team
------------------------------------------------------------------------------
PROCEDURE Populate_Seq_Requests (
  p_request_id      IN NUMBER,
  p_seq_context_id  IN NUMBER) IS

  l_module  CONSTANT VARCHAR2(100) DEFAULT
                        g_module || '.' || 'populate_seq_requests';
BEGIN
  --
  -- Populate Sequencing Context in Fun_Seq_Requests
  --
  Populate_Seq_Context (
    p_request_id     => p_request_id,
    p_seq_context_id => p_seq_context_id);

  --
  -- Populate Sequence Headers in Fun_Seq_Requests
  --
  Populate_Seq_Headers (
    p_request_id     => p_request_id,
    p_Seq_Context_Id => p_seq_context_id);

EXCEPTION
WHEN OTHERS THEN
  --
  -- Logging
  --
  IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(
      log_level => fnd_log.level_exception,
      module    => l_module,
      message   => 'p_request_id: '     || p_request_id     || ', ' ||
                   'p_seq_context_id: ' || p_seq_context_id || ', ' ||
                   'SQLERRM: '          || SQLERRM);
  END IF;
  --
  -- Exception
  --
  app_exception.raise_exception;
END Populate_Seq_Requests;

PROCEDURE Populate_Seq_Context (
  p_request_id     IN NUMBER,
  p_seq_context_id IN NUMBER) IS

  l_user_id   NUMBER;
  l_login_id  NUMBER;
  l_module    CONSTANT VARCHAR2(100) DEFAULT
                          g_module || '.' || 'populate_seq_context';
BEGIN
  l_user_id  := fnd_global.user_id;
  l_login_id := fnd_global.login_id;

  INSERT INTO fun_seq_requests (
     request_id,
     source_type,
     source_id,
     last_update_date,
     last_updated_by,
     creation_date,
     created_by,
     last_update_login)
  VALUES (
     p_request_id,
     'C',
     p_seq_context_id,
     sysdate,
     l_user_id,
     sysdate,
     l_user_id,
     l_login_id);

EXCEPTION
WHEN OTHERS THEN
  --
  -- Logging
  --
  IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(
      log_level => fnd_log.level_exception,
      module    => l_module,
      message   => 'p_request_id: '     || p_request_id     || ', ' ||
                   'p_seq_context_id: ' || p_seq_context_id || ', ' ||
                   'SQLERRM: '          || SQLERRM);
  END IF;
  --
  -- Raise Exception
  --
  app_exception.raise_exception;
END Populate_Seq_Context;

PROCEDURE Populate_Seq_Headers (
  p_request_id      IN NUMBER,
  p_seq_context_id  IN NUMBER) IS

  l_seq_headers num_tbl_type;
  l_user_id     NUMBER;
  l_login_id    NUMBER;

  l_module      CONSTANT VARCHAR2(100) DEFAULT
                           g_module || '.' || 'populate_seq_headers';
BEGIN
  l_user_id  := fnd_global.user_id;
  l_login_id := fnd_global.login_id;

  SELECT sa.seq_header_id
    BULK COLLECT
    INTO l_seq_headers
    FROM fun_seq_assignments sa
   WHERE sa.seq_context_id = p_seq_context_id
     AND sa.use_status_code IN ('NEW','USED');

  IF l_seq_headers.COUNT > 0 THEN
    FORALL i IN l_seq_headers.FIRST .. l_seq_headers.LAST
      INSERT INTO fun_seq_requests(
        request_id,
        source_type,
        source_id,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        last_update_login)
      VALUES (
        p_request_id,
        'S',
        l_seq_headers(i),
        sysdate,
        l_user_id,
        sysdate,
        l_user_id,
        l_login_id);
  END IF;
EXCEPTION
WHEN OTHERS THEN
  --
  -- Logging
  --
  IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(
      log_level => fnd_log.level_exception,
      module    => l_module,
      message   => 'p_request_id: '     || p_request_id     || ', ' ||
                   'p_seq_context_id: ' || p_seq_context_id || ', ' ||
                   'SQLERRM: '          || SQLERRM);
  END IF;
  --
  -- Raise Exception
  --
  app_exception.raise_exception;
END Populate_Seq_Headers;

PROCEDURE Delete_Seq_Requests (
   p_request_id  IN NUMBER) IS

  l_phase            VARCHAR2(30);
  l_status           VARCHAR2(30);
  l_dev_phase        VARCHAR2(30);
  l_dev_status       VARCHAR2(30);
  l_message          VARCHAR2(240);

  l_req_id_tbl       num15_tbl_type;
  l_comp_req_id_tbl  num15_tbl_type; -- "Complete" Request ID
  l_result           BOOLEAN;

  l_module           CONSTANT VARCHAR2(100) DEFAULT
                                g_module || '.' || 'populate_seq_requests';

  l_phase_code VARCHAR2(2);
  more_rows EXCEPTION;
  pragma exception_init(more_rows, -1422);

BEGIN
  --
  -- Bulk collect request ids in fun_seq_requests
  --
  IF p_request_id IS NULL THEN
    SELECT request_id
      BULK COLLECT
      INTO l_req_id_tbl
      FROM fun_seq_requests;

  ELSE

	begin
	--
	-- check if this is the parent request and all child request are completed.
	--
	select  distinct phase_code into  l_phase_code from fnd_concurrent_requests
	where parent_request_id= p_request_id;
	-- all childs completed
	if l_phase_code ='C' then
	 delete from fun_seq_requests where request_id=p_request_id;
	-- childs may be pending or paused ..
	else
	 null;  -- do not release the lock
	end if;
	EXCEPTION
	-- this is not a parent request
	WHEN  NO_DATA_FOUND THEN
 	  delete from fun_seq_requests where request_id=p_request_id;
	-- all child are not completed yet
	WHEN more_rows THEN
	  null;
	end;

  END IF;

  IF l_req_id_tbl.COUNT > 0 THEN
    FOR i IN l_req_id_tbl.FIRST .. l_req_id_tbl.LAST LOOP
      --
      -- Check concurrent request status
      --
      l_result := fnd_concurrent.get_request_status(
                    request_id     => l_req_id_tbl(i),
                    appl_shortname => NULL,
                    program        => NULL,
                    phase          => l_phase,
                    status         => l_status,
                    dev_phase      => l_dev_phase,
                    dev_status     => l_dev_status,
                    message        => l_message);
       --
       -- Store complete concurrent request ids in a local variable
       -- If request id does not exists, l_dev_phase is null.
       --
       IF NVL(l_dev_phase,'COMPLETE') = 'COMPLETE' THEN
         l_comp_req_id_tbl(i) := l_req_id_tbl(i);
       END IF;
    END LOOP;
    --
    -- Bulk delete completed request Ids.
    --
    IF l_comp_req_id_tbl.COUNT > 0 THEN
      FORALL i IN INDICES OF l_comp_req_id_tbl
        DELETE
          FROM fun_seq_requests
         WHERE request_id = l_comp_req_id_tbl(i);
    END IF;
  END IF;

EXCEPTION
WHEN NO_DATA_FOUND THEN
  NULL;
WHEN OTHERS THEN
  --
  -- Logging
  --
  IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(
      log_level => fnd_log.level_exception,
      module    => l_module,
      message   => 'p_request_id: '     || p_request_id     || ', ' ||
                   'SQLERRM: '          || SQLERRM);
  END IF;
  --
  -- Raise Exception
  --
  app_exception.raise_exception;
END Delete_Seq_Requests;

PROCEDURE Populate_Acct_Seq_Prog_View(
            p_request_id        IN NUMBER) IS

  l_ae_header_id_tbl           ae_header_id_tbl_type;
  l_ledger_id_tbl              ledger_id_tbl_type;
  l_balance_type_code_tbl      balance_type_code_tbl_type;
  l_je_source_name_tbl         je_source_name_tbl_type;
  l_je_category_name_tbl       je_category_name_tbl_type;
  l_doc_category_code_tbl      doc_category_code_tbl_type;
  l_acct_event_type_code_tbl   acct_event_type_code_tbl_type;
  l_acct_entry_type_code_tbl   acct_entry_type_code_tbl_type;
  l_gl_date_tbl                date_tbl_type;

  l_seq_ver_id_tbl             seq_ver_id_tbl_type;
  l_assign_id_tbl              assign_id_tbl_type;
  l_out_ctrl_dt_tbl            date_tbl_type;
  l_req_assign_flag_tbl        req_assign_flag_tbl_type;
  l_error_code_tbl             error_code_tbl_type;

  l_ctrl_attr_rec              fun_seq.control_attribute_rec_type;
  l_ctrl_date_tbl              fun_seq.control_date_tbl_type
                                := fun_seq.control_date_tbl_type();

  --
  -- Values to be stored in XLA View
  --
  l_num_dummy_tbl              num_tbl_type; -- for application id
  l_xla_ae_header_id_tbl       ae_header_id_tbl_type;
  l_xla_seq_ver_id_tbl         seq_ver_id_tbl_type;
  l_xla_assign_id_tbl          assign_id_tbl_type;
  l_xla_seq_value_tbl          seq_value_tbl_type;
  l_xla_completion_date_tbl    date_tbl_type;

  l_sorted_ae_header_id_tbl    ae_header_id_tbl_type;
  l_sorted_seq_ver_id_tbl      seq_ver_id_tbl_type;
  l_sorted_assign_id_tbl       assign_id_tbl_type;
  l_sorted_seq_value_tbl       seq_value_tbl_type;

  l_sorted_seq_date_tbl        date_tbl_type;

  l_dummy                      fun_seq_headers.gapless_flag%TYPE;
  l_sort_option_code           fun_seq_contexts.sort_option%TYPE;
  l_date_dummy_tbl             date_tbl_type; -- For Sorting Key

  no_assigned_seq_info         EXCEPTION;
  j                            BINARY_INTEGER DEFAULT 1;

  l_debug_ae_header_id         NUMBER;
BEGIN
  --
  -- Debug Information
  --
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(
        FND_LOG.LEVEL_PROCEDURE,
        'fun.plsql.fun_seq_batch.populate_acct_seq_prog_view.begin',
        'p_request_id => ' || p_request_id );
  END IF;

  --
  -- Bulk Collect Accounting Entry Information
  --
  SELECT  ae_header_id,
          ledger_id,
          balance_type_code,
          je_source_name,
          je_category_name,
          doc_category_code,
          application_id ||'.'|| accounting_event_type_code,
          accounting_entry_type_code,
          gl_date
     BULK COLLECT INTO
          l_ae_header_id_tbl,
          l_ledger_id_tbl,
          l_balance_type_code_tbl,
          l_je_source_name_tbl,
          l_je_category_name_tbl,
          l_doc_category_code_tbl,
          l_acct_event_type_code_tbl,
          l_acct_entry_type_code_tbl,
          l_gl_date_tbl
     FROM XLA_ACCT_PROG_SEQ_V
    WHERE completion_acct_seq_assign_id IS NULL
      AND completion_acct_seq_version_id IS NULL
      AND completion_acct_seq_value IS NULL;

  --
  --  For Accounting Program, Sequencing Control Date Type is
  --  always "GL_DATE".  Setting the type outside the LOOP to
  --  improve performance.
  --
  l_ctrl_date_tbl.EXTEND(1);
  l_ctrl_date_tbl(1).date_type     := 'GL_DATE';
  --
  -- Retrieve Sequence Information
  --
  IF l_ae_header_id_tbl.COUNT > 0 THEN
    FOR i IN l_ae_header_id_tbl.FIRST .. l_ae_header_id_tbl.LAST LOOP
      l_debug_ae_header_id := l_ae_header_id_tbl(i);
      --
      -- Prepare parameters to retrieve Sequence information
      --
      l_ctrl_date_tbl(1).date_value    := l_gl_date_tbl(i);
      l_ctrl_attr_rec.balance_type     := l_balance_type_code_tbl(i);
      l_ctrl_attr_rec.journal_source   := l_je_source_name_tbl(i);
      l_ctrl_attr_rec.journal_category := l_je_category_name_tbl(i);
      l_ctrl_attr_rec.document_category
                                       := l_doc_category_code_tbl(i);
      l_ctrl_attr_rec.accounting_event_type
                                       := l_acct_event_type_code_tbl(i);
      l_ctrl_attr_rec.accounting_entry_type
                                       := l_acct_entry_type_code_tbl(i);

      --
      -- Debug Information
      --
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(
           FND_LOG.LEVEL_PROCEDURE,
          'fun.plsql.fun_seq_batch.populate_acct_seq_prog_view.config',
          'Before calling fun_seq.get_assigned_sequence_info... '
          ||', '||
          'l_debug_ae_header_id: '
              || l_debug_ae_header_id                  ||', '||
          'l_ctrl_date_tbl(1).date_value: '
              || l_ctrl_date_tbl(1).date_value         ||', '||
          'l_ctrl_attr_rec.balance_type: '
              || l_ctrl_attr_rec.balance_type          ||', '||
          'l_ctrl_attr_rec.journal_source: '
              || l_ctrl_attr_rec.journal_source        ||', '||
          'l_ctrl_attr_rec.journal_category: '
              || l_ctrl_attr_rec.journal_category      ||', '||
          'l_ctrl_attr_rec.document_category: '
              || l_ctrl_attr_rec.document_category     ||', '||
          'l_ctrl_attr_rec.accounting_event_type: '
              || l_ctrl_attr_rec.accounting_event_type ||', '||
          'l_ctrl_attr_rec.accounting_entry_type: '
              || l_ctrl_attr_rec.accounting_entry_type
          );
      END IF;
      --
      -- Get Assignment and Version
      --
      fun_seq.get_assigned_sequence_info(
        p_context_type             => 'LEDGER_AND_CURRENCY',
        p_context_value            => l_ledger_id_tbl(i),
        p_application_Id           => 602,
        p_table_name               => 'XLA_AE_HEADERS',
        p_event_code               => 'COMPLETION',
        p_control_attribute_rec    => l_ctrl_attr_rec,
        p_control_date_tbl         => l_ctrl_date_tbl,
        p_request_id               => -1,  -- Use Cache
        p_suppress_error           => 'Y',
        x_sequence_type            => l_dummy,
        x_seq_version_id           => l_seq_ver_id_tbl(i),
        x_assignment_id            => l_assign_id_tbl(i),
        x_control_date_value       => l_out_ctrl_dt_tbl(i),
        x_req_assign_flag          => l_req_assign_flag_tbl(i),
        x_sort_option_code         => l_sort_option_code,
        x_error_code               => l_error_code_tbl(i));
      --
      -- Debug Information
      --
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(
           FND_LOG.LEVEL_PROCEDURE,
          'fun.plsql.fun_seq_batch.populate_acct_seq_prog_view.config',
          'After calling fun_seq.get_assigned_sequence_info... '
          ||', '||
          'l_seq_ver_id_tbl(i): ' || l_seq_ver_id_tbl(i) ||', '||
          'l_assign_id_tbl(i): '  || l_assign_id_tbl(i)  ||', '||
          'l_out_ctrl_dt_tbl(i): '|| l_out_ctrl_dt_tbl(i)||', '||
          'l_req_assign_flag_tbl(i): '
                      || l_req_assign_flag_tbl(i)        ||', '||
          'l_error_code_tbl(i): ' || l_error_code_tbl(i)
          );
      END IF;

      --
      -- Raise Exception for Require Assignment Violation
      --
      IF l_error_code_tbl(i) = 'ENFORCED_NO_ASSIGNMENT' THEN
        RAISE no_assigned_seq_info;
      END IF;

      --
      -- Prepare parameters to generate sequence numbers in batch
      --
      IF l_assign_id_tbl(i) IS NOT NULL THEN
        l_num_dummy_tbl(j) := NULL;
        l_xla_ae_header_id_tbl(j)
                        := l_ae_header_id_tbl(i);
        l_xla_assign_id_tbl(j)
                        := l_assign_id_tbl(i);
        l_xla_seq_ver_id_tbl(j)
                        := l_seq_ver_id_tbl(i);
        j := j + 1;
      END IF;
    END LOOP;
  END IF;

  --
  -- If there exists no valid assignment, skip the following routine.
  --
    IF l_xla_ae_header_id_tbl.COUNT > 0 THEN
    --
    -- Sort Accounting Entries by Sequence Version ID (Avoid Deadlock)
    -- Sorting Option at Accounting event can be GL Date or none.
    --
    IF l_sort_option_code = 'GL_DATE' THEN
      l_date_dummy_tbl := l_gl_date_tbl;
    END IF;

    Sort_Acct_Entries (
      p_calling_program     => 'ACCOUNTING',
      p_application_id_tbl  =>  l_num_dummy_tbl,
      p_ae_header_id_tbl    =>  l_xla_ae_header_id_tbl,
      p_assign_id_tbl       =>  l_xla_assign_id_tbl,
      p_seq_ver_id_tbl      =>  l_xla_seq_ver_id_tbl,
      p_sorting_key_tbl     =>  l_date_dummy_tbl,
      x_application_id_tbl  =>  l_num_dummy_tbl,
      x_ae_header_id_tbl    =>  l_sorted_ae_header_id_tbl,
      x_assign_id_tbl       =>  l_sorted_assign_id_tbl,
      x_seq_ver_id_tbl      =>  l_sorted_seq_ver_id_tbl);
    --
    -- Generate Numbers in Bulk
    --
    IF l_sorted_ae_header_id_tbl.COUNT > 0 THEN
      generate_bulk_numbers(
        p_request_id        => NVL(p_request_id,-99), -- Use cache
        p_seq_ver_id_tbl    => l_sorted_seq_ver_id_tbl,
        p_assign_id_tbl     => l_sorted_assign_id_tbl,
        x_seq_value_tbl     => l_sorted_seq_value_tbl,
        x_seq_date_tbl      => l_sorted_seq_date_tbl);
    END IF;
    --
    --  Update XLA View in Bulk
    --
    IF l_sorted_assign_id_tbl.COUNT > 0 THEN
      FOR i IN l_sorted_assign_id_tbl.FIRST .. l_sorted_assign_id_tbl.LAST LOOP
        UPDATE xla_acct_prog_seq_v
           SET completion_acct_seq_assign_id =  l_sorted_assign_id_tbl(i),
               completion_acct_seq_version_id = l_sorted_seq_ver_id_tbl(i),
               completion_acct_seq_value      = l_sorted_seq_value_tbl(i),
               completion_date                = l_sorted_seq_date_tbl(i)
         WHERE ae_header_id = l_sorted_ae_header_id_tbl(i);
       END LOOP;

    END IF;
  END IF; -- l_xla_ae_header_id_tbl.COUNT > 0

  --
  -- Debug Information
  --
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(
      FND_LOG.LEVEL_PROCEDURE,
     'fun.plsql.fun_seq_batchpopulate_acct_seq_prog_view.end',
     'p_request_id: ' || p_request_id );
  END IF;

EXCEPTION
WHEN no_assigned_seq_info THEN
  --
  -- Logging
  --
  IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(
      fnd_log.level_exception,
      'fun.plsql.fun_seq_batch.populate_acct_seq_prog_view',
      'p_request_id: '  || p_request_id ||', ' ||
      'ae_header_id: '  || l_debug_ae_header_id|| ', ' ||
      'SQLERRM: '       || SQLERRM);
  END IF;
  --
  -- Raise Exception
  --
  fnd_message.set_name  ('FUN','FUN_SEQ_NO_ACTIVE_ASSGN_FOUND');
  fnd_message.set_token ('SEQ_CONTEXT_NAME',
                          fun_seq.get_seq_context_name(null));
  app_exception.raise_exception;
WHEN OTHERS THEN
  --
  -- Logging
  --
  IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(
      fnd_log.level_exception,
      'fun.plsql.fun_seq_batch.populate_acct_seq_prog_view',
      'Unexpected exception in Populate_Acct_Seq_Prog_View' || ', ' ||
      'p_request_id: '  || p_request_id ||', ' ||
      'ae_header_id: '  || l_debug_ae_header_id|| ', ' ||
      'SQLERRM: '       || SQLERRM);
  END IF;
  app_exception.raise_exception;
END Populate_Acct_Seq_Prog_View;

--
-- Populate sequencing information in xla_seq_je_headers_gt.
-- XLA inserts 'Actual' journal entries into this table.
--
--
PROCEDURE Populate_Rep_Seq_Prog_Gt(
            p_request_id IN NUMBER) IS

  l_ae_header_id_tbl           ae_header_id_tbl_type;
  l_application_id_tbl         num_tbl_type;
  l_table_name_tbl             vc30_tbl_type;
  l_ledger_id_tbl              ledger_id_tbl_type;
  l_je_source_name_tbl         je_source_name_tbl_type;
  l_je_category_name_tbl       je_category_name_tbl_type;
  l_gl_date_tbl                date_tbl_type;
  l_reference_date_tbl         date_tbl_type;
  l_completion_date_tbl        date_tbl_type;  -- Completion /Posted Date

  l_ctrl_attr_rec              fun_seq.control_attribute_rec_type;
  l_ctrl_date_tbl              fun_seq.control_date_tbl_type
                                := fun_seq.control_date_tbl_type();

  --
  -- Values to be stored in the XLA Temporary Table
  --
  l_xla_application_id_tbl     num_tbl_type;
  l_xla_ae_header_id_tbl       ae_header_id_tbl_type;
  l_xla_seq_ver_id_tbl         seq_ver_id_tbl_type;
  l_xla_assign_id_tbl          assign_id_tbl_type;
  l_xla_seq_value_tbl          seq_value_tbl_type;
  l_xla_gl_date_tbl            date_tbl_type;
  l_xla_reference_date_tbl     date_tbl_type;
  l_xla_completion_date_tbl    date_tbl_type;

  l_seq_ver_id_tbl             seq_ver_id_tbl_type;
  l_assign_id_tbl              assign_id_tbl_type;
  l_out_ctrl_dt_tbl            date_tbl_type;
  l_req_assign_flag_tbl        req_assign_flag_tbl_type;
  l_sorting_key_tbl            date_tbl_type;
  l_error_code_tbl             error_code_tbl_type;

  l_sort_option_code           fun_seq_contexts.sort_option%TYPE;
  l_dummy                      fun_seq_headers.gapless_flag%TYPE;

  l_sorted_application_id_tbl  num_tbl_type;
  l_sorted_ae_header_id_tbl    ae_header_id_tbl_type;
  l_sorted_seq_ver_id_tbl      seq_ver_id_tbl_type;
  l_sorted_assign_id_tbl       assign_id_tbl_type;
  l_sorted_seq_value_tbl       seq_value_tbl_type;
  l_sorted_seq_date_tbl        date_tbl_type;
  l_dummy_date_tbl             date_tbl_type;

  no_assigned_seq_info         EXCEPTION;
  j                            BINARY_INTEGER DEFAULT 1;

  l_debug_ae_header_id         NUMBER;
  invalid_sort_option          EXCEPTION;
  l_context_name               VARCHAR2(200);
  l_context_type               VARCHAR2(50);
  l_application_id             NUMBER;
  l_context_value              NUMBER;
  l_table_name                 VARCHAR2(50);


BEGIN
  --
  -- Debug Information
  --
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(
        FND_LOG.LEVEL_PROCEDURE,
        'fun.plsql.fun_seq_batch.populate_rep_seq_prog_gt.begin',
        'p_request_id => ' || p_request_id );
  END IF;

  --
  -- Bulk Collect Accounting Entry Information
  --
  SELECT  ae_header_id,
          application_id,
          DECODE(application_id,602,'XLA_AE_HEADERS',
                                101,'GL_JE_HEADERS',
                                null),
          ledger_id,
          je_source_name,
          je_category_name,
          gl_date,
          reference_date,
          completion_posted_date
     BULK COLLECT INTO
          l_ae_header_id_tbl,
          l_application_id_tbl,
          l_table_name_tbl,
          l_ledger_id_tbl,
          l_je_source_name_tbl,
          l_je_category_name_tbl,
          l_gl_date_tbl,
          l_reference_date_tbl,
          l_completion_date_tbl
     FROM xla_seq_je_headers_gt
    WHERE sequence_assign_id IS NULL
      AND sequence_version_id IS NULL
      AND sequence_value IS NULL;

  --
  -- Retrieve Sequence Information
  --
  IF l_ae_header_id_tbl.COUNT > 0 THEN
    FOR i IN l_ae_header_id_tbl.FIRST .. l_ae_header_id_tbl.LAST LOOP
      --
      -- to be used in exception section
      --
      l_debug_ae_header_id := l_ae_header_id_tbl(i);
      l_context_type := 'LEDGER_AND_CURRENCY';
      l_application_id:= l_application_id_tbl(i);
      l_context_value:= l_ledger_id_tbl(i);
      l_table_name:=l_table_name_tbl(i);

      --
      -- Prepare parameters to retrieve Sequence information
      --

      --
      -- Completion / Posted Date is not used to retrived Sequencing
      -- information. It is just for sorting.
      --
      l_ctrl_date_tbl.EXTEND(3);
      l_ctrl_date_tbl(1).date_type     := 'GL_DATE';
      l_ctrl_date_tbl(1).date_value    := l_gl_date_tbl(i);
      l_ctrl_date_tbl(2).date_type     := 'REFERENCE_DATE';
      l_ctrl_date_tbl(2).date_value    := l_reference_date_tbl(i);
      --
      -- balance type is always 'Actual' for reporting sequencing
      --
      l_ctrl_attr_rec.balance_type     := 'A';
      l_ctrl_attr_rec.journal_source   := l_je_source_name_tbl(i);
      l_ctrl_attr_rec.journal_category := l_je_category_name_tbl(i);
      --
      -- Debug Information
      --
      IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(
           FND_LOG.LEVEL_EVENT,
          'fun.plsql.fun_seq_batch.populate_rep_seq_prog_gt.config',
          'Before calling fun_seq.get_assigned_sequence_info... '
          ||', '||
          'l_debug_ae_header_id: '
              || l_debug_ae_header_id                  ||', '||
          'l_ctrl_date_tbl(1).date_value: '
              || l_ctrl_date_tbl(1).date_value         ||', '||
          'l_ctrl_date_tbl(2).date_value: '
              || l_ctrl_date_tbl(2).date_value         ||', '||
          'l_ctrl_attr_rec.journal_source: '
              || l_ctrl_attr_rec.journal_source
          );
      END IF;

      --
      -- Get Assignment and Version
      --
      -- Sorting options of sequencing contexts are identical
      -- within the temporary table.
      --
      fun_seq.get_assigned_sequence_info(
        p_context_type             => 'LEDGER_AND_CURRENCY',
        p_context_value            => l_ledger_id_tbl(i),
        p_application_id           => l_application_id_tbl(i),
        p_table_name               => l_table_name_tbl(i),
        p_event_code               => 'PERIOD_CLOSE',
        p_control_attribute_rec    => l_ctrl_attr_rec,
        p_control_date_tbl         => l_ctrl_date_tbl,
        p_request_id               => -1,  -- Use Cache
        p_suppress_error           => 'Y',
        x_sequence_type            => l_dummy,
        x_seq_version_id           => l_seq_ver_id_tbl(i),
        x_assignment_id            => l_assign_id_tbl(i),
        x_control_date_value       => l_out_ctrl_dt_tbl(i),
        x_req_assign_flag          => l_req_assign_flag_tbl(i),
        x_sort_option_code         => l_sort_option_code,
        x_error_code               => l_error_code_tbl(i));

      --
      -- Debug Information
      --
      IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(
           FND_LOG.LEVEL_EVENT,
          'fun.plsql.fun_seq_batch.populate_rep_seq_prog_gt.config',
          'After calling fun_seq.get_assigned_sequence_info... '
          ||', '||
          'l_seq_ver_id_tbl(i): ' || l_seq_ver_id_tbl(i) ||', '||
          'l_assign_id_tbl(i): '  || l_assign_id_tbl(i)  ||', '||
          'l_out_ctrl_dt_tbl(i): '|| l_out_ctrl_dt_tbl(i)||', '||
          'l_req_assign_flag_tbl(i): '
                      || l_req_assign_flag_tbl(i)        ||', '||
          'l_error_code_tbl(i): ' || l_error_code_tbl(i)
          );
      END IF;

      --
      -- Raise Exception for Require Assignment Violation
      --
      IF l_error_code_tbl(i) = 'ENFORCED_NO_ASSIGNMENT' THEN
        RAISE no_assigned_seq_info;
      END IF;

      --
      -- Prepare parameters to generate sequence numbers in batch
      --
      IF l_assign_id_tbl(i) IS NOT NULL THEN
        l_xla_application_id_tbl(j)
                        := l_application_id_tbl(i);
        l_xla_ae_header_id_tbl(j)
                        := l_ae_header_id_tbl(i);
        l_xla_assign_id_tbl(j)
                        := l_assign_id_tbl(i);
        l_xla_seq_ver_id_tbl(j)
                        := l_seq_ver_id_tbl(i);
        l_xla_gl_date_tbl(j)
                        := l_gl_date_tbl(i);
        l_xla_reference_date_tbl(j)
                        := l_reference_date_tbl(i);
        l_xla_completion_date_tbl(j)
                        := l_completion_date_tbl(i);
        j := j + 1;
      END IF;
    END LOOP;
  END IF;

  --
  -- If there exists no valid assignment, skip the following routine.
  --
  IF l_xla_ae_header_id_tbl.COUNT > 0 THEN
    --
    -- Debug Information
    --
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(
        FND_LOG.LEVEL_STATEMENT,
        'fun.plsql.fun_seq_batch.populate_rep_seq_prog_gt.config',
        'Before calling Sort_Acct_Entires: Sort Option - ' ||
         l_sort_option_code);
    END IF;

    --
    -- Sort Accounting Entries by Sequence Version ID (Avoid Deadlock)
    --
    IF l_sort_option_code = 'GL_DATE' THEN
      l_sorting_key_tbl := l_xla_gl_date_tbl;
    ELSIF l_sort_option_code = 'REFERENCE_DATE' THEN
      l_sorting_key_tbl := l_xla_reference_date_tbl;
    ELSIF l_sort_option_code = 'COMPLETION_OR_POSTING_DATE' THEN
      l_sorting_key_tbl := l_xla_completion_date_tbl;
    ELSE
      RAISE invalid_sort_option;
    END IF;

    Sort_Acct_Entries (
      p_calling_program     => 'REPORTING',
      p_application_id_tbl  =>  l_xla_application_id_tbl,
      p_ae_header_id_tbl    =>  l_xla_ae_header_id_tbl,
      p_assign_id_tbl       =>  l_xla_assign_id_tbl,
      p_seq_ver_id_tbl      =>  l_xla_seq_ver_id_tbl,
      p_sorting_key_tbl     =>  l_sorting_key_tbl,
      x_application_id_tbl  =>  l_sorted_application_id_tbl,
      x_ae_header_id_tbl    =>  l_sorted_ae_header_id_tbl,
      x_assign_id_tbl       =>  l_sorted_assign_id_tbl,
      x_seq_ver_id_tbl      =>  l_sorted_seq_ver_id_tbl);

    --
    -- Debug Information
    --
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(
        FND_LOG.LEVEL_STATEMENT,
        'fun.plsql.fun_seq_batch.populate_rep_seq_prog_gt.config',
        'After calling Sort_Acct_Entires');
    END IF;

    --
    -- Generate Numbers in Bulk
    --
    IF l_sorted_ae_header_id_tbl.COUNT > 0 THEN
      generate_bulk_numbers(
        p_request_id        => NVL(p_request_id,-99), -- Use cache
        p_seq_ver_id_tbl    => l_sorted_seq_ver_id_tbl,
        p_assign_id_tbl     => l_sorted_assign_id_tbl,
        x_seq_value_tbl     => l_sorted_seq_value_tbl,
        x_seq_date_tbl      => l_sorted_seq_date_tbl);
    END IF;
    --
    --  Update XLA View in Bulk
    --
    IF l_sorted_assign_id_tbl.COUNT > 0 THEN
      FORALL i IN l_sorted_assign_id_tbl.FIRST .. l_sorted_assign_id_tbl.LAST
        UPDATE xla_seq_je_headers_gt
           SET sequence_assign_id  = l_sorted_assign_id_tbl(i),
               sequence_version_id = l_sorted_seq_ver_id_tbl(i),
               sequence_value      = l_sorted_seq_value_tbl(i)
         WHERE application_id = l_sorted_application_id_tbl(i)
           AND ae_header_id   = l_sorted_ae_header_id_tbl(i);
    END IF;
  END IF; -- l_xla_ae_header_id_tbl.COUNT > 0

  --
  -- Debug Information
  --
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(
        FND_LOG.LEVEL_PROCEDURE,
        'fun.plsql.fun_seq_batch.populate_rep_seq_prog_gt.end',
        'p_request_id: ' || p_request_id );
  END IF;
EXCEPTION
WHEN no_assigned_seq_info THEN
  --
  -- Logging
  --
  IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(
      fnd_log.level_exception,
      'fun.plsql.fun_seq_batch.populate_rep_seq_prog_gt',
      'p_request_id: '  || p_request_id ||', ' ||
      'ae_header_id: '  || l_debug_ae_header_id|| ', ' ||
      'SQLERRM: '       || SQLERRM);
  END IF;

   SELECT name
   INTO l_context_name
   FROM fun_seq_contexts WHERE
   context_type=l_context_type AND
   context_value=l_context_value AND
   application_id=l_application_id AND
   table_name=l_table_name AND
   event_code='PERIOD_CLOSE';

  --
  -- Raise Exception
  --
  fnd_message.set_name  ('FUN','FUN_SEQ_NO_ACTIVE_ASSGN_FOUND');
  fnd_message.set_token ('SEQ_CONTEXT_NAME',l_context_name);

  app_exception.raise_exception;

WHEN invalid_sort_option THEN
  --
  -- Logging
  --
  IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(
      fnd_log.level_exception,
      'fun.plsql.fun_seq_batch.populate_rep_seq_prog_gt',
      'p_request_id: '     || p_request_id        || ', ' ||
      'ae_header_id: '     || l_debug_ae_header_id|| ', ' ||
      'sort_option_code: ' || l_sort_option_code  || ', ' ||
      'SQLERRM: '          || SQLERRM);
  END IF;
  --
  -- Raise Exception
  --
  app_exception.raise_exception;

WHEN OTHERS THEN
  --
  -- Logging
  --
  IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(
      fnd_log.level_exception,
      'fun.plsql.fun_seq_batch.populate_rep_seq_prog_gt',
      'Unexpected exception in populate_rep_seq_prog_gt' || ', ' ||
      'p_request_id: '  || p_request_id ||', ' ||
      'ae_header_id: '  || l_debug_ae_header_id|| ', ' ||
      'SQLERRM: '       || SQLERRM);
  END IF;

  app_exception.raise_exception;

END Populate_Rep_Seq_Prog_Gt;

PROCEDURE Sort_Acct_Entries (
  p_calling_program     IN         VARCHAR2,
  p_application_id_tbl  IN         num_tbl_type,
  p_ae_header_id_tbl    IN         ae_header_id_tbl_type,
  p_assign_id_tbl       IN         assign_id_tbl_type,
  p_seq_ver_id_tbl      IN         seq_ver_id_tbl_type,
  p_sorting_key_tbl     IN         date_tbl_type,
  x_application_id_tbl  OUT NOCOPY num_tbl_type,
  x_ae_header_id_tbl    OUT NOCOPY ae_header_id_tbl_type,
  x_assign_id_tbl       OUT NOCOPY assign_id_tbl_type,
  x_seq_ver_id_tbl      OUT NOCOPY seq_ver_id_tbl_type) IS

  l_temp_tab     fun_seq_bt_tbl_type;

BEGIN
  l_temp_tab := fun_seq_bt_tbl_type();
  --
  -- Debug Information
  --
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(
        FND_LOG.LEVEL_PROCEDURE,
        'fun.plsql.fun_seq_batch.Sort_Acct_Entries.begin',
        'p_ae_header_id_tbl.count => ' || p_ae_header_id_tbl.COUNT);
  END IF;
  --
  -- Populate Sequence Info in Table Type
  --
  IF p_ae_header_id_tbl.COUNT > 0 THEN
    --
    -- Populate Parameter Values to Table
    --
    IF p_calling_program = 'ACCOUNTING' THEN
     --
     -- bug#5434859 added IF clause
     --
     IF p_sorting_key_tbl.COUNT > 0 THEN
     -- bug# 5373090 - Italian requirement
      FOR i IN p_ae_header_id_tbl.FIRST .. p_ae_header_id_tbl.LAST LOOP
        l_temp_tab.EXTEND;
        l_temp_tab(i) :=
           fun_seq_bt_obj_type(
             NULL, -- Application Id for Reporting Sequencing
             p_ae_header_id_tbl(i),
             p_assign_id_tbl(i),
             p_seq_ver_id_tbl(i),
             fnd_date.date_to_canonical(p_sorting_key_tbl(i)));
      END LOOP;
     ELSE
      FOR i IN p_ae_header_id_tbl.FIRST .. p_ae_header_id_tbl.LAST LOOP
        l_temp_tab.EXTEND;
         l_temp_tab(i) :=
           fun_seq_bt_obj_type(
             NULL, -- Application Id for Reporting Sequencing
             p_ae_header_id_tbl(i),
             p_assign_id_tbl(i),
             p_seq_ver_id_tbl(i),
             null);
      END LOOP;
     END IF;

      --
      -- Debug Information
      --
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(
          FND_LOG.LEVEL_STATEMENT,
          'fun.plsql.fun_seq_batch.Sort_Acct_Entries.config',
          'Local temp table has been populated: ' || p_calling_program);
      END IF;

      --
      -- Sort Accounting Entries by Sequence Versions
      --
      SELECT sqtmp.source_id,
             sqtmp.assignment_id,
             sqtmp.seq_version_id
             -- Don't need sorting key for the Completion event
        BULK COLLECT
        INTO x_ae_header_id_tbl,
             x_assign_id_tbl,
             x_seq_ver_id_tbl
        FROM THE (SELECT CAST( l_temp_tab as fun_seq_bt_tbl_type)
                  FROM dual ) sqtmp
       ORDER BY
             sqtmp.seq_version_id,
             sqtmp.sorting_key;

    ELSIF p_calling_program = 'REPORTING' THEN
      --
      -- Populate Parameter Values to Table
      --
      FOR i IN p_ae_header_id_tbl.FIRST .. p_ae_header_id_tbl.LAST LOOP
        l_temp_tab.EXTEND;
        l_temp_tab(i) :=
           fun_seq_bt_obj_type(
             p_application_id_tbl(i),
             p_ae_header_id_tbl(i),
             p_assign_id_tbl(i),
             p_seq_ver_id_tbl(i),
             fnd_date.date_to_canonical(p_sorting_key_tbl(i)));
      END LOOP;

      --
      -- Debug Information
      --
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(
          FND_LOG.LEVEL_STATEMENT,
          'fun.plsql.fun_seq_batch.Sort_Acct_Entries.config',
          'Local temp table has been populated: ' || p_calling_program);
      END IF;

      --
      -- Sort Accounting Entries by Sequence Versions and Control Dates
      --
      -- Modified the code for Bug7692368, added period_num is order by
      --
      SELECT  res.application_id,
             res.source_id,
             res.assignment_id,
             res.seq_version_id
        BULK COLLECT
        INTO x_application_id_tbl,
             x_ae_header_id_tbl,
             x_assign_id_tbl,
             x_seq_ver_id_tbl
      FROM
      (SELECT
             sqtmp.application_id application_id ,
             sqtmp.source_id source_id,
             sqtmp.assignment_id assignment_id,
             sqtmp.seq_version_id seq_version_id,
             ps.period_num period_num,
             sqtmp.sorting_key sorting_key
        FROM THE (SELECT CAST( l_temp_tab as fun_seq_bt_tbl_type)
                    FROM dual ) sqtmp, gl_period_statuses ps, gl_je_headers h
        WHERE
             ps.period_name = h.period_name
        AND ps.ledger_id = h.ledger_id
        AND ps.application_id = 101
        AND h.je_header_id = sqtmp.source_id
        AND sqtmp.application_id = 101
        union
        SELECT sqtmp.application_id application_id ,
             sqtmp.source_id source_id,
             sqtmp.assignment_id assignment_id,
             sqtmp.seq_version_id seq_version_id,
             ps.period_num period_num,
             sqtmp.sorting_key sorting_key
        FROM THE (SELECT CAST( l_temp_tab as fun_seq_bt_tbl_type)
                    FROM dual ) sqtmp, gl_period_statuses ps, xla_ae_headers ah
        WHERE
             ps.period_name = ah.period_name
        AND ps.ledger_id = ah.ledger_id
        AND ps.application_id = 101
        AND ah.ae_header_id = sqtmp.source_id
	AND sqtmp.application_id = 602) res

        ORDER BY
             res.seq_version_id,
             res.sorting_key,
             res.period_num;

    END IF; -- p_calling_program = <ACCOUNTING/REPORTING>
  END IF;  -- p_ae_header_id_tbl.COUNT > 0

  --
  -- Debug Information
  --
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(
        FND_LOG.LEVEL_PROCEDURE,
        'fun.plsql.fun_seq_batch.Sort_Acct_Entries.end',
        'p_ae_header_id_tbl.count => ' || p_ae_header_id_tbl.COUNT);
  END IF;
EXCEPTION
WHEN OTHERS THEN
  --
  -- Logging
  --
  IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(
         log_level => fnd_log.level_exception,
         module    => 'fun.plsql.fun_seq_batch.Sort_Acct_Entries.Exception',
         message   => 'SQLERRM: '  || SQLERRM);
  END IF;
  app_exception.raise_exception;
END Sort_Acct_Entries;
END fun_seq_batch;

/
