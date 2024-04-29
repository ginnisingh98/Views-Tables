--------------------------------------------------------
--  DDL for Package GMF_GET_XFER_PRICE_HOOK_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_GET_XFER_PRICE_HOOK_PUB" AUTHID CURRENT_USER AS
/* $Header: GMFXFRUS.pls 120.3 2005/10/25 13:39:53 umoogala noship $ */

  procedure Get_xfer_price_user_hook
    ( p_api_version                       IN            NUMBER
    , p_init_msg_list                     IN            VARCHAR2

    , p_transaction_uom                   IN            VARCHAR2
    , p_inventory_item_id                 IN            NUMBER
    , p_transaction_id                    IN            NUMBER
    , p_from_organization_id              IN            NUMBER
    , p_to_organization_id                IN            NUMBER
    , p_from_ou                           IN            NUMBER
    , p_to_ou                             IN            NUMBER

    , x_return_status                     OUT NOCOPY    NUMBER
    , x_msg_data                          OUT NOCOPY    VARCHAR2
    , x_msg_count                         OUT NOCOPY    NUMBER

    , x_transfer_price                    OUT NOCOPY    NUMBER
    , x_transfer_price_priuom             OUT NOCOPY    NUMBER
    , x_currency_code                     OUT NOCOPY    VARCHAR2
    )
  ;

END GMF_get_xfer_price_hook_PUB;

 

/
