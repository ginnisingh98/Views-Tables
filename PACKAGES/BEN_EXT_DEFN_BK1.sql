--------------------------------------------------------
--  DDL for Package BEN_EXT_DEFN_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EXT_DEFN_BK1" AUTHID CURRENT_USER as
/* $Header: bexdfapi.pkh 120.2 2006/06/06 21:50:55 tjesumic ship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_EXT_DEFN_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_EXT_DEFN_b
  (
   p_name                           in  varchar2
  ,p_xml_tag_name                   in  varchar2
  ,p_xdo_template_id                in  number
  ,p_data_typ_cd                    in  varchar2
  ,p_ext_typ_cd                     in  varchar2
  ,p_output_name                    in  varchar2
  ,p_output_type                    in  varchar2
  ,p_apnd_rqst_id_flag              in  varchar2
  ,p_prmy_sort_cd                   in  varchar2
  ,p_scnd_sort_cd                   in  varchar2
  ,p_strt_dt                        in  varchar2
  ,p_end_dt                         in  varchar2
  ,p_ext_crit_prfl_id               in  number
  ,p_ext_file_id                    in  number
  ,p_business_group_id              in  number
  ,p_legislation_code               in  varchar2
  ,p_xdf_attribute_category         in  varchar2
  ,p_xdf_attribute1                 in  varchar2
  ,p_xdf_attribute2                 in  varchar2
  ,p_xdf_attribute3                 in  varchar2
  ,p_xdf_attribute4                 in  varchar2
  ,p_xdf_attribute5                 in  varchar2
  ,p_xdf_attribute6                 in  varchar2
  ,p_xdf_attribute7                 in  varchar2
  ,p_xdf_attribute8                 in  varchar2
  ,p_xdf_attribute9                 in  varchar2
  ,p_xdf_attribute10                in  varchar2
  ,p_xdf_attribute11                in  varchar2
  ,p_xdf_attribute12                in  varchar2
  ,p_xdf_attribute13                in  varchar2
  ,p_xdf_attribute14                in  varchar2
  ,p_xdf_attribute15                in  varchar2
  ,p_xdf_attribute16                in  varchar2
  ,p_xdf_attribute17                in  varchar2
  ,p_xdf_attribute18                in  varchar2
  ,p_xdf_attribute19                in  varchar2
  ,p_xdf_attribute20                in  varchar2
  ,p_xdf_attribute21                in  varchar2
  ,p_xdf_attribute22                in  varchar2
  ,p_xdf_attribute23                in  varchar2
  ,p_xdf_attribute24                in  varchar2
  ,p_xdf_attribute25                in  varchar2
  ,p_xdf_attribute26                in  varchar2
  ,p_xdf_attribute27                in  varchar2
  ,p_xdf_attribute28                in  varchar2
  ,p_xdf_attribute29                in  varchar2
  ,p_xdf_attribute30                in  varchar2
  ,p_drctry_name                    in  varchar2
  ,p_kickoff_wrt_prc_flag           in  varchar2
  ,p_upd_cm_sent_dt_flag            in  varchar2
  ,p_spcl_hndl_flag                 in  varchar2
  ,p_ext_global_flag                 in  varchar2
  ,p_cm_display_flag                 in  varchar2
  ,p_use_eff_dt_for_chgs_flag       in  varchar2
  ,p_ext_post_prcs_rl               in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_EXT_DEFN_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_EXT_DEFN_a
  (
   p_ext_dfn_id                     in  number
  ,p_name                           in  varchar2
  ,p_xml_tag_name                   in  varchar2
  ,p_xdo_template_id                in  number
  ,p_data_typ_cd                    in  varchar2
  ,p_ext_typ_cd                     in  varchar2
  ,p_output_name                    in  varchar2
  ,p_output_type                    in  varchar2
  ,p_apnd_rqst_id_flag              in  varchar2
  ,p_prmy_sort_cd                   in  varchar2
  ,p_scnd_sort_cd                   in  varchar2
  ,p_strt_dt                        in  varchar2
  ,p_end_dt                         in  varchar2
  ,p_ext_crit_prfl_id               in  number
  ,p_ext_file_id                    in  number
  ,p_business_group_id              in  number
  ,p_legislation_code               in  varchar2
  ,p_xdf_attribute_category         in  varchar2
  ,p_xdf_attribute1                 in  varchar2
  ,p_xdf_attribute2                 in  varchar2
  ,p_xdf_attribute3                 in  varchar2
  ,p_xdf_attribute4                 in  varchar2
  ,p_xdf_attribute5                 in  varchar2
  ,p_xdf_attribute6                 in  varchar2
  ,p_xdf_attribute7                 in  varchar2
  ,p_xdf_attribute8                 in  varchar2
  ,p_xdf_attribute9                 in  varchar2
  ,p_xdf_attribute10                in  varchar2
  ,p_xdf_attribute11                in  varchar2
  ,p_xdf_attribute12                in  varchar2
  ,p_xdf_attribute13                in  varchar2
  ,p_xdf_attribute14                in  varchar2
  ,p_xdf_attribute15                in  varchar2
  ,p_xdf_attribute16                in  varchar2
  ,p_xdf_attribute17                in  varchar2
  ,p_xdf_attribute18                in  varchar2
  ,p_xdf_attribute19                in  varchar2
  ,p_xdf_attribute20                in  varchar2
  ,p_xdf_attribute21                in  varchar2
  ,p_xdf_attribute22                in  varchar2
  ,p_xdf_attribute23                in  varchar2
  ,p_xdf_attribute24                in  varchar2
  ,p_xdf_attribute25                in  varchar2
  ,p_xdf_attribute26                in  varchar2
  ,p_xdf_attribute27                in  varchar2
  ,p_xdf_attribute28                in  varchar2
  ,p_xdf_attribute29                in  varchar2
  ,p_xdf_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_drctry_name                    in  varchar2
  ,p_kickoff_wrt_prc_flag           in  varchar2
  ,p_upd_cm_sent_dt_flag            in  varchar2
  ,p_spcl_hndl_flag                 in  varchar2
  ,p_ext_global_flag                 in  varchar2
  ,p_cm_display_flag                 in  varchar2
  ,p_use_eff_dt_for_chgs_flag       in  varchar2
  ,p_ext_post_prcs_rl               in  number
  ,p_effective_date                 in  date
  );
--
end ben_EXT_DEFN_bk1;

 

/
