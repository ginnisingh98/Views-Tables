--------------------------------------------------------
--  DDL for Package Body XLA_CMP_TAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_CMP_TAD_PKG" AS
/* $Header: xlacptad.pkb 120.25.12010000.3 2009/06/26 09:29:37 vkasina ship $ */
/*======================================================================+
|             Copyright (c) 1995-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_cmp_tad_pkg                                                    |
|                                                                       |
| DESCRIPTION                                                           |
|    Transaction Account Builder Engine Compiler                        |
|                                                                       |
| HISTORY                                                               |
|    26-JAN-04 A.Quaglia      Created                                   |
|    04-JUN-04 A.Quaglia      Changed hash_id to NUMBER                 |
|                             ,row_id to base_rowid                     |
|                             ,ccid, target_ccid to NUMBER(15)          |
|                             Removed amb_context param from            |
|                             compile_application_tads_srs              |
|                             compile_application_tads                  |
|    07-JUN-04 A.Quaglia      Fixed GSCC warnings                       |
|                             Corrected typo with                       |
|                             C_TMPL_WHERE_SEGMENTS_EQUALS in upd stmts.|
|    14-JUN-04 A.Quaglia      Completed compile_application_tads.       |
|    16-JUN-04 A.Quaglia      compile_tad: added check on missing tats. |
|    17-JUN-04 A.Quaglia      compile_tad: added reset of msg stack     |
|                             get_tad_package_name: added TO_CHAR       |
|                             in trace statements.                      |
|                             build_code_combinations_dyn: fixed bug    |
|                             for multiple TATs                         |
|                             Some params were still IN OUT instd of OUT|
|    21-JUN-04 A.Quaglia      Change to return the concatenated segments|
|                             g_tab_api_package_name:                   |
|                                removed                                |
|                             get_flex_concat_segments (generated):     |
|                                removed                                |
|                             build_static_ccid_prc_stmts:              |
|                                modified to generate the concatenated  |
|                                segments for all rows.                 |
|                             build_code_combinations_dyn  (generated): |
|                                modified to generate the concatenated  |
|                                segments for all rows.                 |
|                             C_TMPL_BATCH_BUILD_CCID_STMTS:            |
|                                modified to generate the concatenated  |
|                                segments for all rows.                 |
|                             pop_interface_data (generated):           |
|                                modified to retrieve the concatenated  |
|                                segments.                              |
|    23-JUN-04 A.Quaglia      compile_tad:                              |
|                                all enabled tats for the application   |
|                                must be compiled not only those        |
|                                associated to the tad being compiled.  |
|    28-JUL-04 A.Quaglia      trans_account_def_online:                 |
|                                delete from global temp tables so that |
|                                successive calls from OAF are allowed  |
|                                in case of errors and no rollback is   |
|                                issued in-between.                     |
|                             C_TMPL_PUSH_INTERF_DATA_STMT:             |
|                                introduced deletion of interface       |
|                                global temp table as per explanation   |
|                                above.                                 |
|    28-JUL-04 A.Quaglia      compile_tad:                              |
|                                moved call to init_global_variables    |
|                                before messages are raised.            |
|                             log_ccid_disabled_error (generated):      |
|                             log_null_segments_error (generated):      |
|                             log_ccid_not_found_error (generated):     |
|                               added param p_account_type_code         |
|                               and logic to derive the acc.type name   |
|                             changed calls to these routines           |
|                             changed various message tokens            |
|    28-JUL-04 A.Quaglia      C_TMPL_BATCH_BUILD_CCID_STMTS:            |
|                               gt.processed_flag must be gtint.        |
|                               in the statements that creates the new  |
|                               ccids.                                  |
|    05-JAN-05 K.Boussema     Split up C_TMPL_TAD_PACKAGE_BODY_PART_1   |
|                                and C_TMPL_TAD_PACKAGE_BODY_PART_2.    |
|    18-MAI-05 K.Boussema     added the column dummy_rowid in GT tables |
|                                to fix bug 4344773                     |
|    08-AUG-2006 Jorge Larre  Bug 5368196                               |
|     Use FIRST instead of 0 and 1 in the index of the array in the     |
|     statements C_TMPL_PUSH_INTERF_DATA_STMT and                       |
|     C_TMPL_POP_INTERF_DATA_STMT.                                      |
|    23-AUG-2006 Jorge Larre  Bug 5411930                               |
|     When calling FND_FLEX_EXT.get_ccid we need to convert the date    |
|     into the format accepted by the routine : 'YYYY/MM/DD HH24:MI:SS' |
+======================================================================*/

   --
   -- Private exceptions
   --

   ge_fatal_error                   EXCEPTION;

   TYPE gt_rec_tad_details IS RECORD
   (
      application_id          NUMBER
     ,amb_context_code        VARCHAR2(30)
     ,account_type_code       VARCHAR2(30)
     ,flexfield_segment_code  VARCHAR2(30)
     ,segment_rule_type_code  VARCHAR2(1)
     ,segment_rule_code       VARCHAR2(30)
     ,object_name_affix       VARCHAR2(10)
     ,tat_compile_status_code VARCHAR2(1)
     ,rule_assignment_code    VARCHAR2(30)
     ,adr_id                  NUMBER
   );

   TYPE gt_table_of_tad_details IS TABLE OF gt_rec_tad_details
                                   INDEX BY BINARY_INTEGER;


   --
   -- Private constants
   --

   g_chr_newline      CONSTANT VARCHAR2(1):= xla_environment_pkg.g_chr_newline;

   G_STANDARD_MESSAGE CONSTANT VARCHAR2(1) := xla_exceptions_pkg.C_STANDARD_MESSAGE;



--+==========================================================================+
--|            package specification template                                |
--+==========================================================================+

