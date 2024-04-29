--------------------------------------------------------
--  DDL for Package Body PA_PO_INTEGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PO_INTEGRATION" AS
/* $Header: PAPOINTB.pls 120.0 2005/05/30 14:35:21 appldev noship $ */

-- ==========================================================================
-- = FUNCTION IS_PJR_PO_INTEG_ENABLED: This function checks if PJR License is
-- = on and if PA.FP.M or above is installed.
-- ==========================================================================

FUNCTION IS_PJR_PO_INTEG_ENABLED RETURN VARCHAR2 IS

BEGIN

  Return 'N';

END IS_PJR_PO_INTEG_ENABLED;

-- ==========================================================================
-- = FUNCTION is_pjc_po_cwk_intg_enab: This function will return 'N' in 11.5.10
-- = to indicate that PA.FP.M is not installed. PO will disable project related
-- = fields for contingent worker POs in 11.5.10. This function will be changed
-- = to return 'Y' in FP.M.
-- ==========================================================================

FUNCTION is_pjc_po_cwk_intg_enab RETURN VARCHAR2 IS

BEGIN

  Return 'Y';

END is_pjc_po_cwk_intg_enab;

-- ==========================================================================
-- = FUNCTION is_pjc_11i10_enabled: This function will return 'N' in the stub
-- = to indicate that PA changes for 11.5.10 is not available.
-- = PO will need to include this stub in their patchset.
-- = PJC will change this to return 'Y' in 11.5.10 PA changes.
-- ==========================================================================

FUNCTION is_pjc_11i10_enabled RETURN VARCHAR2 IS

BEGIN

  Return 'Y';

END is_pjc_11i10_enabled;

END PA_PO_INTEGRATION;

/
