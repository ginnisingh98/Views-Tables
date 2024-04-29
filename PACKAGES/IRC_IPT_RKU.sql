--------------------------------------------------------
--  DDL for Package IRC_IPT_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_IPT_RKU" AUTHID CURRENT_USER as
/* $Header: iriptrhi.pkh 120.0 2005/07/26 15:10:14 mbocutt noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_posting_content_id           in number
  ,p_language                     in varchar2
  ,p_source_language              in varchar2
  ,p_name                         in varchar2
  ,p_org_name                     in varchar2
  ,p_org_description              in varchar2
  ,p_job_title                    in varchar2
  ,p_brief_description            in varchar2
  ,p_detailed_description         in varchar2
  ,p_job_requirements             in varchar2
  ,p_additional_details           in varchar2
  ,p_how_to_apply                 in varchar2
  ,p_benefit_info                 in varchar2
  ,p_image_url                    in varchar2
  ,p_image_url_alt                in varchar2
  ,p_source_language_o            in varchar2
  ,p_name_o                       in varchar2
  ,p_org_name_o                   in varchar2
  ,p_org_description_o            in varchar2
  ,p_job_title_o                  in varchar2
  ,p_brief_description_o          in varchar2
  ,p_detailed_description_o       in varchar2
  ,p_job_requirements_o           in varchar2
  ,p_additional_details_o         in varchar2
  ,p_how_to_apply_o               in varchar2
  ,p_benefit_info_o               in varchar2
  ,p_image_url_o                  in varchar2
  ,p_image_url_alt_o              in varchar2
  );
--
end irc_ipt_rku;

 

/
