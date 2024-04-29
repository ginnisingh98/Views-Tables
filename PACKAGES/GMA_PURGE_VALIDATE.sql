--------------------------------------------------------
--  DDL for Package GMA_PURGE_VALIDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMA_PURGE_VALIDATE" AUTHID CURRENT_USER AS
/* $Header: GMAPRGVS.pls 115.3 2002/05/15 17:05:54 pkm ship     $ */

  PROCEDURE checksql(p_purge_id   sy_purg_mst.purge_id%TYPE,
                     p_purge_type sy_purg_def.purge_type%TYPE);
                -- make sure sql stored in sy_purg_def is valid

  FUNCTION is_table(p_purge_id  sy_purg_mst.purge_id%TYPE,
                    p_tablename user_tables.table_name%TYPE) RETURN BOOLEAN;
                -- check for existence of named table

  FUNCTION is_tablespace
                   (p_purge_id        sy_purg_mst.purge_id%TYPE,
                    p_tablespace_name user_tablespaces.tablespace_name%TYPE)
         RETURN BOOLEAN;
                -- validate tablespace name

END GMA_PURGE_VALIDATE;

 

/
