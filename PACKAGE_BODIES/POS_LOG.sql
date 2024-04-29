--------------------------------------------------------
--  DDL for Package Body POS_LOG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_LOG" AS
/*$Header: POSLOGB.pls 120.2 2006/02/20 11:43:06 bitang noship $ */

-- This procedure returns the combined messages in fnd_msg_pub
PROCEDURE combine_fnd_msg
  (p_msg_count IN  NUMBER,
   x_msg_data  OUT nocopy VARCHAR2
   )
  IS
     l_msg VARCHAR2(4000);
BEGIN
   FOR l_idx IN 1..p_msg_count LOOP
      x_msg_data := x_msg_data || ' ' || fnd_msg_pub.get(l_idx);
   END LOOP;
END combine_fnd_msg;

-- This procedure logs the return status, msg count and msg data.
-- p_prefix will be used as the prefix of the logged message
PROCEDURE log_call_result
  (p_module        IN VARCHAR2,
   p_prefix        IN VARCHAR2,
   p_return_status IN VARCHAR2,
   p_msg_count     IN NUMBER,
   p_msg_data      IN VARCHAR2,
   p_name1         IN VARCHAR2 DEFAULT NULL,
   p_value1        IN VARCHAR2 DEFAULT NULL,
   p_name2         IN VARCHAR2 DEFAULT NULL,
   p_value2        IN VARCHAR2 DEFAULT NULL,
   p_name3         IN VARCHAR2 DEFAULT NULL,
   p_value3        IN VARCHAR2 DEFAULT NULL
   )
  IS
     l_level NUMBER;
     l_msg   VARCHAR2(4000);
BEGIN

   IF p_return_status = fnd_api.g_ret_sts_success THEN
      l_level := fnd_log.level_statement;
    ELSE
      l_level := fnd_log.level_error;
   END IF;

   IF l_level >= fnd_log.g_current_runtime_level THEN
      fnd_log.string (l_level
                      , p_module
                      , p_prefix || ' return status ' || p_return_status
                      || ' msg count ' || p_msg_count
                      || ' msg data ' || p_msg_data
                      );

      IF p_msg_count > 1 THEN
         combine_fnd_msg(p_msg_count, l_msg);
         fnd_log.string(l_level
                        , p_module
                        , p_prefix
                        || ' combined msg data ' || l_msg
                        );
      END IF;

   END IF;

   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      l_msg := NULL;

      IF p_name1 IS NOT NULL THEN
	 l_msg := p_name1 || '=' || p_value1;
      END IF;

      IF p_name2 IS NOT NULL THEN
	 l_msg := ', ' || p_name2 || '=' || p_value2;
      END IF;

      IF p_name3 IS NOT NULL THEN
	 l_msg := ', ' || p_name3 || '=' || p_value3;
      END IF;

      IF l_msg IS NOT NULL THEN
	 -- the following if statement is not needed but we added
	 -- it so that the GSCC checker will not compaint
	 IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
	    fnd_log.string(fnd_log.level_statement,
			   p_module,
			   p_prefix || ' name values: ' || l_msg
			   );
	 END IF;
      END IF;
   END IF;

END log_call_result;

-- This procedure logs the current value of sqlerrm
PROCEDURE log_sqlerrm
  (p_module        IN VARCHAR2,
   p_prefix        IN VARCHAR2
   )
  IS
BEGIN
   IF fnd_log.level_error >= fnd_log.g_current_runtime_level THEN
      fnd_log.string (fnd_log.level_error
                      , p_module
                      , p_prefix || ' sqlerrm is ' || Sqlerrm
                      );
   END IF;
END log_sqlerrm;

-- Warning: The following 3 procedures/function should be used together
-- Please read the instruction carefully before using them.
--
-- Usage: say you want to log field names and values of a plsql record type variable.
--     1. You should call set_msg_prefix so that your logs will share the common prefix
--        which you can use to correlate the logs.
--     2. Then you call set_msg_module so that your logs will share the same log module
--     3. Then you call log_field for each field name, and value.
--     4. You will then call finish_log_field at the end.

PROCEDURE set_msg_prefix (p_prefix IN VARCHAR2) IS
BEGIN
   g_msg_prefix := p_prefix || ': username [' || fnd_global.user_name || '] time [' ||
     To_char(Sysdate, 'MMDDYYYY HH24:MI:SS') || ']:';
END set_msg_prefix;

PROCEDURE set_msg_module (p_module IN VARCHAR2) IS
BEGIN
   g_msg_module := p_module;
END set_msg_module;

PROCEDURE log_field
  (p_field_name   IN VARCHAR2,
   p_field_value  IN VARCHAR2
   )
  IS
BEGIN
--   IF p_field_value IS NULL THEN
  --    RETURN;
  -- END IF;

   IF Lengthb(g_msg_prefix) + Lengthb(g_msg) + 4 + Lengthb(p_field_name) + Lengthb(p_field_value) > 4000 THEN
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
	 fnd_log.string(fnd_log.level_procedure, g_msg_module, g_msg_prefix || g_msg);
      END IF;
      g_msg := NULL;
   END IF;

   g_msg := g_msg || ' ' || p_field_name || '=[' || p_field_value || ']';

END log_field;

PROCEDURE finish_log_field IS
BEGIN
   IF g_msg IS NOT NULL THEN
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
	 fnd_log.string(fnd_log.level_procedure, g_msg_module, g_msg_prefix || g_msg);
      END IF;
   END IF;

   g_msg := NULL;
   g_msg_prefix := NULL;
   g_msg_module := NULL;

END finish_log_field;

END pos_log;

/
