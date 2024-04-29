--------------------------------------------------------
--  DDL for Package FND_FLEX_DSC_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_FLEX_DSC_API" AUTHID CURRENT_USER AS
/* $Header: AFFFDAIS.pls 120.6.12010000.4 2016/03/11 22:07:44 tebarnes ship $ */

PROCEDURE set_session_mode(session_mode IN VARCHAR2);

/* restricted function. do not use! */
PROCEDURE set_validation(v_in IN BOOLEAN);
PROCEDURE debug_on;
PROCEDURE debug_off;

FUNCTION version RETURN VARCHAR2;
FUNCTION message RETURN VARCHAR2;


PROCEDURE register(appl_short_name       IN VARCHAR2,
		   flexfield_name        IN VARCHAR2,
		   title                 IN VARCHAR2,
		   description           IN VARCHAR2,
		   table_appl_short_name IN VARCHAR2,
		   table_name            IN VARCHAR2,
		   structure_column      IN VARCHAR2,
		   context_prompt        IN VARCHAR2 DEFAULT 'Context Value',
		   protected_flag        IN VARCHAR2 DEFAULT 'N',
		   enable_columns        IN VARCHAR2 DEFAULT NULL,
                   concatenated_segs_view_name IN VARCHAR2 DEFAULT NULL);


PROCEDURE enable_columns(appl_short_name  IN VARCHAR2,
			 flexfield_name   IN VARCHAR2,
			 pattern          IN VARCHAR2);


PROCEDURE setup_context_field(appl_short_name       IN VARCHAR2,
			      flexfield_name        IN VARCHAR2,
			      /* data */
			      segment_separator     IN VARCHAR2,
			      prompt    IN VARCHAR2 DEFAULT 'Context Value',
			      default_value         IN VARCHAR2,
			      reference_field       IN VARCHAR2,
			      value_required        IN VARCHAR2,
			      override_allowed      IN VARCHAR2,
			      freeze_flexfield_definition IN VARCHAR2 DEFAULT 'N',
			      context_default_type IN VARCHAR2 DEFAULT NULL,
			      context_default_value IN VARCHAR2 DEFAULT NULL,
			      context_override_value_set_nam IN VARCHAR2 DEFAULT NULL,
			      context_runtime_property_funct IN VARCHAR2 DEFAULT NULL);


PROCEDURE freeze(appl_short_name       IN VARCHAR2,
		 flexfield_name                IN VARCHAR2);


PROCEDURE create_context(
	/* identification */
	appl_short_name       IN VARCHAR2,
	flexfield_name        IN VARCHAR2,
	/* data */
	context_code          IN VARCHAR2,
	context_name          IN VARCHAR2,
        description           IN VARCHAR2,
        enabled               IN VARCHAR2,
        global_flag           IN VARCHAR2 DEFAULT 'N');


PROCEDURE create_segment(
	/* identification */
	appl_short_name         IN VARCHAR2,
	flexfield_name		IN VARCHAR2,
	context_name            IN VARCHAR2,
	/* data */
   	name			IN VARCHAR2,
	column	                IN VARCHAR2,
	description		IN VARCHAR2,
	sequence_number         IN NUMBER,
	enabled			IN VARCHAR2,
	displayed		IN VARCHAR2,
	/* validation */
	value_set		IN VARCHAR2,
	default_type		IN VARCHAR2,
	default_value		IN VARCHAR2,
	required		IN VARCHAR2,
	security_enabled	IN VARCHAR2,
	/* sizes */
	display_size		IN NUMBER,
	description_size	IN NUMBER,
	concatenated_description_size   IN NUMBER,
	list_of_values_prompt        	IN VARCHAR2,
	window_prompt	                IN VARCHAR2,
	range                           IN VARCHAR2 DEFAULT NULL,
        srw_parameter                   IN VARCHAR2 DEFAULT NULL,
	runtime_property_function       IN VARCHAR2 DEFAULT NULL);


PROCEDURE modify_segment
  (-- PK for segment
   p_appl_short_name  IN VARCHAR2,
   p_flexfield_name   IN VARCHAR2,
   p_context_code     IN VARCHAR2,
   p_segment_name     IN VARCHAR2 DEFAULT NULL,
   p_column_name      IN VARCHAR2 DEFAULT NULL,
   -- Data
   p_description      IN VARCHAR2 DEFAULT fnd_api.g_null_char,
   p_sequence_number  IN NUMBER DEFAULT fnd_api.g_null_num,
   p_enabled          IN VARCHAR2 DEFAULT fnd_api.g_null_char,
   p_displayed        IN VARCHAR2 DEFAULT fnd_api.g_null_char,
   -- Validation
   p_value_set        IN VARCHAR2 DEFAULT fnd_api.g_null_char,
   p_default_type     IN VARCHAR2 DEFAULT fnd_api.g_null_char,
   p_default_value    IN VARCHAR2 DEFAULT fnd_api.g_null_char,
   p_required         IN VARCHAR2 DEFAULT fnd_api.g_null_char,
   p_security_enabled IN VARCHAR2 DEFAULT fnd_api.g_null_char,
   -- Sizes
   p_display_size     IN NUMBER DEFAULT fnd_api.g_null_num,
   p_description_size IN NUMBER DEFAULT fnd_api.g_null_num,
   p_concat_desc_size IN NUMBER DEFAULT fnd_api.g_null_num,
   p_lov_prompt       IN VARCHAR2 DEFAULT fnd_api.g_null_char,
   p_window_prompt    IN VARCHAR2 DEFAULT fnd_api.g_null_char,
   p_range            IN VARCHAR2 DEFAULT fnd_api.g_null_char,
   p_srw_parameter    IN VARCHAR2 DEFAULT fnd_api.g_null_char,
   p_runtime_property_function IN VARCHAR2 DEFAULT fnd_api.g_null_char);



