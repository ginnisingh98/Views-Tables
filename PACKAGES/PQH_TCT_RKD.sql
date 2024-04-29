--------------------------------------------------------
--  DDL for Package PQH_TCT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_TCT_RKD" AUTHID CURRENT_USER as
/* $Header: pqtctrhi.pkh 120.2.12000000.2 2007/04/19 12:48:28 brsinha noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_transaction_category_id        in number
 ,p_custom_wf_process_name_o       in varchar2
 ,p_custom_workflow_name_o         in varchar2
 ,p_form_name_o                    in varchar2
 ,p_freeze_status_cd_o             in varchar2
 ,p_future_action_cd_o             in varchar2
 ,p_member_cd_o                    in varchar2
 ,p_name_o                         in varchar2
 ,p_short_name_o                     in varchar2
 ,p_post_style_cd_o                in varchar2
 ,p_post_txn_function_o            in varchar2
 ,p_route_validated_txn_flag_o     in varchar2
 ,p_prevent_approver_skip_o        in varchar2
 ,p_workflow_enable_flag_o     in varchar2
 ,p_enable_flag_o     in varchar2
 ,p_timeout_days_o                 in number
 ,p_object_version_number_o        in number
 ,p_consolidated_table_route_i_o  in number
 ,p_business_group_id_o           in number
 ,p_setup_type_cd_o               in varchar2
 ,p_master_table_route_i_o  in number
  );
--
end pqh_tct_rkd;

 

/
