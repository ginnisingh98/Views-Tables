--------------------------------------------------------
--  DDL for Package GMDFMLAP_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMDFMLAP_WF_PKG" AUTHID CURRENT_USER AS
/* $Header: GMDFMLAS.pls 115.3 2002/10/29 19:38:44 txdaniel noship $ */
      /* procedure to initialize and run Workflow */
   PROCEDURE wf_init (
      p_Formula_id         IN   FM_FORM_MST_B.Formula_id%TYPE,
      p_Formula_no         IN   FM_FORM_MST_B.Formula_no%TYPE,
      p_Formula_vers       IN   FM_FORM_MST_B.Formula_vers%TYPE,
      p_start_status      IN   FM_FORM_MST_B.Formula_status%TYPE,
      p_target_status     IN   FM_FORM_MST_B.Formula_status%TYPE,
      p_requester         IN   FM_FORM_MST_B.LAST_UPDATED_BY%TYPE,
      p_last_update_date  IN   FM_FORM_MST_B.LAST_UPDATE_DATE%TYPE
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

END gmdfmlap_wf_pkg;

 

/
