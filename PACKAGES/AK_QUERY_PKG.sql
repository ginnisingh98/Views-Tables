--------------------------------------------------------
--  DDL for Package AK_QUERY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AK_QUERY_PKG" AUTHID CURRENT_USER AS
/* $Header: akquerys.pls 115.17 2002/09/27 18:32:19 tshort ship $ */
--
-- Declare constants
--
MAXKEYNUM          CONSTANT number := 10;   -- Max number of keys
MAXDISPNUM         CONSTANT number := 100;  -- Max number of attributes
MAXROWNUM		CONSTANT number := 2147483648; -- 2^32 / 2 (SB4)
--
-- Variable used for debugging purposes
--
sql_stmt		varchar2(20000);
PRINT_DEBUG_ON	boolean := FALSE;

TYPE key_rec IS RECORD
(
name           	varchar2(30),
is_date		boolean
);

--
-- Declare record and table for passing bind variables and values
--
TYPE bind_rec IS RECORD
(
name           	varchar2(30),
value		varchar2(4000)
);
TYPE bind_tab is table of bind_rec
index by binary_integer;

--
-- Declare tables for relationship definitions
--
TYPE rel_id_tab is table of number
index by binary_integer;
TYPE rel_name_tab is table of varchar2(30)
index by binary_integer;
TYPE rel_key_tab is table of key_rec
index by binary_integer;
TYPE rel_key_value_tab is table of varchar2(4000)
index by binary_integer;

TYPE region_rec IS RECORD
(
region_rec_id               number,
parent_region_rec_id        number,
flow_application_id         number,
flow_code                   varchar2(30),
page_application_id         number,
page_code                   varchar2(30),
region_application_id       number,
region_code                 varchar2(30),
database_object_name	varchar2(30),
primary_key_name            varchar2(30),
name                        varchar2(80),
region_style                varchar2(30),
number_of_format_columns    number,
region_defaulting_api_pkg   varchar2(30),
region_defaulting_api_proc  varchar2(30),
region_validation_api_pkg   varchar2(30),
region_validation_api_proc  varchar2(30),
object_defaulting_api_pkg   varchar2(30),
object_defaulting_api_proc  varchar2(30),
object_validation_api_pkg   varchar2(30),
object_validation_api_proc  varchar2(30),
total_result_count		number,
display_sequence            number,
sql_select			varchar2(5000),
sql_from			varchar2(240),
sql_where			varchar2(10000),
sql_order_by		varchar2(1000)
);

TYPE region_bind_rec IS RECORD
(
region_rec_id		number,
name			varchar2(30),
value			varchar2(4000)
);

TYPE item_rec IS RECORD
(
region_rec_id               number,
value_id                    number,
attribute_application_id    number,
attribute_code              varchar2(30),
attribute_label_long        varchar2(80),
attribute_label_length      number,
attribute_value_length      number,
display_value_length        number,
display_sequence            number,
item_style                  varchar2(30),
bold                        varchar2(1),
italic                      varchar2(1),
vertical_alignment          varchar2(30),
horizontal_alignment        varchar2(30),
object_attribute_flag       varchar2(1),
secured_column              varchar2(1),
indexed_column		varchar2(1),
rls_column			varchar2(1),
node_query_flag             varchar2(1),
node_display_flag           varchar2(1),
update_flag                 varchar2(1),
required_flag               varchar2(1),
icx_custom_call             varchar2(80),
region_defaulting_api_pkg   varchar2(30),
region_defaulting_api_proc  varchar2(30),
region_validation_api_pkg   varchar2(30),
region_validation_api_proc  varchar2(30),
object_defaulting_api_pkg   varchar2(30),
object_defaulting_api_proc  varchar2(30),
object_validation_api_pkg   varchar2(30),
object_validation_api_proc  varchar2(30),
lov_foreign_key_name        varchar2(30),
lov_region_application_id   number,
lov_region_code             varchar2(30),
lov_attribute_application_id number,
lov_attribute_code          varchar2(30),
lov_default_flag            varchar2(1)
);

