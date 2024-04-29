--------------------------------------------------------
--  DDL for Package GHR_COMPLAINTS_CA_DETAILS_BK_3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_COMPLAINTS_CA_DETAILS_BK_3" AUTHID CURRENT_USER as
/* $Header: ghcdtapi.pkh 120.1 2005/10/02 01:57:27 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_ca_detail_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ca_detail_b
  (p_compl_ca_detail_id            in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_ca_detail_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ca_detail_a
  (p_compl_ca_detail_id            in     number
  ,p_object_version_number         in     number
  );
--
end ghr_complaints_ca_details_bk_3;

 

/
