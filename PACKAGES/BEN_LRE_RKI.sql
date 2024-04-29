--------------------------------------------------------
--  DDL for Package BEN_LRE_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_LRE_RKI" AUTHID CURRENT_USER as
/* $Header: belrerhi.pkh 120.0.12010000.1 2008/07/29 12:00:38 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_ler_rqrs_enrt_ctfn_id          in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_excld_flag                     in varchar2
 ,p_ctfn_rqd_when_rl               in number
 ,p_ler_id                         in number
 ,p_pl_id                          in number
 ,p_oipl_id                        in number
 ,p_business_group_id              in number
 ,p_lre_attribute_category         in varchar2
 ,p_lre_attribute1                 in varchar2
 ,p_lre_attribute2                 in varchar2
 ,p_lre_attribute3                 in varchar2
 ,p_lre_attribute4                 in varchar2
 ,p_lre_attribute5                 in varchar2
 ,p_lre_attribute6                 in varchar2
 ,p_lre_attribute7                 in varchar2
 ,p_lre_attribute8                 in varchar2
 ,p_lre_attribute9                 in varchar2
 ,p_lre_attribute10                in varchar2
 ,p_lre_attribute11                in varchar2
 ,p_lre_attribute12                in varchar2
 ,p_lre_attribute13                in varchar2
 ,p_lre_attribute14                in varchar2
 ,p_lre_attribute15                in varchar2
 ,p_lre_attribute16                in varchar2
 ,p_lre_attribute17                in varchar2
 ,p_lre_attribute18                in varchar2
 ,p_lre_attribute19                in varchar2
 ,p_lre_attribute20                in varchar2
 ,p_lre_attribute21                in varchar2
 ,p_lre_attribute22                in varchar2
 ,p_lre_attribute23                in varchar2
 ,p_lre_attribute24                in varchar2
 ,p_lre_attribute25                in varchar2
 ,p_lre_attribute26                in varchar2
 ,p_lre_attribute27                in varchar2
 ,p_lre_attribute28                in varchar2
 ,p_lre_attribute29                in varchar2
 ,p_lre_attribute30                in varchar2
 ,p_susp_if_ctfn_not_prvd_flag    in varchar2
 ,p_ctfn_determine_cd              in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
  );
end ben_lre_rki;

/
