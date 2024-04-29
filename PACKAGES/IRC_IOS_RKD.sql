--------------------------------------------------------
--  DDL for Package IRC_IOS_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_IOS_RKD" AUTHID CURRENT_USER as
/* $Header: iriosrhi.pkh 120.2 2005/09/29 09:21 mmillmor noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_offer_status_history_id      in number
  ,p_offer_id_o                   in number
  ,p_status_change_date_o         in date
  ,p_offer_status_o               in varchar2
  ,p_change_reason_o              in varchar2
  ,p_decline_reason_o             in varchar2
  ,p_object_version_number_o      in number
  );
--
end irc_ios_rkd;

 

/
