--------------------------------------------------------
--  DDL for Package BEN_LER_EXTRA_INFO_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_LER_EXTRA_INFO_BK3" AUTHID CURRENT_USER as
/* $Header: belriapi.pkh 120.0 2005/05/28 03:35:01 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------< delete_ler_extra_info_b >----------------------|
-- ----------------------------------------------------------------------------
Procedure delete_ler_extra_info_b
	(
		p_ler_extra_info_id		in	number	,
		p_object_version_number		in	number
	);

-- |----------------------< delete_ler_extra_info_a >----------------------|

Procedure delete_ler_extra_info_a
	(
		p_ler_extra_info_id		in	number	,
		p_object_version_number		in	number
	);

end ben_ler_extra_info_bk3;

 

/
