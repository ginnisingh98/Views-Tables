--------------------------------------------------------
--  DDL for Package Body XLA_CMP_CREATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_CMP_CREATE_PKG" AS
/* $Header: xlacpdbo.pkb 120.18 2006/12/08 22:07:01 weshen ship $   */
/*===========================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| PACKAGE NAME                                                               |
|     xla_cmp_create_pkg                                                     |
|                                                                            |
| DESCRIPTION                                                                |
|     This is a XLA private package, which contains all the APIs required    |
|     for creation packages (spec and body) in the database                  |
|                                                                            |
|                                                                            |
| HISTORY                                                                    |
|     25-JUN-2002 K.Boussema    Created                                      |
|     22-APR-2003 K.Boussema    Included error messages                      |
|     22-JAN-2004 K.Boussema    Changed to call the standards APPS_ARRAY_DDL |
|                               and APPS_DDL to create PL/SQL packages       |
|     23-FEB-2004 K.Boussema    Made changes for the FND_LOG.                |
|     22-MAR-2004 K.Boussema    Added a parameter p_module to the TRACE calls|
|                               and the procedure.                           |
|     11-MAY-2004 K.Boussema  Removed the call to XLA trace routine from     |
|                             trace() procedure                              |
|     02-JUN-2004 A.Quaglia     Added push_database_object, execute_dml      |
|                               ,execute_ddl                                 |
|     17-JUN-2004 A.Quaglia     push_database_object: removed alter package  |
|     21-JUN-2004 A.Quaglia     push_database_object: reintroduced package   |
|                               compilation but only when the package body is|
|                               created.                                     |
|     28-JUL-04 A.Quaglia       Changed message tokens                       |
|     08-JUN-05 W.Chan          Updated dump_package to loop the package from|
|                               user_source only if the log level is stmt    |
|                                                                            |
+===========================================================================*/

