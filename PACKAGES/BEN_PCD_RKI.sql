--------------------------------------------------------
--  DDL for Package BEN_PCD_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PCD_RKI" AUTHID CURRENT_USER as
/* $Header: bepcdrhi.pkh 120.0 2005/05/28 10:10:12 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_per_cm_prvdd_id                in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_rqstd_flag                     in varchar2
 ,p_per_cm_prvdd_stat_cd           in varchar2
 ,p_cm_dlvry_med_cd                in varchar2
 ,p_cm_dlvry_mthd_cd               in varchar2
 ,p_sent_dt                        in date
 ,p_instnc_num                     in number
 ,p_to_be_sent_dt                  in date
 ,p_dlvry_instn_txt                in varchar2
 ,p_inspn_rqd_flag                 in varchar2
 ,p_resnd_rsn_cd                   in varchar2
 ,p_resnd_cmnt_txt                 in varchar2
 ,p_per_cm_id                      in number
 ,p_address_id                     in number
 ,p_business_group_id              in number
 ,p_pcd_attribute_category         in varchar2
 ,p_pcd_attribute1                 in varchar2
 ,p_pcd_attribute2                 in varchar2
 ,p_pcd_attribute3                 in varchar2
 ,p_pcd_attribute4                 in varchar2
 ,p_pcd_attribute5                 in varchar2
 ,p_pcd_attribute6                 in varchar2
 ,p_pcd_attribute7                 in varchar2
 ,p_pcd_attribute8                 in varchar2
 ,p_pcd_attribute9                 in varchar2
 ,p_pcd_attribute10                in varchar2
 ,p_pcd_attribute11                in varchar2
 ,p_pcd_attribute12                in varchar2
 ,p_pcd_attribute13                in varchar2
 ,p_pcd_attribute14                in varchar2
 ,p_pcd_attribute15                in varchar2
 ,p_pcd_attribute16                in varchar2
 ,p_pcd_attribute17                in varchar2
 ,p_pcd_attribute18                in varchar2
 ,p_pcd_attribute19                in varchar2
 ,p_pcd_attribute20                in varchar2
 ,p_pcd_attribute21                in varchar2
 ,p_pcd_attribute22                in varchar2
 ,p_pcd_attribute23                in varchar2
 ,p_pcd_attribute24                in varchar2
 ,p_pcd_attribute25                in varchar2
 ,p_pcd_attribute26                in varchar2
 ,p_pcd_attribute27                in varchar2
 ,p_pcd_attribute28                in varchar2
 ,p_pcd_attribute29                in varchar2
 ,p_pcd_attribute30                in varchar2
 ,p_request_id                     in number
 ,p_program_application_id         in number
 ,p_program_id                     in number
 ,p_program_update_date            in date
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
  );
end ben_pcd_rki;

 

/
