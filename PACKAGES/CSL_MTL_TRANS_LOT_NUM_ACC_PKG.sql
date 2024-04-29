--------------------------------------------------------
--  DDL for Package CSL_MTL_TRANS_LOT_NUM_ACC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSL_MTL_TRANS_LOT_NUM_ACC_PKG" AUTHID CURRENT_USER AS
/* $Header: cslltacs.pls 115.6 2002/11/08 14:02:25 asiegers ship $ */

PROCEDURE Insert_MTL_trans_lot_num(
                                      p_resource_id         NUMBER,
                                      p_transaction_id      NUMBER,
                                      p_inventory_item_id   NUMBER,
                                      p_organization_id     NUMBER
                                    );

PROCEDURE Update_MTL_trans_lot_num(
                                      p_resource_id         NUMBER,
                                      p_transaction_id      NUMBER,
                                      p_inventory_item_id   NUMBER,
                                      p_organization_id     NUMBER
                                    );

PROCEDURE Delete_MTL_trans_lot_num(
                                      p_resource_id         NUMBER,
                                      p_transaction_id      NUMBER,
                                      p_inventory_item_id   NUMBER,
                                      p_organization_id     NUMBER
                                    );

PROCEDURE DELETE_ALL_ACC_RECORDS(     p_resource_id IN NUMBER,
                                      x_return_status OUT NOCOPY VARCHAR2
		  );

END CSL_MTL_TRANS_LOT_NUM_ACC_PKG;

 

/
