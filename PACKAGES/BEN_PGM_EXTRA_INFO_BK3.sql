--------------------------------------------------------
--  DDL for Package BEN_PGM_EXTRA_INFO_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PGM_EXTRA_INFO_BK3" AUTHID CURRENT_USER as
/* $Header: bepgiapi.pkh 120.0 2005/05/28 10:45:47 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------< delete_pgm_extra_info_b >----------------------|
-- ----------------------------------------------------------------------------
Procedure delete_pgm_extra_info_b
	(
		p_pgm_extra_info_id		in	number	,
		p_object_version_number		in	number
	);

-- |----------------------< delete_pgm_extra_info_a >----------------------|

Procedure delete_pgm_extra_info_a
	(
		p_pgm_extra_info_id		in	number	,
		p_object_version_number		in	number
	);

end ben_pgm_extra_info_bk3;

 

/
