--------------------------------------------------------
--  DDL for Package Body GMD_SPEC_MATCH_MIG_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_SPEC_MATCH_MIG_GRP" AS
/* $Header: GMDGSMMB.pls 120.0 2005/05/25 18:49:15 appldev noship $ */

-- Start of comments
--+==========================================================================+
--|                   Copyright (c) 1998 Oracle Corporation                  |
--|                          Redwood Shores, CA, USA                         |
--|                            All rights reserved.                          |
--+==========================================================================+
--| File Name          : GMDGSMMS.pls                                        |
--| Package Name       : GMD_SPEC_MATCH_MIG_GRP                              |
--| Type               : Group                                               |
--|                                                                          |
--| Notes                                                                    |
--|    This package contains group layer APIs for Specification Match for    |
--|    migration.                                                            |
--|                                                                          |
--| HISTORY                                                                  |
--|    B. Stone   13-Oct_2004	Created.  Bug 3934121.                       |
--|                             Removed find_location_spec and               |
--|                             find_resource_spec, these are not used by    |
--|                             migration.                                   |
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
--| Calling Program : - Samples form			   		   |
--|                   - Subscriber for the Receiving Event(if              |
--|                     matching supplier spec is not found) (Workflow)    |
--|                   -	Inventory Transaction Event                        |
--|                   - Lot Expiration Transcation Event                   |
--|                   - Lot Retest Transcation Event                       |
--| HISTORY                                                                |
--|    Mahesh Chandak	6-Aug-2002	Created.                           |
--|    Brenda Stone     1-Mar-2004  Bug 3473559; Added Hints for spec_id   |
--|                                                                        |
--+========================================================================+
-- End of comments

