--------------------------------------------------------
--  DDL for Package OTA_CTL_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_CTL_RKI" AUTHID CURRENT_USER as
/* $Header: otctlrhi.pkh 120.1 2005/12/01 16:42 cmora noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_certification_id             in number
  ,p_language                     in varchar2
  ,p_name                         in varchar2
  ,p_description                  in varchar2
  ,p_objectives                   in varchar2
  ,p_purpose                      in varchar2
  ,p_keywords                     in varchar2
  ,p_end_date_comments            in varchar2
  ,p_initial_period_comments      in varchar2
  ,p_renewal_period_comments      in varchar2
  ,p_source_lang                  in varchar2
  );
end ota_ctl_rki;

 

/
