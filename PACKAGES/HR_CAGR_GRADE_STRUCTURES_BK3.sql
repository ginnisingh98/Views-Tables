--------------------------------------------------------
--  DDL for Package HR_CAGR_GRADE_STRUCTURES_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_CAGR_GRADE_STRUCTURES_BK3" AUTHID CURRENT_USER as
/* $Header: pegrsapi.pkh 120.1 2005/10/02 02:17:25 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_cagr_grade_structures_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_cagr_grade_structures_b
  (
   p_cagr_grade_structure_id        in  number
  ,p_object_version_number          in  number
  ,p_effective_date		    in  date
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_cagr_grade_structures_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_cagr_grade_structures_a
  (
   p_cagr_grade_structure_id        in  number
  ,p_object_version_number          in  number
  ,p_effective_date		    in  date
  );
--
end hr_cagr_grade_structures_bk3;

 

/
