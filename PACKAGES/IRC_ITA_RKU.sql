--------------------------------------------------------
--  DDL for Package IRC_ITA_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_ITA_RKU" AUTHID CURRENT_USER as
/* $Header: iritarhi.pkh 120.0 2005/09/27 08:01 sayyampe noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
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
  ,p_template_id_o                in number
  ,p_default_association_o        in varchar2
  ,p_job_id_o                     in number
  ,p_position_id_o                in number
  ,p_organization_id_o            in number
  ,p_start_date_o                 in date
  ,p_end_date_o                   in date
  ,p_object_version_number_o      in number
  );
--
end irc_ita_rku;

 

/
