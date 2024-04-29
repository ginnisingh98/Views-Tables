--------------------------------------------------------
--  DDL for Package PAY_ASSIGNMENT_ACTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ASSIGNMENT_ACTIONS_PKG" AUTHID CURRENT_USER AS
/* $Header: pyasa01t.pkh 120.1 2007/01/22 14:54:52 alogue noship $ */
/*

   PRODUCT
   Oracle*Payroll
   --
   NAME
      pyasa01t.pkb
   --
   DESCRIPTION
      Contains routines used to support the Assignment level windows in the
      Payroll Process Results window.
   --
   MODIFIED (DD-MON-YYYY)
   dkerr	 40.0      02-NOV-1993        Created
   dkerr	 40.4      11-APP-1996        Added get_action_status and
					      get_payment_status to support
					      void payments process.
   J ALLOUN                30-JUL-1996        Added error handling.
   ccarter                 12-OCT-1999        Bug 1027169, removed pragma
                                              restriction from get_action_status
   Ed Jones                16-JAN-2002        Added ability to switch off the
                                              get_action_status function to
                                              improve query performance in
                                              PAYWSACT
   Ed Jones                03-MAY-2002        Added dbdrv commands and commit
   M.Reid       115.5      29-MAY-2003        Added get_payment_status_code
                                              function for bug 2976050
   A.Logue      115.6      13-JUN-2003        Added message_line_exists
                                              function for 2981945
   A.Logue      115.7      22-JAN-2007        Added archive_assignment_start_date
                                              and archive_person_start_date.
*/
--
--
 procedure update_row(p_rowid                in varchar2,
		      p_action_status        in varchar2 ) ;

 procedure delete_row ( p_rowid  	     in varchar2 ) ;
  --
 procedure lock_row (p_rowid                 in varchar2,
		     p_action_status         in varchar2  ) ;
 --
 -- Name
 --  get_action_status
 -- Purpose
 --  Returns the assignment action status for use in the Assignment Process
 --  results window.
 --  The action status is displayed as it is unless the action is part of
 --  a ChequeWriter process in which case it is displayed as 'Void' if the
 --  action has been voided by Void Payments process.
 --
 function  get_action_status ( p_assignment_action_id in number,
			       p_action_type          in varchar2,
			       p_action_status        in varchar2 ) return varchar2 ;
 --pragma restrict_references ( get_action_status , WNDS , WNPS ) ;
--
-- Switch on/off the get_action_status function so that it can be deferred when
-- the form (PAYWSACT) fetches from the view and then 'manually' populated
-- for each row via the POST-QUERY trigger
procedure enable_action_status;
procedure disable_action_status;
function action_status_enabled return varchar2;
 --
 -- Name
 --   get_payment_status
 -- Purpose
 --  Returns the Pre-Payments status for use in the Pre-Payments window
 --  There are three statuses :
 --     Paid     - There exists a complete check action which is not voided.
 --     Void     - There exists a completed check action but which are all voided.
 --     UnPaid   - There are no completed check actions for the pre-payment.
 --
 function  get_payment_status_code ( p_assignment_action_id in number,
                                      p_pre_payment_id       in number )
 return varchar2 ;

 function  get_payment_status ( p_assignment_action_id in number,
			        p_pre_payment_id       in number )
 return varchar2 ;
 --pragma restrict_references ( get_payment_status , WNDS , WNPS ) ;

 --
 -- Name
 --   message_line_exists
 -- Purpose
 --  Returns whether a line exists in pay_message_lines for the passed assignment action
 --
 function message_line_exists (p_assignment_action_id in number)
 return varchar2;

 --
 -- Functions to get assignemnt and person start dates : archives may process end-dated
 -- or future started assignments
 --
 function archive_assignment_start_date( p_assignment_id  in number,
                                         p_effective_date in date )
 return date;

 function archive_person_start_date( p_person_id      in number,
                                     p_effective_date in date )
 return date;

END PAY_ASSIGNMENT_ACTIONS_PKG;

/
