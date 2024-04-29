--------------------------------------------------------
--  DDL for Package Body XLA_CMP_HASH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_CMP_HASH_PKG" AS
/* $Header: xlacphsh.pkb 120.19.12010000.4 2010/07/05 13:47:31 karamakr ship $   */
/*===========================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| PACKAGE NAME                                                               |
|     xla_cmp_hash_pkg                                                       |
|                                                                            |
| DESCRIPTION                                                                |
|                                                                            |
|                                                                            |
| HISTORY                                                                    |
|     25-JUL-2002 K.Boussema    Created                                      |
|     11-FEB-2003 K.Boussema    Added Drop package API                       |
|     18-FEB-2003 K.Boussema    Added Hash product rule code API             |
|     18-MAR-2003 K.Boussema    Added amb_context_code column                |
|     22-APR-2003 K.Boussema    Included error messages                      |
|     22-JUN-2003 K.Boussema    Updated error messages                       |
|     17-JUL-2003 K.Boussema    Reviewd the code                             |
|     23-FEB-2004 K.Boussema    Made changes for the FND_LOG.                |
|     17-MAR-2004 K.Boussema    Reviewed GetPADHashId to handle multiple AADs|
|                               with the same name (same product_rule_code)  |
|     22-MAR-2004 K.Boussema    Added a parameter p_module to the TRACE calls|
|                               and the procedure.                           |
|     11-MAY-2004 K.Boussema  Removed the call to XLA trace routine from     |
|                             trace() procedure                              |
|     24-JUN-2005 K.Boussema  Redefined the GetPADHashId function as an      |
|                             autonomous transaction                         |
|     26-JUN-2005 W.Chan      Add application_id and product_rule_type_code  |
|                             when looking up the hash id for the aad.       |
|     12-AUG-2005 W.Chan      bug 4549711 - Redefined the GetPADHashId       |
|                             function as an non-autonomous transaction      |
|     31-AUG-2005 W.Chan      bug 4585458 - Fix GetPADHashId to not to       |
|                             update the xla_product_rules_b with            |
|                             product_rule_hash_id if one is not found       |
+===========================================================================*/
--
--
--
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
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.xla_cmp_hash_pkg';

g_log_level           NUMBER;
g_log_enabled         BOOLEAN;
g_product_rule_hash_id NUMBER;
g_application_id       NUMBER;
g_product_rule_code   VARCHAR2(30);
g_product_rule_type_code VARCHAR2(30);
g_amb_context_code     VARCHAR2(30);

PROCEDURE trace
           (p_msg                        IN VARCHAR2
           ,p_level                      IN NUMBER
           ,p_module                     IN VARCHAR2 DEFAULT C_DEFAULT_MODULE) IS
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
             (p_location   => 'xla_cmp_hash_pkg.trace');
END trace;
--+==========================================================================+
--|                                                                          |
--| OVERVIEW of private procedures and functions                             |
--|                                                                          |
--+==========================================================================+
--

--
/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| GetPADHashId                                                          |
|                                                                       |
| Determines the product hash id associated to the current product rule |
| code, returns a number                                                |
|                                                                       |
| Parameters:                                                           |
|         1  IN  p_product_rule_code       VARCHAR2 product rule        |
|         2  IN  p_amb_context_code        VARCHAR2 AMB context         |
+======================================================================*/
--
FUNCTION GetPADHashId      (p_product_rule_code         IN  VARCHAR2
                           ,p_amb_context_code          IN  VARCHAR2
                           ,p_application_id            IN  INTEGER
                           ,p_product_rule_type_code    IN  VARCHAR2)
RETURN NUMBER
IS
l_HashID             NUMBER;
l_log_module         VARCHAR2(240);
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GetPADHashId';
END IF;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of GetPADHashId'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;

