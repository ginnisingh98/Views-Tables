--------------------------------------------------------
--  DDL for Package GMDQC0_WF_P
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMDQC0_WF_P" AUTHID CURRENT_USER AS
/* $Header: GMDQC0S.pls 115.1 99/07/16 03:40:44 porting ship  $ */
   PROCEDURE init_wf (
      /* procedure to initialize and run Workflow
       called via trigger on IC_TRAN_CMP,IC_TRAN_PND */

      p_trans_id      IN   VARCHAR2,
      p_orgn_code     IN   ic_tran_pnd.orgn_code%TYPE ,
      p_whse_code     IN   ic_tran_pnd.whse_code%TYPE ,
      p_item_id       IN   ic_tran_pnd.item_id%TYPE  ,
      p_doc_type      IN   ic_tran_pnd.doc_type%TYPE ,
      p_doc_id        IN   ic_tran_pnd.doc_id%TYPE,
      p_lot_id	    IN   ic_tran_pnd.lot_id%TYPE,
      p_trans_qty     IN   NUMBER   	    );


   PROCEDURE select_role(
      -- procedure to find the role for the given item
      -- parameters conform to WF standard (see WF FAQ)
      p_itemtype   IN VARCHAR2,
      p_itemkey    IN VARCHAR2,
      p_actid      IN NUMBER,
      p_funcmode   IN VARCHAR2,
      p_resultout  OUT VARCHAR2
   ) ;

END gmdqc0_wf_p;

 

/
