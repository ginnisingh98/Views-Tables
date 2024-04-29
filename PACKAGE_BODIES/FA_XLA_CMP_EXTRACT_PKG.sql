--------------------------------------------------------
--  DDL for Package Body FA_XLA_CMP_EXTRACT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_XLA_CMP_EXTRACT_PKG" AS
/* $Header: faxlaceb.pls 120.1.12010000.4 2009/10/29 12:45:31 bridgway ship $   */
/*===========================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| PACKAGE NAME                                                               |
|     fa_xla_cmp_extract_pkg                                                 |
|                                                                            |
| DESCRIPTION                                                                |
|     This is a FA private package, which contains all the APIs required     |
|     for XLA extract package generation                                     |
|                                                                            |
|                                                                            |
| HISTORY                                                                    |
|     25-FEB-2006 BRIDGWAY      Created                                      |
|                                                                            |
+===========================================================================*/


--+==========================================================================+
--|                                                                          |
--|                                                                          |
--|                 Extract templates/Global constants                       |
--|                                                                          |
--|                                                                          |
--+==========================================================================+


C_COMMENT  CONSTANT VARCHAR2(2000) :=
'/'||'*======================================================================+
|                Copyright (c) 1997 Oracle Corporation                  |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| Package Name                                                          |
|     $name
|                                                                       |
| DESCRIPTION                                                           |
|     Package generated From FA AAD setups                              |
|                                                                       |
| HISTORY                                                               |
|     $history
+=======================================================================*'||'/'
 ;



--+==========================================================================+
--|            specification  package template                               |
--+==========================================================================+


C_PACKAGE_SPEC  CONSTANT  VARCHAR2(32000) :=

'CREATE OR REPLACE PACKAGE $PACKAGE_NAME$ AS

$header$


PROCEDURE load_data ;


END $PACKAGE_NAME$;

';


C_PACKAGE_BODY_CLOSE CONSTANT VARCHAR2(32000) := '

END $PACKAGE_NAME$;

';


--+==========================================================================+
--|   Template Body package associated to a Product Accounting definition    |
--+==========================================================================+

C_PACKAGE_BODY_1   CONSTANT VARCHAR2(32000) := '

CREATE OR REPLACE PACKAGE BODY $PACKAGE_NAME$ AS

$header$


-- TYPES
-- globals / constants

G_CURRENT_RUNTIME_LEVEL        NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

G_LEVEL_STATEMENT     CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
G_LEVEL_PROCEDURE     CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
G_LEVEL_EVENT         CONSTANT NUMBER := FND_LOG.LEVEL_EVENT;
G_LEVEL_EXCEPTION     CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
G_LEVEL_ERROR         CONSTANT NUMBER := FND_LOG.LEVEL_ERROR;
G_LEVEL_UNEXPECTED    CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;

G_MODULE_NAME         CONSTANT VARCHAR2(50):= ''fa.plsql.fa_xla_extract_$EXTRACT_TYPE$_pkg.'';


--+============================================+
--|                                            |
--|  PRIVATE  PROCEDURES/FUNCTIONS             |
--|                                            |
--+============================================+

';

-- BMR removed these as they will be built in lower level "generate" routines called from below
-- i.e. load_header / lines / ccid gen, etc
--
-- also not removing package body two as this will be dynamic too


--+==========================================================================+
--|                                                                          |
--|                   End of Constants for Dynamic packages                  |
--|                                                                          |
--+==========================================================================+

--+==========================================================================+
--|                                                                          |
--| Private global variable                                                  |
--|                                                                          |
--+==========================================================================+

g_UserName                      VARCHAR2(100);
g_PackageName                   VARCHAR2(60);
g_ProductRuleName               VARCHAR2(80);
g_ProductRuleVersion            VARCHAR2(30);

--+==========================================================================+
--|                                                                          |
--| Private global constant or variable declarations                         |
--|                                                                          |
--+==========================================================================+

g_chr_newline      CONSTANT VARCHAR2(10):= fa_cmp_string_pkg.g_chr_newline;

G_CURRENT_RUNTIME_LEVEL        NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

G_LEVEL_STATEMENT     CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
G_LEVEL_PROCEDURE     CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
G_LEVEL_EVENT         CONSTANT NUMBER := FND_LOG.LEVEL_EVENT;
G_LEVEL_EXCEPTION     CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
G_LEVEL_ERROR         CONSTANT NUMBER := FND_LOG.LEVEL_ERROR;
G_LEVEL_UNEXPECTED    CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;

