--------------------------------------------------------
--  DDL for Package HXT_INTERFACE_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXT_INTERFACE_UTILITIES" AUTHID CURRENT_USER AS
/* $Header: hxtinterfaceutil.pkh 120.1.12000000.4 2007/06/11 10:18:21 rchennur noship $ */
   SUBTYPE max_varchar IS VARCHAR2 (4000);

   SUBTYPE flag_varchar IS VARCHAR2 (1);

   SUBTYPE varchar_256 IS VARCHAR2 (256);

   SUBTYPE proc_name IS VARCHAR2 (72);

   SUBTYPE package_name IS VARCHAR2 (32);

   TYPE asg_type_rec IS RECORD (
      asg_type   per_all_assignments_f.assignment_type%TYPE
   );

   TYPE asg_system_status_rec IS RECORD (
      asg_system_status   per_assignment_status_types.per_system_status%TYPE
   );

   TYPE batch_info_rec IS RECORD (
      batch_ref           pay_batch_headers.batch_reference%TYPE,
      request_id          fnd_concurrent_requests.request_id%TYPE,
      business_group_id   pay_batch_headers.business_group_id%TYPE,
      free_batch_suffix   NUMBER
   );

   TYPE asg_type_table IS TABLE OF asg_type_rec
      INDEX BY BINARY_INTEGER;

   TYPE asg_system_status_table IS TABLE OF asg_system_status_rec
      INDEX BY BINARY_INTEGER;

   TYPE batch_info_table IS TABLE OF batch_info_rec
      INDEX BY BINARY_INTEGER;

   TYPE input_value_name_table IS TABLE OF pay_input_values_f.NAME%TYPE
      INDEX BY BINARY_INTEGER;

   TYPE accrual_plan_id_table IS TABLE OF pay_accrual_plans.accrual_plan_id%TYPE
      INDEX BY BINARY_INTEGER;

   TYPE bee_rec IS RECORD (
      pay_batch_line   pay_batch_lines%ROWTYPE
   );

   TYPE iv_translation_rec IS RECORD (
      lookup_code         hr_lookups.lookup_code%TYPE,
      start_date_active   hr_lookups.start_date_active%TYPE,
      end_date_active     hr_lookups.end_date_active%TYPE
   );

   TYPE iv_translation_table IS TABLE OF iv_translation_rec
      INDEX BY BINARY_INTEGER;

   TYPE primary_assignment_rec IS RECORD (
      assignment_id          per_all_assignments_f.assignment_id%TYPE,
      effective_start_date   per_all_assignments_f.effective_start_date%TYPE,
      effective_end_date     per_all_assignments_f.effective_end_date%TYPE,
      assignment_type        per_all_assignments_f.assignment_type%TYPE,
      per_system_status      per_assignment_status_types.per_system_status%TYPE
   );

   TYPE primary_assignment_table IS TABLE OF primary_assignment_rec
      INDEX BY BINARY_INTEGER;

   TYPE flex_value_rec IS RECORD (
      flex_value        fnd_flex_values.flex_value%TYPE,
      id_flex_num       fnd_id_flex_segments.id_flex_num%TYPE,
      segment_name      fnd_id_flex_segments.application_column_name%TYPE,
      validation_type   fnd_flex_value_sets.validation_type%TYPE
   );

   TYPE flex_value_table IS TABLE OF flex_value_rec
      INDEX BY BINARY_INTEGER;

   TYPE assignment_info_rec IS RECORD (
      effective_start_date   per_all_assignments_f.effective_start_date%TYPE,
      effective_end_date     per_all_assignments_f.effective_end_date%TYPE,
      assignment_number      per_all_assignments_f.assignment_number%TYPE,
      payroll_id             per_all_assignments_f.payroll_id%TYPE,
      organization_id        per_all_assignments_f.organization_id%TYPE,
      location_id            per_all_assignments_f.location_id%TYPE,
      business_group_id      per_all_assignments_f.business_group_id%TYPE,
      assignment_type        per_all_assignments_f.assignment_type%TYPE
   );

   TYPE assignment_info_table IS TABLE OF assignment_info_rec
      INDEX BY BINARY_INTEGER;

   TYPE concatenated_segment_rec IS RECORD (
      concatenated_segment   pay_cost_allocation_keyflex.concatenated_segments%TYPE
   );

   TYPE concatenated_segment_table IS TABLE OF concatenated_segment_rec
      INDEX BY BINARY_INTEGER;

   c_primary_assignment         CONSTANT flag_varchar                   := 'Y';
   c_element_context_prefix     CONSTANT VARCHAR2 (10)         := 'ELEMENT - ';
   g_wildcard                   CONSTANT VARCHAR2 (1)                   := '%';
   g_otl_batchsize_profile      CONSTANT fnd_profile_options.profile_option_name%TYPE
                                                           := 'HXT_BATCH_SIZE';
   g_per_app_id                 CONSTANT fnd_application.application_id%TYPE
                                                                        := 800;
   g_pay_app_id                 CONSTANT fnd_application.application_id%TYPE
                                                                        := 801;
   g_hxc_app_id                 CONSTANT fnd_application.application_id%TYPE
                                                                        := 809;
   g_cost_flex_code             CONSTANT fnd_id_flex_segments.id_flex_code%TYPE
                                                                     := 'COST';
   g_batch_status_transferred   CONSTANT pay_batch_headers.batch_status%TYPE
                                                                        := 'T';
   g_asg_type_employed          CONSTANT per_all_assignments_f.assignment_type%TYPE
                                                                        := 'E';
   g_element_attribute          CONSTANT hxc_mapping_components.field_name%TYPE
                                                    := 'DUMMY ELEMENT CONTEXT';
   g_cost_attribute             CONSTANT hxc_mapping_components.field_name%TYPE
                                                              := 'COSTSEGMENT';
   g_segment                    CONSTANT hxc_mapping_components.field_name%TYPE
                                                                  := 'SEGMENT';
   g_iv_attribute               CONSTANT hxc_mapping_components.field_name%TYPE
                                                               := 'INPUTVALUE';
   g_asg_id_attribute           CONSTANT hxc_mapping_components.field_name%TYPE
                                                          := 'P_ASSIGNMENT_ID';
   g_asg_num_attribute          CONSTANT hxc_mapping_components.field_name%TYPE
                                                      := 'P_ASSIGNMENT_NUMBER';
   g_otl_info_types_ddf         CONSTANT fnd_descr_flex_column_usages.descriptive_flexfield_name%TYPE
                                                    := 'OTC Information Types';
   g_lookup_enabled             CONSTANT hr_lookups.enabled_flag%TYPE   := 'Y';
   g_element_iv_translations    CONSTANT hr_lookups.lookup_type%TYPE
                                                        := 'NAME_TRANSLATIONS';
   g_hours_iv                   CONSTANT pay_input_values_f.NAME%TYPE
                                                                    := 'HOURS';
   g_jurisdiction_iv            CONSTANT pay_input_values_f.NAME%TYPE
                                                                    := 'JURISDICTION';
   g_hour_juris_iv              CONSTANT pay_input_values_f.NAME%TYPE
                                                                    := 'HOUR_JURIS';
   g_independant                CONSTANT fnd_flex_value_sets.validation_type%TYPE
                                                                        := 'I';
