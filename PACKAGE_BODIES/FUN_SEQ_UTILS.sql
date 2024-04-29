--------------------------------------------------------
--  DDL for Package Body FUN_SEQ_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FUN_SEQ_UTILS" AS
/* $Header: funsqrlb.pls 120.17 2004/11/04 01:16:12 masada noship $ */

--
-- Global Variable
--
g_module      CONSTANT VARCHAR2(30) DEFAULT 'fun.plsql.fun_seq_utils';
g_table_names Table_Name_Tab;
g_cache_size  BINARY_INTEGER DEFAULT 0;

--
-- Constant
--
g_last_update_login CONSTANT NUMBER := 0;

--
-- Exceptions
--
invalid_table             EXCEPTION;
PRAGMA EXCEPTION_INIT(invalid_table, 100);

no_seq_entity_found       EXCEPTION;
PRAGMA EXCEPTION_INIT(no_seq_entity_found, 100);

invalid_context_type      EXCEPTION;
invalid_event_code        EXCEPTION;
invalid_date_type         EXCEPTION;

--
-- Subtypes
--
SUBTYPE Debug_Loc IS VARCHAR2(1000);
--
-- PROCEDURE NAME:
--   show_exception
--
PROCEDURE show_exception (
            p_routine IN VARCHAR2) IS
BEGIN
  fnd_message.set_name('FND','SQL_PLSQL_ERROR');
  fnd_message.set_token('ROUTINE', p_routine);
  fnd_message.set_token('ERRNO', TO_CHAR(sqlcode));
  fnd_message.set_token('REASON',sqlerrm);
  app_exception.raise_exception;
END show_exception;

--
-- Standard Logging Procedures
--
-- P_module:
-- fun.
-- Usage:
PROCEDURE Log(
            p_level        IN  NUMBER,
            p_module       IN  VARCHAR2,
            p_message_text IN  VARCHAR2) IS
BEGIN
  IF (p_level >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(log_level => p_level,
                   module    => p_module,
                   message   => p_message_text);
  END IF;
END Log;

--
-- Log messages at Statement level
-- Severity:
--   1
-- Usage:
--   Low level detailed messages
-- Example:
--   Copying buffer x to y
--
PROCEDURE Log_Statement(
            p_module       IN  VARCHAR2,
            p_message_text IN  VARCHAR2) IS
BEGIN
  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
    log(p_level        => fnd_log.level_statement,
        p_module       => p_module,
        p_message_text => p_message_text);
  END IF;
END Log_Statement;
--
-- Log messages at Procedure level
-- Severity:
--   2
-- Usage:
--   API level flow of Applicatoin and
--   important events
-- Example:
--   Calling an API, Returning from an API, and so on.
--
PROCEDURE Log_Procedure(
            p_module       IN  VARCHAR2,
            p_message_text IN  VARCHAR2) IS
BEGIN
  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
    log(p_level        => fnd_log.level_procedure,
        p_module       => p_module,
        p_message_text => p_message_text);
  END IF;
END Log_Procedure;
--
-- Log messages at Event level
-- Severity:
--   3
-- Usage:
--   A significant milestone in the normal execution path
--   of an application
-- Example:
--   User Authenticated, Starting Business Transaction, and so on.
--
PROCEDURE Log_Event(
            p_module       IN  VARCHAR2,
            p_message_text IN  VARCHAR2) IS
BEGIN
  IF (fnd_log.level_event >= fnd_log.g_current_runtime_level) THEN
    log(p_level        => fnd_log.level_event,
        p_module       => p_module,
        p_message_text => p_message_text);
  END IF;
END Log_Event;
--
-- Log messages at Exception level
-- Severity:
--   4
-- Usage:
--   Internal Software failure condition
-- Example:
--   Detailed Exception Stack Trace, Nullpointer, Rntime Exception,
--   and so on.
--
PROCEDURE Log_Exception(
            p_module       IN  VARCHAR2,
            p_message_text IN  VARCHAR2) IS
BEGIN
  IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level) THEN
    log(p_level        => fnd_log.level_exception,
        p_module       => p_module,
        p_message_text => p_message_text);
  END IF;
END Log_Exception;
--
-- Log messages at Error level
-- Severity:
--   5
-- Usage:
--   External Condition that causes a business rule/component failure.
-- Example:
--   Authentication failure, Invalid input value, and so on.
--
PROCEDURE Log_Error(
            p_module       IN  VARCHAR2,
            p_message_text IN  VARCHAR2) IS
BEGIN
  IF (fnd_log.level_error >= fnd_log.g_current_runtime_level) THEN
    log(p_level        => fnd_log.level_error,
        p_module       => p_module,
        p_message_text => p_message_text);
  END IF;
END Log_Error;
--
-- Log messages at Error level
-- Severity:
--   6
-- Usage:
--   Error that prevents complete system execute, System Alerts
-- Example:
--   Required file not found, Database failure in placing an order,
--   and so on.
--
PROCEDURE Log_Unexpected(
            p_module       IN  VARCHAR2,
            p_message_text IN  VARCHAR2) IS
BEGIN
  IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) THEN
    log(p_level        => fnd_log.level_unexpected,
        p_module       => p_module,
        p_message_text => p_message_text);
  END IF;
END Log_Unexpected;

--
-- PROCEDURE NAME:
--   create_entity
-- DESCRIPTION:
--   Register Sequence Entity
--   INPUT:
--    - p_application_id
--    - p_table_name
--    - p_entity_name
--    - p_mode
--      Valid values are SEED or CUSTOM.
--      If the value is SEED, user id becomes 1.
--
PROCEDURE create_entity (
            p_application_id    IN  NUMBER,
            p_table_name        IN  VARCHAR2,
            p_entity_name       IN  VARCHAR2) IS

  l_user_id       NUMBER DEFAULT 1;
  l_debug_loc     Debug_Loc;

