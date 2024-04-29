--------------------------------------------------------
--  DDL for Package IRC_IVC_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_IVC_RKU" AUTHID CURRENT_USER as
/* $Header: irivcrhi.pkh 120.0 2005/07/26 15:12:32 mbocutt noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_effective_date               in date
  ,p_vacancy_consideration_id     in number
  ,p_person_id                    in number
  ,p_party_id                     in number
  ,p_vacancy_id                   in number
  ,p_consideration_status         in varchar2
  ,p_object_version_number        in number
  ,p_consideration_status_o       in varchar2
  ,p_object_version_number_o      in number
  );
--
end irc_ivc_rku;

 

/
