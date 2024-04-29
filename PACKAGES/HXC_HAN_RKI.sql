--------------------------------------------------------
--  DDL for Package HXC_HAN_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_HAN_RKI" AUTHID CURRENT_USER as
/* $Header: hxchanrhi.pkh 120.0 2006/06/19 08:36:25 gsirigin noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_comp_notification_id          in number
  ,p_object_version_number        in number
  ,p_notification_number_retries  in number
  ,p_notification_timeout_value   in number
  ,p_notification_action_code     in varchar2
  ,p_notification_recipient_code  in varchar2
  );
end hxc_han_rki;

 

/
