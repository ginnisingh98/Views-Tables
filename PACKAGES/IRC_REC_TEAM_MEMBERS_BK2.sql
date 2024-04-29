--------------------------------------------------------
--  DDL for Package IRC_REC_TEAM_MEMBERS_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_REC_TEAM_MEMBERS_BK2" AUTHID CURRENT_USER as
/* $Header: irrtmapi.pkh 120.3.12010000.3 2008/11/17 11:00:56 avarri ship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< UPDATE_REC_TEAM_MEMBER_B >---------------------|
-- ----------------------------------------------------------------------------
--
procedure UPDATE_REC_TEAM_MEMBER_B
  (p_rec_team_member_id            in     number
  ,p_person_id                     in     number
  ,p_object_version_number         in     number
  ,p_job_id                        in     number
  ,p_start_date                    in     date
  ,p_end_date                      in     date
  ,p_update_allowed                in     varchar2
  ,p_delete_allowed                in     varchar2
  ,p_interview_security             in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< UPDATE_REC_TEAM_MEMBER_A >---------------------|
-- ----------------------------------------------------------------------------
--
procedure UPDATE_REC_TEAM_MEMBER_A
  (p_rec_team_member_id            in     number
  ,p_person_id                     in     number
  ,p_object_version_number         in     number
  ,p_job_id                        in     number
  ,p_start_date                    in     date
  ,p_end_date                      in     date
  ,p_update_allowed                in     varchar2
  ,p_delete_allowed                in     varchar2
  ,p_interview_security             in     varchar2
  );
--
end IRC_REC_TEAM_MEMBERS_BK2;

/
