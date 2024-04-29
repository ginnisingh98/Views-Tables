--------------------------------------------------------
--  DDL for Package HR_ASSESSMENT_GROUPS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ASSESSMENT_GROUPS_BK3" AUTHID CURRENT_USER as
/* $Header: peasrapi.pkh 115.3 99/10/05 09:44:03 porting ship $ */
--
--
--  delete_assessment_group_b
--
Procedure delete_assessment_group_b
	(
         p_assessment_group_id        in number,
         p_object_version_number      in number
	);
--
-- delete_assessment_group_a
--
Procedure delete_assessment_group_a
	(
         p_assessment_group_id        in number,
         p_object_version_number      in number
	);

end hr_assessment_groups_bk3;

 

/
