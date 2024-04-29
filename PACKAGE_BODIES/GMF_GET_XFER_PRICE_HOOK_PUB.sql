--------------------------------------------------------
--  DDL for Package Body GMF_GET_XFER_PRICE_HOOK_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_GET_XFER_PRICE_HOOK_PUB" AS
/* $Header: GMFXFRUB.pls 120.6 2006/09/21 13:30:38 umoogala noship $ */

  G_PKG_NAME  CONSTANT VARCHAR2(30) := 'GMF_get_xfer_price_hook_PUB';

  -- Start of comments
  -- API name        : Get_xfer_price_user_hook
  -- Type            : Public
  -- Pre-reqs        : None
  -- Parameters      :
  -- Version         : Current version 1.0
  --                   Initial version 1.0
  -- PURPOSE: Pseudo code
  --   Begin
  --     IF (p_from_organization_id IS discrete org) THEN
  --       call discrete get prior cost routine
  --       return -1
  --     ELSE
  --       Call process get prior cost
  --       return -1
  --   end;
  -- End of comments

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
   IS

     l_api_name    CONSTANT       VARCHAR2(30) := 'Get_xfer_price_user_hook';
     l_api_version CONSTANT       NUMBER       := 1.0;

     l_process_enabled_flag       mtl_parameters.process_enabled_flag%TYPE;
     l_primary_cost_method        mtl_parameters.primary_cost_method%TYPE;
     l_return_status              VARCHAR2(10);

  BEGIN

    -------------------------------------------------------------------------
    -- initialize api return status to -1 to indicate no user hook
    -------------------------------------------------------------------------
    SELECT NVL(process_enabled_flag, 'N'), primary_cost_method
      INTO l_process_enabled_flag, l_primary_cost_method
      FROM mtl_parameters mp
     WHERE organization_id = p_from_organization_id
    ;

    IF l_process_enabled_flag = 'Y'
    THEN
      --
      -- Sending Org is process org.
      --
      x_return_status := -1;
      x_msg_count := 0;

      --
      -- Following is the call to get the prior period cost, if the cost method is
      -- Standard or Actual. For Lot Cost method, error is thrown. Cost Method is
      -- derived from the Cost Type in Fiscal Policy setup.
      --
      -- To get the prior period cost, users have to uncomment the following call.
      --

      /*
      GMF_PROCESS_COST_PUB.Get_Prior_Period_Cost(
          p_inventory_item_id => p_inventory_item_id
        , p_organization_id   => p_from_organization_id
        , p_transaction_date  => sysdate
        , x_unit_cost         => x_transfer_price
        , x_msg_data          => x_msg_data
        , x_return_status     => l_return_status
      );

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS
      THEN
        x_return_status := -2;
        FND_MESSAGE.SET_NAME('GMF', 'GMF_NO_PRIOR_PERIOD_COST');
        x_msg_data      := FND_MESSAGE.get;
      ELSE
	x_transfer_price_priuom := x_transfer_price;
        x_return_status := 0;
        x_msg_data      := NULL;
      END IF;
      */
    ELSE
      x_return_status := -1;
      x_msg_count := 0;

      IF l_primary_cost_method = 1
      THEN
        CSTPSCHK.Get_xfer_price_user_hook (
            p_api_version          => 1.0
          , p_init_msg_list        => fnd_api.g_false

          , p_transaction_uom      => p_transaction_uom
          , p_inventory_item_id    => p_inventory_item_id
          , p_transaction_id       => p_transaction_id

          , p_from_organization_id => p_from_organization_id
          , p_to_organization_id   => p_to_organization_id

          , p_from_ou              => p_from_ou
          , p_to_ou                => p_to_ou

          , x_return_status        => x_return_status
          , x_msg_data             => x_msg_data
          , x_msg_count            => x_msg_count

          , x_transfer_price       => x_transfer_price
          , x_currency_code        => x_currency_code
          );
      ELSE
        CSTPACHK.Get_xfer_price_user_hook (
            p_api_version          => 1.0
          , p_init_msg_list        => fnd_api.g_false

          , p_transaction_uom      => p_transaction_uom
          , p_inventory_item_id    => p_inventory_item_id
          , p_transaction_id       => p_transaction_id

          , p_from_organization_id => p_from_organization_id
          , p_to_organization_id   => p_to_organization_id

          , p_from_ou              => p_from_ou
          , p_to_ou                => p_to_ou

          , x_return_status        => x_return_status
          , x_msg_data             => x_msg_data
          , x_msg_count            => x_msg_count

          , x_transfer_price       => x_transfer_price
          , x_currency_code        => x_currency_code
          );
      END IF;

      IF x_return_status = -1
      THEN
        return;
      ELSIF x_return_status <> 0
      THEN
        x_return_status := -2;
      ELSE
	x_transfer_price_priuom := x_transfer_price;
        x_return_status := 0;
        x_msg_data      := NULL;
      END IF;

    END IF;

  END Get_xfer_price_user_hook;

END GMF_get_xfer_price_hook_PUB;

/
