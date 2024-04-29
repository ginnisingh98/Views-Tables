--------------------------------------------------------
--  DDL for Package PAY_ELEMENT_EXTRA_INFO_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ELEMENT_EXTRA_INFO_BK3" AUTHID CURRENT_USER as
/* $Header: pyeeiapi.pkh 120.1 2005/10/02 02:30:38 aroussel $ */
--
--
--  delete_element_extra_info_b
--
Procedure delete_element_extra_info_b
	(
		p_element_type_extra_info_id    in      number,
		p_object_version_number	        in      number
	);
--
-- delete_element_extra_info_a
--
Procedure delete_element_extra_info_a
	(
		p_element_type_extra_info_id    in      number,
		p_object_version_number         in      number
	);

end pay_element_extra_info_bk3;

 

/
