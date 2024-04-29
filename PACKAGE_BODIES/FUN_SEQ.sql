--------------------------------------------------------
--  DDL for Package Body FUN_SEQ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FUN_SEQ" AS
/* $Header: funsqgnb.pls 120.36 2004/11/04 01:07:53 masada noship $ */
  --
  --
  --
  g_use_cache_flag BOOLEAN DEFAULT FALSE;
  --
  -- For Sequencing Context Cache
  --
  g_sc_cache_size           BINARY_INTEGER DEFAULT 0;
  g_context_info_tbl        context_info_tbl_type;
  g_context_ctrl_tbl        context_ctrl_tbl_type;

  --
  -- For Assignment Cache
  --
  g_as_cache_size           BINARY_INTEGER DEFAULT 0;
  g_assign_info_tbl         assignment_info_tbl_type;
  g_assign_seq_head_tbl     assign_seq_head_tbl_type;

  --
  -- For Exception Cache
  --
  g_exp_cache_size          BINARY_INTEGER DEFAULT 0;
  g_exp_info_tbl            exp_info_tbl_type;
  g_exp_seq_head_tbl        assign_seq_head_tbl_type;

-- PROCEDURE NAME:
--   get_sequence_number
-- DESCRIPTION:
--   Retrieve sequence information of assignments and generate
--   sequence numbers.
--   INPUT:
--    - p_context_type
--      Sequence Context Type.  Only 'LEDGER_AND_CURRENCY' is supported
--      for Accounting Sequencing.
--    - p_context_value
--      Sequence Context Value. Only Ledger ID is supported for
--      Accounting Sequencing.
--    - p_application_id
--      Application Id of your Sequence Entity.
--    - p_table_name
--      Table Name of your Sequence Entity.
--    - p_event_code
--      Sequence Event Code
--    - p_control_attribute_rec
--      Sequence Control Attribute PL/SQL Record consists of 10 control
--      attribute columns.
--      [Implementation Example]
--      p_control_attribute_rec.control_attribute1 := 'ACTUAL';
--      p_control_attribute_rec.control_attribute2 :=
--    - p_control_date_tbl
--      Sequence Control Date PL/SQL Table which consistes of
--      Date Type and Date Value.
--      [Implementation Example]
--        p_control_date_tbl.extend(2);
--        p_control_date_tbl(1).date_type  := 'GL_DATE';
--        p_control_date_tbl(1).date_value := sysdate;
--        p_control_date_tbl(2).date_type  := 'COMPLETION_DATE';
--        p_control_date_tbl(2).date_value := sysdate;
--    - p_suppress_error
--      Suppress Error Flag. If Suppress Error is turned on, the caller is
--      responsible for raising the exceptions. If not, the exception is
--      raised as soon as an error is found.
--   OUTPUT:
--    - x_seq_version_id
--      Sequence Version Id. To be stored in the base table(e.g.GL_JE_HEADERS).
--    - x_sequence_number
--      Sequence Number. To be stored in the base table.
--    - x_assignment_id
--      Assignment Id. To be stored in the base table.
--    - x_error_code
--      - SUCCESS
--        1. No active Assignment Context is found, or
--        2. No Assignment is found and Require Assignment Flag is turned off
--
PROCEDURE Get_Sequence_Number(
            p_context_type          IN  VARCHAR2,
            p_context_value         IN  VARCHAR2,
            p_application_id        IN  NUMBER,
            p_table_name            IN  VARCHAR2,
            p_event_code            IN  VARCHAR2,
            p_control_attribute_rec IN  control_attribute_rec_type,
            p_control_date_tbl      IN  control_date_tbl_type,
            p_suppress_error        IN  VARCHAR2,
            x_seq_version_id        OUT NOCOPY NUMBER,
            x_sequence_number       OUT NOCOPY NUMBER,
            x_assignment_id         OUT NOCOPY NUMBER,
            x_error_code            OUT NOCOPY VARCHAR2)
IS

BEGIN
  --
  -- Debug Information
  --
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(
        FND_LOG.LEVEL_PROCEDURE,
        'fun.plsql.fun_seq.get_sequence_number.begin',
        'p_context_type: '   || p_context_type    ||', '||
        'p_context_value: '  || p_context_value   ||', '||
        'p_application_id: ' || p_application_id  ||', '||
        'p_table_name: '     || p_table_name      ||', '||
        'p_event_code: '     || p_event_code      ||', '||
        'p_suppress_error: ' || p_suppress_error);
  END IF;

  --
  --  Check if Sequencing Context is Intercompany Batch or Not
  --
  IF p_context_type   = 'INTERCOMPANY_BATCH_SOURCE' AND
     p_context_value  = 'LOCAL'                     AND
     p_application_id = 435                         AND
     p_table_name     = 'FUN_TRX_BATCHES'           AND
     p_event_code     = 'CREATION'
  THEN
    --
    -- Issue autonmous commit after getting a number
    --
    get_sequence_number_commit (
      p_context_type           => p_context_type,
      p_context_value          => p_context_value,
      p_application_id         => p_application_id,
      p_table_name             => p_table_name,
      p_event_code             => p_event_code,
      p_control_attribute_rec  => p_control_attribute_rec,
      p_control_date_tbl       => p_control_date_tbl,
      p_suppress_error         => p_suppress_error,
      x_seq_version_id         => x_seq_version_id,
      x_sequence_number        => x_sequence_number,
      x_assignment_id          => x_assignment_id,
      x_error_code             => x_error_code);

  ELSE
  --
  -- Accounting Sequencing
  --
    get_sequence_number_no_commit (
      p_context_type           => p_context_type,
      p_context_value          => p_context_value,
      p_application_id         => p_application_id,
      p_table_name             => p_table_name,
      p_event_code             => p_event_code,
      p_control_attribute_rec  => p_control_attribute_rec,
      p_control_date_tbl       => p_control_date_tbl,
      p_suppress_error         => p_suppress_error,
      x_seq_version_id         => x_seq_version_id,
      x_sequence_number        => x_sequence_number,
      x_assignment_id          => x_assignment_id,
      x_error_code             => x_error_code);

   END IF;

  --
  -- Debug Information
  --
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(
        FND_LOG.LEVEL_PROCEDURE,
        'fun.plsql.fun_seq.get_sequence_number.end',
        'p_context_type: '   || p_context_type    ||', '||
        'p_context_value: '  || p_context_value   ||', '||
        'p_application_id: ' || p_application_id  ||', '||
        'p_table_name: '     || p_table_name      ||', '||
        'p_event_code: '     || p_event_code      ||', '||
        'p_suppress_error: ' || p_suppress_error);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  --
  -- Debug Information
  --
  IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(
      fnd_log.level_exception,
      'fun.plsql.fun_seq.get_sequence_Number.exception',
        'p_context_type: '   || p_context_type    ||', '||
        'p_context_value: '  || p_context_value   ||', '||
        'p_application_id: ' || p_application_id  ||', '||
        'p_table_name: '     || p_table_name      ||', '||
        'p_event_code: '     || p_event_code      ||', '||
        'p_suppress_error: ' || p_suppress_error  ||', '||
        'SQLERRM: '          || SQLERRM);
  END IF;

  --
  -- Raise Exception
  --
  app_exception.raise_exception;
END Get_Sequence_Number;

--
-- Procedure Name: get_assigned_sequence_info
-- Description:
--   *** Consult with SSMOA team before calling this API ***
--   Steps
--   1. Get_Assigned_Context_Info
--   2. Get_Assigned_Sequence_Header
--   3. Get_Seq_Version
--   Returns the following assigned sequence information:
--   - Sequence Type
--   - Sequence Version Id
--   - Sequence Assignment ID
--   - Sequence Control Date Value
--   - Require Assignment Flag
--   - Error Code
--  The meanings of Error Codes are as follows:
--   - NO_ASSIGN_CONTEXT
--     Validation succeeds. No Assignment Context is found.
--     No sequence number is generated.
--   - NO_ASSIGNMENT
--     Validation succeeds. No Assignment is found.
--     No sequence number is generated. Require Assignment Flag is turned off.
--     Therefore, no error is raised.
--   - ENFORCED_NO_ASSIGNMENT
--     Validation fails. No Assignment is found while
--     Require Assignment flag is turned on.
--
PROCEDURE Get_Assigned_Sequence_Info(
             p_context_type          IN  VARCHAR2,
             p_context_value         IN  VARCHAR2,
             p_application_id        IN  NUMBER,
             p_table_name            IN  VARCHAR2,
             p_event_code            IN  VARCHAR2,
             p_control_attribute_rec IN  control_attribute_rec_type,
             p_control_date_tbl      IN  control_date_tbl_type,
             p_request_id            IN  NUMBER,
             p_suppress_error 	     IN  VARCHAR2,
             x_sequence_type         OUT NOCOPY VARCHAR2,
             x_seq_version_id        OUT NOCOPY NUMBER,
             x_assignment_id         OUT NOCOPY NUMBER,
             x_control_date_value    OUT NOCOPY DATE,
             x_req_assign_flag       OUT NOCOPY VARCHAR2,
             x_sort_option_code      OUT NOCOPY VARCHAR2,
             x_error_code            OUT NOCOPY VARCHAR2)
