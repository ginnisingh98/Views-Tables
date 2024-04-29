--------------------------------------------------------
--  DDL for Package BEN_OPT_EXTRA_INFO_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_OPT_EXTRA_INFO_BK3" AUTHID CURRENT_USER as
/* $Header: beopiapi.pkh 120.0 2005/05/28 09:52:55 appldev noship $ */
--

-- |----------------------< delete_opt_extra_info_b >----------------------|

Procedure delete_opt_extra_info_b
	(
		p_opt_extra_info_id		in	number	,
		p_object_version_number		in	number
	);

-- |----------------------< delete_opt_extra_info_a >----------------------|

Procedure delete_opt_extra_info_a
	(
		p_opt_extra_info_id		in	number	,
		p_object_version_number		in	number
	);

end ben_opt_extra_info_bk3;

 

/
