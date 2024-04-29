--------------------------------------------------------
--  DDL for Package GMI_PR_PICK_SLIP_NUMBER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMI_PR_PICK_SLIP_NUMBER" AUTHID CURRENT_USER AS
/* $Header: GMIUSLPS.pls 120.0 2005/05/26 00:14:28 appldev noship $    */
/*
+===========================================================================+
|               Copyright (c) 2000 Oracle Corporation                       |
|                  Thames Valley Park, United Kingdom                       |
|                       All rights reserved.                                |
+===========================================================================+
*/
/*
  Package
         GMI_PR_PICK_SLIP_NUMBER

  Purpose (direct copy of WSHPRPNS.pls)
    This package does the following:
    - Initialize variables to be used
      in determining the how to group pick slips.
    - Get pick slip number
    - Print Pick Slip Report



     PUBLIC FUNCTIONS/PROCEDURES



     Name
       PROCEDURE Print_Pick_Slip

     Purpose
       This function prints a Pick Slip for a given Pick Slip number
       or all Pick Slips for the session

     Input Parameters
       p_pick_slip_number => pick slip number
       p_report_set_id    => report set
       If p_report_set_id IS NULL, procedure returns. No printing.

     Output Parameters
       x_api_status    => FND_API.G_RET_STS_SUCESSS or
                          FND_API.G_RET_STS_ERROR or
                          FND_API.G_RET_STS_UNEXP_ERROR
       x_error_message => Error message
*/

-- HW BUG#:2643440 Removed   FND_API.G_MISS_NUM from p_pick_slip_number
-- and replaced it with NULL
   PROCEDURE Print_Pick_Slip (
      p_pick_slip_number         IN  NUMBER DEFAULT NULL,
      p_report_set_id            IN  NUMBER,
      p_organization_id          IN  NUMBER,
      x_api_status               OUT NOCOPY VARCHAR2,
      x_error_message            OUT NOCOPY VARCHAR2 );

   /*
     Name
       PROCEDURE Get_Pick_Slip_Number

     Purpose
       Returns pick slip number and whether a Pick Slip
       should be printed

     Input Parameters
       p_ps_mode              => pick slip print mode: I=immed, E=deferred
       p_pick_grouping_rule_id => pick grouping rule id
       p_org_id               => organization_id
       p_header_id            => order header id
       p_customer_id          => customer id
       p_ship_method_code     => ship method
       p_ship_to_loc_id       => ship to location
       p_shipment_priority    => shipment priority
       p_subinventory         => subinventory
       p_trip_stop_id         => trip stop
       p_delivery_id          => delivery
       p_inventory_item_id    => inventory item id
       p_locator_id           => locator id
       p_lot_number           => lot number
       p_revision             => revision

     Output Parameters
       x_pick_slip_number     => pick_slip_number
       x_ready_to_print       => FND_API.G_TRUE or FND_API.G_FALSE
       x_api_status           => FND_API.G_RET_STS_SUCESSS or
                                 FND_API.G_RET_STS_ERROR
       x_error_message        => Error message
*/

   PROCEDURE Get_Pick_Slip_Number (
      p_ps_mode                    IN      VARCHAR2,
      p_pick_grouping_rule_id      IN      NUMBER,
      p_org_id                     IN      NUMBER,
      p_header_id                  IN      NUMBER,
      p_customer_id                IN      NUMBER,
      p_ship_method_code           IN      VARCHAR2,
      p_ship_to_loc_id             IN      NUMBER,
      p_shipment_priority          IN      VARCHAR2,
      p_subinventory               IN      VARCHAR2,
      p_trip_stop_id               IN      NUMBER,
      p_delivery_id                IN      NUMBER,
      p_inventory_item_id          IN      NUMBER   DEFAULT NULL,
      p_locator_id                 IN      NUMBER   DEFAULT NULL,
      p_lot_number                 IN      VARCHAR2 DEFAULT NULL,
      p_revision                   IN      VARCHAR2 DEFAULT NULL,
      x_pick_slip_number           OUT NOCOPY     NUMBER,
      x_ready_to_print             OUT NOCOPY     VARCHAR2,
      x_api_status                 OUT NOCOPY     VARCHAR2,
      x_error_message              OUT NOCOPY     VARCHAR2  );

END GMI_PR_PICK_SLIP_NUMBER;

 

/
