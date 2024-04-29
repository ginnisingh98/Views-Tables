--------------------------------------------------------
--  DDL for Package MSC_CL_GMP_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_CL_GMP_UTILITY" AUTHID CURRENT_USER AS -- specification
/* $Header: MSCCLGMS.pls 120.0.12010000.3 2008/08/18 07:05:48 sbyerram ship $ */



/*  Global value variables */
  v_sql_stmt     	   VARCHAR2(32000) := NULL;
  v_item_sql_stmt	   VARCHAR2(32000) := NULL;
  v_sales_sql_stmt	   VARCHAR2(32000) := NULL;
  v_forecast_sql_stmt	   VARCHAR2(32000) := NULL;
  v_association_sql_stmt   VARCHAR2(32000) := NULL;
  v_null_date              DATE := TO_DATE('01/01/1970','DD/MM/YYYY');
  null_value               VARCHAR2(2)      := NULL;
  V_YES                    NUMBER  := 1;
  V_WPS                    CONSTANT VARCHAR2(4) := 'WPS';
  V_APS                    CONSTANT VARCHAR2(4) := 'APS';
  V_BASED                  CONSTANT VARCHAR2(5) := 'BASED';
  no_of_secs               CONSTANT REAL := 86400;

/* Variables for document types */
  v_doc_prod               VARCHAR2(4) := 'PROD';
  v_doc_fpo                VARCHAR2(4) := 'FPO';
  v_doc_opso               VARCHAR2(4) := 'OPSO';
  v_cp_enabled             BOOLEAN := FALSE;

  g_in_str_org             VARCHAR2(4000) := NULL;
  G_ALL_ORG                CONSTANT VARCHAR2(10000) := '-999' ;

  PROCEDURE extract_effectivities
            (
			  at_apps_link   IN VARCHAR2,
			  delimiter_char IN VARCHAR2,
			  instance       IN INTEGER,
			  run_date       IN DATE,
                          return_status  IN OUT NOCOPY BOOLEAN
            );
  PROCEDURE extract_items
            (
			  at_apps_link  IN VARCHAR2,
			  instance      IN INTEGER,
			  run_date      IN DATE,
                          return_status IN OUT NOCOPY BOOLEAN
            );
  PROCEDURE extract_sub_inventory
			(
			  at_apps_link  IN VARCHAR2,
			  instance      IN INTEGER,
			  run_date      IN DATE,
			  return_status IN OUT NOCOPY BOOLEAN
			);

  PROCEDURE time_stamp ;

  FUNCTION check_formula (pplant_code IN VARCHAR2,
                           porganization_id IN NUMBER,
                           pformula_id IN NUMBER) return BOOLEAN ;

  FUNCTION check_formula_for_organization (
                           pplant_code IN VARCHAR2,
                           porganization_id IN NUMBER,
                           pformula_id IN NUMBER) return BOOLEAN ;

  PROCEDURE validate_formula_for_orgn ;

  PROCEDURE validate_formula ;

  PROCEDURE invalidate_rtg_all_org (p_routing_id IN NUMBER) ;

  PROCEDURE validate_routing (prouting_id IN NUMBER ,
                             porgn_code   IN VARCHAR2,
                             pheader_loc  IN  NUMBER,
                             prout_valid  OUT NOCOPY BOOLEAN) ;

  PROCEDURE link_routing ;

  PROCEDURE link_override_routing ;

  PROCEDURE export_effectivities
  (
    return_status            OUT NOCOPY BOOLEAN
  ) ;

  FUNCTION bsearch_routing (p_routing_id IN NUMBER ,
                            p_plant_code IN VARCHAR2)
                          RETURN INTEGER ;

  /* Added New Function for Sequence Dependencies - SGIDUGU  */
  FUNCTION bsearch_setupid (p_oprn_id      IN NUMBER ,
                            p_category_id  IN NUMBER)
                          RETURN INTEGER ;

  PROCEDURE write_process_effectivity
  (
    p_x_aps_fmeff_id   IN NUMBER,
    p_aps_fmeff_id     IN NUMBER,
    return_status      OUT NOCOPY BOOLEAN
  ) ;

  PROCEDURE write_bom_components
  (
    p_x_aps_fmeff_id   IN NUMBER,
    return_status      OUT NOCOPY BOOLEAN
  ) ;

  PROCEDURE write_routing
  (
    p_x_aps_fmeff_id   IN NUMBER,
    return_status      OUT NOCOPY BOOLEAN
  ) ;

  PROCEDURE write_routing_operations
  (
    p_x_aps_fmeff_id   IN NUMBER,
    return_status      OUT NOCOPY BOOLEAN
  ) ;

  PROCEDURE retrieve_effectivities
  (
    return_status  OUT NOCOPY BOOLEAN
  ) ;

  PROCEDURE write_operation_components
  (
    p_x_aps_fmeff_id   IN NUMBER,
    precipe_id         IN NUMBER,
    return_status      OUT NOCOPY BOOLEAN
  ) ;

  PROCEDURE setup
  (
    apps_link_name IN VARCHAR2,
    delimiter_char IN VARCHAR2,
    instance       IN INTEGER,
    run_date       IN DATE,
    return_status  OUT NOCOPY BOOLEAN
  ) ;

   PROCEDURE gmp_putline (
       v_text                    IN       VARCHAR2,
       v_mode                    IN       VARCHAR2 ) ;

   FUNCTION find_routing_header ( prouting_id   IN NUMBER,
                                  pplant_code   IN VARCHAR2)
                                  RETURN BOOLEAN ;
   FUNCTION find_routing_offsets (p_formula_id  IN NUMBER,
                               p_plant_code     IN VARCHAR2)
                               RETURN NUMBER ;
   FUNCTION get_offsets( p_formula_id           IN NUMBER,
                        p_plant_code            IN VARCHAR2,
                        p_formulaline_id        IN NUMBER )
                        RETURN NUMBER ;

   PROCEDURE msc_inserts
   (
     return_status  OUT NOCOPY BOOLEAN
   ) ;

  /* Added new procedure to write the Resource Setups and Transitions - SGIDUGU  */

  PROCEDURE write_setups_and_transitions
  (
    return_status   OUT NOCOPY BOOLEAN
  ) ;

