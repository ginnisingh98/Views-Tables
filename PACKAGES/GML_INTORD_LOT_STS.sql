--------------------------------------------------------
--  DDL for Package GML_INTORD_LOT_STS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GML_INTORD_LOT_STS" AUTHID CURRENT_USER AS
/* $Header: GMLIOLSS.pls 115.0 2004/01/08 20:58:20 uphadtar noship $*/


-----------------------------------------------------------------------------
-- Public variables
-----------------------------------------------------------------------------

  --lot and status record
  TYPE lot_sts_rec IS RECORD
  ( lot_id         NUMBER,
    lot_status     VARCHAR2(4));

  --lot and status plsql table
  TYPE lot_sts_table IS TABLE OF lot_sts_rec
  INDEX BY BINARY_INTEGER;

  --global lot and status plsql table variable
  G_lot_sts_tab lot_sts_table;

  --caching the profiles
  G_move_diff_stat      NUMBER      :=  NVL(FND_PROFILE.VALUE('IC$MOVEDIFFSTAT'),0);
  G_retain_ship_lot_sts VARCHAR2(1) :=  NVL(fnd_profile.value('GMI_INT_ORD_LOT_STS'),'N');

-----------------------------------------------------------------------------
-- Public subprograms
-----------------------------------------------------------------------------


PROCEDURE derive_porc_lot_status
 (  p_item_id                 IN            NUMBER
 ,  p_whse_code               IN            VARCHAR2
 ,  p_lot_id                  IN            NUMBER
 ,  p_location                IN            VARCHAR2
 ,  p_ship_lot_status         IN            VARCHAR2
 ,  x_rcpt_lot_status         IN OUT NOCOPY VARCHAR2
 ,  x_txn_allowed                OUT NOCOPY VARCHAR2
 ,  x_return_status              OUT NOCOPY VARCHAR2
 ,  x_msg_data                   OUT NOCOPY VARCHAR2
 ) ;

PROCEDURE change_inv_lot_status
 (  p_item_id                 IN            NUMBER
 ,  p_whse_code               IN            VARCHAR2
 ,  p_lot_id                  IN            NUMBER
 ,  p_location                IN            VARCHAR2
 ,  p_to_status               IN            VARCHAR2
 ,  x_return_status              OUT NOCOPY VARCHAR2
 ,  x_msg_data                   OUT NOCOPY VARCHAR2
 ) ;

PROCEDURE get_omso_lot_status
 (  p_req_line_id             IN            NUMBER
 ,  p_item_id                 IN            NUMBER
 ,  x_lot_sts_tab             IN OUT NOCOPY lot_sts_table
 ,  x_return_status              OUT NOCOPY VARCHAR2
 ,  x_msg_data                   OUT NOCOPY VARCHAR2
 ) ;


END GML_INTORD_LOT_STS;

 

/
