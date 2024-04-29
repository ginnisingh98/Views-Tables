--------------------------------------------------------
--  DDL for Package GHR_COMPLAINANT_APPEALS_BK_3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_COMPLAINANT_APPEALS_BK_3" AUTHID CURRENT_USER as
/* $Header: ghccaapi.pkh 120.1 2005/10/02 01:57:18 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_complainant_appeal_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_complainant_appeal_b
  (p_compl_appeal_id               in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_complainant_appeal_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_complainant_appeal_a
  (p_compl_appeal_id               in     number
  ,p_object_version_number         in     number
  );

end ghr_complainant_appeals_bk_3;

 

/
