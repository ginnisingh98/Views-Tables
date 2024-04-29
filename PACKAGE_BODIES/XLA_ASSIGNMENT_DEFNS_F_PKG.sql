--------------------------------------------------------
--  DDL for Package Body XLA_ASSIGNMENT_DEFNS_F_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_ASSIGNMENT_DEFNS_F_PKG" AS
/* $Header: xlathasd.pkb 120.2.12010000.1 2008/07/29 10:09:13 appldev ship $ */
/*======================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_assignment_defns                                               |
|                                                                       |
| DESCRIPTION                                                           |
|    Forms PL/SQL Wrapper for xla_assignment_defns                      |
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
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.xla_assignment_defns_f_pkg';

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
      (p_location   => 'xla_assignment_defns_f_pkg.trace');
END trace;

/*======================================================================+
|                                                                       |
|  Procedure insert_row                                                 |
|                                                                       |
+======================================================================*/
PROCEDURE insert_row
  (x_rowid                            IN OUT NOCOPY VARCHAR2
  ,x_program_code                     IN VARCHAR2
  ,x_program_owner_code               IN VARCHAR2
  ,x_assignment_code                  IN VARCHAR2
  ,x_assignment_owner_code            IN VARCHAR2
  ,x_ledger_id                        IN NUMBER
  ,x_enabled_flag                     IN VARCHAR2
  ,x_name                             IN VARCHAR2
  ,x_creation_date                    IN DATE
  ,x_created_by                       IN NUMBER
  ,x_last_update_date                 IN DATE
  ,x_last_updated_by                  IN NUMBER
  ,x_last_update_login                IN NUMBER)

IS

CURSOR c IS
SELECT rowid
FROM   xla_assignment_defns_b
WHERE  program_code                      = x_program_code
  AND  program_owner_code                = x_program_owner_code
  AND  assignment_code                   = x_assignment_code
  AND  assignment_owner_code             = x_assignment_owner_code
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


INSERT INTO xla_assignment_defns_b
(creation_date
,created_by
,program_code
,program_owner_code
,assignment_code
,assignment_owner_code
,ledger_id
,enabled_flag
,last_update_date
,last_updated_by
,last_update_login)
VALUES
(x_creation_date
,x_created_by
,x_program_code
,x_program_owner_code
,x_assignment_code
,x_assignment_owner_code
,x_ledger_id
,x_enabled_flag
,x_last_update_date
,x_last_updated_by
,x_last_update_login)
;

INSERT INTO xla_assignment_defns_tl
(creation_date
,program_code
,program_owner_code
,assignment_code
,assignment_owner_code
,name
,last_update_date
,last_updated_by
,last_update_login
,created_by
,language
,source_lang)
SELECT
       x_creation_date
      ,x_program_code
      ,x_program_owner_code
      ,x_assignment_code
      ,x_assignment_owner_code
      ,x_name
      ,x_last_update_date
      ,x_last_updated_by
      ,x_last_update_login
      ,x_created_by
      ,l.language_code
      ,USERENV('LANG')
FROM   fnd_languages l
WHERE  l.installed_flag                 IN ('I', 'B')
  AND  NOT EXISTS
      (SELECT NULL
       FROM   xla_assignment_defns_tl               t
       WHERE  t.program_code                      = x_program_code
         AND  t.program_owner_code                = x_program_owner_code
         AND  t.assignment_code                   = x_assignment_code
         AND  t.assignment_owner_code             = x_assignment_owner_code
         AND  t.language                          = l.language_code);

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
  (x_program_code                     IN VARCHAR2
  ,x_program_owner_code               IN VARCHAR2
  ,x_assignment_code                  IN VARCHAR2
  ,x_assignment_owner_code            IN VARCHAR2
  ,x_ledger_id                        IN NUMBER
  ,x_enabled_flag                     IN VARCHAR2
  ,x_name                             IN VARCHAR2)

IS

CURSOR c IS
SELECT enabled_flag, ledger_id
FROM   xla_assignment_defns_b
WHERE  program_code                      = x_program_code
  AND  program_owner_code                = x_program_owner_code
  AND  assignment_code                   = x_assignment_code
  AND  assignment_owner_code             = x_assignment_owner_code
FOR UPDATE OF program_code NOWAIT;

recinfo              c%ROWTYPE;

CURSOR c1 IS
SELECT source_lang
      ,name
      ,DECODE(language     , USERENV('LANG'), 'Y', 'N') baselang
FROM   xla_assignment_defns_tl
WHERE  program_code                      = X_program_code
  AND  program_owner_code                = X_program_owner_code
  AND  assignment_code                   = x_assignment_code
  AND  assignment_owner_code             = x_assignment_owner_code
  AND  USERENV('LANG')                 IN (language     ,source_lang)
