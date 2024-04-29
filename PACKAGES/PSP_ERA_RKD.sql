--------------------------------------------------------
--  DDL for Package PSP_ERA_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_ERA_RKD" AUTHID CURRENT_USER as
/* $Header: PSPEARHS.pls 120.1 2006/03/26 01:08:35 dpaudel noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_effort_report_approval_id    in number
  ,p_effort_report_detail_id_o    in number
  ,p_wf_role_name_o               in varchar2
  ,p_wf_orig_system_id_o          in number
  ,p_wf_orig_system_o             in varchar2
  ,p_approver_order_num_o         in number
  ,p_approval_status_o            in varchar2
  ,p_response_date_o              in date
  ,p_actual_cost_share_o          in number
  ,p_overwritten_effort_percent_o in number
  ,p_wf_item_key_o                in varchar2
  ,p_comments_o                   in varchar2
  ,p_pera_information_category_o  in varchar2
  ,p_pera_information1_o          in varchar2
  ,p_pera_information2_o          in varchar2
  ,p_pera_information3_o          in varchar2
  ,p_pera_information4_o          in varchar2
  ,p_pera_information5_o          in varchar2
  ,p_pera_information6_o          in varchar2
  ,p_pera_information7_o          in varchar2
  ,p_pera_information8_o          in varchar2
  ,p_pera_information9_o          in varchar2
  ,p_pera_information10_o         in varchar2
  ,p_pera_information11_o         in varchar2
  ,p_pera_information12_o         in varchar2
  ,p_pera_information13_o         in varchar2
  ,p_pera_information14_o         in varchar2
  ,p_pera_information15_o         in varchar2
  ,p_pera_information16_o         in varchar2
  ,p_pera_information17_o         in varchar2
  ,p_pera_information18_o         in varchar2
  ,p_pera_information19_o         in varchar2
  ,p_pera_information20_o         in varchar2
  ,p_wf_role_display_name_o       in varchar2
  ,p_object_version_number_o      in number
  ,p_notification_id_o            in number
  ,p_eff_information_category_o   in varchar2
  ,p_eff_information1_o           in varchar2
  ,p_eff_information2_o           in varchar2
  ,p_eff_information3_o           in varchar2
  ,p_eff_information4_o           in varchar2
  ,p_eff_information5_o           in varchar2
  ,p_eff_information6_o           in varchar2
  ,p_eff_information7_o           in varchar2
  ,p_eff_information8_o           in varchar2
  ,p_eff_information9_o           in varchar2
  ,p_eff_information10_o          in varchar2
  ,p_eff_information11_o          in varchar2
  ,p_eff_information12_o          in varchar2
  ,p_eff_information13_o          in varchar2
  ,p_eff_information14_o          in varchar2
  ,p_eff_information15_o          in varchar2
  );
--
end psp_era_rkd;

 

/
