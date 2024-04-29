--------------------------------------------------------
--  DDL for Package WMS_UCC_128_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_UCC_128_PVT" AUTHID CURRENT_USER AS
/* $Header: WMSUCCSS.pls 120.0.12010000.2 2008/08/04 19:11:27 bvanjaku ship $ */

-- ======================================================================
-- PROCEDURE get_xref_values
-- ======================================================================
-- Purpose
--   Retrieve crossreferenced item, UOM and Revision based on cross-reference
--     value
-- Input Parameters
--    p_organization_id
--    p_cross_reference
--
-- Output Parameters
--    x_uom_code return a UOM if defined , otherwise NULL
--    x_revision return a revision if defined , otherwise NULL
--    x_item_id  returns the matching item of the p_cross_reference

PROCEDURE get_xref_values
  (x_uom_code     OUT NOCOPY VARCHAR2,
   x_revision     OUT NOCOPY VARCHAR2,
   x_item_id      OUT NOCOPY NUMBER,
   p_org_id          IN NUMBER ,
   p_cross_reference IN VARCHAR2);


-- ======================================================================
-- PROCEDURE get_xref_values
-- ======================================================================
-- Purpose
-- This procedure is another version of get_xref_values which uses concatenated_segments as
-- one of the input parameters instead of zero padded concatenated segments
--     Retrieve crossreference UOM and Revision base on cross reference type
--     and number .
-- Input Parameters
--    p_org_id
--    p_concatenated_segments -
--
-- Output Parameters
--    x_uom_code return a revision if define , otherwise NULL
--    x_revision return a revision if define , otherwise NULL
--    x_item_id  returns matching item-id of p_cross_reference value

PROCEDURE get_xref_values
  (x_uom_code              OUT NOCOPY VARCHAR2,
   x_revision              OUT NOCOPY VARCHAR2,
   x_concatenated_segments OUT NOCOPY VARCHAR2,
   p_org_id                IN NUMBER,
   p_cross_reference       IN VARCHAR2);


-- ======================================================================
-- FUNCTION GenCheckDigit
-- ======================================================================
-- Purpose
--     Generate the CheckDigit for LPN using Modulo 10 Check Digit Algorithm
--      1. Consider the right most digit of the code to be in an 'even'
--           position and assign odd/even to each character moving from right to
--           left.
--      2. Sum the digits in all odd positions
--      3. Sum the digits in all even positions and multiply the result by 3 .
--      4. Sum the totals calculated in steps 2 and 3.
--      5. The Check digit is the number which, when added to the totals
--         calculated in step 4, result in a number  evenly divisible by 10.

-- Input Parameters
--    P_lpn_str  (Required)
--
-- Output value :
--    Valid single check digit .
--

FUNCTION GenCheckDigit(p_lpn_str IN VARCHAR2)
    RETURN NUMBER;

-- Rec Type for UCC128 Attributes from MTL_PARAMETERS
TYPE UCC_128_Attributes is RECORD (
  ORGANIZATION_ID     NUMBER
, TOTAL_LPN_LENGTH    NUMBER
, UCC_128_SUFFIX_FLAG VARCHAR2(1)
);

-- Start of comments
--  API name: Get_UCC_128_Attributes
--  Type    : Private
--  Pre-reqs: None.
--  Function: Returns the column values from MTL_SYSTEM_ITEMS
--            concerning UCC 128 support for a given organization
--  Parameters:
--  IN OUT:
--      x_ucc_128_attributes IN OUT UCC128_Attributes Required
--        SUBTYPE to pass in and retrieve UCC128 attributes from
--        MTL_PARAMETERS.   It is required that the organization_id
--        parameter in this subtype is populated if the p_org
--        input parameter is not used
--  IN: p_org                IN     INV_VALIDATE.ORG  Optional
--        If a properly validated org rec type is available, it
--        can be passed to this API to return the values in the
--        UCC128RecType.  In this case this api serves as an
--        abstraction layer to prevent compile time dependencies
--  Version : Current version 1.0
-- End of comments

PROCEDURE Get_UCC_128_Attributes (
  x_return_status         OUT NOCOPY VARCHAR2
, x_ucc_128_attributes IN OUT NOCOPY UCC_128_Attributes
, p_org                IN            INV_VALIDATE.ORG   := NULL
);

END WMS_UCC_128_PVT;

/