PROCEDURE write_step_dependency(
  p_x_aps_fmeff_id   IN NUMBER
);

FUNCTION enh_bsearch_stpno ( l_formula_id       IN NUMBER,
                             l_recipe_id        IN NUMBER,
                             l_item_id          IN NUMBER
                           ) RETURN INTEGER ;
PROCEDURE bsearch_unique (p_resource_id   IN NUMBER ,
                          p_category_id   IN NUMBER ,
                          p_setup_id      OUT NOCOPY NUMBER
                         ) ;

-- for future use
FUNCTION GMP_BOM_UTILITY1_R10
            (
                          p_dblink      IN VARCHAR2,
                          p_delimiter   IN VARCHAR2,
                          p_instance    IN INTEGER,
                          p_run_date    IN DATE,
                          p_num1        IN NUMBER,
                          p_num2        IN NUMBER,
                          p_num3        IN NUMBER,
                          p_num4        IN NUMBER,
                          p_varchar1    IN VARCHAR2,
                          p_varchar2    IN VARCHAR2,
                          p_varchar3    IN VARCHAR2,
                          p_varchar4    IN VARCHAR2
            ) RETURN INTEGER ;

FUNCTION GMP_BOM_UTILITY2_R10
            (
                          p_dblink      IN VARCHAR2,
                          p_delimiter   IN VARCHAR2,
                          p_instance    IN INTEGER,
                          p_run_date    IN DATE,
                          p_num1        IN NUMBER,
                          p_num2        IN NUMBER,
                          p_num3        IN NUMBER,
                          p_num4        IN NUMBER,
                          p_varchar1    IN VARCHAR2,
                          p_varchar2    IN VARCHAR2,
                          p_varchar3    IN VARCHAR2,
                          p_varchar4    IN VARCHAR2
            ) RETURN INTEGER ;

