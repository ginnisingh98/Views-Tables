--------------------------------------------------------
--  DDL for Package HR_WPM_NTF_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_WPM_NTF_UTIL" AUTHID CURRENT_USER AS
/* $Header: hrwpmntf.pkh 120.0.12010000.1 2008/07/28 03:58:46 appldev ship $*/

   SUCCESS number := 1;
   FAILURE  number := 0;

/*
   FUNCTION send_notification
     ( from_person_id per_all_people_f.person_id%TYPE,
       to_person_id per_all_people_f.person_id%TYPE,
       action_type varchar2,
       subject_message varchar2,
       score_card_id per_personal_scorecards.scorecard_id%TYPE,
       reason varchar2)
     RETURN  number;
*/

   FUNCTION send_notification
     ( action_type varchar2,
       score_card_id per_personal_scorecards.scorecard_id%TYPE,
       to_or_from_mgr_ntf varchar2,
       reason varchar2)
     return number;



END HR_WPM_NTF_UTIL; -- Package spec


/