IS

   l_seq_context_id         fun_seq_contexts.seq_context_id%TYPE;
   l_control_date_type      fun_seq_contexts.date_type%TYPE;
   l_req_assign_flag        fun_seq_contexts.require_assign_flag%TYPE;
   l_sort_option_code       fun_seq_contexts.sort_option%TYPE;
   l_sequence_type          fun_seq_headers.gapless_flag%TYPE;
   l_error_code             VARCHAR2(30);

   l_control_date_value     DATE;
   l_seq_header_id          fun_seq_versions.seq_version_id%TYPE;
   l_seq_version_id         fun_seq_versions.seq_version_id%TYPE;
   l_assignment_id          fun_seq_assignments.assignment_id%TYPE;

   no_assignment_found      EXCEPTION;
   no_seq_version_found     EXCEPTION;

BEGIN
  --
  -- Debug Information
  --
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(
        FND_LOG.LEVEL_PROCEDURE,
        'fun.plsql.fun_seq.get_assigned_sequence_info.begin',
        'p_context_type: '   || p_context_type    ||', '||
        'p_context_value: '  || p_context_value   ||', '||
        'p_application_id: ' || p_application_id  ||', '||
        'p_table_name: '     || p_table_name      ||', '||
        'p_event_code: '     || p_event_code      ||', '||
        'p_request_id: '     || p_request_id      ||', '||
        'p_suppress_error: ' || p_suppress_error);
  END IF;
  --
  -- Get Sequencing Context Information.
  -- Return the following information:
  --  - Sequencing Context ID
  --  - Control Date Type
  --  - Require Assignment Flag
  get_assign_context_info(
    p_context_type           => p_context_type,
    p_context_value          => p_context_value,
    p_application_id         => p_application_id,
    p_table_name             => p_table_name,
    p_event_code             => p_event_code,
    p_request_id             => p_request_id,
    x_seq_context_id         => l_seq_context_id,     -- OUT
    x_control_date_type      => l_control_date_type,  -- OUT
    x_req_assign_flag        => l_req_assign_flag,   -- OUT
    x_sort_option_code       => l_sort_option_code);  -- OUT

  --
  -- Success:
  -- There is no Active Assignment Context.
  --
  IF l_seq_context_id IS NULL THEN
    x_error_code := 'NO_ASSIGN_CONTEXT';
  --
  -- If an Active Assignment Context Exists
  -- 1. Get a Control Date Value
  -- 2. Get an Assigned Sequence
  --
  ELSE
    --
    -- Get a Control Date Value
    --
    l_control_date_value := get_control_date_value(
                              l_control_date_type,
                              p_control_date_tbl);
    --
    -- Get an Assigned Sequence Header
    --
    --fun_seq_utils.log_procedure(
    --  p_module        => l_module || ' in progress',
    --  p_message_text  => 'Beginning of get_assigned_sequence_header');
    --
    IF p_application_id = 435 AND p_table_name = 'FUN_TRX_BATCHES' THEN
      get_ic_assigned_seq_header(
        p_seq_context_id        =>  l_seq_context_id,
        p_control_date_value    =>  l_control_date_value,
        p_request_id            =>  p_request_id,
        x_assignment_id         =>  l_assignment_id,       -- OUT
        x_sequence_type         =>  l_sequence_type,       -- OUT
        x_seq_header_id         =>  l_seq_header_id);      -- OUT
    ELSE
      get_assigned_sequence_header(
        p_seq_context_id        =>  l_seq_context_id,
        p_control_attribute_rec =>  p_control_attribute_rec,
        p_control_date_value    =>  l_control_date_value,
        p_request_id            =>  p_request_id,
        x_assignment_id         =>  l_assignment_id,       -- OUT
        x_sequence_type         =>  l_sequence_type,       -- OUT
        x_seq_header_id         =>  l_seq_header_id);      -- OUT
    END IF;
    --
    -- Get Sequence Version Info if Sequence Assignment is found.
    --
    IF l_assignment_id IS NOT NULL THEN
      IF l_seq_header_id IS NULL THEN
         x_error_code := 'DO_NOT_SEQUENCE';
      ELSE
        --
        -- Get a Sequence Version
        --
        get_seq_version (
          p_sequence_type      => l_sequence_type,
          p_seq_header_id      => l_seq_header_id,
          p_control_date_value => l_control_date_value,
          p_request_id         => p_request_id,
          x_seq_version_id     => l_seq_version_id);      -- OUT
        --
        -- Success:
        -- Sequence Version is found.
        x_error_code := 'SEQ_VER_FOUND';
      END IF;
    --
    -- Error if Require Assignment Flag is YES:
    -- Sequence Assignment Id is not found while an Active Assignment Context
    -- exists
    -- Success if Require Assignment Flag is NO:
    --
    ELSE
      IF l_req_assign_flag = 'Y' THEN
        RAISE no_assignment_found;
      ELSE
        x_error_code :=   'NO_ASSIGNMENT';
      END IF;
    END IF;
  END IF;

  x_sequence_type      := l_sequence_type;
  x_assignment_id      := l_assignment_id;
  x_control_date_value := l_control_date_value;
  x_req_assign_flag    := l_req_assign_flag;
  x_sort_option_code   := l_sort_option_code;
  --
  -- Return Null Sequence Version ID for "Do Not Sequence".
  --
  x_seq_version_id     := l_seq_version_id;
  --
  -- Debug Information
  --
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(
        FND_LOG.LEVEL_PROCEDURE,
        'fun.plsql.fun_seq.get_assigned_sequence_info.end',
        'x_sequence_type: '     || x_sequence_type || ', ' ||
        'x_assignment_id: '     || x_assignment_id || ', ' ||
        'x_control_date_value: '|| x_control_date_value ||', '||
        'x_req_assign_flag: '   || x_req_assign_flag);
  END IF;
EXCEPTION
   WHEN no_assignment_found THEN
     --
     -- Debug Information
     --
     IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(
         FND_LOG.LEVEL_EXCEPTION,
         'fun.plsql.fun_seq.get_assigned_sequence_info.no_assign',
         'No Assignment Found (Require Assignment = Y)' ||', '||
         'l_seq_context_id :' || l_seq_context_id);
     END IF;

     x_error_code := 'ENFORCED_NO_ASSIGNMENT';
     fnd_message.set_name ('FUN','FUN_SEQ_NO_ACTIVE_ASSGN_FOUND');
     fnd_message.set_token ('SEQ_CONTEXT_NAME',
                             get_seq_context_name(l_seq_context_id));
     IF p_suppress_error = 'N' THEN
        app_exception.raise_exception;
     END IF;
   WHEN OTHERS THEN
     IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
       fnd_log.string(
         fnd_log.level_exception,
         'fun.plsql.fun_seq.get_assigned_sequence_info.exception',
         'l_seq_context_id :' || l_seq_context_id ||', ' ||
         'SQLERRM: '         || SQLERRM);
     END IF;
     app_exception.raise_exception;
END Get_Assigned_Sequence_Info;

--
-- PROCEDURE NAME:
--   Generate_Sequence_Number
-- DESCRIPTION
--   *** Consult with SSMOA team before calling this API ***
--   1. Increment the current value by 1.
--   2. Return the new current value.
--   The Status of the Version is updated
--   in Get_Assigned_Sequence_Info.
--
PROCEDURE Generate_Sequence_Number(
            p_assignment_id    IN  NUMBER,
            p_seq_version_id   IN  NUMBER,
            p_sequence_type    IN  VARCHAR2,
            p_request_id       IN  NUMBER,
            x_sequence_number  OUT NOCOPY NUMBER,
            x_sequenced_date   OUT NOCOPY DATE,
            x_error_code       OUT NOCOPY VARCHAR2)
IS
   l_assignment_id   fun_seq_assignments.assignment_id%TYPE;
   l_seq_version_id  fun_seq_versions.seq_version_id%TYPE;
   invalid_seq_type  EXCEPTION;
   l_sql_stmt        VARCHAR2(2000);
   l_debug_loc       CONSTANT VARCHAR2(100) DEFAULT 'generate_sequence_number';
BEGIN
  l_assignment_id  := p_assignment_id;
  l_seq_version_id := p_seq_version_id;
  --
  -- Check if Sequence Type is Gapless
  --
  IF (p_sequence_type = 'G') THEN
    --
    -- Generate Sequence Number if "Do Not Sequence" policy is NOT on
    --
    IF l_seq_version_id IS NOT NULL THEN
      --
      -- If the Sequence Version is NOT used, the current_value is null.
      -- Use initial_value in this case.
      -- Sequence version is locked.
      --
      UPDATE fun_seq_versions
         SET current_value = NVL(current_value + 1,initial_value)
       WHERE seq_version_id= l_seq_version_Id
             RETURNING current_value, sysdate
                  INTO x_sequence_number, x_sequenced_date;
      --
      -- Update Status from "New" to "Used" if p_batch_flag = 'N'.
      --
      update_gapless_status(
          p_assignment_id  => l_assignment_id,
          p_seq_version_id => l_seq_version_id);

    END IF;
  ELSIF (p_sequence_type = 'D') THEN
    l_sql_stmt :=  'SELECT '
                || 'FUN_SEQ_S' || l_seq_version_id || '.nextval '
                || 'FROM dual';
    EXECUTE IMMEDIATE l_sql_stmt INTO x_sequence_number;
    --
    -- Update Status from "New" to "Used".
    --
    update_db_status(
        p_assignment_id  => l_assignment_id,
        p_seq_version_id => l_seq_version_id);
  ELSE
    RAISE invalid_seq_type;
  END IF;
  x_error_code := 'SUCCESS';
