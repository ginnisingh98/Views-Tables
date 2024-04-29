--------------------------------------------------------
--  DDL for Package BEN_CMD_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CMD_RKU" AUTHID CURRENT_USER as
/* $Header: becmdrhi.pkh 120.0 2005/05/28 01:06:37 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_cm_dlvry_med_typ_id            in number
 ,p_cm_dlvry_med_typ_cd            in varchar2
 ,p_cm_dlvry_mthd_typ_id           in number
 ,p_rqd_flag                       in varchar2
 ,p_dflt_flag                      in varchar2
 ,p_business_group_id              in number
 ,p_cmd_attribute_category         in varchar2
 ,p_cmd_attribute1                 in varchar2
 ,p_cmd_attribute2                 in varchar2
 ,p_cmd_attribute3                 in varchar2
 ,p_cmd_attribute4                 in varchar2
 ,p_cmd_attribute5                 in varchar2
 ,p_cmd_attribute6                 in varchar2
 ,p_cmd_attribute7                 in varchar2
 ,p_cmd_attribute8                 in varchar2
 ,p_cmd_attribute9                 in varchar2
 ,p_cmd_attribute10                in varchar2
 ,p_cmd_attribute11                in varchar2
 ,p_cmd_attribute12                in varchar2
 ,p_cmd_attribute13                in varchar2
 ,p_cmd_attribute14                in varchar2
 ,p_cmd_attribute15                in varchar2
 ,p_cmd_attribute16                in varchar2
 ,p_cmd_attribute17                in varchar2
 ,p_cmd_attribute18                in varchar2
 ,p_cmd_attribute19                in varchar2
 ,p_cmd_attribute20                in varchar2
 ,p_cmd_attribute21                in varchar2
 ,p_cmd_attribute22                in varchar2
 ,p_cmd_attribute23                in varchar2
 ,p_cmd_attribute24                in varchar2
 ,p_cmd_attribute25                in varchar2
 ,p_cmd_attribute26                in varchar2
 ,p_cmd_attribute27                in varchar2
 ,p_cmd_attribute28                in varchar2
 ,p_cmd_attribute29                in varchar2
 ,p_cmd_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_cm_dlvry_med_typ_cd_o          in varchar2
 ,p_cm_dlvry_mthd_typ_id_o         in number
 ,p_rqd_flag_o                     in varchar2
 ,p_dflt_flag_o                    in varchar2
 ,p_business_group_id_o            in number
 ,p_cmd_attribute_category_o       in varchar2
 ,p_cmd_attribute1_o               in varchar2
 ,p_cmd_attribute2_o               in varchar2
 ,p_cmd_attribute3_o               in varchar2
 ,p_cmd_attribute4_o               in varchar2
 ,p_cmd_attribute5_o               in varchar2
 ,p_cmd_attribute6_o               in varchar2
 ,p_cmd_attribute7_o               in varchar2
 ,p_cmd_attribute8_o               in varchar2
 ,p_cmd_attribute9_o               in varchar2
 ,p_cmd_attribute10_o              in varchar2
 ,p_cmd_attribute11_o              in varchar2
 ,p_cmd_attribute12_o              in varchar2
 ,p_cmd_attribute13_o              in varchar2
 ,p_cmd_attribute14_o              in varchar2
 ,p_cmd_attribute15_o              in varchar2
 ,p_cmd_attribute16_o              in varchar2
 ,p_cmd_attribute17_o              in varchar2
 ,p_cmd_attribute18_o              in varchar2
 ,p_cmd_attribute19_o              in varchar2
 ,p_cmd_attribute20_o              in varchar2
 ,p_cmd_attribute21_o              in varchar2
 ,p_cmd_attribute22_o              in varchar2
 ,p_cmd_attribute23_o              in varchar2
 ,p_cmd_attribute24_o              in varchar2
 ,p_cmd_attribute25_o              in varchar2
 ,p_cmd_attribute26_o              in varchar2
 ,p_cmd_attribute27_o              in varchar2
 ,p_cmd_attribute28_o              in varchar2
 ,p_cmd_attribute29_o              in varchar2
 ,p_cmd_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_cmd_rku;

 

/
