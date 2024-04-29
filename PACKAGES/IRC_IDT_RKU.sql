--------------------------------------------------------
--  DDL for Package IRC_IDT_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_IDT_RKU" AUTHID CURRENT_USER as
/* $Header: iridtrhi.pkh 120.0 2005/07/26 15:07:32 mbocutt noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_default_posting_id           in number
  ,p_language                     in varchar2
  ,p_source_language              in varchar2
  ,p_org_name                     in varchar2
  ,p_org_description              in varchar2
  ,p_job_title                    in varchar2
  ,p_brief_description            in varchar2
  ,p_detailed_description         in varchar2
  ,p_job_requirements             in varchar2
  ,p_additional_details           in varchar2
  ,p_how_to_apply                 in varchar2
  ,p_image_url                    in varchar2
  ,p_image_url_alt                in varchar2
  ,p_source_language_o            in varchar2
  ,p_org_name_o                   in varchar2
  ,p_org_description_o            in varchar2
  ,p_job_title_o                  in varchar2
  ,p_brief_description_o          in varchar2
  ,p_detailed_description_o       in varchar2
  ,p_job_requirements_o           in varchar2
  ,p_additional_details_o         in varchar2
  ,p_how_to_apply_o               in varchar2
  ,p_image_url_o                  in varchar2
  ,p_image_url_alt_o              in varchar2
  );
--
end irc_idt_rku;

 

/
