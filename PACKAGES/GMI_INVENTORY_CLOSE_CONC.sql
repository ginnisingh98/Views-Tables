--------------------------------------------------------
--  DDL for Package GMI_INVENTORY_CLOSE_CONC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMI_INVENTORY_CLOSE_CONC" AUTHID CURRENT_USER AS
/* $Header: gmisubrs.pls 115.2 2002/10/25 18:21:42 jdiiorio noship $ */

X_msg                       VARCHAR2(2000);
X_errmsg                    VARCHAR2(160);
x_close_err                 NUMBER := 0;
PROCEDURE RUN(
	errbuf     OUT NOCOPY VARCHAR2,
	retcode    OUT NOCOPY VARCHAR2,
	P_sequence    IN	VARCHAR2,
	P_fiscal_year IN	VARCHAR2,
	P_period      IN	VARCHAR2,
	P_period_id   IN	VARCHAR2,
	P_start_date  IN	VARCHAR2,
	P_end_date    IN	VARCHAR2,
	P_op_code     IN	VARCHAR2,
	P_orgn_code   IN	VARCHAR2,
	P_close_ind   IN	VARCHAR2);

PROCEDURE inventory_close(pfiscal_year VARCHAR2,
                              pprd_id      NUMBER,
                              pperiod      NUMBER,
                              pwhse_code   VARCHAR2,
                              pop_code     NUMBER,
                              pprd_start_date DATE,
                              pprd_end_date   DATE);


/* Subtypes
    ======== */
SUBTYPE enddate_type    IS ic_cldr_dtl.period_end_date%TYPE;
SUBTYPE orgn_type       IS ic_cldr_dtl.orgn_code%TYPE;
SUBTYPE whse_type       IS ic_whse_mst.whse_code%TYPE;
--SUBTYPE period_type     IS ic_whse_sts.period%TYPE;
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

END;

 

/
