--------------------------------------------------------
--  DDL for Package BEN_CWB_RSGN_EMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CWB_RSGN_EMP" AUTHID CURRENT_USER as
/* $Header: bencwbre.pkh 120.0.12000000.1 2007/01/19 15:29:45 appldev noship $ */

/* ===========================================================================+
 * Name
 *   Compensation workbench reassign employee
 * Purpose
 *
 * Version   Date           Author     Comment
 * -------+-----------+---------+----------------------------------------------
 * 115.0    01-July-2002   aupadhya    created
 * 115.1    07-Aug-2002    aupadhya    No Change, just removed extra rem statement.
 * 115.2    27-Aug-2002    aupadhya    Remove unused method declaration.
 * 115.3    16-Dec-2002    hnarayan    Added NOCOPY hint
 * 115.4    24-Dec-2002    aupadhya    Modified for CWB Itemization.
 * 115.5    24-Mar-2003    aupadhya    Replaced p_emp_id by p_emp_num in store_emp_details
 * *
 * ==========================================================================+
 * 115.6    01-Mar-2004    aupadhya    Global Budgeting Changes.
 * 115.7    20-Sep-2004    aupadhya    Global Budgeting 11.5.10
 * ==========================================================================+
 */

-- ----------------------------------------------------------------------------
-- |-------------------------< check_approver >-------------------------|
-- ----------------------------------------------------------------------------

procedure check_approver(itemtype    in varchar2
      , itemkey                          in varchar2
      , actid                            in number
      , funcmode                         in varchar2
      , result                       out nocopy    varchar2);

-- ----------------------------------------------------------------------------
-- |-------------------------< store_approval_details >-------------------------|
-- ----------------------------------------------------------------------------

procedure store_approval_details(itemtype    in varchar2
      , itemkey                          in varchar2
      , actid                            in number
      , funcmode                         in varchar2
      , result                       out nocopy    varchar2);

-- ----------------------------------------------------------------------------
-- |-------------------------< curr_ws_mgr_check >---------------------|
-- ----------------------------------------------------------------------------

   procedure curr_ws_mgr_check(itemtype    in varchar2
       , itemkey                          in varchar2
       , actid                            in number
       , funcmode                         in varchar2
      , result                       out nocopy    varchar2);

-- ----------------------------------------------------------------------------
-- |-------------------------< prop_ws_mgr_check >---------------------|
-- ----------------------------------------------------------------------------

 procedure prop_ws_mgr_check(itemtype    in varchar2
          , itemkey                          in varchar2
          , actid                            in number
          , funcmode                         in varchar2
         , result                       out nocopy    varchar2);

-- ----------------------------------------------------------------------------
-- |-------------------------< which_message >---------------------|
-- ----------------------------------------------------------------------------

 procedure which_message(itemtype    in varchar2
 	         , itemkey                          in varchar2
 	         , actid                            in number
 	         , funcmode                         in varchar2
	         , result                       out nocopy    varchar2);

-- ----------------------------------------------------------------------------
-- |-------------------------< set_rejection >---------------------|
-- ----------------------------------------------------------------------------
 procedure set_rejection(itemtype    in varchar2
 	         , itemkey                          in varchar2
 	         , actid                            in number
 	         , funcmode                         in varchar2
	         , result                       out nocopy    varchar2);

-- ----------------------------------------------------------------------------
-- |-------------------------< set_approval >---------------------|
-- ----------------------------------------------------------------------------

 procedure set_approval(itemtype    in varchar2
 	         , itemkey                          in varchar2
 	         , actid                            in number
 	         , funcmode                         in varchar2
	         , result                       out nocopy    varchar2);

-- ----------------------------------------------------------------------------
-- |-------------------------< is_in_comp_manager_role >---------------------|
-- ----------------------------------------------------------------------------

function is_in_comp_manager_role(p_person_id in number) return varchar2;


