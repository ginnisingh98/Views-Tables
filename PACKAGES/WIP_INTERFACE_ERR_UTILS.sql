--------------------------------------------------------
--  DDL for Package WIP_INTERFACE_ERR_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_INTERFACE_ERR_UTILS" AUTHID CURRENT_USER as
/* $Header: wipieuts.pls 115.6 2002/12/12 14:47:01 rmahidha ship $ */

   -- declare a PL/SQL table to record errors
   -- with three columns: Interface_id, error_type and error

  type request_error is record (
    interface_id 	number,
    error_type 		wip_interface_errors.error_type %type,
    error      		wip_interface_errors.error      %type
  ) ;

  type error_list is table of request_error index by binary_integer ;

  current_errors error_list ;

  any_current_request boolean ;


  --  Common procedure for error handling

  Procedure add_error(p_interface_id 	number,
		      p_text		varchar2,
		      p_error_type	number);

  -- Add an error message into PL/SQL table current_errors.

  Procedure load_errors;

  -- Copy all errors from current_errors into WIP_INTERFACE_ERRORS.

end WIP_INTERFACE_ERR_Utils;

 

/
