--------------------------------------------------------
--  DDL for Package IRC_CANDIDATE_TEST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_CANDIDATE_TEST" AUTHID CURRENT_USER as
/* $Header: ircndtst.pkh 120.0 2005/07/26 15:00:05 mbocutt noship $ */
--
-- this function tests whether a person is an iRecruitment candidate
-- or not, returning TRUE if they are a candidate, or FALSE if they
-- are not
--
-- -------------------------------------------------------------------------
-- |------------------------< is_person_a_candidate >----------------------|
-- -------------------------------------------------------------------------
--
function is_person_a_candidate
(p_person_id in number)
return boolean;
--
end irc_candidate_test;

 

/
