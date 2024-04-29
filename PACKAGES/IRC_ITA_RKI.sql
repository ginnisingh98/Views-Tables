--------------------------------------------------------
--  DDL for Package IRC_ITA_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_ITA_RKI" AUTHID CURRENT_USER as
/* $Header: iritarhi.pkh 120.0 2005/09/27 08:01 sayyampe noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_template_association_id      in number
  ,p_template_id                  in number
  ,p_default_association          in varchar2
  ,p_job_id                       in number
  ,p_position_id                  in number
  ,p_organization_id              in number
  ,p_start_date                   in date
  ,p_end_date                     in date
  ,p_object_version_number        in number
  );
end irc_ita_rki;

 

/