FUNCTION FIND_INVENTORY_SPEC(p_inventory_spec_rec IN  inventory_spec_rec_type,
			     x_spec_id 	  	  OUT NOCOPY NUMBER,
			     x_spec_vr_id	  OUT NOCOPY NUMBER,
			     x_return_status	  OUT NOCOPY VARCHAR2,
			     x_message_data   	  OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN IS

l_position   			VARCHAR2(3);
l_grade_ctl			NUMBER ;
l_item_default_grade		QC_GRAD_MST.QC_GRADE%TYPE ;
l_check_for_given_grade 	VARCHAR2(1) := 'N';
l_check_for_null_grade  	VARCHAR2(1) := 'N';
l_check_for_default_grade	VARCHAR2(1) := 'N';
l_lot_no			IC_LOTS_MST.lot_no%TYPE;
l_sublot_no			IC_LOTS_MST.sublot_no%TYPE;

REQ_FIELDS_MISSING 	EXCEPTION;
INVALID_LOT 		EXCEPTION;
INVALID_ITEM		EXCEPTION;

/*  Bug 3473559; Added Hint for spec_id   */

CURSOR cr_match_spec IS
SELECT /*+ INDEX ( b GMD_INVENTORY_SPEC_VRS_N1 ) */
    a.spec_id,b.spec_vr_id,a.grade,decode(a.grade,
    p_inventory_spec_rec.grade,1,2),
    b.location,b.whse_code,b.sublot_no,b.lot_no,
    b.orgn_code
FROM gmd_specifications_b a,gmd_inventory_spec_vrs b
WHERE
     a.item_id = p_inventory_spec_rec.item_id
AND  a.delete_mark = 0
AND ((l_check_for_given_grade = 'Y' and p_inventory_spec_rec.grade = a.grade ) OR (l_check_for_null_grade = 'Y' AND a.grade IS NULL )
      OR (l_check_for_default_grade = 'Y' AND a.grade = l_item_default_grade))
AND  a.spec_id = b.spec_id
AND  b.delete_mark = 0
AND  p_inventory_spec_rec.date_effective between b.start_date and nvl(b.end_date,p_inventory_spec_rec.date_effective)
AND ((p_inventory_spec_rec.location = b.location) OR ( p_inventory_spec_rec.location IS NULL AND b.location IS NULL)
     OR (p_inventory_spec_rec.location IS NOT NULL AND b.location IS NULL ))
AND ((p_inventory_spec_rec.whse_code = b.whse_code) OR ( p_inventory_spec_rec.whse_code IS NULL AND b.whse_code IS NULL)
     OR (p_inventory_spec_rec.whse_code IS NOT NULL AND b.whse_code IS NULL ))
AND ((l_lot_no = b.lot_no) OR ( l_lot_no IS NULL AND b.lot_no IS NULL)
     OR (l_lot_no IS NOT NULL AND b.lot_no IS NULL ))
AND ((l_sublot_no = b.sublot_no) OR ( l_sublot_no IS NULL AND b.sublot_no IS NULL)
     OR (l_sublot_no IS NOT NULL AND b.sublot_no IS NULL ))
AND ((p_inventory_spec_rec.orgn_code = b.orgn_code) OR ( p_inventory_spec_rec.orgn_code IS NULL AND b.orgn_code IS NULL)
     OR (p_inventory_spec_rec.orgn_code IS NOT NULL AND b.orgn_code IS NULL ))
ORDER BY decode(a.grade,p_inventory_spec_rec.grade,1,2),b.sublot_no,b.lot_no,b.location,b.whse_code,b.orgn_code ;

-- Production team requirement to look for a specific test in a spec.
CURSOR cr_match_spec_test IS
SELECT a.spec_id,b.spec_vr_id,a.grade,decode(a.grade,
    p_inventory_spec_rec.grade,1,2),
    b.location,b.whse_code,b.sublot_no,b.lot_no,
    b.orgn_code
FROM gmd_specifications_b a,gmd_inventory_spec_vrs b , gmd_spec_tests_b c
WHERE
     a.item_id = p_inventory_spec_rec.item_id
AND  a.delete_mark = 0
AND ((l_check_for_given_grade = 'Y' and p_inventory_spec_rec.grade = a.grade )
 OR (l_check_for_null_grade = 'Y' AND a.grade IS NULL )
      OR (l_check_for_default_grade = 'Y' AND a.grade = l_item_default_grade))
AND  a.spec_id = c.spec_id
AND  c.test_id = p_inventory_spec_rec.test_id
AND  a.spec_id = b.spec_id
AND  b.delete_mark = 0
AND  p_inventory_spec_rec.date_effective between b.start_date and nvl(b.end_date,p_inventory_spec_rec.date_effective)
AND ((p_inventory_spec_rec.location = b.location)
     OR ( p_inventory_spec_rec.location IS NULL AND b.location IS NULL)
     OR (p_inventory_spec_rec.location IS NOT NULL AND b.location IS NULL ))
AND ((p_inventory_spec_rec.whse_code = b.whse_code) OR ( p_inventory_spec_rec.whse_code IS NULL AND b.whse_code IS NULL)
     OR (p_inventory_spec_rec.whse_code IS NOT NULL AND b.whse_code IS NULL ))
AND ((l_lot_no = b.lot_no) OR ( l_lot_no IS NULL AND b.lot_no IS NULL)
     OR (l_lot_no IS NOT NULL AND b.lot_no IS NULL ))
AND ((l_sublot_no = b.sublot_no) OR ( l_sublot_no IS NULL AND b.sublot_no IS NULL)
     OR (l_sublot_no IS NOT NULL AND b.sublot_no IS NULL ))
AND ((p_inventory_spec_rec.orgn_code = b.orgn_code) OR ( p_inventory_spec_rec.orgn_code IS NULL AND b.orgn_code IS NULL)
     OR (p_inventory_spec_rec.orgn_code IS NOT NULL AND b.orgn_code IS NULL ))
ORDER BY decode(a.grade,p_inventory_spec_rec.grade,1,2),b.sublot_no,b.lot_no,b.location,b.whse_code,b.orgn_code ;

l_match_spec_rec   cr_match_spec%ROWTYPE;

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  FND_MSG_PUB.initialize;
  l_position := '010';

  IF p_inventory_spec_rec.item_id IS NULL OR p_inventory_spec_rec.date_effective IS NULL THEN
       RAISE REQ_FIELDS_MISSING;
  END IF;

  -- if lot_id is passed and corr. lot_no and sublot_no is not there,
  --  fetch the corr. lot and sublot_no
  IF p_inventory_spec_rec.lot_id IS NOT NULL
     AND p_inventory_spec_rec.lot_no IS NULL
	 AND p_inventory_spec_rec.sublot_no IS NULL THEN
    BEGIN
           SELECT lot_no,sublot_no INTO l_lot_no,l_sublot_no
           FROM IC_LOTS_MST
           WHERE  lot_id  =  p_inventory_spec_rec.lot_id ;
    EXCEPTION
    WHEN OTHERS THEN
        RAISE INVALID_LOT;
    END;
  ELSE
    l_lot_no 	:= p_inventory_spec_rec.lot_no;
    l_sublot_no := p_inventory_spec_rec.sublot_no;
  END IF;

  IF p_inventory_spec_rec.grade IS NULL THEN
    BEGIN
       SELECT grade_ctl,qc_grade INTO  l_grade_ctl ,l_item_default_grade
       FROM   IC_ITEM_MST_B
       WHERE  ITEM_ID = p_inventory_spec_rec.item_id ;

       IF l_grade_ctl = 0 THEN
       	  l_check_for_null_grade 	:= 'Y';
       ELSE
 -- if item is grade ctl and grade is not passed,
 --  check for null grade and item's default grade in that order.
          l_check_for_null_grade 	:= 'Y';
          l_check_for_default_grade 	:= 'Y';
       END IF;

    EXCEPTION WHEN OTHERS THEN
       RAISE INVALID_ITEM;
    END ;
  ELSE
    l_grade_ctl := 1;
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
      IF (( p_inventory_spec_rec.grade = l_match_spec_rec.grade)
      	   OR ( p_inventory_spec_rec.grade IS NULL AND l_match_spec_rec.grade IS NULL))
	AND
      	   (( p_inventory_spec_rec.orgn_code = l_match_spec_rec.orgn_code)
      	   OR ( p_inventory_spec_rec.orgn_code IS NULL AND l_match_spec_rec.orgn_code IS NULL))
      	AND
      	   (( l_lot_no = l_match_spec_rec.lot_no)
      	   OR ( l_lot_no IS NULL AND l_match_spec_rec.lot_no IS NULL))
	AND
      	   (( l_sublot_no = l_match_spec_rec.sublot_no)
      	   OR ( l_sublot_no IS NULL AND l_match_spec_rec.sublot_no IS NULL))
      	AND
      	   (( p_inventory_spec_rec.whse_code = l_match_spec_rec.whse_code)
      	   OR ( p_inventory_spec_rec.whse_code IS NULL AND l_match_spec_rec.whse_code IS NULL))
      	AND
      	   (( p_inventory_spec_rec.location = l_match_spec_rec.location)
      	   OR ( p_inventory_spec_rec.location IS NULL AND l_match_spec_rec.location IS NULL))
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
   gmd_api_pub.log_message('GMD_INVALID_LOT','LOT',to_char(p_inventory_spec_rec.lot_id));
   x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
   x_return_status := FND_API.G_RET_STS_ERROR ;
   RETURN FALSE;
WHEN INVALID_ITEM THEN
   gmd_api_pub.log_message('GMD_INVALID_ITEM','ITEM',to_char(p_inventory_spec_rec.item_id));
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
--|                                                                        |
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

l_orgn_code  VARCHAR2(4);
l_position   VARCHAR2(3);
l_order_line_number NUMBER;
l_grade_ctl		NUMBER ;
l_item_default_grade	QC_GRAD_MST.QC_GRADE%TYPE ;
l_check_for_given_grade 	VARCHAR2(1) := 'N';
l_check_for_null_grade  	VARCHAR2(1) := 'N';
l_check_for_default_grade	VARCHAR2(1) := 'N';


REQ_FIELDS_MISSING 	EXCEPTION;
NO_ORGN_WHSE  		EXCEPTION;
INVALID_WHSE 		EXCEPTION;
INVALID_ORDER_LINE 	EXCEPTION;
INVALID_ITEM		EXCEPTION;

/*  Bug 3473559; Added Hint for spec_id   */
--  Bug 3934121; Removed spec_status from Where clause

CURSOR cr_match_spec IS
SELECT /*+  INDEX (b gmd_customer_spec_vrs_n1 )    */
     a.spec_id,b.spec_vr_id,a.grade grade,DECODE(a.grade,p_customer_spec_rec.grade,1,2) grade_order_by,b.order_line_id,b.order_line,b.order_id,b.ship_to_site_id,b.org_id,DECODE(b.orgn_code,l_orgn_code,1,NULL,2,3) orgn_code_order_by,b.orgn_code
FROM gmd_specifications_b a,gmd_customer_spec_vrs b
WHERE
     a.item_id = p_customer_spec_rec.item_id
AND  a.delete_mark = 0
AND ((l_check_for_given_grade = 'Y' and p_customer_spec_rec.grade = a.grade )
      OR (l_check_for_null_grade = 'Y' AND a.grade IS NULL )
      OR (l_check_for_default_grade = 'Y' AND a.grade = l_item_default_grade))
AND  a.spec_id = b.spec_id
AND  b.delete_mark = 0
AND  b.cust_id = p_customer_spec_rec.cust_id
AND  p_customer_spec_rec.date_effective between b.start_date and nvl(b.end_date,p_customer_spec_rec.date_effective + 1)
AND ((l_orgn_code = NVL(b.orgn_code,l_orgn_code))  OR ( p_customer_spec_rec.look_in_other_orgn = 'Y' and l_orgn_code <> b.orgn_code ))
AND ((p_customer_spec_rec.org_id = b.org_id) OR ( p_customer_spec_rec.org_id IS NULL AND b.org_id IS NULL)
     OR (p_customer_spec_rec.org_id IS NOT NULL AND b.org_id IS NULL ))
AND ((p_customer_spec_rec.ship_to_site_id = b.ship_to_site_id)
     OR ( p_customer_spec_rec.ship_to_site_id IS NULL AND b.ship_to_site_id IS NULL)
     OR (p_customer_spec_rec.ship_to_site_id IS NOT NULL AND b.ship_to_site_id IS NULL ))
AND ((p_customer_spec_rec.order_id = b.order_id)
     OR ( p_customer_spec_rec.order_id IS NULL AND b.order_id IS NULL)
     OR (p_customer_spec_rec.order_id IS NOT NULL AND b.order_id IS NULL ))
AND ((l_order_line_number = b.order_line) OR ( l_order_line_number IS NULL AND b.order_line IS NULL)
     OR (l_order_line_number IS NOT NULL AND b.order_line IS NULL ))
ORDER BY DECODE(a.grade,p_customer_spec_rec.grade,1,2),b.order_line_id,b.order_line,b.order_id,b.ship_to_site_id,b.org_id,DECODE(b.orgn_code,l_orgn_code,1,NULL,2,3);

--bug# 2982799
--compare only the order line number. not the line id.remove the order_line_id CLAUSE.

l_match_spec_rec   cr_match_spec%ROWTYPE;

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  FND_MSG_PUB.initialize;
  l_position := '010';

  IF p_customer_spec_rec.item_id IS NULL OR p_customer_spec_rec.cust_id IS NULL OR
     p_customer_spec_rec.date_effective IS NULL THEN
       RAISE REQ_FIELDS_MISSING;
  END IF;

  IF p_customer_spec_rec.orgn_code IS NULL THEN
     IF p_customer_spec_rec.whse_code IS NOT NULL THEN
        BEGIN
           SELECT orgn_code INTO l_orgn_code
           FROM   IC_WHSE_MST
           WHERE  whse_code = p_customer_spec_rec.whse_code;
        EXCEPTION
        WHEN OTHERS THEN
            RAISE INVALID_WHSE;
        END;
     ELSE
        RAISE NO_ORGN_WHSE;
     END IF;
  ELSE
     l_orgn_code := p_customer_spec_rec.orgn_code;
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

  IF p_customer_spec_rec.grade IS NULL THEN
    BEGIN
       SELECT grade_ctl,qc_grade INTO  l_grade_ctl ,l_item_default_grade
       FROM   IC_ITEM_MST_B
       WHERE  ITEM_ID = p_customer_spec_rec.item_id ;

       IF l_grade_ctl = 0 THEN
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
    l_grade_ctl := 1;
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
     IF (( p_customer_spec_rec.grade = l_match_spec_rec.grade)
      	   OR ( p_customer_spec_rec.grade IS NULL AND l_match_spec_rec.grade IS NULL))
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
	AND (l_orgn_code = l_match_spec_rec.orgn_code)
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
WHEN NO_ORGN_WHSE THEN
   gmd_api_pub.log_message('GMD_NO_ORGN_WHSE');
   x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
   x_return_status := FND_API.G_RET_STS_ERROR ;
   RETURN FALSE;
WHEN INVALID_WHSE THEN
   gmd_api_pub.log_message('GMD_INVALID_WHSE','WHSE',p_customer_spec_rec.whse_code);
   x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
   x_return_status := FND_API.G_RET_STS_ERROR ;
   RETURN FALSE;
WHEN INVALID_ORDER_LINE THEN
   gmd_api_pub.log_message('GMD_INVALID_ORDER_LINE','LINE',to_char(p_customer_spec_rec.order_line_id));
   x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
   x_return_status := FND_API.G_RET_STS_ERROR ;
   RETURN FALSE;
WHEN INVALID_ITEM THEN
   gmd_api_pub.log_message('GMD_INVALID_ITEM','ITEM',to_char(p_customer_spec_rec.item_id));
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
      l_inventory_spec_rec_type.item_id          :=  p_customer_spec_rec.item_id         ;
      l_inventory_spec_rec_type.grade            :=  p_customer_spec_rec.grade           ;
      l_inventory_spec_rec_type.orgn_code        :=  p_customer_spec_rec.orgn_code       ;
      l_inventory_spec_rec_type.lot_id           :=  p_customer_spec_rec.lot_id          ;
      l_inventory_spec_rec_type.lot_no		 :=  p_customer_spec_rec.lot_no		 ;
      l_inventory_spec_rec_type.sublot_no	 :=  p_customer_spec_rec.sublot_no	 ;
      l_inventory_spec_rec_type.whse_code        :=  p_customer_spec_rec.whse_code       ;
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
l_grade_ctl			NUMBER ;
l_item_default_grade		QC_GRAD_MST.QC_GRADE%TYPE ;
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

/*  Bug 3473559; Added Hint for spec_id   */
--  Bug 3934121; Removed spec_status from Where clause

CURSOR cr_match_spec IS
SELECT /*+  INDEX ( b gmd_wip_spec_vrs_n1 )  */
    a.spec_id,b.spec_vr_id,a.grade grade,
	DECODE(a.grade,p_wip_spec_rec.grade,1,2) grade_order_by,
	b.charge,b.step_no,
    b.routing_vers,b.routing_no,b.formulaline_id,
	b.formula_vers,b.formula_no,b.recipe_version,
	b.recipe_no,b.batch_id,b.oprn_vers,b.oprn_no,b.orgn_code
FROM gmd_specifications_b a,gmd_wip_spec_vrs b
WHERE
     a.item_id = p_wip_spec_rec.item_id
AND  a.delete_mark = 0
AND ((l_check_for_given_grade = 'Y' and p_wip_spec_rec.grade = a.grade ) OR (l_check_for_null_grade = 'Y' AND a.grade IS NULL )
      OR (l_check_for_default_grade = 'Y' AND a.grade = l_item_default_grade))
AND  a.spec_id = b.spec_id
AND  b.delete_mark = 0
AND  p_wip_spec_rec.date_effective between b.start_date and nvl(b.end_date,p_wip_spec_rec.date_effective)
AND (p_wip_spec_rec.orgn_code = NVL(b.orgn_code,p_wip_spec_rec.orgn_code))
AND ((p_wip_spec_rec.batch_id = b.batch_id) OR ( p_wip_spec_rec.batch_id IS NULL AND b.batch_id IS NULL)
     OR (p_wip_spec_rec.batch_id IS NOT NULL AND b.batch_id IS NULL ))
AND ((l_formula_no = b.formula_no) OR ( l_formula_no IS NULL AND b.formula_no IS NULL)
     OR (l_formula_no IS NOT NULL AND b.formula_no IS NULL ))
AND ((l_formula_vers = b.formula_vers) OR ( l_formula_vers IS NULL AND b.formula_vers IS NULL)
     OR (l_formula_vers IS NOT NULL AND b.formula_vers IS NULL ))
AND ((l_recipe_no = b.recipe_no) OR ( l_recipe_no IS NULL AND b.recipe_no IS NULL)
     OR (l_recipe_no IS NOT NULL AND b.recipe_no IS NULL ))
AND ((l_recipe_version = b.recipe_version) OR ( l_recipe_version IS NULL AND b.recipe_version IS NULL)
     OR (l_recipe_version IS NOT NULL AND b.recipe_version IS NULL ))
AND ((p_wip_spec_rec.charge = b.charge) OR ( p_wip_spec_rec.charge IS NULL AND b.charge IS NULL)
     OR (p_wip_spec_rec.charge IS NOT NULL AND b.charge IS NULL ))
AND ((l_step_no = b.step_no) OR (l_step_no IS NULL AND b.step_no IS NULL)
     OR (nvl(p_wip_spec_rec.find_spec_with_step,'N') = 'N' and l_step_no IS NOT NULL AND b.step_no IS NULL ))
AND ((l_routing_no = b.routing_no) OR ( l_routing_no IS NULL AND b.routing_no IS NULL)
     OR (l_routing_no IS NOT NULL AND b.routing_no IS NULL ))
AND ((l_routing_vers = b.routing_vers) OR ( l_routing_vers IS NULL AND b.routing_vers IS NULL)
     OR (l_routing_vers IS NOT NULL AND b.routing_vers IS NULL ))
AND ((p_wip_spec_rec.formulaline_id = b.formulaline_id)
     OR ( p_wip_spec_rec.formulaline_id IS NULL AND b.formulaline_id IS NULL)
     OR (p_wip_spec_rec.formulaline_id IS NOT NULL AND b.formulaline_id IS NULL ))
AND ((l_oprn_no = b.oprn_no) OR ( l_oprn_no IS NULL AND b.oprn_no IS NULL)
     OR (l_oprn_no IS NOT NULL AND b.oprn_no IS NULL ))
AND ((l_oprn_vers = b.oprn_vers) OR ( l_oprn_vers IS NULL AND b.oprn_vers IS NULL)
     OR (l_oprn_vers IS NOT NULL AND b.oprn_vers IS NULL ))
ORDER BY DECODE(a.grade,p_wip_spec_rec.grade,1,2),b.charge,b.step_no,
b.routing_id,b.routing_no,b.formulaline_id,b.formula_id,b.formula_no,
b.recipe_id,b.recipe_no,b.batch_id,b.oprn_id,b.oprn_no,b.orgn_code ;

l_match_spec_rec   cr_match_spec%ROWTYPE;

BEGIN


  x_return_status := FND_API.G_RET_STS_SUCCESS;
  FND_MSG_PUB.initialize;
  l_position := '010';

  IF p_wip_spec_rec.item_id IS NULL OR p_wip_spec_rec.orgn_code IS NULL OR p_wip_spec_rec.date_effective IS NULL THEN
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

  IF p_wip_spec_rec.grade IS NULL THEN
    BEGIN
       SELECT grade_ctl,qc_grade INTO  l_grade_ctl ,l_item_default_grade
       FROM   IC_ITEM_MST_B
       WHERE  ITEM_ID = p_wip_spec_rec.item_id ;

       IF l_grade_ctl = 0 THEN
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
    l_grade_ctl := 1;
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
     IF (( p_wip_spec_rec.grade = l_match_spec_rec.grade)
      	   OR ( p_wip_spec_rec.grade IS NULL AND l_match_spec_rec.grade IS NULL))
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
      	   OR ( p_wip_spec_rec.formulaline_id IS NULL AND l_match_spec_rec.formulaline_id IS NULL))
      	AND
      	   (( l_step_no = l_match_spec_rec.step_no)
      	   OR ( l_step_no IS NULL AND l_match_spec_rec.step_no IS NULL))
      	AND
      	   (( p_wip_spec_rec.charge = l_match_spec_rec.charge)
      	   OR ( p_wip_spec_rec.charge IS NULL AND l_match_spec_rec.charge IS NULL))
	AND (p_wip_spec_rec.orgn_code = l_match_spec_rec.orgn_code)
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
   gmd_api_pub.log_message('GMD_INVALID_ITEM','ITEM',to_char(p_wip_spec_rec.item_id));
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
      l_inventory_spec_rec_type.item_id          :=  p_wip_spec_rec.item_id         ;
      l_inventory_spec_rec_type.grade            :=  p_wip_spec_rec.grade           ;
      l_inventory_spec_rec_type.orgn_code        :=  p_wip_spec_rec.orgn_code       ;
      l_inventory_spec_rec_type.lot_id           :=  p_wip_spec_rec.lot_id          ;
      l_inventory_spec_rec_type.lot_no		 :=  p_wip_spec_rec.lot_no		 ;
      l_inventory_spec_rec_type.sublot_no	 :=  p_wip_spec_rec.sublot_no	 ;
      l_inventory_spec_rec_type.date_effective   :=  p_wip_spec_rec.date_effective  ;
      l_inventory_spec_rec_type.exact_match	 :=  p_wip_spec_rec.exact_match	 ;

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

