--------------------------------------------------------
--  DDL for Package ECX_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ECX_UTILS" AUTHID CURRENT_USER as
-- $Header: ECXUTILS.pls 120.5.12010000.2 2008/08/22 20:03:35 cpeixoto ship $

program_exit		exception;
no_seed_data		exception;
documents_under_process	exception;
pragma			exception_init(documents_under_process,-54);
error_type              pls_integer ;
i_ret_code      	pls_integer :=0;
i_errbuf        	varchar2(2000);
i_errparams             varchar2(2000);
i_curr_errid            number :=0;
g_direction             varchar2(3);
g_source_object_id pls_integer := null;
g_target_object_id pls_integer := null;
g_ret_code      	pls_integer :=0;

g_delete_doctype boolean := false;

/** Custom message product code placeholder **/
g_cust_msg_code varchar2(20) := null;
G_XML_FRAG_PROC varchar2(50) := 'ECX_ACTIONS.GET_XML_FRAGMENT';
/**
Record for Dynamic Stage Data
**/
TYPE stage_rec is RECORD
(
stage				pls_integer,
level				pls_integer,
object_direction		varchar2(1),
objectlevel_id			pls_integer,
seq_number			pls_integer,
action_type			pls_integer,
variable_level			pls_integer,
variable_pos            	pls_integer,
variable_direction		varchar2(10),
variable_name			ecx_tran_stage_data.variable_name%TYPE,
variable_value			ecx_tran_stage_data.variable_value%TYPE,
default_value			ecx_tran_stage_data.default_value%TYPE,
sequence_name			ecx_tran_stage_data.sequence_name%TYPE,
custom_procedure_name		ecx_tran_stage_data.custom_procedure_name%TYPE,
data_type	        	pls_integer,
function_name			ecx_tran_stage_data.function_name%TYPE,
clause				ecx_tran_stage_data.where_clause%TYPE,
transtage_id			pls_integer,
cond_logical_operator		ecx_tran_stage_data.cond_logical_operator%TYPE,
cond_operator1			ecx_tran_stage_data.cond_operator1%TYPE,
cond_var1_level			pls_integer,
cond_var1_pos			pls_integer,
cond_var1_name			ecx_tran_stage_data.cond_var1_name%TYPE,
cond_var1_direction		ecx_tran_stage_data.cond_var1_direction%TYPE,
cond_var1_constant		ecx_tran_stage_data.cond_var1_constant%TYPE,
cond_val1_level			pls_integer,
cond_val1_pos			pls_integer,
cond_val1_name			ecx_tran_stage_data.cond_val1_name%TYPE,
cond_val1_direction		ecx_tran_stage_data.cond_val1_direction%TYPE,
cond_val1_constant		ecx_tran_stage_data.cond_val1_constant%TYPE,
cond_operator2			ecx_tran_stage_data.cond_operator2%TYPE,
cond_var2_level			pls_integer,
cond_var2_pos			pls_integer,
cond_var2_name			ecx_tran_stage_data.cond_var2_name%TYPE,
cond_var2_direction		ecx_tran_stage_data.cond_var2_direction%TYPE,
cond_var2_constant		ecx_tran_stage_data.cond_var2_constant%TYPE,
cond_val2_level			pls_integer,
cond_val2_pos			pls_integer,
cond_val2_name			ecx_tran_stage_data.cond_val2_name%TYPE,
cond_val2_direction		ecx_tran_stage_data.cond_val2_direction%TYPE,
cond_val2_constant		ecx_tran_stage_data.cond_val2_constant%TYPE,
operand1_level			pls_integer,
operand1_name			ecx_tran_stage_data.operand1_name%TYPE,
operand1_pos			pls_integer,
operand1_direction		ecx_tran_stage_data.operand1_direction%TYPE,
operand1_constant		ecx_tran_stage_data.operand1_constant%TYPE,
operand1_len			ecx_tran_stage_data.operand1_len%TYPE,
operand1_start_pos		ecx_tran_stage_data.operand1_start_pos%TYPE,
operand2_level			pls_integer,
operand2_name			ecx_tran_stage_data.operand2_name%TYPE,
operand2_pos			pls_integer,
operand2_direction		ecx_tran_stage_data.operand2_direction%TYPE,
operand2_constant		ecx_tran_stage_data.operand2_constant%TYPE,
operand3_level			pls_integer,
operand3_name			ecx_tran_stage_data.operand3_name%TYPE,
operand3_pos			pls_integer,
operand3_direction		ecx_tran_stage_data.operand3_direction%TYPE,
operand3_constant		ecx_tran_stage_data.operand3_constant%TYPE,
operand4_level			pls_integer,
operand4_name			ecx_tran_stage_data.operand4_name%TYPE,
operand4_pos			pls_integer,
operand4_direction		ecx_tran_stage_data.operand4_direction%TYPE,
operand4_constant		ecx_tran_stage_data.operand4_constant%TYPE,
operand5_level			pls_integer,
operand5_name			ecx_tran_stage_data.operand5_name%TYPE,
operand5_pos			pls_integer,
operand5_direction		ecx_tran_stage_data.operand5_direction%TYPE,
operand5_constant		ecx_tran_stage_data.operand5_constant%TYPE,
operand6_level			pls_integer,
operand6_name			ecx_tran_stage_data.operand6_name%TYPE,
operand6_pos			pls_integer,
operand6_direction		ecx_tran_stage_data.operand6_direction%TYPE,
operand6_constant		ecx_tran_stage_data.operand6_constant%TYPE
);

