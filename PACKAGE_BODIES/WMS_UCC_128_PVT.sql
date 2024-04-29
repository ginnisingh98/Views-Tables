--------------------------------------------------------
--  DDL for Package Body WMS_UCC_128_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_UCC_128_PVT" AS
/* $Header: WMSUCCSB.pls 120.0.12010000.2 2008/08/04 19:12:16 bvanjaku ship $ */

--  Global constant holding the package name
G_PKG_NAME    CONSTANT VARCHAR2(30)  := 'WMS_UCC_128_PVT';
g_pkg_version CONSTANT VARCHAR2(100) := '$Header: WMSUCCSB.pls 120.0.12010000.2 2008/08/04 19:12:16 bvanjaku ship $';

g_gtin_cross_ref_type VARCHAR2(25) := fnd_profile.value('INV:GTIN_CROSS_REFERENCE_TYPE');
g_gtin_code_length NUMBER := 14;

PROCEDURE print_debug ( msg in varchar2, p_level NUMBER := 4 ) IS
BEGIN
   INV_TRX_UTIL_PUB.TRACE(msg, 'WMS_UCC_128_PVT', p_level);
   --dbms_output.put_line(msg);
END;

-- ======================================================================
-- PROCEDURE get_xref_values
-- ======================================================================
-- Purpose
--     Retrieve crossreference UOM and Revision base on cross reference type
--     and number .
-- Input Parameters
--    p_org_id
--    p_cross_reference
--
-- Output Parameters
--    x_uom_code return a revision if define , otherwise NULL
--    x_revision return a revision if define , otherwise NULL
--    x_item_id  returns matching item-id of p_cross_reference value
--
PROCEDURE get_xref_values
  (x_uom_code OUT NOCOPY VARCHAR2,
   x_revision OUT NOCOPY VARCHAR2,
   x_item_id  OUT NOCOPY NUMBER,
   p_org_id          IN NUMBER,
   p_cross_reference IN VARCHAR2)
  IS
  l_cross_ref varchar2(204);

BEGIN
   print_debug('Begin get_xref_values: p_org_id:'||p_org_id||',p_xref='||p_cross_reference);

   SELECT mx.inventory_item_id, mx.uom_code,  mr.revision
   INTO   x_item_id, x_uom_code, x_revision
   FROM MTL_CROSS_REFERENCES mx, MTL_ITEM_REVISIONS_B mr
   WHERE mx.organization_id = mr.organization_id(+)
      and mx.inventory_item_id = mr.inventory_item_id(+)
      and mx.revision_id = mr.revision_id(+)
      and mx.cross_reference_type = g_gtin_cross_ref_type
      and mx.cross_reference = p_cross_reference
      and nvl(mx.organization_id, p_org_id) = p_org_id
      and rownum = 1;

   print_debug('x_item='||x_item_id||',x_uom='||x_uom_code||',x_rev='||x_revision);

 EXCEPTION
  WHEN OTHERS THEN
     x_uom_code := null;
     x_revision := null;
     x_item_id  := null;
END get_xref_values;

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
   p_cross_reference       IN VARCHAR2)
  IS
  l_cross_ref varchar2(204);

BEGIN
   print_debug('Begin get_xref_values: p_org_id:'||p_org_id||',p_cross_reference='||p_cross_reference||',g_gtin_cross_ref_type='||g_gtin_cross_ref_type);

   SELECT msi.concatenated_segments, mx.uom_code,  mr.revision
   INTO   x_concatenated_segments, x_uom_code, x_revision
   FROM   MTL_CROSS_REFERENCES mx, MTL_ITEM_REVISIONS_B mr,
          mtl_system_items_kfv msi
   WHERE  mx.organization_id = mr.organization_id(+)
      and mx.inventory_item_id = mr.inventory_item_id(+)
      and mx.revision_id = mr.revision_id(+)
      and mx.cross_reference_type = g_gtin_cross_ref_type
      and mx.cross_reference LIKE lpad(Rtrim(p_cross_reference,'%'),
                                          g_gtin_code_length, '00000000000000')
      and nvl(mx.organization_id, p_org_id) = p_org_id
      and msi.organization_id = p_org_id
      and msi.inventory_item_id = mx.inventory_item_id
      and rownum = 1;

   print_debug('x_concatenated_segments='||x_concatenated_segments||',x_uom='||x_uom_code||',x_rev='||x_revision);

 EXCEPTION
  WHEN OTHERS THEN
     x_uom_code := null;
     x_revision := null;
     x_concatenated_segments  := null;
