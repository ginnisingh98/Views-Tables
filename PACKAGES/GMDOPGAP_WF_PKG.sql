--------------------------------------------------------
--  DDL for Package GMDOPGAP_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMDOPGAP_WF_PKG" AUTHID CURRENT_USER AS
/* $Header: GMDOPGAS.pls 115.4 2002/10/29 18:29:09 txdaniel noship $ */
      /* procedure to initialize and run Workflow */
   PROCEDURE wf_init (
      p_operation_id         IN   GMD_OPERATIONS_B.oprn_id%TYPE,
      p_operation_no         IN   GMD_OPERATIONS_B.oprn_no%TYPE,
      p_operation_vers       IN   GMD_OPERATIONS_B.oprn_vers%TYPE,
      p_start_status      IN   GMD_OPERATIONS_B.operation_status%TYPE,
      p_target_status     IN   GMD_OPERATIONS_B.operation_status%TYPE,
      p_requester         IN   GMD_OPERATIONS_B.LAST_UPDATED_BY%TYPE,
      p_last_update_date  IN   GMD_OPERATIONS_B.LAST_UPDATE_DATE%TYPE
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

END gmdopgap_wf_pkg;

 

/
