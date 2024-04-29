--------------------------------------------------------
--  DDL for Package EAM_INT_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_INT_UTILS" AUTHID CURRENT_USER AS
/* $Header: EAMINTUS.pls 115.3 2002/02/20 19:53:08 pkm ship   $ */

  --
  -- Constants
  --

  EAM_INT_EXCEPTION constant number := -20240 ;

  REQUEST_ABORTED exception ;
  pragma exception_init(REQUEST_ABORTED, -20240) ;


  -- declare a PL/SQL table to record errors
  -- with three columns: Interface_id, error_type and error

  type request_error is record (
    interface_id        number,
    error_type          wip_interface_errors.error_type %type,
    error               wip_interface_errors.error      %type
  ) ;

  type error_list is table of request_error index by binary_integer ;

  current_errors error_list ;

  any_current_request boolean ;

  --  Common procedure for error handling

  -- Add an error message into PL/SQL table current_errors.
  procedure add_error(p_interface_id    number,
                      p_text            varchar2,
                      p_error_type      number);

  -- Copy all errors from current_errors into WIP_INTERFACE_ERRORS
  procedure load_errors(p_source_interface_table in varchar2);

  function has_errors return boolean;

  procedure abort_request;

  procedure warn_irrelevant_column(p_current_rowid in rowid,
                                   p_current_interface_id in number,
                                   p_table_name in varchar2,
                                   p_column in varchar2,
                                   p_condition in varchar2);

  procedure warn_redundant_column(p_current_rowid  in rowid,
                                  p_current_interface_id in number,
                                  p_table_name in varchar2,
                                  p_column_being_used in varchar2,
                                  p_column_being_ignored in varchar2,
                                  p_condition in varchar2 default null);

  procedure derive_id_from_code(p_current_rowid in rowid,
                                p_current_interface_id in number,
                                p_table_name in varchar2,
                                p_id_column in varchar2,
                                p_code_column in varchar2,
                                p_derived_value_expression in varchar2,
                                p_id_required in boolean default true);

  procedure derive_code_from_id(p_current_rowid in rowid,
                                  p_current_interface_id in number,
                                  p_table_name in varchar2,
                                  p_id_column in varchar2,
                                  p_code_column in varchar2,
                                  p_derived_value_expression in varchar2,
                                p_id_required in boolean default true);

  procedure default_if_null(p_current_rowid in rowid,
                            p_interface_id in number,
                            p_table_name in varchar2,
                            p_column     in varchar2,
                            p_condition  in varchar2,
                            p_default_value_expression in varchar2);


  function request_matches_condition(p_current_rowid  in rowid,
                                     p_interface_id in number,
                                     p_table_name   in varchar2,
                                     p_where_clause in varchar2)
                                                    return boolean;


  procedure record_ignored_column_warning(p_interface_id in number,
                                          p_column_name in varchar2);

  procedure record_invalid_column_error(p_interface_id in number,
                                        p_column_name in varchar2);

  procedure record_error(p_interface_id in number,
                         p_text in varchar2,
                         p_warning_only in boolean);


END eam_int_utils;

 

/
