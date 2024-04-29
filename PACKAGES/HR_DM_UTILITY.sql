--------------------------------------------------------
--  DDL for Package HR_DM_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_DM_UTILITY" AUTHID CURRENT_USER AS
/* $Header: perdmutl.pkh 120.0 2005/05/31 17:15:42 appldev noship $ */

--
-- Declare records
--

TYPE r_migration_rec IS RECORD (migration_type VARCHAR2(30),
                                database_location VARCHAR2(30),
                                source_database_instance VARCHAR2(30),
                                destination_database_instance VARCHAR2(30),
                                migration_id NUMBER,
                                application_id NUMBER,
                                last_migration_date DATE,
                                business_group_id NUMBER);



-- general purpose procedures
-- start

FUNCTION get_phase_status(p_phase IN VARCHAR2, p_migration_id IN NUMBER)
         RETURN VARCHAR2;
FUNCTION get_phase_id(p_phase IN VARCHAR2, p_migration_id IN NUMBER)
         RETURN NUMBER;
FUNCTION number_of_threads(p_business_group_id IN NUMBER) RETURN NUMBER;
FUNCTION chunk_size(p_business_group_id IN NUMBER) RETURN NUMBER;
PROCEDURE set_process(p_process_text IN VARCHAR2,
                      p_phase IN VARCHAR2,
                      p_migration_id IN NUMBER);


-- general purpose procedures
-- end


-- error procedures
-- start

PROCEDURE error (p_sqlcode IN NUMBER, p_procedure IN VARCHAR2,
                 p_extra IN VARCHAR2, p_rollback IN VARCHAR2 DEFAULT 'R');

-- error procedures
-- end


-- message procedures
-- start

PROCEDURE message (p_type IN VARCHAR2, p_message IN VARCHAR2,
                   p_position IN NUMBER);
PROCEDURE message_init;

-- message procedures
-- end



-- rollback procedures
-- start

PROCEDURE rollback (p_phase IN VARCHAR2,
                    p_masterslave IN VARCHAR2 DEFAULT NULL,
                    p_migration_id IN NUMBER DEFAULT NULL,
                    p_phase_item_id IN NUMBER DEFAULT NULL);
PROCEDURE rollback_range_master (p_migration_id IN NUMBER);
PROCEDURE rollback_down_aol_master (p_migration_id IN NUMBER);
PROCEDURE rollback_up_aol_master (p_migration_id IN NUMBER);
PROCEDURE rollback_download_master (p_migration_id IN NUMBER);
PROCEDURE rollback_init (p_migration_id IN NUMBER);
PROCEDURE rollback_generator (p_migration_id IN NUMBER);
PROCEDURE rollback_cleanup (p_migration_id IN NUMBER);
PROCEDURE rollback_delete (p_migration_id IN NUMBER);
PROCEDURE rollback_upload (p_migration_id IN NUMBER);

-- rollback procedures
-- end



-- update status procedures
-- start

PROCEDURE update_migrations (p_new_status IN VARCHAR2, p_id IN NUMBER);
PROCEDURE update_migration_ranges (p_new_status IN VARCHAR2,
                                   p_id IN NUMBER);
PROCEDURE update_phase_items (p_new_status IN VARCHAR2, p_id IN NUMBER);
PROCEDURE update_phases (p_new_status IN VARCHAR2, p_id IN NUMBER);

-- update status procedures
-- end


--
end hr_dm_utility;

 

/
