--------------------------------------------------------
--  DDL for Package Body XLA_SOURCE_PARAMS_F_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_SOURCE_PARAMS_F_PKG" AS
/* $Header: xlathspm.pkb 120.1 2005/04/28 18:45:55 masada ship $ */

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
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.xla_source_params_f_pkg';

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
      (p_location   => 'xla_source_params_f_pkg.trace');
END trace;


/*======================================================================+
|                                                                       |
|  Procedure insert_row                                                 |
|                                                                       |
+======================================================================*/
PROCEDURE insert_row
  (x_rowid                            IN OUT NOCOPY VARCHAR2
  ,x_source_param_id                  IN NUMBER
  ,x_application_id                   IN NUMBER
  ,x_source_type_code                 IN VARCHAR2
  ,x_source_code                      IN VARCHAR2
  ,x_user_sequence                    IN NUMBER
  ,x_parameter_type_code              IN VARCHAR2
  ,x_constant_value                   IN VARCHAR2
  ,x_ref_source_application_id        IN NUMBER
  ,x_ref_source_type_code             IN VARCHAR2
  ,x_ref_source_code                  IN VARCHAR2
  ,x_creation_date                    IN DATE
  ,x_created_by                       IN NUMBER
  ,x_last_update_date                 IN DATE
  ,x_last_updated_by                  IN NUMBER
  ,x_last_update_login                IN NUMBER)

IS

CURSOR c IS
SELECT rowid
FROM   xla_source_params
WHERE  source_param_id       = x_source_param_id
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


