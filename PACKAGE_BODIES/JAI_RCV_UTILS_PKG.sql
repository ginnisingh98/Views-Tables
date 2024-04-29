--------------------------------------------------------
--  DDL for Package Body JAI_RCV_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_RCV_UTILS_PKG" AS
/* $Header: jai_rcv_utils.plb 120.2 2006/05/26 11:58:32 lgopalsa ship $ */

/* --------------------------------------------------------------------------------------
Filename:

Change History:

Date         Bug         Remarks
---------    ----------  -------------------------------------------------------------
08-Jun-2005  Version 116.2 jai_rcv_utils -Object is Modified to refer to New DB Entity names in place of Old DB Entity Names
		as required for CASE COMPLAINCE.

13-Jun-2005    File Version: 116.3
                  Ramananda for bug#4428980. Removal of SQL LITERALs is done

 06-Jul-2005   rallamse for bug# PADDR Elimination
               1. Removed function query_locator from both package spec and body.
 --------------------------------------------------------------------------------------*/


/*------------------------------------------------------------------------------------------------------------*/
  FUNCTION get_orgn_type_flags (p_location_id number,
                                p_organization_id number,
                                p_subinventory varchar2)
  RETURN VARCHAR2 IS
    v_rg_location_id     number;
    v_subinv             varchar2(3);
    lv_object_name CONSTANT VARCHAR2 (61) := 'jai_rcv_utils_pkg.get_orgn_type_flags';
  BEGIN

  /*----------------------------------------------------------------------------------------------------------------------
   FILENAME: get_orgn_type_flags.sql
   CHANGE HISTORY:

  S.No      Date          Author and Details
  -----------------------------------------------------------------------------------------------------------------------
  1       30/07/04       Nagaraj.s for Bug 3693740 Version : 115.1
                         Previously the condition
                         v_subinv := NVL(v_subinv,'No Data');
                         and since the data v_subinv was having a width of
                         3 characters. Hence the call to this function went into
                         a Numeric or Value Error. Hence changed this to NN.

  */
    jai_rcv_utils_pkg.get_rg1_location (p_location_id,
                                            p_organization_id,
                                            p_subinventory,
                                            v_rg_location_id);
    For loc_rec IN (SELECT manufacturing,
                           trading
                      FROM JAI_CMN_INVENTORY_ORGS
                     WHERE organization_id = p_organization_id
                       AND location_id = v_rg_location_id)
    LOOP
      v_subinv := NVL(loc_rec.manufacturing, 'N')||NVL(loc_rec.trading, 'N');
    END LOOP;

    v_subinv := NVL(v_subinv, 'NN'); /* Changed as NN for Bug3693740 */

    RETURN v_subinv;
  EXCEPTION
    WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME ('JA','JAI_EXCEPTION_OCCURED');
    FND_MESSAGE.SET_TOKEN ('JAI_PROCESS_MSG',lv_object_name ||'.Err:'||sqlerrm);
    app_exception.raise_exception;
  END get_orgn_type_flags;
/*------------------------------------------------------------------------------------------------------------*/

PROCEDURE get_div_range (p_vendor_id number,
                            p_vendor_site_id number,
                            p_range_no OUT NOCOPY varchar2,
                            p_division_no OUT NOCOPY varchar2) IS
  BEGIN
    For hr_rec IN (SELECT excise_duty_range range,
                          excise_duty_division div
                     FROM JAI_CMN_VENDOR_SITES
                    WHERE vendor_id = p_vendor_id
                      AND vendor_site_id = p_vendor_site_id)
    LOOP
      p_range_no := hr_rec.range;
      p_division_no := hr_rec.div;
    END LOOP;

  END get_div_range;
