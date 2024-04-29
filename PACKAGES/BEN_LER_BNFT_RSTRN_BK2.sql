--------------------------------------------------------
--  DDL for Package BEN_LER_BNFT_RSTRN_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_LER_BNFT_RSTRN_BK2" AUTHID CURRENT_USER as
/* $Header: belbrapi.pkh 120.0 2005/05/28 03:16:21 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_LER_BNFT_RSTRN_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_LER_BNFT_RSTRN_b
  (
   p_ler_bnft_rstrn_id              in  number
  ,p_no_mx_cvg_amt_apls_flag        in  varchar2
  ,p_no_mn_cvg_incr_apls_flag       in  varchar2
  ,p_no_mx_cvg_incr_apls_flag       in  varchar2
  ,p_mx_cvg_incr_wcf_alwd_amt       in  number
  ,p_mx_cvg_incr_alwd_amt           in  number
  ,p_mx_cvg_alwd_amt                in  number
  ,p_mx_cvg_mlt_incr_num            in  number
  ,p_mx_cvg_mlt_incr_wcf_num        in  number
  ,p_mx_cvg_rl                      in  number
  ,p_mx_cvg_wcfn_amt                in  number
  ,p_mx_cvg_wcfn_mlt_num            in  number
  ,p_mn_cvg_amt                     in  number
  ,p_mn_cvg_rl                      in  number
  ,p_cvg_incr_r_decr_only_cd        in  varchar2
  ,p_unsspnd_enrt_cd                in  varchar2
  ,p_dflt_to_asn_pndg_ctfn_cd       in  varchar2
  ,p_dflt_to_asn_pndg_ctfn_rl       in  number
  ,p_ler_id                         in  number
  ,p_pl_id                          in  number
  ,p_business_group_id              in  number
  ,p_plip_id                        in  number
  ,p_lbr_attribute_category         in  varchar2
  ,p_lbr_attribute1                 in  varchar2
  ,p_lbr_attribute2                 in  varchar2
  ,p_lbr_attribute3                 in  varchar2
  ,p_lbr_attribute4                 in  varchar2
  ,p_lbr_attribute5                 in  varchar2
  ,p_lbr_attribute6                 in  varchar2
  ,p_lbr_attribute7                 in  varchar2
  ,p_lbr_attribute8                 in  varchar2
  ,p_lbr_attribute9                 in  varchar2
  ,p_lbr_attribute10                in  varchar2
  ,p_lbr_attribute11                in  varchar2
  ,p_lbr_attribute12                in  varchar2
  ,p_lbr_attribute13                in  varchar2
  ,p_lbr_attribute14                in  varchar2
  ,p_lbr_attribute15                in  varchar2
  ,p_lbr_attribute16                in  varchar2
  ,p_lbr_attribute17                in  varchar2
  ,p_lbr_attribute18                in  varchar2
  ,p_lbr_attribute19                in  varchar2
  ,p_lbr_attribute20                in  varchar2
  ,p_lbr_attribute21                in  varchar2
  ,p_lbr_attribute22                in  varchar2
  ,p_lbr_attribute23                in  varchar2
  ,p_lbr_attribute24                in  varchar2
  ,p_lbr_attribute25                in  varchar2
  ,p_lbr_attribute26                in  varchar2
  ,p_lbr_attribute27                in  varchar2
  ,p_lbr_attribute28                in  varchar2
  ,p_lbr_attribute29                in  varchar2
  ,p_lbr_attribute30                in  varchar2
  ,p_susp_if_ctfn_not_prvd_flag     in  varchar2
  ,p_ctfn_determine_cd              in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_LER_BNFT_RSTRN_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_LER_BNFT_RSTRN_a
  (
   p_ler_bnft_rstrn_id              in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_no_mx_cvg_amt_apls_flag        in  varchar2
  ,p_no_mn_cvg_incr_apls_flag       in  varchar2
  ,p_no_mx_cvg_incr_apls_flag       in  varchar2
  ,p_mx_cvg_incr_wcf_alwd_amt       in  number
  ,p_mx_cvg_incr_alwd_amt           in  number
  ,p_mx_cvg_alwd_amt                in  number
  ,p_mx_cvg_mlt_incr_num            in  number
  ,p_mx_cvg_mlt_incr_wcf_num        in  number
  ,p_mx_cvg_rl                      in  number
  ,p_mx_cvg_wcfn_amt                in  number
  ,p_mx_cvg_wcfn_mlt_num            in  number
  ,p_mn_cvg_amt                     in  number
  ,p_mn_cvg_rl                      in  number
  ,p_cvg_incr_r_decr_only_cd        in  varchar2
  ,p_unsspnd_enrt_cd                in  varchar2
  ,p_dflt_to_asn_pndg_ctfn_cd       in  varchar2
  ,p_dflt_to_asn_pndg_ctfn_rl       in  number
  ,p_ler_id                         in  number
  ,p_pl_id                          in  number
  ,p_business_group_id              in  number
  ,p_plip_id                        in  number
  ,p_lbr_attribute_category         in  varchar2
  ,p_lbr_attribute1                 in  varchar2
  ,p_lbr_attribute2                 in  varchar2
  ,p_lbr_attribute3                 in  varchar2
  ,p_lbr_attribute4                 in  varchar2
  ,p_lbr_attribute5                 in  varchar2
  ,p_lbr_attribute6                 in  varchar2
  ,p_lbr_attribute7                 in  varchar2
  ,p_lbr_attribute8                 in  varchar2
  ,p_lbr_attribute9                 in  varchar2
  ,p_lbr_attribute10                in  varchar2
  ,p_lbr_attribute11                in  varchar2
  ,p_lbr_attribute12                in  varchar2
  ,p_lbr_attribute13                in  varchar2
  ,p_lbr_attribute14                in  varchar2
  ,p_lbr_attribute15                in  varchar2
  ,p_lbr_attribute16                in  varchar2
  ,p_lbr_attribute17                in  varchar2
  ,p_lbr_attribute18                in  varchar2
  ,p_lbr_attribute19                in  varchar2
  ,p_lbr_attribute20                in  varchar2
  ,p_lbr_attribute21                in  varchar2
  ,p_lbr_attribute22                in  varchar2
  ,p_lbr_attribute23                in  varchar2
  ,p_lbr_attribute24                in  varchar2
  ,p_lbr_attribute25                in  varchar2
  ,p_lbr_attribute26                in  varchar2
  ,p_lbr_attribute27                in  varchar2
  ,p_lbr_attribute28                in  varchar2
  ,p_lbr_attribute29                in  varchar2
  ,p_lbr_attribute30                in  varchar2
  ,p_susp_if_ctfn_not_prvd_flag     in  varchar2
  ,p_ctfn_determine_cd              in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
end ben_LER_BNFT_RSTRN_bk2;

 

/
