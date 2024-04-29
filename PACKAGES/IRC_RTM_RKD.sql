--------------------------------------------------------
--  DDL for Package IRC_RTM_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_RTM_RKD" AUTHID CURRENT_USER as
/* $Header: irrtmrhi.pkh 120.2 2008/01/22 10:18:04 mkjayara noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_rec_team_member_id           in number
  ,p_person_id_o                  in number
  ,p_party_id_o                   in number
  ,p_vacancy_id_o                 in number
  ,p_job_id_o                     in number
  ,p_start_date_o                 in date
  ,p_end_date_o                   in date
  ,p_update_allowed_o             in varchar2
  ,p_delete_allowed_o             in varchar2
  ,p_object_version_number_o      in number
  ,p_interview_security_o          in varchar2
  );
--
end irc_rtm_rkd;

/