G_MODULE_NAME         CONSTANT VARCHAR2(50):= 'fa.plsql.fa_xla_cmp_extract_pkg.';

--+==========================================================================+
--|                                                                          |
--| OVERVIEW of private procedures and functions                             |
--|                                                                          |
--+==========================================================================+

--+==========================================================================+
--|                                                                          |
--| PRIVATE procedures and functions                                         |
--|                                                                          |
--+==========================================================================+

/*------------------------------------------------+
|                                                 |
|  Private function                               |
|                                                 |
|  return the user name                           |
|                                                 |
+------------------------------------------------*/

FUNCTION GetUserName
RETURN VARCHAR2 IS

   l_user_name       VARCHAR2(100);
   l_procedure_name  varchar2(80) := 'GetUserName';

BEGIN

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(G_LEVEL_PROCEDURE,
                     G_MODULE_NAME||l_procedure_name||'.begin',
                     'Beginning of procedure');
   END IF;

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(G_LEVEL_STATEMENT,
                     G_MODULE_NAME||l_procedure_name,
                     'SQL - Select from fnd_user');
   END IF;

   SELECT  nvl(fd.user_name, 'ANONYMOUS')
     INTO  l_user_name
     FROM  fnd_user fd
    WHERE  fd.user_id = fnd_global.user_id;

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(G_LEVEL_STATEMENT,
                     G_MODULE_NAME||l_procedure_name,
                     'User name = ' || l_user_name);
   END IF;

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(G_LEVEL_PROCEDURE,
                     G_MODULE_NAME||l_procedure_name||'.end',
                     'End of procedure');
   END IF;

   RETURN l_user_name;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
        l_user_name := 'ANONYMOUS';
        RETURN l_user_name;

   WHEN OTHERS THEN
        IF (G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL ) THEN
           fnd_message.set_name('OFA','FA_SHARED_ORACLE_ERR');
           fnd_message.set_token('ORACLE_ERR',SQLERRM);
           FND_LOG.MESSAGE (G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_procedure_name,TRUE);
        END IF;
        raise;

END GetUserName;

/*--------------------------------------------------------------+
|                                                               |
|  Private function                                             |
|                                                               |
|  Create the comment in the FA Extract packages                |
|                                                               |
+--------------------------------------------------------------*/
FUNCTION InsertString(  p_InputString   IN VARCHAR2
                      , p_token         IN VARCHAR2
                      , p_value         IN VARCHAR2)
RETURN VARCHAR2 IS

  l_OutputString    VARCHAR2(2000);
  l_procedure_name  varchar2(80) := 'InsertString';

BEGIN

   l_OutputString := REPLACE(p_InputString,p_token,p_value);
   l_OutputString := SUBSTR(l_OutputString,1,66);
   l_OutputString := l_Outputstring  || LPAD('|', 67- LENGTH(l_OutputString));
   return l_OutputString ;

END InsertString;

/*--------------------------------------------------------------+
|                                                               |
|  Private function                                             |
|                                                               |
|      GeneratePkgComment                                       |
|                                                               |
|  Create the comment in the FA extract packages                |
|                                                               |
+--------------------------------------------------------------*/

FUNCTION GeneratePkgComment ( p_user_name              IN VARCHAR2
                            , p_package_name           IN VARCHAR2
                            )
RETURN VARCHAR2 IS

   l_header          VARCHAR2(32000);
   l_StringValue     VARCHAR2(2000);
   l_procedure_name  varchar2(80) := 'GeneratePkgComment';

BEGIN

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(G_LEVEL_PROCEDURE,
                     G_MODULE_NAME||l_procedure_name||'.begin',
                     'Beginning of procedure');
   END IF;

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(G_LEVEL_STATEMENT,
                     G_MODULE_NAME||l_procedure_name,
                     'p_user_name = '||p_user_name||
                       ' - p_package_name = '||p_package_name);
   END IF;

   l_header := C_COMMENT;

   l_StringValue   := InsertString( p_InputString => '$pkg_name'
                                   ,p_token       => '$pkg_name'
                                   ,p_value       =>  p_package_name
                                  );

   l_header := REPLACE(l_header,'$name',l_StringValue);

   l_StringValue   := REPLACE('Generated at $date by user $user ' ,'$date',
                              TO_CHAR(sysdate, 'DD-MM-YYYY "at" HH:MM:SS' ));

   l_StringValue   := InsertString(p_InputString => l_StringValue
                                  ,p_token       => '$user'
                                  ,p_value       => p_user_name
                                  );

   l_header := REPLACE(l_header,'$history',l_StringValue );

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(G_LEVEL_PROCEDURE,
                     G_MODULE_NAME||l_procedure_name||'.end',
                     'End of procedure');
   END IF;

   RETURN l_header;

