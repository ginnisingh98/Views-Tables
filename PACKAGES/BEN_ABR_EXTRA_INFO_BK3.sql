--------------------------------------------------------
--  DDL for Package BEN_ABR_EXTRA_INFO_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ABR_EXTRA_INFO_BK3" AUTHID CURRENT_USER as
/* $Header: beabiapi.pkh 120.0 2005/05/28 00:17:20 appldev noship $ */
--  ------------------------------------------------------------------------
-- |----------------------< delete_abr_extra_info_b >----------------------|
--  ------------------------------------------------------------------------


Procedure delete_abr_extra_info_b
	(
		p_abr_extra_info_id		in	number	,
		p_object_version_number		in	number
	);

-- |----------------------< delete_abr_extra_info_a >----------------------|

Procedure delete_abr_extra_info_a
	(
		p_abr_extra_info_id		in	number	,
		p_object_version_number		in	number
	);

end ben_abr_extra_info_bk3;

 

/