--   g_total_lines_pipe_name      CONSTANT VARCHAR2 (30)                                                  := 'HXC_PIPE_TOTAL_LINES';
   g_tbb_changed                CONSTANT flag_varchar                   := 'Y';
   g_tbb_deleted                CONSTANT flag_varchar                   := 'Y';

   FUNCTION do_commit
      RETURN BOOLEAN;

   PROCEDURE set_do_commit (p_do_commit IN BOOLEAN);

   PROCEDURE perform_commit;

   FUNCTION use_old_retro_batches
      RETURN BOOLEAN;

   PROCEDURE set_use_old_retro_batches (p_use_old_retro_batches IN BOOLEAN);

   FUNCTION batchname_suffix_connector
      RETURN VARCHAR2;

   PROCEDURE set_batchname_suffix_connector (
      p_batchname_suffix_connector   IN   VARCHAR2
   );

   PROCEDURE empty_asg_cache;

   PROCEDURE empty_batch_suffix_cache;

   PROCEDURE empty_cache;

   FUNCTION max_batch_size
      RETURN NUMBER;

   FUNCTION conc_request_id_suffix (p_from_last IN PLS_INTEGER DEFAULT 4)
      RETURN NUMBER;

   FUNCTION batch_name (
      p_batch_ref              IN   pay_batch_headers.batch_reference%TYPE,
      p_bg_id                  IN   pay_batch_headers.business_group_id%TYPE,
      p_invalid_batch_status   IN   pay_batch_headers.batch_status%TYPE
            DEFAULT NULL
   )
      RETURN pay_batch_headers.batch_name%TYPE;

   FUNCTION max_batch_id (
      p_batch_name   IN   pay_batch_headers.batch_name%TYPE,
      p_bg_id        IN   pay_batch_headers.business_group_id%TYPE
   )
      RETURN pay_batch_headers.batch_id%TYPE;

   FUNCTION count_batch_lines (p_batch_id IN pay_batch_headers.batch_id%TYPE)
      RETURN NUMBER;

   FUNCTION count_batch_lines (
      p_batch_name   IN   pay_batch_headers.batch_name%TYPE,
      p_bg_id        IN   pay_batch_headers.business_group_id%TYPE
   )
      RETURN NUMBER;

   FUNCTION total_batch_lines (
      p_batch_reference   IN   pay_batch_headers.batch_reference%TYPE,
      p_bg_id             IN   pay_batch_headers.business_group_id%TYPE
   )
      RETURN NUMBER;

   PROCEDURE max_lines_exceeded (
      p_batch_id             IN              pay_batch_headers.batch_reference%TYPE,
      p_number_lines         IN OUT NOCOPY   PLS_INTEGER,
      p_max_lines_exceeded   OUT NOCOPY      BOOLEAN
   );

   FUNCTION max_lines_exceeded (
      p_batch_id   IN   pay_batch_headers.batch_reference%TYPE
   )
      RETURN BOOLEAN;

   FUNCTION max_lines_exceeded (
      p_batch_ref   IN   pay_batch_headers.batch_reference%TYPE,
      p_bg_id       IN   pay_batch_headers.business_group_id%TYPE
   )
      RETURN BOOLEAN;

   FUNCTION isnumber (p_value VARCHAR2)
      RETURN BOOLEAN;

   FUNCTION detail_lines_retrieved (
      p_tbb_tbl   IN   hxc_generic_retrieval_pkg.t_building_blocks
   )
      RETURN BOOLEAN;

   FUNCTION gre (
      p_assignment_id    IN   per_all_assignments_f.assignment_id%TYPE,
      p_effective_date   IN   per_all_assignments_f.effective_start_date%TYPE
   )
      RETURN hr_soft_coding_keyflex.segment1%TYPE;

   FUNCTION valid_assignment_type (
      p_asg_type         IN   per_all_assignments_f.assignment_type%TYPE,
      p_validation_tbl   IN   asg_type_table
   )
      RETURN BOOLEAN;

   FUNCTION valid_assignment_system_status (
      p_asg_system_status   IN   per_assignment_status_types.per_system_status%TYPE,
      p_validation_tbl      IN   asg_system_status_table
   )
      RETURN BOOLEAN;

   FUNCTION primary_assignment_id (
      p_person_id                IN   per_people_f.person_id%TYPE,
      p_effective_date           IN   DATE,
      p_valid_asg_types          IN   asg_type_table,
      p_valid_asg_status_types   IN   asg_system_status_table
   )
      RETURN per_all_assignments_f.assignment_id%TYPE;

   PROCEDURE get_assignment_info (
      p_assignment_id       IN              per_all_assignments_f.assignment_id%TYPE,
      p_effective_date      IN              per_all_assignments_f.effective_end_date%TYPE,
      p_assignment_number   OUT NOCOPY      per_all_assignments_f.assignment_number%TYPE,
      p_payroll_id          OUT NOCOPY      per_all_assignments_f.payroll_id%TYPE,
      p_org_id              OUT NOCOPY      per_all_assignments_f.organization_id%TYPE,
      p_location_id         OUT NOCOPY      per_all_assignments_f.location_id%TYPE,
      p_bg_id               OUT NOCOPY      per_all_assignments_f.business_group_id%TYPE
   );

   PROCEDURE get_primary_assignment_info (
      p_person_id           IN              per_all_assignments_f.person_id%TYPE,
      p_effective_date      IN              per_all_assignments_f.effective_end_date%TYPE,
      p_assignment_id       OUT NOCOPY      per_all_assignments_f.assignment_id%TYPE,
      p_assignment_number   OUT NOCOPY      per_all_assignments_f.assignment_number%TYPE,
      p_payroll_id          OUT NOCOPY      per_all_assignments_f.payroll_id%TYPE,
      p_org_id              OUT NOCOPY      per_all_assignments_f.organization_id%TYPE,
      p_location_id         OUT NOCOPY      per_all_assignments_f.location_id%TYPE,
      p_bg_id               OUT NOCOPY      per_all_assignments_f.business_group_id%TYPE
   );

   FUNCTION is_person (p_tbb_rec IN hxc_generic_retrieval_pkg.r_building_blocks)
      RETURN BOOLEAN;

   FUNCTION is_assignment (
      p_tbb_rec   IN   hxc_generic_retrieval_pkg.r_building_blocks
   )
      RETURN BOOLEAN;

   PROCEDURE assignment_info (
      p_tbb_rec             IN              hxc_generic_retrieval_pkg.r_building_blocks,
      p_assignment_id       OUT NOCOPY      per_all_assignments_f.assignment_id%TYPE,
      p_assignment_number   OUT NOCOPY      per_all_assignments_f.assignment_number%TYPE
   );

   FUNCTION attribute_is (
      p_attr_rec         IN   hxc_generic_retrieval_pkg.r_time_attributes,
      p_is_what          IN   hxc_mapping_components.field_name%TYPE,
      p_case_sensitive   IN   BOOLEAN DEFAULT FALSE
   )
      RETURN BOOLEAN;

   FUNCTION attribute_is_element (
      p_attr_rec   IN   hxc_generic_retrieval_pkg.r_time_attributes
   )
      RETURN BOOLEAN;

   FUNCTION attribute_is_cost_segment (
      p_attr_rec   IN   hxc_generic_retrieval_pkg.r_time_attributes
   )
      RETURN BOOLEAN;

   FUNCTION attribute_is_input_value (
      p_attr_rec   IN   hxc_generic_retrieval_pkg.r_time_attributes
   )
      RETURN BOOLEAN;

   FUNCTION attribute_is_asg_id (
      p_attr_rec   IN   hxc_generic_retrieval_pkg.r_time_attributes
   )
      RETURN BOOLEAN;

   FUNCTION attribute_is_asg_num (
      p_attr_rec   IN   hxc_generic_retrieval_pkg.r_time_attributes
   )
      RETURN BOOLEAN;

   FUNCTION extract_number (
      p_extract_from     IN   max_varchar,
      p_sub_string       IN   max_varchar,
      p_case_sensitive   IN   BOOLEAN DEFAULT FALSE
   )
      RETURN PLS_INTEGER;

   FUNCTION input_value_number (
      p_attr_rec   IN   hxc_generic_retrieval_pkg.r_time_attributes
   )
      RETURN PLS_INTEGER;

   FUNCTION cost_segment_number (
      p_attr_rec   IN   hxc_generic_retrieval_pkg.r_time_attributes
   )
      RETURN PLS_INTEGER;

   FUNCTION element_flex_context_code (
      p_element_type_id   IN   pay_element_types_f.element_type_id%TYPE
   )
      RETURN fnd_descr_flex_column_usages.descriptive_flex_context_code%TYPE;

   FUNCTION element_type_id (
      p_attr_rec   IN   hxc_generic_retrieval_pkg.r_time_attributes
   )
      RETURN pay_element_types_f.element_type_id%TYPE;

   FUNCTION element_name (
      p_ele_type_id      IN   pay_element_types_f.element_type_id%TYPE,
      p_effective_date   IN   pay_element_types_f.effective_start_date%TYPE
   )
      RETURN pay_element_types_f.element_name%TYPE;

   FUNCTION hours_worked (
      p_detail_tbb   IN   hxc_generic_retrieval_pkg.r_building_blocks
   )
      RETURN NUMBER;

   FUNCTION element_type_ivs (
      p_element_type_id   IN   pay_element_types_f.element_type_id%TYPE,
      p_effective_date    IN   pay_element_types_f.effective_start_date%TYPE
   )
      RETURN input_value_name_table;

   FUNCTION ddf_input_value_name (
      p_element_type_id   IN   pay_element_types_f.element_type_id%TYPE,
      p_attr_rec          IN   hxc_generic_retrieval_pkg.r_time_attributes
   )
      RETURN fnd_descr_flex_column_usages.end_user_column_name%TYPE;

   FUNCTION accrual_plan_ids (
      p_assignment_id    IN   per_all_assignments_f.assignment_id%TYPE,
      p_effective_date   IN   pay_element_types_f.effective_start_date%TYPE
   )
      RETURN accrual_plan_id_table;

   PROCEDURE assign_iv (
      p_iv_seq    IN              NUMBER,
      p_value     IN              VARCHAR2,
      p_bee_rec   IN OUT NOCOPY   bee_rec
   );

   PROCEDURE convert_attr_to_ivs (
      p_attr_rec          IN              hxc_generic_retrieval_pkg.r_time_attributes,
      p_element_type_id   IN              pay_element_types_f.element_type_id%TYPE,
      p_effective_date    IN              pay_element_types_f.effective_start_date%TYPE,
      p_bee_rec           IN OUT NOCOPY   bee_rec
   );

   PROCEDURE convert_attr_to_costsegment (
      p_attr_rec       IN              hxc_generic_retrieval_pkg.r_time_attributes,
      p_cost_flex_id   IN              per_business_groups_perf.cost_allocation_structure%TYPE,
      p_bee_rec        IN OUT NOCOPY   bee_rec
   );

   FUNCTION translated_iv (
      p_iv_name       IN   hr_lookups.meaning%TYPE,
      p_date_active   IN   hr_lookups.start_date_active%TYPE
   )
      RETURN hr_lookups.lookup_code%TYPE;

  PROCEDURE hours_iv_position (
      p_element_type_id   IN   pay_element_types_f.element_type_id%TYPE,
      p_effective_date    IN   pay_element_types_f.effective_start_date%TYPE,
      p_hours_iv_position OUT NOCOPY PLS_INTEGER,
      p_jurisdiction_iv_position OUT NOCOPY PLS_INTEGER,
      p_iv_type           IN VARCHAR2
   );

   FUNCTION find_element_id_in_attr_tbl (
      p_att_table        IN   hxc_generic_retrieval_pkg.t_time_attribute,
      p_tbb_id           IN   hxc_time_building_blocks.time_building_block_id%TYPE,
      p_start_position   IN   PLS_INTEGER
   )
      RETURN pay_element_types_f.element_type_id%TYPE;

   PROCEDURE find_other_in_attr_tbl (
      p_bg_id             IN              pay_batch_headers.business_group_id%TYPE,
      p_att_table         IN              hxc_generic_retrieval_pkg.t_time_attribute,
      p_tbb_id            IN              hxc_time_building_blocks.time_building_block_id%TYPE,
      p_element_type_id   IN              pay_element_types_f.element_type_id%TYPE,
      p_cost_flex_id      IN              per_business_groups_perf.cost_allocation_structure%TYPE,
      p_effective_date    IN              pay_element_types_f.effective_start_date%TYPE,
      p_start_position    IN              PLS_INTEGER,
      p_ending_position   OUT NOCOPY      PLS_INTEGER,
      p_bee_rec           IN OUT NOCOPY   bee_rec
   );

   FUNCTION skip_attributes (
      p_att_table        IN   hxc_generic_retrieval_pkg.t_time_attribute,
      p_tbb_id           IN   hxc_time_building_blocks.time_building_block_id%TYPE,
      p_start_position   IN   PLS_INTEGER
   )
      RETURN PLS_INTEGER;

