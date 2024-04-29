--------------------------------------------------------
--  DDL for Package Body XLA_ACCT_CLASS_ASSGNS_F_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_ACCT_CLASS_ASSGNS_F_PKG" AS
/* $Header: xlatbaca.pkb 120.0 2005/05/24 21:47:23 dcshah noship $ */
/*======================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_acct_class_assgns                                           |
|                                                                       |
| DESCRIPTION                                                           |
|    Forms PL/SQL Wrapper for xla_acct_class_assgns                  |
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
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.xla_acct_class_assgns_f_pkg';

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
      (p_location   => 'xla_acct_class_assgns_f_pkg.trace');
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
  ,x_accounting_class_code            IN VARCHAR2
  ,x_creation_date                    IN DATE
  ,x_created_by                       IN NUMBER
  ,x_last_update_date                 IN DATE
  ,x_last_updated_by                  IN NUMBER
  ,x_last_update_login                IN NUMBER)

IS

CURSOR c IS
SELECT rowid
FROM   xla_acct_class_assgns
WHERE  program_code                          = x_program_code
  AND  program_owner_code                    = x_program_owner_code
  AND  assignment_code                       = x_assignment_code
  AND  assignment_owner_code                 = x_assignment_owner_code
  AND  accounting_class_code                 = x_accounting_class_code
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

INSERT INTO xla_acct_class_assgns
(creation_date
,created_by
,program_code
,program_owner_code
,assignment_code
,assignment_owner_code
,accounting_class_code
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
,x_accounting_class_code
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
  ,x_program_code                     IN VARCHAR2
  ,x_program_owner_code               IN VARCHAR2
  ,x_assignment_code                  IN VARCHAR2
  ,x_assignment_owner_code            IN VARCHAR2
  ,x_accounting_class_code            IN VARCHAR2)

IS

CURSOR c IS
SELECT program_code
      ,program_owner_code
      ,assignment_code
      ,assignment_owner_code
      ,accounting_class_code
FROM   xla_acct_class_assgns
WHERE  program_code                          = x_program_code
  AND  program_owner_code                    = x_program_owner_code
  AND  assignment_code                       = x_assignment_code
  AND  assignment_owner_code                 = x_assignment_owner_code
  AND  accounting_class_code                 = x_accounting_class_code
FOR UPDATE OF program_code NOWAIT;

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

IF ( (recinfo.program_code                           = x_program_code)
 AND (recinfo.program_owner_code                     = x_program_owner_code)
 AND (recinfo.assignment_code                        = x_assignment_code)
 AND (recinfo.assignment_owner_code                  = x_assignment_owner_code)
 AND (recinfo.accounting_class_code                  = x_accounting_class_code)
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
|  Procedure delete_row                                                 |
|                                                                       |
+======================================================================*/
PROCEDURE delete_row
  (x_program_code                     IN VARCHAR2
  ,x_program_owner_code               IN VARCHAR2
  ,x_assignment_code                  IN VARCHAR2
  ,x_assignment_owner_code            IN VARCHAR2
  ,x_accounting_class_code            IN VARCHAR2)

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

DELETE FROM xla_acct_class_assgns
WHERE  program_code                          = x_program_code
  AND  program_owner_code                    = x_program_owner_code
  AND  assignment_code                       = x_assignment_code
  AND  assignment_owner_code                 = x_assignment_owner_code
  AND  accounting_class_code                 = x_accounting_class_code;


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
(p_program_code                     IN VARCHAR2
,p_program_owner_code               IN VARCHAR2
,p_assignment_code                  IN VARCHAR2
,p_assignment_owner_code            IN VARCHAR2
,p_accounting_class_code            IN VARCHAR2
,p_owner                            IN VARCHAR2
,p_last_update_date                 IN VARCHAR2)
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

  BEGIN

    SELECT last_updated_by, last_update_date
      INTO db_luby, db_ludate
      FROM xla_acct_class_assgns
     WHERE program_code              = p_program_code
       AND program_owner_code        = p_program_owner_code
       AND assignment_code           = p_assignment_code
       AND assignment_owner_code     = p_assignment_owner_code
       AND accounting_class_code     = p_accounting_class_code;

    IF (fnd_load_util.upload_test(f_luby, f_ludate, db_luby, db_ludate, NULL)) THEN
        null;
    END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      xla_acct_class_assgns_f_pkg.insert_row
          (x_rowid                         => l_rowid
          ,x_program_code                  => p_program_code
          ,x_program_owner_code            => p_program_owner_code
          ,x_assignment_code               => p_assignment_code
          ,x_assignment_owner_code         => p_assignment_owner_code
          ,x_accounting_class_code         => p_accounting_class_code
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
      (p_location   => 'xla_acct_class_assgns_f_pkg.load_row');

END load_row;

end xla_acct_class_assgns_f_PKG;

/
