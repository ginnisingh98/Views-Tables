--------------------------------------------------------
--  DDL for Package BEN_PRTT_ENRT_RESULT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PRTT_ENRT_RESULT_API" AUTHID CURRENT_USER as
/* $Header: bepenapi.pkh 120.2.12010000.1 2008/07/29 12:46:49 appldev ship $ */
--
-- Global Variables:
--
g_multi_rows_validate boolean := TRUE;
-- g_debug               boolean := FALSE;
g_enrollment_change   boolean := FALSE;
-- ----------------------------------------------------------------------------
-- |------------------------< get_ben_pen_upd_dt_mode >------------------------|
-- ----------------------------------------------------------------------------
procedure get_ben_pen_upd_dt_mode
                  (p_effective_date         in     date
                  ,p_base_key_value         in     number
                  ,P_desired_datetrack_mode in     varchar2
                  ,P_datetrack_allow        in out nocopy varchar2
                  ,p_ler_typ_cd             in     varchar2 default null
                  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_enrollment >------------------------|
-- ----------------------------------------------------------------------------
-- Description: Business Process on top of Create_Prtt_Enrt_Rslt procedure.
--     This process handle electable choice table.
--
-- Prerequisites:
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_prtt_enrt_rslt_id            Yes  number   PK of record
--   p_effective_start_date         Yes  date     Effective Start Date of Record
--   p_effective_end_date           Yes  date     Effective End Date of Record
--   p_object_version_number        No   number   OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_enrollment
  (p_validate                       in boolean    default false
  ,p_prtt_enrt_rslt_id              out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default null
  ,p_oipl_id                        in  number    default null
  ,p_person_id                      in  number    default null
  ,p_assignment_id                  in  number    default null
  ,p_pgm_id                         in  number    default null
  ,p_pl_id                          in  number    default null
  ,p_rplcs_sspndd_rslt_id           in  number    default null
  ,p_ptip_id                        in  number    default null
  ,p_pl_typ_id                      in  number    default null
  ,p_ler_id                         in  number    default null
  ,p_sspndd_flag                    in  varchar2  default 'N'
  ,p_called_from_sspnd              in  varchar2  default 'N'
  ,p_prtt_is_cvrd_flag              in  varchar2  default 'N'
  ,p_bnft_amt                       in  number    default null
  ,p_uom                            in  varchar2  default null
  ,p_orgnl_enrt_dt                  in  date      default null
  ,p_enrt_mthd_cd                   in  varchar2  default null
  ,p_enrt_ovridn_flag               in  varchar2  default 'N'
  ,p_enrt_ovrid_rsn_cd              in  varchar2  default null
  ,p_erlst_deenrt_dt                in  date      default null
  ,p_enrt_cvg_strt_dt               in  date      default null
  ,p_enrt_cvg_thru_dt               in  date      default hr_api.g_eot
  ,p_enrt_ovrid_thru_dt             in  date      default null
  ,p_pl_ordr_num                    in  number    default null
  ,p_plip_ordr_num                  in  number    default null
  ,p_ptip_ordr_num                  in  number    default null
  ,p_oipl_ordr_num                  in  number    default null
  ,p_pen_attribute_category         in  varchar2  default null
  ,p_pen_attribute1                 in  varchar2  default null
  ,p_pen_attribute2                 in  varchar2  default null
  ,p_pen_attribute3                 in  varchar2  default null
  ,p_pen_attribute4                 in  varchar2  default null
  ,p_pen_attribute5                 in  varchar2  default null
  ,p_pen_attribute6                 in  varchar2  default null
  ,p_pen_attribute7                 in  varchar2  default null
  ,p_pen_attribute8                 in  varchar2  default null
  ,p_pen_attribute9                 in  varchar2  default null
  ,p_pen_attribute10                in  varchar2  default null
  ,p_pen_attribute11                in  varchar2  default null
  ,p_pen_attribute12                in  varchar2  default null
  ,p_pen_attribute13                in  varchar2  default null
  ,p_pen_attribute14                in  varchar2  default null
  ,p_pen_attribute15                in  varchar2  default null
  ,p_pen_attribute16                in  varchar2  default null
  ,p_pen_attribute17                in  varchar2  default null
  ,p_pen_attribute18                in  varchar2  default null
  ,p_pen_attribute19                in  varchar2  default null
  ,p_pen_attribute20                in  varchar2  default null
  ,p_pen_attribute21                in  varchar2  default null
  ,p_pen_attribute22                in  varchar2  default null
  ,p_pen_attribute23                in  varchar2  default null
  ,p_pen_attribute24                in  varchar2  default null
  ,p_pen_attribute25                in  varchar2  default null
  ,p_pen_attribute26                in  varchar2  default null
  ,p_pen_attribute27                in  varchar2  default null
  ,p_pen_attribute28                in  varchar2  default null
  ,p_pen_attribute29                in  varchar2  default null
  ,p_pen_attribute30                in  varchar2  default null
  ,p_request_id                     in  number    default null
  ,p_program_application_id         in  number    default null
  ,p_program_id                     in  number    default null
  ,p_program_update_date            in  date      default null
  ,p_object_version_number          out nocopy number
  ,p_per_in_ler_id                  in  number    default null
  ,p_bnft_typ_cd                    in  varchar2  default null
  ,p_bnft_ordr_num                  in  number    default null
  ,p_prtt_enrt_rslt_stat_cd         in  varchar2  default null
  ,p_bnft_nnmntry_uom               in  varchar2  default null
  ,p_comp_lvl_cd                    in  varchar2  default null
  ,p_effective_date                 in  date
  ,p_multi_row_validate             in  boolean   default TRUE
  ,p_elig_per_elctbl_chc_id         in  number
  ,p_prtt_enrt_rslt_id_o            in  number
  ,p_suspend_flag                   out nocopy varchar2
  ,p_prtt_enrt_interim_id           out nocopy number
  ,p_datetrack_mode                 in  varchar2
  ,p_dpnt_actn_warning              out nocopy boolean
  ,p_bnf_actn_warning               out nocopy boolean
  ,p_ctfn_actn_warning              out nocopy boolean
  ,p_enrt_bnft_id                   in  Number    default null
  ,p_source                         in  varchar2 default null
 );
-- ----------------------------------------------------------------------------
-- |------------------------< create_PRTT_ENRT_RESULT >------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--
-- Prerequisites:
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--   p_business_group_id            Yes  number    Business Group of Record
--   p_oipl_id                      No   number
--   p_person_id                    Yes  number
--   p_assignment_id                No   number
--   p_pgm_id                       No   number
--   p_pl_id                        Yes  number
--   p_rplcs_sspndd_rslt_id         No   number
--   p_ptip_id                      No   number
--   p_pl_typ_id                    No   number
--   p_ler_id                       Yes  number
--   p_sspndd_flag                  Yes  varchar2
--   p_prtt_is_cvrd_flag            Yes  varchar2
--   p_bnft_amt                     No   number
--   p_uom                          No   varchar2
--   p_orgnl_enrt_dt                No   date
--   p_enrt_mthd_cd                 Yes  varchar2
--   p_no_lngr_elig_flag            No   varchar2
--   p_enrt_ovridn_flag             Yes  varchar2
--   p_enrt_ovrid_rsn_cd            No   varchar2
--   p_erlst_deenrt_dt              No   date
--   p_enrt_cvg_strt_dt             No   date
--   p_enrt_cvg_thru_dt             No   date
--   p_enrt_ovrid_thru_dt           No   date
--   p_pen_attribute_category       No   varchar2  Descriptive Flexfield
--   p_pen_attribute1               No   varchar2  Descriptive Flexfield
--   p_pen_attribute2               No   varchar2  Descriptive Flexfield
--   p_pen_attribute3               No   varchar2  Descriptive Flexfield
--   p_pen_attribute4               No   varchar2  Descriptive Flexfield
--   p_pen_attribute5               No   varchar2  Descriptive Flexfield
--   p_pen_attribute6               No   varchar2  Descriptive Flexfield
--   p_pen_attribute7               No   varchar2  Descriptive Flexfield
--   p_pen_attribute8               No   varchar2  Descriptive Flexfield
--   p_pen_attribute9               No   varchar2  Descriptive Flexfield
--   p_pen_attribute10              No   varchar2  Descriptive Flexfield
--   p_pen_attribute11              No   varchar2  Descriptive Flexfield
--   p_pen_attribute12              No   varchar2  Descriptive Flexfield
--   p_pen_attribute13              No   varchar2  Descriptive Flexfield
--   p_pen_attribute14              No   varchar2  Descriptive Flexfield
--   p_pen_attribute15              No   varchar2  Descriptive Flexfield
--   p_pen_attribute16              No   varchar2  Descriptive Flexfield
--   p_pen_attribute17              No   varchar2  Descriptive Flexfield
--   p_pen_attribute18              No   varchar2  Descriptive Flexfield
--   p_pen_attribute19              No   varchar2  Descriptive Flexfield
--   p_pen_attribute20              No   varchar2  Descriptive Flexfield
--   p_pen_attribute21              No   varchar2  Descriptive Flexfield
--   p_pen_attribute22              No   varchar2  Descriptive Flexfield
--   p_pen_attribute23              No   varchar2  Descriptive Flexfield
--   p_pen_attribute24              No   varchar2  Descriptive Flexfield
--   p_pen_attribute25              No   varchar2  Descriptive Flexfield
--   p_pen_attribute26              No   varchar2  Descriptive Flexfield
--   p_pen_attribute27              No   varchar2  Descriptive Flexfield
--   p_pen_attribute28              No   varchar2  Descriptive Flexfield
--   p_pen_attribute29              No   varchar2  Descriptive Flexfield
--   p_pen_attribute30              No   varchar2  Descriptive Flexfield
--   p_request_id                   No   number
--   p_program_application_id       No   number
--   p_program_id                   No   number
--   p_program_update_date          No   date
--   p_effective_date               Yes  date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_prtt_enrt_rslt_id            Yes  number   PK of record
--   p_effective_start_date         Yes  date     Effective Start Date of Record
--   p_effective_end_date           Yes  date     Effective End Date of Record
--   p_object_version_number        No   number   OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_PRTT_ENRT_RESULT
(
   p_validate                       in boolean    default false
  ,p_prtt_enrt_rslt_id              out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default null
  ,p_oipl_id                        in  number    default null
  ,p_person_id                      in  number    default null
  ,p_assignment_id                  in  number    default null
  ,p_pgm_id                         in  number    default null
  ,p_pl_id                          in  number    default null
  ,p_rplcs_sspndd_rslt_id           in  number    default null
  ,p_ptip_id                        in  number    default null
  ,p_pl_typ_id                      in  number    default null
  ,p_ler_id                         in  number    default null
  ,p_sspndd_flag                    in  varchar2  default 'N'
  ,p_prtt_is_cvrd_flag              in  varchar2  default 'N'
  ,p_bnft_amt                       in  number    default null
  ,p_uom                            in  varchar2  default null
  ,p_orgnl_enrt_dt                  in  date      default null
  ,p_enrt_mthd_cd                   in  varchar2  default null
  ,p_no_lngr_elig_flag              in  varchar2  default 'N'
  ,p_enrt_ovridn_flag               in  varchar2  default 'N'
  ,p_enrt_ovrid_rsn_cd              in  varchar2  default null
  ,p_erlst_deenrt_dt                in  date      default null
  ,p_enrt_cvg_strt_dt               in  date      default null
  ,p_enrt_cvg_thru_dt               in  date      default hr_api.g_eot
  ,p_enrt_ovrid_thru_dt             in  date      default null
  ,p_pl_ordr_num                    in  number    default null
  ,p_plip_ordr_num                  in  number    default null
  ,p_ptip_ordr_num                  in  number    default null
  ,p_oipl_ordr_num                  in  number    default null
  ,p_pen_attribute_category         in  varchar2  default null
  ,p_pen_attribute1                 in  varchar2  default null
  ,p_pen_attribute2                 in  varchar2  default null
  ,p_pen_attribute3                 in  varchar2  default null
  ,p_pen_attribute4                 in  varchar2  default null
  ,p_pen_attribute5                 in  varchar2  default null
  ,p_pen_attribute6                 in  varchar2  default null
  ,p_pen_attribute7                 in  varchar2  default null
  ,p_pen_attribute8                 in  varchar2  default null
  ,p_pen_attribute9                 in  varchar2  default null
  ,p_pen_attribute10                in  varchar2  default null
  ,p_pen_attribute11                in  varchar2  default null
  ,p_pen_attribute12                in  varchar2  default null
  ,p_pen_attribute13                in  varchar2  default null
  ,p_pen_attribute14                in  varchar2  default null
  ,p_pen_attribute15                in  varchar2  default null
  ,p_pen_attribute16                in  varchar2  default null
  ,p_pen_attribute17                in  varchar2  default null
  ,p_pen_attribute18                in  varchar2  default null
  ,p_pen_attribute19                in  varchar2  default null
  ,p_pen_attribute20                in  varchar2  default null
  ,p_pen_attribute21                in  varchar2  default null
  ,p_pen_attribute22                in  varchar2  default null
  ,p_pen_attribute23                in  varchar2  default null
  ,p_pen_attribute24                in  varchar2  default null
  ,p_pen_attribute25                in  varchar2  default null
  ,p_pen_attribute26                in  varchar2  default null
  ,p_pen_attribute27                in  varchar2  default null
  ,p_pen_attribute28                in  varchar2  default null
  ,p_pen_attribute29                in  varchar2  default null
  ,p_pen_attribute30                in  varchar2  default null
  ,p_request_id                     in  number    default null
  ,p_program_application_id         in  number    default null
  ,p_program_id                     in  number    default null
  ,p_program_update_date            in  date      default null
  ,p_object_version_number          out nocopy number
  ,p_per_in_ler_id                  in  number    default null
  ,p_bnft_typ_cd                    in  varchar2  default null
  ,p_bnft_ordr_num                  in  number    default null
  ,p_prtt_enrt_rslt_stat_cd         in  varchar2  default null
  ,p_bnft_nnmntry_uom               in  varchar2  default null
  ,p_comp_lvl_cd                    in  varchar2  default null
  ,p_effective_date                 in  date
  ,p_multi_row_validate             in  boolean    default TRUE
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_ENROLLMENT >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
-- In Parameters:
--
-- Post Success:
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_ENROLLMENT
  (
   p_validate                       in boolean    default false
  ,p_prtt_enrt_rslt_id              in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_oipl_id                        in  number    default hr_api.g_number
  ,p_person_id                      in  number    default hr_api.g_number
  ,p_assignment_id                  in  number    default hr_api.g_number
  ,p_pgm_id                         in  number    default hr_api.g_number
  ,p_pl_id                          in  number    default hr_api.g_number
  ,p_rplcs_sspndd_rslt_id           in  number    default hr_api.g_number
  ,p_ptip_id                        in  number    default hr_api.g_number
  ,p_pl_typ_id                      in  number    default hr_api.g_number
  ,p_ler_id                         in  number    default hr_api.g_number
  ,p_sspndd_flag                    in  varchar2  default hr_api.g_varchar2
  ,p_prtt_is_cvrd_flag              in  varchar2  default hr_api.g_varchar2
  ,p_enrt_bnft_id                   in  number    default NULL
  ,p_bnft_amt                       in  number    default hr_api.g_number
  ,p_uom                            in  varchar2  default hr_api.g_varchar2
  ,p_orgnl_enrt_dt                  in  date      default hr_api.g_date
  ,p_enrt_mthd_cd                   in  varchar2  default hr_api.g_varchar2
  ,p_enrt_ovridn_flag               in  varchar2  default hr_api.g_varchar2
  ,p_enrt_ovrid_rsn_cd              in  varchar2  default hr_api.g_varchar2
  ,p_erlst_deenrt_dt                in  date      default hr_api.g_date
  ,p_enrt_cvg_strt_dt               in  date      default hr_api.g_date
  ,p_enrt_cvg_thru_dt               in  date      default hr_api.g_date
  ,p_enrt_ovrid_thru_dt             in  date      default hr_api.g_date
  ,p_pl_ordr_num                    in  number    default hr_api.g_number
  ,p_plip_ordr_num                  in  number    default hr_api.g_number
  ,p_ptip_ordr_num                  in  number    default hr_api.g_number
  ,p_oipl_ordr_num                  in  number    default hr_api.g_number
  ,p_pen_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_request_id                     in  number    default hr_api.g_number
  ,p_program_application_id         in  number    default hr_api.g_number
  ,p_program_id                     in  number    default hr_api.g_number
  ,p_program_update_date            in  date      default hr_api.g_date
  ,p_object_version_number          in  out nocopy number
  ,p_per_in_ler_id                  in  number    default hr_api.g_number
  ,p_bnft_typ_cd                    in  varchar2  default hr_api.g_varchar2
  ,p_bnft_ordr_num                  in  number    default hr_api.g_number
  ,p_prtt_enrt_rslt_stat_cd         in  varchar2  default hr_api.g_varchar2
  ,p_bnft_nnmntry_uom               in  varchar2  default hr_api.g_varchar2
  ,p_comp_lvl_cd                    in  varchar2  default hr_api.g_varchar2
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ,p_multi_row_validate             in  boolean    default TRUE
  ,p_suspend_flag                   out nocopy varchar2
  ,p_prtt_enrt_interim_id           out nocopy number
  ,p_dpnt_actn_warning              out nocopy boolean
  ,p_bnf_actn_warning               out nocopy boolean
  ,p_ctfn_actn_warning              out nocopy boolean
  );
-- ----------------------------------------------------------------------------
-- |------------------------< update_PRTT_ENRT_RESULT >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--   p_prtt_enrt_rslt_id            Yes  number    PK of record
--   p_business_group_id            Yes  number    Business Group of Record
--   p_oipl_id                      No   number
--   p_person_id                    Yes  number
--   p_assignment_id                No   number
--   p_pgm_id                       No   number
--   p_pl_id                        Yes  number
--   p_rplcs_sspndd_rslt_id         No   number
--   p_ptip_id                      No   number
--   p_pl_typ_id                    No   number
--   p_ler_id                       Yes  number
--   p_sspndd_flag                  Yes  varchar2
--   p_prtt_is_cvrd_flag            Yes  varchar2
--   p_bnft_amt                     No   number
--   p_uom                          No   varchar2
--   p_orgnl_enrt_dt                No   date
--   p_enrt_mthd_cd                 Yes  varchar2
--   p_no_lngr_elig_flag            No   varchar2
--   p_enrt_ovridn_flag             Yes  varchar2
--   p_enrt_ovrid_rsn_cd            No   varchar2
--   p_erlst_deenrt_dt              No   date
--   p_enrt_cvg_strt_dt             No   date
--   p_enrt_cvg_thru_dt             No   date
--   p_enrt_ovrid_thru_dt           No   date
--   p_pen_attribute_category       No   varchar2  Descriptive Flexfield
--   p_pen_attribute1               No   varchar2  Descriptive Flexfield
--   p_pen_attribute2               No   varchar2  Descriptive Flexfield
--   p_pen_attribute3               No   varchar2  Descriptive Flexfield
--   p_pen_attribute4               No   varchar2  Descriptive Flexfield
--   p_pen_attribute5               No   varchar2  Descriptive Flexfield
--   p_pen_attribute6               No   varchar2  Descriptive Flexfield
--   p_pen_attribute7               No   varchar2  Descriptive Flexfield
--   p_pen_attribute8               No   varchar2  Descriptive Flexfield
--   p_pen_attribute9               No   varchar2  Descriptive Flexfield
--   p_pen_attribute10              No   varchar2  Descriptive Flexfield
--   p_pen_attribute11              No   varchar2  Descriptive Flexfield
--   p_pen_attribute12              No   varchar2  Descriptive Flexfield
--   p_pen_attribute13              No   varchar2  Descriptive Flexfield
--   p_pen_attribute14              No   varchar2  Descriptive Flexfield
--   p_pen_attribute15              No   varchar2  Descriptive Flexfield
--   p_pen_attribute16              No   varchar2  Descriptive Flexfield
--   p_pen_attribute17              No   varchar2  Descriptive Flexfield
--   p_pen_attribute18              No   varchar2  Descriptive Flexfield
--   p_pen_attribute19              No   varchar2  Descriptive Flexfield
--   p_pen_attribute20              No   varchar2  Descriptive Flexfield
--   p_pen_attribute21              No   varchar2  Descriptive Flexfield
--   p_pen_attribute22              No   varchar2  Descriptive Flexfield
--   p_pen_attribute23              No   varchar2  Descriptive Flexfield
--   p_pen_attribute24              No   varchar2  Descriptive Flexfield
--   p_pen_attribute25              No   varchar2  Descriptive Flexfield
--   p_pen_attribute26              No   varchar2  Descriptive Flexfield
--   p_pen_attribute27              No   varchar2  Descriptive Flexfield
--   p_pen_attribute28              No   varchar2  Descriptive Flexfield
--   p_pen_attribute29              No   varchar2  Descriptive Flexfield
--   p_pen_attribute30              No   varchar2  Descriptive Flexfield
--   p_request_id                   No   number
--   p_program_application_id       No   number
--   p_program_id                   No   number
--   p_program_update_date          No   date
--   p_effective_date               Yes  date       Session Date.
--   p_datetrack_mode               Yes  varchar2   Datetrack mode.
--
-- Post Success:
--
--   Name                           Type     Description
--   p_effective_start_date         Yes  date      Effective Start Date of Record
--   p_effective_end_date           Yes  date      Effective End Date of Record
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_PRTT_ENRT_RESULT
  (
   p_validate                       in boolean    default false
  ,p_prtt_enrt_rslt_id              in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_oipl_id                        in  number    default hr_api.g_number
  ,p_person_id                      in  number    default hr_api.g_number
  ,p_assignment_id                  in  number    default hr_api.g_number
  ,p_pgm_id                         in  number    default hr_api.g_number
  ,p_pl_id                          in  number    default hr_api.g_number
  ,p_rplcs_sspndd_rslt_id           in  number    default hr_api.g_number
  ,p_ptip_id                        in  number    default hr_api.g_number
  ,p_pl_typ_id                      in  number    default hr_api.g_number
  ,p_ler_id                         in  number    default hr_api.g_number
  ,p_sspndd_flag                    in  varchar2  default hr_api.g_varchar2
  ,p_prtt_is_cvrd_flag              in  varchar2  default hr_api.g_varchar2
  ,p_bnft_amt                       in  number    default hr_api.g_number
  ,p_uom                            in  varchar2  default hr_api.g_varchar2
  ,p_orgnl_enrt_dt                  in  date      default hr_api.g_date
  ,p_enrt_mthd_cd                   in  varchar2  default hr_api.g_varchar2
  ,p_no_lngr_elig_flag              in  varchar2  default hr_api.g_varchar2
  ,p_enrt_ovridn_flag               in  varchar2  default hr_api.g_varchar2
  ,p_enrt_ovrid_rsn_cd              in  varchar2  default hr_api.g_varchar2
  ,p_erlst_deenrt_dt                in  date      default hr_api.g_date
  ,p_enrt_cvg_strt_dt               in  date      default hr_api.g_date
  ,p_enrt_cvg_thru_dt               in  date      default hr_api.g_date
  ,p_enrt_ovrid_thru_dt             in  date      default hr_api.g_date
  ,p_pl_ordr_num                    in  number    default hr_api.g_number
  ,p_plip_ordr_num                  in  number    default hr_api.g_number
  ,p_ptip_ordr_num                  in  number    default hr_api.g_number
  ,p_oipl_ordr_num                  in  number    default hr_api.g_number
  ,p_pen_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_request_id                     in  number    default hr_api.g_number
  ,p_program_application_id         in  number    default hr_api.g_number
  ,p_program_id                     in  number    default hr_api.g_number
  ,p_program_update_date            in  date      default hr_api.g_date
  ,p_object_version_number          in out nocopy number
  ,p_per_in_ler_id                  in  number    default hr_api.g_number
  ,p_bnft_typ_cd                    in  varchar2  default hr_api.g_varchar2
  ,p_bnft_ordr_num                  in  number    default hr_api.g_number
  ,p_prtt_enrt_rslt_stat_cd         in  varchar2  default hr_api.g_varchar2
  ,p_bnft_nnmntry_uom               in  varchar2  default hr_api.g_varchar2
  ,p_comp_lvl_cd                    in  varchar2  default hr_api.g_varchar2
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ,p_multi_row_validate             in boolean    default TRUE
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< void_enrollment >-------------------------------|
-- ----------------------------------------------------------------------------

procedure void_enrollment
  (p_validate                in      boolean   default false
  ,p_per_in_ler_id           in      number
  ,p_prtt_enrt_rslt_id       in      number
  ,p_business_group_id       in      number
  ,p_enrt_cvg_strt_dt        in      date      default null
  ,p_person_id               in      number    default null
  ,p_elig_per_elctbl_chc_id  in      number    default null
  ,p_epe_ovn                 in      number    default null
  ,p_object_version_number   in      number    default null
  ,p_effective_date          in      date
  ,p_datetrack_mode          in      varchar2
  ,p_multi_row_validate      in      boolean   default TRUE
  ,p_source                  in      varchar2  default null
  ,p_enrt_bnft_id            in      number    default null);

-- ----------------------------------------------------------------------------
-- |------------------------< delete_enrollment >------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--   p_prtt_enrt_rslt_id            Yes  number    PK of record
--   p_effective_date               Yes  date     Session Date.
--   p_datetrack_mode               Yes  varchar2 Datetrack mode.
--
-- Post Success:
--
--   Name                           Type        Description
--   p_effective_start_date         Yes  date   Effective Start Date of Record
--   p_effective_end_date           Yes  date   Effective End Date of Record
--   p_object_version_number        No   number OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
--
procedure delete_enrollment
  (
   p_validate                in     boolean    default false
  ,p_per_in_ler_id           in     number     default NULL
  ,p_lee_rsn_id              in     number     default NULL
  ,p_enrt_perd_id            in     number     default NULL
  ,p_prtt_enrt_rslt_id       in     number
  ,p_business_group_id       in     number
  ,p_effective_start_date       out nocopy date
  ,p_effective_end_date         out nocopy date
  ,p_object_version_number   in out nocopy number
  ,p_effective_date          in     date
  ,p_datetrack_mode          in     varchar2
  ,p_multi_row_validate      in     boolean    default TRUE
  ,p_source                  in  varchar2 default null
  ,p_enrt_cvg_thru_dt        in  date     default null
  ,p_mode                    in varchar2  default null
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_enrollment_w >------------------------|
-- ----------------------------------------------------------------------------
--
-- Description: Self-Service Wrapper procedure to handle exception
--              while calling delete_enrollment from SS
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--   p_prtt_enrt_rslt_id            Yes  number    PK of record
--   p_effective_date               Yes  date     Session Date.
--   p_datetrack_mode               Yes  varchar2 Datetrack mode.
--
-- Post Success:
--
--   Name                           Type        Description
--   p_effective_start_date         Yes  date   Effective Start Date of Record
--   p_effective_end_date           Yes  date   Effective End Date of Record
--   p_object_version_number        No   number OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
--
procedure delete_enrollment_w
  (
   p_validate                in     boolean    default false
  ,p_per_in_ler_id           in     number     default NULL
  ,p_lee_rsn_id              in     number     default NULL
  ,p_enrt_perd_id            in     number     default NULL
  ,p_prtt_enrt_rslt_id       in     number
  ,p_business_group_id       in     number
  ,p_effective_start_date       out nocopy date
  ,p_effective_end_date         out nocopy date
  ,p_object_version_number   in out nocopy number
  ,p_effective_date          in     date
  ,p_datetrack_mode          in     varchar2
  ,p_multi_row_validate      in     boolean    default TRUE
  ,p_source                  in  varchar2 default null
  ,p_enrt_cvg_thru_dt        in  date     default null
  ,p_mode                    in varchar2  default null
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_PRTT_ENRT_RESULT >------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--   p_prtt_enrt_rslt_id            Yes  number    PK of record
--   p_effective_date               Yes  date     Session Date.
--   p_datetrack_mode               Yes  varchar2 Datetrack mode.
--
-- Post Success:
--
--   Name                           Type     Description
--   p_effective_start_date         Yes  date      Effective Start Date of Record
--   p_effective_end_date           Yes  date      Effective End Date of Record
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_PRTT_ENRT_RESULT
  (
   p_validate               in     boolean default false
  ,p_prtt_enrt_rslt_id      in     number
  ,p_effective_start_date      out nocopy date
  ,p_effective_end_date        out nocopy date
  ,p_object_version_number  in out nocopy number
  ,p_effective_date         in     date
  ,p_datetrack_mode         in     varchar2
  ,p_multi_row_validate     in     boolean default TRUE
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------------< lck >---------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_prtt_enrt_rslt_id            Yes  number   PK of record
--   p_object_version_number        Yes  number   OVN of record
--   p_effective_date               Yes  date     Session Date.
--   p_datetrack_mode               Yes  varchar2 Datetrack mode.
--
-- Post Success:
--
--   Name                           Type     Description
--   p_validation_start_date        Yes      Derived Effective Start Date.
--   p_validation_end_date          Yes      Derived Effective End Date.
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure lck
  (
    p_prtt_enrt_rslt_id       in     number
   ,p_object_version_number   in     number
   ,p_effective_date          in     date
   ,p_datetrack_mode          in     varchar2
   ,p_validation_start_date      out nocopy date
   ,p_validation_end_date        out nocopy date
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------------< multi_row_edit >---------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   This procedure will invoke the multi row edit procedure in Row handler
--
-- Prerequisites:
--   All rows must be enrolled or de-enrolled before this procedure is called.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_person_id                    Yes  number   Person ID
--   p_effective_date               Yes  date
--   p_business_group_id          Yes  number
--   p_pgm_id                     Yes  number
--   p_per_in_ler_id                No   Number
--
-- Post Success:
--
--   Name                           Type     Description
--   p_validation_start_date        Yes      Derived Effective Start Date.
--   p_validation_end_date          Yes      Derived Effective End Date.
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
--
procedure multi_rows_edit
  (p_person_id              in number,
   p_effective_date         in date,
   p_business_group_id      in number,
   p_pgm_id                 in number,
   p_per_in_ler_id          in number default NULL,
   p_include_erl            in varchar2,
   p_called_frm_ss          in Boolean default FALSE
  );
--
-- Overloaded
--
procedure multi_rows_edit
  (p_person_id              in number,
   p_effective_date         in date,
   p_business_group_id      in number,
   p_pgm_id                 in number,
   p_per_in_ler_id          in number default NULL,
   p_called_frm_ss          in Boolean default FALSE
  );

--Start Bug 5768795
procedure chk_coverage_across_plan_types
(  p_person_id              in number,
   p_effective_date         in date,
   p_lf_evt_ocrd_dt         in date,
   p_business_group_id      in number,
   p_pgm_id                 in number,
   p_minimum_check_flag     in varchar default 'Y',
   p_suspended_enrt_check_flag in varchar default 'Y');
--End Bug 5768795
--
-- ----------------------------------------------------------------------------
-- |-------------------------< calc_dpnt_cvg_dt >------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   This procedure will calculate the coverage end date and Rate end date.
--
-- Prerequisites:
--  Elig_elctbl_chc_Id or all Comp. objects and per_in_ler_id passed
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_calc_end_dt                  No    boolean
--   P_calc_strt_dt                 No    boolean
--   P_per_in_ler_id                No    Number
--   p_person_id                    No    number
--   p_pgm_id                       No    number
--   p_pl_id                        No    number
--   p_oipl_id                      No    number
--   p_ptip_id                      No    number
--   p_ler_id                       No    number
--   p_elig_per_elctbl_chc_id       No    number
--   p_enrt_cvg_end_dt              No    date
--   p_business_group_id            Yes   number
--   p_effective_date               Yes   date
--
-- Post Success:
--
--   Name                           Type     Description
--   p_returned_strt_dt             date
--   p_returned_end_dt              date
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
--
procedure calc_dpnt_cvg_dt
         (p_calc_end_dt            in     boolean   default FALSE
         ,P_calc_strt_dt           in     boolean   default FALSE
         ,P_per_in_ler_id          in     number    default NULL
         ,p_person_id              in     number    default NULL
         ,p_pgm_id                 in     number  default NULL
         ,p_pl_id                  in     number  default NULL
         ,p_oipl_id                in     number  default NULL
         ,p_ptip_id                in     number  default NULL
         ,p_ler_id                 in     number  default NULL
         ,p_elig_per_elctbl_chc_id in     number  default NULL
         ,p_business_group_id      in     number
         ,p_effective_date         in     date
         ,p_enrt_cvg_end_dt        in     date          default NULL
         ,p_returned_strt_dt          out nocopy date
         ,p_returned_end_dt           out nocopy date
         );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< calc_dpnt_cvg_dt >------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   This procedure will calculate the coverage end date and Rate end date.
--
-- Prerequisites:
--  Elig_elctbl_chc_Id or all Comp. objects and per_in_ler_id passed
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_elig_per_elctbl_chc_id       No   number
--   p_pgm_id                       No   number
--   p_pl_id                        No   number
--   p_ptip_id                      No   number
--   p_ler_id                       No   number
--   p_effective_date               Yes  date
--   p_business_group_id            Yes  number
--
-- Post Success:
--
--   Name                           Type     Description
--   p_cvg_strt_cd                  varchar2
--   p_cvg_strt_rl                  number
--   p_cvg_end_cd                   varchar2
--   p_cvg_end_rl                   number
--
-- Post Failure:
--
-- Access Status:
--   Private.
--
--
procedure determine_dpnt_cvg_dt_cd
        (p_elig_per_elctbl_chc_id in     number default NULL
        ,p_pgm_id                 in     number default NULL
        ,p_pl_id                  in     number default NULL
        ,p_ptip_id                in     number default NULL
        ,p_ler_id                 in     number default NULL
        ,p_effective_date         in     date
        ,p_business_group_id      in     number
        ,p_cvg_strt_cd               out nocopy varchar2
        ,p_cvg_strt_rl               out nocopy number
        ,p_cvg_end_cd                out nocopy varchar2
        ,p_cvg_end_rl                out nocopy number
        );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< unhook_Bnf >---------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   This procedure will unhook all benificiary for the participant.
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     No   boolean
--   p_prtt_enrt_rslt_id            No   Number
--   p_business_group_id            No   Number
--   p_effective_date               Yes  date
--   p_datetrack_mode               Yes  varchar2
--
-- Post Success:
--
--   Name                           Type     Description
--
-- Post Failure:
--
-- Access Status:
--   Private.
--
--
Procedure unhook_bnf
  (p_validate          in boolean default FALSE
  ,p_prtt_enrt_rslt_id in number
  ,p_per_in_ler_id     in number
  ,p_dsgn_thru_dt      in date
  ,p_business_group_id in number
  ,p_effective_date    in date
  ,p_datetrack_mode    in varchar2
  ,p_rslt_delete_flag  in     boolean default FALSE
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< unhook_Dpnt >--------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   This procedure will unhook all dependent for the participant.
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean
--   p_prtt_enrt_rslt_id            Yes  number
--   p_cvg_thru_dt              Yes  date
--   p_business_group_id            Yes  number
--   p_effective_date               Yes  date
--   p_datetrack_mode               Yes  varchar2
--
-- Post Success:
--
--   Name                           Type     Description
--
-- Post Failure:
--
-- Access Status:
--   Private.
--
--
Procedure unhook_dpnt
        (p_validate          in     boolean default FALSE
        ,p_prtt_enrt_rslt_id in     number
        ,p_per_in_ler_id     in     number
        ,p_cvg_thru_dt       in     date
        ,p_business_group_id in     number
        ,p_effective_date    in     date
        ,p_datetrack_mode    in     varchar2
        ,p_rslt_delete_flag  in     Boolean default FALSE
        ,p_called_from       in     varchar2 default 'bepenapi'
        );
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_person_type_usages >-----------------------|
-- ----------------------------------------------------------------------------
--
Procedure update_person_type_usages
        (p_person_id           in number
        ,p_business_group_id   in number
        ,p_effective_date      in date
        );
--
end ben_PRTT_ENRT_RESULT_api;

/
