--------------------------------------------------------
--  DDL for Package IRC_IPT_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_IPT_RKI" AUTHID CURRENT_USER as
/* $Header: iriptrhi.pkh 120.0 2005/07/26 15:10:14 mbocutt noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
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
  );
end irc_ipt_rki;

 

/
