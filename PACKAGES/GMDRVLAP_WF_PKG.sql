--------------------------------------------------------
--  DDL for Package GMDRVLAP_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMDRVLAP_WF_PKG" AUTHID CURRENT_USER AS
/* $Header: GMDRVLAS.pls 115.3 2002/10/29 19:26:26 txdaniel noship $ */
      /* procedure to initialize and run Workflow */
   PROCEDURE wf_init (
      p_recipe_validity_rule_id         IN   GMD_RECIPE_VALIDITY_RULES.recipe_validity_rule_id%TYPE,
      p_recipe_id                       IN   GMD_RECIPE_VALIDITY_RULES.recipe_id%TYPE,
      p_start_status                    IN   GMD_RECIPE_VALIDITY_RULES.validity_rule_status%TYPE,
      p_target_status                   IN   GMD_RECIPE_VALIDITY_RULES.validity_rule_status%TYPE,
      p_requester                       IN   GMD_RECIPE_VALIDITY_RULES.LAST_UPDATED_BY%TYPE,
      p_last_update_date                IN   GMD_RECIPE_VALIDITY_RULES.LAST_UPDATE_DATE%TYPE
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


END gmdrvlap_wf_pkg;

 

/