TYPE stage_data is TABLE of stage_rec INDEX BY BINARY_INTEGER;

/**
Record for PL/SQL Stack
**/
TYPE stack_rec is RECORD
(
variable_name		varchar2(256),
variable_value		varchar2(32767),
data_type	        pls_integer
);

TYPE  	pl_stack is TABLE of stack_rec index by BINARY_INTEGER;


-- Table to hold XMLNode references indexed by ids
TYPE node_data is TABLE of xmlDOM.DOMNode INDEX BY BINARY_INTEGER;


/**
Record for Interface levels
**/
TYPE level_rec is RECORD
(
level                 		pls_integer,
cursor_handle                   pls_integer,
sql_stmt                        varchar2(32000),
parent_level                    pls_integer,
base_table_name                	varchar2(400),
rows_processed			pls_integer,
stage_id                        pls_integer,
document_id                     pls_integer,
document_number                 Varchar2(500),
dtd_node_index                  pls_integer,
parent_stage_id                 pls_integer,
status                          Varchar2(20),
start_element			ecx_object_levels.object_level_name%TYPE,
file_start_pos			pls_integer,
file_end_pos			pls_integer,
first_source_level		pls_integer,
last_source_level		pls_integer,
first_target_level		pls_integer,
last_target_level		pls_integer
);

TYPE level_tbl is table of level_rec index by BINARY_INTEGER;

/**
Record for Interface/External Levels
**/
TYPE source_target_level_rec is RECORD
(
source_level                 pls_integer,
target_level                 pls_integer
);

TYPE source_target_level_tbl is TABLE of source_target_level_rec index by BINARY_INTEGER;


/**
Used by both External and Internal Objects
**/
TYPE dtd_node_rec is RECORD
(
dtd_node_map_id                 pls_integer,
attribute_id                    pls_integer,
attribute_name                  ecx_object_attributes.attribute_name%TYPE,
object_column_flag		ecx_object_attributes.object_column_flag%TYPE,
base_column_name                ecx_object_attributes.attribute_name%TYPE,
map_attribute_id             	pls_integer,
parent_attribute_id             pls_integer,
attribute_type                  pls_integer,
default_value                   ecx_object_attributes.default_value%TYPE,
data_type                       pls_integer,
occurrence                      pls_integer,
cond_value                      ecx_object_attributes.cond_value%TYPE,
cond_node                       ecx_object_attributes.cond_node%TYPE,
cond_node_type                  ecx_object_attributes.cond_node_type%TYPE,
external_level                  pls_integer,
internal_level                  pls_integer,
has_attributes                  pls_integer,
leaf_node                       pls_integer,
required_flag			ecx_object_attributes.required_flag%TYPE,
xref_category_id                pls_integer,
value                           varchar2(32767),

parent_node_map_id              pls_integer,
xref_retcode                    Varchar2(1),
clob_value                      clob,
clob_length                     pls_integer,
is_clob                         varchar2(1)
);

/**
Record for dtd nodes
**/
TYPE dtd_node_tbl is TABLE of dtd_node_rec index by BINARY_INTEGER;


/**
-- Global instances of the Stack , PL/SQL data table , Stage Data , Interface
-- Levels , External and Interface/External levels.
**/

g_stack                 pl_stack;
g_source_levels		level_tbl;
g_target_levels		level_tbl;
g_target_source_levels	source_target_level_tbl;
g_stage_data		stage_data;
g_dtd_nodes             dtd_node_tbl;
g_source		dtd_node_tbl;
g_empty_source        	dtd_node_tbl;
g_target		dtd_node_tbl;
g_empty_target        	dtd_node_tbl;
g_node_tbl		node_data;

-- Stack for List of Procedures to be executed.
TYPE t_procedures is RECORD
(
procedure_name          Varchar2(80),
cursor_handle           pls_integer,
procedure_call          Varchar2(32000)
);

TYPE t_proclist is TABLE of t_procedures index by BINARY_INTEGER;


