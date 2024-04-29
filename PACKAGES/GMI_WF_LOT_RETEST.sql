--------------------------------------------------------
--  DDL for Package GMI_WF_LOT_RETEST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMI_WF_LOT_RETEST" AUTHID CURRENT_USER AS
/* $Header: gmiltrts.pls 115.2 2002/10/25 16:07:40 jdiiorio ship $ */

   PROCEDURE init_wf (
      /* procedure to initialize and run Workflow */
      p_lot_id        IN   ic_lots_mst.lot_id%TYPE ,
      p_lot_no        IN   ic_lots_mst.lot_no%TYPE ,
      p_sublot_no     IN   ic_lots_mst.sublot_no%TYPE  ,
      p_retest_date   IN   ic_lots_mst.retest_date%TYPE ,
      p_item_id       IN   ic_lots_mst.item_id%TYPE ,
      p_created_by    IN   ic_lots_mst.created_by%TYPE
   ) ;

   PROCEDURE verify_retest (
      /* procedure to confirm lot expiration called via Workflow
      parameters conform to WF standard (see WF FAQ)*/
      p_itemtype   IN VARCHAR2,
      p_itemkey    IN VARCHAR2,
      p_actid      IN NUMBER,
      p_funcmode   IN VARCHAR2,
      p_resultout  OUT NOCOPY VARCHAR2
   ) ;

END gmi_wf_lot_retest ;

 

/