BEGIN
  --
  --  Initialize
  --
  l_debug_loc := 'create_entity';

  --
  -- Check if the combination of application id and table name is valid
  -- If invalid, exception is raised within is_table_name_valid.
  --
  IF NOT is_table_name_valid (
       p_application_id => p_application_id,
       p_table_name     => p_table_name)
  THEN
    l_debug_loc := l_debug_loc || ' -> '||'is_table_name_valid';
    RAISE invalid_table;
  END IF;
  --
  -- Insert Sequence Entity Information into fun_seq_entities
  --
  l_debug_loc := l_debug_loc || '->' || 'insert into fun_seq_entities';
  --
  INSERT INTO fun_seq_entities (
    application_id,
    table_name,
    entity_name,
    created_by,
    creation_date,
    last_updated_by,
    last_update_date,
    last_update_login)
  VALUES (
    p_application_id,
    p_table_name,
    p_entity_name,
    l_user_id,
    sysdate,
    l_user_id,
    sysdate,
    g_last_update_login);

EXCEPTION
WHEN OTHERS THEN
  show_exception (
    p_routine => l_debug_loc);
END create_entity;

PROCEDURE create_sequencing_rule (
            p_application_id    IN  NUMBER,
            p_table_name        IN  VARCHAR2,
            p_context_type      IN  VARCHAR2,
            p_event_code        IN  VARCHAR2,
            p_date_type         IN  VARCHAR2,
            p_flex_context_code IN  VARCHAR2) IS
  l_user_id             NUMBER DEFAULT 1;
  l_debug_loc           Debug_Loc;
BEGIN
  --
  --  Initialize
  --
  l_debug_loc := 'create_sequencing_rule';

  --
  -- 1. Check if Sequence Entity Does exist for given application id
  -- and table name combination.
  --
  IF NOT is_seq_entity_registered (
           p_application_id => p_application_id,
           p_table_name     => p_table_name)
  THEN
    l_debug_loc := l_debug_loc || ' -> '|| 'is_seq_entity_registered';
    RAISE no_seq_entity_found;
  END IF;
  --
  -- 2. Check if context type is valid
  --
  IF NOT is_context_type_valid (
           p_context_type => p_context_type)
  THEN
    l_debug_loc := l_debug_loc || ' -> '|| 'is_context_type_valid';
    RAISE invalid_context_type;
  END IF;
  --
  -- 3. Check if sequence event is valid
  --
  IF NOT is_event_valid (
           p_event => p_event_code)
  THEN
    l_debug_loc := l_debug_loc || ' -> '|| 'is_event_valid';
    RAISE invalid_event_code;
  END IF;
  --
  -- 4. Check if sequence event is valid
  --
  IF NOT is_date_type_valid (
           p_date_type => p_date_type)
  THEN
    l_debug_loc := l_debug_loc || ' -> '|| 'is_date_type_valid';
    RAISE invalid_date_type;
  END IF;
  --
  -- Insert records into fun_seq_rules
  --
  l_debug_loc := l_debug_loc || '->' || 'insert into fun_seq_rules';
  --
  INSERT INTO fun_seq_rules (
    application_id,
    table_name,
    context_type,
    event_code,
    date_type,
    flex_context_code,
    created_by,
    creation_date,
    last_updated_by,
    last_update_date,
    last_update_login)
  VALUES (
    p_application_id,
    p_table_name,
    p_context_type,
    p_event_code,
    p_date_type,
    p_flex_context_code,
    l_user_id,
    sysdate,
    l_user_id,
    sysdate,
    g_last_update_login);

EXCEPTION
WHEN OTHERS THEN
  show_exception (
    p_routine => l_debug_loc);
END create_sequencing_rule;

PROCEDURE delete_entity (
            p_application_id  IN  NUMBER,
            p_table_name      IN  VARCHAR2) IS
  l_debug_loc           Debug_Loc;
BEGIN
  --
  --  Initialize
  --
  l_debug_loc := 'delete_entity';

  --
  -- 1. Check if Sequence Entity Does exist for given application id
  -- and table name combination.
  --
  IF NOT is_seq_entity_registered (
           p_application_id => p_application_id,
           p_table_name     => p_table_name)
  THEN
    l_debug_loc := l_debug_loc || ' -> '|| 'is_seq_entity_registered';
    RAISE no_seq_entity_found;
  END IF;
  --
  -- Delete Sequence Rules
  --
  DELETE
    FROM fun_seq_rules	sr
   WHERE sr.application_id = p_application_id
     AND sr.table_name = p_table_name;

  --
  -- Delete Sequence Entity
  --
  DELETE
    FROM fun_seq_entities	se
   WHERE se.application_id = p_application_id
     AND se.table_name = p_table_name;

EXCEPTION
WHEN OTHERS THEN
  show_exception (
    p_routine => l_debug_loc);
END;

PROCEDURE delete_sequencing_rule (
            p_application_id  	  IN  NUMBER,
            p_table_name	  IN  VARCHAR2,
            p_context_type        IN  VARCHAR2,
            p_event_code 	  IN  VARCHAR2,
            p_date_type           IN  VARCHAR2) IS

  l_debug_loc     Debug_Loc;
