--------------------------------------------------------
--  DDL for Package GMIVQTY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMIVQTY" AUTHID CURRENT_USER AS
/* $Header: GMIVQTYS.pls 115.9 2002/11/11 21:41:55 jdiiorio ship $  */

  PROCEDURE Construct_Txn_Rec
                        ( p_ic_adjs_jnl_row IN ic_adjs_jnl%ROWTYPE
                        , x_tran_rec    OUT NOCOPY GMI_TRANS_ENGINE_PUB.ictran_rec
                        );
  PROCEDURE Validate_Inventory_Posting
                        (  p_api_version      IN  NUMBER
                         , p_validation_level IN  NUMBER
                         , p_qty_rec          IN  GMIGAPI.qty_rec_typ
                         , p_ic_item_mst_row  IN ic_item_mst%ROWTYPE
                         , p_ic_item_cpg_row  IN ic_item_cpg%ROWTYPE
			 , p_ic_lots_mst_row  IN ic_lots_mst%ROWTYPE
                         , p_ic_lots_cpg_row  IN ic_lots_cpg%ROWTYPE
                         , x_ic_jrnl_mst_row  OUT NOCOPY ic_jrnl_mst%ROWTYPE
                         , x_ic_adjs_jnl_row1 OUT NOCOPY ic_adjs_jnl%ROWTYPE
                         , x_ic_adjs_jnl_row2 OUT NOCOPY ic_adjs_jnl%ROWTYPE
                         , x_return_status    OUT NOCOPY VARCHAR2
                         , x_msg_count        OUT NOCOPY NUMBER
                         , x_msg_data         OUT NOCOPY VARCHAR2
                        );
END GMIVQTY;

 

/