--
C_TMPL_TAD_PACKAGE_SPEC  CONSTANT  CLOB :=
'CREATE OR REPLACE PACKAGE $TAD_PACKAGE_NAME_1$ AS' ||
g_chr_newline||
'/'||'* $Header: generated on site by the Subledger Accounting Compiler*/' ||
g_chr_newline||
'/'|| '*======================================================================+
|                Copyright (c) 2004 Oracle Corporation                  |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|     $TAD_PACKAGE_NAME_2$
|                                                                       |
| DESCRIPTION                                                           |
|                                                                       |
|     Transaction Account Builder Engine Component                      |
|                                                                       |
|     Package generated by Oracle Subledger Accounting for              |
|                                                                       |
|     $APPLICATION_NAME$
|     (application_id: $APPLICATION_ID$
|                                                                       |
|     Corresponds to the following Transaction Account Definition       |
|     Code            : $TAD_CODE$
|     Type Code       : $TAD_TYPE_CODE$
|     AMB Context Code: $AMB_CONTEXT_CODE$
|                                                                       |
|                                                                       |
|                                                                       |
|     ATTENTION:                                                        |
|     This package has been automatically generated by the              |
|     Oracle Subledger Accounting Compiler. You should not modify its   |
|     content manually.                                                 |
|     This package has been generated according to the current setup    |
|     for the aforementioned Transaction Account Definition.            |
|                                                                       |
|     In case of issues independent of the setup                        |
|     please log a bug against Oracle Subledger Accounting.             |
|                                                                       |
|                                                                       |
| HISTORY                                                               |
|     $HISTORY$
|                                                                       |
+=======================================================================*'
||'/'
||
'


--Public procedures

PROCEDURE trans_account_def_online
   (
     p_transaction_coa_id           IN         NUMBER
    ,p_accounting_coa_id            IN         NUMBER
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
   );

PROCEDURE trans_account_def_batch
    (
      p_transaction_coa_id          IN            NUMBER
     ,p_accounting_coa_id           IN            NUMBER
     ,x_return_status               OUT NOCOPY VARCHAR2
     ,x_msg_count                   OUT NOCOPY NUMBER
     ,x_msg_data                    OUT NOCOPY VARCHAR2
    );

FUNCTION log_error (
                      p_mode            IN VARCHAR2
                     ,p_rowid           IN UROWID
                     ,p_line_index      IN NUMBER
                     ,p_encoded_message IN VARCHAR2
                    )
RETURN VARCHAR2;

FUNCTION log_ccid_not_found_error (
                      p_mode                   IN VARCHAR2
                     ,p_rowid                  IN UROWID
                     ,p_line_index             IN NUMBER
                     ,p_chart_of_accounts_name IN VARCHAR2
                     ,p_ccid                   IN NUMBER
                     ,p_calling_function_name  IN VARCHAR2
                     ,p_account_type_code      IN VARCHAR2
                    )
RETURN VARCHAR2;

FUNCTION log_ccid_disabled_error (
                      p_mode                   IN VARCHAR2
                     ,p_rowid                  IN UROWID
                     ,p_line_index             IN NUMBER
                     ,p_chart_of_accounts_name IN VARCHAR2
                     ,p_ccid                   IN NUMBER
                     ,p_calling_function_name  IN VARCHAR2
                     ,p_account_type_code      IN VARCHAR2
                    )
RETURN VARCHAR2;

FUNCTION log_null_segments_error (
                      p_mode                   IN VARCHAR2
                     ,p_rowid                  IN UROWID
                     ,p_line_index             IN NUMBER
                     ,p_chart_of_accounts_name IN VARCHAR2
                     ,p_ccid                   IN NUMBER
                     ,p_calling_function_name  IN VARCHAR2
                     ,p_account_type_code      IN VARCHAR2
                    )
RETURN VARCHAR2;

FUNCTION create_ccid (
                      p_mode                     IN VARCHAR2
                     ,p_rowid                    IN UROWID
                     ,p_line_index               IN NUMBER
                     ,p_chart_of_accounts_id     IN NUMBER
                     ,p_chart_of_accounts_name   IN VARCHAR2
                     ,p_calling_function_name    IN VARCHAR2
                     ,p_validation_date          IN DATE
                     ,p_concatenated_segments    IN VARCHAR2
                    )
RETURN NUMBER;

FUNCTION get_coa_info
   (
     p_chart_of_accounts_id         IN         NUMBER
    ,p_chart_of_accounts_name       OUT NOCOPY VARCHAR2
    ,p_flex_delimiter               OUT NOCOPY VARCHAR2
    ,p_concat_segments_template     OUT NOCOPY VARCHAR2
    ,p_gl_balancing_segment_name    OUT NOCOPY VARCHAR2
    ,p_gl_account_segment_name      OUT NOCOPY VARCHAR2
    ,p_gl_intercompany_segment_name OUT NOCOPY VARCHAR2
    ,p_gl_management_segment_name   OUT NOCOPY VARCHAR2
    ,p_fa_cost_ctr_segment_name     OUT NOCOPY VARCHAR2
    ,p_table_segment_qualifiers     OUT NOCOPY xla_cmp_tad_pkg.gt_table_V30_V30
    ,p_table_segment_column_names   OUT NOCOPY xla_cmp_tad_pkg.gt_table_V30
   )
RETURN BOOLEAN;


$TAD_ADR_FUNCT_SPECS$



END $TAD_PACKAGE_NAME_1$;
';

--+==========================================================================+
--|            end of package specification template                         |
--+==========================================================================+


C_TMPL_BATCH_BLD_CCID_DYN_STMS CONSTANT  CLOB :=
'
   IF NOT build_code_combinations_dyn
   (
     p_chart_of_accounts_id         => p_chart_of_accounts_id
    ,p_chart_of_accounts_name       => p_chart_of_accounts_name
    ,p_flex_delimiter               => p_flex_delimiter
    ,p_concat_segments_template     => p_concat_segments_template
    ,p_table_segment_qualifiers     => p_table_segment_qualifiers
    ,p_table_segment_column_names   => p_table_segment_column_names
    ,p_gl_balancing_segment_name    => p_gl_balancing_segment_name
    ,p_gl_account_segment_name      => p_gl_account_segment_name
    ,p_gl_intercompany_segment_name => p_gl_intercompany_segment_name
    ,p_gl_management_segment_name   => p_gl_management_segment_name
    ,p_fa_cost_ctr_segment_name     => p_fa_cost_ctr_segment_name
   )
   THEN
      l_fatal_error_message := ''build_code_combinations_dyn failed'';
      RAISE le_fatal_error;
   END IF;
';




--+==========================================================================+
--|            package body template                                         |
--+==========================================================================+

--

C_TMPL_TAD_PACKAGE_BODY_PART_1  CONSTANT  CLOB :=
'CREATE OR REPLACE PACKAGE BODY $TAD_PACKAGE_NAME_1$ AS' ||
g_chr_newline||
'/'||'* $Header: generated on site by the Subledger Accounting Compiler*/' ||
g_chr_newline||
'/'|| '*======================================================================+
|                Copyright (c) 2004 Oracle Corporation                  |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|     $TAD_PACKAGE_NAME_2$
|                                                                       |
| DESCRIPTION                                                           |
|                                                                       |
|     Transaction Account Builder Engine Component                      |
|                                                                       |
|     Package generated by Oracle Subledger Accounting for              |
|                                                                       |
|     $APPLICATION_NAME$
|     (application_id: $APPLICATION_ID$
|                                                                       |
|     Corresponds to the following Transaction Account Definition       |
|     Code            : $TAD_CODE$
|     Type Code       : $TAD_TYPE_CODE$
|     AMB Context Code: $AMB_CONTEXT_CODE$
|                                                                       |
|                                                                       |
|                                                                       |
|     ATTENTION:                                                        |
|     This package has been automatically generated by the              |
|     Oracle Subledger Accounting Compiler. You should not modify its   |
|     content manually.                                                 |
|     This package has been generated according to the current setup    |
|     for the aforementioned Transaction Account Definition.            |
|                                                                       |
|     In case of issues independent of the setup                        |
|     please log a bug against Oracle Subledger Accounting.             |
|                                                                       |
|                                                                       |
| HISTORY                                                               |
|     $HISTORY$
|                                                                       |
+=======================================================================*'
||'/'
||
'

FUNCTION g_default_module RETURN VARCHAR2
IS
BEGIN
    return ''xla.plsql.$TAD_PACKAGE_NAME_3$'';
END g_default_module;

FUNCTION g_batch_build_ccid_stmts RETURN CLOB
IS
BEGIN
    return REPLACE(xla_cmp_tad_pkg.C_TMPL_BATCH_BUILD_CCID_STMTS, '''''''', '''''''''''');
END g_batch_build_ccid_stmts;

PROCEDURE trace
       ( p_module                     IN VARCHAR2
        ,p_msg                        IN VARCHAR2
        ,p_level                      IN NUMBER
        ) IS
BEGIN
   ----------------------------------------------------------------------------
   -- Following is for FND log.
   ----------------------------------------------------------------------------
   IF (p_msg IS NULL AND p_level >= xla_cmp_tad_pkg.g_log_level) THEN
      fnd_log.message(p_level, p_module);
   ELSIF p_level >= xla_cmp_tad_pkg.g_log_level THEN
      fnd_log.string(p_level, p_module, p_msg);
   END IF;

EXCEPTION
WHEN app_exceptions.application_exception THEN
   RAISE;
WHEN OTHERS THEN
   fnd_message.set_name(''XLA'', ''XLA_TAB_UNHANDLED_EXCEPTION'');
   fnd_message.set_token( ''PROCEDURE''
                         ,''$TAD_PACKAGE_NAME_3$.trace'');
   RAISE;
END trace;


PROCEDURE log_error (
                      p_mode            IN VARCHAR2
                     ,p_rowid           IN UROWID
                     ,p_line_index      IN NUMBER
                     ,p_encoded_message IN VARCHAR2
                    )
IS
   l_encoded_message VARCHAR2(2000);
   l_log_module      VARCHAR2(2000);
BEGIN

   IF xla_cmp_tad_pkg.g_log_enabled THEN
      l_log_module := g_default_module||''.log_error'';
   END IF;

   IF (xla_cmp_tad_pkg.C_LEVEL_PROCEDURE >= xla_cmp_tad_pkg.g_log_level) THEN
      trace
           ( p_module   => l_log_module
            ,p_msg      => ''BEGIN '' || l_log_module
            ,p_level    => xla_cmp_tad_pkg.C_LEVEL_PROCEDURE);
   END IF;

   IF p_encoded_message IS NULL
   THEN
      --Retrieve the encoded message
      l_encoded_message := FND_MESSAGE.GET_ENCODED();
   ELSE
      l_encoded_message := p_encoded_message;
   END IF;

   --Write a record in the appropriate table depending on the mode
   IF p_mode = ''BATCH''
   THEN
      INSERT INTO XLA_TAB_ERRORS_GT
      (
        base_rowid
       ,msg_data
      )
      (
        SELECT p_rowid
              ,l_encoded_message
          FROM dual
         WHERE 0 = (SELECT COUNT(*)
                      FROM XLA_TAB_ERRORS_GT xte
                     WHERE xte.base_rowid   = p_rowid
                       AND xte.msg_data     = l_encoded_message
                   )
           AND ROWNUM = 1
      );

   ELSIF p_mode = ''ONLINE''
   THEN
      NULL;
   END IF;

   IF (xla_cmp_tad_pkg.C_LEVEL_PROCEDURE >= xla_cmp_tad_pkg.g_log_level) THEN
      trace
           ( p_module   => l_log_module
            ,p_msg      => ''END '' || l_log_module
            ,p_level    => xla_cmp_tad_pkg.C_LEVEL_PROCEDURE);
   END IF;

END log_error;

FUNCTION log_error (
                      p_mode            IN VARCHAR2
                     ,p_rowid           IN UROWID
                     ,p_line_index      IN NUMBER
                     ,p_encoded_message IN VARCHAR2
                    )
RETURN VARCHAR2
IS
   l_encoded_message VARCHAR2(2000);
   l_log_module      VARCHAR2(2000);
BEGIN

   IF xla_cmp_tad_pkg.g_log_enabled THEN
      l_log_module := g_default_module||''.log_error'';
   END IF;

   IF (xla_cmp_tad_pkg.C_LEVEL_PROCEDURE >= xla_cmp_tad_pkg.g_log_level) THEN
      trace
           ( p_module   => l_log_module
            ,p_msg      => ''BEGIN '' || l_log_module
            ,p_level    => xla_cmp_tad_pkg.C_LEVEL_PROCEDURE);
   END IF;

   log_error (
               p_mode            => p_mode
              ,p_rowid           => p_rowid
              ,p_line_index      => p_line_index
              ,p_encoded_message => p_encoded_message
             );

   IF (xla_cmp_tad_pkg.C_LEVEL_PROCEDURE >= xla_cmp_tad_pkg.g_log_level) THEN
      trace
           ( p_module   => l_log_module
            ,p_msg      => ''END '' || l_log_module
            ,p_level    => xla_cmp_tad_pkg.C_LEVEL_PROCEDURE);
   END IF;

   RETURN NULL;

END log_error;


PROCEDURE log_error (
                      p_mode           IN VARCHAR2
                     ,p_rowid          IN UROWID
                     ,p_line_index     IN NUMBER
                     ,p_msg_name       IN VARCHAR2
                     ,p_token_name_1   IN VARCHAR2 DEFAULT NULL
                     ,p_token_value_1  IN VARCHAR2 DEFAULT NULL
                     ,p_token_name_2   IN VARCHAR2 DEFAULT NULL
                     ,p_token_value_2  IN VARCHAR2 DEFAULT NULL
                     ,p_token_name_3   IN VARCHAR2 DEFAULT NULL
                     ,p_token_value_3  IN VARCHAR2 DEFAULT NULL
                     ,p_token_name_4   IN VARCHAR2 DEFAULT NULL
                     ,p_token_value_4  IN VARCHAR2 DEFAULT NULL
                     ,p_token_name_5   IN VARCHAR2 DEFAULT NULL
                     ,p_token_value_5  IN VARCHAR2 DEFAULT NULL
                    )
IS
   l_encoded_message VARCHAR2(2000);
   l_log_module                 VARCHAR2(2000);
BEGIN

   IF xla_cmp_tad_pkg.g_log_enabled THEN
      l_log_module := g_default_module||''.log_error'';
   END IF;

   IF (xla_cmp_tad_pkg.C_LEVEL_PROCEDURE >= xla_cmp_tad_pkg.g_log_level) THEN
      trace
           ( p_module   => l_log_module
            ,p_msg      => ''BEGIN '' || l_log_module
            ,p_level    => xla_cmp_tad_pkg.C_LEVEL_PROCEDURE);
   END IF;

   --Set the message onto the message stack
   FND_MESSAGE.SET_NAME
      (
        application => ''XLA''
       ,name        => p_msg_name
      );

   --Set token 1
   IF p_token_name_1 IS NOT NULL
   THEN
      FND_MESSAGE.SET_TOKEN (p_token_name_1, p_token_value_1);
   END IF;

   --Set token 2
   IF p_token_name_2 IS NOT NULL
   THEN
      FND_MESSAGE.SET_TOKEN (p_token_name_2, p_token_value_2);
   END IF;

   --Set token 3
   IF p_token_name_3 IS NOT NULL
   THEN
      FND_MESSAGE.SET_TOKEN (p_token_name_3, p_token_value_3);
   END IF;

   --Set token 4
   IF p_token_name_4 IS NOT NULL
   THEN
      FND_MESSAGE.SET_TOKEN (p_token_name_4, p_token_value_4);
   END IF;

   --Set token 5
   IF p_token_name_5 IS NOT NULL
   THEN
      FND_MESSAGE.SET_TOKEN (p_token_name_5, p_token_value_5);
   END IF;

   log_error
      (
        p_mode            => p_mode
       ,p_rowid           => p_rowid
       ,p_line_index      => p_line_index
       ,p_encoded_message => NULL
      );

   IF (xla_cmp_tad_pkg.C_LEVEL_PROCEDURE >= xla_cmp_tad_pkg.g_log_level) THEN
      trace
           ( p_module   => l_log_module
            ,p_msg      => ''END '' || l_log_module
            ,p_level    => xla_cmp_tad_pkg.C_LEVEL_PROCEDURE);
   END IF;

END log_error;


FUNCTION log_null_segments_error (
                      p_mode                   IN VARCHAR2
                     ,p_rowid                  IN UROWID
                     ,p_line_index             IN NUMBER
                     ,p_chart_of_accounts_name IN VARCHAR2
                     ,p_ccid                   IN NUMBER
                     ,p_calling_function_name  IN VARCHAR2
                     ,p_account_type_code      IN VARCHAR2
                    )
RETURN VARCHAR2
IS
   l_account_type_name VARCHAR2(80);
   l_log_module      VARCHAR2(2000);
BEGIN

   IF xla_cmp_tad_pkg.g_log_enabled THEN
      l_log_module := g_default_module||''.log_null_segments_error'';
   END IF;

   IF (xla_cmp_tad_pkg.C_LEVEL_PROCEDURE >= xla_cmp_tad_pkg.g_log_level) THEN
      trace
           ( p_module   => l_log_module
            ,p_msg      => ''BEGIN '' || l_log_module
            ,p_level    => xla_cmp_tad_pkg.C_LEVEL_PROCEDURE);
   END IF;

   IF (xla_cmp_tad_pkg.C_LEVEL_STATEMENT >= xla_cmp_tad_pkg.g_log_level)
   THEN
      trace
      ( p_module   => l_log_module
       ,p_msg      => ''p_mode: '' || p_mode
       ,p_level    => xla_cmp_tad_pkg.C_LEVEL_STATEMENT);
      trace
      ( p_module   => l_log_module
       ,p_msg      => ''p_rowid: '' || p_rowid
       ,p_level    => xla_cmp_tad_pkg.C_LEVEL_STATEMENT);
      trace
      ( p_module   => l_log_module
       ,p_msg      => ''p_ccid: '' || p_ccid
       ,p_level    => xla_cmp_tad_pkg.C_LEVEL_STATEMENT);
      trace
      ( p_module   => l_log_module
       ,p_msg      => ''p_chart_of_accounts_name: ''||p_chart_of_accounts_name
       ,p_level    => xla_cmp_tad_pkg.C_LEVEL_STATEMENT);
   END IF;

   --Try to get the account type name
   BEGIN
      SELECT xtat.name
        INTO l_account_type_name
        FROM xla_tab_acct_types_tl xtat
       WHERE xtat.application_id    = $APPLICATION_ID_2$
         AND xtat.account_type_code = p_account_type_code;

   EXCEPTION
   --If unable to get the name use the account type code
   WHEN OTHERS
   THEN
      l_account_type_name := p_account_type_code;
   END;

   --If no ccid was given it
   IF p_ccid IS NULL
   THEN
      log_error (
                  p_mode           => p_mode
                 ,p_rowid          => p_rowid
                 ,p_line_index     => p_line_index
                 ,p_msg_name       => ''XLA_TAB_CCID_NULL''
                 ,p_token_name_1   => ''TRX_ACCT_TYPE''
                 ,p_token_value_1  => l_account_type_name

                );
   ELSE
      log_error (
                  p_mode           => p_mode
                 ,p_rowid          => p_rowid
                 ,p_line_index     => p_line_index
                 ,p_msg_name       => ''XLA_TAB_CCID_NOT_FOUND''
                 ,p_token_name_1   => ''TRX_ACCT_TYPE''
                 ,p_token_value_1  => l_account_type_name
                 ,p_token_name_2   => ''ACCOUNT_VALUE''
                 ,p_token_value_2  => p_ccid
                 ,p_token_name_3   => ''STRUCTURE_NAME''
                 ,p_token_value_3  => p_chart_of_accounts_name
                );
   END IF;

   RETURN NULL;

   IF (xla_cmp_tad_pkg.C_LEVEL_PROCEDURE >= xla_cmp_tad_pkg.g_log_level) THEN
      trace
           ( p_module   => l_log_module
            ,p_msg      => ''END '' || l_log_module
            ,p_level    => xla_cmp_tad_pkg.C_LEVEL_PROCEDURE);
   END IF;

END log_null_segments_error;

FUNCTION log_ccid_disabled_error (
                      p_mode                   IN VARCHAR2
                     ,p_rowid                  IN UROWID
                     ,p_line_index             IN NUMBER
                     ,p_chart_of_accounts_name IN VARCHAR2
                     ,p_ccid                   IN NUMBER
                     ,p_calling_function_name  IN VARCHAR2
                     ,p_account_type_code      IN VARCHAR2
                    )
RETURN VARCHAR2
IS
   l_account_type_name VARCHAR2(80);
   l_log_module        VARCHAR2(2000);
BEGIN

   IF xla_cmp_tad_pkg.g_log_enabled THEN
      l_log_module := g_default_module||''.log_ccid_disabled_error'';
   END IF;

   IF (xla_cmp_tad_pkg.C_LEVEL_PROCEDURE >= xla_cmp_tad_pkg.g_log_level) THEN
      trace
           ( p_module   => l_log_module
            ,p_msg      => ''BEGIN '' || l_log_module
            ,p_level    => xla_cmp_tad_pkg.C_LEVEL_PROCEDURE);
   END IF;

   --Try to get the account type name
   BEGIN
      SELECT xtat.name
        INTO l_account_type_name
        FROM xla_tab_acct_types_tl xtat
       WHERE xtat.application_id    = $APPLICATION_ID_2$
         AND xtat.account_type_code = p_account_type_code;

   EXCEPTION
   --If unable to get the name use the account type code
   WHEN OTHERS
   THEN
      l_account_type_name := p_account_type_code;
   END;

   log_error (
                  p_mode           => p_mode
                 ,p_rowid          => p_rowid
                 ,p_line_index     => p_line_index
                 ,p_msg_name       => ''XLA_TAB_CCID_DISABLED''
                 ,p_token_name_1   => ''ACCOUNT_VALUE''
                 ,p_token_value_1  => p_ccid
                 ,p_token_name_2   => ''STRUCTURE_NAME''
                 ,p_token_value_2  => p_chart_of_accounts_name
                 ,p_token_name_3   => ''TRX_ACCT_TYPE''
                 ,p_token_value_3  => l_account_type_name
                );

   RETURN NULL;

   IF (xla_cmp_tad_pkg.C_LEVEL_PROCEDURE >= xla_cmp_tad_pkg.g_log_level) THEN
      trace
           ( p_module   => l_log_module
            ,p_msg      => ''END '' || l_log_module
            ,p_level    => xla_cmp_tad_pkg.C_LEVEL_PROCEDURE);
   END IF;

END log_ccid_disabled_error;

FUNCTION log_ccid_not_found_error (
                      p_mode                   IN VARCHAR2
                     ,p_rowid                  IN UROWID
                     ,p_line_index             IN NUMBER
                     ,p_chart_of_accounts_name IN VARCHAR2
                     ,p_ccid                   IN NUMBER
                     ,p_calling_function_name  IN VARCHAR2
                     ,p_account_type_code      IN VARCHAR2
                    )
RETURN VARCHAR2
IS
   l_account_type_name VARCHAR2(80);
   l_log_module        VARCHAR2(2000);
BEGIN

   IF xla_cmp_tad_pkg.g_log_enabled THEN
      l_log_module := g_default_module||''.log_ccid_not_found_error'';
   END IF;

   IF (xla_cmp_tad_pkg.C_LEVEL_PROCEDURE >= xla_cmp_tad_pkg.g_log_level) THEN
      trace
           ( p_module   => l_log_module
            ,p_msg      => ''BEGIN '' || l_log_module
            ,p_level    => xla_cmp_tad_pkg.C_LEVEL_PROCEDURE);
   END IF;

   --Try to get the account type name
   BEGIN
      SELECT xtat.name
        INTO l_account_type_name
        FROM xla_tab_acct_types_tl xtat
       WHERE xtat.application_id    = $APPLICATION_ID_2$
         AND xtat.account_type_code = p_account_type_code;

   EXCEPTION
   --If unable to get the name use the account type code
   WHEN OTHERS
   THEN
      l_account_type_name := p_account_type_code;
   END;

   log_error (
                  p_mode           => p_mode
                 ,p_rowid          => p_rowid
                 ,p_line_index     => p_line_index
                 ,p_msg_name       => ''XLA_TAB_CCID_NOT_FOUND''
                 ,p_token_name_1   => ''TRX_ACCT_TYPE''
                 ,p_token_value_1  => l_account_type_name
                 ,p_token_name_2   => ''ACCOUNT_VALUE''
                 ,p_token_value_2  => p_ccid
                 ,p_token_name_3   => ''STRUCTURE_NAME''
                 ,p_token_value_3  => p_chart_of_accounts_name
                );

   RETURN NULL;

   IF (xla_cmp_tad_pkg.C_LEVEL_PROCEDURE >= xla_cmp_tad_pkg.g_log_level) THEN
      trace
           ( p_module   => l_log_module
            ,p_msg      => ''END '' || l_log_module
            ,p_level    => xla_cmp_tad_pkg.C_LEVEL_PROCEDURE);
   END IF;

END log_ccid_not_found_error;
'
;

C_TMPL_TAD_PACKAGE_BODY_PART_2  CONSTANT  CLOB :=
'
FUNCTION create_ccid (
                      p_mode                     IN VARCHAR2
                     ,p_rowid                    IN UROWID
                     ,p_line_index               IN NUMBER
                     ,p_chart_of_accounts_id     IN NUMBER
                     ,p_chart_of_accounts_name   IN VARCHAR2
                     ,p_calling_function_name    IN VARCHAR2
                     ,p_validation_date          IN DATE
                     ,p_concatenated_segments    IN VARCHAR2
                    )
RETURN NUMBER
IS
   l_code_combination_id    NUMBER;

   l_log_module             VARCHAR2(2000);
BEGIN

   IF xla_cmp_tad_pkg.g_log_enabled THEN
      l_log_module := g_default_module||''.create_ccid'';
   END IF;

   IF (xla_cmp_tad_pkg.C_LEVEL_PROCEDURE >= xla_cmp_tad_pkg.g_log_level) THEN
      trace
           ( p_module   => l_log_module
            ,p_msg      => ''BEGIN '' || l_log_module
            ,p_level    => xla_cmp_tad_pkg.C_LEVEL_PROCEDURE);
   END IF;

   l_code_combination_id := fnd_flex_ext.get_ccid
      (
        application_short_name => ''SQLGL''
       ,key_flex_code          => ''GL#''
       ,structure_number       => p_chart_of_accounts_id
       ,validation_date        => TO_CHAR(p_validation_date, ''YYYY/MM/DD HH24:MI:SS'')
       ,concatenated_segments  => p_concatenated_segments
      );

   IF l_code_combination_id > 0
   THEN
      INSERT
        INTO XLA_TAB_NEW_CCIDS_GT
       ( code_combination_id
        ,base_rowid
        ,concatenated_segments
        ,msg_data
       )
       VALUES
       ( l_code_combination_id
        ,p_rowid
        ,p_concatenated_segments
        ,NULL
       );
   ELSE
      --If 0 is returned there must be a message on the stack
      DECLARE
         l_message_text    VARCHAR2(2000);
         l_encoded_message VARCHAR2(2000);
      BEGIN
         l_code_combination_id := NULL;
         --Get the flex message text
         l_message_text     := FND_MESSAGE.GET();

         --Set the TAB message onto the message stack
         FND_MESSAGE.SET_NAME
            (
              application => ''XLA''
             ,name        => ''XLA_TAB_CCID_COULD_NOT_CREATE''
            );
         --Replace the token for the flex message retrieved above
         FND_MESSAGE.SET_TOKEN ( token => ''ERROR''
                                   ,value => l_message_text
                                  );
         --Replace the function name token
         FND_MESSAGE.SET_TOKEN ( token => ''FUNCTION_NAME''
                                   ,value => p_calling_function_name
                                  );
         --Get the resulting encoded message
         l_encoded_message     := FND_MESSAGE.GET_ENCODED();

         --Log the error for the current line
         log_error (
                  p_mode            => p_mode
                 ,p_rowid           => p_rowid
                 ,p_line_index      => p_line_index
                 ,p_encoded_message => l_encoded_message
                );

         --Create a record in the new ccid temp table
         INSERT
           INTO XLA_TAB_NEW_CCIDS_GT
                  ( code_combination_id
                   ,base_rowid
                   ,concatenated_segments
                   ,msg_data
                  )
         VALUES
                  ( l_code_combination_id
                   ,p_rowid
                   ,p_concatenated_segments
                   ,l_encoded_message
                  );
      END;
   END IF;

   --Assign return values
   RETURN l_code_combination_id;

   IF (xla_cmp_tad_pkg.C_LEVEL_PROCEDURE >= xla_cmp_tad_pkg.g_log_level) THEN
      trace
           ( p_module   => l_log_module
            ,p_msg      => ''END '' || l_log_module
            ,p_level    => xla_cmp_tad_pkg.C_LEVEL_PROCEDURE);
   END IF;

END create_ccid;


FUNCTION get_coa_info
   (
     p_chart_of_accounts_id         IN         NUMBER
    ,p_chart_of_accounts_name       OUT NOCOPY VARCHAR2
    ,p_flex_delimiter               OUT NOCOPY VARCHAR2
    ,p_concat_segments_template     OUT NOCOPY VARCHAR2
    ,p_gl_balancing_segment_name    OUT NOCOPY VARCHAR2
    ,p_gl_account_segment_name      OUT NOCOPY VARCHAR2
    ,p_gl_intercompany_segment_name OUT NOCOPY VARCHAR2
    ,p_gl_management_segment_name   OUT NOCOPY VARCHAR2
    ,p_fa_cost_ctr_segment_name     OUT NOCOPY VARCHAR2
    ,p_table_segment_qualifiers     OUT NOCOPY xla_cmp_tad_pkg.gt_table_V30_V30
    ,p_table_segment_column_names   OUT NOCOPY xla_cmp_tad_pkg.gt_table_V30
   )
RETURN BOOLEAN
IS
le_fatal_error               EXCEPTION;

TYPE lt_table_v30            IS TABLE OF VARCHAR2(30);

--Local vars for OUT params
l_chart_of_accounts_name       VARCHAR2(80);
l_flex_delimiter               VARCHAR2(1);
l_concat_segments_template     VARCHAR2(2000);
l_gl_balancing_segment_name    VARCHAR2(30);
l_gl_account_segment_name      VARCHAR2(30);
l_gl_intercompany_segment_name VARCHAR2(30);
l_gl_management_segment_name   VARCHAR2(30);
l_fa_cost_ctr_segment_name     VARCHAR2(30);
l_table_segment_qualifiers     xla_cmp_tad_pkg.gt_table_V30_V30;
l_table_segment_column_names   xla_cmp_tad_pkg.gt_table_v30;

--Ancillary local vars
l_table_qualifier_names        lt_table_v30;
l_account_segment_column       VARCHAR2(30);
l_return_value                 BOOLEAN;
l_fatal_error_message          VARCHAR2(2000);
l_log_module                   VARCHAR2(2000);
BEGIN
   IF xla_cmp_tad_pkg.g_log_enabled THEN
      l_log_module := g_default_module||''.get_coa_info'';
   END IF;

   IF (xla_cmp_tad_pkg.C_LEVEL_PROCEDURE >= xla_cmp_tad_pkg.g_log_level) THEN
      trace
           ( p_module   => l_log_module
            ,p_msg      => ''BEGIN '' || l_log_module
            ,p_level    => xla_cmp_tad_pkg.C_LEVEL_PROCEDURE);
   END IF;

   l_return_value := TRUE;

   --Get the Chart Of Accounts name
   SELECT id_flex_structure_name
     INTO l_chart_of_accounts_name
     FROM fnd_id_flex_structures_vl ffsvl
    WHERE ffsvl.application_id = 101
      AND ffsvl.id_flex_code   = ''GL#''
      AND ffsvl.id_flex_num    = p_chart_of_accounts_id;

   --Initialize the segment qualifier name list
   l_table_qualifier_names := lt_table_v30
                                 ( ''GL_BALANCING''
                                  ,''GL_ACCOUNT''
                                  ,''GL_INTERCOMPANY''
                                  ,''GL_MANAGEMENT''
                                  ,''FA_COST_CTR''
                                 );

   --For each qualifier (if assigned) we want the segment column name
   FOR i IN l_table_qualifier_names.FIRST .. l_table_qualifier_names.LAST
   LOOP
      IF FND_FLEX_APIS.get_segment_column( 101
                                          ,''GL#''
                                          ,p_chart_of_accounts_id
                                          ,l_table_qualifier_names(i)
                                          ,l_account_segment_column
                                         )
      THEN
         l_table_segment_qualifiers(l_table_qualifier_names(i)) := l_account_segment_column;
      END IF;
   END LOOP;

   --There are explicit out params for each segment qualifiers

   --Retrieve the balancing segment qualifier column name
   BEGIN
      l_gl_balancing_segment_name    := l_table_segment_qualifiers(''GL_BALANCING'');
   EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
      IF (xla_cmp_tad_pkg.C_LEVEL_EXCEPTION >= xla_cmp_tad_pkg.g_log_level)
      THEN
         trace
            ( p_module   => l_log_module
             ,p_msg      => ''No balancing segment qualifier for COA:''
                            || p_chart_of_accounts_id
             ,p_level    => xla_cmp_tad_pkg.C_LEVEL_EXCEPTION);
      END IF;
      fnd_message.set_name
         (
           application => ''XLA''
          ,name        => ''XLA_TAB_CANNOT_FIND_QUALIFIER''
         );
      fnd_message.set_token
         (
           token => ''QUALIFIER_NAME''
          ,value => ''GL_BALANCING''
         );
      fnd_message.set_token
         (
           token => ''STRUCTURE_NAME''
          ,value => l_chart_of_accounts_name
         );
      fnd_msg_pub.add;
      RAISE le_fatal_error;
   END;

   --Retrieve the natural account segment qualifier column name
   BEGIN
      l_gl_account_segment_name      := l_table_segment_qualifiers(''GL_ACCOUNT'');
   EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
      IF (xla_cmp_tad_pkg.C_LEVEL_EXCEPTION >= xla_cmp_tad_pkg.g_log_level)
      THEN
         trace
            ( p_module   => l_log_module
             ,p_msg      => ''No account segment qualifier for COA:''
                            || p_chart_of_accounts_id
             ,p_level    => xla_cmp_tad_pkg.C_LEVEL_EXCEPTION);
      END IF;
      fnd_message.set_name
         (
           application => ''XLA''
          ,name        => ''XLA_TAB_CANNOT_FIND_QUALIFIER''
         );
      fnd_message.set_token
         (
           token => ''QUALIFIER_NAME''
          ,value => ''GL_ACCOUNT''
         );
      fnd_message.set_token
         (
           token => ''STRUCTURE_NAME''
          ,value => l_chart_of_accounts_name
         );
      fnd_msg_pub.add;
      RAISE le_fatal_error;
   END;

   --Retrieve the intercompany segment qualifier column name
   BEGIN
      l_gl_intercompany_segment_name := l_table_segment_qualifiers(''GL_INTERCOMPANY'');
   EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
      NULL;
   END;


   --Retrieve the manegement segment qualifier column name
   BEGIN
      l_gl_management_segment_name   := l_table_segment_qualifiers(''GL_MANAGEMENT'');
   EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
      NULL;
   END;

   --Retrieve the cost center segment qualifier column name
   BEGIN
      l_fa_cost_ctr_segment_name     := l_table_segment_qualifiers(''FA_COST_CTR'');
   EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
      NULL;
   END;

   l_flex_delimiter := FND_FLEX_EXT.get_delimiter
                   (
                     application_short_name => ''SQLGL''
                    ,key_flex_code          => ''GL#''
                    ,structure_number       => p_chart_of_accounts_id
                   );
   IF l_flex_delimiter IS NULL
   THEN
      IF (xla_cmp_tad_pkg.C_LEVEL_EXCEPTION >= xla_cmp_tad_pkg.g_log_level) THEN
         trace
            ( p_module   => l_log_module
             ,p_msg      => ''EXCEPTION:''
             ,p_level    => xla_cmp_tad_pkg.C_LEVEL_EXCEPTION);
         trace
            ( p_module   => l_log_module
             ,p_msg      => ''get_delimiter failed''
             ,p_level    => xla_cmp_tad_pkg.C_LEVEL_EXCEPTION);
      END IF;
      --The error has been placed on the stack
      RAISE le_fatal_error;
   END IF;


   SELECT UPPER(fifs.application_column_name)
   BULK COLLECT
     INTO l_table_segment_column_names
     FROM fnd_id_flex_segments fifs
    WHERE fifs.application_id           =  101
      AND fifs.id_flex_code             = ''GL#''
      AND fifs.id_flex_num              = p_chart_of_accounts_id
      AND fifs.enabled_flag             = ''Y''
  ORDER BY fifs.segment_num;

   l_concat_segments_template := NULL;

   IF l_table_segment_column_names.COUNT > 0
   THEN
      FOR i IN 1..l_table_segment_column_names.COUNT
      LOOP
         l_concat_segments_template := l_concat_segments_template
                                       || CASE i
                                          WHEN 1 THEN NULL
                                          ELSE l_flex_delimiter
                                          END
                                       || l_table_segment_column_names(i);
      END LOOP;
   END IF;

   --Assign out parameters
   p_chart_of_accounts_name       := l_chart_of_accounts_name;
   p_flex_delimiter               := l_flex_delimiter;
   p_concat_segments_template     := l_concat_segments_template;
   p_gl_balancing_segment_name    := l_gl_balancing_segment_name;
   p_gl_account_segment_name      := l_gl_account_segment_name;
   p_gl_intercompany_segment_name := l_gl_intercompany_segment_name;
   p_gl_management_segment_name   := l_gl_management_segment_name;
   p_fa_cost_ctr_segment_name     := l_fa_cost_ctr_segment_name;
   p_table_segment_qualifiers     := l_table_segment_qualifiers;
   p_table_segment_column_names   := l_table_segment_column_names;

   IF (xla_cmp_tad_pkg.C_LEVEL_PROCEDURE >= xla_cmp_tad_pkg.g_log_level) THEN
      trace
           ( p_module   => l_log_module
            ,p_msg      => ''END '' || l_log_module
            ,p_level    => xla_cmp_tad_pkg.C_LEVEL_PROCEDURE);
   END IF;

   RETURN l_return_value;

EXCEPTION
WHEN le_fatal_error
THEN
   IF (xla_cmp_tad_pkg.C_LEVEL_EXCEPTION >= xla_cmp_tad_pkg.g_log_level) THEN
      trace
            ( p_module   => l_log_module
             ,p_msg      => ''EXCEPTION:''
             ,p_level    => xla_cmp_tad_pkg.C_LEVEL_EXCEPTION);
      trace
            ( p_module   => l_log_module
             ,p_msg      => ''Fatal error: '' || l_fatal_error_message
             ,p_level    => xla_cmp_tad_pkg.C_LEVEL_EXCEPTION);
   END IF;
   RETURN FALSE;
WHEN OTHERS
THEN
   IF (xla_cmp_tad_pkg.C_LEVEL_EXCEPTION >= xla_cmp_tad_pkg.g_log_level) THEN
      trace
            ( p_module   => l_log_module
             ,p_msg      => ''EXCEPTION:''
             ,p_level    => xla_cmp_tad_pkg.C_LEVEL_EXCEPTION);
      trace
            ( p_module   => l_log_module
             ,p_msg      => ''Error: '' || SQLERRM
             ,p_level    => xla_cmp_tad_pkg.C_LEVEL_EXCEPTION);
   END IF;
   RETURN FALSE;
END get_coa_info;


FUNCTION get_flexfield_segment
   (
     p_mode                            IN VARCHAR2
    ,p_rowid                           IN UROWID
    ,p_line_index                      IN NUMBER
    ,p_chart_of_accounts_id            IN NUMBER
    ,p_chart_of_accounts_name          IN VARCHAR2
    ,p_ccid                            IN NUMBER
    ,p_source_code                     IN VARCHAR2
    ,p_source_type_code                IN VARCHAR2
    ,p_source_application_id           IN NUMBER
    ,p_segment_name                    IN VARCHAR2
    ,p_gl_balancing_segment_name       IN VARCHAR2
    ,p_gl_account_segment_name         IN VARCHAR2
    ,p_gl_intercompany_segment_name    IN VARCHAR2
    ,p_gl_management_segment_name      IN VARCHAR2
    ,p_fa_cost_ctr_segment_name        IN VARCHAR2
    ,p_adr_name                        IN VARCHAR2
   )
RETURN VARCHAR2
IS
le_fatal_error        EXCEPTION;

l_segment_name        VARCHAR2(30);
l_value_segment1      VARCHAR2(25);
l_value_segment2      VARCHAR2(25);
l_value_segment3      VARCHAR2(25);
l_value_segment4      VARCHAR2(25);
l_value_segment5      VARCHAR2(25);
l_value_segment6      VARCHAR2(25);
l_value_segment7      VARCHAR2(25);
l_value_segment8      VARCHAR2(25);
l_value_segment9      VARCHAR2(25);
l_value_segment10     VARCHAR2(25);
l_value_segment11     VARCHAR2(25);
l_value_segment12     VARCHAR2(25);
l_value_segment13     VARCHAR2(25);
l_value_segment14     VARCHAR2(25);
l_value_segment15     VARCHAR2(25);
l_value_segment16     VARCHAR2(25);
l_value_segment17     VARCHAR2(25);
l_value_segment18     VARCHAR2(25);
l_value_segment19     VARCHAR2(25);
l_value_segment20     VARCHAR2(25);
l_value_segment21     VARCHAR2(25);
l_value_segment22     VARCHAR2(25);
l_value_segment23     VARCHAR2(25);
l_value_segment24     VARCHAR2(25);
l_value_segment25     VARCHAR2(25);
l_value_segment26     VARCHAR2(25);
l_value_segment27     VARCHAR2(25);
l_value_segment28     VARCHAR2(25);
l_value_segment29     VARCHAR2(25);
l_value_segment30     VARCHAR2(25);
l_return_value        VARCHAR2(25);

l_source_name         VARCHAR2(80);
l_fatal_error_message VARCHAR2(2000);
l_log_module          VARCHAR2(2000);
BEGIN
   IF xla_cmp_tad_pkg.g_log_enabled THEN
      l_log_module := g_default_module||''.get_flexfield_segment'';
   END IF;

   IF (xla_cmp_tad_pkg.C_LEVEL_PROCEDURE >= xla_cmp_tad_pkg.g_log_level) THEN
      trace
           ( p_module   => l_log_module
            ,p_msg      => ''BEGIN '' || l_log_module
            ,p_level    => xla_cmp_tad_pkg.C_LEVEL_PROCEDURE);
   END IF;

   IF p_ccid IS NULL
   THEN
      SELECT name
        INTO l_source_name
        FROM xla_sources_vl xsv
       WHERE xsv.source_code      = p_source_code
         AND xsv.source_type_code = p_source_type_code
         AND xsv.application_id   = p_source_application_id;

      log_error (
                  p_mode           => ''BATCH''
                 ,p_rowid          => p_rowid
                 ,p_line_index     => NULL
                 ,p_msg_name       => ''XLA_TAB_GET_SEG_CCID_IS_NULL''
                 ,p_token_name_1   => ''SEGMENT_NAME''
                 ,p_token_value_1  => p_segment_name
                 ,p_token_name_2   => ''SOURCE_NAME''
                 ,p_token_value_2  => l_source_name
                 ,p_token_name_3   => ''SEGMENT_RULE_NAME''
                 ,p_token_value_3  => p_adr_name
                );

      RAISE le_fatal_error;
   END IF;

   BEGIN
        SELECT
          gcc.segment1
        , gcc.segment2
        , gcc.segment3
        , gcc.segment4
        , gcc.segment5
        , gcc.segment6
        , gcc.segment7
        , gcc.segment8
        , gcc.segment9
        , gcc.segment10
        , gcc.segment11
        , gcc.segment12
        , gcc.segment13
        , gcc.segment14
        , gcc.segment15
        , gcc.segment16
        , gcc.segment17
        , gcc.segment18
        , gcc.segment19
        , gcc.segment20
        , gcc.segment21
        , gcc.segment22
        , gcc.segment23
        , gcc.segment24
        , gcc.segment25
        , gcc.segment26
        , gcc.segment27
        , gcc.segment28
        , gcc.segment29
        , gcc.segment30
      INTO
          l_value_segment1
         ,l_value_segment2
         ,l_value_segment3
         ,l_value_segment4
         ,l_value_segment5
         ,l_value_segment6
         ,l_value_segment7
         ,l_value_segment8
         ,l_value_segment9
         ,l_value_segment10
         ,l_value_segment11
         ,l_value_segment12
         ,l_value_segment13
         ,l_value_segment14
         ,l_value_segment15
         ,l_value_segment16
         ,l_value_segment17
         ,l_value_segment18
         ,l_value_segment19
         ,l_value_segment20
         ,l_value_segment21
         ,l_value_segment22
         ,l_value_segment23
         ,l_value_segment24
         ,l_value_segment25
         ,l_value_segment26
         ,l_value_segment27
         ,l_value_segment28
         ,l_value_segment29
         ,l_value_segment30
      FROM gl_code_combinations   gcc
     WHERE gcc.code_combination_id  = p_ccid
       AND gcc.chart_of_accounts_id = p_chart_of_accounts_id
       AND gcc.template_id          IS NULL
       AND gcc.enabled_flag         = ''Y'';
   EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
      SELECT name
        INTO l_source_name
        FROM xla_sources_vl xsv
       WHERE xsv.source_code      = p_source_code
         AND xsv.source_type_code = p_source_type_code
         AND xsv.application_id   = p_source_application_id;

      log_error (
                  p_mode           => ''BATCH''
                 ,p_rowid          => p_rowid
                 ,p_line_index     => NULL
                 ,p_msg_name       => ''XLA_TAB_GET_SEG_CCID_NOT_FOUND''
                 ,p_token_name_1   => ''ACCOUNT_VALUE''
                 ,p_token_value_1  => p_ccid
                 ,p_token_name_2   => ''SOURCE_NAME''
                 ,p_token_value_2  => l_source_name
                 ,p_token_name_3   => ''STRUCTURE_NAME''
                 ,p_token_value_3  => p_chart_of_accounts_name
                 ,p_token_name_4   => ''SEGMENT_RULE_NAME''
                 ,p_token_value_4  => p_adr_name
                );
      RAISE le_fatal_error;
   END;

   --The segment name might be a segment qualifier name
   CASE p_segment_name
   WHEN ''GL_BALANCING''
      THEN l_segment_name := p_gl_balancing_segment_name;
   WHEN ''GL_ACCOUNT''
      THEN l_segment_name := p_gl_account_segment_name;
   WHEN ''GL_INTERCOMPANY''
      THEN l_segment_name := p_gl_intercompany_segment_name;
   WHEN ''GL_MANAGEMENT''
      THEN l_segment_name := p_gl_management_segment_name;
   WHEN ''FA_COST_CTR''
      THEN l_segment_name := p_fa_cost_ctr_segment_name;
   ELSE
           l_segment_name := p_segment_name;
   END CASE;

   CASE l_segment_name
   WHEN ''SEGMENT1''
      THEN l_return_value := l_value_segment1;
   WHEN ''SEGMENT2''
      THEN l_return_value := l_value_segment2;
   WHEN ''SEGMENT3''
      THEN l_return_value := l_value_segment3;
   WHEN ''SEGMENT4''
      THEN l_return_value := l_value_segment4;
   WHEN ''SEGMENT5''
      THEN l_return_value := l_value_segment5;
   WHEN ''SEGMENT6''
      THEN l_return_value := l_value_segment6;
   WHEN ''SEGMENT7''
      THEN l_return_value := l_value_segment7;
   WHEN ''SEGMENT8''
      THEN l_return_value := l_value_segment8;
   WHEN ''SEGMENT9''
      THEN l_return_value := l_value_segment9;
   WHEN ''SEGMENT10''
      THEN l_return_value := l_value_segment10;
   WHEN ''SEGMENT11''
      THEN l_return_value := l_value_segment11;
   WHEN ''SEGMENT12''
      THEN l_return_value := l_value_segment12;
   WHEN ''SEGMENT13''
      THEN l_return_value := l_value_segment13;
   WHEN ''SEGMENT14''
      THEN l_return_value := l_value_segment14;
   WHEN ''SEGMENT15''
      THEN l_return_value := l_value_segment15;
   WHEN ''SEGMENT16''
      THEN l_return_value := l_value_segment16;
   WHEN ''SEGMENT17''
      THEN l_return_value := l_value_segment17;
   WHEN ''SEGMENT18''
      THEN l_return_value := l_value_segment18;
   WHEN ''SEGMENT19''
      THEN l_return_value := l_value_segment19;
   WHEN ''SEGMENT20''
      THEN l_return_value := l_value_segment20;
   WHEN ''SEGMENT21''
      THEN l_return_value := l_value_segment21;
   WHEN ''SEGMENT22''
      THEN l_return_value := l_value_segment22;
   WHEN ''SEGMENT23''
      THEN l_return_value := l_value_segment23;
   WHEN ''SEGMENT24''
      THEN l_return_value := l_value_segment24;
   WHEN ''SEGMENT25''
      THEN l_return_value := l_value_segment25;
   WHEN ''SEGMENT26''
      THEN l_return_value := l_value_segment26;
   WHEN ''SEGMENT27''
      THEN l_return_value := l_value_segment27;
   WHEN ''SEGMENT28''
      THEN l_return_value := l_value_segment28;
   WHEN ''SEGMENT29''
      THEN l_return_value := l_value_segment29;
   WHEN ''SEGMENT30''
      THEN l_return_value := l_value_segment30;
   ELSE
      --The segment name is invalid
      log_error (
                  p_mode           => ''BATCH''
                 ,p_rowid          => p_rowid
                 ,p_line_index     => NULL
                 ,p_msg_name       => ''XLA_TAB_GET_SEG_INVLD_SEG_NAME''
                 ,p_token_name_1   => ''FUNCTION_NAME''
                 ,p_token_value_1  => ''$TAD_PACKAGE_NAME_3$.get_flexfield_segment''
                 ,p_token_name_2   => ''SEGMENT_NAME''
                 ,p_token_value_2  => p_segment_name
                 ,p_token_name_3   => ''STRUCTURE_NAME''
                 ,p_token_value_3  => p_chart_of_accounts_name
                 ,p_token_name_4   => ''SEGMENT_RULE_NAME''
                 ,p_token_value_4  => p_adr_name
                );

      RAISE le_fatal_error;

   END CASE;

   RETURN l_return_value;

   IF (xla_cmp_tad_pkg.C_LEVEL_PROCEDURE >= xla_cmp_tad_pkg.g_log_level) THEN
         trace
           ( p_module   => l_log_module
            ,p_msg      => ''END '' || l_log_module
            ,p_level    => xla_cmp_tad_pkg.C_LEVEL_PROCEDURE);
   END IF;

EXCEPTION
WHEN le_fatal_error
THEN
   IF (xla_cmp_tad_pkg.C_LEVEL_EXCEPTION >= xla_cmp_tad_pkg.g_log_level) THEN
      trace
            ( p_module   => l_log_module
             ,p_msg      => ''EXCEPTION:''
             ,p_level    => xla_cmp_tad_pkg.C_LEVEL_EXCEPTION);
      trace
            ( p_module   => l_log_module
             ,p_msg      => ''Fatal error: '' || l_fatal_error_message
             ,p_level    => xla_cmp_tad_pkg.C_LEVEL_EXCEPTION);
   END IF;
   RAISE;
WHEN OTHERS THEN
   log_error (
                  p_mode           => ''BATCH''
                 ,p_rowid          => p_rowid
                 ,p_line_index     => NULL
                 ,p_msg_name       => ''XLA_TAB_ADR_GENERIC_EXCEPTION''
                 ,p_token_name_1   => ''FUNCTION_NAME''
                 ,p_token_value_1  => ''$TAD_PACKAGE_NAME_3$.get_flexfield_segment''
                 ,p_token_name_2   => ''ERROR''
                 ,p_token_value_2  => SQLERRM
                 ,p_token_name_3   => ''SEGMENT_RULE_NAME''
                 ,p_token_value_3  => p_adr_name
                );
   RAISE;
END get_flexfield_segment;


$TAD_ADR_FUNCT_BODIES$
';

C_TMPL_TAD_PACKAGE_BODY_PART_3  CONSTANT  CLOB :=
'
FUNCTION apply_adr_rules
   (
     p_chart_of_accounts_id         IN         NUMBER
    ,p_chart_of_accounts_name       IN         VARCHAR2
    ,p_flex_delimiter               IN         VARCHAR2
    ,p_concat_segments_template     IN         VARCHAR2
    ,p_table_segment_qualifiers     IN         xla_cmp_tad_pkg.gt_table_V30_V30
    ,p_table_segment_column_names   IN         xla_cmp_tad_pkg.gt_table_V30
    ,p_gl_balancing_segment_name    IN         VARCHAR2
    ,p_gl_account_segment_name      IN         VARCHAR2
    ,p_gl_intercompany_segment_name IN         VARCHAR2
    ,p_gl_management_segment_name   IN         VARCHAR2
    ,p_fa_cost_ctr_segment_name     IN         VARCHAR2
   )
RETURN BOOLEAN
IS
le_fatal_error               EXCEPTION;

l_current_date               DATE      := TRUNC(SYSDATE);

l_return_value               BOOLEAN;
l_fatal_error_message        VARCHAR2(2000);
l_log_module                 VARCHAR2(2000);
BEGIN
   IF xla_cmp_tad_pkg.g_log_enabled THEN
      l_log_module := g_default_module||''.apply_adr_rules'';
   END IF;

   IF (xla_cmp_tad_pkg.C_LEVEL_PROCEDURE >= xla_cmp_tad_pkg.g_log_level) THEN
      trace
           ( p_module   => l_log_module
            ,p_msg      => ''BEGIN '' || l_log_module
            ,p_level    => xla_cmp_tad_pkg.C_LEVEL_PROCEDURE);
   END IF;

$C_TMPL_BATCH_CCID_SEG_UPD_STMTS$

   l_return_value := TRUE;

   IF (xla_cmp_tad_pkg.C_LEVEL_PROCEDURE >= xla_cmp_tad_pkg.g_log_level) THEN
      trace
           ( p_module   => l_log_module
            ,p_msg      => ''END '' || l_log_module
            ,p_level    => xla_cmp_tad_pkg.C_LEVEL_PROCEDURE);
   END IF;

   RETURN l_return_value;

EXCEPTION
WHEN OTHERS
THEN
   IF (xla_cmp_tad_pkg.C_LEVEL_EXCEPTION >= xla_cmp_tad_pkg.g_log_level)
   THEN
      trace
               ( p_module   => l_log_module
                ,p_msg      => ''apply_adr_rules failed with the error:''
                ,p_level    => xla_cmp_tad_pkg.C_LEVEL_EXCEPTION);
      trace
               ( p_module   => l_log_module
                ,p_msg      => SQLERRM
                ,p_level    => xla_cmp_tad_pkg.C_LEVEL_EXCEPTION);
   END IF;
   fnd_message.set_name
            (
              application => ''XLA''
             ,name        => ''XLA_TAB_CANNOT_APPLY_ADR_RULES''
            );
   fnd_message.set_token
            (
              token => ''FUNCTION_NAME''
             ,value => ''$TAD_PACKAGE_NAME_3$.apply_adr_rules''
            );
   fnd_message.set_token
            (
              token => ''ERROR''
             ,value => SQLERRM
            );
   fnd_msg_pub.add;
   RETURN FALSE;
END apply_adr_rules;

FUNCTION build_code_combinations_dyn
   (
     p_chart_of_accounts_id         IN         NUMBER
    ,p_chart_of_accounts_name       IN         VARCHAR2
    ,p_flex_delimiter               IN         VARCHAR2
    ,p_concat_segments_template     IN         VARCHAR2
    ,p_table_segment_qualifiers     IN         xla_cmp_tad_pkg.gt_table_V30_V30
    ,p_table_segment_column_names   IN         xla_cmp_tad_pkg.gt_table_V30
    ,p_gl_balancing_segment_name    IN         VARCHAR2
    ,p_gl_account_segment_name      IN         VARCHAR2
    ,p_gl_intercompany_segment_name IN         VARCHAR2
    ,p_gl_management_segment_name   IN         VARCHAR2
    ,p_fa_cost_ctr_segment_name     IN         VARCHAR2
   )
RETURN BOOLEAN
IS
le_fatal_error               EXCEPTION;
TYPE lt_rec_tad_details IS RECORD
   (
      application_id          NUMBER
     ,amb_context_code        VARCHAR2(30)
     ,account_type_code       VARCHAR2(30)
     ,flexfield_segment_code  VARCHAR2(30)
     ,segment_rule_type_code  VARCHAR2(1)
     ,segment_rule_code       VARCHAR2(30)
     ,object_name_affix       VARCHAR2(10)
     ,tat_compile_status_code VARCHAR2(1)
     ,rule_assignment_code    VARCHAR2(30)
     ,adr_id                  NUMBER
   );

TYPE lt_table_of_tad_details IS TABLE OF lt_rec_tad_details
                                   INDEX BY BINARY_INTEGER;

l_table_of_tad_details     lt_table_of_tad_details;

l_update_statement_text        CLOB;
l_update_statements_text       CLOB;

l_tmpl_where_segment_null_and  CLOB;
l_tmpl_where_segment_null_ands CLOB;
l_tmpl_where_segment_null_or   CLOB;
l_tmpl_where_segment_null_ors  CLOB;
l_tmpl_upd_set_segment_comma   CLOB;
l_tmpl_upd_set_segment_commas  CLOB;
l_tmpl_sel_nvl_segment_comma   CLOB;
l_tmpl_sel_nvl_segment_commas  CLOB;
l_tmpl_where_segments_equal    CLOB;
l_tmpl_where_segments_equals   CLOB;
l_tmpl_concat_segments         CLOB;

l_update_stmts_wrapper_text    CLOB;

l_current_object_name_affix    VARCHAR2(10);
l_current_temp_table_name      VARCHAR2(30);
l_dummy                        VARCHAR2(30);

l_current_date               DATE      := TRUNC(SYSDATE);

l_return_value               BOOLEAN;
l_fatal_error_message        VARCHAR2(2000);
l_log_module                 VARCHAR2(2000);
BEGIN
   IF xla_cmp_tad_pkg.g_log_enabled THEN
      l_log_module := g_default_module||''.build_code_combinations_dyn'';
   END IF;

   IF (xla_cmp_tad_pkg.C_LEVEL_PROCEDURE >= xla_cmp_tad_pkg.g_log_level) THEN
      trace
           ( p_module   => l_log_module
            ,p_msg      => ''BEGIN '' || l_log_module
            ,p_level    => xla_cmp_tad_pkg.C_LEVEL_PROCEDURE);
   END IF;

   IF p_chart_of_accounts_id IS NULL
   THEN
      l_fatal_error_message
:= ''build_code_combinations_dyn:  p_chart_of_accounts_id cannot be null.'';
      RAISE le_fatal_error;
   END IF;

   --Build the common token values
   FOR i IN p_table_segment_column_names.FIRST..p_table_segment_column_names.LAST
   LOOP
      --C_TMPL_WHERE_SEGMENT_NULL_ANDS
      l_tmpl_where_segment_null_and := xla_cmp_string_pkg.replace_token
                                          ( ''
    AND gt.$SEGMENT_COLUMN_NAME$ IS NULL ''
                                           ,''$SEGMENT_COLUMN_NAME$''
                                           ,p_table_segment_column_names(i)
                                          );
      l_tmpl_where_segment_null_ands :=   l_tmpl_where_segment_null_ands
                                       || l_tmpl_where_segment_null_and;


      --C_TMPL_WHERE_SEGMENT_NULL_ORS

      l_tmpl_where_segment_null_or := CASE i
                                      WHEN 1 THEN ''   ''
                                      ELSE ''        OR ''
                                      END
                                      ||
                                      xla_cmp_string_pkg.replace_token
                                         ( '' gt.$SEGMENT_COLUMN_NAME$ IS NULL
''
                                          ,''$SEGMENT_COLUMN_NAME$''
                                          ,p_table_segment_column_names(i)
                                         );

      l_tmpl_where_segment_null_ors :=   l_tmpl_where_segment_null_ors
                                       || l_tmpl_where_segment_null_or;

      --C_TMPL_UPD_SET_SEGMENT_COMMA
      l_tmpl_upd_set_segment_comma  := CASE i
                                      WHEN 1 THEN ''             ''
                                      ELSE ''            ,''
                                      END
                                      ||
                                      xla_cmp_string_pkg.replace_token
                                         ( '' gt.$SEGMENT_COLUMN_NAME$
''
                                          ,''$SEGMENT_COLUMN_NAME$''
                                          ,p_table_segment_column_names(i)
                                         );

      l_tmpl_upd_set_segment_commas :=   l_tmpl_upd_set_segment_commas
                                       || l_tmpl_upd_set_segment_comma;

      --C_TMPL_SEL_NVL_SEGMENT_COMMA
      l_tmpl_sel_nvl_segment_comma  := CASE i
                                      WHEN 1 THEN ''                ''
                                      ELSE ''               ,''
                                      END
                                      ||
                                      xla_cmp_string_pkg.replace_token
                                         ( '' NVL(gt.$SEGMENT_COLUMN_NAME$, gcc.$SEGMENT_COLUMN_NAME$)
''
                                          ,''$SEGMENT_COLUMN_NAME$''
                                          ,p_table_segment_column_names(i)
                                         );

      l_tmpl_sel_nvl_segment_commas :=   l_tmpl_sel_nvl_segment_commas
                                       || l_tmpl_sel_nvl_segment_comma;

      --C_TMPL_WHERE_SEGMENTS_EQUAL
      l_tmpl_where_segments_equal := xla_cmp_string_pkg.replace_token
                                          ( ''                                AND gcc.$SEGMENT_COLUMN_NAME$ = gt.$SEGMENT_COLUMN_NAME$
''
                                           ,''$SEGMENT_COLUMN_NAME$''
                                           ,p_table_segment_column_names(i)
                                          );
      l_tmpl_where_segments_equals :=   l_tmpl_where_segments_equals
                                       || l_tmpl_where_segments_equal;

      IF i = 1
      THEN
         l_tmpl_concat_segments := ''             ''
                                   || p_table_segment_column_names(i);
      ELSE
         l_tmpl_concat_segments := l_tmpl_concat_segments
                                   || ''
''
                                   || ''             || '''''' || p_flex_delimiter || '''''' || ''
                                   || p_table_segment_column_names(i);
      END IF;

   END LOOP;

   --Read the TAD details and corresponding TAT affix
   SELECT xtdd.application_id
         ,xtdd.amb_context_code
         ,xtdd.account_type_code
         ,xtdd.flexfield_segment_code
         ,xtdd.segment_rule_type_code
         ,xtdd.segment_rule_code
         ,xtta.object_name_affix
         ,xtta.compile_status_code
         ,xtta.rule_assignment_code
         ,NULL
     BULK COLLECT
     INTO l_table_of_tad_details
     FROM xla_tab_acct_def_details xtdd
         ,xla_tab_acct_types_b     xtta
    WHERE xtdd.application_id               = $APPLICATION_ID_2$
      AND xtdd.account_definition_code      = ''$TAD_CODE_2$''
      AND xtdd.account_definition_type_code = ''$TAD_TYPE_CODE_2$''
      AND xtdd.amb_context_code             = ''$AMB_CONTEXT_CODE_2$''
      AND xtta.application_id               = xtdd.application_id
      AND xtta.account_type_code            = xtdd.account_type_code
   ORDER BY xtta.object_name_affix
           ,xtdd.flexfield_segment_code
           ,xtdd.account_type_code;

   l_current_object_name_affix := NULL;
   FOR i IN l_table_of_tad_details.FIRST .. l_table_of_tad_details.LAST
   LOOP
      --If it is the first detail
      --or the affix changes
      --we need a new update statement
      IF    (i = l_table_of_tad_details.FIRST)
         OR (   NVL(l_current_object_name_affix, ''a'')
             <> NVL(l_table_of_tad_details(i).object_name_affix, ''a'')
            )
      THEN
         --Concatenate the current upd statement to the existing ones
         l_update_statements_text    := l_update_statements_text || l_update_statement_text;

         --Null out the partial elements that have been consumed now
         l_update_statement_text     := NULL;

         --Retrieve the affix of the TAT associated to the current detail
         l_current_object_name_affix := l_table_of_tad_details(i).object_name_affix;

         --Get the global temporary table name for the affix
         IF NOT xla_cmp_tab_pkg.get_interface_object_names
            (
              p_application_id    => $APPLICATION_ID_2$
             ,p_object_name_affix => l_current_object_name_affix
             ,x_global_table_name => l_current_temp_table_name
             ,x_plsql_table_name  => l_dummy
            )
         THEN
            l_fatal_error_message  := ''get_interface_object_names failed'';
            RAISE le_fatal_error;
         END IF;

         --Get the update statement template
         l_update_statement_text     := g_batch_build_ccid_stmts;

         --Replace the table name token
         l_update_statement_text:= xla_cmp_string_pkg.replace_token(
                                   l_update_statement_text
                                  ,''$TABLE_NAME$''
                                  ,NVL(l_current_temp_table_name, '' '')
                                 );

         --Replace the common tokens
         l_update_statement_text:= xla_cmp_string_pkg.replace_token(
                                   l_update_statement_text
                                  ,''$C_TMPL_WHERE_SEGMENT_NULL_ANDS$''
                                  ,NVL(l_tmpl_where_segment_null_ands, '' '')
                                 );

         l_update_statement_text:= xla_cmp_string_pkg.replace_token(
                                   l_update_statement_text
                                  ,''$C_TMPL_WHERE_SEGMENT_NULL_ORS$''
                                  ,NVL(l_tmpl_where_segment_null_ors, '' '')
                                 );

         l_update_statement_text:= xla_cmp_string_pkg.replace_token(
                                   l_update_statement_text
                                  ,''$C_TMPL_UPD_SET_SEGMENT_COMMAS$''
                                  ,NVL(l_tmpl_upd_set_segment_commas, '' '')
                                 );

         l_update_statement_text:= xla_cmp_string_pkg.replace_token(
                                   l_update_statement_text
                                  ,''$C_TMPL_SEL_NVL_SEGMENT_COMMAS$''
                                  ,NVL(l_tmpl_sel_nvl_segment_commas, '' '')
                                 );

         l_update_statement_text:= xla_cmp_string_pkg.replace_token(
                                   l_update_statement_text
                                  ,''$C_TMPL_WHERE_SEGMENTS_EQUALS$''
                                  ,NVL(l_tmpl_where_segments_equals, '' '')
                                 );

         l_update_statement_text:= xla_cmp_string_pkg.replace_token(
                                   l_update_statement_text
                                  ,''$C_TMPL_CONCAT_SEGMENTS$''
                                  ,NVL(l_tmpl_concat_segments, '' '')
                                 );

      ELSE
         --No action required
         NULL;
      END IF; --new update statement
   END LOOP;

   --Concatenate the last processed statement
   l_update_statements_text := l_update_statements_text || l_update_statement_text;

   l_update_stmts_wrapper_text := ''
DECLARE
   l_chart_of_accounts_id         NUMBER
      := $TRANSACTION_COA_ID$;
   l_chart_of_accounts_name       VARCHAR2(80)
      := ''''$TRANSACTION_COA_NAME$'''';
   l_concat_segments_template     VARCHAR2(2000)
      := ''''$CONCAT_SEGMENTS_TEMPLATE$'''';

   PROCEDURE build_ccids_on_the_fly
   (
      p_chart_of_accounts_id         IN         NUMBER
     ,p_chart_of_accounts_name       IN         VARCHAR2
     ,p_concat_segments_template     IN         VARCHAR2
   )
   IS
   le_fatal_error               EXCEPTION;

   l_current_date               DATE      := TRUNC(SYSDATE);

   l_return_value               BOOLEAN;
   l_fatal_error_message        VARCHAR2(2000);

   BEGIN
$C_TMPL_BATCH_BUILD_CCID_SQL$
   END build_ccids_on_the_fly;
BEGIN
   build_ccids_on_the_fly
   (
      p_chart_of_accounts_id         => l_chart_of_accounts_id
     ,p_chart_of_accounts_name       => l_chart_of_accounts_name
     ,p_concat_segments_template     => l_concat_segments_template
   );

END;

'';

   --Replace the p_chart_of_accounts_id with :1
   l_update_stmts_wrapper_text:= xla_cmp_string_pkg.replace_token(
                                   l_update_stmts_wrapper_text
                                  ,''$TRANSACTION_COA_ID$''
                                  ,TO_CHAR(p_chart_of_accounts_id)
                                 );
   l_update_stmts_wrapper_text:= xla_cmp_string_pkg.replace_token(
                                   l_update_stmts_wrapper_text
                                  ,''$TRANSACTION_COA_NAME$''
                                  ,NVL(p_chart_of_accounts_name, '' '')
                                 );
   l_update_stmts_wrapper_text:= xla_cmp_string_pkg.replace_token(
                                   l_update_stmts_wrapper_text
                                  ,''$CONCAT_SEGMENTS_TEMPLATE$''
                                  ,NVL(p_concat_segments_template, '' '')
                                 );

   --Replace the update statements token
   l_update_stmts_wrapper_text := xla_cmp_string_pkg.replace_token
                                     ( l_update_stmts_wrapper_text
                                      ,''$C_TMPL_BATCH_BUILD_CCID_SQL$''
                                      ,l_update_statements_text
                                     );



   --Dump the dynamic statement
   IF (xla_cmp_tad_pkg.C_LEVEL_STATEMENT >= xla_cmp_tad_pkg.g_log_level)
   THEN
      xla_cmp_common_pkg.dump_text
                    (
                      p_text     => l_update_stmts_wrapper_text
                    );
   END IF;

   --Execute the dynamic statement
   IF NOT xla_cmp_create_pkg.execute_dml
               (
                 p_dml_text         => l_update_stmts_wrapper_text
                ,p_msg_mode         => xla_cmp_tad_pkg.G_OA_MESSAGE
               )
   THEN
      l_fatal_error_message  := ''xla_cmp_create_pkg.execute_dml failed'';
      RAISE le_fatal_error;
   END IF;

   l_return_value := TRUE;

   IF (xla_cmp_tad_pkg.C_LEVEL_PROCEDURE >= xla_cmp_tad_pkg.g_log_level) THEN
      trace
           ( p_module   => l_log_module
            ,p_msg      => ''END '' || l_log_module
            ,p_level    => xla_cmp_tad_pkg.C_LEVEL_PROCEDURE);
   END IF;

   RETURN l_return_value;

EXCEPTION
WHEN le_fatal_error
THEN
   IF (xla_cmp_tad_pkg.C_LEVEL_EXCEPTION >= xla_cmp_tad_pkg.g_log_level)
   THEN
      trace
               ( p_module   => l_log_module
                ,p_msg      => ''build_code_combinations_dyn failed with the error:''
                ,p_level    => xla_cmp_tad_pkg.C_LEVEL_EXCEPTION);
      trace
               ( p_module   => l_log_module
                ,p_msg      => SQLERRM
                ,p_level    => xla_cmp_tad_pkg.C_LEVEL_EXCEPTION);
   END IF;
   fnd_message.set_name
            (
              application => ''XLA''
             ,name        => ''XLA_TAB_FUN_GENERIC_EXCEPTION''
            );
   fnd_message.set_token
            (
              token => ''FUNCTION_NAME''
             ,value => ''$TAD_PACKAGE_NAME_3$.build_code_combinations_dyn''
            );
   fnd_message.set_token
            (
              token => ''ERROR''
             ,value => SQLERRM
            );
   fnd_msg_pub.add;
   RETURN FALSE;
WHEN OTHERS
THEN
   IF (xla_cmp_tad_pkg.C_LEVEL_EXCEPTION >= xla_cmp_tad_pkg.g_log_level)
   THEN
      trace
               ( p_module   => l_log_module
                ,p_msg      => ''build_code_combinations_dyn failed with the error:''
                ,p_level    => xla_cmp_tad_pkg.C_LEVEL_EXCEPTION);
      trace
               ( p_module   => l_log_module
                ,p_msg      => SQLERRM
                ,p_level    => xla_cmp_tad_pkg.C_LEVEL_EXCEPTION);
   END IF;
   fnd_message.set_name
            (
              application => ''XLA''
             ,name        => ''XLA_TAB_FUN_GENERIC_EXCEPTION''
            );
   fnd_message.set_token
            (
              token => ''FUNCTION_NAME''
             ,value => ''$TAD_PACKAGE_NAME_3$.build_code_combinations_dyn''
            );
   fnd_message.set_token
            (
              token => ''ERROR''
             ,value => SQLERRM
            );
   fnd_msg_pub.add;
   RETURN FALSE;
END build_code_combinations_dyn;
';

C_TMPL_TAD_PACKAGE_BODY_PART_4  CONSTANT  CLOB :=
'
FUNCTION build_code_combinations
   (
     p_chart_of_accounts_id         IN         NUMBER
    ,p_chart_of_accounts_name       IN         VARCHAR2
    ,p_flex_delimiter               IN         VARCHAR2
    ,p_concat_segments_template     IN         VARCHAR2
    ,p_table_segment_qualifiers     IN         xla_cmp_tad_pkg.gt_table_V30_V30
    ,p_table_segment_column_names   IN         xla_cmp_tad_pkg.gt_table_V30
    ,p_gl_balancing_segment_name    IN         VARCHAR2
    ,p_gl_account_segment_name      IN         VARCHAR2
    ,p_gl_intercompany_segment_name IN         VARCHAR2
    ,p_gl_management_segment_name   IN         VARCHAR2
    ,p_fa_cost_ctr_segment_name     IN         VARCHAR2
   )
RETURN BOOLEAN
IS
le_fatal_error               EXCEPTION;

l_current_date               DATE      := TRUNC(SYSDATE);

l_return_value               BOOLEAN;
l_fatal_error_message        VARCHAR2(2000);
l_log_module                 VARCHAR2(2000);
BEGIN
   IF xla_cmp_tad_pkg.g_log_enabled THEN
      l_log_module := g_default_module||''.build_code_combinations'';
   END IF;

   IF (xla_cmp_tad_pkg.C_LEVEL_PROCEDURE >= xla_cmp_tad_pkg.g_log_level) THEN
      trace
           ( p_module   => l_log_module
            ,p_msg      => ''BEGIN '' || l_log_module
            ,p_level    => xla_cmp_tad_pkg.C_LEVEL_PROCEDURE);
   END IF;

$C_TMPL_BATCH_BUILD_CCID_STMTS$

   l_return_value := TRUE;

   IF (xla_cmp_tad_pkg.C_LEVEL_PROCEDURE >= xla_cmp_tad_pkg.g_log_level) THEN
      trace
           ( p_module   => l_log_module
            ,p_msg      => ''END '' || l_log_module
            ,p_level    => xla_cmp_tad_pkg.C_LEVEL_PROCEDURE);
   END IF;

   RETURN l_return_value;

EXCEPTION
WHEN le_fatal_error
THEN
   IF (xla_cmp_tad_pkg.C_LEVEL_EXCEPTION >= xla_cmp_tad_pkg.g_log_level) THEN
      trace
            ( p_module   => l_log_module
             ,p_msg      => ''EXCEPTION:''
             ,p_level    => xla_cmp_tad_pkg.C_LEVEL_EXCEPTION);
      trace
            ( p_module   => l_log_module
             ,p_msg      => ''Fatal error: '' || l_fatal_error_message
             ,p_level    => xla_cmp_tad_pkg.C_LEVEL_EXCEPTION);
   END IF;
   RETURN FALSE;
WHEN OTHERS
THEN
   IF (xla_cmp_tad_pkg.C_LEVEL_EXCEPTION >= xla_cmp_tad_pkg.g_log_level)
   THEN
      trace
               ( p_module   => l_log_module
                ,p_msg      => ''build_code_combinations failed with the error:''
                ,p_level    => xla_cmp_tad_pkg.C_LEVEL_EXCEPTION);
      trace
               ( p_module   => l_log_module
                ,p_msg      => SQLERRM
                ,p_level    => xla_cmp_tad_pkg.C_LEVEL_EXCEPTION);
   END IF;
   fnd_message.set_name
            (
              application => ''XLA''
             ,name        => ''XLA_TAB_FUN_GENERIC_EXCEPTION''
            );
   fnd_message.set_token
            (
              token => ''FUNCTION_NAME''
             ,value => ''$TAD_PACKAGE_NAME_3$.build_code_combinations''
            );
   fnd_message.set_token
            (
              token => ''ERROR''
             ,value => SQLERRM
            );
   fnd_msg_pub.add;
   RETURN FALSE;
END build_code_combinations;


FUNCTION push_interface_data ( x_total_rows_moved OUT NOCOPY NUMBER)
RETURN BOOLEAN
IS
l_total_rows_moved           NUMBER;
le_fatal_error               EXCEPTION;
l_return_value               BOOLEAN;
l_fatal_error_message        VARCHAR2(2000);
l_log_module                 VARCHAR2(2000);
BEGIN
   IF xla_cmp_tad_pkg.g_log_enabled THEN
      l_log_module := g_default_module||''.push_interface_data'';
   END IF;

   IF (xla_cmp_tad_pkg.C_LEVEL_PROCEDURE >= xla_cmp_tad_pkg.g_log_level) THEN
      trace
           ( p_module   => l_log_module
            ,p_msg      => ''BEGIN '' || l_log_module
            ,p_level    => xla_cmp_tad_pkg.C_LEVEL_PROCEDURE);
   END IF;

   l_total_rows_moved := 0;

$C_TMPL_PUSH_INTERF_DATA_STMTS$

   l_return_value := TRUE;

   --Assign out parameters
   x_total_rows_moved := l_total_rows_moved;

   IF (xla_cmp_tad_pkg.C_LEVEL_PROCEDURE >= xla_cmp_tad_pkg.g_log_level) THEN
      trace
           ( p_module   => l_log_module
            ,p_msg      => ''END '' || l_log_module
            ,p_level    => xla_cmp_tad_pkg.C_LEVEL_PROCEDURE);
   END IF;

   RETURN l_return_value;

EXCEPTION
WHEN OTHERS
THEN
   IF (xla_cmp_tad_pkg.C_LEVEL_EXCEPTION >= xla_cmp_tad_pkg.g_log_level)
   THEN
      trace
               ( p_module   => l_log_module
                ,p_msg      => ''push_interface_data failed with the error:''
                ,p_level    => xla_cmp_tad_pkg.C_LEVEL_EXCEPTION);
      trace
               ( p_module   => l_log_module
                ,p_msg      => SQLERRM
                ,p_level    => xla_cmp_tad_pkg.C_LEVEL_EXCEPTION);
   END IF;
   fnd_message.set_name
            (
              application => ''XLA''
             ,name        => ''XLA_TAB_FUN_GENERIC_EXCEPTION''
            );
   fnd_message.set_token
            (
              token => ''FUNCTION_NAME''
             ,value => ''$TAD_PACKAGE_NAME_3$.push_interface_data''
            );
   fnd_message.set_token
            (
              token => ''ERROR''
             ,value => SQLERRM
            );
   fnd_msg_pub.add;
   RETURN FALSE;
END push_interface_data;

FUNCTION pop_interface_data ( x_total_rows_moved OUT NOCOPY NUMBER)
RETURN BOOLEAN
IS
l_total_rows_moved           NUMBER;
le_fatal_error               EXCEPTION;
l_return_value               BOOLEAN;
l_fatal_error_message        VARCHAR2(2000);
l_log_module                 VARCHAR2(2000);
BEGIN
   IF xla_cmp_tad_pkg.g_log_enabled THEN
      l_log_module := g_default_module||''.pop_interface_data'';
   END IF;

   IF (xla_cmp_tad_pkg.C_LEVEL_PROCEDURE >= xla_cmp_tad_pkg.g_log_level) THEN
      trace
           ( p_module   => l_log_module
            ,p_msg      => ''BEGIN '' || l_log_module
            ,p_level    => xla_cmp_tad_pkg.C_LEVEL_PROCEDURE);
   END IF;

   l_total_rows_moved := 0;

$C_TMPL_POP_INTERF_DATA_STMTS$

   l_return_value := TRUE;

   --Assign out parameters
   x_total_rows_moved := l_total_rows_moved;

   IF (xla_cmp_tad_pkg.C_LEVEL_PROCEDURE >= xla_cmp_tad_pkg.g_log_level) THEN
      trace
           ( p_module   => l_log_module
            ,p_msg      => ''END '' || l_log_module
            ,p_level    => xla_cmp_tad_pkg.C_LEVEL_PROCEDURE);
   END IF;

   RETURN l_return_value;

EXCEPTION
WHEN OTHERS
THEN
   IF (xla_cmp_tad_pkg.C_LEVEL_EXCEPTION >= xla_cmp_tad_pkg.g_log_level)
   THEN
      trace
               ( p_module   => l_log_module
                ,p_msg      => ''pop_interface_data failed with the error:''
                ,p_level    => xla_cmp_tad_pkg.C_LEVEL_EXCEPTION);
      trace
               ( p_module   => l_log_module
                ,p_msg      => SQLERRM
                ,p_level    => xla_cmp_tad_pkg.C_LEVEL_EXCEPTION);
   END IF;
   fnd_message.set_name
            (
              application => ''XLA''
             ,name        => ''XLA_TAB_FUN_GENERIC_EXCEPTION''
            );
   fnd_message.set_token
            (
              token => ''FUNCTION_NAME''
             ,value => ''$TAD_PACKAGE_NAME_3$.pop_interface_data''
            );
   fnd_message.set_token
            (
              token => ''ERROR''
             ,value => SQLERRM
            );
   fnd_msg_pub.add;
   RETURN FALSE;
END pop_interface_data;


--Public procedures

PROCEDURE trans_account_def_online
   (
     p_transaction_coa_id           IN         NUMBER
    ,p_accounting_coa_id            IN         NUMBER
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
   )
IS
le_fatal_error                 EXCEPTION;
l_return_msg_name              VARCHAR2(30);

l_table_segment_qualifiers     xla_cmp_tad_pkg.gt_table_V30_V30;
l_table_segment_column_names   xla_cmp_tad_pkg.gt_table_V30;
l_flex_delimiter               VARCHAR2(1);
l_concat_segments_template     VARCHAR2(1000);

l_gl_balancing_segment_name    VARCHAR2(30);
l_gl_account_segment_name      VARCHAR2(30);
l_gl_intercompany_segment_name VARCHAR2(30);
l_gl_management_segment_name   VARCHAR2(30);
l_fa_cost_ctr_segment_name     VARCHAR2(30);

l_chart_of_accounts_name       VARCHAR2(80);

l_current_date                 DATE      := TRUNC(SYSDATE);

l_total_rows_pushed            NUMBER;
l_total_rows_popped            NUMBER;

l_fatal_error_message          VARCHAR2(2000);
l_log_module                   VARCHAR2(2000);

BEGIN
   IF xla_cmp_tad_pkg.g_log_enabled THEN
      l_log_module := g_default_module||''.trans_account_def_online'';
   END IF;

   IF (xla_cmp_tad_pkg.C_LEVEL_PROCEDURE >= xla_cmp_tad_pkg.g_log_level) THEN
      trace
           ( p_module   => l_log_module
            ,p_msg      => ''BEGIN '' || l_log_module
            ,p_level    => xla_cmp_tad_pkg.C_LEVEL_PROCEDURE);
   END IF;

   IF (xla_cmp_tad_pkg.C_LEVEL_STATEMENT >= xla_cmp_tad_pkg.g_log_level) THEN

      trace( p_module   => l_log_module
            ,p_msg      => ''p_transaction_coa_id : '' || p_transaction_coa_id
            ,p_level    => xla_cmp_tad_pkg.C_LEVEL_STATEMENT);

      trace( p_module   => l_log_module
            ,p_msg      => ''p_accounting_coa_id : '' || p_accounting_coa_id
            ,p_level    => xla_cmp_tad_pkg.C_LEVEL_STATEMENT);

   END IF;


   --Retrieve the Chart Of Accounts information
   IF NOT get_coa_info
      (
        p_chart_of_accounts_id         => p_transaction_coa_id
       ,p_chart_of_accounts_name       => l_chart_of_accounts_name
       ,p_flex_delimiter               => l_flex_delimiter
       ,p_concat_segments_template     => l_concat_segments_template
       ,p_gl_balancing_segment_name    => l_gl_balancing_segment_name
       ,p_gl_account_segment_name      => l_gl_account_segment_name
       ,p_gl_intercompany_segment_name => l_gl_intercompany_segment_name
       ,p_gl_management_segment_name   => l_gl_management_segment_name
       ,p_fa_cost_ctr_segment_name     => l_fa_cost_ctr_segment_name
       ,p_table_segment_qualifiers     => l_table_segment_qualifiers
       ,p_table_segment_column_names   => l_table_segment_column_names
      )
   THEN
      l_fatal_error_message := ''get_coa_info failed'';
      RAISE le_fatal_error;
   END IF;

   IF (xla_cmp_tad_pkg.C_LEVEL_STATEMENT >= xla_cmp_tad_pkg.g_log_level) THEN

      trace( p_module   => l_log_module
            ,p_msg      => ''l_gl_balancing_segment_name: '' || l_gl_balancing_segment_name
            ,p_level    => xla_cmp_tad_pkg.C_LEVEL_STATEMENT);

      trace( p_module   => l_log_module
            ,p_msg      => ''l_gl_account_segment_name: '' || l_gl_account_segment_name
            ,p_level    => xla_cmp_tad_pkg.C_LEVEL_STATEMENT);

   END IF;


   --Move the data from the plsql tables into the global temporary tables
   IF NOT push_interface_data (x_total_rows_moved => l_total_rows_pushed)
   THEN
      fnd_message.set_name
            (
              application => ''XLA''
             ,name        => ''XLA_TAB_FATAL_ERROR''
            );
      fnd_message.set_token
            (
              token => ''FUNCTION_NAME''
             ,value => ''$TAD_PACKAGE_NAME_3$.trans_account_def_online''
            );
      fnd_msg_pub.add;

      l_fatal_error_message := ''push_interface_data failed'';
      RAISE le_fatal_error;
   END IF;

   IF (xla_cmp_tad_pkg.C_LEVEL_STATEMENT >= xla_cmp_tad_pkg.g_log_level)
   THEN
      trace
               ( p_module   => l_log_module
                ,p_msg      => ''Number of rows pushed: '' || l_total_rows_pushed
                ,p_level    => xla_cmp_tad_pkg.C_LEVEL_STATEMENT);
   END IF;

   --If no rows could be pushed then raise an error
   IF l_total_rows_pushed = 0
   THEN
      fnd_message.set_name
            (
              application => ''XLA''
             ,name        => ''XLA_TAB_NO_ROWS_ONLINE_INTERF''
            );
      fnd_message.set_token
            (
              token => ''FUNCTION_NAME''
             ,value => ''$TAD_PACKAGE_NAME_3$.trans_account_def_online''
            );
      fnd_msg_pub.add;

      --Document the exception
      l_fatal_error_message :=
         ''No rows present in the inline interface, aborting...'';
      RAISE le_fatal_error;
   END IF;

   --Ensure that global temp tables are empty so that
   --successive calls from OAF are allowed in case of errors
   --and no rollback in-between.
   DELETE
     FROM xla_tab_errors_gt;

   DELETE
     FROM xla_tab_new_ccids_gt;

   --Apply flex and segment ADR Rules on each interface object
   IF NOT apply_adr_rules
      (
        p_chart_of_accounts_id         => p_transaction_coa_id
       ,p_chart_of_accounts_name       => l_chart_of_accounts_name
       ,p_flex_delimiter               => l_flex_delimiter
       ,p_concat_segments_template     => l_concat_segments_template
       ,p_table_segment_qualifiers     => l_table_segment_qualifiers
       ,p_table_segment_column_names   => l_table_segment_column_names
       ,p_gl_balancing_segment_name    => l_gl_balancing_segment_name
       ,p_gl_account_segment_name      => l_gl_account_segment_name
       ,p_gl_intercompany_segment_name => l_gl_intercompany_segment_name
       ,p_gl_management_segment_name   => l_gl_management_segment_name
       ,p_fa_cost_ctr_segment_name     => l_fa_cost_ctr_segment_name
      )
   THEN
         fnd_message.set_name
            (
              application => ''XLA''
             ,name        => ''XLA_TAB_FATAL_ERROR''
            );
         fnd_message.set_token
            (
              token => ''FUNCTION_NAME''
             ,value => ''$TAD_PACKAGE_NAME_3$.trans_account_def_online''
            );
         fnd_msg_pub.add;

         l_fatal_error_message := ''apply_adr_rules failed'';
         RAISE le_fatal_error;
   END IF;

   --Build the code combinations
   IF NOT build_code_combinations
      (
        p_chart_of_accounts_id         => p_transaction_coa_id
       ,p_chart_of_accounts_name       => l_chart_of_accounts_name
       ,p_flex_delimiter               => l_flex_delimiter
       ,p_concat_segments_template     => l_concat_segments_template
       ,p_table_segment_qualifiers     => l_table_segment_qualifiers
       ,p_table_segment_column_names   => l_table_segment_column_names
       ,p_gl_balancing_segment_name    => l_gl_balancing_segment_name
       ,p_gl_account_segment_name      => l_gl_account_segment_name
       ,p_gl_intercompany_segment_name => l_gl_intercompany_segment_name
       ,p_gl_management_segment_name   => l_gl_management_segment_name
       ,p_fa_cost_ctr_segment_name     => l_fa_cost_ctr_segment_name
      )
   THEN
         fnd_message.set_name
            (
              application => ''XLA''
             ,name        => ''XLA_TAB_FATAL_ERROR''
            );
         fnd_message.set_token
            (
              token => ''FUNCTION_NAME''
             ,value => ''$TAD_PACKAGE_NAME_3$.trans_account_def_online''
            );
         fnd_msg_pub.add;

         l_fatal_error_message := ''build_code_combinations failed'';
         RAISE le_fatal_error;
   END IF;

   --Move the data from the the global temporary tables back
   --into the global temp tables
   IF NOT pop_interface_data(x_total_rows_moved => l_total_rows_popped)
   THEN
      IF (xla_cmp_tad_pkg.C_LEVEL_EXCEPTION >= xla_cmp_tad_pkg.g_log_level)
      THEN
         trace
               ( p_module   => l_log_module
                ,p_msg      => ''push_interface_data failed''
                ,p_level    => xla_cmp_tad_pkg.C_LEVEL_EXCEPTION);
      END IF;
      fnd_message.set_name
            (
              application => ''XLA''
             ,name        => ''XLA_TAB_FATAL_ERROR''
            );
      fnd_message.set_token
            (
              token => ''FUNCTION_NAME''
             ,value => ''$TAD_PACKAGE_NAME_3$.trans_account_def_online''
            );
      fnd_msg_pub.add;
      l_fatal_error_message := ''pop_interface_data failed'';
      RAISE le_fatal_error;
   END IF;

   IF (xla_cmp_tad_pkg.C_LEVEL_STATEMENT >= xla_cmp_tad_pkg.g_log_level)
   THEN
      trace
               ( p_module   => l_log_module
                ,p_msg      => ''Number of rows retrieved: '' || l_total_rows_popped
                ,p_level    => xla_cmp_tad_pkg.C_LEVEL_STATEMENT);
   END IF;

   IF l_total_rows_pushed <> l_total_rows_popped
   THEN
      fnd_message.set_name
            (
              application => ''XLA''
             ,name        => ''XLA_TAB_ROWS_MIS_ONLINE_INTERF''
            );
      fnd_message.set_token
            (
              token => ''TAB_ROWS_PUSHED''
             ,value => l_total_rows_pushed
            );
      fnd_message.set_token
            (
              token => ''TAB_ROWS_POPPED''
             ,value => l_total_rows_popped
            );
      fnd_message.set_token
            (
              token => ''FUNCTION_NAME''
             ,value => ''$TAD_PACKAGE_NAME_3$.trans_account_def_online''
            );
      fnd_msg_pub.add;

      l_fatal_error_message := ''Rows pushed('' || l_total_rows_pushed
                               || '') <> Rows popped(''
                               || l_total_rows_popped || '')'';
      RAISE le_fatal_error;

   END IF;

   --Assign return status
   x_return_status := xla_cmp_tad_pkg.C_RET_STS_SUCCESS;

   IF (xla_cmp_tad_pkg.C_LEVEL_PROCEDURE >= xla_cmp_tad_pkg.g_log_level) THEN
      trace
           ( p_module   => l_log_module
            ,p_msg      => ''END '' || l_log_module
            ,p_level    => xla_cmp_tad_pkg.C_LEVEL_PROCEDURE);
   END IF;

EXCEPTION
WHEN le_fatal_error
THEN
   IF (xla_cmp_tad_pkg.C_LEVEL_EXCEPTION >= xla_cmp_tad_pkg.g_log_level)
   THEN
         trace
            ( p_module   => l_log_module
             ,p_msg      => ''EXCEPTION:''
             ,p_level    => xla_cmp_tad_pkg.C_LEVEL_EXCEPTION);
         trace
            ( p_module   => l_log_module
             ,p_msg      => ''Fatal error: '' || l_fatal_error_message
             ,p_level    => xla_cmp_tad_pkg.C_LEVEL_EXCEPTION);
   END IF;
   IF x_return_status IS NULL
   THEN
      x_return_status := xla_cmp_tad_pkg.C_RET_STS_UNEXP_ERROR;
   END IF;
   IF l_return_msg_name IS NOT NULL
   THEN
      --There is a detailed message to push
      fnd_message.set_name
         (
           application => ''XLA''
          ,name        => l_return_msg_name
         );
      fnd_msg_pub.add;
   END IF;
   fnd_msg_pub.Count_And_Get
      (
        p_count => x_msg_count
       ,p_data  => x_msg_data
      );
   --for Forms callers
   fnd_message.set_encoded
      (
        encoded_message => x_msg_data
      );
   IF (xla_cmp_tad_pkg.C_LEVEL_PROCEDURE >= xla_cmp_tad_pkg.g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => ''END '' || l_log_module
         ,p_level    => xla_cmp_tad_pkg.C_LEVEL_PROCEDURE);
   END IF;
WHEN OTHERS
THEN
   fnd_message.set_name(''XLA'', ''XLA_TAB_UNHANDLED_EXCEPTION'');
   fnd_message.set_token( ''PROCEDURE''
                         ,''$TAD_PACKAGE_NAME_3$.trans_account_def_online'');
   RAISE;
END trans_account_def_online;


PROCEDURE trans_account_def_batch
    (
      p_transaction_coa_id          IN          NUMBER
     ,p_accounting_coa_id           IN          NUMBER
     ,x_return_status               OUT NOCOPY  VARCHAR2
     ,x_msg_count                   OUT NOCOPY  NUMBER
     ,x_msg_data                    OUT NOCOPY  VARCHAR2
    )
IS
le_fatal_error                 EXCEPTION;
l_return_msg_name              VARCHAR2(30);

l_table_segment_qualifiers     xla_cmp_tad_pkg.gt_table_V30_V30;
l_table_segment_column_names   xla_cmp_tad_pkg.gt_table_V30;
l_flex_delimiter               VARCHAR2(1);
l_concat_segments_template     VARCHAR2(1000);

l_gl_balancing_segment_name    VARCHAR2(30);
l_gl_account_segment_name      VARCHAR2(30);
l_gl_intercompany_segment_name VARCHAR2(30);
l_gl_management_segment_name   VARCHAR2(30);
l_fa_cost_ctr_segment_name     VARCHAR2(30);

l_chart_of_accounts_name       VARCHAR2(80);

l_current_date                 DATE      := TRUNC(SYSDATE);

l_fatal_error_message          VARCHAR2(2000);
l_log_module                   VARCHAR2(2000);

BEGIN
   IF xla_cmp_tad_pkg.g_log_enabled THEN
      l_log_module := g_default_module||''.trans_account_def_batch'';
   END IF;

   IF (xla_cmp_tad_pkg.C_LEVEL_PROCEDURE >= xla_cmp_tad_pkg.g_log_level) THEN
      trace
           ( p_module   => l_log_module
            ,p_msg      => ''BEGIN '' || l_log_module
            ,p_level    => xla_cmp_tad_pkg.C_LEVEL_PROCEDURE);
   END IF;

   --Retrieve the Chart Of Accounts information
   IF NOT get_coa_info
      (
        p_chart_of_accounts_id         => p_transaction_coa_id
       ,p_chart_of_accounts_name       => l_chart_of_accounts_name
       ,p_flex_delimiter               => l_flex_delimiter
       ,p_concat_segments_template     => l_concat_segments_template
       ,p_gl_balancing_segment_name    => l_gl_balancing_segment_name
       ,p_gl_account_segment_name      => l_gl_account_segment_name
       ,p_gl_intercompany_segment_name => l_gl_intercompany_segment_name
       ,p_gl_management_segment_name   => l_gl_management_segment_name
       ,p_fa_cost_ctr_segment_name     => l_fa_cost_ctr_segment_name
       ,p_table_segment_qualifiers     => l_table_segment_qualifiers
       ,p_table_segment_column_names   => l_table_segment_column_names
      )
   THEN
      l_fatal_error_message := ''Unable to get Chart Of Account Info'';
      RAISE le_fatal_error;
   END IF;

   --Apply flex and segment ADR Rules on each interface object
   IF NOT apply_adr_rules
      (
        p_chart_of_accounts_id         => p_transaction_coa_id
       ,p_chart_of_accounts_name       => l_chart_of_accounts_name
       ,p_flex_delimiter               => l_flex_delimiter
       ,p_concat_segments_template     => l_concat_segments_template
       ,p_table_segment_qualifiers     => l_table_segment_qualifiers
       ,p_table_segment_column_names   => l_table_segment_column_names
       ,p_gl_balancing_segment_name    => l_gl_balancing_segment_name
       ,p_gl_account_segment_name      => l_gl_account_segment_name
       ,p_gl_intercompany_segment_name => l_gl_intercompany_segment_name
       ,p_gl_management_segment_name   => l_gl_management_segment_name
       ,p_fa_cost_ctr_segment_name     => l_fa_cost_ctr_segment_name
      )
   THEN
         IF (xla_cmp_tad_pkg.C_LEVEL_EXCEPTION >= xla_cmp_tad_pkg.g_log_level)
         THEN
            trace
               ( p_module   => l_log_module
                ,p_msg      => ''apply_adr_rules failed''
                ,p_level    => xla_cmp_tad_pkg.C_LEVEL_EXCEPTION);
         END IF;
         fnd_message.set_name
            (
              application => ''XLA''
             ,name        => ''XLA_TAB_FATAL_ERROR''
            );
         fnd_message.set_token
            (
              token => ''FUNCTION_NAME''
             ,value => ''$TAD_PACKAGE_NAME_3$.trans_account_def_batch''
            );
         fnd_msg_pub.add;
         RAISE le_fatal_error;
   END IF;

   --Build the code combinations
   IF NOT build_code_combinations
      (
        p_chart_of_accounts_id         => p_transaction_coa_id
       ,p_chart_of_accounts_name       => l_chart_of_accounts_name
       ,p_flex_delimiter               => l_flex_delimiter
       ,p_concat_segments_template     => l_concat_segments_template
       ,p_table_segment_qualifiers     => l_table_segment_qualifiers
       ,p_table_segment_column_names   => l_table_segment_column_names
       ,p_gl_balancing_segment_name    => l_gl_balancing_segment_name
       ,p_gl_account_segment_name      => l_gl_account_segment_name
       ,p_gl_intercompany_segment_name => l_gl_intercompany_segment_name
       ,p_gl_management_segment_name   => l_gl_management_segment_name
       ,p_fa_cost_ctr_segment_name     => l_fa_cost_ctr_segment_name
      )
   THEN
         IF (xla_cmp_tad_pkg.C_LEVEL_EXCEPTION >= xla_cmp_tad_pkg.g_log_level)
         THEN
            trace
               ( p_module   => l_log_module
                ,p_msg      => ''build_code_combinations failed''
                ,p_level    => xla_cmp_tad_pkg.C_LEVEL_EXCEPTION);
         END IF;
         fnd_message.set_name
            (
              application => ''XLA''
             ,name        => ''XLA_TAB_FATAL_ERROR''
            );
         fnd_message.set_token
            (
              token => ''FUNCTION_NAME''
             ,value => ''$TAD_PACKAGE_NAME_3$.trans_account_def_batch''
            );
         fnd_msg_pub.add;
         RAISE le_fatal_error;
   END IF;

   --Assign return status
   x_return_status := xla_cmp_tad_pkg.C_RET_STS_SUCCESS;

   IF (xla_cmp_tad_pkg.C_LEVEL_PROCEDURE >= xla_cmp_tad_pkg.g_log_level) THEN
      trace
           ( p_module   => l_log_module
            ,p_msg      => ''END '' || l_log_module
            ,p_level    => xla_cmp_tad_pkg.C_LEVEL_PROCEDURE);
   END IF;

EXCEPTION
WHEN le_fatal_error
THEN
   IF (xla_cmp_tad_pkg.C_LEVEL_EXCEPTION >= xla_cmp_tad_pkg.g_log_level)
   THEN
         trace
            ( p_module   => l_log_module
             ,p_msg      => ''EXCEPTION:''
             ,p_level    => xla_cmp_tad_pkg.C_LEVEL_EXCEPTION);
         trace
            ( p_module   => l_log_module
             ,p_msg      => ''Fatal error: '' || l_fatal_error_message
             ,p_level    => xla_cmp_tad_pkg.C_LEVEL_EXCEPTION);
   END IF;
   IF x_return_status IS NULL
   THEN
      x_return_status := xla_cmp_tad_pkg.C_RET_STS_UNEXP_ERROR;
   END IF;
   IF l_return_msg_name IS NOT NULL
   THEN
      --There is a detailed message to push
      fnd_message.set_name
         (
           application => ''XLA''
          ,name        => l_return_msg_name
         );
      fnd_msg_pub.add;
   END IF;
   fnd_msg_pub.Count_And_Get
      (
        p_count => x_msg_count
       ,p_data  => x_msg_data
      );
   --for Forms callers
   fnd_message.set_encoded
      (
        encoded_message => x_msg_data
      );
   IF (xla_cmp_tad_pkg.C_LEVEL_PROCEDURE >= xla_cmp_tad_pkg.g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => ''END '' || l_log_module
         ,p_level    => xla_cmp_tad_pkg.C_LEVEL_PROCEDURE);
   END IF;
WHEN OTHERS
THEN
   fnd_message.set_name(''XLA'', ''XLA_TAB_UNHANDLED_EXCEPTION'');
   fnd_message.set_token( ''PROCEDURE''
                         ,''$TAD_PACKAGE_NAME_3$.trans_account_def_batch'');
   RAISE;
END trans_account_def_batch;



--Trace initialization
BEGIN
   xla_cmp_tad_pkg.g_log_level      := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   xla_cmp_tad_pkg.g_log_enabled    := fnd_log.test
                          (log_level  => xla_cmp_tad_pkg.g_log_level
                          ,module     => g_default_module);

   IF NOT xla_cmp_tad_pkg.g_log_enabled  THEN
      xla_cmp_tad_pkg.g_log_level := xla_cmp_tad_pkg.C_LEVEL_LOG_DISABLED;
   END IF;


END $TAD_PACKAGE_NAME_1$;
';


C_TMPL_TAD_PACKAGE_BODY  CONSTANT  CLOB :=    C_TMPL_TAD_PACKAGE_BODY_PART_1
                                           || C_TMPL_TAD_PACKAGE_BODY_PART_2
                                           || C_TMPL_TAD_PACKAGE_BODY_PART_3
                                           || C_TMPL_TAD_PACKAGE_BODY_PART_4;

--+==========================================================================+
--|            end of package body template                                  |
--+==========================================================================+


C_TMPL_PUSH_INTERF_DATA_STMT  CONSTANT  CLOB :=
'
   IF $TAB_API_PACKAGE_NAME$.$PLSQL_TABLE_NAME$ IS NOT NULL
   AND $TAB_API_PACKAGE_NAME$.$PLSQL_TABLE_NAME$.count > 0
   THEN
      --Dump the content of the PL/SQL table
      IF (xla_cmp_tad_pkg.C_LEVEL_STATEMENT >= xla_cmp_tad_pkg.g_log_level) THEN

            trace
            ( p_module   => l_log_module
             ,p_msg      =>
''Dumping content of PL/SQL table $TAB_API_PACKAGE_NAME$.$PLSQL_TABLE_NAME$''
             ,p_level    => xla_cmp_tad_pkg.C_LEVEL_STATEMENT);

            trace
            ( p_module   => l_log_module
             ,p_msg      =>
''src_distr1, src_distr2, src_distr3, src_distr4, src_distr5, account_type_code, target_ccid''
             ,p_level    => xla_cmp_tad_pkg.C_LEVEL_STATEMENT);


         FOR i IN $TAB_API_PACKAGE_NAME$.$PLSQL_TABLE_NAME$.FIRST..$TAB_API_PACKAGE_NAME$.$PLSQL_TABLE_NAME$.LAST
         LOOP

            trace
            ( p_module => l_log_module
             ,p_msg      => ''Line '' || i || '': ''
||$TAB_API_PACKAGE_NAME$.$PLSQL_TABLE_NAME$(i).source_distribution_id_num_1
||'','' || $TAB_API_PACKAGE_NAME$.$PLSQL_TABLE_NAME$(i).source_distribution_id_num_2
||'','' || $TAB_API_PACKAGE_NAME$.$PLSQL_TABLE_NAME$(i).source_distribution_id_num_3
||'','' || $TAB_API_PACKAGE_NAME$.$PLSQL_TABLE_NAME$(i).source_distribution_id_num_4
||'','' || $TAB_API_PACKAGE_NAME$.$PLSQL_TABLE_NAME$(i).source_distribution_id_num_5
||'','' || $TAB_API_PACKAGE_NAME$.$PLSQL_TABLE_NAME$(i).account_type_code
||'','' || $TAB_API_PACKAGE_NAME$.$PLSQL_TABLE_NAME$(i).target_ccid
             ,p_level    => xla_cmp_tad_pkg.C_LEVEL_STATEMENT);

         END LOOP;
      END IF; --Trace statement


      --Ensure the global temporary table is empty
      DELETE
        FROM $TABLE_NAME$;

      --A named binding would be preferable but either
      --we would encounter the error
      --PLS-00436 implementation restriction: cannot reference fields of BULK In-BIND
      --table of records
      --or we give up bulk binding
      --
      --Added the column dummy_rowid to fix bug4344773
      FORALL i IN $TAB_API_PACKAGE_NAME$.$PLSQL_TABLE_NAME$.FIRST..$TAB_API_PACKAGE_NAME$.$PLSQL_TABLE_NAME$.LAST
         INSERT
           INTO
              ( SELECT gt.DUMMY_ROWID
                      ,gt.SOURCE_DISTRIBUTION_ID_NUM_1
                      ,gt.SOURCE_DISTRIBUTION_ID_NUM_2
                      ,gt.SOURCE_DISTRIBUTION_ID_NUM_3
                      ,gt.SOURCE_DISTRIBUTION_ID_NUM_4
                      ,gt.SOURCE_DISTRIBUTION_ID_NUM_5
                      ,gt.ACCOUNT_TYPE_CODE
                      --START of source list$C_TMPL_TAB_PUSH_INTERF_SOURCES$
                      --END of source list
                      ,gt.TARGET_CCID
                      ,gt.CONCATENATED_SEGMENTS
                      ,gt.MSG_COUNT
                      ,gt.MSG_DATA
               FROM $TABLE_NAME$ gt
              )
         VALUES
            $TAB_API_PACKAGE_NAME$.$PLSQL_TABLE_NAME$(i);

      l_total_rows_moved := l_total_rows_moved + SQL%ROWCOUNT;

      IF (xla_cmp_tad_pkg.C_LEVEL_STATEMENT >= xla_cmp_tad_pkg.g_log_level) THEN
         trace
            ( p_module => l_log_module
             ,p_msg    => SQL%ROWCOUNT
                           || '' row(s) inserted into $TABLE_NAME$''
             ,p_level  => xla_cmp_tad_pkg.C_LEVEL_STATEMENT);
      END IF;

      --Delete all the elements of the PLSQL table
      $TAB_API_PACKAGE_NAME$.$PLSQL_TABLE_NAME$.DELETE;

   END IF;
';

C_TMPL_POP_INTERF_DATA_STMT  CONSTANT  CLOB :=
'
   IF $TAB_API_PACKAGE_NAME$.$PLSQL_TABLE_NAME$.COUNT = 0
   THEN
      --A named binding would be preferable but either
      --we would encounter the error
      --PLS-00436 implementation restriction: cannot reference fields of BULK In-BIND
      --table of records
      --or we give up bulk binding
      SELECT ROWID
            ,SOURCE_DISTRIBUTION_ID_NUM_1
            ,SOURCE_DISTRIBUTION_ID_NUM_2
            ,SOURCE_DISTRIBUTION_ID_NUM_3
            ,SOURCE_DISTRIBUTION_ID_NUM_4
            ,SOURCE_DISTRIBUTION_ID_NUM_5
            ,ACCOUNT_TYPE_CODE
            --START of source list$C_TMPL_TAB_POP_INTERF_SOURCES$
            --END of source list
            ,TARGET_CCID
            ,CONCATENATED_SEGMENTS
            ,MSG_COUNT
            ,MSG_DATA
      BULK COLLECT
        INTO $TAB_API_PACKAGE_NAME$.$PLSQL_TABLE_NAME$
        FROM $TABLE_NAME$ gt;

      l_total_rows_moved := l_total_rows_moved + SQL%ROWCOUNT;

      IF (xla_cmp_tad_pkg.C_LEVEL_STATEMENT >= xla_cmp_tad_pkg.g_log_level) THEN
         trace
            (p_module   => l_log_module
            ,p_msg      => SQL%ROWCOUNT
                           || '' row(s) read from $TABLE_NAME$''
            ,p_level    => xla_cmp_tad_pkg.C_LEVEL_STATEMENT);
      END IF;

      --Dump the content of the PL/SQL table
      IF (xla_cmp_tad_pkg.C_LEVEL_STATEMENT >= xla_cmp_tad_pkg.g_log_level) THEN

            trace
            ( p_module   => l_log_module
             ,p_msg      =>
''Dumping content of PL/SQL table $TAB_API_PACKAGE_NAME$.$PLSQL_TABLE_NAME$''
             ,p_level    => xla_cmp_tad_pkg.C_LEVEL_STATEMENT);

            trace
            ( p_module   => l_log_module
             ,p_msg      =>
''src_distr1, src_distr2, src_distr3, src_distr4, ''
||''src_distr5, account_type_code, target_ccid, msg_count, msg_data, ''
             ,p_level    => xla_cmp_tad_pkg.C_LEVEL_STATEMENT);

            trace
            ( p_module   => l_log_module
             ,p_msg      => ''concatenated segments''
             ,p_level    => xla_cmp_tad_pkg.C_LEVEL_STATEMENT);

         FOR i IN $TAB_API_PACKAGE_NAME$.$PLSQL_TABLE_NAME$.FIRST..$TAB_API_PACKAGE_NAME$.$PLSQL_TABLE_NAME$.LAST
         LOOP

            trace
            ( p_module => l_log_module
             ,p_msg      => ''Line '' || i || '': ''
||$TAB_API_PACKAGE_NAME$.$PLSQL_TABLE_NAME$(i).source_distribution_id_num_1
||'','' || $TAB_API_PACKAGE_NAME$.$PLSQL_TABLE_NAME$(i).source_distribution_id_num_2
||'','' || $TAB_API_PACKAGE_NAME$.$PLSQL_TABLE_NAME$(i).source_distribution_id_num_3
||'','' || $TAB_API_PACKAGE_NAME$.$PLSQL_TABLE_NAME$(i).source_distribution_id_num_4
||'','' || $TAB_API_PACKAGE_NAME$.$PLSQL_TABLE_NAME$(i).source_distribution_id_num_5
||'','' || $TAB_API_PACKAGE_NAME$.$PLSQL_TABLE_NAME$(i).account_type_code
||'','' || $TAB_API_PACKAGE_NAME$.$PLSQL_TABLE_NAME$(i).target_ccid
||'','' || $TAB_API_PACKAGE_NAME$.$PLSQL_TABLE_NAME$(i).msg_count
||'','' || SUBSTR($TAB_API_PACKAGE_NAME$.$PLSQL_TABLE_NAME$(i).msg_data, 1, 20)
             ,p_level    => xla_cmp_tad_pkg.C_LEVEL_STATEMENT);
            trace
            ( p_module => l_log_module
             ,p_msg      =>
SUBSTR($TAB_API_PACKAGE_NAME$.$PLSQL_TABLE_NAME$(i).concatenated_segments, 1, 25)
             ,p_level    => xla_cmp_tad_pkg.C_LEVEL_STATEMENT);

         END LOOP;
      END IF; --Trace statement

   END IF;
';


C_TMPL_TAB_PUSH_INTERF_SOURCE  CONSTANT  CLOB :=
'
                      ,$SOURCE_CODE$';
C_TMPL_TAB_POP_INTERF_SOURCE   CONSTANT  CLOB :=
'
            ,$SOURCE_CODE$';


--$TAD_BATCH_CCID_SEG_UPD_STMTS$
C_TMPL_BATCH_CCID_SEG_UPD_STMT  CONSTANT  CLOB :=
'
   UPDATE $table_name$ gt
      SET
$C_TMPL_SET_CLAUSES$;
';

C_TMPL_SET_CCID CONSTANT CLOB :=
'gt.target_ccid
           = CASE gt.account_type_code
$CASE_BRANCHES$
             END
';

C_TMPL_SET_SEGMENT CONSTANT CLOB :=
'gt.$SEGMENT_COLUMN_NAME$
           = CASE gt.account_type_code
$CASE_BRANCHES$
             END
';


C_TMPL_CASE_BRANCH CONSTANT CLOB :=
'             WHEN ''$ACCOUNT_TYPE$''
             THEN $TAD_PACKAGE_NAME_1$.$ADR_FUNCT_NAME$
                   (
                    ''BATCH''                         --p_mode
                    ,ROWID                           --p_rowid
                    ,NULL                            --p_line_index
                    ,p_chart_of_accounts_id          --p_chart_of_accounts_id
                    ,p_chart_of_accounts_name        --p_chart_of_accounts_name
                    ,p_gl_balancing_segment_name     --p_gl_balancing_segment_name
                    ,p_gl_account_segment_name       --p_gl_account_segment_name
                    ,p_gl_intercompany_segment_name  --p_gl_intercompany_segment_name
                    ,p_gl_management_segment_name    --p_gl_management_segment_name
                    ,p_fa_cost_ctr_segment_name      --p_fa_cost_ctr_segment_name
                    ,l_current_date                  --p_validation_date
$C_TMPL_ADR_FUNCT_PARAMS$
             )
';




   --
   -- Global variables
   --
   g_user_id                 CONSTANT INTEGER
                                := xla_environment_pkg.g_usr_id;
   g_login_id                CONSTANT INTEGER
                                := xla_environment_pkg.g_login_id;
   g_prog_appl_id            CONSTANT INTEGER
                                := xla_environment_pkg.g_prog_appl_id;
   g_prog_id                 CONSTANT INTEGER
                                := xla_environment_pkg.g_prog_id;
   g_req_id                  CONSTANT INTEGER
                                := NVL(xla_environment_pkg.g_req_id, -1);

   --Set the message mode to use the message stack instead of raising an exception
   g_msg_mode                CONSTANT VARCHAR2(1) := G_OA_MESSAGE;

   g_application_info        xla_cmp_common_pkg.lt_application_info;
   g_user_name               VARCHAR2(2000); --100 in the table

   --

   -- Cursor declarations
   --



--=============================================================================
--               *********** Local Trace Routine **********
--=============================================================================
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.xla_cmp_tad_pkg';

PROCEDURE trace
       ( p_module                     IN VARCHAR2
        ,p_msg                        IN VARCHAR2
        ,p_level                      IN NUMBER
        ) IS
BEGIN
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
         ( p_location   => 'xla_cmp_tad_pkg.trace'
          ,p_msg_mode   => g_msg_mode
         );
END trace;


--Forward declarations of private functions
FUNCTION init_global_variables
                   ( p_application_id       IN         NUMBER
                   )
RETURN BOOLEAN;

FUNCTION get_tad_package_name
                   (
                      p_account_definition_code      IN  VARCHAR2
                     ,p_account_definition_type_code IN  VARCHAR2
                     ,p_amb_context_code             IN  VARCHAR2
                     ,p_tad_package_name             OUT NOCOPY VARCHAR2
                     ,p_chart_of_accounts_id         OUT NOCOPY NUMBER
                   )
RETURN BOOLEAN;

FUNCTION create_package_spec
             (
               p_account_definition_code      IN    VARCHAR2
              ,p_account_definition_type_code IN    VARCHAR2
              ,p_amb_context_code             IN    VARCHAR2
              ,p_package_name                 IN    VARCHAR2
              ,p_table_of_tad_details         IN    gt_table_of_tad_details
              ,p_table_of_adrs                IN    xla_cmp_adr_pkg.gt_table_of_adrs_in
              ,p_adr_specs_text               IN    CLOB
             )
RETURN BOOLEAN;

FUNCTION create_package_body
(
  p_account_definition_code      IN    VARCHAR2
 ,p_account_definition_type_code IN    VARCHAR2
 ,p_amb_context_code             IN    VARCHAR2
 ,p_package_name                 IN    VARCHAR2
 ,p_tad_coa_id                   IN    NUMBER
 ,p_table_of_tad_details         IN    gt_table_of_tad_details
 ,p_table_of_adrs                IN    xla_cmp_adr_pkg.gt_table_of_adrs_in
 ,p_table_of_adrs_ext            IN    xla_cmp_adr_pkg.gt_table_of_adrs_out
 ,p_adr_bodies_text              IN    CLOB
)
RETURN BOOLEAN;

FUNCTION build_package_spec
    (
      p_account_definition_code      IN         VARCHAR2
     ,p_account_definition_type_code IN         VARCHAR2
     ,p_amb_context_code             IN         VARCHAR2
     ,p_package_name                 IN         VARCHAR2
     ,p_table_of_tad_details         IN         gt_table_of_tad_details
     ,p_table_of_adrs                IN         xla_cmp_adr_pkg.gt_table_of_adrs_in
     ,p_adr_specs_text               IN         CLOB
     ,p_package_spec_text            OUT NOCOPY CLOB
    )
RETURN BOOLEAN;

FUNCTION build_package_body
(
  p_account_definition_code      IN         VARCHAR2
 ,p_account_definition_type_code IN         VARCHAR2
 ,p_amb_context_code             IN         VARCHAR2
 ,p_package_name                 IN         VARCHAR2
 ,p_tad_coa_id                   IN         NUMBER
 ,p_table_of_tad_details         IN         gt_table_of_tad_details
 ,p_table_of_adrs                IN         xla_cmp_adr_pkg.gt_table_of_adrs_in
 ,p_table_of_adrs_ext            IN         xla_cmp_adr_pkg.gt_table_of_adrs_out
 ,p_adr_bodies_text              IN         CLOB
 ,p_package_body_text            OUT NOCOPY CLOB
)
RETURN BOOLEAN;

FUNCTION build_package_history
            (
              p_package_history OUT NOCOPY CLOB
            )
RETURN BOOLEAN;

FUNCTION build_batch_update_statements
(
  p_table_of_tad_details   IN         gt_table_of_tad_details
 ,p_table_of_adrs          IN         xla_cmp_adr_pkg.gt_table_of_adrs_in
 ,p_table_of_adrs_ext      IN         xla_cmp_adr_pkg.gt_table_of_adrs_out
 ,p_update_statements_text OUT NOCOPY CLOB
)
RETURN BOOLEAN;

FUNCTION build_static_ccid_prc_stmts
(
  p_table_of_tad_details   IN         gt_table_of_tad_details
 ,p_tad_coa_id             IN         NUMBER
 ,p_update_statements_text OUT NOCOPY CLOB
)
RETURN BOOLEAN;

FUNCTION build_move_interf_data_stmts
(
  p_table_of_tad_details        IN         gt_table_of_tad_details
 ,p_tad_coa_id                  IN         NUMBER
 ,x_push_interf_statements_text OUT NOCOPY CLOB
 ,x_pop_interf_statements_text  OUT NOCOPY CLOB
)
RETURN BOOLEAN;


FUNCTION get_coa_info
   (
     p_chart_of_accounts_id       IN         NUMBER
    ,p_chart_of_accounts_name     OUT NOCOPY VARCHAR2
    ,p_flex_delimiter             OUT NOCOPY VARCHAR2
    ,p_concat_segments_template   OUT NOCOPY VARCHAR2
    ,p_table_segment_qualifiers   OUT NOCOPY gt_table_V30_V30
    ,p_table_segment_column_names OUT NOCOPY gt_table_V30
   )
RETURN BOOLEAN;

--End of forward declarations


/*======================================================================+
|                                                                       |
| Private Function                                                      |
|                                                                       |
| init_global_variables                                                 |
|                                                                       |
|       This program initializes the global variables required by the   |
|       package. It retrieves the user name.                            |
|                                                                       |
|                                                                       |
+======================================================================*/
FUNCTION init_global_variables
                           ( p_application_id       IN         NUMBER
                           )
RETURN BOOLEAN
IS
   l_return_value BOOLEAN;
l_log_module                 VARCHAR2 (2000);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.init_global_variables';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module   => l_log_module
         ,p_msg      => 'BEGIN ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   l_return_value := TRUE;
/*
   --Retrieve and set the User Name (xla_cmp_common_pkg.get_user_name)
   --Set the application id
   --Retrieve and set the Application Information (xla_cmp_common_pkg.get_application_info)
   --Build and set the Transaction Account Builder package name (get_tab_api_package_name)
   --Retrieve and set the object name affixes (get_distinct_affixes)
*/
   --Retrieve current user name
   IF NOT xla_cmp_common_pkg.get_user_name
                  (
                    p_user_id          => g_user_id
                   ,p_user_name        => g_user_name
                  )
   THEN
      IF (C_LEVEL_ERROR >= g_log_level) THEN
         trace
            (p_module   => l_log_module
            ,p_msg      => 'ERROR:' ||
                           ' Cannot determine user name.'
            ,p_level    => C_LEVEL_ERROR);
      END IF;
   END IF;

   --Retrieve and set the application info
   IF NOT xla_cmp_common_pkg.get_application_info
                  (
                    p_application_id   => p_application_id
                   ,p_application_info => g_application_info
                  )
   THEN
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            (p_module   => l_log_module
             ,p_msg      => 'EXCEPTION:' ||
                           ' Cannot read application info, aborting...'
             ,p_level    => C_LEVEL_EXCEPTION);
      END IF;
      RAISE ge_fatal_error;
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'value returned= '
                        || CASE l_return_value
                              WHEN TRUE THEN 'TRUE'
                              WHEN FALSE THEN 'FALSE'
                              ELSE 'NULL'
                           END
         ,p_level    => C_LEVEL_STATEMENT );
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   RETURN l_return_value;

EXCEPTION
WHEN ge_fatal_error
THEN
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;
   RETURN FALSE;
WHEN xla_exceptions_pkg.application_exception
THEN
   RAISE;
WHEN OTHERS
THEN
   xla_exceptions_pkg.raise_message
      ( p_location        => 'xla_cmp_tad_pkg.init_global_variables'
       ,p_msg_mode        => g_msg_mode
      );
   RETURN FALSE;
END init_global_variables;


/*======================================================================+
|                                                                       |
| Private Function                                                      |
|                                                                       |
| update_tad_compilation_status                                         |
|                                                                       |
|       This program initializes the global variables required by the   |
|       package. It retrieves the user name.                            |
|                                                                       |
|                                                                       |
+======================================================================*/
FUNCTION update_tad_compilation_status
               ( p_compilation_status_code      IN VARCHAR2
                ,p_application_id               IN NUMBER
                ,p_account_definition_code      IN VARCHAR2
                ,p_account_definition_type_code IN VARCHAR2
                ,p_amb_context_code             IN VARCHAR2
               )
RETURN BOOLEAN
IS
   l_return_value BOOLEAN;
   l_log_module   VARCHAR2 (2000);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.update_tad_compilation_status';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module   => l_log_module
         ,p_msg      => 'BEGIN ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   UPDATE xla_tab_acct_defs_b xtad
      SET xtad.compile_status_code          = p_compilation_status_code
    WHERE xtad.application_id               = p_application_id
      AND xtad.account_definition_code      = p_account_definition_code
      AND xtad.account_definition_type_code = p_account_definition_type_code
      AND xtad.amb_context_code             = p_amb_context_code;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
            (p_module   => l_log_module
            ,p_msg      => SQL%ROWCOUNT
                           || ' row(s) updated in xla_tab_acct_defs_b'
            ,p_level    => C_LEVEL_STATEMENT);
   END IF;

   l_return_value := TRUE;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   RETURN l_return_value;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception
THEN
   xla_exceptions_pkg.raise_message
      ( p_location       => 'xla_cmp_tad_pkg.update_tad_compilation_status'
      );
WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      ( p_location        => 'xla_cmp_tad_pkg.update_tad_compilation_status'
       ,p_msg_mode        => g_msg_mode
      );
   RETURN FALSE;
END update_tad_compilation_status;


PROCEDURE compile_application_tads_srs
                           ( p_errbuf               OUT NOCOPY VARCHAR2
                            ,p_retcode              OUT NOCOPY NUMBER
                            ,p_application_id       IN         NUMBER
                           )
IS
l_log_module                 VARCHAR2 (2000);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE || '.compile_application_tads_srs';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'BEGIN ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   IF xla_cmp_tad_pkg.compile_application_tads
               (
                 p_application_id   => p_application_id
               )
   THEN
      IF (C_LEVEL_EVENT >= g_log_level) THEN
         trace
            (p_module   => l_log_module
            ,p_msg      => 'TAB Accounting Engine built successfully'
            ,p_level    => C_LEVEL_EVENT);
      END IF;
      p_retcode := 0;
   ELSE
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            ( p_module   => l_log_module
             ,p_msg      => 'Unable to build TAB Accounting Engine.'
             ,p_level    => C_LEVEL_EXCEPTION);
      END IF;
      p_retcode := 2;
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'p_retcode = ' || p_retcode
         ,p_level    => C_LEVEL_STATEMENT);
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'RETURN ' || C_DEFAULT_MODULE || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception
THEN
   RAISE;
