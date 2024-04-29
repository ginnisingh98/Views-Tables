--------------------------------------------------------
--  DDL for Package IRC_IAD_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_IAD_RKI" AUTHID CURRENT_USER as
/* $Header: iriadrhi.pkh 120.2.12010000.2 2010/01/11 10:42:09 uuddavol ship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
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
  );
end irc_iad_rki;

/
