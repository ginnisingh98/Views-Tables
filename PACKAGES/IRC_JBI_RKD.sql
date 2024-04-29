--------------------------------------------------------
--  DDL for Package IRC_JBI_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_JBI_RKD" AUTHID CURRENT_USER as
/* $Header: irjbirhi.pkh 120.0 2005/07/26 15:13:22 mbocutt noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_party_id                    in number
  ,p_person_id                   in number
  ,p_job_basket_item_id          in number
  ,p_recruitment_activity_id     in number
  ,p_object_version_number_o     in number
  );
--
end irc_jbi_rkd;

 

/