WHEN OTHERS
THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_cmp_tad_pkg.compile_application_tads_srs'
      );

END compile_application_tads_srs;


FUNCTION compile_application_tads
                           ( p_application_id       IN    NUMBER
                           )
RETURN BOOLEAN
IS
   l_return_value BOOLEAN;

   l_user_name            VARCHAR2(30);
   lr_application_info    xla_cmp_common_pkg.lt_application_info;
   l_amb_context_code     VARCHAR2(30);
   i                      NUMBER;
   l_msg_count            NUMBER;
   l_msg_data             VARCHAR2(2000);
   l_message_text         VARCHAR2(32000);
   l_log_module           VARCHAR2(2000);

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.compile_application_tads';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'BEGIN ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   --Set the return value to TRUE
   l_return_value := TRUE;

   --Retrieve the AMB context code
   l_amb_context_code := NVL( fnd_profile.value('XLA_AMB_CONTEXT')
                             ,'DEFAULT'
                            );

   --Open cursor on all enabled TADs for the application and AMB context
   FOR cur_tad IN
      (SELECT xtdv.application_id
             ,xtdv.account_definition_code
             ,xtdv.account_definition_type_code
             ,xtdv.amb_context_code
             ,xtdv.name
         FROM xla_tab_acct_defs_vl xtdv
        WHERE xtdv.application_id               = p_application_id
          AND xtdv.amb_context_code             = l_amb_context_code
          AND xtdv.enabled_flag                 = 'Y'
      )
   LOOP
      --If tad_compilation successful
      IF compile_tad
            (
              p_application_id               => cur_tad.application_id
             ,p_account_definition_code      => cur_tad.account_definition_code
             ,p_account_definition_type_code => cur_tad.account_definition_type_code
             ,p_amb_context_code             => cur_tad.amb_context_code
            )
       THEN
          --Report the "successfully compiled" message in the output
          fnd_file.put_line
             (
               fnd_file.output
              ,xla_messages_pkg.get_message
                (
                  'XLA'
                 ,'XLA_TAB_CMP_TAD_SUCCEEDED'
                 ,'TRX_ACCT_DEF', cur_tad.name
                )
              );
       --Else (compilation unsuccessful)
       ELSE
          --Set return value to FALSE
          l_return_value := FALSE;
          --Report the "unsuccessfully compiled" message in the output
          fnd_file.put_line
             (
               fnd_file.output
              ,xla_messages_pkg.get_message
                  (
                    'XLA'
                   ,'XLA_TAB_CMP_TAD_FAILED'
                   ,'TRX_ACCT_DEF', cur_tad.name
                  )
             );
          --Report the errors
          fnd_msg_pub.Count_And_Get
         (
           p_count => l_msg_count
          ,p_data  => l_msg_data
         );
         --If msg_count 0 it might be the message is on the old stack
         IF l_msg_count = 0
         THEN
            fnd_file.put_line
               (
                 fnd_file.log
                ,fnd_message.get()
               );
         ELSIF l_msg_count = 1
         THEN
            fnd_message.set_encoded
            (
              encoded_message => l_msg_data
            );
            fnd_file.put_line
               (
                 fnd_file.log
                ,fnd_message.get()
               );
         ELSIF l_msg_count > 1
         THEN
            FOR i IN 1..l_msg_count
            LOOP
               fnd_file.put_line
               (
                 fnd_file.log
                ,fnd_msg_pub.get(p_encoded => 'F')
               );
            END LOOP;
         END IF;
       END IF;
   END LOOP;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || C_DEFAULT_MODULE || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   --If success in all phases return TRUE Else FALSE
   RETURN l_return_value;