IF (C_LEVEL_STATEMENT >= g_log_level) THEN

      trace
         (p_msg      => 'p_product_rule_code = '||p_product_rule_code ||
                        ' - p_amb_context_code = '|| p_amb_context_code
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

      trace
         (p_msg      => 'SQL - select from xla_product_rules_b'
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

END IF;

BEGIN

SELECT  DISTINCT product_rule_hash_id
  INTO  l_HashID
  FROM  xla_product_rules_b
 WHERE  product_rule_code           = p_product_rule_code
   AND  amb_context_code            = p_amb_context_code
   AND  application_id              = p_application_id
   AND  product_rule_type_code      = p_product_rule_type_code
   AND  product_rule_hash_id        IS NOT NULL
;

EXCEPTION

  WHEN NO_DATA_FOUND THEN

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
           trace
               (p_msg      => 'SQL - update xla_product_rules_b'
               ,p_level    => C_LEVEL_STATEMENT
               ,p_module   => l_log_module);

   END IF;

   -- Fix bug 4585458
   -- When this is called by xla_cmp_hash_pkg.BuildPADName in the
   -- xla_accounting_cashe_pkg.load_application_ledgers, it error with ORA-14551
/*
   UPDATE xla_product_rules_b  xprb
     SET xprb.product_rule_hash_id      = (SELECT NVL(MAX(xpr.product_rule_hash_id),0) + 1
                                             FROM xla_product_rules_b xpr)
   WHERE xprb.amb_context_code          = p_amb_context_code
     AND xprb.product_rule_code         = p_product_rule_code
     AND xprb.application_id            = p_application_id
     AND xprb.product_rule_type_code    = p_product_rule_type_code
     RETURNING xprb.product_rule_hash_id INTO l_HashID
   ;
*/

    /*
    SELECT NVL(MAX(product_rule_hash_id),0) + 1
     INTO l_HashID
     FROM xla_product_rules_b;
     */

   -- Fix bug 9325005
   -- When 2 AADs are being Validated from 2 different machines at same time, the NVL((MAX)+1)
   -- fetches same value for the 2 new AADs.
   --  Thereby, the 2 new AADs will have same product rule hash id and only 1 package would
   -- get created for both of these AADs.
   --
   -- Hence creating a new sequence for the same.
   IF g_product_rule_hash_id is NULL
   OR nvl(g_product_rule_code,' ') <> p_product_rule_code
   OR nvl(g_product_rule_type_code,' ') <>  p_product_rule_type_code
   OR nvl(g_amb_context_code,' ') <>  p_amb_context_code
   OR nvl(g_application_id,-1) <>  p_application_id
   THEN
     SELECT xla_prod_rule_hash_s.nextval
     INTO l_HashID
     FROM dual;
     g_product_rule_hash_id := l_HashID;
     g_product_rule_code := p_product_rule_code;
     g_product_rule_type_code := p_product_rule_type_code;
     g_amb_context_code := p_amb_context_code;
     g_application_id := p_application_id;
   ELSE
     l_HashID := g_product_rule_hash_id;
   END IF;


  WHEN TOO_MANY_ROWS THEN

     IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
          trace
            (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR: TWO OR MORE HASH_ID FOR THE SAME AAD code'
            ,p_level    => C_LEVEL_EXCEPTION
            ,p_module   => l_log_module);
     END IF;

     l_HashID:= NULL;

END ;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'return value. = '||l_HashID
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
         (p_msg      => 'END of GetPADHashId'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

RETURN l_HashID;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
          trace
            (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR: FAILED TO CREATE THE AAD HASH_ID VALUE'
            ,p_level    => C_LEVEL_EXCEPTION
            ,p_module   => l_log_module);
   END IF;
   RAISE;
WHEN OTHERS                                  THEN
   xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_hash_pkg.GetPADHashId');
END GetPADHashId;
--

--
/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| GetPackageName                                                        |
|                                                                       |
| Get package name                                                      |
|                                                                       |
| Parameters                                                            |
|         1  IN  p_application_id          NUMBER   application id      |
|         2  IN  p_product_rule_type_code  VARCHAR2 product rule type   |
|         3  IN  p_product_rule_hash_id    NUMBER   product rule hash id|
+======================================================================*/
FUNCTION  GetPackageName   (  p_application_id            IN  NUMBER
                             ,p_product_rule_type_code    IN  VARCHAR2
                             ,p_product_rule_hash_id      IN  NUMBER )
RETURN VARCHAR2
IS
--
l_name               VARCHAR2(30);
l_hashApplication    VARCHAR2(30);
l_HashRuleCode       VARCHAR2(30);
l_log_module         VARCHAR2(240);
--
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GetPackageName';
END IF;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of GetPackageName'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;

IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'p_application_id = '||p_application_id ||
                        ' - p_product_rule_type_code = '||p_product_rule_type_code ||
                        ' - p_product_rule_hash_id = '||p_product_rule_hash_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;

l_hashApplication := LPAD(SUBSTR(TO_CHAR(ABS(p_application_id)), 1, 5), 5, '0');
l_HashRuleCode    := LPAD(SUBSTR(TO_CHAR(p_product_rule_hash_id), 1, 6), 6, '0');

l_name := C_PACKAGE_NAME;
l_name := REPLACE(l_name,'$id1$',l_hashApplication);
l_name := REPLACE(l_name,'$id2$',p_product_rule_type_code);
l_name := REPLACE(l_name,'$id3$',l_HashRuleCode);

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'return value. package_name = '||l_name
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'END of GetPackageName'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
RETURN l_name;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                  THEN
  xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_hash_pkg.GetPackageName');
END GetPackageName;
--
--
/*======================================================================+
|                                                                       |
| Private function                                                      |
|                                                                       |
| Parameters                                                            |
|         1  IN  p_application_id          NUMBER   application id      |
|         2  IN  p_product_rule_code       VARCHAR2 product rule        |
|         3  IN  p_product_rule_type_code  VARCHAR2 product rule type   |
|         4  IN  p_amb_context_code        VARCHAR2 AMB context         |
|         5 OUT  p_product_rule_hash_id    NUMBER   product rule hash id|
+======================================================================*/
FUNCTION SearchPAD    ( p_application_id            IN  NUMBER
                       ,p_product_rule_code         IN  VARCHAR2
                       ,p_product_rule_type_code    IN  VARCHAR2
                       ,p_amb_context_code          IN  VARCHAR2
                       ,p_product_rule_hash_id      OUT NOCOPY NUMBER)
RETURN BOOLEAN
IS
l_log_module         VARCHAR2(240);
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.SearchPAD';
END IF;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of SearchPAD'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

SELECT  product_rule_hash_id
INTO    p_product_rule_hash_id
FROM    xla_product_rules_b
WHERE   product_rule_code           = p_product_rule_code
  AND   product_rule_type_code      = p_product_rule_type_code
  AND   application_id              = p_application_id
  AND   amb_context_code            = p_amb_context_code
;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      IF (p_product_rule_hash_id IS NOT NULL) THEN
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
         (p_msg      => 'END of SearchPAD'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
RETURN (p_product_rule_hash_id IS NOT NULL);
EXCEPTION
WHEN NO_DATA_FOUND THEN
   RETURN FALSE;
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                  THEN
   xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_hash_pkg.SearchPAD');
END SearchPAD;
--
/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| DropPadPkg                                                            |
|                                                                       |
| Drop PAD package for the current application,product rule code,       |
|          , product rule type code                                     |
|                                                                       |
| Parameters:                                                           |
|         1  IN  p_application_id          NUMBER   application id      |
|         2  IN  p_product_rule_code       VARCHAR2 product rule        |
|         3  IN  p_product_rule_type_code  VARCHAR2 product rule type   |
|         4  IN  p_amb_context_code        VARCHAR2 AMB context         |
+======================================================================*/
PROCEDURE DropPadPkg        ( p_application_id            IN  NUMBER
                             ,p_product_rule_code         IN  VARCHAR2
                             ,p_product_rule_type_code    IN  VARCHAR2
                             ,p_amb_context_code          IN  VARCHAR2
                             )
IS

l_statement       VARCHAR2(200);
l_package_name    VARCHAR2(30) ;
l_PADId           NUMBER;
--
package_does_not_exist                     EXCEPTION;
package_locked                             EXCEPTION;

PRAGMA EXCEPTION_INIT(package_locked        ,-04021);
PRAGMA EXCEPTION_INIT(package_does_not_exist,-04043);
--
l_log_module         VARCHAR2(240);
--
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.DropPadPkg';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of DropPadPkg'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
         (p_msg      => 'p_application_id = '||p_application_id ||
                        ' - p_product_rule_code = '||p_product_rule_code ||
                        ' - p_product_rule_type_code = '||p_product_rule_type_code ||
                        ' - p_amb_context_code = '||p_amb_context_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

IF SearchPAD      ( p_application_id             => p_application_id
                    ,p_product_rule_code         => p_product_rule_code
                    ,p_product_rule_type_code    => p_product_rule_type_code
                    ,p_amb_context_code          => p_amb_context_code
                    ,p_product_rule_hash_id      => l_PADId)
THEN
--
-- package exists in the Data Base
--
      l_package_name := GetPackageName (
                           p_application_id            => p_application_id
                          ,p_product_rule_type_code    => p_product_rule_type_code
                          ,p_product_rule_hash_id      => l_PADId
                          );

      --
      -- drop specification package
      --
      l_statement := 'DROP PACKAGE '||l_package_name ;

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN

            trace
               (p_msg      => '>> EXECUTE dynamic SQL = '||l_statement
               ,p_level    => C_LEVEL_STATEMENT
               ,p_module   => l_log_module);

      END IF;

          EXECUTE IMMEDIATE l_statement;

      --
      -- drop body package
      --
      l_statement := 'DROP PACKAGE BODY '||l_package_name ;

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN

            trace
               (p_msg      => '>> EXECUTE dynamic SQL = '||l_statement
               ,p_level    => C_LEVEL_STATEMENT
               ,p_module   => l_log_module);

      END IF;

      EXECUTE IMMEDIATE l_statement;
      --
 END IF;
      --
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

            trace
               (p_msg      => 'END of DropPadPkg'
               ,p_level    => C_LEVEL_PROCEDURE
               ,p_module   => l_log_module);

END IF;
--
EXCEPTION
WHEN package_does_not_exist THEN

       IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
          trace
            (p_msg      => 'WARNNING: Package '|| l_package_name ||' does not exist '
            ,p_level    => C_LEVEL_EXCEPTION
            ,p_module   => l_log_module);
       END IF;

       IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

         trace
             (p_msg      => 'END of DropPadPkg'
             ,p_level    => C_LEVEL_PROCEDURE
             ,p_module   => l_log_module);

       END IF;

WHEN package_locked         THEN

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
                                       , l_package_name
                               );
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                  THEN
   xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_hash_pkg.DropPadPkg');
END DropPadPkg;
--
--
/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| DropPadPkg                                                            |
|                                                                       |
| Drop PAD package for the current application,product rule code,       |
|          , product rule type code                                     |
|                                                                       |
| Parameters:                                                           |
|         1  IN  p_application_id          NUMBER   application id      |
|         2  IN  p_product_rule_code       VARCHAR2 product rule        |
|         3  IN  p_product_rule_type_code  VARCHAR2 product rule type   |
|         4  IN  p_amb_context_code        VARCHAR2 AMB context         |
|                                                                       |
+======================================================================*/
FUNCTION DropPadPkg         ( p_application_id            IN  NUMBER
                             ,p_product_rule_code         IN  VARCHAR2
                             ,p_product_rule_type_code    IN  VARCHAR2
                             ,p_amb_context_code          IN  VARCHAR2
                             )
RETURN BOOLEAN
IS
l_log_module         VARCHAR2(240);
BEGIN
--
DropPadPkg (p_application_id           => p_application_id
           ,p_product_rule_code        => p_product_rule_code
           ,p_product_rule_type_code   => p_product_rule_type_code
           ,p_amb_context_code         => p_amb_context_code
           )
;
RETURN TRUE;
--
EXCEPTION
WHEN OTHERS   THEN
  RETURN FALSE;
END;
--
/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| BuildPackageName                                                      |
|                                                                       |
| Build a package name                                                  |
|                                                                       |
| Parameters                                                            |
|         1  IN  p_application_id          NUMBER   application id      |
|         2  IN  p_product_rule_code       VARCHAR2 product rule        |
|         3  IN  p_product_rule_type_code  VARCHAR2 product rule type   |
|         4  IN  p_amb_context_code        VARCHAR2 AMB context         |
+======================================================================*/
FUNCTION  BuildPackageName   (p_application_id            IN  NUMBER
                             ,p_product_rule_code         IN  VARCHAR2
                             ,p_product_rule_type_code    IN  VARCHAR2
                             ,p_amb_context_code          IN  VARCHAR2
                             )
RETURN VARCHAR2
IS
--
l_PADId              NUMBER      :=NULL;
l_name               VARCHAR2(30):=NULL;
l_hashApplication    VARCHAR2(30);
--
l_pad_name           VARCHAR2(80);
l_log_module         VARCHAR2(240);
BEGIN

IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.BuildPackageName';
END IF;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of BuildPackageName'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
         (p_msg      => 'p_application_id = '||p_application_id ||
                        ' - p_product_rule_code = '||p_product_rule_code ||
                        ' - p_product_rule_type_code = '||p_product_rule_type_code ||
                        ' - p_amb_context_code = '||p_amb_context_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

IF SearchPAD   ( p_application_id            => p_application_id
                ,p_product_rule_code         => p_product_rule_code
                ,p_product_rule_type_code    => p_product_rule_type_code
                ,p_amb_context_code          => p_amb_context_code
                ,p_product_rule_hash_id      => l_PADId)
THEN
    l_name  := GetPackageName (
                     p_application_id            => p_application_id
                    ,p_product_rule_type_code    => p_product_rule_type_code
                    ,p_product_rule_hash_id      => l_PADId
                   );
ELSE

   l_PADId:= GetPADHashId (p_product_rule_code         => p_product_rule_code
                          ,p_amb_context_code          => p_amb_context_code
                          ,p_application_id            => p_application_id
                          ,p_product_rule_type_code    => p_product_rule_type_code) ;


   IF  l_PADId IS NOT NULL THEN

       l_name        := GetPackageName (
                        p_application_id            => p_application_id
                       ,p_product_rule_type_code    => p_product_rule_type_code
                       ,p_product_rule_hash_id      => l_PADId
                       );
   ELSE
      -- raise an error
      BEGIN

      SELECT xprt.name
        INTO l_pad_name
        FROM xla_product_rules_tl xprt
       WHERE xprt.application_id         = p_application_id
         AND xprt.product_rule_code      = p_product_rule_code
         AND xprt.product_rule_type_code = p_product_rule_type_code
         AND xprt.amb_context_code       = p_amb_context_code
         AND nvl(xprt.language ,USERENV('LANG'))  = USERENV('LANG')
         ;

      EXCEPTION

      WHEN OTHERS THEN
        l_pad_name  := p_product_rule_code;
      END;

      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
          trace
            (p_msg      => 'ERROR: XLA_CMP_NO_PAD_PACKAGE'
            ,p_level    => C_LEVEL_EXCEPTION
            ,p_module   => l_log_module);
      END IF;

      xla_exceptions_pkg.raise_message
                                ('XLA'
                                ,'XLA_CMP_NO_PAD_PACKAGE'
                                ,'PAD_NAME'
                                , l_pad_name
                                ,'OWNER'
                                , xla_lookups_pkg.get_meaning(
                                              p_lookup_type    => 'XLA_OWNER_TYPE'
                                            , p_lookup_code    => p_product_rule_type_code
                                              )
                               );

    END IF;
END IF;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
     trace
         (p_msg      => 'END of BuildPackageName'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
RETURN l_name;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                  THEN
  xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_hash_pkg.BuildPackageName');
END BuildPackageName;
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

END xla_cmp_hash_pkg; --

/