EXCEPTION
--
-- Invalid_Seq_Type is a critical programming error.
-- So, you cannot suppress this.
--
WHEN invalid_seq_type THEN
  IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(
       log_level => fnd_log.level_exception,
       module    => 'fun.plsql.fun_seq.generate_sequence_number',
       message   => 'Invalid Sequence Type: ' || ', ' ||
           'SQLERRM: ' || SQLERRM);
  END IF;
  app_exception.raise_exception;
WHEN OTHERS THEN
  IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(
       log_level => fnd_log.level_exception,
       module    => 'fun.plsql.fun_seq.generate_sequence_number',
       message   =>
           'SQLERRM: ' || SQLERRM);
  END IF;
  app_exception.raise_exception;
END Generate_Sequence_Number;

--
-- PROCEDURE NAME: reset
--  Reset sequence version information
--  !!Warning!!
--  Never call this procedure without consulting with SSAMOA team.
--
PROCEDURE Reset(
            p_seq_version_id   IN  NUMBER,
            p_sequence_number  IN  NUMBER)
IS
BEGIN
  --
  -- Rest Sequence Version
  --
  UPDATE fun_seq_versions sv
     SET sv.current_value  = p_sequence_number
   WHERE sv.seq_version_id = p_seq_version_id;
EXCEPTION
WHEN OTHERS THEN
  IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(
       log_level => fnd_log.level_exception,
       module    => 'fun.plsql.fun_seq.reset',
       message   =>
           'SQLERRM: ' || SQLERRM);
  END IF;
  app_exception.raise_exception;
END Reset;

--
-- Retrieve an Active Sequence Assignment Context
-- Note:
-- Called from Get_Assigned_Sequence_Info
-- Product team should not call this procedure directly.
-- Lock the Sequencing Context so that no other process
-- can change the setup until sequence number is generated
--
PROCEDURE get_assign_context_info (
            p_context_type       IN  VARCHAR2,
            p_context_value      IN  VARCHAR2,
            p_application_id     IN  NUMBER,
            p_table_name         IN  VARCHAR2,
            p_event_code         IN  VARCHAR2,
            p_request_id         IN  NUMBER,
            x_seq_context_id     OUT NOCOPY NUMBER,
            x_control_date_type  OUT NOCOPY VARCHAR2,
            x_req_assign_flag    OUT NOCOPY VARCHAR2,
            x_sort_option_code   OUT NOCOPY VARCHAR2) IS

  l_context_info_rec   context_info_rec_type;
  l_context_ctrl_rec   context_ctrl_rec_type;
BEGIN
  --
  -- Debug Information
  --
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(
        FND_LOG.LEVEL_PROCEDURE,
        'fun.plsql.fun_seq.get_assign_context_info.begin',
        'Beginning of get_assign_context_info');
  END IF;
  --
  -- Retrieve Sequenceing Context
  --
  IF g_use_cache_flag = FALSE THEN
    --
    -- Check if we can use cache for next procedure calls.
    --
    g_use_cache_flag := use_cache(
                          p_request_id     => p_request_id,
                          p_application_id => p_application_id,
                          p_table_name     => p_table_name,
                          p_event_code     => p_event_code);
    --
    -- For online transactions, a lock is issued.
    --
    SELECT sac.seq_context_id,
           sac.date_type,
           sac.require_assign_flag,
           sac.sort_option
      INTO x_seq_context_id,
           x_control_date_type,
           x_req_assign_flag,
           x_sort_option_code
      FROM fun_seq_contexts sac
     WHERE sac.application_id = p_application_id
       AND sac.table_name     = p_table_name
       AND sac.context_type   = p_context_type
       AND sac.context_value  = p_context_value
       AND sac.event_code     = p_event_code
       AND sac.obsolete_flag  = 'N'
       FOR UPDATE;
   ELSE
     l_context_info_rec.application_id := p_application_id;
     l_context_info_rec.table_name     := p_table_name;
     l_context_info_rec.context_type   := p_context_type;
     l_context_info_rec.context_value  := p_context_value;
     l_context_info_rec.event_code     := p_event_code;
     --
     -- Batch Mode or UI Display Only.  Use Cache.
     --
     get_cached_context_info (
            p_context_info_rec  => l_context_info_rec,
            x_context_ctrl_rec  => l_context_ctrl_rec);

     x_seq_context_id    := l_context_ctrl_rec.seq_context_id;
     x_control_date_type := l_context_ctrl_rec.date_type;
     x_req_assign_flag   := l_context_ctrl_rec.req_assign_flag;
     x_sort_option_code  := l_context_ctrl_rec.sort_option_code;
   END IF;
  --
  -- Debug Information
  --
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(
        FND_LOG.LEVEL_PROCEDURE,
        'fun.plsql.fun_seq.get_assign_context_info.end',
        'Get_assign_context_info completes successfully.' ||', ' ||
        'x_seq_context_id: ' || x_seq_context_id    || ', ' ||
        'x_control_date_type: ' || x_control_date_type || ', ' ||
        'x_req_assign_flag: '   || x_req_assign_flag   || ', ' ||
        'x_sort_option_code: '   || x_sort_option_code);
  END IF;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
     x_seq_context_id := NULL;
   WHEN OTHERS THEN
     IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
       fnd_log.string(
         log_level => fnd_log.level_exception,
         module    => 'fun.plsql.get_assign_context_info',
         message   =>
           'SQLERRM: ' || SQLERRM);
  END IF;
     FND_MESSAGE.SET_NAME('FND', 'SQL_PLSQL_ERROR');
     FND_MESSAGE.SET_TOKEN('ROUTINE', 'p_context_value: ' || p_context_value);
     FND_MESSAGE.SET_TOKEN('ERRNO', '100');
     FND_MESSAGE.SET_TOKEN('REASON', SQLERRM);
     FND_MESSAGE.RAISE_ERROR;
     app_exception.raise_exception;
END get_assign_context_info;


--
-- Get Sequence Number (without Autonmous Commit)
--
PROCEDURE Get_Sequence_Number_No_Commit(
            p_context_type          IN  VARCHAR2,
            p_context_value         IN  VARCHAR2,
            p_application_id        IN  NUMBER,
            p_table_name            IN  VARCHAR2,
            p_event_code            IN  VARCHAR2,
            p_control_attribute_rec IN  control_attribute_rec_type,
            p_control_date_tbl      IN  control_date_tbl_type,
            p_suppress_error        IN  VARCHAR2,
            x_seq_version_id        OUT NOCOPY NUMBER,
            x_sequence_number       OUT NOCOPY NUMBER,
            x_assignment_id         OUT NOCOPY NUMBER,
            x_error_code            OUT NOCOPY VARCHAR2) IS

  l_context_type           fun_seq_contexts.context_type%TYPE;
  l_context_value          fun_seq_contexts.context_value%TYPE;
  l_application_id         fun_seq_contexts.application_id%TYPE;
  l_table_name             fun_seq_contexts.table_name%TYPE;
  l_event_code             fun_seq_contexts.event_code%TYPE;
  l_control_attribute_rec  control_attribute_rec_type;
  l_control_date_tbl       control_date_tbl_type;
  l_batch_flag             VARCHAR2(1);
  l_suppress_error         VARCHAR2(1);
  l_sequence_type          fun_seq_headers.gapless_flag%TYPE;
  l_seq_version_id         fun_seq_versions.seq_version_id%TYPE;
  l_assignment_id          fun_seq_assignments.assignment_id%TYPE;
  l_control_date_value     DATE;
  l_req_assign_flag        fun_seq_contexts.require_assign_flag%TYPE;
  l_error_code_assign      VARCHAR2(30);
  l_error_code_seq         VARCHAR2(30);
  l_sequence_number        fun_seq_versions.initial_value%TYPE;
  l_sequenced_date         DATE;
  l_dummy                  VARCHAR2(30); -- For Sort Option

  l_debug_loc              VARCHAR2(100);

  no_assigned_seq_info     EXCEPTION;
  no_sequence_number       EXCEPTION;
  invalid_error_code       EXCEPTION;

