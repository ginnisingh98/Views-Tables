--------------------------------------------------------
--  DDL for Package Body XLA_ENTITY_ID_MAPPINGS_F_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_ENTITY_ID_MAPPINGS_F_PKG" AS
/* $Header: xlatheim.pkb 120.2 2005/04/28 18:45:48 masada ship $ */
/*======================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_entity_id_mappings_f_pkg                                       |
|                                                                       |
| DESCRIPTION                                                           |
|    Forms PL/SQL Wrapper for xla_entity_id_mappings                    |
|                                                                       |
| HISTORY                                                               |
|    Generated from XLAUTB.                                             |
|                                                                       |
+======================================================================*/

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
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.xla_entity_id_mappings_f_pkg';

g_log_level           NUMBER;
g_log_enabled         BOOLEAN;

PROCEDURE trace
  (p_msg                        IN VARCHAR2
  ,p_module                     IN VARCHAR2
  ,p_level                      IN NUMBER) IS
BEGIN
  ----------------------------------------------------------------------------
  -- Following is for FND log.
  ----------------------------------------------------------------------------
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
      (p_location   => 'xla_entity_id_mappings_f_pkg.trace');
END trace;


/*======================================================================+
|                                                                       |
|  Procedure insert_row                                                 |
|                                                                       |
+======================================================================*/
PROCEDURE insert_row
  (x_rowid                            IN OUT NOCOPY VARCHAR2
  ,x_application_id                   IN NUMBER
  ,x_entity_code                      IN VARCHAR2
  ,x_transaction_id_col_name_1        IN VARCHAR2
  ,x_transaction_id_col_name_2        IN VARCHAR2
  ,x_transaction_id_col_name_3        IN VARCHAR2
  ,x_transaction_id_col_name_4        IN VARCHAR2
  ,x_source_id_col_name_1             IN VARCHAR2
  ,x_source_id_col_name_2             IN VARCHAR2
  ,x_source_id_col_name_3             IN VARCHAR2
  ,x_source_id_col_name_4             IN VARCHAR2
  ,x_creation_date                    IN DATE
  ,x_created_by                       IN NUMBER
  ,x_last_update_date                 IN DATE
  ,x_last_updated_by                  IN NUMBER
  ,x_last_update_login                IN NUMBER)

IS

CURSOR c IS
SELECT rowid
FROM   xla_entity_id_mappings
WHERE  application_id                   = x_application_id
  AND  entity_code                      = x_entity_code
;

  l_log_module            VARCHAR2(240);
BEGIN

  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.insert_row';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure insert_row',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;


INSERT INTO xla_entity_id_mappings
(creation_date
,created_by
,application_id
,entity_code
,transaction_id_col_name_1
,transaction_id_col_name_2
,transaction_id_col_name_3
,transaction_id_col_name_4
,source_id_col_name_1
,source_id_col_name_2
,source_id_col_name_3
,source_id_col_name_4
,last_update_date
,last_updated_by
,last_update_login)
VALUES
(x_creation_date
,x_created_by
,x_application_id
,x_entity_code
,x_transaction_id_col_name_1
,x_transaction_id_col_name_2
,x_transaction_id_col_name_3
,x_transaction_id_col_name_4
,x_source_id_col_name_1
,x_source_id_col_name_2
,x_source_id_col_name_3
,x_source_id_col_name_4
,x_last_update_date
,x_last_updated_by
,x_last_update_login)
;

OPEN c;
FETCH c INTO x_rowid;

IF (c%NOTFOUND) THEN
   CLOSE c;
   RAISE NO_DATA_FOUND;
END IF;
CLOSE c;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure insert_row',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

END insert_row;

/*======================================================================+
|                                                                       |
|  Procedure lock_row                                                   |
|                                                                       |
+======================================================================*/
PROCEDURE lock_row
  (x_application_id                   IN NUMBER
  ,x_entity_code                      IN VARCHAR2
  ,x_transaction_id_col_name_1        IN VARCHAR2
  ,x_transaction_id_col_name_2        IN VARCHAR2
  ,x_transaction_id_col_name_3        IN VARCHAR2
  ,x_transaction_id_col_name_4        IN VARCHAR2
  ,x_source_id_col_name_1             IN VARCHAR2
  ,x_source_id_col_name_2             IN VARCHAR2
  ,x_source_id_col_name_3             IN VARCHAR2
  ,x_source_id_col_name_4             IN VARCHAR2)

IS

CURSOR c IS
SELECT application_id
      ,entity_code
      ,transaction_id_col_name_1
      ,transaction_id_col_name_2
      ,transaction_id_col_name_3
      ,transaction_id_col_name_4
      ,source_id_col_name_1
      ,source_id_col_name_2
      ,source_id_col_name_3
      ,source_id_col_name_4
