--------------------------------------------------------
--  DDL for Package GMA_PURGE_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMA_PURGE_UTILITIES" AUTHID CURRENT_USER AS
/* $Header: GMAPRGUS.pls 115.3 2002/05/15 17:05:51 pkm ship     $ */

   -- print a long variable to log
  PROCEDURE printlong(p_purge_id sy_purg_mst.purge_id%TYPE,
                      p_text sy_purg_def.sqlstatement%TYPE);

  -- construct tablename for target and temp tables
  FUNCTION makearcname(p_purge_id sy_purg_mst.purge_id%TYPE,
                       p_sourcetable user_tables.table_name%TYPE)
                  RETURN user_tables.table_name%TYPE;

  -- print a line of stars to log
  PROCEDURE printline(p_purge_id sy_purg_mst.purge_id%TYPE);

  -- print passed text if p_debug_flag is TRUE
  PROCEDURE printdebug(p_purge_id   sy_purg_mst.purge_id%TYPE,
                       p_text       sy_purg_def.sqlstatement%TYPE,
                       p_debug_flag BOOLEAN);

  -- print timestamp if p_debug_flag is TRUE
  PROCEDURE debugtime(p_purge_id   sy_purg_mst.purge_id%TYPE,
                      p_debug_flag BOOLEAN);

  -- return character representation of HH24:MI:SS named date
  FUNCTION chartime RETURN     VARCHAR2;

END GMA_PURGE_UTILITIES;

 

/