EXCEPTION
WHEN ge_fatal_error
THEN
   IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            ( p_module   => l_log_module
             ,p_msg      => 'EXCEPTION:' ||
                           ' Cannot initialize global variables, aborting...'
             ,p_level    => C_LEVEL_EXCEPTION);
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;
   RETURN FALSE;
WHEN xla_exceptions_pkg.application_exception
THEN
   RAISE;
WHEN OTHERS
THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_cmp_tad_pkg.compile_application_tads'
       ,p_msg_mode        => g_msg_mode
      );
   RETURN FALSE;
END compile_application_tads;


FUNCTION compile_tad
                           ( p_application_id               IN    NUMBER
                            ,p_account_definition_code      IN    VARCHAR2
                            ,p_account_definition_type_code IN    VARCHAR2
                            ,p_amb_context_code             IN    VARCHAR2
                           )
RETURN BOOLEAN
IS
   l_return_value BOOLEAN;

   l_user_name                    VARCHAR2(30);
   lr_application_info            xla_cmp_common_pkg.lt_application_info;
   l_tad_coa_id                   NUMBER;
   l_count_missing_required_tat   NUMBER;
   l_uncomp_tat_name              VARCHAR2(80);
   l_tad_package_name             VARCHAR2(30);
   l_tad_name                     VARCHAR2(80);
   l_tad_enabled_flag             VARCHAR2(1);
   l_table_of_tad_details         gt_table_of_tad_details;
   l_table_of_adrs                xla_cmp_adr_pkg.gt_table_of_adrs_in;
   l_table_of_adrs_ext            xla_cmp_adr_pkg.gt_table_of_adrs_out;
   l_adr_specs                    CLOB;
   l_adr_bodies                   CLOB;
   l_final_compile_status_code    VARCHAR2(1);

   l_log_module                   VARCHAR2 (2000);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE || '.compile_tad';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'BEGIN ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'Compiling TAD:'
         ,p_level    => C_LEVEL_STATEMENT);
      trace
         (p_module => l_log_module
         ,p_msg      => 'p_application_id:' || p_application_id
         ,p_level    => C_LEVEL_STATEMENT);
      trace
         (p_module => l_log_module
         ,p_msg      => 'p_account_definition_code:'
                        || p_account_definition_code
         ,p_level    => C_LEVEL_STATEMENT);
      trace
         (p_module => l_log_module
         ,p_msg      => 'p_account_definition_type_code:'
                        || p_account_definition_type_code
         ,p_level    => C_LEVEL_STATEMENT);
      trace
         (p_module => l_log_module
         ,p_msg      => 'p_amb_context_code:'
                        || p_amb_context_code
         ,p_level    => C_LEVEL_STATEMENT);
   END IF;

   l_return_value := TRUE;

   --Initialize the global message table
   FND_MSG_PUB.Initialize;

   --Initialize global variables
   IF NOT init_global_variables
                         (
                           p_application_id => p_application_id
                         )
   THEN
      --If global vars cannot be set we cannot continue
      IF (C_LEVEL_ERROR >= g_log_level) THEN
         trace
         (p_module => l_log_module
         ,p_msg      => 'init_global_variables failed'
         ,p_level    => C_LEVEL_ERROR);
      END IF;
      l_return_value := FALSE;
      RAISE ge_fatal_error;
   END IF;

   --Get the name of the TAD in case we need to log messages
   BEGIN
      SELECT name
            ,enabled_flag
        INTO l_tad_name
            ,l_tad_enabled_flag
        FROM xla_tab_acct_defs_vl
       WHERE application_id               = p_application_id
         AND account_definition_code      = p_account_definition_code
         AND account_definition_type_code = p_account_definition_type_code
         AND amb_context_code             = p_amb_context_code;
   EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
      DECLARE
         l_amb_context_meaning VARCHAR2(80);
         l_owner_meaning       VARCHAR2(80);
      BEGIN
         --Try to get the meaning of the amb context code
         BEGIN
            l_amb_context_meaning := xla_lookups_pkg.get_meaning
            (
               p_lookup_type   => 'XLA_AMB_CONTEXT_TYPE'
              ,p_lookup_code   => p_amb_context_code
            );
         EXCEPTION
         --If not possible use the amb context code
         WHEN OTHERS
         THEN
            l_amb_context_meaning := p_amb_context_code;
         END;
         --Try to get the meaning of the owner
         BEGIN

            l_owner_meaning := xla_lookups_pkg.get_meaning
            (
               p_lookup_type   => 'XLA_OWNER_TYPE'
              ,p_lookup_code   => p_account_definition_type_code
            );
         EXCEPTION
         --If not possible use the the type_code
         WHEN OTHERS
         THEN
            l_owner_meaning := p_account_definition_type_code;
         END;

         --Push a message in the message stack
         --without raising an exception
         xla_exceptions_pkg.raise_message
         ( p_appli_s_name    => 'XLA'
          ,p_msg_name        => 'XLA_TAB_CANT_FIND_TAD'
          ,p_token_1         => 'AMB_CONTEXT'
          ,p_value_1         => l_amb_context_meaning
          ,p_token_2         => 'OWNER'
          ,p_value_2         => l_owner_meaning
          ,p_token_3         => 'TRX_ACCT_DEF_CODE'
          ,p_value_3         => p_account_definition_code
          ,p_msg_mode        => g_msg_mode
         );
         l_return_value := FALSE;

         RAISE ge_fatal_error;

      END;
   END;

   --If the TAD is disabled abort the execution
   IF l_tad_enabled_flag = 'N'
   THEN
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            (p_module   => l_log_module
             ,p_msg     => 'EXCEPTION:' ||
                           'This TAD is disabled, aborting...'
            ,p_level    => C_LEVEL_EXCEPTION);
      END IF;
      --Raise a user oriented message
      xla_exceptions_pkg.raise_message
               ( p_appli_s_name    => 'XLA'
                ,p_msg_name        => 'XLA_TAB_CMP_TAD_DISABLED'
                ,p_token_1         => 'TRX_ACCT_DEF'
                ,p_value_1         => l_tad_name
                ,p_msg_mode        => g_msg_mode
               );
      RAISE ge_fatal_error;
   END IF;

   BEGIN
      --Retrieve (if it exists) the first uncompiled TAT for this application
      SELECT xtat.name
        INTO l_uncomp_tat_name
        FROM xla_tab_acct_types_vl xtat
       WHERE xtat.application_id      = p_application_id
         AND xtat.enabled_flag        = 'Y'
         AND (   xtat.compile_status_code IS NULL
              OR xtat.compile_status_code
                 <> xla_cmp_common_pkg.G_COMPILE_STATUS_CODE_COMPILED
             )
         AND ROWNUM = 1;
   EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
      NULL;
   END;

   --If at least not
   IF l_uncomp_tat_name IS NOT NULL
   THEN
      --Raise a user oriented message
      xla_exceptions_pkg.raise_message
               ( p_appli_s_name    => 'XLA'
                ,p_msg_name        => 'XLA_TAB_CMP_INVALIDATED_TAT'
                ,p_token_1         => 'TRX_ACCT_TYPE'
                ,p_value_1         => l_uncomp_tat_name
                ,p_token_2         => 'APPLICATION_NAME'
                ,p_value_2         => g_application_info.application_name
                ,p_msg_mode        => g_msg_mode
               );
      RAISE ge_fatal_error;
   END IF;

