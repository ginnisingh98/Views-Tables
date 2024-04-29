--------------------------------------------------------
--  DDL for Package Body XLA_CMP_COMMON_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_CMP_COMMON_PKG" AS
/* $Header: xlacpcom.pkb 120.3 2006/06/16 00:55:17 jlarre ship $ */
/*======================================================================+
|             Copyright (c) 1995-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_cmp_lock_pkg                                                   |
|                                                                       |
| DESCRIPTION                                                           |
|    Oracle Subledger Accounting Compiler Common Code                   |
|                                                                       |
| HISTORY                                                               |
|    30-JAN-04 A.Quaglia      Created                                   |
|    15-MAY-2006 Jorge Larre  Fix for bug 5330846. This is a temporary  |
|       fix until we get a confirmation from the ATG team that there    |
|       will only be one row in fnd_oracle_userid to retrieve the schema|
|       name with read_only_flag = 'U'. In this temporary fix we assume |
|       that the install_group_num is 1 (this is correct in the internal|
|       databases).                                                     |
|                                                                       |
+======================================================================*/

   -- Private Constants
   G_MAX_PACKAGE_LINE_LENGTH CONSTANT INTEGER := 255;
   G_CHR_QUOTE               CONSTANT VARCHAR2(9)   :='''';
   G_CHR_SPACE               CONSTANT VARCHAR2(9)   :=' ';
   G_CHR_NEWLINE             CONSTANT VARCHAR2(10)  := xla_environment_pkg.g_chr_newline;


   --
   -- Private exceptions
   --
   le_resource_busy                   EXCEPTION;
   PRAGMA exception_init(le_resource_busy, -00054);

   le_fatal_error                     EXCEPTION;
   --
   -- Private types
   --

   --
   -- Private constants
   --

   --
   -- Global variables
   --
   g_user_id                 INTEGER := xla_environment_pkg.g_usr_id;
   g_login_id                INTEGER := xla_environment_pkg.g_login_id;
   g_date                    DATE    := SYSDATE;
   g_prog_appl_id            INTEGER := xla_environment_pkg.g_prog_appl_id;
   g_prog_id                 INTEGER := xla_environment_pkg.g_prog_id;
   g_req_id                  INTEGER := NVL(xla_environment_pkg.g_req_id, -1);

   --

   -- Cursor declarations
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
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.xla_cmp_common_pkg';

g_log_level           NUMBER;
g_log_enabled         BOOLEAN;

--1-STATEMENT, 2-PROCEDURE, 3-EVENT, 4-EXCEPTION, 5-ERROR, 6-UNEXPECTED

PROCEDURE trace
       ( p_module                     IN VARCHAR2 DEFAULT C_DEFAULT_MODULE
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
         (p_location   => 'xla_cmp_common_pkg.trace');
END trace;


FUNCTION get_application_info
                  ( p_application_id       IN            NUMBER
                   ,p_application_info     OUT NOCOPY    lt_application_info
                  )
RETURN BOOLEAN
IS
   l_application_name       VARCHAR2(10);
   l_application_short_name VARCHAR2(50);
   l_product_short_name     VARCHAR2(10);
l_log_module                 VARCHAR2 (2000);

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.get_application_info';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   --Select application info from FND and AD tables
   SELECT fap.application_id
         ,fav.application_name
         ,fap.application_short_name
         ,fou.oracle_username
         ,UPPER(adp.product_abbreviation)
         ,fou_apps.oracle_username
     INTO p_application_info.application_id
         ,p_application_info.application_name
         ,p_application_info.application_short_name
         ,p_application_info.oracle_username
         ,p_application_info.product_abbreviation
         ,p_application_info.apps_account
     FROM fnd_application           fap
         ,fnd_application_vl        fav
         ,fnd_product_installations fpi
         ,fnd_oracle_userid         fou
         ,ad_pm_product_info        adp
         ,fnd_oracle_userid         fou_apps
    WHERE fap.application_id       =  p_application_id
      AND fav.application_id       =  fap.application_id
      AND fpi.application_id       =  fap.application_id
      AND fou.oracle_id            =  fpi.oracle_id
      AND fpi.install_group_num    IN (0, 1) --MSOB no more supported
      AND UPPER(adp.product_abbreviation)
                            =  UPPER(SUBSTR( fap.basepath
                                            ,1
                                            ,INSTR(fap.basepath,'_TOP') - 1
                                           )
                                    )
      AND fou_apps.install_group_num = 1 -- fpi.install_group_num (5330846)
      AND fou_apps.read_only_flag    = 'U'
      ;

   --Application ID cannot be longer that 5 chars
   IF LENGTH(TO_CHAR(p_application_info.application_id)) > 5
   THEN
      IF (C_LEVEL_EXCEPTION >= g_log_level)
      THEN
         trace
         (p_msg      => 'Application_id is too long, aborting'
         ,p_level    => C_LEVEL_PROCEDURE);
      END IF;
      RAISE le_fatal_error;
   END IF;

   --Application ID cannot be negative
   IF SIGN(p_application_info.application_id) <= 0
   THEN
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
         (p_msg      => 'Application_id is negative, aborting'
         ,p_level    => C_LEVEL_PROCEDURE);
      END IF;
      RAISE le_fatal_error;
   END IF;

   --Build the hash id
   p_application_info.application_hash_id := LPAD
                      ( TO_CHAR(p_application_info.application_id)
                       ,5
                       ,'0'
                      );
   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'Application hash id: '
                        || p_application_info.application_hash_id
         ,p_level    => C_LEVEL_STATEMENT);
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   RETURN TRUE;

EXCEPTION
WHEN le_fatal_error
THEN
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg   => 'END with fatal error' || l_log_module
         ,p_level => C_LEVEL_PROCEDURE);
   END IF;
   RETURN FALSE;

WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_cmp_common_pkg.get_application_info');

END get_application_info;


FUNCTION get_user_name
                  ( p_user_id          IN            NUMBER
                   ,p_user_name        OUT NOCOPY    VARCHAR2
                  )
RETURN BOOLEAN
IS
l_log_module                 VARCHAR2 (2000);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.get_user_name';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN ' || C_DEFAULT_MODULE||'.get_user_name'
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'Looking for user id: ' || p_user_id
         ,p_level    => C_LEVEL_STATEMENT);
   END IF;

   BEGIN
      SELECT user_name
        INTO p_user_name
        FROM fnd_user
       WHERE user_id = p_user_id;
   EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
      p_user_name := 'Unknown user';
   END;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'User name retrieved: ' || p_user_name
         ,p_level    => C_LEVEL_STATEMENT);
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END ' || C_DEFAULT_MODULE||'.get_user_name'
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   RETURN TRUE;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_cmp_common_pkg.get_user_name');

END get_user_name;


--+==========================================================================+
--| PRIVATE procedures and functions                                         |
--|    CreateString                                                          |
--|    transforms long lines (length > 255) into a list of lines not         |
--|    exceeding 255 characters                                              |
--|                                                                          |
--|                                                                          |
--+==========================================================================+
PROCEDURE CreateString( p_package_text  IN  VARCHAR2
                       ,p_array_string  OUT NOCOPY DBMS_SQL.VARCHAR2S)
IS
--
l_Text                VARCHAR2(32000);
l_SubText             VARCHAR2(256);
--
l_MaxLine             NUMBER   := G_MAX_PACKAGE_LINE_LENGTH;
--
l_NewLine             BOOLEAN;
l_Literal             BOOLEAN;
l_Space               BOOLEAN;
--
l_pos                 NUMBER         ;
--
l_Idx                 BINARY_INTEGER;
l_array_string        DBMS_SQL.VARCHAR2S;
--
l_log_module                 VARCHAR2 (2000);
BEGIN
--
xla_utility_pkg.trace('> xla_cmp_string_pkg.CreateString' , 80);
--
--
    l_Text      := p_package_text;
    l_pos       := 0;
    l_NewLine   := FALSE;
    l_Literal   := FALSE;
    l_Space     := FALSE;
    l_Idx       := 0;
    --
    WHILE ( LENGTH(l_Text) >= l_MaxLine ) LOOP
    --
      BEGIN
         --
         l_SubText   := SUBSTR(l_Text,1,l_MaxLine);
         l_pos       := INSTR(l_SubText,g_chr_newline,1,1);
         --
         IF l_pos = 0 THEN
         --
           l_NewLine := FALSE;
           l_pos := INSTR(l_SubText,g_chr_quote,1,1);
           --
           IF l_pos = 0 THEN
           --
             l_Literal := FALSE;
             l_pos     := INSTR(l_SubText,g_chr_space,1,1);
             l_Space   := (l_pos = 0);
           --
           ELSE
           --
             l_Literal := TRUE;
           --
           END IF;
         --
         ELSE
         --
           l_NewLine := TRUE;
         --
         END IF;
         --
         --
         IF l_newline THEN
         --
           l_Idx                  := l_Idx + 1;
           l_array_string(l_Idx)  := SUBSTR(l_SubText,1,l_pos);
           l_Text                 := SUBSTR(l_Text,l_pos + 1);
         --
         ELSIF l_Literal THEN
         --
           l_Idx                  := l_Idx + 1;
           l_array_string(l_Idx)  := SUBSTR(l_SubText,1,l_pos-1) || g_chr_newline;
           l_Text                 := SUBSTR(l_Text,l_pos);
         --
         ELSIF l_Space   THEN
         --
           l_Idx                  := l_Idx + 1;
           l_array_string(l_Idx)  := SUBSTR(l_SubText,1,l_pos-1) || g_chr_newline;
           l_Text                 := SUBSTR(l_Text,l_pos + 1);
         --
         ELSE
         --
           l_Idx                  := l_Idx + 1;
           l_array_string(l_Idx)  := l_SubText;
           l_Text                 := SUBSTR(l_Text,l_MaxLine + 1);
         --
         END IF;
         --
      END;
     -- xla_utility_pkg.trace('Text('||l_Idx||') = '||l_array_string(l_Idx), 100);
    END LOOP;
--
IF LENGTH(l_Text) > 0 THEN
--
  l_Idx                 := l_Idx + 1;
  l_array_string(l_Idx) := l_Text;
 -- xla_utility_pkg.trace('Text('||l_Idx||') = '||l_array_string(l_Idx), 100);
--
END IF;
--
p_array_string := l_array_string;
--
xla_utility_pkg.trace('< xla_cmp_string_pkg.CreateString' , 80);
--
EXCEPTION
   WHEN xla_exceptions_pkg.application_exception   THEN
       RAISE;
   WHEN OTHERS    THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_string_pkg.CreateString');
END CreateString;



PROCEDURE clob_to_varchar2s
                    (
                      p_clob          IN  CLOB
                     ,p_varchar2s     OUT NOCOPY DBMS_SQL.VARCHAR2S
                    )
IS
   l_current_table_index PLS_INTEGER;
   l_current_pos_in_clob PLS_INTEGER;
   l_next_newline_pos    PLS_INTEGER;
   l_clob_length         PLS_INTEGER;
   l_subarray            DBMS_SQL.VARCHAR2S;
l_log_module                 VARCHAR2 (2000);

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.clob_to_varchar2s';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   l_clob_length         := LENGTH(p_clob);
   l_current_table_index := -1;
   l_current_pos_in_clob := 1;

   WHILE l_current_pos_in_clob < l_clob_length
   LOOP
      l_current_table_index := l_current_table_index + 1;
      l_next_newline_pos    := INSTR
        ( p_clob                --clob to search
         ,g_chr_newline         --character to look for
         ,l_current_pos_in_clob --starting position
         ,1                     --occurrence
        );

      IF l_next_newline_pos = 0
      THEN
         --no new line found, take all the string to the end
         --if the length of the substring exceeds the maximum
         --break it into substrings
         IF (l_clob_length - l_current_pos_in_clob + 1 )
            <= G_MAX_PACKAGE_LINE_LENGTH
         THEN
            --the chunk length is within the maximum
            p_varchar2s(l_current_table_index) := SUBSTR
                                                  ( p_clob
                                                   ,l_current_pos_in_clob
                                                  );
         ELSE
            /*xla_cmp_string_pkg.*/CreateString
                   (
                     p_package_text => SUBSTR
                                          ( p_clob
                                           ,l_current_pos_in_clob
                                          )
                    ,p_array_string => l_subarray
                   );
            FOR i IN l_subarray.FIRST..l_subarray.LAST
            LOOP
               IF i > l_subarray.FIRST
               THEN
                  l_current_table_index := l_current_table_index + 1;
               END IF;
               p_varchar2s(l_current_table_index) := l_subarray(i);
            END LOOP;
         END IF;

         l_current_pos_in_clob              := l_clob_length;

      ELSIF l_next_newline_pos IS NULL
      THEN
         --probably offset > LOBMAXSIZE
         NULL;
         --raise exception
      ELSE
         IF (l_next_newline_pos - l_current_pos_in_clob + 1 )
            <= G_MAX_PACKAGE_LINE_LENGTH
         THEN
            --take the portion
            p_varchar2s(l_current_table_index) := SUBSTR
                                                  ( p_clob
                                                   ,l_current_pos_in_clob
                                                   ,l_next_newline_pos
                                                    - l_current_pos_in_clob
                                                    + 1
                                                  );
         ELSE
            /*xla_cmp_string_pkg.*/CreateString
                   (
                     p_package_text => SUBSTR
                                                  ( p_clob
                                                   ,l_current_pos_in_clob
                                                   ,l_next_newline_pos
                                                    - l_current_pos_in_clob
                                                    + 1
                                                  )
                    ,p_array_string => l_subarray
                   );
            FOR i IN l_subarray.FIRST..l_subarray.LAST
            LOOP
               IF i > l_subarray.FIRST
               THEN
                  l_current_table_index := l_current_table_index + 1;
               END IF;
               p_varchar2s(l_current_table_index) := l_subarray(i);
            END LOOP;
         END IF;

         l_current_pos_in_clob              := l_next_newline_pos + 1;

      END IF;
   END LOOP;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception   THEN
       RAISE;
   WHEN OTHERS    THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_common_pkg.clob_to_varchar2s');
END clob_to_varchar2s;



PROCEDURE varchar2s_to_clob
                    (
                      p_varchar2s     IN         DBMS_SQL.VARCHAR2S
                     ,x_clob          OUT NOCOPY CLOB
                    )
IS
l_log_module                 VARCHAR2 (2000);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.varchar2s_to_clob';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   x_clob := NULL;

   IF p_varchar2s.FIRST IS NULL
   THEN
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
         (p_msg      => 'p_varchar2s is empty'
         ,p_level    => C_LEVEL_STATEMENT);
      END IF;
   ELSE
      FOR i IN p_varchar2s.FIRST..p_varchar2s.LAST
      LOOP
          x_clob := x_clob || p_varchar2s(i);
      END LOOP;
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception   THEN
       RAISE;
   WHEN OTHERS    THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_common_pkg.varchar2s_to_clob');
END varchar2s_to_clob;



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
/*
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;
*/
   --Dump the SQL command
   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      l_cur_position      := 1;
      l_next_cr_position  := 0;
      l_text_length       := LENGTH(p_text);

      WHILE l_next_cr_position < l_text_length
      LOOP
         l_next_cr_position := INSTR( p_text
                                     ,g_chr_newline
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
            ,p_level    => C_LEVEL_STATEMENT);

         IF l_cur_position < l_text_length
         THEN
            l_cur_position := l_next_cr_position + 1;
         END IF;
      END LOOP;
   END IF;
/*
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;
*/
EXCEPTION
   WHEN xla_exceptions_pkg.application_exception   THEN
       RAISE;
   WHEN OTHERS    THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_common_pkg.dump_text');
END dump_text;

PROCEDURE dump_text
                    (
                      p_text          IN  DBMS_SQL.VARCHAR2S
                    )
IS
l_log_module                 VARCHAR2 (2000);

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.dump_text';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   IF p_text.FIRST IS NULL
   THEN
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
         (p_msg      => 'p_text is empty'
         ,p_level    => C_LEVEL_STATEMENT);
      END IF;
   ELSE
      FOR i IN p_text.FIRST..p_text.LAST
      LOOP
         dump_text(p_text => p_text(i));
      END LOOP;
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception   THEN
       RAISE;
   WHEN OTHERS    THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_common_pkg.dump_text');
END dump_text;

PROCEDURE dump_text
                    (
                      p_text          IN  CLOB
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

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      l_cur_position      := 1;
      l_next_cr_position  := 0;
      l_text_length       := LENGTH(p_text);

      WHILE l_next_cr_position < l_text_length
      LOOP
         l_next_cr_position := INSTR( p_text
                                     ,g_chr_newline
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
            ,p_level    => C_LEVEL_STATEMENT);

         IF l_cur_position < l_text_length
         THEN
            l_cur_position := l_next_cr_position + 1;
         END IF;
      END LOOP;
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception   THEN
       RAISE;
   WHEN OTHERS    THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_common_pkg.dump_text');
END dump_text;


FUNCTION bool_to_char(p_boolean IN BOOLEAN)
RETURN VARCHAR2
IS
   l_log_module                 VARCHAR2 (2000);
   l_return_value               VARCHAR2 (10);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.bool_to_char';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN+END' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   l_return_value := CASE p_boolean
                        WHEN TRUE THEN 'TRUE'
                        WHEN FALSE THEN 'FALSE'
                        ELSE 'NULL'
                     END;

   RETURN l_return_value;
EXCEPTION
   WHEN xla_exceptions_pkg.application_exception   THEN
       RAISE;
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_common_pkg.bool_to_char');
END bool_to_char;


FUNCTION replace_token
                    (
                      p_original_text    IN  CLOB
                     ,p_token            IN  VARCHAR2
                     ,p_replacement_text IN  CLOB
                    )
RETURN CLOB
IS
   l_found_position    INTEGER;

   l_return_value      CLOB;

   l_log_module        VARCHAR2 (2000);

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.dump_text';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   --Copy the original clob into a local variable
   l_return_value   := p_original_text;

   --Start a loop since the token might appear multiple times
   LOOP
      --Find the first occurrence of the token
      l_found_position := INSTR(l_return_value, p_token);

      --If not found exit
      IF    l_found_position = 0
         OR l_found_position IS NULL
      THEN
         EXIT;
      END IF;

      --Extract the portions around the token and embed the replacement
      l_return_value := SUBSTR( l_return_value
                               ,1
                               ,l_found_position - 1
                              )
                     || p_replacement_text
                     || SUBSTR( l_return_value
                               ,l_found_position + LENGTH(p_token)
                              );
   END LOOP;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   RETURN l_return_value;
EXCEPTION
   WHEN xla_exceptions_pkg.application_exception   THEN
       RAISE;
   WHEN OTHERS    THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_common_pkg.replace_token');
END replace_token;


--Trace initialization
BEGIN
   g_log_level      := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   g_log_enabled    := fnd_log.test
                          (log_level  => g_log_level
                          ,module     => C_DEFAULT_MODULE);

   IF NOT g_log_enabled  THEN
      g_log_level := C_LEVEL_LOG_DISABLED;
   END IF;

END xla_cmp_common_pkg;

/
