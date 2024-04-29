--------------------------------------------------------
--  DDL for Package ECX_WORKFLOW_HTML
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ECX_WORKFLOW_HTML" AUTHID CURRENT_USER as
/* $Header: ECXWHTMS.pls 115.4 2002/11/08 06:31:45 ndivakar noship $ */

-- ListECXMSGQueueMessages
--   Lists Queue Messages for ECXMSG ADT
--   in P_QUEUE_NAME       Queue Name
--   in P_TRANSACTION_TYPE ECX Transaction Type
--   in P_DOCUMENT_NUMBER  ECX Document Number
--   in P_PARTY_SITE_ID    ECX Party Site Id
--   in P_MESSAGE_STATUS   Queue Message Status
--   in P_MESSAGE_ID       Queue Message Id

procedure ListECXMSGQueueMessages (
  P_QUEUE_NAME        in varchar2 default null,
  P_TRANSACTION_TYPE  in varchar2 default null,
  P_DOCUMENT_NUMBER   in varchar2 default null,
  P_PARTY_SITE_ID     in varchar2 default null,
  P_MESSAGE_STATUS    in   varchar2 default 'ANY',
  P_MESSAGE_ID        in      varchar2 default null
);

-- ListECX_INENGOBJQueueMessages
--   Lists Queue Messages for ECX_INENGOBJ ADT
--   in P_QUEUE_NAME   Queue Name
--   in P_MESSAGE_STATUS Queue Message Status
--   in P_MESSAGE_ID   ECX Message Id

procedure ListECX_INENGOBJQueueMessages (
  P_QUEUE_NAME        in varchar2 default null,
  P_MESSAGE_STATUS    in   varchar2 default 'ANY',
  P_MESSAGE_ID        in      varchar2 default null
);
end ECX_WORKFLOW_HTML;

 

/
