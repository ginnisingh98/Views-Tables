--------------------------------------------------------
--  DDL for Package INV_EBI_ITEM_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_EBI_ITEM_PUB" AUTHID CURRENT_USER AS
/* $Header: INVEIPITS.pls 120.13.12010000.4 2009/02/19 11:20:21 prepatel ship $ */

G_OTYPE_CREATE             CONSTANT  VARCHAR2(20) := 'CREATE';
G_OTYPE_DELETE             CONSTANT  VARCHAR2(20) := 'DELETE';
G_OTYPE_UPDATE             CONSTANT  VARCHAR2(20) := 'UPDATE';
G_OTYPE_SYNC               CONSTANT  VARCHAR2(20) := 'SYNC';
G_DATA_LEVEL_ITEM          CONSTANT  VARCHAR2(20) := 'ITEM_LEVEL';
G_DATA_LEVEL_ITEM_REV      CONSTANT  VARCHAR2(20) := 'ITEM_REVISION_LEVEL';
G_TEMPLATE                 CONSTANT  NUMBER := 1;
G_INVENTORY_ITEM           CONSTANT  NUMBER := 2;
G_ORGANIZATION             CONSTANT  NUMBER := 3;
G_ITEM_CATALOG_GROUP       CONSTANT  NUMBER := 4;
G_LIFECYCLE                CONSTANT  NUMBER := 5;
G_CURRENT_PHASE            CONSTANT  NUMBER := 6;
G_REVISION                 CONSTANT  NUMBER := 7;
G_HAZARD_CLASS             CONSTANT  NUMBER := 8;
G_ASSET_CATEGORY           CONSTANT  NUMBER := 9;
G_MANUFACTURER             CONSTANT  NUMBER := 11;
G_CATEGORY_SET             CONSTANT  NUMBER := 12;
G_CATEGORY                 CONSTANT  NUMBER := 13;
G_ITEM_BALANCE             CONSTANT  NUMBER := 1;
G_ITEM                     CONSTANT  NUMBER := 2;


PROCEDURE validate_item (
   p_transaction_type  IN  VARCHAR2
  ,p_item              IN  inv_ebi_item_obj
  ,x_out               OUT NOCOPY inv_ebi_item_output_obj
);

PROCEDURE process_item(
  p_commit        IN  VARCHAR2
 ,p_operation     IN  VARCHAR2
 ,p_item          IN  inv_ebi_item_obj
 ,x_out           OUT NOCOPY inv_ebi_item_output_obj
);

PROCEDURE get_item_balance(
  p_items                       IN              inv_ebi_item_list
 ,x_item_balance_output         OUT NOCOPY      inv_ebi_item_bal_output_list
 ,x_return_status               OUT NOCOPY      VARCHAR2
 ,x_msg_count                   OUT NOCOPY      NUMBER
 ,x_msg_data                    OUT NOCOPY      VARCHAR2
);

PROCEDURE get_item_attributes(
  p_items                       IN              inv_ebi_item_list
 ,p_name_val_list               IN              inv_ebi_name_value_list
 ,x_item_tbl_obj                OUT NOCOPY      inv_ebi_item_attr_tbl_obj
 ,x_return_status               OUT NOCOPY      VARCHAR2
 ,x_msg_count                   OUT NOCOPY      NUMBER
 ,x_msg_data                    OUT NOCOPY      VARCHAR2
);

PROCEDURE process_item_list(
  p_commit        IN              VARCHAR2
 ,p_operation     IN              VARCHAR2
 ,p_item          IN              inv_ebi_item_obj_tbl
 ,x_out           OUT NOCOPY      inv_ebi_item_output_obj_tbl
 ,x_return_status OUT NOCOPY      VARCHAR2
 ,x_msg_count     OUT NOCOPY      NUMBER
 ,x_msg_data      OUT NOCOPY      VARCHAR2
);

END INV_EBI_ITEM_PUB;

/
