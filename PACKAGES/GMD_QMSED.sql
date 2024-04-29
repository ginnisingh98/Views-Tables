--------------------------------------------------------
--  DDL for Package GMD_QMSED
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_QMSED" AUTHID CURRENT_USER AS
/* $Header: GMDQMSES.pls 120.0.12010000.2 2009/03/18 21:19:36 plowe ship $ */

/* ######################################################################## */

   PROCEDURE VERIFY_EVENT(
   /* procedure to verify event if the event is sample disposition or sample event disposition */
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


END GMD_QMSED;

/
