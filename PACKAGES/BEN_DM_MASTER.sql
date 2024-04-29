--------------------------------------------------------
--  DDL for Package BEN_DM_MASTER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_DM_MASTER" AUTHID CURRENT_USER AS
/* $Header: benfdmdmas.pkh 120.0 2006/05/04 04:47:51 nkkrishn noship $ */


--
PROCEDURE master(p_current_phase IN VARCHAR2,
                 p_previous_phase IN VARCHAR2,
                 r_migration_data IN ben_dm_utility.r_migration_rec);
PROCEDURE spawn_slaves(p_current_phase IN VARCHAR2,
                       r_migration_data IN ben_dm_utility.r_migration_rec);
PROCEDURE report_error(p_current_phase IN VARCHAR2,
                       p_migration IN NUMBER,
                       p_error_message IN VARCHAR2,
                       p_stage IN VARCHAR2);
FUNCTION slave_status(p_current_phase IN VARCHAR2,
                      r_migration_data IN ben_dm_utility.r_migration_rec)
                      RETURN VARCHAR2;
FUNCTION work_required(p_current_phase IN VARCHAR2,
                       r_migration_data IN ben_dm_utility.r_migration_rec)
                        RETURN VARCHAR2;
PROCEDURE main_controller(errbuf OUT nocopy VARCHAR2,
                          retcode OUT nocopy NUMBER,
                          p_migration_id IN BINARY_INTEGER,
                          p_migration_name IN VARCHAR2,
                          p_input_file_path IN VARCHAR2,
                          p_input_file_name IN VARCHAR2,
                          p_output_file_path IN VARCHAR2,
                          p_output_file_name IN VARCHAR2,
                          p_migration_type IN VARCHAR2,
                          p_restart_migration_id IN NUMBER,
                          p_disable_generation IN VARCHAR2);

PROCEDURE insert_request(p_phase IN VARCHAR2,
                         p_request_id IN NUMBER,
                         p_master_slave IN VARCHAR2 DEFAULT 'S',
                         p_migration_id IN NUMBER,
                         p_phase_id IN NUMBER DEFAULT NULL,
                         p_phase_item_id IN NUMBER DEFAULT NULL);
PROCEDURE controller_init(p_migration_id IN NUMBER,
                          r_migration_data IN OUT
                                              ben_dm_utility.r_migration_rec,
                          p_request_data IN VARCHAR2);

--


end ben_dm_master;

 

/
