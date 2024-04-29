--------------------------------------------------------
--  DDL for Package IRC_APL_PROFILE_ACCESS_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_APL_PROFILE_ACCESS_BK1" AUTHID CURRENT_USER as
/* $Header: irapaapi.pkh 120.1 2008/02/21 13:38:56 viviswan noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_apl_profile_access_b >------------------|
-- ----------------------------------------------------------------------------
--
procedure create_apl_profile_access_b
  (p_person_id				in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_apl_profile_access_a >------------------|
-- ----------------------------------------------------------------------------
--
procedure create_apl_profile_access_a
  (p_person_id				in     number
  ,p_apl_profile_access_id           in     number
  ,p_object_version_number		in     number
  );
--
end irc_apl_profile_access_bk1;

/
