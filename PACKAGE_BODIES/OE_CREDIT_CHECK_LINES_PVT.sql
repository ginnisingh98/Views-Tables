--------------------------------------------------------
--  DDL for Package Body OE_CREDIT_CHECK_LINES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_CREDIT_CHECK_LINES_PVT" AS
-- $Header: OEXVCRLB.pls 120.16.12010000.8 2009/11/19 17:36:23 amimukhe ship $
--+=======================================================================+
--|               Copyright (c) 2001 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--|                                                                       |
--| FILENAME                                                              |
--|   OEXVCRLB.pls                                                        |
--| DESCRIPTION                                                           |
--|    Body of package OE_credit_check_lines_PVT. It contains the         |
--|    and functions used to perform line level credit checking according |
--|    to a given credit rule. It will check the amount against the credit|
--|    limits set at the customer/site.  The result returned will be      |
--|      'PASS' if it is within the customer/site limit and               |
--|      'FAIL' if it exceeds the limits.                                 |
--|                                                                       |
--| HISTORY                                                               |
--|   May-21-2001 rajkrish created                                        |
--|   Nov-07-2001          Update Comments                                |
--|   Jan-29-2002          Multi org changes                              |
--|                        ontdev => 115.20 2001/11/07 22:55:37           |
--|   Mar-16-2002 tsimmond added changes into                             |
--|                        Check_manual_released_holds                    |
--|   Mar-25-2002 tsimmond changed '>' to '>=" for manual holds           |
--|   Apr-26-2002 rajkrish BUG 2338145                                    |
--|   Jun-11-2002 rajkrish 2412678                                        |
--|   Sep-01-2002 tsimmond added code for FPI, submit AR                  |
--|                        Credit Management Review                       |
--|   Nov-17-2002 rajkrish FPI party level                                |
--|   Dec-06-2002 vto      Added NOCOPY to OUT variables                  |
--|   Jan-07-2003 tsimmond changed parameters values in Submit            |
--|                        Credit Review                                  |
--|   Feb-07-2003          Bug 2787722                                    |
--|   Mar-31-2003 vto    2846473,2878410. Handle new global for line count|
--|   Apr-01-2003 vto      2885044,2853800. Modify call to Check_Holds to |
--|                        pass in item_type and activity_name globals    |
--|   Apr-09-2003 tsimmond 2888032, changes in Submit Credit Review       |
--|   May-15-2003 vto      2894424, 2971689. New cc calling action:       |
--|                        AUTO HOLD, AUTO RELEASE.                       |
--|                        Obsolete calling action: AUTO                  |
--|   bug2948597  rajkrish                                                |
--|   Aug-22-2003 vto      Modified to support partial payments and       |
--|                        added create_by=1 for release hold source to ID|
--|                        system created/release holds (bug 3042838)     |
--|   Jan-15-2004 vto      3364726. G_crmgmt_installed instead of = TRUE  |
--|   Mar-10-2004 aksingh  3462295. Added api Update_Comments_And_Commit  |
--|=======================================================================+

--------------------
-- TYPE DECLARATIONS
--------------------

------------
-- CONSTANTS
------------
  G_PKG_NAME       CONSTANT VARCHAR2(30) := 'OE_credit_check_lines_PVT';

---------------------------
-- PRIVATE GLOBAL VARIABLES
---------------------------
  G_debug_flag  VARCHAR2(1) := NVL(OE_CREDIT_CHECK_UTIL.check_debug_flag,'N');
  G_result_out        VARCHAR2(10) := 'PASS' ;
  G_release_status    VARCHAR2(30) := 'NO' ;
  G_hdr_hold_released VARCHAR2(1)  := 'N' ;
  G_order             NUMBER;

------Global variables for Submiting AR Credit Review   -------new (FPI)

  G_total_site_exposure NUMBER;
  G_limit_currency      VARCHAR2(15);
  G_cc_limit_used       VARCHAR2(80);

  -- bug 5907331
  G_credit_limit_entity_id NUMBER;

  g_hold_reason_rec AR_CMGT_CREDIT_REQUEST_API.hold_reason_rec_type
     := AR_CMGT_CREDIT_REQUEST_API.hold_reason_rec_type(NULL);  --ER8880886

---------------------------
-- PROCEDURES AND FUNCTIONS
---------------------------
----------------------------------------------------
/* Bug 7673312 Function added to find the top_model_line_id incase of SMC ,
if that is non smc it will return the same line id. */
Function top_model_line_id_smc(p_line_id  IN NUMBER)
RETURN NUMBER
IS
l_top_model_line_id     NUMBER;

BEGIN
Select top_model_line_id
into l_top_model_line_id
from oe_order_lines_all
where line_id=p_line_id
and top_model_line_id IS NOT NULL
and ship_model_complete_flag='Y';

oe_debug_pub.add('Line Id : '||p_line_id||' passed is a part of SMC PTO line id: '||l_top_model_line_id);

RETURN(l_top_model_line_id);

EXCEPTION
WHEN OTHERS THEN
    oe_debug_pub.add('OTHERS:Line Id : '||p_line_id);
    RETURN(p_line_id);
END top_model_line_id_smc;
-- Bug 7673312

----------------------------------------------------
PROCEDURE Apply_hold_and_commit
  ( p_hold_source_rec      IN
     OE_HOLDS_PVT.Hold_Source_Rec_Type
  , x_msg_count            OUT NOCOPY NUMBER
  , x_msg_data             OUT NOCOPY VARCHAR2
  , x_return_status        OUT NOCOPY VARCHAR2
  )
IS

  PRAGMA AUTONOMOUS_TRANSACTION;


BEGIN

  OE_DEBUG_PUB.ADD(' OEXVCRLB: In Apply_hold_and_commit ');
  OE_DEBUG_PUB.ADD(' Call OE_Holds_PUB.Apply_Holds ');


  OE_Holds_PUB.Apply_Holds
          (   p_api_version       => 1.0
          ,   p_validation_level  => FND_API.G_VALID_LEVEL_NONE
          ,   p_hold_source_rec   => p_hold_source_rec
          ,   x_msg_count         => x_msg_count
          ,   x_msg_data          => x_msg_data
          ,   x_return_status     => x_return_status
          );

    OE_DEBUG_PUB.ADD(' Out OE_Holds_PUB.Apply_Holds ');
    OE_DEBUG_PUB.ADD(' x_return_status => '|| x_return_status );
        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_SUCCESS THEN

         OE_DEBUG_PUB.ADD(' Holds success ');
         OE_DEBUG_PUB.ADD(' About to Issue COMMIT');

         COMMIT;

         OE_DEBUG_PUB.ADD(' AFter Issue COMMIT');

        END IF;

  OE_DEBUG_PUB.ADD(' OEXVCRLB: OUT Apply_hold_and_commit ');

EXCEPTION
  WHEN OTHERS THEN
   rollback;
   OE_DEBUG_PUB.ADD(' Error in Apply_hold_and_commit ' );
   OE_DEBUG_PUB.ADD(' SQLERRM: '|| SQLERRM );
      OE_MSG_PUB.Add_Exc_Msg
      (   G_PKG_NAME
      ,   'Apply_hold_and_commit'
      );

     RAISE;

END Apply_hold_and_commit ;


----------------------------------------------------
-- Procedure to Update Hold Comments And Commit   --
----------------------------------------------------
PROCEDURE Update_Comments_And_Commit
  ( p_hold_source_rec  IN         OE_HOLDS_PVT.Hold_Source_Rec_Type
  , x_msg_count        OUT NOCOPY NUMBER
  , x_msg_data         OUT NOCOPY VARCHAR2
  , x_return_status    OUT NOCOPY VARCHAR2
  )
IS
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.ADD('OEXVCRLB: Entering Update_Comments_And_Commit');
    OE_DEBUG_PUB.ADD('OEXVCRLB: Before OE_Holds_PUB.Update_Hold_Comments');
  END IF;

  OE_Holds_PUB.Update_Hold_comments
      (   p_hold_source_rec   => p_hold_source_rec
      ,   x_msg_count         => x_msg_count
      ,   x_msg_data          => x_msg_data
      ,   x_return_status     => x_return_status
      );

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.ADD('OEXVCRLB: After OE_Holds_PUB.Update_Hold_Comments Status '
                     || x_return_status);
  END IF;

  IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
    IF G_debug_flag = 'Y'
    THEN
      OE_DEBUG_PUB.ADD('OEXVCRLB: Update Hold Comment Success, Issue COMMIT');
    END IF;

    COMMIT;

    IF G_debug_flag = 'Y'
    THEN
      OE_DEBUG_PUB.ADD('OEXVCRLB: After Issuing COMMIT');
    END IF;
  END IF;

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.ADD(' OEXVCRLB: Exiting Update_Comments_And_Commit');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
   rollback;
   OE_DEBUG_PUB.ADD('OEXVCRLB: Error in Update_Comments_And_Commit' );
   OE_DEBUG_PUB.ADD('SQLERRM: '|| SQLERRM );
      OE_MSG_PUB.Add_Exc_Msg
      (   G_PKG_NAME
      ,   'Update_Comments_And_Commit'
      );

     RAISE;

END Update_Comments_And_Commit ;

--------------------------------------------------
-- Build the holds table to store the different
-- type of holds on the order lines for processing
-- during the credit check cycle.
--------------------------------------------------

PROCEDURE Create_Holds_Table
  ( p_header_id	        IN   NUMBER
  , p_site_use_id       IN   NUMBER
  , x_holds_table       OUT  NOCOPY Line_Holds_Tbl_Rectype
  )
IS

 l_hold_line_seq VARCHAR2(1) := NVL(OE_SYS_PARAMETERS.VALUE('OE_HOLD_LINE_SEQUENCE'),1); --ER 6135714

  --ER 6135714 CURSOR billto_lines_csr IS
  CURSOR billto_lines_csr_1 IS --ER 6135714
    --ER 6135714 SELECT /* MOAC_SQL_NO_CHANGE */ l.line_id, l.line_number
    SELECT /* MOAC_SQL_NO_CHANGE */ l.line_id, l.line_number,0 line_total --ER 6135714
    FROM   oe_order_lines_all l,
           oe_order_headers_all h,
           ra_terms_b t
    WHERE  l.invoice_to_org_id = p_site_use_id
    AND    l.header_id         = p_header_id
    AND    h.header_id         = l.header_id
    AND    l.open_flag         = 'Y'
    AND    l.booked_flag       = 'Y'
    AND    NVL(l.invoiced_quantity,0) = 0
    AND    NVL(l.shipped_quantity,0) = 0
    AND    l.line_category_code  = 'ORDER'
    AND    l.payment_term_id   = t.term_id
    AND    t.credit_check_flag = 'Y'
    AND    (l.ato_line_id IS NULL OR l.ato_line_id = l.line_id)
    AND    (EXISTS
             (SELECT NULL
              FROM   oe_payment_types_all pt
              WHERE  pt.payment_type_code = NVL(l.payment_type_code,
                                            NVL(h.payment_type_code, 'BME'))
              AND    pt.credit_check_flag = 'Y'
              AND    NVL(pt.org_id, -99)  = NVL(h.org_id,-99))
             OR
             (l.payment_type_code IS NULL AND h.payment_type_code IS NULL)
           )
    ORDER BY l.line_id;


--ER 6135714
 CURSOR billto_lines_csr_2 IS
     SELECT l.line_id, l.line_number , NVL(unit_selling_price,0) * NVL(ordered_quantity,0)
      + decode( l.ato_line_id, null , 0, (select sum (NVL(l2.unit_selling_price,0) * NVL(l2.ordered_quantity,0)) from  oe_order_lines_all l2 where
                 l2.ato_line_id = l.line_id and l2.ato_line_id <> l2.line_id)
              )line_total
     FROM   oe_order_lines_all l,
            oe_order_headers_all h,
            ra_terms_b t
     WHERE  l.invoice_to_org_id = p_site_use_id
     AND    l.header_id         = p_header_id
     AND    h.header_id         = l.header_id
     AND    l.open_flag         = 'Y'
     AND    l.booked_flag       = 'Y'
     AND    NVL(l.invoiced_quantity,0) = 0
     AND    NVL(l.shipped_quantity,0) = 0
     AND    l.line_category_code  = 'ORDER'
     AND    l.payment_term_id   = t.term_id
     AND    t.credit_check_flag = 'Y'
     AND    (l.ato_line_id IS NULL OR l.ato_line_id = l.line_id)
     AND    (EXISTS
              (SELECT NULL
               FROM   oe_payment_types_all pt
               WHERE  pt.payment_type_code = NVL(l.payment_type_code,
                                             NVL(h.payment_type_code, 'BME'))
               AND    pt.credit_check_flag = 'Y'
               AND    NVL(pt.org_id, -99)  = NVL(h.org_id,-99))
              OR
              (l.payment_type_code IS NULL AND h.payment_type_code IS NULL)
            )
     ORDER BY nvl(l.SCHEDULE_SHIP_DATE, l.REQUEST_DATE) , l.SHIPMENT_PRIORITY_CODE, l.line_id;


   CURSOR billto_lines_csr_3 IS
     SELECT l.line_id, l.line_number , NVL(unit_selling_price,0) * NVL(ordered_quantity,0)
      + decode( l.ato_line_id, null , 0, (select sum (NVL(l2.unit_selling_price,0) * NVL(l2.ordered_quantity,0)) from  oe_order_lines_all l2 where
                 l2.ato_line_id = l.line_id and l2.ato_line_id <> l2.line_id)
              ) line_total
     FROM   oe_order_lines_all l,
            oe_order_headers_all h,
            ra_terms_b t
     WHERE  l.invoice_to_org_id = p_site_use_id
     AND    l.header_id         = p_header_id
     AND    h.header_id         = l.header_id
     AND    l.open_flag         = 'Y'
     AND    l.booked_flag       = 'Y'
     AND    NVL(l.invoiced_quantity,0) = 0
     AND    NVL(l.shipped_quantity,0) = 0
     AND    l.line_category_code  = 'ORDER'
     AND    l.payment_term_id   = t.term_id
     AND    t.credit_check_flag = 'Y'
     AND    (l.ato_line_id IS NULL OR l.ato_line_id = l.line_id)
     AND    (EXISTS
              (SELECT NULL
               FROM   oe_payment_types_all pt
               WHERE  pt.payment_type_code = NVL(l.payment_type_code,
                                             NVL(h.payment_type_code, 'BME'))
               AND    pt.credit_check_flag = 'Y'
               AND    NVL(pt.org_id, -99)  = NVL(h.org_id,-99))
              OR
              (l.payment_type_code IS NULL AND h.payment_type_code IS NULL)
            )
     ORDER BY l.SHIPMENT_PRIORITY_CODE,nvl(l.SCHEDULE_SHIP_DATE, l.REQUEST_DATE) , l.line_id;

   CURSOR billto_lines_csr_4 IS
     SELECT l.line_id, l.line_number , NVL(unit_selling_price,0) * NVL(ordered_quantity,0)
      + decode( l.ato_line_id, null , 0, (select sum (NVL(l2.unit_selling_price,0) * NVL(l2.ordered_quantity,0)) from  oe_order_lines_all l2 where
                 l2.ato_line_id = l.line_id and l2.ato_line_id <> l2.line_id)
              ) line_total
     FROM   oe_order_lines_all l,
            oe_order_headers_all h,
            ra_terms_b t
     WHERE  l.invoice_to_org_id = p_site_use_id
     AND    l.header_id         = p_header_id
     AND    h.header_id         = l.header_id
     AND    l.open_flag         = 'Y'
     AND    l.booked_flag       = 'Y'
     AND    NVL(l.invoiced_quantity,0) = 0
     AND    NVL(l.shipped_quantity,0) = 0
     AND    l.line_category_code  = 'ORDER'
     AND    l.payment_term_id   = t.term_id
     AND    t.credit_check_flag = 'Y'
     AND    (l.ato_line_id IS NULL OR l.ato_line_id = l.line_id)
     AND    (EXISTS
              (SELECT NULL
               FROM   oe_payment_types_all pt
               WHERE  pt.payment_type_code = NVL(l.payment_type_code,
                                             NVL(h.payment_type_code, 'BME'))
               AND    pt.credit_check_flag = 'Y'
               AND    NVL(pt.org_id, -99)  = NVL(h.org_id,-99))
              OR
              (l.payment_type_code IS NULL AND h.payment_type_code IS NULL)
            )
     ORDER BY line_total asc;

   CURSOR billto_lines_csr_5 IS
     SELECT l.line_id, l.line_number , NVL(unit_selling_price,0) * NVL(ordered_quantity,0)
      + decode( l.ato_line_id, null , 0, (select sum (NVL(l2.unit_selling_price,0) * NVL(l2.ordered_quantity,0)) from  oe_order_lines_all l2 where
                 l2.ato_line_id = l.line_id and l2.ato_line_id <> l2.line_id)
              ) line_total
     FROM   oe_order_lines_all l,
            oe_order_headers_all h,
            ra_terms_b t
     WHERE  l.invoice_to_org_id = p_site_use_id
     AND    l.header_id         = p_header_id
     AND    h.header_id         = l.header_id
     AND    l.open_flag         = 'Y'
     AND    l.booked_flag       = 'Y'
     AND    NVL(l.invoiced_quantity,0) = 0
     AND    NVL(l.shipped_quantity,0) = 0
     AND    l.line_category_code  = 'ORDER'
     AND    l.payment_term_id   = t.term_id
     AND    t.credit_check_flag = 'Y'
     AND    (l.ato_line_id IS NULL OR l.ato_line_id = l.line_id)
     AND    (EXISTS
              (SELECT NULL
               FROM   oe_payment_types_all pt
               WHERE  pt.payment_type_code = NVL(l.payment_type_code,
                                             NVL(h.payment_type_code, 'BME'))
               AND    pt.credit_check_flag = 'Y'
               AND    NVL(pt.org_id, -99)  = NVL(h.org_id,-99))
              OR
              (l.payment_type_code IS NULL AND h.payment_type_code IS NULL)
            )
     ORDER BY line_total desc;
--ER 6135714

  l_site_holds_tbl  	Line_Holds_Tbl_Rectype;
  row_cntr		BINARY_INTEGER := 1;
BEGIN
  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.Add('OEXVCRLB: In Create_Holds_Table');
    OE_DEBUG_PUB.Add('p_site_use_id '|| p_site_use_id );
  END IF;

/*ER 6135714
  FOR c_line IN billto_lines_csr LOOP
     l_site_holds_tbl(row_cntr).line_id     := c_line.line_id;
     l_site_holds_tbl(row_cntr).line_number := c_line.line_number;
     row_cntr := row_cntr + 1;
  END LOOP;
ER 6135714*/

--ER 6135714
 IF l_hold_line_seq = '1' THEN
  FOR c_line IN billto_lines_csr_1 LOOP
     l_site_holds_tbl(row_cntr).line_id     := c_line.line_id;
     l_site_holds_tbl(row_cntr).line_number := c_line.line_number;
     l_site_holds_tbl(row_cntr).line_total  := c_line.line_total;
     row_cntr := row_cntr + 1;
  END LOOP;
 ELSIF  l_hold_line_seq = '2' THEN
  FOR c_line IN billto_lines_csr_2 LOOP
     l_site_holds_tbl(row_cntr).line_id     := c_line.line_id;
     l_site_holds_tbl(row_cntr).line_number := c_line.line_number;
     l_site_holds_tbl(row_cntr).line_total  := c_line.line_total;
     row_cntr := row_cntr + 1;
  END LOOP;
 ELSIF  l_hold_line_seq = '3' THEN
  FOR c_line IN billto_lines_csr_3 LOOP
     l_site_holds_tbl(row_cntr).line_id     := c_line.line_id;
     l_site_holds_tbl(row_cntr).line_number := c_line.line_number;
     l_site_holds_tbl(row_cntr).line_total  := c_line.line_total;
     row_cntr := row_cntr + 1;
  END LOOP;
 ELSIF  l_hold_line_seq = '4' THEN
  FOR c_line IN billto_lines_csr_4 LOOP
     l_site_holds_tbl(row_cntr).line_id     := c_line.line_id;
     l_site_holds_tbl(row_cntr).line_number := c_line.line_number;
     l_site_holds_tbl(row_cntr).line_total  := c_line.line_total;
     row_cntr := row_cntr + 1;
  END LOOP;
 ELSIF  l_hold_line_seq = '5' THEN
  FOR c_line IN billto_lines_csr_5 LOOP
     l_site_holds_tbl(row_cntr).line_id     := c_line.line_id;
     l_site_holds_tbl(row_cntr).line_number := c_line.line_number;
     l_site_holds_tbl(row_cntr).line_total  := c_line.line_total;
     row_cntr := row_cntr + 1;
  END LOOP;
 END IF;
 --ER 6135714

  x_holds_table := l_site_holds_tbl;

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.Add('Holds table count = '|| x_holds_table.COUNT );
    OE_DEBUG_PUB.Add('OEXVCRLB: Out Create_Holds_Table');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
     IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        OE_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'Create_Holds_Table');
     END IF;
     RAISE;

END Create_Holds_Table ;

------------------------------------------------------
-- Update the values of a line in the holds table.
------------------------------------------------------

PROCEDURE Update_Holds_Table
  (  p_holds_table      IN OUT NOCOPY Line_Holds_Tbl_Rectype
   , p_line_id          IN NUMBER    DEFAULT NULL
   , p_hold             IN VARCHAR2  DEFAULT NULL
   , p_cc_limit_used    IN VARCHAR2  DEFAULT NULL
   , p_cc_profile_used  IN VARCHAR2  DEFAULT NULL
   , p_customer_id      IN NUMBER    DEFAULT NULL
   , p_site_use_id      IN NUMBER    DEFAULT NULL
   , p_party_id         IN NUMBER    DEFAULT NULL
   , p_item_category_id IN NUMBER    DEFAULT NULL
   , x_return_status   OUT NOCOPY VARCHAR2
  )
