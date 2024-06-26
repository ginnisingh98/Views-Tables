--------------------------------------------------------
--  DDL for Package IRC_IAS_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_IAS_RKU" AUTHID CURRENT_USER as
/* $Header: iriasrhi.pkh 120.0.12010000.2 2009/07/30 03:43:17 vmummidi ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_assignment_status_id         in number
  ,p_assignment_id                in number
  ,p_status_change_reason         in varchar2
  ,p_object_version_number        in number
  ,p_assignment_status_type_id    in number
  ,p_status_change_date           in date
  ,p_status_change_comments       in varchar2
  ,p_status_change_by             in varchar2
  ,p_assignment_id_o              in number
  ,p_status_change_reason_o       in varchar2
  ,p_object_version_number_o      in number
  ,p_assignment_status_type_id_o  in number
  ,p_status_change_date_o         in date
  ,p_status_change_comments_o     in varchar2
  ,p_status_change_by_o           in varchar2
  );
--
end irc_ias_rku;

/