BEGIN
  --
  -- Pass IN parameters to local variables
  --
  l_context_type          := p_context_type;
  l_context_value         := p_context_value;
  l_application_id        := p_application_id;
  l_table_name            := p_table_name;
  l_event_code            := p_event_code;
  l_control_attribute_rec := p_control_attribute_rec;
  l_control_date_tbl      := p_control_date_tbl;
  l_suppress_error        := NVL(p_suppress_error,'N');
  --
  -- Retrieve Assigned Sequence Information.
  -- If null request id is passed, pessimistic locks are imposed
  -- in each SELECT statement so that the user cannot change the setup
  -- between sub program steps. "NOWAIT" is not used here because
  -- the user will receive ORA-54 frequently when calling this API
  -- to generate sequence numbers.
  -- Note:
  --  From Online, Request Id is always null.
  --
  l_debug_loc := 'get_assigned_sequence_info';
  --
  get_assigned_sequence_info(
    p_context_type             => l_context_type,
    p_context_value            => l_context_value,
    p_application_Id           => l_application_id,
    p_table_name               => l_table_name,
    p_event_code               => l_event_code,
    p_control_attribute_rec    => l_control_attribute_rec,
    p_control_date_tbl         => l_control_date_tbl,
    p_request_id               => NULL,
    p_suppress_error           => l_suppress_error,
    x_sequence_type            => l_sequence_type,           -- OUT
    x_seq_version_id           => l_seq_version_id,          -- OUT
    x_assignment_id            => l_assignment_id,           -- OUT
    x_control_date_value       => l_control_date_value,      -- OUT
    x_req_assign_flag          => l_req_assign_flag,         -- OUT
    x_sort_option_code         => l_dummy,                   -- OUT
    x_error_code               => l_error_code_assign);      -- OUT

  --
  -- Return SUCCESS if no active Sequencing Context exists or
  -- no Assignment is found and Require Assignment flag is turned off.
  --
  IF l_error_code_assign IN ('NO_ASSIGN_CONTEXT','NO_ASSIGNMENT') THEN
    x_error_code := 'SUCCESS';
  --
  -- If there is an explicit order of "Do Not Sequence", that is,
  -- Sequence Name is null of a valid Assignment,
  -- Update Assignment Status
  --
  ELSIF l_error_code_assign = 'DO_NOT_SEQUENCE' THEN
    --
    l_debug_loc := 'update_assign_status';
    --
    -- Update Status of the Assignment
    --
    update_assign_status(
      p_assignment_id => l_assignment_id);
    --
    -- Populate OUT variables
    --
    x_assignment_id := l_assignment_id;
    x_error_code := 'SUCCESS';
  ELSIF l_error_code_assign = 'ENFORCED_NO_ASSIGNMENT' THEN
    --
    l_debug_loc := 'EXCEPTION: no_assign_seq_info';
    --
    RAISE no_assigned_seq_info;
  --
  -- Generate sequence numbers if Sequence Version is found.
  --
  ELSIF l_error_code_assign = 'SEQ_VER_FOUND' THEN
    --
    l_debug_loc := 'generate_sequence_number';
    --
    generate_sequence_number(
      p_assignment_id    => l_assignment_id,
      p_seq_version_id   => l_seq_version_id,
      p_sequence_type    => l_sequence_type,
      p_request_id       => NULL,  -- Online mode
      x_sequence_number  => l_sequence_number,  -- OUT
      x_sequenced_date   => l_sequenced_date,  -- Not Used Here
      x_error_code       => l_error_code_seq);  -- OUT

    --
    -- Populate return values
    --
    x_seq_version_id     := l_seq_version_id;
    x_sequence_number    := l_sequence_number;
    x_assignment_id      := l_assignment_id;
    x_error_code         := l_error_code_seq;

  ELSE
     RAISE invalid_error_code;
  END IF;

EXCEPTION
   WHEN no_assigned_seq_info THEN
     --
     -- Logging
     --
     IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
       fnd_log.string(
         log_level => fnd_log.level_exception,
         module    => 'fun.plsql.fun_seq.get_sequence_number_no_commit',
         message   =>
           'l_debug_loc: '     || l_debug_loc      ||', '||
           'p_context_type: '  || p_context_type   ||', '||
           'p_context_value: ' || p_context_value  ||', '||
           'p_application_id: '|| p_application_id ||', '||
           'p_table_name: '    || p_table_name     ||', '||
           'p_event_code: '    || p_event_code     ||', '||
           'balance type: '
             || p_control_attribute_rec.balance_type          ||', '||
           'journal source: '
             || p_control_attribute_rec.journal_source        ||', '||
           'journal category: '
             || p_control_attribute_rec.journal_category      ||', '||
           'acct entry type: '
             || p_control_attribute_rec.accounting_entry_type ||', '||
           'acct event type: '
             || p_control_attribute_rec.accounting_event_type ||', '||
           'doc category: '
             || p_control_attribute_rec.document_category     ||', '||
           'p_suppress_error: '|| p_suppress_error            ||', '||
           'SQLERRM: '         || SQLERRM);
     END IF;
     --
     -- The message is put on the stack in Get_Assigned_Sequence_Info
     --
     x_error_code := 'ENFORCED_NO_ASSIGNMENT';
     IF p_suppress_error = 'N' THEN
        app_exception.raise_exception;
     END IF;
   WHEN OTHERS THEN
     --
     -- Logging
     --
     IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
       fnd_log.string(
         log_level => fnd_log.level_exception,
         module    => 'fun.plsql.fun_seq.get_sequence_number_no_commit',
         message   =>
           'l_debug_loc: '     || l_debug_loc      ||', '||
           'p_context_type: '  || p_context_type   ||', '||
           'p_context_value: ' || p_context_value  ||', '||
           'p_application_id: '|| p_application_id ||', '||
           'p_table_name: '    || p_table_name     ||', '||
           'p_event_code: '    || p_event_code     ||', '||
           'balance type: '
              || p_control_attribute_rec.balance_type          ||', '||
           'journal source: '
              || p_control_attribute_rec.journal_source        ||', '||
           'journal category: '
              || p_control_attribute_rec.journal_category      ||', '||
           'acct entry type: '
              || p_control_attribute_rec.accounting_entry_type ||', '||
           'acct event type: '
              || p_control_attribute_rec.accounting_event_type ||', '||
           'doc category: '
              || p_control_attribute_rec.document_category     ||', '||
           'p_suppress_error: '|| p_suppress_error ||', '||
           'SQLERRM: '         || SQLERRM);
     END IF;
     --
     -- Raise Exception
     --
     app_exception.raise_exception;
END Get_Sequence_Number_No_Commit;

--
-- Get Sequence Number (without Autonmous Commit)
--
PROCEDURE Get_Sequence_Number_Commit(
            p_context_type          IN  VARCHAR2,
            p_context_value         IN  VARCHAR2,
            p_application_id        IN  NUMBER,
            p_table_name            IN  VARCHAR2,
            p_event_code            IN  VARCHAR2,
            p_control_attribute_rec IN  control_attribute_rec_type,
            p_control_date_tbl      IN  control_date_tbl_type,
            p_suppress_error        IN  VARCHAR2,
            x_seq_version_id        OUT NOCOPY NUMBER,
            x_sequence_number       OUT NOCOPY NUMBER,
            x_assignment_id         OUT NOCOPY NUMBER,
            x_error_code            OUT NOCOPY VARCHAR2) IS
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

  get_sequence_number_no_commit (
    p_context_type           => p_context_type,
    p_context_value          => p_context_value,
    p_application_id         => p_application_id,
    p_table_name             => p_table_name,
    p_event_code             => p_event_code,
    p_control_attribute_rec  => p_control_attribute_rec,
    p_control_date_tbl       => p_control_date_tbl,
    p_suppress_error         => p_suppress_error,
    x_seq_version_id         => x_seq_version_id,
    x_sequence_number        => x_sequence_number,
    x_assignment_id          => x_assignment_id,
    x_error_code             => x_error_code);

  COMMIT;

END Get_Sequence_Number_Commit;

--
--
--

--
-- Get Sequencing Context Information with Cache
-- (For Batch Mode only)
--
PROCEDURE get_cached_context_info (
            p_context_info_rec   IN  context_info_rec_type,
            x_context_ctrl_rec   OUT NOCOPY context_ctrl_rec_type) IS
  l_context_ctrl_rec   context_ctrl_rec_type;
  l_sc_cache_index    BINARY_INTEGER;
BEGIN

  --
  -- Find Index of Cached Sequencing Context Information
  --
  l_sc_cache_index := find_seq_context_in_cache (
                         p_context_info_rec => p_context_info_rec);
  --
  -- If the Sequencing Context is in the cache, ..
  --
  IF l_sc_cache_index < g_sc_cache_size THEN
    --
    -- Get Sequencing Context Control Information from Cache
    --
    x_context_ctrl_rec := g_context_ctrl_tbl(l_sc_cache_index);
  ELSE
    --
    -- Get the Control Information from the Database
    --
    l_context_ctrl_rec := find_seq_context_in_db (
                             p_context_info_rec => p_context_info_rec);
    --
    -- If the Sequencing Context exists in DB,...
    --
    IF l_context_ctrl_rec.seq_context_id IS NOT NULL THEN
      --
      -- Put the record of Sequencing Context and Control information
      -- in Cache.
      --
      g_context_info_tbl(g_sc_cache_size) := p_context_info_rec;
      g_context_ctrl_tbl(g_sc_cache_size) := l_context_ctrl_rec;
      --
      -- Increase the cache size by 1
      --
      g_sc_cache_size := g_sc_cache_size + 1;
      --
      -- Return Seq_Context_Id, Req_Assign_Flag, and Date_Type
      --
      x_context_ctrl_rec  := l_context_ctrl_rec;
    END IF;
  END IF;

EXCEPTION
WHEN OTHERS THEN
  app_exception.raise_exception;
END get_cached_context_info;

--
-- Retrieve Assigned Sequences of Assignment / Exception
--
PROCEDURE get_assigned_sequence_header (
            p_seq_context_id        IN  NUMBER,
            p_control_attribute_rec IN  control_attribute_rec_type,
            p_control_date_value    IN  DATE,
            p_request_id            IN  NUMBER,
            x_assignment_id         OUT NOCOPY NUMBER,
            x_sequence_type         OUT NOCOPY VARCHAR2,
            x_seq_header_id         OUT NOCOPY NUMBER)
IS

  l_assignment_id         fun_seq_assignments.assignment_id%TYPE;
  l_sequence_type         fun_seq_headers.gapless_flag%TYPE;
  l_seq_header_id         fun_seq_headers.seq_header_id%TYPE;

  l_exp_assignment_id     fun_seq_assignments.assignment_id%TYPE;
  l_exp_sequence_type     fun_seq_headers.gapless_flag%TYPE;
  l_exp_seq_header_id     fun_seq_headers.seq_header_id%TYPE;