IS
BEGIN
  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.Add('OEXVCRLB: In Update_Holds_Table');
    OE_DEBUG_PUB.Add(' p_customer_id = '|| p_customer_id );
    OE_DEBUG_PUB.Add(' p_site_use_id  = '|| p_site_use_id  );
    OE_DEBUG_PUB.Add(' p_party_id     = '|| p_party_id );
  END IF;


  -- Initialize return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF p_line_id IS NULL THEN
    -- Update the whole table.
    FOR i IN 1..p_holds_table.COUNT
    LOOP
      IF p_hold = 'ITEM'
      THEN
        p_holds_table(i).hold             := p_hold;
        p_holds_table(i).limit_used       := p_cc_limit_used;
        p_holds_table(i).profile_used     := p_cc_profile_used;
        p_holds_table(i).customer_id      := p_customer_id;
        p_holds_table(i).site_use_id      := p_site_use_id;
        p_holds_table(i).item_category_id := p_item_category_id;
        p_holds_table(i).party_id         := p_party_id ;

      ELSIF NVL(p_holds_table(i).hold,'NONE') <> 'ITEM'
      THEN

        p_holds_table(i).hold             := p_hold;
        p_holds_table(i).limit_used       := p_cc_limit_used;
        p_holds_table(i).profile_used     := p_cc_profile_used;
        p_holds_table(i).customer_id      := p_customer_id;
        p_holds_table(i).site_use_id      := p_site_use_id;
        p_holds_table(i).item_category_id := p_item_category_id;
        p_holds_table(i).party_id         := p_party_id ;
      END IF;
    END LOOP;

  ELSE -- Line ID not null
    -- Update the specific line.

    FOR i IN 1..p_holds_table.COUNT
    LOOP
      IF p_holds_table(i).line_id = p_line_id
      THEN
        IF p_hold = 'ITEM'
        THEN
          p_holds_table(i).hold             := p_hold;
          p_holds_table(i).limit_used       := p_cc_limit_used;
          p_holds_table(i).profile_used     := p_cc_profile_used;
          p_holds_table(i).customer_id      := p_customer_id;
          p_holds_table(i).site_use_id      := p_site_use_id;
          p_holds_table(i).item_category_id := p_item_category_id;
          p_holds_table(i).party_id         := p_party_id ;

        ELSIF NVL(p_holds_table(i).hold,'NONE') <> 'ITEM'
        THEN
          p_holds_table(i).hold             := p_hold;
          p_holds_table(i).limit_used       := p_cc_limit_used;
          p_holds_table(i).profile_used     := p_cc_profile_used;
          p_holds_table(i).customer_id      := p_customer_id;
          p_holds_table(i).site_use_id      := p_site_use_id;
          p_holds_table(i).item_category_id := p_item_category_id;
          p_holds_table(i).party_id         := p_party_id ;

        END IF;
      END IF;
    END LOOP;
  END IF;

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.Add('OEXVCRLB: Out Update_Holds_Table');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        OE_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'Update_Holds_Table');
     END IF;
     RAISE;
END Update_Holds_Table;

 --ER 6135714------------------------------------------------------------------------------------
 --------------------------------------------------------------------------
 -- This overloaded API is created for credit check hold on order line   --
 -- based on the system parameter 'Credit Hold Sequence for Order Lines' --
 -- This Overloaded Method is created as a part of ER 6135714            --
 --------------------------------------------------------------------------

 PROCEDURE Update_Holds_Table
   (  p_holds_table      IN OUT NOCOPY Line_Holds_Tbl_Rectype
    , p_hold             IN VARCHAR2  DEFAULT NULL
    , p_cc_limit_used    IN VARCHAR2  DEFAULT NULL
    , p_cc_profile_used  IN VARCHAR2  DEFAULT NULL
    , p_customer_id      IN NUMBER    DEFAULT NULL
    , p_site_use_id      IN NUMBER    DEFAULT NULL
    , p_party_id         IN NUMBER    DEFAULT NULL
    , p_exposure         IN NUMBER
    , p_overall_credit_limit         IN NUMBER
   )
 IS
 l_amt_on_hold number := 0;
 l_amt_hold_applied number := 0;

 BEGIN
   IF G_debug_flag = 'Y'
   THEN
     OE_DEBUG_PUB.Add('OEXVCRLB: In Update_Holds_Table Overloaded');
     OE_DEBUG_PUB.Add(' p_customer_id = '|| p_customer_id );
     OE_DEBUG_PUB.Add(' p_site_use_id  = '|| p_site_use_id  );
     OE_DEBUG_PUB.Add(' p_party_id     = '|| p_party_id );
     OE_DEBUG_PUB.Add(' p_exposure   = '|| p_exposure );
     OE_DEBUG_PUB.Add(' p_overall_credit_limit     = '|| p_overall_credit_limit);
   END IF;

 -- exposure is always > credit limit for hold to be applied
    l_amt_on_hold := p_exposure - p_overall_credit_limit;

     FOR i IN reverse p_holds_table.FIRST..p_holds_table.LAST  LOOP
      IF G_debug_flag = 'Y'  THEN
        OE_DEBUG_PUB.Add('line_total='|| p_holds_table(i).line_total || ' Line-id-' ||p_holds_table(i).line_id );
      END IF;
 -- Dont apply hold if the line value is 0, uncomment below line for 0 value line Toshiba ER
 -- currently Option 4 will ensure that 0 value is NOT on hold
 -- if (l_amt_hold_applied < l_amt_on_hold AND p_holds_table(i).line_total <> 0) then

      IF (l_amt_hold_applied < l_amt_on_hold ) then  --apply hold
 	l_amt_hold_applied := l_amt_hold_applied + p_holds_table(i).line_total;
         p_holds_table(i).hold             := p_hold;
         p_holds_table(i).limit_used       := p_cc_limit_used;
         p_holds_table(i).profile_used     := p_cc_profile_used;
         p_holds_table(i).customer_id      := p_customer_id;
         p_holds_table(i).site_use_id      := p_site_use_id;
         p_holds_table(i).item_category_id := NULL;
         p_holds_table(i).party_id         := p_party_id ;
         IF G_debug_flag = 'Y' THEN
            OE_DEBUG_PUB.Add('Applying Hold on Line_id = '|| p_holds_table(i).line_id );
         END IF;
      END IF;
    END LOOP;

   IF G_debug_flag = 'Y'
   THEN
     OE_DEBUG_PUB.Add('OEXVCRLB: Out Update_Holds_Table');
   END IF;
 EXCEPTION
   WHEN OTHERS THEN
      IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         OE_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'Update_Holds_Table overloaded');
      END IF;
      RAISE;
 END Update_Holds_Table;
 --ER 6135714------------------------------------------------------------------------------------

-------------------------------------------------------
-- Check if credit hold was manually released.
--   N: No release records found
--   Y: Release records found
-------------------------------------------------------
FUNCTION Check_Manual_Released_Holds
  ( p_calling_action    IN   VARCHAR2
  , p_credit_hold_level IN   VARCHAR2
  , p_hold_id           IN   OE_HOLD_DEFINITIONS.HOLD_ID%TYPE
  , p_header_id         IN   NUMBER
  , p_line_id		IN   NUMBER
  , p_credit_check_rule_rec IN
                  OE_CREDIT_CHECK_UTIL.OE_credit_rules_rec_type
  )
RETURN VARCHAR2
IS
  l_hold_release_id           NUMBER;
  l_dummy                     VARCHAR2(1);
  l_manual_hold_exists        VARCHAR2(1) := 'N';
  l_released_rec_exists       VARCHAR2(1) := 'Y';
  l_release_date              DATE;

BEGIN
  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.Add('OEXVCRLB: In Check_Manual_Released_Holds');
    OE_DEBUG_PUB.Add('p_calling_action = '|| p_calling_action );
    OE_DEBUG_PUB.Add('Check for Header ID/Line ID: '||p_header_id||'/'
         ||p_line_id,1);
    OE_DEBUG_PUB.Add('G_delayed_request = '||
                OE_credit_engine_grp.G_delayed_request );
  END IF;

  -- Will not check if the event is UPDATE

  -- Adding 'AUTO HOLD' for bug# 4207478
  IF p_calling_action IN ( 'SHIPPING' , 'PACKING' , 'PICKING', 'AUTO HOLD')
    AND NVL(OE_credit_engine_grp.G_delayed_request, FND_API.G_FALSE )
             = FND_API.G_FALSE
  THEN
    BEGIN
      IF p_credit_hold_level = 'ORDER'
      THEN
        SELECT /* MOAC_SQL_CHANGE */ NVL(MAX(H.HOLD_RELEASE_ID),0)
        INTO   l_hold_release_id
        FROM OE_ORDER_HOLDS h,
             OE_HOLD_SOURCES_ALL s
         WHERE H.HOLD_SOURCE_ID = S.HOLD_SOURCE_ID
         AND H.HEADER_ID = p_header_id
         AND H.LINE_ID IS NULL
         AND H.HOLD_RELEASE_ID IS NOT NULL
         AND S.HOLD_ID = p_hold_id
         AND S.HOLD_ENTITY_CODE = 'O'
         AND S.HOLD_ENTITY_ID = p_header_id
         AND S.RELEASED_FLAG ='Y';
      ELSE
        SELECT /* MOAC_SQL_CHANGE */ NVL(MAX(H.HOLD_RELEASE_ID),0)
        INTO l_hold_release_id
        FROM OE_ORDER_HOLDS h,
             OE_HOLD_SOURCES_ALL s
        WHERE H.HOLD_SOURCE_ID = S.HOLD_SOURCE_ID
         AND H.HEADER_ID = p_header_id
         AND H.LINE_ID = p_line_id
         AND H.HOLD_RELEASE_ID IS NOT NULL
         AND S.HOLD_ID = p_hold_id
         AND S.HOLD_ENTITY_CODE = 'O'
         AND S.HOLD_ENTITY_ID = p_header_id
         AND S.RELEASED_FLAG ='Y';
      END IF;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        OE_DEBUG_PUB.Add
         ('No released record exist forHeader ID/Line ID: '||p_header_id||'/'||p_line_id,1);
        l_released_rec_exists := 'N';
      WHEN OTHERS THEN
        NULL;
    END;

    IF l_released_rec_exists = 'Y' THEN
       BEGIN
         SELECT
           'Y'
         , CREATION_DATE    -----added
         INTO
           l_manual_hold_exists
         , l_release_date
         FROM OE_HOLD_RELEASES
         WHERE HOLD_RELEASE_ID = l_hold_release_id
           AND RELEASE_REASON_CODE <> 'PASS_CREDIT'
           AND CREATED_BY <> 1;

         -----check if days_honor_manual_release expired
         IF p_credit_check_rule_rec.days_honor_manual_release IS NOT NULL
         THEN
           IF (l_release_date + p_credit_check_rule_rec.days_honor_manual_release >= SYSDATE )
           THEN
             l_manual_hold_exists := 'Y';
           ELSE
             l_manual_hold_exists := 'N';
           END IF;
         END IF;

       EXCEPTION
         WHEN NO_DATA_FOUND THEN
           OE_DEBUG_PUB.Add
            ('No manually released credit holds for Header ID/Line ID: '||
             p_header_id||'/'||p_line_id,1);
           l_manual_hold_exists := 'N';
         WHEN OTHERS THEN
           NULL;
       END;
    END IF;
  END IF;

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.Add('OEXVCRLB: Out Check_Manual_Released_Holds: '||l_manual_hold_exists );
  END IF;

  RETURN l_manual_hold_exists ;

EXCEPTION
  WHEN OTHERS THEN
        OE_MSG_PUB.Add_Exc_Msg
        (G_PKG_NAME, 'Check_Manual_Released_Holds' );
     RAISE;

END Check_Manual_Released_Holds;

----------------------------------------------------
--- Check for max past due invoices for
--  line level bill to
----------------------------------------------------
PROCEDURE Chk_Past_Due_Invoice
 ( p_customer_id        IN   NUMBER
 , p_site_use_id        IN   NUMBER
 , p_party_id           IN   NUMBER
 , p_credit_check_rule_rec IN
             OE_CREDIT_CHECK_UTIL.OE_credit_rules_rec_type
 , p_system_parameter_rec   IN
             OE_CREDIT_CHECK_UTIL.OE_systems_param_rec_type
 , p_credit_level       IN   VARCHAR2
 , p_usage_curr         IN   oe_credit_check_util.curr_tbl_type
 , p_include_all_flag   IN   VARCHAR2
, p_global_exposure_flag IN VARCHAR2 := 'N'
 , x_cc_result_out      OUT  NOCOPY VARCHAR2
 , x_return_status      OUT  NOCOPY VARCHAR2
 )
IS
  l_exist_flag   VARCHAR2(1);

BEGIN
  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.ADD('OEXVCRLB: In Chk_Past_Due_Invoice');
  END IF;

  -- Initialize return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- Default to pass
  x_cc_result_out := 'PASS';



  OE_CREDIT_CHECK_UTIL.Get_Past_Due_Invoice
  ( p_customer_id             => p_customer_id
  , p_site_use_id             => p_site_use_id
  , p_party_id                => p_party_id
  , p_credit_check_rule_rec  => p_credit_check_rule_rec
  , p_system_parameter_rec    => p_system_parameter_rec
  , p_credit_level            => p_credit_level
  , p_usage_curr              => p_usage_curr
  , p_include_all_flag        => p_include_all_flag
  , p_global_exposure_flag    => p_global_exposure_flag
  , x_exist_flag              => l_exist_flag
  , x_return_status           => x_return_status
  );


  IF x_return_status = FND_API.G_RET_STS_ERROR THEN
   RAISE FND_API.G_EXC_ERROR;
  ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF l_exist_flag = 'Y'
  THEN
    x_cc_result_out := 'FAIL';
  END IF;

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.ADD('l_exist_flag ' || l_exist_flag  );
    OE_DEBUG_PUB.ADD('x_cc_result_out ' || x_cc_result_out);
    OE_DEBUG_PUB.ADD('OEXVCRLB: Out Chk_Past_Due_Invoice');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        OE_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'Chk_Past_Due_invoice');
     END IF;
END Chk_Past_Due_Invoice;


-----------------------------------------------------
-- Check if line level credit holds exits for a given
-- order/line
--------------------------------------------------
FUNCTION Hold_Exists
  ( p_header_id         IN NUMBER
  , p_line_id           IN NUMBER
  , p_credit_hold_level IN   VARCHAR2
  )
RETURN BOOLEAN IS
  l_hold_result          VARCHAR2(30);
  l_return_status        VARCHAR2(30);
  l_msg_count            NUMBER;
  l_msg_data             VARCHAR2(2000);
BEGIN
  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.ADD('OEXVCRLB: In Hold_Exists');
  END IF;

  IF p_credit_hold_level = 'ORDER'
  THEN
    IF G_debug_flag = 'Y'
    THEN
      OE_DEBUG_PUB.ADD('OEXVCRLB: Check for credit check holds for Header ID : '
                 || p_header_id,1);
    END IF;

    OE_HOLDS_PUB.Check_Holds
                      ( p_api_version    => 1.0
                      , p_header_id      => p_header_id
                      , p_hold_id        => 1
                      , p_wf_item        => OE_Credit_Engine_GRP.G_cc_hold_item_type
                      , p_wf_activity    => OE_Credit_Engine_GRP.G_cc_hold_activity_name
                      , p_entity_code    => 'O'
                      , p_entity_id      => p_header_id
                      , x_result_out     => l_hold_result
                      , x_msg_count      => l_msg_count
                      , x_msg_data       => l_msg_data
                      , x_return_status  => l_return_status
                      );
  ELSE
    IF G_debug_flag = 'Y'
    THEN
      OE_DEBUG_PUB.ADD('OEXVCRLB: Check for holds for Header/Line ID : '
                 || p_header_id || '/' || p_line_id,1);
    END IF;

    OE_HOLDS_PUB.Check_Holds
		      ( p_api_version    => 1.0
                      , p_header_id      => p_header_id
		      , p_line_id        => p_line_id
		      , p_hold_id        => 1
                      , p_wf_item        => OE_Credit_Engine_GRP.G_cc_hold_item_type
                      , p_wf_activity    => OE_Credit_Engine_GRP.G_cc_hold_activity_name
		      , p_entity_code    => 'O'
		      , p_entity_id      => p_header_id
		      , x_result_out     => l_hold_result
		      , x_msg_count      => l_msg_count
		      , x_msg_data       => l_msg_data
		      , x_return_status  => l_return_status
		      );
  END IF;

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.ADD('OEXVCRLB: Out Check_Holds');
  END IF;

  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
   RAISE FND_API.G_EXC_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF l_hold_result = FND_API.G_TRUE THEN
    return TRUE;
  ELSE
    return FALSE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
        OE_MSG_PUB.Add_Exc_Msg
        (G_PKG_NAME, 'Hold_Exists');
     RAISE;

END Hold_Exists;

  ---------------------------------------------------
  -- Write appropriate message to either the message|
  -- table or to the logfile if called from a       |
  -- concurrent program.                            |
  ---------------------------------------------------

PROCEDURE Write_Hold_Message
  ( p_calling_action	  IN VARCHAR2
  , p_cc_limit_used       IN VARCHAR2 DEFAULT NULL
  , p_cc_profile_used     IN VARCHAR2 DEFAULT NULL
  , p_order_number        IN NUMBER
  , p_line_number         IN NUMBER
  , p_customer_name	  IN VARCHAR2 DEFAULT NULL
  , p_site_name           IN VARCHAR2 DEFAULT NULL
  , p_party_name          IN VARCHAR2 DEFAULT NULL
  , p_item_category       IN VARCHAR2 DEFAULT NULL
  , x_comment            OUT NOCOPY VARCHAR2
  )
IS
  l_comment		VARCHAR2(2000);
  l_cc_profile_used 	VARCHAR2(30);
  l_calling_activity   VARCHAR2(50);   --ER#7479609

BEGIN
  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.Add('OEXVCRLB: In Write_Hold_Message');
  END IF;

  -- Write to message stack anyway regardless of the calling action
  -- added IF for bug 5467793
  --bug	7207292, reverting fix 5467793 as multiple messages are now shown in processing messages window
  --IF NVL(OE_credit_engine_GRP.G_delayed_request, FND_API.G_FALSE ) =
  --        FND_API.G_FALSE THEN
  IF p_cc_limit_used <> 'ITEM' THEN
    -- bug 4002820
    IF INSTR(p_cc_limit_used, ',') > 0 THEN
      l_cc_profile_used := OE_CREDIT_CHECK_UTIL.Get_CC_Lookup_Meaning('OE_CC_PROFILE', p_cc_profile_used);
      FND_MESSAGE.Set_Name('ONT','OE_CC_LINE_HOLD_MSG');
      FND_MESSAGE.Set_Token('ORDER_NUMBER' ,p_order_number);
      FND_MESSAGE.Set_Token('LINE_NUMBER'  ,p_line_number);
      FND_MESSAGE.Set_Token('LIMIT_USED',p_cc_limit_used);
      FND_MESSAGE.Set_Token('CC_PROFILE',l_cc_profile_used);
      l_comment := SUBSTR(FND_MESSAGE.GET,1,2000);
      FND_MESSAGE.Set_Name('ONT','OE_CC_LINE_HOLD_MSG');
      FND_MESSAGE.Set_Token('ORDER_NUMBER' ,p_order_number);
      FND_MESSAGE.Set_Token('LINE_NUMBER'  ,p_line_number);
      FND_MESSAGE.Set_Token('LIMIT_USED',p_cc_limit_used);
      FND_MESSAGE.Set_Token('CC_PROFILE',l_cc_profile_used);
      OE_MSG_PUB.Add;

    ELSE
      IF p_cc_profile_used = 'SITE' THEN
        FND_MESSAGE.Set_Name('ONT','OE_CC_HLD_'||p_cc_limit_used||'_'||
                                               p_cc_profile_used);
        FND_MESSAGE.Set_Token('ORDER_NUMBER' ,p_order_number);
        FND_MESSAGE.Set_Token('LINE_NUMBER'  ,p_line_number);
        FND_MESSAGE.Set_Token('CUSTOMER_NAME',p_customer_name);
        FND_MESSAGE.Set_Token('SITE_NAME'    ,p_site_name);
        l_comment := SUBSTR(FND_MESSAGE.GET,1,2000);

        FND_MESSAGE.Set_Name('ONT','OE_CC_HLD_'||p_cc_limit_used||'_'||
                                               p_cc_profile_used);
        FND_MESSAGE.Set_Token('ORDER_NUMBER',p_order_number);
        FND_MESSAGE.Set_Token('LINE_NUMBER',p_line_number);
        FND_MESSAGE.Set_Token('CUSTOMER_NAME',p_customer_name);
        FND_MESSAGE.Set_Token('SITE_NAME'    ,p_site_name);
        OE_MSG_PUB.Add;
      ELSIF p_cc_profile_used =  'CUSTOMER'
      THEN
        FND_MESSAGE.Set_Name('ONT','OE_CC_HLD_'||p_cc_limit_used||'_'||
                                               p_cc_profile_used);
        FND_MESSAGE.Set_Token('ORDER_NUMBER' ,p_order_number);
        FND_MESSAGE.Set_Token('LINE_NUMBER'  ,p_line_number);
        FND_MESSAGE.Set_Token('CUSTOMER_NAME',p_customer_name);
        l_comment := SUBSTR(FND_MESSAGE.GET,1,2000);

        FND_MESSAGE.Set_Name('ONT','OE_CC_HLD_'||p_cc_limit_used||'_'||
                                               p_cc_profile_used);
        FND_MESSAGE.Set_Token('ORDER_NUMBER',p_order_number);
        FND_MESSAGE.Set_Token('LINE_NUMBER',p_line_number);
        FND_MESSAGE.Set_Token('CUSTOMER_NAME',p_customer_name);
        OE_MSG_PUB.Add;

      ELSIF p_cc_profile_used =  'PARTY'
      THEN
        FND_MESSAGE.Set_Name('ONT','OE_CC_HLD_'||p_cc_limit_used||'_'||
                                               p_cc_profile_used);
        FND_MESSAGE.Set_Token('ORDER_NUMBER' ,p_order_number);
        FND_MESSAGE.Set_Token('LINE_NUMBER'  ,p_line_number);
        FND_MESSAGE.Set_Token('PARTY_NAME',p_party_name );
        l_comment := SUBSTR(FND_MESSAGE.GET,1,2000);

        FND_MESSAGE.Set_Name('ONT','OE_CC_HLD_'||p_cc_limit_used||'_'||
                                               p_cc_profile_used);
        FND_MESSAGE.Set_Token('ORDER_NUMBER',p_order_number);
        FND_MESSAGE.Set_Token('LINE_NUMBER',p_line_number);
        FND_MESSAGE.Set_Token('PARTY_NAME',p_party_name) ;
        OE_MSG_PUB.Add;

        ELSIF p_cc_profile_used = 'DEFAULT' THEN
        FND_MESSAGE.Set_Name('ONT','OE_CC_HLD_'||p_cc_limit_used||'_'||
                                               p_cc_profile_used);
        FND_MESSAGE.Set_Token('ORDER_NUMBER',p_order_number);
        FND_MESSAGE.Set_Token('LINE_NUMBER',p_line_number);
        l_comment := SUBSTR(FND_MESSAGE.GET,1,2000);

        FND_MESSAGE.Set_Name('ONT','OE_CC_HLD_'||p_cc_limit_used||'_'||
                                               p_cc_profile_used);
        FND_MESSAGE.Set_Token('ORDER_NUMBER',p_order_number);
        FND_MESSAGE.Set_Token('LINE_NUMBER',p_line_number);
        OE_MSG_PUB.Add;
      END IF;
    END IF;
  ELSE
      FND_MESSAGE.Set_Name('ONT','OE_CC_HLD_'||p_cc_limit_used||'_'||
                                                'CATEGORY');
      FND_MESSAGE.Set_Token('ORDER_NUMBER',p_order_number);
      FND_MESSAGE.Set_Token('LINE_NUMBER',p_line_number);
      FND_MESSAGE.Set_Token('CATEGORY',p_item_category);
      l_comment := SUBSTR(FND_MESSAGE.GET,1,2000);

      FND_MESSAGE.Set_Name('ONT','OE_CC_HLD_'||p_cc_limit_used||'_'||
                                                'CATEGORY');
      FND_MESSAGE.Set_Token('ORDER_NUMBER',p_order_number);
      FND_MESSAGE.Set_Token('LINE_NUMBER',p_line_number);
      FND_MESSAGE.Set_Token('CATEGORY',p_item_category);
      OE_MSG_PUB.Add;
  END IF;
  --END IF;  -- bug 5467793
  --
  -- Save messages on message stack to message table
  -- Give a dummy request id
  -- rajesh
  --OE_MSG_PUB.Save_Messages(1);
  --OE_MSG_PUB.Delete_Msg(OE_MSG_PUB.G_msg_count);
  --
  -- Write to logfile if original call was from a concurrent program
  --
  IF p_calling_action = 'AUTO HOLD' THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Order Number: '||TO_CHAR(p_order_number)
      ||'  Line Number: '||TO_CHAR(p_line_number)
      ||' placed on credit check hold.');
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Hold Comment: '||SUBSTR(l_comment,1,1000));
  END IF;

