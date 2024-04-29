--------------------------------------------------------
--  DDL for Package CSP_PLANNED_ORDERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_PLANNED_ORDERS" AUTHID CURRENT_USER AS
/* $Header: cspvppos.pls 120.0 2005/07/12 13:15:29 phegde noship $ */

-- Purpose: To create planned orders for a warehouse
--
-- MODIFICATION HISTORY
-- Person      Date      Comments
-- ---------   ------    ------------------------------------------
-- phegde      6/13/2005 Created package

  TYPE line_rec_type IS RECORD
  ( supplied_item_id     NUMBER,
    planned_order_type    VARCHAR2(30),
    source_organization_id NUMBER,
    quantity              NUMBER,
    uom_code              VARCHAR2(30),
    plan_date             DATE
   );

  TYPE line_Tbl_Type IS TABLE OF Line_Rec_Type
        INDEX BY BINARY_INTEGER;

  PROCEDURE create_orders
        ( p_api_version             IN NUMBER
        , p_Init_Msg_List           IN VARCHAR2     := FND_API.G_FALSE
        , p_commit                  IN VARCHAR2     := FND_API.G_FALSE
        , p_organization_id         NUMBER
        , p_inventory_item_id       NUMBER
        , px_line_tbl               CSP_PLANNED_ORDERS.Line_Tbl_Type
        , x_return_status           OUT NOCOPY VARCHAR2
        , x_msg_count               OUT NOCOPY NUMBER
        , x_msg_data                OUT NOCOPY VARCHAR2);

END; -- Package spec

 

/
