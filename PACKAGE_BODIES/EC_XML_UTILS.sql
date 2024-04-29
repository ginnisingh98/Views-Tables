--------------------------------------------------------
--  DDL for Package Body EC_XML_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EC_XML_UTILS" AS
-- $Header: ECXMLUTB.pls 115.3 99/08/23 15:40:22 porting ship $

	cursor get_transaction_type
		(
		p_map_id	IN	number
		)
	is
	select	transaction_type
	from	ece_mappings
	where 	map_id = p_map_id;

	cursor get_external_entities
		(
		p_transaction_type	IN	varchar2,
		p_map_id		IN	number
		)
	is
	select	start_element,
		external_level,
		external_level_id,
		parent_level
	from	ece_external_levels
	where	transaction_type = p_transaction_type
	and	map_id = p_map_id
	start with parent_level = 0
	connect by prior external_level_id = parent_level;

	cursor get_external_attributes
		(
		p_map_id		IN	number,
		p_external_level	in	number
		)
	is
	select	interface_column_name,
		staging_column,
		element_tag_name
	from	ece_interface_columns
	where	map_id = p_map_id
	and	external_level = p_external_level
	and	staging_column is not null
	and	element_tag_name is not null
	order by interface_column_id;

	cursor get_root
	(
	p_transaction_type	IN	varchar2,
	p_map_id		IN	number
	)
	is
	select	root_element
	from	ece_mappings
	where	transaction_type = p_transaction_type
	and	map_id = p_map_id;

procedure create_vo_tree
	(
	i_map_id		IN	number,
	i_run_id		IN	number
	)
is
i_transaction_type		ece_mappings.transaction_type%TYPE;
i_string			varchar2(32000);
i_plural_name			varchar2(2000);
i_singular_name			varchar2(2000);
i_where_clause			varchar2(2000);
i_entity_object			varchar2(2000);
i_select_clause			varchar2(32000);
i_orderby_clause		varchar2(2000);
i_from_clause			varchar2(2000);
i_attributes_to_hide		varchar2(2000);
i_product_code			varchar2(2000);
i_apps_error_code		varchar2(2000);
i_parameter0			varchar2(2000);
i_parameter1			varchar2(2000);
i_parameter2			varchar2(2000);
i_parameter3			varchar2(2000);
i_parameter4			varchar2(2000);
i_error_string			varchar2(32000);
i_parent_data_object		varchar2(2000);
i_bind_parent_attributealiases	varchar2(2000);
i_bind_child_attributealiases	varchar2(2000);
i_bind_child_attributecolumns	varchar2(2000);
i_parent_level			pls_integer;
i_prv_parent_level		pls_integer :=0;
i_prv_parent_data_object	varchar2(2000);
begin
ec_debug.push('EC_XMLS.CREATE_VO_TREE');
ec_debug.pl(3,'i_map_id',i_map_id);
ec_debug.pl(3,'i_run_id',i_run_id);

for ctran in get_transaction_type
	(
	p_map_id => i_map_id
	)
loop
	i_transaction_type := ctran.transaction_type;
	ec_debug.pl(3,'Transaction Type ',ctran.transaction_type);
end loop;

for c1 in get_root
	(
	p_transaction_type => i_transaction_type,
	p_map_id => i_map_id
	)
loop
	ec_debug.pl(3,'Root Element',c1.root_element);
end loop;



for c2 in get_external_entities
	(
	p_transaction_type => i_transaction_type,
	p_map_id => i_map_id
	)
loop
	i_string := 'select ';
	i_singular_name := c2.start_element;
	i_plural_name := c2.start_element||'S';
	i_from_clause := 'ECE_STAGE';
	i_orderby_clause := 'order by stage_id';


	if c2.external_level = 1
	then
		i_bind_child_attributecolumns := null;
		i_where_clause := 'run_id = '||i_run_id;
	else
		i_bind_child_attributecolumns := 'parent_stage_id';
		i_bind_parent_attributealiases := 'stage_id';
		i_where_clause := null;
	end if;

	if i_prv_parent_level = i_parent_level
	then
		i_parent_data_object := i_prv_parent_data_object;
	else
		i_parent_data_object := i_plural_name;
	end if;

	ec_debug.pl(3,'External_level'||c2.external_level,c2.start_element);
	ec_debug.pl(3,'External_level_id',c2.external_level_id);
	for c3 in get_external_attributes
		(
		p_map_id => i_map_id,
		p_external_level => c2.external_level
		)
	loop
		i_string := i_string||c3.staging_column;
		if c3.element_tag_name is not null
		then
			i_string := i_string||' AS '||c3.element_tag_name;
		end if;
		i_string := i_string ||',';
	end loop;
	i_select_clause := substrb(i_string,1,length(i_string)-1);

	if  c2.external_level = 1
	then
		create_toplevel_vo
			(
			i_singular_name,
			i_plural_name,
			i_entity_object,
			i_select_clause,
			i_from_clause,
			i_where_clause,
			i_orderby_clause,
			i_attributes_to_hide,
			i_product_code,
			i_apps_error_code,
			i_parameter0,
			i_parameter1,
			i_parameter2,
			i_parameter3,
			i_parameter4,
			i_error_string
			);

	else
		create_child_vo
			(
			i_singular_name,
			i_plural_name,
			i_entity_object,
			i_select_clause,
			i_from_clause,
			i_where_clause,
			i_orderby_clause,
			i_attributes_to_hide,
			i_parent_data_object,
			i_bind_parent_attributealiases,
			i_bind_child_attributealiases,
			i_bind_child_attributecolumns,
			i_product_code,
			i_apps_error_code,
			i_parameter0,
			i_parameter1,
			i_parameter2,
			i_parameter3,
			i_parameter4,
			i_error_string
			);
	end if;

	i_prv_parent_level := c2.parent_level;
	i_prv_parent_data_object := i_plural_name;