FROM   xla_entity_id_mappings
WHERE  application_id                   = x_application_id
  AND  entity_code                      = x_entity_code
FOR UPDATE OF application_id NOWAIT;

recinfo      c%ROWTYPE;

  l_log_module            VARCHAR2(240);
BEGIN

  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.lock_row';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure lock_row',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

OPEN c;
FETCH c INTO recinfo;

IF (c%NOTFOUND) THEN
   CLOSE c;
   fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
   app_exception.raise_exception;
END IF;
CLOSE c;

IF ( ((recinfo.transaction_id_col_name_1         = x_transaction_id_col_name_1) OR
      (recinfo.transaction_id_col_name_1 IS NULL AND x_transaction_id_col_name_1 IS NULL))
 AND ((recinfo.transaction_id_col_name_2         = x_transaction_id_col_name_2) OR
      (recinfo.transaction_id_col_name_2 IS NULL AND x_transaction_id_col_name_2 IS NULL))
 AND ((recinfo.transaction_id_col_name_3         = x_transaction_id_col_name_3) OR
      (recinfo.transaction_id_col_name_3 IS NULL AND x_transaction_id_col_name_3 IS NULL))
 AND ((recinfo.transaction_id_col_name_4         = x_transaction_id_col_name_4) OR
      (recinfo.transaction_id_col_name_4 IS NULL AND x_transaction_id_col_name_4 IS NULL))
 AND ((recinfo.source_id_col_name_1         = x_source_id_col_name_1) OR
      (recinfo.source_id_col_name_1 IS NULL AND x_source_id_col_name_1 IS NULL))
 AND ((recinfo.source_id_col_name_2         = x_source_id_col_name_2) OR
      (recinfo.source_id_col_name_2 IS NULL AND x_source_id_col_name_2 IS NULL))
 AND ((recinfo.source_id_col_name_3         = x_source_id_col_name_3) OR
      (recinfo.source_id_col_name_3 IS NULL AND x_source_id_col_name_3 IS NULL))
 AND ((recinfo.source_id_col_name_4         = x_source_id_col_name_4) OR
      (recinfo.source_id_col_name_4 IS NULL AND x_source_id_col_name_4 IS NULL))
                   ) THEN
   NULL;
ELSE
   fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
   app_exception.raise_exception;
END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure lock_row',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

RETURN;

END lock_row;

/*======================================================================+
|                                                                       |
|  Procedure update_row                                                 |
|                                                                       |
+======================================================================*/
PROCEDURE update_row
 (x_application_id                   IN NUMBER
 ,x_entity_code                      IN VARCHAR2
 ,x_transaction_id_col_name_1        IN VARCHAR2
 ,x_transaction_id_col_name_2        IN VARCHAR2
 ,x_transaction_id_col_name_3        IN VARCHAR2
 ,x_transaction_id_col_name_4        IN VARCHAR2
 ,x_source_id_col_name_1             IN VARCHAR2
 ,x_source_id_col_name_2             IN VARCHAR2
 ,x_source_id_col_name_3             IN VARCHAR2
 ,x_source_id_col_name_4             IN VARCHAR2
 ,x_last_update_date                 IN DATE
 ,x_last_updated_by                  IN NUMBER
 ,x_last_update_login                IN NUMBER)

IS
  l_log_module            VARCHAR2(240);
BEGIN

  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.update_row';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure update_row',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

UPDATE xla_entity_id_mappings
   SET
       last_update_date                 = x_last_update_date
      ,transaction_id_col_name_1        = x_transaction_id_col_name_1
      ,transaction_id_col_name_2        = x_transaction_id_col_name_2
      ,transaction_id_col_name_3        = x_transaction_id_col_name_3
      ,transaction_id_col_name_4        = x_transaction_id_col_name_4
      ,source_id_col_name_1             = x_source_id_col_name_1
      ,source_id_col_name_2             = x_source_id_col_name_2
      ,source_id_col_name_3             = x_source_id_col_name_3
      ,source_id_col_name_4             = x_source_id_col_name_4
      ,last_updated_by                  = x_last_updated_by
      ,last_update_login                = x_last_update_login
WHERE  application_id                   = X_application_id
  AND  entity_code                      = X_entity_code;

IF (SQL%NOTFOUND) THEN
   RAISE NO_DATA_FOUND;
END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure update_row',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

END update_row;

/*======================================================================+
|                                                                       |
|  Procedure delete_row                                                 |
|                                                                       |
+======================================================================*/
PROCEDURE delete_row
  (x_application_id                   IN NUMBER
  ,x_entity_code                      IN VARCHAR2)