/*   PROCEDURE find_asg_in_attr_tbl (
      p_att_table        IN              hxc_generic_retrieval_pkg.t_time_attribute,
      p_tbb_id           IN              hxc_time_building_blocks.time_building_block_id%TYPE,
      p_start_position   IN              PLS_INTEGER,
      p_bee_rec          IN OUT NOCOPY   bee_rec
   ); */
   FUNCTION cost_flex_structure_id (
      p_business_group_id   IN   per_all_organization_units.business_group_id%TYPE
   )
      RETURN per_business_groups_perf.cost_allocation_structure%TYPE;

   FUNCTION costflex_value (
      p_id_flex_num       IN   fnd_id_flex_segments.id_flex_num%TYPE,
      p_segment_name      IN   fnd_id_flex_segments.application_column_name%TYPE,
      p_validation_type   IN   fnd_flex_value_sets.validation_type%TYPE
            DEFAULT g_independant,
--      p_flex_value_id     IN   fnd_flex_values.flex_value_id%TYPE
      p_flex_value_id     IN   hxc_time_attributes.attribute1%TYPE
   )
      RETURN fnd_flex_values.flex_value%TYPE;

   FUNCTION costflex_concat_segments (
      p_cost_allocation_keyflex_id   IN   pay_cost_allocation_keyflex.cost_allocation_keyflex_id%TYPE
   )
      RETURN pay_cost_allocation_keyflex.concatenated_segments%TYPE;

   FUNCTION cost_segments_all_null (p_bee_rec IN bee_rec)
      RETURN BOOLEAN;

   FUNCTION cost_allocation_kff_id (
      p_business_group_id   IN   per_all_organization_units.business_group_id%TYPE,
      p_segment_1           IN   pay_cost_allocation_keyflex.segment1%TYPE,
      p_segment_2           IN   pay_cost_allocation_keyflex.segment2%TYPE,
      p_segment_3           IN   pay_cost_allocation_keyflex.segment3%TYPE,
      p_segment_4           IN   pay_cost_allocation_keyflex.segment4%TYPE,
      p_segment_5           IN   pay_cost_allocation_keyflex.segment5%TYPE,
      p_segment_6           IN   pay_cost_allocation_keyflex.segment6%TYPE,
      p_segment_7           IN   pay_cost_allocation_keyflex.segment7%TYPE,
      p_segment_8           IN   pay_cost_allocation_keyflex.segment8%TYPE,
      p_segment_9           IN   pay_cost_allocation_keyflex.segment9%TYPE,
      p_segment_10          IN   pay_cost_allocation_keyflex.segment10%TYPE,
      p_segment_11          IN   pay_cost_allocation_keyflex.segment11%TYPE,
      p_segment_12          IN   pay_cost_allocation_keyflex.segment12%TYPE,
      p_segment_13          IN   pay_cost_allocation_keyflex.segment13%TYPE,
      p_segment_14          IN   pay_cost_allocation_keyflex.segment14%TYPE,
      p_segment_15          IN   pay_cost_allocation_keyflex.segment15%TYPE,
      p_segment_16          IN   pay_cost_allocation_keyflex.segment16%TYPE,
      p_segment_17          IN   pay_cost_allocation_keyflex.segment17%TYPE,
      p_segment_18          IN   pay_cost_allocation_keyflex.segment18%TYPE,
      p_segment_19          IN   pay_cost_allocation_keyflex.segment19%TYPE,
      p_segment_20          IN   pay_cost_allocation_keyflex.segment20%TYPE,
      p_segment_21          IN   pay_cost_allocation_keyflex.segment21%TYPE,
      p_segment_22          IN   pay_cost_allocation_keyflex.segment22%TYPE,
      p_segment_23          IN   pay_cost_allocation_keyflex.segment23%TYPE,
      p_segment_24          IN   pay_cost_allocation_keyflex.segment24%TYPE,
      p_segment_25          IN   pay_cost_allocation_keyflex.segment25%TYPE,
      p_segment_26          IN   pay_cost_allocation_keyflex.segment26%TYPE,
      p_segment_27          IN   pay_cost_allocation_keyflex.segment27%TYPE,
      p_segment_28          IN   pay_cost_allocation_keyflex.segment28%TYPE,
      p_segment_29          IN   pay_cost_allocation_keyflex.segment29%TYPE,
      p_segment_30          IN   pay_cost_allocation_keyflex.segment30%TYPE
   )
      RETURN pay_cost_allocation_keyflex.cost_allocation_keyflex_id%TYPE;

   FUNCTION cost_allocation_kff_id (
      p_business_group_id   IN   per_all_organization_units.business_group_id%TYPE,
      p_bee_rec             IN   bee_rec
   )
      RETURN pay_cost_allocation_keyflex.cost_allocation_keyflex_id%TYPE;

   FUNCTION hours_factor (p_is_old IN BOOLEAN)
      RETURN NUMBER;

