--------------------------------------------------------
--  DDL for Package HR_CAGR_GRADES_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_CAGR_GRADES_BK1" AUTHID CURRENT_USER as
/* $Header: pegraapi.pkh 120.1 2005/10/02 02:17:12 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_cagr_grades_b >------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_cagr_grades_b
  (
   p_cagr_grade_structure_id        in  number
  ,p_sequence			    in  number
  ,p_segment1			    in  varchar2
  ,p_segment2			    in  varchar2
  ,p_segment3			    in  varchar2
  ,p_segment4			    in  varchar2
  ,p_segment5			    in  varchar2
  ,p_segment6			    in  varchar2
  ,p_segment7			    in  varchar2
  ,p_segment8			    in  varchar2
  ,p_segment9			    in  varchar2
  ,p_segment10			    in  varchar2
  ,p_segment11			    in  varchar2
  ,p_segment12			    in  varchar2
  ,p_segment13			    in  varchar2
  ,p_segment14			    in  varchar2
  ,p_segment15			    in  varchar2
  ,p_segment16			    in  varchar2
  ,p_segment17			    in  varchar2
  ,p_segment18			    in  varchar2
  ,p_segment19			    in  varchar2
  ,p_segment20			    in  varchar2
  ,p_concat_segments		    in  varchar2
  ,p_effective_date		    in date
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_cagr_grades_a >------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_cagr_grades_a
  (
   p_cagr_grade_id                  in  number
  ,p_cagr_grade_structure_id        in  number
  ,p_cagr_grade_def_id              in  number
  ,p_sequence                       in  number
  ,p_segment1			    in  varchar2
  ,p_segment2			    in  varchar2
  ,p_segment3			    in  varchar2
  ,p_segment4			    in  varchar2
  ,p_segment5			    in  varchar2
  ,p_segment6			    in  varchar2
  ,p_segment7			    in  varchar2
  ,p_segment8			    in  varchar2
  ,p_segment9			    in  varchar2
  ,p_segment10			    in  varchar2
  ,p_segment11			    in  varchar2
  ,p_segment12			    in  varchar2
  ,p_segment13			    in  varchar2
  ,p_segment14			    in  varchar2
  ,p_segment15			    in  varchar2
  ,p_segment16			    in  varchar2
  ,p_segment17			    in  varchar2
  ,p_segment18			    in  varchar2
  ,p_segment19			    in  varchar2
  ,p_segment20			    in  varchar2
  ,p_concat_segments		    in  varchar2
  ,p_name		            in varchar2
  ,p_effective_date		    in date
  ,p_object_version_number          in  number
  );
--
end hr_cagr_grades_bk1;

 

/
