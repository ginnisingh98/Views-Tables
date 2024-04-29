--------------------------------------------------------
--  DDL for Package INV_3PL_LOC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_3PL_LOC_PVT" AUTHID CURRENT_USER AS
/* $Header: INVVSSCS.pls 120.0.12010000.1 2010/01/15 15:05:27 damahaja noship $ */

PROCEDURE update_locator_capacity
  ( x_return_status             OUT NOCOPY VARCHAR2, -- return status (success/error/unexpected_error)
    x_msg_count                 OUT NOCOPY NUMBER,   -- number of messages in the message queue
    x_msg_data                  OUT NOCOPY VARCHAR2, -- message text when x_msg_count>0
    p_inventory_location_id     IN         NUMBER,   -- identifier of locator
    p_organization_id           IN         NUMBER,   -- org of locator whose capacity is to be determined
    p_client_code               IN         VARCHAR2,   -- identifier of item
    p_transaction_action_id     IN            NUMBER,   -- transaction action id for pack,unpack,issue,receive,transfer
    p_quantity                  IN         NUMBER,
    p_transaction_date          IN         DATE
  );

Function update_3pl_loc_occupancy
(
    l_Last_Receipt_Date DATE,
    l_current_onhand NUMBER ,
    l_locator_id NUMBER ,
    l_transaction_date DATE ,
    l_transaction_action NUMBER ,
    l_transaction_quantity NUMBER  ,
    l_organization_id NUMBER,
    l_client_code VARCHAR2 ,
    l_number_of_days  number
    ) RETURN VARCHAR2;

Function insert_3pl_loc_occupancy
(
    l_Last_Receipt_Date date,
    l_current_onhand NUMBER ,
    l_locator_id NUMBER ,
    l_transaction_date DATE ,
    l_transaction_action NUMBER ,
    l_transaction_quantity NUMBER  ,
    l_organization_id NUMBER,
    l_client_code VARCHAR2 ,
    l_number_of_days  number
    ) RETURN VARCHAR2;

END inv_3pl_loc_pvt;

/
