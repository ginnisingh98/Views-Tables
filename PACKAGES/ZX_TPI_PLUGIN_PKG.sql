--------------------------------------------------------
--  DDL for Package ZX_TPI_PLUGIN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_TPI_PLUGIN_PKG" AUTHID CURRENT_USER AS
/* $Header: zxisrvctypcgpvts.pls 120.1 2005/11/18 18:39:12 svaze ship $ */


    g_rtn_status_var    VARCHAR2(2000);
    g_rtn_msgtbl_var    VARCHAR2(2000);
    g_counter           INTEGER;

    Type NUMBER_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    Type VARCHAR2_tbl_type IS TABLE OF VARCHAR2(100) INDEX BY BINARY_INTEGER;

/* ------------------------------------------------------------------------- */
/*  caching table to store parameter strings                                 */
/* ------------------------------------------------------------------------- */

    Type t_srvcparamtbl IS TABLE OF VARCHAR2(255) INDEX BY BINARY_INTEGER;
    r_srvcparamtbl t_srvcparamtbl;

/* ------------------------------------------------------------------------- */
/*  Record structure for apiowner, service types and Apis                    */
/* ------------------------------------------------------------------------- */

    Type r_apiowner is Record
    (
      api_owner_id  NUMBER_tbl_type ,
      status_code   VARCHAR2_tbl_type
    );

    Type r_srvctypes is Record
    (
      api_owner_id  NUMBER_tbl_type,
      service_type_id NUMBER_tbl_type,
      service_type_code VARCHAR2_tbl_type,
      data_transfer_code VARCHAR2_tbl_type
    );

    Type r_api is Record
    (
      api_owner_id Number_tbl_type,
      service_type_id Number_tbl_type,
      context_ccid Number_tbl_type,
      package_name VARCHAR2_tbl_type,
      procedure_name VARCHAR2_tbl_type,
      service_type_code VARCHAR2_tbl_type
    );

/* ---------------------------------------------------------------------------*/
/*     Record of tables                                                       */
/* ---------------------------------------------------------------------------*/

    t_prv   r_apiowner;
    t_srvc  r_srvctypes;
    t_api   r_api;


PROCEDURE generate_code(
errbuf           OUT NOCOPY VARCHAR2,
retcode          OUT NOCOPY VARCHAR2,
p_srvc_category  IN         VARCHAR2,
p_api_owner_id   IN         NUMBER);

END ZX_TPI_PLUGIN_PKG;

 

/