PROCEDURE GMP_BOM_PROC1_R10
            (
                          p_dblink      IN VARCHAR2,
                          p_delimiter   IN VARCHAR2,
                          p_instance    IN INTEGER,
                          p_run_date    IN DATE,
                          p_num1        IN NUMBER,
                          p_num2        IN NUMBER,
                          p_num3        IN NUMBER,
                          p_num4        IN NUMBER,
                          p_varchar1    IN VARCHAR2,
                          p_varchar2    IN VARCHAR2,
                          p_varchar3    IN VARCHAR2,
                          p_varchar4    IN VARCHAR2,
                          return_status  OUT NOCOPY BOOLEAN
            ) ;

PROCEDURE GMP_BOM_PROC2_R10
            (
                          p_dblink      IN VARCHAR2,
                          p_delimiter   IN VARCHAR2,
                          p_instance    IN INTEGER,
                          p_run_date    IN DATE,
                          p_num1        IN NUMBER,
                          p_num2        IN NUMBER,
                          p_num3        IN NUMBER,
                          p_num4        IN NUMBER,
                          p_varchar1    IN VARCHAR2,
                          p_varchar2    IN VARCHAR2,
                          p_varchar3    IN VARCHAR2,
                          p_varchar4    IN VARCHAR2,
                          return_status  OUT NOCOPY BOOLEAN
            ) ;

/*--------------------OPM PLD Specifications starts -------------------------*/

/* Procedure to extract production order to the for demands and supplies */
PROCEDURE production_orders(
  pdblink        IN  VARCHAR2,
  pinstance_id   IN  NUMBER,
  prun_date      IN  DATE,
  pdelimiter     IN  VARCHAR2,
  return_status  IN OUT NOCOPY BOOLEAN);

/* Universal routine to write to msc_st_supplies table */
PROCEDURE insert_supplies(
  pitem_id          NUMBER,
  porganization_id  NUMBER,
  pinstance_id      NUMBER,
  pdate             DATE,
  pstart_date       DATE,
  pend_date         DATE,
  pbatch_id         NUMBER,
  pqty              NUMBER,
  pfirmed_ind       NUMBER,
  pbatchstep_no     NUMBER,   /* B2919303 */
  porder_no         VARCHAR2,
  plot_number       VARCHAR2,
  pexpire_date      DATE,
  psupply_type      NUMBER,
  pproduct_item_id  NUMBER);  /* B2953953 - CoProduct changes */

/* Universal routine to  write to msc_st_demands table */
PROCEDURE insert_demands(
  pitem_id          NUMBER,
  porganization_id  NUMBER,
  pinstance_id      NUMBER,
  pbatch_id         NUMBER,
  pproduct_item_id  NUMBER,
  pdate             DATE,
  pqty              NUMBER,
  pbatchstep_no     NUMBER,   /* B2919303 */
  porder_no         VARCHAR2,
  pdesignator       VARCHAR2,
  pnet_price        NUMBER,   /* B1200400 */
  porigination_type NUMBER,
  api_mode          BOOLEAN DEFAULT FALSE,
  pschedule_id      NUMBER DEFAULT NULL);

/* routine to write to msc_st_resource_requirements */
PROCEDURE insert_resource_requirements(
  porganization_id  NUMBER,
  pinstance_id      NUMBER,
  pseq_num          NUMBER,
  presource_id      NUMBER,
  pstart_date       DATE,
  pend_date         DATE,
  presource_usage   NUMBER,
  prsrc_cnt         NUMBER,
  pbatchstep_no     NUMBER,  /* B1224660 added new parameter */
  pbatch_id         NUMBER,
  pstep_status      NUMBER,
  pschedule_flag    NUMBER,
  pparent_seq_num   NUMBER,
  pmin_xfer_qty     NUMBER);

/* Procedure to extract onhand balances */
PROCEDURE extract_onhand_balances(
  pdblink        IN  VARCHAR2,
  pinstance_id   IN  NUMBER,
  prun_date      IN  DATE,
  pdelimiter     IN  VARCHAR2,
  return_status  IN OUT NOCOPY BOOLEAN);

