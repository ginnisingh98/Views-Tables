--------------------------------------------------------
--  DDL for Package EC_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EC_UTILS" AUTHID CURRENT_USER as
-- $Header: ECUTILS.pls 120.2 2005/09/30 06:18:58 arsriniv ship $

program_exit		exception;
documents_under_process	exception;
pragma			exception_init(documents_under_process,-54);
i_ret_code      	pls_integer :=0;
i_errbuf        	varchar2(2000);

/**
 Column Rule table bug# 2500898
**/
Type column_rule_rec is Record
(
column_rule_id  ece_column_rules.column_rule_id%type,
rule_type       ece_column_rules.rule_type%type,
action_code     ece_column_rules.action_code%type,
level                           pls_integer
);

TYPE column_rule_tbl is table of column_rule_rec index by BINARY_INTEGER;

/**
Mapping Record Information.
**/
TYPE mapping_record_type is RECORD
(
interface_level                 pls_integer,
external_level                  pls_integer,
interface_column_id             pls_integer,
base_column_name                ece_interface_columns.base_column_name%TYPE,
interface_column_name           ece_interface_columns.interface_column_name%TYPE,
staging_column                  ece_interface_columns.staging_column%TYPE,
record_layout_code              ECE_INTERFACE_COLUMNS.record_layout_code%TYPE,
record_layout_qualifier         ECE_INTERFACE_COLUMNS.record_layout_qualifier%TYPE,
record_number                   pls_integer,
element_tag_name                ECE_INTERFACE_COLUMNS.element_tag_name%TYPE,
position                        pls_integer,
width                           pls_integer,
data_type                       ece_interface_columns.data_type%TYPE,
value                           varchar2(32000),
conversion_sequence             pls_integer,
xref_category_id                pls_integer,
xref_category_allowed           ece_interface_columns.xref_category_allowed%TYPE,
conversion_group_id             pls_integer,
xref_key1_source_column         ece_interface_columns.xref_key1_source_column%TYPE,
xref_key2_source_column         ece_interface_columns.xref_key2_source_column%TYPE,
xref_key3_source_column         ece_interface_columns.xref_key3_source_column%TYPE,
xref_key4_source_column         ece_interface_columns.xref_key4_source_column%TYPE,
xref_key5_source_column         ece_interface_columns.xref_key5_source_column%TYPE,
ext_val1                        VARCHAR2(500),
ext_val2                        VARCHAR2(500),
ext_val3                        VARCHAR2(500),
ext_val4                        VARCHAR2(500),
ext_val5                        VARCHAR2(500),
column_rule_flag                VARCHAR2(1),
staging_column_no               pls_integer           --bug 2500898
);

TYPE mapping_tbl is table of mapping_record_type index by BINARY_INTEGER;

/**
Record for Dynamic Stage Data
**/
TYPE stage_rec is RECORD
(
stage			pls_integer,
level			pls_integer,
seq_number		pls_integer,
action_type		pls_integer,
variable_level		pls_integer,
variable_name		ece_tran_stage_data.variable_name%TYPE,
variable_value		ece_tran_stage_data.variable_value%TYPE,
default_value		ece_tran_stage_data.default_value%TYPE,
previous_variable_level	pls_integer,
previous_variable_name	ece_tran_stage_data.previous_variable_name%TYPE,
next_variable_name	ece_tran_stage_data.next_variable_name%TYPE,
sequence_name		ece_tran_stage_data.sequence_name%TYPE,
custom_procedure_name	ece_tran_stage_data.custom_procedure_name%TYPE,
data_type		ece_tran_stage_data.data_type%TYPE,
function_name		ece_tran_stage_data.function_name%TYPE,
clause			ece_tran_stage_data.where_clause%TYPE,
transtage_id		pls_integer
);

TYPE stage_data is TABLE of stage_rec INDEX BY BINARY_INTEGER;


/**
Record for PL/SQL Stack
**/
TYPE stack_rec is RECORD
(
level			pls_integer,
variable_name		varchar2(80),
variable_value		varchar2(32000),
variable_position	pls_integer,
data_type		varchar2(30)
);

TYPE  	pl_stack is TABLE of stack_rec index by BINARY_INTEGER;


/**
Record for Interface levels
**/
TYPE interface_level_rec is RECORD
(
interface_level                 pls_integer,
base_table_name                	varchar2(400),
cursor_handle                   pls_integer,
sql_stmt                        varchar2(32000),
parent_level                    pls_integer,
key_column_name			ece_interface_tables.key_column_name%TYPE,
rows_processed			pls_integer,
file_start_pos			pls_integer,
file_end_pos			pls_integer
);

TYPE interface_level_tbl is table of interface_level_rec index by BINARY_INTEGER;


