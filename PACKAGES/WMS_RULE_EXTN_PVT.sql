--------------------------------------------------------
--  DDL for Package WMS_RULE_EXTN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_RULE_EXTN_PVT" AUTHID CURRENT_USER AS
/* $Header: WMSVRXTS.pls 120.4.12010000.1 2008/07/28 18:38:11 appldev ship $ */
  --
  -- File        : WMSVRXTS.pls
  -- Content     : WMS_Rule_Extn_Pvt package
  -- Description : Extended API's using wms rules engine private API's
  --             : such as creating reservations based on rule suggestions
  -- Notes       :
  -- Modified    : 05/18/05 rambrose created orginal file
  --
g_create_reservations   NUMBER := 1;
g_create_suggestions   NUMBER := 2;
g_allocate   NUMBER := 3;

TYPE numtabtype IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE datetabtype IS TABLE OF DATE INDEX BY BINARY_INTEGER;
TYPE chartabtype30 IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
TYPE chartabtype3 IS TABLE OF VARCHAR2(3) INDEX BY BINARY_INTEGER;
TYPE chartabtype10 IS TABLE OF VARCHAR2(10) INDEX BY BINARY_INTEGER;
TYPE chartabtype80 IS TABLE OF VARCHAR2(80) INDEX BY BINARY_INTEGER;
TYPE chartabtype150 IS TABLE OF VARCHAR2(150) INDEX BY BINARY_INTEGER;

TYPE g_suggestion_list_rec_type is RECORD (
  from_organization_id   NUMTABTYPE
, revision   CHARTABTYPE3
, serial_number     CHARTABTYPE30
, transaction_quantity     NUMTABTYPE
, primary_quantity     NUMTABTYPE
, secondary_quantity     NUMTABTYPE
, lot_number        CHARTABTYPE80
, lot_expiration_date        DATETABTYPE
, from_subinventory_code        CHARTABTYPE10
, from_locator_id        NUMTABTYPE
, rule_id        NUMTABTYPE
, reservation_id        NUMTABTYPE
, to_subinventory_code        CHARTABTYPE10
, to_locator_id        NUMTABTYPE
, to_organization_id   NUMTABTYPE
, from_cost_group_id   NUMTABTYPE
, to_cost_group_id   NUMTABTYPE
, lpn_id   NUMTABTYPE
, grade_code   CHARTABTYPE150
);

PROCEDURE suggest_reservations(
    p_api_version         IN            NUMBER
  , p_init_msg_list       IN            VARCHAR2
  , p_commit              IN            VARCHAR2
  , p_validation_level    IN            NUMBER
  , x_return_status       OUT NOCOPY    VARCHAR2
  , x_msg_count           OUT NOCOPY    NUMBER
  , x_msg_data            OUT NOCOPY    VARCHAR2
  , p_transaction_temp_id IN            NUMBER
  , p_allow_partial_pick  IN            VARCHAR2
  , p_suggest_serial      IN            VARCHAR2
  , p_mo_line_rec         IN     inv_move_order_pub.trolin_rec_type
  , p_demand_source_type  IN     NUMBER
  , p_demand_source_header_id         IN     NUMBER
  , p_demand_source_line_id         IN     NUMBER
  , p_demand_source_detail         IN     NUMBER DEFAULT NULL
  , p_demand_source_name  IN     VARCHAR2 DEFAULT NULL
  , p_requirement_date    IN     DATE DEFAULT NULL
  , p_suggestions         OUT NOCOPY g_suggestion_list_rec_type
  );


end wms_rule_extn_pvt;

/
