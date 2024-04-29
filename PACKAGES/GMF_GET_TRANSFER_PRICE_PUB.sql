--------------------------------------------------------
--  DDL for Package GMF_GET_TRANSFER_PRICE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_GET_TRANSFER_PRICE_PUB" AUTHID CURRENT_USER AS
/* $Header: GMFGXFRS.pls 120.1.12010000.2 2009/12/21 18:39:39 uphadtar ship $ */

  G_SKIP_IC_PARAM_FOR_PD_XFER  CONSTANT VARCHAR2(1) := 'N';

  Procedure get_transfer_price
    ( p_api_version                       IN            NUMBER
    , p_init_msg_list                     IN            VARCHAR2

    , p_inventory_item_id                 IN            NUMBER
    , p_transaction_qty                   IN            NUMBER
    , p_transaction_uom                   IN            VARCHAR2

    , p_transaction_id                    IN            NUMBER  /* Order Line Id for now */
    , p_global_procurement_flag           IN            VARCHAR2
    , p_drop_ship_flag                    IN            VARCHAR2

    , p_from_organization_id              IN            NUMBER
    , p_from_ou                           IN            NUMBER  /* from OU */
    , p_to_organization_id                IN            NUMBER
    , p_to_ou                             IN            NUMBER  /* to OU */

    , p_transfer_type                     IN            VARCHAR2
    , p_transfer_source                   IN            VARCHAR2  /* INTORG, INTORD, INTREQ */
    , p_transaction_date                  IN            DATE     DEFAULT NULL  /* Bug 9189961 */

    , x_return_status                     OUT NOCOPY    VARCHAR2
    , x_msg_data                          OUT NOCOPY    VARCHAR2
    , x_msg_count                         OUT NOCOPY    NUMBER

    , x_transfer_price                    OUT NOCOPY    NUMBER   /* In Txn UOM */
    , x_transfer_price_priuom             OUT NOCOPY    NUMBER   /* In Item Primary UOM */
    , x_currency_code                     OUT NOCOPY    VARCHAR2
    , x_incr_transfer_price               OUT NOCOPY    NUMBER
    , x_incr_currency_code                OUT NOCOPY    VARCHAR2
    )
  ;

  Procedure get_xfer_price_basic (
      x_transfer_price       OUT NOCOPY NUMBER
    , x_transfer_price_code  OUT NOCOPY NUMBER
    , x_pricelist_currency   OUT NOCOPY VARCHAR2
    , x_return_status        OUT NOCOPY VARCHAR2
    , x_msg_count            OUT NOCOPY NUMBER
    , x_msg_data             OUT NOCOPY VARCHAR2
    );

  Procedure get_xfer_price_qp (
      x_transfer_price      OUT NOCOPY NUMBER
    , x_currency_code       OUT NOCOPY VARCHAR2
    , x_transfer_price_code OUT NOCOPY NUMBER
    , x_return_status       OUT NOCOPY VARCHAR2
    , x_msg_data            OUT NOCOPY VARCHAR2
    , x_msg_count           OUT NOCOPY NUMBER
  );

  PROCEDURE G_Hdr_Initialize;
  PROCEDURE copy_Header_to_request( p_header_rec             INV_IC_ORDER_PUB.Header_Rec_Type
                                    , p_Request_Type_Code    VARCHAR2
                                    , px_line_index   	   IN OUT NOCOPY NUMBER )
  ;

  PROCEDURE G_Line_Initialize;
  PROCEDURE copy_Line_to_request ( p_Line_rec INV_IC_ORDER_PUB.Line_Rec_Type
                                   , p_pricing_events VARCHAR2
                                   , p_request_type_code VARCHAR2
                                   , px_line_index IN OUT NOCOPY NUMBER )
  ;
  PROCEDURE Populate_Temp_Table ( x_return_status OUT NOCOPY VARCHAR2
  );
  PROCEDURE Populate_Results( p_line_index NUMBER
                              , x_return_status OUT NOCOPY VARCHAR2
                              , x_msg_data      OUT NOCOPY VARCHAR2
  );

END GMF_get_transfer_price_PUB;

/
