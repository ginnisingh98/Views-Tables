--------------------------------------------------------
--  DDL for Package BEN_ERC_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ERC_RKU" AUTHID CURRENT_USER as
/* $Header: beercrhi.pkh 120.0 2005/05/28 02:50:55 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_enrt_rt_ctfn_id                in number
 ,p_enrt_ctfn_typ_cd               in varchar2
 ,p_rqd_flag                       in varchar2
 ,p_enrt_rt_id                     in number
 ,p_business_group_id              in number
 ,p_erc_attribute_category         in varchar2
 ,p_erc_attribute1                 in varchar2
 ,p_erc_attribute2                 in varchar2
 ,p_erc_attribute3                 in varchar2
 ,p_erc_attribute4                 in varchar2
 ,p_erc_attribute5                 in varchar2
 ,p_erc_attribute6                 in varchar2
 ,p_erc_attribute7                 in varchar2
 ,p_erc_attribute8                 in varchar2
 ,p_erc_attribute9                 in varchar2
 ,p_erc_attribute10                in varchar2
 ,p_erc_attribute11                in varchar2
 ,p_erc_attribute12                in varchar2
 ,p_erc_attribute13                in varchar2
 ,p_erc_attribute14                in varchar2
 ,p_erc_attribute15                in varchar2
 ,p_erc_attribute16                in varchar2
 ,p_erc_attribute17                in varchar2
 ,p_erc_attribute18                in varchar2
 ,p_erc_attribute19                in varchar2
 ,p_erc_attribute20                in varchar2
 ,p_erc_attribute21                in varchar2
 ,p_erc_attribute22                in varchar2
 ,p_erc_attribute23                in varchar2
 ,p_erc_attribute24                in varchar2
 ,p_erc_attribute25                in varchar2
 ,p_erc_attribute26                in varchar2
 ,p_erc_attribute27                in varchar2
 ,p_erc_attribute28                in varchar2
 ,p_erc_attribute29                in varchar2
 ,p_erc_attribute30                in varchar2
 ,p_request_id                     in number
 ,p_program_application_id         in number
 ,p_program_id                     in number
 ,p_program_update_date            in date
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_enrt_ctfn_typ_cd_o             in varchar2
 ,p_rqd_flag_o                     in varchar2
 ,p_enrt_rt_id_o       in number
 ,p_business_group_id_o            in number
 ,p_erc_attribute_category_o       in varchar2
 ,p_erc_attribute1_o               in varchar2
 ,p_erc_attribute2_o               in varchar2
 ,p_erc_attribute3_o               in varchar2
 ,p_erc_attribute4_o               in varchar2
 ,p_erc_attribute5_o               in varchar2
 ,p_erc_attribute6_o               in varchar2
 ,p_erc_attribute7_o               in varchar2
 ,p_erc_attribute8_o               in varchar2
 ,p_erc_attribute9_o               in varchar2
 ,p_erc_attribute10_o              in varchar2
 ,p_erc_attribute11_o              in varchar2
 ,p_erc_attribute12_o              in varchar2
 ,p_erc_attribute13_o              in varchar2
 ,p_erc_attribute14_o              in varchar2
 ,p_erc_attribute15_o              in varchar2
 ,p_erc_attribute16_o              in varchar2
 ,p_erc_attribute17_o              in varchar2
 ,p_erc_attribute18_o              in varchar2
 ,p_erc_attribute19_o              in varchar2
 ,p_erc_attribute20_o              in varchar2
 ,p_erc_attribute21_o              in varchar2
 ,p_erc_attribute22_o              in varchar2
 ,p_erc_attribute23_o              in varchar2
 ,p_erc_attribute24_o              in varchar2
 ,p_erc_attribute25_o              in varchar2
 ,p_erc_attribute26_o              in varchar2
 ,p_erc_attribute27_o              in varchar2
 ,p_erc_attribute28_o              in varchar2
 ,p_erc_attribute29_o              in varchar2
 ,p_erc_attribute30_o              in varchar2
 ,p_request_id_o                   in number
 ,p_program_application_id_o       in number
 ,p_program_id_o                   in number
 ,p_program_update_date_o          in date
 ,p_object_version_number_o        in number
  );
--
end ben_erc_rku;

 

/
