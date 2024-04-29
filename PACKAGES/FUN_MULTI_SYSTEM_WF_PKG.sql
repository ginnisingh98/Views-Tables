--------------------------------------------------------
--  DDL for Package FUN_MULTI_SYSTEM_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FUN_MULTI_SYSTEM_WF_PKG" AUTHID CURRENT_USER AS
/* $Header: funmulss.pls 120.0 2003/05/01 23:27:09 yingli noship $ */


  -- Check a party is a local party or remote party
  FUNCTION IS_LOCAL (p_party_id IN  NUMBER) return boolean;

  -- Raise transaction is sent by the initiator events for all
  -- the local recipients

  PROCEDURE RAISE_LOCAL_EVENTS(itemtype           IN VARCHAR2,
                               itemkey            IN VARCHAR2,
                               actid              IN NUMBER,
                               funcmode           IN VARCHAR2,
                               resultout          OUT  NOCOPY VARCHAR2);

  -- Set workflow item attributes for the process

   PROCEDURE SET_ATTRIBUTES   (itemtype           IN VARCHAR2,
                               itemkey            IN VARCHAR2,
                               actid              IN NUMBER,
                               funcmode           IN VARCHAR2,
                               resultout          OUT NOCOPY  VARCHAR2);

 -- Determine the remote instance Number

   PROCEDURE COUNT_REMOTE      (itemtype          IN VARCHAR2,
                               itemkey            IN VARCHAR2,
                               actid              IN NUMBER,
                               funcmode           IN VARCHAR2,
                               resultout          OUT NOCOPY  VARCHAR2);

 -- Check the trading partner is a local party or not;
 -- The trading partner is different according to the event
 -- set the item attribute RECEIVE_EVENT_NAME and event key(LOCAL_EVENT_KEY);

   PROCEDURE CHECK_TP_LOCAL   (itemtype           IN VARCHAR2,
                               itemkey            IN VARCHAR2,
                               actid              IN NUMBER,
                               funcmode           IN VARCHAR2,
                               resultout          OUT NOCOPY VARCHAR2);


END FUN_MULTI_SYSTEM_WF_PKG;


 

/
