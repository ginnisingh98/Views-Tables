--------------------------------------------------------
--  DDL for Package OKL_AM_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_AM_WF" AUTHID CURRENT_USER AS
/* $Header: OKLRAWFS.pls 120.4.12010000.2 2009/06/24 04:02:20 sechawla ship $ */

  PROCEDURE raise_business_event (p_transaction_id     IN NUMBER,
                                  p_event_name         IN VARCHAR2);

  PROCEDURE RAISE_FULFILLMENT_EVENT (
      itemtype	                     IN  VARCHAR2
	, itemkey  	                     IN  VARCHAR2
	, actid		                     IN  NUMBER
	, funcmode	                     IN  VARCHAR2
	, resultout	                     OUT NOCOPY VARCHAR2);

  PROCEDURE CALL_AM_FULFILLMENT (
      itemtype	                     IN VARCHAR2
	, itemkey  	                     IN VARCHAR2
	, actid		                     IN NUMBER
	, funcmode	                     IN VARCHAR2
	, resultout	                     OUT NOCOPY VARCHAR2);

  PROCEDURE START_APPROVAL_PROCESS (
      itemtype	                     IN VARCHAR2
	, itemkey  	                     IN VARCHAR2
	, actid		                     IN NUMBER
	, funcmode	                     IN VARCHAR2
	, resultout	                     OUT NOCOPY VARCHAR2);

  PROCEDURE SET_PARENT_ATTRIBUTES (
      itemtype	                     IN VARCHAR2
	, itemkey  	                     IN VARCHAR2
	, actid		                     IN NUMBER
	, funcmode	                     IN VARCHAR2
	, resultout	                     OUT NOCOPY VARCHAR2);

  PROCEDURE VALIDATE_APPROVAL_REQUEST (
      itemtype	                     IN VARCHAR2
	, itemkey  	                     IN VARCHAR2
	, actid		                     IN NUMBER
	, funcmode	                     IN VARCHAR2
	, resultout	                     OUT NOCOPY VARCHAR2);

  PROCEDURE GET_APPROVER (
      itemtype	                     IN VARCHAR2
	, itemkey  	                     IN VARCHAR2
	, actid		                     IN NUMBER
	, funcmode	                     IN VARCHAR2
	, resultout	                     OUT NOCOPY VARCHAR2);

  PROCEDURE SET_APPROVAL_STATUS (
      itemtype	                     IN VARCHAR2
	, itemkey  	                     IN VARCHAR2
	, actid		                     IN NUMBER
	, funcmode	                     IN VARCHAR2
	, resultout	                     OUT NOCOPY VARCHAR2);

  PROCEDURE GET_ERROR_STACK (
      itemtype	                     IN VARCHAR2
	, itemkey  	                     IN VARCHAR2
	, actid		                     IN NUMBER
	, funcmode	                     IN VARCHAR2
	, resultout	                     OUT NOCOPY VARCHAR2);

  PROCEDURE POPULATE_ERROR_ATTS(
      itemtype                       IN VARCHAR2
	, itemkey  	                     IN VARCHAR2
	, actid		                     IN NUMBER
	, funcmode	                     IN VARCHAR2
	, resultout	                     OUT NOCOPY VARCHAR2);

  PROCEDURE GET_NOTIFICATION_AGENT(
      itemtype	                     IN  VARCHAR2
	, itemkey  	                     IN  VARCHAR2
	, actid		                     IN  NUMBER
	, funcmode	                     IN  VARCHAR2
    , p_user_id                      IN  NUMBER
	, x_name  	                     OUT NOCOPY VARCHAR2
	, x_description                  OUT NOCOPY VARCHAR2);

  PROCEDURE pop_approval_doc (document_id   in varchar2,
                              display_type  in varchar2 default 'text/html',
                              document      in out nocopy varchar2,
                              document_type in out nocopy varchar2);

  PROCEDURE SET_STATUS_ON_EXIT (
      itemtype	                     IN VARCHAR2
	, itemkey  	                     IN VARCHAR2
	, actid		                     IN NUMBER
	, funcmode	                     IN VARCHAR2
	, resultout	                     OUT NOCOPY VARCHAR2);

  --added by akrangan as part of MOAC Changes
  PROCEDURE CALLBACK (itemtype IN VARCHAR2,
                                   itemkey IN VARCHAR2,
                                   activity_id IN NUMBER,
                                   command IN VARCHAR2,
                                   resultout OUT NOCOPY VARCHAR2);

  -- sechawla  - 7594853  - Added - Start
  -- Introducing call back procedure to set the user context.
  -- Method is particularly useful in case of asynchronous workflows
  -- where workflow can be run an user other than the one requesting
  PROCEDURE CALLBACK_USER (  itemtype    IN  VARCHAR2,
                             itemkey     IN  VARCHAR2,
                             activity_id IN  NUMBER,
                             command     IN  VARCHAR2,
                             resultout   OUT NOCOPY VARCHAR2);
  -- sechawla - 7594853  - Added - End


 /* Sosharma 24-Nov-06
 Build :R12
 Procedure to populate attribute values from profiles
 Start Changes*/
PROCEDURE populate_attributes (
      itemtype	                       IN VARCHAR2
	    , itemkey  	                     IN VARCHAR2
	    , actid		                        IN NUMBER
	    , funcmode	                      IN VARCHAR2
	    , resultout	                     OUT NOCOPY VARCHAR2);

/* sosharma End Changes */
END OKL_AM_WF;

/
