--------------------------------------------------------
--  DDL for Package OTA_FRM_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_FRM_RKU" AUTHID CURRENT_USER as
/* $Header: otfrmrhi.pkh 120.1 2005/07/07 06:57 aabalakr noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_effective_date               in date
  ,p_forum_id                     in number
  ,p_business_group_id            in number
  ,p_start_date_active            in date
  ,p_end_date_active              in date
  ,p_message_type_flag            in varchar2
  ,p_allow_html_flag              in varchar2
  ,p_allow_attachment_flag        in varchar2
  ,p_auto_notification_flag       in varchar2
  ,p_public_flag                  in varchar2
  ,p_object_version_number        in number
  ,p_business_group_id_o          in number
  ,p_start_date_active_o          in date
  ,p_end_date_active_o            in date
  ,p_message_type_flag_o          in varchar2
  ,p_allow_html_flag_o            in varchar2
  ,p_allow_attachment_flag_o      in varchar2
  ,p_auto_notification_flag_o     in varchar2
  ,p_public_flag_o                in varchar2
  ,p_object_version_number_o      in number
  );
--
end ota_frm_rku;

 

/
