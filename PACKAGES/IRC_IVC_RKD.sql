--------------------------------------------------------
--  DDL for Package IRC_IVC_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_IVC_RKD" AUTHID CURRENT_USER as
/* $Header: irivcrhi.pkh 120.0 2005/07/26 15:12:32 mbocutt noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_vacancy_consideration_id     in number
  ,p_person_id_o                  in number
  ,p_party_id_o                   in number
  ,p_vacancy_id_o                 in number
  ,p_consideration_status_o       in varchar2
  ,p_object_version_number_o      in number
  );
--
end irc_ivc_rkd;

 

/
