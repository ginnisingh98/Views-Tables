--------------------------------------------------------
--  DDL for Package HRI_APL_DIAGNOSTICS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_APL_DIAGNOSTICS" AUTHID CURRENT_USER AS
/* $Header: hriadiag.pkh 120.1 2005/10/06 09:23:57 jtitmas noship $ */
--
-- This procedure is used to create the subscritpion for objects
-- Every diagnostic should have a subscription
--
-- p_object_name - Name of the object for which you want to create the diagnostics
-- p_object_type - The type of object. Valid values are BUCKET,PROFILE,SEEDED_FAST_FORMULA,TABLE,TRIGGER,USER_DEFN_FAST_FORMULA.Object type of data diagnostic.
-- p_functional_area_cd - The functional area to which the object is being subscribed. Valid values can be found by querying HR_LOOKUPS for lookup type HRI_FUNCTIONAL_AREA.
--
PROCEDURE create_subscription
  (p_object_name IN VARCHAR2,
  p_object_type IN VARCHAR2,
  p_functional_area_cd IN VARCHAR2);
--
-- This procedure is used to delete a subscription
--
-- p_object_name - Name of the object for which you want to create the diagnostics
-- p_object_type - The type of object. Valid values are BUCKET,PROFILE,SEEDED_FAST_FORMULA,TABLE,TRIGGER,USER_DEFN_FAST_FORMULA. Object type of data diagnostic.
-- p_functional_area_cd - The functional area to which the object is being subscribed. Valid values can be found by querying HR_LOOKUPS for lookup type HRI_FUNCTIONAL_AREA.
--
PROCEDURE delete_subscription
  (p_object_name IN VARCHAR2,
  p_object_type IN VARCHAR2,
  p_functional_area_cd IN VARCHAR2);
--
--
-- This procedure is used to create diagnostics associated with profiles
--
--  p_object_name - The name of the profile. This is the column profile_option_name from table fnd_profile_options for the profile.
--  p_dynamic_sql - Stores the dynamic SQL to get the profile value
--  p_dynamic_sql_type - 'API' if the above column contains an api, otherwise null
--  p_exception_value - Stores the value of the profile for which impact message is to be displayed
--  p_impact_msg_name - Message code for the message, which is to be displayed when the exception value for the profile is encountered
--  p_add_info_URL - An URL can be specified here where the user can find more information about the profile
--  p_enabled_flag - Set this to Y, if the diagnostics is to be displayed. Else set to N.
--  p_foundation_HR_FLAG - Set this to Y, if this profile is to be checked in Foundation HR. Else set to N.
--  p_null_impact_msg_name - Message code for the message, which is displayed when the profile value is null
--  p_functional_area_cd - The functional area to which the profile belongs. Valid values can be found by querying HR_LOOKUPS for lookup type HRI_FUNCTIONAL_AREA
--
--
PROCEDURE create_profile_sys_setup
  (p_object_name IN VARCHAR2,
  p_dynamic_sql IN VARCHAR2,
  p_dynamic_sql_type IN VARCHAR2,
  p_exception_value IN VARCHAR2,
  p_impact_msg_name IN VARCHAR2,
  p_add_info_URL IN VARCHAR2,
  p_enabled_flag IN VARCHAR2,
  p_foundation_HR_FLAG IN VARCHAR2,
  p_null_impact_msg_name IN VARCHAR2,
  p_functional_area_cd IN VARCHAR2);

--
-- This procedure is used to create diagnostics associated with dynamic triggers
--
-- p_object_name - The name of the dynamic trigger. This is the short_name column of table pay_trigger_events
-- p_exception_status_msg_cd - Message code for the message, which is displayed if the trigger is not generated and enabled
-- p_valid_status_msg_cd - Message code for the message, which is displayed if the trigger is generated and enabled
-- p_enabled_flag - Set this to Y, if the diagnostics for the trigger is to be displayed. Else set to N.
-- p_foundation_hr_flag - Set this to Y, if this trigger is to be checked in Foundation HR. Else set to N.
-- p_functional_area_cd - The functional area to which the trigger belongs. Valid values can be found by querying HR_LOOKUPS for lookup type HRI_FUNCTIONAL_AREA.
--
PROCEDURE create_trigger_sys_setup
  (p_object_name IN VARCHAR2,
  p_exception_status_msg_cd IN VARCHAR2,
  p_valid_status_msg_cd IN VARCHAR2,
  p_enabled_flag IN VARCHAR2,
  p_foundation_hr_flag IN VARCHAR2,
  p_functional_area_cd IN VARCHAR2);

--
-- This procedure is used to create diagnostics associated with tables
--
-- p_object_name - The name of the table
-- p_object_owner - Schema in which the table exists
-- p_exception_status_msg_cd - Message code for message, which is displayed when record count for the table is 0
-- p_valid_status_msg_cd - Message code for message, which is displayed when record count for the table is not 0
-- p_enabled_flag - Set this to Y, if the diagnostics for this table is to be displayed. Else set to N.
-- p_foundation_hr_flag - Set this to Y, if this table is to be checked in Foundation HR. Else set to N.
-- p_functional_area_cd - The functional area to which the table belongs. Valid values can be found by querying
--
PROCEDURE create_table_sys_setup
  (p_object_name IN VARCHAR2,
  p_object_owner IN VARCHAR2,
  p_exception_status_msg_cd IN VARCHAR2,
  p_valid_status_msg_cd IN VARCHAR2,
  p_enabled_flag IN VARCHAR2,
  p_foundation_hr_flag IN VARCHAR2,
  p_functional_area_cd IN VARCHAR2);