BEGIN
  --
  -- Get Sequence Info of Assignment
  --
  get_seq_header_assignment(
    p_seq_context_id         => p_seq_context_id,
    p_control_attribute_rec  => p_control_attribute_rec,
    p_control_date_value     => p_control_date_value,
    p_request_id             => p_request_id,
    x_assignment_id          => l_assignment_id,  -- OUT
    x_sequence_type          => l_sequence_type,  -- OUT
    x_seq_header_id          => l_seq_header_id); -- OUT
  --
  -- If no sequence assignment is found,
  -- Exit the routine.
  --
  IF l_assignment_id IS NULL THEN
    RETURN;
  ELSE
    --
    -- If sequence assignment id is found,
    -- check if exceptions exist for the assignment.
    --
    -- fun_seq_utils.log_procedure(
    --  p_module        => l_module || '.' || 'in progress',
    --   p_message_text  => 'Beginning of get_seq_header_exception');
    --
    get_seq_header_exception(
      p_assignment_id         => l_assignment_id,
      p_control_attribute_rec => p_control_attribute_rec,
      p_control_date_value    => p_control_date_value,
      p_request_id            => p_request_id,
      x_exp_assignment_id     => l_exp_assignment_id,
      x_exp_sequence_type     => l_exp_sequence_type,
      x_exp_seq_header_id     => l_exp_seq_header_id);
    --
    --fun_seq_utils.log_procedure(
    --  p_module        => l_module || '.' || 'in progress',
    --   p_message_text  => 'End of get_seq_header_exception');
    --
  END IF;
  --
  -- Return Assignment Id and Sequence Header Information
  --
  IF l_exp_assignment_id IS NULL THEN
    x_assignment_id  := l_assignment_id;
    x_sequence_type  := l_sequence_type;
    x_seq_header_id  := l_seq_header_id;
  ELSE
    x_assignment_id  := l_exp_assignment_id;
    x_sequence_type  := l_exp_sequence_type;
    x_seq_header_id  := l_exp_seq_header_id;
  END IF;
EXCEPTION
WHEN OTHERS THEN
  app_exception.raise_exception;
END get_assigned_sequence_header;

--
-- Retrieve Assignment Information of Intercompany Transactions
--
PROCEDURE get_ic_assigned_seq_header (
            p_seq_context_id         IN  NUMBER,
            p_control_date_value     IN  DATE,
            p_request_id             IN  NUMBER,
            x_assignment_id          OUT NOCOPY NUMBER,
            x_sequence_type          OUT NOCOPY VARCHAR2,
            x_seq_header_id          OUT NOCOPY NUMBER) IS
BEGIN
  --
  -- IF p_request_id IS NULL THEN
  --
    SELECT sa.assignment_id,
           sa.seq_header_id,
           sh.gapless_flag
      INTO x_assignment_id,
           x_seq_header_id,
           x_sequence_type
      FROM fun_seq_assignments sa, fun_seq_headers sh
     WHERE sa.seq_context_id = p_seq_context_id
       AND sa.seq_header_id = sh.seq_header_id
       AND sh.obsolete_flag = 'N'
       AND sa.link_to_assignment_id IS NULL
       AND sa.start_date        <= p_control_date_value
       AND sa.use_status_code IN ('NEW','USED')
       AND p_control_date_value <= NVL(sa.end_date, p_control_date_value + 1);
  -- END IF;
EXCEPTION
WHEN OTHERS THEN
  app_exception.raise_exception;
END get_ic_assigned_seq_header;

--
-- Retrieve Assignment Id and its Sequence Header Id of Assignments.
-- Note:
-- Called from Get_Assigned_Sequence
-- Product team should not call this procedure directly.
--
PROCEDURE get_seq_header_assignment(
            p_seq_context_id         IN  NUMBER,
            p_control_attribute_rec  IN  control_attribute_rec_type,
            p_control_date_value     IN  DATE,
            p_request_id             IN  NUMBER,
            x_assignment_id          OUT NOCOPY NUMBER,
            x_sequence_type          OUT NOCOPY VARCHAR2,
            x_seq_header_id          OUT NOCOPY NUMBER)
IS
  l_assignment_id        fun_seq_assignments.assignment_id%TYPE;
  l_seq_header_id        fun_seq_headers.seq_header_id%TYPE;
  l_sequence_type        fun_seq_headers.gapless_flag%TYPE;

  l_assign_info_rec      assign_info_rec_type;
  l_assign_seq_head_rec  assign_seq_head_rec_type;
BEGIN
  IF g_use_cache_flag = FALSE THEN
    -- For Online Transactions, issue a Pessimistic Lock
    SELECT sa.assignment_id,
           sa.seq_header_id,
           sh.gapless_flag
      INTO x_assignment_id,
           x_seq_header_id,
           x_sequence_type
      FROM fun_seq_assignments sa, fun_seq_headers sh
     WHERE sa.seq_context_id = p_seq_context_id
       AND sa.seq_header_id = sh.seq_header_id (+)  -- (+)  Do Not Sequence
       AND sh.obsolete_flag (+) = 'N'
       AND sa.link_to_assignment_id IS NULL
       AND sa.start_date        <= p_control_date_value
       AND sa.use_status_code IN ('NEW','USED')
       AND p_control_date_value <= NVL(sa.end_date, p_control_date_value + 1)
       AND NVL(sa.balance_type, '@NULL@') =
           NVL2(sa.balance_type,
                p_control_attribute_rec.balance_type, '@NULL@')
       AND NVL(sa.journal_source, '@NULL@') =
           NVL2(sa.journal_source,
                p_control_attribute_rec.journal_source, '@NULL@')
       AND NVL(sa.journal_category, '@NULL@') =
           NVL2(sa.journal_category,
                p_control_attribute_rec.journal_category, '@NULL@')
       AND NVL(sa.document_category, '@NULL@') =
           NVL2(sa.document_category,
                p_control_attribute_rec.document_category, '@NULL@')
       AND NVL(sa.accounting_event_type, '@NULL@') =
           NVL2(sa.accounting_event_type,
                p_control_attribute_rec.accounting_event_type, '@NULL@')
       AND NVL(sa.accounting_entry_type, '@NULL@') =
           NVL2(sa.accounting_entry_type,
                p_control_attribute_rec.accounting_entry_type, '@NULL@')
       FOR UPDATE;
   ELSE
     l_assign_info_rec.seq_context_id := p_seq_context_id;
     l_assign_info_rec.ctrl_attr_rec  := p_control_attribute_rec;
     l_assign_info_rec.control_date   := p_control_date_value;
     --
     -- Get Assigned Sequence information from Cache
     --
     get_cached_seq_header_assign (
       p_assign_info_rec      => l_assign_info_rec,
       x_assign_seq_head_rec  => l_assign_seq_head_rec);

     x_assignment_id := l_assign_seq_head_rec.assignment_id;
     x_seq_header_id := l_assign_seq_head_rec.seq_header_id;
     x_sequence_type := l_assign_seq_head_rec.seq_type;
   END IF;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
     x_assignment_id := NULL;
   WHEN OTHERS THEN
     app_exception.raise_exception;
END get_seq_header_assignment;

--
-- Retrieve Assignment Id and Sequence Header Id from the Cache
-- Note:
-- Called from Get_Seq_Header_Assignment
--
PROCEDURE get_cached_seq_header_assign (
            p_assign_info_rec      IN  assign_info_rec_type,
            x_assign_seq_head_rec  OUT NOCOPY assign_seq_head_rec_type)  IS

  l_assign_seq_head_rec   assign_seq_head_rec_type;
  l_as_cache_index        BINARY_INTEGER;
BEGIN
  --
  -- Find Index of Cached Assigned Sequence Information
  --
  l_as_cache_index := find_seq_head_assign_in_cache (
                        p_assign_info_rec => p_assign_info_rec);
  --
  -- If the Assigned Sequence Information is in the cache, ..
  --
  IF l_as_cache_index < g_as_cache_size THEN
    --
    -- Get Assigned Sequence Information from Cache
    --
    x_assign_seq_head_rec := g_assign_seq_head_tbl(l_as_cache_index);
  ELSE
    --
    -- Get the Assigned Sequence Information from the Database
    --
    l_assign_seq_head_rec := find_seq_head_assign_in_db (
                               p_assign_info_rec => p_assign_info_rec);
    --
    -- If the Assigned Sequence Information exists in DB,...
    --
    IF l_assign_seq_head_rec.assignment_id IS NOT NULL THEN
      --
      -- Put the record of Assignment and Sequence Header information
      -- in Cache.
      --
      g_assign_info_tbl(g_as_cache_size).seq_context_id
            := p_assign_info_rec.seq_context_id;
      g_assign_info_tbl(g_as_cache_size).control_date
            := p_assign_info_rec.control_date;
      g_assign_info_tbl(g_as_cache_size).ctrl_attr_rec.balance_type
            := p_assign_info_rec.ctrl_attr_rec.balance_type;
      g_assign_info_tbl(g_as_cache_size).ctrl_attr_rec.journal_source
            := p_assign_info_rec.ctrl_attr_rec.journal_source;
      g_assign_info_tbl(g_as_cache_size).ctrl_attr_rec.journal_category
            := p_assign_info_rec.ctrl_attr_rec.journal_category;
      g_assign_info_tbl(g_as_cache_size).ctrl_attr_rec.document_category
            := NVL(p_assign_info_rec.ctrl_attr_rec.document_category,-1);
      g_assign_info_tbl(g_as_cache_size).ctrl_attr_rec.accounting_event_type
            := NVL(p_assign_info_rec.ctrl_attr_rec.accounting_event_type, -1);
      g_assign_info_tbl(g_as_cache_size).ctrl_attr_rec.accounting_entry_type
            := NVL(p_assign_info_rec.ctrl_attr_rec.accounting_entry_type, -1);

      g_assign_seq_head_tbl(g_as_cache_size) := l_assign_seq_head_rec;
      --
      -- Increase the cache size by 1
      --
      g_as_cache_size := g_as_cache_size + 1;
      --
      -- Return Assignment Id, Sequence Header Id, and
      -- Sequence Type
      --
      x_assign_seq_head_rec := l_assign_seq_head_rec;
    END IF;
  END IF;

