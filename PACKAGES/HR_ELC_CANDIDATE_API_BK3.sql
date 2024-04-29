--------------------------------------------------------
--  DDL for Package HR_ELC_CANDIDATE_API_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ELC_CANDIDATE_API_BK3" AUTHID CURRENT_USER as
/* $Header: peecaapi.pkh 120.1 2005/10/02 02:15:09 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_election_candidate_b >------------------------|
-- ----------------------------------------------------------------------------
--
Procedure delete_election_candidate_b
  (p_election_candidate_id         in      number
  ,p_object_version_number         in      number

  );
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_election_candidate_a >------------------------|
-- ----------------------------------------------------------------------------
--
Procedure delete_election_candidate_a
  (p_election_candidate_id         in      number
  ,p_object_version_number         in      number
  );
--
end hr_elc_candidate_api_bk3;

 

/