l_orgn_code  VARCHAR2(4);
l_position   			VARCHAR2(3);
l_grade_ctl			NUMBER ;
l_item_default_grade		QC_GRAD_MST.QC_GRADE%TYPE ;
l_check_for_given_grade 	VARCHAR2(1) := 'N';
l_check_for_null_grade  	VARCHAR2(1) := 'N';
l_check_for_default_grade	VARCHAR2(1) := 'N';

NO_ORGN_WHSE  		EXCEPTION;
INVALID_WHSE 		EXCEPTION;
REQ_FIELDS_MISSING 	EXCEPTION;
INVALID_ITEM		EXCEPTION;

/*  Bug 3473559; Added Hint for spec_id   */
--  Bug 3934121; Removed spec_status from Where clause

CURSOR cr_match_spec IS
SELECT /*+  INDEX ( b gmd_supplier_spec_vrs_n1)   */
     a.spec_id,b.spec_vr_id,a.grade,
	 decode(a.grade,p_supplier_spec_rec.grade,1,2),b.po_line_id,
	 b.po_header_id,b.supplier_site_id,b.supplier_id,b.orgn_code
FROM gmd_specifications_b a,gmd_supplier_spec_vrs b
WHERE
     a.item_id = p_supplier_spec_rec.item_id
AND  a.delete_mark = 0
AND ((l_check_for_given_grade = 'Y' and p_supplier_spec_rec.grade = a.grade )
      OR (l_check_for_null_grade = 'Y' AND a.grade IS NULL )
      OR (l_check_for_default_grade = 'Y' AND a.grade = l_item_default_grade))