end loop;
ec_debug.pop('EC_XMLS.CREATE_VO_TREE');
EXCEPTION
WHEN EC_UTILS.PROGRAM_EXIT then
        raise;
WHEN OTHERS THEN
        ec_debug.pl
		(
		0,i_product_code,i_apps_error_code,'PARAMETER0',i_parameter0,
                'PARAMETER1',i_parameter1,
                'PARAMETER2',i_parameter2,
                'PARAMETER3',i_parameter3,
                'PARAMETER4',i_parameter4
               	);
        ec_debug.pl(0,'EC','EC_JAVA_ERROR',i_error_string);
        ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_XMLS.CREATE_VO_TREE');
        ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
        ec_utils.i_ret_code :=2;
        raise EC_UTILS.PROGRAM_EXIT;
end create_vo_tree;

/**
Stubs for Java API's
**/

procedure create_toplevel_vo
	(
	i_singular_name		IN	varchar2,
	i_plural_name		IN	varchar2,
	i_entity_object		IN	varchar2,
	i_select_clause		IN	varchar2,
	i_from_clause		IN	varchar2,
	i_where_clause		IN	varchar2,
	i_orderby_clause	IN	varchar2,
	i_attributes_to_hide	IN	varchar2,
	i_product_code		OUT	varchar2,
	i_apps_error_code	OUT	varchar2,
	i_parameter0		OUT	varchar2,
	i_parameter1		OUT	varchar2,
	i_parameter2		OUT	varchar2,
	i_parameter3		OUT	varchar2,
	i_parameter4		OUT	varchar2,
	i_error_string		OUT	varchar2
	)
is
begin
	null;
end;

procedure create_child_vo
	(
	i_singular_name			IN	varchar2,
	i_plural_name			IN	varchar2,
	i_entity_object			IN	varchar2,
	i_select_clause			IN	varchar2,
	i_from_clause			IN	varchar2,
	i_where_clause			IN	varchar2,
	i_orderby_clause		IN	varchar2,
	i_attributes_to_hide		IN	varchar2,
	i_parent_data_object		IN	varchar2,
	i_bind_parent_attributealiases	IN	varchar2,
	i_bind_child_attributealiases	IN	varchar2,
	i_bind_child_attributecolumns	IN	varchar2,
	i_product_code			OUT	varchar2,
	i_apps_error_code		OUT	varchar2,
	i_parameter0			OUT	varchar2,
	i_parameter1			OUT	varchar2,
	i_parameter2			OUT	varchar2,
	i_parameter3			OUT	varchar2,
	i_parameter4			OUT	varchar2,
	i_error_string			OUT	varchar2
	)
is
begin
	null;
end;

procedure produce_xml
	(
	i_file_name		IN	varchar2,
	i_product_code		OUT	varchar2,
	i_apps_error_code	OUT	varchar2,
	i_parameter0		OUT	varchar2,
	i_parameter1		OUT	varchar2,
	i_parameter2		OUT	varchar2,
	i_parameter3		OUT	varchar2,
	i_parameter4		OUT	varchar2,
	i_error_string		OUT	varchar2
	)
is
begin
	null;
end;

procedure consume_xml
	(
	i_file_name		IN	varchar2,
	i_apps_error_code	OUT	varchar2,
	i_parameter0		OUT	varchar2,
	i_parameter1		OUT	varchar2,
	i_parameter2		OUT	varchar2,
	i_parameter3		OUT	varchar2,
	i_parameter4		OUT	varchar2,
	i_error_string		OUT	varchar2,
	i_viewolistner_class	IN	varchar2
	)
as
begin
	null;
end;

PROCEDURE ec_xml_processor_out_generic
	(
      	c_map_id 	IN 	PLS_INTEGER,
      	c_run_id 	IN 	PLS_INTEGER,
      	c_output_path 	IN 	VARCHAR2,
      	c_file_name 	IN 	VARCHAR2
	)
