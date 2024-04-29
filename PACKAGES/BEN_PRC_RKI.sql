--------------------------------------------------------
--  DDL for Package BEN_PRC_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PRC_RKI" AUTHID CURRENT_USER as
/* $Header: beprcrhi.pkh 120.3.12010000.1 2008/07/29 12:53:36 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_prtt_reimbmt_rqst_id           in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_incrd_from_dt                  in date
 ,p_incrd_to_dt                    in date
 ,p_rqst_num                       in number
 ,p_rqst_amt                       in number
 ,p_rqst_amt_uom                   in varchar2
 ,p_rqst_btch_num                  in number
 ,p_prtt_reimbmt_rqst_stat_cd      in varchar2
 ,p_reimbmt_ctfn_typ_prvdd_cd      in varchar2
 ,p_rcrrg_cd                       in varchar2
 ,p_submitter_person_id            in number
 ,p_recipient_person_id            in number
 ,p_provider_person_id             in number
 ,p_provider_ssn_person_id         in number
 ,p_pl_id                          in number
 ,p_gd_or_svc_typ_id               in number
 ,p_contact_relationship_id        in number
 ,p_business_group_id              in number
 ,p_opt_id                         in  number
 ,p_popl_yr_perd_id_1              in  number
 ,p_popl_yr_perd_id_2              in  number
 ,p_amt_year1                      in  number
 ,p_amt_year2                      in  number
 ,p_prc_attribute_category         in varchar2
 ,p_prc_attribute1                 in varchar2
 ,p_prc_attribute2                 in varchar2
 ,p_prc_attribute3                 in varchar2
 ,p_prc_attribute4                 in varchar2
 ,p_prc_attribute5                 in varchar2
 ,p_prc_attribute6                 in varchar2
 ,p_prc_attribute7                 in varchar2
 ,p_prc_attribute8                 in varchar2
 ,p_prc_attribute9                 in varchar2
 ,p_prc_attribute10                in varchar2
 ,p_prc_attribute11                in varchar2
 ,p_prc_attribute12                in varchar2
 ,p_prc_attribute13                in varchar2
 ,p_prc_attribute14                in varchar2
 ,p_prc_attribute15                in varchar2
 ,p_prc_attribute16                in varchar2
 ,p_prc_attribute17                in varchar2
 ,p_prc_attribute18                in varchar2
 ,p_prc_attribute19                in varchar2
 ,p_prc_attribute20                in varchar2
 ,p_prc_attribute21                in varchar2
 ,p_prc_attribute22                in varchar2
 ,p_prc_attribute23                in varchar2
 ,p_prc_attribute24                in varchar2
 ,p_prc_attribute25                in varchar2
 ,p_prc_attribute26                in varchar2
 ,p_prc_attribute27                in varchar2
 ,p_prc_attribute28                in varchar2
 ,p_prc_attribute29                in varchar2
 ,p_prc_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_prtt_enrt_rslt_id              in number
 ,p_comment_id                     in number
 -- Fide Enh
 ,p_stat_rsn_cd                    in varchar2
 ,p_pymt_stat_cd                   in varchar2
 ,p_pymt_stat_rsn_cd               in varchar2
 ,p_stat_ovrdn_flag                in varchar2
 ,p_stat_ovrdn_rsn_cd              in varchar2
 ,p_stat_prr_to_ovrd               in varchar2
 ,p_pymt_stat_ovrdn_flag           in varchar2
 ,p_pymt_stat_ovrdn_rsn_cd         in varchar2
 ,p_pymt_stat_prr_to_ovrd          in varchar2
 ,p_adjmt_flag                     in varchar2
 ,p_submtd_dt                      in date
 ,p_ttl_rqst_amt                   in  number
 ,p_aprvd_for_pymt_amt             in  number
 ,p_effective_date                 in date
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_exp_incurd_dt		   in date
  );
end ben_prc_rki;

/