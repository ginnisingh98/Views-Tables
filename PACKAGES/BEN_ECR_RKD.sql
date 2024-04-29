--------------------------------------------------------
--  DDL for Package BEN_ECR_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ECR_RKD" AUTHID CURRENT_USER as
/* $Header: beecrrhi.pkh 120.0 2005/05/28 01:53:27 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
    p_enrt_rt_id                    in number,
	p_ordr_num_o			   in number,
	p_acty_typ_cd_o                 in  VARCHAR2,
	p_tx_typ_cd_o                   in  VARCHAR2,
	p_ctfn_rqd_flag_o               in  VARCHAR2,
	p_dflt_flag_o                   in  VARCHAR2,
	p_dflt_pndg_ctfn_flag_o         in  VARCHAR2,
	p_dsply_on_enrt_flag_o          in  VARCHAR2,
	p_use_to_calc_net_flx_cr_fla_o  in  VARCHAR2,
	p_entr_val_at_enrt_flag_o       in  VARCHAR2,
	p_asn_on_enrt_flag_o            in  VARCHAR2,
	p_rl_crs_only_flag_o            in  VARCHAR2,
	p_dflt_val_o                    in  NUMBER,
	p_ann_val_o                     in  NUMBER,
	p_ann_mn_elcn_val_o             in  NUMBER,
	p_ann_mx_elcn_val_o             in  NUMBER,
	p_val_o                         in  NUMBER,
	p_nnmntry_uom_o                 in  VARCHAR2,
	p_mx_elcn_val_o                 in  NUMBER,
	p_mn_elcn_val_o                 in  NUMBER,
	p_incrmt_elcn_val_o             in  NUMBER,
	p_cmcd_acty_ref_perd_cd_o       in  VARCHAR2,
	p_cmcd_mn_elcn_val_o            in  NUMBER,
	p_cmcd_mx_elcn_val_o            in  NUMBER,
	p_cmcd_val_o                    in  NUMBER,
	p_cmcd_dflt_val_o               in  NUMBER,
	p_rt_usg_cd_o                   in  VARCHAR2,
	p_ann_dflt_val_o                in  NUMBER,
	p_bnft_rt_typ_cd_o              in  VARCHAR2,
	p_rt_mlt_cd_o                   in  VARCHAR2,
	p_dsply_mn_elcn_val_o           in  NUMBER,
	p_dsply_mx_elcn_val_o           in  NUMBER,
	p_entr_ann_val_flag_o           in  VARCHAR2,
	p_rt_strt_dt_o                  in  DATE,
	p_rt_strt_dt_cd_o               in  VARCHAR2,
	p_rt_strt_dt_rl_o               in  NUMBER,
	p_rt_typ_cd_o                   in  VARCHAR2,
	p_elig_per_elctbl_chc_id_o      in  NUMBER,
	p_acty_base_rt_id_o             in  NUMBER,
	p_spcl_rt_enrt_rt_id_o          in  NUMBER,
	p_enrt_bnft_id_o                in  NUMBER,
	p_prtt_rt_val_id_o              in  NUMBER,
	p_decr_bnft_prvdr_pool_id_o     in  NUMBER,
	p_cvg_amt_calc_mthd_id_o        in  NUMBER,
	p_actl_prem_id_o                in  NUMBER,
	p_comp_lvl_fctr_id_o            in  NUMBER,
	p_ptd_comp_lvl_fctr_id_o        in  NUMBER,
	p_clm_comp_lvl_fctr_id_o        in  NUMBER,
	p_business_group_id_o           in  NUMBER,
        --cwb
        p_iss_val_o                     in  number,
        p_val_last_upd_date_o           in  date,
        p_val_last_upd_person_id_o      in  number,
        --cwb
        p_pp_in_yr_used_num_o           in  number ,
	p_ecr_attribute_category_o      in  VARCHAR2,
	p_ecr_attribute1_o              in  VARCHAR2,
	p_ecr_attribute2_o              in  VARCHAR2,
	p_ecr_attribute3_o              in  VARCHAR2,
	p_ecr_attribute4_o              in  VARCHAR2,
	p_ecr_attribute5_o              in  VARCHAR2,
	p_ecr_attribute6_o              in  VARCHAR2,
	p_ecr_attribute7_o              in  VARCHAR2,
	p_ecr_attribute8_o              in  VARCHAR2,
	p_ecr_attribute9_o              in  VARCHAR2,
	p_ecr_attribute10_o             in  VARCHAR2,
	p_ecr_attribute11_o             in  VARCHAR2,
	p_ecr_attribute12_o             in  VARCHAR2,
	p_ecr_attribute13_o             in  VARCHAR2,
	p_ecr_attribute14_o             in  VARCHAR2,
	p_ecr_attribute15_o             in  VARCHAR2,
	p_ecr_attribute16_o             in  VARCHAR2,
	p_ecr_attribute17_o             in  VARCHAR2,
	p_ecr_attribute18_o             in  VARCHAR2,
	p_ecr_attribute19_o             in  VARCHAR2,
	p_ecr_attribute20_o             in  VARCHAR2,
	p_ecr_attribute21_o             in  VARCHAR2,
	p_ecr_attribute22_o             in  VARCHAR2,
    p_ecr_attribute23_o             in  VARCHAR2,
    p_ecr_attribute24_o             in  VARCHAR2,
    p_ecr_attribute25_o             in  VARCHAR2,
    p_ecr_attribute26_o             in  VARCHAR2,
    p_ecr_attribute27_o             in  VARCHAR2,
    p_ecr_attribute28_o             in  VARCHAR2,
    p_ecr_attribute29_o             in  VARCHAR2,
    p_ecr_attribute30_o             in  VARCHAR2,
    p_last_update_login_o           in  NUMBER,
    p_created_by_o                  in  NUMBER,
    p_creation_date_o               in  DATE,
    p_last_updated_by_o             in  NUMBER,
    p_last_update_date_o            in  DATE,
    p_request_id_o                  in  NUMBER,
    p_program_application_id_o      in  NUMBER,
    p_program_id_o                  in  NUMBER,
    p_program_update_date_o         in  DATE,
    p_object_version_number_o       in  NUMBER
  );
--
end ben_ecr_rkd;

 

/
