--------------------------------------------------------
--  DDL for Package HXC_RTC_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_RTC_RKD" AUTHID CURRENT_USER as
/* $Header: hxcrtcrhi.pkh 120.0 2005/05/29 05:52:00 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_retrieval_rule_comp_id       in number
  ,p_retrieval_rule_id_o          in number
  ,p_status_o                     in varchar2
  ,p_object_version_number_o      in number
  ,p_time_recipient_id_o          in number
  );
--
end hxc_rtc_rkd;

 

/