--ER#7479609 start
   IF OE_Verify_Payment_PUB.G_init_calling_action = 'AUTO HOLD' THEN
      l_calling_activity := 'Credit Check Processor';
   ELSE
      l_calling_activity := InitCap(OE_Verify_Payment_PUB.G_init_calling_action);
   END IF;

   FND_MESSAGE.Set_Name('ONT','OE_CC_HOLD_ACT_COM');
   FND_MESSAGE.Set_Token('CALLING_ACTIVITY',l_calling_activity);
   FND_MESSAGE.Set_Token('CREDIT_CHECK_RULE',OE_Verify_Payment_PUB.G_credit_check_rule);

   l_comment := l_comment||SUBSTR(FND_MESSAGE.GET,1,2000);
--ER#7479609 end

  x_comment := NVL(OE_Credit_Engine_GRP.G_currency_error_msg,l_comment);

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.ADD(' x_comment '|| x_comment );
    OE_DEBUG_PUB.Add('OEXVCRLB: Out Write_Hold_Message');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
        OE_MSG_PUB.Add_Exc_Msg
        (G_PKG_NAME, 'Write_Hold_Message');
     RAISE;

END Write_Hold_Message;

---------------------------------------------------
-- Write release message to the message table     |
-- table and  to the logfile if called from a     |
-- concurrent program.                            |
---------------------------------------------------

PROCEDURE Write_Release_Message (
    p_calling_action      IN VARCHAR2
  , p_order_number        IN NUMBER
  , p_line_number         IN NUMBER
 )
IS
BEGIN
  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.Add('OEXVCRLB: In Write_Release_Message');
  END IF;

  IF p_calling_action = 'AUTO RELEASE' THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Order Number: '||TO_CHAR(p_order_number)
      ||'  Line Number: '||TO_CHAR(p_line_number)
      ||' released from credit check hold.');
  END IF;

  FND_MESSAGE.Set_Name('ONT','OE_CC_HLD_REMOVED');
  FND_MESSAGE.Set_Token('ORDER_NUMBER',p_order_number);
  FND_MESSAGE.Set_Token('LINE_NUMBER',p_line_number);
  OE_MSG_PUB.Add;
  --- rajesh
  --OE_MSG_PUB.Save_Messages(1);
  --
  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.Add('OEXVCRLB: Out Write_Release_Message');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
        OE_MSG_PUB.Add_Exc_Msg
        (G_PKG_NAME, 'Write_Release_Message');
     RAISE;

END Write_Release_Message;

---------------------------------------------------
-- Write appropriate message to either the message|
-- table or to the logfile if called from a       |
-- concurrent program for order level credit hold |
---------------------------------------------------

PROCEDURE Write_Order_Hold_Msg
  (
    p_calling_action      IN VARCHAR2
  , p_cc_limit_used       IN VARCHAR2 DEFAULT NULL
  , p_cc_profile_used     IN VARCHAR2 DEFAULT NULL
  , p_order_number        IN NUMBER
  , p_item_category       IN VARCHAR2 DEFAULT NULL
  , x_comment            OUT NOCOPY VARCHAR2
  )
IS
  l_comment     	VARCHAR2(2000);
  l_cc_profile_used	VARCHAR2(30);
  l_calling_activity   VARCHAR2(50);   --ER#7479609

BEGIN
  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.Add('OEXVCRLB: In Write_Order_Hold_Msg');
  END IF;

  -- Write to message stack anyway regardless of the calling action
  IF p_cc_limit_used <> 'ITEM' THEN
    -- bug 4002820
    IF INSTR(p_cc_limit_used, ',') > 0 THEN

      --bug 4153299
      l_cc_profile_used := OE_CREDIT_CHECK_UTIL.Get_CC_Lookup_Meaning('OE_CC_PROFILE', p_cc_profile_used);

      FND_MESSAGE.Set_Name('ONT','OE_CC_HOLD_MSG');
      FND_MESSAGE.Set_Token('LIMIT_USED',p_cc_limit_used);
      FND_MESSAGE.Set_Token('CC_PROFILE',l_cc_profile_used);
      l_comment := SUBSTR(FND_MESSAGE.GET,1,2000);
      FND_MESSAGE.Set_Name('ONT','OE_CC_HOLD_MSG');
      FND_MESSAGE.Set_Token('LIMIT_USED',p_cc_limit_used);
      FND_MESSAGE.Set_Token('CC_PROFILE',l_cc_profile_used);
      OE_MSG_PUB.Add;
    ELSE
      FND_MESSAGE.Set_Name('ONT','OE_CC_HOLD_'||p_cc_limit_used||'_'||
                                                p_cc_profile_used);
      l_comment := SUBSTR(FND_MESSAGE.GET,1,2000);
      FND_MESSAGE.Set_Name('ONT','OE_CC_HOLD_'||p_cc_limit_used||'_'||
                                               p_cc_profile_used);
      OE_MSG_PUB.Add;
    END IF;
  ELSE
      FND_MESSAGE.Set_Name('ONT','OE_CC_HOLD_'||p_cc_limit_used||'_CATEGORY');
      FND_MESSAGE.Set_Token('CATEGORY',p_item_category);
      l_comment := SUBSTR(FND_MESSAGE.GET,1,2000);
      FND_MESSAGE.Set_Name('ONT','OE_CC_HOLD_'||p_cc_limit_used||'_'||
                                                'CATEGORY');
      FND_MESSAGE.Set_Token('CATEGORY',p_item_category);
      OE_MSG_PUB.Add;
  END IF;
  --
  -- Write to logfile if original call was from a concurrent program
  --
  IF p_calling_action = 'AUTO HOLD' THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Order '||TO_CHAR(p_order_number)
      ||': Credit check hold applied');
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Hold Comment: '||SUBSTR(l_comment,1,1000));
  END IF;

--ER#7479609 start
   IF OE_Verify_Payment_PUB.G_init_calling_action = 'AUTO HOLD' THEN
      l_calling_activity := 'Credit Check Processor';
   ELSE
      l_calling_activity := InitCap(OE_Verify_Payment_PUB.G_init_calling_action);
   END IF;

      FND_MESSAGE.Set_Name('ONT','OE_CC_HOLD_ACT_COM');
      FND_MESSAGE.Set_Token('CALLING_ACTIVITY',l_calling_activity);
      FND_MESSAGE.Set_Token('CREDIT_CHECK_RULE',OE_Verify_Payment_PUB.G_credit_check_rule);

     l_comment := l_comment||SUBSTR(FND_MESSAGE.GET,1,2000);
--ER#7479609 end

  x_comment := l_comment;

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.Add(' x_comment '|| x_comment );
    OE_DEBUG_PUB.Add('OEXVCRLB: Out Write_Order_Hold_Msg');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
        OE_MSG_PUB.Add_Exc_Msg
        (G_PKG_NAME, 'Write_Order_Hold_Msg');
     RAISE;

END Write_Order_Hold_Msg;

---------------------------------------------------
-- Write release message to the screen or to the
-- log file if called from a concurrent program.
---------------------------------------------------
PROCEDURE Write_Order_Release_Msg
 (  p_calling_action      IN VARCHAR2
  , p_order_number        IN NUMBER
 )
IS
BEGIN
  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.Add('OEXVCRLB: In Write_Order_Release_Msg');
  END IF;

  IF p_calling_action = 'AUTO RELEASE' THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Order '||TO_CHAR(p_order_number)
                      ||': Credit check hold released.');
  ELSE
    FND_MESSAGE.Set_Name('ONT','OE_CC_HOLD_REMOVED');
    OE_MSG_PUB.Add;
  END IF;
  --
  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.Add('OEXVCRLB: Out Write_Order_Release_Msg');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
        OE_MSG_PUB.Add_Exc_Msg
        (G_PKG_NAME, 'Write_Order_Release_Msg');
     RAISE;

END Write_Order_Release_Msg;

---------------------------------------------------
-- Apply credit check hold on the specified order
-- line.
---------------------------------------------------
/*
** Bug # 3416932
** Replaced call to Apply_Hold_And_Commit with Apply_Holds
** and made this complete procedure part of Autonomous Trxn
*/
/*
** Bug # 3415608 and 3430235
** Reverted changes done under bug # 3386382.
** Introduced new procedure Update_Comments_And_Commit to
** Update and Commit Hold Comments. Apply_Holds_And_Commit
** And Update_Comments_And_Commit are now called whenever
** Calling Action is Picking, Packing or Shipping ELSE
** Apply_Holds and Update_Hold_Comments are called.
*/

PROCEDURE Apply_Line_CC_Hold
 (  p_header_id            IN NUMBER
  , p_order_number         IN NUMBER
  , p_line_id              IN NUMBER
  , p_line_number          IN NUMBER
  , p_calling_action       IN VARCHAR2   DEFAULT 'BOOKING'
  , p_cc_limit_used        IN VARCHAR2
  , p_cc_profile_used      IN VARCHAR2
  , p_party_id             IN NUMBER     DEFAULT NULL
  , p_customer_id          IN NUMBER     DEFAULT NULL
  , p_site_use_id          IN NUMBER     DEFAULT NULL
  , p_item_category_id     IN NUMBER     DEFAULT NULL
  , p_credit_hold_level    IN VARCHAR2
  , p_credit_check_rule_rec IN
                   OE_CREDIT_CHECK_UTIL.OE_credit_rules_rec_type
  , x_cc_result_out        OUT NOCOPY VARCHAR2
  )
IS

  -- Cursor to select the customer name
  CURSOR customer_name_csr IS
    SELECT name
    FROM   oe_sold_to_orgs_v
    WHERE  customer_id = p_customer_id;

  CURSOR party_name_csr IS
    SELECT party_name
    FROM   hz_parties
    WHERE  party_id = p_party_id  ;

  -- Cursor to select site use code
  CURSOR site_name_csr IS
    SELECT location
    FROM   hz_cust_site_uses
    WHERE  site_use_id = p_site_use_id;
  -- Cursor to select item category
  CURSOR item_category_csr IS
    SELECT description
    FROM   mtl_categories
    WHERE  category_id = p_item_category_id;
  --
  l_customer_name      VARCHAR2(360);
  l_party_name         VARCHAR2(360);
  l_item_category      VARCHAR2(240):= NULL;
  l_site_name          VARCHAR2(40);
  l_cc_result_out      VARCHAR2(30) := 'FAIL_NONE';
  l_hold_exists        VARCHAR2(1) := NULL ;
  l_msg_count          NUMBER := 0;
  l_msg_data           VARCHAR2(2000);
  l_return_status      VARCHAR2(30);
  l_hold_comment       VARCHAR2(2000);
  l_hold_source_rec    OE_HOLDS_PVT.Hold_Source_Rec_Type :=
                       OE_HOLDS_PVT.G_MISS_Hold_Source_REC;
BEGIN
  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.Add('OEXVCRLB: In Apply_Line_CC_Hold');
    OE_DEBUG_PUB.Add('p_calling_action => '|| p_calling_action );
    OE_DEBUG_PUB.Add('p_header_id => '|| p_header_id);
    OE_DEBUG_PUB.Add('p_line_id => '|| p_line_id );
    OE_DEBUG_PUB.Add('p_cc_limit_used => '|| p_cc_limit_used );
    OE_DEBUG_PUB.Add('---------------------------------');
  END IF;
  --
  --
  IF p_cc_limit_used <> 'ITEM' THEN
    --
    -- Get the customer name
    --
    OPEN customer_name_csr;
    FETCH customer_name_csr INTO l_customer_name;
    CLOSE customer_name_csr;
    --
    -- Get the site use location
    --
    OPEN site_name_csr;
    FETCH site_name_csr INTO l_site_name;
    CLOSE site_name_csr;

    OPEN party_name_csr;
    FETCH party_name_csr INTO l_party_name;
    CLOSE party_name_csr;
  ELSE
    --
    -- Get item category if it is passed in
    --
    IF p_cc_limit_used = 'ITEM' THEN
      OPEN item_category_csr;
      FETCH item_category_csr INTO l_item_category;
      CLOSE item_category_csr;
    END IF;
  END IF;
  --
  -- Set hold source
  --
  l_hold_source_rec.hold_id          := 1;           -- credit hold
  l_hold_source_rec.hold_entity_code := 'O';         -- order hold
  l_hold_source_rec.hold_entity_id   := p_header_id; -- order header
  --
  IF Hold_Exists( p_header_id         => p_header_id
                , p_line_id           => p_line_id
                , p_credit_hold_level => p_credit_hold_level
                ) THEN
    G_line_hold_count := G_line_hold_count + 1;
    Write_Hold_Message
        (
           p_calling_action      => p_calling_action
         , p_cc_limit_used       => p_cc_limit_used
         , p_cc_profile_used     => p_cc_profile_used
         , p_order_number        => p_order_number
         , p_line_number         => p_line_number
         , p_customer_name       => l_customer_name
         , p_site_name           => l_site_name
         , p_party_name          => l_party_name
         , p_item_category       => l_item_category
         , x_comment             => l_hold_comment
        );

    G_result_out := 'FAIL' ;
    l_hold_source_rec.hold_comment := l_hold_comment;
    l_hold_source_rec.line_id := p_line_id;

    IF G_debug_flag = 'Y'
    THEN
       OE_DEBUG_PUB.Add('OEXVCRLB: Hold already applied on Header/Line ID:' ||
        p_header_id || '/' || p_line_id, 1);
    END IF;

    IF NVL(p_calling_action, 'BOOKING') IN ('SHIPPING','PACKING','PICKING')
    THEN
      IF G_debug_flag = 'Y'
      THEN
        OE_DEBUG_PUB.ADD('OEXVCRLB: Call Update_Comments_And_Commit');
      END IF;
      --IF NVL(OE_credit_engine_GRP.G_delayed_request, FND_API.G_FALSE ) =
          --FND_API.G_FALSE THEN --bug6120327

      Update_Comments_And_Commit
      (   p_hold_source_rec   => l_hold_source_rec
      ,   x_msg_count         => l_msg_count
      ,   x_msg_data          => l_msg_data
      ,   x_return_status     => l_return_status
      );

     -- END IF;
      IF G_debug_flag = 'Y'
      THEN
        OE_DEBUG_PUB.ADD('OEXVCRLB: Out Update_Comments_And_Commit');
      END IF;

    ELSIF  NVL( p_calling_action,'BOOKING') IN ('BOOKING','UPDATE','AUTO HOLD')
    THEN
      IF G_debug_flag = 'Y'
      THEN
        OE_DEBUG_PUB.ADD('OEXVCRLB: Call OE_Holds_PUB.Update_Hold_Comments directly');
      END IF;
      --IF NVL(OE_credit_engine_GRP.G_delayed_request, FND_API.G_FALSE ) =
          --FND_API.G_FALSE THEN --bug6120327

      OE_Holds_PUB.Update_Hold_comments
      (   p_hold_source_rec   => l_hold_source_rec
      ,   x_msg_count         => l_msg_count
      ,   x_msg_data          => l_msg_data
      ,   x_return_status     => l_return_status
      );

      --END IF;

      IF G_debug_flag = 'Y'
      THEN
        OE_DEBUG_PUB.ADD('OEXVCRLB: Out OE_Holds_PUB.Update_Hold_Comments directly');
      END IF;
    END IF;

    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
      IF G_debug_flag = 'Y' THEN
        OE_DEBUG_PUB.ADD
             ('OEXVCRLB: Updated Comments on Header/Line ID:' ||
                      p_header_id || '/' ||
                      p_line_id, 1);
      END IF;
    END IF;
  ELSE
    IF Check_Manual_Released_Holds
      ( p_calling_action => p_calling_action
      , p_credit_hold_level => p_credit_hold_level
      ,p_hold_id        => 1
      ,p_header_id      => p_header_id
      --,p_line_id        => p_line_id
      ,p_line_id        => top_model_line_id_smc(p_line_id)   -- Bug 7673312
      ,p_credit_check_rule_rec=>p_credit_check_rule_rec
      ) = 'N'
    THEN
      G_result_out := 'FAIL' ;

      Write_Hold_Message
        (
           p_calling_action      => p_calling_action
         , p_cc_limit_used       => p_cc_limit_used
         , p_cc_profile_used     => p_cc_profile_used
         , p_order_number        => p_order_number
         , p_line_number         => p_line_number
         , p_customer_name       => l_customer_name
         , p_site_name           => l_site_name
         , p_item_category       => l_item_category
         , x_comment             => l_hold_comment
        );
      l_hold_source_rec.hold_comment := l_hold_comment;
      l_hold_source_rec.line_id := p_line_id;
      --
      ------------------------------------------------------------
       -- Call for all actions except for the
       -- concurrent program credit check processor
       IF NVL(p_calling_action, 'BOOKING') IN ('SHIPPING','PACKING','PICKING')
       THEN

        IF G_debug_flag = 'Y'
        THEN
          OE_DEBUG_PUB.ADD('OEXVCRLB: Call Apply_hold_and_commit ');
        END IF;

--8478151
       IF Oe_Globals.G_calling_source = 'ONT' and p_calling_action = 'SHIPPING'
       THEN
         OE_Holds_PUB.Apply_Holds
            (   p_api_version       => 1.0
            ,   p_validation_level  => FND_API.G_VALID_LEVEL_NONE
            ,   p_hold_source_rec   => l_hold_source_rec
            ,   x_msg_count         => l_msg_count
            ,   x_msg_data          => l_msg_data
            ,   x_return_status     => l_return_status
            );
       ELSE --8478151

        Apply_hold_and_commit
           ( p_hold_source_rec   => l_hold_source_rec
            , x_msg_count        => l_msg_count
            , x_msg_data         => l_msg_data
            , x_return_status    => l_return_status
            );

       END IF;   --8478151


        IF G_debug_flag = 'Y'
        THEN
          OE_DEBUG_PUB.ADD('OEXVCRLB: Out Apply_hold_and_commit ');
        END IF;


       ELSIF  NVL( p_calling_action,'BOOKING') IN ('BOOKING','UPDATE','AUTO HOLD')
       THEN
         IF G_debug_flag = 'Y'
         THEN
           OE_DEBUG_PUB.ADD('OEXVCRLB: Call OE_Holds_PUB.Apply_Holds directly');
         END IF;

         OE_Holds_PUB.Apply_Holds
            (   p_api_version       => 1.0
            ,   p_validation_level  => FND_API.G_VALID_LEVEL_NONE
            ,   p_hold_source_rec   => l_hold_source_rec
            ,   x_msg_count         => l_msg_count
            ,   x_msg_data          => l_msg_data
            ,   x_return_status     => l_return_status
            );

         IF G_debug_flag = 'Y'
         THEN
           OE_DEBUG_PUB.ADD('OEXVCRLB: Out OE_Holds_PUB.Apply_Holds directly');
         END IF;
       END IF;
       -------------------------------------------------------
       IF G_debug_flag = 'Y' THEN
         OE_DEBUG_PUB.ADD('OEXVCRLB: Apply Holds status '|| l_return_status );
       END IF;

       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
         IF G_debug_flag = 'Y' THEN
           OE_DEBUG_PUB.ADD
           ('OEXVCRLB: Applied credit check hold on Header/Line ID:' ||
                      p_header_id || '/' ||
                      p_line_id, 1);
         END IF;
       END IF;
       l_cc_result_out := 'FAIL_HOLD';
       G_line_hold_count := G_line_hold_count + 1;
    END IF; -- Check manual holds
  END IF; -- Check hold exist
  -- The result out is FAIL_NONE for AUTO RELEASE calling action
  x_cc_result_out     := l_cc_result_out;

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.Add('OEXVCRLB: Apply_Line_CC_Hold Result = '|| x_cc_result_out );
    OE_DEBUG_PUB.Add('OEXVCRLB: Out Apply_Line_CC_Hold');
  END IF;


EXCEPTION
  WHEN OTHERS THEN
        OE_MSG_PUB.Add_Exc_Msg
        (G_PKG_NAME, 'Apply_Line_CC_Hold');
     RAISE;

END Apply_Line_CC_Hold;

---------------------------------------------------
-- Apply credit check hold on the specified order
---------------------------------------------------
/*
** Bug # 3416932: Made this procedure an Autonomous Trxn
** Bug # 3462295: Reverted back the autonomous change
*/
PROCEDURE Apply_Order_CC_Hold
 (  p_header_id            IN NUMBER
  , p_order_number         IN NUMBER
  , p_calling_action       IN VARCHAR2   DEFAULT 'BOOKING'
  , p_cc_limit_used        IN VARCHAR2
  , p_cc_profile_used      IN VARCHAR2
  , p_item_category_id     IN NUMBER     DEFAULT NULL
  , p_credit_hold_level    IN VARCHAR2
  , p_credit_check_rule_rec IN
                  OE_CREDIT_CHECK_UTIL.OE_credit_rules_rec_type
  , x_cc_result_out        OUT NOCOPY VARCHAR2
  )
IS

  -- Cursor to select item category
  CURSOR item_category_csr IS
    SELECT description
    FROM   mtl_categories
    WHERE  category_id = p_item_category_id;

  l_notification_id    NUMBER;
  l_item_category      VARCHAR2(240):= NULL;
  l_cc_result_out      VARCHAR2(30) := 'FAIL_NONE';
  l_hold_exists        VARCHAR2(1) := NULL ;
  l_msg_count          NUMBER := 0;
  l_msg_data           VARCHAR2(2000);
  l_return_status      VARCHAR2(30);
  l_hold_comment       VARCHAR2(2000);
  l_hold_source_rec    OE_HOLDS_PVT.Hold_Source_Rec_Type :=
                       OE_HOLDS_PVT.G_MISS_Hold_Source_REC;
