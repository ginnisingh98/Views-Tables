--------------------------------------------------------
--  DDL for Package Body FA_XLA_CMP_LINE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_XLA_CMP_LINE_PKG" AS
/* $Header: faxlaclb.pls 120.2.12010000.3 2009/10/29 12:45:34 bridgway ship $   */
/*===========================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| PACKAGE NAME                                                               |
|     fa_xla_cmp_line_pkg                                                    |
|                                                                            |
| DESCRIPTION                                                                |
|     This is a FA private package, which contains all the APIs required     |
|     for to create line extract for each extract type                       |
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


FUNCTION GenerateLineExtract
      (p_extract_type                 IN VARCHAR2,
       p_package_body                 OUT NOCOPY DBMS_SQL.VARCHAR2S) RETURN BOOLEAN IS

   l_loop_total   number := 1;
   l_level        varchar2(30);
   l_extract_type varchar2(30);
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


   -- determine number of times to loop
   if (p_extract_type = 'DEPRN' or
       p_extract_type = 'DEF') then

      l_loop_total := 1;
   else
      l_loop_total := 9;
   end if;

   for i in 1..l_loop_total loop

      if (i = 1) then
         if (p_extract_type = 'TRX') then
            l_extract_type := 'TRX1';
            l_level        := 'STG';
            l_proc_name    := 'load_line_data_stg1';
         else
            l_extract_type := p_extract_type;
            l_level        := 'LINE';
            l_proc_name    := 'load_line_data';
         end if;

      elsif (i = 2) then
         l_extract_type := 'TRX2';
         l_level        := 'STG';
         l_proc_name    := 'load_line_data_stg2';

      else
         l_level        := 'LINE';

         if (i=3) then
            l_extract_type := 'FIN1';
            l_proc_name    := 'load_line_data_fin1';
         elsif (i=4) then
            l_extract_type := 'FIN2';
            l_proc_name    := 'load_line_data_fin2';
         elsif (i=5) then
            l_extract_type := 'XFR';
            l_proc_name    := 'load_line_data_xfr';
         elsif (i=6) then
            l_extract_type := 'DIST1';
            l_proc_name    := 'load_line_data_dist';
         elsif (i=7) then
            l_extract_type := 'DIST2';
            l_proc_name    := 'load_line_data_dist';
         elsif (i=8) then
            l_extract_type := 'RET';
            l_proc_name    := 'load_line_data_ret';
         elsif (i=9) then
            l_extract_type := 'RES';
            l_proc_name    := 'load_line_data_res';
         else
            raise invalid_mode;
         end if;

      end if;


      -- note that we have one corner case where DIST1/DIST2
      -- role into the same procedure - needs to be accounted
      -- for in the building of the procsa
      --
      -- same for inter asset splitting main vs group (no longer true - 3 is no longer used)

      if (i <> 7) then

         l_bodypkg := C_PRIVATE_API_1;
         l_bodypkg := REPLACE(l_bodypkg,'$proc_name$',l_proc_name);

         if (i = 1) then
             fa_cmp_string_pkg.CreateString
               (p_package_text   => l_BodyPkg
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
      end if;

      -- call main util to dynamically determine statements to handle sources
      if not fa_xla_cmp_sources_pkg.GenerateSourcesExtract
        (p_extract_type => l_extract_type,
         p_level        => l_level,
         p_package_body => l_array_body) then
         raise invalid_mode;
      end if;

      l_array_pkg :=
         fa_cmp_string_pkg.ConcatTwoStrings
            (p_array_string_1  =>  l_array_pkg
            ,p_array_string_2  =>  l_array_body);


      if (i <> 6) then -- not the first of two part proc
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

      end if;

   end loop;

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

END GenerateLineExtract;

END fa_xla_cmp_line_pkg;

/
