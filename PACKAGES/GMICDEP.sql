--------------------------------------------------------
--  DDL for Package GMICDEP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMICDEP" AUTHID CURRENT_USER AS
/* $Header: gmicdeps.pls 120.0 2005/05/25 16:07:23 appldev noship $ */

/* Subtypes
   ========*/
SUBTYPE enddate_type    IS ic_cldr_dtl.period_end_date%TYPE;
SUBTYPE orgn_type       IS ic_cldr_dtl.orgn_code%TYPE;
SUBTYPE whse_type       IS ic_whse_mst.whse_code%TYPE;
SUBTYPE period_type     IS ic_whse_sts.period%TYPE;
SUBTYPE item_srg_type   IS ic_item_mst.item_id%TYPE;
SUBTYPE lot_srg_type    IS ic_lots_mst.lot_id%TYPE;
SUBTYPE location_type   IS ic_loct_mst.location%TYPE;
SUBTYPE doc_type        IS ic_tran_pnd.doc_type%TYPE;
SUBTYPE ln_type         IS ic_tran_pnd.line_type%TYPE;
SUBTYPE reasoncode_type IS ic_tran_pnd.reason_code%TYPE;
SUBTYPE trans_srg_type  IS ic_tran_pnd.trans_id%TYPE;
SUBTYPE quantity_type   IS ic_loct_inv.loct_onhand%TYPE;

/* Constants
=========*/
ss_debug CONSTANT INTEGER := 1;

/* Constant Return Error Codes:
============================*/
DEP_COST_FISCAL_POLICY_ERR CONSTANT INTEGER := -251;
DEP_COST_UPDATE_ERR        CONSTANT INTEGER := -252;

/* Functions and Procedures
========================*/
FUNCTION calc_costs(pwhse_code     VARCHAR2,
                    pprd_end_date  DATE,
                    pperiod        NUMBER,
                    pfiscal_year   VARCHAR2,
                    pop_code       NUMBER) RETURN NUMBER;

END;

 

/