BEGIN
  --
  --  Initialize
  --
  l_debug_loc := 'delete_sequencing_rule';
  --
  -- Check if Sequence Entity Does exist for given application id
  -- and table name combination.
  --
  IF NOT is_seq_entity_registered (
           p_application_id => p_application_id,
           p_table_name     => p_table_name)
  THEN
    l_debug_loc := l_debug_loc || ' -> '|| 'is_seq_entity_registered';
    RAISE no_seq_entity_found;
  END IF;

  --
  -- 2. Check if context type is valid
  --
  IF NOT is_context_type_valid (
           p_context_type => p_context_type)
  THEN
    l_debug_loc := l_debug_loc || ' -> '|| 'is_context_type_valid';
    RAISE invalid_context_type;
  END IF;
  --
  -- 3. Check if sequence event is valid
  --
  IF NOT is_event_valid (
           p_event => p_event_code)
  THEN
    l_debug_loc := l_debug_loc || ' -> '|| 'is_event_valid';
    RAISE invalid_event_code;
  END IF;
  --
  -- 4. Check if sequence control date type is valid
  --
  IF NOT is_date_type_valid (
           p_date_type => p_date_type)
  THEN
    l_debug_loc := l_debug_loc || ' -> '|| 'is_date_type_valid';
    RAISE invalid_date_type;
  END IF;

  DELETE
    FROM fun_seq_rules sr
   WHERE sr.application_id = p_application_id
     AND sr.table_name = p_table_name
     AND sr.context_type = p_context_type
     AND sr.event_code = p_event_code
     AND sr.date_type = p_date_type;
EXCEPTION
WHEN OTHERS THEN
  show_exception (
    p_routine => l_debug_loc);
END delete_sequencing_rule;

PROCEDURE update_entity (
            p_application_id  	  IN  NUMBER,
            p_table_name	  IN  VARCHAR2,
            p_entity_name	  IN  VARCHAR2) IS

  l_user_id       NUMBER  DEFAULT 1;
  no_seq_entity_found   EXCEPTION;
  l_debug_loc     Debug_Loc;

BEGIN
  --
  --  Initialize
  --
  l_debug_loc := 'update_entity';
  --
  -- Check if Sequence Entity Does exist for given application id
  -- and table name combination.
  --
  IF NOT is_seq_entity_registered (
           p_application_id => p_application_id,
           p_table_name     => p_table_name)
  THEN
    l_debug_loc := l_debug_loc || ' -> '|| 'is_seq_entity_registered';
    RAISE no_seq_entity_found;
  END IF;

  UPDATE fun_seq_entities se
     SET se.entity_name = p_entity_name,
         se.last_updated_by = l_user_id,
         se.last_update_date = sysdate,
         se.last_update_login = l_user_id
   WHERE se.application_id = p_application_id
     AND se.table_name = p_table_name;

EXCEPTION
WHEN OTHERS THEN
  show_exception (
    p_routine => l_debug_loc);
END update_entity;

--
-- Supportive Procedures / Functions
--
FUNCTION is_context_type_valid (
           p_context_type  IN VARCHAR2) RETURN BOOLEAN IS
BEGIN
  IF is_lookup_valid (
       p_lookup_type => 'FUN_SEQ_CONTEXT_TYPE',
       p_lookup_code => p_context_type)
  THEN
    RETURN (TRUE);
  ELSE
    RETURN (FALSE);
  END IF;
END is_context_type_valid;

FUNCTION is_event_valid (
           p_event IN VARCHAR2) RETURN BOOLEAN IS
BEGIN
  IF is_lookup_valid (
       p_lookup_type => 'FUN_SEQ_EVENT',
       p_lookup_code => p_event)
  THEN
    RETURN (TRUE);
  ELSE
    RETURN (FALSE);
  END IF;
END is_event_valid;

FUNCTION is_date_type_valid (
           p_date_type IN VARCHAR2) RETURN BOOLEAN IS
BEGIN
  IF is_lookup_valid (
       p_lookup_type => 'FUN_SEQ_DATE_TYPE',
       p_lookup_code => p_date_type)
  THEN
    RETURN (TRUE);
  ELSE
    RETURN (FALSE);
  END IF;
END;

FUNCTION is_lookup_valid (
           p_lookup_type IN VARCHAR2,
           p_lookup_code IN VARCHAR2) RETURN BOOLEAN IS

  l_dummy  VARCHAR2(1);
BEGIN
  SELECT 'x'
    INTO l_dummy
    FROM fnd_lookups fl
   WHERE fl.lookup_type = p_lookup_type
     AND fl.lookup_code = p_lookup_code;
  RETURN (TRUE);
EXCEPTION
WHEN NO_DATA_FOUND THEN
  RETURN (FALSE);
END;
--
-- FUNCTION NAME:
--   is_table_name_valid
-- DESCRIPTION:
--   Check if table name is valid.
--
FUNCTION is_table_name_valid(
           p_application_id  IN  NUMBER,
           p_table_name      IN  VARCHAR2) RETURN BOOLEAN IS

  l_tb_rec         Table_Name_Rec;
  l_cache_index    BINARY_INTEGER;
  l_defined        BOOLEAN;

BEGIN
  l_tb_rec.application_id := p_application_id;
  l_tb_rec.table_name     := p_table_name;

  l_cache_index := find_table_name_in_cache(l_tb_rec);

  --
  -- Return True if a matching record is found in the cache
  --
  IF l_cache_index < g_cache_size THEN
    RETURN (TRUE);
  --
  -- If a matching record is not found, retrieve it from
  -- the database table
  --
  ELSE
    l_defined := find_table_name_in_db(l_tb_rec);
    IF (l_defined) THEN
      g_table_names(g_cache_size).application_id := l_tb_rec.application_id;
      g_table_names(g_cache_size).table_name     := l_tb_rec.table_name;
      g_cache_size := g_cache_size + 1;
      RETURN (TRUE);
    ELSE
      RETURN (FALSE);
    END IF;
  END IF;
  RETURN (TRUE);
