--------------------------------------------------------
--  DDL for Package BEN_LBC_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_LBC_RKU" AUTHID CURRENT_USER as
/* $Header: belbcrhi.pkh 120.0 2005/05/28 03:15:56 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_ler_bnft_rstrn_ctfn_id         in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_rqd_flag                       in varchar2
 ,p_enrt_ctfn_typ_cd               in varchar2
 ,p_ctfn_rqd_when_rl               in number
 ,p_ler_bnft_rstrn_id              in number
 ,p_business_group_id              in number
 ,p_lbc_attribute_category         in varchar2
 ,p_lbc_attribute1                 in varchar2
 ,p_lbc_attribute2                 in varchar2
 ,p_lbc_attribute3                 in varchar2
 ,p_lbc_attribute4                 in varchar2
 ,p_lbc_attribute5                 in varchar2
 ,p_lbc_attribute6                 in varchar2
 ,p_lbc_attribute7                 in varchar2
 ,p_lbc_attribute8                 in varchar2
 ,p_lbc_attribute9                 in varchar2
 ,p_lbc_attribute10                in varchar2
 ,p_lbc_attribute11                in varchar2
 ,p_lbc_attribute12                in varchar2
 ,p_lbc_attribute13                in varchar2
 ,p_lbc_attribute14                in varchar2
 ,p_lbc_attribute15                in varchar2
 ,p_lbc_attribute16                in varchar2
 ,p_lbc_attribute17                in varchar2
 ,p_lbc_attribute18                in varchar2
 ,p_lbc_attribute19                in varchar2
 ,p_lbc_attribute20                in varchar2
 ,p_lbc_attribute21                in varchar2
 ,p_lbc_attribute22                in varchar2
 ,p_lbc_attribute23                in varchar2
 ,p_lbc_attribute24                in varchar2
 ,p_lbc_attribute25                in varchar2
 ,p_lbc_attribute26                in varchar2
 ,p_lbc_attribute27                in varchar2
 ,p_lbc_attribute28                in varchar2
 ,p_lbc_attribute29                in varchar2
 ,p_lbc_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_rqd_flag_o                     in varchar2
 ,p_enrt_ctfn_typ_cd_o             in varchar2
 ,p_ctfn_rqd_when_rl_o             in number
 ,p_ler_bnft_rstrn_id_o            in number
 ,p_business_group_id_o            in number
 ,p_lbc_attribute_category_o       in varchar2
 ,p_lbc_attribute1_o               in varchar2
 ,p_lbc_attribute2_o               in varchar2
 ,p_lbc_attribute3_o               in varchar2
 ,p_lbc_attribute4_o               in varchar2
 ,p_lbc_attribute5_o               in varchar2
 ,p_lbc_attribute6_o               in varchar2
 ,p_lbc_attribute7_o               in varchar2
 ,p_lbc_attribute8_o               in varchar2
 ,p_lbc_attribute9_o               in varchar2
 ,p_lbc_attribute10_o              in varchar2
 ,p_lbc_attribute11_o              in varchar2
 ,p_lbc_attribute12_o              in varchar2
 ,p_lbc_attribute13_o              in varchar2
 ,p_lbc_attribute14_o              in varchar2
 ,p_lbc_attribute15_o              in varchar2
 ,p_lbc_attribute16_o              in varchar2
 ,p_lbc_attribute17_o              in varchar2
 ,p_lbc_attribute18_o              in varchar2
 ,p_lbc_attribute19_o              in varchar2
 ,p_lbc_attribute20_o              in varchar2
 ,p_lbc_attribute21_o              in varchar2
 ,p_lbc_attribute22_o              in varchar2
 ,p_lbc_attribute23_o              in varchar2
 ,p_lbc_attribute24_o              in varchar2
 ,p_lbc_attribute25_o              in varchar2
 ,p_lbc_attribute26_o              in varchar2
 ,p_lbc_attribute27_o              in varchar2
 ,p_lbc_attribute28_o              in varchar2
 ,p_lbc_attribute29_o              in varchar2
 ,p_lbc_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_lbc_rku;

 

/