/*
   --Lock TAD setup data
   IF NOT xla_cmp_lock_pkg.lock_tad
          (
            p_application_id               => p_application_id
           ,p_account_definition_code      => p_account_definition_code
           ,p_account_definition_type_code => p_account_definition_type_code
           ,p_amb_context_code             => p_amb_context_code
          )
   THEN
      l_return_value := FALSE;
   END IF;
*/

   --Get the package name of the tad
   IF NOT get_tad_package_name
      (
        p_account_definition_code      => p_account_definition_code
       ,p_account_definition_type_code => p_account_definition_type_code
       ,p_amb_context_code             => p_amb_context_code
       ,p_tad_package_name             => l_tad_package_name
       ,p_chart_of_accounts_id         => l_tad_coa_id
      )
   THEN
      IF (C_LEVEL_ERROR >= g_log_level) THEN
         trace
         (p_module => l_log_module
         ,p_msg      => 'get_tad_package_name failed'
         ,p_level    => C_LEVEL_ERROR);
      END IF;
      l_return_value := FALSE;
      RAISE ge_fatal_error;
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'TAD package name: ' || l_tad_package_name
         ,p_level    => C_LEVEL_STATEMENT);
   END IF;

   --Read the TAD details and corresponding TAT affix
   SELECT xtdd.application_id
         ,xtdd.amb_context_code
         ,xtdd.account_type_code
         ,xtdd.flexfield_segment_code
         ,xtdd.segment_rule_type_code
         ,xtdd.segment_rule_code
         ,xtta.object_name_affix
         ,xtta.compile_status_code
         ,xtta.rule_assignment_code
         ,NULL
     BULK COLLECT
     INTO l_table_of_tad_details
     FROM xla_tab_acct_def_details xtdd
         ,xla_tab_acct_types_b     xtta
    WHERE xtdd.application_id               = p_application_id
      AND xtdd.account_definition_code      = p_account_definition_code
      AND xtdd.account_definition_type_code = p_account_definition_type_code
      AND xtdd.amb_context_code             = p_amb_context_code
      AND xtta.application_id               = xtdd.application_id
      AND xtta.account_type_code            = xtdd.account_type_code
   ORDER BY xtta.object_name_affix
           ,xtdd.flexfield_segment_code
           ,xtdd.account_type_code;

   --If the TAD has no details
   IF l_table_of_tad_details.COUNT = 0
   THEN
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            (p_module   => l_log_module
             ,p_msg     => 'ERROR:'
                           || 'This TAD has no details'
            ,p_level    => C_LEVEL_EXCEPTION);
      END IF;

      --Raise a user oriented message
      xla_exceptions_pkg.raise_message
               ( p_appli_s_name    => 'XLA'
                ,p_msg_name        => 'XLA_TAB_CMP_TAD_NO_DETAILS'
                ,p_token_1         => 'TRX_ACCT_DEF'
                ,p_value_1         => l_tad_name
                ,p_msg_mode        => g_msg_mode
               );
      RAISE ge_fatal_error;
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
               (p_module => l_log_module
                ,p_msg      => 'List of TAD details: '
                ,p_level    => C_LEVEL_STATEMENT);
   END IF;

   --Read the distinct Account Derivation Rules assigned to the TAD