END get_xref_values;


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
    RETURN NUMBER
IS

  L NUMBER;
  I NUMBER;
  l_evensum        NUMBER := 0;
  l_oddsum         NUMBER := 0;
  l_total          NUMBER := 0;
  l_checkdigit     NUMBER := 0;
  l_remainder      NUMBER := 0;

  l_length NUMBER;
  l_lpn_str varchar2(255);
BEGIN
   print_debug('Begin GenCheckDigit()');
   print_debug('p_lpn_str : ' || p_lpn_str);
   L := 0;
   l_lpn_str := rtrim(p_lpn_str);
   l_length := LENGTH(l_lpn_str);

   FOR I IN REVERSE 1..l_length
   LOOP
     -- print_debug('l_lpn_str(' || I || ') : ' ||
     --       to_number(substr(l_lpn_str,I,1)));
     IF (mod(L,2) = 0) THEN
       l_Evensum := l_Evensum + to_number(substr(l_lpn_str,I,1));
     ELSE
       l_Oddsum := l_Oddsum + to_number(substr(l_lpn_str,I,1));
     END IF;
     L := L + 1;
   END LOOP;

   l_Evensum := l_Evensum * 3;
   l_Total := l_Evensum + l_Oddsum;
   l_remainder := mod(l_total,10);
   print_debug('l_total:' || l_total || ' l_remainder : ' || l_remainder);
   IF (l_remainder > 0) THEN
      l_checkdigit := 10 - l_remainder;
   END IF;
   print_debug('l_checkdigit : ' || l_checkdigit);
   RETURN l_checkdigit;

END GenCheckDigit;


PROCEDURE Get_UCC_128_Attributes (
  x_return_status      OUT    NOCOPY VARCHAR2
, x_ucc_128_attributes IN OUT NOCOPY UCC_128_Attributes
, p_org                IN            INV_VALIDATE.ORG := NULL
) IS
l_api_name    CONSTANT VARCHAR2(30) := 'Get_UCC_128_Attributes';
l_api_version CONSTANT NUMBER       := 1.0;
l_debug                NUMBER       := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
l_progress             VARCHAR2(10) := '0';

BEGIN
  -- Initialize API return status to success
  x_return_status := fnd_api.g_ret_sts_success;

  IF ( l_debug = 1 ) THEN
    print_debug(l_api_name || ' Entered ' || g_pkg_version, 1);
    print_debug('xorgid='||x_ucc_128_attributes.organization_id||' orgid='||p_org.organization_id||' sfxflag='||p_org.ucc_128_suffix_flag||' length='||p_org.total_lpn_length, 4);
  END IF;

  IF ( p_org.organization_id IS NOT NULL ) THEN
    l_progress := '100';
    x_ucc_128_attributes.organization_id     := p_org.organization_id;
    x_ucc_128_attributes.total_lpn_length    := p_org.total_lpn_length;
    x_ucc_128_attributes.ucc_128_suffix_flag := p_org.ucc_128_suffix_flag;
    l_progress := '110';
  ELSE
    l_progress := '200';
    SELECT total_lpn_length
         , ucc_128_suffix_flag
      INTO x_ucc_128_attributes.total_lpn_length
         , x_ucc_128_attributes.ucc_128_suffix_flag
      FROM mtl_parameters
     WHERE organization_id = x_ucc_128_attributes.organization_id;
    l_progress := '210';
  END IF;

  IF ( l_debug = 1 ) THEN
    print_debug(l_api_name||' Exited sfxflag='||x_ucc_128_attributes.ucc_128_suffix_flag||' length='||x_ucc_128_attributes.total_lpn_length, 1);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF (l_debug = 1) THEN
      print_debug(l_api_name ||' Error l_progress=' || l_progress);
      IF ( SQLCODE IS NOT NULL ) THEN
        print_debug('SQL error: ' || SQLERRM(SQLCODE));
      END IF;
    END IF;
    x_return_status := fnd_api.g_ret_sts_error;
END Get_UCC_128_Attributes;

END WMS_UCC_128_PVT;

/
