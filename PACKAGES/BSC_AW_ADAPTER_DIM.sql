--------------------------------------------------------
--  DDL for Package BSC_AW_ADAPTER_DIM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_AW_ADAPTER_DIM" AUTHID CURRENT_USER AS
/*$Header: BSCAWADS.pls 120.13 2006/03/20 18:07 vsurendr noship $*/
--program runtime parameters
g_debug boolean;
g_stmt varchar2(32000);
--cache a series of aw commands to execute...creating aw program
g_commands dbms_sql.varchar2_table;
g_exception exception;
g_corrected_dim dbms_sql.varchar2_table;
----records----------------
type dim_parent_child_r is record(
parent_level varchar2(200),
child_level varchar2(200),
child_fk varchar2(200),
parent_pk varchar2(200),
level_set number --this is grouping of levels to sets. each set is a dim
);
type dim_parent_child_tb is table of dim_parent_child_r index by pls_integer;
--
type level_pk_r is record(
pk varchar2(200),
data_type varchar2(40)
);
type levels_r is record(
level_name varchar2(200),
level_id number,
position number, --for norml dim, lowest level is 1, for rec, top level is 1. but for rec dim, this is not set
property varchar2(200),
seed_values dbms_sql.varchar2_table,--these are seed values for the dim level. used by projection dim
pk level_pk_r,
filter_variable varchar2(300),
limit_variable varchar2(300),
level_name_dim varchar2(300), --reqd for snow flake implementation
relation_name varchar2(300), --reqd for snow flake implementation ie. this dim level as stand alone dim
level_source varchar2(40) --view or table, dbi etc
);
type levels_tv is table of levels_r index by varchar2(200);
type levels_tb is table of levels_r index by pls_integer;
--
type zero_levels_r is record(
level_name varchar2(200),
child_level_name varchar2(200) --this is the real level for which this is the zero code level
);
type zero_levels_tv is table of zero_levels_r index by varchar2(200);
type zero_levels_tb is table of zero_levels_r index by pls_integer;
--
--these are virtual levels used for rec dim
type rec_levels_r is record(
level_name varchar2(200),
child_level_name varchar2(200)
);
type rec_levels_tv is table of rec_levels_r index by varchar2(200);
type rec_levels_tb is table of rec_levels_r index by pls_integer;
--
--what are the kpi that have this dim
type kpi_for_dim_r is record(
kpi varchar2(200),
dim_set dbms_sql.varchar2_table
);
type kpi_for_dim_tb is table of kpi_for_dim_r index by pls_integer;
--
--this will be used by DBI dimensions both rec and non-rec
--we will match between dim_name and pk_col when we construct the :append <DIM> stmts
type dim_data_source_r is record(
dim_name dbms_sql.varchar2_table,
pk_col dbms_sql.varchar2_table, --this is the pk col of the relation table
data_source varchar2(8000), --(select distinct ...from table)
inc_data_source varchar2(8000),
child_col varchar2(100), --of the denorm table
parent_col varchar2(100), --of the denorm table
position_col varchar2(100), --of the denorm table. if null, set this to value "1"
denorm_data_source varchar2(8000), --select employee,manager from  ...
denorm_change_data_source varchar2(8000) --this holds the delta of the prev version of the hier.
--we use the data in denorm_change_data_source to set the value of the dim relation to NA, because this
--is the parent child relations that no longer exists
);
type dim_data_source_tb is table of dim_data_source_r index by pls_integer;
--
/*
we need the level group concept to handle dimension changes over time. earlier, we dropped and recreated the dim with
any change. this has the problem that kpi need to re-created, losing data. the soln is to age the dim and over time,
once no one uses it, simply drop it.
the other issue is that PMD will not flag any kpi for change if a dim level not used is altered. this can be a problem for aw
if the dim is created using all available dim levels.
Note! get parent and get child will only return levels that are used by AW. at anytime, a dim is levels that are used by aw kpi
say we start with dim A>B>C>D<E   kpi are on a, a-b, a-b-c, d, d-e, d-e-f, a-b-c-d etc
                            F
C is dropped. def is changed to D<E<F
any kpi that used C is marked for structural change. any kpi that looked at F>D relation is marked for structural change. kpi
that looked at a, a-b,d,d-e etc are not. we have api call that MO would call, implement_dim_aw(p_kpi_list). this call will be
triggered for any kpi marked for change, including the ones marked for deletes.
the new dim are A>B and D<E<F. first, A>B is read in. for any level in the new dim, check any old implementation that has it.
dim1 has it. check 2 aspects. levels, and level relations. we wil find that C is no longer there, relations b>c, f>d are invalid.
the initial 1 level group now gets split into 3
group 1 a>b
group 2 e>d
group 3 f
we correct level name dim, regenarete the program. each level group has levels, level relations and data source. they are like
dimset inside a kpi
we have aged the dim. no new additions are brought in. we make a new dim for A>B and a new dim for F>E>D
*/
type level_group_r is record(
level_group_name varchar2(200),
levels levels_tb,
parent_child dim_parent_child_tb,
zero_levels zero_levels_tb,
rec_levels rec_levels_tb,
data_source dim_data_source_r, --for non-rec dbi dim, denorm_data_source will be null
property bsc_aw_utility.value_tb
);
type level_group_tb is table of level_group_r index by pls_integer;
--
--if recursive_imp_with_norm_hier is Y then we do not have adv sum profile for the dim. we aggregate to all levels
type dimension_r is record(
dim_name varchar2(200),
dim_type varchar2(100), --std dim or non std dim(custom), dbi dim etc
concat varchar2(10),--Y or N
property varchar2(1000),
relation_name varchar2(200),
level_name_dim varchar2(300),
recursive varchar2(10),
recursive_norm_hier varchar2(20),--rec dim implemented with normalized hier.
kpi_for_dim kpi_for_dim_tb,
level_groups level_group_tb,
initial_load_program varchar2(300), --program names
inc_load_program varchar2(300),
filter_variable varchar2(300),
limit_variable varchar2(300),
rec_level_position_cube varchar2(300), --used only for rec dim implemented as denorm hier
base_value_cube varchar2(200), --holds the base value. used in the creation of the olap table function
corrected varchar2(40) --Y or N. Y means this is a corrected old copy for the levels involved. new kpi are assigned to idm with N
);
type dimension_tb is table of dimension_r index by pls_integer;
--------------------
g_dimensions dimension_tb;
---procedures-------------------------------------------------------
procedure create_dim(
p_dim_level_list dbms_sql.varchar2_table,
p_affected_kpi in out nocopy dbms_sql.varchar2_table
);
procedure get_all_dim_levels(
p_dim_level_list dbms_sql.varchar2_table,
p_dim_parent_child out nocopy dim_parent_child_tb,
p_dim_levels out nocopy levels_tv
);
procedure group_levels_into_sets(
p_dim_parent_child in out nocopy dim_parent_child_tb
);
procedure assign_set_to_level(
p_dim_parent_child in out nocopy dim_parent_child_tb,
p_level_considered in out nocopy dbms_sql.varchar2_table,
p_level varchar2,
p_set number
);
procedure create_dim(
p_dim_parent_child dim_parent_child_tb,
p_dim_levels levels_tv,
p_dimensions out nocopy dimension_tb
);
procedure reset_dimension_r(p_dim in out nocopy dimension_r);
procedure set_level_position(
p_dimension in out nocopy dimension_r
);
procedure set_level_position(
p_dimension in out nocopy dimension_r,
p_level varchar2,
p_position number
);
procedure get_kpi_for_dim(p_dimension in out nocopy dimension_r);
procedure create_virtual_zero_code_level(
p_dimension in out nocopy dimension_r
);
procedure create_virtual_rec_level(
p_dimension in out nocopy dimension_r
);
procedure implement_dim_aw(
p_dimensions in out nocopy dimension_tb,
p_affected_kpi in out nocopy dbms_sql.varchar2_table
);
procedure implement_dim_aw(
p_dimension in out nocopy dimension_r,
p_affected_kpi in out nocopy dbms_sql.varchar2_table
);
procedure drop_kpi_objects_for_dim(p_dim_name varchar2,p_affected_kpi in out nocopy dbms_sql.varchar2_table);
procedure drop_dim(p_dim_name varchar2);
procedure drop_old_dim_for_level(p_dimension dimension_r,p_affected_kpi in out nocopy dbms_sql.varchar2_table);
procedure create_dim_objects(p_dimension in out nocopy dimension_r);
procedure create_dim_for_levels(p_dimension in out nocopy dimension_r);
procedure create_ccdim(p_dimension in out nocopy dimension_r);
procedure create_level_name_dim(p_dimension in out nocopy dimension_r);
procedure create_relation(p_dimension in out nocopy dimension_r);
procedure create_dim_program(p_dimension dimension_r);
procedure create_dim_program(p_dimension dimension_r,p_mode varchar2);
procedure create_dim_program_rec(p_dimension dimension_r,p_mode varchar2);
procedure dmp_g_dimensions(p_dimensions dimension_tb) ;
procedure create_rec_data_source(
p_dimension in out nocopy dimension_r
);
procedure create_data_source(
p_dimension in out nocopy dimension_r
);
procedure set_dim_properties(p_dim in out nocopy dimension_r);
procedure create_std_dim(p_dimensions in out nocopy dimension_tb) ;
procedure create_type_dim(p_dimensions in out nocopy dimension_tb);
procedure create_projection_dim(p_dimensions in out nocopy dimension_tb);
function level_has_parents(
p_parent_child dim_parent_child_tb,
p_level_name varchar2) return boolean;
procedure create_dmp_program(p_dim_level varchar2,p_name varchar2);
function get_zero_level(p_dimension dimension_r,p_level varchar2) return zero_levels_r ;
procedure get_dim_kpi_limit_cubes(
p_dim varchar2,
p_limit_cubes out nocopy dbms_sql.varchar2_table,
p_aggregate_marker out nocopy dbms_sql.varchar2_table,
p_reset_cubes out nocopy dbms_sql.varchar2_table);
procedure create_dim_program_rec_norm(p_dimension dimension_r,p_mode varchar2);
procedure create_dim(p_dim_level_list dbms_sql.varchar2_table);
procedure create_dim_program(p_dimension dimension_r,p_level_group level_group_r,p_mode varchar2);
procedure create_dim_program(
p_dimension dimension_r,
p_levels levels_tb,
p_parent_child dim_parent_child_tb,
p_zero_levels zero_levels_tb,
p_snowflake_levels levels_tb
);
procedure dmp_dimension(p_dim dimension_r);
function get_level_group(p_dim dimension_r,p_level varchar2) return level_group_r;
function compare_pc_relations(p_pc_1 dim_parent_child_tb,p_pc_2 dim_parent_child_tb) return number;
procedure check_old_dim_operation(p_old_dim dimension_r,p_new_dim dimension_r,p_flag out nocopy varchar2);
procedure correct_old_dim(p_dim dimension_r,p_flag out nocopy varchar2);
function get_level(p_dimension dimension_r,p_level varchar2) return levels_r;
procedure correct_parent_child(p_level_group level_group_r,p_old_pc dim_parent_child_tb,p_new_pc out nocopy dim_parent_child_tb);
procedure correct_levels(p_old_level levels_tb,p_new_level out nocopy levels_tb);
procedure correct_zero_levels(p_new_level levels_tb,p_old_zero_level zero_levels_tb,p_new_zero_level out nocopy zero_levels_tb);
procedure correct_level_name_dim(p_level_name_dim varchar2,p_old_level_groups level_group_tb,p_new_level_groups level_group_tb);
function get_zero_level(p_level_group level_group_r,p_level varchar2) return zero_levels_r;
function get_rec_level(p_level_group level_group_r,p_level varchar2) return rec_levels_r ;
function get_level(p_level_group level_group_r,p_level varchar2) return levels_r ;
procedure correct_level_groups(p_old_level_groups level_group_tb,p_new_level_groups out nocopy level_group_tb);
procedure correct_level_groups(p_old_level_group level_group_r,p_new_level_groups out nocopy level_group_tb);
procedure correct_dim(p_old_dim in out nocopy dimension_r);
procedure merge_dim(p_old_dim dimension_r,p_new_dim in out nocopy dimension_r);
procedure merge_dim(p_old_dim in out nocopy dimension_tb,p_new_dim in out nocopy dimension_r);
procedure dmp_level_group(p_level_group level_group_r);
function get_dim_name_hash_string(p_dimension dimension_r) return varchar2 ;
procedure make_dim_name(p_dimension in out nocopy dimension_r,p_hash_string varchar2);
procedure check_dim_name_conflict(p_dimension in out nocopy dimension_r);
function get_default_lg_name return varchar2;
function get_std_dim_list return dbms_sql.varchar2_table ;
procedure check_parent(
p_parent_child dim_parent_child_tb,
p_child_level varchar2,
p_check_level varchar2,
p_pc_subset out nocopy dim_parent_child_tb
);
function get_hier_subset(p_parent_child dim_parent_child_tb,p_parent_level varchar2,p_child_level varchar2) return dim_parent_child_tb;
procedure set_rec_dim_properties(p_dimension in out nocopy dimension_r);
procedure set_dim_recursive(p_dimension in out nocopy dimension_r);
function get_preloaded_dim_list return dbms_sql.varchar2_table;
function check_dim_view_based(p_dim varchar2) return varchar2 ;
procedure upgrade(p_new_version number,p_old_version number);
procedure merge_hier(p_pc_subset in out nocopy dim_parent_child_tb,p_pc_subset_merge dim_parent_child_tb);
function get_hier_subset(p_parent_child dim_parent_child_tb,p_parent_level dbms_sql.varchar2_table,
p_child_level dbms_sql.varchar2_table) return dim_parent_child_tb;
--std procedures----------------------------------------------------
procedure init_all;
procedure log(p_message varchar2);
procedure log_n(p_message varchar2);
-------------------------------------------------------------------

END BSC_AW_ADAPTER_DIM;

 

/
