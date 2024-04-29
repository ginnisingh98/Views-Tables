--------------------------------------------------------
--  DDL for Package POS_LOG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_LOG" AUTHID CURRENT_USER AS
/*$Header: POSLOGS.pls 120.2 2006/02/20 11:42:37 bitang noship $ */

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
   );

-- This procedure logs the current value of sqlerrm
PROCEDURE log_sqlerrm
  (p_module        IN VARCHAR2,
   p_prefix        IN VARCHAR2
   );

-- This procedure returns the combined messages in fnd_msg_pub
PROCEDURE combine_fnd_msg
  (p_msg_count IN  NUMBER,
   x_msg_data  OUT nocopy VARCHAR2
   );


-- Warning: The following 3 procedures/function should be used together
-- Please read the instruction carefully before using them.
--
-- Usage: say you want to log field names and values of a plsql record type variable.
--     1. You should call set_msg_prefix so that your logs will share the common prefix
--        which you can use to correlate the logs.
--     2. Then you call set_msg_module so that your logs will share the same log module
--     3. Then you call log_field for each field name, and value.
--     4. You will then call finish_log_field at the end.

g_msg        fnd_log_messages.message_text%TYPE;
g_msg_prefix VARCHAR2(200);
g_msg_module fnd_log_messages.module%TYPE;

-- set common log message prefix
PROCEDURE set_msg_prefix (p_prefix IN VARCHAR2);

-- set common log message module
PROCEDURE set_msg_module (p_module IN VARCHAR2);

-- add field name and value to log
PROCEDURE log_field
  (p_field_name   IN VARCHAR2,
   p_field_value  IN VARCHAR2
   );

-- call this procedure after logging all fields
PROCEDURE finish_log_field;

END pos_log;

 

/
