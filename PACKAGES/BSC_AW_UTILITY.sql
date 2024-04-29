--------------------------------------------------------
--  DDL for Package BSC_AW_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_AW_UTILITY" AUTHID CURRENT_USER AS
/*$Header: BSCAWUTS.pls 120.25 2006/03/27 14:46 vsurendr noship $*/

/*
Supported options
option -> calling program -> description

Common:
--------
DEBUG LOG -> ALL -> Turns on debug logging
TRACE -> ALL -> Turns trace on
UTL_FILE_LOG -> Loader -> specifies the dir for the child parallel processes to write the log file to
NO PARALLEL -> Loader -> Hint to turn off parallel load and aggregations
RECREATE KPI -> GDB -> drops and recreates the KPI if the kpi exists
SUMMARIZATION LEVEL -> GDB -> Adv summarization level

Less Common:
------------
TABLESPACE -> GDB -> Specify the tablespace to create the AW worksace on
SEGMENTSIZE -> GDB -> Specify the segment size for the AW workspace
AGGREGATE TIME -> GDB -> Specifies that all levels of time be aggregated
PARTITION -> GDB -> Force Creates partitioned cubes for KPI, 10g and beyond
NO PARTITION -> GDB -> Force Non partitioned cubes for KPI, even if partitions possible
NUMBER PARTITION -> GDB -> Overrides default number of partitions
NO COMPRESSED COMPOSITE -> GDB -> No compressed composite, even if compressed composite possible
NO DISPLAY CUBE -> GDB -> Do not create display cubes. This means no partitions when there are avg measures
AGGREGATE TIME -> GDB -> Force aggregation at load on time dim rather than at query time
NO TARGET PARTITION -> GDB -> Do not partition dimsets that have targets at higher levels

Special Purpose:
----------------
RECREATE PROGRAM -> GDB -> Recreates the dml load programs for the object
RECREATE CALENDAR -> Calendar Module -> Forces the recreation of the calendar
COMPRESSED COMPOSITE -> GDB -> Hint to the system to try and create the kpi with compressed composites for 10.1.0.4.

Advanced, Rarely used:
----------------------
NO LIMIT CUBE COMPOSITE -> GDB -> Creates limit cubes without composite
NO DATACUBE -> GDB -> Creates individual cubes per measure in 10g
NO DETACH WORKSPACE -> Loader/Calendar -> Refreshes the calendar without detaching the workspace
FILE LOG -> used in bscawrdb, for internal purposes to turn on file debugging instead of fnd table debugging
*/