EXCEPTION
   WHEN OTHERS THEN
        IF (G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL ) THEN
           fnd_message.set_name('OFA','FA_SHARED_ORACLE_ERR');
           fnd_message.set_token('ORACLE_ERR',SQLERRM);
           FND_LOG.MESSAGE (G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_procedure_name,TRUE);
        END IF;
        raise;

END GeneratePkgComment;


/*--------------------------------------------------------------+
|                                                               |
|                                                               |
|                                                               |
|       Generation of FA Extract specification packages         |
|                                                               |
|                                                               |
|                                                               |
+--------------------------------------------------------------*/


/*--------------------------------------------------------------+
|                                                               |
|  Private function                                             |
|                                                               |
|     BuildSpecPkg                                              |
|                                                               |
|  Creates the FA Extract package specifications                |
|                                                               |
+--------------------------------------------------------------*/

FUNCTION BuildSpecPkg(   p_user_name              IN VARCHAR2
                       , p_package_name           IN VARCHAR2
                       , p_extract_type           IN VARCHAR2)
RETURN VARCHAR2 IS

   l_SpecPkg         VARCHAR2(32000);
   l_procedure_name  varchar2(80) := 'BuildSpecPkg';

BEGIN

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(G_LEVEL_PROCEDURE,
                     G_MODULE_NAME||l_procedure_name||'.begin',
                     'Beginning of procedure');
   END IF;

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(G_LEVEL_STATEMENT,
                     G_MODULE_NAME||l_procedure_name,
                     'p_user_name = '||p_user_name||
                     ' - p_package_name = '||p_package_name||
                     ' - p_extract_type = '||p_extract_type);
   END IF;

   l_SpecPkg   := C_PACKAGE_SPEC;

   l_SpecPkg   := REPLACE(l_SpecPkg,'$PACKAGE_NAME$',p_package_name);

   l_SpecPkg   := REPLACE(l_SpecPkg,'$header$',GeneratePkgComment (
                                  p_user_name               => p_user_name
                                , p_package_name            => p_package_name
                             ) );

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(G_LEVEL_PROCEDURE,
                     G_MODULE_NAME||l_procedure_name||'.end',
                     'End of procedure' || length(l_SpecPkg));
   END IF;

   RETURN l_SpecPkg ;

EXCEPTION

   WHEN OTHERS THEN
        IF (G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL ) THEN
           fnd_message.set_name('OFA','FA_SHARED_ORACLE_ERR');
           fnd_message.set_token('ORACLE_ERR',SQLERRM);
           FND_LOG.MESSAGE (G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_procedure_name,TRUE);
        END IF;
        raise;

END BuildSpecPkg;

/*--------------------------------------------------------------+
|                                                               |
|  Private function                                             |
|                                                               |
|     GenerateSpecPackage                                       |
|                                                               |
| Generates the FA Extract specifcation packages from AAD       |
| Returns TRUE if the compiler succeeds to generate the spec.   |
| package, FALSE otherwise.                                     |
+--------------------------------------------------------------*/

FUNCTION GenerateSpecPackage(
  p_extract_type                 IN VARCHAR2
, p_package                     OUT NOCOPY VARCHAR2
)
RETURN BOOLEAN IS

   l_procedure_name  varchar2(80) := 'GenerateSpecPackage';

BEGIN

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(G_LEVEL_PROCEDURE,
                     G_MODULE_NAME||l_procedure_name||'.begin',
                     'Beginning of procedure');
   END IF;

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(G_LEVEL_STATEMENT,
                     G_MODULE_NAME||l_procedure_name,
                     ' p_extract_type = '||p_extract_type);
   END IF;

   p_package  := BuildSpecPkg(
                  p_user_name               => g_UserName
                , p_package_name            => g_PackageName
                , p_extract_type            => p_extract_type
                );

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(G_LEVEL_PROCEDURE,
                     G_MODULE_NAME||l_procedure_name||'.end',
                     'End of procedure');
   END IF;

   RETURN (p_package IS NOT NULL);

