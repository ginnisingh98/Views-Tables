--------------------------------------------------------
--  DDL for Package Body FA_XLA_CMP_MLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_XLA_CMP_MLS_PKG" AS
/* $Header: faxlacmb.pls 120.0.12010000.2 2009/07/19 08:35:40 glchen ship $   */
/*===========================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| PACKAGE NAME                                                               |
|     fa_xla_cmp_mls_pkg                                                     |
|                                                                            |
| DESCRIPTION                                                                |
|     This is a FA private package, which contains all the APIs required     |
|     for to create mls level extract for each extract type                  |
|                                                                            |
|                                                                            |
| HISTORY                                                                    |
|     25-JUN-2002 BRIDGWAY      Created                                      |
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
|    $proc_name$                                                        |
|                                                                       |
+======================================================================*/

  PROCEDURE $proc_name$ IS

     l_procedure_name  varchar2(80) := ''$proc_name$'';

  BEGIN

     IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
        fnd_log.string(G_LEVEL_PROCEDURE,
                       G_MODULE_NAME||l_procedure_name||''.begin'',
                       ''Beginning of procedure'');
     END IF;

';

C_PRIVATE_API_2   CONSTANT VARCHAR2(32000) := '

     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
        fnd_log.string(G_LEVEL_PROCEDURE,
                       G_MODULE_NAME||l_procedure_name,
                       ''Rows inserted into mls: '' || to_char(SQL%ROWCOUNT));
     END IF;

';


C_PRIVATE_API_3   CONSTANT VARCHAR2(32000) := '

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

   end $proc_name$;

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

G_MODULE_NAME         CONSTANT VARCHAR2(50):= 'fa.plsql.fa_xla_cmp_line_pkg.';


FUNCTION GenerateMlsExtract
      (p_extract_type                 IN VARCHAR2,
       p_package_body                 OUT NOCOPY DBMS_SQL.VARCHAR2S) RETURN BOOLEAN IS

   l_proc_name    varchar2(80);

   l_array_pkg              DBMS_SQL.VARCHAR2S;
   l_BodyPkg                VARCHAR2(32000);
   l_array_body             DBMS_SQL.VARCHAR2S;
   l_procedure_name  varchar2(80) := 'GenerateLineExtract';

   invalid_mode EXCEPTION;

BEGIN

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(G_LEVEL_PROCEDURE,
                     G_MODULE_NAME||l_procedure_name||'.begin',
                     'Beginning of procedure');
   END IF;

   l_array_body    := fa_cmp_string_pkg.g_null_varchar2s;
   l_array_pkg     := fa_cmp_string_pkg.g_null_varchar2s;


   l_proc_name    := 'load_mls_data';

   l_bodypkg := C_PRIVATE_API_1;
   l_bodypkg := REPLACE(l_bodypkg,'$proc_name$',l_proc_name);

   fa_cmp_string_pkg.CreateString
        (p_package_text   => l_BodyPkg
        ,p_array_string  => l_array_pkg);


   -- call main util to dynamically determine statements to handle sources
   if not fa_xla_cmp_sources_pkg.GenerateSourcesExtract
        (p_extract_type => p_extract_type,
         p_level        => 'MLS',
         p_package_body => l_array_body) then
         raise invalid_mode;
   end if;

   l_array_pkg :=
      fa_cmp_string_pkg.ConcatTwoStrings
            (p_array_string_1  =>  l_array_pkg
            ,p_array_string_2  =>  l_array_body);

   -- add the debug for row counts
   l_bodypkg := C_PRIVATE_API_2;

   fa_cmp_string_pkg.CreateString
      (p_package_text  => l_BodyPkg
      ,p_array_string  => l_array_body);

   l_array_pkg :=
      fa_cmp_string_pkg.ConcatTwoStrings
         (p_array_string_1  =>  l_array_pkg
         ,p_array_string_2  =>  l_array_body);

   -- add the closing
   l_bodypkg := C_PRIVATE_API_3;
   l_bodypkg := REPLACE(l_bodypkg,'$proc_name$',l_proc_name);

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
   WHEN invalid_mode THEN
        RETURN FALSE;

   WHEN OTHERS THEN
        IF (G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL ) THEN
           fnd_message.set_name('OFA','FA_SHARED_ORACLE_ERR');
           fnd_message.set_token('ORACLE_ERR',SQLERRM);
           FND_LOG.MESSAGE (G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_procedure_name,TRUE);
        END IF;
        RETURN FALSE;

END GenerateMlsExtract;

END fa_xla_cmp_mls_pkg;

/
