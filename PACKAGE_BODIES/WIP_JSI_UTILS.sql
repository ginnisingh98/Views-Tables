--------------------------------------------------------
--  DDL for Package Body WIP_JSI_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_JSI_UTILS" as
/* $Header: wipjsiub.pls 115.16 2002/11/29 10:29:34 rmahidha ship $ */


procedure
begin_processing_request (
  p_interface_id in number,
  p_validation_level in number
)
is
begin

  validation_level := p_validation_level ;
  current_interface_id := p_interface_id;
  any_current_request := false ;
  any_nonwarning_errors := false ;

  savepoint wip_jsi_request_start ;

  open matching_request(p_interface_id) ;
  fetch matching_request into current_rowid ;
  if (not matching_request%found) then
    abort_request ;
  end if ;

  any_current_request := true ;

end begin_processing_request ;



procedure
end_processing_request
is

  n_errors binary_integer ;
  error_no binary_integer ;
  x_final_process_status number ;
  x_group_id number;
  x_header_id number;

begin

  if (not any_current_request) then
    close matching_request ;
    return ;
  end if ;

  if (any_nonwarning_errors) then
    rollback to savepoint wip_jsi_request_start ;
    x_final_process_status := WIP_CONSTANTS.ERROR ;

    select group_id,header_id
    into x_group_id, x_header_id
    from wip_job_schedule_interface
    where rowid = current_rowid;

    -- Change process_status of detail records to error.

    WIP_JDI_Utils.Change_Status_Error(x_group_id,x_header_id,null,null);

  else
    x_final_process_status := WIP_CONSTANTS.COMPLETED ;
  end if ;

  -- Use new utilities to load errors into interface errors table.

  WIP_INTERFACE_ERR_Utils.load_errors;

  update wip_job_schedule_interface
  set
    process_phase = current_process_phase,
    process_status = x_final_process_status,
    last_update_date = sysdate
  where current of matching_request ;

  close matching_request ;
  any_current_request := false ;

end end_processing_request ;



procedure
abort_request
is
begin

--  rollback to savepoint wip_jsi_request_start ;

  raise_application_error (
    -20239, -- WIP_JSI_EXCEPTION,
    'Job/Schedule Interface Request Processing Aborted'
  ) ;

end abort_request ;



procedure
record_error_text (
  p_text in varchar2,
  p_warning_only in boolean
)
is

  error_record WIP_INTERFACE_ERR_Utils.request_error ;
  error_type number ;

begin

  if (nvl(p_warning_only,false)) then
    error_type := 2 ;
  else
    error_type := 1 ;
    any_nonwarning_errors := true ;
  end if ;

 -- Use new error handler to add error into PL/SQL table.

  WIP_INTERFACE_ERR_Utils.add_error(current_interface_id,p_text, error_type);

end record_error_text ;



procedure
record_current_error(p_warning_only in boolean)
is
begin

  record_error_text(FND_Message.get, nvl(p_warning_only,false)) ;

end record_current_error ;



procedure
record_error(p_message_name in varchar2, p_warning_only in boolean)
is
begin

  FND_Message.set_name('WIP', p_message_name) ;
  record_current_error(nvl(p_warning_only,false)) ;

end record_error ;



procedure
record_invalid_column_error(p_column_name in varchar2)
is
begin

  FND_Message.set_name('WIP', 'WIP_ML_FIELD_INVALID') ;
  FND_Message.set_token('COLUMN', p_column_name, false ) ;
  record_current_error(p_warning_only => false) ;

end record_invalid_column_error ;



procedure
record_ignored_column_warning(p_column_name in varchar2)
is
begin

  FND_Message.set_name('WIP', 'WIP_ML_FIELD_IGNORED') ;
  FND_Message.set_token('COLUMN', p_column_name, false) ;
  record_current_error(p_warning_only => true) ;

end record_ignored_column_warning ;



function
request_matches_condition (p_where_clause in varchar2) return boolean
is

  x_statement varchar2(2000) :=
    'select 1 from wip_job_schedule_interface WJSI ' ||
    'where rowid = :x_row_id and ' ||
    replace(p_where_clause, '    ', ' ') ;

  x_cursor_id integer ;
  n_rows_fetched integer ;

begin

  x_cursor_id := dbms_sql.open_cursor ;
  dbms_sql.parse(x_cursor_id, x_statement, dbms_sql.native) ;
  dbms_sql.bind_variable_rowid(x_cursor_id, ':x_row_id', current_rowid) ;
  n_rows_fetched := dbms_sql.execute_and_fetch(x_cursor_id) ;
  dbms_sql.close_cursor(x_cursor_id) ;

  return (n_rows_fetched > 0) ;

