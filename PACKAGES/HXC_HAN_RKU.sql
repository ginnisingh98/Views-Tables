--------------------------------------------------------
--  DDL for Package HXC_HAN_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_HAN_RKU" AUTHID CURRENT_USER as
/* $Header: hxchanrhi.pkh 120.0 2006/06/19 08:36:25 gsirigin noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_comp_notification_id          in number
  ,p_object_version_number        in number
  ,p_notification_number_retries  in number
  ,p_notification_timeout_value   in number
  ,p_notification_action_code     in varchar2
  ,p_notification_recipient_code  in varchar2
  ,p_notification_num_retries_o in number
  ,p_notification_timeout_value_o in number
  ,p_notification_action_code_o   in varchar2
  ,p_notification_recip_code_o in varchar2
  );
--
end hxc_han_rku;

 

/
