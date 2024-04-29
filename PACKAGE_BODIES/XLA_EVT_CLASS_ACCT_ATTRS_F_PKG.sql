--------------------------------------------------------
--  DDL for Package Body XLA_EVT_CLASS_ACCT_ATTRS_F_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_EVT_CLASS_ACCT_ATTRS_F_PKG" AS
/* $Header: xlatbaaa.pkb 120.2.12000000.2 2007/04/27 18:28:25 svellani ship $ */
/*======================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_evt_class_acct_attrs                                           |
|                                                                       |
| DESCRIPTION                                                           |
|    Forms PL/SQL Wrapper for xla_evt_class_acct_attrs                  |
|                                                                       |
| HISTORY                                                               |
|    05/22/01     Dimple Shah    Created                                |
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
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.xla_evt_class_acct_attrs_f_pkg';

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
      (p_location   => 'xla_evt_class_acct_attrs_f_pkg.trace');
END trace;



/*======================================================================+
|                                                                       |
|  Procedure insert_row                                                 |
|                                                                       |
+======================================================================*/
PROCEDURE insert_row
  (x_rowid                            IN OUT NOCOPY VARCHAR2
  ,x_application_id                   IN NUMBER
  ,x_event_class_code                 IN VARCHAR2
  ,x_accounting_attribute_code        IN VARCHAR2
  ,x_source_application_id            IN NUMBER
  ,x_source_type_code                 IN VARCHAR2
  ,x_source_code                      IN VARCHAR2
  ,x_assignment_owner_code            IN VARCHAR2
  ,x_default_flag                     IN VARCHAR2
  ,x_creation_date                    IN DATE
  ,x_created_by                       IN NUMBER
  ,x_last_update_date                 IN DATE
  ,x_last_updated_by                  IN NUMBER
  ,x_last_update_login                IN NUMBER)

IS

CURSOR c IS
SELECT rowid
FROM   xla_evt_class_acct_attrs
WHERE  application_id                   = x_application_id
  AND  event_class_code                 = x_event_class_code
  AND  accounting_attribute_code        = x_accounting_attribute_code
  AND  source_application_id            = x_source_application_id
  AND  source_type_code                 = x_source_type_code
  AND  source_code                      = x_source_code
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

