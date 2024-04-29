--------------------------------------------------------
--  DDL for Package HR_LOCATION_EXTRA_INFO_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_LOCATION_EXTRA_INFO_BK3" AUTHID CURRENT_USER as
/* $Header: hrleiapi.pkh 120.1 2005/10/02 02:03:25 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_location_extra_info_b >-----------------|
-- ----------------------------------------------------------------------------

Procedure delete_location_extra_info_b
	(
		p_location_extra_info_id	in	number	,
		p_object_version_number		in	number
	);

-- ----------------------------------------------------------------------------
-- |-------------------------< delete_location_extra_info_a >-----------------|
-- ----------------------------------------------------------------------------


Procedure delete_location_extra_info_a
	(
		p_location_extra_info_id	in	number	,
		p_object_version_number		in	number
	);

end hr_location_extra_info_bk3;

 

/