BEGIN
  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.Add('OEXVCRLB: In Apply_Order_CC_Hold');
  END IF;
  --
  -- Get the order number for notification
  --
  IF p_cc_limit_used = 'ITEM' THEN
    OPEN item_category_csr;
    FETCH item_category_csr INTO l_item_category;
    CLOSE item_category_csr;
  END IF;

  --
  -- Set hold source
  --
  l_hold_source_rec.hold_id          := 1;           -- credit hold
  l_hold_source_rec.hold_entity_code := 'O';         -- order hold
  l_hold_source_rec.hold_entity_id   := p_header_id; -- order header
  --
  IF Hold_Exists( p_header_id => p_header_id
                , p_line_id   => NULL
                , p_credit_hold_level =>
                  p_credit_hold_level
                 ) THEN
      Write_Order_Hold_Msg
        (
           p_calling_action      => p_calling_action
         , p_cc_limit_used       => p_cc_limit_used
         , p_cc_profile_used     => p_cc_profile_used
         , p_order_number        => p_order_number
         , p_item_category       => l_item_category
         , x_comment             => l_hold_comment
        );

    G_result_out := 'FAIL' ;
    l_hold_source_rec.hold_comment := l_hold_comment;

    IF G_debug_flag = 'Y'
    THEN
       OE_DEBUG_PUB.Add('OEXVCRLB: Hold already applied on Header ID:' ||
        p_header_id, 1);
    END IF;
  ELSE
    IF Check_Manual_Released_Holds(
       p_calling_action    => p_calling_action
     , p_credit_hold_level =>
                 p_credit_hold_level
      ,p_hold_id           => 1
      ,p_header_id         => p_header_id
      ,p_line_id           => NULL
      ,p_credit_check_rule_rec=>p_credit_check_rule_rec
      ) = 'N'
    THEN
      G_result_out := 'FAIL' ;

      IF G_debug_flag = 'Y'
      THEN
        OE_DEBUG_PUB.Add( ' No manual release, call Write_order_hold_msg ');
      END IF;

      G_result_out := 'FAIL' ;

      Write_Order_Hold_Msg
        (
           p_calling_action      => p_calling_action
         , p_cc_limit_used       => p_cc_limit_used
         , p_cc_profile_used     => p_cc_profile_used
         , p_order_number        => p_order_number
         , p_item_category       => l_item_category
         , x_comment             => l_hold_comment
        );
      l_hold_source_rec.hold_comment := l_hold_comment;

      IF NVL(p_calling_action, 'BOOKING') <> 'AUTO RELEASE' THEN
        OE_Holds_PUB.Apply_Holds
          (   p_api_version       => 1.0
          ,   p_validation_level  => FND_API.G_VALID_LEVEL_NONE
          ,   p_hold_source_rec   => l_hold_source_rec
          ,   x_msg_count         => l_msg_count
          ,   x_msg_data          => l_msg_data
          ,   x_return_status     => l_return_status
          );

        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
          IF G_debug_flag = 'Y' THEN
            OE_DEBUG_PUB.ADD
            ('OEXVCRLB: Credit check hold applied on header_ID: '||p_header_id, 1);
          END IF;
        END IF;
        l_cc_result_out := 'FAIL_HOLD';
      END IF; -- check calling action
    END IF; -- Check manual holds
  END IF; -- Check hold exist
  x_cc_result_out     := l_cc_result_out;

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.ADD('OEXVCRLB: Apply_Order_CC_Hold Result = '
             ||l_cc_result_out);
    OE_DEBUG_PUB.Add('OEXVCRLB: Out Apply_Order_CC_Hold');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
        OE_MSG_PUB.Add_Exc_Msg
        (G_PKG_NAME, 'Apply_Order_CC_Hold' );
     RAISE;

END Apply_Order_CC_Hold;

-----------------------------------------
-- Release order level credit check hold
-- in the database.
-----------------------------------------

PROCEDURE Release_Order_CC_Hold
 (  p_header_id             IN NUMBER
  , p_order_number          IN NUMBER
  , p_calling_action        IN VARCHAR2   DEFAULT 'BOOKING'
  , p_credit_hold_level     IN VARCHAR2
  , x_cc_result_out         OUT NOCOPY VARCHAR2
  )
IS

  --ER#7479609 l_hold_entity_id         NUMBER := p_header_id;
  l_hold_entity_id         oe_hold_sources_all.hold_entity_id%TYPE := p_header_id;  --ER#7479609
  l_hold_id                NUMBER;
  l_hold_exists            VARCHAR2(1);
  l_hold_result            VARCHAR2(30);
  l_msg_count              NUMBER := 0;
  l_msg_data               VARCHAR2(2000);
  l_return_status          VARCHAR2(30);
  l_release_reason         VARCHAR2(30);
  l_cc_result_out          VARCHAR2(30) := 'PASS_NONE';
  l_hold_source_rec    OE_HOLDS_PVT.Hold_Source_Rec_Type :=
                       OE_HOLDS_PVT.G_MISS_Hold_Source_REC;
  l_hold_release_rec   OE_HOLDS_PVT.Hold_Release_Rec_Type :=
                       OE_HOLDS_PVT.G_MISS_Hold_Release_REC;
  l_calling_activity   VARCHAR2(50);   --ER#7479609
BEGIN
  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.Add('OEXVCRLB: In Release_Order_CC_Hold');
  END IF;

  l_return_status := FND_API.G_RET_STS_SUCCESS;
  --
  -- Release credit hold if the calling action is not BOOKING and not
  -- UPDATE with background credit check set.
  --
  IF hold_exists( p_header_id => p_header_id
                , p_line_id   => NULL
                , p_credit_hold_level =>
                   p_credit_hold_level
                )
  THEN
    IF NVL(p_calling_action, 'BOOKING') <> 'AUTO HOLD' THEN
      l_hold_source_rec.hold_id := 1;  -- Credit Checking hold
      l_hold_source_rec.HOLD_ENTITY_CODE := 'O';
      l_hold_source_rec.HOLD_ENTITY_ID   := p_header_id;

      l_hold_release_rec.release_reason_code := 'PASS_CREDIT';
      l_hold_release_rec.release_comment := 'Credit Check Engine';
      l_hold_release_rec.created_by      := 1; -- indicate non-manual release

--ER#7479609 start
      IF OE_Verify_Payment_PUB.G_init_calling_action = 'AUTO RELEASE' THEN
         l_calling_activity := 'Credit Check Processor';
      ELSE
         l_calling_activity := InitCap(OE_Verify_Payment_PUB.G_init_calling_action);
      END IF;

      FND_MESSAGE.Set_Name('ONT','OE_CC_HOLD_ACT_COM');
      FND_MESSAGE.Set_Token('CALLING_ACTIVITY',l_calling_activity);
      FND_MESSAGE.Set_Token('CREDIT_CHECK_RULE',OE_Verify_Payment_PUB.G_credit_check_rule);

      l_hold_release_rec.release_comment := l_hold_release_rec.release_comment||SUBSTR(FND_MESSAGE.GET,1,2000);

 --ER#7479609 end


      OE_Holds_PUB.Release_Holds
                (   p_api_version       =>   1.0
                ,   p_hold_source_rec   =>   l_hold_source_rec
                ,   p_hold_release_rec  =>   l_hold_release_rec
                ,   x_msg_count         =>   l_msg_count
                ,   x_msg_data          =>   l_msg_data
                ,   x_return_status     =>   l_return_status
                );
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status =FND_API.G_RET_STS_SUCCESS THEN
        Write_Order_Release_Msg(
           p_calling_action    => p_calling_action
         , p_order_number      => p_order_number
        );
      END IF;
      l_cc_result_out := 'PASS_REL';

      IF G_debug_flag = 'Y'
      THEN
        OE_DEBUG_PUB.ADD('OEXVCRLB: Released credit check hold on Header ID:'
                     || p_header_id, 1);
      END IF;
    END IF;  -- check calling action
  END IF; -- hold exist
  x_cc_result_out := l_cc_result_out;

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.Add('OEXVCRLB: Out Release_Order_CC_Hold');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
        OE_MSG_PUB.Add_Exc_Msg
        (G_PKG_NAME, 'Release_Order_CC_Hold');
     RAISE;

END Release_Order_CC_Hold;

-----------------------------------------------------
-- Apply item catagory hold on lines within the given
-- bill-to site that have items belonging to the
-- specified item category.
-----------------------------------------------------

PROCEDURE Apply_Item_Category_Holds
  ( p_header_id           IN NUMBER
  , p_item_category_id    IN NUMBER
  , p_lines               IN OE_CREDIT_CHECK_UTIL.lines_Rec_tbl_type
  , p_holds_table         IN OUT NOCOPY Line_Holds_Tbl_Rectype
  )
IS
  i                    BINARY_INTEGER := 1;
  l_return_status      VARCHAR2(30);
BEGIN

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.Add('OEXVCRLB: In Apply_Item_Category_Holds');
  END IF;

  l_return_status := FND_API.G_RET_STS_SUCCESS;
  FOR i IN 1..p_lines.count LOOP
    IF p_item_category_id = p_lines(i).item_category_id THEN
      OE_DEBUG_PUB.Add('Line ID '||p_lines(i).line_id
            ||' fails ITEM limit ck',1);
      Update_Holds_Table
       (  p_holds_table         => p_holds_table
        , p_line_id             => p_lines(i).line_id
        , p_hold                => 'ITEM'
        , p_cc_limit_used       => 'ITEM'
        , p_cc_profile_used     => 'CATEGORY'
        , p_item_category_id    => p_item_category_id
        , x_return_status       => l_return_status
       );
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;
  END LOOP;

  OE_DEBUG_PUB.Add('OEXVCRLB: Out Apply_Item_Category_Holds');

EXCEPTION
  WHEN OTHERS THEN
        OE_MSG_PUB.Add_Exc_Msg
        (G_PKG_NAME, 'Apply_Item_Category_Holds');
     RAISE;

END Apply_Item_Category_Holds;

---------------------------------------------------
-- Update the plsql holds table to add hold info  |
-- for each line that do not already have ITEM    |
-- hold information.                              |
---------------------------------------------------

PROCEDURE Apply_Other_Holds
  ( p_header_id           IN NUMBER
  , p_customer_id         IN NUMBER
  , p_site_use_id         IN NUMBER
  , p_party_id            IN NUMBER
  , p_cc_limit_used       IN VARCHAR2
  , p_cc_profile_used     IN VARCHAR2
  , p_holds_table         IN OUT NOCOPY Line_Holds_Tbl_Rectype
  )
IS
  l_return_status      VARCHAR2(30);
BEGIN
  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.Add('OEXVCRLB: In Apply_Other_Holds');
  END IF;

  Update_Holds_Table
    (  p_holds_table         => p_holds_table
     , p_hold                => 'OTHER'
     , p_cc_limit_used       => p_cc_limit_used
     , p_cc_profile_used     => p_cc_profile_used
     , p_customer_id         => p_customer_id
     , p_site_use_id         => p_site_use_id
     , p_party_id            => p_party_id
     , x_return_status       => l_return_status
    );

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.Add('OEXVCRLB: Out Apply_Other_Holds');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
        OE_MSG_PUB.Add_Exc_Msg
        (G_PKG_NAME, 'Apply_Other_Holds');
     RAISE;

END Apply_Other_Holds;

---------------------------------------------------------
-- Release credit check holds on order lines belonging to
-- a bill-to site
---------------------------------------------------------

PROCEDURE Release_Line_CC_Hold
  ( p_header_id            IN NUMBER
  , p_order_number         IN NUMBER
  , p_line_id              IN NUMBER
  , p_line_number          IN NUMBER
  , p_calling_action       IN VARCHAR2   DEFAULT NULL
  , p_credit_hold_level    IN VARCHAR2
  , x_cc_result_out        OUT NOCOPY VARCHAR2
  )
IS
  --ER#7479609 l_hold_entity_id         NUMBER := p_header_id;
  l_hold_entity_id         oe_hold_sources_all.hold_entity_id%TYPE := p_header_id;  --ER#7479609
  l_hold_id	           NUMBER;
  l_hold_exists            VARCHAR2(1);
  l_hold_result            VARCHAR2(30);
  l_msg_count              NUMBER := 0;
  l_msg_data               VARCHAR2(2000);
  l_return_status          VARCHAR2(30);
  l_release_reason         VARCHAR2(30);
  l_cc_result_out          VARCHAR2(30) := 'PASS_NONE';

  l_hold_source_rec    OE_HOLDS_PVT.Hold_Source_Rec_Type :=
                       OE_HOLDS_PVT.G_MISS_Hold_Source_REC;
  l_hold_release_rec   OE_HOLDS_PVT.Hold_Release_Rec_Type :=
                       OE_HOLDS_PVT.G_MISS_Hold_Release_REC;
  l_calling_activity   VARCHAR2(50);   --ER#7479609

BEGIN

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.ADD('OEXVCRLB: In Release_Line_CC_Hold');
    OE_DEBUG_PUB.ADD('Processing line ID = '||
                p_line_id );
  END IF;

  l_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Holds Issue 1979918
  --------------------------------------------------------------------
  -- During the credit checking is at Line level ( PASS scenario ),
  --  IF there exist a credit checking Hold already exists at Header
  --  that hold must be released to begin with.
  --  If not the Check_holds API will ALWAYS return YES while
  -- checking for existing holds at line level
  -- REsult out will be HDR_HOLD for the first time
  ---------------------------------------------------------------------

  IF hold_exists(  p_header_id => p_header_id
                 , p_line_id   => p_line_id
                 , p_credit_hold_level => p_credit_hold_level
                )
  THEN
    IF NVL(p_calling_action,'BOOKING') <> 'AUTO HOLD' THEN
      l_hold_source_rec.hold_id := 1;  -- Credit Checking hold
      l_hold_source_rec.HOLD_ENTITY_CODE := 'O';
      l_hold_source_rec.HOLD_ENTITY_ID   := p_header_id;
      l_hold_source_rec.line_id := p_line_id;

      l_hold_release_rec.release_reason_code := 'PASS_CREDIT';
      l_hold_release_rec.release_comment := 'Credit Check Engine' ;
      l_hold_release_rec.created_by := 1; -- hold release by system

--ER#7479609 start
      IF OE_Verify_Payment_PUB.G_init_calling_action = 'AUTO RELEASE' THEN
         l_calling_activity := 'Credit Check Processor';
      ELSE
         l_calling_activity := InitCap(OE_Verify_Payment_PUB.G_init_calling_action);
      END IF;

      FND_MESSAGE.Set_Name('ONT','OE_CC_HOLD_ACT_COM');
      FND_MESSAGE.Set_Token('CALLING_ACTIVITY',l_calling_activity);
      FND_MESSAGE.Set_Token('CREDIT_CHECK_RULE',OE_Verify_Payment_PUB.G_credit_check_rule);

     l_hold_release_rec.release_comment := l_hold_release_rec.release_comment||SUBSTR(FND_MESSAGE.GET,1,2000);
--ER#7479609 end

      OE_Holds_PUB.Release_Holds
                (   p_api_version       =>   1.0
                ,   p_hold_source_rec   =>   l_hold_source_rec
                ,   p_hold_release_rec  =>   l_hold_release_rec
                ,   x_msg_count         =>   l_msg_count
                ,   x_msg_data          =>   l_msg_data
                ,   x_return_status     =>   l_return_status
                );

      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        IF NVL(G_hdr_hold_released,'N') = 'N'
        THEN
          l_cc_result_out := 'HDR_HOLD' ;
        ELSE
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        IF NVL(G_hdr_hold_released,'N') = 'N'
        THEN
          l_cc_result_out := 'HDR_HOLD' ;
        ELSE
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      ELSIF l_return_status =FND_API.G_RET_STS_SUCCESS THEN
        Write_Release_Message(
            p_calling_action    => p_calling_action
          , p_order_number      => p_order_number
          , p_line_number       => p_line_number
          );
          l_cc_result_out := 'PASS_REL';
        G_release_status := 'RELEASED' ;
      END IF;
    END IF; -- check calling action
  ELSE
    IF G_debug_flag = 'Y'
    THEN
      OE_DEBUG_PUB.ADD(' No Hold exist to be Released ');
    END IF;
  END IF;  -- Holds Exist IF

  x_cc_result_out := l_cc_result_out;

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.ADD('x_cc_result_out = '|| x_cc_result_out );
    OE_DEBUG_PUB.ADD('OEXVCRLB: Out Release_Line_CC_Hold');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
        OE_MSG_PUB.Add_Exc_Msg
        (G_PKG_NAME, 'Release_Line_CC_Hold');
     RAISE;

END Release_Line_CC_Hold;

   ----------------------------------------------
   -- additional task - made the procedure      |
   -- Check_trx_Limit local to this package and |
   -- added p_credit_rule_id as an additional   |
   -- input parameter                           |
   ----------------------------------------------

PROCEDURE Check_Trx_Limit
  (   p_header_rec	       IN   OE_ORDER_PUB.header_rec_type
  ,   p_customer_id            IN   NUMBER
  ,   p_site_use_id            IN   NUMBER
  ,   p_credit_level           IN   VARCHAR2
  ,   p_credit_check_rule_rec IN
             OE_CREDIT_CHECK_UTIL.OE_credit_rules_rec_type
  ,   p_system_parameter_rec   IN
             OE_CREDIT_CHECK_UTIL.OE_systems_param_rec_type
  ,   p_limit_curr_code        IN   VARCHAR2
  ,   p_trx_credit_limit       IN   NUMBER
  ,   x_cc_result_out          OUT  NOCOPY VARCHAR2
  ,   x_return_status          OUT  NOCOPY VARCHAR2
  ,   x_conversion_status      OUT  NOCOPY OE_CREDIT_CHECK_UTIL.curr_tbl_type
  )
IS

  l_order_value	          NUMBER;
  l_customer_id           NUMBER;

BEGIN
  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.ADD('OEXVCRLB: In Check_Trx_Limit');
    OE_DEBUG_PUB.ADD('  ', 2);
    OE_DEBUG_PUB.ADD(' ---------------------------------------- ', 2);
    OE_DEBUG_PUB.ADD(' Header ID          = '|| p_header_rec.header_id, 2);
    OE_DEBUG_PUB.ADD(' p_customer_id      = '|| p_customer_id, 2);
    OE_DEBUG_PUB.ADD(' p_site_use_id      = '|| p_site_use_id, 2);
    OE_DEBUG_PUB.ADD(' p_credit_level     = '|| p_credit_level, 2);
    OE_DEBUG_PUB.ADD(' p_limit_curr_code  = '|| p_limit_curr_code, 2);
    OE_DEBUG_PUB.ADD(' p_trx_credit_limit = '|| p_trx_credit_limit,2);
  END IF;

  -- Initialize return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- Default to Pass
  x_cc_result_out := 'PASS';

  ----------------------------------------------
  -- additional task -  Read the value of      |
  -- include_tax_flag from credit check rule   |
  -- and calculate the value of l_order_values |
  -- accordingly. If the value of              |
  -- include_tax_flag is NULL that means it is |
  -- 'No'                                      |
  ----------------------------------------------

  ----------------------------------------------
  -- Do not include lines with payment term    |
  -- that have credit check flag = N. NULL     |
  -- means Y.                                  |
  ----------------------------------------------
  IF p_credit_level = 'CUSTOMER'
  THEN
   l_customer_id := p_customer_id ;
  ELSE
   l_customer_id := NULL;
  END IF;

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.ADD(' l_customer_id = '|| l_customer_id );
    OE_DEBUG_PUB.ADD(' Call GET_transaction_amount ' );
  END IF;

  OE_CREDIT_CHECK_UTIL.GET_transaction_amount
  ( p_header_id              => p_header_rec.header_id
  , p_transaction_curr_code  => p_header_rec.transactional_curr_code
  , p_credit_check_rule_rec  => p_credit_check_rule_rec
  , p_system_parameter_rec   => p_system_parameter_rec
  , p_customer_id            => l_customer_id
  , p_site_use_id            => p_site_use_id
  , p_limit_curr_code        => p_limit_curr_code
  , x_amount                 => l_order_value
  , x_conversion_status      => x_conversion_status
  , x_return_status          => x_return_status
 );

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.ADD(' Out of GET with status '
         || x_return_status );
    OE_DEBUG_PUB.ADD(' ERR curr tbl count = '
         || x_conversion_status.COUNT );
  END IF;

 IF x_return_status = FND_API.G_RET_STS_ERROR THEN
   RAISE FND_API.G_EXC_ERROR;
 ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 END IF;

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.ADD(' l_order_value = '|| l_order_value );
  END IF;


  IF l_order_value > NVL(p_trx_credit_limit, l_order_value) THEN
     x_cc_result_out := 'FAIL';
  END IF;

 IF x_conversion_status.COUNT > 0
 THEN
  x_cc_result_out := 'FAIL';

  fnd_message.set_name('ONT', 'OE_CC_CONVERSION_ERORR');
  FND_MESSAGE.Set_Token('FROM',p_header_rec.transactional_curr_code);
  FND_MESSAGE.Set_Token('TO',p_limit_curr_code );
  FND_MESSAGE.Set_Token('CONV',
               NVL(p_credit_check_rule_rec.user_conversion_type,'Corporate'));
   OE_Credit_Engine_GRP.G_currency_error_msg :=
      SUBSTR(FND_MESSAGE.GET,1,1000) ;

   G_result_out := 'FAIL' ;
   x_cc_result_out := 'FAIL' ;

  IF p_credit_check_rule_rec.credit_hold_level_code = 'ORDER'
  THEN
    fnd_message.set_name('ONT', 'OE_CC_CONVERSION_ERORR');
    FND_MESSAGE.Set_Token('FROM',p_header_rec.transactional_curr_code);
    FND_MESSAGE.Set_Token('TO',p_limit_curr_code );
    FND_MESSAGE.Set_Token('CONV',
               NVL(p_credit_check_rule_rec.user_conversion_type,'Corporate'));

    OE_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_ERROR;

  END IF;


 END IF;

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.ADD(' x_cc_result_out   = '|| x_cc_result_out   );
    OE_DEBUG_PUB.ADD(' x_return_status = '|| x_return_status);
    OE_DEBUG_PUB.ADD(' ---------------------------------------- ' );
    OE_DEBUG_PUB.ADD('  ' );
    OE_DEBUG_PUB.ADD('OEXVCRLB: Out Check_Trx_Limit');
  END IF;
EXCEPTION
   WHEN others THEN
	OE_DEBUG_PUB.Add('Check_Trx_Limit: Other exceptions');
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       OE_MSG_PUB.Add_Exc_Msg
       (   G_PKG_NAME
       ,   'Check_Trx_Limit'
       );
     END IF;
     OE_DEBUG_PUB.ADD( SUBSTR(SQLERRM,1,300) ,1 );
END Check_Trx_Limit;

 -----------------------------------------------------+
  -- A trx is subject to credit check if all the       |
  -- following four conditions are true:               |
  -- 1. related credit rule available for the trx type |
  -- 2. credit check enabled for the payment term      |
  -- 3. credit check enabled for site or cust          |
  -- 4. credit limits available for site or cust       |
  -- When true, the procedure returns limits/other info|
  ------------------------------------------------------

