--------------------------------------------------------
--  DDL for Package HR_DOCUMENT_TYPES_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_DOCUMENT_TYPES_BK3" AUTHID CURRENT_USER as
/* $Header: hrdtyapi.pkh 120.3.12010000.2 2008/08/06 08:36:12 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_document_type_b >-----------------------|
-- ----------------------------------------------------------------------------
Procedure delete_document_type_b
	(
		p_document_type_id	       in       number
	       ,p_object_version_number		in	number
	);

--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_document_type_a >-----------------------|
-- ----------------------------------------------------------------------------
--
Procedure delete_document_type_a
	(
		p_document_type_id	                in	number
		,p_object_version_number		in	number
	);

end hr_document_types_bk3;

/
