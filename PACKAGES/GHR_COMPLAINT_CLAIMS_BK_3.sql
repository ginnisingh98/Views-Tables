--------------------------------------------------------
--  DDL for Package GHR_COMPLAINT_CLAIMS_BK_3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_COMPLAINT_CLAIMS_BK_3" AUTHID CURRENT_USER as
/* $Header: ghcclapi.pkh 120.1 2005/10/02 01:57:22 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_compl_claim_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_compl_claim_b
  (p_compl_claim_id                in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_compl_claim_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_compl_claim_a
  (p_compl_claim_id                in     number
  ,p_object_version_number         in     number
  );
--
end ghr_complaint_claims_bk_3;

 

/