END is_table_name_valid;


--
-- FUNCTION NAME: find_table_name_in_cache
-- DESCRIPTION:
--   Called from is_table_name_valid
--  - If there is no record in the cache, return 0.
--  - If there is a record in the cache but no matching record is found,
--    return the cache size (
--  - If there is a record in the cache and a matching record is found,
--    return the index
--
FUNCTION find_table_name_in_cache (
           p_table_name_rec IN Table_Name_Rec) RETURN BINARY_INTEGER IS

  l_tb_rec      Table_Name_Rec;
  l_cache_index BINARY_INTEGER;
  l_found       BOOLEAN;

BEGIN
    l_tb_rec      := p_table_name_rec;
    l_cache_index := 0;
    l_found       := FALSE;

    WHILE (l_cache_index < g_cache_size) AND (NOT l_found) LOOP
      IF  g_table_names(l_cache_index).application_id = l_tb_rec.application_id
      AND g_table_names(l_cache_index).table_name = l_tb_rec.table_name THEN
        l_found := TRUE;
      ELSE
        l_cache_index := l_cache_index + 1;
      END IF;
    END LOOP;

    RETURN l_cache_index;
END find_table_name_in_cache;

--
-- FUNCTION NAME: find_table_name_in_db
--
--
FUNCTION find_table_name_in_db (
           p_table_name_rec IN Table_Name_Rec) RETURN BOOLEAN IS

  l_dummy   VARCHAR2(1);

  CURSOR c_table IS
  SELECT
         'x'
    FROM
         fnd_tables ft
   WHERE
         ft.application_id = p_table_name_rec.application_id
     AND ft.table_name = p_table_name_rec.table_name;

BEGIN
  OPEN c_table;
    FETCH c_table INTO l_dummy;
    IF (c_table%NOTFOUND) THEN
      RETURN  FALSE;
    ELSE
      RETURN  TRUE;
    END IF;

  CLOSE c_table;
END find_table_name_in_db;

FUNCTION is_seq_entity_registered (
           p_application_id IN  NUMBER,
           p_table_name     IN  VARCHAR2) RETURN BOOLEAN IS

  l_dummy VARCHAR2(1);
BEGIN
  SELECT 'x'
    INTO l_dummy
    FROM fun_seq_entities se
   WHERE se.application_id = p_application_id
     AND se.table_name     = p_table_name;
  RETURN (TRUE);
EXCEPTION
WHEN NO_DATA_FOUND THEN
  RETURN (FALSE);
END is_seq_entity_registered;


--
-- Create Sequencing Setup Data
--
PROCEDURE create_setup_data (
            p_sequence_rec     IN sequence_rec_type,
            p_version_rec      IN version_rec_type,
            p_context_rec      IN context_rec_type,
            p_assignment_rec   IN assignment_rec_type,
            p_owner            IN VARCHAR2,
            p_last_update_date IN VARCHAR2,
            p_custom_mode      IN VARCHAR2) IS

  l_seq_header_id  fun_seq_headers.seq_header_id%TYPE;
  l_seq_context_id fun_seq_contexts.seq_context_id%TYPE;
BEGIN
  --
  -- Delete Existing Records if their status is New
  --
  -- delete_sequence(p_header_name  => p_sequence_rec.header_name);
  -- delete_context (p_context_name => p_context_rec.name);

  --
  -- Create Sequence Header
  --
  create_sequence (
     p_sequence_rec     => p_sequence_rec,
     p_owner            => p_owner,
     p_last_update_date => p_last_update_date,
     p_custom_mode      => p_custom_mode,
     x_seq_header_id    => l_seq_header_id);

  --
  -- Create Version
  --
  create_version (
    p_seq_header_id    => l_seq_header_id,
    p_header_name      => p_sequence_rec.header_name,
    p_version_rec      => p_version_rec,
    p_owner            => p_owner,
    p_last_update_date => p_last_update_date,
    p_custom_mode      => p_custom_mode);
  --
  -- Create Sequencing Context
  --
  create_context (
    p_context_rec      => p_context_rec,
    p_owner            => p_owner,
    p_last_update_date => p_last_update_date,
    p_custom_mode      => p_custom_mode,
    x_seq_context_id   => l_seq_context_id);

  --
  -- Create Assignment
  --
  create_assignment (
    p_seq_context_id   => l_seq_context_id,
    p_seq_header_id    => l_seq_header_id,
    p_assignment_rec   => p_assignment_rec,
    p_owner            => p_owner,
    p_last_update_date => p_last_update_date,
    p_custom_mode      => p_custom_mode);
END create_setup_data;

PROCEDURE create_sequence (
            p_sequence_rec     IN  sequence_rec_type,
            p_owner            IN  VARCHAR2,
            p_last_update_date IN  VARCHAR2,
            p_custom_mode      IN  VARCHAR2,
            x_seq_header_id    OUT NOCOPY NUMBER) IS

  l_seq_header_id  NUMBER;
  f_luby           NUMBER;  -- entity owner in file
  f_ludate         DATE;    -- entity update date in file
  db_luby          NUMBER;  -- entity owner in db
  db_ludate        DATE;    -- entity update date in db
BEGIN
  f_luby   := fnd_load_util.owner_id(p_owner);
  f_ludate := NVL(to_date(p_last_update_date, 'YYYY/MM/DD'),
                        sysdate);
  BEGIN
    --
    -- Retrieve WHO columns from existing Sequence.
    --
    SELECT seq_header_id,
           last_updated_by,
           last_update_date
      INTO x_seq_header_id,
           db_luby,
           db_ludate
      FROM fun_seq_headers
     WHERE header_name = p_sequence_rec.header_name;

    --
    -- Update Description if allowed
    --
    IF (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                        db_ludate, p_custom_mode)) THEN
      UPDATE fun_seq_headers
         SET description = p_sequence_rec.description,
             last_updated_by   = f_luby,
             last_update_date  = f_ludate,
             last_update_login = 0
       WHERE seq_header_id = x_seq_header_id;

    END IF;

  --
  -- Insert a record
  --
  EXCEPTION
  WHEN no_data_found THEN
    INSERT
      INTO fun_seq_headers (
             seq_header_id,
             header_name,
             gapless_flag,
             description,
             obsolete_flag,
             object_version_number,
             last_update_date,
             last_updated_by,
             creation_date,
             created_by,
             last_update_login)
    VALUES (
            fun_seq_headers_s.NEXTVAL,   -- Sequence Header Id
            p_sequence_rec.header_name,  -- Name
            p_sequence_rec.gapless,      -- Type (Gapless)
            p_sequence_rec.description,  -- Description
            'N',                         -- Obsolete Flag
            1,                           -- Object Version Number
            f_ludate,                    -- Last Update Date
            f_luby,                      -- Last Updated By
            f_ludate,                    -- Creation Date
            f_luby,                      -- Created By
            0)                           -- Last Update Login
    RETURNING seq_header_id INTO x_seq_header_id;
  END;