/**
Record for External Levels
**/
TYPE external_level_rec is RECORD
(
external_level                  pls_integer,
cursor_handle                   pls_integer,
sql_stmt                        varchar2(32000),
stage_id                        pls_integer,
document_id                     pls_integer,
document_number			ece_stage.document_number%TYPE,
line_number                     pls_integer,
parent_stage_id                 pls_integer,
status                          ece_stage.status%TYPE,
record_number			ece_external_levels.start_element%TYPE,
file_start_pos			pls_integer,
file_end_pos			pls_integer
);

TYPE external_level_tbl is TABLE of external_level_rec index by BINARY_INTEGER;

/**
Record for Interface/External Levels
**/
TYPE interface_external_level_rec is RECORD
(
interface_level                 pls_integer,
external_level                  pls_integer
);

TYPE interface_external_tbl is TABLE of interface_external_level_rec index by BINARY_INTEGER;

/**
Record for maintaing the location of variables on the Stack for each level
**/
TYPE stack_location is RECORD
(
start_pos	pls_integer,
end_pos		pls_integer
);

TYPE stack_pointer is TABLE of stack_location index by BINARY_INTEGER;

--Bug 2617428 Declared Global variables to store computed hash values
--	      on the positions for g_file_tbl.
-- Bug 2834366
TYPE hash_rec IS RECORD
(
  value         pls_integer,
  occr          pls_integer,
  start_pos     pls_integer
);
TYPE hash_tbl IS TABLE OF hash_rec INDEX BY BINARY_INTEGER;

TYPE pos_tbl IS TABLE OF number INDEX BY BINARY_INTEGER;

g_code_conv_pos_tbl_1    hash_tbl;
g_code_conv_pos_tbl_2    pos_tbl;
g_col_pos_tbl_1          hash_tbl;
g_col_pos_tbl_2          pos_tbl;
g_stack_pos_tbl          pos_tbl;        -- Bug 2708573

/**
-- Global instances of the Stack , PL/SQL data table , Stage Data , Interface
-- Levels , External and Interface/External levels.
**/

g_stack			pl_stack;
g_file_tbl		mapping_tbl;
g_int_levels		interface_level_tbl;
g_ext_levels		external_level_tbl;
g_int_ext_levels	interface_external_tbl;
g_stage_data		stage_data;
g_stack_pointer		stack_pointer;
g_file_pointer		stack_pointer;
g_column_rule_tbl       column_rule_tbl;        --bug 2500898

-- Global parameter for a Stored procedure
g_parameter_stack       ec_execution_utils.t_procparameters;
g_procedure_stack       ec_execution_utils.t_proclist;
g_procedure_mappings    ec_execution_utils.t_procedure_mappings;


/**
Global Document variables
**/
g_documents_skipped             pls_integer :=0;
g_insert_failed                 pls_integer :=0;
g_current_level                 pls_integer :=0;
g_transaction_type              varchar2(20) :=NULL;
g_document_id           	varchar2(20) :=NULL;
g_run_id           		pls_integer :=0;
g_direction			varchar2(1);
g_map_id			pls_integer :=0;

/** Bug 2422787
Global stage variables
**/
i_tmp_stage_data        stage_data;---- Used for Stage 10 data only.
i_tmp2_stage_data       stage_data;---- used for Stages other than 10.
i_stage_data            stage_data;---- Temporary place holder for all Stages .

procedure find_pos
	(
	i_level			IN	number,
	i_search_text		IN	varchar2,
	o_pos			OUT NOCOPY	NUMBER,
	i_required              IN      BOOLEAN DEFAULT TRUE
	) ;

procedure find_pos
        (
        i_from_level                    IN      number,
        i_to_level                      IN      number,
        i_search_text                   IN      varchar2,
        o_pos                           OUT NOCOPY     NUMBER,
        i_required                      IN      BOOLEAN DEFAULT TRUE
        );

function find_variable
	(
	i_variable_level	IN	number,
	i_variable_name		IN	VARCHAR2,
	i_stack_pos		OUT NOCOPY	NUMBER,
	i_plsql_pos		OUT NOCOPY	NUMBER
	) return boolean;

procedure get_nextval_seq
	(
	i_seq_name		in	varchar2,
	o_value			OUT NOCOPY	varchar2
	);

procedure get_function_value
	(
	i_function_name		IN	varchar2,
	o_value			OUT NOCOPY	varchar2
	);

procedure execute_string
	(
	cString			in	varchar2,
	o_value			OUT NOCOPY	varchar2
	);

procedure dump_stack;

procedure get_tran_stage_data
	(
	i_transaction_type	IN	varchar2,
	i_map_id		IN	number
	);

procedure sort_stage_data;

procedure execute_stage_data
        (
        i_stage         	IN      number,
        i_level         	IN      number
        );

procedure create_new_variable
        (
        i_variable_level        IN      NUMBER,
        i_variable_name         IN      VARCHAR2,
        i_variable_value        IN      varchar2,
	i_data_type		IN	varchar2 default NULL
        );

