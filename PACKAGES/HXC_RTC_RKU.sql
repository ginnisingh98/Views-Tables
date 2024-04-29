--------------------------------------------------------
--  DDL for Package HXC_RTC_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_RTC_RKU" AUTHID CURRENT_USER as
/* $Header: hxcrtcrhi.pkh 120.0 2005/05/29 05:52:00 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_effective_date               in date
  ,p_retrieval_rule_comp_id       in number
  ,p_retrieval_rule_id            in number
  ,p_status                       in varchar2
  ,p_object_version_number        in number
  ,p_time_recipient_id            in number
  ,p_retrieval_rule_id_o          in number
  ,p_status_o                     in varchar2
  ,p_object_version_number_o      in number
  ,p_time_recipient_id_o          in number
  );
--
end hxc_rtc_rku;

 

/
