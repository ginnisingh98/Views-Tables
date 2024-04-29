--------------------------------------------------------
--  DDL for Package BSC_AW_ADAPTER_KPI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_AW_ADAPTER_KPI" AUTHID CURRENT_USER AS
/*$Header: BSCAWAKS.pls 120.24 2006/04/17 15:38 vsurendr noship $*/
--program runtime parameters
g_debug boolean;
g_stmt varchar2(32000);
g_commands dbms_sql.varchar2_table;
----types----------------------------------------------------------
--measures are the measures involved in the agg formula
--we need the measures becasue if we need to do the agg on-line, we need to know what the base measurea are for a formula.
--we first need to aggregate them, then run the formula
type agg_formula_r is record(
agg_formula varchar2(2000),
sql_agg_formula varchar2(2000),/*this is the original agg formula from metadata. used when we have non std agg and partitions */
std_aggregation varchar2(20),--Y means sum average etc. N means its a formula like measure1/measure2
avg_aggregation varchar2(20),--Y means average
cubes dbms_sql.varchar2_table, /*the cubes in the formula */
measures dbms_sql.varchar2_table /*the measures in the formula */
);
--
/*
we introduce here new classes.  cube_r, partition_template_r, partition_r, composite_r and partition_r. we need to support the following designs
9i : separate cubes , 1 composite
10g :  separate cubes, separate composites
       datacube. no partitons
       datacube with partitions
measures will reference cubes. cubes will reference through the axis class partitions or composites or dimensions.
axis_name is the name of the dimension or composite or partition
composites, cubes and partitions will be within a dimset. there is no sharing of objects across dimset
we need to look at the cpu count and then decide on the number of partitions. default number of partitions=4
*/
type axis_r is record(
axis_name varchar2(4000),
axis_type varchar2(100)
);
type axis_tb is table of axis_r index by pls_integer;
--
type composite_r is record(
composite_name varchar2(200),
composite_type varchar2(100), --compressed or non compressed
composite_dimensions dbms_sql.varchar2_table
);
type composite_tb is table of composite_r index by pls_integer;
--
/*we need to implement partitions in a whole new way. earlier we were implementing list and hash on dim keys. this will not do
first, avg measure goes wrong . avg becomes at reporting time ((a1+..am)/m + (b1+...bn)/n) / 2 if there are 2 partitions. the correct avg is
(a1+..am+b1+...bn)/(n+m) . also if we consider sum measure, though the final value is technically correct, there is enormous composite node
duplication across partitions.
new partitioning strategy will partition mostly on time. say we partition at day level. there will be no agg on time. at runtime, time agg is
done. though there is node duplication, its only with the other dim limited. time gives predictable load for online agg. worst case is 366 values to
aggregate to year level. if there is avg, have to go with maybe partition on type, since there is no agg on type. we will create generic data structures
so that we can aggregate on any dim at any level. we can choose to aggregate at state level and time. then the agg stop at state. country aggregation
will be runtime
hpt: hash partition*/
type hpt_dimension_r is record( --dimensions of the dimset which are used to hash
dim_name varchar2(100),
dim_type varchar2(40),--normal,std,time
level_names dbms_sql.varchar2_table, /*there can be multiple levels per dim we apply pt on. example, month and week level */
level_keys dbms_sql.varchar2_table
);
type hpt_dimension_tb is table of hpt_dimension_r index by pls_integer;
--
type hpt_data_r is record( --top hpt info holder
hpt_dimensions hpt_dimension_tb,
hpt_calendar hpt_dimension_r
);
--
type partition_r is record( --these are the individual partitions
partition_name varchar2(200),
partition_dim_value varchar2(200),
partition_axis axis_tb --for each value of the partition dim value , what is the name of the composite or dimensions
);
type partition_tb is table of partition_r index by pls_integer;
--
type partition_template_r is record(
template_name varchar2(200),
template_type varchar2(40), --lits or range etc
template_use varchar2(40), --used for datacube or countvar cube etc
template_dim varchar2(200), --hash dim or some range dim
template_dimensions dbms_sql.varchar2_table,--this just holds the dim of the template excluding partion and measure dim
template_partitions partition_tb,
hpt_data hpt_data_r --populated when there are hash partitions
);
type partition_template_tb is table of partition_template_r index by pls_integer;
--
type cube_r is record(
cube_name varchar2(200),
cube_type varchar2(40), --not used
cube_datatype varchar2(40),
cube_axis axis_tb --reference to composite or partition template or dimensions
);
type cube_tb is table of cube_r index by pls_integer;
--
--cube set contains the set of associated cubes. with each cube is a fcst cube, countvar cube. this is a logical structure
type cube_set_r is record(
cube_set_name varchar2(200),
cube cube_r,
display_cube cube_r,/*if cube is compressed and partitioned, display cube will be in the view and data is copied into it from main cube during display*/
fcst_cube cube_r,
countvar_cube cube_r,
cube_set_type varchar2(40), --datacube or measurecube
measurename_dim varchar2(200) --if the cubeset is datacube
);
type cube_set_tb is table of cube_set_r index by pls_integer;
--
type formula_r is record(
formula_name varchar2(200),
formula_expression varchar2(4000)
);
type formula_tb is table of formula_r index by pls_integer;
--
/*
measure_r holds measure name, formula etc
formula : used in creating data source.useful for the lowest level only to see how to pull data from base tables
agg_formula :  this holds how the agg is to be done. if it has
Sum(BSCIC460)/Decode(Sum(BSCIC461),0,Null,Sum(BSCIC461)), it means this cube=cube_460/cube_461 > this is
average at lowest level
it may be sum or average or max or min for other columns
if we have average at the lowest level we are going to represent agg_formula as cube_460/cube_461.
the optimizer api will return the measures. we will substitute the measures with the cubes and simply execute the
cubes in the aggregation module. we store the agg formula in bsc olap metadata
measures can share cubes. so we hold cube names in measures, not cubeset in measure
*/
type measure_r is record(
measure varchar2(100),
measure_type varchar2(80),--normal or balance. by default balance is end period balance
data_type varchar2(40),--aw data type
formula varchar2(400), --formula has the agg in it.. MIN(Gr_806Sim1/DECODE(Gr_806Sim2,0,NULL,Gr_806Sim2))
agg_formula agg_formula_r,
sql_aggregated varchar2(10),--if non std agg, then sql agg means the non std agg is in the view stmt. used with non std agg and partitions
aw_formula formula_r,--if datacube, this will be datacube(measurenamedim ''m1''), else cube name
forecast varchar2(10), --Y or N,
forecast_method varchar2(100), --this is null for now. projections in B tables
cube varchar2(300),
countvar_cube varchar2(300),
fcst_cube varchar2(300), -- if the measure has forecast
display_cube varchar2(300),/*compressed composite and partitions */
property bsc_aw_utility.property_tb /*if this is BALANCE LAST VALUE, this can contain balance loaded Y/N column name */
);
type measure_tb is table of measure_r index by pls_integer;
--
/*
these hold the aggmap oprrators like measure , its agg formula etc. used in aggmaps
*/
type aggmap_operator_r is record(
measure_dim varchar2(300),
opvar varchar2(300),
argvar varchar2(300)
);
--
/*
we want to use opvar, argvar etc so we can support any agg method aw supports
*/
--
type agg_map_r is record(
agg_map varchar2(300),
property varchar2(300),
created varchar2(10), --if the dimset has no dim except type,proj and cal, there will not be an aggmap_notime
aggmap_operator aggmap_operator_r
);
--
--dimensions in a dim set
--we cannot use dim adapter dim data structures since dim creation and kpi creation can happen independent
--of each other. so we cannot assume g_dimensions will have data in it. we will hold here the info we need
--dim_name is the CC dim name
--within a dim, a kpi will be pointing to a level. for example, in a geog dim, kpi will point to city level
--we need to know this level. this will be levels(1). levels will hold the aw dim name for the level
--zero code is at level granularity. a dim may have multiple highest levels, but the dim set may need zero code
--on only 1 of those highest levels.
--filter will be (select code from ...where ...) so we can do level.pk in filter, we will hold the filter at the
--lowest level of the dim set
type level_r is record(
level_name varchar2(300), --this is the aw dim level name
level_type varchar2(40), --normal vs time
pk varchar2(100), --fk=pk for now
fk varchar2(100),
data_type varchar2(40), --for now, all dim are text. so this muust be varchar2(300) needed to create olap table fn
zero_code varchar2(10),
zero_code_level varchar2(300),--the name of the aw dim that is used to represent zero level
rec_parent_level varchar2(300),--the name of the aw dim that is used to represent rec parent level
filter dbms_sql.varchar2_table, --we may have a long stmt, we dont want to constrain this to 4000 characters
position number, --used by the aggregation_r object in bsc_aw_load_kpi
aggregated varchar2(10), --Y or N
zero_aggregated varchar2(10), --Y or N. Use together with zero_code, if zero_code=Y and zero_aggregated=Y then <aggregate zero code>
property varchar2(400), --used for seeing if a level is a standalone level
level_source varchar2(40) --table or view etc
);
type level_tb is table of level_r index by pls_integer;
--
type parent_child_r is record(
parent_level varchar2(200),
child_level varchar2(200),
child_fk varchar2(200),
parent_pk varchar2(200)
);
type parent_child_tb is table of parent_child_r index by pls_integer;
type parent_child_tb_tv is table of parent_child_tb index by varchar2(200);
--
--there will also be an agg map to each dim so that we can agg on the fly. when agg on the fly, we do dim by dim
--first explode all dim to the levels to the position where there is rollup data. then rollup one dim. then limit this dim
--to the higher value. then rollup the next and so on
--not sure if target_limit_cube is reqd. dim_set has dim and target_dim. so will limit cube in target_dim hold the target_limit_cube
--the issue with that is std_dim and calendar. we then need to have std_dim and calendar replicated for targets.
--aggregate_marker is used in load kpi module. if aggregate_marker is set, it means there was some change to dim hierarchies
--necessitating a reagg. used in dim_set.aggregate_marker_program. they are scalar
--reset_cube is reqd to mark those dim values that have no childran anymore. when there are no children anymore, AW does not automatically
--clear the data. reset_cube will use the same composite as the limit cube
--std dim do not have reset bools since they have no agg. also we will not have this for calendar. also , none for targets since there is
--no rollup on target
type dim_r is record(
dim_name varchar2(300),
relation_name varchar2(300), --aw relation name, used to create agg maps
property varchar2(200), --time vs normal
recursive varchar2(10),
recursive_norm_hier varchar2(10),--rec dim implemented with normalized hier.
multi_level varchar2(10),
zero_code varchar2(10), --if any level has zero code, this is set to Y
concat varchar2(10),--Y or N. used in QDR when creating the programs
levels level_tb, --levels of a dim that the dim set for the kpi has.used in creating agg program
parent_child parent_child_tb,
limit_cube varchar2(300),
reset_cube varchar2(300),
limit_cube_composite varchar2(300), --needed for 10g. with "sparse", we cannot acquire parallel locks. will also use for 9i
base_value_cube varchar2(200), --holds the base value. used in the creation of the olap table function
aggregate_marker varchar2(300),--true or false flag. true if there is hier change in the dim and the cubes need reaggregation
level_name_dim varchar2(300),--this is the dim that holds level names
agg_map agg_map_r,
agg_level number --used in bsc_aw_load_kpi to do limit the levels. with this flag in the dim structure
--we can control agg level at a dim level
);
type dim_tb is table of dim_r index by pls_integer;
--
--we are going to keep time dim separate from dim_r
--from AW perspective, time and normal dim are the same not from bsc perspective
type periodicity_r is record(
periodicity number,
periodicity_type varchar2(40),
aw_dim varchar2(300),
lowest_level varchar2(10), --Y or N multiple levels can be lowest!!! like month and week
missing_level varchar2(10),--Y or N
aggregated varchar2(10), --Y or N
property varchar2(3000) --used to store current period in aggregation of balance measures
);
type periodicity_tb is table of periodicity_r index by pls_integer;
--
type cal_parent_child_r is record(
parent number,
parent_dim_name varchar2(300),
child number,
child_dim_name varchar2(300)
);
type cal_parent_child_tb is table of cal_parent_child_r index by pls_integer;
--
type calendar_r is record(
calendar number,
aw_dim varchar2(300),
level_name_dim varchar2(300),--the dim that will store the level names
end_period_level_name_dim varchar2(300),
relation_name varchar2(300),--rel name used to create aggmap
denorm_relation_name varchar2(300),--rel used for balance rollup in kpi load programs
periodicity periodicity_tb,
parent_child cal_parent_child_tb,
end_period_relation_name varchar2(300),--this relation is used for balance measures
limit_cube varchar2(300), --limit cube for time dim
limit_cube_composite varchar2(300), --needed for 10g. with "sparse", we cannot acquire parallel locks. will also use for 9i
aggregate_marker varchar2(300),
agg_map agg_map_r
);
--
--there are 3 kinds of B->measures. one B for all, B1->m1, B2->m2 or B1->m1,m2 and B2->m1,m2
--so with the data source, we also need to know the measures for each data set
--therefore dim_set_r will contain a table of data sources
--we have table of varchar2 for data source instead of varchar2(20000) because we want to have multiple lines
--aw has a limitation of 4000 characters per line. we may run out of 4000 for complex kpi
--we need base table info since with RSG, we will have to load by base tables. so for each dataset,
--we load only if the dataset contains the base tables specified. the list of base tables is passed as a
--parameter to the program. if a kpi itself is being loaded we will pass "ALL"
--
--levels in base_table_r stores the relevant levels that the base table has. a base table may have more keys than the
--dim set. in that case, we group the data across these extra keys we dont need to hold measure info here since
--dim_set_r has the measure info
--if the base table is at the same level as the lowest level of the dim set, base_table_sql=base table name
--if base table level is smaller, base_table_sql= (select ..from base, level where base.fk=level.pk) base_table_name
--we also need the measures in case the base table is at a lower level and we need to create the base table sql,
--we need to know what measures to pick up from the base table. dim_set.measure will hold the measure names in the dimset
--and will be different from what is in the base table
type base_table_r is record(
base_table_name varchar2(100),
levels level_tb, --all dim levels except time
feed_levels dbms_sql.varchar2_table,--these are the levels that feed the dimset Y or N
level_status dbms_sql.varchar2_table,--skip or correct or lower etc
periodicity periodicity_r, --the periodicity at which the base table is
projection_table varchar2(100),
current_period varchar2(40),--in period.year format. this field can be null
table_partition bsc_aw_utility.object_partition_r,
base_table_sql dbms_sql.varchar2_table
);
type base_table_tb is table of base_table_r index by pls_integer;
--
/*this data structute holds info on partition info for a DS. ie, what PT this DS is loading */
type data_source_PT_r is record(
partition_template partition_template_r,
dim_parent_child parent_child_tb_tv,/*index by dim name. used for rollup in DS sql */
cal_parent_child cal_parent_child_tb /*used for rollup in DS sql */
);
--
--data_source_stmt are tables of varchar2 so we can have any number of lines. aw has a limitation of
--4000 characters per line
--we will have one base table per data source for now
--we need to know the dim of the data source since targets at higher levels have the same dim but higher
--levels
--we need std_dim and calendar because in 10g, for targets, we will have diff program and diff limit cubes for dim and calendar
--datasource must know about the measurename dim and the partition dim
--note>>>lets assume that in a datasource, all the measures must share a partition template
/*PT belong to dimsets. cubes point to the PT they want to use. DS has measures that its loading. from this, we find the cubes and find
the PT. from PT we can get all info like partition dim, hpt_data etc. we assume that all the cubes a DS is loading has a similar PT
so each DS deals with one PT
for convinience, we can hold the partition template with a DS. DS has 2 sets of information. B table info, ie info of where data is coming from
target info, info where the data is going to including the dim, measures, PT */
type data_source_r is record(
dim dim_tb,
std_dim dim_tb,
calendar calendar_r,
measure measure_tb,
ds_type varchar2(40),--initial or inc
data_source_stmt_type dbms_sql.varchar2_table, --dimension=<dim> or measure=<measure> or limit cube=<dim> or 'partition dim'
data_source_stmt dbms_sql.varchar2_table, --(select k1,k2,m1,m2 from B)
base_tables base_table_tb,
data_source_PT data_source_PT_r,
property bsc_aw_utility.property_tb --any misc properties
);
type data_source_tb is table of data_source_r index by pls_integer;
--
--in s views we need to know what the levels are for each s view. in dim set we are not
--holding this relation. in dim set, we do not know how the dim and their levels are related to
--the s views. so with each s view, we need to know the level
--we need to hold dim info also to get base value cube
type s_view_r is record(
id varchar2(20),--used to uniquely create a type
s_view varchar2(100),
dim dim_tb,
type_name varchar2(100), -- the name of the olap type for the view
type_table_name varchar2(100) -- the name of the olap table type for the view
);
type s_view_tb is table of s_view_r index by pls_integer;
--
type load_program_r is record(
program_name varchar2(200),
program_type varchar2(40),
ds_base_tables varchar2(4000)
);
--
/*
we have a table of data sources because we can have multiple base tables feeding the cubes. B1->m1, B2-> m2,m3 etc
both actuals and targets have the same dimensions, so thay can use the same composite, however, they can have different
levels, the targets may have lesser number of levels
we create actuals and targets with the all the levels of the dim set. targets usually only have a subset. we control this
when we aggregate target cubes. we limit the levels to the levels the target cubes have
target_dim.levels(1) will be the lowest level in a any dim for the target
filter is at a dim level in the dim set. its applicable to all data sources
calendar is at kpi level. but just for uniformity sake,we hold it al dim set level
with calendar, when we talk of dim, we are never talking about periodicities
if forecast_method is not null, then we use AW to calculate forecast
forecast will be Y even in the case where the B tables have the projections. this is used by aggregations to
decide how to handle forecast data
target cubes in 10g have diff composites. so we can run their load in parallel.
there are no separate programs for targets. but note that the base tables for targets are different
base dim set will be useful for target dimsets, for regular dimsets, this is will be null.
in BSCAWLKB.pls, we have to see the base dim set for a target dimset. only then can we copy data from target cubes to actual cubes
forecast is at measure level.
not sure the idea to have columns like datacube_design, partitioned, compressed is a good one. This is essentially duplicating the information
as the structures get more complicated, we may need to obsolete them
*/
type dim_set_r is record(
dim_set varchar2(100),
dim_set_name varchar2(300), --used in bsc_olap_object metadata
dim_set_type varchar2(100), --actual or target
base_dim_set varchar2(300),
targets_higher_levels varchar2(10),--we hold at kpi level and dimset level
dim dim_tb,
calendar calendar_r,
std_dim dim_tb,--these are TYPE and PROJECTION
measure measure_tb,
s_view s_view_tb,--regular MV
z_s_view s_view_tb,--the ZMV
data_source data_source_tb,
inc_data_source data_source_tb,
initial_load_program load_program_r,
inc_load_program load_program_r,
initial_load_program_parallel load_program_r, --10g, used to load measures in parallel, either per measure or per partition
inc_load_program_parallel load_program_r,
LB_resync_program varchar2(300),--needed when we have partitions
aggregate_marker_program varchar2(300),--used with aggregate_marker to set the limit cubes if dim hier have changed
aggmap_operator aggmap_operator_r,--this contains opvar argsvar etc. shared across aggmaps
agg_map agg_map_r, --for normal measures
agg_map_notime agg_map_r, --for avg measures
master_partition_template partition_template_tb,--holds the master PT info. partition_template will make copy from here
--physical implementation parameters
partition_template partition_template_tb,
composite composite_tb,
cube_set cube_set_tb,
--add properties for the dimset
measurename_dim varchar2(200), --this is for the datacube design
partition_dim varchar2(200),
partition_type varchar2(40),
cube_design varchar2(40), --datacube or single composite or multiple composite
number_partitions number, --if 0, no partitions
compressed varchar2(10), --Y or N
pre_calculated varchar2(10), --higher level aggregates from B tables
property bsc_aw_utility.property_tb
);
type dim_set_tb is table of dim_set_r index by pls_integer;
--
type kpi_r is record(
kpi varchar2(100),
parent_kpi varchar2(100),
calendar varchar2(20),
dim_set dim_set_tb, --for actuals
target_dim_set dim_set_tb --for targets only. if dimset(i) has target, it will be in target_dim_set(i). note the same i
);
type kpi_tb is table of kpi_r index by pls_integer;
--
/*general purpose globals used in the code */
g_period_temp constant varchar2(40):='period_temp';
g_year_temp constant varchar2(40):='year_temp';
g_balance_end_period_prop constant varchar2(40):='BALANCE';
g_balance_last_value_prop constant varchar2(40):='BALANCE LAST VALUE';
g_balance_loaded_column_prop constant varchar2(40):='BALANCE LOADED COLUMN';
--
--procedures-------------------------------------------------------
procedure drop_kpi_objects(p_kpi varchar2);
procedure create_kpi(p_kpi_list dbms_sql.varchar2_table);
procedure create_kpi(p_kpi in out nocopy kpi_r);
procedure get_dim_set_dim_properties(p_kpi varchar2,p_dim_set in out nocopy dim_set_r);
procedure get_dim_set_calendar(p_kpi kpi_r,p_dim_set in out nocopy dim_set_r);
procedure get_dim_set_dims(p_kpi varchar2,p_dim_set in out nocopy dim_set_r);
procedure set_dim_and_level(
p_dim_set in out nocopy dim_set_r,
p_dim varchar2,
p_level varchar2,
p_mo_dim_group varchar2,
p_skip_level varchar2
);
procedure set_dim_order(p_dim_set in out nocopy dim_set_r);
procedure get_dim_set_properties(p_kpi varchar2,p_dim_set in out nocopy dim_set_r);
procedure get_dim_set_measures(p_kpi varchar2,p_dim_set in out nocopy dim_set_r);
procedure get_dim_set_targets(p_kpi in out nocopy kpi_r);
procedure get_s_views(p_kpi varchar2,p_dim_set in out nocopy dim_set_r);
procedure get_dim_set_data_source(p_kpi kpi_r,p_dim_set in out nocopy dim_set_r);
procedure create_data_source_sql(
p_kpi varchar2,
p_dim_set dim_set_r,
p_data_source in out nocopy data_source_r
);
procedure create_base_table_sql(
p_dim_set dim_set_r,
p_data_source data_source_r,
p_base_table in out nocopy base_table_r
);
function is_level_in_dim(p_dim dim_r,p_level varchar2) return boolean;
function get_dim_given_dim_name(p_dim varchar2,p_dim_set dim_set_r) return dim_r;
function is_dim_in_dimset(p_dim_set dim_set_r,p_dim varchar2) return boolean;
procedure create_aw_object_names(p_kpi in out nocopy kpi_r);
procedure create_kpi_objects(p_kpi in out nocopy kpi_r);
procedure create_kpi_objects(
p_kpi kpi_r,
p_dim_set in out nocopy dim_set_r);
procedure create_composite(
p_kpi kpi_r,
p_dim_set in out nocopy dim_set_r);
procedure create_cube(
p_kpi kpi_r,
p_dim_set in out nocopy dim_set_r);
procedure create_kpi_program(p_kpi in out nocopy kpi_r);
procedure create_kpi_program(p_kpi kpi_r,p_dim_set in out nocopy dim_set_r,p_mode varchar2);
procedure create_kpi_program(p_kpi kpi_r,p_dim_set dim_set_r,p_data_source data_source_r);
procedure create_kpi_view(p_kpi in out nocopy kpi_r);
procedure create_kpi_view(p_kpi kpi_r,p_dim_set in out nocopy dim_set_r);
procedure create_db_type(p_kpi kpi_r,p_dim_set in out nocopy dim_set_r);
procedure dmp_kpi(p_kpi kpi_r);
procedure dmp_dimset(p_dim_set dim_set_r);
procedure dmp_dim(p_dim dim_r);
procedure dmp_data_source(p_data_source data_source_tb);
procedure dmp_data_source(p_data_source data_source_r);
procedure create_agg_map(
p_kpi kpi_r,
p_dim_set in out nocopy dim_set_r);
function check_kpi_create(p_kpi varchar2) return boolean;
procedure get_dim_set_std_dims(
p_kpi varchar2,
p_dim_set in out nocopy dim_set_r);
procedure get_dim_set_std_dim_type(
p_kpi varchar2,
p_dim in out nocopy dim_r);
procedure get_dim_set_std_dim_projection(
p_kpi varchar2,
p_dim in out nocopy dim_r);
procedure dmp_agg_map(p_agg_map agg_map_r) ;
procedure create_agg_map(p_dim_set dim_set_r,p_agg_map in out nocopy agg_map_r);
procedure dmp_calendar(p_calendar calendar_r);
procedure create_aggmap_operators(p_kpi kpi_r,p_dim_set dim_set_r);
procedure make_agg_formula(
p_kpi in out nocopy kpi_r
);
procedure make_agg_formula(
p_dim_set in out nocopy dim_set_r
) ;
procedure make_agg_formula(
p_measure in out nocopy measure_r,
p_all_measures measure_tb,
p_dim_set dim_set_r
);
procedure set_dim_level_positions(p_kpi varchar2,p_dim_set in out nocopy dim_set_r);
procedure set_dim_level_positions(p_dim in out nocopy dim_r) ;
procedure set_dim_agg_level(p_kpi in out nocopy kpi_r);
procedure init_agg_level(p_dim_set in out nocopy dim_set_r);
procedure dmp_measure(p_measure measure_r) ;
procedure create_kpi_aw(p_kpi in out nocopy kpi_r);
procedure drop_kpi_objects_aw(p_kpi varchar2);
procedure get_dim_properties(p_kpi varchar2,p_dim in out nocopy dim_r);
procedure create_db_type(p_kpi varchar2,p_dim_set dim_set_r,p_s_view in out nocopy s_view_r) ;
procedure create_kpi_view(p_kpi kpi_r,p_dim_set dim_set_r,p_s_view s_view_r,p_type varchar2);
procedure create_missing_dim_levels(p_kpi varchar2,p_dim_set in out nocopy dim_set_r);
procedure get_dim_mo_dim_groups(
p_dim dim_r,
p_distict_mo_dim_groups out nocopy dbms_sql.varchar2_table);
procedure identify_standalone_levels(
p_kpi varchar2,
p_dim_set in out nocopy dim_set_r);
procedure create_dmp_program(
p_kpi varchar2,
p_dimset varchar2,
p_dim_levels dbms_sql.varchar2_table,
p_name varchar2,
p_table_name varchar2);
procedure get_missing_periodicity(p_kpi kpi_r,p_dim_set in out nocopy dim_set_r);
function get_periodicity_r(p_periodicity periodicity_tb,p_periodicity_dim varchar2) return periodicity_r;
function get_periodicity_r(p_periodicity periodicity_tb,p_periodicity_id number) return periodicity_r;
function is_filter_in_data_source(
p_data_source data_source_r
)return varchar2;
procedure dmp_agg_map_operator(p_agg_map_operator aggmap_operator_r);
procedure drop_kpi_objects_relational(p_kpi varchar2);
procedure create_aggregate_marker_pgm(
p_kpi kpi_r,
p_dim_set dim_set_r
);
procedure create_dim_match_header(p_data_source data_source_r);
procedure create_limit_cube_tail(p_data_source data_source_r);
procedure create_kpi_program_parallel(p_kpi in out nocopy kpi_r);
procedure create_kpi_program_cube(
p_kpi kpi_r,
p_dim_set in out nocopy dim_set_r,
p_mode varchar2);
procedure create_kpi_program_cube(
p_kpi kpi_r,
p_dim_set dim_set_r,
p_cube_set cube_set_r,
p_measures measure_tb,
p_data_source data_source_r);
procedure create_kpi_program_limit_cube(
p_kpi kpi_r,
p_dim_set dim_set_r,
p_data_source data_source_r);
function get_comp_dimensions(p_dim_set in out nocopy dim_set_r) return dbms_sql.varchar2_table;
procedure create_cube(
p_kpi kpi_r,
p_dim_set dim_set_r,
p_cube cube_r);
procedure create_measure_dim(
p_kpi kpi_r,
p_dim_set in out nocopy dim_set_r);
procedure dmp_partition_template(p_partition_template partition_template_r);
procedure dmp_partition(p_partition partition_r);
procedure dmp_axis(p_axis axis_r);
procedure dmp_composite(p_composite composite_r);
procedure dmp_cube_set(p_cube_set cube_set_r);
procedure dmp_cube(p_cube cube_r);
procedure create_PT_comp_names(p_kpi varchar2,p_dimset in out nocopy dim_set_r);
procedure create_partition_template(
p_kpi kpi_r,
p_dim_set in out nocopy dim_set_r) ;
procedure create_partition_template(
p_kpi kpi_r,
p_dim_set in out nocopy dim_set_r,
p_partition_template in out nocopy partition_template_r
);
procedure create_kpi_program_partition(
p_kpi kpi_r,
p_dim_set in out nocopy dim_set_r,
p_mode varchar2) ;
procedure create_kpi_program_partition(
p_kpi kpi_r,
template_partition partition_r,
p_dim_set in out nocopy dim_set_r,
p_data_source data_source_r,
partition_index number);
function get_cube_set_r(p_cube_name varchar2,p_dimset dim_set_r) return cube_set_r;
function get_composite_r(p_composite_name varchar2,p_dimset dim_set_r) return composite_r;
function get_partition_template_r(p_partition_template varchar2,p_dimset dim_set_r) return partition_template_r;
function get_cube_axis(p_cube_name varchar2,p_dimset dim_set_r,p_axis_type varchar2) return varchar2 ;
procedure set_dimset_partition_info(p_kpi varchar2,p_actual_dim_set in out nocopy dim_set_r,p_target_dim_set in out nocopy dim_set_r) ;
procedure get_measures_for_cube(
p_cube varchar2,
p_dim_set dim_set_r,
p_measures out nocopy measure_tb);
function get_cube_set_for_measure(p_measure varchar2,p_dim_set dim_set_r) return cube_set_r;
function get_cube_pt_comp(p_cube_name varchar2,p_dimset dim_set_r,p_type out nocopy varchar2) return varchar2;
procedure create_measure_formula(
p_kpi kpi_r,
p_dim_set in out nocopy dim_set_r);
procedure create_kpi_program_LB_resync(
p_kpi kpi_r,
p_dim_set in out nocopy dim_set_r
);
procedure create_dimset_data_source_sql(
p_kpi varchar2,
p_dim_set dim_set_r,
p_data_source in out nocopy data_source_tb
);
procedure create_dimset_data_source_sql(
p_kpi varchar2,
p_dim_set dim_set_r,
p_data_source data_source_tb,
p_new_data_source in out nocopy data_source_r
);
procedure set_program_property(p_load_program in out nocopy load_program_r,p_data_source data_source_tb);
function get_kpi_level_dim_r(
p_dim_set dim_set_r,
p_level varchar2) return dim_r;
function get_dim_level_r(
p_dim dim_r,
p_level varchar2) return level_r;
procedure check_compressed_composite(p_actual_dim_set in out nocopy dim_set_r,p_target_dim_set in out nocopy dim_set_r);
function check_countvar_cube_needed(p_dimset dim_set_r) return boolean;
procedure set_DS_dim_levels(p_kpi varchar2,p_dim_set in out nocopy dim_set_r,p_data_source in out nocopy data_source_r);
procedure set_DS_dim_levels(p_kpi varchar2,p_dim_set dim_set_r,p_data_source data_source_r,p_base_table in out nocopy base_table_r);
function get_dim_given_dim_name(p_dim varchar2,p_dim_t dim_tb) return dim_r;
function is_dimset_precalculated(p_dim_set dim_set_r) return boolean;
procedure set_dim_set_properties(p_dim_set in out nocopy dim_set_r);
procedure set_dim_set_properties(p_kpi in out nocopy kpi_r);
procedure dmp_table_partition(p_partition bsc_aw_utility.object_partition_r);
procedure dmp_partition_set(p_partition_set bsc_aw_utility.partition_set_r);
procedure set_dim_set_data_source(p_kpi kpi_r,p_dim_set in out nocopy dim_set_r);
procedure get_relevant_cal_hier(p_periodicity periodicity_tb,p_pc cal_parent_child_tb,p_relevant_pc out nocopy cal_parent_child_tb);
procedure get_upper_cal_hier(p_pc cal_parent_child_tb,p_child varchar2,p_upper_hier out nocopy cal_parent_child_tb);
procedure create_balance_aggregation(p_dim_set dim_set_r, p_data_source data_source_r,p_measures measure_tb);
procedure create_temp_variables(p_dim_set dim_set_r,p_data_source data_source_r);
function is_balance_last_value_in_DS(p_data_source data_source_r) return varchar2;
procedure upgrade(p_new_version number,p_old_version number);
procedure set_DS_dim_levels(p_kpi kpi_r,p_dim_set in out nocopy dim_set_r);
function is_higher_level_preloaded(p_dim_set dim_set_r) return boolean;
function is_higher_period_preloaded(p_dim_set dim_set_r) return boolean;
procedure set_dim_agg_level(p_dim_set in out nocopy dim_set_r);
procedure set_dim_agg_level(p_dim in out nocopy dim_r);
procedure set_calendar_agg_level(p_kpi in out nocopy kpi_r);
procedure set_calendar_agg_level(p_dim_set in out nocopy dim_set_r);
procedure dmp_hpt_data(p_hpt_data hpt_data_r);
function get_DS_partition_template(p_dim_set dim_set_r,p_data_source data_source_r) return partition_template_r;
procedure load_master_PT(p_actual_dim_set in out nocopy dim_set_r,p_target_dim_set in out nocopy dim_set_r);
function check_partition_possible(p_actual_dim_set in out nocopy dim_set_r,p_target_dim_set in out nocopy dim_set_r) return boolean;
procedure set_pt_type_count(p_dim_set in out nocopy dim_set_r);
procedure set_master_PT(p_dim_set in out nocopy dim_set_r);
function set_PT_hash_dimensions(p_dim_set dim_set_r,p_partition_template in out nocopy partition_template_r) return boolean;
function get_partition_count return number;
procedure set_data_source_PT(p_kpi kpi_r,p_dim_set in out nocopy dim_set_r);
procedure set_data_source_PT(p_dim_set dim_set_r,p_data_source in out nocopy data_source_r);
procedure set_DS_hpt_rollup_data(p_dim_set dim_set_r,p_data_source in out nocopy data_source_r);
procedure set_DS_hpt_rollup_data(p_DS_dim dim_tb,p_hpt_data hpt_data_r,p_data_source in out nocopy data_source_r);
procedure set_DS_hpt_rollup_data(p_calendar calendar_r,p_DS_calendar calendar_r,p_hpt_data hpt_data_r,p_data_source in out nocopy data_source_r);
function get_DS_PT_hash_stmt(p_dim_set dim_set_r,p_data_source data_source_r)return varchar2;
procedure set_PT_dim_aggregated(p_dim_set in out nocopy dim_set_r,p_partition_template partition_template_r);
procedure set_PT_dim_aggregated(p_dim in out nocopy dim_r,p_dim_set dim_set_r,p_levels dbms_sql.varchar2_table);
procedure set_PT_calendar_aggregated(p_dim_set in out nocopy dim_set_r,p_partition_template partition_template_r);
procedure set_PT_calendar_aggregated(p_calendar in out nocopy calendar_r,p_dim_set dim_set_r,p_levels dbms_sql.varchar2_table);
function is_dim_aggregated(p_dim dim_r) return boolean;
function is_calendar_aggregated(p_calendar calendar_r) return boolean;
function get_projection_dim(p_dim_set dim_set_r) return varchar2;
procedure create_cube(p_kpi kpi_r,p_dim_set dim_set_r,p_cube cube_r,p_cube_axis axis_tb);
function make_display_cube_axis(p_dim_set dim_set_r,p_cube cube_r) return axis_tb;
procedure set_sql_aggregations(p_kpi in out nocopy kpi_r,p_action varchar2);
procedure set_sql_aggregations(p_kpi kpi_r,p_dim_set in out nocopy dim_set_r,p_action varchar2);
procedure reset_PT_template(p_partition_template in out nocopy partition_template_r);
procedure set_calendar_agg_level(p_dim_set in out nocopy dim_set_r,p_target_dim_set dim_set_r);
function is_display_cube_required(p_dim_set dim_set_r,p_cube varchar2) return boolean;
function is_display_cube_possible(p_dim_set dim_set_r) return boolean;
function get_dim_set_lowest_periodicity(p_dim_set dim_set_r) return periodicity_tb;
--procedures-------------------------------------------------------
procedure init_all ;
procedure log(p_message varchar2);
procedure log_n(p_message varchar2);
-------------------------------------------------------------------

END BSC_AW_ADAPTER_KPI;

 

/
