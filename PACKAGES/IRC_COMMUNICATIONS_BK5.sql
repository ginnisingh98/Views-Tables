--------------------------------------------------------
--  DDL for Package IRC_COMMUNICATIONS_BK5
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_COMMUNICATIONS_BK5" AUTHID CURRENT_USER as
/* $Header: ircomapi.pkh 120.2.12010000.4 2010/04/07 09:53:10 vmummidi ship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< CREATE_COMM_TOPIC_b >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure CREATE_COMM_TOPIC_b
    (p_effective_date             in date
    ,p_communication_id           in number
    ,p_subject                    in varchar2
    ,p_status                     in varchar2
    );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< CREATE_COMM_TOPIC_a >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure CREATE_COMM_TOPIC_a
    (p_effective_date             in date
    ,p_communication_id           in number
    ,p_subject                    in varchar2
    ,p_status                     in varchar2
    ,p_communication_topic_id     in number
    ,p_object_version_number      in number
    );
--
end IRC_COMMUNICATIONS_BK5;

/
