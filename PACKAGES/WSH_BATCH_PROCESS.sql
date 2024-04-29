--------------------------------------------------------
--  DDL for Package WSH_BATCH_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_BATCH_PROCESS" AUTHID CURRENT_USER as
/* $Header: WSHBHPSS.pls 120.1.12010000.2 2009/12/03 13:59:52 anvarshn ship $ */

TYPE Brief_Del_Info_Rec IS RECORD (
  delivery_id      NUMBER,
  organization_id  NUMBER,
  initial_pickup_location_id NUMBER);


TYPE Del_Info_Tab IS TABLE OF Brief_Del_Info_Rec INDEX BY BINARY_INTEGER;



TYPE Results_Summary_Rec IS RECORD (
 success         NUMBER,
 warning         NUMBER,
 failure         NUMBER,
 report_req_id   NUMBER);

TYPE Select_Criteria_Rec IS RECORD (
    process_mode            VARCHAR2(30),
    organization_id         NUMBER  ,
    pr_batch_id             NUMBER  ,
    ap_batch_id             NUMBER  ,
    client_id               NUMBER  , -- Modified R12.1.1 LSP PROJECT
    delivery_name_lo        VARCHAR2(30),
    delivery_name_hi        VARCHAR2(30),
    bol_number_lo           VARCHAR2(50),
    bol_number_hi           VARCHAR2(50),
    planned_flag            VARCHAR2(1),
    ship_from_loc_id        NUMBER  ,
    ship_to_loc_id          NUMBER  ,
    intmed_ship_to_loc_id   NUMBER  ,
    pooled_ship_to_loc_id   NUMBER  ,
    customer_id             NUMBER  ,
    ship_method_code        VARCHAR2(30),
    fob_code                VARCHAR2(30),
    freight_terms_code      VARCHAR2(30),
    pickup_date_lo          VARCHAR2(30),
    pickup_date_hi          VARCHAR2(30),
    dropoff_date_lo         VARCHAR2(30),
    dropoff_date_hi         VARCHAR2(30),
    log_level               NUMBER ,
    delivery_lines_status   VARCHAR2(30),
    scheduled_ship_date_lo  VARCHAR2(30),
    scheduled_ship_date_hi  VARCHAR2(30),
    source_code             VARCHAR2(30));

CURSOR G_GET_SHIP_CONFIRM_RULE (c_ship_confirm_rule_id NUMBER ) IS
  SELECT SHIP_CONFIRM_RULE_ID,
     NAME,
     ACTION_FLAG,
     STAGE_DEL_FLAG,
     SHIP_METHOD_CODE,
     NVL(SHIP_METHOD_DEFAULT_FLAG, 'R') SHIP_METHOD_DEFAULT_FLAG,
     AC_ACTUAL_DEP_DATE_DEFAULT,
     AC_INTRANSIT_FLAG,
     AC_CLOSE_TRIP_FLAG,
     AC_BOL_FLAG,
     AC_DEFER_INTERFACE_FLAG,
     MC_INTRANSIT_FLAG,
     MC_CLOSE_TRIP_FLAG,
     MC_BOL_FLAG,
     MC_DEFER_INTERFACE_FLAG,
     REPORT_SET_ID,
     SEND_945_FLAG
  FROM   WSH_SHIP_CONFIRM_RULES
  WHERE  SHIP_CONFIRM_RULE_ID = c_ship_confirm_rule_id AND
     NVL(EFFECTIVE_START_DATE, sysdate) <= sysdate AND
     NVL(EFFECTIVE_END_DATE, sysdate ) >= sysdate ;

PROCEDURE Auto_Pack_A_Delivery(
  p_delivery_id         IN   NUMBER,
  p_ap_batch_id         IN   NUMBER,
  p_auto_pack_level     IN   NUMBER,
  p_log_level           IN   NUMBER,
  x_return_status       OUT  NOCOPY VARCHAR2);

PROCEDURE Ship_Confirm_A_Delivery(
  p_delivery_id            IN   NUMBER,
  p_sc_batch_id            IN   NUMBER,
  p_ship_confirm_rule_rec  IN   G_GET_SHIP_CONFIRM_RULE%ROWTYPE,
  p_log_level              IN   NUMBER,
  p_actual_departure_date  IN   DATE,
  x_return_status     OUT  NOCOPY VARCHAR2);

PROCEDURE Close_A_Stop (
           p_stop_id    IN NUMBER,
           p_actual_date  IN DATE,
           p_defer_interface_flag IN VARCHAR2,
           x_return_status OUT NOCOPY VARCHAR2);

PROCEDURE Select_Deliveries (
    p_input_info              IN  WSH_BATCH_PROCESS.Select_Criteria_Rec,
    p_batch_rec               IN OUT NOCOPY WSH_PICKING_BATCHES%ROWTYPE,
    x_selected_del_tab    OUT NOCOPY  WSH_BATCH_PROCESS.Del_Info_Tab,
    x_return_status           OUT NOCOPY VARCHAR2 );

PROCEDURE Ship_Confirm_Batch(
    p_del_tab                  IN   WSH_BATCH_PROCESS.Del_Info_Tab,
    p_sc_batch_id              IN   NUMBER,
    p_log_level                IN   NUMBER,
    x_confirmed_del_tab        OUT  NOCOPY WSH_UTIL_CORE.Id_Tab_Type,
    x_results_summary          OUT  NOCOPY WSH_BATCH_PROCESS.Results_Summary_Rec,
    x_return_status            OUT  NOCOPY VARCHAR2,
    p_commit                   IN   VARCHAR2);   -- BugFix #4001135

