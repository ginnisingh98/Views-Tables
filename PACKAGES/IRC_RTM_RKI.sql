--------------------------------------------------------
--  DDL for Package IRC_RTM_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_RTM_RKI" AUTHID CURRENT_USER as
/* $Header: irrtmrhi.pkh 120.2 2008/01/22 10:18:04 mkjayara noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_rec_team_member_id           in number
  ,p_person_id                    in number
  ,p_vacancy_id                   in number
  ,p_job_id                       in number
  ,p_start_date                   in date
  ,p_end_date                     in date
  ,p_update_allowed               in varchar2
  ,p_delete_allowed               in varchar2
  ,p_object_version_number        in number
  ,p_interview_security            in varchar2
  );
end irc_rtm_rki;

/