-- Generic mapping of a Stored Procedure / Function
TYPE t_procmapping is RECORD
(
transtage_id                    pls_integer,
procedure_name                  ecx_tran_stage_data.custom_procedure_name%TYPE,
parameter_name                  ecx_proc_mappings.parameter_name%TYPE,
action_type                     pls_integer,
variable_level                  pls_integer,
variable_name                   ecx_proc_mappings.variable_name%TYPE,
variable_pos                    pls_integer,
variable_direction		varchar2(10),
variable_constant		varchar2(4000),
data_type                       pls_integer
);

/**
Stack for Procedure and their mappings to the Data Stack variables.
**/
TYPE t_procedure_mappings is table of t_procmapping index by BINARY_INTEGER;

-- Global parameter for a Stored procedure
g_procedure_list        t_proclist;
g_procedure_mappings    t_procedure_mappings;


/**
Global Document variables
**/

g_routing_id			pls_integer := 0;
g_total_records                 pls_integer := 0;
g_insert_failed                 pls_integer := 0;
g_previous_level                pls_integer := 0;
g_current_level                 pls_integer := 0;
g_document_id           	varchar2(2000):= NULL;
g_transaction_type           	varchar2(2000):= NULL;
g_transaction_subtype          	varchar2(2000):= NULL;
g_run_id           		pls_integer := 0;
g_map_id			pls_integer := 0;
g_rec_tp_id                     pls_integer := null;
g_snd_tp_id                     pls_integer := null;
g_parser                        xmlparser.parser;
g_inb_parser			xmlparser.parser;
dom_printing			Boolean := FALSE;
structure_printing		Boolean := FALSE;
g_xmldoc                        xmlDOM.DOMNode;
g_logfile			varchar2(200);
g_msgid				raw(16);
g_standard_id			pls_integer;
g_org_id			pls_integer;
g_company_name			varchar2(2000) :=NULL;
g_logdir			varchar2(2000);
g_install_mode			varchar2(200);
g_event				wf_event_t;
g_item_type			varchar2(8);
g_item_key			varchar2(240);
g_activity_id			number;
g_tp_dtl_id			pls_integer;

/**
Global Constants
**/
G_VARCHAR_LEN			pls_integer := 32767;

/*
 IMP NOTE: The limit of 16383 needs to be changed to 32767 once
 we get a fix for bug# 2830478
*/
G_CLOB_VARCHAR_LEN		pls_integer := 16383;

TYPE xml_frag_rec is RECORD
(
  variable_pos pls_integer,
  value  varchar2(32767)
);

TYPE xml_frag_tbl is TABLE of xml_frag_rec index by BINARY_INTEGER;

g_xml_frag xml_frag_tbl;
procedure close_process;

procedure initialize
        (
        i_map_id             IN                    pls_integer,
        x_same_map           OUT            NOCOPY Boolean
        );

procedure load_dtd_nodes
        (
        i_map_id             IN     pls_integer,
	i_level_id		IN	pls_integer,
	i_object_level	IN	pls_integer,
	i_source	IN	boolean
        );

procedure load_procedure_mappings
	(
   	i_map_id        IN     pls_integer
	);

procedure load_procedure_definitions
	(
   	i_map_id        IN    pls_integer
	);

procedure build_procedure_call
	(
   	p_transtage_id     IN     pls_integer,
      	p_procedure_name   IN     Varchar2,
	x_proc_cursor      OUT    NOCOPY pls_integer
	);

procedure get_tran_stage_data
	(
   	i_map_id               IN     pls_integer
	);

procedure load_mappings
	(
	i_map_id               in     pls_integer
	);

procedure load_objects
	(
	i_map_id        in      pls_integer
	);

procedure getLogDirectory;

Function GetFileSeparator
	return varchar2;

Function GetLineSeparator
	return varchar2;

Procedure set_error(
   p_error_type in pls_integer default 10,
   p_error_code in pls_integer default 0,
   p_error_msg  in varchar2 default null,
   p_token1     in varchar2 default null,
   p_value1     in varchar2 default null,
   p_token2     in varchar2 default null,
   p_value2     in varchar2 default null,
   p_token3     in varchar2 default null,
   p_value3     in varchar2 default null,
   p_token4     in varchar2 default null,
   p_value4     in varchar2 default null,
   p_token5     in varchar2 default null,
   p_value5     in varchar2 default null,
   p_token6     in varchar2 default null,
   p_value6     in varchar2 default null,
   p_token7     in varchar2 default null,
   p_value7     in varchar2 default null,
   p_token8     in varchar2 default null,
   p_value8     in varchar2 default null,
   p_token9     in varchar2 default null,
   p_value9     in varchar2 default null,
   p_token10    in varchar2 default null,
   p_value10    in varchar2 default null);


procedure convertPartyTypeToCode(
   p_party_type    IN   Varchar2,
   x_party_type    OUT  NOCOPY Varchar2);

 function getNodePath(
	v_map_id IN NUMBER,
	v_attribute_id IN NUMBER) return varchar2;


Function XMLversion
	return varchar2;

end ecx_utils;

/