SELECT application_id          --application_id
      ,segment_rule_type_code  --segment_rule_type_code
      ,segment_rule_code       --segment_rule_code
      ,amb_context_code        --amb_context_code
BULK COLLECT
  INTO l_table_of_adrs
  FROM
(
   SELECT DISTINCT
          xtdd.application_id
         ,xtdd.segment_rule_type_code
         ,xtdd.segment_rule_code
         ,xtdd.amb_context_code
     FROM xla_tab_acct_def_details xtdd
         ,xla_tab_acct_types_b     xtta
    WHERE xtdd.application_id               = p_application_id
      AND xtdd.account_definition_code      = p_account_definition_code
      AND xtdd.account_definition_type_code = p_account_definition_type_code
      AND xtdd.amb_context_code             = p_amb_context_code
      AND xtta.application_id               = xtdd.application_id
      AND xtta.account_type_code            = xtdd.account_type_code
);

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'ADR rules: '
         ,p_level    => C_LEVEL_STATEMENT);
      IF l_table_of_adrs.FIRST IS NOT NULL
      THEN
         FOR i IN l_table_of_adrs.FIRST..l_table_of_adrs.LAST
         LOOP
            trace
            ( p_module => l_log_module
             ,p_msg      => 'ADR ' || i || ' segment_rule_code: '
                           || l_table_of_adrs(i).segment_rule_code
             ,p_level    => C_LEVEL_STATEMENT);
         END LOOP;
      END IF;
   END IF;

   --Build the specifications and the bodies of the adrs
   IF NOT xla_cmp_adr_pkg.build_adrs_for_tab
   (
     p_table_of_adrs_in        => l_table_of_adrs
    ,x_table_of_adrs_out       => l_table_of_adrs_ext
    ,x_adr_specs_text          => l_adr_specs
    ,x_adr_bodies_text         => l_adr_bodies
   )
   THEN
      IF (C_LEVEL_ERROR >= g_log_level) THEN
         trace
         (p_module => l_log_module
         ,p_msg      => 'xla_cmp_adr_pkg.build_adrs_for_tad failed'
         ,p_level    => C_LEVEL_ERROR);
      END IF;
      l_return_value := FALSE;
      RAISE ge_fatal_error;
   END IF;

   --Dump the compiled ADRs hash ids and their sources
   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      FOR i IN l_table_of_adrs_ext.FIRST..l_table_of_adrs_ext.LAST
      LOOP
         trace
         (p_module => l_log_module
         ,p_msg      => 'Hash id: ' || l_table_of_adrs_ext(i).adr_hash_id
         ,p_level    => C_LEVEL_STATEMENT);

         DECLARE
            n VARCHAR2(30);
         BEGIN
            n := l_table_of_adrs_ext(i).table_of_sources.FIRST;
            WHILE n IS NOT NULL
            LOOP
               trace
            (p_module => l_log_module
            ,p_msg      => 'Source: ' || n || ':' || l_table_of_adrs_ext(i).table_of_sources(n)
            ,p_level    => C_LEVEL_STATEMENT);

               n := l_table_of_adrs_ext(i).table_of_sources.NEXT(n); -- get subscript of next element
            END LOOP;
         END;
      END LOOP;

   END IF;


   --Create Package Specification
   IF NOT create_package_spec
             (
               p_account_definition_code      => p_account_definition_code
              ,p_account_definition_type_code => p_account_definition_type_code
              ,p_amb_context_code             => p_amb_context_code
              ,p_package_name                 => l_tad_package_name
              ,p_table_of_tad_details         => l_table_of_tad_details
              ,p_table_of_adrs                => l_table_of_adrs
              ,p_adr_specs_text               => l_adr_specs
             )
   THEN
      IF (C_LEVEL_ERROR >= g_log_level) THEN
         trace
         (p_module => l_log_module
         ,p_msg      => 'create_package_spec failed'
         ,p_level    => C_LEVEL_ERROR);
      END IF;
      l_return_value := FALSE;
   END IF;


   l_adr_bodies := xla_cmp_string_pkg.replace_token
                                          ( l_adr_bodies
                                           ,'G_LOG_ENABLED'
                                           ,'xla_cmp_tad_pkg.G_LOG_ENABLED'
                                          );

   l_adr_bodies := xla_cmp_string_pkg.replace_token
                                          ( l_adr_bodies
                                           ,'g_log_enabled'
                                           ,'xla_cmp_tad_pkg.G_LOG_ENABLED'
                                          );
   l_adr_bodies := xla_cmp_string_pkg.replace_token
                                          ( l_adr_bodies
                                           ,'G_LOG_LEVEL'
                                           ,'xla_cmp_tad_pkg.G_LOG_LEVEL'
                                          );
   l_adr_bodies := xla_cmp_string_pkg.replace_token
                                          ( l_adr_bodies
                                           ,'g_log_level'
                                           ,'xla_cmp_tad_pkg.G_LOG_LEVEL'
                                          );

   l_adr_bodies := xla_cmp_string_pkg.replace_token
                                          ( l_adr_bodies
                                           ,'C_DEFAULT_MODULE'
                                           ,'g_default_module'
                                          );
   l_adr_bodies := xla_cmp_string_pkg.replace_token
                                          ( l_adr_bodies
                                           ,'C_LEVEL_PROCEDURE'
                                           ,'xla_cmp_tad_pkg.C_LEVEL_PROCEDURE'
                                          );

   --Create Package Body
   IF NOT create_package_body
             (
               p_account_definition_code      => p_account_definition_code
              ,p_account_definition_type_code => p_account_definition_type_code
              ,p_amb_context_code             => p_amb_context_code
              ,p_package_name                 => l_tad_package_name
              ,p_tad_coa_id                   => l_tad_coa_id
              ,p_table_of_tad_details         => l_table_of_tad_details
              ,p_table_of_adrs                => l_table_of_adrs
              ,p_table_of_adrs_ext            => l_table_of_adrs_ext
              ,p_adr_bodies_text              => l_adr_bodies
             )
   THEN
      --If fails we cannot continue
      IF (C_LEVEL_ERROR >= g_log_level) THEN
         trace
         (p_module => l_log_module
         ,p_msg      => 'create_package_body failed'
         ,p_level    => C_LEVEL_ERROR);
      END IF;
      l_return_value := FALSE;
   END IF;

   --If compilation status is false log raise a local exception
   IF NOT l_return_value
   THEN
      IF (C_LEVEL_ERROR >= g_log_level) THEN
         trace
         (p_module => l_log_module
         ,p_msg      => 'Overall compilation status is failure'
         ,p_level    => C_LEVEL_ERROR);
      END IF;
      RAISE ge_fatal_error;
   END IF;

   --Check is some TAT requiring compilation has been left out
   SELECT count(*)
     INTO l_count_missing_required_tat
     FROM xla_tab_acct_types_b     xtat
         ,xla_tab_acct_def_details xtad
    WHERE xtat.application_id                  = p_application_id
      AND xtat.enabled_flag                    = 'Y'
      AND xtat.rule_assignment_code            = 'REQUIRED'
      AND xtad.application_id               (+)= xtat.application_id
      AND xtad.account_type_code            (+)= xtat.account_type_code
      AND xtad.account_definition_code      (+)= p_account_definition_code
      AND xtad.account_definition_type_code (+)= p_account_definition_type_code
      AND xtad.amb_context_code             (+)= p_amb_context_code
      AND xtad.flexfield_segment_code          IS NULL;

   IF l_count_missing_required_tat > 0
   THEN
      --Raise a user oriented message
      xla_exceptions_pkg.raise_message
               ( p_appli_s_name    => 'XLA'
                ,p_msg_name        => 'XLA_TAB_CMP_TAD_MISS_REQ_TAT'
                ,p_token_1         => 'TRX_ACCT_DEF'
                ,p_value_1         => l_tad_name
                ,p_msg_mode        => g_msg_mode
               );
      RAISE ge_fatal_error;
   END IF;

   --Update the compilation status of the TAD
   IF NOT update_tad_compilation_status
       ( p_compilation_status_code      =>
            xla_cmp_common_pkg.G_COMPILE_STATUS_CODE_COMPILED
        ,p_application_id               => p_application_id
        ,p_account_definition_code      => p_account_definition_code
        ,p_account_definition_type_code => p_account_definition_type_code
        ,p_amb_context_code             => p_amb_context_code
       )
   THEN
      IF (C_LEVEL_ERROR >= g_log_level) THEN
         trace
         (p_module => l_log_module
         ,p_msg      => 'Could not update the TAD compilation status'
         ,p_level    => C_LEVEL_ERROR);
      END IF;
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   --If success in all phases return TRUE Else FALSE
   RETURN l_return_value;

EXCEPTION
WHEN ge_fatal_error
THEN
   --If the TAD name is not null the TAD exists
   IF l_tad_name IS NOT NULL
   THEN
      --update the compilation status to error
      IF NOT update_tad_compilation_status
       ( p_compilation_status_code      =>
            xla_cmp_common_pkg.G_COMPILE_STATUS_CODE_ERROR
        ,p_application_id               => p_application_id
        ,p_account_definition_code      => p_account_definition_code
        ,p_account_definition_type_code => p_account_definition_type_code
        ,p_amb_context_code             => p_amb_context_code
       )
      THEN
         IF (C_LEVEL_ERROR >= g_log_level) THEN
            trace
            (p_module => l_log_module
            ,p_msg      => 'Could not update the TAD compilation status'
            ,p_level    => C_LEVEL_ERROR);
         END IF;
      END IF;

      --Push a message in the message stack
      --without raising an exception
      xla_exceptions_pkg.raise_message
      ( p_appli_s_name    => 'XLA'
       ,p_msg_name        => 'XLA_TAB_CMP_TAD_FAILED'
       ,p_token_1         => 'TRX_ACCT_DEF'
       ,p_value_1         => l_tad_name
       ,p_msg_mode        => g_msg_mode
      );
   END IF;

   IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
      trace
         ( p_module   => l_log_module
          ,p_msg      => 'EXCEPTION:' ||
                         ' Cannot compile TAD, aborting...'
          ,p_level    => C_LEVEL_EXCEPTION);
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;
   RETURN FALSE;
WHEN xla_exceptions_pkg.application_exception
THEN
   xla_exceptions_pkg.raise_message
      ( p_location       => 'xla_cmp_tad_pkg.compile_tad'
      );
WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      ( p_location        => 'xla_cmp_tad_pkg.compile_tad'
       ,p_msg_mode        => g_msg_mode
      );
   RETURN FALSE;
END compile_tad;


FUNCTION compile_tad_AUTONOMOUS
                           ( p_application_id               IN    NUMBER
                            ,p_account_definition_code      IN    VARCHAR2
                            ,p_account_definition_type_code IN    VARCHAR2
                            ,p_amb_context_code             IN    VARCHAR2
                           )
RETURN BOOLEAN
IS
PRAGMA AUTONOMOUS_TRANSACTION;

   l_return_value BOOLEAN;
   l_log_module   VARCHAR2 (2000);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE || '.compile_tad_AUTONOMOUS';
   END IF;

   l_return_value := compile_tad
         ( p_application_id               => p_application_id
          ,p_account_definition_code      => p_account_definition_code
          ,p_account_definition_type_code => p_account_definition_type_code
          ,p_amb_context_code             => p_amb_context_code
         );

   COMMIT;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   RETURN l_return_value;

EXCEPTION
WHEN ge_fatal_error
THEN
   IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
      trace
         ( p_module   => l_log_module
          ,p_msg      => 'EXCEPTION:' ||
                         ' Cannot compile TAD, aborting...'
          ,p_level    => C_LEVEL_EXCEPTION);
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;
   RETURN FALSE;
WHEN xla_exceptions_pkg.application_exception
THEN
   RAISE;
WHEN OTHERS
THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_cmp_tad_pkg.compile_tad_AUTONOMOUS'
       ,p_msg_mode        => g_msg_mode
      );
   RETURN FALSE;
END compile_tad_AUTONOMOUS;


/*======================================================================+
|                                                                       |
| Private Function                                                      |
|                                                                       |
| create_package_spec                                                   |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
+======================================================================*/
FUNCTION create_package_spec
             (
               p_account_definition_code      IN    VARCHAR2
              ,p_account_definition_type_code IN    VARCHAR2
              ,p_amb_context_code             IN    VARCHAR2
              ,p_package_name                 IN    VARCHAR2
              ,p_table_of_tad_details         IN    gt_table_of_tad_details
              ,p_table_of_adrs                IN    xla_cmp_adr_pkg.gt_table_of_adrs_in
              ,p_adr_specs_text               IN    CLOB
             )
RETURN BOOLEAN
IS
   l_return_value      BOOLEAN;
   l_package_spec_text CLOB;
   l_log_module        VARCHAR2 (2000);

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.create_package_spec';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'BEGIN ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   l_return_value := TRUE;

   --build the package specification
   IF NOT build_package_spec
    (
      p_account_definition_code      => p_account_definition_code
     ,p_account_definition_type_code => p_account_definition_type_code
     ,p_amb_context_code             => p_amb_context_code
     ,p_package_name                 => p_package_name
     ,p_table_of_tad_details         => p_table_of_tad_details
     ,p_table_of_adrs                => p_table_of_adrs
     ,p_adr_specs_text               => p_adr_specs_text
     ,p_package_spec_text            => l_package_spec_text
    )
   THEN
      l_return_value := FALSE;
      IF (C_LEVEL_ERROR >= g_log_level) THEN
         trace
         (p_module => l_log_module
         ,p_msg      => 'ERROR: build_package_spec failed'
         ,p_level    => C_LEVEL_ERROR);
      END IF;
      --Useless to push
      RAISE ge_fatal_error;
   END IF;

   IF NOT xla_cmp_create_pkg.push_database_object
          (
            p_object_name          => p_package_name
           ,p_object_type          => 'PACKAGE'
           ,p_object_owner         => NULL --current user
           ,p_apps_account         => g_application_info.apps_account
           ,p_msg_mode             => G_OA_MESSAGE
           ,p_ddl_text             => l_package_spec_text
          )
   THEN
      l_return_value := FALSE;
      IF (C_LEVEL_ERROR >= g_log_level) THEN
         trace
         (p_module => l_log_module
         ,p_msg      => 'push_database_object failed'
         ,p_level    => C_LEVEL_ERROR);
      END IF;
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         ( p_module   => l_log_module
          ,p_msg      => 'END ' || l_log_module
          ,p_level    => C_LEVEL_PROCEDURE
         );
   END IF;

   RETURN l_return_value;

EXCEPTION
WHEN ge_fatal_error
THEN
   IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            (p_module   => l_log_module
             ,p_msg      => 'EXCEPTION:' ||
                           ' Fatal error, aborting...'
            ,p_level    => C_LEVEL_EXCEPTION);
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || C_DEFAULT_MODULE || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;
   RETURN FALSE;
WHEN xla_exceptions_pkg.application_exception
THEN
   RAISE;
WHEN OTHERS
THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_cmp_tad_pkg.create_package_spec'
       ,p_msg_mode        => g_msg_mode
      );
   RETURN FALSE;

END create_package_spec;




/*======================================================================+
|                                                                       |
| Private Function                                                      |
|                                                                       |
| build_package_spec                                                    |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
+======================================================================*/
FUNCTION build_package_spec
   (
     p_account_definition_code      IN         VARCHAR2
    ,p_account_definition_type_code IN         VARCHAR2
    ,p_amb_context_code             IN         VARCHAR2
    ,p_package_name                 IN         VARCHAR2
    ,p_table_of_tad_details         IN         gt_table_of_tad_details
    ,p_table_of_adrs                IN         xla_cmp_adr_pkg.gt_table_of_adrs_in
    ,p_adr_specs_text               IN         CLOB
    ,p_package_spec_text            OUT NOCOPY CLOB
                )
RETURN BOOLEAN
IS

   l_package_spec_text CLOB;
   l_return_value      BOOLEAN;
   l_log_module        VARCHAR2 (2000);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.build_package_spec';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'BEGIN ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   --take the package specification template
   l_package_spec_text := C_TMPL_TAD_PACKAGE_SPEC;

/*
   --build the package history
   IF NOT build_package_history (l_history )
   THEN
      --not a fatal error
      IF (C_LEVEL_ERROR >= g_log_level) THEN
         trace
         (p_module => l_log_module
         ,p_msg      => 'cannot build package history'
         ,p_level    => C_LEVEL_ERROR);
      END IF;
      l_return_value := FALSE;
   END IF;


   --replace the history token
   p_package_spec_text := REPLACE
                      (
                        p_package_spec_text
                       ,'$HISTORY$'
                       ,RPAD( l_history
                             , 66
                             , ' '
                            ) || '|'
                      );
*/

   --replace the ADR functions declarations token
   l_package_spec_text:= xla_cmp_common_pkg.replace_token
         (
           p_original_text    => l_package_spec_text
          ,p_token            => '$TAD_ADR_FUNCT_SPECS$'
          ,p_replacement_text => p_adr_specs_text
         );

   --replace the package name tokens
   l_package_spec_text := xla_cmp_string_pkg.replace_token
                    (
                       l_package_spec_text
                      ,'$TAD_PACKAGE_NAME_1$'
                      ,p_package_name
                    );

   l_package_spec_text := xla_cmp_string_pkg.replace_token
                    (
                       l_package_spec_text
                      ,'$TAD_PACKAGE_NAME_2$'
                      ,RPAD( p_package_name
                            , 66
                            , ' '
                           )
                       || '|'
                    );

   l_package_spec_text := xla_cmp_string_pkg.replace_token
                    (
                       l_package_spec_text
                      ,'$TAD_PACKAGE_NAME_3$'
                      ,UPPER(p_package_name)
                    );

   --replace the application name token
   l_package_spec_text := xla_cmp_string_pkg.replace_token
                     (
                       l_package_spec_text
                      ,'$APPLICATION_NAME$'
                      ,RPAD( g_application_info.application_name
                            , 66
                            , ' '
                           ) || '|'
                     );

   --replace the application id token
   l_package_spec_text := xla_cmp_string_pkg.replace_token
                      (
                        l_package_spec_text
                       ,'$APPLICATION_ID$'
                       ,RPAD( TO_CHAR(g_application_info.application_id) || ')'
                             , 49
                             , ' '
                            ) || '|'
                      );


   --replace the TAD info tokens
   l_package_spec_text := xla_cmp_string_pkg.replace_token
                    (
                       l_package_spec_text
                      ,'$TAD_CODE$'
                      ,RPAD( p_account_definition_code
                            , 48
                            , ' '
                           )
                       || '|'
                    );
   l_package_spec_text := xla_cmp_string_pkg.replace_token
                    (
                       l_package_spec_text
                      ,'$TAD_TYPE_CODE$'
                      ,RPAD( p_account_definition_type_code
                            , 48
                            , ' '
                           )
                       || '|'
                    );
   l_package_spec_text := xla_cmp_string_pkg.replace_token
                    (
                       l_package_spec_text
                      ,'$AMB_CONTEXT_CODE$'
                      ,RPAD( p_amb_context_code
                            , 48
                            , ' '
                           )
                       || '|'
                    );

   p_package_spec_text := l_package_spec_text;

   l_return_value := TRUE;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   RETURN l_return_value;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception
THEN
   RAISE;
WHEN OTHERS
THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_cmp_tad_pkg.build_package_spec'
       ,p_msg_mode        => g_msg_mode
      );
   RETURN FALSE;

END build_package_spec;



/*======================================================================+
|                                                                       |
| Private Function                                                      |
|                                                                       |
| build_package_history                                                 |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
+======================================================================*/
FUNCTION build_package_history (p_package_history OUT NOCOPY CLOB)
RETURN BOOLEAN
IS
   l_return_value BOOLEAN;
l_log_module                 VARCHAR2 (2000);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.build_package_history';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'BEGIN ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   p_package_history := TO_CHAR(SYSDATE, 'DD-MON-RR')
                        || ' XLA '
                        || 'Generated by Oracle Subledger Accounting Compiler';

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   RETURN l_return_value;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception
THEN
   RAISE;
WHEN OTHERS
THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_cmp_tad_pkg.build_package_history'
       ,p_msg_mode        => g_msg_mode
      );
   RETURN FALSE;
END build_package_history;



