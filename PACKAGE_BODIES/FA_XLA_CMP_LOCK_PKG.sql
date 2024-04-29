--------------------------------------------------------
--  DDL for Package Body FA_XLA_CMP_LOCK_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_XLA_CMP_LOCK_PKG" AS
/* $Header: faxlackb.pls 120.1.12010000.2 2009/07/19 08:34:42 glchen ship $   */
/*===========================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| PACKAGE NAME                                                               |
|     fa_xla_cmp_lock_pkg                                                    |
|                                                                            |
| DESCRIPTION                                                                |
|     This is a FA private package, which contains all the APIs required     |
|     for to create locing for each extract type                             |
|                                                                            |
|                                                                            |
| HISTORY                                                                    |
|     25-FEB-2006 BRIDGWAY      Created                                      |
|                                                                            |
+===========================================================================*/


--+============================================+
--|                                            |
--|  PRIVATE  PROCEDURES/FUNCTIONS             |
--|                                            |
--+============================================+


C_PRIVATE_API_1   CONSTANT VARCHAR2(32000) := '

/*======================================================================+
|                                                                       |
| Private Function                                                      |
|    Lock_Data                                                          |
|                                                                       |
+======================================================================*/

  --------------------------------------------------
  -- Locking Routine                              --
  --------------------------------------------------

  PROCEDURE Lock_Data IS

     TYPE number_tbl_type IS TABLE OF number INDEX BY BINARY_INTEGER;
     l_lock               number_tbl_type;
     l_procedure_name     varchar2(80) := ''lock_data'';

  BEGIN

     IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
        fnd_log.string(G_LEVEL_PROCEDURE,
                       G_MODULE_NAME||l_procedure_name||''.begin'',
                       ''Beginning of procedure'');
     END IF;

';


C_PRIVATE_API_2   CONSTANT VARCHAR2(32000) := '
--
     IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
        fnd_log.string(G_LEVEL_PROCEDURE,
                       G_MODULE_NAME||l_procedure_name||''.end'',
                       ''End of procedure'');
     END IF;

   EXCEPTION
      WHEN others THEN
           IF (G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL ) THEN
              fnd_message.set_name(''OFA'',''FA_SHARED_ORACLE_ERR'');
              fnd_message.set_token(''ORACLE_ERR'',SQLERRM);
              FND_LOG.MESSAGE (G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_procedure_name,TRUE);
           END IF;
           raise;


  END Lock_Data;

';




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

G_MODULE_NAME         CONSTANT VARCHAR2(50):= 'fa.plsql.fa_xla_cmp_lock_pkg.';


FUNCTION GenerateLockingExtract
      (p_extract_type                 IN VARCHAR2,
       p_package_body                 OUT NOCOPY DBMS_SQL.VARCHAR2S) RETURN BOOLEAN IS

   l_array_pkg              DBMS_SQL.VARCHAR2S;
   l_BodyPkg                VARCHAR2(32000);
   l_array_body             DBMS_SQL.VARCHAR2S;
   l_procedure_name  varchar2(80) := 'GenerateLockingExtract';

BEGIN

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(G_LEVEL_PROCEDURE,
                     G_MODULE_NAME||l_procedure_name||'.begin',
                     'Beginning of procedure');
   END IF;

   l_array_body    := fa_cmp_string_pkg.g_null_varchar2s;
   l_array_pkg     := fa_cmp_string_pkg.g_null_varchar2s;

   -- deferred does not use locking - exit returning nothing
   if (p_extract_type = 'DEF') then
      l_bodypkg := '';

      fa_cmp_string_pkg.CreateString
        (p_package_text  => l_BodyPkg
        ,p_array_string  => l_array_pkg);

      p_package_body := l_array_pkg;

      RETURN TRUE;
   else
      l_bodypkg := C_PRIVATE_API_1;
   end if;

   fa_cmp_string_pkg.CreateString
      (p_package_text  => l_BodyPkg
      ,p_array_string  => l_array_pkg);

   -- BUG# 5444002
   -- removing locking at child level
   if (p_extract_type = 'DEPRN') then
      l_BodyPkg := ' ';
   elsif (p_extract_type = 'TRX') then
      l_BodyPkg := ' ';
   else
      null;  -- unkown type
   end if;

   fa_cmp_string_pkg.CreateString
     (p_package_text  => l_BodyPkg
     ,p_array_string  => l_array_body);

   l_array_pkg :=
      fa_cmp_string_pkg.ConcatTwoStrings
         (p_array_string_1  =>  l_array_pkg
         ,p_array_string_2  =>  l_array_body);


   l_bodypkg := C_PRIVATE_API_2;

   fa_cmp_string_pkg.CreateString
     (p_package_text  => l_BodyPkg
     ,p_array_string  => l_array_body);

   l_array_pkg :=
      fa_cmp_string_pkg.ConcatTwoStrings
         (p_array_string_1  =>  l_array_pkg
         ,p_array_string_2  =>  l_array_body);

   p_package_body := l_array_pkg;

   RETURN TRUE;

EXCEPTION
   WHEN OTHERS THEN
        IF (G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL ) THEN
           fnd_message.set_name('OFA','FA_SHARED_ORACLE_ERR');
           fnd_message.set_token('ORACLE_ERR',SQLERRM);
           FND_LOG.MESSAGE (G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_procedure_name,TRUE);
        END IF;
        RETURN FALSE;

END GenerateLockingExtract;

END fa_xla_cmp_lock_pkg;

/