--
--+==========================================================================+
--|                                                                          |
--| Private global constants                                                 |
--|                                                                          |
--+==========================================================================+
--
C_CREATED_ERROR      CONSTANT BOOLEAN := FALSE;
C_CREATED            CONSTANT BOOLEAN := TRUE;
--
g_Max_line            CONSTANT NUMBER := 225;
g_chr_quote           CONSTANT VARCHAR2(10):='''';
g_chr_newline         CONSTANT VARCHAR2(10):= xla_environment_pkg.g_chr_newline;

--
--+==========================================================================+
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|           FND_LOG trace                                                  |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--+==========================================================================+

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
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.xla_cmp_create_pkg';

g_log_level           NUMBER;
g_log_enabled         BOOLEAN;

PROCEDURE trace
           (p_msg                        IN VARCHAR2
           ,p_level                      IN NUMBER
           ,p_module                     IN VARCHAR2 DEFAULT C_DEFAULT_MODULE)
IS
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
             (p_location   => 'xla_cmp_create_pkg.trace');
END trace;
--
--+==========================================================================+
--|                                                                          |
--| OVERVIEW of private procedures/functions                                 |
--|                                                                          |
--+==========================================================================+
--
--
--+==========================================================================+
--| PRIVATE procedures and functions                                         |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--+==========================================================================+


--
--+==========================================================================+
--| PRIVATE procedures and functions                                         |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--+==========================================================================+
--
PROCEDURE dump_package(    p_package_name         IN VARCHAR2
                         , p_package_type         IN VARCHAR2)
IS
--
CURSOR text_cur  ( p_package_name VARCHAR2
                  ,p_package_type VARCHAR2)
IS
SELECT us.text
     , us.line
  FROM user_source us
 WHERE us.name = UPPER(p_package_name)
   AND us.type = UPPER(p_package_type)
 ORDER BY line
;
--
l_first     BOOLEAN:= TRUE;
l_log_module         VARCHAR2(240);
--
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.dump_package';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of dump_package'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
IF (C_LEVEL_STATEMENT >= g_log_level) THEN
   FOR text_rec IN text_cur(p_package_name, p_package_type) LOOP
      --
      IF l_first THEN
          --
          IF (C_LEVEL_STATEMENT >= g_log_level) THEN

            trace
               (p_msg      => '>>> DUMP '|| p_package_type ||' = '||p_package_name
               ,p_level    => C_LEVEL_STATEMENT
               ,p_module   => l_log_module);

           END IF;

          l_first := FALSE;

      END IF;

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN

            trace
               (p_msg      => RPAD(text_rec.line ,10,' ') ||'   '||text_rec.text
               ,p_level    => C_LEVEL_STATEMENT
               ,p_module   => l_log_module);

      END IF;
      --
   END LOOP;
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of dump_package'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
--
EXCEPTION
   WHEN xla_exceptions_pkg.application_exception   THEN
       IF text_cur%ISOPEN THEN CLOSE text_cur; END IF;
       RAISE;
   WHEN OTHERS    THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_create_pkg.dump_package');
END dump_package;

--
--+==========================================================================+
--| PRIVATE procedures and functions                                         |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--+==========================================================================+
--
PROCEDURE get_pkg_errors(  p_product_rule_name    IN VARCHAR2
                         , p_package_name         IN VARCHAR2
                         , p_package_type         IN VARCHAR2)
IS
--
CURSOR error_cur ( p_package_name VARCHAR2
                  ,p_package_type VARCHAR2)
IS
SELECT SUBSTR(ue.text,1,2000) error
     , ue.line
  FROM user_errors ue
 WHERE ue.name = UPPER(p_package_name)
   AND ue.type = UPPER(p_package_type)
 ORDER BY line
;
--
l_first     BOOLEAN:= TRUE;
l_log_module         VARCHAR2(240);
--
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.get_pkg_errors';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of get_pkg_errors'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
FOR error_rec IN error_cur(p_package_name, p_package_type) LOOP
   --
   IF l_first THEN

       IF (C_LEVEL_ERROR >= g_log_level) THEN

         trace
            (p_msg      => '----- COMPILATION FAILS ------'
            ,p_level    => C_LEVEL_ERROR
            ,p_module   => l_log_module);

         trace
            (p_msg      => 'Additional information = '
            ,p_level    => C_LEVEL_ERROR
            ,p_module   => l_log_module);

         trace
            (p_msg      => '------------------------------'
            ,p_level    => C_LEVEL_ERROR
            ,p_module   => l_log_module);

         trace
            (p_msg      => 'Package name = '||p_package_name
            ,p_level    => C_LEVEL_ERROR
            ,p_module   => l_log_module);

         trace
            (p_msg      => 'Application Accounting Definition = '||p_product_rule_name
            ,p_level    => C_LEVEL_ERROR
            ,p_module   => l_log_module);

         trace
            (p_msg      => RPAD('LINE',10,' ') ||'|' ||' ERROR '
            ,p_level    => C_LEVEL_ERROR
            ,p_module   => l_log_module);

         trace
            (p_msg      => LPAD('-',10,'-')    ||'|' ||LPAD('-',50,'-')
            ,p_level    => C_LEVEL_ERROR
            ,p_module   => l_log_module);

       END IF;
       --
       l_first := FALSE;

   END IF;

   IF (C_LEVEL_ERROR >= g_log_level) THEN

         trace
            (p_msg      => RPAD(error_rec.line,10,' ') ||'| '||error_rec.error
            ,p_level    => C_LEVEL_ERROR
            ,p_module   => l_log_module);

   END IF;
   --
END LOOP;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of get_pkg_errors'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
--
EXCEPTION
   WHEN xla_exceptions_pkg.application_exception   THEN
       IF error_cur%ISOPEN THEN CLOSE error_cur; END IF;
       RAISE;
   WHEN OTHERS    THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_create_pkg.get_pkg_errors');
END get_pkg_errors;
--
--
--+==========================================================================+
--| PRIVATE procedures and functions                                         |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--+==========================================================================+
--
FUNCTION GetPackageStatus(   p_package_name         IN VARCHAR2
                           , p_package_type         IN VARCHAR2)
RETURN BOOLEAN
IS
--
l_IsValid            BOOLEAN;
l_status             VARCHAR2(10);
l_log_module         VARCHAR2(240);
--
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GetPackageStatus';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of GetPackageStatus'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
BEGIN
SELECT uo.status
  INTO l_status
  FROM user_objects uo
 WHERE uo.object_name = UPPER(p_package_name)
   AND uo.object_type = UPPER(p_package_type)
;
--
l_IsValid := (l_status = 'VALID');
--
EXCEPTION
 WHEN NO_DATA_FOUND THEN
   l_IsValid := FALSE;
END ;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of GetPackageStatus'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
RETURN l_IsValid;
EXCEPTION
   WHEN OTHERS THEN
       RETURN FALSE;
END GetPackageStatus;


--
--+==========================================================================+
--| PRIVATE procedures and functions                                         |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--+==========================================================================+
FUNCTION CreateBodyPackage (  p_product_rule_name    IN VARCHAR2
                            , p_package_name         IN VARCHAR2
                            , p_package_type         IN VARCHAR2
                            , p_package_text         IN DBMS_SQL.VARCHAR2S
                           )
RETURN BOOLEAN
IS
--
--

l_lb                INTEGER ;
l_ub                INTEGER ;
--
compilation_fails                          EXCEPTION;
package_locked                             EXCEPTION;
PRAGMA EXCEPTION_INIT (compilation_fails    , -24344);
PRAGMA EXCEPTION_INIT(package_locked        ,-04021);
--
l_log_module              VARCHAR2(240);
l_change_optimize_flag    BOOLEAN;
l_original_optimize_level NUMBER;
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.CreateBodyPackage';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of CreateBodyPackage'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
-- Init
--
l_lb                         := NVL(p_package_text.FIRST,0);
l_ub                         := NVL(p_package_text.LAST ,0);
APPS_ARRAY_DDL.glprogtext    := p_package_text;
l_change_optimize_flag       := FALSE;
--

IF (p_package_text.COUNT > 130000) THEN

  l_original_optimize_level := $$PLSQL_OPTIMIZE_LEVEL;
  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => '-> Package count > 130000 and original optimize level: '
                           ||TO_CHAR(l_original_optimize_level)
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
  END IF;

  IF (l_original_optimize_level > 1) THEN
    IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => '-> change optimize level'
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
    END IF;
    l_change_optimize_flag := TRUE;
    EXECUTE IMMEDIATE 'ALTER SESSION SET PLSQL_OPTIMIZE_LEVEL = 1';
  END IF;
END IF;




--
-- call apps_array_ddl API to create body package
--
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => '-> CALL APPS_ARRAY_DDL.apps_array_ddl API'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
APPS_ARRAY_DDL.apps_array_ddl(
                         lb           => l_lb,
                         ub           => l_ub
                         );
--
IF (l_change_optimize_flag) THEN
  IF (C_LEVEL_STATEMENT>= g_log_level) THEN
    trace
         (p_msg      => '-> Change optimize level back '
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
  END IF;
  EXECUTE IMMEDIATE 'ALTER SESSION SET PLSQL_OPTIMIZE_LEVEL = '||TO_CHAR(l_original_optimize_level);
END IF;
--
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of CreateBodyPackage'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
RETURN TRUE;
--
EXCEPTION
   WHEN package_locked    THEN

       IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            (p_msg      => 'ERROR: XLA_CMP_PACKAGE_LOCKED'
            ,p_level    => C_LEVEL_EXCEPTION
            ,p_module   => l_log_module);
       END IF;
       xla_exceptions_pkg.raise_message
                                ('XLA'
                                ,'XLA_CMP_PACKAGE_LOCKED'
                                ,'PACKAGE_NAME'
                                , p_package_name
                                );

       RETURN FALSE;
   WHEN compilation_fails THEN

       IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            (p_msg      => 'ERROR: XLA_CMP_COMPILATION_FAILED'
            ,p_level    => C_LEVEL_EXCEPTION
            ,p_module   => l_log_module);
       END IF;

       xla_exceptions_pkg.raise_message
                                       ('XLA'
                                       ,'XLA_CMP_COMPILATION_FAILED'
                                       ,'PACKAGE_NAME'
                                       , p_package_name
                                );

       RETURN FALSE;

   WHEN  xla_exceptions_pkg.application_exception   THEN

       RETURN FALSE;

  WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_create_pkg.CreateBodyPackage');
END CreateBodyPackage;

--
--+==========================================================================+
--| PRIVATE procedures and functions                                         |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--+==========================================================================+
--
FUNCTION CreateSpecPackage (  p_product_rule_name    IN VARCHAR2
                            , p_package_name         IN VARCHAR2
                            , p_package_type         IN VARCHAR2
                            , p_package_text         IN VARCHAR2
                          )
RETURN BOOLEAN
IS
compilation_fails                          EXCEPTION;
package_locked                             EXCEPTION;
PRAGMA EXCEPTION_INIT (compilation_fails    , -24344);
PRAGMA EXCEPTION_INIT(package_locked        ,-04021);
l_log_module         VARCHAR2(240);
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.CreateSpecPackage';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of CreateSpecPackage - '||p_package_name
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
IF (C_LEVEL_STATEMENT >= g_log_level) THEN

      trace
         (p_msg      => 'p_packgae_text =  '||p_package_text
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

END IF;
--
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => '-> CALL APPS_DDL.apps_ddl API'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
APPS_DDL.apps_ddl(ddl_text => p_package_text);

--
/*
dump_package( p_package_name       => p_package_name
            , p_package_type       => p_package_type
             );
*/

--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of CreateSpecPackage'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
  --
RETURN TRUE;
EXCEPTION
  WHEN  package_locked THEN
      --
       IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            (p_msg      => 'ERROR: XLA_CMP_PACKAGE_LOCKED'
            ,p_level    => C_LEVEL_EXCEPTION
            ,p_module   => l_log_module);
       END IF;

      xla_exceptions_pkg.raise_message
                                      ('XLA'
                                      ,'XLA_CMP_PACKAGE_LOCKED'
                                      ,'PACKAGE_NAME'
                                      , p_package_name
                                      );


      RETURN FALSE;

  WHEN compilation_fails THEN

       get_pkg_errors( p_product_rule_name => p_product_rule_name
                     , p_package_name      => p_package_name
                     , p_package_type      => p_package_type)
       ;
      --
/*
       dump_package( p_package_name       => p_package_name
                     , p_package_type      => p_package_type
                   );
*/

      --
       IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            (p_msg      => 'ERROR: XLA_CMP_COMPILATION_FAILED'
            ,p_level    => C_LEVEL_EXCEPTION
            ,p_module   => l_log_module);
       END IF;

       xla_exceptions_pkg.raise_message
                                              ('XLA'
                                              ,'XLA_CMP_COMPILATION_FAILED'
                                              ,'PACKAGE_NAME'
                                              , p_package_name
                                );

       RETURN FALSE;


  WHEN  xla_exceptions_pkg.application_exception   THEN
      --
      get_pkg_errors( p_product_rule_name => p_product_rule_name
                    , p_package_name      => p_package_name
                    , p_package_type      => p_package_type)
      ;
      --
/*
      dump_package( p_package_name       => p_package_name
                     , p_package_type      => p_package_type
                   );
*/
      --
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR'
            ,p_level    => C_LEVEL_EXCEPTION
            ,p_module   => l_log_module);
      END IF;
      --
      xla_exceptions_pkg.raise_message ('XLA'
                                       ,'XLA_CMP_COMPILER_ERROR'
                                       ,'PROCEDURE'
                                       ,'xla_cmp_create_pkg.CompileProductRule'
                                       ,'ERROR'
                                       , sqlerrm
                                       );
      RETURN FALSE;
  WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_create_pkg.CreateSpecPackage');
END CreateSpecPackage;

--+==========================================================================+
--| PUBLIC procedures and functions                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--+==========================================================================+
--+==========================================================================+
--| PUBLIC FUNCTION                                                          |
--|    create_package                                                        |
--|                                                                          |
--| DESCRIPTION                                                              |
--|    function called with package_text not null                            |
--+==========================================================================+

FUNCTION CreateSpecPackage(   p_product_rule_name    IN VARCHAR2
                            , p_package_name         IN VARCHAR2
                            , p_package_text         IN VARCHAR2
                          )
RETURN BOOLEAN
IS
--
l_package_text       VARCHAR2(32000);
l_created_flag       BOOLEAN := FALSE;
l_log_module         VARCHAR2(240);
--
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.CreateSpecPackage';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of CreateSpecPackage'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
         (p_msg      => 'p_product_rule_name = '||p_product_rule_name
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
         (p_msg      => 'p_package_name = '||p_package_name
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
l_package_text := p_package_text;
--
xla_cmp_string_pkg.truncate_lines( l_package_text);
--
l_created_flag := CreateSpecPackage(
                                    p_product_rule_name  => p_product_rule_name
                                  , p_package_name       => p_package_name
                                  , p_package_type       => C_SPECIFICATION
                                  , p_package_text       => l_package_text
                                  );
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of CreateSpecPackage'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
RETURN l_created_flag;
EXCEPTION
      WHEN xla_exceptions_pkg.application_exception   THEN
          RETURN FALSE;
      WHEN OTHERS    THEN
         xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_create_pkg.CreateSpecPackage');
END CreateSpecPackage;
--
--+==========================================================================+
--| PUBLIC FUNCTION                                                          |
--|    create_package                                                        |
--|                                                                          |
--| DESCRIPTION                                                              |
--|    function called with package_text not null                            |
--+==========================================================================+

FUNCTION CreateBodyPackage(   p_product_rule_name    IN VARCHAR2
                            , p_package_name         IN VARCHAR2
                            , p_package_text         IN DBMS_SQL.VARCHAR2S
                          )
RETURN BOOLEAN
IS
--
l_package_text       DBMS_SQL.VARCHAR2S;
l_created_flag       BOOLEAN := FALSE;
l_IsValid            BOOLEAN := TRUE;
l_log_module         VARCHAR2(240);
--
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.CreateBodyPackage';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of CreateBodyPackage'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
         (p_msg      => 'p_product_rule_name = '||p_product_rule_name
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
         (p_msg      => 'p_package_name = '||p_package_name
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
  --
  l_created_flag := CreateBodyPackage( p_product_rule_name  => p_product_rule_name
                                     , p_package_name       => p_package_name
                                     , p_package_type       => C_BODY
                                     , p_package_text       => p_package_text
                                     );

  --
  l_IsValid := GetPackageStatus(  p_package_name       => p_package_name
                                , p_package_type       => C_BODY
                                );
  --
/*
  dump_package(p_package_name          => p_package_name
               , p_package_type        => C_BODY
             );
*/
  --
  IF NOT l_IsValid THEN
   --
       get_pkg_errors( p_product_rule_name => p_product_rule_name
                      , p_package_name     => p_package_name
                      , p_package_type     => C_BODY)
      ;
  END IF;
  --
  l_created_flag  := l_created_flag  AND l_IsValid;
  --
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
     IF l_created_flag THEN
         trace
             (p_msg      => 'return value. = TRUE'
             ,p_level    => C_LEVEL_PROCEDURE
             ,p_module   => l_log_module);

      ELSE
         trace
             (p_msg      => 'return value. = FALSE'
             ,p_level    => C_LEVEL_PROCEDURE
             ,p_module   => l_log_module);

      END IF;

      trace
         (p_msg      => 'END of CreateBodyPackage'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
RETURN l_created_flag;
--
EXCEPTION
      WHEN xla_exceptions_pkg.application_exception   THEN
          RETURN FALSE;
      WHEN OTHERS    THEN
         xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_create_pkg.CreateBodyPackage');
END CreateBodyPackage;

--Additions for the Transaction Account Builder

FUNCTION execute_ddl
                        (
                          p_ddl_text         IN VARCHAR2
                         ,p_object_owner     IN VARCHAR2
                        )
RETURN BOOLEAN
IS
compilation_fails   EXCEPTION;
package_locked      EXCEPTION;
l_sql_stmt          VARCHAR2(2000);
l_log_module        VARCHAR2(2000);
PRAGMA EXCEPTION_INIT (compilation_fails    , -24344);
PRAGMA EXCEPTION_INIT(package_locked        , -04021);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.execute_ddl';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'BEGIN ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   IF p_object_owner IS NULL
   THEN
      APPS_DDL.apps_ddl( ddl_text => p_ddl_text );
   ELSE

      l_sql_stmt := 'BEGIN ' || p_object_owner || '.APPS_DDL.apps_ddl( ddl_text => ''' ||
      p_ddl_text  || ''' );' || ' END;';

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
            (p_module   => l_log_module
            ,p_msg      => l_sql_stmt
            ,p_level    => C_LEVEL_STATEMENT);
      END IF;

      EXECUTE IMMEDIATE l_sql_stmt;

   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   RETURN TRUE;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception   THEN
      RAISE;
   WHEN OTHERS    THEN
         xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_create_pkg.execute_ddl');

END execute_ddl
;


FUNCTION execute_ddl
               (
                 p_ddl_text         IN DBMS_SQL.VARCHAR2S
               )
RETURN BOOLEAN
IS
l_lb                       INTEGER ;
l_ub                       INTEGER ;
l_return_value             BOOLEAN;
compilation_fails          EXCEPTION;
package_locked             EXCEPTION;
l_log_module               VARCHAR2(2000);
l_fatal_error_message_text VARCHAR2(100);
PRAGMA EXCEPTION_INIT (package_locked        ,-04021);

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.execute_ddl';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'BEGIN ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   l_return_value               := TRUE;

   l_lb                         := NVL(p_ddl_text.FIRST,0);
   l_ub                         := NVL(p_ddl_text.LAST ,0);


   APPS_ARRAY_DDL.glprogtext    := p_ddl_text;
   APPS_ARRAY_DDL.apps_array_ddl
                      (
                        lb           => l_lb
                       ,ub           => l_ub
                      );

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   RETURN l_return_value;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception   THEN
      RAISE;
   WHEN compilation_fails
   THEN
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            (p_module   => l_log_module
            ,p_msg      => 'EXCEPTION:'
            ,p_level    => C_LEVEL_EXCEPTION);
         trace
            (p_msg      => 'Compilation failed'
            ,p_level    => C_LEVEL_EXCEPTION);
      END IF;
      IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
         trace
         (p_module   => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
      END IF;
      RETURN FALSE;
   WHEN package_locked
   THEN
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            (p_module   => l_log_module
            ,p_msg      => 'EXCEPTION:'
            ,p_level    => C_LEVEL_EXCEPTION);
         trace
            (p_module   => l_log_module
            ,p_msg      => 'Package is locked'
            ,p_level    => C_LEVEL_EXCEPTION);
      END IF;
      IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
         trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
      END IF;
      RETURN FALSE;
   WHEN OTHERS    THEN
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            (p_module   => l_log_module
            ,p_msg      => 'EXCEPTION:'
            ,p_level    => C_LEVEL_EXCEPTION);
         trace
            (p_module   => l_log_module
            ,p_msg      => SQLERRM
            ,p_level    => C_LEVEL_EXCEPTION);
      END IF;
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         xla_cmp_common_pkg.dump_text
                        (
                          p_text => p_ddl_text
                        );

      END IF;
      IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
         trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
      END IF;
      RETURN FALSE;
END execute_ddl
;

FUNCTION execute_dml
               (
                 p_dml_text         IN CLOB
                ,p_msg_mode         IN VARCHAR2
               )
RETURN BOOLEAN
IS

l_lb                       INTEGER ;
l_ub                       INTEGER ;
l_return_value             BOOLEAN;
compilation_fails          EXCEPTION;
package_locked             EXCEPTION;
l_dml_text                 DBMS_SQL.VARCHAR2S;
l_log_module               VARCHAR2(2000);
l_fatal_error_message_text VARCHAR2(100);
l_msg_mode                 VARCHAR2(1);

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.execute_ddl';
   END IF;

   IF p_msg_mode IS NULL
   THEN
      l_msg_mode := G_STANDARD_MESSAGE;
   ELSE
      l_msg_mode := p_msg_mode;
   END IF;

   l_return_value               := TRUE;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'BEGIN ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   --Move the CLOB into a VARCHAR2S
   xla_cmp_common_pkg.clob_to_varchar2s
                    (
                      p_clob          => p_dml_text
                     ,p_varchar2s     => l_dml_text
                    );


   l_lb                         := NVL(l_dml_text.FIRST,0);
   l_ub                         := NVL(l_dml_text.LAST ,0);


   APPS_ARRAY_DDL.glprogtext    := l_dml_text;
   APPS_ARRAY_DDL.apps_array_ddl
                      (
                        lb           => l_lb
                       ,ub           => l_ub
                      );

   RETURN TRUE;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

EXCEPTION
   WHEN OTHERS
   THEN
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            (p_msg      => 'EXCEPTION:'
            ,p_level    => C_LEVEL_EXCEPTION);
         trace
            (p_msg      => SQLERRM
            ,p_level    => C_LEVEL_EXCEPTION);
      END IF;
      xla_exceptions_pkg.raise_message
         ( p_location => 'xla_cmp_create_pkg.execute_dml'
          ,p_msg_mode => l_msg_mode
         );
END execute_dml
;

FUNCTION push_database_object
                        (
                          p_object_name          IN VARCHAR2
                         ,p_object_type          IN VARCHAR2
                         ,p_object_owner         IN VARCHAR2
                         ,p_apps_account         IN VARCHAR2
                         ,p_msg_mode             IN VARCHAR2
                         ,p_ddl_text             IN CLOB
                        )
RETURN BOOLEAN
IS
   l_return_value        BOOLEAN;
   l_cur_position        INTEGER;
   l_next_cr_position    INTEGER;
   l_text_length         INTEGER;
   l_additional_sql_stmt VARCHAR2(2000);
   l_ddl_text            DBMS_SQL.VARCHAR2S;
   l_log_module          VARCHAR2 (2000);

   le_table_not_exists   EXCEPTION;
   le_compilation_fails  EXCEPTION;
   PRAGMA EXCEPTION_INIT (le_table_not_exists     ,-00942);
   PRAGMA EXCEPTION_INIT (le_compilation_fails    , -24344);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.push_database_object';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'BEGIN ' || C_DEFAULT_MODULE||'.push_database_object'
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   l_return_value := TRUE;

   IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace
            (p_msg      => 'DDL text size: ' || LENGTH(p_ddl_text)
            ,p_level    => C_LEVEL_EVENT);
   END IF;

   --If the object to push is a table try to drop in case it exists
   IF p_object_type = 'TABLE'
   THEN
      --drop the already existing one (if it exists)
      l_additional_sql_stmt :=
         'DROP TABLE ' || p_object_owner || '.' || p_object_name;
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
            (p_msg      => l_additional_sql_stmt
            ,p_level    => C_LEVEL_STATEMENT);
      END IF;

      BEGIN
         EXECUTE IMMEDIATE l_additional_sql_stmt;
      EXCEPTION
      WHEN le_table_not_exists
      THEN
         NULL;
      WHEN OTHERS
      THEN
         RAISE;
      END;
   END IF;

   --Move the CLOB into a VARCHAR2S
   xla_cmp_common_pkg.clob_to_varchar2s
                    (
                      p_clob          => p_ddl_text
                     ,p_varchar2s     => l_ddl_text
                    );

   l_return_value := execute_ddl
                         (
                           p_ddl_text         => l_ddl_text
                         );


   --Post creation activities

   --If the object to push is a table create synonym and grants
   IF p_object_type = 'TABLE'
   THEN
      --create the synonym
      l_additional_sql_stmt :=
         'CREATE OR REPLACE SYNONYM ' ||
          p_apps_account || '.' || p_object_name ||
          ' FOR ' || p_object_owner || '.' || p_object_name;

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
            (p_msg      => l_additional_sql_stmt
            ,p_level    => C_LEVEL_STATEMENT);
      END IF;

      EXECUTE IMMEDIATE l_additional_sql_stmt;

      --grant all to the apps account
      l_return_value := execute_ddl
          (
            p_ddl_text         => 'GRANT ALL ON ' || p_object_owner || '.'  ||
                                  p_object_name   || ' TO ' ||
                                  p_apps_account  || ' WITH GRANT OPTION'
           ,p_object_owner     => p_object_owner
          );

   ELSIF p_object_type = 'PACKAGE BODY'
   THEN
      l_additional_sql_stmt :=
         'ALTER PACKAGE ' || p_object_name ||
          ' COMPILE
          ';

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
            (p_msg      => l_additional_sql_stmt
            ,p_level    => C_LEVEL_STATEMENT);
      END IF;

      EXECUTE IMMEDIATE l_additional_sql_stmt;
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || C_DEFAULT_MODULE||'.push_database_object'
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   RETURN l_return_value;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception   THEN
      RAISE;
   WHEN le_compilation_fails
   THEN
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            (p_module   => l_log_module
            ,p_msg      => 'EXCEPTION:'
            ,p_level    => C_LEVEL_EXCEPTION);
         trace
            (p_module   => l_log_module
            ,p_msg      => 'Compilation failed'
            ,p_level    => C_LEVEL_EXCEPTION);
         trace
            (p_module   => l_log_module
            ,p_msg      => SQLERRM
            ,p_level    => C_LEVEL_EXCEPTION);
      END IF;
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         xla_cmp_common_pkg.dump_text
                        (
                          p_text => p_ddl_text
                        );
      END IF;

      xla_exceptions_pkg.raise_message
      ( p_appli_s_name    => 'XLA'
       ,p_msg_name        => 'XLA_TAB_CMP_ALTER_PKG_COMPILE'
       ,p_token_1         => 'PACKAGE_NAME'
       ,p_value_1         => p_object_name
       ,p_token_2         => 'ERROR_MSG'
       ,p_value_2         => SQLERRM
       ,p_msg_mode        => p_msg_mode
      );

      IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
         trace
         (p_module   => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
      END IF;
      RETURN FALSE;
   WHEN OTHERS    THEN
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            (p_msg      => 'EXCEPTION:'
            ,p_level    => C_LEVEL_EXCEPTION);
         trace
            (p_msg      => SQLERRM
            ,p_level    => C_LEVEL_EXCEPTION);
      END IF;
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         xla_cmp_common_pkg.dump_text
                        (
                          p_text => p_ddl_text
                        );
      END IF;

      xla_exceptions_pkg.raise_message
         ( p_location => 'xla_cmp_create_pkg.push_database_object'
          ,p_msg_mode => p_msg_mode
         );

      IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
         trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
      END IF;
      RETURN FALSE;
END push_database_object;



--
--=============================================================================
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--=============================================================================
--=============================================================================
--          *********** Initialization routine **********
--=============================================================================

BEGIN

   g_log_level      := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   g_log_enabled    := fnd_log.test
                          (log_level  => g_log_level
                          ,module     => C_DEFAULT_MODULE);

   IF NOT g_log_enabled  THEN
      g_log_level := C_LEVEL_LOG_DISABLED;
   END IF;


END xla_cmp_create_pkg; -- end of package body

/
