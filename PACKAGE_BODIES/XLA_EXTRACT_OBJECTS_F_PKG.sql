--------------------------------------------------------
--  DDL for Package Body XLA_EXTRACT_OBJECTS_F_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_EXTRACT_OBJECTS_F_PKG" AS
/* $Header: xlatbexo.pkb 120.7 2005/04/28 18:45:42 masada ship $ */
/*======================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_extract_objects                                                |
|                                                                       |
| DESCRIPTION                                                           |
|    Forms PL/SQL Wrapper for xla_extract_objects                       |
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
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.xla_extract_objects_f_pkg';

g_debug_flag          VARCHAR2(1) :=
NVL(fnd_profile.value('XLA_DEBUG_TRACE'),'N');

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
      (p_location   => 'xla_extract_objects_f_pkg.trace');
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
  ,x_event_class_code                 IN VARCHAR2
  ,x_object_name                      IN VARCHAR2
  ,x_object_type_code                 IN VARCHAR2
  ,x_always_populated_flag             IN VARCHAR2
  ,x_creation_date                    IN DATE
  ,x_created_by                       IN NUMBER
  ,x_last_update_date                 IN DATE
  ,x_last_updated_by                  IN NUMBER
  ,x_last_update_login                IN NUMBER)

IS

CURSOR c IS
SELECT rowid
FROM   xla_extract_objects
WHERE  application_id                 = x_application_id
  AND  entity_code		      = x_entity_code
  AND  event_class_code		      = x_event_class_code
  AND  object_name		      = x_object_name
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

INSERT INTO xla_extract_objects
(creation_date
,created_by
,application_id
,entity_code
,event_class_code
,object_name
,object_type_code
,always_populated_flag
,last_update_date
,last_updated_by
,last_update_login)
VALUES
(x_creation_date
,x_created_by
,x_application_id
,x_entity_code
,x_event_class_code
,x_object_name
,x_object_type_code
,x_always_populated_flag
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
  ,x_event_class_code                 IN VARCHAR2
  ,x_object_name                      IN VARCHAR2
  ,x_object_type_code                 IN VARCHAR2
  ,x_always_populated_flag             IN VARCHAR2)

IS

CURSOR c IS
SELECT application_id
      ,entity_code
      ,event_class_code
      ,object_name
      ,object_type_code
      ,always_populated_flag
FROM   xla_extract_objects
WHERE  application_id                 = x_application_id
  AND  entity_code		      = x_entity_code
  AND  event_class_code		      = x_event_class_code
  AND  object_name		      = x_object_name
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

IF ( (recinfo.application_id                   = x_application_id)
 AND (recinfo.entity_code                      = x_entity_code)
 AND (recinfo.event_class_code                 = x_event_class_code)
 AND (recinfo.object_name                      = x_object_name)
 AND (recinfo.object_type_code                 = x_object_type_code)
 AND (recinfo.always_populated_flag             = x_always_populated_flag)
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

END lock_row;

/*======================================================================+
|                                                                       |
|  Procedure update_row                                                 |
|                                                                       |
+======================================================================*/
PROCEDURE update_row
 (x_application_id                   IN NUMBER
 ,x_entity_code                      IN VARCHAR2
 ,x_event_class_code                 IN VARCHAR2
 ,x_object_name                      IN VARCHAR2
 ,x_object_type_code                 IN VARCHAR2
 ,x_always_populated_flag             IN VARCHAR2
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

UPDATE xla_extract_objects
   SET
       last_update_date                 = x_last_update_date
      ,object_type_code                 = x_object_type_code
      ,always_populated_flag             = x_always_populated_flag
      ,last_updated_by                  = x_last_updated_by
      ,last_update_login                = x_last_update_login
WHERE  application_id                 = x_application_id
  AND  entity_code		      = x_entity_code
  AND  event_class_code		      = x_event_class_code
  AND  object_name		      = x_object_name
;

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
 ,x_entity_code                      IN VARCHAR2
 ,x_event_class_code                 IN VARCHAR2
 ,x_object_name                      IN VARCHAR2)

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

DELETE FROM xla_extract_objects
WHERE  application_id                 = x_application_id
  AND  entity_code		      = x_entity_code
  AND  event_class_code		      = x_event_class_code
  AND  object_name		      = x_object_name
;


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
,p_event_class_code                   IN VARCHAR2
,p_object_name                        IN VARCHAR2
,p_object_type_code                   IN VARCHAR2
,p_always_populated_flag              IN VARCHAR2
,p_owner                              IN VARCHAR2
,p_last_update_date                   IN VARCHAR2)
IS
  CURSOR c_app_id(p_app_short_name VARCHAR2) IS
  SELECT application_id
  FROM   fnd_application
  WHERE  application_short_name          = p_app_short_name;

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

  OPEN c_app_id(p_application_short_name);
  FETCH c_app_id INTO l_application_id;
  CLOSE c_app_id;

  BEGIN

    SELECT last_updated_by, last_update_date
      INTO db_luby, db_ludate
      FROM xla_extract_objects
     WHERE application_id       = l_application_id
       AND entity_code          = p_entity_code
       AND event_class_code     = p_event_class_code
       AND object_name          = p_object_name;

    IF (fnd_load_util.upload_test(f_luby, f_ludate, db_luby, db_ludate, NULL)) THEN
      xla_extract_objects_f_pkg.update_row
          (x_application_id                => l_application_id
          ,x_entity_code                   => p_entity_code
          ,x_event_class_code              => p_event_class_code
          ,x_object_name                   => p_object_name
          ,x_object_type_code              => p_object_type_code
          ,x_always_populated_flag         => p_always_populated_flag
          ,x_last_update_date              => f_ludate
          ,x_last_updated_by               => f_luby
          ,x_last_update_login             => 0);

    END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      xla_extract_objects_f_pkg.insert_row
          (x_rowid                         => l_rowid
          ,x_application_id                => l_application_id
          ,x_entity_code                   => p_entity_code
          ,x_event_class_code              => p_event_class_code
          ,x_object_name                   => p_object_name
          ,x_object_type_code              => p_object_type_code
          ,x_always_populated_flag         => p_always_populated_flag
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
      (p_location   => 'xla_extract_objects_f_pkg.load_row');

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


end xla_extract_objects_f_pkg;

/