END create_sequence;

PROCEDURE create_version (
            p_seq_header_id    IN NUMBER,
            p_header_name      IN VARCHAR2,
            p_version_rec      IN version_rec_type,
            p_owner            IN VARCHAR2,
            p_last_update_date IN VARCHAR2,
            p_custom_mode      IN VARCHAR2) IS

  l_seq_version_id fun_seq_versions.seq_version_id%TYPE;

  l_module  CONSTANT VARCHAR2(100) DEFAULT g_module || '.' || 'create_version';
  f_luby    NUMBER;  -- entity owner in file
  f_ludate  DATE;    -- entity update date in file
  db_luby   NUMBER;  -- entity owner in db
  db_ludate DATE;    -- entity update date in db

BEGIN
  f_luby   := fnd_load_util.owner_id(p_owner);
  f_ludate := NVL(to_date(p_last_update_date, 'YYYY/MM/DD'),
                        sysdate);
  BEGIN
    --
    -- Retrieve WHO columns from existing Sequence Version.
    --
    SELECT last_updated_by,
           last_update_date
      INTO db_luby,
           db_ludate
      FROM fun_seq_versions
     WHERE seq_header_id = p_seq_header_id
       AND version_name  = p_version_rec.version_name;
    --
    -- Update Version Name
    --
    -- IF (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
    --                                    db_ludate, p_custom_mode)) THEN
    --  NULL;
    -- END IF;

  EXCEPTION
  WHEN no_data_found THEN
    INSERT
      INTO fun_seq_versions (
             seq_version_id,
             seq_header_id,
             version_name,
             header_name,
             initial_value,
             start_date,
             end_date,
             current_value,
             use_status_code,
             object_version_number,
             last_update_date,
             last_updated_by,
             creation_date,
             created_by,
             last_update_login)
    VALUES(
           fun_seq_versions_s.NEXTVAL, -- Sequence Version Id
           p_seq_header_id,
           p_version_rec.version_name,
           p_header_name,
           p_version_rec.initial_value,
           TRUNC(p_version_rec.start_date),
           p_version_rec.end_date,
           p_version_rec.current_value,
           'NEW',
           1,                           -- Object Version Number
           f_ludate,                    -- Last Update Date
           f_luby,                      -- Last Updated By
           f_ludate,                    -- Creation Date
           f_luby,                      -- Created By
           0)
    RETURNING seq_version_id INTO l_seq_version_id;

    --
    -- Create Database Sequence
    --
    create_db_sequence (
      p_seq_version_id => l_seq_version_id,
      p_initial_value  => p_version_rec.initial_value);
  END;

EXCEPTION
WHEN OTHERS THEN
  --
  -- Logging
  --
  IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(
      log_level => fnd_log.level_exception,
      module    => l_module,
      message   =>
        'p_seq_header_id: '            || p_seq_header_id || ', ' ||
        'p_header_name: '              || p_header_name   || ', ' ||
        'p_version_rec.version_name: ' || p_version_rec.version_name  || ', ' ||
        'p_version_rec.initial_value: '|| p_version_rec.initial_value || ', ' ||
        'p_version_rec.current_value: '|| p_version_rec.current_value || ', ' ||
        'p_version_rec.start_date: '   || p_version_rec.start_date    || ', ' ||
        'p_version_rec.end_date: '     || p_version_rec.end_date      || ', ' ||
        'SQLERRM: '                    || SQLERRM);
  END IF;
  --
  -- Raise Exception
  --
  show_exception('fun_seq_utils.create_version');
END create_version;

PROCEDURE recreate_version IS
  l_header_name         fun_seq_versions.header_name%TYPE;
  l_seq_header_id       fun_seq_versions.seq_header_id%TYPE;
  l_seq_version_id      fun_seq_versions.seq_version_id%TYPE;
  l_obs_version_rec     version_rec_type;
  l_new_version_rec     version_rec_type;
  l_max_number          fun_seq_versions.initial_value%TYPE;

  l_module  CONSTANT VARCHAR2(100) DEFAULT
                       g_module || '.' || 'recreate_version';
