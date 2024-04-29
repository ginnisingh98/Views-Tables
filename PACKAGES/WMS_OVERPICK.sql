--------------------------------------------------------
--  DDL for Package WMS_OVERPICK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_OVERPICK" AUTHID CURRENT_USER AS
/* $Header: WMSOPICS.pls 120.1 2005/06/20 04:57:02 appldev ship $ */

-- This API queries the quantity_tree to find OUT NOCOPY /* file.sql.39 change */ whether there is
-- sufficient quantity to be picked in a locator .  If sufficient, the API
-- returns x_ret=1, otherwise x_ret=0

PROCEDURE validate_overpick
  ( x_return_status             OUT NOCOPY /* file.sql.39 change */ VARCHAR2, -- return status (success/error/unexpected_error)
    x_msg_count                 OUT NOCOPY /* file.sql.39 change */ NUMBER,   -- number of messages in the message queue
    x_msg_data                  OUT NOCOPY /* file.sql.39 change */ VARCHAR2, -- message text when x_msg_count>0
    x_ret                       OUT NOCOPY /* file.sql.39 change */ NUMBER,   -- returns 1 if p_qty > quantity from qty_tree
                                              -- otherwise returns 0
    x_att                       OUT NOCOPY /* file.sql.39 change */ NUMBER,   -- quantity that is avail to transact
    p_temp_id                   IN  NUMBER,   -- transaction_temp_id
    p_qty                       IN  NUMBER,   -- quantity requested
    p_uom                       IN  VARCHAR2  -- unit of measure
    );
END wms_overpick;



 

/
