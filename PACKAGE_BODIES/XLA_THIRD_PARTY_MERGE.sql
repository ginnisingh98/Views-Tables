--------------------------------------------------------
--  DDL for Package Body XLA_THIRD_PARTY_MERGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_THIRD_PARTY_MERGE" AS
-- $Header: xlamerge.pkb 120.17.12010000.7 2010/04/23 21:38:26 pshukla ship $
/*===========================================================================+
|                Copyright (c) 2005 Oracle Corporation                       |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| FILENAME                                                                   |
|    xlamerge.pkb                                                            |
|                                                                            |
| PACKAGE NAME                                                               |
|    xla_third_party_merge                                                   |
|                                                                            |
| DESCRIPTION                                                                |
|    This is a XLA private package, which contains all the APIs required for |
|    creating Third Party Merge events.                                      |
|                                                                            |
|    The public wrapper called xla_third_party_merge_pub, is built based on  |
|    this package.                                                           |
|                                                                            |
|    Note:                                                                   |
|       - the APIs may perform ROLLBACK for what changes they have made      |
|       - these APIs are not supposed to raise any exception                 |
|                                                                            |
| HISTORY                                                                    |
|    08-Sep-05 L. Poon   Created                                             |
|    03-Mar-05 V. Kumar  Bug 5041325 Populating GL_SL_LINK_ID in xla_ae_lines|
|    21-Jun-2006 A.Wan   5100860 Performance fix, see bug for detail         |
+===========================================================================*/

-------------------------------------------------------------------------------
-- Private types
-------------------------------------------------------------------------------
TYPE t_number_array IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE t_varchar30_array IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
TYPE t_varchar1_array IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;
TYPE t_date_array IS TABLE OF DATE INDEX BY BINARY_INTEGER;
type t_rowid_array is table of rowid index by binary_integer;

--=============================================================================
--             *********** Local Trace and Log Routines **********
--=============================================================================
C_LEVEL_STATEMENT     CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
C_LEVEL_PROCEDURE     CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
C_LEVEL_EVENT         CONSTANT NUMBER := FND_LOG.LEVEL_EVENT;
C_LEVEL_EXCEPTION     CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
C_LEVEL_ERROR         CONSTANT NUMBER := FND_LOG.LEVEL_ERROR;
C_LEVEL_UNEXPECTED    CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;
C_LEVEL_LOG_DISABLED  CONSTANT NUMBER := 99;
C_BULK_LIMIT          CONSTANT NUMBER := 3000;
C_WORK_UNIT           CONSTANT NUMBER := 2000;
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.xla_third_party_merge';

C_CREATED             CONSTANT VARCHAR2(8) :='CREATED';

g_debug_flag          VARCHAR2(1) := NVL(  fnd_profile.value('XLA_DEBUG_TRACE')
                                         , 'N');
g_use_ledger_security VARCHAR2(1) := NVL(  fnd_profile.value
                                            ('XLA_USE_LEDGER_SECURITY')
                                         , 'N');
g_access_set_id       NUMBER(15)  := NVL(  fnd_profile.value('GL_ACCESS_SET_ID')
                                         , -1);
g_sec_access_set_id   NUMBER(15)  := NVL(  fnd_profile.value
                                            ('XLA_GL_SECONDARY_ACCESS_SET_ID')
                                         , -1);

g_log_level           NUMBER;
g_log_enabled         BOOLEAN;

ValidationError       EXCEPTION;
NoAccountingDateError EXCEPTION;
AccountingError       EXCEPTION;
MissingCCIDError      EXCEPTION;
BalanceError          EXCEPTION;
LastRequestRunning    EXCEPTION;

PROCEDURE delete_je(
    p_application_id            IN INTEGER
    , p_event_id                  IN INTEGER);

PROCEDURE process_accounting_mapping(
        p_application_id       IN NUMBER
        ,p_event_id       IN NUMBER);

PROCEDURE generate_headers(
        p_application_id       IN NUMBER
       ,p_reverse_header_desc  IN VARCHAR2
       ,p_accounting_mode      IN VARCHAR2
);
PROCEDURE process_incomplete_acct_map(
        p_application_id       IN NUMBER
        ,p_event_id            IN NUMBER
        ,p_event_merge_option    IN VARCHAR2
        ,p_entity_id             IN NUMBER
        ,p_merge_date            IN DATE
        ,p_merge_type            IN VARCHAR2
        ,p_old_site_id           IN NUMBER
        ,p_old_party_id          IN NUMBER
        ,p_new_site_id           IN NUMBER
        ,p_new_party_id          IN NUMBER
        ,p_party_type            IN VARCHAR2
        ,p_array_ledger_id       IN xla_accounting_cache_pkg.t_array_ledger_id
        ,p_array_ledger_category IN t_varchar30_array
        ,p_array_reversal_option IN t_varchar30_array
        ,p_array_merge_option    IN t_varchar30_array);

PROCEDURE trace
 (  p_msg                       IN VARCHAR2
  , p_level                     IN NUMBER
  , p_module                    IN VARCHAR2 DEFAULT C_DEFAULT_MODULE) IS
BEGIN
   IF (p_msg IS NULL AND p_level >= g_log_level)
   THEN
      fnd_log.message(p_level, p_module);
   ELSIF p_level >= g_log_level
   THEN
      fnd_log.string(p_level, p_module, p_msg);
   END IF;
END trace;

PROCEDURE user_log
 (p_msg                         IN VARCHAR2) IS
BEGIN
   fnd_file.put_line(fnd_file.log, p_msg);
END user_log;

--=============================================================================
--          *********** public procedures and functions **********
--=============================================================================

-- ----------------------------------------------------------------------------
-- Create third party merge accounting routine - called by SRS
-- ----------------------------------------------------------------------------
PROCEDURE third_party_merge
 (  x_errbuf                    OUT NOCOPY VARCHAR2
  , x_retcode                   OUT NOCOPY VARCHAR2
  , x_event_ids                 OUT NOCOPY xla_third_party_merge_pub.t_event_ids
  , x_request_id                OUT NOCOPY INTEGER
  , p_source_application_id     IN INTEGER DEFAULT NULL
  , p_application_id            IN INTEGER
  , p_ledger_id                 IN INTEGER DEFAULT NULL
  , p_third_party_merge_date    IN DATE
  , p_third_party_type          IN VARCHAR2
  , p_original_third_party_id   IN INTEGER
  , p_original_site_id          IN INTEGER DEFAULT NULL
  , p_new_third_party_id        IN INTEGER
  , p_new_site_id               IN INTEGER DEFAULT NULL
  , p_type_of_third_party_merge IN VARCHAR2
  , p_mapping_flag              IN VARCHAR2
  , p_execution_mode            IN VARCHAR2
  , p_accounting_mode           IN VARCHAR2
  , p_transfer_to_gl_flag       IN VARCHAR2
  , p_post_in_gl_flag           IN VARCHAR2) IS

  v_function VARCHAR2(240);
  v_module   VARCHAR2(240);
  v_message  VARCHAR2(2000);
  v_dummy    VARCHAR2(1);

  v_application_name      VARCHAR2(240);
  v_valuation_method_flag VARCHAR2(1);
  v_rollback_flag         VARCHAR2(1);

  CURSOR ledger_cur IS
   SELECT DISTINCT opt.LEDGER_ID
   FROM XLA_LEDGER_OPTIONS opt,
        XLA_LEDGER_RELATIONSHIPS_V rs,
        gl_ledgers gl
   WHERE (p_ledger_id IS NULL OR opt.LEDGER_ID = p_ledger_id)
   AND opt.APPLICATION_ID = p_application_id
   AND opt.ENABLED_FLAG = 'Y'
   AND rs.LEDGER_ID = opt.LEDGER_ID
   AND (   rs.LEDGER_CATEGORY_CODE = 'PRIMARY'
        OR (rs.LEDGER_CATEGORY_CODE = 'SECONDARY'
            AND v_valuation_method_flag = 'Y'
            AND opt.CAPTURE_EVENT_FLAG = 'Y'))
   AND rs.RELATIONSHIP_ENABLED_FLAG = 'Y'
   AND rs.ledger_id = gl.ledger_id
   AND gl.complete_flag = 'Y'
   AND rs.SLA_ACCOUNTING_METHOD_CODE IS NOT NULL;

  v_ledger_id           NUMBER(15);
  v_entity_id           NUMBER(15);
  v_merge_event_set_id  NUMBER(15);
  v_event_id            NUMBER(15);
  -- v_max_event_number    NUMBER; commented for bug 9439643
  v_mapping_flag        VARCHAR2(1);
  v_event_count         NUMBER;
  v_access_count        NUMBER;
  v_row_count           NUMBER;

