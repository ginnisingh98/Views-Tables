--------------------------------------------------------
--  DDL for Package PER_JOB_EXTRA_INFO_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_JOB_EXTRA_INFO_BK3" AUTHID CURRENT_USER as
/* $Header: pejeiapi.pkh 120.1 2005/10/02 02:17:57 aroussel $ */
--
--
--  delete_job_extra_info_b
--
Procedure delete_job_extra_info_b
	(
		p_job_extra_info_id		in	number	,
		p_object_version_number		in	number
	);
--
-- delete_job_extra_info_a
--
Procedure delete_job_extra_info_a
	(
		p_job_extra_info_id		in	number	,
		p_object_version_number		in	number
	);

end per_job_extra_info_bk3;

 

/