PROCEDURE Validate_other_credit_check
  ( p_header_rec           IN  OE_ORDER_PUB.header_rec_type
  , p_customer_id          IN  NUMBER
  , p_site_use_id          IN  NUMBER
  , p_calling_action       IN  VARCHAR2  := 'BOOKING'
  , p_party_id             IN  NUMBER
  , p_credit_check_rule_rec IN
              OE_Credit_Check_Util.OE_credit_rules_rec_type
  , x_check_order_flag     OUT NOCOPY VARCHAR2
  , x_credit_check_lvl_out OUT NOCOPY VARCHAR2
  , x_default_limit_flag   OUT NOCOPY VARCHAR2
  , x_limit_curr_code      OUT NOCOPY VARCHAR2
  , x_overall_credit_limit OUT NOCOPY NUMBER
  , x_trx_credit_limit     OUT NOCOPY NUMBER
  , x_usage_curr           OUT NOCOPY OE_CREDIT_CHECK_UTIL.curr_tbl_type
  , x_include_all_flag     OUT NOCOPY VARCHAR2
  , x_return_status        OUT NOCOPY VARCHAR2
  , x_global_exposure_flag OUT NOCOPY VARCHAR2
  , x_credit_limit_entity_id OUT NOCOPY NUMBER
  )
  IS

  l_site_use_id                NUMBER;
  l_customer_id                NUMBER;

BEGIN

  x_check_order_flag := 'Y';
  x_return_status    := FND_API.G_RET_STS_SUCCESS;
  x_global_exposure_flag := 'N' ;

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.ADD('OEXVCRLB: In Validate_other_credit_check');
    OE_DEBUG_PUB.ADD('  ' );
    OE_DEBUG_PUB.ADD(' ---------------------------------------- ' );
    OE_DEBUG_PUB.ADD(' Header ID        = '|| p_header_rec.header_id );
    OE_DEBUG_PUB.ADD(' p_customer_id    = '|| p_customer_id );
    OE_DEBUG_PUB.ADD(' p_site_use_id    = '|| p_site_use_id );
    OE_DEBUG_PUB.ADD(' p_party_id       = '|| p_party_id );
    OE_DEBUG_PUB.ADD(' p_calling_action = '|| p_calling_action);
  END IF;

  ------------------------------------------------
  -- Program Logic:                              |
  -- 1. get site-level limit for the trx         |
  -- 2. If (1) fails, get-customer-level limit   |
  -----------------------------------------------|
  -- level | data         | meaning              |
  -----------------------------------------------|
  -- site  | credit_check | stop. credit check   |
  --       | flag = 'N'   | not reqd for the trx |
  -----------------------------------------------|
  -- site  | trx limit &  | check customer       |
  --       | overall limit| limits (and default  |
  --       | are null     | limit for the org)   |
  -----------------------------------------------|
  -- cust/ | credit_check | stop. credit check   |
  -- org   | flag = 'N'   | not reqd for the trx |
  -----------------------------------------------|
  -- cust/ | trx limit &  | stop. credit check   |
  -- org   | overall limit| not reqd for the trx |
  --       | are null     |                      |
  -----------------------------------------------|
  -- Note:                                       |
  -- all rules of customer limits apply to the   |
  -- default limits of the operating unit        |
  -- [a 11.5.3 feature]                          |
  ------------------------------------------------

    OE_CREDIT_CHECK_UTIL.Get_Limit_Info
    (  p_header_id                    => p_header_rec.header_id
    ,  p_entity_type                  => 'SITE'
    ,  p_entity_id                    => p_site_use_id
    ,  p_cust_account_id              => p_customer_id
    ,  p_party_id                     => p_party_id
    ,  p_trx_curr_code                => p_header_rec.transactional_curr_code
    ,  p_suppress_unused_usages_flag  => 'N'
    ,  p_navigate_to_next_level       => 'Y'
    ,  p_precalc_exposure_used        =>
                  p_credit_check_rule_rec.QUICK_CR_CHECK_FLAG
    ,  x_limit_curr_code              => x_limit_curr_code
    ,  x_trx_limit                    => x_trx_credit_limit
    ,  x_overall_limit                => x_overall_credit_limit
    ,  x_include_all_flag             => x_include_all_flag
    ,  x_usage_curr_tbl               => x_usage_curr
    ,  x_default_limit_flag           => x_default_limit_flag
    ,  x_global_exposure_flag         => x_global_exposure_flag
    ,  x_credit_limit_entity_id       => x_credit_limit_entity_id
    ,  x_credit_check_level           => x_credit_check_lvl_out
    );


  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.ADD(' after Get_Limit_Info ');
  END IF;

  IF (x_trx_credit_limit IS NULL AND
     x_overall_credit_limit IS NULL )
  THEN
    x_global_exposure_flag    := 'N' ;
    x_check_order_flag        := 'N' ;
    x_credit_limit_entity_id  := NULL;
    x_credit_check_lvl_out    := NULL ;
  END IF;

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.ADD(' ');
    OE_DEBUG_PUB.Add('   ');
    OE_DEBUG_PUB.Add(' Result from credit profile check ');
    OE_DEBUG_PUB.Add(' -------------------------------------------');
    OE_DEBUG_PUB.Add('   ');
    OE_DEBUG_PUB.Add('x_credit_check_lvl_out = '|| x_credit_check_lvl_out);
    OE_DEBUG_PUB.Add('x_default_limit_flag   = '|| x_default_limit_flag);
    OE_DEBUG_PUB.Add('x_limit_curr_code      = '|| x_limit_curr_code);
    OE_DEBUG_PUB.Add('x_overall_credit_limit = '|| x_overall_credit_limit);
    OE_DEBUG_PUB.Add('x_trx_credit_limit     = '|| x_trx_credit_limit);
    OE_DEBUG_PUB.Add('x_include_all_flag     = '|| x_include_all_flag);
    OE_DEBUG_PUB.Add('x_global_exposure_flag = '|| x_global_exposure_flag );
    OE_DEBUG_PUB.Add('x_credit_limit_entity_id =' ||
               x_credit_limit_entity_id );
    OE_DEBUG_PUB.ADD(' ');
    OE_DEBUG_PUB.ADD('****** List of associated Usage currency rules **** ');
    OE_DEBUG_PUB.ADD(' ');
  END IF;

  FOR K IN 1..x_usage_curr.COUNT
  LOOP
    IF G_debug_flag = 'Y'
    THEN
      OE_DEBUG_PUB.Add(' Usage currency ' || k || ' => ' ||
          x_usage_curr(K).usage_curr_code );
    END IF;
  END LOOP ;

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.ADD(' ');
    OE_DEBUG_PUB.ADD('**************** End of List *********************** ');
    OE_DEBUG_PUB.Add('OEXVCRLB: Out Validate_other_credit_check');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      OE_MSG_PUB.Add_Exc_Msg
      (   G_PKG_NAME
      ,   'Validate_other_credit_check'
      );
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    OE_DEBUG_PUB.ADD( SUBSTR(SQLERRM,1,300) ,1 );
END Validate_other_credit_check;

-----------------------------------------------------------
-- PROCEDURE:   Check_Order_lines_exposure      PUBLIC
-- DESCRIPTION: Calculate the exposure and compare against
--              the overall credit limits to determine
--              credit check status (PASS or FAIL).
--              The calling_action can be the following:
--              BOOKING   - Called when booking an order
--              UPDATE    - Called when order is updated
--              SHIPPING  - Called from shipping
--              PACKING
--              PICKING
--              AUTO      - obsoleted. Was called by credit check processor
--              AUTO HOLD - Called by credit check processor for holds
--              AUTO RELEASE - Called by credit check processor for release
-----------------------------------------------------------
PROCEDURE Check_Order_lines_exposure
( p_customer_id	          IN  NUMBER
, p_site_use_id	          IN  NUMBER
, p_header_id	          IN  NUMBER
, p_credit_level          IN  VARCHAR2
, p_limit_curr_code	  IN  VARCHAR2
, p_overall_credit_limit  IN  NUMBER
, p_calling_action	  IN  VARCHAR2
, p_usage_curr	          IN
                 OE_CREDIT_CHECK_UTIL.curr_tbl_type
, p_include_all_flag	  IN  VARCHAR2 DEFAULT 'N'
, p_holds_rel_flag	  IN  VARCHAR2 DEFAULT 'N'
, p_default_limit_flag	  IN  VARCHAR2 DEFAULT 'N'
, p_credit_check_rule_rec IN
                 OE_Credit_Check_Util.OE_credit_rules_rec_type
, p_system_parameter_rec  IN
                 OE_Credit_Check_Util.OE_systems_param_rec_type
, p_global_exposure_flag  IN VARCHAR2 := 'N'
, p_party_id              IN NUMBER
, p_credit_limit_entity_id IN NUMBER
, x_total_exposure	  OUT NOCOPY NUMBER
, x_cc_result_out	  OUT NOCOPY VARCHAR2
, x_error_curr_tbl	  OUT NOCOPY
                 OE_CREDIT_CHECK_UTIL.curr_tbl_type
, x_return_status	  OUT NOCOPY VARCHAR2
)
IS
l_customer_id NUMBER;
l_site_id    NUMBER;
l_current_order_value NUMBER := 0 ;

l_order_amount      NUMBER ;
l_order_hold_amount NUMBER ;
l_ar_amount         NUMBER ;

BEGIN

IF G_debug_flag = 'Y'
THEN
  OE_DEBUG_PUB.Add('OEXVCRLB: IN  Check_Order_lines_exposure ');
  OE_DEBUG_PUB.Add(' ');
  OE_DEBUG_PUB.Add('-******---------------********---------------**********--');
  OE_DEBUG_PUB.Add('p_header_id             = '|| p_header_id );
  OE_DEBUG_PUB.Add('p_customer_id           = '|| p_customer_id );
  OE_DEBUG_PUB.Add('p_site_use_id           = '|| p_site_use_id );
  OE_DEBUG_PUB.Add('p_credit_level          = '|| p_credit_level );
  OE_DEBUG_PUB.Add('p_limit_curr_code       = '||
         p_limit_curr_code );
  OE_DEBUG_PUB.Add('p_include_all_flag      = '||
         p_include_all_flag );
  OE_DEBUG_PUB.Add('p_default_limit_flag    = '||
         p_default_limit_flag );
  OE_DEBUG_PUB.Add('p_overall_credit_limit = '||
         p_overall_credit_limit );
  OE_DEBUG_PUB.Add('p_global_exposure_flag = '||
         p_global_exposure_flag );
  OE_DEBUG_PUB.Add('p_credit_limit_entity_id => '||
      p_credit_limit_entity_id);
  OE_DEBUG_PUB.Add('-******---------------********---------------**********--');
  OE_DEBUG_PUB.Add(' ');
END IF;

  l_current_order_value := 0 ;

  IF p_credit_level = 'PARTY'
  THEN
    l_customer_id := NULL ;
    l_site_id     := NULL;

  ELSIF p_credit_level = 'CUSTOMER'
  THEN
    l_customer_id := p_customer_id ;
    l_site_id     := NULL;
  ELSE
    l_customer_id := p_customer_id ;
    l_site_id     := p_site_use_id ;

  END IF;

  IF p_overall_credit_limit IS NOT NULL -- bug 4351533
  THEN

  ----------------------------------------------------------
  -- Set the default behaviour to pass credit check        |
  -- exposure                                              |
  ----------------------------------------------------------

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_total_exposure := 0 ;
  l_current_order_value := 0 ;

  OE_DEBUG_PUB.ADD( ' Call Get_Exposure ');

  OE_CREDIT_EXPOSURE_PVT.Get_Exposure
  ( p_customer_id             => l_customer_id
  , p_site_use_id             => l_site_id
  , p_header_id               => p_header_id
  , p_party_id                => p_credit_limit_entity_id
  , p_credit_check_rule_rec   => p_credit_check_rule_rec
  , p_system_parameters_rec   => p_system_parameter_rec
  , p_limit_curr_code         => p_limit_curr_code
  , p_usage_curr_tbl          => p_usage_curr
  , p_include_all_flag        => p_include_all_flag
  , p_global_exposure_flag    => p_global_exposure_flag
  , p_need_exposure_details   => 'N'
  , x_total_exposure          => x_total_exposure
  , x_order_amount            => l_order_amount
  , x_order_hold_amount       => l_order_hold_amount
  , x_ar_amount               => l_ar_amount
  , x_return_status           => x_return_status
  , x_error_curr_tbl          => x_error_curr_tbl
  );

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.Add('Out of Get_Exposure- Precalculated exposure ');
    OE_DEBUG_PUB.Add('x_return_status = '|| x_return_status );
    OE_DEBUG_PUB.Add('x_total_exposure = '|| x_total_exposure );
    OE_DEBUG_PUB.Add('Error table count = '|| x_error_curr_tbl.COUNT );
  END IF;

  IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;


   -- BUG Fix 2338145
   -- Get the current order amount to be included into the
   -- pre-calc exposure during booking action

   -- Bug fix 2787722
   -- The current bill-tosite amount should also be included
   -- for  Non-Booking actions if the
   -- credit check rule does notInclude
   -- OM Uninvoiced Orders exposure


   l_current_order_value := 0 ;

   IF NVL(p_calling_action, 'BOOKING') = 'BOOKING'
      and  NVL(OE_credit_engine_GRP.G_delayed_request, FND_API.G_FALSE ) =
            FND_API.G_FALSE
   THEN
      l_current_order_value :=
             NVL(OE_CREDIT_CHECK_UTIL.g_current_order_value,0) ;
   ELSE
      IF NVL(p_credit_check_rule_rec.uninvoiced_orders_flag,'N') = 'N'
      THEN
        l_current_order_value :=
                  NVL(OE_CREDIT_CHECK_UTIL.g_current_order_value,0) ;
      ELSE
        l_current_order_value := 0 ;
      END IF;
   END IF;

    IF G_debug_flag = 'Y'
    THEN
       OE_DEBUG_PUB.Add('l_current_order_value => '
                || l_current_order_value );
    END IF;



   x_total_exposure := NVL(l_current_order_value,0) + NVL(x_total_exposure,0);

  ---------------------------------------------------
  -- compare limit and exposure                     |
  ---------------------------------------------------

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.Add('x_total_exposure = '|| x_total_exposure );
    OE_DEBUG_PUB.Add('p_overall_credit_limit = '|| p_overall_credit_limit );
  END IF;

  IF NVL(x_total_exposure,0) > p_overall_credit_limit
  THEN
   x_cc_result_out := 'FAIL';
  ELSE
   x_cc_result_out := 'PASS';
  END IF;

  IF NVL(x_error_curr_tbl.COUNT,0) > 0
  THEN
   x_cc_result_out := 'FAIL' ;

   OE_DEBUG_PUB.Add(' Currency conversion failed ');

   fnd_message.set_name('ONT', 'OE_CC_CONVERSION_ERORR');
  FND_MESSAGE.Set_Token('FROM',x_error_curr_tbl(1).usage_curr_code);
  FND_MESSAGE.Set_Token('TO',p_limit_curr_code );
  FND_MESSAGE.Set_Token('CONV',
               NVL(p_credit_check_rule_rec.user_conversion_type,'Corporate'));
   OE_Credit_Engine_GRP.G_currency_error_msg :=
      SUBSTR(FND_MESSAGE.GET,1,1000) ;

   G_result_out := 'FAIL' ;
   x_cc_result_out := 'FAIL' ;


 IF p_credit_check_rule_rec.credit_hold_level_code = 'ORDER'
 THEN
   fnd_message.set_name('ONT', 'OE_CC_CONVERSION_ERORR');
  FND_MESSAGE.Set_Token('FROM',x_error_curr_tbl(1).usage_curr_code);
  FND_MESSAGE.Set_Token('TO',p_limit_curr_code );
  FND_MESSAGE.Set_Token('CONV',
               NVL(p_credit_check_rule_rec.user_conversion_type,'Corporate'));


   OE_MSG_PUB.ADD;
  x_return_status := FND_API.G_RET_STS_ERROR;
  OE_DEBUG_PUB.ADD('Return status after assigned as Error = '
          || x_return_status );
 END IF;


 END IF;


 ELSE
   x_cc_result_out := 'PASS';

    IF G_debug_flag = 'Y'
    THEN
      OE_DEBUG_PUB.Add(' No need to check exposure, UNLIMITED ');
    END IF;
 END IF;

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.Add(' x_cc_result_out = ' || x_cc_result_out );
    OE_DEBUG_PUB.Add(' x_return_status = '|| x_return_status);
    OE_DEBUG_PUB.Add('OEXVCRLB: Out CHECK_ORDER_LINES_EXPOSURE');
  END IF;
EXCEPTION
  WHEN others THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    OE_DEBUG_PUB.Add('CHECK_ORDER_LINES_EXPOSURE: Other exceptions');
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      OE_MSG_PUB.Add_Exc_Msg
      (   G_PKG_NAME
      ,   'CHECK_ORDER_LINES_EXPOSURE'
      );
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    OE_DEBUG_PUB.ADD( SUBSTR(SQLERRM,1,300) ,1 );
END CHECK_ORDER_LINES_EXPOSURE;

-----------------------------------------------------------
-- Check item category limits within the given site
-- If credit check failed on any category, return failure
-- and the category being checked.
-----------------------------------------------------------
PROCEDURE Check_Item_Limits
  ( p_header_rec            IN  OE_ORDER_PUB.header_rec_type
  , p_customer_id           IN  NUMBER
  , p_site_use_id           IN  NUMBER
  , p_calling_action        IN  VARCHAR2 DEFAULT 'BOOKING'
  , p_credit_check_rule_rec IN
                   OE_CREDIT_CHECK_UTIL.OE_credit_rules_rec_type
  , p_system_parameter_rec  IN
                   OE_CREDIT_CHECK_UTIL.OE_systems_param_rec_type
  , p_holds_table           IN OUT NOCOPY Line_Holds_Tbl_Rectype
  , x_cc_result_out         OUT NOCOPY VARCHAR2
  , x_return_status         OUT NOCOPY VARCHAR2
  )
IS
  l_category_sum              NUMBER := 0 ;
  l_limit_category_sum        NUMBER := 0 ; -- Sum converted to Limit currency

  l_return_status             VARCHAR2(30);
  l_credit_hold_level         VARCHAR2(30);
  l_include_tax_flag          VARCHAR2(1) := 'Y';
  l_item_limits               OE_CREDIT_CHECK_UTIL.item_limits_tbl_type;
  l_lines                     OE_CREDIT_CHECK_UTIL.lines_Rec_tbl_type;
  j                           BINARY_INTEGER := 1;
  i                           BINARY_INTEGER := 1;
  l_cc_result_out             VARCHAR2(30);
  l_check_category_id         NUMBER;
  l_limit_currency            VARCHAR2(30);

BEGIN
  OE_DEBUG_PUB.Add('OEXVCRLB: In Check_Item_Limits');
  --
  -- Initialize return status to success
  x_return_status     := FND_API.G_RET_STS_SUCCESS;
  -- Default to Pass
  l_cc_result_out     := 'PASS';
  l_credit_hold_level := p_credit_check_rule_rec.CREDIT_HOLD_LEVEL_CODE ;
  -- Need to use new get_item_limits api
  --

  l_include_tax_flag  := p_credit_check_rule_rec.include_tax_flag ;

  OE_DEBUG_PUB.Add(' Call Get_Item_Limit ');

  OE_CREDIT_CHECK_UTIL.Get_Item_Limit
    (  p_header_id        => p_header_rec.header_id
     , p_include_tax_flag => p_credit_check_rule_rec.include_tax_flag
     , p_site_use_id      => p_site_use_id
     , p_trx_curr_code    => p_header_rec.transactional_curr_code
     , x_item_limits_tbl  => l_item_limits
     , x_lines_tbl        => l_lines
    );


  OE_DEBUG_PUB.Add(' After Get_Item_Limit with item tbl count '
        || l_item_limits.COUNT );

  IF l_item_limits.count = 0
  THEN
    x_cc_result_out := 'NOCHECK';
    OE_DEBUG_PUB.Add(' No need to check as count 0 ');

  ELSE
    OE_DEBUG_PUB.Add(' start category loop ');
    OE_DEBUG_PUB.Add(' ======================== ');

    FOR i in 1..l_item_limits.count
    LOOP
     l_category_sum := 0;
      -- For each item category, sum the line values
     ----------------------------------------------
     OE_DEBUG_PUB.ADD('  ');
     OE_DEBUG_PUB.Add(' ------------------------------------ ');
     OE_DEBUG_PUB.Add(' Category id     = '
                      || l_item_limits(i).item_category_id );
     OE_DEBUG_PUB.Add(' ctg_line_amount = '
                      || l_item_limits(i).ctg_line_amount );

     OE_DEBUG_PUB.Add(' limit_curr_code = '
                      || l_item_limits(i).limit_curr_code  );
     OE_DEBUG_PUB.Add(' item_limit      = '
                      || l_item_limits(i).item_limit );
     OE_DEBUG_PUB.Add(' grouping       = '
                      || l_item_limits(i).grouping_id  );

     l_category_sum := l_item_limits(i).ctg_line_amount ;

     OE_DEBUG_PUB.Add(' l_category_sum = ' || l_category_sum );
     OE_DEBUG_PUB.Add(' GL_CURRENCY = '||
           OE_Credit_Engine_GRP.GL_currency );


     OE_DEBUG_PUB.ADD('  ');
     OE_DEBUG_PUB.Add(' ------------------------------------ ');


    l_check_category_id :=  l_item_limits(i).item_category_id ;
    l_limit_currency    := l_item_limits(i).limit_curr_code ;

    l_limit_category_sum  :=
    OE_CREDIT_CHECK_UTIL.CONVERT_CURRENCY_AMOUNT
    ( p_amount	              => l_category_sum
    , p_transactional_currency  => p_header_rec.transactional_curr_code
    , p_limit_currency	        => l_item_limits(i).limit_curr_code
    , p_functional_currency	  => OE_Credit_Engine_GRP.GL_currency
    , p_conversion_date	        => SYSDATE
    , p_conversion_type         => p_credit_check_rule_rec.conversion_type
    ) ;

    OE_DEBUG_PUB.Add
    (' l_limit_category_sum = '|| l_limit_category_sum );

    OE_DEBUG_PUB.Add
    (' Credit limit = '|| l_item_limits(i).item_limit );

    IF l_limit_category_sum > l_item_limits(i).item_limit
    THEN
       OE_DEBUG_PUB.Add
         ('Fails item category ID: '|| l_item_limits(i).item_category_id);

	IF l_credit_hold_level = 'ORDER' THEN

       OE_DEBUG_PUB.Add
         (' Call Apply_Order_CC_Hold ');

          Apply_Order_CC_Hold
           (  p_header_id           => p_header_rec.header_id
           ,  p_order_number        => p_header_rec.order_number
            , p_calling_action      => p_calling_action
            , p_cc_limit_used       => 'ITEM'
            , p_cc_profile_used     => 'CATEGORY'
            , p_item_category_id    => l_item_limits(i).item_category_id
            , p_credit_hold_level   =>
                   p_credit_check_rule_rec.credit_hold_level_code
            , p_credit_check_rule_rec=>p_credit_check_rule_rec
            , x_cc_result_out       => l_cc_result_out
           );
          EXIT;  -- stop checking item limits
        ELSE

       OE_DEBUG_PUB.Add
         (' Apply_Item_Category_Holds ');

          Apply_Item_Category_Holds
            ( p_header_id         => p_header_rec.header_id
             ,p_item_category_id  => l_item_limits(i).item_category_id
             ,p_lines             => l_lines
             ,p_holds_table       => p_holds_table
            );
        END IF;
        -- If any category failed credit check then the result of
        -- check item limits is FAIL.
        l_cc_result_out := 'FAIL';
        --Don't exit until all item categories are checked.
      END IF;

      l_limit_category_sum := 0 ;
      l_category_sum       := 0;
      l_limit_currency     := NULL;

    END LOOP; -- category loop

    OE_DEBUG_PUB.ADD(' out of category loop ');

    x_cc_result_out := l_cc_result_out;
  END IF;

  OE_DEBUG_PUB.ADD(' x_cc_result_out = ' || x_cc_result_out );

  OE_DEBUG_PUB.ADD('OEXVCRLB: Out Check_Item_Limit');