EXCEPTION

   WHEN OTHERS THEN
        IF (G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL ) THEN
           fnd_message.set_name('OFA','FA_SHARED_ORACLE_ERR');
           fnd_message.set_token('ORACLE_ERR',SQLERRM);
           FND_LOG.MESSAGE (G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_procedure_name,TRUE);
        END IF;
        return false;

END GenerateSpecPackage;

/*------------------------------------------------------------------+
|                                                                   |
|  Private function                                                 |
|                                                                   |
|     CreateSpecPackage                                             |
|                                                                   |
| Creates/compiler the FA package specifications in the DATABASE    |
| It returns TRUE, if the package created is VALID, FALSE otherwise |
|                                                                   |
+------------------------------------------------------------------*/

FUNCTION CreateSpecPackage ( p_extract_type             IN VARCHAR2)

RETURN BOOLEAN IS

   l_Package             VARCHAR2(32000);
   l_IsCompiled          BOOLEAN;
   l_procedure_name       varchar2(80) := 'CreateSpecPackage';

BEGIN

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(G_LEVEL_PROCEDURE,
                     G_MODULE_NAME||l_procedure_name||'.begin',
                     'Beginning of procedure');
   END IF;

   l_IsCompiled  := GenerateSpecPackage(
                      p_extract_type                 => p_extract_type
                    , p_package                      => l_Package
                    );

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(G_LEVEL_STATEMENT,
                     G_MODULE_NAME||l_procedure_name,
                     ' Compile the specification package in the DATABASE'||
                     ' - length of the package = '||length(l_Package));
   END IF;

   l_IsCompiled  := fa_xla_cmp_create_pkg.CreateSpecPackage(
                      p_package_name       =>  g_PackageName
                    , p_package_text       =>  l_Package
                    ) AND l_IsCompiled;

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(G_LEVEL_STATEMENT,
                     G_MODULE_NAME||l_procedure_name,
                     'END of CreateSpecPackage : return = '
                        ||CASE WHEN l_IsCompiled THEN 'TRUE' ELSE 'FALSE' END);
   END IF;


   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(G_LEVEL_PROCEDURE,
                     G_MODULE_NAME||l_procedure_name||'.end',
                     'End of procedure');
   END IF;


   RETURN l_IsCompiled;

EXCEPTION
   WHEN OTHERS    THEN
        IF (G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL ) THEN
           fnd_message.set_name('OFA','FA_SHARED_ORACLE_ERR');
           fnd_message.set_token('ORACLE_ERR',SQLERRM);
           FND_LOG.MESSAGE (G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_procedure_name,TRUE);
        END IF;
        return FALSE;

END CreateSpecPackage;

/*--------------------------------------------------------------+
|                                                               |
|                                                               |
|                                                               |
|           Generation of FA Extract Body packages              |
|                                                               |
|                                                               |
|                                                               |
+--------------------------------------------------------------*/

/*--------------------------------------------------------------+
|                                                               |
|  Private function                                             |
|                                                               |
|     GeneratePrivateProcedures                                 |
|                                                               |
|  Generates private procedures and functions in FA packages    |
|                                                               |
+--------------------------------------------------------------*/

FUNCTION GeneratePrivateProcedures
       (p_package_name                 IN VARCHAR2
       ,p_extract_type                 IN VARCHAR2
       ,p_package_body                 OUT NOCOPY DBMS_SQL.VARCHAR2S)
RETURN BOOLEAN IS

   l_IsCompiled            BOOLEAN;
   l_IsGenerated           BOOLEAN;

   l_array_body            DBMS_SQL.VARCHAR2S;
   l_array_string          DBMS_SQL.VARCHAR2S;
   l_procedure_name        varchar2(80) := 'GeneratePrivateProcedures';