/* Procedure to extract Inventory Transfers Demands B2756431 */
PROCEDURE extract_inv_transfer_demands(
  pdblink        IN  VARCHAR2,
  pinstance_id   IN  NUMBER,
  prun_date      IN  DATE,
  pdelimiter     IN  VARCHAR2,
  pwhse_code     IN  VARCHAR2,
  pdesignator    IN  VARCHAR2,
  return_status  IN OUT NOCOPY BOOLEAN);

/* Procedure to extract Inventory Transfers  Supplies B2756431 */
PROCEDURE extract_inv_transfer_supplies(
  pdblink        IN  VARCHAR2,
  pinstance_id   IN  NUMBER,
  prun_date      IN  DATE,
  pdelimiter     IN  VARCHAR2,
  return_status  IN OUT NOCOPY BOOLEAN);


PROCEDURE onhand_inventory(
  pdblink        IN  VARCHAR2,
  pinstance_id   IN  NUMBER,
  prun_date      IN  DATE,
  pdelimiter     IN  VARCHAR2,
  return_status  IN OUT NOCOPY BOOLEAN);

/* Procedure to develop designator names */
PROCEDURE build_designator(
  poccur       IN  NUMBER,
  pdelimiter   IN  VARCHAR2,
  pdesignator  OUT NOCOPY VARCHAR2);

PROCEDURE sales_forecast_api(
  errbuf         OUT NOCOPY VARCHAR2,
  retcode        OUT NOCOPY VARCHAR2,
  p_cp_enabled   IN BOOLEAN DEFAULT TRUE,
  p_run_date     IN DATE DEFAULT SYSDATE);

/* Procedure to extract the sales and forecast demands */
PROCEDURE sales_forecast(
   pdblink        IN  VARCHAR2,
   pinstance_id   IN  NUMBER,
   prun_date      IN  DATE,
   pdelimiter     IN  VARCHAR2,
   return_status  IN OUT NOCOPY BOOLEAN,
   api_mode       IN BOOLEAN DEFAULT FALSE);

PROCEDURE write_this_so(
   pcounter    IN NUMBER,
   sapi_mode   IN BOOLEAN DEFAULT FALSE) ;

PROCEDURE write_this_fcst(
   pcounter    IN  NUMBER,
   fapi_mode   IN BOOLEAN DEFAULT FALSE) ;

FUNCTION associate_forecasts(
  pschd_fcst_cnt  IN NUMBER,
  pschd_id        IN NUMBER ) return BOOLEAN ;

FUNCTION check_so(
  pso_counter          IN  NUMBER,
  pinventory_item_id   IN  NUMBER,
  porganization_id     IN  NUMBER) return BOOLEAN ;

FUNCTION check_forecast(
  pfcst_counter           IN  NUMBER,
  pinventory_item_id      IN  NUMBER,
  porganization_id        IN  NUMBER) return BOOLEAN ;

PROCEDURE consume_forecast(
  pinventory_item_id  IN  NUMBER,
  porganization_id    IN  NUMBER,
  papi_mode           IN BOOLEAN DEFAULT FALSE) ;

PROCEDURE write_forecast(
  pfcst_counter         IN  NUMBER,
  pinventory_item_id    IN  NUMBER,
  porganization_id      IN  NUMBER,
  papi_mode             IN BOOLEAN DEFAULT FALSE) ;

PROCEDURE write_so(
  pso_counter         IN  NUMBER,
  pinventory_item_id  IN  NUMBER,
  porganization_id    IN  NUMBER,
  papi_mode           IN BOOLEAN DEFAULT FALSE) ;

PROCEDURE insert_designator ;

PROCEDURE process_resource_rows(
  pfirst_row    IN  NUMBER,
  plast_row     IN  NUMBER,
  pfound_mtl    IN  NUMBER,
  porgn_id      IN  NUMBER,
  pinstance_id  IN  NUMBER,
  pinflate_wip  IN  NUMBER,
  pmin_xfer_qty IN  NUMBER);

PROCEDURE extract_forecasts(
   pdblink      IN  VARCHAR2,
   pinstance_id   IN  NUMBER,
   prun_date      IN  DATE,
   pdelimiter     IN  VARCHAR2,
   return_status  IN OUT NOCOPY BOOLEAN);