procedure assign_default_to_variables
	(
	i_variable_level	IN	number,
	i_variable_name		IN	varchar2,
	i_default_value		IN	varchar2
	);

procedure IF_XNULL_SETYDEFAULT
        (
        i_variable_level                        IN      number,
        i_variable_name                         IN      varchar2,
        i_previous_variable_level               IN      number,
        i_previous_variable_name                IN      varchar2,
        i_default_value                         IN      varchar2
        );

procedure assign_pre_defined_variables
	(
	i_variable_level		IN	number,
	i_variable_name			IN	varchar2,
	i_previous_variable_level	IN	number,
	i_previous_variable_name	IN	varchar2
	);

procedure assign_nextval_from_sequence
	(
	i_variable_level	IN	number,
	i_variable_name		IN	varchar2,
	i_sequence_name		IN	varchar2
	);

procedure assign_function_value
	(
	i_variable_level	IN	number,
	i_variable_name		IN	varchar2,
	i_function_name		IN	varchar2
	);

procedure increment_by_one
	(
	i_variable_level	IN	number,
	i_variable_name		IN	varchar2
	);

procedure if_null_pre_defined_variable
	(
	i_variable_level		IN	number,
	i_variable_name			IN	varchar2,
	i_previous_variable_level	IN	number,
	i_previous_variable_name	IN	varchar2
	);

/* Bug 1999536
Procedure to implement the new action code 150.
*/
procedure if_not_null_defined_variable
	(
	i_variable_level		IN	number,
	i_variable_name			IN	varchar2,
	i_previous_variable_level	IN	number,
	i_previous_variable_name	IN	varchar2
	);

procedure if_default_pre_defined_var
	(
	i_variable_level		IN	number,
	i_variable_name			IN	varchar2,
	i_previous_variable_level	IN	number,
	i_previous_variable_name	IN	varchar2,
	i_default_value			IN	varchar2
	);

procedure if_diff_pre_next_then_default
        (
        i_variable_level                        IN      number,
        i_variable_name                         IN      varchar2,
        i_previous_variable_level               IN      number,
        i_previous_variable_name                IN      varchar2,
        i_next_variable_name                    IN      varchar2,
        i_default_value                         IN      varchar2
        );

procedure if_null_equal_default_value
	(
	i_variable_level	IN	number,
	i_variable_name		IN	varchar2,
	i_default_value		IN	varchar2
	);

procedure if_null_skip_document
	(
	i_variable_level	IN	number,
	i_variable_name		IN	varchar2
	);

procedure create_mandatory_columns
	(
	i_variable_level		IN	number,
	i_previous_variable_level	IN	number,
	i_variable_name			IN	varchar2,
	i_default_value			IN	varchar2,
	i_data_type			IN	varchar2,
	i_function_name			IN	varchar2
	);

procedure append_clause
        (
	i_level			IN	number,
        i_where_clause          IN      varchar2
        );

procedure if_Notnull_append_clause
        (
	i_level				IN	number,
        i_variable_level                IN      number,
        i_variable_name                 IN      varchar2,
        i_where_clause                  IN      varchar2
        );

procedure bind_variables_for_view
        (
        i_variable_name                 IN      varchar2,
        i_previous_variable_level       IN      integer,
        i_previous_variable_name        IN      varchar2
        );

procedure execute_proc
        (
        i_transtage_id          IN      number,
        i_procedure_name        IN      varchar2
        );
procedure ifxnull_execute_proc
        (
        i_variable_level                        IN      number,
        i_variable_name                         IN      varchar2,
        i_transtage_id                          IN      number,
        i_procedure_name                        IN      varchar2
        );
procedure ifxnotnull_execute_proc
        (
        i_variable_level                        IN      number,
        i_variable_name                         IN      varchar2,
        i_transtage_id                          IN      number,
        i_procedure_name                        IN      varchar2
        );
procedure ifxconst_execute_proc
        (
        i_variable_level                        IN      number,
        i_variable_name                         IN      varchar2,
        i_default_value                         IN      varchar2,
        i_transtage_id                          IN      number,
        i_procedure_name                        IN      varchar2
        );

procedure ifxpre_execute_proc
        (
        i_variable_level                        IN      number,
        i_variable_name                         IN      varchar2,
        i_previous_variable_level               IN      number,
        i_previous_variable_name                IN      varchar2,
        i_transtage_id                          IN      number,
        i_procedure_name                        IN      varchar2
        );

procedure ext_find_position
	(
	i_level			IN	number,
	i_search_text		IN	varchar2,
	o_pos			OUT NOCOPY	NUMBER,
	i_required              IN      BOOLEAN DEFAULT TRUE
	) ;

procedure ext_get_key_value
        (
        i_position        IN      number,
        o_value           OUT NOCOPY     varchar2
        );

procedure ext_insert_value
        (
        i_position        IN      number,
        i_value           IN     varchar2
        );



end ec_utils;

 

/
