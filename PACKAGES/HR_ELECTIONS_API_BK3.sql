--------------------------------------------------------
--  DDL for Package HR_ELECTIONS_API_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ELECTIONS_API_BK3" AUTHID CURRENT_USER as
/* $Header: peelcapi.pkh 120.1 2005/10/02 02:15:24 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------< delete_election_information_b >---------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_election_information_b
  (p_election_id                   in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------< delete_election_information_a >---------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_election_information_a
  (p_election_id                   in     number
  ,p_object_version_number         in 	  number
  );
--
end hr_elections_api_bk3;

 

/