EXCEPTION
WHEN OTHERS THEN
  app_exception.raise_exception;
END get_cached_seq_header_assign;
--
-- Retrieve Assignment Id and its Sequence Header Id of Exceptions.
-- Note:
-- Called from Get_Assigned_Sequence
-- Product team should not call this procedure directly.
--
PROCEDURE get_seq_header_exception(
            p_assignment_id         IN  NUMBER,
            p_control_attribute_rec IN  control_attribute_rec_type,
            p_control_date_value    IN  DATE,
            p_request_id            IN  NUMBER,
            x_exp_assignment_id     OUT NOCOPY NUMBER,
            x_exp_sequence_type     OUT NOCOPY VARCHAR2,
            x_exp_seq_header_id     OUT NOCOPY NUMBER) IS

  -- TODO: Check the cursor SQL. What if all the passed control attributes
  -- are null?

  TYPE Seq_Header_Type IS REF CURSOR;
  l_CursorVar         Seq_Header_Type;

  l_exp_info_rec      exp_info_rec_type;
  l_exp_seq_head_rec  assign_seq_head_rec_type;

BEGIN
  --
  -- Online
  --
  IF g_use_cache_flag = FALSE THEN
    OPEN l_CursorVar FOR
      SELECT xsa.assignment_id,
             xsh.gapless_flag,
             xsa.seq_header_id
        FROM fun_seq_assignments xsa, fun_seq_headers xsh
       WHERE xsa.link_to_assignment_id = p_assignment_id
         AND xsa.start_date  <= p_control_date_value
         AND p_control_date_value <= NVL(xsa.end_date, p_control_date_value + 1)
         AND xsa.use_status_code IN ('NEW','USED')
         AND xsa.seq_header_id = xsh.seq_header_id  (+) -- Do Not Sequence
         AND xsh.obsolete_flag (+) = 'N'
         AND (xsa.balance_type IS NULL OR
              xsa.balance_type = p_control_attribute_rec.balance_type)
         AND (xsa.journal_source IS NULL OR
              xsa.journal_source = p_control_attribute_rec.journal_source)
         AND (xsa.journal_category IS NULL OR
              xsa.journal_category = p_control_attribute_rec.journal_category)
         AND (xsa.document_category IS NULL OR
              xsa.document_category
                = p_control_attribute_rec.document_category)
         AND (xsa.accounting_event_type IS NULL OR
              xsa.accounting_event_type
                = p_control_attribute_rec.accounting_event_type)
         AND (xsa.accounting_entry_type IS NULL OR
              xsa.accounting_entry_type
                = p_control_attribute_rec.accounting_entry_type)
       ORDER BY xsa.priority
         FOR UPDATE;
    --
    -- Loop - Beginning
    --
    LOOP
      FETCH l_CursorVar
       INTO x_exp_assignment_id,
            x_exp_sequence_type,
            x_exp_seq_header_id;
      --
      -- Assignments are already ordered by Priority.
      -- The first fetched row should be the one returned to a caller.
      --
      IF (l_CursorVar%NOTFOUND) OR (l_CursorVar%ROWCOUNT = 1) THEN
        EXIT;
      END IF;
    END LOOP;
    CLOSE l_CursorVar;
  --
  -- Batch (Use Cache)
  --
  ELSE
    -- This ID is for the Parent Assignment not for Exception
    l_exp_info_rec.assignment_id  := p_assignment_id;
    l_exp_info_rec.ctrl_attr_rec  := p_control_attribute_rec;
    l_exp_info_rec.control_date   := p_control_date_value;
    --
    -- Get Assigned Sequence information from Cache
    --
    get_cached_seq_header_exp (
      p_exp_info_rec      => l_exp_info_rec,
      x_exp_seq_head_rec  => l_exp_seq_head_rec);
    --
    -- Set OUT variables
    --
    x_exp_assignment_id := l_exp_seq_head_rec.assignment_id;
    x_exp_sequence_type := l_exp_seq_head_rec.seq_type;
    x_exp_seq_header_id := l_exp_seq_head_rec.seq_header_id;
  END IF;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
     x_exp_assignment_id := NULL;
     x_exp_sequence_type := NULL;
     x_exp_seq_header_id := NULL;
   WHEN OTHERS THEN
     app_exception.raise_exception;
END get_seq_header_exception;

--
-- Get_Seq_Context_Name
-- (for debug)
FUNCTION get_seq_context_name (
           p_seq_context_id IN NUMBER) RETURN VARCHAR2 IS
  l_seq_context_name fun_seq_contexts.name%TYPE;
BEGIN
  SELECT name
    INTO l_seq_context_name
    FROM fun_seq_contexts
   WHERE seq_context_id = p_seq_context_id;

  RETURN l_seq_context_name;
END get_seq_context_name;

--
-- Get_Seq_Header_Name
-- (for debug)
FUNCTION get_seq_header_name (
           p_seq_header_id IN NUMBER) RETURN VARCHAR2 IS
  l_seq_header_name fun_seq_headers.header_name%TYPE;
BEGIN
  SELECT header_name
    INTO l_seq_header_name
    FROM fun_seq_headers
   WHERE seq_header_id = p_seq_header_id;

  RETURN l_seq_header_name;
END get_seq_header_name;

--
-- Retrieve Assignment Id and Sequence Header Id from the Cache
-- Note:
-- Called from Get_Seq_Header_Exception
--
PROCEDURE get_cached_seq_header_exp (
            p_exp_info_rec      IN  exp_info_rec_type,
            x_exp_seq_head_rec  OUT NOCOPY assign_seq_head_rec_type) IS

  l_exp_seq_head_rec   assign_seq_head_rec_type;
  l_exp_cache_index        BINARY_INTEGER;
BEGIN
  --
  -- Find Index of Cached Assigned Sequence Information
  --
  l_exp_cache_index := find_seq_head_exp_in_cache (
                        p_exp_info_rec => p_exp_info_rec);
  --
  -- If the Assigned Sequence Information is in the cache, ..
  --
  IF l_exp_cache_index < g_exp_cache_size THEN
    --
    -- Get Assigned Sequence Information from Cache
    --
    x_exp_seq_head_rec := g_exp_seq_head_tbl(l_exp_cache_index);
  ELSE
    --
    -- Get the Assigned Sequence Information from the Database
    --
    -- ** This Assignment ID is for Exception Line
    l_exp_seq_head_rec := find_seq_head_exp_in_db (
                               p_exp_info_rec => p_exp_info_rec);
    --
    -- If the Assigned Sequence Information exists in DB,...
    --
    IF l_exp_seq_head_rec.assignment_id IS NOT NULL THEN
      --
      -- Put the record of Assignment and Sequence Header information
      -- in Cache.
      --
      -- This ID is for the parent Assignment not Exception
      g_exp_info_tbl(g_exp_cache_size).assignment_id
        := p_exp_info_rec.assignment_id;
      --
      g_exp_info_tbl(g_exp_cache_size).control_date
        := p_exp_info_rec.control_date;
      g_exp_info_tbl(g_exp_cache_size).ctrl_attr_rec.balance_type
        := p_exp_info_rec.ctrl_attr_rec.balance_type;
      g_exp_info_tbl(g_exp_cache_size).ctrl_attr_rec.journal_source
        := p_exp_info_rec.ctrl_attr_rec.journal_source;
      g_exp_info_tbl(g_exp_cache_size).ctrl_attr_rec.journal_category
        := p_exp_info_rec.ctrl_attr_rec.journal_category;
      g_exp_info_tbl(g_exp_cache_size).ctrl_attr_rec.document_category
        := NVL(p_exp_info_rec.ctrl_attr_rec.document_category, -1);
      g_exp_info_tbl(g_exp_cache_size).ctrl_attr_rec.accounting_event_type
        := NVL(p_exp_info_rec.ctrl_attr_rec.accounting_event_type, -1);
      g_exp_info_tbl(g_exp_cache_size).ctrl_attr_rec.accounting_entry_type
        := NVL(p_exp_info_rec.ctrl_attr_rec.accounting_entry_type, -1);

      g_exp_seq_head_tbl(g_exp_cache_size) := l_exp_seq_head_rec;
      --
      -- Increase the cache size by 1
      --
      g_exp_cache_size := g_exp_cache_size + 1;
      --
      -- Return Assignment Id, Sequence Header Id, and
      -- Sequence Type
      --
      x_exp_seq_head_rec := l_exp_seq_head_rec;
    END IF;
  END IF;

