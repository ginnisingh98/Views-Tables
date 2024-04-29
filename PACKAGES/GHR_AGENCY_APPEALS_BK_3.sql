--------------------------------------------------------
--  DDL for Package GHR_AGENCY_APPEALS_BK_3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_AGENCY_APPEALS_BK_3" AUTHID CURRENT_USER as
/* $Header: ghcaaapi.pkh 120.1 2005/10/02 01:56:59 aroussel $ */
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_agency_appeal_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_agency_appeal_b
  (p_compl_agency_appeal_id        in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_agency_appeal_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_agency_appeal_a
  (p_compl_agency_appeal_id        in     number
  ,p_object_version_number         in     number
  );
--
end ghr_agency_appeals_bk_3;

 

/