FOR UPDATE OF program_code NOWAIT;

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

IF ( (recinfo.enabled_flag                     = x_enabled_flag)
   AND ((recinfo.ledger_id                     = x_ledger_id)
    OR ((recinfo.ledger_id                      is null)
        AND (X_ledger_id                      is null)))
                   ) THEN
   NULL;
ELSE
   fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
   app_exception.raise_exception;
END IF;

FOR tlinfo IN c1 LOOP
   IF (tlinfo.baselang = 'Y') THEN
      IF (    (tlinfo.name = X_name)
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
 (x_program_code                     IN VARCHAR2
  ,x_program_owner_code               IN VARCHAR2
  ,x_assignment_code                  IN VARCHAR2
  ,x_assignment_owner_code            IN VARCHAR2
  ,x_ledger_id                        IN NUMBER
  ,x_enabled_flag                     IN VARCHAR2
  ,x_name                             IN VARCHAR2
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

UPDATE xla_assignment_defns_b
   SET
       last_update_date                 = x_last_update_date
      ,ledger_id                        = x_ledger_id
      ,enabled_flag                     = x_enabled_flag
      ,last_updated_by                  = x_last_updated_by
      ,last_update_login                = x_last_update_login
WHERE  program_code                      = X_program_code
  AND  program_owner_code                = X_program_owner_code
  AND  assignment_code                   = x_assignment_code
  AND  assignment_owner_code             = x_assignment_owner_code;

IF (SQL%NOTFOUND) THEN
   RAISE NO_DATA_FOUND;
END IF;

UPDATE xla_assignment_defns_tl
SET
       last_update_date                 = x_last_update_date
      ,name                             = X_name
      ,last_updated_by                  = x_last_updated_by
      ,last_update_login                = x_last_update_login
      ,source_lang                      = USERENV('LANG')
WHERE  program_code                      = X_program_code
  AND  program_owner_code                 = X_program_owner_code
  AND  assignment_code                   = x_assignment_code
  AND  assignment_owner_code             = x_assignment_owner_code
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
  (x_program_code                     IN VARCHAR2
  ,x_program_owner_code               IN VARCHAR2
  ,x_assignment_code                  IN VARCHAR2
  ,x_assignment_owner_code            IN VARCHAR2)

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

DELETE FROM xla_assignment_defns_tl
WHERE program_code                      = x_program_code
  AND program_owner_code                 = x_program_owner_code
  AND  assignment_code                   = x_assignment_code
  AND  assignment_owner_code             = x_assignment_owner_code;


IF (SQL%NOTFOUND) THEN
   RAISE NO_DATA_FOUND;
END IF;

DELETE FROM xla_assignment_defns_b
WHERE program_code                      = x_program_code
  AND program_owner_code                 = x_program_owner_code
  AND  assignment_code                   = x_assignment_code
  AND  assignment_owner_code             = x_assignment_owner_code;


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

DELETE FROM xla_assignment_defns_tl T
WHERE  NOT EXISTS
      (SELECT NULL
       FROM   xla_assignment_defns_b                b
       WHERE  b.program_code                      = t.program_code
         AND  b.program_owner_code                 = t.program_owner_code
         AND  b.assignment_code                   = t.assignment_code
         AND  b.assignment_owner_code             = t.assignment_owner_code);

UPDATE xla_assignment_defns_tl   t
SET   (name)
   = (SELECT b.name
      FROM   xla_assignment_defns_tl               b
      WHERE  b.program_code                      = t.program_code
        AND  b.program_owner_code                 = t.program_owner_code
         AND  b.assignment_code                   = t.assignment_code
         AND  b.assignment_owner_code             = t.assignment_owner_code
        AND  b.language                         = t.source_lang)
WHERE (t.program_code
      ,t.program_owner_code
      ,t.assignment_code
      ,t.assignment_owner_code
      ,t.language)
    IN (SELECT subt.program_code
              ,subt.program_owner_code
              ,subt.assignment_code
              ,subt.assignment_owner_code
              ,subt.language
        FROM   xla_assignment_defns_tl                   subb
              ,xla_assignment_defns_tl                   subt
        WHERE  subb.program_code                       = subt.program_code
         AND  subb.program_owner_code                  = subt.program_owner_code
         AND  subb.assignment_code                   = subt.assignment_code
         AND  subb.assignment_owner_code             = subt.assignment_owner_code
         AND  subb.language                         = subt.source_lang
         AND (SUBB.name                             <> SUBT.name
      ))
;

INSERT INTO xla_assignment_defns_tl
(creation_date
,program_code
,program_owner_code
,assignment_code
,assignment_owner_code
,name
,last_update_date
,last_updated_by
,last_update_login
,created_by
,language
,source_lang)
SELECT   /*+ ORDERED */
       b.creation_date
      ,b.program_code
      ,b.program_owner_code
      ,b.assignment_code
      ,b.assignment_owner_code
      ,b.name
      ,b.last_update_date
      ,b.last_updated_by
      ,b.last_update_login
      ,b.created_by
      ,l.language_code
      ,b.source_lang
FROM   xla_assignment_defns_tl             b
      ,fnd_languages                    l
WHERE  l.installed_flag                IN ('I', 'B')
  AND  b.language                       = userenv('LANG')
  AND  NOT EXISTS
      (SELECT NULL
       FROM   xla_assignment_defns_tl               t
       WHERE  t.program_code                      = b.program_code
         AND  t.program_owner_code                = b.program_owner_code
         AND  t.assignment_code                   = b.assignment_code
         AND  t.assignment_owner_code             = b.assignment_owner_code
         AND  t.language                          = l.language_code);

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
(p_program_code                       IN VARCHAR2
,p_program_owner_code                 IN VARCHAR2
,p_assignment_code                    IN VARCHAR2
,p_assignment_owner_code              IN VARCHAR2
,p_enabled_flag                       IN VARCHAR2
,p_ledger_short_name                  IN VARCHAR2
,p_owner                              IN VARCHAR2
,p_last_update_date                   IN VARCHAR2
,p_name                               IN VARCHAR2)
IS

  CURSOR c_ledger
  IS
  SELECT ledger_id
    FROM gl_ledgers
   WHERE short_name = p_ledger_short_name;

  l_ledger_id             INTEGER;
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

  OPEN c_ledger;
  FETCH c_ledger
   INTO l_ledger_id;
  CLOSE c_ledger;

  BEGIN

    SELECT last_updated_by, last_update_date
      INTO db_luby, db_ludate
      FROM xla_assignment_defns_vl
     WHERE program_code           = p_program_code
       AND program_owner_code     = p_program_owner_code
       AND assignment_code        = p_assignment_code
       AND assignment_owner_code  = p_assignment_owner_code;

    IF (fnd_load_util.upload_test(f_luby, f_ludate, db_luby, db_ludate, NULL)) THEN
      xla_assignment_defns_f_pkg.update_row
          (x_program_code                  => p_program_code
          ,x_program_owner_code            => p_program_owner_code
          ,x_assignment_code               => p_assignment_code
          ,x_assignment_owner_code         => p_assignment_owner_code
          ,x_enabled_flag                  => p_enabled_flag
          ,x_ledger_id                     => l_ledger_id
          ,x_name                          => p_name
          ,x_last_update_date              => f_ludate
          ,x_last_updated_by               => f_luby
          ,x_last_update_login             => 0);

    END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      xla_assignment_defns_f_pkg.insert_row
          (x_rowid                         => l_rowid
          ,x_program_code                  => p_program_code
          ,x_program_owner_code            => p_program_owner_code
          ,x_assignment_code               => p_assignment_code
          ,x_assignment_owner_code         => p_assignment_owner_code
          ,x_ledger_id                     => l_ledger_id
          ,x_enabled_flag                  => p_enabled_flag
          ,x_name                          => p_name
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
      (p_location   => 'xla_assignment_defns_f_pkg.load_row');

END load_row;

--=============================================================================
--
-- Name: translate_row
-- Description: To be used by FNDLOAD to upload a translated row
--
--=============================================================================
PROCEDURE translate_row
  (p_program_code                     IN VARCHAR2
  ,p_program_owner_code               IN VARCHAR2
  ,p_assignment_code                  IN VARCHAR2
  ,p_assignment_owner_code            IN VARCHAR2
  ,p_name                             IN VARCHAR2
  ,p_owner                            IN VARCHAR2
  ,p_last_update_date                 IN VARCHAR2
  ,p_custom_mode                      IN VARCHAR2)
IS

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

  BEGIN
    SELECT last_updated_by, last_update_date
      INTO db_luby, db_ludate
      FROM xla_assignment_defns_tl
     WHERE program_code          = p_program_code
       AND program_owner_code    = p_program_owner_code
       AND assignment_code       = assignment_code
       AND assignment_owner_code = assignment_owner_code
       AND language              = userenv('LANG');

    IF (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                               db_ludate, p_custom_mode)) then
      UPDATE xla_assignment_defns_tl
         SET name              = p_name
            ,last_update_date  = f_ludate
            ,last_updated_by   = f_luby
            ,last_update_login = 0
            ,source_lang       = userenv('LANG')
       WHERE userenv('LANG')   IN (language, source_lang)
         AND program_code          = p_program_code
         AND program_owner_code    = p_program_owner_code
         AND assignment_code       = p_assignment_code
         AND assignment_owner_code = p_assignment_owner_code;

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

end xla_assignment_defns_f_PKG;

/
