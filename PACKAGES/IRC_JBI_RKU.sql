--------------------------------------------------------
--  DDL for Package IRC_JBI_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_JBI_RKU" AUTHID CURRENT_USER as
/* $Header: irjbirhi.pkh 120.0 2005/07/26 15:13:22 mbocutt noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_effective_date               in date
  ,p_job_basket_item_id           in number
  ,p_person_id                    in number
  ,p_party_id                     in number
  ,p_recruitment_activity_id      in number
  ,p_object_version_number        in number
  ,p_object_version_number_o      in number
  );
--
end irc_jbi_rku;

 

/
