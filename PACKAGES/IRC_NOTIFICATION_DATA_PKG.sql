--------------------------------------------------------
--  DDL for Package IRC_NOTIFICATION_DATA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_NOTIFICATION_DATA_PKG" AUTHID CURRENT_USER as
  /* $Header: irntfdat.pkh 120.5.12010000.4 2009/09/09 10:33:23 dparthas ship $ */
--+ Global variables
  g_package    constant varchar2(50) := 'IRC_NOTIFICATION_DATA_PKG';
--+
--+ getParamValue
--+
  function getParamValue ( p_param     in varchar2
                         , p_eventData in varchar2) return varchar2;
--+
--+
--+
  function getVacancyId ( p_assignmentId  in number
                        , p_effectiveDate in date) return number;
--+
--+ getCandidatePersonId
--+
  function getCandidatePersonId ( p_assignmentId      in number
                                , p_effectiveDate in date
                                , p_event_name        in  varchar2 default null) return number;
--+
--+
--+
  function getCandidateAgencyId(p_candidateId    in number
                                ,p_effectiveDate in date) return varchar2;
--+
--+ getManagerId
--+
  function getManagerPersonId ( p_vacancyId     in number
                              , p_effectiveDate in date) return number;
--+
--+ getRecruiterId
--+
  function getRecruiterPersonId ( p_assignmentId     in number
                                , p_effectiveDate in date) return number;
--+
--+ getVacancyDetails
--+
  function getVacancyDetails ( p_vacancyId     in number
                             , p_effectiveDate in date) return varchar2;
--+
--+ getCommunicationTopicDetails
--+
  function getCommunicationTopicDetails ( p_topicId   in number
                                         , p_messageId in number) return varchar2;
--+
--+ getInterviewDetails
--+
  function getInterviewDetails ( p_interviewId   in number
                               , p_effectiveDate in date) return varchar2;
--+
--+ getPersonDetails
--+
  function getPersonDetails ( p_personId      in number
                            , p_role          in varchar2
                            , p_effectiveDate in date) return varchar2;
--+
--+ getApplicationExtStatus
--+
  function getApplicationExtStatus ( p_assignmentStatusCode in number) return varchar2;
--+
--+
--+
--+ getApplicationExtStatus
--+
  function getApplicationOldExtStatus ( p_AssignmentOldStatusCode in number) return varchar2;
--+
--+ getApplicationStatus
--+
  function getApplicationStatus( p_assignmentStatusCode in number ) return varchar2;
--+
--+getInterviewStatusMeaning
--+
  function getInterviewStatusMeaning (p_interviewStatusCode in varchar2
                                     ,p_attributeName       in varchar2) return varchar2;
--+
--+
--+
  function getInterviersNamesHTML( p_interviewId  in number
                                , p_effectiveDate in date)
           return varchar2;
--+
end IRC_NOTIFICATION_DATA_PKG;

/