BEGIN

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(G_LEVEL_PROCEDURE,
                     G_MODULE_NAME||l_procedure_name||'.begin',
                     'Beginning of procedure');
   END IF;

   l_IsCompiled         := TRUE;
   l_IsGenerated        := TRUE;

   -- generate description functions and the call to those functions
   l_array_body    := fa_cmp_string_pkg.g_null_varchar2s;
   l_array_string  := fa_cmp_string_pkg.g_null_varchar2s;

   --
   -- Generate Header Section
   --

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(G_LEVEL_STATEMENT,
                     G_MODULE_NAME||l_procedure_name,
                      '-> CALL FA_XLA_CMP_HEADER_PKG.GenerateHeaderExtract API');
   END IF;

   l_IsGenerated     :=
      FA_XLA_CMP_HEADER_PKG.GenerateHeaderExtract
         (p_extract_type              => p_extract_type,
          p_package_body              => l_array_string);

   l_IsCompiled   := l_IsCompiled AND l_IsGenerated ;

   l_array_body   :=
      fa_cmp_string_pkg.ConcatTwoStrings
         (p_array_string_1    => l_array_body
         ,p_array_string_2    => l_array_string);

   l_array_string := fa_cmp_string_pkg.g_null_varchar2s;


   --
   -- generate line sections
   --
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(G_LEVEL_STATEMENT,
                     G_MODULE_NAME||l_procedure_name,
                     '-> CALL FA_XLA_CMP_LINES_PKG.GenerateLinesExtract API');
   END IF;

   l_IsGenerated   :=
     FA_XLA_CMP_LINE_PKG.GenerateLineExtract
         (p_extract_type              => p_extract_type,
          p_package_body              => l_array_string);


   l_array_body   :=
      fa_cmp_string_pkg.ConcatTwoStrings
         (p_array_string_1    => l_array_body
         ,p_array_string_2    => l_array_string);

   l_array_string := fa_cmp_string_pkg.g_null_varchar2s;

   l_IsCompiled   := l_IsCompiled AND l_IsGenerated;



   --
   -- generate mls section
   --
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(G_LEVEL_STATEMENT,
                     G_MODULE_NAME||l_procedure_name,
                     '-> CALL FA_XLA_CMP_LINES_PKG.GenerateMlsExtract API');
   END IF;

   l_IsGenerated   :=
     FA_XLA_CMP_MLS_PKG.GenerateMlsExtract
         (p_extract_type              => p_extract_type,
          p_package_body              => l_array_string);


   l_array_body   :=
      fa_cmp_string_pkg.ConcatTwoStrings
         (p_array_string_1    => l_array_body
         ,p_array_string_2    => l_array_string);

   l_array_string := fa_cmp_string_pkg.g_null_varchar2s;

   l_IsCompiled   := l_IsCompiled AND l_IsGenerated;



   --
   -- generate ccid sections - for legacy workflow support
   --

   l_IsGenerated :=
     FA_XLA_CMP_CCID_PKG.GenerateCCIDExtract
         (p_extract_type              => p_extract_type,
          p_package_body              => l_array_string);


   l_array_body   :=
      fa_cmp_string_pkg.ConcatTwoStrings
         (p_array_string_1    => l_array_body
         ,p_array_string_2    => l_array_string);

   l_array_string := fa_cmp_string_pkg.g_null_varchar2s;

   l_IsCompiled   := l_IsCompiled AND l_IsGenerated ;

   --
   -- generate locking sections
   --

   l_IsGenerated :=
     FA_XLA_CMP_LOCK_PKG.GenerateLockingExtract
      (p_extract_type                 => p_extract_type,
       p_package_body                 => l_array_string);

   l_array_body   :=
      fa_cmp_string_pkg.ConcatTwoStrings
         (p_array_string_1    => l_array_body
         ,p_array_string_2    => l_array_string);

   l_array_string := fa_cmp_string_pkg.g_null_varchar2s;

   l_IsCompiled   := l_IsCompiled AND l_IsGenerated ;


   --
   -- generate main procedure
   --

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(G_LEVEL_STATEMENT,
                     G_MODULE_NAME||l_procedure_name,
                    '-> CALL FA_XLA_CMP_LOAD_PKG.GenerateLoadExtract API');
   END IF;

   l_IsGenerated     :=
      FA_XLA_CMP_LOAD_PKG.GenerateLoadExtract
         (p_extract_type              => p_extract_type,
          p_package_body              => l_array_string);

   l_IsCompiled   := l_IsCompiled AND l_IsGenerated ;

   l_array_body   :=
      fa_cmp_string_pkg.ConcatTwoStrings
         (p_array_string_1    => l_array_body
         ,p_array_string_2    => l_array_string);


   l_array_string := fa_cmp_string_pkg.g_null_varchar2s;

   p_package_body := l_array_body;


   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(G_LEVEL_STATEMENT,
                     G_MODULE_NAME||l_procedure_name,
                     'l_isCompiled = '||CASE WHEN l_IsCompiled
                                                THEN 'TRUE'
                                                ELSE 'FALSE' END);
   END IF;

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(G_LEVEL_PROCEDURE,
                     G_MODULE_NAME||l_procedure_name||'.end',
                     'End of procedure');
   END IF;

   RETURN l_IsCompiled;

