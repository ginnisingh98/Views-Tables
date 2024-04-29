--------------------------------------------------------
--  DDL for Package HXC_PREFERENCE_EVALUATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_PREFERENCE_EVALUATION" AUTHID CURRENT_USER AS
/* $Header: hxcpfevl.pkh 120.6 2008/02/29 13:58:10 asrajago ship $ */



TYPE resplist_rec IS RECORD
(
   resp_id     NUMBER,
   start_date  DATE,
   stop_date   DATE );

TYPE resplisttab IS TABLE OF resplist_rec ;



Type r_pref_node_value is Record
(  pref_hierarchy_id hxc_pref_hierarchies.pref_hierarchy_id%TYPE
  ,pref_definition_id hxc_pref_hierarchies.pref_definition_id%TYPE
  ,attribute1 varchar(150)
  ,attribute2 varchar(150)
  ,attribute3 varchar(150)
  ,attribute4 varchar(150)
  ,attribute5 varchar(150)
  ,attribute6 varchar(150)
  ,attribute7 varchar(150)
  ,attribute8 varchar(150)
  ,attribute9 varchar(150)
  ,attribute10 varchar(150)
  ,attribute11 varchar(150)
  ,attribute12 varchar(150)
  ,attribute13 varchar(150)
  ,attribute14 varchar(150)
  ,attribute15 varchar(150)
  ,attribute16 varchar(150)
  ,attribute17 varchar(150)
  ,attribute18 varchar(150)
  ,attribute19 varchar(150)
  ,attribute20 varchar(150)
  ,attribute21 varchar(150)
  ,attribute22 varchar(150)
  ,attribute23 varchar(150)
  ,attribute24 varchar(150)
  ,attribute25 varchar(150)
  ,attribute26 varchar(150)
  ,attribute27 varchar(150)
  ,attribute28 varchar(150)
  ,attribute29 varchar(150)
  ,attribute30 varchar(150)
  ,edit_allowed  hxc_pref_hierarchies.edit_allowed%TYPE
  ,displayed hxc_pref_hierarchies.displayed%TYPE
  ,name hxc_pref_hierarchies.name%TYPE
  ,top_level_parent_id hxc_pref_hierarchies.top_level_parent_id%TYPE
  ,code hxc_pref_hierarchies.code%TYPE);

Type t_pref_node_value is Table of
r_pref_node_value
Index By BINARY_INTEGER;

Type r_pref_hier is Record
( Start_Index Number
 ,Stop_index Number
 ,caching_time Date);

Type t_pref_hier is Table of
r_pref_hier
Index By BINARY_INTEGER; -- Index is pref_hierarchy_id of the topmost parent.

-- Tables to cache preference values
g_pref_hier_ct t_pref_hier;
g_pref_values_ct t_pref_node_value;

-- public types used to manipulate preference information

TYPE t_pref_table_row IS RECORD
( preference_code hxc_pref_definitions.code%TYPE,
  attribute1      VARCHAR(150),
  attribute2      VARCHAR(150),
  attribute3      VARCHAR(150),
  attribute4      VARCHAR(150),
  attribute5      VARCHAR(150),
  attribute6      VARCHAR(150),
  attribute7      VARCHAR(150),
  attribute8      VARCHAR(150),
  attribute9      VARCHAR(150),
  attribute10     VARCHAR(150),
  attribute11     VARCHAR(150),
  attribute12     VARCHAR(150),
  attribute13     VARCHAR(150),
  attribute14     VARCHAR(150),
  attribute15     VARCHAR(150),
  attribute16     VARCHAR(150),
  attribute17     VARCHAR(150),
  attribute18     VARCHAR(150),
  attribute19     VARCHAR(150),
  attribute20     VARCHAR(150),
  attribute21     VARCHAR(150),
  attribute22     VARCHAR(150),
  attribute23     VARCHAR(150),
  attribute24     VARCHAR(150),
  attribute25     VARCHAR(150),
  attribute26     VARCHAR(150),
  attribute27     VARCHAR(150),
  attribute28     VARCHAR(150),
  attribute29     VARCHAR(150),
  attribute30     VARCHAR(150),
  start_date      DATE,
  end_date        DATE,
  rule_evaluation_order hxc_resource_rules.rule_evaluation_order%TYPE,
  edit_allowed    hxc_pref_hierarchies.edit_allowed%TYPE,
  displayed       hxc_pref_hierarchies.displayed%TYPE,
  name            hxc_pref_hierarchies.name%TYPE);

g_maxloop NUMBER := 50000;
g_loop_count NUMBER;

TYPE t_pref_table IS TABLE OF
t_pref_table_row
INDEX BY BINARY_INTEGER;

TYPE t_resource_list IS TABLE OF
NUMBER(15)
INDEX BY BINARY_INTEGER;

-- global table to support function used in views.

g_pref_table t_pref_table;

-- Bulk Preference

-- Table holding index of pref values table for the corresponding resource_id
TYPE r_resource_pref_row IS RECORD
( start_index number,
  stop_index  number);