exception when others then

  record_error_text(sql_error_prefix || x_statement) ;
  abort_request ;
  return false ; -- not reached

end request_matches_condition ;



function
sql_error_prefix
return varchar2
is
begin
  return 'WIP_JSI_Utils : ORA-' || -sqlcode || ' : ' ;
end sql_error_prefix ;



procedure
nonfatal_error_if(p_condition in varchar2, p_message in varchar2)
is
begin
  if (request_matches_condition(p_condition)) then
    record_error(p_message) ;
  end if ;
end nonfatal_error_if ;



procedure
fatal_error_if(p_condition in varchar2, p_message in varchar2)
is
begin
  if (request_matches_condition(p_condition)) then
    record_error(p_message) ;
    abort_request ;
  end if ;
end fatal_error_if ;



-- Sets p_column to the result of p_default_value_expression
-- if p_condition is true.
procedure
default_if_null (
  p_column in varchar2,
  p_condition in varchar2,
  p_default_value_expression in varchar2
)
is
  x_cursor_id integer ;
  x_dummy integer ;
  x_statement varchar2(2000);

begin

  x_statement :=
    'update wip_job_schedule_interface WJSI ' ||
    'set ' || p_column || ' = ' ||
      replace(p_default_value_expression, '    ', ' ') || ' ' ||
    'where rowid = :x_row_id and ' ||
    p_column || ' is null and ' ||
    replace(p_condition, '    ', ' ') ;


  x_cursor_id := dbms_sql.open_cursor ;
  dbms_sql.parse(x_cursor_id, x_statement, dbms_sql.native) ;
  dbms_sql.bind_variable_rowid(x_cursor_id, ':x_row_id', current_rowid) ;
  x_dummy := dbms_sql.execute(x_cursor_id) ;
  dbms_sql.close_cursor(x_cursor_id) ;

exception when others then
  record_error_text(sql_error_prefix || x_statement) ;
  abort_request ;

end default_if_null ;



procedure
warn_irrelevant_column (p_column in varchar2, p_load_type_list in varchar2)
is

  x_condition varchar2(2000) ;

begin

  x_condition := p_column || ' is not null' ;

  if (p_load_type_list is not null) then
    x_condition := x_condition || ' and load_type in ' || p_load_type_list ;
  end if ;

  if (request_matches_condition(x_condition)) then
    record_ignored_column_warning(p_column) ;
  end if ;

end warn_irrelevant_column ;



procedure
warn_redundant_column (
  p_column_being_used in varchar2,
  p_column_being_ignored in varchar2,
  p_exception_load_type_list in varchar2
)
is

  x_condition varchar2(2000) ;

begin

  x_condition :=
    p_column_being_used || ' is not null and ' ||
    p_column_being_ignored || ' is not null' ;

  if (p_exception_load_type_list is not null) then
    x_condition :=
      x_condition || ' and load_type not in ' ||
      p_exception_load_type_list ;
  end if ;

  if(request_matches_condition(x_condition)) then
    record_ignored_column_warning(p_column_being_ignored) ;
  end if ;

end warn_redundant_column ;



procedure
derive_id_from_code (
  p_id_column in varchar2,
  p_code_column in varchar2,
  p_derived_value_expression in varchar2,
  p_exception_load_type_list in varchar2,
  p_required in boolean default NULL
)
is

  x_condition varchar2(2000) ;

begin

  -- If both the code column and the ID column are filled in,
  -- we will ignore the code column.
  warn_redundant_column(p_id_column, p_code_column,
                        p_exception_load_type_list) ;

  -- If the ID column is blank but the code column is filled in,
  -- try to fill in the ID column using the derivation expression
  -- (which presumably involves the code column).
  x_condition := p_code_column || ' is not null' ;
  if (p_exception_load_type_list is not null) then
    x_condition := x_condition ||
      ' and load_type not in ' || p_exception_load_type_list ;
  end if ;
  default_if_null(p_id_column,
                  x_condition,
                  p_derived_value_expression) ;

  -- In the end, we require that the ID column not be null
  -- if the code column was not null.
  if(request_matches_condition (p_code_column || ' is not null and ' ||
                                p_id_column || ' is null') AND nvl(p_required,true))
  then
    record_invalid_column_error(p_code_column) ;
    abort_request ;
  end if ;

end derive_id_from_code ;

end WIP_JSI_Utils ;

/
