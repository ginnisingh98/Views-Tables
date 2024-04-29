--------------------------------------------------------
--  DDL for Package WIP_MASS_LOAD_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_MASS_LOAD_UTILITIES" AUTHID CURRENT_USER AS
/* $Header: wipmluts.pls 115.8 2002/12/12 15:02:09 rmahidha ship $ */


  --
  -- Errors out records of p_group_id in p_table matching p_where_clause.
  -- Updates p_table.PROCESS_STATUS to p_new_process_status if its record
  -- is in error. Inserts an error record in WIP_INTERFACE_ERRORS,
  -- setting the ERROR_TYPE column to p_error_type, and setting the
  -- message to the text of P_ERROR_MSG. Commits.
  --
  PROCEDURE Error (
    P_Group_Id IN NUMBER,
    P_Table IN VARCHAR2,
    P_New_Process_Status IN NUMBER,
    P_Where_Clause IN VARCHAR2,
    P_Error_Type IN NUMBER,
    P_Error_Msg IN VARCHAR2
    ) ;


  --
  -- Valid error types.
  --
  MSG_ERROR CONSTANT NUMBER := 1;
  MSG_WARNING CONSTANT NUMBER := 2;
  MSG_LOG CONSTANT NUMBER := 3;
  MSG_COLUMN CONSTANT NUMBER := 4;
  MSG_CONC CONSTANT NUMBER := 5;

  --
  -- private facilities
  --

  -- Facilities for Storing and Retreiving Mass Load Messages

  -- The procedure set_current_message() stores its argument for later
  -- retrieval by get_current_message(). The function get_current_message()
  -- can be called within a SQL select clause. The (original) reason for
  -- these procedures is to store away an AOL message so that it can be
  -- retreived multiple times -- the function fnd_message.get() works
  -- only once.

  procedure set_current_message(message varchar2) ;

  function get_current_message return varchar2;
  pragma restrict_references(get_current_message,WNDS,WNPS) ;

  -- Buffer in which we store messages
  CURRENT_MESSAGE varchar2(2000) ;


  -- Dynamic SQL Facilities

  -- Executes the argument statement.
  function dynamic_sql(x_statement varchar2,
                       P_Group_Id IN NUMBER) return number;

  -- Helper for dynamic_sql. Records erronious SQL statements in
  -- WIP_INTERFACE_ERRORS with a null group_id, interface_id of -1,
  -- error type of 1, and the creation_date set to sysdate.
  -- Does not commit.
  -- Note: If ever this procedure is called, and if ever there are
  -- rows in WIP_INTERFACE_ERRORS with an interface_id of -1, that means
  -- that there is a bug in some WIP dynamic SQL. Examine the statement
  -- fragments recorded in the table to figure out which statement has
  -- a problem.
  procedure record_bad_query(x_statement in varchar2) ;


END WIP_MASS_LOAD_UTILITIES;

 

/
