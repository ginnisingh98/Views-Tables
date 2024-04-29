--------------------------------------------------------
--  DDL for Package GMIUTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMIUTILS" AUTHID CURRENT_USER AS
/* $Header: gmiutils.pls 115.5 2004/06/24 20:09:20 txyu noship $ */

/* TKW 6/2/2004 B3415691 - Enhancement for Serono */
/*  Global variables */
G_PKG_NAME  CONSTANT  VARCHAR2(30):='GMIUTILS';
G_ALLOW_NEG_INV         NUMBER:= NVL(fnd_profile.value('IC$ALLOWNEGINV'), 0);

FUNCTION get_doc_no
( x_return_status        OUT NOCOPY       VARCHAR2
, x_msg_count            OUT NOCOPY       NUMBER
, x_msg_data             OUT NOCOPY       VARCHAR2
, p_doc_type  		 IN               sy_docs_seq.doc_type%TYPE
, p_orgn_code 		 IN               sy_docs_seq.orgn_code%TYPE
) RETURN VARCHAR2;
-- BEGIN BUG#3071034 Sastry
FUNCTION get_inventory_item_id
( p_item_no         IN   VARCHAR2
, p_reset_flag      IN   BOOLEAN DEFAULT FALSE
) RETURN NUMBER;

x_inventory_item_id mtl_system_items.inventory_item_id%TYPE DEFAULT NULL;
-- END BUG#3071034

-- TKW 10/31/03 B3230887
x_item_no ic_item_mst_b.item_no%TYPE DEFAULT NULL;


/* TKW 6/2/2004 B3415691
   Enhancement for Serono
   Procedures for use before/after batch update in lot conversion form */

PROCEDURE set_allow_neg_inv;
PROCEDURE restore_allow_neg_inv;

/* TKW 6/7/2004 B3415691
   Enhancement for Serono
   Functions for neg inv and lot status */

FUNCTION NEG_INV_CHECK
(
 p_item_id	IN NUMBER,
 p_whse_code	IN VARCHAR2,
 p_lot_id	IN NUMBER,
 p_location	IN VARCHAR2,
 p_qty		IN NUMBER,
 p_qty2		IN NUMBER
)
RETURN BOOLEAN;

FUNCTION LOT_STATUS_CHECK
(
 p_item_id	IN NUMBER,
 p_whse_code	IN VARCHAR2,
 p_lot_id	IN NUMBER,
 p_location	IN VARCHAR2,
 p_doc_type	IN VARCHAR2,
 p_line_type	IN NUMBER,
 p_trans_qty	IN NUMBER,
 p_lot_status	IN VARCHAR2
)
RETURN BOOLEAN;

END GMIUTILS;


 

/