BEGIN

  -- --------------------------
  -- Initialize local variables
  -- --------------------------
  v_function      := 'xla_third_party_merge.third_party_merge';
  v_module        := C_DEFAULT_MODULE||'.third_party_merge';
  v_rollback_flag := 'N';
  v_event_count   := 0;
  v_access_count  := 0;

  IF (C_LEVEL_PROCEDURE >= g_log_level)
  THEN
    -- Log the function entry
    trace(  p_msg    => 'BEGIN - ' || v_function
          , p_level  => C_LEVEL_PROCEDURE
          , p_module => v_module);
    -- List the parameters and their passed values
    trace(  p_msg    => 'p_source_application_id = ' || p_source_application_id
                         || ', p_applicaiton_id = ' || p_application_id
                         || ', p_ledger_id = ' || p_ledger_id
                         || ', p_third_party_merge_date = '
                             || p_third_party_merge_date
                             || ', p_third_party_type = ' || p_third_party_type
          , p_level  => C_LEVEL_PROCEDURE
          , p_module => v_module);
    trace(  p_msg    => 'p_original_third_party_id = '
                             || p_original_third_party_id
                                                 || ', p_original_site_id = ' || p_original_site_id
                         || ', p_new_third_party_id = ' || p_new_third_party_id
                         || ', p_new_site_id = ' || p_new_site_id
                         || ', p_type_of_third_party_merge = '
                             || p_type_of_third_party_merge
          , p_level  => C_LEVEL_PROCEDURE
          , p_module => v_module);
    trace(  p_msg    => 'p_mapping_flag = ' || p_mapping_flag
                             || ', p_execution_mode = ' || p_execution_mode
                             || ', p_accounting_mode = ' || p_accounting_mode
                         || ', p_transfer_to_gl_flag = '
                                                 || p_transfer_to_gl_flag
                         || ', p_post_in_gl_flag = ' || p_post_in_gl_flag
          , p_level  => C_LEVEL_PROCEDURE
          , p_module => v_module);
  END IF; -- IF (C_LEVEL_PROCEDURE >= g_log_level)

  -- -----------------------
  -- Validate the parameters
  -- -----------------------

  -- Validate if the passed application is defined in XLA_SUBLEDGERS
  BEGIN
        SELECT f.APPLICATION_NAME, s.VALUATION_METHOD_FLAG
    INTO v_application_name, v_valuation_method_flag
    FROM XLA_SUBLEDGERS s, FND_APPLICATION_VL f
    WHERE s.APPLICATION_ID = f.APPLICATION_ID
    AND s.APPLICATION_ID = p_application_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      v_message := xla_messages_pkg.get_message
                      (  p_appli_s_name => 'XLA'
                       , p_msg_name     => 'XLA_MERGE_INVALID_PARAM'
                       , p_token_1      => 'PARAMETER_VALUE'
                       , p_value_1      => p_application_id
                       , p_token_2      => 'PARAMETER'
                       , p_value_2      => 'p_application_id');
      RAISE ValidationError;
  END;

  -- Log values of v_valuation_method_flag, g_use_ledger_security,
  -- g_access_set_id, and g_sec_access_set_id
  trace(  p_msg    => 'v_valuation_method_flag = ' || v_valuation_method_flag
                       || ', g_use_ledger_security = ' || g_use_ledger_security
                       || ', g_access_set_id = ' || g_access_set_id
                       || ', g_sec_access_set_id = ' || g_sec_access_set_id
        , p_level  => C_LEVEL_STATEMENT
        , p_module => v_module);

  -- Validate the ledger if it is passed
  IF (p_ledger_id IS NOT NULL)
  THEN
    BEGIN
      SELECT 'X'
      INTO v_dummy
      FROM XLA_LEDGER_OPTIONS opt,
           XLA_LEDGER_RELATIONSHIPS_V rs,
           gl_ledgers gl
      WHERE opt.LEDGER_ID = p_ledger_id
      AND opt.APPLICATION_ID = p_application_id
      AND opt.ENABLED_FLAG = 'Y'
      AND rs.LEDGER_ID = opt.LEDGER_ID
      AND (   rs.LEDGER_CATEGORY_CODE = 'PRIMARY'
           OR (rs.LEDGER_CATEGORY_CODE = 'SECONDARY'
               AND v_valuation_method_flag = 'Y'
                           AND opt.CAPTURE_EVENT_FLAG = 'Y'))
      AND rs.RELATIONSHIP_ENABLED_FLAG = 'Y'
      AND rs.ledger_id = gl.ledger_id
      AND gl.complete_flag = 'Y'
      AND rs.SLA_ACCOUNTING_METHOD_CODE IS NOT NULL;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_message := xla_messages_pkg.get_message
                      (  p_appli_s_name => 'XLA'
                       , p_msg_name     => 'XLA_MERGE_INVALID_PARAM'
                       , p_token_1      => 'PARAMETER_VALUE'
                       , p_value_1      => p_ledger_id
                       , p_token_2      => 'PARAMETER'
                       , p_value_2      => 'p_ledger_id');
        RAISE ValidationError;
    END;
  END IF; -- IF (p_ledger_id IS NOT NULL)

  -- Validate the third party merge date is passed
  IF (p_third_party_merge_date IS NULL)
  THEN
    v_message := xla_messages_pkg.get_message
                  (  p_appli_s_name => 'XLA'
                   , p_msg_name     => 'XLA_MERGE_INVALID_PARAM'
                   , p_token_1      => 'PARAMETER_VALUE'
                   , p_value_1      => ''''||p_third_party_merge_date||''''
                   , p_token_2      => 'PARAMETER'
                   , p_value_2      => 'p_third_party_merge_date');
    RAISE ValidationError;
  END IF; -- IF (p_third_party_merge_date IS NULL)

  -- Validate the passed third party type
  IF (p_third_party_type <> 'C' AND p_third_party_type <> 'S')
  THEN
    v_message := xla_messages_pkg.get_message
                  (  p_appli_s_name => 'XLA'
                   , p_msg_name     => 'XLA_MERGE_INVALID_PARAM'
                   , p_token_1      => 'PARAMETER_VALUE'
                   , p_value_1      => ''''||p_third_party_type||''''
                   , p_token_2      => 'PARAMETER'
                   , p_value_2      => 'p_third_party_type');
    RAISE ValidationError;
  END IF; -- IF (p_third_party_type <> 'C' AND p_third_party_type <> 'S')

  -- Validate the passed original third party
  BEGIN
    SELECT 'X'
    INTO v_dummy
    FROM XLA_THIRD_PARTIES_V
    WHERE THIRD_PARTY_ID = p_original_third_party_id
    AND THIRD_PARTY_TYPE = p_third_party_type;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      v_message := xla_messages_pkg.get_message
                    (  p_appli_s_name => 'XLA'
                     , p_msg_name     => 'XLA_MERGE_INVALID_PARAM'
                     , p_token_1      => 'PARAMETER_VALUE'
                     , p_value_1      => p_original_third_party_id
                     , p_token_2      => 'PARAMETER'
                     , p_value_2      => 'p_original_third_party_id');
      RAISE ValidationError;
  END;

  -- Validate the passed new third party
  BEGIN
    SELECT 'X'
    INTO v_dummy
    FROM XLA_THIRD_PARTIES_V
    WHERE THIRD_PARTY_ID = p_new_third_party_id
    AND THIRD_PARTY_TYPE = p_third_party_type;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      v_message := xla_messages_pkg.get_message
                    (  p_appli_s_name => 'XLA'
                     , p_msg_name     => 'XLA_MERGE_INVALID_PARAM'
                     , p_token_1      => 'PARAMETER_VALUE'
                     , p_value_1      => p_new_third_party_id
                     , p_token_2      => 'PARAMETER'
                     , p_value_2      => 'p_new_third_party_id');
      RAISE ValidationError;
  END;

  IF (p_original_site_id IS NOT NULL)
  THEN
    -- Validate the new site is passed if the original site is passed
    IF (p_new_site_id IS NULL)
    THEN
      v_message := xla_messages_pkg.get_message
                    (  p_appli_s_name => 'XLA'
                     , p_msg_name     => 'XLA_MERGE_SITE_ERR');
      RAISE ValidationError;
    END IF; -- IF (p_new_site_id IS NULL)

    -- Validate the passed original third party site
    BEGIN
      SELECT 'X'
      INTO v_dummy
      FROM XLA_THIRD_PARTY_SITES_V
      WHERE THIRD_PARTY_ID = p_original_third_party_id
      AND THIRD_PARTY_SITE_ID = p_original_site_id
      AND THIRD_PARTY_TYPE = p_third_party_type
      AND ROWNUM = 1; -- May return multiple sites (e.g. different ship tos)
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_message := xla_messages_pkg.get_message
                      (  p_appli_s_name => 'XLA'
                       , p_msg_name     => 'XLA_MERGE_INVALID_PARAM'
                       , p_token_1      => 'PARAMETER_VALUE'
                       , p_value_1      => p_original_site_id
                       , p_token_2      => 'PARAMETER'
                       , p_value_2      => 'p_original_site_id');
        RAISE ValidationError;
    END;

    -- Validate the passed new third party site
    BEGIN
      SELECT 'X'
      INTO v_dummy
      FROM XLA_THIRD_PARTY_SITES_V
      WHERE THIRD_PARTY_ID = p_new_third_party_id
      AND THIRD_PARTY_SITE_ID = p_new_site_id
      AND THIRD_PARTY_TYPE = p_third_party_type
      AND ROWNUM = 1; -- May return multiple sites (e.g. different ship tos)
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_message := xla_messages_pkg.get_message
                      (  p_appli_s_name => 'XLA'
                       , p_msg_name     => 'XLA_MERGE_INVALID_PARAM'
                       , p_token_1      => 'PARAMETER_VALUE'
                       , p_value_1      => p_new_site_id
                       , p_token_2      => 'PARAMETER'
                       , p_value_2      => 'p_new_site_id');
        RAISE ValidationError;
    END;

  END IF; -- IF (p_original_site_id IS NOT NULL)

  -- Validate the passed third party merge type
  IF (p_type_of_third_party_merge <> 'FULL'
      AND p_type_of_third_party_merge <> 'PARTIAL')
  THEN
    v_message := xla_messages_pkg.get_message
                  (  p_appli_s_name => 'XLA'
                   , p_msg_name     => 'XLA_MERGE_INVALID_PARAM'
                   , p_token_1      => 'PARAMETER_VALUE'
                   , p_value_1      => ''''||p_type_of_third_party_merge||''''
                   , p_token_2      => 'PARAMETER'
                   , p_value_2      => 'p_type_of_third_party_merge');
    RAISE ValidationError;
  END IF; -- IF (p_type_of_third_party_merge <> 'FULL' AND ...

  IF (p_mapping_flag = 'Y')
  THEN
    -- Validate only one segment code is provided per application/ledger/COA
    BEGIN
      SELECT 'Y'
      INTO v_dummy
      FROM XLA_MERGE_SEG_MAPS_GT
      HAVING COUNT(DISTINCT SEGMENT_CODE) > 1
      GROUP BY APPLICATION_ID, LEDGER_ID, CHART_OF_ACCOUNTS_ID;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_dummy := 'N';
    END;

    IF (v_dummy = 'Y')
    THEN
      -- The segment code is not unqiue per applicaiton/ledger
      v_message := xla_messages_pkg.get_message
                    (  p_appli_s_name => 'XLA'
                     , p_msg_name     => 'XLA_MERGE_MAPPING_ERR');
      RAISE ValidationError;
    END IF; -- IF (v_dummy = 'Y')

  END IF; -- IF (p_mapping_flag = 'Y')

  -- Validate the passed execution mode
  IF (p_execution_mode <> 'ASYNC_NOREQ' AND p_execution_mode <> 'ASYNC_REQ'
                                        AND p_execution_mode <> 'SYNC')
  THEN
    v_message := xla_messages_pkg.get_message
                  (  p_appli_s_name => 'XLA'
                   , p_msg_name     => 'XLA_MERGE_INVALID_PARAM'
                   , p_token_1      => 'PARAMETER_VALUE'
                   , p_value_1      => ''''||p_execution_mode||''''
                   , p_token_2      => 'PARAMETER'
                   , p_value_2      => 'p_execution_mode');
    RAISE ValidationError;
  END IF; -- IF (p_execution_mode <> 'ASYNC_NOREQ' AND ...

  -- Record the save point before creating events
  SAVEPOINT BeforeLedgerCur;
  -- Set v_rollback_flag to 'Y' i.e. indicating rolllback is needed
  v_rollback_flag := 'Y';

  -- ----------------------------------------------------------
  -- Create third party merge event for each selected ledger(s)
  -- ----------------------------------------------------------

  -- Loop for each ledger to create third party merge event
  OPEN ledger_cur;
  LOOP
    FETCH ledger_cur INTO v_ledger_id;
    EXIT WHEN ledger_cur%NOTFOUND;

    -- Log the value of v_ledger_id
    trace(  p_msg    => 'v_ledger_id = ' || v_ledger_id
          , p_level  => C_LEVEL_STATEMENT
          , p_module => v_module);

    -- Find the Third Party Merge transaction entity for the passed
        -- application/selected ledger
    trace(  p_msg    => 'Find the Third Party Merge transaction entity'
          , p_level  => C_LEVEL_STATEMENT
          , p_module => v_module);
        v_dummy := 'N';
    BEGIN
      SELECT ENTITY_ID
      INTO v_entity_id
      FROM XLA_TRANSACTION_ENTITIES
      WHERE APPLICATION_ID = p_application_id
      AND LEDGER_ID = v_ledger_id
      AND ENTITY_CODE = 'THIRD_PARTY_MERGE'
      AND ROWNUM = 1;--added debug 9593919
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        -- Set the dummy flag to 'Y' to indicate creating a new entity
        v_dummy := 'Y';
    END;

    IF (v_dummy = 'Y')
    THEN
      -- We cannot find the entity for the passed application/selected ledger,
          -- so create one.
      trace(  p_msg    => 'Create a Third Party Merge transaction entity'
            , p_level  => C_LEVEL_STATEMENT
            , p_module => v_module);
      INSERT INTO XLA_TRANSACTION_ENTITIES
      ( ENTITY_ID, APPLICATION_ID, LEDGER_ID, ENTITY_CODE,
        SOURCE_APPLICATION_ID, CREATION_DATE, CREATED_BY,
        LAST_UPDATE_DATE, LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN)
      VALUES
       (XLA_TRANSACTION_ENTITIES_S.nextval,
        p_application_id,
        v_ledger_id,
        'THIRD_PARTY_MERGE',
        NVL(p_source_application_id, p_application_id),
        sysdate,
        XLA_ENVIRONMENT_PKG.g_usr_id,
        sysdate,
        XLA_ENVIRONMENT_PKG.g_usr_id,
        XLA_ENVIRONMENT_PKG.g_login_id)
      RETURNING ENTITY_ID INTO v_entity_id;
      -- It's a new transaciton entity, so the maximum event number must be 0
    --  v_max_event_number := 0;  commented for bug 9439643

    ELSE
      -- We do find the entity for the passed application/selected ledger,
          -- so find its maximum event number
    /*  commented bug 9439643 fetch event number from event id sequence
    trace(  p_msg    => 'Find the maximum event number'
            , p_level  => C_LEVEL_STATEMENT
            , p_module => v_module);

      SELECT max(EVENT_NUMBER)
      INTO v_max_event_number
      FROM XLA_EVENTS
      WHERE ENTITY_ID = v_entity_id;

      IF(v_max_event_number is null) THEN
        v_max_event_number :=0;
      END IF; */
      null;

    END IF; -- IF (v_dummy = 'Y')

    -- Log the values of v_entity_id
    trace(  p_msg    => 'v_entity_id = ' || v_entity_id
          , p_level  => C_LEVEL_STATEMENT
          , p_module => v_module);

    v_mapping_flag := 'N';
    IF (p_mapping_flag = 'Y')
    THEN
      -- Check whether any mapping rows are inserted for the passed
      -- application/selected ledger. Its associated secondary ledgers will be
      -- checked if the valuation method flag is 'N' for the pased application.
      trace(  p_msg    => 'Check the mapping rows'
            , p_level  => C_LEVEL_STATEMENT
            , p_module => v_module);
      BEGIN
        SELECT 'Y'
        INTO v_mapping_flag
        FROM DUAL
        WHERE EXISTS
        (SELECT 'X'
         FROM XLA_LEDGER_RELATIONSHIPS_V rs,
              XLA_MERGE_SEG_MAPS_GT gt,
              gl_ledgers gld
         WHERE rs.RELATIONSHIP_ENABLED_FLAG = 'Y'
         AND rs.ledger_id = gld.ledger_id
         AND gld.complete_flag = 'Y'
         AND rs.SLA_ACCOUNTING_METHOD_CODE IS NOT NULL
         AND DECODE(v_valuation_method_flag
              , 'N', rs.PRIMARY_LEDGER_ID, rs.LEDGER_ID) = v_ledger_id
         AND rs.LEDGER_CATEGORY_CODE IN ('PRIMARY', 'SECONDARY')
         AND gt.APPLICATION_ID = p_application_id
         AND gt.LEDGER_ID = rs.LEDGER_ID);
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          v_mapping_flag := 'N';
      END;

      IF(v_mapping_flag = 'N') THEN
        v_message := xla_messages_pkg.get_message
                  (  p_appli_s_name => 'XLA'
                   , p_msg_name     => 'XLA_MERGE_NO_MAPPING');
        RAISE ValidationError;
      END IF;

      -- Log the values of v_mapping_flag
      trace(  p_msg    => 'v_mapping_flag = ' || v_mapping_flag
            , p_level  => C_LEVEL_STATEMENT
            , p_module => v_module);

    END IF; -- IF (p_mapping_flag = 'Y')

    -- Create the Third Party Merge event for the passed application/selected
    -- ledger
    trace(  p_msg    => 'Create the Third Party Merge event'
          , p_level  => C_LEVEL_STATEMENT
          , p_module => v_module);
    INSERT INTO XLA_EVENTS
    ( EVENT_ID, APPLICATION_ID, ENTITY_ID, EVENT_NUMBER,
      EVENT_TYPE_CODE, EVENT_DATE, EVENT_STATUS_CODE,
      PROCESS_STATUS_CODE, CREATION_DATE, CREATED_BY,
      LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN,
      PROGRAM_UPDATE_DATE, PROGRAM_APPLICATION_ID, PROGRAM_ID,
      REQUEST_ID, REFERENCE_NUM_1, REFERENCE_NUM_2, REFERENCE_NUM_3,
      REFERENCE_NUM_4, REFERENCE_CHAR_1, REFERENCE_CHAR_2,
      MERGE_EVENT_SET_ID, ON_HOLD_FLAG,
      TRANSACTION_DATE)
    VALUES
    ( XLA_EVENTS_S.nextval,
      p_application_id,
      v_entity_id,
      XLA_EVENTS_S.nextval ,  -- v_max_event_number + 1  commented for bug 9439643
      p_type_of_third_party_merge||'_MERGE',
      p_third_party_merge_date,
      'U',
      'U',
      sysdate,
      XLA_ENVIRONMENT_PKG.g_usr_id,
      sysdate,
      XLA_ENVIRONMENT_PKG.g_usr_id,
      XLA_ENVIRONMENT_PKG.g_login_id,
      sysdate,
      XLA_ENVIRONMENT_PKG.g_prog_appl_id,
      XLA_ENVIRONMENT_PKG.g_prog_id,
      XLA_ENVIRONMENT_PKG.g_req_id,
      p_original_third_party_id,
      p_original_site_id,
      p_new_third_party_id,
      p_new_site_id,
      p_third_party_type,
      v_mapping_flag,
      DECODE(v_event_count
       , 0, NULL, TO_CHAR(v_merge_event_set_id)),
      'N',
      p_third_party_merge_date)
    RETURNING EVENT_ID INTO v_event_id;

    -- Log the values of v_event_id
    trace(  p_msg    => 'v_event_id = ' || v_event_id
          , p_level  => C_LEVEL_STATEMENT
          , p_module => v_module);



    IF (v_mapping_flag = 'Y')
    THEN
      -- Populate the table XLA_MERGE_SEG_MAPS based on XLA_MERGE_SEG_MAPS_GT
      -- for this current event/associated ledgers
      trace(  p_msg    => 'Insert mapping rows'
            , p_level  => C_LEVEL_STATEMENT
            , p_module => v_module);
      INSERT INTO XLA_MERGE_SEG_MAPS
      ( APPLICATION_ID, LEDGER_ID, SEGMENT_CODE, FROM_VALUE,
        TO_VALUE, EVENT_ID, CHART_OF_ACCOUNTS_ID, CREATION_DATE,
        CREATED_BY, LAST_UPDATE_DATE, LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN, PROGRAM_UPDATE_DATE,
        PROGRAM_APPLICATION_ID)
      SELECT gt.APPLICATION_ID,
             gt.LEDGER_ID,
             gt.SEGMENT_CODE,
             gt.FROM_VALUE,
             gt.TO_VALUE,
             v_event_id,
             gt.CHART_OF_ACCOUNTS_ID,
             sysdate,
             XLA_ENVIRONMENT_PKG.g_usr_id,
             sysdate,
             XLA_ENVIRONMENT_PKG.g_usr_id,
             XLA_ENVIRONMENT_PKG.g_login_id,
             sysdate,
             XLA_ENVIRONMENT_PKG.g_prog_appl_id
      FROM XLA_LEDGER_RELATIONSHIPS_V rs,
           XLA_MERGE_SEG_MAPS_GT gt,
           GL_LEDGERS gl
      WHERE rs.RELATIONSHIP_ENABLED_FLAG = 'Y'
      AND rs.ledger_id = gl.ledger_id
      AND gl.complete_flag = 'Y'
      AND rs.SLA_ACCOUNTING_METHOD_CODE IS NOT NULL
      AND DECODE(v_valuation_method_flag
           , 'N', rs.PRIMARY_LEDGER_ID
                , rs.LEDGER_ID) = v_ledger_id
      AND rs.LEDGER_CATEGORY_CODE IN ('PRIMARY', 'SECONDARY')
      AND gt.APPLICATION_ID = p_application_id
      AND gt.LEDGER_ID = rs.LEDGER_ID;

      -- Log the number of rows inserted
      trace(  p_msg    => 'Insert ' || SQL%ROWCOUNT
                               || ' rows into XLA_MERGE_SEG_MAPS'
            , p_level  => C_LEVEL_STATEMENT
            , p_module => v_module);

    END IF; -- IF (v_mapping_flag = 'Y')

    IF (p_type_of_third_party_merge = 'PARTIAL')
    THEN
      -- Populate the table XLA_PARTIAL_MERGE_TXNS based on XLA_EVENTS_GT for
      -- this current event
      trace(  p_msg    => 'Insert partial transactions'
            , p_level  => C_LEVEL_STATEMENT
            , p_module => v_module);
      INSERT INTO XLA_PARTIAL_MERGE_TXNS
      ( APPLICATION_ID, MERGE_EVENT_ID, ENTITY_ID, ENTITY_CODE,
        SOURCE_ID_INT_1, SOURCE_ID_INT_2, SOURCE_ID_INT_3,
        SOURCE_ID_INT_4, SOURCE_ID_CHAR_1, SOURCE_ID_CHAR_2,
        SOURCE_ID_CHAR_3, SOURCE_ID_CHAR_4, VALUATION_METHOD,
        CREATION_DATE, CREATED_BY, LAST_UPDATE_DATE,
        LAST_UPDATED_BY, LAST_UPDATE_LOGIN, PROGRAM_UPDATE_DATE,
        PROGRAM_APPLICATION_ID, PROGRAM_ID, REQUEST_ID)
      SELECT DISTINCT
             gt.APPLICATION_ID,
             v_event_id,
             ent.ENTITY_ID,
             gt.ENTITY_CODE,
             gt.SOURCE_ID_INT_1,
             gt.SOURCE_ID_INT_2,
             gt.SOURCE_ID_INT_3,
             gt.SOURCE_ID_INT_4,
             gt.SOURCE_ID_CHAR_1,
             gt.SOURCE_ID_CHAR_2,
             gt.SOURCE_ID_CHAR_3,
             gt.SOURCE_ID_CHAR_4,
             gt.VALUATION_METHOD,
             sysdate,
             XLA_ENVIRONMENT_PKG.g_usr_id,
             sysdate,
             XLA_ENVIRONMENT_PKG.g_usr_id,
             XLA_ENVIRONMENT_PKG.g_login_id,
             sysdate,
             XLA_ENVIRONMENT_PKG.g_prog_appl_id,
             XLA_ENVIRONMENT_PKG.g_prog_id,
             XLA_ENVIRONMENT_PKG.g_req_id
      FROM XLA_EVENTS_GT gt,
           XLA_TRANSACTION_ENTITIES ent
      WHERE gt.APPLICATION_ID = p_application_id
      AND gt.LEDGER_ID = v_ledger_id
      AND ent.APPLICATION_ID = gt.APPLICATION_ID
      AND ent.LEDGER_ID = gt.LEDGER_ID
      AND ent.ENTITY_CODE = gt.ENTITY_CODE
      AND NVL(ent.VALUATION_METHOD,' ') = NVL(gt.VALUATION_METHOD,' ')
      AND NVL(ent.SOURCE_ID_INT_1,-99) = NVL(gt.SOURCE_ID_INT_1,-99)
      AND NVL(ent.SOURCE_ID_INT_2,-99) = NVL(gt.SOURCE_ID_INT_2,-99)
      AND NVL(ent.SOURCE_ID_INT_3,-99) = NVL(gt.SOURCE_ID_INT_3,-99)
      AND NVL(ent.SOURCE_ID_INT_4,-99) = NVL(gt.SOURCE_ID_INT_4,-99)
      AND NVL(ent.SOURCE_ID_CHAR_1,' ') = NVL(gt.SOURCE_ID_CHAR_1,' ')
      AND NVL(ent.SOURCE_ID_CHAR_2,' ') = NVL(gt.SOURCE_ID_CHAR_2,' ')
      AND NVL(ent.SOURCE_ID_CHAR_3,' ') = NVL(gt.SOURCE_ID_CHAR_3,' ')
      AND NVL(ent.SOURCE_ID_CHAR_4,' ') = NVL(gt.SOURCE_ID_CHAR_4,' ');

      -- Log the number of rows inserted
      v_row_count := SQL%ROWCOUNT;
      trace(  p_msg    => 'Insert ' || to_char(v_row_count)
                                || ' rows into XLA_PARTIAL_MERGE_TXNS'
            , p_level  => C_LEVEL_STATEMENT
            , p_module => v_module);
      IF(v_row_count = 0) THEN
        v_message := xla_messages_pkg.get_message
                  (  p_appli_s_name => 'XLA'
                   , p_msg_name     => 'XLA_MERGE_NO_TRX_SET');
        RAISE ValidationError;
      END IF;

    END IF; -- IF (p_type_of_third_party_merge = 'PARTIAL')

    IF (p_execution_mode <> 'ASYNC_NOREQ')
    THEN
      IF (g_use_ledger_security = 'Y')
      THEN
        -- Check if the user has the access to create accounting for this event
        trace(  p_msg    => 'Check user access'
              , p_level  => C_LEVEL_STATEMENT
              , p_module => v_module);
        BEGIN
          SELECT 'Y'
          INTO v_dummy
          FROM DUAL
          WHERE EXISTS
           (SELECT 'Ledger without access'
            FROM XLA_LEDGER_OPTIONS opt,
                 XLA_LEDGER_RELATIONSHIPS_V rs,
                 GL_LEDGERS gld
            WHERE opt.APPLICATION_ID = p_application_id
            AND opt.ENABLED_FLAG = 'Y'
            AND opt.MERGE_ACCT_OPTION_CODE <> 'NONE'
            AND DECODE(rs.LEDGER_CATEGORY_CODE
                 , 'ALC', rs.PRIMARY_LEDGER_ID
                        , rs.LEDGER_ID) = opt.LEDGER_ID
            AND rs.RELATIONSHIP_ENABLED_FLAG = 'Y'
            AND rs.ledger_id = gld.ledger_id
            AND gld.complete_flag = 'Y'
            AND rs.SLA_ACCOUNTING_METHOD_CODE IS NOT NULL
            AND DECODE(v_valuation_method_flag
                 , 'N', rs.PRIMARY_LEDGER_ID
                      , DECODE(rs.LEDGER_CATEGORY_CODE
                         , 'ALC', rs.PRIMARY_LEDGER_ID
                                , rs.LEDGER_ID)) = v_ledger_id
            AND rs.LEDGER_ID NOT IN
             (SELECT asa.LEDGER_ID
                FROM GL_ACCESS_SET_ASSIGNMENTS asa
               WHERE asa.ACCESS_SET_ID
                      IN (g_access_set_id,
                          g_sec_access_set_id)));
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            -- Increment access count by 1
            v_access_count := v_access_count + 1;
        END;

      ELSE
        -- Increment access count by 1
        v_access_count := v_access_count + 1;

      END IF; -- IF (g_use_ledger_security = 'Y')

    END IF; -- IF (p_execution_mode <> 'ASYNC_NOREQ')

    -- Increment event count by 1
    v_event_count := v_event_count + 1;

    -- Store the just created event ID to event ID list
    trace(  p_msg    => 'Store just created event ID to x_event_ids'
          , p_level  => C_LEVEL_STATEMENT
          , p_module => v_module);
    x_event_ids(v_event_count) := v_event_id;

    -- Check if this is the first event created
    IF (v_event_count = 1)
    THEN
      -- Set the merge event set ID as the first event ID
      v_merge_event_set_id := v_event_id;
      -- Log the value of v_ledger_id
      trace(  p_msg    => 'v_merge_event_set_id = ' || v_merge_event_set_id
            , p_level  => C_LEVEL_STATEMENT
            , p_module => v_module);

      -- Populate the merge event set ID to the first event
      trace(  p_msg    => 'Populate the merge event set ID to the first event'
            , p_level  => C_LEVEL_STATEMENT
            , p_module => v_module);
      UPDATE XLA_EVENTS
      SET MERGE_EVENT_SET_ID = TO_CHAR(v_merge_event_set_id)
      WHERE EVENT_ID = v_merge_event_set_id;

    END IF; -- IF (v_event_count = 1)

  END LOOP; -- End of ledger_cur loop

  -- Log the values of v_access_count and v_event_count
  trace(  p_msg    => 'v_access_count = ' || v_access_count
                       || ', v_event_count = ' || v_event_count
        , p_level  => C_LEVEL_STATEMENT
        , p_module => v_module);

  IF (v_event_count = 0)
  THEN
    -- No events are created
    v_message := xla_messages_pkg.get_message
                  (  p_appli_s_name => 'XLA'
                   , p_msg_name     => 'XLA_MERGE_NO_LG_ERR'
                   , p_token_1      => 'SUBLEDGER_APPLICATION_NAME'
                   , p_value_1      => v_application_name);
    RAISE ValidationError;
  END IF; -- IF (v_event_count = 0)

  -- Check if we need to create accounting for just created events
  IF (v_access_count > 0)
  THEN

        -- Set v_event_id to NULL if there are more than 1 events created
        IF (v_merge_event_set_id IS NOT NULL)
        THEN
      v_event_id := NULL;
    END IF; -- IF (v_merge_event_set_id IS NOT NULL)

    IF (p_execution_mode = 'SYNC')
    THEN
      -- If the execution mode is 'SYNC', call API to create accounting for just
      -- create third party merge events
      trace(  p_msg    => 'Call xla_third_party_merge.create_accounting()'
            , p_level  => C_LEVEL_STATEMENT
            , p_module => v_module);
      xla_third_party_merge.create_accounting
       (  x_errbuf              => x_errbuf
        , x_retcode             => x_retcode
        , p_application_id      => p_application_id
        , p_event_id            => v_event_id
        , p_accounting_mode     => p_accounting_mode
        , p_transfer_to_gl_flag => p_transfer_to_gl_flag
        , p_post_in_gl_flag     => p_post_in_gl_flag
        , p_merge_event_set_id  => v_merge_event_set_id
        , p_srs_flag            => 'N');

          -- If the return code is 'E' or 'U', raise AccountingError exception
      IF (x_retcode = xla_third_party_merge_pub.G_RET_STS_ERROR OR
              x_retcode = xla_third_party_merge_pub.G_RET_STS_UNEXP_ERROR)
      THEN
            RAISE AccountingError;
      END IF; -- IF (x_retcode = xla_third_party_merge_pub.G_RET_STS_ERROR ...

    ELSIF (p_execution_mode = 'ASYNC_REQ')
    THEN
      -- If the execution mode is 'ASYNC_REQ', call API to submit the concurrent
          -- program, Create Third Party Merge Accounting
      trace(  p_msg    => 'Call fnd_request.submit_request()'
            , p_level  => C_LEVEL_STATEMENT
            , p_module => v_module);
      x_request_id := fnd_request.submit_request
                           (  'XLA'
                        , 'XLAMERGEACCT'
                        , ''
                        , ''
                        , FALSE
                        , p_application_id
                                                , v_event_id
                                                , p_accounting_mode
                                                , p_transfer_to_gl_flag
                                                , p_post_in_gl_flag
                                                , v_merge_event_set_id);
    END IF; -- IF (p_execution_mode = 'SYNC')

  END IF; -- IF (v_access_count > 0)

  -- Set the return code to 'S'
  x_retcode := xla_third_party_merge_pub.G_RET_STS_SUCCESS;

  -- Log the out parameters, their returned values and the function exit
  IF (C_LEVEL_PROCEDURE >= g_log_level)
  THEN
    trace(  p_msg    => 'x_retcode = ' || x_retcode
                         || ', x_errbuf = ' || x_errbuf
          , p_level  => C_LEVEL_PROCEDURE
          , p_module => v_module);
    trace(  p_msg    => 'x_request_id = ' || x_request_id
                         || ', x_event_ids.COUNT = ' || x_event_ids.COUNT
          , p_level  => C_LEVEL_PROCEDURE
          , p_module => v_module);
    -- Log the function exit
    trace(  p_msg    => 'END - ' || v_function
          , p_level  => C_LEVEL_PROCEDURE
          , p_module => v_module);

  END IF; -- IF (C_LEVEL_PROCEDURE >= g_log_level)

EXCEPTION
  WHEN ValidationError THEN
    -- Log the error message
    trace(  p_msg    => v_message
          , p_level  => C_LEVEL_ERROR
          , p_module => v_module);
    -- Set the out parameters
    x_errbuf := xla_messages_pkg.get_message
                 (  p_appli_s_name => 'XLA'
                  , p_msg_name     => 'XLA_MERGE_FATAL_ERR'
                  , p_token_1      => 'FUNCTION'
                  , p_value_1      => v_function
                  , p_token_2      => 'ERROR'
                  , p_value_2      => v_message);
    x_retcode := xla_third_party_merge_pub.G_RET_STS_ERROR;
    -- Log the out parameters, their returned values and the function exit
    IF (C_LEVEL_PROCEDURE >= g_log_level)
    THEN
      trace(  p_msg    => 'x_retcode = ' || x_retcode
                           || ', x_errbuf = ' || x_errbuf
            , p_level  => C_LEVEL_PROCEDURE
            , p_module => v_module);
      trace(  p_msg    => 'x_request_id = ' || x_request_id
                           || ', x_event_ids.COUNT = ' || x_event_ids.COUNT
            , p_level  => C_LEVEL_PROCEDURE
            , p_module => v_module);
      -- Log the function exit
      trace(  p_msg    => 'EXIT with ERROR - ' || v_function
            , p_level  => C_LEVEL_PROCEDURE
            , p_module => v_module);
    END IF; -- IF (C_LEVEL_PROCEDURE >= g_log_level)

  WHEN AccountingError THEN
    -- Rollback to the save point before creating events
    ROLLBACK TO BeforeLedgerCur;
    -- Log the out parameters, their returned values and the function exit
    IF (C_LEVEL_PROCEDURE >= g_log_level)
    THEN
      trace(  p_msg    => 'x_retcode = ' || x_retcode
                           || ', x_errbuf = ' || x_errbuf
            , p_level  => C_LEVEL_PROCEDURE
            , p_module => v_module);
      trace(  p_msg    => 'x_request_id = ' || x_request_id
                           || ', x_event_ids.COUNT = ' || x_event_ids.COUNT
            , p_level  => C_LEVEL_PROCEDURE
            , p_module => v_module);
      -- Log the function exit
      trace(  p_msg    => 'EXIT with ERROR - ' || v_function
            , p_level  => C_LEVEL_PROCEDURE
            , p_module => v_module);
    END IF; -- IF (C_LEVEL_PROCEDURE >= g_log_level)

  WHEN OTHERS THEN
    -- Rollback to the save point before creating events if necessary
    IF (v_rollback_flag = 'Y')
    THEN
      ROLLBACK to BeforeLedgerCur;
    END IF;
    -- Get and log the SQL error message
    v_message := SQLERRM;
    trace(  p_msg    => v_message
          , p_level  => C_LEVEL_UNEXPECTED
          , p_module => v_module);
    -- Set the out parameters
    x_errbuf := xla_messages_pkg.get_message
                 (  p_appli_s_name => 'XLA'
                  , p_msg_name     => 'XLA_MERGE_FATAL_ERR'
                  , p_token_1      => 'FUNCTION'
                  , p_value_1      => v_function
                  , p_token_2      => 'ERROR'
                  , p_value_2      => v_message);
    x_retcode := xla_third_party_merge_pub.G_RET_STS_UNEXP_ERROR;
    -- Log the out parameters, their returned values and the function exit
    IF (C_LEVEL_PROCEDURE >= g_log_level)
    THEN
      trace(  p_msg    => 'x_retcode = ' || x_retcode
                           || ', x_errbuf = ' || x_errbuf
            , p_level  => C_LEVEL_PROCEDURE
            , p_module => v_module);
      trace(  p_msg    => 'x_request_id = ' || x_request_id
                           || ', x_event_ids.COUNT = ' || x_event_ids.COUNT
            , p_level  => C_LEVEL_PROCEDURE
            , p_module => v_module);
      -- Log the function exit
      trace(  p_msg    => 'EXIT with ERROR - ' || v_function
            , p_level  => C_LEVEL_PROCEDURE
            , p_module => v_module);
    END IF; -- IF (C_LEVEL_PROCEDURE >= g_log_level)

END third_party_merge;

PROCEDURE get_line_number(
                 p_array_ledger_id           IN xla_accounting_cache_pkg.t_array_ledger_id
                 ,p_array_rounding_rule_code IN t_varchar30_array
                 ,p_array_mau                IN t_number_array
) IS
--
l_ae_line_num   NUMBER;
l_ae_header_id  NUMBER;
l_log_module         VARCHAR2(240);
--
l_array_rowid        t_rowid_array;
l_array_rowid1        t_rowid_array;
l_array_ae_line_num  t_number_array;
l_array_doc_rounding_amt1   t_number_array;
l_array_rounding_entd_amt1   t_number_array;
l_array_ledger_id    xla_accounting_cache_pkg.t_array_ledger_id;
l_array_header_id    t_number_array;

l_rounding_rule_code VARCHAR2(30);
l_array_rounding_rule_code t_varchar30_array;
l_array_mau              t_number_array;
l_array_rounding_class_code  t_varchar30_array;
l_array_doc_rounding_level   t_varchar30_array;
l_array_unrounded_amount        t_number_array;
l_array_unrounded_entd_amount   t_number_array;
l_array_entd_mau                t_number_array;

l_curr_rounding_class_code VARCHAR2(30);
l_curr_doc_rounding_level  VARCHAR2(30);
l_curr_doc_rounding_amount NUMBER;
l_curr_entd_rounding_amount NUMBER;
l_curr_total_unrounded     NUMBER;
l_curr_total_rounded       NUMBER;
l_curr_entd_total_unrounded     NUMBER;
l_curr_entd_total_rounded       NUMBER;
l_curr_max_rowid           ROWID;
l_curr_max_amount          NUMBER;
l_curr_ledger_id           NUMBER;
l_curr_header_id           NUMBER;
l_curr_mau                 NUMBER;
l_curr_entd_mau            NUMBER;
l_curr_rounding_rule_code  VARCHAR2(30);
j                          NUMBER;
l_temp                 NUMBER;


l_count             NUMBER :=1;

CURSOR csr_set_linenum is
  select rowid, dense_rank() over (partition by ae_header_id
                                    order by line_hash_num, merge_index) ae_line_num
                   from xla_ae_lines_gt;

CURSOR csr_rounding_lines is
    SELECT max(xalg.rowid)
       ,rounding_class_code
       ,document_rounding_level
       ,NVL(SUM(unrounded_accounted_cr), 0)
                - NVL(SUM(unrounded_accounted_dr), 0) unrounded_amount
       ,ledger_id
       ,ae_header_id
       ,NVL(SUM(unrounded_entered_cr), 0)
                - NVL(SUM(unrounded_entered_dr), 0) unrounded_entered_amount
       ,entered_currency_mau
    FROM xla_ae_lines_gt xalg
    WHERE temp_line_num <> 0
    GROUP BY ledger_id, event_id, ae_header_id,
         rounding_class_code, document_rounding_level, ae_line_num
         ,entered_currency_mau
    HAVING document_rounding_level is not null
       AND rounding_class_code is not null
    ORDER BY document_rounding_level, rounding_class_code;


BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.get_line_number';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of get_line_number'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;

For i in 1..p_array_ledger_id.COUNT LOOP
  l_array_mau(p_array_ledger_id(i)) := p_array_mau(i);
  l_array_rounding_rule_code(p_array_ledger_id(i)) := p_array_rounding_rule_code(i);
END LOOP;

BEGIN

  UPDATE xla_ae_lines_gt ael
    set line_hash_num =
    DBMS_UTILITY.GET_HASH_VALUE
        (ae_header_id
        ||accounting_class_code
        ||rounding_class_code
        ||document_rounding_level
        ||currency_code
        ||currency_conversion_type
        ||currency_conversion_date
        ||currency_conversion_rate
        ||party_id
        ||party_site_id
        ||party_type_code
        ||code_combination_id
        ||description
        ||jgzz_recon_ref
        ||ussgl_transaction_code
        ||merge_duplicate_code
        ||encumbrance_type_id,
       1,
       1073741824)
    ,merge_index = CASE merge_duplicate_code
                   WHEN 'A' THEN
                     CASE switch_side_flag
                     WHEN 'Y' THEN -1
                     ELSE
                       CASE
                       WHEN accounted_cr is null THEN -2
                       ELSE -3
                       END
                     END
                   WHEN 'W' THEN
                     CASE
                     WHEN accounted_cr is null THEN -2
                     ELSE -3
                     END
                   WHEN 'N' THEN temp_line_num
                   END;

  open csr_set_linenum;
  LOOP
    FETCH csr_set_linenum
    BULK COLLECT INTO l_array_rowid, l_array_ae_line_num
    LIMIT C_BULK_LIMIT;

    IF(l_array_rowid.COUNT=0) THEN
      EXIT;
    END IF;

    FORALL i IN 1..l_array_rowid.count
      UPDATE xla_ae_lines_gt
         SET ae_line_num = l_array_ae_line_num(i)
       WHERE rowid = l_array_rowid(i);
  END LOOP;
  Close csr_set_linenum;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN

    trace
         (p_msg      => 'SQL - Update xla_ae_lines_gt 3'
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

  END IF;

  open csr_rounding_lines;
  j:=1;
  l_curr_rounding_class_code := null;
  l_curr_doc_rounding_level := null;
  l_curr_total_unrounded :=null;
  l_curr_total_rounded :=null;
  l_curr_max_rowid :=null;
  l_curr_max_amount := null;
  l_curr_ledger_id :=null;
  l_curr_header_id :=null;
  l_curr_mau := null;
  l_curr_entd_mau := null;
  l_curr_rounding_rule_code := null;
  l_curr_entd_rounding_amount := null;
  l_curr_entd_total_unrounded :=null;
  l_curr_entd_total_rounded :=null;

  LOOP
    FETCH csr_rounding_lines
    BULK COLLECT INTO l_array_rowid
                   ,l_array_rounding_class_code
                   ,l_array_doc_rounding_level
                   ,l_array_unrounded_amount
                   ,l_array_ledger_id
                   ,l_array_header_id
                   ,l_array_unrounded_entd_amount
                   ,l_array_entd_mau
    LIMIT C_BULK_LIMIT;

    IF(l_array_rounding_class_code.COUNT=0) THEN
      EXIT;
    END IF;
    IF (C_LEVEL_STATEMENT >= g_log_level) THEN
        trace
           (p_msg      => 'SQL - Update xla_ae_lines_gt 6'
           ,p_level    => C_LEVEL_STATEMENT
           ,p_module   => l_log_module);
        trace
           (p_msg      => 'count:'||to_char(l_array_rounding_class_code.count)
           ,p_level    => C_LEVEL_STATEMENT
           ,p_module   => l_log_module);
    END IF;

    FOR Idx IN l_array_rounding_class_code.FIRST .. l_array_rounding_class_code.LAST LOOP
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
        trace
           (p_msg      => 'Ixd:'||to_char(Idx) ||' rounding class code:'||l_array_rounding_class_code(Idx) || ' rounding level:'||l_array_doc_rounding_level(Idx)
                             || ' ledgerid:'||to_char(l_array_ledger_id(Idx))||' unrounded:'|| to_char(l_curr_total_unrounded)
                             ||' rounded:'|| to_char(l_curr_total_rounded)
           ,p_level    => C_LEVEL_STATEMENT
           ,p_module   => l_log_module);
        trace
           (p_msg      => 'amount:'||to_char(l_array_unrounded_amount(Idx))||'curr mau:'||to_char(l_curr_mau)||' curr rule code:'||l_curr_rounding_rule_code
           ,p_level    => C_LEVEL_STATEMENT
           ,p_module   => l_log_module);
        trace
           (p_msg      => 'cur rounding class code:'||l_curr_rounding_class_code || ' rounding level:'||l_curr_doc_rounding_level || ' ledgerid:'||to_char(l_curr_ledger_id)
           ,p_level    => C_LEVEL_STATEMENT
           ,p_module   => l_log_module);
        trace
           (p_msg      => ' unrounded entered:'|| to_char(l_curr_entd_total_unrounded)
                             ||' rounded entered:'|| to_char(l_curr_entd_total_rounded)
                             ||' amount:'|| to_char(l_array_unrounded_entd_amount(Idx))
                             ||' mau:'|| to_char(l_array_entd_mau(Idx))
           ,p_level    => C_LEVEL_STATEMENT
           ,p_module   => l_log_module);
      END IF;

      IF(l_array_rounding_class_code(Idx) = l_curr_rounding_class_code
           AND l_array_doc_rounding_level(Idx) = l_curr_doc_rounding_level
           AND  l_array_header_id(Idx) = l_curr_header_id
           AND  l_array_ledger_id(Idx) = l_curr_ledger_id) THEN
        l_curr_total_unrounded:= l_curr_total_unrounded + l_array_unrounded_amount(Idx);
        IF(l_curr_rounding_rule_code = 'UP') THEN
          l_temp    := CEIL( l_array_unrounded_amount(Idx)/l_curr_mau);
        ELSIF (l_curr_rounding_rule_code = 'DOWN') THEN
          l_temp    := FLOOR( l_array_unrounded_amount(Idx)/l_curr_mau);
        ELSE
          l_temp    := ROUND( l_array_unrounded_amount(Idx)/l_curr_mau);
        END IF;
        l_curr_total_rounded:= l_curr_total_rounded +l_temp *l_curr_mau;
        l_curr_entd_total_unrounded:= l_curr_entd_total_unrounded + l_array_unrounded_entd_amount(Idx);
        IF(l_curr_rounding_rule_code = 'UP') THEN
          l_temp    := CEIL(l_array_unrounded_entd_amount(Idx)/l_array_entd_mau(Idx));
        ELSIF (l_curr_rounding_rule_code = 'DOWN') THEN
          l_temp    := FLOOR(l_array_unrounded_entd_amount(Idx)/l_array_entd_mau(Idx));
        ELSE
          l_temp    := ROUND(l_array_unrounded_entd_amount(Idx)/l_array_entd_mau(Idx));
        END IF;

        l_curr_entd_total_rounded:= l_curr_entd_total_rounded
                             +l_temp *l_array_entd_mau(Idx);
        IF(l_curr_max_amount < ABS(l_array_unrounded_amount(Idx))) THEN
          l_curr_max_amount := ABS(l_array_unrounded_amount(Idx));
          l_curr_max_rowid := l_array_rowid(Idx);
        END IF;
      ELSE
        IF(l_curr_total_unrounded is not null) THEN
          IF(l_curr_rounding_rule_code = 'UP') THEN
            l_temp    := CEIL(l_curr_total_unrounded/l_curr_mau);
          ELSIF (l_curr_rounding_rule_code = 'DOWN') THEN
            l_temp    := FLOOR(l_curr_total_unrounded/l_curr_mau);
          ELSE
            l_temp    := ROUND(l_curr_total_unrounded/l_curr_mau);
          END IF;

          l_curr_doc_rounding_amount := l_temp *l_curr_mau -l_curr_total_rounded;
          IF(l_curr_rounding_rule_code = 'UP') THEN
            l_temp    := CEIL(l_curr_entd_total_unrounded/l_curr_entd_mau);
          ELSIF (l_curr_rounding_rule_code = 'DOWN') THEN
            l_temp    := FLOOR(l_curr_entd_total_unrounded/l_curr_entd_mau);
          ELSE
            l_temp    := ROUND(l_curr_entd_total_unrounded/l_curr_entd_mau);
          END IF;
          l_curr_entd_rounding_amount := l_temp *l_curr_entd_mau
                             -l_curr_entd_total_rounded;
          IF (C_LEVEL_STATEMENT >= g_log_level) THEN
             trace
              (p_msg      => 'doc rounding is:'||to_char(l_curr_doc_rounding_amount)
                             ||' unrounded:'|| to_char(l_curr_total_unrounded)
                             ||' rounded:'|| to_char(l_curr_total_rounded)
              ,p_level    => C_LEVEL_STATEMENT
              ,p_module   => l_log_module);
             trace
              (p_msg      => 'entd rounding is:'||to_char(l_curr_entd_rounding_amount)
                             ||' unrounded:'|| to_char(l_curr_entd_total_unrounded)
                             ||' rounded:'|| to_char(l_curr_entd_total_rounded)
              ,p_level    => C_LEVEL_STATEMENT
              ,p_module   => l_log_module);
          END IF;
          IF(l_curr_doc_rounding_amount <>0 or l_curr_entd_rounding_amount <> 0) THEN
            l_array_rowid1(j):= l_curr_max_rowid;
            l_array_doc_rounding_amt1(j) := l_curr_doc_rounding_amount;
            l_array_rounding_entd_amt1(j) := l_curr_entd_rounding_amount;
            j:= j+1;
            IF (j> C_BULK_LIMIT) THEN
              FORALL i in 1..j-1
                update xla_ae_lines_gt
                   set doc_rounding_acctd_amt = l_array_doc_rounding_amt1(i)
                      ,doc_rounding_entered_amt = l_array_rounding_entd_amt1(i)
                where rowid = l_array_rowid1(i);
              j:=1;
            END IF;
          END IF;
        END IF;
        IF(l_curr_ledger_id is null or
               l_curr_ledger_id <> l_array_ledger_id(Idx)) THEN
          l_curr_ledger_id :=l_array_ledger_id(Idx);
          l_curr_mau := l_array_mau(l_curr_ledger_id);
          l_curr_rounding_rule_code:= l_array_rounding_rule_code(l_curr_ledger_id);
        END IF;
        l_curr_entd_mau:=l_array_entd_mau(Idx);
        l_curr_header_id :=l_array_header_id(Idx);
        l_curr_rounding_class_code := l_array_rounding_class_code(Idx);
        l_curr_doc_rounding_level := l_array_doc_rounding_level(Idx);
        l_curr_total_unrounded:= l_array_unrounded_amount(Idx);
        IF(l_curr_rounding_rule_code = 'UP') THEN
          l_temp    := CEIL(l_array_unrounded_amount(Idx)/l_curr_mau);
        ELSIF (l_curr_rounding_rule_code = 'DOWN') THEN
          l_temp    := FLOOR(l_array_unrounded_amount(Idx)/l_curr_mau);
        ELSE
          l_temp    := ROUND(l_array_unrounded_amount(Idx)/l_curr_mau);
        END IF;

        l_curr_total_rounded:= l_temp *l_curr_mau;
        l_curr_entd_total_unrounded:= l_array_unrounded_entd_amount(Idx);
          IF (C_LEVEL_STATEMENT >= g_log_level) THEN
             trace
              (p_msg      => '----l_curr_entd_total_rounded:'||to_char(l_curr_entd_total_rounded)
                             ||' l_array_unrounded_entd_amount(Idx):'|| to_char(l_array_unrounded_entd_amount(Idx))
                             ||' l_curr_entd_mau:'|| to_char(l_curr_entd_mau)
                             ||'l_curr_rounding_rule_code:'|| l_curr_rounding_rule_code
              ,p_level    => C_LEVEL_STATEMENT
              ,p_module   => l_log_module);
          END IF;
        IF(l_curr_rounding_rule_code = 'UP') THEN
          l_temp    := CEIL(l_array_unrounded_entd_amount(Idx)/l_curr_entd_mau);
        ELSIF (l_curr_rounding_rule_code = 'DOWN') THEN
          l_temp    := FLOOR(l_array_unrounded_entd_amount(Idx)/l_curr_entd_mau);
        ELSE
          l_temp    := ROUND(l_array_unrounded_entd_amount(Idx)/l_curr_entd_mau);
        END IF;

        l_curr_entd_total_rounded:= l_temp *l_curr_entd_mau;
          IF (C_LEVEL_STATEMENT >= g_log_level) THEN
             trace
              (p_msg      => '----l_curr_entd_total_rounded:'||to_char(l_curr_entd_total_rounded)
                             ||' l_array_unrounded_entd_amount(Idx):'|| to_char(l_array_unrounded_entd_amount(Idx))
                             ||' l_curr_entd_mau:'|| to_char(l_curr_entd_mau)
                             ||'l_curr_rounding_rule_code:'|| l_curr_rounding_rule_code
              ,p_level    => C_LEVEL_STATEMENT
              ,p_module   => l_log_module);
          END IF;
        l_curr_max_rowid := l_array_rowid(Idx);
        l_curr_max_amount := ABS(l_array_unrounded_amount(Idx));
      END IF;
    END LOOP;
  END LOOP;
  -- process the last one
  IF(l_curr_total_unrounded is not null) THEN
    IF(l_curr_rounding_rule_code = 'UP') THEN
      l_temp    := CEIL(l_curr_total_unrounded/l_curr_mau);
    ELSIF (l_curr_rounding_rule_code = 'DOWN') THEN
      l_temp    := FLOOR(l_curr_total_unrounded/l_curr_mau);
    ELSE
      l_temp    := ROUND(l_curr_total_unrounded/l_curr_mau);
    END IF;
    l_curr_doc_rounding_amount :=  l_temp
               *l_curr_mau -l_curr_total_rounded;
    IF(l_curr_rounding_rule_code = 'UP') THEN
      l_temp    := CEIL(l_curr_entd_total_unrounded/l_curr_entd_mau);
    ELSIF (l_curr_rounding_rule_code = 'DOWN') THEN
      l_temp    := FLOOR(l_curr_entd_total_unrounded/l_curr_entd_mau);
    ELSE
      l_temp    := ROUND(l_curr_entd_total_unrounded/l_curr_entd_mau);
    END IF;
    l_curr_entd_rounding_amount := l_temp
               *l_curr_entd_mau -l_curr_entd_total_rounded;
    IF (C_LEVEL_STATEMENT >= g_log_level) THEN
           trace
              (p_msg      => 'doc rounding is:'||to_char(l_curr_doc_rounding_amount)
                             ||' unrounded:'|| to_char(l_curr_total_unrounded)
                             ||' rounded:'|| to_char(l_curr_total_rounded)
              ,p_level    => C_LEVEL_STATEMENT
              ,p_module   => l_log_module);
    END IF;
  END IF;
  IF(l_curr_doc_rounding_amount <>0  or l_curr_entd_rounding_amount <> 0) THEN
    l_array_rowid1(j):= l_curr_max_rowid;
    l_array_doc_rounding_amt1(j) := l_curr_doc_rounding_amount;
    l_array_rounding_entd_amt1(j) := l_curr_entd_rounding_amount;
    j:= j+1;
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
           (p_msg      => 'SQL - Update xla_ae_lines_gt 7, j='||to_char(j)
           ,p_level    => C_LEVEL_STATEMENT
           ,p_module   => l_log_module);
  END IF;

  IF j>1 THEN
    FORALL i in 1..j-1
      update xla_ae_lines_gt
         set doc_rounding_acctd_amt = l_array_doc_rounding_amt1(i)
            ,doc_rounding_entered_amt = l_array_rounding_entd_amt1(i)
       where rowid = l_array_rowid1(i);
  END IF;

  EXCEPTION
  WHEN OTHERS  THEN

    IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            (p_msg      => 'ERROR: XLA_AP_CANNOT_INSERT_JE ='||sqlerrm
            ,p_level    => C_LEVEL_EXCEPTION
            ,p_module   => l_log_module);
  END IF;

  xla_exceptions_pkg.raise_message  (p_appli_s_name => 'XLA'
                                    ,p_msg_name     => 'XLA_AP_CANNOT_INSERT_JE'
                                    ,p_token_1      => 'ERROR'
                                    ,p_value_1      => sqlerrm
                                    );
END;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of get_line_number'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  RAISE;
WHEN OTHERS  THEN
  xla_exceptions_pkg.raise_message
                (p_location => 'XLA_THIRD_PARTY_MERGE.get_line_number');
END get_line_number;

PROCEDURE insert_headers(
             p_batch_id         IN NUMBER
            ,p_application_id   IN NUMBER
            ,p_event_id         IN NUMBER
            ,p_accounting_mode  IN VARCHAR2)
IS
v_function VARCHAR2(240);
v_module   VARCHAR2(240);
BEGIN
  v_function              := 'xla_third_party_merge.insert_headers';
  v_module                := C_DEFAULT_MODULE||'.insert_headers';
  IF (C_LEVEL_PROCEDURE >= g_log_level)
  THEN
    trace(  p_msg    => 'BEGIN - ' || v_function
          , p_level  => C_LEVEL_PROCEDURE
          , p_module => v_module);
  END IF; -- IF (C_LEVEL_PROCEDURE >= g_log_level)
  INSERT INTO xla_ae_headers
  (
     ae_header_id
   , application_id
   , ledger_id
   , entity_id
   , event_id
   , event_type_code
   , accounting_date
   , gl_transfer_status_code
   , je_category_name
   , accounting_entry_status_code
   , accounting_entry_type_code
   , product_rule_type_code
   , product_rule_code
   , product_rule_version
   , description
   , creation_date
   , created_by
   , last_update_date
   , last_updated_by
   , last_update_login
   , doc_sequence_id
   , doc_sequence_value
   , doc_category_code
   , program_update_date
   , program_application_id
   , program_id
   , request_id
   , budget_version_id
   , balance_type_code
   , completed_date
   , period_name
   , accounting_batch_id
   , amb_context_code
   , zero_amount_flag
   , parent_ae_header_id   -- 4262811
   , parent_ae_line_num    -- 4262811
   , accrual_reversal_flag -- 4262811
   , merge_event_id
  )
  SELECT
           hed.ae_header_id
         , p_application_id
         , hed.ledger_id
         , hed.entity_id
         , hed.event_id
         , hed.event_type_code
         , hed.accounting_date
         , hed.gl_transfer_status_code
         , hed.je_category_name
         , hed.accounting_entry_status_code
         , hed.accounting_entry_type_code
         , hed.product_rule_type_code
         , hed.product_rule_code
         , hed.product_rule_version
         , hed.description
         , TRUNC(SYSDATE)
         , xla_environment_pkg.g_Usr_Id
         , TRUNC(SYSDATE)
         , xla_environment_pkg.g_Usr_Id
         , xla_environment_pkg.g_Login_Id
         , hed.doc_sequence_id
         , hed.doc_sequence_value
         , hed.doc_category_code
         , TRUNC(SYSDATE)
         , xla_environment_pkg.g_Prog_Appl_Id
         , xla_environment_pkg.g_Prog_Id
         , xla_environment_pkg.g_req_Id
         , CASE hed.balance_type_code
             WHEN 'B' THEN hed.budget_version_id
             ELSE NULL
           END
         , hed.balance_type_code
         , sysdate
         , hed.period_name
         , p_batch_id
         , hed.amb_context_code
         , 'N'
         , hed.parent_header_id      -- 4262811
         , hed.parent_ae_line_num    -- 4262811
         , hed.accrual_reversal_flag -- 4262811
         , p_event_id
          FROM xla_ae_headers_gt hed;

  IF (C_LEVEL_PROCEDURE >= g_log_level)
  THEN
    trace(  p_msg    => 'END - ' || v_function
            , p_level  => C_LEVEL_PROCEDURE
            , p_module => v_module);
  END IF; -- IF (C_LEVEL_PROCEDURE >= g_log_level)

END insert_headers;

PROCEDURE insert_links(p_application_id   IN NUMBER)

IS
v_function VARCHAR2(240);
v_module   VARCHAR2(240);
BEGIN
  v_function              := 'xla_third_party_merge.insert_links';
  v_module                := C_DEFAULT_MODULE||'.insert_links';
  IF (C_LEVEL_PROCEDURE >= g_log_level)
  THEN
    trace(  p_msg    => 'BEGIN - ' || v_function
          , p_level  => C_LEVEL_PROCEDURE
          , p_module => v_module);
  END IF; -- IF (C_LEVEL_PROCEDURE >= g_log_level)

  INSERT INTO xla_distribution_links
    (
       application_id
     , event_id
     , source_distribution_id_char_1
     , source_distribution_id_char_2
     , source_distribution_id_char_3
     , source_distribution_id_char_4
     , source_distribution_id_char_5
     , source_distribution_id_num_1
     , source_distribution_id_num_2
     , source_distribution_id_num_3
     , source_distribution_id_num_4
     , source_distribution_id_num_5
     , source_distribution_type
     , unrounded_entered_cr
     , unrounded_entered_dr
     , unrounded_accounted_cr
     , unrounded_accounted_dr
     , ae_header_id
     , ae_line_num
     , temp_line_num
     , tax_line_ref_id
     , tax_summary_line_ref_id
     , tax_rec_nrec_dist_ref_id
     , statistical_amount
     , event_class_code
     , event_type_code
     , line_definition_owner_code
     , line_definition_code
     , accounting_line_type_code
     , accounting_line_code
     , ref_event_id
     , ref_ae_header_id
     , ref_temp_line_num
     , merge_duplicate_code
     , calculate_acctd_amts_flag
     , calculate_g_l_amts_flag
     , rounding_class_code
     , document_rounding_level
     , doc_rounding_acctd_amt
     , doc_rounding_entered_amt
    )
    SELECT
          p_application_id
        , event_id
        , source_distribution_id_char_1
        , source_distribution_id_char_2
        , source_distribution_id_char_3
        , source_distribution_id_char_4
        , source_distribution_id_char_5
        , source_distribution_id_num_1
        , source_distribution_id_num_2
        , source_distribution_id_num_3
        , source_distribution_id_num_4
        , source_distribution_id_num_5
        , source_distribution_type
        , unrounded_entered_cr
        , unrounded_entered_dr
        , unrounded_accounted_cr
        , unrounded_accounted_dr
        , ae_header_id
        , ae_line_num
        , temp_line_num
        , tax_line_ref_id
        , tax_summary_line_ref_id
        , tax_rec_nrec_dist_ref_id
        , statistical_amount
        , event_class_code
        , event_type_code
        , line_definition_owner_code
        , line_definition_code
        , accounting_line_type_code
        , accounting_line_code
        , ref_event_id
        , ref_ae_header_id
        , ref_temp_line_num
        , merge_duplicate_code
        , calculate_acctd_amts_flag
        , calculate_g_l_amts_flag
        , rounding_class_code
        , document_rounding_level
        , doc_rounding_acctd_amt
        , doc_rounding_entered_amt
    FROM xla_ae_lines_gt;

  IF (C_LEVEL_PROCEDURE >= g_log_level)
  THEN
    trace(  p_msg    => 'END - ' || v_function
            , p_level  => C_LEVEL_PROCEDURE
            , p_module => v_module);
  END IF; -- IF (C_LEVEL_PROCEDURE >= g_log_level)

END insert_links;

PROCEDURE insert_lines(p_application_id         IN INTEGER
                 ,p_array_ledger_id       IN xla_accounting_cache_pkg.t_array_ledger_id
                 ,p_array_reversal_option IN t_varchar30_array
                 ,p_array_mau             IN t_number_array
                 ,p_array_rounding_rule   IN t_varchar30_array
) IS
l_count number;
v_query_str          VARCHAR2(8000);

v_function VARCHAR2(240);
v_module   VARCHAR2(240);
BEGIN
  v_function              := 'xla_third_party_merge.insert_lines';
  v_module                := C_DEFAULT_MODULE||'.insert_lines';
  IF (C_LEVEL_PROCEDURE >= g_log_level)
  THEN
    trace(  p_msg    => 'BEGIN - ' || v_function
          , p_level  => C_LEVEL_PROCEDURE
          , p_module => v_module);
  END IF; -- IF (C_LEVEL_PROCEDURE >= g_log_level)

  FORALL i in 1..p_array_ledger_id.count
  INSERT INTO xla_ae_lines
  (
     ae_header_id
   , ae_line_num
   , displayed_line_number
   , code_combination_id
   , gl_transfer_mode_code
   , creation_date
   , accounted_cr
   , accounted_dr
   , unrounded_accounted_cr
   , unrounded_accounted_dr
   , gain_or_loss_flag
   , accounting_class_code
   , currency_code
   , currency_conversion_date
   , currency_conversion_rate
   , currency_conversion_type
   , description
   , entered_cr
   , entered_dr
   , unrounded_entered_cr
   , unrounded_entered_dr
   , last_update_date
   , last_update_login
   , party_id
   , party_site_id
   , party_type_code
   , statistical_amount
   , ussgl_transaction_code
   , created_by
   , last_updated_by
   , jgzz_recon_ref
   , program_update_date
   , program_application_id
   , program_id
   , application_id
   , request_id
   , gl_sl_link_table
   , business_class_code    -- 4336173
   , mpa_accrual_entry_flag -- 4262811
   , encumbrance_type_id    -- 4458381 Public Sector Enh
   , accounting_date
   , ledger_id
   , control_balance_flag
   , gl_sl_link_id          --5041325
  )
 (SELECT
     ae_header_id
   , ae_line_num
   , displayed_line_number
   , code_combination_id
   , gl_transfer_mode_code
   , creation_date
   , accounted_cr
   , accounted_dr
   , unrounded_accounted_cr
   , unrounded_accounted_dr
   , gain_or_loss_flag
   , accounting_class_code
   , currency_code
   , currency_conversion_date
   , currency_conversion_rate
   , currency_conversion_type
   , description
   , entered_cr
   , entered_dr
   , unrounded_entered_cr
   , unrounded_entered_dr
   , last_update_date
   , last_update_login
   , party_id
   , party_site_id
   , party_type_code
   , statistical_amount
   , ussgl_transaction_code
   , created_by
   , last_updated_by
   , jgzz_recon_ref
   , program_update_date
   , program_application_id
   , program_id
   , application_id
   , request_id
   , gl_sl_link_table
   , business_class_code    -- 4336173
   , mpa_accrual_entry_flag -- 4262811
   , encumbrance_type_id    -- 4458381 Public Sector Enh
   , accounting_date
   , ledger_id
   , alt_segment1
   , Decode(accounting_entry_status_code,'F',xla_gl_sl_link_id_s.nextval,NULL)
  FROM
  (SELECT
     lin.ae_header_id  ae_header_id
   , ae_line_num
-- we always treat switch_side_flag as 'Y' since we can't get the original switch_side_flag any more
   ,
     ROW_NUMBER()
        over (PARTITION BY ae_header_id
              order by
               ABS (
                  NVL(SUM(unrounded_accounted_cr),0) - NVL(SUM(unrounded_accounted_dr),0)+
                  NVL(SUM(doc_rounding_acctd_amt), 0)
                )
         desc) displayed_line_number
   , code_combination_id
   , 'N'  gl_transfer_mode_code
   , sysdate  creation_date
-- accounted_cr
-- no need to take care of the case that both accounted dr and cr are null.
-- this can't happen in third party merge
   ,
     CASE p_array_reversal_option(i)
     WHEN 'SIDE' THEN
         CASE SIGN(
                  NVL(SUM(unrounded_accounted_cr),0) - NVL(SUM(unrounded_accounted_dr),0)+
                  NVL(SUM(doc_rounding_acctd_amt), 0)
                )
         WHEN -1 THEN null
         WHEN 1 THEN
            DECODE(p_array_rounding_rule(i)
                ,'UP', CEIL((NVL(SUM(unrounded_accounted_cr),0)
                              - NVL(SUM(unrounded_accounted_dr),0)
                              + NVL(SUM(doc_rounding_acctd_amt), 0))
                             /p_array_mau(i))
                ,'DOWN', FLOOR((NVL(SUM(unrounded_accounted_cr),0)
                              - NVL(SUM(unrounded_accounted_dr),0)
                              + NVL(SUM(doc_rounding_acctd_amt), 0))
                             /p_array_mau(i))
                ,ROUND((NVL(SUM(unrounded_accounted_cr),0)
                              - NVL(SUM(unrounded_accounted_dr),0)
                              + NVL(SUM(doc_rounding_acctd_amt), 0))
                             /p_array_mau(i))
                )*p_array_mau(i)
         ELSE
           CASE SIGN(NVL(SUM(unrounded_entered_cr),0) - NVL(SUM(unrounded_entered_dr),0)+
                  NVL(SUM(doc_rounding_entered_amt), 0))
           WHEN -1 THEN null
           ELSE 0
           END
         END
     ELSE
         CASE SIGN(
                  NVL(SUM(unrounded_accounted_cr),0) - NVL(SUM(unrounded_accounted_dr),0)+
                  NVL(SUM(doc_rounding_acctd_amt), 0)
                )
         WHEN 1 THEN null
         WHEN -1 THEN
            DECODE(p_array_rounding_rule(i)
                ,'UP', CEIL((NVL(SUM(unrounded_accounted_cr),0)
                              - NVL(SUM(unrounded_accounted_dr),0)
                              + NVL(SUM(doc_rounding_acctd_amt), 0))
                             /p_array_mau(i))
                ,'DOWN', FLOOR((NVL(SUM(unrounded_accounted_cr),0)
                              - NVL(SUM(unrounded_accounted_dr),0)
                              + NVL(SUM(doc_rounding_acctd_amt), 0))
                             /p_array_mau(i))
                ,ROUND((NVL(SUM(unrounded_accounted_cr),0)
                              - NVL(SUM(unrounded_accounted_dr),0)
                              + NVL(SUM(doc_rounding_acctd_amt), 0))
                             /p_array_mau(i))
                )*p_array_mau(i)
         ELSE
           CASE SIGN(NVL(SUM(unrounded_entered_cr),0) - NVL(SUM(unrounded_entered_dr),0)+
                  NVL(SUM(doc_rounding_entered_amt), 0))
           WHEN 1 THEN null
           ELSE 0
           END
         END
       END
       accounted_cr
   -- accounted_dr
   ,
     CASE p_array_reversal_option(i)
     WHEN 'SIDE' THEN
       CASE SIGN(
                  NVL(SUM(unrounded_accounted_dr),0) - NVL(SUM(unrounded_accounted_cr),0)-
                  NVL(SUM(doc_rounding_acctd_amt), 0)
                )
       WHEN -1 THEN null
       WHEN 1 THEN
            DECODE(p_array_rounding_rule(i)
                ,'UP', CEIL((NVL(SUM(unrounded_accounted_dr),0)
                              - NVL(SUM(unrounded_accounted_cr),0)
                              - NVL(SUM(doc_rounding_acctd_amt), 0))
                             /p_array_mau(i))
                ,'DOWN', FLOOR((NVL(SUM(unrounded_accounted_dr),0)
                              - NVL(SUM(unrounded_accounted_cr),0)
                              - NVL(SUM(doc_rounding_acctd_amt), 0))
                             /p_array_mau(i))
                ,ROUND((NVL(SUM(unrounded_accounted_dr),0)
                              - NVL(SUM(unrounded_accounted_cr),0)
                              - NVL(SUM(doc_rounding_acctd_amt), 0))
                             /p_array_mau(i))
                )*p_array_mau(i)
       ELSE
         CASE SIGN(NVL(SUM(unrounded_entered_dr),0) - NVL(SUM(unrounded_entered_cr),0)-
                   NVL(SUM(doc_rounding_entered_amt), 0))
         WHEN 1 THEN 0
         ELSE null
         END
       END
     ELSE
       CASE SIGN(
                  NVL(SUM(unrounded_accounted_dr),0) - NVL(SUM(unrounded_accounted_cr),0)-
                  NVL(SUM(doc_rounding_acctd_amt), 0)
                )
       WHEN 1 THEN null
       WHEN -1 THEN
            DECODE(p_array_rounding_rule(i)
                ,'UP', CEIL((NVL(SUM(unrounded_accounted_dr),0)
                              - NVL(SUM(unrounded_accounted_cr),0)
                              - NVL(SUM(doc_rounding_acctd_amt), 0))
                             /p_array_mau(i))
                ,'DOWN', FLOOR((NVL(SUM(unrounded_accounted_dr),0)
                              - NVL(SUM(unrounded_accounted_cr),0)
                              - NVL(SUM(doc_rounding_acctd_amt), 0))
                             /p_array_mau(i))
                ,ROUND((NVL(SUM(unrounded_accounted_dr),0)
                              - NVL(SUM(unrounded_accounted_cr),0)
                              - NVL(SUM(doc_rounding_acctd_amt), 0))
                             /p_array_mau(i))
                )*p_array_mau(i)
       ELSE
         CASE SIGN(NVL(SUM(unrounded_entered_dr),0) - NVL(SUM(unrounded_entered_cr),0)-
                   NVL(SUM(doc_rounding_entered_amt), 0))
         WHEN -1 THEN 0
         ELSE null
         END
       END
     END
     accounted_dr
   -- unrounded_accounted_cr
   ,
     CASE p_array_reversal_option(i)
     WHEN 'SIDE' THEN
       CASE SIGN(NVL(SUM(unrounded_accounted_cr),0) - NVL(SUM(unrounded_accounted_dr),0))
       WHEN -1 THEN null
       WHEN 1 THEN
         NVL(SUM(unrounded_accounted_cr),0) - NVL(SUM(unrounded_accounted_dr),0)
       ELSE
         CASE SIGN(NVL(SUM(unrounded_entered_cr),0) - NVL(SUM(unrounded_entered_dr),0))
         WHEN -1 THEN null
         ELSE 0
         END
       END
     ELSE
       CASE SIGN(NVL(SUM(unrounded_accounted_cr),0) - NVL(SUM(unrounded_accounted_dr),0))
       WHEN 1 THEN null
       WHEN -1 THEN
         NVL(SUM(unrounded_accounted_cr),0) - NVL(SUM(unrounded_accounted_dr),0)
       ELSE
         CASE SIGN(NVL(SUM(unrounded_entered_cr),0) - NVL(SUM(unrounded_entered_dr),0))
         WHEN 1 THEN null
         ELSE 0
         END
       END
     END
     unrounded_accounted_cr
   -- unrounded_accounted_dr
   ,
     CASE p_array_reversal_option(i)
     WHEN 'SIDE' THEN
       CASE SIGN(NVL(SUM(unrounded_accounted_dr),0) - NVL(SUM(unrounded_accounted_cr),0))
       WHEN 1 THEN
         NVL(SUM(unrounded_accounted_dr),0) - NVL(SUM(unrounded_accounted_cr),0)
       WHEN -1 THEN null
       ELSE
         CASE SIGN(NVL(SUM(unrounded_entered_dr),0) - NVL(SUM(unrounded_entered_cr),0))
         WHEN 1 THEN 0
         ELSE null
         END
       END
     ELSE
       CASE SIGN(NVL(SUM(unrounded_accounted_dr),0) - NVL(SUM(unrounded_accounted_cr),0))
       WHEN -1 THEN
         NVL(SUM(unrounded_accounted_dr),0) - NVL(SUM(unrounded_accounted_cr),0)
       WHEN 1 THEN null
       ELSE
         CASE SIGN(NVL(SUM(unrounded_entered_dr),0) - NVL(SUM(unrounded_entered_cr),0))
         WHEN -1 THEN 0
         ELSE null
         END
       END
     END
     unrounded_accounted_dr
   , gain_or_loss_flag
   , accounting_class_code
   , currency_code
   , currency_conversion_date
   , currency_conversion_rate
   , currency_conversion_type
   , lin.description  description
   -- entered_cr
   ,
     CASE p_array_reversal_option(i)
     WHEN 'SIDE' THEN
         CASE SIGN(
                  NVL(SUM(unrounded_entered_cr),0) - NVL(SUM(unrounded_entered_dr),0)+
                  NVL(SUM(doc_rounding_entered_amt), 0)
                )
         WHEN -1 THEN null
         WHEN 1 THEN
              DECODE(p_array_rounding_rule(i)
                ,'UP', CEIL((NVL(SUM(unrounded_entered_cr),0)
                               - NVL(SUM(unrounded_entered_dr),0)
                               + NVL(SUM(doc_rounding_entered_amt), 0))
                             /entered_currency_mau)
                ,'DOWN', FLOOR((NVL(SUM(unrounded_entered_cr),0)
                               - NVL(SUM(unrounded_entered_dr),0)
                               + NVL(SUM(doc_rounding_entered_amt), 0))
                             /entered_currency_mau)
                ,ROUND((NVL(SUM(unrounded_entered_cr),0)
                               - NVL(SUM(unrounded_entered_dr),0)
                               + NVL(SUM(doc_rounding_entered_amt), 0))
                             /entered_currency_mau)
                )*entered_currency_mau
         ELSE
               CASE SIGN(NVL(SUM(unrounded_accounted_cr),0) - NVL(SUM(unrounded_accounted_dr),0)
                         +NVL(SUM(doc_rounding_acctd_amt), 0))
               WHEN -1 THEN null
               ELSE 0
               END
         END
     ELSE
         CASE SIGN(
                  NVL(SUM(unrounded_entered_cr),0) - NVL(SUM(unrounded_entered_dr),0)+
                  NVL(SUM(doc_rounding_entered_amt), 0)
                )
         WHEN 1 THEN null
         WHEN -1 THEN
              DECODE(p_array_rounding_rule(i)
                ,'UP', CEIL((NVL(SUM(unrounded_entered_cr),0)
                               - NVL(SUM(unrounded_entered_dr),0)
                               + NVL(SUM(doc_rounding_entered_amt), 0))
                             /entered_currency_mau)
                ,'DOWN', FLOOR((NVL(SUM(unrounded_entered_cr),0)
                               - NVL(SUM(unrounded_entered_dr),0)
                               + NVL(SUM(doc_rounding_entered_amt), 0))
                             /entered_currency_mau)
                ,ROUND((NVL(SUM(unrounded_entered_cr),0)
                               - NVL(SUM(unrounded_entered_dr),0)
                               + NVL(SUM(doc_rounding_entered_amt), 0))
                             /entered_currency_mau)
                )*entered_currency_mau
         ELSE
               CASE SIGN(NVL(SUM(unrounded_accounted_cr),0) - NVL(SUM(unrounded_accounted_dr),0)
                         +NVL(SUM(doc_rounding_acctd_amt), 0))
               WHEN 1 THEN null
               ELSE 0
               END
         END
     END
     entered_cr
   -- entered_dr
   ,
     CASE p_array_reversal_option(i)
     WHEN 'SIDE' THEN
       CASE SIGN(
                  NVL(SUM(unrounded_entered_dr),0) - NVL(SUM(unrounded_entered_cr),0)-
                  NVL(SUM(doc_rounding_entered_amt), 0)
                )
       WHEN -1 THEN null
       WHEN 1 THEN
            DECODE(p_array_rounding_rule(i)
                ,'UP', CEIL((NVL(SUM(unrounded_entered_dr),0)
                               - NVL(SUM(unrounded_entered_cr),0)
                               - NVL(SUM(doc_rounding_entered_amt), 0))
                             /entered_currency_mau)
                ,'DOWN', FLOOR((NVL(SUM(unrounded_entered_dr),0)
                               - NVL(SUM(unrounded_entered_cr),0)
                               - NVL(SUM(doc_rounding_entered_amt), 0))
                             /entered_currency_mau)
                ,ROUND((NVL(SUM(unrounded_entered_dr),0)
                               - NVL(SUM(unrounded_entered_cr),0)
                               - NVL(SUM(doc_rounding_entered_amt), 0))
                             /entered_currency_mau)
                )*entered_currency_mau
       ELSE
           CASE SIGN(NVL(SUM(unrounded_accounted_dr),0) - NVL(SUM(unrounded_accounted_cr),0)
                     -NVL(SUM(doc_rounding_acctd_amt), 0))
           WHEN 1 THEN 0
           ELSE null
           END
       END
     ELSE
       CASE SIGN(
                  NVL(SUM(unrounded_entered_dr),0) - NVL(SUM(unrounded_entered_cr),0)-
                  NVL(SUM(doc_rounding_entered_amt), 0)
                )
       WHEN 1 THEN null
       WHEN -1 THEN
            DECODE(p_array_rounding_rule(i)
                ,'UP', CEIL((NVL(SUM(unrounded_entered_dr),0)
                               - NVL(SUM(unrounded_entered_cr),0)
                               - NVL(SUM(doc_rounding_entered_amt), 0))
                             /entered_currency_mau)
                ,'DOWN', FLOOR((NVL(SUM(unrounded_entered_dr),0)
                               - NVL(SUM(unrounded_entered_cr),0)
                               - NVL(SUM(doc_rounding_entered_amt), 0))
                             /entered_currency_mau)
                ,ROUND((NVL(SUM(unrounded_entered_dr),0)
                               - NVL(SUM(unrounded_entered_cr),0)
                               - NVL(SUM(doc_rounding_entered_amt), 0))
                             /entered_currency_mau)
                )*entered_currency_mau
       ELSE
           CASE SIGN(NVL(SUM(unrounded_accounted_dr),0) - NVL(SUM(unrounded_accounted_cr),0)
                     -NVL(SUM(doc_rounding_acctd_amt), 0))
           WHEN -1 THEN 0
           ELSE null
           END
       END
     END
     entered_dr
   -- unrounded_entered_cr
   ,
     CASE p_array_reversal_option(i)
     WHEN 'SIDE' THEN
       CASE SIGN(NVL(SUM(unrounded_entered_cr),0) - NVL(SUM(unrounded_entered_dr),0))
       WHEN -1 THEN null
       WHEN 1 THEN NVL(SUM(unrounded_entered_cr),0) - NVL(SUM(unrounded_entered_dr),0)
       ELSE
         CASE SIGN(NVL(SUM(unrounded_accounted_cr),0) - NVL(SUM(unrounded_accounted_dr),0))
         WHEN -1 THEN null
         ELSE 0
         END
       END
     ELSE
       CASE SIGN(NVL(SUM(unrounded_entered_cr),0) - NVL(SUM(unrounded_entered_dr),0))
       WHEN 1 THEN null
       WHEN -1 THEN NVL(SUM(unrounded_entered_cr),0) - NVL(SUM(unrounded_entered_dr),0)
       ELSE
         CASE SIGN(NVL(SUM(unrounded_accounted_cr),0) - NVL(SUM(unrounded_accounted_dr),0))
         WHEN 1 THEN null
         ELSE 0
         END
       END
     END
     unrounded_entered_cr
   -- unrounded_entered_dr
   ,
     CASE p_array_reversal_option(i)
     WHEN 'SIDE' THEN
       CASE SIGN(NVL(SUM(unrounded_entered_cr),0) - NVL(SUM(unrounded_entered_dr),0))
       WHEN 1 THEN null
       WHEN -1 THEN NVL(SUM(unrounded_entered_dr),0) - NVL(SUM(unrounded_entered_cr),0)
       ELSE
         CASE SIGN(NVL(SUM(unrounded_accounted_cr),0) - NVL(SUM(unrounded_accounted_dr),0))
         WHEN -1 THEN 0
         ELSE null
         END
       END
     ELSE
       CASE SIGN(NVL(SUM(unrounded_entered_cr),0) - NVL(SUM(unrounded_entered_dr),0))
       WHEN -1 THEN null
       WHEN 1 THEN NVL(SUM(unrounded_entered_dr),0) - NVL(SUM(unrounded_entered_cr),0)
       ELSE
         CASE SIGN(NVL(SUM(unrounded_accounted_cr),0) - NVL(SUM(unrounded_accounted_dr),0))
         WHEN 1 THEN 0
         ELSE null
         END
       END
     END unrounded_entered_dr
   , sysdate    last_update_date
   , XLA_ENVIRONMENT_PKG.g_login_id  last_update_login
   , party_id
   , party_site_id
   , party_type_code
   , sum(statistical_amount)  statistical_amount
   , ussgl_transaction_code
   , XLA_ENVIRONMENT_PKG.g_login_id  created_by
   , XLA_ENVIRONMENT_PKG.g_login_id  last_updated_by
   , jgzz_recon_ref
   , sysdate  program_update_date
   , XLA_ENVIRONMENT_PKG.g_prog_appl_id  program_application_id
   , XLA_ENVIRONMENT_PKG.g_prog_id  program_id
   , p_application_id   application_id
   , XLA_ENVIRONMENT_PKG.g_req_id  request_id
   , 'XLAJEL'     gl_sl_link_table
   , business_class_code    -- 4336173
   , mpa_accrual_entry_flag -- 4262811
   , encumbrance_type_id    -- 4458381 Public Sector Enh
   , accounting_date
   , ledger_id
   , alt_segment1
   , accounting_entry_status_code
  FROM xla_ae_lines_gt lin
  WHERE ledger_id = p_array_ledger_id(i)
    AND ae_line_num is not NULL
 GROUP BY lin.ae_header_id
        , ae_line_num
        , header_num                    -- 4262811c  MPA reversal lines
        , sysdate
        , XLA_ENVIRONMENT_PKG.g_login_id
        , XLA_ENVIRONMENT_PKG.g_prog_appl_id
        , XLA_ENVIRONMENT_PKG.g_prog_id
        , XLA_ENVIRONMENT_PKG.g_req_id
        , p_application_id
        , accounting_class_code
        , event_class_code
        , event_type_code
        , line_definition_owner_code
        , line_definition_code
        , entered_currency_mau
        , currency_code
        , currency_conversion_type
        , currency_conversion_date
        , currency_conversion_rate
        , party_id
        , party_site_id
        , party_type_code
        , code_combination_id
        , code_combination_status_code
        , lin.description
        , jgzz_recon_ref
        , ussgl_transaction_code
        , merge_duplicate_code
        , switch_side_flag
        , gain_or_loss_flag
        , lin.business_class_code    -- 4336173
        , lin.mpa_accrual_entry_flag -- 4262811
        , encumbrance_type_id -- 4458381 Public Sector Enh
        , accounting_date
        , ledger_id
        , alt_segment1
        , merge_index
                ,accounting_entry_status_code)
        );

  l_count := SQL%ROWCOUNT;
  IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace
         (p_msg      => '# journal entry lines inserted into xla_ae_lines = '||to_char(l_count)
         ,p_level    => C_LEVEL_EVENT
         ,p_module   => v_module);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'return value. = '||TO_CHAR(l_count)
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => v_module);


      trace
         (p_msg      => 'END of insert_lines'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => v_module);
  END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
       trace
           (p_msg      => 'Error. = '||sqlerrm
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => v_module);
  END IF;
  RAISE;
WHEN OTHERS  THEN
  IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
       trace
           (p_msg      => 'Error. = '||sqlerrm
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => v_module);
  END IF;
  xla_exceptions_pkg.raise_message
                (p_location => 'XLA_AE_JOURNAL_ENTRY_PKG.insert_lines');
END insert_lines;


PROCEDURE get_accounting_date(
         p_merge_date            IN DATE
        ,p_primary_ledger_id     IN NUMBER
        ,p_array_ledger_id       IN xla_accounting_cache_pkg.t_array_ledger_id
        ,p_array_ledger_category IN t_varchar30_array
        ,p_array_merge_option    IN t_varchar30_array
        ,p_gl_date               OUT NOCOPY t_date_array
        ,p_gl_period_name        OUT NOCOPY t_varchar30_array
        ,p_entry_status          OUT NOCOPY t_varchar1_array) IS
v_function VARCHAR2(240);
v_module   VARCHAR2(240);
v_gl_date  date := null;
v_gl_period_name VARCHAR2(30) := null;
v_entry_status   VARCHAR2(1) := 'F';
BEGIN
  v_function              := 'xla_third_party_merge.get_accounting_date';
  v_module                := C_DEFAULT_MODULE||'.get_accounting_date';
  IF (C_LEVEL_PROCEDURE >= g_log_level)
  THEN
    trace(  p_msg    => 'BEGIN - ' || v_function
          , p_level  => C_LEVEL_PROCEDURE
          , p_module => v_module);
    trace(  p_msg    => 'p_merge_date ' || to_char(p_merge_date)
          , p_level  => C_LEVEL_PROCEDURE
          , p_module => v_module);
  END IF; -- IF (C_LEVEL_PROCEDURE >= g_log_level)

  FOR i in 1 .. p_array_merge_option.count LOOP
    IF(p_array_merge_option(i) = 'TRANSFER') THEN
      IF(p_array_ledger_category(i) in ('PRIMARY', 'SECONDARY')) THEN
        SELECT period_name, start_date, decode(closing_status, 'O', 'F', 'N', 'I', 'F', 'F')
          INTO p_gl_period_name(i), p_gl_date(i), p_entry_status(i)
          FROM gl_period_statuses
         WHERE ledger_id = p_array_ledger_id(i)
           AND application_id = 101
           AND end_date >= p_merge_date
           AND closing_status in ('O', 'F', 'N')
           AND start_date =
                 (SELECT min(start_date)
                    FROM gl_period_statuses
                   WHERE ledger_id = p_array_ledger_id(i)
                     AND application_id = 101
                     AND end_date >= p_merge_date
                     AND closing_status in ('O', 'F', 'N'));
        IF(p_merge_date > p_gl_date(i)) THEN
          p_gl_date(i) := p_merge_date;
        ELSIF(p_entry_status(i) = 'I') THEN
          RAISE NO_DATA_FOUND;
        END IF;
        IF(p_array_ledger_category(i) = 'PRIMARY') THEN
          v_gl_date := p_gl_date(i);
          v_gl_period_name :=p_gl_period_name(i);
          v_entry_status := p_entry_status(i);
        END IF;
      ELSE
        IF(v_gl_date is not null) THEN
          p_gl_date(i) := v_gl_date;
          p_gl_period_name(i) :=v_gl_period_name;
          p_entry_status(i) := v_entry_status;
        ELSE
          SELECT period_name, start_date, decode(closing_status, 'O', 'F', 'N', 'I', 'F', 'F')
            INTO p_gl_period_name(i), p_gl_date(i), p_entry_status(i)
            FROM gl_period_statuses
           WHERE ledger_id = p_array_ledger_id(i)
             AND application_id = 101
             AND end_date >= p_merge_date
             AND closing_status in ('O', 'F', 'N')
             AND start_date =
                   (SELECT min(start_date)
                      FROM gl_period_statuses
                     WHERE ledger_id = p_array_ledger_id(i)
                       AND application_id = 101
                       AND end_date >= p_merge_date
                       AND closing_status in ('O', 'F', 'N'));
          IF(p_merge_date > p_gl_date(i)) THEN
            p_gl_date(i) := p_merge_date;
          ELSIF(p_entry_status(i) = 'I') THEN
            RAISE NO_DATA_FOUND;
          END IF;
          v_gl_date := p_gl_date(i);
          v_gl_period_name :=p_gl_period_name(i);
          v_entry_status := p_entry_status(i);
        END IF;
      END IF;
    END IF;
  END LOOP;

  IF (C_LEVEL_PROCEDURE >= g_log_level)
  THEN
    trace(  p_msg    => 'END - ' || v_function
          , p_level  => C_LEVEL_PROCEDURE
          , p_module => v_module);
  END IF; -- IF (C_LEVEL_PROCEDURE >= g_log_level)

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    -- no accounting date is found
    raise;
  WHEN OTHERS THEN
    raise;
END get_accounting_date;

PROCEDURE create_work_table(
        p_request_id            IN NUMBER
        ,p_application_id        IN NUMBER
        ,p_event_id              IN NUMBER
        ,p_merge_date            IN DATE
        ,p_merge_type            IN VARCHAR2
        ,p_old_site_id           IN NUMBER
        ,p_old_party_id          IN NUMBER
        ,p_new_site_id           IN NUMBER
        ,p_new_party_id          IN NUMBER
        ,p_party_type            IN VARCHAR2
        ,p_array_ledger_id       IN xla_accounting_cache_pkg.t_array_ledger_id
        ,p_array_merge_option    IN t_varchar30_array
        ) is
CURSOR c_lastRunningReq is
  SELECT xtw.request_id
    FROM XLA_TPM_WORKING_HDRS_T xtw
         , fnd_concurrent_requests fcr
   WHERE xtw.merge_event_id = p_event_id
     AND xtw.process_type_flag in ('B', 'R')
     AND xtw.request_id = fcr.request_id
     AND fcr.phase_code IN ('R','P','I');
v_last_request_id   NUMBER := null;
v_function VARCHAR2(240);
v_module   VARCHAR2(240);
begin
  v_function              := 'xla_third_party_merge.create_work_table';
  v_module                := C_DEFAULT_MODULE||'.create_work_table';

  -- Log the function entry, the passed parameters and their values
  IF (C_LEVEL_PROCEDURE >= g_log_level)
  THEN
    trace(  p_msg    => 'BEGIN - ' || v_function
          , p_level  => C_LEVEL_PROCEDURE
          , p_module => v_module);
    trace(  p_msg    => ', p_merge_type = ' || p_merge_type
          , p_level  => C_LEVEL_PROCEDURE
          , p_module => v_module);
  END IF; -- IF (C_LEVEL_PROCEDURE >= g_log_level)

  open c_lastRunningReq;
  fetch c_lastRunningReq into v_last_request_id;
  close c_lastRunningReq;

  IF(v_last_request_id is not null) THEN
    IF (C_LEVEL_STATEMENT>= g_log_level)
    THEN
      trace(  p_msg    => 'old request id is  - ' || to_char(v_last_request_id)
          , p_level  => C_LEVEL_STATEMENT
          , p_module => v_module);
    END IF;
    -- check if the request is still running, report error if it is
    raise LastRequestRunning;
  ELSE
    DELETE from XLA_TPM_WORKING_HDRS_T
    WHERE merge_event_id = p_event_id;
    COMMIT;
  END IF;

  IF(p_merge_type = 'PARTIAL_MERGE') THEN
    FORALL i in 1..p_array_ledger_id.count
      INSERT INTO XLA_TPM_WORKING_HDRS_T
          ( request_id
           ,ae_header_id
           ,merge_event_id
           ,process_type_flag)
        SELECT
           p_request_id
          ,ae_header_id
          ,p_event_id
          ,'B'
        FROM xla_ae_headers            aeh
        WHERE aeh.BALANCE_TYPE_CODE = 'A'
          AND aeh.LEDGER_ID = p_array_ledger_id(i)
          AND aeh.ACCOUNTING_DATE <= p_merge_date
          AND aeh.ACCOUNTING_ENTRY_STATUS_CODE IN ('F','N')
          AND 'TRANSFER' = p_array_merge_option(i)
          AND merge_event_id is null
          AND ae_header_id in
           (SELECT ael.ae_header_id
              FROM xla_ae_lines ael
                  ,XLA_PARTIAL_MERGE_TXNS pmt
             WHERE nvl(ael.merge_party_id, ael.party_id) = p_old_party_id
               AND nvl(nvl(ael.merge_party_site_id, ael.party_site_id), -1)
                        = nvl(p_old_site_id, -1)
               and nvl(ael.party_type_code , p_party_type) = p_party_type
               and ael.currency_code <> 'STAT'
               AND ael.APPLICATION_ID =  p_application_id
               AND aeh.AE_HEADER_ID = ael.AE_HEADER_ID
               AND ael.control_balance_flag in ('P', 'Y')
               AND pmt.APPLICATION_ID = ael.application_id
               AND pmt.MERGE_EVENT_ID = p_event_id
               AND pmt.ENTITY_ID = aeh.ENTITY_ID);
    IF (C_LEVEL_STATEMENT>= g_log_level)
    THEN
      trace(  p_msg    => 'partial, balance, # inserted:'||to_char(SQL%ROWCOUNT)
          , p_level  => C_LEVEL_STATEMENT
          , p_module => v_module);
    END IF;

    commit;

    FORALL i in 1..p_array_ledger_id.count
      INSERT INTO XLA_TPM_WORKING_HDRS_T
          ( request_id
           ,ae_header_id
           ,merge_event_id
           ,process_type_flag)
        SELECT
           p_request_id
          ,ae_header_id
          ,p_event_id
          ,'R'
        FROM xla_ae_headers            aeh
        WHERE aeh.BALANCE_TYPE_CODE = 'A'
          AND aeh.APPLICATION_ID = p_application_id
          AND aeh.LEDGER_ID = p_array_ledger_id(i)
          AND aeh.ACCOUNTING_DATE > p_merge_date
          AND aeh.ACCOUNTING_ENTRY_STATUS_CODE IN ('F','N')
          AND 'TRANSFER' = p_array_merge_option(i)
          AND merge_event_id is null
          AND ae_header_id in
           (SELECT ael.ae_header_id
              FROM xla_ae_lines ael
                  ,XLA_PARTIAL_MERGE_TXNS pmt
             WHERE nvl(ael.merge_party_id, ael.party_id) = p_old_party_id
               AND nvl(nvl(ael.merge_party_site_id, ael.party_site_id), -1)
                        = nvl(p_old_site_id, -1)
               and nvl(ael.party_type_code , p_party_type) = p_party_type
               and ael.currency_code <> 'STAT'
               AND ael.APPLICATION_ID =  p_application_id
               AND aeh.AE_HEADER_ID = ael.AE_HEADER_ID
               AND pmt.APPLICATION_ID = ael.application_id
               AND pmt.MERGE_EVENT_ID = p_event_id
               AND pmt.ENTITY_ID = aeh.ENTITY_ID);
    IF (C_LEVEL_STATEMENT>= g_log_level)
    THEN
      trace(  p_msg    => 'partial, reverse and rebooking# inserted:'||to_char(SQL%ROWCOUNT)
          , p_level  => C_LEVEL_STATEMENT
          , p_module => v_module);
    END IF;
    commit;
  ELSE
    FORALL i in 1..p_array_ledger_id.count
      INSERT INTO XLA_TPM_WORKING_HDRS_T
          ( request_id
           ,ae_header_id
           ,merge_event_id
           ,process_type_flag)
        SELECT
           p_request_id
          ,ae_header_id
          ,p_event_id
          ,'B'
        FROM xla_ae_headers            aeh
        WHERE aeh.BALANCE_TYPE_CODE = 'A'
          AND aeh.APPLICATION_ID = p_application_id
          AND aeh.LEDGER_ID = p_array_ledger_id(i)
          AND aeh.ACCOUNTING_DATE <= p_merge_date
          AND aeh.ACCOUNTING_ENTRY_STATUS_CODE IN ('F','N')
          AND 'TRANSFER' = p_array_merge_option(i)
          AND merge_event_id is null
          AND ae_header_id in
           (SELECT ael.ae_header_id
              FROM xla_ae_lines ael
             WHERE nvl(ael.merge_party_id, ael.party_id) = p_old_party_id
               AND nvl(nvl(ael.merge_party_site_id, ael.party_site_id), -1)
                        = nvl(p_old_site_id, -1)
               and nvl(ael.party_type_code , p_party_type) = p_party_type
               and ael.currency_code <> 'STAT'
               AND ael.APPLICATION_ID =  p_application_id
               AND aeh.AE_HEADER_ID = ael.AE_HEADER_ID
               AND ael.control_balance_flag in ('P', 'Y'));
    IF (C_LEVEL_STATEMENT>= g_log_level)
    THEN
      trace(  p_msg    => 'full, balance transfer # inserted:'||to_char(SQL%ROWCOUNT)
          , p_level  => C_LEVEL_STATEMENT
          , p_module => v_module);
    END IF;
    commit;

    FORALL i in 1..p_array_ledger_id.count
      INSERT INTO XLA_TPM_WORKING_HDRS_T
          ( request_id
           ,ae_header_id
           ,merge_event_id
           ,process_type_flag)
        SELECT
           p_request_id
          ,ae_header_id
          ,p_event_id
          ,'R'
        FROM xla_ae_headers            aeh
        WHERE aeh.BALANCE_TYPE_CODE = 'A'
          AND aeh.APPLICATION_ID = p_application_id
          AND aeh.LEDGER_ID = p_array_ledger_id(i)
          AND aeh.ACCOUNTING_DATE > p_merge_date
          AND aeh.ACCOUNTING_ENTRY_STATUS_CODE IN ('F','N')
          AND 'TRANSFER' = p_array_merge_option(i)
          AND merge_event_id is null
          AND ae_header_id in
           (SELECT ael.ae_header_id
              FROM xla_ae_lines ael
             WHERE nvl(ael.merge_party_id, ael.party_id) = p_old_party_id
               AND nvl(nvl(ael.merge_party_site_id, ael.party_site_id), -1)
                        = nvl(p_old_site_id, -1)
               and nvl(ael.party_type_code , p_party_type) = p_party_type
               and ael.currency_code <> 'STAT'
               AND ael.APPLICATION_ID =  p_application_id
               AND aeh.AE_HEADER_ID = ael.AE_HEADER_ID);
    IF (C_LEVEL_STATEMENT>= g_log_level)
    THEN
      trace(  p_msg    => 'full, reverse and rebooking # inserted:'||to_char(SQL%ROWCOUNT)
          , p_level  => C_LEVEL_STATEMENT
          , p_module => v_module);
    END IF;
    commit;
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level)
  THEN
    trace(  p_msg    => 'end- ' || v_function
          , p_level  => C_LEVEL_PROCEDURE
          , p_module => v_module);
  END IF; -- IF (C_LEVEL_PROCEDURE >= g_log_level)
END create_work_table;

FUNCTION create_balance_transfer_aes(
        p_application_id        IN NUMBER
        ,p_accounting_mode      IN VARCHAR2
        ,p_event_id              IN NUMBER
        ,p_entity_id             IN NUMBER
        ,p_event_ledger_id       IN NUMBER
        ,p_merge_date            IN DATE
        ,p_merge_type            IN VARCHAR2
        ,p_old_site_id           IN NUMBER
        ,p_old_party_id          IN NUMBER
        ,p_new_site_id           IN NUMBER
        ,p_new_party_id          IN NUMBER
        ,p_party_type            IN VARCHAR2
        ,p_balance_desc          IN VARCHAR2
        ,p_array_ledger_id       IN xla_accounting_cache_pkg.t_array_ledger_id
        ,p_array_ledger_category IN t_varchar30_array
        ,p_array_reversal_option IN t_varchar30_array
        ,p_array_merge_option    IN t_varchar30_array
        ,p_array_submit_transfer IN t_varchar1_array) RETURN NUMBER is

v_query varchar2(20000);
v_function VARCHAR2(240);
v_module   VARCHAR2(240);
v_gl_date  t_date_array;
v_gl_period_name t_varchar30_array;
v_gl_entry_status t_varchar1_array;
v_row_count  INTEGER:=0;
v_total_row_count  INTEGER:=0;
v_gl_date_flag  VARCHAR2(1) :='N';
begin
  v_function              := 'xla_third_party_merge.create_balance_transfer_aes';
  v_module                := C_DEFAULT_MODULE||'.create_balance_transfer_aes';

  -- Log the function entry, the passed parameters and their values
  IF (C_LEVEL_PROCEDURE >= g_log_level)
  THEN
    trace(  p_msg    => 'BEGIN - ' || v_function
          , p_level  => C_LEVEL_PROCEDURE
          , p_module => v_module);
    trace(  p_msg    => 'p_applicaiton_id = ' || p_application_id
                         || ', p_event_id = ' || p_event_id
          , p_level  => C_LEVEL_PROCEDURE
          , p_module => v_module);
  END IF; -- IF (C_LEVEL_PROCEDURE >= g_log_level)

  IF (C_LEVEL_STATEMENT>= g_log_level)
  THEN
    trace(  p_msg    => 'before inserting reverse sql'
          , p_level  => C_LEVEL_STATEMENT
          , p_module => v_module);
  END IF;

  FORALL i in 1..p_array_ledger_id.count
    INSERT INTO xla_ae_lines_gt
      (ae_header_id
      ,temp_line_num
      ,event_id
      ,ref_ae_header_id
      ,ref_ae_line_num
      ,ref_temp_line_num
      ,ref_event_id
      ,balance_type_code
      ,ledger_id
      ,accounting_class_code
      ,event_class_code
      ,event_type_code
      ,line_definition_owner_code
      ,line_definition_code
      ,accounting_line_type_code
      ,accounting_line_code
      ,code_combination_status_code
      ,code_combination_id
      ,description
      ,gl_transfer_mode_code
      ,merge_duplicate_code
      ,unrounded_entered_dr
      ,unrounded_entered_cr
      ,unrounded_accounted_dr
      ,unrounded_accounted_cr
      ,calculate_acctd_amts_flag
      ,calculate_g_l_amts_flag
      ,gain_or_loss_flag
      ,rounding_class_code
      ,document_rounding_level
      ,doc_rounding_acctd_amt
      ,doc_rounding_entered_amt
      ,entered_currency_mau
      ,currency_code
      ,currency_conversion_date
      ,currency_conversion_rate
      ,currency_conversion_type
      ,statistical_amount
      ,party_id
      ,party_site_id
      ,party_type_code
      ,source_distribution_type
      ,ussgl_transaction_code
      ,jgzz_recon_ref
      ,analytical_balance_flag
      ,reversal_code
      ,accounting_entry_status_code
      ,inherit_desc_flag
      ,header_num          -- 5100860 assign value to avoid using function index
      ,alt_segment1
      ,encumbrance_type_id)
    SELECT
       p_event_id
      ,rownum
      ,p_event_id
      ,ael.ae_header_id
      ,ael.ae_line_num
      ,xdl.temp_line_num
      ,xdl.event_id
      ,aeh.balance_type_code
      ,aeh.ledger_id
      ,ael.accounting_class_code
      ,'MERGE' --xdl.event_class_code
      ,p_merge_type
      ,null --xdl.line_definition_owner_code
      ,xdl.line_definition_code
      ,xdl.accounting_line_type_code
      ,xdl.accounting_line_code
      ,'CREATED'-- code combination id status
      ,ael.code_combination_id
      ,p_balance_desc
      ,'N'  --gl_transfer_mode_code
      ,xdl.merge_duplicate_code
      ,decode(p_array_reversal_option(i), 'SIDE', xdl.unrounded_entered_cr, 0 - xdl.unrounded_entered_dr)
      ,decode(p_array_reversal_option(i), 'SIDE', xdl.unrounded_entered_dr, 0 - xdl.unrounded_entered_cr)
      ,decode(p_array_reversal_option(i), 'SIDE', xdl.unrounded_accounted_cr, 0 - xdl.unrounded_accounted_dr)
      ,decode(p_array_reversal_option(i), 'SIDE', xdl.unrounded_accounted_dr, 0 - xdl.unrounded_accounted_cr)
      ,xdl.calculate_acctd_amts_flag
      ,xdl.calculate_g_l_amts_flag
      ,ael.gain_or_loss_flag
      ,xdl.rounding_class_code
      ,xdl.document_rounding_level
      ,xdl.doc_rounding_acctd_amt
      ,xdl.doc_rounding_entered_amt
      ,nvl(fcu.minimum_accountable_unit, power(10, -1*fcu.precision))
      ,ael.currency_code
      ,ael.currency_conversion_date
      ,ael.currency_conversion_rate
      ,ael.currency_conversion_type
      ,ael.statistical_amount
      ,nvl(ael.merge_party_id, ael.party_id)
      ,nvl(ael.merge_party_site_id, ael.party_site_id)
      ,ael.party_type_code
      ,xdl.source_distribution_type
      ,ael.ussgl_transaction_code
      ,ael.jgzz_recon_ref
      ,ael.analytical_balance_flag
      ,'REVERSE_BALANCE'
      ,'F'
      ,'N'
      ,0                   -- 5100860 assign value to avoid using function index
      ,decode(ael.control_balance_flag, 'Y', 'P', 'P', 'P', null)
      ,ael.encumbrance_type_id
    FROM
       xla_ae_lines              ael
      ,xla_ae_headers            aeh
      ,xla_distribution_links    xdl
      ,fnd_currencies            fcu
    WHERE nvl(ael.merge_party_id, ael.party_id) = p_old_party_id
      AND nvl(nvl(ael.merge_party_site_id, ael.party_site_id), -1)
                   = nvl(p_old_site_id, -1)
      and nvl(ael.party_type_code , p_party_type) = p_party_type
      and ael.currency_code <> 'STAT'
      and ael.currency_code          = fcu.currency_code
      AND aeh.ae_header_id           = xdl.ae_header_id
      AND ael.ae_line_num            = xdl.ae_line_num
      AND ael.APPLICATION_ID =  p_application_id
      AND aeh.AE_HEADER_ID = ael.AE_HEADER_ID
      AND aeh.BALANCE_TYPE_CODE = 'A'
      AND aeh.APPLICATION_ID = ael.application_id
      AND aeh.LEDGER_ID = p_array_ledger_id(i)
      AND aeh.ACCOUNTING_DATE <= p_merge_date
      AND aeh.ACCOUNTING_ENTRY_STATUS_CODE = 'F'
      AND aeh.ae_header_id in (
           SELECT ae_header_id
             FROM XLA_TPM_WORKING_HDRS_T      xtwh
            WHERE xtwh.merge_event_id = p_event_id
              AND xtwh.process_type_flag= 'B'
              AND rownum <= C_WORK_UNIT)
      AND aeh.merge_event_id is null
/*
      AND NOT EXISTS (
           SELECT 1
           FROM xla_distribution_links
           WHERE ref_ae_header_id = xdl.ae_header_id
             AND ref_temp_line_num    = xdl.temp_line_num
            -- means it is a third party merge line
              And ref_ae_header_id <>ae_header_id
              )
*/
      AND ael.control_balance_flag in ('Y', 'P');

  v_row_count :=SQL%ROWCOUNT;
  IF (C_LEVEL_STATEMENT>= g_log_level)
  THEN
    trace(  p_msg    => '# inserted:'||to_char(v_row_count)
          , p_level  => C_LEVEL_STATEMENT
          , p_module => v_module);
    trace(  p_msg    => 'before inserting transfer sql'
          , p_level  => C_LEVEL_STATEMENT
          , p_module => v_module);
  END IF;

  IF(v_row_count = 0) THEN
    IF (C_LEVEL_PROCEDURE >= g_log_level)
    THEN
      trace(  p_msg    => 'end- ' || v_function||' return 0'
          , p_level  => C_LEVEL_PROCEDURE
          , p_module => v_module);
    END IF;
    return 0;
  END IF;


  FORALL i in 1..p_array_ledger_id.count
    INSERT INTO xla_ae_lines_gt
      (ae_header_id
      ,temp_line_num
      ,event_id
      ,ref_ae_header_id
      ,ref_ae_line_num
      ,ref_temp_line_num
      ,ref_event_id
      ,balance_type_code
      ,ledger_id
      ,accounting_class_code
      ,event_class_code
      ,event_type_code
      ,line_definition_owner_code
      ,line_definition_code
      ,accounting_line_type_code
      ,accounting_line_code
      ,code_combination_status_code
      ,code_combination_id
      ,description
      ,gl_transfer_mode_code
      ,merge_duplicate_code
      ,unrounded_entered_dr
      ,unrounded_entered_cr
      ,unrounded_accounted_dr
      ,unrounded_accounted_cr
      ,calculate_acctd_amts_flag
      ,calculate_g_l_amts_flag
      ,gain_or_loss_flag
      ,rounding_class_code
      ,document_rounding_level
      ,doc_rounding_acctd_amt
      ,doc_rounding_entered_amt
      ,entered_currency_mau
      ,currency_code
      ,currency_conversion_date
      ,currency_conversion_rate
      ,currency_conversion_type
      ,statistical_amount
      ,party_id
      ,party_site_id
      ,party_type_code
      ,source_distribution_type
      ,ussgl_transaction_code
      ,jgzz_recon_ref
      ,analytical_balance_flag
      ,reversal_code
      ,accounting_entry_status_code
      ,inherit_desc_flag
      ,header_num          -- 5100860 assign value to avoid using function index
      ,alt_segment1
      ,encumbrance_type_id)
    SELECT
       p_event_id
      ,v_row_count+rownum
      ,p_event_id
      ,ael.ae_header_id
      ,ael.ae_line_num
      ,xdl.temp_line_num
      ,xdl.event_id
      ,aeh.balance_type_code
      ,aeh.ledger_id
      ,ael.accounting_class_code
      ,'MERGE' --xdl.event_class_code
      ,p_merge_type
      ,null --xdl.line_definition_owner_code
      ,xdl.line_definition_code
      ,xdl.accounting_line_type_code
      ,xdl.accounting_line_code
      ,'CREATED'-- code combination id status
      ,ael.code_combination_id
      ,p_balance_desc
      ,'N'  --gl_transfer_mode_code
      ,xdl.merge_duplicate_code
      ,xdl.unrounded_entered_dr
      ,xdl.unrounded_entered_cr
      ,xdl.unrounded_accounted_dr
      ,xdl.unrounded_accounted_cr
      ,xdl.calculate_acctd_amts_flag
      ,xdl.calculate_g_l_amts_flag
      ,ael.gain_or_loss_flag
      ,xdl.rounding_class_code
      ,xdl.document_rounding_level
      ,xdl.doc_rounding_acctd_amt
      ,xdl.doc_rounding_entered_amt
      ,nvl(fcu.minimum_accountable_unit, power(10, -1*fcu.precision))
      ,ael.currency_code
      ,ael.currency_conversion_date
      ,ael.currency_conversion_rate
      ,ael.currency_conversion_type
      ,ael.statistical_amount
      ,p_new_party_id
      ,p_new_site_id
      ,ael.party_type_code
      ,xdl.source_distribution_type
      ,ael.ussgl_transaction_code
      ,ael.jgzz_recon_ref
      ,ael.analytical_balance_flag
      ,'TRANSFER_BALANCE'
      ,'F'
      ,'N'
      ,0                   -- 5100860 assign value to avoid using function index
      ,decode(ael.control_balance_flag, 'Y', 'P', 'P', 'P', null)
      ,ael.encumbrance_type_id
    FROM
       xla_ae_lines              ael
      ,xla_ae_headers            aeh
      ,xla_distribution_links    xdl
      ,fnd_currencies            fcu
    WHERE nvl(ael.merge_party_id, ael.party_id) = p_old_party_id
      AND nvl(nvl(ael.merge_party_site_id, ael.party_site_id), -1)
                   = nvl(p_old_site_id, -1)
      and nvl(ael.party_type_code , p_party_type) = p_party_type
      and ael.currency_code <> 'STAT'
      and ael.currency_code          = fcu.currency_code
      AND aeh.ae_header_id           = xdl.ae_header_id
      AND ael.ae_line_num            = xdl.ae_line_num
      AND ael.APPLICATION_ID =  p_application_id
      AND aeh.AE_HEADER_ID = ael.AE_HEADER_ID
      AND aeh.BALANCE_TYPE_CODE = 'A'
      AND aeh.APPLICATION_ID = ael.application_id
      AND aeh.LEDGER_ID = p_array_ledger_id(i)
      AND aeh.ACCOUNTING_DATE <= p_merge_date
      AND aeh.ACCOUNTING_ENTRY_STATUS_CODE = 'F'
      AND aeh.ae_header_id in (
           SELECT ae_header_id
             FROM XLA_TPM_WORKING_HDRS_T      xtwh
            WHERE xtwh.merge_event_id = p_event_id
              AND xtwh.process_type_flag= 'B'
              AND rownum <= C_WORK_UNIT)
      AND aeh.merge_event_id is null
/*
      AND NOT EXISTS (
           SELECT 1
           FROM xla_distribution_links
           WHERE ref_ae_header_id = xdl.ae_header_id
             AND ref_temp_line_num    = xdl.temp_line_num
            -- means it is a third party merge line
              And ref_ae_header_id <>ae_header_id
              )
*/
      AND ael.control_balance_flag in ('P', 'Y');

  v_row_count :=v_row_count + SQL%ROWCOUNT;
  IF (C_LEVEL_STATEMENT>= g_log_level)
  THEN
    trace(  p_msg    => '# total rows inserted:'||to_char(v_row_count)
          , p_level  => C_LEVEL_STATEMENT
          , p_module => v_module);
  END IF;

  IF(v_row_count> 0 AND v_gl_date_flag = 'N') THEN
    IF (C_LEVEL_STATEMENT>= g_log_level)
    THEN
      trace(  p_msg    => 'calling the get_accounting_date api '
          , p_level  => C_LEVEL_STATEMENT
          , p_module => v_module);
    END IF;
    BEGIN
      get_accounting_date(
         p_merge_date            => p_merge_date
        ,p_primary_ledger_id     => p_event_ledger_id
        ,p_array_ledger_id       => p_array_ledger_id
        ,p_array_ledger_category => p_array_ledger_category
        ,p_array_merge_option    => p_array_merge_option
        ,p_gl_date               => v_gl_date
        ,p_gl_period_name        => v_gl_period_name
        ,p_entry_status          => v_gl_entry_status);
      v_gl_date_flag := 'Y';
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        raise NoAccountingDateError;
    END;
    IF (C_LEVEL_STATEMENT>= g_log_level)
    THEN
      trace(  p_msg    => 'after calling the get_accounting_date api '
          , p_level  => C_LEVEL_STATEMENT
          , p_module => v_module);
    END IF;
  END IF;

  IF(v_row_count>0) THEN
    IF (C_LEVEL_STATEMENT>= g_log_level)
    THEN
      trace(  p_msg    => 'before inserting header'
          , p_level  => C_LEVEL_STATEMENT
          , p_module => v_module);
    END IF;

    FORALL i in 1 .. p_array_ledger_id.count
      INSERT INTO xla_ae_headers_gt
          ( ae_header_id
          , accounting_entry_status_code
          , accounting_entry_type_code
          , ledger_id
          , entity_id
          , event_id
          , event_type_code
          , accounting_date
          , period_name
          , description
          , budget_version_id  -- use this field to save merge_event_id
          , balance_type_code
          , amb_context_code
          , gl_transfer_status_code
          , je_category_name
        )
        select xla_ae_headers_s.nextval
                ,decode(p_accounting_mode, 'D', 'D', v_gl_entry_status(i))
                ,'MERGE'
                ,p_array_ledger_id(i)
                ,p_entity_id
                ,p_event_id
                ,p_merge_type
                ,v_gl_date(i)
                ,v_gl_period_name(i)
                ,p_balance_desc
                ,p_event_id
                ,'A'
                ,null
                ,'N'
                ,'Other'
                from dual
         where p_array_merge_option(i) = 'TRANSFER'
           AND p_array_ledger_id(i) in
                 (select ledger_id from xla_ae_lines_gt);

    IF (C_LEVEL_STATEMENT>= g_log_level)
    THEN
      trace(  p_msg    => 'Header inserted'
          , p_level  => C_LEVEL_STATEMENT
          , p_module => v_module);
    END IF;

    UPDATE xla_ae_lines_gt xal
       set (ae_header_id, accounting_date) =(
            select ae_header_id, accounting_date
              from xla_ae_headers_gt xah
             where xah.ledger_id = xal.ledger_id);
  END IF;

-- this is not needed since it is called in the caller procedure.
--  process_accounting_mapping(p_application_id => p_application_id);

  IF (C_LEVEL_PROCEDURE >= g_log_level)
  THEN
    trace(  p_msg    => 'end- ' || v_function || ' returning :'||to_char(v_row_count)
          , p_level  => C_LEVEL_PROCEDURE
          , p_module => v_module);
  END IF;
  return v_row_count;
END create_balance_transfer_aes;


FUNCTION create_reverse_rebooking_aes(
        p_application_id        IN NUMBER
        ,p_accounting_mode      IN VARCHAR2
        ,p_event_id              IN NUMBER
        ,p_entity_id             IN NUMBER
        ,p_event_ledger_id       IN NUMBER
        ,p_merge_date            IN DATE
        ,p_merge_type            IN VARCHAR2
        ,p_old_site_id           IN NUMBER
        ,p_old_party_id          IN NUMBER
        ,p_new_site_id           IN NUMBER
        ,p_new_party_id          IN NUMBER
        ,p_party_type            IN VARCHAR2
        ,p_reverse_line_desc     IN VARCHAR2
        ,p_rebooking_line_desc   IN VARCHAR2
        ,p_reverse_header_desc   IN VARCHAR2
        ,p_array_ledger_id       IN xla_accounting_cache_pkg.t_array_ledger_id
        ,p_array_ledger_category IN t_varchar30_array
        ,p_array_reversal_option IN t_varchar30_array
        ,p_array_merge_option    IN t_varchar30_array
        ,p_array_submit_transfer IN t_varchar1_array) RETURN NUMBER is

v_query varchar2(20000);
v_function VARCHAR2(240);
v_module   VARCHAR2(240);
v_gl_date  t_date_array;
v_gl_period_name t_varchar30_array;
v_row_count  INTEGER:=0;
v_total_row_count  INTEGER:=0;
v_gl_date_flag  VARCHAR2(1) :='N';
begin
  v_function              := 'xla_third_party_merge.create_reverse_rebooking_aes';
  v_module                := C_DEFAULT_MODULE||'.create_reverse_rebooking_aes';

  -- Log the function entry, the passed parameters and their values
  IF (C_LEVEL_PROCEDURE >= g_log_level)
  THEN
    trace(  p_msg    => 'BEGIN - ' || v_function
          , p_level  => C_LEVEL_PROCEDURE
          , p_module => v_module);
    trace(  p_msg    => 'p_applicaiton_id = ' || p_application_id
                         || ', p_event_id = ' || p_event_id
          , p_level  => C_LEVEL_PROCEDURE
          , p_module => v_module);
  END IF; -- IF (C_LEVEL_PROCEDURE >= g_log_level)

  IF (C_LEVEL_STATEMENT>= g_log_level)
  THEN
    trace(  p_msg    => 'before inserting reverse sql'
          , p_level  => C_LEVEL_STATEMENT
          , p_module => v_module);
  END IF;

  FORALL i in 1..p_array_ledger_id.count
    INSERT INTO xla_ae_lines_gt
      (ae_header_id
      ,temp_line_num
      ,event_id
      ,ref_ae_header_id
      ,ref_ae_line_num
      ,ref_temp_line_num
      ,ref_event_id
      ,balance_type_code
      ,ledger_id
      ,accounting_class_code
      ,event_class_code
      ,event_type_code
      ,line_definition_owner_code
      ,line_definition_code
      ,accounting_line_type_code
      ,accounting_line_code
      ,code_combination_status_code
      ,code_combination_id
      ,description
      ,gl_transfer_mode_code
      ,merge_duplicate_code
      ,unrounded_entered_dr
      ,unrounded_entered_cr
      ,unrounded_accounted_dr
      ,unrounded_accounted_cr
      ,calculate_acctd_amts_flag
      ,calculate_g_l_amts_flag
      ,gain_or_loss_flag
      ,rounding_class_code
      ,document_rounding_level
      ,doc_rounding_acctd_amt
      ,doc_rounding_entered_amt
      ,entered_currency_mau
      ,currency_code
      ,currency_conversion_date
      ,currency_conversion_rate
      ,currency_conversion_type
      ,statistical_amount
      ,party_id
      ,party_site_id
      ,party_type_code
      ,ussgl_transaction_code
      ,jgzz_recon_ref
      ,source_distribution_id_char_1
      ,source_distribution_id_char_2
      ,source_distribution_id_char_3
      ,source_distribution_id_char_4
      ,source_distribution_id_char_5
      ,source_distribution_id_num_1
      ,source_distribution_id_num_2
      ,source_distribution_id_num_3
      ,source_distribution_id_num_4
      ,source_distribution_id_num_5
      ,source_distribution_type
      ,analytical_balance_flag
      ,reversal_code
      ,accounting_entry_status_code
      ,inherit_desc_flag
      ,header_num          -- 5100860 assign value to avoid using function index
      ,alt_segment1
      ,encumbrance_type_id)
    SELECT
       p_event_id
      ,rank() over(partition by xdl.ae_header_id order by xdl.temp_line_num)
      ,aeh.event_id
      ,ael.ae_header_id
      ,ael.ae_line_num
      ,xdl.temp_line_num
      ,xdl.event_id
      ,aeh.balance_type_code
      ,aeh.ledger_id
      ,ael.accounting_class_code
      ,xdl.event_class_code
      ,aeh.event_type_code --'MERGE' --merge_event_type_code
      ,null --xdl.line_definition_owner_code
      ,xdl.line_definition_code
      ,xdl.accounting_line_type_code
      ,xdl.accounting_line_code
      ,'CREATED'-- code combination id status
      ,ael.code_combination_id
      ,ael.description || p_reverse_line_desc
      ,'N'  --gl_transfer_mode_code
      ,xdl.merge_duplicate_code
      ,decode(p_array_reversal_option(i), 'SIDE', xdl.unrounded_entered_cr, 0 - xdl.unrounded_entered_dr)
      ,decode(p_array_reversal_option(i), 'SIDE', xdl.unrounded_entered_dr, 0 - xdl.unrounded_entered_cr)
      ,decode(p_array_reversal_option(i), 'SIDE', xdl.unrounded_accounted_cr, 0 - xdl.unrounded_accounted_dr)
      ,decode(p_array_reversal_option(i), 'SIDE', xdl.unrounded_accounted_dr, 0 - xdl.unrounded_accounted_cr)
      ,xdl.calculate_acctd_amts_flag
      ,xdl.calculate_g_l_amts_flag
      ,ael.gain_or_loss_flag
      ,xdl.rounding_class_code
      ,xdl.document_rounding_level
      ,xdl.doc_rounding_acctd_amt
      ,xdl.doc_rounding_entered_amt
      ,nvl(fcu.minimum_accountable_unit, power(10, -1*fcu.precision))
      ,ael.currency_code
      ,ael.currency_conversion_date
      ,ael.currency_conversion_rate
      ,ael.currency_conversion_type
      ,ael.statistical_amount
      ,nvl(ael.merge_party_id, ael.party_id)
      ,nvl(ael.merge_party_site_id, ael.party_site_id)
      ,ael.party_type_code
      ,ael.ussgl_transaction_code
      ,ael.jgzz_recon_ref
      ,xdl.source_distribution_id_char_1
      ,xdl.source_distribution_id_char_2
      ,xdl.source_distribution_id_char_3
      ,xdl.source_distribution_id_char_4
      ,xdl.source_distribution_id_char_5
      ,xdl.source_distribution_id_num_1
      ,xdl.source_distribution_id_num_2
      ,xdl.source_distribution_id_num_3
      ,xdl.source_distribution_id_num_4
      ,xdl.source_distribution_id_num_5
      ,xdl.source_distribution_type
      ,ael.analytical_balance_flag
      ,'REVERSE'
      ,'F'
      ,'N'
      ,0                   -- 5100860 assign value to avoid using function index
      ,decode(ael.control_balance_flag, 'Y', 'P', 'P', 'P', null)
      ,ael.encumbrance_type_id
    FROM
       xla_ae_lines              ael
      ,xla_ae_headers            aeh
      ,xla_distribution_links    xdl
      ,fnd_currencies            fcu
    WHERE nvl(ael.merge_party_id, ael.party_id) = p_old_party_id
      AND nvl(nvl(ael.merge_party_site_id, ael.party_site_id), -1)
                   = nvl(p_old_site_id, -1)
      and nvl(ael.party_type_code , p_party_type) = p_party_type
      and ael.currency_code <> 'STAT'
      and ael.currency_code          = fcu.currency_code
      AND aeh.ae_header_id           = xdl.ae_header_id
      AND ael.ae_line_num            = xdl.ae_line_num
      AND ael.APPLICATION_ID =  p_application_id
      AND aeh.AE_HEADER_ID = ael.AE_HEADER_ID
      AND aeh.BALANCE_TYPE_CODE = 'A'
      AND aeh.APPLICATION_ID = ael.application_id
      AND aeh.LEDGER_ID = p_array_ledger_id(i)
      AND aeh.ACCOUNTING_DATE > p_merge_date
      AND aeh.ACCOUNTING_ENTRY_STATUS_CODE = 'F'
      AND aeh.ae_header_id in (
           SELECT ae_header_id
             FROM XLA_TPM_WORKING_HDRS_T      xtwh
            WHERE xtwh.merge_event_id = p_event_id
              AND xtwh.process_type_flag= 'R'
              AND rownum <= C_WORK_UNIT)
      AND aeh.merge_event_id is null
/*
      AND NOT EXISTS (
           SELECT 1
           FROM xla_distribution_links
           WHERE ref_ae_header_id = xdl.ae_header_id
             AND ref_temp_line_num    = xdl.temp_line_num
            -- means it is a third party merge line
              And ref_ae_header_id <>ae_header_id
              )
*/
      ;

  v_row_count :=SQL%ROWCOUNT;
  IF (C_LEVEL_STATEMENT>= g_log_level)
  THEN
    trace(  p_msg    => '# inserted:'||to_char(v_row_count)
          , p_level  => C_LEVEL_STATEMENT
          , p_module => v_module);
    trace(  p_msg    => 'before inserting rebooking sql'
          , p_level  => C_LEVEL_STATEMENT
          , p_module => v_module);
  END IF;

  IF(v_row_count = 0) THEN
    IF (C_LEVEL_PROCEDURE >= g_log_level)
    THEN
      trace(  p_msg    => 'end- ' || v_function||' return 0'
          , p_level  => C_LEVEL_PROCEDURE
          , p_module => v_module);
    END IF;
    return 0;
  END IF;

  FORALL i in 1..p_array_ledger_id.count
    INSERT INTO xla_ae_lines_gt
      (ae_header_id
      ,temp_line_num
      ,event_id
      ,ref_ae_header_id
      ,ref_ae_line_num
      ,ref_temp_line_num
      ,ref_event_id
      ,balance_type_code
      ,ledger_id
      ,accounting_class_code
      ,event_class_code
      ,event_type_code
      ,line_definition_owner_code
      ,line_definition_code
      ,accounting_line_type_code
      ,accounting_line_code
      ,code_combination_status_code
      ,code_combination_id
      ,description
      ,gl_transfer_mode_code
      ,merge_duplicate_code
      ,unrounded_entered_dr
      ,unrounded_entered_cr
      ,unrounded_accounted_dr
      ,unrounded_accounted_cr
      ,calculate_acctd_amts_flag
      ,calculate_g_l_amts_flag
      ,gain_or_loss_flag
      ,rounding_class_code
      ,document_rounding_level
      ,doc_rounding_acctd_amt
      ,doc_rounding_entered_amt
      ,entered_currency_mau
      ,currency_code
      ,currency_conversion_date
      ,currency_conversion_rate
      ,currency_conversion_type
      ,statistical_amount
      ,party_id
      ,party_site_id
      ,party_type_code
      ,ussgl_transaction_code
      ,jgzz_recon_ref
      ,source_distribution_id_char_1
      ,source_distribution_id_char_2
      ,source_distribution_id_char_3
      ,source_distribution_id_char_4
      ,source_distribution_id_char_5
      ,source_distribution_id_num_1
      ,source_distribution_id_num_2
      ,source_distribution_id_num_3
      ,source_distribution_id_num_4
      ,source_distribution_id_num_5
      ,source_distribution_type
      ,analytical_balance_flag
      ,reversal_code
      ,accounting_entry_status_code
      ,inherit_desc_flag
      ,header_num          -- 5100860 assign value to avoid using function index
      ,alt_segment1
      ,encumbrance_type_id)
    SELECT
       p_event_id
      ,count(*) over(partition by xdl.ae_header_id) + rank() over(partition by xdl.ae_header_id order by xdl.temp_line_num)
--      ,xdl.temp_line_num
      ,aeh.event_id
      ,ael.ae_header_id
      ,ael.ae_line_num
      ,xdl.temp_line_num
      ,xdl.event_id
      ,aeh.balance_type_code
      ,aeh.ledger_id
      ,ael.accounting_class_code
      ,xdl.event_class_code
      ,aeh.event_type_code --'MERGE' --merge_event_type_code
      ,null --xdl.line_definition_owner_code
      ,xdl.line_definition_code
      ,xdl.accounting_line_type_code
      ,xdl.accounting_line_code
      ,'CREATED'-- code combination id status
      ,ael.code_combination_id
      ,ael.description || p_rebooking_line_desc
      ,'N'  --gl_transfer_mode_code
      ,xdl.merge_duplicate_code
      ,xdl.unrounded_entered_dr
      ,xdl.unrounded_entered_cr
      ,xdl.unrounded_accounted_dr
      ,xdl.unrounded_accounted_cr
      ,xdl.calculate_acctd_amts_flag
      ,xdl.calculate_g_l_amts_flag
      ,ael.gain_or_loss_flag
      ,xdl.rounding_class_code
      ,xdl.document_rounding_level
      ,xdl.doc_rounding_acctd_amt
      ,xdl.doc_rounding_entered_amt
      ,nvl(fcu.minimum_accountable_unit, power(10, -1*fcu.precision))
      ,ael.currency_code
      ,ael.currency_conversion_date
      ,ael.currency_conversion_rate
      ,ael.currency_conversion_type
      ,ael.statistical_amount
      ,p_new_party_id
      ,p_new_site_id
      ,ael.party_type_code
      ,ael.ussgl_transaction_code
      ,ael.jgzz_recon_ref
      ,xdl.source_distribution_id_char_1
      ,xdl.source_distribution_id_char_2
      ,xdl.source_distribution_id_char_3
      ,xdl.source_distribution_id_char_4
      ,xdl.source_distribution_id_char_5
      ,xdl.source_distribution_id_num_1
      ,xdl.source_distribution_id_num_2
      ,xdl.source_distribution_id_num_3
      ,xdl.source_distribution_id_num_4
      ,xdl.source_distribution_id_num_5
      ,xdl.source_distribution_type
      ,ael.analytical_balance_flag
      ,'REBOOKING'
      ,'F'
      ,'N'
      ,0                   -- 5100860 assign value to avoid using function index
      ,decode(ael.control_balance_flag, 'Y', 'P', 'P', 'P', null)
      ,ael.encumbrance_type_id
    FROM
       xla_ae_lines              ael
      ,xla_ae_headers            aeh
      ,xla_distribution_links    xdl
      ,fnd_currencies            fcu
    WHERE nvl(ael.merge_party_id, ael.party_id) = p_old_party_id
      AND nvl(nvl(ael.merge_party_site_id, ael.party_site_id), -1)
                   = nvl(p_old_site_id, -1)
      and nvl(ael.party_type_code , p_party_type) = p_party_type
      and ael.currency_code <> 'STAT'
      and ael.currency_code          = fcu.currency_code
      AND aeh.ae_header_id           = xdl.ae_header_id
      AND ael.ae_line_num            = xdl.ae_line_num
      AND ael.APPLICATION_ID =  p_application_id
      AND aeh.AE_HEADER_ID = ael.AE_HEADER_ID
      AND aeh.BALANCE_TYPE_CODE = 'A'
      AND aeh.APPLICATION_ID = ael.application_id
      AND aeh.LEDGER_ID = p_array_ledger_id(i)
      AND aeh.ACCOUNTING_DATE > p_merge_date
      AND aeh.ACCOUNTING_ENTRY_STATUS_CODE = 'F'
      AND aeh.ae_header_id in (
           SELECT ae_header_id
             FROM XLA_TPM_WORKING_HDRS_T      xtwh
            WHERE xtwh.merge_event_id = p_event_id
              AND xtwh.process_type_flag= 'R'
              AND rownum <= C_WORK_UNIT)
      AND aeh.merge_event_id is null
/*
      AND NOT EXISTS (
           SELECT 1
           FROM xla_distribution_links
           WHERE ref_ae_header_id = xdl.ae_header_id
             AND ref_temp_line_num    = xdl.temp_line_num
            -- means it is a third party merge line
              And ref_ae_header_id <>ae_header_id
              )
*/
      ;

  v_row_count :=v_row_count + SQL%ROWCOUNT;
  IF (C_LEVEL_STATEMENT>= g_log_level)
  THEN
    trace(  p_msg    => '# total rows inserted:'||to_char(v_row_count)
          , p_level  => C_LEVEL_STATEMENT
          , p_module => v_module);
  END IF;


  IF(v_row_count>0) THEN
    IF (C_LEVEL_STATEMENT>= g_log_level)
    THEN
      trace(  p_msg    => 'before inserting header'
          , p_level  => C_LEVEL_STATEMENT
          , p_module => v_module);
    END IF;

    generate_headers( p_application_id       => p_application_id
                     ,p_reverse_header_desc  => p_reverse_header_desc
                     ,p_accounting_mode      => p_accounting_mode
                    );

    IF (C_LEVEL_STATEMENT>= g_log_level)
    THEN
      trace(  p_msg    => 'return from generate_headers, Header inserted'
          , p_level  => C_LEVEL_STATEMENT
          , p_module => v_module);
    END IF;
  END IF;


  IF (C_LEVEL_PROCEDURE >= g_log_level)
  THEN
    trace(  p_msg    => 'end- ' || v_function || ' returning :'||to_char(v_row_count)
          , p_level  => C_LEVEL_PROCEDURE
          , p_module => v_module);
  END IF;
  return v_row_count;
END create_reverse_rebooking_aes;


PROCEDURE create_journal_entries(
         x_errbuf                OUT NOCOPY VARCHAR2
        ,x_retcode               OUT NOCOPY VARCHAR2
        ,p_application_id        IN NUMBER
        ,p_accounting_mode       IN VARCHAR2
        ,p_transfer_to_gl_flag   IN VARCHAR2
        ,p_post_in_gl_flag       IN VARCHAR2
        ,p_event_id              IN NUMBER
        ,p_entity_id             IN NUMBER
        ,p_mapping_flag          IN VARCHAR2
        ,p_event_ledger_id       IN NUMBER
        ,p_merge_date            IN DATE
        ,p_merge_type            IN VARCHAR2
        ,p_old_site_id           IN NUMBER
        ,p_old_party_id          IN NUMBER
        ,p_new_site_id           IN NUMBER
        ,p_new_party_id          IN NUMBER
        ,p_party_type            IN VARCHAR2
        ,p_balance_desc          IN VARCHAR2
        ,p_reverse_line_desc     IN VARCHAR2
        ,p_rebooking_line_desc   IN VARCHAR2
        ,p_reverse_header_desc   IN VARCHAR2
        ,p_array_ledger_id       IN xla_accounting_cache_pkg.t_array_ledger_id
        ,p_array_ledger_category IN t_varchar30_array
        ,p_array_reversal_option IN t_varchar30_array
        ,p_array_rounding_rule_code IN t_varchar30_array
        ,p_array_mau                IN t_number_array
        ,p_array_merge_option    IN t_varchar30_array
        ,p_array_submit_transfer IN t_varchar1_array) is

v_query varchar2(20000);
v_function VARCHAR2(240);
v_module   VARCHAR2(240);
v_gl_date  t_date_array;
v_gl_period_name t_varchar30_array;
v_row_count  INTEGER:=0;
v_row_count1  INTEGER:=0;
v_status   VARCHAR2(1) := 'B';
v_batch_id              NUMBER(15) := null;
v_array_ledger_id       xla_accounting_cache_pkg.t_array_ledger_id;
v_array_ledger_category t_varchar30_array;
v_array_reversal_option t_varchar30_array;
v_array_rounding_rule_code t_varchar30_array;
v_array_mau                t_number_array;
v_array_merge_option    t_varchar30_array;
v_array_submit_transfer t_varchar1_array;
l_count NUMBER :=0;
begin
  v_function              := 'xla_third_party_merge.create_journal_entries';
  v_module                := C_DEFAULT_MODULE||'.create_journal_entries';

  -- Log the function entry, the passed parameters and their values
  IF (C_LEVEL_PROCEDURE >= g_log_level)
  THEN
    trace(  p_msg    => 'BEGIN - ' || v_function
          , p_level  => C_LEVEL_PROCEDURE
          , p_module => v_module);
    trace(  p_msg    => 'p_applicaiton_id = ' || p_application_id
                         || ', p_event_id = ' || p_event_id
          , p_level  => C_LEVEL_PROCEDURE
          , p_module => v_module);
  END IF; -- IF (C_LEVEL_PROCEDURE >= g_log_level)

  FOR Idx IN p_array_ledger_id.FIRST .. p_array_ledger_id.LAST LOOP
    IF(p_array_merge_option(Idx) = 'TRANSFER') THEN
      l_count := l_count + 1;
      v_array_ledger_id(l_count) := p_array_ledger_id(Idx);
      v_array_ledger_category(l_count) := p_array_ledger_category(Idx);
      v_array_reversal_option(l_count) := p_array_reversal_option(Idx);
      v_array_rounding_rule_code(l_count) := p_array_rounding_rule_code(Idx);
      v_array_mau(l_count) := p_array_mau(Idx);
      v_array_merge_option(l_count) := p_array_merge_option(Idx);
      v_array_submit_transfer(l_count) := p_array_submit_transfer(Idx);
    END IF;
  END LOOP;

  LOOP
    IF(v_status = 'B') THEN
      v_row_count := create_balance_transfer_aes(
           p_application_id        => p_application_id
           ,p_accounting_mode      => p_accounting_mode
           ,p_event_id              => p_event_id
           ,p_entity_id             => p_entity_id
           ,p_event_ledger_id       => p_event_ledger_id
           ,p_merge_date            => p_merge_date
           ,p_merge_type            => p_merge_type
           ,p_old_site_id           => p_old_site_id
           ,p_old_party_id          => p_old_party_id
           ,p_new_site_id           => p_new_site_id
           ,p_new_party_id          => p_new_party_id
           ,p_party_type            => p_party_type
           ,p_balance_desc          => p_balance_desc
           ,p_array_ledger_id       => v_array_ledger_id
           ,p_array_ledger_category => v_array_ledger_category
           ,p_array_reversal_option => v_array_reversal_option
           ,p_array_merge_option    => v_array_merge_option
           ,p_array_submit_transfer => v_array_submit_transfer);
    ELSE
      v_row_count := create_reverse_rebooking_aes(
           p_application_id        => p_application_id
           ,p_accounting_mode      => p_accounting_mode
           ,p_event_id              => p_event_id
           ,p_entity_id             => p_entity_id
           ,p_event_ledger_id       => p_event_ledger_id
           ,p_merge_date            => p_merge_date
           ,p_merge_type            => p_merge_type
           ,p_old_site_id           => p_old_site_id
           ,p_old_party_id          => p_old_party_id
           ,p_new_site_id           => p_new_site_id
           ,p_new_party_id          => p_new_party_id
           ,p_party_type            => p_party_type
           ,p_reverse_line_desc     => p_reverse_line_desc
           ,p_rebooking_line_desc   => p_rebooking_line_desc
           ,p_reverse_header_desc   => p_reverse_header_desc
           ,p_array_ledger_id       => v_array_ledger_id
           ,p_array_ledger_category => v_array_ledger_category
           ,p_array_reversal_option => v_array_reversal_option
           ,p_array_merge_option    => v_array_merge_option
           ,p_array_submit_transfer => v_array_submit_transfer);
    END IF;

    IF(v_row_count > 0) THEN
      IF(p_mapping_flag = 'Y') THEN
        process_accounting_mapping(p_application_id => p_application_id
                                  ,p_event_id              => p_event_id);
      END IF;
      get_line_number(
         p_array_ledger_id          => v_array_ledger_id
        ,p_array_rounding_rule_code => v_array_rounding_rule_code
        ,p_array_mau                => v_array_mau);

      insert_lines(
           p_application_id        => p_application_id
           ,p_array_ledger_id       => v_array_ledger_id
           ,p_array_reversal_option => v_array_reversal_option
           ,p_array_mau                => v_array_mau
           ,p_array_rounding_rule=> v_array_rounding_rule_code);

      IF(p_accounting_mode = 'F' AND v_batch_id is null) THEN
        SELECT xla_accounting_batches_s.NEXTVAL INTO v_batch_id FROM DUAL;
        IF (C_LEVEL_STATEMENT>= g_log_level)
        THEN
          trace(  p_msg    => 'Getting the batch id:'||to_char(v_batch_id)
                , p_level  => C_LEVEL_STATEMENT
                , p_module => v_module);
        END IF;
      END IF;

      insert_headers(
             p_batch_id         => v_batch_id
            ,p_application_id   => p_application_id
             ,p_event_id        => p_event_id
            ,p_accounting_mode  => p_accounting_mode);

      insert_links(
           p_application_id        => p_application_id);


      IF(xla_je_validation_pkg.balance_tpm_amounts
                         (p_application_id         => p_application_id
                         ,p_ledger_id              => p_event_ledger_id
                         ,p_ledger_array           => v_array_ledger_id
                         ,p_accounting_mode        => p_accounting_mode) = 1) THEN
        raise BalanceError;
      END IF;

      IF(p_accounting_mode <> 'D') THEN
        UPDATE xla_ae_lines xal
           SET (merge_party_id, merge_party_site_id, merge_code_combination_id)
                = (select party_id, party_site_id, code_combination_id
                     from xla_ae_lines_gt xalg
                    where xalg.ref_ae_header_id = xal.ae_header_id
                      AND xalg.ref_ae_line_num = xal.ae_line_num
                      AND xalg.reversal_code in ('REBOOKING', 'TRANSFER_BALANCE')
                      and rownum = 1)
         WHERE xal.application_id = p_application_id
           AND (ae_header_id, ae_line_num) in
                (select xlg.ref_ae_header_id, xlg.ref_ae_line_num
                   from xla_ae_lines_gt    xlg
                       ,xla_ae_headers     xah
                  where xlg.reversal_code in ('REBOOKING', 'TRANSFER_BALANCE')
                    -- Bug 5103972 MPA / Reversal of incomplete JE
                    -- should not be stamped with merge party informtion
                    AND xlg.ref_ae_header_id = xah.ae_header_id
                    AND xah.application_id = p_application_id
                    AND (xah.parent_ae_header_id IS NULL
                      OR xah.accounting_entry_status_code <> 'N')
                );

      END IF;
    END IF;

    v_row_count1 := 0 ;
    IF(v_status = 'B') THEN
      DELETE XLA_TPM_WORKING_HDRS_T      xtwh
       WHERE xtwh.merge_event_id = p_event_id
         AND xtwh.process_type_flag= 'B'
         AND rownum <= C_WORK_UNIT;
         v_row_count1 :=SQL%ROWCOUNT;
    ELSE
      DELETE XLA_TPM_WORKING_HDRS_T      xtwh
       WHERE xtwh.merge_event_id = p_event_id
         AND xtwh.process_type_flag= 'R'
         AND rownum <= C_WORK_UNIT;
         v_row_count1 :=SQL%ROWCOUNT;
    END IF;

    IF(v_row_count > 0 AND v_row_count1 > 0) THEN
      COMMIT;
    END IF;

    EXIT WHEN (v_row_count1 = 0 and v_status = 'R');

    IF(v_row_count1 = 0 AND v_status = 'B') THEN
        v_status := 'R';
    END IF;

  END LOOP;

/* Added by krsankar for bug 7457594 and RCA bug 8395892 */

IF v_batch_id IS NOT NULL
THEN

  IF(p_accounting_mode = 'F' AND p_transfer_to_gl_flag = 'Y') THEN
    IF (C_LEVEL_STATEMENT>= g_log_level)
    THEN
      trace(  p_msg    => 'before calling gl_transfer_main'
          , p_level  => C_LEVEL_STATEMENT
          , p_module => v_module);
    END IF;
    xla_transfer_pkg.gl_transfer_main
         (p_application_id        => p_application_id
         ,p_transfer_mode         => 'COMBINED'
         ,p_ledger_id             => p_event_ledger_id
         ,p_securiy_id_int_1      => null
         ,p_securiy_id_int_2      => null
         ,p_securiy_id_int_3      => null
         ,p_securiy_id_char_1     => null
         ,p_securiy_id_char_2     => null
         ,p_securiy_id_char_3     => null
         ,p_valuation_method      => null
         ,p_process_category      => null
         ,p_accounting_batch_id   => v_batch_id
         ,p_entity_id             => NULL
         ,p_batch_name            => null
         ,p_end_date              => null
         ,p_submit_gl_post        => p_post_in_gl_flag
         ,p_caller                => xla_transfer_pkg.C_TP_MERGE); -- Bug 5056632

        IF (C_LEVEL_STATEMENT>= g_log_level)
    THEN
      trace(  p_msg    => 'after calling gl_transfer_main'
          , p_level  => C_LEVEL_STATEMENT
          , p_module => v_module);
    END IF;
  END IF;

ELSE /* Else part of v_batch_id IS NOT NULL*/
     /* Added by krsankar for bug 7457594 and RCA bug 8395892 */

    IF (C_LEVEL_STATEMENT>= g_log_level)
    THEN
      trace(  p_msg    => 'Else of v_batch_id : batch_id IS NULL'
          , p_level  => C_LEVEL_STATEMENT
          , p_module => v_module);
    END IF;

    IF (C_LEVEL_STATEMENT>= g_log_level)
    THEN
      trace(  p_msg    => 'Found no records to process.Returning back to create_accounting'
          , p_level  => C_LEVEL_STATEMENT
          , p_module => v_module);
    END IF;

 return;


END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level)
  THEN
    trace(  p_msg    => 'END - ' || v_function
          , p_level  => C_LEVEL_PROCEDURE
          , p_module => v_module);
  END IF;
end create_journal_entries;

PROCEDURE update_journal_entries(
         x_errbuf                OUT NOCOPY VARCHAR2
        ,x_retcode               OUT NOCOPY VARCHAR2
        ,p_application_id        IN NUMBER
        ,p_event_id              IN NUMBER
        ,p_event_merge_option    IN VARCHAR2
        ,p_entity_id             IN NUMBER
        ,p_mapping_flag          IN VARCHAR2
        ,p_event_ledger_id       IN NUMBER
        ,p_merge_date            IN DATE
        ,p_merge_type            IN VARCHAR2
        ,p_old_site_id           IN NUMBER
        ,p_old_party_id          IN NUMBER
        ,p_new_site_id           IN NUMBER
        ,p_new_party_id          IN NUMBER
        ,p_party_type            IN VARCHAR2
        ,p_line_desc             IN VARCHAR2
        ,p_array_ledger_id       IN xla_accounting_cache_pkg.t_array_ledger_id
        ,p_array_ledger_category IN t_varchar30_array
        ,p_array_reversal_option IN t_varchar30_array
        ,p_array_merge_option    IN t_varchar30_array
        ,p_array_submit_transfer IN t_varchar1_array)
is

v_function VARCHAR2(240);
v_module   VARCHAR2(240);
v_gl_date  t_date_array;
v_gl_period_name t_varchar30_array;
v_row_count  INTEGER:=0;
v_total_row_count  INTEGER:=0;

v_aeh_desc              VARCHAR2(1996);

begin
  v_function              := 'xla_third_party_merge.update_journal_entries';
  v_module                := C_DEFAULT_MODULE||'.update_journal_entries';

  -- Log the function entry, the passed parameters and their values
  IF (C_LEVEL_PROCEDURE >= g_log_level)
  THEN
    trace(  p_msg    => 'BEGIN - ' || v_function
          , p_level  => C_LEVEL_PROCEDURE
          , p_module => v_module);
    trace(  p_msg    => 'p_applicaiton_id = ' || p_application_id
                         || ', p_event_id = ' || p_event_id
          , p_level  => C_LEVEL_PROCEDURE
          , p_module => v_module);
  END IF; -- IF (C_LEVEL_PROCEDURE >= g_log_level)

  v_aeh_desc := xla_messages_pkg.get_message
                    (  p_appli_s_name => 'XLA'
                     , p_msg_name     => 'XLA_MERGE_AEH_DESC'
                     , p_token_1      => 'MERGE_DATE'
                     , p_value_1      => p_merge_date);

  IF(p_merge_type = 'PARTIAL_MERGE') THEN
    FORALL i IN 1..p_array_ledger_id.count
      UPDATE XLA_AE_HEADERS aeh
         SET DESCRIPTION
               = DECODE(DESCRIPTION
                           , NULL, v_aeh_desc
                           , SUBSTRB(DESCRIPTION, 0,
                                1995 - LENGTHB(v_aeh_desc))
                          || ' ' || v_aeh_desc),
             LAST_UPDATE_DATE = sysdate,
             LAST_UPDATED_BY = XLA_ENVIRONMENT_PKG.g_usr_id,
             LAST_UPDATE_LOGIN = XLA_ENVIRONMENT_PKG.g_login_id,
             PROGRAM_UPDATE_DATE = sysdate,
             PROGRAM_APPLICATION_ID = XLA_ENVIRONMENT_PKG.g_prog_appl_id,
             PROGRAM_ID = XLA_ENVIRONMENT_PKG.g_prog_id,
             REQUEST_ID = XLA_ENVIRONMENT_PKG.g_req_id
       WHERE aeh.APPLICATION_ID = p_application_id
         AND aeh.LEDGER_ID = p_array_ledger_id(i)
         AND ((aeh.accounting_entry_status_code = 'F' AND
               p_array_merge_option(i) = 'CHANGE')
              OR
              --
              -- Bug 5103972
              -- Should update party info for incomplete je for MPA
              -- even when the merge option is 'TRANSFER'
              --
              (p_array_merge_option(i) = 'TRANSFER' AND
               aeh.parent_ae_header_id IS NOT NULL AND
               aeh.accounting_entry_status_code = 'N'
              )
             )
         AND EXISTS
          (SELECT 'X'
             FROM XLA_AE_LINES ael
            WHERE ael.PARTY_ID = p_old_party_id
              AND (   p_old_site_id IS NULL
                   OR ael.PARTY_SITE_ID = p_old_site_id)
              AND ael.PARTY_TYPE_CODE = p_party_type
              AND aeh.AE_HEADER_ID = ael.AE_HEADER_ID
              AND aeh.APPLICATION_ID = ael.APPLICATION_ID)
         AND EXISTS
                  (SELECT 'X'
                      FROM XLA_PARTIAL_MERGE_TXNS pmt
                     WHERE pmt.APPLICATION_ID = p_application_id
                      AND pmt.MERGE_EVENT_ID = p_event_id
                       AND pmt.ENTITY_ID = aeh.ENTITY_ID);
  ELSE
    FORALL i IN 1..p_array_ledger_id.count
      UPDATE XLA_AE_HEADERS aeh
         SET DESCRIPTION
               = DECODE(DESCRIPTION
                           , NULL, v_aeh_desc
                           , SUBSTRB(DESCRIPTION, 0,
                                1995 - LENGTHB(v_aeh_desc))
                          || ' ' || v_aeh_desc),
             LAST_UPDATE_DATE = sysdate,
             LAST_UPDATED_BY = XLA_ENVIRONMENT_PKG.g_usr_id,
             LAST_UPDATE_LOGIN = XLA_ENVIRONMENT_PKG.g_login_id,
             PROGRAM_UPDATE_DATE = sysdate,
             PROGRAM_APPLICATION_ID = XLA_ENVIRONMENT_PKG.g_prog_appl_id,
             PROGRAM_ID = XLA_ENVIRONMENT_PKG.g_prog_id,
             REQUEST_ID = XLA_ENVIRONMENT_PKG.g_req_id
       WHERE aeh.APPLICATION_ID = p_application_id
         AND aeh.LEDGER_ID = p_array_ledger_id(i)
         AND ((aeh.accounting_entry_status_code = 'F' AND
               p_array_merge_option(i) = 'CHANGE')
              OR
              --
              -- Bug 5103972
              -- Should update party info for incomplete je for MPA
              -- even when the merge option is 'TRANSFER'
              --
              (p_array_merge_option(i) = 'TRANSFER' AND
               aeh.parent_ae_header_id IS NOT NULL AND
               aeh.accounting_entry_status_code = 'N'
              )
             )
         AND EXISTS
          (SELECT 'X'
             FROM XLA_AE_LINES ael
            WHERE ael.PARTY_ID = p_old_party_id
              AND (   p_old_site_id IS NULL
                   OR ael.PARTY_SITE_ID = p_old_site_id)
              AND ael.PARTY_TYPE_CODE = p_party_type
              AND aeh.AE_HEADER_ID = ael.AE_HEADER_ID
              AND aeh.APPLICATION_ID = ael.APPLICATION_ID);
  END IF;

  v_row_count :=SQL%ROWCOUNT;
  IF (C_LEVEL_STATEMENT>= g_log_level) THEN
    trace(  p_msg    => '# of headers updated:'||to_char(v_row_count)
          , p_level  => C_LEVEL_STATEMENT
          , p_module => v_module);
  END IF;

  IF(v_row_count > 0) THEN
    -- need to apply segment mapping for transfer and incomplete entry
    IF (C_LEVEL_STATEMENT>= g_log_level) THEN
      trace(  p_msg    => 'update the line next '
          , p_level  => C_LEVEL_STATEMENT
          , p_module => v_module);
    END IF;

    IF(p_event_merge_option in ('BOTH', 'TRANSFER') AND p_mapping_flag = 'Y') THEN
      process_incomplete_acct_map(
          p_application_id        => p_application_id
          ,p_event_id              => p_event_id
          ,p_event_merge_option    => p_event_merge_option
          ,p_entity_id             => p_entity_id
          ,p_merge_date            => p_merge_date
          ,p_merge_type            => p_merge_type
          ,p_old_site_id           => p_old_site_id
          ,p_old_party_id          => p_old_party_id
          ,p_new_site_id           => p_new_site_id
          ,p_new_party_id          => p_new_party_id
          ,p_party_type            => p_party_type
          ,p_array_ledger_id       => p_array_ledger_id
          ,p_array_ledger_category => p_array_ledger_category
          ,p_array_reversal_option => p_array_reversal_option
          ,p_array_merge_option    => p_array_merge_option);

    END IF;

    IF(p_merge_type = 'PARTIAL_MERGE') THEN
      FORALL i IN 1..p_array_ledger_id.count
        UPDATE XLA_AE_LINES ael
        SET PARTY_ID = p_new_party_id,
            PARTY_SITE_ID = NVL(p_new_site_id, PARTY_SITE_ID),
            DESCRIPTION
             = DECODE(DESCRIPTION
                , NULL, p_line_desc
                      , SUBSTRB(DESCRIPTION, 0,
                                1995 - LENGTHB(p_line_desc))
                         || ' ' || p_line_desc),
            LAST_UPDATE_DATE = sysdate,
            LAST_UPDATED_BY = XLA_ENVIRONMENT_PKG.g_usr_id,
            LAST_UPDATE_LOGIN = XLA_ENVIRONMENT_PKG.g_login_id,
            PROGRAM_UPDATE_DATE = sysdate,
            PROGRAM_APPLICATION_ID = XLA_ENVIRONMENT_PKG.g_prog_appl_id,
            PROGRAM_ID = XLA_ENVIRONMENT_PKG.g_prog_id,
            REQUEST_ID = XLA_ENVIRONMENT_PKG.g_req_id
        WHERE ael.PARTY_ID = p_old_party_id
        AND (   p_old_site_id IS NULL
             OR ael.PARTY_SITE_ID = p_old_site_id)
        AND ael.PARTY_TYPE_CODE = p_party_type
        AND EXISTS
         (SELECT 'X'
            FROM XLA_AE_HEADERS aeh, XLA_PARTIAL_MERGE_TXNS pmt
           WHERE ael.APPLICATION_ID = aeh.APPLICATION_ID
             AND ael.AE_HEADER_ID = aeh.AE_HEADER_ID
             AND aeh.APPLICATION_ID = p_application_id
             AND aeh.accounting_entry_status_code = 'F'
             AND aeh.LEDGER_ID = p_array_ledger_id(i)
             AND p_array_merge_option(i) = 'CHANGE'
             AND pmt.APPLICATION_ID = p_application_id
             AND pmt.MERGE_EVENT_ID = p_event_id
             AND pmt.ENTITY_ID = aeh.ENTITY_ID
           UNION ALL
          --
          -- Incomplete lines from MPA / Accrual Reversal (5090223/5103972)
          --
          SELECT 'X'
            FROM XLA_AE_HEADERS aeh, XLA_PARTIAL_MERGE_TXNS pmt
           WHERE ael.APPLICATION_ID = aeh.APPLICATION_ID
             AND ael.AE_HEADER_ID = aeh.AE_HEADER_ID
             AND aeh.APPLICATION_ID = p_application_id
             AND aeh.accounting_entry_status_code = 'N'
             AND aeh.LEDGER_ID = p_array_ledger_id(i)
             AND aeh.parent_ae_header_id IS NOT NULL
             AND p_array_merge_option(i) IN ('TRANSFER','CHANGE')
             AND pmt.APPLICATION_ID = p_application_id
             AND pmt.MERGE_EVENT_ID = p_event_id
             AND pmt.ENTITY_ID = aeh.ENTITY_ID
             );

      v_row_count :=SQL%ROWCOUNT;
      IF (C_LEVEL_STATEMENT>= g_log_level) THEN
        trace(  p_msg    => '# of lines updated:'||to_char(v_row_count)
          , p_level  => C_LEVEL_STATEMENT
          , p_module => v_module);
      END IF;


      FORALL i IN 1..p_array_ledger_id.count
        UPDATE XLA_TRIAL_BALANCES tb
        SET PARTY_ID = p_new_party_id,
            PARTY_SITE_ID = NVL(p_new_site_id, PARTY_SITE_ID),
            LAST_UPDATE_DATE = sysdate,
            LAST_UPDATED_BY = XLA_ENVIRONMENT_PKG.g_usr_id,
            LAST_UPDATE_LOGIN = XLA_ENVIRONMENT_PKG.g_login_id,
            PROGRAM_UPDATE_DATE = sysdate,
            PROGRAM_APPLICATION_ID = XLA_ENVIRONMENT_PKG.g_prog_appl_id,
            PROGRAM_ID = XLA_ENVIRONMENT_PKG.g_prog_id,
            REQUEST_ID = XLA_ENVIRONMENT_PKG.g_req_id
        WHERE tb.PARTY_ID = p_old_party_id
        AND (   p_old_site_id IS NULL
             OR tb.PARTY_SITE_ID = p_old_site_id)
        AND tb.PARTY_TYPE_CODE = p_party_type
        AND EXISTS
         (SELECT 'X'
            FROM XLA_AE_HEADERS aeh, XLA_PARTIAL_MERGE_TXNS pmt
           WHERE tb.AE_HEADER_ID = aeh.AE_HEADER_ID
             AND aeh.APPLICATION_ID = p_application_id
             AND aeh.LEDGER_ID = p_array_ledger_id(i)
             AND aeh.accounting_entry_status_code = 'F'
             AND p_array_merge_option(i) = 'CHANGE'
             AND pmt.APPLICATION_ID = p_application_id
             AND pmt.MERGE_EVENT_ID = p_event_id
             AND pmt.ENTITY_ID = aeh.ENTITY_ID
           UNION ALL
           --
           -- Incomplete lines from MPA / Accrual Reversal (5090223/5103972)
           --
           SELECT 'X'
            FROM XLA_AE_HEADERS aeh, XLA_PARTIAL_MERGE_TXNS pmt
           WHERE tb.AE_HEADER_ID = aeh.AE_HEADER_ID
             AND aeh.APPLICATION_ID = p_application_id
             AND aeh.LEDGER_ID = p_array_ledger_id(i)
             AND aeh.parent_ae_header_id IS NOT NULL
             AND aeh.accounting_entry_status_code = 'N'
             AND p_array_merge_option(i) IN ('TRANSFER','CHANGE')
             AND pmt.APPLICATION_ID = p_application_id
             AND pmt.MERGE_EVENT_ID = p_event_id
             AND pmt.ENTITY_ID = aeh.ENTITY_ID);

      v_row_count :=SQL%ROWCOUNT;
      IF (C_LEVEL_STATEMENT>= g_log_level) THEN
        trace(  p_msg    => '# of rows in xla_trial_balances table updated:'||to_char(v_row_count)
          , p_level  => C_LEVEL_STATEMENT
          , p_module => v_module);
      END IF;

    ELSE
      FORALL i IN 1..p_array_ledger_id.count
        UPDATE XLA_AE_LINES ael
        SET PARTY_ID = p_new_party_id,
            PARTY_SITE_ID = NVL(p_new_site_id, PARTY_SITE_ID),
            DESCRIPTION
             = DECODE(DESCRIPTION
                , NULL, p_line_desc
                      , SUBSTRB(DESCRIPTION, 0,
                                1995 - LENGTHB(p_line_desc))
                         || ' ' || p_line_desc),
            LAST_UPDATE_DATE = sysdate,
            LAST_UPDATED_BY = XLA_ENVIRONMENT_PKG.g_usr_id,
            LAST_UPDATE_LOGIN = XLA_ENVIRONMENT_PKG.g_login_id,
            PROGRAM_UPDATE_DATE = sysdate,
            PROGRAM_APPLICATION_ID = XLA_ENVIRONMENT_PKG.g_prog_appl_id,
            PROGRAM_ID = XLA_ENVIRONMENT_PKG.g_prog_id,
            REQUEST_ID = XLA_ENVIRONMENT_PKG.g_req_id
        WHERE ael.PARTY_ID = p_old_party_id
        AND (   p_old_site_id IS NULL
             OR ael.PARTY_SITE_ID = p_old_site_id)
        AND ael.PARTY_TYPE_CODE = p_party_type
        AND EXISTS
         (SELECT 'X'
            FROM XLA_AE_HEADERS aeh
           WHERE ael.APPLICATION_ID = aeh.APPLICATION_ID
             AND ael.AE_HEADER_ID = aeh.AE_HEADER_ID
             AND aeh.APPLICATION_ID = p_application_id
             AND aeh.accounting_entry_status_code = 'F'
             AND aeh.LEDGER_ID = p_array_ledger_id(i)
             AND p_array_merge_option(i) = 'CHANGE'
           UNION ALL
          --
          -- Incomplete lines from MPA / Accrual Reversal (5090223/5103972)
          --
          SELECT 'X'
            FROM XLA_AE_HEADERS aeh
           WHERE ael.APPLICATION_ID = aeh.APPLICATION_ID
             AND ael.AE_HEADER_ID = aeh.AE_HEADER_ID
             AND aeh.APPLICATION_ID = p_application_id
             AND aeh.LEDGER_ID = p_array_ledger_id(i)
             AND aeh.accounting_entry_status_code = 'N'
             AND aeh.parent_ae_header_id IS NOT NULL
             AND p_array_merge_option(i) IN ('TRANSFER','CHANGE')
             )
             ;

      v_row_count :=SQL%ROWCOUNT;
      IF (C_LEVEL_STATEMENT>= g_log_level) THEN
        trace(  p_msg    => '# of lines updated:'||to_char(v_row_count)
          , p_level  => C_LEVEL_STATEMENT
          , p_module => v_module);
      END IF;

      FORALL i IN 1..p_array_ledger_id.count
        UPDATE XLA_TRIAL_BALANCES tb
        SET PARTY_ID = p_new_party_id,
            PARTY_SITE_ID = NVL(p_new_site_id, PARTY_SITE_ID),
            LAST_UPDATE_DATE = sysdate,
            LAST_UPDATED_BY = XLA_ENVIRONMENT_PKG.g_usr_id,
            LAST_UPDATE_LOGIN = XLA_ENVIRONMENT_PKG.g_login_id,
            PROGRAM_UPDATE_DATE = sysdate,
            PROGRAM_APPLICATION_ID = XLA_ENVIRONMENT_PKG.g_prog_appl_id,
            PROGRAM_ID = XLA_ENVIRONMENT_PKG.g_prog_id,
            REQUEST_ID = XLA_ENVIRONMENT_PKG.g_req_id
        WHERE tb.PARTY_ID = p_old_party_id
        AND (   p_old_site_id IS NULL
             OR tb.PARTY_SITE_ID = p_old_site_id)
        AND tb.PARTY_TYPE_CODE = p_party_type
        AND EXISTS
         (SELECT 'X'
            FROM XLA_AE_HEADERS aeh
           WHERE tb.AE_HEADER_ID = aeh.AE_HEADER_ID
             AND aeh.APPLICATION_ID = p_application_id
             AND aeh.accounting_entry_status_code = 'F'
             AND aeh.LEDGER_ID = p_array_ledger_id(i)
             AND p_array_merge_option(i) = 'CHANGE'
           UNION ALL
          --
          -- Incomplete lines from MPA / Accrual Reversal (5090223/5103972)
          --
          SELECT 'X'
            FROM XLA_AE_HEADERS aeh
           WHERE tb.AE_HEADER_ID = aeh.AE_HEADER_ID
             AND aeh.APPLICATION_ID = p_application_id
             AND aeh.accounting_entry_status_code = 'N'
             AND aeh.LEDGER_ID = p_array_ledger_id(i)
             AND aeh.parent_ae_header_id IS NOT NULL
             AND p_array_merge_option(i) IN ('TRANSFER','CHANGE')
             );

      v_row_count :=SQL%ROWCOUNT;
      IF (C_LEVEL_STATEMENT>= g_log_level) THEN
        trace(  p_msg    => '# of rows in xla_trial_balances table updated:'||to_char(v_row_count)
          , p_level  => C_LEVEL_STATEMENT
          , p_module => v_module);
      END IF;

    END IF;

  END IF;

  IF (C_LEVEL_PROCEDURE>= g_log_level)
  THEN
    trace(  p_msg    => 'End of '||v_function
          , p_level  => C_LEVEL_PROCEDURE
          , p_module => v_module);
  END IF;

end update_journal_entries;



PROCEDURE populate_ccid_to_gt IS
v_function VARCHAR2(240);
v_module   VARCHAR2(240);
cursor c_null_ccid is
  select 1
    from xla_ae_lines_gt
   where code_combination_id is null;
v_temp     NUMBER;
begin
  v_function              := 'xla_third_party_merge.populate_ccid_to_gt';
  v_module                := C_DEFAULT_MODULE||'.populate_ccid_to_gt';

  -- Log the function entry, the passed parameters and their values
  IF (C_LEVEL_PROCEDURE >= g_log_level)
  THEN
    trace(  p_msg    => 'BEGIN - ' || v_function
          , p_level  => C_LEVEL_PROCEDURE
          , p_module => v_module);
  END IF; -- IF (C_LEVEL_PROCEDURE >= g_log_level)

  update xla_ae_lines_gt xalg
  set code_combination_id =
  (select code_combination_id
     from gl_code_combinations gcc
    where gcc.chart_of_accounts_id = xalg.ccid_coa_id
      and gcc.template_id is null
      and (gcc.segment1= xalg.segment1 or (gcc.segment1 is null and xalg.segment1 is null))
      and (gcc.segment2= xalg.segment2 or (gcc.segment2 is null and xalg.segment2 is null))
      and (gcc.segment3= xalg.segment3 or (gcc.segment3 is null and xalg.segment3 is null))
      and (gcc.segment4= xalg.segment4 or (gcc.segment4 is null and xalg.segment4 is null))
      and (gcc.segment5= xalg.segment5 or (gcc.segment5 is null and xalg.segment5 is null))
      and (gcc.segment6= xalg.segment6 or (gcc.segment6 is null and xalg.segment6 is null))
      and (gcc.segment7= xalg.segment7 or (gcc.segment7 is null and xalg.segment7 is null))
      and (gcc.segment8= xalg.segment8 or (gcc.segment8 is null and xalg.segment8 is null))
      and (gcc.segment9= xalg.segment9 or (gcc.segment9 is null and xalg.segment9 is null))
      and (gcc.segment10= xalg.segment10 or (gcc.segment10 is null and xalg.segment10 is null))
      and (gcc.segment11= xalg.segment11 or (gcc.segment11 is null and xalg.segment11 is null))
      and (gcc.segment12= xalg.segment12 or (gcc.segment12 is null and xalg.segment12 is null))
      and (gcc.segment13= xalg.segment13 or (gcc.segment13 is null and xalg.segment13 is null))
      and (gcc.segment14= xalg.segment14 or (gcc.segment14 is null and xalg.segment14 is null))
      and (gcc.segment15= xalg.segment15 or (gcc.segment15 is null and xalg.segment15 is null))
      and (gcc.segment16= xalg.segment16 or (gcc.segment16 is null and xalg.segment16 is null))
      and (gcc.segment17= xalg.segment17 or (gcc.segment17 is null and xalg.segment17 is null))
      and (gcc.segment18= xalg.segment18 or (gcc.segment18 is null and xalg.segment18 is null))
      and (gcc.segment19= xalg.segment19 or (gcc.segment19 is null and xalg.segment19 is null))
      and (gcc.segment20= xalg.segment20 or (gcc.segment20 is null and xalg.segment20 is null))
      and (gcc.segment21= xalg.segment21 or (gcc.segment21 is null and xalg.segment21 is null))
      and (gcc.segment22= xalg.segment22 or (gcc.segment22 is null and xalg.segment22 is null))
      and (gcc.segment23= xalg.segment23 or (gcc.segment23 is null and xalg.segment23 is null))
      and (gcc.segment24= xalg.segment24 or (gcc.segment24 is null and xalg.segment24 is null))
      and (gcc.segment25= xalg.segment25 or (gcc.segment25 is null and xalg.segment25 is null))
      and (gcc.segment26= xalg.segment26 or (gcc.segment26 is null and xalg.segment26 is null))
      and (gcc.segment27= xalg.segment27 or (gcc.segment27 is null and xalg.segment27 is null))
      and (gcc.segment28= xalg.segment28 or (gcc.segment28 is null and xalg.segment28 is null))
      and (gcc.segment29= xalg.segment29 or (gcc.segment29 is null and xalg.segment29 is null))
      and (gcc.segment30= xalg.segment30 or (gcc.segment30 is null and xalg.segment30 is null)))
  WHERE code_combination_id is null;

  IF (C_LEVEL_STATEMENT>= g_log_level)
  THEN
    trace(  p_msg    => '# of lines updated:'||to_char(SQL%ROWCOUNT)
          , p_level  => C_LEVEL_STATEMENT
          , p_module => v_module);
  END IF;

  update xla_ae_lines_gt temp
    SET code_combination_id =
       xla_ae_code_combination_pkg.GetCcid(
                      temp.segment1
                     ,temp.segment2
                     ,temp.segment3
                     ,temp.segment4
                     ,temp.segment5
                     ,temp.segment6
                     ,temp.segment7
                     ,temp.segment8
                     ,temp.segment9
                     ,temp.segment10
                     ,temp.segment11
                     ,temp.segment12
                     ,temp.segment13
                     ,temp.segment14
                     ,temp.segment15
                     ,temp.segment16
                     ,temp.segment17
                     ,temp.segment18
                     ,temp.segment19
                     ,temp.segment20
                     ,temp.segment21
                     ,temp.segment22
                     ,temp.segment23
                     ,temp.segment24
                     ,temp.segment25
                     ,temp.segment26
                     ,temp.segment27
                     ,temp.segment28
                     ,temp.segment29
                     ,temp.segment30
                     ,temp.ccid_coa_id
                     )
    WHERE temp.code_combination_id IS NULL;

  IF (C_LEVEL_STATEMENT>= g_log_level)
  THEN
    trace(  p_msg    => '# of lines updated:'||to_char(SQL%ROWCOUNT)
          , p_level  => C_LEVEL_STATEMENT
          , p_module => v_module);
  END IF;

  OPEN c_null_ccid;
  fetch c_null_ccid into v_temp;
  CLOSE c_null_ccid;

  IF(v_temp is not null) THEN
    IF (C_LEVEL_STATEMENT>= g_log_level)
    THEN
      trace(  p_msg    => 'raise MissingCCIDError'
          , p_level  => C_LEVEL_STATEMENT
          , p_module => v_module);
    END IF;
    raise MissingCCIDError;
  END IF;

  IF (C_LEVEL_PROCEDURE>= g_log_level)
  THEN
    trace(  p_msg    => 'End of '||v_function
          , p_level  => C_LEVEL_PROCEDURE
          , p_module => v_module);
  END IF;

END populate_ccid_to_gt;

PROCEDURE process_accounting_mapping(
        p_application_id       IN NUMBER
        ,p_event_id            IN NUMBER) IS
v_function VARCHAR2(240);
v_module   VARCHAR2(240);
cursor c_null_ccid is
  select 1
    from xla_ae_lines_gt
   where code_combination_id is null;
v_temp     NUMBER;
begin
  v_function              := 'xla_third_party_merge.process_accounting_mapping';
  v_module                := C_DEFAULT_MODULE||'.process_accounting_mapping';

  -- Log the function entry, the passed parameters and their values
  IF (C_LEVEL_PROCEDURE >= g_log_level)
  THEN
    trace(  p_msg    => 'BEGIN - ' || v_function
          , p_level  => C_LEVEL_PROCEDURE
          , p_module => v_module);
  END IF; -- IF (C_LEVEL_PROCEDURE >= g_log_level)

  update xla_ae_lines_gt xalg
      set ( code_combination_id
           ,ccid_coa_id
           ,segment1
           ,segment2
           ,segment3
           ,segment4
           ,segment5
           ,segment6
           ,segment7
           ,segment8
           ,segment9
           ,segment10
           ,segment11
           ,segment12
           ,segment13
           ,segment14
           ,segment15
           ,segment16
           ,segment17
           ,segment18
           ,segment19
           ,segment20
           ,segment21
           ,segment22
           ,segment23
           ,segment24
           ,segment25
           ,segment26
           ,segment27
           ,segment28
           ,segment29
           ,segment30) =
           (select null
           ,gcc.chart_of_accounts_id
           ,decode(segment_code, 'SEGMENT1', to_value, gcc.segment1)
           ,decode(segment_code, 'SEGMENT2', to_value, gcc.segment2)
           ,decode(segment_code, 'SEGMENT3', to_value, gcc.segment3)
           ,decode(segment_code, 'SEGMENT4', to_value, gcc.segment4)
           ,decode(segment_code, 'SEGMENT5', to_value, gcc.segment5)
           ,decode(segment_code, 'SEGMENT6', to_value, gcc.segment6)
           ,decode(segment_code, 'SEGMENT7', to_value, gcc.segment7)
           ,decode(segment_code, 'SEGMENT8', to_value, gcc.segment8)
           ,decode(segment_code, 'SEGMENT9', to_value, gcc.segment9)
           ,decode(segment_code, 'SEGMENT10', to_value, gcc.segment10)
           ,decode(segment_code, 'SEGMENT11', to_value, gcc.segment11)
           ,decode(segment_code, 'SEGMENT12', to_value, gcc.segment12)
           ,decode(segment_code, 'SEGMENT13', to_value, gcc.segment13)
           ,decode(segment_code, 'SEGMENT14', to_value, gcc.segment14)
           ,decode(segment_code, 'SEGMENT15', to_value, gcc.segment15)
           ,decode(segment_code, 'SEGMENT16', to_value, gcc.segment16)
           ,decode(segment_code, 'SEGMENT17', to_value, gcc.segment17)
           ,decode(segment_code, 'SEGMENT18', to_value, gcc.segment18)
           ,decode(segment_code, 'SEGMENT19', to_value, gcc.segment19)
           ,decode(segment_code, 'SEGMENT20', to_value, gcc.segment20)
           ,decode(segment_code, 'SEGMENT21', to_value, gcc.segment21)
           ,decode(segment_code, 'SEGMENT22', to_value, gcc.segment22)
           ,decode(segment_code, 'SEGMENT23', to_value, gcc.segment23)
           ,decode(segment_code, 'SEGMENT24', to_value, gcc.segment24)
           ,decode(segment_code, 'SEGMENT25', to_value, gcc.segment25)
           ,decode(segment_code, 'SEGMENT26', to_value, gcc.segment26)
           ,decode(segment_code, 'SEGMENT27', to_value, gcc.segment27)
           ,decode(segment_code, 'SEGMENT28', to_value, gcc.segment28)
           ,decode(segment_code, 'SEGMENT29', to_value, gcc.segment29)
           ,decode(segment_code, 'SEGMENT30', to_value, gcc.segment30)
       from xla_merge_seg_maps map
            ,gl_code_combinations gcc
            ,XLA_LEDGER_RELATIONSHIPS_V rs
            ,gl_ledgers gld
       where map.application_id = p_application_id
         and rs.RELATIONSHIP_ENABLED_FLAG = 'Y'
         AND rs.ledger_id = gld.ledger_id
         AND gld.complete_flag = 'Y'
         AND rs.SLA_ACCOUNTING_METHOD_CODE IS NOT NULL
         AND rs.ledger_id = xalg.ledger_id
         AND DECODE(rs.LEDGER_CATEGORY_CODE
                 , 'ALC', rs.PRIMARY_LEDGER_ID
                        , rs.LEDGER_ID) = map.ledger_id
         and map.event_id       = p_event_id
         AND decode(map.segment_code, 'SEGMENT1', gcc.segment1
                  ,'SEGMENT2', gcc.segment2
                  ,'SEGMENT3', gcc.segment3
                  ,'SEGMENT4', gcc.segment4
                  ,'SEGMENT5', gcc.segment5
                  ,'SEGMENT6', gcc.segment6
                  ,'SEGMENT7', gcc.segment7
                  ,'SEGMENT8', gcc.segment8
                  ,'SEGMENT9', gcc.segment9
                  ,'SEGMENT10', gcc.segment10
                  ,'SEGMENT11', gcc.segment11
                  ,'SEGMENT12', gcc.segment12
                  ,'SEGMENT13', gcc.segment13
                  ,'SEGMENT14', gcc.segment14
                  ,'SEGMENT15', gcc.segment15
                  ,'SEGMENT16', gcc.segment16
                  ,'SEGMENT17', gcc.segment17
                  ,'SEGMENT18', gcc.segment18
                  ,'SEGMENT19', gcc.segment19
                  ,'SEGMENT20', gcc.segment20
                  ,'SEGMENT21', gcc.segment21
                  ,'SEGMENT22', gcc.segment22
                  ,'SEGMENT23', gcc.segment23
                  ,'SEGMENT24', gcc.segment24
                  ,'SEGMENT25', gcc.segment25
                  ,'SEGMENT26', gcc.segment26
                  ,'SEGMENT27', gcc.segment27
                  ,'SEGMENT28', gcc.segment28
                  ,'SEGMENT29', gcc.segment29
                  ,'SEGMENT30', gcc.segment30)
                                      = map.FROM_VALUE
          and gcc.code_combination_id = xalg.code_combination_id
     )
     where reversal_code in ('REBOOKING', 'TRANSFER_BALANCE')
       AND exists
       (select 1
       from xla_merge_seg_maps map
            ,gl_code_combinations gcc
            ,XLA_LEDGER_RELATIONSHIPS_V rs
            ,gl_ledgers gld
       where map.application_id = p_application_id
         and rs.RELATIONSHIP_ENABLED_FLAG = 'Y'
         AND rs.ledger_id = gld.ledger_id
         AND gld.complete_flag = 'Y'
         AND rs.SLA_ACCOUNTING_METHOD_CODE IS NOT NULL
         AND rs.ledger_id = xalg.ledger_id
         AND DECODE(rs.LEDGER_CATEGORY_CODE
                 , 'ALC', rs.PRIMARY_LEDGER_ID
                        , rs.LEDGER_ID) = map.ledger_id
         and map.event_id       = p_event_id
         AND decode(map.segment_code, 'SEGMENT1', gcc.segment1
                  ,'SEGMENT2', gcc.segment2
                  ,'SEGMENT3', gcc.segment3
                  ,'SEGMENT4', gcc.segment4
                  ,'SEGMENT5', gcc.segment5
                  ,'SEGMENT6', gcc.segment6
                  ,'SEGMENT7', gcc.segment7
                  ,'SEGMENT8', gcc.segment8
                  ,'SEGMENT9', gcc.segment9
                  ,'SEGMENT10', gcc.segment10
                  ,'SEGMENT11', gcc.segment11
                  ,'SEGMENT12', gcc.segment12
                  ,'SEGMENT13', gcc.segment13
                  ,'SEGMENT14', gcc.segment14
                  ,'SEGMENT15', gcc.segment15
                  ,'SEGMENT16', gcc.segment16
                  ,'SEGMENT17', gcc.segment17
                  ,'SEGMENT18', gcc.segment18
                  ,'SEGMENT19', gcc.segment19
                  ,'SEGMENT20', gcc.segment20
                  ,'SEGMENT21', gcc.segment21
                  ,'SEGMENT22', gcc.segment22
                  ,'SEGMENT23', gcc.segment23
                  ,'SEGMENT24', gcc.segment24
                  ,'SEGMENT25', gcc.segment25
                  ,'SEGMENT26', gcc.segment26
                  ,'SEGMENT27', gcc.segment27
                  ,'SEGMENT28', gcc.segment28
                  ,'SEGMENT29', gcc.segment29
                  ,'SEGMENT30', gcc.segment30)
                                      = map.FROM_VALUE
          and gcc.code_combination_id = xalg.code_combination_id);


  IF (C_LEVEL_STATEMENT>= g_log_level)
  THEN
    trace(  p_msg    => '# of lines updated:'||to_char(SQL%ROWCOUNT)
          , p_level  => C_LEVEL_STATEMENT
          , p_module => v_module);
  END IF;

  populate_ccid_to_gt;

  IF (C_LEVEL_PROCEDURE>= g_log_level)
  THEN
    trace(  p_msg    => 'End of '||v_function
          , p_level  => C_LEVEL_PROCEDURE
          , p_module => v_module);
  END IF;

END process_accounting_mapping;


-- private procedure, populate xla_ae_lines_gt table
-- for the purpose of account mapping
FUNCTION populate_gt_for_mapping(
        p_application_id       IN NUMBER
        ,p_event_id            IN NUMBER
        ,p_merge_type            IN VARCHAR2
        ,p_old_site_id           IN NUMBER
        ,p_old_party_id          IN NUMBER
        ,p_new_site_id           IN NUMBER
        ,p_new_party_id          IN NUMBER
        ,p_party_type            IN VARCHAR2
        ,p_array_ledger_id       IN xla_accounting_cache_pkg.t_array_ledger_id
        ,p_array_reversal_option IN t_varchar30_array
        ,p_array_merge_option    IN t_varchar30_array) RETURN NUMBER IS
v_function VARCHAR2(240);
v_module   VARCHAR2(240);

v_row_count NUMBER;

BEGIN

  v_function              := 'xla_third_party_merge.populate_gt_for_mapping';
  v_module                := C_DEFAULT_MODULE||'.populate_gt_for_mapping';

  -- Log the function entry, the passed parameters and their values
  IF (C_LEVEL_PROCEDURE >= g_log_level)
  THEN
    trace(  p_msg    => 'BEGIN - ' || v_function
          , p_level  => C_LEVEL_PROCEDURE
          , p_module => v_module);
  END IF; -- IF (C_LEVEL_PROCEDURE >= g_log_level)


  IF(p_merge_type = 'PARTIAL_MERGE') THEN
    FORALL i IN 1..p_array_ledger_id.count
          INSERT INTO xla_ae_lines_gt (
              ae_header_id
             ,ae_line_num
             ,temp_line_num
             ,inherit_desc_flag
             ,header_num
             ,ledger_id
             ,ref_ae_header_id
             ,ccid_coa_id
             ,segment1
             ,segment2
             ,segment3
             ,segment4
             ,segment5
             ,segment6
             ,segment7
             ,segment8
             ,segment9
             ,segment10
             ,segment11
             ,segment12
             ,segment13
             ,segment14
             ,segment15
             ,segment16
             ,segment17
             ,segment18
             ,segment19
             ,segment20
             ,segment21
             ,segment22
             ,segment23
             ,segment24
             ,segment25
             ,segment26
             ,segment27
             ,segment28
             ,segment29
             ,segment30)
          (SELECT
              ael.ae_header_id
             ,ael.ae_line_num
             ,ael.ae_line_num
             ,'N'
             ,ael.ae_header_id
             ,ael.ledger_id
             ,ael.ae_header_id
             ,gcc.chart_of_accounts_id
             ,decode(segment_code, 'SEGMENT1', to_value, gcc.segment1)
             ,decode(segment_code, 'SEGMENT2', to_value, gcc.segment2)
             ,decode(segment_code, 'SEGMENT3', to_value, gcc.segment3)
             ,decode(segment_code, 'SEGMENT4', to_value, gcc.segment4)
             ,decode(segment_code, 'SEGMENT5', to_value, gcc.segment5)
             ,decode(segment_code, 'SEGMENT6', to_value, gcc.segment6)
             ,decode(segment_code, 'SEGMENT7', to_value, gcc.segment7)
             ,decode(segment_code, 'SEGMENT8', to_value, gcc.segment8)
             ,decode(segment_code, 'SEGMENT9', to_value, gcc.segment9)
             ,decode(segment_code, 'SEGMENT10', to_value, gcc.segment10)
             ,decode(segment_code, 'SEGMENT11', to_value, gcc.segment11)
             ,decode(segment_code, 'SEGMENT12', to_value, gcc.segment12)
             ,decode(segment_code, 'SEGMENT13', to_value, gcc.segment13)
             ,decode(segment_code, 'SEGMENT14', to_value, gcc.segment14)
             ,decode(segment_code, 'SEGMENT15', to_value, gcc.segment15)
             ,decode(segment_code, 'SEGMENT16', to_value, gcc.segment16)
             ,decode(segment_code, 'SEGMENT17', to_value, gcc.segment17)
             ,decode(segment_code, 'SEGMENT18', to_value, gcc.segment18)
             ,decode(segment_code, 'SEGMENT19', to_value, gcc.segment19)
             ,decode(segment_code, 'SEGMENT20', to_value, gcc.segment20)
             ,decode(segment_code, 'SEGMENT21', to_value, gcc.segment21)
             ,decode(segment_code, 'SEGMENT22', to_value, gcc.segment22)
             ,decode(segment_code, 'SEGMENT23', to_value, gcc.segment23)
             ,decode(segment_code, 'SEGMENT24', to_value, gcc.segment24)
             ,decode(segment_code, 'SEGMENT25', to_value, gcc.segment25)
             ,decode(segment_code, 'SEGMENT26', to_value, gcc.segment26)
             ,decode(segment_code, 'SEGMENT27', to_value, gcc.segment27)
             ,decode(segment_code, 'SEGMENT28', to_value, gcc.segment28)
             ,decode(segment_code, 'SEGMENT29', to_value, gcc.segment29)
             ,decode(segment_code, 'SEGMENT30', to_value, gcc.segment30)
          FROM xla_merge_seg_maps map
             ,gl_code_combinations gcc
             ,xla_ae_lines ael
             ,xla_ae_headers aeh
             ,XLA_PARTIAL_MERGE_TXNS xpmt
             ,XLA_LEDGER_RELATIONSHIPS_V rs
             ,gl_ledgers gld
          WHERE ael.PARTY_ID = p_old_party_id
            AND (p_old_site_id IS NULL
                OR ael.PARTY_SITE_ID = p_old_site_id)
            AND ael.PARTY_TYPE_CODE = p_party_type
            AND ael.APPLICATION_ID = aeh.APPLICATION_ID
            AND ael.AE_HEADER_ID = aeh.AE_HEADER_ID
            AND aeh.APPLICATION_ID = p_application_id
            AND aeh.accounting_entry_status_code = 'N'
            AND aeh.LEDGER_ID = p_array_ledger_id(i)
            AND aeh.parent_ae_header_id IS NOT NULL
            AND p_array_merge_option(i) = 'TRANSFER'
            AND xpmt.APPLICATION_ID = p_application_id
            AND xpmt.MERGE_EVENT_ID = p_event_id
            AND xpmt.ENTITY_ID = aeh.ENTITY_ID
            AND map.application_id = p_application_id
            and rs.RELATIONSHIP_ENABLED_FLAG = 'Y'
            AND rs.ledger_id = gld.ledger_id
            AND gld.complete_flag = 'Y'
            AND rs.SLA_ACCOUNTING_METHOD_CODE IS NOT NULL
            AND rs.ledger_id = aeh.ledger_id
            AND DECODE(rs.LEDGER_CATEGORY_CODE
                 , 'ALC', rs.PRIMARY_LEDGER_ID
                        , rs.LEDGER_ID) = map.ledger_id
            and map.event_id       = p_event_id
            AND decode(map.segment_code, 'SEGMENT1', gcc.segment1
                  ,'SEGMENT2', gcc.segment2
                  ,'SEGMENT3', gcc.segment3
                  ,'SEGMENT4', gcc.segment4
                  ,'SEGMENT5', gcc.segment5
                  ,'SEGMENT6', gcc.segment6
                  ,'SEGMENT7', gcc.segment7
                  ,'SEGMENT8', gcc.segment8
                  ,'SEGMENT9', gcc.segment9
                  ,'SEGMENT10', gcc.segment10
                  ,'SEGMENT11', gcc.segment11
                  ,'SEGMENT12', gcc.segment12
                  ,'SEGMENT13', gcc.segment13
                  ,'SEGMENT14', gcc.segment14
                  ,'SEGMENT15', gcc.segment15
                  ,'SEGMENT16', gcc.segment16
                  ,'SEGMENT17', gcc.segment17
                  ,'SEGMENT18', gcc.segment18
                  ,'SEGMENT19', gcc.segment19
                  ,'SEGMENT20', gcc.segment20
                  ,'SEGMENT21', gcc.segment21
                  ,'SEGMENT22', gcc.segment22
                  ,'SEGMENT23', gcc.segment23
                  ,'SEGMENT24', gcc.segment24
                  ,'SEGMENT25', gcc.segment25
                  ,'SEGMENT26', gcc.segment26
                  ,'SEGMENT27', gcc.segment27
                  ,'SEGMENT28', gcc.segment28
                  ,'SEGMENT29', gcc.segment29
                  ,'SEGMENT30', gcc.segment30)
                                      = map.FROM_VALUE
             and gcc.code_combination_id = ael.code_combination_id);
    v_row_count :=SQL%ROWCOUNT;
    IF (C_LEVEL_STATEMENT>= g_log_level) THEN
      trace(  p_msg    => '# of lines inserted for mapping change:'||to_char(v_row_count)
            , p_level  => C_LEVEL_STATEMENT
            , p_module => v_module);
    END IF;
  ELSE

    FORALL i IN 1..p_array_ledger_id.count
          INSERT INTO xla_ae_lines_gt (
              ae_header_id
             ,ae_line_num
             ,temp_line_num
             ,inherit_desc_flag
             ,header_num
             ,ledger_id
             ,ref_ae_header_id
             ,ccid_coa_id
             ,segment1
             ,segment2
             ,segment3
             ,segment4
             ,segment5
             ,segment6
             ,segment7
             ,segment8
             ,segment9
             ,segment10
             ,segment11
             ,segment12
             ,segment13
             ,segment14
             ,segment15
             ,segment16
             ,segment17
             ,segment18
             ,segment19
             ,segment20
             ,segment21
             ,segment22
             ,segment23
             ,segment24
             ,segment25
             ,segment26
             ,segment27
             ,segment28
             ,segment29
             ,segment30)
          (SELECT
              ael.ae_header_id
             ,ael.ae_line_num
             ,ael.ae_line_num
             ,'N'
             ,ael.ae_header_id
             ,ael.ledger_id
             ,ael.ae_header_id
             ,gcc.chart_of_accounts_id
             ,decode(segment_code, 'SEGMENT1', to_value, gcc.segment1)
             ,decode(segment_code, 'SEGMENT2', to_value, gcc.segment2)
             ,decode(segment_code, 'SEGMENT3', to_value, gcc.segment3)
             ,decode(segment_code, 'SEGMENT4', to_value, gcc.segment4)
             ,decode(segment_code, 'SEGMENT5', to_value, gcc.segment5)
             ,decode(segment_code, 'SEGMENT6', to_value, gcc.segment6)
             ,decode(segment_code, 'SEGMENT7', to_value, gcc.segment7)
             ,decode(segment_code, 'SEGMENT8', to_value, gcc.segment8)
             ,decode(segment_code, 'SEGMENT9', to_value, gcc.segment9)
             ,decode(segment_code, 'SEGMENT10', to_value, gcc.segment10)
             ,decode(segment_code, 'SEGMENT11', to_value, gcc.segment11)
             ,decode(segment_code, 'SEGMENT12', to_value, gcc.segment12)
             ,decode(segment_code, 'SEGMENT13', to_value, gcc.segment13)
             ,decode(segment_code, 'SEGMENT14', to_value, gcc.segment14)
             ,decode(segment_code, 'SEGMENT15', to_value, gcc.segment15)
             ,decode(segment_code, 'SEGMENT16', to_value, gcc.segment16)
             ,decode(segment_code, 'SEGMENT17', to_value, gcc.segment17)
             ,decode(segment_code, 'SEGMENT18', to_value, gcc.segment18)
             ,decode(segment_code, 'SEGMENT19', to_value, gcc.segment19)
             ,decode(segment_code, 'SEGMENT20', to_value, gcc.segment20)
             ,decode(segment_code, 'SEGMENT21', to_value, gcc.segment21)
             ,decode(segment_code, 'SEGMENT22', to_value, gcc.segment22)
             ,decode(segment_code, 'SEGMENT23', to_value, gcc.segment23)
             ,decode(segment_code, 'SEGMENT24', to_value, gcc.segment24)
             ,decode(segment_code, 'SEGMENT25', to_value, gcc.segment25)
             ,decode(segment_code, 'SEGMENT26', to_value, gcc.segment26)
             ,decode(segment_code, 'SEGMENT27', to_value, gcc.segment27)
             ,decode(segment_code, 'SEGMENT28', to_value, gcc.segment28)
             ,decode(segment_code, 'SEGMENT29', to_value, gcc.segment29)
             ,decode(segment_code, 'SEGMENT30', to_value, gcc.segment30)
          FROM xla_merge_seg_maps map
             ,gl_code_combinations gcc
             ,xla_ae_lines ael
             ,xla_ae_headers aeh
             ,XLA_LEDGER_RELATIONSHIPS_V rs
             ,gl_ledgers gld
          WHERE ael.PARTY_ID = p_old_party_id
            AND (p_old_site_id IS NULL
                OR ael.PARTY_SITE_ID = p_old_site_id)
            AND ael.PARTY_TYPE_CODE = p_party_type
            AND ael.APPLICATION_ID = aeh.APPLICATION_ID
            AND ael.AE_HEADER_ID = aeh.AE_HEADER_ID
            AND aeh.APPLICATION_ID = p_application_id
            AND aeh.accounting_entry_status_code = 'N'
            AND aeh.LEDGER_ID = p_array_ledger_id(i)
            AND aeh.parent_ae_header_id IS NOT NULL
            AND p_array_merge_option(i) = 'TRANSFER'
            AND map.application_id = p_application_id
            and rs.RELATIONSHIP_ENABLED_FLAG = 'Y'
            AND rs.ledger_id = gld.ledger_id
            AND gld.complete_flag = 'Y'
            AND rs.SLA_ACCOUNTING_METHOD_CODE IS NOT NULL
            AND rs.ledger_id = aeh.ledger_id
            AND DECODE(rs.LEDGER_CATEGORY_CODE
                 , 'ALC', rs.PRIMARY_LEDGER_ID
                        , rs.LEDGER_ID) = map.ledger_id
            and map.event_id       = p_event_id
            AND decode(map.segment_code, 'SEGMENT1', gcc.segment1
                  ,'SEGMENT2', gcc.segment2
                  ,'SEGMENT3', gcc.segment3
                  ,'SEGMENT4', gcc.segment4
                  ,'SEGMENT5', gcc.segment5
                  ,'SEGMENT6', gcc.segment6
                  ,'SEGMENT7', gcc.segment7
                  ,'SEGMENT8', gcc.segment8
                  ,'SEGMENT9', gcc.segment9
                  ,'SEGMENT10', gcc.segment10
                  ,'SEGMENT11', gcc.segment11
                  ,'SEGMENT12', gcc.segment12
                  ,'SEGMENT13', gcc.segment13
                  ,'SEGMENT14', gcc.segment14
                  ,'SEGMENT15', gcc.segment15
                  ,'SEGMENT16', gcc.segment16
                  ,'SEGMENT17', gcc.segment17
                  ,'SEGMENT18', gcc.segment18
                  ,'SEGMENT19', gcc.segment19
                  ,'SEGMENT20', gcc.segment20
                  ,'SEGMENT21', gcc.segment21
                  ,'SEGMENT22', gcc.segment22
                  ,'SEGMENT23', gcc.segment23
                  ,'SEGMENT24', gcc.segment24
                  ,'SEGMENT25', gcc.segment25
                  ,'SEGMENT26', gcc.segment26
                  ,'SEGMENT27', gcc.segment27
                  ,'SEGMENT28', gcc.segment28
                  ,'SEGMENT29', gcc.segment29
                  ,'SEGMENT30', gcc.segment30)
                                      = map.FROM_VALUE
             and gcc.code_combination_id = ael.code_combination_id);
    v_row_count :=SQL%ROWCOUNT;
    IF (C_LEVEL_STATEMENT>= g_log_level) THEN
      trace(  p_msg    => '# of lines inserted for mapping change:'||to_char(v_row_count)
            , p_level  => C_LEVEL_STATEMENT
            , p_module => v_module);
    END IF;
  END IF;

  RETURN v_row_count;

END populate_gt_for_mapping;


--  this function process the account mapping for incomplete entries
PROCEDURE process_incomplete_acct_map(
        p_application_id       IN NUMBER
        ,p_event_id            IN NUMBER
        ,p_event_merge_option    IN VARCHAR2
        ,p_entity_id             IN NUMBER
        ,p_merge_date            IN DATE
        ,p_merge_type            IN VARCHAR2
        ,p_old_site_id           IN NUMBER
        ,p_old_party_id          IN NUMBER
        ,p_new_site_id           IN NUMBER
        ,p_new_party_id          IN NUMBER
        ,p_party_type            IN VARCHAR2
        ,p_array_ledger_id       IN xla_accounting_cache_pkg.t_array_ledger_id
        ,p_array_ledger_category IN t_varchar30_array
        ,p_array_reversal_option IN t_varchar30_array
        ,p_array_merge_option    IN t_varchar30_array) IS
v_function VARCHAR2(240);
v_module   VARCHAR2(240);
cursor c_null_ccid is
  select 1
    from xla_ae_lines_gt
   where code_combination_id is null;
v_row_count     NUMBER;
begin
  v_function              := 'xla_third_party_merge.process_incomplete_acct_map';
  v_module                := C_DEFAULT_MODULE||'.process_incomplete_acct_map';

  -- Log the function entry, the passed parameters and their values
  IF (C_LEVEL_PROCEDURE >= g_log_level)
  THEN
    trace(  p_msg    => 'BEGIN - ' || v_function
          , p_level  => C_LEVEL_PROCEDURE
          , p_module => v_module);
  END IF; -- IF (C_LEVEL_PROCEDURE >= g_log_level)

  v_row_count := populate_gt_for_mapping(
           p_application_id        => p_application_id
           ,p_event_id              => p_event_id
           ,p_merge_type            => p_merge_type
           ,p_old_site_id           => p_old_site_id
           ,p_old_party_id          => p_old_party_id
           ,p_new_site_id           => p_new_site_id
           ,p_new_party_id          => p_new_party_id
           ,p_party_type            => p_party_type
           ,p_array_ledger_id       => p_array_ledger_id
           ,p_array_reversal_option => p_array_reversal_option
           ,p_array_merge_option    => p_array_merge_option);

  IF (C_LEVEL_STATEMENT>= g_log_level)
  THEN
    trace(  p_msg    => 'function populate_gt_for_mapping returns: '||to_char(v_row_count)
          , p_level  => C_LEVEL_STATEMENT
          , p_module => v_module);
  END IF;

  IF(v_row_count = 0) THEN
    RETURN;
  -- there is no row that need account mapping
  END IF;

  -- populate the ccid into gt table
  populate_ccid_to_gt;

  IF (C_LEVEL_STATEMENT>= g_log_level)
  THEN
    trace(  p_msg    => 'after procedure populate_ccid_to_gt'
          , p_level  => C_LEVEL_STATEMENT
          , p_module => v_module);
  END IF;

  -- populate the ccid back to the lines table

  UPDATE
         (SELECT xalg.code_combination_id
                 , xal.code_combination_id code_combination_id1
            FROM xla_ae_lines_gt xalg
                 , xla_ae_lines xal
           WHERE xalg.ae_header_id      = xal.ae_header_id
             AND xalg.ae_line_num       = xal.ae_line_num
             AND xal.application_id     = p_application_id
             AND xalg.temp_line_num     = xal.ae_line_num
             AND xalg.ref_ae_header_id  = xal.ae_header_id
             AND xalg.ledger_id         = xal.ledger_id
             AND xalg.header_num        = xal.ae_header_id
             AND xalg.inherit_desc_flag = 'N')
  SET code_combination_id1 = code_combination_id;

  IF (C_LEVEL_STATEMENT>= g_log_level)
  THEN
    trace(  p_msg    => '# of lines updated:'||to_char(SQL%ROWCOUNT)
          , p_level  => C_LEVEL_STATEMENT
          , p_module => v_module);
  END IF;

  IF (C_LEVEL_PROCEDURE>= g_log_level)
  THEN
    trace(  p_msg    => 'End of '||v_function
          , p_level  => C_LEVEL_PROCEDURE
          , p_module => v_module);
  END IF;

END process_incomplete_acct_map;




PROCEDURE generate_headers(
        p_application_id       IN NUMBER
        ,p_reverse_header_desc  IN VARCHAR2
        ,p_accounting_mode  IN VARCHAR2
) IS
v_function VARCHAR2(240);
v_module   VARCHAR2(240);
v_query_str VARCHAR2(2000);
begin
  v_function              := 'xla_third_party_merge.generate_headers';
  v_module                := C_DEFAULT_MODULE||'.generate_headers';

  -- Log the function entry, the passed parameters and their values
  IF (C_LEVEL_PROCEDURE >= g_log_level)
  THEN
    trace(  p_msg    => 'BEGIN - ' || v_function
          , p_level  => C_LEVEL_PROCEDURE
          , p_module => v_module);
  END IF; -- IF (C_LEVEL_PROCEDURE >= g_log_level)

  INSERT INTO xla_ae_headers_gt
          ( ae_header_id
          , accounting_entry_status_code
          , accounting_entry_type_code
          , GL_TRANSFER_STATUS_CODE
          , ledger_id
          , entity_id
          , event_id
          , event_type_code
          , accounting_date
          , je_category_name
          , period_name
          , description
          , balance_type_code
          , amb_context_code
          , budget_version_id
          -- 5103972
          -- Used at the end of this procedure to find ae header ids
          -- to be stamped on xla_ae_lines_gt
          , parent_header_id
        )
        (select xla_ae_headers_s.nextval
                ,p_accounting_mode
                ,'MERGE'
                ,'N'
                ,ledger_id
                , entity_id
                , event_id
                , event_type_code
                , accounting_date
                , je_category_name
                , period_name
                , description || p_reverse_header_desc
                , balance_type_code
                , null
                , ae_header_id
                , ref_ae_header_id -- 5103972
         from
           (select distinct xah.ledger_id
                , xah.entity_id
                , xah.event_id
                , xah.event_type_code
                , xah.accounting_date
                , xah.je_category_name
                , xah.period_name
                , xah.description
                , xah.balance_type_code
                , xal.ae_header_id
                , xal.ref_ae_header_id -- 5103972
                from xla_ae_headers xah
                    ,xla_ae_lines_gt xal
                where xah.application_id = p_application_id
                and xah.ae_header_id =xal.ref_ae_header_id
                and xal.reversal_code = 'REBOOKING'));

  IF (C_LEVEL_STATEMENT>= g_log_level)
  THEN
    trace(  p_msg    => '# of header inserted:'||to_char(SQL%ROWCOUNT)
          , p_level  => C_LEVEL_STATEMENT
          , p_module => v_module);
  END IF;

  UPDATE xla_ae_headers_gt xah
     SET (accounting_date, period_name) =
         (SELECT start_date, period_name
            FROM gl_period_statuses
           WHERE ledger_id = xah.ledger_id
             AND application_id = 101
             AND adjustment_period_flag = 'N'
             AND closing_status in ('O', 'F')
             AND start_date =
                 (SELECT min(gps.start_date)
                    FROM gl_period_statuses gps
                   WHERE ledger_id = xah.ledger_id
                     AND application_id = 101
                     AND adjustment_period_flag = 'N'
                     AND start_date > xah.accounting_date
                     AND closing_status in ('O', 'F')))
   WHERE period_name in
      (SELECT period_name
         FROM gl_period_statuses gps2
        WHERE gps2.ledger_id = xah.ledger_id
          AND gps2.adjustment_period_flag = 'N'
          AND gps2.closing_status = 'C'
          AND gps2.period_name = xah.period_name);

  IF (C_LEVEL_STATEMENT>= g_log_level)
  THEN
    trace(  p_msg    => '# of header have gl date updated:'||to_char(SQL%ROWCOUNT)
          , p_level  => C_LEVEL_STATEMENT
          , p_module => v_module);
  END IF;

  UPDATE xla_ae_lines_gt xal
      SET (ae_header_id, accounting_date) =
           (SELECT ae_header_id, accounting_date
              FROM xla_ae_headers_gt xah
             WHERE xal.event_id = xah.event_id
               AND xal.ledger_id = xah.ledger_id
               -- 5103972
               -- Without the following line, this SQL fails as one event_id
               -- could have multiple ae headers (mpa).
               AND xal.ref_ae_header_id = xah.parent_header_id);

  IF (C_LEVEL_STATEMENT>= g_log_level)
  THEN
    trace(  p_msg    => '# of lines updated:'||to_char(SQL%ROWCOUNT)
          , p_level  => C_LEVEL_STATEMENT
          , p_module => v_module);
  END IF;

  IF (C_LEVEL_PROCEDURE>= g_log_level)
  THEN
    trace(  p_msg    => 'End of '||v_function
          , p_level  => C_LEVEL_PROCEDURE
          , p_module => v_module);
  END IF;

END generate_headers;
-- ----------------------------------------------------------------------------
-- Create third party merge accounting routine
-- ----------------------------------------------------------------------------
PROCEDURE create_accounting
 (  x_errbuf                    OUT NOCOPY VARCHAR2
  , x_retcode                   OUT NOCOPY VARCHAR2
  , p_application_id            IN INTEGER
  , p_event_id                  IN INTEGER DEFAULT NULL
  , p_accounting_mode           IN VARCHAR2
  , p_transfer_to_gl_flag       IN VARCHAR2
  , p_post_in_gl_flag           IN VARCHAR2
  , p_merge_event_set_id        IN INTEGER DEFAULT NULL
  , p_srs_flag                  IN VARCHAR2 DEFAULT NULL) IS

  v_function VARCHAR2(240);
  v_module   VARCHAR2(240);
  v_message  VARCHAR2(2000);
  v_dummy    VARCHAR2(1);

  v_application_name      VARCHAR2(240);
  v_valuation_method_flag VARCHAR2(1);

  CURSOR mergeEvent_cur IS
   SELECT evt.event_id,
          evt.event_type_code,
          evt.event_date,
          evt.process_status_code,
          evt.reference_num_1          old_party_id,
          evt.reference_num_2          old_site_id,
          evt.reference_num_3          new_party_id,
          evt.reference_num_4          new_site_id,
          p1.third_party_number        original_party_number,
          s1.third_party_site_code     original_site_code,
          p2.third_party_number        new_party_number,
          s2.third_party_site_code     new_site_code,
          evt.reference_char_1         party_type,
          evt.reference_char_2         mapping_flag,
          ent.entity_id,
          ent.source_application_id,
          ent.ledger_id
   FROM   xla_events evt,
          xla_third_parties_v p1,
          xla_third_parties_v p2,
          xla_third_party_sites_v s1,
          xla_third_party_sites_v s2,
          xla_transaction_entities ent,
          xla_ledger_options lgopt,
          xla_launch_options lnopt
   WHERE /*(p_event_id IS NULL OR evt.EVENT_ID = p_event_id)
   AND   (   p_merge_event_set_id IS NULL
          OR evt.MERGE_EVENT_SET_ID = p_merge_event_set_id)*/
	  evt.EVENT_ID = nvl(p_event_id,evt.EVENT_ID)
   AND evt.MERGE_EVENT_SET_ID = nvl(p_merge_event_set_id,evt.MERGE_EVENT_SET_ID)
   AND evt.APPLICATION_ID = p_application_id
   AND evt.EVENT_TYPE_CODE IN ('PARTIAL_MERGE', 'FULL_MERGE')
   AND evt.PROCESS_STATUS_CODE not in ('P','F') -- Modified by krsankar for RCA bug 8396757
   AND p1.THIRD_PARTY_ID = evt.REFERENCE_NUM_1
   AND p1.THIRD_PARTY_TYPE = evt.REFERENCE_CHAR_1
   AND p2.THIRD_PARTY_ID = evt.REFERENCE_NUM_3
   AND p2.THIRD_PARTY_TYPE = evt.REFERENCE_CHAR_1
   AND s1.THIRD_PARTY_ID (+) = evt.REFERENCE_NUM_1
   AND s1.THIRD_PARTY_SITE_ID (+) = evt.REFERENCE_NUM_2
   AND s1.THIRD_PARTY_TYPE (+) = evt.REFERENCE_CHAR_1
   AND s2.THIRD_PARTY_ID (+) = evt.REFERENCE_NUM_3
   AND s2.THIRD_PARTY_SITE_ID (+) = evt.REFERENCE_NUM_4
   AND s2.THIRD_PARTY_TYPE (+) = evt.REFERENCE_CHAR_1
   AND ent.APPLICATION_ID = evt.APPLICATION_ID
   AND ent.ENTITY_ID = evt.ENTITY_ID
   AND ent.ENTITY_CODE = 'THIRD_PARTY_MERGE'
   AND lgopt.APPLICATION_ID = ent.APPLICATION_ID
   AND lgopt.LEDGER_ID = ent.LEDGER_ID
   AND lgopt.ENABLED_FLAG = 'Y'
   AND lnopt.APPLICATION_ID = lgopt.APPLICATION_ID
   AND lnopt.LEDGER_ID = lgopt.LEDGER_ID
   AND (    lnopt.ACCOUNTING_MODE_OVERRIDE_FLAG = 'Y'
         OR (lnopt.ACCOUNTING_MODE_OVERRIDE_FLAG = 'N'
             AND lnopt.ACCOUNTING_MODE_CODE = p_accounting_mode))
   AND (    lnopt.SUBMIT_TRANSFER_OVERRIDE_FLAG = 'Y'
         OR (lnopt.SUBMIT_TRANSFER_OVERRIDE_FLAG = 'N'
             AND lnopt.SUBMIT_TRANSFER_TO_GL_FLAG
                  = p_transfer_to_gl_flag))
   AND (    lnopt.SUBMIT_GL_POST_OVERRIDE_FLAG = 'Y'
         OR (lnopt.SUBMIT_GL_POST_OVERRIDE_FLAG = 'N'
             AND lnopt.SUBMIT_GL_POST_FLAG = p_post_in_gl_flag))
   AND (   g_use_ledger_security = 'N'
        OR (g_use_ledger_security = 'Y'
            AND NOT EXISTS
            (SELECT 'Ledger without access'
             FROM XLA_LEDGER_RELATIONSHIPS_V rs,
                  XLA_LEDGER_OPTIONS lgopt2,
                  gl_ledgers gld
             WHERE rs.RELATIONSHIP_ENABLED_FLAG = 'Y'
             AND rs.ledger_id = gld.ledger_id
             AND gld.complete_flag = 'Y'
             AND rs.SLA_ACCOUNTING_METHOD_CODE IS NOT NULL
             AND DECODE(v_valuation_method_flag
                  , 'N', rs.PRIMARY_LEDGER_ID
                       , DECODE(rs.LEDGER_CATEGORY_CODE
                         , 'ALC', rs.PRIMARY_LEDGER_ID
                                , rs.LEDGER_ID)) = lgopt.LEDGER_ID
             AND DECODE(rs.LEDGER_CATEGORY_CODE
                  , 'ALC', rs.PRIMARY_LEDGER_ID
                         , rs.LEDGER_ID) = lgopt2.LEDGER_ID
             AND lgopt2.APPLICATION_ID = lgopt.APPLICATION_ID
             AND lgopt2.ENABLED_FLAG = 'Y'
             AND lgopt2.MERGE_ACCT_OPTION_CODE <> 'NONE'
             AND rs.LEDGER_ID NOT IN
                 (SELECT asa.LEDGER_ID
                    FROM GL_ACCESS_SET_ASSIGNMENTS asa
                   WHERE asa.ACCESS_SET_ID
                                          IN (g_access_set_id, g_sec_access_set_id)))))
   ORDER BY evt.EVENT_DATE, evt.EVENT_ID;

  v_event_id                 NUMBER(15);
  v_merge_type               VARCHAR2(30);
  v_merge_date               DATE;
  v_process_status           VARCHAR2(1);
  v_old_party_id             NUMBER(15);
  v_old_site_id              NUMBER(15);
  v_new_party_id             NUMBER(15);
  v_new_site_id              NUMBER(15);
--  v_original_desc_token    VARCHAR2(1000);
  v_original_party_number    xla_third_parties_v.third_party_number%TYPE;
  v_original_site_code       xla_third_party_sites_v.third_party_site_code%TYPE;
--  v_new_desc_token           VARCHAR2(1000);
  v_new_party_number         xla_third_parties_v.third_party_number%TYPE;
  v_new_site_code            xla_third_party_sites_v.third_party_site_code%TYPE;
  v_party_type               VARCHAR2(1);
  v_mapping_flag             VARCHAR2(1);
  v_entity_id                NUMBER(15);
  v_src_appl_id              NUMBER(15);
  v_event_ledger_id          NUMBER(15);

  v_array_ledger_id          xla_accounting_cache_pkg.t_array_ledger_id;
  v_array_ledger_category    t_varchar30_array;
  v_array_rounding_rule_code t_varchar30_array;
  v_array_mau                t_number_array;
  v_array_currency_code      t_varchar30_array;
  v_array_reversal_option    t_varchar30_array;
  v_array_merge_option       t_varchar30_array;
  v_array_submit_transfer    t_varchar1_array;

  v_event_merge_option       VARCHAR2(30);
  v_ael_desc1                VARCHAR2(1996);
  v_ael_desc2                VARCHAR2(1996);
  v_ael_desc3                VARCHAR2(1996);
  v_ael_desc4                VARCHAR2(1996);
  v_processed_event_count    NUMBER;


  /* Added by krsankar for RCA bug 8396757 */
  v_ledger_id                NUMBER;
  v_acctg_mode_code          VARCHAR2(10);

BEGIN
  -- --------------------------
  -- Initialize local variables
  -- --------------------------
  v_function              := 'xla_third_party_merge.create_accounting';
  v_module                := C_DEFAULT_MODULE||'.create_accounting';
  v_event_merge_option    := 'NONE';
  v_processed_event_count := 0;

  -- Log the function entry, the passed parameters and their values
  IF (C_LEVEL_PROCEDURE >= g_log_level)
  THEN
    trace(  p_msg    => 'BEGIN - ' || v_function
          , p_level  => C_LEVEL_PROCEDURE
          , p_module => v_module);
    trace(  p_msg    => 'p_applicaiton_id = ' || p_application_id
                         || ', p_event_id = ' || p_event_id
                         || ', p_transfer_to_gl_flag = ' || p_transfer_to_gl_flag
                         || ', p_post_in_gl_flag = ' || p_post_in_gl_flag
                         || ', p_merge_event_set_id = ' || p_merge_event_set_id
                         || ', p_srs_flag = ' || p_srs_flag
          , p_level  => C_LEVEL_PROCEDURE
          , p_module => v_module);
  END IF; -- IF (C_LEVEL_PROCEDURE >= g_log_level)

  -- -----------------------
  -- Validate the parameters
  -- -----------------------

  -- Validate if the passed application is defined in XLA_SUBLEDGERS
  BEGIN
    SELECT f.APPLICATION_NAME, s.VALUATION_METHOD_FLAG
      INTO v_application_name, v_valuation_method_flag
      FROM XLA_SUBLEDGERS s, FND_APPLICATION_VL f
     WHERE s.APPLICATION_ID = f.APPLICATION_ID
       AND s.APPLICATION_ID = p_application_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      v_message := xla_messages_pkg.get_message
                    (  p_appli_s_name => 'XLA'
                     , p_msg_name     => 'XLA_MERGE_INVALID_PARAM'
                     , p_token_1      => 'PARAMETER_VALUE'
                     , p_value_1      => p_application_id
                     , p_token_2      => 'PARAMETER'
                     , p_value_2      => 'p_application_id');
      RAISE ValidationError;
  END;

  -- Log values of v_valuation_method_flag, g_use_ledger_security,
  -- g_access_set_id, and g_sec_access_set_id
  trace(  p_msg    => 'v_valuation_method_flag = ' || v_valuation_method_flag
                       || ', g_use_ledger_security = ' || g_use_ledger_security
                       || ', g_access_set_id = ' || g_access_set_id
                       || ', g_sec_access_set_id = ' || g_sec_access_set_id
        , p_level  => C_LEVEL_STATEMENT
        , p_module => v_module);

  IF (p_merge_event_set_id IS NOT NULL)
  THEN
    -- Validate the passed merge event set ID
    BEGIN
      SELECT 'X'
      INTO v_dummy
      FROM XLA_EVENTS
      WHERE EVENT_ID = p_merge_event_set_id
      AND EVENT_TYPE_CODE IN ('PARTIAL_MERGE', 'FULL_MERGE');
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_message := xla_messages_pkg.get_message
                      (  p_appli_s_name => 'XLA'
                       , p_msg_name     => 'XLA_MERGE_INVALID_PARAM'
                       , p_token_1      => 'PARAMETER_VALUE'
                       , p_value_1      => p_merge_event_set_id
                       , p_token_2      => 'PARAMETER'
                       , p_value_2      => 'p_merge_event_set_id');
      RAISE ValidationError;
    END;
  ELSIF (p_event_id IS NOT NULL)
  THEN
    -- Validate the passed event ID
    BEGIN
      SELECT 'X'
      INTO v_dummy
      FROM XLA_EVENTS
      WHERE EVENT_ID = p_event_id
      AND EVENT_TYPE_CODE IN ('PARTIAL_MERGE', 'FULL_MERGE');
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_message := xla_messages_pkg.get_message
                      (  p_appli_s_name => 'XLA'
                       , p_msg_name     => 'XLA_MERGE_INVALID_PARAM'
                       , p_token_1      => 'PARAMETER_VALUE'
                       , p_value_1      => p_event_id
                       , p_token_2      => 'PARAMETER'
                       , p_value_2      => 'p_event_id');
      RAISE ValidationError;
    END;
  END IF; -- IF (p_merge_event_set_id IS NOT NULL)

  -- ------------------------------------
  -- Process the third party merge events
  -- ------------------------------------

  -- Loop for each event to process
  OPEN mergeEvent_cur;
  LOOP
    FETCH mergeEvent_cur
     INTO v_event_id
         ,v_merge_type
         ,v_merge_date
         ,v_process_status
         ,v_old_party_id
         ,v_old_site_id
         ,v_new_party_id
         ,v_new_site_id
         ,v_original_party_number
         ,v_original_site_code
         ,v_new_party_number
         ,v_new_site_code
         ,v_party_type
         ,v_mapping_flag
         ,v_entity_id
         ,v_src_appl_id
         ,v_event_ledger_id;
    EXIT WHEN mergeEvent_cur%NOTFOUND;

    IF (C_LEVEL_STATEMENT >= g_log_level)
    THEN
      -- Log the values retrieved from the cursor
      trace(p_msg  =>   'v_event_id = '       || v_event_id
                     || ', v_merge_type = '     || v_merge_type
                     || ', v_merge_date = '     || v_merge_date
                     || ', v_process_status = ' || v_process_status
                     || ', v_old_party_id = '   || v_old_party_id
                     || ', v_old_site_id = '    || v_old_site_id
            , p_level  => C_LEVEL_STATEMENT
            , p_module => v_module);

      trace(p_msg  => 'v_new_party_id = ' || v_new_party_id
                   || ', v_new_site_id = ' || v_new_site_id
                   || ', v_original_party_number = ' || v_original_party_number
                   || ', v_original_site_code = ' || v_original_site_code
                   || ', v_new_party_number = ' || v_new_party_number
                   || ', v_new_site_code = '    || v_new_site_code
            , p_level  => C_LEVEL_STATEMENT
            , p_module => v_module);

      trace(p_msg  => 'v_party_type = ' || v_party_type
                           || ', v_mapping_flag = ' || v_mapping_flag
                           || ', v_entity_id = ' || v_entity_id
                           || ', v_src_appl_id = ' || v_src_appl_id
                           || ', v_event_ledger_id = ' || v_event_ledger_id
            , p_level  => C_LEVEL_STATEMENT
            , p_module => v_module);
    END IF; -- IF (C_LEVEL_STATEMENT >= g_log_level)

    -- Cache the ledgers to be processed for the current merge event
    trace(  p_msg    => 'Cache the ledgers for the current merge event'
          , p_level  => C_LEVEL_STATEMENT
          , p_module => v_module);

    SELECT rs.LEDGER_ID,
           rs.LEDGER_CATEGORY_CODE,
           lgopt.ACCT_REVERSAL_OPTION_CODE,
           nvl(lgopt.MERGE_ACCT_OPTION_CODE, 'NONE'),
           lgopt.ROUNDING_RULE_CODE,
           rs.CURRENCY_CODE,
           nvl(fcu.minimum_accountable_unit, power(10, -1* fcu.precision)),
           'N'
    BULK COLLECT INTO
      v_array_ledger_id,
      v_array_ledger_category,
      v_array_reversal_option,
      v_array_merge_option,
      v_array_rounding_rule_code,
      v_array_currency_code,
      v_array_mau,
      v_array_submit_transfer
    FROM XLA_LEDGER_RELATIONSHIPS_V rs,
         XLA_LEDGER_OPTIONS lgopt,
         FND_CURRENCIES fcu,
         GL_LEDGERS gld
    WHERE rs.RELATIONSHIP_ENABLED_FLAG = 'Y'
    AND rs.ledger_id = gld.ledger_id
    AND gld.complete_flag = 'Y'
    AND rs.SLA_ACCOUNTING_METHOD_CODE IS NOT NULL
    AND DECODE(decode(v_valuation_method_flag, 'N', 'N', lgopt.capture_event_flag)
         , 'N', rs.PRIMARY_LEDGER_ID
              , DECODE(rs.LEDGER_CATEGORY_CODE
                 , 'ALC', rs.PRIMARY_LEDGER_ID
                        , rs.LEDGER_ID)) = v_event_ledger_id
    AND DECODE(rs.LEDGER_CATEGORY_CODE
         , 'ALC', rs.PRIMARY_LEDGER_ID
                , rs.LEDGER_ID) = lgopt.LEDGER_ID
    AND lgopt.APPLICATION_ID = p_application_id
    AND lgopt.ENABLED_FLAG = 'Y'
    and rs.currency_code          = fcu.currency_code;

    -- Loop for each ledger to log its attribute values and check the third
    -- party merge accounting option in order to set v_event_merge_option
    FOR i IN 1..v_array_ledger_id.COUNT
    LOOP
      -- Log the ledger attribute values
      trace(  p_msg    => 'v_array_ledger_id('||i||') = '
                           || v_array_ledger_id(i)
                           || ', v_array_ledger_category('||i||') = '
                           || v_array_ledger_category(i)
                           || ', v_array_reversal_option('||i||') = '
                           || v_array_reversal_option(i)
                           || ', v_array_merge_option('||i||') = '
                           || v_array_merge_option(i)
            , p_level  => C_LEVEL_STATEMENT
            , p_module => v_module);

      IF (v_event_merge_option = 'NONE' AND v_array_merge_option(i) <> 'NONE')
      THEN
        -- Set the event merge option same as the merge option of current event
        v_event_merge_option := v_array_merge_option(i);
          ELSIF (   (v_event_merge_option = 'CHANGE'
                     AND v_array_merge_option(i) = 'TRANSFER')
                 OR (v_event_merge_option = 'TRANSFER'
                     AND v_array_merge_option(i) = 'CHANGE'))
          THEN
        -- Set the event merge option to 'BOTH'
            v_event_merge_option := 'BOTH';
      END IF; -- IF (v_event_merge_option = 'NONE' AND ...

    END LOOP;

    -- Log the value of v_event_merge_option
    trace(  p_msg    => 'v_event_merge_option = ' || v_event_merge_option
          , p_level  => C_LEVEL_STATEMENT
          , p_module => v_module);

    IF (v_event_merge_option <> 'NONE') THEN

       IF v_old_site_id IS NULL THEN

          -- Get messages for AE header and lines descriptions
          -- this is the description for reverse and rebooking header
          -- and the line desc for 'change' option
          v_ael_desc1 := xla_messages_pkg.get_message
                       (  p_appli_s_name => 'XLA'
                        , p_msg_name     => 'XLA_MERGE_AE_DESC1'
                        , p_token_1      => 'ORIGINAL'
                        , p_value_1      => v_original_party_number
                        , p_token_2      => 'NEW'
                        , p_value_2      => v_new_party_number);

          -- this is the description for transfer balance, both line and  header
          v_ael_desc2 := xla_messages_pkg.get_message
                        (  p_appli_s_name => 'XLA'
                         , p_msg_name     => 'XLA_MERGE_AE_DESC2'
                         , p_token_1      => 'ORIGINAL'
                         , p_value_1      => v_original_party_number
                         , p_token_2      => 'NEW'
                         , p_value_2      => v_new_party_number);

          -- this is the description for reverse lines
          v_ael_desc3 := xla_messages_pkg.get_message
                       (  p_appli_s_name => 'XLA'
                        , p_msg_name     => 'XLA_MERGE_AE_DESC3'
                        , p_token_1      => 'ORIGINAL'
                        , p_value_1      => v_original_party_number
                        , p_token_2      => 'NEW'
                        , p_value_2      => v_new_party_number);

          -- this is the description for rebooking lines
          v_ael_desc4 := xla_messages_pkg.get_message
                        (  p_appli_s_name => 'XLA'
                         , p_msg_name     => 'XLA_MERGE_AE_DESC4'
                         , p_token_1      => 'ORIGINAL'
                         , p_value_1      => v_original_party_number
                         , p_token_2      => 'NEW'
                         , p_value_2      => v_new_party_number);

       ELSE -- v_old_site_id IS NOT NULL

          --
          -- Get messages for AE header and lines descriptions
          -- this is the description for reverse and rebooking header
          -- and the line desc for 'change' option
          --
          -- Use message XLA_MERGE_AE_DESC_SITE<N> as site code is populated
          --
          v_ael_desc1 := xla_messages_pkg.get_message
                       (  p_appli_s_name => 'XLA'
                        , p_msg_name     => 'XLA_MERGE_AE_DESC_SITE1'
                         , p_token_1      => 'ORIGINAL_PARTY_NUMBER'
                         , p_value_1      => v_original_party_number
                         , p_token_2      => 'ORIGINAL_PARTY_SITE_CODE'
                         , p_value_2      => v_original_site_code
                         , p_token_3      => 'NEW_PARTY_NUMBER'
                         , p_value_3      => v_new_party_number
                         , p_token_4      => 'NEW_PARTY_SITE_CODE'
                         , p_value_4      => v_new_site_code);

          -- this is the description for transfer balance, both line and  header
          v_ael_desc2 := xla_messages_pkg.get_message
                        (  p_appli_s_name => 'XLA'
                         , p_msg_name     => 'XLA_MERGE_AE_DESC_SITE2'
                         , p_token_1      => 'ORIGINAL_PARTY_NUMBER'
                         , p_value_1      => v_original_party_number
                         , p_token_2      => 'ORIGINAL_PARTY_SITE_CODE'
                         , p_value_2      => v_original_site_code
                         , p_token_3      => 'NEW_PARTY_NUMBER'
                         , p_value_3      => v_new_party_number
                         , p_token_4      => 'NEW_PARTY_SITE_CODE'
                         , p_value_4      => v_new_site_code);

          -- this is the description for reverse lines
          v_ael_desc3 := xla_messages_pkg.get_message
                        (  p_appli_s_name => 'XLA'
                         , p_msg_name     => 'XLA_MERGE_AE_DESC_SITE3'
                         , p_token_1      => 'ORIGINAL_PARTY_NUMBER'
                         , p_value_1      => v_original_party_number
                         , p_token_2      => 'ORIGINAL_PARTY_SITE_CODE'
                         , p_value_2      => v_original_site_code
                         , p_token_3      => 'NEW_PARTY_NUMBER'
                         , p_value_3      => v_new_party_number
                         , p_token_4      => 'NEW_PARTY_SITE_CODE'
                         , p_value_4      => v_new_site_code);

          -- this is the description for rebooking lines
          v_ael_desc4 := xla_messages_pkg.get_message
                        (  p_appli_s_name => 'XLA'
                         , p_msg_name     => 'XLA_MERGE_AE_DESC_SITE4'
                         , p_token_1      => 'ORIGINAL_PARTY_NUMBER'
                         , p_value_1      => v_original_party_number
                         , p_token_2      => 'ORIGINAL_PARTY_SITE_CODE'
                         , p_value_2      => v_original_site_code
                         , p_token_3      => 'NEW_PARTY_NUMBER'
                         , p_value_3      => v_new_party_number
                         , p_token_4      => 'NEW_PARTY_SITE_CODE'
                         , p_value_4      => v_new_site_code);
       END IF;
    END IF; -- IF (v_event_merge_option <> 'NONE')

    IF (v_process_status = 'D') THEN
      -- ----------------------------------------------------------------
      -- Delete all the draft entries created for this merge event if the
      -- current event process status is 'D'
      -- ----------------------------------------------------------------
      trace(  p_msg    => 'Delete draft entries'
            , p_level  => C_LEVEL_STATEMENT
            , p_module => v_module);

      delete_je (
          p_application_id   => p_application_id
        , p_event_id         => v_event_id);

    END IF;

    IF (v_event_merge_option = 'TRANSFER' OR v_event_merge_option = 'BOTH')
    THEN
      -- ---------------------------------------------------------------------
      -- Transfer third party balances if the event merge option is 'TRANSFER'
      -- or 'BOTH'
      -- ---------------------------------------------------------------------
      trace(  p_msg    => 'Start to transfer third party balances'
            , p_level  => C_LEVEL_STATEMENT
            , p_module => v_module);

      -- ---------------------------------------------------------------------
      -- create journal entries for the event: v_event_id for all the ledgers
      -- ---------------------------------------------------------------------
      create_work_table(
         p_request_id            => XLA_ENVIRONMENT_PKG.g_req_id
        ,p_application_id        => p_application_id
        ,p_event_id              => v_event_id
        ,p_merge_date            => v_merge_date
        ,p_merge_type            => v_merge_type
        ,p_old_site_id           => v_old_site_id
        ,p_old_party_id          => v_old_party_id
        ,p_new_site_id           => v_new_site_id
        ,p_new_party_id          => v_new_party_id
        ,p_party_type            => v_party_type
        ,p_array_ledger_id       => v_array_ledger_id
        ,p_array_merge_option    => v_array_merge_option);

      create_journal_entries(
        x_errbuf                 => x_errbuf
        ,x_retcode               => x_retcode
        ,p_application_id        => p_application_id
        ,p_accounting_mode       => p_accounting_mode
        ,p_transfer_to_gl_flag   => p_transfer_to_gl_flag
        ,p_post_in_gl_flag       => p_post_in_gl_flag
        ,p_event_id              => v_event_id
        ,p_entity_id             => v_entity_id
        ,p_mapping_flag          => v_mapping_flag
        ,p_event_ledger_id       => v_event_ledger_id
        ,p_merge_date            => v_merge_date
        ,p_merge_type            => v_merge_type
        ,p_old_site_id           => v_old_site_id
        ,p_old_party_id          => v_old_party_id
        ,p_new_site_id           => v_new_site_id
        ,p_new_party_id          => v_new_party_id
        ,p_party_type            => v_party_type
        ,p_balance_desc          => v_ael_desc2
        ,p_reverse_line_desc     => v_ael_desc3
        ,p_rebooking_line_desc   => v_ael_desc4
        ,p_reverse_header_desc   => v_ael_desc1
        ,p_array_ledger_id       => v_array_ledger_id
        ,p_array_ledger_category => v_array_ledger_category
        ,p_array_reversal_option => v_array_reversal_option
        ,p_array_rounding_rule_code => v_array_rounding_rule_code
        ,p_array_mau                => v_array_mau
        ,p_array_merge_option    => v_array_merge_option
        ,p_array_submit_transfer => v_array_submit_transfer);

    END IF; -- IF (v_event_merge_option = 'TRANSFER' OR ...

    IF (v_event_merge_option = 'CHANGE' OR v_event_merge_option = 'BOTH'
    -- 5103972
    -- For incomplete JEs, need to update Third Paryt Information
    -- irrespective of merge options
    OR  v_event_merge_option = 'TRANSFER')
    THEN
      -- --------------------------------------------------------------------
      -- Update third party information if the event merge option is 'CHANGE'
      -- or 'BOTH'
      -- --------------------------------------------------------------------
      trace(  p_msg    => 'Start to update third party information'
            , p_level  => C_LEVEL_STATEMENT
            , p_module => v_module);

      IF(p_accounting_mode = 'F') THEN
        update_journal_entries(
          x_errbuf                 => x_errbuf
          ,x_retcode               => x_retcode
          ,p_application_id        => p_application_id
          ,p_event_id              => v_event_id
          ,p_event_merge_option    => v_event_merge_option
          ,p_entity_id             => v_entity_id
          ,p_mapping_flag          => v_mapping_flag
          ,p_event_ledger_id       => v_event_ledger_id
          ,p_merge_date            => v_merge_date
          ,p_merge_type            => v_merge_type
          ,p_old_site_id           => v_old_site_id
          ,p_old_party_id          => v_old_party_id
          ,p_new_site_id           => v_new_site_id
          ,p_new_party_id          => v_new_party_id
          ,p_party_type            => v_party_type
          ,p_line_desc             => v_ael_desc1
          ,p_array_ledger_id       => v_array_ledger_id
          ,p_array_ledger_category => v_array_ledger_category
          ,p_array_reversal_option => v_array_reversal_option
          ,p_array_merge_option    => v_array_merge_option
          ,p_array_submit_transfer => v_array_submit_transfer);
      END IF;

    END IF; -- IF (v_event_merge_option = 'CHANGE' OR ...

    -- Update the status of this current event
    trace(  p_msg    => 'Update the current event status'
          , p_level  => C_LEVEL_STATEMENT
          , p_module => v_module);

  /*  Added by krsankar for RCA bug 8396757 */

  IF p_accounting_mode IS NULL
  THEN

   BEGIN
    trace(  p_msg    => 'p_accounting_mode is passed as NULL'
          , p_level  => C_LEVEL_STATEMENT
          , p_module => v_module);

    trace(  p_msg    => 'Retrieving p_accounting_mode from subledger options'
          , p_level  => C_LEVEL_STATEMENT
          , p_module => v_module);

      select ledger_id
      into   v_ledger_id
      from   xla_events xe,
             xla_transaction_entities xte
      where  xe.entity_id      = xte.entity_id
      and    xe.application_id = xte.application_id
      and    xe.event_id       = v_event_id
      and    xe.application_id = p_application_id;

    trace(  p_msg    => 'Ledger id fetched for event_id '||v_event_id||' is : '||v_ledger_id
          , p_level  => C_LEVEL_STATEMENT
          , p_module => v_module);

      select accounting_mode_code
      into   v_acctg_mode_code
      from   xla_subledger_options_v
      where  application_id = p_application_id
      and    ledger_id      = v_ledger_id;

    trace(  p_msg    => 'Accounting mode code for ledger id '||v_ledger_id||' is : '||v_acctg_mode_code
          , p_level  => C_LEVEL_STATEMENT
          , p_module => v_module);

  EXCEPTION
  WHEN OTHERS THEN

    trace(  p_msg    => 'Exception in fetching accounting_mode,ledger_id from Ledger setup for event_id : '||v_event_id
          , p_level  => C_LEVEL_STATEMENT
          , p_module => v_module);

    trace(  p_msg    => 'Exception is : '|| sqlerrm
          , p_level  => C_LEVEL_STATEMENT
          , p_module => v_module);

  END;

  END IF;


   /* Based on the p_accounting_mode, if p_accounting_mode is NULL, then v_acctg_mode_code
      is used.v_acctg_mode_code is fetched from ledger setup, for that specific ledger, based
      on whether the ledger has FINAL or DRAFT as its accounting mode.
         So, if the accounting mode is FINAL, then event_status_code = 'P' and
      process_status_code = 'F'.If accounting_mode is DRAFT, then event_status_code = 'U' and
      process_status_code = 'D'. */


    UPDATE XLA_EVENTS
    SET EVENT_STATUS_CODE = DECODE(nvl(p_accounting_mode,v_acctg_mode_code)
                                 , 'F', 'P', EVENT_STATUS_CODE),
        PROCESS_STATUS_CODE = nvl(p_accounting_mode,v_acctg_mode_code) --Added by krsankar for RCA bug 8396757
    WHERE EVENT_ID = v_event_id;

    -- Increment v_processed_event_count by 1
    v_processed_event_count := v_processed_event_count + 1;
  END LOOP;

  -- Log the value of v_processed_event_count
  trace(  p_msg    => 'v_processed_event_count = ' || v_processed_event_count
        , p_level  => C_LEVEL_STATEMENT
        , p_module => v_module);

  IF (v_processed_event_count = 0)
  THEN
    -- No events are processed
    x_errbuf := xla_messages_pkg.get_message
                 (  p_appli_s_name => 'XLA'
                  , p_msg_name     => 'XLA_MERGE_ACCT_NO_EVENT'
                  , p_token_1      => 'SUBLEDGER_APPLICATION_NAME'
                  , p_value_1      => v_application_name);
    -- Log the error message
    trace(  p_msg    => v_message
          , p_level  => C_LEVEL_ERROR
          , p_module => v_module);
    -- Set return code to 'E'

    /* Commented the ELSE part of the code below for bug 8472734.
     If the number of records are processed is 0, still the
     program should complete normally and should not error out.
       But in case there are no events processed, the message is
     printed in the log file saying that there are no third party
     events to be processed */


    /*x_retcode := xla_third_party_merge_pub.G_RET_STS_ERROR;
  ELSE*/

    x_retcode := xla_third_party_merge_pub.G_RET_STS_SUCCESS;

    trace(  p_msg    => 'RETURN SUCCESS'
          , p_level  => C_LEVEL_ERROR
          , p_module => v_module);

  END IF; -- IF (v_processed_event_count = 0)

  -- Log the out parameters, their returned values and function exit
  IF (C_LEVEL_PROCEDURE >= g_log_level)
  THEN
    trace(  p_msg    => 'x_retcode = ' || x_retcode
                             || ', x_errbuf = ' || x_errbuf
          , p_level  => C_LEVEL_PROCEDURE
          , p_module => v_module);
    IF (x_retcode = xla_third_party_merge_pub.G_RET_STS_SUCCESS)
    THEN
      trace(  p_msg    => 'END - ' || v_function
            , p_level  => C_LEVEL_PROCEDURE
            , p_module => v_module);
    ELSE
      trace(  p_msg    => 'EXIT with ERROR - ' || v_function
            , p_level  => C_LEVEL_PROCEDURE
            , p_module => v_module);
    END IF; -- IF (x_retcode = xla_third_party_merge_pub.G_RET_STS_SUCCESS)

  END IF; -- IF (C_LEVEL_PROCEDURE >= g_log_level)

EXCEPTION
  WHEN NoAccountingDateError THEN
    IF (C_LEVEL_PROCEDURE >= g_log_level)
    THEN
      trace(  p_msg    => 'x_retcode = ' || x_retcode
                               || ', x_errbuf = ' || x_errbuf
            , p_level  => C_LEVEL_PROCEDURE
            , p_module => v_module);
      trace(  p_msg    => 'EXIT with ERROR - ' || v_function
            , p_level  => C_LEVEL_PROCEDURE
            , p_module => v_module);
    END IF; -- IF (C_LEVEL_PROCEDURE >= g_log_level)
    x_errbuf := 'No accounting date can be found';
    x_retcode := xla_third_party_merge_pub.G_RET_STS_ERROR;
  WHEN ValidationError THEN
    -- Log the error message
    trace(  p_msg    => v_message
          , p_level  => C_LEVEL_ERROR
          , p_module => v_module);
    -- Set the out parameters
    x_errbuf := xla_messages_pkg.get_message
                 (  p_appli_s_name => 'XLA'
                  , p_msg_name     => 'XLA_MERGE_FATAL_ERR'
                  , p_token_1      => 'FUNCTION'
                  , p_value_1      => v_function
                  , p_token_2      => 'ERROR'
                  , p_value_2      => v_message);
    x_retcode := xla_third_party_merge_pub.G_RET_STS_ERROR;
    -- Log the out parameters, their returned values and function exit
    IF (C_LEVEL_PROCEDURE >= g_log_level)
    THEN
      trace(  p_msg    => 'x_retcode = ' || x_retcode
                               || ', x_errbuf = ' || x_errbuf
            , p_level  => C_LEVEL_PROCEDURE
            , p_module => v_module);
      trace(  p_msg    => 'EXIT with ERROR - ' || v_function
            , p_level  => C_LEVEL_PROCEDURE
            , p_module => v_module);
    END IF; -- IF (C_LEVEL_PROCEDURE >= g_log_level)

  WHEN OTHERS THEN
    -- Get and log the SQL error message
    v_message := SQLERRM;
    trace(  p_msg    => v_message
          , p_level  => C_LEVEL_UNEXPECTED
          , p_module => v_module);
    -- Set the out parameters
    x_errbuf := xla_messages_pkg.get_message
                 (  p_appli_s_name => 'XLA'
                  , p_msg_name     => 'XLA_MERGE_FATAL_ERR'
                  , p_token_1      => 'FUNCTION'
                  , p_value_1      => v_function
                  , p_token_2      => 'ERROR'
                  , p_value_2      => v_message);
    -- Set the return code to 'W' if any event is processed and it doesn't have
        -- merge event set; else, set it to 'U'
    IF (p_merge_event_set_id IS NULL AND v_processed_event_count > 0)
    THEN
      x_retcode := xla_third_party_merge_pub.G_RET_STS_WARN;
    ELSE
      x_retcode := xla_third_party_merge_pub.G_RET_STS_UNEXP_ERROR;
    END IF; -- IF (p_merge_event_set_id IS NULL AND v_processed_event_count > 0)
    -- Log the out parameters, their returned values and function exit
    IF (C_LEVEL_PROCEDURE >= g_log_level)
    THEN
      trace(  p_msg    => 'x_retcode = ' || x_retcode
                               || ', x_errbuf = ' || x_errbuf
            , p_level  => C_LEVEL_PROCEDURE
            , p_module => v_module);
      IF (x_retcode = xla_third_party_merge_pub.G_RET_STS_UNEXP_ERROR)
      THEN
        trace(  p_msg    => 'EXIT with ERROR - ' || v_function
              , p_level  => C_LEVEL_PROCEDURE
              , p_module => v_module);
      ELSE
        trace(  p_msg    => 'END - ' || v_function
              , p_level  => C_LEVEL_PROCEDURE
              , p_module => v_module);
      END IF; -- IF (x_retcode = G_RET_STS_UNEXP_ERROR)
    END IF; -- IF (C_LEVEL_PROCEDURE >= g_log_level)

END create_accounting;


PROCEDURE delete_je(
    p_application_id            IN INTEGER
    , p_event_id                  IN INTEGER) IS
l_log_module                      VARCHAR2(240);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.delete_je';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of procedure DELETE_JE'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

/* no accounting error here
   DELETE FROM xla_accounting_errors
      WHERE event_id IN
               (SELECT event_id FROM xla_events
                 WHERE application_id       = g_application_id
                   AND request_id           = g_report_request_id);
*/


   DELETE FROM xla_distribution_links
      WHERE ae_header_id IN
               (SELECT ae_header_id FROM xla_ae_headers
                 WHERE application_id       = p_application_id
                   AND merge_event_id       = p_event_id);

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'Number of distribution links deleted = '||SQL%ROWCOUNT
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
   END IF;


   DELETE FROM xla_ae_segment_values
      WHERE ae_header_id IN
               (SELECT ae_header_id FROM xla_ae_headers
                 WHERE application_id       = p_application_id
                   AND merge_event_id       = p_event_id);

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'Number of segment values deleted = '||SQL%ROWCOUNT
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
   END IF;


   DELETE FROM xla_ae_line_details
      WHERE ae_header_id IN
               (SELECT ae_header_id FROM xla_ae_headers
                 WHERE application_id       = p_application_id
                   AND merge_event_id       = p_event_id);

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'Number of line details deleted = '||SQL%ROWCOUNT
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
   END IF;

   DELETE FROM xla_ae_header_details
      WHERE ae_header_id IN
               (SELECT ae_header_id FROM xla_ae_headers
                 WHERE application_id       = p_application_id
                   AND merge_event_id       = p_event_id);

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'Number of header details deleted = '||SQL%ROWCOUNT
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
   END IF;

   DELETE FROM xla_ae_lines
      WHERE application_id  = p_application_id
        AND ae_header_id IN
               (SELECT ae_header_id FROM xla_ae_headers
                 WHERE application_id       = p_application_id
                   AND merge_event_id       = p_event_id);

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'Number of ae lines deleted = '||SQL%ROWCOUNT
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
   END IF;

   DELETE FROM xla_ae_headers
      WHERE application_id  = p_application_id
        AND merge_event_id  = p_event_id;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'Number of ae headers deleted = '||SQL%ROWCOUNT
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of procedure DELETE_JE'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_third_party_merge.delete_je');
END delete_je;



--=============================================================================
--          *******************  Initialization  *********************
--=============================================================================
BEGIN
   g_log_level      := fnd_log.G_CURRENT_RUNTIME_LEVEL;
   g_log_enabled    := fnd_log.test(  log_level => g_log_level
                                    , module    => C_DEFAULT_MODULE);

   IF NOT g_log_enabled
   THEN
      g_log_level := C_LEVEL_LOG_DISABLED;
   END IF;

END xla_third_party_merge;

/
