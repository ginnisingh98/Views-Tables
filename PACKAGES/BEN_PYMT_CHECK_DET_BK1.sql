--------------------------------------------------------
--  DDL for Package BEN_PYMT_CHECK_DET_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PYMT_CHECK_DET_BK1" AUTHID CURRENT_USER as
/* $Header: bepdtapi.pkh 120.0 2005/05/28 10:28:46 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_pymt_check_det_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_pymt_check_det_b
  (
   p_person_id                      in  number
  ,p_business_group_id              in  number
  ,p_check_num                      in  varchar2
  ,p_pymt_dt                        in  date
  ,p_pymt_amt                       in  number
  ,p_pdt_attribute_category         in  varchar2
  ,p_pdt_attribute1                 in  varchar2
  ,p_pdt_attribute2                 in  varchar2
  ,p_pdt_attribute3                 in  varchar2
  ,p_pdt_attribute4                 in  varchar2
  ,p_pdt_attribute5                 in  varchar2
  ,p_pdt_attribute6                 in  varchar2
  ,p_pdt_attribute7                 in  varchar2
  ,p_pdt_attribute8                 in  varchar2
  ,p_pdt_attribute9                 in  varchar2
  ,p_pdt_attribute10                in  varchar2
  ,p_pdt_attribute11                in  varchar2
  ,p_pdt_attribute12                in  varchar2
  ,p_pdt_attribute13                in  varchar2
  ,p_pdt_attribute14                in  varchar2
  ,p_pdt_attribute15                in  varchar2
  ,p_pdt_attribute16                in  varchar2
  ,p_pdt_attribute17                in  varchar2
  ,p_pdt_attribute18                in  varchar2
  ,p_pdt_attribute19                in  varchar2
  ,p_pdt_attribute20                in  varchar2
  ,p_pdt_attribute21                in  varchar2
  ,p_pdt_attribute22                in  varchar2
  ,p_pdt_attribute23                in  varchar2
  ,p_pdt_attribute24                in  varchar2
  ,p_pdt_attribute25                in  varchar2
  ,p_pdt_attribute26                in  varchar2
  ,p_pdt_attribute27                in  varchar2
  ,p_pdt_attribute28                in  varchar2
  ,p_pdt_attribute29                in  varchar2
  ,p_pdt_attribute30                in  varchar2
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_pymt_check_det_a >---------------------|
-- ----------------------------------------------------------------------------
--
procedure create_pymt_check_det_a
  (
   p_pymt_check_det_id              in number
  ,p_person_id                      in  number
  ,p_business_group_id              in  number
  ,p_check_num                      in  varchar2
  ,p_pymt_dt                        in  date
  ,p_pymt_amt                       in  number
  ,p_pdt_attribute_category         in  varchar2
  ,p_pdt_attribute1                 in  varchar2
  ,p_pdt_attribute2                 in  varchar2
  ,p_pdt_attribute3                 in  varchar2
  ,p_pdt_attribute4                 in  varchar2
  ,p_pdt_attribute5                 in  varchar2
  ,p_pdt_attribute6                 in  varchar2
  ,p_pdt_attribute7                 in  varchar2
  ,p_pdt_attribute8                 in  varchar2
  ,p_pdt_attribute9                 in  varchar2
  ,p_pdt_attribute10                in  varchar2
  ,p_pdt_attribute11                in  varchar2
  ,p_pdt_attribute12                in  varchar2
  ,p_pdt_attribute13                in  varchar2
  ,p_pdt_attribute14                in  varchar2
  ,p_pdt_attribute15                in  varchar2
  ,p_pdt_attribute16                in  varchar2
  ,p_pdt_attribute17                in  varchar2
  ,p_pdt_attribute18                in  varchar2
  ,p_pdt_attribute19                in  varchar2
  ,p_pdt_attribute20                in  varchar2
  ,p_pdt_attribute21                in  varchar2
  ,p_pdt_attribute22                in  varchar2
  ,p_pdt_attribute23                in  varchar2
  ,p_pdt_attribute24                in  varchar2
  ,p_pdt_attribute25                in  varchar2
  ,p_pdt_attribute26                in  varchar2
  ,p_pdt_attribute27                in  varchar2
  ,p_pdt_attribute28                in  varchar2
  ,p_pdt_attribute29                in  varchar2
  ,p_pdt_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_pymt_check_det_bk1;

 

/
