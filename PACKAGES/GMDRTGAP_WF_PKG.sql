--------------------------------------------------------
--  DDL for Package GMDRTGAP_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMDRTGAP_WF_PKG" AUTHID CURRENT_USER AS
/* $Header: GMDRTGAS.pls 115.5 2002/10/29 19:08:38 txdaniel noship $ */
      /* procedure to initialize and run Workflow */
   PROCEDURE wf_init (
      p_Routing_id         IN   gmd_routings_b.Routing_id%TYPE,
      p_Routing_no         IN   gmd_routings_b.Routing_no%TYPE,
      p_Routing_vers       IN   gmd_routings_b.Routing_vers%TYPE,
      p_start_status      IN   gmd_routings_b.Routing_status%TYPE,
      p_target_status     IN   gmd_routings_b.Routing_status%TYPE,
      p_requester         IN   gmd_routings_b.LAST_UPDATED_BY%TYPE,
      p_last_update_date  IN   gmd_routings_b.LAST_UPDATE_DATE%TYPE
                );

      /* Is approval required for next Activity */

   PROCEDURE IS_APPROVAL_REQ(
      p_itemtype   IN VARCHAR2,
      p_itemkey    IN VARCHAR2,
      p_actid      IN NUMBER,
      p_funcmode   IN VARCHAR2,
      p_resultout  OUT NOCOPY VARCHAR2
   ) ;

PROCEDURE REMINDAR_CHECK (
      p_itemtype      IN VARCHAR2,
      p_itemkey       IN VARCHAR2,
      p_actid         IN NUMBER,
      p_funcmode      IN VARCHAR2,
      p_resultout     OUT NOCOPY VARCHAR2);

  PROCEDURE REQ_APPROVED (
      p_itemtype      IN VARCHAR2,
      p_itemkey       IN VARCHAR2,
      p_actid         IN NUMBER,
      p_funcmode      IN VARCHAR2,
      p_resultout     OUT NOCOPY VARCHAR2) ;

 PROCEDURE REQ_REJECTED (
      p_itemtype      IN VARCHAR2,
      p_itemkey       IN VARCHAR2,
      p_actid         IN NUMBER,
      p_funcmode      IN VARCHAR2,
      p_resultout     OUT NOCOPY VARCHAR2);

 PROCEDURE NO_RESPONSE (
      p_itemtype      IN VARCHAR2,
      p_itemkey       IN VARCHAR2,
      p_actid         IN NUMBER,
      p_funcmode      IN VARCHAR2,
      p_resultout     OUT NOCOPY VARCHAR2);

PROCEDURE MOREINFO_RESPONSE  (
      p_itemtype      IN VARCHAR2,
      p_itemkey       IN VARCHAR2,
      p_actid         IN NUMBER,
      p_funcmode      IN VARCHAR2,
      p_resultout     OUT NOCOPY VARCHAR2);
PROCEDURE APPEND_COMMENTS (
      p_itemtype      IN VARCHAR2,
      p_itemkey       IN VARCHAR2,
      p_actid         IN NUMBER,
      p_funcmode      IN VARCHAR2,
      p_resultout     OUT NOCOPY VARCHAR2);

END gmdrtgap_wf_pkg;

 

/
