--------------------------------------------------------
--  DDL for Package BEN_COP_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_COP_RKI" AUTHID CURRENT_USER as
/* $Header: becoprhi.pkh 120.0 2005/05/28 01:10:23 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_oipl_id                        in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_ivr_ident                      in varchar2
 ,p_url_ref_name                   in varchar2
 ,p_opt_id                         in number
 ,p_business_group_id              in number
 ,p_pl_id                          in number
 ,p_ordr_num                       in number
 ,p_rqd_perd_enrt_nenrt_val                       in number
 ,p_dflt_flag                      in varchar2
 ,p_actl_prem_id                   in number
 ,p_mndtry_flag                    in varchar2
 ,p_oipl_stat_cd                   in varchar2
 ,p_pcp_dsgn_cd                    in varchar2
 ,p_pcp_dpnt_dsgn_cd               in varchar2
 ,p_rqd_perd_enrt_nenrt_uom                   in varchar2
 ,p_elig_apls_flag                 in varchar2
 ,p_dflt_enrt_det_rl               in number
 ,p_trk_inelig_per_flag            in varchar2
 ,p_drvbl_fctr_prtn_elig_flag      in varchar2
 ,p_mndtry_rl                      in number
 ,p_rqd_perd_enrt_nenrt_rl                      in number
 ,p_dflt_enrt_cd                   in varchar2
 ,p_prtn_elig_ovrid_alwd_flag      in varchar2
 ,p_drvbl_fctr_apls_rts_flag       in varchar2
 ,p_per_cvrd_cd                    in varchar2
 ,p_postelcn_edit_rl               in number
 ,p_vrfy_fmly_mmbr_cd              in varchar2
 ,p_vrfy_fmly_mmbr_rl              in number
 ,p_enrt_cd                        in varchar2
 ,p_enrt_rl                        in number
 ,p_auto_enrt_flag                 in varchar2
 ,p_auto_enrt_mthd_rl              in number
 ,p_short_name			   in varchar2		/*FHR*/
 ,p_short_code			   in varchar2		/*FHR*/
  ,p_legislation_code			   in varchar2		/*FHR*/
  ,p_legislation_subgroup			   in varchar2		/*FHR*/
 ,p_hidden_flag			   in varchar2		/*CWB Itemization*/
 ,p_susp_if_ctfn_not_prvd_flag      in  varchar2
 ,p_ctfn_determine_cd          in  varchar2
 ,p_cop_attribute_category         in varchar2
 ,p_cop_attribute1                 in varchar2
 ,p_cop_attribute2                 in varchar2
 ,p_cop_attribute3                 in varchar2
 ,p_cop_attribute4                 in varchar2
 ,p_cop_attribute5                 in varchar2
 ,p_cop_attribute6                 in varchar2
 ,p_cop_attribute7                 in varchar2
 ,p_cop_attribute8                 in varchar2
 ,p_cop_attribute9                 in varchar2
 ,p_cop_attribute10                in varchar2
 ,p_cop_attribute11                in varchar2
 ,p_cop_attribute12                in varchar2
 ,p_cop_attribute13                in varchar2
 ,p_cop_attribute14                in varchar2
 ,p_cop_attribute15                in varchar2
 ,p_cop_attribute16                in varchar2
 ,p_cop_attribute17                in varchar2
 ,p_cop_attribute18                in varchar2
 ,p_cop_attribute19                in varchar2
 ,p_cop_attribute20                in varchar2
 ,p_cop_attribute21                in varchar2
 ,p_cop_attribute22                in varchar2
 ,p_cop_attribute23                in varchar2
 ,p_cop_attribute24                in varchar2
 ,p_cop_attribute25                in varchar2
 ,p_cop_attribute26                in varchar2
 ,p_cop_attribute27                in varchar2
 ,p_cop_attribute28                in varchar2
 ,p_cop_attribute29                in varchar2
 ,p_cop_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
  );
end ben_cop_rki;

 

/
