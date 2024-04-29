--------------------------------------------------------
--  DDL for Package GMA_PURGE_DDL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMA_PURGE_DDL" AUTHID CURRENT_USER AS
/* $Header: GMAPRGDS.pls 120.0.12010000.1 2008/07/30 06:17:21 appldev ship $ */

  TYPE g_tablename_tab_type       IS TABLE OF user_tables.table_name%TYPE
                                  INDEX BY BINARY_INTEGER;
  TYPE g_tablespace_name_tab_type IS TABLE OF user_tablespaces.tablespace_name%TYPE
                                  INDEX BY BINARY_INTEGER;
  TYPE g_tableaction_tab_type     IS TABLE OF CHAR(1)
                                  INDEX BY BINARY_INTEGER;
  TYPE g_statement_tab_type       IS TABLE OF user_source.text%TYPE
                                  INDEX BY BINARY_INTEGER;

  FUNCTION createarctable(p_purge_id     sy_purg_mst.purge_id%TYPE,
                          p_tablename    user_tables.table_name%TYPE,
                          p_tablespace   user_tablespaces.tablespace_name%TYPE,
                          p_owner        user_users.username%TYPE,
                          p_appl_short_name fnd_application.application_short_name%TYPE,
                          p_sizing_flag  BOOLEAN,
                          p_arctablename user_tables.table_name%TYPE,
                          p_debug_flag   BOOLEAN)
                          RETURN         BOOLEAN;

  PROCEDURE droparctable(p_purge_id sy_purg_mst.purge_id%TYPE,
                         p_owner    user_users.username%TYPE,
                         p_appl_short_name fnd_application.application_short_name%TYPE,
                         p_tablename user_tables.table_name%TYPE);

  PROCEDURE createarcviews(p_purge_id   sy_purg_mst.purge_id%TYPE,
                           p_purge_type sy_purg_def.purge_type%TYPE,
                           p_owner      user_users.username%TYPE,
                           p_appl_short_name fnd_application.application_short_name%TYPE,
                           p_debug_flag BOOLEAN);

  PROCEDURE coalescetablespace
                         (p_purge_id        sy_purg_mst.purge_id%TYPE,
                          p_tablespace_name user_tablespaces.tablespace_name%TYPE,
                          p_debug_flag      BOOLEAN);

  PROCEDURE alterconstraints
                     (p_purge_id                    sy_purg_mst.purge_id%TYPE,
                      p_tablenames_tab              g_tablename_tab_type,
                      p_tableactions_tab            g_tableaction_tab_type,
                      p_tablecount                  INTEGER,
                      p_idx_tablespace_tab   IN OUT NOCOPY g_tablespace_name_tab_type,
                      p_idx_tablespace_count IN OUT NOCOPY INTEGER,
                      p_owner                        user_users.username%TYPE,
                      p_appl_short_name              fnd_application.application_short_name%TYPE,
                      p_action                       VARCHAR2,
                      p_debug_flag                   BOOLEAN);
  -- disable or enable all constraints for named table

  PROCEDURE disableindexes(p_purge_id                sy_purg_mst.purge_id%TYPE,
                           p_tablenames_tab          g_tablename_tab_type,
                           p_tableactions_tab        g_tableaction_tab_type,
                           p_tablecount              INTEGER,
                           p_indexes_tab      IN OUT NOCOPY g_statement_tab_type,
                           p_indexcount       IN OUT NOCOPY INTEGER,
                           p_owner                   user_users.username%TYPE,
                           p_appl_short_name         fnd_application.application_short_name%TYPE,
                           p_debug_flag              BOOLEAN);

  PROCEDURE enableindexes(p_purge_id             sy_purg_mst.purge_id%TYPE,
                          p_indexes_tab          g_statement_tab_type,
                          p_indexcount           INTEGER,
                          p_idx_tablespace_tab   g_tablespace_name_tab_type,
                          p_idx_tablespace_count INTEGER,
                          p_owner                user_users.username%TYPE,
                          p_appl_short_name      fnd_application.application_short_name%TYPE,
                          p_debug_flag           BOOLEAN);

  FUNCTION tab_size(p_purge_id  sy_purg_mst.purge_id%TYPE,
                    p_tablename user_tables.table_name%TYPE,
                    p_rowcount  NUMBER,
                    p_initrans  NUMBER,
                    p_pctfree   NUMBER)
                    RETURN      NUMBER;
  -- return size of initial extent in bytes

END GMA_PURGE_DDL;

/