AND  a.spec_id = b.spec_id
AND  b.delete_mark = 0
AND  b.supplier_id = p_supplier_spec_rec.supplier_id
AND  p_supplier_spec_rec.date_effective between b.start_date and nvl(b.end_date,p_supplier_spec_rec.date_effective)
AND ((p_supplier_spec_rec.po_line_id = b.po_line_id)
     OR ( p_supplier_spec_rec.po_line_id IS NULL AND b.po_line_id IS NULL)
     OR (p_supplier_spec_rec.po_line_id IS NOT NULL AND b.po_line_id IS NULL ))
AND ((p_supplier_spec_rec.po_header_id = b.po_header_id)
     OR ( p_supplier_spec_rec.po_header_id IS NULL AND b.po_header_id IS NULL)
     OR (p_supplier_spec_rec.po_header_id IS NOT NULL AND b.po_header_id IS NULL ))
AND ((p_supplier_spec_rec.supplier_site_id = b.supplier_site_id)
     OR ( p_supplier_spec_rec.supplier_site_id IS NULL AND b.supplier_site_id IS NULL)
     OR (p_supplier_spec_rec.supplier_site_id IS NOT NULL AND b.supplier_site_id IS NULL ))
AND (l_orgn_code = NVL(b.orgn_code,l_orgn_code))
ORDER BY DECODE(a.grade,p_supplier_spec_rec.grade,1,2),b.po_line_id,
b.po_header_id,b.supplier_site_id,b.supplier_id,b.orgn_code ;

