--------------------------------------------------------
--  DDL for Package GHR_COMPLAINT_ADRS_BK_3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_COMPLAINT_ADRS_BK_3" AUTHID CURRENT_USER as
/* $Header: ghcadapi.pkh 120.1 2005/10/02 01:57:04 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_compl_adr_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_compl_adr_b
  (p_compl_adr_id                  in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_compl_adr_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_compl_adr_a
  (p_compl_adr_id                  in     number
  ,p_object_version_number         in     number
  );
--
end ghr_complaint_adrs_bk_3;

 

/
