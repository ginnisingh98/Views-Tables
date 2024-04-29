--------------------------------------------------------
--  DDL for Package CSL_MTL_UNIT_TRANS_ACC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSL_MTL_UNIT_TRANS_ACC_PKG" AUTHID CURRENT_USER AS
/* $Header: cslutacs.pls 115.6 2002/11/08 14:01:03 asiegers ship $ */

PROCEDURE Insert_MTL_Unit_Trans(
                                      p_resource_id         NUMBER,
                                      p_transaction_id      NUMBER,
                                      p_inventory_item_id   NUMBER,
                                      p_organization_id     NUMBER,
		        p_subinventory_code   VARCHAR2
	                );

PROCEDURE Update_MTL_Unit_Trans(
                                      p_resource_id         NUMBER,
                                      p_transaction_id      NUMBER,
                                      p_inventory_item_id   NUMBER,
                                      p_organization_id     NUMBER,
		        p_subinventory_code   VARCHAR2
                               );

PROCEDURE Delete_MTL_Unit_Trans(
                                      p_resource_id         NUMBER,
                                      p_transaction_id      NUMBER,
                                      p_inventory_item_id   NUMBER,
                                      p_organization_id     NUMBER,
		        p_subinventory_code   VARCHAR2
                               );

PROCEDURE DELETE_ALL_ACC_RECORDS(     p_resource_id IN NUMBER,
                                      x_return_status OUT NOCOPY VARCHAR2
		  );

END CSL_MTL_UNIT_TRANS_ACC_PKG;

 

/
