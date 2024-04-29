--------------------------------------------------------
--  DDL for Package Body AP_WEB_DB_PO_INT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_WEB_DB_PO_INT_PKG" AS
/* $Header: apwdbpob.pls 115.3 2003/11/06 20:42:07 kwidjaja noship $ */

--
-- Function Name: IsVendorValid
-- Author:        Kristian Widjaja
-- Purpose:       This function checks whether a given Supplier is
--                active as of a given date.
--
-- Input:         p_vendor_id
--                p_effective_date
--
-- Output:        'Y' or 'N'
--
-- Notes:         Bug 3215993
--                Inactive Employees and Contingent Workers project

FUNCTION IsVendorValid(p_vendor_id IN NUMBER,
                       p_effective_date IN DATE default SYSDATE
) return VARCHAR2 IS

BEGIN

  /* Check if the given Supplier is active */
  /* We are ignoring the effective_date for now */
  IF (PO_VENDORS_SV.val_vendor(p_vendor_id)) THEN
    RETURN 'Y';
  ELSE
    RETURN 'N';
  END IF;

END IsVendorValid;

--
-- Function Name: IsVendorSiteValid
-- Author:        Kristian Widjaja
-- Purpose:       This function checks whether a given Supplier Site is
--                active as of a given date.
--
-- Input:         p_vendor_id
--                p_effective_date
--
-- Output:        'Y' or 'N'
--
-- Notes:         Bug 3215993
--                Inactive Employees and Contingent Workers project

FUNCTION IsVendorSiteValid(p_vendor_site_id IN NUMBER,
                       p_effective_date IN DATE default SYSDATE
) return VARCHAR2 IS

BEGIN

  /* Check if the given Supplier Site is active. */
  /* We are ignoring the effective date for now. */
  IF (PO_VENDOR_SITES_SV.val_vendor_site_id('PO',p_vendor_site_id)) THEN
    RETURN 'Y';
  ELSE
    RETURN 'N';
  END IF;

END IsVendorSiteValid;

END AP_WEB_DB_PO_INT_PKG;

/
