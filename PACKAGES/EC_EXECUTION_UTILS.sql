--------------------------------------------------------
--  DDL for Package EC_EXECUTION_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EC_EXECUTION_UTILS" AUTHID CURRENT_USER as
-- $Header: ECXUTILS.pls 115.0 99/08/05 21:24:40 porting ship   $

/**
Stack for List of Parameters for a stored procedure or function
**/
TYPE t_parameter is RECORD
(
procedure_name	varchar2(80),
parameter_name	varchar2(80),
data_type	pls_integer,
in_out		pls_integer,
value		varchar2(32000)
);

/**
PL/SQL table for parameter List
**/
TYPE t_procparameters is table of t_parameter index by BINARY_INTEGER;


/**
Stack for List of Procedures/Functions to be executed.
Overloaded procedures name is listed once but the parameter stack will have
entries for all overloaded procedures.
**/

TYPE t_procedures is RECORD
(
procedure_name		varchar2(80),
cursor_handle		pls_integer,
execution_clause	varchar2(32000),
stack_start_pos		pls_integer,
stack_end_pos		pls_integer
);

/**
PL/SQL table for list of procedures
**/
TYPE t_proclist is TABLE of t_procedures index by BINARY_INTEGER;

-- Generic mapping of a Stored Procedure / Function
TYPE t_procmapping is RECORD
(
transtage_id			pls_integer,
procedure_name			ece_tran_stage_data.custom_procedure_name%TYPE,
parameter_name			ece_procedure_mappings.parameter_name%TYPE,
action_type			pls_integer,
variable_level			pls_integer,
variable_name			ece_procedure_mappings.variable_name%TYPE
);

/**
Stack for Procedure and their mappings to the Data Stack variables.
**/
TYPE t_procedure_mappings is table of t_procmapping index by BINARY_INTEGER;

-- Executes a Given Stored Procedure / Function
procedure runproc
	(
	i_procedure_name	in		varchar2
	);

procedure assign_values
        (
        i_transtage_id          IN      	pls_integer,
        i_procedure_name        IN      	varchar2,
        i_action_type           IN      	pls_integer
        );

procedure load_mappings
	(
	i_transaction_type	in      	varchar2,
	i_map_id		in      	pls_integer
	);

end ec_execution_utils;

 

/