IS
i_product_code          varchar2(2000);
i_apps_error_code       varchar2(2000);
i_parameter0            varchar2(2000);
i_parameter1            varchar2(2000);
i_parameter2            varchar2(2000);
i_parameter3            varchar2(2000);
i_parameter4            varchar2(2000);
i_error_string          varchar2(32000);
BEGIN
ec_debug.push('EC_XML_UTILS.EC_XML_PROCESSOR_OUT_GENERIC');
ec_debug.pl(3,'c_map_id',c_map_id);
ec_debug.pl(3,'c_run_id',c_run_id);
ec_debug.pl(3,'c_output_path',c_output_path);
ec_debug.pl(3,'c_file_name',c_file_name);

		create_vo_tree
			(
			c_map_id,
			c_run_id
			);

		produce_xml
			(
			c_output_path||'/'||c_file_name,
			i_product_code,
			i_apps_error_code,
			i_parameter0,
			i_parameter1,
			i_parameter2,
			i_parameter3,
			i_parameter4,
			i_error_string
			);

ec_debug.pop('EC_XML_UTILS.EC_XML_PROCESSOR_OUT_GENERIC');
EXCEPTION
WHEN EC_UTILS.PROGRAM_EXIT then
        raise;
WHEN OTHERS THEN
        ec_debug.pl
		(
		0,i_product_code,i_apps_error_code,'PARAMETER0',i_parameter0,
                'PARAMETER1',i_parameter1,
                'PARAMETER2',i_parameter2,
                'PARAMETER3',i_parameter3,
                'PARAMETER4',i_parameter4
                );
        ec_debug.pl(0,'EC','EC_JAVA_ERROR',i_error_string);
        ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_XML_UTILS.XML_PROCESSOR_OUT_GENERIC');
        ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
        ec_utils.i_ret_code :=2;
      	raise EC_UTILS.PROGRAM_EXIT;

END ec_xml_processor_out_generic;

PROCEDURE ec_xml_processor_in_generic
	(
      	c_map_id 	IN 	PLS_INTEGER,
      	c_run_id 	OUT 	PLS_INTEGER,
      	c_output_path 	IN 	VARCHAR2,
      	c_file_name 	IN 	VARCHAR2
	)
IS
i_product_code          varchar2(2000);
i_apps_error_code       varchar2(2000);
i_parameter0            varchar2(2000);
i_parameter1            varchar2(2000);
i_parameter2            varchar2(2000);
i_parameter3            varchar2(2000);
i_parameter4            varchar2(2000);
i_error_string          varchar2(32000);
i_viewolistner_class	varchar2(2000);
BEGIN
ec_debug.push('EC_XML_UTILS.EC_XML_PROCESSOR_IN_GENERIC');
ec_debug.pl(3,'c_map_id',c_map_id);
ec_debug.pl(3,'c_output_path',c_output_path);
ec_debug.pl(3,'c_file_name',c_file_name);
/**
If the program is run from SQLplus , the Concurrent Request id is
< 0. In this case , get the run id from ECE_OUTPUT_RUNS_S.NEXTVAL.
**/
        c_run_id := fnd_global.conc_request_id;
        if c_run_id <= 0
        then
                select  ece_output_runs_s.NEXTVAL
                into    c_run_id
                from    dual;
        end if;

        ec_debug.pl(3,'Run Id for the Transaction',c_run_id);

	create_vo_tree
		(
		c_map_id,
		c_run_id
		);

	consume_xml
		(
		c_output_path||'/'||c_file_name,
		i_apps_error_code,
		i_parameter0,
		i_parameter1,
		i_parameter2,
		i_parameter3,
		i_parameter4,
		i_error_string,
		i_viewolistner_class
		);

ec_debug.pl(3,'c_run_id',c_run_id);
ec_debug.pop('EC_XML_UTILS.EC_XML_PROCESSOR_IN_GENERIC');
EXCEPTION
WHEN EC_UTILS.PROGRAM_EXIT then
        raise;
WHEN OTHERS THEN
        ec_debug.pl
		(
		0,i_product_code,i_apps_error_code,'PARAMETER0',i_parameter0,
                'PARAMETER1',i_parameter1,
                'PARAMETER2',i_parameter2,
                'PARAMETER3',i_parameter3,
                'PARAMETER4',i_parameter4
                );
        ec_debug.pl(0,'EC','EC_JAVA_ERROR',i_error_string);
        ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_XML_UTILS.EC_XML_PROCESSOR_IN_GENERIC');
        ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
        ec_utils.i_ret_code :=2;
      	raise EC_UTILS.PROGRAM_EXIT;
END ec_xml_processor_in_generic;

END EC_XML_UTILS;


/
