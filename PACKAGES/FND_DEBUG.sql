--------------------------------------------------------
--  DDL for Package FND_DEBUG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_DEBUG" AUTHID CURRENT_USER as
/* $Header: AFCPDWBS.pls 115.1 2004/01/14 02:37:06 vvengala noship $ */

  --
  -- PUBLIC VARIABLES
  -- debug components
  REPORTS    VARCHAR2(30) := 'REPORTS';
  FORMS      VARCHAR2(30) := 'FORM';
  SQLPLUS_CP VARCHAR2(30) := 'SQLPLUS_CP';
  PLSQL_CP   VARCHAR2(30) := 'PLSQL_CP';
  JAVA_CP    VARCHAR2(30) := 'JAVA_CP';
  FORM_FUNC  VARCHAR2(30) := 'FORM_FUNCTION';
  PERL_CP    VARCHAR2(30) := 'PERL_CP';


  -- Exceptions

  -- Exception Pragmas

  --
  -- PUBLIC FUNCTIONS
  --

  --
  -- Name
  --   enable_db_rules
  -- Purpose
  --   Based on debug rules currently active for the user / responsibility
  --   it will execute the matching rules accordingly
  --   return string which will contain the debug string for the
  --   component instance to use.
  --
  -- return true if atleast one rule is executed in this call
  --        other wise returns false (if no rule is executed)
  /*
    some examples to call this API
    1. To execute all rules associated with this component having different debug options
        enable_db_rules(FND_DEBUG.FORM, 'FNDRSRUN');

    2. To execute all rules associated with this component id and component application id
        having different debug options (one of the component name or comp id and  comp appl id is required)
        enable_db_rules(FND_DEBUG.FORM, null, 1,2);

    3. To execute rules specific to a request id having different debug options
        enable_db_rules(FND_DEBUG.REPORT, 'FNDSCURS', null, null, 12345);

  */
  function enable_db_rules (comp_type       in varchar2,
                            comp_name       in varchar2,
                            comp_appl_id    in number default null,
                            comp_id         in number default null,
                            req_id          in number default null
                           ) return boolean;


  --
  -- Name
  --   disable_db_rules
  -- Purpose
  --   Based on all debug rules currently active for the user / responsibility
  --   it will disable the rules in the database session.
  --
  -- return true if atleast one rule is disabled
  --        other wise returns false (if no rule is disabled)
  function disable_db_rules return boolean;

  --
  -- Name
  --    get_os_rules
  -- Purpose
  --    Based on debug rules currently active for the user / responsibility
  --    it will return debug string which contains debug string for the component
  --    to use before running the component.
  --    this will execute one and only one rule at a call
  --    in case multiple rules are matching, the oldest rule will be picked
  --
  --  return string containing debug string for matched rule
  /*
    some examples to call this API
    1. To execute rule associated with a component instance
        get_os_rules(FND_DEBUG.REPORT, 'FNDSCURS', null, null, 12345, 0, 20420,1);


  */
  function get_os_rules ( comp_type          in varchar2,
                          comp_name          in varchar2,
                          comp_appl_id       in number default null,
                          comp_id            in number default null,
                          comp_inst_id       in number default null, /* request id */
                          user_id            in number,
                          resp_appl_id       in number,
                          resp_id            in number
                        ) return varchar2;


  --
  -- Name
  --    get_ret_value
  -- Purpose
  --    A utility function to execute the passed routine as string
  --
  --  returns string containing the result of execution of passes string.
  function get_ret_value(t_routine varchar2) return varchar2;

  --
  -- Name
  --    get_transaction_id
  -- Purpose
  --    Returns the transaction context id by calling
  --    fnd_log_repository.init_trans_int_with_context api.

  FUNCTION get_transaction_id(force               boolean   default FALSE,
                              comp_type           varchar2  default null,
                              comp_inst_id        number    default null,
                              comp_inst_appl_id   number    default null,
                              user_id             number    default null,
                              resp_id             number    default null,
                              resp_appl_id        number    default null
                            ) return number;

  --
  -- Name
  --    assign_request
  -- Purpose
  --    It will assign specified request_id to the debug_rule_execution.
  --    In case of PL SQL Profiling we have to submit a request to get the
  --    output of trace information.
  -- Arguments:
  --    Transaction_id : transaction_id for which we need to assign the
  --                     request_id
  --    request_id     : Request_id value we need to assign.
  PROCEDURE assign_request(transaction_id   IN number,
                           request_id       IN number);

 end FND_DEBUG;

 

/