/*Sowmya - As Per latest FDD changes - Start*/
PROCEDURE production_reservations (
   pdblink  IN  VARCHAR2,
   pinstance_id      IN  NUMBER,
   prun_date         IN  DATE,
   pdelimiter        IN  VARCHAR2,
   return_status     IN OUT NOCOPY BOOLEAN);
/*Sowmya - As Per latest FDD changes - End*/

/*Sowmya */
PROCEDURE update_last_setup_id (
   effbuf       OUT NOCOPY VARCHAR2,
   retcode      OUT NOCOPY NUMBER,
   f_orgn_code  IN  VARCHAR2,
   t_orgn_code  IN  VARCHAR2
   );
/*Sowmya */

FUNCTION GMP_APSDS_UTILITY1_R10
            (
                          p_dblink      IN VARCHAR2,
                          p_delimiter   IN VARCHAR2,
                          p_instance    IN INTEGER,
                          p_run_date    IN DATE,
                          p_num1        IN NUMBER,
                          p_num2        IN NUMBER,
                          p_num3        IN NUMBER,
                          p_num4        IN NUMBER,
                          p_varchar1    IN VARCHAR2,
                          p_varchar2    IN VARCHAR2,
                          p_varchar3    IN VARCHAR2,
                          p_varchar4    IN VARCHAR2
            ) RETURN INTEGER ;

PROCEDURE GMP_APSDS_PROC1_R10
            (
                          p_dblink      IN VARCHAR2,
                          p_delimiter   IN VARCHAR2,
                          p_instance    IN INTEGER,
                          p_run_date    IN DATE,
                          p_num1        IN NUMBER,
                          p_num2        IN NUMBER,
                          p_num3        IN NUMBER,
                          p_num4        IN NUMBER,
                          p_varchar1    IN VARCHAR2,
                          p_varchar2    IN VARCHAR2,
                          p_varchar3    IN VARCHAR2,
                          p_varchar4    IN VARCHAR2,
                          return_status  OUT NOCOPY BOOLEAN
            ) ;

PROCEDURE sales_order_allocation (
                          pdblink        IN  VARCHAR2,
                          pinstance_id   IN  NUMBER,
                          pentity        IN  NUMBER,
                          return_status  IN  OUT NOCOPY BOOLEAN);

/*--------------------OPM Calendar Specification Starts ---------------*/

PROCEDURE log_message(pBUFF  IN  VARCHAR2) ;

/* Procedure to Insert department resources  */
PROCEDURE rsrc_extract(p_instance_id IN NUMBER,
                       p_db_link     IN VARCHAR2,
                       return_status OUT NOCOPY BOOLEAN);

/* Bug# 1494939 - Initial changes for Resource Calendar */
PROCEDURE update_trading_partners(p_org_id      IN NUMBER,
                                  p_cal_code    IN VARCHAR2,
                                  return_status OUT NOCOPY BOOLEAN);

PROCEDURE get_cal_no( p_cal_id           IN  NUMBER,
                      p_cal_no           IN  VARCHAR2,
                      p_icode            IN  VARCHAR2,
                      p_out_cal          OUT NOCOPY VARCHAR2,
                      p_already_prefixed OUT NOCOPY VARCHAR2 );

PROCEDURE retrieve_calendar_detail( p_cal_id      IN NUMBER,
                                    p_calendar_no IN VARCHAR2,
                                    p_cal_desc    IN VARCHAR2,
                                    p_run_date    IN DATE,
                                    p_db_link     IN VARCHAR2,
                                    p_instance_id IN NUMBER,
                                    p_usage       IN VARCHAR2,
                                    return_status OUT NOCOPY BOOLEAN) ;

PROCEDURE insert_simulation_sets(p_org_id         IN NUMBER,
                                 p_instance_id    IN NUMBER,
                                 p_simulation_set IN VARCHAR2,
                                 return_status    OUT NOCOPY BOOLEAN);

