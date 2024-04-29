--------------------------------------------------------
--  DDL for Package IRC_CMC_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_CMC_RKI" AUTHID CURRENT_USER as
/* $Header: ircmcrhi.pkh 120.0 2007/11/19 11:23:16 sethanga noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_communication_id             in number
  ,p_communication_property_id    in number
  ,p_object_type                  in varchar2
  ,p_object_id                    in number
  ,p_status                       in varchar2
  ,p_start_date                   in date
  ,p_end_date                     in date
  ,p_object_version_number        in number
  );
end irc_cmc_rki;

/
