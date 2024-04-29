--------------------------------------------------------
--  DDL for Package GHR_PRH_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_PRH_RKI" AUTHID CURRENT_USER as
/* $Header: ghprhrhi.pkh 120.1.12000000.1 2007/01/18 14:09:34 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_insert >------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description :
--    If the user(customer) has any packages to be executed, then those will be
--    called by this procedure. The body of this procedure will be generated.
--
procedure after_insert	(
	p_pa_routing_history_id         in number,
	p_pa_request_id                 in number,
	p_attachment_modified_flag      in varchar2,
	p_initiator_flag                in varchar2,
	p_approver_flag                 in varchar2,
	p_reviewer_flag                 in varchar2,
	p_requester_flag                in varchar2,
      p_authorizer_flag               in varchar2,
      p_personnelist_flag             in varchar2,
 	p_approved_flag                 in varchar2,
    	p_user_name                     in varchar2,
	p_user_name_employee_id         in number,
     	p_user_name_emp_first_name      in varchar2,
	p_user_name_emp_last_name       in varchar2,
	p_user_name_emp_middle_names    in varchar2,
	p_notepad                       in varchar2,
	p_action_taken                  in varchar2,
	p_groupbox_id                   in number,
	p_routing_list_id               in number,
	p_routing_seq_number            in number,
      p_noa_family_code               in varchar2,
	p_nature_of_action_id           in number,
	p_second_nature_of_action_id    in number,
      p_approval_status               in varchar2,
	p_date_notification_sent        in date,
	p_object_version_number         in number  );

end ghr_prh_rki;

 

/