EXCEPTION
WHEN OTHERS THEN
  app_exception.raise_exception;
END get_cached_seq_header_exp;

-- Program Name: Get_Seq_Version
-- Description:
--   Retrieve an Active Sequence Version
--
PROCEDURE get_seq_version (
            p_sequence_type       IN  VARCHAR2,
            p_seq_header_id       IN  NUMBER,
            p_control_date_value  IN  DATE,
            p_request_id          IN  NUMBER,
            x_seq_version_id      OUT NOCOPY NUMBER) IS
BEGIN
  IF g_use_cache_flag = FALSE THEN
    -- For Online Transactions, issue Pessimistic Lock
    SELECT sv.seq_version_id
      INTO x_seq_version_id
      FROM fun_seq_versions sv
     WHERE sv.seq_header_id      = p_seq_header_id
       AND sv.start_date        <= p_control_date_value
       AND p_control_date_value <= NVL(sv.end_date, p_control_date_value + 1)
       AND sv.use_status_code IN ('NEW','USED')
       FOR UPDATE;
  ELSE -- No Lock is necessary, assuming Setup Pages become read-only.
    SELECT sv.seq_version_id
      INTO x_seq_version_id
      FROM fun_seq_versions sv
     WHERE sv.seq_header_id      = p_seq_header_id
       AND sv.start_date        <= p_control_date_value
       AND p_control_date_value <= NVL(sv.end_date, p_control_date_value + 1)
       AND sv.use_status_code IN ('NEW','USED');
  END IF;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
     fnd_message.set_name ('FUN','FUN_SEQ_NO_ACTIVE_SEQ_FOUND');
     fnd_message.set_token ('SEQ_NAME',get_seq_header_name(p_seq_header_id));
     --
     -- Cannot suppress this exception
     --
     app_exception.raise_exception;
END get_seq_version;

--
--
--
FUNCTION get_control_date_value (
           p_control_date_type IN VARCHAR2,
           p_control_dates     IN control_date_tbl_type) RETURN VARCHAR2
IS
   l_control_date_value DATE;
BEGIN
  FOR i IN p_control_dates.FIRST .. p_control_dates.LAST LOOP
    l_control_date_value:= p_control_dates(i).date_value;
    EXIT WHEN p_control_dates(i).date_type = p_control_date_type;
  END LOOP;

  RETURN l_control_date_value;
EXCEPTION
WHEN OTHERS THEN
  app_exception.raise_exception;
END get_control_date_value;

--
-- Updat_Gapless_Status
--
PROCEDURE update_gapless_status (
           p_assignment_id  IN NUMBER,
           p_seq_version_id IN NUMBER) IS
BEGIN
  --
  -- Update the Status of Versions
  --
  update_seq_ver_status(p_seq_version_id => p_seq_version_id);
  --
  -- Update the Status of Assignment and Exception
  -- For Exceptions, Update the status of its Parent Assignment
  --
  update_assign_status (p_assignment_id => p_assignment_id);
EXCEPTION
WHEN OTHERS THEN
  app_exception.raise_exception;
END update_gapless_status;

--
-- Update the Status of Versions with Database Sequence
--
PROCEDURE update_db_status (
           p_assignment_id  IN NUMBER,
           p_seq_version_id IN NUMBER) IS
  --
  -- This will cause deadlock if Version is Locked
  --
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
  --
  -- Update the Status of Assignment and Exception
  -- For Exceptions, Update the status of its Parent Assignment
  --
  update_assign_status (p_assignment_id => p_assignment_id);
  --
  -- Update the Status of Versions
  --
  update_seq_ver_status(p_seq_version_id => p_seq_version_id);
  --
  COMMIT;
EXCEPTION
WHEN OTHERS THEN
  app_exception.raise_exception;
END update_db_status;

--
-- Update_Assign_Status
--
-- Update the status of the Assignment
--
PROCEDURE update_assign_status (
           p_assignment_id  IN NUMBER) IS

  TYPE assign_id_tbl_type IS TABLE OF fun_seq_assignments.assignment_id%TYPE
    INDEX BY BINARY_INTEGER;

  l_assign_id_tbl     assign_id_tbl_type;
BEGIN
  SELECT assignment_id
    BULK COLLECT
    INTO l_assign_id_tbl
    FROM fun_seq_assignments
   WHERE use_status_code = 'NEW'
     AND ((assignment_id = p_assignment_id) OR
          (assignment_id = (SELECT ex.link_to_assignment_id
                              FROM fun_seq_assignments ex
                             WHERE ex.assignment_id = p_assignment_id)));
  --
  -- When no data is found, then l_assign_id_tbl.count = 0
  --
  IF l_assign_id_tbl.COUNT > 0 THEN
    FORALL i in l_assign_id_tbl.FIRST .. l_assign_id_tbl.LAST
      UPDATE fun_seq_assignments
         SET use_status_code = 'USED'
       WHERE assignment_id = l_assign_id_tbl(i);
  END IF;
EXCEPTION
WHEN OTHERS THEN
  app_exception.raise_exception;
END update_assign_status;
--
-- Update_Seq_Ver_Status
--
-- Update the status of the Sequence Version
--
PROCEDURE update_seq_ver_status (
           p_seq_version_id  IN NUMBER) IS

  l_seq_version_id fun_seq_versions.seq_version_id%TYPE;
BEGIN
  --
  -- Check if we need to update the status of the Version
  --
  SELECT seq_version_id
    INTO l_seq_version_id
    FROM fun_seq_versions
   WHERE seq_version_id = p_seq_version_id
     AND use_status_code = 'NEW';
  --
  -- Update status of the Version
  --
  UPDATE fun_seq_versions
     SET use_status_code = 'USED'
   WHERE seq_version_id = l_seq_version_id;
EXCEPTION
WHEN NO_DATA_FOUND THEN
  NULL;
WHEN OTHERS THEN
  app_exception.raise_exception;
END update_seq_ver_status;
--
-- Find a Sequencing Context in the Cache
--
FUNCTION find_seq_context_in_cache(
           p_context_info_rec IN context_info_rec_type) RETURN BINARY_INTEGER IS

  l_sc_index    BINARY_INTEGER;
  l_found       BOOLEAN;
BEGIN
  l_sc_index := 0;
  l_found    := FALSE;

  WHILE (l_sc_index < g_sc_cache_size) AND (NOT l_found) LOOP
    --
    -- g_context_info_tbl(l_sc_index) = p_context_info_rec gives an error.
    --
    IF g_context_info_tbl(l_sc_index).application_id =
         p_context_info_rec.application_id AND
       g_context_info_tbl(l_sc_index).table_name     =
         p_context_info_rec.table_name     AND
       g_context_info_tbl(l_sc_index).context_type   =
         p_context_info_rec.context_type   AND
       g_context_info_tbl(l_sc_index).context_value  =
         p_context_info_rec.context_value  AND
       g_context_info_tbl(l_sc_index).event_code     =
         p_context_info_rec.event_code
    THEN
      l_found := TRUE;
    ELSE
      l_sc_index := l_sc_index + 1;
    END IF;
  END LOOP;

  RETURN l_sc_index;
END find_seq_context_in_cache;

--
-- Find a Sequencing Context in the database
--
FUNCTION find_seq_context_in_db(
  p_context_info_rec IN context_info_rec_type)  RETURN context_ctrl_rec_type IS

  l_context_ctrl_rec context_ctrl_rec_type;
BEGIN
  SELECT sac.seq_context_id,
         sac.date_type,
         sac.require_assign_flag,
         sac.sort_option
    INTO l_context_ctrl_rec.seq_context_id,
         l_context_ctrl_rec.date_type,
         l_context_ctrl_rec.req_assign_flag,
         l_context_ctrl_rec.sort_option_code
    FROM fun_seq_contexts sac
   WHERE sac.application_id = p_context_info_rec.application_id
     AND sac.table_name     = p_context_info_rec.table_name
     AND sac.context_type   = p_context_info_rec.context_type
     AND sac.context_value  = p_context_info_rec.context_value
     AND sac.event_code     = p_context_info_rec.event_code
     AND sac.obsolete_flag  = 'N';

  RETURN l_context_ctrl_rec;
EXCEPTION
WHEN NO_DATA_FOUND THEN
  --
  -- No Sequencing is required
  --
  l_context_ctrl_rec  := NULL;
  RETURN l_context_ctrl_rec;
WHEN OTHERS THEN
  app_exception.raise_exception;
END find_seq_context_in_db;

--
-- Find an Assigned Sequence Header in the Cache
--
FUNCTION find_seq_head_assign_in_cache(
           p_assign_info_rec IN assign_info_rec_type)
  RETURN BINARY_INTEGER IS

  l_as_index    BINARY_INTEGER;
  l_found       BOOLEAN;
