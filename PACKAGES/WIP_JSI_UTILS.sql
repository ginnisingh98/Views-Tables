--------------------------------------------------------
--  DDL for Package WIP_JSI_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_JSI_UTILS" AUTHID CURRENT_USER as
/* $Header: wipjsius.pls 115.8 2002/11/29 10:29:21 rmahidha ship $ */

  --
  -- Constants
  --

  WIP_JSI_EXCEPTION constant number := -20239 ;

  REQUEST_ABORTED exception ;
  pragma exception_init(REQUEST_ABORTED, -20239) ;

  --
  -- Public Package Globals
  --

  -- What kind of processing is being done on the current record.
  -- You should set this variable as appropriate.
  current_process_phase number ;

  -- Rowid of the locked row being processed.
  -- You should not set this variable.
  current_rowid rowid ;

  -- How the current row is to be processed.
  -- You should not set this variable.
  validation_level number ;

  -- Whether any error messages other than warnings have been encountered
  -- for the current record.
  -- You should not set this variable.
  any_nonwarning_errors boolean ;

  -- Interface_id of the locked row being processed.
  -- You should not set this variable.
  current_interface_id number;

  --
  -- Procedures and Functions
  --


  --
  -- Prepares to process the request identified by p_interface_id.
  -- Aborts if this request does not exist or is not currently set up
  -- to be processed.
  --
  -- Think of this as the "constructor" of a request-processing session.
  -- You must call this procedure before calling
  -- 'end_processing_request' or 'abort_request'.
  --
  procedure
  begin_processing_request (
    p_interface_id in number,
    p_validation_level in number
  ) ;

  --
  -- Cleans up after processing a single request. If any errors have been
  -- recorded, this procedure rolls back to the point when
  -- 'begin_processing_request' was called. Stores any errors
  -- in WIP_INTERFACE_ERRORS and updates WIP_JOB_SCHEDULE_INTERFACE to have
  -- an error status if appropriate.
  --
  -- This is the "destructor" of a request-processing session.
  -- You must call this procedure after all processing is complete.
  --
  procedure
  end_processing_request ;

  --
  -- Throws the REQUEST_ABORTED exception.
  --
  procedure
  abort_request ;

  --
  -- Saves the given error message for later insertion into
  -- WIP_INTERFACE_ERRORS.
  --
  procedure
  record_error_text (
    p_text in varchar2,
    p_warning_only in boolean default NULL
  ) ;

  --
  -- Like 'record_error_text', but fetches the message text
  -- from the AOL message dictionary using the supplied message name.
  --
  procedure
  record_error (
    p_message_name in varchar2,
    p_warning_only in boolean default NULL
  ) ;

  --
  -- Like 'record_error', but retrieves the current error message
  -- from the AOL message stack.
  --
  procedure
  record_current_error (
    p_warning_only in boolean default NULL
  ) ;

  --
  -- Like 'record_error_text', but issues a nonwarning message using a
  -- pre-set text indicating that the value in the argument
  -- column is invalid.
  --
  procedure
  record_invalid_column_error (
    p_column_name in varchar2
  ) ;

  --
  -- Like 'record_error_text', but issues a warning message using a
  -- pre-set text indicating that the value in the argument
  -- column is being ignored.
  --
  procedure
  record_ignored_column_warning (
    p_column_name in varchar2
  ) ;

  --
  -- Returns a string containing the current SQLCODE which
  -- can be used to precede an internal error message.
  --
  function
  sql_error_prefix return varchar2 ;

  --
  -- Determines whether the current row being examined matches the
  -- additional where-clause provided.
  --
  function
  request_matches_condition (p_where_clause in varchar2) return boolean ;

  --
  -- Records an error with the given message name if the given condition
  -- is true about the current row.
  --
  procedure
  nonfatal_error_if(p_condition in varchar2, p_message in varchar2) ;

  --
  -- Records an error with the given message name, and then aborts
  -- processing of the current row, if the condition matches the current row.
  --
  procedure
  fatal_error_if(p_condition in varchar2, p_message in varchar2) ;

  --
  -- If the specified column in the current request null,
  -- and the specified condition is also true of the current request,
  -- this procedure sets the column to the given expression.
  --
  procedure
  default_if_null (
    p_column in varchar2,
    p_condition in varchar2,
    p_default_value_expression in varchar2
  ) ;

  --
  -- If the specified column is null, and the load type is in the list
  -- specified, this issues a warning message that the column is being
  -- ignored.
  --
  procedure
  warn_irrelevant_column (
    p_column in varchar2,
    p_load_type_list in varchar2 default null
  ) ;

  --
  -- If the load type is not in the exception list, this procedure
  -- checks the specified columns and issues a warning message if
  -- both of them contain a value.
  --
  procedure
  warn_redundant_column (
    p_column_being_used in varchar2,
    p_column_being_ignored in varchar2,
    p_exception_load_type_list in varchar2
  ) ;

  --
  -- If the load type is not in the exception list, and if necessary,
  -- this procedure attempts to derive a value the ID column from the value,
  -- if any, that is in the code column. If unsuccessful, it aborts
  -- processing of the current row.
  --
  procedure
  derive_id_from_code (
    p_id_column in varchar2,
    p_code_column in varchar2,
    p_derived_value_expression in varchar2,
    p_exception_load_type_list in varchar2,
    p_required in boolean default NULL
  ) ;



  --
  -- Private
  --


  cursor matching_request (p_interface_id in number) is
  select rowid
  from wip_job_schedule_interface
  where
    interface_id = p_interface_id and
    process_phase = WIP_CONSTANTS.ML_VALIDATION and
    process_status = WIP_CONSTANTS.RUNNING
  for update ;

  /* type request_error is record (
    error_type wip_interface_errors.error_type %type,
    error      wip_interface_errors.error      %type
  ) ;

  type error_list is table of request_error index by binary_integer ;

  current_errors error_list ; */

  any_current_request boolean ;

end WIP_JSI_Utils ;

 

/
