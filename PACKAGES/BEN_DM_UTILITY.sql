--------------------------------------------------------
--  DDL for Package BEN_DM_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_DM_UTILITY" AUTHID CURRENT_USER AS
/* $Header: benfdmutil.pkh 120.0 2006/05/11 05:02:46 nkkrishn noship $ */

--
-- Declare records
--
TYPE r_migration_rec IS RECORD (migration_id NUMBER,
                                migration_name VARCHAR2(80),
                                input_parameter_file_name VARCHAR2(30),
                                input_parameter_file_path VARCHAR2(60),
                                data_file_name VARCHAR2(30),
                                data_file_path VARCHAR2(60),
                                database_location VARCHAR2(2),
                                last_migration_date DATE);


g_out_file_handle utl_file.file_type;

PROCEDURE rollback (p_phase IN VARCHAR2,
                    p_masterslave IN VARCHAR2 DEFAULT NULL,
                    p_migration_id IN NUMBER DEFAULT NULL,
                    p_phase_item_id IN NUMBER DEFAULT NULL);
PROCEDURE rollback_download_master (p_migration_id IN NUMBER);
PROCEDURE rollback_init (p_migration_id IN NUMBER);
PROCEDURE rollback_generator (p_migration_id IN NUMBER);
PROCEDURE rollback_upload (p_migration_id IN NUMBER);

FUNCTION number_of_threads(p_business_group_id IN NUMBER) RETURN NUMBER;
FUNCTION get_phase_status(p_phase IN VARCHAR2, p_migration_id IN NUMBER)
         RETURN VARCHAR2;
FUNCTION get_phase_id(p_phase IN VARCHAR2, p_migration_id IN NUMBER)
         RETURN NUMBER;

PROCEDURE error (p_sqlcode IN NUMBER, p_procedure IN VARCHAR2,
                 p_extra IN VARCHAR2, p_rollback IN VARCHAR2 DEFAULT 'R');

PROCEDURE message (p_type IN VARCHAR2, p_message IN VARCHAR2,
                   p_position IN NUMBER);

PROCEDURE message_init;
-- update status procedures
-- start

PROCEDURE update_migrations (p_new_status IN VARCHAR2, p_id IN NUMBER);
PROCEDURE update_phase_items (p_new_status IN VARCHAR2, p_id IN NUMBER);
PROCEDURE update_phases (p_new_status IN VARCHAR2, p_id IN NUMBER);

FUNCTION get_table_id(p_table_name IN VARCHAR2) RETURN NUMBER;
PROCEDURE seed_column_mapping (p_table_name IN VARCHAR2);
PROCEDURE seed_table_order (p_table_name IN VARCHAR2, p_order_no IN NUMBER);
PROCEDURE ins_hir (p_table_name                   varchar2,
                    p_parent_table_name            varchar2 default null,
                    p_column_name                  varchar2 default null,
                    p_parent_column_name           varchar2 default null,
                    p_parent_id_column_name        varchar2 default null,
                    p_hierarchy_type               varchar2 default 'PC');
--
end ben_dm_utility;

 

/
