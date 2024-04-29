--------------------------------------------------------
--  DDL for Package GMICUOM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMICUOM" AUTHID CURRENT_USER AS
/* $Header: gmicuoms.pls 115.2 2002/11/12 21:21:14 jdiiorio ship $ */
/* Subtypes
========*/
SUBTYPE itm_surg_type  IS ic_item_cnv.item_id%TYPE;
SUBTYPE form_surg_type IS lm_item_dat.formula_id%TYPE;
SUBTYPE lab_type       IS lm_item_dat.lab_type%TYPE;
SUBTYPE lot_surg_type  IS ic_item_cnv.lot_id%TYPE;
SUBTYPE quantity_type  IS ic_loct_inv.loct_onhand%TYPE;
SUBTYPE uomcode_type   IS sy_uoms_mst.um_code%TYPE;
SUBTYPE flag_type      IS NUMBER;

/* Constants
=========*/
ss_debug           CONSTANT INTEGER := 1;
cur_factor_default CONSTANT INTEGER := 1;
new_factor_default CONSTANT INTEGER := 1;
default_lot        CONSTANT INTEGER := 0;

/* RETURN Error Code Constants:
============================*/
UOM_LAB_TYPE_ERR    CONSTANT INTEGER := -2;
UOM_CUR_UOMTYPE_ERR CONSTANT INTEGER := -3;
UOM_NEW_UOMTYPE_ERR CONSTANT INTEGER := -4;
UOM_INVUOM_ERR      CONSTANT INTEGER := -5;
UOM_INV_UOMTYPE_ERR CONSTANT INTEGER := -6;
UOM_CUR_CONV_ERR    CONSTANT INTEGER := -7;
UOM_LAB_CONST_ERR   CONSTANT INTEGER := -8;
UOM_LAB_CONV_ERR    CONSTANT INTEGER := -9;
UOM_NEW_CONV_ERR    CONSTANT INTEGER := -10;
UOM_NOITEM_ERR      CONSTANT INTEGER := -11;

/* Functions and Procedures
========================*/
PROCEDURE icuomcv(pitem_id     NUMBER,
                  plot_id      NUMBER,
                  pcur_qty     NUMBER,
                  pcur_uom     VARCHAR2,
                  pnew_uom     VARCHAR2,
                  onew_qty OUT NOCOPY NUMBER);

PROCEDURE icuomcvl(pitem_id     NUMBER,
                   pformula_id  NUMBER,
                   pcur_qty     NUMBER,
                   pcur_uom     VARCHAR2,
                   pnew_uom     VARCHAR2,
                   plab_type    VARCHAR2,
                   pcnv_factor  NUMBER,
                   onew_qty OUT NOCOPY NUMBER);

/* This is for all Modules except
Laboratory Management and CRP/I2 integration
============================================*/
FUNCTION uom_conversion(pitem_id  NUMBER,
                      plot_id     NUMBER,
                      pcur_qty    NUMBER ,
                      pcur_uom    VARCHAR2,
                      pnew_uom    VARCHAR2,
                      patomic     NUMBER) RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES(uom_conversion, WNDS, WNPS);

/* This is an overloaded function specifically
for Laboratory Management.
=========================================*/
FUNCTION uom_conversion(pitem_id  NUMBER,
                      pformula_id NUMBER,
                      pcur_qty    NUMBER,
                      pcur_uom    VARCHAR2,
                      pnew_uom    VARCHAR2,
                      patomic     NUMBER,
                      plab_type   VARCHAR2,
                      pcnv_factor NUMBER DEFAULT 0) RETURN NUMBER;


/* This function is a wrapper fuction specifically
for Capacity Requirements Planning/I2 Integration.
==================================================*/
FUNCTION i2uom_cv(pitem_id  NUMBER,
                  plot_id   NUMBER,
                  pcur_uom  VARCHAR2,
                  pcur_qty  NUMBER,
                  pnew_uom  VARCHAR2) RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES(i2uom_cv, WNDS, WNPS);

END;

 

/
