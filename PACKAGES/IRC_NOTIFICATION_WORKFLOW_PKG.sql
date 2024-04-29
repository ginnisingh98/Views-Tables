--------------------------------------------------------
--  DDL for Package IRC_NOTIFICATION_WORKFLOW_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_NOTIFICATION_WORKFLOW_PKG" AUTHID CURRENT_USER as
  /* $Header: irntfwfl.pkh 120.4.12010000.4 2009/07/30 15:30:22 amikukum ship $ */
--+ Global variables
  g_WFItemType varchar2(100);
  g_package    constant varchar2(50) := 'IRC_NOTIFICATION_WORKFLOW_PKG';
--+
--+ launchNotificationsWorkflow
--+
  function launchNotificationsWorkflow ( p_subscriptionGuid in raw
                                       , p_event             in out nocopy WF_EVENT_T ) return varchar2;
--+
--+  loadWorkflowAttributes
--+

  procedure loadWorkflowAttributes ( p_eventData in varchar2
                                   , p_itemType  in varchar2
                                   , p_itemKey   in varchar2 );
--+
--+ parseAndReplaceFNDMessage
--+
  function parseAndReplaceFNDMessage ( p_itemType in varchar2
                                     , p_itemKey  in varchar2
                                     , p_message  in varchar2
                                     , p_personId in varchar2 default null
                                     , p_personType in varchar2 default null )
				     return varchar2;
--+
--+ getNextRecipient
--+
  procedure getNextRecipient ( p_itemType    in varchar2
                             , p_itemKey     in varchar2
                             , p_activityId  in number
                             , funmode       in varchar2
                             , result        out nocopy varchar2 );
--+
--+ getWFAttrValue
--+
  function getWFAttrValue ( p_itemKey in varchar2
                          , p_WFAttr in varchar2 ) return varchar2;
--+
--+ isValidRecipient
--+
  function isValidRecipient (p_recipient in VARCHAR2) return VARCHAR2;
--+
--+ checkIfIntvwCandidateIncluded
--+
  function checkIfIntvwCandidateIncluded (p_modifiedItemsString varchar2
                                         , p_eventName varchar2)
    return varchar2;
--+
--+ getDocument
--+
  procedure getDocument (p_documentId   in varchar2
                        ,p_displayType  in varchar2
                        ,p_document in  out nocopy varchar2
                        ,p_documentType in out nocopy varchar2);
--+
--+ attatchDoc
--+
procedure attatchDoc(   document_id   IN VARCHAR2
                       ,display_type  IN VARCHAR2
                       ,document      IN OUT nocopy blob
                       ,document_type IN OUT nocopy VARCHAR2);
--+
--attach the calender file
procedure attatchICDoc( document_id   IN VARCHAR2
                      ,display_type  IN VARCHAR2
                      ,document      IN OUT nocopy blob
                      ,document_type IN OUT nocopy VARCHAR2);
--+
end IRC_NOTIFICATION_WORKFLOW_PKG;

/
