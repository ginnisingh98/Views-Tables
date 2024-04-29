--------------------------------------------------------
--  DDL for Package BEN_PCP_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PCP_RKD" AUTHID CURRENT_USER as
/* $Header: bepcprhi.pkh 120.0 2005/05/28 10:14:07 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_pl_pcp_id                    in number
  ,p_pl_id_o                      in number
  ,p_business_group_id_o          in number
  ,p_pcp_strt_dt_cd_o             in varchar2
  ,p_pcp_dsgn_cd_o                in varchar2
  ,p_pcp_dpnt_dsgn_cd_o           in varchar2
  ,p_pcp_rpstry_flag_o            in varchar2
  ,p_pcp_can_keep_flag_o          in varchar2
  ,p_pcp_radius_o                 in number
  ,p_pcp_radius_uom_o             in varchar2
  ,p_pcp_radius_warn_flag_o       in varchar2
  ,p_pcp_num_chgs_o               in number
  ,p_pcp_num_chgs_uom_o           in varchar2
  ,p_pcp_attribute_category_o     in varchar2
  ,p_pcp_attribute1_o             in varchar2
  ,p_pcp_attribute2_o             in varchar2
  ,p_pcp_attribute3_o             in varchar2
  ,p_pcp_attribute4_o             in varchar2
  ,p_pcp_attribute5_o             in varchar2
  ,p_pcp_attribute6_o             in varchar2
  ,p_pcp_attribute7_o             in varchar2
  ,p_pcp_attribute8_o             in varchar2
  ,p_pcp_attribute9_o             in varchar2
  ,p_pcp_attribute10_o            in varchar2
  ,p_pcp_attribute11_o            in varchar2
  ,p_pcp_attribute12_o            in varchar2
  ,p_pcp_attribute13_o            in varchar2
  ,p_pcp_attribute14_o            in varchar2
  ,p_pcp_attribute15_o            in varchar2
  ,p_pcp_attribute16_o            in varchar2
  ,p_pcp_attribute17_o            in varchar2
  ,p_pcp_attribute18_o            in varchar2
  ,p_pcp_attribute19_o            in varchar2
  ,p_pcp_attribute20_o            in varchar2
  ,p_pcp_attribute21_o            in varchar2
  ,p_pcp_attribute22_o            in varchar2
  ,p_pcp_attribute23_o            in varchar2
  ,p_pcp_attribute24_o            in varchar2
  ,p_pcp_attribute25_o            in varchar2
  ,p_pcp_attribute26_o            in varchar2
  ,p_pcp_attribute27_o            in varchar2
  ,p_pcp_attribute28_o            in varchar2
  ,p_pcp_attribute29_o            in varchar2
  ,p_pcp_attribute30_o            in varchar2
  ,p_object_version_number_o      in number
  );
--
end ben_pcp_rkd;

 

/
