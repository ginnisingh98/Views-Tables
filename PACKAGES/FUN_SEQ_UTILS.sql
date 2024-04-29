--------------------------------------------------------
--  DDL for Package FUN_SEQ_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FUN_SEQ_UTILS" AUTHID CURRENT_USER AS
/* $Header: funsqrls.pls 120.13 2004/02/25 18:22:55 masada noship $ */

TYPE Table_Name_Rec IS RECORD(
			 application_id fnd_application.application_id%TYPE,
			 table_name     fnd_tables.table_name%TYPE);

TYPE Table_Name_Tab IS TABLE OF Table_Name_Rec INDEX BY BINARY_INTEGER;

TYPE sequence_rec_type IS RECORD (
       header_name          fun_seq_headers.header_name%TYPE,
       gapless              fun_seq_headers.gapless_flag%TYPE,
       description          fun_seq_headers.description%TYPE);

TYPE version_rec_type IS RECORD (
       version_name         fun_seq_versions.version_name%TYPE,
       initial_value        fun_seq_versions.initial_value%TYPE,
       current_value        fun_seq_versions.current_value%TYPE,
       start_date           fun_seq_versions.start_date%TYPE,
       end_date             fun_seq_versions.end_date%TYPE);

TYPE context_rec_type IS RECORD (
       application_id       fun_seq_contexts.application_id%TYPE,
       table_name           fun_seq_contexts.table_name%TYPE,
       context_type         fun_seq_contexts.context_type%TYPE,
       context_value        fun_seq_contexts.context_value%TYPE,
       event_code           fun_seq_contexts.event_code%TYPE,
       name                 fun_seq_contexts.name%TYPE,
       require_assign_flag  fun_seq_contexts.require_assign_flag%TYPE,
       date_type            fun_seq_contexts.date_type%TYPE);

TYPE assignment_rec_type IS RECORD (
       control_attribute_structure fun_seq_assignments.control_attribute_structure%TYPE,
       start_date                  fun_seq_assignments.start_date%TYPE,
       end_date                    fun_seq_assignments.end_date%TYPE);


PROCEDURE show_exception (
            p_routine IN VARCHAR2);

--
-- Standard Logging Procedures
-- To be dropped.
--
PROCEDURE Log(
            p_level        IN  NUMBER,
            p_module       IN  VARCHAR2,
            p_message_text IN  VARCHAR2);

PROCEDURE Log_Statement(
            p_module       IN  VARCHAR2,
            p_message_text IN  VARCHAR2);

PROCEDURE Log_Procedure(
            p_module       IN  VARCHAR2,
            p_message_text IN  VARCHAR2);

PROCEDURE Log_Event(
            p_module       IN  VARCHAR2,
            p_message_text IN  VARCHAR2);

PROCEDURE Log_Exception(
            p_module       IN  VARCHAR2,
            p_message_text IN  VARCHAR2);

PROCEDURE Log_Error(
            p_module       IN  VARCHAR2,
            p_message_text IN  VARCHAR2);

PROCEDURE Log_Unexpected(
            p_module       IN  VARCHAR2,
            p_message_text IN  VARCHAR2);
--
-- APIs to Create Sequencing Rules
--
PROCEDURE create_entity (
            p_application_id  	        IN  NUMBER,
            p_table_name	  	IN  VARCHAR2,
            p_entity_name               IN  VARCHAR2);

PROCEDURE create_sequencing_rule (
            p_application_id  	  IN  NUMBER,
            p_table_name          IN  VARCHAR2,
            p_context_type        IN  VARCHAR2,
            p_event_code          IN  VARCHAR2,
            p_date_type       	  IN  VARCHAR2,
            p_flex_context_code   IN  VARCHAR2);

PROCEDURE delete_entity (
            p_application_id  IN  NUMBER,
            p_table_name      IN  VARCHAR2);

