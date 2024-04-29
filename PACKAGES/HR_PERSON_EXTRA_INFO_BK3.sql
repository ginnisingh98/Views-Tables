--------------------------------------------------------
--  DDL for Package HR_PERSON_EXTRA_INFO_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PERSON_EXTRA_INFO_BK3" AUTHID CURRENT_USER as
/* $Header: pepeiapi.pkh 120.1.12010000.1 2008/07/28 05:10:44 appldev ship $ */
--
--
--  delete_person_extra_info_b
--
Procedure delete_person_extra_info_b
	(
		p_person_extra_info_id		in	number	,
		p_object_version_number		in	number
	);
--
-- delete__extra_info_a
--
Procedure delete_person_extra_info_a
	(
		p_person_extra_info_id		in	number	,
		p_object_version_number		in	number
	);

end hr_person_extra_info_bk3;

/
