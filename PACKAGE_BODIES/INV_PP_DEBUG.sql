--------------------------------------------------------
--  DDL for Package Body INV_PP_DEBUG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_PP_DEBUG" AS
/* $Header: INVPPDGB.pls 120.1 2005/06/07 18:40:08 appldev  $ */
g_debug_mode       NUMBER  	    := g_debug_mode_no;
g_last_dynamic_sql long    	    := NULL ;
g_last_error_pos   NUMBER           := -1;
g_last_error_msg   long             := NULL;
g_pipename         VARCHAR2(1000)   := NULL;
g_line_feed        VARCHAR2(1) :='
';
PROCEDURE set_debug_mode(p_mode IN NUMBER) IS
BEGIN
   IF p_mode IN (g_debug_mode_yes, g_debug_mode_no) THEN
      g_debug_mode := p_mode;
   END IF;
END set_debug_mode;
--
FUNCTION IS_debug_mode RETURN BOOLEAN IS
BEGIN
   RETURN (g_debug_mode = g_debug_mode_yes);
END is_debug_mode;
--
PROCEDURE set_last_dynamic_sql(p_sql IN long) IS
BEGIN
   g_last_dynamic_sql := p_sql;
END set_last_dynamic_sql;
--
FUNCTION  get_last_dynamic_sql RETURN long IS
BEGIN
   RETURN g_last_dynamic_sql;
END get_last_dynamic_sql;
--
PROCEDURE set_last_error_message(p_error_msg IN long) IS
BEGIN
   g_last_error_msg := p_error_msg;
END set_last_error_message;
--
FUNCTION  get_last_error_message RETURN long IS
BEGIN
   RETURN g_last_error_msg;
END get_last_error_message;
--
PROCEDURE set_last_error_position(p_error_pos IN NUMBER) IS
BEGIN
   g_last_error_pos := p_error_pos;
END set_last_error_position;
--
FUNCTION  get_last_error_position RETURN NUMBER IS
BEGIN
   RETURN g_last_error_pos;
END get_last_error_position;
--
PROCEDURE set_debug_pipe_name(p_pipename IN VARCHAR2) IS
BEGIN
   g_pipename := p_pipename;
END set_debug_pipe_name;
--
PROCEDURE send_message_to_pipe(p_message IN VARCHAR2) IS
   l_rval NUMBER;
BEGIN
   IF g_debug_mode <> g_debug_mode_yes OR
     g_pipename IS NULL THEN
      RETURN;
   END IF;
   -- bug # 3133781
   /*
   dbms_pipe.pack_message(p_message||g_line_feed);
   l_rval := dbms_pipe.send_message(g_pipename, 120, 10000000);
   dbms_pipe.pack_message('.'); -- message ending symbol
   l_rval := dbms_pipe.send_message(g_pipename, 120, 10000000);
  */
   RETURN;
END send_message_to_pipe;
--
PROCEDURE send_long_to_pipe(p_message IN long ) IS
    p_n NUMBER;
    p_v VARCHAR2(1);
    l_buf VARCHAR2(4096);
    l_line_size INTEGER;
BEGIN
   IF g_debug_mode <> g_debug_mode_yes OR
     g_pipename IS NULL THEN
      RETURN;
   END IF;
   l_line_size := 0;
   FOR p_n IN 1..LENGTH(p_message) LOOP
      p_v := Substr(p_message,p_n,1);
      l_line_size := l_line_size +1;
      if (p_v = g_line_feed OR l_line_size > 250)
	AND l_buf IS NOT NULL THEN
	send_message_to_pipe(l_buf);
	l_buf := NULL;
	l_line_size := 0;
     ELSE
	IF l_buf IS NULL THEN
         l_buf := p_v;
        ELSE
         l_buf := l_buf || p_v;
        END IF;
      END IF;
   END LOOP;
   IF l_buf IS NOT NULL THEN
      send_message_to_pipe(l_buf);
   END IF;
END send_long_to_pipe;
PROCEDURE send_last_dynamic_sql IS
BEGIN
  IF g_debug_mode <> g_debug_mode_yes OR
    g_pipename IS NULL THEN
      RETURN;
  END IF;
  send_message_to_pipe('last dynamic sql is ');
  send_long_to_pipe(g_last_dynamic_sql);
END send_last_dynamic_sql;
PROCEDURE send_last_error_position IS
BEGIN
  IF g_debug_mode <> g_debug_mode_yes OR
    g_pipename IS NULL THEN
     RETURN;
  END IF;
  send_message_to_pipe('last error position is '||g_last_error_pos);
END send_last_error_position;
PROCEDURE send_last_error_message IS
BEGIN
  IF g_debug_mode <> g_debug_mode_yes OR
    g_pipename IS NULL THEN
     RETURN;
  END IF;
  send_message_to_pipe('last error message is '||g_last_error_msg);
END send_last_error_message;
--
FUNCTION receive
  (  p_pipename      IN  VARCHAR2
   , x_message       OUT NOCOPY VARCHAR2
   ) RETURN NUMBER IS
      l_rval NUMBER := NULL;
BEGIN
   l_rval := dbms_pipe.receive_message(p_pipename, 30);
   IF l_rval = 0 THEN
      dbms_pipe.unpack_message(x_message);
    ELSE
      x_message := NULL;
   END IF;
   --dbms_output.put_line('l_rval '|| l_rval);
   RETURN l_rval;
END receive;
END inv_pp_debug;

/