INSERT INTO xla_source_params
(creation_date
,created_by
,source_param_id
,application_id
,source_type_code
,source_code
,user_sequence
,parameter_type_code
,constant_value
,ref_source_application_id
,ref_source_type_code
,ref_source_code
,last_update_date
,last_updated_by
,last_update_login)
VALUES
(x_creation_date
,x_created_by
,x_source_param_id
,x_application_id
,x_source_type_code
,x_source_code
,x_user_sequence
,x_parameter_type_code
,x_constant_value
,x_ref_source_application_id
,x_ref_source_type_code
,x_ref_source_code
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
 (x_source_param_id                  IN NUMBER
 ,x_application_id                   IN NUMBER
 ,x_source_type_code                 IN VARCHAR2
 ,x_source_code                      IN VARCHAR2
 ,x_user_sequence                    IN NUMBER
 ,x_parameter_type_code              IN VARCHAR2
 ,x_constant_value                   IN VARCHAR2
 ,x_ref_source_application_id        IN NUMBER
 ,x_ref_source_type_code             IN VARCHAR2
 ,x_ref_source_code                  IN VARCHAR2
)
IS

CURSOR c IS
SELECT application_id
      ,source_type_code
      ,source_code
      ,user_sequence
      ,parameter_type_code
      ,constant_value
      ,ref_source_application_id
      ,ref_source_type_code
      ,ref_source_code
FROM   xla_source_params
WHERE  source_param_id                = x_source_param_id
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

IF ( (recinfo.application_id                     = x_application_id)
 AND (recinfo.source_type_code                   = x_source_type_code)
 AND (recinfo.source_code                        = x_source_code)
 AND (recinfo.user_sequence                      = x_user_sequence)
 AND (recinfo.parameter_type_code                = x_parameter_type_code)
 AND ((recinfo.constant_value                    = x_constant_value) OR
      (recinfo.constant_value IS NULL            AND x_constant_value IS NULL))
 AND ((recinfo.ref_source_application_id         = x_ref_source_application_id) OR
      (recinfo.ref_source_application_id IS NULL AND x_ref_source_application_id IS NULL))
 AND ((recinfo.ref_source_type_code              = x_ref_source_type_code) OR
      (recinfo.ref_source_type_code IS NULL      AND x_ref_source_type_code IS NULL))
 AND ((recinfo.ref_source_code                   = x_ref_source_code) OR
      (recinfo.ref_source_code IS NULL           AND x_ref_source_code IS NULL))
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
 (x_source_param_id                  IN NUMBER
 ,x_application_id                   IN NUMBER
 ,x_source_type_code                 IN VARCHAR2
 ,x_source_code                      IN VARCHAR2
 ,x_user_sequence                    IN NUMBER
 ,x_parameter_type_code              IN VARCHAR2
 ,x_constant_value                   IN VARCHAR2
 ,x_ref_source_application_id        IN NUMBER
 ,x_ref_source_type_code             IN VARCHAR2
 ,x_ref_source_code                  IN VARCHAR2
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

UPDATE xla_source_params
   SET
       last_update_date             = x_last_update_date
      ,application_id               = x_application_id
      ,source_type_code             = x_source_type_code
      ,source_code                  = x_source_code
      ,user_sequence                = x_user_sequence
      ,parameter_type_code          = x_parameter_type_code
      ,constant_value               = x_constant_value
      ,ref_source_application_id    = x_ref_source_application_id
      ,ref_source_type_code         = x_ref_source_type_code
      ,ref_source_code              = x_ref_source_code
      ,last_updated_by              = x_last_updated_by
      ,last_update_login            = x_last_update_login
WHERE  source_param_id              = x_source_param_id;

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
  (x_source_param_id                   IN NUMBER)
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

DELETE FROM xla_source_params
WHERE source_param_id             = x_source_param_id;

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
,p_source_type_code                   IN VARCHAR2
,p_source_code                        IN VARCHAR2
,p_user_sequence                      IN VARCHAR2
,p_parameter_type_code                IN VARCHAR2
,p_constant_value                     IN VARCHAR2
,p_ref_source_app_short_name          IN VARCHAR2
,p_ref_source_type_code               IN VARCHAR2
,p_ref_source_code                    IN VARCHAR2
,p_owner                              IN VARCHAR2
,p_last_update_date                   IN VARCHAR2)
IS
  CURSOR c_app_id(l_app_id VARCHAR2) IS
  SELECT application_id
  FROM   fnd_application
  WHERE  application_short_name          = l_app_id;

  l_application_id        INTEGER;
  l_ref_source_app_id     INTEGER;
  l_source_param_id       INTEGER;
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

  OPEN c_app_id(p_application_short_name);
  FETCH c_app_id INTO l_application_id;
  CLOSE c_app_id;

  OPEN c_app_id(p_ref_source_app_short_name);
  FETCH c_app_id INTO l_ref_source_app_id;
  CLOSE c_app_id;

  BEGIN

    SELECT source_param_id, last_updated_by, last_update_date
      INTO l_source_param_id, db_luby, db_ludate
      FROM xla_source_params
     WHERE application_id       = l_application_id
       AND source_type_code     = p_source_type_code
       AND source_code          = p_source_code
       AND user_sequence        = p_user_sequence;

    IF (fnd_load_util.upload_test(f_luby, f_ludate, db_luby, db_ludate, NULL)) THEN
      xla_source_params_f_pkg.update_row
          (x_source_param_id               => l_source_param_id
          ,x_application_id                => l_application_id
          ,x_source_type_code              => p_source_type_code
          ,x_source_code                   => p_source_code
          ,x_user_sequence                 => p_user_sequence
          ,x_parameter_type_code           => p_parameter_type_code
          ,x_constant_value                => p_constant_value
          ,x_ref_source_application_id     => l_ref_source_app_id
          ,x_ref_source_type_code          => p_ref_source_type_code
          ,x_ref_source_code               => p_ref_source_code
          ,x_last_update_date              => f_ludate
          ,x_last_updated_by               => f_luby
          ,x_last_update_login             => 0);

    END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      SELECT xla_source_params_s.nextval INTO l_source_param_id
        FROM dual;

      xla_source_params_f_pkg.insert_row
          (x_rowid                         => l_rowid
          ,x_source_param_id               => l_source_param_id
          ,x_application_id                => l_application_id
          ,x_source_type_code              => p_source_type_code
          ,x_source_code                   => p_source_code
          ,x_user_sequence                 => p_user_sequence
          ,x_parameter_type_code           => p_parameter_type_code
          ,x_constant_value                => p_constant_value
          ,x_ref_source_application_id     => l_ref_source_app_id
          ,x_ref_source_type_code          => p_ref_source_type_code
          ,x_ref_source_code               => p_ref_source_code
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
      (p_location   => 'xla_source_params_f_pkg.load_row');

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


end xla_source_params_f_pkg;

/