/*======================================================================+
|                                                                       |
| Private Function                                                      |
|                                                                       |
| create_package_body                                                   |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
+======================================================================*/
FUNCTION create_package_body
(
  p_account_definition_code      IN    VARCHAR2
 ,p_account_definition_type_code IN    VARCHAR2
 ,p_amb_context_code             IN    VARCHAR2
 ,p_package_name                 IN    VARCHAR2
 ,p_tad_coa_id                   IN    NUMBER
 ,p_table_of_tad_details         IN    gt_table_of_tad_details
 ,p_table_of_adrs                IN    xla_cmp_adr_pkg.gt_table_of_adrs_in
 ,p_table_of_adrs_ext            IN    xla_cmp_adr_pkg.gt_table_of_adrs_out
 ,p_adr_bodies_text              IN    CLOB
)
RETURN BOOLEAN
IS
   l_return_value         BOOLEAN;
   l_package_body_text    CLOB;
   l_tab_api_package_name VARCHAR2(30);
   l_fatal_message_text   VARCHAR2(2000);
   l_log_module           VARCHAR2 (2000);

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.create_package_body';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'BEGIN ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   --build the package body
   IF NOT build_package_body
     (
       p_account_definition_code      => p_account_definition_code
      ,p_account_definition_type_code => p_account_definition_type_code
      ,p_amb_context_code             => p_amb_context_code
      ,p_package_name                 => p_package_name
      ,p_tad_coa_id                   => p_tad_coa_id
      ,p_table_of_tad_details         => p_table_of_tad_details
      ,p_table_of_adrs                => p_table_of_adrs
      ,p_table_of_adrs_ext            => p_table_of_adrs_ext
      ,p_package_body_text            => l_package_body_text
      ,p_adr_bodies_text              => p_adr_bodies_text
     )
   THEN
      l_return_value := FALSE;
      IF (C_LEVEL_ERROR >= g_log_level) THEN
         trace
         (p_module => l_log_module
         ,p_msg      => 'build_package_body failed'
         ,p_level    => C_LEVEL_ERROR);
      END IF;
      --Useless to push
      RAISE ge_fatal_error;
   END IF;

   IF NOT xla_cmp_create_pkg.push_database_object
                    (
                      p_object_name         => p_package_name
                     ,p_object_type         => 'PACKAGE BODY'
                     ,p_object_owner        => NULL --current user
                     ,p_apps_account        => g_application_info.apps_account
                     ,p_msg_mode            => G_OA_MESSAGE
                     ,p_ddl_text            => l_package_body_text
                    )
   THEN
      l_return_value := FALSE;
      IF (C_LEVEL_ERROR >= g_log_level) THEN
         trace
         (p_module => l_log_module
         ,p_msg      => 'push_database_object failed'
         ,p_level    => C_LEVEL_ERROR);
      END IF;
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   RETURN l_return_value;
EXCEPTION
WHEN ge_fatal_error
THEN
   IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            (p_module   => l_log_module
            ,p_msg      => 'EXCEPTION:' ||
                           ' Fatal error, aborting...'
            ,p_level    => C_LEVEL_EXCEPTION);
   END IF;
   IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            (p_module   => l_log_module
            ,p_msg      => l_fatal_message_text
            ,p_level    => C_LEVEL_EXCEPTION);
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;
   RETURN FALSE;
WHEN xla_exceptions_pkg.application_exception
THEN
   xla_exceptions_pkg.raise_message
      (p_location        => 'xla_cmp_tad_pkg.create_package_body'
       ,p_msg_mode       => 'NON_STANDARD'
      );
   RETURN FALSE;
WHEN OTHERS
THEN
   xla_exceptions_pkg.raise_message
      (p_location        => 'xla_cmp_tad_pkg.create_package_body'
       ,p_msg_mode        => g_msg_mode
      );
   RETURN FALSE;
END create_package_body;


/*======================================================================+
|                                                                       |
| Private Function                                                      |
|                                                                       |
| build_package_body                                                    |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
+======================================================================*/
FUNCTION build_package_body
(
  p_account_definition_code      IN         VARCHAR2
 ,p_account_definition_type_code IN         VARCHAR2
 ,p_amb_context_code             IN         VARCHAR2
 ,p_package_name                 IN         VARCHAR2
 ,p_tad_coa_id                   IN         NUMBER
 ,p_table_of_tad_details         IN         gt_table_of_tad_details
 ,p_table_of_adrs                IN         xla_cmp_adr_pkg.gt_table_of_adrs_in
 ,p_table_of_adrs_ext            IN         xla_cmp_adr_pkg.gt_table_of_adrs_out
 ,p_adr_bodies_text              IN         CLOB
 ,p_package_body_text            OUT NOCOPY CLOB
)
RETURN BOOLEAN
IS
   l_history                     CLOB;

   l_push_interf_statements_text CLOB;
   l_pop_interf_statements_text  CLOB;

   l_update_statements_text      CLOB;

   l_batch_ccid_proc_stmts_text  CLOB;
   l_package_body_text           CLOB;

   l_return_value               BOOLEAN;
   l_log_module                 VARCHAR2 (2000);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.build_package_body';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'BEGIN ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   l_return_value := TRUE;

   --Build the statements to move data from/to the plsql tab
   --and the global temp table
   IF NOT build_move_interf_data_stmts
     (
       p_table_of_tad_details        => p_table_of_tad_details
      ,p_tad_coa_id                  => p_tad_coa_id
      ,x_push_interf_statements_text => l_push_interf_statements_text
      ,x_pop_interf_statements_text  => l_pop_interf_statements_text
     )
   THEN
      l_return_value := FALSE;
      IF (C_LEVEL_ERROR >= g_log_level) THEN
         trace
            (p_module   => l_log_module
            ,p_msg      => 'ERROR:' ||
                           ' build_move_interf_data_stmts failed'
            ,p_level    => C_LEVEL_ERROR);
      END IF;
   END IF;

   --Build the statements process data into the global temp table
   IF NOT build_batch_update_statements
     (
       p_table_of_tad_details         => p_table_of_tad_details
      ,p_table_of_adrs                => p_table_of_adrs
      ,p_table_of_adrs_ext            => p_table_of_adrs_ext
      ,p_update_statements_text       => l_update_statements_text
     )
   THEN
      l_return_value := FALSE;
      IF (C_LEVEL_ERROR >= g_log_level) THEN
         trace
            (p_module   => l_log_module
            ,p_msg      => 'ERROR:' ||
                           ' build_batch_update_statements failed'
            ,p_level    => C_LEVEL_ERROR);
      END IF;
   END IF;

   --Build the ccid processing statements
   IF NOT build_static_ccid_prc_stmts
        (
          p_table_of_tad_details         => p_table_of_tad_details
         ,p_tad_coa_id                   => p_tad_coa_id
         ,p_update_statements_text       => l_batch_ccid_proc_stmts_text
        )
   THEN
      l_return_value := FALSE;
      IF (C_LEVEL_ERROR >= g_log_level) THEN
         trace
            (p_module   => l_log_module
            ,p_msg      => 'ERROR:' ||
                           ' build_static_ccid_prc_stmts failed'
            ,p_level    => C_LEVEL_ERROR);
      END IF;
   END IF;

   --take the package body template
   l_package_body_text := C_TMPL_TAD_PACKAGE_BODY;

   --replace the ADR functions bodies token
   l_package_body_text:= xla_cmp_common_pkg.replace_token
         (
           p_original_text    => l_package_body_text
          ,p_token            => '$TAD_ADR_FUNCT_BODIES$'
          ,p_replacement_text => p_adr_bodies_text
         );

   --replace the push interface data update statements token
   l_package_body_text:= xla_cmp_common_pkg.replace_token
         (
           p_original_text    => l_package_body_text
          ,p_token            => '$C_TMPL_PUSH_INTERF_DATA_STMTS$'
          ,p_replacement_text => NVL(l_push_interf_statements_text, ' ')
         );

   --replace the pop interface data update statements token
   l_package_body_text:= xla_cmp_common_pkg.replace_token
         (
           p_original_text    => l_package_body_text
          ,p_token            => '$C_TMPL_POP_INTERF_DATA_STMTS$'
          ,p_replacement_text => NVL(l_pop_interf_statements_text, ' ')
         );

   --replace the update statements token
   l_package_body_text:= xla_cmp_common_pkg.replace_token
         (
           p_original_text    => l_package_body_text
          ,p_token            => '$C_TMPL_BATCH_CCID_SEG_UPD_STMTS$'
          ,p_replacement_text => NVL(l_update_statements_text, ' ')
         );

   --replace the ccid processing statements token
   l_package_body_text:= xla_cmp_common_pkg.replace_token
         (
           p_original_text    => l_package_body_text
          ,p_token            => '$C_TMPL_BATCH_BUILD_CCID_STMTS$'
          ,p_replacement_text => NVL(l_batch_ccid_proc_stmts_text, ' ')
         );

   --replace the package name tokens
/* Commented due to the bug 6354106
   l_package_body_text := REPLACE
                    (
                       l_package_body_text
                      ,'$TAD_PACKAGE_NAME_1$'
                      ,p_package_name
                    );
   Introducing the following due to the bug 6354106
*/

   l_package_body_text:= xla_cmp_common_pkg.replace_token
         (
           p_original_text    => l_package_body_text
          ,p_token            => '$TAD_PACKAGE_NAME_1$'
          ,p_replacement_text => p_package_name
         );


   l_package_body_text := xla_cmp_string_pkg.replace_token
                    (
                       l_package_body_text
                      ,'$TAD_PACKAGE_NAME_2$'
                      ,RPAD( p_package_name
                            , 66
                            , ' '
                           )
                       || '|'
                    );

   l_package_body_text := xla_cmp_string_pkg.replace_token
                    (
                       l_package_body_text
                      ,'$TAD_PACKAGE_NAME_3$'
                      ,LOWER(p_package_name)
                    );


   --replace the application name token
   l_package_body_text := xla_cmp_string_pkg.replace_token
                     (
                       l_package_body_text
                      ,'$APPLICATION_NAME$'
                      ,RPAD( g_application_info.application_name
                            , 66
                            , ' '
                           ) || '|'
                     );

   --replace the application id token
   l_package_body_text := xla_cmp_string_pkg.replace_token
                      (
                        l_package_body_text
                       ,'$APPLICATION_ID$'
                       ,RPAD( TO_CHAR(g_application_info.application_id) || ')'
                             , 49
                             , ' '
                            ) || '|'
                      );
   l_package_body_text := xla_cmp_string_pkg.replace_token
                      (
                        l_package_body_text
                       ,'$APPLICATION_ID_2$'
                       ,TO_CHAR(g_application_info.application_id)
                      );

   --replace the TAD info tokens
   l_package_body_text := xla_cmp_string_pkg.replace_token
                    (
                       l_package_body_text
                      ,'$TAD_CODE$'
                      ,RPAD( p_account_definition_code
                            , 48
                            , ' '
                           )
                       || '|'
                    );
   l_package_body_text := xla_cmp_string_pkg.replace_token
                    (
                       l_package_body_text
                      ,'$TAD_CODE_2$'
                      ,p_account_definition_code
                    );

   l_package_body_text := xla_cmp_string_pkg.replace_token
                    (
                       l_package_body_text
                      ,'$TAD_TYPE_CODE$'
                      ,RPAD( p_account_definition_type_code
                            , 48
                            , ' '
                           )
                       || '|'
                    );
   l_package_body_text := xla_cmp_string_pkg.replace_token
                    (
                       l_package_body_text
                      ,'$TAD_TYPE_CODE_2$'
                      ,p_account_definition_type_code
                    );

   l_package_body_text := xla_cmp_string_pkg.replace_token
                    (
                       l_package_body_text
                      ,'$AMB_CONTEXT_CODE$'
                      ,RPAD( p_amb_context_code
                            , 48
                            , ' '
                           )
                       || '|'
                    );
   l_package_body_text := xla_cmp_string_pkg.replace_token
                    (
                       l_package_body_text
                      ,'$AMB_CONTEXT_CODE_2$'
                      ,p_amb_context_code
                    );

   --Assign the OUT params
   p_package_body_text := l_package_body_text;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   RETURN l_return_value;

EXCEPTION
WHEN ge_fatal_error
THEN
   IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            (p_module   => l_log_module
             ,p_msg      => 'EXCEPTION:' ||
                           ' Fatal error, aborting...'
            ,p_level    => C_LEVEL_EXCEPTION);
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;
   RETURN FALSE;
WHEN xla_exceptions_pkg.application_exception
THEN
   RAISE;
WHEN OTHERS
THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_cmp_tad_pkg.build_package_body'
       ,p_msg_mode        => g_msg_mode
      );
   RETURN FALSE;
END build_package_body;



/*======================================================================+
|                                                                       |
| Private Function                                                      |
|                                                                       |
| build_batch_update_statements                                         |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
+======================================================================*/
FUNCTION build_batch_update_statements
(
  p_table_of_tad_details   IN         gt_table_of_tad_details
 ,p_table_of_adrs          IN         xla_cmp_adr_pkg.gt_table_of_adrs_in
 ,p_table_of_adrs_ext      IN         xla_cmp_adr_pkg.gt_table_of_adrs_out
 ,p_update_statements_text OUT NOCOPY CLOB
)
RETURN BOOLEAN
IS
l_update_statement_text     CLOB;
l_update_statements_text    CLOB;
l_set_clause_text           CLOB;
l_set_clauses_text          CLOB;
l_case_branch_text          CLOB;
l_case_branches_text        CLOB;
l_adr_funct_params          CLOB;
l_current_object_name_affix VARCHAR2(10);
l_current_flex_segment_code VARCHAR2(30);
l_current_account_type_code VARCHAR2(30);
l_current_temp_table_name   VARCHAR2(30);
l_dummy                     VARCHAR2(30);
l_adr_function_name         VARCHAR2(30);
l_table_of_adr_sources      xla_cmp_adr_pkg.gt_table_of_adr_sources;
l_fatal_message_text        VARCHAR2(2000);
l_return_value              BOOLEAN;
l_log_module                VARCHAR2 (2000);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.build_batch_update_statements';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'BEGIN ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   l_return_value := TRUE;

   l_current_object_name_affix := NULL;
   l_current_flex_segment_code := NULL;
   l_current_account_type_code := NULL;
   FOR i IN p_table_of_tad_details.FIRST .. p_table_of_tad_details.LAST
   LOOP
      --If it is the first detail
      --or the affix changes
      --we need a new update statement
      IF    (i = p_table_of_tad_details.FIRST)
         OR (   NVL(l_current_object_name_affix, 'a')
             <> NVL(p_table_of_tad_details(i).object_name_affix, 'a')
            )
      THEN
         --If not the first detail there is a SQL statement in the pipeline
         IF i <> p_table_of_tad_details.FIRST
         THEN
            --Chain the current case branch with the existing ones
            l_case_branches_text := l_case_branches_text || l_case_branch_text;

            --Replace the current case branches to the current set clause
            l_set_clause_text:= xla_cmp_common_pkg.replace_token
               (
                 p_original_text    => l_set_clause_text
                ,p_token            => '$CASE_BRANCHES$'
                ,p_replacement_text => NVL(l_case_branches_text, ' ')
               );

            --Concatenate the current set clause to the already existing ones
            l_set_clauses_text := l_set_clauses_text || l_set_clause_text;

            --Replace the accumulated update set clauses
            --in the current upd statement
            l_update_statement_text:= xla_cmp_common_pkg.replace_token
               (
                 p_original_text    => l_update_statement_text
                ,p_token            => '$C_TMPL_SET_CLAUSES$'
                ,p_replacement_text => NVL(l_set_clauses_text, ' ')
               );

            --Concatenate the current upd statement to the existing ones
            l_update_statements_text    := l_update_statements_text || l_update_statement_text;

            --Null out the partial elements that have been consumed now
            l_case_branch_text          := NULL;
            l_case_branches_text        := NULL;
            l_set_clause_text           := NULL;
            l_set_clauses_text          := NULL;
            l_update_statement_text     := NULL;

            --The new update statement has no dependency on the previous ones
            l_current_account_type_code := NULL;
            l_current_flex_segment_code := NULL;
         END IF;

         --Retrieve the affix of the TAT associated to the current detail
         l_current_object_name_affix := p_table_of_tad_details(i).object_name_affix;

         --Get the global temporary table name for the affix
         IF NOT xla_cmp_tab_pkg.get_interface_object_names
            (
              p_application_id    => g_application_info.application_id
             ,p_object_name_affix => l_current_object_name_affix
             ,x_global_table_name => l_current_temp_table_name
             ,x_plsql_table_name  => l_dummy
            )
         THEN
            l_fatal_message_text := 'get_interface_object_names failed';
         END IF;

         --Get the update statement template
         l_update_statement_text     := C_TMPL_BATCH_CCID_SEG_UPD_STMT;

         --Replace the table name token
         l_update_statement_text:= xla_cmp_string_pkg.replace_token(
                                   l_update_statement_text
                                  ,'$table_name$'
                                  ,NVL(l_current_temp_table_name, ' ')
                                 );
      END IF; --new update statement

      --If the segment code has changed or is the first one we process
      --initialize a new set clause
      IF   (   l_current_flex_segment_code
            <> p_table_of_tad_details(i).flexfield_segment_code
           )
        OR l_current_flex_segment_code IS NULL
      THEN
         l_current_flex_segment_code
            := p_table_of_tad_details(i).flexfield_segment_code;
         --If there is a pending set clause
         IF l_set_clause_text IS NOT NULL
         THEN
            --Chain the current case branch with the existing ones
            l_case_branches_text := l_case_branches_text || l_case_branch_text;
            --Replace the current case branches in the current set clause
            l_set_clause_text:= xla_cmp_common_pkg.replace_token
               (
                 p_original_text    => l_set_clause_text
                ,p_token            => '$CASE_BRANCHES$'
                ,p_replacement_text => NVL(l_case_branches_text, ' ')
               );

            --Chain it to the other clauses
            l_set_clauses_text := l_set_clauses_text || l_set_clause_text;

            --Null out the partial elements that have been consumed now
            l_case_branch_text      := NULL;
            l_case_branches_text    := NULL;
            l_set_clause_text       := NULL;

            --The new set clause has no dependency on the previous one
            l_current_account_type_code := NULL;
         END IF;

         --If there is already some set clause we need to add a comma
         --at the beginning of the clause
         IF l_set_clauses_text IS NOT NULL
            THEN
            l_set_clause_text := '         ,';
         ELSE
            l_set_clause_text := '          ';
         END IF;

         --If the flex segment code is ALL
         IF p_table_of_tad_details(i).flexfield_segment_code = 'ALL'
         THEN
            --Get the template for the ccid SET clause
            l_set_clause_text := l_set_clause_text || C_TMPL_SET_CCID;
         ELSE
            l_set_clause_text := l_set_clause_text || C_TMPL_SET_SEGMENT;
            l_set_clause_text :=
               xla_cmp_string_pkg.replace_token(
                  l_set_clause_text
                 ,'$SEGMENT_COLUMN_NAME$'
                 ,p_table_of_tad_details(i).flexfield_segment_code
                );
         END IF;
      END IF;

      --If the TAT code has changed or is NULL we need a new case branch
      IF   (   l_current_account_type_code
            <> p_table_of_tad_details(i).account_type_code
           )
         OR l_current_account_type_code IS NULL
      THEN
         --Chain the current case branch with the existing ones
         l_case_branches_text := l_case_branches_text || l_case_branch_text;
         l_case_branch_text := C_TMPL_CASE_BRANCH;

         --Get the TAT code of the current detail
         l_current_account_type_code := p_table_of_tad_details(i).account_type_code;

         --Replace the account type token in the new branch
         l_case_branch_text:= xla_cmp_common_pkg.replace_token
         (
           p_original_text    => l_case_branch_text
          ,p_token            => '$ACCOUNT_TYPE$'
          ,p_replacement_text => NVL(l_current_account_type_code, ' ')
         );

      END IF; --new TAT code

      --Get the ADR function name associated to the detail
      l_adr_function_name := NULL;
      IF p_table_of_adrs.FIRST IS NOT NULL
      THEN
         FOR adr_index IN p_table_of_adrs.FIRST..p_table_of_adrs.LAST
         LOOP
            IF     p_table_of_adrs(adr_index).application_id
                   = p_table_of_tad_details(i).application_id
               AND p_table_of_adrs(adr_index).segment_rule_type_code
                   = p_table_of_tad_details(i).segment_rule_type_code
               AND p_table_of_adrs(adr_index).segment_rule_code
                   = p_table_of_tad_details(i).segment_rule_code
               AND p_table_of_adrs(adr_index).amb_context_code
                   = p_table_of_tad_details(i).amb_context_code
            THEN
               --Get the ADR function name
               l_adr_function_name
               := p_table_of_adrs_ext(adr_index).adr_function_name;

               --Get the source parameter list for the function
               l_table_of_adr_sources
               := p_table_of_adrs_ext(adr_index).table_of_sources;
               EXIT;
            END IF;
         END LOOP;
      END IF;

      --Replace the function name token
      l_case_branch_text:= xla_cmp_string_pkg.replace_token(
                                   l_case_branch_text
                                  ,'$ADR_FUNCT_NAME$'
                                  ,l_adr_function_name
                                 );

      --Concatenate the function source params
      l_adr_funct_params := NULL;
      DECLARE
--         n VARCHAR2(30);
         n NUMBER;
      BEGIN
         n := l_table_of_adr_sources.FIRST;
         WHILE n IS NOT NULL
         LOOP
            --Add the current parameter
            l_adr_funct_params :=    l_adr_funct_params
                                  || '                    ,'
                                  || RPAD(l_table_of_adr_sources(n), 30, ' ')
                                  || '  --p_source_'
                                  || n;
            --Add a linefeed
            l_adr_funct_params :=    l_adr_funct_params ||
'
';
            -- get the subscript of next element
            n := l_table_of_adr_sources.NEXT(n);
         END LOOP;
      END;

      --Replace the function source params token
      l_case_branch_text:= xla_cmp_string_pkg.replace_token(
                                   l_case_branch_text
                                  ,'$C_TMPL_ADR_FUNCT_PARAMS$'
                                  ,NVL(l_adr_funct_params, ' ')
                                 );
   END LOOP;

   --Add the case branch text to the existing ones
   l_case_branches_text := l_case_branches_text || l_case_branch_text;

   --Replace the current case branches in the current set clause
   l_set_clause_text:= xla_cmp_common_pkg.replace_token
         (
           p_original_text    => l_set_clause_text
          ,p_token            => '$CASE_BRANCHES$'
          ,p_replacement_text => NVL(l_case_branches_text, ' ')
         );

   --Concatenate the current set clause to the already existing ones
   l_set_clauses_text := l_set_clauses_text || l_set_clause_text;

   --Replace the accumulated update set clauses in the current upd statement
   l_update_statement_text:= xla_cmp_common_pkg.replace_token
         (
           p_original_text    => l_update_statement_text
          ,p_token            => '$C_TMPL_SET_CLAUSES$'
          ,p_replacement_text => NVL(l_set_clauses_text, ' ')
         );

   --Concatenate the last processed statement
   l_update_statements_text := l_update_statements_text || l_update_statement_text;

   --Assing the out parameter
   p_update_statements_text := l_update_statements_text;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   RETURN l_return_value;

EXCEPTION
WHEN ge_fatal_error
THEN
   IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
      trace
            ( p_module   => l_log_module
             ,p_msg      => 'EXCEPTION:' ||
                           ' Fatal error, aborting...'
             ,p_level    => C_LEVEL_EXCEPTION);
      trace
            ( p_module   => l_log_module
             ,p_msg      => l_fatal_message_text
             ,p_level    => C_LEVEL_EXCEPTION);
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;
   RETURN FALSE;
WHEN xla_exceptions_pkg.application_exception
THEN
   RAISE;
WHEN OTHERS
THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_cmp_tad_pkg.build_batch_update_statements'
       ,p_msg_mode        => g_msg_mode
      );
   RETURN FALSE;
END build_batch_update_statements;

/*======================================================================+
|                                                                       |
| Private Function                                                      |
|                                                                       |
| build_static_ccid_prc_stmts                                           |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
+======================================================================*/
FUNCTION build_static_ccid_prc_stmts
(
  p_table_of_tad_details   IN         gt_table_of_tad_details
 ,p_tad_coa_id             IN         NUMBER
 ,p_update_statements_text OUT NOCOPY CLOB
)
RETURN BOOLEAN
IS
l_update_statement_text        CLOB;
l_update_statements_text       CLOB;

l_tmpl_where_segment_null_and  CLOB;
l_tmpl_where_segment_null_ands CLOB;
l_tmpl_where_segment_null_or   CLOB;
l_tmpl_where_segment_null_ors  CLOB;
l_tmpl_upd_set_segment_comma   CLOB;
l_tmpl_upd_set_segment_commas  CLOB;
l_tmpl_sel_nvl_segment_comma   CLOB;
l_tmpl_sel_nvl_segment_commas  CLOB;
l_tmpl_where_segments_equal    CLOB;
l_tmpl_where_segments_equals   CLOB;
l_tmpl_concat_segments         CLOB;

l_current_object_name_affix VARCHAR2(10);
l_current_temp_table_name   VARCHAR2(30);
l_dummy                     VARCHAR2(30);

l_table_segment_qualifiers     gt_table_V30_V30;
l_table_segment_column_names   gt_table_V30;
l_flex_delimiter               VARCHAR2(1);
l_concat_segments_template     VARCHAR2(1000);
l_chart_of_accounts_name       VARCHAR2(80);

l_fatal_message_text        VARCHAR2(2000);
l_return_value              BOOLEAN;
l_log_module                VARCHAR2 (2000);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.build_static_ccid_prc_stmts';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'BEGIN ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   l_return_value := TRUE;

   IF p_tad_coa_id IS NULL
   THEN
      l_update_statements_text := C_TMPL_BATCH_BLD_CCID_DYN_STMS;
   ELSE
      --retrieve the active flex segments
      IF NOT get_coa_info
      (
        p_chart_of_accounts_id       => p_tad_coa_id
       ,p_chart_of_accounts_name     => l_chart_of_accounts_name
       ,p_flex_delimiter             => l_flex_delimiter
       ,p_concat_segments_template   => l_concat_segments_template
       ,p_table_segment_qualifiers   => l_table_segment_qualifiers
       ,p_table_segment_column_names => l_table_segment_column_names
      )
      THEN
         l_return_value := FALSE;
         IF (C_LEVEL_ERROR >= g_log_level) THEN
            trace
            (p_module   => l_log_module
            ,p_msg      => 'ERROR:' ||
                           ' get_coa_info failed'
            ,p_level    => C_LEVEL_ERROR);
         END IF;
      END IF;

      --Build the common token values
      FOR i IN l_table_segment_column_names.FIRST..l_table_segment_column_names.LAST
      LOOP
         --C_TMPL_WHERE_SEGMENT_NULL_ANDS
         l_tmpl_where_segment_null_and := xla_cmp_string_pkg.replace_token
                                          ( '
    AND gt.$SEGMENT_COLUMN_NAME$ IS NULL '
                                           ,'$SEGMENT_COLUMN_NAME$'
                                           ,l_table_segment_column_names(i)
                                          );
         l_tmpl_where_segment_null_ands :=   l_tmpl_where_segment_null_ands
                                          || l_tmpl_where_segment_null_and;


         --C_TMPL_WHERE_SEGMENT_NULL_ORS

         l_tmpl_where_segment_null_or := CASE i
                                         WHEN 1 THEN '   '
                                         ELSE '        OR '
                                         END
                                         ||
                                         xla_cmp_string_pkg.replace_token
                                         ( ' gt.$SEGMENT_COLUMN_NAME$ IS NULL
'
                                          ,'$SEGMENT_COLUMN_NAME$'
                                          ,l_table_segment_column_names(i)
                                         );

         l_tmpl_where_segment_null_ors :=   l_tmpl_where_segment_null_ors
                                          || l_tmpl_where_segment_null_or;

         --C_TMPL_UPD_SET_SEGMENT_COMMA
         l_tmpl_upd_set_segment_comma  := CASE i
                                         WHEN 1 THEN '         '
                                         ELSE '        ,'
                                         END
                                         ||
                                         xla_cmp_string_pkg.replace_token
                                            ( ' gt.$SEGMENT_COLUMN_NAME$
'
                                             ,'$SEGMENT_COLUMN_NAME$'
                                             ,l_table_segment_column_names(i)
                                            );

         l_tmpl_upd_set_segment_commas :=   l_tmpl_upd_set_segment_commas
                                          || l_tmpl_upd_set_segment_comma;

         --C_TMPL_SEL_NVL_SEGMENT_COMMA
         l_tmpl_sel_nvl_segment_comma  := CASE i
                                         WHEN 1 THEN '                '
                                         ELSE '               ,'
                                         END
                                         ||
                                         xla_cmp_string_pkg.replace_token
                                         ( ' NVL(gt.$SEGMENT_COLUMN_NAME$, gcc.$SEGMENT_COLUMN_NAME$)
'
                                          ,'$SEGMENT_COLUMN_NAME$'
                                          ,l_table_segment_column_names(i)
                                         );

         l_tmpl_sel_nvl_segment_commas :=   l_tmpl_sel_nvl_segment_commas
                                          || l_tmpl_sel_nvl_segment_comma;

         --C_TMPL_WHERE_SEGMENTS_EQUAL
         l_tmpl_where_segments_equal := xla_cmp_string_pkg.replace_token
                                          ( '                                AND gcc.$SEGMENT_COLUMN_NAME$ = gt.$SEGMENT_COLUMN_NAME$
'
                                           ,'$SEGMENT_COLUMN_NAME$'
                                           ,l_table_segment_column_names(i)
                                          );
         l_tmpl_where_segments_equals :=   l_tmpl_where_segments_equals
                                          || l_tmpl_where_segments_equal;

         IF i = 1
         THEN
            l_tmpl_concat_segments := '             '
                                      || l_table_segment_column_names(i);
         ELSE
            l_tmpl_concat_segments := l_tmpl_concat_segments
                                      || '
