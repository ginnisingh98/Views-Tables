--------------------------------------------------------
--  DDL for Package PQP_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_UTILITIES" AUTHID CURRENT_USER AS
/* $Header: pqputifn.pkh 120.10.12000000.1 2007/01/16 04:29:24 appldev noship $ */


  hr_application_error          EXCEPTION;
  PRAGMA EXCEPTION_INIT(hr_application_error, -20001);


  g_nested_level                NUMBER(5) := 0;
  g_debug_timestamps            BOOLEAN := FALSE;
  g_debug_entry_exits_only      BOOLEAN := FALSE;
  g_debug                       BOOLEAN := hr_utility.debug_enabled;





TYPE t_tbls IS RECORD(
    table_name                    pay_user_tables.user_table_name%TYPE
   ,column_name                  pay_user_columns.user_column_name%TYPE
  );

 TYPE t_cached_tbls IS TABLE OF t_tbls
    INDEX BY BINARY_INTEGER;

  g_cached_tbls                     t_cached_tbls;



  TYPE t_cached_udt IS TABLE OF pay_user_tables.user_table_name%TYPE
    INDEX BY BINARY_INTEGER;

  g_cached_udts                 t_cached_udt;

  TYPE t_udt_rec IS RECORD(
    table_name                    pay_user_tables.user_table_name%TYPE
   , -- Comment
     column_name                  pay_user_columns.user_column_name%TYPE
   ,row_name                      pay_user_rows_f.row_low_range_or_name%TYPE
   ,row_high_range                pay_user_rows_f.row_high_range%TYPE
   ,matrix_value                  pay_user_column_instances_f.VALUE%TYPE
   ,start_date                    DATE
   ,end_date                      DATE
  );

  TYPE temp_rec IS RECORD
   (
     hash_string VARCHAR2(200)
    );

  TYPE t_temp_rec IS TABLE OF temp_rec
  INDEX BY BINARY_INTEGER;
  g_hash_keys t_temp_rec;



  -- Added by akarmaka
  -- global cache pointer  record structure.This is used
  -- as template for hash-buckets.
  TYPE t_cached_udt_bucket_rec IS RECORD
  (
    table_name         pay_user_tables.user_table_name%TYPE
   ,business_group_id  NUMBER(15)
   ,start_index        NUMBER (15)
   ,rec_count          NUMBER(15)
   );



  TYPE t_cached_udt_bucket IS TABLE OF t_cached_udt_bucket_rec
    INDEX BY BINARY_INTEGER;
   g_cached_udt        t_cached_udt_bucket;
-- four hash buckets for the cached UDTs
  g_cached_udt0        t_cached_udt_bucket;
  g_cached_udt1        t_cached_udt_bucket;
  g_cached_udt2        t_cached_udt_bucket;
  g_cached_udt3        t_cached_udt_bucket;

--
    TYPE r_config_values IS RECORD (
          configuration_value_id        NUMBER,
          pcv_information1              pqp_configuration_values.pcv_information1%TYPE,
          pcv_information2              pqp_configuration_values.pcv_information2%TYPE,
          pcv_information3              pqp_configuration_values.pcv_information3%TYPE,
          pcv_information4              pqp_configuration_values.pcv_information4%TYPE,
          pcv_information5              pqp_configuration_values.pcv_information5%TYPE,
          pcv_information6              pqp_configuration_values.pcv_information6%TYPE,
          pcv_information7              pqp_configuration_values.pcv_information7%TYPE,
          pcv_information8              pqp_configuration_values.pcv_information8%TYPE,
          pcv_information9              pqp_configuration_values.pcv_information9%TYPE,
          pcv_information10             pqp_configuration_values.pcv_information10%TYPE,
          pcv_information11             pqp_configuration_values.pcv_information11%TYPE,
          pcv_information12             pqp_configuration_values.pcv_information12%TYPE,
          pcv_information13             pqp_configuration_values.pcv_information13%TYPE,
          pcv_information14             pqp_configuration_values.pcv_information14%TYPE,
          pcv_information15             pqp_configuration_values.pcv_information15%TYPE,
          pcv_information16             pqp_configuration_values.pcv_information16%TYPE,
          pcv_information17             pqp_configuration_values.pcv_information17%TYPE,
          pcv_information18             pqp_configuration_values.pcv_information18%TYPE,
          pcv_information19             pqp_configuration_values.pcv_information19%TYPE,
          pcv_information20             pqp_configuration_values.pcv_information20%TYPE
          );

      TYPE t_config_values IS TABLE OF r_config_values
      INDEX BY BINARY_INTEGER;