BEGIN
  l_header_name := '$SEQUENCE$.INTERCOMPANY';
  l_max_number  := get_max_number;
  --
  -- Recreate Versions when there exists one or more
  -- numeric trx numbers stored in FUN_TRX_BATCHES.
  --
  IF l_max_number IS NOT NULL THEN
    --
    -- Lock the transaction table to prevent the creation of new records
    -- during the recreation process.
    --
    LOCK TABLE fun_trx_batches IN EXCLUSIVE MODE NOWAIT;
    --
    -- Retrieve an active Version information
    --
    get_active_version (
      p_header_name    => l_header_name,
      x_seq_header_id  => l_seq_header_id,
      x_seq_version_id => l_seq_version_id,
      x_version_rec    => l_obs_version_rec);
    --
    -- Obsolete the active Version
    --
    obsolete_version (p_seq_version_id => l_seq_version_id);
    --
    -- Build New Version Information
    --
    l_new_version_rec.version_name  := 'V' ||
      (TO_NUMBER(LTRIM(l_obs_version_rec.version_name,'V')) + 1);
    l_new_version_rec.initial_value := l_max_number + 1;
    l_new_version_rec.current_value := null;
    l_new_version_rec.start_date    := sysdate;
    l_new_version_rec.end_date      := null;
    --
    -- Create a new Version
    -- Note: DDL (Create Sequence) is issued within this procedure.
    -- i.e. implicit commit is issued and lock is released automatically.
    --
    create_version (
      p_seq_header_id    => l_seq_header_id,
      p_header_name      => l_header_name,
      p_version_rec      => l_new_version_rec,
      p_owner            => 'USER',
      p_last_update_date => fnd_date.date_to_canonical(SYSDATE),
      p_custom_mode      => 'FORCE');

  END IF;
EXCEPTION
WHEN OTHERS THEN
  --
  -- If the system cannot lock the table, display the message to the user.
  --
  IF SQLCODE = -54 THEN
   IF fnd_log.level_error>= fnd_log.g_current_runtime_level THEN

    fnd_message.set_name('FUN','FUN_SEQ_IC_TRX_LOCKED');
    fnd_log.message(
      log_level   => fnd_log.level_error,
      module      => l_module,
      pop_message => FALSE); -- Displayed to the user layer
    fnd_message.raise_error;
   END IF;
  --
  -- Logging
  --
  ELSE
    IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(
        log_level => fnd_log.level_exception,
        module    => l_module,
        message   => 'SQLERRM: ' || SQLERRM);
    END IF;
  END IF;
  --
  -- Raise Exception
  --
  app_exception.raise_exception;
END recreate_version;

PROCEDURE create_db_sequence (
           p_seq_version_id  IN NUMBER,
           p_initial_value   IN NUMBER) IS

  l_fnd_user         fnd_oracle_userid.oracle_username%TYPE;
  l_db_sequence_name VARCHAR2(30);
  l_sql_stmt         VARCHAR2(2000);

  l_module  CONSTANT VARCHAR2(100) DEFAULT
              g_module || '.' || 'create_db_sequence';
BEGIN
  --
  -- Get AOL User Name
  --
  SELECT MIN(ou.oracle_username) -- In case for multiple installation
    INTO l_fnd_user
    FROM fnd_product_installations pi,
         fnd_oracle_userid ou
   WHERE ou.oracle_id = pi.oracle_id
     AND application_id = 0;

  --
  -- Construct SQL statement
  --
  l_db_sequence_name := 'FUN_SEQ_S' || p_seq_version_id;
  l_sql_stmt := 'CREATE SEQUENCE '  ||l_db_sequence_name||
                ' MINVALUE 1 '      ||
                ' START WITH '      || p_initial_value ||
                ' NOCACHE';
  --
  -- Register the Sequence to dictionary
  --
  ad_ddl.do_ddl(l_fnd_user, 'FUN', ad_ddl.create_sequence, l_sql_stmt, l_db_sequence_name);

  --
  -- Update Database Sequence column of fun_seq_versions
  --
  UPDATE fun_seq_versions
     SET db_sequence_name = l_db_sequence_name
   WHERE seq_version_id = p_seq_version_id;
EXCEPTION
WHEN OTHERS THEN
  --
  -- Logging
  --
  IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(
      log_level => fnd_log.level_exception,
      module    => l_module,
      message   => 'p_seq_version_id: ' || p_seq_version_id || ', ' ||
                   'p_initial_value: '  || p_initial_value  || ', ' ||
                   'SQLERRM: '          || SQLERRM);
  END IF;
  --
  -- Raise Exception
  --
  app_exception.raise_exception;
END create_db_sequence;

PROCEDURE create_context (
            p_context_rec      IN  context_rec_type,
            p_owner            IN  VARCHAR2,
            p_last_update_date IN  VARCHAR2,
            p_custom_mode      IN  VARCHAR2,
            x_seq_context_id   OUT NOCOPY NUMBER) IS

  l_seq_context_id   fun_seq_contexts.seq_context_id%TYPE;
  f_luby             NUMBER;  -- entity owner in file
  f_ludate           DATE;    -- entity update date in file
  db_luby            NUMBER;  -- entity owner in db
  db_ludate          DATE;    -- entity update date in db
