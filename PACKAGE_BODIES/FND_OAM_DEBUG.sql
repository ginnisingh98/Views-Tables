--------------------------------------------------------
--  DDL for Package Body FND_OAM_DEBUG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_OAM_DEBUG" as
/* $Header: AFOAMDBGB.pls 120.5 2005/10/14 15:00 ilawler noship $ */

   ----------------------------------------
   -- Private Body Constants
   ----------------------------------------
   PKG_NAME                     CONSTANT VARCHAR2(20) := 'DEBUG.';
   B_DEFAULT_FILE_PREFIX        CONSTANT VARCHAR2(20) := 'fnd_oam_debug';

   -- State variables
   b_log_level                  NUMBER                  := NULL;   --defaulting to NULL allows fnd_log's level to be used by default
   b_include_timestamp          BOOLEAN                 := FALSE;
   b_use_indentation            BOOLEAN                 := FALSE;
   b_indent_level               NUMBER                  := 0;
   b_fd                         UTL_FILE.FILE_TYPE;

   --store what styles are enabled
   b_style_screen               BOOLEAN                 := FALSE;
   b_style_file                 BOOLEAN                 := FALSE;
   b_style_fnd_log              BOOLEAN                 := TRUE;  --by default, only enable fnd_log

   -- Private helper to close the log file, also turns off the "file" style
   FUNCTION CLOSE_LOG_FILE
      RETURN BOOLEAN
   IS
   BEGIN
      IF UTL_FILE.IS_OPEN(b_fd) THEN
         UTL_FILE.FCLOSE(b_fd);
      END IF;
      b_style_file := FALSE;
      b_fd := NULL;
      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN FALSE;
   END;

   -- Public
   FUNCTION INIT_LOG(p_include_timestamp        IN BOOLEAN,
                     p_use_indentation          IN BOOLEAN,
                     p_start_indent_level       IN NUMBER)
      RETURN BOOLEAN
   IS
      l_ignore BOOLEAN;
   BEGIN
      --set the state from the provided values
      b_include_timestamp := NVL(p_include_timestamp, FALSE);
      b_use_indentation := NVL(p_use_indentation, FALSE);
      b_indent_level := NVL(p_start_indent_level, 0);

      --default the rest of the state to its start position
      b_style_screen := FALSE;
      IF b_style_file THEN
         l_ignore := CLOSE_LOG_FILE;
      END IF;
      b_style_fnd_log := TRUE;

      --also reset the internal log level
      b_log_level := NULL;

      RETURN TRUE;
   END;

   -- Public
   FUNCTION FLUSH_LOG
      RETURN BOOLEAN
   IS
   BEGIN
      -- we can only flush a file
      IF b_style_file THEN
         UTL_FILE.FFLUSH(b_fd);
      END IF;
      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN FALSE;
   END;

   -- Public
   FUNCTION CLOSE_LOG
      RETURN BOOLEAN
   IS
   BEGIN
      --reset to defaults
      b_style_screen := FALSE;
      IF b_style_file THEN
         IF NOT CLOSE_LOG_FILE THEN
            RETURN FALSE;
         END IF;
      END IF;
      b_style_fnd_log := TRUE;

      b_include_timestamp       := FALSE;
      b_use_indentation         := FALSE;
      b_indent_level            := 0;

      b_log_level               := NULL;
      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN FALSE;
   END;

   -- Public
   FUNCTION ENABLE_STYLE_SCREEN
      RETURN BOOLEAN
   IS
   BEGIN
      b_style_screen := TRUE;
      RETURN TRUE;
   END;

   -- Private helper to actually dump a string to a log file.
   PROCEDURE LOG_FILE_WRITE(s           IN VARCHAR2,
                            p_flush     IN BOOLEAN)
   IS
   BEGIN
      UTL_FILE.PUT_LINE(b_fd, s);
      IF (p_flush) THEN
         UTL_FILE.FFLUSH(b_fd);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         null;
   END;

   -- Public
   FUNCTION ENABLE_STYLE_FILE(p_file_name_prefix        IN VARCHAR2 DEFAULT NULL,
                              p_include_unique_suffix   IN BOOLEAN DEFAULT NULL,
                              p_write_header            IN BOOLEAN DEFAULT NULL)
      RETURN BOOLEAN
   IS
      l_ignore  BOOLEAN;
      l_prefix  VARCHAR2(512) := p_file_name_prefix;
      l_suffix  VARCHAR2(512) := '';
      l_tmp_dir VARCHAR2(512);
      l_name    VARCHAR2(2048);
   BEGIN
      --if style file is already enabled, close the current file
      IF b_style_file THEN
         l_ignore := CLOSE_LOG_FILE;
      END IF;

      --get the directory where we can write
      SELECT value
         INTO l_tmp_dir
         FROM V$PARAMETER
         WHERE name = 'utl_file_dir';

      IF l_tmp_dir IS NULL THEN
         RETURN FALSE;
      END IF;

      --get the first directory
      IF instr(l_tmp_dir,',') > 0 THEN
         l_tmp_dir := substr(l_tmp_dir,
                             1,
                             instr(l_tmp_dir,',')-1);
      END IF;

      --create the file name using the prefix and suffix
      IF p_file_name_prefix IS NULL THEN
         l_prefix := B_DEFAULT_FILE_PREFIX;
      END IF;
      IF p_include_unique_suffix IS NOT NULL AND p_include_unique_suffix THEN
         SELECT substr(round(to_char(systimestamp, 'FF'),-5),1,4)
            INTO l_suffix
            FROM DUAL;
      END IF;
      l_name := l_prefix||l_suffix||'.txt';

      --issue the file open API
      b_fd := UTL_FILE.FOPEN(l_tmp_dir,
                             l_name,
                             'w');

      --Yields GSCC warning, ignore
      dbms_output.put_line('FND_OAM_DEBUG: Opened File Log: ('||l_tmp_dir||'/'||l_name||')');

      b_style_file := TRUE;

      --if we're writing a header, go ahead and do that.
      IF p_write_header THEN
         LOG_FILE_WRITE('## Opened ('||to_char(SYSDATE, 'YYYY/MM/DD HH24:MI:SS')||')',
                        TRUE);
      END IF;
      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN FALSE;
   END;

   -- Public
   FUNCTION ENABLE_STYLE_FND_LOG
      RETURN BOOLEAN
   IS
   BEGIN
      b_style_fnd_log := TRUE;
      RETURN TRUE;
   END;

   -- Public
   FUNCTION DISABLE_STYLE(p_style       IN VARCHAR2)
      RETURN BOOLEAN
   IS
      l_bool    BOOLEAN := TRUE;
   BEGIN
      CASE p_style
         WHEN STYLE_SCREEN THEN
            b_style_screen := FALSE;
         WHEN STYLE_FILE THEN
            l_bool := CLOSE_LOG_FILE;
         WHEN STYLE_FND_LOG THEN
            b_style_fnd_log := FALSE;
         ELSE
            RETURN FALSE;
      END CASE;
      RETURN l_bool;
   END;

   -- Public
   FUNCTION TEST(p_level        IN NUMBER,
                 p_module       IN VARCHAR2)
      RETURN BOOLEAN
   IS
   BEGIN
      --if our internal log level is null, look elsewhere for a level
      IF b_log_level IS NULL THEN
         --try to defer to fnd_log
         IF b_style_fnd_log THEN
            RETURN (p_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL);
         END IF;
      ELSE
         RETURN p_level >= b_log_level;
      END IF;
      RETURN TRUE;
   END;

   -- Public
   PROCEDURE SET_LOG_LEVEL(p_level      IN NUMBER)
   IS
   BEGIN
      b_log_level := p_level;
   END;

   -- Public
   PROCEDURE SET_INDENT_LEVEL(p_level   IN NUMBER)
   IS
   BEGIN
      b_indent_level := p_level;
   END;

   -- Private, indents the log only when indentation is enabled
   PROCEDURE LOG_INDENT
   IS
   BEGIN
      IF b_use_indentation THEN
         b_indent_level := b_indent_level + 1;
      END IF;
   END;

   -- Private, outdents the log only when indentation is enabled
   PROCEDURE LOG_OUTDENT
   IS
   BEGIN
      IF b_use_indentation AND b_indent_level > 0 THEN
         b_indent_level := b_indent_level - 1;
      END IF;
   END;

   -- Private, helper to compute the leading underscore string representing
   -- indentation for a line.  Uses underscore instead of space because dbms_output
   -- trims leading spaces.
   FUNCTION MAKE_INDENT_STR
      RETURN VARCHAR2
   IS
      l_str VARCHAR2(2048) := '';
   BEGIN
      RETURN SUBSTR(RPAD(' ', b_indent_level+1, '_'), 2);
   END;

   -- Computes the change in the indent level based on certain well known strings triggering
   -- indent and outdent.
   FUNCTION COMPUTE_INDENT_CHANGE(s IN VARCHAR2)
      RETURN NUMBER
   IS
      l_retval  NUMBER := NULL;
      l_s       VARCHAR2(2048) := upper(s);
   BEGIN
      IF l_s = 'ENTER' THEN
         l_retval := 1;
      ELSIF l_s = 'EXIT' THEN
         l_retval := -1;
      END IF;

      RETURN l_retval;
   END;

   -- Private, internal API that triggers the actual different logs to log the string in their
   -- proper formats.
   -- Invariant: assumes TEST has already been called
   PROCEDURE INTERNAL_LOG(p_level               IN NUMBER,
                          p_ctxt                IN VARCHAR2,
                          s                     IN VARCHAR2)
   IS
      l_indent_change   NUMBER;
      l_s               VARCHAR2(32767);
      l_now             TIMESTAMP;
   BEGIN
      IF b_use_indentation THEN
         l_indent_change := COMPUTE_INDENT_CHANGE(s);
         IF l_indent_change IS NOT NULL AND l_indent_change > 0 THEN
            b_indent_level := b_indent_level + l_indent_change;
         END IF;
      END IF;

      --prep it
      --note: if you round the systimestamp time fraction, you lose leading zeroes, easier to just trim
      IF NOT b_include_timestamp AND NOT b_use_indentation THEN
         l_s := s;
      ELSIF b_include_timestamp AND b_use_indentation THEN
         SELECT systimestamp
            INTO l_now
            FROM DUAL;
         l_s := MAKE_INDENT_STR||'('||to_char(l_now, 'HH24:MI:SS')||'.'||substr(to_char(l_now, 'FF'),1,4)||')['||p_ctxt||']('||p_level||'): "'||s||'"';
      ELSIF b_include_timestamp THEN
         SELECT systimestamp
            INTO l_now
            FROM DUAL;
         l_s := '('||to_char(l_now, 'HH24:MI:SS')||'.'||substr(to_char(l_now, 'FF'),1,4)||')['||p_ctxt||']('||p_level||'): "'||s||'"';
      ELSIF b_use_indentation THEN
         l_s := MAKE_INDENT_STR||'['||p_ctxt||']('||p_level||'): "'||s||'"';
      END IF;

      --log it
      IF b_style_fnd_log THEN
         --For GSCC compliance, check against constant instead of calling PL/SQL function
         --Needs to be present even though we have a TEST function
         IF (p_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(p_level,
                           p_ctxt,
                           s);
         END IF;
      END IF;
      IF b_style_file THEN
         LOG_FILE_WRITE(l_s,
                        TRUE);
      END IF;
      IF b_style_screen THEN
         --Yields GSCC warning, ignore
         dbms_output.put_line(l_s);
      END IF;

      IF b_use_indentation AND l_indent_change IS NOT NULL AND l_indent_change < 0 THEN
         b_indent_level := b_indent_level + l_indent_change;
      END If;
   EXCEPTION
      WHEN OTHERS THEN
         --dbms_output.put_line('internal_log failed');
         NULL;
   END;

   -- Public
   PROCEDURE LOG(p_string IN VARCHAR2)
   IS
   BEGIN
      IF TEST(1,
              NULL) THEN
         INTERNAL_LOG(1,
                      NULL,
                      p_string);
      END IF;
   END;

   -- Public
   PROCEDURE LOG(p_level        IN NUMBER,
                 p_context      IN VARCHAR2,
                 p_string       IN VARCHAR2)
   IS
   BEGIN
      IF TEST(p_level,
              p_context) THEN
         INTERNAL_LOG(p_level,
                      p_context,
                      p_string);
      END IF;
   END;

   -- Public
   PROCEDURE LOGSTAMP(p_string IN VARCHAR2)
   IS
      l_prev_include_timestamp BOOLEAN := b_include_timestamp;
   BEGIN
      IF TEST(1,
              NULL) THEN
         b_include_timestamp := TRUE;
         INTERNAL_LOG(1,
                      NULL,
                      p_string);
         b_include_timestamp := l_prev_include_timestamp;
      END IF;
   END;

END FND_OAM_DEBUG;

/