--
  -- added by kkarri
  TYPE r_all_segment_values IS RECORD
        (
        segment_column_value1      VARCHAR2(80)
        ,segment_column_value2     VARCHAR2(80)
        ,segment_column_value3     VARCHAR2(80)
        ,segment_column_value4     VARCHAR2(80)
        ,segment_column_value5     VARCHAR2(80)
        ,segment_column_value6     VARCHAR2(80)
        ,segment_column_value7     VARCHAR2(80)
        ,segment_column_value8     VARCHAR2(80)
        ,segment_column_value9     VARCHAR2(80)
        ,segment_column_value10    VARCHAR2(80)
        ,segment_column_value11    VARCHAR2(80)
        ,segment_column_value12    VARCHAR2(80)
        ,segment_column_value13    VARCHAR2(80)
        ,segment_column_value14    VARCHAR2(80)
        ,segment_column_value15    VARCHAR2(80)
        ,segment_column_value16    VARCHAR2(80)
        ,segment_column_value17    VARCHAR2(80)
        ,segment_column_value18    VARCHAR2(80)
        ,segment_column_value19    VARCHAR2(80)
        ,segment_column_value20    VARCHAR2(80)
        ,segment_column_value21    VARCHAR2(80)
        ,segment_column_value22    VARCHAR2(80)
        ,segment_column_value23    VARCHAR2(80)
        ,segment_column_value24    VARCHAR2(80)
        ,segment_column_value25    VARCHAR2(80)
        ,segment_column_value26    VARCHAR2(80)
        ,segment_column_value27    VARCHAR2(80)
        ,segment_column_value28    VARCHAR2(80)
        ,segment_column_value29    VARCHAR2(80)
        ,segment_column_value30    VARCHAR2(80)
        );
  PROCEDURE get_config_type_values
    (
     p_configuration_type   IN              VARCHAR2
    ,p_business_group_id    IN              NUMBER
    ,p_legislation_code     IN              VARCHAR2
    ,p_tab_config_values    OUT NOCOPY      t_config_values
    );

--
  TYPE t_udt_array IS TABLE OF t_udt_rec
    INDEX BY BINARY_INTEGER;

  g_udt_rec                     t_udt_array;

-- Added by : rtahilia
-- Date : 04/04/2003
-- Record type to store merged event dates and update types
  TYPE event_details_record_type IS RECORD(
    event_date                    DATE
   ,update_type                   pay_datetracked_events.update_type%TYPE
  );

-- Added by : rtahilia
-- Date : 04/04/2003
-- PL/SQL table type to store merged event dates and update types
  TYPE t_event_details_table_type IS TABLE OF event_details_record_type
    INDEX BY BINARY_INTEGER;

--
-- Cursor to get Data Type for a given Table Name and column Name
  CURSOR csr_data_type(p_tab_nam IN VARCHAR2, p_col_nam IN VARCHAR2)
  IS
    SELECT fc.column_type data_type
    FROM   fnd_tables ft, fnd_columns fc
    WHERE  ft.table_id = fc.table_id
    AND    ft.application_id = fc.application_id
    -- 801-PAY, 800-PER, 805-BEN, 8303-PQP, 8302-PQH, 0-FND, 804-SSP
    AND    ft.application_id IN (801,800,805,8303,8302,0,804)
    AND    ft.table_name = p_tab_nam
    AND    fc.column_name = p_col_nam;