--program runtime parameters
g_debug boolean;
g_debug_level varchar2(30);
g_stmt varchar2(32000);
g_job_wait_time_large constant number:=10;
g_job_wait_time_small constant number:=5;
g_max_wait_time constant number:=36000; --max system wait of 10 hrs
g_max_partitions constant number:=16;
g_infinite_loop constant number:=1000000;
g_exception exception;
g_db_version number;
g_newline constant varchar2(20):='
';
g_trace_set boolean;
pragma exception_init(g_exception,-20000);
g_log_level constant number:=FND_LOG.LEVEL_STATEMENT;
g_upgrade_version constant number:=3;
g_parallel_load_cutoff constant number:=50000;/*more than these rows is parallel load if possible */
g_parallel_aggregate_cutoff constant number:=1000000;/*more than these composite nodes is parallel formula if possible*/
g_parallel_target_cutoff constant number:=1000000;/*more than these composite nodes is parallel target to actual copy if possible*/
---TYPES------------
type varchar2_table is table of varchar2(400) index by varchar2(400);
type number_table is table of number index by varchar2(400);
type boolean_table is table of boolean index by varchar2(400);
--sqlerror is sqlcode and message
type sqlerror_r is record(
sql_code number,
action varchar2(40),--ignore etc
message varchar2(2000)
);
type sqlerror_tb is table of sqlerror_r index by pls_integer;
g_sqlerror sqlerror_tb;
--value_tb is used to parse out the options
type value_r is record(
parameter varchar2(8000),
value varchar2(8000)
);
type value_tb is table of value_r index by pls_integer;
type value_tv is table of value_r index by varchar2(200);
--
type property_r is record(
property_name varchar2(200),
property_type varchar2(200),
property_value varchar2(8000)
);
type property_tb is table of property_r index by pls_integer;
type property_tv is table of property_r index by varchar2(200);
--
type object_r is record(
object_name varchar2(300),
object_type varchar2(100)
);
type object_tb is table of object_r index by pls_integer;
--
--used to normalize a denorm parent child relation
type parent_child_r is record(
parent varchar2(200),
child varchar2(200),
status varchar2(40)
);
type parent_child_tb is table of parent_child_r index by pls_integer;
--
g_options value_tb;
--
type parallel_job_r is record(
job_name varchar2(100),--same name is used in the pipe
run_id integer,--we give it a id 1,2 3 etc
job_id integer,--dbms job id
start_time varchar2(40),--populate with get_time
end_time varchar2(40),
status varchar2(40),
sqlcode number,
message varchar2(2000) --if there is some error
);
type parallel_job_tb is table of parallel_job_r index by pls_integer;
g_parallel_jobs parallel_job_tb;
--
type new_values_r is record(
id number,
new_values dbms_sql.varchar2_table
);
type new_values_tb is table of new_values_r index by pls_integer;
g_values new_values_tb;
--
type all_tables_tb is table of all_tables%rowtype index by pls_integer;
-------
type partition_r is record(
partition_name varchar2(40), --P0
partition_value varchar2(40), --'0'
partition_position number
);
type partition_tb is table of partition_r index by pls_integer;
--
type partition_set_r is record(  --contains the partitions
set_name varchar2(40),
partition_type varchar2(40), --range, list, hash
partition_column varchar2(32000), --for hash, we will have comma separated list
partition_column_data_type varchar2(32000), --data type
partitions partition_tb
);
--
type object_partition_r is record(
main_partition partition_set_r,
sub_partition partition_set_r
);
--
/*data structures to hold statistic information */
type stats_r is record(
stats_name varchar2(100),
value number,
diff_value number
);
type stats_tb is table of stats_r index by pls_integer;
--
type wait_event_r is record(
event_name varchar2(100),
total_waits number,
total_timeouts number,
time_waited number, /*100th of a second*/
average_wait number,/*100th of a second*/
max_wait number, /*100th of a second*/
--
diff_total_waits number,
diff_total_timeouts number,
diff_time_waited number
);
type wait_event_tb is table of wait_event_r index by pls_integer;
--
type session_stats_r is record(
stats_name varchar2(200),
stats_time date,
stats stats_tb,
wait_events wait_event_tb
);
type session_stats_tb is table of session_stats_r index by pls_integer;
--
type session_stats_group_r is record(
group_name varchar2(200),
session_stats session_stats_tb
);
type session_stats_group_tb is table of session_stats_group_r index by pls_integer;
--
g_ssg session_stats_group_tb;
--------
--procedures-------------------------------------------------------
function in_array(
p_array dbms_sql.varchar2_table,
p_value varchar2
) return boolean;
function in_array(
p_array dbms_sql.number_table,
p_value number
) return boolean;
function in_array(
p_array varchar2_table,
p_value varchar2
) return boolean;
function get_parameter_value(p_string varchar2,p_parameter varchar2,p_separator varchar2) return varchar2;
function get_parameter_value(p_options value_tb,p_parameter varchar2) return varchar2 ;
function get_min(num1 number,num2 number) return number;
function contains(p_text varchar2,p_check varchar2) return boolean;
--used to populate created by etc
function get_who return number;
procedure delete_aw_object(p_object varchar2);
procedure execute_ddl_ne(p_stmt varchar2);
procedure execute_ddl(p_stmt varchar2);
procedure delete_table(p_table varchar2,p_where varchar2);
procedure resolve_into_value_r(
p_string varchar2,
p_value out nocopy value_r);
procedure parse_parameter_values(
p_string varchar2,
p_separator varchar2,
p_values out nocopy value_tb
);
procedure normalize_denorm_relation(p_relation in out nocopy parent_child_tb);
procedure make_stmt_for_aw(p_program varchar2,p_stmt in out nocopy varchar2,p_type varchar2);
procedure add_g_commands(p_commands in out nocopy dbms_sql.varchar2_table,p_command varchar2);
procedure trim_g_commands(p_commands in out nocopy dbms_sql.varchar2_table,p_trim number,p_add varchar2) ;
procedure exec_program_commands(p_program varchar2,p_commands dbms_sql.varchar2_table);
procedure dmp_g_options(p_options value_tb);
procedure create_temp_tables;
procedure parse_out_agg_function(p_formula varchar2,p_noagg_formula out nocopy varchar2);
function get_max(p_array dbms_sql.number_table) return number;
procedure exec_aw_program_aggmap(p_name varchar2,p_commands dbms_sql.varchar2_table,p_type varchar2);
procedure exec_aggmap_commands(p_aggmap varchar2,p_commands dbms_sql.varchar2_table);
function does_table_have_data(p_table varchar2,p_where varchar2) return varchar2;
function is_std_aggregation_function(p_agg_formula varchar2) return varchar2;
function is_in_between(p_input number,p_left number,p_right number) return boolean ;
function is_ascii(p_char varchar2) return boolean ;
function is_string_present(
p_string varchar2,
p_text varchar2,
p_location out nocopy dbms_sql.number_table
) return boolean ;
procedure replace_string(
p_string in out nocopy varchar2,
p_old_text varchar2,
p_new_text varchar2,
p_start_array dbms_sql.number_table
);
function get_adv_sum_profile return number ;
FUNCTION get_apps_schema_name RETURN VARCHAR2;
function get_table_owner(p_table varchar2) return varchar2 ;
procedure truncate_table(p_table varchar2);
function get_db_version return number ;
procedure write_to_file(p_type varchar2,p_message varchar2,p_new_line boolean);
procedure log(p_message varchar2);
procedure log_s(p_message varchar2) ;
procedure log_n(p_message varchar2);
procedure convert_varchar2_to_table(
p_string varchar2,
p_limit number,
p_table out nocopy dbms_sql.varchar2_table
);
procedure drop_db_object_ne(p_object varchar2,p_object_type varchar2);
procedure drop_db_object(p_object varchar2,p_object_type varchar2);
procedure execute_stmt(p_stmt varchar2);
procedure sleep(p_sleep_time integer,p_random_time integer);
procedure remove_array_element(p_array in out nocopy dbms_sql.varchar2_table,p_object varchar2);
procedure start_job(
p_job_name varchar2,
p_run_id number,
p_process varchar2,
p_options varchar2
);
function get_parallel_job(p_job_name varchar2) return parallel_job_r;
procedure wait_on_jobs(
p_options varchar2,
p_job_status out nocopy parallel_job_tb
);
procedure update_job_status(p_parallel_job in out nocopy parallel_job_r);
function get_pipe_message(p_pipe_name varchar2) return varchar2;
procedure remove_pipe(p_pipe_name varchar2);
function is_job_running(p_job_id number) return varchar2;
procedure clean_up_jobs(p_options varchar2);
function can_launch_jobs(p_number_jobs number) return varchar2;
function count_jobs_running return number;
function get_vparameter(p_name varchar2) return varchar2;
function get_option_string return varchar2;
function get_session_id return number;
procedure create_pipe(p_pipe_name varchar2);
procedure send_pipe_message(p_pipe_name varchar2,p_message varchar2);
procedure dmp_parallel_jobs;
function make_string_from_list(p_list dbms_sql.varchar2_table) return varchar2;
function make_string_from_list(p_list dbms_sql.varchar2_table,p_separator varchar2) return varchar2;
procedure parse_parameter_values(
p_string varchar2,
p_separator varchar2,
p_values out nocopy dbms_sql.varchar2_table
);
function get_parameter_value(p_parameter varchar2) return varchar2;
procedure add_option(p_options varchar2,p_option_value varchar2,p_separator varchar2);
procedure execute_stmt_ne(p_stmt varchar2);
function get_hash_value(p_string varchar2,p_start number,p_end number) return varchar2 ;
function get_dbms_time return number;
function get_random_number(p_seed number) return number;
procedure merge_array(p_array in out nocopy dbms_sql.varchar2_table,p_values dbms_sql.varchar2_table);
procedure merge_value(p_array in out nocopy dbms_sql.varchar2_table,p_value varchar2);
procedure subtract_array(p_array in out nocopy dbms_sql.varchar2_table,p_values dbms_sql.varchar2_table);
procedure set_aw_trace;
procedure dmp_values(p_table dbms_sql.varchar2_table,p_text varchar2);
function get_sqlerror(p_sqlcode number,p_action varchar2) return sqlerror_r;
procedure add_sqlerror(p_sqlcode number,p_action varchar2,p_message varchar2);
function is_sqlerror(p_sqlcode number,p_action varchar2) return boolean;
procedure remove_sqlerror(p_sqlcode number,p_action varchar2);
procedure remove_all_sqlerror;
function compare_pc_relations(p_pc_1 parent_child_tb,p_pc_2 parent_child_tb) return number;
procedure init_is_new_value;
procedure init_is_new_value(p_index number);
function is_new_value(p_value varchar2,p_index number) return boolean;
function is_new_value(p_value number,p_index number) return boolean;
function order_array(p_array dbms_sql.varchar2_table) return dbms_sql.varchar2_table;
function make_upper(p_array dbms_sql.varchar2_table) return dbms_sql.varchar2_table;
function is_avg_aggregation_function(p_agg_formula varchar2) return varchar2;
procedure get_db_lock(p_lock_name varchar2);
procedure release_db_lock(p_lock_name varchar2);
function get_lock_handle(p_lock_name varchar2) return varchar2 ;
function can_launch_dbms_job(p_number_jobs number) return varchar2;
function get_closest_2_power_number(p_number number) return number;
function get_db_table_parameters(p_table varchar2,p_owner varchar2) return all_tables_tb;
procedure analyze_table(p_table varchar2,p_owner varchar2);
procedure analyze_table(p_table varchar2,p_interval number);
procedure log_fnd(p_message varchar2,p_severity number);
procedure set_option(p_parameter varchar2,p_value varchar2);
function get_g_commands(p_commands dbms_sql.varchar2_table,p_index number) return varchar2;
procedure get_upper_trim_hier(p_parent_child parent_child_tb,p_seed varchar2,p_trim_parent_child in out nocopy parent_child_tb);
procedure get_lower_trim_hier(p_parent_child parent_child_tb,p_seed varchar2,p_trim_parent_child in out nocopy parent_child_tb);
procedure get_parent_values(p_parent_child parent_child_tb,p_child varchar2,p_parents out nocopy parent_child_tb);
procedure get_child_values(p_parent_child parent_child_tb,p_parent varchar2,p_children out nocopy parent_child_tb);
procedure get_all_parents(p_parent_child parent_child_tb,p_child varchar2,p_parents in out nocopy dbms_sql.varchar2_table);
procedure get_all_children(p_parent_child parent_child_tb,p_parent varchar2,p_children in out nocopy dbms_sql.varchar2_table);
procedure update_property(p_string in out nocopy varchar2,p_parameter varchar2,p_value varchar2,p_separator varchar2);
procedure merge_property(p_property in out nocopy property_tb,p_property_name varchar2,p_property_type varchar2,p_property_value varchar2);
procedure remove_property(p_property in out nocopy property_tb,p_property_name varchar2);
function get_property(p_property property_tb,p_property_name varchar2) return property_r;
procedure merge_property(p_property in out nocopy property_tb,p_property_string varchar2,p_separator varchar2);
function get_property_string(p_property property_tb) return varchar2;
procedure merge_array(p_array in out nocopy dbms_sql.number_table,p_values dbms_sql.number_table);
procedure merge_value(p_array in out nocopy dbms_sql.number_table,p_value number);
function get_cpu_count return number;
procedure load_stats(p_name varchar2,p_group varchar2);
procedure load_session_stats(p_stats out nocopy stats_tb);
procedure load_session_waits(p_wait_events out nocopy wait_event_tb);
function get_session_stats_group(p_group varchar2) return session_stats_group_r;
procedure print_stats(p_group varchar2);
procedure clean_stats(p_group varchar2);
procedure clean_stats(p_ssg in out nocopy session_stats_group_r);
procedure print_stats(p_ssg session_stats_group_r);
procedure print_stats(p_session_stats session_stats_r);
procedure print_session_stats(p_stats stats_tb);
procedure print_session_wait(p_wait_events wait_event_tb);
procedure diff_stats(p_ssg in out nocopy session_stats_group_r);
procedure diff_session_stats(p_new_stats in out nocopy stats_tb,p_old_stats stats_tb);
procedure diff_waits(p_ssg in out nocopy session_stats_group_r);
procedure diff_session_wait(p_new_wait in out nocopy wait_event_tb,p_old_wait wait_event_tb);
function get_ssg_index(p_group varchar2) return pls_integer;
procedure kill_session(p_sid number,p_serial number);
function is_PT_aggregation_function(p_agg_formula varchar2) return varchar2 ;
function get_array_index(
p_array dbms_sql.varchar2_table,
p_value varchar2
) return number;
function get_array_index(
p_array dbms_sql.number_table,
p_value number
) return number;
function is_CC_aggregation_function(p_agg_formula varchar2) return varchar2;
procedure check_jobs(p_parallel_jobs in out nocopy parallel_job_tb);
function check_all_jobs_complete(p_parallel_jobs parallel_job_tb) return boolean;
procedure wait_on_jobs_sleep(p_options varchar2,p_job_status out nocopy parallel_job_tb);
function get_table_count(p_table varchar2,p_where varchar2) return number;
function is_number(p_number varchar2) return boolean ;
procedure create_perm_tables;
--procedures-------------------------------------------------------
procedure init_all(p_debug boolean);
procedure init_all_procedures;
function get_time return varchar2;
procedure open_file(p_object_name varchar2);
-------------------------------------------------------------------

END BSC_AW_UTILITY;

 

/
