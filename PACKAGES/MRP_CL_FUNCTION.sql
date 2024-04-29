--------------------------------------------------------
--  DDL for Package MRP_CL_FUNCTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_CL_FUNCTION" AUTHID CURRENT_USER AS -- specification
/* $Header: MRPCLHAS.pls 120.4 2007/12/06 12:16:40 sbyerram ship $ */


  ----- CONSTANTS --------------------------------------------------------

   SYS_YES                      CONSTANT NUMBER := 1;
   SYS_NO                       CONSTANT NUMBER := 2;

   G_SUCCESS                    CONSTANT NUMBER := 0;
   G_WARNING                    CONSTANT NUMBER := 1;
   G_ERROR                      CONSTANT NUMBER := 2;

 ----- PARAMETERS --------------------------------------------------------
   v_yield_uom_class         varchar2(10):= FND_PROFILE.value('FM_YIELD_TYPE');
   v_debug                     BOOLEAN := FALSE;

   v_price_list_id  number :=  FND_PROFILE.value('MRP_BIS_PRICE_LIST');
   v_cp_enabled                NUMBER;


   v_lrn                       NUMBER;
   v_request_id                NUMBER;
   v_cmro_customer_id          NUMBER;


   --  ================= Functions ====================

   PROCEDURE APPS_INITIALIZE(
                       p_user_name        IN  VARCHAR2,
                       p_resp_name        IN  VARCHAR2,
                       p_application_name IN  VARCHAR2 );

   FUNCTION Default_ABC_Assignment_Group ( p_org_id NUMBER)
     RETURN NUMBER;

FUNCTION mrp_item_cost(p_item_id in number,
                       p_org_id  in number,
                       p_primary_cost_method in number)
     RETURN NUMBER;

FUNCTION mrp_resource_cost(p_item_id in number,
                           p_org_id  in number,
                           p_primary_cost_method in number)
     RETURN NUMBER;

FUNCTION mrp_item_list_price(arg_item_id in number,
			     arg_org_id  in number,
                             arg_uom_code in varchar2,
			     arg_process_flag in varchar2,
			     arg_primary_cost_method in number)
     RETURN NUMBER;

FUNCTION mrp_item_supp_price(p_item_id in number,
                             p_asl_id in number)
     RETURN NUMBER;

/*over-loaded the funcs so that the old ver of view mrp_ap_wip_jobs_v does
  not get invalid during patch application */
FUNCTION mrp_rev_cum_yield(p_wip_entity_id in number,
                             p_org_id in number)
     RETURN NUMBER;

FUNCTION mrp_rev_cum_yield_unreleased(p_wip_entity_id in number,
                             p_org_id in number)
     RETURN NUMBER;

FUNCTION mrp_rev_cum_yield(p_wip_entity_id in number,
                           p_org_id in number,
                           p_bill_seq_id   in number,
                           p_co_prod_supply in number)
     RETURN NUMBER;

FUNCTION mrp_day_uom_qty(p_uom_code in varchar2,
                         p_quantity in number)
     RETURN NUMBER;

FUNCTION mrp_rev_cum_yield_unreleased(p_wip_entity_id in number,
                             p_org_id in number,
                             p_bill_seq_id   in number,
                             p_co_prod_supply in number)
     RETURN NUMBER;

FUNCTION mrp_jd_rev_cum_yield(p_wip_entity_id in number,
                             p_org_id in number,
                             p_bill_seq_id   in number,
                             p_co_prod_supply in number)
     RETURN NUMBER;
FUNCTION get_primary_quantity(p_org_id in number,
                             p_item_id in number,
                             p_primary_uom_code in varchar2)
     RETURN NUMBER;

FUNCTION GET_RESOURCE_OVERHEAD(res_id IN NUMBER, dept_id IN NUMBER,
                              org_id IN NUMBER, res_cost IN NUMBER)
RETURN NUMBER;

FUNCTION GET_CURRENT_OP_SEQ_NUM(p_org_id IN NUMBER,
                                p_wip_entity_id IN NUMBER)
RETURN NUMBER;

FUNCTION GET_CURRENT_JD_OP_SEQ_NUM( p_org_id IN NUMBER
                               , p_wip_entity_id IN NUMBER)