PROCEDURE Auto_Pack_Deliveries_Batch(
    p_del_tab                  IN   WSH_BATCH_PROCESS.Del_Info_Tab,
    p_ap_batch_id              IN   NUMBER,
    p_auto_pack_level          IN   NUMBER,
    p_log_level                IN   NUMBER,
    x_packed_del_tab           OUT  NOCOPY WSH_BATCH_PROCESS.Del_Info_Tab,
    x_results_summary          OUT  NOCOPY WSH_BATCH_PROCESS.Results_Summary_Rec,
    x_return_status            OUT  NOCOPY VARCHAR2,
    p_commit                   IN   VARCHAR2);   -- BugFix #4001135

PROCEDURE Confirm_Delivery_SRS(
     errbuf                    OUT NOCOPY VARCHAR2,
     retcode                   OUT NOCOPY VARCHAR2,
     p_ship_confirm_rule_id    IN NUMBER,
     p_actual_departure_date   IN VARCHAR2,
     p_sc_batch_prefix         IN VARCHAR2,
     p_deploy_mode             IN VARCHAR2,  -- Modified R12.1.1 LSP PROJECT (rminocha)
     p_client_id               IN NUMBER, -- Modified R12.1.1 LSP PROJECT (rminocha)
     p_organization_id         IN NUMBER,
     p_pr_batch_id             IN NUMBER,
     p_ap_batch_id             IN NUMBER,
     p_delivery_name_lo        IN VARCHAR2,
     p_delivery_name_hi        IN VARCHAR2,
     p_bol_number_lo           IN VARCHAR2,
     p_bol_number_hi           IN VARCHAR2,
     p_planned_flag            IN VARCHAR2,
     p_ship_from_loc_id        IN NUMBER,
     p_ship_to_loc_id          IN NUMBER,
     p_intmed_ship_to_loc_id   IN NUMBER,
     p_pooled_ship_to_loc_id   IN NUMBER,
     p_customer_id             IN NUMBER,
     p_ship_method_code        IN VARCHAR2,
     p_fob_code                IN VARCHAR2,
     p_freight_terms_code      IN VARCHAR2,
     p_pickup_date_lo          IN VARCHAR2,
     p_pickup_date_hi          IN VARCHAR2,
     p_dropoff_date_lo         IN VARCHAR2,
     p_dropoff_date_hi         IN VARCHAR2,
     p_log_level               IN NUMBER);



PROCEDURE Auto_Pack_Deliveries_SRS(
    errbuf                    OUT NOCOPY VARCHAR2,
    retcode                   OUT NOCOPY VARCHAR2,
    p_auto_pack_level         IN  NUMBER,
    p_ap_batch_prefix         IN VARCHAR2,
    p_organization_id         IN NUMBER,
    p_pr_batch_id             IN NUMBER,
    p_delivery_name_lo        IN VARCHAR2,
    p_delivery_name_hi        IN VARCHAR2,
    p_bol_number_lo           IN VARCHAR2,
    p_bol_number_hi           IN VARCHAR2,
    p_planned_flag            IN VARCHAR2,
    p_ship_from_loc_id        IN NUMBER,
    p_ship_to_loc_id          IN NUMBER,
    p_intmed_ship_to_loc_id   IN NUMBER,
    p_pooled_ship_to_loc_id   IN NUMBER,
    p_customer_id             IN NUMBER,
    p_ship_method_code        IN VARCHAR2,
    p_fob_code                IN VARCHAR2,
    p_freight_terms_code      IN VARCHAR2,
    p_pickup_date_lo          IN VARCHAR2,
    p_pickup_date_hi          IN VARCHAR2,
    p_dropoff_date_lo         IN VARCHAR2,
    p_dropoff_date_hi         IN VARCHAR2,
    p_log_level               IN NUMBER );

Procedure log_batch_messages(p_batch_id    IN NUMBER,
                             p_delivery_id IN NUMBER,
                             p_stop_id     IN NUMBER,
                             p_exception_location_id IN NUMBER,
                             p_error_status IN VARCHAR2);


PROCEDURE Process_Deliveries_SRS(
  errbuf                    OUT NOCOPY VARCHAR2,
  retcode                   OUT NOCOPY VARCHAR2,
  p_entity_type             IN VARCHAR2,
  p_delivery_lines_status   IN VARCHAR2,
  p_deliveries_status       IN VARCHAR2,
  p_scheduled_ship_date_lo  IN VARCHAR2,
  p_scheduled_ship_date_hi  IN VARCHAR2,
  p_source_system           IN VARCHAR2,
  p_pickup_date_lo          IN VARCHAR2,
  p_pickup_date_hi          IN VARCHAR2,
  p_dropoff_date_lo         IN VARCHAR2,
  p_dropoff_date_hi         IN VARCHAR2,
  p_deploy_mode             IN VARCHAR2,  -- Modified R12.1.1 LSP PROJECT
  p_client_id               IN NUMBER, --Modified R12.1.1 LSP PROJECT
  p_organization_id         IN NUMBER,
  p_customer_id             IN VARCHAR2,
  p_ship_to_loc_id          IN NUMBER,
  p_ship_method_code        IN VARCHAR2,
  p_autocreate_deliveries   IN VARCHAR2,
  p_ac_del_criteria         IN VARCHAR2,
  p_append_deliveries       IN VARCHAR2,
  p_grp_ship_method         IN VARCHAR2,
  p_grp_ship_from           IN VARCHAR2,
  p_max_del_number          IN NUMBER,
  p_log_level               IN NUMBER );

END WSH_BATCH_PROCESS;

/
