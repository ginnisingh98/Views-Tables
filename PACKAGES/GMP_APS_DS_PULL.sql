--------------------------------------------------------
--  DDL for Package GMP_APS_DS_PULL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMP_APS_DS_PULL" AUTHID CURRENT_USER AS
/* $Header: GMPPLDSS.pls 120.2.12010000.3 2009/07/01 09:56:40 vpedarla ship $ */

/*  Global value variables */
  v_sql_stmt     		VARCHAR2(4000) := NULL;
  v_item_sql_stmt		VARCHAR2(4000) := NULL;
  v_sales_sql_stmt		VARCHAR2(4000) := NULL;
  v_forecast_sql_stmt		VARCHAR2(4000) := NULL;
  v_association_sql_stmt	VARCHAR2(4000) := NULL;
  v_null_date     DATE := TO_DATE('01/01/1970','DD/MM/YYYY');

/* Variables for document types */
  v_doc_prod      VARCHAR2(4) := 'PROD';
  v_doc_fpo       VARCHAR2(4) := 'FPO';
  v_doc_opso      VARCHAR2(4) := 'OPSO';
  v_cp_enabled   BOOLEAN := FALSE;

/* Procedure to extract production order to the for demands and supplies */
PROCEDURE production_orders(
  pdblink        IN  VARCHAR2,
  pinstance_id   IN  NUMBER,
  prun_date      IN  DATE,
  pdelimiter     IN  VARCHAR2,
  return_status  IN OUT NOCOPY BOOLEAN);

/* Universal routine to write to msc_st_supplies table */
PROCEDURE insert_supplies(
  pitem_id          PLS_INTEGER,
  porganization_id  PLS_INTEGER,
  pinstance_id      PLS_INTEGER,
  pdate             DATE,
  pstart_date       DATE,
  pend_date         DATE,
  pbatch_id         PLS_INTEGER,
  pqty              NUMBER,
  pfirmed_ind       NUMBER,
  pbatchstep_no     NUMBER,   /* B2919303 */
  porder_no         VARCHAR2,
  plot_number       VARCHAR2,
  pexpire_date      DATE,
  psupply_type      NUMBER,
  pproduct_item_id  PLS_INTEGER);  /* B2953953 - CoProduct changes */

/* Universal routine to  write to msc_st_demands table */
PROCEDURE insert_demands(
  pitem_id          PLS_INTEGER,
  porganization_id  PLS_INTEGER,
  pinstance_id      PLS_INTEGER,
  pbatch_id         PLS_INTEGER,
  pproduct_item_id  PLS_INTEGER,
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
  porganization_id  PLS_INTEGER,
  pinstance_id      PLS_INTEGER,
  pseq_num          PLS_INTEGER,
  presource_id      PLS_INTEGER,
  pstart_date       DATE,
  pend_date         DATE,
  presource_usage   NUMBER,
  prsrc_cnt         NUMBER,
  pbatchstep_no     NUMBER,  /* B1224660 added new parameter */
  pbatch_id         PLS_INTEGER,
  pstep_status      NUMBER,
  pschedule_flag    NUMBER,
  pparent_seq_num   NUMBER,
  pmin_xfer_qty     NUMBER);

/* Procedure to extract onhand balances */
PROCEDURE extract_onhand_balances(
  pdblink        IN  VARCHAR2,
  pinstance_id   IN  PLS_INTEGER,
  prun_date      IN  DATE,
  pdelimiter     IN  VARCHAR2,
  return_status  IN OUT NOCOPY BOOLEAN);

/* Procedure to extract Inventory Transfers Demands B2756431 */
PROCEDURE extract_inv_transfer_demands(
  pdblink        IN  VARCHAR2,
  pinstance_id   IN  PLS_INTEGER,
  prun_date      IN  DATE,
  pdelimiter     IN  VARCHAR2,
  pwhse_code     IN  VARCHAR2,
  pdesignator    IN  VARCHAR2,
  return_status  IN OUT NOCOPY BOOLEAN);