-- ----------------------------------------------------------------------------
-- |-------------------------< store_emp_details >---------------------|
-- ----------------------------------------------------------------------------

 procedure store_emp_details
   			(p_per_in_ler_id in number,
   			 p_transaction_id in number,
   			 p_emp_name in varchar2,
   			 p_emp_num in varchar2,
   			 p_curr_ws_mgr in varchar2,
   			 p_curr_ws_mgr_id in number,
   			 p_prop_ws_mgr in varchar2,
   			 p_prop_ws_mgr_id in number,
   			 p_requestor in varchar2,
   			 p_requestor_id in number,
   			 p_request_date in varchar2,
   			 p_prop_ws_mgr_per_in_ler_id in number,
   			 p_curr_ws_mgr_per_in_ler_id in number,
   			 p_group_pl_id in number,
   			 p_business_group in varchar2
  			 );

-- ----------------------------------------------------------------------------
-- |-------------------------< remove_emp_details >---------------------|
-- ----------------------------------------------------------------------------

procedure remove_emp_details
			(itemtype    in varchar2
	         , itemkey                          in varchar2
	         , actid                            in number
	         , funcmode                         in varchar2
	         , result                       out nocopy    varchar2);

-- ----------------------------------------------------------------------------
-- |-------------------------< start_workflow >---------------------|
-- ----------------------------------------------------------------------------
procedure start_workflow(p_requestor_id in number,
			 p_curr_ws_manager_id number,
			 p_prop_ws_manager_id number,
			 p_plan_name varchar2,
			 p_message varchar2,
			 p_transaction_id number,
			 p_request_date  varchar2,
			 p_reccount number,
			 p_prop_ws_mgr_per_in_ler_id number,
			 p_plan_id number)  ;

-- ----------------------------------------------------------------------------
-- |-------------------------< send_fyi_notifications >---------------------|
-- ----------------------------------------------------------------------------

procedure send_fyi_notifications(p_requestor_id in number,
									 p_curr_ws_manager_id number,
									 p_prop_ws_manager_id number,
									 p_plan_name varchar2,
									 p_message varchar2,
									 p_transaction_id number,
									 p_request_date  varchar2,
		 							 p_reccount  number,
                                     p_prop_mgr_per_in_ler_id number);

-- ----------------------------------------------------------------------------
-- |-------------------------< generate_detail_html >---------------------|
-- ----------------------------------------------------------------------------

PROCEDURE generate_detail_html
	(
	  document_id      IN      VARCHAR2,
          display_type     IN      VARCHAR2,
	  document         IN OUT NOCOPY  VARCHAR2,
	  document_type    IN OUT NOCOPY  VARCHAR2
  );

-- ----------------------------------------------------------------------------
-- |-------------------------< generate_employee_table_html >---------------------|
-- ----------------------------------------------------------------------------

procedure generate_employee_table_html
    		(
    		  document_id      IN      VARCHAR2,
    			display_type     IN      VARCHAR2,
    			document         IN OUT NOCOPY  VARCHAR2,
    		  document_type    IN OUT NOCOPY  VARCHAR2
	  ) ;

-- ----------------------------------------------------------------------------
-- |-------------------------< generate_approver_table_html >---------------------|
-- ----------------------------------------------------------------------------

PROCEDURE generate_approver_table_html
  	(
  	  document_id      IN      VARCHAR2,
  		display_type     IN      VARCHAR2,
  		document         IN OUT NOCOPY  VARCHAR2,
  	  document_type    IN OUT NOCOPY  VARCHAR2
    );

-- ----------------------------------------------------------------------------
-- |-------------------------< generate_error_html >---------------------|
-- ----------------------------------------------------------------------------

PROCEDURE generate_error_html
  	(
  	  document_id      IN      VARCHAR2,
  	  display_type     IN      VARCHAR2,
  		document         IN OUT NOCOPY  VARCHAR2,
  	  document_type    IN OUT NOCOPY  VARCHAR2
  	);

end BEN_CWB_RSGN_EMP;

 

/
