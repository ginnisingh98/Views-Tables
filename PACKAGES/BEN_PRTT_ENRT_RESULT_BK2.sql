--------------------------------------------------------
--  DDL for Package BEN_PRTT_ENRT_RESULT_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PRTT_ENRT_RESULT_BK2" AUTHID CURRENT_USER as
/* $Header: bepenapi.pkh 120.2.12010000.1 2008/07/29 12:46:49 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_PRTT_ENRT_RESULT_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_PRTT_ENRT_RESULT_b
  (
   p_prtt_enrt_rslt_id              in  number
  ,p_business_group_id              in  number
  ,p_oipl_id                        in  number
  ,p_person_id                      in  number
  ,p_assignment_id                  in  number
  ,p_pgm_id                         in  number
  ,p_pl_id                          in  number
  ,p_rplcs_sspndd_rslt_id           in  number
  ,p_ptip_id                        in  number
  ,p_pl_typ_id                      in  number
  ,p_ler_id                         in  number
  ,p_sspndd_flag                    in  varchar2
  ,p_prtt_is_cvrd_flag              in  varchar2
  ,p_bnft_amt                       in  number
  ,p_uom                            in  varchar2
  ,p_orgnl_enrt_dt                  in  date
  ,p_enrt_mthd_cd                   in  varchar2
  ,p_no_lngr_elig_flag              in  varchar2
  ,p_enrt_ovridn_flag               in  varchar2
  ,p_enrt_ovrid_rsn_cd              in  varchar2
  ,p_erlst_deenrt_dt                in  date
  ,p_enrt_cvg_strt_dt               in  date
  ,p_enrt_cvg_thru_dt               in  date
  ,p_enrt_ovrid_thru_dt             in  date
  ,p_pl_ordr_num                    in  number
  ,p_plip_ordr_num                  in  number
  ,p_ptip_ordr_num                  in  number
  ,p_oipl_ordr_num                  in  number
  ,p_pen_attribute_category         in  varchar2
  ,p_pen_attribute1                 in  varchar2
  ,p_pen_attribute2                 in  varchar2
  ,p_pen_attribute3                 in  varchar2
  ,p_pen_attribute4                 in  varchar2
  ,p_pen_attribute5                 in  varchar2
  ,p_pen_attribute6                 in  varchar2
  ,p_pen_attribute7                 in  varchar2
  ,p_pen_attribute8                 in  varchar2
  ,p_pen_attribute9                 in  varchar2
  ,p_pen_attribute10                in  varchar2
  ,p_pen_attribute11                in  varchar2
  ,p_pen_attribute12                in  varchar2
  ,p_pen_attribute13                in  varchar2
  ,p_pen_attribute14                in  varchar2
  ,p_pen_attribute15                in  varchar2
  ,p_pen_attribute16                in  varchar2
  ,p_pen_attribute17                in  varchar2
  ,p_pen_attribute18                in  varchar2
  ,p_pen_attribute19                in  varchar2
  ,p_pen_attribute20                in  varchar2
  ,p_pen_attribute21                in  varchar2
  ,p_pen_attribute22                in  varchar2
  ,p_pen_attribute23                in  varchar2
  ,p_pen_attribute24                in  varchar2
  ,p_pen_attribute25                in  varchar2
  ,p_pen_attribute26                in  varchar2
  ,p_pen_attribute27                in  varchar2
  ,p_pen_attribute28                in  varchar2
  ,p_pen_attribute29                in  varchar2
  ,p_pen_attribute30                in  varchar2
  ,p_request_id                     in  number
  ,p_program_application_id         in  number
  ,p_program_id                     in  number
  ,p_program_update_date            in  date
  ,p_object_version_number          in  number
  ,p_per_in_ler_id                  in  number
  ,p_bnft_typ_cd                    in  varchar2
  ,p_bnft_ordr_num                  in  number
  ,p_prtt_enrt_rslt_stat_cd         in  varchar2
  ,p_bnft_nnmntry_uom               in  varchar2
  ,p_comp_lvl_cd                    in  varchar2
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_PRTT_ENRT_RESULT_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_PRTT_ENRT_RESULT_a
  (
   p_prtt_enrt_rslt_id              in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_business_group_id              in  number
  ,p_oipl_id                        in  number
  ,p_person_id                      in  number
  ,p_assignment_id                  in  number
  ,p_pgm_id                         in  number
  ,p_pl_id                          in  number
  ,p_rplcs_sspndd_rslt_id           in  number
  ,p_ptip_id                        in  number
  ,p_pl_typ_id                      in  number
  ,p_ler_id                         in  number
  ,p_sspndd_flag                    in  varchar2
  ,p_prtt_is_cvrd_flag              in  varchar2
  ,p_bnft_amt                       in  number
  ,p_uom                            in  varchar2
  ,p_orgnl_enrt_dt                  in  date
  ,p_enrt_mthd_cd                   in  varchar2
  ,p_no_lngr_elig_flag              in  varchar2
  ,p_enrt_ovridn_flag               in  varchar2
  ,p_enrt_ovrid_rsn_cd              in  varchar2
  ,p_erlst_deenrt_dt                in  date
  ,p_enrt_cvg_strt_dt               in  date
  ,p_enrt_cvg_thru_dt               in  date
  ,p_enrt_ovrid_thru_dt             in  date
  ,p_pl_ordr_num                    in  number
  ,p_plip_ordr_num                  in  number
  ,p_ptip_ordr_num                  in  number
  ,p_oipl_ordr_num                  in  number
  ,p_pen_attribute_category         in  varchar2
  ,p_pen_attribute1                 in  varchar2
  ,p_pen_attribute2                 in  varchar2
  ,p_pen_attribute3                 in  varchar2
  ,p_pen_attribute4                 in  varchar2
  ,p_pen_attribute5                 in  varchar2
  ,p_pen_attribute6                 in  varchar2
  ,p_pen_attribute7                 in  varchar2
  ,p_pen_attribute8                 in  varchar2
  ,p_pen_attribute9                 in  varchar2
  ,p_pen_attribute10                in  varchar2
  ,p_pen_attribute11                in  varchar2
  ,p_pen_attribute12                in  varchar2
  ,p_pen_attribute13                in  varchar2
  ,p_pen_attribute14                in  varchar2
  ,p_pen_attribute15                in  varchar2
  ,p_pen_attribute16                in  varchar2
  ,p_pen_attribute17                in  varchar2
  ,p_pen_attribute18                in  varchar2
  ,p_pen_attribute19                in  varchar2
  ,p_pen_attribute20                in  varchar2
  ,p_pen_attribute21                in  varchar2
  ,p_pen_attribute22                in  varchar2
  ,p_pen_attribute23                in  varchar2
  ,p_pen_attribute24                in  varchar2
  ,p_pen_attribute25                in  varchar2
  ,p_pen_attribute26                in  varchar2
  ,p_pen_attribute27                in  varchar2
  ,p_pen_attribute28                in  varchar2
  ,p_pen_attribute29                in  varchar2
  ,p_pen_attribute30                in  varchar2
  ,p_request_id                     in  number
  ,p_program_application_id         in  number
  ,p_program_id                     in  number
  ,p_program_update_date            in  date
  ,p_object_version_number          in  number
  ,p_per_in_ler_id                  in  number
  ,p_bnft_typ_cd                    in  varchar2
  ,p_bnft_ordr_num                  in  number
  ,p_prtt_enrt_rslt_stat_cd         in  varchar2
  ,p_bnft_nnmntry_uom               in  varchar2
  ,p_comp_lvl_cd                    in  varchar2
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
end ben_PRTT_ENRT_RESULT_bk2;

/