TYPE t_resource_pref_table IS TABLE OF
r_resource_pref_row
INDEX BY BINARY_INTEGER;

-- Table holding index of pref sets table and pref values table
TYPE r_pref_sets_index_row is record
( set_start number,
  set_stop  number,
  result_start number,
  result_stop number);

type t_pref_sets_index_table is table of
r_pref_sets_index_row
index by binary_integer;

-- Table holding Pref-REO sets
type r_pref_sets_row is record
( reo number,
  pref_hier_id number);

type t_pref_sets_table is table of
r_pref_sets_row
index by binary_integer;

-- Table holding all the rules associated to the resource_ids being evaluated.
type r_resource_elig_row is record
( criteria_id number,
  pref_hier_id number,
  reo number
);

type t_resource_elig_table is table of
r_resource_elig_row
index by binary_integer;

-- Procedures / functions to get resource preferences

-- Function to get the value of a attribute of a preference code for a given resource
-- Example:
-- resource_preferences(10150,'TC_W_TCRD_LAYOUT',1);
--
FUNCTION resource_preferences(p_resource_id IN NUMBER,
                              p_pref_code in VARCHAR2,
                              p_attribute_n IN NUMBER,
                              p_evaluation_date IN DATE DEFAULT sysdate,
                              p_resp_id IN number default -99) RETURN VARCHAR2;


-- Procedure to get the values of all the attributes of a list of preferences for a given
-- resource
-- Example:
-- resource_preferences(10150,'TC_W_TCRD_LAYOUT,TS_PER_APPLICATION_SET',l_pref_table);
--
PROCEDURE resource_preferences(p_resource_id IN NUMBER,
                               p_pref_code_list in VARCHAR2,
                               p_pref_table IN OUT NOCOPY t_pref_table,
                               p_evaluation_date IN DATE DEFAULT sysdate,
                               p_resp_id IN NUMBER DEFAULT -99);


-- Procedure to get the value of all the attributes of all the preferences for a given
--  resource
-- Example:
-- resource_preferences(10150,l_pref_table,sysdate,-1,-1);
--
PROCEDURE resource_preferences(p_resource_id IN NUMBER,
                               p_pref_table IN OUT NOCOPY t_pref_table,
                               p_evaluation_date IN DATE DEFAULT sysdate,
                               p_user_id IN number DEFAULT fnd_global.user_id,
			       p_resp_id IN number DEFAULT -99,
			       p_ignore_user_id in BOOLEAN default FALSE,
			       p_ignore_resp_id in BOOLEAN default FALSE);

-- Bulk evaluation of preferences - calculates preferences for a list of resource_ids
-- this is a single date evaluation
-- does not consider responsibility and login based preferences.

procedure resource_prefs_bulk ( p_evaluation_date in date,
                                p_pref_table IN OUT NOCOPY t_pref_table,
                                p_resource_pref_table IN OUT NOCOPY t_resource_pref_table,
                                p_resource_sql in  varchar2  );




-- Procedure to load global g_pref_table with preferences

PROCEDURE set_resource_preferences(p_resource_id IN NUMBER,
                                   p_evaluation_date IN DATE DEFAULT sysdate );

-- same for range based prefs.
PROCEDURE set_resource_preferences(p_resource_id IN NUMBER,
                                   p_start_evaluation_date DATE,
                                   p_end_evaluation_date DATE);

-- Procedure to get preferences from the global g_pref_table. (Without recalculation)

FUNCTION get_resource_preferences(p_resource_id IN NUMBER,
                                   p_pref_id IN NUMBER,
                                   p_attn in VARCHAR2) RETURN VARCHAR2;


-- 1) Procedure to get the values of specified codes and attributes for a given resource.
-- Result is returned as a string.
-- Example:
-- resource_preferences(10150,'TC_W_TCRD_LAYOUT|1|2|3|,TS_PER_APPLICATION_SET|1|20|13|5|,
--                                       TC_W_TCRD_DISPLAY_DAYS|1|2|3|4|5|6|7|'));
-- This brings back the following string:
-- 3|4|5|1||||N|Y|Y|Y|Y|Y|N
--

FUNCTION resource_preferences(p_resource_id IN NUMBER,
                              p_pref_spec_list IN VARCHAR2,
                              p_evaluation_date IN DATE DEFAULT sysdate) RETURN VARCHAR2;

-- Same as 1), but allows you to specify the output separator
-- Named separately since this without default looks like the above function (ignoring the date/varchar
-- difference)

FUNCTION resource_pref_sep(p_resource_id IN NUMBER,
                              p_pref_spec_list IN VARCHAR2,
                              p_output_separator IN VARCHAR2,
                              p_evaluation_date IN DATE DEFAULT sysdate) RETURN VARCHAR2;

