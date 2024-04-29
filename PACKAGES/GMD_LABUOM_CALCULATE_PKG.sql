--------------------------------------------------------
--  DDL for Package GMD_LABUOM_CALCULATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_LABUOM_CALCULATE_PKG" AUTHID CURRENT_USER as
/* $Header: GMDSUOMS.pls 120.0 2005/07/13 07:32 rajreddy noship $ */

/* Constants
=========*/
cur_factor_default CONSTANT INTEGER := 1;
new_factor_default CONSTANT INTEGER := 1;

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

     /* =============================================
      FUNCTION:
      uom_conversion         OVERLOADED FUNCTION
                                   LAB ONLY!

      DESCRIPTION:
        This PL/SQL function is responsible for
        calculating and returning the converted
        quantity of an item in the unit of measure
        specified.

        The uom_conversion function ASSUMES POSITIVE NUMBERS ONLY!
        ALL CALLERS MUST DEAL WITH NEGATIVE NUMBERS PRIOR TO
        CALLING THIS FUNCTION!

      PARAMETERS:
        pitem_id     The surrogate key of the item number

        pformula_id  The surrogate key for the formula/version
                     being converted.  ALLOWS ZERO if performing
                     a regular conversion. FOR LAB MGT ONLY!

        pcur_qty     The current quantity to convert.

        pcur_uom     The current unit of measure to convert from.

        pnew_uom     The unit of measure to convert to.

        patomic      Flag to determine if decimal percision is
                     required as part of the conversion.
                       0 = No, provide full precision.
                       1 = Yes, provide integer ONLY!

        plab_id      Organization_id

        pcnv_factor  Conversion factor for density passed
                     by the user.  NOT REQUIRED!
      RETURNS:
      >=0 - SUCCESS
       -1 - Package problem.
       -2 - Lab Type not passed for LAB conversion.
       -3 - UOM_CLASS and conversion factor for current UOM not found.
       -4 - UOM_CLASS and conversion factor for NEW UOM not found.
       -5 - Cannot determine INVENTORY UOM for item.
       -6 - UOM_CLASS and conversion factor for INV UOM not found.
       -7 - Cannot find conversion factor for CURRENT UOM.
       -8 - LAB CONVERSION - LM$DENSITY variable not found.
       -9 - LAB CONVERSION - conversion factor not found.
      -10 - Cannot find conversion factor for NEW UOM.
      -11 - Item_id not passed as a parameter.
      ============================================================== */

  FUNCTION uom_conversion(pitem_id     NUMBER,
                          pformula_id  NUMBER,
                          plot_number VARCHAR2,
                          pcur_qty     NUMBER,
                          pcur_uom     VARCHAR2,
                          pnew_uom     VARCHAR2,
                          patomic      NUMBER,
                          plab_id      NUMBER,
                          pcnv_factor  NUMBER DEFAULT 0) RETURN NUMBER;

end GMD_LABUOM_CALCULATE_PKG;

 

/
