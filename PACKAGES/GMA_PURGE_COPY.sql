--------------------------------------------------------
--  DDL for Package GMA_PURGE_COPY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMA_PURGE_COPY" AUTHID CURRENT_USER AS
/* $Header: GMAPRGCS.pls 120.1.12010000.1 2008/07/30 06:17:16 appldev ship $ */

  -- This is a drag, but we have to maintain two tables rather
  -- than one table with a composite type to provide compatability
  -- with Oracle v7.x.
  TYPE g_tablename_tab_type   IS TABLE OF user_tables.table_name%TYPE
                               INDEX BY BINARY_INTEGER;
  TYPE g_tableaction_tab_type IS TABLE OF CHAR(1)
                               INDEX BY BINARY_INTEGER;

  PROCEDURE docommit(p_purge_id          sy_purg_mst.purge_id%TYPE,
                     p_transcount IN OUT NOCOPY INTEGER);

  FUNCTION archiveengine(p_purge_id            sy_purg_mst.purge_id%TYPE,
                         p_owner               user_users.username%TYPE,
                         p_appl_short_name     fnd_application.application_short_name%TYPE,
                         p_user                NUMBER,
                         p_arcrowtablename     user_tables.table_name%TYPE,
                         p_tablecount          INTEGER,
                         p_tablename_tab       GMA_PURGE_DDL.g_tablename_tab_type,
                         p_tableaction_tab     GMA_PURGE_DDL.g_tableaction_tab_type,
                         p_debug_flag          BOOLEAN,
                         p_commitfrequency     INTEGER)
                 RETURN BOOLEAN;

END GMA_PURGE_COPY;

/