TYPE result_rec IS RECORD
(region_rec_id              number,
key1                       varchar2(4000),
key2                       varchar2(4000),
key3                       varchar2(4000),
key4                       varchar2(4000),
key5                       varchar2(4000),
key6                       varchar2(4000),
key7                       varchar2(4000),
key8                       varchar2(4000),
key9                       varchar2(4000),
key10                      varchar2(4000),
value1                     varchar2(4000),
value2                     varchar2(4000),
value3                     varchar2(4000),
value4                     varchar2(4000),
value5                     varchar2(4000),
value6                     varchar2(4000),
value7                     varchar2(4000),
value8                     varchar2(4000),
value9                     varchar2(4000),
value10                    varchar2(4000),
value11                    varchar2(4000),
value12                    varchar2(4000),
value13                    varchar2(4000),
value14                    varchar2(4000),
value15                    varchar2(4000),
value16                    varchar2(4000),
value17                    varchar2(4000),
value18                    varchar2(4000),
value19                    varchar2(4000),
value20                    varchar2(4000),
value21                    varchar2(4000),
value22                    varchar2(4000),
value23                    varchar2(4000),
value24                    varchar2(4000),
value25                    varchar2(4000),
value26                    varchar2(4000),
value27                    varchar2(4000),
value28                    varchar2(4000),
value29                    varchar2(4000),
value30                    varchar2(4000),
value31                    varchar2(4000),
value32                    varchar2(4000),
value33                    varchar2(4000),
value34                    varchar2(4000),
value35                    varchar2(4000),
value36                    varchar2(4000),
value37                    varchar2(4000),
value38                    varchar2(4000),
value39                    varchar2(4000),
value40                    varchar2(4000),
value41                    varchar2(4000),
value42                    varchar2(4000),
value43                    varchar2(4000),
value44                    varchar2(4000),
value45                    varchar2(4000),
value46                    varchar2(4000),
value47                    varchar2(4000),
value48                    varchar2(4000),
value49                    varchar2(4000),
value50                    varchar2(4000),
value51                    varchar2(4000),
value52                    varchar2(4000),
value53                    varchar2(4000),
value54                    varchar2(4000),
value55                    varchar2(4000),
value56                    varchar2(4000),
value57                    varchar2(4000),
value58                    varchar2(4000),
value59                    varchar2(4000),
value60                    varchar2(4000),
value61                    varchar2(4000),
value62                    varchar2(4000),
value63                    varchar2(4000),
value64                    varchar2(4000),
value65                    varchar2(4000),
value66                    varchar2(4000),
value67                    varchar2(4000),
value68                    varchar2(4000),
value69                    varchar2(4000),
value70                    varchar2(4000),
value71                    varchar2(4000),
value72                    varchar2(4000),
value73                    varchar2(4000),
value74                    varchar2(4000),
value75                    varchar2(4000),
value76                    varchar2(4000),
value77                    varchar2(4000),
value78                    varchar2(4000),
value79                    varchar2(4000),
value80                    varchar2(4000),
value81                    varchar2(4000),
value82                    varchar2(4000),
value83                    varchar2(4000),
value84                    varchar2(4000),
value85                    varchar2(4000),
value86                    varchar2(4000),
value87                    varchar2(4000),
value88                    varchar2(4000),
value89                    varchar2(4000),
value90                    varchar2(4000),
value91                    varchar2(4000),
value92                    varchar2(4000),
value93                    varchar2(4000),
value94                    varchar2(4000),
value95                    varchar2(4000),
value96                    varchar2(4000),
value97                    varchar2(4000),
value98                    varchar2(4000),
value99                    varchar2(4000),
value100                   varchar2(4000));

--
-- Declare tables for return regions, items and data results
--
TYPE regions_table_type is table of region_rec
index by binary_integer;
TYPE regions_bind_table_type is table of region_bind_rec
index by binary_integer;
TYPE items_table_type is table of item_rec
index by binary_integer;
TYPE results_table_type is table of result_rec
index by binary_integer;

--
-- Globals to be used to output data
--
g_regions_table   		regions_table_type;
g_regions_bind_table          regions_bind_table_type;
g_items_table     		items_table_type;
g_results_table   		results_table_type;

--
-- Global used as default value for parameter
--
G_BIND_TAB_NULL		bind_tab;

--
-- Declare exec_query
--
PROCEDURE exec_query
(
p_flow_appl_id              IN number       default NULL,
p_flow_code                 IN varchar2     default NULL,
p_parent_page_appl_id       IN number       default NULL,
p_parent_page_code          IN varchar2     default NULL,
p_parent_region_appl_id     IN number,
p_parent_region_code        IN varchar2,
p_parent_primary_key_name   IN varchar2     default NULL,
p_parent_key_value1         IN varchar2     default NULL,
p_parent_key_value2         IN varchar2     default NULL,
p_parent_key_value3         IN varchar2     default NULL,
p_parent_key_value4         IN varchar2     default NULL,
p_parent_key_value5         IN varchar2     default NULL,
p_parent_key_value6         IN varchar2     default NULL,
p_parent_key_value7         IN varchar2     default NULL,
p_parent_key_value8         IN varchar2     default NULL,
p_parent_key_value9         IN varchar2     default NULL,
p_parent_key_value10        IN varchar2     default NULL,
p_child_page_appl_id        IN number       default NULL,
p_child_page_code           IN varchar2     default NULL,
p_where_clause              IN varchar2     default NULL,
p_order_by_clause           IN varchar2     default NULL,
p_responsibility_id         IN number       default NULL,
p_user_id                   IN number       default NULL,
p_return_parents	        IN varchar2     default 'T',
p_return_children	        IN varchar2     default 'T',
p_return_node_display_only  IN varchar2     default 'F',
p_set_trace                 IN varchar2     default 'F',
p_range_low			IN number	default 0,
p_range_high		IN number       default MAXROWNUM,
p_where_binds		IN bind_tab	default G_BIND_TAB_NULL,
p_max_rows                  IN number       default NULL,
p_use_subquery              IN varchar2     default 'F'
);

function getSecuredWhere(
p_region_rec                  IN region_rec,
p_responsibility_id           IN number,
p_user_id                     IN number,
p_where_clause                IN varchar2 default NULL,
p_order_by_clause             IN varchar2 default NULL ,
p_return_node_display_only    IN boolean default True,
p_display_region              IN boolean default True
) return varchar2;

END AK_QUERY_PKG;

 

/
