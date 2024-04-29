--------------------------------------------------------
--  DDL for Package BEN_PERSON_LIFE_EVENT_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PERSON_LIFE_EVENT_BK1" AUTHID CURRENT_USER as
/* $Header: bepilapi.pkh 120.0 2005/05/28 10:49:48 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_Person_Life_Event_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_Person_Life_Event_b
  (p_per_in_ler_stat_cd             in  varchar2
  ,p_prvs_stat_cd                   in  varchar2
  ,p_lf_evt_ocrd_dt                 in  date
  ,p_trgr_table_pk_id               in  number
  ,p_procd_dt                       in  date
  ,p_strtd_dt                       in  date
  ,p_voidd_dt                       in  date
  ,p_bckt_dt                        in  date
  ,p_clsd_dt                        in  date
  ,p_ntfn_dt                        in  date
  ,p_ptnl_ler_for_per_id            in  number
  ,p_bckt_per_in_ler_id             in  number
  ,p_ler_id                         in  number
  ,p_person_id                      in  number
  ,p_business_group_id              in  number
  ,p_ASSIGNMENT_ID                  in  number
  ,p_WS_MGR_ID                      in  number
  ,p_GROUP_PL_ID                    in  number
  ,p_MGR_OVRID_PERSON_ID            in  number
  ,p_MGR_OVRID_DT                   in  date
  ,p_pil_attribute_category         in  varchar2
  ,p_pil_attribute1                 in  varchar2
  ,p_pil_attribute2                 in  varchar2
  ,p_pil_attribute3                 in  varchar2
  ,p_pil_attribute4                 in  varchar2
  ,p_pil_attribute5                 in  varchar2
  ,p_pil_attribute6                 in  varchar2
  ,p_pil_attribute7                 in  varchar2
  ,p_pil_attribute8                 in  varchar2
  ,p_pil_attribute9                 in  varchar2
  ,p_pil_attribute10                in  varchar2
  ,p_pil_attribute11                in  varchar2
  ,p_pil_attribute12                in  varchar2
  ,p_pil_attribute13                in  varchar2
  ,p_pil_attribute14                in  varchar2
  ,p_pil_attribute15                in  varchar2
  ,p_pil_attribute16                in  varchar2
  ,p_pil_attribute17                in  varchar2
  ,p_pil_attribute18                in  varchar2
  ,p_pil_attribute19                in  varchar2
  ,p_pil_attribute20                in  varchar2
  ,p_pil_attribute21                in  varchar2
  ,p_pil_attribute22                in  varchar2
  ,p_pil_attribute23                in  varchar2
  ,p_pil_attribute24                in  varchar2
  ,p_pil_attribute25                in  varchar2
  ,p_pil_attribute26                in  varchar2
  ,p_pil_attribute27                in  varchar2
  ,p_pil_attribute28                in  varchar2
  ,p_pil_attribute29                in  varchar2
  ,p_pil_attribute30                in  varchar2
  ,p_request_id                     in  number
  ,p_program_application_id         in  number
  ,p_program_id                     in  number
  ,p_program_update_date            in  date
  ,p_effective_date                 in  date);
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_Person_Life_Event_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_Person_Life_Event_a
  (p_per_in_ler_id                  in  number
  ,p_per_in_ler_stat_cd             in  varchar2
  ,p_prvs_stat_cd                   in  varchar2
  ,p_lf_evt_ocrd_dt                 in  date
  ,p_trgr_table_pk_id               in  number
  ,p_procd_dt                       in  date
  ,p_strtd_dt                       in  date
  ,p_voidd_dt                       in  date
  ,p_bckt_dt                        in  date
  ,p_clsd_dt                        in  date
  ,p_ntfn_dt                        in  date
  ,p_ptnl_ler_for_per_id            in  number
  ,p_bckt_per_in_ler_id             in  number
  ,p_ler_id                         in  number
  ,p_person_id                      in  number
  ,p_business_group_id              in  number
  ,p_ASSIGNMENT_ID                  in  number
  ,p_WS_MGR_ID                      in  number
  ,p_GROUP_PL_ID                    in  number
  ,p_MGR_OVRID_PERSON_ID            in  number
  ,p_MGR_OVRID_DT                   in  date
  ,p_pil_attribute_category         in  varchar2
  ,p_pil_attribute1                 in  varchar2
  ,p_pil_attribute2                 in  varchar2
  ,p_pil_attribute3                 in  varchar2
  ,p_pil_attribute4                 in  varchar2
  ,p_pil_attribute5                 in  varchar2
  ,p_pil_attribute6                 in  varchar2
  ,p_pil_attribute7                 in  varchar2
  ,p_pil_attribute8                 in  varchar2
  ,p_pil_attribute9                 in  varchar2
  ,p_pil_attribute10                in  varchar2
  ,p_pil_attribute11                in  varchar2
  ,p_pil_attribute12                in  varchar2
  ,p_pil_attribute13                in  varchar2
  ,p_pil_attribute14                in  varchar2
  ,p_pil_attribute15                in  varchar2
  ,p_pil_attribute16                in  varchar2
  ,p_pil_attribute17                in  varchar2
  ,p_pil_attribute18                in  varchar2
  ,p_pil_attribute19                in  varchar2
  ,p_pil_attribute20                in  varchar2
  ,p_pil_attribute21                in  varchar2
  ,p_pil_attribute22                in  varchar2
  ,p_pil_attribute23                in  varchar2
  ,p_pil_attribute24                in  varchar2
  ,p_pil_attribute25                in  varchar2
  ,p_pil_attribute26                in  varchar2
  ,p_pil_attribute27                in  varchar2
  ,p_pil_attribute28                in  varchar2
  ,p_pil_attribute29                in  varchar2
  ,p_pil_attribute30                in  varchar2
  ,p_request_id                     in  number
  ,p_program_application_id         in  number
  ,p_program_id                     in  number
  ,p_program_update_date            in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date);
--
end ben_Person_Life_Event_bk1;

 

/