PROCEDURE net_rsrc_insert(p_org_id         IN NUMBER,
                          p_orgn_code      IN VARCHAR2,
                          p_simulation_set IN VARCHAR2,
                          p_db_link        IN VARCHAR2,
                          p_instance_id    IN NUMBER,
                          p_run_date       IN DATE ,
                          p_calendar_id    IN NUMBER,
                          p_usage          IN VARCHAR2,
                          return_status    OUT NOCOPY BOOLEAN);

PROCEDURE populate_rsrc_cal(p_run_date    IN DATE,
                            p_instance_id IN NUMBER,
                            p_delimiter   IN VARCHAR2,
                            p_db_link     IN VARCHAR2,
                            p_nra_enabled IN NUMBER,
                            return_status OUT NOCOPY BOOLEAN);


PROCEDURE insert_gmp_resource_avail( errbuf        OUT NOCOPY VARCHAR2,
                                     retcode       OUT NOCOPY NUMBER  ,
                                     p_orgn_code   IN VARCHAR2 ,
                                     p_from_rsrc   IN VARCHAR2 ,
                                     p_to_rsrc     IN VARCHAR2 ,
                                     p_calendar_id IN NUMBER   ) ;

PROCEDURE net_rsrc_avail_calculate(
                          p_org_id       IN NUMBER,
                          p_orgn_code    IN VARCHAR2,
                          p_calendar_id  IN NUMBER,
                          p_instance_id  IN NUMBER,
                          p_db_link      IN VARCHAR2,
                          p_usage        IN VARCHAR2,   /* OPM-PS */
                          return_status  OUT NOCOPY BOOLEAN);

PROCEDURE net_rsrc_avail_insert(p_instance_id          IN NUMBER,
                                p_orgn_code            IN VARCHAR2,
                                p_resource_instance_id IN NUMBER,
                                p_calendar_id          IN NUMBER,
                                p_resource_id          IN NUMBER,
                                p_assigned_qty         IN NUMBER,
                                p_shift_num            IN NUMBER,
                                p_calendar_date        IN DATE,
                                p_from_time            IN NUMBER,
                                p_to_time              IN NUMBER ) ;

PROCEDURE net_rsrc(p_instance_id    IN NUMBER,
                   p_org_id         IN NUMBER,
                   p_simulation_set IN VARCHAR2,
                   p_resource_id    IN NUMBER,
                   p_assigned_qty   IN NUMBER,
                   p_shift_num      IN NUMBER,
                   p_calendar_date  IN DATE,
                   p_from_time      IN NUMBER,
                   p_to_time        IN NUMBER ) ;

FUNCTION ORG_STRING(instance_id IN NUMBER) return BOOLEAN ;

FUNCTION GMP_CAL_UTILITY1_R10
            (
                          p_dblink      IN VARCHAR2,
                          p_delimiter   IN VARCHAR2,
                          p_instance    IN INTEGER,
                          p_run_date    IN DATE,
                          p_num1        IN NUMBER,
                          p_num2        IN NUMBER,
                          p_num3        IN NUMBER,
                          p_num4        IN NUMBER,
                          p_varchar1    IN VARCHAR2,
                          p_varchar2    IN VARCHAR2,
                          p_varchar3    IN VARCHAR2,
                          p_varchar4    IN VARCHAR2
            ) RETURN INTEGER ;

PROCEDURE GMP_CAL_PROC1_R10
            (
                          p_dblink      IN VARCHAR2,
                          p_delimiter   IN VARCHAR2,
                          p_instance    IN INTEGER,
                          p_run_date    IN DATE,
                          p_num1        IN NUMBER,
                          p_num2        IN NUMBER,
                          p_num3        IN NUMBER,
                          p_num4        IN NUMBER,
                          p_varchar1    IN VARCHAR2,
                          p_varchar2    IN VARCHAR2,
                          p_varchar3    IN VARCHAR2,
                          p_varchar4    IN VARCHAR2,
                          return_status  OUT NOCOPY BOOLEAN
            ) ;

PROCEDURE rsrcal_based_availability(p_run_date IN date,
                                    p_instance_id IN number,
                                    p_db_link IN varchar2,
                                    return_status OUT NOCOPY BOOLEAN) ;


FUNCTION is_aps_compatible RETURN NUMBER;

END MSC_CL_GMP_UTILITY;

/