INSERT INTO xla_evt_class_acct_attrs
(creation_date
,created_by
,application_id
,event_class_code
,accounting_attribute_code
,source_application_id
,source_type_code
,source_code
,assignment_owner_code
,default_flag
,last_update_date
,last_updated_by
,last_update_login)
VALUES
(x_creation_date
,x_created_by
,x_application_id
,x_event_class_code
,x_accounting_attribute_code
,x_source_application_id
,x_source_type_code
,x_source_code
,x_assignment_owner_code
,x_default_flag
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
  (x_rowid                            IN OUT NOCOPY VARCHAR2
  ,x_application_id                   IN NUMBER
  ,x_event_class_code                 IN VARCHAR2
  ,x_accounting_attribute_code        IN VARCHAR2
  ,x_source_application_id            IN NUMBER
  ,x_source_type_code                 IN VARCHAR2
  ,x_source_code                      IN VARCHAR2
  ,x_assignment_owner_code            IN VARCHAR2
  ,x_default_flag                     IN VARCHAR2)

IS

CURSOR c IS
SELECT application_id
      ,event_class_code
      ,source_application_id
      ,source_type_code
      ,source_code
      ,assignment_owner_code
      ,default_flag
      ,accounting_attribute_code
FROM   xla_evt_class_acct_attrs
WHERE  application_id                   = x_application_id
  AND  event_class_code                 = x_event_class_code
  AND  accounting_attribute_code        = x_accounting_attribute_code
  AND  source_application_id            = x_source_application_id
  AND  source_type_code                 = x_source_type_code
  AND  source_code                      = x_source_code
FOR UPDATE OF application_id NOWAIT;

recinfo              c%ROWTYPE;

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

IF ( (recinfo.application_id                    = x_application_id)
 AND (recinfo.event_class_code                  = x_event_class_code)
 AND (recinfo.source_application_id             = x_source_application_id)
 AND (recinfo.source_code                       = x_source_code)
 AND (recinfo.source_type_code                  = x_source_type_code)
 AND (recinfo.assignment_owner_code             = x_assignment_owner_code)
 AND (recinfo.default_flag                      = x_default_flag)
 AND (recinfo.accounting_attribute_code         = x_accounting_attribute_code)
                   ) THEN
   null;
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
  (x_rowid                            IN OUT NOCOPY VARCHAR2
  ,x_application_id                   IN NUMBER
  ,x_event_class_code                 IN VARCHAR2
  ,x_accounting_attribute_code        IN VARCHAR2
  ,x_source_application_id            IN NUMBER
  ,x_source_type_code                 IN VARCHAR2
  ,x_source_code                      IN VARCHAR2
  ,x_assignment_owner_code            IN VARCHAR2
  ,x_default_flag                     IN VARCHAR2
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

UPDATE xla_evt_class_acct_attrs
   SET
       last_update_date                 = x_last_update_date
      ,default_flag                     = x_default_flag
      ,last_updated_by                  = x_last_updated_by
      ,last_update_login                = x_last_update_login
WHERE  application_id                   = X_application_id
  AND  event_class_code                 = x_event_class_code
  AND  accounting_attribute_code        = x_accounting_attribute_code
  AND  source_application_id            = x_source_application_id
  AND  source_type_code                 = X_source_type_code
  AND  source_code                      = X_source_code;

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
  ,x_event_class_code                 IN VARCHAR2
  ,x_accounting_attribute_code        IN VARCHAR2
  ,x_source_application_id            IN NUMBER
  ,x_source_type_code                 IN VARCHAR2
  ,x_source_code                      IN VARCHAR2)

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

DELETE FROM xla_evt_class_acct_attrs
WHERE application_id                   = x_application_id
  AND event_class_code                 = x_event_class_code
  AND accounting_attribute_code        = x_accounting_attribute_code
  AND source_application_id            = x_source_application_id
  AND source_type_code                 = x_source_type_code
  AND source_code                      = x_source_code;


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
(p_application_short_name           IN VARCHAR2
,p_event_class_code                 IN VARCHAR2
,p_accounting_attribute_code        IN VARCHAR2
,p_source_app_short_name            IN VARCHAR2
,p_source_type_code                 IN VARCHAR2
,p_source_code                      IN VARCHAR2
,p_assignment_owner_code            IN VARCHAR2
,p_default_flag                     IN VARCHAR2
,p_owner                            IN VARCHAR2
,p_last_update_date                 IN VARCHAR2)
IS
  CURSOR c_app_id (l_app_id VARCHAR2) IS
  SELECT application_id
  FROM   fnd_application
  WHERE  application_short_name          = l_app_id;

  l_application_id        INTEGER;
  l_source_app_id         INTEGER;
  l_rowid                 ROWID;
  l_exist                 VARCHAR2(1);
  f_luby                  NUMBER;      -- entity owner in file
  f_ludate                DATE;        -- entity update date in file
  db_luby                 NUMBER;      -- entity owner in db
  db_ludate               DATE;        -- entity update date in db
  l_log_module            VARCHAR2(240);
  l_assign_level_code     xla_acct_attributes_b.accounting_attribute_code%TYPE;
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

  OPEN c_app_id(p_source_app_short_name);
  FETCH c_app_id INTO l_source_app_id;
  CLOSE c_app_id;
/* Bug 5954674*/
  BEGIN
        BEGIN
            SELECT assignment_level_code
              INTO l_assign_level_code
              FROM xla_acct_attributes_b
             WHERE accounting_attribute_code = p_accounting_attribute_code;

            IF l_assign_level_code = 'EVT_CLASS_ONLY' THEN
                 DELETE FROM xla_evt_class_acct_attrs
                 WHERE  application_id                   =  l_application_id
                   AND  event_class_code                 =  p_event_class_code
                   AND  accounting_attribute_code        =  p_accounting_attribute_code
                   AND  source_application_id            =  l_source_app_id
                   AND  source_type_code                 =  p_source_type_code
                   AND  source_code                      <> p_source_code;
            END IF;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
                 null;
         END;


    SELECT last_updated_by, last_update_date
      INTO db_luby, db_ludate
      FROM xla_evt_class_acct_attrs
     WHERE application_id            = l_application_id
       AND event_class_code          = p_event_class_code
       AND accounting_attribute_code = p_accounting_attribute_code
       AND source_application_id     = l_source_app_id
       AND source_type_code          = p_source_type_code
       AND source_code               = p_source_code;

    IF (fnd_load_util.upload_test(f_luby, f_ludate, db_luby, db_ludate, NULL)) THEN
      xla_evt_class_acct_attrs_f_pkg.update_row
          (x_rowid                         => l_rowid
          ,x_application_id                => l_application_id
          ,x_event_class_code              => p_event_class_code
          ,x_accounting_attribute_code     => p_accounting_attribute_code
          ,x_source_application_id         => l_source_app_id
          ,x_source_type_code              => p_source_type_code
          ,x_source_code                   => p_source_code
          ,x_assignment_owner_code         => p_assignment_owner_code
          ,x_default_flag                  => p_default_flag
          ,x_last_update_date              => f_ludate
          ,x_last_updated_by               => f_luby
          ,x_last_update_login             => 0);

    END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      xla_evt_class_acct_attrs_f_pkg.insert_row
          (x_rowid                         => l_rowid
          ,x_application_id                => l_application_id
          ,x_event_class_code              => p_event_class_code
          ,x_accounting_attribute_code     => p_accounting_attribute_code
          ,x_source_application_id         => l_source_app_id
          ,x_source_type_code              => p_source_type_code
          ,x_source_code                   => p_source_code
          ,x_assignment_owner_code         => p_assignment_owner_code
          ,x_default_flag                  => p_default_flag
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
      (p_location   => 'xla_evt_class_acct_attrs_f_pkg.load_row');

END load_row;


end xla_evt_class_acct_attrs_f_PKG;

/
