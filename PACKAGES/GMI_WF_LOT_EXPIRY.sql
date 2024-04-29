--------------------------------------------------------
--  DDL for Package GMI_WF_LOT_EXPIRY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMI_WF_LOT_EXPIRY" AUTHID CURRENT_USER AS
/* $Header: gmiltexs.pls 115.3 2002/10/25 16:04:28 jdiiorio ship $ */

   PROCEDURE init_wf (
      /* procedure to initialize and run Workflow
      called via trigger on ic_lots_mst */

      p_lot_id        IN   ic_lots_mst.lot_id%TYPE ,
      p_lot_no        IN   ic_lots_mst.lot_no%TYPE ,
      p_sublot_no     IN   ic_lots_mst.sublot_no%TYPE  ,
      p_expire_date   IN   ic_lots_mst.expire_date%TYPE ,
      p_item_id       IN   ic_lots_mst.item_id%TYPE ,
      p_created_by    IN   ic_lots_mst.created_by%TYPE
   ) ;

   PROCEDURE verify_expiry (
      /* procedure to confirm lot expiration called via Workflow
      parameters conform to WF standard (see WF FAQ) */
      p_itemtype   IN VARCHAR2,
      p_itemkey    IN VARCHAR2,
      p_actid      IN NUMBER,
      p_funcmode   IN VARCHAR2,
      p_resultout  OUT NOCOPY VARCHAR2
   ) ;

END gmi_wf_lot_expiry ;

 

/
