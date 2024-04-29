--------------------------------------------------------
--  DDL for Package HR_CAGR_GRADES_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_CAGR_GRADES_BK3" AUTHID CURRENT_USER as
/* $Header: pegraapi.pkh 120.1 2005/10/02 02:17:12 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_cagr_grades_b >------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_cagr_grades_b
  (
   p_cagr_grade_id                  in  number
  ,p_object_version_number          in  number
  ,p_effective_date		    in  date
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_cagr_grades_a >------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_cagr_grades_a
  (
   p_cagr_grade_id                  in  number
  ,p_object_version_number          in  number
  ,p_effective_date		    in  date
  );
--
end hr_cagr_grades_bk3;

 

/
