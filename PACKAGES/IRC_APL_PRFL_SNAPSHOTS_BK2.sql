--------------------------------------------------------
--  DDL for Package IRC_APL_PRFL_SNAPSHOTS_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_APL_PRFL_SNAPSHOTS_BK2" AUTHID CURRENT_USER as
/* $Header: irapsapi.pkh 120.1 2008/02/21 13:57:08 viviswan noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_applicant_snapshot_b >------------------|
-- ----------------------------------------------------------------------------
--
procedure update_applicant_snapshot_b
  (p_effective_date                in     date
  ,p_person_id                     in     number
  ,p_profile_snapshot_id           in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_applicant_snapshot_a >------------------|
-- ----------------------------------------------------------------------------
--
procedure update_applicant_snapshot_a
  (p_effective_date                in     date
  ,p_person_id                     in     number
  ,p_profile_snapshot_id           in     number
  ,p_object_version_number         in     number
  );
--
end irc_apl_prfl_snapshots_bk2;

/