EXCEPTION
   WHEN  GL_CURRENCY_API.NO_RATE
   THEN
   BEGIN
     OE_DEBUG_PUB.Add('EXCEPTION: GL_CURRENCY_API.NO_RATE ');
     OE_DEBUG_PUB.Add('Apply_Order_CC_Hold for Item category');
     OE_DEBUG_PUB.Add('currency = '|| p_header_rec.transactional_curr_code );
     OE_DEBUG_PUB.Add('checking category = '|| l_check_category_id );

     fnd_message.set_name('ONT', 'OE_CC_CONVERSION_ERORR');
     FND_MESSAGE.Set_Token('FROM',p_header_rec.transactional_curr_code );
     FND_MESSAGE.Set_Token('TO',l_limit_currency );
     FND_MESSAGE.Set_Token('CONV',
               NVL(p_credit_check_rule_rec.user_conversion_type,'Corporate'));
     OE_Credit_Engine_GRP.G_currency_error_msg :=
      SUBSTR(FND_MESSAGE.GET,1,1000) ;
     G_result_out := 'FAIL' ;
     x_cc_result_out := 'FAIL' ;


     IF p_credit_check_rule_rec.credit_hold_level_code = 'ORDER'
     THEN
       fnd_message.set_name('ONT', 'OE_CC_CONVERSION_ERORR');
       FND_MESSAGE.Set_Token('FROM',p_header_rec.transactional_curr_code );
       FND_MESSAGE.Set_Token('TO',l_limit_currency );
       FND_MESSAGE.Set_Token('CONV',
               NVL(p_credit_check_rule_rec.user_conversion_type,'Corporate'));

       OE_MSG_PUB.ADD ;
       x_return_status := FND_API.G_RET_STS_ERROR;
       OE_DEBUG_PUB.ADD('Return status after assigned as Error = '
          || x_return_status );
      END IF;

      OE_DEBUG_PUB.ADD(' Item CTG  cc fails due to conversion error ');
   END;

   WHEN others THEN
     OE_DEBUG_PUB.Add('Check_Item_Limit: Other exceptions');
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       OE_MSG_PUB.Add_Exc_Msg
       (   G_PKG_NAME
       ,   'Check_Item_Limits'
       );
     END IF;
     OE_DEBUG_PUB.ADD( SUBSTR(SQLERRM,1,300) ,1 );
END Check_Item_Limits;

------------------------------------------------------------
-- PROCEDURE:   Check_Other_Credit_Limits            PRIVATE
-- DESCRIPTION: Get additional credit limit information and
--              perform credit check on customer/site/default
--              credit limits specified in the customer/site
--              or default credit profiles.
------------------------------------------------------------
PROCEDURE Check_Other_Credit_Limits
  ( p_header_rec            IN  OE_ORDER_PUB.header_rec_type
  , p_customer_id           IN  NUMBER
  , p_site_use_id           IN  NUMBER
  , p_calling_action        IN  VARCHAR2 := 'BOOKING'
  , p_credit_check_rule_rec IN
                    OE_Credit_Check_Util.OE_credit_rules_rec_type
  , p_system_parameter_rec  IN
                    OE_Credit_Check_Util.OE_systems_param_rec_type
  , p_holds_table           IN OUT NOCOPY Line_Holds_Tbl_Rectype
  , p_party_id              IN NUMBER
  , x_credit_level         OUT NOCOPY VARCHAR2
  , x_check_exposure_mode  OUT NOCOPY VARCHAR2
  , x_cc_result_out        OUT NOCOPY VARCHAR2
  , x_return_status        OUT NOCOPY VARCHAR2
  , x_global_exposure_flag OUT NOCOPY VARCHAR2
  )
IS

  l_check_order 	          VARCHAR2(1);
  l_default_limit_flag      VARCHAR2(1);
  l_limit_curr_code 	    VARCHAR2(30);
  l_overall_credit_limit    NUMBER;
  l_trx_credit_limit        NUMBER;
  l_usage_curr	          OE_CREDIT_CHECK_UTIL.curr_tbl_type;
  l_include_all_flag	    VARCHAR2(1);
  l_prev_customer_id        NUMBER;
  l_customer_result_out     VARCHAR2(30) := NULL;
  l_total_exposure          NUMBER;
  l_orders                  NUMBER;
  l_orders_on_hold          NUMBER;
  l_payments_overdue        NUMBER;
  l_payments_at_risk        NUMBER;
  l_error_curr_tbl	    OE_CREDIT_CHECK_UTIL. curr_tbl_type ;
  l_cc_profile_used         VARCHAR2(30);
  l_cc_limit_used           VARCHAR2(80);
  l_cc_result_out           VARCHAR2(30);
  l_credit_hold_level       VARCHAR2(30);
  l_credit_limit_entity_id  NUMBER;

  --bug 4293874 start
  l_request_id              NUMBER;
  l_msg_count               NUMBER;
  l_msg_data	            VARCHAR2(2000);
  l_customer_id             NUMBER;
  l_site_use_id             NUMBER;
  l_source_org_id           NUMBER;
  l_source_user_id          NUMBER;
  l_source_resp_id          NUMBER;
  l_source_appln_id         NUMBER;
  l_source_security_group_id  NUMBER;
  --bug 4293874 ends

  l_cc_trx_result_out       VARCHAR2(30);
  l_cc_duedate_result_out   VARCHAR2(30);
  l_cc_overall_result_out   VARCHAR2(30);
  ----Bug 4320650
  l_unrounded_exposure          NUMBER;
  -- bug 5907331
  l_review_party_id             NUMBER;
  l_hold_line_seq VARCHAR2(1) := NVL(OE_SYS_PARAMETERS.VALUE('OE_HOLD_LINE_SEQUENCE'),1); -- ER 6135714

  i_hld_rec NUMBER := 0;  --ER8880886

