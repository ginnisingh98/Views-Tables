--------------------------------------------------------
--  DDL for Package HXC_HAC_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_HAC_RKI" AUTHID CURRENT_USER as
/* $Header: hxchacrhi.pkh 120.1 2006/06/08 15:17:53 gsirigin noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_approval_comp_id             in number
  ,p_approval_style_id            in number
  ,p_time_recipient_id            in number
  ,p_approval_mechanism           in varchar2
  ,p_approval_mechanism_id        in number
  ,p_wf_item_type                 in varchar2
  ,p_wf_name                      in varchar2
  ,p_start_date                   in date
  ,p_end_date                     in date
  ,p_object_version_number        in number
  ,p_approval_order               in number
  ,p_time_category_id             in number
  ,p_parent_comp_id               in number
  ,p_parent_comp_ovn              in number
  ,p_run_recipient_extensions     in varchar2
  );
end hxc_hac_rki;

 

/
