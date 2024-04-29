--------------------------------------------------------
--  DDL for Package IRC_IVC_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_IVC_RKI" AUTHID CURRENT_USER as
/* $Header: irivcrhi.pkh 120.0 2005/07/26 15:12:32 mbocutt noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_vacancy_consideration_id     in number
  ,p_person_id                    in number
  ,p_party_id                     in number
  ,p_vacancy_id                   in number
  ,p_consideration_status         in varchar2
  ,p_object_version_number        in number
  );
end irc_ivc_rki;

 

/
