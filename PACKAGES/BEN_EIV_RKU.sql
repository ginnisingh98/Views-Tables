--------------------------------------------------------
--  DDL for Package BEN_EIV_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EIV_RKU" AUTHID CURRENT_USER as
/* $Header: beeivrhi.pkh 120.0 2005/05/28 02:16:44 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_extra_input_value_id         in number
  ,p_acty_base_rt_id              in number
  ,p_input_value_id               in number
  ,p_input_text                   in varchar2
  ,p_upd_when_ele_ended_cd        in varchar2
  ,p_return_var_name              in varchar2
  ,p_business_group_id            in number
  ,p_eiv_attribute_category       in varchar2
  ,p_eiv_attribute1               in varchar2
  ,p_eiv_attribute2               in varchar2
  ,p_eiv_attribute3               in varchar2
  ,p_eiv_attribute4               in varchar2
  ,p_eiv_attribute5               in varchar2
  ,p_eiv_attribute6               in varchar2
  ,p_eiv_attribute7               in varchar2
  ,p_eiv_attribute8               in varchar2
  ,p_eiv_attribute9               in varchar2
  ,p_eiv_attribute10              in varchar2
  ,p_eiv_attribute11              in varchar2
  ,p_eiv_attribute12              in varchar2
  ,p_eiv_attribute13              in varchar2
  ,p_eiv_attribute14              in varchar2
  ,p_eiv_attribute15              in varchar2
  ,p_eiv_attribute16              in varchar2
  ,p_eiv_attribute17              in varchar2
  ,p_eiv_attribute18              in varchar2
  ,p_eiv_attribute19              in varchar2
  ,p_eiv_attribute20              in varchar2
  ,p_eiv_attribute21              in varchar2
  ,p_eiv_attribute22              in varchar2
  ,p_eiv_attribute23              in varchar2
  ,p_eiv_attribute24              in varchar2
  ,p_eiv_attribute25              in varchar2
  ,p_eiv_attribute26              in varchar2
  ,p_eiv_attribute27              in varchar2
  ,p_eiv_attribute28              in varchar2
  ,p_eiv_attribute29              in varchar2
  ,p_eiv_attribute30              in varchar2
  ,p_object_version_number        in number
  ,p_effective_date               in date
  ,p_acty_base_rt_id_o            in number
  ,p_input_value_id_o             in number
  ,p_input_text_o                 in varchar2
  ,p_upd_when_ele_ended_cd_o      in varchar2
  ,p_return_var_name_o            in varchar2
  ,p_business_group_id_o          in number
  ,p_eiv_attribute_category_o     in varchar2
  ,p_eiv_attribute1_o             in varchar2
  ,p_eiv_attribute2_o             in varchar2
  ,p_eiv_attribute3_o             in varchar2
  ,p_eiv_attribute4_o             in varchar2
  ,p_eiv_attribute5_o             in varchar2
  ,p_eiv_attribute6_o             in varchar2
  ,p_eiv_attribute7_o             in varchar2
  ,p_eiv_attribute8_o             in varchar2
  ,p_eiv_attribute9_o             in varchar2
  ,p_eiv_attribute10_o            in varchar2
  ,p_eiv_attribute11_o            in varchar2
  ,p_eiv_attribute12_o            in varchar2
  ,p_eiv_attribute13_o            in varchar2
  ,p_eiv_attribute14_o            in varchar2
  ,p_eiv_attribute15_o            in varchar2
  ,p_eiv_attribute16_o            in varchar2
  ,p_eiv_attribute17_o            in varchar2
  ,p_eiv_attribute18_o            in varchar2
  ,p_eiv_attribute19_o            in varchar2
  ,p_eiv_attribute20_o            in varchar2
  ,p_eiv_attribute21_o            in varchar2
  ,p_eiv_attribute22_o            in varchar2
  ,p_eiv_attribute23_o            in varchar2
  ,p_eiv_attribute24_o            in varchar2
  ,p_eiv_attribute25_o            in varchar2
  ,p_eiv_attribute26_o            in varchar2
  ,p_eiv_attribute27_o            in varchar2
  ,p_eiv_attribute28_o            in varchar2
  ,p_eiv_attribute29_o            in varchar2
  ,p_eiv_attribute30_o            in varchar2
  ,p_object_version_number_o      in number
  );
--
end ben_eiv_rku;

 

/