PROCEDURE create_reference_field(appl_short_name    IN VARCHAR2,
				 flexfield_name     IN VARCHAR2,
				 context_field_name IN VARCHAR2,
				 description        IN VARCHAR2);


PROCEDURE delete_flexfield(appl_short_name    IN VARCHAR2,
			   flexfield_name     IN VARCHAR2);

PROCEDURE disable_columns(appl_short_name  IN VARCHAR2,
			  flexfield_name   IN VARCHAR2,
			  pattern          IN VARCHAR2);

PROCEDURE delete_context(appl_short_name    IN VARCHAR2,
			 flexfield_name     IN VARCHAR2,
			 context            IN VARCHAR2);

/* Added for bug#5058433 */
PROCEDURE drop_DFV (p_application_short_name     IN VARCHAR2,
                    p_descriptive_flexfield_name IN VARCHAR2);

PROCEDURE update_context(
                  p_appl_short_name               IN VARCHAR2,
                  p_flexfield_name                IN VARCHAR2,
                  p_desc_flex_context_code        IN VARCHAR2,
                  p_desc_flex_context_name        IN VARCHAR2 DEFAULT NULL,
                  p_description                   IN VARCHAR2 DEFAULT NULL,
                  p_enabled_flag                  IN VARCHAR2 DEFAULT NULL,
                  p_language                      IN VARCHAR2);


PROCEDURE delete_segment(appl_short_name    IN VARCHAR2,
			 flexfield_name     IN VARCHAR2,
			 context            IN VARCHAR2,
			 segment            IN VARCHAR2);

FUNCTION flexfield_exists(appl_short_name   IN VARCHAR2,
			  flexfield_name    IN VARCHAR2) RETURN BOOLEAN;

FUNCTION context_exists(p_appl_short_name IN VARCHAR2,
			p_flexfield_name  IN VARCHAR2,
			p_context_code    IN VARCHAR2) RETURN BOOLEAN;

FUNCTION segment_exists(p_appl_short_name IN VARCHAR2,
			p_flexfield_name  IN VARCHAR2,
			p_context_code    IN VARCHAR2,
			p_segment_name    IN VARCHAR2 DEFAULT NULL,
			p_column_name     IN VARCHAR2 DEFAULT NULL) RETURN BOOLEAN;

PROCEDURE enable_context(appl_short_name    IN VARCHAR2,
			 flexfield_name     IN VARCHAR2,
			 context            IN VARCHAR2,
			 enable             IN BOOLEAN DEFAULT TRUE);

FUNCTION is_table_used(p_application_id IN fnd_tables.application_id%TYPE,
		       p_table_name     IN fnd_tables.table_name%TYPE,
		       x_message        OUT nocopy VARCHAR2) RETURN BOOLEAN;

FUNCTION is_column_used(p_application_id IN fnd_tables.application_id%TYPE,
			p_table_name     IN fnd_tables.table_name%TYPE,
			p_column_name    IN fnd_columns.column_name%TYPE,
			x_message        OUT nocopy VARCHAR2) RETURN BOOLEAN;

PROCEDURE rename_dff(p_old_application_short_name   IN   fnd_application.application_short_name%TYPE,
                     p_old_dff_name                 IN   fnd_descriptive_flexs.descriptive_flexfield_name%TYPE,
                     p_new_application_short_name   IN   fnd_application.application_short_name%TYPE,
                     p_new_dff_name                 IN   fnd_descriptive_flexs.descriptive_flexfield_name%TYPE);

PROCEDURE migrate_dff(p_application_short_name      IN   fnd_application.application_short_name%TYPE,
                      p_descriptive_flexfield_name  IN   fnd_descriptive_flexs.descriptive_flexfield_name%TYPE,
                      p_new_table_appl_short_name   IN   fnd_application.application_short_name%TYPE,
                      p_new_table_name              IN   fnd_tables.table_name%TYPE);

PROCEDURE modify_segment_null_default
  (-- PK for segment
   p_appl_short_name  IN VARCHAR2,
   p_flexfield_name   IN VARCHAR2,
   p_context_code     IN VARCHAR2,
   p_segment_name     IN VARCHAR2 DEFAULT NULL,
   p_column_name      IN VARCHAR2 DEFAULT NULL);

--
-- Remove descriptive flexfields whose base table is not registered in
-- fnd_tables.
--

PROCEDURE delete_missing_tbl_flexs ;


END fnd_flex_dsc_api;

/
