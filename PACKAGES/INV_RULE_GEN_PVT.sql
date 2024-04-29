--------------------------------------------------------
--  DDL for Package INV_RULE_GEN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_RULE_GEN_PVT" AUTHID CURRENT_USER AS
  /* $Header: INVRLGNS.pls 120.0 2005/05/25 06:42:50 appldev noship $ */

  --
  -- File        : INVRLGNB.pls
  -- Content     : INV_RULE_GEN_PVT
  -- Description : wms rules engine private API's
  -- Notes       :
  -- Modified    : 08/30/04 ckuenzel created orginal file in inventory
  --

  Type picking_rule_rec is  RECORD
  (
     INV_RULE_ID             Number
   , NAME                    Varchar2(80)
   , description             Varchar2(240)
   , SHELF_DAYS              number
   , SINGLE_LOT              VARchar2(1)
   , PARTIAL_ALLOWED_FLAG    varchar2(1)
   , CUST_SPEC_MATCH_FLAG    varchar2(1)
   , LOT_SORT                number
   , LOT_SORT_RANK           Number
   , REVISION_SORT           number
   , REVISION_SORT_RANK      Number
   , SUBINVENTORY_SORT       number
   , SUBINVENTORY_SORT_RANK  Number
   , LOCATOR_SORT            number
   , LOCATOR_SORT_RANK       Number
   , WMS_RULE_ID             Number
   , WMS_STRATEGY_ID         Number
   , Apply_to_source         Number  -- 1,sales order, 2 GME, 3 WIP
   , enabled_flag            varchar2(1)
   , CREATION_DATE           date
   , CREATED_BY              number
   , LAST_UPDATE_DATE        date
   , LAST_UPDATED_BY         number
   , LAST_UPDATE_LOGIN       number
  );

  PROCEDURE Save
  (p_mtl_picking_rule_rec    IN OUT NOCOPY INV_RULE_GEN_PVT.picking_rule_rec
  , x_return_status          OUT NOCOPY VARCHAR2
  , x_msg_data               OUT NOCOPY VARCHAR2
  , x_msg_count              OUT NOCOPY NUMBER
  );

  PROCEDURE Save_to_mtl_picking_rules
  (p_mtl_picking_rule_rec    IN OUT NOCOPY INV_RULE_GEN_PVT.picking_rule_rec
  , x_return_status          OUT NOCOPY VARCHAR2
  , x_msg_data               OUT NOCOPY VARCHAR2
  , x_msg_count              OUT NOCOPY NUMBER
  );

  PROCEDURE Save_to_wms_rule
  (p_mtl_picking_rule_rec    IN OUT NOCOPY INV_RULE_GEN_PVT.picking_rule_rec
  , x_return_status          OUT NOCOPY VARCHAR2
  , x_msg_data               OUT NOCOPY VARCHAR2
  , x_msg_count              OUT NOCOPY NUMBER
  );

  PROCEDURE Restrictions_insert
  (p_mtl_picking_rule_rec    IN OUT NOCOPY INV_RULE_GEN_PVT.picking_rule_rec
  , x_return_status          OUT NOCOPY VARCHAR2
  , x_msg_data               OUT NOCOPY VARCHAR2
  , x_msg_count              OUT NOCOPY NUMBER
  );

  PROCEDURE Restrictions_update
  (p_mtl_picking_rule_rec    IN OUT NOCOPY INV_RULE_GEN_PVT.picking_rule_rec
  , x_return_status          OUT NOCOPY VARCHAR2
  , x_msg_data               OUT NOCOPY VARCHAR2
  , x_msg_count              OUT NOCOPY NUMBER
  );

  PROCEDURE Restrictions_delete
  (p_mtl_picking_rule_rec    IN OUT NOCOPY INV_RULE_GEN_PVT.picking_rule_rec
  , x_return_status          OUT NOCOPY VARCHAR2
  , x_msg_data               OUT NOCOPY VARCHAR2
  , x_msg_count              OUT NOCOPY NUMBER
  );

  PROCEDURE consistency_insert
  (p_mtl_picking_rule_rec    IN OUT NOCOPY INV_RULE_GEN_PVT.picking_rule_rec
  , x_return_status          OUT NOCOPY VARCHAR2
  , x_msg_data               OUT NOCOPY VARCHAR2
  , x_msg_count              OUT NOCOPY NUMBER
  );

 PROCEDURE consistency_update
  (p_mtl_picking_rule_rec    IN OUT NOCOPY INV_RULE_GEN_PVT.picking_rule_rec
  , x_return_status          OUT NOCOPY VARCHAR2
  , x_msg_data               OUT NOCOPY VARCHAR2
  , x_msg_count              OUT NOCOPY NUMBER
  );

