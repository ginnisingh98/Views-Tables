--------------------------------------------------------
--  DDL for Package Body XLA_CMP_STRING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_CMP_STRING_PKG" AS
/* $Header: xlacpstr.pkb 120.15.12010000.2 2010/05/11 10:58:57 karamakr ship $   */
/*===========================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| PACKAGE NAME                                                               |
|     xla_cmp_string_pkg                                                     |
|                                                                            |
| DESCRIPTION                                                                |
|     This is a XLA private package, which contains all the logic required   |
|     to handle the text gcreated by the compiler                            |
|                                                                            |
| HISTORY                                                                    |
|     25-JUL-2002 K.Boussema    Created                                      |
|     19-APR-2003 K.Boussema    Included Error messages                      |
|     23-FEB-2004 K.Boussema    Made changes for the FND_LOG.                |
|     22-MAR-2004 K.Boussema    Added a parameter p_module to the TRACE calls|
|                               and the procedure.                           |
|     11-MAY-2004 K.Boussema    Removed the call to XLA trace routine from   |
|                               trace() procedure                            |
|     21-Sep-2004 S.Singhania   Replaced long VARCHAR2 variables with CLOB.  |
|                               Added routine replace_token to handle REPLACE|
|                                 in CLOB variables.                         |
|     01-Oct-2004 S.Singhania   Bug 3918467: Modfied the logic in the routine|
|                                 CreateString to improve the performance.   |
|     21-Jun-2005 S.Singhania   Bug 4444678. Modified replace_token routine. |
|                                 The code uses iterative calls to iteself   |
|                                 instead of unconditional looping.          |
|     21-Jul-2006 A.Wan         Bug 5403943: replace SUBSTR with SUBSTRB and |
|                                 INSTR with INSTRB, except for SUBSTR of    |
|                                 CLOB.                                      |
+===========================================================================*/
--+==========================================================================+
--|                                                                          |
--| OVERVIEW of private procedures and functions                             |
--|                                                                          |
--+==========================================================================+
--
g_Max_line            CONSTANT NUMBER        := 255;
g_chr_quote           CONSTANT VARCHAR2(9)   :='''';
g_chr_space           CONSTANT VARCHAR2(9)   :=' ';
g_chr_newline         CONSTANT VARCHAR2(10)  := xla_environment_pkg.g_chr_newline;
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
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.xla_cmp_string_pkg';

g_log_level           NUMBER;
g_log_enabled         BOOLEAN;

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
             (p_location   => 'xla_cmp_string_pkg.trace');
END trace;

--+==========================================================================+
--|                                                                          |
--| PUBLIC Function                                                          |
--|                                                                          |
--+==========================================================================+
--
FUNCTION  ConcatTwoStrings (
                   p_array_string_1           IN DBMS_SQL.VARCHAR2S
                  ,p_array_string_2           IN DBMS_SQL.VARCHAR2S
)
RETURN DBMS_SQL.VARCHAR2S
IS
l_array_string       DBMS_SQL.VARCHAR2S;
l_Index              BINARY_INTEGER;
l_log_module         VARCHAR2(240);
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.ConcatTwoStrings';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of ConcatTwoStrings'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
IF (C_LEVEL_STATEMENT >= g_log_level) THEN

      trace
         (p_msg      => 'LENGTH string 1 = '||p_array_string_1.COUNT
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

      trace
         (p_msg      => 'LENGTH string 2 = '||p_array_string_2.COUNT
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

END IF;
--
l_array_string := p_array_string_1;
--
IF p_array_string_2.COUNT > 0 THEN
--
  l_Index        := NVL(l_array_string.LAST,0);
  --
  FOR Idx IN p_array_string_2.FIRST .. p_array_string_2.LAST LOOP
  --
    IF p_array_string_2.EXISTS(Idx) THEN
    --
      l_Index                 := l_Index + 1;
      l_array_string(l_Index) := p_array_string_2(Idx);
    --
    END IF;
  --
  END LOOP;
  --
END IF;
--
IF (C_LEVEL_STATEMENT >= g_log_level) THEN

      trace
         (p_msg      => 'LENGTH result = '||l_array_string.COUNT
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of ConcatTwoStrings'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
RETURN l_array_string;
--
EXCEPTION
   WHEN xla_exceptions_pkg.application_exception   THEN
        RETURN g_null_varchar2s;
   WHEN OTHERS    THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_string_pkg.ConcatTwoStrings');
END ConcatTwoStrings;
--
--
--+==========================================================================+
--| PRIVATE procedures and functions                                         |
--|    CreateString                                                          |
--|    transforms CLOB lines (length > 255) into a list of lines not         |
--|    exceeding 255 characters                                              |
--|                                                                          |
--|    Modified this procedure to improve performance bug 3918467            |
--+==========================================================================+
--
PROCEDURE CreateString
        (p_package_text  IN  CLOB
        ,p_array_string  OUT NOCOPY DBMS_SQL.VARCHAR2S)
IS
--
l_Text                VARCHAR2(32000);
l_SubText             VARCHAR2(256);
--
l_MaxLine             NUMBER   := 255;
--
l_NewLine             BOOLEAN;
l_Literal             BOOLEAN;
l_Space               BOOLEAN;
--
l_pos                 NUMBER         ;
--
l_Idx                 BINARY_INTEGER;
l_array_string        DBMS_SQL.VARCHAR2S;
l_log_module          VARCHAR2(240);

l_clob_string        CLOB;
l_maxLength          NUMBER := 8000;
--
l_length   number;
l_iteration number;
BEGIN
--
   IF g_log_enabled THEN
         l_log_module := C_DEFAULT_MODULE||'.CreateString';
   END IF;
   --
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

         trace
            (p_msg      => 'BEGIN of CreateString'
            ,p_level    => C_LEVEL_PROCEDURE
            ,p_module   => l_log_module);

   END IF;
   --

    l_clob_string := p_package_text;

    l_pos       := 0;
    l_NewLine   := FALSE;
    l_Literal   := FALSE;
    l_Space     := FALSE;
    l_Idx       := 0;

    --

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
            (p_msg      => 'Begin looping....'
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
   END IF;
   WHILE length(l_clob_string) > 0 LOOP
      l_text := substr(l_clob_string,1,l_maxLength);

       WHILE ( LENGTH(l_Text) >= l_MaxLine ) LOOP
         BEGIN
            l_SubText   := SUBSTRB(l_Text,1,l_MaxLine);
            l_pos       := INSTRB(l_SubText,g_chr_newline,1,1);
            IF l_pos = 0 THEN
              l_NewLine := FALSE;
              l_pos := INSTRB(l_SubText,g_chr_quote,1,1);
              IF l_pos = 0 THEN
                l_Literal := FALSE;
                l_pos     := INSTRB(l_SubText,g_chr_space,1,1);
                l_Space   := (l_pos = 0);
              ELSE
                l_Literal := TRUE;
              END IF;
            ELSE
              l_NewLine := TRUE;
            END IF;

            IF l_newline THEN
              l_Idx                  := l_Idx + 1;
              l_array_string(l_Idx)  := SUBSTRB(l_SubText,1,l_pos);
              l_Text                 := SUBSTRB(l_Text,l_pos + 1);
            ELSIF l_Literal THEN
              l_Idx                  := l_Idx + 1;
              l_array_string(l_Idx)  := SUBSTRB(l_SubText,1,l_pos-1) || g_chr_newline;
              l_Text                 := SUBSTRB(l_Text,l_pos);
            ELSIF l_Space   THEN
              l_Idx                  := l_Idx + 1;
              l_array_string(l_Idx)  := SUBSTRB(l_SubText,1,l_pos-1) || g_chr_newline;
              l_Text                 := SUBSTRB(l_Text,l_pos + 1);
            ELSE
              l_Idx                  := l_Idx + 1;
              l_array_string(l_Idx)  := l_SubText;
              l_Text                 := SUBSTRB(l_Text,l_MaxLine + 1);
            END IF;
         END;
       END LOOP;

    IF (length(l_clob_string)-l_maxLength) >= 0 THEN
        l_clob_string := substr(l_clob_string,(l_maxLength - nvl(length(l_Text),0) + 1)); --Fix for Bug 9609429
    ELSE
       l_clob_string := NULL;
       l_Idx                 := l_Idx + 1;
       l_array_string(l_Idx) := l_Text;
    END IF;
END LOOP;
p_array_string := l_array_string;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of CreateString'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
END CreateString;
--
--+==========================================================================+
--| PRIVATE procedures and functions                                         |
--|    AddNewLine                                                          |
--|    transforms CLOB lines (length > 255) into a list of lines not         |
--|    exceeding 255 characters                                              |
--|                                                                          |
--|                                                                          |
--+==========================================================================+

PROCEDURE AddNewLine(p_array_string  IN  OUT NOCOPY DBMS_SQL.VARCHAR2S)
IS
--
l_Idx                 BINARY_INTEGER;
l_array_string        DBMS_SQL.VARCHAR2S;
l_log_module          VARCHAR2(240);
--
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.AddNewLine';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of AddNewLine'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
l_array_string := p_array_string;
--
IF l_array_string.COUNT > 0 THEN
--
  FOR Idx IN l_array_string.FIRST .. l_array_string.LAST LOOP
  --
    IF l_array_string.EXISTS(Idx) THEN
    --
      IF SUBSTR(l_array_string(Idx),LENGTH(l_array_string(Idx))) <> g_chr_newline THEN
      --
         l_array_string(Idx) := l_array_string(Idx) || g_chr_newline;
      --
      END IF;
    --
    END IF;
  --
  END LOOP;
--
END IF;
--
p_array_string := l_array_string;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of AddNewLine'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
EXCEPTION
   WHEN xla_exceptions_pkg.application_exception   THEN
       RAISE;
   WHEN OTHERS    THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_string_pkg.AddNewLine');
END AddNewLine;
--
--
--+==========================================================================+
--| PRIVATE procedures and functions                                         |
--|    truncate_lines                                                        |
--|    transforms CLOB lines (length > 255) into a list of lines not         |
--|    exceeding 255 characters, this constraint was inposed by MRC product  |
--|                                                                          |
--|                                                                          |
--+==========================================================================+
--
PROCEDURE truncate_lines(p_package_text IN OUT NOCOPY CLOB)
IS
--
--
l_Text                CLOB;
l_SubText             VARCHAR2(1024); --bug6600635 increased size to accomodate
                                                  --multibyte strings.
--
l_MaxLine             NUMBER   := g_Max_line;
--
l_NewLine             BOOLEAN;
l_Literal             BOOLEAN;
l_Space               BOOLEAN;
--
l_pos                 NUMBER         ;
--
l_Output              CLOB;
l_log_module          VARCHAR2(240);
--
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.truncate_lines';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of truncate_lines'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
--
    l_Text      := p_package_text;
    l_pos       := 0;
    l_NewLine   := FALSE;
    l_Literal   := FALSE;
    l_Space     := FALSE;
    l_Output    := NULL;
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
           l_Output               := l_Output || SUBSTR(l_SubText,1,l_pos);
           l_Text                 := SUBSTR(l_Text,l_pos + 1);
         --
         ELSIF l_Literal THEN
         --
           l_Output               := l_Output || SUBSTR(l_SubText,1,l_pos-1) || g_chr_newline;
           l_Text                 := SUBSTR(l_Text,l_pos);
         --
         ELSIF l_Space   THEN
         --
           l_Output               := l_Output || SUBSTR(l_SubText,1,l_pos-1) || g_chr_newline;
           l_Text                 := SUBSTR(l_Text,l_pos + 1);
         --
         ELSE
         --
           l_Output               := l_Output || l_SubText;
           l_Text                 := SUBSTR(l_Text,l_MaxLine + 1);
         --
         END IF;
         --
      END;
     --
    END LOOP;
--
IF LENGTH(l_Text) > 0 THEN
--
  l_Output              := l_Output|| l_Text;
--
END IF;
--
p_package_text := l_Output;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of truncate_lines'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
EXCEPTION
   WHEN xla_exceptions_pkg.application_exception   THEN
       RAISE;
   WHEN OTHERS    THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_string_pkg.truncate_lines');
END truncate_lines;
--
--+==========================================================================+
--|                                                                          |
--| PUBLIC Procedure                                                         |
--|                                                                          |
--+==========================================================================+
--
PROCEDURE DumpLines (p_array_output_string      IN DBMS_SQL.VARCHAR2S)
IS
l_array_string          DBMS_SQL.VARCHAR2S;
l_log_module            VARCHAR2(240);
BEGIN
--
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.DumpLines';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of DumpLines'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

IF p_array_output_string.COUNT > 0 THEN
 --
 FOR Idx IN p_array_output_string.FIRST .. p_array_output_string.LAST LOOP
 --
   IF p_array_output_string.EXISTS(Idx) THEN
   --
     IF (C_LEVEL_STATEMENT >= g_log_level) THEN

         trace
             (p_msg      =>  RPAD(Idx,10,' ')||' '||p_array_output_string(Idx)
             ,p_level    => C_LEVEL_STATEMENT
             ,p_module   => l_log_module);

     END IF;
   --
   END IF;
 --
 END LOOP;
 --
END IF;
--
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of DumpLines'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
EXCEPTION
   WHEN xla_exceptions_pkg.application_exception   THEN
        RAISE;
   WHEN OTHERS    THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_string_pkg.DumpLines');
END DumpLines;
--
--+==========================================================================+
--|                                                                          |
--| PUBLIC Procedure                                                         |
--|                                                                          |
--+==========================================================================+
--
FUNCTION replace_token
       (p_original_text             IN  CLOB
       ,p_token                     IN  VARCHAR2
       ,p_replacement_text          IN  CLOB)
RETURN CLOB IS
l_found_position        INTEGER;
l_return_value          CLOB;
l_log_module            VARCHAR2(240);
BEGIN
IF g_log_enabled THEN
   l_log_module := C_DEFAULT_MODULE||'.replace_token';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
   trace
      (p_msg      => 'BEGIN of replace_token'
      ,p_level    => C_LEVEL_PROCEDURE
      ,p_module   => l_log_module);
END IF;

--
-- Copy the original clob into a local variable
--
l_return_value   := p_original_text;

--
-- Find the first occurrence of the token
--
l_found_position := INSTR(l_return_value, p_token);

--
-- If not found exit
--
IF l_found_position = 0 OR l_found_position IS NULL THEN
   NULL;
ELSE
   --
   -- Extract the portions around the token and embed the replacement
   -- Bug 4444678. Used the iterative call to replace_token
   --
   l_return_value := SUBSTR(l_return_value ,1 ,l_found_position - 1) ||
                     p_replacement_text  ||
                     replace_token
                        (SUBSTR(l_return_value,l_found_position + LENGTH(p_token))
                        ,p_token
                        ,p_replacement_text);
END IF;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
   trace
      (p_msg      => 'END of replace_token'
      ,p_level    => C_LEVEL_PROCEDURE
      ,p_module   => l_log_module);
END IF;

RETURN l_return_value;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception   THEN
   RAISE;
WHEN OTHERS    THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_cmp_string_pkg.replace_token');
END replace_token;

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
--
END xla_cmp_string_pkg;

/
