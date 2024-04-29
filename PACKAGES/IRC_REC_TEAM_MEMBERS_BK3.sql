--------------------------------------------------------
--  DDL for Package IRC_REC_TEAM_MEMBERS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_REC_TEAM_MEMBERS_BK3" AUTHID CURRENT_USER as
/* $Header: irrtmapi.pkh 120.3.12010000.3 2008/11/17 11:00:56 avarri ship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< DELETE_REC_TEAM_MEMBER_B >---------------------|
-- ----------------------------------------------------------------------------
--
procedure DELETE_REC_TEAM_MEMBER_B
  (p_rec_team_member_id            in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< DELETE_REC_TEAM_MEMBER_A >---------------------|
-- ----------------------------------------------------------------------------
--
procedure DELETE_REC_TEAM_MEMBER_A
  (p_rec_team_member_id            in     number
  ,p_object_version_number         in     number
  );
--
end IRC_REC_TEAM_MEMBERS_BK3;

/
