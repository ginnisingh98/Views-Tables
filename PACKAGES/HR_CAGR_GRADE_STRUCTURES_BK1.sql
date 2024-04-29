--------------------------------------------------------
--  DDL for Package HR_CAGR_GRADE_STRUCTURES_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_CAGR_GRADE_STRUCTURES_BK1" AUTHID CURRENT_USER as
/* $Header: pegrsapi.pkh 120.1 2005/10/02 02:17:25 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_cagr_grade_structures_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_cagr_grade_structures_b
  (
   p_collective_agreement_id        in  number
  ,p_id_flex_num                    in  number
  ,p_dynamic_insert_allowed         in  varchar2
  ,p_attribute_category             in  varchar2
  ,p_attribute1                     in  varchar2
  ,p_attribute2                     in  varchar2
  ,p_attribute3                     in  varchar2
  ,p_attribute4                     in  varchar2
  ,p_attribute5                     in  varchar2
  ,p_attribute6                     in  varchar2
  ,p_attribute7                     in  varchar2
  ,p_attribute8                     in  varchar2
  ,p_attribute9                     in  varchar2
  ,p_attribute10                    in  varchar2
  ,p_attribute11                    in  varchar2
  ,p_attribute12                    in  varchar2
  ,p_attribute13                    in  varchar2
  ,p_attribute14                    in  varchar2
  ,p_attribute15                    in  varchar2
  ,p_attribute16                    in  varchar2
  ,p_attribute17                    in  varchar2
  ,p_attribute18                    in  varchar2
  ,p_attribute19                    in  varchar2
  ,p_attribute20                    in  varchar2
  ,p_effective_date		    in date
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_cagr_grade_structures_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_cagr_grade_structures_a
  (
   p_collective_agreement_id        in  number
  ,p_id_flex_num                    in  number
  ,p_dynamic_insert_allowed         in  varchar2
  ,p_attribute_category             in  varchar2
  ,p_attribute1                     in  varchar2
  ,p_attribute2                     in  varchar2
  ,p_attribute3                     in  varchar2
  ,p_attribute4                     in  varchar2
  ,p_attribute5                     in  varchar2
  ,p_attribute6                     in  varchar2
  ,p_attribute7                     in  varchar2
  ,p_attribute8                     in  varchar2
  ,p_attribute9                     in  varchar2
  ,p_attribute10                    in  varchar2
  ,p_attribute11                    in  varchar2
  ,p_attribute12                    in  varchar2
  ,p_attribute13                    in  varchar2
  ,p_attribute14                    in  varchar2
  ,p_attribute15                    in  varchar2
  ,p_attribute16                    in  varchar2
  ,p_attribute17                    in  varchar2
  ,p_attribute18                    in  varchar2
  ,p_attribute19                    in  varchar2
  ,p_attribute20                    in  varchar2
  ,p_cagr_grade_structure_id        in number
  ,p_object_version_number          in number
  ,p_effective_date		    in date
  );
--
end hr_cagr_grade_structures_bk1;

 

/
