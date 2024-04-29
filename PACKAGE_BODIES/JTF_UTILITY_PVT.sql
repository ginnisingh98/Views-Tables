--------------------------------------------------------
--  DDL for Package Body JTF_UTILITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_UTILITY_PVT" as
/* $Header: jtfgutlb.pls 120.1 2005/07/02 00:44:54 appldev ship $ */

/****************************************************************************/
-- FUNCTION
--   check_fk_exists
-- HISTORY
------------------------------------------------------------------------------
FUNCTION check_fk_exists
(
  p_table_name                 IN VARCHAR2,
  p_pk_name                    IN VARCHAR2,
  p_pk_value                   IN VARCHAR2,
  p_pk_data_type               IN NUMBER := g_number,
  p_additional_where_clause    IN VARCHAR2 := NULL
)
RETURN VARCHAR2
IS

  l_sql      VARCHAR2(4000);
  l_count    NUMBER;

BEGIN

  l_sql := 'SELECT COUNT(*) FROM ' || p_table_name;
  l_sql := l_sql || ' WHERE ' || p_pk_name || ' = ';

  IF p_PK_data_type = g_varchar2 THEN
    l_sql := l_sql || '''' || p_pk_value || '''';
  ELSE
    l_sql := l_sql || p_pk_value;
  END IF;

  IF p_additional_where_clause IS NOT NULL THEN
    l_sql := l_sql || ' AND ' || p_additional_where_clause;
  END IF;

  debug_message('SQL statement: '||l_sql);
  EXECUTE IMMEDIATE l_sql INTO l_count;

  IF l_count = 0 THEN
    RETURN FND_API.g_false;
  ELSE
    RETURN FND_API.g_true;
  END IF;

END check_fk_exists;


/****************************************************************************/
-- FUNCTION
--   check_uniqueness
-- HISTORY
------------------------------------------------------------------------------
FUNCTION check_uniqueness
(
  p_table_name      IN VARCHAR2,
  p_where_clause    IN VARCHAR2
)
RETURN VARCHAR2
IS

  l_sql       VARCHAR2(4000);
  l_count     NUMBER;

BEGIN

  l_sql := 'SELECT COUNT(*) FROM ' || p_table_name;
  l_sql := l_sql || ' WHERE ' || p_where_clause;

  debug_message('SQL statement: '||l_sql);
  EXECUTE IMMEDIATE l_sql INTO l_count;

  IF l_count = 0 THEN
    RETURN FND_API.g_true;
  ELSE
    RETURN FND_API.g_false;
  END IF;

END check_uniqueness;


/****************************************************************************/
-- PROCEDURE
--   debug_message
-- HISTORY
------------------------------------------------------------------------------
PROCEDURE debug_message
(
  p_message_text     IN  VARCHAR2,
  p_message_level    IN  NUMBER := FND_MSG_PUB.g_msg_lvl_debug_high
)
IS
BEGIN

  IF FND_MSG_PUB.check_msg_level(p_message_level) THEN
    FND_MESSAGE.set_name('JTF', 'JTF_API_DEBUG_MESSAGE');
    FND_MESSAGE.set_token('TEXT', p_message_text);
    FND_MSG_PUB.add;
  END IF;
END debug_message;

---------------------------------------------------------------------
-- PROCEDURE
--    display_messages
-- HISTORY
--    11/26/99    juliu    Created.
---------------------------------------------------------------------
PROCEDURE display_messages
IS
  l_count  NUMBER;
  l_msg    VARCHAR2(2000);
BEGIN
  l_count := FND_MSG_PUB.count_msg;
  FOR i IN 1 .. l_count LOOP
    l_msg := FND_MSG_PUB.get(i, FND_API.g_false);
    --DBMS_OUTPUT.put_line('(' || i || ') ' || l_msg);
  END LOOP;
END display_messages;

END JTF_Utility_PVT;

/
