--------------------------------------------------------
--  DDL for Package Body GMD_SPEC_MATCH_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_SPEC_MATCH_GRP" AS
/* $Header: GMDGSPMB.pls 120.5 2005/11/25 05:27:09 svankada ship $ */

-- Start of comments
--+==========================================================================+
--|                   Copyright (c) 1998 Oracle Corporation                  |
--|                          Redwood Shores, CA, USA                         |
--|                            All rights reserved.                          |
--+==========================================================================+
--| File Name          : GMDGSPMS.pls                                        |
--| Package Name       : GMD_SPEC_MATCH_GRP                                  |
--| Type               : Group                                               |
--|                                                                          |
--| Notes                                                                    |
--|    This package contains group layer APIs for Specification Match        |
--|                                                                          |
--| HISTORY                                                                  |
--|    Mahesh Chandak	6-Aug-2002	Created.                             |
--|    Brenda Stone     1-Mar-2004  Bug 3473559; Added Hints for spec_id     |
--| Saikiran Vankadari 15-Feb-2005  Made Converegence related changes.     |
--| Saikiran Vankadari 25-Nov-2005  Created function GET_INV_SPEC_OR_VR_ID() for bug# 4538523 |
--|                                                                          |
--+==========================================================================+
-- End of comments


--Start of comments
--+========================================================================+
--| API Name    : find_inventory_spec                                      |
--| TYPE        : Group                                                    |
--| Notes       : This function RETURN TRUE if matching inventory          |
--|               spec. is found else it RETURN FALSE.                     |
--|               If matching inventory spec is found,then                 |
--|               it returns matching spec_id  and spec_vr_id              |
--| Calling Program : - Samples form			   		                   |
--|                   - Subscriber for the Receiving Event(if              |
--|                     matching supplier spec is not found) (Workflow)    |
--|                   -	Inventory Transaction Event                        |
--|                   - Lot Expiration Transcation Event                   |
--|                   - Lot Retest Transcation Event                       |
--| HISTORY                                                                |
--|    Mahesh Chandak	6-Aug-2002	Created.                               |
--|    Brenda Stone     1-Mar-2004  Bug 3473559; Added Hints for spec_id   |
--| Saikiran Vankadari 15-Feb-2005  Made Converegence related changes.     |
--|          Added organization_id, subinventory, locator_id and lot_number|
--+========================================================================+
-- End of comments