/* Procedure to extract Inventory Transfers  Supplies B2756431 */
PROCEDURE extract_inv_transfer_supplies(
  pdblink        IN  VARCHAR2,
  pinstance_id   IN  PLS_INTEGER,
  prun_date      IN  DATE,
  pdelimiter     IN  VARCHAR2,
  return_status  IN OUT NOCOPY BOOLEAN);


PROCEDURE onhand_inventory(
  pdblink        IN  VARCHAR2,
  pinstance_id   IN  PLS_INTEGER,
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
PROCEDURE sales_forecast( pdblink        IN  VARCHAR2,
                          pinstance_id   IN  PLS_INTEGER,
                          prun_date      IN  DATE,
                          pdelimiter     IN  VARCHAR2,
                          return_status  IN OUT NOCOPY BOOLEAN,
                          api_mode       IN BOOLEAN DEFAULT FALSE);

PROCEDURE write_this_so(pcounter    IN NUMBER,
                        sapi_mode   IN BOOLEAN DEFAULT FALSE) ;

PROCEDURE write_this_fcst(pcounter    IN  NUMBER,
                          fapi_mode   IN BOOLEAN DEFAULT FALSE) ;

FUNCTION associate_forecasts (  pschd_fcst_cnt  IN NUMBER,
                                pschd_id        IN PLS_INTEGER ) return BOOLEAN ;

FUNCTION check_so( pso_counter          IN  NUMBER,
                   pinventory_item_id   IN  PLS_INTEGER,
                   porganization_id     IN  PLS_INTEGER) return BOOLEAN ;

FUNCTION check_forecast(pfcst_counter           IN  NUMBER,
                        pinventory_item_id      IN  PLS_INTEGER,
                        porganization_id        IN  PLS_INTEGER) return BOOLEAN ;

PROCEDURE consume_forecast( pinventory_item_id  IN  PLS_INTEGER,
                            porganization_id    IN  PLS_INTEGER,
                            papi_mode           IN BOOLEAN DEFAULT FALSE) ;

PROCEDURE write_forecast( pfcst_counter         IN  NUMBER,
                          pinventory_item_id    IN  PLS_INTEGER,
                          porganization_id      IN  PLS_INTEGER,
                          papi_mode             IN BOOLEAN DEFAULT FALSE) ;

PROCEDURE write_so( pso_counter         IN  NUMBER,
                    pinventory_item_id  IN  PLS_INTEGER,
                    porganization_id    IN  PLS_INTEGER,
                    papi_mode           IN BOOLEAN DEFAULT FALSE) ;

PROCEDURE time_stamp ;

PROCEDURE insert_designator ;

PROCEDURE process_resource_rows(
  pfirst_row    IN  NUMBER,
  plast_row     IN  NUMBER,
  pfound_mtl    IN  NUMBER,
  porgn_id      IN  PLS_INTEGER,
  pinstance_id  IN  PLS_INTEGER,
  pinflate_wip  IN  NUMBER,
  pmin_xfer_qty IN  NUMBER);

PROCEDURE LOG_MESSAGE(pBUFF  IN  VARCHAR2) ;
PROCEDURE extract_forecasts( pdblink        IN  VARCHAR2,
                          pinstance_id   IN  PLS_INTEGER,
                          prun_date      IN  DATE,
                          pdelimiter     IN  VARCHAR2,
                          return_status  IN OUT NOCOPY BOOLEAN);

/*Sowmya - As Per latest FDD changes - Start*/
PROCEDURE production_reservations ( pdblink        IN  VARCHAR2,
                          pinstance_id   IN  PLS_INTEGER,
                          prun_date      IN  DATE,
                          pdelimiter     IN  VARCHAR2,
                          return_status  IN OUT NOCOPY BOOLEAN);
/*Sowmya - As Per latest FDD changes - End*/

/*Sowmya */
PROCEDURE update_last_setup_id (
                                effbuf   OUT NOCOPY VARCHAR2,
                                retcode      OUT NOCOPY NUMBER,
                                f_orgn_code    IN  NUMBER,
                                t_orgn_code    IN  NUMBER
                                );
/*Sowmya */

PROCEDURE gmp_debug_message(pBUFF IN VARCHAR2);  -- Bug: 8420747 Vpedarla

END gmp_aps_ds_pull;

/