BEGIN
  l_as_index := 0;
  l_found    := FALSE;

  --
  -- *** Revisit DATE evaliation for better performance
  -- *** May have better use range validation
  --
  WHILE (l_as_index < g_as_cache_size) AND (NOT l_found) LOOP
    IF g_assign_info_tbl(l_as_index).seq_context_id
       = p_assign_info_rec.seq_context_id AND
       g_assign_info_tbl(l_as_index).control_date
        = p_assign_info_rec.control_date AND
       g_assign_info_tbl(l_as_index).ctrl_attr_rec.balance_type
       = p_assign_info_rec.ctrl_attr_rec.balance_type AND
       g_assign_info_tbl(l_as_index).ctrl_attr_rec.journal_source
       = p_assign_info_rec.ctrl_attr_rec.journal_source AND
       g_assign_info_tbl(l_as_index).ctrl_attr_rec.journal_category
       = p_assign_info_rec.ctrl_attr_rec.journal_category AND
       g_assign_info_tbl(l_as_index).ctrl_attr_rec.document_category
       = NVL(p_assign_info_rec.ctrl_attr_rec.document_category,-1) AND
       g_assign_info_tbl(l_as_index).ctrl_attr_rec.accounting_event_type
       = NVL(p_assign_info_rec.ctrl_attr_rec.accounting_event_type,-1) AND
       g_assign_info_tbl(l_as_index).ctrl_attr_rec.accounting_entry_type
       = NVL(p_assign_info_rec.ctrl_attr_rec.accounting_entry_type,-1)
    THEN
      l_found := TRUE;
    ELSE
      l_as_index := l_as_index + 1;
    END IF;
  END LOOP;

  RETURN l_as_index;
EXCEPTION
WHEN OTHERS THEN
  IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(
      log_level => fnd_log.level_exception,
      module    => 'fun.plsql.fun_seq.find_seq_head_assign_in_cache',
      message   => 'SQLERRM: ' || SQLERRM);
  END IF;
END find_seq_head_assign_in_cache;

--
-- Find an Assigned Sequence Header Information
--
FUNCTION find_seq_head_assign_in_db (
           p_assign_info_rec IN assign_info_rec_type)
  RETURN assign_seq_head_rec_type IS

  l_assign_seq_head_rec    assign_seq_head_rec_type;
  l_rec                    assign_info_rec_type;
BEGIN
  l_rec := p_assign_info_rec;
  SELECT sa.assignment_id,
         sa.seq_header_id,
         sh.gapless_flag
    INTO l_assign_seq_head_rec.assignment_id,
         l_assign_seq_head_rec.seq_header_id,
         l_assign_seq_head_rec.seq_type
    FROM fun_seq_assignments sa, fun_seq_headers sh
   WHERE sa.seq_context_id = l_rec.seq_context_id
     AND sa.seq_header_id = sh.seq_header_id (+) -- Do Not Sequence
     AND sh.obsolete_flag (+) = 'N'
     AND sa.link_to_assignment_id IS NULL
     AND sa.start_date        <= l_rec.control_date
     AND sa.use_status_code IN ('NEW','USED')
     AND l_rec.control_date <= NVL(sa.end_date, l_rec.control_date + 1)
     AND NVL(sa.balance_type, '@NULL@') =
         NVL2(sa.balance_type,
              l_rec.ctrl_attr_rec.balance_type, '@NULL@')
     AND NVL(sa.journal_source, '@NULL@') =
         NVL2(sa.journal_source,
              l_rec.ctrl_attr_rec.journal_source, '@NULL@')
     AND NVL(sa.journal_category, '@NULL@') =
         NVL2(sa.journal_category,
              l_rec.ctrl_attr_rec.journal_category, '@NULL@')
     AND NVL(sa.document_category, '@NULL@') =
         NVL2(sa.document_category,
              l_rec.ctrl_attr_rec.document_category, '@NULL@')
     AND NVL(sa.accounting_event_type, '@NULL@') =
         NVL2(sa.accounting_event_type,
              l_rec.ctrl_attr_rec.accounting_event_type, '@NULL@')
     AND NVL(sa.accounting_entry_type, '@NULL@') =
         NVL2(sa.accounting_entry_type,
              l_rec.ctrl_attr_rec.accounting_entry_type, '@NULL@');

  RETURN l_assign_seq_head_rec;
EXCEPTION
WHEN NO_DATA_FOUND THEN
  --
  -- No Assignment is found
  --
  l_assign_seq_head_rec := NULL;
  RETURN l_assign_seq_head_rec;
WHEN OTHERS THEN
  app_exception.raise_exception;
END find_seq_head_assign_in_db;

--
-- Find an Exception in the database
--
FUNCTION find_seq_head_exp_in_cache(
           p_exp_info_rec  IN exp_info_rec_type)
  RETURN BINARY_INTEGER IS

  l_rec         exp_info_rec_type;
  l_exp_index   BINARY_INTEGER;
  l_found       BOOLEAN;
BEGIN
  l_rec       := p_exp_info_rec;
  l_exp_index := 0;
  l_found     := FALSE;

  WHILE (l_exp_index < g_exp_cache_size) AND (NOT l_found) LOOP
    IF g_exp_info_tbl(l_exp_index).assignment_id   = l_rec.assignment_id AND
       g_exp_info_tbl(l_exp_index).control_date = l_rec.control_date AND
       g_exp_info_tbl(l_exp_index).ctrl_attr_rec.balance_type =
         l_rec.ctrl_attr_rec.balance_type AND
       g_exp_info_tbl(l_exp_index).ctrl_attr_rec.journal_source =
         l_rec.ctrl_attr_rec.journal_source AND
       g_exp_info_tbl(l_exp_index).ctrl_attr_rec.journal_category =
         l_rec.ctrl_attr_rec.journal_category AND
       g_exp_info_tbl(l_exp_index).ctrl_attr_rec.document_category =
         NVL(l_rec.ctrl_attr_rec.document_category, -1) AND
       g_exp_info_tbl(l_exp_index).ctrl_attr_rec.accounting_event_type =
         NVL(l_rec.ctrl_attr_rec.accounting_event_type,-1) AND
       g_exp_info_tbl(l_exp_index).ctrl_attr_rec.accounting_entry_type =
         NVL(l_rec.ctrl_attr_rec.accounting_entry_type,-1)
    THEN
      l_found := TRUE;
    ELSE
      l_exp_index := l_exp_index + 1;
    END IF;
  END LOOP;

  RETURN l_exp_index;
END find_seq_head_exp_in_cache;
--
-- Find an Exception in the database
--
FUNCTION find_seq_head_exp_in_db(
           p_exp_info_rec  IN exp_info_rec_type)
  RETURN assign_seq_head_rec_type IS

  TYPE Seq_Header_Type IS REF CURSOR;
  l_CursorVar  Seq_Header_Type;

  l_rec_in            exp_info_rec_type;
  l_exp_rec_out       assign_seq_head_rec_type;
BEGIN
  --
  -- Initialize records
  --
  l_rec_in := p_exp_info_rec;

  OPEN l_CursorVar FOR
    SELECT xsa.assignment_id,
           xsh.gapless_flag,
           xsa.seq_header_id
      FROM fun_seq_assignments xsa, fun_seq_headers xsh
     WHERE xsa.link_to_assignment_id = l_rec_in.assignment_id
       AND xsa.start_date  <= l_rec_in.control_date
       AND l_rec_in.control_date <= NVL(xsa.end_date, l_rec_in.control_date + 1)
       AND xsa.use_status_code IN ('NEW','USED')
       AND xsa.seq_header_id = xsh.seq_header_id  (+) -- Do not Sequence
       AND xsh.obsolete_flag (+) = 'N'
       AND (xsa.balance_type IS NULL OR
            xsa.balance_type = l_rec_in.ctrl_attr_rec.balance_type)
       AND (xsa.journal_source IS NULL OR
            xsa.journal_source = l_rec_in.ctrl_attr_rec.journal_source)
       AND (xsa.journal_category IS NULL OR
            xsa.journal_category = l_rec_in.ctrl_attr_rec.journal_category)
       AND (xsa.document_category IS NULL OR
            xsa.document_category
              = l_rec_in.ctrl_attr_rec.document_category)
       AND (xsa.accounting_event_type IS NULL OR
            xsa.accounting_event_type
              = l_rec_in.ctrl_attr_rec.accounting_event_type)
       AND (xsa.accounting_entry_type IS NULL OR
            xsa.accounting_entry_type
              = l_rec_in.ctrl_attr_rec.accounting_entry_type)
    ORDER BY xsa.priority;
  --
  -- Loop - Begin
  --
  LOOP
    FETCH l_CursorVar
     INTO l_exp_rec_out.assignment_id,
          l_exp_rec_out.seq_type,
          l_exp_rec_out.seq_header_id;
    --
    -- Assignments are already ordered by Priority.
    -- The first fetched row should be the one returned to a caller.
    --
    IF (l_CursorVar%NOTFOUND) OR (l_CursorVar%ROWCOUNT = 1) THEN
      EXIT;
    END IF;
  END LOOP;
  CLOSE l_CursorVar;
  RETURN l_exp_rec_out;
END find_seq_head_exp_in_db;

--
-- Checkk if we should use Cache
--  **** In case UI pages are display only. ****
--
FUNCTION use_cache (
           p_request_id      IN NUMBER,
           p_application_id  IN NUMBER,
           p_table_name      IN VARCHAR2,
           p_event_code      IN VARCHAR2) RETURN BOOLEAN IS
BEGIN
  IF p_request_id IS NULL THEN
    --
    -- Online Transactions (UI pages are NOT updatealbe.)
    --
    IF (p_application_id = 435 AND p_table_name = 'FUN_TRX_BATCHES') THEN
      RETURN (TRUE);
    --
    -- Online Transactions (UI pages are updateable.)
    --
    ELSE
      RETURN (FALSE);
    END IF;
  ELSE
    --
    -- Batch Mode
    --
    RETURN (TRUE);
  END IF;
END use_cache;
END fun_seq;

/
