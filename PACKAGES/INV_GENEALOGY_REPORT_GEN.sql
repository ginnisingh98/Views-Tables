--------------------------------------------------------
--  DDL for Package INV_GENEALOGY_REPORT_GEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_GENEALOGY_REPORT_GEN" AUTHID CURRENT_USER AS
/* $Header: INVLTGNS.pls 120.4.12010000.2 2008/10/07 09:50:36 kbanddyo ship $ */
--
--
-- File        : INVVDEUS.pls
-- Content     : INV_GENEALOGY_REPORT_GEN package spec
-- Description : utlitities used by the detailing engine (both inv and wms versions)
-- Notes       :
-- Modified    : 07/18/2005 lgao created
--
TYPE item_info_rec_type IS RECORD
  (
      inventory_item_id              NUMBER
    , ITEM_NO                        VARCHAR2(150)
    , ITEM_DESC                      VARCHAR2(500)
    , SHELF_LIFE                     NUMBER
    , RETEST_INTERVAL                NUMBER
    , primary_uom                    VARCHAR2(5)
    , secondary_uom                  VARCHAR2(5)
    , org_code                       VARCHAR2(5)
    , org_desc                       VARCHAR2(50)
  );

TYPE lot_attributes_rec_type IS RECORD
  (
      object_id                      NUMBER
    , LOT_NUMBER                     VARCHAR2(80)
    , parent_lot                     VARCHAR2(80)
    , status                         VARCHAR2(30)
    , grade_code                     VARCHAR2(150)
    , retest_date                    DATE
    , expiration_date                DATE
    , hold_date                      DATE
    , source_origin                  VARCHAR2(80)
    , init_quantity                  NUMBER
    , uom                            VARCHAR2(5)
    , init_transaction               VARCHAR2(150)
    , init_date                      DATE
    , document                       VARCHAR2(150)
    , supplier                       VARCHAR2(150)
    , org_code                       VARCHAR2(5)
    , org_desc                       VARCHAR2(240)
    , organization_id                NUMBER
    , inventory_item_id              NUMBER
    , sampling_event_id             NUMBER
  );

TYPE serial_attributes_rec_type IS RECORD
  (
      object_id                      NUMBER
    , unit_number                     VARCHAR2(30)
    , serial_number                   VARCHAR2(30)
    , status                          VARCHAR2(30)
    , state                           VARCHAR2(30)
    , receipt_date                    DATE
    , ship_date                       DATE
    , job                             VARCHAR2(30)
    , operation                       VARCHAR2(30)
    , step                            VARCHAR2(30)
    , org_code                        VARCHAR2(5)
    , org_desc                        VARCHAR2(240)
    , current_lot_number              VARCHAR2(80)
    , organization_id                 NUMBER
    , wip_entity_id                   NUMBER
    , operation_seq_num               NUMBER
    , intraoperation_step_type        NUMBER
  );

TYPE work_order_header_rec_type IS RECORD
  (
      object_id                      NUMBER
    , assembly                        VARCHAR2(40)
    , assembly_desc                   VARCHAR2(240)
    , wip_entity_id                   NUMBER
    , prod_item_id                    NUMBER
    , status                          VARCHAR2(80)
    , org_code                        VARCHAR2(30)
    , org_desc                        VARCHAR2(240)
    , work_order_type                 VARCHAR2(30)
    , work_order_number               VARCHAR2(240)
    , date_released                   DATE
    , date_completed                  DATE
    , current_org_id                  NUMBER
    , wip_entity_type                 NUMBER
  );

TYPE work_order_dtl_rec_type IS RECORD
  (
      product                         VARCHAR2(40)
    , product_desc                    VARCHAR2(240)
    , planned_qty                     VARCHAR2(40)
    , qty_scrapped                    VARCHAR2(40)
    , qty_remaining                   VARCHAR2(40)
    , qty_completed                   VARCHAR2(40)
    , uom                             VARCHAR2(5)
  );