/* These 3 procedures were commented out because the pipes were causing
   issues with the SGA.  The pipe grew out-of-control for no apparent reason.
   Anyway, for now, we will NOT allow multithreading of this process so we do
   not need pipes!!!
*/
/*   PROCEDURE write_pipe_batch_info (p_batch_info IN piped_batch_info_table);

   FUNCTION read_pipe_batch_info
      RETURN piped_batch_info_table;

   FUNCTION purge_pipe
      RETURN BOOLEAN;
*/
   FUNCTION free_batch_suffix (
      p_batch_reference   IN   pay_batch_headers.batch_reference%TYPE,
      p_bg_id             IN   pay_batch_headers.business_group_id%TYPE
   )
      RETURN NUMBER;

/*   FUNCTION total_lines (
      p_batch_reference     IN   pay_batch_headers.batch_reference%TYPE,
      p_bg_id               IN   pay_batch_headers.business_group_id%TYPE,
      p_incremental_value   IN   PLS_INTEGER DEFAULT 0
   )
      RETURN NUMBER;

   FUNCTION is_full (
      p_batch_reference   IN   pay_batch_headers.batch_reference%TYPE,
      p_bg_id             IN   pay_batch_headers.business_group_id%TYPE
   )
      RETURN BOOLEAN; */
   FUNCTION is_changed (
      p_tbb_rec   IN   hxc_generic_retrieval_pkg.r_building_blocks
   )
      RETURN BOOLEAN;

   FUNCTION is_deleted (
      p_tbb_rec   IN   hxc_generic_retrieval_pkg.r_building_blocks
   )
      RETURN BOOLEAN;

   FUNCTION is_in_sync (
      p_check_tbb_id     IN   hxc_time_building_blocks.time_building_block_id%TYPE,
      p_against_tbb_id   IN   hxc_time_building_blocks.time_building_block_id%TYPE
   )
      RETURN BOOLEAN;
/*   FUNCTION is_in_sync (
      p_tbb_id         IN   hxc_time_building_blocks.time_building_block_id%TYPE,
      p_attr_tbl       IN   hxc_generic_retrieval_pkg.t_time_attribute,
      p_attr_tbl_idx   IN   PLS_INTEGER
   )
      RETURN BOOLEAN; */

    FUNCTION get_geocode_from_attr_tab (
      p_att_table        IN   hxc_generic_retrieval_pkg.t_time_attribute,
      p_tbb_id           IN   hxc_time_building_blocks.time_building_block_id%TYPE,
      p_start_position   IN   PLS_INTEGER
   )
      RETURN VARCHAR2;

END hxt_interface_utilities;

 

/