RETURN NUMBER;

FUNCTION GET_CURRENT_JOB_OP_SEQ_NUM( p_org_id IN NUMBER
                               , p_wip_entity_id IN NUMBER)
RETURN NUMBER;

FUNCTION GET_CURRENT_RTNG_OP_SEQ_NUM( p_org_id IN NUMBER
                               , p_wip_entity_id IN NUMBER)
RETURN NUMBER;

FUNCTION GETWFUSER(ORIG_SYS_ID in varchar2)
RETURN VARCHAR2;

FUNCTION  GET_ROUTING_SEQ_ID ( p_primary_item_id    IN NUMBER,
                               p_org_id             IN NUMBER,
                               p_alt_ROUTING_DESIG  IN VARCHAR2,
                               p_common_rout_seq_id IN NUMBER
                              )
RETURN NUMBER;

FUNCTION GET_PO_ORIG_NEED_BY_DATE ( p_po_header_id IN NUMBER,
								    p_po_line_id   IN NUMBER,
								    p_po_line_location_id IN NUMBER
                                  )
RETURN DATE;

FUNCTION GET_PO_ORIG_QUANTITY ( p_po_header_id IN NUMBER,
								p_po_line_id   IN NUMBER,
								p_po_line_location_id IN NUMBER
                              )
RETURN NUMBER;

FUNCTION get_userenv_lang RETURN  varchar2;

FUNCTION  GET_COST_TYPE_ID (   p_org_id             IN NUMBER )
RETURN NUMBER;

--PRAGMA RESTRICT_REFERENCES (Default_ABC_Assignment_Group,WNDS,WNPS,RNPS);
--PRAGMA RESTRICT_REFERENCES (mrp_item_cost,WNDS,WNPS,RNPS);
--PRAGMA RESTRICT_REFERENCES (mrp_resource_cost,WNDS,WNPS,RNPS);
--PRAGMA RESTRICT_REFERENCES (mrp_item_list_price,WNDS,WNPS,RNPS);

FUNCTION MAP_REGION_TO_SITE(p_last_update_date in DATE) RETURN NUMBER;

FUNCTION get_ship_set_name(p_SHIP_SET_ID in number)
RETURN VARCHAR2;

FUNCTION get_arrival_set_name(p_ARRIVAL_SET_ID in number)
RETURN VARCHAR2;


/* New Entities to Get the Customer, Bill To and Ship To site */
FUNCTION GET_CMRO_CUSTOMER_ID return NUMBER;
FUNCTION GET_CMRO_BILL_TO return NUMBER;
FUNCTION GET_CMRO_SHIP_TO return NUMBER;

FUNCTION CHECK_BOM_VER return NUMBER;

FUNCTION CHECK_AHL_VER return NUMBER;

   /* -- Added this procedure to accept application_id instead of application_name */
   PROCEDURE APPS_INITIALIZE(
                       p_user_name        IN  VARCHAR2,
                       p_resp_name        IN  VARCHAR2,
                       p_application_name IN  VARCHAR2,
                       p_application_id   IN  NUMBER );

 Procedure SUBMIT_CR
                   ( p_user_name        IN  VARCHAR2,
                     p_resp_name        IN  VARCHAR2,
                     p_application_name IN  VARCHAR2,
                     p_application_id   IN  NUMBER,
                     p_batch_id         IN  NUMBER,
                     p_conc_req_short_name IN varchar2 ,
                     p_conc_req_desc IN  varchar2 ,
                     p_owning_applshort_name IN varchar2,
                     p_load_type IN NUMBER,
                     p_request_id  IN OUT NOCOPY Number) ;


FUNCTION CHECK_WSH_VER return NUMBER;

FUNCTION validateUser (pUSERID    IN    NUMBER,
                       pTASK      IN    NUMBER,
                       pMESSAGE   IN OUT NOCOPY   varchar2)
                       return BOOLEAN;

PROCEDURE msc_Initialize(pTASK          IN  NUMBER,
                         pUSERID        IN  NUMBER,
                         pRESPID        IN  NUMBER DEFAULT -1,
                         pAPPLID        IN  NUMBER DEFAULT -1) ;


END MRP_CL_FUNCTION;

/
