--------------------------------------------------------
--  DDL for Package Body XLA_AE_CODE_COMBINATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_AE_CODE_COMBINATION_PKG" AS
/* $Header: xlajecci.pkb 120.59.12010000.13 2010/03/24 08:06:15 karamakr ship $   */
/*===========================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| PACKAGE NAME                                                               |
|     xla_ae_code_combination_pkg                                            |
|                                                                            |
| DESCRIPTION                                                                |
|                                                                            |
|                                                                            |
| HISTORY                                                                    |
|     20-NOV-2002 K.Boussema    Created                                      |
|     17-MAR-2003 K.Boussema    Made changes for the new bulk approach of the|
|                               accounting engine                            |
|     11-APR-2003 K.Boussema    Include Build Ccid Process                   |
|                                static : create_ccid procedure ,            |
|                                dynamic. create_ccidV2 procedure            |
|                               This package calls the static procedure      |
|     19-APR-2003 K.Boussema    Included Error messages                      |
|     12-MAI-2003 K.Boussema    Updated Message code XLA_AP_CODE_COMBINATION |
|     13-MAI-2003 K.Boussema    Renamed temporary table  xla_je_lines_gt by  |
|                               xla_ae_lines_gt                              |
|     27-MAI-2003 K.Boussema    Renamed code_combination_status by           |
|                                  code_combination_status_flag              |
|     17-JUL-2003 K.Boussema    Reviewd the code                             |
|     24-JUL-2003 K.Boussema    Updated the error messages                   |
|     29-JUL-2003 K.Boussema    Renamed XLA_AP_INVALID_CODE_COMBINATION      |
|                               message code by XLA_AP_INV_CODE_COMBINATION  |
|     30-JUL-2003 K.Boussema    Reviewed the procedure create_ccid()         |
|     28-AUG-2003 K.boussema    Reviewed GetCCid to fix bug 3103575          |
|     01-SEP-2003 K.boussema    Reviewed call to build_message, bug 3099988  |
|     27-SEP-2003 K.Boussema    Added the error message XLA_AP_COA_INVALID   |
|     13-NOV-2003 K.Boussema    Changed to fix issue in bug3252058           |
|     26-NOV-2003 K.Boussema    Added the cache of GL mapping information    |
|     28-NOV-2003 K.Boussema    Changed create_ccid call by create_ccidV2    |
|     12-DEC-2003 K.Boussema    Renamed target_coa_id in xla_ae_lines_gt     |
|                               by ccid_coa_id                               |
|     18-DEC-2003 K.Boussema    Changed to fix bug 3042840,3307761,3268940   |
|                               3310291 and 3320689                          |
|     20-JAN-2004 K.Boussema    Updated the message error XLA_AP_COA_INVALID |
|     03-FEB-2004 K.Boussema    Reviewed get_flexfield_description in order  |
|                               to retrieve segment value description instead|
|                               of the segment description                   |
|     16-FEB-2004 K.Boussema   Made changes for the FND_LOG.                 |
|                              renamed create_ccidV2 by create_ccid          |
|     03-MAR-2004 K.Boussema  Changed to set GL_ACCOUNTS_MAP_GRP debug param.|
|     22-MAR-2004 K.Boussema    Added a parameter p_module to the TRACE calls|
|                               and the procedure.                           |
|     25-MAR-2004 K.Boussema   Changed MapCcid to insert the coa_mapping_id  |
|                              into gl_accounts_map_interface_gt GT GL table |
|     11-MAY-2004 K.Boussema  Removed the call to XLA trace routine from     |
|                             trace() procedure                              |
|                             Revised update of journal entry status defined |
|                             in BuildCcids() function                       |
|     03-JUN-2004 K.Boussema  Added the validaton of the CCIDs passed through|
|                             extract, refer to bug 3656297                  |
|     23-JUN-2004 K.Boussema  Removed the validation of CCIDs, changed error |
|                             message XLA_AP_INVALID_CCID                    |
|                             by XLA_AP_CCID_NOT_EXISTS                      |
|     23-Sep-2004 S.Singhania Minor changes due to bulk performance in calls |
|                               to xla_accrounting_err_pkg.build_message.    |
|     28-Feb-2005 K.boussema  Renamed GT table: gl_accounts_map_interface_gt |
|                             => gl_accts_map_int_gt                         |
|     03-MAR-2005 K.Boussema Reviewed MapCCid() function to fix bug 4197942  |
|     06-MAR-2005 W. Shen    Ledger Currency Project.                        |
|                             maintain two ccids in line table               |
|     14-Mar-2005 K.Boussema Changed for ADR-enhancements.                   |
|     11-APR-2005 K.Boussema Reviewed the code to don't process Dummy lines  |
|     21-APR-2005 Shishir J. Renamed gl_accounts_map_bsv_int_gt to           |
|                            gl_accts_map_bsv_gt                             |
|     19-MAI-2005 K.Boussema Reviewed cache_combination_id to fix bug4304098 |
|     23-MAY-2005 W.Chan     Fix bug4388150 in create_ccid                   |
|     08-Aug-2005 W.Chan     Fix bug4542460 in map_ccid                      |
|     19-Aug-2005 W.Chan     Fix bug4564062 in map_ccid                      |
|     26-May-2006 M.Asada    Merge updates in create_ccid and create_new_ccid|
+===========================================================================*/

/*-------------------------------------------------------------------+
|                                                                    |
|                            PL/SQL constants                        |
|                                                                    |
+-------------------------------------------------------------------*/

-- accounting CCID status
C_NOT_PROCESSED          CONSTANT VARCHAR2(30)  := 'NOT_PROCESSED';
C_PROCESSING             CONSTANT VARCHAR2(30)  := 'PROCESSING';
C_CREATED                CONSTANT VARCHAR2(30)  := 'CREATED';
C_INVALID                CONSTANT VARCHAR2(30)  := 'INVALID';

-- transaction account status
C_MAP_CCID               CONSTANT VARCHAR2(30)  := 'MAP_CCID';
C_MAP_QUALIFIER          CONSTANT VARCHAR2(30)  := 'MAP_QUALIFIER';
C_MAP_SEGMENT            CONSTANT VARCHAR2(30)  := 'MAP_SEGMENT';

C_JE_INVALID             CONSTANT VARCHAR2(30)  := 'I';

C_FINAL                  CONSTANT VARCHAR2(1)   := 'P';
C_DRAFT                  CONSTANT VARCHAR2(1)   := 'D';

C_CHAR                   CONSTANT VARCHAR2(1)   := '#';
C_MAXCOUNT               CONSTANT NUMBER        := 1000;

C_NEW_LINE               CONSTANT VARCHAR2(8)   := fnd_global.newline;

/*-------------------------------------------------------------------+
|                                                                    |
|                  PL/SQL structures/records/arrays                  |
|                                                                    |
+-------------------------------------------------------------------*/
--
-- CCID structure and cache, indexed by
-- hash_code(flexfield_application_id,
--           id_flex_code,
--           id_flex_num,
--           combination_id)
--
TYPE t_rec_combination_id IS RECORD (
 flexfield_application_id   NUMBER
,id_flex_code               VARCHAR2(4)
,id_flex_num                NUMBER
,combination_id             NUMBER
,segment1                   VARCHAR2(30)
,segment2                   VARCHAR2(30)
,segment3                   VARCHAR2(30)
,segment4                   VARCHAR2(30)
,segment5                   VARCHAR2(30)
,segment6                   VARCHAR2(30)
,segment7                   VARCHAR2(30)
,segment8                   VARCHAR2(30)
,segment9                   VARCHAR2(30)
,segment10                  VARCHAR2(30)
,segment11                  VARCHAR2(30)
,segment12                  VARCHAR2(30)
,segment13                  VARCHAR2(30)
,segment14                  VARCHAR2(30)
,segment15                  VARCHAR2(30)
,segment16                  VARCHAR2(30)
,segment17                  VARCHAR2(30)
,segment18                  VARCHAR2(30)
,segment19                  VARCHAR2(30)
,segment20                  VARCHAR2(30)
,segment21                  VARCHAR2(30)
,segment22                  VARCHAR2(30)
,segment23                  VARCHAR2(30)
,segment24                  VARCHAR2(30)
,segment25                  VARCHAR2(30)
,segment26                  VARCHAR2(30)
,segment27                  VARCHAR2(30)
,segment28                  VARCHAR2(30)
,segment29                  VARCHAR2(30)
,segment30                  VARCHAR2(30)
,combination_status         VARCHAR2(1)
);


TYPE t_array_qualifier IS TABLE OF varchar2(30) INDEX BY varchar2(30);
TYPE t_array_segment   IS TABLE OF varchar2(30) INDEX BY binary_integer;

TYPE t_rec_key_flexfield IS RECORD (
 flexfield_application_id    NUMBER
,application_short_name      VARCHAR2(50)
,id_flex_code                VARCHAR2(4)
,id_flex_num                 NUMBER  --coa_id
,segment_qualifier           t_array_qualifier
,segment_num                 t_array_segment
);

TYPE t_array_key_flexfiled   IS TABLE OF t_rec_key_flexfield INDEX BY binary_integer;
TYPE t_array_combination_id  IS TABLE OF t_rec_combination_id INDEX BY binary_integer;
TYPE t_array_appl_short_name IS TABLE OF varchar2(50) INDEX BY binary_integer;

/*-------------------------------------------------------------------+
|                                                                    |
|                       global variables/caches                      |
|                                                                    |
+-------------------------------------------------------------------*/

--g_error_exists                  BOOLEAN;
g_array_combination_id          t_array_combination_id;
g_array_key_flexfield           t_array_key_flexfiled;
g_array_appl_short_name         t_array_appl_short_name;
g_array_cache_target_coa        xla_ae_journal_entry_pkg.t_array_Num;
g_cache_coa_sla_mapping         xla_ae_journal_entry_pkg.t_array_V33L;
g_cache_dynamic_inserts         xla_ae_journal_entry_pkg.t_array_V1L;

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
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.xla_ae_code_combination_pkg';

g_log_level           NUMBER;
g_log_enabled         BOOLEAN;

PROCEDURE trace
           (p_msg                        IN VARCHAR2
           ,p_level                      IN NUMBER
           ,p_module                     IN VARCHAR2) IS
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
             (p_location   => 'xla_ae_code_combination_pkg.trace');
END trace;

/*======================================================================+
|                                                                       |
| Private Function                                                      |
|                                                                       |
|    Dump_Text                                                          |
|                                                                       |
|    Dump text into fnd_log_messages.                                   |
|                                                                       |
+======================================================================*/
PROCEDURE dump_text
                    (
                      p_text          IN  VARCHAR2
                    )
IS
   l_cur_position      INTEGER;
   l_next_cr_position  INTEGER;
   l_text_length       INTEGER;
   l_log_module                 VARCHAR2 (2000);

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.dump_text';
   END IF;

   --Dump the SQL command
   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      l_cur_position      := 1;
      l_next_cr_position  := 0;
      l_text_length       := LENGTH(p_text);

      WHILE l_next_cr_position < l_text_length
      LOOP
         l_next_cr_position := INSTR( p_text
                                     ,C_NEW_LINE
                                     ,l_cur_position
                                    );

         IF l_next_cr_position = 0
         THEN
            l_next_cr_position := l_text_length;
         END IF;

         trace
            (p_msg      => SUBSTR( p_text
                                  ,l_cur_position
                                  ,l_next_cr_position
                                   - l_cur_position
                                   + 1
                                 )
            ,p_level    => C_LEVEL_STATEMENT
			,p_module   => l_log_module);

         IF l_cur_position < l_text_length
         THEN
            l_cur_position := l_next_cr_position + 1;
         END IF;
      END LOOP;
   END IF;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception   THEN
       RAISE;
   WHEN OTHERS    THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_ae_code_combination_pkg.dump_text');
END dump_text;

--
--====================================================================
--
--
--
--
-- Forward declaration of local routines
--
--
--
--
--======================================================================
--
--
--
PROCEDURE refreshGLMappingCache
;

PROCEDURE cache_flex_qualifier (
   p_flex_application_id                IN NUMBER,
   p_id_flex_code                       IN VARCHAR2,
   p_id_flex_num                        IN NUMBER,
   p_position                           IN NUMBER
)
;

PROCEDURE cache_flex_segment (
   p_flex_application_id                IN NUMBER,
   p_id_flex_code                       IN VARCHAR2,
   p_id_flex_num                        IN NUMBER,
   p_position                           IN NUMBER
)
;

FUNCTION init_SegmentArray(
        p_segment1              IN VARCHAR2
      , p_segment2              IN VARCHAR2
      , p_segment3              IN VARCHAR2
      , p_segment4              IN VARCHAR2
      , p_segment5              IN VARCHAR2
      , p_segment6              IN VARCHAR2
      , p_segment7              IN VARCHAR2
      , p_segment8              IN VARCHAR2
      , p_segment9              IN VARCHAR2
      , p_segment10             IN VARCHAR2
      , p_segment11             IN VARCHAR2
      , p_segment12             IN VARCHAR2
      , p_segment13             IN VARCHAR2
      , p_segment14             IN VARCHAR2
      , p_segment15             IN VARCHAR2
      , p_segment16             IN VARCHAR2
      , p_segment17             IN VARCHAR2
      , p_segment18             IN VARCHAR2
      , p_segment19             IN VARCHAR2
      , p_segment20             IN VARCHAR2
      , p_segment21             IN VARCHAR2
      , p_segment22             IN VARCHAR2
      , p_segment23             IN VARCHAR2
      , p_segment24             IN VARCHAR2
      , p_segment25             IN VARCHAR2
      , p_segment26             IN VARCHAR2
      , p_segment27             IN VARCHAR2
      , p_segment28             IN VARCHAR2
      , p_segment29             IN VARCHAR2
      , p_segment30             IN VARCHAR2
      , p_flex_application_id      IN NUMBER
      , p_application_short_name   IN VARCHAR2
      , p_id_flex_code             IN VARCHAR2
      , p_id_flex_num              IN NUMBER
)
RETURN FND_FLEX_EXT.SegmentArray
;

PROCEDURE cache_combination_id(
   p_combination_id         IN NUMBER
 , p_flex_application_id    IN NUMBER
 , p_application_short_name IN VARCHAR2
 , p_id_flex_code           IN VARCHAR2
 , p_id_flex_num            IN NUMBER
)
;

FUNCTION get_flex_structure_name(
   p_flex_application_id                IN NUMBER,
   p_id_flex_code                       IN VARCHAR2,
   p_id_flex_num                        IN NUMBER
)
RETURN VARCHAR2
;


FUNCTION get_account_value(
        p_combination_id          IN NUMBER
      , p_flex_application_id     IN NUMBER
      , p_application_short_name  IN VARCHAR2
      , p_id_flex_code            IN VARCHAR2
      , p_id_flex_num             IN NUMBER)
RETURN VARCHAR2
;

FUNCTION get_application_name(
   p_flex_application_id                IN NUMBER
)
RETURN VARCHAR2
;


PROCEDURE build_events_message(
        p_appli_s_name          IN VARCHAR2
      , p_msg_name              IN VARCHAR2
      , p_token_1               IN VARCHAR2
      , p_value_1               IN VARCHAR2
      , p_token_2               IN VARCHAR2
      , p_value_2               IN VARCHAR2
      , p_segment1              IN VARCHAR2
      , p_segment2              IN VARCHAR2
      , p_segment3              IN VARCHAR2
      , p_segment4              IN VARCHAR2
      , p_segment5              IN VARCHAR2
      , p_segment6              IN VARCHAR2
      , p_segment7              IN VARCHAR2
      , p_segment8              IN VARCHAR2
      , p_segment9              IN VARCHAR2
      , p_segment10             IN VARCHAR2
      , p_segment11             IN VARCHAR2
      , p_segment12             IN VARCHAR2
      , p_segment13             IN VARCHAR2
      , p_segment14             IN VARCHAR2
      , p_segment15             IN VARCHAR2
      , p_segment16             IN VARCHAR2
      , p_segment17             IN VARCHAR2
      , p_segment18             IN VARCHAR2
      , p_segment19             IN VARCHAR2
      , p_segment20             IN VARCHAR2
      , p_segment21             IN VARCHAR2
      , p_segment22             IN VARCHAR2
      , p_segment23             IN VARCHAR2
      , p_segment24             IN VARCHAR2
      , p_segment25             IN VARCHAR2
      , p_segment26             IN VARCHAR2
      , p_segment27             IN VARCHAR2
      , p_segment28             IN VARCHAR2
      , p_segment29             IN VARCHAR2
      , p_segment30             IN VARCHAR2
      , p_chart_of_accounts_id  IN NUMBER
  )
;
--
--PROCEDURE get_ccid_errors;
--
FUNCTION  validate_source_ccid
RETURN NUMBER
;
--
FUNCTION  override_ccid
RETURN NUMBER
;
--
FUNCTION create_ccid
RETURN NUMBER
;
--
FUNCTION  create_new_ccid
RETURN NUMBER
;
--
FUNCTION  map_ccid(
    p_gl_coa_mapping_name IN VARCHAR2
  , p_gl_coa_mapping_id   IN NUMBER
)
RETURN NUMBER
;

FUNCTION  map_segment_qualifier(
    p_gl_coa_mapping_name IN VARCHAR2
  , p_gl_coa_mapping_id   IN NUMBER
)
RETURN NUMBER
;

FUNCTION  map_transaction_accounts
RETURN NUMBER
;

--
--+==========================================================================+
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

/*--------------------------------------------------------+
|                                                         |
|  Private function                                       |
|                                                         |
|    get_application_name                                 |
|                                                         |
| retruns the application name for a given application id |
|                                                         |
+--------------------------------------------------------*/

FUNCTION get_application_name(
   p_flex_application_id                IN NUMBER
)
RETURN VARCHAR2
IS
l_name                   VARCHAR2(240);
BEGIN
SELECT application_name
 INTO  l_name
  FROM fnd_application_vl fnd
 WHERE fnd.application_id      =  p_flex_application_id
    ;

RETURN l_name;
EXCEPTION
WHEN NO_DATA_FOUND OR TOO_MANY_ROWS THEN
   RETURN TO_CHAR(p_flex_application_id);
WHEN xla_exceptions_pkg.application_exception THEN
   RETURN TO_CHAR(p_flex_application_id);
WHEN OTHERS  THEN
   xla_exceptions_pkg.raise_message
           (p_location => 'xla_ae_code_combination_pkg.get_application_name');
END get_application_name;

/*---------------------------------------------------------------+
|                                                                |
|  Private function                                              |
|                                                                |
|    get_flex_structure_name                                     |
|                                                                |
| retruns key flexfield structure name for a given key flexfield |
|                                                                |
+---------------------------------------------------------------*/

FUNCTION get_flex_structure_name(
   p_flex_application_id                IN NUMBER,
   p_id_flex_code                       IN VARCHAR2,
   p_id_flex_num                        IN NUMBER
)
RETURN VARCHAR2
IS
l_id_flex_num               NUMBER;
l_name                      VARCHAR2(30);
BEGIN
l_id_flex_num:= p_id_flex_num;
IF l_id_flex_num   IS NULL THEN
    l_id_flex_num:=  xla_flex_pkg.get_flexfield_structure
                    (p_application_id  =>p_flex_application_id
                    ,p_id_flex_code   => p_id_flex_code);
END IF;

SELECT id_flex_structure_name
 INTO  l_name
  FROM fnd_id_flex_structures_vl fnd
 WHERE fnd.application_id      =  p_flex_application_id
   AND fnd.id_flex_code        =  p_id_flex_code
   AND fnd.id_flex_num         =  l_id_flex_num
;
RETURN l_name;
EXCEPTION
WHEN NO_DATA_FOUND OR TOO_MANY_ROWS THEN
  RETURN NULL;
WHEN xla_exceptions_pkg.application_exception THEN
  RETURN NULL;
WHEN OTHERS  THEN
   xla_exceptions_pkg.raise_message
           (p_location => 'xla_ae_code_combination_pkg.get_flex_structure_name');
END get_flex_structure_name;

/*---------------------------------------------------------------+
|                                                                |
|  Public procedure                                              |
|                                                                |
|    refreshCCID                                                 |
|                                                                |
| refresh key flexfield combination cache                        |
|                                                                |
+---------------------------------------------------------------*/

PROCEDURE refreshCCID
IS
l_null_combination_id      t_array_combination_id;
BEGIN
g_array_combination_id    := l_null_combination_id;

END refreshCCID;

/*---------------------------------------------------------------+
|                                                                |
|  Private procedure                                             |
|                                                                |
|    reset_flexfield_cache                                       |
|                                                                |
| refresh key flexfield structure cache                          |
|                                                                |
+---------------------------------------------------------------*/

PROCEDURE reset_flexfield_cache
IS
l_null_key_flexfiled                   t_array_key_flexfiled;
BEGIN
g_array_key_flexfield    := l_null_key_flexfiled;
END reset_flexfield_cache;

/*---------------------------------------------------------------+
|                                                                |
|  Private procedure                                             |
|                                                                |
|    refreshGLMappingCache                                       |
|                                                                |
| refresh GL COA mapping cache                                   |
|                                                                |
+---------------------------------------------------------------*/

PROCEDURE refreshGLMappingCache
IS
l_null_coa_sla_mapping         xla_ae_journal_entry_pkg.t_array_V33L;
l_null_dynamic_inserts         xla_ae_journal_entry_pkg.t_array_V1L;
BEGIN

g_cache_coa_sla_mapping    := l_null_coa_sla_mapping;
g_cache_dynamic_inserts    := l_null_dynamic_inserts;

END refreshGLMappingCache;

/*---------------------------------------------------------------+
|                                                                |
|  Public procedure                                              |
|                                                                |
|      refreshCcidCache                                          |
|                                                                |
| refresh the accounts cache                                     |
|                                                                |
+---------------------------------------------------------------*/

PROCEDURE refreshCcidCache
IS
g_array_appl_short_null         t_array_appl_short_name;
BEGIN
--
refreshCCID;
reset_flexfield_cache;
g_array_appl_short_name:= g_array_appl_short_null ;
--
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  RAISE;
WHEN OTHERS  THEN
       xla_exceptions_pkg.raise_message
               (p_location => 'xla_ae_journal_entry_pkg.refreshCcidCache');
END refreshCcidCache;

/*------------------------------------------------------------------+
|                                                                   |
| Private procedure                                                 |
|                                                                   |
|      cache_flex_qualifier                                         |
|                                                                   |
| caches the segment attributes for a given key flexfield structure |
|                                                                   |
+------------------------------------------------------------------*/

PROCEDURE cache_flex_qualifier(
   p_flex_application_id                IN NUMBER,
   p_id_flex_code                       IN VARCHAR2,
   p_id_flex_num                        IN NUMBER,
   p_position                           IN NUMBER
)
IS
l_log_module                VARCHAR2(240);
BEGIN

IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.cache_flex_qualifier';
END IF;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of cache_flex_qualifier'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
          (p_msg      => 'flexfield application id = '|| TO_CHAR(p_flex_application_id) ||
                         ' - p_id_flex_code = '|| TO_CHAR(p_id_flex_code)||
                         ' - p_id_flex_num = '|| TO_CHAR(p_id_flex_num)||
                         ' - p_position = '||p_position
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

FOR flex_cur IN ( SELECT  fsav.segment_attribute_type       segment_qualifier
                        , fsav.application_column_name      segment_code
                         FROM fnd_segment_attribute_values fsav
                        WHERE fsav.application_id    =  p_flex_application_id
                          AND fsav.id_flex_code      =  p_id_flex_code
                          AND fsav.id_flex_num       =  p_id_flex_num
                          AND fsav.attribute_value   = 'Y'
                     GROUP BY fsav.application_column_name, fsav.segment_attribute_type
                       )
LOOP

 g_array_key_flexfield(p_position).segment_qualifier(flex_cur.segment_qualifier):= flex_cur.segment_code;

 IF (C_LEVEL_STATEMENT>= g_log_level) THEN
   trace
         (p_msg      => 'segment_qualifier = '||flex_cur.segment_qualifier||
                        ' - segment_code ='||flex_cur.segment_code
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
 END IF;

END LOOP;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of cache_flex_qualifier'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  RAISE;
WHEN OTHERS  THEN
   xla_exceptions_pkg.raise_message
           (p_location => 'xla_ae_code_combination_pkg.cache_flex_qualifier');
END cache_flex_qualifier;

/*------------------------------------------------------------------+
|                                                                   |
| Private procedure                                                 |
|                                                                   |
|     cache_flex_segment                                            |
|                                                                   |
| caches the segment number for a given key flexfield structure     |
|                                                                   |
+------------------------------------------------------------------*/

PROCEDURE cache_flex_segment (
   p_flex_application_id                IN NUMBER,
   p_id_flex_code                       IN VARCHAR2,
   p_id_flex_num                        IN NUMBER,
   p_position                           IN NUMBER
)
IS
l_log_module                VARCHAR2(240);
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.cache_flex_segment';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of cache_flex_segment'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
          (p_msg      => 'p_flex_application_id = '|| TO_CHAR(p_flex_application_id)||
                         ' - p_id_flex_code = '|| TO_CHAR(p_id_flex_code)||
                         ' - p_id_flex_num = '|| TO_CHAR(p_id_flex_num)||
                         ' - p_position = '||p_position
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;

FOR flex_cur IN (
SELECT  upper(fifs.application_column_name)  segment_name
      , fifs.segment_num                     segment_num
   FROM fnd_id_flex_segments fifs
  WHERE fifs.application_id          =  p_flex_application_id
   AND  fifs.id_flex_code            =  p_id_flex_code
   AND  fifs.id_flex_num             =  p_id_flex_num
   AND  fifs.enabled_flag            = 'Y'
  ORDER BY fifs.segment_num
)
LOOP

 g_array_key_flexfield(p_position).segment_num(flex_cur.segment_num):= flex_cur.segment_name;

 IF (C_LEVEL_STATEMENT>= g_log_level) THEN
   trace
         (p_msg      => 'segment_num = '||flex_cur.segment_num||
                        ' - segment_name ='||flex_cur.segment_name
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
 END IF;

END LOOP;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of cache_flex_segment'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  RAISE;
WHEN OTHERS  THEN
   xla_exceptions_pkg.raise_message
           (p_location => 'xla_ae_code_combination_pkg.cache_flex_segment');
END cache_flex_segment;

/*------------------------------------------------------------------+
|                                                                   |
| Private procedure                                                 |
|                                                                   |
|     cache_key_flexfield                                           |
|                                                                   |
| caches the key flexfield structure. It retruns the key flexfield  |
| number, when the key flexfield is not an accounting flexfield     |
|                                                                   |
+------------------------------------------------------------------*/

PROCEDURE cache_key_flexfield(
   p_flex_application_id                IN NUMBER,
   p_application_short_name             IN VARCHAR2,
   p_id_flex_code                       IN VARCHAR2,
   p_id_flex_num                        IN OUT NOCOPY NUMBER
)
IS
l_id_flex_num        NUMBER;
l_position           NUMBER;
l_log_module         VARCHAR2(240);
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.cache_key_flexfield';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of cache_key_flexfield'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
          (p_msg      => 'p_flex_application_id = '|| TO_CHAR(p_flex_application_id)||
                         ' - p_id_flex_code = '|| TO_CHAR(p_id_flex_code)||
                         ' - p_id_flex_num = '|| TO_CHAR(p_id_flex_num)
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;

l_position    := DBMS_UTILITY.get_hash_value(
                    TO_CHAR(p_id_flex_num)||
                    TO_CHAR(p_flex_application_id)||
                    p_id_flex_code,1,1073741824);

IF (C_LEVEL_STATEMENT >= g_log_level) THEN
 trace
         (p_msg      => ' hash code of the key flexfield/position ='||l_position
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

IF NOT g_array_key_flexfield.EXISTS(l_position) THEN

 l_id_flex_num := p_id_flex_num;

 IF l_id_flex_num  IS NULL THEN

   l_id_flex_num:=  xla_flex_pkg.get_flexfield_structure
                    (p_application_id  =>p_flex_application_id
                    ,p_id_flex_code   => p_id_flex_code);
 END IF;

 g_array_key_flexfield(l_position).flexfield_application_id := p_flex_application_id;
 g_array_key_flexfield(l_position).application_short_name   := p_application_short_name;
 g_array_key_flexfield(l_position).id_flex_code             := p_id_flex_code;
 g_array_key_flexfield(l_position).id_flex_num              := l_id_flex_num;

 cache_flex_qualifier(
   p_flex_application_id => p_flex_application_id,
   p_id_flex_code        => p_id_flex_code,
   p_id_flex_num         => l_id_flex_num,
   p_position            => l_position
 );

 cache_flex_segment (
   p_flex_application_id => p_flex_application_id,
   p_id_flex_code        => p_id_flex_code,
   p_id_flex_num         => l_id_flex_num,
   p_position            => l_position
 );

 --cache application short name
 g_array_appl_short_name(p_flex_application_id):= p_application_short_name;

ELSE
  l_id_flex_num := g_array_key_flexfield(l_position).id_flex_num;
END IF;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of cache_key_flexfield'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
p_id_flex_num := l_id_flex_num;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  RAISE;
WHEN OTHERS  THEN
   xla_exceptions_pkg.raise_message
           (p_location => 'xla_ae_code_combination_pkg.cache_key_flexfield');
END cache_key_flexfield;

/*---------------------------------------------------------+
|                                                          |
| Public procedure                                         |
|                                                          |
|   cache_coa                                              |
|                                                          |
| caches the accounting flexfield structures, involved in  |
| the accounting process                                   |
+---------------------------------------------------------*/

PROCEDURE cache_coa(
            p_coa_id                IN NUMBER
)
IS
l_id_flex_num        NUMBER;
l_log_module         VARCHAR2(240);
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.cache_coa';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of cache_coa'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
          (p_msg      => 'p_coa_id = '|| TO_CHAR(p_coa_id)
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

l_id_flex_num:= p_coa_id;

cache_key_flexfield(
   p_flex_application_id    => 101,
   p_application_short_name => 'SQLGL',
   p_id_flex_code           => 'GL#',
   p_id_flex_num            => l_id_flex_num
  );

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of cache_coa'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  RAISE;
WHEN OTHERS  THEN
   xla_exceptions_pkg.raise_message
           (p_location => 'xla_ae_code_combination_pkg.cache_coa');
END cache_coa;

/*---------------------------------------------------------+
|                                                          |
| Public procedure                                         |
|                                                          |
|   cache_coa                                              |
|                                                          |
| caches the accounting flexfield structures, involved in  |
| the accounting process. It caches only the accounting    |
| chart of accounts                                        |
+---------------------------------------------------------*/

PROCEDURE cache_coa(
             p_coa_id                IN NUMBER
            ,p_target_coa            IN VARCHAR2
)
IS
l_log_module         VARCHAR2(240);
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.cache_coa';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of cache_coa'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
          (p_msg      => 'p_coa_id = '|| TO_CHAR(p_coa_id)||
                         ' - p_target_coa = '|| TO_CHAR(p_target_coa)
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
--
IF NVL(p_target_coa,'N')='Y' THEN

  cache_coa( p_coa_id  => p_coa_id );
  g_array_cache_target_coa(p_coa_id) := p_coa_id;

END IF;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of cache_coa_segment_num'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  RAISE;
WHEN OTHERS  THEN
   xla_exceptions_pkg.raise_message
           (p_location => 'xla_ae_code_combination_pkg.cache_coa');
END cache_coa;

/*---------------------------------------------------------+
|                                                          |
| Public procedure                                         |
|                                                          |
|   cacheGLMapping                                         |
|                                                          |
| caches the GL chart of acounts mappings, i,volved in the |
| accounting process.                                      |
|                                                          |
+---------------------------------------------------------*/

PROCEDURE cacheGLMapping(
                         p_sla_coa_mapping_name IN VARCHAR2
                       , p_sla_coa_mapping_id   IN NUMBER
                       , p_dynamic_inserts_flag IN VARCHAR2
                        )
IS
--
Idx                            BINARY_INTEGER;
l_exists                       BOOLEAN;
l_log_module                   VARCHAR2(240);
--
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.cacheGLMapping';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of cacheGLMapping'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
          (p_msg      => 'p_sla_coa_mapping_name = '|| p_sla_coa_mapping_name||
                         ' - p_sla_coa_mapping_id = '|| p_sla_coa_mapping_id||
                         ' - p_dynamic_inserts_flag = '|| p_dynamic_inserts_flag
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

g_cache_coa_sla_mapping(p_sla_coa_mapping_id)    := SUBSTR(p_sla_coa_mapping_name,1,33);
g_cache_dynamic_inserts(p_sla_coa_mapping_id)    := SUBSTR(p_dynamic_inserts_flag,1,1);


IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of cacheGLMapping'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
END cacheGLMapping;

/*------------------------------------------------------------------+
|                                                                   |
| Private procedure                                                 |
|                                                                   |
|     InitSegmentArray                                              |
|                                                                   |
| Set the FND_FLEX_EXT.SegmentArray varaibles.                      |
|                                                                   |
+------------------------------------------------------------------*/

FUNCTION init_SegmentArray(
        p_segment1               IN VARCHAR2
      , p_segment2               IN VARCHAR2
      , p_segment3               IN VARCHAR2
      , p_segment4               IN VARCHAR2
      , p_segment5               IN VARCHAR2
      , p_segment6               IN VARCHAR2
      , p_segment7               IN VARCHAR2
      , p_segment8               IN VARCHAR2
      , p_segment9               IN VARCHAR2
      , p_segment10              IN VARCHAR2
      , p_segment11              IN VARCHAR2
      , p_segment12              IN VARCHAR2
      , p_segment13              IN VARCHAR2
      , p_segment14              IN VARCHAR2
      , p_segment15              IN VARCHAR2
      , p_segment16              IN VARCHAR2
      , p_segment17              IN VARCHAR2
      , p_segment18              IN VARCHAR2
      , p_segment19              IN VARCHAR2
      , p_segment20              IN VARCHAR2
      , p_segment21              IN VARCHAR2
      , p_segment22              IN VARCHAR2
      , p_segment23              IN VARCHAR2
      , p_segment24              IN VARCHAR2
      , p_segment25              IN VARCHAR2
      , p_segment26              IN VARCHAR2
      , p_segment27              IN VARCHAR2
      , p_segment28              IN VARCHAR2
      , p_segment29              IN VARCHAR2
      , p_segment30              IN VARCHAR2
      , p_flex_application_id    IN NUMBER
      , p_application_short_name IN VARCHAR2
      , p_id_flex_code           IN VARCHAR2
      , p_id_flex_num            IN NUMBER
)
RETURN FND_FLEX_EXT.SegmentArray
IS
l_position            NUMBER;
l_SegmentArray        FND_FLEX_EXT.SegmentArray;
l_log_module          VARCHAR2(240);
l_id_flex_num         NUMBER;
l_id                  INTEGER;   -- index for flexfield
--
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.init_SegmentArray';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of init_SegmentArray'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
          (p_msg      => 'p_flex_application_id = '|| TO_CHAR(p_flex_application_id)||
                         ' - p_id_flex_code = '|| TO_CHAR(p_id_flex_code)||
                         ' - p_id_flex_num = '|| TO_CHAR(p_id_flex_num)
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;

l_position := DBMS_UTILITY.get_hash_value(
                    TO_CHAR(p_id_flex_num)||
                    TO_CHAR(p_flex_application_id)||
                    p_id_flex_code,1,1073741824);

IF NOT g_array_key_flexfield.EXISTS(l_position) THEN

  l_id_flex_num := p_id_flex_num;

  cache_key_flexfield(
   p_flex_application_id    => p_flex_application_id,
   p_application_short_name => p_application_short_name,
   p_id_flex_code           => p_id_flex_code,
   p_id_flex_num            => l_id_flex_num
  );

END IF;

IF g_array_key_flexfield(l_position).segment_num.COUNT > 0 THEN

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace
         (p_msg      => '# key flexfield segments = '||g_array_key_flexfield(l_position).segment_num.COUNT
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
  END IF;

     l_id := 0;
     FOR Idx IN g_array_key_flexfield(l_position).segment_num.first ..
                g_array_key_flexfield(l_position).segment_num.last LOOP

         IF g_array_key_flexfield(l_position).segment_num.EXISTS(Idx) THEN

            l_id := l_id + 1;

            CASE g_array_key_flexfield(l_position).segment_num(Idx)

              WHEN 'SEGMENT1'  THEN l_SegmentArray(l_id) := p_segment1;
              WHEN 'SEGMENT2'  THEN l_SegmentArray(l_id) := p_segment2;
              WHEN 'SEGMENT3'  THEN l_SegmentArray(l_id) := p_segment3;
              WHEN 'SEGMENT4'  THEN l_SegmentArray(l_id) := p_segment4;
              WHEN 'SEGMENT5'  THEN l_SegmentArray(l_id) := p_segment5;
              WHEN 'SEGMENT6'  THEN l_SegmentArray(l_id) := p_segment6;
              WHEN 'SEGMENT7'  THEN l_SegmentArray(l_id) := p_segment7;
              WHEN 'SEGMENT8'  THEN l_SegmentArray(l_id) := p_segment8;
              WHEN 'SEGMENT9'  THEN l_SegmentArray(l_id) := p_segment9;
              WHEN 'SEGMENT10' THEN l_SegmentArray(l_id) := p_segment10;
              WHEN 'SEGMENT11' THEN l_SegmentArray(l_id) := p_segment11;
              WHEN 'SEGMENT12' THEN l_SegmentArray(l_id) := p_segment12;
              WHEN 'SEGMENT13' THEN l_SegmentArray(l_id) := p_segment13;
              WHEN 'SEGMENT14' THEN l_SegmentArray(l_id) := p_segment14;
              WHEN 'SEGMENT15' THEN l_SegmentArray(l_id) := p_segment15;
              WHEN 'SEGMENT16' THEN l_SegmentArray(l_id) := p_segment16;
              WHEN 'SEGMENT17' THEN l_SegmentArray(l_id) := p_segment17;
              WHEN 'SEGMENT18' THEN l_SegmentArray(l_id) := p_segment18;
              WHEN 'SEGMENT19' THEN l_SegmentArray(l_id) := p_segment19;
              WHEN 'SEGMENT20' THEN l_SegmentArray(l_id) := p_segment20;
              WHEN 'SEGMENT21' THEN l_SegmentArray(l_id) := p_segment21;
              WHEN 'SEGMENT22' THEN l_SegmentArray(l_id) := p_segment22;
              WHEN 'SEGMENT23' THEN l_SegmentArray(l_id) := p_segment23;
              WHEN 'SEGMENT24' THEN l_SegmentArray(l_id) := p_segment24;
              WHEN 'SEGMENT25' THEN l_SegmentArray(l_id) := p_segment25;
              WHEN 'SEGMENT26' THEN l_SegmentArray(l_id) := p_segment26;
              WHEN 'SEGMENT27' THEN l_SegmentArray(l_id) := p_segment27;
              WHEN 'SEGMENT28' THEN l_SegmentArray(l_id) := p_segment28;
              WHEN 'SEGMENT29' THEN l_SegmentArray(l_id) := p_segment29;
              WHEN 'SEGMENT30' THEN l_SegmentArray(l_id) := p_segment30;
              ELSE null;
            END CASE;

              /*
              WHEN 'SEGMENT1'  THEN l_SegmentArray(Idx) := p_segment1;
              WHEN 'SEGMENT2'  THEN l_SegmentArray(Idx) := p_segment2;
              WHEN 'SEGMENT3'  THEN l_SegmentArray(Idx) := p_segment3;
              WHEN 'SEGMENT4'  THEN l_SegmentArray(Idx) := p_segment4;
              WHEN 'SEGMENT5'  THEN l_SegmentArray(Idx) := p_segment5;
              WHEN 'SEGMENT6'  THEN l_SegmentArray(Idx) := p_segment6;
              WHEN 'SEGMENT7'  THEN l_SegmentArray(Idx) := p_segment7;
              WHEN 'SEGMENT8'  THEN l_SegmentArray(Idx) := p_segment8;
              WHEN 'SEGMENT9'  THEN l_SegmentArray(Idx) := p_segment9;
              WHEN 'SEGMENT10' THEN l_SegmentArray(Idx) := p_segment10;
              WHEN 'SEGMENT11' THEN l_SegmentArray(Idx) := p_segment11;
              WHEN 'SEGMENT12' THEN l_SegmentArray(Idx) := p_segment12;
              WHEN 'SEGMENT13' THEN l_SegmentArray(Idx) := p_segment13;
              WHEN 'SEGMENT14' THEN l_SegmentArray(Idx) := p_segment14;
              WHEN 'SEGMENT15' THEN l_SegmentArray(Idx) := p_segment15;
              WHEN 'SEGMENT16' THEN l_SegmentArray(Idx) := p_segment16;
              WHEN 'SEGMENT17' THEN l_SegmentArray(Idx) := p_segment17;
              WHEN 'SEGMENT18' THEN l_SegmentArray(Idx) := p_segment18;
              WHEN 'SEGMENT19' THEN l_SegmentArray(Idx) := p_segment19;
              WHEN 'SEGMENT20' THEN l_SegmentArray(Idx) := p_segment20;
              WHEN 'SEGMENT21' THEN l_SegmentArray(Idx) := p_segment21;
              WHEN 'SEGMENT22' THEN l_SegmentArray(Idx) := p_segment22;
              WHEN 'SEGMENT23' THEN l_SegmentArray(Idx) := p_segment23;
              WHEN 'SEGMENT24' THEN l_SegmentArray(Idx) := p_segment24;
              WHEN 'SEGMENT25' THEN l_SegmentArray(Idx) := p_segment25;
              WHEN 'SEGMENT26' THEN l_SegmentArray(Idx) := p_segment26;
              WHEN 'SEGMENT27' THEN l_SegmentArray(Idx) := p_segment27;
              WHEN 'SEGMENT28' THEN l_SegmentArray(Idx) := p_segment28;
              WHEN 'SEGMENT29' THEN l_SegmentArray(Idx) := p_segment29;
              WHEN 'SEGMENT30' THEN l_SegmentArray(Idx) := p_segment30;
              ELSE null;
            END CASE;
              */
         END IF;

    END LOOP;

    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      FOR l_id IN 1 .. 30 LOOP
         IF l_SegmentArray.EXISTS(l_id) THEN
            trace
              (p_msg      => 'l_SegmentArray('||l_id||') = '||l_SegmentArray(l_id)
              ,p_level    => C_LEVEL_PROCEDURE
              ,p_module   => l_log_module);
         END IF;
      END LOOP;
    END IF;

END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of init_SegmentArray'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
RETURN l_SegmentArray;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  RAISE;
WHEN OTHERS  THEN
   xla_exceptions_pkg.raise_message
           (p_location => 'xla_ae_code_combination_pkg.init_SegmentArray');
END init_SegmentArray;

/*---------------------------------------------------+
|                                                    |
| Private procedure                                  |
|                                                    |
|     cache_combination_id                           |
|                                                    |
|  cache the key flexfield combination involved in   |
|  the accounting process                            |
+---------------------------------------------------*/

PROCEDURE cache_combination_id(
   p_combination_id         IN NUMBER
 , p_flex_application_id    IN NUMBER
 , p_application_short_name IN VARCHAR2
 , p_id_flex_code           IN VARCHAR2
 , p_id_flex_num            IN NUMBER
)
IS
  l_ConcatKey                  VARCHAR2(4000);
  l_SegmentArray               FND_FLEX_EXT.SegmentArray;
  l_SegmentNumber              PLS_INTEGER;
  l_message                    VARCHAR2(4000);
  l_log_module                 VARCHAR2(240);
  l_position                   NUMBER;
  l_coa_position               NUMBER;
  l_id_flex_num                NUMBER;
  invalid_key_combination_id   EXCEPTION;
--
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.cache_combination_id';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of cache_combination_id'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_combination_id  = '|| TO_CHAR(p_combination_id)||
                        ' - p_flex_application_id = '|| TO_CHAR(p_flex_application_id)||
                        ' - p_id_flex_code = '|| p_id_flex_code||
                        ' - p_id_flex_num = '|| TO_CHAR(p_id_flex_num)
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;

l_position    := DBMS_UTILITY.get_hash_value(
                    TO_CHAR(p_combination_id)||
                    TO_CHAR(p_id_flex_num)||
                    TO_CHAR(p_flex_application_id)||
                    p_id_flex_code,1,1073741824);


l_coa_position:=  DBMS_UTILITY.get_hash_value(
                             TO_CHAR(p_id_flex_num)||
                             TO_CHAR(p_flex_application_id)||
                             p_id_flex_code,1,1073741824);


IF NOT g_array_key_flexfield.EXISTS(l_coa_position)
   OR g_array_key_flexfield(l_coa_position).id_flex_num <> p_id_flex_num THEN

    l_id_flex_num := p_id_flex_num;

           cache_key_flexfield(
            p_flex_application_id    => p_flex_application_id,
            p_application_short_name => p_application_short_name,
            p_id_flex_code           => p_id_flex_code,
            p_id_flex_num            => l_id_flex_num
            );

ELSE
    -- added to fix bug4304098
    l_id_flex_num := nvl(p_id_flex_num,g_array_key_flexfield(l_coa_position).id_flex_num);

END IF;

--accounting flexfield
IF (NOT g_array_combination_id.EXISTS(l_position)
    OR g_array_combination_id(l_position).combination_id <> p_combination_id) AND
   p_flex_application_id = 101                   AND
   p_id_flex_code        ='GL#'                  AND
   l_id_flex_num         IS NOT NULL            THEN

  BEGIN
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
            (p_msg      => 'SQL - Select from gl_code_combinations '
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
      END IF;

     SELECT
       gcc.code_combination_id
     , p_flex_application_id
     , p_id_flex_code
     , gcc.chart_of_accounts_id
     , gcc.segment1
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
     , 'Y'
   INTO
      g_array_combination_id(l_position).combination_id
    , g_array_combination_id(l_position).flexfield_application_id
    , g_array_combination_id(l_position).id_flex_code
    , g_array_combination_id(l_position).id_flex_num
    , g_array_combination_id(l_position).segment1
    , g_array_combination_id(l_position).segment2
    , g_array_combination_id(l_position).segment3
    , g_array_combination_id(l_position).segment4
    , g_array_combination_id(l_position).segment5
    , g_array_combination_id(l_position).segment6
    , g_array_combination_id(l_position).segment7
    , g_array_combination_id(l_position).segment8
    , g_array_combination_id(l_position).segment9
    , g_array_combination_id(l_position).segment10
    , g_array_combination_id(l_position).segment11
    , g_array_combination_id(l_position).segment12
    , g_array_combination_id(l_position).segment13
    , g_array_combination_id(l_position).segment14
    , g_array_combination_id(l_position).segment15
    , g_array_combination_id(l_position).segment16
    , g_array_combination_id(l_position).segment17
    , g_array_combination_id(l_position).segment18
    , g_array_combination_id(l_position).segment19
    , g_array_combination_id(l_position).segment20
    , g_array_combination_id(l_position).segment21
    , g_array_combination_id(l_position).segment22
    , g_array_combination_id(l_position).segment23
    , g_array_combination_id(l_position).segment24
    , g_array_combination_id(l_position).segment25
    , g_array_combination_id(l_position).segment26
    , g_array_combination_id(l_position).segment27
    , g_array_combination_id(l_position).segment28
    , g_array_combination_id(l_position).segment29
    , g_array_combination_id(l_position).segment30
    , g_array_combination_id(l_position).combination_status
   FROM gl_code_combinations      gcc
  WHERE gcc.code_combination_id   = p_combination_id
    AND gcc.chart_of_accounts_id  = l_id_flex_num
    AND gcc.template_id           IS NULL
   ;

  EXCEPTION
  WHEN NO_DATA_FOUND THEN
       RAISE invalid_key_combination_id;
  END;

ELSE
--key flexfield
    IF (C_LEVEL_STATEMENT >= g_log_level) THEN
           trace
              (p_msg      => '-> CALL FND_FLEX_EXT.get_segments API'
              ,p_level    => C_LEVEL_STATEMENT
              ,p_module   => l_log_module);
    END IF;

    IF FND_FLEX_EXT.get_segments(application_short_name  =>  p_application_short_name ,
                                 key_flex_code           =>  p_id_flex_code   ,
                                 structure_number        =>  l_id_flex_num    ,
                                 combination_id          =>  p_combination_id ,
                                 n_segments              =>  l_SegmentNumber  ,
                                 segments                =>  l_SegmentArray   )
    THEN
       g_array_combination_id(l_position).combination_id           := p_combination_id ;
       g_array_combination_id(l_position).combination_status       := 'Y' ;
       g_array_combination_id(l_position).id_flex_num              := l_id_flex_num ;
       g_array_combination_id(l_position).flexfield_application_id := p_flex_application_id ;
       g_array_combination_id(l_position).id_flex_code             := p_id_flex_code;

       IF l_SegmentNumber > 0 THEN

            FOR Idx IN l_SegmentArray.FIRST .. l_SegmentArray.LAST LOOP

             CASE g_array_key_flexfield(l_coa_position).segment_num(Idx)

              WHEN 'SEGMENT1'  THEN g_array_combination_id(l_position).segment1  := l_SegmentArray(Idx);
              WHEN 'SEGMENT2'  THEN g_array_combination_id(l_position).segment2  := l_SegmentArray(Idx);
              WHEN 'SEGMENT3'  THEN g_array_combination_id(l_position).segment3  := l_SegmentArray(Idx);
              WHEN 'SEGMENT4'  THEN g_array_combination_id(l_position).segment4  := l_SegmentArray(Idx);
              WHEN 'SEGMENT5'  THEN g_array_combination_id(l_position).segment5  := l_SegmentArray(Idx);
              WHEN 'SEGMENT6'  THEN g_array_combination_id(l_position).segment6  := l_SegmentArray(Idx);
              WHEN 'SEGMENT7'  THEN g_array_combination_id(l_position).segment7  := l_SegmentArray(Idx);
              WHEN 'SEGMENT8'  THEN g_array_combination_id(l_position).segment8  := l_SegmentArray(Idx);
              WHEN 'SEGMENT9'  THEN g_array_combination_id(l_position).segment9  := l_SegmentArray(Idx);
              WHEN 'SEGMENT10' THEN g_array_combination_id(l_position).segment10 := l_SegmentArray(Idx);
              WHEN 'SEGMENT11' THEN g_array_combination_id(l_position).segment11 := l_SegmentArray(Idx);
              WHEN 'SEGMENT12' THEN g_array_combination_id(l_position).segment12 := l_SegmentArray(Idx);
              WHEN 'SEGMENT13' THEN g_array_combination_id(l_position).segment13 := l_SegmentArray(Idx);
              WHEN 'SEGMENT14' THEN g_array_combination_id(l_position).segment14 := l_SegmentArray(Idx);
              WHEN 'SEGMENT15' THEN g_array_combination_id(l_position).segment15 := l_SegmentArray(Idx);
              WHEN 'SEGMENT16' THEN g_array_combination_id(l_position).segment16 := l_SegmentArray(Idx);
              WHEN 'SEGMENT17' THEN g_array_combination_id(l_position).segment17 := l_SegmentArray(Idx);
              WHEN 'SEGMENT18' THEN g_array_combination_id(l_position).segment18 := l_SegmentArray(Idx);
              WHEN 'SEGMENT19' THEN g_array_combination_id(l_position).segment19 := l_SegmentArray(Idx);
              WHEN 'SEGMENT20' THEN g_array_combination_id(l_position).segment20 := l_SegmentArray(Idx);
              WHEN 'SEGMENT21' THEN g_array_combination_id(l_position).segment21 := l_SegmentArray(Idx);
              WHEN 'SEGMENT22' THEN g_array_combination_id(l_position).segment22 := l_SegmentArray(Idx);
              WHEN 'SEGMENT23' THEN g_array_combination_id(l_position).segment23 := l_SegmentArray(Idx);
              WHEN 'SEGMENT24' THEN g_array_combination_id(l_position).segment24 := l_SegmentArray(Idx);
              WHEN 'SEGMENT25' THEN g_array_combination_id(l_position).segment25 := l_SegmentArray(Idx);
              WHEN 'SEGMENT26' THEN g_array_combination_id(l_position).segment26 := l_SegmentArray(Idx);
              WHEN 'SEGMENT27' THEN g_array_combination_id(l_position).segment27 := l_SegmentArray(Idx);
              WHEN 'SEGMENT28' THEN g_array_combination_id(l_position).segment28 := l_SegmentArray(Idx);
              WHEN 'SEGMENT29' THEN g_array_combination_id(l_position).segment29 := l_SegmentArray(Idx);
              WHEN 'SEGMENT30' THEN g_array_combination_id(l_position).segment30 := l_SegmentArray(Idx);
              ELSE null;

             END CASE;

           END LOOP;

       END IF;

     ELSE
         RAISE invalid_key_combination_id;
     END IF;

END IF;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of cache_combination_id'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
EXCEPTION

WHEN invalid_key_combination_id THEN

   xla_ae_journal_entry_pkg.g_global_status              := xla_ae_journal_entry_pkg.C_INVALID;
   g_array_combination_id(l_position).combination_id     := p_combination_id ;
   g_array_combination_id(l_position).id_flex_num        := nvl(p_id_flex_num,l_id_flex_num);
   g_array_combination_id(l_position).flexfield_application_id := p_flex_application_id ;
   g_array_combination_id(l_position).id_flex_code       := p_id_flex_code ;
   g_array_combination_id(l_position).combination_status := 'N';

   l_message :=   SUBSTR(FND_FLEX_EXT.get_message,1,4000);

   l_ConcatKey := FND_FLEX_EXT.concatenate_segments(
                   n_segments     => l_SegmentNumber,
                   segments       => l_SegmentArray,
                   delimiter      => FND_FLEX_EXT.get_delimiter(
                         application_short_name  => p_application_short_name,
                         key_flex_code           => p_id_flex_code,
                         structure_number        => nvl(p_id_flex_num,l_id_flex_num)
                         ));

   xla_accounting_err_pkg.build_message
        (p_appli_s_name => 'XLA'
        ,p_msg_name     => 'XLA_AP_INVALID_AOL_CCID'
        ,p_token_1      => 'ACCOUNT_VALUE'
        ,p_value_1      =>  l_ConcatKey
        ,p_token_2      => 'MESSAGE'
        ,p_value_2      =>  l_message
        ,p_entity_id    => xla_ae_journal_entry_pkg.g_cache_event.entity_id
        ,p_event_id     => xla_ae_journal_entry_pkg.g_cache_event.event_id
        ,p_ledger_id    => xla_ae_journal_entry_pkg.g_cache_event.target_ledger_id);

   IF (C_LEVEL_ERROR >= g_log_level) THEN
       trace
         (p_msg      => 'ERROR: XLA_AP_INVALID_AOL_CCID'
         ,p_level    => C_LEVEL_ERROR
         ,p_module   => l_log_module);
   END IF;
WHEN xla_exceptions_pkg.application_exception THEN
  RAISE;
WHEN OTHERS  THEN
   xla_exceptions_pkg.raise_message
           (p_location => 'xla_ae_code_combination_pkg.cache_combination_id');
END cache_combination_id;

/*-----------------------------------------------------+
|                                                      |
| Private function                                     |
|                                                      |
|     get_account_value                                |
|                                                      |
| retruns the key flex concateneted value for a given  |
| key combination identifier.                          |
|                                                      |
+-----------------------------------------------------*/

FUNCTION get_account_value(
        p_combination_id          IN NUMBER
      , p_flex_application_id     IN NUMBER
      , p_application_short_name  IN VARCHAR2
      , p_id_flex_code            IN VARCHAR2
      , p_id_flex_num             IN NUMBER)
RETURN VARCHAR2
IS
  l_ConcatKey           VARCHAR2(4000);   -- key flex concateneted value
  l_SegmentArray        FND_FLEX_EXT.SegmentArray;
  l_SegmentNumber       PLS_INTEGER;
  l_log_module          VARCHAR2(240);
  l_position            NUMBER;
  l_id_flex_num         NUMBER;
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.get_account_value';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of get_account_value'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
          (p_msg      => 'p_combination_id  = '|| TO_CHAR(p_combination_id)
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
     trace
          (p_msg      => 'p_id_flex_num  = '|| TO_CHAR(p_id_flex_num)
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

l_id_flex_num := p_id_flex_num;

IF l_id_flex_num IS NULL THEN

    l_position:=  DBMS_UTILITY.get_hash_value(
                             TO_CHAR(p_id_flex_num)||
                             TO_CHAR(p_flex_application_id)||
                             p_id_flex_code,1,1073741824);

    IF NOT g_array_key_flexfield.EXISTS(l_position) THEN

           cache_key_flexfield(
            p_flex_application_id    => p_flex_application_id,
            p_application_short_name => p_application_short_name,
            p_id_flex_code           => p_id_flex_code,
            p_id_flex_num            => l_id_flex_num
            );
    END IF;

END IF;

IF FND_FLEX_EXT.get_segments(application_short_name  =>  p_application_short_name ,
                             key_flex_code           =>  p_id_flex_code   ,
                             structure_number        =>  l_id_flex_num   ,
                             combination_id          =>  p_combination_id ,
                             n_segments              =>  l_SegmentNumber  ,
                             segments                =>  l_SegmentArray   )
THEN

  l_ConcatKey := FND_FLEX_EXT.concatenate_segments(
                                n_segments     => l_SegmentNumber,
                                segments       => l_SegmentArray,
                                delimiter      => FND_FLEX_EXT.get_delimiter(
                                                       application_short_name  => p_application_short_name,
                                                       key_flex_code           => p_id_flex_code,
                                                       structure_number        => l_id_flex_num
                                                                            )
                                                     );
ELSE
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'Invalid ccid. = '||p_combination_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
  END IF;
  l_ConcatKey := NULL;
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'return value. = '||l_ConcatKey
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'END of get_account_value'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
RETURN l_ConcatKey;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  RAISE;
WHEN OTHERS  THEN
   xla_exceptions_pkg.raise_message
           (p_location => 'xla_ae_code_combination_pkg.get_account_value');
END get_account_value;

--======================================================================
--
--
--
--            routines to retrieve values from caches
--
--
--
--=======================================================================

/*-----------------------------------------------------+
|                                                      |
| Public function                                      |
|                                                      |
|     get_segment_code                                 |
|                                                      |
|  Returns the segment code for a given key flexfield  |
|  attribute.                                          |
|                                                      |
+-----------------------------------------------------*/
-- replaces FUNCTION get_segment_qualifier()
FUNCTION get_segment_code(
   p_flex_application_id    IN NUMBER
 , p_application_short_name IN VARCHAR2
 , p_id_flex_code           IN VARCHAR2
 , p_id_flex_num            IN NUMBER
 , p_segment_qualifier      IN VARCHAR2
 , p_component_type         IN VARCHAR2
 , p_component_code         IN VARCHAR2
 , p_component_type_code    IN VARCHAR2
 , p_component_appl_id      IN INTEGER
 , p_amb_context_code       IN VARCHAR2
 , p_entity_code            IN VARCHAR2
 , p_event_class_code       IN VARCHAR2
)
RETURN VARCHAR2
IS
l_position                  NUMBER;
l_id_flex_num               NUMBER;
l_segment_code              VARCHAR2(30);
l_segment_name              VARCHAR2(240);
l_key_flexfield_name        VARCHAR2(240);
l_product_name              VARCHAR2(240);
l_type                      VARCHAR2(240);
l_name                      VARCHAR2(240);
l_owner                     VARCHAR2(240);
l_log_module                VARCHAR2(240);
invalid_segment_qualifier   EXCEPTION;
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.get_segment_code';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
 trace
         (p_msg      => 'BEGIN of get_segment_code'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
 trace
         (p_msg      => 'p_flex_application_id ='||p_flex_application_id||
                        ' - p_id_flex_code =' ||p_id_flex_code||
                        ' - p_id_flex_num =' ||TO_CHAR(p_id_flex_num) ||
                        ' - p_segment_qualifier ='||p_segment_qualifier
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

IF p_segment_qualifier LIKE 'SEGMENT%' THEN

   l_segment_code := p_segment_qualifier;

ELSE
     l_position     := DBMS_UTILITY.get_hash_value(
                        TO_CHAR(p_id_flex_num)||
                        TO_CHAR(p_flex_application_id)||
                        p_id_flex_code,1,1073741824);

     IF NOT g_array_key_flexfield.EXISTS(l_position) THEN

           l_id_flex_num := p_id_flex_num;

           cache_key_flexfield(
               p_flex_application_id    => p_flex_application_id,
               p_application_short_name => p_application_short_name,
               p_id_flex_code           => p_id_flex_code,
               p_id_flex_num            => l_id_flex_num
               );

    END IF;

    if g_array_key_flexfield(l_position).segment_qualifier.EXISTS(p_segment_qualifier) then  -- 5276582

       l_segment_code := g_array_key_flexfield(l_position).segment_qualifier(p_segment_qualifier);

    else  -- 5276582

       IF (C_LEVEL_STATEMENT >= g_log_level) THEN
             trace
                (p_msg      => 'Invalid qualifier'
                ,p_level    => C_LEVEL_PROCEDURE
                ,p_module   => l_log_module);
       END IF;
       l_segment_code := null;

    end if;

    IF l_segment_code IS NULL THEN
        RAISE invalid_segment_qualifier;
    END IF;

END IF;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'return value. = '||l_segment_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'END of get_segment_code'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
RETURN l_segment_code;
EXCEPTION
WHEN invalid_segment_qualifier THEN
   xla_ae_journal_entry_pkg.g_global_status:=  xla_ae_journal_entry_pkg.C_INVALID;

/*
   l_segment_name := xla_lookups_pkg.get_meaning(
                          'XLA_FLEXFIELD_SEGMENTS_QUAL'
                        ,  p_segment_qualifier
                         );
*/
   l_segment_name := xla_flex_pkg.get_qualifier_name   -- 5276582
                           (p_application_id    => p_flex_application_id
                           ,p_id_flex_code      => 'GL#'
                           ,p_qualifier_segment => p_segment_qualifier);

   l_key_flexfield_name :=  get_flex_structure_name(
                                       p_flex_application_id,
                                       p_id_flex_code,
                                       l_id_flex_num
                                       );

   l_product_name := get_application_name(p_flex_application_id);

   l_type  := xla_lookups_pkg.get_meaning(
                         'XLA_AMB_COMPONENT_TYPE'
                         , p_component_type
                         );

   l_name  := xla_ae_sources_pkg.GetComponentName (
                     p_component_type
                    ,p_component_code
                    ,p_component_type_code
                    ,p_component_appl_id
                    ,p_amb_context_code
                    ,p_entity_code
                    ,p_event_class_code
                    );

   l_owner := xla_lookups_pkg.get_meaning('XLA_OWNER_TYPE',p_component_type_code );

   xla_accounting_err_pkg.build_message
                   (p_appli_s_name            => 'XLA'
                   ,p_msg_name                => 'XLA_AP_INVALID_QUALIFIER'
                   ,p_token_1                 => 'QUALIFIER_NAME'
                   ,p_value_1                 =>  l_segment_name
                   ,p_token_2                 => 'KEY_FLEXFIELD_NAME'
                   ,p_value_2                 =>  l_key_flexfield_name
                   ,p_token_3                 => 'FLEX_APPLICATION_NAME'
                   ,p_value_3                 =>  l_product_name
                   ,p_token_4                 => 'COMPONENT_TYPE'
                   ,p_value_4                 =>  l_type
                   ,p_token_5                 => 'COMPONENT_NAME'
                   ,p_value_5                 =>  l_name
                   ,p_token_6                 => 'OWNER'
                   ,p_value_6                 => l_owner
                   ,p_entity_id               => xla_ae_journal_entry_pkg.g_cache_event.entity_id
                   ,p_event_id                => xla_ae_journal_entry_pkg.g_cache_event.event_id
                   ,p_ledger_id               => xla_ae_journal_entry_pkg.g_cache_event.target_ledger_id
                   ,p_ae_header_id            => NULL
     );
    IF (C_LEVEL_ERROR >= g_log_level) THEN
       trace
         (p_msg      => 'ERROR: XLA_AP_INVALID_QUALIFIER'
         ,p_level    => C_LEVEL_ERROR
         ,p_module   => l_log_module);
    END IF;
    RETURN NULL;
WHEN xla_exceptions_pkg.application_exception THEN
  RAISE;
WHEN OTHERS  THEN
   xla_exceptions_pkg.raise_message
           (p_location => 'xla_ae_code_combination_pkg.get_segment_code');
END get_segment_code;


/*-------------------------------------------------------------+
|                                                              |
| Public function                                              |
|                                                              |
|     get_flex_segment_value                                   |
|                                                              |
|  retrieves the segment value from key flexfield combination  |
|                                                              |
+-------------------------------------------------------------*/
-- replaces get_flexfield_segment()
FUNCTION get_flex_segment_value(
           p_combination_id         IN NUMBER
          ,p_segment_code           IN VARCHAR2
          ,p_id_flex_code           IN VARCHAR2
          ,p_flex_application_id    IN NUMBER
          ,p_application_short_name IN VARCHAR2
          ,p_source_code            IN VARCHAR2
          ,p_source_type_code       IN VARCHAR2
          ,p_source_application_id  IN NUMBER
          ,p_component_type         IN VARCHAR2
          ,p_component_code         IN VARCHAR2
          ,p_component_type_code    IN VARCHAR2
          ,p_component_appl_id      IN INTEGER
          ,p_amb_context_code       IN VARCHAR2
          ,p_entity_code            IN VARCHAR2
          ,p_event_class_code       IN VARCHAR2
          ,p_ae_header_id           IN NUMBER
)
RETURN VARCHAR2
IS
l_position                   NUMBER;
l_segment_value              VARCHAR2(25);
l_id_flex_num                NUMBER;
l_segment_code               VARCHAR2(30);
l_component_name             VARCHAR2(240);
l_product_name               VARCHAR2(240);
l_type                       VARCHAR2(240);
l_name                       VARCHAR2(240);
l_owner                      VARCHAR2(240);
l_source_name                VARCHAR2(240);
l_key_flexfield_name         VARCHAR2(240);
l_ConcatKey                  VARCHAR2(4000);
null_key_combination_id      EXCEPTION;
invalid_key_combination_id   EXCEPTION;
invalid_segment              EXCEPTION;
l_log_module                 VARCHAR2(240);
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.get_flex_segment_value';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of get_flexfield_segment'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_combination_id  = '|| TO_CHAR(p_combination_id)
                        ||' - p_segment_code  = '||p_segment_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

IF p_flex_application_id = 101 and p_id_flex_code ='GL#' THEN
   l_id_flex_num := xla_ae_journal_entry_pkg.g_cache_ledgers_info.source_coa_id;
ELSE
   l_id_flex_num := NULL;
END IF;

IF (C_LEVEL_STATEMENT >= g_log_level) THEN
     trace
          (p_msg      => 'p_flex_application_id = '||p_flex_application_id
                         ||' - p_id_flex_code = '||p_id_flex_code
                         ||' - l_id_flex_num = '||l_id_flex_num
          ,p_level    => C_LEVEL_STATEMENT
          ,p_module   => l_log_module);
     trace
          (p_msg      => 'p_source_code = '||p_source_code
                         ||' - p_source_type_code = '||p_source_type_code
                         ||' - p_source_application_id = '||p_source_application_id

          ,p_level    => C_LEVEL_STATEMENT
          ,p_module   => l_log_module);
     trace
          (p_msg      => 'p_component_code = '||p_component_code
                        ||' - p_component_type = '||p_component_type
                        ||' - p_component_type_code = '||p_component_type_code
                        ||' - p_amb_context_code = '||p_amb_context_code
                        ||' - p_entity_code = '||p_entity_code
                        ||' - p_event_class_code = '||p_event_class_code
          ,p_level    => C_LEVEL_STATEMENT
          ,p_module   => l_log_module);

END IF;

IF p_combination_id IS NULL THEN
   RAISE null_key_combination_id;
END IF;

l_position    := DBMS_UTILITY.get_hash_value(
                    TO_CHAR(p_combination_id)||
                    TO_CHAR(l_id_flex_num)||
                    TO_CHAR(p_flex_application_id)||
                    p_id_flex_code,1,1073741824);

IF (C_LEVEL_STATEMENT >= g_log_level) THEN
     trace
          (p_msg      => 'position = '||l_position
          ,p_level    => C_LEVEL_STATEMENT
          ,p_module   => l_log_module);
END IF;

IF NOT g_array_combination_id.EXISTS(l_position)
   OR g_array_combination_id(l_position).combination_id <> p_combination_id THEN

   cache_combination_id(
       p_combination_id         => p_combination_id
     , p_flex_application_id    => p_flex_application_id
     , p_application_short_name => p_application_short_name
     , p_id_flex_code           => p_id_flex_code
     , p_id_flex_num            => l_id_flex_num  )
     ;
END IF;

IF nvl(g_array_combination_id(l_position).combination_status,'N') <> 'Y' THEN
   RAISE invalid_key_combination_id;
END IF;

l_segment_code:= p_segment_code;

IF l_segment_code NOT LIKE 'SEGMENT%' THEN

   l_segment_code  := get_segment_code(
                         p_flex_application_id   => p_flex_application_id
                        ,p_application_short_name => p_application_short_name
                        ,p_id_flex_code          => p_id_flex_code
                        ,p_id_flex_num           => l_id_flex_num
                        ,p_segment_qualifier     => l_segment_code
                        ,p_component_type        => p_component_type
                        ,p_component_code        => p_component_code
                        ,p_component_type_code   => p_component_type_code
                        ,p_component_appl_id     => p_component_appl_id
                        ,p_amb_context_code      => p_amb_context_code
                        ,p_entity_code           => p_entity_code
                        ,p_event_class_code      => p_event_class_code
                        );

END IF;

CASE l_segment_code

   WHEN 'SEGMENT1'  THEN l_segment_value := g_array_combination_id(l_position).segment1;
   WHEN 'SEGMENT2'  THEN l_segment_value := g_array_combination_id(l_position).segment2;
   WHEN 'SEGMENT3'  THEN l_segment_value := g_array_combination_id(l_position).segment3;
   WHEN 'SEGMENT4'  THEN l_segment_value := g_array_combination_id(l_position).segment4;
   WHEN 'SEGMENT5'  THEN l_segment_value := g_array_combination_id(l_position).segment5;
   WHEN 'SEGMENT6'  THEN l_segment_value := g_array_combination_id(l_position).segment6;
   WHEN 'SEGMENT7'  THEN l_segment_value := g_array_combination_id(l_position).segment7;
   WHEN 'SEGMENT8'  THEN l_segment_value := g_array_combination_id(l_position).segment8;
   WHEN 'SEGMENT9'  THEN l_segment_value := g_array_combination_id(l_position).segment9;
   WHEN 'SEGMENT10' THEN l_segment_value := g_array_combination_id(l_position).segment10;
   WHEN 'SEGMENT11' THEN l_segment_value := g_array_combination_id(l_position).segment11;
   WHEN 'SEGMENT12' THEN l_segment_value := g_array_combination_id(l_position).segment12;
   WHEN 'SEGMENT13' THEN l_segment_value := g_array_combination_id(l_position).segment13;
   WHEN 'SEGMENT14' THEN l_segment_value := g_array_combination_id(l_position).segment14;
   WHEN 'SEGMENT15' THEN l_segment_value := g_array_combination_id(l_position).segment15;
   WHEN 'SEGMENT16' THEN l_segment_value := g_array_combination_id(l_position).segment16;
   WHEN 'SEGMENT17' THEN l_segment_value := g_array_combination_id(l_position).segment17;
   WHEN 'SEGMENT18' THEN l_segment_value := g_array_combination_id(l_position).segment18;
   WHEN 'SEGMENT19' THEN l_segment_value := g_array_combination_id(l_position).segment19;
   WHEN 'SEGMENT20' THEN l_segment_value := g_array_combination_id(l_position).segment20;
   WHEN 'SEGMENT21' THEN l_segment_value := g_array_combination_id(l_position).segment21;
   WHEN 'SEGMENT22' THEN l_segment_value := g_array_combination_id(l_position).segment22;
   WHEN 'SEGMENT23' THEN l_segment_value := g_array_combination_id(l_position).segment23;
   WHEN 'SEGMENT24' THEN l_segment_value := g_array_combination_id(l_position).segment24;
   WHEN 'SEGMENT25' THEN l_segment_value := g_array_combination_id(l_position).segment25;
   WHEN 'SEGMENT26' THEN l_segment_value := g_array_combination_id(l_position).segment26;
   WHEN 'SEGMENT27' THEN l_segment_value := g_array_combination_id(l_position).segment27;
   WHEN 'SEGMENT28' THEN l_segment_value := g_array_combination_id(l_position).segment28;
   WHEN 'SEGMENT29' THEN l_segment_value := g_array_combination_id(l_position).segment29;
   WHEN 'SEGMENT30' THEN l_segment_value := g_array_combination_id(l_position).segment30;

   ELSE
      RAISE invalid_segment;
END CASE;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'return value. = '||l_segment_value
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'END of get_flex_segment_value'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
RETURN l_segment_value;
EXCEPTION
WHEN invalid_segment THEN
   xla_ae_journal_entry_pkg.g_global_status  :=  xla_ae_journal_entry_pkg.C_INVALID;

   l_key_flexfield_name :=  get_flex_structure_name(
                                       p_flex_application_id,
                                       p_id_flex_code,
                                       l_id_flex_num
                                       );

   l_product_name := get_application_name(p_flex_application_id);

   l_type  := xla_lookups_pkg.get_meaning(
                         'XLA_AMB_COMPONENT_TYPE'
                         , p_component_type
                         );

   l_name  := xla_ae_sources_pkg.GetComponentName (
                     p_component_type
                    ,p_component_code
                    ,p_component_type_code
                    ,p_component_appl_id
                    ,p_amb_context_code
                    ,p_entity_code
                    ,p_event_class_code
                    );

   l_owner := xla_lookups_pkg.get_meaning('XLA_OWNER_TYPE',p_component_type_code );

   xla_accounting_err_pkg.build_message
                   (p_appli_s_name            => 'XLA'
                   ,p_msg_name                => 'XLA_AP_INVALID_QUALIFIER'
                   ,p_token_1                 => 'QUALIFIER_NAME'
                   ,p_value_1                 =>  p_segment_code
                   ,p_token_2                 => 'KEY_FLEXFIELD_NAME'
                   ,p_value_2                 =>  l_key_flexfield_name
                   ,p_token_3                 => 'FLEX_APPLICATION_NAME'
                   ,p_value_3                 =>  l_product_name
                   ,p_token_4                 => 'COMPONENT_TYPE'
                   ,p_value_4                 =>  l_type
                   ,p_token_5                 => 'COMPONENT_NAME'
                   ,p_value_5                 =>  l_name
                   ,p_token_6                 => 'OWNER'
                   ,p_value_6                 => l_owner
                   ,p_entity_id               => xla_ae_journal_entry_pkg.g_cache_event.entity_id
                   ,p_event_id                => xla_ae_journal_entry_pkg.g_cache_event.event_id
                   ,p_ledger_id               => xla_ae_journal_entry_pkg.g_cache_event.target_ledger_id
                   ,p_ae_header_id            => NULL
     );

  IF (C_LEVEL_ERROR >= g_log_level) THEN
         trace
            (p_msg      => 'ERROR:XLA_AP_INVALID_QUALIFIER'
            ,p_level    => C_LEVEL_ERROR
            ,p_module   => l_log_module);

  END IF;
  RETURN NULL;
WHEN null_key_combination_id THEN
   xla_ae_journal_entry_pkg.g_global_status      :=  xla_ae_journal_entry_pkg.C_INVALID;

   l_type  := xla_lookups_pkg.get_meaning(
                            'XLA_AMB_COMPONENT_TYPE'
                            , p_component_type
                            );

   l_name  := xla_ae_sources_pkg.GetComponentName (
                        p_component_type
                       ,p_component_code
                       ,p_component_type_code
                       ,p_component_appl_id
                       ,p_amb_context_code
                       ,p_entity_code
                       ,p_event_class_code
                    );

   l_owner       := xla_lookups_pkg.get_meaning(
                         'XLA_OWNER_TYPE'
                         ,p_component_type_code
                          );

   IF p_source_code IS NOT NULL THEN
         l_source_name := xla_ae_sources_pkg.GetSourceName(
                          p_source_code
                         ,p_source_type_code
                         ,p_source_application_id
                                      );
   END IF;

   xla_accounting_err_pkg.build_message
                 (p_appli_s_name  => 'XLA'
                 ,p_msg_name      => 'XLA_AP_NULL_CODE_COMBINATION'
                 ,p_token_1       => 'SOURCE_NAME'
                 ,p_value_1       =>  l_source_name
                 ,p_token_2       => 'COMPONENT_TYPE'
                 ,p_value_2       =>  l_type
                 ,p_token_3       => 'COMPONENT_NAME'
                 ,p_value_3       => l_name
                 ,p_token_4       => 'OWNER'
                 ,p_value_4       =>  l_owner
                 ,p_token_5       => 'PRODUCT_NAME'
                 ,p_value_5       => xla_ae_journal_entry_pkg.g_cache_event.application_name
                 ,p_entity_id     => xla_ae_journal_entry_pkg.g_cache_event.entity_id
                 ,p_event_id      => xla_ae_journal_entry_pkg.g_cache_event.event_id
                 ,p_ledger_id     => xla_ae_journal_entry_pkg.g_cache_event.target_ledger_id
                 ,p_ae_header_id  => NULL --p_ae_header_id
                 );

  IF (C_LEVEL_ERROR >= g_log_level) THEN
      trace
          (p_msg      => 'ERROR: XLA_AP_NULL_CODE_COMBINATION'
          ,p_level    => C_LEVEL_ERROR
          ,p_module   => l_log_module);
  END IF;
  RETURN NULL;
WHEN invalid_key_combination_id THEN
  xla_ae_journal_entry_pkg.g_global_status      :=  xla_ae_journal_entry_pkg.C_INVALID;
  l_type  := xla_lookups_pkg.get_meaning(
                              'XLA_AMB_COMPONENT_TYPE'
                              , p_component_type
                              );

  l_name  := xla_ae_sources_pkg.GetComponentName (
                          p_component_type
                         ,p_component_code
                         ,p_component_type_code
                         ,p_component_appl_id
                         ,p_amb_context_code
                         ,p_entity_code
                         ,p_event_class_code
                    );

   l_owner       := xla_lookups_pkg.get_meaning(
                         'XLA_OWNER_TYPE'
                         ,p_component_type_code
                          );

   IF p_source_code IS NOT NULL THEN
    l_source_name := xla_ae_sources_pkg.GetSourceName(
                          p_source_code
                         ,p_source_type_code
                         ,p_source_application_id
                         );
   END IF;

   l_ConcatKey := NVL(get_account_value(
                     p_combination_id
                   , p_flex_application_id
                   , p_application_short_name
                   , p_id_flex_code
                   , l_id_flex_num),TO_CHAR(p_combination_id));

  xla_accounting_err_pkg.build_message
       (p_appli_s_name => 'XLA'
       ,p_msg_name     => 'XLA_AP_INV_CODE_COMBINATION'
       ,p_token_1      => 'CODE_COMBINATION_ID'
       ,p_value_1      => l_ConcatKey
       ,p_token_2      => 'SOURCE_NAME'
       ,p_value_2      =>  l_source_name
       ,p_token_3      => 'COMPONENT_TYPE'
       ,p_value_3      => l_type
       ,p_token_4      => 'COMPONENT_NAME'
       ,p_value_4      => l_name
       ,p_token_5      => 'OWNER'
       ,p_value_5      => l_owner
       ,p_entity_id    => xla_ae_journal_entry_pkg.g_cache_event.entity_id
       ,p_event_id     => xla_ae_journal_entry_pkg.g_cache_event.event_id
       ,p_ledger_id    => xla_ae_journal_entry_pkg.g_cache_event.target_ledger_id
       ,p_ae_header_id => NULL --p_ae_header_id
        );

  IF (C_LEVEL_ERROR >= g_log_level) THEN
       trace
         (p_msg      => 'ERROR: XLA_AP_INV_CODE_COMBINATION'
         ,p_level    => C_LEVEL_ERROR
         ,p_module   => l_log_module);
  END IF;
  RETURN NULL;
WHEN xla_exceptions_pkg.application_exception THEN
  RETURN NULL;
WHEN OTHERS  THEN
   xla_exceptions_pkg.raise_message
           (p_location => 'xla_ae_code_combination_pkg.get_flex_segment_value');
END get_flex_segment_value;

/*-------------------------------------------------------------+
|                                                              |
| Public function                                              |
|                                                              |
|     get_flex_segment_desc                                    |
|                                                              |
|  retrieves the segment description for a given segment code  |
|                                                              |
+--------------------------------------------------------------*/

--replaces FUNCTION get_flexfield_description()
FUNCTION get_flex_segment_desc(
           p_combination_id         IN NUMBER
          ,p_segment_code           IN VARCHAR2
          ,p_id_flex_code           IN VARCHAR2
          ,p_flex_application_id    IN NUMBER
          ,p_application_short_name IN VARCHAR2
          ,p_source_code            IN VARCHAR2
          ,p_source_type_code       IN VARCHAR2
          ,p_source_application_id  IN NUMBER
          ,p_component_type         IN VARCHAR2
          ,p_component_code         IN VARCHAR2
          ,p_component_type_code    IN VARCHAR2
          ,p_component_appl_id      IN INTEGER
          ,p_amb_context_code       IN VARCHAR2
          ,p_ae_header_id           IN NUMBER
)
RETURN VARCHAR2
IS
l_segment_value         VARCHAR2(240);
l_segment_description   VARCHAR2(240);
l_segment_code          VARCHAR2(30) ;
l_desc_language         VARCHAR2(30);
l_id_flex_num           NUMBER;
l_log_module            VARCHAR2(240);
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.get_flex_segment_desc';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of get_flex_segment_desc'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_combination_id  = '|| TO_CHAR(p_combination_id)
                      ||' - p_segment_code  = '||p_segment_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

l_segment_description:= NULL;
IF p_flex_application_id = 101 and p_id_flex_code ='GL#' THEN
   l_id_flex_num := xla_ae_journal_entry_pkg.g_cache_ledgers_info.source_coa_id;
ELSE
   l_id_flex_num := NULL;
END IF;
l_desc_language := xla_ae_journal_entry_pkg.g_cache_ledgers_info.description_language;

IF (C_LEVEL_STATEMENT >= g_log_level) THEN
     trace
          (p_msg      => 'p_flex_application_id = '||p_flex_application_id
                         ||' - p_id_flex_code = '||p_id_flex_code
                         ||' - l_id_flex_num = '||l_id_flex_num
                         ||' - language = '||l_desc_language
          ,p_level    => C_LEVEL_STATEMENT
          ,p_module   => l_log_module);

      trace
          (p_msg      => 'p_source_code = '||p_source_code
                         ||' - p_source_type_code = '||p_source_type_code
                         ||' - p_source_application_id = '||p_source_application_id

          ,p_level    => C_LEVEL_STATEMENT
          ,p_module   => l_log_module);
     trace
          (p_msg      => 'p_component_code = '||p_component_code
                        ||' - p_component_type = '||p_component_type
                        ||' - p_component_type_code = '||p_component_type_code
                        ||' - p_amb_context_code = '||p_amb_context_code
          ,p_level    => C_LEVEL_STATEMENT
          ,p_module   => l_log_module);
END IF;

IF l_segment_code NOT LIKE 'SEGMENT%' THEN

   l_segment_code  := get_segment_code(
                         p_flex_application_id    => p_flex_application_id
                        ,p_application_short_name => p_application_short_name
                        ,p_id_flex_code           => p_id_flex_code
                        ,p_id_flex_num            => l_id_flex_num
                        ,p_segment_qualifier      => p_segment_code
                        ,p_component_type         => p_component_type
                        ,p_component_code         => p_component_code
                        ,p_component_type_code    => p_component_type_code
                        ,p_component_appl_id      => p_component_appl_id
                        ,p_amb_context_code       => p_amb_context_code
                        ,p_entity_code            => NULL
                        ,p_event_class_code       => NULL
                        );

END IF;

l_segment_value      := get_flex_segment_value(
           p_combination_id         => p_combination_id
          ,p_segment_code           => p_segment_code
          ,p_id_flex_code           => p_id_flex_code
          ,p_flex_application_id    => p_flex_application_id
          ,p_application_short_name => p_application_short_name
          ,p_source_code            => p_source_code
          ,p_source_type_code       => p_source_type_code
          ,p_source_application_id  => p_source_application_id
          ,p_component_type         => p_component_type
          ,p_component_code         => p_component_code
          ,p_component_type_code    => p_component_type_code
          ,p_component_appl_id      => p_component_appl_id
          ,p_amb_context_code       => p_amb_context_code
          ,p_entity_code            => NULL
          ,p_event_class_code       => NULL
          ,p_ae_header_id           => p_ae_header_id
          );

IF l_segment_value IS NOT NULL AND l_segment_code  IS NOT NULL THEN

       BEGIN
           IF (C_LEVEL_STATEMENT >= g_log_level) THEN
             trace
              (p_msg      => 'SQL - Select from fnd_flex_values_tl'
              ,p_level    => C_LEVEL_STATEMENT
              ,p_module   => l_log_module);
           END IF;

         SELECT ffvt.description
           INTO l_segment_description
           FROM fnd_flex_values_tl   ffvt
              , fnd_flex_values      ffv
              , fnd_id_flex_segments fifs
          WHERE ffvt.flex_value_meaning      = ffv.flex_value
            AND ffvt.flex_value_id           = ffv.flex_value_id
            AND ffvt.language                = l_desc_language
            AND ffv.flex_value               = l_segment_value
            AND ffv.flex_value_set_id        = fifs.flex_value_set_id
            AND fifs.application_id          = p_flex_application_id
            AND fifs.id_flex_code            = p_id_flex_code
            AND fifs.id_flex_num             = l_id_flex_num
            AND fifs.application_column_name = l_segment_code
            ;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
                    NULL;
            WHEN OTHERS THEN
                    NULL;
       END;
END IF;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'return value. = '||l_segment_description
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'END of get_flex_segment_desc'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
RETURN l_segment_description;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
       trace
           (p_msg      => 'Error. = '||sqlerrm
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
  END IF;
  RAISE;
WHEN OTHERS  THEN
   IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
       trace
           (p_msg      => 'Error. = '||sqlerrm
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
    END IF;
   xla_exceptions_pkg.raise_message
           (p_location => 'xla_ae_code_combination_pkg.get_flex_segment_desc');
END get_flex_segment_desc;


--======================================================================
--
--
--
--            routines to build the new accounting ccids
--
--
--
--=======================================================================


/*-------------------------------------------------------------+
|                                                              |
| Private function                                             |
|                                                              |
|     build_events_message                                     |
|                                                              |
|  build the line error messages for invalid ccids             |
|                                                              |
+-------------------------------------------------------------*/

PROCEDURE build_events_message(
        p_appli_s_name          IN VARCHAR2
      , p_msg_name              IN VARCHAR2
      , p_token_1               IN VARCHAR2
      , p_value_1               IN VARCHAR2
      , p_token_2               IN VARCHAR2
      , p_value_2               IN VARCHAR2
      , p_segment1              IN VARCHAR2
      , p_segment2              IN VARCHAR2
      , p_segment3              IN VARCHAR2
      , p_segment4              IN VARCHAR2
      , p_segment5              IN VARCHAR2
      , p_segment6              IN VARCHAR2
      , p_segment7              IN VARCHAR2
      , p_segment8              IN VARCHAR2
      , p_segment9              IN VARCHAR2
      , p_segment10             IN VARCHAR2
      , p_segment11             IN VARCHAR2
      , p_segment12             IN VARCHAR2
      , p_segment13             IN VARCHAR2
      , p_segment14             IN VARCHAR2
      , p_segment15             IN VARCHAR2
      , p_segment16             IN VARCHAR2
      , p_segment17             IN VARCHAR2
      , p_segment18             IN VARCHAR2
      , p_segment19             IN VARCHAR2
      , p_segment20             IN VARCHAR2
      , p_segment21             IN VARCHAR2
      , p_segment22             IN VARCHAR2
      , p_segment23             IN VARCHAR2
      , p_segment24             IN VARCHAR2
      , p_segment25             IN VARCHAR2
      , p_segment26             IN VARCHAR2
      , p_segment27             IN VARCHAR2
      , p_segment28             IN VARCHAR2
      , p_segment29             IN VARCHAR2
      , p_segment30             IN VARCHAR2
      , p_chart_of_accounts_id  IN NUMBER
  )
 IS
 l_log_module         VARCHAR2(240);
 BEGIN
 --
 IF g_log_enabled THEN
       l_log_module := C_DEFAULT_MODULE||'.build_events_message';
 END IF;
--
 IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

       trace
          (p_msg      => 'BEGIN of build_events_message'
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   => l_log_module);

 END IF;
--

 FOR events_rec IN (
         SELECT DISTINCT
               hdr.event_id         event_id,
               hdr.entity_id        entity_id,
               hdr.ledger_id        ledger_id,
               hdr.ae_header_id     ae_header_id,
               temp.ae_line_num ae_line_num
           FROM xla_ae_lines_gt     temp,
                xla_ae_headers_gt   hdr
         WHERE  temp.ae_header_id          = hdr.ae_header_id
           AND  temp.ccid_coa_id           = p_chart_of_accounts_id
           AND  nvl(temp.segment1 ,'#')    = nvl(p_segment1,'#')
           AND  nvl(temp.segment2 ,'#')    = nvl(p_segment2,'#')
           AND  nvl(temp.segment3 ,'#')    = nvl(p_segment3,'#')
           AND  nvl(temp.segment4 ,'#')    = nvl(p_segment4,'#')
           AND  nvl(temp.segment5 ,'#')    = nvl(p_segment5,'#')
           AND  nvl(temp.segment6 ,'#')    = nvl(p_segment6,'#')
           AND  nvl(temp.segment7 ,'#')    = nvl(p_segment7,'#')
           AND  nvl(temp.segment8 ,'#')    = nvl(p_segment8,'#')
           AND  nvl(temp.segment9 ,'#')    = nvl(p_segment9,'#')
           AND  nvl(temp.segment10,'#')    = nvl(p_segment10,'#')
           AND  nvl(temp.segment11,'#')    = nvl(p_segment11,'#')
           AND  nvl(temp.segment12,'#')    = nvl(p_segment12,'#')
           AND  nvl(temp.segment13,'#')    = nvl(p_segment13,'#')
           AND  nvl(temp.segment14,'#')    = nvl(p_segment14,'#')
           AND  nvl(temp.segment15,'#')    = nvl(p_segment15,'#')
           AND  nvl(temp.segment16,'#')    = nvl(p_segment16,'#')
           AND  nvl(temp.segment17,'#')    = nvl(p_segment17,'#')
           AND  nvl(temp.segment18,'#')    = nvl(p_segment18,'#')
           AND  nvl(temp.segment19,'#')    = nvl(p_segment19,'#')
           AND  nvl(temp.segment20,'#')    = nvl(p_segment20,'#')
           AND  nvl(temp.segment21,'#')    = nvl(p_segment21,'#')
           AND  nvl(temp.segment22,'#')    = nvl(p_segment22,'#')
           AND  nvl(temp.segment23,'#')    = nvl(p_segment23,'#')
           AND  nvl(temp.segment24,'#')    = nvl(p_segment24,'#')
           AND  nvl(temp.segment25,'#')    = nvl(p_segment25,'#')
           AND  nvl(temp.segment26,'#')    = nvl(p_segment26,'#')
           AND  nvl(temp.segment27,'#')    = nvl(p_segment27,'#')
           AND  nvl(temp.segment28,'#')    = nvl(p_segment28,'#')
           AND  nvl(temp.segment29,'#')    = nvl(p_segment29,'#')
           AND  nvl(temp.segment30,'#')    = nvl(p_segment30,'#')
           AND  temp.code_combination_id             = -1
           AND  temp.code_combination_status_code    = C_CREATED
           AND  temp.balance_type_code               <> 'X'
           AND  hdr.entity_id   IS NOT NULL
           AND  hdr.event_id    IS NOT NULL
           AND  hdr.ledger_id   IS NOT NULL
           )
 LOOP

      xla_ae_journal_entry_pkg.g_global_status      :=  xla_ae_journal_entry_pkg.C_INVALID;
      xla_accounting_err_pkg.build_message
                 (p_appli_s_name            => p_appli_s_name
                 ,p_msg_name                => p_msg_name
                 ,p_token_1                 => p_token_1
                 ,p_value_1                 => p_value_1
                 ,p_token_2                 => p_token_2
                 ,p_value_2                 => p_value_2
                 ,p_entity_id               => events_rec.entity_id
                 ,p_event_id                => events_rec.event_id
                 ,p_ledger_id               => events_rec.ledger_id
                 ,p_ae_header_id            => events_rec.ae_header_id
                 ,p_ae_line_num             => events_rec.ae_line_num
              );

   IF (C_LEVEL_ERROR >= g_log_level) THEN
      trace
          (p_msg      => 'ERROR: '||p_msg_name
          ,p_level    => C_LEVEL_ERROR
          ,p_module   => l_log_module);
   END IF;
 END LOOP;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
       trace
          (p_msg      => 'END of build_events_message'
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   => l_log_module);
 END IF;
--
 EXCEPTION
 WHEN xla_exceptions_pkg.application_exception THEN
   IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
       trace
           (p_msg      => 'Error. = '||sqlerrm
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
   END IF;
   RAISE;
 WHEN OTHERS  THEN
    IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
       trace
           (p_msg      => 'Error. = '||sqlerrm
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
    END IF;
    xla_exceptions_pkg.raise_message
            (p_location => 'xla_ae_code_combination_pkg.build_events_message');
END build_events_message;

/*-------------------------------------------------------------+
|                                                              |
| Private function                                             |
|                                                              |
|     get_ccid_errors                                          |
|                                                              |
|  get AOL error message for invalid ccids                     |
|                                                              |
+-------------------------------------------------------------*/

PROCEDURE get_ccid_errors
IS
  l_ConcatKey           VARCHAR2(2000);   -- key flex concateneted value
  --
  l_SegmentArray        FND_FLEX_EXT.SegmentArray;
  l_SegmentNumber       PLS_INTEGER;
  l_message             VARCHAR2(4000);
  l_Ccid                NUMBER;
  l_log_module          VARCHAR2(240);
BEGIN
--
IF g_log_enabled THEN
       l_log_module := C_DEFAULT_MODULE||'.get_ccid_errors';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of get_ccid_errors'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
FOR ccid_rec IN (
         SELECT DISTINCT
               temp.segment1        segment1,
               temp.segment2        segment2,
               temp.segment3        segment3,
               temp.segment4        segment4,
               temp.segment5        segment5,
               temp.segment6        segment6,
               temp.segment7        segment7,
               temp.segment8        segment8,
               temp.segment9        segment9,
               temp.segment10       segment10,
               temp.segment11       segment11,
               temp.segment12       segment12,
               temp.segment13       segment13,
               temp.segment14       segment14,
               temp.segment15       segment15,
               temp.segment16       segment16,
               temp.segment17       segment17,
               temp.segment18       segment18,
               temp.segment19       segment19,
               temp.segment20       segment20,
               temp.segment21       segment21,
               temp.segment22       segment22,
               temp.segment23       segment23,
               temp.segment24       segment24,
               temp.segment25       segment25,
               temp.segment26       segment26,
               temp.segment27       segment27,
               temp.segment28       segment28,
               temp.segment29       segment29,
               temp.segment30       segment30,
               temp.ccid_coa_id     coa_id
           FROM xla_ae_lines_gt    temp
         WHERE  temp.code_combination_id             = -1
           AND  temp.code_combination_status_code    = C_CREATED
           AND  temp.balance_type_code               <> 'X'
           )
 LOOP

      l_SegmentArray := init_SegmentArray(
                p_segment1                 => ccid_rec.segment1
              , p_segment2                 => ccid_rec.segment2
              , p_segment3                 => ccid_rec.segment3
              , p_segment4                 => ccid_rec.segment4
              , p_segment5                 => ccid_rec.segment5
              , p_segment6                 => ccid_rec.segment6
              , p_segment7                 => ccid_rec.segment7
              , p_segment8                 => ccid_rec.segment8
              , p_segment9                 => ccid_rec.segment9
              , p_segment10                => ccid_rec.segment10
              , p_segment11                => ccid_rec.segment11
              , p_segment12                => ccid_rec.segment12
              , p_segment13                => ccid_rec.segment13
              , p_segment14                => ccid_rec.segment14
              , p_segment15                => ccid_rec.segment15
              , p_segment16                => ccid_rec.segment16
              , p_segment17                => ccid_rec.segment17
              , p_segment18                => ccid_rec.segment18
              , p_segment19                => ccid_rec.segment19
              , p_segment20                => ccid_rec.segment20
              , p_segment21                => ccid_rec.segment21
              , p_segment22                => ccid_rec.segment22
              , p_segment23                => ccid_rec.segment23
              , p_segment24                => ccid_rec.segment24
              , p_segment25                => ccid_rec.segment25
              , p_segment26                => ccid_rec.segment26
              , p_segment27                => ccid_rec.segment27
              , p_segment28                => ccid_rec.segment28
              , p_segment29                => ccid_rec.segment29
              , p_segment30                => ccid_rec.segment30
              , p_flex_application_id      => 101
              , p_application_short_name   => 'SQLGL'
              , p_id_flex_code             =>'GL#'
              , p_id_flex_num              => ccid_rec.coa_id
            );

  l_SegmentNumber    := l_SegmentArray.COUNT;

 IF (C_LEVEL_STATEMENT >= g_log_level) THEN
       trace
              (p_msg      => '-> CALL FND_FLEX_EXT.get_combination_id API'
              ,p_level    => C_LEVEL_STATEMENT
              ,p_module   => l_log_module);

       END IF;

  IF FND_FLEX_EXT.get_combination_id(
                               application_short_name       => 'SQLGL',
                               key_flex_code                => 'GL#',
                               structure_number             => ccid_rec.coa_id,
                               validation_date              => sysdate,
                               n_segments                   => l_SegmentNumber,
                               segments                     => l_SegmentArray,
                               combination_id               => l_Ccid) = FALSE
  THEN

      --
      -- get FND error message
      --
      l_message:= SUBSTR(FND_FLEX_EXT.get_message,1,2000);
      --
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN

           trace
              (p_msg      => 'l_message = '||l_message
              ,p_level    => C_LEVEL_STATEMENT
              ,p_module   => l_log_module);

           trace
              (p_msg      => '-> CALL FND_FLEX_EXT.concatenate_segments API'
              ,p_level    => C_LEVEL_STATEMENT
              ,p_module   => l_log_module);

       END IF;
      --
      -- Concatenates segments from segment array
      --
      l_ConcatKey := FND_FLEX_EXT.concatenate_segments(
                                n_segments     => l_SegmentNumber,
                                segments       => l_SegmentArray,
                                delimiter      => FND_FLEX_EXT.get_delimiter(
                                                       application_short_name       => 'SQLGL',
                                                       key_flex_code                => 'GL#',
                                                       structure_number             => ccid_rec.coa_id
                                                                            )
                                                     );
      --

      build_events_message(
                 p_appli_s_name            => 'XLA'
               , p_msg_name                => 'XLA_AP_INVALID_AOL_CCID'
               , p_token_1                 => 'ACCOUNT_VALUE'
               , p_value_1                 =>  l_ConcatKey
               , p_token_2                 => 'MESSAGE'
               , p_value_2                 => l_message
               , p_segment1                => ccid_rec.segment1
               , p_segment2                => ccid_rec.segment2
               , p_segment3                => ccid_rec.segment3
               , p_segment4                => ccid_rec.segment4
               , p_segment5                => ccid_rec.segment5
               , p_segment6                => ccid_rec.segment6
               , p_segment7                => ccid_rec.segment7
               , p_segment8                => ccid_rec.segment8
               , p_segment9                => ccid_rec.segment9
               , p_segment10               => ccid_rec.segment10
               , p_segment11               => ccid_rec.segment11
               , p_segment12               => ccid_rec.segment12
               , p_segment13               => ccid_rec.segment13
               , p_segment14               => ccid_rec.segment14
               , p_segment15               => ccid_rec.segment15
               , p_segment16               => ccid_rec.segment16
               , p_segment17               => ccid_rec.segment17
               , p_segment18               => ccid_rec.segment18
               , p_segment19               => ccid_rec.segment19
               , p_segment20               => ccid_rec.segment20
               , p_segment21               => ccid_rec.segment21
               , p_segment22               => ccid_rec.segment22
               , p_segment23               => ccid_rec.segment23
               , p_segment24               => ccid_rec.segment24
               , p_segment25               => ccid_rec.segment25
               , p_segment26               => ccid_rec.segment26
               , p_segment27               => ccid_rec.segment27
               , p_segment28               => ccid_rec.segment28
               , p_segment29               => ccid_rec.segment29
               , p_segment30               => ccid_rec.segment30
               , p_chart_of_accounts_id    => ccid_rec.coa_id
               );

  END IF;
END LOOP;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of get_ccid_errors'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
       trace
           (p_msg      => 'Error. = '||sqlerrm
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
  END IF;
  RAISE;
WHEN OTHERS  THEN
   IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
       trace
           (p_msg      => 'Error. = '||sqlerrm
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
   END IF;
   xla_exceptions_pkg.raise_message
           (p_location => 'xla_ae_code_combination_pkg.get_ccid_errors');
END get_ccid_errors;

/*-------------------------------------------------------------+
|                                                              |
| Public function                                              |
|                                                              |
|     GetCcid                                                  |
|                                                              |
| Call AOL routine to create the new ccid, when the ccid does  |
| not exist in the gl_code_combinations table. It calls the    |
| AOL API FND_FLEX_EXT.get_combination_id.                     |
|                                                              |
+-------------------------------------------------------------*/

FUNCTION GetCcid(
        p_segment1              IN VARCHAR2
      , p_segment2              IN VARCHAR2
      , p_segment3              IN VARCHAR2
      , p_segment4              IN VARCHAR2
      , p_segment5              IN VARCHAR2
      , p_segment6              IN VARCHAR2
      , p_segment7              IN VARCHAR2
      , p_segment8              IN VARCHAR2
      , p_segment9              IN VARCHAR2
      , p_segment10             IN VARCHAR2
      , p_segment11             IN VARCHAR2
      , p_segment12             IN VARCHAR2
      , p_segment13             IN VARCHAR2
      , p_segment14             IN VARCHAR2
      , p_segment15             IN VARCHAR2
      , p_segment16             IN VARCHAR2
      , p_segment17             IN VARCHAR2
      , p_segment18             IN VARCHAR2
      , p_segment19             IN VARCHAR2
      , p_segment20             IN VARCHAR2
      , p_segment21             IN VARCHAR2
      , p_segment22             IN VARCHAR2
      , p_segment23             IN VARCHAR2
      , p_segment24             IN VARCHAR2
      , p_segment25             IN VARCHAR2
      , p_segment26             IN VARCHAR2
      , p_segment27             IN VARCHAR2
      , p_segment28             IN VARCHAR2
      , p_segment29             IN VARCHAR2
      , p_segment30             IN VARCHAR2
      , p_chart_of_accounts_id  IN NUMBER
  )
RETURN NUMBER
IS
  l_ConcatKey           VARCHAR2(4000);   -- key flex concateneted value
  --
  l_SegmentArray        FND_FLEX_EXT.SegmentArray;
  l_SegmentNumber       PLS_INTEGER;
  l_Ccid                NUMBER;
  l_sql_stmt            VARCHAR2(10000);
  l_message             VARCHAR2(4000);
  l_log_module          VARCHAR2(240);
BEGIN
--
IF g_log_enabled THEN
       l_log_module := C_DEFAULT_MODULE||'.GetCcid';
END IF;
--

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of GetCcid'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
IF (C_LEVEL_STATEMENT >= g_log_level) THEN

     trace
          (p_msg      => 'p_chart_of_accounts_id = '||p_chart_of_accounts_id
          ,p_level    => C_LEVEL_STATEMENT
          ,p_module   => l_log_module);
     trace
          (p_msg      => 'p_segment1 = '||p_segment1 ||
                         '- p_segment2 = '||p_segment2 ||
                         '- p_segment3 = '||p_segment3 ||
                         '- p_segment4 = '||p_segment4 ||
                         '- p_segment5 = '||p_segment5 ||
                         '- p_segment6 = '||p_segment6 ||
                         '- p_segment7 = '||p_segment7 ||
                         '- p_segment8 = '||p_segment8 ||
                         '- p_segment9 = '||p_segment9 ||
                         '- p_segment10 = '||p_segment10
          ,p_level    => C_LEVEL_STATEMENT
          ,p_module   => l_log_module);

       trace
          (p_msg      => 'p_segment11 = '||p_segment11 ||
                         '- p_segment12 = '||p_segment12 ||
                         '- p_segment13 = '||p_segment13 ||
                         '- p_segment14 = '||p_segment14 ||
                         '- p_segment15 = '||p_segment15 ||
                         '- p_segment16 = '||p_segment16 ||
                         '- p_segment17 = '||p_segment17 ||
                         '- p_segment18 = '||p_segment18 ||
                         '- p_segment19 = '||p_segment19 ||
                         '- p_segment20 = '||p_segment20
          ,p_level    => C_LEVEL_STATEMENT
          ,p_module   => l_log_module);
       trace
          (p_msg      => 'p_segment21 = '||p_segment21 ||
                         '- p_segment22 = '||p_segment22 ||
                         '- p_segment23 = '||p_segment23 ||
                         '- p_segment24 = '||p_segment24 ||
                         '- p_segment25 = '||p_segment25 ||
                         '- p_segment26 = '||p_segment26 ||
                         '- p_segment27 = '||p_segment27 ||
                         '- p_segment28 = '||p_segment28 ||
                         '- p_segment29 = '||p_segment29 ||
                         '- p_segment30 = '||p_segment30
          ,p_level    => C_LEVEL_STATEMENT
          ,p_module   => l_log_module);

END IF;
       l_SegmentArray := init_SegmentArray(
                p_segment1                 => p_segment1
              , p_segment2                 => p_segment2
              , p_segment3                 => p_segment3
              , p_segment4                 => p_segment4
              , p_segment5                 => p_segment5
              , p_segment6                 => p_segment6
              , p_segment7                 => p_segment7
              , p_segment8                 => p_segment8
              , p_segment9                 => p_segment9
              , p_segment10                => p_segment10
              , p_segment11                => p_segment11
              , p_segment12                => p_segment12
              , p_segment13                => p_segment13
              , p_segment14                => p_segment14
              , p_segment15                => p_segment15
              , p_segment16                => p_segment16
              , p_segment17                => p_segment17
              , p_segment18                => p_segment18
              , p_segment19                => p_segment19
              , p_segment20                => p_segment20
              , p_segment21                => p_segment21
              , p_segment22                => p_segment22
              , p_segment23                => p_segment23
              , p_segment24                => p_segment24
              , p_segment25                => p_segment25
              , p_segment26                => p_segment26
              , p_segment27                => p_segment27
              , p_segment28                => p_segment28
              , p_segment29                => p_segment29
              , p_segment30                => p_segment30
              , p_flex_application_id      => 101
              , p_application_short_name   => 'SQLGL'
              , p_id_flex_code             =>'GL#'
              , p_id_flex_num              => p_chart_of_accounts_id
            );

       l_SegmentNumber    := l_SegmentArray.COUNT;


      IF (C_LEVEL_STATEMENT >= g_log_level) THEN

           trace
              (p_msg      => '-> CALL FND_FLEX_EXT.get_combination_id API'
              ,p_level    => C_LEVEL_STATEMENT
              ,p_module   => l_log_module);

       END IF;

  IF FND_FLEX_EXT.get_combination_id(
                               application_short_name       => 'SQLGL',
                               key_flex_code                => 'GL#',
                               structure_number             => p_chart_of_accounts_id,
                               validation_date              => sysdate,
                               n_segments                   => l_SegmentNumber,
                               segments                     => l_SegmentArray,
                               combination_id               => l_Ccid) = FALSE
  THEN

    g_error_exists := TRUE;
    xla_ae_journal_entry_pkg.g_global_status              := xla_ae_journal_entry_pkg.C_INVALID;

    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

        trace
           (p_msg      => 'return value. = -1'
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);

        trace
           (p_msg      => 'END of functionGetCcid'
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);

    END IF;
    RETURN -1;

  ELSE

     IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
        trace
           (p_msg      => 'return value. = '||l_Ccid
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
        trace
           (p_msg      => 'END of GetCcid'
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);

     END IF;

    RETURN l_Ccid;
  END IF;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
       trace
           (p_msg      => 'Error. = '||sqlerrm
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
  END IF;
  RAISE;
WHEN OTHERS  THEN
   IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
       trace
           (p_msg      => 'Error. = '||sqlerrm
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
   END IF;
   xla_exceptions_pkg.raise_message
           (p_location => 'xla_ae_code_combination_pkg.GetCcid');
END GetCcid;

/*------------------------------------------------------------------+
|                                                                   |
| Private function                                                  |
|                                                                   |
|     validate_source_ccid                                          |
|                                                                   |
| This function validates the code combination identifiers          |
| passed to  ccounting engine through the extract (by the product). |
| It returns the number of rows updated                             |
|                                                                   |
+------------------------------------------------------------------*/

FUNCTION  validate_source_ccid
RETURN NUMBER
IS
l_log_module         VARCHAR2(240);
l_rowcount           NUMBER;
l_count              NUMBER;
BEGIN
IF g_log_enabled THEN
       l_log_module := C_DEFAULT_MODULE||'.validate_source_ccid';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of validate_source_ccid'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

l_count     := 0;
l_rowcount  := 0;

IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace
         (p_msg      => 'Validate the accounting ccids: SQL - Update xla_ae_lines_gt '
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
END IF;

UPDATE xla_ae_lines_gt temp
   SET code_combination_status_code   =
          CASE
          WHEN temp.code_combination_id            IS NOT NULL
           AND temp.code_combination_status_code   = C_NOT_PROCESSED
           AND temp.code_combination_id            <> -1
           AND temp.balance_type_code              <> 'X'
           AND NOT EXISTS
                  (SELECT 'x'
                     FROM gl_code_combinations gl
                    WHERE gl.code_combination_id  = temp.code_combination_id
                      AND gl.chart_of_accounts_id = temp.ccid_coa_id
                      AND gl.template_id          IS NULL)
          THEN C_INVALID
          ELSE code_combination_status_code
          END
      ,alt_ccid_status_code =
          CASE
          WHEN temp.alt_code_combination_id       IS NOT NULL
           AND temp.alt_ccid_status_code          = C_NOT_PROCESSED
           AND temp.alt_code_combination_id       <> -1
           AND temp.balance_type_code             <> 'X'
           AND NOT EXISTS
                  (SELECT 'x'
                     FROM gl_code_combinations gl
                    WHERE gl.code_combination_id   = temp.alt_code_combination_id
                      AND gl.chart_of_accounts_id  = temp.ccid_coa_id
                      AND gl.template_id           IS NULL)
          THEN C_INVALID
          ELSE alt_ccid_status_code
          END
WHERE
     (temp.code_combination_id            IS NOT NULL
  AND temp.code_combination_status_code   = C_NOT_PROCESSED
  AND temp.code_combination_id            <> -1
  AND temp.balance_type_code              <> 'X'
  AND NOT EXISTS (SELECT 'x'
                     FROM gl_code_combinations gl
                    WHERE gl.code_combination_id   = temp.code_combination_id
                      AND gl.chart_of_accounts_id  = temp.ccid_coa_id
                      AND gl.template_id          IS NULL
                  ))
   OR
     (temp.alt_code_combination_id        IS NOT NULL
  AND temp.alt_ccid_status_code           = C_NOT_PROCESSED
  AND temp.alt_code_combination_id        <> -1
  AND temp.balance_type_code              <> 'X'
  AND NOT EXISTS (SELECT 'x'
                    FROM gl_code_combinations gl
                   WHERE gl.code_combination_id   = temp.alt_code_combination_id
                     AND gl.chart_of_accounts_id  = temp.ccid_coa_id
                     AND gl.template_id          IS NULL
                  ))
          ;

l_rowcount := SQL%ROWCOUNT;
l_count:= l_count + l_rowcount;

IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace
         (p_msg      => '# rows Updated in xla_ae_lines_gt (ccid + ALT ccid) ='||l_rowcount
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
END IF;


--logging the errors
IF ( l_count> 0 ) THEN

   xla_ae_journal_entry_pkg.g_global_status              := xla_ae_journal_entry_pkg.C_INVALID;

   FOR error_rec IN (
        SELECT event_id
              ,entity_id
              ,ledger_id
              ,ae_header_id
              ,ccid
       FROM (
         --accounting ccid
         SELECT DISTINCT
               hdr.event_id                 event_id,
               hdr.entity_id                entity_id,
               hdr.ledger_id                ledger_id,
               hdr.ae_header_id             ae_header_id,
               lns.code_combination_id      ccid
           FROM xla_ae_lines_gt     lns,
                xla_ae_headers_gt   hdr
         WHERE  lns.ae_header_id                    = hdr.ae_header_id
           AND  lns.code_combination_id             <> -1
           AND  lns.code_combination_status_code    = C_INVALID
           AND  lns.balance_type_code               <> 'X'
           AND  hdr.entity_id   IS NOT NULL
           AND  hdr.event_id    IS NOT NULL
           AND  hdr.ledger_id   IS NOT NULL

         UNION
         --accounting ALT ccid
         SELECT DISTINCT
               hdr.event_id                 event_id,
               hdr.entity_id                entity_id,
               hdr.ledger_id                ledger_id,
               hdr.ae_header_id             ae_header_id,
               lns.alt_code_combination_id      ccid
           FROM xla_ae_lines_gt     lns,
                xla_ae_headers_gt   hdr
         WHERE  lns.ae_header_id                    = hdr.ae_header_id
           AND  lns.alt_code_combination_id             <> -1
           AND  lns.alt_ccid_status_code    = C_INVALID
           AND  lns.balance_type_code               <> 'X'
           AND  hdr.entity_id   IS NOT NULL
           AND  hdr.event_id    IS NOT NULL
           AND  hdr.ledger_id   IS NOT NULL
           )
       )
   LOOP
            xla_ae_journal_entry_pkg.g_global_status      :=  xla_ae_journal_entry_pkg.C_INVALID;
            xla_accounting_err_pkg.build_message
                                               (p_appli_s_name            => 'XLA'
                                               ,p_msg_name                => 'XLA_AP_CCID_NOT_EXISTS'
                                               ,p_token_1                 => 'CODE_COMBINATION_ID'
                                               ,p_value_1                 =>  error_rec.ccid
                                               ,p_entity_id               =>  error_rec.entity_id
                                               ,p_event_id                =>  error_rec.event_id
                                               ,p_ledger_id               =>  error_rec.ledger_id
                                               ,p_ae_header_id            =>  error_rec.ae_header_id
              );

              IF (C_LEVEL_ERROR >= g_log_level) THEN

                 trace
                   (p_msg      => 'ERROR: XLA_AP_CCID_NOT_EXISTS = '||TO_CHAR(error_rec.ccid)
                   ,p_level    => C_LEVEL_ERROR
                   ,p_module   => l_log_module);

              END IF;

   END LOOP;
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
        trace
           (p_msg      => 'END of validate_source_ccid'
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
END IF;
RETURN l_count;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
       trace
           (p_msg      => 'Error. = '||sqlerrm
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
  END IF;
  RAISE;
WHEN OTHERS  THEN
  IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
       trace
           (p_msg      => 'Error. = '||sqlerrm
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
  END IF;
  xla_exceptions_pkg.raise_message
           (p_location => 'xla_ae_code_combination_pkg.validate_source_ccid');
END validate_source_ccid;

/*------------------------------------------------------------------+
|                                                                   |
| Private function                                                  |
|                                                                   |
|     override_ccid                                                 |
|                                                                   |
| Override accounting ccid segments. It returns the number of rows  |
| updated.                                                          |
|                                                                   |
+------------------------------------------------------------------*/

FUNCTION  override_ccid
RETURN NUMBER
IS
l_log_module         VARCHAR2(240);
l_rowcount           NUMBER;
l_return             NUMBER;
BEGIN
IF g_log_enabled THEN
       l_log_module := C_DEFAULT_MODULE||'.override_ccid';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of override_ccid'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;

l_return    := 0;
l_rowcount  := 0;

IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace
         (p_msg      => 'Override the accounting ccid: SQL - Update xla_ae_lines_gt '
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
END IF;

UPDATE xla_ae_lines_gt temp
   SET
      ( segment1
      , segment2
      , segment3
      , segment4
      , segment5
      , segment6
      , segment7
      , segment8
      , segment9
      , segment10
      , segment11
      , segment12
      , segment13
      , segment14
      , segment15
      , segment16
      , segment17
      , segment18
      , segment19
      , segment20
      , segment21
      , segment22
      , segment23
      , segment24
      , segment25
      , segment26
      , segment27
      , segment28
      , segment29
      , segment30
      , code_combination_status_code
      )
   = (
     SELECT
              nvl(temp.segment1  , gl.segment1)
            , nvl(temp.segment2  , gl.segment2)
            , nvl(temp.segment3  , gl.segment3)
            , nvl(temp.segment4  , gl.segment4)
            , nvl(temp.segment5  , gl.segment5)
            , nvl(temp.segment6  , gl.segment6)
            , nvl(temp.segment7  , gl.segment7)
            , nvl(temp.segment8  , gl.segment8)
            , nvl(temp.segment9  , gl.segment9)
            , nvl(temp.segment10 , gl.segment10)
            , nvl(temp.segment11 , gl.segment11)
            , nvl(temp.segment12 , gl.segment12)
            , nvl(temp.segment13 , gl.segment13)
            , nvl(temp.segment14 , gl.segment14)
            , nvl(temp.segment15 , gl.segment15)
            , nvl(temp.segment16 , gl.segment16)
            , nvl(temp.segment17 , gl.segment17)
            , nvl(temp.segment18 , gl.segment18)
            , nvl(temp.segment19 , gl.segment19)
            , nvl(temp.segment20 , gl.segment20)
            , nvl(temp.segment21 , gl.segment21)
            , nvl(temp.segment22 , gl.segment22)
            , nvl(temp.segment23 , gl.segment23)
            , nvl(temp.segment24 , gl.segment24)
            , nvl(temp.segment25 , gl.segment25)
            , nvl(temp.segment26 , gl.segment26)
            , nvl(temp.segment27 , gl.segment27)
            , nvl(temp.segment28 , gl.segment28)
            , nvl(temp.segment29 , gl.segment29)
            , nvl(temp.segment30 , gl.segment30)
            , C_PROCESSING
        FROM gl_code_combinations gl
       WHERE gl.code_combination_id   = temp.code_combination_id
         AND gl.chart_of_accounts_id  = temp.ccid_coa_id
         AND gl.template_id          IS NULL
       )
WHERE temp.code_combination_id            IS NOT NULL
  AND temp.code_combination_status_code   = C_NOT_PROCESSED
  AND temp.code_combination_id            <> -1
;

l_rowcount := SQL%ROWCOUNT;
l_return := l_return + l_rowcount;


IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace
         (p_msg      => '# rows updates = '||TO_CHAR(l_rowcount)
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

    trace
         (p_msg      => 'Override the accounting ALT ccid: SQL - Update xla_ae_lines_gt '
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

END IF;


UPDATE xla_ae_lines_gt temp
   SET
      ( alt_segment1
      , alt_segment2
      , alt_segment3
      , alt_segment4
      , alt_segment5
      , alt_segment6
      , alt_segment7
      , alt_segment8
      , alt_segment9
      , alt_segment10
      , alt_segment11
      , alt_segment12
      , alt_segment13
      , alt_segment14
      , alt_segment15
      , alt_segment16
      , alt_segment17
      , alt_segment18
      , alt_segment19
      , alt_segment20
      , alt_segment21
      , alt_segment22
      , alt_segment23
      , alt_segment24
      , alt_segment25
      , alt_segment26
      , alt_segment27
      , alt_segment28
      , alt_segment29
      , alt_segment30
      , alt_ccid_status_code
      )
   = (
     SELECT
              nvl(temp.alt_segment1  , gl.segment1)
            , nvl(temp.alt_segment2  , gl.segment2)
            , nvl(temp.alt_segment3  , gl.segment3)
            , nvl(temp.alt_segment4  , gl.segment4)
            , nvl(temp.alt_segment5  , gl.segment5)
            , nvl(temp.alt_segment6  , gl.segment6)
            , nvl(temp.alt_segment7  , gl.segment7)
            , nvl(temp.alt_segment8  , gl.segment8)
            , nvl(temp.alt_segment9  , gl.segment9)
            , nvl(temp.alt_segment10 , gl.segment10)
            , nvl(temp.alt_segment11 , gl.segment11)
            , nvl(temp.alt_segment12 , gl.segment12)
            , nvl(temp.alt_segment13 , gl.segment13)
            , nvl(temp.alt_segment14 , gl.segment14)
            , nvl(temp.alt_segment15 , gl.segment15)
            , nvl(temp.alt_segment16 , gl.segment16)
            , nvl(temp.alt_segment17 , gl.segment17)
            , nvl(temp.alt_segment18 , gl.segment18)
            , nvl(temp.alt_segment19 , gl.segment19)
            , nvl(temp.alt_segment20 , gl.segment20)
            , nvl(temp.alt_segment21 , gl.segment21)
            , nvl(temp.alt_segment22 , gl.segment22)
            , nvl(temp.alt_segment23 , gl.segment23)
            , nvl(temp.alt_segment24 , gl.segment24)
            , nvl(temp.alt_segment25 , gl.segment25)
            , nvl(temp.alt_segment26 , gl.segment26)
            , nvl(temp.alt_segment27 , gl.segment27)
            , nvl(temp.alt_segment28 , gl.segment28)
            , nvl(temp.alt_segment29 , gl.segment29)
            , nvl(temp.alt_segment30 , gl.segment30)
            , C_PROCESSING
        FROM gl_code_combinations gl
       WHERE gl.code_combination_id   = temp.alt_code_combination_id
         AND gl.chart_of_accounts_id  = temp.ccid_coa_id
         AND gl.template_id          IS NULL
       )
WHERE temp.alt_code_combination_id    IS NOT NULL
  AND temp.alt_ccid_status_code       = C_NOT_PROCESSED
  AND temp.alt_code_combination_id    <> -1
;

l_rowcount := SQL%ROWCOUNT;
l_return := l_return + l_rowcount;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
       trace
         (p_msg      => '# rows updates = '||TO_CHAR(l_rowcount)||
                        ' - return value. = '||to_char(l_return)
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
       trace
           (p_msg      => 'END of override_ccid'
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
END IF;
RETURN l_return;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
 IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
       trace
           (p_msg      => 'Error. = '||sqlerrm
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
  END IF;
  RAISE;
WHEN OTHERS  THEN
   IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
       trace
           (p_msg      => 'Error. = '||sqlerrm
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
  END IF;
   xla_exceptions_pkg.raise_message
           (p_location => 'xla_ae_code_combination_pkg.override_ccid');
END override_ccid;

/*-----------------------------------------------------------------------+
|                                                                        |
| Private function                                                       |
|                                                                        |
|     create_ccid                                                        |
|                                                                        |
| retrieves new accounting ccids and ALT ccids from gl_code_combinations |
| gl_code_combinations table. It returns the  number of rows updated     |
|                                                                        |
+-----------------------------------------------------------------------*/

FUNCTION create_ccid
RETURN NUMBER
IS
l_upd_stmt            VARCHAR2(20000);
l_sql_stmt            VARCHAR2(20000);
l_alt_sql_stmt        VARCHAR2(20000);
l_position            NUMBER;
l_id_flex_num         NUMBER;
l_rowcount            NUMBER;
l_count               NUMBER;
l_log_module          VARCHAR2(240);

BEGIN
IF g_log_enabled THEN
       l_log_module := C_DEFAULT_MODULE||'.create_ccid';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of create_ccid'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;

l_count    := 0;
l_rowcount := 0;

IF g_array_cache_target_coa.COUNT > 0 THEN

  FOR Idx IN g_array_cache_target_coa.FIRST .. g_array_cache_target_coa.LAST  LOOP

    IF g_array_cache_target_coa.EXISTS(Idx) AND g_array_cache_target_coa(Idx) IS NOT NULL THEN

       l_position:=  DBMS_UTILITY.get_hash_value(
                             TO_CHAR(g_array_cache_target_coa(Idx))||
                             TO_CHAR(101)||
                             'GL#',1,1073741824);

       IF NOT g_array_key_flexfield.EXISTS(l_position) THEN

         l_id_flex_num := g_array_cache_target_coa(Idx);

           cache_key_flexfield(
            p_flex_application_id    => 101,
            p_application_short_name => 'SQLGL',
            p_id_flex_code           => 'GL#',
            p_id_flex_num            => l_id_flex_num
            );

       END IF;

       --
       --  Initialize when coa id is switched.
       --
       l_sql_stmt     := NULL;
       l_alt_sql_stmt := NULL;

       FOR Jdx IN g_array_key_flexfield(l_position).segment_num.first ..
                   g_array_key_flexfield(l_position).segment_num.last LOOP

            IF g_array_key_flexfield(l_position).segment_num.EXISTS(Jdx) THEN

               CASE g_array_key_flexfield(l_position).segment_num(Jdx)

                WHEN 'SEGMENT1'  THEN
                    l_sql_stmt := l_sql_stmt || ' AND glc.segment1 = temp.segment1' ;
                    l_alt_sql_stmt := l_alt_sql_stmt || ' AND glc.segment1 = temp.alt_segment1' ;
                WHEN 'SEGMENT2'  THEN
                    l_sql_stmt := l_sql_stmt || ' AND glc.segment2 = temp.segment2 ' ;
                    l_alt_sql_stmt := l_alt_sql_stmt || ' AND glc.segment2 = temp.alt_segment2 ' ;
                WHEN 'SEGMENT3'  THEN
                    l_sql_stmt := l_sql_stmt || ' AND glc.segment3 = temp.segment3 ' ;
                    l_alt_sql_stmt := l_alt_sql_stmt || ' AND glc.segment3 = temp.alt_segment3 ' ;
                WHEN 'SEGMENT4'  THEN
                    l_sql_stmt := l_sql_stmt || ' AND glc.segment4 = temp.segment4 ' ;
                    l_alt_sql_stmt := l_alt_sql_stmt || ' AND glc.segment4 = temp.alt_segment4 ' ;
                WHEN 'SEGMENT5'  THEN
                    l_sql_stmt := l_sql_stmt || ' AND glc.segment5 = temp.segment5 ' ;
                    l_alt_sql_stmt := l_alt_sql_stmt || ' AND glc.segment5 = temp.alt_segment5 ' ;
                WHEN 'SEGMENT6'  THEN
                    l_sql_stmt := l_sql_stmt || ' AND glc.segment6 = temp.segment6 ' ;
                    l_alt_sql_stmt := l_alt_sql_stmt || ' AND glc.segment6 = temp.alt_segment6 ' ;
                WHEN 'SEGMENT7'  THEN
                    l_sql_stmt := l_sql_stmt || ' AND glc.segment7 = temp.segment7 ' ;
                    l_alt_sql_stmt := l_alt_sql_stmt || ' AND glc.segment7 = temp.alt_segment7 ' ;
                WHEN 'SEGMENT8'  THEN
                    l_sql_stmt := l_sql_stmt || ' AND glc.segment8 = temp.segment8 ' ;
                    l_alt_sql_stmt := l_alt_sql_stmt || ' AND glc.segment8 = temp.alt_segment8 ' ;
                WHEN 'SEGMENT9'  THEN
                    l_sql_stmt := l_sql_stmt || ' AND glc.segment9 = temp.segment9 ' ;
                    l_alt_sql_stmt := l_alt_sql_stmt || ' AND glc.segment9 = temp.alt_segment9 ' ;
                WHEN 'SEGMENT10' THEN
                    l_sql_stmt := l_sql_stmt || ' AND glc.segment10 = temp.segment10 '  ;
                    l_alt_sql_stmt := l_alt_sql_stmt || ' AND glc.segment10 = temp.alt_segment10 '  ;
                WHEN 'SEGMENT11' THEN
                    l_sql_stmt := l_sql_stmt || ' AND glc.segment11 = temp.segment11 '  ;
                    l_alt_sql_stmt := l_alt_sql_stmt || ' AND glc.segment11 = temp.alt_segment11 '  ;
                WHEN 'SEGMENT12' THEN
                    l_sql_stmt := l_sql_stmt || ' AND glc.segment12 = temp.segment12 '  ;
                    l_alt_sql_stmt := l_alt_sql_stmt || ' AND glc.segment12 = temp.alt_segment12 '  ;
                WHEN 'SEGMENT13' THEN
                    l_sql_stmt := l_sql_stmt || ' AND glc.segment13 = temp.segment13 '  ;
                    l_alt_sql_stmt := l_alt_sql_stmt || ' AND glc.segment13 = temp.alt_segment13 '  ;
                WHEN 'SEGMENT14' THEN
                    l_sql_stmt := l_sql_stmt || ' AND glc.segment14 = temp.segment14 '  ;
                    l_alt_sql_stmt := l_alt_sql_stmt || ' AND glc.segment14 = temp.alt_segment14 '  ;
                WHEN 'SEGMENT15' THEN
                    l_sql_stmt := l_sql_stmt || ' AND glc.segment15 = temp.segment15 '  ;
                    l_alt_sql_stmt := l_alt_sql_stmt || ' AND glc.segment15 = temp.alt_segment15 '  ;
                WHEN 'SEGMENT16' THEN
                    l_sql_stmt := l_sql_stmt || ' AND glc.segment16 = temp.segment16 '  ;
                    l_alt_sql_stmt := l_alt_sql_stmt || ' AND glc.segment16 = temp.alt_segment16 '  ;
                WHEN 'SEGMENT17' THEN
                    l_sql_stmt := l_sql_stmt || ' AND glc.segment17 = temp.segment17 '  ;
                    l_alt_sql_stmt := l_alt_sql_stmt || ' AND glc.segment17 = temp.alt_segment17 '  ;
                WHEN 'SEGMENT18' THEN
                    l_sql_stmt := l_sql_stmt || ' AND glc.segment18 = temp.segment18 '  ;
                    l_alt_sql_stmt := l_alt_sql_stmt || ' AND glc.segment18 = temp.alt_segment18 '  ;
                WHEN 'SEGMENT19' THEN
                    l_sql_stmt := l_sql_stmt || ' AND glc.segment19 = temp.segment19 '  ;
                    l_alt_sql_stmt := l_alt_sql_stmt || ' AND glc.segment19 = temp.alt_segment19 '  ;
                WHEN 'SEGMENT20' THEN
                    l_sql_stmt := l_sql_stmt || ' AND glc.segment20 = temp.segment20 '  ;
                    l_alt_sql_stmt := l_alt_sql_stmt || ' AND glc.segment20 = temp.alt_segment20 '  ;
                WHEN 'SEGMENT21' THEN
                    l_sql_stmt := l_sql_stmt || ' AND glc.segment21 = temp.segment21 '  ;
                    l_alt_sql_stmt := l_alt_sql_stmt || ' AND glc.segment21 = temp.alt_segment21 '  ;
                WHEN 'SEGMENT22' THEN
                    l_sql_stmt := l_sql_stmt || ' AND glc.segment22 = temp.segment22 '  ;
                    l_alt_sql_stmt := l_alt_sql_stmt || ' AND glc.segment22 = temp.alt_segment22 '  ;
                WHEN 'SEGMENT23' THEN
                    l_sql_stmt := l_sql_stmt || ' AND glc.segment23 = temp.segment23 '  ;
                    l_alt_sql_stmt := l_alt_sql_stmt || ' AND glc.segment23 = temp.alt_segment23 '  ;
                WHEN 'SEGMENT24' THEN
                    l_sql_stmt := l_sql_stmt || ' AND glc.segment24 = temp.segment24 '  ;
                    l_alt_sql_stmt := l_alt_sql_stmt || ' AND glc.segment24 = temp.alt_segment24 '  ;
                WHEN 'SEGMENT25' THEN
                    l_sql_stmt := l_sql_stmt || ' AND glc.segment25 = temp.segment25 '  ;
                    l_alt_sql_stmt := l_alt_sql_stmt || ' AND glc.segment25 = temp.alt_segment25 '  ;
                WHEN 'SEGMENT26' THEN
                    l_sql_stmt := l_sql_stmt || ' AND glc.segment26 = temp.segment26 '  ;
                    l_alt_sql_stmt := l_alt_sql_stmt || ' AND glc.segment26 = temp.alt_segment26 '  ;
                WHEN 'SEGMENT27' THEN
                    l_sql_stmt := l_sql_stmt || ' AND glc.segment27 = temp.segment27 '  ;
                    l_alt_sql_stmt := l_alt_sql_stmt || ' AND glc.segment27 = temp.alt_segment27 '  ;
                WHEN 'SEGMENT28' THEN
                    l_sql_stmt := l_sql_stmt || ' AND glc.segment28 = temp.segment28 '  ;
                    l_alt_sql_stmt := l_alt_sql_stmt || ' AND glc.segment28 = temp.alt_segment28 '  ;
                WHEN 'SEGMENT29' THEN
                    l_sql_stmt := l_sql_stmt || ' AND glc.segment29 = temp.segment29 '  ;
                    l_alt_sql_stmt := l_alt_sql_stmt || ' AND glc.segment29 = temp.alt_segment29 '  ;
                WHEN 'SEGMENT30' THEN
                    l_sql_stmt := l_sql_stmt || ' AND glc.segment30 = temp.segment30 '  ;
                    l_alt_sql_stmt := l_alt_sql_stmt || ' AND glc.segment30 = temp.alt_segment30 '  ;

                ELSE null;

              END CASE;

           END IF;
    --
    END LOOP;

    l_upd_stmt := 'UPDATE xla_ae_lines_gt temp
                      SET code_combination_id =
                             CASE
                             WHEN temp.ccid_coa_id = :1
                              AND temp.code_combination_status_code = :2
                              AND temp.balance_type_code <> ''X''
                             THEN
                                 (SELECT glc.code_combination_id
                                    FROM gl_code_combinations glc
                                   WHERE glc.chart_of_accounts_id  = temp.ccid_coa_id
                                     AND temp.ccid_coa_id          = :3
                                     AND glc.template_id           IS NULL
                                     ' || l_sql_stmt || ' )
                              ELSE
                                   code_combination_id
                              END
                         ,code_combination_status_code =
                             CASE
                             WHEN temp.ccid_coa_id = :4
                              AND temp.code_combination_status_code = :5
                              AND temp.balance_type_code <> ''X''
                             THEN :6
                             ELSE
                                  code_combination_status_code
                              END
                         ,alt_code_combination_id =
                             CASE
                             WHEN temp.ccid_coa_id = :7
                              AND temp.alt_ccid_status_code = :8
                              AND temp.balance_type_code <> ''X''
                             THEN
                                 (SELECT glc.code_combination_id
                                    FROM gl_code_combinations glc
                                   WHERE glc.chart_of_accounts_id  = temp.ccid_coa_id
                                     AND temp.ccid_coa_id          = :9
                                     AND glc.template_id           IS NULL
                                  ' || l_alt_sql_stmt || ' )
                             ELSE
                                  alt_code_combination_id
                              END
                         ,alt_ccid_status_code =
                             CASE
                             WHEN temp.ccid_coa_id = :10
                              AND temp.alt_ccid_status_code = :11
                              AND temp.balance_type_code <> ''X''
                             THEN :12
                             ELSE
                                alt_ccid_status_code
                             END
                    WHERE temp.ccid_coa_id = :13
                      AND temp.balance_type_code <> ''X''
                      AND
                         (temp.code_combination_status_code = :14
                       OR temp.alt_ccid_status_code   = :15) ';

    --
    --============================
    -- execute Dynamic SQL
    --============================

    IF (C_LEVEL_STATEMENT >= g_log_level) THEN

/*
 * Fix bug 4388150 - the l_seq_stmt and l_alt_sql_stmt are too big for the
 * fnd_log
          trace
            (p_msg      => '>> EXECUTE Dynamic SQL = '||l_sql_stmt
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);

          trace
            (p_msg      => '>> EXECUTE Dynamic SQL = '||l_alt_sql_stmt
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
*/

          trace
            (p_msg      => 'target_coa = '||g_array_cache_target_coa(Idx)
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);

          dump_text(p_text => l_upd_stmt);

    END IF;


    EXECUTE IMMEDIATE l_upd_stmt USING g_array_cache_target_coa(Idx)  --  1
                                      ,C_PROCESSING
                                      ,g_array_cache_target_coa(Idx)
                                      ,g_array_cache_target_coa(Idx)
                                      ,C_PROCESSING                   --  5
                                      ,C_CREATED
                                      ,g_array_cache_target_coa(Idx)
                                      ,C_PROCESSING
                                      ,g_array_cache_target_coa(Idx)
                                      ,g_array_cache_target_coa(Idx)  -- 10
                                      ,C_PROCESSING
                                      ,C_CREATED
                                      ,g_array_cache_target_coa(Idx)
                                      ,C_PROCESSING
                                      ,C_PROCESSING;                  -- 15

    l_rowcount := SQL%ROWCOUNT;
    l_count := l_count + l_rowcount;

    IF (C_LEVEL_STATEMENT >= g_log_level) THEN

          trace
            (p_msg      => '# rows updated (ccid + alt ccid) = '||l_rowcount
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
    END IF;


    END IF;
  END LOOP;
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
        trace
           (p_msg      => 'return value. = '||l_count
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
        trace
           (p_msg      => 'END of create_ccid'
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
END IF;
RETURN l_count;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
       trace
           (p_msg      => 'Error. = '||sqlerrm
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
  END IF;
  RAISE;
WHEN OTHERS  THEN
   IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
       trace
           (p_msg      => 'Error. = '||sqlerrm
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
   END IF;
   xla_exceptions_pkg.raise_message
           (p_location => 'xla_ae_code_combination_pkg.create_ccid');
END create_ccid;

/*---------------------------------------------------------------+
|                                                                |
| Private function                                               |
|                                                                |
|     create_new_ccid                                            |
|                                                                |
| create new accounting ccids and new ALT ccids. It returns the  |
| number of rows updated                                         |
|                                                                |
+---------------------------------------------------------------*/

FUNCTION  create_new_ccid
RETURN NUMBER
IS
l_log_module         VARCHAR2(240);
l_rowcount            NUMBER;
l_count               NUMBER;
BEGIN
--
IF g_log_enabled THEN
       l_log_module := C_DEFAULT_MODULE||'.create_new_ccid';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of create_new_ccid'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

l_rowcount := 0;
l_count    := 0;
g_error_exists := FALSE;

UPDATE xla_ae_lines_gt temp
   SET code_combination_id =
          CASE
          WHEN temp.code_combination_id           IS NULL
           AND temp.balance_type_code             <> 'X'
          THEN xla_ae_code_combination_pkg.GetCcid(
                  temp.segment1
                 ,temp.segment2
                 ,temp.segment3
                 ,temp.segment4
                 ,temp.segment5
                 ,temp.segment6
                 ,temp.segment7
                 ,temp.segment8
                 ,temp.segment9
                 ,temp.segment10
                 ,temp.segment11
                 ,temp.segment12
                 ,temp.segment13
                 ,temp.segment14
                 ,temp.segment15
                 ,temp.segment16
                 ,temp.segment17
                 ,temp.segment18
                 ,temp.segment19
                 ,temp.segment20
                 ,temp.segment21
                 ,temp.segment22
                 ,temp.segment23
                 ,temp.segment24
                 ,temp.segment25
                 ,temp.segment26
                 ,temp.segment27
                 ,temp.segment28
                 ,temp.segment29
                 ,temp.segment30
                 ,temp.ccid_coa_id
                 )
          ELSE code_combination_id
           END

      ,code_combination_status_code =
          CASE
          WHEN temp.code_combination_id           IS NULL
           AND temp.balance_type_code             <> 'X'
          THEN C_CREATED
          ELSE code_combination_status_code
           END

      ,alt_code_combination_id =
          CASE
          WHEN temp.alt_code_combination_id  IS NULL
           AND temp.balance_type_code        <> 'X'
           AND temp.gain_or_loss_flag        =  'Y'
          THEN xla_ae_code_combination_pkg.GetCcid(
                  temp.alt_segment1
                 ,temp.alt_segment2
                 ,temp.alt_segment3
                 ,temp.alt_segment4
                 ,temp.alt_segment5
                 ,temp.alt_segment6
                 ,temp.alt_segment7
                 ,temp.alt_segment8
                 ,temp.alt_segment9
                 ,temp.alt_segment10
                 ,temp.alt_segment11
                 ,temp.alt_segment12
                 ,temp.alt_segment13
                 ,temp.alt_segment14
                 ,temp.alt_segment15
                 ,temp.alt_segment16
                 ,temp.alt_segment17
                 ,temp.alt_segment18
                 ,temp.alt_segment19
                 ,temp.alt_segment20
                 ,temp.alt_segment21
                 ,temp.alt_segment22
                 ,temp.alt_segment23
                 ,temp.alt_segment24
                 ,temp.alt_segment25
                 ,temp.alt_segment26
                 ,temp.alt_segment27
                 ,temp.alt_segment28
                 ,temp.alt_segment29
                 ,temp.alt_segment30
                 ,temp.ccid_coa_id
                 )
          ELSE alt_code_combination_id
           END
      ,alt_ccid_status_code =
          CASE
          WHEN temp.alt_code_combination_id  IS NULL
           AND temp.balance_type_code        <> 'X'
           AND temp.gain_or_loss_flag        =  'Y'
          THEN C_CREATED
          ELSE alt_ccid_status_code
           END
 WHERE temp.balance_type_code             <> 'X'
   AND (
         (temp.code_combination_id           IS NULL)
     OR
         (temp.alt_code_combination_id       IS NULL
     AND  temp.gain_or_loss_flag             =  'Y')
       );

l_rowcount := SQL%ROWCOUNT;
l_count := l_count + l_rowcount;

IF (C_LEVEL_STATEMENT >= g_log_level) THEN

      trace
         (p_msg      => '# rows updated (ccid + ALT ccid)='||l_rowcount
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

END IF;
--
-- get event error messages
--
--IF g_error_exists THEN get_ccid_errors; END IF;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

        trace
           (p_msg      => 'return value. = '||to_char(l_count)
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);

        trace
           (p_msg      => 'END of create_new_ccid'
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);

END IF;
--
RETURN l_count;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
       trace
           (p_msg      => 'Error. = '||sqlerrm
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
  END IF;
  RAISE;
WHEN OTHERS  THEN
  IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
       trace
           (p_msg      => 'Error. = '||sqlerrm
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
   END IF;
   xla_exceptions_pkg.raise_message
           (p_location => 'xla_ae_code_combination_pkg.create_new_ccid');
END create_new_ccid;

/*---------------------------------------------------------------+
|                                                                |
| Private function                                               |
|                                                                |
|     map_ccid                                                   |
|                                                                |
| converts the transaction CCIDs in accounting ledger's COA      |
|                                                                |
+---------------------------------------------------------------*/

FUNCTION  map_ccid(
    p_gl_coa_mapping_name IN VARCHAR2
  , p_gl_coa_mapping_id   IN NUMBER
)
RETURN NUMBER
IS
--
l_message                       VARCHAR2(2000);
l_count                         NUMBER;
l_rowcount                      NUMBER;
l_log_module                    VARCHAR2(240);
l_ConcatKey                     VARCHAR2(4000);

TYPE t_array_num15  IS TABLE OF NUMBER(15)   INDEX BY BINARY_INTEGER;
TYPE t_array_vc30   IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;

l_array_header_id               t_array_num15;
l_array_temp_line_num           t_array_num15;
l_array_ledger_id               t_array_num15;
l_array_coa_mapping_id          t_array_num15;
l_array_gl_map_status           t_array_vc30;
l_array_processing_status_code  t_array_vc30;
l_array_to_segment_code         t_array_vc30;
l_array_ccid                    t_array_num15;
l_array_segment_value           t_array_vc30;

l_array_alt_header_id           t_array_num15;
l_array_alt_temp_line_num       t_array_num15;
l_array_alt_ledger_id           t_array_num15;
l_array_alt_coa_mapping_id      t_array_num15;
l_array_alt_gl_map_status       t_array_vc30;
l_array_alt_proc_status_code    t_array_vc30;
l_array_alt_to_segment_code     t_array_vc30;
l_array_alt_ccid                t_array_num15;
l_array_alt_segment_value       t_array_vc30;

-- bug 6743896
l_coa_mapping_id                     NUMBER;
l_from_coa_id                        NUMBER;
l_to_coa_id                          NUMBER;
l_start_date_active                  DATE;
l_end_date_active                    DATE;
GL_DISABLED_MAPPING                 Exception;
-- end bug 6743896

--
BEGIN
IF g_log_enabled THEN
       l_log_module := C_DEFAULT_MODULE||'.map_ccid';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of map_ccid'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;

l_count    := 0;
l_rowcount := 0;

DELETE FROM gl_accts_map_int_gt; -- bug 4564062

INSERT INTO gl_accts_map_int_gt
     (
       from_ccid
     , coa_mapping_id
     )
SELECT   code_combination_id
       , sl_coa_mapping_id
  FROM xla_transaction_accts_gt
 WHERE code_combination_id          IS NOT NULL
   AND processing_status_code       IN (C_MAP_CCID , C_MAP_SEGMENT)
   AND sl_coa_mapping_id            = p_gl_coa_mapping_id
 GROUP BY code_combination_id, sl_coa_mapping_id
   ;

l_rowcount:= SQL%ROWCOUNT;
l_count   := l_count + l_rowcount;

IF (C_LEVEL_STATEMENT >= g_log_level) THEN
   trace
   (p_msg      => '# rows inserted into gl_accts_map_int_gt(ccid) = '||to_char(l_rowcount)
   ,p_level    => C_LEVEL_STATEMENT
   ,p_module   => l_log_module);
END IF;

IF l_rowcount > 0 THEN

     IF (C_LEVEL_STATEMENT >= g_log_level) THEN
       trace
           (p_msg      => '-> CALL gl_accounts_map_grp API'
           ,p_level    => C_LEVEL_STATEMENT
           ,p_module   => l_log_module);
     END IF;

    -- call GL_ACCOUNTS_MAP_GRP to map accounts
    GL_ACCOUNTS_MAP_GRP.MAP(
               mapping_name =>  p_gl_coa_mapping_name
             , create_ccid  => ( NVL(g_cache_dynamic_inserts(p_gl_coa_mapping_id),'N') ='Y' )
             , debug        => g_log_enabled
              );

    IF (C_LEVEL_STATEMENT >= g_log_level) THEN
       trace
           (p_msg      => 'SQL - convert the transaction ccids'
           ,p_level    => C_LEVEL_STATEMENT
           ,p_module   => l_log_module);
    END IF;

     --
     -- get transaction ccid
     --
     UPDATE /*+ dynamic_sampling(1) */ xla_ae_lines_gt temp
          SET ( temp.code_combination_id
               ,temp.segment1
               ,temp.segment2
               ,temp.segment3
               ,temp.segment4
               ,temp.segment5
               ,temp.segment6
               ,temp.segment7
               ,temp.segment8
               ,temp.segment9
               ,temp.segment10
               ,temp.segment11
               ,temp.segment12
               ,temp.segment13
               ,temp.segment14
               ,temp.segment15
               ,temp.segment16
               ,temp.segment17
               ,temp.segment18
               ,temp.segment19
               ,temp.segment20
               ,temp.segment21
               ,temp.segment22
               ,temp.segment23
               ,temp.segment24
               ,temp.segment25
               ,temp.segment26
               ,temp.segment27
               ,temp.segment28
               ,temp.segment29
               ,temp.segment30
               ,temp.code_combination_status_code) =
                (
                SELECT /*+ INDEX (XTA XLA_TRANSACTION_ACCTS_GT_N1) LEADING (XTA) */
		       DISTINCT
                       DECODE(gami.error_code, NULL, gami.to_ccid, -1)
                     , nvl(temp.segment1 , gami.to_segment1)
                     , nvl(temp.segment2 , gami.to_segment2)
                     , nvl(temp.segment3 , gami.to_segment3)
                     , nvl(temp.segment4 , gami.to_segment4)
                     , nvl(temp.segment5 , gami.to_segment5)
                     , nvl(temp.segment6 , gami.to_segment6)
                     , nvl(temp.segment7 , gami.to_segment7)
                     , nvl(temp.segment8 , gami.to_segment8)
                     , nvl(temp.segment9 , gami.to_segment9)
                     , nvl(temp.segment10, gami.to_segment10)
                     , nvl(temp.segment11, gami.to_segment11)
                     , nvl(temp.segment12, gami.to_segment12)
                     , nvl(temp.segment13, gami.to_segment13)
                     , nvl(temp.segment14, gami.to_segment14)
                     , nvl(temp.segment15, gami.to_segment15)
                     , nvl(temp.segment16, gami.to_segment16)
                     , nvl(temp.segment17, gami.to_segment17)
                     , nvl(temp.segment18, gami.to_segment18)
                     , nvl(temp.segment19, gami.to_segment19)
                     , nvl(temp.segment20, gami.to_segment20)
                     , nvl(temp.segment21, gami.to_segment21)
                     , nvl(temp.segment22, gami.to_segment22)
                     , nvl(temp.segment23, gami.to_segment23)
                     , nvl(temp.segment24, gami.to_segment24)
                     , nvl(temp.segment25, gami.to_segment25)
                     , nvl(temp.segment26, gami.to_segment26)
                     , nvl(temp.segment27, gami.to_segment27)
                     , nvl(temp.segment28, gami.to_segment28)
                     , nvl(temp.segment29, gami.to_segment29)
                     , nvl(temp.segment30, gami.to_segment30)
                     , CASE WHEN gami.error_code IS NULL
                         THEN CASE temp.code_combination_status_code
                                   WHEN C_INVALID    THEN C_CREATED
                                   WHEN C_PROCESSING THEN C_NOT_PROCESSED
                                   ELSE temp.code_combination_status_code
                                END
                          ELSE C_INVALID
                       END
                  FROM gl_accts_map_int_gt  gami
                     , xla_transaction_accts_gt   xta
                  WHERE xta.ae_header_id           = temp.ae_header_id
                    AND xta.temp_line_num          = temp.temp_line_num
                    AND xta.ledger_id              = temp.ledger_id
                    AND xta.sl_coa_mapping_id      = temp.sl_coa_mapping_id
                    AND gami.from_ccid             = xta.code_combination_id
                    AND gami.coa_mapping_id        = xta.sl_coa_mapping_id
                    AND xta.processing_status_code = 'MAP_CCID'
                    AND xta.side_code              IN ('ALL','CREDIT','NA')
                    AND xta.sl_coa_mapping_id      = p_gl_coa_mapping_id
                    AND temp.code_combination_id   IS NULL
                   )
          WHERE temp.code_combination_id IS NULL
            AND temp.sl_coa_mapping_id = p_gl_coa_mapping_id
            AND temp.balance_type_code  <> 'X'
            AND EXISTS (SELECT /*+ INDEX (t XLA_TRANSACTION_ACCTS_GT_N1) */ 'x'  --added bug7673701
                          FROM xla_transaction_accts_gt  t
                         WHERE t.ae_header_id           = temp.ae_header_id
                           AND t.temp_line_num          = temp.temp_line_num
                           AND t.ledger_id              = temp.ledger_id
                           AND t.sl_coa_mapping_id      = temp.sl_coa_mapping_id
                           AND t.processing_status_code = 'MAP_CCID'
                           AND t.sl_coa_mapping_id      = p_gl_coa_mapping_id
                         )
                         ;

      l_rowcount:= SQL%ROWCOUNT;
      l_count := l_count + l_rowcount;

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
          trace
              (p_msg      => '# of rows updated into xla_ae_lines_gt(ccid) = '||to_char(l_rowcount)
              ,p_level    => C_LEVEL_STATEMENT
              ,p_module   => l_log_module);

      END IF;


     UPDATE /*+ dynamic_sampling(1) */ xla_ae_lines_gt temp
          SET ( temp.alt_code_combination_id
               ,temp.alt_segment1
               ,temp.alt_segment2
               ,temp.alt_segment3
               ,temp.alt_segment4
               ,temp.alt_segment5
               ,temp.alt_segment6
               ,temp.alt_segment7
               ,temp.alt_segment8
               ,temp.alt_segment9
               ,temp.alt_segment10
               ,temp.alt_segment11
               ,temp.alt_segment12
               ,temp.alt_segment13
               ,temp.alt_segment14
               ,temp.alt_segment15
               ,temp.alt_segment16
               ,temp.alt_segment17
               ,temp.alt_segment18
               ,temp.alt_segment19
               ,temp.alt_segment20
               ,temp.alt_segment21
               ,temp.alt_segment22
               ,temp.alt_segment23
               ,temp.alt_segment24
               ,temp.alt_segment25
               ,temp.alt_segment26
               ,temp.alt_segment27
               ,temp.alt_segment28
               ,temp.alt_segment29
               ,temp.alt_segment30
               ,temp.alt_ccid_status_code) =
                (
                SELECT /*+ INDEX (XTA XLA_TRANSACTION_ACCTS_GT_N1) LEADING (XTA) */
		       DISTINCT
                       DECODE(gami.error_code, NULL, gami.to_ccid, -1)
                     , nvl(temp.alt_segment1 , gami.to_segment1)
                     , nvl(temp.alt_segment2 , gami.to_segment2)
                     , nvl(temp.alt_segment3 , gami.to_segment3)
                     , nvl(temp.alt_segment4 , gami.to_segment4)
                     , nvl(temp.alt_segment5 , gami.to_segment5)
                     , nvl(temp.alt_segment6 , gami.to_segment6)
                     , nvl(temp.alt_segment7 , gami.to_segment7)
                     , nvl(temp.alt_segment8 , gami.to_segment8)
                     , nvl(temp.alt_segment9 , gami.to_segment9)
                     , nvl(temp.alt_segment10, gami.to_segment10)
                     , nvl(temp.alt_segment11, gami.to_segment11)
                     , nvl(temp.alt_segment12, gami.to_segment12)
                     , nvl(temp.alt_segment13, gami.to_segment13)
                     , nvl(temp.alt_segment14, gami.to_segment14)
                     , nvl(temp.alt_segment15, gami.to_segment15)
                     , nvl(temp.alt_segment16, gami.to_segment16)
                     , nvl(temp.alt_segment17, gami.to_segment17)
                     , nvl(temp.alt_segment18, gami.to_segment18)
                     , nvl(temp.alt_segment19, gami.to_segment19)
                     , nvl(temp.alt_segment20, gami.to_segment20)
                     , nvl(temp.alt_segment21, gami.to_segment21)
                     , nvl(temp.alt_segment22, gami.to_segment22)
                     , nvl(temp.alt_segment23, gami.to_segment23)
                     , nvl(temp.alt_segment24, gami.to_segment24)
                     , nvl(temp.alt_segment25, gami.to_segment25)
                     , nvl(temp.alt_segment26, gami.to_segment26)
                     , nvl(temp.alt_segment27, gami.to_segment27)
                     , nvl(temp.alt_segment28, gami.to_segment28)
                     , nvl(temp.alt_segment29, gami.to_segment29)
                     , nvl(temp.alt_segment30, gami.to_segment30)
                     , CASE WHEN gami.error_code IS NULL
                          THEN CASE temp.alt_ccid_status_code
                                    WHEN C_INVALID    THEN C_CREATED
                                    WHEN C_PROCESSING THEN C_NOT_PROCESSED
                                    ELSE temp.alt_ccid_status_code
                                 END
                          ELSE C_INVALID
                       END
                  FROM gl_accts_map_int_gt  gami
                     , xla_transaction_accts_gt   xta
                  WHERE xta.ae_header_id           = temp.ae_header_id
                    AND xta.temp_line_num          = temp.temp_line_num
                    AND xta.ledger_id              = temp.ledger_id
                    AND xta.sl_coa_mapping_id      = temp.sl_coa_mapping_id
                    AND gami.from_ccid             = xta.code_combination_id
                    AND gami.coa_mapping_id        = xta.sl_coa_mapping_id
                    AND xta.processing_status_code = 'MAP_CCID'
                    AND xta.side_code              IN ('ALL','DEBIT')
                    AND xta.sl_coa_mapping_id      = p_gl_coa_mapping_id
                    AND temp.alt_code_combination_id  IS NULL
                   )
          WHERE temp.alt_code_combination_id IS NULL
            AND temp.sl_coa_mapping_id = p_gl_coa_mapping_id
            AND temp.balance_type_code  <> 'X'
            AND EXISTS (SELECT /*+ INDEX (t XLA_TRANSACTION_ACCTS_GT_N1) */ 'x'  --added bug7673701
                          FROM xla_transaction_accts_gt  t
                         WHERE t.ae_header_id           = temp.ae_header_id
                           AND t.temp_line_num          = temp.temp_line_num
                           AND t.ledger_id              = temp.ledger_id
                           AND t.sl_coa_mapping_id      = temp.sl_coa_mapping_id
                           AND t.processing_status_code = 'MAP_CCID'
                           AND t.sl_coa_mapping_id      = p_gl_coa_mapping_id
                         )
                         ;

      l_rowcount:= SQL%ROWCOUNT;
      l_count := l_count + l_rowcount;

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
          trace
              (p_msg      => '# of rows updated into xla_ae_lines_gt(ALT ccid) = '||to_char(l_rowcount)
              ,p_level    => C_LEVEL_STATEMENT
              ,p_module   => l_log_module);

      END IF;

   --
   --  get accounting segment value from converted ccid
   --
   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
       trace
           (p_msg      => 'SQL - override segments'
           ,p_level    => C_LEVEL_STATEMENT
           ,p_module   => l_log_module);
   END IF;

   --
   -- Retrieve to_segment information
   --
SELECT	  coa_mapping_id,
    		from_coa_id,
    		to_coa_id,
    		start_date_active,
    		end_date_active

INTO            l_coa_mapping_id,
    		l_from_coa_id,
    		l_to_coa_id,
    		l_start_date_active,
    		l_end_date_active
FROM	        gl_coa_mappings
WHERE	        name = p_gl_coa_mapping_name
AND             coa_mapping_id=p_gl_coa_mapping_id;

IF (l_start_date_active IS NOT NULL AND l_start_date_active > SYSDATE) OR
          (l_end_date_active IS NOT NULL AND l_end_date_active < SYSDATE) THEN
          raise GL_DISABLED_MAPPING;
END IF;


/* Reverting changes as per bug 8477316
SELECT DISTINCT
          xta.ae_header_id                                   ae_header_id
        , xta.temp_line_num                                  temp_line_num
        , xta.ledger_id                                      ledger_id
        , xta.sl_coa_mapping_id                              sl_coa_mapping_id
        , DECODE (gami.code_combination_id,NULL,C_INVALID,C_CREATED) gl_map_status
        , xta.processing_status_code                         processing_status_code
        , xta.to_segment_code                                to_segment_code
        , NVL(gami.code_combination_id,-1)                     code_combination_id
        , CASE xta.from_segment_code
             WHEN 'SEGMENT1'  THEN gami.segment1
             WHEN 'SEGMENT2'  THEN gami.segment2
             WHEN 'SEGMENT3'  THEN gami.segment3
             WHEN 'SEGMENT4'  THEN gami.segment4
             WHEN 'SEGMENT5'  THEN gami.segment5
             WHEN 'SEGMENT6'  THEN gami.segment6
             WHEN 'SEGMENT7'  THEN gami.segment7
             WHEN 'SEGMENT8'  THEN gami.segment8
             WHEN 'SEGMENT9'  THEN gami.segment9
             WHEN 'SEGMENT10' THEN gami.segment10
             WHEN 'SEGMENT11' THEN gami.segment11
             WHEN 'SEGMENT12' THEN gami.segment12
             WHEN 'SEGMENT13' THEN gami.segment13
             WHEN 'SEGMENT14' THEN gami.segment14
             WHEN 'SEGMENT15' THEN gami.segment15
             WHEN 'SEGMENT16' THEN gami.segment16
             WHEN 'SEGMENT17' THEN gami.segment17
             WHEN 'SEGMENT18' THEN gami.segment18
             WHEN 'SEGMENT19' THEN gami.segment19
             WHEN 'SEGMENT20' THEN gami.segment20
             WHEN 'SEGMENT21' THEN gami.segment21
             WHEN 'SEGMENT22' THEN gami.segment22
             WHEN 'SEGMENT23' THEN gami.segment23
             WHEN 'SEGMENT24' THEN gami.segment24
             WHEN 'SEGMENT25' THEN gami.segment25
             WHEN 'SEGMENT26' THEN gami.segment26
             WHEN 'SEGMENT27' THEN gami.segment27
             WHEN 'SEGMENT28' THEN gami.segment28
             WHEN 'SEGMENT29' THEN gami.segment29
             WHEN 'SEGMENT30' THEN gami.segment30
          END                                                segment_value
    BULK  COLLECT INTO
          l_array_header_id
        , l_array_temp_line_num
        , l_array_ledger_id
        , l_array_coa_mapping_id
        , l_array_gl_map_status
        , l_array_processing_status_code
        , l_array_to_segment_code
        , l_array_ccid
        , l_array_segment_value
    FROM  gl_code_combinations  gami
        , xla_transaction_accts_gt   xta
   WHERE gami.code_combination_id        = xta.code_combination_id
     AND gami.chart_of_accounts_id       = l_from_coa_id
     AND xta.code_combination_id    IS NOT NULL
     AND xta.from_segment_code      IS NOT NULL
     AND xta.to_segment_code        IS NOT NULL
     AND xta.processing_status_code = 'MAP_SEGMENT'
     AND xta.sl_coa_mapping_id      = p_gl_coa_mapping_id
     AND xta.side_code IN           ('ALL','CREDIT','NA');
-- end bug 6743896 */

 -- Reverting code changes  for bug 8512854
   SELECT DISTINCT
          xta.ae_header_id                                   ae_header_id
        , xta.temp_line_num                                  temp_line_num
        , xta.ledger_id                                      ledger_id
        , xta.sl_coa_mapping_id                              sl_coa_mapping_id
        , DECODE (gami.error_code ,NULL,C_CREATED,C_INVALID) gl_map_status
        , xta.processing_status_code                         processing_status_code
        , xta.to_segment_code                                to_segment_code
        , DECODE(gami.error_code ,NULL,gami.to_ccid,-1)      code_combination_id
        , CASE xta.from_segment_code
             WHEN 'SEGMENT1'  THEN gami.to_segment1
             WHEN 'SEGMENT2'  THEN gami.to_segment2
             WHEN 'SEGMENT3'  THEN gami.to_segment3
             WHEN 'SEGMENT4'  THEN gami.to_segment4
             WHEN 'SEGMENT5'  THEN gami.to_segment5
             WHEN 'SEGMENT6'  THEN gami.to_segment6
             WHEN 'SEGMENT7'  THEN gami.to_segment7
             WHEN 'SEGMENT8'  THEN gami.to_segment8
             WHEN 'SEGMENT9'  THEN gami.to_segment9
             WHEN 'SEGMENT10' THEN gami.to_segment10
             WHEN 'SEGMENT11' THEN gami.to_segment11
             WHEN 'SEGMENT12' THEN gami.to_segment12
             WHEN 'SEGMENT13' THEN gami.to_segment13
             WHEN 'SEGMENT14' THEN gami.to_segment14
             WHEN 'SEGMENT15' THEN gami.to_segment15
             WHEN 'SEGMENT16' THEN gami.to_segment16
             WHEN 'SEGMENT17' THEN gami.to_segment17
             WHEN 'SEGMENT18' THEN gami.to_segment18
             WHEN 'SEGMENT19' THEN gami.to_segment19
             WHEN 'SEGMENT20' THEN gami.to_segment20
             WHEN 'SEGMENT21' THEN gami.to_segment21
             WHEN 'SEGMENT22' THEN gami.to_segment22
             WHEN 'SEGMENT23' THEN gami.to_segment23
             WHEN 'SEGMENT24' THEN gami.to_segment24
             WHEN 'SEGMENT25' THEN gami.to_segment25
             WHEN 'SEGMENT26' THEN gami.to_segment26
             WHEN 'SEGMENT27' THEN gami.to_segment27
             WHEN 'SEGMENT28' THEN gami.to_segment28
             WHEN 'SEGMENT29' THEN gami.to_segment29
             WHEN 'SEGMENT30' THEN gami.to_segment30
          END                                                segment_value
    BULK  COLLECT INTO
          l_array_header_id
        , l_array_temp_line_num
        , l_array_ledger_id
        , l_array_coa_mapping_id
        , l_array_gl_map_status
        , l_array_processing_status_code
        , l_array_to_segment_code
        , l_array_ccid
        , l_array_segment_value
    FROM  gl_accts_map_int_gt  gami
        , xla_transaction_accts_gt   xta
   WHERE gami.from_ccid             = xta.code_combination_id
     AND gami.coa_mapping_id        = xta.sl_coa_mapping_id
     AND xta.code_combination_id    IS NOT NULL
     AND xta.from_segment_code      IS NOT NULL
     AND xta.to_segment_code        IS NOT NULL
     AND xta.processing_status_code = 'MAP_SEGMENT'
     AND xta.sl_coa_mapping_id      = p_gl_coa_mapping_id
     AND xta.side_code IN           ('ALL','CREDIT','NA');

-- end bug 8512854


  IF l_array_header_id.COUNT > 0 THEN

    FORALL i IN l_array_header_id.FIRST .. l_array_header_id.LAST

       UPDATE   xla_ae_lines_gt temp
          SET ( temp.code_combination_id
               ,temp.segment1
               ,temp.segment2
               ,temp.segment3
               ,temp.segment4
               ,temp.segment5
               ,temp.segment6
               ,temp.segment7
               ,temp.segment8
               ,temp.segment9
               ,temp.segment10
               ,temp.segment11
               ,temp.segment12
               ,temp.segment13
               ,temp.segment14
               ,temp.segment15
               ,temp.segment16
               ,temp.segment17
               ,temp.segment18
               ,temp.segment19
               ,temp.segment20
               ,temp.segment21
               ,temp.segment22
               ,temp.segment23
               ,temp.segment24
               ,temp.segment25
               ,temp.segment26
               ,temp.segment27
               ,temp.segment28
               ,temp.segment29
               ,temp.segment30
               ,temp.code_combination_status_code) =
              (
       SELECT   /*+ INDEX(SEG XLA_TRANSACTION_ACCTS_GT_N1) */ DISTINCT     --bug7673701
                DECODE(l_array_gl_map_status(i), C_INVALID, -1, temp.code_combination_id)
               , DECODE(seg.to_segment_code,'SEGMENT1' ,l_array_segment_value(i), temp.segment1)
               , DECODE(seg.to_segment_code,'SEGMENT2' ,l_array_segment_value(i), temp.segment2)
               , DECODE(seg.to_segment_code,'SEGMENT3' ,l_array_segment_value(i), temp.segment3)
               , DECODE(seg.to_segment_code,'SEGMENT4' ,l_array_segment_value(i), temp.segment4)
               , DECODE(seg.to_segment_code,'SEGMENT5' ,l_array_segment_value(i), temp.segment5)
               , DECODE(seg.to_segment_code,'SEGMENT6' ,l_array_segment_value(i), temp.segment6)
               , DECODE(seg.to_segment_code,'SEGMENT7' ,l_array_segment_value(i), temp.segment7)
               , DECODE(seg.to_segment_code,'SEGMENT8' ,l_array_segment_value(i), temp.segment8)
               , DECODE(seg.to_segment_code,'SEGMENT9' ,l_array_segment_value(i), temp.segment9)
               , DECODE(seg.to_segment_code,'SEGMENT10',l_array_segment_value(i), temp.segment10)
               , DECODE(seg.to_segment_code,'SEGMENT11',l_array_segment_value(i), temp.segment11)
               , DECODE(seg.to_segment_code,'SEGMENT12',l_array_segment_value(i), temp.segment12)
               , DECODE(seg.to_segment_code,'SEGMENT13',l_array_segment_value(i), temp.segment13)
               , DECODE(seg.to_segment_code,'SEGMENT14',l_array_segment_value(i), temp.segment14)
               , DECODE(seg.to_segment_code,'SEGMENT15',l_array_segment_value(i), temp.segment15)
               , DECODE(seg.to_segment_code,'SEGMENT16',l_array_segment_value(i), temp.segment16)
               , DECODE(seg.to_segment_code,'SEGMENT17',l_array_segment_value(i), temp.segment17)
               , DECODE(seg.to_segment_code,'SEGMENT18',l_array_segment_value(i), temp.segment18)
               , DECODE(seg.to_segment_code,'SEGMENT19',l_array_segment_value(i), temp.segment19)
               , DECODE(seg.to_segment_code,'SEGMENT20',l_array_segment_value(i), temp.segment20)
               , DECODE(seg.to_segment_code,'SEGMENT21',l_array_segment_value(i), temp.segment21)
               , DECODE(seg.to_segment_code,'SEGMENT22',l_array_segment_value(i), temp.segment22)
               , DECODE(seg.to_segment_code,'SEGMENT23',l_array_segment_value(i), temp.segment23)
               , DECODE(seg.to_segment_code,'SEGMENT24',l_array_segment_value(i), temp.segment24)
               , DECODE(seg.to_segment_code,'SEGMENT25',l_array_segment_value(i), temp.segment25)
               , DECODE(seg.to_segment_code,'SEGMENT26',l_array_segment_value(i), temp.segment26)
               , DECODE(seg.to_segment_code,'SEGMENT27',l_array_segment_value(i), temp.segment27)
               , DECODE(seg.to_segment_code,'SEGMENT28',l_array_segment_value(i), temp.segment28)
               , DECODE(seg.to_segment_code,'SEGMENT29',l_array_segment_value(i), temp.segment29)
               , DECODE(seg.to_segment_code,'SEGMENT30',l_array_segment_value(i), temp.segment30)
               , CASE l_array_gl_map_status(i)
                   WHEN C_INVALID THEN C_INVALID
                   ELSE CASE temp.code_combination_status_code
                           WHEN C_INVALID THEN C_PROCESSING
                           WHEN C_CREATED THEN C_NOT_PROCESSED
                           ELSE temp.code_combination_status_code
                        END
                 END
            FROM xla_transaction_accts_gt   seg
           WHERE seg.ae_header_id           = temp.ae_header_id
             AND seg.temp_line_num          = temp.temp_line_num
             AND seg.ledger_id              = temp.ledger_id
             AND seg.sl_coa_mapping_id      = temp.sl_coa_mapping_id
             AND seg.ae_header_id           = l_array_header_id(i)
             AND seg.temp_line_num          = l_array_temp_line_num(i)
             AND seg.ledger_id              = l_array_ledger_id(i)
             AND seg.sl_coa_mapping_id      = l_array_coa_mapping_id(i)
            AND seg.to_segment_code        = l_array_to_segment_code(i)     --added 6660472 suggested by Kaouther
             AND seg.processing_status_code = l_array_processing_status_code(i)--added for bug6314762 to avoid single row subquery returns more than one row error
             )
        WHERE  temp.balance_type_code             <> 'X'
          AND  EXISTS (SELECT /*+ INDEX(t XLA_TRANSACTION_ACCTS_GT_N1) */ 'x'      --bug7673701
                  FROM xla_transaction_accts_gt  t
                 WHERE t.ae_header_id           = temp.ae_header_id
		               AND t.temp_line_num          = temp.temp_line_num
		               AND t.ledger_id              = temp.ledger_id
		               AND t.sl_coa_mapping_id      = temp.sl_coa_mapping_id
                   AND t.processing_status_code = 'MAP_SEGMENT'
                   AND t.sl_coa_mapping_id      = p_gl_coa_mapping_id
                   AND t.ae_header_id           = l_array_header_id(i)
                   AND t.temp_line_num          = l_array_temp_line_num(i)
                   AND t.ledger_id              = l_array_ledger_id(i)
                   AND t.to_segment_code        = l_array_to_segment_code(i)  --added 6660472 suggested by Kaouther
                   AND t.sl_coa_mapping_id      = l_array_coa_mapping_id(i))

   ;
   END IF;  -- l_array_header_id.COUNT > 0

   l_rowcount:= SQL%ROWCOUNT;
   l_count := l_count + l_rowcount;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
          trace
              (p_msg      => '# of rows updated into xla_ae_lines_gt(ccid) = '||to_char(l_rowcount)
              ,p_level    => C_LEVEL_STATEMENT
              ,p_module   => l_log_module);

   END IF;

   --
   -- Retrieve to_segment information for alt ccid
   --
   SELECT  DISTINCT
           xta.ae_header_id                                   ae_header_id
         , xta.temp_line_num                                  temp_line_num
         , xta.ledger_id                                      ledger_id
         , xta.sl_coa_mapping_id                              sl_coa_mapping_id
         , DECODE (gami.error_code ,NULL,C_CREATED,C_INVALID) gl_map_status
         , xta.processing_status_code                         processing_status_code
         , xta.to_segment_code                                to_segment_code
         , DECODE(gami.error_code ,NULL,gami.to_ccid,-1)      code_combination_id
         , CASE xta.from_segment_code
            WHEN 'SEGMENT1'  THEN gami.to_segment1
            WHEN 'SEGMENT2'  THEN gami.to_segment2
            WHEN 'SEGMENT3'  THEN gami.to_segment3
            WHEN 'SEGMENT4'  THEN gami.to_segment4
            WHEN 'SEGMENT5'  THEN gami.to_segment5
            WHEN 'SEGMENT6'  THEN gami.to_segment6
            WHEN 'SEGMENT7'  THEN gami.to_segment7
            WHEN 'SEGMENT8'  THEN gami.to_segment8
            WHEN 'SEGMENT9'  THEN gami.to_segment9
            WHEN 'SEGMENT10' THEN gami.to_segment10
            WHEN 'SEGMENT11' THEN gami.to_segment11
            WHEN 'SEGMENT12' THEN gami.to_segment12
            WHEN 'SEGMENT13' THEN gami.to_segment13
            WHEN 'SEGMENT14' THEN gami.to_segment14
            WHEN 'SEGMENT15' THEN gami.to_segment15
            WHEN 'SEGMENT16' THEN gami.to_segment16
            WHEN 'SEGMENT17' THEN gami.to_segment17
            WHEN 'SEGMENT18' THEN gami.to_segment18
            WHEN 'SEGMENT19' THEN gami.to_segment19
            WHEN 'SEGMENT20' THEN gami.to_segment20
            WHEN 'SEGMENT21' THEN gami.to_segment21
            WHEN 'SEGMENT22' THEN gami.to_segment22
            WHEN 'SEGMENT23' THEN gami.to_segment23
            WHEN 'SEGMENT24' THEN gami.to_segment24
            WHEN 'SEGMENT25' THEN gami.to_segment25
            WHEN 'SEGMENT26' THEN gami.to_segment26
            WHEN 'SEGMENT27' THEN gami.to_segment27
            WHEN 'SEGMENT28' THEN gami.to_segment28
            WHEN 'SEGMENT29' THEN gami.to_segment29
            WHEN 'SEGMENT30' THEN gami.to_segment30
          END                                                 segment_value
    BULK  COLLECT INTO
          l_array_alt_header_id
        , l_array_alt_temp_line_num
        , l_array_alt_ledger_id
        , l_array_alt_coa_mapping_id
        , l_array_alt_gl_map_status
        , l_array_alt_proc_status_code
        , l_array_alt_to_segment_code
        , l_array_alt_ccid
        , l_array_alt_segment_value
    FROM  gl_accts_map_int_gt  gami
        , xla_transaction_accts_gt   xta
    WHERE gami.from_ccid             = xta.code_combination_id
      AND gami.coa_mapping_id        = xta.sl_coa_mapping_id
      AND xta.code_combination_id    IS NOT NULL
      AND xta.from_segment_code      IS NOT NULL
      AND xta.to_segment_code        IS NOT NULL
      AND xta.processing_status_code = 'MAP_SEGMENT'
      AND xta.sl_coa_mapping_id      = p_gl_coa_mapping_id
      AND xta.side_code IN           ('ALL','DEBIT');

   IF l_array_alt_header_id.COUNT > 0 THEN

      FORALL i IN l_array_alt_header_id.FIRST .. l_array_alt_header_id.LAST

         UPDATE xla_ae_lines_gt temp
                SET ( temp.alt_code_combination_id
                     ,temp.alt_segment1
                     ,temp.alt_segment2
                     ,temp.alt_segment3
                     ,temp.alt_segment4
                     ,temp.alt_segment5
                     ,temp.alt_segment6
                     ,temp.alt_segment7
                     ,temp.alt_segment8
                     ,temp.alt_segment9
                     ,temp.alt_segment10
                     ,temp.alt_segment11
                     ,temp.alt_segment12
                     ,temp.alt_segment13
                     ,temp.alt_segment14
                     ,temp.alt_segment15
                     ,temp.alt_segment16
                     ,temp.alt_segment17
                     ,temp.alt_segment18
                     ,temp.alt_segment19
                     ,temp.alt_segment20
                     ,temp.alt_segment21
                     ,temp.alt_segment22
                     ,temp.alt_segment23
                     ,temp.alt_segment24
                     ,temp.alt_segment25
                     ,temp.alt_segment26
                     ,temp.alt_segment27
                     ,temp.alt_segment28
                     ,temp.alt_segment29
                     ,temp.alt_segment30
                     ,temp.alt_ccid_status_code) =
                      (
                SELECT /*+ INDEX(SEG XLA_TRANSACTION_ACCTS_GT_N1) */ DISTINCT     --bug7673701
                         DECODE(l_array_alt_gl_map_status(i), C_INVALID, -1, temp.alt_code_combination_id)
                       , DECODE(seg.to_segment_code,'SEGMENT1' ,l_array_alt_segment_value(i), temp.alt_segment1)
                       , DECODE(seg.to_segment_code,'SEGMENT2' ,l_array_alt_segment_value(i), temp.alt_segment2)
                       , DECODE(seg.to_segment_code,'SEGMENT3' ,l_array_alt_segment_value(i), temp.alt_segment3)
                       , DECODE(seg.to_segment_code,'SEGMENT4' ,l_array_alt_segment_value(i), temp.alt_segment4)
                       , DECODE(seg.to_segment_code,'SEGMENT5' ,l_array_alt_segment_value(i), temp.alt_segment5)
                       , DECODE(seg.to_segment_code,'SEGMENT6' ,l_array_alt_segment_value(i), temp.alt_segment6)
                       , DECODE(seg.to_segment_code,'SEGMENT7' ,l_array_alt_segment_value(i), temp.alt_segment7)
                       , DECODE(seg.to_segment_code,'SEGMENT8' ,l_array_alt_segment_value(i), temp.alt_segment8)
                       , DECODE(seg.to_segment_code,'SEGMENT9' ,l_array_alt_segment_value(i), temp.alt_segment9)
                       , DECODE(seg.to_segment_code,'SEGMENT10',l_array_alt_segment_value(i), temp.alt_segment10)
                       , DECODE(seg.to_segment_code,'SEGMENT11',l_array_alt_segment_value(i), temp.alt_segment11)
                       , DECODE(seg.to_segment_code,'SEGMENT12',l_array_alt_segment_value(i), temp.alt_segment12)
                       , DECODE(seg.to_segment_code,'SEGMENT13',l_array_alt_segment_value(i), temp.alt_segment13)
                       , DECODE(seg.to_segment_code,'SEGMENT14',l_array_alt_segment_value(i), temp.alt_segment14)
                       , DECODE(seg.to_segment_code,'SEGMENT15',l_array_alt_segment_value(i), temp.alt_segment15)
                       , DECODE(seg.to_segment_code,'SEGMENT16',l_array_alt_segment_value(i), temp.alt_segment16)
                       , DECODE(seg.to_segment_code,'SEGMENT17',l_array_alt_segment_value(i), temp.alt_segment17)
                       , DECODE(seg.to_segment_code,'SEGMENT18',l_array_alt_segment_value(i), temp.alt_segment18)
                       , DECODE(seg.to_segment_code,'SEGMENT19',l_array_alt_segment_value(i), temp.alt_segment19)
                       , DECODE(seg.to_segment_code,'SEGMENT20',l_array_alt_segment_value(i), temp.alt_segment20)
                       , DECODE(seg.to_segment_code,'SEGMENT21',l_array_alt_segment_value(i), temp.alt_segment21)
                       , DECODE(seg.to_segment_code,'SEGMENT22',l_array_alt_segment_value(i), temp.alt_segment22)
                       , DECODE(seg.to_segment_code,'SEGMENT23',l_array_alt_segment_value(i), temp.alt_segment23)
                       , DECODE(seg.to_segment_code,'SEGMENT24',l_array_alt_segment_value(i), temp.alt_segment24)
                       , DECODE(seg.to_segment_code,'SEGMENT25',l_array_alt_segment_value(i), temp.alt_segment25)
                       , DECODE(seg.to_segment_code,'SEGMENT26',l_array_alt_segment_value(i), temp.alt_segment26)
                       , DECODE(seg.to_segment_code,'SEGMENT27',l_array_alt_segment_value(i), temp.alt_segment27)
                       , DECODE(seg.to_segment_code,'SEGMENT28',l_array_alt_segment_value(i), temp.alt_segment28)
                       , DECODE(seg.to_segment_code,'SEGMENT29',l_array_alt_segment_value(i), temp.alt_segment29)
                       , DECODE(seg.to_segment_code,'SEGMENT30',l_array_alt_segment_value(i), temp.alt_segment30)
                       , CASE l_array_alt_gl_map_status(i)
                           WHEN C_INVALID THEN C_INVALID
                           ELSE CASE temp.alt_ccid_status_code
                                   WHEN C_INVALID THEN C_PROCESSING
                                   WHEN C_CREATED THEN C_NOT_PROCESSED
                                   ELSE temp.alt_ccid_status_code
                                END
                         END
                  FROM xla_transaction_accts_gt seg
                 WHERE seg.ae_header_id           = temp.ae_header_id
                   AND seg.temp_line_num          = temp.temp_line_num
                   AND seg.ledger_id              = temp.ledger_id
                   AND seg.sl_coa_mapping_id      = temp.sl_coa_mapping_id
                   AND seg.ae_header_id           = l_array_alt_header_id(i)
                   AND seg.temp_line_num          = l_array_alt_temp_line_num(i)
                   AND seg.ledger_id              = l_array_alt_ledger_id(i)
                   AND seg.sl_coa_mapping_id      = l_array_alt_coa_mapping_id(i)
                   AND seg.to_segment_code        = l_array_alt_to_segment_code(i)     --added 6660472 suggested by Kaouther
                   --AND seg.processing_status_code = l_array_processing_status_code(i)  --added by for bug6314762 to avoid single row subquery returns more than one row error
                   AND seg.processing_status_code =   l_array_alt_proc_status_code(i)       --corrected bug 8757043
                   )
       WHERE temp.balance_type_code             <> 'X'
         AND EXISTS (SELECT /*+ INDEX(t XLA_TRANSACTION_ACCTS_GT_N1) */ 'x'      --bug7673701
                        FROM xla_transaction_accts_gt  t
                       WHERE t.ae_header_id           = temp.ae_header_id
      		               AND t.temp_line_num          = temp.temp_line_num
      		               AND t.ledger_id              = temp.ledger_id
      		               AND t.sl_coa_mapping_id      = temp.sl_coa_mapping_id
                         AND t.processing_status_code = 'MAP_SEGMENT'
                         AND t.sl_coa_mapping_id      = p_gl_coa_mapping_id
                         AND t.ae_header_id           = l_array_alt_header_id(i)
                         AND t.temp_line_num          = l_array_alt_temp_line_num(i)
                         AND t.ledger_id              = l_array_alt_ledger_id(i)
                          AND t.to_segment_code        = l_array_alt_to_segment_code(i)     --added 6660472 suggested by Kaouther
                         AND t.sl_coa_mapping_id      = l_array_alt_coa_mapping_id(i)   )

   ;
   END IF; -- l_array_alt_header_id.COUNT > 0

   l_rowcount:= SQL%ROWCOUNT;
   l_count := l_count + l_rowcount;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
          trace
              (p_msg      => '# of rows updated into xla_ae_lines_gt(ALT ccid) = '||to_char(l_rowcount)
              ,p_level    => C_LEVEL_STATEMENT
              ,p_module   => l_log_module);

   END IF;

END IF;

--
-- get Mapping errors
-- 7509835 and removed headers_gt join.changed bind on XTAG instead of GAMI
-- And introduced a leading hint.
FOR error_rec IN
(

              SELECT  error_code
                     ,event_id
                     ,ledger_id
                     ,entity_id
                     ,from_ccid
                     ,ccid_coa_id
                FROM (SELECT /*+ dynamic_sampling(1)  INDEX (XTAG XLA_TRANSACTION_ACCTS_GT_N1) LEADING (XTAG,GAMI) */ DISTINCT
                                   gami.error_code  error_code
                                  ,xjlg.event_id    event_id
                                  ,xjlg.ledger_id   ledger_id
                                  ,xjlg.entity_id   entity_id
                                  ,gami.from_ccid   from_ccid
                                  ,xjlg.ccid_coa_id ccid_coa_id
                              FROM gl_accts_map_int_gt  gami
			          ,xla_transaction_accts_gt   xtag
                                  ,xla_ae_lines_gt               xjlg
                             WHERE xjlg.ae_header_id           = xtag.ae_header_id
                               AND xjlg.temp_line_num          = xtag.temp_line_num
                               AND xjlg.ledger_id              = xtag.ledger_id
                               AND xjlg.sl_coa_mapping_id      = xtag.sl_coa_mapping_id
                               AND gami.from_ccid              = xtag.code_combination_id
                               AND gami.coa_mapping_id         = xtag.sl_coa_mapping_id
                               AND xtag.sl_coa_mapping_id      = p_gl_coa_mapping_id
                               AND xtag.processing_status_code IN ('MAP_CCID','MAP_SEGMENT')
                               AND xtag.side_code              IN ('ALL','CREDIT','NA')
                               AND gami.error_code             IS NOT NULL
                               AND xjlg.code_combination_id    = -1
                               AND xjlg.balance_type_code      <> 'X'
                      UNION
                      SELECT /*+ dynamic_sampling(1)  INDEX (XTAG XLA_TRANSACTION_ACCTS_GT_N1) LEADING (XTAG,GAMI) */ DISTINCT
                                   gami.error_code  error_code
                                  ,xjlg.event_id    event_id
                                  ,xjlg.ledger_id   ledger_id
                                  ,xjlg.entity_id   entity_id
                                  ,gami.from_ccid   from_ccid
                                  , xjlg.ccid_coa_id coa_id
                              FROM gl_accts_map_int_gt  gami
			          ,xla_transaction_accts_gt   xtag
                                  ,xla_ae_lines_gt            xjlg
                             WHERE xjlg.ae_header_id           = xtag.ae_header_id
                               AND xjlg.temp_line_num          = xtag.temp_line_num
                               AND xjlg.ledger_id              = xtag.ledger_id
                               AND xjlg.sl_coa_mapping_id      = xtag.sl_coa_mapping_id
                               AND gami.from_ccid              = xtag.code_combination_id
                               AND gami.coa_mapping_id         = xtag.sl_coa_mapping_id
                               AND xtag.sl_coa_mapping_id      = p_gl_coa_mapping_id
                               AND xtag.processing_status_code IN ('MAP_CCID','MAP_SEGMENT')
                               AND xtag.side_code              IN ('ALL','DEBIT')
                               AND gami.error_code             IS NOT NULL
                               AND xjlg.alt_code_combination_id    = -1
                               AND xjlg.balance_type_code          <> 'X'
                        )
)
LOOP

/*
--added bug 6666983,account value should be displayed in error message even if ccid is invalid
SELECT concatenated_segments
INTO l_ConcatKey
FROM gl_code_combinations_kfv
WHERE code_combination_id  = error_rec.from_ccid;
*/ --commented per bug 8687228


 xla_ae_journal_entry_pkg.g_global_status      :=  xla_ae_journal_entry_pkg.C_INVALID;
 l_message  := SUBSTR(error_rec.error_code,1,1000);
 xla_accounting_err_pkg.build_message
                         (p_appli_s_name            => 'XLA'
                         ,p_msg_name                => 'XLA_AP_GL_INVALID_COA_MAPPING'
                         ,p_token_1                 => 'GL_COA_MAPPING_NAME'
                         ,p_value_1                 =>  p_gl_coa_mapping_name
                         ,p_token_2                 => 'ACCOUNT_VALUE'
                         ,p_value_2                 => NVL(get_account_value(
                                                              p_combination_id => error_rec.from_ccid
                                                             ,p_flex_application_id => 101
                                                             ,p_application_short_name => 'SQLGL'
                                                             ,p_id_flex_code => 'GL#'
                                                             ,p_id_flex_num => error_rec.ccid_coa_id),error_rec.from_ccid)
                                                             --added error_rec.from_ccid  per bug 8687228 ccid should be displayed in error message even if ccid is invalid
                         ,p_token_3                 => 'ERROR'
                         ,p_value_3                 => nvl(l_message, error_rec.error_code)
                         ,p_entity_id               => error_rec.entity_id
                         ,p_event_id                => error_rec.event_id
                         ,p_ledger_id               => error_rec.ledger_id
  );

IF (C_LEVEL_ERROR >= g_log_level) THEN
    trace
       (p_msg      => 'ERROR: XLA_AP_GL_INVALID_COA_MAPPING'
       ,p_level    => C_LEVEL_ERROR
       ,p_module   => l_log_module);
END IF;
END LOOP;




IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
        trace
           (p_msg      => 'END of map_ccid = '||to_char(l_count)
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);

END IF;
RETURN l_count;
EXCEPTION

    WHEN GL_DISABLED_MAPPING THEN
    IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
       trace
           (p_msg      => 'Error. = '||sqlerrm
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
    END IF;
    RAISE;

    WHEN xla_exceptions_pkg.application_exception THEN
    IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
       trace
           (p_msg      => 'Error. = '||sqlerrm
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
    END IF;
    RAISE;
  WHEN OTHERS  THEN
   IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
       trace
           (p_msg      => 'Error. = '||sqlerrm
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
   END IF;
   xla_exceptions_pkg.raise_message
           (p_location => 'xla_ae_code_combination_pkg.map_ccid');
       --
END map_ccid;


/*---------------------------------------------------------------+
|                                                                |
| Private function                                               |
|                                                                |
|    map_segment_qualifier                                       |
|                                                                |
| converts the transaction CCIDs in accounting ledger's COA      |
|                                                                |
+---------------------------------------------------------------*/

FUNCTION  map_segment_qualifier(
    p_gl_coa_mapping_name IN VARCHAR2
  , p_gl_coa_mapping_id   IN NUMBER
)
RETURN NUMBER
IS
l_message            VARCHAR2(2000);
l_count              NUMBER;
l_rowcount           NUMBER;
l_error              BOOLEAN;
l_gl_error_code      VARCHAR2(1000);
l_array_event_id     xla_ae_journal_entry_pkg.t_array_Num;
l_array_entity_id    xla_ae_journal_entry_pkg.t_array_Num;
l_array_ledger_id    xla_ae_journal_entry_pkg.t_array_Num;
l_log_module         VARCHAR2(240);
BEGIN
IF g_log_enabled THEN
       l_log_module := C_DEFAULT_MODULE||'.map_segment_qualifier';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of map_segment_qualifier'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;

l_count := 0;

FOR  qualifier_rec IN (SELECT xtag.from_segment_code  qualifier
                      FROM xla_transaction_accts_gt xtag
                     WHERE xtag.sl_coa_mapping_id      = p_gl_coa_mapping_id
                       AND xtag.processing_status_code = 'MAP_QUALIFIER'
                  GROUP BY xtag.from_segment_code )
LOOP
-- reset the GT table

 DELETE from gl_accts_map_bsv_gt;

-- insert the segment value in the GT table

 INSERT INTO gl_accts_map_bsv_gt
 ( SOURCE_BSV )
 SELECT segment
  FROM xla_transaction_accts_gt xtag
 WHERE xtag.sl_coa_mapping_id      = p_gl_coa_mapping_id
   AND xtag.processing_status_code = 'MAP_QUALIFIER'
   AND xtag.from_segment_code      = qualifier_rec.qualifier
 GROUP BY segment
;

-- call the GL qualifier mapping

BEGIN

 GL_ACCOUNTS_MAP_GRP.map_qualified_segment(
     p_mapping_name => p_gl_coa_mapping_name
   , p_qualifier  => qualifier_rec.qualifier
   , p_debug        => g_log_enabled
 );

EXCEPTION

 WHEN GL_ACCOUNTS_MAP_GRP.GL_INVALID_MAPPING_NAME THEN
      l_gl_error_code:= 'GL_INVALID_MAPPING_NAME';
      l_error :=TRUE;
 WHEN GL_ACCOUNTS_MAP_GRP.GL_DISABLED_MAPPING THEN
     l_gl_error_code:='GL_DISABLED_MAPPING';
     l_error :=TRUE;
 WHEN GL_ACCOUNTS_MAP_GRP.GL_BSV_MAP_NO_SOURCE_BAL_SEG THEN
      l_gl_error_code:='GL_BSV_MAP_NO_SOURCE_BAL_SEG';
      l_error :=TRUE;
 WHEN GL_ACCOUNTS_MAP_GRP.GL_BSV_MAP_NO_TARGET_BAL_SEG THEN
      l_gl_error_code:='GL_BSV_MAP_NO_TARGET_BAL_SEG';
      l_error :=TRUE;
 WHEN GL_ACCOUNTS_MAP_GRP.GL_BSV_MAP_NO_SEGMENT_MAP THEN
      l_gl_error_code:='GL_BSV_MAP_NO_SEGMENT_MAP';
      l_error :=TRUE;
 WHEN GL_ACCOUNTS_MAP_GRP.GL_BSV_MAP_NO_SINGLE_VALUE THEN
      l_gl_error_code:='GL_BSV_MAP_NO_SINGLE_VALUE';
       l_error :=TRUE;
 WHEN GL_ACCOUNTS_MAP_GRP.GL_BSV_MAP_NO_FROM_SEGMENT THEN
      l_gl_error_code:='GL_BSV_MAP_NO_FROM_SEGMENT';
      l_error :=TRUE;
 WHEN GL_ACCOUNTS_MAP_GRP.GL_BSV_MAP_NOT_BSV_DERIVED THEN
      l_gl_error_code:='GL_BSV_MAP_NOT_BSV_DERIVED';
      l_error :=TRUE;
 WHEN GL_ACCOUNTS_MAP_GRP.GL_BSV_MAP_SETUP_ERROR THEN
      l_gl_error_code:='GL_BSV_MAP_SETUP_ERROR';
      l_error :=TRUE;
 WHEN GL_ACCOUNTS_MAP_GRP.GL_BSV_MAP_MAPPING_ERROR THEN
      l_gl_error_code:='GL_BSV_MAP_MAPPING_ERROR';
      l_error :=TRUE;
END;

-- update xla_ae_lines_gt

IF l_error THEN

 UPDATE xla_ae_lines_gt temp
    SET temp.code_combination_id = -1
       ,temp.code_combination_status_code = C_INVALID
 WHERE  temp.balance_type_code             <> 'X'
   AND EXISTS (SELECT /*+ INDEX (t XLA_TRANSACTION_ACCTS_GT_N1) */ 'x' --bug7673701
                   FROM xla_transaction_accts_gt  t
                  WHERE t.ae_header_id          = temp.ae_header_id
 		   AND t.temp_line_num          = temp.temp_line_num
 		   AND t.ledger_id              = temp.ledger_id
 		   AND t.sl_coa_mapping_id      = temp.sl_coa_mapping_id
 		   AND t.from_segment_code      =  qualifier_rec.qualifier
                   AND t.processing_status_code = 'MAP_QUALIFIER'
                   AND t.side_code              IN ('ALL','CREDIT','NA')
                   AND t.sl_coa_mapping_id      = p_gl_coa_mapping_id
                )
 RETURNING    entity_id, event_id, ledger_id   BULK COLLECT
 INTO l_array_entity_id, l_array_event_id, l_array_ledger_id
 ;

 l_rowcount:= SQL%ROWCOUNT;

 IF (C_LEVEL_STATEMENT >= g_log_level) THEN
     trace
      (p_msg      => '# of rows updated into xla_ae_lines_gt(error) = '||to_char(l_rowcount)
      ,p_level    => C_LEVEL_STATEMENT
      ,p_module   => l_log_module);

 END IF;

 l_count := l_count + l_rowcount;

 IF (C_LEVEL_ERROR >= g_log_level) THEN
                   trace
                      (p_msg      => 'ERROR: XLA_AP_GL_INV_QUAL_MAPPING'
                      ,p_level    => C_LEVEL_ERROR
                      ,p_module   => l_log_module);
 END IF;

 FOR Idx IN l_array_event_id.FIRST .. l_array_event_id.LAST  LOOP

   IF l_array_event_id.EXISTS(Idx) THEN
    xla_ae_journal_entry_pkg.g_global_status      :=  xla_ae_journal_entry_pkg.C_INVALID;
    xla_accounting_err_pkg.build_message
                         (p_appli_s_name            => 'XLA'
                         ,p_msg_name                => 'XLA_AP_GL_INV_QUAL_MAPPING'
                         ,p_token_1                 => 'GL_COA_MAPPING_NAME'
                         ,p_value_1                 =>  p_gl_coa_mapping_name
                         ,p_token_2                 => 'QUALIFIER_NAME'
                         ,p_value_2                 => xla_lookups_pkg.get_meaning(
                                                       'XLA_FLEXFIELD_SEGMENTS_QUAL'
                                                      , qualifier_rec.qualifier)
                         ,p_token_3                 => 'ERROR_MSG'
                         ,p_value_3                 => l_gl_error_code
                         ,p_entity_id               => l_array_entity_id(Idx)
                         ,p_event_id                => l_array_event_id(Idx)
                         ,p_ledger_id               => l_array_ledger_id(Idx)
                          );
    END IF;

 END LOOP;

 l_array_entity_id.DELETE ;
 l_array_event_id.DELETE;
 l_array_ledger_id.DELETE;

  UPDATE xla_ae_lines_gt temp
    SET temp.alt_code_combination_id = -1
       ,temp.alt_ccid_status_code = C_INVALID
  WHERE temp.balance_type_code             <> 'X'
    AND EXISTS (SELECT /*+ INDEX (t XLA_TRANSACTION_ACCTS_GT_N1) */ 'x' --bug7673701
                   FROM xla_transaction_accts_gt  t
                  WHERE t.ae_header_id          = temp.ae_header_id
 		   AND t.temp_line_num          = temp.temp_line_num
 		   AND t.ledger_id              = temp.ledger_id
 		   AND t.sl_coa_mapping_id      = temp.sl_coa_mapping_id
 		   AND t.from_segment_code      =  qualifier_rec.qualifier
                   AND t.processing_status_code = 'MAP_QUALIFIER'
                   AND t.side_code              IN ('ALL','DEBIT')
                   AND t.sl_coa_mapping_id      = p_gl_coa_mapping_id
                )
   RETURNING    entity_id, event_id, ledger_id   BULK COLLECT
   INTO l_array_entity_id, l_array_event_id, l_array_ledger_id
 ;

 l_rowcount:= SQL%ROWCOUNT;
 l_count := l_count + l_rowcount;

 IF (C_LEVEL_STATEMENT >= g_log_level) THEN
     trace
      (p_msg      => '# of rows updated into xla_ae_lines_gt(error) = '||to_char(l_rowcount)
      ,p_level    => C_LEVEL_STATEMENT
      ,p_module   => l_log_module);

 END IF;

 FOR Idx IN l_array_event_id.FIRST .. l_array_event_id.LAST  LOOP

   IF l_array_event_id.EXISTS(Idx) THEN
    xla_ae_journal_entry_pkg.g_global_status      :=  xla_ae_journal_entry_pkg.C_INVALID;
    xla_accounting_err_pkg.build_message
                         (p_appli_s_name            => 'XLA'
                         ,p_msg_name                => 'XLA_AP_GL_INV_QUAL_MAPPING'
                         ,p_token_1                 => 'GL_COA_MAPPING_NAME'
                         ,p_value_1                 =>  p_gl_coa_mapping_name
                         ,p_token_2                 => 'QUALIFIER_NAME'
                         ,p_value_2                 => xla_lookups_pkg.get_meaning(
                                                       'XLA_FLEXFIELD_SEGMENTS_QUAL'
                                                      , qualifier_rec.qualifier)
                         ,p_token_3                 => 'ERROR_MSG'
                         ,p_value_3                 => l_gl_error_code
                         ,p_entity_id               => l_array_entity_id(Idx)
                         ,p_event_id                => l_array_event_id(Idx)
                         ,p_ledger_id               => l_array_ledger_id(Idx)
                          );
    END IF;

 END LOOP;


ELSE
-- no error
-- copy converted qualifier value in the xla_ae_lines_gt table

UPDATE xla_ae_lines_gt temp
           SET ( temp.segment1
                ,temp.segment2
                ,temp.segment3
                ,temp.segment4
                ,temp.segment5
                ,temp.segment6
                ,temp.segment7
                ,temp.segment8
                ,temp.segment9
                ,temp.segment10
                ,temp.segment11
                ,temp.segment12
                ,temp.segment13
                ,temp.segment14
                ,temp.segment15
                ,temp.segment16
                ,temp.segment17
                ,temp.segment18
                ,temp.segment19
                ,temp.segment20
                ,temp.segment21
                ,temp.segment22
                ,temp.segment23
                ,temp.segment24
                ,temp.segment25
                ,temp.segment26
                ,temp.segment27
                ,temp.segment28
                ,temp.segment29
                ,temp.segment30
                ,temp.code_combination_status_code) =
                 (
           SELECT DISTINCT
                    DECODE(seg.to_segment_code,'SEGMENT1' ,seg.target_value, temp.segment1)
                  , DECODE(seg.to_segment_code,'SEGMENT2' ,seg.target_value, temp.segment2)
                  , DECODE(seg.to_segment_code,'SEGMENT3' ,seg.target_value, temp.segment3)
                  , DECODE(seg.to_segment_code,'SEGMENT4' ,seg.target_value, temp.segment4)
                  , DECODE(seg.to_segment_code,'SEGMENT5' ,seg.target_value, temp.segment5)
                  , DECODE(seg.to_segment_code,'SEGMENT6' ,seg.target_value, temp.segment6)
                  , DECODE(seg.to_segment_code,'SEGMENT7' ,seg.target_value, temp.segment7)
                  , DECODE(seg.to_segment_code,'SEGMENT8' ,seg.target_value, temp.segment8)
                  , DECODE(seg.to_segment_code,'SEGMENT9' ,seg.target_value, temp.segment9)
                  , DECODE(seg.to_segment_code,'SEGMENT10',seg.target_value, temp.segment10)
                  , DECODE(seg.to_segment_code,'SEGMENT11',seg.target_value, temp.segment11)
                  , DECODE(seg.to_segment_code,'SEGMENT12',seg.target_value, temp.segment12)
                  , DECODE(seg.to_segment_code,'SEGMENT13',seg.target_value, temp.segment13)
                  , DECODE(seg.to_segment_code,'SEGMENT14',seg.target_value, temp.segment14)
                  , DECODE(seg.to_segment_code,'SEGMENT15',seg.target_value, temp.segment15)
                  , DECODE(seg.to_segment_code,'SEGMENT16',seg.target_value, temp.segment16)
                  , DECODE(seg.to_segment_code,'SEGMENT17',seg.target_value, temp.segment17)
                  , DECODE(seg.to_segment_code,'SEGMENT18',seg.target_value, temp.segment18)
                  , DECODE(seg.to_segment_code,'SEGMENT19',seg.target_value, temp.segment19)
                  , DECODE(seg.to_segment_code,'SEGMENT20',seg.target_value, temp.segment20)
                  , DECODE(seg.to_segment_code,'SEGMENT21',seg.target_value, temp.segment21)
                  , DECODE(seg.to_segment_code,'SEGMENT22',seg.target_value, temp.segment22)
                  , DECODE(seg.to_segment_code,'SEGMENT23',seg.target_value, temp.segment23)
                  , DECODE(seg.to_segment_code,'SEGMENT24',seg.target_value, temp.segment24)
                  , DECODE(seg.to_segment_code,'SEGMENT25',seg.target_value, temp.segment25)
                  , DECODE(seg.to_segment_code,'SEGMENT26',seg.target_value, temp.segment26)
                  , DECODE(seg.to_segment_code,'SEGMENT27',seg.target_value, temp.segment27)
                  , DECODE(seg.to_segment_code,'SEGMENT28',seg.target_value, temp.segment28)
                  , DECODE(seg.to_segment_code,'SEGMENT29',seg.target_value, temp.segment29)
                  , DECODE(seg.to_segment_code,'SEGMENT30',seg.target_value, temp.segment30)
                  , CASE temp.code_combination_status_code
                      WHEN C_INVALID THEN C_PROCESSING
                      WHEN C_CREATED THEN C_NOT_PROCESSED
                      ELSE temp.code_combination_status_code
                    END
             FROM (
                   SELECT /*+ INDEX (XTA XLA_TRANSACTION_ACCTS_GT_N1) LEADING (XTA) */   DISTINCT    --bug7673701
                          xta.ae_header_id                                   ae_header_id
                        , xta.temp_line_num                                  temp_line_num
                        , xta.ledger_id                                      ledger_id
                        , xta.sl_coa_mapping_id                              sl_coa_mapping_id
                        , xta.to_segment_code                                to_segment_code
                        , gami.target_bsv                                    target_value
                   FROM  gl_accts_map_bsv_gt   gami
                       , xla_transaction_accts_gt   xta
                   WHERE gami.source_bsv            = xta.segment
                     AND xta.from_segment_code      = qualifier_rec.qualifier
                     AND xta.processing_status_code = 'MAP_QUALIFIER'
                     AND xta.side_code              IN ('ALL','CREDIT','NA')
                     AND xta.sl_coa_mapping_id      = p_gl_coa_mapping_id
                  ) seg
             WHERE seg.ae_header_id           = temp.ae_header_id
               AND seg.temp_line_num          = temp.temp_line_num
               AND seg.ledger_id              = temp.ledger_id
               AND seg.sl_coa_mapping_id      = temp.sl_coa_mapping_id
              )
  WHERE temp.balance_type_code             <> 'X'
    AND EXISTS (SELECT /*+ INDEX (t XLA_TRANSACTION_ACCTS_GT_N1) */ 'x' --bug7673701
                   FROM xla_transaction_accts_gt  t
                  WHERE t.ae_header_id          = temp.ae_header_id
 		   AND t.temp_line_num          = temp.temp_line_num
 		   AND t.ledger_id              = temp.ledger_id
 		   AND t.sl_coa_mapping_id      = temp.sl_coa_mapping_id
 		   AND t.from_segment_code      =  qualifier_rec.qualifier
                   AND t.processing_status_code = 'MAP_QUALIFIER'
                   AND t.side_code              IN ('ALL','CREDIT','NA')
                   AND t.sl_coa_mapping_id      = p_gl_coa_mapping_id)
   ;

  l_rowcount:= SQL%ROWCOUNT;
  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
        (p_msg      => '# of rows updated into xla_ae_lines_gt(ccid) = '||to_char(l_rowcount)
        ,p_level    => C_LEVEL_STATEMENT
        ,p_module   => l_log_module);
  END IF;
  l_count := l_count + l_rowcount;
--end insert into xla_ae_lines_gt(ccid)


UPDATE xla_ae_lines_gt temp
           SET ( temp.alt_segment1
                ,temp.alt_segment2
                ,temp.alt_segment3
                ,temp.alt_segment4
                ,temp.alt_segment5
                ,temp.alt_segment6
                ,temp.alt_segment7
                ,temp.alt_segment8
                ,temp.alt_segment9
                ,temp.alt_segment10
                ,temp.alt_segment11
                ,temp.alt_segment12
                ,temp.alt_segment13
                ,temp.alt_segment14
                ,temp.alt_segment15
                ,temp.alt_segment16
                ,temp.alt_segment17
                ,temp.alt_segment18
                ,temp.alt_segment19
                ,temp.alt_segment20
                ,temp.alt_segment21
                ,temp.alt_segment22
                ,temp.alt_segment23
                ,temp.alt_segment24
                ,temp.alt_segment25
                ,temp.alt_segment26
                ,temp.alt_segment27
                ,temp.alt_segment28
                ,temp.alt_segment29
                ,temp.alt_segment30
                ,temp.alt_ccid_status_code) =
                 (
           SELECT   DISTINCT
                    DECODE(seg.to_segment_code,'SEGMENT1' ,seg.target_value, temp.alt_segment1)
                  , DECODE(seg.to_segment_code,'SEGMENT2' ,seg.target_value, temp.alt_segment2)
                  , DECODE(seg.to_segment_code,'SEGMENT3' ,seg.target_value, temp.alt_segment3)
                  , DECODE(seg.to_segment_code,'SEGMENT4' ,seg.target_value, temp.alt_segment4)
                  , DECODE(seg.to_segment_code,'SEGMENT5' ,seg.target_value, temp.alt_segment5)
                  , DECODE(seg.to_segment_code,'SEGMENT6' ,seg.target_value, temp.alt_segment6)
                  , DECODE(seg.to_segment_code,'SEGMENT7' ,seg.target_value, temp.alt_segment7)
                  , DECODE(seg.to_segment_code,'SEGMENT8' ,seg.target_value, temp.alt_segment8)
                  , DECODE(seg.to_segment_code,'SEGMENT9' ,seg.target_value, temp.alt_segment9)
                  , DECODE(seg.to_segment_code,'SEGMENT10',seg.target_value, temp.alt_segment10)
                  , DECODE(seg.to_segment_code,'SEGMENT11',seg.target_value, temp.alt_segment11)
                  , DECODE(seg.to_segment_code,'SEGMENT12',seg.target_value, temp.alt_segment12)
                  , DECODE(seg.to_segment_code,'SEGMENT13',seg.target_value, temp.alt_segment13)
                  , DECODE(seg.to_segment_code,'SEGMENT14',seg.target_value, temp.alt_segment14)
                  , DECODE(seg.to_segment_code,'SEGMENT15',seg.target_value, temp.alt_segment15)
                  , DECODE(seg.to_segment_code,'SEGMENT16',seg.target_value, temp.alt_segment16)
                  , DECODE(seg.to_segment_code,'SEGMENT17',seg.target_value, temp.alt_segment17)
                  , DECODE(seg.to_segment_code,'SEGMENT18',seg.target_value, temp.alt_segment18)
                  , DECODE(seg.to_segment_code,'SEGMENT19',seg.target_value, temp.alt_segment19)
                  , DECODE(seg.to_segment_code,'SEGMENT20',seg.target_value, temp.alt_segment20)
                  , DECODE(seg.to_segment_code,'SEGMENT21',seg.target_value, temp.alt_segment21)
                  , DECODE(seg.to_segment_code,'SEGMENT22',seg.target_value, temp.alt_segment22)
                  , DECODE(seg.to_segment_code,'SEGMENT23',seg.target_value, temp.alt_segment23)
                  , DECODE(seg.to_segment_code,'SEGMENT24',seg.target_value, temp.alt_segment24)
                  , DECODE(seg.to_segment_code,'SEGMENT25',seg.target_value, temp.alt_segment25)
                  , DECODE(seg.to_segment_code,'SEGMENT26',seg.target_value, temp.alt_segment26)
                  , DECODE(seg.to_segment_code,'SEGMENT27',seg.target_value, temp.alt_segment27)
                  , DECODE(seg.to_segment_code,'SEGMENT28',seg.target_value, temp.alt_segment28)
                  , DECODE(seg.to_segment_code,'SEGMENT29',seg.target_value, temp.alt_segment29)
                  , DECODE(seg.to_segment_code,'SEGMENT30',seg.target_value, temp.alt_segment30)
                  , CASE temp.alt_ccid_status_code
                      WHEN C_INVALID THEN C_PROCESSING
                      WHEN C_CREATED THEN C_NOT_PROCESSED
                      ELSE temp.alt_ccid_status_code
                    END
             FROM (
                   SELECT /*+ INDEX (XTA XLA_TRANSACTION_ACCTS_GT_N1) LEADING (XTA) */   DISTINCT    --bug7673701
                          xta.ae_header_id                                   ae_header_id
                        , xta.temp_line_num                                  temp_line_num
                        , xta.ledger_id                                      ledger_id
                        , xta.sl_coa_mapping_id                              sl_coa_mapping_id
                        , xta.to_segment_code                                to_segment_code
                        , gami.target_bsv                                    target_value
                   FROM  gl_accts_map_bsv_gt   gami
                       , xla_transaction_accts_gt   xta
                   WHERE gami.source_bsv            = xta.segment
                     AND xta.from_segment_code      = qualifier_rec.qualifier
                     AND xta.processing_status_code = 'MAP_QUALIFIER'
                     AND xta.side_code              IN ('ALL','DEBIT')
                     AND xta.sl_coa_mapping_id      = p_gl_coa_mapping_id
                  ) seg
             WHERE seg.ae_header_id           = temp.ae_header_id
               AND seg.temp_line_num          = temp.temp_line_num
               AND seg.ledger_id              = temp.ledger_id
               AND seg.sl_coa_mapping_id      = temp.sl_coa_mapping_id
              )
  WHERE  temp.balance_type_code             <> 'X'
    AND  EXISTS (SELECT /*+ INDEX (t XLA_TRANSACTION_ACCTS_GT_N1) */ 'x' --bug7673701
                   FROM xla_transaction_accts_gt  t
                  WHERE t.ae_header_id          = temp.ae_header_id
 		   AND t.temp_line_num          = temp.temp_line_num
 		   AND t.ledger_id              = temp.ledger_id
 		   AND t.sl_coa_mapping_id      = temp.sl_coa_mapping_id
 		   AND t.from_segment_code      =  qualifier_rec.qualifier
                   AND t.processing_status_code = 'MAP_QUALIFIER'
                   AND t.side_code              IN ('ALL','DEBIT')
                   AND t.sl_coa_mapping_id      = p_gl_coa_mapping_id)
   ;

  l_rowcount:= SQL%ROWCOUNT;
  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
        (p_msg      => '# of rows updated into xla_ae_lines_gt(ALT ccid) = '||to_char(l_rowcount)
        ,p_level    => C_LEVEL_STATEMENT
        ,p_module   => l_log_module);
  END IF;
  l_count := l_count + l_rowcount;
--end insert into xla_ae_lines_gt(ccid)

END IF;

END LOOP; --end loop qualifiers

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
        trace
           (p_msg      => 'END of map_segment_qualifier ='||l_count
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
END IF;
RETURN l_count;
EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
     IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
       trace
           (p_msg      => 'Error. = '||sqlerrm
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
     END IF;
     RAISE;
  WHEN OTHERS  THEN
    IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
       trace
           (p_msg      => 'Error. = '||sqlerrm
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
    END IF;
   xla_exceptions_pkg.raise_message
           (p_location => 'xla_ae_code_combination_pkg.map_segment_qualifier');
END map_segment_qualifier;

/*-----------------------------------------------------------------------+
|                                                                        |
| Private function                                                       |
|                                                                        |
|      map_transaction_accounts                                          |
|                                                                        |
| Drives the mapping of ccids and segment qualifiers                     |
|                                                                        |
+-----------------------------------------------------------------------*/

FUNCTION  map_transaction_accounts
RETURN NUMBER
IS
l_message            VARCHAR2(2000);
l_count              NUMBER;
l_log_module         VARCHAR2(240);
BEGIN
IF g_log_enabled THEN
       l_log_module := C_DEFAULT_MODULE||'.map_transaction_accounts';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of map_transaction_accounts'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
l_count := 0;

IF g_cache_coa_sla_mapping.COUNT > 0 THEN
  FOR Idx IN g_cache_coa_sla_mapping.FIRST .. g_cache_coa_sla_mapping.LAST  LOOP
     IF g_cache_coa_sla_mapping.EXISTS(Idx) THEN

        IF (C_LEVEL_STATEMENT >= g_log_level) THEN
           trace
              (p_msg      => 'coa_sla_mapping_name = '|| g_cache_coa_sla_mapping(Idx)||
                             ', coa_sla_mapping_id = '|| Idx
             ,p_level    => C_LEVEL_STATEMENT
             ,p_module   => l_log_module);
        END IF;

        l_count := l_count + map_ccid(
                    p_gl_coa_mapping_name => g_cache_coa_sla_mapping(Idx),
                    p_gl_coa_mapping_id   => Idx);

        l_count := l_count + map_segment_qualifier(
                    p_gl_coa_mapping_name => g_cache_coa_sla_mapping(Idx),
                    p_gl_coa_mapping_id   => Idx);

     END IF; -- end if exists
  END LOOP;
END IF; -- end if count>0
--
refreshGLMappingCache;
--
-- Moved call to BusinessflowSameEntry after Map_ccid,bug 6675871
XLA_AE_LINES_PKG.BusinessFlowSameEntries;


IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
        trace
           (p_msg      => 'END of map_transaction_accounts= '||to_char(l_count)
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
END IF;
--
RETURN l_count;
EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
     RAISE;
  WHEN OTHERS  THEN
   xla_exceptions_pkg.raise_message
           (p_location => 'xla_ae_code_combination_pkg.map_transaction_accounts');
       --
END map_transaction_accounts;

/*-----------------------------------------------------------------------+
|                                                                        |
| Public function                                                        |
|                                                                        |
|         BuildCcids                                                     |
|                                                                        |
| builds the new accounting ccids. It returns the number of rows updated |
|                                                                        |
+-----------------------------------------------------------------------*/
FUNCTION BuildCcids
RETURN NUMBER
IS
--
--
l_ccid_created                         NUMBER;
l_array_je_ids                         xla_ae_journal_entry_pkg.t_array_Num;
l_array_event_ids                      xla_ae_journal_entry_pkg.t_array_Num;
l_array_event_status                   xla_ae_journal_entry_pkg.t_array_V1L;
l_cache_array_target_coa               xla_ae_journal_entry_pkg.t_array_Num;
l_log_module                           VARCHAR2(240);
--
BEGIN
--
IF g_log_enabled THEN
       l_log_module := C_DEFAULT_MODULE||'.BuildCcids';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of BuildCcids'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
l_ccid_created   :=0;
--
l_ccid_created := map_transaction_accounts +
                  validate_source_ccid +
                  override_ccid +
                  create_ccid +
                  create_new_ccid ;
--
IF l_ccid_created > 0 THEN

   UPDATE xla_ae_headers_gt  xahg
      SET xahg.accounting_entry_status_code = xla_ae_journal_entry_pkg.C_INVALID
    WHERE xahg.ae_header_id IN (SELECT xalg.ae_header_id
                                   FROM xla_ae_lines_gt xalg
                                  WHERE xalg.balance_type_code            <> 'X'
                                    AND (xalg.code_combination_status_code <> C_CREATED
                                     OR xalg.code_combination_id = -1) and (nvl(xalg.gain_or_loss_flag,'N') = 'N' or nvl(xalg.calculate_g_l_amts_flag,'N') = 'N')
/*
                                     OR ((xalg.alt_code_combination_id = -1
                                          OR xalg.alt_ccid_status_code <> C_CREATED)
                                         AND xalg.gain_or_loss_flag = 'Y' and xalg.calculate_g_l_amts_flag = 'Y'))
*/
                                )
      AND xahg.accounting_entry_status_code <> xla_ae_journal_entry_pkg.C_INVALID
    ;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN

       trace
            (p_msg      => 'SQL - Update xla_ae_headers_gt  '
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
       trace
            (p_msg      => '# of rows updated into xla_ae_headers_gt = '||SQL%ROWCOUNT
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);

    END IF;


END IF;
--
-- reset traget coa cache
--
g_array_cache_target_coa  := l_cache_array_target_coa;
--
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

        trace
           (p_msg      => 'return value. = 0'
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);

        trace
           (p_msg      => 'END of BuildCcids'
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);

END IF;
--
RETURN 0;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
    IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
       trace
           (p_msg      => 'Error. = '||sqlerrm
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
     END IF;
     RAISE;
  WHEN OTHERS  THEN
   IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
       trace
           (p_msg      => 'Error. = '||sqlerrm
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
     END IF;
   xla_exceptions_pkg.raise_message
           (p_location => 'xla_ae_code_combination_pkg.BuildCcids');
END BuildCcids;
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
   g_error_exists   :=FALSE;
   g_log_level      := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   g_log_enabled    := fnd_log.test
                          (log_level  => g_log_level
                          ,module     => C_DEFAULT_MODULE);

   IF NOT g_log_enabled  THEN
      g_log_level := C_LEVEL_LOG_DISABLED;
   END IF;
END xla_ae_code_combination_pkg; --

/