PROCEDURE delete_sequencing_rule (
            p_application_id  IN  NUMBER,
            p_table_name      IN  VARCHAR2,
            p_context_type    IN  VARCHAR2,
            p_event_code      IN  VARCHAR2,
            p_date_type       IN  VARCHAR2);

PROCEDURE update_entity (
            p_application_id  	        IN  NUMBER,
	          p_table_name                IN  VARCHAR2,
            p_entity_name               IN  VARCHAR2);

FUNCTION is_context_type_valid (
           p_context_type  IN VARCHAR2) RETURN BOOLEAN;

FUNCTION is_event_valid (
           p_event IN VARCHAR2) RETURN BOOLEAN;

FUNCTION is_date_type_valid (
           p_date_type IN VARCHAR2) RETURN BOOLEAN;

FUNCTION is_lookup_valid (
           p_lookup_type IN VARCHAR2,
           p_lookup_code IN VARCHAR2) RETURN BOOLEAN;

FUNCTION is_table_name_valid (
           p_application_id  IN  NUMBER,
           p_table_name      IN  VARCHAR2) RETURN BOOLEAN;

FUNCTION find_table_name_in_cache (
           p_table_name_rec IN Table_Name_Rec) RETURN BINARY_INTEGER;

FUNCTION find_table_name_in_db (
           p_table_Name_rec IN Table_Name_Rec) RETURN BOOLEAN;

FUNCTION is_seq_entity_registered (
           p_application_id IN  NUMBER,
           p_table_name     IN  VARCHAR2) RETURN BOOLEAN;

--
-- Create Sequencing Setup Data
--
-- PROCEDURE create_setup_data
--
PROCEDURE create_setup_data (
            p_sequence_rec     IN sequence_rec_type,
            p_version_rec      IN version_rec_type,
            p_context_rec      IN context_rec_type,
            p_assignment_rec   IN assignment_rec_type,
            p_owner            IN VARCHAR2,
            p_last_update_date IN VARCHAR2,
            p_custom_mode      IN VARCHAR2);

PROCEDURE create_sequence (
            p_sequence_rec     IN  sequence_rec_type,
            p_owner            IN  VARCHAR2,
            p_last_update_date IN  VARCHAR2,
            p_custom_mode      IN  VARCHAR2,
            x_seq_header_id    OUT NOCOPY NUMBER);

PROCEDURE create_version (
            p_seq_header_id    IN NUMBER,
            p_header_name      IN VARCHAR2,
            p_version_rec      IN version_rec_type,
            p_owner            IN VARCHAR2,
            p_last_update_date IN VARCHAR2,
            p_custom_mode      IN VARCHAR2);

PROCEDURE recreate_version;

PROCEDURE create_db_sequence (
            p_seq_version_id  IN NUMBER,
            p_initial_value   IN NUMBER);

PROCEDURE create_context (
            p_context_rec      IN  context_rec_type,
            p_owner            IN VARCHAR2,
            p_last_update_date IN VARCHAR2,
            p_custom_mode      IN VARCHAR2,
            x_seq_context_id   OUT NOCOPY NUMBER);

PROCEDURE create_assignment (
            p_seq_context_id   IN NUMBER,
            p_seq_header_id    IN NUMBER,
            p_assignment_rec   IN assignment_rec_type,
            p_owner            IN VARCHAR2,
            p_last_update_date IN VARCHAR2,
            p_custom_mode      IN VARCHAR2);

PROCEDURE delete_sequence (
            p_header_name   IN VARCHAR2);

PROCEDURE delete_context (
            p_context_name  IN VARCHAR2);

PROCEDURE obsolete_version (
            p_seq_version_id IN NUMBER);

PROCEDURE get_active_version (
            p_header_name     IN  VARCHAR2,
            x_seq_header_id   OUT NOCOPY NUMBER,
            x_seq_version_id  OUT NOCOPY NUMBER,
            x_version_rec     OUT NOCOPY version_rec_type);

FUNCTION get_max_number RETURN NUMBER;

END fun_seq_utils;

 

/
