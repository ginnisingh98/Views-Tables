--------------------------------------------------------
--  DDL for Package Body XLA_EVENT_MAPPINGS_F_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_EVENT_MAPPINGS_F_PKG" AS
/* $Header: xlathevm.pkb 120.17.12010000.1 2008/07/29 10:09:39 appldev ship $ */
/*======================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_event_mappings                                                 |
|                                                                       |
| DESCRIPTION                                                           |
|    Forms PL/SQL Wrapper for xla_event_mappings                        |
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
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.xla_event_mappings_f_pkg';

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
      (p_location   => 'xla_event_mappings_f_pkg.trace');
END trace;

/*======================================================================+
|                                                                       |
|  Procedure insert_row                                                 |
|                                                                       |
+======================================================================*/
PROCEDURE insert_row
  (x_rowid                            IN OUT NOCOPY VARCHAR2
  ,x_event_mapping_id                 IN NUMBER
  ,x_application_id                   IN NUMBER
  ,x_entity_code                      IN VARCHAR2
  ,x_event_class_code                 IN VARCHAR2
  ,x_user_sequence                    IN NUMBER
  ,x_column_name                      IN VARCHAR2
  ,x_column_title                     IN VARCHAR2
  ,x_creation_date                    IN DATE
  ,x_created_by                       IN NUMBER
  ,x_last_update_date                 IN DATE
  ,x_last_updated_by                  IN NUMBER
  ,x_last_update_login                IN NUMBER)

IS

CURSOR c IS
SELECT rowid
FROM   xla_event_mappings_b
WHERE  event_mapping_id                 = x_event_mapping_id
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

INSERT INTO xla_event_mappings_b
(creation_date
,created_by
,event_mapping_id
,application_id
,entity_code
,event_class_code
,user_sequence
,column_name
,last_update_date
,last_updated_by
,last_update_login)
VALUES
(x_creation_date
,x_created_by
,x_event_mapping_id
,x_application_id
,x_entity_code
,x_event_class_code
,x_user_sequence
,x_column_name
,x_last_update_date
,x_last_updated_by
,x_last_update_login)
;

INSERT INTO xla_event_mappings_tl
(event_mapping_id
,column_title
,creation_date
,created_by
,last_update_date
,last_updated_by
,last_update_login
,language
,source_lang)
SELECT
       x_event_mapping_id
      ,x_column_title
      ,x_creation_date
      ,x_created_by
      ,x_last_update_date
      ,x_last_updated_by
      ,x_last_update_login
      ,l.language_code
      ,USERENV('LANG')
FROM   fnd_languages l
WHERE  l.installed_flag                 IN ('I', 'B')
  AND  NOT EXISTS
      (SELECT NULL
       FROM   xla_event_mappings_tl              t
       WHERE  t.event_mapping_id                 = x_event_mapping_id
         AND  t.language                         = l.language_code);

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
  (x_event_mapping_id                 IN NUMBER
  ,x_application_id                   IN NUMBER
  ,x_entity_code                      IN VARCHAR2
  ,x_event_class_code                 IN VARCHAR2
  ,x_user_sequence                    IN NUMBER
  ,x_column_name                      IN VARCHAR2
  ,x_column_title                     IN VARCHAR2)

IS

CURSOR c IS
SELECT event_mapping_id
      ,application_id
      ,entity_code
      ,event_class_code
      ,user_sequence
      ,column_name
FROM   xla_event_mappings_b
WHERE  event_mapping_id                 = x_event_mapping_id
FOR UPDATE OF event_mapping_id NOWAIT;

recinfo              c%ROWTYPE;

CURSOR c1 IS
SELECT event_mapping_id
      ,column_title
      ,DECODE(language     , USERENV('LANG'), 'Y', 'N') baselang
FROM   xla_event_mappings_tl
WHERE  event_mapping_id                 = X_event_mapping_id
  AND  USERENV('LANG')                 IN (language     ,source_lang)
FOR UPDATE OF event_mapping_id NOWAIT;

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
 AND (recinfo.user_sequence                    = x_user_sequence)
 AND (recinfo.column_name                      = x_column_name)
                   ) THEN
   NULL;
ELSE
   fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
   app_exception.raise_exception;
END IF;

FOR tlinfo IN c1 LOOP
   IF (tlinfo.baselang = 'Y') THEN
      IF (    (tlinfo.column_title = X_column_title)
      ) THEN
        NULL;
      ELSE
         fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
         app_exception.raise_exception;
      END IF;
   END IF;
END LOOP;

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
 (x_event_mapping_id                 IN NUMBER
 ,x_application_id                   IN NUMBER
 ,x_entity_code                      IN VARCHAR2
 ,x_event_class_code                 IN VARCHAR2
 ,x_user_sequence                    IN NUMBER
 ,x_column_name                      IN VARCHAR2
 ,x_column_title                     IN VARCHAR2
 ,x_last_update_date                  IN DATE
 ,x_last_updated_by                   IN NUMBER
 ,x_last_update_login                 IN NUMBER)

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

