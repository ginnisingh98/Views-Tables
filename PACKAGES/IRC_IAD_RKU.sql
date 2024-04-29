--------------------------------------------------------
--  DDL for Package IRC_IAD_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_IAD_RKU" AUTHID CURRENT_USER as
/* $Header: iriadrhi.pkh 120.2.12010000.2 2010/01/11 10:42:09 uuddavol ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_effective_date               in date
  ,p_datetrack_mode               in varchar2
  ,p_validation_start_date        in date
  ,p_validation_end_date          in date
  ,p_assignment_details_id        in number
  ,p_assignment_id                in number
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
  ,p_details_version              in number
  ,p_latest_details               in varchar2
  ,p_attempt_id                   in number
  ,p_qualified                    in varchar2
  ,p_considered                   in varchar2
  ,p_object_version_number        in number
  ,p_assignment_id_o              in number
  ,p_effective_start_date_o       in date
  ,p_effective_end_date_o         in date
  ,p_details_version_o            in number
  ,p_latest_details_o             in varchar2
  ,p_attempt_id_o                 in number
  ,p_qualified_o                  in varchar2
  ,p_considered_o                 in varchar2
  ,p_object_version_number_o      in number
  );
--
end irc_iad_rku;

/