-- Cursor to get Segment Name for a flex name, context and flex field title.
  CURSOR csr_seg_name(
    p_flex_name                 IN       VARCHAR2
   ,p_flex_context              IN       VARCHAR2
   ,p_flex_field_title          IN       VARCHAR2
  )
  IS
    SELECT application_column_name
    FROM   fnd_descr_flex_col_usage_vl
    WHERE  descriptive_flexfield_name = p_flex_name
    -- Added for performance fix 3166903
    -- 801-PAY, 800-PER, 805-BEN, 8303-PQP, 8302-PQH, 0-FND, 804-SSP
    AND    application_id IN (801,800,805,8303,8302,0,804)
    AND    descriptive_flex_context_code = p_flex_context
    AND    end_user_column_name = p_flex_field_title;

-- Need to check for FORM_LEFT_PROMPT?

-- Cursor to get Table Name associated with a Flex Field
  CURSOR csr_tab_name(p_flex_name IN VARCHAR2)
  IS
    SELECT application_table_name
    FROM   fnd_descriptive_flexs
    WHERE application_id IN (801,800,805,8303,8302,0)
      AND descriptive_flexfield_name = p_flex_name;

-- Need to check for Title?

-- Cursor to check whether Multiple Ocurances of EIT information
-- type is allowed
  CURSOR csr_mult_occur(p_information_type IN VARCHAR2)
  IS
    SELECT multiple_occurences_flag
    FROM   pay_element_type_info_types
    WHERE  information_type = p_information_type
           AND active_inactive_flag = 'Y';

-- Cursor to get Element type id for a given element Name.
  CURSOR csr_element_type(
    p_element_type_name         IN       VARCHAR2
   ,p_effective_date            IN       DATE
   ,p_business_group_id         IN       NUMBER
   ,p_legislation_code          IN       VARCHAR2
  )
  IS
    SELECT element_type_id
    FROM   pay_element_types_f
    WHERE upper( element_name) =upper( p_element_type_name)
    AND    p_effective_date BETWEEN effective_start_date AND effective_end_date
    AND    (   business_group_id = p_business_group_id
            OR business_group_id IS NULL)
    AND    (   legislation_code = p_legislation_code
            OR legislation_code IS NULL);

-- Cursor to get User Defined Table ID for a given UDT Name.
  CURSOR csr_table_id(p_table_id IN NUMBER)
  IS
    SELECT user_table_name
    FROM   pay_user_tables
    WHERE  user_table_id = p_table_id;

-- Cursor to get Legislation Code from a Business Group Id.
  CURSOR csr_leg_code(p_business_group_id IN NUMBER)
  IS
    SELECT legislation_code
    FROM   per_business_groups
    WHERE  business_group_id = p_business_group_id;

-- Cursor to get Lookup Code.
  CURSOR csr_lookup_code(
    p_lookup_type               IN       VARCHAR2
   ,p_lookup_meaning            IN       VARCHAR2
  )
  IS
    SELECT lookup_code
    FROM   fnd_lookup_values_vl
    WHERE  lookup_type = p_lookup_type AND UPPER(meaning) = UPPER(p_lookup_meaning);

-- Cursor to get the event group details
  CURSOR csr_event_group_details(
    p_event_group_name                   VARCHAR2
   ,p_business_group_id                  NUMBER
  )
  IS
    SELECT event_group_id
          ,event_group_name
          ,event_group_type
          ,proration_type
    FROM   pay_event_groups
    WHERE  event_group_name = p_event_group_name
    AND    NVL(business_group_id, p_business_group_id) = p_business_group_id;

-------------debug
  PROCEDURE DEBUG(
    p_trace_message             IN       VARCHAR2
   ,p_trace_location            IN       NUMBER DEFAULT NULL
  );

-------------debug_enter
  PROCEDURE debug_enter(
    p_proc_name                 IN       VARCHAR2 DEFAULT NULL
   ,p_trace_on                  IN       VARCHAR2 DEFAULT NULL
  );

