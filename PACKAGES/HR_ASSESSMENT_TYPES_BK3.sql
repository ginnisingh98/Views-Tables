--------------------------------------------------------
--  DDL for Package HR_ASSESSMENT_TYPES_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ASSESSMENT_TYPES_BK3" AUTHID CURRENT_USER as
/* $Header: peastapi.pkh 120.2 2006/02/09 07:43:16 sansingh noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------< <delete_assessment_type_b> >-----------------------|
-- ----------------------------------------------------------------------------
Procedure delete_assessment_type_b
	(
         p_assessment_type_id           in number
        ,p_object_version_number        in number
      );

-- ----------------------------------------------------------------------------
-- |-----------------------< <delete_assessment_type_a> >-----------------------|
-- ----------------------------------------------------------------------------
Procedure delete_assessment_type_a
	(
         p_assessment_type_id           in number
        ,p_object_version_number        in number
	);

end hr_assessment_types_bk3;

 

/
