--------------------------------------------------------
--  DDL for Package WMS_XDOCK_UTILS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_XDOCK_UTILS_PVT" AUTHID CURRENT_USER AS
  /* $Header: WMSXDUTS.pls 120.1 2005/06/17 17:21:22 appldev  $ */

  g_pkg_spec_ver  CONSTANT VARCHAR2(100) := '$Header: WMSXDUTS.pls 120.1 2005/06/17 17:21:22 appldev  $';
  g_pkg_name      CONSTANT VARCHAR2(30)  := 'WMS_XDOCK_UTILS_PVT';


  --
  -- Constants used in Planned Crossdocking
  --

  -- Types of sources
  G_SRC_TYPE_SUP       CONSTANT NUMBER := 1;   -- Source type SUPPLY
  G_SRC_TYPE_DEM       CONSTANT NUMBER := 2;   -- Source type DEMAND

  -- Crossdock criterion types
  G_CRT_TYPE_OPP       CONSTANT NUMBER := 1;   -- Criterion type Opportunistic
  G_CRT_TYPE_PLAN      CONSTANT NUMBER := 2;   -- Criterion type Planned

  -- Scheduling methods
  G_APPT_START_TIME    CONSTANT NUMBER := 1;   -- Start of dock appointment
  G_APPT_MEAN_TIME     CONSTANT NUMBER := 2;   -- Mid-point of dock appointment
  G_APPT_END_TIME      CONSTANT NUMBER := 3;   -- End of dock appointment

  -- Crossdocking goals
  G_MINIMIZE_WAIT      CONSTANT NUMBER := 1;
  G_MAXIMIZE_XDOCK     CONSTANT NUMBER := 2;
  G_CUSTOM_GOAL        CONSTANT NUMBER := 3;

  -- Demand sources for Opportunistic Crossdock
  G_OPP_DEM_SO_SCHED   CONSTANT NUMBER := 10;  -- Sales Order (Scheduled)
  G_OPP_DEM_SO_BKORD   CONSTANT NUMBER := 20;  -- Sales Order (Backordered)
  G_OPP_DEM_IO_SCHED   CONSTANT NUMBER := 30;  -- Internal Order (Scheduled)
  G_OPP_DEM_IO_BKORD   CONSTANT NUMBER := 40;  -- Internal Order (Backordered)
  G_OPP_DEM_WIP_BKORD  CONSTANT NUMBER := 50;  -- WIP Component Demand (Backordered)

  -- Supply sources for Opportunistic Crossdock
  G_OPP_SUP_PO_RCV     CONSTANT NUMBER := 10;  -- PO (In Receiving)
  G_OPP_SUP_REQ_RCV    CONSTANT NUMBER := 20;  -- Internal Req (In Receiving)
  G_OPP_SUP_WIP        CONSTANT NUMBER := 30;  -- WIP
  G_OPP_SUP_INTR_RCV   CONSTANT NUMBER := 40;  -- In transit shipments (In Receiving)

  -- Demand sources for Planned Crossdock
  G_PLAN_DEM_SO_SCHED  CONSTANT NUMBER := 10;  -- Sales Order (Scheduled)
  G_PLAN_DEM_SO_BKORD  CONSTANT NUMBER := 20;  -- Sales Order (Backordered)
  G_PLAN_DEM_IO_SCHED  CONSTANT NUMBER := 30;  -- Internal Order (Scheduled)
  G_PLAN_DEM_IO_BKORD  CONSTANT NUMBER := 40;  -- Internal Order (Backordered)

  -- Supply sources for Planned Crossdock
  G_PLAN_SUP_PO_APPR   CONSTANT NUMBER := 10;  -- Approved PO
  G_PLAN_SUP_ASN       CONSTANT NUMBER := 20;  -- ASN
  G_PLAN_SUP_REQ       CONSTANT NUMBER := 30;  -- Internal Req
  G_PLAN_SUP_INTR      CONSTANT NUMBER := 40;  -- Intransit Shipments
  G_PLAN_SUP_WIP       CONSTANT NUMBER := 50;  -- WIP
  G_PLAN_SUP_RCV       CONSTANT NUMBER := 60;  -- Material in Receiving

  --
  -- End of list of constants
  --

  -- Switch to indicate if reservation change is triggered
  -- from the demand side or not (default is FALSE)
  G_DEMAND_TRIGGERED   BOOLEAN := FALSE;


  FUNCTION is_eligible_supply_source
  ( p_criterion_id   IN   NUMBER
  , p_source_code    IN   NUMBER
  ) RETURN BOOLEAN;


  FUNCTION is_eligible_demand_source
  ( p_criterion_id   IN   NUMBER
  , p_source_code    IN   NUMBER
  ) RETURN BOOLEAN;


  PROCEDURE create_crossdock_reservation
  ( x_return_status   OUT NOCOPY   VARCHAR2
  , p_rsv_rec         IN  inv_reservation_global.mtl_reservation_rec_type
  );


  PROCEDURE update_crossdock_reservation
  ( x_return_status   OUT NOCOPY   VARCHAR2
  , p_orig_rsv_rec    IN  inv_reservation_global.mtl_reservation_rec_type
  , p_new_rsv_rec     IN  inv_reservation_global.mtl_reservation_rec_type
  );


  PROCEDURE transfer_crossdock_reservation
  ( x_return_status   OUT NOCOPY   VARCHAR2
  , p_orig_rsv_rec    IN  inv_reservation_global.mtl_reservation_rec_type
  , p_new_rsv_rec     IN  inv_reservation_global.mtl_reservation_rec_type
  );


  PROCEDURE delete_crossdock_reservation
  ( x_return_status   OUT NOCOPY   VARCHAR2
  , p_rsv_rec         IN  inv_reservation_global.mtl_reservation_rec_type
  );


  PROCEDURE relieve_crossdock_reservation
  ( x_return_status   OUT NOCOPY   VARCHAR2
  , p_rsv_rec         IN  inv_reservation_global.mtl_reservation_rec_type
  );


END wms_xdock_utils_pvt;

 

/
