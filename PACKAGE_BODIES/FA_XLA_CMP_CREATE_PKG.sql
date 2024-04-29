--------------------------------------------------------
--  DDL for Package Body FA_XLA_CMP_CREATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_XLA_CMP_CREATE_PKG" AS
/* $Header: faxlaccb.pls 120.0.12010000.3 2009/10/29 12:45:42 bridgway ship $   */
/*===========================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| PACKAGE NAME                                                               |
|     fa_xla_cmp_create_pkg                                                  |
|                                                                            |
| DESCRIPTION                                                                |
|     This is a FA private package, which contains all the APIs required     |
|     for creation packages (spec and body) in the database                  |
|                                                                            |
|                                                                            |
| HISTORY                                                                    |
|     25-FEB-2006 BRIDGWAY      Created                                      |
|                                                                            |
+===========================================================================*/


--+==========================================================================+
--|                                                                          |
--| Private global constants                                                 |
--|                                                                          |
--+==========================================================================+

C_CREATED_ERROR      CONSTANT BOOLEAN := FALSE;
C_CREATED            CONSTANT BOOLEAN := TRUE;

g_Max_line            CONSTANT NUMBER := 225;
g_chr_quote           CONSTANT VARCHAR2(10):='''';
g_chr_newline         CONSTANT VARCHAR2(10):= fa_cmp_string_pkg.g_chr_newline;

g_log_level_rec fa_api_types.log_level_rec_type;

G_CURRENT_RUNTIME_LEVEL        NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

G_LEVEL_STATEMENT     CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
G_LEVEL_PROCEDURE     CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
G_LEVEL_EVENT         CONSTANT NUMBER := FND_LOG.LEVEL_EVENT;
G_LEVEL_EXCEPTION     CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
G_LEVEL_ERROR         CONSTANT NUMBER := FND_LOG.LEVEL_ERROR;
G_LEVEL_UNEXPECTED    CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;

G_MODULE_NAME         CONSTANT VARCHAR2(50):= 'fa.plsql.fa_xla_cmp_create_pkg.';

--+==========================================================================+
--|                                                                          |
--| PRIVATE procedures and functions                                         |
--|                                                                          |
--+==========================================================================+

PROCEDURE dump_package(  p_package_name         IN VARCHAR2,
                         p_package_type         IN VARCHAR2)
IS

   CURSOR text_cur  ( p_package_name VARCHAR2
                     ,p_package_type VARCHAR2) IS
   SELECT us.text
        , us.line
     FROM user_source us
    WHERE us.name = UPPER(p_package_name)
      AND us.type = UPPER(p_package_type)
    ORDER BY line;

   l_first     BOOLEAN:= TRUE;
   l_procedure_name      varchar2(80) := 'dump_package';

BEGIN

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(G_LEVEL_PROCEDURE,
                     G_MODULE_NAME||l_procedure_name||'.begin',
                     'Beginning of procedure');
   END IF;

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN

      FOR text_rec IN text_cur(p_package_name, p_package_type) LOOP

         IF l_first THEN

            IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
               fnd_log.string(G_LEVEL_STATEMENT,
                              G_MODULE_NAME||l_procedure_name,
                              '>>> DUMP '|| p_package_type ||' = '||p_package_name);
            END IF;

            l_first := FALSE;

         END IF;

         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
            fnd_log.string(G_LEVEL_STATEMENT,
                           G_MODULE_NAME||l_procedure_name,
                           RPAD(text_rec.line ,10,' ') ||'   '||text_rec.text);
         END IF;

      END LOOP;
   END IF;

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(G_LEVEL_PROCEDURE,
                     G_MODULE_NAME||l_procedure_name||'.end',
                     'End of procedure');
   END IF;

EXCEPTION
   WHEN OTHERS THEN
        IF (G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL ) THEN
           fnd_message.set_name('OFA','FA_SHARED_ORACLE_ERR');
           fnd_message.set_token('ORACLE_ERR',SQLERRM);
           FND_LOG.MESSAGE (G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_procedure_name,TRUE);
        END IF;
        raise;

END dump_package;


--+==========================================================================+
--|                                                                          |
--| PRIVATE procedures and functions                                         |
--|                                                                          |
--+==========================================================================+

PROCEDURE get_pkg_errors(p_package_name         IN VARCHAR2,
                         p_package_type         IN VARCHAR2) IS

   CURSOR error_cur ( p_package_name VARCHAR2
                     ,p_package_type VARCHAR2) IS
   SELECT SUBSTR(ue.text,1,2000) error
        , ue.line
     FROM user_errors ue
    WHERE ue.name = UPPER(p_package_name)
      AND ue.type = UPPER(p_package_type)
    ORDER BY line;

   l_first     BOOLEAN:= TRUE;
   l_procedure_name      varchar2(80) := 'get_pkg_errors';

BEGIN

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(G_LEVEL_PROCEDURE,
                     G_MODULE_NAME||l_procedure_name||'.begin',
                     'Beginning of procedure');
   END IF;


   FOR error_rec IN error_cur(p_package_name, p_package_type) LOOP

      IF l_first THEN

         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN

            fnd_log.string(G_LEVEL_STATEMENT,
                           G_MODULE_NAME||l_procedure_name,
                           '----- COMPILATION FAILS ------');

            fnd_log.string(G_LEVEL_STATEMENT,
                           G_MODULE_NAME||l_procedure_name,
                           'Additional information = ');

            fnd_log.string(G_LEVEL_STATEMENT,
                           G_MODULE_NAME||l_procedure_name,
                           '------------------------------');

            fnd_log.string(G_LEVEL_STATEMENT,
                           G_MODULE_NAME||l_procedure_name,
                           'Package name = '||p_package_name);

            fnd_log.string(G_LEVEL_STATEMENT,
                           G_MODULE_NAME||l_procedure_name,
                           RPAD('LINE',10,' ') ||'|' ||' ERROR ');

            fnd_log.string(G_LEVEL_STATEMENT,
                           G_MODULE_NAME||l_procedure_name,
                           LPAD('-',10,'-')    ||'|' ||LPAD('-',50,'-'));

         END IF;

         l_first := FALSE;

      END IF;


      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
         fnd_log.string(G_LEVEL_STATEMENT,
                        G_MODULE_NAME||l_procedure_name,
                        RPAD(error_rec.line,10,' ') ||'| '||error_rec.error);
      END IF;

   END LOOP;

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(G_LEVEL_PROCEDURE,
                     G_MODULE_NAME||l_procedure_name||'.end',
                     'End of procedure');
   END IF;

EXCEPTION
   WHEN OTHERS    THEN
        IF (G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL ) THEN
           fnd_message.set_name('OFA','FA_SHARED_ORACLE_ERR');
           fnd_message.set_token('ORACLE_ERR',SQLERRM);
           FND_LOG.MESSAGE (G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_procedure_name,TRUE);
        END IF;
        raise;

END get_pkg_errors;


--+==========================================================================+
--|                                                                          |
--| PRIVATE procedures and functions                                         |
--|                                                                          |
--+==========================================================================+

FUNCTION GetPackageStatus( p_package_name         IN VARCHAR2,
                           p_package_type         IN VARCHAR2)
RETURN BOOLEAN IS

   l_IsValid            BOOLEAN;
   l_status             VARCHAR2(10);
   l_procedure_name      varchar2(80) := 'GetPackageStatus';

BEGIN

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(G_LEVEL_PROCEDURE,
                     G_MODULE_NAME||l_procedure_name||'.begin',
                     'Beginning of procedure');
   END IF;


   BEGIN
      SELECT uo.status
        INTO l_status
        FROM user_objects uo
       WHERE uo.object_name = UPPER(p_package_name)
         AND uo.object_type = UPPER(p_package_type);

      l_IsValid := (l_status = 'VALID');

   EXCEPTION
      WHEN NO_DATA_FOUND THEN
          l_IsValid := FALSE;
   END;

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(G_LEVEL_PROCEDURE,
                     G_MODULE_NAME||l_procedure_name||'.end',
                     'End of procedure');
   END IF;

   RETURN l_IsValid;

EXCEPTION
   WHEN OTHERS THEN
        IF (G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL ) THEN
           fnd_message.set_name('OFA','FA_SHARED_ORACLE_ERR');
           fnd_message.set_token('ORACLE_ERR',SQLERRM);
           FND_LOG.MESSAGE (G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_procedure_name,TRUE);
        END IF;
        RETURN FALSE;

END GetPackageStatus;

--+==========================================================================+
--|                                                                          |
--| PRIVATE procedures and functions                                         |
--|                                                                          |
--+==========================================================================+

FUNCTION CreateBodyPackage (p_package_name         IN VARCHAR2,
                            p_package_type         IN VARCHAR2,
                            p_package_text         IN DBMS_SQL.VARCHAR2S
                           )
RETURN BOOLEAN IS

   l_lb                INTEGER ;
   l_ub                INTEGER ;
   compilation_fails                          EXCEPTION;
   package_locked                             EXCEPTION;
   PRAGMA EXCEPTION_INIT (compilation_fails    , -24344);
   PRAGMA EXCEPTION_INIT (package_locked        ,-04021);

   l_procedure_name      varchar2(80) := 'CreateBodyPackage';

BEGIN

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(G_LEVEL_PROCEDURE,
                     G_MODULE_NAME||l_procedure_name||'.begin',
                     'Beginning of procedure');
   END IF;

   -- Init
   l_lb                         := NVL(p_package_text.FIRST,0);
   l_ub                         := NVL(p_package_text.LAST ,0);
   APPS_ARRAY_DDL.glprogtext    := p_package_text;

   --
   -- call apps_array_ddl API to create body package
   --

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(G_LEVEL_STATEMENT,
                     G_MODULE_NAME||l_procedure_name,
                     '-> CALL APPS_ARRAY_DDL.apps_array_ddl API');
   END IF;

   APPS_ARRAY_DDL.apps_array_ddl(
                        lb           => l_lb,
                        ub           => l_ub
                        );

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(G_LEVEL_PROCEDURE,
                     G_MODULE_NAME||l_procedure_name||'.end',
                     'End of procedure');
   END IF;

   RETURN TRUE;

EXCEPTION
   WHEN package_locked    THEN

        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
           fnd_log.string(G_LEVEL_STATEMENT,
                          G_MODULE_NAME||l_procedure_name,
                          'ERROR: Package Locked');
        END IF;

        IF (G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL ) THEN
           fnd_message.set_name('XLA','XLA_CMP_PACKAGE_LOCKED');
           fnd_message.set_token('PACKAGE_NAME',p_package_name);
           FND_LOG.MESSAGE (G_LEVEL_ERROR,G_MODULE_NAME||l_procedure_name,TRUE);
        END IF;

        RETURN FALSE;

   WHEN compilation_fails THEN

        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
           fnd_log.string(G_LEVEL_STATEMENT,
                          G_MODULE_NAME||l_procedure_name,
                          'ERROR: Package Compilation Failed');
        END IF;

        IF (G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL ) THEN
           fnd_message.set_name('XLA','XLA_CMP_COMPILATION_FAILED');
           fnd_message.set_token('PACKAGE_NAME',p_package_name);
           FND_LOG.MESSAGE (G_LEVEL_ERROR,G_MODULE_NAME||l_procedure_name,TRUE);
        END IF;

        RETURN FALSE;

   WHEN OTHERS THEN
        IF (G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL ) THEN
           fnd_message.set_name('OFA','FA_SHARED_ORACLE_ERR');
           fnd_message.set_token('ORACLE_ERR',SQLERRM);
           FND_LOG.MESSAGE (G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_procedure_name,TRUE);
        END IF;

        RETURN FALSE;

END CreateBodyPackage;


--+==========================================================================+
--|                                                                          |
--| PRIVATE procedures and functions                                         |
--|                                                                          |
--+==========================================================================+

FUNCTION CreateSpecPackage (p_package_name         IN VARCHAR2,
                            p_package_type         IN VARCHAR2,
                            p_package_text         IN VARCHAR2
                          )
   RETURN BOOLEAN IS
   compilation_fails                          EXCEPTION;
   package_locked                             EXCEPTION;
   PRAGMA EXCEPTION_INIT (compilation_fails    , -24344);
   PRAGMA EXCEPTION_INIT(package_locked        ,-04021);
   l_procedure_name      varchar2(80) := 'CreateSpecPackage';

BEGIN

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(G_LEVEL_PROCEDURE,
                     G_MODULE_NAME||l_procedure_name||'.begin',
                     'Beginning of procedure');
   END IF;


   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(G_LEVEL_STATEMENT,
                     G_MODULE_NAME||l_procedure_name,
                     'p_package_text =  '||p_package_text);
   END IF;

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(G_LEVEL_STATEMENT,
                     G_MODULE_NAME||l_procedure_name,
                     '-> CALL APPS_DDL.apps_ddl API');
   END IF;

   APPS_DDL.apps_ddl(ddl_text => p_package_text);

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(G_LEVEL_PROCEDURE,
                     G_MODULE_NAME||l_procedure_name||'.end',
                     'End of procedure');
   END IF;

   RETURN TRUE;

EXCEPTION

   WHEN package_locked THEN
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
           fnd_log.string(G_LEVEL_STATEMENT,
                          G_MODULE_NAME||l_procedure_name,
                          'ERROR: XLA_CMP_PACKAGE_LOCKED');
        END IF;

        IF (G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL ) THEN
           fnd_message.set_name('XLA','XLA_CMP_PACKAGE_LOCKED');
           fnd_message.set_token('PACKAGE_NAME',p_package_name);
           FND_LOG.MESSAGE (G_LEVEL_ERROR,G_MODULE_NAME||l_procedure_name,TRUE);
        END IF;

        RETURN FALSE;

   WHEN compilation_fails THEN

        get_pkg_errors( p_package_name      => p_package_name
                      , p_package_type      => p_package_type);
        dump_package( p_package_name       => p_package_name
                      , p_package_type      => p_package_type
                    );

        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
           fnd_log.string(G_LEVEL_STATEMENT,
                          G_MODULE_NAME||l_procedure_name,
                          'ERROR: XLA_CMP_COMPILATION_FAILED');
        END IF;

        IF (G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL ) THEN
           fnd_message.set_name('XLA','XLA_CMP_COMPILATION_FAILED');
           fnd_message.set_token('PACKAGE_NAME',p_package_name);
           FND_LOG.MESSAGE (G_LEVEL_ERROR,G_MODULE_NAME||l_procedure_name,TRUE);
        END IF;

        RETURN FALSE;

   WHEN OTHERS THEN
        IF (G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL ) THEN
           fnd_message.set_name('OFA','FA_SHARED_ORACLE_ERR');
           fnd_message.set_token('ORACLE_ERR',SQLERRM);
           FND_LOG.MESSAGE (G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_procedure_name,TRUE);
        END IF;

        return false;

END CreateSpecPackage;

--+==========================================================================+
--|                                                                          |
--| PUBLIC procedures and functions                                          |
--|                                                                          |
--+==========================================================================+

--+==========================================================================+
--| PUBLIC FUNCTION                                                          |
--|    create_package                                                        |
--|                                                                          |
--| DESCRIPTION                                                              |
--|    function called with package_text not null                            |
--+==========================================================================+

FUNCTION CreateSpecPackage( p_package_name         IN VARCHAR2,
                            p_package_text         IN VARCHAR2
                          )
RETURN BOOLEAN IS

   l_package_text       VARCHAR2(32000);
   l_created_flag       BOOLEAN := FALSE;
   l_procedure_name      varchar2(80) := 'CreateSpecPackage';

BEGIN

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(G_LEVEL_PROCEDURE,
                     G_MODULE_NAME||l_procedure_name||'.begin',
                     'Beginning of procedure');
   END IF;


   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(G_LEVEL_STATEMENT,
                     G_MODULE_NAME||l_procedure_name,
                     'p_package_name = '||p_package_name);

   END IF;

   l_package_text := p_package_text;

   fa_cmp_string_pkg.truncate_lines( l_package_text);

   l_created_flag := CreateSpecPackage(
                                    p_package_name       => p_package_name
                                  , p_package_type       => C_SPECIFICATION
                                  , p_package_text       => l_package_text
                                  );

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(G_LEVEL_PROCEDURE,
                     G_MODULE_NAME||l_procedure_name||'.end',
                     'End of procedure');
   END IF;

   RETURN l_created_flag;

EXCEPTION
   WHEN OTHERS    THEN
        IF (G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL ) THEN
           fnd_message.set_name('OFA','FA_SHARED_ORACLE_ERR');
           fnd_message.set_token('ORACLE_ERR',SQLERRM);
           FND_LOG.MESSAGE (G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_procedure_name,TRUE);
        END IF;

        return false;

END CreateSpecPackage;

--+==========================================================================+
--| PUBLIC FUNCTION                                                          |
--|    create_package                                                        |
--|                                                                          |
--| DESCRIPTION                                                              |
--|    function called with package_text not null                            |
--+==========================================================================+

FUNCTION CreateBodyPackage( p_package_name         IN VARCHAR2,
                            p_package_text         IN DBMS_SQL.VARCHAR2S
                          )
RETURN BOOLEAN IS

   l_package_text       DBMS_SQL.VARCHAR2S;
   l_created_flag       BOOLEAN := FALSE;
   l_IsValid            BOOLEAN := TRUE;
   l_procedure_name      varchar2(80) := 'CreateBodyPackage';

BEGIN

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(G_LEVEL_PROCEDURE,
                     G_MODULE_NAME||l_procedure_name||'.begin',
                     'Beginning of procedure');
   END IF;

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN

      fnd_log.string(G_LEVEL_STATEMENT,
                     G_MODULE_NAME||l_procedure_name,
                     'p_package_name = '||p_package_name);

   END IF;

   l_created_flag := CreateBodyPackage(p_package_name       => p_package_name
                                     , p_package_type       => C_BODY
                                     , p_package_text       => p_package_text);

   l_IsValid := GetPackageStatus( p_package_name       => p_package_name
                                , p_package_type       => C_BODY);


   /* this is already handled above and is easier to read:

   dump_package(p_package_name          => p_package_name
              , p_package_type        => C_BODY
             );
   */

   IF NOT l_IsValid THEN
       get_pkg_errors(  p_package_name     => p_package_name
                      , p_package_type     => C_BODY);
   END IF;

   l_created_flag  := l_created_flag  AND l_IsValid;

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
      IF l_created_flag THEN
         fnd_log.string(G_LEVEL_STATEMENT,
                        G_MODULE_NAME||l_procedure_name,
                         'return value. = TRUE');
      ELSE
         fnd_log.string(G_LEVEL_STATEMENT,
                        G_MODULE_NAME||l_procedure_name,
                        'return value. = FALSE');
      END IF;
   END IF;

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(G_LEVEL_PROCEDURE,
                     G_MODULE_NAME||l_procedure_name||'.end',
                     'End of procedure');
   END IF;

   RETURN l_created_flag;

EXCEPTION
   WHEN OTHERS THEN
        IF (G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL ) THEN
           fnd_message.set_name('OFA','FA_SHARED_ORACLE_ERR');
           fnd_message.set_token('ORACLE_ERR',SQLERRM);
           FND_LOG.MESSAGE (G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_procedure_name,TRUE);
        END IF;

        return false;

END CreateBodyPackage;

--Additions for the Transaction Account Builder

FUNCTION execute_ddl
                        (
                          p_ddl_text         IN VARCHAR2,
                          p_object_owner     IN VARCHAR2
                        )
RETURN BOOLEAN IS
   compilation_fails   EXCEPTION;
   package_locked      EXCEPTION;
   l_sql_stmt          VARCHAR2(2000);
   l_procedure_name    varchar2(80) := 'execute_ddl';

   PRAGMA EXCEPTION_INIT (compilation_fails    , -24344);
   PRAGMA EXCEPTION_INIT(package_locked        , -04021);

BEGIN

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(G_LEVEL_PROCEDURE,
                     G_MODULE_NAME||l_procedure_name||'.begin',
                     'Beginning of procedure');
   END IF;

   IF p_object_owner IS NULL THEN
      APPS_DDL.apps_ddl( ddl_text => p_ddl_text );
   ELSE
      l_sql_stmt := 'BEGIN ' || p_object_owner || '.APPS_DDL.apps_ddl( ddl_text => ''' ||
      p_ddl_text  || ''' );' || ' END;';

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
         fnd_log.string(G_LEVEL_STATEMENT,
                        G_MODULE_NAME||l_procedure_name,
                        l_sql_stmt);
      END IF;

      EXECUTE IMMEDIATE l_sql_stmt;

   END IF;

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(G_LEVEL_PROCEDURE,
                     G_MODULE_NAME||l_procedure_name||'.end',
                     'End of procedure');
   END IF;

   RETURN TRUE;

EXCEPTION
   WHEN OTHERS    THEN
        IF (G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL ) THEN
           fnd_message.set_name('OFA','FA_SHARED_ORACLE_ERR');
           fnd_message.set_token('ORACLE_ERR',SQLERRM);
           FND_LOG.MESSAGE (G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_procedure_name,TRUE);
        END IF;

        return false;

END execute_ddl;


FUNCTION execute_ddl
               (
                 p_ddl_text         IN DBMS_SQL.VARCHAR2S
               )
RETURN BOOLEAN IS

   l_lb                       INTEGER ;
   l_ub                       INTEGER ;
   l_return_value             BOOLEAN;
   compilation_fails          EXCEPTION;
   package_locked             EXCEPTION;
   l_procedure_name      varchar2(80) := 'execute_ddl';
   l_fatal_error_message_text VARCHAR2(100);
   PRAGMA EXCEPTION_INIT (package_locked        ,-04021);

BEGIN

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(G_LEVEL_PROCEDURE,
                     G_MODULE_NAME||l_procedure_name||'.begin',
                     'Beginning of procedure');
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

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(G_LEVEL_PROCEDURE,
                     G_MODULE_NAME||l_procedure_name||'.end',
                     'End of procedure');
   END IF;

   RETURN l_return_value;

EXCEPTION

   WHEN compilation_fails THEN

        IF (G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL ) THEN
           fnd_message.set_name('OFA','FA_SHARED_ORACLE_ERR');
           fnd_message.set_token('ORACLE_ERR',SQLERRM);
           FND_LOG.MESSAGE (G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_procedure_name,TRUE);
        END IF;

        RETURN FALSE;

   WHEN package_locked THEN

        IF (G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL ) THEN
           fnd_message.set_name('OFA','FA_SHARED_ORACLE_ERR');
           fnd_message.set_token('ORACLE_ERR',SQLERRM);
           FND_LOG.MESSAGE (G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_procedure_name,TRUE);
        END IF;

        RETURN FALSE;

   WHEN OTHERS THEN

        IF (G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL ) THEN
           fnd_message.set_name('OFA','FA_SHARED_ORACLE_ERR');
           fnd_message.set_token('ORACLE_ERR',SQLERRM);
           FND_LOG.MESSAGE (G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_procedure_name,TRUE);
        END IF;

        RETURN FALSE;

        --BMR : do we need routine like xla_cmp_common_pkg.dump_text here????

END execute_ddl;

FUNCTION execute_dml
               (
                 p_dml_text         IN CLOB
               )
RETURN BOOLEAN IS

   l_lb                       INTEGER ;
   l_ub                       INTEGER ;
   l_return_value             BOOLEAN;
   compilation_fails          EXCEPTION;
   package_locked             EXCEPTION;
   l_dml_text                 DBMS_SQL.VARCHAR2S;
   l_procedure_name           varchar2(80) := 'execute_dml';
   l_fatal_error_message_text VARCHAR2(100);

BEGIN

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(G_LEVEL_PROCEDURE,
                     G_MODULE_NAME||l_procedure_name||'.begin',
                     'Beginning of procedure');
   END IF;

   l_return_value               := TRUE;

   --Move the CLOB into a VARCHAR2S
   fa_cmp_string_pkg.clob_to_varchar2s
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

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(G_LEVEL_PROCEDURE,
                     G_MODULE_NAME||l_procedure_name||'.end',
                     'End of procedure');
   END IF;

   RETURN TRUE;

EXCEPTION
   WHEN OTHERS THEN
        IF (G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL ) THEN
           fnd_message.set_name('OFA','FA_SHARED_ORACLE_ERR');
           fnd_message.set_token('ORACLE_ERR',SQLERRM);
           FND_LOG.MESSAGE (G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_procedure_name,TRUE);
        END IF;

        return false;


END execute_dml;

FUNCTION push_database_object
                        (
                         p_object_name          IN VARCHAR2,
                         p_object_type          IN VARCHAR2,
                         p_object_owner         IN VARCHAR2,
                         p_apps_account         IN VARCHAR2,
                         p_ddl_text             IN CLOB
                        )
RETURN BOOLEAN IS

   l_return_value        BOOLEAN;
   l_cur_position        INTEGER;
   l_next_cr_position    INTEGER;
   l_text_length         INTEGER;
   l_additional_sql_stmt VARCHAR2(2000);
   l_ddl_text            DBMS_SQL.VARCHAR2S;
   l_procedure_name      varchar2(80) := 'push_database_object';

   le_table_not_exists   EXCEPTION;
   le_compilation_fails  EXCEPTION;
   PRAGMA EXCEPTION_INIT (le_table_not_exists     ,-00942);
   PRAGMA EXCEPTION_INIT (le_compilation_fails    , -24344);

BEGIN

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(G_LEVEL_PROCEDURE,
                     G_MODULE_NAME||l_procedure_name||'.begin',
                     'Beginning of procedure');
   END IF;

   l_return_value := TRUE;


   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(G_LEVEL_STATEMENT,
                     G_MODULE_NAME||l_procedure_name,
                     'DDL text size: ' || LENGTH(p_ddl_text));
   END IF;

   --If the object to push is a table try to drop in case it exists
   IF p_object_type = 'TABLE' THEN

      --drop the already existing one (if it exists)
      l_additional_sql_stmt :=
         'DROP TABLE ' || p_object_owner || '.' || p_object_name;
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
         fnd_log.string(G_LEVEL_STATEMENT,
                        G_MODULE_NAME||l_procedure_name,
                        l_additional_sql_stmt);
      END IF;

      BEGIN
         EXECUTE IMMEDIATE l_additional_sql_stmt;
      EXCEPTION
         WHEN le_table_not_exists THEN
              NULL;
         WHEN OTHERS THEN
              RAISE;
      END;

   END IF;

   --Move the CLOB into a VARCHAR2S
   fa_cmp_string_pkg.clob_to_varchar2s
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
   IF p_object_type = 'TABLE' THEN

      --create the synonym
      l_additional_sql_stmt :=
         'CREATE OR REPLACE SYNONYM ' ||
          p_apps_account || '.' || p_object_name ||
          ' FOR ' || p_object_owner || '.' || p_object_name;

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
         fnd_log.string(G_LEVEL_STATEMENT,
                        G_MODULE_NAME||l_procedure_name,
                        l_additional_sql_stmt);
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

   ELSIF p_object_type = 'PACKAGE BODY' THEN
      l_additional_sql_stmt :=
         'ALTER PACKAGE ' || p_object_name || ' COMPILE ';

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
         fnd_log.string(G_LEVEL_STATEMENT,
                        G_MODULE_NAME||l_procedure_name,
                        l_additional_sql_stmt);
      END IF;

      EXECUTE IMMEDIATE l_additional_sql_stmt;
   END IF;

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(G_LEVEL_PROCEDURE,
                     G_MODULE_NAME||l_procedure_name||'.end',
                     'End of procedure');
   END IF;

   RETURN l_return_value;

EXCEPTION
   WHEN le_compilation_fails THEN
        IF (G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL ) THEN
           fnd_message.set_name('OFA','FA_SHARED_ORACLE_ERR');
           fnd_message.set_token('ORACLE_ERR',SQLERRM);
           FND_LOG.MESSAGE (G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_procedure_name,TRUE);
        END IF;

        -- BMR: need utility like xla_cmp_common_pkg.dump_text here

        RETURN FALSE;

   WHEN OTHERS THEN
        IF (G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL ) THEN
           fnd_message.set_name('OFA','FA_SHARED_ORACLE_ERR');
           fnd_message.set_token('ORACLE_ERR',SQLERRM);
           FND_LOG.MESSAGE (G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_procedure_name,TRUE);
        END IF;

        RETURN FALSE;

END push_database_object;

--=============================================================================

END fa_xla_cmp_create_pkg; -- end of package body

/