BEGIN
  --
  -- Set the default behavior to pass credit check
  --
  x_cc_result_out := 'PASS';
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_credit_hold_level := p_credit_check_rule_rec.CREDIT_HOLD_LEVEL_CODE ;
  x_global_exposure_flag := 'N' ;

  l_cc_result_out := 'PASS';
  l_cc_trx_result_out := 'PASS';
  l_cc_duedate_result_out := 'PASS';
  l_cc_overall_result_out := 'PASS';

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.Add('OEXVCRLB: In Check_Other_Credit Limits');
    OE_DEBUG_PUB.ADD('  ' );
    OE_DEBUG_PUB.ADD(' ---------------------------------------- ' );
    OE_DEBUG_PUB.ADD(' Header ID        = '|| p_header_rec.header_id );
    OE_DEBUG_PUB.ADD(' p_customer_id    = '|| p_customer_id );
    OE_DEBUG_PUB.ADD(' p_site_use_id    = '|| p_site_use_id );
    OE_DEBUG_PUB.Add(' p_calling_action = '|| p_calling_action );
    OE_DEBUG_PUB.Add('Calling Validate_other_credit_check');
  END IF;
  --
  -----------------------------------------------------------
  -- Check if order site use needs credit check. Also       |
  -- determine if credit check should be at customer level  |
  -- or the site level and the credit limits at that level. |
  -- The information returned will be used for credit check.|
  -----------------------------------------------------------
  --
  OE_credit_check_lines_PVT.Validate_other_credit_check
          (   p_header_rec            => p_header_rec
          ,   p_customer_id           => p_customer_id
          ,   p_site_use_id           => p_site_use_id
          ,   p_calling_action        => p_calling_action
          ,   p_credit_check_rule_rec => p_credit_check_rule_rec
          ,   p_party_id              => p_party_id
          ,   x_check_order_flag      => l_check_order
          ,   x_credit_check_lvl_out  => x_credit_level
          ,   x_default_limit_flag    => l_default_limit_flag
          ,   x_limit_curr_code       => l_limit_curr_code
          ,   x_overall_credit_limit  => l_overall_credit_limit
          ,   x_trx_credit_limit      => l_trx_credit_limit
          ,   x_usage_curr            => l_usage_curr
          ,   x_include_all_flag      => l_include_all_flag
          ,   x_return_status         => x_return_status
          ,   x_global_exposure_flag  => x_global_exposure_flag
           , x_credit_limit_entity_id => l_credit_limit_entity_id
          );

          IF G_debug_flag = 'Y'
          THEN
            OE_DEBUG_PUB.Add(' After Validate_other_credit_check status '
                   || x_return_status );
             OE_DEBUG_PUB.Add(' x_global_exposure_flag => '||
                   x_global_exposure_flag );
             OE_DEBUG_PUB.Add(' l_credit_limit_entity_id ==> '||
                l_credit_limit_entity_id );
             OE_DEBUG_PUB.Add(' l_check_order = '|| l_check_order );
          END IF;

  IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
  ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;


  --
  -----------------------------------------------------------
  -- Perform credit checks for due date, transaction limits,
  -- and overall limits.
  -----------------------------------------------------------
  IF l_check_order = 'Y' THEN
    --
    -- Determine the profile used
    --
    IF l_default_limit_flag = 'Y' THEN
      l_cc_profile_used := 'DEFAULT';
    ELSE
      l_cc_profile_used := x_credit_level ;
    END IF;
    --
    ----------------------------------------------------+
    -- order site use is subject to credit check:       |
    ----------------------------------------------------|
    -- check 1: item limit             <-- passed/failed|
    -- check 2: max-past-due-inv limit <-- in progress  |
    -- check 3: trx limit                               |
    -- check 4: overall limit                           |
    ----------------------------------------------------+
    --


    OE_credit_check_lines_PVT.Chk_Past_Due_Invoice
      (  p_customer_id           => p_customer_id
      ,  p_site_use_id           => p_site_use_id
      ,  p_party_id              => l_credit_limit_entity_id
      ,  p_credit_check_rule_rec => p_credit_check_rule_rec
      ,  p_system_parameter_rec  => p_system_parameter_rec
      ,  p_credit_level          => x_credit_level
      ,  p_usage_curr            => l_usage_curr
      ,  p_include_all_flag      => l_include_all_flag
      ,  p_global_exposure_flag  => x_global_exposure_flag
      ,  x_cc_result_out         => l_cc_duedate_result_out
      ,  x_return_status         => x_return_status
      );

    IF G_debug_flag = 'Y'
      THEN
      OE_DEBUG_PUB.Add('Chk_Past_Due_Invoice: Result Out    ='
            ||l_cc_duedate_result_out);
      OE_DEBUG_PUB.Add('Chk_Past_Due_Invoice: Return Status ='
                   || x_return_status );

    END IF;

    -- bug 4002820
    IF l_cc_duedate_result_out = 'FAIL' THEN
        -- only overwrite the l_cc_result_out if the current checking fails
        -- to make sure the l_cc_result_out is FAIL if any of the checkings fails.
        l_cc_result_out := l_cc_duedate_result_out;
        l_cc_limit_used := 'DUEDATE';

        --ER8880886
        i_hld_rec := i_hld_rec +1;
        g_hold_reason_rec(i_hld_rec) := 'OE_CC_HOLD_OVERDUE';
        --ER8880886
    END IF;


    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- IF l_cc_result_out = 'PASS' THEN
    -- Changed IF condition to fix bug 4002820, need to do overall
    -- limit checking even order limit checking failed when
    -- Credit Management is installed and used.

    IF OE_CREDIT_CHECK_UTIL.G_crmgmt_installed is NULL
       THEN
       OE_CREDIT_CHECK_UTIL.G_crmgmt_installed :=
       AR_CMGT_CREDIT_REQUEST_API.is_Credit_Management_Installed ;
    END IF;

    IF l_cc_duedate_result_out = 'PASS'
         OR OE_CREDIT_CHECK_UTIL.G_crmgmt_installed = TRUE THEN
      ----------------------------------------------------+
      -- order site use is subject to credit check:       |
      ----------------------------------------------------|
      -- check 1: item limit             <-- passed/failed|
      -- check 2: max-past-due-inv limit <-- passed       |
      -- check 3: trx limit              <-- in progress  |
      -- check 4: overall limit                           |
      ----------------------------------------------------+
      --

      OE_credit_check_lines_PVT.Check_Trx_Limit
        (   p_header_rec            => p_header_rec
        ,   p_customer_id           => p_customer_id
        ,   p_site_use_id           => p_site_use_id
        ,   p_credit_level          => x_credit_level
        ,   p_credit_check_rule_rec => p_credit_check_rule_rec
        ,   p_system_parameter_rec  => p_system_parameter_rec
        ,   p_limit_curr_code       => l_limit_curr_code
        ,   p_trx_credit_limit      => l_trx_credit_limit
        ,   x_cc_result_out         => l_cc_trx_result_out
        ,   x_return_status         => x_return_status
        ,   x_conversion_status     => l_error_curr_tbl
        );

       IF G_debug_flag = 'Y'
       THEN
         OE_DEBUG_PUB.Add('Check_Trx_Limit: Result Out    ='
               ||l_cc_trx_result_out);
         OE_DEBUG_PUB.Add('Check_Trx_Limit: Return Status ='
                   || x_return_status );
         OE_DEBUG_PUB.Add('err curr tbl count = '|| l_error_curr_tbl.COUNT );

       END IF;

      IF l_cc_trx_result_out = 'FAIL' THEN
         l_cc_result_out := l_cc_trx_result_out;
         IF l_cc_limit_used IS NOT NULL THEN
            -- in order to disply useful message if two or more checkings fail.
            -- l_cc_limit_used := 'Overdue invoices found' || ', order limit exceeded';
            -- bug 4153299
            /*l_cc_limit_used
                := OE_CREDIT_CHECK_UTIL.Get_CC_Lookup_Meaning('OE_CC_LIMIT', 'OVERDUE')
                || OE_CREDIT_CHECK_UTIL.Get_CC_Lookup_Meaning('OE_CC_LIMIT', 'ORDER');*/ --commented ER8880886

                l_cc_limit_used := OE_CREDIT_CHECK_UTIL.Get_CC_Lookup_Meaning('OE_CC_LIMIT', 'OVERDUE') || ', '
                             || OE_CREDIT_CHECK_UTIL.Get_CC_Lookup_Meaning('OE_CC_LIMIT', 'ORDER');    --added ER8880886

                  --ER8880886
	          i_hld_rec := i_hld_rec +1;
	          g_hold_reason_rec.extend;
	          g_hold_reason_rec(i_hld_rec) := 'OE_CC_HOLD_ORDER';
        	  --ER8880886
         ELSE
           l_cc_limit_used := 'TRX';

	   --ER8880886
	   i_hld_rec := i_hld_rec +1;
	   g_hold_reason_rec(i_hld_rec) := 'OE_CC_HOLD_ORDER';
	   --ER8880886

         END IF;
      END IF;

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- IF l_cc_result_out = 'PASS' THEN
      -- Changed IF condition to fix bug 4002820, need to do overall
      -- limit checking even order limit checking failed when
      -- Credit Management is installed and used.
      IF l_cc_trx_result_out = 'PASS'
         OR OE_CREDIT_CHECK_UTIL.G_crmgmt_installed = TRUE THEN
        ----------------------------------------------------+
        -- order is subject to credit check:                |
        ----------------------------------------------------|
        -- check 1: item limit             <-- passed/failed|
        -- check 2: max-past-due-inv limit <-- passed       |
        -- check 3: trx limit              <-- passed       |
        -- check 4: overall limit          <-- in progress  |
        ----------------------------------------------------+
        --
        --
        x_check_exposure_mode := 'INLINE';

        IF G_debug_flag = 'Y'
        THEN
            OE_DEBUG_PUB.Add(' x_check_exposure_mode = '
             || x_check_exposure_mode );
        END IF;
        -------------------------------------------------
        -- l_prev_customer_id is used to keep track of the
        --   customer level exposure calc
        -- If a bill to site has no credit profile defined,
        -- the customer profile is used.
        -- This l_prev_customer_id variable will enable to prevent
        -- multiple credit exposure calculation for customer level
        --  if more than one bill to
        -- site has no credit profile and needs to use the customer
        -- level
       ---------------------------------------------------
       IF G_debug_flag = 'Y'
       THEN
         OE_DEBUG_PUB.Add(' l_prev_customer_id = '|| l_prev_customer_id );
       END IF;

        IF (  ( x_credit_level NOT IN ( 'CUSTOMER','PARTY') )
            OR
            NVL(l_prev_customer_id,p_customer_id * -1) <> p_customer_id
           )
        THEN

            OE_credit_check_lines_PVT.Check_Order_lines_exposure
            ( p_customer_id	        => p_customer_id
            , p_site_use_id	        => p_site_use_id
            , p_header_id	        => p_header_rec.header_id
            , p_party_id                => p_party_id
            , p_credit_level	        => x_credit_level
            , p_limit_curr_code	        => l_limit_curr_code
            , p_overall_credit_limit    => l_overall_credit_limit
            , p_calling_action	        => p_calling_action
            , p_usage_curr	        => l_usage_curr
            , p_include_all_flag        => l_include_all_flag
            , p_holds_rel_flag	        => 'N'
            , p_default_limit_flag      => l_default_limit_flag
            , p_credit_check_rule_rec   => p_credit_check_rule_rec
            , p_system_parameter_rec    => p_system_parameter_rec
            , p_global_exposure_flag    => x_global_exposure_flag
            , p_credit_limit_entity_id  => l_credit_limit_entity_id
            , x_total_exposure	        => l_total_exposure
            , x_cc_result_out	        => l_cc_overall_result_out
            , x_error_curr_tbl	        => l_error_curr_tbl
            , x_return_status	        => x_return_status
            );


            IF G_debug_flag = 'Y'
            THEN
              OE_DEBUG_PUB.Add('After call to Check_order_lines_Exposure ');
              OE_DEBUG_PUB.Add('l_cc_result_out = ' || l_cc_overall_result_out );
              OE_DEBUG_PUB.Add('total exposure =  ' || l_total_exposure );
              OE_DEBUG_PUB.Add('x_return_status  =  ' || x_return_status  );
              OE_DEBUG_PUB.Add('Err curr table count = '||
                l_error_curr_tbl.COUNT );
            END IF;
            --Bug 4320650
 	      l_unrounded_exposure := l_total_exposure;

	      OE_CREDIT_CHECK_UTIL.Rounded_Amount(l_limit_curr_code,
						l_unrounded_exposure,
						l_total_exposure);


            G_total_site_exposure:=l_total_exposure ; -------new (FPI)


            G_limit_currency :=l_limit_curr_code ; -------new (FPI)


            IF x_credit_level = 'CUSTOMER'  OR x_credit_level = 'PARTY'
            THEN
              l_prev_customer_id    := p_customer_id;
              l_customer_result_out := l_cc_result_out;
            END IF;

        ELSE
          IF G_debug_flag = 'Y'
          THEN
            OE_DEBUG_PUB.Add('customer exposure already checked');
          END IF;

            -- customer exposure already checked, retrieve the result
            l_cc_result_out := l_customer_result_out;
        END IF;

        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

         IF l_cc_overall_result_out = 'FAIL' THEN
           l_cc_result_out := l_cc_overall_result_out;
           -- in order to disply useful message if two or more checkings fail.

           IF INSTR(l_cc_limit_used, ',') >0  THEN
             -- l_cc_limit_used := l_cc_limit_used || ', overall limit exceeded';
             -- bug 4153299
             l_cc_limit_used := l_cc_limit_used || ', '
                           || OE_CREDIT_CHECK_UTIL.Get_CC_Lookup_Meaning('OE_CC_LIMIT', 'OVERALL');

           --ER8880886
            i_hld_rec := i_hld_rec +1;
            g_hold_reason_rec.extend;
            g_hold_reason_rec(i_hld_rec) := 'OE_CC_HOLD_OVERALL';
           --ER8880886

           ELSIF l_cc_limit_used IS NOT NULL THEN

      	         --ER8880886
      	         i_hld_rec := i_hld_rec +1;
       		 g_hold_reason_rec.extend;
       		 g_hold_reason_rec(i_hld_rec) := 'OE_CC_HOLD_OVERALL';
           	 --ER8880886

             IF l_cc_trx_result_out = 'FAIL' THEN
                --  l_cc_limit_used := 'Order limit, overall limit exceeded';
                -- bug 4153299
                l_cc_limit_used
                  :=  OE_CREDIT_CHECK_UTIL.Get_CC_Lookup_Meaning('OE_CC_LIMIT', 'ORDER')
                  ||', '
                  || OE_CREDIT_CHECK_UTIL.Get_CC_Lookup_Meaning('OE_CC_LIMIT', 'OVERALL');
             ELSIF l_cc_duedate_result_out = 'FAIL' THEN
               -- l_cc_limit_used := 'Overdue invoices found'||', overall limit exceeded'; --commented ER8880886
               l_cc_limit_used := OE_CREDIT_CHECK_UTIL.Get_CC_Lookup_Meaning('OE_CC_LIMIT', 'OVERDUE') || ', '
                || OE_CREDIT_CHECK_UTIL.Get_CC_Lookup_Meaning('OE_CC_LIMIT', 'OVERALL');	--ER8880886

             END IF;
           ELSE
             l_cc_limit_used := 'OVERALL';

             --ER8880886
             i_hld_rec := i_hld_rec +1;
             g_hold_reason_rec(i_hld_rec) := 'OE_CC_HOLD_OVERALL';
             --ER8880886

           END IF;

           -- set g_cc_limit_used here in order to indicate Overall Limit was
           -- used in the subsequent call to submit Credit Management Request.
           -- l_cc_limit_used will be passed to display messages.
           G_cc_limit_used := 'OVERALL';
        END IF;

        -- l_cc_limit_used := 'OVERALL';

      ELSE
        l_cc_limit_used := 'TRX';
      END IF;
    ELSE
      l_cc_limit_used := 'DUEDATE';
    END IF;
  ELSE
    IF G_debug_flag = 'Y'
    THEN
      OE_DEBUG_PUB.Add('No credit check required');
    END IF;

    l_cc_result_out := 'NOCHECK';
  END IF;
  -- bug 5907331
  G_credit_limit_entity_id := l_credit_limit_entity_id;

  --
  -- Update database table with hold information
  --
  IF l_cc_result_out = 'FAIL' THEN
    IF l_credit_hold_level = 'ORDER' THEN

    -- bug 4153299
    --6616741 l_cc_profile_used := OE_CREDIT_CHECK_UTIL.Get_CC_Lookup_Meaning('OE_CC_PROFILE', l_cc_profile_used);

    Apply_Order_CC_Hold
       (  p_header_id          => p_header_rec.header_id
        ,  p_order_number        => p_header_rec.order_number
        , p_calling_action     => p_calling_action
        , p_cc_limit_used      => l_cc_limit_used
        , p_cc_profile_used    => l_cc_profile_used
        , p_item_category_id   => NULL
        , p_credit_hold_level  => l_credit_hold_level
        , p_credit_check_rule_rec=> p_credit_check_rule_rec
        , x_cc_result_out      => l_cc_result_out
       );

       ----Bug 4293874 starts----------
       ---------------------- Start Credit Review --------------

       IF l_cc_result_out in ('FAIL_HOLD','FAIL_NONE','FAIL')
       THEN
        --IF l_cc_overall_result_out = 'FAIL' --ER8880886
        -- THEN 			      --ER8880886
           IF OE_CREDIT_CHECK_UTIL.G_crmgmt_installed is NULL
           THEN
             OE_CREDIT_CHECK_UTIL.G_crmgmt_installed :=
               AR_CMGT_CREDIT_REQUEST_API.is_Credit_Management_Installed ;
           END IF;

           IF OE_CREDIT_CHECK_UTIL.G_crmgmt_installed
           THEN
            -- bug 5907331
            l_review_party_id := p_party_id;
             ------check if the credit check level is PARTY, CUSTOMER or SITE
             IF x_credit_level ='PARTY'
             THEN
               l_customer_id:=NULL;
               l_site_use_id:=NULL;
            -- bug 5907331
                IF p_party_id <> nvl(l_credit_limit_entity_id ,p_party_id) THEN
                   l_review_party_id := l_credit_limit_entity_id;
                END IF;
             ELSIF x_credit_level ='CUSTOMER'
             THEN
               l_customer_id:=p_customer_id;
               l_site_use_id:=NULL;
             ELSIF x_credit_level ='SITE'
             THEN
               l_customer_id:=p_customer_id;
               l_site_use_id:=p_site_use_id;
             END IF;

             -------------get profile values:
             l_source_org_id  := FND_PROFILE.VALUE('ORG_ID');
             l_source_user_id := FND_PROFILE.VALUE ('USER_ID');
             l_source_resp_id := FND_PROFILE.VALUE ('RESP_ID');
             l_source_appln_id  := FND_PROFILE.VALUE ('RESP_APPL_ID');
             l_source_security_group_id := FND_PROFILE.VALUE('SECURITY_GROUP_ID');

           IF G_debug_flag = 'Y'
           THEN
             OE_DEBUG_PUB.Add('Calling Create_credit_request,
                              credit check level= '||x_credit_level);

             OE_DEBUG_PUB.Add('Parameters: ');
             OE_DEBUG_PUB.Add('-------------------------------------------');
             OE_DEBUG_PUB.Add('p_requestor_id= '||TO_CHAR(fnd_global.employee_id));
             OE_DEBUG_PUB.Add('p_review_type= ORDER_HOLD');
             OE_DEBUG_PUB.Add('p_credit_classification= NULL');
             OE_DEBUG_PUB.Add('p_requested_amount= '||TO_CHAR(l_total_exposure ));
             OE_DEBUG_PUB.Add('p_requested_currency= '||l_limit_curr_code);
             OE_DEBUG_PUB.Add('p_trx_amount= '||TO_CHAR(g_order));
             OE_DEBUG_PUB.Add('p_trx_currency= '||p_header_rec.transactional_curr_code );
             OE_DEBUG_PUB.Add('p_credit_type = TRADE' );
             OE_DEBUG_PUB.Add('p_term_length = NULL' );
             OE_DEBUG_PUB.Add('p_credit_check_rule_id= '||
                  TO_CHAR(p_credit_check_rule_rec.credit_check_rule_id));
             OE_DEBUG_PUB.Add('p_credit_request_status = SUBMIT');
             OE_DEBUG_PUB.Add('p_party_id= '||TO_CHAR(p_party_id));
             OE_DEBUG_PUB.Add('p_cust_account_id= '||TO_CHAR(l_customer_id));
             OE_DEBUG_PUB.Add('p_cust_acct_site_id = NULL');
             OE_DEBUG_PUB.Add('p_site_use_id= '||TO_CHAR(l_site_use_id));
             OE_DEBUG_PUB.Add('p_contact_party_id = NULL');
             OE_DEBUG_PUB.Add('p_notes = NULL');
             OE_DEBUG_PUB.Add('p_source_org_id= '||TO_CHAR(l_source_org_id));
             OE_DEBUG_PUB.Add('p_source_user_id= '||TO_CHAR(l_source_user_id));
             OE_DEBUG_PUB.Add('p_source_resp_id= '||TO_CHAR(l_source_resp_id));
             OE_DEBUG_PUB.Add('p_source_appln_id= '||TO_CHAR(l_source_appln_id));
             OE_DEBUG_PUB.Add('p_source_security_group_id= '||TO_CHAR(l_source_security_group_id));
             OE_DEBUG_PUB.Add('p_source_name  = OM');
             OE_DEBUG_PUB.Add('p_source_column1 = header_id= '||
                  TO_CHAR(p_header_rec.header_id));
             OE_DEBUG_PUB.Add('p_source_column2 = order_number= '||
                  TO_CHAR(p_header_rec.order_number));
             OE_DEBUG_PUB.Add('p_source_column3= ORDER');

           END IF;
           ----------------Submit Credit Review--------------------
           AR_CMGT_CREDIT_REQUEST_API.Create_credit_request
           ( p_api_version           => 1.0
           , p_init_msg_list         => FND_API.G_FALSE
           , p_commit                => FND_API.G_FALSE
           , p_validation_level      => FND_API.G_VALID_LEVEL_FULL
           , x_return_status         => x_return_status
           , x_msg_count             => l_msg_count
           , x_msg_data              => l_msg_data
           , p_application_number    => NULL
           , p_application_date      => SYSDATE
           , p_requestor_type        => NULL
           , p_requestor_id          => fnd_global.employee_id
           , p_review_type           => 'ORDER_HOLD'
           , p_credit_classification => NULL
           , p_requested_amount      => l_total_exposure
           , p_requested_currency    => l_limit_curr_code
           , p_trx_amount            => g_order
           , p_trx_currency          => p_header_rec.transactional_curr_code
           , p_credit_type           => 'TRADE'
           , p_term_length           => NULL  --the unit is no of months
           , p_credit_check_rule_id  => p_credit_check_rule_rec.credit_check_rule_id
           , p_credit_request_status => 'SUBMIT'
           , p_party_id              => l_review_party_id -- bug 5907331
           , p_cust_account_id       => l_customer_id
           , p_cust_acct_site_id     => NULL
           , p_site_use_id           => l_site_use_id
           , p_contact_party_id      => NULL --party_id of the pseudo party
           , p_notes                 => NULL  --contact relationship.
           , p_source_org_id         => l_source_org_id
           , p_source_user_id        => l_source_user_id
           , p_source_resp_id        => l_source_resp_id
           , p_source_appln_id       => l_source_appln_id
           , p_source_security_group_id => l_source_security_group_id
           , p_source_name           => 'OM'
           , p_source_column1        => p_header_rec.header_id
           , p_source_column2        => p_header_rec.order_number
           , p_source_column3        => 'ORDER'
           , p_credit_request_id     => l_request_id
           , p_hold_reason_rec       => g_hold_reason_rec  --ER8880886
           );

           IF x_return_status='S'
           THEN
             FND_MESSAGE.Set_Name('ONT','OE_CC_CMGT_REVIEW');
             FND_MESSAGE.Set_Token('REQUEST_ID',l_request_id);
             OE_MSG_PUB.Add;
           END IF;

           IF G_debug_flag = 'Y'
           THEN
             IF x_return_status='S'
             THEN
               OE_DEBUG_PUB.Add('Credit review submitted, request_id= '
                     ||TO_CHAR(l_request_id));
             ELSE
               OE_DEBUG_PUB.Add('Credit review has not been submitted');
             END IF;

             OE_DEBUG_PUB.Add('l_request_id= '||TO_CHAR(l_request_id));
             OE_DEBUG_PUB.Add('x_return_status= '||x_return_status);
             OE_DEBUG_PUB.Add('l_msg_count= '||TO_CHAR(l_msg_count));
             OE_DEBUG_PUB.Add('l_msg_data= '||l_msg_data);

           END IF;

         END IF;

       --END IF;       --ER8880886

      END IF;
      --------------------------------- End Credit review -----
      ---Bug 4293874 ends---------
    ELSE


     -- ER 6135714
        IF G_debug_flag = 'Y'  THEN
            OE_DEBUG_PUB.Add('Applying Hold for hold line sequence ');
        END IF;

     IF (l_hold_line_seq = '1' OR p_calling_action = 'BOOKING'
          OR nvl(p_credit_check_rule_rec.uninvoiced_orders_flag,'N') = 'Y') THEN
        IF G_debug_flag = 'Y'  THEN
            OE_DEBUG_PUB.Add('Applying Hold for all hold line sequence option');
        END IF;
     -- ER 6135714
      Apply_Other_Holds
        (  p_header_id           => p_header_rec.header_id
         , p_customer_id         => p_customer_id
         , p_site_use_id         => p_site_use_id
         , p_party_id            => l_credit_limit_entity_id
         , p_cc_limit_used       => l_cc_limit_used
         , p_cc_profile_used     => l_cc_profile_used
         ,p_holds_table          => p_holds_table
        );
      ELSE -- ER 6135714
         Update_Holds_Table
         (  p_holds_table         => p_holds_table
         , p_hold                => 'OTHER'
         , p_cc_limit_used       => l_cc_limit_used
         , p_cc_profile_used     => l_cc_profile_used
         , p_customer_id         => p_customer_id
         , p_site_use_id         => p_site_use_id
         , p_party_id            => l_credit_limit_entity_id
         , p_exposure	         =>   l_total_exposure
         , p_overall_credit_limit => l_overall_credit_limit
        );
     END IF; -- ER 6135714

    END IF;
  END IF;
  x_cc_result_out := l_cc_result_out;
  -- If no need to check order, then the non-item holds should be released.
  IF NVL(l_check_order,'N') = 'N' THEN
    x_check_exposure_mode := 'NOCHECK';
  END IF;

  -----assign l_cc_limit_used to the Global
  -- G_cc_limit_used := l_cc_limit_used;
  -- bug 4002820
   IF nvl(g_cc_limit_used,'NULL') <> 'OVERALL' THEN
    G_cc_limit_used := l_cc_limit_used;
  END IF;

  IF G_debug_flag = 'Y'
  THEN
     OE_DEBUG_PUB.Add('OEXVCRLB: Out Check_Other_Credit Limits');
  END IF;


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    RAISE FND_API.G_EXC_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
 	 OE_MSG_PUB.Add_Exc_Msg
	   (   G_PKG_NAME, 'Check_Other_Credit_Limits');
    END IF;
    OE_DEBUG_PUB.ADD( SUBSTR(SQLERRM,1,300),1 ) ;

END Check_Other_Credit_Limits;

-------------------------------------------------
-- Read from the plsql holds table and update the
-- database holds table.
-------------------------------------------------
PROCEDURE Apply_And_Release_Holds
  ( p_header_id            IN    NUMBER
  , p_order_number         IN    NUMBER
  , p_holds_table          IN    Line_Holds_Tbl_Rectype
  , p_calling_action       IN    VARCHAR2
  , p_check_exposure_mode  IN    VARCHAR2
  , p_credit_hold_level    IN    VARCHAR2
  , p_credit_check_rule_rec IN
                  OE_CREDIT_CHECK_UTIL.OE_credit_rules_rec_type
  , x_cc_result_out        OUT   NOCOPY VARCHAR2
  , x_return_status        OUT   NOCOPY VARCHAR2
  )
IS
  l_notification_id     NUMBER;
  l_wfn_to              VARCHAR2(100);
  l_result_out          VARCHAR2(30);
  l_cc_result_out       VARCHAR2(30) ;
  l_comment             VARCHAR2(2000);
  l_cc_hdr_result_out   VARCHAR2(30) ;

BEGIN
  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.Add('OEXVCRLB: In Apply_And_Release_Holds');
    OE_DEBUG_PUB.Add('p_header_id: '||p_header_id);
    OE_DEBUG_PUB.Add('start Loop for holds table');
    OE_DEBUG_PUB.Add('p_check_exposure_mode => '|| p_check_exposure_mode );
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  --
  -- Get the order number for notification
  --

  FOR i IN 1..p_holds_table.COUNT LOOP
    IF p_holds_table(i).hold IS NOT NULL
    THEN

      --bug 4503551
      OE_MSG_PUB.Set_Msg_Context(
           p_entity_code          => 'LINE'
          ,p_entity_id            => p_holds_table(i).line_id
	  ,p_header_id            => p_header_id
          ,p_line_id              => p_holds_table(i).line_id );

      l_cc_result_out := 'FAIL_NONE' ;

      Apply_Line_CC_Hold
       (  p_header_id             => p_header_id
       ,  p_order_number          => p_order_number
        , p_line_id               => p_holds_table(i).line_id
        , p_line_number           => p_holds_table(i).line_number
        , p_calling_action        => p_calling_action
        , p_cc_limit_used         => p_holds_table(i).limit_used
        , p_cc_profile_used       => p_holds_table(i).profile_used
        , p_customer_id           => p_holds_table(i).customer_id
        , p_site_use_id           => p_holds_table(i).site_use_id
        , p_party_id              => p_holds_table(i).party_id
        , p_item_category_id      => p_holds_table(i).item_category_id
        , p_credit_hold_level     => p_credit_hold_level
        , p_credit_check_rule_rec => p_credit_check_rule_rec
        , x_cc_result_out         => l_result_out
       );

       IF G_debug_flag = 'Y'
       THEN
         OE_DEBUG_PUB.Add('Apply Hold: l_result_out = '|| l_result_out);
       END IF;

      IF l_result_out = 'FAIL_HOLD' THEN
        l_cc_result_out := l_result_out;
      END IF;

      OE_MSG_PUB.Reset_Msg_Context('LINE'); --bug 4503551

    ELSIF p_check_exposure_mode = 'INLINE' OR
          p_check_exposure_mode = 'NOCHECK'
    THEN


      Release_Line_CC_Hold
        ( p_header_id           => p_header_id
        , p_order_number        => p_order_number
        , p_line_id             => p_holds_table(i).line_id
        , p_line_number         => p_holds_table(i).line_number
        , p_calling_action      => p_calling_action
        , p_credit_hold_level   => p_credit_hold_level
        , x_cc_result_out       => l_result_out
        );


     ----------------------------------------------------------
     -- IF l_result_out = HDR_HOLD, thst means that there is a credit
     -- hold already at header level. This hold must be released
     -- first and then continue the lines processed again
     -------------------------------------------------------------

      IF l_result_out = 'HDR_HOLD'
      THEN
        IF NVL(G_hdr_hold_released,'N') = 'N'
        THEN
          BEGIN
             IF G_debug_flag = 'Y'
             THEN
               OE_DEBUG_PUB.ADD('Call Releases_Order_Cc_Hold ');
               OE_DEBUG_PUB.ADD('Before G_hdr_hold_released = '||
                G_hdr_hold_released );
             END IF;

             Release_Order_CC_Hold
             ( p_header_id          => p_header_id
             , p_order_number       => p_order_number
             , p_calling_action     => p_calling_action
             , p_credit_hold_level  => p_credit_hold_level
             , x_cc_result_out      => l_cc_hdr_result_out
             );


             G_hdr_hold_released := 'Y' ;


             l_result_out := NULL ;

             Release_Line_CC_Hold
             ( p_header_id           => p_header_id
             , p_order_number        => p_order_number
             , p_line_id             => p_holds_table(i).line_id
             , p_line_number         => p_holds_table(i).line_number
             , p_calling_action      => p_calling_action
             , p_credit_hold_level   => p_credit_hold_level
             , x_cc_result_out       => l_result_out
             );

          END ;

        ELSE
          IF G_debug_flag = 'Y'
          THEN
            OE_DEBUG_PUB.ADD('Header holds released already');
          END IF;
        END IF;
        l_cc_hdr_result_out := NULL ;
      END IF; -- End HDR_HOLD

    END IF; --  Holds table IF
  END LOOP;


  x_cc_result_out := l_cc_result_out;

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.Add('x_cc_result_out => '|| x_cc_result_out );
    OE_DEBUG_PUB.Add('OEXVCRLB: Out Apply_And_Release_Holds');
  END IF;
EXCEPTION
  WHEN others THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      OE_MSG_PUB.Add_Exc_Msg
      ( G_PKG_NAME
      , 'Apply_And_Release_Holds'
      );
    END IF;
    OE_DEBUG_PUB.ADD( SUBSTR(SQLERRM,1,300),1 ) ;
END Apply_And_Release_Holds;

------------------------------------------------+
-- Mainline Function that will read an Order    |
-- Header and Determine if should be checked,   |
-- calculates total exposure, find credit       |
-- and determine result for calling function.   |
-------------------------------------------------

PROCEDURE Check_order_lines_credit
  ( p_header_rec            IN  OE_ORDER_PUB.Header_Rec_Type
  , p_calling_action        IN  VARCHAR2 DEFAULT 'BOOKING'
  , p_credit_check_rule_rec IN  OE_CREDIT_CHECK_UTIL.OE_credit_rules_rec_type
  , p_system_parameter_rec  IN  OE_CREDIT_CHECK_UTIL.OE_systems_param_rec_type
  , x_msg_count             OUT NOCOPY NUMBER
  , x_msg_data              OUT NOCOPY VARCHAR2
  , x_cc_result_out         OUT NOCOPY VARCHAR2
  , x_cc_limit_used         OUT NOCOPY VARCHAR2
  , x_cc_profile_used       OUT NOCOPY VARCHAR2
  , x_return_status         OUT NOCOPY VARCHAR2
  ) IS

  l_credit_level            VARCHAR2(30); -- limits at cust or site level
  l_check_order             VARCHAR2(1);  -- if Order requires credit check
  l_check_exposure_mode     VARCHAR2(20);
  l_cc_profile_used         VARCHAR2(30) := NULL;
  l_cc_limit_used           VARCHAR2(30) := NULL;
  l_msg_count		    NUMBER;
  l_msg_data	            VARCHAR2(2000);
  l_holds_table             Line_Holds_Tbl_Rectype;
  l_release_order_hold      VARCHAR2(1) := 'Y';
  l_credit_hold_level       VARCHAR2(30);
  l_cc_result_out           VARCHAR2(30);
  l_own_customer_id         NUMBER;
  l_global_exposure_flag    VARCHAR2(1);
  l_party_id                NUMBER; -----------------new (FPI)
  l_request_id              NUMBER;  -----------------new (FPI)
  l_customer_id             NUMBER;     -----------------------new (FPI)
  l_site_use_id             NUMBER;     -----------------------new (FPI)
  l_source_org_id           NUMBER;     -----------------------new (FPI)
  l_source_user_id          NUMBER;     -----------------------new (FPI)
  l_source_resp_id          NUMBER;     -----------------------new (FPI)
  l_source_appln_id         NUMBER;     -----------------------new (FPI)
  l_source_security_group_id NUMBER;     -----------------------new (FPI)

  -- bug 5907331
  l_review_party_id NUMBER;

  CURSOR  cust_and_site_csr IS
  SELECT  DISTINCT
          ool.invoice_to_org_id site_use_id
  FROM    oe_order_lines_all ool
  WHERE    ool.header_id	        = p_header_rec.header_id
  AND      ool.open_flag                = 'Y'
  AND      NVL(ool.invoiced_quantity,0) = 0
  AND      NVL(ool.shipped_quantity,0) = 0
  ORDER BY  1 ;


  -- bug 4767772
  -- to select lines on credit checking hold but having payment term with
  -- credit check flag unchecked, this might be resulted by user changing
  -- the payment term after hold got applied.
  CURSOR lines_on_hold IS
  SELECT l.line_id, l.line_number
  FROM   oe_order_headers_all h,
         oe_order_lines_all l,
         ra_terms t
  WHERE  h.header_id = p_header_rec.header_id
  AND    h.header_id = l.header_id
  AND    l.payment_term_id = t.term_id
  AND    nvl(t.credit_check_flag, 'N') = 'N'
  AND    (EXISTS
           (SELECT 'Y'
           FROM   oe_payment_types_all pt
           WHERE  NVL(l.payment_type_code, 'N') = pt.payment_type_code
           AND pt.credit_check_flag = 'N'
           )
          OR l.payment_type_code IS NULL
          )
  AND    (EXISTS
         (SELECT 'Y'
         FROM   oe_order_holds_all oh,
                oe_hold_sources_all hs
         WHERE  oh.header_id = p_header_rec.header_id
         AND    oh.line_id = l.line_id
         AND    oh.hold_release_id IS NULL
         AND    oh.hold_source_id = hs.hold_source_id
         AND    hs.hold_id = 1
         ));



BEGIN
 IF G_debug_flag = 'Y'
 THEN
   OE_DEBUG_PUB.Add('OEXVCRLB: In Check_order_lines_credit API',1);
 END IF;

  --
  -- Set the default behavior to pass credit check
  --
  x_cc_result_out     := 'NOCHECK';
  x_return_status     := FND_API.G_RET_STS_SUCCESS;
  l_global_exposure_flag := 'N' ;

  G_result_out        := 'PASS' ;
  G_release_status    := 'NO' ;
  G_hdr_hold_released := 'N' ;


  OE_Credit_Engine_GRP.G_currency_error_msg := NULL;

   l_credit_hold_level := p_credit_check_rule_rec.CREDIT_HOLD_LEVEL_CODE ;

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.Add('Inital starting G_result_out = '|| G_result_out);
    OE_DEBUG_PUB.Add('l_credit_hold_level => '||
             l_credit_hold_level );
    OE_DEBUG_PUB.Add('Inital G_hdr_hold_released = '||
            G_hdr_hold_released);
    OE_DEBUG_PUB.Add('Inital G_release_status = '||
            G_release_status );
    OE_DEBUG_PUB.Add('G_currency_error_msg = '||
     OE_Credit_Engine_GRP.G_currency_error_msg );
    OE_DEBUG_PUB.Add('  ');
    OE_DEBUG_PUB.Add(' ---------------------------------------');
    OE_DEBUG_PUB.Add('  ');
    OE_DEBUG_PUB.Add(' p_calling_action     = ' || p_calling_action );
    OE_DEBUG_PUB.Add(' OEXVCRLB:Header ID   = ' || p_header_rec.header_id );
    OE_DEBUG_PUB.Add(' ORDER NUMBER         = ' || p_header_rec.order_number );
    OE_DEBUG_PUB.Add(' Credit check rule ID = '
       || p_credit_check_rule_rec.credit_check_rule_id );
    OE_DEBUG_PUB.Add(' conversion type = '
       || p_credit_check_rule_rec.conversion_type );
    OE_DEBUG_PUB.Add(' Credit check level = '
       || p_credit_check_rule_rec.credit_check_level_code );

    OE_DEBUG_PUB.Add(' CHECK_ITEM_CATEGORIES_FLAG = '
                || p_credit_check_rule_rec.CHECK_ITEM_CATEGORIES_FLAG );
    OE_DEBUG_PUB.Add(' SEND_HOLD_NOTIFICATIONS_FLAG = '
                || p_credit_check_rule_rec.SEND_HOLD_NOTIFICATIONS_FLAG );
    OE_DEBUG_PUB.Add('  ');
    OE_DEBUG_PUB.Add(' ---------------------------------------');
    OE_DEBUG_PUB.Add('  ');
    OE_DEBUG_PUB.Add('start SITE loop ');
  END IF;

  -- bug 4767772
  -- release the credit hold for lines with credit check flag not enabled.
  FOR c_lines IN lines_on_hold
  LOOP

    Release_Line_CC_Hold
        ( p_header_id           => p_header_rec.header_id
        , p_order_number        => p_header_rec.order_number
        , p_line_id             => c_lines.line_id
        , p_line_number         => c_lines.line_number
        , p_calling_action      => p_calling_action
        , p_credit_hold_level   => 'LINE'
        , x_cc_result_out       => l_cc_result_out
        );

    IF G_debug_flag = 'Y'
    THEN
      oe_debug_pub.add ('line level credit checking hold is released for line: '||c_lines.line_id,3);
      oe_debug_pub.add ('l_cc_result_out is : '||l_cc_result_out ,3);
    END IF;

  END LOOP;




  FOR c_site IN cust_and_site_csr
  LOOP
    IF G_debug_flag = 'Y'
    THEN
      OE_DEBUG_PUB.ADD('OEXVCRLB: HeaderID/SiteUseID:' ||
      p_header_rec.header_id  || '/' || c_site.site_use_id, 1);
    END IF;

      l_own_customer_id := NULL ;

    BEGIN
      SELECT /* MOAC_SQL_CHANGE */ cas.cust_account_id
           , ca.party_id             --------------new (FPI)
      INTO   l_own_customer_id
           , l_party_id              --------------new (FPI)
      FROM   HZ_cust_acct_sites_all cas
             , HZ_cust_site_uses su
             , hz_cust_accounts_all ca    --------------new (FPI)
      WHERE  su.site_use_id = c_site.site_use_id
        AND  cas.cust_acct_site_id = su.cust_acct_site_id
        AND  cas.cust_account_id=ca.cust_account_id; ---------new (FPI)


      IF G_debug_flag = 'Y'
      THEN
        OE_DEBUG_PUB.ADD(' l_own_customer_id = '|| l_own_customer_id );
      END IF;

      EXCEPTION
       WHEN NO_DATA_FOUND
       THEN
         OE_DEBUG_PUB.ADD(' Exception - No data  found ');
         RAISE;
       WHEN TOO_MANY_ROWS
       THEN
         OE_DEBUG_PUB.ADD(' Exception - TOO_MANY_ROWS');
         RAISE;
    END ;



    --
    -------------------------------------------------------
    -- Initialize site level variables.
    -------------------------------------------------------
    --
    -- Recreate the plsql holds table for each site
    --

   Create_Holds_Table
      (  p_header_id      => p_header_rec.header_id
       , p_site_use_id    => c_site.site_use_id
       , x_holds_table    => l_holds_table
      );

    IF G_debug_flag = 'Y'
    THEN
      OE_DEBUG_PUB.Add('PLSQL Holds table created');
    END IF;
    ----------------------------------------------------------
    -- Perform item category credit check for the order site
    -- IF the check failed,
    --   set the result to FAIL.
    -- IF no credit check is performed, THEN return NOCHECK in
    -- x_cc_result_out
    ----------------------------------------------------------
    --
    ---------------------------------------------------+
    -- order site use is subject to credit check:      |
    ---------------------------------------------------|
    -- check 1: item limit             <-- in progress |
    -- check 2: max-past-due-inv limit                 |
    -- check 3: trx limit                              |
    -- check 4: overall limit                          |
    ---------------------------------------------------+

    IF G_debug_flag = 'Y'
    THEN
      OE_DEBUG_PUB.Add(' table count = '|| l_holds_table.COUNT );
    END IF;

    IF l_holds_table.COUNT > 0
    THEN

     IF p_credit_check_rule_rec.CHECK_ITEM_CATEGORIES_FLAG = 'Y'
     THEN

       Check_Item_Limits
       ( p_header_rec            => p_header_rec
       , p_customer_id           => l_own_customer_id
       , p_site_use_id           => c_site.site_use_id
       , p_calling_action        => p_calling_action
       , p_credit_check_rule_rec => p_credit_check_rule_rec
       , p_system_parameter_rec  => p_system_parameter_rec
       , p_holds_table           => l_holds_table
       , x_cc_result_out         => l_cc_result_out
       , x_return_status         => x_return_status
       );

      ELSE
        l_cc_result_out := 'PASS' ;
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF G_debug_flag = 'Y'
        THEN
          OE_DEBUG_PUB.Add(' No check item categories, Flag OFF ');
        END IF;

      END IF;


        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        --
        -- Apply the database hold and Exit the bill-to site loop if
        -- credit hold level is ORDER and the order failed credit check.
        --
        IF l_credit_hold_level = 'ORDER' AND
        ( l_cc_result_out = 'FAIL' OR l_cc_result_out = 'FAIL_HOLD' OR
        l_cc_result_out = 'FAIL_NONE')
      THEN
        -- set the order hold release flag
        l_release_order_hold := 'N';

         IF G_debug_flag = 'Y'
         THEN
            OE_DEBUG_PUB.Add(' Exit SITE loop as order failed ');
         END IF;

        EXIT;

      END IF;
      --
      -- Check other credit limits regardless if the lines of the
      -- site have item category failure.  Since only lines with
      -- items belonging to the failed item category are placed on
      -- hold, other lines will need to be checked for other holds.
      -- Otherwise, if no further checking is done, then those lines
      -- can be booked even though they might fail other credit limits.
      --

      ---------------------------------------------------+
      -- Check other credit limits for the bill-to site: |
      -- check 2: max-past-due-inv limit                 |
      -- check 3: trx limit                              |
      -- check 4: overall limit                          |
      ---------------------------------------------------+


      Check_Other_Credit_Limits
      ( p_header_rec            => p_header_rec
      , p_customer_id           => l_own_customer_id
      , p_site_use_id           => c_site.site_use_id
      , p_calling_action        => p_calling_action
      , p_credit_check_rule_rec => p_credit_check_rule_rec
      , p_system_parameter_rec  => p_system_parameter_rec
      , p_holds_table           => l_holds_table
      , p_party_id              => l_party_id
      , x_credit_level          => l_credit_level
      , x_check_exposure_mode   => l_check_exposure_mode
      , x_cc_result_out         => l_cc_result_out
      , x_return_status         => x_return_status
      , x_global_exposure_flag  => l_global_exposure_flag
      );

      IF G_debug_flag = 'Y'
      THEN
        OE_DEBUG_PUB.Add('Check_Other_Credit_Limits : Result Out = '
              || l_cc_result_out );
        OE_DEBUG_PUB.Add('Check_Other_Credit_Limits: Return Status = '
               || x_return_status );
      END IF;


      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Apply order level credit hold to the database if it necessary

      IF l_credit_hold_level = 'ORDER' AND
        ( l_cc_result_out = 'FAIL' OR l_cc_result_out = 'FAIL_HOLD' OR
         l_cc_result_out = 'FAIL_NONE') THEN
        -- set the order hold release flag
        l_release_order_hold := 'N';

        IF G_debug_flag = 'Y'
        THEN
          OE_DEBUG_PUB.Add(' Exit site loop as FAILED ');
        END IF;

        EXIT; --exit out of bill-to site loop

      END IF;

      --
      -- Actually apply and release holds in the database table.
      --

      IF     l_cc_result_out     <> 'NOCHECK'
         AND l_credit_hold_level = 'LINE'
      THEN



        Apply_And_Release_Holds
         ( p_header_id             => p_header_rec.header_id
         , p_order_number          => p_header_rec.order_number
         , p_holds_table           => l_holds_table
         , p_calling_action        => p_calling_action
         , p_check_exposure_mode   => l_check_exposure_mode
         , p_credit_hold_level     => l_credit_hold_level
         , p_credit_check_rule_rec => p_credit_check_rule_rec
         , x_cc_result_out         => l_cc_result_out
         , x_return_status         => x_return_status
         );


        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
      END IF;

   ------------------------- Credit review ------------

       IF l_cc_result_out in ('FAIL_HOLD','FAIL_NONE','FAIL')
       THEN
         ---------submit AR Credit Review---------
         --IF OE_CREDIT_CHECK_LINES_PVT.G_cc_limit_used = 'OVERALL' --ER8880886
         --THEN							    --ER8880886

           IF OE_CREDIT_CHECK_UTIL.G_crmgmt_installed is NULL
           THEN
               OE_CREDIT_CHECK_UTIL.G_crmgmt_installed :=
         AR_CMGT_CREDIT_REQUEST_API.is_Credit_Management_Installed ;
           END IF;

         IF OE_CREDIT_CHECK_UTIL.G_crmgmt_installed
         THEN

           IF G_debug_flag = 'Y'
           THEN
             OE_DEBUG_PUB.Add('Calling Create_credit_request ');
           END IF;
                -- bug 5907331
                l_review_party_id := l_party_id;
           ------check if the credit check level is PARTY, CUSTOMER or SITE
           IF l_credit_level ='PARTY'
           THEN
               l_customer_id := NULL;
               l_site_use_id := NULL;
                -- bug 5907331
                IF l_party_id <> nvl(G_credit_limit_entity_id ,l_party_id) THEN
                   l_review_party_id := G_credit_limit_entity_id;
                END IF;

           ELSIF l_credit_level ='CUSTOMER'
           THEN
             l_customer_id := l_own_customer_id ;
               l_site_use_id := NULL;
           ELSIF l_credit_level ='SITE'
           THEN
               l_customer_id := l_own_customer_id;
               l_site_use_id := c_site.site_use_id;
           END IF;

             -------------get profile values:
             l_source_org_id  := p_header_rec.org_id;   /* MOAC ORG_ID CHANGE */ --FND_PROFILE.VALUE('ORG_ID');
             l_source_user_id := FND_PROFILE.VALUE ('USER_ID');
             l_source_resp_id := FND_PROFILE.VALUE ('RESP_ID');
             l_source_appln_id  := FND_PROFILE.VALUE ('RESP_APPL_ID');
             l_source_security_group_id :=
                      FND_PROFILE.VALUE('SECURITY_GROUP_ID');

           IF G_debug_flag = 'Y'
           THEN
             OE_DEBUG_PUB.Add('Calling Create_credit_request,
                              credit check level= '||l_credit_level);
             OE_DEBUG_PUB.Add('Parameters: ');
             OE_DEBUG_PUB.Add('-------------------------------------------');
             OE_DEBUG_PUB.Add('p_requestor_id= '||TO_CHAR(fnd_global.employee_id));
             OE_DEBUG_PUB.Add('p_review_type= ORDER_HOLD');
             OE_DEBUG_PUB.Add('p_credit_classification= NULL');
             OE_DEBUG_PUB.Add('p_requested_amount= '||
                 TO_CHAR(OE_CREDIT_CHECK_LINES_PVT.G_total_site_exposure ));
             OE_DEBUG_PUB.Add('p_requested_currency= '||
                   OE_CREDIT_CHECK_LINES_PVT.G_limit_currency);
             OE_DEBUG_PUB.Add('p_trx_amount= '||
                 TO_CHAR(OE_CREDIT_CHECK_UTIL.g_current_order_value));
             OE_DEBUG_PUB.Add('p_trx_currency= '||
                  p_header_rec.transactional_curr_code );
             OE_DEBUG_PUB.Add('p_credit_type = TRADE' );
             OE_DEBUG_PUB.Add('p_term_length = NULL' );
             OE_DEBUG_PUB.Add('p_credit_check_rule_id= '||
                  TO_CHAR(p_credit_check_rule_rec.credit_check_rule_id));
             OE_DEBUG_PUB.Add('p_credit_request_status = SUBMIT');
             OE_DEBUG_PUB.Add('p_party_id= '||TO_CHAR(l_party_id));
             OE_DEBUG_PUB.Add('p_cust_account_id= '||TO_CHAR(l_customer_id));
             OE_DEBUG_PUB.Add('p_cust_acct_site_id = NULL');
             OE_DEBUG_PUB.Add('p_site_use_id= '||TO_CHAR(l_site_use_id));
             OE_DEBUG_PUB.Add('p_contact_party_id = NULL');
             OE_DEBUG_PUB.Add('p_notes = NULL');
             OE_DEBUG_PUB.Add('p_source_org_id= '||TO_CHAR(l_source_org_id));
             OE_DEBUG_PUB.Add('p_source_user_id= '||TO_CHAR(l_source_user_id));
             OE_DEBUG_PUB.Add('p_source_resp_id= '||TO_CHAR(l_source_resp_id));
             OE_DEBUG_PUB.Add('p_source_appln_id= '||TO_CHAR(l_source_appln_id));
             OE_DEBUG_PUB.Add('p_source_security_group_id= '||TO_CHAR(l_source_security_group_id));
             OE_DEBUG_PUB.Add('p_source_name  = OM');
             OE_DEBUG_PUB.Add('p_source_column1 = header_id= '||
                    TO_CHAR(p_header_rec.header_id));
             OE_DEBUG_PUB.Add('p_source_column2 = order_number= '||
                      TO_CHAR(p_header_rec.order_number));
             OE_DEBUG_PUB.Add('p_source_column3= LINE');

           END IF;
             ----------------Submit Credit Review--------------------
             AR_CMGT_CREDIT_REQUEST_API.Create_credit_request
             ( p_api_version           => 1.0
             , p_init_msg_list         => FND_API.G_FALSE
             , p_commit                => FND_API.G_FALSE
             , p_validation_level      => FND_API.G_VALID_LEVEL_FULL
             , x_return_status         => x_return_status
             , x_msg_count             => l_msg_count
             , x_msg_data              => l_msg_data
             , p_application_number    => NULL
             , p_application_date      => SYSDATE
             , p_requestor_type        => NULL
             , p_requestor_id          => fnd_global.employee_id
             , p_review_type           => 'ORDER_HOLD'
             , p_credit_classification => NULL
             , p_requested_amount      =>
                       OE_CREDIT_CHECK_LINES_PVT.G_total_site_exposure
             , p_requested_currency    =>
                        OE_CREDIT_CHECK_LINES_PVT.G_limit_currency
             , p_trx_amount            =>
                         OE_CREDIT_CHECK_UTIL.g_current_order_value
             , p_trx_currency          => p_header_rec.transactional_curr_code
             , p_credit_type           => 'TRADE'
             , p_term_length           => NULL  --the unit is no of months
             , p_credit_check_rule_id  =>
                         p_credit_check_rule_rec.credit_check_rule_id
             , p_credit_request_status => 'SUBMIT'
             , p_party_id              => l_review_party_id -- bug 5907331
             , p_cust_account_id       => l_customer_id
             , p_cust_acct_site_id     => NULL
             , p_site_use_id           => l_site_use_id
             , p_contact_party_id      => NULL --party_id of the pseudo party
             , p_notes                 => NULL  --contact relationship.
             , p_source_org_id         => l_source_org_id
             , p_source_user_id        => l_source_user_id
             , p_source_resp_id        => l_source_resp_id
             , p_source_appln_id       => l_source_appln_id
             , p_source_security_group_id => l_source_security_group_id
             , p_source_name           => 'OM'
             , p_source_column1        => p_header_rec.header_id
             , p_source_column2        => p_header_rec.order_number
             , p_source_column3        => 'LINE'
             , p_credit_request_id     => l_request_id
             , p_hold_reason_rec       => g_hold_reason_rec  --ER8880886
             );

             IF x_return_status='S'
             THEN

  	       --bug 4503551
	       OE_MSG_PUB.Set_Msg_Context(
		   p_entity_code        => 'HEADER'
		  ,p_entity_id          => p_header_rec.header_id
		  ,p_header_id			=> p_header_rec.header_id );

               FND_MESSAGE.Set_Name('ONT','OE_CC_CMGT_REVIEW');
               FND_MESSAGE.Set_Token('REQUEST_ID',l_request_id);
               OE_MSG_PUB.Add;
	       OE_MSG_PUB.Reset_Msg_Context('HEADER'); --bug 4503551
             END IF;

              IF G_debug_flag = 'Y'
              THEN
                IF x_return_status='S'
                THEN

                  OE_DEBUG_PUB.Add('Credit review submitted, request_id= '
                     ||TO_CHAR(l_request_id));
                ELSE
                  OE_DEBUG_PUB.Add('Credit review has not been submitted');
                END IF;
              END IF;

              OE_DEBUG_PUB.Add('l_request_id= '||TO_CHAR(l_request_id));
              OE_DEBUG_PUB.Add('x_return_status= '||x_return_status);
              OE_DEBUG_PUB.Add('l_msg_count= '||TO_CHAR(l_msg_count));
              OE_DEBUG_PUB.Add('l_msg_data= '||l_msg_data);


            END IF;

          --END IF; --ER8880886
        END IF; -- credit rev
---------------------------------End Credit review --------------


         G_total_site_exposure := 0; ----------new (FPI)
         G_limit_currency      := NULL ;
         G_cc_limit_used       := NULL ;
      --
      -- Return null for output since it is meaningless at the order level
      --
      IF l_cc_result_out = 'NOCHECK'
          AND l_credit_hold_level = 'LINE'
      THEN
        IF G_debug_flag = 'Y'
        THEN
           OE_DEBUG_PUB.Add('No credit check required');
        END IF;
        --x_cc_result_out := 'NOCHECK';


        Apply_And_Release_Holds
         ( p_header_id             => p_header_rec.header_id
         , p_order_number          => p_header_rec.order_number
         , p_holds_table           => l_holds_table
         , p_calling_action        => p_calling_action
         , p_check_exposure_mode   => l_check_exposure_mode
         , p_credit_hold_level     => l_credit_hold_level
         , p_credit_check_rule_rec => p_credit_check_rule_rec
         , x_cc_result_out         => x_cc_result_out
         , x_return_status         => x_return_status
         );

      ELSE
        x_cc_result_out   := l_cc_result_out ;
        x_cc_limit_used   := l_cc_limit_used;
        x_cc_profile_used := l_cc_profile_used;
      END IF;

    ELSE
     OE_DEBUG_PUB.Add('No credit check as table count = 0 ');
    END IF ;  -- count IF

  END LOOP; -- End of Loop

    -- Release order level credit hold if it exist and if the
  IF G_debug_flag = 'Y'
  THEN
   OE_DEBUG_PUB.Add(' x_cc_result_out = '|| x_cc_result_out );
   OE_DEBUG_PUB.Add(' x_cc_limit_used = '|| x_cc_limit_used );
   OE_DEBUG_PUB.Add(' x_cc_profile_used = '|| x_cc_profile_used );
   OE_DEBUG_PUB.Add(' l_release_order_hold = '|| l_release_order_hold );
  END IF;


   IF     l_credit_hold_level = 'ORDER'
       AND l_release_order_hold = 'Y'
    -- AND l_cc_result_out <> 'NOCHECK'
   THEN

      Release_Order_CC_Hold
        ( p_header_id           => p_header_rec.header_id
        ,  p_order_number       => p_header_rec.order_number
        , p_calling_action      => p_calling_action
        , p_credit_hold_level   =>
                   p_credit_check_rule_rec.credit_hold_level_code

        , x_cc_result_out       => l_cc_result_out
        );
    END IF;
    -- Bug 4506263 FP
    -- x_cc_result_out   := G_result_out ;
       x_cc_result_out   := l_cc_result_out ;

    IF G_debug_flag = 'Y'
    THEN
      OE_DEBUG_PUB.Add(' l_cc_result_out       = '|| l_cc_result_out);
      OE_DEBUG_PUB.Add(' G_result_out          = '|| G_result_out );
      OE_DEBUG_PUB.Add(' G_release_status      = '|| G_release_status );
      OE_DEBUG_PUB.Add(' final x_cc_result_out = '|| x_cc_result_out,1   );
    END IF;
    --
  IF l_credit_hold_level = 'LINE'
  THEN
   --  fix bug 4558056
   --  OE_MSG_PUB.Save_Messages(1);
   --  OE_MSG_PUB.Delete_Msg(OE_MSG_PUB.G_msg_count);

     -- added OR condition for bug 5467793
     IF x_cc_result_out = 'FAIL'
     --OR( NVL(OE_credit_engine_GRP.G_delayed_request, FND_API.G_FALSE ) =
         --FND_API.G_TRUE AND  x_cc_result_out IN ('FAIL_HOLD', 'FAIL_NONE'))
     THEN
    -- Display the general message for the user on the screen

       FND_MESSAGE.Set_Name('ONT','OE_CC_HLD_GENERAL_MSG');

       OE_MSG_PUB.Add;
    END IF;

    IF G_release_status = 'RELEASED'
    THEN

        FND_MESSAGE.Set_Name('ONT','OE_CC_HOLD_REMOVED');
        OE_MSG_PUB.Add;

    END IF;

  END IF;

 IF G_debug_flag = 'Y'
 THEN
   OE_DEBUG_PUB.Add('OEXVCRLB: Out Check_order_lines_credit API',1);
 END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    OE_DEBUG_PUB.Add('Check_order_lines_credit: Error ',1);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    OE_DEBUG_PUB.Add('Check_order_lines_credit: Unexpected Error ',1);
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    OE_DEBUG_PUB.Add('Check_order_lines_credit: Other Unexpected Error ',1);
    OE_DEBUG_PUB.ADD( SUBSTR(SQLERRM,1,300),1 ) ;
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      OE_MSG_PUB.Add_Exc_Msg
      (   G_PKG_NAME
      ,   'Check_order_lines_credit'
      );
    END IF;
END Check_order_lines_credit;


END OE_credit_check_lines_PVT;

/