IS
  l_log_module            VARCHAR2(240);
BEGIN

  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.delete_row';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure delete_row',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

DELETE FROM xla_entity_id_mappings
WHERE application_id                   = x_application_id
  AND entity_code                      = x_entity_code;


IF (SQL%NOTFOUND) THEN
   RAISE NO_DATA_FOUND;
END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure delete_row',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

END delete_row;

--=============================================================================
--
-- Name: load_row
-- Description: To be used by FNDLOAD to upload a row to the table
--
--=============================================================================
PROCEDURE load_row
(p_application_short_name             IN VARCHAR2
,p_entity_code                        IN VARCHAR2
,p_transaction_id_col_name_1          IN VARCHAR2
,p_transaction_id_col_name_2          IN VARCHAR2
,p_transaction_id_col_name_3          IN VARCHAR2
,p_transaction_id_col_name_4          IN VARCHAR2
,p_source_id_col_name_1               IN VARCHAR2
,p_source_id_col_name_2               IN VARCHAR2
,p_source_id_col_name_3               IN VARCHAR2
,p_source_id_col_name_4               IN VARCHAR2
,p_owner                              IN VARCHAR2
,p_last_update_date                   IN VARCHAR2)
IS
  CURSOR c_app_id IS
  SELECT application_id
  FROM   fnd_application
  WHERE  application_short_name          = p_application_short_name;

  l_application_id        INTEGER;
  l_rowid                 ROWID;
  l_exist                 VARCHAR2(1);
  f_luby                  NUMBER;      -- entity owner in file
  f_ludate                DATE;        -- entity update date in file
  db_luby                 NUMBER;      -- entity owner in db
  db_ludate               DATE;        -- entity update date in db
  l_log_module            VARCHAR2(240);
BEGIN

  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.load_row';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure load_row',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(p_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(p_last_update_date, 'YYYY/MM/DD'), sysdate);

  OPEN c_app_id;
  FETCH c_app_id INTO l_application_id;
  CLOSE c_app_id;

  BEGIN

    SELECT last_updated_by, last_update_date
      INTO db_luby, db_ludate
      FROM xla_entity_id_mappings
     WHERE application_id       = l_application_id
       AND entity_code          = p_entity_code;

    IF (fnd_load_util.upload_test(f_luby, f_ludate, db_luby, db_ludate, NULL)) THEN
      xla_entity_id_mappings_f_pkg.update_row
          (x_application_id                => l_application_id
          ,x_entity_code                   => p_entity_code
          ,x_transaction_id_col_name_1     => p_transaction_id_col_name_1
          ,x_transaction_id_col_name_2     => p_transaction_id_col_name_2
          ,x_transaction_id_col_name_3     => p_transaction_id_col_name_3
          ,x_transaction_id_col_name_4     => p_transaction_id_col_name_4
          ,x_source_id_col_name_1          => p_source_id_col_name_1
          ,x_source_id_col_name_2          => p_source_id_col_name_2
          ,x_source_id_col_name_3          => p_source_id_col_name_3
          ,x_source_id_col_name_4          => p_source_id_col_name_4
          ,x_last_update_date              => f_ludate
          ,x_last_updated_by               => f_luby
          ,x_last_update_login             => 0);

    END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      xla_entity_id_mappings_f_pkg.insert_row
          (x_rowid                         => l_rowid
          ,x_application_id                => l_application_id
          ,x_entity_code                   => p_entity_code
          ,x_transaction_id_col_name_1     => p_transaction_id_col_name_1
          ,x_transaction_id_col_name_2     => p_transaction_id_col_name_2
          ,x_transaction_id_col_name_3     => p_transaction_id_col_name_3
          ,x_transaction_id_col_name_4     => p_transaction_id_col_name_4
          ,x_source_id_col_name_1          => p_source_id_col_name_1
          ,x_source_id_col_name_2          => p_source_id_col_name_2
          ,x_source_id_col_name_3          => p_source_id_col_name_3
          ,x_source_id_col_name_4          => p_source_id_col_name_4
          ,x_creation_date                 => f_ludate
          ,x_created_by                    => f_luby
          ,x_last_update_date              => f_ludate
          ,x_last_updated_by               => f_luby
          ,x_last_update_login             => 0);

  END;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure load_row',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      null;
   WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location   => 'xla_entity_id_mappings_f_pkg.load_row');

END load_row;


--=============================================================================
--
-- Following code is executed when the package body is referenced for the first
-- time
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


end xla_entity_id_mappings_f_pkg;

/
