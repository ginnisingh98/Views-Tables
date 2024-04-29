--------------------------------------------------------
--  DDL for Package GML_BATCH_OM_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GML_BATCH_OM_UTIL" AUTHID CURRENT_USER AS
/*  $Header: GMLOUTLS.pls 120.0 2005/05/25 16:25:24 appldev noship $
 +=========================================================================+
 |                Copyright (c) 2000 Oracle Corporation                    |
 |                        TVP, Reading, England                            |
 |                         All rights reserved                             |
 +=========================================================================+
 | FILENAME                                                                |
 |    GMIURSVS.pls                                                         |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     This package contains private utilities  relating to OPM            |
 |     reservation.                                                        |
 |                                                                         |
 |                                                                         |
 | HISTORY                                                                 |
 |     Aug-18-2003  Liping Gao Created                                     |
 +=========================================================================+
  API Name  : GML_BATCH_OM_UTIL
  Type      : Private
  Function  : This package contains Private Utilities procedures used to
              OPM reservation for a batch.
  Pre-reqs  : N/A
  Parameters: Per function

  Current Vers  : 1.0

*/

G_DEFAULT_LOCT  CONSTANT  VARCHAR2(16):= FND_PROFILE.VALUE('IC$DEFAULT_LOCT');

TYPE Gme_om_reservation_rec IS RECORD
   ( Batch_res_id         Number
   , Whse_code            Varchar2(5)
   , Item_id              Number(15)
   , So_line_id           Number(15)
   , Batch_line_id        Number(15)
   , Batch_id             Number(15)
   , order_id             Number(15)
   , delivery_detail_id   Number(15)
   , mo_line_id           Number(15)
   , rule_id              Number(15)
   , organization_id      Number(15)
   , Reserved_qty         Number
   , Reserved_qty2        Number
   , Uom1                 Varchar2(4)
   , Uom2                 Varchar2(4)
   , Sched_ship_date      date
   , shipment_priority    varchar2(32)
   , batch_type           number
   , delete_mark          number
   );
TYPE Gme_om_config_assign IS RECORD
   ( Rule_assign_id       Number
   , Whse_code            Varchar2(5)
   , Item_id              Number(15)
   , allocation_class     Varchar2(30)
   , Customer_id          Number(15)
   , Site_use_id          Number(15)
   );
TYPE Gme_om_rule_rec IS RECORD
   ( Rule_id                 Number
   , Rule_name               Varchar2(30)
   , DAYS_BEFORE_SHIP_DATE   number
   , DAYS_AFTER_SHIP_DATE    number
   , BATCH_STATUS            varchar2(30)
   , ALLOCATION_TOLERANCE    number
   , ALLOCATION_PRIORITY     number
   , AUTO_PICK_CONFIRM       varchar2(1)
   , BATCH_NOTIFICATION      varchar2(1)
   , ORDER_NOTIFICATION      varchar2(1)
   , Enable_FPO              varchar2(1)
   , RULE_TYPE		     number
   , BATCH_TYPE_TO_CREATE    number
   , BATCH_CREATION_USER     number
   , CHECK_AVAILABILITY      varchar2(1)
   , AUTO_LOT_GENERATION     varchar2(1)
   , FIRMED_IND		     varchar2(1)
   , RESERVE_MAX_TOLERANCE   varchar2(1)
   , COPY_ATTACHMENTS        varchar2(1)
   , SALES_ORDER_ATTACHMENT  number
   , BATCH_ATTACHMENT	     number
   , BATCH_CREATION_NOTIFICATION varchar2(1)
   );
TYPE So_line_rec IS RECORD
   ( So_line_id           Number
   , Ship_from_org_id     Number
   , Customer_id          Number
   , Site_use_id          Number
   , Inventory_item_id    Number
   , Ordered_qty          Number
   , Ordered_qty2         Number
   , Ordered_uom          Varchar2(5)
   , whse_code            Varchar2(5)
   );
TYPE Batch_line_rec is RECORD
   ( Batch_line_id        Number
   , Batch_id             Number
   , Batch_type           Number(5)
   , Planned_qty          Number
   , Planned_uom          Varchar2(5)
   , Actual_qty           Number
   , Batch_status         Number
   , Trans_id             Number -- for update, it is the from_trans_id
   , Release_type         Number
   , Cmplt_date           Date
  );