UPDATE xla_event_mappings_b
   SET
       last_update_date                 = x_last_update_date
      ,application_id                   = x_application_id
      ,entity_code                      = x_entity_code
      ,event_class_code                 = x_event_class_code
      ,user_sequence                    = x_user_sequence
      ,column_name                      = x_column_name
      ,last_updated_by                  = x_last_updated_by
      ,last_update_login                = x_last_update_login
WHERE  event_mapping_id                 = X_event_mapping_id;

IF (SQL%NOTFOUND) THEN
   RAISE NO_DATA_FOUND;
END IF;

UPDATE xla_event_mappings_tl
SET
       last_update_date                 = x_last_update_date
      ,column_title                     = X_column_title
      ,last_updated_by                  = x_last_updated_by
      ,last_update_login                = x_last_update_login
      ,source_lang                      = USERENV('LANG')
WHERE  event_mapping_id                 = X_event_mapping_id
  AND  USERENV('LANG')                 IN (language, source_lang);

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
  (x_event_mapping_id                 IN NUMBER)

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

DELETE FROM xla_event_mappings_tl
WHERE event_mapping_id                 = x_event_mapping_id;


IF (SQL%NOTFOUND) THEN
   RAISE NO_DATA_FOUND;
END IF;

DELETE FROM xla_event_mappings_b
WHERE event_mapping_id                 = x_event_mapping_id;


IF (SQL%NOTFOUND) THEN
   RAISE NO_DATA_FOUND;
END IF;


  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure delete_row',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

END delete_row;

/*======================================================================+
|                                                                       |
|  Procedure add_language                                               |
|                                                                       |
+======================================================================*/
PROCEDURE add_language

IS

  l_log_module            VARCHAR2(240);
BEGIN

  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.add_language';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure add_language',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

DELETE FROM xla_event_mappings_tl T
WHERE  NOT EXISTS
      (SELECT NULL
       FROM   xla_event_mappings_b               b
       WHERE  b.event_mapping_id                 = t.event_mapping_id);

UPDATE xla_event_mappings_tl   t
SET   (column_title)
   = (SELECT b.column_title
      FROM   xla_event_mappings_tl              b
      WHERE  b.event_mapping_id                 = t.event_mapping_id
        AND  b.language                         = t.source_lang)
WHERE (t.event_mapping_id
      ,t.language)
    IN (SELECT subt.event_mapping_id
              ,subt.language
        FROM   xla_event_mappings_tl                  subb
              ,xla_event_mappings_tl                  subt
        WHERE  subb.event_mapping_id                 = subt.event_mapping_id
         AND  subb.language                         = subt.source_lang
         AND (SUBB.column_title                     <> SUBT.column_title
      ))
;

INSERT INTO xla_event_mappings_tl
(event_mapping_id
,column_title
,creation_date
,created_by
,last_update_date
,last_updated_by
,last_update_login
,language
,source_lang)
SELECT   /*+ ORDERED */
       b.event_mapping_id
      ,b.column_title
      ,b.creation_date
      ,b.created_by
      ,b.last_update_date
      ,b.last_updated_by
      ,b.last_update_login
      ,l.language_code
      ,b.source_lang
FROM   xla_event_mappings_tl            b
      ,fnd_languages                    l
WHERE  l.installed_flag                IN ('I', 'B')
  AND  b.language                       = userenv('LANG')
  AND  NOT EXISTS
      (SELECT NULL
       FROM   xla_event_mappings_tl              t
       WHERE  t.event_mapping_id                 = b.event_mapping_id
         AND  t.language                         = l.language_code);

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure add_language',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

