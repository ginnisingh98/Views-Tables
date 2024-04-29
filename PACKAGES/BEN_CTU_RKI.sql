--------------------------------------------------------
--  DDL for Package BEN_CTU_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CTU_RKI" AUTHID CURRENT_USER as
/* $Header: becturhi.pkh 120.0 2005/05/28 01:28:25 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
 (p_cm_typ_usg_id                  in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_all_r_any_cd                   in varchar2
 ,p_cm_usg_rl                      in number
 ,p_descr_text                     in varchar2
 ,p_pgm_id                         in number
 ,p_pl_id                          in number
 ,p_pl_typ_id                      in number
 ,p_enrt_perd_id                   in number
 ,p_actn_typ_id                    in number
 ,p_cm_typ_id                      in number
 ,p_ler_id                         in number
 ,p_business_group_id              in number
 ,p_ctu_attribute_category         in varchar2
 ,p_ctu_attribute1                 in varchar2
 ,p_ctu_attribute2                 in varchar2
 ,p_ctu_attribute3                 in varchar2
 ,p_ctu_attribute4                 in varchar2
 ,p_ctu_attribute5                 in varchar2
 ,p_ctu_attribute6                 in varchar2
 ,p_ctu_attribute7                 in varchar2
 ,p_ctu_attribute8                 in varchar2
 ,p_ctu_attribute9                 in varchar2
 ,p_ctu_attribute10                in varchar2
 ,p_ctu_attribute11                in varchar2
 ,p_ctu_attribute12                in varchar2
 ,p_ctu_attribute13                in varchar2
 ,p_ctu_attribute14                in varchar2
 ,p_ctu_attribute15                in varchar2
 ,p_ctu_attribute16                in varchar2
 ,p_ctu_attribute17                in varchar2
 ,p_ctu_attribute18                in varchar2
 ,p_ctu_attribute19                in varchar2
 ,p_ctu_attribute20                in varchar2
 ,p_ctu_attribute21                in varchar2
 ,p_ctu_attribute22                in varchar2
 ,p_ctu_attribute23                in varchar2
 ,p_ctu_attribute24                in varchar2
 ,p_ctu_attribute25                in varchar2
 ,p_ctu_attribute26                in varchar2
 ,p_ctu_attribute27                in varchar2
 ,p_ctu_attribute28                in varchar2
 ,p_ctu_attribute29                in varchar2
 ,p_ctu_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
  );
end ben_ctu_rki;

 

/
