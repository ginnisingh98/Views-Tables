--------------------------------------------------------
--  DDL for Package IRC_COMMUNICATIONS_BK7
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_COMMUNICATIONS_BK7" AUTHID CURRENT_USER as
/* $Header: ircomapi.pkh 120.2.12010000.4 2010/04/07 09:53:10 vmummidi ship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< UPDATE_MESSAGE_b >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure UPDATE_MESSAGE_b
  (p_effective_date               in     date
  ,p_deleted_flag                 in     varchar2
  ,p_communication_message_id     in     number
  ,p_object_version_number        in     number
   );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< UPDATE_MESSAGE_a >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure UPDATE_MESSAGE_a
    (p_effective_date             in     date
    ,p_deleted_flag               in     varchar2
    ,p_communication_message_id   in     number
    ,p_object_version_number      in     number
    );
--
end IRC_COMMUNICATIONS_BK7;

/