-------------debug_exit
  PROCEDURE debug_exit(
    p_proc_name                 IN       VARCHAR2 DEFAULT NULL
   ,p_trace_off                 IN       VARCHAR2 DEFAULT NULL
  );

  PROCEDURE debug_others(
    p_proc_name                 IN       VARCHAR2
   ,p_proc_step                 IN       NUMBER DEFAULT NULL
  );

----------------get_value_main
  FUNCTION get_col_value(
    p_col_nam                   IN       VARCHAR2
   ,p_key_val                   IN       NUMBER
   ,p_table                     IN       VARCHAR2
   ,p_key_col                   IN       VARCHAR2
   ,p_where                     IN       VARCHAR2
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_message                   OUT NOCOPY VARCHAR2
  )
    RETURN VARCHAR2;

-----------------get_data_type
  FUNCTION get_data_type(
    p_col_nam                   IN       VARCHAR2
   ,p_tab_nam                   IN       VARCHAR2
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_message                   OUT NOCOPY VARCHAR2
  )
    RETURN VARCHAR2;

-----------------get_flex_value
  FUNCTION get_ddf_value(
    p_flex_name                 IN       VARCHAR2
   ,p_flex_context              IN       VARCHAR2
   ,p_flex_field_title          IN       VARCHAR2
   ,p_key_col                   IN       VARCHAR2
   ,p_key_val                   IN       NUMBER
   ,p_effective_date            IN       DATE
   ,p_eff_date_req              IN       VARCHAR2
   ,p_business_group_id         IN       NUMBER
   ,p_bus_group_id_req          IN       VARCHAR2
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_message                   OUT NOCOPY VARCHAR2
  )
    RETURN VARCHAR2;

------------------get_segment_name
  FUNCTION get_segment_name(
    p_flex_name                 IN       VARCHAR2
   ,p_flex_field_title          IN       VARCHAR2
   ,p_flex_context              IN       VARCHAR2
   ,p_tab_nam                   OUT NOCOPY VARCHAR2
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_message                   OUT NOCOPY VARCHAR2
  )
    RETURN VARCHAR2;

------------------get_df_value
  FUNCTION get_df_value(
    p_flex_name                 IN       VARCHAR2
   ,p_flex_context              IN       VARCHAR2
   ,p_flex_field_title          IN       VARCHAR2
   ,p_key_col                   IN       VARCHAR2
   ,p_key_val                   IN       VARCHAR2
   ,p_tab_name                  IN       VARCHAR2
   ,p_effective_date            IN       DATE
   ,p_eff_date_req              IN       VARCHAR2
   ,p_business_group_id         IN       NUMBER
   ,p_bus_group_id_req          IN       VARCHAR2
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_message                   OUT NOCOPY VARCHAR2
  )
    RETURN VARCHAR2;

------------------pqp_get_concat_value
  FUNCTION pqp_get_concat_value(
    p_key_col                   IN       VARCHAR2
   ,p_key_val                   IN       VARCHAR2
   ,p_tab_name                  IN       VARCHAR2
   ,p_view_name                 IN       VARCHAR2
   ,p_message                   OUT NOCOPY VARCHAR2
  )
    RETURN VARCHAR2;

------------------pqp_get_extra_element_mult
  FUNCTION pqp_get_extra_element_mult(
    p_flex_name                 IN       VARCHAR2
   ,p_segment_name              IN       VARCHAR2
   ,p_flex_context              IN       VARCHAR2
   ,p_element_type_id           IN       NUMBER
   ,p_message                   OUT NOCOPY VARCHAR2
  )
    RETURN NUMBER;

------------------pqp_get_extra_element_info
  FUNCTION pqp_get_extra_element_info(
    p_element_type_id           IN       NUMBER
   ,p_information_type          IN       VARCHAR2
   ,p_segment_name              IN       VARCHAR2
   ,p_value                     OUT NOCOPY VARCHAR2
   ,p_truncated_yes_no          OUT NOCOPY VARCHAR2
   ,p_error_msg                 OUT NOCOPY VARCHAR2
  )
    RETURN NUMBER;

