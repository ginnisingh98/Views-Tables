--------------------------------------------------------
--  DDL for Package WIP_JDI_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_JDI_UTILS" AUTHID CURRENT_USER as
/* $Header: wipjdius.pls 115.6 2002/11/28 18:40:11 rmahidha ship $ */

--
-- Valid error types.
--
  MSG_ERROR CONSTANT NUMBER := 1;
  MSG_WARNING CONSTANT NUMBER := 2;
  MSG_LOG CONSTANT NUMBER := 3;
  MSG_COLUMN CONSTANT NUMBER := 4;
  MSG_CONC CONSTANT NUMBER := 5;

--
-- Procedures for error handling in loading details.
--

Procedure Begin_Processing_Request(p_group_id 		number,
				   p_parent_header_id	number,
                                   x_err_code		 out NOCOPY varchar2,
                                   x_err_msg		 out NOCOPY varchar2,
				   x_return_status	 out NOCOPY varchar2);

-- Generate new interface_id and set process_status to running.


Procedure Error_If_Batch(p_group_id 	number,
                         p_new_process_status number,
			 p_where_clause varchar2,
			 p_error_type	number,
			 p_error_msg	varchar2);

-- Insert error into PL/SQL table, if p_where_clause is satisfied.

Procedure End_Processing_Request(p_wip_entity_id 	number,
				 p_organization_id	number);


-- Commit if no error, else rollback.

Procedure Change_Status_Error(p_group_id number := null,
                              p_parent_header_id number := null,
                              p_wip_entity_id    number := null,
                              p_organization_id  number := null);

-- Change process_status to error after rollback.

Procedure Change_Status_Pending(p_row_id varchar2,p_group_id number);


-- Used in resubmit jobs or schedules.

end WIP_JDI_Utils;

 

/
