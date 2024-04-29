--------------------------------------------------------
--  DDL for Package GHR_PDH_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_PDH_RKI" AUTHID CURRENT_USER as
/* $Header: ghpdhrhi.pkh 120.0 2005/05/29 03:27:50 appldev noship $ */
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
         p_pd_routing_history_id        in number  ,
         p_position_description_id      in number  ,
         p_initiator_flag               in varchar2,
         p_requester_flag               in varchar2,
         p_approver_flag                in varchar2,
         p_reviewer_flag                in varchar2,
         p_authorizer_flag              in varchar2,
         p_personnelist_flag            in varchar2,
         p_approved_flag                in varchar2,
         p_user_name                    in varchar2,
         p_user_name_employee_id        in number  ,
         p_user_name_emp_first_name     in varchar2,
         p_user_name_emp_last_name      in varchar2,
         p_user_name_emp_middle_names   in varchar2,
         p_action_taken                 in varchar2,
         p_groupbox_id                  in number  ,
         p_routing_list_id              in number  ,
         p_routing_seq_number           in number  ,
         p_date_notification_sent       in date    ,
	 p_item_key                     in varchar2,
         p_object_version_number        in number  );

end ghr_pdh_rki;

 

/
