--------------------------------------------------------
--  DDL for Package BEN_ELP_EXTRA_INFO_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELP_EXTRA_INFO_BK3" AUTHID CURRENT_USER as
/* $Header: beeliapi.pkh 120.0 2005/05/28 02:18:14 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------< delete_elp_extra_info_b >----------------------|
-- ----------------------------------------------------------------------------
Procedure delete_elp_extra_info_b
	(
		p_elp_extra_info_id		in	number	,
		p_object_version_number		in	number
	);


-- |----------------------< delete_elp_extra_info_a >----------------------|


Procedure delete_elp_extra_info_a
	(
		p_elp_extra_info_id		in	number	,
		p_object_version_number		in	number
	);

end ben_elp_extra_info_bk3;

 

/
