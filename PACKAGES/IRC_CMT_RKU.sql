--------------------------------------------------------
--  DDL for Package IRC_CMT_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_CMT_RKU" AUTHID CURRENT_USER as
/* $Header: ircmtrhi.pkh 120.0 2007/11/19 11:51:32 sethanga noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_effective_date               in date
  ,p_communication_topic_id       in number
  ,p_communication_id             in number
  ,p_subject                      in varchar2
  ,p_status                       in varchar2
  ,p_object_version_number        in number
  ,p_communication_id_o           in number
  ,p_subject_o                    in varchar2
  ,p_status_o                     in varchar2
  ,p_object_version_number_o      in number
  );
--
end irc_cmt_rku;

/