-- Further modification of 1) that will return a fatal error to calling code, letting the
-- caller handle the error. This is useful in Oracle Reports (where calling prefs from a
-- formula.

FUNCTION resource_pref_errcode(p_resource_id IN NUMBER,
                               p_pref_spec_list IN VARCHAR2,
                               p_message IN OUT NOCOPY VARCHAR,
                               p_evaluation_date IN DATE DEFAULT sysdate) RETURN VARCHAR2;

----
-- Procedure to get the values of all the attributes of all the preferences for a
-- range of dates.
----

PROCEDURE resource_preferences(p_resource_id  in NUMBER,
                               p_start_evaluation_date DATE,
                               p_end_evaluation_date DATE,
                               p_pref_table IN OUT NOCOPY  t_pref_table,
                               p_no_prefs_outside_asg IN BOOLEAN DEFAULT FALSE,
                               p_resp_id IN number default -99,
                               p_resp_appl_id IN NUMBER DEFAULT fnd_global.resp_appl_id,
			       p_ignore_resp_id in boolean default false);

-- Same as above but allows specification of preference code.
-- This filters the pref table for the specified preference and
-- sorts the preferences by start_date in ascending order.
-- (first item being the earliest date and so on).
-- The table produced is contiguous and starts at index 1
--
-- It also caches the whole preference table and only clears the cache when
--
--    i)   the p_clear_cache param is TRUE
--    ii)  the p_resource_id does not match the resource id in the cache
--    iii) the resource id matches but the evaluation dates do not

PROCEDURE resource_preferences(p_resource_id  in NUMBER,
			       p_preference_code IN VARCHAR2,
                               p_start_evaluation_date DATE,
                               p_end_evaluation_date DATE,
                               p_sorted_pref_table IN OUT NOCOPY  t_pref_table,
			       p_clear_cache BOOLEAN DEFAULT FALSE,
                               p_no_prefs_outside_asg IN BOOLEAN DEFAULT FALSE);

-- This is the overloaded version of the above procedure which allows
-- the user to pass their preference table. In this case the passed
-- pref table is substitued for the cached pref table

PROCEDURE resource_preferences(p_resource_id  in NUMBER,
			       p_preference_code IN VARCHAR2,
                               p_start_evaluation_date DATE,
                               p_end_evaluation_date DATE,
                               p_sorted_pref_table IN OUT NOCOPY  t_pref_table,
			       p_clear_cache BOOLEAN DEFAULT FALSE,
			       p_master_pref_table t_pref_table );

-- this clears the pref table cache when preference evaluation is finished
-- to allow memory saving.

PROCEDURE clear_sort_pref_table_cache;

----
-- Supporting function to allow inquiries as to whether specific values have been used
-- in preference hierarchies. Useful for data integrity checking.
----

FUNCTION num_hierarchy_occurances(p_preference_code IN VARCHAR2,
                                  p_attributen      IN NUMBER,
                                  p_value           IN VARCHAR2) RETURN NUMBER;

   FUNCTION migration_mode
      RETURN BOOLEAN;

   PROCEDURE set_migration_mode (p_migration_mode IN BOOLEAN);

   FUNCTION employment_ended (
      p_person_id        per_all_people_f.person_id%TYPE,
      p_effective_date   per_all_assignments_f.effective_start_date%TYPE
            DEFAULT SYSDATE
   )
      RETURN BOOLEAN;

   FUNCTION assignment_last_eff_dt (
      p_person_id        per_all_people_f.person_id%TYPE,
      p_effective_date   per_all_assignments_f.effective_start_date%TYPE
            DEFAULT SYSDATE
   )
      RETURN per_all_assignments_f.effective_start_date%TYPE;

   FUNCTION evaluation_date (
      p_resource_id       hxc_time_building_blocks.resource_id%TYPE,
      p_evaluation_date   DATE
   )
      RETURN DATE;

  FUNCTION check_number(
     p_string                 varchar2
   )
     RETURN number ;

 FUNCTION return_version_id (
      p_criteria  hxc_resource_rules.eligibility_criteria_id%TYPE,
      p_eligibility_type hxc_resource_rules.eligibility_criteria_type%TYPE
   )
     RETURN NUMBER;

 FUNCTION get_tc_resp (	p_resource_id NUMBER,
     			p_evaluation_date DATE)
 RETURN NUMBER;

 PROCEDURE get_tc_resp ( p_resource_id 		 IN NUMBER,
 			 p_start_evaluation_date IN DATE,
 			 p_end_evaluation_date 	 IN DATE,
 			 p_resp_id 		 OUT NOCOPY NUMBER,
			 p_resp_appl_id 	 OUT NOCOPY NUMBER) ;

PROCEDURE get_tc_resp (	p_resource_id           IN NUMBER,
			p_start_evaluation_date IN DATE,
			p_end_evaluation_date   IN DATE,
                        p_resplist              OUT NOCOPY resplisttab )  ;


FUNCTION resource_preferences(p_resource_id        IN NUMBER,
                              p_pref_code          IN VARCHAR2,
                              p_attribute_n        IN NUMBER,
                              p_resp_id 	   IN NUMBER )
RETURN VARCHAR2;

END hxc_preference_evaluation;

/
