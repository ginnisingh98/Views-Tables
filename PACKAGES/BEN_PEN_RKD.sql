--------------------------------------------------------
--  DDL for Package BEN_PEN_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PEN_RKD" AUTHID CURRENT_USER as
/* $Header: bepenrhi.pkh 120.1.12010000.1 2008/07/29 12:47:02 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_prtt_enrt_rslt_id              in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_business_group_id_o            in number
 ,p_oipl_id_o                      in number
 ,p_person_id_o                    in number
 ,p_assignment_id_o                in number
 ,p_pgm_id_o                       in number
 ,p_pl_id_o                        in number
 ,p_rplcs_sspndd_rslt_id_o         in number
 ,p_ptip_id_o                      in number
 ,p_pl_typ_id_o                    in number
 ,p_ler_id_o                       in number
 ,p_sspndd_flag_o                  in varchar2
 ,p_prtt_is_cvrd_flag_o            in varchar2
 ,p_bnft_amt_o                     in number
 ,p_uom_o                          in varchar2
 ,p_orgnl_enrt_dt_o                in date
 ,p_enrt_mthd_cd_o                 in varchar2
 ,p_no_lngr_elig_flag_o            in varchar2
 ,p_enrt_ovridn_flag_o             in varchar2
 ,p_enrt_ovrid_rsn_cd_o            in varchar2
 ,p_erlst_deenrt_dt_o              in date
 ,p_enrt_cvg_strt_dt_o             in date
 ,p_enrt_cvg_thru_dt_o             in date
 ,p_enrt_ovrid_thru_dt_o           in date
 ,p_pl_ordr_num_o                   in number
 ,p_plip_ordr_num_o                 in number
 ,p_ptip_ordr_num_o                 in number
 ,p_oipl_ordr_num_o                 in number
 ,p_pen_attribute_category_o       in varchar2
 ,p_pen_attribute1_o               in varchar2
 ,p_pen_attribute2_o               in varchar2
 ,p_pen_attribute3_o               in varchar2
 ,p_pen_attribute4_o               in varchar2
 ,p_pen_attribute5_o               in varchar2
 ,p_pen_attribute6_o               in varchar2
 ,p_pen_attribute7_o               in varchar2
 ,p_pen_attribute8_o               in varchar2
 ,p_pen_attribute9_o               in varchar2
 ,p_pen_attribute10_o              in varchar2
 ,p_pen_attribute11_o              in varchar2
 ,p_pen_attribute12_o              in varchar2
 ,p_pen_attribute13_o              in varchar2
 ,p_pen_attribute14_o              in varchar2
 ,p_pen_attribute15_o              in varchar2
 ,p_pen_attribute16_o              in varchar2
 ,p_pen_attribute17_o              in varchar2
 ,p_pen_attribute18_o              in varchar2
 ,p_pen_attribute19_o              in varchar2
 ,p_pen_attribute20_o              in varchar2
 ,p_pen_attribute21_o              in varchar2
 ,p_pen_attribute22_o              in varchar2
 ,p_pen_attribute23_o              in varchar2
 ,p_pen_attribute24_o              in varchar2
 ,p_pen_attribute25_o              in varchar2
 ,p_pen_attribute26_o              in varchar2
 ,p_pen_attribute27_o              in varchar2
 ,p_pen_attribute28_o              in varchar2
 ,p_pen_attribute29_o              in varchar2
 ,p_pen_attribute30_o              in varchar2
 ,p_request_id_o                   in number
 ,p_program_application_id_o       in number
 ,p_program_id_o                   in number
 ,p_program_update_date_o          in date
 ,p_object_version_number_o        in number
 ,p_per_in_ler_id_o                in number
 ,p_bnft_typ_cd_o                  in varchar2
 ,p_bnft_ordr_num_o                in number
 ,p_prtt_enrt_rslt_stat_cd_o       in varchar2
 ,p_bnft_nnmntry_uom_o             in varchar2
 ,p_comp_lvl_cd_o                  in varchar2
 );
--
end ben_pen_rkd;

/
