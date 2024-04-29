--------------------------------------------------------
--  DDL for Package CSP_SCH_INT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_SCH_INT_PVT" AUTHID CURRENT_USER AS
/* $Header: cspgscis.pls 120.0.12010000.14 2013/04/09 12:42:43 htank ship $ */

-- Start of Comments
-- Package name     : CSP_SCH_INT_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


    G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSP_SCH_INT_PVT';
    G_FILE_NAME CONSTANT VARCHAR2(12) := 'cspgscis.pls';

    TYPE csp_sch_resources_rec_typ IS RECORD(resource_id   NUMBER
                                            ,resource_type VARCHAR2(30));

    TYPE csp_sch_options_rec_typ IS RECORD(resource_id      NUMBER
                                          ,resource_type    VARCHAR2(30)
                                          ,start_time       DATE
                                          ,transfer_cost    NUMBER
                                          ,missing_parts    NUMBER
                                          ,available_parts  NUMBER
                                          ,src_warehouse    VARCHAR2(4000)    -- org code (3 char) + '.' (1) char + 10 subinv
                                          ,ship_method      VARCHAR2(4000)
                                          ,distance_str     VARCHAR2(4000));

    TYPE csp_sch_interval_rec_typ IS RECORD(earliest_time   DATE,
                                            latest_time     DATE);

    TYPE CSP_PARTS_REC_TYPE IS RECORD(item_id        NUMBER
                                    ,item_uom        VARCHAR2(3)
                                    ,revision        VARCHAR2(3)
                                    ,quantity        NUMBER
                                    ,ship_set_name   VARCHAR2(30)
                                    ,line_id         NUMBER);

     TYPE CSP_UNAVAILABILITY_REC_TYPE IS RECORD(resource_id       NUMBER
                                             ,resource_type     VARCHAR2(30)
                                             ,organization_id   NUMBER
                                             ,item_id           NUMBER
                                             ,revision          VARCHAR2(3)
                                             ,item_uom          VARCHAR2(3)
                                             ,item_type         NUMBER
                                             ,line_id           NUMBER
                                             ,quantity          NUMBER
                                             ,ship_set_name     VARCHAR2(30));

   TYPE CSP_AVAILABILITY_REC_TYPE IS RECORD(resource_id       NUMBER
                                           ,resource_type     VARCHAR2(30)
                                           ,organization_id   NUMBER
                                           ,destination_location_id NUMBER
                                           ,line_id           NUMBER
                                           ,item_id           NUMBER
                                           ,item_uom          VARCHAR2(3)
                                           ,item_type         NUMBER
                                           ,revision          VARCHAR2(3)
                                           ,quantity          NUMBER
                                           ,available_quantity NUMBER
                                           ,source_org        NUMBER
                                           ,sub_inventory     VARCHAR2(10)
                                           ,available_date    DATE
                                           ,shipping_methode  VARCHAR2(30)
                                           ,intransit_time    NUMBER
                                           ,replenishment_source varchar2(3)
                                           );

    TYPE AVAILABLE_PARTS_REC_TYP IS RECORD(item_id             NUMBER
                                          ,item_uom            varchar2(10)
                                         ,required_quantity    NUMBER
                                         ,source_org_id        NUMBER
                                         ,sub_inventory_code   VARCHAR2(10)
                                         ,reserved_quantity    NUMBER
                                         ,ordered_quantity     NUMBER
                                         ,available_quantity   NUMBER
                                         ,shipping_methode     VARCHAR2(30)
                                         ,arraival_date        DATE
                                         ,order_by_date        DATE
                                         ,source_type          VARCHAR2(50)
                                         ,line_id              NUMBER
                                         ,item_type           NUMBER
                                         ,recommended_option  VARCHAR2(1)
                                         ,revision varchar2(3));
    TYPE RESERVATION_REC_TYP IS RECORD(need_by_date       DATE
                                     ,organization_id    NUMBER
                                     ,item_id            NUMBER
                                     ,item_uom_code      VARCHAR2(3)
                                     ,quantity_needed    NUMBER
                                     ,sub_inventory_code VARCHAR2(10)
                                     ,line_id            NUMBER
                                     ,revision           varchar2(3)
									 ,serial_number		 varchar2(30));
    TYPE ws_AVAILABLE_PARTS_REC_TYP IS RECORD(resource_id      NUMBER
                                             ,resource_type    varchar2(30)
                                             ,distance        NUMBER
                                             ,unit            varchar(10)
                                             ,phone_number    varchar2(30)
                                             ,name            varchar2(240)
                                             ,item_id         NUMBER
                                             ,item_number     varchar2(240)
                                             ,item_uom            varchar2(10)
                                             ,item_type           varchar2(30)
                                             ,source_org_id        NUMBER
                                             ,location_id          NUMBER
                                             ,sub_inventory_code   VARCHAR2(10)
                                             ,available_quantity   NUMBER
                                             ,on_hand_quantity     NUMBER
                                             ,shipping_method_code  varchar2(30)
                                             ,shipping_methode     VARCHAR2(80)
                                             ,arraival_date        DATE
                                             ,order_by_date        DATE
                                             ,source_type          VARCHAR2(50)
                                             ,revision             varchar2(3)
                                             );
    TYPE csp_ws_resource_rec_type IS record (resource_type varchar2(30)
                                              ,resource_id NUMBER
                                              ,distance NUMBER
                                              ,unit varchar2(10)
                                              ,phone_number varchar2(30)
                                              ,name varchar2(240));

    TYPE alternate_item_rec_type IS RECORD(item NUMBER
                                            ,revision varchar2(3)
                                               ,item_uom varchar2(10)
                                               ,item_quantity NUMBER
                                              ,alternate_item NUMBER
                                              ,alternate_item_uom varchar2(10)
                                              ,alternate_item_quantity NUMBER
                                              ,relation_type NUMBER);



    TYPE csp_sch_resource_tbl_typ IS TABLE OF csp_sch_resources_rec_typ;

    TYPE csp_sch_options_tbl_typ  IS TABLE OF csp_sch_options_rec_typ ;

    TYPE CSP_UNAVAILABILITY_TBL_TYPE IS TABLE OF CSP_SCH_INT_PVT.CSP_UNAVAILABILITY_REC_TYPE ;

     TYPE CSP_AVAILABILITY_TBL_TYPE IS TABLE OF CSP_SCH_INT_PVT.CSP_AVAILABILITY_REC_TYPE ;

     TYPE CSP_PARTS_TBL_TYPE IS TABLE OF CSP_SCH_INT_PVT.CSP_PARTS_REC_TYPE;

     TYPE AVAILABLE_PARTS_TBL_TYP IS TABLE OF CSP_SCH_INT_PVT.AVAILABLE_PARTS_REC_TYP;
     TYPE AVAILABLE_PARTS_TBL_TYP1 IS TABLE OF CSP_SCH_INT_PVT.AVAILABLE_PARTS_REC_TYP INDEX BY BINARY_INTEGER;
     TYPE CSP_PARTS_TBL_TYP1 IS TABLE OF CSP_SCH_INT_PVT.CSP_PARTS_REC_TYPE INDEX BY BINARY_INTEGER;
     TYPE ws_AVAILABLE_PARTS_tbl_TYP IS table of ws_AVAILABLE_PARTS_REC_TYP;
     TYPE csp_ws_resource_table_type IS table of csp_ws_resource_rec_type;
     TYPE alternate_items_table_type IS TABLE OF alternate_item_rec_type;

    PROCEDURE GET_AVAILABILITY_OPTIONS(p_api_version_number IN  NUMBER
                                      ,p_task_id            IN  NUMBER
                                      ,p_resources          IN CSP_SCH_INT_PVT.csp_sch_resource_tbl_typ
                                      ,p_interval           IN CSP_SCH_INT_PVT.csp_sch_interval_rec_typ
                                      ,p_likelihood         IN  NUMBER
                                      ,p_subinv_only        IN  BOOLEAN DEFAULT FALSE
                                      ,p_mandatory          IN  BOOLEAN DEFAULT TRUE
                                      ,p_trunk              IN  BOOLEAN DEFAULT TRUE
                                      ,p_warehouse          IN  BOOLEAN DEFAULT TRUE
                                      ,x_options            OUT NOCOPY CSP_SCH_INT_PVT.csp_sch_options_tbl_typ
                                      ,x_return_status      OUT NOCOPY VARCHAR2
                                      ,x_msg_data           OUT NOCOPY VARCHAR2
                                      ,x_msg_count          OUT NOCOPY NUMBER);

   PROCEDURE CHOOSE_OPTION(p_api_version_number IN  NUMBER
                          ,p_task_id            IN  NUMBER
                          ,p_task_assignment_id IN  NUMBER
                          ,p_likelihood         IN  NUMBER
                          ,p_mandatory          IN  BOOLEAN DEFAULT TRUE
                          ,p_trunk              IN  BOOLEAN DEFAULT TRUE
                          ,p_warehouse          IN  BOOLEAN DEFAULT TRUE
                          ,p_options            IN CSP_SCH_INT_PVT.csp_sch_options_rec_typ
                          ,x_return_status      OUT NOCOPY VARCHAR2
                          ,x_msg_data           OUT NOCOPY VARCHAR2
                          ,x_msg_count          OUT NOCOPY NUMBER);

   PROCEDURE CLEAN_MATERIAL_TRANSACTION(p_api_version_number  IN  NUMBER
                                        ,p_task_assignment_id  IN  NUMBER
                                        ,x_return_status       OUT NOCOPY VARCHAR2
                                        ,x_msg_data            OUT NOCOPY VARCHAR2
                                        ,x_msg_count           OUT NOCOPY NUMBER);

   PROCEDURE CLEAN_REQUIREMENT(p_api_version_number  IN  NUMBER
                                        ,p_task_assignment_id  IN  NUMBER
                                        ,x_return_status       OUT NOCOPY VARCHAR2
                                        ,x_msg_data            OUT NOCOPY VARCHAR2
                                        ,x_msg_count           OUT NOCOPY NUMBER);

   PROCEDURE CREATE_ORDERS(p_api_version_number  IN  NUMBER
                         ,p_task_assignment_id  IN  NUMBER
                         ,x_return_status       OUT NOCOPY VARCHAR2
                         ,x_msg_data            OUT NOCOPY VARCHAR2
                         ,x_msg_count           OUT NOCOPY NUMBER);
   PROCEDURE CHECK_PARTS_AVAILABILITY(p_resource           IN CSP_SCH_INT_PVT.csp_sch_resources_rec_typ
                                       ,p_organization_id  IN  NUMBER
                                       ,P_subinv_code      IN VARCHAR2
                                       ,p_need_by_date     IN  DATE
                                       ,p_parts_list       IN CSP_SCH_INT_PVT.CSP_PARTS_TBL_TYP1
                                       ,p_timezone_id      IN  NUMBER
                                       ,x_availability     OUT NOCOPY CSP_SCH_INT_PVT.AVAILABLE_PARTS_TBL_TYP1
                                       ,x_return_status    OUT NOCOPY VARCHAR2
                                       ,x_msg_data         OUT NOCOPY VARCHAR2
                                       ,x_msg_count        OUT NOCOPY NUMBER
                                       ,p_called_from     IN varchar2 DEFAULT 'SPARES'
                                       ,p_location_id     IN NUMBER DEFAULT NULL
                                       ,p_include_alternates IN BOOLEAN DEFAULT NULL
                                       );
   PROCEDURE CHECK_LOCAL_INVENTORY(   p_org_id        IN   NUMBER
                                     ,p_revision      IN   varchar2
                                     ,p_subinv_code   IN   VARCHAR2
                                     ,p_item_id       IN   NUMBER
                                     ,x_att           OUT NOCOPY  NUMBER
                                     ,x_onhand        OUT NOCOPY  NUMBER
                                     ,x_return_status OUT NOCOPY  VARCHAR2
                                     ,x_msg_data      OUT NOCOPY  VARCHAR2
                                     ,x_msg_count     OUT NOCOPY  NUMBER);
  FUNCTION CREATE_RESERVATION(p_reservation_parts IN
CSP_SCH_INT_PVT.RESERVATION_REC_TYP
                                ,x_return_status     OUT NOCOPY VARCHAR2
                                ,x_msg_data         OUT NOCOPY VARCHAR2)  RETURN NUMBER;
  PROCEDURE TASKS_POST_INSERT( x_return_status out NOCOPY varchar2);

  PROCEDURE ws_Check_other_eng_subinv(p_resource_list IN CSP_SCH_INT_PVT.csp_ws_resource_table_type
                                   ,p_parts_list    IN CSP_SCH_INT_PVT.CSP_PARTS_TBL_TYP1
                                   ,p_include_alternate IN varchar2  DEFAULT 'N'
                                   ,x_available_list   OUT NOCOPY CSP_SCH_INT_PVT.ws_AVAILABLE_PARTS_tbl_TYP
                                   ,x_return_status   OUT NOCOPY varchar2
                                   ,x_msg_data      OUT NOCOPY varchar2
                                   ,x_msg_count      OUT NOCOPY  NUMBER);
   PROCEDURE ws_Check_engineers_subinv(p_resource_type IN varchar2
                                   ,p_resource_id  IN NUMBER
                                   ,p_parts_list    IN CSP_SCH_INT_PVT.CSP_PARTS_TBL_TYP1
                                   ,p_include_alternate IN varchar2  DEFAULT 'N'
                                   ,x_available_list   OUT NOCOPY CSP_SCH_INT_PVT.ws_AVAILABLE_PARTS_tbl_TYP
                                   ,x_return_status   OUT NOCOPY varchar2
                                   ,x_msg_data      OUT NOCOPY varchar2
                                   ,x_msg_count      OUT NOCOPY  NUMBER);
    PROCEDURE ws_Check_organizations(p_resource_type IN varchar2
                                   ,p_resource_id  IN NUMBER
                                   ,p_parts_list    IN csp_sch_int_pvt.CSP_PARTS_TBL_TYP1
                                   ,p_include_alternate IN varchar2  DEFAULT 'N'
                                   ,x_available_list   OUT NOCOPY csp_sch_int_pvt.ws_AVAILABLE_PARTS_tbl_TYP
                                   ,x_return_status   OUT NOCOPY varchar2
                                   ,x_msg_data      OUT NOCOPY varchar2
                                   ,x_msg_count      OUT NOCOPY  NUMBER);
   PROCEDURE    get_alternates(p_parts_rec    IN CSP_SCH_INT_PVT.CSP_PARTS_REC_TYPE
                               ,p_org_id      IN  NUMBER
                               ,px_alternate_items IN OUT NOCOPY csp_sch_int_pvt.alternate_items_table_type
                               ,x_return_status OUT NOCOPY varchar2
                               ,x_msg_data      OUT NOCOPY varchar2
                               ,x_msg_count     OUT NOCOPY NUMBER);


   PROCEDURE TASK_POST_CANCEL(x_return_status out nocopy varchar2);
   PROCEDURE CREATE_RES_FOR_RCV_TRANXS(p_transaction_id IN NUMBER
                                           ,x_return_Status  OUT NOCOPY varchar2
                                           ,x_msg_data OUT NOCOPY varchar2);

  PROCEDURE GET_DELIVERY_DATE(p_relation_ship_id  IN  NUMBER,
                                 x_delivery_date     OUT NOCOPY DATE,
                                 x_shipping_option   OUT NOCOPY BOOLEAN,
                                 x_return_status     OUT NOCOPY VARCHAR2
                                 ,x_msg_data         OUT NOCOPY VARCHAR2
                                 ,x_msg_count        OUT NOCOPY NUMBER);

  FUNCTION get_arrival_date(p_ship_date IN DATE,
                                p_lead_time IN NUMBER,
                                p_org_id IN NUMBER) return  DATE;


    PROCEDURE CANCEL_RESERVATION(p_reserv_id      IN NUMBER
                                ,x_return_status OUT NOCOPY VARCHAR2
                                ,x_msg_data      OUT NOCOPY VARCHAR2
                                ,x_msg_count     OUT NOCOPY NUMBER);
     PROCEDURE cancel_order_line(
              p_order_line_id IN NUMBER,
              p_cancel_reason IN Varchar2,
              x_return_status OUT NOCOPY VARCHAR2,
              x_msg_count     OUT NOCOPY NUMBER,
              x_msg_data      OUT NOCOPY VARCHAR2);

   PROCEDURE SPARES_CHECK2(
               p_resources      IN  CSP_SCH_INT_PVT.csp_sch_resource_tbl_typ,
               p_task_id        in     number,
               p_need_by_date   in     date,
               p_trunk          IN  BOOLEAN,
               p_warehouse      IN  BOOLEAN,
               p_mandatory      IN  BOOLEAN,
               x_options        OUT NOCOPY  CSP_SCH_INT_PVT.csp_sch_options_tbl_typ,
               x_return_status  OUT NOCOPY    VARCHAR2,
               x_msg_data       OUT NOCOPY    VARCHAR2,
               x_msg_count      OUT NOCOPY    NUMBER);

	procedure move_parts_on_reassign(
		p_task_id in number,
		p_task_asgn_id in number,
		p_new_task_asgn_id in number,
		p_new_need_by_date in date,
		p_new_resource_id in number,
		p_new_resource_type in varchar2,
		x_return_status OUT NOCOPY VARCHAR2,
		x_msg_count     OUT NOCOPY NUMBER,
		x_msg_data      OUT NOCOPY VARCHAR2
	);

 END    CSP_SCH_INT_PVT;


/
