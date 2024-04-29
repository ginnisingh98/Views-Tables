--------------------------------------------------------
--  DDL for Package BEN_ELTBL_CHC_CTFN_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELTBL_CHC_CTFN_BK1" AUTHID CURRENT_USER as
/* $Header: beeccapi.pkh 120.0 2005/05/28 01:48:50 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_ELTBL_CHC_CTFN_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_ELTBL_CHC_CTFN_b
  (
   p_enrt_ctfn_typ_cd               in  varchar2
  ,p_rqd_flag                       in  varchar2
  ,p_elig_per_elctbl_chc_id         in  number
  ,p_enrt_bnft_id                   in  number
  ,p_business_group_id              in  number
  ,p_ecc_attribute_category         in  varchar2
  ,p_ecc_attribute1                 in  varchar2
  ,p_ecc_attribute2                 in  varchar2
  ,p_ecc_attribute3                 in  varchar2
  ,p_ecc_attribute4                 in  varchar2
  ,p_ecc_attribute5                 in  varchar2
  ,p_ecc_attribute6                 in  varchar2
  ,p_ecc_attribute7                 in  varchar2
  ,p_ecc_attribute8                 in  varchar2
  ,p_ecc_attribute9                 in  varchar2
  ,p_ecc_attribute10                in  varchar2
  ,p_ecc_attribute11                in  varchar2
  ,p_ecc_attribute12                in  varchar2
  ,p_ecc_attribute13                in  varchar2
  ,p_ecc_attribute14                in  varchar2
  ,p_ecc_attribute15                in  varchar2
  ,p_ecc_attribute16                in  varchar2
  ,p_ecc_attribute17                in  varchar2
  ,p_ecc_attribute18                in  varchar2
  ,p_ecc_attribute19                in  varchar2
  ,p_ecc_attribute20                in  varchar2
  ,p_ecc_attribute21                in  varchar2
  ,p_ecc_attribute22                in  varchar2
  ,p_ecc_attribute23                in  varchar2
  ,p_ecc_attribute24                in  varchar2
  ,p_ecc_attribute25                in  varchar2
  ,p_ecc_attribute26                in  varchar2
  ,p_ecc_attribute27                in  varchar2
  ,p_ecc_attribute28                in  varchar2
  ,p_ecc_attribute29                in  varchar2
  ,p_ecc_attribute30                in  varchar2
  ,p_susp_if_ctfn_not_prvd_flag     in  varchar2
  ,p_ctfn_determine_cd              in  varchar2
  ,p_request_id                     in  number
  ,p_program_application_id         in  number
  ,p_program_id                     in  number
  ,p_program_update_date            in  date
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_ELTBL_CHC_CTFN_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_ELTBL_CHC_CTFN_a
  (
   p_elctbl_chc_ctfn_id             in  number
  ,p_enrt_ctfn_typ_cd               in  varchar2
  ,p_rqd_flag                       in  varchar2
  ,p_elig_per_elctbl_chc_id         in  number
  ,p_enrt_bnft_id                   in  number
  ,p_business_group_id              in  number
  ,p_ecc_attribute_category         in  varchar2
  ,p_ecc_attribute1                 in  varchar2
  ,p_ecc_attribute2                 in  varchar2
  ,p_ecc_attribute3                 in  varchar2
  ,p_ecc_attribute4                 in  varchar2
  ,p_ecc_attribute5                 in  varchar2
  ,p_ecc_attribute6                 in  varchar2
  ,p_ecc_attribute7                 in  varchar2
  ,p_ecc_attribute8                 in  varchar2
  ,p_ecc_attribute9                 in  varchar2
  ,p_ecc_attribute10                in  varchar2
  ,p_ecc_attribute11                in  varchar2
  ,p_ecc_attribute12                in  varchar2
  ,p_ecc_attribute13                in  varchar2
  ,p_ecc_attribute14                in  varchar2
  ,p_ecc_attribute15                in  varchar2
  ,p_ecc_attribute16                in  varchar2
  ,p_ecc_attribute17                in  varchar2
  ,p_ecc_attribute18                in  varchar2
  ,p_ecc_attribute19                in  varchar2
  ,p_ecc_attribute20                in  varchar2
  ,p_ecc_attribute21                in  varchar2
  ,p_ecc_attribute22                in  varchar2
  ,p_ecc_attribute23                in  varchar2
  ,p_ecc_attribute24                in  varchar2
  ,p_ecc_attribute25                in  varchar2
  ,p_ecc_attribute26                in  varchar2
  ,p_ecc_attribute27                in  varchar2
  ,p_ecc_attribute28                in  varchar2
  ,p_ecc_attribute29                in  varchar2
  ,p_ecc_attribute30                in  varchar2
  ,p_susp_if_ctfn_not_prvd_flag     in  varchar2
  ,p_ctfn_determine_cd              in  varchar2
  ,p_request_id                     in  number
  ,p_program_application_id         in  number
  ,p_program_id                     in  number
  ,p_program_update_date            in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_ELTBL_CHC_CTFN_bk1;

 

/
