--------------------------------------------------------
--  DDL for Package HXC_HAC_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_HAC_RKD" AUTHID CURRENT_USER as
/* $Header: hxchacrhi.pkh 120.1 2006/06/08 15:17:53 gsirigin noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_approval_comp_id             in number
  ,p_approval_style_id_o          in number
  ,p_time_recipient_id_o          in number
  ,p_approval_mechanism_o         in varchar2
  ,p_approval_mechanism_id_o      in number
  ,p_wf_item_type_o               in varchar2
  ,p_wf_name_o                    in varchar2
  ,p_start_date_o                 in date
  ,p_end_date_o                   in date
  ,p_object_version_number_o      in number
  ,p_approval_order_o             in number
  ,p_time_category_id_o           in number
  ,p_parent_comp_id_o             in number
  ,p_parent_comp_ovn_o            in number
  ,p_run_recipient_extensions_o   in varchar2
  );
--
end hxc_hac_rkd;

 

/