'
                                      || '             || ''' || l_flex_delimiter || ''' || '
                                      || l_table_segment_column_names(i);
         END IF;

      END LOOP;

      l_current_object_name_affix := NULL;

      FOR i IN p_table_of_tad_details.FIRST .. p_table_of_tad_details.LAST
      LOOP
      --If it is the first detail
      --or the affix changes
      --we need a new update statement
         IF    (i = p_table_of_tad_details.FIRST)
            OR (   NVL(l_current_object_name_affix, 'a')
                <> NVL(p_table_of_tad_details(i).object_name_affix, 'a')
               )
         THEN
            --Concatenate the current upd statement to the existing ones
            l_update_statements_text    := l_update_statements_text || l_update_statement_text;

            --Null out the partial elements that have been consumed now
            l_update_statement_text     := NULL;

            --Retrieve the affix of the TAT associated to the current detail
            l_current_object_name_affix := p_table_of_tad_details(i).object_name_affix;

            --Get the global temporary table name for the affix
            IF NOT xla_cmp_tab_pkg.get_interface_object_names
            (
              p_application_id    => g_application_info.application_id
             ,p_object_name_affix => l_current_object_name_affix
             ,x_global_table_name => l_current_temp_table_name
             ,x_plsql_table_name  => l_dummy
            )
            THEN
               l_fatal_message_text := 'get_interface_object_names failed';
            END IF;

            --Get the update statement template
            l_update_statement_text     := C_TMPL_BATCH_BUILD_CCID_STMTS;

            --Replace the table name token
            l_update_statement_text:= xla_cmp_string_pkg.replace_token(
                                   l_update_statement_text
                                  ,'$TABLE_NAME$'
                                  ,NVL(l_current_temp_table_name, ' ')
                                 );

            --Replace the common tokens
            l_update_statement_text:= xla_cmp_string_pkg.replace_token(
                                   l_update_statement_text
                                  ,'$C_TMPL_WHERE_SEGMENT_NULL_ANDS$'
                                  ,NVL(l_tmpl_where_segment_null_ands, ' ')
                                 );

            l_update_statement_text:= xla_cmp_string_pkg.replace_token(
                                   l_update_statement_text
                                  ,'$C_TMPL_WHERE_SEGMENT_NULL_ORS$'
                                  ,NVL(l_tmpl_where_segment_null_ors, ' ')
                                 );

            l_update_statement_text:= xla_cmp_string_pkg.replace_token(
                                   l_update_statement_text
                                  ,'$C_TMPL_UPD_SET_SEGMENT_COMMAS$'
                                  ,NVL(l_tmpl_upd_set_segment_commas, ' ')
                                 );

            l_update_statement_text:= xla_cmp_string_pkg.replace_token(
                                   l_update_statement_text
                                  ,'$C_TMPL_SEL_NVL_SEGMENT_COMMAS$'
                                  ,NVL(l_tmpl_sel_nvl_segment_commas, ' ')
                                 );

            l_update_statement_text:= xla_cmp_string_pkg.replace_token(
                                   l_update_statement_text
                                  ,'$C_TMPL_WHERE_SEGMENTS_EQUALS$'
                                  ,NVL(l_tmpl_where_segments_equals, ' ')
                                 );

            l_update_statement_text:= xla_cmp_string_pkg.replace_token(
                                   l_update_statement_text
                                  ,'$C_TMPL_CONCAT_SEGMENTS$'
                                  ,NVL(l_tmpl_concat_segments, ' ')
                                 );

         ELSE
            --No action required
            NULL;
         END IF; --new update statement
      END LOOP;

      --Concatenate the last processed statement
      l_update_statements_text := l_update_statements_text || l_update_statement_text;

   END IF;

   --Assing the out parameter
   p_update_statements_text := l_update_statements_text;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   RETURN l_return_value;

EXCEPTION
WHEN ge_fatal_error
THEN
   IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
      trace
            ( p_module   => l_log_module
             ,p_msg      => 'EXCEPTION:' ||
                           ' Fatal error, aborting...'
             ,p_level    => C_LEVEL_EXCEPTION);
      trace
            ( p_module   => l_log_module
             ,p_msg      => l_fatal_message_text
             ,p_level    => C_LEVEL_EXCEPTION);
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;
   RETURN FALSE;
WHEN xla_exceptions_pkg.application_exception
THEN
   RAISE;
WHEN OTHERS
THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_cmp_tad_pkg.build_static_ccid_prc_stmts'
       ,p_msg_mode        => g_msg_mode
      );
   RETURN FALSE;
END build_static_ccid_prc_stmts;



/*======================================================================+
|                                                                       |
| Private Function                                                      |
|                                                                       |
| build_move_interf_data_stmts                                          |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
+======================================================================*/
FUNCTION build_move_interf_data_stmts
(
  p_table_of_tad_details        IN         gt_table_of_tad_details
 ,p_tad_coa_id                  IN         NUMBER
 ,x_push_interf_statements_text OUT NOCOPY CLOB
 ,x_pop_interf_statements_text  OUT NOCOPY CLOB
)
RETURN BOOLEAN
IS
l_push_interf_statement_text   CLOB;
l_push_interf_statements_text  CLOB;

l_pop_interf_statement_text    CLOB;
l_pop_interf_statements_text   CLOB;

l_tmpl_tab_push_interf_sources CLOB;
l_tmpl_tab_pop_interf_sources  CLOB;

l_tab_api_package_name         VARCHAR2(30);

l_current_object_name_affix    VARCHAR2(10);
l_current_temp_table_name      VARCHAR2(30);
l_current_plsql_table_name     VARCHAR2(30);

l_table_of_sources            xla_cmp_tab_pkg.gt_table_of_varchar2_30;
l_table_of_source_datatypes   xla_cmp_tab_pkg.gt_table_of_varchar2_1;

l_fatal_message_text          VARCHAR2(2000);
l_return_value                BOOLEAN;
l_log_module                  VARCHAR2 (2000);

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.build_move_interf_data_stmts';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'BEGIN ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   l_return_value := TRUE;

   --Get the TAB API package for the application
   IF NOT xla_cmp_tab_pkg.get_tab_api_package_name
            (
              p_application_id       => g_application_info.application_id
             ,x_tab_api_package_name => l_tab_api_package_name
            )
   THEN
      l_fatal_message_text := 'get_tab_api_package_name failed';
      RAISE ge_fatal_error;
   END IF;

   l_current_object_name_affix := NULL;

   FOR i IN p_table_of_tad_details.FIRST .. p_table_of_tad_details.LAST
   LOOP
      --If it is the first detail
      --or the affix changes
      --we need a new update statement
      IF    (i = p_table_of_tad_details.FIRST)
         OR (   NVL(l_current_object_name_affix, 'a')
             <> NVL(p_table_of_tad_details(i).object_name_affix, 'a')
            )
      THEN
         --Concatenate the current push and pop stmts to the existing ones
         l_push_interf_statements_text    := l_push_interf_statements_text
                                            || l_push_interf_statement_text;

         l_pop_interf_statements_text    := l_pop_interf_statements_text
                                            || l_pop_interf_statement_text;

         --Null out the partial elements that have been consumed now
         l_push_interf_statement_text     := NULL;
         l_pop_interf_statement_text      := NULL;

         --Retrieve the affix of the TAT associated to the current detail
         l_current_object_name_affix := p_table_of_tad_details(i).object_name_affix;

         --Get the global temporary table name for the affix
         IF NOT xla_cmp_tab_pkg.get_interface_object_names
            (
              p_application_id    => g_application_info.application_id
             ,p_object_name_affix => l_current_object_name_affix
             ,x_global_table_name => l_current_temp_table_name
             ,x_plsql_table_name  => l_current_plsql_table_name
            )
         THEN
            l_fatal_message_text := 'get_interface_object_names failed';
            RAISE ge_fatal_error;
         END IF;

         --Get the source list for the affix
         IF NOT xla_cmp_tab_pkg.get_interface_sources
            (
              p_application_id            => g_application_info.application_id
             ,p_object_name_affix         => l_current_object_name_affix
             ,x_table_of_sources          => l_table_of_sources
             ,x_table_of_source_datatypes => l_table_of_source_datatypes

            )
         THEN
            l_fatal_message_text := 'get_source_list failed';
            RAISE ge_fatal_error;
         END IF;

         l_tmpl_tab_push_interf_sources := NULL;
         l_tmpl_tab_pop_interf_sources  := NULL;

         FOR source_index IN l_table_of_sources.FIRST..l_table_of_sources.LAST
         LOOP
            l_tmpl_tab_push_interf_sources :=   l_tmpl_tab_push_interf_sources
                                    || xla_cmp_string_pkg.replace_token
                                       (
                                         C_TMPL_TAB_PUSH_INTERF_SOURCE
                                        ,'$SOURCE_CODE$'
                                        ,NVL( l_table_of_sources(source_index)
                                             , ' ')
                                       );
            l_tmpl_tab_pop_interf_sources :=   l_tmpl_tab_pop_interf_sources
                                    || xla_cmp_string_pkg.replace_token
                                       (
                                         C_TMPL_TAB_POP_INTERF_SOURCE
                                        ,'$SOURCE_CODE$'
                                        ,NVL( l_table_of_sources(source_index)
                                             , ' ')
                                       );
         END LOOP;

         --Get the push/pop statement template
         l_push_interf_statement_text     := C_TMPL_PUSH_INTERF_DATA_STMT;
         l_pop_interf_statement_text      := C_TMPL_POP_INTERF_DATA_STMT;

         --Replace the table name token
         l_push_interf_statement_text:= xla_cmp_string_pkg.replace_token
                                 (
                                   l_push_interf_statement_text
                                  ,'$TABLE_NAME$'
                                  ,NVL(l_current_temp_table_name, ' ')
                                 );
         l_pop_interf_statement_text:= xla_cmp_string_pkg.replace_token
                                 (
                                   l_pop_interf_statement_text
                                  ,'$TABLE_NAME$'
                                  ,NVL(l_current_temp_table_name, ' ')
                                 );

         --Replace the plsql table name token
         l_push_interf_statement_text:= xla_cmp_string_pkg.replace_token
                                 (
                                   l_push_interf_statement_text
                                  ,'$PLSQL_TABLE_NAME$'
                                  ,NVL(l_current_plsql_table_name, ' ')
                                 );
         l_pop_interf_statement_text:= xla_cmp_string_pkg.replace_token
                                 (
                                   l_pop_interf_statement_text
                                  ,'$PLSQL_TABLE_NAME$'
                                  ,NVL(l_current_plsql_table_name, ' ')
                                 );

         --Replace the TAB API package name token
         l_push_interf_statement_text:= xla_cmp_string_pkg.replace_token
                                 (
                                   l_push_interf_statement_text
                                  ,'$TAB_API_PACKAGE_NAME$'
                                  ,NVL(l_tab_api_package_name, ' ')
                                 );
         l_pop_interf_statement_text:= xla_cmp_string_pkg.replace_token
                                 (
                                   l_pop_interf_statement_text
                                  ,'$TAB_API_PACKAGE_NAME$'
                                  ,NVL(l_tab_api_package_name, ' ')
                                 );

         --Replace the source list token
         l_push_interf_statement_text:= xla_cmp_string_pkg.replace_token
                                 (
                                   l_push_interf_statement_text
                                  ,'$C_TMPL_TAB_PUSH_INTERF_SOURCES$'
                                  ,NVL(l_tmpl_tab_push_interf_sources, ' ')
                                 );
         l_pop_interf_statement_text:= xla_cmp_string_pkg.replace_token
                                 (
                                   l_pop_interf_statement_text
                                  ,'$C_TMPL_TAB_POP_INTERF_SOURCES$'
                                  ,NVL(l_tmpl_tab_pop_interf_sources, ' ')
                                 );

      ELSE
         --If same affix as previous record, no action is required
         NULL;
      END IF; --new update statement
   END LOOP;

   --Concatenate the last processed statement
   l_push_interf_statements_text :=   l_push_interf_statements_text
                                   || l_push_interf_statement_text;
   l_pop_interf_statements_text  :=   l_pop_interf_statements_text
                                   || l_pop_interf_statement_text;

   --Assing the out parameter
   x_push_interf_statements_text := l_push_interf_statements_text;
   x_pop_interf_statements_text  := l_pop_interf_statements_text;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   RETURN l_return_value;

EXCEPTION
WHEN ge_fatal_error
THEN
   IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
      trace
            ( p_module   => l_log_module
             ,p_msg      => 'EXCEPTION:' ||
                           ' Fatal error, aborting...'
             ,p_level    => C_LEVEL_EXCEPTION);
      trace
            ( p_module   => l_log_module
             ,p_msg      => l_fatal_message_text
             ,p_level    => C_LEVEL_EXCEPTION);
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;
   RETURN FALSE;
WHEN xla_exceptions_pkg.application_exception
THEN
   xla_exceptions_pkg.raise_message
      ( p_location        => 'xla_cmp_tad_pkg.build_move_interf_data_stmts'
       ,p_msg_mode       => 'NON_STANDARD'
      );
   RETURN FALSE;
WHEN OTHERS
THEN
   xla_exceptions_pkg.raise_message
      ( p_location        => 'xla_cmp_tad_pkg.build_move_interf_data_stmts'
       ,p_msg_mode        => g_msg_mode
      );
   RETURN FALSE;
END build_move_interf_data_stmts;




FUNCTION get_tad_package_name
                   (
                      p_application_id               IN         NUMBER
                     ,p_account_definition_code      IN         VARCHAR2
                     ,p_account_definition_type_code IN         VARCHAR2
                     ,p_amb_context_code             IN         VARCHAR2
                     ,p_tad_package_name             OUT NOCOPY VARCHAR2
                   )
RETURN BOOLEAN
IS
   l_return_value               BOOLEAN;
   l_chart_of_accounts_id       NUMBER;
   l_log_module                 VARCHAR2 (2000);

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.get_tad_package_name';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'BEGIN ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   --Initialize global variables
   IF NOT init_global_variables
                         (
                           p_application_id => p_application_id
                         )
   THEN
      --If global vars cannot be set we cannot continue
      IF (C_LEVEL_ERROR >= g_log_level) THEN
         trace
         (p_module => l_log_module
         ,p_msg      => 'init_global_variables failed'
         ,p_level    => C_LEVEL_ERROR);
      END IF;
      l_return_value := FALSE;
      RAISE ge_fatal_error;
   END IF;

   IF NOT get_tad_package_name
      (
        p_account_definition_code      => p_account_definition_code
       ,p_account_definition_type_code => p_account_definition_type_code
       ,p_amb_context_code             => p_amb_context_code
       ,p_tad_package_name             => p_tad_package_name
       ,p_chart_of_accounts_id         => l_chart_of_accounts_id
      )
   THEN
      IF (C_LEVEL_ERROR >= g_log_level) THEN
         trace
         (p_module => l_log_module
         ,p_msg      => 'get_tad_package_name failed'
         ,p_level    => C_LEVEL_ERROR);
      END IF;
      l_return_value := FALSE;
      RAISE ge_fatal_error;
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'p_tad_package_name: ' || p_tad_package_name
         ,p_level    => C_LEVEL_STATEMENT);
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   RETURN TRUE;

EXCEPTION
WHEN ge_fatal_error
THEN
   IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            (p_module   => l_log_module
             ,p_msg      => 'EXCEPTION:' ||
                           ' Fatal error, aborting...'
            ,p_level    => C_LEVEL_EXCEPTION);
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;
   RETURN FALSE;
WHEN xla_exceptions_pkg.application_exception
THEN
   RAISE;
WHEN OTHERS
THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_cmp_tad_pkg.get_tad_package_name'
       ,p_msg_mode        => g_msg_mode
      );
   RETURN FALSE;
END get_tad_package_name;


/*======================================================================+
|                                                                       |
| Private Function                                                      |
|                                                                       |
| It builds the TAB API package name                                    |
| <PROD_ABBR>_XLA_TAB_PKG                                               |
|                                                                       |
|                                                                       |
|                                                                       |
+======================================================================*/
FUNCTION get_tad_package_name
                   (
                      p_account_definition_code      IN  VARCHAR2
                     ,p_account_definition_type_code IN  VARCHAR2
                     ,p_amb_context_code             IN  VARCHAR2
                     ,p_tad_package_name             OUT NOCOPY VARCHAR2
                     ,p_chart_of_accounts_id         OUT NOCOPY NUMBER
                   )
RETURN BOOLEAN
IS
   l_return_value               BOOLEAN;
   C_TMPL_TAD_PKG_NAME CONSTANT VARCHAR2(100)
                    := 'XLA_$APP_HASH_ID$_TAD_$TYPE_CODE$_$TAD_HASH_ID$_PKG';
   --                   -3-_---5---------_-3-_----1------_---10--------_-3-
   l_tad_hash_id                NUMBER;
   l_tad_package_name           VARCHAR2(100);
   l_tad_enabled_flag           VARCHAR2(1);
   l_chart_of_accounts_id       NUMBER;

   l_log_module                 VARCHAR2 (2000);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.get_tad_package_name';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'BEGIN ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'p_account_definition_code: '
                       || NVL(p_account_definition_code, '<NULL>')
         ,p_level    => C_LEVEL_STATEMENT);
   END IF;
   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'p_account_definition_type_code: '
                       || NVL(p_account_definition_type_code, '<NULL>')
         ,p_level    => C_LEVEL_STATEMENT);
   END IF;
   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'p_amb_context_code: '
                       || NVL(p_amb_context_code, '<NULL>')
         ,p_level    => C_LEVEL_STATEMENT);
   END IF;

   --Get TAD Hash Id
   BEGIN
      SELECT xtd.hash_id
            ,xtd.enabled_flag
            ,xtd.chart_of_accounts_id
        INTO l_tad_hash_id
            ,l_tad_enabled_flag
            ,l_chart_of_accounts_id
        FROM xla_tab_acct_defs_b xtd
       WHERE xtd.application_id               = g_application_info.application_id
         AND xtd.account_definition_code      = p_account_definition_code
         AND xtd.account_definition_type_code = p_account_definition_type_code
        AND xtd.amb_context_code             = p_amb_context_code;
   EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            (p_module   => l_log_module
             ,p_msg      => 'EXCEPTION:' ||
                           ' Transaction Account Definition not found'
            ,p_level    => C_LEVEL_EXCEPTION);
      END IF;
      RAISE ge_fatal_error;
   END;

   --If the TAD is disabled abort the execution
   IF l_tad_enabled_flag = 'N'
   THEN
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            (p_module   => l_log_module
             ,p_msg     => 'EXCEPTION:' ||
                           'This TAD is disabled, aborting...'
            ,p_level    => C_LEVEL_EXCEPTION);
      END IF;
      RAISE ge_fatal_error;
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'Current Hash ID: ' || NVL(TO_CHAR(l_tad_hash_id), 'NULL')
         ,p_level    => C_LEVEL_STATEMENT);
   END IF;

   --If the hash_id is NULL
   IF l_tad_hash_id IS NULL
   THEN
      --Get a new one from the DB sequence
      SELECT xla_tab_acct_defs_b_s.NEXTVAL
        INTO l_tad_hash_id
        FROM DUAL;

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
            (p_module   => l_log_module
            ,p_msg      => 'New Hash ID: ' || NVL(TO_CHAR(l_tad_hash_id), 'NULL')
            ,p_level    => C_LEVEL_STATEMENT);
      END IF;

      --Update the TAD record with the hash id
      UPDATE xla_tab_acct_defs_b xtd
         SET xtd.hash_id = l_tad_hash_id
       WHERE xtd.application_id               = g_application_info.application_id
         AND xtd.account_definition_code      = p_account_definition_code
         AND xtd.account_definition_type_code = p_account_definition_type_code
         AND xtd.amb_context_code             = p_amb_context_code;

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
            (p_module   => l_log_module
            ,p_msg      => SQL%ROWCOUNT
                           || ' row(s) updated in xla_tab_acct_defs_b'
            ,p_level    => C_LEVEL_STATEMENT);
      END IF;
   END IF;

   --Get the template for the TAD package name and replace the tokens
   l_tad_package_name := C_TMPL_TAD_PKG_NAME;

   l_tad_package_name := REPLACE( l_tad_package_name
                                 ,'$APP_HASH_ID$'
                                 ,g_application_info.application_hash_id
                                );

   l_tad_package_name := REPLACE( l_tad_package_name
                                 ,'$TYPE_CODE$'
                                 ,p_account_definition_type_code
                                );

   l_tad_package_name := REPLACE( l_tad_package_name
                                 ,'$TAD_HASH_ID$'
                                 ,LPAD ( TO_CHAR(l_tad_hash_id)
                                        ,10
                                        ,'0'
                                       )
                                );

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'l_tad_package_name: ' || l_tad_package_name
         ,p_level    => C_LEVEL_STATEMENT);
   END IF;

   --Assign the out variables
   p_tad_package_name     := l_tad_package_name;
   p_chart_of_accounts_id := l_chart_of_accounts_id;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   RETURN TRUE;

EXCEPTION
WHEN ge_fatal_error
THEN
   IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            (p_module   => l_log_module
             ,p_msg      => 'EXCEPTION:' ||
                           ' Fatal error, aborting...'
            ,p_level    => C_LEVEL_EXCEPTION);
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;
   RETURN FALSE;
WHEN xla_exceptions_pkg.application_exception
THEN
   RAISE;
WHEN OTHERS
THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_cmp_tad_pkg.get_tad_package_name'
       ,p_msg_mode        => g_msg_mode
      );
   RETURN FALSE;
END get_tad_package_name;


FUNCTION get_coa_info
   (
     p_chart_of_accounts_id       IN         NUMBER
    ,p_chart_of_accounts_name     OUT NOCOPY VARCHAR2
    ,p_flex_delimiter             OUT NOCOPY VARCHAR2
    ,p_concat_segments_template   OUT NOCOPY VARCHAR2
    ,p_table_segment_qualifiers   OUT NOCOPY gt_table_V30_V30
    ,p_table_segment_column_names OUT NOCOPY gt_table_V30
   )
RETURN BOOLEAN
IS
le_fatal_error               EXCEPTION;

TYPE lt_table_v30            IS TABLE OF VARCHAR2(30);

l_table_qualifier_names      lt_table_v30;
l_account_segment_column     VARCHAR2(30);
l_flex_delimiter             VARCHAR2(1);

l_table_segment_names        gt_table_v30;

l_concat_segments_string     VARCHAR2(1000);
l_return_value               BOOLEAN;
l_fatal_error_message        VARCHAR2(2000);
l_log_module                 VARCHAR2(2000);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.get_coa_info';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
           ( p_module   => l_log_module
            ,p_msg      => 'BEGIN ' || l_log_module
            ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   l_return_value := TRUE;

   --Get the Chart Of Accounts name
   SELECT id_flex_structure_name
     INTO p_chart_of_accounts_name
     FROM fnd_id_flex_structures_vl ffsvl
    WHERE ffsvl.application_id = 101
      AND ffsvl.id_flex_code   = 'GL#'
      AND ffsvl.id_flex_num    = p_chart_of_accounts_id;

   --Initialize the segment qualifier name list
   l_table_qualifier_names := lt_table_v30
                                 ( 'GL_BALANCING'
                                  ,'GL_ACCOUNT'
                                  ,'GL_INTERCOMPANY'
                                  ,'GL_MANAGEMENT'
                                  ,'FA_COST_CTR'
                                 );

   --For each qualifier (if assigned) we want the segment column name
   FOR i IN l_table_qualifier_names.FIRST .. l_table_qualifier_names.LAST
   LOOP
      IF FND_FLEX_APIS.get_segment_column( 101
                                       ,'GL#'
                                       ,p_chart_of_accounts_id
                                       ,l_table_qualifier_names(i)
                                       ,l_account_segment_column
                                      )
      THEN
         p_table_segment_qualifiers(l_table_qualifier_names(i)) := l_account_segment_column;
      END IF;
   END LOOP;

   l_flex_delimiter := FND_FLEX_EXT.get_delimiter
                   (
                     application_short_name => 'SQLGL'
                    ,key_flex_code          => 'GL#'
                    ,structure_number       => p_chart_of_accounts_id
                   );
   IF l_flex_delimiter IS NULL
   THEN
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            ( p_module   => l_log_module
             ,p_msg      => 'EXCEPTION:'
             ,p_level    => C_LEVEL_EXCEPTION);
         trace
            ( p_module   => l_log_module
             ,p_msg      => 'get_delimiter failed'
             ,p_level    => C_LEVEL_EXCEPTION);
      END IF;
      --The error has been placed on the stack
      RAISE le_fatal_error;
   END IF;


   SELECT UPPER(fifs.application_column_name)
   BULK COLLECT
     INTO l_table_segment_names
     FROM fnd_id_flex_segments fifs
    WHERE fifs.application_id           =  101
      AND fifs.id_flex_code             = 'GL#'
      AND fifs.id_flex_num              = p_chart_of_accounts_id
      AND fifs.enabled_flag             = 'Y'
  ORDER BY fifs.segment_num;

   l_concat_segments_string := NULL;

   IF l_table_segment_names.COUNT > 0
   THEN
      FOR i IN 1..l_table_segment_names.COUNT
      LOOP
         l_concat_segments_string := l_concat_segments_string
                                     || CASE i
                                        WHEN 1 THEN NULL
                                        ELSE l_flex_delimiter
                                        END
                                     || l_table_segment_names(i);
      END LOOP;
   END IF;

   --Assign out param
   p_flex_delimiter             := l_flex_delimiter;
   p_concat_segments_template   := l_concat_segments_string;
   p_table_segment_column_names := l_table_segment_names;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
           ( p_module   => l_log_module
            ,p_msg      => 'END ' || l_log_module
            ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   RETURN l_return_value;
EXCEPTION
WHEN le_fatal_error
THEN
   IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
      trace
            ( p_module   => l_log_module
             ,p_msg      => 'EXCEPTION:'
             ,p_level    => C_LEVEL_EXCEPTION);
      trace
            ( p_module   => l_log_module
             ,p_msg      => 'Fatal error: ' || l_fatal_error_message
             ,p_level    => C_LEVEL_EXCEPTION);
   END IF;
   RETURN FALSE;
WHEN xla_exceptions_pkg.application_exception
THEN
   RAISE;
WHEN OTHERS
THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_cmp_tad_pkg.get_coa_info'
       ,p_msg_mode        => g_msg_mode
      );
   RETURN FALSE;
END get_coa_info;







--Trace initialization
BEGIN
   g_log_level      := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   g_log_enabled    := fnd_log.test
                          (log_level  => g_log_level
                          ,module     => C_DEFAULT_MODULE);

   IF NOT g_log_enabled  THEN
      g_log_level := C_LEVEL_LOG_DISABLED;
   END IF;

END xla_cmp_tad_pkg;

/
