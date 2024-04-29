--------------------------------------------------------
--  DDL for Package Body AK_QUERY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AK_QUERY_PKG" AS
/* $Header: akqueryb.pls 115.40 2004/03/10 20:53:58 tshort ship $ */

TYPE relation_rec IS RECORD
( foreign_key_name        varchar2(30),
fk_unique_key_name	  varchar2(30),
fk_db_object_name	  varchar2(30),
from_page_appl_id       number,
from_page_code          varchar2(30),
from_region_appl_id     number,
from_region_code        varchar2(30),
from_db_object_name     varchar2(30),
from_obj_unique_key     varchar2(30),
from_display_region     boolean,
to_page_appl_id         number,
to_page_code            varchar2(30),
to_region_appl_id       number,
to_region_code          varchar2(30),
to_db_object_name       varchar2(30),
to_obj_unique_key       varchar2(30),
to_display_region       boolean
);

TYPE relations_table_type is table of relation_rec
index by binary_integer;

PROCEDURE do_execute_query
(
p_node	                IN region_rec,
p_node_key_columns		IN rel_key_tab,
p_node_key_values		IN rel_key_value_tab,
p_child_page_appl_id          IN number,
p_child_page_code             IN varchar2,
p_where_clause                IN varchar2,
p_where_binds			IN bind_tab,
p_order_by_clause             IN varchar2,
p_responsibility_id           IN number,
p_user_id                     IN number,
p_return_parents              IN boolean,
p_return_children             IN boolean,
p_return_node_display_only    IN boolean,
p_display_region		IN boolean,
p_range_low			IN number ,
p_range_high			IN number ,
p_max_rows			IN number ,
p_use_subquery		IN boolean
);

PROCEDURE process_children
( p_parent	                IN region_rec,
p_parent_key_columns		IN rel_key_tab,
p_parent_key_values		IN rel_key_value_tab,
p_child_page_appl_id          IN number,
p_child_page_code             IN varchar2,
p_responsibility_id           IN number,
p_user_id                     IN number,
p_return_node_display_only    IN boolean,
p_display_region		IN boolean,
p_use_subquery		IN boolean,
p_range_low			IN number ,
p_range_high			IN number ,
p_where_clause		IN varchar2 ,
p_where_binds			IN bind_tab
);


PROCEDURE load_relations
(
p_region_rec			IN region_rec,
p_target_page_appl_id	        IN number,
p_target_page_code            IN varchar2,
p_relations_table		OUT NOCOPY relations_table_type
);

PROCEDURE construct_query
(
p_region_rec                  IN region_rec,
p_key_columns			IN rel_key_tab,
p_key_values                  IN rel_key_value_tab,
p_where_clause                IN varchar2,
p_order_by_clause             IN varchar2,
p_return_node_display_only    IN boolean,
p_display_region              IN boolean,
p_responsibility_id           IN number,
p_user_id                     IN number,
p_max_rows			IN number,
p_use_subquery		IN boolean,
p_query_stmt			OUT NOCOPY varchar2,
p_num_select			OUT NOCOPY number,
p_num_key			OUT NOCOPY number,
p_new_key_columns		OUT NOCOPY rel_key_tab,
p_rls_binds			OUT NOCOPY bind_tab,
p_select			OUT NOCOPY varchar2,
p_from			OUT NOCOPY varchar2,
p_where			OUT NOCOPY varchar2,
p_order_by			OUT NOCOPY varchar2
);

PROCEDURE get_sql
(
p_cursor_id         	        IN number,
p_num_select        	        IN number,
p_num_key       	        IN number,
p_region_rec		        IN region_rec,
p_display_region	        IN boolean,
p_key_values			OUT NOCOPY rel_key_value_tab
);

PROCEDURE define_sql
(
p_cursor_id                   IN number,
p_num_select                  IN number
);

PROCEDURE bind_sql
(
p_cursor_id                   IN number,
p_key_values	                IN rel_key_value_tab
);

PROCEDURE bind_where_clause
(
p_cursor_id                   IN number,
p_where_binds	                IN bind_tab
);

PROCEDURE create_region_record
(
p_region_rec	                IN region_rec,
p_key_column_values		IN rel_key_value_tab,
p_key_column_count		IN number,
p_where_binds			IN bind_tab,
p_rls_binds			IN bind_tab,
p_select			IN varchar2,
p_from			IN varchar2,
p_where			IN varchar2,
p_order_by			IN varchar2
);

PROCEDURE get_new_key_values
(
p_db_object_name		IN varchar2,
p_current_key_columns		IN rel_key_tab,
p_current_key_values		IN rel_key_value_tab,
p_new_key_columns		IN rel_key_tab,
p_new_key_values		OUT NOCOPY rel_key_value_tab
);

PROCEDURE get_fk_columns
( p_foreign_key_name	IN varchar2,
p_fk_column_tab	OUT NOCOPY rel_key_tab
);

PROCEDURE get_uk_columns
( p_unique_key_name	IN varchar2,
p_uk_column_tab	OUT NOCOPY rel_key_tab
);

PROCEDURE print_debug
( dMessage	IN	varchar2
);

-- ======================================================
--  EXEC_QUERY					|
-- ======================================================
PROCEDURE exec_query
(
p_flow_appl_id                IN number,
p_flow_code                   IN varchar2,
p_parent_page_appl_id         IN number,
p_parent_page_code            IN varchar2,
p_parent_region_appl_id       IN number,
p_parent_region_code          IN varchar2,
p_parent_primary_key_name     IN varchar2,
p_parent_key_value1           IN varchar2,
p_parent_key_value2           IN varchar2,
p_parent_key_value3           IN varchar2,
p_parent_key_value4           IN varchar2,
p_parent_key_value5           IN varchar2,
p_parent_key_value6           IN varchar2,
p_parent_key_value7           IN varchar2,
p_parent_key_value8           IN varchar2,
p_parent_key_value9           IN varchar2,
p_parent_key_value10          IN varchar2,
p_child_page_appl_id          IN number,
p_child_page_code             IN varchar2,
p_where_clause                IN varchar2,
p_order_by_clause             IN varchar2,
p_responsibility_id           IN number,
p_user_id                     IN number,
p_return_parents              IN varchar2,
p_return_children             IN varchar2,
p_return_node_display_only    IN varchar2,
p_set_trace                   IN varchar2,
p_range_low			IN number,
p_range_high			IN number,
p_where_binds			IN bind_tab,
p_max_rows			IN number,
p_use_subquery		IN varchar2
)
IS

root			        region_rec;
dummy			        varchar2(200);
query_stmt		        varchar2(20000);
retval		        number  := 0;
cursor_id		        number  := 0;
num_select		        number  := 0;
num_key		        number  := 0;
row_num		        number  := 0;
l_current_key_columns		rel_key_tab;
l_current_key_values		rel_key_value_tab;
l_new_key_columns		rel_key_tab;
l_new_key_values		rel_key_value_tab;
l_return_parents              boolean := FALSE;
l_return_children             boolean := FALSE;
l_return_node_display_only    boolean := FALSE;
l_range_low			number := 0;
l_range_high			number := MAXROWNUM;
l_use_subquery		boolean := FALSE;

BEGIN
print_debug('** In function: exec_query **');

g_regions_table.delete;
g_regions_bind_table.delete;
g_items_table.delete;
g_results_table.delete;
--
-- If set_trace is true, enable sql trace
--
-- REMOVED FOR BUG 3304342
--IF (p_set_trace = 'T') THEN
--dummy := 'alter session set sql_trace = true';
--cursor_id := dbms_sql.open_cursor;
--dbms_sql.parse(cursor_id, dummy, dbms_sql.v7);
--retval := dbms_sql.execute(dummy);
--dbms_sql.close_cursor(cursor_id);
--END IF;

IF p_return_node_display_only = 'T' THEN
l_return_node_display_only := TRUE;
ELSE
l_return_node_display_only := FALSE;
END IF;

IF p_return_parents = 'T' THEN
l_return_parents := TRUE;
ELSE
l_return_parents := FALSE;
END IF;

IF p_return_children = 'T' THEN
l_return_children := TRUE;
ELSE
l_return_children := FALSE;
END IF;

IF p_use_subquery = 'T' THEN
l_use_subquery := TRUE;
ELSE
l_use_subquery := FALSE;
END IF;

--
-- Setup root node
--
root.region_rec_id         := 0;
root.parent_region_rec_id  := null;
root.flow_application_id   := p_flow_appl_id;
root.flow_code             := p_flow_code;
root.page_application_id   := p_parent_page_appl_id;
root.page_code             := p_parent_page_code;
root.region_application_id := p_parent_region_appl_id;
root.region_code           := p_parent_region_code;

-- Get object's database_object_name and primary key
select ao.database_object_name, ao.primary_key_name
into root.database_object_name, root.primary_key_name
from ak_objects ao,
ak_regions ar
where ar.region_code = root.region_code
and   ar.region_application_id = root.region_application_id
and   ar.database_object_name = ao.database_object_name;

l_current_key_values(0) := substr(p_parent_key_value1,1,4000);
l_current_key_values(1) := substr(p_parent_key_value2,1,4000);
l_current_key_values(2) := substr(p_parent_key_value3,1,4000);
l_current_key_values(3) := substr(p_parent_key_value4,1,4000);
l_current_key_values(4) := substr(p_parent_key_value5,1,4000);
l_current_key_values(5) := substr(p_parent_key_value6,1,4000);
l_current_key_values(6) := substr(p_parent_key_value7,1,4000);
l_current_key_values(7) := substr(p_parent_key_value8,1,4000);
l_current_key_values(8) := substr(p_parent_key_value9,1,4000);
l_current_key_values(9) := substr(p_parent_key_value10,1,4000);

-- Setup l_new_key_columns and l_new_key_values
-- If a key was passed then check if the passed PK is different
-- than the current PK, if so convert
IF p_parent_primary_key_name is NOT NULL THEN
IF p_parent_primary_key_name <> root.primary_key_name THEN
get_uk_columns(p_parent_primary_key_name, l_current_key_columns);
get_uk_columns(root.primary_key_name, l_new_key_columns);
get_new_key_values(root.database_object_name,
l_current_key_columns,
l_current_key_values,
l_new_key_columns,
l_new_key_values);
ELSE
get_uk_columns(p_parent_primary_key_name, l_current_key_columns);
l_new_key_columns := l_current_key_columns;
l_new_key_values := l_current_key_values;
END IF;
END IF;

--
-- Only use p_range_low and p_range_high if this is an LOV type call
-- i.e. Parent query = TRUE and Child query = FALSE
--
IF ( (l_return_parents = TRUE and l_return_children = FALSE)
or (l_return_parents = FALSE and l_return_children = TRUE) )then
l_range_low := nvl(p_range_low,0);
l_range_high := nvl(p_range_high,MAXROWNUM);
END IF;

--
-- Now that everything is setup, call do_execute_query to do the work
--

-- set defaults due to gscc standard
l_range_low := nvl(l_range_low,0);
l_range_high := nvl(l_range_high,MAXROWNUM);
l_use_subquery := nvl(l_use_subquery, FALSE);

ak_query_pkg.do_execute_query(
root,
l_new_key_columns,
l_new_key_values,
p_child_page_appl_id,
p_child_page_code,
p_where_clause,
p_where_binds,
p_order_by_clause,
p_responsibility_id,
p_user_id,
l_return_parents,
l_return_children,
l_return_node_display_only,
TRUE,
l_range_low,
l_range_high,
p_max_rows,
l_use_subquery);

END exec_query;

