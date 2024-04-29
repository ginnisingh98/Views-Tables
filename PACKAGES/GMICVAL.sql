--------------------------------------------------------
--  DDL for Package GMICVAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMICVAL" AUTHID CURRENT_USER AS
/* $Header: gmicvals.pls 120.0 2005/05/25 16:06:40 appldev noship $ */

/* Subtypes
======== */
SUBTYPE item_surg_type   IS ic_item_mst.item_id%TYPE;
SUBTYPE item_number_type IS ic_item_mst.item_no%TYPE;
SUBTYPE lot_surg_type    IS ic_lots_mst.lot_id%TYPE;
SUBTYPE form_surg_type   IS lm_item_dat.formula_id%TYPE;
SUBTYPE lab_type         IS lm_item_dat.lab_type%TYPE;
SUBTYPE reason_type      IS sy_reas_cds.reason_code%TYPE;
SUBTYPE loct_type        IS ic_loct_mst.location%TYPE;
SUBTYPE whse_type        IS ic_whse_mst.whse_code%TYPE;
SUBTYPE grade_type       IS qc_grad_mst.qc_grade%TYPE;
SUBTYPE status_type      IS ic_lots_sts.lot_status%TYPE;
SUBTYPE lot_no_type      IS ic_lots_mst.lot_no%TYPE;
SUBTYPE desc_type        IS ic_lots_mst.lot_desc%TYPE;
SUBTYPE dualum_type      IS ic_item_mst.dualum_ind%TYPE;
SUBTYPE uom_type         IS ic_item_mst.item_um%TYPE;
SUBTYPE dev_type         IS ic_item_mst.deviation_hi%TYPE;
SUBTYPE quantity_type    IS ic_loct_inv.loct_onhand%TYPE;
SUBTYPE orgn_type        IS sy_orgn_mst.orgn_code%TYPE;
SUBTYPE ctl_type         IS ic_item_mst.loct_ctl%TYPE;
SUBTYPE flag_type        IS NUMBER;

/* Constants
=========*/
ss_debug CONSTANT INTEGER           := 1;

/* Error Return Code Constants:
============================*/
VAL_PACKAGE_ERR         CONSTANT INTEGER := -1;
VAL_REASONCODE_ERR      CONSTANT INTEGER := -61;
VAL_LOCATION_ERR        CONSTANT INTEGER := -62;
VAL_GRADE_ERR           CONSTANT INTEGER := -63;
VAL_LOTSTATUS_ERR       CONSTANT INTEGER := -64;
VAL_WHSE_ERR            CONSTANT INTEGER := -65;
VAL_LOT_ERR             CONSTANT INTEGER := -66;
VAL_DUALUM_ERR          CONSTANT INTEGER := -67;
VAL_CALCDEV_HIGH_ERR    CONSTANT INTEGER := -68;
VAL_CALCDEV_LO_ERR      CONSTANT INTEGER := -69;
VAL_ITEMATTR_ERR        CONSTANT INTEGER := -70;
VAL_NOTLOT_CTL_ERR      CONSTANT INTEGER := -71;
VAL_LOT_PARM_ERR        CONSTANT INTEGER := -72;
VAL_SUBLOT_ERR          CONSTANT INTEGER := -73;
VAL_UOMATTR_ERR         CONSTANT INTEGER := -74;
VAL_ITEM_ERR            CONSTANT INTEGER := -75;
VAL_CONTROLS_ERR        CONSTANT INTEGER := -76;
VAL_DEFAULT_LOCT_ERR    CONSTANT INTEGER := -77;
VAL_USING_DEFAULT_ERR   CONSTANT INTEGER := -78;
VAL_CO_CODE_ERR         CONSTANT INTEGER := -79;
VAL_ORGN_CODE_ERR       CONSTANT INTEGER := -80;
VAL_UOMCODE_ERR         CONSTANT INTEGER := -81;
VAL_NOTLOCATION_CTL_ERR CONSTANT INTEGER := -82;


/* Functions and Procedures
========================*/
PROCEDURE trans_date_val(ptrans_date DATE,
                        porgn_code  VARCHAR2,
                        pwhse_code  VARCHAR2);

PROCEDURE deviation_val(pitem_id NUMBER,
                        plot_id  NUMBER,
                        pcur_qty NUMBER,
                        pcur_uom VARCHAR2,
                        pnew_qty NUMBER,
                        pnew_uom VARCHAR2);

PROCEDURE itm_loct_validation(plocation  VARCHAR2,
                              pwhse_code VARCHAR2,
                              ploct_ctl  NUMBER);

FUNCTION item_val(pitem_id NUMBER) RETURN NUMBER;

FUNCTION item_val(pitem_no VARCHAR2) RETURN NUMBER;

FUNCTION lot_validate(pitem_id NUMBER,
                      plot_id  NUMBER) RETURN NUMBER;

FUNCTION lot_validate(pitem_no   VARCHAR2,
                      plot_no    VARCHAR2,
                      psublot_no VARCHAR2 DEFAULT 0)
                      RETURN NUMBER;

FUNCTION reason_code_val(preason_code VARCHAR2) RETURN NUMBER;

FUNCTION itm_location_val(plocation  VARCHAR2,
                          pwhse_code VARCHAR2,
                          ploct_ctl  NUMBER) RETURN NUMBER;

FUNCTION whse_location_val(porgn_code VARCHAR2,
                           pwhse_code VARCHAR2,
                           plocation  VARCHAR2) RETURN NUMBER;

FUNCTION grade_val(pqc_grade  VARCHAR2) RETURN NUMBER;

FUNCTION lot_status_val(plot_status  VARCHAR2) RETURN NUMBER;

FUNCTION whse_val(pwhse_code VARCHAR2,
                  porgn_code VARCHAR2) RETURN NUMBER;

FUNCTION co_code_val(porgn_code VARCHAR2) RETURN NUMBER;

FUNCTION orgn_code_val(porgn_code VARCHAR2) RETURN NUMBER;

FUNCTION uomcode_val(puom_code VARCHAR2) RETURN NUMBER;

FUNCTION dev_validation(pitem_id    NUMBER,
                        plot_id     NUMBER,
                        ptrans_qty1 NUMBER,
                        pprim_uom   VARCHAR2,
                        ptrans_qty2 NUMBER,
                        psec_uom    VARCHAR2,
                        patomic     NUMBER) RETURN NUMBER;

FUNCTION det_dualum_ind(pitem_id NUMBER) RETURN NUMBER;

FUNCTION calc_deviation(pitem_id       NUMBER,
                        ptrans_qty2    NUMBER,
                        pconverted_qty NUMBER) RETURN NUMBER;


END;


 

/
