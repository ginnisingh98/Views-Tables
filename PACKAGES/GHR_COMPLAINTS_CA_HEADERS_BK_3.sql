--------------------------------------------------------
--  DDL for Package GHR_COMPLAINTS_CA_HEADERS_BK_3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_COMPLAINTS_CA_HEADERS_BK_3" AUTHID CURRENT_USER as
/* $Header: ghcahapi.pkh 120.1 2005/10/02 01:57:09 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_ca_header_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ca_header_b
  (p_compl_ca_header_id            in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_ca_header_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ca_header_a
  (p_compl_ca_header_id            in     number
  ,p_object_version_number         in     number
  );
--
end ghr_complaints_ca_headers_bk_3;

 

/
