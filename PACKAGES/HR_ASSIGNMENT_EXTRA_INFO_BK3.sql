--------------------------------------------------------
--  DDL for Package HR_ASSIGNMENT_EXTRA_INFO_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ASSIGNMENT_EXTRA_INFO_BK3" AUTHID CURRENT_USER as
/* $Header: peaeiapi.pkh 120.2 2006/05/30 05:24:04 sspratur noship $ */
--
--
--  delete_assignment_extra_info_b
--
Procedure delete_assignment_extra_info_b
	(	p_assignment_extra_info_id	in	number,
		p_object_version_number		in	number
	);
--
-- delete_assignment_extra_info_a
--
Procedure delete_assignment_extra_info_a
	(	p_assignment_extra_info_id	in	number,
		p_object_version_number		in	number
	);

end hr_assignment_extra_info_bk3;

 

/
