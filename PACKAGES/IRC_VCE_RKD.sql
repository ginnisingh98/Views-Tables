--------------------------------------------------------
--  DDL for Package IRC_VCE_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_VCE_RKD" AUTHID CURRENT_USER as
/* $Header: irvcerhi.pkh 120.0 2005/07/26 15:19:36 mbocutt noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_vacancy_id                   in number
  ,p_variable_comp_lookup         in varchar2
  ,p_object_version_number_o      in number
  );
--
end irc_vce_rkd;

 

/