TYPE material_txn_rec_type IS RECORD
  (
      object_id                       NUMBER
    , object_type                     NUMBER
    , transaction_date                DATE
    , Organization                    VARCHAR2(30)
    , Transaction_Source_Type         VARCHAR2(90)
    , Transaction_Type                VARCHAR2(90)
    , Document                        VARCHAR2(4000)
    , Quantity                        NUMBER
    , UOM                             VARCHAR2(30)
    , Secondary_Quantity              NUMBER
    , Secondary_UOM                   VARCHAR2(30)
    , Subinventory                    VARCHAR2(30)
    , Locator                         VARCHAR2(30)
    , Project                         VARCHAR2(90)
    , Task                            VARCHAR2(90)
    , LPN                             VARCHAR2(90)
    , Transfer_LPN                    VARCHAR2(90)
    , Content_LPN                     VARCHAR2(90)
    , Grade                           VARCHAR2(150)
    , current_org_id                  NUMBER
    , wip_entity_type                 NUMBER
  );

TYPE pending_txn_rec_type IS RECORD
  (
      object_id                       NUMBER
    , object_type                     NUMBER
    , transaction_date                DATE
    , Organization                    VARCHAR2(30)
    , Transaction_Source_Type         VARCHAR2(90)
    , Transaction_Type                VARCHAR2(90)
    , Document                        VARCHAR2(4000)
    , Quantity                        NUMBER
    , UOM                             VARCHAR2(30)
    , Secondary_Quantity              NUMBER
    , Secondary_UOM                   VARCHAR2(30)
    , Subinventory                    VARCHAR2(30)
    , Locator                         VARCHAR2(30)
    , Project                         VARCHAR2(90)
    , Task                            VARCHAR2(90)
    , LPN                             VARCHAR2(90)
    , Transfer_LPN                    VARCHAR2(90)
    , Content_LPN                     VARCHAR2(90)
    , Grade                           VARCHAR2(150)
    , current_org_id                  NUMBER
    , transaction_status              VARCHAR2(20)
  );

TYPE product_rec_type IS RECORD
  (
      Organization                    VARCHAR2(30)
    , transaction_date                date
    , Assembly                        VARCHAR2(40)
    , Product_type                    VARCHAR2(240)
    --#  Sunitha Ch. 21jun06. Bug#5312854. Changed the size of lot to 80 from 30
    --,Lot                             VARCHAR2(30)
    , Lot                             VARCHAR2(80)
    , Serial                          VARCHAR2(30)
    , Quantity                        NUMBER
    , UOM                             VARCHAR2(30)
    , Secondary_quantity              NUMBER
    , Secondary_UOM                   VARCHAR2(30)
    , Subinventory                    VARCHAR2(30)
    , Locator                         VARCHAR2(30)
    , Grade                           VARCHAR2(150)
    , current_org_id                  NUMBER
    , inventory_item_id               NUMBER
    , comp_lot_number                 VARCHAR2(150)
    , comp_serial_number              VARCHAR2(150)
  );

TYPE component_rec_type IS RECORD
  (
      Organization                    VARCHAR2(30)
    , transaction_date                date
    , item                            VARCHAR2(30)
    --#  Sunitha Ch. 21jun06. Bug#5312854. Changed the size of lot to 80 from 30
    --,Lot                             VARCHAR2(30)
    , Lot                             VARCHAR2(80)
    , Serial                          VARCHAR2(30)
    , Quantity                        NUMBER
    , UOM                             VARCHAR2(10)
    , Secondary_quantity              NUMBER
    , Secondary_UOM                   VARCHAR2(10)
    , Subinventory                    VARCHAR2(30)
    , Locator                         VARCHAR2(30)
    , Grade                           VARCHAR2(150)
    , current_org_id                  NUMBER
    , wip_entity_id                   NUMBER
    , wip_entity_name                 VARCHAR2(240)
    , inventory_item_id               NUMBER
    , product_lot_number              VARCHAR2(150)
    , product_serial_number           VARCHAR2(150)
  );

TYPE quality_collections_rec_type IS RECORD
  (
      Organization                    VARCHAR2(30)
    , Item                            VARCHAR2(40)
    , Item_Desc                       VARCHAR2(240)
    , Collection_Plan                 VARCHAR2(30)
    , Plan_Type                       VARCHAR2(240)
    , Plan_Description                VARCHAR2(150)
    , inventory_item_id               NUMBER
    , lot_number                      VARCHAR2(80)
    , serial_number                   VARCHAR2(80)
    , wip_entity_id                   NUMBER
  );

