--------------------------------------------------------
--  DDL for Package GMICCAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMICCAL" AUTHID CURRENT_USER AS
/* $Header: gmiccals.pls 115.2 2002/12/03 22:07:51 jdiiorio ship $ */

/* Subtypes
    ======== */
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
   ========= */
ss_debug CONSTANT INTEGER := 1;

/* Constant Return Error Codes:
=============================== */
INVCAL_FISCALYR_ERR       CONSTANT INTEGER := -21;
INVCAL_PERIOD_ERR         CONSTANT INTEGER := -22;
INVCAL_PERIOD_CLOSED      CONSTANT INTEGER := -23;
INVCAL_CO_ERR             CONSTANT INTEGER := -24;
INVCAL_WHSE_CLOSED        CONSTANT INTEGER := -25;
INVCAL_DATE_PARM_ERR      CONSTANT INTEGER := -26;
INVCAL_ORGN_PARM_ERR      CONSTANT INTEGER := -27;
INVCAL_WHSE_PARM_ERR      CONSTANT INTEGER := -28;
INVCAL_WHSE_ERR           CONSTANT INTEGER := -29;
INVCAL_WHSESTS_UPDATE_ERR CONSTANT INTEGER := -30;
INVCAL_PRDSTS_UPDATE_ERR  CONSTANT INTEGER := -31;

ORGN_CO_ERR               CONSTANT INTEGER := -41;
ORGN_VAL_ERR              CONSTANT INTEGER := -42;

/* Functions and Procedures
   ======================== */
FUNCTION trans_date_validate(trans_date DATE,
                             porgn_code VARCHAR2,
                             pwhse_code VARCHAR2) RETURN NUMBER;

FUNCTION delete_ic_perd_bal(pfiscal_year VARCHAR2,
                            pperiod      NUMBER,
                            pwhse_code   VARCHAR2) RETURN NUMBER;

FUNCTION insert_ic_perd_bal(pfiscal_year VARCHAR2,
                            pper_id      NUMBER,
                            pperiod      NUMBER,
                            pwhse_code   VARCHAR2,
                            pop_code     NUMBER) RETURN NUMBER;

FUNCTION calc_usage_yield(pwhse_code VARCHAR2,
                          pprd_start_date DATE,
                          pprd_end_date   DATE,
                          plog_end_date   DATE,
                          pperiod         NUMBER,
                          pprd_id         NUMBER,
                          pfiscal_year    VARCHAR2,
                          pop_code        NUMBER) RETURN NUMBER;

FUNCTION whse_status_update(pwhse_code   VARCHAR2,
                            pfiscal_year VARCHAR2,
                            pperiod      NUMBER,
                            pclose_type  NUMBER) RETURN NUMBER;

FUNCTION period_status_update(pco_code     VARCHAR2,
                              pfiscal_year VARCHAR2,
                              pperiod      NUMBER) RETURN NUMBER;

FUNCTION determine_company(porgn_code VARCHAR2,
                           pout_co_code IN OUT NOCOPY VARCHAR2)
                           RETURN NUMBER;

END;

 

/
