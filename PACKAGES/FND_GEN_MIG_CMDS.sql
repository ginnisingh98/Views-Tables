--------------------------------------------------------
--  DDL for Package FND_GEN_MIG_CMDS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_GEN_MIG_CMDS" AUTHID CURRENT_USER AS
/* $Header: fndpgmcs.pls 120.2 2005/07/02 03:34:18 appldev noship $ */

 PROCEDURE write_out( p_owner IN VARCHAR2,
                      p_object_type IN VARCHAR2,
                      p_mig_cmd IN VARCHAR2,
                      p_object_name IN VARCHAR2 DEFAULT NULL,
                      p_old_tablespace IN VARCHAR2 DEFAULT NULL,
                      p_new_tablespace IN VARCHAR2 DEFAULT NULL,
                      p_subobject_type IN VARCHAR2 DEFAULT 'X',
                      p_parent_owner IN VARCHAR2 DEFAULT NULL,
                      p_parent_object_name IN VARCHAR2 DEFAULT NULL,
                      p_tot_blocks IN NUMBER DEFAULT 0,
                      p_index_parallel IN VARCHAR2 DEFAULT 'NOPARALLEL',
                      p_execution_mode IN VARCHAR2 DEFAULT NULL,
                      p_partitioned IN VARCHAR2 DEFAULT 'NO',
                      p_err_text IN VARCHAR2 DEFAULT NULL,
                      p_parent_lineno IN NUMBER DEFAULT NULL,
                      x_lineno OUT  NOCOPY NUMBER);

 FUNCTION get_txn_idx_tablespace RETURN VARCHAR2;

 FUNCTION get_idx_tablespace(p_tablespace_type IN VARCHAR2,
                             p_tab_tablespace  IN VARCHAR2,
                             p_txn_idx_tablespace  IN VARCHAR2)
  RETURN VARCHAR2;

 FUNCTION get_tot_blocks ( p_owner IN VARCHAR2,
                           p_object_type IN VARCHAR2,
                           p_object_name IN VARCHAR2,
                           p_partition_name IN VARCHAR2)
  RETURN NUMBER;

 PROCEDURE gen_move_obj ( p_owner IN VARCHAR2,
                          p_obj_type IN VARCHAR2,
                          p_sub_obj_type IN VARCHAR2,
                          p_obj_name IN VARCHAR2,
                          p_partitioned IN VARCHAR2,
                          p_logging IN VARCHAR2,
                          p_old_tablespace IN VARCHAR2,
                          p_new_tablespace IN VARCHAR2,
                          p_parent_owner IN VARCHAR2 DEFAULT NULL,
                          p_parent_obj_name IN VARCHAR2 DEFAULT NULL,
                          p_parent_lineno IN NUMBER DEFAULT NULL,
                          x_execution_mode OUT  NOCOPY VARCHAR2,
                          x_lineno OUT  NOCOPY NUMBER);

 PROCEDURE gen_rebuild_idx( p_owner IN VARCHAR2,
                            p_table_name IN VARCHAR2,
                            p_parent_obj_type IN VARCHAR2,
                            p_tab_moved IN BOOLEAN,
                            p_tablespace_name IN VARCHAR2,
                            p_parent_lineno IN NUMBER,
                            p_execution_mode IN VARCHAR2,
                            p_type IN VARCHAR2 DEFAULT 'INDEX');

 FUNCTION get_iot_tablespace(p_owner IN VARCHAR2,
                             p_iot_name IN VARCHAR2)
   RETURN VARCHAR2;

 PROCEDURE gen_move_aqs (p_owner IN VARCHAR2);

-- PROCEDURE gen_move_mvlogs (p_owner IN VARCHAR2);

 PROCEDURE gen_move_mvs (p_owner IN VARCHAR2);

 PROCEDURE gen_move_longs (p_owner IN VARCHAR2,
                           p_threshold_size IN NUMBER DEFAULT NULL);

 PROCEDURE gen_move_tabs (p_owner IN VARCHAR2);

 PROCEDURE gen_migrate_schema (p_schema IN VARCHAR2,
                               p_threshold_size IN NUMBER DEFAULT NULL);

 PROCEDURE gen_alter_constraint (p_schema IN VARCHAR2);

 PROCEDURE gen_alter_trigger (p_schema IN VARCHAR2);

 PROCEDURE gen_alter_queue (p_schema IN VARCHAR2);

 PROCEDURE gen_disable_cmds (p_schema IN VARCHAR2);

-- PROCEDURE update_blk_size(p_owner IN VARCHAR2);

END fnd_gen_mig_cmds;

 

/