BEGIN
  f_luby   := fnd_load_util.owner_id(p_owner);
  f_ludate := NVL(to_date(p_last_update_date, 'YYYY/MM/DD'),
                        sysdate);
  BEGIN
    --
    -- Retrieve WHO columns from existing Sequence Version.
    --
    SELECT seq_context_id,
           last_updated_by,
           last_update_date
      INTO
           x_seq_context_id,
           db_luby,
           db_ludate
      FROM fun_seq_contexts
     WHERE application_id = p_context_rec.application_id
       AND table_name     = p_context_rec.table_name
       AND context_type   = p_context_rec.context_type
       AND context_value  = p_context_rec.context_value
       AND event_code     = p_context_rec.event_code
       AND inactive_date IS NULL;
    --
    -- Update Sequencing Context Name
    --
    IF (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                        db_ludate, p_custom_mode)) THEN
      UPDATE fun_seq_contexts
         SET name = p_context_rec.NAME
       WHERE seq_context_id = x_seq_context_id
         AND inactive_date IS NULL;
    END IF;

  EXCEPTION
  WHEN no_data_found THEN
  INSERT
    INTO fun_seq_contexts (
           seq_context_id,
           application_id,
           table_name,
           context_type,
           context_value,
           event_code,
           date_type,
           NAME,
           require_assign_flag,
           obsolete_flag,
           inactive_date,
           object_version_number,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by,
           last_update_login)
  VALUES (
           fun_seq_contexts_s.NEXTVAL,
           p_context_rec.application_id,
           p_context_rec.table_name,
           p_context_rec.context_type,
           p_context_rec.context_value,
           p_context_rec.event_code,
           p_context_rec.date_type,
           p_context_rec.name,
           p_context_rec.require_assign_flag,
           'N',  -- Obsolete Flag
           NULL, -- Inactive Date
           1,
           f_ludate,                    -- Last Update Date
           f_luby,                      -- Last Updated By
           f_ludate,                    -- Creation Date
           f_luby,                      -- Created By
           0)
   RETURNING seq_context_id INTO x_seq_context_id;
  END;
END create_context;

--
-- Do not use for GL or XLA
--
PROCEDURE create_assignment (
            p_seq_context_id   IN NUMBER,
            p_seq_header_id    IN NUMBER,
            p_assignment_rec   IN assignment_rec_type,
            p_owner            IN VARCHAR2,
            p_last_update_date IN VARCHAR2,
            p_custom_mode      IN VARCHAR2) IS

  l_assignment_id fun_seq_assignments.assignment_id%TYPE;
  f_luby          NUMBER;  -- entity owner in file
  f_ludate        DATE;    -- entity update date in file
  db_luby         NUMBER;  -- entity owner in db
  db_ludate       DATE;    -- entity update date in db
BEGIN
  f_luby   := fnd_load_util.owner_id(p_owner);
  f_ludate := NVL(to_date(p_last_update_date, 'YYYY/MM/DD'),
                        sysdate);
  BEGIN
    --
    -- Retrieve WHO columns from existing Sequence Version.
    --
    SELECT assignment_id,
           last_updated_by,
           last_update_date
      INTO
           l_assignment_id,
           db_luby,
           db_ludate
      FROM fun_seq_assignments
     WHERE seq_context_id = p_seq_context_id
       AND use_status_code <> 'OBSOLETE';
  --
  -- Create a record
  --
  EXCEPTION
  WHEN no_data_found THEN
    INSERT
      INTO fun_seq_assignments (
             assignment_id,
             seq_context_id,
             seq_header_id,
             link_to_assignment_id,
             priority,
             control_attribute_structure,
             balance_type,
             journal_source,
             journal_category,
             accounting_event_type,
             accounting_entry_type,
             document_category,
             start_date,
             end_date,
             use_status_code,
             object_version_number,
             last_update_date,
             last_updated_by,
             creation_date,
             created_by,
             last_update_login)
    VALUES (
             fun_seq_assignments_s.NEXTVAL,
             p_seq_context_id,
             p_seq_header_id,
             NULL,  -- Link to Assignment Id,
             NULL,  -- Priority
             p_assignment_rec.control_attribute_structure,
             NULL,  -- Balance Type
             NULL,  -- Jounral Source
             NULL,  -- Journal Category
             NULL,  -- Accounting Event Type
             NULL,  -- Accounting Entry Type
             NULL,  -- Document Category
             TRUNC(p_assignment_rec.start_date),
             p_assignment_rec.end_date,
             'NEW',
             1,
             f_ludate,                    -- Last Update Date
             f_luby,                      -- Last Updated By
             f_ludate,                    -- Creation Date
             f_luby,                      -- Created By
             0);
  END;
END create_assignment;

--
-- Delete Sequence and its Versions
-- if they are new.
--
PROCEDURE delete_sequence (
            p_header_name   IN VARCHAR2) IS

  TYPE seq_version_id_tbl_type IS TABLE OF
    fun_seq_versions.seq_version_id%TYPE INDEX BY BINARY_INTEGER;

  l_seq_ver_id_tbl  seq_version_id_tbl_type;
  l_seq_header_id   fun_seq_headers.seq_header_id%TYPE;
BEGIN
  --
  -- Lock Sequence Versions
  --
  SELECT sv.seq_version_id
    BULK COLLECT
    INTO l_seq_ver_id_tbl
    FROM fun_seq_versions sv
   WHERE sv.header_name = p_header_name
     AND sv.use_status_code = 'NEW'
     FOR UPDATE NOWAIT;
  --
  -- Delete Versions
  --
  FORALL i IN l_seq_ver_id_tbl.FIRST..l_seq_ver_id_tbl.LAST
    DELETE
      FROM fun_seq_versions sv
     WHERE sv.seq_version_id = l_seq_ver_id_tbl(i);
  --
  -- Lock Sequence Header
  --
  SELECT sh.seq_header_id
    INTO l_seq_header_id
    FROM fun_seq_headers sh
   WHERE sh.header_name = p_header_name
     AND NOT EXISTS (SELECT 1
                       FROM fun_seq_versions sv
                      WHERE sv.seq_header_id = sh.seq_header_id
                        AND sv.use_status_code <> 'NEW')
     FOR UPDATE NOWAIT;
  --
  -- Delelete Sequence Header
  --
  DELETE
    FROM fun_seq_headers sh
   WHERE sh.seq_header_id = l_seq_header_id;