/*--------------------------------------------------------------------------------------------------------*/
  PROCEDURE get_func_curr (p_organization_id number,
                            p_func_currency OUT NOCOPY varchar2,
                            p_gl_set_of_books_id OUT NOCOPY number)
  IS
    v_set_of_books_id            gl_sets_of_books.set_of_books_id % type;
    v_func_currency              gl_sets_of_books.currency_code % type;
    v_currency_conversion_rate   rcv_transactions.currency_conversion_type % type;

    /* Bug 5243532. Added by Lakshmi Gopalsami
     * Defined variable for implementing caching logic.
     */
    l_func_curr_det jai_plsql_cache_pkg.func_curr_details;
    -- End for bug 5243532
  BEGIN
    IF p_organization_id IS NOT NULL
    THEN
     /* bug 5243532. Added by Lakshmi Gopalsami
      * removed cursor org_rec and implemented caching logic.
      */
     l_func_curr_det       := jai_plsql_cache_pkg.return_sob_curr
                              (p_org_id  => p_organization_id );
     v_func_currency       := l_func_curr_det.currency_code;
     v_set_of_books_id     := l_func_curr_det.ledger_id;

    ELSE
      FND_PROFILE.GET('GL_SET_OF_BKS_ID', v_set_of_books_id);
      For org_rec IN (SELECT currency_code
                        FROM gl_sets_of_books
                       WHERE set_of_books_id = v_set_of_books_id)
      LOOP
        v_func_currency := org_rec.currency_code;
      END LOOP;
    END IF;
    p_func_currency := v_func_currency;
    p_gl_set_of_books_id := v_set_of_books_id;
  END get_func_curr;
----------------------------- Procedure For picking organization and item -----------------------
  PROCEDURE get_organization (p_shipment_line_id number,
                               p_organization_id OUT NOCOPY number,
                               p_item_id OUT NOCOPY number) IS
  BEGIN
    For item_rec IN (SELECT to_organization_id,
                            item_id
                       FROM rcv_shipment_lines
                      WHERE shipment_line_id = p_shipment_line_id)
    LOOP
      p_organization_id := item_rec.to_organization_id;
      p_item_id := item_rec.item_id;
    END LOOP;
  END get_organization;

---------------------- Procedure For picking the location_id and bonded type --------------------
  PROCEDURE get_rg1_location (p_location_id number,
                               p_organization_id number,
                               p_subinventory varchar2,
                               p_rg_location_id OUT NOCOPY number) IS
    v_rg_location_id      number;
    v_organization_id     number;
  BEGIN
    IF p_subinventory IS NOT NULL
    THEN
      get_location (p_location_id,
                     p_organization_id,
                     p_subinventory,
                     v_rg_location_id);
    ELSE
      IF p_location_id = 0
      THEN
        v_rg_location_id := 0;
      ELSIF p_location_id IS NOT NULL
      THEN
        For hr_rec IN (SELECT inventory_organization_id org
                         FROM hr_locations
                        WHERE location_id = p_location_id)
        LOOP
          v_organization_id := NVL(hr_rec.org, 0);
        END LOOP;
        IF NVL(v_organization_id, 0) <> p_organization_id
        THEN
          v_rg_location_id := 0;
        ELSE
          v_rg_location_id := p_location_id;
        END IF;
      END IF;
    END IF;
    p_rg_location_id := NVL(v_rg_location_id, 0);
  END get_rg1_location;

---------------------- Procedure For picking the location_id and bonded type --------------------

PROCEDURE get_location (p_location_id number,
                           p_organization_id number,
                           p_subinventory varchar2,
                           p_rg_location_id OUT NOCOPY number) IS
    v_rg_location_id      number;
  BEGIN

    For location_rec IN (SELECT location_id
                           FROM JAI_INV_SUBINV_DTLS
                          WHERE organization_id = p_organization_id
                            AND sub_inventory_name = p_subinventory)
    LOOP
      v_rg_location_id := location_rec.location_id;
    END LOOP;
    p_rg_location_id := NVL(v_rg_location_id, 0);
  END get_location;




END jai_rcv_utils_pkg;

/
