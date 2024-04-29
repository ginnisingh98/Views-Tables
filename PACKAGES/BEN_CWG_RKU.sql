--------------------------------------------------------
--  DDL for Package BEN_CWG_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CWG_RKU" AUTHID CURRENT_USER as
/* $Header: becwgrhi.pkh 120.0 2005/05/28 01:30:01 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_effective_date               in date
  ,p_cwb_wksht_grp_id             in number
  ,p_ordr_num                     in number
  ,p_wksht_grp_cd                 in varchar2
  ,p_label                        in varchar2
  ,p_cwg_attribute_category       in varchar2
  ,p_cwg_attribute1               in varchar2
  ,p_cwg_attribute2               in varchar2
  ,p_cwg_attribute3               in varchar2
  ,p_cwg_attribute4               in varchar2
  ,p_cwg_attribute5               in varchar2
  ,p_cwg_attribute6               in varchar2
  ,p_cwg_attribute7               in varchar2
  ,p_cwg_attribute8               in varchar2
  ,p_cwg_attribute9               in varchar2
  ,p_cwg_attribute10              in varchar2
  ,p_cwg_attribute11              in varchar2
  ,p_cwg_attribute12              in varchar2
  ,p_cwg_attribute13              in varchar2
  ,p_cwg_attribute14              in varchar2
  ,p_cwg_attribute15              in varchar2
  ,p_cwg_attribute16              in varchar2
  ,p_cwg_attribute17              in varchar2
  ,p_cwg_attribute18              in varchar2
  ,p_cwg_attribute19              in varchar2
  ,p_cwg_attribute20              in varchar2
  ,p_cwg_attribute21              in varchar2
  ,p_cwg_attribute22              in varchar2
  ,p_cwg_attribute23              in varchar2
  ,p_cwg_attribute24              in varchar2
  ,p_cwg_attribute25              in varchar2
  ,p_cwg_attribute26              in varchar2
  ,p_cwg_attribute27              in varchar2
  ,p_cwg_attribute28              in varchar2
  ,p_cwg_attribute29              in varchar2
  ,p_cwg_attribute30              in varchar2
  ,p_status_cd                    in varchar2
  ,p_hidden_cd                   in varchar2
  ,p_object_version_number        in number
  ,p_business_group_id_o          in number
  ,p_pl_id_o                      in number
  ,p_ordr_num_o                   in number
  ,p_wksht_grp_cd_o               in varchar2
  ,p_label_o                      in varchar2
  ,p_cwg_attribute_category_o     in varchar2
  ,p_cwg_attribute1_o             in varchar2
  ,p_cwg_attribute2_o             in varchar2
  ,p_cwg_attribute3_o             in varchar2
  ,p_cwg_attribute4_o             in varchar2
  ,p_cwg_attribute5_o             in varchar2
  ,p_cwg_attribute6_o             in varchar2
  ,p_cwg_attribute7_o             in varchar2
  ,p_cwg_attribute8_o             in varchar2
  ,p_cwg_attribute9_o             in varchar2
  ,p_cwg_attribute10_o            in varchar2
  ,p_cwg_attribute11_o            in varchar2
  ,p_cwg_attribute12_o            in varchar2
  ,p_cwg_attribute13_o            in varchar2
  ,p_cwg_attribute14_o            in varchar2
  ,p_cwg_attribute15_o            in varchar2
  ,p_cwg_attribute16_o            in varchar2
  ,p_cwg_attribute17_o            in varchar2
  ,p_cwg_attribute18_o            in varchar2
  ,p_cwg_attribute19_o            in varchar2
  ,p_cwg_attribute20_o            in varchar2
  ,p_cwg_attribute21_o            in varchar2
  ,p_cwg_attribute22_o            in varchar2
  ,p_cwg_attribute23_o            in varchar2
  ,p_cwg_attribute24_o            in varchar2
  ,p_cwg_attribute25_o            in varchar2
  ,p_cwg_attribute26_o            in varchar2
  ,p_cwg_attribute27_o            in varchar2
  ,p_cwg_attribute28_o            in varchar2
  ,p_cwg_attribute29_o            in varchar2
  ,p_cwg_attribute30_o            in varchar2
  ,p_status_cd_o                  in varchar2
  ,p_hidden_cd_o                 in varchar2
  ,p_object_version_number_o      in number
  );
--
end ben_cwg_rku;

 

/
