--------------------------------------------------------
--  DDL for Package BEN_PL_EXTRA_INFO_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PL_EXTRA_INFO_BK3" AUTHID CURRENT_USER as
/* $Header: bepliapi.pkh 120.0.12010000.1 2008/07/29 12:50:37 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------< delete_pl_extra_info_b >----------------------|
-- ----------------------------------------------------------------------------
Procedure delete_pl_extra_info_b
	(
		p_pl_extra_info_id		in	number	,
		p_object_version_number		in	number
	);

-- |----------------------< delete_pl_extra_info_a >----------------------|

Procedure delete_pl_extra_info_a
	(
		p_pl_extra_info_id		in	number	,
		p_object_version_number		in	number
	);

end ben_pl_extra_info_bk3;

/
