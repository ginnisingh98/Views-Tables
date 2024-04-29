--------------------------------------------------------
--  DDL for Package CSD_HVR_BI_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_HVR_BI_PVT" AUTHID CURRENT_USER AS
/* $Header: csdvhbis.pls 120.0 2005/07/14 17:45:21 vkjain noship $ */

  -- Global Varaiables
  C_ERROR       CONSTANT VARCHAR2(1) := '2'; -- concurrent manager error code
  C_WARNING     CONSTANT VARCHAR2(1) := '1'; -- concurrent manager warning code
  C_OK          CONSTANT VARCHAR2(1) := '0'; -- concurrent manager success code

  C_CSD_REPAIR_ORDERS_F CONSTANT VARCHAR2(30) := 'CSD_REPAIR_ORDERS_F';
  C_CSD_MTL_CONSUMED_F CONSTANT VARCHAR2(30) := 'CSD_MTL_CONSUMED_F';
  C_CSD_RES_CONSUMED_F CONSTANT VARCHAR2(30) := 'CSD_RES_CONSUMED_F';

  -- The following constants represent inventory transaction types.
  -- Of the many INV txn types only the following ones are used in the package.
  lc_MTL_TXN_TYPE_COMP_ISSUE CONSTANT NUMBER := 35;
  lc_MTL_TXN_TYPE_COMP_RETURN CONSTANT NUMBER := 43;


/*--------------------------------------------------*/
/* procedure name: get_last_run_date                */
/* description   : procedure used to get            */
/*                 the last run date for the ETL    */
/*--------------------------------------------------*/

  FUNCTION get_last_run_date(p_fact_name VARCHAR2
                             ) RETURN DATE;

/*--------------------------------------------------*/
/* procedure name: initial_load_ro_etl              */
/* description   : procedure to load Repair Orders  */
/*                 fact initially.                  */
/*--------------------------------------------------*/

  PROCEDURE initial_load_ro_etl(errbuf  IN OUT NOCOPY VARCHAR2,
                                retcode IN OUT NOCOPY VARCHAR2);

/*--------------------------------------------------*/
/* procedure name: incr_load_ro_etl                 */
/* description   : procedure to load Repair Orders  */
/*                 fact incrementally               */
/*--------------------------------------------------*/
  PROCEDURE incr_load_ro_etl(errbuf  in out NOCOPY VARCHAR2,
                             retcode in out NOCOPY VARCHAR2);

/*--------------------------------------------------*/
/* procedure name: initial_load_mtl_etl             */
/* description   : procedure to load Materials      */
/*                 Consumed fact initially.         */
/*--------------------------------------------------*/

  PROCEDURE initial_load_mtl_etl(errbuf  IN OUT NOCOPY VARCHAR2,
                                 retcode IN OUT NOCOPY VARCHAR2);

/*--------------------------------------------------*/
/* procedure name: incr_load_mtl_etl                */
/* description   : procedure to load Materials      */
/*                 Consumed fact incrementally      */
/*--------------------------------------------------*/
  PROCEDURE incr_load_mtl_etl(errbuf  in out NOCOPY VARCHAR2,
                              retcode in out NOCOPY VARCHAR2);

/*--------------------------------------------------*/
/* procedure name: initial_load_res_etl             */
/* description   : procedure to load Resources      */
/*                 Consumed fact initially.         */
/*--------------------------------------------------*/

  PROCEDURE initial_load_res_etl(errbuf  IN OUT NOCOPY VARCHAR2,
                                 retcode IN OUT NOCOPY VARCHAR2);

/*--------------------------------------------------*/
/* procedure name: incr_load_res_etl                */
/* description   : procedure to load Resources      */
/*                 Consumed fact incrementally      */
/*--------------------------------------------------*/
  PROCEDURE incr_load_res_etl(errbuf  in out NOCOPY VARCHAR2,
                              retcode in out NOCOPY VARCHAR2);

/*--------------------------------------------------*/
/* procedure name: Initial_Load                     */
/* description   : procedure to load Repair Orders  */
/*                 Resource and Material facts      */
/*                 initially.                       */
/*--------------------------------------------------*/
  PROCEDURE Initial_Load(errbuf  IN OUT NOCOPY VARCHAR2,
                         retcode IN OUT NOCOPY varchar2 );

/*--------------------------------------------------*/
/* procedure name: Incr_Load                        */
/* description   : procedure to load                */
/*                 fact  tables incrementally       */
/*--------------------------------------------------*/
  PROCEDURE Incr_Load(errbuf  in out NOCOPY VARCHAR2,
                      retcode in out NOCOPY VARCHAR2);

/*--------------------------------------------------*/
/* procedure name: Hvr_Bi_Driver_Main               */
/* description   : procedure to load                */
/*                 fact  tables incrementally       */
/*--------------------------------------------------*/
PROCEDURE Hvr_Bi_Driver_Main (errbuf  IN OUT NOCOPY VARCHAR2,
                                retcode IN OUT NOCOPY VARCHAR2,
                                p_refresh_type IN VARCHAR2 );

END CSD_HVR_BI_PVT;

 

/