END add_language;

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
,p_user_sequence                      IN VARCHAR2
,p_column_name                        IN VARCHAR2
,p_owner                              IN VARCHAR2
,p_last_update_date                   IN VARCHAR2
,p_column_title                       IN VARCHAR2)
IS
  CURSOR c_app_id IS
  SELECT application_id
  FROM   fnd_application
  WHERE  application_short_name          = p_application_short_name;

  l_application_id        INTEGER;
  l_event_mapping_id      INTEGER;
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

    SELECT event_mapping_id, last_updated_by, last_update_date
      INTO l_event_mapping_id, db_luby, db_ludate
      FROM xla_event_mappings_vl
     WHERE application_id       = l_application_id
       AND entity_code          = p_entity_code
       AND event_class_code     = p_event_class_code
       AND (user_sequence       = p_user_sequence or
            column_name         = p_column_name);

    IF (fnd_load_util.upload_test(f_luby, f_ludate, db_luby, db_ludate, NULL)) THEN
      xla_event_mappings_f_pkg.update_row
          (x_event_mapping_id              => l_event_mapping_id
          ,x_application_id                => l_application_id
          ,x_entity_code                   => p_entity_code
          ,x_event_class_code              => p_event_class_code
          ,x_user_sequence                 => p_user_sequence
          ,x_column_name                   => p_column_name
          ,x_column_title                  => p_column_title
          ,x_last_update_date              => f_ludate
          ,x_last_updated_by               => f_luby
          ,x_last_update_login             => 0);

    END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      SELECT xla_event_mappings_s.nextval
        INTO l_event_mapping_id
        FROM dual;

      xla_event_mappings_f_pkg.insert_row
          (x_rowid                         => l_rowid
          ,x_event_mapping_id              => l_event_mapping_id
          ,x_application_id                => l_application_id
          ,x_entity_code                   => p_entity_code
          ,x_event_class_code              => p_event_class_code
          ,x_column_name                   => p_column_name
          ,x_user_sequence                 => p_user_sequence
          ,x_column_title                  => p_column_title
          ,x_creation_date                 => f_ludate
          ,x_created_by                    => f_luby
          ,x_last_update_date              => f_ludate
          ,x_last_updated_by               => f_luby
          ,x_last_update_login             => 0);

    WHEN TOO_MANY_ROWS THEN
      DELETE FROM xla_event_mappings_tl
       WHERE event_mapping_id IN
             (SELECT event_mapping_id
                FROM xla_event_mappings_b
               WHERE application_id       = l_application_id
                 AND entity_code          = p_entity_code
                 AND event_class_code     = p_event_class_code
                 AND (user_sequence       = p_user_sequence or
                      column_name         = p_column_name));

      DELETE FROM xla_event_mappings_b
            WHERE application_id       = l_application_id
              AND entity_code          = p_entity_code
              AND event_class_code     = p_event_class_code
              AND (user_sequence       = p_user_sequence or
                   column_name         = p_column_name);

      SELECT xla_event_mappings_s.nextval
        INTO l_event_mapping_id
        FROM dual;

      xla_event_mappings_f_pkg.insert_row
          (x_rowid                         => l_rowid
          ,x_event_mapping_id              => l_event_mapping_id
          ,x_application_id                => l_application_id
          ,x_entity_code                   => p_entity_code
          ,x_event_class_code              => p_event_class_code
          ,x_column_name                   => p_column_name
          ,x_user_sequence                 => p_user_sequence
          ,x_column_title                  => p_column_title
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
      (p_location   => 'xla_event_mappings_f_pkg.load_row');

END load_row;

--=============================================================================
--
-- Name: translate_row
-- Description: To be used by FNDLOAD to upload a translated row
--
--=============================================================================
PROCEDURE translate_row
  (p_application_short_name           IN VARCHAR2
  ,p_entity_code                      IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_user_sequence                    IN VARCHAR2
  ,p_column_name                      IN VARCHAR2
  ,p_column_title                     IN VARCHAR2
  ,p_owner                            IN VARCHAR2
  ,p_last_update_date                 IN VARCHAR2
  ,p_custom_mode                      IN VARCHAR2)
IS
  CURSOR c_app_id IS
  SELECT application_id
  FROM   fnd_application
  WHERE  application_short_name          = p_application_short_name;

  l_application_id        INTEGER;
  l_event_mapping_id      INTEGER;
  l_rowid                 ROWID;
  l_exist                 VARCHAR2(1);
  f_luby                  NUMBER;      -- entity owner in file
  f_ludate                DATE;        -- entity update date in file
  db_luby                 NUMBER;      -- entity owner in db
  db_ludate               DATE;        -- entity update date in db
  l_log_module            VARCHAR2(240);
BEGIN

  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.translate_row';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure translate_row',
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

    SELECT event_mapping_id, last_updated_by, last_update_date
      INTO l_event_mapping_id, db_luby, db_ludate
      FROM xla_event_mappings_vl
     WHERE application_id       = l_application_id
       AND entity_code          = p_entity_code
       AND event_class_code     = p_event_class_code
       AND (user_sequence       = p_user_sequence or
            column_name         = p_column_name);

    IF (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                               db_ludate, p_custom_mode)) then
      UPDATE xla_event_mappings_tl
         SET column_title      = p_column_title
            ,last_update_date  = f_ludate
            ,last_updated_by   = f_luby
            ,last_update_login = 0
            ,source_lang       = userenv('LANG')
       WHERE userenv('LANG')   IN (language, source_lang)
         AND event_mapping_id  = l_event_mapping_id;

    END IF;



  END;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure translate_row',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;



END translate_row;

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

end xla_event_mappings_f_PKG;

/
