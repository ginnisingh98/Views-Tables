--------------------------------------------------------
--  DDL for Package IRC_RTM_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_RTM_RKU" AUTHID CURRENT_USER as
/* $Header: irrtmrhi.pkh 120.2 2008/01/22 10:18:04 mkjayara noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_rec_team_member_id           in number
  ,p_person_id                    in number
  ,p_party_id                     in number
  ,p_vacancy_id                   in number
  ,p_job_id                       in number
  ,p_start_date                   in date
  ,p_end_date                     in date
  ,p_update_allowed               in varchar2
  ,p_delete_allowed               in varchar2
  ,p_interview_security            in varchar2
  ,p_object_version_number        in number
  ,p_job_id_o                     in number
  ,p_start_date_o                 in date
  ,p_end_date_o                   in date
  ,p_update_allowed_o             in varchar2
  ,p_delete_allowed_o             in varchar2
  ,p_interview_security_o          in varchar2
  ,p_object_version_number_o      in number
  ,p_person_id_o                  in number
  ,p_party_id_o                   in number
  );
--
end irc_rtm_rku;

/
