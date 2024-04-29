--------------------------------------------------------
--  DDL for Package JA_AU_COSTPROC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JA_AU_COSTPROC_PKG" AUTHID CURRENT_USER as
/* $Header: jaauicps.pls 115.4 2003/01/08 23:28:56 thwon ship $ */

PROCEDURE JA_AU_LOCAL_ACCOUNT(x_org_id     	IN
           mtl_material_transactions.organization_id%TYPE,
           x_subinv     	IN
           mtl_material_transactions.subinventory_code%TYPE,
           x_item_id    	IN
           mtl_material_transactions.inventory_item_id%TYPE,
           x_transaction_id 	IN 	number);

END JA_AU_COSTPROC_PKG;

 

/
