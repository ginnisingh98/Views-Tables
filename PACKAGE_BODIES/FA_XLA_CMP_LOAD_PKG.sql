--------------------------------------------------------
--  DDL for Package Body FA_XLA_CMP_LOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_XLA_CMP_LOAD_PKG" AS
/* $Header: faxlacob.pls 120.2.12010000.2 2009/07/19 08:36:39 glchen ship $   */
/*===========================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| PACKAGE NAME                                                               |
|     fa_xla_cmp_load_pkg                                                    |
|                                                                            |
| DESCRIPTION                                                                |
|     This is a FA private package, which contains all the APIs required     |
|     for to create header extract for each extract type                     |
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
| Public Function                                                       |
|    Lock_Data                                                          |
|                                                                       |
+======================================================================*/

  --------------------------------------------------
  -- Main Load Routine                            --
  --------------------------------------------------
   PROCEDURE load_data IS

      l_log_level_rec   FA_API_TYPES.log_level_rec_type;
      l_use_fafbgcc     varchar2(25);
      l_procedure_name  varchar2(80) := ''load_data'';   -- BMR make this dynamic on type
      error_found       EXCEPTION;

   BEGIN

      IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
         fnd_log.string(G_LEVEL_PROCEDURE,
                        G_MODULE_NAME||l_procedure_name||''.begin'',
                        ''Beginning of procedure'');
      END IF;

';

C_PRIVATE_API_2   CONSTANT VARCHAR2(32000) := '


      fnd_profile.get (''FA_WF_GENERATE_CCIDS'', l_use_fafbgcc);
      if (nvl(l_use_fafbgcc, ''N'') = ''Y'') then
         if (NOT fa_util_pub.get_log_level_rec (
                   x_log_level_rec =>  l_log_level_rec)) then raise error_found;
         end if;

         Load_Generated_Ccids
            (p_log_level_rec => l_log_level_rec);
      end if;


';

C_PRIVATE_API_3   CONSTANT VARCHAR2(32000) := '


      IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
         fnd_log.string(G_LEVEL_PROCEDURE,
                        G_MODULE_NAME||l_procedure_name||''.end'',
                        ''End of procedure'');
      END IF;

   EXCEPTION
      WHEN error_found THEN
           IF (G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.string (G_LEVEL_ERROR,
                              G_MODULE_NAME||l_procedure_name,
                              ''ended in error'');
           END IF;
           raise;

      WHEN others THEN
           IF (G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
              fnd_message.set_name(''OFA'',''FA_SHARED_ORACLE_ERR'');
              fnd_message.set_token(''ORACLE_ERR'',SQLERRM);
              FND_LOG.MESSAGE (G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_procedure_name,TRUE);
           END IF;
           raise;

   END load_data;

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

G_MODULE_NAME         CONSTANT VARCHAR2(50):= 'fa.plsql.fa_xla_cmp_header_pkg.';


FUNCTION GenerateLoadExtract
      (p_extract_type                 IN VARCHAR2,
       p_package_body                 OUT NOCOPY DBMS_SQL.VARCHAR2S) RETURN BOOLEAN IS

   l_array_pkg              DBMS_SQL.VARCHAR2S;
   l_BodyPkg                VARCHAR2(32000);
   l_array_body             DBMS_SQL.VARCHAR2S;
   l_procedure_name  varchar2(80) := 'GenerateLoadExtract';

BEGIN

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(G_LEVEL_PROCEDURE,
                     G_MODULE_NAME||l_procedure_name||'.begin',
                     'Beginning of procedure');
   END IF;

   l_array_body    := fa_cmp_string_pkg.g_null_varchar2s;
   l_array_pkg     := fa_cmp_string_pkg.g_null_varchar2s;

   -- deferred does not use locking - exit returning nothing
   l_bodypkg := C_PRIVATE_API_1;

   fa_cmp_string_pkg.CreateString
      (p_package_text  => l_BodyPkg
      ,p_array_string  => l_array_pkg);

   if (p_extract_type = 'DEPRN') then
      l_bodypkg := '

         if (fa_xla_extract_util_pkg.G_deprn_exists) then
            Lock_Data;
            Load_header_data;
            Load_line_data;
            Load_mls_data;

            '  || C_PRIVATE_API_2 || '

         end if;

         if (fa_xla_extract_util_pkg.G_rollback_deprn_exists) then
            Load_header_data_rb;
         end if;

';


   elsif (p_extract_type = 'TRX') then

      l_bodypkg := '

         Lock_Data;
         if (fa_xla_extract_util_pkg.G_trx_exists) then
            load_header_data_stg1;
            Load_line_data_stg1;
         end if;

         if (fa_xla_extract_util_pkg.G_inter_trx_exists) then
            load_header_data_stg2;
            Load_line_data_stg2;
         end if;

         if (fa_xla_extract_util_pkg.G_fin_trx_exists) then
            Load_line_data_fin1;
         end if;

         if (fa_xla_extract_util_pkg.G_inter_trx_exists) then
            Load_line_data_fin2;
         end if;

         if (fa_xla_extract_util_pkg.G_xfr_trx_exists) then
            Load_line_data_xfr;
         end if;

         if (fa_xla_extract_util_pkg.G_dist_trx_exists) then
            Load_line_data_dist;
         end if;

         if (fa_xla_extract_util_pkg.G_ret_trx_exists) then
            Load_line_data_ret;
         end if;

         if (fa_xla_extract_util_pkg.G_res_trx_exists) then
            Load_line_data_res;
         end if;

         Load_mls_data;

         '  || C_PRIVATE_API_2;

   elsif (p_extract_type = 'DEF') then

      l_bodypkg := '

         Load_header_data;
         Load_line_data;
         Load_mls_data;

         '  || C_PRIVATE_API_2;

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


   l_bodypkg := C_PRIVATE_API_3;

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

END GenerateLoadExtract;

END fa_xla_cmp_Load_pkg;

/