l_match_spec_rec   cr_match_spec%ROWTYPE;

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  FND_MSG_PUB.initialize;
  l_position := '010';

  IF p_supplier_spec_rec.item_id IS NULL
     OR p_supplier_spec_rec.date_effective IS NULL
	 OR p_supplier_spec_rec.supplier_id IS NULL THEN
       RAISE REQ_FIELDS_MISSING;
  END IF;

  IF p_supplier_spec_rec.orgn_code IS NULL THEN
     IF p_supplier_spec_rec.whse_code IS NOT NULL THEN
        BEGIN
           SELECT orgn_code INTO l_orgn_code
           FROM   IC_WHSE_MST
           WHERE  whse_code = p_supplier_spec_rec.whse_code;
        EXCEPTION
        WHEN OTHERS THEN
            RAISE INVALID_WHSE;
        END;
     ELSE
        RAISE NO_ORGN_WHSE;
     END IF;
  ELSE
     l_orgn_code := p_supplier_spec_rec.orgn_code;
  END IF;

  IF p_supplier_spec_rec.grade IS NULL THEN
    BEGIN
       SELECT grade_ctl,qc_grade INTO  l_grade_ctl ,l_item_default_grade
       FROM   IC_ITEM_MST_B
       WHERE  ITEM_ID = p_supplier_spec_rec.item_id ;

       IF l_grade_ctl = 0 THEN
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
    l_grade_ctl := 1;
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
      IF (( p_supplier_spec_rec.grade = l_match_spec_rec.grade)
      	   OR ( p_supplier_spec_rec.grade IS NULL AND l_match_spec_rec.grade IS NULL))
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
      	AND (l_orgn_code = l_match_spec_rec.orgn_code)
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
WHEN NO_ORGN_WHSE THEN
   gmd_api_pub.log_message('GMD_NO_ORGN_WHSE');
   x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
   x_return_status := FND_API.G_RET_STS_ERROR ;
   RETURN FALSE;
