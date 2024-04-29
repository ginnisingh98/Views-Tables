--------------------------------------------------------
--  DDL for Package Body CSP_SCH_INT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_SCH_INT_PVT" as
/* $Header: cspgscib.pls 120.9.12010000.102 2013/08/22 10:54:17 rrajain ship $
 * */
-- Start of Comments
-- Package name     : CSP_SCH_INT_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

    G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSP_SCH_INT_PVT';
   G_FILE_NAME CONSTANT VARCHAR2(12) := 'cspgscib.pls';

   g_interval  CSP_SCH_INT_PVT.csp_sch_interval_rec_typ;
   g_schedular_call  VARCHAR2(1) := 'Y' ;
   g_shipto_timezone_id NUMBER;
   g_earliest_delivery_date Date := sysdate + 365 * 10;

   TYPE CSP_RESOURCE_ORG_REC_TYP IS RECORD(resource_id      NUMBER
                                          ,resource_type    VARCHAR2(30)
                                          ,organization_id  NUMBER
                                          ,sub_inv_code     VARCHAR2(10));

   TYPE CSP_RESOURCE_ORG_tbl_TYP IS TABLE OF CSP_SCH_INT_PVT.CSP_RESOURCE_ORG_REC_TYP ;

   TYPE CSP_SHIP_PARAMETERS_REC_TYPE IS RECORD( resource_id        NUMBER
                                               ,resource_type      VARCHAR2(30)
                                               ,lead_time          NUMBER
                                               ,transfer_cost      NUMBER
                                               ,shipping_methodes  VARCHAR2(4000)
                                               ,arrival_date       DATE);

   TYPE CSP_SHIP_PARAMETERS_TBL_TYPE IS TABLE OF CSP_SCH_INT_PVT.CSP_SHIP_PARAMETERS_REC_TYPE ;

   TYPE CSP_ORGS_SHIP_PARAM_REC_TYPE IS RECORD(resource_id         NUMBER
                                               ,resource_type      VARCHAR2(30)
                                               ,from_org_id        NUMBER
                                               ,to_org_id          NUMBER
                                               ,quantity           NUMBER
                                               ,lead_time          NUMBER
                                               ,transfer_cost      NUMBER
                                               ,shipping_method    VARCHAR2(30)
                                               ,delivery_time      DATE);

   TYPE CSP_ORGS_SHIP_PARAM_TBL_TYPE IS TABLE OF CSP_SCH_INT_PVT.CSP_ORGS_SHIP_PARAM_REC_TYPE;


   TYPE CSP_SHIP_QUANTITY_REC_TYPE IS RECORD(resource_id    NUMBER
                                        ,resource_type      VARCHAR2(30)
                                        ,from_org_id        NUMBER
                                        ,to_org_id          NUMBER
                                        ,quantity           NUMBER
                                        ,destination_location_id      NUMBER);

   TYPE CSP_SHIP_QUANTITY_TBL_TYPE IS TABLE OF CSP_SCH_INT_PVT.CSP_SHIP_QUANTITY_REC_TYPE ;

   TYPE CSP_SHIP_METHOD_COUNT_REC_TYP IS RECORD(from_org_id         NUMBER
                                                ,to_org_id          NUMBER
                                                ,shipping_methodes  NUMBER
                                                ,min_leadtime       NUMBER
                                                ,max_leadtime       NUMBER);


   TYPE CSP_SHIP_METHOD_COUNT_TBL_TYP IS TABLE OF CSP_SCH_INT_PVT.CSP_SHIP_METHOD_COUNT_REC_TYP ;


    TYPE org_ship_methodes IS RECORD(from_org NUMBER,
                                         to_org   NUMBER,
                                         shipping_methode varchar2(30));

    TYPE org_ship_methodes_tbl_type IS TABLE OF csp_sch_int_pvt.org_ship_methodes ;
    TYPE csp_req_line_details_rec_typ is  RECORD(req_line_detail_id    NUMBER
                                                ,requirement_line_id   NUMBER
                                                ,source_type           varchar2(30)
                                                ,source_id            NUMBER);
    TYPE csp_req_line_details_tabl_typ is table of csp_req_line_details_rec_typ;

procedure log(p_procedure in varchar2,p_message in varchar2) as
begin
    --dbms_output.put_line(p_procedure||' - '||p_message);
    if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   'csp.plsql.csp_sch_int_pvt.'||p_procedure,
                   p_message);
    end if;
end;

   PROCEDURE GET_ORGANIZATION_SUBINV(p_resources            IN  CSP_SCH_INT_PVT.csp_sch_resource_tbl_typ
                                    ,x_resource_org_subinv  OUT NOCOPY CSP_SCH_INT_PVT.csp_resource_org_tbl_typ
                                    ,x_return_status        OUT NOCOPY VARCHAR2
                                    ,x_msg_data             OUT NOCOPY VARCHAR2
                                    ,x_msg_count            OUT NOCOPY NUMBER);

   PROCEDURE GET_PARTS_LIST(p_task_id       IN NUMBER
                           ,p_likelihood    IN NUMBER
                           ,x_parts_list    OUT NOCOPY CSP_SCH_INT_PVT.csp_parts_tbl_typ1
                           ,x_return_status OUT NOCOPY VARCHAR2
                           ,x_msg_data      OUT NOCOPY VARCHAR2
                           ,x_msg_count     OUT NOCOPY NUMBER);

   PROCEDURE CHECK_LOCAl_INVENTORY( p_resource_org_subinv  IN  CSP_SCH_INT_PVT.CSP_RESOURCE_ORG_tbl_TYP
                                   ,p_parts_list           IN  CSP_SCH_INT_PVT.CSP_PARTS_TBL_TYP1
                                   ,p_trunk                IN BOOLEAN
                                   ,x_unavailable_list    OUT NOCOPY  CSP_SCH_INT_PVT.CSP_UNAVAILABILITY_TBL_TYPE
                                   ,x_available_list      OUT NOCOPY  CSP_SCH_INT_PVT.CSP_AVAILABILITY_TBL_TYPE
                                   ,x_return_status       OUT NOCOPY VARCHAR2
                                   ,x_msg_data            OUT NOCOPY VARCHAR2
                                   ,x_msg_count           OUT NOCOPY NUMBER);

   PROCEDURE DO_ATP_CHECK(p_unavailable_list       IN     CSP_SCH_INT_PVT.CSP_UNAVAILABILITY_TBL_TYPE
                         ,p_interval               IN     CSP_SCH_INT_PVT.csp_sch_interval_rec_typ
                         ,px_available_list        IN OUT NOCOPY CSP_SCH_INT_PVT.CSP_AVAILABILITY_TBL_TYPE
                         ,x_final_unavailable_list OUT NOCOPY    CSP_SCH_INT_PVT.CSP_UNAVAILABILITY_TBL_TYPE
                         ,x_return_status          OUT NOCOPY    VARCHAR2
                         ,x_msg_data               OUT NOCOPY    VARCHAR2
                         ,x_msg_count              OUT NOCOPY    NUMBER);

   PROCEDURE SPARES_CHECK(p_unavailable_list       IN     CSP_SCH_INT_PVT.CSP_UNAVAILABILITY_TBL_TYPE
                         ,p_interval               IN     CSP_SCH_INT_PVT.csp_sch_interval_rec_typ
                         ,px_available_list        IN OUT NOCOPY CSP_SCH_INT_PVT.CSP_AVAILABILITY_TBL_TYPE
                         ,x_final_unavailable_list OUT NOCOPY    CSP_SCH_INT_PVT.CSP_UNAVAILABILITY_TBL_TYPE
                         ,x_return_status          OUT NOCOPY    VARCHAR2
                         ,x_msg_data               OUT NOCOPY    VARCHAR2
                         ,x_msg_count              OUT NOCOPY    NUMBER);

   PROCEDURE ELIGIBLE_RESOURCES(p_resource_list            IN  CSP_SCH_INT_PVT.CSP_SCH_RESOURCE_tbl_TYP
                               ,p_available_list           IN  CSP_SCH_INT_PVT.CSP_AVAILABILITY_TBL_TYPE
                               ,p_final_unavailable_list   IN  CSP_SCH_INT_PVT.CSP_UNAVAILABILITY_TBL_TYPE
                               ,x_eligible_resources_list  OUT NOCOPY CSP_SCH_INT_PVT.CSP_AVAILABILITY_TBL_TYPE
                               ,x_return_status            OUT NOCOPY VARCHAR2
                               ,x_msg_data                 OUT NOCOPY VARCHAR2
                               ,x_msg_count                OUT NOCOPY NUMBER);

   PROCEDURE CONSOLIDATE_QUANTITIES(p_eligible_resources_list IN  CSP_SCH_INT_PVT.CSP_AVAILABILITY_TBL_TYPE
                                   ,x_ship_quantity           OUT NOCOPY    CSP_SCH_INT_PVT.CSP_SHIP_QUANTITY_TBL_TYPE
                                   ,x_return_status OUT NOCOPY VARCHAR2
                                   ,X_MSG_DATA      OUT NOCOPY VARCHAR2
                                   ,x_msg_count     OUT NOCOPY NUMBER);


   PROCEDURE EXTEND_ATP_REC(p_atp_rec IN OUT NOCOPY MRP_ATP_PUB.ATP_REC_TYP
                             ,x_return_status OUT NOCOPY VARCHAR2);

   /*PROCEDURE GET_TIME_COST(p_eligible_resources_list  IN  CSP_SCH_INT_PVT.CSP_AVAILABILITY_TBL_TYPE
                          ,x_options                  OUT NOCOPY CSP_SCH_INT_PVT.csp_sch_options_tab_typ
                          ,x_return_status            OUT NOCOPY VARCHAR2);*/

   PROCEDURE BUILD_FINAL_LIST(p_temp_options  IN  CSP_SCH_INT_PVT.CSP_SHIP_PARAMETERS_TBL_TYPE
                               ,px_options IN OUT NOCOPY CSP_SCH_INT_PVT.csp_sch_options_tbl_typ
                               ,x_return_status OUT NOCOPY VARCHAR2
                               ,x_msg_data      OUT NOCOPY VARCHAR2
                               ,x_msg_count     OUT NOCOPY NUMBER);

   PROCEDURE OPTIMIZE_OPTIONS(p_eligible_resources IN  CSP_SCH_INT_PVT.CSP_AVAILABILITY_TBL_TYPE
                              ,px_options       IN OUT NOCOPY CSP_SCH_INT_PVT.CSP_SHIP_PARAMETERS_TBL_TYPE
                              ,x_ship_count        OUT NOCOPY CSP_SCH_INT_PVT.CSP_SHIP_METHOD_COUNT_TBL_TYP
                              ,x_ship_parameters   OUT NOCOPY CSP_SCH_INT_PVT.CSP_ORGS_SHIP_PARAM_TBL_TYPE
                              ,x_return_status     OUT NOCOPY VARCHAR2
                              ,x_msg_data          OUT NOCOPY VARCHAR2
                              ,x_msg_count         OUT NOCOPY NUMBER);

   PROCEDURE GET_SHIPPING_PARAMETERS(p_ship_quantity            IN CSP_SCH_INT_PVT.CSP_SHIP_QUANTITY_TBL_TYPE
                                    ,x_resource_ship_parameters OUT NOCOPY CSP_SCH_INT_PVT.CSP_ORGS_SHIP_PARAM_TBL_TYPE
                                    ,x_ship_count               OUT NOCOPY CSP_SCH_INT_PVT.CSP_SHIP_METHOD_COUNT_TBL_TYP
                                    ,x_return_status            OUT NOCOPY VARCHAR2
                                    ,x_msg_data                 OUT NOCOPY VARCHAR2
                                    ,x_msg_count                OUT NOCOPY NUMBER);

   PROCEDURE GET_TIME_COST(p_eligible_resources_list  IN  CSP_SCH_INT_PVT.CSP_AVAILABILITY_TBL_TYPE
                          ,x_options                  OUT NOCOPY CSP_SCH_INT_PVT.csp_sch_options_tbl_typ
                          ,x_return_status            OUT NOCOPY VARCHAR2
                          ,x_msg_data                 OUT NOCOPY VARCHAR2
                          ,x_msg_count                OUT NOCOPY NUMBER);


   PROCEDURE CANCEL_ORDER(p_order_id       IN  NUMBER
                         ,x_return_status  OUT NOCOPY VARCHAR2
                         ,x_msg_data       OUT NOCOPY VARCHAR2
                         ,x_msg_count      OUT NOCOPY NUMBER);

   PROCEDURE GET_SHIPPING_METHODE(p_from_org_id     IN   NUMBER,
                                   p_to_org_id        IN   NUMBER,
                                   p_need_by_date     IN   DATE,
                                   p_timezone_id      IN   NUMBER,
                                   x_shipping_methode OUT NOCOPY  VARCHAR2,
                                   x_intransit_time   OUT NOCOPY  NUMBER,
                                   x_return_status    OUT NOCOPY  VARCHAR2
                                   , x_msg_data       OUT NOCOPY  VARCHAR2
                                   , x_msg_count      OUT NOCOPY  NUMBER);



    PROCEDURE TRANSFER_RESERVATION(p_reservation_id  IN  NUMBER
                                   ,p_order_header_id IN  NUMBER
                                   ,p_order_line_id   IN  NUMBER
                                   ,x_return_status   OUT NOCOPY VARCHAR2
                                   ,x_reservation_id   OUT NOCOPY NUMBER
                                   ,x_msg_data        OUT NOCOPY VARCHAR2
                                   ,x_msg_count       OUT NOCOPY NUMBER);

    PROCEDURE strip_into_lines (px_options          IN  OUT NOCOPY    CSP_SCH_INT_PVT.CSP_SHIP_PARAMETERS_TBL_TYPE
                                 ,p_ship_count      IN      CSP_SCH_INT_PVT.CSP_SHIP_METHOD_COUNT_TBL_TYP
                                 ,p_res_ship_parameters IN  CSP_SCH_INT_PVT.CSP_ORGS_SHIP_PARAM_TBL_TYPE
                                 ,px_available_list     IN OUT NOCOPY CSP_SCH_INT_PVT.CSP_AVAILABILITY_TBL_TYPE
                                 ,x_msg_data           OUT NOCOPY varchar2
                                 ,x_return_status      OUT NOCOPY varchar2
                                 ,x_msg_count          OUT NOCOPY NUMBER);

   FUNCTION get_order_by_date(p_org_id IN NUMBER,
                                p_ship_method varchar2,
                                p_need_by_date IN DATE,
                                p_lead_time IN NUMBER,
                                p_to_org_id IN NUMBER) return  DATE ;
 procedure get_session_id(p_database_link IN varchar2, x_sesssion_id OUT NOCOPY NUMBER);

 PROCEDURE DELETE_RESERVATION(p_reservation_id IN NUMBER
                                ,x_return_status     OUT NOCOPY VARCHAR2
                                ,x_msg_data         OUT NOCOPY VARCHAR2);

   PROCEDURE GET_AVAILABILITY_OPTIONS(p_api_version_number  IN  NUMBER
                                      ,p_task_id            IN  NUMBER
                                      ,p_resources          IN  CSP_SCH_INT_PVT.csp_sch_resource_tbl_typ
                                      ,p_interval           IN  CSP_SCH_INT_PVT.csp_sch_interval_rec_typ
                                      ,p_likelihood         IN  NUMBER
                                      ,p_subinv_only        IN  BOOLEAN
                                      ,p_mandatory          IN  BOOLEAN
                                      ,p_trunk              IN  BOOLEAN
                                      ,p_warehouse          IN  BOOLEAN
                                      ,x_options            OUT NOCOPY CSP_SCH_INT_PVT.csp_sch_options_tbl_typ
                                      ,x_return_status      OUT NOCOPY VARCHAR2
                                      ,x_msg_data           OUT NOCOPY VARCHAR2
                                      ,x_msg_count          OUT NOCOPY NUMBER) IS

        l_resource_org_subinv     CSP_SCH_INT_PVT.CSP_RESOURCE_ORG_tbl_TYP;
        l_parts_list              CSP_SCH_INT_PVT.CSP_PARTS_TBL_TYP1 ;
        l_unavailable_list        CSP_SCH_INT_PVT.CSP_UNAVAILABILITY_TBL_TYPE ;
        l_available_list          CSP_SCH_INT_PVT.CSP_AVAILABILITY_TBL_TYPE ;
        l_final_available_list    CSP_SCH_INT_PVT.CSP_AVAILABILITY_TBL_TYPE ;
        l_eligible_resources_list CSP_SCH_INT_PVT.CSP_AVAILABILITY_TBL_TYPE ;
        l_final_unavailable_list  CSP_SCH_INT_PVT.CSP_UNAVAILABILITY_TBL_TYPE ;
        l_return_status           VARCHAR2(128) := FND_API.G_RET_STS_SUCCESS;
        l_del_date                VARCHAR2(50);
        l_api_name                VARCHAR2(60) := 'CSP_SCH_INT_PVT.GET_AVAILABILITY_OPTIONS';
        l_temp_line_id            NUMBER;
        l_total_parts             NUMBER := 0;
        l_subinv_only             BOOLEAN := p_subinv_only;
        --hehxxx
        l_search_method           varchar2(30) := fnd_profile.value('CSP_PART_SEARCH_METHOD_SCHEDULER');

         cursor get_line_id is
        select distinct(crl.requirement_line_id) req_line_id
        from csp_requirement_lines  crl,csp_requirement_headers crh
        where crh.task_id = p_task_id
        and crl.requirement_header_id = crh.requirement_header_id;

        cursor get_asgn_id is
        select task_assignment_id
        from jtf_task_assignments
        where task_id = p_task_id;

                l_partial_line number;
                l_fl_rcvd_multi_source number;
                l_oth_req_line number;
                l_fl_rcvd_lines number;
                l_non_src_line number;
                l_shpd_lines number;
                l_tech_spec_pr number;
                l_ship_multi_src number;
                l_old_arrival_date date;
                l_dest_ou number;
                l_rs_ou number;

                cursor get_rs_ou(v_rs_type varchar2, v_rs_id number) is
                SELECT csp.organization_id
                FROM CSP_RS_SUBINVENTORIES_V csp
                WHERE csp.resource_type = v_rs_type
                AND csp.resource_id     = v_rs_id
                AND csp.condition_type  = 'G'
                AND csp.default_flag    = 'Y';

                l_order_number number;

   BEGIN

                if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                                  'csp.plsql.CSP_SCH_INT_PVT.GET_AVAILABILITY_OPTIONS',
                                                  'Begin');
                  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                                  'csp.plsql.CSP_SCH_INT_PVT.GET_AVAILABILITY_OPTIONS',
                                                  'p_task_id=' || p_task_id);
                  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                                  'csp.plsql.CSP_SCH_INT_PVT.GET_AVAILABILITY_OPTIONS',
                                                  'p_resources.count=' || p_resources.count);
                  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                                  'csp.plsql.CSP_SCH_INT_PVT.GET_AVAILABILITY_OPTIONS',
                                                  'p_interval.latest_time=' || to_char(p_interval.latest_time, 'DD-MON-RRRR HH24:MI:SS'));
                end if;

      savepoint GET_AVAILABILITY_OPTIONS_SP;

        if p_warehouse then
          l_subinv_only := FALSE;
        elsif not p_warehouse then
          l_subinv_only := TRUE;
        end if;

        l_resource_org_subinv     := CSP_SCH_INT_PVT.CSP_RESOURCE_ORG_tbl_TYP();
       -- l_parts_list              := CSP_SCH_INT_PVT.CSP_PARTS_TBL_TYP1();
        l_unavailable_list        := CSP_SCH_INT_PVT.CSP_UNAVAILABILITY_TBL_TYPE();
        l_available_list          := CSP_SCH_INT_PVT.CSP_AVAILABILITY_TBL_TYPE ();
        l_eligible_resources_list := CSP_SCH_INT_PVT.CSP_AVAILABILITY_TBL_TYPE() ;
        l_final_unavailable_list  := CSP_SCH_INT_PVT.CSP_UNAVAILABILITY_TBL_TYPE();
        x_options :=  CSP_SCH_INT_PVT.csp_sch_options_tbl_typ();
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        g_interval := p_interval;

    -- bug # 12618325
    -- need to clear old requirement
    if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                      'csp.plsql.CSP_SCH_INT_PVT.GET_AVAILABILITY_OPTIONS',
                      'trying to clear old requirement if it has any...');
    end if;

    for r_asgn in get_asgn_id loop

                -- ER Task Rescheduling
                -- first check if there is any Partial Received order line
                -- if yes then reject the request saying order cannot be cancelled
                -- then check for the fully received case for task cand customer ship to
                -- also, make sure there is no other requirement line with other order line
                -- status, at this moment, we do not support that complex case
                -- then check for already shipped order lines
                -- also, we need to support the case where one line is fully received
                -- or shipped and other line is not yet sourced
                -- in above case, we need to continue with the search process


                -- first check for the partial received order line status
                l_partial_line := 0;
                SELECT count(l.requirement_line_id)
                into l_partial_line
                FROM csp_requirement_headers h,
                  csp_requirement_lines l,
                  csp_req_line_details d,
                  oe_order_lines_all oola
                WHERE h.task_id             = p_task_id
                AND h.task_assignment_id    = r_asgn.task_assignment_id
                AND h.requirement_header_id = l.requirement_header_id
                AND l.requirement_line_id   = d.requirement_line_id
                and d.source_type = 'IO'
                AND d.source_id = oola.line_id
                and csp_pick_utils.get_order_status(oola.line_id,oola.flow_status_code) = 'PARTIALLY RECEIVED';

                if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                                  'csp.plsql.CSP_SCH_INT_PVT.GET_AVAILABILITY_OPTIONS',
                                                  'l_partial_line = ' || l_partial_line);
                end if;

                if l_partial_line > 0 then
                        x_return_status := FND_API.G_RET_STS_ERROR;
                        FND_MESSAGE.SET_NAME('CSP', 'CSP_SCH_NOT_CANCEL_ORDER');
                        FND_MSG_PUB.ADD;
                        fnd_msg_pub.count_and_get
                                        ( p_count => x_msg_count
                                        , p_data  => x_msg_data);
                        return;
                end if;

                -- bug # 14182971
                -- block rescheduling if part is already received for Tech or Special
                -- ship to address type
                l_fl_rcvd_lines := 0;
                SELECT COUNT(l.requirement_line_id)
                into l_fl_rcvd_lines
                FROM csp_requirement_headers h,
                  csp_requirement_lines l,
                  csp_req_line_details dio,
                  csp_req_line_details dres,
                  oe_order_lines_all oola,
                  mtl_reservations mr
                WHERE h.task_id             = p_task_id
                AND h.task_assignment_id    = r_asgn.task_assignment_id
                AND h.address_type         IN ('R', 'S')
                AND h.requirement_header_id = l.requirement_header_id
                AND l.requirement_line_id   = dio.requirement_line_id
                AND dio.source_type        = 'IO'
                and dio.source_id = oola.line_id
                AND csp_pick_utils.get_order_status(oola.line_id,oola.flow_status_code)        = 'FULLY RECEIVED'
                AND dio.requirement_line_id = dres.requirement_line_id
                AND oola.inventory_item_id    = mr.inventory_item_id
                AND oola.ordered_quantity   = mr.reservation_quantity
                AND dres.source_type       = 'RES'
                AND dres.source_id = mr.reservation_id;

                if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                                  'csp.plsql.CSP_SCH_INT_PVT.GET_AVAILABILITY_OPTIONS',
                                                  'l_fl_rcvd_lines (R or S) = ' || l_fl_rcvd_lines);
                end if;

                if l_fl_rcvd_lines > 0 then
                        SELECT ooha.order_number
                        into l_order_number
                        FROM csp_requirement_headers h,
                          csp_requirement_lines l,
                          csp_req_line_details dio,
                          oe_order_lines_all oola,
                          oe_order_headers_all ooha
                        WHERE h.task_id             = p_task_id
                        AND h.task_assignment_id    = r_asgn.task_assignment_id
                        AND h.address_type         IN ('R', 'S')
                        AND h.requirement_header_id = l.requirement_header_id
                        AND l.requirement_line_id   = dio.requirement_line_id
                        AND dio.source_type        = 'IO'
                        and dio.source_id = oola.line_id
                        and oola.header_id = ooha.header_id
                        AND rownum                  = 1;

                        x_return_status := FND_API.G_RET_STS_ERROR;
                        FND_MESSAGE.SET_NAME('CSP', 'CSP_TSK_ASSGN_NO_IO_CAN');
                        FND_MESSAGE.SET_TOKEN('ORDER_NUMBER',l_order_number, FALSE);
                        FND_MSG_PUB.ADD;
                        fnd_msg_pub.count_and_get
                                        ( p_count => x_msg_count
                                        , p_data  => x_msg_data);
                        return;
                end if;

                -- for fully rcvd case
                l_fl_rcvd_lines := 0;
                SELECT COUNT(l.requirement_line_id)
                into l_fl_rcvd_lines
                FROM csp_requirement_headers h,
                  csp_requirement_lines l,
                  csp_req_line_details dio,
                  csp_req_line_details dres,
                  oe_order_lines_all oola,
                  mtl_reservations mr
                WHERE h.task_id             = p_task_id
                AND h.task_assignment_id    = r_asgn.task_assignment_id
                AND h.address_type         IN ('T', 'C', 'P')
                AND h.requirement_header_id = l.requirement_header_id
                AND l.requirement_line_id   = dio.requirement_line_id
                AND dio.source_type        = 'IO'
                and dio.source_id = oola.line_id
                AND csp_pick_utils.get_order_status(oola.line_id,oola.flow_status_code)        = 'FULLY RECEIVED'
                AND dio.requirement_line_id = dres.requirement_line_id
                AND oola.inventory_item_id    = mr.inventory_item_id
                AND oola.ordered_quantity   = mr.reservation_quantity
                AND dres.source_type       = 'RES'
                AND dres.source_id = mr.reservation_id;

                if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                                  'csp.plsql.CSP_SCH_INT_PVT.GET_AVAILABILITY_OPTIONS',
                                                  'l_fl_rcvd_lines (T or C) = ' || l_fl_rcvd_lines);
                end if;

                if l_fl_rcvd_lines > 0 then

                        -- get fully received lines for task and customer ship to case
                        l_fl_rcvd_multi_source := 0;
                        SELECT COUNT(l.requirement_line_id)
                        into l_fl_rcvd_multi_source
                        FROM csp_requirement_headers h,
                          csp_requirement_lines l,
                          csp_req_line_details dio,
                          csp_req_line_details dres,
                          csp_req_line_details dother,
                          oe_order_lines_all oola,
                          mtl_reservations mr
                        WHERE h.task_id             = p_task_id
                        AND h.task_assignment_id    = r_asgn.task_assignment_id
                        AND h.address_type         IN ('T', 'C', 'P')
                        AND h.requirement_header_id = l.requirement_header_id
                        AND l.requirement_line_id   = dio.requirement_line_id
                        AND dio.source_type        = 'IO'
                        AND dio.source_id = oola.line_id
                        AND csp_pick_utils.get_order_status(oola.line_id,oola.flow_status_code)         = 'FULLY RECEIVED'
                        AND dio.requirement_line_id = dres.requirement_line_id
                        AND oola.inventory_item_id    = mr.inventory_item_id
                        AND oola.ordered_quantity   = mr.reservation_quantity
                        AND dres.source_type       = 'RES'
                        AND dres.source_id = mr.reservation_id
                        AND l.requirement_line_id   = dother.requirement_line_id
                        AND dother.source_id       <> dio.source_id
                        AND dother.source_id       <> dres.source_id;

                        if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                                          'csp.plsql.CSP_SCH_INT_PVT.GET_AVAILABILITY_OPTIONS',
                                                          'l_fl_rcvd_multi_source = ' || l_fl_rcvd_multi_source);
                        end if;

                        if l_fl_rcvd_multi_source > 0 then
                                x_return_status := FND_API.G_RET_STS_ERROR;
                                FND_MESSAGE.SET_NAME('CSP', 'CSP_SCH_NOT_CANCEL_ORDER');
                                FND_MSG_PUB.ADD;
                                fnd_msg_pub.count_and_get
                                                ( p_count => x_msg_count
                                                , p_data  => x_msg_data);
                                return;
                        end if;

                        -- check if any other req line sourced
                        l_oth_req_line := 0;
                        SELECT COUNT(requirement_line_id)
                        into l_oth_req_line
                        FROM
                          (SELECT l.requirement_line_id
                          FROM csp_requirement_headers h,
                                csp_requirement_lines l,
                                csp_req_line_details d
                          WHERE h.task_id             = p_task_id
                          AND h.task_assignment_id    = r_asgn.task_assignment_id
                          AND h.requirement_header_id = l.requirement_header_id
                          AND h.address_type         IN ('T', 'C', 'P')
                          AND l.requirement_line_id   = d.requirement_line_id
                          MINUS
                          SELECT l.requirement_line_id
                          FROM csp_requirement_headers h,
                                csp_requirement_lines l,
                                csp_req_line_details dio,
                                csp_req_line_details dres,
                                oe_order_lines_all oola,
                                mtl_reservations mr
                          WHERE h.task_id             = p_task_id
                          AND h.task_assignment_id    = r_asgn.task_assignment_id
                          AND h.address_type         IN ('T', 'C', 'P')
                          AND h.requirement_header_id = l.requirement_header_id
                          AND l.requirement_line_id   = dio.requirement_line_id
                          AND dio.source_type        = 'IO'
                          AND dio.source_id = oola.line_id
                          AND csp_pick_utils.get_order_status(oola.line_id,oola.flow_status_code)       = 'FULLY RECEIVED'
                          AND dio.requirement_line_id = dres.requirement_line_id
                          AND oola.inventory_item_id    = mr.inventory_item_id
                          AND oola.ordered_quantity   = mr.reservation_quantity
                          AND dres.source_type       = 'RES'
                          AND dres.source_id = mr.reservation_id
                          );

                        if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                                          'csp.plsql.CSP_SCH_INT_PVT.GET_AVAILABILITY_OPTIONS',
                                                          'l_oth_req_line = ' || l_oth_req_line);
                        end if;

                        if l_oth_req_line > 0 then
                                x_return_status := FND_API.G_RET_STS_ERROR;
                                FND_MESSAGE.SET_NAME('CSP', 'CSP_SCH_NOT_CANCEL_ORDER');
                                FND_MSG_PUB.ADD;
                                fnd_msg_pub.count_and_get
                                                ( p_count => x_msg_count
                                                , p_data  => x_msg_data);
                                return;
                        end if;

                        --check if there is any not sourced line
                        l_non_src_line := 0;
                        SELECT COUNT(requirement_line_id)
                        into l_non_src_line
                        FROM
                          (SELECT l.requirement_line_id
                          FROM csp_requirement_headers h,
                                csp_requirement_lines l
                          WHERE h.task_id             = p_task_id
                          AND h.task_assignment_id    = r_asgn.task_assignment_id
                          AND h.requirement_header_id = l.requirement_header_id
                          AND h.address_type         IN ('T', 'C', 'P')
                          AND (SELECT COUNT (d.requirement_line_id)
                                FROM csp_req_line_details d
                                WHERE d.requirement_line_id = l.requirement_line_id) = 0
                          MINUS
                          SELECT l.requirement_line_id
                          FROM csp_requirement_headers h,
                                csp_requirement_lines l,
                                csp_req_line_details dio,
                                csp_req_line_details dres,
                                oe_order_lines_all oola,
                                mtl_reservations mr
                          WHERE h.task_id             = p_task_id
                          AND h.task_assignment_id    = r_asgn.task_assignment_id
                          AND h.address_type         IN ('T', 'C', 'P')
                          AND h.requirement_header_id = l.requirement_header_id
                          AND l.requirement_line_id   = dio.requirement_line_id
                          AND dio.source_type        = 'IO'
                          AND dio.source_id = oola.line_id
                          AND csp_pick_utils.get_order_status(oola.line_id,oola.flow_status_code)        = 'FULLY RECEIVED'
                          AND dio.requirement_line_id = dres.requirement_line_id
                          AND oola.inventory_item_id    = mr.inventory_item_id
                          AND oola.ordered_quantity   = mr.reservation_quantity
                          AND dres.source_type       = 'RES'
                          AND dres.source_id = mr.reservation_id
                          );

                        if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                                          'csp.plsql.CSP_SCH_INT_PVT.GET_AVAILABILITY_OPTIONS',
                                                          'l_non_src_line = ' || l_non_src_line);
                        end if;

                        if l_non_src_line = 0 then
                                -- if we are here that means all the lines source have been
                                -- already recived
                                -- return to scheduler saying part is available
                                x_options := CSP_SCH_INT_PVT.csp_sch_options_tbl_typ();
                                for res_count in 1..p_resources.count loop
                                        x_options.extend;
                                        x_options(x_options.count).resource_id   := p_resources(res_count).resource_id;
                                        x_options(x_options.count).resource_type := p_resources(res_count).resource_type;
                                        x_options(x_options.count).start_time    := sysdate + (1/144);
                                        x_options(x_options.count).transfer_cost := 0;
                                        x_options(x_options.count).missing_parts := 0;
                                        x_options(x_options.count).available_parts := 1;        -- not sure if required
                                        x_options(x_options.count).src_warehouse := '';
                                        x_options(x_options.count).ship_method := '';
                                        x_options(x_options.count).distance_str := '';
                                end loop;
                                return;
                        end if;
                end if;

                -- now check for shipped lines
                l_shpd_lines := 0;
                SELECT COUNT(l.requirement_line_id)
                into l_shpd_lines
                FROM csp_requirement_headers h,
                  csp_requirement_lines l,
                  csp_req_line_details d,
                  oe_order_lines_all oola
                WHERE h.task_id             = p_task_id
                AND h.task_assignment_id    = r_asgn.task_assignment_id
                AND h.requirement_header_id = l.requirement_header_id
                AND l.requirement_line_id   = d.requirement_line_id
                AND d.source_type          = 'IO'
                AND d.source_id = oola.line_id
                AND csp_pick_utils.get_order_status(oola.line_id,oola.flow_status_code)          in ('SHIPPED', 'EXPECTED');

                if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                                  'csp.plsql.CSP_SCH_INT_PVT.GET_AVAILABILITY_OPTIONS',
                                                  'l_shpd_lines = ' || l_shpd_lines);
                end if;

                if l_shpd_lines > 0 then
                        l_tech_spec_pr := 0;
                        SELECT count(h.address_type)
                        into l_tech_spec_pr
                        FROM csp_requirement_headers h
                        WHERE h.task_id          = p_task_id
                        AND h.task_assignment_id = r_asgn.task_assignment_id
                        AND h.address_type      IN ('R', 'S');

                        if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                                          'csp.plsql.CSP_SCH_INT_PVT.GET_AVAILABILITY_OPTIONS',
                                                          'l_tech_spec_pr = ' || l_tech_spec_pr);
                        end if;

                        if l_tech_spec_pr > 0 then
                                SELECT ooha.order_number
                                INTO l_order_number
                                FROM csp_requirement_headers h,
                                  csp_requirement_lines l,
                                  csp_req_line_details d,
                                  oe_order_lines_all oola,
                                  oe_order_headers_all ooha
                                WHERE h.task_assignment_id  = r_asgn.task_assignment_id
                                AND h.task_id               = p_task_id
                                AND h.requirement_header_id = l.requirement_header_id
                                AND l.requirement_line_id   = d.requirement_line_id
                                AND d.source_type          = 'IO'
                                AND d.source_id = oola.line_id
                                AND oola.header_id = ooha.header_id
                                AND csp_pick_utils.get_order_status(oola.line_id,oola.flow_status_code)         IN ('SHIPPED', 'EXPECTED')
                                AND rownum                  = 1;

                                x_return_status := FND_API.G_RET_STS_ERROR;
                                FND_MESSAGE.SET_NAME('CSP', 'CSP_TSK_ASSGN_NO_IO_CAN');
                                FND_MESSAGE.SET_TOKEN('ORDER_NUMBER',l_order_number, FALSE);
                                FND_MSG_PUB.ADD;
                                fnd_msg_pub.count_and_get
                                                ( p_count => x_msg_count
                                                , p_data  => x_msg_data);
                                return;
                        else
                                -- now check for same line multiple IO case
                                l_ship_multi_src := 0;
                                SELECT COUNT(l.requirement_line_id)
                                into l_ship_multi_src
                                FROM csp_requirement_headers h,
                                  csp_requirement_lines l,
                                  csp_req_line_details d,
                                  csp_req_line_details dother,
                                  oe_order_lines_all oola
                                WHERE h.task_id                = p_task_id
                                AND h.task_assignment_id       = r_asgn.task_assignment_id
                                AND h.requirement_header_id    = l.requirement_header_id
                                AND l.requirement_line_id      = d.requirement_line_id
                                AND h.address_type         IN ('T', 'C', 'P')
                                AND d.source_type             = 'IO'
                                AND d.source_id = oola.line_id
                                AND csp_pick_utils.get_order_status(oola.line_id,oola.flow_status_code)              in ('SHIPPED', 'EXPECTED')
                                AND dother.requirement_line_id = l.requirement_line_id
                                AND dother.source_id          <> d.source_id;

                                if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                                  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                                                  'csp.plsql.CSP_SCH_INT_PVT.GET_AVAILABILITY_OPTIONS',
                                                                  'l_ship_multi_src = ' || l_ship_multi_src);
                                end if;

                                if l_ship_multi_src > 0 then
                                        x_return_status := FND_API.G_RET_STS_ERROR;
                                        FND_MESSAGE.SET_NAME('CSP', 'CSP_SCH_NOT_CANCEL_ORDER');
                                        FND_MSG_PUB.ADD;
                                        fnd_msg_pub.count_and_get
                                                        ( p_count => x_msg_count
                                                        , p_data  => x_msg_data);
                                        return;
                                end if;

                                -- check of other source line
                                l_oth_req_line := 0;
                                SELECT COUNT(requirement_line_id)
                                into l_oth_req_line
                                FROM
                                  (SELECT l.requirement_line_id
                                  FROM csp_requirement_headers h,
                                        csp_requirement_lines l,
                                        csp_req_line_details d
                                  WHERE h.task_id             = p_task_id
                                  AND h.task_assignment_id    = r_asgn.task_assignment_id
                                  AND h.requirement_header_id = l.requirement_header_id
                                  AND l.requirement_line_id   = d.requirement_line_id
                                  MINUS
                                  SELECT l.requirement_line_id
                                  FROM csp_requirement_headers h,
                                        csp_requirement_lines l,
                                        csp_req_line_details d,
                                        oe_order_lines_all oola
                                  WHERE h.task_id             = p_task_id
                                  AND h.task_assignment_id    = r_asgn.task_assignment_id
                                  AND h.requirement_header_id = l.requirement_header_id
                                  AND l.requirement_line_id   = d.requirement_line_id
                                  AND d.source_type          = 'IO'
                                  AND d.source_id = oola.line_id
                                  AND csp_pick_utils.get_order_status(oola.line_id,oola.flow_status_code)          in ('SHIPPED', 'EXPECTED')
                                  );

                                if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                                  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                                                  'csp.plsql.CSP_SCH_INT_PVT.GET_AVAILABILITY_OPTIONS',
                                                                  'l_oth_req_line = ' || l_oth_req_line);
                                end if;

                                if l_oth_req_line > 0 then
                                        x_return_status := FND_API.G_RET_STS_ERROR;
                                        FND_MESSAGE.SET_NAME('CSP', 'CSP_SCH_NOT_CANCEL_ORDER');
                                        FND_MSG_PUB.ADD;
                                        fnd_msg_pub.count_and_get
                                                        ( p_count => x_msg_count
                                                        , p_data  => x_msg_data);
                                        return;
                                end if;

                                -- now check for non sourced lines
                                l_non_src_line := 0;
                                SELECT COUNT(requirement_line_id)
                                into l_non_src_line
                                FROM
                                  (SELECT l.requirement_line_id
                                  FROM csp_requirement_headers h,
                                        csp_requirement_lines l
                                  WHERE h.task_id             = p_task_id
                                  AND h.task_assignment_id    = r_asgn.task_assignment_id
                                  AND h.requirement_header_id = l.requirement_header_id
                                  AND (SELECT COUNT (d.requirement_line_id)
                                                                FROM csp_req_line_details d
                                                                WHERE d.requirement_line_id = l.requirement_line_id) = 0
                                  MINUS
                                  SELECT l.requirement_line_id
                                  FROM csp_requirement_headers h,
                                        csp_requirement_lines l,
                                        csp_req_line_details d,
                                        oe_order_lines_all oola
                                  WHERE h.task_id             = p_task_id
                                  AND h.task_assignment_id    = r_asgn.task_assignment_id
                                  AND h.requirement_header_id = l.requirement_header_id
                                  AND l.requirement_line_id   = d.requirement_line_id
                                  AND d.source_type          = 'IO'
                                  AND d.source_id = oola.line_id
                                  AND csp_pick_utils.get_order_status(oola.line_id,oola.flow_status_code)         in ('SHIPPED', 'EXPECTED')
                                  );

                                if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                                  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                                                  'csp.plsql.CSP_SCH_INT_PVT.GET_AVAILABILITY_OPTIONS',
                                                                  'l_non_src_line = ' || l_non_src_line);
                                end if;

                                if l_non_src_line = 0 then
                                        l_old_arrival_date := null;
                                        SELECT MAX(oel.request_date)
                                        into l_old_arrival_date
                                        FROM csp_requirement_headers h,
                                          csp_requirement_lines l,
                                          csp_req_line_details d,
                                          oe_order_lines_all oel
                                        WHERE h.task_id             = p_task_id
                                        AND h.task_assignment_id    = r_asgn.task_assignment_id
                                        AND h.requirement_header_id = l.requirement_header_id
                                        AND l.requirement_line_id   = d.requirement_line_id
                                        AND d.source_type          = 'IO'
                                        AND csp_pick_utils.get_order_status(oel.line_id,oel.flow_status_code)       in ('SHIPPED', 'EXPECTED')
                                        AND d.source_id             = oel.line_id;

                                        if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                                          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                                                          'csp.plsql.CSP_SCH_INT_PVT.GET_AVAILABILITY_OPTIONS',
                                                                          'l_old_arrival_date = ' || to_char(nvl(l_old_arrival_date, sysdate), 'dd-MON-YYYY HH24:MI'));
                                        end if;

                                        l_dest_ou := -999;
                                        SELECT ch.destination_organization_id
                                        into l_dest_ou
                                        FROM csp_requirement_headers ch
                                        WHERE ch.task_id                     = p_task_id
                                        AND ch.task_assignment_id          = r_asgn.task_assignment_id
                                        AND rownum                         = 1;

                                        x_options := CSP_SCH_INT_PVT.csp_sch_options_tbl_typ();
                                        for res_count in 1..p_resources.count loop
                                                l_rs_ou := -999;
                                                open get_rs_ou(p_resources(res_count).resource_type, p_resources(res_count).resource_id);
                                                fetch get_rs_ou into l_rs_ou;
                                                close get_rs_ou;
                                                if(l_rs_ou <> -999 and l_rs_ou = l_dest_ou) then
                                                        x_options.extend;
                                                        x_options(x_options.count).resource_id   := p_resources(res_count).resource_id;
                                                        x_options(x_options.count).resource_type := p_resources(res_count).resource_type;
                                                        x_options(x_options.count).start_time    := l_old_arrival_date;
                                                        x_options(x_options.count).transfer_cost := 0;
                                                        x_options(x_options.count).missing_parts := 0;
                                                        x_options(x_options.count).available_parts := 1;        -- not sure if required
                                                        x_options(x_options.count).src_warehouse := '';
                                                        x_options(x_options.count).ship_method := '';
                                                        x_options(x_options.count).distance_str := '';
                                                end if;
                                        end loop;
                                        return;
                                end if;
                        end if;
                end if;


        if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                          'csp.plsql.CSP_SCH_INT_PVT.GET_AVAILABILITY_OPTIONS',
                          'before making call to CLEAN_REQUIREMENT...');
        end if;

        CLEAN_REQUIREMENT(
            p_api_version_number    => 1.0,
            p_task_assignment_id    => r_asgn.task_assignment_id,
            x_return_status => x_return_status,
            x_msg_count => x_msg_count,
            x_msg_data => x_msg_data
            );

        if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                          'csp.plsql.CSP_SCH_INT_PVT.GET_AVAILABILITY_OPTIONS',
                          'after making call to CLEAN_REQUIREMENT... x_return_status = ' || x_return_status);
        end if;

         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        -- bug # 14084319
                        -- handle a case where cancellation of an order is failed
                        -- due to OM processing constraints
                        if x_return_status = 'C' then

                                if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                                  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                                                  'csp.plsql.CSP_SCH_INT_PVT.GET_AVAILABILITY_OPTIONS',
                                                                  'handle a case where cancellation of an order is failed due to OM processing constraints');
                                end if;

                                l_old_arrival_date := null;
                                SELECT MAX(oel.request_date)
                                into l_old_arrival_date
                                FROM csp_requirement_headers h,
                                  csp_requirement_lines l,
                                  csp_req_line_details d,
                                  oe_order_lines_all oel
                                WHERE h.task_id             = p_task_id
                                AND h.task_assignment_id    = r_asgn.task_assignment_id
                                AND h.requirement_header_id = l.requirement_header_id
                                AND l.requirement_line_id   = d.requirement_line_id
                                AND d.source_type          = 'IO'
                                --AND csp_pick_utils.get_order_status(oel.line_id,oel.flow_status_code)       in ('SHIPPED', 'EXPECTED')
                                AND d.source_id             = oel.line_id;

                                if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                                  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                                                  'csp.plsql.CSP_SCH_INT_PVT.GET_AVAILABILITY_OPTIONS',
                                                                  'l_old_arrival_date = ' || to_char(nvl(l_old_arrival_date, sysdate), 'dd-MON-YYYY HH24:MI'));
                                end if;

                                l_dest_ou := -999;
                                SELECT ch.destination_organization_id
                                into l_dest_ou
                                FROM csp_requirement_headers ch
                                WHERE ch.task_id                     = p_task_id
                                AND ch.task_assignment_id          = r_asgn.task_assignment_id
                                AND rownum                         = 1;

                                x_options := CSP_SCH_INT_PVT.csp_sch_options_tbl_typ();
                                for res_count in 1..p_resources.count loop
                                        l_rs_ou := -999;
                                        open get_rs_ou(p_resources(res_count).resource_type, p_resources(res_count).resource_id);
                                        fetch get_rs_ou into l_rs_ou;
                                        close get_rs_ou;
                                        if(l_rs_ou <> -999 and l_rs_ou = l_dest_ou) then
                                                x_options.extend;
                                                x_options(x_options.count).resource_id   := p_resources(res_count).resource_id;
                                                x_options(x_options.count).resource_type := p_resources(res_count).resource_type;
                                                x_options(x_options.count).start_time    := l_old_arrival_date;
                                                x_options(x_options.count).transfer_cost := 0;
                                                x_options(x_options.count).missing_parts := 0;
                                                x_options(x_options.count).available_parts := 1;        -- not sure if required
                                                x_options(x_options.count).src_warehouse := '';
                                                x_options(x_options.count).ship_method := '';
                                                x_options(x_options.count).distance_str := '';
                                        end if;
                                end loop;
                                x_return_status := FND_API.G_RET_STS_SUCCESS;
                                return;
                        end if;
            return;
         END IF;

    end loop;

    if nvl(l_search_method,'SPARES') <> 'ATP' then
      SPARES_CHECK2(
               p_resources     => p_resources,
               p_task_id       => p_task_id,
               p_need_by_date  => p_interval.latest_time,
               p_trunk         => p_trunk,
               p_warehouse     => p_warehouse,
               p_mandatory     => p_mandatory,
               x_options       => x_options,
               x_return_status => x_return_status,
               x_msg_data      => x_msg_data,
               x_msg_count     => x_msg_count);


          if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                            'csp.plsql.CSP_SCH_INT_PVT.GET_AVAILABILITY_OPTIONS',
                            'rollback to GET_AVAILABILITY_OPTIONS_SP');
          end if;

        rollback to GET_AVAILABILITY_OPTIONS_SP;

        return;
     end if;

        CSP_SCH_INT_PVT.GET_ORGANIZATION_SUBINV(p_resources, l_resource_org_subinv , x_return_status,x_msg_data,x_msg_count);

                if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                                  'csp.plsql.CSP_SCH_INT_PVT.GET_AVAILABILITY_OPTIONS',
                                                  'After CSP_SCH_INT_PVT.GET_ORGANIZATION_SUBINV... x_return_status=' || x_return_status);
                  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                                  'csp.plsql.CSP_SCH_INT_PVT.GET_AVAILABILITY_OPTIONS',
                                                  'l_resource_org_subinv.count=' || l_resource_org_subinv.count);
                end if;

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RETURN;
        END IF;

        CSP_SCH_INT_PVT.GET_PARTS_LIST(p_task_id,p_likelihood,l_parts_list,x_return_status,x_msg_data,x_msg_count);

                if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                                  'csp.plsql.CSP_SCH_INT_PVT.GET_AVAILABILITY_OPTIONS',
                                                  'After CSP_SCH_INT_PVT.GET_PARTS_LIST... x_return_status=' || x_return_status);
                  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                                  'csp.plsql.CSP_SCH_INT_PVT.GET_AVAILABILITY_OPTIONS',
                                                  'l_parts_list.count=' || l_parts_list.count);
                end if;

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RETURN;
        END IF;

        IF l_parts_list.count = 0 THEN
            x_return_status := FND_API.G_RET_STS_SUCCESS;
            for i in 1..l_parts_list.count loop
              l_total_parts := l_total_parts + l_parts_list(i).quantity;
            end loop;
            FOR I IN 1..p_resources.count LOOP
                x_options.extend;
                x_options(x_options.count).resource_id   := p_resources(I).resource_id;
                x_options(x_options.count).resource_type := p_resources(I).resource_type;
                x_options(x_options.count).start_time    := p_interval.earliest_time;
                x_options(x_options.count).transfer_cost := NULL;
                x_options(x_options.count).missing_parts := 0;
                x_options(x_options.count).available_parts := l_total_parts;
            END LOOP;
            RETURN;
        END IF;

         IF l_parts_list.count > 0 THEN
              CSP_SCH_INT_PVT.CHECK_LOCAl_INVENTORY(l_resource_org_subinv,l_parts_list,p_trunk,l_unavailable_list,l_final_available_list,x_return_status,x_msg_data,x_msg_count);

                        if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                                          'csp.plsql.CSP_SCH_INT_PVT.GET_AVAILABILITY_OPTIONS',
                                                          'After CSP_SCH_INT_PVT.CHECK_LOCAl_INVENTORY... x_return_status=' || x_return_status);
                          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                                          'csp.plsql.CSP_SCH_INT_PVT.GET_AVAILABILITY_OPTIONS',
                                                          'l_unavailable_list.count=' || l_unavailable_list.count);
                          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                                          'csp.plsql.CSP_SCH_INT_PVT.GET_AVAILABILITY_OPTIONS',
                                                          'l_final_available_list.count=' || l_final_available_list.count);
                        end if;

              IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  RETURN;
              END IF ;

            if p_trunk and not p_mandatory then
              for i in 1..p_resources.count loop
                x_options.extend;
                x_options(i).resource_id := p_resources(i).resource_id;
                x_options(i).resource_type := p_resources(i).resource_type;
                x_options(i).start_time := null;
                x_options(i).transfer_cost := 0;
                x_options(i).missing_parts := 0;
                x_options(i).available_parts := 0;
                for j in 1..l_unavailable_list.count loop
                  if p_resources(i).resource_id =
l_unavailable_list(j).resource_id and
                     p_resources(i).resource_type =
l_unavailable_list(j).resource_type then
                    x_options(i).missing_parts := x_options(i).missing_parts +
l_unavailable_list(j).quantity;
                    x_options(i).transfer_cost := -1;
                  end if;
                end loop;
                for j in 1..l_final_available_list.count loop
                  if p_resources(i).resource_id =
l_final_available_list(j).resource_id and
                     p_resources(i).resource_type =
l_final_available_list(j).resource_type then
                    x_options(i).available_parts := x_options(i).available_parts +
l_final_available_list(j).quantity;
                    x_options(i).start_time := sysdate;
                  end if;
                end loop;
              end loop;
              return;
            end if;

           if nvl(l_search_method,'SPARES') <> 'ATP' and nvl(p_warehouse,FALSE)
              and l_unavailable_list.count >= 1 then

                                if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                                  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                                                  'csp.plsql.CSP_SCH_INT_PVT.GET_AVAILABILITY_OPTIONS',
                                                                  'Before calling CSP_SCH_INT_PVT.SPARES_CHECK...');
                                end if;

              CSP_SCH_INT_PVT.SPARES_CHECK(l_unavailable_list,p_interval,l_available_list,l_final_unavailable_list,x_return_status,x_msg_data,x_msg_count);

                                if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                                  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                                                  'csp.plsql.CSP_SCH_INT_PVT.GET_AVAILABILITY_OPTIONS',
                                                                  'After CSP_SCH_INT_PVT.SPARES_CHECK... x_return_status=' || x_return_status);
                                  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                                                  'csp.plsql.CSP_SCH_INT_PVT.GET_AVAILABILITY_OPTIONS',
                                                                  'l_unavailable_list.count=' || l_unavailable_list.count);
                                  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                                                  'csp.plsql.CSP_SCH_INT_PVT.GET_AVAILABILITY_OPTIONS',
                                                                  'l_available_list.count=' || l_available_list.count);
                                  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                                                  'csp.plsql.CSP_SCH_INT_PVT.GET_AVAILABILITY_OPTIONS',
                                                                  'l_final_unavailable_list.count=' || l_final_unavailable_list.count);
                                end if;

            elsif  (l_unavailable_list.count > 0 AND (NOT l_subinv_only) AND
            (fnd_profile.value(name => 'CSP_CHECK_ATP')= 'ALWAYS' or
                      fnd_profile.value(name => 'CSP_CHECK_ATP')= 'SCHONLY' )) or
                (l_unavailable_list.count > 0 and nvl(p_warehouse,FALSE)) THEN
                CSP_SCH_INT_PVT.DO_ATP_CHECK(l_unavailable_list,p_interval,l_available_list,l_final_unavailable_list,x_return_status,x_msg_data,x_msg_count);
            ELSE
                l_final_unavailable_list := l_unavailable_list;
            END IF;

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
                RETURN;
            END IF;

             If l_available_list.count > 0 THEN
               FOR gli in get_line_id LOOP
                        FOR J IN 1..l_available_list.count LOOP
                          FOR I IN 1..p_resources.count LOOP
                            IF l_available_list(J).resource_id = p_resources(I).resource_id
                                and l_available_list(J).resource_type = p_resources(I).resource_type
                                and l_available_list(J).line_id = gli.req_line_id THEN
                                l_final_available_list.extend;
                                l_final_available_list(l_final_available_list.count) := l_available_list(J);

                                                                if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                                                                  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                                                                                  'csp.plsql.CSP_SCH_INT_PVT.GET_AVAILABILITY_OPTIONS',
                                                                                                  'Got available data... l_final_available_list.count=' || l_final_available_list.count);
                                                                end if;

                                EXIT;
                            END IF;
                        END LOOP;
                    END LOOP;
                END LOOP;
             END IF;

            CSP_SCH_INT_PVT.ELIGIBLE_RESOURCES(p_resources,l_final_available_list,l_final_unavailable_list,l_eligible_resources_list,x_return_status,x_msg_data,x_msg_count);

                        if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                                          'csp.plsql.CSP_SCH_INT_PVT.GET_AVAILABILITY_OPTIONS',
                                                          'After CSP_SCH_INT_PVT.ELIGIBLE_RESOURCES... x_return_status=' || x_return_status);
                          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                                          'csp.plsql.CSP_SCH_INT_PVT.GET_AVAILABILITY_OPTIONS',
                                                          'l_eligible_resources_list.count=' || l_eligible_resources_list.count);
                        end if;

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
                RETURN;
            END IF;

            IF l_eligible_resources_list.count > 0 THEN

                           CSP_SCH_INT_PVT.GET_TIME_COST(l_eligible_resources_list,x_options,x_return_status,x_msg_data,x_msg_count);

                                if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                                  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                                                  'csp.plsql.CSP_SCH_INT_PVT.GET_AVAILABILITY_OPTIONS',
                                                                  'After CSP_SCH_INT_PVT.GET_TIME_COST... x_return_status=' || x_return_status);
                                  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                                                  'csp.plsql.CSP_SCH_INT_PVT.GET_AVAILABILITY_OPTIONS',
                                                                  'l_eligible_resources_list.count=' || l_eligible_resources_list.count);
                                  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                                                  'csp.plsql.CSP_SCH_INT_PVT.GET_AVAILABILITY_OPTIONS',
                                                                  'x_options.count=' || x_options.count);
                                end if;

                           IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
                    RETURN;
                /*ELSE
                    IF x_options.count = 0 THEN
                        x_return_status := FND_API.G_RET_STS_ERROR;
                        l_del_date := to_char(g_earliest_delivery_date,'MM-DD-YYYY HH24:MI:SS');
                        FND_MESSAGE.SET_NAME('CSP', 'CSP_SCH_DEL');
                        FND_MESSAGE.SET_TOKEN('DDATE', l_del_date, TRUE);
                        FND_MSG_PUB.ADD;
                        fnd_msg_pub.count_and_get
                         ( p_count => x_msg_count
                         , p_data  => x_msg_data);
                    END IF;*/
                END IF;
            ELSE
                x_return_status := FND_API.G_RET_STS_ERROR;
                FND_MESSAGE.SET_NAME('CSP', 'CSP_SCH_NO_PARTS');
                FND_MSG_PUB.ADD;
                fnd_msg_pub.count_and_get
                    ( p_count => x_msg_count
                    , p_data  => x_msg_data);
            END IF;
       ELSE
            FOR I IN 1..p_resources.count LOOP
                x_options.extend;
                x_options(x_options.count).resource_id   := p_resources(I).resource_id;
                x_options(x_options.count).resource_type := p_resources(I).resource_type;
                x_options(x_options.count).start_time    := p_interval.earliest_time;
                x_options(x_options.count).transfer_cost := 0;
                x_options(x_options.count).missing_parts := 0;
                x_options(x_options.count).available_parts := 0;
            END LOOP;
        END IF;
        EXCEPTION
        WHEN OTHERS THEN
            FND_MESSAGE.SET_NAME('CSP', 'CSP_UNEXPECTED_EXEC_ERRORS');
            FND_MESSAGE.SET_TOKEN('ROUTINE', l_api_name, FALSE);
            FND_MESSAGE.SET_TOKEN('SQLERRM', sqlerrm, FALSE);
            FND_MSG_PUB.ADD;
            fnd_msg_pub.count_and_get
              ( p_count => x_msg_count
              , p_data  => x_msg_data);
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            return;
   END GET_AVAILABILITY_OPTIONS;

   PROCEDURE CHOOSE_OPTION(p_api_version_number IN  NUMBER
                          ,p_task_id            IN  NUMBER
                          ,p_task_assignment_id IN  NUMBER
                          ,p_likelihood         IN  NUMBER
                          ,p_mandatory          IN  BOOLEAN
                          ,p_trunk              IN  BOOLEAN
                          ,p_warehouse          IN  BOOLEAN
                          ,p_options            IN  CSP_SCH_INT_PVT.csp_sch_options_rec_typ
                          ,x_return_status      OUT NOCOPY VARCHAR2
                          ,x_msg_data           OUT NOCOPY VARCHAR2
                          ,x_msg_count          OUT NOCOPY NUMBER) IS

          CURSOR C2  IS
        SELECT crh.REQUIREMENT_HEADER_ID,crh.address_type
        FROM   CSP_REQUIREMENT_HEADERS crh
        WHERE  crh.TASK_ID = p_task_id;

        cursor  c_accepted_flag is
        select  nvl(jtsv.accepted_flag,'N')
        from    jtf_task_statuses_vl jtsv,
                jtf_task_assignments jta
        where   jta.task_assignment_id = p_task_assignment_id
        and     jtsv.task_status_id = jta.assignment_status_id;

        CURSOR  csp_resource_org(c_resource_id number, c_resource_type varchar2) IS
        SELECT  ORGANIZATION_ID, SUBINVENTORY_CODE
        FROM    CSP_INV_LOC_ASSIGNMENTS
        WHERE   RESOURCE_ID = c_resource_id
        AND     RESOURCE_TYPE = c_resource_type
        AND     DEFAULT_CODE = 'IN' ;

        CURSOR  csp_ship_to_location(c_resource_id number, c_resource_type varchar2) IS
        SELECT  SHIP_TO_LOCATION_ID
        FROM    CSP_RS_SHIP_TO_ADDRESSES_ALL_V
        WHERE   RESOURCE_ID = c_resource_id
        AND     RESOURCE_TYPE = c_resource_type
        AND     PRIMARY_FLAG = 'Y'
        AND     status        = 'A'
        AND     rownum        = 1;

        cursor c_scheduled_start is
        select scheduled_start_date
        from   jtf_tasks_b
        where  task_id = p_task_id;

        cursor c_available_parts(p_task_id number) is
        select distinct capt.supplied_item_id,
               capt.supplied_quantity,
               msib.primary_uom_code,
               capt.supplied_item_rev,
               capt.organization_id,
               capt.subinventory_code,
               capt.source_type_code,
               capt.shipping_method,
               ood.operating_unit,
               crl.requirement_line_id,
               crh.destination_organization_id,
               crh.destination_subinventory,
               crh.ship_to_location_id
        from   csp_available_parts_temp capt,
               org_organization_definitions ood,
               csp_requirement_lines crl,
               csp_requirement_headers crh,
               mtl_system_items_b msib
        where  ood.organization_id = capt.organization_id
        and    crl.requirement_header_id = crh.requirement_header_id
        and    crl.inventory_item_id = capt.required_item_id
        and    msib.organization_id = capt.organization_id
        and    msib.inventory_item_id = capt.supplied_item_id
        and    crh.task_id = p_task_id
        order by ood.operating_unit;

        l_interval                CSP_SCH_INT_PVT.csp_sch_interval_rec_typ;
        l_resources               CSP_SCH_INT_PVT.csp_sch_resource_tbl_typ;
        l_resource_org_subinv     CSP_SCH_INT_PVT.CSP_RESOURCE_ORG_tbl_TYP;
        l_parts_list              CSP_SCH_INT_PVT.CSP_PARTS_TBL_TYP1 ;
        l_unavailable_list        CSP_SCH_INT_PVT.CSP_UNAVAILABILITY_TBL_TYPE ;
        l_available_list          CSP_SCH_INT_PVT.CSP_AVAILABILITY_TBL_TYPE ;
        l_eligible_resources_list CSP_SCH_INT_PVT.CSP_AVAILABILITY_TBL_TYPE ;
        l_final_unavailable_list  CSP_SCH_INT_PVT.CSP_UNAVAILABILITY_TBL_TYPE ;
        l_options                 CSP_SCH_INT_PVT.CSP_SHIP_PARAMETERS_TBL_TYPE;
        l_ship_count              CSP_SCH_INT_PVT.CSP_SHIP_METHOD_COUNT_TBL_TYP;
        l_return_status           VARCHAR2(128);
        l_temp_options            CSP_SCH_INT_PVT.CSP_SHIP_PARAMETERS_TBL_TYPE ;
        min_cost                  NUMBER ;
        l_final_option            CSP_SCH_INT_PVT.CSP_SHIP_PARAMETERS_TBL_TYPE ;
        l_reservation_parts       CSP_SCH_INT_PVT.RESERVATION_REC_TYP;
        l_org_ship_methode        org_ship_methodes_tbl_type ;
       -- l_Requirement_Line_Tbl    CSP_Requirement_Lines_PVT.Requirement_Line_Tbl_Type;
        l_res_ship_parameters     CSP_SCH_INT_PVT.CSP_ORGS_SHIP_PARAM_TBL_TYPE;
        l_requirement_header      CSP_Requirement_Headers_PVT.REQUIREMENT_HEADER_Rec_Type;
        l_parts_header             csp_parts_requirement.Header_rec_type;
        l_parts_lines              csp_parts_requirement.Line_Tbl_type;
        l_revision                varchar2(3);
        l_ship_set                varchar2(3);
        g_arrival_date            DATE;
        current_position          NUMBER;
        previous_position         NUMBER;
        str_length                NUMBER;
        l_reservation_id          NUMBER;
        l_requirements_line_id    NUMBER;
        req_loop                  NUMBER := 1;
        l_requirement_header_id   NUMBER;
        l_api_name                varchar2(60) := 'CSP_SCH_INT_PVT.CHOOSE_OPTION';
        l_msg varchar2(2000);
        rec_count                 NUMBER := 1;
        l_destination_sub_inv     varchar2(30) := null;
        l_destination_org_id      NUMBER := null;
        l_ship_to_location_id     NUMBER;
        l_ship_methode_count      NUMBER;
        l_temp_line_id            NUMBER;
        l_final_available_list    CSP_SCH_INT_PVT.CSP_AVAILABILITY_TBL_TYPE ;
        l_req_line_details_tbl    CSP_SCH_INT_PVT.csp_req_line_details_tabl_typ;
        l_address_type            varchar2(3);
        --hehxxx
        l_search_method           varchar2(30) := fnd_profile.value('CSP_PART_SEARCH_METHOD_SCHEDULER');
        x_options                 CSP_SCH_INT_PVT.csp_sch_options_tbl_typ;
        l_req_line_details_id     number := null;
        l_old_operating_unit      number := null;
        l_book_order              varchar2(30) := fnd_profile.value('CSP_INIT_IO_STATUS');
        l_need_by_date            date := null;

        cursor get_asgn_id is
        select task_assignment_id
        from jtf_task_assignments
        where task_id = p_task_id;

        l_task_asgn_id number;
                l_fl_rcvd_lines number;
                l_shpd_lines number;

                cursor c_parts_req (v_task_id number, v_task_assignment_id number) is
                select requirement_header_id
                from csp_requirement_headers
                where task_id = v_task_id
                and task_assignment_id = v_task_assignment_id;

                l_resource_name varchar2(200);
                l_resource_type_name varchar2(100);
   BEGIN
        savepoint choose_options;

        log('choose_option','Begin...');

                open  csp_resource_org(p_options.resource_id, p_options.resource_type);
                fetch csp_resource_org into l_destination_org_id, l_destination_sub_inv;
                close csp_resource_org;

                log('choose_option', 'l_destination_org_id=' || l_destination_org_id);
                log('choose_option', 'l_destination_sub_inv=' || l_destination_sub_inv);

                if l_destination_org_id is null or l_destination_sub_inv is null then
                        SELECT NAME
                        INTO l_resource_type_name
                        FROM JTF_OBJECTS_VL
                        WHERE OBJECT_CODE = p_options.resource_type;
                        l_resource_name := csp_pick_utils.get_object_name(p_options.resource_type, p_options.resource_id);
                        FND_MESSAGE.SET_NAME('CSP', 'CSP_SCH_DEFAULT_SUBINV');
                        FND_MESSAGE.SET_TOKEN('RESOURCE_TYPE',l_resource_type_name, FALSE);
                        FND_MESSAGE.SET_TOKEN('RESOURCE_NAME',l_resource_name, FALSE);
                        FND_MSG_PUB.ADD;
                        fnd_msg_pub.count_and_get( p_count => x_msg_count
                                                                         , p_data  => x_msg_data);
                        x_return_status := FND_API.G_RET_STS_ERROR;
                        return;
                end if;

        for r_asgn in get_asgn_id loop
            l_task_asgn_id := r_asgn.task_assignment_id;

                        -- case 1: if the part is already received at task/customer address
                        -- first find out all RES created after receiving
                        -- read item, qty and src org/subinv information from the RES
                        -- release the RES
                        -- do part transfer using direct inter-org transfer or subinv transfer
                        -- create a new reservation for new destination org/subinv
                        -- link the RES to req_line

                        l_fl_rcvd_lines := 0;
                        SELECT COUNT(l.requirement_line_id)
                        into l_fl_rcvd_lines
                        FROM csp_requirement_headers h,
                          csp_requirement_lines l,
                          csp_req_line_details dio,
                          csp_req_line_details dres,
                          oe_order_lines_all oola,
                          mtl_reservations mr
                        WHERE h.task_id             = p_task_id
                        AND h.task_assignment_id    = r_asgn.task_assignment_id
                        AND h.address_type         IN ('T', 'C', 'P')
                        AND h.requirement_header_id = l.requirement_header_id
                        AND l.requirement_line_id   = dio.requirement_line_id
                        AND dio.source_type        = 'IO'
                        AND dio.source_id = oola.line_id
                        AND  csp_pick_utils.get_order_status(oola.line_id,oola.flow_status_code)      = 'FULLY RECEIVED'
                        AND dio.requirement_line_id = dres.requirement_line_id
                        AND oola.inventory_item_id    = mr.inventory_item_id
                        AND oola.ordered_quantity   = mr.reservation_quantity
                        AND dres.source_type       = 'RES'
                        AND dres.source_id = mr.reservation_id;

                        log('choose_option', 'l_fl_rcvd_lines=' || l_fl_rcvd_lines);

                        if l_fl_rcvd_lines > 0 then
                                log('choose_option', 'before calling move_parts_on_reassign...');
                                move_parts_on_reassign(
                                        p_task_id => p_task_id,
                                        p_task_asgn_id => r_asgn.task_assignment_id,
                                        p_new_task_asgn_id => p_task_assignment_id,
                                        p_new_need_by_date => p_options.start_time,
                                        p_new_resource_id => p_options.resource_id,
                                        p_new_resource_type => p_options.resource_type,
                                        x_return_status => x_return_status,
                                        x_msg_count => x_msg_count,
                                        x_msg_data => x_msg_data
                                );
                                log('choose_option', 'after calling move_parts_on_reassign...x_return_status=' || x_return_status);
                                if x_return_status <> FND_API.G_RET_STS_SUCCESS then
                                        x_return_status := FND_API.G_RET_STS_ERROR;
                                        FND_MESSAGE.SET_NAME('CSP', 'CSP_SCH_NOT_CANCEL_ORDER');
                                        FND_MSG_PUB.ADD;
                                        fnd_msg_pub.count_and_get
                                                        ( p_count => x_msg_count
                                                        , p_data  => x_msg_data);
                                end if;
                                return;
                        end if;

                        -- case 2: Part is already shipped and we cannot cancel the internal order
                        -- if the task type is Task or Customer, we should allow reassignment with same
                        -- inventory org and let second resource receive it
                        l_shpd_lines := 0;
                        SELECT COUNT(l.requirement_line_id)
                        into l_shpd_lines
                        FROM csp_requirement_headers h,
                          csp_requirement_lines l,
                          csp_req_line_details d,
                          oe_order_lines_all oola
                        WHERE h.task_id             = p_task_id
                        AND h.task_assignment_id    = r_asgn.task_assignment_id
                        AND h.requirement_header_id = l.requirement_header_id
                        and h.address_type in ('C', 'T', 'P')
                        AND l.requirement_line_id   = d.requirement_line_id
                        AND d.source_type          = 'IO'
                        AND d.source_id = oola.line_id
                        AND csp_pick_utils.get_order_status(oola.line_id,oola.flow_status_code)        in ('SHIPPED', 'EXPECTED');

                        log('choose_option', 'l_shpd_lines=' || l_shpd_lines);

                        if l_shpd_lines > 0 then
                                for cr in c_parts_req(p_task_id, r_asgn.task_assignment_id)
                                loop
                                        l_requirement_header := CSP_Requirement_headers_PVT.G_MISS_REQUIREMENT_HEADER_REC;
                                        l_requirement_header.requirement_header_id := cr.requirement_header_id;
                                        l_requirement_header.need_by_date := p_options.start_time;
                                        l_requirement_header.task_assignment_id := p_task_assignment_id ;
                                        l_requirement_header.last_update_date := sysdate;
                                        l_requirement_header.destination_organization_id := l_destination_org_id;
                                        l_requirement_header.destination_subinventory := l_destination_sub_inv;
                                        l_requirement_header.resource_type := p_options.resource_type;
                                        l_requirement_header.resource_id := p_options.resource_id;

                                        log('choose_option','task_assignment_id:'||l_requirement_header.task_assignment_id);
                                        log('choose_option','dest_organization_id:'||l_requirement_header.destination_organization_id);
                                        log('choose_option','dest_subinventory:'||l_requirement_header.destination_subinventory);
                                        log('choose_option','resource_type:'||l_requirement_header.resource_type);
                                        log('choose_option','resource_id:'||l_requirement_header.resource_id);
                                        log('choose_option','start_time:'||to_char(l_requirement_header.need_by_date,'dd-mon-yyyy hh24:mi:ss'));

                                        log('choose_option', 'before calling Update_requirement_headers...');
                                        CSP_Requirement_Headers_PVT.Update_requirement_headers(
                                                                        P_Api_Version_Number         => 1.0,
                                                                        P_Init_Msg_List              => FND_API.G_FALSE,
                                                                        P_Commit                     => FND_API.G_FALSE,
                                                                        p_validation_level           => FND_API.G_VALID_LEVEL_FULL,
                                                                        P_REQUIREMENT_HEADER_Rec     => l_requirement_header,
                                                                        X_Return_Status              => x_return_status,
                                                                        X_Msg_Count                  => x_msg_count,
                                                                        x_msg_data                   => x_msg_data
                                                                        );
                                        log('choose_option', 'before calling Update_requirement_headers...x_return_status=' || x_return_status);

                                        if x_return_status <> FND_API.G_RET_STS_SUCCESS then
                                                x_return_status := FND_API.G_RET_STS_ERROR;
                                                FND_MESSAGE.SET_NAME('CSP', 'CSP_SCH_NOT_CANCEL_ORDER');
                                                FND_MSG_PUB.ADD;
                                                fnd_msg_pub.count_and_get
                                                                ( p_count => x_msg_count
                                                                , p_data  => x_msg_data);
                                                return;
                                        end if;
                                end loop;
                                return;
                        end if;


            log('choose_option','l_task_asgn_id = ' || l_task_asgn_id);
            log('choose_option','before making call to CLEAN_REQUIREMENT...');

            CLEAN_REQUIREMENT(
                p_api_version_number    => 1.0,
                p_task_assignment_id    => l_task_asgn_id,
                x_return_status => x_return_status,
                x_msg_count => x_msg_count,
                x_msg_data => x_msg_data
                );

            log('choose_option', 'after making call to CLEAN_REQUIREMENT... x_return_status = ' || x_return_status);

             IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                if x_return_status = 'C' then
                                        for cr in c_parts_req(p_task_id, r_asgn.task_assignment_id)
                                        loop
                                                l_requirement_header := CSP_Requirement_headers_PVT.G_MISS_REQUIREMENT_HEADER_REC;
                                                l_requirement_header.requirement_header_id := cr.requirement_header_id;
                                                l_requirement_header.need_by_date := p_options.start_time;
                                                l_requirement_header.task_assignment_id := p_task_assignment_id ;
                                                l_requirement_header.last_update_date := sysdate;
                                                l_requirement_header.destination_organization_id := l_destination_org_id;
                                                l_requirement_header.destination_subinventory := l_destination_sub_inv;
                                                l_requirement_header.resource_type := p_options.resource_type;
                                                l_requirement_header.resource_id := p_options.resource_id;

                                                log('choose_option','task_assignment_id:'||l_requirement_header.task_assignment_id);
                                                log('choose_option','dest_organization_id:'||l_requirement_header.destination_organization_id);
                                                log('choose_option','dest_subinventory:'||l_requirement_header.destination_subinventory);
                                                log('choose_option','resource_type:'||l_requirement_header.resource_type);
                                                log('choose_option','resource_id:'||l_requirement_header.resource_id);
                                                log('choose_option','start_time:'||to_char(l_requirement_header.need_by_date,'dd-mon-yyyy hh24:mi:ss'));

                                                log('choose_option', 'before calling Update_requirement_headers...');
                                                CSP_Requirement_Headers_PVT.Update_requirement_headers(
                                                                                P_Api_Version_Number         => 1.0,
                                                                                P_Init_Msg_List              => FND_API.G_FALSE,
                                                                                P_Commit                     => FND_API.G_FALSE,
                                                                                p_validation_level           => FND_API.G_VALID_LEVEL_FULL,
                                                                                P_REQUIREMENT_HEADER_Rec     => l_requirement_header,
                                                                                X_Return_Status              => x_return_status,
                                                                                X_Msg_Count                  => x_msg_count,
                                                                                x_msg_data                   => x_msg_data
                                                                                );
                                                log('choose_option', 'before calling Update_requirement_headers...x_return_status=' || x_return_status);

                                                if x_return_status <> FND_API.G_RET_STS_SUCCESS then
                                                        x_return_status := FND_API.G_RET_STS_ERROR;
                                                        FND_MESSAGE.SET_NAME('CSP', 'CSP_SCH_NOT_CANCEL_ORDER');
                                                        FND_MSG_PUB.ADD;
                                                        fnd_msg_pub.count_and_get
                                                                        ( p_count => x_msg_count
                                                                        , p_data  => x_msg_data);
                                                        return;
                                                end if;
                                        end loop;
                                        x_return_status := FND_API.G_RET_STS_SUCCESS;
                                        return;
                                end if;
                return;
             END IF;

        end loop;

        x_return_status           := FND_API.G_RET_STS_SUCCESS ;
        l_resources               := CSP_SCH_INT_PVT.csp_sch_resource_tbl_typ();
         l_resource_org_subinv    := CSP_SCH_INT_PVT.CSP_RESOURCE_ORG_tbl_TYP();
        --l_parts_list              := CSP_SCH_INT_PVT.CSP_PARTS_TBL_TYPE();
        l_unavailable_list        := CSP_SCH_INT_PVT.CSP_UNAVAILABILITY_TBL_TYPE();
        l_available_list          := CSP_SCH_INT_PVT.CSP_AVAILABILITY_TBL_TYPE ();
        l_eligible_resources_list := CSP_SCH_INT_PVT.CSP_AVAILABILITY_TBL_TYPE() ;
        l_final_unavailable_list  := CSP_SCH_INT_PVT.CSP_UNAVAILABILITY_TBL_TYPE();
        l_resources               := CSP_SCH_INT_PVT.csp_sch_resource_tbl_typ();
        l_options                 := CSP_SCH_INT_PVT.CSP_SHIP_PARAMETERS_TBL_TYPE();
        l_ship_count              := CSP_SCH_INT_PVT.CSP_SHIP_METHOD_COUNT_TBL_TYP();
        l_temp_options            := CSP_SCH_INT_PVT.CSP_SHIP_PARAMETERS_TBL_TYPE() ;
        l_final_option            := CSP_SCH_INT_PVT.CSP_SHIP_PARAMETERS_TBL_TYPE() ;
        l_res_ship_parameters     := CSP_SCH_INT_PVT.CSP_ORGS_SHIP_PARAM_TBL_TYPE();
        l_org_ship_methode        := org_ship_methodes_tbl_type();
        l_req_line_details_tbl    := CSP_SCH_INT_PVT.csp_req_line_details_tabl_typ();

        l_resources.extend;
        l_resources(1).resource_id   := p_options.resource_id ;
        l_resources(1).resource_type := p_options.resource_type ;
       -- l_interval.earliest_time     :=
        l_interval.latest_time       := p_options.start_time;


        if nvl(l_search_method,'SPARES') <> 'ATP' then
          if nvl(l_book_order,'B') = 'E' then
            l_book_order := 'N';
            -- if task assignment is accepted, create order in booked status
            open  c_accepted_flag;
            fetch c_accepted_flag into l_book_order;
            close c_accepted_flag;
          else
            l_book_order := 'Y';
          end if;
          open  c_scheduled_start;
          fetch c_scheduled_start into l_need_by_date;
          close c_scheduled_start;
          x_options := CSP_SCH_INT_PVT.csp_sch_options_tbl_typ();
          SPARES_CHECK2(
               p_resources     => l_resources,
               p_task_id       => p_task_id,
               p_need_by_date  => p_options.start_time+1/144,
               p_trunk         => p_trunk,
               p_warehouse     => p_warehouse,
               p_mandatory     => p_mandatory,
               x_options       => x_options,
               x_return_status => x_return_status,
               x_msg_data      => x_msg_data,
               x_msg_count     => x_msg_count);


                        if(x_options.count = 0) then
                                x_return_status := FND_API.G_RET_STS_ERROR;
                                FND_MESSAGE.SET_NAME('CSP', 'CSP_SCH_OPTION_NOT_VALIED');
                                FND_MSG_PUB.ADD;
                                fnd_msg_pub.count_and_get
                                  ( p_count => x_msg_count
                                  , p_data  => x_msg_data);
                                  return;
                        end if;

          log('choose_option','x_options(1).transfer_cost'||x_options(1).transfer_cost);
          log('choose_option','p_options.transfer_cost'||p_options.transfer_cost);
          log('choose_option','x_options(1).start_time'||to_char(x_options(1).start_time,'dd-mon-yyyy hh24:mi:ss'));
          log('choose_option','p_options.start_time'||to_char(p_options.start_time+1/144,'dd-mon-yyyy hh24:mi:ss'));



          if x_options(1).transfer_cost <= p_options.transfer_cost and
            x_options(1).start_time <= p_options.start_time+1/144 then
            -- Loop csp_available_parts_temp
            for cap in c_available_parts(p_task_id) loop
                l_ship_to_location_id := cap.ship_to_location_id;

                log('choose_option','l_destination_org_id:'||l_destination_org_id);
                log('choose_option','cap.destination_organization_id:'||cap.destination_organization_id);
                log('choose_option','cap.destination_subinventory:'||cap.destination_subinventory);
                log('choose_option','l_ship_to_location_id:'||l_ship_to_location_id);

                if l_destination_org_id is null and cap.destination_organization_id is null then
                  open  csp_resource_org(l_resources(1).resource_id, l_resources(1).resource_type);
                  fetch csp_resource_org into l_destination_org_id, l_destination_sub_inv;
                  close csp_resource_org;
                elsif cap.destination_organization_id is not null then
                  l_destination_org_id := cap.destination_organization_id;
                  l_destination_sub_inv := cap.destination_subinventory;
                end if;

                if l_ship_to_location_id is null then
                  open csp_ship_to_location(l_resources(1).resource_id, l_resources(1).resource_type);
                  fetch csp_ship_to_location into l_ship_to_location_id;
                  close csp_ship_to_location;
                  log('choose_option','l_ship_to_location_id:'||l_ship_to_location_id);
                end if;

              if cap.source_type_code in ('MYSELF','DEDICATED') then
                log('choose_option','Create Reservation');
                l_reservation_id := NULL;
                l_reservation_parts.need_by_date       := sysdate;
                l_reservation_parts.organization_id    := cap.organization_id;
                l_reservation_parts.item_id            := cap.supplied_item_id;
                l_reservation_parts.item_uom_code      := cap.primary_uom_code;
                l_reservation_parts.quantity_needed    := cap.supplied_quantity;
                l_reservation_parts.sub_inventory_code := cap.subinventory_code;
                l_reservation_parts.line_id            := cap.requirement_line_id;
                l_reservation_parts.revision           := cap.supplied_item_rev;
                l_reservation_id := CSP_SCH_INT_PVT.CREATE_RESERVATION(l_reservation_parts,x_return_status,x_msg_data);
                if x_return_status = FND_API.G_RET_STS_SUCCESS then
                  l_req_line_details_id := null;
                  csp_req_line_details_pkg.insert_row(
                       l_req_line_details_id
                      ,cap.requirement_line_id
                      ,fnd_global.user_id
                      ,sysdate
                      ,fnd_global.user_id
                      ,sysdate
                      ,fnd_global.login_id
                      ,'RES'
                      ,l_reservation_id);
                else
                    log('choose_option','Reservation Creation failed');
                    ROLLBACK TO CHOOSE_OPTIONS;
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    return;
                end if;
                log('choose_option','Reservation_id:'||l_reservation_id);
              else
                if cap.operating_unit <> nvl(l_old_operating_unit,cap.operating_unit) then
                  CSP_PARTS_ORDER.process_order(
                      p_api_version   =>  1.0
                      ,p_Init_Msg_List =>  FND_API.G_FALSE
                      ,p_commit        =>  FND_API.G_FALSE
                      ,p_book_order    =>  l_book_order
                      ,px_header_rec   =>  l_parts_header
                      ,px_line_table   =>  l_parts_lines
                      ,x_return_status =>  x_return_status
                      ,x_msg_count     =>  x_msg_count
                      ,x_msg_data      =>  x_msg_data
                      );
                  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    log('choose_option','Order Creation failed');
                    ROLLBACK TO CHOOSE_OPTIONS;
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    FND_MESSAGE.SET_NAME('CSP', 'CSP_SCH_UNABLE_TO_ORDER');
                    FND_MSG_PUB.ADD;
                    fnd_msg_pub.count_and_get
                            ( p_count => x_msg_count
                            , p_data  => x_msg_data);
                    return;
                  end if;
                  for i in 1..l_parts_lines.count loop
                    l_req_line_details_id := null;
                    csp_req_line_details_pkg.insert_row(
                       l_req_line_details_id
                      ,l_parts_lines(i).requirement_line_id
                      ,fnd_global.user_id
                      ,sysdate
                      ,fnd_global.user_id
                      ,sysdate
                      ,fnd_global.login_id
                      ,'IO'
                      ,l_parts_lines(i).order_line_id);
                  end loop;
                  l_parts_lines.delete;
                  rec_count := 1;
                end if;
                IF rec_count = 1 then
                  log('choose_option','Setting order header.');
                  open  c2;
                  fetch c2 into l_requirement_header_id,l_address_type;
                  close c2;
                  l_parts_header.requirement_header_id := l_requirement_header_id;
                  l_parts_header.ORDER_TYPE_ID := FND_PROFILE.value(name => 'CSP_ORDER_TYPE');
                  l_parts_header.SHIP_TO_LOCATION_ID :=  l_ship_to_location_id;
                  l_parts_header.DEST_ORGANIZATION_ID := l_destination_org_id;
                  l_parts_header.dest_subinventory := l_destination_sub_inv;
                  l_parts_header.operation := 'CREATE';
                  l_parts_header.need_by_date := nvl(l_need_by_date,p_options.start_time);
                end if;

                l_parts_lines(rec_count).inventory_item_id       := cap.supplied_item_id;
                l_parts_lines(rec_count).line_num                := rec_count;
                l_parts_lines(rec_count).revision                := null; --cap.supplied_item_rev;
                l_parts_lines(rec_count).quantity                :=  NULL;
                l_parts_lines(rec_count).unit_of_measure         := cap.primary_uom_code;
                --l_parts_lines(l_parts_lines.count).dest_subinventory       := cap.destination_subinventory;
                l_parts_lines(rec_count).source_organization_id  := cap.organization_id;
                l_parts_lines(rec_count).source_subinventory     := cap.subinventory_code;
                l_parts_lines(rec_count).ship_complete           := null;
                l_parts_lines(rec_count).shipping_method_code    := cap.shipping_method;
                --l_parts_lines(l_parts_lines.count).likelihood              :=  NULL;
                l_parts_lines(rec_count).ordered_quantity        := cap.supplied_quantity;
                --l_parts_lines(l_parts_lines.count).reservation_id          := null;
                l_parts_lines(rec_count).requirement_line_id     := cap.requirement_line_id;
                l_parts_lines(rec_count).arrival_date := least(x_options(1).start_time, nvl(l_need_by_date,p_options.start_time));
                l_old_operating_unit := cap.operating_unit;
                rec_count := rec_count + 1;
              end if;
            end loop;

            log('choose_option','outside loop, rec_count:'||rec_count);
            if rec_count > 1 then
              log('choose_option','Creating last order');
              CSP_PARTS_ORDER.process_order(
                p_api_version   =>  1.0
                ,p_Init_Msg_List =>  FND_API.G_FALSE
                ,p_commit        =>  FND_API.G_FALSE
                ,p_book_order    =>  l_book_order
                ,px_header_rec   =>  l_parts_header
                ,px_line_table   =>  l_parts_lines
                ,x_return_status =>  x_return_status
                ,x_msg_count     =>  x_msg_count
                ,x_msg_data      =>  x_msg_data
                );
              IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                log('choose_option','Order Creation failed');
                ROLLBACK TO CHOOSE_OPTIONS;
                x_return_status := FND_API.G_RET_STS_ERROR;
                FND_MESSAGE.SET_NAME('CSP', 'CSP_SCH_UNABLE_TO_ORDER');
                FND_MSG_PUB.ADD;
                fnd_msg_pub.count_and_get
                  ( p_count => x_msg_count
                  , p_data  => x_msg_data);
                return;
              end if;
              for i in 1..l_parts_lines.count loop
                log('choose_option','Creating requirement line details');
                l_req_line_details_id := null;
                csp_req_line_details_pkg.insert_row(
                   l_req_line_details_id
                  ,l_parts_lines(i).requirement_line_id
                  ,fnd_global.user_id
                  ,sysdate
                  ,fnd_global.user_id
                  ,sysdate
                  ,fnd_global.login_id
                  ,'IO'
                  ,l_parts_lines(i).order_line_id);
              end loop;
            end if;


             l_requirement_header.need_by_date := nvl(l_need_by_date,p_options.start_time);

             l_requirement_header.task_assignment_id    := p_task_assignment_id ;
             l_requirement_header.last_update_date      := sysdate;
             l_requirement_header.destination_organization_id := l_destination_org_id;
                               l_requirement_header.destination_subinventory := l_destination_sub_inv;
             --l_requirement_header.need_by_date := p_options.start_time;
             l_requirement_header.resource_type := p_options.resource_type;
             l_requirement_header.resource_id := p_options.resource_id;
             log('choose_option','task_assignment_id:'||l_requirement_header.task_assignment_id);
             log('choose_option','dest_organization_id:'||l_requirement_header.destination_organization_id);
             log('choose_option','dest_subinventory:'||l_requirement_header.destination_subinventory);
             log('choose_option','resource_type:'||l_requirement_header.resource_type);
             log('choose_option','resource_id:'||l_requirement_header.resource_id);
             log('choose_option','start_time:'||to_char(l_requirement_header.need_by_date,'dd-mon-yyyy hh24:mi:ss'));
             open  c2;
             fetch c2 into l_requirement_header_id,l_address_type;
             close c2;
             l_requirement_header.requirement_header_id := l_requirement_header_id;
             l_address_type := l_address_type;
             if l_address_type is null or l_address_type = 'R' or l_address_type = 'S' then
               if l_ship_to_location_id is not null then
                 l_requirement_header.address_type          := 'R';
                 l_requirement_header.ship_to_location_id   := l_ship_to_location_id;
                                 l_requirement_header.SHIP_TO_CONTACT_ID := null;
               end if;
             end if;
             CSP_Requirement_Headers_PVT.Update_requirement_headers(
                                P_Api_Version_Number         => 1.0,
                                P_Init_Msg_List              => FND_API.G_FALSE,
                                P_Commit                     => FND_API.G_FALSE,
                                p_validation_level           => FND_API.G_VALID_LEVEL_FULL,
                                P_REQUIREMENT_HEADER_Rec     => l_requirement_header,
                                X_Return_Status              => x_return_status,
                                X_Msg_Count                  => x_msg_count,
                                x_msg_data                   => x_msg_data
                                );

          else
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.SET_NAME('CSP', 'CSP_SCH_OPTION_NOT_VALIED');
            FND_MSG_PUB.ADD;
            fnd_msg_pub.count_and_get
              ( p_count => x_msg_count
              , p_data  => x_msg_data);
              return;
          end if;

          log('choose_option','Return');
          return;
        end if;
        log('choose_option','get_organization_subinv');
        CSP_SCH_INT_PVT.GET_ORGANIZATION_SUBINV(l_resources, l_resource_org_subinv , x_return_status,x_msg_data,x_msg_count);
        IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
            RETURN;
        END IF;
        CSP_SCH_INT_PVT.GET_PARTS_LIST(p_task_id,p_likelihood,l_parts_list,x_return_status,x_msg_data,x_msg_count);
        IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
            RETURN;
        END IF;
        IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
            CSP_SCH_INT_PVT.CHECK_LOCAL_INVENTORY(l_resource_org_subinv,l_parts_list,p_trunk,l_unavailable_list,l_final_available_list,x_return_status,x_msg_data,x_msg_count);
        ELSE
            return;
        END IF;
--hehxxxx
        if nvl(l_search_method,'SPARES') <> 'ATP' and nvl(p_warehouse,FALSE)
           and l_unavailable_list.count >= 1 then
              CSP_SCH_INT_PVT.SPARES_CHECK(l_unavailable_list,l_interval,l_available_list,l_final_unavailable_list,x_return_status,x_msg_data,x_msg_count);
        elsif l_unavailable_list.count >= 1 and p_warehouse THEN
            CSP_SCH_INT_PVT.DO_ATP_CHECK(l_unavailable_list,l_interval,l_available_list,l_final_unavailable_list,x_return_status,x_msg_data,x_msg_count);
        END IF;
        IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
            RETURN;
        END IF;
        IF l_available_list.count > 0 THEN
                l_temp_line_id := l_available_list(1).line_id;
                l_final_available_list.extend;
                l_final_available_list(l_final_available_list.count) := l_available_list(1);
        END IF;
        FOR I IN 1..l_available_list.count LOOP
            IF l_temp_line_id <> l_available_list(I).line_id THEN
                l_final_available_list.extend;
                l_final_available_list(l_final_available_list.count) := l_available_list(I);
                l_temp_line_id := l_available_list(I).line_id;
            END IF;
        END LOOP;
        if p_mandatory then
          CSP_SCH_INT_PVT.ELIGIBLE_RESOURCES(l_resources,l_final_available_list,l_final_unavailable_list,l_eligible_resources_list,x_return_status,x_msg_data,x_msg_count);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
            RETURN;
          END IF;
        else
          FOR K IN  1..l_final_available_list.count LOOP
             l_eligible_resources_list.extend ;
             l_eligible_resources_list(l_eligible_resources_list.count).resource_id := l_final_available_list(K).resource_id ;
             l_eligible_resources_list(l_eligible_resources_list.count).resource_type := l_final_available_list(K).resource_type ;
             l_eligible_resources_list(l_eligible_resources_list.count).organization_id:= l_final_available_list(K).organization_id ;
             l_eligible_resources_list(l_eligible_resources_list.count).item_id := l_final_available_list(K).Item_Id ;
             l_eligible_resources_list(l_eligible_resources_list.count).quantity := l_final_available_list(K).quantity ;
             l_eligible_resources_list(l_eligible_resources_list.count).source_org := l_final_available_list(K).source_org ;
             l_eligible_resources_list(l_eligible_resources_list.count).item_uom := l_final_available_list(K).Item_uom ;
             l_eligible_resources_list(l_eligible_resources_list.count).revision := l_final_available_list(K).revision ;
             l_eligible_resources_list(l_eligible_resources_list.count).sub_inventory := l_final_available_list(K).sub_inventory ;
             l_eligible_resources_list(l_eligible_resources_list.count).available_date := l_final_available_list(K).available_date;
             l_eligible_resources_list(l_eligible_resources_list.count).line_id := l_final_available_list(K).line_id;
           END LOOP;
        end if;
        IF l_eligible_resources_list.count > 0 THEN
         --CSP_SCH_INT_PVT.GET_TIME_COST(l_eligible_resources_list,l_options,x_return_status);
            CSP_SCH_INT_PVT.OPTIMIZE_OPTIONS(l_eligible_resources_list,l_options,l_ship_count,l_res_ship_parameters,x_return_status,x_msg_data,x_msg_count);
        ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.SET_NAME('CSP', 'CSP_SCH_OPTION_NOT_VALIED');
            FND_MSG_PUB.ADD;
            fnd_msg_pub.count_and_get
              ( p_count => x_msg_count
              , p_data  => x_msg_data);
            return;
        END IF;
         FOR I IN 1..l_options.count LOOP
            IF (ROUND(((l_options(I).arrival_date - sysdate) * 24 * 60 ),2) <=  ROUND(((p_options.start_time - sysdate) * 24 * 60),2)
               OR (ROUND(((l_options(I).arrival_date - sysdate) * 24 * 60 ),2) - ROUND(((p_options.start_time - sysdate) * 24 * 60),2)) <= 10 )
               AND   l_options(I).transfer_cost <= nvl(p_options.transfer_cost,0) THEN
               l_temp_options.extend;
               l_temp_options(l_temp_options.count).resource_id       :=  l_options(I).resource_id;
               l_temp_options(l_temp_options.count).resource_type     :=  l_options(I).resource_type;
               l_temp_options(l_temp_options.count).lead_time         :=  l_options(I).lead_time   ;
               l_temp_options(l_temp_options.count).transfer_cost     :=  l_options(I).transfer_cost;
               l_temp_options(l_temp_options.count).shipping_methodes :=  l_options(I).shipping_methodes;
               l_temp_options(l_temp_options.count).arrival_date      :=  l_options(I).arrival_date ;
            END IF;
         END LOOP;
            IF l_temp_options.count = 0 then
                x_return_status := FND_API.G_RET_STS_ERROR;
                FND_MESSAGE.SET_NAME('CSP', 'CSP_SCH_OPTION_NOT_VALIED');
                FND_MSG_PUB.ADD;
                fnd_msg_pub.count_and_get
                    ( p_count => x_msg_count
                    , p_data  => x_msg_data);
                return;
            END IF;
        FOR I IN 1..l_temp_options.count LOOP
               IF I =1 THEN
                    min_cost := l_temp_options(I).transfer_cost;
                    l_final_option.extend;
                    l_final_option(l_final_option.count).resource_id       :=  l_temp_options(I).resource_id;
                    l_final_option(l_final_option.count).resource_type     :=  l_temp_options(I).resource_type;
                    l_final_option(l_final_option.count).lead_time         :=  l_temp_options(I).lead_time   ;
                    l_final_option(l_final_option.count).transfer_cost     :=  l_temp_options(I).transfer_cost;
                    IF l_temp_options(I).shipping_methodes IS NOT NULL THEN
                        l_temp_options(I).shipping_methodes := l_temp_options(I).shipping_methodes || '$' ;
                    END IF;
                    l_final_option(l_final_option.count).shipping_methodes :=  l_temp_options(I).shipping_methodes;
                    l_final_option(l_final_option.count).arrival_date      :=  l_temp_options(I).arrival_date ;
               ELSE
                    SELECT LEAST(min_cost, l_temp_options(I).transfer_cost) INTO min_cost
                    FROM   DUAL;
                    IF min_cost = l_temp_options(I).transfer_cost THEN
                       l_final_option.trim(l_final_option.count);
                       l_final_option.extend;
                       l_final_option(l_final_option.count).resource_id       :=  l_temp_options(I).resource_id;
                       l_final_option(l_final_option.count).resource_type     :=  l_temp_options(I).resource_type;
                       l_final_option(l_final_option.count).lead_time         :=  l_temp_options(I).lead_time   ;
                       l_final_option(l_final_option.count).transfer_cost     :=  l_temp_options(I).transfer_cost;
                        IF l_temp_options(I).shipping_methodes IS NOT NULL THEN
                            l_temp_options(I).shipping_methodes := l_temp_options(I).shipping_methodes || '$' ;
                        END IF;
                            l_final_option(l_final_option.count).shipping_methodes :=  l_temp_options(I).shipping_methodes;
                            l_final_option(l_final_option.count).arrival_date      :=  l_temp_options(I).arrival_date ;
                     END IF;
               END IF;
               g_arrival_date := l_final_option(l_final_option.count).arrival_date;
        END LOOP;
        previous_position :=1;
        str_length := 0;
        l_ship_methode_count := 1;
        IF l_ship_count.count > 1 THEN
            FOR I IN 1..l_ship_count.count LOOP
               IF l_ship_count(I).from_org_id <> l_ship_count(I).to_org_id  THEN
                    --IF I <> l_ship_count.count THEN
                        l_org_ship_methode.extend;
                        SELECT INSTR(l_final_option(1).shipping_methodes,'$',1,l_ship_methode_count ) INTO current_position
                        FROM   DUAL;
                        SELECT SUBSTR(l_final_option(1).shipping_methodes,previous_position,(current_position-previous_position))
                        INTO   l_org_ship_methode(l_org_ship_methode.count).shipping_methode
                        FROM   DUAL;
                        l_org_ship_methode(l_org_ship_methode.count).from_org := l_ship_count(I).from_org_id;
                        l_org_ship_methode(l_org_ship_methode.count).to_org   := l_ship_count(I).to_org_id ;
                        previous_position := current_position+1;
                        current_position := 1;
                        l_ship_methode_count := l_ship_methode_count + 1;
                 ELSE
                        l_org_ship_methode.extend;
                        l_org_ship_methode(l_org_ship_methode.count).from_org := l_ship_count(I).from_org_id;
                        l_org_ship_methode(l_org_ship_methode.count).to_org   := l_ship_count(I).to_org_id ;
                        l_org_ship_methode(l_org_ship_methode.count).shipping_methode := NULL;
                 END IF;
            END LOOP;
         ELSE
            l_org_ship_methode.extend;
            SELECT INSTR(l_final_option(1).shipping_methodes,'$',1,l_ship_methode_count ) INTO current_position
                        FROM   DUAL;
                        SELECT SUBSTR(l_final_option(1).shipping_methodes,previous_position,(current_position-previous_position))
                        INTO   l_org_ship_methode(l_org_ship_methode.count).shipping_methode
                        FROM   DUAL;
            l_org_ship_methode(l_org_ship_methode.count).from_org := l_ship_count(1).from_org_id;
            l_org_ship_methode(l_org_ship_methode.count).to_org   := l_ship_count(1).to_org_id ;
         --   l_org_ship_methode(l_org_ship_methode.count).shipping_methode := l_final_option(1).shipping_methodes;
         END IF;
        FOR I IN 1..l_eligible_resources_list.count LOOP
           IF l_eligible_resources_list(I).sub_inventory IS NULL  AND (l_eligible_resources_list(I).organization_id <> l_eligible_resources_list(I).source_org) THEN
                FOR J IN 1..l_org_ship_methode.count LOOP
                    IF l_eligible_resources_list(I).organization_id =l_org_ship_methode(J).to_org
                            AND  l_eligible_resources_list(I).source_org =l_org_ship_methode(J).from_org THEN
                        l_eligible_resources_list(I).shipping_methode := l_org_ship_methode(J).shipping_methode;
                            FOR K In 1..l_res_ship_parameters.count LOOP
                                IF l_res_ship_parameters(K).to_org_id = l_eligible_resources_list(I).organization_id
                                    AND l_res_ship_parameters(K).from_org_id = l_eligible_resources_list(I).source_org
                                    AND l_res_ship_parameters(K).shipping_method = l_eligible_resources_list(I).shipping_methode THEN
                                    l_eligible_resources_list(I).intransit_time := l_res_ship_parameters(K).lead_time ;
                                    exit;
                                END IF;
                            END LOOP;
                        EXIT;
                    END IF;
                END LOOP;
           END IF;
        END LOOP;
        rec_count := 1;
        IF l_eligible_resources_list.count > 0 THEN
                OPEN csp_resource_org(p_options.resource_id,p_options.resource_type);
                LOOP
                    FETCH csp_resource_org INTO l_destination_org_id,l_destination_sub_inv;
                    EXIT WHEN csp_resource_org % NOTFOUND;
                END LOOP;
                CLOSE csp_resource_org;
                OPEN csp_ship_to_location(p_options.resource_id,p_options.resource_type);
                LOOP
                    FETCH csp_ship_to_location INTO l_ship_to_location_id;
                    EXIT WHEN csp_ship_to_location % NOTFOUND;
                END LOOP;
                CLOSE csp_ship_to_location;
        END IF;
       FOR I IN 1..l_eligible_resources_list.count LOOP
            IF  l_eligible_resources_list(I).sub_inventory IS NOT NULL THEN
                l_reservation_id := NULL;
                l_reservation_parts.need_by_date       := p_options.start_time;
                l_reservation_parts.organization_id    := l_eligible_resources_list(I).source_org ;
                l_reservation_parts.item_id            := l_eligible_resources_list(I).item_id;
                l_reservation_parts.item_uom_code      := l_eligible_resources_list(I).item_uom;
                l_reservation_parts.quantity_needed    := l_eligible_resources_list(I).quantity;
                l_reservation_parts.sub_inventory_code := l_eligible_resources_list(I).sub_inventory;
                l_reservation_parts.line_id            := l_eligible_resources_list(I).line_id;
                l_reservation_parts.revision           := l_eligible_resources_list(I).revision;
                l_reservation_id := CSP_SCH_INT_PVT.CREATE_RESERVATION(l_reservation_parts,x_return_status,x_msg_data);
                IF l_reservation_id <= 0 THEN
                    ROLLBACK TO choose_options;
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    FND_MESSAGE.SET_NAME('CSP', 'CSP_SCH_COULD_NOT_RESERVE');
                    FND_MSG_PUB.ADD;
                    fnd_msg_pub.count_and_get
                        ( p_count => x_msg_count
                        , p_data  => x_msg_data);
                    return;
                END IF;

                l_requirement_header.RESOURCE_TYPE := l_eligible_resources_list(I).resource_type;
                l_requirement_header.RESOURCE_ID := l_eligible_resources_list(I).resource_id;
                l_requirement_header.DESTINATION_ORGANIZATION_ID := l_eligible_resources_list(I).source_org;
                l_requirement_header.DESTINATION_SUBINVENTORY := l_eligible_resources_list(I).sub_inventory;

                l_req_line_details_tbl.extend;
                select CSP_REQUIREMENT_LINES_S1.nextval INTO l_req_line_details_tbl(l_req_line_details_tbl.count).req_line_detail_id from dual;
                l_req_line_details_tbl(l_req_line_details_tbl.count).requirement_line_id  := l_eligible_resources_list(I).line_id ;
                l_req_line_details_tbl(l_req_line_details_tbl.count).source_type  := 'RES' ;
                l_req_line_details_tbl(l_req_line_details_tbl.count).source_id  := l_reservation_id ;
            ELSE
                l_parts_lines(rec_count).inventory_item_id := l_eligible_resources_list(I).item_id;
                l_parts_lines(rec_count).line_num                :=  rec_count ;
                l_parts_lines(rec_count).revision                :=  l_eligible_resources_list(I).revision; --l_revision;
                l_parts_lines(rec_count).quantity                :=  NULL;
                l_parts_lines(rec_count).unit_of_measure         :=  l_eligible_resources_list(I).item_uom;
                l_parts_lines(rec_count).dest_subinventory       :=  l_destination_sub_inv ;
                l_parts_lines(rec_count).source_organization_id  :=  l_eligible_resources_list(I).source_org ;
                l_parts_lines(rec_count).source_subinventory     :=  NULL;
                l_parts_lines(rec_count).ship_complete           :=  l_ship_set;
                l_parts_lines(rec_count).shipping_method_code    :=  l_eligible_resources_list(I).shipping_methode;
                l_parts_lines(rec_count).likelihood              :=  NULL;
                l_parts_lines(rec_count).ordered_quantity        :=  l_eligible_resources_list(I).quantity;
                 l_parts_lines(rec_count).reservation_id          :=  l_reservation_id;
                l_parts_lines(rec_count).requirement_line_id     :=  l_requirements_line_id;
                rec_count := rec_count + 1;
                l_req_line_details_tbl.extend;
                select CSP_REQUIREMENT_LINES_S1.nextval INTO l_req_line_details_tbl(l_req_line_details_tbl.count).req_line_detail_id from dual;
                l_req_line_details_tbl(l_req_line_details_tbl.count).requirement_line_id  := l_eligible_resources_list(I).line_id ;
                l_req_line_details_tbl(l_req_line_details_tbl.count).source_type  := 'IO' ;
            END IF;
            END LOOP;
            IF l_parts_lines.count > 0 THEN
            l_parts_header.ORDER_TYPE_ID := FND_PROFILE.value(name => 'CSP_ORDER_TYPE');
            l_parts_header.SHIP_TO_LOCATION_ID :=  l_ship_to_location_id;
            l_parts_header.DEST_ORGANIZATION_ID := l_destination_org_id;
                        l_parts_header.dest_subinventory := l_destination_sub_inv;
            l_parts_header.OPERATION := 'CREATE';
            l_parts_header.need_by_date :=g_arrival_date;
             CSP_PARTS_ORDER.process_order(
                                      p_api_version   =>  1.0
                                     ,p_Init_Msg_List =>  FND_API.G_FALSE
                                     ,p_commit        =>  FND_API.G_FALSE
                                     ,px_header_rec   =>  l_parts_header
                                     ,px_line_table   =>  l_parts_lines
                                     ,x_return_status =>  x_return_status
                                     ,x_msg_count     =>  x_msg_count
                                     ,x_msg_data      =>  x_msg_data
                                     );
            END IF;
            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                ROLLBACK TO CHOOSE_OPTIONS;
                x_return_status := FND_API.G_RET_STS_ERROR;
                FND_MESSAGE.SET_NAME('CSP', 'CSP_SCH_UNABLE_TO_ORDER');
                FND_MSG_PUB.ADD;
                fnd_msg_pub.count_and_get
                            ( p_count => x_msg_count
                            , p_data  => x_msg_data);
                return;
          ELSE

            l_requirement_header.RESOURCE_TYPE := p_options.resource_type;
            l_requirement_header.RESOURCE_ID := p_options.resource_id;
            l_requirement_header.DESTINATION_ORGANIZATION_ID := l_destination_org_id;
            l_requirement_header.DESTINATION_SUBINVENTORY := l_destination_sub_inv;

                FOR I IN 1..l_parts_lines.count LOOP
                    FOR J IN 1..l_req_line_details_tbl.count LOOP
                        IF l_req_line_details_tbl(J).source_type = 'IO' AND l_req_line_details_tbl(J).source_ID IS NULL THEN
                            l_req_line_details_tbl(J).source_ID :=  l_parts_lines(I).order_line_id;
                            EXIT;
                        END IF;
                    END LOOP;
                END LOOP;
            --CSP_Requirement_Lines_PVT.Update_requirement_lines(
                                --P_Api_Version_Number         => 1.0,
                                --P_Init_Msg_List              => FND_API.G_FALSE,
                                --P_Commit                     => FND_API.G_FALSE,
                                --p_validation_level           => FND_API.G_VALID_LEVEL_FULL,
                                --P_Requirement_Line_Tbl       => l_Requirement_Line_Tbl,
                                --X_Return_Status              => x_return_status,
                                --X_Msg_Count                  => x_msg_count,
                                --X_Msg_Data                   => x_msg_data
                                --);
         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            ROLLBACK TO choose_options;
            return;
         END IF;
         FOR K IN 1..l_req_line_details_tbl.count LOOP
            csp_req_line_details_pkg.insert_row(l_req_line_details_tbl(K).REQ_LINE_DETAIL_ID
                                                ,l_req_line_details_tbl(K).REQUIREMENT_LINE_ID
                                                ,fnd_global.user_id
                                                ,sysdate
                                                ,fnd_global.user_id
                                                ,sysdate
                                                ,fnd_global.login_id
                                                ,l_req_line_details_tbl(K).SOURCE_TYPE
                                                ,l_req_line_details_tbl(K).SOURCE_ID);
         END LOOP;
         OPEN C2;
         FETCH C2 INTO l_requirement_header_id,l_address_type;
         CLOSE C2;
         l_requirement_header.REQUIREMENT_HEADER_ID := l_requirement_header_id;
         l_requirement_header.TASK_ASSIGNMENT_ID    := p_task_assignment_id ;

         l_requirement_header.Last_Update_Date      := SYSDATE;
         IF l_address_type IS NULL or l_address_type = 'R' OR l_address_type = 'S' THEN
            l_requirement_header.address_type          := 'R';
            l_requirement_header.ship_to_location_id   := l_ship_to_location_id;
         END IF;
         l_requirement_header.ORDER_TYPE_ID := FND_PROFILE.value(name => 'CSP_ORDER_TYPE');
         CSP_Requirement_Headers_PVT.Update_requirement_headers(
                                P_Api_Version_Number         => 1.0,
                                P_Init_Msg_List              => FND_API.G_FALSE,
                                P_Commit                     => FND_API.G_FALSE,
                                p_validation_level           => FND_API.G_VALID_LEVEL_FULL,
                                P_REQUIREMENT_HEADER_Rec     => l_requirement_header,
                                X_Return_Status              => x_return_status,
                                X_Msg_Count                  => x_msg_count,
                                X_Msg_Data                   => x_msg_data
                                );
         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            ROLLBACK TO choose_options;
            return;
         END IF;
        END IF;

      EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK TO choose_options;
            FND_MESSAGE.SET_NAME('CSP', 'CSP_UNEXPECTED_EXEC_ERRORS');
            FND_MESSAGE.SET_TOKEN('ROUTINE', l_api_name, FALSE);
            FND_MESSAGE.SET_TOKEN('SQLERRM', sqlerrm, FALSE);
            FND_MSG_PUB.ADD;
            fnd_msg_pub.count_and_get
              ( p_count => x_msg_count
              , p_data  => x_msg_data);
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   END CHOOSE_OPTION;

   /* PROCEDURE CLEAN_MATERIAL_TRANSACTION(p_api_version_number  IN  NUMBER
                                        ,p_task_assignment_id  IN  NUMBER
                                        ,x_return_status       OUT NOCOPY VARCHAR2
                                        ,x_msg_data            OUT NOCOPY VARCHAR2
                                        ,x_msg_count           OUT NOCOPY NUMBER) IS

    CURSOR cancel_reserv  IS
    SELECT crl.RESERVATION_ID,crl.LOCAL_RESERVATION_ID,crl.REQUIREMENT_LINE_ID
    FROM   CSP_REQUIREMENT_LINES crl, csp_requirement_headers crh
    WHERE  crh.task_assignment_id = p_task_assignment_id
    and    crl.REQUIREMENT_HEADER_ID = crh.requirement_header_id
    AND    crl.local_RESERVATION_ID IS NOT NULL;

     cursor cancel_order IS
     select distinct  oeh.header_id,crl.requirement_line_id
     from oe_order_lines_all oel, oe_order_headers_all oeh, csp_requirement_headers crh, csp_requirement_lines crl
     where crh.task_assignment_id = p_task_assignment_id
     and   crl.REQUIREMENT_HEADER_ID = crh.REQUIREMENT_HEADER_ID
     and   oel.line_id = crl.order_line_id
     and   oeh.header_id =  oel.header_id
     order by oeh.header_id;

    l_api_name   varchar2(60) := 'CSP_SCH_INT_PVT.CLEAN_MATERIAL_TRANSACTION';
    l_reserv_id NUMBER;
    l_local_reserv_id NUMBER;
    l_order_id  NUMBER;
    l_return_status VARCHAR2(3);
    l_msg_data VARCHAR2(128);
    l_msg_count NUMBER;
    l_order_line_id NUMBER;
    l_previous_order_id NUMBER := 0;
    l_requirement_line_id NUMBER;
    l_Requirement_Line_Tbl         CSP_Requirement_Lines_PVT.Requirement_Line_Tbl_Type;
    l_Requirement_Line_Tbl_order   CSP_Requirement_Lines_PVT.Requirement_Line_Tbl_Type;
    req_loop NUMBER := 0 ;
    reservation_present BOOLEAN := FALSE;
    order_present       BOOLEAN := FALSE;
    BEGIN
         x_return_status := FND_API.G_RET_STS_SUCCESS;
         SAVEPOINT CLEAN_MATERIAL_TRANSACTION;
         OPEN cancel_reserv ;
         LOOP
            FETCH cancel_reserv INTO l_reserv_id,l_local_reserv_id,l_requirement_line_id;
            EXIT WHEN  cancel_reserv%NOTFOUND;
            IF l_reserv_id IS NOT NULL THEN
                CSP_SCH_INT_PVT.CANCEL_RESERVATION(l_reserv_id,x_return_status,x_msg_data,x_msg_count);
            END IF;
            IF l_local_reserv_id IS NOT NULL THEN
                CSP_SCH_INT_PVT.CANCEL_RESERVATION(l_local_reserv_id,x_return_status,x_msg_data,x_msg_count);
            END IF;
            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                ROLLBACK TO CLEAN_MATERIAL_TRANSACTION;
                x_return_status := FND_API.G_RET_STS_ERROR;
                FND_MESSAGE.SET_NAME('CSP', 'CSP_SCH_NOT_CANCEL_RESERV');
                FND_MSG_PUB.ADD;
                fnd_msg_pub.count_and_get
                    ( p_count => x_msg_count
                    , p_data  => x_msg_data);
                exit;
            ELSE
                req_loop := req_loop + 1;
                l_Requirement_Line_Tbl(req_loop).REQUIREMENT_LINE_ID      := l_requirement_line_id;
                l_Requirement_Line_Tbl(req_loop).local_RESERVATION_ID     := NULL;
                l_Requirement_Line_Tbl(req_loop).RESERVATION_ID           := NULL;
                l_Requirement_Line_Tbl(req_loop).source_organization_id   := NULL;
                l_Requirement_Line_Tbl(req_loop).source_subinventory      := NULL;
                l_Requirement_Line_Tbl(req_loop).sourced_from             := NULL;
                reservation_present := TRUE;
            END IF;
            l_reserv_id := NULL ;
         END LOOP;
         CLOSE cancel_reserv;
         IF x_return_status = FND_API.G_RET_STS_ERROR THEN
             ROLLBACK TO CLEAN_MATERIAL_TRANSACTION;
             return;
         ELSE
            IF  reservation_present THEN
                CSP_Requirement_Lines_PVT.Update_requirement_lines(
                                P_Api_Version_Number         => 1.0,
                                P_Init_Msg_List              => FND_API.G_FALSE,
                                P_Commit                     => FND_API.G_FALSE,
                                p_validation_level           => FND_API.G_VALID_LEVEL_FULL,
                                P_Requirement_Line_Tbl       => l_Requirement_Line_Tbl,
                                X_Return_Status              => x_return_status,
                                X_Msg_Count                  => x_msg_count,
                                X_Msg_Data                   => x_msg_data
                                );
                IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    ROLLBACK TO CLEAN_MATERIAL_TRANSACTION;
                    return;
                END IF;
             END IF;
          END IF;
                req_loop := 0;
         OPEN cancel_order;
         LOOP
            FETCH cancel_order INTO l_order_id,l_requirement_line_id ;
            EXIT WHEN cancel_order % NOTFOUND;
            IF l_order_id <> l_previous_order_id THEN
                CSP_SCH_INT_PVT.CANCEL_ORDER(l_order_id,x_return_status,x_msg_data,x_msg_count);
                l_previous_order_id := l_order_id;
            ELSE
                x_return_status := FND_API.G_RET_STS_SUCCESS;
            END IF;
            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               x_return_status := FND_API.G_RET_STS_ERROR;
               FND_MESSAGE.SET_NAME('CSP', 'CSP_SCH_NOT_CANCEL_ORDER');
               FND_MSG_PUB.ADD;
               fnd_msg_pub.count_and_get
                                ( p_count => x_msg_count
                                , p_data  => x_msg_data);
               exit;
            ELSE
                req_loop := req_loop + 1;
                l_Requirement_Line_Tbl(req_loop).REQUIREMENT_LINE_ID      := l_requirement_line_id;
                l_Requirement_Line_Tbl(req_loop).ORDER_LINE_ID            := NULL;
                l_Requirement_Line_Tbl(req_loop).source_organization_id   := NULL;
                l_Requirement_Line_Tbl(req_loop).source_subinventory      := NULL;
                l_Requirement_Line_Tbl(req_loop).shipping_method_code     := NULL;
                l_Requirement_Line_Tbl(req_loop).order_by_date            := NULL;
                l_Requirement_Line_Tbl(req_loop).arrival_date             := NULL;
                l_Requirement_Line_Tbl(req_loop).ordered_quantity         := NULL;
                l_Requirement_Line_Tbl(req_loop).sourced_from             := NULL;
                order_present := TRUE;
                l_requirement_line_id := null;
            END IF;
         END LOOP;
         CLOSE cancel_order;
         IF x_return_status = FND_API.G_RET_STS_ERROR THEN
             ROLLBACK TO CLEAN_MATERIAL_TRANSACTION;
             return;
         ELSE
              IF order_present then
                    CSP_Requirement_Lines_PVT.Update_requirement_lines(
                                P_Api_Version_Number         => 1.0,
                                P_Init_Msg_List              => FND_API.G_FALSE,
                                P_Commit                     => FND_API.G_FALSE,
                                p_validation_level           => FND_API.G_VALID_LEVEL_FULL,
                                P_Requirement_Line_Tbl       => l_Requirement_Line_Tbl,
                                X_Return_Status              => x_return_status,
                                X_Msg_Count                  => x_msg_count,
                                X_Msg_Data                   => x_msg_data
                                );
                    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        ROLLBACK TO CLEAN_MATERIAL_TRANSACTION;
                        return;
                    END IF;
                END IF;
           END IF;
           IF  x_return_status = FND_API.G_RET_STS_SUCCESS THEN
                    COMMIT WORK;
           END IF;
      EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK TO CLEAN_MATERIAL_TRANSACTION;
            FND_MESSAGE.SET_NAME('CSP', 'CSP_UNEXPECTED_EXEC_ERRORS');
            FND_MESSAGE.SET_TOKEN('ROUTINE', l_api_name, TRUE);
            FND_MESSAGE.SET_TOKEN('SQLERRM', sqlerrm, TRUE);
            FND_MSG_PUB.ADD;
            fnd_msg_pub.count_and_get
              ( p_count => x_msg_count
              , p_data  => x_msg_data);
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   END CLEAN_MATERIAL_TRANSACTION;*/

   PROCEDURE CLEAN_MATERIAL_TRANSACTION(p_api_version_number  IN  NUMBER
                                        ,p_task_assignment_id  IN  NUMBER
                                        ,x_return_status       OUT NOCOPY VARCHAR2
                                        ,x_msg_data            OUT NOCOPY VARCHAR2
                                        ,x_msg_count           OUT NOCOPY NUMBER) IS
    BEGIN

         if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
           fnd_log.string(fnd_log.level_statement,
                           'csp.plsql.csp_sch_int_pvt.clean_material_transaction',
                           'in Clean_Material_Transaction procedure.. calling CLEAN_REQUIREMENT....');
           fnd_log.string(fnd_log.level_statement,
                           'csp.plsql.csp_sch_int_pvt.clean_material_transaction',
                           'p_task_assignment_id = ' || p_task_assignment_id);
         end if;
         x_return_status := FND_API.G_RET_STS_SUCCESS;

        /*
        CLEAN_REQUIREMENT(
            p_api_version_number    => p_api_version_number,
            p_task_assignment_id    => p_task_assignment_id,
            x_return_status => x_return_status,
            x_msg_count => x_msg_count,
            x_msg_data => x_msg_data
            );
            */

         if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
           fnd_log.string(fnd_log.level_statement,
                           'csp.plsql.csp_sch_int_pvt.clean_material_transaction',
                           'leaving... x_return_status = ' || x_return_status);
         end if;

    END CLEAN_MATERIAL_TRANSACTION;

   PROCEDURE CLEAN_REQUIREMENT(p_api_version_number  IN  NUMBER
                                        ,p_task_assignment_id  IN  NUMBER
                                        ,x_return_status       OUT NOCOPY VARCHAR2
                                        ,x_msg_data            OUT NOCOPY VARCHAR2
                                        ,x_msg_count           OUT NOCOPY NUMBER) IS

    l_order_id  NUMBER;
    l_req_details_line_id NUMBER;
    l_reserv_id NUMBER;
    l_status varchar2(30);
    l_module_name varchar2(100);

    CURSOR get_reservations is
    select crld.source_id , crld.req_line_detail_id
    from  csp_req_line_details crld
         ,csp_requirement_lines crl
         ,csp_requirement_headers crh
    where  crh.task_assignment_id = p_task_assignment_id
    and crl.requirement_header_id = crh.requirement_header_id
    and crld.requirement_line_id = crl.requirement_line_id
    and crld.source_type = 'RES' ;

    CURSOR get_orders is
    select oeh.header_id, crld.req_line_detail_id, crh.address_type
    from  csp_req_line_details crld
         ,csp_requirement_lines crl
         ,csp_requirement_headers crh
         ,oe_order_lines_all oel
         ,oe_order_headers_all oeh
    where  crh.task_assignment_id = p_task_assignment_id
    and crl.requirement_header_id = crh.requirement_header_id
    and crld.requirement_line_id = crl.requirement_line_id
    and crld.source_type = 'IO'
    and oel.line_id = crld.source_id
    and oeh.header_id =  oel.header_id
    order by oeh.header_id;

    CURSOR get_order_status(c_header_id NUMBER) IS
    select flow_status_code
    from   oe_order_headers_all
    where  header_id =  c_header_id;

    cursor get_line_details(c_order_header_id Number) is
    select REQ_LINE_DETAIL_ID
    from  csp_req_line_details crld,oe_order_lines_all oel
    where crld.source_id = oel.line_id
    and crld.source_type = 'IO'
    and oel.header_id = c_order_header_id;

    cursor get_requirement_header_id is
    select requirement_header_id,address_type
    from csp_requirement_headers
    where task_assignment_id = p_task_assignment_id;

    cursor get_assign_status_closed_flag is
    SELECT nvl(jtsb.closed_flag, 'N')
    FROM JTF_TASK_STATUSES_B jtsb, JTF_TASK_ALL_ASSIGNMENTS jtaa
    WHERE jtsb.task_status_id = jtaa.assignment_status_id
    AND jtaa.task_assignment_id = p_task_assignment_id;

    l_requirement_header      CSP_Requirement_Headers_PVT.REQUIREMENT_HEADER_Rec_Type;
    l_requirement_header_id NUMBER;
    l_address_type varchar2(3);
    l_line_to_cancel number;
        l_fl_rcvd_lines number;
        l_shpd_lines number;
	l_assign_status_cl_flag varchar2(1);

   BEGIN
        l_module_name:= 'csp.plsql.csp_sch_int_pvt.clean_requirement';

         if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
           fnd_log.string(fnd_log.level_statement, l_module_name,
                           'begin...');
         end if;

        x_return_status := FND_API.G_RET_STS_SUCCESS;

                -- check for the fully rcvd case
                -- if yes then do not clear this
                -- choose option will take care of it
                l_fl_rcvd_lines := 0;
                SELECT COUNT(l.requirement_line_id)
                into l_fl_rcvd_lines
                FROM csp_requirement_headers h,
                  csp_requirement_lines l,
                  csp_req_line_details dio,
                  csp_req_line_details dres,
                  oe_order_lines_all oola,
                  mtl_reservations mr
                WHERE h.task_assignment_id    = p_task_assignment_id
                AND h.address_type         IN ('T', 'C', 'P')
                AND h.requirement_header_id = l.requirement_header_id
                AND l.requirement_line_id   = dio.requirement_line_id
                AND dio.source_type        = 'IO'
                AND dio.source_id = oola.line_id
                AND csp_pick_utils.get_order_status(oola.line_id,oola.flow_status_code)         = 'FULLY RECEIVED'
                AND dio.requirement_line_id = dres.requirement_line_id
                AND oola.inventory_item_id    = mr.inventory_item_id
                AND oola.ordered_quantity   = mr.reservation_quantity
                AND dres.source_type       = 'RES'
                AND dres.source_id = mr.reservation_id;

                if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                        fnd_log.string(fnd_log.level_statement, l_module_name,
                                           'l_fl_rcvd_lines=' || l_fl_rcvd_lines);
                end if;

                if l_fl_rcvd_lines > 0 then
                        return;
                end if;

                -- another check for already shipped order lines
                l_shpd_lines := 0;
                SELECT COUNT(l.requirement_line_id)
                into l_shpd_lines
                FROM csp_requirement_headers h,
                  csp_requirement_lines l,
                  csp_req_line_details d,
                  oe_order_lines_all oola
                WHERE h.task_assignment_id    = p_task_assignment_id
                AND h.requirement_header_id = l.requirement_header_id
                and h.address_type in ('C', 'T', 'P')
                AND l.requirement_line_id   = d.requirement_line_id
                AND d.source_type          = 'IO'
                AND d.source_id = oola.line_id
                AND csp_pick_utils.get_order_status(oola.line_id,oola.flow_status_code)           in ('SHIPPED', 'EXPECTED');

                if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                        fnd_log.string(fnd_log.level_statement, l_module_name,
                                           'l_shpd_lines=' || l_shpd_lines);
                end if;

                if l_shpd_lines > 0 then
                        return;
                end if;

        SAVEPOINT CLEAN_MATERIAL_TRANSACTION;

         OPEN get_reservations ;
         LOOP
            FETCH get_reservations INTO l_reserv_id,l_req_details_line_id;
            EXIT WHEN  get_reservations%NOTFOUND;

             if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
               fnd_log.string(fnd_log.level_statement, l_module_name,
                               'l_reserv_id = ' || l_reserv_id);
               fnd_log.string(fnd_log.level_statement, l_module_name,
                               'l_req_details_line_id = ' || l_req_details_line_id);
               fnd_log.string(fnd_log.level_statement, l_module_name,
                               'before cancelling reservation');
             end if;

                CSP_SCH_INT_PVT.CANCEL_RESERVATION(l_reserv_id,x_return_status,x_msg_data,x_msg_count);

             if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
               fnd_log.string(fnd_log.level_statement, l_module_name,
                               'after cancelling reservation... x_return_status = ' || x_return_status);
             end if;

                IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    --x_return_status := FND_API.G_RET_STS_SUCCESS;
                    rollback to CLEAN_MATERIAL_TRANSACTION;
                    return;
                ELSE
                    CSP_REQ_LINE_DETAILS_PKG.Delete_Row(l_req_details_line_id);
                END IF;
         END LOOP;
         close get_reservations;

         if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
           fnd_log.string(fnd_log.level_statement, l_module_name,
                           'after reservation loop... x_return_status = ' || x_return_status);
         end if;

         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            --x_return_status := FND_API.G_RET_STS_SUCCESS;
            rollback to CLEAN_MATERIAL_TRANSACTION;
            return;
         ELSE
            OPEN get_orders;
            LOOP
                FETCH get_orders INTO l_order_id ,l_req_details_line_id, l_address_type ;
                EXIT WHEN get_orders% NOTFOUND;

                 if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                   fnd_log.string(fnd_log.level_statement, l_module_name,
                                   'l_order_id = ' || l_order_id);
                   fnd_log.string(fnd_log.level_statement, l_module_name,
                                   'l_req_details_line_id = ' || l_req_details_line_id);
                 end if;

                OPEN get_order_status(l_order_id);
                FETCH get_order_status INTO l_status;
                CLOSE get_order_status;

                 if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                   fnd_log.string(fnd_log.level_statement, l_module_name,
                                   'l_status = ' || l_status);
                 end if;

                SELECT COUNT(1)
                INTO l_line_to_cancel
                FROM oe_order_lines_all
                WHERE header_id    = l_order_id
                AND cancelled_flag = 'N'
                                AND open_flag = 'Y'
                                AND flow_status_code <> 'SHIPPED';

                 if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                   fnd_log.string(fnd_log.level_statement, l_module_name,
                                   'l_line_to_cancel = ' || l_line_to_cancel);
                 end if;

                IF l_status <> 'CANCELLED'
                                        and l_status <> 'CLOSED'
                                        and l_line_to_cancel > 0 THEN

                     if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                       fnd_log.string(fnd_log.level_statement, l_module_name,
                                       'before CANCEL_ORDER...');
                     end if;

                   CSP_SCH_INT_PVT.CANCEL_ORDER(l_order_id,x_return_status,x_msg_data,x_msg_count);

                     if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                       fnd_log.string(fnd_log.level_statement, l_module_name,
                                       'after CANCEL_ORDER... x_return_status = ' || x_return_status);
                     end if;

                   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                                --x_return_status := FND_API.G_RET_STS_SUCCESS;
                                                rollback to CLEAN_MATERIAL_TRANSACTION;

                                                -- bug # 14084319
                                                -- we assume the error is due to the custom OM constraints
                                                -- return special return status code, so that the caller
                                                -- can read this
                                                if l_address_type = 'T' or l_address_type = 'C' or l_address_type = 'P' then
                                                        x_return_status := 'C';        -- CSP custom return code
                                                end if;
                                                return;
                   END IF;
                                END IF;

                                open get_line_details(l_order_id);
                                LOOP
                                 FETCH get_line_details INTO l_req_details_line_id;
                                 EXIT WHEN get_line_details% NOTFOUND;

                                         if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                                           fnd_log.string(fnd_log.level_statement, l_module_name,
                                                                           'deleting req_line_details for l_req_details_line_id = ' || l_req_details_line_id);
                                         end if;

                           if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                                           fnd_log.string(fnd_log.level_statement, l_module_name,
                                            'CSF_TASKS_PUB.g_reschedule = ' || CSF_TASKS_PUB.g_reschedule);
                            end if;

                                        --17080626
				        OPEN get_assign_status_closed_flag;
					FETCH get_assign_status_closed_flag INTO l_assign_status_cl_flag;
					CLOSE get_assign_status_closed_flag;

					if l_assign_status_cl_flag = 'N' or (nvl(CSF_TASKS_PUB.g_reschedule, 'N') = 'Y') then
						CSP_REQ_LINE_DETAILS_PKG.Delete_Row(l_req_details_line_id);
                                        else
                                                return;
					end if;
					--17080626

                                END LOOP;
                                CLOSE get_line_details;

            END LOOP;
            close get_orders;

         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            rollback to CLEAN_MATERIAL_TRANSACTION;
            return;
         END IF;

         OPEN get_requirement_header_id;
         FETCH get_requirement_header_id INTO l_requirement_header_id, l_address_type;
         CLOSE get_requirement_header_id;

         if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
           fnd_log.string(fnd_log.level_statement, l_module_name,
                           'l_requirement_header_id = ' || l_requirement_header_id);
           fnd_log.string(fnd_log.level_statement, l_module_name,
                           'l_address_type = ' || l_address_type);
         end if;

         if l_requirement_header_id is not null THEN
                l_requirement_header.REQUIREMENT_HEADER_ID := l_requirement_header_id;
                l_requirement_header.TASK_ASSIGNMENT_ID    := NULL ;

                if nvl(l_address_type, 'X') IN ('R', 'S') THEN
                  l_requirement_header.ship_to_location_id := null;
                  --l_requirement_header.address_Type := null;
            end if;
                l_requirement_header.resource_type := null;
                l_requirement_header.resource_id := null;
                l_requirement_header.destination_organization_id  := null;
                l_requirement_header.destination_subinventory  := null;

         if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
           fnd_log.string(fnd_log.level_statement, l_module_name,
                           'before updating req header... ');
         end if;

                CSP_Requirement_Headers_PVT.Update_requirement_headers(
                                P_Api_Version_Number         => 1.0,
                                P_Init_Msg_List              => FND_API.G_FALSE,
                                P_Commit                     => FND_API.G_FALSE,
                                p_validation_level           => FND_API.G_VALID_LEVEL_FULL,
                                P_REQUIREMENT_HEADER_Rec     => l_requirement_header,
                                X_Return_Status              => x_return_status,
                                X_Msg_Count                  => x_msg_count,
                                X_Msg_Data                   => x_msg_data
                                );

         if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
           fnd_log.string(fnd_log.level_statement, l_module_name,
                           'after updating req header... x_return_status = ' || x_return_status);
         end if;

          END IF;
            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                --x_return_status := FND_API.G_RET_STS_SUCCESS;
                rollback to CLEAN_MATERIAL_TRANSACTION;
                return;
            END IF;

         END IF;
   END CLEAN_REQUIREMENT;

   PROCEDURE CANCEL_RESERVATION(p_reserv_id   IN NUMBER
                                ,x_return_status OUT NOCOPY VARCHAR2
                                ,x_msg_data OUT NOCOPY VARCHAR2
                                ,x_msg_count OUT NOCOPY NUMBER) IS
    l_api_name   varchar2(60) := 'CSP_SCH_INT_PVT.CANCEL_RESERVATION';
    l_api_version_number NUMBER := 1.0;
    l_return_status      VARCHAR2(3);
    l_msg_count          NUMBER;
    l_init_msg_lst       VARCHAR2(1) := fnd_api.g_true;
    l_msg_data           VARCHAR2(2000);
    l_rsv_rec        inv_reservation_global.mtl_reservation_rec_type;
    l_serial_number  inv_reservation_global.serial_number_tbl_type;
   BEGIN
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        l_rsv_rec.reservation_id := p_reserv_id ;
        INV_RESERVATION_PUB.delete_reservation(l_api_version_number
                                              ,l_init_msg_lst
                                              ,x_return_status
                                              ,x_msg_count
                                              ,x_msg_data
                                              ,l_rsv_rec
                                              ,l_serial_number);
     EXCEPTION
     WHEN OTHERS THEN
            ROLLBACK TO CLEAN_MATERIAL_TRANSACTION;
            FND_MESSAGE.SET_NAME('CSP', 'CSP_UNEXPECTED_EXEC_ERRORS');
            FND_MESSAGE.SET_TOKEN('ROUTINE', l_api_name, FALSE);
            FND_MESSAGE.SET_TOKEN('SQLERRM', sqlerrm, FALSE);
            FND_MSG_PUB.ADD;
            fnd_msg_pub.count_and_get
              ( p_count => x_msg_count
              , p_data  => x_msg_data);
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   END CANCEL_RESERVATION;

   PROCEDURE CANCEL_ORDER(p_order_id      IN   NUMBER
                         ,x_return_status OUT NOCOPY  VARCHAR2
                         ,x_msg_data      OUT NOCOPY  VARCHAR2
                         ,x_msg_count     OUT NOCOPY  NUMBER) IS
      l_parts_header             csp_parts_requirement.Header_rec_type;
      l_parts_lines              csp_parts_requirement.Line_Tbl_type;
      l_api_version              NUMBER := 1.0;
      l_api_name        varchar2(60) := 'CSP_SCH_INT_PVT.CANCEL_ORDER';
   BEGIN
            x_return_status := FND_API.G_RET_STS_SUCCESS;
            l_parts_header.order_header_id := p_order_id;
            --l_parts_header.operation       := 'CANCEL';
            fnd_profile.get('CSP_CANCEL_REASON', l_parts_header.change_Reason);


            CSP_PARTS_ORDER.Cancel_Order(
                p_header_rec    => l_parts_header,
                p_line_table    => l_parts_lines,
                p_process_Type  => 'ORDER',
                x_return_status => x_return_status,
                x_msg_count     => x_msg_count,
                x_msg_data      => x_msg_data
                );

            EXCEPTION
            WHEN OTHERS THEN
            FND_MESSAGE.SET_NAME('CSP', 'CSP_UNEXPECTED_EXEC_ERRORS');
            FND_MESSAGE.SET_TOKEN('ROUTINE', l_api_name, FALSE);
            FND_MESSAGE.SET_TOKEN('SQLERRM', sqlerrm, FALSE);
            FND_MSG_PUB.ADD;
            fnd_msg_pub.count_and_get
              ( p_count => x_msg_count
              , p_data  => x_msg_data);
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   END CANCEL_ORDER;
   PROCEDURE CREATE_ORDERS(p_api_version_number  IN  NUMBER
                         ,p_task_assignment_id  IN  NUMBER
                         ,x_return_status       OUT NOCOPY VARCHAR2
                         ,x_msg_data            OUT NOCOPY VARCHAR2
                         ,x_msg_count           OUT NOCOPY NUMBER) IS

        CURSOR get_orders is
        select distinct oeh.header_id, oel.line_id
        from  csp_req_line_details crld
         ,csp_requirement_lines crl
         ,csp_requirement_headers crh
         ,oe_order_lines_all oel
         ,oe_order_headers_all oeh
        where  crh.task_assignment_id = p_task_assignment_id
        and crl.requirement_header_id = crh.requirement_header_id
        and crld.requirement_line_id = crl.requirement_line_id
        and crld.source_type = 'IO'
        and oel.line_id = crld.source_id
        and oeh.header_id =  oel.header_id
        order by oeh.header_id;

        l_api_name                 VARCHAR2(60) := 'CSP_SCH_INT_PVT.CREATE_ORDERS';
        l_parts_header             csp_parts_requirement.Header_rec_type;
        l_parts_lines              csp_parts_requirement.Line_Tbl_type;
        l_order_header_id          NUMBER;
        l_order_line_id            NUMBER;
        l_header_id                NUMBER;
        rec_count                  NUMBER := 1;
        l_previous_header_id       NUMBER := NULL;
   BEGIN
        SAVEPOINT CREATE_ORDERS;
        l_previous_header_id := NULL;
        OPEN get_orders;
        LOOP
        FETCH get_orders into l_order_header_id, l_order_line_id;
        EXIT WHEN get_orders % NOTFOUND;
        IF l_previous_header_id IS NULL THEN
            l_previous_header_id := l_order_header_id;
        END IF;
        IF l_previous_header_id <> l_order_header_id THEN
                 l_parts_header.OPERATION := 'UPDATE';
                 l_parts_header.order_header_id := l_previous_header_id;
                     CSP_PARTS_ORDER.process_order(
                                      p_api_version   =>  1.0
                                     ,p_Init_Msg_List =>  FND_API.G_FALSE
                                     ,p_commit        =>  FND_API.G_FALSE
                                     ,px_header_rec   =>  l_parts_header
                                     ,px_line_table   =>  l_parts_lines
                                     ,p_process_type  =>  'ORDER'
                                     ,x_return_status =>  x_return_status
                                     ,x_msg_count     =>  x_msg_count
                                     ,x_msg_data      =>  x_msg_data
                                     );
                IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    ROLLBACK TO CREATE_ORDERS;
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    FND_MESSAGE.SET_NAME('CSP', 'CSP_SCH_UNABLE_TO_ORDER');
                    FND_MSG_PUB.ADD;
                    fnd_msg_pub.count_and_get
                            ( p_count => x_msg_count
                            , p_data  => x_msg_data);
                    exit;
                END IF;
                l_previous_header_id := l_order_header_id;
              END IF;
            l_parts_lines(rec_count).order_line_id     := l_order_line_id;
            l_parts_lines(rec_count).booked_flag       := 'Y';
            rec_count := rec_count + 1;
        END LOOP;
        CLOSE get_orders;
        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RETURN;
        END IF;
   END CREATE_ORDERS;

   /*PROCEDURE CREATE_ORDERS(p_api_version_number  IN  NUMBER
                         ,p_task_assignment_id  IN  NUMBER
                         ,x_return_status       OUT NOCOPY VARCHAR2
                         ,x_msg_data            OUT NOCOPY VARCHAR2
                         ,x_msg_count           OUT NOCOPY NUMBER) IS
   /* CURSOR get_parts(c_task_assignment NUMBER) IS
    SELECT  INVENTORY_ITEM_ID, UOM_CODE,REVISION
           ,SHIP_COMPLETE_FLAG,SOURCE_ORGANIZATION_ID
           ,ORDERED_QUANTITY,REQUIREMENT_LINE_ID,RESERVATION_ID
    FROM  CSP_REQUIREMENT_HEADERS HR,CSP_REQUIREMENT_LINES LN
    WHERE HR.TASK_ASSIGNMENT_ID = c_task_assignment
    AND   LN.REQUIREMENT_HEADER_ID = HR.REQUIREMENT_HEADER_ID;


    This has been commented and spli in to two queries because of performance
    reasons.


    */
    /*CURSOR C1(c_task_assignment number) is
    select REQUIREMENT_HEADER_ID
    from   CSP_REQUIREMENT_HEADERS
    where  TASK_ASSIGNMENT_ID = c_task_assignment;
    CURSOR C2(c_header_id number) is
    SELECT  INVENTORY_ITEM_ID, UOM_CODE,REVISION
           ,SHIP_COMPLETE_FLAG,SOURCE_ORGANIZATION_ID
           ,ORDERED_QUANTITY,REQUIREMENT_LINE_ID,RESERVATION_ID
    FROM  CSP_REQUIREMENT_LINES
    WHERE REQUIREMENT_HEADER_ID = c_header_id;


    CURSOR get_resource(c_task_assignment_id NUMBER) IS
    SELECT RESOURCE_ID,RESOURCE_TYPE_CODE
    FROM   JTF_TASK_ASSIGNMENTS
    WHERE  TASK_ASSIGNMENT_ID=c_task_assignment_id;

    CURSOR  csp_resource_org(c_resource_id number, c_resource_type varchar2) IS
    SELECT  ORGANIZATION_ID, SUBINVENTORY_CODE
    FROM    CSP_INV_LOC_ASSIGNMENTS
    WHERE   RESOURCE_ID = c_resource_id
    AND     RESOURCE_TYPE = c_resource_type
    AND     DEFAULT_CODE = 'IN' ;

    CURSOR  csp_ship_to_location(c_resource_id number, c_resource_type varchar2) IS
    SELECT  SHIP_TO_LOCATION_ID
    FROM    CSP_RS_SHIP_TO_ADDRESSES_V
    WHERE   RESOURCE_ID = c_resource_id
    AND     RESOURCE_TYPE = c_resource_type
    AND     PRIMARY_FLAG = 'Y';

    l_api_name                 VARCHAR2(60) := 'CSP_SCH_INT_PVT.CREATE_ORDERS';
    l_parts_header             csp_parts_requirement.Header_rec_type;
    l_parts_lines              csp_parts_requirement.Line_Tbl_type;
    l_requrements_lines        CSP_Requirement_Lines_PVT.Requirement_Line_Tbl_Type;
    l_return_status            VARCHAR2(30);
    l_msg_count                NUMBER;
    l_msg_data                 VARCHAR2(1000);
    l_resource_id              NUMBER;
    l_resource_type            VARCHAR2(30);
    l_destination_org_id       NUMBER;
    l_destination_sub_inv      VARCHAR2(10);
    l_item_id                  NUMBER;
    l_uom_code                 VARCHAR2(3);
    l_ship_set                 VARCHAR2(30);
    l_source_org               NUMBER;
    l_order_quantity           NUMBER;
    l_revision                 VARCHAR2(3);
    l_line_id                  NUMBER;
    rec_count                     NUMBER;
    l_ship_to_location_id         NUMBER;
    l_reservation_id              NUMBER;
    x_reservation_id              NUMBER;
    l_header_id                   NUMBER;
  BEGIN
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        SAVEPOINT CREATE_ORDERS;
        OPEN get_resource(p_task_assignment_id);
        LOOP
            FETCH get_resource INTO l_resource_id,l_resource_type;
            EXIT WHEN get_resource% NOTFOUND;
        END LOOP;
        CLOSE get_resource;

        OPEN csp_resource_org(l_resource_id,l_resource_type);
        LOOP
            FETCH csp_resource_org INTO l_destination_org_id,l_destination_sub_inv ;
            EXIT WHEN csp_resource_org%NOTFOUND;
        END LOOP;
        CLOSE csp_resource_org;
        /*OPEN get_parts(p_task_assignment_id);
        rec_count := 1;
        LOOP
            FETCH get_parts INTO l_item_id,l_uom_code,l_revision,
                                 l_ship_set,l_source_org,l_order_quantity,
                                 l_line_id,l_reservation_id;
            EXIT WHEN get_parts % NOTFOUND ;
            l_parts_lines(rec_count).inventory_item_id := l_item_id;
            --l_parts_lines(rec_count).item_description  := 'test';
            l_parts_lines(rec_count).line_num := rec_count ;
            l_parts_lines(rec_count).revision          := l_revision;
            l_parts_lines(rec_count).quantity          := NULL;
            l_parts_lines(rec_count).unit_of_measure   := l_uom_code ;
            l_parts_lines(rec_count).dest_subinventory := l_destination_sub_inv ;
            l_parts_lines(rec_count).source_organization_id  :=  l_source_org ;
            l_parts_lines(rec_count).source_subinventory     :=  NULL;
            l_parts_lines(rec_count).ship_complete           :=  l_ship_set;
            l_parts_lines(rec_count).likelihood              :=  NULL;
            l_parts_lines(rec_count).ordered_quantity        :=  l_order_quantity;
            l_parts_lines(rec_count).reservation_id          :=  l_reservation_id;
            l_parts_lines(rec_count).requirement_line_id     :=  l_line_id;
            rec_count := rec_count + 1;
        END LOOP;
        CLOSE get_parts;*/
        /*OPEN C1(p_task_assignment_id);
        LOOP
            FETCH C1 INTO l_header_id;
            EXIT WHEN C1%NOTFOUND;
        END LOOP;
        CLOSE C1;
        OPEN C2(l_header_id);
        rec_count := 1;
        LOOP
            l_item_id := null;
            l_uom_code := null;
            l_revision := null;
            l_ship_set := null;
            l_source_org := null;
            l_order_quantity := null;
            l_line_id := null;
            l_reservation_id := null;
            FETCH C2 INTO l_item_id,l_uom_code,l_revision,
                                 l_ship_set,l_source_org,l_order_quantity,
                                 l_line_id,l_reservation_id;
            EXIT WHEN C2 % NOTFOUND ;
            l_parts_lines(rec_count).inventory_item_id := l_item_id;
            --l_parts_lines(rec_count).item_description  := 'test';
            l_parts_lines(rec_count).line_num := rec_count ;
            l_parts_lines(rec_count).revision          := l_revision;
            l_parts_lines(rec_count).quantity          := NULL;
            l_parts_lines(rec_count).unit_of_measure   := l_uom_code ;
            l_parts_lines(rec_count).dest_subinventory := l_destination_sub_inv ;
            l_parts_lines(rec_count).source_organization_id  :=  l_source_org ;
            l_parts_lines(rec_count).source_subinventory     :=  NULL;
            l_parts_lines(rec_count).ship_complete           :=  l_ship_set;
            l_parts_lines(rec_count).likelihood              :=  NULL;
            l_parts_lines(rec_count).ordered_quantity        :=  l_order_quantity;
            --l_parts_lines(rec_count).reservation_id          :=  l_reservation_id;
            l_parts_lines(rec_count).requirement_line_id     :=  l_line_id;
            rec_count := rec_count + 1;
        END LOOP;
        CLOSE C2;
        OPEN csp_ship_to_location(l_resource_id,l_resource_type);
        LOOP
            FETCH csp_ship_to_location INTO l_ship_to_location_id;
            EXIT WHEN csp_ship_to_location% NOTFOUND;
        END LOOP;
        CLOSE csp_ship_to_location;
        l_parts_header.ORDER_TYPE_ID := FND_PROFILE.value(name => 'CSP_ORDER_TYPE');
        l_parts_header.SHIP_TO_LOCATION_ID :=  l_ship_to_location_id;
        l_parts_header.DEST_ORGANIZATION_ID := l_destination_org_id;
        l_parts_header.OPERATION := 'CREATE';
        CSP_PARTS_ORDER.process_order(
                                      p_api_version   =>  1.0
                                     ,p_Init_Msg_List =>  FND_API.G_FALSE
                                     ,p_commit        =>  FND_API.G_FALSE
                                     ,px_header_rec   =>  l_parts_header
                                     ,px_line_table   =>  l_parts_lines
                                     ,x_return_status =>  l_return_status
                                     ,x_msg_count     =>  l_msg_count
                                     ,x_msg_data      =>  l_msg_data
                                     );
       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            ROLLBACK TO CREATE_ORDERS;
             x_return_status := FND_API.G_RET_STS_ERROR;
             FND_MESSAGE.SET_NAME('CSP', 'CSP_SCH_UNABLE_TO_ORDER');
             FND_MSG_PUB.ADD;
             fnd_msg_pub.count_and_get
                            ( p_count => x_msg_count
                            , p_data  => x_msg_data);
            return;
       ELSE
          FOR I IN 1..l_parts_lines.count LOOP
                l_requrements_lines(I).REQUIREMENT_LINE_ID :=  l_parts_lines(I).requirement_line_id;
                l_requrements_lines(I).ORDER_LINE_ID       :=  l_parts_lines(I).order_line_id;
                CSP_SCH_INT_PVT.TRANSFER_RESERVATION(p_reservation_id  => l_parts_lines(I).reservation_id
                                                    ,p_order_header_id => l_parts_header.order_header_id
                                                    ,p_order_line_id   => l_parts_lines(I).order_line_id
                                                    ,x_return_status   => x_return_status
                                                    ,x_reservation_id  => x_reservation_id
                                                    ,x_msg_data        => x_msg_data
                                                    ,x_msg_count       => x_msg_count);
               IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    Rollback to CREATE_ORDERS;
                    x_msg_data := ' Unable to Transfer Reservations';
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    return;
               ELSE
                    l_requrements_lines(I).reservation_id := x_reservation_id;
               END IF;
          END LOOP;
          CSP_Requirement_Lines_PVT.Update_requirement_lines(
                                    P_Api_Version_Number     => 1.0,
                                    P_Init_Msg_List          => FND_API.G_FALSE,
                                    P_Commit                 => FND_API.G_FALSE,
                                    p_validation_level       => FND_API.G_VALID_LEVEL_FULL,
                                    P_Requirement_Line_Tbl   => l_requrements_lines,
                                    X_Return_Status          => l_return_status,
                                    X_Msg_Count              => l_msg_count,
                                    X_Msg_Data               => l_msg_data
                                    )  ;
         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            ROLLBACK TO CREATE_ORDERS;
            return;
         END IF;
      END IF;
      EXCEPTION
        WHEN OTHERS THEN
            FND_MESSAGE.SET_NAME('CSP', 'CSP_UNEXPECTED_EXEC_ERRORS');
            FND_MESSAGE.SET_TOKEN('ROUTINE', l_api_name, TRUE);
            FND_MESSAGE.SET_TOKEN('SQLERRM', sqlerrm, TRUE);
            FND_MSG_PUB.ADD;
            fnd_msg_pub.count_and_get
              ( p_count => x_msg_count
              , p_data  => x_msg_data);
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END CREATE_ORDERS;*/

  PROCEDURE GET_ORGANIZATION_SUBINV( p_resources            IN  CSP_SCH_INT_PVT.csp_sch_resource_tbl_typ
                                    ,x_resource_org_subinv  OUT NOCOPY CSP_SCH_INT_PVT.csp_resource_org_tbl_typ
                                    ,x_return_status        OUT NOCOPY VARCHAR2
                                    ,x_msg_data             OUT NOCOPY VARCHAR2
                                    ,x_msg_count            OUT NOCOPY NUMBER) IS

        CURSOR csp_resource_org(l_resource_id number, l_resource_type varchar2) IS
        SELECT  ORGANIZATION_ID, SUBINVENTORY_CODE
        FROM    CSP_INV_LOC_ASSIGNMENTS
        WHERE   RESOURCE_ID = l_resource_id
        AND     RESOURCE_TYPE = l_resource_type
        AND     DEFAULT_CODE = 'IN' ;

        CURSOR csp_resource_type_name(l_resource_type varchar2) is
        SELECT NAME
        FROM JTF_OBJECTS_VL
        WHERE OBJECT_CODE = l_resource_type;
        l_organization NUMBER;
        l_sub_inventory VARCHAR2(10);
        l_api_name   varchar2(60) :=    'CSP_SCH_INT_PVT.GET_ORGANIZATION_SUBINV';
        l_msg_count  number;
        l_msg_data   number;
        l_resource_name varchar2(1000);
        l_resource_type_name varchar2(1000);
  BEGIN
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        x_resource_org_subinv := CSP_SCH_INT_PVT.csp_resource_org_tbl_typ();
        FOR I IN 1..p_resources.count
                LOOP
                        OPEN csp_resource_org(p_resources(I).resource_id, p_resources(I).resource_type);
                        LOOP
                                FETCH csp_resource_org INTO l_organization,l_sub_inventory ;
                                EXIT WHEN csp_resource_org%NOTFOUND ;
                        END LOOP;

                        IF csp_resource_org%rowcount =0 THEN
                        /*select csp_pick_utils.get_object_name(p_resources(I).resource_type,p_resources(I).resource_id)
                        INTO   l_resource_name
                        FROM   DUAL;*/
                        OPEN csp_resource_type_name(p_resources(I).resource_type);
                        LOOP
                            FETCH csp_resource_type_name INTO l_resource_type_name;
                            EXIT WHEN csp_resource_type_name%NOTFOUND;
                        END LOOP;
                        CLOSE csp_resource_type_name;
                        l_resource_name := csp_pick_utils.get_object_name(p_resources(I).resource_type,p_resources(I).resource_id);
                        FND_MESSAGE.SET_NAME('CSP', 'CSP_SCH_DEFAULT_SUBINV');
                        FND_MESSAGE.SET_TOKEN('RESOURCE_TYPE',l_resource_type_name,FALSE);
                        FND_MESSAGE.SET_TOKEN('RESOURCE_NAME',l_resource_name, FALSE);
                        FND_MSG_PUB.ADD;
                        fnd_msg_pub.count_and_get( p_count => x_msg_count
                                                 , p_data  => x_msg_data);
                      --  x_msg_data := 'Default organization and subinventory not defined for  ' || l_resource_type_name || '  ' || l_resource_name ;
                        x_return_status := FND_API.G_RET_STS_ERROR;
                        return;
                        END IF;
            CLOSE csp_resource_org;
                         x_resource_org_subinv.extend;
                         x_resource_org_subinv(I).resource_id := p_resources(I).resource_id ;
                         x_resource_org_subinv(I).resource_type := p_resources(I).resource_type ;
                         x_resource_org_subinv(I).organization_id := l_organization;
                         x_resource_org_subinv(I).sub_inv_code  := l_sub_inventory;
        END LOOP;
        EXCEPTION
        WHEN OTHERS THEN
            FND_MESSAGE.SET_NAME('CSP', 'CSP_UNEXPECTED_EXEC_ERRORS');
            FND_MESSAGE.SET_TOKEN('ROUTINE', l_api_name, FALSE);
            FND_MESSAGE.SET_TOKEN('SQLERRM', sqlerrm,FALSE);
            FND_MSG_PUB.ADD;
            fnd_msg_pub.count_and_get
              ( p_count => x_msg_count
              , p_data  => x_msg_data);
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END GET_ORGANIZATION_SUBINV;

  PROCEDURE GET_PARTS_LIST(p_task_id       IN NUMBER
                           ,p_likelihood    IN NUMBER
                           ,x_parts_list    OUT NOCOPY CSP_SCH_INT_PVT.csp_parts_tbl_typ1
                           ,x_return_status OUT NOCOPY VARCHAR2
                           ,x_msg_data      OUT NOCOPY VARCHAR2
                           ,x_msg_count     OUT NOCOPY NUMBER) IS

        CURSOR parts_list(product_task NUMBER,  parts_category NUMBER) IS
        SELECT INVENTORY_ITEM_ID,REQUIRED_QUANTITY , UOM_CODE,SHIP_COMPLETE_FLAG,REVISION,REQUIREMENT_LINE_ID
        FROM   CSP_REQUIREMENT_LINES crl, CSP_REQUIREMENT_HEADERS crh
        WHERE  crh.TASK_ID = product_task
        AND    crl.requirement_header_id = crh.requirement_header_id
        AND    nvl(crl.LIKELIHOOD,0) >= nvl(parts_category,0) ;

        part_number   NUMBER;
        part_quantity NUMBER;
        l_requirement_header_id NUMBER;
        part_uom      varchar2(3) ;
        l_ship_complet VARCHAR2(30);
        l_msg_data     VARCHAR2(2000);
        l_msg_count    NUMBER;
        l_revision     varchar2(3);
        l_api_name     varchar2(60) := 'CSP_SCH_INT_PVT.GET_PARTS_LIST' ;
        l_header_id    NUMBER;
        loop_count     NUMBER := 0;
        l_line_id     NUMBER;

  BEGIN
       -- savepoint GET_PARTS_LIST;
        x_return_status := FND_API.G_RET_STS_SUCCESS ;
       --x_parts_list := CSP_SCH_INT_PVT.csp_parts_tbl_typ1();
            OPEN parts_list(p_task_id, p_likelihood);
                LOOP
                    FETCH parts_list  INTO part_number, part_quantity , part_uom , l_ship_complet,l_revision , l_line_id;
                    EXIT WHEN parts_list % NOTFOUND;
                        --x_parts_list.extend;
                        loop_count := loop_count + 1;
                        x_parts_list(loop_count).item_id       :=  part_number ;
                        x_parts_list(loop_count).quantity      :=  part_quantity ;
                        x_parts_list(loop_count).Item_UOM      :=  part_uom;
                        x_parts_list(loop_count).ship_set_name :=  l_ship_complet ;
                        x_parts_list(loop_count).revision      :=  l_revision;
                        x_parts_list(loop_count).line_id       :=  l_line_id;
                END LOOP;
           CLOSE parts_list;
        EXCEPTION
        WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('CSP', 'CSP_UNEXPECTED_EXEC_ERRORS');
            FND_MESSAGE.SET_TOKEN('ROUTINE', l_api_name, FALSE);
            FND_MESSAGE.SET_TOKEN('SQLERRM', sqlerrm, FALSE);
            FND_MSG_PUB.ADD;
            fnd_msg_pub.count_and_get
              ( p_count => x_msg_count
              , p_data  => x_msg_data);
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        return;
  END GET_PARTS_LIST;
  PROCEDURE CHECK_LOCAl_INVENTORY(p_resource_org_subinv  IN   CSP_SCH_INT_PVT.CSP_RESOURCE_ORG_tbl_TYP
                                 ,p_parts_list          IN   CSP_SCH_INT_PVT.CSP_PARTS_TBL_TYP1
                                 ,p_trunk               IN  BOOLEAN
                                 ,x_unavailable_list    OUT NOCOPY  CSP_SCH_INT_PVT.CSP_UNAVAILABILITY_TBL_TYPE
                                 ,x_available_list      OUT NOCOPY  CSP_SCH_INT_PVT.CSP_AVAILABILITY_TBL_TYPE
                                 ,x_return_status       OUT NOCOPY  VARCHAR2
                                 ,x_msg_data            OUT NOCOPY  VARCHAR2
                                 ,x_msg_count           OUT NOCOPY  NUMBER) IS
   /* CURSOR reservation_check(org_id NUMBER, sub_inv_code VARCHAR2,item_id NUMBER)
    IS
    SELECT NVL((REQUIRED_QUANTITY-ORDERED_QUANTITY),0)
    FROM   CSP_REQUIREMENT_LINES
    WHERE  REQUIREMENT_HEADER_ID = (SELECT REQUIREMENT_HEADER_ID
                                    FROM   CSP_REQUIREMENT_HEADERS
                                    WHERE  OPEN_REQUIREMENT = 'Yes'
                                    AND    DESTINATION_ORGANIZATION_ID = org_id)
    AND   SOURCE_SUBINVENTORY =  sub_inv_code
    AND   INVENTORY_ITEM_ID = item_id
    AND   ORDER_LINE_ID IS NOT NULL ;*/

        CURSOR substitutes(item_id NUMBER,org_id NUMBER) IS
        SELECT mri.RELATED_ITEM_ID
        FROM   MTL_RELATED_ITEMS_VIEW mri, mtl_parameters mp
        WHERE  mp.organization_id = org_id
        AND    mri.INVENTORY_ITEM_ID = item_id
        AND    mri.RELATIONSHIP_TYPE_ID = 2
        AND    mri.ORGANIZATION_ID  = MP.MASTER_ORGANIZATION_ID;

    l_onhand            NUMBER;
    l_available         NUMBER;
    l_msg_data          VARCHAR2(2000);
    l_msg_count         NUMBER;
    l_return_status     VARCHAR2(128);
    l_rqoh              NUMBER;
    l_qr                NUMBER;
    l_qs                NUMBER;
    l_att               NUMBER;
    l_temp_reserv_quantity NUMBER;
    l_substitute_item  NUMBER;
    l_api_name varchar2(60) := 'CSP_SCH_INT_PVT.CHECK_LOCAl_INVENTORY';
   --- l_cumulative_att   NUMBER;
    l_supersede_items  CSP_SUPERSESSIONS_PVT.NUMBER_ARR;
    l_required_quantity NUMBER;
    l_alternate_parts CSP_SUPERSESSIONS_PVT.NUMBER_ARR;
    l_append     boolean := true;
    l_revision_controlled BOOLEAN := false;
    l_reservation_parts       CSP_SCH_INT_PVT.RESERVATION_REC_TYP;
    l_reservation_id NUMBER;
     l_res_ids CSP_SUPERSESSIONS_PVT.NUMBER_ARR;
  BEGIN
      savepoint csp_check_local_inv;
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      x_unavailable_list:=  CSP_SCH_INT_PVT.CSP_UNAVAILABILITY_TBL_TYPE();
      x_available_list  := CSP_SCH_INT_PVT.CSP_AVAILABILITY_TBL_TYPE();
      if l_res_ids.count > 0 THEN
        l_res_ids.delete;
      END IF;
          FOR I IN 1..p_resource_org_subinv.count LOOP
            FOR J IN 1..p_parts_list.count LOOP
                          l_required_quantity := 0;
               IF fnd_profile.value(name => 'CSP_INCL_ALTERNATES')= 'ALWAYS' or
                  fnd_profile.value(name => 'CSP_INCL_ALTERNATES')= 'SCHONLY'  THEN
                 if l_alternate_parts.count >0 THEN
                    l_alternate_parts.delete;
                 END IF;
                 if l_supersede_items.count > 0 THEN
                    l_supersede_items.DELETE;
                 END IF;
                CSP_SUPERSESSIONS_PVT.get_supersede_bilateral_items(p_inventory_item_id => p_parts_list(J).item_id
                                                    ,p_organization_id => p_resource_org_subinv(I).organization_id
                                                    ,x_supersede_items => l_supersede_items);
                l_alternate_parts := l_supersede_items;

                OPEN substitutes(p_parts_list(J).item_id, p_resource_org_subinv(I).organization_id);
                LOOP
                  FETCH substitutes INTO l_substitute_item;
                  EXIT WHEN substitutes % NOTFOUND;
                    l_append := true;
                    FOR I IN 1.. l_alternate_parts.count LOOP
                        if l_substitute_item =  l_alternate_parts(I) then
                           l_append := false;
                           exit;
                        end if;
                    END LOOP;
                        IF l_append THEN
                            l_alternate_parts(l_alternate_parts.count+1) := l_substitute_item;
                        END IF;
                    l_substitute_item := null;
                END LOOP;
                CLOSE substitutes;
                END IF;

               IF (fnd_profile.value(name => 'CSP_INCL_CAR_STOCK')= 'ALWAYS' or
                  fnd_profile.value(name => 'CSP_INCL_CAR_STOCK')= 'SCHONLY') and
                  nvl(p_trunk,TRUE) THEN
                l_att := 0;
                    IF p_parts_list(J).revision IS NOT NULL THEN
                        l_revision_controlled := TRUE;
                    END IF;
                    inv_quantity_tree_pub.clear_quantity_cache;
                inv_quantity_tree_pub.query_quantities(p_api_version_number => 1.0
                                                     , p_organization_id  => p_resource_org_subinv(I).organization_id
                                                     , p_inventory_item_id => p_parts_list(J).item_id
                                                     , p_subinventory_code => p_resource_org_subinv(I).sub_inv_code
                                                     , x_qoh     => l_onhand
                                                     , x_atr     => l_available
                                                     , p_init_msg_lst   => fnd_api.g_false
                                                     , p_tree_mode   => inv_quantity_tree_pvt.g_transaction_mode
                                                     , p_is_revision_control => l_revision_controlled
                                                     , p_is_lot_control  => NULL
                                                     , p_is_serial_control => NULL
                                                     , p_revision    =>  p_parts_list(J).revision
                                                     , p_lot_number   => NULL
                                                     , p_locator_id   => NULL
                                                     , x_rqoh     => l_rqoh
                                                     , x_qr     => l_qr
                                                     , x_qs     => l_qs
                                                     , x_att     => l_att
                                                     , x_return_status  => l_return_status
                                                     , x_msg_count   => l_msg_count
                                                     , x_msg_data    => l_msg_data
                                                     );
                IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    l_att := 0;
                END IF;
                    /*OPEN reservation_check(p_resource_org_subinv(I).organization_id, p_resource_org_subinv(I).sub_inv_code,p_parts_list(J).item_id);
                    LOOP
                        FETCH reservation_check INTO l_temp_reserv_quantity;
                        EXIT WHEN reservation_check% NOTFOUND;
                        l_att := l_att - l_temp_reserv_quantity ;
                     END LOOP;
                    CLOSE reservation_check;*/
                    IF l_att <= 0 THEN
                        l_att := 0;
                    ELSIF  l_att >=  p_parts_list(J).quantity THEN
                        x_available_list.extend;
                        x_available_list(x_available_list.count).resource_id := p_resource_org_subinv(I).resource_id;
                        x_available_list(x_available_list.count).resource_type := p_resource_org_subinv(I).resource_type;
                        x_available_list(x_available_list.count).organization_id   := p_resource_org_subinv(I).organization_id;
                        x_available_list(x_available_list.count).item_id   := p_parts_list(J).item_id ;
                        x_available_list(x_available_list.count).item_uom   := p_parts_list(J).item_uom ;
                        x_available_list(x_available_list.count).revision   := p_parts_list(J).revision ;
                        x_available_list(x_available_list.count).quantity  := p_parts_list(J).quantity  ;
                        x_available_list(x_available_list.count).source_org := p_resource_org_subinv(I).organization_id ;
                        x_available_list(x_available_list.count).sub_inventory := p_resource_org_subinv(I).sub_inv_code;
                        x_available_list(x_available_list.count).AVAILABLE_DATE  := SYSDATE;
                        x_available_list(x_available_list.count).line_id  := p_parts_list(J).line_id;
                        IF l_alternate_parts.count >0 THEN
                         l_reservation_id := NULL;
                            l_reservation_parts.need_by_date       := sysdate;
                            l_reservation_parts.organization_id    := x_available_list(x_available_list.count).source_org ;
                            l_reservation_parts.item_id            := x_available_list(x_available_list.count).item_id;
                            l_reservation_parts.item_uom_code      := x_available_list(x_available_list.count).item_uom ;
                            l_reservation_parts.quantity_needed    := x_available_list(x_available_list.count).quantity ;
                            l_reservation_parts.sub_inventory_code := x_available_list(x_available_list.count).sub_inventory;
                            l_reservation_parts.line_id            := x_available_list(x_available_list.count).line_id ;
                            l_reservation_parts.revision           :=  x_available_list(x_available_list.count).revision;
                            l_reservation_id := CSP_SCH_INT_PVT.CREATE_RESERVATION(l_reservation_parts,x_return_status,x_msg_data);

                         IF l_reservation_id <= 0 THEN
                            FND_MESSAGE.SET_NAME('CSP', 'CSP_SCH_COULD_NOT_RESERVE');
                            FND_MSG_PUB.ADD;
                            fnd_msg_pub.count_and_get
                                ( p_count => x_msg_count
                                , p_data  => x_msg_data);
                         else
                             l_res_ids(l_res_ids.count+1) := l_reservation_id;
                         END IF;
                        END IF;
                    ELSIF l_att <=  p_parts_list(J).quantity THEN
                        x_available_list.extend;
                        x_available_list(x_available_list.count).resource_id := p_resource_org_subinv(I).resource_id;
                        x_available_list(x_available_list.count).resource_type := p_resource_org_subinv(I).resource_type;
                        x_available_list(x_available_list.count).organization_id   := p_resource_org_subinv(I).organization_id;
                        x_available_list(x_available_list.count).item_id   := p_parts_list(J).item_id ;
                        x_available_list(x_available_list.count).item_uom   := p_parts_list(J).item_uom ;
                        x_available_list(x_available_list.count).revision   := p_parts_list(J).revision ;
                        x_available_list(x_available_list.count).quantity  := l_att ;
                        x_available_list(x_available_list.count).source_org := p_resource_org_subinv(I).organization_id ;
                        x_available_list(x_available_list.count).sub_inventory := p_resource_org_subinv(I).sub_inv_code;
                        x_available_list(x_available_list.count).AVAILABLE_DATE  := SYSDATE;
                        x_available_list(x_available_list.count).line_id  := p_parts_list(J).line_id;
                         IF l_alternate_parts.count >0 THEN
                            l_reservation_id := NULL;
                            l_reservation_parts.need_by_date       := sysdate;
                            l_reservation_parts.organization_id    := x_available_list(x_available_list.count).source_org ;
                            l_reservation_parts.item_id            := x_available_list(x_available_list.count).item_id;
                            l_reservation_parts.item_uom_code      := x_available_list(x_available_list.count).item_uom ;
                            l_reservation_parts.quantity_needed    := x_available_list(x_available_list.count).quantity ;
                            l_reservation_parts.sub_inventory_code := x_available_list(x_available_list.count).sub_inventory;
                            l_reservation_parts.line_id            := x_available_list(x_available_list.count).line_id ;
                            l_reservation_parts.revision           :=  x_available_list(x_available_list.count).revision;
                             l_reservation_id := CSP_SCH_INT_PVT.CREATE_RESERVATION(l_reservation_parts,x_return_status,x_msg_data);

                         IF l_reservation_id <= 0 THEN
                            FND_MESSAGE.SET_NAME('CSP', 'CSP_SCH_COULD_NOT_RESERVE');
                            FND_MSG_PUB.ADD;
                            fnd_msg_pub.count_and_get
                                ( p_count => x_msg_count
                                , p_data  => x_msg_data);
                          else
                             l_res_ids(l_res_ids.count+1) := l_reservation_id;
                         END IF;
                        END IF;
                    END IF;

                    IF l_att < p_parts_list(J).quantity THEN
                    l_required_quantity := p_parts_list(J).quantity - l_att;
                         FOR K IN 1..l_alternate_parts.count LOOP
                            l_onhand := 0;
                            l_available := 0;
                            l_rqoh := 0;
                            l_qr := 0;
                            l_qs := 0;
                            l_att := 0;
                            l_msg_count := 0;
                            inv_quantity_tree_pub.clear_quantity_cache;
                            inv_quantity_tree_pub.query_quantities(p_api_version_number => 1.0
                                                     , p_organization_id  => p_resource_org_subinv(I).organization_id
                                                     , p_inventory_item_id => l_alternate_parts(k)
                                                     , p_subinventory_code => p_resource_org_subinv(I).sub_inv_code
                                                     , x_qoh     => l_onhand
                                                     , x_atr     => l_available
                                                     , p_init_msg_lst   => fnd_api.g_false
                                                     , p_tree_mode   => inv_quantity_tree_pvt.g_transaction_mode
                                                     , p_is_revision_control => NULL
                                                     , p_is_lot_control  => NULL
                                                     , p_is_serial_control => NULL
                                                     , p_revision    =>  NULL
                                                     , p_lot_number   => NULL
                                                     , p_locator_id   => NULL
                                                     , x_rqoh     => l_rqoh
                                                     , x_qr     => l_qr
                                                     , x_qs     => l_qs
                                                     , x_att     => l_att
                                                     , x_return_status  => l_return_status
                                                     , x_msg_count   => l_msg_count
                                                     , x_msg_data    => l_msg_data
                                                     );

                            IF l_att <= 0 THEN
                                l_att := 0;
                            ELSIF  l_att >=  l_required_quantity THEN
                                x_available_list.extend;
                                x_available_list(x_available_list.count).resource_id := p_resource_org_subinv(I).resource_id;
                                x_available_list(x_available_list.count).resource_type := p_resource_org_subinv(I).resource_type;
                                x_available_list(x_available_list.count).organization_id   := p_resource_org_subinv(I).organization_id;
                                x_available_list(x_available_list.count).item_id   := l_alternate_parts(k) ;
                                x_available_list(x_available_list.count).item_uom   := p_parts_list(J).item_uom ;
                                x_available_list(x_available_list.count).revision   := p_parts_list(J).revision ;
                                x_available_list(x_available_list.count).quantity  := l_required_quantity ;
                                x_available_list(x_available_list.count).source_org := p_resource_org_subinv(I).organization_id ;
                                x_available_list(x_available_list.count).sub_inventory := p_resource_org_subinv(I).sub_inv_code;
                                x_available_list(x_available_list.count).AVAILABLE_DATE  := SYSDATE;
                                x_available_list(x_available_list.count).line_id  := p_parts_list(J).line_id;
                                IF l_alternate_parts.count >0 THEN
                         l_reservation_id := NULL;
                            l_reservation_parts.need_by_date       := sysdate;
                            l_reservation_parts.organization_id    := x_available_list(x_available_list.count).source_org ;
                            l_reservation_parts.item_id            := x_available_list(x_available_list.count).item_id;
                            l_reservation_parts.item_uom_code      := x_available_list(x_available_list.count).item_uom ;
                            l_reservation_parts.quantity_needed    := x_available_list(x_available_list.count).quantity ;
                            l_reservation_parts.sub_inventory_code := x_available_list(x_available_list.count).sub_inventory;
                            l_reservation_parts.line_id            := x_available_list(x_available_list.count).line_id ;
                            l_reservation_parts.revision           :=  x_available_list(x_available_list.count).revision;
                            l_reservation_id := CSP_SCH_INT_PVT.CREATE_RESERVATION(l_reservation_parts,x_return_status,x_msg_data);

                         IF l_reservation_id <= 0 THEN
                            FND_MESSAGE.SET_NAME('CSP', 'CSP_SCH_COULD_NOT_RESERVE');
                            FND_MSG_PUB.ADD;
                            fnd_msg_pub.count_and_get
                                ( p_count => x_msg_count
                                , p_data  => x_msg_data);
                          else
                             l_res_ids(l_res_ids.count+1) := l_reservation_id;
                         END IF;
                        END IF;
                                l_required_quantity := 0;
                                exit;
                            ELSIF l_att <  l_required_quantity THEN
                                x_available_list.extend;
                                x_available_list(x_available_list.count).resource_id := p_resource_org_subinv(I).resource_id;
                                x_available_list(x_available_list.count).resource_type := p_resource_org_subinv(I).resource_type;
                                x_available_list(x_available_list.count).organization_id   := p_resource_org_subinv(I).organization_id;
                                x_available_list(x_available_list.count).item_id   := l_alternate_parts(k) ;
                                x_available_list(x_available_list.count).item_uom   := p_parts_list(J).item_uom ;
                                x_available_list(x_available_list.count).revision   := p_parts_list(J).revision ;
                                x_available_list(x_available_list.count).quantity  := l_att ;
                                x_available_list(x_available_list.count).source_org := p_resource_org_subinv(I).organization_id ;
                                x_available_list(x_available_list.count).sub_inventory := p_resource_org_subinv(I).sub_inv_code;
                                x_available_list(x_available_list.count).AVAILABLE_DATE  := SYSDATE;
                                x_available_list(x_available_list.count).line_id  := p_parts_list(J).line_id;
                                IF l_alternate_parts.count >0 THEN
                         l_reservation_id := NULL;
                            l_reservation_parts.need_by_date       := sysdate;
                            l_reservation_parts.organization_id    := x_available_list(x_available_list.count).source_org ;
                            l_reservation_parts.item_id            := x_available_list(x_available_list.count).item_id;
                            l_reservation_parts.item_uom_code      := x_available_list(x_available_list.count).item_uom ;
                            l_reservation_parts.quantity_needed    := x_available_list(x_available_list.count).quantity ;
                            l_reservation_parts.sub_inventory_code := x_available_list(x_available_list.count).sub_inventory;
                            l_reservation_parts.line_id            := x_available_list(x_available_list.count).line_id ;
                            l_reservation_parts.revision           :=  x_available_list(x_available_list.count).revision;
                            l_reservation_id := CSP_SCH_INT_PVT.CREATE_RESERVATION(l_reservation_parts,x_return_status,x_msg_data);

                         IF l_reservation_id <= 0 THEN
                            FND_MESSAGE.SET_NAME('CSP', 'CSP_SCH_COULD_NOT_RESERVE');
                            FND_MSG_PUB.ADD;
                            fnd_msg_pub.count_and_get
                                ( p_count => x_msg_count
                                , p_data  => x_msg_data);
                           else
                             l_res_ids(l_res_ids.count+1) := l_reservation_id;
                         END IF;
                        END IF;
                            END IF;
                            l_required_quantity := l_required_quantity - l_att ;
                         END LOOP;
                    END IF;
                  ELSE
                    l_required_quantity := p_parts_list(J).quantity;
                  END IF;
                IF l_required_quantity > 0 THEN
                        x_unavailable_list.extend ;
                        x_unavailable_list(x_unavailable_list.count).resource_id
                                                                        := p_resource_org_subinv(I).resource_id;
                        x_unavailable_list(x_unavailable_list.count).resource_type
                                                                        := p_resource_org_subinv(I).resource_type;
                        x_unavailable_list(x_unavailable_list.count).organization_id   := p_resource_org_subinv(I).organization_id;
                        x_unavailable_list(x_unavailable_list.count).item_id   := p_parts_list(J).Item_id ;
                        x_unavailable_list(x_unavailable_list.count).quantity  := l_required_quantity;
                        x_unavailable_list(x_unavailable_list.count).item_UOM := p_parts_list(J).Item_UOM ;
                        x_unavailable_list(x_unavailable_list.count).revision := p_parts_list(J).revision   ;
                        x_unavailable_list(x_unavailable_list.count).ship_set_name := p_parts_list(J).ship_set_name;
                        x_unavailable_list(x_unavailable_list.count).line_id := p_parts_list(J).line_id;
                    FOR K IN 1..l_alternate_parts.count LOOP
                        x_unavailable_list.extend ;
                        x_unavailable_list(x_unavailable_list.count).resource_id
                                                                        := p_resource_org_subinv(I).resource_id;
                        x_unavailable_list(x_unavailable_list.count).resource_type
                                                                        := p_resource_org_subinv(I).resource_type;
                        x_unavailable_list(x_unavailable_list.count).organization_id   := p_resource_org_subinv(I).organization_id;
                        x_unavailable_list(x_unavailable_list.count).item_id   := l_alternate_parts(k);
                        x_unavailable_list(x_unavailable_list.count).quantity  := l_required_quantity;
                        x_unavailable_list(x_unavailable_list.count).item_UOM := p_parts_list(J).Item_UOM ;
                        x_unavailable_list(x_unavailable_list.count).revision := p_parts_list(J).revision ;
                        x_unavailable_list(x_unavailable_list.count).ship_set_name := p_parts_list(J).ship_set_name;
                        x_unavailable_list(x_unavailable_list.count).line_id := p_parts_list(J).line_id;
                    END LOOP;
                END IF;
                END LOOP;
            END LOOP;
             for i in 1..l_res_ids.count loop
                CSP_SCH_INT_PVT.DELETE_RESERVATION(l_res_ids(i),x_return_status,x_msg_data);
              end loop;
      EXCEPTION
        WHEN OTHERS THEN
            FND_MESSAGE.SET_NAME('CSP', 'CSP_UNEXPECTED_EXEC_ERRORS');
            FND_MESSAGE.SET_TOKEN('ROUTINE', l_api_name, FALSE);
            FND_MESSAGE.SET_TOKEN('SQLERRM', sqlerrm, FALSE);
            FND_MSG_PUB.ADD;
            fnd_msg_pub.count_and_get
              ( p_count => x_msg_count
              , p_data  => x_msg_data);
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            return;
  END  CHECK_LOCAl_INVENTORY;
  --hehxxx
   PROCEDURE SPARES_CHECK(p_unavailable_list       IN     CSP_SCH_INT_PVT.CSP_UNAVAILABILITY_TBL_TYPE
                         ,p_interval               IN     CSP_SCH_INT_PVT.csp_sch_interval_rec_typ
                         ,px_available_list        IN OUT NOCOPY CSP_SCH_INT_PVT.CSP_AVAILABILITY_TBL_TYPE
                         ,x_final_unavailable_list OUT NOCOPY    CSP_SCH_INT_PVT.CSP_UNAVAILABILITY_TBL_TYPE
                         ,x_return_status          OUT NOCOPY    VARCHAR2
                         ,x_msg_data               OUT NOCOPY    VARCHAR2
                         ,x_msg_count              OUT NOCOPY    NUMBER) is

    cursor c_available (p_inventory_item_id number, p_quantity number) is
    select organization_id,
           subinventory_code,
           shipping_date,
           sum(supplied_quantity)
    from   csp_available_parts_temp capt
    where  capt.required_item_id = p_inventory_item_id
    and    capt.supplied_quantity >= p_quantity
    and    capt.arrival_date <= p_interval.latest_time
    group by organization_id, subinventory_code, shipping_date, shipping_cost
    order by shipping_cost asc;

    cursor c_ship_to(p_resource_type varchar2,p_resource_id number) is
    select inv_loc_id,
           site_loc_id
    from   csp_rs_ship_to_addresses_all_v
    where  resource_type = p_resource_type
    and    resource_id = p_resource_id
    and    primary_flag = 'Y';

    l_total_supplied number := 0;
    l_old_item number;
    l_hz_location_id number;
    l_hr_location_id number;

    p_required_parts csp_part_search_pvt.required_parts_tbl;
    p_search_params apps.csp_part_search_pvt.search_params_rec;
    l_search_method     varchar2(30) := fnd_profile.value('CSP_PART_SEARCH_METHOD_SCHEDULER');
    l_incl_alternates   varchar2(30) := fnd_profile.value('CSP_INCL_ALTERNATES');
    l_alternates        boolean := FALSE;

    l_organization_id   number;
    l_supplied_quantity number;
    l_subinventory_code varchar2(30);
    l_shipping_date     date;

   begin
     if nvl(l_incl_alternates,'NEVER') in ('ALWAYS','SCHONLY') then
       l_alternates := TRUE;
     else
       l_alternates := FALSE;
     end if;
   x_final_unavailable_list := CSP_SCH_INT_PVT.CSP_UNAVAILABILITY_TBL_TYPE();
     for i in 1..p_unavailable_list.count loop
       open  c_ship_to(p_unavailable_list(i).resource_type,p_unavailable_list(i).resource_id);
       fetch c_ship_to into l_hr_location_id,l_hz_location_id;
       close c_ship_to;
       p_search_params.search_method := l_search_method;
       p_search_params.my_inventory := false;
       p_search_params.unmanned_warehouses := false;
       p_search_params.technicians := false;
       p_search_params.manned_warehouses := true;
       p_search_params.resource_type := p_unavailable_list(i).resource_type;
       p_search_params.resource_id := p_unavailable_list(i).resource_id;
       p_search_params.need_by_date := p_interval.latest_time;
       p_search_params.to_hz_location_id := l_hz_location_id;
       p_search_params.to_location_id := l_hr_location_id;
       p_search_params.include_closed := true;
       p_search_params.include_alternates := l_alternates;
       p_search_params.called_from := 'SCHEDULER';

       p_required_parts.delete();
       p_required_parts(1).inventory_item_id := p_unavailable_list(i).item_id;
       p_required_parts(1).quantity := p_unavailable_list(i).quantity;

                if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                                  'csp.plsql.CSP_SCH_INT_PVT.SPARES_CHECK',
                                                  'Before calling csp_part_search_pvt.search...');
                end if;

       csp_part_search_pvt.search(
         p_required_parts => p_required_parts,
         p_search_params  => p_search_params,
         x_return_status  => x_return_status,
         x_msg_data       => x_msg_data,
         x_msg_count      => x_msg_count
       );

       open  c_available(p_unavailable_list(i).item_id,
                         p_unavailable_list(i).quantity);
       fetch c_available into l_organization_id,
                              l_subinventory_code,
                              l_shipping_date,
                              l_supplied_quantity;
       close c_available;

                if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                                  'csp.plsql.CSP_SCH_INT_PVT.SPARES_CHECK',
                                                  'After calling csp_part_search_pvt.search...');
                  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                                  'csp.plsql.CSP_SCH_INT_PVT.SPARES_CHECK',
                                                  'l_organization_id=' || l_organization_id);
                  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                                  'csp.plsql.CSP_SCH_INT_PVT.SPARES_CHECK',
                                                  'l_subinventory_code=' || l_subinventory_code);
                  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                                  'csp.plsql.CSP_SCH_INT_PVT.SPARES_CHECK',
                                                  'l_shipping_date=' || to_char(l_shipping_date, 'DD-MON-RRRR HH24:MI:SS'));
                  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                                  'csp.plsql.CSP_SCH_INT_PVT.SPARES_CHECK',
                                                  'l_supplied_quantity=' || l_supplied_quantity);
                end if;

       if l_organization_id is not null then
         px_available_list.extend;
         px_available_list(px_available_list.count).resource_id        := p_unavailable_list(i).resource_id ;
         px_available_list(px_available_list.count).resource_type      := p_unavailable_list(i).resource_type;
         px_available_list(px_available_list.count).organization_id    := p_unavailable_list(i).organization_id;
         px_available_list(px_available_list.count).item_id            := p_unavailable_list(i).item_id;
         px_available_list(px_available_list.count).item_uom           := p_unavailable_list(i).item_uom;
         px_available_list(px_available_list.count).quantity           := p_unavailable_list(i).quantity;
         px_available_list(px_available_list.count).source_org         := l_organization_id;
         px_available_list(px_available_list.count).sub_inventory      := l_subinventory_code;
         px_available_list(px_available_list.count).available_date     := l_shipping_date;
         px_available_list(px_available_list.count).available_quantity := l_supplied_quantity;
         px_available_list(px_available_list.count).revision           := null;
         px_available_list(px_available_list.count).item_type          := p_unavailable_list(i).item_type;
         px_available_list(px_available_list.count).line_id            := p_unavailable_list(i).line_id;
       else
         x_final_unavailable_list.extend;
         x_final_unavailable_list(x_final_unavailable_list.count).resource_id     := p_unavailable_list(i).resource_id;
         x_final_unavailable_list(x_final_unavailable_list.count).resource_type   := p_unavailable_list(i).resource_type ;
         x_final_unavailable_list(x_final_unavailable_list.count).organization_id := p_unavailable_list(i).organization_id;
         x_final_unavailable_list(x_final_unavailable_list.count).item_id         := p_unavailable_list(i).item_id;
         x_final_unavailable_list(x_final_unavailable_list.count).quantity        := p_unavailable_list(i).quantity;
         x_final_unavailable_list(x_final_unavailable_list.count).item_UOM        := p_unavailable_list(i).item_uom;
         x_final_unavailable_list(x_final_unavailable_list.count).revision        := p_unavailable_list(i).revision;
         x_final_unavailable_list(x_final_unavailable_list.count).item_type       := p_unavailable_list(i).item_type;
         x_final_unavailable_list(x_final_unavailable_list.count).line_id         := p_unavailable_list(i).line_id;
       end if;
       delete from csp_available_parts_temp;
       delete from csp_required_parts_temp;
     end loop;
   end;

   PROCEDURE SPARES_CHECK2(
               p_resources     IN  CSP_SCH_INT_PVT.csp_sch_resource_tbl_typ,
               p_task_id       in     number,
               p_need_by_date  in     date,
               p_trunk              IN  BOOLEAN,
               p_warehouse          IN  BOOLEAN,
               p_mandatory          IN  BOOLEAN,
               x_options    OUT NOCOPY  CSP_SCH_INT_PVT.csp_sch_options_tbl_typ,
               x_return_status          OUT NOCOPY    VARCHAR2,
               x_msg_data               OUT NOCOPY    VARCHAR2,
               x_msg_count              OUT NOCOPY    NUMBER) is

    cursor c_requirement_header is
    select crh.requirement_header_id,
           decode(crh.address_type,'R',null,'S',null,crh.ship_to_location_id),
           decode(crh.address_type,'R',null,'S',null,hps.location_id)
    from   csp_requirement_headers crh,
           hz_cust_site_uses_all hcsua,
           po_location_associations_all plaa,
           hz_cust_acct_sites_all hcasa,
           hz_party_sites hps
    where  crh.task_id = p_task_id
    and    plaa.location_id = crh.ship_to_location_id
    and    hcsua.site_use_id = plaa.site_use_id
    and    hcsua.site_use_code = 'SHIP_TO'
    and    hcsua.status = 'A'
    and    hcasa.cust_acct_site_id = hcsua.cust_acct_site_id
    and    hps.party_site_id = hcasa.party_site_id;

    cursor c_requirement_header_id is
    select crh.requirement_header_id
    from   csp_requirement_headers crh
    where  crh.task_id = p_task_id;

    cursor c_parts is
    select inventory_item_id,
           quantity
    from   csp_required_parts_temp
    where  item_type = 'BASE';

    cursor c_available(p_inventory_item_id number) is
    select distinct supplied_quantity,
           arrival_date,
           shipping_cost,
           organization_id,
           subinventory_code,
           shipping_method,
           source_type_code,
           supplied_item_id,
           distance
    from   csp_available_parts_temp
    where  required_item_id = p_inventory_item_id
    and    nvl(open_or_closed,'-1') <> 'USED'
    order by shipping_cost,distance,organization_id,subinventory_code;

    cursor c_sr_org_id is
    select cia.org_id
    from   cs_incidents_all cia,
           jtf_tasks_b jtb
    where  jtb.task_id = p_task_id
    and    jtb.source_object_type_code = 'SR'
    and    cia.incident_id = jtb.source_object_id;

    cursor c_primary_ship_to(p_resource_type varchar2,
                             p_resource_id number) is
    select crstaav.ship_to_location_id,
           crstaav.site_loc_id,
           hcasa.org_id
    from   csp_rs_ship_to_addresses_all_v crstaav,
           hz_cust_acct_sites_all hcasa
    where  crstaav.resource_type = p_resource_type
    and    crstaav.resource_id = p_resource_id
    and    crstaav.primary_flag = 'Y'
    and    hcasa.cust_acct_site_id = crstaav.cust_acct_site_id;

    l_requirement_header_id number;
    l_ship_to_location_id   number := null;
    l_hz_to_location_id     number := null;
    l_primary_ship_to       number := null;
    l_org_id                number := null;
    l_sr_org_id             number := null;
    p_required_parts csp_part_search_pvt.required_parts_tbl;
    p_search_params apps.csp_part_search_pvt.search_params_rec;
    l_search_method     varchar2(30) := fnd_profile.value('CSP_PART_SEARCH_METHOD_SCHEDULER');
    l_incl_alternates   varchar2(30) := fnd_profile.value('CSP_INCL_ALTERNATES');
    l_alternates        boolean := FALSE;
    l_choose_option     boolean := FALSE;

    l_organization_id        number;
    l_supplied_quantity      number;
    l_subinventory_code      varchar2(30);
    l_shipping_date          date;
    l_start_time             date := sysdate;
    l_missing_parts          number :=0;
    l_total_missing_parts    number := 0;
    l_transfer_cost          number := 0;
    l_total_parts            number := 0;
    l_prev_organization_id   number := 0;
    l_prev_subinventory_code varchar2(10) := null;
    l_available              varchar2(1) := 'N';
    l_src_warehouse varchar2(4000) := null;
    l_ship_method varchar2(4000) := null;
    l_distance_str varchar2(4000) := null;
    l_src_org_code varchar2(3) := null;
    l_distance_uom varchar2(20):= fnd_profile.value('CSFW_DEFAULT_DISTANCE_UNIT');
    l_dist_temp_str varchar2(10);
    l_ship_method_meaning varchar2(1000);

   begin
     x_options := CSP_SCH_INT_PVT.csp_sch_options_tbl_typ();

     open  c_requirement_header;
     fetch c_requirement_header into l_requirement_header_id,
                                     l_ship_to_location_id,
                                     l_hz_to_location_id;
     close c_requirement_header;
     if l_requirement_header_id is null then
       open  c_requirement_header_id;
       fetch c_requirement_header_id into l_requirement_header_id;
       close c_requirement_header_id;
     end if;

     log('spares_check2','l_requirement_header_id:'||l_requirement_header_id);
     log('spares_check2','l_ship_to_location_id:'||l_ship_to_location_id);
     if nvl(l_incl_alternates,'NEVER') in ('ALWAYS','SCHONLY') then
       l_alternates := TRUE;
     else
       l_alternates := FALSE;
     end if;
     if l_ship_to_location_id is not null and p_warehouse then
       delete from csp_available_parts_temp;
       delete from csp_required_parts_temp;
       if p_warehouse then
         p_search_params.search_method := l_search_method;
         p_search_params.my_inventory := false;
         p_search_params.unmanned_warehouses := false;
         p_search_params.resource_type := p_resources(1).resource_type;
         p_search_params.resource_id := p_resources(1).resource_id;
         p_search_params.technicians := false;
         p_search_params.manned_warehouses := p_warehouse;
         p_search_params.need_by_date := p_need_by_date;
         p_search_params.to_location_id := l_ship_to_location_id;
         p_search_params.to_hz_location_id := l_hz_to_location_id;
         p_search_params.include_closed := true;
         p_search_params.include_alternates := l_alternates;
         p_search_params.requirement_header_id := l_requirement_header_id;
         p_search_params.called_from := 'SCHEDULER';

         csp_part_search_pvt.search(
             p_required_parts => p_required_parts,
             p_search_params  => p_search_params,
             x_return_status  => x_return_status,
             x_msg_data       => x_msg_data,
             x_msg_count      => x_msg_count);
       end if;
     end if;
     log('spares_check2','p_resources.count:'||p_resources.count);
     if p_resources.count = 1 then
         l_choose_option := TRUE;
       log('spares_check2','l_choose_option = TRUE');
     end if;

     for i in 1..p_resources.count LOOP
       log('spares_check2','Looping resources. ResourceID:'||p_resources(i).resource_id);
       log('spares_check2','l_ship_to_location_id:'||l_ship_to_location_id);
           l_src_warehouse := null;
           l_ship_method := null;
           l_distance_str := null;
           l_src_org_code := null;
           l_dist_temp_str := null;
           l_ship_method_meaning := null;

       if p_warehouse then
         log('spares_check2','p_warehouse=TRUE');
         l_primary_ship_to := l_ship_to_location_id;
         if l_ship_to_location_id is null then
           log('spares_check2','l_ship_to_location_id is null');
           open  c_sr_org_id;
           fetch c_sr_org_id into l_sr_org_id;
           close c_sr_org_id;
           for cr in c_primary_ship_to(p_resources(i).resource_type,
                                       p_resources(i).resource_id) loop
             l_primary_ship_to := cr.ship_to_location_id;
             l_hz_to_location_id := cr.site_loc_id;
             l_org_id := cr.org_id;
             log('spares_check2','l_org_id:'||l_org_id);
             log('spares_check2','l_sr_org_id:'||l_sr_org_id);
             log('spares_check2','l_primary_ship_to:'||l_primary_ship_to);
             log('spares_check2','l_hz_to_location_id:'||l_hz_to_location_id);
             if l_org_id = l_sr_org_id then
               exit;
             end if;
           end loop;
         delete from csp_available_parts_temp;
         delete from csp_required_parts_temp;
         p_search_params.search_method := l_search_method;
         p_search_params.my_inventory := false;
         p_search_params.unmanned_warehouses := false;
         p_search_params.resource_type := p_resources(i).resource_type;
         p_search_params.resource_id := p_resources(i).resource_id;
         p_search_params.technicians := false;
         p_search_params.manned_warehouses := p_warehouse;
         p_search_params.need_by_date := p_need_by_date;
         p_search_params.to_location_id := l_primary_ship_to;
         p_search_params.to_hz_location_id := l_hz_to_location_id;
         p_search_params.include_closed := true;
         p_search_params.include_alternates := l_alternates;
         p_search_params.requirement_header_id := l_requirement_header_id;
         p_search_params.called_from := 'SCHEDULER';

         csp_part_search_pvt.search(
             p_required_parts => p_required_parts,
             p_search_params  => p_search_params,
             x_return_status  => x_return_status,
             x_msg_data       => x_msg_data,
             x_msg_count      => x_msg_count);
         end if;
       end if;

       if p_trunk then
         begin
           delete from csp_available_parts_temp
           where source_type_code in ('MYSELF','DEDICATED');
           exception when others then null;
         end;
         --dbms_output.put_line('ResourceTYPE:'||p_resources(i).resource_type);
         --dbms_output.put_line('ResourceID:'||p_resources(i).resource_id);
         p_search_params.search_method := l_search_method;
         p_search_params.my_inventory := p_trunk;
         p_search_params.unmanned_warehouses := false;
         p_search_params.resource_type := p_resources(i).resource_type;
         p_search_params.resource_id := p_resources(i).resource_id;
         p_search_params.technicians := false;
         p_search_params.manned_warehouses := false;
         p_search_params.need_by_date := p_need_by_date;
         p_search_params.to_location_id := nvl(l_ship_to_location_id,
                                               l_primary_ship_to);
         p_search_params.to_hz_location_id := l_hz_to_location_id;
         p_search_params.include_closed := true;
         p_search_params.include_alternates := l_alternates;
         p_search_params.called_from := 'SCHEDULER';
         if not p_warehouse then
           delete from csp_required_parts_temp;
           p_search_params.requirement_header_id := l_requirement_header_id;
         end if;
         csp_part_search_pvt.search(
           p_required_parts => p_required_parts,
           p_search_params  => p_search_params,
           x_return_status  => x_return_status,
           x_msg_data       => x_msg_data,
           x_msg_count      => x_msg_count);
       end if;

       l_transfer_cost := 0;
       l_total_parts := 0;
       l_start_time := sysdate;
       l_total_missing_parts := 0;
       for cp in c_parts loop
         log('spares_check2','item_id:'||cp.inventory_item_id);
         log('spares_check2','quantity:'||cp.quantity);
         l_missing_parts := cp.quantity;
         for ca in c_available(cp.inventory_item_id) loop
           log('spares_check2','l_missing_parts:'||l_missing_parts);
           log('spares_check2','organization_id:'||ca.organization_id);
           log('spares_check2','shipping_method:'||ca.shipping_method);
           log('spares_check2','source_type_code:'||ca.source_type_code);
           log('spares_check2','shipping_cost:'||ca.shipping_cost);
           log('spares_check2','distance:'||ca.distance);

           if l_missing_parts > 0 then
             if ca.organization_id <> l_prev_organization_id or
                nvl(ca.subinventory_code,'-1') <> nvl(l_prev_subinventory_code,'-1') then
               l_transfer_cost := l_transfer_cost + ca.shipping_cost;

               select organization_code into l_src_org_code
                    from mtl_parameters where organization_id = ca.organization_id;

               log('spares_check2','l_src_org_code:'||l_src_org_code);
               log('spares_check2','subinventory_code:'||ca.subinventory_code);

               if l_src_warehouse is null then
                    l_src_warehouse := l_src_org_code;
               else
                    l_src_warehouse := l_src_warehouse || ',' || l_src_org_code;
               end if;
               if ca.subinventory_code is not null then
                    l_src_warehouse := l_src_warehouse || '.' || ca.subinventory_code;
               end if;
               log('spares_check2','l_src_warehouse:'||l_src_warehouse);

                                if ca.shipping_method is not null then
                                        SELECT meaning
                                        into l_ship_method_meaning
                                        FROM fnd_lookup_values_vl
                                        WHERE lookup_type = 'SHIP_METHOD'
                                        AND lookup_code   = ca.shipping_method;
                                end if;

               if l_ship_method is null then
                    l_ship_method := nvl(l_ship_method_meaning, '-');
               else
                    l_ship_method := l_ship_method || ',' || nvl(l_ship_method_meaning, '-');
               end if;
               log('spares_check2','l_ship_method:'||l_ship_method);

               if ca.distance is null then
                    l_dist_temp_str := '-';
               else
                    l_dist_temp_str := to_char(ca.distance);
               end if;
               if l_distance_str is null then
                    l_distance_str := l_dist_temp_str;
               else
                    l_distance_str := l_distance_str || '$' || l_dist_temp_str;
               end if;
               if l_dist_temp_str <> '-' then
                    l_distance_str := l_distance_str || ' ' || l_distance_uom;
               end if;
               log('spares_check2','l_distance_str:'||l_distance_str);

             end if;
             log('spares_check2','l_transfer_cost:'||l_transfer_cost);
             l_start_time := greatest(l_start_time,ca.arrival_date);
             log('spares_check2','l_start_time:'||to_char(l_start_time,'dd-mon-yyyy hh24:mi'));
             if l_choose_option then
               log('spares_check2','update supplied quantity of capt');
               update csp_available_parts_temp
               set    supplied_quantity = least(supplied_quantity,l_missing_parts),
                      open_or_closed = 'USED'
               where  organization_id = ca.organization_id
               and    nvl(subinventory_code,'-1') = nvl(ca.subinventory_code,'-1')
               and    supplied_item_id = ca.supplied_item_id
               and    required_item_id = cp.inventory_item_id
               and    nvl(open_or_closed,'-1') <> 'USED'
               and    rownum = 1;
               log('spares_check2','Records updated:'||sql%rowcount);
             end if;
             l_missing_parts := greatest(l_missing_parts - ca.supplied_quantity,0);
             log('spares_check2','l_missing_parts:'||l_missing_parts);
           elsif l_missing_parts = 0 and l_choose_option then
             delete from csp_available_parts_temp
             where organization_id = ca.organization_id
             and   nvl(subinventory_code,'-1') = nvl(ca.subinventory_code,'-1')
             and   supplied_item_id = ca.supplied_item_id
             and   required_item_id = cp.inventory_item_id
             and   rownum = 1;
             log('spares_check2','Records deleted:'||sql%rowcount);
           elsif l_missing_parts = 0 then
             exit;
           end if;
           l_prev_organization_id := ca.organization_id;
           l_prev_subinventory_code := ca.subinventory_code;
         end loop;
         l_prev_organization_id := 0;
         l_prev_subinventory_code := null;
         l_total_missing_parts := l_total_missing_parts + l_missing_parts;
         l_total_parts := l_total_parts + cp.quantity - l_missing_parts;
       end loop;
       if l_total_missing_parts > 0 then
         l_transfer_cost := -1;
         l_start_time := null;
       end if;
       if l_total_missing_parts = 0 then
         l_available := 'Y';
       end if;
         log('spares_check2','l_total_parts:'||l_total_parts);
       if l_total_missing_parts = 0 or (l_total_missing_parts > 0 and not p_mandatory) then
         x_options.extend;
         x_options(x_options.count).resource_id   := p_resources(i).resource_id;
         x_options(x_options.count).resource_type := p_resources(i).resource_type;
         x_options(x_options.count).start_time    := l_start_time;
         x_options(x_options.count).transfer_cost := l_transfer_cost;--null;
         x_options(x_options.count).missing_parts := l_total_missing_parts;
         x_options(x_options.count).available_parts := l_total_parts;
         x_options(x_options.count).src_warehouse := l_src_warehouse;
         x_options(x_options.count).ship_method := l_ship_method;
         x_options(x_options.count).distance_str := l_distance_str;
       end if;
       log('spares_check2','resource_id:'||p_resources(i).resource_id);
       log('spares_check2','l_transfer_cost:'||l_transfer_cost);
       /*elsif l_total_missing_parts = 0 or p_mandatory then

         x_options.extend;
         x_options(x_options.count).resource_id   := p_resources(i).resource_id;
         x_options(x_options.count).resource_type := p_resources(i).resource_type;
         x_options(x_options.count).start_time    := l_start_time;
         x_options(x_options.count).transfer_cost := l_transfer_cost;
         x_options(x_options.count).missing_parts := l_total_missing_parts;
         x_options(x_options.count).available_parts := l_total_parts;
         log('spares_check2','resource_id:'||p_resources(i).resource_id);
         log('spares_check2','l_transfer_cost:'||l_transfer_cost);
       end if;*/
     end loop;
     if p_mandatory and l_available <> 'Y' then
       x_return_status := fnd_api.g_ret_sts_error;
       FND_MESSAGE.SET_NAME('CSP', 'CSP_SCH_NO_PARTS');
       FND_MSG_PUB.ADD;
       fnd_msg_pub.count_and_get
         ( p_count => x_msg_count
         , p_data  => x_msg_data);
     end if;
   end;

PROCEDURE DO_ATP_CHECK(p_unavailable_list         IN     CSP_SCH_INT_PVT.CSP_UNAVAILABILITY_TBL_TYPE
                          ,p_interval               IN     CSP_SCH_INT_PVT.csp_sch_interval_rec_typ
                          ,px_available_list        IN OUT NOCOPY CSP_SCH_INT_PVT.CSP_AVAILABILITY_TBL_TYPE
                          ,x_final_unavailable_list OUT NOCOPY    CSP_SCH_INT_PVT.CSP_UNAVAILABILITY_TBL_TYPE
                          ,x_return_status          OUT NOCOPY    VARCHAR2
                          ,x_msg_data               OUT NOCOPY    VARCHAR2
                          ,x_msg_count              OUT NOCOPY    NUMBER) IS
        CURSOR instance IS
        SELECT instance_id
        FROM   mrp_ap_apps_instances;

        CURSOR  error_message(c_errro_code number) IS
        select  meaning
        from    mfg_lookups
        where   lookup_type = 'MTL_DEMAND_INTERFACE_ERRORS'
        and    lookup_code = c_errro_code;

        CURSOR  get_item_segments(c_item_id number,c_organization_id number) IS
        select  distinct(CONCATENATED_SEGMENTS)
        from    mtl_system_items_b_kfv
        where   inventory_item_id = c_item_id
        and     organization_id = cs_std.get_item_valdn_orgzn_id;

        CURSOR check_buy_from(c_item_id number,c_assignment_id number, c_organization_id number)
        IS
       /* SELECT vendor_id, vendor_site_id
        FROM  mrp_sources_v
        where assignment_set_id = c_assignment_id
        and   inventory_item_id = c_item_id
        and   organization_id  = c_organization_id
        and   source_type = 3;*/
       Select 'Y'
       from MRP_ITEM_SOURCING_LEVELS_V  misl
       where misl.organization_id = c_organization_id
       and misl.assignment_set_id =c_assignment_id
       and inventory_item_id = c_item_id
       and SOURCE_TYPE       = 3
       and sourcing_level = (select min(sourcing_level) from MRP_ITEM_SOURCING_LEVELS_V
                             where organization_id = c_organization_id
                             and assignment_set_id = c_assignment_id
                             and inventory_item_id = c_item_id
                             and sourcing_level not in (2,9));

        l_atp_rec            mrp_atp_pub.atp_rec_typ;
        l_atp_rec_out        mrp_atp_pub.atp_rec_typ;
        l_atp_supply_demand  mrp_atp_pub.atp_supply_demand_typ;
        l_atp_period         mrp_atp_pub.atp_period_typ;
        l_atp_details        mrp_atp_pub.atp_details_typ;
        l_mrp_database_link  VARCHAR2(128);
        l_statement          VARCHAR2(500);
        l_session_id         NUMBER;
        l_return_status      VARCHAR2(128);
     --   x_msg_data           VARCHAR2(2000);
     --   x_msg_count          NUMBER;
        l_msg                varchar2(2000);
        l_ship_complete_profile VARCHAR2(3);
        l_instance_id        NUMBER;
        l_api_name           VARCHAR2(60) := 'CSP_SCH_INT_PVT.DO_ATP_CHECK' ;
        l_message            varchar2(2000);
        l_item_segments      varchar2(1000);
        l_error              BOOLEAN := FALSE;
        dbug_variable1    NUMBER;
        l_calling_module NUMBER := NULL;
        l_buy_from varchar2(1);
        l_assignment_set_id NUMBER;
        l_unavailable varchar2(1);
    BEGIN
        log('do_atp_check', 'Begin');
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        x_final_unavailable_list := CSP_SCH_INT_PVT.CSP_UNAVAILABILITY_TBL_TYPE();
                OPEN instance;
                FETCH instance INTO l_instance_id;
                CLOSE instance;
                log('do_atp_check', 'l_instance_id: '||l_instance_id);
            l_mrp_database_link := fnd_profile.value(name => 'MRP_ATP_DATABASE_LINK');
            log('do_atp_check', 'l_mrp_database_link: '||l_mrp_database_link);
            If l_mrp_database_link IS NULL Then
                Select MRP_ATP_SCHEDULE_TEMP_S.NextVal
                Into   l_session_id
                From   Dual;
                l_calling_module := 724;
             Else
                 get_session_id(p_database_link => l_mrp_database_link,
                                x_sesssion_id => l_session_id);
                l_calling_module := NULL;
             End If;
         log('do_atp_check', 'l_calling_module: '||l_calling_module);
         log('do_atp_check', 'begin p_unavailable_list loop. count: '||p_unavailable_list.count);
         FOR I in 1..p_unavailable_list.count LOOP
                    log('do_atp_check', 'calling msc_satp_func.extend_atp');
                     msc_satp_func.extend_atp(l_atp_rec,x_return_status,1);
                    log('do_atp_check', 'after msc_satp_func.extend_atp');
                    log('do_atp_check', 'x_return_status: '||x_return_status);
                    l_atp_rec.Insert_Flag(I) := 1;
                    l_atp_rec.inventory_item_id(I) := p_unavailable_list(I).item_id;
                    l_atp_rec.quantity_ordered(I) := p_unavailable_list(I).quantity;
                    l_atp_rec.quantity_uom(I) :=  p_unavailable_list(I).Item_UOM;
                    l_atp_rec.calling_module(I) := l_calling_module;  ---- 724
                    l_atp_rec.action(I) := 100 ;
                    l_atp_rec.Instance_Id(I)  := l_instance_id ;  ----- (for srp it is 1);
                    IF p_interval.latest_time IS NOT NULL THEN
                       l_atp_rec.latest_acceptable_date(I)  := p_interval.latest_time ;
                    END IF;

                    --l_atp_rec.latest_acceptable_date(I) := p_interval.latest_time;
                    l_atp_rec.Requested_Ship_Date(I) := sysdate ; --'03-MAY-2002' ;
                    l_atp_rec.Organization_id(I) := p_unavailable_list(I).organization_id;
                    l_atp_rec.Identifier(I):= p_unavailable_list(I).resource_id + I ;
                    l_atp_rec.Scenario_Id(I) := 1;
                    l_ship_complete_profile := fnd_profile.value(name => 'CSP_SHIP_COMPLETE');
                    IF l_ship_complete_profile ='Y' THEN
                        IF g_schedular_call = 'Y' THEN
                            l_atp_rec.ship_set_name(I) := to_char(p_unavailable_list(I).resource_id);
                        ELSE
                            l_atp_rec.ship_set_name(I) :=  p_unavailable_list(I).ship_set_name;
                        END IF;
                    ELSE
                            l_atp_rec.ship_set_name(I) :=  p_unavailable_list(I).ship_set_name;
                    END IF;
            END LOOP;
         savepoint csp_msc_atp_check;
            log('do_atp_check', 'calling MRP_ATP_PUB.CALL_ATP');
            MRP_ATP_PUB.CALL_ATP(l_session_id,
                                           l_atp_rec,
                                           l_atp_rec_out,
                                           l_atp_supply_demand,
                                           l_atp_period,
                                           l_atp_details,
                                           x_return_status,
                                           x_msg_data,
                                           x_msg_count);
            log('do_atp_check', 'after MRP_ATP_PUB.CALL_ATP');
            log('do_atp_check', 'x_return_status: '||x_return_status);
            log('do_atp_check', 'x_msg_data: '||x_msg_data);
            log('do_atp_check', 'x_msg_count: '||x_msg_count);
            l_msg := FND_MSG_PUB.Get(1,FND_API.G_FALSE) ;

            rollback to csp_msc_atp_check;
        IF x_return_status = FND_API.G_RET_STS_SUCCESS  THEN
                l_unavailable := 'Y';
                log('do_atp_check', 'begin l_atp_rec_out.Inventory_Item_Id loop. count: '||l_atp_rec_out.Inventory_Item_Id.count);
                FOR I IN 1..l_atp_rec_out.Inventory_Item_Id.count LOOP
                    log('do_atp_check', 'l_atp_rec_out.Error_Code('||I||'): '||l_atp_rec_out.Error_Code(I));
                    IF  (l_atp_rec_out.Error_Code(I) <> 0 and l_atp_rec_out.Error_Code(I) <> 150  ) THEN
                        l_assignment_set_id := FND_PROFILE.value(name => 'MRP_ATP_ASSIGN_SET');
                        log('do_atp_check', 'l_assignment_set_id: '||l_assignment_set_id);
                        OPEN check_buy_from(l_atp_rec.Inventory_Item_Id(I),l_assignment_set_id, l_atp_rec.Organization_id(I));
                        FETCH check_buy_from INTO l_buy_from;
                        CLOSE check_buy_from;
                       log('do_atp_check', 'g_schedular_call: '||g_schedular_call);
                       log('do_atp_check', 'l_buy_from: '||l_buy_from);
                       log('do_atp_check', 'l_atp_rec_out.Error_Code('||I||'): '||l_atp_rec_out.Error_Code(I));
                       IF   g_schedular_call = 'N' AND l_buy_from = 'Y' THEN
                            IF (nvl(l_atp_rec_out.Error_Code(I),0) <> 0  and l_atp_rec_out.Error_Code(I) <> 52 and l_atp_rec_out.Error_Code(I) <>53) THEN
                             IF not l_error then
                                OPEN error_message(23);
                                FETCH error_message INTO l_message;
                                CLOSE error_message;

                                FND_MESSAGE.SET_NAME('CSP', 'CSP_ATP');
                                FND_MESSAGE.SET_TOKEN('ERROR', l_message, FALSE);
                                FND_MSG_PUB.ADD;
                                fnd_msg_pub.count_and_get
                                    ( p_count => x_msg_count
                                    , p_data  => x_msg_data);

                             END IF;
                            x_return_status := FND_API.G_RET_STS_ERROR;
                            OPEN error_message(l_atp_rec_out.Error_Code(I));
                            FETCH error_message INTO l_message;
                            CLOSE error_message;
                             l_item_segments := null;
                            OPEN get_item_segments(l_atp_rec.Inventory_Item_Id(I),l_atp_rec.Organization_id(I));
                            FETCH get_item_segments INTO l_item_segments;
                            CLOSE get_item_segments;
                            l_error := true;
                            l_message := l_item_segments || ' : '||  l_message;
                            FND_MESSAGE.SET_NAME('CSP', 'CSP_ATP');
                            FND_MESSAGE.SET_TOKEN('ERROR', l_message, FALSE);
                            FND_MSG_PUB.ADD;
                            fnd_msg_pub.count_and_get
                                ( p_count => x_msg_count
                                , p_data  => x_msg_data);
                        END IF;
                      ELSE
                        If l_atp_rec_out.ship_date(I) IS NULL or l_atp_rec_out.Error_Code(I) <>53 THEN
                            IF not l_error then
                             OPEN error_message(23);
                             FETCH error_message INTO l_message;
                             CLOSE error_message;

                             FND_MESSAGE.SET_NAME('CSP', 'CSP_ATP');
                             FND_MESSAGE.SET_TOKEN('ERROR', l_message, FALSE);
                             FND_MSG_PUB.ADD;
                             fnd_msg_pub.count_and_get
                                ( p_count => x_msg_count
                                , p_data  => x_msg_data);

                            END IF;
                            x_return_status := FND_API.G_RET_STS_ERROR;
                            OPEN error_message(l_atp_rec_out.Error_Code(I));
                            FETCH error_message INTO l_message;
                            CLOSE error_message;
                             l_item_segments := null;
                            OPEN get_item_segments(l_atp_rec.Inventory_Item_Id(I),l_atp_rec.Organization_id(I));
                            FETCH get_item_segments INTO l_item_segments;
                            CLOSE get_item_segments;
                            l_error := true;
                            l_message := l_item_segments || ' : '||  l_message;
                            FND_MESSAGE.SET_NAME('CSP', 'CSP_ATP');
                            FND_MESSAGE.SET_TOKEN('ERROR', l_message, FALSE);
                            FND_MSG_PUB.ADD;
                            fnd_msg_pub.count_and_get
                                ( p_count => x_msg_count
                                , p_data  => x_msg_data);
                          ELSE
                            l_unavailable := 'N';
                          END IF;
                      END IF;
                       log('do_atp_check', 'l_unavailable: '||l_unavailable);
                       IF l_unavailable = 'Y' THEN
                        x_final_unavailable_list.extend;
                        x_final_unavailable_list(x_final_unavailable_list.count).resource_id
                                                                        := p_unavailable_list(I).resource_id;
                        x_final_unavailable_list(x_final_unavailable_list.count).resource_type
                                                                        := p_unavailable_list(I).resource_type ;
                        x_final_unavailable_list(x_final_unavailable_list.count).organization_id := l_atp_rec.Organization_id(I);
                        x_final_unavailable_list(x_final_unavailable_list.count).item_id    := l_atp_rec.Inventory_Item_Id(I);
                        x_final_unavailable_list(x_final_unavailable_list.count).quantity   := l_atp_rec.quantity_ordered(I);
                        x_final_unavailable_list(x_final_unavailable_list.count).item_UOM   := l_atp_rec.quantity_uom(I) ;
                        x_final_unavailable_list(x_final_unavailable_list.count).revision   := p_unavailable_list(I).revision ;
                        FOR J IN 1..p_unavailable_list.count LOOP
                            IF x_final_unavailable_list(x_final_unavailable_list.count).item_id =
                                p_unavailable_list(J).item_id THEN
                                x_final_unavailable_list(x_final_unavailable_list.count).item_type := p_unavailable_list(J).item_type;
                                x_final_unavailable_list(x_final_unavailable_list.count).line_id  := p_unavailable_list(J).line_id;
                                    EXIT;
                            END IF;
                        END LOOP;
                       ELSE
                        log('do_atp_check', 'inner else part');
                             px_available_list.extend;
                        px_available_list(px_available_list.count).resource_id        :=  p_unavailable_list(I).resource_id ;
                        px_available_list(px_available_list.count).resource_type      :=  p_unavailable_list(I).resource_type;
                        px_available_list(px_available_list.count).organization_id    :=  l_atp_rec_out.Organization_id(I);
                        px_available_list(px_available_list.count).item_id            :=  l_atp_rec_out.Inventory_Item_Id(I);
                        px_available_list(px_available_list.count).item_uom            := l_atp_rec_out.quantity_uom(I) ;
                        px_available_list(px_available_list.count).quantity           :=  l_atp_rec_out.quantity_ordered(I);
                        px_available_list(px_available_list.count).source_org         :=  l_atp_rec_out.Source_Organization_Id(I);
                        px_available_list(px_available_list.count).sub_inventory      :=  NULL;
                        if trunc(l_atp_rec_out.ship_date(I)) = trunc(sysdate) THEN
                            px_available_list(px_available_list.count).available_date := trunc(l_atp_rec_out.ship_date(I)) + (sysdate - trunc(sysdate));
                        ELSE
                            px_available_list(px_available_list.count).available_date := l_atp_rec_out.ship_date(I);
                        END IF;
                      --  px_available_list(px_available_list.count).available_date     :=  l_atp_rec_out.ship_date(I);
                        px_available_list(px_available_list.count).available_quantity :=  l_atp_rec_out.Available_Quantity(I);
                        px_available_list(px_available_list.count).revision         := p_unavailable_list(I).revision ;
                         FOR J IN 1..p_unavailable_list.count LOOP
                            IF px_available_list(px_available_list.count).item_id =
                                p_unavailable_list(J).item_id THEN
                                px_available_list(px_available_list.count).item_type := p_unavailable_list(J).item_type;
                                px_available_list(px_available_list.count).line_id  := p_unavailable_list(J).line_id;
                                    EXIT;
                            END IF;
                        END LOOP;
                       END IF;
                    ELSE
                        log('do_atp_check', 'outer else part');
                        px_available_list.extend;
                        px_available_list(px_available_list.count).resource_id        :=  p_unavailable_list(I).resource_id ;
                        px_available_list(px_available_list.count).resource_type      :=  p_unavailable_list(I).resource_type;
                        px_available_list(px_available_list.count).organization_id    :=  l_atp_rec_out.Organization_id(I);
                        px_available_list(px_available_list.count).item_id            :=  l_atp_rec_out.Inventory_Item_Id(I);
                        px_available_list(px_available_list.count).item_uom            := l_atp_rec_out.quantity_uom(I) ;
                        px_available_list(px_available_list.count).quantity           :=  l_atp_rec_out.quantity_ordered(I);
                        px_available_list(px_available_list.count).source_org         :=  l_atp_rec_out.Source_Organization_Id(I);
                        px_available_list(px_available_list.count).sub_inventory      :=  NULL;
                        if trunc(l_atp_rec_out.ship_date(I)) = trunc(sysdate) THEN
                            px_available_list(px_available_list.count).available_date := trunc(l_atp_rec_out.ship_date(I)) + (sysdate - trunc(sysdate));
                        ELSE
                            px_available_list(px_available_list.count).available_date := l_atp_rec_out.ship_date(I);
                        END IF;
                      --  px_available_list(px_available_list.count).available_date     :=  l_atp_rec_out.ship_date(I);
                        px_available_list(px_available_list.count).available_quantity :=  l_atp_rec_out.Available_Quantity(I);
                        px_available_list(px_available_list.count).revision         := p_unavailable_list(I).revision ;
                         log('do_atp_check', 'begin p_unavailable_list loop. count: '||p_unavailable_list.count);
                         FOR J IN 1..p_unavailable_list.count LOOP
                            IF px_available_list(px_available_list.count).item_id =
                                p_unavailable_list(J).item_id THEN
                                px_available_list(px_available_list.count).item_type := p_unavailable_list(J).item_type;
                                px_available_list(px_available_list.count).line_id  := p_unavailable_list(J).line_id;
                                    EXIT;
                            END IF;
                        END LOOP;
                     END IF;
                END LOOP;
            ELSE
                return;
            END IF;
            log('do_atp_check', 'End');
            EXCEPTION
            WHEN OTHERS THEN
            FND_MESSAGE.SET_NAME('CSP', 'CSP_UNEXPECTED_EXEC_ERRORS');
            FND_MESSAGE.SET_TOKEN('ROUTINE', l_api_name, FALSE);
            FND_MESSAGE.SET_TOKEN('SQLERRM', sqlerrm, FALSE);
            FND_MSG_PUB.ADD;
            fnd_msg_pub.count_and_get
              ( p_count => x_msg_count
              , p_data  => x_msg_data);
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            return;

     END DO_ATP_CHECK;



     PROCEDURE ELIGIBLE_RESOURCES(p_resource_list            IN  CSP_SCH_INT_PVT.CSP_SCH_RESOURCE_tbl_TYP
                                 ,p_available_list           IN  CSP_SCH_INT_PVT.CSP_AVAILABILITY_TBL_TYPE
                                 ,p_final_unavailable_list   IN  CSP_SCH_INT_PVT.CSP_UNAVAILABILITY_TBL_TYPE
                                 ,x_eligible_resources_list  OUT NOCOPY CSP_SCH_INT_PVT.CSP_AVAILABILITY_TBL_TYPE
                                 ,x_return_status            OUT NOCOPY VARCHAR2
                                 ,x_msg_data                 OUT NOCOPY VARCHAR2
                                 ,x_msg_count                OUT NOCOPY NUMBER) IS

        resource_eligible BOOLEAN := TRUE;
        l_api_name     VARCHAR2(60) := 'CSP_SCH_INT_PVT.ELIGIBLE_RESOURCES';
     BEGIN
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        x_eligible_resources_list :=  CSP_SCH_INT_PVT.CSP_AVAILABILITY_TBL_TYPE();

          FOR I IN 1..p_resource_list.count LOOP

                FOR J IN 1..p_final_unavailable_list.count LOOP
                    IF p_final_unavailable_list(J).resource_id = p_resource_list(I).resource_id THEN
                        resource_eligible := FALSE;
                        EXIT;
                    ELSE
                        resource_eligible := TRUE ;
                    END IF;
                END LOOP;
                IF resource_eligible = TRUE THEN
                   FOR K IN  1..p_available_list.count LOOP
                        IF  p_available_list(K).resource_id = p_resource_list(I).resource_id THEN
                            x_eligible_resources_list.extend ;
                            x_eligible_resources_list(x_eligible_resources_list.count).resource_id    := p_available_list(K).resource_id ;
                            x_eligible_resources_list(x_eligible_resources_list.count).resource_type  := p_available_list(K).resource_type ;
                            x_eligible_resources_list(x_eligible_resources_list.count).organization_id:= p_available_list(K).organization_id ;
                            x_eligible_resources_list(x_eligible_resources_list.count).item_id        := p_available_list(K).Item_Id ;
                            x_eligible_resources_list(x_eligible_resources_list.count).quantity       := p_available_list(K).quantity ;
                            x_eligible_resources_list(x_eligible_resources_list.count).source_org     := p_available_list(K).source_org ;
                            x_eligible_resources_list(x_eligible_resources_list.count).item_uom       := p_available_list(K).Item_uom ;
                            x_eligible_resources_list(x_eligible_resources_list.count).revision       := p_available_list(K).revision ;
                            x_eligible_resources_list(x_eligible_resources_list.count).sub_inventory       := p_available_list(K).sub_inventory ;
                            x_eligible_resources_list(x_eligible_resources_list.count).available_date := p_available_list(K).available_date;
                             x_eligible_resources_list(x_eligible_resources_list.count).line_id :=p_available_list(K).line_id;

                        END IF;
                   END LOOP;
                END IF;
        END LOOP;
        EXCEPTION
        WHEN OTHERS THEN
            FND_MESSAGE.SET_NAME('CSP', 'CSP_UNEXPECTED_EXEC_ERRORS');
            FND_MESSAGE.SET_TOKEN('ROUTINE', l_api_name, FALSE);
            FND_MESSAGE.SET_TOKEN('SQLERRM', sqlerrm, FALSE);
            FND_MSG_PUB.ADD;
            fnd_msg_pub.count_and_get
              ( p_count => x_msg_count
              , p_data  => x_msg_data);
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            return;
    END ELIGIBLE_RESOURCES;

    PROCEDURE GET_TIME_COST(p_eligible_resources_list  IN  CSP_SCH_INT_PVT.CSP_AVAILABILITY_TBL_TYPE
                          ,x_options                  OUT NOCOPY  CSP_SCH_INT_PVT.csp_sch_options_tbl_typ
                          ,x_return_status            OUT NOCOPY  VARCHAR2
                          ,x_msg_data                 OUT NOCOPY  VARCHAR2
                          ,x_msg_count                OUT NOCOPY  NUMBER) IS
        l_temp_options        CSP_SCH_INT_PVT.CSP_SHIP_PARAMETERS_TBL_TYPE;
        l_temp_resources_list CSP_SCH_INT_PVT.CSP_AVAILABILITY_TBL_TYPE;
        l_options             CSP_SCH_INT_PVT.CSP_SHIP_PARAMETERS_TBL_TYPE ;
        loop_count            NUMBER;
        l_resources           CSP_SCH_INT_PVT.CSP_AVAILABILITY_TBL_TYPE;
        l_ship_count          CSP_SCH_INT_PVT.CSP_SHIP_METHOD_COUNT_TBL_TYP;
        l_res_ship_parameters CSP_SCH_INT_PVT.CSP_ORGS_SHIP_PARAM_TBL_TYPE ;
        l_api_name            VARCHAR2(60) := 'CSP_SCH_INT_PVT.GET_TIME_COST' ;
     BEGIN

        if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SCH_INT_PVT.GET_TIME_COST',
                  'begin...');
        end if;
            x_return_status := FND_API.G_RET_STS_SUCCESS;
            l_temp_options        :=  CSP_SCH_INT_PVT.CSP_SHIP_PARAMETERS_TBL_TYPE();
            l_temp_resources_list :=  CSP_SCH_INT_PVT.CSP_AVAILABILITY_TBL_TYPE();
            l_options             :=  CSP_SCH_INT_PVT.CSP_SHIP_PARAMETERS_TBL_TYPE();
            l_resources           :=  CSP_SCH_INT_PVT.CSP_AVAILABILITY_TBL_TYPE();
            x_options             :=  CSP_SCH_INT_PVT.csp_sch_options_tbl_typ();
            l_ship_count          :=  CSP_SCH_INT_PVT.CSP_SHIP_METHOD_COUNT_TBL_TYP();
            l_res_ship_parameters :=  CSP_SCH_INT_PVT.CSP_ORGS_SHIP_PARAM_TBL_TYPE();
            loop_count :=1 ;

        if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_SCH_INT_PVT.GET_TIME_COST',
                  'Starting while loop with p_eligible_resources_list.count=' || p_eligible_resources_list.count);
        end if;

            WHILE loop_count <= p_eligible_resources_list.count LOOP
                IF loop_count > 1 THEN
                    IF p_eligible_resources_list(loop_count).resource_id =
                                p_eligible_resources_list(loop_count-1).resource_id
                            AND p_eligible_resources_list(loop_count).resource_type =
                                p_eligible_resources_list(loop_count-1).resource_type THEN
                            l_temp_resources_list.extend;
                            l_temp_resources_list(l_temp_resources_list.count).resource_type :=
                                                                  p_eligible_resources_list(loop_count).resource_type ;
                            l_temp_resources_list(l_temp_resources_list.count).resource_id :=
                                                                  p_eligible_resources_list(loop_count).resource_id ;
                            l_temp_resources_list(l_temp_resources_list.count).source_org := p_eligible_resources_list(loop_count).source_org;
                            l_temp_resources_list(l_temp_resources_list.count).organization_id :=  p_eligible_resources_list(loop_count).organization_id ;
                            l_temp_resources_list(l_temp_resources_list.count).quantity := p_eligible_resources_list(loop_count).quantity;
                            l_temp_resources_list(l_temp_resources_list.count).sub_inventory := p_eligible_resources_list(loop_count).sub_inventory;
                            l_temp_resources_list(l_temp_resources_list.count).available_date := p_eligible_resources_list(loop_count).available_date;
                            IF loop_count = p_eligible_resources_list.count THEN
                                CSP_SCH_INT_PVT.OPTIMIZE_OPTIONS(l_temp_resources_list,l_temp_options,l_ship_count,l_res_ship_parameters,x_return_status,x_msg_data,x_msg_count);
                                IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                    RETURN;
                                END IF;
                                CSP_SCH_INT_PVT.BUILD_FINAL_LIST(l_temp_options,x_options,x_return_status,x_msg_data,x_msg_count);
                                IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                    RETURN;
                                END IF;
                                l_temp_options.trim(l_temp_options.count);
                                l_temp_resources_list.trim(l_temp_resources_list.count);
                            END IF;
                    ELSE
                     CSP_SCH_INT_PVT.OPTIMIZE_OPTIONS(l_temp_resources_list,l_temp_options,l_ship_count,l_res_ship_parameters,x_return_status,x_msg_data,x_msg_count);
                     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                    RETURN;
                     END IF;
                     CSP_SCH_INT_PVT.BUILD_FINAL_LIST(l_temp_options,x_options,x_return_status,x_msg_data,x_msg_count);
                     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                    RETURN;
                     END IF;
                     l_temp_options.trim(l_temp_options.count);
                     l_temp_resources_list.trim(l_temp_resources_list.count);
                        l_temp_resources_list.extend;
                        l_temp_resources_list(l_temp_resources_list.count).resource_type   := p_eligible_resources_list(loop_count).resource_type ;
                         l_temp_resources_list(l_temp_resources_list.count).resource_id     := p_eligible_resources_list(loop_count).resource_id ;
                        l_temp_resources_list(l_temp_resources_list.count).source_org      := p_eligible_resources_list(loop_count).source_org;
                        l_temp_resources_list(l_temp_resources_list.count).organization_id := p_eligible_resources_list(loop_count).organization_id;
                        l_temp_resources_list(l_temp_resources_list.count).quantity        := p_eligible_resources_list(loop_count).quantity;
                        l_temp_resources_list(l_temp_resources_list.count).sub_inventory   := p_eligible_resources_list(loop_count).sub_inventory ;
                        l_temp_resources_list(l_temp_resources_list.count).available_date := p_eligible_resources_list(loop_count).available_date;
                    END IF;
                    IF loop_count = p_eligible_resources_list.count THEN
                                CSP_SCH_INT_PVT.OPTIMIZE_OPTIONS(l_temp_resources_list,l_temp_options,l_ship_count,l_res_ship_parameters,x_return_status,x_msg_data,x_msg_count);
                                IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                    RETURN;
                                END IF;
                                CSP_SCH_INT_PVT.BUILD_FINAL_LIST(l_temp_options,x_options,x_return_status,x_msg_data,x_msg_count);
                                IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                    RETURN;
                                END IF;
                                l_temp_options.trim(l_temp_options.count);
                                l_temp_resources_list.trim(l_temp_resources_list.count);
                     END IF;
                ELSE

                                        if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                                          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                                  'csp.plsql.CSP_SCH_INT_PVT.GET_TIME_COST',
                                                  'In else part of loop_count > 1');
                                        end if;

                    l_temp_resources_list.extend;
                    l_temp_resources_list(l_temp_resources_list.count).resource_type   := p_eligible_resources_list(loop_count).resource_type ;
                    l_temp_resources_list(l_temp_resources_list.count).resource_id     := p_eligible_resources_list(loop_count).resource_id ;
                    l_temp_resources_list(l_temp_resources_list.count).source_org      := p_eligible_resources_list(loop_count).source_org;
                    l_temp_resources_list(l_temp_resources_list.count).organization_id := p_eligible_resources_list(loop_count).organization_id;
                    l_temp_resources_list(l_temp_resources_list.count).quantity        := p_eligible_resources_list(loop_count).quantity;
                    l_temp_resources_list(l_temp_resources_list.count).sub_inventory   := p_eligible_resources_list(loop_count).sub_inventory ;
                    l_temp_resources_list(l_temp_resources_list.count).available_date := p_eligible_resources_list(loop_count).available_date;

                    IF p_eligible_resources_list.count =1 THEN

                                                if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                                                  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                                          'csp.plsql.CSP_SCH_INT_PVT.GET_TIME_COST',
                                                          'Before calling CSP_SCH_INT_PVT.OPTIMIZE_OPTIONS...');
                                                end if;

                                                CSP_SCH_INT_PVT.OPTIMIZE_OPTIONS(l_temp_resources_list,l_temp_options,l_ship_count,l_res_ship_parameters,x_return_status,x_msg_data,x_msg_count);

                                                if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                                                  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                                          'csp.plsql.CSP_SCH_INT_PVT.GET_TIME_COST',
                                                          'After calling CSP_SCH_INT_PVT.OPTIMIZE_OPTIONS... x_return_status=' || x_return_status);
                                                  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                                          'csp.plsql.CSP_SCH_INT_PVT.GET_TIME_COST',
                                                          'After calling CSP_SCH_INT_PVT.OPTIMIZE_OPTIONS... l_temp_options.count=' || l_temp_options.count);
                                                end if;

                                                IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                    RETURN;
                        END IF;

                                                if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                                                  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                                          'csp.plsql.CSP_SCH_INT_PVT.GET_TIME_COST',
                                                          'Before calling BUILD_FINAL_LIST...');
                                                end if;

                        CSP_SCH_INT_PVT.BUILD_FINAL_LIST(l_temp_options,x_options,x_return_status,x_msg_data,x_msg_count);

                                                if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                                                  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                                          'csp.plsql.CSP_SCH_INT_PVT.GET_TIME_COST',
                                                          'After calling BUILD_FINAL_LIST... x_return_status=' || x_return_status);
                                                  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                                          'csp.plsql.CSP_SCH_INT_PVT.GET_TIME_COST',
                                                          'After calling BUILD_FINAL_LIST... x_options.count=' || x_options.count);
                                                end if;

                        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                    RETURN;
                        END IF;

                        l_temp_options.trim(l_temp_options.count);
                        l_temp_resources_list.trim(l_temp_resources_list.count);

                    END IF;
                 END IF;
                    loop_count := loop_count + 1 ;
            END LOOP;

                        if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                  'csp.plsql.CSP_SCH_INT_PVT.GET_TIME_COST',
                                  'Coming out of the loop...');
                        end if;

            EXCEPTION
            WHEN OTHERS THEN
            FND_MESSAGE.SET_NAME('CSP', 'CSP_UNEXPECTED_EXEC_ERRORS');
            FND_MESSAGE.SET_TOKEN('ROUTINE', l_api_name, FALSE);
            FND_MESSAGE.SET_TOKEN('SQLERRM', sqlerrm, FALSE);
            FND_MSG_PUB.ADD;
            fnd_msg_pub.count_and_get
              ( p_count => x_msg_count
              , p_data  => x_msg_data);
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            return;
     END GET_TIME_COST;
     PROCEDURE BUILD_FINAL_LIST(p_temp_options  IN     CSP_SCH_INT_PVT.CSP_SHIP_PARAMETERS_TBL_TYPE
                               ,px_options      IN OUT NOCOPY CSP_SCH_INT_PVT.csp_sch_options_tbl_typ
                               ,x_return_status  OUT NOCOPY   VARCHAR2
                               ,x_msg_data       OUT NOCOPY   VARCHAR2
                               ,x_msg_count      OUT NOCOPY   NUMBER) IS
        l_api_name varchar2(60) := 'CSP_SCH_INT_PVT.BUILD_FINAL_LIST';
        l_need_by_date date;
     BEGIN
            IF g_interval.latest_time IS NOT NULL
            THEN
               l_need_by_date := g_interval.latest_time;
            ELSE
               l_need_by_date := g_interval.earliest_time;
            END IF;
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        FOR I IN 1..p_temp_options.count LOOP
          -- IF round(p_temp_options(I).arrival_date,'MI') <= round(l_need_by_date,'MI') THEN
            px_options.extend;
            px_options(px_options.count).resource_type :=  p_temp_options(I).resource_type;
            px_options(px_options.count).resource_id   :=  p_temp_options(I).resource_id;
            px_options(px_options.count).start_time    :=  round(p_temp_options(I).arrival_date,'MI') ;
            px_options(px_options.count).transfer_cost :=  p_temp_options(I).transfer_cost;
            px_options(px_options.count).missing_parts :=  0;
           /* ELSE
                select least(round(p_temp_options(I).arrival_date,'MI'),round(g_earliest_delivery_date,'MI'))
                INTO g_earliest_delivery_date
                from dual;
            END IF;*/
        END LOOP;
        EXCEPTION
        WHEN OTHERS THEN
            FND_MESSAGE.SET_NAME('CSP', 'CSP_UNEXPECTED_EXEC_ERRORS');
            FND_MESSAGE.SET_TOKEN('ROUTINE', l_api_name, FALSE);
            FND_MESSAGE.SET_TOKEN('SQLERRM', sqlerrm, FALSE);
            FND_MSG_PUB.ADD;
            fnd_msg_pub.count_and_get
              ( p_count => x_msg_count
              , p_data  => x_msg_data);
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            return;
     END BUILD_FINAL_LIST;

      PROCEDURE OPTIMIZE_OPTIONS(p_eligible_resources IN      CSP_SCH_INT_PVT.CSP_AVAILABILITY_TBL_TYPE
                               ,px_options           IN OUT NOCOPY  CSP_SCH_INT_PVT.CSP_SHIP_PARAMETERS_TBL_TYPE
                               ,x_ship_count         OUT NOCOPY     CSP_SCH_INT_PVT.CSP_SHIP_METHOD_COUNT_TBL_TYP
                               ,x_ship_parameters    OUT NOCOPY     CSP_SCH_INT_PVT.CSP_ORGS_SHIP_PARAM_TBL_TYPE
                               ,x_return_status      OUT NOCOPY     VARCHAR2
                               ,x_msg_data           OUT NOCOPY     VARCHAR2
                               ,x_msg_count          OUT NOCOPY     NUMBER) IS

         cursor location_shipping_method_count(c_from_org_id number, c_to_location_id number) IS
        SELECT count(*)
        FROM   MTL_INTERORG_SHIP_METHODS ISM,HR_ALL_ORGANIZATION_UNITS hao
        where  hao.organization_id = c_from_org_id
        and  ism.from_location_id = hao.location_id
        and  ism.to_location_id = c_to_location_id;


        l_resource_shipping_parameters  CSP_SCH_INT_PVT.CSP_ORGS_SHIP_PARAM_TBL_TYPE ;
        l_temp_rec                      CSP_SCH_INT_PVT.CSP_ORGS_SHIP_PARAM_TBL_TYPE ;
        l_ship_quantity                 CSP_SCH_INT_PVT.CSP_SHIP_QUANTITY_TBL_TYPE ;
        l_final_resource                CSP_SCH_INT_PVT.CSP_SHIP_PARAMETERS_TBL_TYPE ;
        l_temp_final_resource           CSP_SCH_INT_PVT.CSP_SHIP_PARAMETERS_TBL_TYPE ;
        L_API_NAME  VARCHAR2(60) := 'CSP_SCH_INT_PVT.OPTIMIZE_OPTIONS';
        loop_start NUMBER :=0 ;
        loop_end   NUMBER :=0 ;
        loop_min   NUMBER :=100000 ;
        loop_max   NUMBER :=0 ;
        min_leadtime NUMBER;
        max_leadtime NUMBER;
        k   NUMBER;
        low_cost_present BOOLEAN;
        ship_methodes_count NUMBER;
        first_count NUMBER;
        itration NUMBER;
        I NUMBER;
        resource_count NUMBER;
        record_present BOOLEAN;
        min_cost NUMBER;
        do_optimize BOOLEAN := FALSE;
        greatest_available_date DATE:= to_date('1','j');
        l_present boolean;
        l_min_cost_for_loop number;
        do_insert BOOLEAN;
        l_shipping_methods varchar2(2000);
        l_to_org_id NUMBER;
        l_loc_ship_method_count NUMBER := 0;
      BEGIN
             x_return_status := FND_API.G_RET_STS_SUCCESS ;
            l_resource_shipping_parameters :=  CSP_SCH_INT_PVT.CSP_ORGS_SHIP_PARAM_TBL_TYPE() ;
            l_temp_rec                     :=  CSP_SCH_INT_PVT.CSP_ORGS_SHIP_PARAM_TBL_TYPE() ;
            x_ship_count                   :=  CSP_SCH_INT_PVT.CSP_SHIP_METHOD_COUNT_TBL_TYP() ;
            l_ship_quantity                :=  CSP_SCH_INT_PVT.CSP_SHIP_QUANTITY_TBL_TYPE() ;
            l_final_resource               :=  CSP_SCH_INT_PVT.CSP_SHIP_PARAMETERS_TBL_TYPE() ;
            l_temp_final_resource          :=  CSP_SCH_INT_PVT.CSP_SHIP_PARAMETERS_TBL_TYPE() ;
            x_ship_parameters              :=  CSP_SCH_INT_PVT.CSP_ORGS_SHIP_PARAM_TBL_TYPE();

                if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                          'csp.plsql.CSP_SCH_INT_PVT.OPTIMIZE_OPTIONS',
                          'Begin...');
                end if;

            FOR I IN 1..p_eligible_resources.count LOOP
               l_to_org_id := p_eligible_resources(I).organization_id;
               OPEN location_shipping_method_count(p_eligible_resources(I).source_org, p_eligible_resources(I).destination_location_id);
               FETCH location_shipping_method_count INTO l_loc_ship_method_count;
               CLOSE location_shipping_method_count;

                                if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                                  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                          'csp.plsql.CSP_SCH_INT_PVT.OPTIMIZE_OPTIONS',
                                          'inside first for loop l_loc_ship_method_count for row I =' || l_loc_ship_method_count || '(' || I || ')');
                                end if;

                IF p_eligible_resources(I).sub_inventory IS NULL AND
                                       (p_eligible_resources(I).organization_id <> p_eligible_resources(I).source_org or nvl(l_loc_ship_method_count,0) <> 0 ) THEN
                    do_optimize := TRUE ;
                    exit;
                ELSE
                    do_optimize := FALSE;
                END IF;
            END LOOP;


          IF do_optimize  THEN

                        if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                  'csp.plsql.CSP_SCH_INT_PVT.OPTIMIZE_OPTIONS',
                                  'doing do_optimize...');
                          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                  'csp.plsql.CSP_SCH_INT_PVT.OPTIMIZE_OPTIONS',
                                  'before calling CONSOLIDATE_QUANTITIES...');
                        end if;

            CSP_SCH_INT_PVT.CONSOLIDATE_QUANTITIES(p_eligible_resources, l_ship_quantity,x_return_status,x_msg_data,x_msg_count);

                        if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                  'csp.plsql.CSP_SCH_INT_PVT.OPTIMIZE_OPTIONS',
                                  'After calling CONSOLIDATE_QUANTITIES...x_return_status=' || x_return_status);
                          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                  'csp.plsql.CSP_SCH_INT_PVT.OPTIMIZE_OPTIONS',
                                  'After calling CONSOLIDATE_QUANTITIES...l_ship_quantity.count=' || l_ship_quantity.count);
                        end if;

            IF x_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
                return;
            END IF;

                        if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                  'csp.plsql.CSP_SCH_INT_PVT.OPTIMIZE_OPTIONS',
                                  'before calling GET_SHIPPING_PARAMETERS...');
                        end if;

            CSP_SCH_INT_PVT.GET_SHIPPING_PARAMETERS(l_ship_quantity,l_resource_shipping_parameters,x_ship_count,x_return_status,x_msg_data,x_msg_count);

                        if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                  'csp.plsql.CSP_SCH_INT_PVT.OPTIMIZE_OPTIONS',
                                  'After calling GET_SHIPPING_PARAMETERS...x_return_status=' || x_return_status);
                          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                  'csp.plsql.CSP_SCH_INT_PVT.OPTIMIZE_OPTIONS',
                                  'After calling GET_SHIPPING_PARAMETERS...l_resource_shipping_parameters.count=' || l_resource_shipping_parameters.count);
                          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                  'csp.plsql.CSP_SCH_INT_PVT.OPTIMIZE_OPTIONS',
                                  'After calling GET_SHIPPING_PARAMETERS...x_ship_count.count=' || x_ship_count.count);
                        end if;

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                return;
            END IF;

            x_ship_parameters := l_resource_shipping_parameters;
                loop_start := 1 ;
                min_leadtime := 0;
                max_leadtime := 0;

           FOR I IN 1..p_eligible_resources.count LOOP
                IF p_eligible_resources(I).sub_inventory IS NULL THEN
                    SELECT GREATEST(greatest_available_date, nvl(p_eligible_resources(I).available_date,sysdate))
                    INTO   greatest_available_date
                    FROM DUAL;
                END IF;
           END LOOP;

                        if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                  'csp.plsql.CSP_SCH_INT_PVT.OPTIMIZE_OPTIONS',
                                  'greatest_available_date=' || to_char(greatest_available_date, 'DD-MON-RRRR HH24:MI:SS'));
                        end if;

           FOR I IN 1..x_ship_count.count LOOP
                loop_min := x_ship_count(I).min_leadtime;
                loop_max := x_ship_count(I).max_leadtime;
                SELECT GREATEST(min_leadtime,loop_min) INTO min_leadtime FROM DUAL;
                SELECT GREATEST(max_leadtime,loop_max) INTO max_leadtime FROM DUAL;
           END LOOP;

                        if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                  'csp.plsql.CSP_SCH_INT_PVT.OPTIMIZE_OPTIONS',
                                  'min_leadtime=' || min_leadtime || ', max_leadtime=' || max_leadtime);
                        end if;

             resource_count := 1 ;
              WHILE resource_count <= l_resource_shipping_parameters.count LOOP
                first_count := 0;
                FOR J IN 1..x_ship_count.count LOOP
                    IF x_ship_count(J).from_org_id  = l_resource_shipping_parameters(resource_count).from_org_id AND
                       x_ship_count(J).to_org_id    = l_resource_shipping_parameters(resource_count).to_org_id  THEN
                       first_count := x_ship_count(J).shipping_methodes;
                       exit;
                    END IF;
                END LOOP;

                        if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                  'csp.plsql.CSP_SCH_INT_PVT.OPTIMIZE_OPTIONS',
                                  'after for loop first_count=' || first_count);
                        end if;

               IF first_count  > 1 THEN
                FOR I IN resource_count..(resource_count + first_count-1) LOOP
                    IF  l_resource_shipping_parameters(I).lead_time >= min_leadtime THEN
                           k := I-1 ;
                           low_cost_present := FALSE;
                            FOR K IN resource_count..(resource_count + first_count-1) LOOP
                                IF l_resource_shipping_parameters(K).lead_time < l_resource_shipping_parameters(I).lead_time
                                AND  l_resource_shipping_parameters(K).transfer_cost <=
                                            l_resource_shipping_parameters(I).transfer_cost THEN
                                    low_cost_present := TRUE;
                                    l_temp_rec.extend;
                                    l_temp_rec(l_temp_rec.count).resource_type
                                                                := l_resource_shipping_parameters(k).resource_type ;
                                    l_temp_rec(l_temp_rec.count).resource_id
                                                                := l_resource_shipping_parameters(k).resource_id ;
                                    l_temp_rec(l_temp_rec.count) .from_org_id
                                                                := l_resource_shipping_parameters(k).from_org_id ;
                                    l_temp_rec(l_temp_rec.count) .to_org_id
                                                                := l_resource_shipping_parameters(k).to_org_id ;
                                    l_temp_rec(l_temp_rec.count) .quantity
                                                                := l_resource_shipping_parameters(k).quantity ;
                                    l_temp_rec(l_temp_rec.count) .shipping_method
                                                                := l_resource_shipping_parameters(k).shipping_method;
                                    l_temp_rec(l_temp_rec.count) .lead_time
                                                                := l_resource_shipping_parameters(k).lead_time ;
                                    l_temp_rec(l_temp_rec.count) .transfer_cost
                                                                := l_resource_shipping_parameters(k).transfer_cost ;
                                END IF ;
                            END LOOP;
                            IF low_cost_present = FALSE THEN
                                    l_temp_rec .extend;
                                    l_temp_rec(l_temp_rec.count).resource_type
                                                                := l_resource_shipping_parameters(I).resource_type ;
                                    l_temp_rec(l_temp_rec.count) .resource_id
                                                                := l_resource_shipping_parameters(I).resource_id ;
                                    l_temp_rec(l_temp_rec.count) .from_org_id
                                                                := l_resource_shipping_parameters(I).from_org_id;
                                    l_temp_rec(l_temp_rec.count) .to_org_id
                                                                := l_resource_shipping_parameters(I).to_org_id;
                                    l_temp_rec(l_temp_rec.count) .quantity
                                                                := l_resource_shipping_parameters(I).quantity ;
                                    l_temp_rec(l_temp_rec.count) .shipping_method
                                                                := l_resource_shipping_parameters(I).shipping_method;
                                    l_temp_rec(l_temp_rec.count) .lead_time
                                                                := l_resource_shipping_parameters(I).lead_time ;
                                    l_temp_rec(l_temp_rec.count) .transfer_cost
                                                                := l_resource_shipping_parameters(I).transfer_cost ;
                            END IF;
                    END IF;
                END LOOP;
               ELSE
                    l_temp_rec .extend;
                    l_temp_rec(l_temp_rec.count).resource_type
                                          := l_resource_shipping_parameters(resource_count).resource_type ;
                    l_temp_rec(l_temp_rec.count) .resource_id
                                          := l_resource_shipping_parameters(resource_count).resource_id ;
                    l_temp_rec(l_temp_rec.count) .from_org_id
                                          := l_resource_shipping_parameters(resource_count).from_org_id;
                    l_temp_rec(l_temp_rec.count) .to_org_id
                                          := l_resource_shipping_parameters(resource_count).to_org_id;
                    l_temp_rec(l_temp_rec.count) .quantity
                                          := l_resource_shipping_parameters(resource_count).quantity ;
                    l_temp_rec(l_temp_rec.count) .shipping_method
                                          := l_resource_shipping_parameters(resource_count).shipping_method;
                   l_temp_rec(l_temp_rec.count) .lead_time
                                          := l_resource_shipping_parameters(resource_count).lead_time ;
                   l_temp_rec(l_temp_rec.count) .transfer_cost
                                          := l_resource_shipping_parameters(resource_count).transfer_cost ;
                 END IF;
                        l_present := FALSE ;
                        FOR N IN 1..l_temp_rec.count LOOP
                            IF l_temp_rec(N).resource_type = l_resource_shipping_parameters(resource_count).resource_type and
                               l_temp_rec(N) .resource_id  = l_resource_shipping_parameters(resource_count).resource_id   and
                               l_temp_rec(N) .from_org_id  = l_resource_shipping_parameters(resource_count).from_org_id   and
                               l_temp_rec(N) .to_org_id    = l_resource_shipping_parameters(resource_count).to_org_id  THEN
                               l_present := TRUE;
                               exit;
                            END IF;
                        END LOOP;
                        l_min_cost_for_loop := 1000000000;
                        IF not l_present THEN
                            FOR N IN resource_count..(resource_count+first_count-1) LOOP
                                select LEAST(l_min_cost_for_loop,l_resource_shipping_parameters(N).transfer_cost)
                                INTO l_min_cost_for_loop
                                FROM DUAL;
                            END LOOP;
                            FOR N IN resource_count..(resource_count+first_count-1) LOOP
                                IF l_min_cost_for_loop = l_resource_shipping_parameters(N).transfer_cost THEN
                                l_temp_rec .extend;
                                l_temp_rec(l_temp_rec.count).resource_type
                                          := l_resource_shipping_parameters(resource_count).resource_type ;
                                l_temp_rec(l_temp_rec.count) .resource_id
                                          := l_resource_shipping_parameters(resource_count).resource_id ;
                                l_temp_rec(l_temp_rec.count) .from_org_id
                                          := l_resource_shipping_parameters(resource_count).from_org_id;
                                l_temp_rec(l_temp_rec.count) .to_org_id
                                          := l_resource_shipping_parameters(resource_count).to_org_id;
                                l_temp_rec(l_temp_rec.count) .quantity
                                          := l_resource_shipping_parameters(resource_count).quantity ;
                                l_temp_rec(l_temp_rec.count) .shipping_method
                                          := l_resource_shipping_parameters(resource_count).shipping_method;
                                l_temp_rec(l_temp_rec.count) .lead_time
                                          := l_resource_shipping_parameters(resource_count).lead_time ;
                                l_temp_rec(l_temp_rec.count) .transfer_cost
                                          := l_resource_shipping_parameters(resource_count).transfer_cost ;
                                END IF;
                            END LOOP;
                          END IF;
                    resource_count := resource_count + first_count ;
              END LOOP;

                        if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                  'csp.plsql.CSP_SCH_INT_PVT.OPTIMIZE_OPTIONS',
                                  'Out of while loop ...');
                        end if;

                        FOR I IN 1..x_ship_count.count LOOP
                    ship_methodes_count := 0;
                    FOR J IN 1..l_temp_rec.count LOOP
                        IF l_temp_rec(J).from_org_id = x_ship_count(I).from_org_id AND
                               l_temp_rec(J).to_org_id = x_ship_count(I).to_org_id THEN
                               ship_methodes_count := ship_methodes_count + 1 ;
                        END IF;
                    END LOOP;
                    x_ship_count(I).shipping_methodes  := ship_methodes_count ;
            END LOOP;
            itration := 1;
            loop_start := 0;
            I :=1;

                        if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                  'csp.plsql.CSP_SCH_INT_PVT.OPTIMIZE_OPTIONS',
                                  'another while loop ... l_temp_rec.count=' || l_temp_rec.count);
                        end if;

           WHILE I <=  l_temp_rec.count LOOP
                first_count := 0;

                        if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                  'csp.plsql.CSP_SCH_INT_PVT.OPTIMIZE_OPTIONS',
                                  'another while loop ... first_count=' || first_count);
                        end if;

                FOR J IN 1..x_ship_count.count LOOP
                    IF x_ship_count(J).from_org_id = l_temp_rec(I).from_org_id AND
                       x_ship_count(J).to_org_id = l_temp_rec(I).to_org_id THEN
                       first_count := x_ship_count(J).shipping_methodes;
                       exit;
                    END IF;
                END LOOP;
                IF itration = 1 then
                    FOR K IN 1..first_count LOOP
                     l_final_resource.extend;
                     l_final_resource(l_final_resource.count).resource_id        :=  l_temp_rec(I).resource_id ;
                     l_final_resource(l_final_resource.count).resource_type      :=  l_temp_rec(I).resource_type ;
                     l_final_resource(l_final_resource.count).lead_time          :=  l_temp_rec(K).lead_time;
                     l_final_resource(l_final_resource.count).transfer_cost      :=  l_temp_rec(K).quantity * l_temp_rec(K).transfer_cost;
                     l_final_resource(l_final_resource.count).shipping_methodes  :=  l_temp_rec(K).shipping_method ;
                    END LOOP;
               ELSE
                    FOR K IN 1..l_final_resource.count LOOP
                        FOR L IN I..(I+first_count-1) LOOP
                            l_temp_final_resource.extend ;
                            l_temp_final_resource(l_temp_final_resource.count).resource_id
                                                        :=  l_final_resource(k).resource_id ;
                            l_temp_final_resource(l_temp_final_resource.count).resource_type :=
                                                                       l_final_resource(K).resource_type ;
                            SELECT GREATEST(l_final_resource(K).lead_time,l_temp_rec(L).lead_time)
                            INTO l_temp_final_resource(l_temp_final_resource.count).lead_time
                            FROM DUAL ;
                             l_temp_final_resource(l_temp_final_resource.count).transfer_cost :=
                                                (l_temp_rec(L).transfer_cost * l_temp_rec(L) .quantity) +
                                                 l_final_resource(K).transfer_cost;
                             l_temp_final_resource(l_temp_final_resource.count).shipping_methodes
                                                         := l_final_resource(K).shipping_methodes || '$' || l_temp_rec(L).shipping_method ;
                        END LOOP;
                    END LOOP;
                            l_final_resource.trim(l_final_resource.count) ;
                    FOR L IN 1..l_temp_final_resource.count LOOP
                        l_final_resource.extend ;
                        l_final_resource(l_final_resource.count).resource_id      :=  l_temp_final_resource(L).resource_id ;
                        l_final_resource(l_final_resource.count).resource_type    :=  l_temp_final_resource(L).resource_type ;
                        l_final_resource(l_final_resource.count).lead_time        := l_temp_final_resource(L).lead_time;
                        l_final_resource(l_final_resource.count).transfer_cost    := l_temp_final_resource(L).transfer_cost ;
                        l_final_resource(l_final_resource.count).shipping_methodes:= l_temp_final_resource(L).shipping_methodes;
                    END LOOP;
                        l_temp_final_resource.trim(l_temp_final_resource.count);
                END IF;
                itration := itration + 1;
                I := I + first_count ;
            END LOOP;
            FOR L IN 1..l_final_resource.count LOOP
                  record_present := false;
                  FOR K IN 1..px_options.count LOOP
                            IF l_final_resource(L).lead_time = px_options(K).lead_time THEN
                                record_present := TRUE;
                                exit;
                            END IF;
                  END LOOP;
                 IF record_present = FALSE THEN
                    min_cost := l_final_resource(L).transfer_cost ;
                    l_shipping_methods := l_final_resource(L).shipping_methodes;
                    FOR J IN 1..l_final_resource.count LOOP
                        IF L <> J AND l_final_resource(L).lead_time =l_final_resource(J).lead_time THEN
                           /* SELECT LEAST(min_cost, l_final_resource(J).transfer_cost)
                            INTO min_cost
                            FROM DUAL;*/
                            if min_cost > l_final_resource(J).transfer_cost then
                                min_cost := l_final_resource(J).transfer_cost;
                                l_shipping_methods := l_final_resource(J).shipping_methodes;
                            end if;
                        END IF;
                    END LOOP;
                    px_options.extend;
                    px_options(px_options.count).resource_id       :=  l_final_resource(L).resource_id ;
                    px_options(px_options.count).resource_type     :=  l_final_resource(L).resource_type ;
                   /* in case of available date not today we have to assume that it is from other source
                     hence we have to substarct the current time from midnight today*/
                    l_final_resource(L).lead_time := l_final_resource(L).lead_time -
                                            ((to_number(to_Char(greatest_available_date,'HH24')) + to_number(to_Char(greatest_available_date,'MI'))/60 ) -(to_number(to_Char(sysdate,'HH24')) + to_number(to_Char(sysdate,'MI'))/60 ));

                    px_options(px_options.count).lead_time         :=  l_final_resource(L).lead_time;
                    px_options(px_options.count).transfer_cost     :=  min_cost;
                    px_options(px_options.count).shipping_methodes :=  l_shipping_methods;
                    px_options(px_options.count).arrival_date      :=  get_arrival_date(greatest_available_date,
                                                                                        l_final_resource(L).lead_time,
                                                                                        l_to_org_id);

                   END IF;
            END LOOP;
           ELSE
                 FOR I IN 1..p_eligible_resources.count LOOP
                    IF px_options.count >= 1 THEN
                        FOR J IN 1..px_options.count LOOP
                            IF px_options(J).resource_id <> p_eligible_resources(I).resource_id AND
                               px_options(J).resource_type <>  p_eligible_resources(I).resource_type THEN
                               do_insert := TRUE;
                               EXIT;
                            END IF;
                        END LOOP;
                        IF do_insert THEN
                            px_options.extend;
                            px_options(px_options.count).resource_id       :=  p_eligible_resources(I).resource_id ;
                            px_options(px_options.count).resource_type     :=  p_eligible_resources(I).resource_type ;
                            px_options(px_options.count).lead_time         :=  0;
                            px_options(px_options.count).transfer_cost     :=  0;
                            px_options(px_options.count).shipping_methodes :=  null;
                            px_options(px_options.count).arrival_date      :=  SYSDATE;
                        END IF;
                    ELSE
                            px_options.extend;
                            px_options(px_options.count).resource_id       :=  p_eligible_resources(I).resource_id ;
                            px_options(px_options.count).resource_type     :=  p_eligible_resources(I).resource_type ;
                            px_options(px_options.count).lead_time         :=  0;
                            px_options(px_options.count).transfer_cost     :=  0;
                            px_options(px_options.count).shipping_methodes :=  null;
                            px_options(px_options.count).arrival_date      :=  SYSDATE;
                    END IF;
                    do_insert := FALSE;
                    IF x_ship_count.count = 0 THEN
                        x_ship_count.extend;
                        x_ship_count(x_ship_count.count).from_org_id       := p_eligible_resources(I).source_org;
                        x_ship_count(x_ship_count.count).to_org_Id         := p_eligible_resources(I).organization_id;
                        x_ship_count(x_ship_count.count).shipping_methodes := 0 ;
                        x_ship_count(x_ship_count.count).min_leadtime      := 0;
                        x_ship_count(x_ship_count.count).max_leadtime      := 0;
                    ELSE
                        FOR I IN 1..x_ship_count.count LOOP
                            IF x_ship_count(x_ship_count.count).from_org_id <> p_eligible_resources(I).source_org AND
                                 x_ship_count(x_ship_count.count).to_org_id <> p_eligible_resources(I).organization_id THEN
                                do_insert := TRUE;
                                exit;
                            END IF;
                        END LOOP;
                        IF do_insert THEN
                            x_ship_count.extend;
                            x_ship_count(x_ship_count.count).from_org_id       := p_eligible_resources(I).source_org;
                            x_ship_count(x_ship_count.count).to_org_Id         := p_eligible_resources(I).organization_id;
                            x_ship_count(x_ship_count.count).shipping_methodes := 0 ;
                            x_ship_count(x_ship_count.count).min_leadtime      := 0;
                            x_ship_count(x_ship_count.count).max_leadtime      := 0;
                        END IF;
                    END IF;
                END LOOP;
           END IF;
           EXCEPTION
            WHEN OTHERS THEN
            FND_MESSAGE.SET_NAME('CSP', 'CSP_UNEXPECTED_EXEC_ERRORS');
            FND_MESSAGE.SET_TOKEN('ROUTINE', l_api_name, FALSE);
            FND_MESSAGE.SET_TOKEN('SQLERRM', sqlerrm, FALSE);
            FND_MSG_PUB.ADD;
            fnd_msg_pub.count_and_get
              ( p_count => x_msg_count
              , p_data  => x_msg_data);
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            return;
      END OPTIMIZE_OPTIONS;

     PROCEDURE CONSOLIDATE_QUANTITIES(p_eligible_resources_list IN     CSP_SCH_INT_PVT.CSP_AVAILABILITY_TBL_TYPE
                                      ,x_ship_quantity          OUT NOCOPY    CSP_SCH_INT_PVT.CSP_SHIP_QUANTITY_TBL_TYPE
                                      ,x_return_status          OUT NOCOPY    VARCHAR2
                                      ,x_msg_data               OUT NOCOPY    VARCHAR2
                                      ,x_msg_count              OUT NOCOPY    NUMBER) IS
        I NUMBER;
        J NUMBER;
        available BOOLEAN;
        l_api_name VARCHAR2(60) := 'CSP_SCH_INT_PVT.CONSOLIDATE_QUANTITIES';
     BEGIN
            x_return_status := FND_API.G_RET_STS_SUCCESS ;
            x_ship_quantity := CSP_SCH_INT_PVT.CSP_SHIP_QUANTITY_TBL_TYPE();
            x_ship_quantity.trim(x_ship_quantity.count);
            FOR I IN 1..p_eligible_resources_list.count LOOP
                IF p_eligible_resources_list(I).sub_inventory IS NULL THEN
                    IF x_ship_quantity.count >= 1 THEN
                        FOR J IN 1..x_ship_quantity.count LOOP
                            IF p_eligible_resources_list(I).organization_id = x_ship_quantity(J).to_org_id AND
                             p_eligible_resources_list(I).source_org = x_ship_quantity(J).from_org_id THEN
                             x_ship_quantity(J).quantity := x_ship_quantity(J).quantity +
                                                              p_eligible_resources_list(I).quantity ;
                                available := TRUE;
                                EXIT ;
                            ELSE
                             available := FALSE;
                            END IF;
                        END LOOP;
                            IF available  = FALSE THEN
                                x_ship_quantity.extend ;
                                x_ship_quantity(x_ship_quantity.count).resource_type :=
                                                                           p_eligible_resources_list(I).resource_type  ;
                                x_ship_quantity(x_ship_quantity.count).resource_id :=
                                                                           p_eligible_resources_list(I).resource_id ;
                                x_ship_quantity(x_ship_quantity.count).from_org_id := p_eligible_resources_list(I).source_org;
                                x_ship_quantity(x_ship_quantity.count).to_org_id   :=  p_eligible_resources_list(I).organization_id;
                                x_ship_quantity(x_ship_quantity.count).quantity := p_eligible_resources_list(I).quantity;
                                x_ship_quantity(x_ship_quantity.count).destination_location_id :=  p_eligible_resources_list(I).destination_location_id;
                            END IF;
                    ELSE
                        x_ship_quantity.extend ;
                        x_ship_quantity(x_ship_quantity.count).resource_type := p_eligible_resources_list(I).resource_type  ;
                        x_ship_quantity(x_ship_quantity.count).resource_id := p_eligible_resources_list(I).resource_id ;
                        x_ship_quantity(x_ship_quantity.count).from_org_id := p_eligible_resources_list(I).source_org;
                        x_ship_quantity(x_ship_quantity.count).to_org_id   :=  p_eligible_resources_list(I).organization_id;
                        x_ship_quantity(x_ship_quantity.count).quantity    := p_eligible_resources_list(I).quantity;
                         x_ship_quantity(x_ship_quantity.count).destination_location_id :=  p_eligible_resources_list(I).destination_location_id;
                    END IF;
                END IF;
            END LOOP;
            EXCEPTION
            WHEN OTHERS THEN
            FND_MESSAGE.SET_NAME('CSP', 'CSP_UNEXPECTED_EXEC_ERRORS');
            FND_MESSAGE.SET_TOKEN('ROUTINE', l_api_name, FALSE);
            FND_MESSAGE.SET_TOKEN('SQLERRM', sqlerrm, FALSE);
            FND_MSG_PUB.ADD;
            fnd_msg_pub.count_and_get
              ( p_count => x_msg_count
              , p_data  => x_msg_data);
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            return;
     END CONSOLIDATE_QUANTITIES;

      PROCEDURE GET_SHIPPING_PARAMETERS(p_ship_quantity            IN CSP_SCH_INT_PVT.CSP_SHIP_QUANTITY_TBL_TYPE,
                                       x_resource_ship_parameters OUT NOCOPY CSP_SCH_INT_PVT.CSP_ORGS_SHIP_PARAM_TBL_TYPE
                                      ,x_ship_count               OUT NOCOPY CSP_SCH_INT_PVT.CSP_SHIP_METHOD_COUNT_TBL_TYP
                                      ,x_return_status            OUT NOCOPY VARCHAR2
                                      ,x_msg_data                 OUT NOCOPY VARCHAR2
                                      ,x_msg_count                OUT NOCOPY NUMBER) IS
        CURSOR csp_ship_methodes(from_org varchar2,to_org varchar2) IS
        SELECT ISM.SHIP_METHOD,NVL(ISM.COST_PER_UNIT_LOAD_WEIGHT,0)
       ,CDT.FREIGHT_CODE,CDT.LEAD_TIME,CDT.LEAD_TIME_UOM,CDT.DELIVERY_TIME
       ,CDT.CUTOFF_TIME,CDT.TIMEZONE_ID,CDT.SAFETY_ZONE
        FROM   MTL_INTERORG_SHIP_METHODS ISM,CSP_CARRIER_DELIVERY_TIMES CDT
        WHERE  ISM.FROM_ORGANIZATION_ID = from_org
        AND    ISM.TO_ORGANIZATION_ID =  to_org
        AND    CDT.ORGANIZATION_ID = from_org
        AND    CDT.SHIPPING_METHOD = ISM.SHIP_METHOD;

        CURSOR C2(c_resource_type varchar2, c_resource_id NUMBER)
        IS
        SELECT TIMEZONE_ID
        FROM   CSP_RS_SHIP_TO_ADDRESSES_V
        WHERE  PRIMARY_FLAG ='Y'
        AND resource_id  = c_resource_id
        AND resource_type = c_resource_type;

        CURSOR get_organization_code(l_org_id number) IS
        SELECT ORGANIZATION_CODE
        FROM   MTL_PARAMETERS
        WHERE  ORGANIZATION_ID = l_org_id;

        cursor csp_location_ship_methods(c_from_org_id number, c_to_location_id number) IS
        select shipping_method,
               shipping_cost,
               intransit_time,
               from_location_id,
               to_location_id,
               destination_type
        from   csp_shipping_details_v
        where  organization_id = c_from_org_id
        and    to_location_id = c_to_location_id;


        l_default_unit_for_hour  varchar2(3);
        l_ship_methode           VARCHAR2(30);
        l_cost_per_unit          NUMBER;
        l_lead_time              NUMBER;
        l_freight_code           Varchar2(30);
        l_lead_time_uom          varchar2(3);
        l_delivery_time           date;
        l_cutoff_time            date;
        l_timezone_id            NUMBER;
        l_saftey_zone            number;
        l_hours                  NUMBER;
        l_server_timezone_id     NUMBER;
        l_shipto_timezone_id   NUMBER;
        l_delivery_date          DATE;
        l_days                   NUMBER;
        shipping_option         BOOLEAN;

        l_shipping_methode_count NUMBER;
        l_need_by_date           DATE;
        l_min_lead_time      NUMBER;
        l_max_lead_time      NUMBER;
        l_server_time_zone_id NUMBER;
        l_msg_count           NUMBER;
        l_cutoff_hours        NUMBER;
        l_sys_hours           NUMBER;
        l_msg_data            VARCHAR2(2000);
        l_return_status       VARCHAR2(3);
        l_server_delivery_date DATE;
        l_server_cutoff_time   DATE;
        l_api_name             VARCHAR2(60) := 'CSP_SCH_INT_PVT.GET_SHIPPING_PARAMETERS';
        l_from_org_code        VARCHAR2(10);
        l_to_org_code           VARCHAR2(10);
        l_sysdate              DATE;
        l_server_sys_date      Date;
        l_from_location_id     NUMBER;
        l_to_location_id       NUMBER ;
        l_destination_type     varchar2(1);
        l_ship_method_present_for_loc boolean := false;
        l_ship_method_present_for_reg boolean :=false;
     BEGIN
            l_server_sys_date := sysdate;
            x_return_status := FND_API.G_RET_STS_SUCCESS;
            l_default_unit_for_hour := FND_PROFILE.VALUE(NAME => 'CSF_UOM_HOURS');
            l_server_time_zone_id   := FND_PROFILE.VALUE(NAME => 'SERVER_TIMEZONE_ID');

            IF g_interval.latest_time IS NOT NULL
            THEN
               l_need_by_date := g_interval.latest_time;
            ELSE
               l_need_by_date := g_interval.earliest_time;
            END IF;
            x_resource_ship_parameters :=  CSP_SCH_INT_PVT.CSP_ORGS_SHIP_PARAM_TBL_TYPE();
            x_ship_count := CSP_SCH_INT_PVT.CSP_SHIP_METHOD_COUNT_TBL_TYP();
            x_ship_count.trim(x_ship_count.count) ;
            FOR I IN 1..p_ship_quantity.count LOOP
                IF p_ship_quantity(I).resource_type = 'DUMMY'          and
                   p_ship_quantity(I).resource_id =  '999999999999999'  or g_shipto_timezone_id is not null THEN
                   l_shipto_timezone_id := g_shipto_timezone_id;
                ELSE
                    OPEN C2(p_ship_quantity(I).resource_type, p_ship_quantity(I).resource_id);
                    LOOP
                        FETCH C2 INTO l_shipto_timezone_id;
                        EXIT WHEN C2%NOTFOUND;
                    END LOOP;
                    CLOSE C2;
                END IF;
                IF l_shipto_timezone_id <> l_server_time_zone_id THEN
                            HZ_TIMEZONE_PUB.Get_Time(   p_api_version  => 1.0,
                                    p_init_msg_list  => FND_API.G_FALSE,
                                    p_source_tz_id   => l_server_time_zone_id,
                                    p_dest_tz_id     => l_shipto_timezone_id,
                                    p_source_day_time  => sysdate,
                                    x_dest_day_time    => l_sysdate,
                                    x_return_status    => l_return_status ,
                                    x_msg_count        => l_msg_count ,
                                    x_msg_data         => l_msg_data);
                  ELSE
                      l_sysdate := sysdate;
                  END IF;
                l_min_lead_time  := 0;
                l_max_lead_time  := 0;
                l_shipping_methode_count := 0;
                OPEN csp_location_ship_methods(p_ship_quantity(I).from_org_id,p_ship_quantity(I).destination_location_id);
                LOOP
                    FETCH csp_location_ship_methods INTO l_ship_methode,l_cost_per_unit,l_lead_time,l_from_location_id,l_to_location_id,l_destination_type;
                    EXIT WHEN csp_location_ship_methods%NOTFOUND;
                    if not l_ship_method_present_for_loc then
                        if l_destination_type = 'L' THEN
                            l_ship_method_present_for_loc := true;
                        end if;
                        if not l_ship_method_present_for_reg then
                          if l_destination_type = 'R' THEN
                            l_ship_method_present_for_reg := true;
                          end if;
                        end if;
                    end if ;
                    shipping_option := false;
                    if l_ship_method_present_for_loc AND l_destination_type = 'L' THEN
                            shipping_option := true;
                    end if;
                    if not l_ship_method_present_for_loc AND l_ship_method_present_for_reg AND l_destination_type = 'R' THEN
                        shipping_option := true;
                    END IF;
                    if not l_ship_method_present_for_loc AND NOT l_ship_method_present_for_reg AND l_destination_type = 'Z' THEN
                        shipping_option := true;
                    END IF;
                        l_delivery_date := trunc(l_sysdate + l_lead_time);
                         IF l_shipto_timezone_id <> l_server_time_zone_id THEN
                            HZ_TIMEZONE_PUB.Get_Time(   p_api_version  => 1.0,
                                    p_init_msg_list  => FND_API.G_FALSE,
                                    p_source_tz_id   => l_shipto_timezone_id,
                                    p_dest_tz_id     => l_server_time_zone_id,
                                    p_source_day_time  => l_delivery_date,
                                    x_dest_day_time    => l_server_delivery_date,
                                    x_return_status    => l_return_status ,
                                    x_msg_count        => l_msg_count ,
                                    x_msg_data         => l_msg_data);
                        ELSE
                            l_server_delivery_date := l_delivery_date;
                        END IF;
                        IF  shipping_option then
                            l_shipping_methode_count := l_shipping_methode_count + 1;
                        IF l_shipping_methode_count = 1 THEN
                            l_min_lead_time :=  (l_server_delivery_date - l_server_sys_date) * 24 ;
                            l_max_lead_time :=  (l_server_delivery_date - l_server_sys_date) * 24 ;
                        ELSE
                            IF l_min_lead_time > (l_server_delivery_date - l_server_sys_date) * 24 THEN
                               l_min_lead_time :=  (l_server_delivery_date - l_server_sys_date) * 24 ;
                            END IF;
                            IF l_max_lead_time < (l_server_delivery_date - l_server_sys_date) * 24 THEN
                                l_max_lead_time :=  (l_server_delivery_date - l_server_sys_date) * 24 ;
                            END IF;
                        END IF;
                        x_resource_ship_parameters.extend ;
                    x_resource_ship_parameters(x_resource_ship_parameters.count).resource_type
                                                                := p_ship_quantity(I).resource_type ;
                    x_resource_ship_parameters(x_resource_ship_parameters.count).resource_id
                                                                := p_ship_quantity(I).resource_id ;
                    x_resource_ship_parameters(x_resource_ship_parameters.count).from_org_id
                                                                := p_ship_quantity(I).from_org_id;
                    x_resource_ship_parameters(x_resource_ship_parameters.count).to_org_id
                                                                := p_ship_quantity(I).to_org_id;
                    x_resource_ship_parameters(x_resource_ship_parameters.count).quantity
                                                                := p_ship_quantity(I).quantity ;
                    x_resource_ship_parameters(x_resource_ship_parameters.count).shipping_method
                                                                := l_ship_methode ;
                    x_resource_ship_parameters(x_resource_ship_parameters.count).lead_time
                                                                := (l_server_delivery_date - l_server_sys_date) * 24  ;
                    x_resource_ship_parameters(x_resource_ship_parameters.count).transfer_cost
                                                                := NVL(l_cost_per_unit,0);
                    x_resource_ship_parameters(x_resource_ship_parameters.count).delivery_time := l_server_delivery_date;
                    END IF;
                END LOOP;
              IF csp_location_ship_methods % ROWCOUNT = 0 THEN
                CLOSE csp_location_ship_methods;
                OPEN CSP_SHIP_METHODES(p_ship_quantity(I).from_org_id,p_ship_quantity(I).to_org_id);
                LOOP
                    FETCH CSP_SHIP_METHODES INTO l_ship_methode,l_cost_per_unit,l_freight_code,l_lead_time,l_lead_time_uom,
                                     l_delivery_time,l_cutoff_time, l_timezone_id, l_saftey_zone;
                    EXIT WHEN CSP_SHIP_METHODES%NOTFOUND;
                    l_hours := 0;
                    l_days := 0;
                    shipping_option := true;
                    IF l_lead_time > 0 THEN
                        l_hours := inv_convert.inv_um_convert (null,6,l_lead_time,l_lead_time_uom,l_default_unit_for_hour,null,null);
                        IF l_hours >= 24 then
                            IF l_delivery_time is null THEN
                                l_hours := l_hours ;
                                l_delivery_date := (l_sysdate + (1/24) * l_hours);
                            ELSE
                                l_days := round (l_hours / 24 ) ;
                                l_delivery_date := trunc(l_sysdate + l_days) ;
                                l_hours :=  TO_NUMBER(to_char(l_delivery_time,'HH24'))  +  TO_NUMBER(to_char(l_delivery_time,'MI')) * (1/60);
                                l_delivery_date := (l_delivery_date + (1/24) * l_hours);
                            END IF;
                        ELSE
                            IF l_delivery_time is null THEN
                                l_delivery_date := (l_sysdate + (1/24) * l_hours);
                            ELSE
                                IF ((to_number(to_char(l_delivery_time,'HH24')) + (1/60) * to_number(to_char(l_delivery_time,'MI')))
                                     - (to_number(to_char(l_sysdate ,'HH24'))  + (1/60) * to_number(to_char(l_sysdate,'MI'))) ) > l_hours THEN
                                    l_delivery_date := (l_sysdate + (1/24) * l_hours);
                                ELSE
                                    shipping_option := FALSE;
                                END IF;
                            END IF;
                        END IF;
                    END IF;
                    IF l_saftey_zone IS NOT NULL THEN
                        l_delivery_date := l_delivery_date + (l_saftey_zone * 1/24) ;
                    END IF;

                      IF l_shipto_timezone_id <> l_server_time_zone_id THEN
                            HZ_TIMEZONE_PUB.Get_Time(   p_api_version  => 1.0,
                                    p_init_msg_list  => FND_API.G_FALSE,
                                    p_source_tz_id   => l_shipto_timezone_id,
                                    p_dest_tz_id     => l_server_time_zone_id,
                                    p_source_day_time  => l_delivery_date,
                                    x_dest_day_time    => l_server_delivery_date,
                                    x_return_status    => l_return_status ,
                                    x_msg_count        => l_msg_count ,
                                    x_msg_data         => l_msg_data);
                        ELSE
                            l_server_delivery_date := l_delivery_date;
                        END IF;

                        IF l_cutoff_time is not null then
                            HZ_TIMEZONE_PUB.Get_Time(   p_api_version  => 1.0,
                                    p_init_msg_list  => FND_API.G_FALSE,
                                    p_source_tz_id   => l_timezone_id,
                                    p_dest_tz_id     => l_server_time_zone_id,
                                    p_source_day_time  => l_cutoff_time,
                                    x_dest_day_time    => l_server_cutoff_time,
                                    x_return_status    => l_return_status ,
                                    x_msg_count        => l_msg_count ,
                                    x_msg_data         => l_msg_data);
                                    l_cutoff_hours := to_number(to_char(l_server_cutoff_time,'HH24')) + (to_number(to_char(l_server_cutoff_time,'MI')) * 1/60);
                                    l_sys_hours    := to_number(to_char(l_sysdate,'HH24')) + (to_number(to_char(l_sysdate,'MI')) * 1/60);

                            IF l_cutoff_hours < l_sys_hours THEN
                                l_server_delivery_date := l_server_delivery_date + 1;
                            END IF;
                        END IF;
                  /*  IF l_need_by_date IS NOT NULL AND  l_server_delivery_date > l_need_by_date THEN
                            shipping_option := FALSE;
                    END IF;*/
                       IF  shipping_option then
                        l_shipping_methode_count := l_shipping_methode_count + 1;
                        IF l_shipping_methode_count = 1 THEN
                            l_min_lead_time :=  (l_server_delivery_date - l_server_sys_date) * 24 ;
                            l_max_lead_time :=  (l_server_delivery_date - l_server_sys_date) * 24 ;
                        ELSE
                            IF l_min_lead_time > (l_server_delivery_date - l_server_sys_date) * 24 THEN
                               l_min_lead_time :=  (l_server_delivery_date - l_server_sys_date) * 24 ;
                            END IF;
                            IF l_max_lead_time < (l_server_delivery_date - l_server_sys_date) * 24 THEN
                                l_max_lead_time :=  (l_server_delivery_date - l_server_sys_date) * 24 ;
                            END IF;
                        END IF;
                        x_resource_ship_parameters.extend ;
                    x_resource_ship_parameters(x_resource_ship_parameters.count).resource_type
                                                                := p_ship_quantity(I).resource_type ;
                    x_resource_ship_parameters(x_resource_ship_parameters.count).resource_id
                                                                := p_ship_quantity(I).resource_id ;
                    x_resource_ship_parameters(x_resource_ship_parameters.count).from_org_id
                                                                := p_ship_quantity(I).from_org_id;
                    x_resource_ship_parameters(x_resource_ship_parameters.count).to_org_id
                                                                := p_ship_quantity(I).to_org_id;
                    x_resource_ship_parameters(x_resource_ship_parameters.count).quantity
                                                                := p_ship_quantity(I).quantity ;
                    x_resource_ship_parameters(x_resource_ship_parameters.count).shipping_method
                                                                := l_ship_methode ;
                    x_resource_ship_parameters(x_resource_ship_parameters.count).lead_time
                                                                := (l_server_delivery_date - l_server_sys_date) * 24  ;
                    x_resource_ship_parameters(x_resource_ship_parameters.count).transfer_cost
                                                                := NVL(l_cost_per_unit,0);
                    x_resource_ship_parameters(x_resource_ship_parameters.count).delivery_time := l_server_delivery_date;
                    END IF;
                END LOOP;
                    IF csp_ship_methodes%ROWCOUNT = 0 and  (p_ship_quantity(I).from_org_id <> p_ship_quantity(I).to_org_id) THEN
                         open get_organization_code(p_ship_quantity(I).from_org_id);
                         LOOP
                             FETCH get_organization_code INTO l_from_org_code;
                             EXIT WHEN get_organization_code % NOTFOUND;
                         END LOOP;
                         CLOSE get_organization_code;
                         open get_organization_code(p_ship_quantity(I).to_org_id);
                         LOOP
                             FETCH get_organization_code INTO l_to_org_code;
                             EXIT WHEN get_organization_code % NOTFOUND;
                         END LOOP;
                         CLOSE get_organization_code;
                         FND_MESSAGE.SET_NAME('CSP', 'CSP_SCH_SHIPMETHOD_NOT_DEFINED');
                         FND_MESSAGE.SET_TOKEN('FROM_ORG', l_from_org_code, TRUE);
                         FND_MESSAGE.SET_TOKEN('TO_ORG', l_to_org_code, TRUE);
                         FND_MSG_PUB.ADD;
                         fnd_msg_pub.count_and_get
                                            ( p_count => x_msg_count
                                            , p_data  => x_msg_data);
                         x_return_status := FND_API.G_RET_STS_ERROR;
                         return;
                    END IF;
                    IF csp_ship_methodes%ISOPEN THEN
                        CLOSE csp_ship_methodes;
                    END IF;
                END IF;
                    IF csp_location_ship_methods %ISOPEN THEN
                        CLOSE csp_location_ship_methods;
                    END IF;
                x_ship_count.extend;
                x_ship_count(x_ship_count.count).from_org_id       := p_ship_quantity(I).from_org_id ;
                x_ship_count(x_ship_count.count).to_org_Id         := p_ship_quantity(I).to_org_id ;
                x_ship_count(x_ship_count.count).shipping_methodes := l_shipping_methode_count ;
                x_ship_count(x_ship_count.count).min_leadtime      := l_min_lead_time;
                x_ship_count(x_ship_count.count).max_leadtime      := l_max_lead_time;
            END LOOP;

            EXCEPTION
            WHEN OTHERS THEN
            FND_MESSAGE.SET_NAME('CSP', 'CSP_UNEXPECTED_EXEC_ERRORS');
            FND_MESSAGE.SET_TOKEN('ROUTINE', l_api_name, TRUE);
            FND_MESSAGE.SET_TOKEN('SQLERRM', sqlerrm, TRUE);
            FND_MSG_PUB.ADD;
            fnd_msg_pub.count_and_get
              ( p_count => x_msg_count
              , p_data  => x_msg_data);
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            return;
     END GET_SHIPPING_PARAMETERS;
     PROCEDURE GET_DELIVERY_DATE(p_relation_ship_id  IN  NUMBER,
                                 x_delivery_date     OUT NOCOPY DATE,
                                 x_shipping_option   OUT NOCOPY BOOLEAN,
                                 x_return_status     OUT NOCOPY VARCHAR2,
                                 x_msg_data          OUT NOCOPY VARCHAR2,
                                 x_msg_count         OUT NOCOPY NUMBER) IS
        CURSOR C1(c_relation_id NUMBER) IS
        SELECT CDT.LEAD_TIME,CDT.LEAD_TIME_UOM,CDT.DELIVERY_TIME
              ,CDT.CUTOFF_TIME,CDT.TIMEZONE_ID,CDT.SAFETY_ZONE
        FROM   CSP_CARRIER_DELIVERY_TIMES CDT
        WHERE  CDT.relation_ship_id = c_relation_id;
        I NUMBER;
        l_hours     NUMBER;
        l_days      NUMBER;
        l_lead_time NUMBER;
        l_lead_time_uom varchar2(3);
        l_delivery_time DATE;
        l_cutoff_time DATE;
        l_timezone_id NUMBER;
        l_saftey_zone NUMBER;
        l_delivery_date DATE;
        l_default_unit_for_hour  varchar2(3);
        l_api_name varchar2(60) := 'CSP_SCH_INT_PVT.GET_DELIVERY_DATE' ;
      BEGIN
            x_return_status := FND_API.G_RET_STS_SUCCESS ;
          l_default_unit_for_hour := FND_PROFILE.VALUE(NAME => 'CSF_UOM_HOURS');
            OPEN C1(p_relation_ship_id);
            LOOP
                FETCH C1 INTO l_lead_time,l_lead_time_uom,l_delivery_time,l_cutoff_time, l_timezone_id, l_saftey_zone;
                    EXIT WHEN C1%NOTFOUND;
                    l_hours := 0;
                    l_days := 0;
                    x_shipping_option := true;
                    IF l_lead_time > 0 THEN
                        l_hours := inv_convert.inv_um_convert (null,6,l_lead_time,l_lead_time_uom,l_default_unit_for_hour,null,null);
                        IF l_hours >= 24 then
                            IF l_delivery_time is null THEN
                                l_hours := l_hours ;
                                l_delivery_date := (SYSDATE + (1/24) * l_hours);
                            ELSE
                                l_days := round (l_hours / 24 ) ;
                                l_delivery_date := trunc(SYSDATE + l_days) ;
                                l_hours :=  TO_NUMBER(to_char(l_delivery_time,'HH24'))  +  TO_NUMBER(to_char(l_delivery_time,'MI')) * (1/60);
                                l_delivery_date := (l_delivery_date + (1/24) * l_hours);
                            END IF;
                        ELSE
                            IF l_delivery_time is null THEN
                                l_delivery_date := (SYSDATE + (1/24) * l_hours);
                            ELSE
                                IF ((to_number(to_char(l_delivery_time,'HH24')) + (1/60) * to_number(to_char(l_delivery_time,'MI')))
                                     - (to_number(to_char(sysdate ,'HH24'))  + (1/60) * to_number(to_char(sysdate,'MI'))) ) > l_hours THEN
                                    l_delivery_date := (SYSDATE + (1/24) * l_hours);
                                ELSE
                                    x_shipping_option := FALSE;
                                END IF;
                            END IF;
                        END IF;
                    END IF;
            END LOOP;
                CLOSE C1;
                    IF l_saftey_zone IS NOT NULL THEN
                        l_delivery_date := l_delivery_date + (l_saftey_zone * 1/24) ;
                    END IF;
                    x_delivery_date := l_delivery_date;
            EXCEPTION
            WHEN OTHERS THEN
            FND_MESSAGE.SET_NAME('CSP', 'CSP_UNEXPECTED_EXEC_ERRORS');
            FND_MESSAGE.SET_TOKEN('ROUTINE', l_api_name, FALSE);
            FND_MESSAGE.SET_TOKEN('SQLERRM', sqlerrm, FALSE);
            FND_MSG_PUB.ADD;
            fnd_msg_pub.count_and_get
              ( p_count => x_msg_count
              , p_data  => x_msg_data);
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            return;
      END GET_DELIVERY_DATE;

    PROCEDURE EXTEND_ATP_REC(p_atp_rec IN OUT NOCOPY mrp_atp_pub.atp_rec_typ
                             ,x_return_status OUT NOCOPY VARCHAR2) IS

    BEGIN
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        p_atp_rec.Row_Id.Extend;
        p_atp_rec.Instance_Id.Extend;
        p_atp_rec.Inventory_Item_Id.Extend;
        p_atp_rec.Inventory_Item_Name.Extend;
        p_atp_rec.Source_Organization_Id.Extend;
        p_atp_rec.Source_Organization_Code.Extend;
        p_atp_rec.organization_id.Extend;
        p_atp_rec.Identifier.Extend;
        p_atp_rec.Demand_Source_Header_Id.Extend;
        p_atp_rec.Demand_Source_Delivery.Extend;
        p_atp_rec.Demand_Source_Type.Extend;
        p_atp_rec.Scenario_Id.Extend;
        p_atp_rec.Calling_Module.Extend;
        p_atp_rec.Customer_Id.Extend;
        p_atp_rec.Customer_Site_Id.Extend;
        p_atp_rec.Destination_Time_Zone.Extend;
        p_atp_rec.Quantity_Ordered.Extend;
        p_atp_rec.Quantity_UOM.Extend;
        p_atp_rec.Requested_Ship_Date.Extend;
        p_atp_rec.Requested_Arrival_Date.Extend;
        p_atp_rec.Earliest_Acceptable_Date.Extend;
        p_atp_rec.Latest_Acceptable_Date.Extend;
        p_atp_rec.Delivery_Lead_Time.Extend;
        p_atp_rec.Freight_Carrier.Extend;
        p_atp_rec.Ship_Method.Extend;
        p_atp_rec.Demand_Class.Extend;
        p_atp_rec.Ship_Set_Name.Extend;
        p_atp_rec.Arrival_Set_Name.Extend;
        p_atp_rec.Override_Flag.Extend;
        p_atp_rec.Action.Extend;
        p_atp_rec.Ship_Date.Extend;
        p_atp_rec.Available_Quantity.Extend;
        p_atp_rec.Requested_Date_Quantity.Extend;
        p_atp_rec.Group_Ship_Date.Extend;
        p_atp_rec.Group_Arrival_Date.Extend;
        p_atp_rec.Vendor_Id.Extend;
        p_atp_rec.Vendor_Name.Extend;
        p_atp_rec.Vendor_Site_Id.Extend;
        p_atp_rec.Vendor_Site_Name.Extend;
        p_atp_rec.Insert_Flag.Extend;
        p_atp_rec.OE_Flag.Extend;
        p_atp_rec.Error_Code.Extend;
        p_atp_rec.Atp_Lead_Time.Extend;
        p_atp_rec.Message.Extend;
        p_atp_rec.End_Pegging_Id.EXTEND;
        p_atp_rec.Order_Number.EXTEND;
        p_atp_rec.Old_Source_Organization_Id.EXTEND;
        p_atp_rec.Old_Demand_Class.EXTEND;
        EXCEPTION
        WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            return;
    END EXTEND_ATP_REC;

    FUNCTION CREATE_RESERVATION(p_reservation_parts IN CSP_SCH_INT_PVT.RESERVATION_REC_TYP
                                ,x_return_status     OUT NOCOPY VARCHAR2
                                ,x_msg_data         OUT NOCOPY VARCHAR2)
    RETURN NUMBER
    IS
          CURSOR csp_transactions IS
          SELECT TRANSACTION_SOURCE_TYPE_ID,TRANSACTION_SOURCE_TYPE_NAME
          FROM   MTL_TXN_SOURCE_TYPES
          WHERE  transaction_source_type_id = 13;
          I NUMBER;
          l_api_version_number number :=1;
          l_init_msg_lst  varchar2(1) := fnd_api.g_true;
          x_msg_count number;
         -- x_msg_data  varchar2(128);
          l_rsv_rec  inv_reservation_global.mtl_reservation_rec_type;
          l_serial_number inv_reservation_global.serial_number_tbl_type;
          x_serial_number inv_reservation_global.serial_number_tbl_type;
          l_partial_reservation_flag varchar2(1):= fnd_api.g_false;
          l_force_reservation_flag varchar2(1) := fnd_api.g_true;
          l_validation_flag    varchar2(1) := fnd_api.g_true;
          l_source_type_id     NUMBER;
          l_source_name        varchar2(30);
          x_quantity_reserved  number;
          x_reservation_id number;
          l_avail_qty number;
          l_msg varchar2(2000);
          --x_return_status varchar(128);
		  l_serial_number_rec_type inv_reservation_global.serial_number_rec_type;
		  l_org_serial_number inv_reservation_global.serial_number_tbl_type;
		  cursor c_get_serial_numbers(v_res_id number, v_item_id number) is
			SELECT SERIAL_NUMBER
			FROM Mtl_Serial_Numbers
			WHERE reservation_id  = v_res_id
			AND INVENTORY_ITEM_ID = v_item_id;
		counter number;
		l_ext_resv_tbl inv_reservation_global.mtl_reservation_tbl_type;
		l_ext_rsc_tbl_cnt number;
		l_error_code number;

     BEGIN
          log('create_reservation','In function Create_reservation');
          x_return_status  := FND_API.G_RET_STS_SUCCESS;
          OPEN csp_transactions;
            LOOP
                FETCH csp_transactions INTO l_source_type_id, l_source_name;
                EXIT WHEN csp_transactions%NOTFOUND;
            END LOOP;
          CLOSE csp_transactions;
                IF l_source_type_id IS NULL THEN
                    raise NO_DATA_FOUND ;
                END IF;
				/*
                 IF p_reservation_parts.sub_inventory_code IS NULL THEN
                  FND_MSG_PUB.INITIALIZE;
                  FND_MESSAGE.SET_NAME('CSP', 'CSP_RES_SUBINV_NULL');
                  FND_MSG_PUB.ADD;
                  fnd_msg_pub.count_and_get
                  ( p_count => x_msg_count
                    , p_data  => x_msg_data);
                  x_return_status := FND_API.G_RET_STS_ERROR;
                  RETURN 0;
              	 END IF;
				 */
                begin
                    select LOT INTO l_rsv_rec.lot_number
                    from MTL_ONHAND_LOT_V
                    where INVENTORY_ITEM_ID=p_reservation_parts.item_id
                    and SUBINVENTORY_CODE = p_reservation_parts.sub_inventory_code
                    and organization_id=p_reservation_parts.organization_id
                    and rownum=1;
                    EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                      l_rsv_rec.lot_number:=null;
                end;
                l_rsv_rec.reservation_id   := NULL;
                l_rsv_rec.requirement_date := p_reservation_parts.need_by_date  ;
                l_rsv_rec.organization_id  := p_reservation_parts.organization_id  ;
                l_rsv_rec.inventory_item_id := p_reservation_parts.item_id   ;
                l_rsv_rec.demand_source_type_id  := l_source_type_id ;
                l_rsv_rec.demand_source_name     := l_source_name ;
                l_rsv_rec.demand_source_header_id   := NULL;
                l_rsv_rec.demand_source_line_id     := p_reservation_parts.line_id;
                l_rsv_rec.demand_source_delivery    := NULL;
                l_rsv_rec.primary_uom_code          := p_reservation_parts.item_UOM_code ;
                l_rsv_rec.primary_uom_id            := NULL;
                l_rsv_rec.reservation_uom_code      := p_reservation_parts.item_UOM_code;
                l_rsv_rec.reservation_uom_id        := NULL;
                l_rsv_rec.reservation_quantity      := p_reservation_parts.quantity_needed;
                l_rsv_rec.primary_reservation_quantity  := NUll;
                l_rsv_rec.detailed_quantity         := null;
                l_rsv_rec.autodetail_group_id       := NULL;
                l_rsv_rec.external_source_code       := NULL;
                l_rsv_rec.external_source_line_id     := NULL;
                l_rsv_rec.supply_source_type_id        := 13; --inv_reservation_global.g_source_type_internal_req;
                l_rsv_rec.supply_source_header_id      := NULL;
                l_rsv_rec.supply_source_line_id        := NULL;
                l_rsv_rec.supply_source_name           := NULL;
                l_rsv_rec.supply_source_line_detail    := NULL;
                l_rsv_rec.revision                     := p_reservation_parts.revision ;
                l_rsv_rec.subinventory_code            := p_reservation_parts.sub_inventory_code ;
                l_rsv_rec.subinventory_id              := NULL ;
                l_rsv_rec.locator_id                   := NULL;
                --l_rsv_rec.lot_number                   := NULL;
                l_rsv_rec.lot_number_id                := NULL;
                l_rsv_rec.pick_slip_number            := NULL;
                l_rsv_rec.lpn_id                      := NULL;
                l_rsv_rec.attribute_category       := NULL;
                l_rsv_rec.attribute1               := NULL;
                l_rsv_rec.attribute2               := NULL;
                l_rsv_rec.attribute3               := NULL;
                l_rsv_rec.attribute4               := NULL;
                l_rsv_rec.attribute5               := NULL;
                l_rsv_rec.attribute6               := NULL;
                l_rsv_rec.attribute7               := NULL;
                l_rsv_rec.attribute8               := NULL;
                l_rsv_rec.attribute9               := NULL;
                l_rsv_rec.attribute10              := NULL;
                l_rsv_rec.attribute11              := NULL;
                l_rsv_rec.attribute12              := NULL;
                l_rsv_rec.attribute13              := NULL;
                l_rsv_rec.attribute14              := NULL;
                l_rsv_rec.attribute15              := NULL;
                l_rsv_rec.ship_ready_flag          := NULL;

                l_avail_qty := csp_validate_pub.get_avail_qty(l_rsv_rec.organization_id,
                                               l_rsv_rec.subinventory_code,
                                               l_rsv_rec.locator_id,
                                               l_rsv_rec.inventory_item_id,
                                               l_rsv_rec.revision,
                                               l_rsv_rec.lot_number);
                log('create_reservation','Avail Quatity: '||l_avail_qty);

                IF l_avail_qty >= l_rsv_rec.reservation_quantity THEN
					log('create_reservation','p_reservation_parts.serial_number = ' || p_reservation_parts.serial_number);

					if p_reservation_parts.serial_number is not null then
						l_serial_number_rec_type.inventory_item_id := p_reservation_parts.item_id;
						l_serial_number_rec_type.serial_number := p_reservation_parts.serial_number;
						l_serial_number(1) := l_serial_number_rec_type;

						-- first check if we already have reservation for this record
						inv_reservation_pub.query_reservation(p_api_version_number => l_api_version_number,
												p_query_input => l_rsv_rec,
												x_mtl_reservation_tbl => l_ext_resv_tbl,
												x_mtl_reservation_tbl_count => l_ext_rsc_tbl_cnt,
												x_error_code => l_error_code,
												x_return_status => x_return_status,
												x_msg_count => x_msg_count,
												x_msg_data => x_msg_data);

						log('create_reservation','after calling query_reservation x_return_status = ' || x_return_status);

						if x_return_status <> FND_API.G_RET_STS_SUCCESS then
							RAISE fnd_api.g_exc_error;
							return 0;
						end if;

						log('create_reservation','l_ext_resv_tbl.COUNT = ' || l_ext_resv_tbl.COUNT);
						if l_ext_resv_tbl.COUNT > 0 then
							log('create_reservation','l_ext_resv_tbl(1).reservation_quantity = ' || l_ext_resv_tbl(1).reservation_quantity);
							l_rsv_rec.reservation_quantity := l_ext_resv_tbl(1).reservation_quantity + 1;
							l_rsv_rec.primary_reservation_quantity := l_ext_resv_tbl(1).primary_reservation_quantity + 1;

							log('create_reservation','l_ext_resv_tbl(1).reservation_id = ' || l_ext_resv_tbl(1).reservation_id);
							log('create_reservation','l_ext_resv_tbl(1).inventory_item_id = ' || l_ext_resv_tbl(1).inventory_item_id);
							counter := 1;
							for ser_rec in c_get_serial_numbers(l_ext_resv_tbl(1).reservation_id, l_ext_resv_tbl(1).inventory_item_id)
							loop
								l_serial_number_rec_type.inventory_item_id := l_ext_resv_tbl(1).inventory_item_id;
								l_serial_number_rec_type.serial_number := ser_rec.SERIAL_NUMBER;
								l_org_serial_number(counter) := l_serial_number_rec_type;
								l_serial_number(counter + 1) := l_serial_number_rec_type;
								counter := counter + 1;
							end loop;

							log('create_reservation','l_org_serial_number.COUNT = ' || l_org_serial_number.COUNT);
							log('create_reservation','l_serial_number.COUNT = ' || l_serial_number.COUNT);

							inv_reservation_pub.update_reservation(p_api_version_number => l_api_version_number,
													p_original_rsv_rec => l_ext_resv_tbl(1),
													p_to_rsv_rec => l_rsv_rec,
													p_original_serial_number => l_org_serial_number,
													p_to_serial_number => l_serial_number,
													x_return_status => x_return_status,
													x_msg_count => x_msg_count,
													x_msg_data => x_msg_data);

							log('create_reservation','x_return_status = ' || x_return_status);
							if x_return_status <> FND_API.G_RET_STS_SUCCESS then
								log('create_reservation','x_msg_data = ' || x_msg_data);
								RAISE fnd_api.g_exc_error;
								return 0;
							end if;
							log('create_reservation','Updated reservation ID:'||l_ext_resv_tbl(1).reservation_id);
							return l_ext_resv_tbl(1).reservation_id;
						end if;
					end if;

					INV_RESERVATION_PUB.create_reservation(p_api_version_number => l_api_version_number
                                                 , p_init_msg_lst => l_init_msg_lst
                                                 , x_return_status => x_return_status
                                                 , x_msg_count => x_msg_count
                                                 , x_msg_data => x_msg_data
                                                 , p_rsv_rec => l_rsv_rec
                                                 , p_serial_number => l_serial_number
                                                 , x_serial_number => x_serial_number
                                                 , p_partial_reservation_flag => l_partial_reservation_flag
                                                 , p_force_reservation_flag => l_force_reservation_flag
                                                 , p_validation_flag => l_validation_flag
                                                 , x_quantity_reserved => x_quantity_reserved
                                                 , x_reservation_id => x_reservation_id
                                                 );
           IF x_return_status <> FND_API.G_RET_STS_SUCCESS and x_reservation_id <= 0  THEN
                return 0;
           ELSE
                log('create_reservation','Created reservation ID:'||x_reservation_id);
                return x_reservation_id;
           END IF;
           ELSE
                FND_MSG_PUB.INITIALIZE;
                FND_MESSAGE.SET_NAME('CSP', 'CSP_INSUFFICIENT_QTY');
                FND_MSG_PUB.ADD;
                fnd_msg_pub.count_and_get
                  ( p_count => x_msg_count
                  , p_data  => x_msg_data);
                x_return_status := FND_API.G_RET_STS_ERROR;
                return 0;
           END IF;
           EXCEPTION
        WHEN NO_DATA_FOUND THEN
            FND_MESSAGE.SET_NAME('CSP', 'CSP_SCH_TRANSACTION');
            FND_MSG_PUB.ADD;
            fnd_msg_pub.count_and_get
              ( p_count => x_msg_count
              , p_data  => x_msg_data);
            x_return_status := FND_API.G_RET_STS_ERROR;
            return 0;
        WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            return 0;
     END CREATE_RESERVATION;
     PROCEDURE TRANSFER_RESERVATION(p_reservation_id  IN  NUMBER
                                   ,p_order_header_id IN  NUMBER
                                   ,p_order_line_id   IN  NUMBER
                                   ,x_return_status   OUT NOCOPY VARCHAR2
                                   ,x_reservation_id   OUT NOCOPY NUMBER
                                   ,x_msg_data        OUT NOCOPY VARCHAR2
                                   ,x_msg_count       OUT NOCOPY NUMBER) IS

          I NUMBER;
          l_api_version_number number :=1;
          l_init_msg_lst  varchar2(1) := fnd_api.g_true;
         -- x_msg_data  varchar2(128);
          l_old_rsv_rec  inv_reservation_global.mtl_reservation_rec_type;
          l_new_rsv_rec  inv_reservation_global.mtl_reservation_rec_type;
          l_old_serial_number inv_reservation_global.serial_number_tbl_type;
          l_new_serial_number inv_reservation_global.serial_number_tbl_type;
          l_partial_reservation_flag varchar2(1):= fnd_api.g_false;
          l_is_transfer_supply varchar2(1) := fnd_api.g_true;
          l_validation_flag    varchar2(1) := fnd_api.g_true;
          l_source_type_id     NUMBER;
          l_source_name        varchar2(30);
          x_quantity_reserved  number;
          l_msg varchar2(2000);
          --x_return_status varchar(128);
     BEGIN
          x_return_status  := FND_API.G_RET_STS_SUCCESS;

                l_old_rsv_rec.reservation_id   := p_reservation_id;

                l_new_rsv_rec.reservation_id   := NULL;
                l_new_rsv_rec.demand_source_type_id  := 8 ;
                l_new_rsv_rec.demand_source_name     := 'g_source_type_internal_ord' ;
                l_new_rsv_rec.demand_source_header_id   := p_order_header_id;
                l_new_rsv_rec.demand_source_line_id     := p_order_line_id ;
                INV_RESERVATION_PUB. transfer_reservation(
                                        p_api_version_number  =>  l_api_version_number
                                      , p_init_msg_lst        =>  l_init_msg_lst
                                      , x_return_status       =>  x_return_status
                                      , x_msg_count           =>  x_msg_count
                                      , x_msg_data            =>  x_msg_data
                                      , p_is_transfer_supply  =>  l_is_transfer_supply
                                      , p_original_rsv_rec    => l_old_rsv_rec
                                      , p_to_rsv_rec          => l_new_rsv_rec
                                      , p_original_serial_number => l_old_serial_number
                                      , p_to_serial_number       => l_new_serial_number
                                      , p_validation_flag        => l_validation_flag
                                      , x_to_reservation_id      => x_reservation_id
                                      );
           IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                 X_return_status := FND_API.G_RET_STS_ERROR;
                return;
           END IF;
           EXCEPTION
        WHEN NO_DATA_FOUND THEN
            X_return_status := FND_API.G_RET_STS_ERROR;
            return;
        WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            return;
     END TRANSFER_RESERVATION;
     PROCEDURE GET_SHIPPING_METHODE(p_from_org_id     IN   NUMBER,
                                   p_to_org_id        IN   NUMBER,
                                   p_need_by_date     IN   DATE,
                                   p_timezone_id     IN   NUMBER,
                                   x_shipping_methode OUT NOCOPY  VARCHAR2,
                                   x_intransit_time   OUT NOCOPY  NUMBER,
                                   x_return_status    OUT NOCOPY  VARCHAR2
                                   ,x_msg_data        OUT NOCOPY  VARCHAR2
                                   ,x_msg_count       OUT NOCOPY  NUMBER) IS
     CURSOR C3(from_org varchar2,to_org varchar2) IS
        SELECT NVL(ISM.COST_PER_UNIT_LOAD_WEIGHT,0),
               CDT.RELATION_SHIP_ID,CDT.CUTOFF_TIME,CDT.TIMEZONE_ID,ISM.SHIP_METHOD
        FROM   MTL_INTERORG_SHIP_METHODS ISM,CSP_CARRIER_DELIVERY_TIMES CDT
        WHERE  ISM.FROM_ORGANIZATION_ID = from_org
        AND    ISM.TO_ORGANIZATION_ID =  to_org
        AND    CDT.ORGANIZATION_ID = from_org
        AND    CDT.SHIPPING_METHOD = ISM.SHIP_METHOD;
        I NUMBER :=0;
        l_relation_ship_id NUMBER;
        l_cost             NUMBER;
        x_delivery_date    DATE;
        x_shipping_option  BOOLEAN := true;
        l_cutoff_time      DATE;
        l_timezone_id      NUMBER;
        l_shipto_timezone_id NUMBER;
        l_server_time_zone_id NUMBER;
        l_cutoff_hours       NUMBER;
        l_sys_hours          NUMBER;
        l_server_delivery_date DATE;
        l_server_cutoff_time DATE;
        l_return_status Varchar2(3);
        l_msg_count NUMBER;
        l_msg_data  varchar2(1000);
        l_min_leadtime NUMBER := 100000000;
        l_shipping_methode varchar2(30);
        l_api_name varchar2(60) := 'CSP_SCH_INT_PVT.GET_SHIPPING_METHODE' ;
     BEGIN
            x_return_status := FND_API.G_RET_STS_SUCCESS ;
            l_server_time_zone_id   := FND_PROFILE.VALUE(NAME => 'SERVER_TIMEZONE_ID');
            OPEN C3(p_from_org_id,p_to_org_id);
            LOOP
                FETCH C3 INTO l_cost,l_relation_ship_id ,l_cutoff_time,l_timezone_id,l_shipping_methode ;
                EXIT WHEN C3%NOTFOUND;
                CSP_SCH_INT_PVT.GET_DELIVERY_DATE(l_relation_ship_id, x_delivery_date,x_shipping_option,x_return_status,x_msg_data,x_msg_count);
                    IF p_timezone_id <> l_server_time_zone_id THEN
                            HZ_TIMEZONE_PUB.Get_Time(   p_api_version  => 1.0,
                                    p_init_msg_list  => FND_API.G_FALSE,
                                    p_source_tz_id   => p_timezone_id,
                                    p_dest_tz_id     => l_server_time_zone_id,
                                    p_source_day_time  => x_delivery_date,
                                    x_dest_day_time    => l_server_delivery_date,
                                    x_return_status    => l_return_status ,
                                    x_msg_count        => l_msg_count ,
                                    x_msg_data         => l_msg_data);
                        ELSE
                            l_server_delivery_date := x_delivery_date;
                        END IF;
                        IF l_cutoff_time is not null then
                            HZ_TIMEZONE_PUB.Get_Time(   p_api_version  => 1.0,
                                    p_init_msg_list  => FND_API.G_FALSE,
                                    p_source_tz_id   => l_timezone_id,
                                    p_dest_tz_id     => l_server_time_zone_id,
                                    p_source_day_time  => l_cutoff_time,
                                    x_dest_day_time    => l_server_cutoff_time,
                                    x_return_status    => l_return_status ,
                                    x_msg_count        => l_msg_count ,
                                    x_msg_data         => l_msg_data);
                                    l_cutoff_hours := to_number(to_char(l_server_cutoff_time,'HH24')) + (to_number(to_char(l_server_cutoff_time,'MI')) * 1/60);
                                    l_sys_hours    := to_number(to_char(sysdate,'HH24')) + (to_number(to_char(sysdate,'MI')) * 1/60);
                            IF l_cutoff_hours < l_sys_hours THEN
                                l_server_delivery_date := l_server_delivery_date + 1;
                            END IF;
                        END IF;
                    IF p_need_by_date IS NOT NULL AND  l_server_delivery_date > p_need_by_date THEN
                            x_shipping_option := FALSE;
                    END IF;
                    IF x_shipping_option THEN
                        IF l_min_leadtime > ( (l_server_delivery_date -  sysdate) * 24 )THEN
                            l_min_leadtime := ( (l_server_delivery_date -  sysdate) * 24 );
                            x_shipping_methode := l_shipping_methode ;
                            x_intransit_time  :=  l_min_leadtime / 24 ;
                        END IF;
                    END IF;
              END LOOP;
            EXCEPTION
            WHEN OTHERS THEN
             FND_MESSAGE.SET_NAME('CSP', 'CSP_UNEXPECTED_EXEC_ERRORS');
            FND_MESSAGE.SET_TOKEN('ROUTINE', l_api_name, FALSE);
            FND_MESSAGE.SET_TOKEN('SQLERRM', sqlerrm, FALSE);
            FND_MSG_PUB.ADD;
            fnd_msg_pub.count_and_get
              ( p_count => x_msg_count
              , p_data  => x_msg_data);
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            return;
     END GET_SHIPPING_METHODE;

PROCEDURE CHECK_PARTS_AVAILABILITY(
    p_resource        IN CSP_SCH_INT_PVT.csp_sch_resources_rec_typ ,
    p_organization_id IN NUMBER ,
    p_subinv_code     IN VARCHAR2 ,
    p_need_by_date    IN DATE ,
    p_parts_list      IN CSP_SCH_INT_PVT.CSP_PARTS_TBL_TYP1 ,
    p_timezone_id     IN NUMBER ,
    x_availability OUT NOCOPY CSP_SCH_INT_PVT.AVAILABLE_PARTS_TBL_TYP1 ,
    x_return_status OUT NOCOPY VARCHAR2 ,
    X_MSG_DATA OUT NOCOPY      VARCHAR2 ,
    x_msg_count OUT NOCOPY     NUMBER ,
    p_called_from IN VARCHAR2 ,
    p_location_id IN NUMBER DEFAULT NULL,
    p_include_alternates IN BOOLEAN DEFAULT NULL)
IS
TYPE alternate_item_rec_type
IS
  RECORD
  (
    item                    NUMBER ,
    revision                VARCHAR2(3) ,
    item_uom                VARCHAR2(10) ,
    item_quantity           NUMBER ,
    alternate_item          NUMBER ,
    alternate_item_uom      VARCHAR2(10) ,
    alternate_item_quantity NUMBER ,
    relation_type           NUMBER);
TYPE alternate_items_table_type
IS
  TABLE OF alternate_item_rec_type;

  CURSOR C1(c_resource_type VARCHAR2, c_resource_id NUMBER)
  IS
    /*SELECT TIMEZONE_ID
    FROM   CSP_RS_SHIP_TO_ADDRESSES_V
    WHERE  PRIMARY_FLAG ='Y'
    AND resource_id  = c_resource_id
    AND resource_type = c_resource_type;*/
    SELECT hzl.time_zone TIMEZONE_ID
    FROM csp_rs_cust_relations rcr,
      hz_cust_acct_sites cas,
      hz_cust_site_uses csu,
      hz_party_sites ps,
      hz_locations hzl
    WHERE rcr.customer_id     = cas.cust_account_id
    AND cas.cust_acct_site_id = csu.cust_acct_site_id (+)
    AND csu.site_use_code     = 'SHIP_TO'
    AND cas.party_site_id     = ps.party_site_id
    AND ps.location_id        = hzl.location_id
    AND csu.primary_flag      = 'Y'
    AND rcr.resource_type     =c_resource_type
    AND rcr.resource_id       = c_resource_id;

  CURSOR check_buy_from(c_item_id NUMBER,c_assignment_id NUMBER, c_organization_id NUMBER)
  IS
    /* SELECT vendor_id, vendor_site_id
    FROM  mrp_sources_v
    where assignment_set_id = c_assignment_id
    and   inventory_item_id = c_item_id
    and   organization_id  = c_organization_id
    and   source_type = 3;*/
    SELECT vendor_id,
      vendor_site_id
    FROM MRP_ITEM_SOURCING_LEVELS_V misl
    WHERE misl.organization_id = c_organization_id
    AND misl.assignment_set_id =c_assignment_id
    AND inventory_item_id      = c_item_id
    AND SOURCE_TYPE            = 3
    AND sourcing_level         =
      (SELECT MIN(sourcing_level)
      FROM MRP_ITEM_SOURCING_LEVELS_V
      WHERE organization_id   = c_organization_id
      AND assignment_set_id   = c_assignment_id
      AND inventory_item_id   = c_item_id
      AND sourcing_level NOT IN (2,9)
      );

  CURSOR primary_uom_code(item_id NUMBER,org_id NUMBER)
  IS
    SELECT PRIMARY_UOM_CODE
    FROM MTL_SYSTEM_ITEMS_B
    WHERE INVENTORY_ITEM_ID = item_id
    AND organization_id     = org_id;
  CURSOR substitutes(item_id NUMBER,org_id NUMBER)
  IS
    /* SELECT mri.RELATED_ITEM_ID
    FROM   MTL_RELATED_ITEMS_VIEW mri, mtl_parameters mp
    WHERE  mp.organization_id = org_id
    AND    mri.INVENTORY_ITEM_ID = item_id
    AND    mri.RELATIONSHIP_TYPE_ID = 2
    AND    mri.ORGANIZATION_ID  = MP.MASTER_ORGANIZATION_ID;*/
    SELECT mri.RELATED_ITEM_ID
    FROM MTL_RELATED_ITEMS mri,
      mtl_parameters mp
    WHERE mp.organization_id     = org_id
    AND mri.INVENTORY_ITEM_ID    = item_id
    AND mri.RELATIONSHIP_TYPE_ID = 2
    AND mri.ORGANIZATION_ID      = MP.MASTER_ORGANIZATION_ID;

  l_interval CSP_SCH_INT_PVT.csp_sch_interval_rec_typ;
  l_resources CSP_SCH_INT_PVT.csp_sch_resource_tbl_typ;
  l_resource_org_subinv CSP_SCH_INT_PVT.CSP_RESOURCE_ORG_tbl_TYP;
  l_unavailable_list CSP_SCH_INT_PVT.CSP_UNAVAILABILITY_TBL_TYPE ;
  l_available_list CSP_SCH_INT_PVT.CSP_AVAILABILITY_TBL_TYPE ;
  /* l_subinv_unavailable_list        CSP_SCH_INT_PVT.CSP_UNAVAILABILITY_TBL_TYPE ;
  l_subinv_available_list          CSP_SCH_INT_PVT.CSP_AVAILABILITY_TBL_TYPE ;*/
  l_eligible_resources_list CSP_SCH_INT_PVT.CSP_AVAILABILITY_TBL_TYPE ;
  l_final_unavailable_list CSP_SCH_INT_PVT.CSP_UNAVAILABILITY_TBL_TYPE ;
  l_parts_list CSP_SCH_INT_PVT.CSP_PARTS_TBL_TYPE;
  l_options CSP_SCH_INT_PVT.CSP_SHIP_PARAMETERS_TBL_TYPE;
  l_ship_count CSP_SCH_INT_PVT.CSP_SHIP_METHOD_COUNT_TBL_TYP;
  l_res_ship_parameters CSP_SCH_INT_PVT.CSP_ORGS_SHIP_PARAM_TBL_TYPE;
  l_temp_options CSP_SCH_INT_PVT.CSP_SHIP_PARAMETERS_TBL_TYPE ;
  l_final_option CSP_SCH_INT_PVT.CSP_SHIP_PARAMETERS_TBL_TYPE ;
  l_org_ship_methode org_ship_methodes_tbl_type ;
  l_supersede_items CSP_SUPERSESSIONS_PVT.NUMBER_ARR;
  min_cost           NUMBER ;
  rec_pointer        NUMBER;
  l_intransit_time   NUMBER;
  l_timezone_id      NUMBER;
  l_return_status    VARCHAR2(128);
  l_shipping_methode VARCHAR2(30);
  record_present     BOOLEAN;
  l_temp_org_id      NUMBER;
  loop_count         NUMBER := 1;
  l_need_by_date DATE;
  previous_position NUMBER;
  str_length        NUMBER;
  current_position  NUMBER;
  l_api_name        VARCHAR2(60) := 'CSP_SCH_INT_PVT.CHECK_PARTS_AVAILABILITY';
  g_arrival_date DATE;
  l_ship_methode_count NUMBER;
  l_assignment_set_id  NUMBER;
  l_vendor_id          NUMBER;
  l_vendor_site_id     NUMBER;
  do_purchase          BOOLEAN;
  l_uom_code           VARCHAR2(3);
  l_temp_quantity      NUMBER;
  l_substitute_item    NUMBER;
  l_alternate_items_list alternate_items_table_type;
  l_alternate_parts CSP_SUPERSESSIONS_PVT.NUMBER_ARR;
  l_final_available_list CSP_SCH_INT_PVT.CSP_AVAILABILITY_TBL_TYPE ;
  l_atp_success      BOOLEAN;
  check_subinventory BOOLEAN;
  l_att              NUMBER;
  l_onhand           NUMBER;
  x_final_availability CSP_SCH_INT_PVT.AVAILABLE_PARTS_TBL_TYP1;
  l_temp_subinv_code         VARCHAR2(30);
  try_buy_from               BOOLEAN;
  l_temp_line_id             NUMBER;
  quantity_fullfilled        BOOLEAN := FALSE ;
  l_required_quantity        NUMBER;
  l_no_of_options            NUMBER;
  l_dest_org_id              NUMBER;
  l_atleast_one_rec_per_line BOOLEAN;
  l_temp_avail_list CSP_SCH_INT_PVT.CSP_AVAILABILITY_TBL_TYPE ;
  min_arrival_date DATE;
  l_no_of_days NUMBER;--heh
  l_reservation_parts CSP_SCH_INT_PVT.RESERVATION_REC_TYP;
  l_reservation_id NUMBER;
  l_res_ids CSP_SUPERSESSIONS_PVT.NUMBER_ARR;
  l_primary_uom_code          VARCHAR2(10);
  l_replenisment_org_id       NUMBER;
  l_replenisment_subinventory VARCHAR2(100);
  l_check_alternates          BOOLEAN := FALSE;
BEGIN
  log('check_parts_availability', 'BEGIN');
  g_schedular_call := 'N';
  fnd_msg_pub.initialize;
  IF p_timezone_id IS NOT NULL THEN
    g_shipto_timezone_id := p_timezone_id;
  END IF;
  l_resources               := CSP_SCH_INT_PVT.csp_sch_resource_tbl_typ();
  l_resource_org_subinv     := CSP_SCH_INT_PVT.CSP_RESOURCE_ORG_tbl_TYP();
  l_unavailable_list        := CSP_SCH_INT_PVT.CSP_UNAVAILABILITY_TBL_TYPE();
  l_available_list          := CSP_SCH_INT_PVT.CSP_AVAILABILITY_TBL_TYPE ();
  l_eligible_resources_list := CSP_SCH_INT_PVT.CSP_AVAILABILITY_TBL_TYPE() ;
  l_final_unavailable_list  := CSP_SCH_INT_PVT.CSP_UNAVAILABILITY_TBL_TYPE();
  l_parts_list              := CSP_SCH_INT_PVT.CSP_PARTS_TBL_TYPE();
  l_ship_count              := CSP_SCH_INT_PVT.CSP_SHIP_METHOD_COUNT_TBL_TYP();
  l_res_ship_parameters     := CSP_SCH_INT_PVT.CSP_ORGS_SHIP_PARAM_TBL_TYPE();
  l_final_option            := CSP_SCH_INT_PVT.CSP_SHIP_PARAMETERS_TBL_TYPE() ;
  l_org_ship_methode        := org_ship_methodes_tbl_type() ;
  /* l_subinv_unavailable_list := CSP_SCH_INT_PVT.CSP_UNAVAILABILITY_TBL_TYPE() ;
  l_subinv_available_list   := CSP_SCH_INT_PVT.CSP_AVAILABILITY_TBL_TYPE();*/
  -- x_availability            := CSP_SCH_INT_PVT.AVAILABLE_PARTS_TBL_TYP1();
  l_interval.latest_time := p_need_by_date;
  x_return_status        := FND_API.G_RET_STS_SUCCESS;
  l_alternate_items_list := alternate_items_table_type();
  l_final_available_list := CSP_SCH_INT_PVT.CSP_AVAILABILITY_TBL_TYPE() ;
  l_temp_avail_list      := CSP_SCH_INT_PVT.CSP_AVAILABILITY_TBL_TYPE() ;
  l_timezone_id          := p_timezone_id ;
  log('check_parts_availability', 'p_organization_id: '||p_organization_id);
  log('check_parts_availability', 'p_resource.resource_id: '||p_resource.resource_id);
  IF p_organization_id IS NOT NULL THEN
    log('check_parts_availability', '1');
    l_temp_org_id      := p_organization_id;
    l_timezone_id      := p_timezone_id ;
    l_temp_subinv_code := p_subinv_code;
    l_resources.extend;
    l_resources(1).resource_id   := p_resource.resource_id;
    l_resources(1).resource_type := p_resource.resource_type;
    IF p_resource.resource_id IS NULL THEN
      log('check_parts_availability', '2');
      l_resources(1).resource_id   := '999999999999999';
      l_resources(1).resource_type := 'DUMMY';
    END IF;
  ELSE
    log('check_parts_availability', '3');
    IF p_resource.resource_id IS NOT NULL THEN
      log('check_parts_availability', '4');
      OPEN C1(p_resource.resource_type,p_resource.resource_id);
      LOOP
        FETCH C1 INTO l_timezone_id;
        EXIT
      WHEN C1%NOTFOUND;
      END LOOP;
      CLOSE C1;
      l_resources.extend;
      l_resources(1).resource_id   := p_resource.resource_id;
      l_resources(1).resource_type := p_resource.resource_type;
      CSP_SCH_INT_PVT.GET_ORGANIZATION_SUBINV(l_resources, l_resource_org_subinv , l_return_status,x_msg_data,x_msg_count);
      l_temp_org_id      := l_resource_org_subinv(1).organization_id;
      l_temp_subinv_code := l_resource_org_subinv(1).sub_inv_code;
    ELSE
      log('check_parts_availability', '5');
      l_resources.extend;
      l_temp_org_id                            := p_organization_id;
      l_temp_subinv_code                       := p_subinv_code;
      l_resources(1).resource_type             := 'DUMMY' ;
      l_resources(1).resource_id               := '999999999999999' ;
      l_temp_subinv_code                       := p_subinv_code;
      l_resource_org_subinv(1).resource_type   := 'DUMMY' ;
      l_resource_org_subinv(1).resource_id     := '999999999999999' ;
      l_resource_org_subinv(1).organization_id := p_organization_id;
      l_resource_org_subinv(1).sub_inv_code    := p_subinv_code;
    END IF;
  END IF;
  log('check_parts_availability', '6');
  IF p_organization_id IS NOT NULL THEN
    l_dest_org_id      := p_organization_id;
  ELSE
    l_dest_org_id := l_temp_org_id;
  END IF;
  log('check_parts_availability', 'p_parts_list.count: '||p_parts_list.count);
  IF p_parts_list.count > 1 THEN
    log('check_parts_availability', 'l_temp_org_id: '||l_temp_org_id);
    csp_supersessions_pvt.check_for_duplicate_parts(p_parts_list,l_temp_org_id,x_return_status,x_msg_data,x_msg_count);
  END IF;
  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RETURN;
  END IF;
  log('check_parts_availability', 'begin p_parts_list loop');
  FOR I IN 1..p_parts_list.count
  LOOP
    log('check_parts_availability', 'p_parts_list('||I||').item_id: '||p_parts_list(I).item_id);
    log('check_parts_availability', 'p_parts_list('||I||').item_uom: '||p_parts_list(I).item_uom);
    log('check_parts_availability', 'p_parts_list('||I||').quantity: '||p_parts_list(I).quantity);
    log('check_parts_availability', 'p_parts_list('||i||').line_id: '||p_parts_list(i).line_id);
    log('check_parts_availability', 'p_parts_list('||I||').revision: '||p_parts_list(I).revision);
    l_unavailable_list.extend;
    l_unavailable_list(l_unavailable_list.count).resource_type   := l_resources(1).resource_type;
    l_unavailable_list(l_unavailable_list.count).resource_id     := l_resources(1).resource_id;
    l_unavailable_list(l_unavailable_list.count).organization_id := l_dest_org_id;
    l_unavailable_list(l_unavailable_list.count).item_id         := p_parts_list(I).item_id;
    l_primary_uom_code                                           := p_parts_list(I).item_uom;
    OPEN primary_uom_code(p_parts_list(I).item_id ,l_dest_org_id);
    FETCH primary_uom_code INTO l_primary_uom_code;
    CLOSE primary_uom_code;
    IF l_primary_uom_code                                   <> p_parts_list(I).item_uom THEN
      l_unavailable_list(l_unavailable_list.count).quantity :=
            inv_convert.inv_um_convert(  item_id => p_parts_list(I).item_id
                                       , PRECISION => NULL -- use default precision
                                       , from_quantity => p_parts_list(I).quantity
                                       , from_unit => p_parts_list(I).item_uom
                                       , to_unit => l_primary_uom_code
                                       , from_name => NULL    -- from uom name
                                       , to_name => NULL      -- to uom name
                                      );
      l_unavailable_list(l_unavailable_list.count).item_uom := l_primary_uom_code ;
    ELSE
      l_unavailable_list(l_unavailable_list.count).quantity := p_parts_list(I).quantity;
      l_unavailable_list(l_unavailable_list.count).item_uom := p_parts_list(I).item_uom;
    END IF;
    l_unavailable_list(l_unavailable_list.count).ship_set_name := p_parts_list(I).ship_set_name;
    l_unavailable_list(l_unavailable_list.count).line_id       := p_parts_list(I).line_id;
    l_unavailable_list(l_unavailable_list.count).revision      := p_parts_list(I).revision;
    /*  END LOOP;
    FOR I IN 1..p_parts_list.count LOOP*/
    log('check_parts_availability', 'p_called_from: '||p_called_from);
    IF p_called_from <> 'MOBILE' THEN
      l_att          := 0;
      log('check_parts_availability', 'l_temp_subinv_code: '||l_temp_subinv_code);
      IF l_temp_subinv_code IS NOT NULL THEN
        log('check_parts_availability', 'calling check_local_inventory');
        check_local_inventory(
                p_org_id => l_temp_org_id,
                p_subinv_code => l_temp_subinv_code,
                p_item_id => p_parts_list(i).item_id,
                p_revision => p_parts_list(i).revision,
                x_att => l_att,
                x_onhand => l_onhand,
                x_return_status => x_return_status,
                x_msg_data => x_msg_data,
                x_msg_count => x_return_status);
        log('check_parts_availability', 'x_return_status: '||x_return_status);
        log('check_parts_availability', 'x_msg_data: '||x_msg_data);
        log('check_parts_availability', 'x_msg_count: '||x_msg_count);
        log('check_parts_availability', 'after check_local_inventory');
        log('check_parts_availability', 'l_att: '||l_att);
        IF l_att > 0 THEN
          l_final_available_list.extend;
          l_final_available_list(l_final_available_list.count).resource_id        := l_resources(1).resource_id;
          l_final_available_list(l_final_available_list.count).resource_type      := l_resources(1).resource_type;
          l_final_available_list(l_final_available_list.count).organization_id    := l_temp_org_id;
          l_final_available_list(l_final_available_list.count).item_id            := p_parts_list(I).item_id ;
          l_final_available_list(l_final_available_list.count).item_uom           := l_unavailable_list(l_unavailable_list.count).item_uom ;
          l_final_available_list(l_final_available_list.count).revision           := p_parts_list(I).revision ;
          l_final_available_list(l_final_available_list.count).available_quantity := l_att ;
          l_final_available_list(l_final_available_list.count).source_org         := l_temp_org_id;
          l_final_available_list(l_final_available_list.count).sub_inventory      := l_temp_subinv_code;
          l_final_available_list(l_final_available_list.count).AVAILABLE_DATE     := SYSDATE;
          l_final_available_list(l_final_available_list.count).line_id            := p_parts_list(I).line_id;
          l_reservation_id                                                        := NULL;
          l_reservation_parts.need_by_date                                        := sysdate;
          l_reservation_parts.organization_id                                     := l_final_available_list(l_final_available_list.count).source_org ;
          l_reservation_parts.item_id                                             := l_final_available_list(l_final_available_list.count).item_id;
          l_reservation_parts.item_uom_code                                       := l_final_available_list(l_final_available_list.count).item_uom ;
          l_reservation_parts.quantity_needed                                     := least(l_final_available_list(l_final_available_list.count).available_quantity,l_unavailable_list(l_unavailable_list.count).quantity);
          l_reservation_parts.sub_inventory_code                                  := l_final_available_list(l_final_available_list.count).sub_inventory;
          l_reservation_parts.line_id                                             := l_final_available_list(l_final_available_list.count).line_id ;
          l_reservation_parts.revision                                            := l_final_available_list(l_final_available_list.count).revision;
          l_reservation_id                                                        := csp_sch_int_pvt.create_reservation(l_reservation_parts,x_return_status,x_msg_data);
          log('check_parts_availability', 'l_reservation_id: '||l_reservation_id);
          IF l_reservation_id <= 0 THEN
            x_return_status   := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.SET_NAME('CSP', 'CSP_SCH_COULD_NOT_RESERVE');
            FND_MSG_PUB.ADD;
            fnd_msg_pub.count_and_get ( p_count => x_msg_count , p_data => x_msg_data);
          ELSE
            log('check_parts_availability', 'l_res_ids.count: ||l_res_ids.count');
            l_res_ids(l_res_ids.count+1) := l_reservation_id ;
            log('check_parts_availability', 'l_res_ids.count: '||l_res_ids.count);
          END IF;
        END IF;
      END IF;
    END IF;
  END LOOP;
  log('check_parts_availability', 'begin p_parts_list loop again. count: '||p_parts_list.count);
  FOR I IN 1..p_parts_list.count
  LOOP
    log('check_parts_availability', 'profile CSP_INCL_ALTERNATES value: '||fnd_profile.value(name => 'CSP_INCL_ALTERNATES'));
    if p_include_alternates is not null then
      l_check_alternates := p_include_alternates;
    else
      l_check_alternates := fnd_profile.value(name => 'CSP_INCL_ALTERNATES')= 'ALWAYS' OR fnd_profile.value(name => 'CSP_INCL_ALTERNATES')= 'PRONLY';
    end if;
    IF l_check_alternates THEN
      CSP_SUPERSESSIONS_PVT.get_supersede_bilateral_items(p_inventory_item_id => p_parts_list(I).item_id ,p_organization_id => l_temp_org_id ,x_supersede_items => l_supersede_items);
      log('check_parts_availability', 'begin l_supersede_items loop. l_supersede_items count: '||l_supersede_items.count);
      FOR J IN 1..l_supersede_items.count
      loop
        log('check_parts_availability', 'supersede items loop begin: '||J);
        log('check_parts_availability', 'l_supersede_items('||J||'): '||l_supersede_items(J));
        l_uom_code := NULL;
        OPEN primary_uom_code(l_supersede_items(J),p_organization_id);
        LOOP
          FETCH primary_uom_code INTO l_uom_code;
          EXIT
        WHEN primary_uom_code% NOTFOUND;
        END LOOP;
        CLOSE primary_uom_code;
        log('check_parts_availability', 'l_uom_code: '||l_uom_code);
        l_temp_quantity := inv_convert.inv_um_convert(  item_id => l_supersede_items(J)
                                                      , PRECISION => NULL   -- use default precision
                                                      , from_quantity => p_parts_list(I).quantity
                                                      , from_unit => p_parts_list(I).item_uom
                                                      , to_unit => l_uom_code
                                                      , from_name => NULL -- from uom name
                                                      , to_name => NULL   -- to uom name
                                                      );
        log('check_parts_availability', 'l_temp_quantity: '||l_temp_quantity);
        l_alternate_items_list.extend;
        l_alternate_items_list(l_alternate_items_list.count).item                    := p_parts_list(I).item_id;
        l_alternate_items_list(l_alternate_items_list.count).item_quantity           := p_parts_list(I).quantity;
        l_alternate_items_list(l_alternate_items_list.count).item_uom                := p_parts_list(I).item_uom;
        l_alternate_items_list(l_alternate_items_list.count).alternate_item          := l_supersede_items(J);
        l_alternate_items_list(l_alternate_items_list.count).alternate_item_quantity := l_temp_quantity;
        l_alternate_items_list(l_alternate_items_list.count).alternate_item_uom      := l_uom_code;
        l_alternate_items_list(l_alternate_items_list.count).relation_type           := 8;
        l_temp_quantity                                                              := 0;
        l_uom_code                                                                   := NULL;
      END LOOP;
      OPEN substitutes(p_parts_list(I).item_id, l_temp_org_id);
      LOOP
        FETCH substitutes INTO l_substitute_item;
        EXIT
      WHEN substitutes % NOTFOUND;
        log('check_parts_availability', 'inside substitutes loop');
        log('check_parts_availability', 'l_substitute_item: '||l_substitute_item);
        l_uom_code := NULL;
        OPEN primary_uom_code(l_substitute_item,l_temp_org_id);
        LOOP
          FETCH primary_uom_code INTO l_uom_code;
          EXIT
        WHEN primary_uom_code% NOTFOUND;
        end loop;
        CLOSE primary_uom_code;
        log('check_parts_availability', 'l_uom_code: '||l_uom_code);
        l_temp_quantity := inv_convert.inv_um_convert(item_id => l_substitute_item , PRECISION => NULL                                  -- use default precision
        , from_quantity => p_parts_list(I).quantity , from_unit => p_parts_list(I).item_uom , to_unit => l_uom_code , from_name => NULL -- from uom name
        , to_name => NULL                                                                                                               -- to uom name
        );
        log('check_parts_availability', 'l_temp_quantity: '||l_temp_quantity);
        l_alternate_items_list.extend;
        l_alternate_items_list(l_alternate_items_list.count).item                    := p_parts_list(I).item_id;
        l_alternate_items_list(l_alternate_items_list.count).item_quantity           := p_parts_list(I).quantity;
        l_alternate_items_list(l_alternate_items_list.count).item_uom                := p_parts_list(I).item_uom;
        l_alternate_items_list(l_alternate_items_list.count).alternate_item          := l_substitute_item;
        l_alternate_items_list(l_alternate_items_list.count).alternate_item_quantity := l_temp_quantity;
        l_alternate_items_list(l_alternate_items_list.count).alternate_item_uom      := l_uom_code;
        l_alternate_items_list(l_alternate_items_list.count).relation_type           := 2;
        l_temp_quantity                                                              := 0;
        l_uom_code                                                                   := NULL;
      END LOOP;
      CLOSE substitutes;
    END IF;
    log('check_parts_availability', 'begin l_alternate_items_list loop. count: '||l_alternate_items_list.count);
    FOR J IN 1..l_alternate_items_list.count
    LOOP
      --l_parts_list.extend;
      l_unavailable_list.extend;
      l_unavailable_list(l_unavailable_list.count).resource_type   := l_resources(1).resource_type;
      l_unavailable_list(l_unavailable_list.count).resource_id     := l_resources(1).resource_id;
      l_unavailable_list(l_unavailable_list.count).organization_id := l_dest_org_id;
      l_unavailable_list(l_unavailable_list.count).item_id         := l_alternate_items_list(J).alternate_item;
      l_unavailable_list(l_unavailable_list.count).item_uom        := l_alternate_items_list(J).alternate_item_uom;
      l_unavailable_list(l_unavailable_list.count).quantity        := l_alternate_items_list(J).alternate_item_quantity;
      l_unavailable_list(l_unavailable_list.count).ship_set_name   := p_parts_list(I).ship_set_name;
      l_unavailable_list(l_unavailable_list.count).item_type       := l_alternate_items_list(J).relation_type ;
      l_unavailable_list(l_unavailable_list.count).line_id         := p_parts_list(I).line_id;
      l_unavailable_list(l_unavailable_list.count).revision        := p_parts_list(I).revision;
      log('check_parts_availability', 'l_alternate_items_list(J).alternate_item: '||l_alternate_items_list(j).alternate_item);
      log('check_parts_availability', 'l_alternate_items_list(J).relation_type: '||l_alternate_items_list(j).relation_type);
      log('check_parts_availability', 'l_alternate_items_list(J).alternate_item_quantity: '||l_alternate_items_list(j).alternate_item_quantity);
      log('check_parts_availability', 'l_alternate_items_list(J).alternate_item_uom: '||l_alternate_items_list(j).alternate_item_uom);
      log('check_parts_availability', 'l_temp_org_id: '||l_temp_org_id);
      IF l_temp_subinv_code IS NOT NULL THEN
        log('check_parts_availability', 'calling check_local_inventory');
        check_local_inventory(
                p_org_id => l_temp_org_id,
                p_subinv_code => l_temp_subinv_code,
                p_item_id => l_alternate_items_list(J).alternate_item,
                p_revision => null,
                x_att => l_att,
                x_onhand => l_onhand,
                x_return_status => x_return_status,
                x_msg_data => x_msg_data,
                x_msg_count => x_return_status);
        log('check_parts_availability', 'after check_local_inventory');
        log('check_parts_availability', 'x_return_status: '||x_return_status);
        log('check_parts_availability', 'x_msg_data: '||x_msg_data);
        log('check_parts_availability', 'x_msg_count: '||x_msg_count);
        log('check_parts_availability', 'l_att: '||l_att);
        IF l_att > 0 THEN
          l_final_available_list.extend;
          l_final_available_list(l_final_available_list.count).resource_id        := l_resources(1).resource_id;
          l_final_available_list(l_final_available_list.count).resource_type      := l_resources(1).resource_type;
          l_final_available_list(l_final_available_list.count).organization_id    := l_temp_org_id;
          l_final_available_list(l_final_available_list.count).item_id            := l_alternate_items_list(J).alternate_item ;
          l_final_available_list(l_final_available_list.count).item_uom           := l_alternate_items_list(J).alternate_item_uom ;
          l_final_available_list(l_final_available_list.count).revision           := NULL;
          l_final_available_list(l_final_available_list.count).available_quantity := l_att ;
          l_final_available_list(l_final_available_list.count).source_org         := l_temp_org_id;
          l_final_available_list(l_final_available_list.count).sub_inventory      := l_temp_subinv_code;
          l_final_available_list(l_final_available_list.count).AVAILABLE_DATE     := SYSDATE;
          l_final_available_list(l_final_available_list.count).line_id            := p_parts_list(I).line_id;
          l_final_available_list(l_final_available_list.count).item_type          := l_alternate_items_list(J).relation_type ;
          l_reservation_id                                                        := NULL;
          l_reservation_parts.need_by_date                                        := sysdate;
          l_reservation_parts.organization_id                                     := l_final_available_list(l_final_available_list.count).source_org ;
          l_reservation_parts.item_id                                             := l_final_available_list(l_final_available_list.count).item_id;
          l_reservation_parts.item_uom_code                                       := l_final_available_list(l_final_available_list.count).item_uom ;
          l_reservation_parts.quantity_needed                                     := least(l_final_available_list(l_final_available_list.count).available_quantity,l_unavailable_list(l_unavailable_list.count).quantity) ;
          l_reservation_parts.sub_inventory_code                                  := l_final_available_list(l_final_available_list.count).sub_inventory;
          l_reservation_parts.line_id                                             := l_final_available_list(l_final_available_list.count).line_id ;
          l_reservation_parts.revision                                            := l_final_available_list(l_final_available_list.count).revision;
          l_reservation_id                                                        := CSP_SCH_INT_PVT.CREATE_RESERVATION(l_reservation_parts,x_return_status,x_msg_data);
          IF l_reservation_id                                                     <= 0 THEN
            x_return_status                                                       := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.SET_NAME('CSP', 'CSP_SCH_COULD_NOT_RESERVE');
            FND_MSG_PUB.ADD;
            fnd_msg_pub.count_and_get ( p_count => x_msg_count , p_data => x_msg_data);
          ELSE
            l_res_ids(l_res_ids.count+1) := l_reservation_id ;
          END IF;
        END IF;
      END IF;
      l_uom_code      := NULL;
      l_temp_quantity := NULL;
      l_att           := 0;
    END LOOP;
    IF l_alternate_items_list.count > 0 THEN
      l_alternate_items_list.trim;
      l_alternate_items_list := alternate_items_table_type();
    END IF;
  END LOOP;
  log('check_parts_availability', 'begin l_res_ids loop. count: '||l_res_ids.count);
  FOR i IN 1..l_res_ids.count
  LOOP
    log('check_parts_availability', 'l_res_ids('||i||'): '||l_res_ids(i));
    CSP_SCH_INT_PVT.DELETE_RESERVATION(l_res_ids(i),x_return_status,x_msg_data);
  END LOOP;
  log('check_parts_availability', 'profile CSP_CHECK_ATP value: '||fnd_profile.value(name => 'CSP_CHECK_ATP'));
  IF fnd_profile.value(name => 'CSP_CHECK_ATP')= 'ALWAYS' OR fnd_profile.value(name => 'CSP_CHECK_ATP')= 'PRONLY' THEN
    log('check_parts_availability', 'l_unavailable_list count: '||l_unavailable_list.count);
    IF l_unavailable_list.count >=1 THEN
      log('check_parts_availability', 'calling csp_sch_int_pvt.do_atp_check');
      csp_sch_int_pvt.do_atp_check(l_unavailable_list,l_interval,l_available_list,l_final_unavailable_list,l_return_status,x_msg_data,x_msg_count);
      log('check_parts_availability', 'after csp_sch_int_pvt.do_atp_check');
      log('check_parts_availability', 'l_return_status: '||l_return_status);
      log('check_parts_availability', 'x_msg_data: '||x_msg_data);
      log('check_parts_availability', 'x_msg_count: '||x_msg_count);
    END IF;
    log('check_parts_availability', 'l_available_list count: '||l_available_list.count);
    IF l_available_list.count > 0 THEN
      log('check_parts_availability', 'begin p_parts_list loop. count: '||p_parts_list.count);
      FOR K IN 1..p_parts_list.count
      LOOP
        l_atleast_one_rec_per_line := FALSE;
        log('check_parts_availability', 'begin l_available_list loop. count: '||l_available_list.count);
        FOR J IN 1..l_available_list.count
        LOOP
          log('check_parts_availability', 'l_available_list('||j||').line_id: '||l_available_list(j).line_id);
          log('check_parts_availability', 'p_parts_list('||K||').line_id: '||p_parts_list(K).line_id);
          IF l_available_list(J).line_id = p_parts_list(K).line_id THEN
            l_options                   := CSP_SCH_INT_PVT.CSP_SHIP_PARAMETERS_TBL_TYPE();
            l_temp_options              := CSP_SCH_INT_PVT.CSP_SHIP_PARAMETERS_TBL_TYPE ();
            l_temp_avail_list.extend;
            l_temp_avail_list(1)                         := l_available_list(J);
            l_temp_avail_list(1).destination_location_id := p_location_id;
            CSP_SCH_INT_PVT.OPTIMIZE_OPTIONS(l_temp_avail_list,l_options,l_ship_count,l_res_ship_parameters,x_return_status,x_msg_data,x_msg_count);
            min_cost := NULL;
            l_temp_avail_list.trim;
            min_arrival_date := NULL;
            rec_pointer      := NULL;
            log('check_parts_availability', 'begin l_options loop. count: '||l_options.count);
            FOR I IN 1..l_options.count
            LOOP
              -- phegde : uncommenting the if condition as a fix for Ikon bug 3925273
              IF ROUND(((l_options(I).arrival_date - sysdate) * 24),2) <= ROUND(((p_need_by_date - sysdate) * 24),2) OR p_need_by_date IS NULL THEN
                l_temp_options.extend;
                l_temp_options(l_temp_options.count).resource_id       := l_options(I).resource_id;
                l_temp_options(l_temp_options.count).resource_type     := l_options(I).resource_type;
                l_temp_options(l_temp_options.count).lead_time         := l_options(I).lead_time ;
                l_temp_options(l_temp_options.count).transfer_cost     := l_options(I).transfer_cost;
                l_temp_options(l_temp_options.count).shipping_methodes := l_options(I).shipping_methodes;
                l_temp_options(l_temp_options.count).arrival_date      := l_options(I).arrival_date ;
                l_atleast_one_rec_per_line                             := TRUE;
                IF p_need_by_date IS NOT NULL THEN
                  IF min_cost IS NULL THEN
                    min_cost                                           := l_temp_options(l_temp_options.count).transfer_cost;
                    rec_pointer                                        := l_temp_options.count;
                  ELSE
                    IF min_cost    > l_temp_options(l_temp_options.count).transfer_cost THEN
                      min_cost    := l_temp_options(l_temp_options.count).transfer_cost;
                      rec_pointer := l_temp_options.count;
                    END IF;
                  END IF;
                ELSE
                  IF min_arrival_date IS NULL THEN
                    min_arrival_date  := l_temp_options(l_temp_options.count).arrival_date;
                    rec_pointer       := l_temp_options.count;
                  ELSE
                    IF min_arrival_date > l_temp_options(l_temp_options.count).arrival_date THEN
                      min_arrival_date := l_temp_options(l_temp_options.count).arrival_date;
                      rec_pointer      := l_temp_options.count;
                    END IF;
                  END IF;
                END IF;
              END IF;
            END LOOP;
            log('check_parts_availability', 'l_temp_options.count: '||l_temp_options.count);
            IF l_temp_options.count                 > 0 THEN
              l_available_list(J).shipping_methode := l_temp_options(rec_pointer).shipping_methodes;
              l_available_list(J).intransit_time   := l_temp_options(rec_pointer).lead_time ;
              l_temp_options.trim;
            ELSE
              -- phegde : adding this code, since uncommented the if condition above
              log('check_parts_availability', 'begin l_options loop. count: '||l_options.count);
              FOR I IN 1..l_options.count
              LOOP
                l_temp_options.extend;
                l_temp_options(l_temp_options.count).resource_id       := l_options(I).resource_id;
                l_temp_options(l_temp_options.count).resource_type     := l_options(I).resource_type;
                l_temp_options(l_temp_options.count).lead_time         := l_options(I).lead_time ;
                l_temp_options(l_temp_options.count).transfer_cost     := l_options(I).transfer_cost;
                l_temp_options(l_temp_options.count).shipping_methodes := l_options(I).shipping_methodes;
                l_temp_options(l_temp_options.count).arrival_date      := l_options(I).arrival_date ;
                l_atleast_one_rec_per_line                             := TRUE;
                IF min_arrival_date                                    IS NULL THEN
                  min_arrival_date                                     := l_temp_options(l_temp_options.count).arrival_date;
                  rec_pointer                                          := l_temp_options.count;
                ELSE
                  IF min_arrival_date > l_temp_options(l_temp_options.count).arrival_date THEN
                    min_arrival_date := l_temp_options(l_temp_options.count).arrival_date;
                    rec_pointer      := l_temp_options.count;
                  END IF;
                END IF;
              END LOOP;
              log('check_parts_availability', 'l_temp_options.count: '||l_temp_options.count);
              IF l_temp_options.count                 > 0 THEN
                l_available_list(J).shipping_methode := l_temp_options(rec_pointer).shipping_methodes;
                l_available_list(J).intransit_time   := l_temp_options(rec_pointer).lead_time ;
                l_temp_options.trim;
              ELSE
                l_available_list(J).item_id := NULL;
              END IF;
              -- phegde : end of changes
            END IF;
          END IF;
        END LOOP;
        log('check_parts_availability', 'begin l_final_available_list loop. count: '||l_final_available_list.count);
        FOR I IN 1..l_final_available_list.count
        LOOP
          IF l_final_available_list(I).line_id = p_parts_list(K).line_id THEN
            l_atleast_one_rec_per_line        := TRUE;
          END IF;
        END LOOP;
        IF NOT l_atleast_one_rec_per_line THEN
          FND_MESSAGE.SET_NAME('CSP', 'CSP_UNABLE_NEED_BY_DATE');
          FND_MSG_PUB.ADD;
          fnd_msg_pub.count_and_get ( p_count => x_msg_count , p_data => x_msg_data);
        END IF;
      END LOOP;
    END IF;
  ELSE
    log('check_parts_availability', 'ATP profile else part. begin l_unavailable_list loop. count: '||l_unavailable_list.count);
    FOR I IN 1..l_unavailable_list.count
    LOOP
      l_replenisment_org_id       := NULL;
      l_replenisment_subinventory := NULL;
      csp_parts_requirement.get_source_organization(l_unavailable_list(I).item_id, l_unavailable_list(I).organization_id, l_temp_subinv_code, l_replenisment_org_id, l_replenisment_subinventory);
      IF l_replenisment_org_id IS NOT NULL THEN
        l_available_list.extend;
        l_available_list(l_available_list.count).item_id          := l_unavailable_list(I).item_id ;
        l_available_list(l_available_list.count).source_org       := l_replenisment_org_id;
        l_available_list(l_available_list.count).shipping_methode := NULL;
        CHECK_LOCAL_INVENTORY(
                p_org_id => l_replenisment_org_id,
                p_subinv_code => l_replenisment_subinventory,
                p_item_id => l_unavailable_list(i).item_id,
                p_revision => l_unavailable_list(i).revision,
                x_att => l_att,
                x_onhand => l_onhand,
                x_return_status => x_return_status,
                x_msg_data => x_msg_data,
                x_msg_count => x_return_status);
        l_available_list(l_available_list.count).available_quantity   := l_att;
        l_available_list(l_available_list.count).sub_inventory        := l_replenisment_subinventory;
        l_available_list(l_available_list.count).item_type            := l_unavailable_list(I).item_type ;
        l_available_list(l_available_list.count).item_uom             := l_unavailable_list(I).item_uom ;
        l_available_list(l_available_list.count).line_id              := l_unavailable_list(I).line_id ;
        l_available_list(l_available_list.count).replenishment_source := 'Y';
      END IF;
    END LOOP;
  END IF;
  l_temp_line_id      := p_parts_list(1).line_id;
  loop_Count          := 1;
  l_required_quantity := 0;
  log('check_parts_availability', 'begin p_parts_list loop again. count: '||p_parts_list.count);
  FOR I IN 1..p_parts_list.count
  LOOP
    l_no_of_options     := 0;
    l_required_quantity := p_parts_list(I).quantity;
    quantity_fullfilled := FALSE ;
    log('check_parts_availability', 'p_called_from: '||p_called_from);
    IF p_called_from <> 'MOBILE' THEN
      log('check_parts_availability', 'begin l_final_available_list loop. count: '||l_final_available_list.count);
      FOR K IN 1..l_final_available_list.count
      LOOP
        log('check_parts_availability', 'l_final_available_list('||K||').line_id: '||l_final_available_list(K).line_id);
        log('check_parts_availability', 'p_parts_list('||I||').line_id: '||p_parts_list(I).line_id);
        IF l_final_available_list(K).line_id             = p_parts_list(I).line_id THEN
          l_no_of_options                               := l_no_of_options + 1;
          x_availability(loop_count).line_id            := l_final_available_list(k).line_id ;
          x_availability(loop_count).item_uom           := p_parts_list(I).item_uom ;
          x_availability(loop_count).item_id            := l_final_available_list(k).item_id ;
          x_availability(loop_count).source_org_id      := l_final_available_list(k).source_org;
          x_availability(loop_count).shipping_methode   := l_final_available_list(k).shipping_methode;
          x_availability(loop_count).item_type          := l_final_available_list(k).item_type ;
          x_availability(loop_count).sub_inventory_code := l_final_available_list(k).sub_inventory;
          x_availability(loop_count).available_quantity := inv_convert.inv_um_convert(  item_id => l_final_available_list(K).item_id
                                                                                      , PRECISION => NULL   -- use default precision
                                                                                      , from_quantity => l_final_available_list(K).available_quantity
                                                                                      , from_unit => l_final_available_list(K).item_uom
                                                                                      , to_unit => p_parts_list(I).item_uom
                                                                                      , from_name => NULL -- from uom name
                                                                                      , to_name => NULL   -- to uom name
                                                                                      );
          l_final_available_list(K).available_quantity := x_availability(loop_count).available_quantity;
          x_availability(loop_count).revision          := l_final_available_list(K).revision;
          IF x_availability(loop_count).source_org_id = l_temp_org_id THEN
            IF p_need_by_date IS NOT NULL THEN
              x_availability(loop_count).arraival_date := p_need_by_date;
              x_availability(loop_count).order_by_date := p_need_by_date;
            ELSE
              x_availability(loop_count).arraival_date := sysdate ;
              x_availability(loop_count).order_by_date := sysdate ;
            END IF;
          END IF;
          IF l_final_available_list(k).shipping_methode IS NOT NULL THEN
            x_availability(loop_count).source_type       := 'IO' ;
            IF p_need_by_date IS NOT NULL THEN
              x_availability(loop_count).arraival_date   := l_final_available_list(k).available_date + l_final_available_list(k).intransit_time/24 ;
              IF p_need_by_date > x_availability(loop_count).arraival_date THEN
                x_availability(loop_count).arraival_date := p_need_by_date;
              END IF;
              x_availability(loop_count).order_by_date := x_availability(loop_count).arraival_date - l_final_available_list(k).intransit_time/24 ;
            ELSE
              x_availability(loop_count).arraival_date := l_final_available_list(k).available_date + l_final_available_list(k).intransit_time/24 ;
              x_availability(loop_count).order_by_date := SYSDATE;
            END IF;
          ELSE
            x_availability(loop_count).source_type := 'RES' ;
          END IF;
          IF fnd_profile.value(name => 'CSP_INCL_CAR_STOCK')= 'ALWAYS' OR fnd_profile.value(name => 'CSP_INCL_CAR_STOCK')= 'PRONLY' THEN
            IF NOT quantity_fullfilled THEN
              IF l_required_quantity                           > l_final_available_list(k).available_quantity THEN
                x_availability(loop_count).recommended_option := 'Y';
                quantity_fullfilled                           := FALSE;
                l_required_quantity                           := l_required_quantity - l_final_available_list(k).available_quantity;
                x_availability(loop_count).ordered_quantity   := l_final_available_list(k).available_quantity;
              ELSE
                x_availability(loop_count).recommended_option := 'Y';
                x_availability(loop_count).ordered_quantity   := l_required_quantity;
                quantity_fullfilled                           := TRUE ;
              END IF;
            END IF;
          END IF;
          loop_count := loop_count + 1;
        END IF;
      END LOOP;
    END IF;
    log('check_parts_availability', 'begin l_available_list loop. count: '||l_available_list.count);
    FOR J IN 1..l_available_list.count
    LOOP
      log('check_parts_availability', 'l_available_list('||J||').line_id: '||l_available_list(J).line_id);
      log('check_parts_availability', 'p_parts_list('||i||').line_id: '||p_parts_list(i).line_id);
      log('check_parts_availability', 'l_available_list('||J||').item_id: '||l_available_list(J).item_id);
      IF l_available_list(J).line_id = p_parts_list(I).line_id AND l_available_list(J).item_id IS NOT NULL THEN
        l_no_of_options                             := l_no_of_options + 1;
        x_availability(loop_count).item_uom         := p_parts_list(I).item_uom ;
        x_availability(loop_count).line_id          := l_available_list(J).line_id ;
        x_availability(loop_count).item_id          := l_available_list(J).item_id ;
        x_availability(loop_count).source_org_id    := l_available_list(J).source_org;
        x_availability(loop_count).shipping_methode := l_available_list(J).shipping_methode;
        --  x_availability(loop_count).ordered_quantity :=  l_available_list(J).quantity;
        x_availability(loop_count).item_type := l_available_list(J).item_type ;
        --  x_availability(loop_count).source_type      := 'IO' ;
        x_availability(loop_count).sub_inventory_code := l_available_list(J).sub_inventory;
        x_availability(loop_count).available_quantity := inv_convert.inv_um_convert(  item_id => l_available_list(J).item_id
                                                                                    , PRECISION => NULL   -- use default precision
                                                                                    , from_quantity => l_available_list(J).available_quantity
                                                                                    , from_unit => l_available_list(J).item_uom
                                                                                    , to_unit => p_parts_list(I).item_uom
                                                                                    , from_name => NULL -- from uom name
                                                                                    , to_name => NULL   -- to uom name
                                                                                    );
        l_available_list(J).available_quantity       := x_availability(loop_count).available_quantity;
        x_availability(loop_count).revision          := l_available_list(J).revision;

        IF x_availability(loop_count).source_org_id = l_temp_org_id THEN
          IF p_need_by_date IS NOT NULL THEN
            x_availability(loop_count).arraival_date := p_need_by_date;
            x_availability(loop_count).order_by_date := get_order_by_date(x_availability(loop_count).source_org_id,
                                                                          x_availability(loop_count).shipping_methode,
                                                                          x_availability(loop_count).arraival_date,
                                                                          l_available_list(I).intransit_time,
                                                                          l_temp_org_id);
          ELSE
            x_availability(loop_count).arraival_date := sysdate ;
            x_availability(loop_count).order_by_date := sysdate ;
          END IF;
        END IF;

        IF l_available_list(J).shipping_methode IS NOT NULL OR l_available_list(J).sub_inventory IS NULL OR l_available_list(J).replenishment_source IS NOT NULL THEN
          x_availability(loop_count).source_type := 'IO' ;
          IF p_need_by_date IS NOT NULL THEN
            x_availability(loop_count).arraival_date := get_arrival_date(l_available_list(J).available_date, l_available_list(J).intransit_time, l_temp_org_id) ;
            -- Modified for bug 3925273
            IF p_need_by_date - x_availability(loop_count).arraival_date >= 1 THEN
              l_no_of_days := ROUND((p_need_by_date - x_availability(loop_count).arraival_date) - 0.5);
              x_availability(loop_count).arraival_date := x_availability(loop_count).arraival_date + l_no_of_days;
            END IF;
            /* x_availability(loop_count).order_by_date    := x_availability(loop_count).arraival_date
            - l_available_list(J).intransit_time/24 ;*/
            x_availability(loop_count).order_by_date := get_order_by_date(x_availability(loop_count).source_org_id,
                                                                          x_availability(loop_count).shipping_methode,
                                                                          x_availability(loop_count).arraival_date,
                                                                          l_available_list(J).intransit_time,
                                                                          l_temp_org_id);
          ELSE
            x_availability(loop_count).arraival_date := get_arrival_date(l_available_list(J).available_date, l_available_list(J).intransit_time, l_temp_org_id);
            x_availability(loop_count).order_by_date := SYSDATE;
          END IF;
        ELSE
          x_availability(loop_count).source_type := 'RES' ;
        END IF;

        IF NOT quantity_fullfilled THEN
          IF l_required_quantity > l_available_list(J).available_quantity THEN
            x_availability(loop_count).recommended_option := 'Y';
            quantity_fullfilled                           := FALSE;
            l_required_quantity                           := l_required_quantity - l_available_list(J).available_quantity;
          ELSE
            x_availability(loop_count).recommended_option := 'Y';
            x_availability(loop_count).ordered_quantity   := l_required_quantity;
            quantity_fullfilled                           := TRUE ;
          END IF;
        END IF;
        loop_count := loop_count + 1;
      END IF;
    END LOOP;
    IF NOT quantity_fullfilled THEN
      l_assignment_set_id := FND_PROFILE.value(name => 'MRP_ATP_ASSIGN_SET');
      log('check_parts_availability', 'l_assignment_set_id: '||l_assignment_set_id);
      OPEN check_buy_from(p_parts_list(I).item_id, l_assignment_set_id,l_temp_org_id);
      LOOP
        FETCH check_buy_from INTO l_vendor_id, l_vendor_site_id;
        EXIT
      WHEN check_buy_from%notfound;
        x_availability(loop_count).item_id            := p_parts_list(I).item_id ;
        x_availability(loop_count).source_type        := 'POREQ' ;
        x_availability(loop_count).ordered_quantity   := l_required_quantity;
        x_availability(loop_count).line_id            := p_parts_list(I).line_id ;
        x_availability(loop_count).recommended_option := 'Y';
        x_availability(loop_count).item_uom           := p_parts_list(I).item_uom ;
        x_availability(loop_count).shipping_methode   := NULL;
        l_no_of_options                               := 1;
        loop_count                                    := loop_count+ 1;
        EXIT;
      END LOOP;
      CLOSE check_buy_from;
    END IF;
    log('check_parts_availability', 'l_no_of_options: '||l_no_of_options);
    IF l_no_of_options                               = 0 THEN
      x_availability(loop_count).line_id            := p_parts_list(I).line_id ;
      x_availability(loop_count).item_id            := p_parts_list(I).item_id ;
      x_availability(loop_count).source_org_id      := NULL;
      x_availability(loop_count).shipping_methode   := NULL;
      x_availability(loop_count).ordered_quantity   := NULL;
      x_availability(loop_count).item_type          := NULL;
      x_availability(loop_count).source_type        := NULL;
      x_availability(loop_count).sub_inventory_code := NULL;
      x_availability(loop_count).arraival_date      := NULL;
      x_availability(loop_count).order_by_date      := NULL;
      loop_count                                    := loop_count+ 1;
    END IF;
  END LOOP;
  log('check_parts_availability', 'END');
EXCEPTION
WHEN OTHERS THEN
  FND_MESSAGE.SET_NAME('CSP', 'CSP_UNEXPECTED_EXEC_ERRORS');
  FND_MESSAGE.SET_TOKEN('ROUTINE', l_api_name, FALSE);
  FND_MESSAGE.SET_TOKEN('SQLERRM', sqlerrm, FALSE);
  FND_MSG_PUB.ADD;
  fnd_msg_pub.count_and_get ( p_count => x_msg_count , p_data => x_msg_data);
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  RETURN;
END check_parts_availability;

    PROCEDURE CHECK_LOCAL_INVENTORY(  p_org_id        IN   NUMBER
                                      ,p_revision      IN   varchar2
                                     ,p_subinv_code   IN   VARCHAR2
                                     ,p_item_id       IN   NUMBER
                                     ,x_att           OUT NOCOPY  NUMBER
                                     ,x_onhand        OUT NOCOPY  NUMBER
                                     ,x_return_status OUT NOCOPY  VARCHAR2
                                     ,x_msg_data      OUT NOCOPY  VARCHAR2
                                     ,x_msg_count     OUT NOCOPY  NUMBER) IS
    /*CURSOR reservation_check(org_id NUMBER, sub_inv_code VARCHAR2,item_id NUMBER)
    IS
    SELECT (REQUIRED_QUANTITY-ORDERED_QUANTITY)
    FROM   CSP_REQUIREMENT_LINES
    WHERE  REQUIREMENT_HEADER_ID = (SELECT REQUIREMENT_HEADER_ID
                                    FROM   CSP_REQUIREMENT_HEADERS
                                    WHERE  OPEN_REQUIREMENT = 'Yes'
                                    AND    DESTINATION_ORGANIZATION_ID = org_id)
    AND   SOURCE_SUBINVENTORY =  sub_inv_code
    AND   INVENTORY_ITEM_ID = item_id
    AND   ORDER_LINE_ID IS NOT NULL ;*/

    l_onhand            NUMBER;
    l_available         NUMBER;
    l_rqoh              NUMBER;
   -- l_msg_data          VARCHAR2(2000);
   -- l_msg_count         NUMBER;
    l_return_status     VARCHAR2(128);
    l_qr                NUMBER;
    l_qs                NUMBER;
    l_temp_reserv_quantity NUMBER;
    l_api_name varchar2(60) := 'CSP_SCH_INT_PVT.CHECK_LOCAl_INVENTORY';
    l_is_revision_control boolean := null;
  BEGIN
        IF p_revision IS NOT NULL THEN
                l_is_revision_control  := TRUE;
        END IF;
                x_return_status := FND_API.G_RET_STS_SUCCESS ;
                x_att := 0;
                inv_quantity_tree_pub.clear_quantity_cache;
                inv_quantity_tree_pub.query_quantities(p_api_version_number => 1.0
                                                     , p_organization_id  =>  p_org_id
                                                     , p_inventory_item_id => p_item_id
                                                     , p_subinventory_code => p_subinv_code
                                                     , x_qoh     => x_onhand
                                                     , x_atr     => l_available
                                                     , p_init_msg_lst   => fnd_api.g_false
                                                     , p_tree_mode   => inv_quantity_tree_pvt.g_transaction_mode
                                                     , p_is_revision_control => l_is_revision_control
                                                     , p_is_lot_control  => NULL
                                                     , p_is_serial_control => NULL
                                                     , p_revision    => p_revision
                                                     , p_lot_number   => NULL
                                                     , p_locator_id   => NULL
                                                     , x_rqoh     => l_rqoh
                                                     , x_qr     => l_qr
                                                     , x_qs     => l_qs
                                                     , x_att     => x_att
                                                     , x_return_status  => l_return_status
                                                     , x_msg_count   => x_msg_count
                                                     , x_msg_data    => x_msg_data
                                                     );

               /* OPEN reservation_check(p_org_id, p_subinv_code,p_item_id );
                LOOP
                    FETCH reservation_check INTO l_temp_reserv_quantity;
                    EXIT WHEN reservation_check% NOTFOUND;
                     x_att := x_att - l_temp_reserv_quantity ;
                 END LOOP;
                 CLOSE reservation_check;*/
            EXCEPTION
            WHEN OTHERS THEN
            FND_MESSAGE.SET_NAME('CSP', 'CSP_UNEXPECTED_EXEC_ERRORS');
            FND_MESSAGE.SET_TOKEN('ROUTINE', l_api_name, FALSE);
            FND_MESSAGE.SET_TOKEN('SQLERRM', sqlerrm, FALSE);
            FND_MSG_PUB.ADD;
            fnd_msg_pub.count_and_get
              ( p_count => x_msg_count
              , p_data  => x_msg_data);
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            return;
      END CHECK_LOCAL_INVENTORY;
      PROCEDURE TASKS_POST_INSERT( x_return_status out nocopy varchar2) IS
        p_task_id NUMBER;
        l_msg_data varchar2(3000);
        l_msg_count NUMBER;
        l_header_id NUMBER;
        p_task_template_id NUMBER;
      BEGIN
            p_task_id := jtf_tasks_pub.p_task_user_hooks.task_id;
             CSP_REQUIREMENT_POPULATE_PVT.POPULATE_REQUIREMENTS(p_task_id       => p_task_id
                                                              ,p_api_version   => 1.0
                                                              ,p_Init_Msg_List => FND_API.G_FALSE
                                                              ,p_commit        => FND_API.G_FALSE
                                                              ,x_return_status => x_return_status
                                                              ,x_msg_data      => l_msg_data
                                                              ,x_msg_count     => l_msg_count
                                                              ,px_header_id    => l_header_id
                                                              ,p_called_by     => 1);


      END TASKS_POST_INSERT;
      PROCEDURE strip_into_lines(px_options          IN OUT NOCOPY      CSP_SCH_INT_PVT.CSP_SHIP_PARAMETERS_TBL_TYPE
                                 ,p_ship_count      IN      CSP_SCH_INT_PVT.CSP_SHIP_METHOD_COUNT_TBL_TYP
                                 ,p_res_ship_parameters IN  CSP_SCH_INT_PVT.CSP_ORGS_SHIP_PARAM_TBL_TYPE
                                 ,px_available_list     IN OUT NOCOPY CSP_SCH_INT_PVT.CSP_AVAILABILITY_TBL_TYPE
                                 ,x_msg_data           OUT NOCOPY varchar2
                                 ,x_return_status      OUT NOCOPY varchar2
                                 ,x_msg_count          OUT NOCOPY NUMBER) IS


        l_org_ship_methode        org_ship_methodes_tbl_type ;
        l_final_option            CSP_SCH_INT_PVT.CSP_SHIP_PARAMETERS_TBL_TYPE ;
        min_cost number;
        previous_position NUMBER;
        str_length NUMBER;
        l_ship_methode_count NUMBER;
        g_arrival_date            DATE;
        current_position NUMBER;

      BEGIN
         l_final_option   :=         CSP_SCH_INT_PVT.CSP_SHIP_PARAMETERS_TBL_TYPE() ;
         l_org_ship_methode :=       org_ship_methodes_tbl_type() ;
          FOR I IN 1..px_options.count LOOP
               IF I =1 THEN
                    min_cost := px_options(I).transfer_cost;
                    l_final_option.extend;
                    l_final_option(l_final_option.count).resource_id       :=  px_options(I).resource_id;
                    l_final_option(l_final_option.count).resource_type     :=  px_options(I).resource_type;
                    l_final_option(l_final_option.count).lead_time         :=  px_options(I).lead_time   ;
                    l_final_option(l_final_option.count).transfer_cost     :=  px_options(I).transfer_cost;
                    IF px_options(I).shipping_methodes IS NOT NULL THEN
                        px_options(I).shipping_methodes := px_options(I).shipping_methodes || '$' ;
                    END IF;
                    l_final_option(l_final_option.count).shipping_methodes :=  px_options(I).shipping_methodes;
                    l_final_option(l_final_option.count).arrival_date      :=  px_options(I).arrival_date ;
               ELSE
                    SELECT LEAST(min_cost, px_options(I).transfer_cost) INTO min_cost
                    FROM   DUAL;
                    IF min_cost = px_options(I).transfer_cost THEN
                       l_final_option.trim(l_final_option.count);
                       l_final_option.extend;
                       l_final_option(l_final_option.count).resource_id       :=  px_options(I).resource_id;
                       l_final_option(l_final_option.count).resource_type     :=  px_options(I).resource_type;
                       l_final_option(l_final_option.count).lead_time         :=  px_options(I).lead_time   ;
                       l_final_option(l_final_option.count).transfer_cost     :=  px_options(I).transfer_cost;
                        IF px_options(I).shipping_methodes IS NOT NULL THEN
                            px_options(I).shipping_methodes := px_options(I).shipping_methodes || '$' ;
                        END IF;
                            l_final_option(l_final_option.count).shipping_methodes :=  px_options(I).shipping_methodes;
                            l_final_option(l_final_option.count).arrival_date      :=  px_options(I).arrival_date ;
                     END IF;
               END IF;
               g_arrival_date := l_final_option(l_final_option.count).arrival_date;
        END LOOP;
        previous_position :=1;
        str_length := 0;
        l_ship_methode_count := 1;
        IF p_ship_count.count > 1 THEN
            FOR I IN 1..p_ship_count.count LOOP
               IF p_ship_count(I).from_org_id <> p_ship_count(I).to_org_id  THEN
                    --IF I <> p_ship_count.count THEN
                        l_org_ship_methode.extend;
                        SELECT INSTR(l_final_option(1).shipping_methodes,'$',1,l_ship_methode_count ) INTO current_position
                        FROM   DUAL;
                        SELECT SUBSTR(l_final_option(1).shipping_methodes,previous_position,(current_position-previous_position))
                        INTO   l_org_ship_methode(l_org_ship_methode.count).shipping_methode
                        FROM   DUAL;
                        l_org_ship_methode(l_org_ship_methode.count).from_org := p_ship_count(I).from_org_id;
                        l_org_ship_methode(l_org_ship_methode.count).to_org   := p_ship_count(I).to_org_id ;
                        previous_position := current_position+1;
                        current_position := 1;
                        l_ship_methode_count := l_ship_methode_count + 1;
                 ELSE
                        l_org_ship_methode.extend;
                        l_org_ship_methode(l_org_ship_methode.count).from_org := p_ship_count(I).from_org_id;
                        l_org_ship_methode(l_org_ship_methode.count).to_org   := p_ship_count(I).to_org_id ;
                        l_org_ship_methode(l_org_ship_methode.count).shipping_methode := NULL;
                 END IF;
            END LOOP;
         ELSE
            l_org_ship_methode.extend;
            SELECT INSTR(l_final_option(1).shipping_methodes,'$',1,l_ship_methode_count ) INTO current_position
            FROM   DUAL;
            SELECT SUBSTR(l_final_option(1).shipping_methodes,previous_position,(current_position-previous_position))
            INTO   l_org_ship_methode(l_org_ship_methode.count).shipping_methode
            FROM   DUAL;
            l_org_ship_methode(l_org_ship_methode.count).from_org := p_ship_count(1).from_org_id;
            l_org_ship_methode(l_org_ship_methode.count).to_org   := p_ship_count(1).to_org_id ;
          ---  l_org_ship_methode(l_org_ship_methode.count).shipping_methode := l_final_option(1).shipping_methodes;
         END IF;
        FOR I IN 1..px_available_list.count LOOP
           IF px_available_list(I).sub_inventory IS NULL  AND (px_available_list(I).organization_id <> px_available_list(I).source_org) THEN
                FOR J IN 1..l_org_ship_methode.count LOOP
                    IF px_available_list(I).organization_id =l_org_ship_methode(J).to_org
                            AND  px_available_list(I).source_org =l_org_ship_methode(J).from_org THEN
                                px_available_list(I).shipping_methode := l_org_ship_methode(J).shipping_methode;
                            FOR K In 1..p_res_ship_parameters.count LOOP
                                IF p_res_ship_parameters(K).to_org_id = px_available_list(I).organization_id
                                    AND p_res_ship_parameters(K).from_org_id = px_available_list(I).source_org
                                    AND p_res_ship_parameters(K).shipping_method = px_available_list(I).shipping_methode THEN
                                    px_available_list(I).intransit_time := p_res_ship_parameters(K).lead_time ;
                                    exit;
                                END IF;
                            END LOOP;
                        EXIT;
                    END IF;
                END LOOP;
           END IF;
        END LOOP;
      END strip_into_lines;
       PROCEDURE ws_Check_engineers_subinv(p_resource_type IN varchar2
                                   ,p_resource_id  IN NUMBER
                                   ,p_parts_list    IN csp_sch_int_pvt.CSP_PARTS_TBL_TYP1
                                   ,p_include_alternate IN varchar2
                                   ,x_available_list   OUT NOCOPY csp_sch_int_pvt.ws_AVAILABLE_PARTS_tbl_TYP
                                   ,x_return_status   OUT NOCOPY varchar2
                                   ,x_msg_data      OUT NOCOPY varchar2
                                   ,x_msg_count      OUT NOCOPY  NUMBER) IS
            l_att NUMBER:=0;
            l_onhand NUMBER := 0;
            l_org_id NUMBER;
            l_subinv_code varchar2(30);
            l_items   csp_sch_int_pvt.alternate_items_table_type;

            CURSOR get_all_subinventories(l_resource_id number, l_resource_type varchar2) IS
            SELECT  cil.ORGANIZATION_ID, cil.SUBINVENTORY_CODE
            FROM    CSP_INV_LOC_ASSIGNMENTS cil,csp_sec_inventories csi
            WHERE   cil.RESOURCE_ID = l_resource_id
            AND     cil.RESOURCE_TYPE = l_resource_type
            AND     nvl(cil.EFFECTIVE_DATE_END,sysdate) >= sysdate
            AND     csi.organization_id = cil.organization_id
            and     csi.secondary_inventory_name = cil.subinventory_code
            and     csi.condition_type = 'G' ;

            CURSOR get_default_subinventory(l_resource_id number, l_resource_type varchar2) IS
            SELECT  ORGANIZATION_ID, SUBINVENTORY_CODE
            FROM    CSP_INV_LOC_ASSIGNMENTS
            WHERE   RESOURCE_ID = l_resource_id
            AND     RESOURCE_TYPE = l_resource_type
            AND     DEFAULT_CODE = 'IN' ;

            CURSOR get_source_meaning(l_type varchar2) IS
            select meaning
            from fnd_lookups
            where lookup_type = 'CSP_REQ_SOURCE_TYPE'
            and lookup_code = l_type;

            CURSOR get_item_type_meaning(l_item_type number) IS
            select meaning
            from mfg_lookups
            where lookup_type
            like 'MTL_RELATIONSHIP_TYPES'
            and lookup_code = l_item_type;

            CURSOR get_item_number(c_item_id NUMBER, c_org_id NUMBER) IS
            select CONCATENATED_SEGMENTS
            FROM   mtl_system_items_kfv
            where inventory_item_id = c_item_id
            and   organization_id = c_org_id;

            -- bug # 4618899
            CURSOR primary_uom_code(item_id NUMBER,org_id NUMBER) IS
            SELECT PRIMARY_UOM_CODE
            FROM   MTL_SYSTEM_ITEMS_B
            WHERE  INVENTORY_ITEM_ID = item_id
            AND    organization_id  = org_id;
            l_primary_uom varchar2(500);

      BEGIN
            l_items  := csp_sch_int_pvt.alternate_items_table_type();
            x_available_list   := csp_sch_int_pvt.ws_AVAILABLE_PARTS_tbl_TYP();
            OPEN get_default_subinventory(p_resource_id,p_resource_type);
            FETCH get_default_subinventory INTO l_org_id, l_subinv_code;
            CLOSE get_default_subinventory;
                 l_items.extend;
                 l_items(l_items.count).item                     := p_parts_list(1).item_id;
                 l_items(l_items.count).item_quantity            := p_parts_list(1).quantity;
                 l_items(l_items.count).item_uom                 := p_parts_list(1).item_uom;
                 l_items(l_items.count).alternate_item           := p_parts_list(1).item_id;
                 l_items(l_items.count).alternate_item_quantity  := p_parts_list(1).quantity;
                 l_items(l_items.count).alternate_item_uom       := p_parts_list(1).item_uom;
                 l_items(l_items.count).relation_type            := NULL;
                 l_items(l_items.count).revision                 := p_parts_list(1).revision;
              IF p_include_alternate = 'Y' THEN
                 get_alternates(p_parts_rec   => p_parts_list(1)
                               ,p_org_id      => l_org_id
                               ,px_alternate_items => l_items
                               ,x_return_status => x_return_status
                               ,x_msg_data      => x_msg_data
                               ,x_msg_count    => x_msg_count);
              END IF;

                open get_all_subinventories(p_resource_id,p_resource_type);
                LOOP
                    FETCH get_all_subinventories INTO l_org_id, l_subinv_code;
                    EXIT WHEN get_all_subinventories% NOTFOUND;
                    l_onhand := 0;
                    l_att := 0;
                    FOR I IN 1..l_items.count LOOP
                        CHECK_LOCAL_INVENTORY(p_org_id        => l_org_id
                                     ,p_revision     => l_items(I).revision
                                     ,p_subinv_code   => l_subinv_code
                                     ,p_item_id       => l_items(I).alternate_item
                                     ,x_att           => l_att
                                     ,x_onhand        => l_onhand
                                     ,x_return_status => x_return_status
                                     ,x_msg_data      => x_msg_data
                                     ,x_msg_count     => x_msg_count);
                       IF l_att > 0 or l_onhand > 0 THEN
                          x_available_list.extend;
                          x_available_list(x_available_list.count).item_id       := l_items(I).alternate_item;
                          x_available_list(x_available_list.count).item_uom      := l_items(I).alternate_item_uom;
                          x_available_list(x_available_list.count).revision      := l_items(I).revision;

                          -- bug # 6955417
                          if l_items(I).relation_type is not NULL then
                            OPEN get_item_type_meaning(l_items(I).relation_type);
                            FETCH get_item_type_meaning INTO x_available_list(x_available_list.count).item_type ;
                            CLOSE get_item_type_meaning;
                          end if;

                          x_available_list(x_available_list.count).source_org_id := l_org_id;
                          OPEN get_item_number(x_available_list(x_available_list.count).item_id ,x_available_list(x_available_list.count).source_org_id);
                          FETCH  get_item_number INTO x_available_list(x_available_list.count).item_number;
                          CLOSE get_item_number;
                          x_available_list(x_available_list.count).sub_inventory_code  := l_subinv_code;

                          -- bug # 4618899
                          --x_available_list(x_available_list.count).available_quantity  := l_att;
                          --x_available_list(x_available_list.count).on_hand_quantity    := l_onhand;

                          open primary_uom_code(x_available_list(x_available_list.count).item_id ,x_available_list(x_available_list.count).source_org_id);
                          fetch primary_uom_code into l_primary_uom;
                          close primary_uom_code;

                          -- for available_quantity
                          x_available_list(x_available_list.count).available_quantity :=
                                inv_convert.inv_um_convert(item_id => x_available_list(x_available_list.count).item_id
                                 , precision     => NULL  -- use default precision
                                 , from_quantity => l_att
                                 , from_unit     => l_primary_uom
                                 , to_unit       => x_available_list(x_available_list.count).item_uom
                                 , from_name     => NULL  -- from uom name
                                 , to_name       => NULL  -- to uom name
                                 );

                          -- for on_hand_quantity
                          x_available_list(x_available_list.count).on_hand_quantity :=
                                inv_convert.inv_um_convert(item_id => x_available_list(x_available_list.count).item_id
                                 , precision     => NULL  -- use default precision
                                 , from_quantity => l_onhand
                                 , from_unit     => l_primary_uom
                                 , to_unit       => x_available_list(x_available_list.count).item_uom
                                 , from_name     => NULL  -- from uom name
                                 , to_name       => NULL  -- to uom name
                                 );


                          x_available_list(x_available_list.count).arraival_date       := sysdate;
                          OPEN  get_source_meaning('RES');
                          FETCH get_source_meaning INTO x_available_list(x_available_list.count).source_type;
                          CLOSE get_source_meaning;
                       END IF;
                   END LOOP;
                END LOOP;
                CLOSE get_all_subinventories;
      END ws_Check_engineers_subinv;
      PROCEDURE ws_Check_other_eng_subinv(p_resource_list IN csp_sch_int_pvt.csp_ws_resource_table_type
                                   ,p_parts_list    IN csp_sch_int_pvt.CSP_PARTS_TBL_TYP1
                                   ,p_include_alternate IN varchar2
                                   ,x_available_list   OUT NOCOPY csp_sch_int_pvt.ws_AVAILABLE_PARTS_tbl_TYP
                                   ,x_return_status   OUT NOCOPY varchar2
                                   ,x_msg_data      OUT NOCOPY varchar2
                                   ,x_msg_count      OUT NOCOPY  NUMBER) IS

            l_att NUMBER:=0;
            l_onhand NUMBER := 0;
            l_org_id NUMBER;
            l_subinv_code varchar2(30);
            l_items   csp_sch_int_pvt.alternate_items_table_type;

            CURSOR get_default_subinventory(l_resource_id number, l_resource_type varchar2) IS
            SELECT  ORGANIZATION_ID, SUBINVENTORY_CODE
            FROM    CSP_INV_LOC_ASSIGNMENTS
            WHERE   RESOURCE_ID = l_resource_id
            AND     RESOURCE_TYPE = l_resource_type
            AND     DEFAULT_CODE = 'IN' ;

             CURSOR get_source_meaning(l_type varchar2) IS
            select meaning
            from fnd_lookups
            where lookup_type = 'CSP_REQ_SOURCE_TYPE'
            and lookup_code = l_type;

            CURSOR get_item_type_meaning(l_item_type number) IS
            select meaning
            from mfg_lookups
            where lookup_type
            like 'MTL_RELATIONSHIP_TYPES'
            and lookup_code = l_item_type;

            CURSOR get_item_number(c_item_id NUMBER, c_org_id NUMBER) IS
            select CONCATENATED_SEGMENTS
            FROM   mtl_system_items_kfv
            where inventory_item_id = c_item_id
            and   organization_id = c_org_id;

            -- bug # 4618899
            CURSOR primary_uom_code(item_id NUMBER,org_id NUMBER) IS
            SELECT PRIMARY_UOM_CODE
            FROM   MTL_SYSTEM_ITEMS_B
            WHERE  INVENTORY_ITEM_ID = item_id
            AND    organization_id  = org_id;
            l_primary_uom varchar2(500);

      BEGIN
            l_items   := csp_sch_int_pvt.alternate_items_table_type();
            x_available_list   := csp_sch_int_pvt.ws_AVAILABLE_PARTS_tbl_TYP();
            --null;
        /*    OPEN get_default_subinventory(p_resource_list(1).resource_id,p_resource_list(1).resource_type);
            FETCH get_default_subinventory INTO l_org_id, l_subinv_code;
            CLOSE get_default_subinventory;
                 l_items.extend;
                 l_items(l_items.count).item                     := p_parts_list(1).item_id;
                 l_items(l_items.count).item_quantity            := p_parts_list(1).quantity;
                 l_items(l_items.count).item_uom                 := p_parts_list(1).item_uom;
                 l_items(l_items.count).alternate_item           := p_parts_list(1).item_id;
                 l_items(l_items.count).alternate_item_quantity  := p_parts_list(1).quantity;
                 l_items(l_items.count).alternate_item_uom       := p_parts_list(1).item_uom;
                 l_items(l_items.count).relation_type            := NULL;
              IF p_include_alternate = 'Y' THEN
                 get_alternates(p_parts_rec   => p_parts_list(1)
                               ,p_org_id      => l_org_id
                               ,px_alternate_items => l_items
                               ,x_return_status => x_return_status
                               ,x_msg_data      => x_msg_data
                               ,x_msg_count    => x_msg_count);
              END IF;*/
                FOR J IN 1..p_resource_list.count LOOP
                    l_org_id := null;
                    l_subinv_code := null;
                    OPEN get_default_subinventory(p_resource_list(J).resource_id,p_resource_list(J).resource_type);
                    FETCH get_default_subinventory INTO l_org_id, l_subinv_code;
                    CLOSE get_default_subinventory;
                    IF l_org_id IS NOT NULL AND l_subinv_code IS NOT NULL THEN
                        IF l_items.count = 0 THEN
                            l_items.extend;
                            l_items(l_items.count).item                     := p_parts_list(1).item_id;
                            l_items(l_items.count).item_quantity            := p_parts_list(1).quantity;
                            l_items(l_items.count).item_uom                 := p_parts_list(1).item_uom;
                            l_items(l_items.count).alternate_item           := p_parts_list(1).item_id;
                            l_items(l_items.count).alternate_item_quantity  := p_parts_list(1).quantity;
                            l_items(l_items.count).alternate_item_uom       := p_parts_list(1).item_uom;
                            l_items(l_items.count).revision                 := p_parts_list(1).revision;
                            l_items(l_items.count).relation_type            := NULL;
                            IF p_include_alternate = 'Y' THEN
                                get_alternates(p_parts_rec   => p_parts_list(1)
                               ,p_org_id      => l_org_id
                               ,px_alternate_items => l_items
                               ,x_return_status => x_return_status
                               ,x_msg_data      => x_msg_data
                               ,x_msg_count    => x_msg_count);
                            END IF;
                        END IF;
                    l_att := 0;
                        FOR I IN 1..l_items.count LOOP
                            CHECK_LOCAL_INVENTORY(p_org_id        => l_org_id
                                     ,p_subinv_code   => l_subinv_code
                                     ,p_item_id       => l_items(I).alternate_item
                                     ,p_revision      => l_items(I).revision
                                     ,x_att           => l_att
                                     ,x_onhand        => l_onhand
                                     ,x_return_status => x_return_status
                                     ,x_msg_data      => x_msg_data
                                     ,x_msg_count     => x_return_status);
                            IF l_att > 0  THEN
                                x_available_list.extend;
                                x_available_list(x_available_list.count).resource_id   :=   p_resource_list(J).resource_id;
                                x_available_list(x_available_list.count).resource_type :=   p_resource_list(J).resource_type;
                                x_available_list(x_available_list.count).distance      :=   p_resource_list(J).distance;
                                x_available_list(x_available_list.count).unit          :=   p_resource_list(J).unit;
                                x_available_list(x_available_list.count).phone_number  :=  p_resource_list(J).phone_number;
                                x_available_list(x_available_list.count).name          :=   p_resource_list(J).name;
                                x_available_list(x_available_list.count).item_id       := l_items(I).alternate_item;
                                x_available_list(x_available_list.count).item_uom      := l_items(I).alternate_item_uom;

                              -- bug # 6955417
                              if l_items(I).relation_type is not NULL then
                                OPEN get_item_type_meaning(l_items(I).relation_type);
                                FETCH get_item_type_meaning INTO x_available_list(x_available_list.count).item_type ;
                                CLOSE get_item_type_meaning;
                              end if;

                                x_available_list(x_available_list.count).source_org_id := l_org_id;
                                OPEN get_item_number(x_available_list(x_available_list.count).item_id ,x_available_list(x_available_list.count).source_org_id);
                                FETCH  get_item_number INTO x_available_list(x_available_list.count).item_number;
                                CLOSE get_item_number;
                                x_available_list(x_available_list.count).sub_inventory_code  := l_subinv_code;

                          -- bug # 4618899
                          --x_available_list(x_available_list.count).available_quantity  := l_att;
                          --x_available_list(x_available_list.count).on_hand_quantity    := l_onhand;


                          open primary_uom_code(x_available_list(x_available_list.count).item_id ,x_available_list(x_available_list.count).source_org_id);
                          fetch primary_uom_code into l_primary_uom;
                          close primary_uom_code;

                          -- for available_quantity
                          x_available_list(x_available_list.count).available_quantity :=
                                inv_convert.inv_um_convert(item_id => x_available_list(x_available_list.count).item_id
                                 , precision     => NULL  -- use default precision
                                 , from_quantity => l_att
                                 , from_unit     => l_primary_uom
                                 , to_unit       => x_available_list(x_available_list.count).item_uom
                                 , from_name     => NULL  -- from uom name
                                 , to_name       => NULL  -- to uom name
                                 );

                          -- for on_hand_quantity
                          x_available_list(x_available_list.count).on_hand_quantity :=
                                inv_convert.inv_um_convert(item_id => x_available_list(x_available_list.count).item_id
                                 , precision     => NULL  -- use default precision
                                 , from_quantity => l_onhand
                                 , from_unit     => l_primary_uom
                                 , to_unit       => x_available_list(x_available_list.count).item_uom
                                 , from_name     => NULL  -- from uom name
                                 , to_name       => NULL  -- to uom name
                                 );

                                x_available_list(x_available_list.count).arraival_date       := sysdate;
                                OPEN  get_source_meaning('RES');
                                FETCH get_source_meaning INTO x_available_list(x_available_list.count).source_type;
                                CLOSE get_source_meaning;
                            END IF;
                          END LOOP;
                    END IF;
                END LOOP;
      END ws_Check_other_eng_subinv;

       PROCEDURE ws_Check_organizations(p_resource_type IN varchar2
                                   ,p_resource_id  IN NUMBER
                                   ,p_parts_list    IN csp_sch_int_pvt.CSP_PARTS_TBL_TYP1
                                   ,p_include_alternate IN varchar2
                                   ,x_available_list   OUT NOCOPY csp_sch_int_pvt.ws_AVAILABLE_PARTS_tbl_TYP
                                   ,x_return_status   OUT NOCOPY varchar2
                                   ,x_msg_data      OUT NOCOPY varchar2
                                   ,x_msg_count      OUT NOCOPY  NUMBER) IS

            l_att NUMBER:=0;
            l_onhand NUMBER := 0;
            l_org_id NUMBER;
            l_subinv_code varchar2(30);
            l_items   csp_sch_int_pvt.alternate_items_table_type;
            l_unavailable_list        CSP_SCH_INT_PVT.CSP_UNAVAILABILITY_TBL_TYPE ;
            l_interval                CSP_SCH_INT_PVT.csp_sch_interval_rec_typ;
            l_available_list          CSP_SCH_INT_PVT.CSP_AVAILABILITY_TBL_TYPE ;
            l_temp_avail_list          CSP_SCH_INT_PVT.CSP_AVAILABILITY_TBL_TYPE ;
            l_final_unavailable_list  CSP_SCH_INT_PVT.CSP_UNAVAILABILITY_TBL_TYPE ;
            l_options                 CSP_SCH_INT_PVT.CSP_SHIP_PARAMETERS_TBL_TYPE;
             l_ship_count              CSP_SCH_INT_PVT.CSP_SHIP_METHOD_COUNT_TBL_TYP;
             l_res_ship_parameters      CSP_SCH_INT_PVT.CSP_ORGS_SHIP_PARAM_TBL_TYPE;
             l_temp_options            CSP_SCH_INT_PVT.CSP_SHIP_PARAMETERS_TBL_TYPE;
             l_final_option            CSP_SCH_INT_PVT.CSP_SHIP_PARAMETERS_TBL_TYPE;
             l_return_status           varchar2(10);
             p_need_by_date             date := null ;
             l_atleast_one_rec          BOOLEAN;
             min_cost                   NUMBER;
             min_arrival_date           DATE;
             rec_pointer                NUMBER;

            CURSOR get_default_subinventory(l_resource_id number, l_resource_type varchar2) IS
            SELECT  ORGANIZATION_ID, SUBINVENTORY_CODE
            FROM    CSP_INV_LOC_ASSIGNMENTS
            WHERE   RESOURCE_ID = l_resource_id
            AND     RESOURCE_TYPE = l_resource_type
            AND     DEFAULT_CODE = 'IN' ;

             CURSOR get_source_meaning(l_type varchar2) IS
            select meaning
            from fnd_lookups
            where lookup_type = 'CSP_REQ_SOURCE_TYPE'
            and lookup_code = l_type;

            CURSOR get_item_type_meaning(l_item_type number) IS
            select meaning
            from mfg_lookups
            where lookup_type
            like 'MTL_RELATIONSHIP_TYPES'
            and lookup_code = l_item_type;

            CURSOR get_location_id(c_org_id NUMBER) IS
            select location_id
            from HR_ALL_ORGANIZATION_UNITS
            where organization_id = c_org_id;

            CURSOR get_item_number(c_item_id NUMBER, c_org_id NUMBER) IS
            select CONCATENATED_SEGMENTS
            FROM   mtl_system_items_kfv
            where inventory_item_id = c_item_id
            and   organization_id = c_org_id;

            CURSOR get_shpping_method_meaning(c_ship_method varchar2) IS
            select meaning
            from   OE_SHIP_METHODS_V
            where  lookup_code = c_ship_method;

      BEGIN

            l_unavailable_list  :=     CSP_SCH_INT_PVT.CSP_UNAVAILABILITY_TBL_TYPE() ;
            l_available_list    :=     CSP_SCH_INT_PVT.CSP_AVAILABILITY_TBL_TYPE();
            l_final_unavailable_list := CSP_SCH_INT_PVT.CSP_UNAVAILABILITY_TBL_TYPE() ;

             l_ship_count            :=  CSP_SCH_INT_PVT.CSP_SHIP_METHOD_COUNT_TBL_TYP();
             l_res_ship_parameters   :=  CSP_SCH_INT_PVT.CSP_ORGS_SHIP_PARAM_TBL_TYPE();
             l_temp_options          := CSP_SCH_INT_PVT.CSP_SHIP_PARAMETERS_TBL_TYPE ();
             l_final_option          := CSP_SCH_INT_PVT.CSP_SHIP_PARAMETERS_TBL_TYPE ();
             x_available_list   := csp_sch_int_pvt.ws_AVAILABLE_PARTS_tbl_TYP();
             l_items           := csp_sch_int_pvt.alternate_items_table_type();
            l_temp_avail_list   :=  CSP_SCH_INT_PVT.CSP_AVAILABILITY_TBL_TYPE() ;
            OPEN get_default_subinventory(p_resource_id,p_resource_type);
            FETCH get_default_subinventory INTO l_org_id, l_subinv_code;
            CLOSE get_default_subinventory;
                 l_items.extend;
                 l_items(l_items.count).item                     := p_parts_list(1).item_id;
                 l_items(l_items.count).item_quantity            := p_parts_list(1).quantity;
                 l_items(l_items.count).item_uom                 := p_parts_list(1).item_uom;
                 l_items(l_items.count).alternate_item           := p_parts_list(1).item_id;
                 l_items(l_items.count).alternate_item_quantity  := p_parts_list(1).quantity;
                 l_items(l_items.count).alternate_item_uom       := p_parts_list(1).item_uom;
                 l_items(l_items.count).relation_type            := NULL;
              IF p_include_alternate = 'Y' THEN
                 get_alternates(p_parts_rec   => p_parts_list(1)
                               ,p_org_id      => l_org_id
                               ,px_alternate_items => l_items
                               ,x_return_status => x_return_status
                               ,x_msg_data      => x_msg_data
                               ,x_msg_count    => x_msg_count);
              END IF;
            FOR J IN 1..l_items.count LOOP
                    l_unavailable_list.extend;
                    l_unavailable_list(l_unavailable_list.count).resource_type     := p_resource_type;
                    l_unavailable_list(l_unavailable_list.count).resource_id       := p_resource_id;
                    l_unavailable_list(l_unavailable_list.count).organization_id   := l_org_id;
                    l_unavailable_list(l_unavailable_list.count).item_id           := l_items(J).alternate_item;
                    l_unavailable_list(l_unavailable_list.count).item_uom          := l_items(J).alternate_item_uom;
                    l_unavailable_list(l_unavailable_list.count).quantity          := l_items(J).alternate_item_quantity;
                   -- l_unavailable_list(l_unavailable_list.count).ship_set_name     := p_parts_list(I).ship_set_name;
                    l_unavailable_list(l_unavailable_list.count).item_type         := l_items(J).relation_type ;
                    l_unavailable_list(l_unavailable_list.count).line_id          := 1;
            END LOOP;
        IF l_unavailable_list.count >=1 THEN
            CSP_SCH_INT_PVT.DO_ATP_CHECK(l_unavailable_list,l_interval,l_available_list,l_final_unavailable_list,l_return_status,x_msg_data,x_msg_count);
        END IF;
     IF l_available_list.count > 0 THEN
             l_atleast_one_rec := FALSE;
         FOR J IN 1..l_available_list.count LOOP
            l_temp_avail_list.extend;
            l_temp_avail_list(1) := l_available_list(J);
            l_options                := CSP_SCH_INT_PVT.CSP_SHIP_PARAMETERS_TBL_TYPE();
            l_temp_options          := CSP_SCH_INT_PVT.CSP_SHIP_PARAMETERS_TBL_TYPE ();
            CSP_SCH_INT_PVT.OPTIMIZE_OPTIONS(l_temp_avail_list,l_options,l_ship_count,l_res_ship_parameters,x_return_status,x_msg_data,x_msg_count);
            l_temp_avail_list.trim;
            min_cost := null;
            min_arrival_date := null;
            rec_pointer := null;
            FOR I IN 1..l_options.count LOOP
                IF ROUND(((l_options(I).arrival_date - sysdate) * 24),2) <=  ROUND(((p_need_by_date - sysdate) * 24),2)
                OR p_need_by_date IS NULL THEN
                l_temp_options.extend;
                l_temp_options(l_temp_options.count).resource_id       :=  l_options(I).resource_id;
                l_temp_options(l_temp_options.count).resource_type     :=  l_options(I).resource_type;
                l_temp_options(l_temp_options.count).lead_time         :=  l_options(I).lead_time   ;
                l_temp_options(l_temp_options.count).transfer_cost     :=  l_options(I).transfer_cost;
                l_temp_options(l_temp_options.count).shipping_methodes :=  l_options(I).shipping_methodes;
                l_temp_options(l_temp_options.count).arrival_date      :=  l_options(I).arrival_date ;
                l_atleast_one_rec := TRUE;
                IF p_need_by_date is not null then
                 IF min_cost is null then
                    min_cost :=  l_temp_options(l_temp_options.count).transfer_cost;
                    rec_pointer := l_temp_options.count;
                 ELSE
                    IF min_cost > l_temp_options(l_temp_options.count).transfer_cost THEN
                       min_cost := l_temp_options(l_temp_options.count).transfer_cost;
                       rec_pointer := l_temp_options.count;
                    END IF;
                 END IF;
                ELSE
                   if  min_arrival_date is null then
                        min_arrival_date := l_temp_options(l_temp_options.count).arrival_date;
                        rec_pointer := l_temp_options.count;
                   ELSE
                        IF min_arrival_date > l_temp_options(l_temp_options.count).arrival_date THEN
                            min_arrival_date := l_temp_options(l_temp_options.count).arrival_date;
                            rec_pointer := l_temp_options.count;
                        END IF;
                   END IF;
                  END IF;
                END IF;
             END LOOP;
               IF l_temp_options.count > 0 THEN
                    l_available_list(J).shipping_methode := l_temp_options(rec_pointer).shipping_methodes;
                    l_available_list(J).intransit_time := l_temp_options(rec_pointer).lead_time  ;
               ELSE
                    l_available_list(J).item_id := NULL;
               END IF;
           END LOOP;
               IF not l_atleast_one_rec THEN
                    FND_MESSAGE.SET_NAME('CSP', 'CSP_UNABLE_NEED_BY_DATE');
                    FND_MSG_PUB.ADD;
                    fnd_msg_pub.count_and_get
                    ( p_count => x_msg_count
                    , p_data  => x_msg_data);
               END IF;
     END IF;
         FOR J IN 1..l_available_list.count LOOP
                x_available_list.extend;
                x_available_list(x_available_list.count).item_uom          :=  p_parts_list(1).item_uom ;

                x_available_list(x_available_list.count).item_id          :=  l_available_list(J).item_id ;
                x_available_list(x_available_list.count).source_org_id    :=  l_available_list(J).source_org;
                OPEN get_item_number(x_available_list(x_available_list.count).item_id ,x_available_list(x_available_list.count).source_org_id);
                FETCH  get_item_number INTO x_available_list(x_available_list.count).item_number;
                CLOSE get_item_number;
                OPEN get_location_id(x_available_list(x_available_list.count).source_org_id);
                FETCH get_location_id INTO x_available_list(x_available_list.count).location_id;
                CLOSE get_location_id;
                OPEN get_shpping_method_meaning(l_available_list(J).shipping_methode);
                FETCH get_shpping_method_meaning INTO x_available_list(x_available_list.count).shipping_methode;
                CLOSE get_shpping_method_meaning;
                 x_available_list(x_available_list.count).shipping_method_code := l_available_list(J).shipping_methode;
              --  x_available_list(x_available_list.count).shipping_methode :=  l_available_list(J).shipping_methode;
                OPEN get_item_type_meaning(l_available_list(J).item_type);
                FETCH get_item_type_meaning INTO x_available_list(x_available_list.count).item_type;
                CLOSE get_item_type_meaning;
               --x_available_list(x_available_list.count).item_type        :=  l_available_list(J).item_type ;
                x_available_list(x_available_list.count).sub_inventory_code := l_available_list(J).sub_inventory;
                x_available_list(x_available_list.count).available_quantity := l_available_list(J).available_quantity;
                    IF l_available_list(J).shipping_methode IS NOT NULL THEN
                        x_available_list(x_available_list.count).source_type      := 'IO' ;
                        IF p_need_by_date IS NOT NULL THEN
                            x_available_list(x_available_list.count).arraival_date    := p_need_by_date ;
                            x_available_list(x_available_list.count).order_by_date    := x_available_list(x_available_list.count).arraival_date
                                                                   - l_available_list(J).intransit_time/24 ;
                        ELSE
                            x_available_list(x_available_list.count).arraival_date    := get_arrival_date(SYSDATE,
                                                                                        l_available_list(J).intransit_time,
                                                                                        l_org_id);
                            x_available_list(x_available_list.count).order_by_date    := SYSDATE;
                        END IF;
                   ELSE
                        x_available_list(x_available_list.count).source_type      := 'RES' ;
                   END IF;
         END LOOP;

      END ws_Check_organizations;
      PROCEDURE get_alternates(p_parts_rec    IN csp_sch_int_pvt.CSP_PARTS_REC_TYPE
                               ,p_org_id      IN  NUMBER
                               ,px_alternate_items IN OUT NOCOPY csp_sch_int_pvt.alternate_items_table_type
                               ,x_return_status OUT NOCOPY varchar2
                               ,x_msg_data      OUT NOCOPY varchar2
                               ,x_msg_count     OUT NOCOPY NUMBER)  IS

       l_temp_quantity NUMBER := 0;
       l_uom_code     varchar2(10);
       l_supersede_items  CSP_SUPERSESSIONS_PVT.NUMBER_ARR;
       l_substitute_item NUMBER;

        CURSOR primary_uom_code(item_id NUMBER,org_id NUMBER) IS
        SELECT PRIMARY_UOM_CODE
        FROM   MTL_SYSTEM_ITEMS_B
        WHERE  INVENTORY_ITEM_ID = item_id
        AND    organization_id  = org_id;

        CURSOR substitutes(item_id NUMBER,org_id NUMBER) IS
       /* SELECT mri.RELATED_ITEM_ID
        FROM   MTL_RELATED_ITEMS_VIEW mri, mtl_parameters mp
        WHERE  mp.organization_id = org_id
        AND    mri.INVENTORY_ITEM_ID = item_id
        AND    mri.RELATIONSHIP_TYPE_ID = 2
        AND    mri.ORGANIZATION_ID  = MP.MASTER_ORGANIZATION_ID;*/
        SELECT mri.RELATED_ITEM_ID
        FROM   MTL_RELATED_ITEMS mri, mtl_parameters mp
        WHERE  mp.organization_id = org_id
        AND    mri.INVENTORY_ITEM_ID = item_id
        AND    mri.RELATIONSHIP_TYPE_ID = 2
        AND    mri.ORGANIZATION_ID  = MP.MASTER_ORGANIZATION_ID;



      BEGIN
                    CSP_SUPERSESSIONS_PVT.get_supersede_bilateral_items(p_inventory_item_id => p_parts_rec.item_id
                                                    ,p_organization_id => p_org_id
                                                    ,x_supersede_items => l_supersede_items);
                    FOR J IN 1..l_supersede_items.count LOOP
                        l_uom_code := null;
                        OPEN primary_uom_code(l_supersede_items(J),p_org_id);
                        LOOP
                        FETCH primary_uom_code INTO l_uom_code;
                        EXIT WHEN primary_uom_code% NOTFOUND;
                        END LOOP;
                        CLOSE primary_uom_code;

                        l_temp_quantity :=
                        inv_convert.inv_um_convert(item_id       => l_supersede_items(J)
                                                 , precision     => NULL  -- use default precision
                                                 , from_quantity => p_parts_rec.quantity
                                                 , from_unit     => p_parts_rec.item_uom
                                                 , to_unit       => l_uom_code
                                                 , from_name     => NULL  -- from uom name
                                                 , to_name       => NULL  -- to uom name
                                                 );
                        px_alternate_items.extend;
                        px_alternate_items(px_alternate_items.count).item                     := p_parts_rec.item_id;
                        px_alternate_items(px_alternate_items.count).item_quantity            := p_parts_rec.quantity;
                        px_alternate_items(px_alternate_items.count).item_uom                 := p_parts_rec.item_uom;
                        px_alternate_items(px_alternate_items.count).alternate_item           := l_supersede_items(J);
                        px_alternate_items(px_alternate_items.count).alternate_item_quantity  := l_temp_quantity;
                        px_alternate_items(px_alternate_items.count).alternate_item_uom       := l_uom_code;
                        px_alternate_items(px_alternate_items.count).relation_type            := 8;
                        l_temp_quantity := 0;
                        l_uom_code := NULL;
                    END LOOP;
                    OPEN substitutes(p_parts_rec.item_id, p_org_id);
                    LOOP
                    FETCH substitutes INTO l_substitute_item;
                    EXIT WHEN substitutes % NOTFOUND;
                         l_uom_code := null;
                        OPEN primary_uom_code(l_substitute_item,p_org_id);
                        LOOP
                        FETCH primary_uom_code INTO l_uom_code;
                        EXIT WHEN primary_uom_code% NOTFOUND;
                        END LOOP;
                        CLOSE primary_uom_code;
                        l_temp_quantity :=
                        inv_convert.inv_um_convert(item_id       => l_substitute_item
                                                 , precision     => NULL  -- use default precision
                                                 , from_quantity => p_parts_rec.quantity
                                                 , from_unit     => p_parts_rec.item_uom
                                                 , to_unit       => l_uom_code
                                                 , from_name     => NULL  -- from uom name
                                                 , to_name       => NULL  -- to uom name
                                                 );
                        px_alternate_items.extend;
                        px_alternate_items(px_alternate_items.count).item                     := p_parts_rec.item_id;
                        px_alternate_items(px_alternate_items.count).item_quantity            := p_parts_rec.quantity;
                        px_alternate_items(px_alternate_items.count).item_uom                 := p_parts_rec.item_uom;
                        px_alternate_items(px_alternate_items.count).alternate_item           := l_substitute_item;
                        px_alternate_items(px_alternate_items.count).alternate_item_quantity  := l_temp_quantity;
                        px_alternate_items(px_alternate_items.count).alternate_item_uom       := l_uom_code;
                        px_alternate_items(px_alternate_items.count).relation_type            := 2;
                        l_temp_quantity := 0;
                        l_uom_code := NULL;
                    END LOOP;
                    CLOSE substitutes;
      END get_alternates;
       FUNCTION get_arrival_date(p_ship_date IN DATE,
                                p_lead_time IN NUMBER,
                                p_org_id IN NUMBER) return  DATE IS

        l_lead_time number;
        l_calendar_code varchar2(10);
        l_exception_set_id number;
        l_expected_arrival_date date;
        l_arrival_date date;
        l_no_of_days number;
        l_lead_time_in_days number;


        CURSOR csp_resource_calendar  IS
        SELECT  mp.calendar_code,mp.calendar_exception_set_id
        FROM    mtl_parameters mp
        where     mp.organization_id = p_org_id;


        cursor get_arrival_seq_number(c_calendar_code varchar2,
                                       c_exception_set_id number,
                                       c_calendar_date date,
                                       c_lead_time number) IS
        select bcd1.calendar_date
        from bom_calendar_dates bcd,
             bom_calendar_dates bcd1
        where bcd.calendar_code = c_calendar_code
        and   bcd.exception_set_id = c_exception_set_id
        and   bcd.calendar_date = c_calendar_date
        and   bcd1.calendar_code = bcd.calendar_code
        and   bcd1.exception_set_id = bcd.exception_set_id
        and   bcd1.seq_num = (bcd.seq_num + c_lead_time);

        cursor get_seq_number(c_calendar_code varchar2,
                                       c_exception_set_id number,
                                       c_calendar_date date)
                                      IS
          select bcd.seq_num
          from bom_calendar_dates bcd
          where   bcd.calendar_code = c_calendar_code
            and   bcd.exception_set_id = c_exception_set_id
            and   bcd.calendar_date = c_calendar_date;

     BEGIN
        OPEN csp_resource_calendar;
        FETCH csp_resource_calendar INTO l_calendar_code,l_exception_set_id ;
        CLOSE csp_resource_calendar;
        IF l_calendar_code is null then
            l_arrival_date := p_ship_date +  (p_lead_time * (1/24));
            return l_arrival_date;
        END IF;
        l_lead_time_in_days :=    p_lead_time * (1/24);
-- bug 3925273        l_expected_arrival_date := p_ship_date + l_lead_time_in_days;
        l_expected_arrival_date := trunc(p_ship_date) + (sysdate - trunc(sysdate)) + l_lead_time_in_days;
        l_no_of_days := trunc(l_expected_arrival_date) - trunc(p_ship_date);
        IF  l_no_of_days  >  0  THEN
            OPEN get_arrival_seq_number(l_calendar_code,
                                        l_exception_set_id,
                                       trunc(p_ship_date),
                                       trunc(l_no_of_days));
            FETCH get_arrival_seq_number INTO l_arrival_date;
            CLOSE get_arrival_seq_number;
            l_arrival_date := l_arrival_date + (l_expected_arrival_date - trunc(l_expected_arrival_date));
        ELSE
            l_arrival_date  := l_expected_arrival_date;
        END IF;
        return   trunc(l_arrival_date,'MI');
     END;
  FUNCTION get_order_by_date(p_org_id IN NUMBER,
                                p_ship_method varchar2,
                                p_need_by_date IN DATE,
                                p_lead_time IN NUMBER,
                                p_to_org_id IN NUMBER) return  DATE IS

        l_lead_time number;
        l_calendar_code varchar2(10);
        l_exception_set_id number;
        l_expected_arrival_date date;
        l_order_by_date date;
        l_no_of_days number;
        l_lead_time_in_days number;
        l_cutoff_time   date;
        l_server_cutoff_time date;
        l_server_cutoff_hours number;
        l_timezone_id number;
        l_server_time_zone_id number;
        l_return_status varchar2(10);
        l_msg_count number;
        l_msg_data  varchar2(2000);

        CURSOR csp_resource_calendar  IS
        SELECT  mp.calendar_code,mp.calendar_exception_set_id
        FROM    mtl_parameters mp
        WHERE   mp.organization_id = p_to_org_id ;


        cursor get_arrival_seq_number(c_calendar_code varchar2,
                                       c_exception_set_id number,
                                       c_calendar_date date,
                                       c_lead_time number) IS
        select bcd1.calendar_date
        from bom_calendar_dates bcd,
             bom_calendar_dates bcd1
        where bcd.calendar_code = c_calendar_code
        and   bcd.exception_set_id = c_exception_set_id
        and   bcd.calendar_date = c_calendar_date
        and   bcd1.calendar_code = bcd.calendar_code
        and   bcd1.exception_set_id = bcd.exception_set_id
        and   bcd1.seq_num = (bcd.seq_num - c_lead_time);

        cursor get_seq_number(c_calendar_code varchar2,
                                       c_exception_set_id number,
                                       c_calendar_date date)
                                      IS
          select bcd.seq_num
          from bom_calendar_dates bcd
          where   bcd.calendar_code = c_calendar_code
            and   bcd.exception_set_id = c_exception_set_id
            and   bcd.calendar_date = c_calendar_date;

        cursor get_cutoff_time(c_org_id number,
                               c_ship_method_code varchar2) IS
            select cutoff_time,timezone_id
            from CSP_CARRIER_DELIVERY_TIMES
            where  ORGANIZATION_ID = c_org_id
            and    SHIPPING_METHOD = c_ship_method_code;

     BEGIN
        l_server_time_zone_id   := FND_PROFILE.VALUE(NAME => 'SERVER_TIMEZONE_ID');
        OPEN csp_resource_calendar;
        FETCH csp_resource_calendar INTO l_calendar_code,l_exception_set_id ;
        CLOSE csp_resource_calendar;
        IF l_calendar_code is null then
            l_order_by_date := p_need_by_date -  (p_lead_time * (1/24));
            return l_order_by_date;
        END IF;
        l_lead_time_in_days :=    p_lead_time * (1/24);
        l_expected_arrival_date := p_need_by_date - l_lead_time_in_days;
        l_no_of_days :=  trunc(p_need_by_date) - trunc(l_expected_arrival_date);
        IF  l_no_of_days  >  0  THEN
            OPEN get_arrival_seq_number(l_calendar_code,
                                        l_exception_set_id,
                                       trunc(p_need_by_date),
                                       trunc(l_no_of_days));
            FETCH get_arrival_seq_number INTO l_order_by_date;
            CLOSE get_arrival_seq_number;
            l_order_by_date := l_order_by_date + (l_expected_arrival_date - trunc(l_expected_arrival_date));
        ELSE
            l_order_by_date  := l_expected_arrival_date;
        END IF;
        OPEN get_cutoff_time(p_org_id,p_ship_method);
        FETCH get_cutoff_time INTO l_cutoff_time ,  l_timezone_id;
        CLOSE get_cutoff_time;
        IF l_cutoff_time IS NOT NULL and l_server_time_zone_id IS NOT NULL THEN
            HZ_TIMEZONE_PUB.Get_Time(   p_api_version  => 1.0,
                                    p_init_msg_list  => FND_API.G_FALSE,
                                    p_source_tz_id   => l_timezone_id,
                                    p_dest_tz_id     => l_server_time_zone_id,
                                    p_source_day_time  => l_cutoff_time,
                                    x_dest_day_time    => l_server_cutoff_time,
                                    x_return_status    => l_return_status ,
                                    x_msg_count        => l_msg_count ,
                                    x_msg_data         => l_msg_data);
            IF l_return_status <> 'S' THEN
                l_server_cutoff_hours := nvl(to_number(to_char(l_cutoff_time,'HH24')),0) * 60 + nvl(to_number(to_char(l_cutoff_time,'MI')),0);
            ELSE
                l_server_cutoff_hours := nvl(to_number(to_char(l_server_cutoff_time,'HH24')),0) * 60 + nvl(to_number(to_char(l_server_cutoff_time,'MI')),0);
            END IF;
           IF l_server_cutoff_hours  < (nvl(to_number(to_char(l_order_by_date,'HH24')),0) * 60 + nvl(to_number(to_char(l_order_by_date,'MI')),0)) THEN
                l_order_by_date := trunc(l_order_by_date) + round(((l_server_cutoff_hours -60)/(24*60)),2);
            END IF;
        END IF;
        return l_order_by_date;
     END;
      procedure get_session_id(p_database_link IN varchar2, x_sesssion_id OUT NOCOPY NUMBER) IS
     PRAGMA AUTONOMOUS_TRANSACTION;
        l_statement varchar2(1000);
        l_statement1 varchar2(1000);
     BEGIN
        BEGIN
        l_statement := 'Select MRP_ATP_SCHEDULE_TEMP_S.NextVal From   Dual@'
                         || p_database_link;
                EXECUTE IMMEDIATE l_statement
                INTO x_sesssion_id;
        END;
        commit;
        Begin
        l_statement1 := 'alter session close database link ' ||p_database_link;
                EXECUTE IMMEDIATE l_statement1;
        END;
     END;

      PROCEDURE TASK_POST_CANCEL( x_return_status out nocopy varchar2) IS

           l_task_id NUMBER;
           l_task_status_id NUMBER;
            l_order_id  NUMBER;
            l_req_details_line_id NUMBER;
            l_reserv_id NUMBER;
            l_status varchar2(30);
            l_return_status varchar2(3);
            x_msg_data varchar2(4000);
            x_msg_count NUMBER;
            l_cleanup_needed Varchar2(1) := 'N';

    CURSOR get_reservations is
    select crld.source_id , crld.req_line_detail_id
    from  csp_req_line_details crld
         ,csp_requirement_lines crl
         ,csp_requirement_headers crh
    where  crh.task_id = l_task_id
    and crl.requirement_header_id = crh.requirement_header_id
    and crld.requirement_line_id = crl.requirement_line_id
    and crld.source_type = 'RES' ;

    CURSOR get_orders is
    select oeh.header_id, crld.req_line_detail_id
    from  csp_req_line_details crld
         ,csp_requirement_lines crl
         ,csp_requirement_headers crh
         ,oe_order_lines_all oel
         ,oe_order_headers_all oeh
    where  crh.task_id = l_task_id
    and crl.requirement_header_id = crh.requirement_header_id
    and crld.requirement_line_id = crl.requirement_line_id
    and crld.source_type = 'IO'
    and oel.line_id = crld.source_id
    and oeh.header_id =  oel.header_id
    order by oeh.header_id;

    CURSOR get_order_status(c_header_id NUMBER) IS
    select flow_status_code
    from   oe_order_headers_all
    where  header_id =  c_header_id;

    cursor cleanup_needed IS
    select 'Y'
    from jtf_task_statuses_vl
    where task_status_id = l_task_status_id
    and ( CANCELLED_FLAG = 'Y' or rejected_flag = 'Y');

    cursor get_line_details(c_order_header_id Number) is
    select REQ_LINE_DETAIL_ID
    from  csp_req_line_details crld,oe_order_lines_all oel
    where crld.source_id = oel.line_id
    and crld.source_type = 'IO'
    and oel.header_id = c_order_header_id;

     BEGIN
        x_return_status :=  FND_API.G_RET_STS_SUCCESS;
        l_return_status := FND_API.G_RET_STS_SUCCESS;
         l_task_id := jtf_tasks_pub.p_task_user_hooks.task_id;
         l_task_status_id := jtf_tasks_pub.p_task_user_hooks.task_status_id;
         OPEN cleanup_needed;
         FETCH cleanup_needed INTO l_cleanup_needed;
         CLOSE cleanup_needed;
       IF l_cleanup_needed = 'Y' THEN
         OPEN get_reservations ;
         LOOP
            FETCH get_reservations INTO l_reserv_id,l_req_details_line_id;
            EXIT WHEN  get_reservations%NOTFOUND;
                CSP_SCH_INT_PVT.CANCEL_RESERVATION(l_reserv_id,l_return_status,x_msg_data,x_msg_count);
                IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
                     x_return_status := FND_API.G_RET_STS_SUCCESS;
                ELSIF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
                    delete from csp_req_line_details where req_line_detail_id = l_req_details_line_id;
                END IF;
         END LOOP;
         close get_reservations;
            OPEN get_orders;
            LOOP
                FETCH get_orders INTO l_order_id ,l_req_details_line_id ;
                EXIT WHEN get_orders% NOTFOUND;
                OPEN get_order_status(l_order_id);
                FETCH get_order_status INTO l_status;
                CLOSE get_order_status;
                IF l_status <> 'CANCELLED' THEN
                   CSP_SCH_INT_PVT.CANCEL_ORDER(l_order_id,l_return_status,x_msg_data,x_msg_count);
                   IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                       x_return_status := FND_API.G_RET_STS_SUCCESS;
                   ELSIF l_return_status =  FND_API.G_RET_STS_SUCCESS THEN
                     open get_line_details(l_order_id);
                     LOOP
                         FETCH get_line_details INTO l_req_details_line_id;
                         EXIT WHEN get_line_details% NOTFOUND;
                            delete from csp_req_line_details where req_line_detail_id = l_req_details_line_id;
                     END LOOP;
                     CLOSE get_line_details;
                   END IF;
                END IF;
            END LOOP;
            CLOSE get_orders;
        END IF;
     END;
      PROCEDURE   CREATE_RES_FOR_RCV_TRANXS(p_transaction_id IN NUMBER
                                           ,x_return_Status  OUT NOCOPY varchar2
                                           ,x_msg_data OUT NOCOPY varchar2) IS

        CURSOR get_res_detail IS
        select mmt.transaction_quantity transaction_quantity ,mmt.inventory_item_id  item_id,
               mmt.revision revision, mmt.organization_id org_id,mmt.subinventory_code subinv_code,
               crld.source_id line_id, mmt.transaction_uom uom,crh.need_by_date need_by_date,
               crld.requirement_line_id requirement_line_id,rcl.quantity_shipped quantity_shipped,
               rcl.quantity_received quantity_received,crld.req_line_detail_id req_line_detail_id
        from mtl_material_transactions mmt,RCV_SHIPMENT_headers rsh,
            rcv_shipment_lines rcl,
            oe_order_lines_all oola,csp_req_line_details crld,
            csp_requirement_lines crl,
            csp_requirement_headers crh
        where mmt.transaction_id = p_transaction_id
        and mmt.shipment_number = rsh.shipment_num
        and rsh.shipment_header_id = rcl.shipment_header_id
        and oola.source_document_line_id = rcl.requisition_line_id
        and crld.source_id = oola.line_id
        and mmt.source_code = 'RCV'
        and crld.source_type = 'IO'
        and crld.requirement_line_id = crl.requirement_line_id
        and crh.requirement_header_id = crl.requirement_header_id
           and crh.task_id is not null
         UNION
         select mmt.transaction_quantity transaction_quantity ,mmt.inventory_item_id  item_id,
               mmt.revision revision, mmt.organization_id org_id,mmt.subinventory_code subinv_code,
               crld.source_id line_id, mmt.transaction_uom uom,crh.need_by_date need_by_date,
               crld.requirement_line_id requirement_line_id, mmt.transaction_quantity quantity_shipped,
               mmt.transaction_quantity quantity_received,crld.req_line_detail_id req_line_detail_id
         from mtl_material_transactions mmt,
            oe_order_lines_all oola,csp_req_line_details crld,
            csp_requirement_lines crl,csp_requirement_headers crh
          where mmt.transaction_id = p_transaction_id
          and  oola.source_document_id = mmt.transaction_source_id
           and crld.source_id = oola.line_id
        and (mmt.source_code = 'ORDER ENTRY')
        and TRANSACTION_QUANTITY > 0
        and crld.source_type = 'IO'
        and crld.requirement_line_id = crl.requirement_line_id
        and crh.requirement_header_id = crl.requirement_header_id
           and crh.task_id is not null;

         l_reservation_parts CSP_SCH_INT_PVT.RESERVATION_REC_TYP;
         l_reservation_id NUMBER;
         l_req_line_detali_id NUMBER;

      BEGIN
        FOR grd in get_res_detail LOOP
                l_reservation_id := NULL;
                l_reservation_parts.need_by_date       := nvl(grd.need_by_date,sysdate);
                l_reservation_parts.organization_id    := grd.org_id ;
                l_reservation_parts.item_id            := grd.item_id;
                l_reservation_parts.item_uom_code      := grd.uom;
                l_reservation_parts.quantity_needed    := grd.transaction_quantity ;
                l_reservation_parts.sub_inventory_code := grd.subinv_code ;
                l_reservation_parts.line_id            := p_transaction_id;
                l_reservation_parts.revision           := grd.revision;
                l_reservation_id := csp_sch_int_pvt.CREATE_RESERVATION(l_reservation_parts
                                                                        ,x_return_status
                                                                        ,x_msg_data );
                l_req_line_detali_id := NULL;
                IF l_reservation_id IS NOT NULL AND l_reservation_id >0 THEN
                        csp_req_line_details_pkg.insert_row(px_req_line_detail_id => l_req_line_detali_id
                                              ,p_requirement_line_id => grd.requirement_line_id
                                              ,p_created_by => FND_GLOBAL.user_id
                                              ,p_creation_date => sysdate
                                              ,p_last_updated_by =>  FND_GLOBAL.user_id
                                              ,p_last_update_date => sysdate
                                              ,p_last_update_login => FND_GLOBAL.login_id
                                              ,p_source_type => 'RES'
                                              ,p_source_id => l_reservation_id );

                IF grd.quantity_shipped = grd.quantity_received THEN
                 csp_req_line_details_pkg.delete_row(grd.req_line_detail_id);
               END IF;
           END IF;
        END LOOP;
      END CREATE_RES_FOR_RCV_TRANXS;
       PROCEDURE cancel_order_line(
              p_order_line_id IN NUMBER,
              p_cancel_reason IN Varchar2,
              x_return_status OUT NOCOPY VARCHAR2,
              x_msg_count     OUT NOCOPY NUMBER,
              x_msg_data      OUT NOCOPY VARCHAR2) IS
       BEGIN
            csp_parts_order.cancel_order_line(p_order_line_id
                                        ,p_cancel_reason
                                        ,x_return_status
                                        ,x_msg_count
                                        ,x_msg_data);
       END;
     PROCEDURE DELETE_RESERVATION(p_reservation_id IN NUMBER
                                ,x_return_status     OUT NOCOPY VARCHAR2
                                ,x_msg_data         OUT NOCOPY VARCHAR2)
    IS
          CURSOR csp_transactions IS
          SELECT TRANSACTION_SOURCE_TYPE_ID,TRANSACTION_SOURCE_TYPE_NAME
          FROM   MTL_TXN_SOURCE_TYPES
          WHERE  transaction_source_type_id = 13;
          I NUMBER;
          l_api_version_number number :=1;
          l_init_msg_lst  varchar2(1) := fnd_api.g_true;
          x_msg_count number;
         -- x_msg_data  varchar2(128);
          l_rsv_rec  inv_reservation_global.mtl_reservation_rec_type;
          l_serial_number inv_reservation_global.serial_number_tbl_type;
          x_serial_number inv_reservation_global.serial_number_tbl_type;
          l_partial_reservation_flag varchar2(1):= fnd_api.g_false;
          l_force_reservation_flag varchar2(1) := fnd_api.g_true;
          l_validation_flag    varchar2(1) := fnd_api.g_true;
          l_source_type_id     NUMBER;
          l_source_name        varchar2(30);
          x_quantity_reserved  number;
          x_reservation_id number;
          l_msg varchar2(2000);
          --x_return_status varchar(128);
     BEGIN
          x_return_status  := FND_API.G_RET_STS_SUCCESS;
          OPEN csp_transactions;
            LOOP
                FETCH csp_transactions INTO l_source_type_id, l_source_name;
                EXIT WHEN csp_transactions%NOTFOUND;
            END LOOP;
          CLOSE csp_transactions;
                IF l_source_type_id IS NULL THEN
                    raise NO_DATA_FOUND ;
                END IF;
                l_rsv_rec.reservation_id   :=  p_reservation_id;
                /*l_rsv_rec.requirement_date := p_reservation_parts.need_by_date  ;
                l_rsv_rec.organization_id  := p_reservation_parts.organization_id  ;
                l_rsv_rec.inventory_item_id := p_reservation_parts.item_id   ;
                l_rsv_rec.demand_source_type_id  := l_source_type_id ;
                l_rsv_rec.demand_source_name     := l_source_name ;
                l_rsv_rec.demand_source_header_id   := NULL;
                l_rsv_rec.demand_source_line_id     := p_reservation_parts.line_id;
                l_rsv_rec.demand_source_delivery    := NULL;
                l_rsv_rec.primary_uom_code          := p_reservation_parts.item_UOM_code ;
                l_rsv_rec.primary_uom_id            := NULL;
                l_rsv_rec.reservation_uom_code      := p_reservation_parts.item_UOM_code;
                l_rsv_rec.reservation_uom_id        := NULL;
                l_rsv_rec.reservation_quantity      := p_reservation_parts.quantity_needed;
                l_rsv_rec.primary_reservation_quantity  := NUll;
                l_rsv_rec.detailed_quantity         := null;
                l_rsv_rec.autodetail_group_id       := NULL;
                l_rsv_rec.external_source_code       := NULL;
                l_rsv_rec.external_source_line_id     := NULL;
                l_rsv_rec.supply_source_type_id        := 13; --inv_reservation_global.g_source_type_internal_req;
                l_rsv_rec.supply_source_header_id      := NULL;
                l_rsv_rec.supply_source_line_id        := NULL;
                l_rsv_rec.supply_source_name           := NULL;
                l_rsv_rec.supply_source_line_detail    := NULL;
                l_rsv_rec.revision                     := p_reservation_parts.revision ;
                l_rsv_rec.subinventory_code            := p_reservation_parts.sub_inventory_code ;
                l_rsv_rec.subinventory_id              := NULL ;
                l_rsv_rec.locator_id                   := NULL;
                l_rsv_rec.lot_number                   := NULL;
                l_rsv_rec.lot_number_id                := NULL;
                l_rsv_rec.pick_slip_number            := NULL;
                l_rsv_rec.lpn_id                      := NULL;
                l_rsv_rec.attribute_category       := NULL;
                l_rsv_rec.attribute1               := NULL;
                l_rsv_rec.attribute2               := NULL;
                l_rsv_rec.attribute3               := NULL;
                l_rsv_rec.attribute4               := NULL;
                l_rsv_rec.attribute5               := NULL;
                l_rsv_rec.attribute6               := NULL;
                l_rsv_rec.attribute7               := NULL;
                l_rsv_rec.attribute8               := NULL;
                l_rsv_rec.attribute9               := NULL;
                l_rsv_rec.attribute10              := NULL;
                l_rsv_rec.attribute11              := NULL;
                l_rsv_rec.attribute12              := NULL;
                l_rsv_rec.attribute13              := NULL;
                l_rsv_rec.attribute14              := NULL;
                l_rsv_rec.attribute15              := NULL;
                l_rsv_rec.ship_ready_flag          := NULL;*/
                INV_RESERVATION_PUB.delete_reservation(l_api_version_number
                                                 , l_init_msg_lst
                                                 , x_return_status
                                                 , x_msg_count
                                                 , x_msg_data
                                                 , l_rsv_rec
                                                 , l_serial_number);
           EXCEPTION
        WHEN NO_DATA_FOUND THEN
            FND_MESSAGE.SET_NAME('CSP', 'CSP_SCH_TRANSACTION');
            FND_MSG_PUB.ADD;
            fnd_msg_pub.count_and_get
              ( p_count => x_msg_count
              , p_data  => x_msg_data);
            x_return_status := FND_API.G_RET_STS_ERROR;
        WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     END DELETE_RESERVATION;

        -- first find out all RES created after receiving
        -- read item, qty and src org/subinv information from the RES
        -- release the RES
        -- do part transfer using direct inter-org transfer or subinv transfer
        -- create a new reservation for new destination org/subinv
        -- link the RES to req_line
        -- update req_header with new dest org/subinv, resource

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
        ) is

        cursor old_res_details is
        SELECT dres.source_id,
          mr.inventory_item_id,
          mr.reservation_quantity,
          mr.reservation_uom_code,
          mr.organization_id,
          mr.subinventory_code,
          dres.requirement_line_id,
          dres.req_line_detail_id,
          h.requirement_header_id,
		  mr.serial_number
        FROM csp_requirement_headers h,
          csp_requirement_lines l,
          csp_req_line_details dio,
          csp_req_line_details dres,
          oe_order_lines_all oola,
          mtl_reservations mr
        WHERE h.task_id             = p_task_id
        AND h.task_assignment_id    = p_task_asgn_id
        AND h.address_type         IN ('T', 'C', 'P')
        AND h.requirement_header_id = l.requirement_header_id
        AND l.requirement_line_id   = dio.requirement_line_id
        AND dio.source_type        = 'IO'
        AND dio.source_id = oola.line_id
        AND csp_pick_utils.get_order_status(oola.line_id,oola.flow_status_code)      = 'FULLY RECEIVED'
        AND dio.requirement_line_id = dres.requirement_line_id
        AND oola.inventory_item_id    = mr.inventory_item_id
        AND oola.ordered_quantity   = mr.reservation_quantity
        AND dres.source_type       = 'RES'
        AND dres.source_id = mr.reservation_id;

        l_trans_record csp_transactions_pub.trans_items_rec_type;
        l_trans_tbl csp_transactions_pub.trans_items_tbl_type;
        l_reservation_rec   csp_sch_int_pvt.reservation_rec_typ;
        l_requirement_header      csp_requirement_headers_pvt.requirement_header_rec_type;
        l_new_reservation_id number;
        l_req_line_detail_id number;
        l_new_dest_org number := -999;
        l_new_dest_subinv varchar2(30) := null;
        l_resource_name varchar2(2000);
        l_resource_type_name varchar2(2000);

        cursor req_line_dtl_rows (v_req_line_id number) is
        SELECT req_line_detail_id
        FROM csp_req_line_details
        WHERE requirement_line_id = v_req_line_id
        AND source_type = 'RES';

        CURSOR  resource_org IS
        SELECT ORGANIZATION_ID,
          SUBINVENTORY_CODE
        FROM CSP_INV_LOC_ASSIGNMENTS
        WHERE RESOURCE_ID = p_new_resource_id
        AND RESOURCE_TYPE = p_new_resource_type
        AND DEFAULT_CODE  = 'IN';

		-- bug 16452324
		-- handle serial numbers
		l_is_serial varchar2(1) := 'N';
		l_counter number;

		cursor get_serial_nums (v_res_id number, v_item_id number, v_org_id number, v_subinv varchar2) is
		SELECT serial_number
		FROM Mtl_Serial_Numbers
		WHERE reservation_id          = v_res_id
		AND inventory_item_id         = v_item_id
		AND CURRENT_ORGANIZATION_ID   = v_org_id
		AND CURRENT_SUBINVENTORY_CODE = v_subinv;

        begin
                log('move_parts_on_reassign', 'begin...');
                log('move_parts_on_reassign', 'p_task_id=' || p_task_id);
                log('move_parts_on_reassign', 'p_task_asgn_id=' || p_task_asgn_id);
                log('move_parts_on_reassign', 'p_new_task_asgn_id=' || p_new_task_asgn_id);
                log('move_parts_on_reassign', 'p_new_need_by_date=' || to_char(p_new_need_by_date, 'dd-MON-YYYY HH24:MI'));
                log('move_parts_on_reassign', 'p_new_resource_id=' || p_new_resource_id);
                log('move_parts_on_reassign', 'p_new_resource_type=' || p_new_resource_type);

                x_return_status  := FND_API.G_RET_STS_SUCCESS;

                open resource_org;
                fetch resource_org into l_new_dest_org, l_new_dest_subinv;
                close resource_org;

                log('move_parts_on_reassign', 'l_new_dest_org=' || l_new_dest_org);
                log('move_parts_on_reassign', 'l_new_dest_subinv=' || l_new_dest_subinv);

                if l_new_dest_org = -999 then
                        x_return_status := FND_API.G_RET_STS_ERROR;
                        l_resource_name := csp_pick_utils.get_object_name(p_new_resource_type, p_new_resource_id);
                        SELECT NAME
                        into l_resource_type_name
                        FROM JTF_OBJECTS_VL
                        WHERE OBJECT_CODE = p_new_resource_type;
                        FND_MESSAGE.SET_NAME('CSP', 'CSP_SCH_DEFAULT_SUBINV');
                        FND_MESSAGE.SET_TOKEN('RESOURCE_TYPE',l_resource_type_name,FALSE);
                        FND_MESSAGE.SET_TOKEN('RESOURCE_NAME',l_resource_name, FALSE);
                        FND_MSG_PUB.ADD;
                        fnd_msg_pub.count_and_get
                                        ( p_count => x_msg_count
                                        , p_data  => x_msg_data);
                        return;
                end if;

                for old_res_record in old_res_details
                loop
                        log('move_parts_on_reassign', 'old_res_record.source_id=' || old_res_record.source_id);
                        log('move_parts_on_reassign', 'old_res_record.inventory_item_id=' || old_res_record.inventory_item_id);
                        log('move_parts_on_reassign', 'old_res_record.reservation_quantity=' || old_res_record.reservation_quantity);
                        log('move_parts_on_reassign', 'old_res_record.reservation_uom_code=' || old_res_record.reservation_uom_code);
                        log('move_parts_on_reassign', 'old_res_record.organization_id=' || old_res_record.organization_id);
                        log('move_parts_on_reassign', 'old_res_record.subinventory_code=' || old_res_record.subinventory_code);
                        log('move_parts_on_reassign', 'old_res_record.requirement_line_id=' || old_res_record.requirement_line_id);
                        log('move_parts_on_reassign', 'old_res_record.req_line_detail_id=' || old_res_record.req_line_detail_id);
                        log('move_parts_on_reassign', 'old_res_record.requirement_header_id=' || old_res_record.requirement_header_id);
						log('move_parts_on_reassign', 'old_res_record.serial_number=' || old_res_record.serial_number);

						-- check if the reservation has any serial number
						l_trans_record.INVENTORY_ITEM_ID := old_res_record.inventory_item_id;
						l_trans_record.QUANTITY := old_res_record.reservation_quantity;
						l_trans_record.UOM_CODE := old_res_record.reservation_uom_code;
						l_trans_record.FRM_ORGANIZATION_ID := old_res_record.organization_id;
						l_trans_record.FRM_SUBINVENTORY_CODE := old_res_record.subinventory_code;
						l_trans_record.serial_number := old_res_record.serial_number;
						l_trans_record.TO_ORGANIZATION_ID := l_new_dest_org;
						l_trans_record.TO_SUBINVENTORY_CODE := l_new_dest_subinv;

						l_counter := 1;
						l_is_serial := 'N';
						log('move_parts_on_reassign', 'resetting l_is_serial=' || l_is_serial);
						for r_ser_num in get_serial_nums(old_res_record.source_id,
															old_res_record.inventory_item_id,
															old_res_record.organization_id,
															old_res_record.subinventory_code)
						loop
							l_is_serial := 'Y';
							log('move_parts_on_reassign', 'l_is_serial=' || l_is_serial);
							l_trans_record.QUANTITY := 1;
							l_trans_record.SERIAL_NUMBER := r_ser_num.serial_number;
							log('move_parts_on_reassign', 'adding serial number for transfer=' || l_trans_record.SERIAL_NUMBER);
							log('move_parts_on_reassign', 'populating serialized record for item_id=' || l_trans_record.INVENTORY_ITEM_ID);
							l_trans_tbl(l_counter) := l_trans_record;
							l_counter := l_counter + 1;
						end loop;

						log('move_parts_on_reassign', 'l_is_serial=' || l_is_serial);

						if l_is_serial = 'N' then
							log('move_parts_on_reassign', 'l_is_serial=' || l_is_serial);
							log('move_parts_on_reassign', 'populating nonserialized record for item_id=' || l_trans_record.INVENTORY_ITEM_ID);
							l_trans_record.serial_number := NULL;
							l_trans_tbl(1) := l_trans_record;
							log('move_parts_on_reassign', 'Now nulling out (not serialized!) l_trans_tbl(1).serial_number=' || l_trans_tbl(1).serial_number);
							l_trans_tbl(1).serial_number := NULL;
						end if;
						log('move_parts_on_reassign', 'l_trans_tbl.count=' || l_trans_tbl.count);

                        CSP_SCH_INT_PVT.CANCEL_RESERVATION(old_res_record.source_id, x_return_status, x_msg_data, x_msg_count);

                        log('move_parts_on_reassign', 'x_return_status=' || x_return_status);

                        if x_return_status <> FND_API.G_RET_STS_SUCCESS then
                                x_return_status := FND_API.G_RET_STS_ERROR;
                                FND_MESSAGE.SET_NAME('CSP', 'CSP_SCH_NOT_CANCEL_ORDER');
                                FND_MSG_PUB.ADD;
                                fnd_msg_pub.count_and_get
                                                ( p_count => x_msg_count
                                                , p_data  => x_msg_data);
                                return;
                        end if;

                        if old_res_record.organization_id <> l_new_dest_org then
							log('move_parts_on_reassign', 'before calling transact_intorg_transfer...');
							csp_transactions_pub.transact_intorg_transfer(
									P_Api_Version_Number => 1.0,
									p_Trans_Items => l_trans_tbl,
									p_if_intransit => false,
									X_Return_Status => x_return_status,
									X_Msg_Count => x_msg_count,
									X_Msg_Data => x_msg_data
							);
                        else
							log('move_parts_on_reassign', 'before calling transact_subinv_transfer...');
							csp_transactions_pub.transact_subinv_transfer(
									P_Api_Version_Number => 1.0,
									p_Trans_Items => l_trans_tbl,
									X_Return_Status => x_return_status,
									X_Msg_Count => x_msg_count,
									X_Msg_Data => x_msg_data
							);
                        end if;

						log('move_parts_on_reassign', 'after calling csp_transactions_pub... x_return_status=' || x_return_status);
						if x_return_status <> FND_API.G_RET_STS_SUCCESS then
							x_return_status := FND_API.G_RET_STS_ERROR;
							FND_MESSAGE.SET_NAME('CSP', 'CSP_SCH_NOT_CANCEL_ORDER');
							FND_MSG_PUB.ADD;
							fnd_msg_pub.count_and_get
											( p_count => x_msg_count
											, p_data  => x_msg_data);
							return;
						end if;

						for l_counter in 1..l_trans_tbl.count
						loop
							log('move_parts_on_reassign', 'l_trans_tbl(l_counter).ERROR_MSG=' || l_trans_tbl(l_counter).ERROR_MSG);
							if l_trans_tbl(l_counter).ERROR_MSG is not null then
								x_return_status := FND_API.G_RET_STS_ERROR;
								FND_MESSAGE.SET_NAME('CSP', 'CSP_SCH_NOT_CANCEL_ORDER');
								FND_MSG_PUB.ADD;
								fnd_msg_pub.count_and_get
												( p_count => x_msg_count
												, p_data  => x_msg_data);
								return;
							end if;
						end loop;



                        l_reservation_rec.need_by_date := sysdate;
                        l_reservation_rec.organization_id := l_new_dest_org;
                        l_reservation_rec.sub_inventory_code := l_new_dest_subinv;
                        l_reservation_rec.item_id := old_res_record.inventory_item_id;
                        l_reservation_rec.item_uom_code := old_res_record.reservation_uom_code;
                        l_reservation_rec.quantity_needed := old_res_record.reservation_quantity;
                        l_reservation_rec.line_id := old_res_record.requirement_line_id;

						for l_counter in 1..l_trans_tbl.count
						loop
							if l_trans_tbl(l_counter).SERIAL_NUMBER is not null then
								log('move_parts_on_reassign', 'creating reservation for serial_number=' || l_trans_tbl(l_counter).SERIAL_NUMBER);
								l_reservation_rec.serial_number := l_trans_tbl(l_counter).SERIAL_NUMBER;
								l_reservation_rec.quantity_needed := 1;
							else
								l_reservation_rec.serial_number := null;
							end if;

							log('move_parts_on_reassign', 'before creating a new reservation...');
							l_new_reservation_id := CSP_SCH_INT_PVT.CREATE_RESERVATION(
											  p_reservation_parts => l_reservation_rec,
											  x_return_status => x_return_status,
											  x_msg_data => x_msg_data);
							log('move_parts_on_reassign', 'after creating a new reservation...x_return_status=' || x_return_status);
							log('move_parts_on_reassign', 'l_new_reservation_id=' || l_new_reservation_id);

							if x_return_status <> FND_API.G_RET_STS_SUCCESS then
									x_return_status := FND_API.G_RET_STS_ERROR;
									FND_MESSAGE.SET_NAME('CSP', 'CSP_SCH_NOT_CANCEL_ORDER');
									FND_MSG_PUB.ADD;
									fnd_msg_pub.count_and_get
													( p_count => x_msg_count
													, p_data  => x_msg_data);
									return;
							end if;
						end loop;




                        for r_req_line_dtl_rec in req_line_dtl_rows(old_res_record.requirement_line_id)
                        loop
                                log('move_parts_on_reassign', 'deleting req_line_detail_id=' || r_req_line_dtl_rec.req_line_detail_id);
                                csp_req_line_details_pkg.delete_row(r_req_line_dtl_rec.req_line_detail_id);
                        end loop;


                        log('move_parts_on_reassign', 'before inserting a new req_line_detail...');
                        l_req_line_detail_id := null;
                        csp_req_line_details_pkg.Insert_Row(
                          px_REQ_LINE_DETAIL_ID => l_req_line_detail_id,
                          p_REQUIREMENT_LINE_ID => old_res_record.requirement_line_id,
                          p_CREATED_BY => FND_GLOBAL.user_id,
                          p_CREATION_DATE => sysdate,
                          p_LAST_UPDATED_BY => FND_GLOBAL.user_id,
                          p_LAST_UPDATE_DATE => sysdate,
                          p_LAST_UPDATE_LOGIN => FND_GLOBAL.user_id,
                          p_SOURCE_TYPE => 'RES',
                          p_SOURCE_ID => l_new_reservation_id);


                        l_requirement_header.requirement_header_id := old_res_record.requirement_header_id;
                        l_requirement_header.need_by_date := p_new_need_by_date;
                        l_requirement_header.task_assignment_id := p_new_task_asgn_id ;
                        l_requirement_header.last_update_date := sysdate;
                        l_requirement_header.destination_organization_id := l_new_dest_org;
                        l_requirement_header.destination_subinventory := l_new_dest_subinv;
                        l_requirement_header.resource_type := p_new_resource_type;
                        l_requirement_header.resource_id := p_new_resource_id;

                        log('move_parts_on_reassign','task_assignment_id:'||l_requirement_header.task_assignment_id);
                        log('move_parts_on_reassign','dest_organization_id:'||l_requirement_header.destination_organization_id);
                        log('move_parts_on_reassign','dest_subinventory:'||l_requirement_header.destination_subinventory);
                        log('move_parts_on_reassign','resource_type:'||l_requirement_header.resource_type);
                        log('move_parts_on_reassign','resource_id:'||l_requirement_header.resource_id);
                        log('move_parts_on_reassign','start_time:'||to_char(l_requirement_header.need_by_date,'dd-mon-yyyy hh24:mi:ss'));

                        log('move_parts_on_reassign', 'before calling Update_requirement_headers...');
                        CSP_Requirement_Headers_PVT.Update_requirement_headers(
                                                        P_Api_Version_Number         => 1.0,
                                                        P_Init_Msg_List              => FND_API.G_FALSE,
                                                        P_Commit                     => FND_API.G_FALSE,
                                                        p_validation_level           => FND_API.G_VALID_LEVEL_FULL,
                                                        P_REQUIREMENT_HEADER_Rec     => l_requirement_header,
                                                        X_Return_Status              => x_return_status,
                                                        X_Msg_Count                  => x_msg_count,
                                                        x_msg_data                   => x_msg_data
                                                        );
                        log('move_parts_on_reassign', 'before calling Update_requirement_headers...x_return_status=' || x_return_status);

                        if x_return_status <> FND_API.G_RET_STS_SUCCESS then
                                x_return_status := FND_API.G_RET_STS_ERROR;
                                FND_MESSAGE.SET_NAME('CSP', 'CSP_SCH_NOT_CANCEL_ORDER');
                                FND_MSG_PUB.ADD;
                                fnd_msg_pub.count_and_get
                                                ( p_count => x_msg_count
                                                , p_data  => x_msg_data);
                                return;
                        end if;

                end loop;

                log('move_parts_on_reassign', 'returning...');
        end move_parts_on_reassign;
 END CSP_SCH_INT_PVT;

/
