--------------------------------------------------------
--  DDL for Package Body FA_XLA_CMP_HEADER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_XLA_CMP_HEADER_PKG" AS
/* $Header: faxlachb.pls 120.1.12010000.5 2009/10/29 12:48:58 bridgway ship $   */
/*===========================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| PACKAGE NAME                                                               |
|     fa_xla_cmp_header_pkg                                                  |
|                                                                            |
| DESCRIPTION                                                                |
|     This is a FA private package, which contains all the APIs required     |
|     for to create header level extract for each extract type               |
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

C_PRIVATE_ROLLBACK CONSTANT VARCHAR2(32000) := '

  PROCEDURE Load_header_data_rb IS

     l_procedure_name  varchar2(80) := ''load_header_data_rb'';

  BEGIN

     IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
        fnd_log.string(G_LEVEL_PROCEDURE,
                       G_MODULE_NAME||l_procedure_name||''.begin'',
                       ''Beginning of procedure'');
     END IF;

     INSERT INTO FA_XLA_EXT_HEADERS_B_GT (
          event_id                                ,
          period_close_date                       ,
          reversal_flag                           ,
          transfer_to_gl_flag                     ,
          accounting_date                         )
    SELECT ctlgd.event_id                         ,
           dp.CALENDAR_PERIOD_CLOSE_DATE          ,
           ''Y''                                  ,
           decode(bc.GL_POSTING_ALLOWED_FLAG      ,
                 ''YES'', ''Y'',
                 ''N''),
           dp.CALENDAR_PERIOD_CLOSE_DATE
      FROM xla_events_gt                 ctlgd,
           fa_book_controls              bc,
           fa_deprn_periods              dp,
           fa_deprn_events               ds
     WHERE ctlgd.entity_code         = ''DEPRECIATION''
       AND ctlgd.event_type_code     = ''ROLLBACK_DEPRECIATION''
       AND ds.asset_id               = ctlgd.source_id_int_1
       AND ds.book_type_code         = ctlgd.source_id_char_1
       AND ds.period_counter         = ctlgd.source_id_int_2
       AND ds.deprn_run_id           = ctlgd.source_id_int_3
       AND bc.book_type_code         = ctlgd.source_id_char_1
--       AND ds.book_type_code         = ctlgd.valuation_method
       AND ds.reversal_event_id      = ctlgd.event_id
       AND dp.book_type_code         = ds.book_type_code
       AND dp.period_counter         = ds.period_counter;


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

  END Load_header_data_rb ;

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


FUNCTION GenerateHeaderExtract
      (p_extract_type                 IN VARCHAR2,
       p_package_body                 OUT NOCOPY DBMS_SQL.VARCHAR2S) RETURN BOOLEAN IS

   l_loop_total   number := 1;
   l_level        varchar2(30);
   l_extract_type varchar2(30);
   l_proc_name    varchar2(80);

   l_array_pkg              DBMS_SQL.VARCHAR2S;
   l_BodyPkg                VARCHAR2(32000);
   l_array_body             DBMS_SQL.VARCHAR2S;
   l_procedure_name  varchar2(80) := 'GenerateHeaderExtract';

   invalid_mode EXCEPTION;

BEGIN

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(G_LEVEL_PROCEDURE,
                     G_MODULE_NAME||l_procedure_name||'.begin',
                     'Beginning of procedure');
   END IF;

   l_array_body    := fa_cmp_string_pkg.g_null_varchar2s;
   l_array_pkg     := fa_cmp_string_pkg.g_null_varchar2s;


   -- determine number of times to loop
   if (p_extract_type = 'DEPRN' or
       p_extract_type = 'DEF') then
      l_loop_total := 1;
   else
      l_loop_total := 2;
   end if;

   for i in 1..l_loop_total loop

      if (i = 1) then
         if (p_extract_type = 'TRX') then
            l_extract_type := 'TRX1';
            l_proc_name    := 'load_header_data_stg1';
         else
            l_extract_type := p_extract_type;
            l_proc_name    := 'load_header_data';
         end if;
      else -- 2
         l_extract_type := 'TRX2';
         l_proc_name    := 'load_header_data_stg2';
      end if;

      l_bodypkg := C_PRIVATE_API_1;
      l_bodypkg := REPLACE(l_bodypkg,'$proc_name$',l_proc_name);

      if (i = 1) then
         fa_cmp_string_pkg.CreateString
            (p_package_text  => l_BodyPkg
            ,p_array_string  => l_array_pkg);

      else
         fa_cmp_string_pkg.CreateString
            (p_package_text  => l_BodyPkg
            ,p_array_string  => l_array_body);

         l_array_pkg :=
            fa_cmp_string_pkg.ConcatTwoStrings
               (p_array_string_1  =>  l_array_pkg
               ,p_array_string_2  =>  l_array_body);
      end if;

      -- call main util to dynamically determine statements to handle sources
      if not fa_xla_cmp_sources_pkg.GenerateSourcesExtract
        (p_extract_type => l_extract_type,
         p_level        => 'HEADER',
         p_package_body => l_array_body) then
         raise invalid_mode;
      end if;


      l_array_pkg :=
         fa_cmp_string_pkg.ConcatTwoStrings
            (p_array_string_1  =>  l_array_pkg
            ,p_array_string_2  =>  l_array_body);

      -- add the closing
      l_bodypkg := C_PRIVATE_API_2;
      l_bodypkg := REPLACE(l_bodypkg,'$proc_name$',l_proc_name);

      fa_cmp_string_pkg.CreateString
        (p_package_text  => l_BodyPkg
        ,p_array_string  => l_array_body);

      l_array_pkg :=
         fa_cmp_string_pkg.ConcatTwoStrings
            (p_array_string_1  =>  l_array_pkg
            ,p_array_string_2  =>  l_array_body);

   end loop;

   -- for rollback deprn, need one more routine in deprn package
   if (p_extract_type = 'DEPRN') then

     l_bodypkg := C_PRIVATE_ROLLBACK;

      fa_cmp_string_pkg.CreateString
        (p_package_text  => l_BodyPkg
        ,p_array_string  => l_array_body);

      l_array_pkg :=
         fa_cmp_string_pkg.ConcatTwoStrings
            (p_array_string_1  =>  l_array_pkg
            ,p_array_string_2  =>  l_array_body);

   end if;

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

END GenerateHeaderExtract;

END fa_xla_cmp_header_pkg;

/