WHEN INVALID_WHSE THEN
   gmd_api_pub.log_message('GMD_INVALID_WHSE','WHSE',p_supplier_spec_rec.whse_code);
   x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
   x_return_status := FND_API.G_RET_STS_ERROR ;
   RETURN FALSE;
WHEN INVALID_ITEM THEN
   gmd_api_pub.log_message('GMD_INVALID_ITEM','ITEM',to_char(p_supplier_spec_rec.item_id));
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
      l_inventory_spec_rec_type.item_id          :=  p_supplier_spec_rec.item_id         ;
      l_inventory_spec_rec_type.orgn_code        :=  p_supplier_spec_rec.orgn_code       ;
      l_inventory_spec_rec_type.lot_id           :=  p_supplier_spec_rec.lot_id          ;
      l_inventory_spec_rec_type.date_effective   :=  p_supplier_spec_rec.date_effective ;
      l_inventory_spec_rec_type.exact_match	 :=  'N' ;

      --l_inventory_spec_rec_type.grade            :=  p_supplier_spec_rec.grade           ;
      l_inventory_spec_rec_type.lot_no		 :=  p_supplier_spec_rec.lot_no		 ;
      l_inventory_spec_rec_type.sublot_no	 :=  p_supplier_spec_rec.sublot_no	 ;

        -- Bug 3143796: Added whse and location to supplier sample, so passing
        --              them to inventory spec match
      l_inventory_spec_rec_type.whse_code        :=  p_supplier_spec_rec.whse_code  ;
      l_inventory_spec_rec_type.location	 :=  p_supplier_spec_rec.location	 ;

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
--|	  	  lot_id       - IN PARAMETER lot_id                                                     |
--|	  	  whse_code    - IN PARAMETER warehouse                                                  |
--|	  	  location     - IN PARAMETER location                                                   |
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
--| 						                                                         |
--| Calling Program : -  Order Management(Pick lots form)		                                 |
--| HISTORY                                                                                              |
--|    Mahesh Chandak	1-sep-2002	Created.                                                         |
--|                                                                                                      |
--+=====================================================================================================+
-- End of comments



