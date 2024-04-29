--------------------------------------------------------
--  DDL for Package PAY_PAYROLL_ACTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PAYROLL_ACTIONS_PKG" AUTHID CURRENT_USER AS
/* $Header: pypra02t.pkh 120.0.12010000.1 2008/07/27 23:26:42 appldev ship $ */
--
 procedure update_row(p_rowid                in varchar2,
		      p_action_status        in varchar2 ) ;
 --
 procedure delete_row ( p_rowid  	     in varchar2 ) ;
 --
 procedure lock_row (p_rowid                 in varchar2,
		     p_action_status         in varchar2  ) ;
 --
 -- Functions to support the views used in the PAYWSACT form
 --
 function v_action_status ( p_payroll_action_id     in number,
			    p_payroll_action_status in varchar2,
			    p_request_id            in number ) return varchar2;
 -- pragma restrict_references(v_action_status, WNPS, WNDS);
 --
 function v_action_status ( p_payroll_action_id     in number,
			    p_payroll_action_status in varchar2,
			    p_request_id            in number,
                            p_force                 in boolean) return varchar2;
 -- pragma restrict_references(v_action_status, WNPS, WNDS);
 --
 function v_messages_exist(p_payroll_action_id     in number) return varchar2  ;
 pragma restrict_references(v_messages_exist, WNPS,WNDS);
 --
 function  v_name(p_payroll_action_id     in number,
                  p_action_type           in varchar2,
                  p_consolidation_set_id  in number,
                  p_display_run_number    in number,
                  p_element_set_id        in number,
                  p_assignment_set_id     in number,
                  p_effective_date        in date ) return varchar2 ;
 -- pragma restrict_references(v_name, WNPS,WNDS);
--
 function  v_name(p_payroll_action_id     in number,
                  p_action_type           in varchar2,
                  p_consolidation_set_id  in number,
                  p_display_run_number    in number,
                  p_element_set_id        in number,
                  p_assignment_set_id     in number,
                  p_effective_date        in date,
                  p_force                 in boolean ) return varchar2 ;
 -- pragma restrict_references(v_name, WNPS,WNDS);


 -- DK
 -- Bug 643154
 -- The following functions allow numeric and date bind values to be
 -- passed through to a view. In a future release it is likely that this
 -- mechanism will be genericised and put into a common code area.
 --
 -- Name
 --  set_query_bindvar
 -- Purpose
 --  Sets a constant value from the client to server side
 -- Arguments
 --
 --    p_context_name   name of the context to be supported.
 --    See package body for the list of those supported.
 --
 --    p_context_value  value of the context.
 --
 procedure set_query_bindvar( p_context_name  in varchar2,
                              p_context_value in varchar2 ) ;

 -- Name
 --  get_num_bindvar
 -- Purpose
 --  Returns the the given context as a number
 -- Arguments
 --   p_context_name
 --
 function get_num_bindvar( p_context_name in varchar2 ) return number ;
 pragma restrict_references(get_num_bindvar, WNPS,WNDS);

 -- Name
 --  get_date_bindvar
 -- Purpose
 --  Returns the the given context as a date
 -- Arguments
 --   p_context_name
 --
 function get_date_bindvar( p_context_name in varchar2 ) return date ;
 pragma restrict_references(get_date_bindvar, WNPS,WNDS);

 -- Name
 --  get_char_bindvar
 -- Purpose
 --  Returns the the given context  in varchar2
 -- Arguments
 --   p_context_name
 --
 function get_char_bindvar ( p_context_name in varchar2 ) return varchar2;
 pragma restrict_references(get_char_bindvar, WNPS,WNDS);

 -- Name
 --  set_where
 -- Purpose
 --  Sets query criteria passed from the Payroll Process results block as
 --  package variables using the set_query_bindvar routines above.
 -- Arguments
 --  See below
 --
 procedure set_where ( p_payroll_id in number,
                       p_date_from in date ,
                       p_date_to in date,
                       p_action_type in varchar2 );

 procedure set_where ( p_payroll_id in number,
                       p_date_from in date ,
                       p_date_to in date,
                       p_action_type in varchar2,
                       p_server_validate in varchar2 default 'Y' ) ;
-- Name
--  latest_balance_exists
-- Purpose
--  Identifies latest balances for rows returned in pay_balances_v and
--  is defined as a function for performance reasons.
-- Arguments
--  See below
function latest_balance_exists (p_assignment_action_id in number
                               ,p_defined_balance_id   in number) return varchar2;

-- Name
--  decode_cheque_type
-- Purpose
--  Returns the correct action type for the cheque writer process depending on
--  the legislation code associated with the business_group_id passed in.
--  ie. GB => "Cheque Writer", US => "Check Writer"
-- Arguments
--  p_business_group_id
--
function decode_cheque_type ( p_business_group_id in number ) return varchar2;
--
END PAY_PAYROLL_ACTIONS_PKG;

/