--
-- This procedure is used to create diagnostics associated with seeded fast formulas
--
-- p_object_name - The name of the fast formula. This is the value of column formula_name of table ff_formulas_f
-- p_exception_status_msg_cd - Message code for message, which is displayed when the fast formula is in invalid status
-- p_valid_status_msg_cd - Message code for message, which is displayed when the fast formula is in a valid state
-- p_add_info_url - URL for additional information on the fast formula
-- p_enabled_flag - Set this to Y, if the diagnostics for this fast formula is to be displayed. Else set to N.
-- p_foundation_hr_flag - Set this to Y, if this fast formula is to be checked in Foundation HR. Else set to N.
-- p_functional_area_cd - The functional area to which the fast formula belongs. Valid values can be found by querying HR_LOOKUPS for lookup type HRI_FUNCTIONAL_AREA.
--
PROCEDURE create_seeded_ff_sys_setup
  (p_object_name IN VARCHAR2,
  p_exception_status_msg_cd IN VARCHAR2,
  p_valid_status_msg_cd IN VARCHAR2,
  p_add_info_url IN VARCHAR2,
  p_enabled_flag IN VARCHAR2,
  p_foundation_hr_flag IN VARCHAR2,
  p_functional_area_cd IN VARCHAR2);

--
-- This procedure is used to create diagnostics associated with used defined fast formulas
--
-- p_object_name - The name of the fast formula. This is the value of column formula name of table ff_formulas_f
-- p_dynamic_sql - SQL to fetch information for all business group for this user defined fast formula
-- p_dynamic_sql_type - 'API' if the above column contains an api, otherwise null
-- p_exception_status_msg_cd - Message code for the message, which is displayed when the fast formula is in invalid status
-- p_valid_status_msg_cd - Message code for the message, which is displayed when the fast formula is in a valid state
-- p_impact_msg_name - Message code for the message, which is displayed when the fast formula has not been defined for any business group
-- p_add_info_url - URL for additional information on the fast formula
-- p_enabled_flag - Set this to Y, if the diagnostics for this fast formula is to be checked. Else set to N.
-- p_foundation_hr_flag - Set this to Y, if this fast formula is to be checked in Foundation HR. Else set to N.
-- p_functional_area_cd - The functional area to which the fast formula belongs. Valid values can be found by querying HR_LOOKUPS for lookup type HRI_FUNCTIONAL_AREA.
--
PROCEDURE create_usr_def_ff_sys_setup
  (p_object_name IN VARCHAR2,
  p_dynamic_sql IN VARCHAR2,
  p_dynamic_sql_type IN VARCHAR2,
  p_exception_status_msg_cd IN VARCHAR2,
  p_valid_status_msg_cd IN VARCHAR2,
  p_impact_msg_name IN VARCHAR2,
  p_add_info_url IN VARCHAR2,
  p_enabled_flag IN VARCHAR2,
  p_foundation_hr_flag IN VARCHAR2,
  p_functional_area_cd IN VARCHAR2);
--
-- This procedure is used to create diagnostics associated with buckets
--
-- p_object_name - The name of the bucket. This is the short_name column from table bis_bucket
-- p_dynamic_sql - SQL that returns N when correct number of ranges are not defined for buckets, else Y.
-- p_dynamic_sql_type - 'API' if the above column contains an api, otherwise null
-- p_exception_status_msg_cd - Message code for the message, which display the status of bucket, when the dynamic SQL returns N.
-- p_valid_status_msg_cd - Message code for the message, which display the status of bucket, when the dynamic SQL returns Y.
-- p_impact_msg_name - Message Code for the message, which display the impact message when the dynamic SQL return N.
-- p_enabled_flag - Set this to Y, if the diagnostics for this bucket is to be checked. Else set to N.
-- p_foundation_hr_flag - Set this to Y, if this bucket is to be checked in Foundation HR. Else set to N.
-- p_functional_area_cd - The functional area to which the bucket belongs. Valid values can be found by querying HR_LOOKUPS for lookup type HRI_FUNCTIONAL_AREA.
--
PROCEDURE create_bucket_sys_setup
  (p_object_name IN VARCHAR2,
  p_dynamic_sql IN VARCHAR2,
  p_dynamic_sql_type IN VARCHAR2,
  p_exception_status_msg_cd IN VARCHAR2,
  p_valid_status_msg_cd IN VARCHAR2,
  p_impact_msg_name IN VARCHAR2,
  p_enabled_flag IN VARCHAR2,
  p_foundation_hr_flag IN VARCHAR2,
  p_functional_area_cd IN VARCHAR2);
