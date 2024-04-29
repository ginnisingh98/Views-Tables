--------------------------------------------------------
--  DDL for Package IRC_CMR_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_CMR_RKD" AUTHID CURRENT_USER as
/* $Header: ircmrrhi.pkh 120.0 2007/11/19 11:44:34 sethanga noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_communication_recipient_id   in number
  ,p_communication_object_type_o  in varchar2
  ,p_communication_object_id_o    in number
  ,p_recipient_type_o             in varchar2
  ,p_recipient_id_o               in number
  ,p_start_date_active_o          in date
  ,p_end_date_active_o            in date
  ,p_primary_flag_o               in varchar2
  ,p_object_version_number_o      in number
  );
--
end irc_cmr_rkd;

/