TYPE quality_samples_rec_type IS RECORD
  (
      Organization                    VARCHAR2(30)
    , Item                            VARCHAR2(40)
    , item_desc                       VARCHAR2(240)
    --#  Sunitha Ch. 21jun06. Bug#5312854. Changed the size of lot to 80 from 30
    --,Lot                             VARCHAR2(30)
    , Lot                             VARCHAR2(80)
    , Sample_number                   VARCHAR2(80)
    , Sample_description              VARCHAR2(80)
    , Date_Drawn                      DATE
    , Disposition                     VARCHAR2(30)
    , Sample_source                   VARCHAR2(30)
    , Subinventory                    VARCHAR2(30)
    , Locator                         VARCHAR2(30)
    , Sample_Quantity                 NUMBER
    , UOM                             VARCHAR2(30)
    , inventory_item_id               NUMBER
    , current_org_id                  NUMBER
    , wip_entity_id                   NUMBER
    , sampling_event_id               NUMBER
    , parent_lot                      VARCHAR2(80)
  );

TYPE move_txn_rec_type IS RECORD
  (
      Transaction_Date                DATE
    , Job                             VARCHAR2(240)
    , Assembly                        VARCHAR2(80)
    , From_Seq                        NUMBER
    , From_Code                       VARCHAR2(4)
    , From_Department                 VARCHAR2(10)
    , From_Step                       VARCHAR2(80)
    , To_Seq                          NUMBER
    , To_Code                         VARCHAR2(4)
    , To_Department                   VARCHAR2(10)
    , To_Step                         VARCHAR2(80)
    , Transaction_UOM                 VARCHAR2(3)
    , Transaction_Quantity            NUMBER
    , Primary_UOM                     VARCHAR2(3)
    , Primary_Quantity                NUMBER
    , Over_Cplt_Txn_Qty               NUMBER
    , Over_Cplt_Primary_Qty           NUMBER
    , object_id                       NUMBER
    , organization_id                 NUMBER
    , wip_entity_id                   NUMBER
    , transaction_id                  NUMBER
  );

TYPE lotbased_wip_txn_rec_type IS RECORD
  (
      Transaction_Date                DATE
    , transaction_type                VARCHAR2(80)
    , prev_wip_entity_name            VARCHAR2(240)
    , prev_start_quantity             NUMBER
    , prev_wip_entity_id              NUMBER
    , prev_alt_routing_designator     VARCHAR2(10)
    , prev_primary_item_id            NUMBER
    , chg_wip_entity_name             VARCHAR2(240)
    , chg_wip_entity_id               NUMBER
    , chg_start_quantity              NUMBER
    , chg_alt_routing_designator      VARCHAR2(10)
    , chg_primary_item_id             NUMBER
    , object_id                       NUMBER
    , object_type                     NUMBER
    , created_by                      NUMBER
    , transaction_id                  NUMBER(15)
  );

TYPE grade_status_rec_type IS RECORD
  (
      Organization                    VARCHAR2(30)
    , Date_Time                       DATE
    , Action                          VARCHAR2(30)
    , From_value                      VARCHAR2(150)
    , To_value                        VARCHAR2(150)
    , Quantity                        NUMBER
    , UOM                             VARCHAR2(30)
    , Secondary_Quantity              NUMBER
    , Secondary_UOM                   VARCHAR2(30)
    , Source                          VARCHAR2(30)
    , Reason                          VARCHAR2(30)
    , User                            VARCHAR2(30)
    , lot_number                      VARCHAR2(80)
    , inventory_item_id               NUMBER
    , current_org_id                  NUMBER
  );

PROCEDURE genealogy_report
  (
   errbuf                       OUT NOCOPY VARCHAR2
  ,retcode                      OUT NOCOPY VARCHAR2
  ,p_organization_code          IN  VARCHAR2
  ,p_item_no                    IN  VARCHAR2 DEFAULT null
  ,p_lot_number                 IN  VARCHAR2 DEFAULT null
  ,p_serial_number              IN  VARCHAR2 DEFAULT null
  ,p_wip_entity_name            IN  VARCHAR2 DEFAULT null
  ,p_include_txns               IN  VARCHAR2 DEFAULT 'Y'
  ,p_include_move_txns          IN  VARCHAR2 DEFAULT 'Y'
  ,p_include_pending_txns       IN  VARCHAR2 DEFAULT 'Y'
  ,p_include_grd_sts            IN  VARCHAR2 DEFAULT 'Y'
  ,p_quality_control            IN  VARCHAR2 DEFAULT 'Y'
  ,p_genealogy_type             IN  NUMBER   DEFAULT 1
   );

END;

/
