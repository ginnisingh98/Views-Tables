--------------------------------------------------------
--  DDL for Package GMD_SS_TIMEPOINT_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_SS_TIMEPOINT_WF_PKG" AUTHID CURRENT_USER AS
/* $Header: GMDQSTTS.pls 115.1 2003/04/17 15:37:31 hsaleeb noship $ */

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

   PROCEDURE CANCEL_TIMEPOINT_WF(
   /* Procedure to cancel a workflow for a timepoint and reset the
	wf_sent column */
      p_timepoint      IN NUMBER,
      p_result         OUT NOCOPY VARCHAR2
    ) ;

END GMD_SS_TIMEPOINT_WF_PKG ;

 

/
