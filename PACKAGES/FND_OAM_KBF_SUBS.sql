--------------------------------------------------------
--  DDL for Package FND_OAM_KBF_SUBS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_OAM_KBF_SUBS" AUTHID CURRENT_USER AS
/* $Header: AFOAMSBS.pls 115.12 2002/12/04 20:15:23 rmohan noship $ */

---Common Constants
COMP_TYPE_UNKNOWN CONSTANT VARCHAR2(7) := 'UNKNOWN';

  /*
   **  CreateSubList
   **  Description:
   **  It is used to retrive WF_ROLES.USER_ID of all the people wants
   **  to be notified about the exception message.
   **  It Looks the FND_KBF_SUBSCRIPTION table for matching the USER_ID
   **  and filter criteria is bnased on
   **  APPLICATION_ID+COMPONENT_TYPE/BIZ_FLOW_ID, SEVERITY, CATEGORY of
   **  the message.
   **  The retrieved list is used to create adHoc WF_ROLE using
   **  WF_DIRECTORY.CreateAdHocRole api
   **
   **  Arguments:
   **      pItemtype    - WF Item Type
   **      pItemkey     - WF Item Key
   **      pActid       - WF Activity ID
   **
   **  Returns:
   **      pResultout - List of subscriber, if there is no user,
   **     pResultout is set to 'NULL'
   **
   **
   */
   procedure CreateSubList(itemtype in varchar2,
      itemkey in varchar2,
      actid in number,
      funcmode in varchar2,
      resultout out NOCOPY varchar2);



  /*
   **  createSubject
   **  Description:
   **  It retrives Subject for the  given document_id(Log sequence)
   **
   **  Arguments:
   **      document_id    -
   **      display_type     - text
   **
   **
   **  Returns:
   **      document - Subject
   **      document_type - text
   **
   */
   procedure createSubject(document_id in varchar2,
                          display_type in varchar2,
                          document in out NOCOPY varchar2,
                          document_type in out NOCOPY varchar2);



  /*
   **  createBusExcepDoc
   **  Description:
   **  It retrives the message using FND_LOG.message API for a given message_id
   **
   **  Arguments:
   **      document_id    -
   **      display_type     - text
   **
   **
   **  Returns:
   **      document - Actual Message for the message_id
   **      document_type - text
   **
   */
   procedure createBusExcepDoc(document_id in varchar2,
                            display_type in varchar2,
                            document in out NOCOPY varchar2,
                            document_type in out NOCOPY varchar2);




  /*
   **  createBusExcepDoc
   **  Description:
   **  It retrives the context information about exception
   **
   **  Arguments:
   **      document_id    -
   **      display_type     - text
   **
   **
   **  Returns:
   **      document - Context information.
   **      document_type - text
   **
   */
 procedure createBusExcepDocPart1(document_id in varchar2,
                            display_type in varchar2,
                            document in out NOCOPY varchar2,
                            document_type in out NOCOPY varchar2);


--This is for test purpose only
---  FUNCTION  raise_oamEvent
---    (v_comm   IN   VARCHAR2)
---    RETURN VARCHAR2;

--  FUNCTION SHALL_ADD_SUBS_SEVERITY
--    (pItemSub IN VARCHAR2, pItemException IN VARCHAR2)
--     RETURN BOOLEAN;

--  FUNCTION SHALL_ADD_SUBS
--    (pItemSub IN VARCHAR2, pItemException IN VARCHAR2)
--     RETURN BOOLEAN;

 END FND_OAM_KBF_SUBS;

 

/