EXCEPTION
   WHEN OTHERS    THEN
        IF (G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL ) THEN
           fnd_message.set_name('OFA','FA_SHARED_ORACLE_ERR');
           fnd_message.set_token('ORACLE_ERR',SQLERRM);
           FND_LOG.MESSAGE (G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_procedure_name,TRUE);
        END IF;
        return false;

END GeneratePrivateProcedures;

/*--------------------------------------------------------------+
|                                                               |
|  Private function                                             |
|                                                               |
|     GenerateBody                                              |
|                                                               |
|  Generates the procedures and functions in FA body packages   |
|                                                               |
+--------------------------------------------------------------*/

FUNCTION GenerateBody
       (p_package_name                 IN VARCHAR2
       ,p_extract_type                 IN VARCHAR2
       ,p_package_body                OUT NOCOPY DBMS_SQL.VARCHAR2S)
RETURN BOOLEAN IS

   l_IsCompiled                        BOOLEAN;
   l_procedure_name  varchar2(80) := 'GenerateBody';

BEGIN

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(G_LEVEL_PROCEDURE,
                     G_MODULE_NAME||l_procedure_name||'.begin',
                     'Beginning of procedure');
   END IF;

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(G_LEVEL_STATEMENT,
                     G_MODULE_NAME||l_procedure_name,
                     'p_package_name = '||p_package_name||
                     ' - p_extract_type = '||p_extract_type);
   END IF;

   l_IsCompiled     :=
      GeneratePrivateProcedures
      (p_package_name                => p_package_name
      ,p_extract_type                => p_extract_type
      ,p_package_body                => p_package_body);


   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(G_LEVEL_STATEMENT,
                     G_MODULE_NAME||l_procedure_name,
                     'l_isCompiled = '||CASE WHEN l_IsCompiled
                                                THEN 'TRUE'
                                                ELSE 'FALSE' END);
   END IF;

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(G_LEVEL_PROCEDURE,
                     G_MODULE_NAME||l_procedure_name||'.end',
                     'End of procedure');
   END IF;

   RETURN l_IsCompiled;

EXCEPTION
   WHEN OTHERS THEN
        IF (G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL ) THEN
           fnd_message.set_name('OFA','FA_SHARED_ORACLE_ERR');
           fnd_message.set_token('ORACLE_ERR',SQLERRM);
           FND_LOG.MESSAGE (G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_procedure_name,TRUE);
        END IF;
        return false;

END GenerateBody;

/*--------------------------------------------------------------+
|                                                               |
|  Private function                                             |
|                                                               |
|     GenerateBodyPackage                                       |
|                                                               |
| Generates the FA body packages from AAD definitions           |
| Returns TRUE if the compiler succeeds to generate the body    |
| package, FALSE otherwise.                                     |
+--------------------------------------------------------------*/

FUNCTION GenerateBodyPackage
       (p_extract_type                 IN VARCHAR2
       ,p_package_body                 OUT NOCOPY DBMS_SQL.VARCHAR2S)
RETURN BOOLEAN IS

   l_array_pkg              DBMS_SQL.VARCHAR2S;
   l_BodyPkg                VARCHAR2(32000);
   l_array_body             DBMS_SQL.VARCHAR2S;
   l_IsCompiled             BOOLEAN;
   l_procedure_name  varchar2(80) := 'GenerateBodyPackage';