-- ======================================================
--  DO_EXECUTE_QUERY					|
-- ======================================================
PROCEDURE do_execute_query
(
p_node	                IN region_rec,
p_node_key_columns		IN rel_key_tab,
p_node_key_values		IN rel_key_value_tab,
p_child_page_appl_id          IN number,
p_child_page_code             IN varchar2,
p_where_clause		IN varchar2,
p_where_binds			IN bind_tab,
p_order_by_clause		IN varchar2,
p_responsibility_id           IN number,
p_user_id                     IN number,
p_return_parents		IN boolean,
p_return_children		IN boolean,
p_return_node_display_only    IN boolean,
p_display_region		IN boolean,
p_range_low			IN number,
p_range_high			IN number,
p_max_rows			IN number,
p_use_subquery		IN boolean
)
IS
l_retval			number := 0;
l_row_num			number := 0;
l_num_select			number := 0;
l_num_key			number := 0;
cursor_id			number;
l_query_stmt			varchar2(32000);
l_key_columns			rel_key_tab;
l_key_values			rel_key_value_tab;
l_rls_binds			bind_tab;
l_select			varchar2(10000);
l_from			varchar2(240);
l_where			varchar2(10000);
l_order_by			varchar2(1000);

-- set defaults due to gscc standard
l_range_low			number := 0;
l_range_high                    number := MAXROWNUM;
l_where_clause          varchar2(10000) := null;
l_where_binds                   bind_tab := G_BIND_TAB_NULL;

BEGIN
print_debug('** in function: do_execute_query ** ');

IF p_return_parents = FALSE and p_return_children = FALSE THEN
-- return the region and item information for the parent only

ak_query_pkg.construct_query(
p_node,
p_node_key_columns,
p_node_key_values,
p_where_clause,
p_order_by_clause,
p_return_node_display_only,
p_display_region,
p_responsibility_id,
p_user_id,
p_max_rows,
p_use_subquery,
l_query_stmt,
l_num_select,
l_num_key,
l_key_columns,
l_rls_binds,
l_select,
l_from,
l_where,
l_order_by);

IF p_display_region THEN
ak_query_pkg.create_region_record(p_node,
p_node_key_values,
p_node_key_columns.COUNT,
l_rls_binds,
p_where_binds,
l_select,
l_from,
l_where,
l_order_by);
END IF;


END IF;


IF p_return_parents THEN

ak_query_pkg.construct_query(
p_node,
p_node_key_columns,
p_node_key_values,
p_where_clause,
p_order_by_clause,
p_return_node_display_only,
p_display_region,
p_responsibility_id,
p_user_id,
p_max_rows,
p_use_subquery,
l_query_stmt,
l_num_select,
l_num_key,
l_key_columns,
l_rls_binds,
l_select,
l_from,
l_where,
l_order_by);

IF p_display_region THEN
ak_query_pkg.create_region_record(p_node,
p_node_key_values,
p_node_key_columns.COUNT,
l_rls_binds,
p_where_binds,
l_select,
l_from,
l_where,
l_order_by);
END IF;

--
-- Retreive data results
--
cursor_id := dbms_sql.open_cursor;
dbms_sql.parse(cursor_id, l_query_stmt, dbms_sql.v7);

IF (p_node_key_columns.count > 0) THEN
ak_query_pkg.bind_sql(cursor_id, p_node_key_values);
END IF;

IF (p_where_binds.count > 0) THEN
ak_query_pkg.bind_where_clause(cursor_id, p_where_binds);
END IF;

IF (l_rls_binds.count > 0) THEN
ak_query_pkg.bind_where_clause(cursor_id, l_rls_binds);
END IF;

ak_query_pkg.define_sql(cursor_id, l_num_select + l_num_key);

l_retval := dbms_sql.execute(cursor_id);

-- Fetch rows
LOOP
l_retval := dbms_sql.fetch_rows(cursor_id);

IF (l_retval = 0) THEN -- no more rows
-- If the region is displayed it will be the highest numbered region,
-- then set region with the total number of rows the query returned
-- regardless of how many rows are actually fetched based on the range
-- used below.
IF p_display_region THEN
g_regions_table(p_node.region_rec_id).total_result_count
:= l_row_num;
END IF;
exit;
ELSE
l_row_num := l_row_num + 1;
print_debug('row# = '||to_char(l_row_num));
END IF;

