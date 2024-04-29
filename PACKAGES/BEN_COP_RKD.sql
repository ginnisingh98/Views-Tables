--------------------------------------------------------
--  DDL for Package BEN_COP_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_COP_RKD" AUTHID CURRENT_USER as
/* $Header: becoprhi.pkh 120.0 2005/05/28 01:10:23 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_oipl_id                        in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_ivr_ident_o                    in varchar2
 ,p_url_ref_name_o                 in varchar2
 ,p_opt_id_o                       in number
 ,p_business_group_id_o            in number
 ,p_pl_id_o                        in number
 ,p_ordr_num_o                     in number
 ,p_rqd_perd_enrt_nenrt_val_o                     in number
 ,p_dflt_flag_o                    in varchar2
 ,p_actl_prem_id_o                 in number
 ,p_mndtry_flag_o                  in varchar2
 ,p_oipl_stat_cd_o                 in varchar2
 ,p_pcp_dsgn_cd_o                  in varchar2
 ,p_pcp_dpnt_dsgn_cd_o             in varchar2
 ,p_rqd_perd_enrt_nenrt_uom_o                 in varchar2
 ,p_elig_apls_flag_o               in varchar2
 ,p_dflt_enrt_det_rl_o             in number
 ,p_trk_inelig_per_flag_o          in varchar2
 ,p_drvbl_fctr_prtn_elig_flag_o    in varchar2
 ,p_mndtry_rl_o                    in number
 ,p_rqd_perd_enrt_nenrt_rl_o                    in number
 ,p_dflt_enrt_cd_o                 in varchar2
 ,p_prtn_elig_ovrid_alwd_flag_o    in varchar2
 ,p_drvbl_fctr_apls_rts_flag_o     in varchar2
 ,p_per_cvrd_cd_o                  in varchar2
 ,p_postelcn_edit_rl_o             in number
 ,p_vrfy_fmly_mmbr_cd_o            in varchar2
 ,p_vrfy_fmly_mmbr_rl_o            in number
 ,p_enrt_cd_o                      in varchar2
 ,p_enrt_rl_o                      in number
 ,p_auto_enrt_flag_o               in varchar2
 ,p_auto_enrt_mthd_rl_o            in number
 ,p_short_name_o		   in varchar2		/*FHR*/
 ,p_short_code_o		   in varchar2		/*FHR*/
  ,p_legislation_code_o		   in varchar2		/*FHR*/
  ,p_legislation_subgroup_o		   in varchar2		/*FHR*/
 ,p_hidden_flag_o		   in varchar2		/*CWB Itemization*/
 ,p_susp_if_ctfn_not_prvd_flag_o    in  varchar2
 ,p_ctfn_determine_cd_o        in  varchar2
 ,p_cop_attribute_category_o       in varchar2
 ,p_cop_attribute1_o               in varchar2
 ,p_cop_attribute2_o               in varchar2
 ,p_cop_attribute3_o               in varchar2
 ,p_cop_attribute4_o               in varchar2
 ,p_cop_attribute5_o               in varchar2
 ,p_cop_attribute6_o               in varchar2
 ,p_cop_attribute7_o               in varchar2
 ,p_cop_attribute8_o               in varchar2
 ,p_cop_attribute9_o               in varchar2
 ,p_cop_attribute10_o              in varchar2
 ,p_cop_attribute11_o              in varchar2
 ,p_cop_attribute12_o              in varchar2
 ,p_cop_attribute13_o              in varchar2
 ,p_cop_attribute14_o              in varchar2
 ,p_cop_attribute15_o              in varchar2
 ,p_cop_attribute16_o              in varchar2
 ,p_cop_attribute17_o              in varchar2
 ,p_cop_attribute18_o              in varchar2
 ,p_cop_attribute19_o              in varchar2
 ,p_cop_attribute20_o              in varchar2
 ,p_cop_attribute21_o              in varchar2
 ,p_cop_attribute22_o              in varchar2
 ,p_cop_attribute23_o              in varchar2
 ,p_cop_attribute24_o              in varchar2
 ,p_cop_attribute25_o              in varchar2
 ,p_cop_attribute26_o              in varchar2
 ,p_cop_attribute27_o              in varchar2
 ,p_cop_attribute28_o              in varchar2
 ,p_cop_attribute29_o              in varchar2
 ,p_cop_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_cop_rkd;

 

/
