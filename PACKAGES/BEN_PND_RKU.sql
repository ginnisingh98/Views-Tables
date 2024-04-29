--------------------------------------------------------
--  DDL for Package BEN_PND_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PND_RKU" AUTHID CURRENT_USER as
/* $Header: bepndrhi.pkh 120.0.12010000.1 2008/07/29 12:51:19 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_pl_dpnt_cvg_ctfn_id            in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_pl_id                          in number
 ,p_pfd_flag                       in varchar2
 ,p_ctfn_rqd_when_rl               in number
 ,p_lack_ctfn_sspnd_enrt_flag      in varchar2
 ,p_dpnt_cvg_ctfn_typ_cd           in varchar2
 ,p_rqd_flag                       in varchar2
 ,p_rlshp_typ_cd                   in varchar2
 ,p_business_group_id              in number
 ,p_pnd_attribute_category         in varchar2
 ,p_pnd_attribute1                 in varchar2
 ,p_pnd_attribute2                 in varchar2
 ,p_pnd_attribute3                 in varchar2
 ,p_pnd_attribute4                 in varchar2
 ,p_pnd_attribute5                 in varchar2
 ,p_pnd_attribute6                 in varchar2
 ,p_pnd_attribute7                 in varchar2
 ,p_pnd_attribute8                 in varchar2
 ,p_pnd_attribute9                 in varchar2
 ,p_pnd_attribute10                in varchar2
 ,p_pnd_attribute11                in varchar2
 ,p_pnd_attribute12                in varchar2
 ,p_pnd_attribute13                in varchar2
 ,p_pnd_attribute14                in varchar2
 ,p_pnd_attribute15                in varchar2
 ,p_pnd_attribute16                in varchar2
 ,p_pnd_attribute17                in varchar2
 ,p_pnd_attribute18                in varchar2
 ,p_pnd_attribute19                in varchar2
 ,p_pnd_attribute20                in varchar2
 ,p_pnd_attribute21                in varchar2
 ,p_pnd_attribute22                in varchar2
 ,p_pnd_attribute23                in varchar2
 ,p_pnd_attribute24                in varchar2
 ,p_pnd_attribute25                in varchar2
 ,p_pnd_attribute26                in varchar2
 ,p_pnd_attribute27                in varchar2
 ,p_pnd_attribute28                in varchar2
 ,p_pnd_attribute29                in varchar2
 ,p_pnd_attribute30                in varchar2
 ,p_request_id                     in number
 ,p_program_application_id         in number
 ,p_program_id                     in number
 ,p_program_update_date            in date
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_pl_id_o                        in number
 ,p_pfd_flag_o                     in varchar2
 ,p_ctfn_rqd_when_rl_o             in number
 ,p_lack_ctfn_sspnd_enrt_flag_o    in varchar2
 ,p_dpnt_cvg_ctfn_typ_cd_o         in varchar2
 ,p_rqd_flag_o                     in varchar2
 ,p_rlshp_typ_cd_o                 in varchar2
 ,p_business_group_id_o            in number
 ,p_pnd_attribute_category_o       in varchar2
 ,p_pnd_attribute1_o               in varchar2
 ,p_pnd_attribute2_o               in varchar2
 ,p_pnd_attribute3_o               in varchar2
 ,p_pnd_attribute4_o               in varchar2
 ,p_pnd_attribute5_o               in varchar2
 ,p_pnd_attribute6_o               in varchar2
 ,p_pnd_attribute7_o               in varchar2
 ,p_pnd_attribute8_o               in varchar2
 ,p_pnd_attribute9_o               in varchar2
 ,p_pnd_attribute10_o              in varchar2
 ,p_pnd_attribute11_o              in varchar2
 ,p_pnd_attribute12_o              in varchar2
 ,p_pnd_attribute13_o              in varchar2
 ,p_pnd_attribute14_o              in varchar2
 ,p_pnd_attribute15_o              in varchar2
 ,p_pnd_attribute16_o              in varchar2
 ,p_pnd_attribute17_o              in varchar2
 ,p_pnd_attribute18_o              in varchar2
 ,p_pnd_attribute19_o              in varchar2
 ,p_pnd_attribute20_o              in varchar2
 ,p_pnd_attribute21_o              in varchar2
 ,p_pnd_attribute22_o              in varchar2
 ,p_pnd_attribute23_o              in varchar2
 ,p_pnd_attribute24_o              in varchar2
 ,p_pnd_attribute25_o              in varchar2
 ,p_pnd_attribute26_o              in varchar2
 ,p_pnd_attribute27_o              in varchar2
 ,p_pnd_attribute28_o              in varchar2
 ,p_pnd_attribute29_o              in varchar2
 ,p_pnd_attribute30_o              in varchar2
 ,p_request_id_o                   in number
 ,p_program_application_id_o       in number
 ,p_program_id_o                   in number
 ,p_program_update_date_o          in date
 ,p_object_version_number_o        in number
  );
--
end ben_pnd_rku;

/