PROCEDURE get_result_match_for_spec
                  (  p_spec_id       IN  NUMBER
                   , p_lots 	     IN  OUT NOCOPY result_lot_match_tbl
                   , x_return_status OUT NOCOPY VARCHAR2
		   , x_message_data  OUT NOCOPY VARCHAR2 ) IS

l_position   		VARCHAR2(3);
l_lot_no		VARCHAR2(32);
l_sublot_no		VARCHAR2(32);
l_whse_code		VARCHAR2(4);
l_location 		VARCHAR2(16);
l_item_id		NUMBER;
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
  AND    gs.item_id  	= l_item_id
  AND   (gs.lot_no   	= l_lot_no  OR gs.lot_no IS NULL)
  AND   (gs.sublot_no  	= l_sublot_no  OR gs.sublot_no IS NULL)
  AND   (gs.whse_code 	= l_whse_code OR gs.whse_code IS NULL)
  AND   (gs.location  	= l_location OR gs.location IS NULL )
  AND    gr.delete_mark = 0
  AND   (gr.result_value_num IS NOT NULL or gr.result_value_char IS NOT NULL)
  ORDER BY gs.lot_no,gs.date_drawn desc,gs.sublot_no,gs.location,gs.whse_code,gr.result_date desc ;
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
       IF p_lots(l_lot_counter).item_id IS NULL OR p_lots(l_lot_counter).lot_id IS NULL OR
       	 p_lots(l_lot_counter).whse_code IS NULL  THEN
       	   RAISE REQ_FIELDS_MISSING;
       END IF;

       IF p_lots(l_lot_counter).lot_id IS NOT NULL THEN
       	  BEGIN
          	SELECT lot_no,sublot_no INTO l_lot_no,l_sublot_no
           	FROM IC_LOTS_MST
           	WHERE  lot_id  =  p_lots(l_lot_counter).lot_id
           	AND    item_id =  p_lots(l_lot_counter).item_id;

       	  EXCEPTION
          WHEN OTHERS THEN
             RAISE INVALID_LOT;
          END;
       END IF;

       l_item_id   := p_lots(l_lot_counter).item_id;
       l_whse_code := p_lots(l_lot_counter).whse_code;
       l_location  := p_lots(l_lot_counter).location;

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
   gmd_api_pub.log_message('GMD_INVALID_LOT','LOT',to_char(p_lots(l_lot_counter).lot_id));
   x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
   x_return_status := FND_API.G_RET_STS_ERROR ;
WHEN OTHERS THEN
   gmd_api_pub.log_message('GMD_API_ERROR','PACKAGE','GMD_SPEC_MATCH_GRP.GET_RESULT_MATCH_FOR_SPEC','ERROR', SUBSTR(SQLERRM,1,100),'POSITION',l_position);
   x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
END get_result_match_for_spec ;


END gmd_spec_match_mig_grp;

/
