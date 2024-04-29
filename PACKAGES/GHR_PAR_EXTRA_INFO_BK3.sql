--------------------------------------------------------
--  DDL for Package GHR_PAR_EXTRA_INFO_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_PAR_EXTRA_INFO_BK3" AUTHID CURRENT_USER as
/* $Header: ghreiapi.pkh 120.9.12000000.1 2007/01/18 14:10:48 appldev noship $ */
--
--
-- delete_par_extra_info_b
--
Procedure delete_par_extra_info_b	(
                   p_pa_request_extra_info_id   in  number
                  ,p_object_version_number      in  number
	);
--
-- delete_par_extra_info_a
--
Procedure delete_par_extra_info_a	(
                   p_pa_request_extra_info_id   in  number
                  ,p_object_version_number      in  number
	);

end ghr_par_extra_info_bk3;

 

/
