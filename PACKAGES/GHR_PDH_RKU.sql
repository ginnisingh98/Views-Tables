--------------------------------------------------------
--  DDL for Package GHR_PDH_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_PDH_RKU" AUTHID CURRENT_USER as
/* $Header: ghpdhrhi.pkh 120.0 2005/05/29 03:27:50 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update	(
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
         p_object_version_number        in number  ,
	 p_item_key                     in varchar2,
         p_position_description_id_o    in number  ,
         p_initiator_flag_o             in varchar2,
         p_requester_flag_o               in varchar2,
         p_approver_flag_o              in varchar2,
         p_reviewer_flag_o              in varchar2,
         p_authorizer_flag_o            in varchar2,
         p_personnelist_flag_o          in varchar2,
         p_approved_flag_o              in varchar2,
         p_user_name_o                  in varchar2,
         p_user_name_employee_id_o      in number  ,
         p_user_name_emp_first_name_o   in varchar2,
         p_user_name_emp_last_name_o    in varchar2,
         p_user_name_emp_middle_names_o in varchar2,
         p_action_taken_o               in varchar2,
         p_groupbox_id_o                in number  ,
         p_routing_list_id_o            in number  ,
         p_routing_seq_number_o         in number  ,
         p_date_notification_sent_o     in date    ,
	 p_item_key_o                     in varchar2,
         p_object_version_number_o      in number  );

end ghr_pdh_rku;

 

/
