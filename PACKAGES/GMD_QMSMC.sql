--------------------------------------------------------
--  DDL for Package GMD_QMSMC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_QMSMC" AUTHID CURRENT_USER AS
/* $Header: GMDQMSMS.pls 120.2.12010000.1 2008/07/24 09:58:27 appldev ship $ */

/* ######################################################################## */

   PROCEDURE VERIFY_EVENT(
   /* procedure to verify which event is raised */
      p_itemtype      IN VARCHAR2,
      p_itemkey       IN VARCHAR2,
      p_actid         IN NUMBER,
      p_funcmode      IN VARCHAR2,
      p_resultout     OUT NOCOPY VARCHAR2
   );

   /* procedure to get the document number based on the doc_id and doc_type */
/* Bug 4165704 INVCONV: not used
   PROCEDURE GET_DOC_NO(
      p_doc_id        IN NUMBER,
      p_doc_type      IN VARCHAR2,
      p_doc_no        OUT NOCOPY NUMBER
   ); */
-- Bug #3361101 (JKB) Added get_doc_no above.


   PROCEDURE CHECK_NEXT_APPROVER(
   /* procedure to Check next approver if any */
      p_itemtype      IN VARCHAR2,
      p_itemkey       IN VARCHAR2,
      p_actid         IN NUMBER,
      p_funcmode      IN VARCHAR2,
      p_resultout     OUT NOCOPY VARCHAR2
   );

  PROCEDURE PRODUCTION(
   /* procedure to Check next approver if any */
      p_itemtype      IN VARCHAR2,
      p_itemkey       IN VARCHAR2,
      p_actid         IN NUMBER,
      p_funcmode      IN VARCHAR2,
      p_resultout     OUT NOCOPY VARCHAR2
   );

/* RLNAGARA Bug 5032406 (FP of 4604305 ME) Added new procedure */
   PROCEDURE IS_STEP(
   /* procedure to check if the event is raised for a batch step level transaction */
      p_itemtype      IN VARCHAR2,
      p_itemkey       IN VARCHAR2,
      p_actid         IN NUMBER,
      p_funcmode      IN VARCHAR2,
      p_resultout     OUT NOCOPY VARCHAR2
   );


END GMD_QMSMC;

/
