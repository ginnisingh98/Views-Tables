--------------------------------------------------------
--  DDL for Package IRC_LINKED_CANDIDATES_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_LINKED_CANDIDATES_BK1" AUTHID CURRENT_USER as
/* $Header: irilcapi.pkh 120.0.12010000.1 2010/03/17 14:06:44 vmummidi noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< <create_linked_candidate_b >--------------------|
-- ----------------------------------------------------------------------------
--
procedure create_linked_candidate_b
               (p_duplicate_set_id                in           number
                ,p_party_id                       in           number
                ,p_status                         in           varchar2
                ,p_target_party_id                in           number
               );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_linked_candidate_a >---------------------|
-- ----------------------------------------------------------------------------
--
procedure create_linked_candidate_a
                (p_link_id               in           number
                ,p_duplicate_set_id      in           number
                ,p_party_id              in           number
                ,p_status                in           varchar2
                ,p_target_party_id       in           number
                ,p_object_version_number in           number
               );
--
--
end IRC_LINKED_CANDIDATES_BK1;

/
