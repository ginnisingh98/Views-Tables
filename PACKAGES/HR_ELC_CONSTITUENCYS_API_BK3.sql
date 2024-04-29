--------------------------------------------------------
--  DDL for Package HR_ELC_CONSTITUENCYS_API_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ELC_CONSTITUENCYS_API_BK3" AUTHID CURRENT_USER as
/* $Header: peecoapi.pkh 120.1 2005/10/02 02:15:15 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------< delete_election_constituency_b >---------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_election_constituency_b
  (p_election_constituency_id      in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------< delete_election_constituency_a >---------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_election_constituency_a
  (p_election_constituency_id      in     number
  ,p_object_version_number         in     number
  );
--
end hr_elc_constituencys_api_bk3;

 

/
