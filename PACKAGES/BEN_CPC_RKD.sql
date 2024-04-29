--------------------------------------------------------
--  DDL for Package BEN_CPC_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CPC_RKD" AUTHID CURRENT_USER as
/* $Header: becpcrhi.pkh 120.0 2005/05/28 01:11:10 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_cntnu_prtn_ctfn_typ_id         in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_business_group_id_o            in number
 ,p_cntng_prtn_elig_prfl_id_o      in number
 ,p_pfd_flag_o                     in varchar2
 ,p_lack_ctfn_sspnd_elig_flag_o    in varchar2
 ,p_ctfn_rqd_when_rl_o             in number
 ,p_prtn_ctfn_typ_cd_o             in varchar2
 ,p_cpc_attribute_category_o       in varchar2
 ,p_cpc_attribute1_o               in varchar2
 ,p_cpc_attribute2_o               in varchar2
 ,p_cpc_attribute3_o               in varchar2
 ,p_cpc_attribute4_o               in varchar2
 ,p_cpc_attribute5_o               in varchar2
 ,p_cpc_attribute6_o               in varchar2
 ,p_cpc_attribute7_o               in varchar2
 ,p_cpc_attribute8_o               in varchar2
 ,p_cpc_attribute9_o               in varchar2
 ,p_cpc_attribute10_o              in varchar2
 ,p_cpc_attribute11_o              in varchar2
 ,p_cpc_attribute12_o              in varchar2
 ,p_cpc_attribute13_o              in varchar2
 ,p_cpc_attribute14_o              in varchar2
 ,p_cpc_attribute15_o              in varchar2
 ,p_cpc_attribute16_o              in varchar2
 ,p_cpc_attribute17_o              in varchar2
 ,p_cpc_attribute18_o              in varchar2
 ,p_cpc_attribute19_o              in varchar2
 ,p_cpc_attribute20_o              in varchar2
 ,p_cpc_attribute21_o              in varchar2
 ,p_cpc_attribute22_o              in varchar2
 ,p_cpc_attribute23_o              in varchar2
 ,p_cpc_attribute24_o              in varchar2
 ,p_cpc_attribute25_o              in varchar2
 ,p_cpc_attribute26_o              in varchar2
 ,p_cpc_attribute27_o              in varchar2
 ,p_cpc_attribute28_o              in varchar2
 ,p_cpc_attribute29_o              in varchar2
 ,p_cpc_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_cpc_rkd;

 

/