BEGIN

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(G_LEVEL_PROCEDURE,
                     G_MODULE_NAME||l_procedure_name||'.begin',
                     'Beginning of procedure');
   END IF;

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(G_LEVEL_STATEMENT,
                     G_MODULE_NAME||l_procedure_name,
                     'p_extract_type = '||p_extract_type);
   END IF;

   l_IsCompiled    := TRUE;
   l_array_body    := fa_cmp_string_pkg.g_null_varchar2s;
   l_array_pkg     := fa_cmp_string_pkg.g_null_varchar2s;

   l_BodyPkg   := C_PACKAGE_BODY_1;
   l_BodyPkg   := REPLACE(l_BodyPkg,'$PACKAGE_NAME$'   ,g_PackageName);
   l_BodyPkg   := REPLACE(l_BodyPkg,'$EXTRACT_TYPE$'   ,lower(p_extract_type));

   l_BodyPkg   :=
      REPLACE(l_BodyPkg,'$header$'
          ,GeneratePkgComment
             (p_user_name               => g_UserName
             ,p_package_name            => g_PackageName
          ));

   l_BodyPkg     := REPLACE(l_BodyPkg,'$PACKAGE_NAME$'          ,g_PackageName);

   fa_cmp_string_pkg.CreateString
      (p_package_text  => l_BodyPkg
      ,p_array_string  => l_array_pkg);

   l_IsCompiled :=
      GenerateBody
      (p_package_name             => g_PackageName
      ,p_extract_type             => p_extract_type
      ,p_package_body             => l_array_body);


   l_array_pkg :=
      fa_cmp_string_pkg.ConcatTwoStrings
         (p_array_string_1  =>  l_array_pkg
         ,p_array_string_2  =>  l_array_body);

   fa_cmp_string_pkg.CreateString
     (p_package_text  => l_BodyPkg
     ,p_array_string  => l_array_body);

   l_BodyPkg := C_PACKAGE_BODY_CLOSE ;
   l_BodyPkg   := REPLACE(l_BodyPkg,'$PACKAGE_NAME$'   ,g_PackageName);

   fa_cmp_string_pkg.CreateString
     (p_package_text  => l_BodyPkg
     ,p_array_string  => l_array_body);

   l_array_pkg :=
      fa_cmp_string_pkg.ConcatTwoStrings
         (p_array_string_1  =>  l_array_pkg
         ,p_array_string_2  =>  l_array_body);

   p_package_body      := l_array_pkg;

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(G_LEVEL_STATEMENT,
                     G_MODULE_NAME||l_procedure_name,
                     'return value (l_IsCompiled) = '||
                     CASE l_IsCompiled WHEN TRUE THEN 'TRUE' ELSE 'FALSE' END);
   END IF;

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(G_LEVEL_PROCEDURE,
                     G_MODULE_NAME||l_procedure_name||'.end',
                     'End of procedure');
   END IF;

   RETURN l_IsCompiled;

EXCEPTION
   WHEN OTHERS    THEN
        IF (G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL ) THEN
           fnd_message.set_name('OFA','FA_SHARED_ORACLE_ERR');
           fnd_message.set_token('ORACLE_ERR',SQLERRM);
           FND_LOG.MESSAGE (G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_procedure_name,TRUE);
        END IF;
        RETURN FALSE;

END GenerateBodyPackage;

/*--------------------------------------------------------------+
|                                                               |
|  Private function                                             |
|                                                               |
|        CreateBodyPackage                                      |
|                                                               |
| Compiles the FA body packages in the DATABASE                 |
| Returns TRUE if the package body is VALID, FALSE otherwise.   |
|                                                               |
+--------------------------------------------------------------*/
FUNCTION CreateBodyPackage
       (p_extract_type             IN VARCHAR2)
RETURN BOOLEAN IS

   l_Package             DBMS_SQL.VARCHAR2S;
   l_PackageName         VARCHAR2(30);
   l_ProductRuleName     VARCHAR2(80);
   l_ProductRuleVersion  VARCHAR2(30);

   l_IsCompiled          BOOLEAN;
   l_procedure_name      varchar2(80) := 'CreateBodyPackage';

BEGIN

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(G_LEVEL_PROCEDURE,
                     G_MODULE_NAME||l_procedure_name||'.begin',
                     'Beginning of procedure');
   END IF;



   l_IsCompiled  :=
      GenerateBodyPackage
         (p_extract_type                 => p_extract_type
         ,p_package_body                 => l_Package);

   l_IsCompiled  :=
      fa_xla_cmp_create_pkg.CreateBodyPackage
         (p_package_name       =>  g_PackageName
         ,p_package_text       =>  l_Package) AND l_IsCompiled;

  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(G_LEVEL_STATEMENT,
                     G_MODULE_NAME||l_procedure_name,
                     'return value (l_IsCompiled) = '||
                     CASE l_IsCompiled WHEN TRUE THEN 'TRUE' ELSE 'FALSE' END);
   END IF;

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(G_LEVEL_PROCEDURE,
                     G_MODULE_NAME||l_procedure_name||'.end',
                     'End of procedure');
   END IF;

   RETURN l_IsCompiled;

