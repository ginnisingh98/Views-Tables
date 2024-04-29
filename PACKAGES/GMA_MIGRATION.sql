--------------------------------------------------------
--  DDL for Package GMA_MIGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMA_MIGRATION" AUTHID CURRENT_USER AS
/* $Header: GMAMIGS.pls 120.3 2005/09/15 03:45:17 kshukla noship $*/
PROCEDURE run;
FUNCTION gma_migration_start(p_app_short_name IN VARCHAR2,
                             p_mig_name IN VARCHAR2
                            ) RETURN NUMBER;

PROCEDURE gma_migration_end(l_run_id IN NUMBER);

FUNCTION get_mig_run_id(p_mig_name IN VARCHAR2) RETURN NUMBER;

FUNCTION get_mig_name(p_run_id IN NUMBER) RETURN VARCHAR2;

FUNCTION get_gma_mig_messages (p_name IN VARCHAR2, p_rowid IN ROWID)
      RETURN VARCHAR2;

PROCEDURE gma_insert_message(p_run_id           IN   NUMBER,
                             p_table_name       IN   VARCHAR2,
                             p_DB_ERROR         IN   VARCHAR2,
                             p_param1       IN   VARCHAR2,
                             p_param2       IN   VARCHAR2,
                             p_param3       IN   VARCHAR2,
                             p_param4       IN   VARCHAR2,
                             p_param5       IN   VARCHAR2,
                             p_message_token    IN   VARCHAR2,
                             p_message_type     IN   VARCHAR2,
                             p_line_no          IN   NUMBER,
                             p_position         IN   NUMBER,
                             p_base_message     IN   VARCHAR2);

END gma_migration;

 

/
