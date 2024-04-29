--------------------------------------------------------
--  DDL for Package IRC_CMC_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_CMC_RKD" AUTHID CURRENT_USER as
/* $Header: ircmcrhi.pkh 120.0 2007/11/19 11:23:16 sethanga noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_communication_id             in number
  ,p_communication_property_id_o  in number
  ,p_object_type_o                in varchar2
  ,p_object_id_o                  in number
  ,p_status_o                     in varchar2
  ,p_start_date_o                 in date
  ,p_end_date_o                   in date
  ,p_object_version_number_o      in number
  );
--
end irc_cmc_rkd;

/