PROCEDURE consistency_delete
  (p_mtl_picking_rule_rec    IN OUT NOCOPY INV_RULE_GEN_PVT.picking_rule_rec
  , x_return_status          OUT NOCOPY VARCHAR2
  , x_msg_data               OUT NOCOPY VARCHAR2
  , x_msg_count              OUT NOCOPY NUMBER
  );

  PROCEDURE Sorting_criteria_insert
  (p_mtl_picking_rule_rec    IN OUT NOCOPY INV_RULE_GEN_PVT.picking_rule_rec
  , x_return_status          OUT NOCOPY VARCHAR2
  , x_msg_data               OUT NOCOPY VARCHAR2
  , x_msg_count              OUT NOCOPY NUMBER
  );

  PROCEDURE Sorting_criteria_update
  (p_mtl_picking_rule_rec    IN OUT NOCOPY INV_RULE_GEN_PVT.picking_rule_rec
  , x_return_status          OUT NOCOPY VARCHAR2
  , x_msg_data               OUT NOCOPY VARCHAR2
  , x_msg_count              OUT NOCOPY NUMBER
  );

  PROCEDURE Sorting_criteria_delete
  (p_mtl_picking_rule_rec    IN OUT NOCOPY INV_RULE_GEN_PVT.picking_rule_rec
  , x_return_status          OUT NOCOPY VARCHAR2
  , x_msg_data               OUT NOCOPY VARCHAR2
  , x_msg_count              OUT NOCOPY NUMBER
  );

  PROCEDURE Strategy_insert
  (p_mtl_picking_rule_rec    IN OUT NOCOPY INV_RULE_GEN_PVT.picking_rule_rec
  , x_return_status          OUT NOCOPY VARCHAR2
  , x_msg_data               OUT NOCOPY VARCHAR2
  , x_msg_count              OUT NOCOPY NUMBER
  );

  /* Only enabled flag can be updated. */
  PROCEDURE Strategy_update
  (p_mtl_picking_rule_rec    IN OUT NOCOPY INV_RULE_GEN_PVT.picking_rule_rec
  , x_return_status          OUT NOCOPY VARCHAR2
  , x_msg_data               OUT NOCOPY VARCHAR2
  , x_msg_count              OUT NOCOPY NUMBER
  );
  PROCEDURE Rule_Enabled_Flag
  (p_mtl_picking_rule_rec    IN OUT NOCOPY INV_RULE_GEN_PVT.picking_rule_rec
  , x_return_status          OUT NOCOPY VARCHAR2
  , x_msg_data               OUT NOCOPY VARCHAR2
  , x_msg_count              OUT NOCOPY NUMBER
  );
  FUNCTION rule_assigned_to_strategy
  (p_mtl_picking_rule_rec    IN OUT NOCOPY INV_RULE_GEN_PVT.picking_rule_rec
  , x_return_status          OUT NOCOPY VARCHAR2
  , x_msg_data               OUT NOCOPY VARCHAR2
  , x_msg_count              OUT NOCOPY NUMBER)
  RETURN BOOLEAN;

  PROCEDURE GenerateRulePKG
  (p_mtl_picking_rule_rec    IN OUT NOCOPY INV_RULE_GEN_PVT.picking_rule_rec
  , x_return_status          OUT NOCOPY VARCHAR2
  , x_msg_data               OUT NOCOPY VARCHAR2
  , x_msg_count              OUT NOCOPY NUMBER
  );

END; -- Package Specification inv_rule_gen_pvt

 

/
