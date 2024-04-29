--------------------------------------------------------
--  DDL for Package PQH_ROLE_EXTRA_INFO_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_ROLE_EXTRA_INFO_BK3" AUTHID CURRENT_USER as
/* $Header: pqreiapi.pkh 120.1 2005/10/02 02:27:16 aroussel $ */
--
 -- |--------------------------< delete_role_extra_info_b >--------------------------|
Procedure delete_role_extra_info_b
	(
		p_role_extra_info_id		in	number,
		p_object_version_number		in	number
	);

  -- |--------------------------< delete_role_extra_info_a >--------------------------|
Procedure delete_role_extra_info_a
	(
		p_role_extra_info_id		in	number,
		p_object_version_number		in	number
	);

end pqh_role_extra_info_bk3;

 

/
