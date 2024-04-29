--------------------------------------------------------
--  DDL for Package IRC_COMMUNICATIONS_BK8
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_COMMUNICATIONS_BK8" AUTHID CURRENT_USER as
/* $Header: ircomapi.pkh 120.2.12010000.4 2010/04/07 09:53:10 vmummidi ship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< ADD_RECIPIENT_b >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure ADD_RECIPIENT_b
    (p_effective_date                in date
    ,p_communication_object_type     in varchar2
    ,p_communication_object_id       in number
    ,p_recipient_type                in varchar2
    ,p_recipient_id                  in number
    ,p_start_date_active             in date
    ,p_end_date_active               in date
    ,p_primary_flag                  in varchar2
    );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< ADD_RECIPIENT_a >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure ADD_RECIPIENT_a
    (p_effective_date                in date
    ,p_communication_object_type     in varchar2
    ,p_communication_object_id       in number
    ,p_recipient_type                in varchar2
    ,p_recipient_id                  in number
    ,p_start_date_active             in date
    ,p_end_date_active               in date
    ,p_primary_flag                  in varchar2
    ,p_communication_recipient_id    in number
    ,p_object_version_number         in number
    );
--
end IRC_COMMUNICATIONS_BK8;

/
