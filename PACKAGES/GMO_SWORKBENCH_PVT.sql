--------------------------------------------------------
--  DDL for Package GMO_SWORKBENCH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMO_SWORKBENCH_PVT" AUTHID CURRENT_USER AS
/* $Header: GMOVSWBS.pls 120.2 2007/08/06 06:09:10 rvsingh noship $ */
G_PKG_NAME CONSTANT VARCHAR2(40) := 'GMO_SWORKBENCH_PVT';
PROCEDURE UPDATE_PLANNING_STATUS
(
    P_API_VERSION           IN NUMBER,
    P_INIT_MSG_LIST         IN VARCHAR2 DEFAULT FND_API.G_FALSE,
    X_RETURN_STATUS         OUT NOCOPY VARCHAR2,
    X_MSG_COUNT             OUT NOCOPY NUMBER,
    X_MSG_DATA              OUT NOCOPY VARCHAR2,
    P_RESERVATION_ID        IN NUMBER,
    P_DISPENSE_ID           IN NUMBER,
    P_DISPENSED_DATE        IN DATE,
    P_DISPENSE_TYPE         IN VARCHAR2,
    P_DISPENSE_AREA_ID      IN NUMBER,
    P_DISP_ORG_ID           IN NUMBER
);
FUNCTION GET_TASK_PERCENTAGE(area_id number,max_no_of_tasks number,date_value Date) RETURN Number;
FUNCTION GET_TASK_PERCENTAGE(area_id number,max_no_of_tasks number,date_value Date,oper NUMBER) RETURN Number;
FUNCTION GET_WEEKLY_TASK_PERCENTAGE(area_id number,max_no_of_tasks number,week_start_date Date,week_end_date Date) RETURN Number;
FUNCTION GET_WEEKLY_TASK_PERCENTAGE(area_id number,max_no_of_tasks number,week_start_date Date,week_end_date Date,oper NUMBER) RETURN Number;

FUNCTION GET_HOURS(timevalue varchar2)return number;
FUNCTION get_MINUTES(timevalue varchar2)return number;
function get_days(timevalue varchar2)return number;


procedure create_material_reservation(
 p_org_id                  IN              NUMBER
,p_material_detail_id      IN              NUMBER
,p_resv_qty                IN              NUMBER DEFAULT NULL
,p_sec_resv_qty            IN              NUMBER DEFAULT NULL
,p_resv_um                 IN              VARCHAR2 DEFAULT NULL
,p_subinventory            IN              VARCHAR2 DEFAULT NULL
,p_locator_id              IN              NUMBER DEFAULT NULL
,p_lot_number              IN              VARCHAR2 DEFAULT NULL
,x_res_id                  OUT  NOCOPY     NUMBER
,x_msg_data                OUT  NOCOPY     VARCHAR2
, x_msg_count              OUT  NOCOPY     NUMBER
,x_return_status           OUT  NOCOPY     VARCHAR2
);
   PROCEDURE create_material_reservation (
      p_matl_dtl_rec    IN              gme_material_details%ROWTYPE
     ,p_resv_qty        IN              NUMBER DEFAULT NULL
     ,p_sec_resv_qty    IN              NUMBER DEFAULT NULL
     ,p_resv_um         IN              VARCHAR2 DEFAULT NULL
     ,p_subinventory    IN              VARCHAR2 DEFAULT NULL
     ,p_locator_id      IN              NUMBER DEFAULT NULL
     ,p_lot_number      IN              VARCHAR2 DEFAULT NULL
     ,x_msg_data        OUT   NOCOPY    VARCHAR2
     , x_msg_count      OUT   NOCOPY    NUMBER
     ,x_return_status   OUT   NOCOPY    VARCHAR2);
      PROCEDURE validate_mtl_for_reservation(
      p_material_detail_rec    IN              GME_MATERIAL_DETAILS%ROWTYPE
      ,x_msg_data               OUT NOCOPY      VARCHAR2
      , x_msg_count             OUT NOCOPY      NUMBER
      ,x_return_status          OUT NOCOPY      VARCHAR2);
      PROCEDURE update_reservation (
      p_reservation_id   IN              NUMBER
     ,p_revision         IN              VARCHAR2 DEFAULT NULL
     ,p_subinventory     IN              VARCHAR2 DEFAULT NULL
     ,p_locator_id       IN              NUMBER DEFAULT NULL
     ,p_lot_number       IN              VARCHAR2 DEFAULT NULL
     ,p_new_qty          IN              NUMBER DEFAULT NULL
     ,p_new_sec_qty      IN              NUMBER DEFAULT NULL
     ,p_new_uom          IN              VARCHAR2 DEFAULT NULL
     ,p_new_date         IN              DATE DEFAULT NULL
     ,x_return_status    OUT NOCOPY      VARCHAR2);
       PROCEDURE query_reservation (
      p_reservation_id    IN              NUMBER
     ,x_reservation_rec   OUT NOCOPY      inv_reservation_global.mtl_reservation_rec_type
     ,x_return_status     OUT NOCOPY      VARCHAR2);

END;


/
