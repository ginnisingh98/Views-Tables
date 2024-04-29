--------------------------------------------------------
--  DDL for Package IRC_IOS_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_IOS_RKI" AUTHID CURRENT_USER as
/* $Header: iriosrhi.pkh 120.2 2005/09/29 09:21 mmillmor noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_offer_status_history_id      in number
  ,p_offer_id                     in number
  ,p_status_change_date           in date
  ,p_offer_status                 in varchar2
  ,p_change_reason                in varchar2
  ,p_decline_reason               in varchar2
  ,p_object_version_number        in number
  );
end irc_ios_rki;

 

/
