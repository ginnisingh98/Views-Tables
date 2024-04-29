--------------------------------------------------------
--  DDL for Package Body PA_CLIENT_EXTN_CIP_ACCT_OVR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CLIENT_EXTN_CIP_ACCT_OVR" AS
-- $Header: PACCXCOB.pls 115.2 2003/08/18 14:30:57 ajdas noship $

FUNCTION CIP_ACCT_OVERRIDE(p_cdl_cip_ccid          IN      NUMBER,
                           p_expenditure_item_id    IN      NUMBER,
                           p_cdl_line_number        IN      NUMBER) RETURN NUMBER IS

BEGIN
 /* This is a client extension function called by the GENERATE_PROJ_ASSET_LINES procedure,
    which groups CDLs into Asset Lines using the CIP Account CCID as one of the grouping
    criteria.  The extension will be called once for every CDL processed by that program.

    The intended use of this extension is to provide clients with the ability to override
    the CIP account on the CDL line with a DIFFERENT code combination id value, in order
    to generate and interface lines to Oracle Assets with different Asset Clearing Account
    than the CIP Account credited in Oracle Projects.  The reason that a customer would want
    to credit a different account than the original account that was debited is that there
    are customers who wish to maintain CIP details in the GL (i.e., CIP costs by Cost Center,
    Activity, etc.), and credit out the CIP account at a higher level (i.e., Balancing Segment
    and Account only).  This allows clients to maintain visibility of CIP spending details
    over time, rather than having them cleared out as soon as assets are posted in Oracle Assets.

    Note that this extension will ALSO be called by the Generate Retirement Cost Lines process,
    for similar purposes.

 */

    RETURN(p_cdl_cip_ccid);

EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END;

END;

/
