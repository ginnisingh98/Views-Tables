--------------------------------------------------------
--  DDL for Package HR_CAGR_GRADE_STRUCTURES_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_CAGR_GRADE_STRUCTURES_BK2" AUTHID CURRENT_USER as
/* $Header: pegrsapi.pkh 120.1 2005/10/02 02:17:25 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_cagr_grade_structures_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_cagr_grade_structures_b
  (
   p_cagr_grade_structure_id        in  number
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
  ,p_object_version_number          in  number
  ,p_effective_date		    in  date
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_cagr_grade_structures_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_cagr_grade_structures_a
  (
   p_cagr_grade_structure_id        in  number
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
  ,p_object_version_number          in  number
  ,p_effective_date		    in  date
  );
--
end hr_cagr_grade_structures_bk2;

 

/
