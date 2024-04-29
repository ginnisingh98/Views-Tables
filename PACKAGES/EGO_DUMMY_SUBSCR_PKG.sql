--------------------------------------------------------
--  DDL for Package EGO_DUMMY_SUBSCR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_DUMMY_SUBSCR_PKG" AUTHID CURRENT_USER AS
/* $Header: EGOSBSCRS.pls 120.3 2006/04/26 03:48 swshukla noship $ */
  /*FUNCTION dummy_subscription (P_SUBSCRIPTION_GUID IN RAW,
                               P_EVENT IN OUT NOCOPY wf_event_t)
  RETURN VARCHAR2;*/

PROCEDURE SET_EGO_EVENT_INFO(
          itemtype  IN VARCHAR2,
          itemkey   IN VARCHAR2,
          actid     IN NUMBER,
          funcmode  IN VARCHAR2,
          result    IN OUT NOCOPY VARCHAR2
);

END EGO_DUMMY_SUBSCR_PKG;

 

/
