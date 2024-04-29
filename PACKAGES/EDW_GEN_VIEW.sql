--------------------------------------------------------
--  DDL for Package EDW_GEN_VIEW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_GEN_VIEW" AUTHID DEFINER AS
/*$Header: EDWVGENS.pls 120.1 2005/06/13 12:56:16 aguwalan noship $*/


cursor c_getAttributeMappings(p_obj_name in varchar2, p_instance in varchar2, p_level IN VARCHAR2) IS
	SELECT attribute_name, source_attribute, datatype FROM edw_attribute_mappings
	WHERE object_short_name = p_obj_name and upper(flex_flag) = 'N'
	AND instance_code = p_instance
	AND decode(level_name, null, '000', 'null','000',level_name) = nvl(p_level, '000')
	AND attribute_name NOT IN /* for multiple columns mapping to single target col*/
	(SELECT attribute_name FROM edw_attribute_mappings
	WHERE object_short_name = p_obj_name and upper(flex_flag) = 'N'
	AND instance_code = p_instance
	AND decode(level_name, null, '000', 'null', '000', level_name) = nvl(p_level, '000')
	GROUP BY attribute_name having count(attribute_name) > 1)
	ORDER BY attribute_name;

cursor c_getMultiAttributeList(p_obj_name in varchar2, p_instance in varchar2, p_level IN VARCHAR2) IS
	SELECT distinct attribute_name FROM edw_attribute_mappings
	WHERE object_short_name = p_obj_name and  upper(flex_flag) = 'N'
	AND instance_code = p_instance
	AND  decode(level_name, null, '000', 'null', '000', level_name) = nvl(p_level, '000')
	GROUP BY attribute_name having count(attribute_name) > 1
	ORDER BY attribute_name;


cursor c_getMultiAttributeMappings(p_obj_name in varchar2, p_instance in varchar2, p_level IN VARCHAR2,
	p_column IN VARCHAR2) IS
	SELECT source_attribute FROM edw_attribute_mappings
	WHERE object_short_name = p_obj_name and upper(flex_flag) = 'N'
	AND instance_code = p_instance
	AND decode(level_name, null, '000', 'null', '000', level_name)= nvl(p_level, '000')
	AND attribute_name = p_column;


cursor c_getFlexAttributeMappings(p_obj_name in varchar2, p_instance in varchar2, p_level IN VARCHAR2) IS
	SELECT distinct(attribute_name) attribute_name, source_view, id_flex_code, datatype, flex_field_type
	FROM edw_attribute_mappings a, edw_flex_attribute_mappings b
	WHERE a.object_short_name = p_obj_name
	AND decode(level_name, null, '000', 'null', '000', level_name) = nvl(p_level, '000')
	AND a.attr_mapping_pk = b.attr_mapping_fk
	AND a.instance_code = p_instance
	ORDER BY attribute_name;

cursor c_getFactFlexFKMaps(p_obj_name in varchar2, p_instance in varchar2) IS
        SELECT fk_physical_name
        from edw_fact_flex_fk_maps a, edw_flex_seg_mappings b
        where a.fact_short_name = p_obj_name
	and a.dimension_short_name = b.dimension_short_name
	and b.instance_code = p_instance
        and a.enabled_flag = 'Y';

cursor c_getMultipleMaps(p_obj_name in varchar2, p_instance in varchar2) IS
        SELECT fk_physical_name
        from edw_fact_flex_fk_maps a, edw_flex_seg_mappings b
        where a.fact_short_name = p_obj_name
	and a.dimension_short_name = b.dimension_short_name
	and b.instance_code = p_instance
        and a.enabled_flag = 'Y';

TYPE tab_att_maps IS TABLE of
     c_getAttributeMappings%ROWTYPE
     INDEX BY BINARY_INTEGER;

TYPE tab_multi_att_maps IS TABLE OF
     c_getMultiAttributeMappings%ROWTYPE
     INDEX BY BINARY_INTEGER;

TYPE tab_multi_att_list IS TABLE OF
     c_getMultiAttributeList%ROWTYPE
     INDEX BY BINARY_INTEGER;

