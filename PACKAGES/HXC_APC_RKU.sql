--------------------------------------------------------
--  DDL for Package HXC_APC_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_APC_RKU" AUTHID CURRENT_USER as
/* $Header: hxcapcrhi.pkh 120.0 2005/05/29 05:24:25 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_effective_date               in date
  ,p_approval_period_comp_id      in number
  ,p_time_recipient_id            in number
  ,p_recurring_period_id          in number
  ,p_approval_period_set_id       in number
  ,p_object_version_number        in number
  ,p_time_recipient_id_o          in number
  ,p_recurring_period_id_o        in number
  ,p_approval_period_set_id_o     in number
  ,p_object_version_number_o      in number
  );
--
end hxc_apc_rku;

 

/