-- Only get the row and do something with it if it falls within
-- the range of rows to get (i.e. this is an LOV and we are only
-- to return rows 25 - 50
IF l_row_num >= p_range_low AND l_row_num <= p_range_high THEN

ak_query_pkg.get_sql(cursor_id,
l_num_select,
l_num_key,
p_node,
p_display_region,
l_key_values);

IF p_return_children THEN
process_children( p_node,
l_key_columns,
l_key_values,
p_child_page_appl_id,
p_child_page_code,
p_responsibility_id,
p_user_id,
p_return_node_display_only,
p_display_region,
p_use_subquery,
l_range_low,
l_range_high,
l_where_clause,
l_where_binds);
END IF;
END IF;
END LOOP;
dbms_sql.close_cursor(cursor_id);
ELSE
-- p_return_parents is false
-- don't return parents, just take the key_values and get children
IF p_return_children THEN
-- The parameter p_display_region is FALSE, because the parent
-- region wasn't displayed, because p_return_parents was false

-- set defaults to gscc standard
l_range_low := nvl(p_range_low,0);
l_range_high := nvl(p_range_high,MAXROWNUM);
l_where_binds := nvl(p_where_binds,G_BIND_TAB_NULL);

process_children( p_node,
p_node_key_columns,
p_node_key_values,
p_child_page_appl_id,
p_child_page_code,
p_responsibility_id,
p_user_id,
p_return_node_display_only,
FALSE,
p_use_subquery,
l_range_low,
l_range_high,
p_where_clause,
l_where_binds);
END IF;

END IF;

END do_execute_query;


-- ======================================================
--  LOAD_RELATIONS					|
-- ======================================================
PROCEDURE load_relations
(
p_region_rec			        IN region_rec,
p_target_page_appl_id	                IN number,
p_target_page_code                    IN varchar2,
p_relations_table			OUT NOCOPY relations_table_type
)
IS

CURSOR relations_cur
(
flow_appl_id_param	                NUMBER,
flow_code_param		        VARCHAR2,
from_page_appl_id_param	        NUMBER,
from_page_code_param	        VARCHAR2,
from_region_appl_id_param           NUMBER,
from_region_code_param	        VARCHAR2,
to_page_appl_id_param	        NUMBER,
to_page_code_param	                VARCHAR2
)
IS
SELECT afrr.foreign_key_name    foreign_key_name,
afk.unique_key_name      fk_unique_key_name,
afk.database_object_name fk_db_object_name,
afrr.from_page_appl_id   from_page_appl_id,
afrr.from_page_code      from_page_code,
afrr.from_region_appl_id from_region_appl_id,
afrr.from_region_code    from_region_code,
ar1.database_object_name from_db_object_name,
ao1.primary_key_name	    from_obj_unique_key,
decode(afpr1.display_sequence, null, 'N','Y') from_region_disp_flag,
afrr.to_page_appl_id     to_page_appl_id,
afrr.to_page_code        to_page_code,
afrr.to_region_appl_id   to_region_appl_id,
afrr.to_region_code      to_region_code,
ar2.database_object_name to_db_object_name,
ao2.primary_key_name     to_obj_unique_key,
decode(afpr2.display_sequence, null, 'N','Y') to_region_disp_flag,
decode(afpr2.display_sequence, null, 0 ,afpr2.display_sequence) disp_seq
FROM
ak_flow_region_relations afrr,
ak_regions ar1,
ak_regions ar2,
ak_flow_page_regions afpr1,
ak_flow_page_regions afpr2,
ak_objects ao1,
ak_objects ao2,
ak_foreign_keys afk
WHERE afrr.flow_application_id = flow_appl_id_param
AND afrr.flow_code = flow_code_param
AND afrr.from_page_appl_id = from_page_appl_id_param
AND afrr.from_page_code = from_page_code_param
AND afrr.from_region_appl_id = from_region_appl_id_param
AND afrr.from_region_code = from_region_code_param
AND afrr.to_page_appl_id = NVL(to_page_appl_id_param,afrr.to_page_appl_id)
AND afrr.to_page_code = NVL(to_page_code_param,afrr.to_page_code)
AND afrr.from_region_appl_id = ar1.region_application_id
AND afrr.from_region_code = ar1.region_code
AND afrr.to_region_appl_id = ar2.region_application_id
AND afrr.to_region_code = ar2.region_code
AND afrr.flow_application_id = afpr1.flow_application_id
AND afrr.flow_code = afpr1.flow_code
AND afrr.from_page_appl_id = afpr1.page_application_id
AND afrr.from_page_code = afpr1.page_code
AND afrr.from_region_appl_id = afpr1.region_application_id
AND afrr.from_region_code = afpr1.region_code
AND afrr.flow_application_id = afpr2.flow_application_id
AND afrr.flow_code = afpr2.flow_code
AND afrr.to_page_appl_id = afpr2.page_application_id
AND afrr.to_page_code = afpr2.page_code
AND afrr.to_region_appl_id = afpr2.region_application_id
AND afrr.to_region_code = afpr2.region_code
AND ar1.database_object_name = ao1.database_object_name
AND ar2.database_object_name = ao2.database_object_name
AND afrr.foreign_key_name = afk.foreign_key_name
ORDER BY disp_seq
;

rel_rec	relations_cur%rowtype;
rel_count	number := 0;
BEGIN
print_debug('** In function: load_relations');
OPEN relations_cur(p_region_rec.flow_application_id,
p_region_rec.flow_code,
p_region_rec.page_application_id,
p_region_rec.page_code,
p_region_rec.region_application_id,
p_region_rec.region_code,
p_target_page_appl_id,
p_target_page_code);
LOOP
FETCH relations_cur into rel_rec;
exit when relations_cur%notfound;

p_relations_table(rel_count).foreign_key_name   := rel_rec.foreign_key_name;
p_relations_table(rel_count).fk_unique_key_name := rel_rec.fk_unique_key_name;
p_relations_table(rel_count).fk_db_object_name  := rel_rec.fk_db_object_name;
p_relations_table(rel_count).from_page_appl_id  := rel_rec.from_page_appl_id;
p_relations_table(rel_count).from_page_code     := rel_rec.from_page_code;
p_relations_table(rel_count).from_region_appl_id:= rel_rec.from_region_appl_id;
p_relations_table(rel_count).from_region_code   := rel_rec.from_region_code;
p_relations_table(rel_count).from_db_object_name:= rel_rec.from_db_object_name;
p_relations_table(rel_count).from_obj_unique_key:= rel_rec.from_obj_unique_key;
p_relations_table(rel_count).from_display_region:= (rel_rec.from_region_disp_flag = 'Y');
p_relations_table(rel_count).to_page_appl_id    := rel_rec.to_page_appl_id;
p_relations_table(rel_count).to_page_code       := rel_rec.to_page_code;
p_relations_table(rel_count).to_region_appl_id  := rel_rec.to_region_appl_id;
p_relations_table(rel_count).to_region_code     := rel_rec.to_region_code;
p_relations_table(rel_count).to_db_object_name  := rel_rec.to_db_object_name;
p_relations_table(rel_count).to_obj_unique_key  := rel_rec.to_obj_unique_key;
p_relations_table(rel_count).to_display_region  := (rel_rec.to_region_disp_flag = 'Y');


rel_count := rel_count + 1;
END LOOP;
CLOSE relations_cur;

print_debug('** Leaving function: load_relations');

END load_relations;


-- ======================================================
--  CONSTRUCT_QUERY					|
-- ======================================================
PROCEDURE construct_query
(
p_region_rec                  IN region_rec,
p_key_columns			IN rel_key_tab,
p_key_values                  IN rel_key_value_tab,
p_where_clause                IN varchar2,
p_order_by_clause             IN varchar2,
p_return_node_display_only    IN boolean,
p_display_region              IN boolean,
p_responsibility_id           IN number,
p_user_id                     IN number,
p_max_rows			IN number,
p_use_subquery		IN boolean,
p_query_stmt			OUT NOCOPY varchar2,
p_num_select			OUT NOCOPY number,
p_num_key			OUT NOCOPY number,
p_new_key_columns		OUT NOCOPY rel_key_tab,
p_rls_binds			OUT NOCOPY bind_tab,
p_select			OUT NOCOPY varchar2,
p_from			OUT NOCOPY varchar2,
p_where			OUT NOCOPY varchar2,
p_order_by			OUT NOCOPY varchar2
)
IS

CURSOR select_cur
(
p_child_region_appl_id              NUMBER,
p_child_region_code                 VARCHAR2,
p_responsibility_id                 NUMBER
)
IS
-- Select region_items that are also object_attributes
SELECT aoa.column_name                      column_name,
ari.display_sequence                 display_sequence,
ari.attribute_application_id         attribute_application_id,
ari.attribute_code                   attribute_code,
decode(aei.attribute_code,NULL,'F','T')  secured_column,
decode(arsa.attribute_code,NULL,'F','T') rls_column,
decode(ari.icx_custom_call,'INDEX','T','F') indexed_column,
arit.attribute_label_long            attribute_label_long,
ari.attribute_label_length           attribute_label_length,
aa.attribute_value_length		attribute_value_length,
ari.display_value_length             display_value_length,
ari.item_style                       item_style,
ari.bold                             bold,
ari.italic                           italic,
ari.vertical_alignment               vertical_alignment,
ari.horizontal_alignment             horizontal_alignment,
ari.object_attribute_flag            object_attribute_flag,
ari.node_query_flag                  node_query_flag,
ari.node_display_flag                node_display_flag,
ari.update_flag                      update_flag,
ari.required_flag                    required_flag,
ari.icx_custom_call                  icx_custom_call,
aoa.validation_api_pkg               object_validation_api_pkg,
aoa.validation_api_proc              object_validation_api_proc,
aoa.defaulting_api_pkg               object_defaulting_api_pkg,
aoa.defaulting_api_proc              object_defaulting_api_proc,
ari.region_validation_api_pkg        region_validation_api_pkg,
ari.region_validation_api_proc       region_validation_api_proc,
ari.region_defaulting_api_pkg        region_defaulting_api_pkg,
ari.region_defaulting_api_proc       region_defaulting_api_proc,
ari.lov_foreign_key_name             lov_foreign_key_name,
ari.lov_region_application_id        lov_region_application_id,
ari.lov_region_code                  lov_region_code,
ari.lov_attribute_application_id     lov_attribute_application_id,
ari.lov_attribute_code               lov_attribute_code,
ari.lov_default_flag                 lov_default_flag,
ari.order_sequence			order_sequence,
ari.order_direction			order_direction,
aa.data_type				data_type
FROM  ak_object_attributes aoa,
ak_excluded_items aei,
ak_resp_security_attributes arsa,
ak_attributes aa,
ak_regions ar,
ak_region_items_tl arit,
ak_region_items ari
WHERE ari.object_attribute_flag = 'Y'
AND  aoa.attribute_application_id = ari.attribute_application_id
AND  aoa.attribute_code = ari.attribute_code
AND  aoa.database_object_name = ar.database_object_name
AND  ar.region_application_id = ari.region_application_id
AND  ar.region_code = ari.region_code
AND  ari.region_code = p_child_region_code
AND  ari.region_application_id = p_child_region_appl_id
AND  arit.region_code = ari.region_code
AND  arit.region_application_id = ari.region_application_id
AND  arit.attribute_code = ari.attribute_code
AND  arit.attribute_application_id = ari.attribute_application_id
AND  arit.language = userenv('LANG')
AND  aei.responsibility_id (+) = p_responsibility_id
AND  aei.attribute_application_id (+) = ari.attribute_application_id
AND  aei.attribute_code (+) = ari.attribute_code
AND  arsa.responsibility_id (+) = p_responsibility_id
AND  arsa.attribute_application_id (+) = ari.attribute_application_id
AND  arsa.attribute_code (+) = ari.attribute_code
AND  ari.attribute_code = aa.attribute_code
AND  ari.attribute_application_id = aa.attribute_application_id
UNION ALL
-- Select region_items that are not object attributes
SELECT null                                 column_name,
ari.display_sequence                 display_sequence,
ari.attribute_application_id         attribute_application_id,
ari.attribute_code                   attribute_code,
decode(aei.attribute_code,NULL,'F','T')  secured_column,
decode(arsa.attribute_code,NULL,'F','T') rls_column,
decode(ari.icx_custom_call,'INDEX','T','F') indexed_column,
arit.attribute_label_long            attribute_label_long,
ari.attribute_label_length           attribute_label_length,
aa.attribute_value_length		attribute_value_length,
ari.display_value_length             display_value_length,
ari.item_style                       item_style,
ari.bold                             bold,
ari.italic                           italic,
ari.vertical_alignment               vertical_alignment,
ari.horizontal_alignment             horizontal_alignment,
ari.object_attribute_flag            object_attribute_flag,
ari.node_query_flag                  node_query_flag,
ari.node_display_flag                node_display_flag,
ari.update_flag                      update_flag,
ari.required_flag                    required_flag,
ari.icx_custom_call                  icx_custom_call,
null                                 object_validation_api_pkg,
null                                 object_validation_api_proc,
null                                 object_defaulting_api_pkg,
null                                 object_defaulting_api_proc,
ari.region_validation_api_pkg        region_validation_api_pkg,
ari.region_validation_api_proc       region_validation_api_proc,
ari.region_defaulting_api_pkg        region_defaulting_api_pkg,
ari.region_defaulting_api_proc       region_defaulting_api_proc,
ari.lov_foreign_key_name             lov_foreign_key_name,
ari.lov_region_application_id        lov_region_application_id,
ari.lov_region_code                  lov_region_code,
ari.lov_attribute_application_id     lov_attribute_application_id,
ari.lov_attribute_code               lov_attribute_code,
ari.lov_default_flag                 lov_default_flag,
ari.order_sequence			order_sequence,
ari.order_direction			order_direction,
aa.data_type				data_type
FROM  ak_excluded_items aei,
ak_resp_security_attributes arsa,
ak_attributes aa,
ak_region_items_tl arit,
ak_region_items ari
WHERE ari.object_attribute_flag <> 'Y'
AND   ari.region_code = p_child_region_code
AND   ari.region_application_id = p_child_region_appl_id
AND   arit.region_code = ari.region_code
AND   arit.region_application_id = ari.region_application_id
AND   arit.attribute_code = ari.attribute_code
AND   arit.attribute_application_id = ari.attribute_application_id
AND   arit.language = userenv('LANG')
AND   aei.responsibility_id (+) = p_responsibility_id
AND   aei.attribute_application_id (+) = ari.attribute_application_id
AND   aei.attribute_code (+) = ari.attribute_code
AND   arsa.responsibility_id (+) = p_responsibility_id
AND   arsa.attribute_application_id (+) = ari.attribute_application_id
AND   arsa.attribute_code (+) = ari.attribute_code
AND   ari.attribute_code = aa.attribute_code
AND   ari.attribute_application_id = aa.attribute_application_id
ORDER BY 2;

select_rec select_cur%rowtype;


CURSOR attr_values_cur
(
p_user_id                           NUMBER,
p_attribute_appl_id                 NUMBER,
p_attribute_code                    VARCHAR2,
p_responsibility_id                 NUMBER
)
IS
SELECT nvl(to_char(number_value),
nvl(varchar2_value,to_char(date_value))) sec_value
FROM ak_web_user_sec_attr_values awusav
WHERE awusav.web_user_id = p_user_id
AND awusav.attribute_application_id = p_attribute_appl_id
AND awusav.attribute_code = p_attribute_code
union
SELECT nvl(to_char(number_value),
nvl(varchar2_value,to_char(date_value))) sec_value
FROM  AK_RESP_SECURITY_ATTR_VALUES arsav
WHERE arsav.responsibility_id = p_responsibility_id
AND arsav.attribute_application_id = p_attribute_appl_id
AND arsav.attribute_code = p_attribute_code;


attr_values_rec attr_values_cur%rowtype;

l_query_stmt			varchar2(32000);
bind_count			number := 0;
select_count			number := 0;
key_count			number := 0;
row_count			number := 0;
select_stmt			varchar2(10000);
from_stmt			varchar2(240);
where_stmt			varchar2(10000);
order_by_stmt			varchar2(1000);
order_by_col_tab		rel_name_tab;
order_by_dir_tab		rel_name_tab;
node_display_criteria         varchar2(1);
results_table_value_id        integer := 1;
where_temp                    varchar2(1000);
where_secured                 varchar2(5000) := NULL;
i                             integer;
rec_count			number;
l_use_subquery		boolean := FALSE;
l_date_format			varchar2(80);
BEGIN
print_debug('** In function: construct_query');

print_debug('retrieve item/attribute information');
--
-- When constructing the SQL statement, choose
-- between all columns or only those that are marked as
-- node_display_flag = 'Y'.
--
IF p_return_node_display_only THEN
node_display_criteria := 'Y';
ELSE
node_display_criteria := null;
END IF;

--
-- Construct the SQL statement by selecting
-- the region items
--
OPEN select_cur(p_region_rec.region_application_id,
p_region_rec.region_code,
p_responsibility_id);

print_debug('building select list and order by list');
LOOP
FETCH select_cur INTO select_rec;
EXIT WHEN select_cur%NOTFOUND;
row_count := select_cur%ROWCOUNT;

if ( NOT(p_return_node_display_only) or
(p_return_node_display_only and select_rec.node_display_flag = 'Y') ) then
IF select_rec.object_attribute_flag = 'Y' THEN
select_count := select_count + 1;

IF (select_count > 1) THEN
select_stmt := select_stmt || ', ';
END IF;

if ( select_rec.data_type = 'DATETIME' ) then
select value into l_date_format
from V$NLS_PARAMETERS WHERE PARAMETER='NLS_DATE_FORMAT';
l_date_format := l_date_format ||' HH24:MI:SS';
select_stmt := select_stmt ||'TO_CHAR(akq.'||
select_rec.column_name||', '''||
l_date_format||''')';
else
select_stmt := select_stmt || 'SUBSTR(akq.'||
select_rec.column_name ||',1,4000)';
end if;
print_debug('select column = '||select_rec.column_name);

IF select_rec.order_sequence IS NOT NULL THEN
order_by_col_tab(select_rec.order_sequence) := select_rec.column_name;
order_by_dir_tab(select_rec.order_sequence) :=
select_rec.order_direction;

END IF;

END IF; -- end if object_attribute_flag = 'Y'
end if;

IF p_display_region THEN
if ( NOT(p_return_node_display_only) or
(p_return_node_display_only and select_rec.node_display_flag = 'Y') ) then

--
-- Add item defintion to g_items_table.
--
print_debug('Adding attribute to Items Table = '||
select_rec.attribute_code);
i := g_items_table.COUNT;
g_items_table(i).region_rec_id                := p_region_rec.region_rec_id;
g_items_table(i).attribute_application_id     := select_rec.attribute_application_id;
g_items_table(i).attribute_code               := select_rec.attribute_code;
g_items_table(i).attribute_label_long         := select_rec.attribute_label_long;
g_items_table(i).attribute_label_length       := select_rec.attribute_label_length;
g_items_table(i).attribute_value_length       := select_rec.attribute_value_length;
g_items_table(i).display_value_length         := select_rec.display_value_length;
g_items_table(i).display_sequence             := select_rec.display_sequence;
g_items_table(i).item_style                   := select_rec.item_style;
g_items_table(i).bold                         := select_rec.bold;
g_items_table(i).italic                       := select_rec.italic;
g_items_table(i).vertical_alignment           := select_rec.vertical_alignment;
g_items_table(i).horizontal_alignment         := select_rec.horizontal_alignment;
g_items_table(i).object_attribute_flag        := select_rec.object_attribute_flag;
g_items_table(i).node_query_flag              := select_rec.node_query_flag;
g_items_table(i).node_display_flag            := select_rec.node_display_flag;
g_items_table(i).update_flag                  := select_rec.update_flag;
g_items_table(i).required_flag                := select_rec.required_flag;
g_items_table(i).icx_custom_call              := select_rec.icx_custom_call;
g_items_table(i).region_defaulting_api_pkg    := select_rec.region_defaulting_api_pkg;
g_items_table(i).region_defaulting_api_proc   := select_rec.region_defaulting_api_proc;
g_items_table(i).region_validation_api_pkg    := select_rec.region_validation_api_pkg;
g_items_table(i).region_validation_api_proc   := select_rec.region_validation_api_proc;
g_items_table(i).object_defaulting_api_pkg    := select_rec.object_defaulting_api_pkg;
g_items_table(i).object_defaulting_api_proc   := select_rec.object_defaulting_api_proc;
g_items_table(i).object_validation_api_pkg    := select_rec.object_validation_api_pkg;
g_items_table(i).object_validation_api_proc   := select_rec.object_validation_api_proc;
g_items_table(i).lov_foreign_key_name         := select_rec.lov_foreign_key_name;
g_items_table(i).lov_region_application_id    := select_rec.lov_region_application_id;
g_items_table(i).lov_region_code              := select_rec.lov_region_code;
g_items_table(i).lov_attribute_application_id := select_rec.lov_attribute_application_id;
g_items_table(i).lov_attribute_code           := select_rec.lov_attribute_code;
g_items_table(i).lov_default_flag             := select_rec.lov_default_flag;
g_items_table(i).secured_column  		    := select_rec.secured_column;
g_items_table(i).indexed_column  		    := select_rec.indexed_column;
g_items_table(i).rls_column  		    := select_rec.rls_column;

--
-- Set index into result_table for items that are 'object_attributes'.
-- Region Items that are only 'attributes' will have no entry
-- in result_table.
--
IF select_rec.object_attribute_flag = 'Y' THEN
g_items_table(i).value_id := results_table_value_id;
results_table_value_id := results_table_value_id +1;
ELSE
g_items_table(i).value_id := NULL;
END IF;
end if; -- end if display_node_flag = 'Y'

--
-- Item has secured VALUES if it was found on the
-- ak_web_user_sec_attr_values or on the AK_RESP_SECURITY_ATTR_VALUES table.
-- If found, then the
-- record(s) will contain value(s) to use in the where clause
-- to limit row selection. If item was suppose to have secured
-- values, but none where found then create a where clause
-- containing '= NULL' which forces no rows to be found.
--
IF select_rec.rls_column = 'T' THEN
-- if there are more than 255 sec attr values, force p_use_subquery
-- to TRUE
rec_count := 0;
l_use_subquery := p_use_subquery;
for attr_values_rec in attr_values_cur(p_user_id, select_rec.attribute_application_id,
select_rec.attribute_code, p_responsibility_id) loop
rec_count := rec_count + 1;
end loop;
if rec_count > 255 then
l_use_subquery := TRUE;
end if;

IF l_use_subquery = FALSE THEN
DECLARE
i number := nvl(p_rls_binds.LAST,0);
j number := 0;
last_value varchar2(4000);
where_temp varchar2(5000) := NULL;
BEGIN
FOR attr_values_rec IN attr_values_cur(p_user_id,
select_rec.attribute_application_id,
select_rec.attribute_code,
p_responsibility_id) LOOP
i := i + 1;
j := j + 1;
IF where_temp IS NULL THEN
where_temp := '(akq.'||select_rec.column_name || ' IN (';
ELSE
where_temp := where_temp ||', ';
END IF;
where_temp := where_temp || ':BIND'||
to_char(select_count)||'_'||to_char(i);
p_rls_binds(i).name:=
'BIND'||to_char(select_count)||'_'||to_char(i);
p_rls_binds(i).value:= attr_values_rec.sec_value;
END LOOP;
-- pad out the number of binds to 6,11,16,21...
-- this is so there is a better hit ratio in sga for
-- the sql statement
IF j <> 0 THEN
last_value := p_rls_binds(i).value;
WHILE MOD(j,5) <> 1 LOOP
i := i + 1;
j := j + 1;
where_temp := where_temp || ', :BIND'||
to_char(select_count)||'_'||to_char(i);
p_rls_binds(i).name:=
'BIND'||to_char(select_count)||'_'||to_char(i);
p_rls_binds(i).value:= last_value;
END LOOP;
END IF;
IF where_temp IS NOT NULL THEN
where_temp := where_temp || '))';
ELSE
where_temp := '(akq.' || select_rec.column_name || ' = NULL)';
END IF;

where_secured := where_secured || ' AND ' || where_temp;
END;
ELSE  -- p_use_subquery = T
where_temp := '(akq.'||select_rec.column_name || ' IN ('
|| 'SELECT nvl(number_value,nvl(varchar2_value,date_value)) '
|| 'FROM ak_web_user_sec_attr_values awusav '
|| 'WHERE awusav.web_user_id = :BIND'
|| to_char(select_count) || 'USER_ID '
|| 'AND awusav.attribute_application_id = :BIND'
|| to_char(select_count) || 'ATTR_APPL_ID '
|| 'AND awusav.attribute_code = :BIND'
|| to_char(select_count) || 'ATTR_CODE '
|| 'union '
|| 'SELECT nvl(number_value,nvl(varchar2_value,date_value)) '
|| 'FROM AK_RESP_SECURITY_ATTR_VALUES arsav '
|| 'WHERE arsav.responsibility_id = :BIND'
|| to_char(select_count) || 'RESPONSIBILITY_ID '
|| 'AND arsav.attribute_application_id = :BIND'
|| to_char(select_count) || 'ATTR_APPL_ID '
|| 'AND arsav.attribute_code = :BIND'
|| to_char(select_count) || 'ATTR_CODE ))';


DECLARE
i number := nvl(p_rls_binds.LAST,0);
BEGIN
p_rls_binds(i+1).name := 'BIND'||to_char(select_count)||'USER_ID';
p_rls_binds(i+1).value := p_user_id;
p_rls_binds(i+2).name := 'BIND'||to_char(select_count)||
'ATTR_APPL_ID';
p_rls_binds(i+2).value := select_rec.attribute_application_id;
p_rls_binds(i+3).name := 'BIND'||to_char(select_count)||
'ATTR_CODE';
p_rls_binds(i+3).value := select_rec.attribute_code;
p_rls_binds(i+4).name := 'BIND'||to_char(select_count)||'RESPONSIBILITY_ID';
p_rls_binds(i+4).value := p_responsibility_id;

END;

where_secured := where_secured || ' AND ' || where_temp;
END IF;
END IF;
END IF;
END LOOP;

p_num_select := select_count;
print_debug('Select count = '||to_char(select_count));
CLOSE select_cur;

--
-- Now add the key columns to the select
--
DECLARE
l_uk_column_tab rel_key_tab;
BEGIN
get_uk_columns(p_region_rec.primary_key_name, l_uk_column_tab);

FOR i IN 0..(l_uk_column_tab.count -1) LOOP
IF select_stmt IS NOT NULL THEN
select_stmt := select_stmt ||', ';
END IF;
IF l_uk_column_tab(i).is_date THEN
select_stmt := select_stmt || 'TO_CHAR(akq.'||l_uk_column_tab(i).name||
',''YYYY/MM/DD HH24:MI:SS'')';
ELSE
select_stmt := select_stmt || 'akq.' || l_uk_column_tab(i).name;
END IF;
print_debug('key column = '||l_uk_column_tab(i).name);
END LOOP;
key_count := l_uk_column_tab.count;
p_num_key := l_uk_column_tab.count;
p_new_key_columns := l_uk_column_tab;
END;


--
-- Now add the order by columns to the select
-- We add these to the select list so that we can solve the following
-- problems: 1) Must use positional notation since the same column
--		  may be in the select list multiple times
--	       2) Must select these columns again to get the proper
--		  datatyping.  Since the case columns are now substr'ed
--		  this implicitly converts them to varchars so that
--		  ordering by them will give a character ordering
--		  we need to select the raw column to order by here.
--
DECLARE
max_order_by_sequence number := order_by_col_tab.LAST;
i number := order_by_col_tab.FIRST;
-- j is the total number of selected columns so far
j number := select_count + key_count;
append_col boolean;
l_uk_column_tab rel_key_tab;
k number;
uk_column_index number;
BEGIN
get_uk_columns(p_region_rec.primary_key_name, l_uk_column_tab);
-- Only do this if there are columns to order by (order_by_col_tab.FIRST
-- is not null)
IF order_by_col_tab.FIRST IS NOT NULL THEN
WHILE i <= max_order_by_sequence LOOP
append_col := true;
-- we don't want to append the order by column to select list
-- if it's one of the unique key columns
for k in 0 .. (l_uk_column_tab.count - 1 ) loop
if order_by_col_tab(i) = l_uk_column_tab(k).name then
append_col := false;
uk_column_index := k;
end if;
end loop;
if append_col then
j := j + 1;
select_stmt := select_stmt ||', akq.'|| order_by_col_tab(i);
IF order_by_stmt IS NOT NULL THEN
order_by_stmt := order_by_stmt ||', ';
END IF;
order_by_stmt := order_by_stmt ||to_char(j)||' '||order_by_dir_tab(i);
else
if order_by_stmt is not null then
order_by_stmt := order_by_stmt ||', ';
end if;
order_by_stmt := order_by_stmt ||to_char(select_count + uk_column_index + 1)||' '||order_by_dir_tab(i);
print_debug('not append_col order_by = '||order_by_stmt);
end if;
i := order_by_col_tab.NEXT(i);
END LOOP;
END IF;
END;

--
-- Construct the WHERE clause
--

print_debug('constructing where clause');

FOR bind_count IN 1..(p_key_columns.count) LOOP

IF (bind_count > 1) THEN
where_stmt := where_stmt || ' AND ';
END IF;

print_debug('bind fk column '||to_char(bind_count)|| ' is '||
p_key_columns(bind_count-1).name);

if (p_key_values(bind_count-1) is null) then
where_stmt := where_stmt ||'akq.'|| p_key_columns(bind_count-1).name ||
' is NULL ';
else
IF p_key_columns(bind_count-1).is_date THEN
where_stmt := where_stmt ||'akq.'|| p_key_columns(bind_count-1).name ||
' = TO_DATE(:BIND' || to_char(bind_count) ||
',''YYYY/MM/DD HH24:MI:SS'')';
ELSE
where_stmt := where_stmt ||'akq.'|| p_key_columns(bind_count-1).name
|| ' = :BIND' || to_char(bind_count);
END IF;
end if;

END LOOP;

-- Assembling the sql statement
print_debug('assembling sql statement');

-- If a where clause was passed, then add it on to where_stmt.
-- If where_stmt is not null then need to include 'AND'
if p_where_clause is not null then
if where_stmt is not null then
where_stmt := where_stmt || ' AND ('|| p_where_clause || ')';
else
where_stmt := p_where_clause;
end if;
end if;

--
-- Add on row security 'where clause'.
--

-- First make sure there is some where clause to and the row clause to
IF where_stmt IS NULL THEN
where_stmt := ' 1=1 ';
END IF;

  -- Add parens around where_stmt for bug 1774098

IF where_secured IS NOT NULL THEN  -- where secured includes the AND
where_stmt := '(' || where_stmt || ')' || where_secured;
END IF;


-- Assign sql fragments to out variables
p_select := select_stmt;
p_from := p_region_rec.database_object_name || ' akq';
p_where := where_stmt;
p_order_by := nvl(p_order_by_clause, order_by_stmt);


--
-- construct query using the following form:
-- SELECT * FROM (
--    SELECT p_select || FROM p_from || WHERE p_where || ORDER BY p_order_by
-- )
-- WHERE rownum < n
--


--  commented out this to fix bug 1409489
--  l_query_stmt := 'SELECT * FROM ( SELECT ' || select_stmt ||' FROM '||
--			p_region_rec.database_object_name || ' akq' ||
--			' WHERE ' || where_stmt;

-- If necessary add the top n where condition
IF p_max_rows IS NOT NULL THEN
where_stmt := where_stmt || ' AND ROWNUM < '||
to_char(p_max_rows+1);
END IF;

l_query_stmt := 'SELECT '||select_stmt||' FROM '||
p_region_rec.database_object_name ||' akq' ||
' WHERE '||where_stmt;

-- Add order by if one exists (i.e. it was calculated or passed)
-- If an order by clause was passed then use it, else use the one we built
if p_order_by_clause is not null then
l_query_stmt := l_query_stmt || ' ORDER BY '|| p_order_by_clause;
else
if order_by_stmt is not null then
l_query_stmt := l_query_stmt || ' ORDER BY '|| order_by_stmt;
end if;
end if;

-- commented out the line below to fix bug 1409489
-- now add the closing ')' after the inner select
-- l_query_stmt := l_query_stmt || ')';

-- If necessary add the top n where condition
--  IF p_max_rows IS NOT NULL THEN
--    l_query_stmt := l_query_stmt || ' WHERE ROWNUM < '||
--	to_char(p_max_rows+1);
--  END IF;


p_query_stmt := l_query_stmt;
ak_query_pkg.sql_stmt := l_query_stmt;
print_debug('sql_stmt = ' ||substr(l_query_stmt,1,240));
print_debug('where clause = '|| where_stmt);
print_debug('order by clause = '||
nvl(p_order_by_clause,order_by_stmt));

END construct_query;


-- ==============================================
--  GET_SQL					|
-- ==============================================
PROCEDURE get_sql
(
p_cursor_id         	        IN number,
p_num_select        	        IN number,
p_num_key       	        IN number,
p_region_rec			IN region_rec,
p_display_region		IN boolean,
p_key_values			OUT NOCOPY rel_key_value_tab
)
IS

key_index		number := 0;
display_index		number := 0;
key_value		rel_key_value_tab;
display_value		rel_key_value_tab;
i                     integer;
BEGIN
print_debug('** In function: get_sql **');

--
-- Retrieve column values
--
FOR display_index in 0..(p_num_select + p_num_key - 1) LOOP

IF (display_index < p_num_select) THEN
--
-- Retrieve display attribute values
--
dbms_sql.column_value(p_cursor_id, display_index + 1,
display_value(display_index));
print_debug('display_value('||to_char(display_index)||') = '
||display_value(display_index));

ELSE
--
-- Retrieve primary key values
--
dbms_sql.column_value(p_cursor_id, display_index + 1,
key_value(key_index));
print_debug('** key_value(' || to_char(key_index)
|| ')=' || key_value(key_index));
key_index := key_index + 1;
END IF;
END LOOP;

IF p_display_region THEN
print_debug('** creating results record **');
--
-- Populate the Results Table with the returned data.
-- The routine 'g_results_table.COUNT' retrieves the next available slot in the table.
--
i := nvl(g_results_table.last, -1) + 1;
g_results_table(i).region_rec_id         := p_region_rec.region_rec_id;

if (1 <= p_num_key) then
g_results_table(i).key1    := key_value(0);
end if;
if (2 <= p_num_key) then
g_results_table(i).key2    := key_value(1);
end if;
if (3 <= p_num_key) then
g_results_table(i).key3    := key_value(2);
end if;
if (4 <= p_num_key) then
g_results_table(i).key4    := key_value(3);
end if;
if (5 <= p_num_key) then
g_results_table(i).key5    := key_value(4);
end if;
if (6 <= p_num_key) then
g_results_table(i).key6    := key_value(5);
end if;
if (7 <= p_num_key) then
g_results_table(i).key7    := key_value(6);
end if;
if (8 <= p_num_key) then
g_results_table(i).key8    := key_value(7);
end if;
if (9 <= p_num_key) then
g_results_table(i).key9    := key_value(8);
end if;
if (10 <= p_num_key) then
g_results_table(i).key10   := key_value(9);
end if;

if (1 <= p_num_select) then
g_results_table(i).value1 := display_value(0);
end if;
if (2 <= p_num_select) then
g_results_table(i).value2 := display_value(1);
end if;
if (3 <= p_num_select) then
g_results_table(i).value3 := display_value(2);
end if;
if (4 <= p_num_select) then
g_results_table(i).value4 := display_value(3);
end if;
if (5 <= p_num_select) then
g_results_table(i).value5 := display_value(4);
end if;
if (6 <= p_num_select) then
g_results_table(i).value6 := display_value(5);
end if;
if (7 <= p_num_select) then
g_results_table(i).value7 := display_value(6);
end if;
if (8 <= p_num_select) then
g_results_table(i).value8 := display_value(7);
end if;
if (9 <= p_num_select) then
g_results_table(i).value9 := display_value(8);
end if;
if (10 <= p_num_select) then
g_results_table(i).value10 := display_value(9);
end if;
if (11 <= p_num_select) then
g_results_table(i).value11 := display_value(10);
end if;
if (12 <= p_num_select) then
g_results_table(i).value12 := display_value(11);
end if;
if (13 <= p_num_select) then
g_results_table(i).value13 := display_value(12);
end if;
if (14 <= p_num_select) then
g_results_table(i).value14 := display_value(13);
end if;
if (15 <= p_num_select) then
g_results_table(i).value15 := display_value(14);
end if;
if (16 <= p_num_select) then
g_results_table(i).value16 := display_value(15);
end if;
if (17 <= p_num_select) then
g_results_table(i).value17 := display_value(16);
end if;
if (18 <= p_num_select) then
g_results_table(i).value18 := display_value(17);
end if;
if (19 <= p_num_select) then
g_results_table(i).value19 := display_value(18);
end if;
if (20 <= p_num_select) then
g_results_table(i).value20 := display_value(19);
end if;
if (21 <= p_num_select) then
g_results_table(i).value21 := display_value(20);
end if;
if (22 <= p_num_select) then
g_results_table(i).value22 := display_value(21);
end if;
if (23 <= p_num_select) then
g_results_table(i).value23 := display_value(22);
end if;
if (24 <= p_num_select) then
g_results_table(i).value24 := display_value(23);
end if;
if (25 <= p_num_select) then
g_results_table(i).value25 := display_value(24);
end if;
if (26 <= p_num_select) then
g_results_table(i).value26 := display_value(25);
end if;
if (27 <= p_num_select) then
g_results_table(i).value27 := display_value(26);
end if;
if (28 <= p_num_select) then
g_results_table(i).value28 := display_value(27);
end if;
if (29 <= p_num_select) then
g_results_table(i).value29 := display_value(28);
end if;
if (30 <= p_num_select) then
g_results_table(i).value30 := display_value(29);
end if;
if (31 <= p_num_select) then
g_results_table(i).value31 := display_value(30);
end if;
if (32 <= p_num_select) then
g_results_table(i).value32 := display_value(31);
end if;
if (33 <= p_num_select) then
g_results_table(i).value33 := display_value(32);
end if;
if (34 <= p_num_select) then
g_results_table(i).value34 := display_value(33);
end if;
if (35 <= p_num_select) then
g_results_table(i).value35 := display_value(34);
end if;
if (36 <= p_num_select) then
g_results_table(i).value36 := display_value(35);
end if;
if (37 <= p_num_select) then
g_results_table(i).value37 := display_value(36);
end if;
if (38 <= p_num_select) then
g_results_table(i).value38 := display_value(37);
end if;
if (39 <= p_num_select) then
g_results_table(i).value39 := display_value(38);
end if;
if (40 <= p_num_select) then
g_results_table(i).value40 := display_value(39);
end if;
if (41 <= p_num_select) then
g_results_table(i).value41 := display_value(40);
end if;
if (42 <= p_num_select) then
g_results_table(i).value42 := display_value(41);
end if;
if (43 <= p_num_select) then
g_results_table(i).value43 := display_value(42);
end if;
if (44 <= p_num_select) then
g_results_table(i).value44 := display_value(43);
end if;
if (45 <= p_num_select) then
g_results_table(i).value45 := display_value(44);
end if;
if (46 <= p_num_select) then
g_results_table(i).value46 := display_value(45);
end if;
if (47 <= p_num_select) then
g_results_table(i).value47 := display_value(46);
end if;
if (48 <= p_num_select) then
g_results_table(i).value48 := display_value(47);
end if;
if (49 <= p_num_select) then
g_results_table(i).value49 := display_value(48);
end if;
if (50 <= p_num_select) then
g_results_table(i).value50 := display_value(49);
end if;
if (51 <= p_num_select) then
g_results_table(i).value51 := display_value(50);
end if;
if (52 <= p_num_select) then
g_results_table(i).value52 := display_value(51);
end if;
if (53 <= p_num_select) then
g_results_table(i).value53 := display_value(52);
end if;
if (54 <= p_num_select) then
g_results_table(i).value54 := display_value(53);
end if;
if (55 <= p_num_select) then
g_results_table(i).value55 := display_value(54);
end if;
if (56 <= p_num_select) then
g_results_table(i).value56 := display_value(55);
end if;
if (57 <= p_num_select) then
g_results_table(i).value57 := display_value(56);
end if;
if (58 <= p_num_select) then
g_results_table(i).value58 := display_value(57);
end if;
if (59 <= p_num_select) then
g_results_table(i).value59 := display_value(58);
end if;
if (60 <= p_num_select) then
g_results_table(i).value60 := display_value(59);
end if;
if (61 <= p_num_select) then
g_results_table(i).value61 := display_value(60);
end if;
if (62 <= p_num_select) then
g_results_table(i).value62 := display_value(61);
end if;
if (63 <= p_num_select) then
g_results_table(i).value63 := display_value(62);
end if;
if (64 <= p_num_select) then
g_results_table(i).value64 := display_value(63);
end if;
if (65 <= p_num_select) then
g_results_table(i).value65 := display_value(64);
end if;
if (66 <= p_num_select) then
g_results_table(i).value66 := display_value(65);
end if;
if (67 <= p_num_select) then
g_results_table(i).value67 := display_value(66);
end if;
if (68 <= p_num_select) then
g_results_table(i).value68 := display_value(67);
end if;
if (69 <= p_num_select) then
g_results_table(i).value69 := display_value(68);
end if;
if (70 <= p_num_select) then
g_results_table(i).value70 := display_value(69);
end if;
if (71 <= p_num_select) then
g_results_table(i).value71 := display_value(70);
end if;
if (72 <= p_num_select) then
g_results_table(i).value72 := display_value(71);
end if;
if (73 <= p_num_select) then
g_results_table(i).value73 := display_value(72);
end if;
if (74 <= p_num_select) then
g_results_table(i).value74 := display_value(73);
end if;
if (75 <= p_num_select) then
g_results_table(i).value75 := display_value(74);
end if;
if (76 <= p_num_select) then
g_results_table(i).value76 := display_value(75);
end if;
if (77 <= p_num_select) then
g_results_table(i).value77 := display_value(76);
end if;
if (78 <= p_num_select) then
g_results_table(i).value78 := display_value(77);
end if;
if (79 <= p_num_select) then
g_results_table(i).value79 := display_value(78);
end if;
if (80 <= p_num_select) then
g_results_table(i).value80 := display_value(79);
end if;
if (81 <= p_num_select) then
g_results_table(i).value81 := display_value(80);
end if;
if (82 <= p_num_select) then
g_results_table(i).value82 := display_value(81);
end if;
if (83 <= p_num_select) then
g_results_table(i).value83 := display_value(82);
end if;
if (84 <= p_num_select) then
g_results_table(i).value84 := display_value(83);
end if;
if (85 <= p_num_select) then
g_results_table(i).value85 := display_value(84);
end if;
if (86 <= p_num_select) then
g_results_table(i).value86 := display_value(85);
end if;
if (87 <= p_num_select) then
g_results_table(i).value87 := display_value(86);
end if;
if (88 <= p_num_select) then
g_results_table(i).value88 := display_value(87);
end if;
if (89 <= p_num_select) then
g_results_table(i).value89 := display_value(88);
end if;
if (90 <= p_num_select) then
g_results_table(i).value90 := display_value(89);
end if;
if (91 <= p_num_select) then
g_results_table(i).value91 := display_value(90);
end if;
if (92 <= p_num_select) then
g_results_table(i).value92 := display_value(91);
end if;
if (93 <= p_num_select) then
g_results_table(i).value93 := display_value(92);
end if;
if (94 <= p_num_select) then
g_results_table(i).value94 := display_value(93);
end if;
if (95 <= p_num_select) then
g_results_table(i).value95 := display_value(94);
end if;
if (96 <= p_num_select) then
g_results_table(i).value96 := display_value(95);
end if;
if (97 <= p_num_select) then
g_results_table(i).value97 := display_value(96);
end if;
if (98 <= p_num_select) then
g_results_table(i).value98 := display_value(97);
end if;
if (99 <= p_num_select) then
g_results_table(i).value99 := display_value(98);
end if;
if (100 <= p_num_select) then
g_results_table(i).value100:= display_value(99);
end if;

print_debug('finish populate results_table');
END IF;

-- Set out variables
p_key_values := key_value;

END get_sql;


-- ==============================================
--  DEFINE_SQL					|
-- ==============================================
PROCEDURE define_sql
(
p_cursor_id                   IN number,
p_num_select                  IN number
)
IS

select_index    number := 0;
BEGIN
print_debug('** In function: define_sql **');

--
-- define each select column with an appropriate variable
--

FOR select_index in 0..(p_num_select - 1) LOOP
dbms_sql.define_column(p_cursor_id, select_index + 1, NULL, 4000);
END LOOP;
END define_sql;


-- ==============================================
--  BIND_SQL					|
-- ==============================================
PROCEDURE bind_sql
(
p_cursor_id                   IN number,
p_key_values                  IN rel_key_value_tab
) IS

key_index		number := 0;
dont_care_error	EXCEPTION;

PRAGMA EXCEPTION_INIT(dont_care_error, -1006);
BEGIN
print_debug('** In function: bind_sql **');

--
-- bind each variable to the appropriate key value
--

FOR key_index in 0..(MAXKEYNUM-1) LOOP
BEGIN
print_debug('key_value(' || to_char(key_index) || ') = '
|| p_key_values(key_index));

IF (p_key_values(key_index) IS NOT NULL) THEN
BEGIN
print_debug('binding bind variable :BIND'||
to_char(key_index + 1));
dbms_sql.bind_variable(p_cursor_id, 'BIND' ||
to_char(key_index + 1),
p_key_values(key_index));
EXCEPTION
WHEN dont_care_error THEN NULL;
END;
END IF;
EXCEPTION
WHEN no_data_found THEN EXIT;
END;
END LOOP;

END bind_sql;


-- ==============================================
--  BIND_WHERE_CLAUSE				|
-- ==============================================
PROCEDURE bind_where_clause
(
p_cursor_id                   IN number,
p_where_binds                 IN bind_tab
) IS

bind_index		number := 1;
i			number := p_where_binds.FIRST;

BEGIN
print_debug('** In function: bind_where_clause **');

--
-- bind each variable to the appropriate value
--

FOR bind_index in 1..(p_where_binds.count) LOOP

print_debug('binding bind variable :'
|| p_where_binds(i).name || ' to '
|| '''' || p_where_binds(i).value || '''');
dbms_sql.bind_variable(p_cursor_id, p_where_binds(i).name,
p_where_binds(i).value);
i := p_where_binds.NEXT(i);
END LOOP;

END bind_where_clause;

-- ==============================================
--  CREATE_REGION_RECORD			|
-- ==============================================
PROCEDURE create_region_record
(
p_region_rec	                IN region_rec,
p_key_column_values		IN rel_key_value_tab,
p_key_column_count		IN number,
p_where_binds			IN bind_tab,
p_rls_binds			IN bind_tab,
p_select			IN varchar2,
p_from			IN varchar2,
p_where			IN varchar2,
p_order_by			IN varchar2
)
IS
l_region_style              	varchar2(30);
l_number_of_format_columns  	number;
l_region_name               	varchar2(80);
l_object_validation_api_pkg 	varchar2(30);
l_object_validation_api_proc	varchar2(30);
l_object_defaulting_api_pkg 	varchar2(30);
l_object_defaulting_api_proc	varchar2(30);
l_region_validation_api_pkg 	varchar2(30);
l_region_validation_api_proc	varchar2(30);
l_region_defaulting_api_pkg 	varchar2(30);
l_region_defaulting_api_proc	varchar2(30);
l_display_sequence		number;
i     integer;
BEGIN
print_debug('** In function: create_region_record **');

-- Get the rest of the attributes of the region
-- First try to get them from AK_FLOW_PAGE_REGIONS

BEGIN
SELECT fpr.region_style              region_style,
fpr.num_columns               number_of_format_columns,
art.name                      region_name,
ao.validation_api_pkg         object_validation_api_pkg,
ao.validation_api_proc        object_validation_api_proc,
ao.defaulting_api_pkg         object_defaulting_api_pkg,
ao.defaulting_api_proc        object_defaulting_api_proc,
ar.region_validation_api_pkg  region_validation_api_pkg,
ar.region_validation_api_proc region_validation_api_proc,
ar.region_defaulting_api_pkg  region_defaulting_api_pkg,
ar.region_defaulting_api_proc region_defaulting_api_proc,
fpr.display_sequence		 display_sequence
INTO   l_region_style              ,
l_number_of_format_columns  ,
l_region_name               ,
l_object_validation_api_pkg ,
l_object_validation_api_proc,
l_object_defaulting_api_pkg ,
l_object_defaulting_api_proc,
l_region_validation_api_pkg ,
l_region_validation_api_proc,
l_region_defaulting_api_pkg ,
l_region_defaulting_api_proc,
l_display_sequence
FROM ak_flow_page_regions fpr,
ak_regions ar,
ak_regions_tl art,
ak_objects ao
WHERE fpr.flow_application_id = p_region_rec.flow_application_id
AND fpr.flow_code = p_region_rec.flow_code
AND fpr.page_application_id = p_region_rec.page_application_id
AND fpr.page_code = p_region_rec.page_code
AND fpr.region_application_id = p_region_rec.region_application_id
AND fpr.region_code = p_region_rec.region_code
AND ar.region_application_id = fpr.region_application_id
AND ar.region_code = fpr.region_code
AND art.region_application_id = ar.region_application_id
AND art.region_code = ar.region_code
AND art.language = userenv('LANG')
AND ao.database_object_name = ar.database_object_name;

EXCEPTION
WHEN NO_DATA_FOUND THEN
-- If AK_FLOW_PAGE_REGIONS does not have a record (i.e. this
-- call is for an LOV (i.e. no flow) then get the default information
-- from AK_REGIONS directly
SELECT ar.region_style               region_style,
ar.num_columns                number_of_format_columns,
art.name                      region_name,
ao.validation_api_pkg         object_validation_api_pkg,
ao.validation_api_proc        object_validation_api_proc,
ao.defaulting_api_pkg         object_defaulting_api_pkg,
ao.defaulting_api_proc        object_defaulting_api_proc,
ar.region_validation_api_pkg  region_validation_api_pkg,
ar.region_validation_api_proc region_validation_api_proc,
ar.region_defaulting_api_pkg  region_defaulting_api_pkg,
ar.region_defaulting_api_proc region_defaulting_api_proc,
null
INTO   l_region_style              ,
l_number_of_format_columns  ,
l_region_name               ,
l_object_validation_api_pkg ,
l_object_validation_api_proc,
l_object_defaulting_api_pkg ,
l_object_defaulting_api_proc,
l_region_validation_api_pkg ,
l_region_validation_api_proc,
l_region_defaulting_api_pkg ,
l_region_defaulting_api_proc,
l_display_sequence
FROM ak_regions ar,
ak_regions_tl art,
ak_objects ao
WHERE ar.region_application_id = p_region_rec.region_application_id
AND ar.region_code = p_region_rec.region_code
AND art.region_application_id = ar.region_application_id
AND art.region_code = ar.region_code
AND art.language = userenv('LANG')
AND ao.database_object_name = ar.database_object_name;
WHEN OTHERS THEN RAISE;
END;

--
-- Add region defintion child g_regions_table.
--
i := p_region_rec.region_rec_id;
g_regions_table(i).region_rec_id              := i;
g_regions_table(i).parent_region_rec_id       := p_region_rec.parent_region_rec_id;
g_regions_table(i).flow_application_id        := p_region_rec.flow_application_id;
g_regions_table(i).flow_code                  := p_region_rec.flow_code;
g_regions_table(i).page_application_id        := p_region_rec.page_application_id;
g_regions_table(i).page_code                  := p_region_rec.page_code;
g_regions_table(i).region_application_id      := p_region_rec.region_application_id;
g_regions_table(i).region_code                := p_region_rec.region_code;
g_regions_table(i).name                       := l_region_name;
g_regions_table(i).region_style               := l_region_style;
g_regions_table(i).primary_key_name           := p_region_rec.primary_key_name;
g_regions_table(i).number_of_format_columns   := l_number_of_format_columns;
g_regions_table(i).object_validation_api_pkg  := l_object_validation_api_pkg;
g_regions_table(i).object_validation_api_proc := l_object_validation_api_proc;
g_regions_table(i).object_defaulting_api_pkg  := l_object_defaulting_api_pkg;
g_regions_table(i).object_defaulting_api_proc := l_object_defaulting_api_proc;
g_regions_table(i).region_validation_api_pkg  := l_region_validation_api_pkg;
g_regions_table(i).region_validation_api_proc := l_region_validation_api_proc;
g_regions_table(i).region_defaulting_api_pkg  := l_region_defaulting_api_pkg;
g_regions_table(i).region_defaulting_api_proc := l_region_defaulting_api_proc;
g_regions_table(i).display_sequence           := l_display_sequence;
g_regions_table(i).sql_select			:= p_select;
g_regions_table(i).sql_from			:= p_from;
g_regions_table(i).sql_where			:= p_where;
g_regions_table(i).sql_order_by		:= p_order_by;

-- add records to bind values table for this region

-- first add the bind variables for the passed PK values (if any)
DECLARE
bind_index number := 1;
j          number := p_key_column_values.FIRST;
k	       number := nvl(g_regions_bind_table.LAST,0) + 1;
BEGIN
FOR key_index in 1..(p_key_column_count) LOOP
-- only non null values have bind variables
IF p_key_column_values(j) is not null THEN
g_regions_bind_table(k).region_rec_id := i;
g_regions_bind_table(k).name := 'BIND'|| j;
g_regions_bind_table(k).value := p_key_column_values(j);
print_debug('adding to bind table: '||k||' region='||
i||' name='||'BIND'||j||' value='||
p_key_column_values(j));
j := p_key_column_values.NEXT(j);
k := k+1;
END IF;
END LOOP;
END;

-- add in binds from p_where_binds
DECLARE
bind_index number := 1;
j          number := p_where_binds.FIRST;
k	       number := nvl(g_regions_bind_table.LAST,0) + 1;
BEGIN
FOR key_index in 1..(p_where_binds.COUNT) LOOP
g_regions_bind_table(k).region_rec_id := i;
g_regions_bind_table(k).name := p_where_binds(j).name;
g_regions_bind_table(k).value := p_where_binds(j).value;
print_debug('adding to bind table: '||k||' region='||
i||' name='||p_where_binds(j).name||' value='||p_where_binds(j).value);
j := p_where_binds.NEXT(j);
k := k+1;
END LOOP;
END;

-- add in binds from p_rls_binds
DECLARE
bind_index number := 1;
j          number := p_rls_binds.FIRST;
k	       number := nvl(g_regions_bind_table.LAST,0) + 1;
BEGIN
FOR key_index in 1..(p_rls_binds.COUNT) LOOP
g_regions_bind_table(k).region_rec_id := i;
g_regions_bind_table(k).name := p_rls_binds(j).name;
g_regions_bind_table(k).value := p_rls_binds(j).value;
print_debug('adding to bind table: '||k||' region='||
i||' name='||p_rls_binds(j).name||' value='||p_rls_binds(j).value);
j := p_rls_binds.NEXT(j);
k := k+1;
END LOOP;
END;

END create_region_record;


-- ==============================================
--  GET_NEW_KEY_VALUES			        |
-- ==============================================
PROCEDURE get_new_key_values
(
p_db_object_name		IN varchar2,
p_current_key_columns		IN rel_key_tab,
p_current_key_values		IN rel_key_value_tab,
p_new_key_columns		IN rel_key_tab,
p_new_key_values		OUT NOCOPY rel_key_value_tab
)
IS

c integer;
l_retval number;
l_sql_statement varchar2(2000) := 'SELECT ';
x integer;
y integer;
l_new_key_values	rel_key_value_tab;

BEGIN
print_debug('** In function: get_new_key_values **');

FOR x in 0..p_new_key_columns.count - 1 LOOP
IF (x > 0) THEN
l_sql_statement := l_sql_statement || ', ';
END IF;

IF p_new_key_columns(x).is_date THEN
l_sql_statement := l_sql_statement || 'TO_CHAR('||
p_new_key_columns(x).name || ',''YYYY/MM/DD HH24:MI:SS'')';
ELSE
l_sql_statement := l_sql_statement || 'SUBSTR('||
p_new_key_columns(x).name || ',1,4000)';
END IF;
END LOOP;

-- Add FROM clause

l_sql_statement := l_sql_statement ||' FROM '|| p_db_object_name;

-- Add WHERE clause

l_sql_statement := l_sql_statement || ' WHERE ';

FOR y in 0..p_current_key_columns.count - 1 LOOP
IF (y > 0) THEN
l_sql_statement := l_sql_statement || ' AND ';
END IF;

IF (p_current_key_values(y) is null) THEN
l_sql_statement:=l_sql_statement||p_current_key_columns(y).name||
' is NULL';
ELSE
IF p_current_key_columns(y).is_date THEN
l_sql_statement:= l_sql_statement || p_current_key_columns(y).name ||
' = TO_DATE(:BIND' || to_char(y+1) ||',''YYYY/MM/DD HH24:MI:SS'')';
ELSE
l_sql_statement:= l_sql_statement || p_current_key_columns(y).name ||
' = :BIND' || to_char(y+1);
END IF;
END IF;

END LOOP;

ak_query_pkg.sql_stmt := l_sql_statement;

--  Now execute the select statement built above
c := dbms_sql.open_cursor;
dbms_sql.parse(c, l_sql_statement, dbms_sql.v7);

-- Bind Values

bind_sql(c,p_current_key_values);

-- Define select list data types
FOR i in 1..p_new_key_columns.count LOOP
dbms_sql.define_column(c, i, NULL, 4000);
END LOOP;

l_retval := dbms_sql.execute(c);

-- Fetch the first row from SQL statement (there should be none or one)

l_retval := dbms_sql.fetch_rows(c);
-- If the fetch returns a row then get new values, else no rows were
-- returned.  This may happen when a FK
IF l_retval = 0 THEN
RAISE NO_DATA_FOUND;
END IF;

-- Retrieve column values
FOR i in 1..p_new_key_columns.count LOOP
print_debug('New Key Column'||to_char(i));
dbms_sql.column_value(c, i, l_new_key_values(i - 1));
print_debug(' value: '||l_new_key_values(i - 1));
END LOOP;

-- Assign values to OUT parameters

p_new_key_values := l_new_key_values;
dbms_sql.close_cursor(c);

END;

-- ======================================================
--  get_fk_columns					|
-- ======================================================
PROCEDURE get_fk_columns
( p_foreign_key_name	IN varchar2,
p_fk_column_tab	OUT NOCOPY rel_key_tab )
IS

CURSOR fk_cur
(
foreign_key_name_param              VARCHAR2
)
IS
SELECT aoa.column_name foreign_key_column_name, aa.data_type
FROM ak_foreign_keys afk,
ak_foreign_key_columns afkc,
ak_object_attributes aoa,
ak_attributes aa
WHERE
afk.database_object_name = aoa.database_object_name
AND  afkc.attribute_application_id = aoa.attribute_application_id
AND  afkc.attribute_code = aoa.attribute_code
AND  afkc.foreign_key_name = afk.foreign_key_name
AND  afk.foreign_key_name = foreign_key_name_param
AND  aoa.attribute_code = aa.attribute_code
AND  aoa.attribute_application_id = aa.attribute_application_id
ORDER BY afkc.foreign_key_sequence;

fk_cur_rec fk_cur%rowtype;
i integer := 0;
BEGIN
print_debug('** In function: get_fk_columns');
print_debug('foreign_key_name='||p_foreign_key_name);

OPEN fk_cur(p_foreign_key_name);
LOOP
FETCH fk_cur INTO fk_cur_rec;
EXIT WHEN fk_cur%NOTFOUND;
p_fk_column_tab(i).name := fk_cur_rec.foreign_key_column_name;
if (fk_cur_rec.data_type = 'DATE' or fk_cur_rec.data_type = 'DATETIME') THEN
p_fk_column_tab(i).is_date := TRUE;
else
p_fk_column_tab(i).is_date := FALSE;
end if;
i := i + 1;
END LOOP;
CLOSE fk_cur;

END get_fk_columns;

-- ======================================================
--  get_uk_columns					|
-- ======================================================
PROCEDURE get_uk_columns
( p_unique_key_name	IN varchar2,
p_uk_column_tab	OUT NOCOPY rel_key_tab )
IS

CURSOR uk_cur
(
unique_key_name_param              VARCHAR2
)
IS
SELECT aoa.column_name unique_key_column_name, aa.data_type
FROM ak_unique_keys auk,
ak_unique_key_columns aukc,
ak_object_attributes aoa,
ak_attributes aa
WHERE
auk.database_object_name = aoa.database_object_name
AND  aukc.attribute_application_id = aoa.attribute_application_id
AND  aukc.attribute_code = aoa.attribute_code
AND  aukc.unique_key_name = auk.unique_key_name
AND  auk.unique_key_name = unique_key_name_param
AND  aoa.attribute_code = aa.attribute_code
AND  aoa.attribute_application_id = aa.attribute_application_id
ORDER BY aukc.unique_key_sequence;

uk_cur_rec uk_cur%rowtype;
i integer := 0;
BEGIN
print_debug('** In function: get_uk_columns (UK='||
p_unique_key_name||')');

OPEN uk_cur(p_unique_key_name);
LOOP
FETCH uk_cur INTO uk_cur_rec;
EXIT WHEN uk_cur%NOTFOUND;
p_uk_column_tab(i).name := uk_cur_rec.unique_key_column_name;
if (uk_cur_rec.data_type = 'DATE' or uk_cur_rec.data_type = 'DATETIME') THEN
p_uk_column_tab(i).is_date := TRUE;
else
p_uk_column_tab(i).is_date := FALSE;
end if;
i := i + 1;
END LOOP;
CLOSE uk_cur;

END get_uk_columns;

-- ======================================================
-- PROCESS_CHILDREN					|
-- ======================================================
PROCEDURE process_children
(
p_parent	                IN region_rec,
p_parent_key_columns		IN rel_key_tab,
p_parent_key_values		IN rel_key_value_tab,
p_child_page_appl_id          IN number,
p_child_page_code             IN varchar2,
p_responsibility_id           IN number,
p_user_id                     IN number,
p_return_node_display_only    IN boolean,
p_display_region		IN boolean,
p_use_subquery		IN boolean,
p_range_low			IN number,
p_range_high			IN number,
p_where_clause		IN Varchar2,
p_where_binds			IN bind_tab)
IS

l_parent_key_columns		rel_key_tab;
l_child			region_rec;
l_child_key_columns		rel_key_tab;
l_child_key_values		rel_key_value_tab;
l_relations_table		relations_table_type;

-- set defaults due to gscc standard
l_range_low			number := 0;
l_range_high                    number := MAXROWNUM;
l_use_subquery			boolean := FALSE;

BEGIN
print_debug('** in function: process_children ** ');

-- If no key_columns where passed then get them
-- This can happen if the original call to execute_query didn't pass
-- a PK
IF p_parent_key_columns.count = 0 THEN
get_uk_columns(p_parent.primary_key_name,l_parent_key_columns);
ELSE
l_parent_key_columns := p_parent_key_columns;
END IF;

-- For each row recurse down to get it children

ak_query_pkg.load_relations(p_parent,
p_child_page_appl_id,
p_child_page_code,
l_relations_table);

print_debug('Found '||to_char(l_relations_table.count)||
' relations');
IF l_relations_table.count > 0 THEN
FOR i in 0..(l_relations_table.count - 1) LOOP

print_debug('relation number = '||to_char(i+1));

--
-- Get columns and values for child
--

-- determine direction of FK
-- check if the parent object is different than the FK object
IF p_parent.database_object_name <>
l_relations_table(i).fk_db_object_name THEN
-- relation is PK->FK
print_debug('relation is PK->FK');

-- First get the key_columns for the child from the FK
get_fk_columns(l_relations_table(i).foreign_key_name,
l_child_key_columns);

-- Now get the appropriate values to bind to these FK columns

-- Since we are going from a UK on the parent to a FK on the child
-- if the passed UK is the same as the UK referenced by the FK
-- the passed values can be used
IF (p_parent.primary_key_name =
l_relations_table(i).fk_unique_key_name) THEN
print_debug('An easy join');
l_child_key_values := p_parent_key_values;
ELSE
-- This is a diferent UK, therefore we need to convert from one
-- to the other
print_debug('Not an easy join');

DECLARE
l_key_columns rel_key_tab;
BEGIN
get_uk_columns(l_relations_table(i).fk_unique_key_name,
l_key_columns);
get_new_key_values(
p_parent.database_object_name,
l_parent_key_columns,
p_parent_key_values,
l_key_columns,
l_child_key_values);
END;
END IF;

ELSE
-- Relation is FK->PK
print_debug('relation is FK->PK');

-- First get the key_columns for the child from the UK that the FK
-- references
get_uk_columns(l_relations_table(i).fk_unique_key_name,
l_child_key_columns);

-- Now get the appropriate values to bind to these UK columns

-- Since we are going from a FK on the parent to a UK on the child
-- we need to convert the passed parent UK values to the FK values
print_debug('Not an easy join');

DECLARE
l_key_columns rel_key_tab;
BEGIN
get_fk_columns(l_relations_table(i).foreign_key_name,
l_key_columns);
get_new_key_values(
p_parent.database_object_name,
l_parent_key_columns,
p_parent_key_values,
l_key_columns,
l_child_key_values);
END;

END IF;

-- Setup new region
l_child.region_rec_id := 	g_regions_table.count;
l_child.flow_application_id :=
p_parent.flow_application_id;
l_child.flow_code := p_parent.flow_code;
l_child.page_application_id :=
l_relations_table(i).to_page_appl_id;
l_child.page_code := l_relations_table(i).to_page_code;
l_child.region_application_id :=
l_relations_table(i).to_region_appl_id;
l_child.region_code := l_relations_table(i).to_region_code;
l_child.primary_key_name :=
l_relations_table(i).to_obj_unique_key;
l_child.database_object_name :=
l_relations_table(i).to_db_object_name;
--
-- If parent region is not displayed, parent_region_rec_id of
-- child region should point to the grandparent region.
--

IF (p_display_region = FALSE) THEN
l_child.parent_region_rec_id := p_parent.parent_region_rec_id;
ELSE
l_child.parent_region_rec_id := p_parent.region_rec_id;
END IF;

--
-- Call do_execute_query recursively to get children
--

-- set defaults due to gscc standard
l_range_low := nvl(p_range_low, 0);
l_range_high := nvl(p_range_high, MAXROWNUM);
l_use_subquery := nvl(p_use_subquery, FALSE);

print_debug('before calling do_execute_query recursively');
do_execute_query(l_child,
l_child_key_columns,
l_child_key_values,
l_child.page_application_id,
l_child.page_code,
p_where_clause, -- = null if p_return_parents = true
p_where_binds,
null,
p_responsibility_id,
p_user_id,
TRUE,
TRUE,
p_return_node_display_only,
l_relations_table(i).to_display_region,
l_range_low,
l_range_high,
null,
l_use_subquery);
print_debug('after calling do_execute_query recursively');
END LOOP;
END IF;
END process_children;

function getSecuredWhere(
p_region_rec                  IN region_rec,
p_responsibility_id           IN number,
p_user_id                     IN number,
p_where_clause                IN varchar2,
p_order_by_clause             IN varchar2,
p_return_node_display_only    IN boolean,
p_display_region              IN boolean
) return varchar2

IS
where_secured                 varchar2(12000) := NULL;


CURSOR select_cur
(
p_child_region_appl_id              NUMBER,
p_child_region_code                 VARCHAR2,
p_responsibility_id                 NUMBER,
p_node_display_criteria             VARCHAR2
)
IS
-- Select region_items that are also object_attributes
SELECT aoa.column_name                      column_name,
ari.display_sequence                 display_sequence,
ari.attribute_application_id         attribute_application_id,
ari.attribute_code                   attribute_code,
decode(aei.attribute_code,NULL,'F','T')  secured_column,
decode(arsa.attribute_code,NULL,'F','T') rls_column,
decode(ari.icx_custom_call,'INDEX','T','F') indexed_column,
arit.attribute_label_long            attribute_label_long,
ari.attribute_label_length           attribute_label_length,
aa.attribute_value_length		attribute_value_length,
ari.display_value_length             display_value_length,
ari.item_style                       item_style,
ari.bold                             bold,
ari.italic                           italic,
ari.vertical_alignment               vertical_alignment,
ari.horizontal_alignment             horizontal_alignment,
ari.object_attribute_flag            object_attribute_flag,
ari.node_query_flag                  node_query_flag,
ari.node_display_flag                node_display_flag,
ari.update_flag                      update_flag,
ari.required_flag                    required_flag,
ari.icx_custom_call                  icx_custom_call,
aoa.validation_api_pkg               object_validation_api_pkg,
aoa.validation_api_proc              object_validation_api_proc,
aoa.defaulting_api_pkg               object_defaulting_api_pkg,
aoa.defaulting_api_proc              object_defaulting_api_proc,
ari.region_validation_api_pkg        region_validation_api_pkg,
ari.region_validation_api_proc       region_validation_api_proc,
ari.region_defaulting_api_pkg        region_defaulting_api_pkg,
ari.region_defaulting_api_proc       region_defaulting_api_proc,
ari.lov_foreign_key_name             lov_foreign_key_name,
ari.lov_region_application_id        lov_region_application_id,
ari.lov_region_code                  lov_region_code,
ari.lov_attribute_application_id     lov_attribute_application_id,
ari.lov_attribute_code               lov_attribute_code,
ari.lov_default_flag                 lov_default_flag,
ari.order_sequence			order_sequence,
ari.order_direction			order_direction,
aa.data_type				data_type
FROM  ak_object_attributes aoa,
ak_excluded_items aei,
ak_resp_security_attributes arsa,
ak_attributes aa,
ak_regions ar,
ak_region_items_tl arit,
ak_region_items ari
WHERE ari.object_attribute_flag = 'Y'
AND  aoa.attribute_application_id = ari.attribute_application_id
AND  aoa.attribute_code = ari.attribute_code
AND  aoa.database_object_name = ar.database_object_name
AND  ar.region_application_id = ari.region_application_id
AND  ar.region_code = ari.region_code
AND  ari.region_code = p_child_region_code
AND  ari.region_application_id = p_child_region_appl_id
AND  ari.node_display_flag =
decode(p_node_display_criteria,'Y','Y',ari.node_display_flag)
AND  arit.region_code = ari.region_code
AND  arit.region_application_id = ari.region_application_id
AND  arit.attribute_code = ari.attribute_code
AND  arit.attribute_application_id = ari.attribute_application_id
AND  arit.language = userenv('LANG')
AND  aei.responsibility_id (+) = p_responsibility_id
AND  aei.attribute_application_id (+) = ari.attribute_application_id
AND  aei.attribute_code (+) = ari.attribute_code
AND  arsa.responsibility_id (+) = p_responsibility_id
AND  arsa.attribute_application_id (+) = ari.attribute_application_id
AND  arsa.attribute_code (+) = ari.attribute_code
AND  ari.attribute_code = aa.attribute_code
AND  ari.attribute_application_id = aa.attribute_application_id
UNION ALL
-- Select region_items that are not object attributes
SELECT null                                 column_name,
ari.display_sequence                 display_sequence,
ari.attribute_application_id         attribute_application_id,
ari.attribute_code                   attribute_code,
decode(aei.attribute_code,NULL,'F','T')  secured_column,
decode(arsa.attribute_code,NULL,'F','T') rls_column,
decode(ari.icx_custom_call,'INDEX','T','F') indexed_column,
arit.attribute_label_long            attribute_label_long,
ari.attribute_label_length           attribute_label_length,
aa.attribute_value_length		attribute_value_length,
ari.display_value_length             display_value_length,
ari.item_style                       item_style,
ari.bold                             bold,
ari.italic                           italic,
ari.vertical_alignment               vertical_alignment,
ari.horizontal_alignment             horizontal_alignment,
ari.object_attribute_flag            object_attribute_flag,
ari.node_query_flag                  node_query_flag,
ari.node_display_flag                node_display_flag,
ari.update_flag                      update_flag,
ari.required_flag                    required_flag,
ari.icx_custom_call                  icx_custom_call,
null                                 object_validation_api_pkg,
null                                 object_validation_api_proc,
null                                 object_defaulting_api_pkg,
null                                 object_defaulting_api_proc,
ari.region_validation_api_pkg        region_validation_api_pkg,
ari.region_validation_api_proc       region_validation_api_proc,
ari.region_defaulting_api_pkg        region_defaulting_api_pkg,
ari.region_defaulting_api_proc       region_defaulting_api_proc,
ari.lov_foreign_key_name             lov_foreign_key_name,
ari.lov_region_application_id        lov_region_application_id,
ari.lov_region_code                  lov_region_code,
ari.lov_attribute_application_id     lov_attribute_application_id,
ari.lov_attribute_code               lov_attribute_code,
ari.lov_default_flag                 lov_default_flag,
ari.order_sequence			order_sequence,
ari.order_direction			order_direction,
aa.data_type				data_type
FROM  ak_excluded_items aei,
ak_resp_security_attributes arsa,
ak_attributes aa,
ak_region_items_tl arit,
ak_region_items ari
WHERE ari.object_attribute_flag <> 'Y'
AND   ari.region_code = p_child_region_code
AND   ari.region_application_id = p_child_region_appl_id
AND   ari.node_display_flag =
decode(p_node_display_criteria,'Y','Y',ari.node_display_flag)
AND   arit.region_code = ari.region_code
AND   arit.region_application_id = ari.region_application_id
AND   arit.attribute_code = ari.attribute_code
AND   arit.attribute_application_id = ari.attribute_application_id
AND   arit.language = userenv('LANG')
AND   aei.responsibility_id (+) = p_responsibility_id
AND   aei.attribute_application_id (+) = ari.attribute_application_id
AND   aei.attribute_code (+) = ari.attribute_code
AND   arsa.responsibility_id (+) = p_responsibility_id
AND   arsa.attribute_application_id (+) = ari.attribute_application_id
AND   arsa.attribute_code (+) = ari.attribute_code
AND   ari.attribute_code = aa.attribute_code
AND   ari.attribute_application_id = aa.attribute_application_id
ORDER BY 2;


select_rec select_cur%rowtype;


CURSOR attr_values_cur
(
p_user_id                           NUMBER,
p_attribute_appl_id                 NUMBER,
p_attribute_code                    VARCHAR2,
p_responsibility_id                 NUMBER
)
IS
SELECT nvl(to_char(number_value),nvl(varchar2_value, to_char(date_value))) sec_value
FROM ak_web_user_sec_attr_values awusav
WHERE awusav.web_user_id = p_user_id
AND awusav.attribute_application_id = p_attribute_appl_id
AND awusav.attribute_code = p_attribute_code
union
SELECT nvl(to_char(number_value),
nvl(varchar2_value,to_char(date_value))) sec_value
FROM AK_RESP_SECURITY_ATTR_VALUES arsav
WHERE arsav.responsibility_id = p_responsibility_id
AND arsav.attribute_application_id = p_attribute_appl_id
AND arsav.attribute_code = p_attribute_code;

attr_values_rec attr_values_cur%rowtype;

l_query_stmt                  varchar2(32000);
select_count1                 number := 0;
select_count2                 number := 0;
select_count                  number := 0;
row_count                     number := 0;
select_stmt                   varchar2(20000);
where_stmt                    varchar2(20000);
order_by_stmt                 varchar2(1000);
order_by_col_tab              rel_name_tab;
order_by_dir_tab              rel_name_tab;
node_display_criteria         varchar2(1);
results_table_value_id        integer := 1;
where_temp                    varchar2(10000);
i                             integer;
svalue_datatype               varchar2(40) := NULL;

BEGIN
print_debug('** In function: getSecuredWhere');

l_query_stmt := 'SELECT ';

print_debug('retrieve item/attribute information');
--
-- When constructing the SQL statement, choose
-- between all columns or only those that are marked as
-- node_display_flag = 'Y'.
--
IF p_return_node_display_only THEN
node_display_criteria := 'Y';
ELSE
node_display_criteria := null;
END IF;

--
-- Construct the SQL statement by selecting
-- the region items
--
OPEN select_cur(p_region_rec.region_application_id,
p_region_rec.region_code,
p_responsibility_id,
node_display_criteria);

LOOP
FETCH select_cur INTO select_rec;
EXIT WHEN select_cur%NOTFOUND;
row_count := select_cur%ROWCOUNT;

print_debug('select column1 = '||select_rec.column_name);
print_debug('secure value1 = '||select_rec.rls_column);
print_debug('obj attr flag = '||select_rec.object_attribute_flag);

IF p_display_region THEN

print_debug ( 'Secured Value is -> ' || select_rec.rls_column);
--
-- Item has secured VALUES if it was found on the
-- ak_web_user_sec_attr_values table or ak_resp_security_attr_values table
-- If found, then the
-- record(s) will contain value(s) to use in the where clause
-- to limit row selection. If item was suppose to have secured
-- values, but none where found then create a where clause
-- containing '= NULL' which forces no rows to be found.
--
IF select_rec.rls_column = 'T'  THEN
where_temp := NULL;
svalue_datatype := NULL;

/** Verify if there is bad data **/

SELECT count(*)
INTO   select_count1
FROM ak_web_user_sec_attr_values awusav
WHERE awusav.web_user_id = p_user_id
AND awusav.attribute_application_id = select_rec.attribute_application_id
AND awusav.attribute_code = select_rec.attribute_code
AND (( varchar2_value is not null and date_value is not null) or
( varchar2_value is not null and number_value is not null) or
( date_value is not null and number_value is not null));

SELECT count(*)
INTO   select_count2
FROM ak_resp_security_attr_values arsav
WHERE arsav.responsibility_id = p_responsibility_id
AND arsav.attribute_application_id = select_rec.attribute_application_id
AND arsav.attribute_code = select_rec.attribute_code
AND (( varchar2_value is not null and date_value is not null) or
( varchar2_value is not null and number_value is not null) or
( date_value is not null and number_value is not null));

select_count := select_count1 + select_count2;
if select_count = 0 then
FOR attr_values_rec IN attr_values_cur(p_user_id,
select_rec.attribute_application_id,
select_rec.attribute_code,
p_responsibility_id) LOOP
IF where_temp IS NULL THEN
where_temp := '('||select_rec.column_name || ' IN (';
ELSE
where_temp := where_temp || ', ';
END IF;

IF attr_values_rec.sec_value IS NOT NULL THEN
where_temp := where_temp || '''' || attr_values_rec.sec_value || '''';
END IF;

END LOOP;

end if;

IF where_temp IS NOT NULL THEN
where_temp := where_temp || '))';
ELSE
where_temp := '(' || select_rec.column_name || ' = NULL)';
END IF;
where_secured := where_secured || ' AND ' || where_temp;
END IF;
END IF;
END LOOP;
CLOSE select_cur;
return where_secured;

end getSecuredWhere;

procedure print_debug(dMessage in varchar2) is
begin
if (AK_QUERY_PKG.PRINT_DEBUG_ON) then
null;
-- comment out dbms_output so that adchkdrv would not complain
-- uncomment the following line when debug
--dbms_output.put_line(dMessage);
end if;
end print_debug;

END AK_QUERY_PKG;

/
