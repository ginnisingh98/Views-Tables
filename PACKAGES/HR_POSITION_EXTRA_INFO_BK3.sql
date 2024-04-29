--------------------------------------------------------
--  DDL for Package HR_POSITION_EXTRA_INFO_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_POSITION_EXTRA_INFO_BK3" AUTHID CURRENT_USER as
/* $Header: pepoiapi.pkh 120.1 2005/10/02 02:21:45 aroussel $ */
--
--
--  delete_position_extra_info_b
--
Procedure delete_position_extra_info_b
	(
		p_position_extra_info_id	in	number	,
		p_object_version_number		in	number
	);
--
-- delete_position_extra_info_a
--
Procedure delete_position_extra_info_a
	(
		p_position_extra_info_id	in	number	,
		p_object_version_number		in	number
	);

end hr_position_extra_info_bk3;

 

/