TYPE tab_flex_att_maps IS TABLE of
     c_getFlexAttributeMappings%ROWTYPE
     INDEX BY BINARY_INTEGER;

TYPE tab_fact_flex_fk_maps IS TABLE of
     c_getFactFlexFKMaps%ROWTYPE
     INDEX BY BINARY_INTEGER;

g_source_db_link varchar2(40);
g_instance varchar2(120) := null;
g_indenting varchar2(30) := '';
g_spacing varchar2(10) := '	';
g_apps_schema varchar2(100):= EDW_OWB_COLLECTION_UTIL.get_apps_schema_name;
g_version VARCHAR2(10):='11i';
g_status_failed_all varchar2(30):= 'FAILED_ALL';
g_status_failed_pruned varchar2(30):='FAILED_PRUNED';
g_status_generated_all varchar2(30):='GENERATED_ALL';
g_status_generated_pruned varchar2(30):='GENERATED_PRUNED';
l_file  utl_file.file_type;
-- spool out the view_text into l_out_file
l_out_file  utl_file.file_type;
g_success boolean := true;
g_error   varchar2(2000):= null;
g_obj_name VARCHAR2(30);

viewgen_exception EXCEPTION;



g_where_clause dbms_sql.varchar2_table;

Procedure indentBegin;
Procedure indentEnd;

Function getColumnCountForView(view_name in varchar2) RETURN INTEGER;
Function getAppsSchema  RETURN VARCHAR2;
Function getAppsVersion RETURN VARCHAR2;
Function formSegmentName(p_prefix IN VARCHAR2,
			p_segment_name IN VARCHAR2,
			p_struct_num IN NUMBER,
			p_Id_Flex_Code VARCHAR2,
			p_flex_type VARCHAR2)  RETURN VARCHAR2;

Function getContextColForFlex(p_flex in varchar2, p_flex_type IN VARCHAR2) RETURN VARCHAR2;

PROCEDURE getColumnMaps(object_name IN VARCHAR2, attMaps OUT NOCOPY  tab_att_maps, multiAttList OUT NOCOPY tab_multi_att_list, flexMaps OUT NOCOPY tab_flex_att_maps, fkMaps OUT NOCOPY tab_fact_flex_fk_maps, p_level IN VARCHAR2 DEFAULT null);

Function getFlexPrefix( pViewName IN VARCHAR2, pIdFlexCode IN VARCHAR2) RETURN VARCHAR2;


FUNCTION getDecodeClauseForFlexCol( pSourceView IN VARCHAR2,
	pAttributeName IN VARCHAR2, pIdFlexCode IN VARCHAR2,
	pFlexType IN VARCHAR2) RETURN VARCHAR2;

FUNCTION getNvlClause(p_object IN VARCHAR2, p_level IN VARCHAR2, p_instance IN VARCHAR2,
p_column IN VARCHAR2) return VARCHAR2;


Procedure Generate(p_obj_name in varchar2,
                  p_obj_type in varchar2,
		  p_instance in varchar2,
                  p_db_link in varchar2,
		  p_log_dir in varchar2 default null);

Function getUtlFileDir return VARCHAR2 ;

Procedure writeLog(p_message IN VARCHAR2);
Procedure writeOut(p_message IN VARCHAR2);
Procedure writeOutLine(p_message IN VARCHAR2);
--Procedure GenerateDepVSView(p_dim_name in varchar2);
function getApplsysSchema return varchar2;
Procedure BuildViewStmt(p_view_text in varchar2, p_line_num in number);
PROCEDURE createView(src_view IN VARCHAR2, view_name IN VARCHAR2);
PROCEDURE createLongView(view_name IN VARCHAR2, p_first_line_num IN NUMBER, p_last_line_num IN NUMBER);
FUNCTION convertString(p_string IN VARCHAR2) RETURN VARCHAR2;

Function checkWhereClause(p_value_set_id in NUMBER, p_link in varchar2) return boolean ;
End EDW_GEN_VIEW;

 

/
