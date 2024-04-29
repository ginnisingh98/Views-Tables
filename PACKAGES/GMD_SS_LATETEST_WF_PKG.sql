--------------------------------------------------------
--  DDL for Package GMD_SS_LATETEST_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_SS_LATETEST_WF_PKG" AUTHID CURRENT_USER AS
/* $Header: GMDQSLTS.pls 115.0 2003/04/08 21:32:11 hsaleeb noship $ */

/* ######################################################################## */

   PROCEDURE VERIFY_EVENT(
   /* procedure to verify event and send out notification */
      p_itemtype      IN VARCHAR2,
      p_itemkey       IN VARCHAR2,
      p_actid         IN NUMBER,
      p_funcmode      IN VARCHAR2,
      p_resultout     OUT NOCOPY VARCHAR2
   );

   PROCEDURE CHECK_NEXT_APPROVER(
   /* procedure to Check next approver if any */
      p_itemtype      IN VARCHAR2,
      p_itemkey       IN VARCHAR2,
      p_actid         IN NUMBER,
      p_funcmode      IN VARCHAR2,
      p_resultout     OUT NOCOPY VARCHAR2
   );


END GMD_SS_LATETEST_WF_PKG ;

 

/
