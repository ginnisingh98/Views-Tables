--------------------------------------------------------
--  DDL for Package Body XLA_POST_ACCT_PROGS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_POST_ACCT_PROGS_PKG" AS
/* $Header: xlaamprg.pkb 120.0 2005/05/24 21:39:07 dcshah noship $ */
/*======================================================================+
|             Copyright (c) 1995-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_post_acct_progs_pkg                                            |
|                                                                       |
| DESCRIPTION                                                           |
|    XLA Post Accounting Programs Package                               |
|                                                                       |
| HISTORY                                                               |
|    01-May-01 Dimple Shah    Created                                   |
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
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.xla_post_acct_progs_pkg';

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
      (p_location   => 'xla_post_acct_progs_pkg.trace');
END trace;



/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| delete_program_details                                                |
|                                                                       |
| Deletes all details of the Post Accounting Program                    |
|                                                                       |
+======================================================================*/

PROCEDURE delete_program_details
  (p_program_code                   IN VARCHAR2
  ,p_program_owner_code             IN VARCHAR2)
IS

   l_log_module  VARCHAR2(240);
BEGIN
   IF g_log_enabled THEN
     l_log_module := C_DEFAULT_MODULE||'.delete_program_details';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
     trace(p_msg    => 'BEGIN of procedure delete_program_details'
          ,p_module => l_log_module
          ,p_level  => C_LEVEL_PROCEDURE);
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
     trace(p_msg    => 'program_code = '||p_program_code||
                       ',program_owner_code = '||p_program_owner_code
          ,p_module => l_log_module
          ,p_level  => C_LEVEL_STATEMENT);
   END IF;

   DELETE
     FROM xla_acct_class_assgns
    WHERE program_code          = p_program_code
      AND program_owner_code    = p_program_owner_code;

   DELETE
     FROM xla_assignment_defns_tl
    WHERE program_code          = p_program_code
      AND program_owner_code    = p_program_owner_code;

   DELETE
     FROM xla_assignment_defns_b
    WHERE program_code          = p_program_code
      AND program_owner_code    = p_program_owner_code;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
     trace(p_msg    => 'END of procedure delete_program_details'
          ,p_module => l_log_module
          ,p_level  => C_LEVEL_PROCEDURE);
   END IF;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS                                   THEN
      xla_exceptions_pkg.raise_message
        (p_location   => 'xla_post_acct_progs_pkg.delete_program_details');

END delete_program_details;

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| delete_assignment_details                                             |
|                                                                       |
| Deletes all details of the Assignment Definition                      |
|                                                                       |
+======================================================================*/

PROCEDURE delete_assignment_details
  (p_program_code                   IN VARCHAR2
  ,p_program_owner_code             IN VARCHAR2
  ,p_assignment_code                IN VARCHAR2
  ,p_assignment_owner_code          IN VARCHAR2)

IS

   l_log_module  VARCHAR2(240);
BEGIN
   IF g_log_enabled THEN
     l_log_module := C_DEFAULT_MODULE||'.delete_assignment_details';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
     trace(p_msg    => 'BEGIN of procedure delete_assignment_details'
          ,p_module => l_log_module
          ,p_level  => C_LEVEL_PROCEDURE);
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
     trace(p_msg    => 'program_code = '||p_program_code||
                       ',program_owner_code = '||p_program_owner_code||
                       ',assignment_code = '||p_assignment_code||
                       ',assignment_owner_code = '||p_assignment_owner_code
          ,p_module => l_log_module
          ,p_level  => C_LEVEL_STATEMENT);
   END IF;

   DELETE
     FROM xla_acct_class_assgns
    WHERE program_code          = p_program_code
      AND program_owner_code    = p_program_owner_code
      AND assignment_code       = p_assignment_code
      AND assignment_owner_code = p_assignment_owner_code;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
     trace(p_msg    => 'END of procedure delete_assignment_details'
          ,p_module => l_log_module
          ,p_level  => C_LEVEL_PROCEDURE);
   END IF;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS                                   THEN
      xla_exceptions_pkg.raise_message
        (p_location   => 'xla_post_acct_progs_pkg.delete_ssignment_details');

END delete_assignment_details;

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| copy_assignment_details                                               |
|                                                                       |
| Copies all details of the Assignment Definition                       |
|                                                                       |
+======================================================================*/

PROCEDURE copy_assignment_details
  (p_program_code                   IN VARCHAR2
  ,p_program_owner_code             IN VARCHAR2
  ,p_old_assignment_code            IN VARCHAR2
  ,p_old_assignment_owner_code      IN VARCHAR2
  ,p_new_assignment_code            IN VARCHAR2
  ,p_new_assignment_owner_code      IN VARCHAR2)

IS
   l_creation_date                   DATE;
   l_last_update_date                DATE;
   l_created_by                      INTEGER;
   l_last_update_login               INTEGER;
   l_last_updated_by                 INTEGER;
   l_accounting_class_code           VARCHAR2(30);

   CURSOR c_acct_class
   IS
   SELECT accounting_class_code
     FROM xla_acct_class_assgns
    WHERE program_code                = p_program_code
      AND program_owner_code          = p_program_owner_code
      AND assignment_code             = p_old_assignment_code
      AND assignment_owner_code       = p_old_assignment_owner_code;

   l_log_module  VARCHAR2(240);
BEGIN
   IF g_log_enabled THEN
     l_log_module := C_DEFAULT_MODULE||'.copy_assignment_details';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
     trace(p_msg    => 'BEGIN of procedure copy_assignment_details'
          ,p_module => l_log_module
          ,p_level  => C_LEVEL_PROCEDURE);
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
     trace(p_msg    => 'program_code = '||p_program_code||
                       ',program_owner_code = '||p_program_owner_code||
                       ',old_assignment_code = '||p_old_assignment_code||
                       ',old_assignment_owner_code = '||p_old_assignment_owner_code||
                       ',new_assignment_code = '||p_new_assignment_code||
                       ',new_assignment_owner_code = '||p_new_assignment_owner_code
          ,p_module => l_log_module
          ,p_level  => C_LEVEL_STATEMENT);
   END IF;

   l_creation_date           := sysdate;
   l_last_update_date        := sysdate;
   l_created_by              := xla_environment_pkg.g_usr_id;
   l_last_update_login       := xla_environment_pkg.g_login_id;
   l_last_updated_by         := xla_environment_pkg.g_usr_id;

   OPEN c_acct_class;
   LOOP
      FETCH c_acct_class
       INTO l_accounting_class_code;
      EXIT WHEN c_acct_class%notfound;


   INSERT INTO xla_acct_class_assgns
     (program_code
     ,program_owner_code
     ,assignment_code
     ,assignment_owner_code
     ,accounting_class_code
     ,creation_date
     ,created_by
     ,last_update_date
     ,last_updated_by
     ,last_update_login)
    VALUES
      (p_program_code
      ,p_program_owner_code
      ,p_new_assignment_code
      ,p_new_assignment_owner_code
      ,l_accounting_class_code
      ,l_creation_date
      ,l_created_by
      ,l_last_update_date
      ,l_last_updated_by
      ,l_last_update_login);

   END LOOP;
   CLOSE c_acct_class;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
     trace(p_msg    => 'END of procedure copy_assignment_details'
          ,p_module => l_log_module
          ,p_level  => C_LEVEL_PROCEDURE);
   END IF;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS                                   THEN
      xla_exceptions_pkg.raise_message
        (p_location   => 'xla_post_acct_progs_pkg.copy_ssignment_details');

END copy_assignment_details;

END xla_post_acct_progs_pkg;

/