------------------pqp_get_extra_element_info_det
  FUNCTION pqp_get_extra_element_info_det(
    p_element_type_id           IN       NUMBER
   ,p_information_type          IN       VARCHAR2
   ,p_segment_name              IN       VARCHAR2
   ,p_value                     OUT NOCOPY VARCHAR2
   ,p_truncated_yes_no          OUT NOCOPY VARCHAR2
   ,p_error_msg                 OUT NOCOPY VARCHAR2
  )
    RETURN NUMBER;

------------------pqp_get_element_extra_info
  FUNCTION pqp_get_element_extra_info(
    p_business_group_id         IN       NUMBER
   ,p_effective_date            IN       DATE
   ,p_element_type_name         IN       VARCHAR2
   ,p_information_type          IN       VARCHAR2
   ,p_segment_name              IN       VARCHAR2
   ,p_value                     OUT NOCOPY VARCHAR2
   ,p_truncated_yes_no          OUT NOCOPY VARCHAR2
   ,p_error_msg                 OUT NOCOPY VARCHAR2
  )
    RETURN NUMBER;

------------------pqp_get_element_extra_info_det
  FUNCTION pqp_get_element_extra_info_det(
    p_business_group_id         IN       NUMBER
   ,p_effective_date            IN       DATE
   ,p_element_type_name         IN       VARCHAR2
   ,p_information_type          IN       VARCHAR2
   ,p_segment_name              IN       VARCHAR2
   ,p_value                     OUT NOCOPY VARCHAR2
   ,p_truncated_yes_no          OUT NOCOPY VARCHAR2
   ,p_error_msg                 OUT NOCOPY VARCHAR2
  )
    RETURN NUMBER;

------------------pqp_get_ele_type_extra_info_id
-- added by   : vimittal
-- added date : 10-Feb-2005
-- purpose    : The function returns the element type extra information id
--              for the passed element type id and information type.
  FUNCTION pqp_get_ele_type_extra_info_id(
     p_element_type_id             IN         NUMBER
    ,p_information_type            IN         VARCHAR2
    ,p_element_type_extra_info_id  OUT NOCOPY NUMBER
    ,p_error_msg                   OUT NOCOPY VARCHAR2
    )
    RETURN NUMBER;


------------------pqp_gb_get_element_type_id
  FUNCTION pqp_get_element_type_id(
    p_business_group_id         IN       NUMBER
   ,p_legislation_code          IN       VARCHAR2
   ,p_effective_date            IN       DATE
   ,p_element_type_name         IN       VARCHAR2
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_message                   OUT NOCOPY VARCHAR2
  )
    RETURN NUMBER;

------------------pqp_gb_get_table_value
  FUNCTION pqp_gb_get_table_value(
    p_business_group_id         IN       NUMBER
   ,p_effective_date            IN       DATE
   ,p_table_name                IN       VARCHAR2
   ,p_column_name               IN       VARCHAR2
   ,p_row_name                  IN       VARCHAR2
   ,p_value                     OUT NOCOPY VARCHAR2
   ,p_error_msg                 OUT NOCOPY VARCHAR2
   ,p_refresh_cache             IN         VARCHAR2   DEFAULT 'N'
  )
    RETURN NUMBER;

------------------pqp_gb_get_table_value_id
  FUNCTION pqp_gb_get_table_value_id(
    p_business_group_id         IN       NUMBER
   ,p_effective_date            IN       DATE
   ,p_table_id                  IN       NUMBER
   ,p_column_name               IN       VARCHAR2
   ,p_row_name                  IN       VARCHAR2
   ,p_value                     OUT NOCOPY VARCHAR2
   ,p_error_msg                 OUT NOCOPY VARCHAR2
  )
    RETURN NUMBER;

------------
  PROCEDURE delete_udt_value(
   p_table_name    IN         VARCHAR2
  ,p_column_name   IN         VARCHAR2 DEFAULT 'ALL'
  ,p_error_msg     OUT NOCOPY VARCHAR2
  );