EXCEPTION
WHEN OTHERS THEN
  ROLLBACK;
END delete_sequence;

--
-- Delete Sequence Context and its Assignments
-- if any of them is not used.
--
PROCEDURE delete_context (
            p_context_name  IN VARCHAR2) IS

  TYPE assign_id_tbl_type IS TABLE OF
    fun_seq_assignments.assignment_id%TYPE INDEX BY BINARY_INTEGER;

  l_assign_id_tbl  assign_id_tbl_type;
  l_seq_context_id fun_seq_contexts.seq_context_id%TYPE;
BEGIN
  --
  -- Lock Assignments
  --
  SELECT sa.assignment_id
    BULK COLLECT
    INTO l_assign_id_tbl
    FROM fun_seq_assignments sa,
         fun_seq_contexts    sc
   WHERE sc.seq_context_id = sa.seq_context_id
     AND sc.name = p_context_name
     AND sa.use_status_code = 'NEW'
     FOR UPDATE NOWAIT;
  --
  -- Delete Versions
  --
  FORALL i IN l_assign_id_tbl.FIRST..l_assign_id_tbl.LAST
    DELETE
      FROM fun_seq_assignments sa
     WHERE sa.assignment_id = l_assign_id_tbl(i);
  --
  -- Lock Sequence Header
  --
  SELECT sc.seq_context_id
    INTO l_seq_context_id
    FROM fun_seq_contexts    sc
   WHERE sc.name = p_context_name
     AND NOT EXISTS (SELECT 1
                       FROM fun_seq_assignments sa
                      WHERE sa.seq_context_id = sc.seq_context_id
                        AND sa.use_status_code <> 'NEW')
     FOR UPDATE NOWAIT;
  --
  -- Delelete Sequence Header
  --
  DELETE
    FROM fun_seq_contexts sc
   WHERE sc.seq_context_id = l_seq_context_id;

EXCEPTION
WHEN OTHERS THEN
  ROLLBACK;
END delete_context;

PROCEDURE obsolete_version (
            p_seq_version_id IN NUMBER) IS

  l_seq_version_id fun_seq_versions.seq_version_id%TYPE;
  l_module  CONSTANT VARCHAR2(100) DEFAULT
                       g_module || '.' || 'obsolete_version';
BEGIN

  SELECT sv.seq_version_id
    INTO l_seq_version_id
    FROM fun_seq_versions sv
   WHERE sv.seq_version_id = p_seq_version_id
     FOR UPDATE NOWAIT;

  UPDATE fun_seq_versions sv
     SET use_status_code = 'OBSOLETE'
   WHERE sv.seq_version_id = l_seq_version_id;

EXCEPTION
WHEN OTHERS THEN
  --
  -- Logging
  --
  IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(
      log_level => fnd_log.level_exception,
      module    => l_module,
      message   => 'p_seq_version_id: ' || p_seq_version_id || ', ' ||
                   'SQLERRM: '          || SQLERRM);
  END IF;
  --
  -- Raise Exception
  --
  app_exception.raise_exception;
END obsolete_version;

PROCEDURE get_active_version (
            p_header_name     IN  VARCHAR2,
            x_seq_header_id   OUT NOCOPY NUMBER,
            x_seq_version_id  OUT NOCOPY NUMBER,
            x_version_rec     OUT NOCOPY version_rec_type) IS

  l_module  CONSTANT VARCHAR2(100) DEFAULT
                       g_module || '.' || 'get_active_version';
BEGIN
  --
  -- Raise exceptions when,
  --   - multiple records are returned.
  -- Return null when,
  --   - no record is returned.
  --
  -- Need to obsolete 'New' Versions in case
  -- manual numeric numbers are recorded on
  -- transactions.
  --
  SELECT sv.seq_header_id,
         sv.seq_version_id,
         sv.version_name,
         sv.initial_value,
         sv.current_value,
         sv.start_date,
         sv.end_date
    INTO x_seq_header_id,
         x_seq_version_id,
         x_version_rec.version_name,
         x_version_rec.initial_value,
         x_version_rec.current_value,
         x_version_rec.start_date,
         x_version_rec.end_date
    FROM fun_seq_versions sv
   WHERE sv.header_name = p_header_name
     AND sv.use_status_code IN ('USED','NEW');
EXCEPTION
WHEN NO_DATA_FOUND THEN
  x_seq_version_id := NULL;
WHEN OTHERS THEN
  --
  -- Logging
  --
  IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(
      log_level => fnd_log.level_exception,
      module    => l_module,
      message   => 'p_header_name: ' || p_header_name || ', ' ||
                   'SQLERRM: '       || SQLERRM);
  END IF;
  --
  -- Raise Exception
  --
  app_exception.raise_exception;
END get_active_version;

FUNCTION get_max_number RETURN NUMBER IS
  l_max_number  fun_seq_versions.initial_value%TYPE;
BEGIN
  SELECT max(TO_NUMBER(tb.batch_number))
    INTO l_max_number
    FROM fun_trx_batches tb
   WHERE TRANSLATE(tb.batch_number,'0123456789','0000000000')
       = RPAD('0',LENGTH(tb.batch_number),'0');

  RETURN l_max_number;
EXCEPTION
WHEN NO_DATA_FOUND THEN
  RETURN NULL;
END get_max_number;

END fun_seq_utils;

/
