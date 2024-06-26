--------------------------------------------------------
--  DDL for Package IRC_COMMUNICATIONS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_COMMUNICATIONS_BK3" AUTHID CURRENT_USER as
/* $Header: ircomapi.pkh 120.2.12010000.4 2010/04/07 09:53:10 vmummidi ship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< CREATE_COMMUNICATION_b >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure CREATE_COMMUNICATION_b
  (p_effective_date                in     date
  ,p_communication_property_id     in     number
  ,p_object_type                   in     varchar2
  ,p_object_id                     in     number
  ,p_status                        in     varchar2
  ,p_start_date                    in     date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< CREATE_COMMUNICATION_a >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure CREATE_COMMUNICATION_a
  (p_effective_date                in     date
  ,p_communication_property_id     in     number
  ,p_object_type                   in     varchar2
  ,p_object_id                     in     number
  ,p_status                        in     varchar2
  ,p_start_date                    in     date
  ,p_communication_id              in     number
  ,p_object_version_number         in     number
  );
--
end IRC_COMMUNICATIONS_BK3;

/