------------------pqp_get_legislation_code
  FUNCTION pqp_get_legislation_code(p_business_group_id IN NUMBER)
    RETURN VARCHAR2;

------------------get_udt_data
   PROCEDURE get_udt_data(
    p_business_group_id         IN       NUMBER
   ,p_effective_date            IN       DATE
   ,p_udt_name                  IN       VARCHAR2
   ,p_column_name               IN       VARCHAR2 DEFAULT 'ALL'
   ,p_error_msg                 OUT NOCOPY VARCHAR2
  );

------------------get_udt_value
  FUNCTION get_udt_value(
    p_table_name                IN       VARCHAR2
   ,p_column_name               IN       VARCHAR2
   ,p_row_name                  IN       VARCHAR2
   ,p_effective_date            IN       DATE
   ,p_business_group_id         IN       NUMBER
  )
    RETURN VARCHAR2;

------------------set_trace_on
  FUNCTION set_trace_on(
    p_trace_destination         IN       VARCHAR2
   ,p_trace_coverage            IN       VARCHAR2
   ,p_error_message             OUT NOCOPY VARCHAR2
  )
    RETURN NUMBER;

------------------set_request_trace_on
  FUNCTION set_request_trace_on(p_error_message OUT NOCOPY VARCHAR2)
    RETURN NUMBER;

------------------set_trace_off
  FUNCTION set_trace_off(p_error_message OUT NOCOPY VARCHAR2)
    RETURN NUMBER;

------------------------get_lookup_code
  FUNCTION get_lookup_code(
    p_lookup_type               IN       VARCHAR2
   ,p_lookup_meaning            IN       VARCHAR2
   ,p_message                   OUT NOCOPY VARCHAR2
  )
    RETURN VARCHAR2;

--delete_formula
  PROCEDURE delete_formula(
    p_formula_id                IN       NUMBER
   ,p_drop_compiled_info        IN       BOOLEAN DEFAULT TRUE
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_error_message             OUT NOCOPY VARCHAR2
  );

------------------get_event_group_id
-- Added by : rtahilia
-- Date : 04/04/2003
-- This a generic function to return the event group id
-- for the give event group name and business group id
  FUNCTION get_event_group_id(
    p_business_group_id         IN       NUMBER
   ,p_event_group_name          IN       VARCHAR2
  )
    RETURN NUMBER;

------------------get_events - overloaded
-- Added by : rtahilia
-- Date : 04/04/2003
-- This is a generic function to return events for a
-- given event group and date range
  FUNCTION get_events(
    p_assignment_id             IN       NUMBER
   ,p_element_entry_id          IN       NUMBER DEFAULT NULL
   ,p_assignment_action_id      IN       NUMBER DEFAULT NULL
   ,p_business_group_id         IN       NUMBER
   ,p_process_mode              IN       VARCHAR2
        DEFAULT 'ENTRY_EFFECTIVE_DATE'
   ,p_event_group_name          IN       VARCHAR2
   ,p_start_date                IN       DATE
   ,p_end_date                  IN       DATE
   ,t_event_details             OUT NOCOPY pqp_utilities.t_event_details_table_type
  )
    RETURN NUMBER;

------------------get_events - overloaded
-- Added by : rtahilia
-- Date : 19/08/2003
-- This is a generic function to return events for a
-- given event group and date range
  FUNCTION get_events(
    p_assignment_id             IN       NUMBER
   ,p_element_entry_id          IN       NUMBER DEFAULT NULL
   ,p_assignment_action_id      IN       NUMBER DEFAULT NULL
   ,p_business_group_id         IN       NUMBER
   ,p_process_mode              IN       VARCHAR2 DEFAULT 'ENTRY_EFFECTIVE_DATE'
   ,p_event_group_name          IN       VARCHAR2
   ,p_start_date                IN       DATE
   ,p_end_date                  IN       DATE
   ,t_proration_dates          OUT NOCOPY pay_interpreter_pkg.t_proration_dates_table_type
   ,t_proration_change_type    OUT NOCOPY pay_interpreter_pkg.t_proration_type_table_type
  )
    RETURN NUMBER;