FUNCTION FIND_INVENTORY_SPEC(p_inventory_spec_rec IN  inventory_spec_rec_type,
			     x_spec_id 	  	  OUT NOCOPY NUMBER,
			     x_spec_vr_id	  OUT NOCOPY NUMBER,
			     x_return_status	  OUT NOCOPY VARCHAR2,
			     x_message_data   	  OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN IS

l_position   		VARCHAR2(3);
l_grade_ctl			VARCHAR2(1);
l_item_default_grade_code	MTL_SYSTEM_ITEMS_B.DEFAULT_GRADE%TYPE ;
l_check_for_given_grade 	VARCHAR2(1) := 'N';
l_check_for_null_grade  	VARCHAR2(1) := 'N';
l_check_for_default_grade	VARCHAR2(1) := 'N';

REQ_FIELDS_MISSING 	EXCEPTION;
INVALID_LOT 		EXCEPTION;
INVALID_ITEM		EXCEPTION;

/*  Bug 3473559; Added Hint for spec_id   */

CURSOR cr_match_spec IS
SELECT /*+ INDEX ( b GMD_INVENTORY_SPEC_VRS_N1 ) */
    a.spec_id,b.spec_vr_id,a.grade_code,revision,decode(a.grade_code,
    p_inventory_spec_rec.grade_code,1,2),
    b.locator_id,b.subinventory,b.parent_lot_number,b.lot_number,
    b.organization_id
FROM gmd_specifications_b a,gmd_inventory_spec_vrs b
WHERE
     a.inventory_item_id = p_inventory_spec_rec.inventory_item_id
AND ((p_inventory_spec_rec.revision = a.revision) OR ( p_inventory_spec_rec.revision IS NULL AND a.revision IS NULL)
     OR (p_inventory_spec_rec.revision IS NOT NULL AND a.revision IS NULL ))
AND ((a.spec_status between  400 and 499) OR (a.spec_status between  700 and 799) OR (a.spec_status between  900 and 999))
AND  a.delete_mark = 0
AND ((l_check_for_given_grade = 'Y' and p_inventory_spec_rec.grade_code = a.grade_code ) OR (l_check_for_null_grade = 'Y' AND a.grade_code IS NULL )
      OR (l_check_for_default_grade = 'Y' AND a.grade_code = l_item_default_grade_code))
AND  a.spec_id = b.spec_id
AND ((b.spec_vr_status between  400 and 499) OR (b.spec_vr_status between  700 and 799) OR (b.spec_vr_status between  900 and 999))
AND  b.delete_mark = 0
AND  p_inventory_spec_rec.date_effective between b.start_date and nvl(b.end_date,p_inventory_spec_rec.date_effective)
AND ((p_inventory_spec_rec.locator_id = b.locator_id) OR ( p_inventory_spec_rec.locator_id IS NULL AND b.locator_id IS NULL)
     OR (p_inventory_spec_rec.locator_id IS NOT NULL AND b.locator_id IS NULL ))
AND ((p_inventory_spec_rec.subinventory = b.subinventory) OR ( p_inventory_spec_rec.subinventory IS NULL AND b.subinventory IS NULL)
     OR (p_inventory_spec_rec.subinventory IS NOT NULL AND b.subinventory IS NULL ))
AND ((p_inventory_spec_rec.parent_lot_number = b.parent_lot_number) OR ( p_inventory_spec_rec.parent_lot_number IS NULL AND b.parent_lot_number IS NULL)
     OR (p_inventory_spec_rec.parent_lot_number IS NOT NULL AND b.parent_lot_number IS NULL ))
AND ((p_inventory_spec_rec.lot_number = b.lot_number) OR ( p_inventory_spec_rec.lot_number IS NULL AND b.lot_number IS NULL)
     OR (p_inventory_spec_rec.lot_number IS NOT NULL AND b.lot_number IS NULL ))
AND ((p_inventory_spec_rec.organization_id = b.organization_id)
     OR (p_inventory_spec_rec.organization_id IS NOT NULL AND b.organization_id IS NULL ))
ORDER BY decode(a.grade_code,p_inventory_spec_rec.grade_code,1,2),b.lot_number,b.location,b.subinventory,b.organization_id ;

-- Production team requirement to look for a specific test in a spec.
CURSOR cr_match_spec_test IS
SELECT a.spec_id,b.spec_vr_id,a.grade_code,revision,decode(a.grade_code,
    p_inventory_spec_rec.grade_code,1,2),
    b.locator_id,b.subinventory,b.parent_lot_number,b.lot_number,
    b.organization_id
FROM gmd_specifications_b a,gmd_inventory_spec_vrs b , gmd_spec_tests_b c
WHERE
     a.inventory_item_id = p_inventory_spec_rec.inventory_item_id
AND ((p_inventory_spec_rec.revision = a.revision) OR ( p_inventory_spec_rec.revision IS NULL AND a.revision IS NULL)
     OR (p_inventory_spec_rec.revision IS NOT NULL AND a.revision IS NULL ))
AND ((a.spec_status between  400 and 499) OR (a.spec_status between  700 and 799) OR (a.spec_status between  900 and 999))
AND  a.delete_mark = 0
AND ((l_check_for_given_grade = 'Y' and p_inventory_spec_rec.grade_code = a.grade_code ) OR (l_check_for_null_grade = 'Y' AND a.grade_code IS NULL )
      OR (l_check_for_default_grade = 'Y' AND a.grade_code = l_item_default_grade_code))
AND  a.spec_id = c.spec_id
AND  c.test_id = p_inventory_spec_rec.test_id
AND  a.spec_id = b.spec_id
AND ((b.spec_vr_status between  400 and 499) OR (b.spec_vr_status between  700 and 799) OR (b.spec_vr_status between  900 and 999))
AND  b.delete_mark = 0
AND  p_inventory_spec_rec.date_effective between b.start_date and nvl(b.end_date,p_inventory_spec_rec.date_effective)
AND ((p_inventory_spec_rec.locator_id = b.locator_id) OR ( p_inventory_spec_rec.locator_id IS NULL AND b.locator_id IS NULL)
     OR (p_inventory_spec_rec.locator_id IS NOT NULL AND b.locator_id IS NULL ))
AND ((p_inventory_spec_rec.subinventory = b.subinventory) OR ( p_inventory_spec_rec.subinventory IS NULL AND b.subinventory IS NULL)
     OR (p_inventory_spec_rec.subinventory IS NOT NULL AND b.subinventory IS NULL ))
AND ((p_inventory_spec_rec.parent_lot_number = b.parent_lot_number) OR ( p_inventory_spec_rec.parent_lot_number IS NULL AND b.parent_lot_number IS NULL)
     OR (p_inventory_spec_rec.parent_lot_number IS NOT NULL AND b.parent_lot_number IS NULL ))
AND ((p_inventory_spec_rec.lot_number = b.lot_number) OR ( p_inventory_spec_rec.lot_number IS NULL AND b.lot_number IS NULL)
     OR (p_inventory_spec_rec.lot_number IS NOT NULL AND b.lot_number IS NULL ))
AND ((p_inventory_spec_rec.organization_id = b.organization_id) OR ( p_inventory_spec_rec.organization_id IS NULL AND b.organization_id IS NULL)
     OR (p_inventory_spec_rec.organization_id IS NOT NULL AND b.organization_id IS NULL ))
ORDER BY decode(a.grade_code,p_inventory_spec_rec.grade_code,1,2),b.lot_number,b.locator_id,b.subinventory,b.organization_id ;

l_match_spec_rec   cr_match_spec%ROWTYPE;

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  FND_MSG_PUB.initialize;
  l_position := '010';

  IF p_inventory_spec_rec.inventory_item_id IS NULL OR p_inventory_spec_rec.organization_id IS NULL
     OR p_inventory_spec_rec.date_effective IS NULL THEN
       RAISE REQ_FIELDS_MISSING;
  END IF;


  IF p_inventory_spec_rec.grade_code IS NULL THEN
    BEGIN
       SELECT grade_control_flag, default_grade INTO  l_grade_ctl ,l_item_default_grade_code
       FROM   mtl_system_items_b
       WHERE  inventory_item_id = p_inventory_spec_rec.inventory_item_id
       AND organization_id = p_inventory_spec_rec.organization_id;

       IF l_grade_ctl = 'N' THEN
       	  l_check_for_null_grade 	:= 'Y';
       ELSE
 -- if item is grade ctl and grade is not passed, check for null grade and item's default grade in that order.
          l_check_for_null_grade 	:= 'Y';
          l_check_for_default_grade 	:= 'Y';
       END IF;

    EXCEPTION WHEN OTHERS THEN
       RAISE INVALID_ITEM;
    END ;
  ELSE
    l_grade_ctl := 'Y';
    l_check_for_given_grade := 'Y';
    l_check_for_null_grade  := 'Y';
  END IF;

  l_position := '020';

  IF p_inventory_spec_rec.test_id IS NULL THEN

  	OPEN  cr_match_spec;
  	FETCH cr_match_spec INTO l_match_spec_rec ;
  	IF cr_match_spec%NOTFOUND THEN
     		CLOSE cr_match_spec;
     		RETURN FALSE;
  	END IF;
  	CLOSE cr_match_spec;
  ELSE

  	OPEN  cr_match_spec_test;
  	FETCH cr_match_spec_test INTO l_match_spec_rec ;
  	IF cr_match_spec_test%NOTFOUND THEN
     		CLOSE cr_match_spec_test;
     		RETURN FALSE;
  	END IF;
  	CLOSE cr_match_spec_test;
  END IF;

  l_position := '030';

  IF p_inventory_spec_rec.exact_match = 'Y' THEN
      IF ((p_inventory_spec_rec.revision = l_match_spec_rec.revision)
           OR ( p_inventory_spec_rec.revision IS NULL AND l_match_spec_rec.revision IS NULL))
        AND (( p_inventory_spec_rec.grade_code = l_match_spec_rec.grade_code)
      	   OR ( p_inventory_spec_rec.grade_code IS NULL AND l_match_spec_rec.grade_code IS NULL))
    	AND
      	   (( p_inventory_spec_rec.organization_id = l_match_spec_rec.organization_id)
      	   OR ( p_inventory_spec_rec.organization_id IS NULL AND l_match_spec_rec.organization_id IS NULL))
      	AND
      	   (( p_inventory_spec_rec.parent_lot_number = l_match_spec_rec.parent_lot_number)
      	   OR ( p_inventory_spec_rec.parent_lot_number IS NULL AND l_match_spec_rec.parent_lot_number IS NULL))
      	AND
      	   (( p_inventory_spec_rec.lot_number = l_match_spec_rec.lot_number)
      	   OR ( p_inventory_spec_rec.lot_number IS NULL AND l_match_spec_rec.lot_number IS NULL))
      	AND
      	   (( p_inventory_spec_rec.subinventory = l_match_spec_rec.subinventory)
      	   OR ( p_inventory_spec_rec.subinventory IS NULL AND l_match_spec_rec.subinventory IS NULL))
      	AND
      	   (( p_inventory_spec_rec.locator_id = l_match_spec_rec.locator_id)
      	   OR ( p_inventory_spec_rec.locator_id IS NULL AND l_match_spec_rec.locator_id IS NULL))
      	THEN
      	   x_spec_id 	:= l_match_spec_rec.spec_id ;
      	   x_spec_vr_id := l_match_spec_rec.spec_vr_id ;
           RETURN TRUE;
      ELSE
           RETURN FALSE;
      END IF;
  ELSE
      x_spec_id    := l_match_spec_rec.spec_id ;
      x_spec_vr_id := l_match_spec_rec.spec_vr_id ;
      RETURN TRUE;
  END IF;

EXCEPTION
WHEN REQ_FIELDS_MISSING THEN
   gmd_api_pub.log_message('GMD_REQ_FIELD_MIS','PACKAGE','GMD_SPEC_MATCH_GRP.FIND_INVENTORY_SPEC');
   x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
   x_return_status := FND_API.G_RET_STS_ERROR ;
   RETURN FALSE;
WHEN INVALID_LOT THEN
   gmd_api_pub.log_message('GMD_INVALID_LOT','LOT',to_char(p_inventory_spec_rec.lot_number));
   x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
   x_return_status := FND_API.G_RET_STS_ERROR ;
   RETURN FALSE;
WHEN INVALID_ITEM THEN
   gmd_api_pub.log_message('GMD_INVALID_ITEM','ITEM',to_char(p_inventory_spec_rec.inventory_item_id));
   x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
   x_return_status := FND_API.G_RET_STS_ERROR ;
   RETURN FALSE;
WHEN OTHERS THEN
   gmd_api_pub.log_message('GMD_API_ERROR','PACKAGE','GMD_SPEC_MATCH_GRP.FIND_INVENTORY_SPEC','ERROR', SUBSTR(SQLERRM,1,100),'POSITION',l_position);
   x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
   RETURN FALSE;
END FIND_INVENTORY_SPEC;


--Start of comments
--+========================================================================+
--| API Name    : find_customer_spec                                       |
--| TYPE        : Group                                                    |
--| Notes       : This function RETURN TRUE if matching customer           |
--|               spec. is found else it RETURN FALSE.                     |
--|               If matching customer spec is found,then                  |
--|               it returns matching spec_id  and spec_vr_id              |
--| Calling Program : -  Samples form			   		                   |
--|                   -  Spec matching in Order Management(Pick lots form) |
--|                   -  Shipment screen in OM (in Future )		           |
--| HISTORY                                                                |
--|    Mahesh Chandak	6-Aug-2002	Created.                               |
--|    Brenda Stone     1-Mar-2004  Bug 3473559; Added Hints for spec_id   |
--| Saikiran Vankadari 15-Feb-2005  Made Converegence related changes.     |
--|                                 Removed ORGN_CODE. Changed the logic   |
--|                                 for usage of grade in spec matching    |
--+========================================================================+
-- End of comments

-- item_id, cust_id,date_effective are required.
-- either orgn_code or whse_code must be present.
-- Pick lot screen and Samples will pass order_line_id(if exists) and not line_number.
-- set look_in_other_orgn = 'Y' when calling from pick lots screen else set to 'N'
-- when calling from samples screen.
-- date_effective - from pick lots screen would be shipment date.
                  -- from sample screen, sample creation date.
-- order_line_id(if it exists) will be passed from Pick lot and Samples screen.They won't pass order_line
-- End of comments

FUNCTION FIND_CUSTOMER_SPEC(p_customer_spec_rec IN  customer_spec_rec_type,
		     	    x_spec_id 	  	OUT NOCOPY NUMBER,
			    x_spec_vr_id	OUT NOCOPY NUMBER,
			    x_return_status	OUT NOCOPY VARCHAR2,
			    x_message_data   	OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN IS

l_position   VARCHAR2(3);
l_order_line_number NUMBER;
l_check_for_given_grade 	VARCHAR2(1) := 'N';
l_check_for_null_grade  	VARCHAR2(1) := 'N';

REQ_FIELDS_MISSING 	EXCEPTION;
INVALID_ORDER_LINE 	EXCEPTION;
INVALID_ITEM		EXCEPTION;

/*  Bug 3473559; Added Hint for spec_id   */

CURSOR cr_match_spec IS
SELECT /*+  INDEX (b gmd_customer_spec_vrs_n1 )    */
     a.spec_id,b.spec_vr_id,a.revision,a.grade_code ,DECODE(a.grade_code,p_customer_spec_rec.grade_code,1,2) grade_order_by,
     b.order_line_id,b.order_line,b.order_id,b.ship_to_site_id,b.org_id
FROM gmd_specifications_b a,gmd_customer_spec_vrs b
WHERE
     a.inventory_item_id = p_customer_spec_rec.inventory_item_id
AND ((p_customer_spec_rec.revision = a.revision) OR ( p_customer_spec_rec.revision IS NULL AND a.revision IS NULL)
     OR (p_customer_spec_rec.revision IS NOT NULL AND a.revision IS NULL ))
AND ((a.spec_status between  700 and 799) OR (a.spec_status between  900 and 999))
AND  a.delete_mark = 0
AND ((l_check_for_given_grade = 'Y' and p_customer_spec_rec.grade_code = a.grade_code ) OR (l_check_for_null_grade = 'Y' AND a.grade_code IS NULL ))
AND  a.spec_id = b.spec_id
AND ((b.spec_vr_status between  700 and 799) OR (b.spec_vr_status between  900 and 999))
AND  b.delete_mark = 0
AND  b.cust_id = p_customer_spec_rec.cust_id
AND  p_customer_spec_rec.date_effective between b.start_date and nvl(b.end_date,p_customer_spec_rec.date_effective + 1)
AND ((p_customer_spec_rec.organization_id = b.organization_id) OR ( p_customer_spec_rec.organization_id IS NULL AND b.organization_id IS NULL)
     OR (p_customer_spec_rec.organization_id IS NOT NULL AND b.organization_id IS NULL ))
AND ((p_customer_spec_rec.org_id = b.org_id) OR ( p_customer_spec_rec.org_id IS NULL AND b.org_id IS NULL)
     OR (p_customer_spec_rec.org_id IS NOT NULL AND b.org_id IS NULL ))
AND ((p_customer_spec_rec.ship_to_site_id = b.ship_to_site_id) OR ( p_customer_spec_rec.ship_to_site_id IS NULL AND b.ship_to_site_id IS NULL)
     OR (p_customer_spec_rec.ship_to_site_id IS NOT NULL AND b.ship_to_site_id IS NULL ))
AND ((p_customer_spec_rec.order_id = b.order_id) OR ( p_customer_spec_rec.order_id IS NULL AND b.order_id IS NULL)
     OR (p_customer_spec_rec.order_id IS NOT NULL AND b.order_id IS NULL ))
AND ((l_order_line_number = b.order_line) OR ( l_order_line_number IS NULL AND b.order_line IS NULL)
     OR (l_order_line_number IS NOT NULL AND b.order_line IS NULL ))
ORDER BY grade_order_by,b.order_line_id,b.order_line,b.order_id,b.ship_to_site_id,b.org_id;

--bug# 2982799
--compare only the order line number. not the line id.remove the order_line_id CLAUSE.

l_match_spec_rec   cr_match_spec%ROWTYPE;

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  FND_MSG_PUB.initialize;
  l_position := '010';

  IF p_customer_spec_rec.inventory_item_id IS NULL OR p_customer_spec_rec.organization_id IS NULL
     OR p_customer_spec_rec.cust_id IS NULL OR p_customer_spec_rec.date_effective IS NULL THEN
       RAISE REQ_FIELDS_MISSING;
  END IF;

  --bug# 2982799
  --compare only the order line number. not the line id.
  --Validity rule form stores the line number only till 1.1(line_number + shipment_number/10)
  --In Samples form user enters complete line number (it could be 1.1 and if it is split it could be 1.1.1)
  --But while passing,sample will pass as 1.1 Also line_id is passed from sample form.
  --Pick lot screen always passes the line_id. We would derive the line number from the line_id in the format d.d
  --While matching the spec, we would ignore the order_line_id.


  -- get the line_number for the order_line_id
  IF p_customer_spec_rec.order_line IS NULL THEN
     IF p_customer_spec_rec.order_line_id IS NOT NULL THEN
        BEGIN
           SELECT line_number + (shipment_number/10) INTO l_order_line_number
           FROM OE_ORDER_LINES_ALL
           WHERE  line_id  =  p_customer_spec_rec.order_line_id ;
        EXCEPTION
        WHEN OTHERS THEN
          RAISE INVALID_ORDER_LINE;
        END;
     END IF;
  ELSE
     l_order_line_number := p_customer_spec_rec.order_line ;
  END IF;

  IF p_customer_spec_rec.grade_code IS NULL THEN
    l_check_for_null_grade 	:= 'Y';
  ELSE
    l_check_for_given_grade := 'Y';
    l_check_for_null_grade  := 'Y';
  END IF;

  l_position := '020';

  OPEN  cr_match_spec;
  FETCH cr_match_spec INTO l_match_spec_rec ;
  IF cr_match_spec%NOTFOUND THEN
     CLOSE cr_match_spec;
     RETURN FALSE;
  END IF;
  CLOSE cr_match_spec;

-- no need to compare order_line_no. Compare just the order_line_id. Line_no is not passed by the calling program.
  IF p_customer_spec_rec.exact_match = 'Y' THEN
     IF ((p_customer_spec_rec.revision = l_match_spec_rec.revision)
           OR ( p_customer_spec_rec.revision IS NULL AND l_match_spec_rec.revision IS NULL))
        AND (( p_customer_spec_rec.grade_code = l_match_spec_rec.grade_code)
      	   OR ( p_customer_spec_rec.grade_code IS NULL AND l_match_spec_rec.grade_code IS NULL))
    	AND
      	   (( p_customer_spec_rec.order_line_id = l_match_spec_rec.order_line_id)
      	   OR ( p_customer_spec_rec.order_line_id IS NULL AND l_match_spec_rec.order_line_id IS NULL))
      	AND
      	   (( p_customer_spec_rec.order_id = l_match_spec_rec.order_id)
      	   OR ( p_customer_spec_rec.order_id IS NULL AND l_match_spec_rec.order_id IS NULL))
      	AND
      	   (( p_customer_spec_rec.ship_to_site_id = l_match_spec_rec.ship_to_site_id)
      	   OR ( p_customer_spec_rec.ship_to_site_id IS NULL AND l_match_spec_rec.ship_to_site_id IS NULL))
      	AND
      	   (( p_customer_spec_rec.org_id = l_match_spec_rec.org_id)
      	   OR ( p_customer_spec_rec.org_id IS NULL AND l_match_spec_rec.org_id IS NULL))
     THEN
        x_spec_id 	:= l_match_spec_rec.spec_id ;
        x_spec_vr_id 	:= l_match_spec_rec.spec_vr_id ;
        RETURN TRUE;
     ELSE
        RETURN FALSE;
     END IF;
  ELSE
      x_spec_id    := l_match_spec_rec.spec_id ;
      x_spec_vr_id := l_match_spec_rec.spec_vr_id ;
      RETURN TRUE;
  END IF;


EXCEPTION
WHEN REQ_FIELDS_MISSING THEN
   gmd_api_pub.log_message('GMD_REQ_FIELD_MIS','PACKAGE','GMD_SPEC_MATCH_GRP.FIND_CUSTOMER_SPEC');
   x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
   x_return_status := FND_API.G_RET_STS_ERROR ;
   RETURN FALSE;
WHEN INVALID_ORDER_LINE THEN
   gmd_api_pub.log_message('GMD_INVALID_ORDER_LINE','LINE',to_char(p_customer_spec_rec.order_line_id));
   x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
   x_return_status := FND_API.G_RET_STS_ERROR ;
   RETURN FALSE;
WHEN INVALID_ITEM THEN
   gmd_api_pub.log_message('GMD_INVALID_ITEM','ITEM',to_char(p_customer_spec_rec.inventory_item_id));
   x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
   x_return_status := FND_API.G_RET_STS_ERROR ;
   RETURN FALSE;
WHEN OTHERS THEN
   gmd_api_pub.log_message('GMD_API_ERROR','PACKAGE','GMD_SPEC_MATCH_GRP.FIND_CUSTOMER_SPEC','ERROR', SUBSTR(SQLERRM,1,100),'POSITION',l_position);
   x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
   RETURN FALSE;
END FIND_CUSTOMER_SPEC;

FUNCTION FIND_CUST_OR_INV_SPEC(
			    p_customer_spec_rec IN  customer_spec_rec_type,
		     	    x_spec_id 	  	OUT NOCOPY NUMBER,
			    x_spec_vr_id	OUT NOCOPY NUMBER,
			    x_spec_type		OUT NOCOPY VARCHAR2,
			    x_return_status	OUT NOCOPY VARCHAR2,
			    x_message_data   	OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN IS

l_position 	VARCHAR2(3);
l_inventory_spec_rec_type	inventory_spec_rec_type ;

BEGIN
   l_position := '010';
   IF FIND_CUSTOMER_SPEC(p_customer_spec_rec 	=> p_customer_spec_rec,
		     	 x_spec_id 	  	=> x_spec_id,
			 x_spec_vr_id	  	=> x_spec_vr_id,
			 x_return_status	=> x_return_status,
			 x_message_data   	=> x_message_data ) THEN
      x_spec_type := 'C';
      RETURN TRUE;
   ELSIF x_return_status <> 'S' THEN
      RETURN FALSE;
   END IF;

   l_position := '020';

   IF NVL(p_customer_spec_rec.exact_match,'N') = 'N' THEN
      l_inventory_spec_rec_type.inventory_item_id    :=  p_customer_spec_rec.inventory_item_id ;
      l_inventory_spec_rec_type.revision             :=  p_customer_spec_rec.revision ;
      l_inventory_spec_rec_type.organization_id      :=  p_customer_spec_rec.organization_id ;
      l_inventory_spec_rec_type.subinventory         :=  p_customer_spec_rec.subinventory ;
      l_inventory_spec_rec_type.grade_code           :=  p_customer_spec_rec.grade_code;
      l_inventory_spec_rec_type.parent_lot_number  	 :=  p_customer_spec_rec.parent_lot_number;
      l_inventory_spec_rec_type.lot_number  	 :=  p_customer_spec_rec.lot_number;
      l_inventory_spec_rec_type.date_effective   :=  p_customer_spec_rec.date_effective  ;
      l_inventory_spec_rec_type.exact_match	 :=  p_customer_spec_rec.exact_match	 ;

      l_position := '030';

      IF FIND_INVENTORY_SPEC(p_inventory_spec_rec => l_inventory_spec_rec_type,
			     x_spec_id 	  	=> x_spec_id,
			     x_spec_vr_id	=> x_spec_vr_id,
			     x_return_status	=> x_return_status,
			     x_message_data   	=> x_message_data ) THEN
	  x_spec_type := 'I';
          RETURN TRUE;
      ELSE
          RETURN FALSE;
      END IF;
   ELSE
      RETURN FALSE;
   END IF;

EXCEPTION WHEN OTHERS THEN
   gmd_api_pub.log_message('GMD_API_ERROR','PACKAGE','GMD_SPEC_MATCH_GRP.FIND_CUST_OR_INV_SPEC','ERROR', SUBSTR(SQLERRM,1,100),'POSITION',l_position);
   x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
   RETURN FALSE;
END FIND_CUST_OR_INV_SPEC ;



--Start of comments
--+========================================================================+
--| API Name    : find_wip_spec                                            |
--| TYPE        : Group                                                    |
--| Notes       : This function RETURN TRUE if matching WIP                |
--|               spec. is found else it RETURN FALSE.                     |
--|               If matching WIP spec is found,then                       |
--|               it returns matching spec_id  and spec_vr_id              |
--| HISTORY                                                                |
--|    Mahesh Chandak	6-Aug-2002	Created.                               |
--|    Brenda Stone     1-Mar-2004  Bug 3473559; Added Hints for spec_id   |
--| Saikiran Vankadari 15-Feb-2005  Made Converegence related changes.     |
--|                        Added organization_id in place of orgn_code     |
--|                                                                        |
--|    Calling Program : -  Samples form			                	   |
--|                      -  Batch Creation                                 |
--+========================================================================+
-- End of comments

FUNCTION FIND_WIP_SPEC(p_wip_spec_rec  	IN  wip_spec_rec_type,
		       x_spec_id       	OUT NOCOPY NUMBER,
		       x_spec_vr_id    	OUT NOCOPY NUMBER,
		       x_return_status	OUT NOCOPY VARCHAR2,
		       x_message_data   OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN IS


l_position   			VARCHAR2(3);
l_grade_ctl			VARCHAR2(1) ;
l_item_default_grade_code		MTL_SYSTEM_ITEMS_B.DEFAULT_GRADE%TYPE ;
l_check_for_given_grade 	VARCHAR2(1) := 'N';
l_check_for_null_grade  	VARCHAR2(1) := 'N';
l_check_for_default_grade	VARCHAR2(1) := 'N';
l_recipe_no			GMD_RECIPES_B.recipe_no%TYPE;
l_formula_no			FM_FORM_MST_B.formula_no%TYPE;
l_routing_no			GMD_ROUTINGS_B.routing_no%TYPE;
l_oprn_no			GMD_OPERATIONS_B.oprn_no%TYPE;
l_recipe_version		GMD_RECIPES_B.recipe_version%TYPE;
l_formula_vers			FM_FORM_MST_B.formula_vers%TYPE;
l_routing_vers			GMD_ROUTINGS_B.routing_vers%TYPE;
l_oprn_vers			GMD_OPERATIONS_B.oprn_vers%TYPE;
l_step_no			NUMBER(10);

REQ_FIELDS_MISSING 	EXCEPTION;
INVALID_ITEM 		EXCEPTION;
INVALID_RECIPE 		EXCEPTION;
INVALID_FORMULA		EXCEPTION;
INVALID_OPRN	 	EXCEPTION;
INVALID_ROUTING		EXCEPTION;
INVALID_STEP		EXCEPTION;

-- Bug 3473559; Added Hint for spec_id
-- Bug 4640143; Added material_detail_id
CURSOR cr_match_spec IS
SELECT                          /*+  INDEX ( b gmd_wip_spec_vrs_n1 )  */
    a.spec_id,
    b.spec_vr_id,
    a.revision,
    a.grade_code,
    DECODE(a.grade_code,p_wip_spec_rec.grade_code,1,2) grade_order_by,
    b.charge,
    b.step_no,
    b.routing_vers,
    b.routing_no,
    b.formulaline_id,
    b.material_detail_id,
    b.formula_vers,
    b.formula_no,
    b.recipe_version,
    b.recipe_no,
    b.batch_id,
    b.oprn_vers,
    b.oprn_no,
    b.organization_id
FROM gmd_specifications_b a,
     gmd_wip_spec_vrs b
WHERE
     a.inventory_item_id = p_wip_spec_rec.inventory_item_id
AND ((p_wip_spec_rec.revision = a.revision)
     OR ( p_wip_spec_rec.revision IS NULL AND a.revision IS NULL)
     OR (p_wip_spec_rec.revision IS NOT NULL AND a.revision IS NULL ))
AND ((a.spec_status between  400 and 499)
     OR (a.spec_status between  700 and 799)
     OR (a.spec_status between  900 and 999))
AND  a.delete_mark = 0
AND ((l_check_for_given_grade = 'Y' and p_wip_spec_rec.grade_code = a.grade_code )
     OR (l_check_for_null_grade = 'Y' AND a.grade_code IS NULL )
      OR (l_check_for_default_grade = 'Y' AND a.grade_code = l_item_default_grade_code))
AND  a.spec_id = b.spec_id
AND ((b.spec_vr_status between  400 and 499)
     OR (b.spec_vr_status between  700 and 799)
     OR (b.spec_vr_status between  900 and 999))
AND  b.delete_mark = 0
AND  p_wip_spec_rec.date_effective between b.start_date and nvl(b.end_date,p_wip_spec_rec.date_effective)
AND (p_wip_spec_rec.organization_id = NVL(b.organization_id,p_wip_spec_rec.organization_id))
AND ((p_wip_spec_rec.batch_id = b.batch_id)
     OR ( p_wip_spec_rec.batch_id IS NULL AND b.batch_id IS NULL)
     OR (p_wip_spec_rec.batch_id IS NOT NULL AND b.batch_id IS NULL ))
AND ((l_formula_no = b.formula_no)
     OR ( l_formula_no IS NULL AND b.formula_no IS NULL)
     OR (l_formula_no IS NOT NULL AND b.formula_no IS NULL ))
AND ((l_formula_vers = b.formula_vers)
     OR ( l_formula_vers IS NULL AND b.formula_vers IS NULL)
     OR (l_formula_vers IS NOT NULL AND b.formula_vers IS NULL ))
AND ((l_recipe_no = b.recipe_no)
     OR ( l_recipe_no IS NULL AND b.recipe_no IS NULL)
     OR (l_recipe_no IS NOT NULL AND b.recipe_no IS NULL ))
AND ((l_recipe_version = b.recipe_version)
     OR ( l_recipe_version IS NULL AND b.recipe_version IS NULL)
     OR (l_recipe_version IS NOT NULL AND b.recipe_version IS NULL ))
AND ((p_wip_spec_rec.charge = b.charge)
     OR ( p_wip_spec_rec.charge IS NULL AND b.charge IS NULL)
     OR (p_wip_spec_rec.charge IS NOT NULL AND b.charge IS NULL ))
AND ((l_step_no = b.step_no)
     OR (l_step_no IS NULL AND b.step_no IS NULL)
     OR (nvl(p_wip_spec_rec.find_spec_with_step,'N') = 'N' and l_step_no IS NOT NULL AND b.step_no IS NULL ))
AND ((l_routing_no = b.routing_no)
     OR ( l_routing_no IS NULL AND b.routing_no IS NULL)
     OR (l_routing_no IS NOT NULL AND b.routing_no IS NULL ))
AND ((l_routing_vers = b.routing_vers)
     OR ( l_routing_vers IS NULL AND b.routing_vers IS NULL)
     OR (l_routing_vers IS NOT NULL AND b.routing_vers IS NULL ))
AND ((p_wip_spec_rec.formulaline_id = b.formulaline_id)
     OR ( p_wip_spec_rec.formulaline_id IS NULL AND b.formulaline_id IS NULL)
     OR (p_wip_spec_rec.formulaline_id IS NOT NULL AND b.formulaline_id IS NULL )
     OR (p_wip_spec_rec.batch_id IS NOT NULL ))
AND ((p_wip_spec_rec.material_detail_id = b.material_detail_id)
     OR ( p_wip_spec_rec.material_detail_id IS NULL AND b.material_detail_id IS NULL)
     OR (p_wip_spec_rec.material_detail_id IS NOT NULL AND b.material_detail_id IS NULL ))
AND ((l_oprn_no = b.oprn_no)
     OR ( l_oprn_no IS NULL AND b.oprn_no IS NULL)
     OR (l_oprn_no IS NOT NULL AND b.oprn_no IS NULL ))
AND ((l_oprn_vers = b.oprn_vers)
     OR ( l_oprn_vers IS NULL AND b.oprn_vers IS NULL)
     OR (l_oprn_vers IS NOT NULL AND b.oprn_vers IS NULL ))
ORDER BY grade_order_by, b.charge, b.step_no, b.routing_id, b.routing_no, b.material_detail_id,
         b.formulaline_id, b.formula_id, b.formula_no, b.recipe_id, b.recipe_no, b.batch_id, b.oprn_id,
         b.oprn_no, b.organization_id ;

l_match_spec_rec   cr_match_spec%ROWTYPE;

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  FND_MSG_PUB.initialize;
  l_position := '010';

  IF p_wip_spec_rec.inventory_item_id IS NULL OR p_wip_spec_rec.organization_id IS NULL OR p_wip_spec_rec.date_effective IS NULL THEN
       RAISE REQ_FIELDS_MISSING;
  END IF;

  IF p_wip_spec_rec.recipe_id IS NOT NULL AND p_wip_spec_rec.recipe_no IS NULL AND p_wip_spec_rec.recipe_version IS NULL THEN
  BEGIN
     SELECT recipe_no,recipe_version INTO l_recipe_no,l_recipe_version
     FROM   GMD_RECIPES_B
     WHERE  recipe_id = p_wip_spec_rec.recipe_id ;

     EXCEPTION
     WHEN OTHERS THEN
        RAISE INVALID_RECIPE;
     END;
  ELSE
     l_recipe_no := p_wip_spec_rec.recipe_no;
     l_recipe_version := p_wip_spec_rec.recipe_version;
  END IF;

  IF p_wip_spec_rec.formula_id IS NOT NULL AND p_wip_spec_rec.formula_no IS NULL AND p_wip_spec_rec.formula_vers IS NULL THEN
  BEGIN
     SELECT formula_no,formula_vers INTO l_formula_no,l_formula_vers
     FROM   fm_form_mst_b
     WHERE  formula_id = p_wip_spec_rec.formula_id;

     EXCEPTION
     WHEN OTHERS THEN
        RAISE INVALID_FORMULA;
     END;
  ELSE
     l_formula_no := p_wip_spec_rec.formula_no;
     l_formula_vers := p_wip_spec_rec.formula_vers;
  END IF ;

  IF p_wip_spec_rec.routing_id IS NOT NULL AND p_wip_spec_rec.routing_no IS NULL AND p_wip_spec_rec.routing_vers IS NULL THEN
  BEGIN
     SELECT routing_no,routing_vers INTO l_routing_no,l_routing_vers
     FROM   gmd_routings_b
     WHERE  routing_id = p_wip_spec_rec.routing_id ;

     EXCEPTION
     WHEN OTHERS THEN
        RAISE INVALID_ROUTING;
     END;
  ELSE
     l_routing_no := p_wip_spec_rec.routing_no;
     l_routing_vers := p_wip_spec_rec.routing_vers;
  END IF ;

  IF p_wip_spec_rec.oprn_id IS NOT NULL AND p_wip_spec_rec.oprn_no IS NULL AND p_wip_spec_rec.oprn_vers IS NULL THEN
  BEGIN
     SELECT oprn_no,oprn_vers INTO l_oprn_no,l_oprn_vers
     FROM   gmd_operations_b
     WHERE  oprn_id = p_wip_spec_rec.oprn_id;

     EXCEPTION
     WHEN OTHERS THEN
        RAISE INVALID_OPRN;
     END;
  ELSE
     l_oprn_no := p_wip_spec_rec.oprn_no;
     l_oprn_vers := p_wip_spec_rec.oprn_vers;
  END IF;

  -- get step_no if step_id is passed instead of step_no.
  IF p_wip_spec_rec.step_id IS NOT NULL AND p_wip_spec_rec.step_no IS NULL THEN
    IF p_wip_spec_rec.batch_id IS NOT NULL THEN
      BEGIN
        SELECT BATCHSTEP_NO INTO l_step_no
     	FROM   gme_batch_steps
     	WHERE  batchstep_id = p_wip_spec_rec.step_id
     	AND    batch_id = p_wip_spec_rec.batch_id;


      EXCEPTION
      WHEN OTHERS THEN
         BEGIN
           SELECT ROUTINGSTEP_NO INTO l_step_no
     	   FROM   fm_rout_dtl
     	   WHERE  routingstep_id = p_wip_spec_rec.step_id
     	   AND    routing_id = p_wip_spec_rec.routing_id;

     	 EXCEPTION WHEN OTHERS THEN
     	   RAISE INVALID_STEP;
     	 END ;
      END;
    ELSIF p_wip_spec_rec.routing_id IS NOT NULL THEN
      BEGIN
      	SELECT ROUTINGSTEP_NO INTO l_step_no
     	FROM   fm_rout_dtl
     	WHERE  routingstep_id = p_wip_spec_rec.step_id
     	AND    routing_id = p_wip_spec_rec.routing_id ;

      EXCEPTION
      WHEN OTHERS THEN
         BEGIN
           SELECT BATCHSTEP_NO INTO l_step_no
     	   FROM   gme_batch_steps
     	   WHERE  batchstep_id = p_wip_spec_rec.step_id
     	   AND    batch_id = p_wip_spec_rec.batch_id;

     	 EXCEPTION WHEN OTHERS THEN
     	   RAISE INVALID_STEP;
     	 END ;
      END;
    ELSE
       RAISE INVALID_STEP; -- should have either batch or routing with the step.
    END IF;
  ELSE
     l_step_no   := p_wip_spec_rec.step_no;
  END IF;

--MCHANDAK bug# 2645698
-- created additional paramater find_spec_with_step which will be set to 'Y' when
-- calling from batch step creation workflow.Also changed the main select.

-- need to pass a step if one needs a WIP with step.
  IF p_wip_spec_rec.find_spec_with_step = 'Y' and l_step_no IS NULL THEN
     RAISE INVALID_STEP;
  END IF;

  l_position := '020';

  IF p_wip_spec_rec.grade_code IS NULL THEN
    BEGIN
       SELECT grade_control_flag, default_grade INTO  l_grade_ctl ,l_item_default_grade_code
       FROM   mtl_system_items_b
       WHERE  inventory_item_id = p_wip_spec_rec.inventory_item_id
       AND organization_id = p_wip_spec_rec.organization_id;

       IF l_grade_ctl = 'N' THEN
       	  l_check_for_null_grade 	:= 'Y';
       ELSE
 -- if item is grade ctl and grade is not passed, check for null grade and item's default grade in that order.
          l_check_for_null_grade 	:= 'Y';
          l_check_for_default_grade 	:= 'Y';
       END IF;

    EXCEPTION WHEN OTHERS THEN
       RAISE INVALID_ITEM;
    END ;
  ELSE
    l_grade_ctl := 'Y';
    l_check_for_given_grade := 'Y';
    l_check_for_null_grade  := 'Y';
  END IF;

  l_position := '030';

  OPEN  cr_match_spec;
  FETCH cr_match_spec INTO l_match_spec_rec ;
  IF cr_match_spec%NOTFOUND THEN
     CLOSE cr_match_spec;
     RETURN FALSE;
  END IF;
  CLOSE cr_match_spec;

  l_position := '040';

  IF p_wip_spec_rec.exact_match = 'Y' THEN
     IF ((p_wip_spec_rec.revision = l_match_spec_rec.revision)
           OR ( p_wip_spec_rec.revision IS NULL AND l_match_spec_rec.revision IS NULL))
        AND
          (( p_wip_spec_rec.grade_code = l_match_spec_rec.grade_code)
      	   OR ( p_wip_spec_rec.grade_code IS NULL AND l_match_spec_rec.grade_code IS NULL))
    	AND
      	   (( p_wip_spec_rec.batch_id = l_match_spec_rec.batch_id)
      	   OR ( p_wip_spec_rec.batch_id IS NULL AND l_match_spec_rec.batch_id IS NULL))
      	AND
      	   (( l_recipe_no = l_match_spec_rec.recipe_no)
      	   OR ( l_recipe_no IS NULL AND l_match_spec_rec.recipe_no IS NULL))
	    AND
      	   (( l_recipe_version = l_match_spec_rec.recipe_version)
      	   OR ( l_recipe_version IS NULL AND l_match_spec_rec.recipe_version IS NULL))
      	AND
      	   (( l_routing_no = l_match_spec_rec.routing_no)
      	   OR ( l_routing_no IS NULL AND l_match_spec_rec.routing_no IS NULL))
    	AND
      	   (( l_routing_vers = l_match_spec_rec.routing_vers)
      	   OR ( l_routing_vers IS NULL AND l_match_spec_rec.routing_vers IS NULL))
      	AND
      	   (( l_oprn_no = l_match_spec_rec.oprn_no)
      	   OR ( l_oprn_no IS NULL AND l_match_spec_rec.oprn_no IS NULL))
	    AND
      	   (( l_oprn_vers = l_match_spec_rec.oprn_vers)
      	   OR ( l_oprn_vers IS NULL AND l_match_spec_rec.oprn_vers IS NULL))
      	AND
      	   (( l_formula_no = l_match_spec_rec.formula_no)
      	   OR ( l_formula_no IS NULL AND l_match_spec_rec.formula_no IS NULL))
    	AND
      	   (( l_formula_vers = l_match_spec_rec.formula_vers)
      	   OR ( l_formula_vers IS NULL AND l_match_spec_rec.formula_vers IS NULL))
      	AND
      	   (( p_wip_spec_rec.formulaline_id = l_match_spec_rec.formulaline_id)
      	   OR ( p_wip_spec_rec.batch_id  IS NOT NULL)
      	   OR ( p_wip_spec_rec.formulaline_id IS NULL AND l_match_spec_rec.formulaline_id IS NULL))
      	AND
      	   (( p_wip_spec_rec.material_detail_id = l_match_spec_rec.material_detail_id)
      	   OR ( p_wip_spec_rec.material_detail_id IS NULL AND l_match_spec_rec.material_detail_id IS NULL))
      	AND
      	   (( l_step_no = l_match_spec_rec.step_no)
      	   OR ( l_step_no IS NULL AND l_match_spec_rec.step_no IS NULL))
      	AND
      	   (( p_wip_spec_rec.charge = l_match_spec_rec.charge)
      	   OR ( p_wip_spec_rec.charge IS NULL AND l_match_spec_rec.charge IS NULL))
	    AND (p_wip_spec_rec.organization_id = l_match_spec_rec.organization_id)
     THEN
        x_spec_id 	:= l_match_spec_rec.spec_id ;
        x_spec_vr_id 	:= l_match_spec_rec.spec_vr_id ;
        RETURN TRUE;
     ELSE
        RETURN FALSE;
     END IF;
  ELSE
      x_spec_id    := l_match_spec_rec.spec_id ;
      x_spec_vr_id := l_match_spec_rec.spec_vr_id ;
      RETURN TRUE;
  END IF;

EXCEPTION
WHEN REQ_FIELDS_MISSING THEN
   gmd_api_pub.log_message('GMD_REQ_FIELD_MIS','PACKAGE','GMD_SPEC_MATCH_GRP.FIND_WIP_SPEC');
   x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
   x_return_status := FND_API.G_RET_STS_ERROR ;
   RETURN FALSE;
WHEN INVALID_ITEM THEN
   gmd_api_pub.log_message('GMD_INVALID_ITEM','ITEM',to_char(p_wip_spec_rec.inventory_item_id));
   x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
   x_return_status := FND_API.G_RET_STS_ERROR ;
   RETURN FALSE;
WHEN INVALID_FORMULA THEN
   gmd_api_pub.log_message('GMD_INVALID_FORMULA','FORMULA',to_char(p_wip_spec_rec.formula_id));
   x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
   x_return_status := FND_API.G_RET_STS_ERROR ;
   RETURN FALSE;
WHEN INVALID_ROUTING THEN
   gmd_api_pub.log_message('GMD_INVALID_ROUTING','ROUTING',to_char(p_wip_spec_rec.routing_id));
   x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
   x_return_status := FND_API.G_RET_STS_ERROR ;
   RETURN FALSE;
WHEN INVALID_OPRN THEN
   gmd_api_pub.log_message('GMD_INVALID_OPRN','OPRN',to_char(p_wip_spec_rec.oprn_id));
   x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
   x_return_status := FND_API.G_RET_STS_ERROR ;
   RETURN FALSE;
WHEN INVALID_STEP THEN
   gmd_api_pub.log_message('GMD_INVALID_STEP','STEP',to_char(p_wip_spec_rec.step_id));
   x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
   x_return_status := FND_API.G_RET_STS_ERROR ;
   RETURN FALSE;
WHEN INVALID_RECIPE THEN
   gmd_api_pub.log_message('GMD_INVALID_RECIPE','RECIPE',to_char(p_wip_spec_rec.recipe_id));
   x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
   x_return_status := FND_API.G_RET_STS_ERROR ;
   RETURN FALSE;
WHEN OTHERS THEN
   gmd_api_pub.log_message('GMD_API_ERROR','PACKAGE','GMD_SPEC_MATCH_GRP.FIND_WIP_SPEC','ERROR', SUBSTR(SQLERRM,1,100),'POSITION',l_position);
   x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
   RETURN FALSE;
END FIND_WIP_SPEC;

FUNCTION FIND_WIP_OR_INV_SPEC(
		       p_wip_spec_rec  	IN  wip_spec_rec_type,
		       x_spec_id       	OUT NOCOPY NUMBER,
		       x_spec_vr_id    	OUT NOCOPY NUMBER,
		       x_spec_type	OUT NOCOPY VARCHAR2,
		       x_return_status	OUT NOCOPY VARCHAR2,
		       x_message_data   OUT NOCOPY VARCHAR2 )

RETURN BOOLEAN IS
l_inventory_spec_rec_type	inventory_spec_rec_type ;
l_position 	VARCHAR2(3);
BEGIN

   l_position := '010';
   IF FIND_WIP_SPEC( p_wip_spec_rec 	=> p_wip_spec_rec,
	      	     x_spec_id 	  	=> x_spec_id,
		     x_spec_vr_id	=> x_spec_vr_id,
		     x_return_status	=> x_return_status,
		     x_message_data   	=> x_message_data ) THEN
      x_spec_type := 'W';
      RETURN TRUE;
   ELSIF x_return_status <> 'S' THEN
      RETURN FALSE;
   END IF;

   l_position := '020';

   IF NVL(p_wip_spec_rec.exact_match,'N') = 'N' THEN
      l_inventory_spec_rec_type.inventory_item_id     :=  p_wip_spec_rec.inventory_item_id ;
      l_inventory_spec_rec_type.revision              :=  p_wip_spec_rec.revision ;
      l_inventory_spec_rec_type.grade_code            :=  p_wip_spec_rec.grade_code;
      l_inventory_spec_rec_type.organization_id       :=  p_wip_spec_rec.organization_id;
      l_inventory_spec_rec_type.parent_lot_number     :=  p_wip_spec_rec.parent_lot_number ;
      l_inventory_spec_rec_type.lot_number		      :=  p_wip_spec_rec.lot_number ;
      l_inventory_spec_rec_type.date_effective        :=  p_wip_spec_rec.date_effective  ;
      l_inventory_spec_rec_type.exact_match	          :=  p_wip_spec_rec.exact_match	 ;

      l_position := '030';
      IF FIND_INVENTORY_SPEC(p_inventory_spec_rec => l_inventory_spec_rec_type,
			     x_spec_id 	  	=> x_spec_id,
			     x_spec_vr_id	=> x_spec_vr_id,
			     x_return_status	=> x_return_status,
			     x_message_data   	=> x_message_data ) THEN
	  x_spec_type := 'I';
          RETURN TRUE;
      ELSE
          RETURN FALSE;
      END IF;
   ELSE
      RETURN FALSE;
   END IF;

EXCEPTION WHEN OTHERS THEN
   gmd_api_pub.log_message('GMD_API_ERROR','PACKAGE','GMD_SPEC_MATCH_GRP.FIND_WIP_OR_INV_SPEC','ERROR', SUBSTR(SQLERRM,1,100),'POSITION',l_position);
   x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
   RETURN FALSE;
END FIND_WIP_OR_INV_SPEC ;


--Start of comments
--+========================================================================+
--| API Name    : find_supplier_spec                                       |
--| TYPE        : Group                                                    |
--| Notes       : This function RETURN TRUE if matching supplier           |
--|               spec. is found else it RETURN FALSE.                     |
--|               If matching supplier spec is found,then                  |
--|               it returns matching spec_id  and spec_vr_id              |
--| HISTORY                                                                |
--|    Mahesh Chandak	6-Aug-2002	Created.                               |
--|    Brenda Stone     1-Mar-2004  Bug 3473559; Added Hints for spec_id   |
--| Saikiran Vankadari 15-Feb-2005  Made Converegence related changes.     |
--|                    Changed the logic for usage of grade in spec matching|
--|    Calling Program : Samples form					                   |
--|                      Receiving Transaction Event(Workflow)	           |
--+========================================================================+
-- End of comments

FUNCTION FIND_SUPPLIER_SPEC(p_supplier_spec_rec  IN  supplier_spec_rec_type,
		     	    x_spec_id 	  	 OUT NOCOPY NUMBER,
			    x_spec_vr_id	 OUT NOCOPY NUMBER,
			    x_return_status	 OUT NOCOPY VARCHAR2,
			    x_message_data   	 OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN IS

l_position   			    VARCHAR2(3);
l_check_for_given_grade 	VARCHAR2(1) := 'N';
l_check_for_null_grade  	VARCHAR2(1) := 'N';

REQ_FIELDS_MISSING 	EXCEPTION;
INVALID_ITEM		EXCEPTION;

/*  Bug 3473559; Added Hint for spec_id   */

CURSOR cr_match_spec IS
SELECT /*+  INDEX ( b gmd_supplier_spec_vrs_n1)   */
     a.spec_id,b.spec_vr_id,a.revision,a.grade_code,
	 decode(a.grade_code,p_supplier_spec_rec.grade_code,1,2),b.po_line_id,
	 b.po_header_id,b.supplier_site_id,b.supplier_id
FROM gmd_specifications_b a,gmd_supplier_spec_vrs b
WHERE
     a.inventory_item_id = p_supplier_spec_rec.inventory_item_id
AND ((p_supplier_spec_rec.revision = a.revision) OR ( p_supplier_spec_rec.revision IS NULL AND a.revision IS NULL)
     OR (p_supplier_spec_rec.revision IS NOT NULL AND a.revision IS NULL ))
AND ((a.spec_status between  700 and 799) OR (a.spec_status between  900 and 999))
AND  a.delete_mark = 0
AND ((l_check_for_given_grade = 'Y' and p_supplier_spec_rec.grade_code = a.grade_code ) OR
      (l_check_for_null_grade = 'Y' AND a.grade_code IS NULL ))
AND  a.spec_id = b.spec_id
AND ((b.spec_vr_status between  700 and 799) OR (b.spec_vr_status between  900 and 999))
AND  b.delete_mark = 0
AND  b.supplier_id = p_supplier_spec_rec.supplier_id
AND  p_supplier_spec_rec.date_effective between b.start_date and nvl(b.end_date,p_supplier_spec_rec.date_effective)
AND ((p_supplier_spec_rec.organization_id = b.organization_id) OR ( p_supplier_spec_rec.organization_id IS NULL AND b.organization_id IS NULL)
     OR (p_supplier_spec_rec.organization_id IS NOT NULL AND b.organization_id IS NULL ))
AND ((p_supplier_spec_rec.org_id = b.org_id) OR ( p_supplier_spec_rec.org_id IS NULL AND b.org_id IS NULL)
     OR (p_supplier_spec_rec.org_id IS NOT NULL AND b.org_id IS NULL ))
AND ((p_supplier_spec_rec.po_line_id = b.po_line_id) OR ( p_supplier_spec_rec.po_line_id IS NULL AND b.po_line_id IS NULL)
     OR (p_supplier_spec_rec.po_line_id IS NOT NULL AND b.po_line_id IS NULL ))
AND ((p_supplier_spec_rec.po_header_id = b.po_header_id) OR ( p_supplier_spec_rec.po_header_id IS NULL AND b.po_header_id IS NULL)
     OR (p_supplier_spec_rec.po_header_id IS NOT NULL AND b.po_header_id IS NULL ))
AND ((p_supplier_spec_rec.supplier_site_id = b.supplier_site_id) OR ( p_supplier_spec_rec.supplier_site_id IS NULL AND b.supplier_site_id IS NULL)
     OR (p_supplier_spec_rec.supplier_site_id IS NOT NULL AND b.supplier_site_id IS NULL ))
ORDER BY DECODE(a.grade_code,p_supplier_spec_rec.grade_code,1,2),b.po_line_id,b.po_header_id,b.supplier_site_id,b.supplier_id;

l_match_spec_rec   cr_match_spec%ROWTYPE;

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  FND_MSG_PUB.initialize;
  l_position := '010';

  IF p_supplier_spec_rec.inventory_item_id IS NULL OR p_supplier_spec_rec.organization_id IS NULL OR
     p_supplier_spec_rec.date_effective IS NULL OR p_supplier_spec_rec.supplier_id IS NULL THEN
       RAISE REQ_FIELDS_MISSING;
  END IF;

  IF p_supplier_spec_rec.grade_code IS NULL THEN
    l_check_for_null_grade 	:= 'Y';
  ELSE
    l_check_for_given_grade := 'Y';
    l_check_for_null_grade  := 'Y';
  END IF;

  l_position := '020';

  OPEN  cr_match_spec;
  FETCH cr_match_spec INTO l_match_spec_rec ;
  IF cr_match_spec%NOTFOUND THEN
     CLOSE cr_match_spec;
     RETURN FALSE;
  END IF;
  CLOSE cr_match_spec;

  l_position := '030';

-- do we need to compare grade also ??
  IF p_supplier_spec_rec.exact_match = 'Y' THEN
      IF ((p_supplier_spec_rec.revision = l_match_spec_rec.revision)
           OR ( p_supplier_spec_rec.revision IS NULL AND l_match_spec_rec.revision IS NULL))
        AND
           (( p_supplier_spec_rec.grade_code = l_match_spec_rec.grade_code)
      	   OR ( p_supplier_spec_rec.grade_code IS NULL AND l_match_spec_rec.grade_code IS NULL))
  	    AND
      	   (( p_supplier_spec_rec.supplier_id = l_match_spec_rec.supplier_id)
      	   OR ( p_supplier_spec_rec.supplier_id IS NULL AND l_match_spec_rec.supplier_id IS NULL))
      	AND
      	   (( p_supplier_spec_rec.supplier_site_id = l_match_spec_rec.supplier_site_id)
      	   OR ( p_supplier_spec_rec.supplier_site_id IS NULL AND l_match_spec_rec.supplier_site_id IS NULL))
      	AND
      	   (( p_supplier_spec_rec.po_header_id = l_match_spec_rec.po_header_id)
      	   OR ( p_supplier_spec_rec.po_header_id IS NULL AND l_match_spec_rec.po_header_id IS NULL))
      	AND
      	   (( p_supplier_spec_rec.po_line_id = l_match_spec_rec.po_line_id)
      	   OR ( p_supplier_spec_rec.po_line_id IS NULL AND l_match_spec_rec.po_line_id IS NULL))
      	THEN
      	   x_spec_id 	:= l_match_spec_rec.spec_id ;
      	   x_spec_vr_id := l_match_spec_rec.spec_vr_id ;
           RETURN TRUE;
      ELSE
           RETURN FALSE;
      END IF;
  ELSE
      x_spec_id    := l_match_spec_rec.spec_id ;
      x_spec_vr_id := l_match_spec_rec.spec_vr_id ;
      RETURN TRUE;
  END IF;


EXCEPTION
WHEN REQ_FIELDS_MISSING THEN
   gmd_api_pub.log_message('GMD_REQ_FIELD_MIS','PACKAGE','GMD_SPEC_MATCH_GRP.FIND_SUPPLIER_SPEC');
   x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
   x_return_status := FND_API.G_RET_STS_ERROR ;
   RETURN FALSE;
WHEN INVALID_ITEM THEN
   gmd_api_pub.log_message('GMD_INVALID_ITEM','ITEM',to_char(p_supplier_spec_rec.inventory_item_id));
   x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
   x_return_status := FND_API.G_RET_STS_ERROR ;
   RETURN FALSE;
WHEN OTHERS THEN
   gmd_api_pub.log_message('GMD_API_ERROR','PACKAGE','GMD_SPEC_MATCH_GRP.FIND_SUPPLIER_SPEC','ERROR', SUBSTR(SQLERRM,1,100),'POSITION',l_position);
   x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
   RETURN FALSE;
END FIND_SUPPLIER_SPEC;


FUNCTION FIND_SUPPLIER_OR_INV_SPEC(
		       p_supplier_spec_rec  IN  supplier_spec_rec_type,
		       x_spec_id       	OUT NOCOPY NUMBER,
		       x_spec_vr_id    	OUT NOCOPY NUMBER,
		       x_spec_type	OUT NOCOPY VARCHAR2,
		       x_return_status	OUT NOCOPY VARCHAR2,
		       x_message_data   OUT NOCOPY VARCHAR2)
RETURN BOOLEAN IS
l_inventory_spec_rec_type	inventory_spec_rec_type ;
l_position 	VARCHAR2(3);

BEGIN
   l_position := '010';
   IF FIND_SUPPLIER_SPEC( p_supplier_spec_rec => p_supplier_spec_rec,
	      	     x_spec_id 	  	 => x_spec_id,
		     x_spec_vr_id	 => x_spec_vr_id,
		     x_return_status	 => x_return_status,
		     x_message_data   	 => x_message_data ) THEN
      x_spec_type := 'S';
      RETURN TRUE;
   END IF;

   l_position := '020';

   IF NVL(p_supplier_spec_rec.exact_match,'N') = 'N' THEN
      l_inventory_spec_rec_type.inventory_item_id:=  p_supplier_spec_rec.inventory_item_id;
      l_inventory_spec_rec_type.revision        :=  p_supplier_spec_rec.revision;
      l_inventory_spec_rec_type.organization_id:=  p_supplier_spec_rec.organization_id;
      l_inventory_spec_rec_type.subinventory   :=  p_supplier_spec_rec.subinventory;
      l_inventory_spec_rec_type.locator_id      :=  p_supplier_spec_rec.locator_id;
      l_inventory_spec_rec_type.parent_lot_number :=  p_supplier_spec_rec.parent_lot_number;
      l_inventory_spec_rec_type.lot_number       :=  p_supplier_spec_rec.lot_number;
      l_inventory_spec_rec_type.date_effective   :=  p_supplier_spec_rec.date_effective ;
      l_inventory_spec_rec_type.exact_match	 :=  'N' ;
      l_inventory_spec_rec_type.grade_code        :=  p_supplier_spec_rec.grade_code;


      l_position := '030';

      IF FIND_INVENTORY_SPEC(p_inventory_spec_rec => l_inventory_spec_rec_type,
			     x_spec_id 	  	=> x_spec_id,
			     x_spec_vr_id	=> x_spec_vr_id,
			     x_return_status	=> x_return_status,
			     x_message_data   	=> x_message_data ) THEN
	  x_spec_type := 'I';
          RETURN TRUE;
      ELSE

          RETURN FALSE;
      END IF;
   ELSE
      RETURN FALSE;
   END IF;

EXCEPTION WHEN OTHERS THEN
   gmd_api_pub.log_message('GMD_API_ERROR','PACKAGE','GMD_SPEC_MATCH_GRP.FIND_SUPPLIER_OR_INV_SPEC','ERROR', SUBSTR(SQLERRM,1,100),'POSITION',l_position);
   x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
   RETURN FALSE;
END FIND_SUPPLIER_OR_INV_SPEC ;






--Start of comments
--+=====================================================================================================+
--| API Name    : get_result_match_for_spec                                  			         |
--| TYPE        : Group                                                                                  |
--| Notes       :                                                                                        |
--| Parameters  : item_id      - IN PARAMETER item_id of the order line                                  |
--|	  	  lot_number       - IN PARAMETER lot_number                                                     |
--|	  	  subinventory    - IN PARAMETER subinventory                                                  |
--|	  	  locator_id     - IN PARAMETER locator_id                                                   |
--|	  	  result_type  - OUT parameter ( will be SET BY THE API get_result_match_for_spec)       |
--|                         result_type will have 2 values - 'I' for Individual Result,             	 |
--|                         'C' - for Composite Result                                              	 |
--|	  	  sample_id      - OUT parameter ( will be SET BY THE API get_result_match_for_spec)     |
--|	                 - This will be used to navigate to the Result form.                     	 |
--|	  	  spec_match_type - OUT parameter ( will be SET BY THE API get_result_match_for_spec)    |
--|                          It can have 3 values.                                                  	 |
--|           	          - NULL If no sample is found, OR no results can be found for this lot, 	 |
--|	                  - 'U' for Unaccepted. If the latest accepted final result is not       	 |
--|	                     within the spec. test range.                                        	 |
--|	                  - 'A' for Accepted.All the test results for the customer spec are      	 |
--|	                  within the spec. test range                                            	 |
--|	  	  event_spec_disp_id - OUT parameter ( will be SET BY THE API get_result_match_for_spec) |
--|		             - This will be used to navigate to the composite results form.      	 |
--| 						                                                                             |
--| Calling Program : -  Order Management(Pick lots form)		                                          |
--| HISTORY                                                                                              |
--|    Mahesh Chandak	1-sep-2002	Created.                                                         |
--|                                                                                                      |
--| Saikiran Vankadari 15-Feb-2005  Made Converegence related changes.                                   |
--|                                                                                                     |
--+=====================================================================================================+
-- End of comments



PROCEDURE get_result_match_for_spec
                  (  p_spec_id       IN  NUMBER
                   , p_lots 	     IN  OUT NOCOPY result_lot_match_tbl
                   , x_return_status OUT NOCOPY VARCHAR2
		   , x_message_data  OUT NOCOPY VARCHAR2 ) IS

l_position   		VARCHAR2(3);
l_lot_number		VARCHAR2(80);
l_subinventory		VARCHAR2(10);
l_locator_id 		NUMBER;
l_inventory_item_id NUMBER;
l_organization_id   NUMBER;
l_old_sample_id		NUMBER;

-- pick up only required test
CURSOR cr_get_req_spec_tests IS
  SELECT gst.test_id
  FROM   GMD_SPEC_TESTS_B gst
  WHERE  gst.spec_id = p_spec_id
  AND    gst.optional_ind is NULL  ;

CURSOR cr_get_sample_for_lot IS
  SELECT gs.sample_id,gr.test_id,gr.result_value_num,gr.result_value_char
  FROM   GMD_SAMPLES gs , GMD_RESULTS gr
  WHERE  gs.sample_id = gr.sample_id
  AND    gs.delete_mark = 0
  AND    gs.sample_id IN ( SELECT ssd.sample_id FROM gmd_sample_spec_disp ssd
  			  WHERE ssd.sample_id = gs.sample_id
  			  AND ssd.disposition IN ('3C','4A','5AV','6RJ') )
  AND    gs.inventory_item_id  	= l_inventory_item_id
  AND    gs.organization_id = l_organization_id
  AND   (gs.lot_number 	= l_lot_number  OR gs.lot_number IS NULL)
  AND   (gs.subinventory 	= l_subinventory OR gs.subinventory IS NULL)
  AND   (gs.locator_id  	= l_locator_id OR gs.locator_id IS NULL )
  AND    gr.delete_mark = 0
  AND   (gr.result_value_num IS NOT NULL or gr.result_value_char IS NOT NULL)
  ORDER BY gs.lot_number,gs.date_drawn desc,gs.location,gs.subinventory,gr.result_date desc ;
-- 2651353  changed the order by clause. sample date takes preference over sub lot no.
-- looks for a sample within a lot_no with latest sample date.

l_lot_counter		BINARY_INTEGER;
l_spec_test_counter	BINARY_INTEGER;
REQ_FIELDS_MISSING  	EXCEPTION;
INVALID_LOT		EXCEPTION;
l_sample_rec		cr_get_sample_for_lot%ROWTYPE;

TYPE spec_test_tab IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

spec_test_list  spec_test_tab ;

TYPE result_test_tab IS TABLE OF cr_get_sample_for_lot%ROWTYPE INDEX BY BINARY_INTEGER;

result_test_list  		result_test_tab ;
l_spec_tests_exist_in_sample	BOOLEAN := FALSE;
l_result_in_spec		BOOLEAN := TRUE;
l_in_spec			VARCHAR2(1); -- returned by the results API
BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;
   FND_MSG_PUB.initialize;
   l_position := '010';

   IF p_spec_id IS NULL THEN
   	RETURN;
   END IF;

   FOR spec_test_row IN  cr_get_req_spec_tests LOOP
      spec_test_list(spec_test_row.test_id) := spec_test_row.test_id;
   END LOOP;

   l_position := '020';

   l_lot_counter := p_lots.FIRST;
   WHILE l_lot_counter IS NOT NULL
   LOOP
       IF p_lots(l_lot_counter).inventory_item_id IS NULL OR p_lots(l_lot_counter).organization_id IS NULL OR
          p_lots(l_lot_counter).lot_number IS NULL OR p_lots(l_lot_counter).subinventory IS NULL THEN
       	   RAISE REQ_FIELDS_MISSING;
       END IF;

       /*IF p_lots(l_lot_counter).lot_id IS NOT NULL THEN
       	  BEGIN
          	SELECT lot_no,sublot_no INTO l_lot_no,l_sublot_no
           	FROM IC_LOTS_MST
           	WHERE  lot_id  =  p_lots(l_lot_counter).lot_id
           	AND    item_id =  p_lots(l_lot_counter).item_id;

       	  EXCEPTION
          WHEN OTHERS THEN
             RAISE INVALID_LOT;
          END;
       END IF;*/



       l_inventory_item_id   := p_lots(l_lot_counter).inventory_item_id;
       l_organization_id := p_lots(l_lot_counter).organization_id;
       l_subinventory := p_lots(l_lot_counter).subinventory;
       l_locator_id  := p_lots(l_lot_counter).locator_id;
       l_lot_number := p_lots(l_lot_counter).lot_number;

       l_old_sample_id := null;
       l_spec_tests_exist_in_sample := FALSE;
       l_result_in_spec		    := TRUE;
       result_test_list.DELETE;

       l_position := '030';

       OPEN  cr_get_sample_for_lot ;
       LOOP
          FETCH cr_get_sample_for_lot INTO l_sample_rec;
          IF cr_get_sample_for_lot%NOTFOUND THEN
             EXIT ;
          END IF;

          -- sample changed.check for tests against each sample.
          IF l_old_sample_id IS NULL OR l_sample_rec.sample_id <> l_old_sample_id THEN
             l_old_sample_id := l_sample_rec.sample_id ;

             IF result_test_list.COUNT = spec_test_list.COUNT THEN
                 l_spec_tests_exist_in_sample := TRUE;
                 EXIT; -- once a matching sample with all the reqd spec test is found,then do not continue further.
             END IF;
             result_test_list.DELETE;

          -- If the current test is not in the spec, ignore it.
          -- If the test is already in the result test list, skip this row.
          END IF;
          IF spec_test_list.EXISTS(l_sample_rec.test_id) AND
            NOT (result_test_list.EXISTS(l_sample_rec.test_id)) THEN
              result_test_list(l_sample_rec.test_id) := l_sample_rec;
          END IF;

       END LOOP;
       CLOSE cr_get_sample_for_lot;
       -- do check again since the last sample won't go through the first test.
       IF result_test_list.COUNT = spec_test_list.COUNT THEN
           l_spec_tests_exist_in_sample := TRUE;
       END IF;

       l_position := '040';

       IF l_spec_tests_exist_in_sample  THEN
       -- check test results against the selected sample are in range as per the given specification
       	  l_spec_test_counter := spec_test_list.FIRST;
          WHILE l_spec_test_counter IS NOT NULL
          LOOP
              l_in_spec := GMD_RESULTS_GRP.rslt_is_in_spec(
              		p_spec_id         => p_spec_id
		, 	p_test_id         => spec_test_list(l_spec_test_counter)
		, 	p_rslt_value_num  => result_test_list(l_spec_test_counter).result_value_num
		, 	p_rslt_value_char => result_test_list(l_spec_test_counter).result_value_char ) ;
	      IF l_in_spec IS NULL THEN
		  l_result_in_spec := FALSE;
                  EXIT;
              END IF;
              l_spec_test_counter := spec_test_list.NEXT(l_spec_test_counter);
          END LOOP ;
          l_position := '050';
          IF l_result_in_spec THEN
              p_lots(l_lot_counter).sample_id        := result_test_list(result_test_list.FIRST).sample_id;
              p_lots(l_lot_counter).spec_match_type  := 'A';
              p_lots(l_lot_counter).result_type      := 'I' ;
          ELSE
              p_lots(l_lot_counter).sample_id        := result_test_list(result_test_list.FIRST).sample_id;
              p_lots(l_lot_counter).spec_match_type  := 'U';
              p_lots(l_lot_counter).result_type      := 'I' ;
          END IF;
       ELSE
          p_lots(l_lot_counter).spec_match_type := null;
       END IF;
       l_lot_counter := p_lots.NEXT(l_lot_counter);
   END LOOP;


EXCEPTION
WHEN REQ_FIELDS_MISSING THEN
   gmd_api_pub.log_message('GMD_REQ_FIELD_MIS','PACKAGE','GMD_SPEC_MATCH_GRP.GET_RESULT_MATCH_FOR_SPEC');
   x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
   x_return_status := FND_API.G_RET_STS_ERROR ;
WHEN INVALID_LOT THEN
   gmd_api_pub.log_message('GMD_INVALID_LOT','LOT',to_char(p_lots(l_lot_counter).lot_number));
   x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
   x_return_status := FND_API.G_RET_STS_ERROR ;
WHEN OTHERS THEN
   gmd_api_pub.log_message('GMD_API_ERROR','PACKAGE','GMD_SPEC_MATCH_GRP.GET_RESULT_MATCH_FOR_SPEC','ERROR', SUBSTR(SQLERRM,1,100),'POSITION',l_position);
   x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
END get_result_match_for_spec ;




--Start of comments
--+========================================================================+
--| API Name    : find_location_spec                                       |
--| TYPE        : Group                                                    |
--| Notes       : This function RETURN TRUE if matching location           |
--|               spec. is found else it RETURN FALSE.                     |
--|               If matching location spec is found,then                  |
--|               it returns matching spec_id  and spec_vr_id              |
--| HISTORY                                                                |
--|    Chetan Nagar	30-Mar-2003	Created.                           |
--| Saikiran Vankadari 15-Feb-2005  Made Converegence related changes.     |
--|    Calling Program : Samples form					   |
--+========================================================================+
-- End of comments

FUNCTION find_location_spec
(
  p_location_spec_rec IN         LOCATION_SPEC_REC_TYPE
, x_spec_id 	      OUT NOCOPY NUMBER
, x_spec_vr_id	      OUT NOCOPY NUMBER
, x_return_status     OUT NOCOPY VARCHAR2
, x_message_data      OUT NOCOPY VARCHAR2
) RETURN BOOLEAN IS

l_position   			VARCHAR2(3);

REQ_FIELDS_MISSING 	EXCEPTION;

CURSOR cr_match_spec IS
SELECT a.spec_id, b.spec_vr_id,
       b.locator_organization_id,
       b.subinventory,
       b.locator_id
FROM   gmd_specifications_b a,
       gmd_monitoring_spec_vrs b,
       gmd_qc_status qs1,
       gmd_qc_status qs2
WHERE  (a.spec_status = qs1.status_code AND
        qs1.entity_type = 'S' AND
        qs1.status_type in (400, 700, 900)
       )
AND    a.delete_mark = 0
AND    a.spec_id = b.spec_id
AND    (b.spec_vr_status = qs2.status_code AND
        qs2.entity_type = 'S' AND
        qs2.status_type in (400, 700, 900)
       )
AND    b.delete_mark = 0
AND    b.rule_type = 'L'
AND    p_location_spec_rec.date_effective between b.start_date and nvl(b.end_date, p_location_spec_rec.date_effective)
AND    ((p_location_spec_rec.locator_organization_id = b.locator_organization_id) OR
        (p_location_spec_rec.locator_organization_id IS NULL AND b.locator_organization_id IS NULL) OR
        (p_location_spec_rec.locator_organization_id IS NOT NULL AND b.locator_organization_id IS NULL)
       )
AND    ((p_location_spec_rec.subinventory = b.subinventory) OR
        (p_location_spec_rec.subinventory IS NULL AND b.subinventory IS NULL) OR
        (p_location_spec_rec.subinventory IS NOT NULL AND b.subinventory IS NULL)
       )
AND    ((p_location_spec_rec.locator_id = b.locator_id) OR
        (p_location_spec_rec.locator_id IS NULL AND b.locator_id IS NULL) OR
        (p_location_spec_rec.locator_id IS NOT NULL AND b.locator_id IS NULL )
       )
ORDER BY b.locator_id,b.subinventory,b.locator_organization_id ;

l_match_spec_rec   cr_match_spec%ROWTYPE;

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  FND_MSG_PUB.initialize;
  l_position := '010';

  IF (p_location_spec_rec.locator_organization_id IS NULL AND
      p_location_spec_rec.subinventory IS NULL AND
      p_location_spec_rec.locator_id IS NULL
     ) OR p_location_spec_rec.date_effective IS NULL THEN
       RAISE REQ_FIELDS_MISSING;
  END IF;

  l_position := '020';

  OPEN  cr_match_spec;
  FETCH cr_match_spec INTO l_match_spec_rec ;
  IF cr_match_spec%NOTFOUND THEN
     CLOSE cr_match_spec;
     RETURN FALSE;
  END IF;
  CLOSE cr_match_spec;

  l_position := '030';

  x_spec_id 	:= l_match_spec_rec.spec_id ;
  x_spec_vr_id  := l_match_spec_rec.spec_vr_id ;
  RETURN TRUE;

EXCEPTION
WHEN REQ_FIELDS_MISSING THEN
   gmd_api_pub.log_message('GMD_REQ_FIELD_MIS','PACKAGE','GMD_SPEC_MATCH_GRP.FIND_LOCATION_SPEC');
   x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
   x_return_status := FND_API.G_RET_STS_ERROR ;
   RETURN FALSE;
WHEN OTHERS THEN
   gmd_api_pub.log_message('GMD_API_ERROR','PACKAGE','GMD_SPEC_MATCH_GRP.FIND_LOCATION_SPEC','ERROR', SUBSTR(SQLERRM,1,100),'POSITION',l_position);
   x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
   RETURN FALSE;
END find_location_spec;





--Start of comments
--+========================================================================+
--| API Name    : find_resource_spec                                       |
--| TYPE        : Group                                                    |
--| Notes       : This function RETURN TRUE if matching location           |
--|               spec. is found else it RETURN FALSE.                     |
--|               If matching resource spec is found,then                  |
--|               it returns matching spec_id  and spec_vr_id              |
--| HISTORY                                                                |
--|    Chetan Nagar	30-Mar-2003	Created.                           |
--| Saikiran Vankadari 15-Feb-2005  Made Converegence related changes.     |
--|    Calling Program : Samples form					   |
--+========================================================================+
-- End of comments

FUNCTION find_resource_spec
(
  p_resource_spec_rec IN         RESOURCE_SPEC_REC_TYPE
, x_spec_id 	      OUT NOCOPY NUMBER
, x_spec_vr_id	      OUT NOCOPY NUMBER
, x_return_status     OUT NOCOPY VARCHAR2
, x_message_data      OUT NOCOPY VARCHAR2
) RETURN BOOLEAN IS

l_position   			VARCHAR2(3);

REQ_FIELDS_MISSING 	EXCEPTION;

CURSOR cr_match_spec IS
SELECT a.spec_id, b.spec_vr_id,
       b.resource_organization_id,
       b.resources,
       b.resource_instance_id
FROM   gmd_specifications_b a,
       gmd_monitoring_spec_vrs b,
       gmd_qc_status qs1,
       gmd_qc_status qs2
WHERE  (a.spec_status = qs1.status_code AND
        qs1.entity_type = 'S' AND
        qs1.status_type in (400, 700, 900)
       )
AND    a.delete_mark = 0
AND    a.spec_id = b.spec_id
AND    (b.spec_vr_status = qs2.status_code AND
        qs2.entity_type = 'S' AND
        qs2.status_type in (400, 700, 900)
       )
AND    b.delete_mark = 0
AND    b.rule_type = 'R'
AND    p_resource_spec_rec.date_effective between b.start_date and nvl(b.end_date, p_resource_spec_rec.date_effective)
AND    ((p_resource_spec_rec.resource_organization_id = b.resource_organization_id) OR
        (p_resource_spec_rec.resource_organization_id IS NULL AND b.resource_organization_id IS NULL) OR
        (p_resource_spec_rec.resource_organization_id IS NOT NULL AND b.resource_organization_id IS NULL)
       )
AND    ((p_resource_spec_rec.resources = b.resources) OR
        (p_resource_spec_rec.resources IS NULL AND b.resources IS NULL) OR
        (p_resource_spec_rec.resources IS NOT NULL AND b.resources IS NULL)
       )
AND    ((p_resource_spec_rec.resource_instance_id = b.resource_instance_id) OR
        (p_resource_spec_rec.resource_instance_id IS NULL AND b.resource_instance_id IS NULL) OR
        (p_resource_spec_rec.resource_instance_id IS NOT NULL AND b.resource_instance_id IS NULL )
       )
ORDER BY b.resource_instance_id, b.resources, b.resource_organization_id ;

l_match_spec_rec   cr_match_spec%ROWTYPE;

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  FND_MSG_PUB.initialize;
  l_position := '010';

  IF (p_resource_spec_rec.resource_organization_id IS NULL AND
      p_resource_spec_rec.resources IS NULL AND
      p_resource_spec_rec.resource_instance_id IS NULL
     ) OR p_resource_spec_rec.date_effective IS NULL THEN
       RAISE REQ_FIELDS_MISSING;
  END IF;

  l_position := '020';

  OPEN  cr_match_spec;
  FETCH cr_match_spec INTO l_match_spec_rec ;
  IF cr_match_spec%NOTFOUND THEN
     CLOSE cr_match_spec;
     RETURN FALSE;
  END IF;
  CLOSE cr_match_spec;

  l_position := '030';

  x_spec_id 	:= l_match_spec_rec.spec_id ;
  x_spec_vr_id  := l_match_spec_rec.spec_vr_id ;
  RETURN TRUE;

EXCEPTION
WHEN REQ_FIELDS_MISSING THEN
   gmd_api_pub.log_message('GMD_REQ_FIELD_MIS','PACKAGE','GMD_SPEC_MATCH_GRP.FIND_RESOURCE_SPEC');
   x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
   x_return_status := FND_API.G_RET_STS_ERROR ;
   RETURN FALSE;
WHEN OTHERS THEN
   gmd_api_pub.log_message('GMD_API_ERROR','PACKAGE','GMD_SPEC_MATCH_GRP.FIND_RESOURCE_SPEC','ERROR', SUBSTR(SQLERRM,1,100),'POSITION',l_position);
   x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
   RETURN FALSE;
END find_resource_spec;

--Start of comments
--+========================================================================+
--| API Name    : get_inv_spec_or_vr_id                                    |
--|                                                                        |
--| Notes      Returns spec_id or spec_vr_id depending on parameter 	   |
--|            p_spec_or_vr_ind passed. Returns 0 if not able to get 	   |
--|            the matching spec or p_spec_or_vr_ind is invalid or if      |
--|            GMD_SPEC_MATCH_GRP.FIND_INVENTORY_SPEC raises any error.    |
--|            Pass 'SPECID'   to p_spec_or_vr_ind to get spec_id.         |
--|            Pass 'SPECVRID' to get spec_vr_id.		           |
--|									   |
--|  HISTORY                                                               |
--|  Saikiran Vankadari	25-Nov-2005	Bug 4538523 Created.               |
--|  Calling Program : 	Item/Location Required Analysis Report             |
--+========================================================================+
-- End of comments

FUNCTION GET_INV_SPEC_OR_VR_ID(  p_inventory_item_id IN NUMBER
                                ,p_revision        IN VARCHAR2
                                ,p_grade_code      IN VARCHAR2
                                ,p_organization_id IN VARCHAR2
                                ,p_subinventory    IN VARCHAR2
                                ,p_parent_lot_number IN VARCHAR2
                                ,p_lot_number      IN VARCHAR2
                                ,p_locator_id      IN NUMBER
                                ,p_date_effective  IN DATE
                                ,p_exact_match     IN VARCHAR2
                                ,p_test_id         IN NUMBER
                                ,p_spec_or_vr_ind  IN VARCHAR2 )
 RETURN NUMBER IS

    l_inventory_spec_rec  GMD_SPEC_MATCH_GRP.inventory_spec_rec_type;
    l_inv_spec_vr_id      NUMBER := 0;
    l_return_flag         BOOLEAN;
    x_spec_id             NUMBER;
    x_spec_vr_id          NUMBER;
    x_return_status       VARCHAR2(1000);
    x_message_data        VARCHAR2(1000);
    l_spec_or_vr_ind      VARCHAR2(10);

 BEGIN

    l_inventory_spec_rec.inventory_item_id := p_inventory_item_id         ;
    l_inventory_spec_rec.revision       := p_revision       ;
    l_inventory_spec_rec.grade_code     := p_grade_code           ;
    l_inventory_spec_rec.organization_id := p_organization_id       ;
    l_inventory_spec_rec.subinventory    := p_subinventory          ;
    l_inventory_spec_rec.parent_lot_number  := p_parent_lot_number          ;
    l_inventory_spec_rec.lot_number      := p_lot_number       ;
    l_inventory_spec_rec.locator_id      := p_locator_id        ;
    l_inventory_spec_rec.date_effective := p_date_effective  ;
    l_inventory_spec_rec.exact_match    := p_exact_match     ;
    l_inventory_spec_rec.test_id        := p_test_id         ;
    l_spec_or_vr_ind                    := p_spec_or_vr_ind  ;

    IF l_spec_or_vr_ind NOT IN('SPECID','SPECVRID') THEN
       l_inv_spec_vr_id := 0;   --consider spec_vr_id not found
       RETURN l_inv_spec_vr_id;
    END IF;

    l_return_flag := GMD_SPEC_MATCH_GRP.FIND_INVENTORY_SPEC( l_inventory_spec_rec
                                                            ,x_spec_id
                                                            ,x_spec_vr_id
                                                            ,x_return_status
                                                            ,x_message_data );
    IF l_return_flag THEN      --spec_vr_id found
       IF l_spec_or_vr_ind = 'SPECID' THEN
          l_inv_spec_vr_id := x_spec_id;
          RETURN l_inv_spec_vr_id;       --return spec_id
       ELSIF l_spec_or_vr_ind = 'SPECVRID' THEN
          l_inv_spec_vr_id := x_spec_vr_id;
          RETURN l_inv_spec_vr_id;       --return spec_vr_id
       END IF;
    ELSE
       l_inv_spec_vr_id := 0;  --spec_vr_id not found
    END IF;
    RETURN l_inv_spec_vr_id;

 EXCEPTION
   WHEN OTHERS THEN
     l_inv_spec_vr_id := 0;  --consider spec_vr_id not found
     RETURN l_inv_spec_vr_id;

END GET_INV_SPEC_OR_VR_ID;


END gmd_spec_match_grp;

/