TYPE Alloc_history_rec is RECORD
   ( Alloc_rec_id         Number
   , Batch_line_id        Number
   , Batch_id             Number
   , So_line_id           Number
   , Batch_res_id         Number
   , Batch_trans_id       Number
   , trans_id             Number
   , rule_id              Number
   , lot_id               Number
   , location             Varchar2(32)
   , Whse_code            Varchar2(5)
   , Reserved_qty         Number
   , Reserved_qty2        Number
   , Trans_um             Varchar2(5)
   , Trans_um2            Varchar2(5)
   , failure_reason       Varchar2(3000)
   );

 TYPE so_lineRecTyp IS RECORD (
          customer_id NUMBER,
          site_use_id NUMBER,
          organization_id NUMBER);

 TYPE so_lineTabTyp IS TABLE OF so_lineRecTyp INDEX BY BINARY_INTEGER;

 PROCEDURE query_reservation
 (
    P_So_line_rec            IN    GML_BATCH_OM_UTIL.so_line_rec
  , P_Batch_line_rec         IN    GML_BATCH_OM_UTIL.batch_line_rec
  , P_Gme_om_reservation_rec IN    OUT   NOCOPY GML_BATCH_OM_UTIL.gme_om_reservation_rec
  , X_return_status          OUT   NOCOPY VARCHAR2
  , X_msg_cont               OUT   NOCOPY NUMBER
  , X_msg_data               OUT   NOCOPY VARCHAR2
 );
 PROCEDURE insert_reservation
 (
    P_Gme_om_reservation_rec IN    GML_BATCH_OM_UTIL.gme_om_reservation_rec
  , X_return_status          OUT   NOCOPY VARCHAR2
  , X_msg_cont               OUT   NOCOPY NUMBER
  , X_msg_data               OUT   NOCOPY VARCHAR2
 );
 PROCEDURE update_reservation
 (
    P_Gme_om_reservation_rec IN    GML_BATCH_OM_UTIL.gme_om_reservation_rec
  , X_return_status          OUT   NOCOPY VARCHAR2
  , X_msg_cont               OUT   NOCOPY NUMBER
  , X_msg_data               OUT   NOCOPY VARCHAR2
 );
 PROCEDURE delete_reservation
 (
    P_Batch_res_id           IN    NUMBER default null
  , P_Batch_line_id          IN    NUMBER default null
  , P_Batch_id               IN    NUMBER default null
  , X_return_status          OUT   NOCOPY VARCHAR2
  , X_msg_cont               OUT   NOCOPY NUMBER
  , X_msg_data               OUT   NOCOPY VARCHAR2
 );
 PROCEDURE query_alloc_history
 (
    P_alloc_history_rec      IN OUT NOCOPY GML_BATCH_OM_UTIL.alloc_history_rec
  , X_return_status          OUT   NOCOPY VARCHAR2
  , X_msg_cont               OUT   NOCOPY NUMBER
  , X_msg_data               OUT   NOCOPY VARCHAR2
 ) ;
 PROCEDURE insert_alloc_history
 (
    P_alloc_history_rec      IN    GML_BATCH_OM_UTIL.alloc_history_rec
  , X_return_status          OUT   NOCOPY VARCHAR2
  , X_msg_cont               OUT   NOCOPY NUMBER
  , X_msg_data               OUT   NOCOPY VARCHAR2
 );
 FUNCTION check_reservation
 (
    P_Batch_res_id           IN    NUMBER default null
  , P_Batch_line_id          IN    NUMBER default null
  , P_Batch_id               IN    NUMBER default null
  , P_so_line_id             IN    NUMBER default null
  , P_delivery_detail_id     IN    NUMBER default null
  , X_return_status          OUT   NOCOPY VARCHAR2
  , X_msg_cont               OUT   NOCOPY NUMBER
  , X_msg_data               OUT   NOCOPY VARCHAR2
 ) Return boolean;
 PROCEDURE get_rule
 (
    P_so_line_rec            IN    GML_BATCH_OM_UTIL.so_line_rec
  , P_batch_line_rec         IN    GML_BATCH_OM_UTIL.batch_line_rec
  , X_gme_om_rule_rec        OUT   NOCOPY GML_BATCH_OM_UTIL.gme_om_rule_rec
  , X_return_status          OUT   NOCOPY VARCHAR2
  , X_msg_cont               OUT   NOCOPY NUMBER
  , X_msg_data               OUT   NOCOPY VARCHAR2
 );
 PROCEDURE check_rules
 (
    P_Gme_om_config_assign   IN    GML_BATCH_OM_UTIL.gme_om_config_assign
  , X_count                  OUT   NOCOPY NUMBER
  , X_rule_id                OUT   NOCOPY NUMBER
  , X_return_status          OUT   NOCOPY VARCHAR2
  , X_msg_cont               OUT   NOCOPY NUMBER
  , X_msg_data               OUT   NOCOPY VARCHAR2
 );
END GML_BATCH_OM_UTIL;

 

/
