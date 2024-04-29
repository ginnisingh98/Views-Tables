--------------------------------------------------------
--  DDL for Package BEN_PGC_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PGC_RKU" AUTHID CURRENT_USER as
/* $Header: bepgcrhi.pkh 120.0 2005/05/28 10:45:05 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_pgm_dpnt_cvg_ctfn_id           in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_business_group_id              in number
 ,p_pgm_id                         in number
 ,p_lack_ctfn_sspnd_enrt_flag      in varchar2
 ,p_ctfn_rqd_when_rl               in number
 ,p_pfd_flag                       in varchar2
 ,p_dpnt_cvg_ctfn_typ_cd           in varchar2
 ,p_rqd_flag                       in varchar2
 ,p_rlshp_typ_cd                   in varchar2
 ,p_pgc_attribute_category         in varchar2
 ,p_pgc_attribute1                 in varchar2
 ,p_pgc_attribute2                 in varchar2
 ,p_pgc_attribute3                 in varchar2
 ,p_pgc_attribute4                 in varchar2
 ,p_pgc_attribute5                 in varchar2
 ,p_pgc_attribute6                 in varchar2
 ,p_pgc_attribute7                 in varchar2
 ,p_pgc_attribute8                 in varchar2
 ,p_pgc_attribute9                 in varchar2
 ,p_pgc_attribute10                in varchar2
 ,p_pgc_attribute11                in varchar2
 ,p_pgc_attribute12                in varchar2
 ,p_pgc_attribute13                in varchar2
 ,p_pgc_attribute14                in varchar2
 ,p_pgc_attribute15                in varchar2
 ,p_pgc_attribute16                in varchar2
 ,p_pgc_attribute17                in varchar2
 ,p_pgc_attribute18                in varchar2
 ,p_pgc_attribute19                in varchar2
 ,p_pgc_attribute20                in varchar2
 ,p_pgc_attribute21                in varchar2
 ,p_pgc_attribute22                in varchar2
 ,p_pgc_attribute23                in varchar2
 ,p_pgc_attribute24                in varchar2
 ,p_pgc_attribute25                in varchar2
 ,p_pgc_attribute26                in varchar2
 ,p_pgc_attribute27                in varchar2
 ,p_pgc_attribute28                in varchar2
 ,p_pgc_attribute29                in varchar2
 ,p_pgc_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_business_group_id_o            in number
 ,p_pgm_id_o                       in number
 ,p_lack_ctfn_sspnd_enrt_flag_o    in varchar2
 ,p_ctfn_rqd_when_rl_o             in number
 ,p_pfd_flag_o                     in varchar2
 ,p_dpnt_cvg_ctfn_typ_cd_o         in varchar2
 ,p_rqd_flag_o                     in varchar2
 ,p_rlshp_typ_cd_o                 in varchar2
 ,p_pgc_attribute_category_o       in varchar2
 ,p_pgc_attribute1_o               in varchar2
 ,p_pgc_attribute2_o               in varchar2
 ,p_pgc_attribute3_o               in varchar2
 ,p_pgc_attribute4_o               in varchar2
 ,p_pgc_attribute5_o               in varchar2
 ,p_pgc_attribute6_o               in varchar2
 ,p_pgc_attribute7_o               in varchar2
 ,p_pgc_attribute8_o               in varchar2
 ,p_pgc_attribute9_o               in varchar2
 ,p_pgc_attribute10_o              in varchar2
 ,p_pgc_attribute11_o              in varchar2
 ,p_pgc_attribute12_o              in varchar2
 ,p_pgc_attribute13_o              in varchar2
 ,p_pgc_attribute14_o              in varchar2
 ,p_pgc_attribute15_o              in varchar2
 ,p_pgc_attribute16_o              in varchar2
 ,p_pgc_attribute17_o              in varchar2
 ,p_pgc_attribute18_o              in varchar2
 ,p_pgc_attribute19_o              in varchar2
 ,p_pgc_attribute20_o              in varchar2
 ,p_pgc_attribute21_o              in varchar2
 ,p_pgc_attribute22_o              in varchar2
 ,p_pgc_attribute23_o              in varchar2
 ,p_pgc_attribute24_o              in varchar2
 ,p_pgc_attribute25_o              in varchar2
 ,p_pgc_attribute26_o              in varchar2
 ,p_pgc_attribute27_o              in varchar2
 ,p_pgc_attribute28_o              in varchar2
 ,p_pgc_attribute29_o              in varchar2
 ,p_pgc_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_pgc_rku;

 

/
