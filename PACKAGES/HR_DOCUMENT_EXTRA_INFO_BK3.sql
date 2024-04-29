--------------------------------------------------------
--  DDL for Package HR_DOCUMENT_EXTRA_INFO_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_DOCUMENT_EXTRA_INFO_BK3" AUTHID CURRENT_USER as
/* $Header: hrdeiapi.pkh 120.8.12010000.2 2010/04/07 11:40:46 tkghosh ship $ */
  --
  -- ----------------------------------------------------------------------------
  -- |-----------------------< delete_doc_extra_info_b >-----------------------|
  -- ----------------------------------------------------------------------------
  --


  Procedure delete_doc_extra_info_b
  	(
  		p_document_extra_info_id	in	number	,
  		p_object_version_number		in	number
  	);
   -- ----------------------------------------------------------------------------
    -- |-----------------------< delete_doc_extra_info_a >-----------------------|
  -- ----------------------------------------------------------------------------


  Procedure delete_doc_extra_info_a
  	(
  		p_document_extra_info_id	in	number	,
  		p_object_version_number		in	number
  	);

end hr_document_extra_info_bk3;

/