--
-- This procedure is used to create data diagnostics
--
-- p_object_name - The name of the object for the particular data diagnostic being created. This is a short code with underscores and no spaces. For ex. TOTAL_ASG_BY_ASGTYPE means total assignment by assignment type
-- p_object_type - The type of the object for the data diagnostics being created. It can be of same name as object name.
-- p_dynamic_sql - SQL which returns the data for the diagnostics
-- p_dynamic_sql_type - 'API' if the above column contains an api, otherwise null
-- p_impact_msg_name - Message for the message, which displays the impact of the diagnostics being displayed
-- p_enabled_flag - Set this to Y, if this data diagnostic is to be displayed
-- p_foundation_hr_flag - Set this to Y, if the data diagnostic is to be displayed in foundation HR
-- p_section_heading - Message code for the message, which displays section heading
-- p_section_count_desc - Message code for the message, which displays the section description in COUNT mode
-- p_section_detail_desc - Message code for the message, which displays the section description in DETAIL mode
-- p_sub_section_heading - Message code for the message which displays sub section heading
-- p_sub_section_count_desc - Message code for the message, which displays the sub section description in COUNT mode
-- p_sub_section_detail_desc - Message code for the message, which displays the sub section description in DETAIL mode
-- p_heading_for_count - Message code for the message, which displays the heading for count column in COUNT mode
-- p_heading_for_column1 - Message code for the message, which displays the heading for column 1, in the SQL provided in parameter p_dynamic_sql
-- p_heading_for_column2 - Message code for the message, which displays the heading for column 2, in the SQL provided in parameter p_dynamic_sql
-- p_heading_for_column3 - Message code for the message, which displays the heading for column 3, in the SQL provided in parameter p_dynamic_sql
-- p_heading_for_column4 - Message code for the message, which displays the heading for column 4, in the SQL provided in parameter p_dynamic_sql
-- p_heading_for_column5 - Message code for the message, which displays the heading for column 5, in the SQL provided in parameter p_dynamic_sql
-- p_default_sql_mode - Stores the values COUNT, DETAIL, DETAIL_RESTRICT, DETAIL_RESTRICT_COUNT.
-- p_seq_num - Stores the sequence, in which data diagnostics appear. It is suggested to keep enough numbers between two diagnostics, so that another diagnostic can be incorporated between the two in future, if required.
-- p_functional_area_cd - The functional area to which the data diagnostic belongs. Valid values can be found by querying HR_LOOKUPS for lookup type HRI_FUNCTIONAL_AREA.
--
PROCEDURE create_data_diagnostics
  (p_object_name IN VARCHAR2,
  p_object_type IN VARCHAR2,
  p_dynamic_sql IN VARCHAR2,
  p_dynamic_sql_type IN VARCHAR2,
  p_impact_msg_name IN VARCHAR2,
  p_enabled_flag IN VARCHAR2,
  p_foundation_hr_flag IN VARCHAR2,
  --
  -- object_type_msg_name
  -- Section heading
  --
  p_section_heading IN VARCHAR2,
  --
  -- object_type_desc
  -- Description for COUNT section
  --
  p_section_count_desc IN VARCHAR2,
  --
  -- object_type_dtl_desc_msg_name
  -- Description for DETAIL section
  --
  p_section_detail_desc IN VARCHAR2,
  --
  -- object_name_msg_name
  -- Subsection heading
  --
  p_sub_section_heading IN VARCHAR2,
  --
  -- object_name_desc
  -- Description for COUNT sub-section
  --
  p_sub_section_count_desc  IN VARCHAR2,
  --
  -- object_name_dtl_desc_msg_name
  -- Description for DETAIL sub section
  --
  p_sub_section_detail_desc IN VARCHAR2,
  --
  -- Heading of count column
  --
  p_heading_for_count IN VARCHAR2,
  --
  -- Heading of columns in detail mode as ordered in the dynamic SQL
  --
  p_heading_for_column1 IN VARCHAR2,
  p_heading_for_column2 IN VARCHAR2,
  p_heading_for_column3 IN VARCHAR2,
  p_heading_for_column4 IN VARCHAR2,
  p_heading_for_column5 IN VARCHAR2,
  --
  p_default_sql_mode IN VARCHAR2,
  --
  p_seq_num IN NUMBER,
  p_functional_area_cd IN VARCHAR2
  );
--
-- This procedure is used to delete an object from  the diagnostics metadata table
--
-- p_object_name - Name of the object for which you want to create the diagnostics
-- p_object_type - The type of object. Valid values are BUCKET,PROFILE,SEEDED_FAST_FORMULA,TABLE,TRIGGER,USER_DEFN_FAST_FORMULA. Object type of data diagnostic.
-- p_report_type - The report type of the object.Valid values are SYSTEM, DATA.
-- p_functional_area_cd - The functional area to which the object is being subscribed. Valid values can be found by querying HR_LOOKUPS for lookup type HRI_FUNCTIONAL_AREA.
--
PROCEDURE delete_object
  (p_object_name IN VARCHAR2,
  p_object_type IN VARCHAR2,
  p_report_type IN VARCHAR2,
  p_functional_area_cd IN VARCHAR2);
--
END hri_apl_diagnostics;

 

/