EXCEPTION
   WHEN OTHERS    THEN
        IF (G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL ) THEN
           fnd_message.set_name('OFA','FA_SHARED_ORACLE_ERR');
           fnd_message.set_token('ORACLE_ERR',SQLERRM);
           FND_LOG.MESSAGE (G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_procedure_name,TRUE);
        END IF;

        return false;

END CreateBodyPackage;


--+==========================================================================+
--| PUBLIC function                                                          |
--|    Compile                                                               |
--|                                                                          |
--| DESCRIPTION : generates the PL/SQL packages from the Product Accounting  |
--|               definition.                                                |
--|                                                                          |
--|                                                                          |
--|  RETURNS                                                                 |
--|   1. l_IsCompiled  : BOOLEAN, TRUE if Product accounting definition has  |
--|                      been successfully created, FALSE otherwise.         |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--+==========================================================================+

FUNCTION Compile RETURN BOOLEAN IS

   l_IsCompiled          BOOLEAN := TRUE;
   l_log_module          VARCHAR2(240);
   l_procedure_name      varchar2(80) := 'Compile';

   l_extract_type        varchar2(15);

BEGIN

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(G_LEVEL_PROCEDURE,
                     G_MODULE_NAME||l_procedure_name||'.begin',
                     'Beginning of procedure');
   END IF;

   g_UserName           := GetUserName;


   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(G_LEVEL_STATEMENT,
                     G_MODULE_NAME||l_procedure_name,
                     'entering loop');
   END IF;

   -- Loop three times to process each package: deprn/trx/deferred

   for i in 1..3 loop

      -- no need for this anymore as we are not segregating by AAD
      -- g_PackageName        :=
      --    fa_xla_cmp_hash_pkg.BuildPackageName
      --      (p_extract_type            => l_extract_type);


      if (i=1) then
         l_extract_type := 'DEPRN';
         g_PackageName  := 'FA_XLA_EXTRACT_DEPRN_PKG';
      elsif (i=2) then
         l_extract_type := 'TRX';
         g_PackageName  := 'FA_XLA_EXTRACT_TRX_PKG';
      else
         l_extract_type := 'DEF';
         g_PackageName  := 'FA_XLA_EXTRACT_DEF_PKG';
      end if;

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
         fnd_log.string(G_LEVEL_STATEMENT,
                        G_MODULE_NAME||l_procedure_name,
                        'l_extract_type = '||l_extract_type ||
                        ' - g_PackageName = '||g_PackageName);
      END IF;

      l_IsCompiled  := l_IsCompiled and
            CreateSpecPackage
               (p_extract_type            => l_extract_type);

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
         fnd_log.string(G_LEVEL_STATEMENT,
                        G_MODULE_NAME||l_procedure_name,
                        ' FA specification package created  = '||
                        CASE l_IsCompiled WHEN TRUE THEN 'TRUE' ELSE 'FALSE' END);
      END IF;

      l_IsCompiled  :=
         l_IsCompiled AND
            CreateBodyPackage
               (p_extract_type            => l_extract_type);

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
         fnd_log.string(G_LEVEL_STATEMENT,
                        G_MODULE_NAME||l_procedure_name,
                        ' AAD body  package created  = '||
                        CASE l_IsCompiled WHEN TRUE THEN 'TRUE' ELSE 'FALSE' END);
      END IF;

      --  BMR - need something here?   was calling xla_amb_setup_err_pkg.stack_error


   END LOOP;

   COMMIT;

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(G_LEVEL_STATEMENT,
                     G_MODULE_NAME||l_procedure_name,
                     'return value. = '||
                     CASE l_IsCompiled WHEN TRUE THEN 'TRUE' ELSE 'FALSE' END);
   END IF;

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(G_LEVEL_PROCEDURE,
                     G_MODULE_NAME||l_procedure_name||'.end',
                     'End of procedure');
   END IF;

   RETURN l_IsCompiled;

EXCEPTION
   WHEN OTHERS    THEN
        IF (G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL ) THEN
           fnd_message.set_name('OFA','FA_SHARED_ORACLE_ERR');
           fnd_message.set_token('ORACLE_ERR',SQLERRM);
           FND_LOG.MESSAGE (G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_procedure_name,TRUE);
        END IF;
        RETURN FALSE;

END Compile;

--=============================================================================

END fa_xla_cmp_extract_pkg; -- end of package spec

/