------------------------------chk_cached_udt_bucket
-- Added by akarmaka
FUNCTION chk_cached_udt_bucket (p_refresh_cache IN VARCHAR2
                                ,p_business_group IN NUMBER
				,p_table_name     IN VARCHAR2
				,p_error_msg      OUT NOCOPY VARCHAR2
			      )
 RETURN BOOLEAN ;
-------------- added by akarmaka for hash function implementation
 FUNCTION get_hash_key
 ( p_string IN VARCHAR2
  ,p_error_msg    OUT NOCOPY VARCHAR2
  ,p_refresh_cache IN VARCHAR2
  ,p_business_group_id IN NUMBER
  )
 RETURN BINARY_INTEGER;

 PROCEDURE set_hash_conflict_check_off;
 PROCEDURE set_hash_conflict_check_on;
 PROCEDURE reset_hash_keys;
 PROCEDURE set_hash_parameters
  (p_hash_base       IN  BINARY_INTEGER
  ,p_hash_size       IN  BINARY_INTEGER
  ,p_conflict_check  IN  BOOLEAN DEFAULT FALSE
  );

------------------------------------------------------------------
--
--
--
  PROCEDURE check_error_code(
    p_error_code                IN       fnd_new_messages.message_number%TYPE
   ,p_error_message             IN       fnd_new_messages.MESSAGE_TEXT%TYPE
        DEFAULT NULL
  );
--
--
--
  FUNCTION pqp_fnd_message_set_token(
    token                       IN      VARCHAR2
   ,value                       IN      VARCHAR2
   ,translate                   IN      VARCHAR2 DEFAULT 'N'
   ) RETURN NUMBER;

--
--
--
  FUNCTION pqp_fnd_message_set_name(
    application                 IN      VARCHAR2
   ,name                        IN      VARCHAR2
   ) RETURN NUMBER;

--
--

FUNCTION round_value_up_down(
    p_value_to_round IN NUMBER
   ,p_base_value     IN NUMBER
   ,p_rounding_type  IN VARCHAR2
  )
  RETURN NUMBER ;
--

--
FUNCTION pqp_get_config_value(
    p_business_group_id     IN NUMBER
   ,p_legislation_code     IN VARCHAR2
   ,p_column_name          IN VARCHAR2
   ,p_information_category IN VARCHAR2
  ) RETURN VARCHAR2;

--
-- added by kkarri
PROCEDURE get_kflex_value
    (p_entity_name                IN VARCHAR2 -- name of the table holding the values
    ,p_key_column_name            IN VARCHAR2 -- Key Column Name
    ,p_key_column_value           IN VARCHAR2 -- Key Column Value
    ,p_segment_column_values      OUT NOCOPY r_all_segment_values
    );
-- added by kkarri
PROCEDURE get_kflex_value
    (p_entity_name                IN VARCHAR2 -- name of the table holding the values
    ,p_key_column_name            IN VARCHAR2 -- Key Column Name
    ,p_key_column_value           IN VARCHAR2 -- Key Column Value
    ,p_segment_column_name        IN VARCHAR2
    ,p_segment_column_value       OUT NOCOPY VARCHAR2
    );
-- added by kkarri
PROCEDURE entries_affected
    (p_assignment_id           IN  NUMBER DEFAULT NULL
    ,p_event_group_id         IN  NUMBER DEFAULT NULL
    ,p_mode                   IN  VARCHAR2 DEFAULT NULL
    ,p_start_date             IN  DATE  DEFAULT hr_api.g_sot
    ,p_end_date               IN  DATE  DEFAULT hr_api.g_eot
    ,p_business_group_id      IN  NUMBER
    ,p_detailed_output        OUT NOCOPY  pay_interpreter_pkg.t_detailed_output_table_type
    ,p_process_mode           IN  VARCHAR2 DEFAULT 'ENTRY_CREATION_DATE'
    );
END pqp_utilities;

 

/
