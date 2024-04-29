--------------------------------------------------------
--  DDL for Package OTA_CTL_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_CTL_RKD" AUTHID CURRENT_USER as
/* $Header: otctlrhi.pkh 120.1 2005/12/01 16:42 cmora noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_certification_id             in number
  ,p_language                     in varchar2
  ,p_name_o                       in varchar2
  ,p_description_o                in varchar2
  ,p_objectives_o                 in varchar2
  ,p_purpose_o                    in varchar2
  ,p_keywords_o                   in varchar2
  ,p_end_date_comments_o          in varchar2
  ,p_initial_period_comments_o    in varchar2
  ,p_renewal_period_comments_o    in varchar2
  ,p_source_lang_o                in varchar2
  );
--
end ota_ctl_rkd;

 

/
