--------------------------------------------------------
--  DDL for Package Body OE_LINE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_LINE_UTIL" AS
/* $Header: OEXULINB.pls 120.67.12010000.86 2012/09/14 08:20:00 rahujain ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'oe_line_util';
--bug4080363 commenting out the following
-- bug 3491752
--G_LIST_PRICE_OVERRIDE    Varchar2(30) := nvl(fnd_profile.value('ONT_LIST_PRICE_OVERRIDE_PRIV'), 'NONE');
G_BINARY_LIMIT CONSTANT NUMBER := OE_GLOBALS.G_BINARY_LIMIT; -- Added for bug 8636027

-- Added new API for 12355310
FUNCTION Shipping_Interfaced_Status
(
p_line_id NUMBER
) RETURN VARCHAR2;

-- Added new API for FP bug 6628653 base bug 6513023
PROCEDURE HANDLE_RFR
(
p_line_id            IN NUMBER,
p_top_model_line_id  IN NUMBER,
p_link_to_line_id     IN NUMBER
);

--  Procedure Clear_Dependent_Attr: Moved to OE_LINE_UTIL_EXT (OEXULXTS/B.pls)

-- Added 09-DEC-2002
-- Forward declaration of LOCAL PROCEDURE Log_Blanket_Request
PROCEDURE Log_Blanket_Request
(   p_x_line_rec      IN OUT NOCOPY  OE_Order_PUB.Line_Rec_Type
,   p_old_line_rec    IN OE_Order_PUB.Line_Rec_Type
);

Procedure Log_Dropship_CMS_Request
( p_x_line_rec            IN OUT NOCOPY  OE_Order_PUB.Line_Rec_Type
, p_old_line_rec          IN OE_Order_PUB.Line_Rec_Type
);

PROCEDURE get_customer_details
(   p_org_id                IN  NUMBER
,   p_site_use_code         IN  VARCHAR2
,   x_customer_name         OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_customer_number       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_customer_id           OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_location              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_address1              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_address2              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_address3              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_address4              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_city                  OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_state                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_zip                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_country               OUT NOCOPY /* file.sql.39 change */ VARCHAR2);

------------------------------------------------------------
PROCEDURE Log_CTO_Requests
(p_x_line_rec    IN OUT NOCOPY  OE_Order_PUB.Line_Rec_Type
,p_old_line_rec  IN             OE_Order_PUB.Line_Rec_Type :=
                                   OE_Order_PUB.G_MISS_LINE_REC
,x_return_status OUT NOCOPY /* file.sql.39 change */ VARCHAR2);

PROCEDURE Log_Config_Requests
(p_x_line_rec    IN OUT NOCOPY  OE_Order_PUB.Line_Rec_Type
,p_old_line_rec  IN             OE_Order_PUB.Line_Rec_Type :=
                                   OE_Order_PUB.G_MISS_LINE_REC
,x_return_status OUT NOCOPY /* file.sql.39 change */ VARCHAR2);

PROCEDURE Log_Cascade_Requests
(p_x_line_rec    IN OUT NOCOPY  OE_Order_PUB.Line_Rec_Type
,p_old_line_rec  IN             OE_Order_PUB.Line_Rec_Type :=
                                   OE_Order_PUB.G_MISS_LINE_REC
,x_return_status OUT NOCOPY /* file.sql.39 change */ VARCHAR2);
--------------------------------------------------------------


/*----------------------------------------------------------
Procedure Delete_Dependents
Delete dependents call out for line.
Keep your dependenceis on line here
bug fix 2127356: log update_shipping req here.
bug fix 2670775: Reverse Limits here.
-----------------------------------------------------------*/

Procedure Delete_Dependents
( p_line_id                  IN NUMBER
 ,p_item_type_code           IN VARCHAR2
 ,p_line_category_code       IN VARCHAR2
 ,p_config_header_id         IN NUMBER
 ,p_config_rev_nbr           IN NUMBER
 ,p_schedule_status_code     IN VARCHAR2
 ,p_shipping_interfaced_flag IN VARCHAR2
 ,p_ordered_quantity         IN NUMBER         -- BUG 2670775 Reverse Limits
 ,p_price_request_code       IN VARCHAR2       -- BUG 2670775 Reverse Limits
 ,p_transaction_phase_code   IN VARCHAR2 default null       -- Bug 3315331
)IS
l_return_status varchar2(30);
l_set_tbl_count number;
l_header_id	number;

l_debug_level  CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_delete_lines_tbl           OE_ORDER_PUB.Request_Tbl_Type; -- For bug 3754586
BEGIN
  if l_debug_level > 0 then
   oe_debug_pub.add('Entering in Delete Dependents');
  end if;
   /* set the set type in g_set_tbl to invalid if the line is being deleted */


   IF  OE_SET_UTIL.g_set_tbl.count > 0 THEN

     if l_debug_level > 0 then
       oe_debug_pub.add('Table Count : '||OE_SET_UTIL.g_set_tbl.count,3);
     end if;

       l_set_tbl_count := OE_SET_UTIL.g_set_tbl.first;
       WHILE l_set_tbl_count IS NOT NULL
       LOOP

           IF  OE_SET_UTIL.g_set_tbl(l_set_tbl_count).line_id = p_line_id THEN

               OE_SET_UTIL.g_set_tbl(l_set_tbl_count).set_type := 'INVALID_SET';

             if l_debug_level > 0 then
               oe_debug_pub.add('Set the set type as invalid ',3);
             end if;
           END IF;

           l_set_tbl_count := OE_SET_UTIL.g_set_tbl.next(l_set_tbl_count);

       END LOOP;

   END IF;

    OE_Atchmt_Util.Delete_Attachments
               ( p_entity_code	=> OE_GLOBALS.G_ENTITY_LINE
               , p_entity_id      	=> p_line_id
               , x_return_status   => l_return_status
               );
    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- BUG 2670775 Reverse Limits Begin
    OE_DELAYED_REQUESTS_UTIL.REVERSE_LIMITS
              ( x_return_status           => l_return_status
              , p_action_code             => 'CANCEL'
              , p_cons_price_request_code => p_price_request_code
              , p_orig_ordered_qty        => p_ordered_quantity
              , p_amended_qty             => NULL
              , p_ret_price_request_code  => NULL
              , p_returned_qty            => NULL
              , p_line_id                 => p_line_id
              );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- BUG 2670775 Reverse Limits End

    -- Scheduling restructure.
    IF p_schedule_status_code IS NOT NULL
    AND p_item_type_code <> OE_GLOBALS.G_ITEM_CONFIG THEN

      --4504362: Branch scheduling checs removed
       OE_SCHEDULE_UTIL.Delete_row(p_line_id => p_line_id);


    END IF;

    OE_Line_Adj_Util.delete_row(p_line_id => p_line_id);
    OE_Line_PAttr_Util.delete_row(p_line_id => p_line_id);
    OE_Line_Scredit_Util.delete_row(p_line_id => p_line_id);
    OE_Lot_Serial_Util.delete_row(p_line_id => p_line_id);
    -- Bug 3315531
    -- Do not call WF delete for lines in negotiation phase as
    -- line workflows are only started when order is in fulfillment phase.
    IF nvl(p_transaction_phase_code,'F') = 'F' THEN
       OE_Order_WF_Util.delete_row(p_type => 'LINE', p_id => p_line_id);
    END IF;
    OE_Holds_PUB.Delete_Holds(p_line_id => p_line_id );

    -- 1829201, commitment related changes.
    -- OE_Payments_Util.delete_row(p_line_id => p_line_id);

    begin
      select header_id
      into   l_header_id
      from   oe_order_lines_all
      where  line_id = p_line_id;
    exception when no_data_found then
      null;
    end;

    OE_Line_Payment_Util.delete_row
                        (p_line_id => p_line_id
                        ,p_header_id => l_header_id
                        );

    oe_line_fullfill.cancel_line(p_line_id => p_line_id,
						  x_return_status => l_return_status);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then

	 if l_return_status = FND_API.G_RET_STS_ERROR then

	    raise FND_API.G_EXC_ERROR;
      else

	    raise FND_API.G_EXC_UNEXPECTED_ERROR;
	 end if;

    end if;

    OE_Set_Util.Remove_From_Fulfillment(p_line_id => p_line_id);

  /* Log and Execute the delayed request logged for update shipping
       as they will get deleted in the next step */
  if l_debug_level > 0 then
   oe_debug_pub.ADD('p_shipping_interfaced_flag '|| p_shipping_interfaced_flag,1);
  end if;

   IF	p_shipping_interfaced_flag = 'Y' THEN

    if l_debug_level > 0 then
     oe_debug_pub.ADD('Update Shipping,Delete '|| p_line_id,1);
    end if;

   /*
   The code for logging and processing the delayed request for update shipping
   was removed for bug 3754586 , instead we call update_shipping_from_oe
   This was done for the following reason :
   In case of multiple lines call to process order with some lines getting
   deleted and others getting updated, we see that WSHcheck scripts api is called
   even for DELETE case at the time of delayes request execution whereas we want
   the call to be made at actually databse delete in delete_row api.
   */
   -- Preparing the table for calling Update_Shipping_From_OE for the deleted line

     l_delete_lines_tbl(1).entity_code            := OE_GLOBALS.G_ENTITY_LINE;
     l_delete_lines_tbl(1).entity_id              := p_line_id;
     l_delete_lines_tbl(1).param1                 := FND_API.G_TRUE;
     l_delete_lines_tbl(1).param2                 := FND_API.G_FALSE;
     l_delete_lines_tbl(1).request_unique_key1    := OE_GLOBALS.G_OPR_DELETE;

     OE_Shipping_Integration_PVT.Update_Shipping_From_OE
        (p_update_lines_tbl      =>      l_delete_lines_tbl,
         x_return_status         =>      l_return_status
        );

   END IF;-- shipping interfaced = 'Y'
   -- changes for bug 3754586 ends

     if l_debug_level > 0 then
      oe_debug_pub.add('ret sts: '|| l_return_status, 4);
     end if;

      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

    OE_Delayed_Requests_Pvt.Delete_Reqs_for_deleted_entity(
        p_entity_code  => OE_GLOBALS.G_ENTITY_LINE,
        p_delete_against => FALSE, -- bug 5114189
        p_entity_id     => p_line_id,
        x_return_status => l_return_status
        );



EXCEPTION
    WHEN NO_DATA_FOUND THEN
				NULL;
    WHEN FND_API.G_EXC_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    WHEN OTHERS THEN
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Delete_Dependents'
            );
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Delete_Dependents;


Procedure Calc_Catchweight_Return_qty2
( p_x_line_rec IN OUT NOCOPY OE_Order_PUB.Line_Rec_Type
,  p_old_line_rec                  IN  OE_Order_PUB.Line_Rec_Type) IS
x_item_rec  OE_ORDER_CACHE.item_rec_type;
l_debug_level  CONSTANT NUMBER := oe_debug_pub.g_debug_level;

BEGIN
   If l_debug_level > 0 Then
      oe_debug_pub.add('Entering into Calc_Catchweight_Return_qty2',1);
      oe_debug_pub.add('p_x_line_rec.line_category_code : '||p_x_line_rec.line_category_code||' p_x_line_rec.reference_line_id : '||p_x_line_rec.reference_line_id,3);
      oe_debug_pub.add('p_x_line_rec.inventory_item_id : '||p_x_line_rec.inventory_item_id||' p_x_line_rec.ship_from_org_id : '||p_x_line_rec.ship_from_org_id,3);
   End If;

   IF p_x_line_rec.line_category_code = 'RETURN' AND
        p_x_line_rec.reference_line_id IS NOT NULL THEN  -- referenced return
     IF (p_x_line_rec.inventory_item_id IS NOT NULL AND
            p_x_line_rec.inventory_item_id <> FND_API.G_MISS_NUM) AND
           (p_x_line_rec.ship_from_org_id  IS NOT NULL AND
            p_x_line_rec.ship_from_org_id <> FND_API.G_MISS_NUM) THEN
            x_item_rec := OE_Order_Cache.Load_Item (p_x_line_rec.inventory_item_id
                            ,p_x_line_rec.ship_from_org_id);
            --IF  x_item_rec.ont_pricing_qty_source = 1  AND -- INVCONV
            IF x_item_rec.ont_pricing_qty_source = 'S' AND -- INVCONV
                   x_item_rec.tracking_quantity_ind = 'P'  THEN -- AND -- INVCONV -
                  --x_item_rec.wms_enabled_flag = 'Y' THEN -- INVCONV - TAKE OUT AS OPENED UP TO ANY ORG
                  IF l_debug_level  > 0 THEN
                        oe_debug_pub.add(  'Discrete catchweight enabled. Prorating ordered_quantity2. p_old_line_rec.ordered_quantity2:'|| p_old_line_rec.ordered_quantity2||
          ': p_old_line_rec.ordered_quantity:'|| p_old_line_rec.ordered_quantity||': p_x_line_rec.ordered_quantity:'|| p_x_line_rec.ordered_quantity);
                         oe_debug_pub.add('p_x_line_rec.ordered_quantity2 : '||p_x_line_rec.ordered_quantity2,3);
                  END IF;
                  If p_old_line_rec.ordered_quantity2 Is NOT NULL AND
                     p_old_line_rec.ordered_quantity2 <> FND_API.G_MISS_NUM AND
                     p_old_line_rec.ordered_quantity Is NOT NULL AND
                     p_old_line_rec.ordered_quantity <> FND_API.G_MISS_NUM Then
                        p_x_line_rec.ordered_quantity2 := (p_old_line_rec.ordered_quantity2 / p_old_line_rec.ordered_quantity) * p_x_line_rec.ordered_quantity;
                  END IF;
                 -- Populate pricing quantity
                  IF p_x_line_rec.ordered_quantity2 <> FND_API.G_MISS_NUM And
                       p_x_line_rec.ordered_quantity2 IS NOT NULL and
                       p_x_line_rec.pricing_quantity_uom is not null and
                       p_x_line_rec.pricing_quantity_uom <> FND_API.G_MISS_CHAR
and
                       p_x_line_rec.ordered_quantity_uom2 is not null  and
                       p_x_line_rec.ordered_quantity_uom2 <> FND_API.G_MISS_CHAR Then
                       IF p_x_line_rec.pricing_quantity_uom = p_x_line_rec.ordered_quantity_uom2 THEN
                            IF l_debug_level  > 0 THEN
                                  oe_debug_pub.add('pricing uom is same as ordered quantity2 uom');
                            END IF;
                            p_x_line_rec.Pricing_quantity := p_x_line_rec.ordered_quantity2;
                       ELSE
                             p_x_line_rec.Pricing_quantity :=
                                        OE_Order_Misc_Util.convert_uom(
                                                p_x_line_rec.inventory_item_id,
                                                p_x_line_rec.order_quantity_uom,                                                p_x_line_rec.pricing_quantity_uom,
                                                p_x_line_rec.ordered_quantity
                                                );
                              IF l_debug_level  > 0 THEN
                                  oe_debug_pub.add('pricing uom is different than ordered quantity2 uom. p_x_line_rec.Pricing_quantity:'|| p_x_line_rec.Pricing_quantity);
                            END IF;
                         END IF; -- Pricing Quantity
                   END IF; -- Check for existence of qty2, uom2 and pricing uom
            END IF; -- end check for discrete catchweight
      END IF; -- end check for item, warehouse existence
   END IF; -- end check for referenced return
END Calc_Catchweight_Return_qty2;




/*----------------------------------------------------------
Procedure Apply_Attribute_Changes
-----------------------------------------------------------*/

PROCEDURE Apply_Attribute_Changes
(   p_x_line_rec                    IN OUT NOCOPY OE_Order_PUB.Line_Rec_Type
,   p_old_line_rec                  IN  OE_Order_PUB.Line_Rec_Type :=
                                        OE_Order_PUB.G_MISS_LINE_REC
)
IS
l_temp_pricing_quantity  NUMBER:=0;
L_RETURN_STATUS   		VARCHAR2(1);
L_IS_MODEL        		VARCHAR2(1);
-- The following variables have been declared for Shipping Integration
l_update_shipping			VARCHAR2(1) := FND_API.G_FALSE;
l_explosion_date_changed	VARCHAR2(1) := FND_API.G_FALSE;
l_ordered_quantity_changed	VARCHAR2(1) := FND_API.G_FALSE;
l_shipping_unique_key1		VARCHAR2(30);
l_shipping_param1			VARCHAR2(240);
l_x_line_Tbl                    OE_Order_PUB.Line_Tbl_Type;
l_temp_shipped_quantity		NUMBER;
l_validated_quantity		NUMBER;
l_primary_quantity			NUMBER;
l_qty_return_status			VARCHAR2(1);
--  End of Shipping Integration Variables
l_verify_payment_flag VARCHAR2(30) := 'N';
idx                   NUMBER; --ER 12363706
i					pls_integer;
l_Price_Control_Rec		QP_PREQ_GRP.control_record_type;
l_freeze_method   		VARCHAR2(30);
l_count           		NUMBER := 0;
l_copy_adjustments			boolean := FALSE;
l_copy_pricing_attributes	boolean := FALSE;
l_no_copy_adjustments		boolean := FALSE;
l_no_price_flag			boolean 	:= FALSE;
l_from_line_id				number;
l_from_Header_id			number;
l_return_code           		NUMBER;
l_error_buffer          		VARCHAR2(240);
l_x_result_out          		VARCHAR2(30);
l_turn_off_pricing      		VARCHAR2(30);
--OPM 06/SEP/00
l_item_rec                    OE_ORDER_CACHE.item_rec_type; -- INVCONV
-- l_OPM_shipped_quantity        NUMBER(19,9);  -- INVCONV
-- l_OPM_shipping_quantity_uom   VARCHAR2(4);   -- INVCONV
-- l_OPM_order_quantity_uom      VARCHAR2(4);   -- INVCONV
l_status                      VARCHAR2(1);
l_msg_count                   NUMBER;
l_msg_data                    VARCHAR2(2000);
--OPM 06/SEP/00 END
--OPM BUG 1491504 BEGIN
l_ordered_quantity            NUMBER := p_x_line_rec.ordered_quantity;
l_ordered_quantity2           NUMBER := p_x_line_rec.ordered_quantity2;
l_old_line_tbl	               OE_Order_PUB.Line_Tbl_Type;
l_line_tbl	               OE_Order_PUB.Line_Tbl_Type;
l_control_rec	               OE_GLOBALS.Control_Rec_Type;
--OPM BUG 1491504 END
/* csheu -- bug #1533658 start*/
l_copy_service_fields         boolean := FALSE;
/* csheu -- bug #1533658 end*/
l_zero_line_qty               boolean := FALSE;
/* lchen -- bug #1761154 start*/
l_serviceable_item   VARCHAR2(1);
l_serviced_model       VARCHAR2(1);
/* lchen -- bug #1761154 end*/
-- commitment bug 1829201
l_calculate_commitment_flag 	VARCHAR2(1) := 'N';
l_get_commitment_bal	 	VARCHAR2(1) := 'N';
l_update_commitment_flag 	VARCHAR2(1) := 'N';
l_update_commitment_applied 	VARCHAR2(1) := 'N';
l_class 			VARCHAR2(30);
l_so_source_code 		VARCHAR2(30);
l_oe_installed_flag 		VARCHAR2(30);
l_commitment_applied_amount	NUMBER := 0;
l_param1			VARCHAR2(30) := NULL;
l_item_chg_prof                 VARCHAR2(1);
--bug 1786835
l_charges_for_backorders     VARCHAR2(1):= G_CHARGES_FOR_BACKORDERS; /* Bug # 5036404 */
l_charges_for_included_item  VARCHAR2(1):= G_CHARGES_FOR_INCLUD_ITM; /* Bug # 5036404 */
-- bug 1406890
l_current_event number := 0;
l_tax_calculation_event_code number := 0; --renga's change
l_tax_calc_rec  OE_ORDER_CACHE.Tax_Calc_Rec_Type;
l_tax_calculation_flag varchar2(1) := NULL;  --end renga's change
l_tax_commt_flag varchar2(1) := 'N';   --bug 2505961
--B2037234  	EMC
--B2204216      EMC Assignment of IC$EPSILON profile value moved outside
--              declaration to OPM branch of code.
l_epsilon                       NUMBER;
n                       	NUMBER;
l_pricing_event                 VARCHAR2(30);
--RT{
l_retrobill_operation VARCHAR2(10);
--RT}
-- by default, pricing will be called for Freight Rating
-- after calling FTE.
l_get_FTE_freight_rate          VARCHAR2(1) := 'N';
l_3a7_attribute_change          VARCHAR2(1) := FND_API.G_FALSE;
l_wms_org_flag_new VARCHAR2(1) := 'X';
l_wms_org_flag_old  VARCHAR2(1) := 'X';
l_fte_count   NUMBER := 0;
l_call_pricing varchar2(1) := 'N';

--Customer Acceptance
l_def_contingency_attributes VARCHAR2(1) := FND_API.G_FALSE;
--CC Encryption
l_delete_payment_count NUMBER;
--
-- bug 4378531
l_hold_result                   VARCHAR2(30);
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
--Bug#5026401
l_orig_line_calc_price_flag     VARCHAR2(1);
l_ship_inv_count NUMBER :=0;

l_po_NeedByDate_Update   VARCHAR2(10); -- Adeed for IR ISO CMS project
--
l_credit_check_rule_rec OE_CREDIT_CHECK_UTIL.OE_credit_rules_rec_type; --ER 12363706

-- ER#3667551 start
l_new_tbl_entry varchar2(10) := '';
l_bill_to_cust_id NUMBER := 0;
l_credithold_cust VARCHAR2(10) := NVL(OE_SYS_PARAMETERS.value('ONT_CREDITHOLD_TYPE'),'S') ;
-- ER#3667551 end
-- 14078867 start
l_old_itemcat NUMBER:= 0;
l_new_itemcat NUMBER:= 0;
-- 14078867 end

BEGIN

  if l_debug_level > 0 then
    oe_debug_pub.add('Entering OE_LINE_UTIL.APPLY_ATTRIBUTE_CHANGES', 1);
  end if;

    -- Query Header Record
    -- Performance Improvement Bug 1929163
    -- Use cached header rec instead of querying header rec into
    -- a local variable
    OE_Order_Cache.Load_Order_Header(p_x_line_rec.header_id);

    l_tax_calc_rec := oe_order_cache.get_tax_calculation_flag
                                 (p_x_line_rec.line_type_id,
                                  p_x_line_rec);

    l_tax_calculation_flag := l_tax_calc_rec.tax_calculation_flag;


    IF NOT OE_GLOBALS.Equal(p_x_line_rec.accounting_rule_id,p_old_line_rec.accounting_rule_id)
    THEN
      --Customer Acceptance
       l_def_contingency_attributes := FND_API.G_TRUE;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_line_rec.agreement_id,p_old_line_rec.agreement_id)
    THEN
         OE_GLOBALS.G_PRICE_FLAG := 'Y';

         -- bug 1829201, need to recalculate commitment.
         IF p_x_line_rec.commitment_id is not null then
           l_calculate_commitment_flag := 'Y';
         END IF;
    END IF;

    --bug3280378
    --changes in the customer job field should be reflected in the
    --shipping tables also
    IF NOT
OE_GLOBALS.Equal(p_x_line_rec.customer_job,p_old_line_rec.customer_job) THEN

       l_update_shipping := FND_API.G_TRUE;

    END IF;
    --bug3280378

    IF NOT OE_GLOBALS.Equal(p_x_line_rec.arrival_set_id,p_old_line_rec.arrival_set_id)
    THEN
		-- Need to Call Shipping Update
    		l_update_shipping	:= FND_API.G_TRUE;

    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_line_rec.arrival_set,p_old_line_rec.arrival_set) THEN

	NULL;

    END IF;

    -- CMS Date Changes

    IF NOT OE_GLOBALS.Equal(p_x_line_rec.schedule_arrival_date,p_old_line_rec.schedule_arrival_date)
    THEN
           -- Need to Call Shipping Update
           l_update_shipping       := FND_API.G_TRUE;

    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_line_rec.promise_date,p_old_line_rec.promise_date)
    THEN
           -- Need to Call Shipping Update
           l_update_shipping       := FND_API.G_TRUE;

    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_line_rec.earliest_acceptable_date,p_old_line_rec.earliest_acceptable_date)
    THEN
           -- Need to Call Shipping Update
           l_update_shipping       := FND_API.G_TRUE;

    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_line_rec.latest_acceptable_date,p_old_line_rec.latest_acceptable_date)
    THEN
           -- Need to Call Shipping Update
           l_update_shipping       := FND_API.G_TRUE;

    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_line_rec.earliest_ship_date,p_old_line_rec.earliest_ship_date)
    THEN
           -- Need to Call Shipping Update
           l_update_shipping       := FND_API.G_TRUE;

    END IF;


    IF NOT OE_GLOBALS.Equal(p_x_line_rec.ato_line_id,p_old_line_rec.ato_line_id)
    THEN

		-- Need to Call Shipping Update
    		l_update_shipping	:= FND_API.G_TRUE;

    END IF;

    -- Bug 10264299
    IF NOT OE_GLOBALS.Equal(p_x_line_rec.line_number,p_old_line_rec.line_number)
       OR NOT OE_GLOBALS.Equal(p_x_line_rec.shipment_number,p_old_line_rec.shipment_number)
    THEN
       --Need to Call Shipping Update
       l_update_shipping   := FND_API.G_TRUE;
     END IF;


    IF NOT OE_GLOBALS.Equal(p_x_line_rec.cancelled_quantity,p_old_line_rec.cancelled_quantity)
    THEN

	-- Call Pricing
        OE_GLOBALS.G_PRICE_FLAG := 'Y';

        -- bug 1829201, need to recalculate commitment.
        IF p_x_line_rec.commitment_id is not null then
          l_calculate_commitment_flag := 'Y';
        END IF;

	/* Additional task:
	Log delayed request for Verify Payment if the payment type
	is not CREDIT CARD and the Order line is Booked */

        IF p_x_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE THEN
	    IF NVL(OE_Order_Cache.g_header_rec.payment_type_code,'NULL') <> 'CREDIT_CARD'
		AND p_x_line_rec.booked_flag ='Y'
	    THEN
		-- Log Delayed Request for Verify Payment
               if l_debug_level > 0 then
		oe_debug_pub.ADD('log verify payment delayed request for change in Canceled Qty');
               end if;
		l_verify_payment_flag := 'Y';
	     END IF;
	 END IF;

    --Should not include any code here for cancellation specific
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_line_rec.customer_dock_code,p_old_line_rec.customer_dock_code)
    THEN

		-- Need to Call Shipping Update
    		l_update_shipping	:= FND_API.G_TRUE;

    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_line_rec.cust_production_seq_num,p_old_line_rec.cust_production_seq_num)
    THEN
	-- Need to Call Shipping Update
    	l_update_shipping	:= FND_API.G_TRUE;
    END IF;

IF NOT OE_GLOBALS.Equal(p_x_line_rec.cust_po_number,p_old_line_rec.cust_po_number)
    THEN
	 /*Changes for ER 6072870 begin*/

      IF (Nvl(p_x_line_rec.shipped_quantity,0)>0 AND          --suneela
      p_x_line_rec.LINE_CATEGORY_CODE='ORDER')
      THEN
        l_ship_inv_count:= -1;
        if l_debug_level > 0 THEN
               oe_debug_pub.add('Need not query shipping tables hence setting the counter to -1');
               oe_debug_pub.add('Line is already shipped,will not update shipping', 1);
               end if;
         FND_MESSAGE.SET_NAME('ONT', 'OE_PO_SHIPPED');
         OE_MSG_PUB.ADD;

     ELSIF p_x_line_rec.LINE_CATEGORY_CODE='ORDER' THEN

      BEGIN
       IF Nvl(p_x_line_rec.shipping_interfaced_flag,'N')='Y' THEN

          SELECT Count(1)
          INTO l_ship_inv_count
          FROM wsh_delivery_details wdd
          WHERE  wdd.source_code='OE'
                 AND wdd.source_line_id=p_x_line_rec.line_id
                 AND (wdd.released_status IN ('C','I')
                 OR oe_interfaced_flag='Y');

       ELSE
          l_ship_inv_count:=0;
       END IF;

      EXCEPTION
      WHEN No_Data_Found THEN
        l_ship_inv_count:=0;
        if l_debug_level > 0 then
         oe_debug_pub.add('the line is neither picked, shipped or interfaced. can call update shipping', 1);
        end if;
      END ;
     END IF;

	 -- Need to Call Shipping Update
     IF l_ship_inv_count>0

      THEN
               if l_debug_level > 0 then
               oe_debug_pub.add('Line is already shipped,will not update shipping', 1);
               end if;
         FND_MESSAGE.SET_NAME('ONT', 'OE_PO_SHIPPED');
         OE_MSG_PUB.ADD;

     ELSIF l_ship_inv_count=0 THEN

    	 l_update_shipping	:= FND_API.G_TRUE;

     END IF ;

    /*Changes for ER 6072870 end */
	 -- Call Pricing
         OE_GLOBALS.G_PRICE_FLAG := 'Y';

        IF p_x_line_rec.commitment_id IS NOT NULL THEN
          l_get_commitment_bal := 'Y';
        END IF;
END IF;

    IF NOT OE_GLOBALS.Equal(p_x_line_rec.deliver_to_contact_id,p_old_line_rec.deliver_to_contact_id)
    THEN
	 -- Need to Call Shipping Update
    	 l_update_shipping	:= FND_API.G_TRUE;
	 -- Call Pricing
         -- OE_GLOBALS.G_PRICE_FLAG := 'Y';  Commented out for fix 1419204
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_line_rec.deliver_to_org_id,p_old_line_rec.deliver_to_org_id)
    THEN
	 -- Need to Call Shipping Update
    	 l_update_shipping	:= FND_API.G_TRUE;
	 -- Call Pricing
      -- OE_GLOBALS.G_PRICE_FLAG := 'Y'; Commented out for fix 1419204


    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_line_rec.explosion_date,p_old_line_rec.explosion_date)
    THEN
	IF OE_GLOBALS.EQUAL(p_x_line_rec.ship_model_complete_flag,'Y') THEN
    		l_explosion_date_changed	:= FND_API.G_TRUE;
	END IF;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_line_rec.fob_point_code,p_old_line_rec.fob_point_code)
    THEN
		-- Need to Call Shipping Update
    		l_update_shipping	:= FND_API.G_TRUE;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_line_rec.freight_terms_code,p_old_line_rec.freight_terms_code)
    THEN
		-- Need to Call Shipping Update
    		l_update_shipping	:= FND_API.G_TRUE;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_line_rec.calculate_price_flag,p_old_line_rec.calculate_price_flag)
    THEN

	   If p_x_line_rec.calculate_price_flag = 'Y' then
	   	Begin

			OE_Order_Cache.Enforce_List_price(p_line_type_id => p_x_line_rec.Line_Type_id
										, p_header_id => p_x_line_rec.header_id);

	     	exception when no_data_found then
				OE_Order_Cache.g_Enforce_list_price_rec.enforce_line_prices_flag := 'N';
	   	end ;

        	If  OE_Order_Cache.g_Enforce_list_price_rec.enforce_line_prices_flag = 'Y'  Then
			p_x_line_rec.calculate_price_flag := 'P';
	   	End If;

		IF p_x_line_rec.open_flag = 'N' or
			p_x_line_rec.cancelled_flag = 'Y'
		THEN

			 p_x_line_rec.calculate_price_flag := 'N';

		End If;

	   End If; -- For price_flag='Y'

      -- bug 3585862
      if l_debug_level > 0 then
         oe_debug_pub.add('old calculate price flag'||p_old_line_rec.calculate_price_flag, 3);
         oe_debug_pub.add('new calculate price flag'||p_x_line_rec.calculate_price_flag, 3);
      end if;
      IF Nvl(oe_globals.g_pricing_recursion,'N') = 'N'
        AND p_x_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE
        AND ((p_old_line_rec.calculate_price_flag in ('N','P') and p_x_line_rec.calculate_price_flag = 'Y')
             OR (p_old_line_rec.calculate_price_flag = 'N' and p_x_line_rec.calculate_price_flag = 'P'))
      THEN
        if l_debug_level > 0 then
          oe_debug_pub.add('setting price flag because of calculate price flag change', 3);
        end if;
        IF nvl(OE_GLOBALS.G_PRICE_FLAG, 'N') <> 'Y' THEN
  	  OE_GLOBALS.G_PRICE_FLAG := 'Y';
          OE_LINE_ADJ_UTIL.Register_Changed_Lines
          (p_line_id         => p_x_line_rec.line_id,
           p_header_id       => p_x_line_rec.header_id,
           p_operation       => p_x_line_rec.operation );
        END IF;
      END IF;
      -- end bug 3585862
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_line_rec.intermed_ship_to_org_id,p_old_line_rec.intermed_ship_to_org_id)
    THEN
		-- Need to Call Shipping Update
    		l_update_shipping	:= FND_API.G_TRUE;
        /* may need to call pricing */
        /*
          OE_GLOBALS.G_PRICE_FLAG := 'Y';
        */

    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_line_rec.intermed_ship_to_contact_id,p_old_line_rec.intermed_ship_to_contact_id)
    THEN
		-- Need to Call Shipping Update
    		l_update_shipping	:= FND_API.G_TRUE;
        /* may need to call pricing */
        /*
          OE_GLOBALS.G_PRICE_FLAG := 'Y';
        */
    END IF;


    IF NOT OE_GLOBALS.Equal(p_x_line_rec.inventory_item_id,p_old_line_rec.inventory_item_id)
    THEN

      -- QUOTING changes - log explosion request only for lines in
      -- fulfillment phase
      IF nvl(p_x_line_rec.transaction_phase_code,'F') = 'F' THEN

    -- log a delayed request to get included items for this item if any.

      l_freeze_method := G_FREEZE_METHOD; /* Bug # 5036404 */
     if l_debug_level > 0 then
      oe_debug_pub.ADD('Freeze method is :' || l_freeze_method,2);
     end if;
      --3286378 : Added check for operation= create
      IF (l_freeze_method = OE_GLOBALS.G_IIFM_ENTRY AND
         (p_x_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE OR
          (p_x_line_rec.operation = OE_GLOBALS.G_OPR_CREATE AND
           p_x_line_rec.split_from_line_id IS NULL)) AND
         p_x_line_rec.ato_line_id is NULL AND
         ( p_x_line_rec.item_type_code = OE_GLOBALS.G_ITEM_MODEL OR
           (p_x_line_rec.item_type_code = OE_GLOBALS.G_ITEM_KIT AND
            p_x_line_rec.line_id = p_x_line_rec.top_model_line_id))
/* Start DOO Pre Exploded Kit ER 9339742 */
           AND NOT(OE_GENESIS_UTIL.G_INCOMING_FROM_DOO OR OE_GENESIS_UTIL.G_INCOMING_FROM_SIEBEL))
          OR
           (((p_x_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE AND (OE_GENESIS_UTIL.G_INCOMING_FROM_DOO OR OE_GENESIS_UTIL.G_INCOMING_FROM_SIEBEL)) OR
            (p_x_line_rec.operation = OE_GLOBALS.G_OPR_CREATE AND
             p_x_line_rec.split_from_line_id IS NULL AND p_x_line_rec.pre_exploded_flag = 'Y'))
           AND p_x_line_rec.ato_line_id is NULL
           AND ( (( p_x_line_rec.item_type_code = OE_GLOBALS.G_ITEM_KIT OR p_x_line_rec.item_type_code = OE_GLOBALS.G_ITEM_MODEL)
               AND p_x_line_rec.line_id = p_x_line_rec.top_model_line_id)
             OR p_x_line_rec.item_type_code = OE_GLOBALS.G_ITEM_CLASS))
      THEN
           IF OE_GENESIS_UTIL.G_INCOMING_FROM_DOO OR OE_GENESIS_UTIL.G_INCOMING_FROM_SIEBEL THEN
             if l_debug_level > 0 then
               oe_debug_pub.ADD(' The update is from DOO/Siebel Pre Exploded Kit ER',5);
             end if;
           END IF;
/* End DOO Pre Exploded Kit ER 9339742 */
           if l_debug_level > 0 then
              oe_debug_pub.ADD('LINE ID : '||p_x_line_rec.line_id,2);
           end if;
           p_x_line_rec.explosion_date := null;
           l_count := l_count + 1;
           OE_Config_Pvt.OE_FREEZE_INC_ITEMS_TBL(l_count):= p_x_line_rec.line_id;
      END IF;

      END IF; -- End if phase is fulfillment
      -- END QUOTING changes

      --Customer Acceptance
       l_def_contingency_attributes := FND_API.G_TRUE;

      --  NULL;
      -- Need to Call Shipping Update
      l_update_shipping	:= FND_API.G_TRUE;

	 IF ( p_x_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE AND
	    NVL(p_x_line_rec.split_action_code,'X') <> 'SPLIT' )
            -- QUOTING change
            AND NVL(p_x_line_rec.transaction_phase_code,'F') = 'F'
         THEN
     if l_debug_level > 0 then
      oe_debug_pub.ADD('item update: logging request for eval_hold_source');
         oe_debug_pub.ADD('line ID: '|| to_char(p_x_line_rec.line_id)||
                   ' Entity ID: '|| to_char(p_x_line_rec.inventory_item_id));
     end if;

         OE_delayed_requests_Pvt.log_request
                 (p_entity_code => OE_GLOBALS.G_ENTITY_LINE,
                  p_entity_id         => p_x_line_rec.line_id,
                  p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
                  p_requesting_entity_id         => p_x_line_rec.line_id,
                  p_request_type      => OE_GLOBALS.G_EVAL_HOLD_SOURCE,
                  p_request_unique_key1 => 'ITEM',
                  p_param1		 => 'I',
                  p_param2		 => p_x_line_rec.inventory_item_id,
                  x_return_status     => l_return_status);
       if l_debug_level > 0 then
         oe_debug_pub.ADD('after call to log_request: l_return_status: '||
							   l_return_status , 1);
       end if;
	   -- 14078867 Start
	   -- Get Item Category IDs
	   l_old_itemcat := OE_ITORD_UTIL.get_item_category_id(p_old_line_rec.inventory_item_id);
	   l_new_itemcat := OE_ITORD_UTIL.get_item_category_id(p_x_line_rec.inventory_item_id);
	   if l_debug_level > 0 then
        oe_debug_pub.ADD(' Old ItemID: '||p_old_line_rec.inventory_item_id||
		                 ' -Old Category ID: '||l_old_itemcat||
						 ' -New ItemID: '||p_x_line_rec.inventory_item_id||
						 ' -New Category ID: '||l_new_itemcat);
        end if;
	   If (l_old_itemcat <> l_new_itemcat )
	   THEN
	    if l_debug_level > 0 then
        oe_debug_pub.ADD('item update, Item Category Different: logging request for eval_hold_source');
         oe_debug_pub.ADD('line ID: '|| to_char(p_x_line_rec.line_id)||
                   ' Entity ID: '|| l_new_itemcat);
        end if;

         OE_delayed_requests_Pvt.log_request
                 (p_entity_code => OE_GLOBALS.G_ENTITY_LINE,
                  p_entity_id         => p_x_line_rec.line_id,
                  p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
                  p_requesting_entity_id         => p_x_line_rec.line_id,
                  p_request_type      => OE_GLOBALS.G_EVAL_HOLD_SOURCE,
                  p_request_unique_key1 => 'ITEMCATEGORY',
                  p_param1		 => 'IC',
                  p_param2		 => l_new_itemcat,
                  x_return_status     => l_return_status);
       if l_debug_level > 0 then
         oe_debug_pub.ADD('after call to log_request: l_return_status: '||
							   l_return_status , 1);
       end if;
	   End IF;
	   -- 14078867 End

       END IF;
       -- Item ID has changed. Need to redo balance checking
       if p_x_line_rec.commitment_id is not null then
         null;
       end if;

       -- Redefault Globalization flexfield
       -- Performance Improvement Bug 1929163
       -- JG has provided a NOCOPY spec via bug 1950033
     if l_debug_level > 0 then
       oe_debug_pub.add('before calling jg');
     end if;

      ---Start bug 14317960 --Comparing so that User passed value are always honoured
     IF OE_GLOBALS.Equal(p_x_line_rec.global_attribute1,p_old_line_rec.global_attribute1) then
       if l_debug_level > 0 then
          oe_debug_pub.add('p_x_line_rec.global_attribute1'|| p_x_line_rec.global_attribute1);
       end if;
       p_x_line_rec.global_attribute1 := NULL;
     End IF ;

     IF OE_GLOBALS.Equal(p_x_line_rec.global_attribute2,p_old_line_rec.global_attribute2) then
       if l_debug_level > 0 then
          oe_debug_pub.add('p_x_line_rec.global_attribute2'|| p_x_line_rec.global_attribute2);
       end if;
       p_x_line_rec.global_attribute2 := NULL;
     End IF ;


     IF OE_GLOBALS.Equal(p_x_line_rec.global_attribute3,p_old_line_rec.global_attribute3) then
       if l_debug_level > 0 then
          oe_debug_pub.add('p_x_line_rec.global_attribute3'|| p_x_line_rec.global_attribute3);
       end if;
       p_x_line_rec.global_attribute3 := NULL;
     End IF ;

     IF OE_GLOBALS.Equal(p_x_line_rec.global_attribute4,p_old_line_rec.global_attribute4) then
       if l_debug_level > 0 then
          oe_debug_pub.add('p_x_line_rec.global_attribute4'|| p_x_line_rec.global_attribute4);
       end if;
       p_x_line_rec.global_attribute4 := NULL;
     End IF ;

     IF OE_GLOBALS.Equal(p_x_line_rec.global_attribute5,p_old_line_rec.global_attribute5) then
       if l_debug_level > 0 then
          oe_debug_pub.add('p_x_line_rec.global_attribute5'|| p_x_line_rec.global_attribute5);
       end if;
       p_x_line_rec.global_attribute5 := NULL;
     End IF ;

     IF OE_GLOBALS.Equal(p_x_line_rec.global_attribute6,p_old_line_rec.global_attribute6) then
       if l_debug_level > 0 then
          oe_debug_pub.add('p_x_line_rec.global_attribute6'|| p_x_line_rec.global_attribute6);
       end if;
       p_x_line_rec.global_attribute6 := NULL;
     End IF ;

     IF OE_GLOBALS.Equal(p_x_line_rec.global_attribute7,p_old_line_rec.global_attribute7) then
       if l_debug_level > 0 then
          oe_debug_pub.add('p_x_line_rec.global_attribute7'|| p_x_line_rec.global_attribute7);
       end if;
       p_x_line_rec.global_attribute7 := NULL;
     End IF ;

     IF OE_GLOBALS.Equal(p_x_line_rec.global_attribute8,p_old_line_rec.global_attribute8) then
       if l_debug_level > 0 then
          oe_debug_pub.add('p_x_line_rec.global_attribute8'|| p_x_line_rec.global_attribute8);
       end if;
       p_x_line_rec.global_attribute8 := NULL;
     End IF ;

     IF OE_GLOBALS.Equal(p_x_line_rec.global_attribute9,p_old_line_rec.global_attribute9) then
       if l_debug_level > 0 then
          oe_debug_pub.add('p_x_line_rec.global_attribute9'|| p_x_line_rec.global_attribute9);
       end if;
       p_x_line_rec.global_attribute9 := NULL;
     End IF ;

     IF OE_GLOBALS.Equal(p_x_line_rec.global_attribute10,p_old_line_rec.global_attribute10) then
       if l_debug_level > 0 then
         oe_debug_pub.add('p_x_line_rec.global_attribute10'|| p_x_line_rec.global_attribute10);
       end if;
       p_x_line_rec.global_attribute10 := NULL;
     End IF ;

     IF OE_GLOBALS.Equal(p_x_line_rec.global_attribute11,p_old_line_rec.global_attribute11) then
       if l_debug_level > 0 then
         oe_debug_pub.add('p_x_line_rec.global_attribute11'|| p_x_line_rec.global_attribute11);
       end if;
       p_x_line_rec.global_attribute11 := NULL;
     End IF ;

     IF OE_GLOBALS.Equal(p_x_line_rec.global_attribute12,p_old_line_rec.global_attribute12) then
       if l_debug_level > 0 then
          oe_debug_pub.add('p_x_line_rec.global_attribute12'|| p_x_line_rec.global_attribute12);
       end if;
       p_x_line_rec.global_attribute12 := NULL;
     End IF ;

     IF OE_GLOBALS.Equal(p_x_line_rec.global_attribute13,p_old_line_rec.global_attribute13) then
       if l_debug_level > 0 then
         oe_debug_pub.add('p_x_line_rec.global_attribute13'|| p_x_line_rec.global_attribute13);
       end if;
       p_x_line_rec.global_attribute13 := NULL;
     End IF ;

     IF OE_GLOBALS.Equal(p_x_line_rec.global_attribute14,p_old_line_rec.global_attribute14) then
      if l_debug_level > 0 then
         oe_debug_pub.add('p_x_line_rec.global_attribute14'|| p_x_line_rec.global_attribute14);
       end if;
       p_x_line_rec.global_attribute14:= NULL;
     End IF ;

     IF OE_GLOBALS.Equal(p_x_line_rec.global_attribute15,p_old_line_rec.global_attribute15) then
      if l_debug_level > 0 then
         oe_debug_pub.add('p_x_line_rec.global_attribute15'|| p_x_line_rec.global_attribute15);
      end if;
      p_x_line_rec.global_attribute15 := NULL;
     End IF ;

     IF OE_GLOBALS.Equal(p_x_line_rec.global_attribute16,p_old_line_rec.global_attribute16) then
       if l_debug_level > 0 then
        oe_debug_pub.add('p_x_line_rec.global_attribute16'|| p_x_line_rec.global_attribute16);
       end if;
       p_x_line_rec.global_attribute16 := NULL;
     End IF ;

     IF OE_GLOBALS.Equal(p_x_line_rec.global_attribute17,p_old_line_rec.global_attribute17) then
       if l_debug_level > 0 then
        oe_debug_pub.add('p_x_line_rec.global_attribute17'|| p_x_line_rec.global_attribute17);
       end if;
       p_x_line_rec.global_attribute17 := NULL;
     End IF ;

     IF OE_GLOBALS.Equal(p_x_line_rec.global_attribute18,p_old_line_rec.global_attribute18) then
       if l_debug_level > 0 then
          oe_debug_pub.add('p_x_line_rec.global_attribute18'|| p_x_line_rec.global_attribute18);
       end if;
       p_x_line_rec.global_attribute18 := NULL;
     End IF ;

     IF OE_GLOBALS.Equal(p_x_line_rec.global_attribute19,p_old_line_rec.global_attribute19) then
       if l_debug_level > 0 then
         oe_debug_pub.add('p_x_line_rec.global_attribute19'|| p_x_line_rec.global_attribute19);
       end if;
       p_x_line_rec.global_attribute19 := NULL;
     End IF ;

     IF OE_GLOBALS.Equal(p_x_line_rec.global_attribute20,p_old_line_rec.global_attribute20) then
       if l_debug_level > 0 then
         oe_debug_pub.add('p_x_line_rec.global_attribute20'|| p_x_line_rec.global_attribute20);
       end if;
       p_x_line_rec.global_attribute20 := NULL;
     End IF ;

     IF OE_GLOBALS.Equal(p_x_line_rec.global_attribute_category,p_old_line_rec.global_attribute_category) then
      if l_debug_level > 0 then
         oe_debug_pub.add('global_attribute_category'|| p_x_line_rec.global_attribute_category);
       end if;
       p_x_line_rec.global_attribute_category := NULL;
     End IF ;


      ---End Bug 14317960
     /*     -- bug 12540628
       p_x_line_rec.global_attribute1 := NULL;
       p_x_line_rec.global_attribute2 := NULL;
       p_x_line_rec.global_attribute3 := NULL;
       p_x_line_rec.global_attribute4 := NULL;
       p_x_line_rec.global_attribute5 := NULL;
       p_x_line_rec.global_attribute6 := NULL;
       p_x_line_rec.global_attribute7 := NULL;
       p_x_line_rec.global_attribute8 := NULL;
       p_x_line_rec.global_attribute9 := NULL;
       p_x_line_rec.global_attribute10 := NULL;
       p_x_line_rec.global_attribute11 := NULL;
       p_x_line_rec.global_attribute12 := NULL;
       p_x_line_rec.global_attribute13 := NULL;
       p_x_line_rec.global_attribute14 := NULL;
       p_x_line_rec.global_attribute15 := NULL;
       p_x_line_rec.global_attribute16 := NULL;
       p_x_line_rec.global_attribute17 := NULL;
       p_x_line_rec.global_attribute18 := NULL;
       p_x_line_rec.global_attribute19 := NULL;
       p_x_line_rec.global_attribute20 := NULL;
       p_x_line_rec.global_attribute_category := NULL;*/  ---commencted for bug 14317960
JG_ZZ_OM_COMMON_PKG.default_gdf(
                                x_line_rec=>p_x_line_rec,
				x_return_code => l_return_code,
				x_error_buffer => l_error_buffer);
     if l_debug_level > 0 then
       oe_debug_pub.add('after calling jg');
     end if;
       --bug 2971066 Begin
       l_item_chg_prof := fnd_profile.value('ONT_HONOR_ITEM_CHANGE');
if l_debug_level > 0 then
 oe_debug_pub.add('value of ONT_HONOR_ITEM_CHANGE:'||l_item_chg_prof,5);
 oe_debug_pub.add('p_x_line_rec.inventory_item_id : '||p_x_line_rec.inventory_item_id);
 oe_debug_pub.add('p_old_line_rec.inventory_item_id : '||p_old_line_rec.inventory_item_id);
end if;
       IF p_x_line_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN
        /*if nvl(p_x_line_rec.inventory_item_id,FND_API.G_MISS_NUM)
          <> FND_API.G_MISS_NUM
        and nvl(p_old_line_rec.inventory_item_id,FND_API.G_MISS_NUM) <>
             FND_API.G_MISS_NUM*/
        IF (
              (nvl(p_x_line_rec.inventory_item_id,FND_API.G_MISS_NUM)
               <> FND_API.G_MISS_NUM
               and nvl(p_old_line_rec.inventory_item_id,FND_API.G_MISS_NUM)
               <> FND_API.G_MISS_NUM )
           -- Bug# 3942402
           -- For Case1:
            or
              (nvl(p_x_line_rec.inventory_item_id,FND_API.G_MISS_NUM)
               = FND_API.G_MISS_NUM
               and nvl(p_old_line_rec.inventory_item_id,FND_API.G_MISS_NUM)
               <> FND_API.G_MISS_NUM )
            )
           -- Bug# 3942402 end
        and p_x_line_rec.calculate_price_flag in ('N','P')
        and nvl(l_item_chg_prof,'N') = 'N' then
          if l_debug_level > 0 then
            oe_debug_pub.add('Changing calculate price flag to Y');
          end if;
            p_x_line_rec.calculate_price_flag := 'Y';
        end if;
       -- bug 2971066 end
       -- bug 1819133, need to recalculate price if item is updated
       ELSIF p_x_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE THEN
        --change made for bug 1998333      Begin
          if nvl(l_item_chg_prof,'N') = 'N' then
           --retaining the old behaviour
            p_x_line_rec.calculate_price_flag := 'Y';
          else
           --we do not change anything
            null;
          end if;
        --change made for bug 1998333      End
       END IF;

       OE_GLOBALS.G_PRICE_FLAG := 'Y';

       -- bug 1829201, need to recalculate commitment.
       IF p_x_line_rec.commitment_id is not null then
         l_calculate_commitment_flag := 'Y';
       END IF;

       IF OE_Freight_Rating_Util.IS_FREIGHT_RATING_AVAILABLE
          AND OE_Freight_Rating_Util.Get_List_Line_Type_Code
                                     (p_x_line_rec.header_id)
              = 'OM_CALLED_FREIGHT_RATES' THEN
          if l_debug_level > 0 then
            oe_debug_pub.add('Log Freight Rating request for item change. ',3);
          end if;
            l_get_FTE_freight_rate := 'Y';
       END IF;


/*sdatti*/
     if l_debug_level > 0 then
       oe_debug_pub.ADD('OE_GLOBALS.G_PRICING_RECURSION:'||oe_globals.g_pricing_recursion,1);
     end if;
       IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110509' THEN
        IF Nvl(oe_globals.g_pricing_recursion,'N') = 'N'  THEN
	  update_adjustment_flags(p_old_line_rec,p_x_line_rec);
        END IF;
       END IF;
/*sdatti*/

    END IF;


    IF NOT OE_GLOBALS.Equal(p_x_line_rec.invoice_to_org_id,p_old_line_rec.invoice_to_org_id)
    THEN
        /* may need to call pricing */

          OE_GLOBALS.G_PRICE_FLAG := 'Y';
		  -- 12876258 Start Enable Log delayed request for taxing
		  OE_GLOBALS.G_TAX_FLAG := 'Y';
		  if l_debug_level > 0 then
		  oe_debug_pub.add('TaxFlag set for invoice to org change');
		  end if; -- 12876258 End addition
	  --Customer Acceptance
	  l_def_contingency_attributes := FND_API.G_TRUE;

          IF p_x_line_rec.commitment_id IS NOT NULL THEN
            l_get_commitment_bal := 'Y';
          END IF;

	   IF ( p_x_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE AND
	      NVL(p_x_line_rec.split_action_code,'X') <> 'SPLIT')
               -- QUOTING change
              AND NVL(p_x_line_rec.transaction_phase_code,'F') = 'F'
           THEN
                if l_debug_level > 0 then
                  oe_debug_pub.ADD('invoice site update: logging request for eval_hold_source');
                  oe_debug_pub.ADD('line ID: '|| to_char(p_x_line_rec.line_id)||
		         ' Entity ID: '|| to_char(p_x_line_rec.invoice_to_org_id));
                end if;
                  OE_delayed_requests_Pvt.log_request(
                    p_entity_code => OE_GLOBALS.G_ENTITY_LINE,
                    p_entity_id         => p_x_line_rec.line_id,
			     p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
			     p_requesting_entity_id         => p_x_line_rec.line_id,
                    p_request_type      => OE_GLOBALS.G_EVAL_HOLD_SOURCE,
                    p_request_unique_key1 => 'BILL_TO',
                    p_param1		 => 'B',
                    p_param2		 => p_x_line_rec.invoice_to_org_id,
                    x_return_status     => l_return_status);
        END IF;

	IF p_x_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE THEN
		--R12 CC Encryption
		select count(payment_type_code) into
		l_delete_payment_count from oe_payments
		where header_id = p_x_line_rec.header_id
		and line_id = p_x_line_rec.line_id and
		payment_type_code in ('ACH','DIRECT_DEBIT','CREDIT_CARD');

		 --Delayed request for deleting the payments when
		 --invoice to changes
		 IF l_delete_payment_count > 0 THEN
			OE_delayed_requests_Pvt.log_request
			    (p_entity_code            	=> OE_GLOBALS.G_ENTITY_LINE_PAYMENT,
			     p_entity_id              	=> p_x_line_rec.line_id,
			     p_requesting_entity_code	=> OE_GLOBALS.G_ENTITY_LINE_PAYMENT,
			     p_requesting_entity_id  	=> p_x_line_rec.line_id,
			     p_request_type           	=> OE_GLOBALS.G_DELETE_PAYMENTS,
			     p_param1			=> p_x_line_rec.header_id,
			     p_param2			=> to_char(p_old_line_rec.invoice_to_org_id),
			     x_return_status         	=> l_return_status);
		  END IF;--Payment type code check
		  --R12 CC Encryption
		/* Additional Task : Log a delayed request for Verify payment
		(Credit Checking) when the bill to site changes for a booked line */
		IF NVL(OE_Order_Cache.g_header_rec.payment_type_code,'NULL') <>  'CREDIT_CARD'
		AND  p_x_line_rec.booked_flag ='Y'
		THEN
                      if l_debug_level > 0 then
			oe_debug_pub.ADD('log verify payment delayed request for change in invoice to site');
                      end if;
			l_verify_payment_flag := 'Y';
			OE_CREDIT_ENGINE_GRP.TOLERANCE_CHECK_REQUIRED := FALSE; --ER 12363706

		END IF;
	        --ER 12363706 start

	        idx                                                                := OE_CREDIT_CHECK_UTIL.G_CC_Invoice_tab.count;
	        OE_CREDIT_CHECK_UTIL.G_CC_Invoice_tab(idx+1).new_invoice_to_org_id := p_x_line_rec.invoice_to_org_id;
	        OE_CREDIT_CHECK_UTIL.G_CC_Invoice_tab(idx+1).old_invoice_to_org_id := p_old_line_rec.invoice_to_org_id;
	        OE_CREDIT_CHECK_UTIL.G_CC_Invoice_tab(idx+1).line_id               := p_x_line_rec.line_id;
	        --ER 12363706 end
	END IF;

    END IF;

   -- Changes for Blanket Orders

   IF NOT OE_GLOBALS.Equal(p_x_line_rec.blanket_number,p_old_line_rec.blanket_number)  OR
      NOT OE_GLOBALS.Equal(p_x_line_rec.blanket_line_number,p_old_line_rec.blanket_line_number)
    THEN
        --for ER 2901219
        --To trigger Pricing event if Blanket Number or Line Number is Changed
        OE_GLOBALS.G_PRICE_FLAG := 'Y';

        IF ( p_x_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE AND
	     NVL(p_x_line_rec.split_action_code,'X') <> 'SPLIT')
             -- QUOTING change
             AND NVL(p_x_line_rec.transaction_phase_code,'F') = 'F'
        THEN
                  OE_delayed_requests_Pvt.log_request(
                    p_entity_code            => OE_GLOBALS.G_ENTITY_LINE,
                    p_entity_id              => p_x_line_rec.line_id,
                    p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
                    p_requesting_entity_id   => p_x_line_rec.line_id,
                    p_request_type           => OE_GLOBALS.G_EVAL_HOLD_SOURCE,
                    p_param1                 => 'H',
                    p_param2                 => p_x_line_rec.blanket_number,
                    x_return_status          => l_return_status);
        END IF;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_line_rec.ordered_item_id,p_old_line_rec.ordered_item_id)
    THEN
        /*  need to reprice the line*/

        -- bug 1819133, need to recalculate price if item is updated
        IF p_x_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE THEN
      if l_debug_level > 0 then
        oe_debug_pub.add('before checking profile ONT_HONOR_ITEM_CHANGE',5);
      end if;
        --change made for bug 1998333      Begin
          l_item_chg_prof := fnd_profile.value('ONT_HONOR_ITEM_CHANGE');
if l_debug_level > 0 then
 oe_debug_pub.add('value of profile ONT_HONOR_ITEM_CHANGE:'||l_item_chg_prof,5);
end if;
          if nvl(l_item_chg_prof,'N') = 'N' then
           --retaining the old behaviour
            p_x_line_rec.calculate_price_flag := 'Y';
          else
           --we do not change anything
            null;
          end if;
        --change made for bug 1998333      End
        END IF;

        OE_GLOBALS.G_PRICE_FLAG := 'Y';

        -- bug 1829201, need to recalculate commitment.
        IF p_x_line_rec.commitment_id is not null then
          l_calculate_commitment_flag := 'Y';
        END IF;

    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_line_rec.item_identifier_type,p_old_line_rec.item_identifier_type)
    THEN
        /*  need to reprice the line*/
        -- OE_GLOBALS.G_PRICE_FLAG := 'Y'; Commented out for fix 1419204
           null;

    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_line_rec.ordered_item,p_old_line_rec.ordered_item)
    THEN
	    -- Call Pricing
       -- bug 1819133, need to recalculate price if item is updated
       IF p_x_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE THEN
      if l_debug_level > 0 then
        oe_debug_pub.add('before checking profile ONT_HONOR_ITEM_CHANGE',5);
      end if;
        --change made for bug 1998333      Begin
          l_item_chg_prof := fnd_profile.value('ONT_HONOR_ITEM_CHANGE');
if l_debug_level > 0 then
 oe_debug_pub.add('value of profile ONT_HONOR_ITEM_CHANGE:'||l_item_chg_prof,5);
end if;
          if nvl(l_item_chg_prof,'N') = 'N' then
           --retaining the old behaviour
            p_x_line_rec.calculate_price_flag := 'Y';
          else
           --we do not change anything
            null;
          end if;
        --change made for bug 1998333      End
       END IF;

       OE_GLOBALS.G_PRICE_FLAG := 'Y';

       OE_GLOBALS.G_TAX_FLAG := 'Y';

       -- bug 1829201, need to recalculate commitment.
       IF p_x_line_rec.commitment_id is not null then
         l_calculate_commitment_flag := 'Y';
       END IF;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_line_rec.item_revision,p_old_line_rec.item_revision)
    THEN
		-- Need to Call Shipping Update
    		l_update_shipping	:= FND_API.G_TRUE;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_line_rec.item_type_code,p_old_line_rec.item_type_code)
    THEN

      -- Need to Call Shipping Update
    	 l_update_shipping	:= FND_API.G_TRUE;

      -- QUOTING changes - log explosion request only for lines in
      -- fulfillment phase
      IF nvl(p_x_line_rec.transaction_phase_code,'F') = 'F' THEN

      -- log a delayed request to get included items for this item if any.

      l_freeze_method := G_FREEZE_METHOD; /* Bug # 5036404 */
    if l_debug_level > 0 then
      oe_debug_pub.ADD('Freeze method is :' || l_freeze_method,2);
    end if;

      IF p_x_line_rec.operation = OE_GLOBALS.G_OPR_CREATE AND
         p_x_line_rec.booked_flag = 'Y' AND
         l_freeze_method <> OE_GLOBALS.G_IIFM_PICK_RELEASE
      THEN
        l_freeze_method := OE_GLOBALS.G_IIFM_ENTRY;
      END IF;

      l_freeze_method := nvl(l_freeze_method, OE_GLOBALS.G_IIFM_ENTRY);

      IF l_freeze_method = OE_GLOBALS.G_IIFM_ENTRY AND
         p_x_line_rec.operation = OE_GLOBALS.G_OPR_CREATE AND
         p_x_line_rec.ato_line_id is NULL AND
         ( p_x_line_rec.item_type_code = OE_GLOBALS.G_ITEM_MODEL OR
           p_x_line_rec.item_type_code = OE_GLOBALS.G_ITEM_CLASS OR
           p_x_line_rec.item_type_code = OE_GLOBALS.G_ITEM_KIT )
      THEN
       if l_debug_level > 0 then
         oe_debug_pub.ADD('freeze inc items ' || l_freeze_method,2);
       end if;
           l_count := l_count + 1;
           OE_Config_Pvt.OE_FREEZE_INC_ITEMS_TBL(l_count)
                                          := p_x_line_rec.line_id;
      END IF;
      END IF; -- End if phase is fulfillment
      -- END QUOTING changes

      -- Need to log Freight Rating request for configured item.
      IF OE_Freight_Rating_Util.IS_FREIGHT_RATING_AVAILABLE
          AND OE_Freight_Rating_Util.Get_List_Line_Type_Code
               (p_x_line_rec.header_id) = 'OM_CALLED_FREIGHT_RATES'
          AND p_x_line_rec.operation = OE_GLOBALS.G_OPR_CREATE
          AND p_x_line_rec.item_type_code = OE_GLOBALS.G_ITEM_CONFIG THEN
           if l_debug_level > 0 then
            oe_debug_pub.add('Log Freight Rating request for CONFIG item. ',3);
           end if;
            l_get_FTE_freight_rate := 'Y';
      END IF;

      --Customer Acceptance
       l_def_contingency_attributes := FND_API.G_TRUE;

    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_line_rec.line_category_code,p_old_line_rec.line_category_code)
    THEN

	 -- Need to Call Shipping Update
    	 l_update_shipping	:= FND_API.G_TRUE;
	 -- Call Pricing
         OE_GLOBALS.G_PRICE_FLAG := 'Y';

         IF p_x_line_rec.commitment_id IS NOT NULL THEN
           l_get_commitment_bal := 'Y';
         END IF;

     -- For bugfix 3426865
        IF p_old_line_rec.line_category_code = 'RETURN' THEN
            p_x_line_rec.return_reason_code := NULL;
        END IF;

      --Customer Acceptance
       l_def_contingency_attributes := FND_API.G_TRUE;

    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_line_rec.line_type_id,p_old_line_rec.line_type_id)
    THEN

	-- Need to Call Shipping Update
    	l_update_shipping	:= FND_API.G_TRUE;
	-- Call Pricing
        OE_GLOBALS.G_PRICE_FLAG := 'Y';
        --Customer Acceptance
        l_def_contingency_attributes := FND_API.G_TRUE;


        IF p_x_line_rec.commitment_id IS NOT NULL THEN
          l_get_commitment_bal := 'Y';
        END IF;

    END IF;

       -- bug 2072014, need to recalculate price if uom is updated BEGIN
    IF NOT OE_GLOBALS.Equal(p_x_line_rec.order_quantity_uom,p_old_line_rec.order_quantity_uom)
    THEN

       -- Added below debug messages for bug 9014929
       oe_debug_pub.add(' ORDER_QUANTITY_UOM has changed : p_x_line_rec.operation = '||p_x_line_rec.operation);
       oe_debug_pub.add('p_x_line_rec.Pricing_quantity = '||p_x_line_rec.Pricing_quantity);
       oe_debug_pub.add('p_x_line_rec.ordered_quantity = '||p_x_line_rec.ordered_quantity);

/* Added the following if condition to fix the bug 2967630 */
       IF p_x_line_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN

        -- Added below code for bug 9014929
        OE_LINE_ADJ_UTIL.Change_adj_for_uom_change(p_x_line_rec);
        Oe_Debug_Pub.add('   p_x_line_rec.Pricing_quantity = ' || p_x_line_rec.Pricing_quantity);
        -- End of code changes for bug 9014929

        if (nvl(p_old_line_rec.order_quantity_uom,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR)
          and (nvl(p_x_line_rec.order_quantity_uom,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR)
          and p_x_line_rec.calculate_price_flag in ('P','N')
        then
            if l_debug_level > 0 then
                oe_debug_pub.add('operation is :'||p_x_line_rec.operation);
            end if;
            p_x_line_rec.calculate_price_flag := 'Y';
        end if;

       ELSIF p_x_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE THEN
       --bug 3942402
        IF NOT OE_GLOBALS.Equal(p_x_line_rec.inventory_item_id, p_old_line_rec.inventory_item_id) THEN
          IF (nvl(p_x_line_rec.inventory_item_id,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM
             and nvl(p_old_line_rec.inventory_item_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM)
             and p_x_line_rec.calculate_price_flag in ('N','P')
             and nvl(l_item_chg_prof,'N') = 'N' then
                if l_debug_level > 0 then
                  oe_debug_pub.add('Changing calculate price flag to Y');
                end if;
                p_x_line_rec.calculate_price_flag := 'Y';
          ELSE
             null;
          END IF;
        ELSE
		--For Bug#7648864
		--ER 9059812
		--LSP project OM Changes
		--Calcualte_price_flag will be set to 'Y' only for non LSP orders.
		--For LSP orders repricing will not happen during UOM change(LSP will always call
		-- process_order API with calcualte_price_flag ='N' )
            if l_debug_level > 0 then
              oe_debug_pub.add(' In ELSE: ');
            end if;
            IF (WSH_INTEGRATION.Validate_Oe_Attributes(p_x_line_rec.order_source_id) = 'Y' ) THEN
    			p_x_line_rec.calculate_price_flag := 'Y';
            END IF;

        end if;
        --bug 3942402
/* Added the following line to fix the bug 2917690 */
            OE_LINE_ADJ_UTIL.Change_adj_for_uom_change(p_x_line_rec);
       END IF;
       OE_GLOBALS.G_PRICE_FLAG := 'Y';
       l_3a7_attribute_change := FND_API.G_TRUE;

       -- Freight Rating.
       IF OE_Freight_Rating_Util.IS_FREIGHT_RATING_AVAILABLE
          AND OE_Freight_Rating_Util.Get_List_Line_Type_Code
                                    (p_x_line_rec.header_id)
             = 'OM_CALLED_FREIGHT_RATES' THEN
         if l_debug_level > 0 then
           oe_debug_pub.add('Log Freight Rating request for uom change. ',3);
         end if;
           l_get_FTE_freight_rate := 'Y';
       END IF;
    END IF;
       -- bug 2072014, need to recalculate price if uom is updated END

    IF NOT OE_GLOBALS.Equal(p_x_line_rec.ordered_quantity,p_old_line_rec.ordered_quantity)
    THEN

      if l_debug_level > 0 then
       oe_debug_pub.add('Ordered Qty has changed',1); -- PETER
       oe_debug_pub.add('New Ordered Qty : ' || p_x_line_rec.ordered_quantity, 1);
       oe_debug_pub.add('Old Ordered Qty : ' ||
                                p_old_line_rec.ordered_quantity, 1);
      end if;
       l_3a7_attribute_change := FND_API.G_TRUE;

          /* Added the following code to fix the bug 3739180 */
          If p_x_line_rec.calculate_price_flag in ('N','P') and p_x_line_rec.reference_line_id IS NOT NULL THEN
            IF (OE_GLOBALS.G_UI_FLAG) THEN
             if l_debug_level > 0 then
              oe_debug_pub.add('Log REVERSE_LIMITS delayed request for ENTITY LINE return',1);
             end if;
              OE_delayed_requests_Pvt.log_request(
                                p_entity_code            => OE_GLOBALS.G_ENTITY_LINE,
                                p_entity_id              => p_x_line_rec.line_id,
                                p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
                                p_requesting_entity_id   => p_x_line_rec.line_id,
                                p_request_unique_key1    => 'LINE',
                                p_param1                 => 'RETURN',
                                p_param2                 => NULL,
                                p_param3                 => NULL,
                                p_param4                 => NULL,
                                p_param5                 => NULL,
                                p_param6                 => p_x_line_rec.ordered_quantity,
                                p_request_type           => OE_GLOBALS.G_REVERSE_LIMITS,
                                x_return_status          => l_return_status);
            ELSIF NOT (OE_GLOBALS.G_UI_FLAG) THEN
             if l_debug_level > 0 then
              oe_debug_pub.add('Log REVERSE_LIMITS delayed request for ENTITY ALL line return',1);
             end if;
              OE_delayed_requests_Pvt.log_request(
                                p_entity_code            => OE_GLOBALS.G_ENTITY_ALL,
                                p_entity_id              => p_x_line_rec.line_id,
                                p_requesting_entity_code => OE_GLOBALS.G_ENTITY_ALL,
                                p_requesting_entity_id   => p_x_line_rec.line_id,
                                p_request_unique_key1    => 'LINE',
                                p_param1                 => 'RETURN',
                                p_param2                 => NULL,
                                p_param3                 => NULL,
                                p_param4                 => NULL,
                                p_param5                 => NULL,
                                p_param6                 => p_x_line_rec.ordered_quantity,
                                p_request_type           => OE_GLOBALS.G_REVERSE_LIMITS,
                                x_return_status          => l_return_status);
            END IF;
          END IF;
          /* End of the code added to fix the bug 3739180 */

       /* Fix for bug 2431953 / 2749740
       IF ((p_old_line_rec.ordered_quantity is not null) AND (nvl(p_x_line_rec.source_document_type_id,-99) <> 2) AND (p_x_line_rec.item_type_code = 'SERVICE'))

       THEN
          G_ORDERED_QTY_CHANGE := TRUE;
          OE_SERVICE_UTIL.Get_Service_Attribute
                          (x_return_status => l_return_status
                          , p_x_line_rec    => p_x_line_rec
                          );

          G_ORDERED_QTY_CHANGE := FALSE;

          IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            fnd_message.set_name('ONT', 'OE_CAN_SERV_AMT_NOT_ALLOWED');
            oe_msg_pub.add;
            RAISE FND_API.G_EXC_ERROR;
          END IF;
       END IF;
        Fix ends */

       IF (p_x_line_rec.order_source_id = 10) AND
		(p_old_line_rec.ordered_quantity IS NOT NULL) THEN


/* 7576948: IR ISO Change Management project Start */
--
-- This program unit will track the specific change in Ordered Quantity
-- and/or Schedule Ship Date on an internal sales order line shipment,
-- and in the event of any change in values, it will log a delayed request
-- of type OE_Globals.G_UPDATE_REQUISITION.
--
-- This delayed request will be logged only if global OE_Internal_Requisi
-- tion_Pvt.G_Update_ISO_From_Req set to FALSE. If this global is TRUE
-- then it means, the change requests for quantity/date or cancellation
-- request is initiated by internal requisition user, in which case, it is
-- not required to log the delayed request for updating the change to the
-- requesting organization. System will also check that global OE_SALES_CAN
-- _UTIL.G_IR_ISO_HDR_CANCEL, and will log a delayed request only if it is
-- FALSE. If this global is TRUE then signifies that it is a case of full
-- internal sales order header cancellation. Thus, in the event of full
-- order cancellation, we only need to inform Purchasing about the
-- cancellation. There is no need to provide specific line level information.
-- Additionally, while logging a delayed request specific to Schedule Ship
-- Date change, system will ensure that it should be allowed via Purchasing
-- profile 'POR: Sync Up Need By date on IR with OM'.
--
-- While logging the delayed request, we will log it for Order Header or
-- Order Line entity, while Entity id will be the Header_id or Line_id
-- respectively. In addition to this, we will even pass Unique_Params value
-- to make this request very specific to Requisition Header or Requisition
-- Line.
--
-- Please refer to following delayed request params with their meaning
-- useful while logging the delayed request -
--
-- P_entity_code        Entity for which delayed request has to be logged.
--                      In this project it can be OE_Globals.G_Entity_Line
--                      or OE_Globals.G_Entity_Header
-- P_entity_id          Primary key of the entity record. In this project,
--                      it can be Order Line_id or Header_id
-- P_requesting_entity_code Which entity has requested this delayed request to
--                          be logged! In this project it will be OE_Globals.
--                          G_Entity_Line or OE_Globals.G_Entity_Header
-- P_requesting_entity_id       Primary key of the requesting entity. In this
--                              project, it is Line_id or Header_id
-- P_request_type       Indicates which business logic (or which procedure)
--                      should be executed. In this project, it is OE_Global
--                      s.G_UPDATE_REQUISITION
-- P_request_unique_key1        Additional argument in form of parameters.
--                              In this project, it will denote the Sales Order
--                              Header id
-- P_request_unique_key2        Additional argument in form of parameters.
--                              In this project, it will denote the Requisition
--                              Header id
-- P_request_unique_key3        Additional argument in form of parameters. In
--                              this project, it will denote the Requistion Line
--                              id
-- P_param1     Additional argument in form of parameters. In this project, it
--              will denote net change in order quantity with respective single
--              requisition line. If it is greater than 0 then it is an increment
--              in the quantity, while if it is less than 0 then it is a decrement
--              in the ordered quantity. If it is 0 then it indicates there is no
--              change in ordered quantity value
-- P_param2     Additional argument in form of parameters. In this project, it
--              will denote whether internal sales order is cancelled or not. If
--              it is cancelled then respective Purchasing api will be called to
--              trigger the requisition header cancellation. It accepts a value of
--              Y indicating requisition header has to be cancelled.
-- P_param3     Additional argument in form of parameters. In this project, it
--              will denote the number of sales order lines cancelled while order
--              header is (Full/Partial) cancelled.
-- p_date_param1        Additional date argument in form of parameters. In this
--                      project, it will denote the change in Schedule Ship Date
--                      with to respect to single requisition line.
-- P_Long_param1        Additional argument in form of parameters. In this project,
--                      it will store all the sales order line_ids, which are getting
--                      cancelled while order header gets cancelled (Full/Partial).
--                      These Line_ids will be separated by a delimiter comma ','
--
-- For details on IR ISO CMS project, please refer to FOL >
-- OM Development > OM GM > 12.1.1 > TDD > IR_ISO_CMS_TDD.doc
--

    IF NOT ((nvl(p_x_line_rec.split_by,'X') IN ('USER','SYSTEM'))
              AND (NVL(p_x_line_rec.split_action_code,'X') = 'SPLIT')) THEN

      -- There is no need to update IR for System Split, as the net
      -- change in quantity during split operation is 0

      /* IR ISO Change Management : Comment this code Begins */
      /*
	    FND_MESSAGE.SET_NAME('ONT','OE_CHG_CORR_REQ');
            -- { start fix for 2648277
	    FND_MESSAGE.SET_TOKEN('CHG_ATTR',
               OE_Order_Util.Get_Attribute_Name('ordered_quantity'));
            -- end fix for 2648277}
	    OE_MSG_PUB.Add;

      */
      /* IR ISO Change Management : Comment this code Ends */

      IF NOT OE_Internal_Requisition_Pvt.G_Update_ISO_From_Req THEN
        IF NOT OE_SALES_CAN_UTIL.G_IR_ISO_HDR_CANCEL THEN
          IF l_debug_level > 0 THEN
            oe_debug_pub.add(' Header Level Cancellation is FALSE',5);
          END IF;

          -- Log a delayed request to update the Internal Requisition. This delayed
          -- request will be logged only if the change is not initiated from Requesting
          -- Organization user, and it is not a Internal Sales Order Full Cancellation

          OE_delayed_requests_Pvt.log_request
          ( p_entity_code            => OE_GLOBALS.G_ENTITY_LINE
          , p_entity_id              => p_x_line_rec.line_id
          , p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE
          , p_requesting_entity_id   => p_x_line_rec.line_id
          , p_request_unique_key1    => p_x_line_rec.header_id  -- Order Hdr_id
          , p_request_unique_key2    => p_x_line_rec.source_document_id -- Req Hdr_id
          , p_request_unique_key3    => p_x_line_rec.source_document_line_id -- Req Line_id
          , p_param1                 => (p_x_line_rec.ordered_quantity - p_old_line_rec.ordered_quantity)
--          , p_date_param1            => p_x_line_rec.schedule_ship_date
          , p_request_type           => OE_GLOBALS.G_UPDATE_REQUISITION
          , x_return_status          => l_return_status
          );

          IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
          END IF;

/*        ELSIF OE_SALES_CAN_UTIL.G_IR_ISO_HDR_CANCEL THEN  -- Commented for IR ISO Tracking bug 7667702
          IF l_debug_level > 0 THEN
            oe_debug_pub.add(' Header Level Cancellation is TRUE',5);
          END IF;

          -- Log a delayed request to update the Internal Requisition. This delayed
          -- request will be logged only if the change is not initiated from Requesting
          -- Organization user, and it is not a Internal Sales Order Full Cancellation

          OE_delayed_requests_Pvt.log_request
          ( p_entity_code            => OE_GLOBALS.G_ENTITY_HEADER
          , p_entity_id              => p_x_line_rec.header_id
          , p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE
          , p_requesting_entity_id   => p_x_line_rec.line_id
          , p_request_unique_key2    => p_x_line_rec.source_document_id -- Req Hdr_id
          , p_param3                 => 1
          , p_long_param1            => p_x_line_rec.line_id
          , p_request_type           => OE_GLOBALS.G_UPDATE_REQUISITION
          , x_return_status          => l_return_status
          );

          IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
          END IF;
*/ -- Commented for IR ISO Tracking bug 7667702

        END IF;
      END IF;
    END IF; -- Split_by

/* ============================= */
/* IR ISO Change Management Ends */


       END IF;

      -- QUOTING changes - log explosion request only for lines in
      -- fulfillment phase
      IF nvl(p_x_line_rec.transaction_phase_code,'F') = 'F' THEN

      -- log a delayed request to get included items for this item if any.

      l_freeze_method := G_FREEZE_METHOD; /* Bug # 5036404 */
     if l_debug_level > 0 then
      oe_debug_pub.ADD('Freeze method is :' || l_freeze_method,2);
     end if;
      IF ( l_freeze_method = OE_GLOBALS.G_IIFM_ENTRY AND
         p_x_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE AND
         p_x_line_rec.ato_line_id is NULL AND
         p_old_line_rec.ordered_quantity = 0 AND
         ( p_x_line_rec.item_type_code = OE_GLOBALS.G_ITEM_MODEL OR
           (p_x_line_rec.item_type_code = OE_GLOBALS.G_ITEM_KIT AND
            p_x_line_rec.line_id = p_x_line_rec.top_model_line_id))
/* Start DOO Pre Exploded Kit ER 9339742 */
       AND NOT(OE_GENESIS_UTIL.G_INCOMING_FROM_DOO OR OE_GENESIS_UTIL.G_INCOMING_FROM_SIEBEL))
          OR
           (((p_x_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE AND (OE_GENESIS_UTIL.G_INCOMING_FROM_DOO OR OE_GENESIS_UTIL.G_INCOMING_FROM_SIEBEL) ) OR
            (p_x_line_rec.operation = OE_GLOBALS.G_OPR_CREATE AND
             p_x_line_rec.split_from_line_id IS NULL AND p_x_line_rec.pre_exploded_flag = 'Y'))
           AND p_x_line_rec.ato_line_id is NULL
           AND ( (( p_x_line_rec.item_type_code = OE_GLOBALS.G_ITEM_KIT OR p_x_line_rec.item_type_code = OE_GLOBALS.G_ITEM_MODEL)
               AND p_x_line_rec.line_id = p_x_line_rec.top_model_line_id)
             OR p_x_line_rec.item_type_code = OE_GLOBALS.G_ITEM_CLASS))
      THEN
           IF OE_GENESIS_UTIL.G_INCOMING_FROM_DOO OR OE_GENESIS_UTIL.G_INCOMING_FROM_SIEBEL THEN
             if l_debug_level > 0 then
               oe_debug_pub.ADD(' The update is from DOO/Siebel Pre Exploded Kit ER',5);
             end if;
           END IF;
/* End DOO Pre Exploded Kit ER 9339742 */
           p_x_line_rec.explosion_date := null;
           l_count := l_count + 1;
           OE_Config_Pvt.OE_FREEZE_INC_ITEMS_TBL(l_count):= p_x_line_rec.line_id;
      END IF;

      END IF; -- End if phase is fulfillment
      -- END QUOTING changes

      -- Need to Call Shipping Update
      l_update_shipping	:= FND_API.G_TRUE;

      -- If the ordered quantity has been reduced then set the flag so
      -- that delayed request can check for shipment status.
      IF p_x_line_rec.ordered_quantity < p_old_line_rec.ordered_quantity THEN
    	   l_ordered_quantity_changed	:= FND_API.G_TRUE;
      END IF;
      --changes for bug 2315926  Begin

       IF (p_x_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE and
           p_x_line_rec.split_by = 'SYSTEM' and
           NVL(p_x_line_rec.split_action_code,'X') = 'SPLIT')
           OR
           (p_x_line_rec.operation = OE_GLOBALS.G_OPR_CREATE AND
            p_x_line_rec.split_from_line_id IS NOT NULL AND
            nvl(p_x_line_rec.split_by, 'USER') = 'SYSTEM') THEN
            -- don't call credit checking for system split when tax value changes.
           l_param1 := 'No_Credit_Checking';
         if l_debug_level > 0 then
           oe_debug_pub.add('System Split - l_param1 is: '||l_param1,1);
           oe_debug_pub.ADD('B2315926_1:',2);
              oe_debug_pub.add('In the split case, checking for catchweight item',3);
           end if;
           IF (p_x_line_rec.inventory_item_id IS NOT NULL AND
               p_x_line_rec.inventory_item_id <> FND_API.G_MISS_NUM) AND
              (p_x_line_rec.ship_from_org_id  IS NOT NULL AND
               p_x_line_rec.ship_from_org_id <> FND_API.G_MISS_NUM) THEN
                   l_item_rec := OE_Order_Cache.Load_Item (p_x_line_rec.inventory_item_id
                            ,p_x_line_rec.ship_from_org_id);
                   -- IF  l_item_rec.ont_pricing_qty_source = 1   AND
                   IF l_item_rec.ont_pricing_qty_source = 'S' AND -- INVCONV
                       l_item_rec.tracking_quantity_ind = 'P' and
                       l_item_rec.wms_enabled_flag = 'Y' THEN
                       If l_debug_level > 0 Then
                          oe_debug_pub.add('Catchweight enabled item',3);
                          oe_debug_pub.add('Setting the price flag to Yes');
                       End If;
                       OE_GLOBALS.G_PRICE_FLAG := 'Y';
                   END IF;
           END IF;
       else
        OE_GLOBALS.G_PRICE_FLAG := 'Y';
        if l_debug_level > 0 then
         oe_debug_pub.ADD('B2315926_2:',2);
        end if;
       end if;
       --changes for bug 2315926 end

     --changes for bug#7491829

       IF (p_x_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE and
           p_x_line_rec.split_by = 'SYSTEM' and
           NVL(p_x_line_rec.split_action_code,'X') = 'SPLIT') THEN
           IF l_debug_level > 0 THEN
              oe_debug_pub.add('Logging Reverse Limits delayed request for parent line');
              oe_debug_pub.add('Price request code for parent : ' || p_x_line_rec.price_request_code);
              oe_debug_pub.add('OLD Price request code for parent : ' || p_old_line_rec.price_request_code);
           END IF;
                         OE_delayed_requests_Pvt.log_request(
                                p_entity_code            => OE_GLOBALS.G_ENTITY_ALL,
                                p_entity_id              => p_x_line_rec.line_id,
                                p_requesting_entity_code => OE_GLOBALS.G_ENTITY_ALL,
                                p_requesting_entity_id   => p_x_line_rec.line_id,
                                p_request_unique_key1    => 'LINE',
                                p_param1                 => 'SPLIT_ORIG',
                                p_param2                 => p_old_line_rec.price_request_code,
                                p_param3                 => p_old_line_rec.ordered_quantity,
                                p_param4                 => p_x_line_rec.ordered_quantity,
                                p_param5                 => NULL,
                                p_param6                 => NULL,
                                p_request_type           => OE_GLOBALS.G_REVERSE_LIMITS,
                                x_return_status          => l_return_status);

       END IF;

       IF   (p_x_line_rec.operation = OE_GLOBALS.G_OPR_CREATE AND
            p_x_line_rec.split_from_line_id IS NOT NULL AND
            nvl(p_x_line_rec.split_by, 'USER') = 'SYSTEM') THEN
            IF l_debug_level > 0 THEN
              oe_debug_pub.add('Logging Reverse Limits delayed request for child line');
            END IF;
              OE_delayed_requests_Pvt.log_request(
                                p_entity_code            => OE_GLOBALS.G_ENTITY_ALL,
                                p_entity_id              => p_x_line_rec.line_id,
                                p_requesting_entity_code => OE_GLOBALS.G_ENTITY_ALL,
                                p_requesting_entity_id   => p_x_line_rec.line_id,
                                p_request_unique_key1    => 'LINE',
                                p_param1                 => 'SPLIT_NEW',
                                p_param2                 => NULL,
                                p_param3                 => NULL,
                                p_param4                 => NULL,
                                p_param5                 => NULL,
                                p_param6                 => p_x_line_rec.ordered_quantity,
                                p_request_type           => OE_GLOBALS.G_REVERSE_LIMITS,
                                x_return_status          => l_return_status);
       END IF;

       --bug#7491829

      OE_GLOBALS.G_TAX_FLAG := 'Y';

      -- bug 1829201, need to recalculate commitment when quantity changes.
      IF p_x_line_rec.commitment_id is not null then
        l_calculate_commitment_flag := 'Y';

        -- lkxu, bug 1786533 for commitment during line split
        IF ( p_x_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE AND
             NVL(p_x_line_rec.split_action_code,'X') = 'SPLIT' ) THEN

            l_update_commitment_flag := 'Y';
            OE_GLOBALS.g_original_commitment_applied
              := Oe_Commitment_Pvt.Get_Commitment_Applied_Amount
		(p_header_id          => p_x_line_rec.header_id ,
                 p_line_id            => p_x_line_rec.line_id ,
                 p_commitment_id      => p_x_line_rec.commitment_id);
        END IF;
      END IF;

      -- Freight Rating.
      IF OE_Freight_Rating_Util.IS_FREIGHT_RATING_AVAILABLE
         AND OE_Freight_Rating_Util.Get_List_Line_Type_Code
                                    (p_x_line_rec.header_id)
             = 'OM_CALLED_FREIGHT_RATES' THEN
         if l_debug_level > 0 then
           oe_debug_pub.add('Log Freight Rating request for qty change. ',3);
         end if;
           l_get_FTE_freight_rate := 'Y';
      END IF;

            /* INVCONV ordered_quantity2 needs to be calculated for
      split line process items - CHILD
      ============================================================*/
      -- INVCONV

      IF p_x_line_rec.operation = OE_GLOBALS.G_OPR_CREATE AND
         p_x_line_rec.split_from_line_id IS NOT NULL AND
         nvl(p_x_line_rec.split_by, 'USER') = 'USER' AND
         p_x_line_rec.line_category_code <> 'RETURN'
         THEN
                /*
          	p_x_line_rec.ordered_quantity2 :=
           		oe_line_util.Calculate_Ordered_Quantity2(p_x_line_rec);
           	*/
           	/* OPM - NC 3/8/02 Bug#2046641
           	   Commented the above call and added the call to calculate_dual_quantity */
                IF (OE_CODE_CONTROL.CODE_RELEASE_LEVEL <= '110507') OR NOT(OE_GLOBALS.G_UI_FLAG) THEN

           						if l_debug_level > 0 then
                				oe_debug_pub.add('about to call calculate_dual_quantity 1' );
                      end if;
                    oe_line_util.calculate_dual_quantity(
                         p_ordered_quantity => p_x_line_rec.ordered_quantity
                        ,p_old_ordered_quantity => NULL
                        ,p_ordered_quantity2 => p_x_line_rec.ordered_quantity2
                        ,p_old_ordered_quantity2 => NULL
                        ,p_ordered_quantity_uom  => p_x_line_rec.order_quantity_uom
                        ,p_ordered_quantity_uom2 => p_x_line_rec.ordered_quantity_uom2
                        ,p_inventory_item_id     => p_x_line_rec.inventory_item_id
                        ,p_ship_from_org_id      => p_x_line_rec.ship_from_org_id
                        ,x_ui_flag 		 => 0
                        ,x_return_status         => l_return_code
                        );


                        IF l_return_code <> 0 THEN -- INVCONV
	     										 IF l_return_status = -1
	     										 THEN
															p_x_line_rec.return_status := FND_API.G_RET_STS_ERROR;
														else
														p_x_line_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
														END IF;
												END IF;



                END IF;  -- Bug#2046641
           END IF;      -- INVCONV

      IF p_x_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE THEN
       /* INVCONV 02/JUN/00 ordered_quantity2 needs to be calculated
        for split line process items  - PARENT
        =======================================================*/
        IF p_x_line_rec.split_action_code = 'SPLIT' AND
        p_x_line_rec.line_category_code <> 'RETURN' AND
        p_x_line_rec.split_by = 'USER'
        THEN
                /*
            	p_x_line_rec.ordered_quantity2 :=
                     oe_line_util.Calculate_Ordered_Quantity2(p_x_line_rec);
                */
                /* OPM - NC 3/8/02 Bug#2046641
           	   Commented the above call and added the call to calculate_dual_quantity */
                IF (OE_CODE_CONTROL.CODE_RELEASE_LEVEL <= '110507') OR NOT(OE_GLOBALS.G_UI_FLAG) THEN
                    if l_debug_level > 0 then
                	oe_debug_pub.add('about to call calculate_dual_quantity 2' );
                      end if;

                    oe_line_util.calculate_dual_quantity(
                         p_ordered_quantity => p_x_line_rec.ordered_quantity
                        ,p_old_ordered_quantity => NULL
                        ,p_ordered_quantity2 => p_x_line_rec.ordered_quantity2
                        ,p_old_ordered_quantity2 => NULL
                        ,p_ordered_quantity_uom  => p_x_line_rec.order_quantity_uom
                        ,p_ordered_quantity_uom2 => p_x_line_rec.ordered_quantity_uom2
                        ,p_inventory_item_id     => p_x_line_rec.inventory_item_id
                        ,p_ship_from_org_id      => p_x_line_rec.ship_from_org_id
                        ,x_ui_flag 		 => 0
                        ,x_return_status         => l_return_code
                        );


                        IF l_return_code <> 0 THEN -- INVCONV
	     										 IF l_return_status = -1
	     										 THEN
															p_x_line_rec.return_status := FND_API.G_RET_STS_ERROR;
														else
														p_x_line_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
														END IF;
												END IF;





                END IF;  -- OPM Bug#2046641

        END IF;      -- OPM B1661023 04/02/01

        /* OPM END */

	   oe_sales_can_util.check_constraints
		      (p_x_line_rec	=> p_x_line_rec,
		       p_old_line_rec	=> p_old_line_rec,
		       x_return_status	=> l_return_status);
	    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	 		p_x_line_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
			p_x_line_rec.return_status := FND_API.G_RET_STS_ERROR;
              END IF;
	    END IF;



	    -- Additional task: Log the delayed request for verify payment
	    -- when order quantity changes and the Payment Type Code
	    -- is not CREDIT CARD and the Line is Booked.
	    -- If the payment type is CREDIT CARD then the delayed req should be
	    -- logged only if the quantity has increased.

	    IF OE_Order_Cache.g_header_rec.payment_type_code = 'CREDIT_CARD' THEN
	      IF  p_x_line_rec.ordered_quantity > p_old_line_rec.ordered_quantity
                THEN
                -- Log request here if commitment id is null
                if p_x_line_rec.commitment_id is null then
                 if l_debug_level > 0 then
           	  oe_debug_pub.ADD('Log Verify Payment delayed request in Ord Qty');
                 end if;
		  l_verify_payment_flag := 'Y';
	        end if;
              END IF;
              -- if this is a prepaid order, also log delayed request if ordered
              -- quantity decreases, as refund may need to be issued.
              IF OE_PrePayment_UTIL.is_prepaid_order(p_x_line_rec.header_id)
                      = 'Y'  AND p_x_line_rec.booked_flag ='Y' THEN
                  if l_debug_level > 0 then
           	    oe_debug_pub.ADD('Log Verify Payment delayed request in Ord Qty for prepayment', 3);
                  end if;
		    l_verify_payment_flag := 'Y';
              END IF;
	    ELSE
		  IF p_x_line_rec.booked_flag ='Y' THEN
                   if l_debug_level > 0 then
	 	    oe_debug_pub.ADD('Log Verify Payment delayed request for change in Order Qty');

                   end if;

                   -- Start fix for bug# 4378531
                   IF l_debug_level  > 0 THEN
                    oe_debug_pub.add('CHECKING CREDIT CHECK HOLD FOR HEADER/LINE ID : ' || TO_CHAR ( p_x_line_rec.header_id ) || '/' || TO_CHAR ( p_x_line_rec.line_id ) ) ;
                   END IF;

                   OE_HOLDS_PUB.Check_Holds
                      (  p_api_version    => 1.0
                       , p_header_id      => p_x_line_rec.header_id
                       , p_line_id        => p_x_line_rec.line_id
                       , p_hold_id        => 1
                       , p_entity_code    => 'O'
                       , p_entity_id      => p_x_line_rec.header_id
                       , x_result_out     => l_hold_result
                       , x_msg_count      => l_msg_count
                       , x_msg_data       => l_msg_data
                       , x_return_status  => l_return_status
                      );

                   IF l_debug_level  > 0 THEN
                    oe_debug_pub.add('CHECKING FOR CANCEL FLAG : ' || p_x_line_rec.cancelled_flag ) ;
                   END IF;

                   IF NOT( l_hold_result = FND_API.G_FALSE AND p_x_line_rec.cancelled_flag='Y') THEN
                    l_verify_payment_flag := 'Y';
                   END IF;

          -- Start of the fix  8471719
          IF p_x_line_rec.cancelled_flag='Y' THEN
            --ER 12363706 start
            IF OE_Credit_Engine_GRP.Is_Tolerance_Enabled(p_x_line_rec.header_id,l_credit_check_rule_rec) THEN

            		oe_debug_pub.add('OEXULINB: Tolerance is enabled.') ;

            ELSE
              --ER 12363706 end
              -- If Tolerance is not enabled, then tolernce check is not required. Setting the global variable to FALSE
              -- for avoinding tolerance checks.

              OE_CREDIT_ENGINE_GRP.TOLERANCE_CHECK_REQUIRED := FALSE;

              IF ('Y' = OE_SYS_PARAMETERS.VALUE('OE_CC_CANCEL_PARAM')) THEN
	          l_verify_payment_flag                       := 'Y';
              ELSE
                  l_verify_payment_flag                       := 'N';

              END IF;
            END IF; --ER 12363706
          END IF;
          -- End of the fix  8471719


                   IF l_debug_level  > 0 THEN
                    oe_debug_pub.add('CHECKING FOR VERIFY PAYMENT FLAG : ' || l_verify_payment_flag ) ;
                   END IF;
                   -- End fix for bug# 4378531

		  END IF;
         	END IF;

       END IF; --End of check for ordered_quantity


        -- Populate pricing quantity
    	IF p_x_line_rec.ordered_quantity <> FND_API.G_MISS_NUM And
		p_x_line_rec.pricing_quantity_uom is not null and
		p_x_line_rec.pricing_quantity_uom <> FND_API.G_MISS_CHAR and
		p_x_line_rec.order_quantity_uom is not null  and
		p_x_line_rec.order_quantity_uom <> FND_API.G_MISS_CHAR
	Then
            l_temp_pricing_quantity :=
		OE_Order_Misc_Util.convert_uom(
		p_x_line_rec.inventory_item_id,
		p_x_line_rec.order_quantity_uom,
		p_x_line_rec.pricing_quantity_uom,
		p_x_line_rec.ordered_quantity
					);

	    IF  l_temp_pricing_quantity >= 0 THEN
	            p_x_line_rec.Pricing_quantity:=l_temp_pricing_quantity;
		    oe_debug_pub.add('temp pricing quantity:'||l_temp_pricing_quantity);
	    END IF;

	End If; -- Pricing Quantity
      -- Pack J catchweight
       IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110510' THEN
       null; -- INVCONV COMMENTED OUT FOR NOW
          -- Calc_Catchweight_Return_qty2(p_x_line_rec => p_x_line_rec INVCONV COMMENTED OUT FOR NOW
          --                           , p_old_line_rec => p_old_line_rec); INVCONV COMMENTED OUT FOR NOW
       END IF;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_line_rec.order_quantity_uom,p_old_line_rec.order_quantity_uom)
    THEN
	-- Need to Call Shipping Update
    	l_update_shipping	:= FND_API.G_TRUE;
        OE_GLOBALS.G_PRICE_FLAG := 'Y';
        OE_GLOBALS.G_TAX_FLAG := 'Y';
    END IF;

    -- bug 1829201, need to recalculate commitment.
    --IF p_x_line_rec.commitment_id is not null then
    --  l_calculate_commitment_flag := 'Y';
    --END IF;

-- INVCONV
    --OPM 02/JUN/00   Test for changes to process attributes
    --                (ordered_quantity2, preferred_grade)
    --------------------------------------------------------
    IF NOT OE_GLOBALS.Equal(p_x_line_rec.ordered_quantity2,p_old_line_rec.ordered_quantity2) -- peter
    THEN
        if l_debug_level > 0 then
       			oe_debug_pub.add('Ordered Qty2 has changed',1); -- INVCONV
       			oe_debug_pub.add('New Ordered Qty2 : ' || p_x_line_rec.ordered_quantity2, 1);
       			oe_debug_pub.add('Old Ordered Qty2 : ' ||
                                p_old_line_rec.ordered_quantity2, 1);
      	end if;

        l_update_shipping     := FND_API.G_TRUE;
        -- start 2046190
             IF dual_uom_control   --   INVCONV Process_Characteristics
                             (p_x_line_rec.inventory_item_id
                             ,p_x_line_rec.ship_from_org_id
                             ,l_item_rec) THEN

                -- IF l_item_rec.ont_pricing_qty_source = 1 THEN INVCONV
                IF l_item_rec.ont_pricing_qty_source = 'S' THEN -- INVCONV
                 -- need to call pricing
                      if l_debug_level > 0 then
                				oe_debug_pub.add('dual uom  - ont_pricing_qty_source = ' || l_item_rec.ont_pricing_qty_source );
                      end if;
								OE_GLOBALS.G_PRICE_FLAG := 'Y';
        				OE_GLOBALS.G_TAX_FLAG := 'Y';

        				END IF;

          oe_sales_can_util.check_constraints
		      (p_x_line_rec	=> p_x_line_rec,
		       p_old_line_rec	=> p_old_line_rec,
		       x_return_status	=> l_return_status);
	    		IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	      		IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	 							p_x_line_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
								p_x_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;
	    		END IF;

      --Bug 14211120 Start
      --log delayed request to update IR if secondary quantity changes on ISO
      IF (p_x_line_rec.order_source_id = 10) AND
                 (p_old_line_rec.ordered_quantity2 IS NOT NULL) THEN
       IF NOT ((nvl(p_x_line_rec.split_by,'X') IN ('USER','SYSTEM')) --Not a split
          AND (NVL(p_x_line_rec.split_action_code,'X') = 'SPLIT')) THEN
       IF NOT OE_Internal_Requisition_Pvt.G_Update_ISO_From_Req THEN --change not initiated by PO
         IF NOT OE_SALES_CAN_UTIL.G_IR_ISO_HDR_CANCEL THEN --not a full order cancellation
           IF l_debug_level > 0 THEN
             oe_debug_pub.add(' Header Level Cancellation is FALSE',5);
             oe_debug_pub.add(' Secondary qty change: Logging delayed request for G_UPDATE_REQUISITION',5);
           END IF;

           -- Log a delayed request to update the Internal Requisition. This delayed
           -- request will be logged only if the change is not initiated from Requesting
           -- Organization user, and it is not a Internal Sales Order Full Cancellation

           OE_delayed_requests_Pvt.log_request
           ( p_entity_code            => OE_GLOBALS.G_ENTITY_LINE
           , p_entity_id              => p_x_line_rec.line_id
           , p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE
           , p_requesting_entity_id   => p_x_line_rec.line_id
           , p_request_unique_key1    => p_x_line_rec.header_id  -- Order Hdr_id
           , p_request_unique_key2    => p_x_line_rec.source_document_id -- Req Hdr_id
           , p_request_unique_key3    => p_x_line_rec.source_document_line_id -- Req Line_id
           , p_param4                 => (p_x_line_rec.ordered_quantity2 - p_old_line_rec.ordered_quantity2)
           --, p_date_param1            => p_x_line_rec.schedule_ship_date
           , p_request_type           => OE_GLOBALS.G_UPDATE_REQUISITION
           , x_return_status          => l_return_status
           );
           IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
           END IF;
         END IF;
       END IF;
	   END IF;
      END IF;
      --Bug 14211120 End

   			END IF; -- IF dual_uom_control   --   INVCONV Process_Characteristics
-- end   2046190

--      NULL;
    END IF; -- IF NOT OE_GLOBALS.Equal(p_x_line_rec.ordered_quantity2,p_old_line_rec.ordered_quantity2) -- peter

    IF NOT OE_GLOBALS.Equal(p_x_line_rec.preferred_grade,p_old_line_rec.preferred_grade
)
    THEN
        -- Need to Call Shipping Update
        l_update_shipping     := FND_API.G_TRUE;
        OE_GLOBALS.G_PRICE_FLAG := 'Y';
        OE_GLOBALS.G_TAX_FLAG := 'Y';

        IF p_x_line_rec.commitment_id IS NOT NULL THEN
          l_get_commitment_bal := 'Y';
        END IF;
    END IF;
    --INVCONV  02/JUN/00 END
    --=================

    IF NOT OE_GLOBALS.Equal(p_x_line_rec.payment_term_id,p_old_line_rec.payment_term_id)
    THEN

        -- Need to Call Pricing: bug 1504821
        OE_GLOBALS.G_PRICE_FLAG := 'Y';

	/* Additional task: If the payment type is not CREDIT CARD
	then if the payment term changes for a line which is Booked
	it should log a delayed request for Verify Payment */

	IF p_x_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE THEN

          if p_x_line_rec.booked_flag ='Y' then

            IF OE_PrePayment_UTIL.IS_MULTIPLE_PAYMENTS_ENABLED = TRUE THEN

              if l_debug_level > 0 then
                 oe_debug_pub.ADD('multpayments: logging delayed request for verify payment as payment term is changed');
              end if;
              l_verify_payment_flag := 'Y';

	    ELSIF NVL(OE_Order_Cache.g_header_rec.payment_type_code, 'NULL') <> 'CREDIT_CARD'
	    THEN

              if l_debug_level > 0 then
	        oe_debug_pub.ADD('logging delayed request for verify payment as payment term is changed');
              end if;
	      l_verify_payment_flag := 'Y';

	    END IF;   -- if multiple_payments is enabled

          end if; -- if booked_flag is Y

        END IF; -- if operation is update

    END IF;  -- if payment_term_id has changed

    IF NOT OE_GLOBALS.Equal(p_x_line_rec.price_list_id,p_old_line_rec.price_list_id)
    THEN
        OE_GLOBALS.G_PRICE_FLAG := 'Y';

        IF p_x_line_rec.commitment_id IS NOT NULL THEN
          l_get_commitment_bal := 'Y';
        END IF;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_line_rec.pricing_date,p_old_line_rec.pricing_date)
    THEN
        OE_GLOBALS.G_PRICE_FLAG := 'Y';

       -- bug 2072014, need to recalculate price if pricing_date is updated BEGIN
        IF p_x_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE AND
	   OE_GLOBALS.Equal(p_x_line_rec.reference_line_id,p_old_line_rec.reference_line_id) THEN --bug 5260190
            p_x_line_rec.calculate_price_flag := 'Y';
        END IF;
       -- bug 2072014, need to recalculate price if pricing_date is updated END

        IF p_x_line_rec.commitment_id IS NOT NULL THEN
          l_get_commitment_bal := 'Y';
        END IF;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_line_rec.pricing_quantity,p_old_line_rec.pricing_quantity)
    THEN
       --commenting the below line for bug 2315926
        --OE_GLOBALS.G_PRICE_FLAG := 'Y';

        -- bug 1829201, need to recalculate commitment.
        IF p_x_line_rec.commitment_id is not null then
          l_calculate_commitment_flag := 'Y';
        END IF;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_line_rec.pricing_quantity_uom,p_old_line_rec.pricing_quantity_uom)
    THEN
       --commenting the below line for bug 2315926
        --OE_GLOBALS.G_PRICE_FLAG := 'Y';

        -- bug 1829201, need to recalculate commitment.
        IF p_x_line_rec.commitment_id is not null then
          l_calculate_commitment_flag := 'Y';
        END IF;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_line_rec.reference_line_id,p_old_line_rec.reference_line_id)
    THEN
      IF OE_GLOBALS.G_RETURN_CHILDREN_MODE = 'N' THEN
       if l_debug_level > 0 then
        oe_debug_pub.ADD('RMA: logging delayed request ');
       end if;
        IF p_x_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE OR
           p_x_line_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN

           IF p_x_line_rec.split_from_line_id is NULL THEN -- Bug 5676051

           OE_delayed_requests_Pvt.log_request(
				p_entity_code            => OE_GLOBALS.G_ENTITY_LINE,
                p_entity_id              => p_x_line_rec.line_id,
			    p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
			    p_requesting_entity_id   => p_x_line_rec.line_id,
                p_param1    => p_x_line_rec.operation,  --Bug 4651421
                p_param2    => p_x_line_rec.split_by,
                p_param3    => p_x_line_rec.split_action_code,
                p_param4    => to_char(p_x_line_rec.split_from_line_id),
                p_request_type      => OE_GLOBALS.G_INSERT_RMA,
                x_return_status     => l_return_status);
           END IF; -- Bug 5676051

          /* BUG 2013611 and 2109230 */
          If p_x_line_rec.calculate_price_flag in ('N','P') THEN
            IF (OE_GLOBALS.G_UI_FLAG) THEN
             if l_debug_level > 0 then
              oe_debug_pub.add('Log REVERSE_LIMITS delayed request for ENTITY LINE return',1);
             end if;
              OE_delayed_requests_Pvt.log_request(
                                p_entity_code 		 => OE_GLOBALS.G_ENTITY_LINE,
				p_entity_id              => p_x_line_rec.line_id,
				p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
				p_requesting_entity_id   => p_x_line_rec.line_id,
				p_request_unique_key1  	 => 'LINE',
		 		p_param1                 => 'RETURN',
		 		p_param2                 => NULL,
		 		p_param3                 => NULL,
		 		p_param4                 => NULL,
		 		p_param5                 => NULL,
		 		p_param6                 => p_x_line_rec.ordered_quantity,
		 		p_request_type           => OE_GLOBALS.G_REVERSE_LIMITS,
		 		x_return_status          => l_return_status);
            ELSIF NOT (OE_GLOBALS.G_UI_FLAG) THEN
             if l_debug_level > 0 then
              oe_debug_pub.add('Log REVERSE_LIMITS delayed request for ENTITY ALL line return',1);
             end if;
              OE_delayed_requests_Pvt.log_request(
                                p_entity_code 		 => OE_GLOBALS.G_ENTITY_ALL,
				p_entity_id              => p_x_line_rec.line_id,
				p_requesting_entity_code => OE_GLOBALS.G_ENTITY_ALL,
				p_requesting_entity_id   => p_x_line_rec.line_id,
				p_request_unique_key1  	 => 'LINE',
		 		p_param1                 => 'RETURN',
		 		p_param2                 => NULL,
		 		p_param3                 => NULL,
		 		p_param4                 => NULL,
		 		p_param5                 => NULL,
		 		p_param6                 => p_x_line_rec.ordered_quantity,
		 		p_request_type           => OE_GLOBALS.G_REVERSE_LIMITS,
		 		x_return_status          => l_return_status);
            END IF;
	  END IF;
          /* BUG 2013611 and 2109230 END */
        END IF;
       END IF;

        -- bug 1917869
	IF p_x_line_rec.calculate_price_flag in ('N','P') then
	  l_copy_adjustments := TRUE;
        END IF;

	l_copy_pricing_attributes := TRUE;
	If p_x_line_rec.calculate_price_flag = 'N' then
		p_x_line_rec.calculate_price_flag := 'P';
	end if;

    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_line_rec.request_date,p_old_line_rec.request_date)
    THEN

	 -- Need to Call Shipping Update
    	 l_update_shipping	:= FND_API.G_TRUE;

	 -- Call Pricing
         OE_GLOBALS.G_PRICE_FLAG := 'Y';

         IF p_x_line_rec.commitment_id IS NOT NULL THEN
           l_get_commitment_bal := 'Y';
         END IF;

       /*
       ** Commented as part of 1655720 after discussion with zbutt
       IF p_x_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE AND
          p_x_line_rec.booked_flag ='Y'
       THEN
          if l_debug_level > 0 then
            oe_debug_pub.ADD('logging delayed request for Verify Payment
                                    forchange in Request date');
          end if;
            l_verify_payment_flag := 'Y';
       END IF;
       */

    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_line_rec.schedule_ship_date,p_old_line_rec.schedule_ship_date)
    THEN

	  -- Need to Call Shipping Update
    	  l_update_shipping	:= FND_API.G_TRUE;
	   --  Taking out this because the TAX request should get fired only
	   --  when the tax_date changes. And tax_date will change if the
	   --  schedule_ship_date changes.
        IF p_old_line_rec.schedule_ship_date IS NOT NULL THEN
           l_3a7_attribute_change := FND_API.G_TRUE;
        END IF;
        --  OE_GLOBALS.G_TAX_FLAG := 'Y';

	 -- Call Pricing
         -- For performance bug 1351111, turning off Pricing for scheduling

         /* Commenting out for 1419204
         l_turn_off_pricing := FND_PROFILE.VALUE('ONT_NO_PRICING_AT_SCHEDULING');
         -- by default, turn off pricing at scheduling
         IF l_turn_off_pricing = 'N' THEN
           OE_GLOBALS.G_PRICE_FLAG := 'Y';
         End If;
         */

         IF p_x_line_rec.commitment_id IS NOT NULL THEN
           l_get_commitment_bal := 'Y';
         END IF;

        -- Freight Rating
        IF OE_Freight_Rating_Util.IS_FREIGHT_RATING_AVAILABLE
           AND OE_Freight_Rating_Util.Get_List_Line_Type_Code
                                      (p_x_line_rec.header_id)
               = 'OM_CALLED_FREIGHT_RATES' THEN
           if l_debug_level > 0 then
             oe_debug_pub.add('Log Freight Rating request for schedule ship date. ',3);
           end if;
             l_get_FTE_freight_rate := 'Y';
        END IF;

	  /* Additional task : Log delayed request for verify payment
	  when payment type is not CREDIT CARD and when schedule date
	  has changed for a booked Line  and it is not a drop-ship line*/

    -- modified for bug 1655720 to not perform credit checking if
    -- schedule_ship_date changes.
    /***
    IF (p_x_line_rec.source_type_code <> OE_GLOBALS.G_SOURCE_EXTERNAL) THEN

	  IF p_x_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE
	  THEN
	     IF NVL(OE_Order_Cache.g_header_rec.payment_type_code, 'NULL') <> 'CREDIT_CARD' AND
             p_x_line_rec.booked_flag ='Y' AND
             (to_date(p_x_line_rec.schedule_ship_date, 'DD/MM/YYYY') <>
              to_date(p_x_line_rec.request_date, 'DD/MM/YYYY'))
	     THEN
               if l_debug_level > 0 then
		  oe_debug_pub.ADD('logging delayed request for Verify Payment
                                     for change in Scheduled Ship date');
               end if;
		  l_verify_payment_flag := 'Y';
	     END IF;
	  END IF;

     END IF;
     ***/

       if l_debug_level > 0 then
	 oe_debug_pub.add('opr = '||p_x_line_rec.operation);
       end if;

/* 7576948: IR ISO Change Management project Start */
--
-- This program unit will track the specific change in Ordered Quantity
-- and/or Schedule Ship Date on an internal sales order line shipment,
-- and in the event of any change in values, it will log a delayed request
-- of type OE_Globals.G_UPDATE_REQUISITION.
--
-- This delayed request will be logged only if global OE_Internal_Requisi
-- tion_Pvt.G_Update_ISO_From_Req set to FALSE. If this global is TRUE
-- then it means, the change requests for quantity/date or cancellation
-- request is initiated by internal requisition user, in which case, it is
-- not required to log the delayed request for updating the change to the
-- requesting organization. System will also check that global OE_SALES_CAN
-- _UTIL.G_IR_ISO_HDR_CANCEL, and will log a delayed request only if it is
-- FALSE. If this global is TRUE then signifies that it is a case of full
-- internal sales order header cancellation. Thus, in the event of full
-- order cancellation, we only need to inform Purchasing about the
-- cancellation. There is no need to provide specific line level information.
-- Additionally, while logging a delayed request specific to Schedule Ship
-- Date change, system will ensure that it should be allowed via Purchasing
-- profile 'POR: Sync Up Need By date on IR with OM'.
--
-- While logging the delayed request, we will log it for Order Header or
-- Order Line entity, while Entity id will be the Header_id or Line_id
-- respectively. In addition to this, we will even pass Unique_Params value
-- to make this request very specific to Requisition Header or Requisition
-- Line.
--
-- Please refer to following delayed request params with their meaning
-- useful while logging the delayed request -
--
-- P_entity_code        Entity for which delayed request has to be logged.
--                      In this project it can be OE_Globals.G_Entity_Line
--                      or OE_Globals.G_Entity_Header
-- P_entity_id          Primary key of the entity record. In this project,
--                      it can be Order Line_id or Header_id
-- P_requesting_entity_code Which entity has requested this delayed request to
--                          be logged! In this project it will be OE_Globals.
--                          G_Entity_Line or OE_Globals.G_Entity_Header
-- P_requesting_entity_id       Primary key of the requesting entity. In this
--                              project, it is Line_id or Header_id
-- P_request_type       Indicates which business logic (or which procedure)
--                      should be executed. In this project, it is OE_Global
--                      s.G_UPDATE_REQUISITION
-- P_request_unique_key1        Additional argument in form of parameters.
--                              In this project, it will denote the Sales Order
--                              Header id
-- P_request_unique_key2        Additional argument in form of parameters.
--                              In this project, it will denote the Requisition
--                              Header id
-- P_request_unique_key3        Additional argument in form of parameters. In
--                              this project, it will denote the Requistion Line
--                              id
-- P_param1     Additional argument in form of parameters. In this project, it
--              will denote net change in order quantity with respective single
--              requisition line. If it is greater than 0 then it is an increment
--              in the quantity, while if it is less than 0 then it is a decrement
--              in the ordered quantity. If it is 0 then it indicates there is no
--              change in ordered quantity value
-- P_param2     Additional argument in form of parameters. In this project, it
--              will denote whether internal sales order is cancelled or not. If
--              it is cancelled then respective Purchasing api will be called to
--              trigger the requisition header cancellation. It accepts a value of
--              Y indicating requisition header has to be cancelled.
-- P_param3     Additional argument in form of parameters. In this project, it
--              will denote the number of sales order lines cancelled while order
--              header is (Full/Partial) cancelled.
-- p_date_param1        Additional date argument in form of parameters. In this
--                      project, it will denote the change in Schedule Ship Date
--                      with to respect to single requisition line.
-- P_Long_param1        Additional argument in form of parameters. In this project,
--                      it will store all the sales order line_ids, which are getting
--                      cancelled while order header gets cancelled (Full/Partial).
--                      These Line_ids will be separated by a delimiter comma ','
--
-- For details on IR ISO CMS project, please refer to FOL >
-- OM Development > OM GM > 12.1.1 > TDD > IR_ISO_CMS_TDD.doc
--

/* -- Commented for IR ISO : Starts

	 IF (p_x_line_rec.order_source_id = 10) AND
	    (p_old_line_rec.schedule_ship_date IS NOT NULL) THEN
            FND_MESSAGE.SET_NAME('ONT','OE_CHG_CORR_REQ');
            -- { start fix for 2648277
	    FND_MESSAGE.SET_TOKEN('CHG_ATTR',
               OE_Order_Util.Get_Attribute_Name('schedule_ship_date'));
            -- end fix for 2648277}
	   OE_MSG_PUB.Add;
      END IF;

      END IF;
*/ -- Commented for IR ISO Ends.


/* -- Commented for IR ISO Tracking bug 7667702
 *
   IF (p_x_line_rec.order_source_id = 10) THEN
     IF (p_old_line_rec.schedule_ship_date IS NOT NULL) OR
        (p_x_line_rec.operation = OE_GLOBALS.G_OPR_CREATE AND
         p_x_line_rec.split_from_line_id IS NOT NULL AND
         nvl(p_x_line_rec.split_by, 'X') = 'SYSTEM') THEN
       -- The above new OR condition is needed to ensure that a data
       -- change can happen either as a direct Update operation, OR
       -- during split of order lines, where original record will be
       -- Updated while new record will be Created

       l_po_NeedByDate_Update := NVL(FND_PROFILE.VALUE('POR_SYNC_NEEDBYDATE_OM'),'NO');

       IF l_debug_level > 0 THEN
         oe_debug_pub.add(' Need By Date update is allowed ? '||l_po_NeedByDate_Update);
       END IF;

       IF NOT OE_Internal_Requisition_Pvt.G_Update_ISO_From_Req
         AND NOT OE_SALES_CAN_UTIL.G_IR_ISO_HDR_CANCEL AND
         l_po_NeedByDate_Update = 'YES' THEN

         -- Log a delayed request to update the change in Schedule Ship Date to
         -- Requisition Line. This request will be logged only if the change is
         -- not initiated from Requesting Organization, and it is not a case of
         -- Internal Sales Order Full Cancellation. It will even not be logged
         -- Purchasing profile option does not allow update of Need By Date when
         -- Schedule Ship Date changes on internal sales order line

         OE_delayed_requests_Pvt.log_request
         ( p_entity_code            => OE_GLOBALS.G_ENTITY_LINE
         , p_entity_id              => p_x_line_rec.line_id
         , p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE
         , p_requesting_entity_id   => p_x_line_rec.line_id
         , p_request_unique_key1    => p_x_line_rec.header_id  -- Order Hdr_id
         , p_request_unique_key2    => p_x_line_rec.source_document_id -- Req Hdr_id
         , p_request_unique_key3    => p_x_line_rec.source_document_line_id -- Req Line_id
         , p_date_param1            => p_x_line_rec.schedule_ship_date
         , p_request_type           => OE_GLOBALS.G_UPDATE_REQUISITION
         , x_return_status          => l_return_status
         );

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;

       END IF;
     END IF; -- Split_by
   END IF;  -- Order Source is 10.
*/ -- Commented for IR ISO Tracking bug 7667702

/* ============================= */
/* IR ISO Change Management Ends */


    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_line_rec.schedule_arrival_date,p_old_line_rec.schedule_arrival_date)
    THEN

        -- Freight Rating
        IF OE_Freight_Rating_Util.IS_FREIGHT_RATING_AVAILABLE
           AND OE_Freight_Rating_Util.Get_List_Line_Type_Code
                                      (p_x_line_rec.header_id)
               = 'OM_CALLED_FREIGHT_RATES' THEN
           if l_debug_level > 0 then
             oe_debug_pub.add('Log Freight Rating request for schedule arrivale date. ',3);
           end if;
             l_get_FTE_freight_rate := 'Y';
        END IF;

/* 7576948: IR ISO Change Management project Start */
--
-- For details on IR ISO CMS project, please refer to FOL >
-- OM Development > OM GM > 12.1.1 > TDD > IR_ISO_CMS_TDD.doc
--


   IF (p_x_line_rec.order_source_id = 10) THEN
     IF (p_old_line_rec.schedule_arrival_date IS NOT NULL) OR
        (p_x_line_rec.operation = OE_GLOBALS.G_OPR_CREATE AND
         p_x_line_rec.split_from_line_id IS NOT NULL AND
         nvl(p_x_line_rec.split_by, 'X') = 'SYSTEM') THEN
       -- The above new OR condition is needed to ensure that a data
       -- change can happen either as a direct Update operation, OR
       -- during split of order lines, where original record will be
       -- Updated while new record will be Created

       l_po_NeedByDate_Update := NVL(FND_PROFILE.VALUE('POR_SYNC_NEEDBYDATE_OM'),'NO');

       IF l_debug_level > 0 THEN
         oe_debug_pub.add(' Need By Date update is allowed ? '||l_po_NeedByDate_Update);
       END IF;

       IF NOT OE_Internal_Requisition_Pvt.G_Update_ISO_From_Req
         AND NOT OE_SALES_CAN_UTIL.G_IR_ISO_HDR_CANCEL AND
         OE_Schedule_GRP.G_ISO_Planning_Update THEN -- Added for IR ISO Tracking bug 7667702
         -- l_po_NeedByDate_Update = 'YES' THEN -- Commented for IR ISO Tracking bug 7667702
         IF l_po_NeedByDate_Update = 'YES' THEN -- Added for IR ISO Tracking bug 7667702

         -- Log a delayed request to update the change in Schedule Arrival Date to
         -- Requisition Line. This request will be logged only if the change is
         -- not initiated from Requesting Organization, and it is not a case of
         -- Internal Sales Order Full Cancellation. It will even not be logged
         -- Purchasing profile option does not allow update of Need By Date when
         -- Schedule Arrival Date changes on internal sales order line

         OE_delayed_requests_Pvt.log_request
         ( p_entity_code            => OE_GLOBALS.G_ENTITY_LINE
         , p_entity_id              => p_x_line_rec.line_id
         , p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE
         , p_requesting_entity_id   => p_x_line_rec.line_id
         , p_request_unique_key1    => p_x_line_rec.header_id  -- Order Hdr_id
         , p_request_unique_key2    => p_x_line_rec.source_document_id -- Req Hdr_id
         , p_request_unique_key3    => p_x_line_rec.source_document_line_id -- Req Line_id
         , p_date_param1            => p_x_line_rec.schedule_arrival_date
-- Note: p_date_param1 is used for both Schedule_Ship_Date and
-- Schedule_Arrival_Date, as while executing G_UPDATE_REQUISITION delayed
-- request via OE_Process_Requisition_Pvt.Update_Internal_Requisition,
-- it can expect change with respect to Ship or Arrival date. Thus, will
-- not raise any issues.
         , p_request_type           => OE_GLOBALS.G_UPDATE_REQUISITION
         , x_return_status          => l_return_status
         );

         IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
         END IF;

         ELSE -- Added for IR ISO Tracking bug 7667702
           IF l_debug_level > 0 THEN
             oe_debug_pub.add(' Need By Date is not allowed to update. Updating MTL_Supply only',5);
           END IF;

           OE_SCHEDULE_UTIL.Update_PO(p_x_line_rec.schedule_arrival_date,
                p_x_line_rec.source_document_id,
                p_x_line_rec.source_document_line_id);
         END IF;

       END IF;
     END IF; -- Split_by
   END IF;  -- Order Source is 10.

/* ============================= */
/* IR ISO Change Management Ends */


    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_line_rec.shipment_priority_code,p_old_line_rec.shipment_priority_code)
    THEN
	-- Need to Call Shipping Update
    	l_update_shipping	:= FND_API.G_TRUE;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_line_rec.shipped_quantity,p_old_line_rec.shipped_quantity)
    THEN
		--IF (p_x_line_rec.ship_set_id IS NOT NULL ) THEN
          --OE_delayed_requests_Pvt.log_request(
	     --p_entity_code => OE_GLOBALS.G_ENTITY_LINE,
          --p_entity_id         => p_x_line_rec.ship_set_id,
	     --p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
	     --p_requesting_entity_id         => p_x_line_rec.line_id,
          -- p_request_type      => OE_GLOBALS.G_SPLIT_SET_CHK,
          --p_param1 => to_char(p_x_line_rec.actual_shipment_date,'DD-MON-RRRR'),
          --x_return_status     => l_return_status);
		--END IF;

        NULL;

    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_line_rec.shipping_method_code,p_old_line_rec.shipping_method_code)
    THEN
        -- Need to Call Pricing: bug 3344835
        OE_GLOBALS.G_PRICE_FLAG := 'Y';

	-- Need to Call Shipping Update
    	l_update_shipping	:= FND_API.G_TRUE;
        IF OE_Freight_Rating_Util.IS_FREIGHT_RATING_AVAILABLE
           AND OE_Freight_Rating_Util.Get_List_Line_Type_Code
                                      (p_x_line_rec.header_id)
               = 'OM_CALLED_FREIGHT_RATES'
           AND oe_globals.g_freight_recursion = 'N' THEN
            if l_debug_level > 0 then
             oe_debug_pub.add('Log Freight Rating request for shipping method. ',3);
            end if;
             l_get_FTE_freight_rate := 'Y';
        END IF;

    END IF;

    -- Don't change the order for the following, flow_status_code depends on this
    -- order to update the appropriate flow_status_code

    IF NOT OE_GLOBALS.Equal(p_x_line_rec.booked_flag, p_old_line_rec.booked_flag)
    THEN
  	   IF p_x_line_rec.booked_flag = 'Y' AND p_x_line_rec.flow_status_code = 'ENTERED' THEN
	   -- only set status to BOOKED if we were at ENTERED
		 p_x_line_rec.flow_status_code := 'BOOKED';
                 -- For bug 1304916. Booking wil call price_line directly
        	 --OE_GLOBALS.G_PRICE_FLAG := 'Y';
               if l_debug_level > 0 then
		 oe_debug_pub.add('sam: flow_status_code is ' || p_x_line_rec.flow_status_code);
               end if;
	   END IF;
    END IF;



  /*  WARNING !!!! The following code will not get executed after patchset 'G'.
  This code HAS BEEN MOVED to package OE_SHIP_CONFIRMATION_PUB.SHIP_CONFIRM. Please change the code in file OEXPSHCB.pls if any changes are required in the following IF */

    IF NOT OE_GLOBALS.Equal(p_x_line_rec.shipping_quantity,p_old_line_rec.shipping_quantity)
    THEN
	   -- Convert the shipping quantity from shipping quantity UOM to
	   -- Ordered quantity UOM and update the field shipped quantity

	   -- Call API to convert the shipping quantity to shipped quantity from
	   -- shipping quantity UOM to ordered quantity UOM and assign the returned
	   -- quantity to shipped quantity of p_x_line_rec.
     if l_debug_level > 0 then
        oe_debug_pub.ADD('Order Quantity UOM : '|| p_x_line_rec.order_quantity_uom,2);
        oe_debug_pub.ADD('Shipping Quantity UOM : '|| p_x_line_rec.shipping_quantity_uom,2);
     end if;
	   IF 	p_x_line_rec.shipping_quantity_uom <> p_x_line_rec.order_quantity_uom THEN

     /* --OPM 06/SEP/00 invoke process Uom Conversion for process line INVCONV
             --============================================================
             IF dual_uom_control  --   INVCONV Process_Characteristics
                             (p_x_line_rec.inventory_item_id
                             ,p_x_line_rec.ship_from_org_id
                             ,l_item_rec) THEN

             if l_debug_level > 0 then
               oe_debug_pub.ADD('OPM Process shipping update ',1);
             end if;
                GMI_Reservation_Util.Get_OPMUOM_from_AppsUOM
                     (p_Apps_UOM       => p_x_line_rec.order_quantity_uom
                     ,x_OPM_UOM        => l_OPM_order_quantity_uom
                     ,x_return_status  => l_status
                     ,x_msg_count      => l_msg_count
                     ,x_msg_data       => l_msg_data);

--             Get the OPM equivalent code for shipping_quantity_uom
--               ========================================================
               GMI_Reservation_Util.Get_OPMUOM_from_AppsUOM
                     (p_Apps_UOM       => p_x_line_rec.shipping_quantity_uom
                     ,x_OPM_UOM        => l_OPM_shipping_quantity_uom
                     ,x_return_status  => l_status
                     ,x_msg_count      => l_msg_count
                     ,x_msg_data       => l_msg_data);

--                Apply OPM unit of measure conversion
--               ======================================
               l_OPM_shipped_quantity :=GMICUOM.uom_conversion
 	                     	(l_item_rec.opm_item_id,0
     	    	                ,p_x_line_rec.shipping_quantity
                               ,l_OPM_shipping_quantity_uom
    	    	                     ,l_OPM_order_quantity_uom,0);

-- get_opm_converted_qty to resolve rounding issues


      l_OPM_shipped_quantity := GMI_Reservation_Util.get_opm_converted_qty(
              p_apps_item_id    => p_x_line_rec.inventory_item_id,
              p_organization_id => p_x_line_rec.ship_from_org_id,
              p_apps_from_uom   => p_x_line_rec.shipping_quantity_uom,
              p_apps_to_uom     => p_x_line_rec.order_quantity_uom,
              p_original_qty    => p_x_line_rec.shipping_quantity);
     if l_debug_level > 0 then
     end if;

-- Feb 2003 2683316 end


		-- B2037234 EMC  INVCONV
                -- B2204216 EMC- Moved assignment of profile value out of
                -- Declaration. Here, the profile value has the potential to
                -- affect OPM customers only.
                -- To accomodate for international date format and use of commas
		-- instead of decimal points, introduced
                -- fnd_number.canonical_to_number which converts the returned
                -- VARCHAR value to a number.

		l_epsilon :=fnd_number.canonical_to_number(NVL(FND_PROFILE.VALUE('IC$EPSILON'),0)) ;
 		n := (-1) * round(log(10,l_epsilon));
 		l_OPM_shipped_quantity:=round(l_OPM_shipped_quantity, n);



               -- Enforce precision of 19,9
               --===========================-
               l_temp_shipped_quantity := l_OPM_shipped_quantity;
             if l_debug_level > 0 then
               oe_debug_pub.ADD('OPM Process shipping update conversion gives shipped quantity of ' || l_temp_shipped_quantity,1);
             end if;



             ELSE */ --  INVCONV

			l_temp_shipped_quantity := OE_Order_Misc_Util.Convert_Uom
				  (
				  p_x_line_rec.inventory_item_id,
				  p_x_line_rec.shipping_quantity_uom,
				  p_x_line_rec.order_quantity_uom,
				  p_x_line_rec.shipping_quantity
				  );
              if l_debug_level > 0 then
        	oe_debug_pub.ADD('Converted Shipped Quantity : '|| to_char(l_temp_shipped_quantity),1);
              end if;
            --   END IF; -- INVCONV
             --OPM 06/SEP/00 END


              if l_debug_level > 0 then
        	oe_debug_pub.ADD('Converted Shipped Quantity : '|| to_char(l_temp_shipped_quantity),1);
              end if;

			IF	l_temp_shipped_quantity <> trunc(l_temp_shipped_quantity) THEN

				Inv_Decimals_PUB.Validate_Quantity
				(
					p_item_id	=> p_x_line_rec.inventory_item_id,
					p_organization_id => OE_Sys_Parameters.value('MASTER_ORGANIZATION_ID'),
					p_input_quantity => l_temp_shipped_quantity,
					p_uom_code		 => p_x_line_rec.order_quantity_uom,
					x_output_quantity => l_validated_quantity,
					x_primary_quantity => l_primary_quantity,
					x_return_status		=> l_qty_return_status
				);

                             if l_debug_level > 0 then
				oe_debug_pub.add('Return status from INV API : '||l_qty_return_status,1);
                             end if;
				IF	l_qty_return_status = 'W' THEN

					p_x_line_rec.shipped_quantity := l_validated_quantity;
				ELSE

					p_x_line_rec.shipped_quantity := l_temp_shipped_quantity;

				END IF;

			ELSE
				p_x_line_rec.shipped_quantity := l_temp_shipped_quantity;

			END IF;

		        p_x_line_rec.shipped_quantity2 := p_x_line_rec.shipping_quantity2; -- OPM B1873114 07/10/01
	   ELSE

			p_x_line_rec.shipped_quantity := p_x_line_rec.shipping_quantity;
		        p_x_line_rec.shipped_quantity2 := p_x_line_rec.shipping_quantity2; -- OPM B1661023 04/02/01

	   END IF;

      if l_debug_level > 0 then
        oe_debug_pub.ADD('Shipped Quantity : '|| to_char(p_x_line_rec.shipped_quantity),1);
      end if;
	   -- The following line needs to assign the value of shipped quantity
	   -- after the conversion of shipping quantity to ordered quantity UOM.

       -- Log the delayed request for Ship Confirmation if there is an update
       -- from Shipping for ship confirmation
       IF p_x_line_rec.line_category_code <> 'RETURN' THEN
         IF (p_x_line_rec.ship_set_id IS NOT NULL AND
             p_x_line_rec.ship_set_id <> FND_API.G_MISS_NUM) THEN

         l_shipping_unique_key1  :=  'SHIP_SET';
         l_shipping_param1       :=  p_x_line_rec.ship_set_id;

       ELSIF (p_x_line_rec.top_model_line_id  IS NOT NULL AND
              p_x_line_rec.top_model_line_id <> FND_API.G_MISS_NUM) AND
              nvl(p_x_line_rec.model_remnant_flag,'N') = 'N' THEN

         l_shipping_unique_key1  :=  'PTO_KIT';
         l_shipping_param1       :=  p_x_line_rec.top_model_line_id;

       ELSIF (p_x_line_rec.ato_line_id IS NOT NULL AND
              p_x_line_rec.ato_line_id <> FND_API.G_MISS_NUM) AND
              p_x_line_rec.item_type_code = Oe_Globals.G_ITEM_CONFIG AND
              nvl(p_x_line_rec.model_remnant_flag,'N') = 'N' THEN
         l_shipping_unique_key1  :=  'ATO';
         l_shipping_param1       :=  p_x_line_rec.line_id;
       ELSE
         l_shipping_unique_key1  :=  p_x_line_rec.item_type_code;
         l_shipping_param1       :=  p_x_line_rec.line_id;
       END IF;

	   -- Log a delayed request for Ship Confirmation
      if l_debug_level > 0 then
        oe_debug_pub.ADD('Ship Confirmation : logging delayed request for '|| l_shipping_unique_key1 || l_shipping_param1,1);
      end if;

		OE_Delayed_Requests_Pvt.Log_Request(
		p_entity_code				=>	OE_GLOBALS.G_ENTITY_LINE,
		p_entity_id					=>	p_x_line_rec.line_id,
		p_requesting_entity_code	=>	OE_GLOBALS.G_ENTITY_LINE,
		p_requesting_entity_id  	=>	p_x_line_rec.line_id,
		p_request_type				=>	OE_GLOBALS.G_SHIP_CONFIRMATION,
		p_request_unique_key1		=>	l_shipping_unique_key1,
		p_param1             		=>	l_shipping_param1,
		x_return_status				=>	l_return_status);

		END IF;

    END IF;



    IF NOT OE_GLOBALS.Equal(p_x_line_rec.invoice_interface_status_code, p_old_line_rec.invoice_interface_status_code)
    THEN
        IF p_x_line_rec.invoice_interface_status_code = 'YES' THEN
           p_x_line_rec.flow_status_code := 'INVOICED';
         if l_debug_level > 0 then
           oe_debug_pub.add('sam: flow_status_code is ' || p_x_line_rec.flow_status_code);
         end if;
        ELSIF p_x_line_rec.invoice_interface_status_code = 'RFR-PENDING' THEN
           p_x_line_rec.flow_status_code := 'INVOICED_PARTIAL';
         if l_debug_level > 0 then
           oe_debug_pub.add('sam: flow_status_code is ' || p_x_line_rec.flow_status_code);
          end if;
        END IF;

    END IF;


    IF NOT OE_GLOBALS.Equal(p_x_line_rec.open_flag, p_old_line_rec.open_flag)
    THEN
	IF p_x_line_rec.open_flag = 'N' THEN
	 	p_x_line_rec.flow_status_code := 'CLOSED';
                IF p_x_line_rec.cancelled_flag = 'Y' THEN
                   p_x_line_rec.flow_status_code := 'CANCELLED';
                END IF;
              if l_debug_level > 0 then
	 	oe_debug_pub.add('sam: flow_status_code is ' || p_x_line_rec.flow_status_code);
              end if;
	 	p_x_line_rec.calculate_price_flag := 'N';
	END IF;

    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_line_rec.cancelled_flag, p_old_line_rec.cancelled_flag)
    THEN
	IF p_x_line_rec.cancelled_flag = 'Y' THEN
		 p_x_line_rec.flow_status_code := 'CANCELLED';
               if l_debug_level > 0 then
		 oe_debug_pub.add('sam: flow_status_code is ' || p_x_line_rec.flow_status_code);
               end if;
	 	 p_x_line_rec.calculate_price_flag := 'N';
	END IF;

    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_line_rec.ship_from_org_id,p_old_line_rec.ship_from_org_id)
    THEN
	   -- BUG 1491504 BEGIN -- INVCONV  stet
	   -- Warehouse data CAN determine whether the line is treated as process or discrete OR SINGLE uom OR dUAL uom CONTROLLED .
	   -- Warehouse data can impact quantity calculations, so check the quantites here
	   -- pal
	   OE_Line_Util.Sync_Dual_Qty (p_x_line_rec => p_x_line_rec
                                   ,p_old_line_rec => p_old_line_rec);
        -- Check to see if either the primary or secondary quantity has changed
	   -- If there is a change, make a recursive call to OE_Order_Pvt.Lines
        IF p_x_line_rec.ordered_quantity <> l_ordered_quantity OR
          p_x_line_rec.ordered_quantity2 <> l_ordered_quantity2 THEN
          -- OE_GLOBALS.G_RECURSION_MODE           := 'Y';
	     l_control_rec.controlled_operation    := TRUE;
	     l_control_rec.check_security	        := TRUE;
    	     l_control_rec.clear_dependents 	   := FALSE;
	     l_control_rec.default_attributes      := FALSE;
	     l_control_rec.change_attributes	   := TRUE;
	     l_control_rec.validate_entity	        := FALSE;
    	     l_control_rec.write_to_DB             := FALSE;
    	     l_control_rec.process                 := FALSE;
	     l_old_line_tbl(1) 			        := p_old_line_rec;
          l_line_tbl(1)			             := p_x_line_rec;

          Oe_Order_Pvt.Lines
	     ( p_validation_level	=> FND_API.G_VALID_LEVEL_NONE
          , p_control_rec		=> l_control_rec
          , p_x_line_tbl			=> l_line_tbl
          , p_x_old_line_tbl		=> l_old_line_tbl
	     , x_return_status        => l_return_status
	     );

          -- OE_GLOBALS.G_RECURSION_MODE           := 'N';
          IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
          ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
        END IF;
	   -- BUG 1491504 END
        -- =======================================
        -- Log the request for Tax Calculation
        OE_GLOBALS.G_TAX_FLAG := 'Y';
          -- Need to Call Shipping Update
        l_update_shipping := FND_API.G_TRUE;
        /* may need to call pricing */
        -- For performance bug 1351111, turning off Pricing for scheduling
        /* commenting out for fix 1419204
        l_turn_off_pricing := FND_PROFILE.VALUE('ONT_NO_PRICING_AT_SCHEDULING');
        -- by default, turn off pricing at scheduling
        IF l_turn_off_pricing = 'N' THEN
          OE_GLOBALS.G_PRICE_FLAG := 'Y';
        End If;
        */

       IF ( p_x_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE AND
	    NVL(p_x_line_rec.split_action_code,'X') <> 'SPLIT')
            -- QUOTING change
            AND NVL(p_x_line_rec.transaction_phase_code,'F') = 'F'
       THEN
         if l_debug_level > 0 then
          oe_debug_pub.ADD('ship from update: logging request for eval_hold_source', 1);
          oe_debug_pub.add('line ID: '|| to_char(p_x_line_rec.line_id) ||
               ' Entity ID :'|| to_char(p_x_line_rec.ship_from_org_id), 1);
         end if;

          OE_delayed_requests_Pvt.log_request(
            p_entity_code => OE_GLOBALS.G_ENTITY_LINE,
            p_entity_id              => p_x_line_rec.line_id,
            p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
            p_requesting_entity_id   => p_x_line_rec.line_id,
            p_request_type           => OE_GLOBALS.G_EVAL_HOLD_SOURCE,
            p_request_unique_key1    => 'SHIP_FROM',
            p_param1                 => 'W',
            p_param2                 => p_x_line_rec.ship_from_org_id,
            x_return_status          => l_return_status);

        if l_debug_level > 0 then
          oe_debug_pub.add('return status after logging delayed request '||
                 l_return_status, 1);
        end if;
        END IF;

        -- Freight Rating
        IF OE_Freight_Rating_Util.IS_FREIGHT_RATING_AVAILABLE
           AND OE_Freight_Rating_Util.Get_List_Line_Type_Code
                                      (p_x_line_rec.header_id)
               = 'OM_CALLED_FREIGHT_RATES' THEN
           if l_debug_level > 0 then
             oe_debug_pub.add('Log Freight Rating request for ship from org. ',3);
           end if;
             l_get_FTE_freight_rate := 'Y';
        END IF;

       -- Pack J catchweight
        IF l_debug_level  > 0 THEN
           oe_debug_pub.add('old ship_from_org_id:'|| p_old_line_rec.ship_from_org_id  );
           oe_debug_pub.add('New ship_from_org_id  :'|| p_x_line_rec.ship_from_org_id  );
        END IF;

        IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110510' THEN
           IF p_x_line_rec.ship_from_org_id  IS NOT NULL AND
              p_x_line_rec.ship_from_org_id <> FND_API.G_MISS_NUM THEN
                SELECT wms_enabled_flag
                INTO l_wms_org_flag_new
                FROM mtl_parameters
                WHERE organization_id= p_x_line_rec.ship_from_org_id;
           END IF;
           IF p_old_line_rec.ship_from_org_id  IS NOT NULL AND
              p_old_line_rec.ship_from_org_id <> FND_API.G_MISS_NUM THEN
                SELECT wms_enabled_flag
                INTO l_wms_org_flag_old
                FROM mtl_parameters
                WHERE organization_id= p_old_line_rec.ship_from_org_id;
           END IF;
           IF l_debug_level  > 0 THEN
              oe_debug_pub.add('l_wms_org_flag_new:'|| l_wms_org_flag_new);
              oe_debug_pub.add('l_wms_org_flag_old:'|| l_wms_org_flag_old);
           END IF;
           IF l_wms_org_flag_new <> l_wms_org_flag_old
           AND (l_wms_org_flag_new = 'Y' OR l_wms_org_flag_old = 'Y') THEN -- added for bug 8449058
              OE_GLOBALS.G_PRICE_FLAG := 'Y';
           END IF;
        END IF;
       -- Pack J catchweight


    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_line_rec.subinventory,p_old_line_rec.subinventory)
    THEN
       -- change of subinventory should not require tax or pricing calculation.
       -- or even hold evaluation
	  l_update_shipping := FND_API.G_TRUE;
      if l_debug_level > 0 then
       oe_debug_pub.add('subinventory update',  1);
      end if;
    END IF;


    IF NOT OE_GLOBALS.Equal(p_x_line_rec.ship_model_complete_flag,p_old_line_rec.ship_model_complete_flag)
    THEN
	-- Need to Call Shipping Update
    	l_update_shipping	:= FND_API.G_TRUE;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_line_rec.ship_set_id,p_old_line_rec.ship_set_id)
    THEN
	-- Need to Call Shipping Update
    	l_update_shipping	:= FND_API.G_TRUE;

    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_line_rec.ship_set,p_old_line_rec.ship_set)
    THEN

	NULL;

    END IF;


    IF NOT OE_GLOBALS.Equal(p_x_line_rec.ship_tolerance_above,p_old_line_rec.ship_tolerance_above)
    THEN
	-- Need to Call Shipping Update
    	l_update_shipping	:= FND_API.G_TRUE;
    END IF;

    -- Changes for Bug-2579571

    IF NOT OE_GLOBALS.Equal(p_x_line_rec.line_set_id,p_old_line_rec.line_set_id)
    THEN
        -- Need to Call Shipping Update
        l_update_shipping       := FND_API.G_TRUE;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_line_rec.ship_tolerance_below,p_old_line_rec.ship_tolerance_below)
    THEN
	-- Need to Call Shipping Update
    	l_update_shipping	:= FND_API.G_TRUE;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_line_rec.ship_to_contact_id,p_old_line_rec.ship_to_contact_id)
    THEN
	-- Need to Call Shipping Update
    	l_update_shipping	:= FND_API.G_TRUE;
	-- Call Pricing
     -- OE_GLOBALS.G_PRICE_FLAG := 'Y'; Commented out for fix 1419204

    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_line_rec.ship_to_org_id,p_old_line_rec.ship_to_org_id)
    THEN
	-- Log the request for Tax Calculation
        OE_GLOBALS.G_TAX_FLAG := 'Y';
	-- Need to Call Shipping Update
    	l_update_shipping	:= FND_API.G_TRUE;
        /* may need to call pricing */
          OE_GLOBALS.G_PRICE_FLAG := 'Y';

	--Customer Acceptance
        l_def_contingency_attributes := FND_API.G_TRUE;  --added for BUG#11937680

          IF p_x_line_rec.commitment_id IS NOT NULL THEN
            l_get_commitment_bal := 'Y';
          END IF;

          IF OE_Freight_Rating_Util.IS_FREIGHT_RATING_AVAILABLE
             AND OE_Freight_Rating_Util.Get_List_Line_Type_Code
                                        (p_x_line_rec.header_id)
                 = 'OM_CALLED_FREIGHT_RATES' THEN
             if l_debug_level > 0 then
               oe_debug_pub.add('Log Freight Rating request for ship to org. ',3);
             end if;
               l_get_FTE_freight_rate := 'Y';
          END IF;

     IF ( p_x_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE AND
	   NVL(p_x_line_rec.split_action_code,'X') <> 'SPLIT')
           -- QUOTING change
           AND NVL(p_x_line_rec.transaction_phase_code,'F') = 'F'
     THEN
         if l_debug_level > 0 then
           oe_debug_pub.ADD('ship to update: logging request for eval_hold_source', 1);
           oe_debug_pub.add('line ID: '|| to_char(p_x_line_rec.line_id) ||
	           ' Entity ID :'|| to_char(p_x_line_rec.ship_to_org_id), 1);
         end if;
         OE_delayed_requests_Pvt.log_request(
                  p_entity_code => OE_GLOBALS.G_ENTITY_LINE,
                  p_entity_id         => p_x_line_rec.line_id,
                  p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
                  p_requesting_entity_id         => p_x_line_rec.line_id,
                  p_request_type      => OE_GLOBALS.G_EVAL_HOLD_SOURCE,
                  p_request_unique_key1 => 'SHIP_TO',
                  p_param1		 => 'S',
                  p_param2		 => p_x_line_rec.ship_to_org_id,
                  x_return_status     => l_return_status);

         if l_debug_level > 0 then
          oe_debug_pub.add('return status after logging delayed request '||
                         p_x_line_rec.return_status, 1);
         end if;
     END IF;

    END IF;



    IF NOT OE_GLOBALS.Equal(p_x_line_rec.sold_to_org_id,p_old_line_rec.sold_to_org_id)
    THEN

	-- Need to Call Shipping Update
    	l_update_shipping	:= FND_API.G_TRUE;
	--Customer Acceptance
        l_def_contingency_attributes := FND_API.G_TRUE;

       if l_debug_level > 0 then
        oe_debug_pub.add('In Apply Atrributes:Sold To', 1);
        oe_debug_pub.add('Return Status before is : '||p_x_line_rec.return_status, 1);
       end if;

	-- Call Pricing
        OE_GLOBALS.G_PRICE_FLAG := 'Y';


        -- bug 1829201, need to recalculate commitment.
        IF p_x_line_rec.commitment_id is not null then
         l_calculate_commitment_flag := 'Y';
        END IF;

        IF (p_old_line_rec.sold_to_org_id IS NOT NULL AND
            p_x_line_rec.sold_to_org_id <> FND_API.G_MISS_NUM) THEN
          IF p_x_line_rec.item_identifier_type = 'CUST' THEN
             IF (p_x_line_rec.ordered_item_id IS NOT NULL AND
                 p_x_line_rec.ordered_item_id <> FND_API.G_MISS_NUM) THEN
               if l_debug_level > 0 then
                oe_debug_pub.add('old sold_to is' || to_char(p_old_line_rec.sold_to_org_id), 1);
                oe_debug_pub.add('new sold_to is' || to_char(p_x_line_rec.sold_to_org_id), 1);
               end if;
                fnd_message.set_name('ONT','OE_CUSTOMER_ITEM_EXIST');
                OE_MSG_PUB.Add;
                p_x_line_rec.return_status := FND_API.G_RET_STS_ERROR;
             END IF;
          END IF;
        END IF;
       if l_debug_level > 0 then
        oe_debug_pub.add('Return Status after is : '||p_x_line_rec.return_status, 1);
       end if;

        if p_x_line_rec.commitment_id is not null then
          l_get_commitment_bal := 'Y';
        end if;

    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_line_rec.source_document_type_id,p_old_line_rec.source_document_type_id)
    THEN

	If p_x_line_rec.source_document_type_id = 2 Then
          --
        -- bug 1917869
	IF p_x_line_rec.calculate_price_flag in ('N','P') then
  	  l_copy_adjustments := TRUE;
        END IF;

	  l_copy_pricing_attributes := TRUE;

          -- commented out for 1819133
          /***
          IF (NOT OE_GLOBALS.Equal(p_x_line_rec.inventory_item_id,p_old_line_rec.inventory_item_id)) OR (NOT OE_GLOBALS.Equal(p_x_line_rec.ordered_item_id,p_old_line_rec.ordered_item_id)) THEN
            p_x_line_rec.calculate_price_flag := 'Y';
            OE_GLOBALS.G_PRICE_FLAG := 'Y';
          END IF;
          ***/

	End If;
        --
      --Customer Acceptance
       l_def_contingency_attributes := FND_API.G_TRUE;

    END IF;
    --

    -- SAO
           IF p_x_line_rec.line_category_code <> 'RETURN'
                 and p_x_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE
                 and p_x_line_rec.split_by = 'SYSTEM'
                 and NVL(p_x_line_rec.split_action_code,'X') = 'SPLIT'
                 and p_x_line_rec.calculate_price_flag = 'Y' Then
                   p_x_line_rec.calculate_price_flag :='P';
           End IF;


    IF NOT OE_GLOBALS.Equal(p_x_line_rec.split_from_line_id,p_old_line_rec.split_from_line_id)
    THEN

	   -- Do not attempt to copy the adjustments for the parent line
	   IF p_x_line_rec.operation = oe_globals.g_opr_create THEN
	      l_copy_adjustments := TRUE;
	      l_copy_pricing_attributes := TRUE;

           IF p_x_line_rec.split_by = 'SYSTEM'
           THEN
               p_x_line_rec.calculate_price_flag := 'N';

               IF l_charges_for_backorders = 'Y' AND
                  p_x_line_rec.line_category_code <> 'RETURN'   /* For bug#2680291 */
		   AND nvl(p_x_line_rec.order_source_id,-1) <>  10 --added for the FP bug 3709662

               THEN
		   IF l_debug_level > 0 THEN
		       oe_debug_pub.add('pviprana: the price_flag is changing to P here and order_source_id is '||p_x_line_rec.order_source_id);
		        --oe_debug_pub.add('pviprana: order_source_id is ' ||p_x_line_rec.order_source_id);
                   END IF;
	     	       p_x_line_rec.calculate_price_flag := 'P';
               END IF;

               /*Bug#5026401 - For RMA split lines, set the flag to 'P', if the original line's
                 calculate_price_flag is 'P' or 'Y' and if the profile option OM: Charges for Back
                 orders is set to 'Yes'.
               */
               IF l_charges_for_backorders = 'Y' AND
                  p_x_line_rec.line_category_code = 'RETURN' AND
                  p_x_line_rec.split_from_line_id IS NOT NULL
               THEN
                  BEGIN
                     SELECT calculate_price_flag
                     INTO l_orig_line_calc_price_flag
                     FROM OE_ORDER_LINES_ALL
                     WHERE LINE_ID = p_x_line_rec.split_from_line_id;
                  EXCEPTION
                     WHEN OTHERS THEN
                        l_orig_line_calc_price_flag := NULL;
                  END;
                  oe_debug_pub.add('Bug#5026401 l_orig_line_calc_price_flag:'||l_orig_line_calc_price_flag);
                  IF NVL(l_orig_line_calc_price_flag,'N') IN ('Y','P')
                  THEN
                     p_x_line_rec.calculate_price_flag := 'P';
                  END IF;
               END IF;
               oe_debug_pub.add('Bug#5026401 p_x_line_rec.calculate_price_flag:'|| p_x_line_rec.calculate_price_flag);
               /* Bug#5026401 - End */

           END IF;
	   END IF;

	   If p_x_line_rec.split_by = 'SYSTEM' then
	   -- Do not reprice the lines when the split is system
              --changes for bug 2315926 Begin
                    /*    If l_charges_for_backorders = 'N' Then
			  l_no_price_flag := TRUE;
                        Else
                          l_no_price_flag := FALSE;
                        End If;
                       */
         	  l_no_price_flag := TRUE;
              --changes for bug 2315926  end
	   --Elsif p_x_line_rec.split_by = 'USER' Then
               -- Bug 1313728
               -- User split should keep the original calculate_price_flag
		--	p_x_line_rec.calculate_price_flag:='P';
	   End If;

    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_line_rec.tax_code,p_old_line_rec.tax_code)
    THEN
        OE_GLOBALS.G_TAX_FLAG := 'Y';

        IF p_x_line_rec.commitment_id IS NOT NULL THEN
          l_get_commitment_bal := 'Y';
        END IF;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_line_rec.tax_date,p_old_line_rec.tax_date)
    THEN
        OE_GLOBALS.G_TAX_FLAG := 'Y';

        IF p_x_line_rec.commitment_id IS NOT NULL THEN
          l_get_commitment_bal := 'Y';
        END IF;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_line_rec.tax_exempt_flag,p_old_line_rec.tax_exempt_flag)
    THEN
        OE_GLOBALS.G_TAX_FLAG := 'Y';

        IF p_x_line_rec.commitment_id IS NOT NULL THEN
          l_get_commitment_bal := 'Y';
        END IF;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_line_rec.tax_exempt_number,p_old_line_rec.tax_exempt_number)
    THEN
	   -- Log the request for Tax Calculation
        OE_GLOBALS.G_TAX_FLAG := 'Y';

        IF p_x_line_rec.commitment_id IS NOT NULL THEN
          l_get_commitment_bal := 'Y';
        END IF;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_line_rec.tax_exempt_reason_code,p_old_line_rec.tax_exempt_reason_code)
    THEN
	   -- Log the request for Tax Calculation
        OE_GLOBALS.G_TAX_FLAG := 'Y';

        IF p_x_line_rec.commitment_id IS NOT NULL THEN
          l_get_commitment_bal := 'Y';
        END IF;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_line_rec.tax_value,p_old_line_rec.tax_value)
    THEN

	IF p_x_line_rec.commitment_id is NOT NULL THEN
	   l_calculate_commitment_flag := 'Y';

      	END IF;

        IF p_x_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE THEN
	  -- Log Verify Payment only if the Tax Value has
	  -- Increased AND Payment Type Code is Credit Card.
	  IF  p_x_line_rec.tax_value > p_old_line_rec.tax_value AND
              OE_Order_Cache.g_header_rec.payment_type_code = 'CREDIT_CARD' THEN
             -- Set flag to log Verify Payment Delayed Request
            if l_debug_level > 0 then
             oe_debug_pub.ADD('Log Verify Payment delayed request in Tax Value');
            end if;
	     l_verify_payment_flag := 'Y';

           ELSIF OE_PrePayment_UTIL.is_prepaid_order(p_x_line_rec.header_id)
                      = 'Y' AND p_x_line_rec.booked_flag ='Y' THEN
             -- if this is a prepaid order, also log delayed request if ordered
             -- quantity decreases, as refund may need to be issued.
            if l_debug_level > 0 then
             oe_debug_pub.ADD('Log Verify Payment delayed request in Tax Value for prepayment', 3);
            end if;
	     l_verify_payment_flag := 'Y';
           END IF;
         END IF;

    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_line_rec.top_model_line_id,p_old_line_rec.top_model_line_id)
    THEN
		-- Need to Call Shipping Update
    	l_update_shipping	:= FND_API.G_TRUE;

      --Customer Acceptance
       l_def_contingency_attributes := FND_API.G_TRUE;

    END IF;
    -- Bug 3418496
    IF NOT OE_GLOBALS.Equal(p_x_line_rec.unit_list_price,p_old_line_rec.unit_list_price) THEN
       IF( p_x_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE
         AND p_x_line_rec.booked_flag ='Y') THEN
         -- Log Delayed Request for Verify Payment
        if l_debug_level > 0 then
         oe_debug_pub.ADD('log verify payment delayed request for change in List price');
        end if;
         l_verify_payment_flag := 'Y';
       END IF;
    END IF;
    /* Fixed bug 1889762
       If the new selling price is NULL AND old selling price is NOT NULL Then
	 Reprice the line
       End if;
    */
    IF NOT OE_GLOBALS.Equal(p_x_line_rec.unit_selling_price,p_old_line_rec.unit_selling_price)
    THEN

        l_3a7_attribute_change := FND_API.G_TRUE;
        IF (p_x_line_rec.unit_selling_price is NULL And
           p_old_line_rec.unit_selling_price is NOT NULL) Then
           if l_debug_level > 0 then
	    oe_debug_pub.add('User has cleared unit selling price');
	    oe_debug_pub.add('Just Reprice');
           end if;
            --Oe_Line_Adj_Util.Delete_Row(p_line_id=>p_x_line_rec.line_id); 7363196
            OE_GLOBALS.G_PRICE_FLAG := 'Y';
	    p_x_line_rec.unit_list_price := NULL;
	    p_x_line_rec.unit_list_price_per_pqty := NULL;
        End if;

        OE_GLOBALS.G_TAX_FLAG := 'Y';
        IF p_x_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE THEN
	   -- Additional task : Log Verify Payment always when the payment Type
	   -- code is not CREDIT CARD. For CREDIT CARD, log this request only if
	   -- the Unit Selling Price has increased.

	  IF OE_Order_Cache.g_header_rec.payment_type_code = 'CREDIT_CARD' THEN
	    IF  p_x_line_rec.unit_selling_price > p_old_line_rec.unit_selling_price
		then
               -- Log request here if commitment id is null
               IF p_x_line_rec.commitment_id is null THEN
                  -- if it is not a prepaid order, log Verify Payment delayed request.
                  -- if it is a prepaid order, check the shipped_quantity to make
                  -- sure to not collect fund again during repricing at shipment.

                  IF OE_PrePayment_UTIL.is_prepaid_order(p_x_line_rec.header_id) = 'N'
                     OR (OE_PrePayment_UTIL.is_prepaid_order(p_x_line_rec.header_id)
                         = 'Y' AND p_x_line_rec.booked_flag ='Y'
                         AND p_x_line_rec.shipped_quantity IS NULL) THEN
                   if l_debug_level > 0 then
            	    oe_debug_pub.ADD('Log Verify Payment delayed request in Selling Price');
                   end if;
		    l_verify_payment_flag := 'Y';
                  END IF;
	        END IF;
             ELSIF OE_PrePayment_UTIL.is_prepaid_order(p_x_line_rec.header_id)
                    = 'Y'  AND p_x_line_rec.booked_flag ='Y'
                    AND p_x_line_rec.shipped_quantity IS NULL THEN
               -- if this is a prepaid order, also log delayed request if selling
               -- price decreases, as refund may need to be issued.
              if l_debug_level > 0 then
	       oe_debug_pub.ADD('Log Verify Payment delayed request for change in Selling Price for prepayment', 3);
              end if;
	       l_verify_payment_flag := 'Y';
             END IF;
	   ELSE
	     IF p_x_line_rec.booked_flag ='Y' THEN
               if l_debug_level > 0 then
	        oe_debug_pub.ADD('Log Verify Payment delayed request for change in Selling Price');
               end if;
	        l_verify_payment_flag := 'Y';
	   END IF;
         END IF;

        END IF;

        IF p_x_line_rec.commitment_id is not null then
	  l_calculate_commitment_flag := 'Y';
        END IF;

    END IF;

/* csheu -- bug #1533658 S*/

    IF NOT OE_GLOBALS.Equal(p_x_line_rec.service_start_date,p_old_line_rec.service_start_date)

    THEN
	    -- Call Pricing
        if l_debug_level > 0 then
	 oe_debug_pub.add('CSH- service start_date is changed');
        end if;
         OE_GLOBALS.G_PRICE_FLAG := 'Y';
	 l_copy_service_fields := TRUE;

         IF p_x_line_rec.commitment_id IS NOT NULL THEN
           l_get_commitment_bal := 'Y';
         END IF;
          --BUG#11655793
	 	IF (p_x_line_rec.item_type_code = 'SERVICE') THEN
	 		oe_debug_pub.add('Calling OE_SERVICE_UTIL.Get_Service_Duration for change in service start date');
	 		      OE_SERVICE_UTIL.Get_Service_Duration
	 				(x_return_status => l_return_status
	 				 , p_x_line_rec    => p_x_line_rec);

	 		      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	 			    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	 		      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	 			     RAISE FND_API.G_EXC_ERROR;
	 		       END IF;
	 	END IF;
	 --BUG#11655793
    END IF;


    IF NOT OE_GLOBALS.Equal(p_x_line_rec.service_end_date,p_old_line_rec.service_end_date)

    THEN
        if l_debug_level > 0 then
	 oe_debug_pub.add('CSH- service end_date is changed');
        end if;
	 -- Call Pricing
         OE_GLOBALS.G_PRICE_FLAG := 'Y';
	 l_copy_service_fields := TRUE;

         IF p_x_line_rec.commitment_id IS NOT NULL THEN
           l_get_commitment_bal := 'Y';
         END IF;
          --BUG#11655793
	 	IF (p_x_line_rec.item_type_code = 'SERVICE') THEN
	 		oe_debug_pub.add('Calling OE_SERVICE_UTIL.Get_Service_Duration for change in service end date');
	 		      OE_SERVICE_UTIL.Get_Service_Duration
	 				(x_return_status => l_return_status
	 				 , p_x_line_rec    => p_x_line_rec);

	 		      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	 			    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	 		      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	 			     RAISE FND_API.G_EXC_ERROR;
	 		       END IF;
	 	END IF;
	 --BUG#11655793
    END IF;

/* csheu -- bug #1533658 E*/

    IF NOT OE_GLOBALS.Equal(p_x_line_rec.service_duration,p_old_line_rec.service_duration)

    THEN
	    -- Call Pricing
         OE_GLOBALS.G_PRICE_FLAG := 'Y';
/* csheu -- bug #1533658 s*/
        if l_debug_level > 0 then
         oe_debug_pub.add('CSH- service duration is changed');
        end if;
         l_copy_service_fields := TRUE;
/* csheu -- bug #1533658 e*/

         IF p_x_line_rec.commitment_id IS NOT NULL THEN
           l_get_commitment_bal := 'Y';
         END IF;
          --BUG#11655793
	 	IF (p_x_line_rec.item_type_code = 'SERVICE') THEN
	 		oe_debug_pub.add('Calling OE_SERVICE_UTIL.Get_Service_Duration for change in service Duration');
	 		      OE_SERVICE_UTIL.Get_Service_Duration
	 				(x_return_status => l_return_status
	 				 , p_x_line_rec    => p_x_line_rec);

	 		      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	 			    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	 		      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	 			     RAISE FND_API.G_EXC_ERROR;
	 		       END IF;
	 	END IF;
	 --BUG#11655793
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_line_rec.service_period,p_old_line_rec.service_period)
    THEN
        -- Reprice the Line
        OE_GLOBALS.G_PRICE_FLAG := 'Y';

        IF p_x_line_rec.commitment_id IS NOT NULL THEN
          l_get_commitment_bal := 'Y';
        END IF;

/* csheu -- bug #1533658 s*/
       if l_debug_level > 0 then
        oe_debug_pub.add('CSH- service period is changed');
       end if;
        l_copy_service_fields := TRUE;
/* csheu -- bug #1533658 e*/
        --BUG#11655793
		IF (p_x_line_rec.item_type_code = 'SERVICE') THEN
			oe_debug_pub.add('Calling OE_SERVICE_UTIL.Get_Service_Duration for change in service Period');
			      OE_SERVICE_UTIL.Get_Service_Duration
					(x_return_status => l_return_status
					 , p_x_line_rec    => p_x_line_rec);

			      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
				    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
				    RAISE FND_API.G_EXC_ERROR;
			      END IF;
	       END IF;
       --BUG#11655793
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_line_rec.service_reference_line_id,p_old_line_rec.service_reference_line_id)

    THEN
       if l_debug_level > 0 then
	 oe_debug_pub.add('JPN: line id is: ' || to_char(p_x_line_rec.line_id));
	 oe_debug_pub.add('JPN: Serviced line id is: ' || to_char(p_x_line_rec.service_reference_line_id));
       end if;

-- The IF condition on source_type_document_type_id is being
-- commented for bug 2372098

--      IF (p_x_line_rec.source_document_type_id = 2) THEN
--	    NULL; /* do nothing for copy order */
--      ELSE /* cascade the service line to options */

	IF (nvl(p_x_line_rec.source_document_type_id,-99) <> 2) THEN  -- for bug 2494517, 2567242(nvl condition)

	   /* Call to retrieve service reference information */

	   IF (p_x_line_rec.item_type_code = 'SERVICE') THEN

	     OE_SERVICE_UTIL.Get_Service_Attribute
                             (x_return_status => l_return_status
                             , p_x_line_rec    => p_x_line_rec
                             );

         if l_debug_level > 0 then
          oe_debug_pub.add('AKS: Service num is: ' || to_char(p_x_line_rec.service_number));
          oe_debug_pub.add('UTIL call: Line num is: ' || to_char(p_x_line_rec.line_number));
         end if;

          IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
          END IF;

          OE_SERVICE_UTIL.Get_Service_Duration
                        (x_return_status => l_return_status
                         , p_x_line_rec    => p_x_line_rec);

          IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
          END IF;

	   END IF; /* End of item_type_code */

	 END IF; /* source_document_type_id */

/* hashraf bug # 2757859 */

    IF NOT OE_GLOBALS.Equal(p_x_line_rec.ordered_quantity,p_old_line_rec.ordered_quantity) THEN
         OE_GLOBALS.G_PRICE_FLAG := 'Y';
    END IF;

/* end of 2757859 */



        IF p_x_line_rec.service_reference_type_code  = 'ORDER' THEN
	     BEGIN

     	  Select 'Y'
     	  INTO   l_is_model
     	  FROM   oe_order_lines
     	  WHERE  line_id = p_x_line_rec.service_reference_line_id
     	  AND    item_type_code in ('INCLUDED', 'MODEL', 'CLASS', 'OPTION', 'KIT') ; -- Included KIT Item Type Code for bug 2938790

          EXCEPTION
          WHEN OTHERS THEN
            l_is_model := 'N';
          END;

-- Added for bug 2372098. The IF condition below would set the flag
-- l_is_model to Y, if the configuration has any serviceable
-- INCLUDED items. This check is for copied service lines.

	   IF (p_x_line_rec.source_document_type_id = 2 AND l_is_model = 'Y') THEN
            if l_debug_level > 0 then
              oe_debug_pub.add( 'This is a copied service line', 5 );
            end if;
	      BEGIN
		 Select 'Y'
		   INTO   l_is_model
		   FROM   oe_order_lines l
		   WHERE  top_model_line_id = p_x_line_rec.service_reference_line_id
		   AND    item_type_code = 'INCLUDED'
 		   AND    exists (select null from mtl_system_items mtl where
 				  mtl.inventory_item_id = l.inventory_item_id and
 				  mtl.serviceable_product_flag = 'Y' and
 				  mtl.organization_id=OE_SYS_PARAMETERS.VALUE('MASTER_ORGANIZATION_ID') )
		   AND    ROWNUM = 1;

	      EXCEPTION
		 WHEN OTHERS THEN
		    l_is_model := 'N';
	      END;
	   END IF; /* source_document_id = 2 and l_is_model = 'Y'*/

-- end 2372098


            /* Log the service delayed request only if it is not a split. */
            /* Fix for Bug 1802612 */

           if l_debug_level > 0 then
	     oe_debug_pub.ADD('SERVICE: Logging delayed request ');
	     oe_debug_pub.ADD('JPN: What type of item: '|| l_is_model);
             oe_debug_pub.add('Split action code:' || p_x_line_rec.split_action_code);
             oe_debug_pub.add('Operation:' || p_x_line_rec.operation);
             oe_debug_pub.add('Split from line:' || p_x_line_rec.split_from_line_id);
           end if;

             IF NOT (( NVL(p_x_line_rec.split_action_code,'X') = 'SPLIT' and
                           p_x_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE) or
                          (p_x_line_rec.operation = OE_GLOBALS.G_OPR_CREATE and
                           p_x_line_rec.split_from_line_id is NOT NULL)) then


	     IF p_x_line_rec.service_reference_type_code = 'ORDER' and
		  p_x_line_rec.service_reference_line_id is NOT NULL and
		  (p_x_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE or
		  p_x_line_rec.operation = OE_GLOBALS.G_OPR_CREATE) and
		  l_is_model = 'Y' THEN
		  OE_Delayed_Requests_Pvt.log_request(
					p_entity_code => OE_GLOBALS.G_ENTITY_LINE,
					p_entity_id   => p_x_line_rec.line_id,
					p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
					p_requesting_entity_id   => p_x_line_rec.line_id,
					p_request_type   => OE_GLOBALS.G_INSERT_SERVICE,
					x_return_status  => l_return_status);
	     END IF; /* delayed request */
        END IF; /* service_reference_type_code = ORDER */
       END IF;  /*  Check if not split */
-- commented for bug 2372098
--      END IF; /* not from copy order */
    END IF; /* service_reference_line_id not equal */

/*lchen -- bug #1761154 start*/
--For bug 2447402, added INCLUDED, KIT item_type_codes in the IF condition

    IF (p_x_line_rec.item_type_code = 'OPTION' OR
        p_x_line_rec.item_type_code = 'CLASS' OR
        p_x_line_rec.item_type_code = 'INCLUDED' OR
        p_x_line_rec.item_type_code = 'KIT' ) and p_x_line_rec.top_model_line_id is NOT NULL then

   IF NOT (( NVL(p_x_line_rec.split_action_code,'X') = 'SPLIT' and
            p_x_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE) or
            (p_x_line_rec.operation = OE_GLOBALS.G_OPR_CREATE and
            p_x_line_rec.split_from_line_id is NOT NULL)) then

     IF p_x_line_rec.operation = OE_GLOBALS.G_OPR_CREATE
     THEN
    if l_debug_level > 0 then
     oe_debug_pub.ADD('operation : '|| p_x_line_rec.operation);
     oe_debug_pub.ADD('inventory_item_id : '|| p_x_line_rec.inventory_item_id);
    end if;
     BEGIN
       select distinct 'Y'
       into l_serviceable_item
       from mtl_system_items mtl
       where mtl.inventory_item_id = p_x_line_rec.inventory_item_id
      and mtl.organization_id=OE_SYS_PARAMETERS.VALUE('MASTER_ORGANIZATION_ID')
      and mtl.serviceable_product_flag='Y';
   -- lchen added check for organizations to fix bug 2039304

      EXCEPTION
      WHEN OTHERS THEN
         l_serviceable_item := 'N';
     END;

     if l_debug_level > 0 then
      oe_debug_pub.ADD('serviceable option :  '|| l_serviceable_item);

      oe_debug_pub.ADD('service_reference_line_id:  '|| p_x_line_rec.top_model_line_id);
     end if;

       IF l_serviceable_item = 'Y' THEN
         BEGIN
          select distinct 'Y'
          into l_serviced_model
          from oe_order_lines
          where item_type_code = 'SERVICE'
          and service_reference_line_id = p_x_line_rec.top_model_line_id
          and service_reference_type_code = 'ORDER';

          EXCEPTION
          WHEN OTHERS THEN
             l_serviced_model := 'N';
          END;

         if l_debug_level > 0 then
          oe_debug_pub.ADD('serviced model :  '|| l_serviced_model);
         end if;

          IF l_serviced_model = 'Y' THEN
            if l_debug_level > 0 then
              oe_debug_pub.add('Before log delayed request -- G_CASCADE_OPTIONS_SERVICE',1);
            end if;
              OE_Delayed_Requests_Pvt.log_request(
					p_entity_code => OE_GLOBALS.G_ENTITY_LINE,
					p_entity_id   => p_x_line_rec.line_id,
					p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
					p_requesting_entity_id   => p_x_line_rec.line_id,
					p_request_type   => OE_GLOBALS.G_CASCADE_OPTIONS_SERVICE,
					x_return_status  => l_return_status);

	   END IF; /* delayed request -- G_CASCADE_OPTIONS_SERVICE  */
       END IF; /*l_serviceable_item = 'Y' */
     END IF; /*operation = CREATE */
   END IF; /* check if not split */
 END IF; /* item_type_code='OPTION' or 'CLASS'*/

    -- oe_debug_pub.add(' out of cascade option condition',1);

/*lchen -- bug #1761154 end*/

   /* End of service related columns */

    IF NOT OE_GLOBALS.Equal(p_x_line_rec.shipping_instructions,p_old_line_rec.shipping_instructions)
    THEN
		-- Need to Call Shipping Update
    	l_update_shipping	:= FND_API.G_TRUE;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_line_rec.packing_instructions,p_old_line_rec.packing_instructions)
    THEN
		-- Need to Call Shipping Update
    	l_update_shipping	:= FND_API.G_TRUE;
    END IF;

   -- Added for the bug 2939731

   IF NOT OE_GLOBALS.Equal(p_x_line_rec.ordered_item_id,p_old_line_rec.ordered_item_id)
    THEN
        -- Need to Call Shipping Update
        l_update_shipping       := FND_API.G_TRUE;
   END IF;


-- adding check for changes in project/task

   IF NOT OE_GLOBALS.Equal(p_x_line_rec.project_id,p_old_line_rec.project_id)
    THEN
        -- Need to Call Shipping Update
        l_update_shipping       := FND_API.G_TRUE;
   END IF;


   IF NOT OE_GLOBALS.Equal(p_x_line_rec.task_id,p_old_line_rec.task_id)
    THEN
        -- Need to Call Shipping Update
        l_update_shipping       := FND_API.G_TRUE;
   END IF;


--ER#7479609 start
    IF NOT OE_GLOBALS.Equal(p_x_line_rec.created_by,p_old_line_rec.created_by)
       AND p_x_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE
       AND NVL(p_x_line_rec.split_action_code,'X') <> 'SPLIT'
       AND NVL(p_x_line_rec.transaction_phase_code,'F') = 'F'
    THEN
          IF l_debug_level > 0 then
             oe_debug_pub.ADD('created By update: logging request for eval_hold_source');
             oe_debug_pub.ADD('line ID: '|| to_char(p_x_line_rec.line_id)||
		             ' Entity ID: '|| to_char(p_x_line_rec.created_by));
          END IF;

          OE_delayed_requests_Pvt.log_request(
                    p_entity_code => OE_GLOBALS.G_ENTITY_LINE,
                    p_entity_id         => p_x_line_rec.line_id,
		    p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
		    p_requesting_entity_id         => p_x_line_rec.line_id,
                    p_request_type      => OE_GLOBALS.G_EVAL_HOLD_SOURCE,
                    p_request_unique_key1 => 'CREATED_BY',
                    p_param1		 => 'CB',
                    p_param2		 => p_x_line_rec.created_by,
                    x_return_status     => l_return_status);
   END IF;

    IF NOT OE_GLOBALS.Equal(p_x_line_rec.creation_date,p_old_line_rec.creation_date)
       AND p_x_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE
       AND NVL(p_x_line_rec.split_action_code,'X') <> 'SPLIT'
       AND NVL(p_x_line_rec.transaction_phase_code,'F') = 'F'
    THEN
          IF l_debug_level > 0 then
             oe_debug_pub.ADD('Creation date update: logging request for eval_hold_source');
             oe_debug_pub.ADD('line ID: '|| to_char(p_x_line_rec.line_id)||
		             ' Entity ID: '|| to_char(p_x_line_rec.creation_date));
          END IF;

          OE_delayed_requests_Pvt.log_request(
                    p_entity_code => OE_GLOBALS.G_ENTITY_LINE,
                    p_entity_id         => p_x_line_rec.line_id,
		    p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
		    p_requesting_entity_id         => p_x_line_rec.line_id,
                    p_request_type      => OE_GLOBALS.G_EVAL_HOLD_SOURCE,
                    p_request_unique_key1 => 'CREATION_DATE',
                    p_param1		 => 'CD',
                    p_param2		 => p_x_line_rec.creation_date,
                    x_return_status     => l_return_status);
   END IF;

    IF NOT OE_GLOBALS.Equal(p_x_line_rec.sold_to_org_id,p_old_line_rec.sold_to_org_id)
       AND p_x_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE
       AND NVL(p_x_line_rec.split_action_code,'X') <> 'SPLIT'
       AND NVL(p_x_line_rec.transaction_phase_code,'F') = 'F'
    THEN
          IF l_debug_level > 0 then
             oe_debug_pub.ADD('Customer update: logging request for eval_hold_source');
             oe_debug_pub.ADD('line ID: '|| to_char(p_x_line_rec.line_id)||
		             ' Entity ID: '|| to_char(p_x_line_rec.sold_to_org_id));
          END IF;

          OE_delayed_requests_Pvt.log_request(
                    p_entity_code => OE_GLOBALS.G_ENTITY_LINE,
                    p_entity_id         => p_x_line_rec.line_id,
		    p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
		    p_requesting_entity_id         => p_x_line_rec.line_id,
                    p_request_type      => OE_GLOBALS.G_EVAL_HOLD_SOURCE,
                    p_request_unique_key1 => 'CUSTOMER',
                    p_param1		 => 'C',
                    p_param2		 => p_x_line_rec.sold_to_org_id,
                    x_return_status     => l_return_status);
   END IF;

    IF NOT OE_GLOBALS.Equal(p_x_line_rec.deliver_to_org_id,p_old_line_rec.deliver_to_org_id)
       AND p_x_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE
       AND NVL(p_x_line_rec.split_action_code,'X') <> 'SPLIT'
       AND NVL(p_x_line_rec.transaction_phase_code,'F') = 'F'
    THEN
          IF l_debug_level > 0 then
             oe_debug_pub.ADD('Delver to site update: logging request for eval_hold_source');
             oe_debug_pub.ADD('line ID: '|| to_char(p_x_line_rec.line_id)||
		             ' Entity ID: '|| to_char(p_x_line_rec.deliver_to_org_id));
          END IF;

          OE_delayed_requests_Pvt.log_request(
                    p_entity_code => OE_GLOBALS.G_ENTITY_LINE,
                    p_entity_id         => p_x_line_rec.line_id,
		    p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
		    p_requesting_entity_id         => p_x_line_rec.line_id,
                    p_request_type      => OE_GLOBALS.G_EVAL_HOLD_SOURCE,
                    p_request_unique_key1 => 'DELIVER_TO',
                    p_param1		 => 'D',
                    p_param2		 => p_x_line_rec.deliver_to_org_id,
                    x_return_status     => l_return_status);
   END IF;

    IF NOT OE_GLOBALS.Equal(p_x_line_rec.line_type_id,p_old_line_rec.line_type_id)
       AND p_x_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE
       AND NVL(p_x_line_rec.split_action_code,'X') <> 'SPLIT'
       AND NVL(p_x_line_rec.transaction_phase_code,'F') = 'F'
    THEN
          IF l_debug_level > 0 then
             oe_debug_pub.ADD('Line Type update: logging request for eval_hold_source');
             oe_debug_pub.ADD('line ID: '|| to_char(p_x_line_rec.line_id)||
		             ' Entity ID: '|| to_char(p_x_line_rec.line_type_id));
          END IF;

          OE_delayed_requests_Pvt.log_request(
                    p_entity_code => OE_GLOBALS.G_ENTITY_LINE,
                    p_entity_id         => p_x_line_rec.line_id,
		    p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
		    p_requesting_entity_id         => p_x_line_rec.line_id,
                    p_request_type      => OE_GLOBALS.G_EVAL_HOLD_SOURCE,
                    p_request_unique_key1 => 'LINE_TYPE',
                    p_param1		 => 'LT',
                    p_param2		 => p_x_line_rec.line_type_id,
                    x_return_status     => l_return_status);
   END IF;

    IF NOT OE_GLOBALS.Equal(p_x_line_rec.payment_term_id,p_old_line_rec.payment_term_id)
       AND p_x_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE
       AND NVL(p_x_line_rec.split_action_code,'X') <> 'SPLIT'
       AND NVL(p_x_line_rec.transaction_phase_code,'F') = 'F'
    THEN
          IF l_debug_level > 0 then
             oe_debug_pub.ADD('Payment Term update: logging request for eval_hold_source');
             oe_debug_pub.ADD('line ID: '|| to_char(p_x_line_rec.line_id)||
		             ' Entity ID: '|| to_char(p_x_line_rec.payment_term_id));
          END IF;

          OE_delayed_requests_Pvt.log_request(
                    p_entity_code => OE_GLOBALS.G_ENTITY_LINE,
                    p_entity_id         => p_x_line_rec.line_id,
		    p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
		    p_requesting_entity_id         => p_x_line_rec.line_id,
                    p_request_type      => OE_GLOBALS.G_EVAL_HOLD_SOURCE,
                    p_request_unique_key1 => 'TERM',
                    p_param1		 => 'PT',
                    p_param2		 => p_x_line_rec.payment_term_id,
                    x_return_status     => l_return_status);
   END IF;

    IF NOT OE_GLOBALS.Equal(p_x_line_rec.price_list_id,p_old_line_rec.price_list_id)
       AND p_x_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE
       AND NVL(p_x_line_rec.split_action_code,'X') <> 'SPLIT'
       AND NVL(p_x_line_rec.transaction_phase_code,'F') = 'F'
    THEN
          IF l_debug_level > 0 then
             oe_debug_pub.ADD('Price List update: logging request for eval_hold_source');
             oe_debug_pub.ADD('line ID: '|| to_char(p_x_line_rec.line_id)||
		             ' Entity ID: '|| to_char(p_x_line_rec.price_list_id));
          END IF;

          OE_delayed_requests_Pvt.log_request(
                    p_entity_code => OE_GLOBALS.G_ENTITY_LINE,
                    p_entity_id         => p_x_line_rec.line_id,
		    p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
		    p_requesting_entity_id         => p_x_line_rec.line_id,
                    p_request_type      => OE_GLOBALS.G_EVAL_HOLD_SOURCE,
                    p_request_unique_key1 => 'PRICE_LIST',
                    p_param1		 => 'PL',
                    p_param2		 => p_x_line_rec.price_list_id,
                    x_return_status     => l_return_status);
   END IF;

    IF NOT OE_GLOBALS.Equal(p_x_line_rec.project_id,p_old_line_rec.project_id)
       AND p_x_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE
       AND NVL(p_x_line_rec.split_action_code,'X') <> 'SPLIT'
       AND NVL(p_x_line_rec.transaction_phase_code,'F') = 'F'
    THEN
          IF l_debug_level > 0 then
             oe_debug_pub.ADD('Project update: logging request for eval_hold_source');
             oe_debug_pub.ADD('line ID: '|| to_char(p_x_line_rec.line_id)||
		             ' Entity ID: '|| to_char(p_x_line_rec.project_id));
          END IF;

          OE_delayed_requests_Pvt.log_request(
                    p_entity_code => OE_GLOBALS.G_ENTITY_LINE,
                    p_entity_id         => p_x_line_rec.line_id,
		    p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
		    p_requesting_entity_id         => p_x_line_rec.line_id,
                    p_request_type      => OE_GLOBALS.G_EVAL_HOLD_SOURCE,
                    p_request_unique_key1 => 'PROJECT',
                    p_param1		 => 'PR',
                    p_param2		 => p_x_line_rec.project_id,
                    x_return_status     => l_return_status);
   END IF;

    IF NOT OE_GLOBALS.Equal(p_x_line_rec.shipping_method_code,p_old_line_rec.shipping_method_code)
       AND p_x_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE
       AND NVL(p_x_line_rec.split_action_code,'X') <> 'SPLIT'
       AND NVL(p_x_line_rec.transaction_phase_code,'F') = 'F'
    THEN
          IF l_debug_level > 0 then
             oe_debug_pub.ADD('Shipping Method update: logging request for eval_hold_source');
             oe_debug_pub.ADD('line ID: '|| to_char(p_x_line_rec.line_id)||
		             ' Entity ID: '|| to_char(p_x_line_rec.shipping_method_code));
          END IF;

          OE_delayed_requests_Pvt.log_request(
                    p_entity_code => OE_GLOBALS.G_ENTITY_LINE,
                    p_entity_id         => p_x_line_rec.line_id,
		    p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
		    p_requesting_entity_id         => p_x_line_rec.line_id,
                    p_request_type      => OE_GLOBALS.G_EVAL_HOLD_SOURCE,
                    p_request_unique_key1 => 'SHIP_METHOD',
                    p_param1		 => 'SM',
                    p_param2		 => p_x_line_rec.shipping_method_code,
                    x_return_status     => l_return_status);
   END IF;

    IF NOT OE_GLOBALS.Equal(p_x_line_rec.source_type_code,p_old_line_rec.source_type_code)
       AND p_x_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE
       AND NVL(p_x_line_rec.split_action_code,'X') <> 'SPLIT'
       AND NVL(p_x_line_rec.transaction_phase_code,'F') = 'F'
    THEN
          IF l_debug_level > 0 then
             oe_debug_pub.ADD('Source Type update: logging request for eval_hold_source');
             oe_debug_pub.ADD('line ID: '|| to_char(p_x_line_rec.line_id)||
		             ' Entity ID: '|| to_char(p_x_line_rec.source_type_code));
          END IF;

          OE_delayed_requests_Pvt.log_request(
                    p_entity_code => OE_GLOBALS.G_ENTITY_LINE,
                    p_entity_id         => p_x_line_rec.line_id,
		    p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
		    p_requesting_entity_id         => p_x_line_rec.line_id,
                    p_request_type      => OE_GLOBALS.G_EVAL_HOLD_SOURCE,
                    p_request_unique_key1 => 'SOURCE_TYPE',
                    p_param1		 => 'ST',
                    p_param2		 => p_x_line_rec.source_type_code,
                    x_return_status     => l_return_status);
   END IF;

    IF NOT OE_GLOBALS.Equal(p_x_line_rec.task_id,p_old_line_rec.task_id)
       AND p_x_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE
       AND NVL(p_x_line_rec.split_action_code,'X') <> 'SPLIT'
       AND NVL(p_x_line_rec.transaction_phase_code,'F') = 'F'
    THEN
          IF l_debug_level > 0 then
             oe_debug_pub.ADD('task id update: logging request for eval_hold_source');
             oe_debug_pub.ADD('line ID: '|| to_char(p_x_line_rec.line_id)||
		             ' Entity ID: '|| to_char(p_x_line_rec.task_id));
          END IF;

          OE_delayed_requests_Pvt.log_request(
                    p_entity_code => OE_GLOBALS.G_ENTITY_LINE,
                    p_entity_id         => p_x_line_rec.line_id,
		    p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
		    p_requesting_entity_id         => p_x_line_rec.line_id,
                    p_request_type      => OE_GLOBALS.G_EVAL_HOLD_SOURCE,
                    p_request_unique_key1 => 'TASK',
                    p_param1		 => 'T',
                    p_param2		 => p_x_line_rec.task_id,
                    x_return_status     => l_return_status);
   END IF;

    IF NOT OE_GLOBALS.Equal(p_x_line_rec.inventory_item_id,p_old_line_rec.inventory_item_id)
       AND p_x_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE
       AND NVL(p_x_line_rec.split_action_code,'X') <> 'SPLIT'
       AND NVL(p_x_line_rec.transaction_phase_code,'F') = 'F'
    THEN
          IF l_debug_level > 0 then
             oe_debug_pub.ADD('Top Model update: logging request for eval_hold_source');
             oe_debug_pub.ADD('line ID: '|| to_char(p_x_line_rec.line_id)||
		             ' Entity ID: '|| to_char(p_x_line_rec.inventory_item_id));
          END IF;

          OE_delayed_requests_Pvt.log_request(
                    p_entity_code => OE_GLOBALS.G_ENTITY_LINE,
                    p_entity_id         => p_x_line_rec.line_id,
		    p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
		    p_requesting_entity_id         => p_x_line_rec.line_id,
                    p_request_type      => OE_GLOBALS.G_EVAL_HOLD_SOURCE,
                    p_request_unique_key1 => 'TOP_MODEL',
                    p_param1		 => 'TM',
                    p_param2		 => p_x_line_rec.inventory_item_id,
                    x_return_status     => l_return_status);
   END IF;


--ER#7479609 end

  --ER 12571983 start
  IF NOT OE_GLOBALS.Equal(p_x_line_rec.end_customer_id,p_old_line_rec.end_customer_id)
     AND p_x_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE
	 AND NVL(p_x_line_rec.split_action_code,'X') <> 'SPLIT'
	 AND NVL(p_x_line_rec.transaction_phase_code,'F') = 'F' THEN

	IF l_debug_level > 0 THEN
      oe_debug_pub.ADD('End Customer update: logging request for eval_hold_source');
      oe_debug_pub.ADD('line ID: '|| TO_CHAR(p_x_line_rec.line_id)||
                       ' Entity ID: '|| TO_CHAR(p_x_line_rec.end_customer_id));
    END IF;

	OE_delayed_requests_Pvt.log_request(
						p_entity_code => OE_GLOBALS.G_ENTITY_LINE,
						p_entity_id => p_x_line_rec.line_id,
						p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
						p_requesting_entity_id => p_x_line_rec.line_id,
						p_request_type => OE_GLOBALS.G_EVAL_HOLD_SOURCE,
						p_request_unique_key1 => 'END_CUSTOMER',
						p_param1 => 'EC',
						p_param2 => p_x_line_rec.end_customer_id,
						x_return_status => l_return_status);
   END IF;
   IF NOT OE_GLOBALS.Equal(p_x_line_rec.end_customer_site_use_id,p_old_line_rec.end_customer_site_use_id)
     AND p_x_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE
	 AND NVL(p_x_line_rec.split_action_code,'X') <> 'SPLIT'
	 AND NVL(p_x_line_rec.transaction_phase_code,'F') = 'F' THEN

	IF l_debug_level > 0 THEN
      oe_debug_pub.ADD('End Customer Location update: logging request for eval_hold_source');
      oe_debug_pub.ADD('line ID: '|| TO_CHAR(p_x_line_rec.line_id)||
                       ' Entity ID: '|| TO_CHAR(p_x_line_rec.end_customer_site_use_id));
    END IF;

	OE_delayed_requests_Pvt.log_request(
						p_entity_code => OE_GLOBALS.G_ENTITY_LINE,
						p_entity_id => p_x_line_rec.line_id,
						p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
						p_requesting_entity_id => p_x_line_rec.line_id,
						p_request_type => OE_GLOBALS.G_EVAL_HOLD_SOURCE,
						p_request_unique_key1 => 'END_CUSTOMER_LOCATION',
						p_param1 => 'EL',
						p_param2 => p_x_line_rec.end_customer_site_use_id,
						x_return_status => l_return_status);
   END IF;
  --ER 12571983 end

   --ER 3667551 start
   -- only if system parameter is set to BTL then processing for BTH case needs to be done
  IF NOT OE_GLOBALS.Equal(p_x_line_rec.invoice_to_org_id,p_old_line_rec.invoice_to_org_id)
     AND p_x_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE
	 AND NVL(p_x_line_rec.split_action_code,'X') <> 'SPLIT'
	 AND NVL(p_x_line_rec.transaction_phase_code,'F') = 'F'
         AND l_credithold_cust = 'BTL' THEN

	 l_bill_to_cust_id := OE_Bulk_Holds_PVT.CustAcctID_func
			                             (p_in_site_id => p_x_line_rec.invoice_to_org_id,
                                          p_out_IDfound=> l_new_tbl_entry);

	IF l_debug_level > 0 THEN
      oe_debug_pub.ADD('Bill To Customer update: logging request for eval_hold_source');
      oe_debug_pub.ADD('line ID: '|| TO_CHAR(p_x_line_rec.line_id)||
                       ' Entity ID: '|| TO_CHAR(l_bill_to_cust_id));
    END IF;

	OE_delayed_requests_Pvt.log_request(
						p_entity_code => OE_GLOBALS.G_ENTITY_LINE,
						p_entity_id => p_x_line_rec.line_id,
						p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
						p_requesting_entity_id => p_x_line_rec.line_id,
						p_request_type => OE_GLOBALS.G_EVAL_HOLD_SOURCE,
						p_request_unique_key1 => 'BILL_TO_CUSTOMER',
						p_param1 => 'BTL',
						p_param2 => l_bill_to_cust_id,
						x_return_status => l_return_status);
   END IF;
  --ER 3667551 end

    -- bug 1829201, commitment related change.
    IF NOT OE_GLOBALS.Equal(p_x_line_rec.commitment_id,p_old_line_rec.commitment_id)
    THEN

      l_calculate_commitment_flag := 'Y';
      OE_GLOBALS.G_TAX_FLAG := 'Y';

      -- log delayed request for Verify_Payment.
     if l_debug_level > 0 then
      oe_debug_pub.add('log verify payment delayed request for change in commitment_id', 3);
     end if;
     l_verify_payment_flag                         := 'Y';
     OE_CREDIT_ENGINE_GRP.TOLERANCE_CHECK_REQUIRED := FALSE; --ER 12363706
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_line_rec.commitment_applied_amount,p_old_line_rec.commitment_applied_amount)
       AND OE_Commitment_Pvt.Do_Commitment_Sequencing
       AND oe_code_control.code_release_level >= '110510'
       AND p_x_line_rec.commitment_id IS NOT NULL
    THEN
     if l_debug_level > 0 then
      oe_debug_pub.add('Log verify payment delayed request for change in commitment_applied_amount.',3);
     end if;
      l_update_commitment_applied := 'Y';

    END IF;

    -- QUOTING changes - log fulfillment requests when transaction phase is
    -- updated during complete negotiation WF activity
    IF
    OE_Quote_Util.G_COMPLETE_NEG = 'Y'
       AND
      NOT OE_GLOBALS.Equal(p_x_line_rec.transaction_phase_code
                           ,p_old_line_rec.transaction_phase_code)
    THEN

      -- NOTE: Evaluate Hold Source Requests will be directly executed
      -- in post_write, no need to log it here.

      if l_debug_level > 0 then
         oe_debug_pub.add('Log Complete Neg Requests for Line');
      end if;

      -- log a delayed request to get included items for this item if any.

      l_freeze_method := G_FREEZE_METHOD; /* Bug # 5036404 */
     if l_debug_level > 0 then
      oe_debug_pub.ADD('Freeze method is :' || l_freeze_method,2);
     end if;

      IF l_freeze_method = OE_GLOBALS.G_IIFM_ENTRY AND
         p_x_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE AND
         p_x_line_rec.ato_line_id is NULL AND
         ( p_x_line_rec.item_type_code = OE_GLOBALS.G_ITEM_MODEL OR
           (p_x_line_rec.item_type_code = OE_GLOBALS.G_ITEM_KIT AND
            p_x_line_rec.line_id = p_x_line_rec.top_model_line_id))
      THEN
           p_x_line_rec.explosion_date := null;
           l_count := l_count + 1;
           OE_Config_Pvt.OE_FREEZE_INC_ITEMS_TBL(l_count):= p_x_line_rec.line_id;
      END IF;

      -- log request to calculate commitment
      IF p_x_line_rec.commitment_id IS NOT NULL THEN
         l_calculate_commitment_flag := 'Y';
      END IF;

       --Customer Acceptance
       l_def_contingency_attributes := FND_API.G_TRUE;

    END IF; -- End if phase is updated and complete neg is 'Y'
    -- QUOTING changes: END

    --Customer Acceptance:: Log delayed request to default contingency attributes

    IF NOT OE_GLOBALS.Equal(p_x_line_rec.contingency_id,p_old_line_rec.contingency_id)
    THEN
      --Customer Acceptance
       l_def_contingency_attributes := FND_API.G_TRUE;
    END IF;

      IF l_debug_level > 0 then
         oe_debug_pub.add('operation:'||p_x_line_rec.operation||' booked_flag:'||p_x_line_rec.booked_flag||' new contingency_id: '||p_x_line_rec.contingency_id ||' old contingency_id: '||p_old_line_rec.contingency_id);
      END IF;
      IF NVL(OE_SYS_PARAMETERS.VALUE('ENABLE_FULFILLMENT_ACCEPTANCE'), 'N') = 'Y'
	 AND (NVL( p_x_line_rec.booked_flag, 'N') = 'N' OR
                 p_x_line_rec.operation=OE_GLOBALS.G_OPR_CREATE)
         AND  l_def_contingency_attributes = FND_API.G_TRUE
         AND   p_x_line_rec.inventory_item_id IS NOT NULL
         AND   p_x_line_rec.inventory_item_id <> FND_API.G_MISS_NUM
         AND   p_x_line_rec.line_type_id IS NOT NULL
         AND   p_x_line_rec.line_type_id <> FND_API.G_MISS_NUM
        THEN

         IF ( p_x_line_rec.line_category_code = 'RETURN' OR
             p_x_line_rec.source_document_type_id = 10 OR
           (p_x_line_rec.order_source_id=27 AND p_x_line_rec.retrobill_request_id IS NOT NULL) OR
           (p_x_line_rec.item_type_code IN ('CONFIG', 'SERVICE', 'CLASS', 'OPTION', 'INCLUDED')) OR
           (p_x_line_rec.item_type_code='KIT' AND p_x_line_rec.top_model_line_id <> p_x_line_rec.line_id) OR
           (p_x_line_rec.operation=OE_GLOBALS.G_OPR_CREATE AND p_x_line_rec.split_from_line_id IS NULL AND NVL( p_x_line_rec.booked_flag, 'N') = 'N' AND nvl(p_x_line_rec.contingency_id, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM) OR
           (p_x_line_rec.operation=OE_GLOBALS.G_OPR_CREATE AND p_x_line_rec.split_from_line_id IS NOT NULL) OR
           (p_x_line_rec.operation=OE_GLOBALS.G_OPR_UPDATE AND NOT OE_GLOBALS.Equal(p_x_line_rec.contingency_id,p_old_line_rec.contingency_id)) OR
            NVL(p_x_line_rec.transaction_phase_code, 'F') = 'N') THEN
	     IF l_debug_level  > 0 THEN
              oe_debug_pub.add('Item_type_code:'||p_x_line_rec.item_type_code||'-Do not default Contingency Attributes for this line' );
             END IF;

	     OE_ACCEPTANCE_UTIL.Register_Changed_Lines(
                p_line_id           => p_x_line_rec.line_id
              , p_header_id         => p_x_line_rec.header_id
              , p_line_type_id      => p_x_line_rec.line_type_id
              , p_sold_to_org_id    => p_x_line_rec.sold_to_org_id
              , p_invoice_to_org_id => p_x_line_rec.invoice_to_org_id
              , p_inventory_item_id => p_x_line_rec.inventory_item_id
              , p_shippable_flag    => p_x_line_rec.shippable_flag
              , p_org_id            => p_x_line_rec.org_id
              , p_accounting_rule_id  => p_x_line_rec.accounting_rule_id
              , p_ship_to_org_id    => p_x_line_rec.ship_to_org_id  --For Bug#8262992
              , p_operation         => OE_GLOBALS.G_OPR_DELETE);

         ELSE

	     OE_ACCEPTANCE_UTIL.Register_Changed_Lines(
                p_line_id           => p_x_line_rec.line_id
              , p_header_id         => p_x_line_rec.header_id
              , p_line_type_id      => p_x_line_rec.line_type_id
              , p_sold_to_org_id    => p_x_line_rec.sold_to_org_id
              , p_invoice_to_org_id => p_x_line_rec.invoice_to_org_id
              , p_inventory_item_id => p_x_line_rec.inventory_item_id
              , p_shippable_flag    => p_x_line_rec.shippable_flag
              , p_org_id            => p_x_line_rec.org_id
              , p_accounting_rule_id  => p_x_line_rec.accounting_rule_id
              , p_ship_to_org_id    => p_x_line_rec.ship_to_org_id  --For Bug#8262992
              , p_operation         => p_x_line_rec.operation);

	    /** Logic to Default Contingency attributes**/
	    oe_delayed_requests_pvt.log_request(
                     p_entity_code            => OE_GLOBALS.G_ENTITY_ALL,
                     p_entity_id              => p_x_line_rec.header_id,
                     p_requesting_entity_code => OE_GLOBALS.G_ENTITY_ALL,
                     p_requesting_entity_id   => p_x_line_rec.header_id,
                     p_request_type           => OE_GLOBALS.G_DFLT_CONTINGENCY_ATTRIBUTES,
                     x_return_status          => l_return_status);

	 END IF;
     END IF;
     -- Customer Acceptance Changes End

	-- Log the delayed request for Update Shipping if any of the attributes in
	-- which Shipping is interested has been changed and the line has been
	-- interfaced with Shipping.

     -- Bug 12355310 : Replacing check on SI flag by new API
     -- IF (p_x_line_rec.shipping_interfaced_flag = 'Y' AND
     IF((p_x_line_rec.shipping_interfaced_flag = 'Y' OR
        (p_x_line_rec.shippable_flag = 'Y' AND p_x_line_rec.booked_flag = 'Y'
         AND Shipping_Interfaced_Status(p_x_line_rec.line_id) = 'Y')) AND
        (l_update_shipping = FND_API.G_TRUE OR l_explosion_date_changed = FND_API.G_TRUE) AND
        (p_x_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE AND NVL(p_x_line_rec.split_action_code,'X') <> 'SPLIT')) THEN

       if l_debug_level > 0 then
         oe_debug_pub.ADD('Logging update shipping delayed request for line ID :  '|| to_char(p_x_line_rec.line_id) ,1);
       end if;

       OE_Delayed_Requests_Pvt.Log_Request(
		p_entity_code			=>	OE_GLOBALS.G_ENTITY_LINE,
		p_entity_id			=>	p_x_line_rec.line_id,
		p_requesting_entity_code	=>	OE_GLOBALS.G_ENTITY_LINE,
		p_requesting_entity_id  	=>	p_x_line_rec.line_id,
		p_request_type			=>	OE_GLOBALS.G_UPDATE_SHIPPING,
		p_request_unique_key1		=>	p_x_line_rec.operation,
		p_param1             		=>	l_update_shipping,
		p_param2             		=>	l_explosion_date_changed,
		p_param5             		=>	l_ordered_quantity_changed,
		x_return_status			=>	l_return_status);

    END IF;

    If l_copy_adjustments and
		not l_no_copy_adjustments THEN

                -- commented out for bug 1917869
                -- p_x_line_rec.calculate_price_flag in ('N','P') then

	   If p_x_line_rec.split_from_line_id is not null and
			p_x_line_rec.split_from_line_id <> fnd_api.g_miss_num then
		l_from_line_id	:= p_x_line_rec.split_from_line_id ;
		l_from_header_id := p_x_line_rec.header_id;
	   elsif p_x_line_rec.reference_line_id is not null and
			p_x_line_rec.reference_line_id <> fnd_api.g_miss_num then
		l_from_line_id	:= p_x_line_rec.reference_line_id ;
		l_from_header_id := p_x_line_rec.reference_Header_id;
	   elsif p_x_line_rec.source_document_line_id is not null and
			p_x_line_rec.source_document_line_id <> fnd_api.g_miss_num then
		l_from_line_id	:= p_x_line_rec.source_document_line_id ;
		l_from_header_id := p_x_line_rec.source_document_id;
	   End If;

        OE_delayed_requests_Pvt.log_request(
				p_entity_code 			=> OE_GLOBALS.G_ENTITY_LINE,
				p_entity_id         	=> p_x_line_rec.line_id,
				p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
				p_requesting_entity_id   => p_x_line_rec.line_id,
		 		p_param1                 => p_x_line_rec.header_id,
                 	p_param2                 => l_from_line_id,
                 	p_param3                 => l_from_header_id,
		 		p_param4                 => p_x_line_rec.line_category_code,
		 		p_param5                 => p_x_line_rec.split_by,
		 		p_param6                 => p_x_line_rec.booked_flag,
		 		p_request_type           => OE_GLOBALS.G_COPY_ADJUSTMENTS,
		 		x_return_status          => l_return_status);

    end if;


    --Bug#10052614 Start
    oe_debug_pub.ADD('OPERATION' ||p_x_line_rec.operation);
    oe_debug_pub.ADD('CALCULATE_PRICE_FLAG '||p_x_line_rec.CALCULATE_PRICE_FLAG);
    oe_debug_pub.ADD('LINE_CATEGORY_CODE '||p_x_line_rec.LINE_CATEGORY_CODE);
    oe_debug_pub.ADD('REFERENCE_LINE_ID '||p_x_line_rec.REFERENCE_LINE_ID);
    oe_debug_pub.ADD('RETURN_CONTEXT '||p_x_line_rec.RETURN_CONTEXT);

    IF p_x_line_rec.operation = OE_GLOBALS.G_OPR_CREATE AND (p_x_line_rec.CALCULATE_PRICE_FLAG = 'N' OR
												       (p_x_line_rec.CALCULATE_PRICE_FLAG = 'P' AND
												       p_x_line_rec.LINE_CATEGORY_CODE = 'RETURN' AND
												       p_x_line_rec.REFERENCE_LINE_ID IS NOT NULL AND
												       p_x_line_rec.RETURN_CONTEXT IS NOT NULL))
    THEN
      oe_debug_pub.ADD('Logging DR_COPY_OTM_RECORDS relayed request fro Line '||p_x_line_rec.line_id||' From line '||l_from_line_id);
    	OE_delayed_requests_Pvt.log_request(
		p_entity_code 		 => OE_GLOBALS.G_ENTITY_LINE,
		p_entity_id         	 => p_x_line_rec.line_id,
		p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
		p_requesting_entity_id   => p_x_line_rec.line_id,
		p_param1                 => p_x_line_rec.header_id,
		p_param2                 => l_from_line_id,
		p_param3                 => l_from_header_id,
		p_request_type           => OE_GLOBALS.G_DR_COPY_OTM_RECORDS,
		x_return_status          => l_return_status
	  );
    END IF;
    --Bug#10052614 End

/* csheu -- bug #1533658 S */
    IF l_copy_service_fields and
	  p_x_line_rec.item_type_code = 'SERVICE' and
	  p_x_line_rec.service_reference_type_code  = 'ORDER' and
       p_x_line_rec.service_reference_line_id is NOT NULL and
	  p_x_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE THEN
	  BEGIN

            Select 'Y'
            INTO   l_is_model
            FROM   oe_order_lines
            WHERE  line_id = p_x_line_rec.service_reference_line_id
            AND    item_type_code in ('INCLUDED', 'MODEL', 'CLASS', 'OPTION') ;

       EXCEPTION
        WHEN OTHERS THEN
          l_is_model := 'N';
       END;

       IF l_is_model = 'Y' THEN
        if l_debug_level > 0 then
         oe_debug_pub.add('CSH Before log request --G_UPDATE_SERVICE', 1);
        end if;
         OE_Delayed_Requests_Pvt.log_request(
                         p_entity_code => OE_GLOBALS.G_ENTITY_LINE,
                         p_entity_id   => p_x_line_rec.line_id,
                         p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
                         p_requesting_entity_id   => p_x_line_rec.line_id,
                         p_request_type   => OE_GLOBALS.G_UPDATE_SERVICE,
                         x_return_status  => l_return_status);
       END IF;
    END IF; /* IF l_copy_service_fields... = TRUE */

   if l_debug_level > 0 then
    oe_debug_pub.add('CSH --OUT of l_copy_service_field condition ', 1);
   end if;
/* csheu -- bug #1533658 E */
    -- added by lkxu
    IF l_copy_pricing_attributes THEN
	   IF p_x_line_rec.split_from_line_id is not null and
		p_x_line_rec.split_from_line_id <> fnd_api.g_miss_num THEN
		  l_from_line_id	:= p_x_line_rec.split_from_line_id ;
		  l_from_header_id := p_x_line_rec.header_id;
	   ELSIF p_x_line_rec.reference_line_id is not null and
		p_x_line_rec.reference_line_id <> fnd_api.g_miss_num THEN
		  l_from_line_id	:= p_x_line_rec.reference_line_id ;
		  l_from_header_id := p_x_line_rec.reference_Header_id;
	   ELSIF p_x_line_rec.source_document_line_id is not null and
		p_x_line_rec.source_document_line_id <> fnd_api.g_miss_num THEN
		  l_from_line_id	:= p_x_line_rec.source_document_line_id ;
		  l_from_header_id := p_x_line_rec.source_document_id;
	   End IF;

        OE_delayed_requests_Pvt.log_request(
				p_entity_code 			=> OE_GLOBALS.G_ENTITY_LINE,
				p_entity_id         	=> p_x_line_rec.line_id,
				p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
				p_requesting_entity_id   => p_x_line_rec.line_id,
		 		p_param1                 => p_x_line_rec.header_id,
                 	p_param2                 => l_from_line_id,
                 	p_param3                 => l_from_header_id,
		 		p_request_type           => OE_GLOBALS.G_COPY_PRICING_ATTRIBUTES,
		 		x_return_status          => l_return_status);

    END IF;

    -----------------------------------------------------------
    --Set included item to 0 since it is should not be priced
    --No pricing should be called bug 1620213
    -----------------------------------------------------------
    If p_x_line_rec.item_type_code In ('INCLUDED','CONFIG') Then
         P_x_line_rec.unit_selling_price := 0;
         p_x_line_rec.unit_list_price := 0;
         P_x_line_rec.unit_selling_price_per_pqty := 0;
         p_x_line_rec.unit_list_price_per_pqty := 0;

/* Added the following two lines to fix the bug 2175029 */
         p_x_line_rec.pricing_quantity := p_x_line_rec.ordered_quantity;
         p_x_line_rec.pricing_quantity_uom := p_x_line_rec.order_quantity_uom;


         If p_x_line_rec.item_type_code = 'INCLUDED' and
            l_charges_for_included_item = 'Y' Then
           oe_globals.g_price_flag := 'Y';
         --Elsif p_x_line_rec.item_type_code = 'CONFIG' THEN
         --  oe_globals.g_price_flag := 'Y';
         Else
          if l_debug_level > 0 then
           oe_debug_pub.add('2207809: no price for config item', 3);
          end if;
           oe_globals.g_price_flag := 'N';
         End If;
    End If;

    -------------------------------------------------------------------
    --In the future all pricing related operations will be handled
    --by process_pricing.  The purpose of this is to reduce file locking
    --issue on OEXULINB.pls
    -------------------------------------------------------------------
    OE_LINE_ADJ_UTIL.Process_Pricing(p_x_new_line_rec => p_x_line_rec,
                                     p_old_line_rec   => p_old_line_rec,
                                     p_no_price_flag  => l_no_price_flag);

  if l_debug_level > 0 then
   oe_debug_pub.add('unit_list_price:'||p_x_line_rec.unit_list_price);
   oe_debug_pub.add('old unit_list_price:'||p_old_line_rec.unit_list_price);
   oe_debug_pub.add('original_list_price:'||p_x_line_rec.original_list_price);
  end if;
-- Override List Price
    IF  ((p_x_line_rec.unit_list_price IS NOT NULL AND
         p_x_line_rec.unit_list_price <> FND_API.G_MISS_NUM AND
--       p_x_line_rec.unit_list_price <> p_x_line_rec.original_list_price AND
         p_x_line_rec.unit_list_price <> p_old_line_rec.unit_list_price)
       OR
         (p_x_line_rec.unit_list_price IS NULL))
       AND
         p_old_line_rec.unit_list_price IS NOT NULL AND
         p_old_line_rec.unit_list_price <> FND_API.G_MISS_NUM AND
         p_x_line_rec.original_list_price  IS NOT NULL AND
         p_x_line_rec.original_list_price <> FND_API.G_MISS_NUM AND
         p_x_line_rec.Ordered_Quantity <> fnd_api.g_miss_num and
         p_x_line_rec.order_quantity_uom is not null and
         p_x_line_rec.order_quantity_uom <> fnd_api.g_miss_char
         AND oe_code_control.code_release_level >= '110510'
         -- bug 3491752
         --AND /*nvl(fnd_profile.value('ONT_LIST_PRICE_OVERRIDE_PRIV'), 'NONE')*/          --G_LIST_PRICE_OVERRIDE  = 'UNLIMITED' --bug4080363
         -- AND  OE_GLOBALS.G_UI_FLAG bug#12944527 - Commenting out this line since ULP, USP is not updatable from PO API
         AND  OE_Globals.G_PRICING_RECURSION = 'N' THEN

            IF p_x_line_rec.unit_list_price IS NOT NULL AND
               p_x_line_rec.unit_list_price <> FND_API.G_MISS_NUM AND
               p_x_line_rec.original_list_price  IS NOT NULL AND
               p_x_line_rec.original_list_price <> FND_API.G_MISS_NUM THEN
       --      p_x_line_rec.unit_list_price <> p_x_line_rec.original_list_price THEN

                   -- setting unit_list_price_per_pqty appropriately
                   p_x_line_rec.unit_list_price_per_pqty := (p_x_line_rec.ordered_quantity*p_x_line_rec.unit_list_price)/p_x_line_rec.pricing_quantity;
                 if l_debug_level > 0 then
                   oe_debug_pub.add('setting unit_list_price_per_pqty to:'||p_x_line_rec.unit_list_price_per_pqty);
                 end if;
            END IF;

            IF p_old_line_rec.unit_list_price IS NOT NULL AND
               p_x_line_rec.unit_list_price IS NULL AND
               p_x_line_rec.original_list_price IS NOT NULL THEN

                   -- setting unit_list_price_per_pqt, original_list_price to null
                 if l_debug_level > 0 then
                   oe_debug_pub.add('setting original_list_price, unit_list_price_per_pqty to null');
                 end if;
                   p_x_line_rec.original_list_price := NULL;
                   p_x_line_rec.unit_list_price_per_pqty := NULL;

            END IF;
           if l_debug_level > 0 then
            oe_debug_pub.add('setting call_pricing for list price override');
           end if;
            L_Call_pricing := 'Y';
    End If;
-- Override List Price
    IF 	oe_globals.g_price_flag = 'Y' and
		not l_no_price_flag  and
		nvl(oe_globals.g_pricing_recursion,'N') <> 'Y'  and
	  	--bsadri nvl(p_x_line_rec.ordered_quantity,0) <> 0 and
                --For bug 7115648
                p_x_line_rec.inventory_item_id  is not null and
	  	--End of 7115648
		p_x_line_rec.Ordered_Quantity <> fnd_api.g_miss_num and
		p_x_line_rec.order_quantity_uom is not null and
		p_x_line_rec.order_quantity_uom <> fnd_api.g_miss_char
       or  l_call_pricing = 'Y' --Override List Price
	THEN
                --bsadri for cancelled lines l_zero_line_qty is true

                IF nvl(p_x_line_rec.ordered_quantity,0) = 0 THEN
                    l_zero_line_qty := TRUE;
                    /* BUG 2013611 BEGIN */
                  if l_debug_level > 0 then
	            oe_debug_pub.ADD('Logging REVERSE_LIMITS delayed request for LINE CANCEL ',1);
                  end if;
                    OE_delayed_requests_Pvt.log_request(
				p_entity_code 		 => OE_GLOBALS.G_ENTITY_LINE,
				p_entity_id              => p_x_line_rec.line_id,
				p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
				p_requesting_entity_id   => p_x_line_rec.line_id,
				p_request_unique_key1  	 => 'LINE',
		 		p_param1                 => 'CANCEL',
		 		p_param2                 => p_x_line_rec.price_request_code,
		 		p_param3                 => NULL,
		 		p_param4                 => NULL,
		 		p_param5                 => NULL,
		 		p_param6                 => NULL,
		 		p_request_type           => OE_GLOBALS.G_REVERSE_LIMITS,
		 		x_return_status          => l_return_status);
                  if l_debug_level > 0 then
	            oe_debug_pub.ADD('REVERSE_LIMITS Delayed request has been logged',1);
                  end if;
                    /* BUG 2013611 END */
                ELSE
                    l_zero_line_qty := FALSE;
                END IF;
		If
		( (p_x_line_rec.unit_list_price is null or
		  p_x_line_rec.Unit_List_Price = fnd_api.g_miss_num or
		  NOT OE_GLOBALS.Equal(p_x_line_rec.ordered_quantity,p_old_line_rec.ordered_quantity) or
		  NOT OE_GLOBALS.Equal(p_x_line_rec.ordered_quantity2,p_old_line_rec.ordered_quantity2) or -- INVCONV 2317146 - INVCONV STET
		  NOT OE_GLOBALS.Equal(p_x_line_rec.cancelled_Quantity,p_old_line_rec.cancelled_Quantity) or
		   NOT OE_GLOBALS.Equal(p_x_line_rec.order_quantity_uom,p_old_line_rec.order_quantity_uom) or
		   NOT OE_GLOBALS.Equal(p_x_line_rec.inventory_item_id,p_old_line_rec.inventory_item_id) or   --fix bug 1388503 btea
                   NOT OE_GLOBALS.Equal(p_x_line_rec.unit_list_price,p_old_line_rec.unit_list_price)  )
                  and p_x_line_rec.item_type_code <> OE_GLOBALS.G_ITEM_SERVICE
		   )
           --RT{
               and nvl(p_x_line_rec.retrobill_request_id,FND_API.G_MISS_NUM)= FND_API.G_MISS_NUM
           --RT}
               or l_call_pricing = 'Y' -- Override List Price
	   then


               IF ((OE_GLOBALS.G_UI_FLAG)
                and OE_GLOBALS.G_DEFER_PRICING='N'
                and (nvl(Oe_Config_Pvt.oecfg_configuration_pricing,'N')='N'))
               THEN

          	l_Price_Control_Rec.pricing_event := 'PRICE';
			l_Price_Control_Rec.calculate_flag := QP_PREQ_GRP.G_SEARCH_N_CALCULATE;
			l_Price_Control_Rec.Simulation_Flag := 'N';

			l_x_line_tbl(1) := p_x_line_rec;
                        IF NOT l_zero_line_qty THEN
                         --bsadri call the Price_line for non-cancelled lines
                         if l_debug_level > 0 then
                          oe_debug_pub.add('list price before call to price_line:'||p_x_line_rec.unit_list_price);
                          oe_debug_pub.add('list price per pqty  before call to price_line:'||p_x_line_rec.unit_list_price_per_pqty);
                         end if;
			  oe_order_adj_pvt.Price_line(
				X_Return_Status     => l_Return_Status
				,p_Line_id          => p_x_line_rec.line_id
				,p_Request_Type_code=> 'ONT'
				,p_Control_rec      => l_Price_Control_Rec
				,p_Write_To_Db		=> FALSE
				,x_Line_Tbl		=> l_x_Line_Tbl
				);

			   -- Populate Line_rec
			   -- Fix for Bug 3374889. Commented the while loop and
                           -- and assigned l_x_Line_Tbl(1) to line_rec.
                           p_x_line_rec := l_x_Line_Tbl(1);
                           /*
                            i:= l_x_Line_Tbl.First;
			    While i is not null loop
				  p_x_line_rec := l_x_Line_Tbl(i);
				  i:= l_x_Line_Tbl.Next(i);
			    End Loop;
                           */
                        if l_debug_level > 0 then
                          oe_debug_pub.add('list price after call to price_line:'||p_x_line_rec.unit_list_price);
                          oe_debug_pub.add('list price per pqty  after call to price_line:'||p_x_line_rec.unit_list_price_per_pqty);
                        end if;
                  -- Bug 2757443.
                  -- Need to log delayed request for tax and commitment
                  -- when unit_selling_price changes from null to not null
                  -- during PRICE event.
                  IF NOT OE_GLOBALS.Equal(p_old_line_rec.unit_selling_price,
                         l_x_Line_Tbl(1).unit_selling_price) THEN

                     OE_GLOBALS.G_TAX_FLAG := 'Y';
                     IF l_x_Line_Tbl(1).commitment_id IS NOT NULL THEN
                       l_calculate_commitment_flag := 'Y';
                     END IF;
                  END IF;

                if l_debug_level > 0 then
                  oe_debug_pub.add('outside margin code',1);
                end if;
                            --MRG BGN
                          If OE_FEATURES_PVT.Is_Margin_Avail Then
                 if l_debug_level > 0 then
                  oe_debug_pub.add('inside margin code',1);
                 end if;
                            p_x_line_rec.unit_cost:=OE_MARGIN_PVT.GET_COST(p_x_line_rec);
                          End If;
                            --MRG END

                          END IF;
	   End If;
        End If;  --end if for UI Flag Check
         if l_debug_level > 0 then
	   oe_debug_pub.ADD('Logging delayed request for pricing');
         end if;
        IF ((OE_GLOBALS.G_UI_FLAG)
          and OE_GLOBALS.G_DEFER_PRICING='N'
          and (nvl(Oe_Config_Pvt.oecfg_configuration_pricing,'N')='N'))
          OR (p_x_line_rec.item_type_code = 'INCLUDED' and OE_GLOBALS.G_DEFER_PRICING='N')
          --RT
          and nvl(p_x_line_rec.retrobill_request_id,FND_API.G_MISS_NUM)=FND_API.G_MISS_NUM THEN
         if l_debug_level > 0 then
          oe_debug_pub.add('ui mode or config, included item'||p_x_line_rec.line_id);
         end if;
         IF NOT l_zero_line_qty THEN
             --bsadri don't call this for a cancelled line

           IF nvl(p_x_line_rec.item_type_code,'x') <> 'INCLUDED' THEN
             --bug 2855794
     if l_debug_level > 0 then
      oe_debug_pub.ADD('Calc price flag:'||p_x_line_rec.calculate_price_flag);
     end if;
             if (p_x_line_rec.calculate_price_flag <> 'N' OR
                 l_item_rec.ont_pricing_qty_source = 'S' ) THEN -- INVCONV
                if l_debug_level > 0 then
                 oe_debug_pub.ADD('logging price line request');
                end if;

                OE_delayed_requests_Pvt.log_request(
		p_entity_code 			=> OE_GLOBALS.G_ENTITY_LINE,
		p_entity_id         	=> p_x_line_rec.line_id,
		p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
		p_requesting_entity_id   => p_x_line_rec.line_id,
		p_request_unique_key1  	=> 'LINE',
		p_param1                 => p_x_line_rec.header_id,
               	p_param2                 => 'LINE',
		p_request_type           => OE_GLOBALS.G_PRICE_LINE,
		x_return_status          => l_return_status);
             end if; --bug 2855794

           ELSE

             IF OE_LINE_ADJ_UTIL.Is_Pricing_Related_Change(p_x_line_rec,p_old_line_rec)
	     OR NOT OE_GLOBALS.Equal(p_x_line_rec.shipping_method_code,p_old_line_rec.shipping_method_code) THEN
               if l_debug_level > 0 then
                oe_debug_pub.add('renga-logging delayed req freight_for_included',1);
               end if;

               OE_delayed_requests_Pvt.log_request(
				p_entity_code 	=> OE_GLOBALS.G_ENTITY_ALL,
				p_entity_id     => p_x_line_rec.header_id,
				p_requesting_entity_code => OE_GLOBALS.G_ENTITY_ALL,
				p_requesting_entity_id   => p_x_line_rec.header_id,
				p_request_unique_key1  	=> 'ORDER',
		 		p_param1                 => p_x_line_rec.header_id,
                 		p_param2                 => 'ORDER',
		 		p_request_type           => OE_GLOBALS.G_FREIGHT_FOR_INCLUDED,
		 		x_return_status          => l_return_status);

               if l_debug_level > 0 then
                oe_debug_pub.add('renga-after logging delayed req freight_for_included',1);
               end if;
             END IF;

           END IF;  -- if item type code is not included

         END IF;  -- if not l_zero_line_qty
          IF p_x_line_rec.item_type_code <> 'INCLUDED' THEN
             IF p_x_line_rec.booked_flag='Y' THEN  --2442012
                 l_pricing_event := 'BATCH,ORDER,BOOK';  --7494393
             ELSE
                 l_pricing_event := 'ORDER';
             END IF;
           OE_delayed_requests_Pvt.log_request(
				p_entity_code 			=> OE_GLOBALS.G_ENTITY_ALL,
				p_entity_id         	=> p_x_line_rec.Header_Id,
				p_requesting_entity_code => OE_GLOBALS.G_ENTITY_ALL,
				p_requesting_entity_id   => p_x_line_rec.Header_Id,
				p_request_unique_key1  	=> l_pricing_event,
		 		p_param1                 => p_x_line_rec.header_id,
                 		p_param2                 => l_pricing_event,
		 		p_request_type           => OE_GLOBALS.G_PRICE_ORDER,
		 		x_return_status          => l_return_status);
          END IF;  -- item_type_code not included
        ELSE
         if l_debug_level > 0 then
          oe_debug_pub.add('batch mode or defer pricing');
         end if;
         --RT{
          IF nvl(p_x_line_rec.retrobill_request_id,FND_API.G_MISS_NUM)<>FND_API.G_MISS_NUM Then
              --call pricing for retrobilling lines in one shot (PRICE_ORDER)
             IF p_x_line_rec.operation=OE_GLOBALS.G_OPR_CREATE THEN
               l_retrobill_operation:='CREATE';
             ELSE
               l_retrobill_operation:='UPDATE';
             END IF;


              OE_delayed_requests_Pvt.log_request(
				p_entity_code 			=> OE_GLOBALS.G_ENTITY_ALL,
				p_entity_id         	=> p_x_line_rec.Header_Id,
				p_requesting_entity_code => OE_GLOBALS.G_ENTITY_ALL,
				p_requesting_entity_id   => p_x_line_rec.Header_Id,
				p_request_unique_key1  	=> 'RETROBILL',
		 		p_param1                 => p_x_line_rec.header_id,
                 		p_param2                 => 'RETROBILL',
                                p_param3                 => l_retrobill_operation,
		 		p_request_type           => OE_GLOBALS.G_PRICE_ORDER,
		 		x_return_status          => l_return_status);

              --copy the adjustments over to the new retrobilling line
              OE_delayed_requests_Pvt.log_request(
				p_entity_code 		=> OE_GLOBALS.G_ENTITY_LINE,
				p_entity_id         	 => p_x_line_rec.line_id,
				p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
				p_requesting_entity_id   => p_x_line_rec.line_id,
		 		p_param1                 => p_x_line_rec.header_id,
                                --x_line_rec.orig_sys_line_ref stores orignial line_id
                                --p_param2 is copy_line_line_id
                 	        p_param2                 => p_x_line_rec.orig_sys_line_ref,
                                --orig_sys_document_ref stores original header_id
                                --p_param3 is copy_from_header_id
                 	        p_param3                 => p_x_line_rec.orig_sys_document_ref,
		 		p_param4                 => p_x_line_rec.line_category_code,
		 		p_param5                 => p_x_line_rec.split_by,
		 		p_param6                 => p_x_line_rec.booked_flag,
		 		p_request_type           => OE_GLOBALS.G_COPY_ADJUSTMENTS,
                                p_param7                   => 'RETROBILL',
                                p_param8   => p_x_line_rec.retrobill_request_id,
		 		x_return_status          => l_return_status);
          --RT}
          Else
           IF p_x_line_rec.booked_flag='Y' and p_x_line_rec.item_type_code <> 'INCLUDED' Then
                  l_pricing_event := 'BATCH,BOOK';
           ELSE
                  l_pricing_event := 'BATCH';
           END IF;

           IF OE_GLOBALS.G_DEFER_PRICING='Y' AND
              p_x_line_rec.booked_flag='Y'AND
              p_x_line_rec.item_type_code <>'INCLUDED' THEN  --2442012
                l_pricing_event := 'PRICE,BATCH,BOOK';
           ELSIF OE_GLOBALS.G_DEFER_PRICING='Y' THEN
                l_pricing_event := 'PRICE,BATCH';
           END IF;

           OE_delayed_requests_Pvt.log_request(
				p_entity_code 			=> OE_GLOBALS.G_ENTITY_ALL,
				p_entity_id         	=> p_x_line_rec.Header_Id,
				p_requesting_entity_code => OE_GLOBALS.G_ENTITY_ALL,
				p_requesting_entity_id   => p_x_line_rec.Header_Id,
				p_request_unique_key1  	=> l_pricing_event,
		 		p_param1                 => p_x_line_rec.header_id,
                 		p_param2                 => l_pricing_event,
		 		p_request_type           => OE_GLOBALS.G_PRICE_ORDER,
		 		x_return_status          => l_return_status);
          END IF;   --RT
        END IF;     --2442012

  /*         If p_x_line_rec.booked_flag='Y' and p_x_line_rec.item_type_code <> 'INCLUDED' Then
           OE_delayed_requests_Pvt.log_request(
				p_entity_code 			=> OE_GLOBALS.G_ENTITY_ALL,
				p_entity_id         	=> p_x_line_rec.Header_Id,
				p_requesting_entity_code => OE_GLOBALS.G_ENTITY_ALL,
				p_requesting_entity_id   => p_x_line_rec.Header_Id,
				p_request_unique_key1  	=> 'BOOK',
		 		p_param1                 => p_x_line_rec.header_id,
                 		p_param2                 => 'BOOK',
		 		p_request_type           => OE_GLOBALS.G_PRICE_ORDER,
		 		x_return_status          => l_return_status);
	   End If;
  */
      --  fixed bug 1688064, move the following line out of IF block.
	 --  Oe_Globals.g_price_flag := 'N';
     END IF;

	/* rlanka: Fix for Bug 1729372

            For the new line that is created by Promotional modifier
            need to log a delayed request to PRICE_LINE again to apply
	    freight charges.

         */

      if l_debug_level > 0 then
        oe_debug_pub.add('g_price_flag = ' || oe_globals.g_price_flag);
        --oe_debug_pub.add('l_no_price_flag = '|| l_no_price_flag);
        oe_debug_pub.add('g_pricing_recursion = ' || oe_globals.g_pricing_recursion);
        oe_debug_pub.add('Ordered quantity = '|| to_char(p_x_line_rec.ordered_quantity));
        oe_debug_pub.add('Ordered qty UOM = ' || p_x_line_rec.order_quantity_uom);
        oe_debug_pub.add('Calculate_price_flag = '|| p_x_line_rec.calculate_price_flag);
      end if;

	 if (oe_globals.g_price_flag = 'Y' and
            not l_no_price_flag and
            oe_globals.g_pricing_recursion = 'Y' and
            nvl(p_x_line_rec.ordered_quantity,0) <> 0 and
            p_x_line_rec.Ordered_Quantity <> fnd_api.g_miss_num and
            p_x_line_rec.order_quantity_uom is not null and
            p_x_line_rec.order_quantity_uom <> fnd_api.g_miss_char and
            p_x_line_rec.calculate_price_flag = 'R')
           --RT{
            and nvl(p_x_line_rec.retrobill_request_id,FND_API.G_MISS_NUM)=FND_API.G_MISS_NUM
           --RT}
        then

          if l_debug_level > 0 then
           oe_debug_pub.add('New line created by Promotional Modifier');

            oe_debug_pub.add('Resetting calc. price. flag to P');
          end if;
            p_x_line_rec.calculate_price_flag := 'P';
           if l_debug_level > 0 then
            oe_debug_pub.add('Logging a request to PRICE_LINE in batch mode');
           end if;
            if (p_x_line_rec.booked_flag = 'Y')  --2442012
            then
              if l_debug_level > 0 then
               oe_debug_pub.add('Booked order -- log a request to Price Line');
              end if;
               l_pricing_event := 'BATCH,BOOK';
            Else
               l_pricing_event := 'BATCH';
            End If;
            OE_delayed_requests_Pvt.log_request(
				p_entity_code           =>OE_GLOBALS.G_ENTITY_ALL,
                                p_entity_id             => p_x_line_rec.line_Id,
                                p_requesting_entity_code => OE_GLOBALS.G_ENTITY_ALL,
                                p_requesting_entity_id   => p_x_line_rec.line_Id,
                                p_request_unique_key1   => l_pricing_event,
                                p_param1                 => p_x_line_rec.header_id,
                                p_param2                 => l_pricing_event,
                                p_request_type           => OE_GLOBALS.G_PRICE_LINE,
                                x_return_status          => l_return_status);

  /*        if (p_x_line_rec.booked_flag = 'Y')
          then
             oe_debug_pub.add('Booked order -- log a request to Price Line');
             OE_delayed_requests_Pvt.log_request(
                                p_entity_code           =>OE_GLOBALS.G_ENTITY_ALL,
                                p_entity_id             => p_x_line_rec.line_Id,
                                p_requesting_entity_code => OE_GLOBALS.G_ENTITY_ALL,
                                p_requesting_entity_id   => p_x_line_rec.line_Id,
                                p_request_unique_key1   => 'BOOK',
                                p_param1                 => p_x_line_rec.header_id,
                                p_param2                 => 'BOOK',
                                p_request_type           => OE_GLOBALS.G_PRICE_LINE,
                                x_return_status          => l_return_status);
          end if; -- if order is BOOKED
   */    --2442012
        end if; -- if new line created by Promotional modifier needs to be re-priced.

        -- end of fix for bug 1729372

     Oe_Globals.g_price_flag := 'N';

	If NOT OE_GLOBALS.Equal(p_x_line_rec.Shipped_Quantity,p_old_line_rec.Shipped_Quantity)
           --RT{
             and nvl(p_x_line_rec.retrobill_request_id,FND_API.G_MISS_NUM)=FND_API.G_MISS_NUM
           --RT}
	Then
           --btea
           IF p_x_line_rec.line_category_code <> 'RETURN' Then
              OE_Shipping_Integration_PVT.Check_Shipment_Line(
                 p_line_rec                => p_old_line_rec
              ,  p_shipped_quantity        => p_x_line_rec.Shipped_Quantity
              ,  x_result_out              => l_x_result_out
              );

              IF l_x_result_out = OE_GLOBALS.G_PARTIALLY_SHIPPED THEN
               -- This line will split, set the calculate_price_flag  to 'P' if 'Y'
                IF (p_x_line_rec.calculate_price_flag = 'Y') THEN
                  p_x_line_rec.calculate_price_flag := 'P';
                END IF;


              END IF;

           Elsif p_x_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE
                 and p_x_line_rec.split_by = 'SYSTEM'
                 and NVL(p_x_line_rec.split_action_code,'X') = 'SPLIT'
                 and p_x_line_rec.calculate_price_flag = 'Y' Then
                   p_x_line_rec.calculate_price_flag :='P';
           End If;

           OE_delayed_requests_Pvt.log_request(
				p_entity_code 		=> OE_GLOBALS.G_ENTITY_ALL,
				p_entity_id         	=> p_x_line_rec.line_id,
				p_requesting_entity_code => OE_GLOBALS.G_ENTITY_ALL,
				p_requesting_entity_id   => p_x_line_rec.line_id,
				p_request_unique_key1  	=> 'SHIP',
		 		p_param1                 => p_x_line_rec.header_id,
                 		p_param2                 => 'SHIP',
		 		p_request_type           => OE_GLOBALS.G_PRICE_LINE,
		 		x_return_status          => l_return_status);
	End If;

        -- change for bug 1406890
        -- Renga making changes for tax calculation event enhancement
        IF nvl(p_x_line_rec.booked_flag, 'N') = 'Y' THEN
            l_current_event := 1;  /* current event is booking or higher */
        END IF;

        IF (p_x_line_rec.shippable_flag = 'Y' and
            p_x_line_rec.shipped_quantity is not null ) THEN
           l_current_event := 2; /* current event is shipping or higher */
        END IF;

        BEGIN

         IF OE_Order_Cache.g_header_rec.order_type_id is not null THEN

              --use cache instead of SQL to fix bug 4200055
              if (OE_Order_Cache.g_order_type_rec.order_type_id = FND_API.G_MISS_NUM)
		  OR (OE_Order_Cache.g_order_type_rec.order_type_id is null)
                  OR (OE_Order_Cache.g_order_type_rec.order_type_id <>
OE_Order_Cache.g_header_rec.Order_Type_id) THEN
       	  		 OE_Order_Cache.Load_Order_type(OE_Order_CACHE.g_header_rec.Order_Type_id)
;
	       END IF ;
	       IF (OE_Order_Cache.g_order_type_rec.order_type_id =
OE_Order_Cache.g_header_rec.Order_Type_id) THEN
	  	        if (OE_Order_Cache.g_order_type_rec.tax_calculation_event_code =
'ENTERING') then
				l_tax_calculation_event_code := 0;
			elsif (OE_Order_Cache.g_order_type_rec.tax_calculation_event_code =
'BOOKING') then
				l_tax_calculation_event_code := 1;
			elsif (OE_Order_Cache.g_order_type_rec.tax_calculation_event_code =
'SHIPPING') then
				l_tax_calculation_event_code := 2;
			elsif (OE_Order_Cache.g_order_type_rec.tax_calculation_event_code =
'INVOICING') then
				l_tax_calculation_event_code := 3;
			else
				l_tax_calculation_event_code := -1;
                        end if ;
	       ELSE
		      l_tax_calculation_event_code := 0 ;
	       END IF ;

           /* SELECT DECODE( TAX_CALCULATION_EVENT_CODE, 'ENTERING',   0,
                                                  'BOOKING', 1,
                                                  'SHIPPING', 2,
                                                  'INVOICING', 3,
                                                  -1)
            into l_tax_calculation_event_code
            from oe_transaction_types_all
            where transaction_type_id = OE_Order_Cache.g_header_rec.order_type_id;
            */
            --end bug 4200055

         END IF;

        EXCEPTION
           when no_data_found then
                 l_tax_calculation_event_code := 0;
           when others then
            if l_debug_level > 0 then
             oe_debug_pub.add('Ren: failed while trying to query up tax_calcualtion_event for order_type_id ');
            end if;
             RAISE;

        END;

        -- all non-shippable lines need to get taxed at the time of entry
        -- itself - so we set the current event to same as
        --  tax_calculation_event

        IF ( l_tax_calculation_event_code = 2 and
             p_x_line_rec.shippable_flag = 'N' ) THEN
              l_current_event := l_tax_calculation_event_code;
        END IF;

        -- if current_event >= tax_calculation_event, then log
        -- the delayed request
        -- Renga end making changes for tax calculation event enhancement

        -- Modified the If condition as part of the fix for bug#2047434
        -- delayed request for taxing should not get logged for a line
        -- without an item thus added the condition to test the value of
        -- inventory item id .

        IF p_x_line_rec.item_type_code in ('INCLUDED', 'CONFIG') THEN

         if l_debug_level > 0 then
          oe_debug_pub.add('Ren: no tax delayed request for include and config',1);
         end if;

          oe_globals.g_tax_flag := 'N';

        END IF;
    --changes for bug 2505961  begin

    --commented the following for bug7306510 as the sql execution is no more required
    /*if p_x_line_rec.commitment_id is not null
       and p_x_line_rec.commitment_id <> FND_API.G_MISS_NUM
       and oe_globals.g_tax_flag = 'Y'
    then
     begin
      select  nvl(tax_calculation_flag,'N') into l_tax_commt_flag
      from ra_cust_trx_types ract where ract.cust_trx_type_id =
      (
      select nvl(cust_type.subsequent_trx_type_id,cust_type.cust_trx_type_id)
      from ra_cust_trx_types_all cust_type,ra_customer_trx_all cust_trx  where
      cust_type.cust_trx_type_id = cust_trx.cust_trx_type_id
      and cust_trx.customer_trx_id = p_x_line_rec.commitment_id
      );
     if l_debug_level > 0 then
      oe_debug_pub.add('OEXULINB:l_commit tax flag: '||l_tax_commt_flag,1);
     end if;

     exception
      when others then
     if l_debug_level > 0 then
      oe_debug_pub.add('OEXULINB: in exception commitment ',1);
     end if;
      l_tax_commt_flag := 'N';
     end;
    end if;*/
    --changes for bug 2505961  end
    --changes made in if condition below for bug 2573940



    -- commented portion of the following condition for bug7306510
       -- with ebtax upkae in R12 ,meaning of ra_cust_trx_types.tax_calculation_flag has changed
       -- now this flag will be checcked by customers only if they want the 11i migrated Tax Classification
       -- code approach,other wise tax will be calculated based on tax rules .It no more controls wheter tax code  is a  required  filed in AR transactions or not
       -- OM will depend on Tax_event alone ( specfied transaction type level) to automatically trigger
       -- tax calcualtion .ra_cust_trx_types.tax_calculation_flag is no more considered while logging delayed requests for tax
    -- 12876258 Added Debug
     if l_debug_level > 0 then
	    oe_debug_pub.add('Before Tax delayed Req, taxFlag= '||oe_globals.g_tax_flag||' l_current_event= '||l_current_event);
     end if; -- end 12876258

   IF ( oe_globals.g_tax_flag = 'Y'  and
          l_current_event >= l_tax_calculation_event_code and
       /*bug7306510 ( l_tax_calculation_flag = 'Y' or
          p_x_line_rec.tax_exempt_flag = 'R' or l_tax_commt_flag = 'Y'
         or (l_tax_calculation_flag = 'N' and
          nvl(p_x_line_rec.tax_value,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM
            )
        ) and */
  nvl(p_x_line_rec.inventory_item_id,fnd_api.g_miss_num) <> fnd_api.g_miss_num)
  THEN
         if l_debug_level > 0 then
	    oe_debug_pub.ADD('Logging delayed request for taxing');
         end if;
	    -- lkxu, make changes for bug 1581188
            l_tax_commt_flag := 'N'; --bug 2505961
	  IF (OE_GLOBALS.G_UI_FLAG) THEN
	    OE_delayed_requests_Pvt.log_request(
		p_entity_code 		=> OE_GLOBALS.G_ENTITY_LINE,
		p_entity_id   		=> p_x_line_rec.line_id,
		p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
		p_requesting_entity_id   => p_x_line_rec.line_id,
                p_request_type      	=> OE_GLOBALS.g_tax_line,
                x_return_status     	=> l_return_status);
          ELSE
            -- added p_param1 for bug 1786533.
	    OE_delayed_requests_Pvt.log_request(
		p_entity_code		=> OE_GLOBALS.G_ENTITY_ALL,
		p_entity_id   		=> p_x_line_rec.line_id,
		p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
		p_requesting_entity_id   => p_x_line_rec.line_id,
                p_request_type      	=> OE_GLOBALS.g_tax_line,
                p_param1             	=> l_param1,
                x_return_status     	=> l_return_status);
	  END IF;
          oe_globals.g_tax_flag := 'N';
	END IF;

	/** commented out for bug 1581188
	IF (oe_globals.g_tax_flag = 'Y') THEN
         if l_debug_level > 0 then
	   oe_debug_pub.ADD('Logging delayed request for taxing');
         end if;
	   OE_delayed_requests_Pvt.log_request(p_entity_code => OE_GLOBALS.G_ENTITY_LINE,
				p_entity_id         => p_x_line_rec.line_id,
				p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
				p_requesting_entity_id         => p_x_line_rec.line_id,
                                p_request_type      => OE_GLOBALS.g_tax_line,
                                x_return_status     => l_return_status);
          oe_globals.g_tax_flag := 'N';
	END IF;
	**/

    -- Log a verify payment request if the order is booked and a new line.
    -- Fix 1939779: Added condition to not log verify payment request for
    -- new config item lines being added to an order.
    IF p_x_line_rec.operation = OE_GLOBALS.G_OPR_CREATE AND
       p_x_line_rec.item_type_code <> OE_GLOBALS.G_ITEM_CONFIG AND
	  p_x_line_rec.booked_flag = 'Y' THEN
      IF (NVL(OE_Order_Cache.g_header_rec.payment_type_code, 'NULL') <> 'CREDIT_CARD'
          AND OE_PrePayment_UTIL.is_prepaid_order(p_x_line_rec.header_id) = 'N')
         OR OE_PrePayment_UTIL.is_prepaid_order(p_x_line_rec.header_id) = 'Y'
          THEN
         if l_debug_level > 0 then
	  oe_debug_pub.ADD('New line added to a booked order,'
		 || 'Logging delayed request for Verify Payment', 1);
         end if;
       l_verify_payment_flag := 'Y';
      END IF;
    END IF;

    -- Suppress verify payment and credit checking if the line is split
    IF (p_x_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE AND
	   NVL(p_x_line_rec.split_action_code,'X') = 'SPLIT' ) OR
       (p_x_line_rec.operation = OE_GLOBALS.G_OPR_CREATE AND
	    p_x_line_rec.split_from_line_id IS NOT NULL) THEN
         if l_debug_level > 0 then
	  oe_debug_pub.ADD('Line is being Split, Suppress Verify Payment', 1);
         end if;
        l_verify_payment_flag := 'N';
    END IF;

     -- If verify payment flag set to 'Y' then log a request for verify payment
     IF (l_verify_payment_flag = 'Y') THEN
	  -- Log request only if the Line is NOT a RETURN.
	  IF	p_x_line_rec.line_category_code <> 'RETURN' THEN
	  --
      if l_debug_level > 0 then
       oe_debug_pub.ADD('Logging delayed request for Verify Payment');
      end if;
	  --
       OE_delayed_requests_Pvt.log_request
                  (p_entity_code            => OE_GLOBALS.G_ENTITY_ALL,
                   p_entity_id              => p_x_line_rec.header_id,
                   p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
                   p_requesting_entity_id   => p_x_line_rec.line_id,
                   p_request_type           => OE_GLOBALS.G_VERIFY_PAYMENT,
                   x_return_status          => l_return_status);
          END IF;
     END IF;

     --bug 1829201, commitment related changes
     -- QUOTING change
     IF (l_calculate_commitment_flag = 'Y' OR l_get_commitment_bal = 'Y')
        AND nvl(p_x_line_rec.transaction_phase_code,'F') = 'F'
     THEN

         -- don't get the balance again, as this is the second call due to the change
         -- of unit_selling_price, and the returned value at this moment would be the
         -- balance after the current line is saved to database.

        IF NVL(OE_GLOBALS.g_pricing_recursion, 'N') <> 'Y'
           OR (NVL(OE_GLOBALS.g_pricing_recursion, 'N') = 'Y' AND
               oe_globals.g_commitment_balance IS NULL) THEN
  	   l_class := NULL;
           l_so_source_code := FND_PROFILE.VALUE('ONT_SOURCE_CODE');
           l_oe_installed_flag := 'I';

           -- get the available commitmenb balance before saving the line.
           IF NOT (p_x_line_rec.operation = OE_GLOBALS.G_OPR_CREATE AND
	         p_x_line_rec.split_from_line_id IS NOT NULL) THEN
              oe_globals.g_commitment_balance := ARP_BAL_UTIL.GET_COMMITMENT_BALANCE(
                        p_x_line_rec.commitment_id
                	,l_class
                	,l_so_source_code
               	 	,l_oe_installed_flag );
           END IF;

            -- if updating, then the applied commitment should become available
            IF p_x_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE THEN
              l_commitment_applied_amount
                 := OE_Commitment_PVT.get_commitment_applied_amount
                     (p_header_id          => p_x_line_rec.header_id ,
                      p_line_id            => p_x_line_rec.line_id ,
                      p_commitment_id      => p_x_line_rec.commitment_id);
              /* Fix Bug # 2511389: This is now done in OE_Commitment_PVT.Calculate_Commitments
              oe_globals.g_commitment_balance
                 := oe_globals.g_commitment_balance + l_commitment_applied_amount;
              */


            END IF;
         END IF;

        IF l_calculate_commitment_flag = 'Y'
           AND OE_Commitment_Pvt.Do_Commitment_Sequencing
           AND l_update_commitment_applied <> 'Y' THEN

         if l_debug_level > 0 then
           oe_debug_pub.add('Logging delayed request for Commitment.', 2);
         end if;
	   OE_Delayed_Requests_Pvt.Log_Request(
	   p_entity_code		=>	OE_GLOBALS.G_ENTITY_LINE,
	   p_entity_id			=>	p_x_line_rec.line_id,
	   p_requesting_entity_code	=>	OE_GLOBALS.G_ENTITY_LINE,
	   p_requesting_entity_id	=>	p_x_line_rec.line_id,
	   p_request_type		=>	OE_GLOBALS.G_CALCULATE_COMMITMENT,
	   x_return_status		=>	l_return_status);

        END IF;

    END IF;

    IF p_x_line_rec.commitment_id IS NOT NULL
       AND l_update_commitment_flag = 'Y'
       AND OE_Commitment_Pvt.Do_Commitment_Sequencing
       -- QUOTING change
       AND nvl(p_x_line_rec.transaction_phase_code,'F') = 'F'
    THEN

       -- lkxu, bug 1786533.
       IF (p_x_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE AND
           NVL(p_x_line_rec.split_action_code,'X') = 'SPLIT' ) THEN

         if l_debug_level > 0 then
           oe_debug_pub.add('Logging delayed request for updating commitment for line '||p_x_line_rec.line_id, 2);
         end if;

            -- should log as ENTITY_ALL, as SPLIT is a batch mode
	   OE_Delayed_Requests_Pvt.Log_Request(
		p_entity_code			=>OE_GLOBALS.G_ENTITY_ALL,
		p_entity_id			=>p_x_line_rec.line_id,
		p_requesting_entity_code	=>OE_GLOBALS.G_ENTITY_LINE,
		p_requesting_entity_id 		=>p_x_line_rec.line_id,
		p_request_type			=>OE_GLOBALS.G_UPDATE_COMMITMENT,
		x_return_status			=>l_return_status);
         END IF;
    END IF;

    IF l_update_commitment_applied = 'Y'
       AND nvl(p_x_line_rec.transaction_phase_code,'F') = 'F' THEN

         if l_debug_level > 0 then
           oe_debug_pub.add('Logging delayed request for Commitment Applied Amount '|| p_x_line_rec.commitment_applied_amount, 3);
           oe_debug_pub.add('param2 is: '|| p_x_line_rec.header_id, 3);
           oe_debug_pub.add('param3 is: '|| p_x_line_rec.commitment_id, 3);
         end if;
	   OE_Delayed_Requests_Pvt.Log_Request(
	   p_entity_code		=>	OE_GLOBALS.G_ENTITY_LINE,
	   p_entity_id			=>	p_x_line_rec.line_id,
	   p_requesting_entity_code	=>	OE_GLOBALS.G_ENTITY_LINE,
	   p_requesting_entity_id	=>	p_x_line_rec.line_id,
	   p_request_type		=>	OE_GLOBALS.G_UPDATE_COMMITMENT_APPLIED,
           p_param1             	=>      p_x_line_rec.commitment_applied_amount,
           p_param2             	=>      p_x_line_rec.header_id,
           p_param3             	=>      p_x_line_rec.commitment_id,
	   x_return_status		=>	l_return_status);

    END IF;

    -- bug 2668298, Freight Rating.
    IF l_get_FTE_freight_rate = 'Y' THEN

      if l_debug_level > 0 then
       oe_debug_pub.add('Logging delayed request for freight rate: '||p_x_line_rec.header_id, 2);
      end if;

       OE_delayed_requests_Pvt.log_request
                  (p_entity_code            => OE_GLOBALS.G_ENTITY_ALL,
                   p_entity_id              => p_x_line_rec.header_id,
                   p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
                   p_requesting_entity_id   => p_x_line_rec.line_id,
                   p_request_type           => OE_GLOBALS.G_FREIGHT_RATING,
                   x_return_status          => l_return_status);

        IF p_x_line_rec.booked_flag='Y' THEN
           l_pricing_event := 'BATCH,BOOK';
        ELSE
           l_pricing_event := 'BATCH';
        END IF;

        -- also log pricing request to calculate fregight rates.
        OE_delayed_requests_Pvt.log_request(
                   p_entity_code            => OE_GLOBALS.G_ENTITY_ALL,
                   p_entity_id              => p_x_line_rec.header_id,
                   p_requesting_entity_code => OE_GLOBALS.G_ENTITY_ALL,
                   p_requesting_entity_id   => p_x_line_rec.header_id,
                   p_request_unique_key1    => l_pricing_event,
                   p_request_unique_key2    => 'Y',  -- get freight flag
                   p_param1                 => p_x_line_rec.header_id,
                   p_param2                 => l_pricing_event,
                   p_request_type           => OE_GLOBALS.G_PRICE_ORDER,
                   x_return_status          => l_return_status);
    END IF;
    -- end of bug 2668298.


    -- Populate re_source_flag when project is not null, so that planning will
    -- not change Warehouse on the line.
    IF p_x_line_rec.project_id IS NOT NULL AND
	p_x_line_rec.project_id <> FND_API.G_MISS_NUM THEN

	p_x_line_rec.re_source_flag := 'N';

    END IF;


    /*
    ** Fix # 3147694 Start
    ** Following will be true only if the user is cancelling the
    ** order right after quantity on the lines was updated to 0.
    */

    IF p_x_line_rec.ordered_quantity = 0 AND
       p_old_line_rec.ordered_quantity = 0 AND
        OE_GLOBALS.g_recursion_mode = 'N' AND       -- Bug 3379121
       OE_OE_FORM_CANCEL_LINE.g_ord_lvl_can THEN

      IF l_debug_level > 0 THEN
        oe_debug_pub.add('Line Ord Qty already 0, Calling Check_Constraints based on Order Cancel Global');
      END IF;

      OE_SALES_CAN_UTIL.Check_Constraints
            (p_x_line_rec          => p_x_line_rec,
             p_old_line_rec  => p_old_line_rec,
             x_return_status => l_return_status
            );
      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        p_x_line_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        p_x_line_rec.return_status := FND_API.G_RET_STS_ERROR;
      END IF;

    END IF;
    /* Fix # 3147694 End   */


  IF OE_CODE_CONTROL.GET_CODE_RELEASE_LEVEL >='110510' THEN
  IF p_x_line_rec.operation = OE_GLOBALS.G_OPR_CREATE OR
    (p_x_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE AND
     ( ( NOT OE_GLOBALS.EQUAL(p_x_line_rec.ship_from_org_id
                                                      ,p_old_line_rec.ship_from_org_id)
       AND p_old_line_rec.ship_from_org_id <> FND_API.G_MISS_NUM) OR
     ( NOT OE_GLOBALS.EQUAL(p_x_line_rec.ship_to_org_id
                                                      ,p_old_line_rec.ship_to_org_id)
       AND p_old_line_rec.ship_to_org_id <> FND_API.G_MISS_NUM) OR
     ( NOT OE_GLOBALS.EQUAL(p_x_line_rec.inventory_item_id
                                                      ,p_old_line_rec.inventory_item_id)
       AND p_old_line_rec.inventory_item_id <> FND_API.G_MISS_NUM) OR
     ( NOT OE_GLOBALS.EQUAL(p_x_line_rec.order_quantity_uom
                                                      ,p_old_line_rec.order_quantity_uom)
       AND p_old_line_rec.order_quantity_uom <> FND_API.G_MISS_CHAR) OR
     ( NOT OE_GLOBALS.EQUAL(p_x_line_rec.ordered_quantity
                                                      ,p_old_line_rec.ordered_quantity)
       AND p_old_line_rec.ordered_quantity <> FND_API.G_MISS_NUM) OR
     ( NOT OE_GLOBALS.EQUAL(p_x_line_rec.schedule_ship_date
                                                      ,p_old_line_rec.schedule_ship_date)
       AND p_old_line_rec.schedule_ship_date <> FND_API.G_MISS_DATE) OR
     ( NOT OE_GLOBALS.EQUAL(p_x_line_rec.schedule_arrival_date
                                                      ,p_old_line_rec.schedule_arrival_date)
       AND p_old_line_rec.schedule_arrival_date <> FND_API.G_MISS_DATE) OR
     ( NOT OE_GLOBALS.EQUAL(p_x_line_rec.freight_terms_code
                                                      ,p_old_line_rec.freight_terms_code)
       AND p_old_line_rec.freight_terms_code <> FND_API.G_MISS_CHAR)))
       THEN
          IF OE_GLOBALS.G_FTE_REINVOKE IS NULL THEN
            Select Count(*) into l_fte_count
             from oe_price_adjustments where
             header_id = p_x_line_rec.header_id
             and LIST_LINE_TYPE_CODE = 'OM_CALLED_CHOOSE_SHIP_METHOD';
            if l_debug_level > 0 then
             oe_debug_pub.add( 'Value of fte count '||l_fte_count);
            end if;
            If l_fte_count > 0  Then
                  --fnd_message.set_name('ONT','MY_MESSAGE');
                  --OE_MSG_PUB.Add;
                    --NULL;
                     OE_GLOBALS.G_FTE_REINVOKE := 'Y';
            ELSE
	             OE_GLOBALS.G_FTE_REINVOKE := 'N';
            End If;
	  END IF;
  END IF;
  END IF;

    -- Moved to OE_ACKNOWLEDGMENT_PUB as part of 3417899 and 3412458
    /* IF l_3a7_attribute_change = FND_API.G_TRUE
       AND OE_Code_Control.code_release_level >= '110510'
       AND NVL(FND_PROFILE.VALUE('ONT_3A7_RESPONSE_REQUIRED'), 'N') = 'Y'
       AND p_x_line_rec.order_source_id= OE_Acknowledgment_Pub.G_XML_ORDER_SOURCE_ID
       AND nvl(p_x_line_rec.xml_transaction_type_code, OE_Acknowledgment_Pub.G_TRANSACTION_CSO) = OE_Acknowledgment_Pub.G_TRANSACTION_CSO
       AND p_x_line_rec.booked_flag = 'Y'
       AND p_x_line_rec.ordered_quantity <> 0 -- for bug 3421996
    THEN
           IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'Calling OE_Acknowlegment_PUB.Apply_3A7_Hold', 2 ) ;
           END IF;
           OE_Acknowledgment_PUB.Apply_3A7_Hold
                             ( p_header_id       =>  p_x_line_rec.header_id
                             , p_line_id         =>   p_x_line_rec.line_id
                             , p_sold_to_org_id  =>   p_x_line_rec.sold_to_org_id
                             , x_return_status   =>   l_return_status);
           IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'Return status after call to apply_3a7_hold:' || l_return_status, 2 ) ;
           END IF;
    END IF; */

   /*Bug2848734 */
   IF NOT OE_GLOBALS.Equal(p_x_line_rec.return_context, p_old_line_rec.return_context) THEN
    IF (p_x_line_rec.line_category_code = 'RETURN' and
       p_x_line_rec.OPERATION = OE_GLOBALS.G_OPR_UPDATE and
       p_x_line_rec.return_context IS NULL ) THEN

       p_x_line_rec.reference_customer_trx_line_id := NULL;
       p_x_line_rec.credit_invoice_line_id := NULL;
       p_x_line_rec.reference_line_id := NULL;
       p_x_line_rec.reference_header_id := NULL;
    END IF;
  END IF;
  /*Bug2848734*/

  if l_debug_level > 0 then
    oe_debug_pub.add('return status before exiting '|| p_x_line_rec.return_status, 1);
    oe_debug_pub.add('Exiting OE_LINE_UTIL.APPLY_ATTRIBUTE_CHANGES', 1);
  end if;

END Apply_Attribute_Changes;



/*----------------------------------------------------------
PROCEDURE Complete_Record
-----------------------------------------------------------*/

PROCEDURE Complete_Record
(   p_x_line_rec                    IN OUT NOCOPY  OE_Order_PUB.Line_Rec_Type
,   p_old_line_rec                  IN  OE_Order_PUB.Line_Rec_Type
)
IS
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('Entering OE_LINE_UTIL.COMPLETE_RECORD', 1);
  END IF;

    IF p_x_line_rec.accounting_rule_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.accounting_rule_id := p_old_line_rec.accounting_rule_id;
    END IF;

    IF p_x_line_rec.accounting_rule_duration = FND_API.G_MISS_NUM THEN
        p_x_line_rec.accounting_rule_duration := p_old_line_rec.accounting_rule_duration;
    END IF;

    IF p_x_line_rec.actual_arrival_date = FND_API.G_MISS_DATE THEN
        p_x_line_rec.actual_arrival_date := p_old_line_rec.actual_arrival_date;
    END IF;

    IF p_x_line_rec.actual_shipment_date = FND_API.G_MISS_DATE THEN
        p_x_line_rec.actual_shipment_date := p_old_line_rec.actual_shipment_date;
    END IF;

    IF p_x_line_rec.agreement_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.agreement_id := p_old_line_rec.agreement_id;
    END IF;

    IF p_x_line_rec.arrival_set_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.arrival_Set_id := p_old_line_rec.arrival_set_id;
    END IF;

    IF p_x_line_rec.ato_line_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.ato_line_id := p_old_line_rec.ato_line_id;
    END IF;
    IF p_x_line_rec.upgraded_flag = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.upgraded_flag := p_old_line_rec.upgraded_flag;
    END IF;

    IF p_x_line_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.attribute1 := p_old_line_rec.attribute1;
    END IF;

    IF p_x_line_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.attribute10 := p_old_line_rec.attribute10;
    END IF;

    IF p_x_line_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.attribute11 := p_old_line_rec.attribute11;
    END IF;

    IF p_x_line_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.attribute12 := p_old_line_rec.attribute12;
    END IF;

    IF p_x_line_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.attribute13 := p_old_line_rec.attribute13;
    END IF;

    IF p_x_line_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.attribute14 := p_old_line_rec.attribute14;
    END IF;

    IF p_x_line_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.attribute15 := p_old_line_rec.attribute15;
    END IF;

    IF p_x_line_rec.attribute16 = FND_API.G_MISS_CHAR THEN  --Bug 2184255
        p_x_line_rec.attribute16 := p_old_line_rec.attribute16;
    END IF;

    IF p_x_line_rec.attribute17 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.attribute17 := p_old_line_rec.attribute17;
    END IF;

    IF p_x_line_rec.attribute18 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.attribute18 := p_old_line_rec.attribute18;
    END IF;

    IF p_x_line_rec.attribute19 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.attribute19 := p_old_line_rec.attribute19;
    END IF;

    IF p_x_line_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.attribute2 := p_old_line_rec.attribute2;
    END IF;

    IF p_x_line_rec.attribute20 = FND_API.G_MISS_CHAR THEN  -- 2184255
        p_x_line_rec.attribute20 := p_old_line_rec.attribute20;
    END IF;

    IF p_x_line_rec.calculate_price_flag = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.calculate_price_flag := p_old_line_rec.calculate_price_flag;
    END IF;

    IF p_x_line_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.attribute3 := p_old_line_rec.attribute3;
    END IF;

    IF p_x_line_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.attribute4 := p_old_line_rec.attribute4;
    END IF;

    IF p_x_line_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.attribute5 := p_old_line_rec.attribute5;
    END IF;

    IF p_x_line_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.attribute6 := p_old_line_rec.attribute6;
    END IF;

    IF p_x_line_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.attribute7 := p_old_line_rec.attribute7;
    END IF;

    IF p_x_line_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.attribute8 := p_old_line_rec.attribute8;
    END IF;

    IF p_x_line_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.attribute9 := p_old_line_rec.attribute9;
    END IF;

    IF p_x_line_rec.auto_selected_quantity = FND_API.G_MISS_NUM THEN
        p_x_line_rec.auto_selected_quantity := p_old_line_rec.auto_selected_quantity;
    END IF;
    IF p_x_line_rec.authorized_to_ship_flag = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.authorized_to_ship_flag := p_old_line_rec.authorized_to_ship_flag;
    END IF;

    IF p_x_line_rec.booked_flag = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.booked_flag := p_old_line_rec.booked_flag;
    END IF;

    IF p_x_line_rec.cancelled_flag = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.cancelled_flag := p_old_line_rec.cancelled_flag;
    END IF;

    IF p_x_line_rec.cancelled_quantity = FND_API.G_MISS_NUM THEN
        p_x_line_rec.cancelled_quantity := p_old_line_rec.cancelled_quantity;
    END IF;

    IF p_x_line_rec.component_code = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.component_code := p_old_line_rec.component_code;
    END IF;

    IF p_x_line_rec.component_number = FND_API.G_MISS_NUM THEN
        p_x_line_rec.component_number := p_old_line_rec.component_number;
    END IF;

    IF p_x_line_rec.component_sequence_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.component_sequence_id := p_old_line_rec.component_sequence_id;
    END IF;

    IF p_x_line_rec.config_header_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.config_header_id := p_old_line_rec.config_header_id;
    END IF;

    IF p_x_line_rec.config_rev_nbr = FND_API.G_MISS_NUM THEN
        p_x_line_rec.config_rev_nbr := p_old_line_rec.config_rev_nbr;
    END IF;

    IF p_x_line_rec.config_display_sequence = FND_API.G_MISS_NUM THEN
        p_x_line_rec.config_display_sequence := p_old_line_rec.config_display_sequence;
    END IF;

    IF p_x_line_rec.configuration_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.configuration_id := p_old_line_rec.configuration_id;
    END IF;

    IF p_x_line_rec.context = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.context := p_old_line_rec.context;
    END IF;

    --recurring charges
    IF p_x_line_rec.charge_periodicity_code = FND_API.G_MISS_CHAR THEN
       p_x_line_rec.charge_periodicity_code :=
                         p_old_line_rec.charge_periodicity_code;
    END IF;

    --Customer Acceptance
     IF p_x_line_rec.CONTINGENCY_ID  = FND_API.G_MISS_NUM THEN
        p_x_line_rec.CONTINGENCY_ID  := p_old_line_rec.CONTINGENCY_ID  ;
    END IF;
     IF p_x_line_rec.REVREC_EVENT_CODE = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.REVREC_EVENT_CODE:= p_old_line_rec.REVREC_EVENT_CODE  ;
    END IF;
     IF p_x_line_rec.REVREC_EXPIRATION_DAYS = FND_API.G_MISS_NUM THEN
        p_x_line_rec.REVREC_EXPIRATION_DAYS:= p_old_line_rec.REVREC_EXPIRATION_DAYS;
    END IF;
     IF p_x_line_rec.ACCEPTED_QUANTITY = FND_API.G_MISS_NUM THEN
        p_x_line_rec.ACCEPTED_QUANTITY:= p_old_line_rec.ACCEPTED_QUANTITY;
    END IF;
     IF p_x_line_rec.REVREC_COMMENTS = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.REVREC_COMMENTS:= p_old_line_rec.REVREC_COMMENTS;
    END IF;
     IF p_x_line_rec.REVREC_SIGNATURE = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.REVREC_SIGNATURE:= p_old_line_rec.REVREC_SIGNATURE;
    END IF;
     IF p_x_line_rec.REVREC_SIGNATURE_DATE = FND_API.G_MISS_DATE THEN
        p_x_line_rec.REVREC_SIGNATURE_DATE:= p_old_line_rec.REVREC_SIGNATURE_DATE;
    END IF;
     IF p_x_line_rec.ACCEPTED_BY = FND_API.G_MISS_NUM THEN
        p_x_line_rec.ACCEPTED_BY:= p_old_line_rec.ACCEPTED_BY;
    END IF;
     IF p_x_line_rec.REVREC_REFERENCE_DOCUMENT = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.REVREC_REFERENCE_DOCUMENT:= p_old_line_rec.REVREC_REFERENCE_DOCUMENT;
    END IF;
     IF p_x_line_rec.REVREC_IMPLICIT_FLAG = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.REVREC_IMPLICIT_FLAG:= p_old_line_rec.REVREC_IMPLICIT_FLAG;
    END IF;
    --Customer Acceptance end

    IF p_x_line_rec.created_by = FND_API.G_MISS_NUM THEN
        p_x_line_rec.created_by := p_old_line_rec.created_by;
    END IF;

    IF p_x_line_rec.creation_date = FND_API.G_MISS_DATE THEN
        p_x_line_rec.creation_date := p_old_line_rec.creation_date;
    END IF;

     IF p_x_line_rec.credit_invoice_line_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.credit_invoice_line_id := p_old_line_rec.credit_invoice_line_id;
     END IF;

    IF p_x_line_rec.customer_dock_code = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.customer_dock_code := p_old_line_rec.customer_dock_code;
    END IF;

    IF p_x_line_rec.customer_job = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.customer_job := p_old_line_rec.customer_job;
    END IF;

    IF p_x_line_rec.customer_production_line = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.customer_production_line := p_old_line_rec.customer_production_line;
    END IF;
     IF p_x_line_rec.cust_production_seq_num = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.cust_production_seq_num := p_old_line_rec.cust_production_seq_num;
    END IF;
    IF p_x_line_rec.customer_trx_line_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.customer_trx_line_id := p_old_line_rec.customer_trx_line_id;
    END IF;

    IF p_x_line_rec.cust_model_serial_number = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.cust_model_serial_number := p_old_line_rec.cust_model_serial_number;
    END IF;

    IF p_x_line_rec.cust_po_number = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.cust_po_number := p_old_line_rec.cust_po_number;
    END IF;

    IF p_x_line_rec.customer_line_number = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.customer_line_number := p_old_line_rec.customer_line_number;
    END IF;

    IF p_x_line_rec.customer_shipment_number = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.customer_shipment_number := p_old_line_rec.customer_shipment_number;
    END IF;

    IF p_x_line_rec.delivery_lead_time = FND_API.G_MISS_NUM THEN
        p_x_line_rec.delivery_lead_time := p_old_line_rec.delivery_lead_time;
    END IF;
    IF p_x_line_rec.deliver_to_contact_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.deliver_to_contact_id := p_old_line_rec.deliver_to_contact_id;
    END IF;

    IF p_x_line_rec.deliver_to_org_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.deliver_to_org_id := p_old_line_rec.deliver_to_org_id;
    END IF;

    IF p_x_line_rec.demand_bucket_type_code = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.demand_bucket_type_code := p_old_line_rec.demand_bucket_type_code;
    END IF;

    IF p_x_line_rec.demand_class_code = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.demand_class_code := p_old_line_rec.demand_class_code;
    END IF;

    IF p_x_line_rec.dep_plan_required_flag = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.dep_plan_required_flag := p_old_line_rec.dep_plan_required_flag;
    END IF;



    IF p_x_line_rec.earliest_acceptable_date = FND_API.G_MISS_DATE THEN
        p_x_line_rec.earliest_acceptable_date := p_old_line_rec.earliest_acceptable_date;
    END IF;

    IF p_x_line_rec.explosion_date = FND_API.G_MISS_DATE THEN
        p_x_line_rec.explosion_date := p_old_line_rec.explosion_date;
    END IF;

    IF p_x_line_rec.fob_point_code = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.fob_point_code := p_old_line_rec.fob_point_code;
    END IF;

    IF p_x_line_rec.freight_carrier_code = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.freight_carrier_code := p_old_line_rec.freight_carrier_code;
    END IF;

    IF p_x_line_rec.freight_terms_code = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.freight_terms_code := p_old_line_rec.freight_terms_code;
    END IF;

    IF p_x_line_rec.fulfilled_quantity = FND_API.G_MISS_NUM THEN
        p_x_line_rec.fulfilled_quantity := p_old_line_rec.fulfilled_quantity;
    END IF;

    IF p_x_line_rec.fulfilled_flag = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.fulfilled_flag := p_old_line_rec.fulfilled_flag;
    END IF;

    IF p_x_line_rec.fulfillment_method_code = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.fulfillment_method_code := p_old_line_rec.fulfillment_method_code;
    END IF;

    IF p_x_line_rec.fulfillment_date = FND_API.G_MISS_DATE THEN
        p_x_line_rec.fulfillment_date := p_old_line_rec.fulfillment_date;
    END IF;

    IF p_x_line_rec.global_attribute1 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.global_attribute1 := p_old_line_rec.global_attribute1;
    END IF;

    IF p_x_line_rec.global_attribute10 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.global_attribute10 := p_old_line_rec.global_attribute10;
    END IF;

    IF p_x_line_rec.global_attribute11 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.global_attribute11 := p_old_line_rec.global_attribute11;
    END IF;

    IF p_x_line_rec.global_attribute12 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.global_attribute12 := p_old_line_rec.global_attribute12;
    END IF;

    IF p_x_line_rec.global_attribute13 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.global_attribute13 := p_old_line_rec.global_attribute13;
    END IF;

    IF p_x_line_rec.global_attribute14 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.global_attribute14 := p_old_line_rec.global_attribute14;
    END IF;

    IF p_x_line_rec.global_attribute15 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.global_attribute15 := p_old_line_rec.global_attribute15;
    END IF;

    IF p_x_line_rec.global_attribute16 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.global_attribute16 := p_old_line_rec.global_attribute16;
    END IF;

    IF p_x_line_rec.global_attribute17 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.global_attribute17 := p_old_line_rec.global_attribute17;
    END IF;

    IF p_x_line_rec.global_attribute18 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.global_attribute18 := p_old_line_rec.global_attribute18;
    END IF;

    IF p_x_line_rec.global_attribute19 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.global_attribute19 := p_old_line_rec.global_attribute19;
    END IF;

    IF p_x_line_rec.global_attribute2 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.global_attribute2 := p_old_line_rec.global_attribute2;
    END IF;

    IF p_x_line_rec.global_attribute20 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.global_attribute20 := p_old_line_rec.global_attribute20;
    END IF;

    IF p_x_line_rec.global_attribute3 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.global_attribute3 := p_old_line_rec.global_attribute3;
    END IF;

    IF p_x_line_rec.global_attribute4 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.global_attribute4 := p_old_line_rec.global_attribute4;
    END IF;

    IF p_x_line_rec.global_attribute5 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.global_attribute5 := p_old_line_rec.global_attribute5;
    END IF;

    IF p_x_line_rec.global_attribute6 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.global_attribute6 := p_old_line_rec.global_attribute6;
    END IF;

    IF p_x_line_rec.global_attribute7 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.global_attribute7 := p_old_line_rec.global_attribute7;
    END IF;

    IF p_x_line_rec.global_attribute8 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.global_attribute8 := p_old_line_rec.global_attribute8;
    END IF;

    IF p_x_line_rec.global_attribute9 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.global_attribute9 := p_old_line_rec.global_attribute9;
    END IF;

    IF p_x_line_rec.global_attribute_category = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.global_attribute_category := p_old_line_rec.global_attribute_category;
    END IF;

    IF p_x_line_rec.header_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.header_id := p_old_line_rec.header_id;
    END IF;

    IF p_x_line_rec.industry_attribute1 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.industry_attribute1 := p_old_line_rec.industry_attribute1;
    END IF;

    IF p_x_line_rec.industry_attribute10 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.industry_attribute10 := p_old_line_rec.industry_attribute10;
    END IF;

    IF p_x_line_rec.industry_attribute11 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.industry_attribute11 := p_old_line_rec.industry_attribute11;
    END IF;

    IF p_x_line_rec.industry_attribute12 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.industry_attribute12 := p_old_line_rec.industry_attribute12;
    END IF;

    IF p_x_line_rec.industry_attribute13 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.industry_attribute13 := p_old_line_rec.industry_attribute13;
    END IF;

    IF p_x_line_rec.industry_attribute14 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.industry_attribute14 := p_old_line_rec.industry_attribute14;
    END IF;

    IF p_x_line_rec.industry_attribute15 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.industry_attribute15 := p_old_line_rec.industry_attribute15;
    END IF;

    IF p_x_line_rec.industry_attribute16 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.industry_attribute16 := p_old_line_rec.industry_attribute16;
    END IF;
    IF p_x_line_rec.industry_attribute17 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.industry_attribute17 := p_old_line_rec.industry_attribute17;
    END IF;
    IF p_x_line_rec.industry_attribute18 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.industry_attribute18 := p_old_line_rec.industry_attribute18;
    END IF;
    IF p_x_line_rec.industry_attribute19 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.industry_attribute19 := p_old_line_rec.industry_attribute19;
    END IF;
    IF p_x_line_rec.industry_attribute20 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.industry_attribute20 := p_old_line_rec.industry_attribute20;
    END IF;
    IF p_x_line_rec.industry_attribute21 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.industry_attribute21 := p_old_line_rec.industry_attribute21;
    END IF;
    IF p_x_line_rec.industry_attribute22 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.industry_attribute22 := p_old_line_rec.industry_attribute22;
    END IF;
    IF p_x_line_rec.industry_attribute23 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.industry_attribute23 := p_old_line_rec.industry_attribute23;
    END IF;
    IF p_x_line_rec.industry_attribute24 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.industry_attribute24 := p_old_line_rec.industry_attribute24;
    END IF;
    IF p_x_line_rec.industry_attribute25 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.industry_attribute25 := p_old_line_rec.industry_attribute25;
    END IF;
    IF p_x_line_rec.industry_attribute26 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.industry_attribute26 := p_old_line_rec.industry_attribute26;
    END IF;
    IF p_x_line_rec.industry_attribute27 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.industry_attribute27 := p_old_line_rec.industry_attribute27;
    END IF;
    IF p_x_line_rec.industry_attribute28 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.industry_attribute28 := p_old_line_rec.industry_attribute28;
    END IF;
    IF p_x_line_rec.industry_attribute29 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.industry_attribute29 := p_old_line_rec.industry_attribute29;
    END IF;
    IF p_x_line_rec.industry_attribute30 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.industry_attribute30 := p_old_line_rec.industry_attribute30;
    END IF;
    IF p_x_line_rec.industry_attribute2 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.industry_attribute2 := p_old_line_rec.industry_attribute2;
    END IF;

    IF p_x_line_rec.industry_attribute3 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.industry_attribute3 := p_old_line_rec.industry_attribute3;
    END IF;

    IF p_x_line_rec.industry_attribute4 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.industry_attribute4 := p_old_line_rec.industry_attribute4;
    END IF;

    IF p_x_line_rec.industry_attribute5 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.industry_attribute5 := p_old_line_rec.industry_attribute5;
    END IF;

    IF p_x_line_rec.industry_attribute6 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.industry_attribute6 := p_old_line_rec.industry_attribute6;
    END IF;

    IF p_x_line_rec.industry_attribute7 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.industry_attribute7 := p_old_line_rec.industry_attribute7;
    END IF;

    IF p_x_line_rec.industry_attribute8 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.industry_attribute8 := p_old_line_rec.industry_attribute8;
    END IF;

    IF p_x_line_rec.industry_attribute9 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.industry_attribute9 := p_old_line_rec.industry_attribute9;
    END IF;

    IF p_x_line_rec.industry_context = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.industry_context := p_old_line_rec.industry_context;
    END IF;

    /* TP_ATTRIBUTE */
    IF p_x_line_rec.tp_context = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.tp_context := p_old_line_rec.tp_context;
    END IF;

    IF p_x_line_rec.tp_attribute1 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.tp_attribute1 := p_old_line_rec.tp_attribute1;
    END IF;
    IF p_x_line_rec.tp_attribute2 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.tp_attribute2 := p_old_line_rec.tp_attribute2;
    END IF;
    IF p_x_line_rec.tp_attribute3 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.tp_attribute3 := p_old_line_rec.tp_attribute3;
    END IF;
    IF p_x_line_rec.tp_attribute4 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.tp_attribute4 := p_old_line_rec.tp_attribute4;
    END IF;
    IF p_x_line_rec.tp_attribute5 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.tp_attribute5 := p_old_line_rec.tp_attribute5;
    END IF;
    IF p_x_line_rec.tp_attribute6 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.tp_attribute6 := p_old_line_rec.tp_attribute6;
    END IF;
    IF p_x_line_rec.tp_attribute7 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.tp_attribute7 := p_old_line_rec.tp_attribute7;
    END IF;
    IF p_x_line_rec.tp_attribute8 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.tp_attribute8 := p_old_line_rec.tp_attribute8;
    END IF;
    IF p_x_line_rec.tp_attribute9 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.tp_attribute9 := p_old_line_rec.tp_attribute9;
    END IF;
    IF p_x_line_rec.tp_attribute10 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.tp_attribute10 := p_old_line_rec.tp_attribute10;
    END IF;
    IF p_x_line_rec.tp_attribute11 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.tp_attribute11 := p_old_line_rec.tp_attribute11;
    END IF;
    IF p_x_line_rec.tp_attribute12 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.tp_attribute12 := p_old_line_rec.tp_attribute12;
    END IF;
    IF p_x_line_rec.tp_attribute13 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.tp_attribute13 := p_old_line_rec.tp_attribute13;
    END IF;
    IF p_x_line_rec.tp_attribute14 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.tp_attribute14 := p_old_line_rec.tp_attribute14;
    END IF;
    IF p_x_line_rec.tp_attribute15 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.tp_attribute15 := p_old_line_rec.tp_attribute15;
    END IF;


    IF p_x_line_rec.intermed_ship_to_contact_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.intermed_ship_to_contact_id := p_old_line_rec.intermed_ship_to_contact_id;
    END IF;

    IF p_x_line_rec.intermed_ship_to_org_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.intermed_ship_to_org_id := p_old_line_rec.intermed_ship_to_org_id;
    END IF;

    IF p_x_line_rec.inventory_item_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.inventory_item_id := p_old_line_rec.inventory_item_id;
    END IF;

    IF p_x_line_rec.invoice_interface_status_code = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.invoice_interface_status_code := p_old_line_rec.invoice_interface_status_code;
    END IF;



    IF p_x_line_rec.invoice_to_contact_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.invoice_to_contact_id := p_old_line_rec.invoice_to_contact_id;
    END IF;

    IF p_x_line_rec.invoice_to_org_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.invoice_to_org_id := p_old_line_rec.invoice_to_org_id;
    END IF;

    IF p_x_line_rec.invoiced_quantity = FND_API.G_MISS_NUM THEN
        p_x_line_rec.invoiced_quantity := p_old_line_rec.invoiced_quantity;
    END IF;

    IF p_x_line_rec.invoicing_rule_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.invoicing_rule_id := p_old_line_rec.invoicing_rule_id;
    END IF;

    IF p_x_line_rec.ordered_item_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.ordered_item_id := p_old_line_rec.ordered_item_id;
    END IF;

    IF p_x_line_rec.item_identifier_type = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.item_identifier_type := p_old_line_rec.item_identifier_type;
    END IF;

    IF p_x_line_rec.ordered_item = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.ordered_item := p_old_line_rec.ordered_item;
    END IF;

    IF p_x_line_rec.item_revision = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.item_revision := p_old_line_rec.item_revision;
    END IF;

    IF p_x_line_rec.item_type_code = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.item_type_code := p_old_line_rec.item_type_code;
    END IF;

    IF p_x_line_rec.last_updated_by = FND_API.G_MISS_NUM THEN
        p_x_line_rec.last_updated_by := p_old_line_rec.last_updated_by;
    END IF;

    IF p_x_line_rec.last_update_date = FND_API.G_MISS_DATE THEN
        p_x_line_rec.last_update_date := p_old_line_rec.last_update_date;
    END IF;

    IF p_x_line_rec.last_update_login = FND_API.G_MISS_NUM THEN
        p_x_line_rec.last_update_login := p_old_line_rec.last_update_login;
    END IF;

    IF p_x_line_rec.latest_acceptable_date = FND_API.G_MISS_DATE THEN
        p_x_line_rec.latest_acceptable_date := p_old_line_rec.latest_acceptable_date;
    END IF;

    IF p_x_line_rec.line_category_code = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.line_category_code := p_old_line_rec.line_category_code;
    END IF;

    IF p_x_line_rec.line_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.line_id := p_old_line_rec.line_id;
    END IF;

    IF p_x_line_rec.line_number = FND_API.G_MISS_NUM THEN
        p_x_line_rec.line_number := p_old_line_rec.line_number;
    END IF;

    IF p_x_line_rec.line_type_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.line_type_id := p_old_line_rec.line_type_id;
    END IF;

    IF p_x_line_rec.link_to_line_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.link_to_line_id := p_old_line_rec.link_to_line_id;
    END IF;

    IF p_x_line_rec.model_group_number = FND_API.G_MISS_NUM THEN
        p_x_line_rec.model_group_number := p_old_line_rec.model_group_number;
    END IF;

    IF p_x_line_rec.mfg_component_sequence_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.mfg_component_sequence_id := p_old_line_rec.mfg_component_sequence_id;
    END IF;

    IF p_x_line_rec.mfg_lead_time = FND_API.G_MISS_NUM THEN
        p_x_line_rec.mfg_lead_time := p_old_line_rec.mfg_lead_time;
    END IF;

    IF p_x_line_rec.open_flag = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.open_flag := p_old_line_rec.open_flag;
    END IF;

    IF p_x_line_rec.option_flag = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.option_flag := p_old_line_rec.option_flag;
    END IF;

    IF p_x_line_rec.option_number = FND_API.G_MISS_NUM THEN
        p_x_line_rec.option_number := p_old_line_rec.option_number;
    END IF;

    IF p_x_line_rec.ordered_quantity = FND_API.G_MISS_NUM THEN
        p_x_line_rec.ordered_quantity := p_old_line_rec.ordered_quantity;
    END IF;

    -- OPM 02/JUN/00 INVCONV
    IF p_x_line_rec.ordered_quantity2 = FND_API.G_MISS_NUM THEN
        p_x_line_rec.ordered_quantity2 := p_old_line_rec.ordered_quantity2;
    END IF;
    -- OPM 02/JUN/00 END

    IF p_x_line_rec.order_quantity_uom = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.order_quantity_uom := p_old_line_rec.order_quantity_uom;
    END IF;

    -- OPM 02/JUN/00 INVCONV

    IF p_x_line_rec.ordered_quantity_uom2 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.ordered_quantity_uom2 :=p_old_line_rec.ordered_quantity_uom2;
    END IF;
    -- OPM 02/JUN/00 END

    IF p_x_line_rec.org_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.org_id := p_old_line_rec.org_id;
    END IF;

    IF p_x_line_rec.orig_sys_document_ref = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.orig_sys_document_ref := p_old_line_rec.orig_sys_document_ref;
    END IF;

    IF p_x_line_rec.orig_sys_line_ref = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.orig_sys_line_ref := p_old_line_rec.orig_sys_line_ref;
    END IF;

    IF p_x_line_rec.orig_sys_shipment_ref = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.orig_sys_shipment_ref := p_old_line_rec.orig_sys_shipment_ref;
    END IF;

-- Override List Price
    IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510' THEN
       IF p_x_line_rec.original_list_price = FND_API.G_MISS_NUM THEN
          p_x_line_rec.original_list_price:= p_old_line_rec.original_list_price;
       END IF;
    END IF;
-- Override List Price

   IF p_x_line_rec.over_ship_reason_code = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.over_ship_reason_code := p_old_line_rec.over_ship_reason_code;
    END IF;

    IF p_x_line_rec.over_ship_resolved_flag = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.over_ship_resolved_flag := p_old_line_rec.over_ship_resolved_flag;
    END IF;

    IF p_x_line_rec.payment_term_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.payment_term_id := p_old_line_rec.payment_term_id;
    END IF;

    IF p_x_line_rec.planning_priority = FND_API.G_MISS_NUM THEN
        p_x_line_rec.planning_priority := p_old_line_rec.planning_priority;
    END IF;

    -- OPM 02/JUN/00 INVCONV
    IF p_x_line_rec.preferred_grade = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.preferred_grade :=p_old_line_rec.preferred_grade;
    END IF;
    -- OPM 02/JUN/00 END

    IF p_x_line_rec.price_list_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.price_list_id := p_old_line_rec.price_list_id;
    END IF;

    -- PROMOTIONS SEP/01 BEGIN
    IF p_x_line_rec.price_request_code = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.price_request_code := p_old_line_rec.price_request_code;
    END IF;
    -- PROMOTIONS SEP/01 END

    IF p_x_line_rec.pricing_attribute1 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.pricing_attribute1 := p_old_line_rec.pricing_attribute1;
    END IF;

    IF p_x_line_rec.pricing_attribute10 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.pricing_attribute10 := p_old_line_rec.pricing_attribute10;
    END IF;

    IF p_x_line_rec.pricing_attribute2 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.pricing_attribute2 := p_old_line_rec.pricing_attribute2;
    END IF;

    IF p_x_line_rec.pricing_attribute3 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.pricing_attribute3 := p_old_line_rec.pricing_attribute3;
    END IF;

    IF p_x_line_rec.pricing_attribute4 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.pricing_attribute4 := p_old_line_rec.pricing_attribute4;
    END IF;

    IF p_x_line_rec.pricing_attribute5 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.pricing_attribute5 := p_old_line_rec.pricing_attribute5;
    END IF;

    IF p_x_line_rec.pricing_attribute6 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.pricing_attribute6 := p_old_line_rec.pricing_attribute6;
    END IF;

    IF p_x_line_rec.pricing_attribute7 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.pricing_attribute7 := p_old_line_rec.pricing_attribute7;
    END IF;

    IF p_x_line_rec.pricing_attribute8 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.pricing_attribute8 := p_old_line_rec.pricing_attribute8;
    END IF;

    IF p_x_line_rec.pricing_attribute9 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.pricing_attribute9 := p_old_line_rec.pricing_attribute9;
    END IF;

    IF p_x_line_rec.pricing_context = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.pricing_context := p_old_line_rec.pricing_context;
    END IF;

    IF p_x_line_rec.pricing_date = FND_API.G_MISS_DATE THEN
        p_x_line_rec.pricing_date := p_old_line_rec.pricing_date;
    END IF;

    IF p_x_line_rec.pricing_quantity = FND_API.G_MISS_NUM THEN
        p_x_line_rec.pricing_quantity := p_old_line_rec.pricing_quantity;
    END IF;

    IF p_x_line_rec.pricing_quantity_uom = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.pricing_quantity_uom := p_old_line_rec.pricing_quantity_uom;
    END IF;

    IF p_x_line_rec.program_application_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.program_application_id := p_old_line_rec.program_application_id;
    END IF;

    IF p_x_line_rec.program_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.program_id := p_old_line_rec.program_id;
    END IF;

    IF p_x_line_rec.program_update_date = FND_API.G_MISS_DATE THEN
        p_x_line_rec.program_update_date := p_old_line_rec.program_update_date;
    END IF;

    IF p_x_line_rec.project_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.project_id := p_old_line_rec.project_id;
    END IF;

    IF p_x_line_rec.promise_date = FND_API.G_MISS_DATE THEN
        p_x_line_rec.promise_date := p_old_line_rec.promise_date;
    END IF;

    IF p_x_line_rec.re_source_flag = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.re_source_flag := p_old_line_rec.re_source_flag;
    END IF;

    IF p_x_line_rec.reference_customer_trx_line_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.reference_customer_trx_line_id := p_old_line_rec.reference_customer_trx_line_id;
    END IF;

    IF p_x_line_rec.reference_header_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.reference_header_id := p_old_line_rec.reference_header_id;
    END IF;

    IF p_x_line_rec.reference_line_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.reference_line_id := p_old_line_rec.reference_line_id;
    END IF;

    IF p_x_line_rec.reference_type = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.reference_type := p_old_line_rec.reference_type;
    END IF;



    IF p_x_line_rec.request_date = FND_API.G_MISS_DATE THEN
        p_x_line_rec.request_date := p_old_line_rec.request_date;
    END IF;

    IF p_x_line_rec.request_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.request_id := p_old_line_rec.request_id;
    END IF;

    IF p_x_line_rec.reserved_quantity = FND_API.G_MISS_NUM THEN
        p_x_line_rec.reserved_quantity := p_old_line_rec.reserved_quantity;
    END IF;



    IF p_x_line_rec.return_attribute1 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.return_attribute1 := p_old_line_rec.return_attribute1;
    END IF;

    IF p_x_line_rec.return_attribute10 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.return_attribute10 := p_old_line_rec.return_attribute10;
    END IF;

    IF p_x_line_rec.return_attribute11 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.return_attribute11 := p_old_line_rec.return_attribute11;
    END IF;

    IF p_x_line_rec.return_attribute12 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.return_attribute12 := p_old_line_rec.return_attribute12;
    END IF;

    IF p_x_line_rec.return_attribute13 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.return_attribute13 := p_old_line_rec.return_attribute13;
    END IF;

    IF p_x_line_rec.return_attribute14 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.return_attribute14 := p_old_line_rec.return_attribute14;
    END IF;

    IF p_x_line_rec.return_attribute15 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.return_attribute15 := p_old_line_rec.return_attribute15;
    END IF;

    IF p_x_line_rec.return_attribute2 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.return_attribute2 := p_old_line_rec.return_attribute2;
    END IF;

    IF p_x_line_rec.return_attribute3 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.return_attribute3 := p_old_line_rec.return_attribute3;
    END IF;

    IF p_x_line_rec.return_attribute4 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.return_attribute4 := p_old_line_rec.return_attribute4;
    END IF;

    IF p_x_line_rec.return_attribute5 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.return_attribute5 := p_old_line_rec.return_attribute5;
    END IF;

    IF p_x_line_rec.return_attribute6 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.return_attribute6 := p_old_line_rec.return_attribute6;
    END IF;

    IF p_x_line_rec.return_attribute7 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.return_attribute7 := p_old_line_rec.return_attribute7;
    END IF;

    IF p_x_line_rec.return_attribute8 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.return_attribute8 := p_old_line_rec.return_attribute8;
    END IF;

    IF p_x_line_rec.return_attribute9 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.return_attribute9 := p_old_line_rec.return_attribute9;
    END IF;

    IF p_x_line_rec.return_context = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.return_context := p_old_line_rec.return_context;
    END IF;

    IF p_x_line_rec.return_reason_code = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.return_reason_code := p_old_line_rec.return_reason_code;
    END IF;
    IF p_x_line_rec.salesrep_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.salesrep_id := p_old_line_rec.salesrep_id;
    END IF;

    IF p_x_line_rec.rla_schedule_type_code = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.rla_schedule_type_code := p_old_line_rec.rla_schedule_type_code;
    END IF;

    IF p_x_line_rec.schedule_arrival_date = FND_API.G_MISS_DATE THEN
        p_x_line_rec.schedule_arrival_date := p_old_line_rec.schedule_arrival_date;
    END IF;

    IF p_x_line_rec.schedule_ship_date = FND_API.G_MISS_DATE THEN
        p_x_line_rec.schedule_ship_date := p_old_line_rec.schedule_ship_date;
    END IF;

    IF p_x_line_rec.schedule_action_code = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.schedule_action_code := p_old_line_rec.schedule_action_code;
    END IF;

    IF p_x_line_rec.schedule_status_code = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.schedule_status_code := p_old_line_rec.schedule_status_code;
    END IF;

    IF p_x_line_rec.shipment_number = FND_API.G_MISS_NUM THEN
        p_x_line_rec.shipment_number := p_old_line_rec.shipment_number;
    END IF;

    IF p_x_line_rec.shipment_priority_code = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.shipment_priority_code := p_old_line_rec.shipment_priority_code;
    END IF;

    IF p_x_line_rec.shipped_quantity = FND_API.G_MISS_NUM THEN
        p_x_line_rec.shipped_quantity := p_old_line_rec.shipped_quantity;
    END IF;

    IF p_x_line_rec.shipped_quantity2 = FND_API.G_MISS_NUM THEN -- OPM B1661023 04/02/01 INVCONV
        p_x_line_rec.shipped_quantity2 := p_old_line_rec.shipped_quantity2;
    END IF;

    IF p_x_line_rec.shipping_method_code = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.shipping_method_code := p_old_line_rec.shipping_method_code;
    END IF;

    IF p_x_line_rec.shipping_quantity = FND_API.G_MISS_NUM THEN
        p_x_line_rec.shipping_quantity := p_old_line_rec.shipping_quantity;
    END IF;

    IF p_x_line_rec.shipping_quantity2 = FND_API.G_MISS_NUM THEN -- OPM B1661023 04/02/01 INVCONV
        p_x_line_rec.shipping_quantity2 := p_old_line_rec.shipping_quantity2;
    END IF;

    IF p_x_line_rec.shipping_quantity_uom = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.shipping_quantity_uom := p_old_line_rec.shipping_quantity_uom;
    END IF;

    IF p_x_line_rec.ship_from_org_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.ship_from_org_id := p_old_line_rec.ship_from_org_id;
    END IF;

    IF p_x_line_rec.subinventory = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.subinventory := p_old_line_rec.subinventory;
    END IF;

    IF p_x_line_rec.ship_model_complete_flag = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.ship_model_complete_flag := p_old_line_rec.ship_model_complete_flag;
    END IF;
    IF p_x_line_rec.ship_set_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.ship_Set_id := p_old_line_rec.ship_set_id;
    END IF;

    IF p_x_line_rec.ship_tolerance_above = FND_API.G_MISS_NUM THEN
        p_x_line_rec.ship_tolerance_above := p_old_line_rec.ship_tolerance_above;
    END IF;

    IF p_x_line_rec.ship_tolerance_below = FND_API.G_MISS_NUM THEN
        p_x_line_rec.ship_tolerance_below := p_old_line_rec.ship_tolerance_below;
    END IF;

    IF p_x_line_rec.shippable_flag = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.shippable_flag := p_old_line_rec.shippable_flag;
    END IF;

    IF p_x_line_rec.shipping_interfaced_flag = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.shipping_interfaced_flag := p_old_line_rec.shipping_interfaced_flag;
    END IF;

    IF p_x_line_rec.ship_to_contact_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.ship_to_contact_id := p_old_line_rec.ship_to_contact_id;
    END IF;

    IF p_x_line_rec.ship_to_org_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.ship_to_org_id := p_old_line_rec.ship_to_org_id;
    END IF;

    IF p_x_line_rec.sold_from_org_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.sold_from_org_id := p_old_line_rec.sold_from_org_id;
    END IF;

    IF p_x_line_rec.sold_to_org_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.sold_to_org_id := p_old_line_rec.sold_to_org_id;
    END IF;

    IF p_x_line_rec.sort_order = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.sort_order := p_old_line_rec.sort_order;
    END IF;

    IF p_x_line_rec.source_document_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.source_document_id := p_old_line_rec.source_document_id;
    END IF;

    IF p_x_line_rec.source_document_line_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.source_document_line_id := p_old_line_rec.source_document_line_id;
    END IF;

    IF p_x_line_rec.source_document_type_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.source_document_type_id := p_old_line_rec.source_document_type_id;
    END IF;

    IF p_x_line_rec.source_type_code = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.source_type_code := p_old_line_rec.source_type_code;
    END IF;
    IF p_x_line_rec.split_from_line_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.split_from_line_id := p_old_line_rec.split_from_line_id;
    END IF;

    IF p_x_line_rec.line_set_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.line_set_id := p_old_line_rec.line_set_id;
    END IF;
    IF p_x_line_rec.split_by = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.split_by := p_old_line_rec.split_by;
    END IF;
    IF p_x_line_rec.model_remnant_flag = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.model_remnant_flag := p_old_line_rec.model_remnant_flag;
    END IF;

    IF p_x_line_rec.task_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.task_id := p_old_line_rec.task_id;
    END IF;

    IF p_x_line_rec.tax_code = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.tax_code := p_old_line_rec.tax_code;
    END IF;

    IF p_x_line_rec.tax_date = FND_API.G_MISS_DATE THEN
        p_x_line_rec.tax_date := p_old_line_rec.tax_date;
    END IF;

    IF p_x_line_rec.tax_exempt_flag = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.tax_exempt_flag := p_old_line_rec.tax_exempt_flag;
    END IF;

    IF p_x_line_rec.tax_exempt_number = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.tax_exempt_number := p_old_line_rec.tax_exempt_number;
    END IF;

    IF p_x_line_rec.tax_exempt_reason_code = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.tax_exempt_reason_code := p_old_line_rec.tax_exempt_reason_code;
    END IF;

    IF p_x_line_rec.tax_point_code = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.tax_point_code := p_old_line_rec.tax_point_code;
    END IF;

    IF p_x_line_rec.tax_rate = FND_API.G_MISS_NUM THEN
        p_x_line_rec.tax_rate := p_old_line_rec.tax_rate;
    END IF;

    IF p_x_line_rec.tax_value = FND_API.G_MISS_NUM THEN
        p_x_line_rec.tax_value := p_old_line_rec.tax_value;
    END IF;

    IF p_x_line_rec.top_model_line_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.top_model_line_id := p_old_line_rec.top_model_line_id;
    END IF;

    IF p_x_line_rec.unit_list_price = FND_API.G_MISS_NUM THEN
        p_x_line_rec.unit_list_price := p_old_line_rec.unit_list_price;
    END IF;

    IF p_x_line_rec.unit_list_price_per_pqty = FND_API.G_MISS_NUM THEN
        p_x_line_rec.unit_list_price_per_pqty := p_old_line_rec.unit_list_price_per_pqty;
    END IF;

    IF p_x_line_rec.unit_selling_price = FND_API.G_MISS_NUM THEN
        p_x_line_rec.unit_selling_price := p_old_line_rec.unit_selling_price;
    END IF;

    IF p_x_line_rec.unit_selling_price_per_pqty = FND_API.G_MISS_NUM THEN
        p_x_line_rec.unit_selling_price_per_pqty := p_old_line_rec.unit_selling_price_per_pqty;
    END IF;

    IF p_x_line_rec.visible_demand_flag = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.visible_demand_flag := p_old_line_rec.visible_demand_flag;
    END IF;
     IF p_x_line_rec.veh_cus_item_cum_key_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.veh_cus_item_cum_key_id := p_old_line_rec.veh_cus_item_cum_key_id;
    END IF;

    IF p_x_line_rec.first_ack_code = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.first_ack_code := p_old_line_rec.first_ack_code;
    END IF;

    IF p_x_line_rec.first_ack_date = FND_API.G_MISS_DATE THEN
        p_x_line_rec.first_ack_date := p_old_line_rec.first_ack_date;
    END IF;

    IF p_x_line_rec.last_ack_code = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.last_ack_code := p_old_line_rec.last_ack_code;
    END IF;

    IF p_x_line_rec.last_ack_date = FND_API.G_MISS_DATE THEN
        p_x_line_rec.last_ack_date := p_old_line_rec.last_ack_date;
    END IF;

    IF p_x_line_rec.end_item_unit_number = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.end_item_unit_number := p_old_line_rec.end_item_unit_number;
    END IF;

    IF p_x_line_rec.shipping_instructions = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.shipping_instructions := p_old_line_rec.shipping_instructions;
    END IF;

    IF p_x_line_rec.packing_instructions = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.packing_instructions := p_old_line_rec.packing_instructions;
    END IF;

    -- Service Related

    IF p_x_line_rec.service_txn_reason_code = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.service_txn_reason_code := p_old_line_rec.service_txn_reason_code;
    END IF;

    IF p_x_line_rec.service_txn_comments = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.service_txn_comments := p_old_line_rec.service_txn_comments;
    END IF;


    IF p_x_line_rec.service_duration = FND_API.G_MISS_NUM THEN
        p_x_line_rec.service_duration := p_old_line_rec.service_duration;
    END IF;

    IF p_x_line_rec.service_period = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.service_period := p_old_line_rec.service_period;
    END IF;

    IF p_x_line_rec.service_start_date = FND_API.G_MISS_DATE THEN
        p_x_line_rec.service_start_date := p_old_line_rec.service_start_date;
    END IF;

    IF p_x_line_rec.service_end_date = FND_API.G_MISS_DATE THEN
        p_x_line_rec.service_end_date := p_old_line_rec.service_end_date;
    END IF;

    IF p_x_line_rec.service_coterminate_flag = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.service_coterminate_flag := p_old_line_rec.service_coterminate_flag;
    END IF;

    IF p_x_line_rec.unit_list_percent = FND_API.G_MISS_NUM THEN
        p_x_line_rec.unit_list_percent := p_old_line_rec.unit_list_percent;
    END IF;

    IF p_x_line_rec.unit_selling_percent = FND_API.G_MISS_NUM THEN
        p_x_line_rec.unit_selling_percent := p_old_line_rec.unit_selling_percent;
    END IF;

    IF p_x_line_rec.unit_percent_base_price = FND_API.G_MISS_NUM THEN
        p_x_line_rec.unit_percent_base_price := p_old_line_rec.unit_percent_base_price;
    END IF;

    IF p_x_line_rec.service_number = FND_API.G_MISS_NUM THEN
        p_x_line_rec.service_number := p_old_line_rec.service_number;
    END IF;

    IF p_x_line_rec.service_reference_type_code = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.service_reference_type_code := p_old_line_rec.service_reference_type_code;
    END IF;

    IF p_x_line_rec.calculate_price_flag = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.calculate_price_flag := NULL;
    END IF;

    IF p_x_line_rec.service_reference_line_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.service_reference_line_id := p_old_line_rec.service_reference_line_id;
    END IF;

    IF p_x_line_rec.service_reference_system_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.service_reference_system_id := p_old_line_rec.service_reference_system_id;
    END IF;

   -- End of Service related columns

   /* Marketing source code related */

    IF p_x_line_rec.marketing_source_code_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.marketing_source_code_id := p_old_line_rec.marketing_source_code_id;
    END IF;

  /* end of Marketing source code id */

    IF p_x_line_rec.flow_status_code = 'ENTERED' THEN
       -- flow_status_code is initilized to ENTERED
       -- QUOTING change - do not override ENTERED status with old
       -- value as status should be set to entered during complete
       -- negotiation call
       IF OE_Quote_Util.G_COMPLETE_NEG = 'N' THEN
          p_x_line_rec.flow_status_code := p_old_line_rec.flow_status_code;
       END IF;
    -- elsif added for bug 8639681
    ELSIF p_x_line_rec.flow_status_code = fnd_api.g_miss_char THEN
       p_x_line_rec.flow_status_code := p_old_line_rec.flow_status_code;
    END IF;

    -- Commitment related
    IF p_x_line_rec.commitment_id = FND_API.G_MISS_NUM THEN
       p_x_line_rec.commitment_id := p_old_line_rec.commitment_id;
    END IF;

    IF p_x_line_rec.order_source_id = FND_API.G_MISS_NUM THEN
   if l_debug_level > 0 then
    oe_debug_pub.add('OEXULINB -aksingh complete_record - order_source_id');
   end if;
        p_x_line_rec.order_source_id := p_old_line_rec.order_source_id;
    END IF;

   -- Item Substitution changes.
   IF p_x_line_rec.Original_Inventory_Item_Id = FND_API.G_MISS_NUM THEN
       p_x_line_rec.Original_Inventory_Item_Id :=
                         p_old_line_rec.Original_Inventory_Item_Id;
   END IF;

   IF p_x_line_rec.Original_item_identifier_Type = FND_API.G_MISS_CHAR THEN
       p_x_line_rec.Original_item_identifier_Type :=
                         p_old_line_rec.Original_item_identifier_Type;
   END IF;

   IF p_x_line_rec.Original_ordered_item_id = FND_API.G_MISS_NUM THEN
       p_x_line_rec.Original_ordered_item_id :=
                         p_old_line_rec.Original_ordered_item_id;
   END IF;

   IF p_x_line_rec.Original_ordered_item = FND_API.G_MISS_CHAR THEN
       p_x_line_rec.Original_ordered_item :=
                         p_old_line_rec.Original_ordered_item;
   END IF;

   IF p_x_line_rec.item_relationship_type = FND_API.G_MISS_NUM THEN
       p_x_line_rec.item_relationship_type :=
                         p_old_line_rec.item_relationship_type;
   END IF;

   IF p_x_line_rec.Item_substitution_type_code = FND_API.G_MISS_CHAR THEN
       p_x_line_rec.Item_substitution_type_code :=
                         p_old_line_rec.Item_substitution_type_code;
   END IF;

   IF p_x_line_rec.Late_Demand_Penalty_Factor = FND_API.G_MISS_NUM THEN
       p_x_line_rec.Late_Demand_Penalty_Factor :=
                         p_old_line_rec.Late_Demand_Penalty_Factor;
   END IF;

   IF p_x_line_rec.Override_atp_date_code = FND_API.G_MISS_CHAR THEN
       p_x_line_rec.Override_atp_date_code :=
                         p_old_line_rec.Override_atp_date_code;
   END IF;

   -- Changes for Blanket Orders

   IF p_x_line_rec.Blanket_Number = FND_API.G_MISS_NUM THEN
      p_x_line_rec.Blanket_Number := p_old_line_rec.Blanket_Number;
   END IF;

   IF p_x_line_rec.Blanket_Line_Number = FND_API.G_MISS_NUM THEN
      p_x_line_rec.Blanket_Line_Number := p_old_line_rec.Blanket_Line_Number;
   END IF;

   IF p_x_line_rec.Blanket_Version_Number = FND_API.G_MISS_NUM THEN
      p_x_line_rec.Blanket_Version_Number := p_old_line_rec.Blanket_Version_Number;
   END IF;

   -- bug 2589332
   IF p_x_line_rec.User_Item_Description = FND_API.G_MISS_CHAR THEN
      p_x_line_rec.User_Item_Description := p_old_line_rec.User_Item_Description;
   END IF;

   -- QUOTING changes
   IF p_x_line_rec.transaction_phase_code = FND_API.G_MISS_CHAR THEN
       p_x_line_rec.transaction_phase_code :=
                         p_old_line_rec.transaction_phase_code;
   END IF;

   IF p_x_line_rec.source_document_version_number = FND_API.G_MISS_NUM THEN
       p_x_line_rec.source_document_version_number :=
                         p_old_line_rec.source_document_version_number;
   END IF;
   -- END QUOTING changes
    IF p_x_line_rec.Minisite_Id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.Minisite_Id := p_old_line_rec.Minisite_Id;
    END IF;

    IF p_x_line_rec.End_customer_Id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.End_customer_Id := p_old_line_rec.End_customer_Id;
    END IF;

    IF p_x_line_rec.End_customer_contact_Id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.End_customer_contact_Id := p_old_line_rec.End_customer_contact_Id;
    END IF;

    IF p_x_line_rec.End_customer_site_use_Id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.End_customer_site_use_Id := p_old_line_rec.End_customer_site_use_Id;
    END IF;

    IF p_x_line_rec.ib_owner = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.ib_owner := p_old_line_rec.ib_owner;
    END IF;

    IF p_x_line_rec.ib_installed_at_location = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.ib_installed_at_location := p_old_line_rec.ib_installed_at_location;
    END IF;

    IF p_x_line_rec.ib_current_location = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.ib_current_location := p_old_line_rec.ib_current_location;
    END IF;

    IF p_x_line_rec.supplier_signature = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.supplier_signature := p_old_line_rec.supplier_signature;
    END IF;

    --retro{
    IF p_x_line_rec.retrobill_request_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.retrobill_request_id :=
                         p_old_line_rec.retrobill_request_id;
    END IF;

    --retro}

    IF p_x_line_rec.firm_demand_flag = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.firm_demand_flag := p_old_line_rec.firm_demand_flag;
    END IF;

--key Transaction Dates Project
    IF p_x_line_rec.order_firmed_date = FND_API.G_MISS_DATE THEN
        p_x_line_rec.order_firmed_date := p_old_line_rec.order_firmed_date;
    END IF;

    IF p_x_line_rec.actual_fulfillment_date = FND_API.G_MISS_DATE THEN
        p_x_line_rec.actual_fulfillment_date := p_old_line_rec.actual_fulfillment_date;
    END IF;

--end


-- INVCONV OPM inventory convergence
	  IF p_x_line_rec.fulfilled_quantity2 = FND_API.G_MISS_NUM THEN
        p_x_line_rec.fulfilled_quantity2 := p_old_line_rec.fulfilled_quantity2;
    END IF;
		IF p_x_line_rec.cancelled_quantity2 = FND_API.G_MISS_NUM THEN
        p_x_line_rec.cancelled_quantity2 := p_old_line_rec.cancelled_quantity2;
    END IF;
 		IF p_x_line_rec.shipping_quantity_uom2 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.shipping_quantity_uom2 := p_old_line_rec.shipping_quantity_uom2;
    END IF;


    IF p_x_line_rec.reserved_quantity2 = FND_API.G_MISS_NUM THEN
           p_x_line_rec.reserved_quantity2 := p_old_line_rec.reserved_quantity2;  -- bug 4889860
    END IF;


-- INVCONV end


/*  IF p_x_line_rec.supplier_signature_date = FND_API.G_MISS_DATE THEN
        p_x_line_rec.supplier_signature_date := p_old_line_rec.supplier_signature_date;
    END IF;

  IF p_x_line_rec.customer_signature = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.customer_signature := p_old_line_rec.customer_signature;
    END IF;

  IF p_x_line_rec.customer_signature_date = FND_API.G_MISS_DATE THEN
        p_x_line_rec.customer_signature_date := p_old_line_rec.customer_signature_date;
    END IF;

*/

 IF p_x_line_rec.customer_item_net_price = FND_API.G_MISS_NUM THEN
      p_x_line_rec.customer_item_net_price := p_old_line_rec.customer_item_net_price; -- 5465342
   END IF;

   IF p_x_line_rec.earliest_ship_date = FND_API.G_MISS_DATE THEN
      p_x_line_rec.earliest_ship_date := p_old_line_rec.earliest_ship_date; -- 8497317
   END IF;

if l_debug_level > 0 then
    oe_debug_pub.add('Exiting OE_LINE_UTIL.COMPLETE_RECORD', 1);
  end if;

END Complete_Record;



/*-----------------------------------------------------------
PROCEDURE Convert_Miss_To_Null
-----------------------------------------------------------*/

PROCEDURE Convert_Miss_To_Null
(   p_x_line_rec                    IN OUT NOCOPY  OE_Order_PUB.Line_Rec_Type
)
IS
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

  if l_debug_level > 0 then
    oe_debug_pub.add('Entering OE_LINE_UTIL.CONVERT_MISS_TO_NULL', 1);

oe_debug_pub.add('outside margin convert miss to null',1);
  end if;
--MRG BGN
IF OE_FEATURES_PVT.Is_Margin_Avail Then
  if l_debug_level > 0 then
   oe_debug_pub.add('inside margin convert miss to null',1);
  end if;
    IF p_x_line_rec.unit_cost = FND_API.G_MISS_NUM THEN
        p_x_line_rec.unit_cost := NULL;
    END IF;
END IF;
--MRG END


    IF p_x_line_rec.accounting_rule_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.accounting_rule_id := NULL;
    END IF;

    IF p_x_line_rec.accounting_rule_duration = FND_API.G_MISS_NUM THEN
        p_x_line_rec.accounting_rule_duration := NULL;
    END IF;

    IF p_x_line_rec.actual_arrival_date = FND_API.G_MISS_DATE THEN
        p_x_line_rec.actual_arrival_date := NULL;
    END IF;

    IF p_x_line_rec.actual_shipment_date = FND_API.G_MISS_DATE THEN
        p_x_line_rec.actual_shipment_date := NULL;
    END IF;

    IF p_x_line_rec.agreement_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.agreement_id := NULL;
    END IF;
    IF p_x_line_rec.arrival_set_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.arrival_set_id := NULL;
    END IF;

    IF p_x_line_rec.ato_line_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.ato_line_id := NULL;
    END IF;
    IF p_x_line_rec.upgraded_flag = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.upgraded_flag := NULL;
    END IF;

    IF p_x_line_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.attribute1 := NULL;
    END IF;

    IF p_x_line_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.attribute10 := NULL;
    END IF;

    IF p_x_line_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.attribute11 := NULL;
    END IF;

    IF p_x_line_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.attribute12 := NULL;
    END IF;

    IF p_x_line_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.attribute13 := NULL;
    END IF;

    IF p_x_line_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.attribute14 := NULL;
    END IF;

    IF p_x_line_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.attribute15 := NULL;
    END IF;

    IF p_x_line_rec.attribute16 = FND_API.G_MISS_CHAR THEN    --For bug 2184255
        p_x_line_rec.attribute16 := NULL;
    END IF;

    IF p_x_line_rec.attribute17 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.attribute17 := NULL;
    END IF;

    IF p_x_line_rec.attribute18 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.attribute18 := NULL;
    END IF;

    IF p_x_line_rec.attribute19 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.attribute19 := NULL;
    END IF;

    IF p_x_line_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.attribute2 := NULL;
    END IF;

    IF p_x_line_rec.attribute20 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.attribute20 := NULL;
    END IF;

    IF p_x_line_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.attribute3 := NULL;
    END IF;

    IF p_x_line_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.attribute4 := NULL;
    END IF;

    IF p_x_line_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.attribute5 := NULL;
    END IF;

    IF p_x_line_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.attribute6 := NULL;
    END IF;

    IF p_x_line_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.attribute7 := NULL;
    END IF;

    IF p_x_line_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.attribute8 := NULL;
    END IF;

    IF p_x_line_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.attribute9 := NULL;
    END IF;

    IF p_x_line_rec.auto_selected_quantity = FND_API.G_MISS_NUM THEN
        p_x_line_rec.auto_selected_quantity := NULL;
    END IF;
     IF p_x_line_rec.authorized_to_ship_flag = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.authorized_to_ship_flag := NULL;
    END IF;

    IF p_x_line_rec.booked_flag = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.booked_flag := NULL;
    END IF;

    IF p_x_line_rec.cancelled_flag = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.cancelled_flag := NULL;
    END IF;

    IF p_x_line_rec.cancelled_quantity = FND_API.G_MISS_NUM THEN
        p_x_line_rec.cancelled_quantity := NULL;
    END IF;

    IF p_x_line_rec.component_code = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.component_code := NULL;
    END IF;

    IF p_x_line_rec.component_number = FND_API.G_MISS_NUM THEN
        p_x_line_rec.component_number := NULL;
    END IF;

    IF p_x_line_rec.component_sequence_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.component_sequence_id := NULL;
    END IF;

    IF p_x_line_rec.config_header_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.config_header_id := NULL;
    END IF;

    IF p_x_line_rec.config_rev_nbr = FND_API.G_MISS_NUM THEN
        p_x_line_rec.config_rev_nbr := NULL;
    END IF;

    IF p_x_line_rec.config_display_sequence = FND_API.G_MISS_NUM THEN
        p_x_line_rec.config_display_sequence := NULL;
    END IF;

    IF p_x_line_rec.configuration_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.configuration_id := NULL;
    END IF;

    IF p_x_line_rec.context = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.context := NULL;
    END IF;
    --recurring charges
    IF p_x_line_rec.charge_periodicity_code = FND_API.G_MISS_CHAR THEN
       p_x_line_rec.charge_periodicity_code := NULL;
    END IF;

    --Customer Acceptance
     IF p_x_line_rec.CONTINGENCY_ID  = FND_API.G_MISS_NUM THEN
        p_x_line_rec.CONTINGENCY_ID  := NULL  ;
    END IF;
     IF p_x_line_rec.REVREC_EVENT_CODE = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.REVREC_EVENT_CODE:= NULL  ;
    END IF;
     IF p_x_line_rec.REVREC_EXPIRATION_DAYS = FND_API.G_MISS_NUM THEN
        p_x_line_rec.REVREC_EXPIRATION_DAYS:= NULL  ;
    END IF;
     IF p_x_line_rec.ACCEPTED_QUANTITY = FND_API.G_MISS_NUM THEN
        p_x_line_rec.ACCEPTED_QUANTITY:= NULL  ;
    END IF;
     IF p_x_line_rec.REVREC_COMMENTS = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.REVREC_COMMENTS:= NULL  ;
    END IF;
     IF p_x_line_rec.REVREC_SIGNATURE = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.REVREC_SIGNATURE:= NULL  ;
    END IF;
     IF p_x_line_rec.REVREC_SIGNATURE_DATE = FND_API.G_MISS_DATE THEN
        p_x_line_rec.REVREC_SIGNATURE_DATE:= NULL  ;
    END IF;
     IF p_x_line_rec.ACCEPTED_BY = FND_API.G_MISS_NUM THEN
        p_x_line_rec.ACCEPTED_BY:= NULL  ;
    END IF;
     IF p_x_line_rec.REVREC_REFERENCE_DOCUMENT = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.REVREC_REFERENCE_DOCUMENT:= NULL  ;
    END IF;
     IF p_x_line_rec.REVREC_IMPLICIT_FLAG = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.REVREC_IMPLICIT_FLAG:= NULL  ;
    END IF;
   --Customer Acceptance Changes End

    IF p_x_line_rec.created_by = FND_API.G_MISS_NUM THEN
        p_x_line_rec.created_by := NULL;
    END IF;

    IF p_x_line_rec.creation_date = FND_API.G_MISS_DATE THEN
        p_x_line_rec.creation_date := NULL;
    END IF;

    IF p_x_line_rec.credit_invoice_line_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.credit_invoice_line_id := NULL;
    END IF;

    IF p_x_line_rec.customer_dock_code = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.customer_dock_code := NULL;
    END IF;

    IF p_x_line_rec.customer_job = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.customer_job := NULL;
    END IF;

    IF p_x_line_rec.customer_production_line = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.customer_production_line := NULL;
    END IF;

    IF p_x_line_rec.cust_production_seq_num = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.cust_production_seq_num := NULL;
    END IF;

    IF p_x_line_rec.customer_trx_line_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.customer_trx_line_id := NULL;
    END IF;

    IF p_x_line_rec.cust_model_serial_number = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.cust_model_serial_number := NULL;
    END IF;

    IF p_x_line_rec.cust_po_number = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.cust_po_number := NULL;
    END IF;

    IF p_x_line_rec.customer_line_number = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.customer_line_number := NULL;
    END IF;

    IF p_x_line_rec.customer_shipment_number = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.customer_shipment_number := NULL;
    END IF;

    IF p_x_line_rec.delivery_lead_time = FND_API.G_MISS_NUM THEN
        p_x_line_rec.delivery_lead_time := NULL;
    END IF;

    IF p_x_line_rec.deliver_to_contact_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.deliver_to_contact_id := NULL;
    END IF;

    IF p_x_line_rec.deliver_to_org_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.deliver_to_org_id := NULL;
    END IF;

    IF p_x_line_rec.demand_bucket_type_code = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.demand_bucket_type_code := NULL;
    END IF;

    IF p_x_line_rec.demand_class_code = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.demand_class_code := NULL;
    END IF;

    IF p_x_line_rec.dep_plan_required_flag = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.dep_plan_required_flag := NULL;
    END IF;


    IF p_x_line_rec.earliest_acceptable_date = FND_API.G_MISS_DATE THEN
        p_x_line_rec.earliest_acceptable_date := NULL;
    END IF;

    IF p_x_line_rec.explosion_date = FND_API.G_MISS_DATE THEN
        p_x_line_rec.explosion_date := NULL;
    END IF;

    IF p_x_line_rec.fob_point_code = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.fob_point_code := NULL;
    END IF;

    IF p_x_line_rec.freight_carrier_code = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.freight_carrier_code := NULL;
    END IF;

    IF p_x_line_rec.freight_terms_code = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.freight_terms_code := NULL;
    END IF;

    IF p_x_line_rec.fulfilled_quantity = FND_API.G_MISS_NUM THEN
        p_x_line_rec.fulfilled_quantity := NULL;
    END IF;

    IF p_x_line_rec.fulfilled_flag = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.fulfilled_flag := NULL;
    END IF;

    IF p_x_line_rec.fulfillment_method_code = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.fulfillment_method_code := NULL;
    END IF;

    IF p_x_line_rec.fulfillment_date = FND_API.G_MISS_DATE THEN
        p_x_line_rec.fulfillment_date := NULL;
    END IF;

    IF p_x_line_rec.global_attribute1 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.global_attribute1 := NULL;
    END IF;

    IF p_x_line_rec.global_attribute10 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.global_attribute10 := NULL;
    END IF;

    IF p_x_line_rec.global_attribute11 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.global_attribute11 := NULL;
    END IF;

    IF p_x_line_rec.global_attribute12 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.global_attribute12 := NULL;
    END IF;

    IF p_x_line_rec.global_attribute13 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.global_attribute13 := NULL;
    END IF;

    IF p_x_line_rec.global_attribute14 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.global_attribute14 := NULL;
    END IF;

    IF p_x_line_rec.global_attribute15 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.global_attribute15 := NULL;
    END IF;

    IF p_x_line_rec.global_attribute16 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.global_attribute16 := NULL;
    END IF;

    IF p_x_line_rec.global_attribute17 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.global_attribute17 := NULL;
    END IF;

    IF p_x_line_rec.global_attribute18 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.global_attribute18 := NULL;
    END IF;

    IF p_x_line_rec.global_attribute19 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.global_attribute19 := NULL;
    END IF;

    IF p_x_line_rec.global_attribute2 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.global_attribute2 := NULL;
    END IF;

    IF p_x_line_rec.global_attribute20 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.global_attribute20 := NULL;
    END IF;

    IF p_x_line_rec.global_attribute3 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.global_attribute3 := NULL;
    END IF;

    IF p_x_line_rec.global_attribute4 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.global_attribute4 := NULL;
    END IF;

    IF p_x_line_rec.global_attribute5 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.global_attribute5 := NULL;
    END IF;

    IF p_x_line_rec.global_attribute6 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.global_attribute6 := NULL;
    END IF;

    IF p_x_line_rec.global_attribute7 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.global_attribute7 := NULL;
    END IF;

    IF p_x_line_rec.global_attribute8 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.global_attribute8 := NULL;
    END IF;

    IF p_x_line_rec.global_attribute9 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.global_attribute9 := NULL;
    END IF;

    IF p_x_line_rec.global_attribute_category = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.global_attribute_category := NULL;
    END IF;

    IF p_x_line_rec.header_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.header_id := NULL;
    END IF;

    IF p_x_line_rec.industry_attribute1 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.industry_attribute1 := NULL;
    END IF;

    IF p_x_line_rec.industry_attribute10 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.industry_attribute10 := NULL;
    END IF;

    IF p_x_line_rec.industry_attribute11 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.industry_attribute11 := NULL;
    END IF;

    IF p_x_line_rec.industry_attribute12 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.industry_attribute12 := NULL;
    END IF;

    IF p_x_line_rec.industry_attribute13 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.industry_attribute13 := NULL;
    END IF;

    IF p_x_line_rec.industry_attribute14 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.industry_attribute14 := NULL;
    END IF;

    IF p_x_line_rec.industry_attribute15 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.industry_attribute15 := NULL;
    END IF;

IF p_x_line_rec.industry_attribute16 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.industry_attribute16 := NULL;
    END IF;
IF p_x_line_rec.industry_attribute17 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.industry_attribute17 := NULL;
    END IF;
IF p_x_line_rec.industry_attribute18 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.industry_attribute18 := NULL;
    END IF;
IF p_x_line_rec.industry_attribute19 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.industry_attribute19 := NULL;
    END IF;
IF p_x_line_rec.industry_attribute20 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.industry_attribute20 := NULL;
    END IF;
IF p_x_line_rec.industry_attribute21 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.industry_attribute21 := NULL;
    END IF;
IF p_x_line_rec.industry_attribute22 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.industry_attribute22 := NULL;
    END IF;
IF p_x_line_rec.industry_attribute23 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.industry_attribute23 := NULL;
    END IF;
IF p_x_line_rec.industry_attribute24 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.industry_attribute24 := NULL;
    END IF;
IF p_x_line_rec.industry_attribute25 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.industry_attribute25 := NULL;
    END IF;
IF p_x_line_rec.industry_attribute26 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.industry_attribute26 := NULL;
    END IF;
IF p_x_line_rec.industry_attribute27 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.industry_attribute27 := NULL;
    END IF;
IF p_x_line_rec.industry_attribute28 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.industry_attribute28 := NULL;
    END IF;
 IF p_x_line_rec.industry_attribute29 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.industry_attribute29 := NULL;
    END IF;
IF p_x_line_rec.industry_attribute30 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.industry_attribute30 := NULL;
    END IF;


    IF p_x_line_rec.industry_attribute2 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.industry_attribute2 := NULL;
    END IF;

    IF p_x_line_rec.industry_attribute3 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.industry_attribute3 := NULL;
    END IF;

    IF p_x_line_rec.industry_attribute4 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.industry_attribute4 := NULL;
    END IF;

    IF p_x_line_rec.industry_attribute5 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.industry_attribute5 := NULL;
    END IF;

    IF p_x_line_rec.industry_attribute6 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.industry_attribute6 := NULL;
    END IF;

    IF p_x_line_rec.industry_attribute7 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.industry_attribute7 := NULL;
    END IF;

    IF p_x_line_rec.industry_attribute8 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.industry_attribute8 := NULL;
    END IF;

    IF p_x_line_rec.industry_attribute9 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.industry_attribute9 := NULL;
    END IF;

    IF p_x_line_rec.industry_context = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.industry_context := NULL;
    END IF;

    /* TP_ATTRIBUTE */
    IF p_x_line_rec.tp_context = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.tp_context := NULL;
    END IF;
    IF p_x_line_rec.tp_attribute1 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.tp_attribute1 := NULL;
    END IF;
    IF p_x_line_rec.tp_attribute2 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.tp_attribute2 := NULL;
    END IF;
    IF p_x_line_rec.tp_attribute3 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.tp_attribute3 := NULL;
    END IF;
    IF p_x_line_rec.tp_attribute4 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.tp_attribute4 := NULL;
    END IF;
    IF p_x_line_rec.tp_attribute5 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.tp_attribute5 := NULL;
    END IF;
    IF p_x_line_rec.tp_attribute6 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.tp_attribute6 := NULL;
    END IF;
    IF p_x_line_rec.tp_attribute7 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.tp_attribute7 := NULL;
    END IF;
    IF p_x_line_rec.tp_attribute8 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.tp_attribute8 := NULL;
    END IF;
    IF p_x_line_rec.tp_attribute9 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.tp_attribute9 := NULL;
    END IF;
    IF p_x_line_rec.tp_attribute10 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.tp_attribute10 := NULL;
    END IF;
    IF p_x_line_rec.tp_attribute11 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.tp_attribute11 := NULL;
    END IF;
    IF p_x_line_rec.tp_attribute12 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.tp_attribute12 := NULL;
    END IF;
    IF p_x_line_rec.tp_attribute13 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.tp_attribute13 := NULL;
    END IF;
    IF p_x_line_rec.tp_attribute14 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.tp_attribute14 := NULL;
    END IF;
    IF p_x_line_rec.tp_attribute15 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.tp_attribute15 := NULL;
    END IF;


    IF p_x_line_rec.intermed_ship_to_contact_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.intermed_ship_to_contact_id := NULL;
    END IF;

    IF p_x_line_rec.intermed_ship_to_org_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.intermed_ship_to_org_id := NULL;
    END IF;

    IF p_x_line_rec.inventory_item_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.inventory_item_id := NULL;
    END IF;

    IF p_x_line_rec.invoice_interface_status_code = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.invoice_interface_status_code := NULL;
    END IF;



    IF p_x_line_rec.invoice_to_contact_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.invoice_to_contact_id := NULL;
    END IF;

    IF p_x_line_rec.invoiced_quantity = FND_API.G_MISS_NUM THEN
        p_x_line_rec.invoiced_quantity := NULL;
    END IF;

    IF p_x_line_rec.invoice_to_org_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.invoice_to_org_id := NULL;
    END IF;

    IF p_x_line_rec.invoicing_rule_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.invoicing_rule_id := NULL;
    END IF;

    IF p_x_line_rec.ordered_item_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.ordered_item_id := NULL;
    END IF;

    IF p_x_line_rec.item_identifier_type = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.item_identifier_type := NULL;
    END IF;

    IF p_x_line_rec.ordered_item = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.ordered_item := NULL;
    END IF;

    IF p_x_line_rec.item_revision = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.item_revision := NULL;
    END IF;

    IF p_x_line_rec.item_type_code = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.item_type_code := NULL;
    END IF;

    IF p_x_line_rec.last_updated_by = FND_API.G_MISS_NUM THEN
        p_x_line_rec.last_updated_by := NULL;
    END IF;

    IF p_x_line_rec.last_update_date = FND_API.G_MISS_DATE THEN
        p_x_line_rec.last_update_date := NULL;
    END IF;

    IF p_x_line_rec.last_update_login = FND_API.G_MISS_NUM THEN
        p_x_line_rec.last_update_login := NULL;
    END IF;

    IF p_x_line_rec.latest_acceptable_date = FND_API.G_MISS_DATE THEN
        p_x_line_rec.latest_acceptable_date := NULL;
    END IF;

    IF p_x_line_rec.line_category_code = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.line_category_code := NULL;
    END IF;

    IF p_x_line_rec.line_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.line_id := NULL;
    END IF;

    IF p_x_line_rec.line_number = FND_API.G_MISS_NUM THEN
        p_x_line_rec.line_number := NULL;
    END IF;

    IF p_x_line_rec.line_type_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.line_type_id := NULL;
    END IF;

    IF p_x_line_rec.link_to_line_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.link_to_line_id := NULL;
    END IF;

    IF p_x_line_rec.model_group_number = FND_API.G_MISS_NUM THEN
        p_x_line_rec.model_group_number := NULL;
    END IF;

    IF p_x_line_rec.mfg_component_sequence_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.mfg_component_sequence_id := NULL;
    END IF;

    IF p_x_line_rec.mfg_lead_time = FND_API.G_MISS_NUM THEN
        p_x_line_rec.mfg_lead_time := NULL;
    END IF;

    IF p_x_line_rec.open_flag = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.open_flag := NULL;
    END IF;

    IF p_x_line_rec.option_flag = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.option_flag := NULL;
    END IF;

    IF p_x_line_rec.option_number = FND_API.G_MISS_NUM THEN
        p_x_line_rec.option_number := NULL;
    END IF;

    IF p_x_line_rec.ordered_quantity = FND_API.G_MISS_NUM THEN
        p_x_line_rec.ordered_quantity := NULL;
    END IF;

    IF p_x_line_rec.order_quantity_uom = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.order_quantity_uom := NULL;
    END IF;

    -- OPM 02/JUN/00 - Deal with process attributes INVCONV
    -- ============================================
    IF p_x_line_rec.ordered_quantity2 = FND_API.G_MISS_NUM THEN
        p_x_line_rec.ordered_quantity2 := NULL;
    END IF;

    IF p_x_line_rec.ordered_quantity_uom2 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.ordered_quantity_uom2 := NULL;
    END IF;
    -- OPM 02/JUN/00 - END
    -- ===================

    IF p_x_line_rec.org_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.org_id := NULL;
    END IF;

    IF p_x_line_rec.orig_sys_document_ref = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.orig_sys_document_ref := NULL;
    END IF;

    IF p_x_line_rec.orig_sys_line_ref = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.orig_sys_line_ref := NULL;
    END IF;

    IF p_x_line_rec.orig_sys_shipment_ref = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.orig_sys_shipment_ref := NULL;
    END IF;

-- Override List Price
    IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510' THEN
       IF p_x_line_rec.original_list_price = FND_API.G_MISS_NUM THEN
          p_x_line_rec.original_list_price:= NULL;
       END IF;
    END IF;
-- Override List Price

    IF p_x_line_rec.over_ship_reason_code = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.over_ship_reason_code := NULL;
    END IF;
    IF p_x_line_rec.over_ship_resolved_flag = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.over_ship_resolved_flag := NULL;
    END IF;

    IF p_x_line_rec.payment_term_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.payment_term_id := NULL;
    END IF;

    IF p_x_line_rec.planning_priority = FND_API.G_MISS_NUM THEN
        p_x_line_rec.planning_priority := NULL;
    END IF;

    -- OPM 02/JUN/00 - Deal with process attributes INVCONV
    -- ============================================
    IF p_x_line_rec.preferred_grade = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.preferred_grade := NULL;
    END IF;
    -- OPM 02/JUN/00 - END
    -- ===================

    IF p_x_line_rec.price_list_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.price_list_id := NULL;
    END IF;

     IF p_x_line_rec.price_request_code = FND_API.G_MISS_CHAR THEN -- PROMOTIONS SEP/01
        p_x_line_rec.price_request_code := NULL;
    END IF;

    IF p_x_line_rec.pricing_attribute1 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.pricing_attribute1 := NULL;
    END IF;

    IF p_x_line_rec.pricing_attribute10 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.pricing_attribute10 := NULL;
    END IF;

    IF p_x_line_rec.pricing_attribute2 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.pricing_attribute2 := NULL;
    END IF;

    IF p_x_line_rec.pricing_attribute3 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.pricing_attribute3 := NULL;
    END IF;

    IF p_x_line_rec.pricing_attribute4 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.pricing_attribute4 := NULL;
    END IF;

    IF p_x_line_rec.pricing_attribute5 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.pricing_attribute5 := NULL;
    END IF;

    IF p_x_line_rec.pricing_attribute6 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.pricing_attribute6 := NULL;
    END IF;

    IF p_x_line_rec.pricing_attribute7 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.pricing_attribute7 := NULL;
    END IF;

    IF p_x_line_rec.pricing_attribute8 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.pricing_attribute8 := NULL;
    END IF;

    IF p_x_line_rec.pricing_attribute9 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.pricing_attribute9 := NULL;
    END IF;

    IF p_x_line_rec.pricing_context = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.pricing_context := NULL;
    END IF;

    IF p_x_line_rec.pricing_date = FND_API.G_MISS_DATE THEN
        p_x_line_rec.pricing_date := NULL;
    END IF;

    IF p_x_line_rec.pricing_quantity = FND_API.G_MISS_NUM THEN
        p_x_line_rec.pricing_quantity := NULL;
    END IF;

    IF p_x_line_rec.pricing_quantity_uom = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.pricing_quantity_uom := NULL;
    END IF;

    IF p_x_line_rec.program_application_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.program_application_id := NULL;
    END IF;

    IF p_x_line_rec.program_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.program_id := NULL;
    END IF;

    IF p_x_line_rec.program_update_date = FND_API.G_MISS_DATE THEN
        p_x_line_rec.program_update_date := NULL;
    END IF;

    IF p_x_line_rec.project_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.project_id := NULL;
    END IF;

    IF p_x_line_rec.promise_date = FND_API.G_MISS_DATE THEN
        p_x_line_rec.promise_date := NULL;
    END IF;

    IF p_x_line_rec.re_source_flag = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.re_source_flag := NULL;
    END IF;

    IF p_x_line_rec.reference_customer_trx_line_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.reference_customer_trx_line_id := NULL;
    END IF;

    IF p_x_line_rec.reference_header_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.reference_header_id := NULL;
    END IF;

    IF p_x_line_rec.reference_line_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.reference_line_id := NULL;
    END IF;

    IF p_x_line_rec.reference_type = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.reference_type := NULL;
    END IF;



    IF p_x_line_rec.request_date = FND_API.G_MISS_DATE THEN
        p_x_line_rec.request_date := NULL;
    END IF;

    IF p_x_line_rec.request_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.request_id := NULL;
    END IF;

    IF p_x_line_rec.return_attribute1 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.return_attribute1 := NULL;
    END IF;

    IF p_x_line_rec.return_attribute10 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.return_attribute10 := NULL;
    END IF;

    IF p_x_line_rec.return_attribute11 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.return_attribute11 := NULL;
    END IF;

    IF p_x_line_rec.return_attribute12 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.return_attribute12 := NULL;
    END IF;

    IF p_x_line_rec.return_attribute13 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.return_attribute13 := NULL;
    END IF;

    IF p_x_line_rec.return_attribute14 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.return_attribute14 := NULL;
    END IF;

    IF p_x_line_rec.return_attribute15 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.return_attribute15 := NULL;
    END IF;

    IF p_x_line_rec.return_attribute2 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.return_attribute2 := NULL;
    END IF;

    IF p_x_line_rec.return_attribute3 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.return_attribute3 := NULL;
    END IF;

    IF p_x_line_rec.return_attribute4 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.return_attribute4 := NULL;
    END IF;

    IF p_x_line_rec.return_attribute5 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.return_attribute5 := NULL;
    END IF;

    IF p_x_line_rec.return_attribute6 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.return_attribute6 := NULL;
    END IF;

    IF p_x_line_rec.return_attribute7 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.return_attribute7 := NULL;
    END IF;

    IF p_x_line_rec.return_attribute8 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.return_attribute8 := NULL;
    END IF;

    IF p_x_line_rec.return_attribute9 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.return_attribute9 := NULL;
    END IF;

    IF p_x_line_rec.return_context = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.return_context := NULL;
    END IF;
    IF p_x_line_rec.return_reason_code = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.return_reason_code := NULL;
    END IF;
    IF p_x_line_rec.salesrep_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.salesrep_id := NULL;
    END IF;

    IF p_x_line_rec.rla_schedule_type_code = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.rla_schedule_type_code := NULL;
    END IF;

    IF p_x_line_rec.schedule_arrival_date = FND_API.G_MISS_DATE THEN
        p_x_line_rec.schedule_arrival_date := NULL;
    END IF;

    IF p_x_line_rec.schedule_ship_date = FND_API.G_MISS_DATE THEN
        p_x_line_rec.schedule_ship_date := NULL;
    END IF;

    IF p_x_line_rec.schedule_action_code = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.schedule_action_code := NULL;
    END IF;

    IF p_x_line_rec.schedule_status_code = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.schedule_status_code := NULL;
    END IF;

    IF p_x_line_rec.shipment_number = FND_API.G_MISS_NUM THEN
        p_x_line_rec.shipment_number := NULL;
    END IF;

    IF p_x_line_rec.shipment_priority_code = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.shipment_priority_code := NULL;
    END IF;

    IF p_x_line_rec.shipped_quantity = FND_API.G_MISS_NUM THEN
        p_x_line_rec.shipped_quantity := NULL;
    END IF;

    IF p_x_line_rec.shipped_quantity2 = FND_API.G_MISS_NUM THEN -- OPM B1661023 04/02/01 INVCONV
        p_x_line_rec.shipped_quantity2 := NULL;
    END IF;

    IF p_x_line_rec.shipping_method_code = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.shipping_method_code := NULL;
    END IF;

    IF p_x_line_rec.shipping_quantity = FND_API.G_MISS_NUM THEN
        p_x_line_rec.shipping_quantity := NULL;
    END IF;

    IF p_x_line_rec.shipping_quantity2 = FND_API.G_MISS_NUM THEN -- OPM B1661023 04/02/01 INVCONV
        p_x_line_rec.shipping_quantity2 := NULL;
    END IF;

    IF p_x_line_rec.shipping_quantity_uom = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.shipping_quantity_uom := NULL;
    END IF;

    IF p_x_line_rec.ship_from_org_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.ship_from_org_id := NULL;
    END IF;

    IF p_x_line_rec.subinventory = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.subinventory := NULL;
    END IF;

    IF p_x_line_rec.ship_model_complete_flag = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.ship_model_complete_flag := NULL;
    END IF;
    IF p_x_line_rec.ship_set_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.ship_set_id := NULL;
    END IF;

    IF p_x_line_rec.ship_tolerance_above = FND_API.G_MISS_NUM THEN
        p_x_line_rec.ship_tolerance_above := NULL;
    END IF;

    IF p_x_line_rec.ship_tolerance_below = FND_API.G_MISS_NUM THEN
        p_x_line_rec.ship_tolerance_below := NULL;
    END IF;

    IF p_x_line_rec.shippable_flag = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.shippable_flag := NULL;
    END IF;

    IF p_x_line_rec.shipping_interfaced_flag = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.shipping_interfaced_flag := NULL;
    END IF;

    IF p_x_line_rec.ship_to_contact_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.ship_to_contact_id := NULL;
    END IF;

    IF p_x_line_rec.ship_to_org_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.ship_to_org_id := NULL;
    END IF;

    IF p_x_line_rec.sold_from_org_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.sold_from_org_id := NULL;
    END IF;

    IF p_x_line_rec.sold_to_org_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.sold_to_org_id := NULL;
    END IF;

    IF p_x_line_rec.sort_order = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.sort_order := NULL;
    END IF;

    IF p_x_line_rec.source_document_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.source_document_id := NULL;
    END IF;

    IF p_x_line_rec.source_document_line_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.source_document_line_id := NULL;
    END IF;

    IF p_x_line_rec.source_document_type_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.source_document_type_id := NULL;
    END IF;

    IF p_x_line_rec.source_type_code = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.source_type_code := NULL;
    END IF;
    IF p_x_line_rec.split_from_line_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.split_from_line_id := NULL;
    END IF;
    IF p_x_line_rec.line_set_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.line_set_id := NULL;
    END IF;

    IF p_x_line_rec.split_by = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.split_by := NULL;
    END IF;
    IF p_x_line_rec.model_remnant_flag = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.model_remnant_flag := NULL;
    END IF;
    IF p_x_line_rec.task_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.task_id := NULL;
    END IF;

    IF p_x_line_rec.tax_code = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.tax_code := NULL;
    END IF;

    IF p_x_line_rec.tax_date = FND_API.G_MISS_DATE THEN
        p_x_line_rec.tax_date := NULL;
    END IF;

    IF p_x_line_rec.tax_exempt_flag = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.tax_exempt_flag := NULL;
    END IF;

    IF p_x_line_rec.tax_exempt_number = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.tax_exempt_number := NULL;
    END IF;

    IF p_x_line_rec.tax_exempt_reason_code = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.tax_exempt_reason_code := NULL;
    END IF;

    IF p_x_line_rec.tax_point_code = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.tax_point_code := NULL;
    END IF;

    IF p_x_line_rec.tax_rate = FND_API.G_MISS_NUM THEN
        p_x_line_rec.tax_rate := NULL;
    END IF;

    IF p_x_line_rec.tax_value = FND_API.G_MISS_NUM THEN
        p_x_line_rec.tax_value := NULL;
    END IF;

    IF p_x_line_rec.top_model_line_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.top_model_line_id := NULL;
    END IF;

    IF p_x_line_rec.unit_list_price = FND_API.G_MISS_NUM THEN
        p_x_line_rec.unit_list_price := NULL;
    END IF;

    IF p_x_line_rec.unit_list_price_per_pqty = FND_API.G_MISS_NUM THEN
        p_x_line_rec.unit_list_price_per_pqty := NULL;
    END IF;

    IF p_x_line_rec.unit_selling_price = FND_API.G_MISS_NUM THEN
        p_x_line_rec.unit_selling_price := NULL;
    END IF;

    IF p_x_line_rec.unit_selling_price_per_pqty = FND_API.G_MISS_NUM THEN
        p_x_line_rec.unit_selling_price_per_pqty := NULL;
    END IF;


    IF p_x_line_rec.visible_demand_flag = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.visible_demand_flag := NULL;
    END IF;
    IF p_x_line_rec.veh_cus_item_cum_key_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.veh_cus_item_cum_key_id := NULL;
    END IF;

    IF p_x_line_rec.first_ack_code = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.first_ack_code := NULL;
    END IF;

    IF p_x_line_rec.first_ack_date = FND_API.G_MISS_DATE THEN
        p_x_line_rec.first_ack_date := NULL;
    END IF;

    IF p_x_line_rec.last_ack_code = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.last_ack_code := NULL;
    END IF;

    IF p_x_line_rec.last_ack_date = FND_API.G_MISS_DATE THEN
        p_x_line_rec.last_ack_date := NULL;
    END IF;


    IF p_x_line_rec.end_item_unit_number = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.end_item_unit_number := NULL;
    END IF;

    IF p_x_line_rec.shipping_instructions = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.shipping_instructions := NULL;
    END IF;

    IF p_x_line_rec.packing_instructions = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.packing_instructions := NULL;
    END IF;

    -- Service related columns

    IF p_x_line_rec.service_txn_reason_code = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.service_txn_reason_code := NULL;
    END IF;

    IF p_x_line_rec.service_txn_comments = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.service_txn_comments := NULL;
    END IF;

    IF p_x_line_rec.service_duration = FND_API.G_MISS_NUM THEN
        p_x_line_rec.service_duration := NULL;
    END IF;

    IF p_x_line_rec.service_period = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.service_period := NULL;
    END IF;

    IF p_x_line_rec.service_start_date = FND_API.G_MISS_DATE THEN
        p_x_line_rec.service_start_date := NULL;
    END IF;

    IF p_x_line_rec.service_end_date = FND_API.G_MISS_DATE THEN
        p_x_line_rec.service_end_date := NULL;
    END IF;

    IF p_x_line_rec.service_coterminate_flag = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.service_coterminate_flag := NULL;
    END IF;


    IF p_x_line_rec.unit_list_percent = FND_API.G_MISS_NUM THEN
        p_x_line_rec.unit_list_percent := NULL;
    END IF;

    IF p_x_line_rec.unit_selling_percent = FND_API.G_MISS_NUM THEN
        p_x_line_rec.unit_selling_percent := NULL;
    END IF;

    IF p_x_line_rec.unit_percent_base_price = FND_API.G_MISS_NUM THEN
        p_x_line_rec.unit_percent_base_price := NULL;
    END IF;

    IF p_x_line_rec.service_number = FND_API.G_MISS_NUM THEN
        p_x_line_rec.service_number := NULL;
    END IF;

    IF p_x_line_rec.service_reference_type_code = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.service_reference_type_code := NULL;
    END IF;

    IF p_x_line_rec.service_reference_line_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.service_reference_line_id := NULL;
    END IF;

    IF p_x_line_rec.service_reference_system_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.service_reference_system_id := NULL;
    END IF;

    /* Marketing source code related */

    IF p_x_line_rec.marketing_source_code_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.marketing_source_code_id := NULL;
    END IF;

    /* End of Marketing source code related */

    IF p_x_line_rec.order_source_id = FND_API.G_MISS_NUM THEN
  if l_debug_level > 0 then
    oe_debug_pub.add('OEXULIN-aksingh convert_miss_to_null - order_source_id');
  end if;
        p_x_line_rec.order_source_id := NULL;
    END IF;

    IF p_x_line_rec.flow_status_code = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.flow_status_code := NULL;
    END IF;

    -- Commitment related
    IF p_x_line_rec.commitment_id = FND_API.G_MISS_NUM THEN
       p_x_line_rec.commitment_id := NULL;
    END IF;


   -- Item Substitution changes.
   IF p_x_line_rec.Original_Inventory_Item_Id = FND_API.G_MISS_NUM THEN
       p_x_line_rec.Original_Inventory_Item_Id := Null;
   END IF;

   IF p_x_line_rec.Original_item_identifier_Type = FND_API.G_MISS_CHAR THEN
       p_x_line_rec.Original_item_identifier_Type := Null;
   END IF;

   IF p_x_line_rec.Original_ordered_item_id = FND_API.G_MISS_NUM THEN
       p_x_line_rec.Original_ordered_item_id := Null;
   END IF;

   IF p_x_line_rec.Original_ordered_item = FND_API.G_MISS_CHAR THEN
       p_x_line_rec.Original_ordered_item := Null;
   END IF;

   IF p_x_line_rec.item_relationship_type = FND_API.G_MISS_NUM THEN
       p_x_line_rec.item_relationship_type := Null;
   END IF;

   IF p_x_line_rec.Item_substitution_type_code = FND_API.G_MISS_CHAR THEN
       p_x_line_rec.Item_substitution_type_code := Null;
   END IF;

   IF p_x_line_rec.Late_Demand_Penalty_Factor = FND_API.G_MISS_NUM THEN
       p_x_line_rec.Late_Demand_Penalty_Factor := Null;
   END IF;

   IF p_x_line_rec.Override_atp_date_code = FND_API.G_MISS_CHAR THEN
       p_x_line_rec.Override_atp_date_code := Null;
   END IF;

   -- Changes for Blanket Orders

   IF p_x_line_rec.Blanket_Number = FND_API.G_MISS_NUM THEN
      p_x_line_rec.Blanket_Number := NULL;
   END IF;

   IF p_x_line_rec.Blanket_Line_Number = FND_API.G_MISS_NUM THEN
      p_x_line_rec.Blanket_Line_Number := NULL;
   END IF;

   IF p_x_line_rec.Blanket_Version_Number = FND_API.G_MISS_NUM THEN
      p_x_line_rec.Blanket_Version_Number := NULL;
   END IF;

   -- QUOTING changes
   IF p_x_line_rec.transaction_phase_code = FND_API.G_MISS_CHAR THEN
      p_x_line_rec.transaction_phase_code := NULL;
   END IF;

   IF p_x_line_rec.source_document_version_number = FND_API.G_MISS_NUM THEN
      p_x_line_rec.source_document_version_number := NULL;
   END IF;
   -- END QUOTING changes
    IF p_x_line_rec.Minisite_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.Minisite_id := NULL;
    END IF;

    IF p_x_line_rec.End_customer_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.End_customer_id := NULL;
    END IF;

    IF p_x_line_rec.End_customer_contact_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.End_customer_contact_id := NULL;
    END IF;

    IF p_x_line_rec.End_customer_site_use_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.End_customer_site_use_id := NULL;
    END IF;

    IF p_x_line_rec.ib_owner = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.ib_owner := NULL;
    END IF;

    IF p_x_line_rec.ib_installed_at_location = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.ib_installed_at_location := NULL;
    END IF;

    IF p_x_line_rec.ib_current_location = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.ib_current_location := NULL;
    END IF;

    --retro{
    IF p_x_line_rec.retrobill_request_id = FND_API.G_MISS_NUM THEN
       p_x_line_rec.retrobill_request_id := Null;
    END IF;
    --retro}

    IF p_x_line_rec.firm_demand_flag = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.firm_demand_flag := NULL;
    END IF;

--key Transaction Dates
    IF p_x_line_rec.order_firmed_date = FND_API.G_MISS_DATE THEN
      	p_x_line_rec.order_firmed_date := NULL;
    END IF;

   IF p_x_line_rec.actual_fulfillment_date = FND_API.G_MISS_DATE THEN
	p_x_line_rec.actual_fulfillment_date := NULL;
    END IF;
--end

-- INVCONV OPM inventory convergence

	  IF p_x_line_rec.fulfilled_quantity2 = FND_API.G_MISS_NUM THEN
        p_x_line_rec.fulfilled_quantity2 := NULL;
    END IF;

	  IF p_x_line_rec.cancelled_quantity2 = FND_API.G_MISS_NUM THEN
        p_x_line_rec.cancelled_quantity2 := NULL;
    END IF;
 		IF p_x_line_rec.shipping_quantity_uom2 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.shipping_quantity_uom2 := NULL;
    END IF;

-- INVCONV end

--bug8468258
 IF p_x_line_rec.service_reference_line = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.service_reference_line := NULL;
 END IF;

 IF p_x_line_rec.service_reference_order = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.service_reference_order := NULL;
 END IF;

 IF p_x_line_rec.service_reference_system = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.service_reference_system := NULL;
 END IF;
--bug8468258


    IF p_x_line_rec.Pre_Exploded_Flag = FND_API.G_MISS_CHAR THEN
      p_x_line_rec.Pre_Exploded_Flag := NULL;
    END IF; -- DOO Pre Exploded Kit ER 9339742

    IF p_x_line_rec.bypass_sch_flag = FND_API.G_MISS_CHAR THEN
      p_x_line_rec.bypass_sch_flag := NULL;
    END IF; -- DOO Scheduling related support ER 11728366

    --Bug 12383041
    IF p_x_line_rec.earliest_ship_date = FND_API.G_MISS_DATE THEN
       p_x_line_rec.earliest_ship_date := NULL;
    END IF;

/*   IF p_x_line_rec.supplier_signature = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.supplier_signature := NULL;
    END IF;

   IF p_x_line_rec.supplier_signature_date = FND_API.G_MISS_DATE THEN
        p_x_line_rec.supplier_signature_date := NULL;
    END IF;

   IF p_x_line_rec.customer_signature = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.customer_signature := NULL;
    END IF;

   IF p_x_line_rec.customer_signature_date = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.customer_signature_date := NULL;
    END IF;
*/

  if l_debug_level > 0 then
   oe_debug_pub.add('Exiting OE_LINE_UTIL.CONVERT_MISS_TO_NULL', 1);
  end if;
END Convert_Miss_To_Null;



/*-----------------------------------------------------------
Procedure Update_Row
-----------------------------------------------------------*/

PROCEDURE Update_Row
(   p_line_rec                      IN  OUT NOCOPY OE_Order_PUB.Line_Rec_Type
)
IS
l_org_id NUMBER;
l_lock_control NUMBER;
l_index    NUMBER;
l_return_status VARCHAR2(1);

l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

  if l_debug_level > 0 then
    oe_debug_pub.add('Entering OE_LINE_UTIL.UPDATE_ROW', 1);
  end if;
            --Commented for MOAC start
	    /*if l_org_id IS NULL THEN
		    OE_GLOBALS.Set_Context;
		    l_org_id := OE_GLOBALS.G_ORG_ID;
	    end if;*/
            --Commented for MOAC end

    SELECT lock_control
    INTO   l_lock_control
    FROM   oe_order_lines
    WHERE  line_id = p_line_rec.line_id;

    l_lock_control :=   l_lock_control + 1;

  -- calling notification framework to update global picture
   --check code release level first. Notification framework is at Pack H level
    IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110508' THEN
      OE_ORDER_UTIL.Update_Global_Picture(p_Upd_New_Rec_If_Exists => True,
                    p_Line_rec =>p_line_rec,
                    p_line_id => p_line_rec.line_id,
                    x_index => l_index,
                    x_return_status => l_return_status);
      if l_debug_level > 0 then
       OE_DEBUG_PUB.ADD('Update_Global Return Status from OE_LINE_UTIL.update_row is: ' || l_return_status);
       OE_DEBUG_PUB.ADD('JFC: Line Booked Status in OE_LINE_UTIL.update_row is: ' || p_line_rec.booked_flag);
       OE_DEBUG_PUB.ADD('JFC: Line Flow Status in OE_LINE_UTIL.update_row is: ' || p_line_rec.flow_status_code);
      end if;
       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         if l_debug_level > 0 then
          OE_DEBUG_PUB.ADD('EVENT NOTIFY - Unexpected Error');
          OE_DEBUG_PUB.ADD('Exiting OE_LINE_UTIL.Update_ROW', 1);
         end if;
       	  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        if l_debug_level > 0 then
          OE_DEBUG_PUB.ADD('Update_Global_Picture Error in OE_LINE_UTIL.Update_row');
        OE_DEBUG_PUB.ADD('Exiting OE_LINE_UTIL.Update_ROW', 1);
        end if;
	RAISE FND_API.G_EXC_ERROR;
       END IF;
    END IF; /*code_release_level*/
  -- notification framework end

  if l_debug_level > 0 then
    -- oe_debug_pub.add('Entering update'||to_char(l_org_id), 1);
    oe_debug_pub.add('arrivalset-'||to_char(p_line_rec.arrival_set_id), 1);
    oe_debug_pub.add('shipset-'||to_char(p_line_rec.ship_set_id), 1);
  end if;
    -- OPM 02/JUN/00 - Include process columns
    --                (ordered_quantity2,ordered_quantity_uom2,preferred_grade)
    UPDATE  OE_ORDER_LINES
    SET     ACCOUNTING_RULE_ID             = p_line_rec.accounting_rule_id
    ,       ACCOUNTING_RULE_DURATION       = p_line_rec.accounting_rule_duration
    ,       CALCULATE_PRICE_FLAG            = p_line_rec.calculate_price_flag
    ,       ACTUAL_ARRIVAL_DATE            = p_line_rec.actual_arrival_date
    ,       ACTUAL_SHIPMENT_DATE           = p_line_rec.actual_shipment_date
    ,       AGREEMENT_ID                   = p_line_rec.agreement_id
    ,       ARRIVAL_SET_ID                 = p_line_rec.arrival_set_id
    ,       ATO_LINE_ID                    = p_line_rec.ato_line_id
    ,       ATTRIBUTE1                     = p_line_rec.attribute1
    ,       ATTRIBUTE10                    = p_line_rec.attribute10
    ,       ATTRIBUTE11                    = p_line_rec.attribute11
    ,       ATTRIBUTE12                    = p_line_rec.attribute12
    ,       ATTRIBUTE13                    = p_line_rec.attribute13
    ,       ATTRIBUTE14                    = p_line_rec.attribute14
    ,       ATTRIBUTE15                    = p_line_rec.attribute15
    ,       ATTRIBUTE16                    = p_line_rec.attribute16   --For bug 2184255
    ,       ATTRIBUTE17                    = p_line_rec.attribute17
    ,       ATTRIBUTE18                    = p_line_rec.attribute18
    ,       ATTRIBUTE19                    = p_line_rec.attribute19
    ,       ATTRIBUTE2                     = p_line_rec.attribute2
    ,       ATTRIBUTE20                    = p_line_rec.attribute20
    ,       ATTRIBUTE3                     = p_line_rec.attribute3
    ,       ATTRIBUTE4                     = p_line_rec.attribute4
    ,       ATTRIBUTE5                     = p_line_rec.attribute5
    ,       ATTRIBUTE6                     = p_line_rec.attribute6
    ,       ATTRIBUTE7                     = p_line_rec.attribute7
    ,       ATTRIBUTE8                     = p_line_rec.attribute8
    ,       ATTRIBUTE9                     = p_line_rec.attribute9
    ,       AUTO_SELECTED_QUANTITY         = p_line_rec.auto_selected_quantity
    ,       AUTHORIZED_TO_SHIP_FLAG        = p_line_rec.authorized_to_ship_flag
    ,       BOOKED_FLAG                    = p_line_rec.booked_flag
    ,       CANCELLED_FLAG                 = p_line_rec.cancelled_flag
    ,       CANCELLED_QUANTITY             = p_line_rec.cancelled_quantity
    ,       COMMITMENT_ID                  = p_line_rec.commitment_id
    ,       COMPONENT_CODE                 = p_line_rec.component_code
    ,       COMPONENT_SEQUENCE_ID          = p_line_rec.component_sequence_id
    ,       CONFIG_HEADER_ID               = p_line_rec.config_header_id
    ,       CONFIG_REV_NBR                 = p_line_rec.config_rev_nbr
    ,       CONFIG_DISPLAY_SEQUENCE        = p_line_rec.config_display_sequence
    ,       CONFIGURATION_ID               = p_line_rec.configuration_id
    ,       CONTEXT                        = p_line_rec.context
    ,       CREATED_BY                     = p_line_rec.created_by
    ,       CREATION_DATE                  = p_line_rec.creation_date
    ,       CREDIT_INVOICE_LINE_ID         = p_line_rec.credit_invoice_line_id
    ,       CUSTOMER_LINE_NUMBER	   = p_line_rec.customer_line_number
    ,       CUSTOMER_SHIPMENT_NUMBER       = p_line_rec.customer_shipment_number
    ,       CUSTOMER_ITEM_NET_PRICE        = p_line_rec.customer_item_net_price
    ,       CUSTOMER_PAYMENT_TERM_ID       = p_line_rec.customer_payment_term_id
    ,       CUSTOMER_DOCK_CODE             = p_line_rec.customer_dock_code
    ,       CUSTOMER_JOB                   = p_line_rec.customer_job
    ,       CUSTOMER_PRODUCTION_LINE       = p_line_rec.customer_production_line
    ,       CUST_PRODUCTION_SEQ_NUM        = p_line_rec.cust_production_seq_num
    ,       CUSTOMER_TRX_LINE_ID           = p_line_rec.customer_trx_line_id
    ,       CUST_MODEL_SERIAL_NUMBER       = p_line_rec.cust_model_serial_number
    ,       CUST_PO_NUMBER                 = p_line_rec.cust_po_number
    ,       DELIVERY_LEAD_TIME             = p_line_rec.delivery_lead_time
    ,       DELIVER_TO_CONTACT_ID          = p_line_rec.deliver_to_contact_id
    ,       DELIVER_TO_ORG_ID              = p_line_rec.deliver_to_org_id
    ,       DEMAND_BUCKET_TYPE_CODE        = p_line_rec.demand_bucket_type_code
    ,       DEMAND_CLASS_CODE              = p_line_rec.demand_class_code
    ,       DEP_PLAN_REQUIRED_FLAG         = p_line_rec.dep_plan_required_flag
    --,       DROP_SHIP_FLAG		   = p_line_rec.drop_ship_flag
    ,       EARLIEST_ACCEPTABLE_DATE       = p_line_rec.earliest_acceptable_date
    ,       END_ITEM_UNIT_NUMBER           = p_line_rec.end_item_unit_number
    ,       EXPLOSION_DATE                 = p_line_rec.explosion_date
    ,       FIRST_ACK_CODE                 = p_line_rec.first_ack_code
    ,       FIRST_ACK_DATE                 = p_line_rec.first_ack_date
    ,       FOB_POINT_CODE                 = p_line_rec.fob_point_code
    ,       FREIGHT_CARRIER_CODE           = p_line_rec.freight_carrier_code
    ,       FREIGHT_TERMS_CODE             = p_line_rec.freight_terms_code
    ,       FULFILLED_QUANTITY             = p_line_rec.fulfilled_quantity
    ,       FULFILLED_FLAG                 = p_line_rec.fulfilled_flag
    ,       FULFILLMENT_METHOD_CODE        = p_line_rec.fulfillment_method_code
    ,       FULFILLMENT_DATE               = p_line_rec.fulfillment_date
    ,       GLOBAL_ATTRIBUTE1              = p_line_rec.global_attribute1
    ,       GLOBAL_ATTRIBUTE10             = p_line_rec.global_attribute10
    ,       GLOBAL_ATTRIBUTE11             = p_line_rec.global_attribute11
    ,       GLOBAL_ATTRIBUTE12             = p_line_rec.global_attribute12
    ,       GLOBAL_ATTRIBUTE13             = p_line_rec.global_attribute13
    ,       GLOBAL_ATTRIBUTE14             = p_line_rec.global_attribute14
    ,       GLOBAL_ATTRIBUTE15             = p_line_rec.global_attribute15
    ,       GLOBAL_ATTRIBUTE16             = p_line_rec.global_attribute16
    ,       GLOBAL_ATTRIBUTE17             = p_line_rec.global_attribute17
    ,       GLOBAL_ATTRIBUTE18             = p_line_rec.global_attribute18
    ,       GLOBAL_ATTRIBUTE19             = p_line_rec.global_attribute19
    ,       GLOBAL_ATTRIBUTE2              = p_line_rec.global_attribute2
    ,       GLOBAL_ATTRIBUTE20             = p_line_rec.global_attribute20
    ,       GLOBAL_ATTRIBUTE3              = p_line_rec.global_attribute3
    ,       GLOBAL_ATTRIBUTE4              = p_line_rec.global_attribute4
    ,       GLOBAL_ATTRIBUTE5              = p_line_rec.global_attribute5
    ,       GLOBAL_ATTRIBUTE6              = p_line_rec.global_attribute6
    ,       GLOBAL_ATTRIBUTE7              = p_line_rec.global_attribute7
    ,       GLOBAL_ATTRIBUTE8              = p_line_rec.global_attribute8
    ,       GLOBAL_ATTRIBUTE9              = p_line_rec.global_attribute9
    ,       GLOBAL_ATTRIBUTE_CATEGORY      = p_line_rec.global_attribute_category
    ,       HEADER_ID                      = p_line_rec.header_id
    ,       INDUSTRY_ATTRIBUTE1            = p_line_rec.industry_attribute1
    ,       INDUSTRY_ATTRIBUTE10           = p_line_rec.industry_attribute10
    ,       INDUSTRY_ATTRIBUTE11           = p_line_rec.industry_attribute11
    ,       INDUSTRY_ATTRIBUTE12           = p_line_rec.industry_attribute12
    ,       INDUSTRY_ATTRIBUTE13           = p_line_rec.industry_attribute13
    ,       INDUSTRY_ATTRIBUTE14           = p_line_rec.industry_attribute14
    ,       INDUSTRY_ATTRIBUTE15           = p_line_rec.industry_attribute15
    ,       INDUSTRY_ATTRIBUTE16           = p_line_rec.industry_attribute16
    ,       INDUSTRY_ATTRIBUTE17           = p_line_rec.industry_attribute17
    ,       INDUSTRY_ATTRIBUTE18           = p_line_rec.industry_attribute18
    ,       INDUSTRY_ATTRIBUTE19           = p_line_rec.industry_attribute19
    ,       INDUSTRY_ATTRIBUTE20           = p_line_rec.industry_attribute20
    ,       INDUSTRY_ATTRIBUTE21           = p_line_rec.industry_attribute21
    ,       INDUSTRY_ATTRIBUTE22           = p_line_rec.industry_attribute22
    ,       INDUSTRY_ATTRIBUTE23           = p_line_rec.industry_attribute23
    ,       INDUSTRY_ATTRIBUTE24           = p_line_rec.industry_attribute24
    ,       INDUSTRY_ATTRIBUTE25           = p_line_rec.industry_attribute25
    ,       INDUSTRY_ATTRIBUTE26           = p_line_rec.industry_attribute26
    ,       INDUSTRY_ATTRIBUTE27           = p_line_rec.industry_attribute27
    ,       INDUSTRY_ATTRIBUTE28           = p_line_rec.industry_attribute28
    ,       INDUSTRY_ATTRIBUTE29           = p_line_rec.industry_attribute29
    ,       INDUSTRY_ATTRIBUTE30           = p_line_rec.industry_attribute30
    ,       INDUSTRY_ATTRIBUTE2            = p_line_rec.industry_attribute2
    ,       INDUSTRY_ATTRIBUTE3            = p_line_rec.industry_attribute3
    ,       INDUSTRY_ATTRIBUTE4            = p_line_rec.industry_attribute4
    ,       INDUSTRY_ATTRIBUTE5            = p_line_rec.industry_attribute5
    ,       INDUSTRY_ATTRIBUTE6            = p_line_rec.industry_attribute6
    ,       INDUSTRY_ATTRIBUTE7            = p_line_rec.industry_attribute7
    ,       INDUSTRY_ATTRIBUTE8            = p_line_rec.industry_attribute8
    ,       INDUSTRY_ATTRIBUTE9            = p_line_rec.industry_attribute9
    ,       INDUSTRY_CONTEXT               = p_line_rec.industry_context
    ,       INTMED_SHIP_TO_CONTACT_ID = p_line_rec.intermed_ship_to_contact_id
    ,       INTMED_SHIP_TO_ORG_ID     = p_line_rec.intermed_ship_to_org_id
    ,       INVENTORY_ITEM_ID              = p_line_rec.inventory_item_id
    ,       INVOICE_INTERFACE_STATUS_CODE          = p_line_rec.invoice_interface_status_code
    ,       INVOICE_TO_CONTACT_ID          = p_line_rec.invoice_to_contact_id
    ,       INVOICE_TO_ORG_ID              = p_line_rec.invoice_to_org_id
    ,       INVOICED_QUANTITY              = p_line_rec.invoiced_quantity
    ,       INVOICING_RULE_ID              = p_line_rec.invoicing_rule_id
    ,       ORDERED_ITEM_ID                        = p_line_rec.ordered_item_id
    ,       ITEM_IDENTIFIER_TYPE           = p_line_rec.item_identifier_type
    ,       ORDERED_ITEM                     = p_line_rec.ordered_item
    ,       ITEM_REVISION                  = p_line_rec.item_revision
    ,       ITEM_TYPE_CODE                 = p_line_rec.item_type_code
    ,       LAST_ACK_CODE                  = p_line_rec.last_ack_code
    ,       LAST_ACK_DATE                  = p_line_rec.last_ack_date --bug6448638
    ,       LAST_UPDATED_BY                = p_line_rec.last_updated_by
    ,       LATEST_ACCEPTABLE_DATE         = p_line_rec.latest_acceptable_date
    ,       LAST_UPDATE_DATE               = p_line_rec.last_update_date
    ,       LAST_UPDATE_LOGIN              = p_line_rec.last_update_login
    ,       LINE_CATEGORY_CODE             = p_line_rec.line_category_code
    ,       LINE_NUMBER                    = p_line_rec.line_number
    ,       LINE_TYPE_ID                   = p_line_rec.line_type_id
    ,       LINK_TO_LINE_ID                = p_line_rec.link_to_line_id
    ,       MODEL_GROUP_NUMBER             = p_line_rec.model_group_number
 --   ,       MFG_COMPONENT_SEQUENCE_ID      = p_line_rec.mfg_component_sequence_id
    ,       MFG_LEAD_TIME                  = p_line_rec.mfg_lead_time
    ,       OPEN_FLAG                      = p_line_rec.open_flag
    ,       OPTION_FLAG                    = p_line_rec.option_flag
    ,       OPTION_NUMBER                  = p_line_rec.option_number
    ,       ORDERED_QUANTITY               = p_line_rec.ordered_quantity
    ,       ORDERED_QUANTITY2              = p_line_rec.ordered_quantity2
    ,       ORDER_QUANTITY_UOM             = p_line_rec.order_quantity_uom
    ,       ORDERED_QUANTITY_UOM2          = p_line_rec.ordered_quantity_uom2
--We should not allow to update org_id(operting unit)
--  ,       ORG_ID                         = p_line_rec.org_id
    ,       ORDER_SOURCE_ID	           = p_line_rec.order_source_id
    ,       ORIG_SYS_DOCUMENT_REF          = p_line_rec.orig_sys_document_ref
    ,       ORIG_SYS_LINE_REF              = p_line_rec.orig_sys_line_ref
    ,       ORIG_SYS_SHIPMENT_REF          = p_line_rec.orig_sys_shipment_ref
    ,       CHANGE_SEQUENCE                = p_line_rec.change_sequence
    ,       OVER_SHIP_REASON_CODE          = p_line_rec.over_ship_reason_code
    ,       OVER_SHIP_RESOLVED_FLAG        = p_line_rec.over_ship_resolved_flag
    ,       PAYMENT_TERM_ID                = p_line_rec.payment_term_id
    ,       PLANNING_PRIORITY              = p_line_rec.planning_priority
    ,       PREFERRED_GRADE                = p_line_rec.preferred_grade
    ,       PRICE_LIST_ID                  = p_line_rec.price_list_id
    ,       PRICE_REQUEST_CODE             = p_line_rec.price_request_code  -- PROMOTIONS SEP/01
    ,       PRICING_ATTRIBUTE1             = p_line_rec.pricing_attribute1
    ,       PRICING_ATTRIBUTE10            = p_line_rec.pricing_attribute10
    ,       PRICING_ATTRIBUTE2             = p_line_rec.pricing_attribute2
    ,       PRICING_ATTRIBUTE3             = p_line_rec.pricing_attribute3
    ,       PRICING_ATTRIBUTE4             = p_line_rec.pricing_attribute4
    ,       PRICING_ATTRIBUTE5             = p_line_rec.pricing_attribute5
    ,       PRICING_ATTRIBUTE6             = p_line_rec.pricing_attribute6
    ,       PRICING_ATTRIBUTE7             = p_line_rec.pricing_attribute7
    ,       PRICING_ATTRIBUTE8             = p_line_rec.pricing_attribute8
    ,       PRICING_ATTRIBUTE9             = p_line_rec.pricing_attribute9
    ,       PRICING_CONTEXT                = p_line_rec.pricing_context
    ,       PRICING_DATE                   = p_line_rec.pricing_date
    ,       PRICING_QUANTITY               = p_line_rec.pricing_quantity
    ,       PRICING_QUANTITY_UOM           = p_line_rec.pricing_quantity_uom
    ,       PROGRAM_APPLICATION_ID         = p_line_rec.program_application_id
    ,       PROGRAM_ID                     = p_line_rec.program_id
    ,       PROGRAM_UPDATE_DATE            = p_line_rec.program_update_date
    ,       PROJECT_ID                     = p_line_rec.project_id
    ,       PROMISE_DATE                   = p_line_rec.promise_date
    ,       RE_SOURCE_FLAG                 = p_line_rec.re_source_flag
    ,       REFERENCE_CUSTOMER_TRX_LINE_ID = p_line_rec.reference_customer_trx_line_id
    ,       REFERENCE_HEADER_ID            = p_line_rec.reference_header_id
    ,       REFERENCE_LINE_ID              = p_line_rec.reference_line_id
    ,       REFERENCE_TYPE                 = p_line_rec.reference_type
    ,       REQUEST_DATE                   = p_line_rec.request_date
    ,       REQUEST_ID                     = p_line_rec.request_id
    ,       RETURN_ATTRIBUTE1              = p_line_rec.return_attribute1
    ,       RETURN_ATTRIBUTE10             = p_line_rec.return_attribute10
    ,       RETURN_ATTRIBUTE11             = p_line_rec.return_attribute11
    ,       RETURN_ATTRIBUTE12             = p_line_rec.return_attribute12
    ,       RETURN_ATTRIBUTE13             = p_line_rec.return_attribute13
    ,       RETURN_ATTRIBUTE14             = p_line_rec.return_attribute14
    ,       RETURN_ATTRIBUTE15             = p_line_rec.return_attribute15
    ,       RETURN_ATTRIBUTE2              = p_line_rec.return_attribute2
    ,       RETURN_ATTRIBUTE3              = p_line_rec.return_attribute3
    ,       RETURN_ATTRIBUTE4              = p_line_rec.return_attribute4
    ,       RETURN_ATTRIBUTE5              = p_line_rec.return_attribute5
    ,       RETURN_ATTRIBUTE6              = p_line_rec.return_attribute6
    ,       RETURN_ATTRIBUTE7              = p_line_rec.return_attribute7
    ,       RETURN_ATTRIBUTE8              = p_line_rec.return_attribute8
    ,       RETURN_ATTRIBUTE9              = p_line_rec.return_attribute9
    ,       RETURN_CONTEXT                 = p_line_rec.return_context
    ,       RETURN_REASON_CODE             = p_line_rec.return_reason_code
    ,       RLA_SCHEDULE_TYPE_CODE         = p_line_rec.rla_schedule_type_code
    ,       SALESREP_ID                    = p_line_rec.salesrep_id
    ,       SCHEDULE_ARRIVAL_DATE          = p_line_rec.schedule_arrival_date
    ,       SCHEDULE_SHIP_DATE             = p_line_rec.schedule_ship_date
    ,       SCHEDULE_STATUS_CODE           = p_line_rec.schedule_status_code
    ,       SHIPMENT_NUMBER                = p_line_rec.shipment_number
    ,       SHIPMENT_PRIORITY_CODE         = p_line_rec.shipment_priority_code
    ,       SHIPPED_QUANTITY               = p_line_rec.shipped_quantity
    ,       SHIPPED_QUANTITY2              = p_line_rec.shipped_quantity2  -- OPM B1661023 04/02/01
    ,       SHIPPING_METHOD_CODE           = p_line_rec.shipping_method_code
    ,       SHIPPING_QUANTITY              = p_line_rec.shipping_quantity
    ,       SHIPPING_QUANTITY2             = p_line_rec.shipping_quantity2 -- OPM B1661023 04/02/01
    ,       SHIPPING_QUANTITY_UOM          = p_line_rec.shipping_quantity_uom
    ,       SHIP_FROM_ORG_ID               = p_line_rec.ship_from_org_id
    ,       SUBINVENTORY                   = p_line_rec.subinventory
    ,       SHIP_TOLERANCE_ABOVE           = p_line_rec.ship_tolerance_above
    ,       SHIP_TOLERANCE_BELOW           = p_line_rec.ship_tolerance_below
    ,       SHIPPABLE_FLAG                 = p_line_rec.shippable_flag
    ,       SHIPPING_INTERFACED_FLAG       = p_line_rec.shipping_interfaced_flag
    ,       SHIP_TO_CONTACT_ID             = p_line_rec.ship_to_contact_id
    ,       SHIP_TO_ORG_ID                 = p_line_rec.ship_to_org_id
    ,       SHIP_MODEL_COMPLETE_FLAG       = p_line_rec.ship_model_complete_flag
    ,       SHIP_SET_ID                    = p_line_rec.ship_set_id
    ,       SOLD_TO_ORG_ID                 = p_line_rec.sold_to_org_id
    ,       SOLD_FROM_ORG_ID               = p_line_rec.sold_from_org_id
    ,       SORT_ORDER                     = p_line_rec.sort_order
    ,       SOURCE_DOCUMENT_ID             = p_line_rec.source_document_id
    ,       SOURCE_DOCUMENT_LINE_ID        = p_line_rec.source_document_line_id
    ,       SOURCE_DOCUMENT_TYPE_ID        = p_line_rec.source_document_type_id
    ,       SOURCE_TYPE_CODE               = p_line_rec.source_type_code
    ,       SPLIT_FROM_LINE_ID             = p_line_rec.split_from_line_id
    ,       LINE_SET_ID                    = p_line_rec.line_set_id
    ,       SPLIT_BY                       = p_line_rec.split_by
    ,       MODEL_REMNANT_FLAG             = p_line_rec.model_remnant_flag
    ,       TASK_ID                        = p_line_rec.task_id
    ,       TAX_CODE                       = p_line_rec.tax_code
    ,       TAX_DATE                       = p_line_rec.tax_date
    ,       TAX_EXEMPT_FLAG                = p_line_rec.tax_exempt_flag
    ,       TAX_EXEMPT_NUMBER              = p_line_rec.tax_exempt_number
    ,       TAX_EXEMPT_REASON_CODE         = p_line_rec.tax_exempt_reason_code
    ,       TAX_POINT_CODE                 = p_line_rec.tax_point_code
    ,       TAX_RATE                       = p_line_rec.tax_rate
    ,       TAX_VALUE                      = p_line_rec.tax_value
    ,       TOP_MODEL_LINE_ID              = p_line_rec.top_model_line_id
    ,       UNIT_LIST_PRICE                = p_line_rec.unit_list_price
    ,       UNIT_LIST_PRICE_PER_PQTY       = p_line_rec.unit_list_price_per_pqty
    ,       UNIT_SELLING_PRICE             = p_line_rec.unit_selling_price
    ,       UNIT_SELLING_PRICE_PER_PQTY    = p_line_rec.unit_selling_price_per_pqty
    ,       VISIBLE_DEMAND_FLAG            = p_line_rec.visible_demand_flag
    ,       VEH_CUS_ITEM_CUM_KEY_ID        = p_line_rec.veh_cus_item_cum_key_id
    ,       SHIPPING_INSTRUCTIONS          = p_line_rec.shipping_instructions
    ,       PACKING_INSTRUCTIONS           = p_line_rec.packing_instructions
    ,       SERVICE_TXN_REASON_CODE        = p_line_rec.service_txn_reason_code
    ,       SERVICE_TXN_COMMENTS           = p_line_rec.service_txn_comments
    ,       SERVICE_DURATION               = p_line_rec.service_duration
    ,       SERVICE_PERIOD                 = p_line_rec.service_period
    ,       SERVICE_START_DATE             = p_line_rec.service_start_date
    ,       SERVICE_END_DATE               = p_line_rec.service_end_date
    ,       SERVICE_COTERMINATE_FLAG       = p_line_rec.service_coterminate_flag
    ,       UNIT_LIST_PERCENT           = p_line_rec.unit_list_percent
    ,       UNIT_SELLING_PERCENT        = p_line_rec.unit_selling_percent
    ,       UNIT_PERCENT_BASE_PRICE     = p_line_rec.unit_percent_base_price
    ,       SERVICE_NUMBER              = p_line_rec.service_number
    ,       SERVICE_REFERENCE_TYPE_CODE = p_line_rec.service_reference_type_code
    ,       SERVICE_REFERENCE_LINE_ID   = p_line_rec.service_reference_line_id
    ,       SERVICE_REFERENCE_SYSTEM_ID = p_line_rec.service_reference_system_id
    ,       TP_CONTEXT                  = p_line_rec.tp_context
    ,       TP_ATTRIBUTE1               = p_line_rec.tp_attribute1
    ,       TP_ATTRIBUTE2               = p_line_rec.tp_attribute2
    ,       TP_ATTRIBUTE3               = p_line_rec.tp_attribute3
    ,       TP_ATTRIBUTE4               = p_line_rec.tp_attribute4
    ,       TP_ATTRIBUTE5               = p_line_rec.tp_attribute5
    ,       TP_ATTRIBUTE6               = p_line_rec.tp_attribute6
    ,       TP_ATTRIBUTE7               = p_line_rec.tp_attribute7
    ,       TP_ATTRIBUTE8               = p_line_rec.tp_attribute8
    ,       TP_ATTRIBUTE9               = p_line_rec.tp_attribute9
    ,       TP_ATTRIBUTE10              = p_line_rec.tp_attribute10
    ,       TP_ATTRIBUTE11              = p_line_rec.tp_attribute11
    ,       TP_ATTRIBUTE12              = p_line_rec.tp_attribute12
    ,       TP_ATTRIBUTE13              = p_line_rec.tp_attribute13
    ,       TP_ATTRIBUTE14              = p_line_rec.tp_attribute14
    ,       TP_ATTRIBUTE15              = p_line_rec.tp_attribute15
    ,       FLOW_STATUS_CODE		     = p_line_rec.flow_status_code
    ,       MARKETING_SOURCE_CODE_ID    = p_line_rec.marketing_source_code_id
    ,       ORIGINAL_INVENTORY_ITEM_ID  = p_line_rec.Original_Inventory_Item_Id
    ,       ORIGINAL_ITEM_IDENTIFIER_TYPE = p_line_rec.Original_item_identifier_Type
    ,       ORIGINAL_ORDERED_ITEM_ID    = p_line_rec.Original_ordered_item_id
    ,       ORIGINAL_ORDERED_ITEM       = p_line_rec.Original_ordered_item
    ,       ITEM_RELATIONSHIP_TYPE      = p_line_rec.item_relationship_type
    ,       ITEM_SUBSTITUTION_TYPE_CODE = p_line_rec.Item_substitution_type_code
    ,       LATE_DEMAND_PENALTY_FACTOR  = p_line_rec.Late_Demand_Penalty_Factor
    ,       OVERRIDE_ATP_DATE_CODE      = p_line_rec.Override_atp_date_code
    ,       FIRM_DEMAND_FLAG            = p_line_rec.firm_demand_flag
    ,       EARLIEST_SHIP_DATE          = p_line_rec.earliest_ship_date
    ,       USER_ITEM_DESCRIPTION       = p_line_rec.User_Item_Description
    ,       BLANKET_NUMBER              = p_line_rec.Blanket_Number
    ,       BLANKET_LINE_NUMBER         = p_line_rec.Blanket_Line_Number
    ,       BLANKET_VERSION_NUMBER      = p_line_rec.Blanket_Version_Number
    --MRG B
    ,       UNIT_COST                   = p_line_rec.unit_cost
    --MRG E
    ,       LOCK_CONTROL                = l_lock_control
-- Changes for quoting
    ,	    transaction_phase_code      = p_line_rec.transaction_phase_code
     ,      source_document_version_number = p_line_rec.source_document_version_number
-- end changes for quoting
    ,       MINISITE_ID                 = p_line_rec.Minisite_Id
    ,       IB_OWNER                    = p_line_rec.Ib_owner
    ,       IB_INSTALLED_AT_LOCATION    = p_line_rec.Ib_INSTALLED_AT_LOCATION
    ,       IB_CURRENT_LOCATION         = p_line_rec.Ib_current_location
    ,       END_CUSTOMER_ID             = p_line_rec.End_Customer_Id
    ,       END_CUSTOMER_CONTACT_ID     = p_line_rec.End_Customer_CONTACT_Id
    ,       END_CUSTOMER_SITE_USE_ID    = p_line_rec.End_Customer_site_use_Id
 /*   ,       SUPPLIER_SIGNATURE          = p_line_rec.SUPPLIER_SIGNATURE
    ,       SUPPLIER_SIGNATURE_DATE     = p_line_rec.SUPPLIER_SIGNATURE_DATE
    ,       CUSTOMER_SIGNATURE          = p_line_rec.CUSTOMER_SIGNATURE
    ,       CUSTOMER_SIGNATURE_DATE     = p_line_rec.CUSTOMER_SIGNATURE_DATE
*/
    --retro{
    ,       RETROBILL_REQUEST_ID        = p_line_rec.retrobill_request_id
    --retro
    -- Override List Price
    ,       ORIGINAL_LIST_PRICE         = p_line_rec.original_list_price
--key Transaction Dates
    ,       ORDER_FIRMED_DATE           = p_line_rec.order_firmed_date
    ,       ACTUAL_FULFILLMENT_DATE     = p_line_rec.actual_fulfillment_date
    --recurring charges
    , CHARGE_PERIODICITY_CODE = p_line_rec.charge_periodicity_code
-- INVCONV
    ,       CANCELLED_QUANTITY2         = p_line_rec.cancelled_quantity2
    ,       SHIPPING_QUANTITY_UOM2      = p_line_rec.shipping_quantity_uom2
    ,       FULFILLED_QUANTITY2         = p_line_rec.fulfilled_quantity2
--Customer Acceptance
    ,       CONTINGENCY_ID	        = p_line_rec.CONTINGENCY_ID
    ,       REVREC_EVENT_CODE	        = p_line_rec.REVREC_EVENT_CODE
    ,       REVREC_EXPIRATION_DAYS	= p_line_rec.REVREC_EXPIRATION_DAYS
    ,       ACCEPTED_QUANTITY	        = p_line_rec.ACCEPTED_QUANTITY
    ,       REVREC_COMMENTS	        = p_line_rec.REVREC_COMMENTS
    ,       REVREC_SIGNATURE	        = p_line_rec.REVREC_SIGNATURE
    ,       REVREC_SIGNATURE_DATE	= p_line_rec.REVREC_SIGNATURE_DATE
    ,       ACCEPTED_BY           	= p_line_rec.ACCEPTED_BY
    ,       REVREC_REFERENCE_DOCUMENT	= p_line_rec.REVREC_REFERENCE_DOCUMENT
    ,       REVREC_IMPLICIT_FLAG	= p_line_rec.REVREC_IMPLICIT_FLAG
    WHERE   LINE_ID 			   = p_line_rec.line_id
      AND   HEADER_ID 			   = p_line_rec.header_id ;

	IF SQL%NOTFOUND THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

    p_line_rec.lock_control := l_lock_control;

  if l_debug_level > 0 then
    oe_debug_pub.add('Exiting OE_LINE_UTIL.UPDATE_ROW', 1);
  end if;

EXCEPTION


    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Update_Row'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;


END Update_Row;


/*-----------------------------------------------------------
Procedure Insert_Row
-----------------------------------------------------------*/

PROCEDURE Insert_Row
(   p_line_rec                      IN  OUT  NOCOPY OE_Order_PUB.Line_Rec_Type
)
IS
l_org_id 	NUMBER ;
l_sold_from_org NUMBER;
l_upgraded_flag varchar2(1);
l_lock_control  NUMBER:= 1;
l_index         NUMBER;
l_return_status VARCHAR2(1);

l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--bug 4446805
l_price_request_code VARCHAR2(240);
BEGIN

  if l_debug_level > 0 then
    oe_debug_pub.add('Entering OE_LINE_UTIL.INSERT_ROW', 1);
  end if;

 --MOAC change
 OE_GLOBALS.Set_Context;
 l_org_id := OE_GLOBALS.G_ORG_ID;
 IF l_org_id IS NULL THEN
     -- org_id is null, don't do insert. raise an error.
     IF l_debug_level > 0 then
          oe_debug_pub.ADD('Org_Id is NULL',1);
     END IF;
     FND_MESSAGE.SET_NAME('FND','MO_ORG_REQUIRED');
     FND_MSG_PUB.ADD;
     RAISE FND_API.G_EXC_ERROR;
 END IF;
 /*
	    if l_org_id IS NULL THEN
		    OE_GLOBALS.Set_Context;
		    l_org_id := OE_GLOBALS.G_ORG_ID;
	    end if;
 */
 l_sold_from_org := l_org_id;

-- For the split's issue Bug #3721385
   if p_line_rec.split_from_line_id is not null and  p_line_rec.operation = OE_GLOBALS.G_OPR_CREATE AND
      (p_line_rec.sold_from_org_id is not null OR p_line_rec.sold_from_org_id <> FND_API.G_MISS_NUM)
   then

      l_sold_from_org := p_line_rec.sold_from_org_id;
   end if;

-- This change is to ensure the upgraded flag is not populated through any
-- source other than upgrade and split. Upgrade uses direct insertion and
-- split follows this path.

		IF  p_line_rec.split_from_line_id is null
		THEN
		  l_upgraded_flag := null;
	     ELSE
				l_upgraded_flag := p_line_rec.upgraded_flag;
	     END IF;
--bug 4446805 set the price request code to NULL if operation is create during splitting
        IF p_line_rec.split_from_line_id is not null AND
            p_line_rec.split_from_line_id <> FND_API.G_MISS_NUM AND
             p_line_rec.operation = OE_GLOBALS.G_OPR_CREATE
        THEN
             l_price_request_code := NULL;
        ELSE
             l_price_request_code := p_line_rec.price_request_code;
        END IF;
--End bug 4446805

    -- OPM 02/JUN/00 - Include process columns
    --                (ordered_quantity2,ordered_quantity_uom2,preferred_grade)
    -- =======================================================================
    INSERT  INTO OE_ORDER_LINES
    (       ACCOUNTING_RULE_ID
    ,       ACCOUNTING_RULE_DURATION
    ,       ACTUAL_ARRIVAL_DATE
    ,       ACTUAL_SHIPMENT_DATE
    ,       AGREEMENT_ID
    ,       ARRIVAL_SET_ID
    ,       ATO_LINE_ID
    ,       ATTRIBUTE1
    ,       ATTRIBUTE10
    ,       ATTRIBUTE11
    ,       ATTRIBUTE12
    ,       ATTRIBUTE13
    ,       ATTRIBUTE14
    ,       ATTRIBUTE15
    ,       ATTRIBUTE16   --For bug 2184255
    ,       ATTRIBUTE17
    ,       ATTRIBUTE18
    ,       ATTRIBUTE19
    ,       ATTRIBUTE2
    ,       ATTRIBUTE20
    ,       ATTRIBUTE3
    ,       ATTRIBUTE4
    ,       ATTRIBUTE5
    ,       ATTRIBUTE6
    ,       ATTRIBUTE7
    ,       ATTRIBUTE8
    ,       ATTRIBUTE9
    ,       AUTO_SELECTED_QUANTITY
    ,       AUTHORIZED_TO_SHIP_FLAG
    ,       BOOKED_FLAG
    ,       CANCELLED_FLAG
    ,       CANCELLED_QUANTITY
    ,       COMPONENT_CODE
    ,       COMPONENT_NUMBER
    ,       COMPONENT_SEQUENCE_ID
    ,       CONFIG_HEADER_ID
    ,       CONFIG_REV_NBR
    ,       CONFIG_DISPLAY_SEQUENCE
    ,       CONFIGURATION_ID
    ,       CONTEXT
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       CREDIT_INVOICE_LINE_ID
    ,       CUSTOMER_LINE_NUMBER
    ,       CUSTOMER_SHIPMENT_NUMBER
    ,       CUSTOMER_ITEM_NET_PRICE
    ,       CUSTOMER_PAYMENT_TERM_ID
    ,       CUSTOMER_DOCK_CODE
    ,       CUSTOMER_JOB
    ,       CUSTOMER_PRODUCTION_LINE
    ,       CUST_PRODUCTION_SEQ_NUM
    ,       CUSTOMER_TRX_LINE_ID
    ,       CUST_MODEL_SERIAL_NUMBER
    ,       CUST_PO_NUMBER
    ,       DELIVERY_LEAD_TIME
    ,       DELIVER_TO_CONTACT_ID
    ,       DELIVER_TO_ORG_ID
    ,       DEMAND_BUCKET_TYPE_CODE
    ,       DEMAND_CLASS_CODE
    ,       DEP_PLAN_REQUIRED_FLAG
    --,       DROP_SHIP_FLAG
    ,       EARLIEST_ACCEPTABLE_DATE
    ,       END_ITEM_UNIT_NUMBER
    ,       EXPLOSION_DATE
    ,       FIRST_ACK_CODE
    ,       FIRST_ACK_DATE
    ,       FOB_POINT_CODE
    ,       FREIGHT_CARRIER_CODE
    ,       FREIGHT_TERMS_CODE
    ,       FULFILLED_QUANTITY
    ,       FULFILLED_FLAG
    ,       FULFILLMENT_METHOD_CODE
    ,       FULFILLMENT_DATE
    ,       GLOBAL_ATTRIBUTE1
    ,       GLOBAL_ATTRIBUTE10
    ,       GLOBAL_ATTRIBUTE11
    ,       GLOBAL_ATTRIBUTE12
    ,       GLOBAL_ATTRIBUTE13
    ,       GLOBAL_ATTRIBUTE14
    ,       GLOBAL_ATTRIBUTE15
    ,       GLOBAL_ATTRIBUTE16
    ,       GLOBAL_ATTRIBUTE17
    ,       GLOBAL_ATTRIBUTE18
    ,       GLOBAL_ATTRIBUTE19
    ,       GLOBAL_ATTRIBUTE2
    ,       GLOBAL_ATTRIBUTE20
    ,       GLOBAL_ATTRIBUTE3
    ,       GLOBAL_ATTRIBUTE4
    ,       GLOBAL_ATTRIBUTE5
    ,       GLOBAL_ATTRIBUTE6
    ,       GLOBAL_ATTRIBUTE7
    ,       GLOBAL_ATTRIBUTE8
    ,       GLOBAL_ATTRIBUTE9
    ,       GLOBAL_ATTRIBUTE_CATEGORY
    ,       HEADER_ID
    ,       INDUSTRY_ATTRIBUTE1
    ,       INDUSTRY_ATTRIBUTE10
    ,       INDUSTRY_ATTRIBUTE11
    ,       INDUSTRY_ATTRIBUTE12
    ,       INDUSTRY_ATTRIBUTE13
    ,       INDUSTRY_ATTRIBUTE14
    ,       INDUSTRY_ATTRIBUTE15
    ,       INDUSTRY_ATTRIBUTE16
    ,       INDUSTRY_ATTRIBUTE17
    ,       INDUSTRY_ATTRIBUTE18
    ,       INDUSTRY_ATTRIBUTE19
    ,       INDUSTRY_ATTRIBUTE20
    ,       INDUSTRY_ATTRIBUTE21
    ,       INDUSTRY_ATTRIBUTE22
    ,       INDUSTRY_ATTRIBUTE23
    ,       INDUSTRY_ATTRIBUTE24
    ,       INDUSTRY_ATTRIBUTE25
    ,       INDUSTRY_ATTRIBUTE26
    ,       INDUSTRY_ATTRIBUTE27
    ,       INDUSTRY_ATTRIBUTE28
    ,       INDUSTRY_ATTRIBUTE29
    ,       INDUSTRY_ATTRIBUTE30
    ,       INDUSTRY_ATTRIBUTE2
    ,       INDUSTRY_ATTRIBUTE3
    ,       INDUSTRY_ATTRIBUTE4
    ,       INDUSTRY_ATTRIBUTE5
    ,       INDUSTRY_ATTRIBUTE6
    ,       INDUSTRY_ATTRIBUTE7
    ,       INDUSTRY_ATTRIBUTE8
    ,       INDUSTRY_ATTRIBUTE9
    ,       INDUSTRY_CONTEXT
    ,       INTMED_SHIP_TO_CONTACT_ID
    ,       INTMED_SHIP_TO_ORG_ID
    ,       INVENTORY_ITEM_ID
    ,       INVOICE_INTERFACE_STATUS_CODE
    ,       INVOICE_TO_CONTACT_ID
    ,       INVOICE_TO_ORG_ID
    ,       INVOICED_QUANTITY
    ,       INVOICING_RULE_ID
    ,       ORDERED_ITEM_ID
    ,       ITEM_IDENTIFIER_TYPE
    ,       ORDERED_ITEM
    ,       ITEM_REVISION
    ,       ITEM_TYPE_CODE
    ,       LAST_ACK_CODE
    ,       LAST_ACK_DATE
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       LATEST_ACCEPTABLE_DATE
    ,       LINE_CATEGORY_CODE
    ,       LINE_ID
    ,       LINE_NUMBER
    ,       LINE_TYPE_ID
    ,       LINK_TO_LINE_ID
    ,       MODEL_GROUP_NUMBER
   -- ,       MFG_COMPONENT_SEQUENCE_ID
    ,       MFG_LEAD_TIME
    ,       OPEN_FLAG
    ,       OPTION_FLAG
    ,       OPTION_NUMBER
    ,       ORDERED_QUANTITY
    ,       ORDERED_QUANTITY2           --OPM Added 02/JUN/00
    ,       ORDER_QUANTITY_UOM
    ,       ORDERED_QUANTITY_UOM2       --OPM Added 02/JUN/00
    ,       ORG_ID                      -- MOAC change
    ,       ORDER_SOURCE_ID
    ,       ORIG_SYS_DOCUMENT_REF
    ,       ORIG_SYS_LINE_REF
    ,       ORIG_SYS_SHIPMENT_REF
    ,       CHANGE_SEQUENCE
    ,       OVER_SHIP_REASON_CODE
    ,       OVER_SHIP_RESOLVED_FLAG
    ,       PAYMENT_TERM_ID
    ,       PLANNING_PRIORITY
    ,       PREFERRED_GRADE             --OPM Added 02/JUN/00
    ,       PRICE_LIST_ID
    ,       PRICE_REQUEST_CODE          --PROMOTIONS SEP/01
    ,       PRICING_ATTRIBUTE1
    ,       PRICING_ATTRIBUTE10
    ,       PRICING_ATTRIBUTE2
    ,       PRICING_ATTRIBUTE3
    ,       PRICING_ATTRIBUTE4
    ,       PRICING_ATTRIBUTE5
    ,       PRICING_ATTRIBUTE6
    ,       PRICING_ATTRIBUTE7
    ,       PRICING_ATTRIBUTE8
    ,       PRICING_ATTRIBUTE9
    ,       PRICING_CONTEXT
    ,       PRICING_DATE
    ,       PRICING_QUANTITY
    ,       PRICING_QUANTITY_UOM
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       PROJECT_ID
    ,       PROMISE_DATE
    ,       RE_SOURCE_FLAG
    ,       REFERENCE_CUSTOMER_TRX_LINE_ID
    ,       REFERENCE_HEADER_ID
    ,       REFERENCE_LINE_ID
    ,       REFERENCE_TYPE
    ,       REQUEST_DATE
    ,       REQUEST_ID
    ,       RETURN_ATTRIBUTE1
    ,       RETURN_ATTRIBUTE10
    ,       RETURN_ATTRIBUTE11
    ,       RETURN_ATTRIBUTE12
    ,       RETURN_ATTRIBUTE13
    ,       RETURN_ATTRIBUTE14
    ,       RETURN_ATTRIBUTE15
    ,       RETURN_ATTRIBUTE2
    ,       RETURN_ATTRIBUTE3
    ,       RETURN_ATTRIBUTE4
    ,       RETURN_ATTRIBUTE5
    ,       RETURN_ATTRIBUTE6
    ,       RETURN_ATTRIBUTE7
    ,       RETURN_ATTRIBUTE8
    ,       RETURN_ATTRIBUTE9
    ,       RETURN_CONTEXT
    ,       RETURN_REASON_CODE
    ,       RLA_SCHEDULE_TYPE_CODE
    ,       SALESREP_ID
    ,       SCHEDULE_ARRIVAL_DATE
    ,       SCHEDULE_SHIP_DATE
    ,       SCHEDULE_STATUS_CODE
    ,       SHIPMENT_NUMBER
    ,       SHIPMENT_PRIORITY_CODE
    ,       SHIPPED_QUANTITY
    ,       SHIPPED_QUANTITY2 -- OPM B1661023 04/02/01
    ,       SHIPPING_METHOD_CODE
    ,       SHIPPING_QUANTITY
    ,       SHIPPING_QUANTITY2 -- OPM B1661023 04/02/01
    ,       SHIPPING_QUANTITY_UOM
    ,       SHIP_FROM_ORG_ID
    ,       SUBINVENTORY
    ,       SHIP_SET_ID
    ,       SHIP_TOLERANCE_ABOVE
    ,       SHIP_TOLERANCE_BELOW
    ,       SHIPPABLE_FLAG
    ,       SHIPPING_INTERFACED_FLAG
    ,       SHIP_TO_CONTACT_ID
    ,       SHIP_TO_ORG_ID
    ,       SHIP_MODEL_COMPLETE_FLAG
    ,       SOLD_TO_ORG_ID
    ,       SOLD_FROM_ORG_ID
    ,       SORT_ORDER
    ,       SOURCE_DOCUMENT_ID
    ,       SOURCE_DOCUMENT_LINE_ID
    ,       SOURCE_DOCUMENT_TYPE_ID
    ,       SOURCE_TYPE_CODE
    ,       SPLIT_FROM_LINE_ID
    ,       LINE_SET_ID
    ,       SPLIT_BY
    ,       model_remnant_flag
    ,       TASK_ID
    ,       TAX_CODE
    ,       TAX_DATE
    ,       TAX_EXEMPT_FLAG
    ,       TAX_EXEMPT_NUMBER
    ,       TAX_EXEMPT_REASON_CODE
    ,       TAX_POINT_CODE
    ,       TAX_RATE
    ,       TAX_VALUE
    ,       TOP_MODEL_LINE_ID
    ,       UNIT_LIST_PRICE
    ,       UNIT_LIST_PRICE_PER_PQTY
    ,       UNIT_SELLING_PRICE
    ,       UNIT_SELLING_PRICE_PER_PQTY
    ,       VISIBLE_DEMAND_FLAG
    ,       VEH_CUS_ITEM_CUM_KEY_ID
    ,       SHIPPING_INSTRUCTIONS
    ,       PACKING_INSTRUCTIONS
    ,       SERVICE_TXN_REASON_CODE
    ,       SERVICE_TXN_COMMENTS
    ,       SERVICE_DURATION
    ,       SERVICE_PERIOD
    ,       SERVICE_START_DATE
    ,       SERVICE_END_DATE
    ,       SERVICE_COTERMINATE_FLAG
    ,       UNIT_LIST_PERCENT
    ,       UNIT_SELLING_PERCENT
    ,       UNIT_PERCENT_BASE_PRICE
    ,       SERVICE_NUMBER
    ,       SERVICE_REFERENCE_TYPE_CODE
    ,       SERVICE_REFERENCE_LINE_ID
    ,       SERVICE_REFERENCE_SYSTEM_ID
    ,       TP_CONTEXT
    ,       TP_ATTRIBUTE1
    ,       TP_ATTRIBUTE2
    ,       TP_ATTRIBUTE3
    ,       TP_ATTRIBUTE4
    ,       TP_ATTRIBUTE5
    ,       TP_ATTRIBUTE6
    ,       TP_ATTRIBUTE7
    ,       TP_ATTRIBUTE8
    ,       TP_ATTRIBUTE9
    ,       TP_ATTRIBUTE10
    ,       TP_ATTRIBUTE11
    ,       TP_ATTRIBUTE12
    ,       TP_ATTRIBUTE13
    ,       TP_ATTRIBUTE14
    ,       TP_ATTRIBUTE15
    ,       FLOW_STATUS_CODE
    ,       MARKETING_SOURCE_CODE_ID
    ,       CALCULATE_PRICE_FLAG
    ,       COMMITMENT_ID
    ,       UPGRADED_FLAG
    ,       ORIGINAL_INVENTORY_ITEM_ID
    ,       ORIGINAL_ITEM_IDENTIFIER_TYPE
    ,       ORIGINAL_ORDERED_ITEM_ID
    ,       ORIGINAL_ORDERED_ITEM
    ,       ITEM_RELATIONSHIP_TYPE
    ,       ITEM_SUBSTITUTION_TYPE_CODE
    ,       LATE_DEMAND_PENALTY_FACTOR
    ,       OVERRIDE_ATP_DATE_CODE
    ,       FIRM_DEMAND_FLAG
    ,       EARLIEST_SHIP_DATE
    ,       USER_ITEM_DESCRIPTION
    ,       BLANKET_NUMBER
    ,       BLANKET_LINE_NUMBER
    ,       BLANKET_VERSION_NUMBER
--MRG B
    ,       UNIT_COST
--MRG E
    ,       LOCK_CONTROL
-- Changes for quoting
    ,	    transaction_phase_code
    ,       source_document_version_number
-- end changes for quoting
   ,        Minisite_ID
   ,        Ib_Owner
   ,        Ib_installed_at_location
   ,        Ib_current_location
   ,        End_customer_ID
   ,        End_customer_contact_ID
   ,        End_customer_site_use_ID
 /*  ,        Supplier_signature
   ,        Supplier_signature_date
   ,        Customer_signature
   ,        Customer_signature_date  */
--retro{
    ,       RETROBILL_REQUEST_ID
--retro}
    ,       ORIGINAL_LIST_PRICE  -- Override List Price
 -- Key Transaction Dates
    ,       order_firmed_date
    ,       actual_fulfillment_date
    --recurring charges
    ,       charge_periodicity_code
-- INVCONV
    ,       CANCELLED_QUANTITY2
    ,       SHIPPING_QUANTITY_UOM2
    ,       FULFILLED_QUANTITY2
--Customer Acceptance
    ,       CONTINGENCY_ID
    ,       REVREC_EVENT_CODE
    ,       REVREC_EXPIRATION_DAYS
    ,       ACCEPTED_QUANTITY
    ,       REVREC_COMMENTS
    ,       REVREC_SIGNATURE
    ,       REVREC_SIGNATURE_DATE
    ,       ACCEPTED_BY
    ,       REVREC_REFERENCE_DOCUMENT
    ,       REVREC_IMPLICIT_FLAG

-- { DOO/O2C Integration
    ,      BYPASS_SCH_FLAG
    ,      PRE_EXPLODED_FLAG
--  DOO/O2C Integration }
    )
    VALUES
    (       p_line_rec.accounting_rule_id
    ,       p_line_rec.accounting_rule_duration
    ,       p_line_rec.actual_arrival_date
    ,       p_line_rec.actual_shipment_date
    ,       p_line_rec.agreement_id
    ,       p_line_rec.arrival_set_id
    ,       p_line_rec.ato_line_id
    ,       p_line_rec.attribute1
    ,       p_line_rec.attribute10
    ,       p_line_rec.attribute11
    ,       p_line_rec.attribute12
    ,       p_line_rec.attribute13
    ,       p_line_rec.attribute14
    ,       p_line_rec.attribute15
    ,       p_line_rec.attribute16   --For bug 2184255
    ,       p_line_rec.attribute17
    ,       p_line_rec.attribute18
    ,       p_line_rec.attribute19
    ,       p_line_rec.attribute2
    ,       p_line_rec.attribute20
    ,       p_line_rec.attribute3
    ,       p_line_rec.attribute4
    ,       p_line_rec.attribute5
    ,       p_line_rec.attribute6
    ,       p_line_rec.attribute7
    ,       p_line_rec.attribute8
    ,       p_line_rec.attribute9
    ,       p_line_rec.auto_selected_quantity
    ,       p_line_rec.authorized_to_ship_flag
    ,       p_line_rec.booked_flag
    ,       p_line_rec.cancelled_flag
    ,       p_line_rec.cancelled_quantity
    ,       p_line_rec.component_code
    ,       p_line_rec.component_number
    ,       p_line_rec.component_sequence_id
    ,       p_line_rec.config_header_id
    ,       p_line_rec.config_rev_nbr
    ,       p_line_rec.config_display_sequence
    ,       p_line_rec.configuration_id
    ,       p_line_rec.context
    ,       p_line_rec.created_by
    ,       p_line_rec.creation_date
    ,       p_line_rec.credit_invoice_line_id
    ,       p_line_rec.customer_line_number
    ,       p_line_rec.customer_shipment_number
    ,       p_line_rec.customer_item_net_price
    ,       p_line_rec.customer_payment_term_id
    ,       p_line_rec.customer_dock_code
    ,       p_line_rec.customer_job
    ,       p_line_rec.customer_production_line
    ,       p_line_rec.cust_production_seq_num
    ,       p_line_rec.customer_trx_line_id
    ,       p_line_rec.cust_model_serial_number
    ,       p_line_rec.cust_po_number
    ,       p_line_rec.delivery_lead_time
    ,       p_line_rec.deliver_to_contact_id
    ,       p_line_rec.deliver_to_org_id
    ,       p_line_rec.demand_bucket_type_code
    ,       p_line_rec.demand_class_code
    ,       p_line_rec.dep_plan_required_flag
    --,       p_line_rec.drop_ship_flag
    ,       p_line_rec.earliest_acceptable_date
    ,       p_line_rec.end_item_unit_number
    ,       p_line_rec.explosion_date
    ,       p_line_rec.first_ack_code
    ,       p_line_rec.first_ack_date
    ,       p_line_rec.fob_point_code
    ,       p_line_rec.freight_carrier_code
    ,       p_line_rec.freight_terms_code
    ,       p_line_rec.fulfilled_quantity
    ,       p_line_rec.fulfilled_flag
    ,       p_line_rec.fulfillment_method_code
    ,       p_line_rec.fulfillment_date
    ,       p_line_rec.global_attribute1
    ,       p_line_rec.global_attribute10
    ,       p_line_rec.global_attribute11
    ,       p_line_rec.global_attribute12
    ,       p_line_rec.global_attribute13
    ,       p_line_rec.global_attribute14
    ,       p_line_rec.global_attribute15
    ,       p_line_rec.global_attribute16
    ,       p_line_rec.global_attribute17
    ,       p_line_rec.global_attribute18
    ,       p_line_rec.global_attribute19
    ,       p_line_rec.global_attribute2
    ,       p_line_rec.global_attribute20
    ,       p_line_rec.global_attribute3
    ,       p_line_rec.global_attribute4
    ,       p_line_rec.global_attribute5
    ,       p_line_rec.global_attribute6
    ,       p_line_rec.global_attribute7
    ,       p_line_rec.global_attribute8
    ,       p_line_rec.global_attribute9
    ,       p_line_rec.global_attribute_category
    ,       p_line_rec.header_id
    ,       p_line_rec.industry_attribute1
    ,       p_line_rec.industry_attribute10
    ,       p_line_rec.industry_attribute11
    ,       p_line_rec.industry_attribute12
    ,       p_line_rec.industry_attribute13
    ,       p_line_rec.industry_attribute14
    ,       p_line_rec.industry_attribute15
    ,       p_line_rec.industry_attribute16
    ,       p_line_rec.industry_attribute17
    ,       p_line_rec.industry_attribute18
    ,       p_line_rec.industry_attribute19
    ,       p_line_rec.industry_attribute20
    ,       p_line_rec.industry_attribute21
    ,       p_line_rec.industry_attribute22
    ,       p_line_rec.industry_attribute23
    ,       p_line_rec.industry_attribute24
    ,       p_line_rec.industry_attribute25
    ,       p_line_rec.industry_attribute26
    ,       p_line_rec.industry_attribute27
    ,       p_line_rec.industry_attribute28
    ,       p_line_rec.industry_attribute29
    ,       p_line_rec.industry_attribute30
    ,       p_line_rec.industry_attribute2
    ,       p_line_rec.industry_attribute3
    ,       p_line_rec.industry_attribute4
    ,       p_line_rec.industry_attribute5
    ,       p_line_rec.industry_attribute6
    ,       p_line_rec.industry_attribute7
    ,       p_line_rec.industry_attribute8
    ,       p_line_rec.industry_attribute9
    ,       p_line_rec.industry_context
    ,       p_line_rec.intermed_ship_to_contact_id
    ,       p_line_rec.intermed_ship_to_org_id
    ,       p_line_rec.inventory_item_id
    ,       p_line_rec.invoice_interface_status_code
    ,       p_line_rec.invoice_to_contact_id
    ,       p_line_rec.invoice_to_org_id
    ,       p_line_rec.invoiced_quantity
    ,       p_line_rec.invoicing_rule_id
    ,       p_line_rec.ordered_item_id
    ,       p_line_rec.item_identifier_type
    ,       p_line_rec.ordered_item
    ,       p_line_rec.item_revision
    ,       p_line_rec.item_type_code
    ,       p_line_rec.last_ack_code
    ,       p_line_rec.last_ack_date
    ,       p_line_rec.last_updated_by
    ,       p_line_rec.last_update_date
    ,       p_line_rec.last_update_login
    ,       p_line_rec.latest_acceptable_date
    ,       p_line_rec.line_category_code
    ,       p_line_rec.line_id
    ,       p_line_rec.line_number
    ,       p_line_rec.line_type_id
    ,       p_line_rec.link_to_line_id
    ,       p_line_rec.model_group_number
    --,       p_line_rec.mfg_component_sequence_id
    ,       p_line_rec.mfg_lead_time
    ,       p_line_rec.open_flag
    ,       p_line_rec.option_flag
    ,       p_line_rec.option_number
    ,       p_line_rec.ordered_quantity
    ,       p_line_rec.ordered_quantity2          --OPM 02/JUN/00
    ,       p_line_rec.order_quantity_uom
    ,       p_line_rec.ordered_quantity_uom2      --OPM 02/JUN/00
    ,       l_org_id                              --MOAC change
    ,       p_line_rec.order_source_id
    ,       p_line_rec.orig_sys_document_ref
    ,       p_line_rec.orig_sys_line_ref
    ,       p_line_rec.orig_sys_shipment_ref
    ,       p_line_rec.change_sequence
    ,       p_line_rec.over_ship_reason_code
    ,       p_line_rec.over_ship_resolved_flag
    ,       p_line_rec.payment_term_id
    ,       p_line_rec.planning_priority
    ,       p_line_rec.preferred_grade            --OPM 02/JUN/00
    ,       p_line_rec.price_list_id
    ,       l_price_request_code         --PROMOTIONS SEP/01   --bug 4446805
    ,       p_line_rec.pricing_attribute1
    ,       p_line_rec.pricing_attribute10
    ,       p_line_rec.pricing_attribute2
    ,       p_line_rec.pricing_attribute3
    ,       p_line_rec.pricing_attribute4
    ,       p_line_rec.pricing_attribute5
    ,       p_line_rec.pricing_attribute6
    ,       p_line_rec.pricing_attribute7
    ,       p_line_rec.pricing_attribute8
    ,       p_line_rec.pricing_attribute9
    ,       p_line_rec.pricing_context
    ,       p_line_rec.pricing_date
    ,       p_line_rec.pricing_quantity
    ,       p_line_rec.pricing_quantity_uom
    ,       p_line_rec.program_application_id
    ,       p_line_rec.program_id
    ,       p_line_rec.program_update_date
    ,       p_line_rec.project_id
    ,       p_line_rec.promise_date
    ,       p_line_rec.re_source_flag
    ,       p_line_rec.reference_customer_trx_line_id
    ,       p_line_rec.reference_header_id
    ,       p_line_rec.reference_line_id
    ,       p_line_rec.reference_type
    ,       p_line_rec.request_date
    ,       p_line_rec.request_id
    ,       p_line_rec.return_attribute1
    ,       p_line_rec.return_attribute10
    ,       p_line_rec.return_attribute11
    ,       p_line_rec.return_attribute12
    ,       p_line_rec.return_attribute13
    ,       p_line_rec.return_attribute14
    ,       p_line_rec.return_attribute15
    ,       p_line_rec.return_attribute2
    ,       p_line_rec.return_attribute3
    ,       p_line_rec.return_attribute4
    ,       p_line_rec.return_attribute5
    ,       p_line_rec.return_attribute6
    ,       p_line_rec.return_attribute7
    ,       p_line_rec.return_attribute8
    ,       p_line_rec.return_attribute9
    ,       p_line_rec.return_context
    ,       p_line_rec.return_reason_code
    ,       p_line_rec.rla_schedule_type_code
    ,       p_line_rec.salesrep_id
    ,       p_line_rec.schedule_arrival_date
    ,       p_line_rec.schedule_ship_date
    ,       p_line_rec.schedule_status_code
    ,       p_line_rec.shipment_number
    ,       p_line_rec.shipment_priority_code
    ,       p_line_rec.shipped_quantity
    ,       p_line_rec.shipped_quantity2 -- OPM B1661023 04/02/01
    ,       p_line_rec.shipping_method_code
    ,       p_line_rec.shipping_quantity
    ,       p_line_rec.shipping_quantity2    -- OPM B1661023 04/02/01
    ,       p_line_rec.shipping_quantity_uom
    ,       p_line_rec.ship_from_org_id
    ,       p_line_Rec.subinventory
    ,       p_line_rec.ship_set_id
    ,       p_line_rec.ship_tolerance_above
    ,       p_line_rec.ship_tolerance_below
    ,       p_line_rec.shippable_flag
    ,       p_line_rec.shipping_interfaced_flag
    ,       p_line_rec.ship_to_contact_id
    ,       p_line_rec.ship_to_org_id
    ,       p_line_rec.ship_model_complete_flag

    ,       p_line_rec.sold_to_org_id
    ,       l_sold_from_org
    ,       p_line_rec.sort_order
    ,       p_line_rec.source_document_id
    ,       p_line_rec.source_document_line_id
    ,       p_line_rec.source_document_type_id
    ,       p_line_rec.source_type_code
    ,       p_line_rec.split_from_line_id
    ,       p_line_rec.line_set_id
    ,       p_line_rec.split_by
    ,       p_line_rec.model_remnant_flag
    ,       p_line_rec.task_id
    ,       p_line_rec.tax_code
    ,       p_line_rec.tax_date
    ,       p_line_rec.tax_exempt_flag
    ,       p_line_rec.tax_exempt_number
    ,       p_line_rec.tax_exempt_reason_code
    ,       p_line_rec.tax_point_code
    ,       p_line_rec.tax_rate
    ,       p_line_rec.tax_value
    ,       p_line_rec.top_model_line_id
    ,       p_line_rec.unit_list_price
    ,       p_line_rec.unit_list_price_per_pqty
    ,       p_line_rec.unit_selling_price
    ,       p_line_rec.unit_selling_price_per_pqty
    ,       p_line_rec.visible_demand_flag
    ,       p_line_rec.veh_cus_item_cum_key_id
    ,       p_line_rec.shipping_instructions
    ,       p_line_rec.packing_instructions
    ,       p_line_rec.service_txn_reason_code
    ,       p_line_rec.service_txn_comments
    ,       p_line_rec.service_duration
    ,       p_line_rec.service_period
    ,       p_line_rec.service_start_date
    ,       p_line_rec.service_end_date
    ,       p_line_rec.service_coterminate_flag
    ,       p_line_rec.unit_list_percent
    ,       p_line_rec.unit_selling_percent
    ,       p_line_rec.unit_percent_base_price
    ,       p_line_rec.service_number
    ,       p_line_rec.service_reference_type_code
    ,       p_line_rec.service_reference_line_id
    ,       p_line_rec.service_reference_system_id
    ,       p_line_rec.tp_context
    ,       p_line_rec.tp_attribute1
    ,       p_line_rec.tp_attribute2
    ,       p_line_rec.tp_attribute3
    ,       p_line_rec.tp_attribute4
    ,       p_line_rec.tp_attribute5
    ,       p_line_rec.tp_attribute6
    ,       p_line_rec.tp_attribute7
    ,       p_line_rec.tp_attribute8
    ,       p_line_rec.tp_attribute9
    ,       p_line_rec.tp_attribute10
    ,       p_line_rec.tp_attribute11
    ,       p_line_rec.tp_attribute12
    ,       p_line_rec.tp_attribute13
    ,       p_line_rec.tp_attribute14
    ,       p_line_rec.tp_attribute15
    ,       p_line_rec.flow_status_code
    ,       p_line_rec.marketing_source_code_id
    ,       p_line_rec.calculate_price_flag
    ,       p_line_rec.commitment_id
    ,       l_upgraded_flag
    ,       p_line_rec.original_inventory_item_id
    ,       p_line_rec.original_item_identifier_Type
    ,       p_line_rec.original_ordered_item_id
    ,       p_line_rec.original_ordered_item
    ,       p_line_rec.item_relationship_type
    ,       p_line_rec.item_substitution_type_code
    ,       p_line_rec.late_demand_penalty_factor
    ,       p_line_rec.Override_atp_date_code
    ,       p_line_rec.Firm_demand_flag
    ,       p_line_rec.Earliest_ship_date
    ,       p_line_rec.user_item_description
    ,       p_line_rec.Blanket_Number
    ,       p_line_rec.Blanket_Line_Number
    ,       p_line_rec.Blanket_Version_Number
--MRG B
    ,       p_line_rec.unit_cost
--MRG E
    ,       l_lock_control
-- Changes for quoting
    ,	    p_line_rec.transaction_phase_code
    ,       p_line_rec.source_document_version_number
-- end changes for quoting
   ,        p_line_rec.Minisite_Id
   ,        p_line_rec.Ib_owner
   ,        p_line_rec.Ib_installed_at_location
   ,        p_line_rec.Ib_current_location
   ,        p_line_rec.End_customer_Id
   ,        p_line_rec.End_customer_contact_Id
   ,        p_line_rec.End_customer_site_use_Id
 /*  ,        p_line_rec.Supplier_signature
   ,        p_line_rec.Supplier_signature_date
   ,        p_line_rec.customer_signature
   ,        p_line_rec.customer_signature_date */
--retro{
   ,        p_line_rec.retrobill_request_id
--retro}
   ,        p_line_rec.original_list_price -- Override List Price
-- key Transaction Dates
   ,        p_line_rec.order_firmed_date
   ,        p_line_rec.actual_fulfillment_date
   --recurring charges
   ,        p_line_rec.charge_periodicity_code
-- INVCONV
    ,       p_line_rec.cancelled_quantity2
    ,       p_line_rec.shipping_quantity_uom2
    ,       p_line_rec.fulfilled_quantity2
    ,       p_line_rec.CONTINGENCY_ID
    ,       p_line_rec.REVREC_EVENT_CODE
    ,       p_line_rec.REVREC_EXPIRATION_DAYS
    ,       p_line_rec.ACCEPTED_QUANTITY
    ,       p_line_rec.REVREC_COMMENTS
    ,       p_line_rec.REVREC_SIGNATURE
    ,       p_line_rec.REVREC_SIGNATURE_DATE
    ,       p_line_rec.ACCEPTED_BY
    ,       p_line_rec.REVREC_REFERENCE_DOCUMENT
    ,       p_line_rec.REVREC_IMPLICIT_FLAG

-- { O2C/DOO Integration
    ,      p_line_rec.BYPASS_SCH_FLAG
    ,      p_line_rec.PRE_EXPLODED_FLAG
--  O2C/DOO Integration }

  );

    p_line_rec.lock_control := l_lock_control;
    p_line_rec.sold_from_org_id := l_sold_from_org;   /*Added for bug#12956482 */
    -- calling notification framework to update global picture
 -- check code release level first. Notification framework is at Pack H level
  IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110508' THEN
      OE_ORDER_UTIL.Update_Global_Picture(p_Upd_New_Rec_If_Exists => True,
                    p_Line_rec =>p_line_rec,
                    p_old_line_rec => NULL,
                    p_line_id => p_line_rec.line_id,
                    x_index => l_index,
                    x_return_status => l_return_status);
      if l_debug_level > 0 then
       OE_DEBUG_PUB.ADD('Update_Global Return Status from OE_LINE_UTIL.inset_row is: ' || l_return_status);
       OE_DEBUG_PUB.ADD('returned index is: ' || l_index ,1);
      end if;
       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         if l_debug_level > 0 then
          OE_DEBUG_PUB.ADD('EVENT NOTIFY - Unexpected Error');
          OE_DEBUG_PUB.ADD('Exiting OE_LINE_UTIL.insert_ROW', 1);
         end if;
	  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          if l_debug_level > 0 then
           OE_DEBUG_PUB.ADD('Update_Global_Picture Error in OE_LINE_UTIL.insert_row');
           OE_DEBUG_PUB.ADD('Exiting OE_LINE_UTIL.insert_ROW', 1);
          end if;
	  RAISE FND_API.G_EXC_ERROR;
        END IF;
    END IF; /*code_release_code*/
 -- notification framework end

  if l_debug_level > 0 then
    oe_debug_pub.add('Exiting OE_LINE_UTIL.INSERT_ROW', 1);
  end if;

EXCEPTION

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Insert_Row'
            );
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Insert_Row;


/*-----------------------------------------------------------
Procedure Delete_Row
-----------------------------------------------------------*/

PROCEDURE Delete_Row
( p_line_id       IN  NUMBER := FND_API.G_MISS_NUM
 ,p_header_id     IN  NUMBER := FND_API.G_MISS_NUM)
IS
  l_return_status            VARCHAR2(30);
  l_org_id                   NUMBER;
  l_line_rec                 oe_order_pub.line_rec_type;
  lsqlstmt                   varchar2(4000) ;
  lvariable1                 varchar2(80);
  lvariable2                 number;
  TYPE llinecur IS REF       CURSOR;
  llinetbl                   llinecur;
  llinetbl_svc               llinecur; -- for bug 2408321
  l_tmp_line_id              NUMBER;   -- for bug 2408321
  l_line_id                  number;
  l_item_type_code           varchar2(30);
  l_line_category_code       varchar2(30);
  l_config_header_id         number;
  l_config_rev_nbr           number;
  l_in_line_id               number := p_line_id;
  l_column                   varchar2(30);
  l_line_tbl                 OE_Order_PUB.Line_Tbl_Type;
  l_schedule_status_code     VARCHAR2(30);
  l_shipping_interfaced_flag VARCHAR2(1);
  l_ordered_quantity         NUMBER;           -- BUG 2670775 Reverse Limits
  l_price_request_code       varchar2(240);    -- BUG 2670775 Reverse Limits
  l_transaction_phase_code   varchar2(30);
  l_header_id                NUMBER;
  l_data                     VARCHAR2(1);
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

  -- BUG 2670775 - Add ordered_quantity,price_request_code to select list
  CURSOR order_line IS
  SELECT line_id, item_type_code,
         config_header_id, config_rev_nbr,
         line_category_code, schedule_status_code,
         shipping_interfaced_flag,
         ordered_quantity, price_request_code
         ,transaction_phase_code
  FROM   OE_ORDER_LINES
  WHERE  HEADER_ID = p_header_id;
  /*AND  NVL(ORG_ID,NVL(l_org_id,0))= NVL(l_org_id,0);*/

-- added for notification framework
  l_new_line_rec     OE_Order_PUB.Line_Rec_Type;
  l_index    NUMBER;
CURSOR svc_line IS
	SELECT line_id, item_type_code
     	FROM OE_ORDER_LINES
	  WHERE   service_reference_line_id  = p_line_id
	  AND     service_reference_type_code = 'ORDER';   --bug 3056313

BEGIN

  oe_debug_pub.add('Entering OE_LINE_UTIL.DELETE_ROW', 1);
  --Commented for MOAC start
  /*l_org_id := OE_GLOBALS.G_ORG_ID;

  IF l_org_id IS NULL THEN
    OE_GLOBALS.Set_Context;
    l_org_id := OE_GLOBALS.G_ORG_ID;
  END IF;

  oe_debug_pub.add('Entering delete '||to_char(l_org_id), 1); */
  --Commented for MOAC end
  IF p_header_id <> FND_API.G_MISS_NUM THEN
    FOR l_line IN order_line
    LOOP

       --added for notification framework
   --check code release level first. Notification framework is at Pack H level
    IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110508' THEN
       oe_debug_pub.add('JFC: in delete row, l_line_id'|| l_line.line_id , 1);
      /* Set the operation on the record so that globals are updated as well */
      l_new_line_rec.operation := OE_GLOBALS.G_OPR_DELETE;
      l_new_line_rec.line_id :=l_line.line_id;
      OE_ORDER_UTIL.Update_Global_Picture(p_Upd_New_Rec_If_Exists => True,
                    p_line_rec =>l_new_line_rec,
                    p_line_id =>l_line.line_id,
                    x_index => l_index,
                    x_return_status => l_return_status);
        OE_DEBUG_PUB.ADD('Update_Global Return Status from OE_LINE_UTIL.delete_row  is: ' || l_return_status);
       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          OE_DEBUG_PUB.ADD('EVENT NOTIFY - Unexpected Error');
          OE_DEBUG_PUB.ADD('Exiting OE_LINE_UTIL.DELETE_ROW', 1);
	  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          OE_DEBUG_PUB.ADD('Update_Global_Picture Error in OE_LINE_UTIL.Delete_row');
          OE_DEBUG_PUB.ADD('Exiting OE_LINE_UTIL.DELETE_ROW', 1);
	  RAISE FND_API.G_EXC_ERROR;
       END IF;
    END IF; /*code_release_level*/
    -- notification framework end

      -- Keep all your dependencies in Delete Dependents Procedure
      -- If model is deleted, delete from SPC tables
      IF l_line.item_type_code = OE_GLOBALS.G_ITEM_MODEL THEN
        OE_Config_Pvt.Delete_Config
        ( p_config_hdr_id     => l_line.config_header_id,
          p_config_rev_nbr    => l_line.config_rev_nbr,
          x_return_status     => l_return_status );
      END IF;

      l_line_id                  := l_line.line_id;
      l_item_type_code           := l_line.item_type_code;
      l_line_category_code       := l_line.line_category_code;
      l_config_header_id         := l_line.config_header_id;
      l_config_rev_nbr           := l_line.config_rev_nbr;
      l_schedule_status_code     := l_line.schedule_status_code;
      l_shipping_interfaced_flag := l_line.shipping_interfaced_flag;
      l_ordered_quantity         := l_line.ordered_quantity;   -- BUG 2670775 Reverse Limits
      l_price_request_code       := l_line.price_request_code; -- BUG 2670775 Reverse Limits
      l_transaction_phase_code   := l_line.transaction_phase_code;

      oe_debug_pub.add(' Header - Before delete dependent');

      Delete_Dependents
      ( p_line_id                  => l_line_id
       ,p_item_type_code           => l_item_type_code
       ,p_line_category_code       => l_line_category_code
       ,p_config_header_id         => l_config_header_id
       ,p_config_rev_nbr           => l_config_rev_nbr
       ,p_schedule_status_code     => l_schedule_status_code
       ,p_shipping_interfaced_flag => l_shipping_interfaced_flag
       ,p_ordered_quantity         => l_ordered_quantity          -- BUG 2670775 Reverse Limits
       ,p_price_request_code       => l_price_request_code      -- BUG 2670775 Reverse Limits
       ,p_transaction_phase_code   => l_transaction_phase_code -- Bug 3315331
       );

    END LOOP; -- all the lines in a header.

    /* Start Audit Trail */
    DELETE  FROM OE_ORDER_LINES_HISTORY
    WHERE   HEADER_ID = p_header_id;
    /* End Audit Trail */

    DELETE  FROM OE_ORDER_LINES
    WHERE   HEADER_ID = p_header_id;
   /* AND NVL(ORG_ID,NVL(l_org_id,0))= NVL(l_org_id,0);*/

  ELSE -- header_id is missing.
    oe_debug_pub.add('hdr missing delete_row,line_id: '||p_line_id, 1);

    oe_line_util.query_row
    (p_line_id   => p_line_id
    ,x_line_rec  => l_line_rec );

    lvariable2 := p_line_id;

    IF l_line_rec.ITEM_TYPE_CODE = 'MODEL' OR
       (l_line_rec.ITEM_TYPE_CODE = 'KIT' AND
        l_line_rec.top_model_line_id = l_line_rec.line_id) THEN
      oe_debug_pub.add('Entering - MODEL', 1);

      -- BUG 2670775 Reverse Limits - add ordered_quantity,price_request_code to select
      lsqlstmt := 'Select line_id, item_type_code, line_category_code,
                   config_header_id, config_rev_nbr,
                   schedule_status_code, shipping_interfaced_flag,
                   ordered_quantity, price_request_code
                   from oe_order_lines
                   where top_model_line_id = :x and
                         line_id <> :y';


      OPEN llinetbl
      FOR lsqlstmt
      USING
      p_line_id,
      l_in_line_id;

      lvariable1 := 'TOP_MODEL';
      oe_debug_pub.add('end of loop for OPEN MODEL', 1);

    END IF; -- if top level model.


    IF llinetbl%ISOPEN THEN
      LOOP
        oe_debug_pub.add('Entering model LOOP', 1);

        FETCH llinetbl INTO l_line_id,l_item_type_code,
            l_line_category_code,l_config_header_id,
            l_config_rev_nbr,l_schedule_status_code,
            l_shipping_interfaced_flag,
            l_ordered_quantity, l_price_request_code;  -- BUG 2670775 Reverse Limits

        EXIT WHEN llinetbl%NOTFOUND;

        oe_debug_pub.add('After Fetch -IN  LOOP', 1);
        -- Keep all your dependencies in Delete Dependents Procedure

        oe_debug_pub.add(' model - Before delete dependent' || l_line_id);

        Delete_Dependents
        ( p_line_id                  => l_line_id
         ,p_item_type_code           => l_item_type_code
         ,p_line_category_code       => l_line_category_code
         ,p_config_header_id         => l_config_header_id
         ,p_config_rev_nbr           => l_config_rev_nbr
         ,p_schedule_status_code     => l_schedule_status_code
         ,p_shipping_interfaced_flag => l_shipping_interfaced_flag
         ,p_ordered_quantity         => l_ordered_quantity     -- BUG 2670775 Reverse Limits
         ,p_price_request_code       => l_price_request_code); -- BUG 2670775 Reverse Limits

	-- start bug  2408321
	l_tmp_line_id := l_line_id;

        -- BUG 2670775 Reverse Limits - add ordered_quantity,price_request_code to select
	lsqlstmt := 'Select line_id, item_type_code, line_category_code,
	  config_header_id, config_rev_nbr,
	  schedule_status_code, shipping_interfaced_flag,
          ordered_quantity, price_request_code
	  from oe_order_lines
	  where service_reference_type_code = ' || '''' || 'ORDER' || ''' ' ||
	  'AND service_reference_line_id = :x';  --bug 3056313

	  OPEN llinetbl_svc
	  FOR lsqlstmt
	  using l_line_id;

	IF llinetbl_svc%ISOPEN THEN
	   LOOP
	      FETCH llinetbl_svc
		INTO l_line_id,l_item_type_code,l_line_category_code
		,l_config_header_id,l_config_rev_nbr
		,l_schedule_status_code,l_shipping_interfaced_flag
                ,l_ordered_quantity, l_price_request_code;  -- BUG 2670775 Reverse Limits

	      EXIT WHEN llinetbl_svc%NOTFOUND;

	      oe_debug_pub.add('Service - Before delete dependent' || l_line_id);

	      Delete_Dependents
		( p_line_id                  => l_line_id
		  ,p_item_type_code           => l_item_type_code
		  ,p_line_category_code       => l_line_category_code
		  ,p_config_header_id         => l_config_header_id
		  ,p_config_rev_nbr           => l_config_rev_nbr
		  ,p_schedule_status_code     => l_schedule_status_code
		  ,p_shipping_interfaced_flag => l_shipping_interfaced_flag
                  ,p_ordered_quantity         => l_ordered_quantity      -- BUG 2670775 Reverse Limits
                  ,p_price_request_code       => l_price_request_code ); -- BUG 2670775 Reverse Limits

	   END LOOP; -- loop of the service lines.

	   CLOSE llinetbl_svc;

	   DELETE  FROM OE_ORDER_LINES
	     WHERE   SERVICE_REFERENCE_LINE_ID = l_tmp_line_id
	     AND   SERVICE_REFERENCE_TYPE_CODE = 'ORDER';  -- bug 3056313

	END IF; -- if service lines exist, for bug 2408321

        OE_GLOBALS.G_CASCADING_REQUEST_LOGGED := TRUE;
      END LOOP; -- loop for models

      CLOSE llinetbl;

      IF lvariable1 = 'TOP_MODEL' THEN
        EXECUTE IMMEDIATE
        'Delete oe_order_lines where top_model_line_id = :x
         and line_id <> :y'
         USING
         p_line_id,
         p_line_id;
      END IF;

    END IF; -- end if model

   /* Remove the Parent Line and sub entities Here */
   /* Keep all your dependencies in Delete Dependents Procedure */

    oe_debug_pub.add('calling delete dep for the line', 1);
    Delete_Dependents
    ( p_line_id                  => l_line_rec.line_id
     ,p_item_type_code           => l_line_rec.item_type_code
     ,p_line_category_code       => l_line_rec.line_category_code
     ,p_config_header_id         => l_line_rec.config_header_id
     ,p_config_rev_nbr           => l_line_rec.config_rev_nbr
     ,p_schedule_status_code     => l_line_rec.schedule_status_code
     ,p_shipping_interfaced_flag => l_line_rec.shipping_interfaced_flag
     ,p_ordered_quantity         => l_line_rec.ordered_quantity     -- BUG 2670775 Reverse Limits
     ,p_price_request_code       => l_line_rec.price_request_code); -- BUG 2670775 Reverse Limits

    -- if model, call spc's delete
    IF p_header_id = FND_API.G_MISS_NUM THEN
      -- we already have l_line_rec

      IF l_line_rec.item_type_code = OE_GLOBALS.G_ITEM_MODEL THEN
        OE_Config_Pvt.Delete_Config
        ( p_config_hdr_id     => l_line_rec.config_header_id,
          p_config_rev_nbr    => l_line_rec.config_rev_nbr,
          x_return_status     => l_return_status );
      END IF;
    END IF;

    /* Delete all the dependents for service line */
    oe_debug_pub.add('Item Type for delete: ' || l_line_rec.item_type_code);

    /* When a standard line is being deleted, check if it has any service */
    /* lines attached to it. If so, get the line_id of the service line and */
    /* use this to delete the dependents */

    -- 02/NOV Reverse Limits add ordered_quantity, price_request_code to select
    lsqlstmt := 'Select line_id, item_type_code, line_category_code,
                 config_header_id, config_rev_nbr,
                 schedule_status_code, shipping_interfaced_flag,
                 ordered_quantity,price_request_code
                 from oe_order_lines
                 where service_reference_type_code = ' || '''' || 'ORDER' || ''' ' ||
                'and service_reference_line_id = :x';  -- bug 3056313

    OPEN llinetbl
    FOR lsqlstmt
    using p_line_id;

    IF llinetbl%ISOPEN THEN
      LOOP
        FETCH llinetbl
        INTO l_line_id,l_item_type_code,l_line_category_code
            ,l_config_header_id,l_config_rev_nbr
            ,l_schedule_status_code,l_shipping_interfaced_flag
            ,l_ordered_quantity    ,l_price_request_code      ; -- BUG 2670775 Reverse Limits

        EXIT WHEN llinetbl%NOTFOUND;

        oe_debug_pub.add('Service - Before delete dependent' || l_line_id);

        Delete_Dependents
        ( p_line_id                  => l_line_id
         ,p_item_type_code           => l_item_type_code
         ,p_line_category_code       => l_line_category_code
         ,p_config_header_id         => l_config_header_id
         ,p_config_rev_nbr           => l_config_rev_nbr
         ,p_schedule_status_code     => l_schedule_status_code
         ,p_shipping_interfaced_flag => l_shipping_interfaced_flag
         ,p_ordered_quantity         => l_ordered_quantity     -- BUG 2670775 Reverse Limits
         ,p_price_request_code       => l_price_request_code); -- BUG 2670775 Reverse Limits

        OE_GLOBALS.G_CASCADING_REQUEST_LOGGED := TRUE;
      END LOOP; -- loop of the service lines.

      CLOSE llinetbl;

    END IF; -- if service lines exist

    /* Start Audit Trail (modified for 11.5.10) */
    DELETE  FROM OE_ORDER_LINES_HISTORY
    WHERE   LINE_ID = p_line_id
    AND     NVL(AUDIT_FLAG, 'Y') = 'Y'
    AND     NVL(VERSION_FLAG, 'N') = 'N'
    AND     NVL(PHASE_CHANGE_FLAG, 'N') = 'N';

    UPDATE OE_ORDER_LINES_HISTORY
    SET    AUDIT_FLAG = 'N'
    WHERE  LINE_ID = p_line_id
    AND    NVL(AUDIT_FLAG, 'Y') = 'Y'
    AND   (NVL(VERSION_FLAG, 'N') = 'Y'
    OR     NVL(PHASE_CHANGE_FLAG, 'N') = 'Y');
    /* End Audit Trail */


  --added for notification framework to update global picture for standard line
   --check code release level first. Notification framework is at Pack H level
      oe_debug_pub.add('JPN: Delete all lines now');
    IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110508' THEN
      /* Set the operation on the record so that globals are updated as well */
     l_new_line_rec.operation := OE_GLOBALS.G_OPR_DELETE;
     l_new_line_rec.line_id :=l_line_rec.line_id;
     l_new_line_rec.last_update_date :=l_line_rec.last_update_date;

      OE_ORDER_UTIL.Update_Global_Picture(p_Upd_New_Rec_If_Exists => True,
                    p_line_rec =>l_new_line_rec,
                    p_line_id =>l_line_rec.line_id,
                    x_index => l_index,
                    x_return_status => l_return_status);
        OE_DEBUG_PUB.ADD('Update_Global Return Status from OE_LINE_UTIL.delete_row for deleting standard line is: ' || l_return_status);
        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          OE_DEBUG_PUB.ADD('EVENT NOTIFY - Unexpected Error');
          OE_DEBUG_PUB.ADD('Exiting OE_LINE_UTIL.DELETE_ROW', 1);
	  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          OE_DEBUG_PUB.ADD('Update_Global_Picture Error in OE_LINE_UTIL.Delete_row');
          OE_DEBUG_PUB.ADD('Exiting OE_LINE_UTIL.DELETE_ROW', 1);
	  RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF; /*code_release_level*/
    -- notification framework end


    DELETE  FROM OE_ORDER_LINES
    WHERE   LINE_ID = p_line_id;
    /* AND   NVL(ORG_ID,NVL(l_org_id,0))= NVL(l_org_id,0);*/


 --added for notification framework to update global picture for service line
  --check code release level first. Notification framework is at Pack H level
    IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110508' THEN
      FOR l_svc IN svc_line
       LOOP
         oe_debug_pub.add('JFC: in delete row, service line_id= '|| l_svc.line_id , 1);
      /* Set the operation on the record so that globals are updated as well */
          l_new_line_rec.operation := OE_GLOBALS.G_OPR_DELETE;
          l_new_line_rec.line_id :=l_svc.line_id;
          OE_ORDER_UTIL.Update_Global_Picture(p_Upd_New_Rec_If_Exists => True,
                    p_line_rec =>l_new_line_rec,
                    p_line_id =>l_svc.line_id,
                    x_index => l_index,
                    x_return_status => l_return_status);

          OE_DEBUG_PUB.ADD('Update_Global Return Status from OE_LINE_UTIL.delete_row for deleting service line is: ' || l_return_status);
          IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
             OE_DEBUG_PUB.ADD('EVENT NOTIFY - Unexpected Error');
             OE_DEBUG_PUB.ADD('Exiting OE_LINE_UTIL.DELETE_ROW', 1);
	     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
             OE_DEBUG_PUB.ADD('Update_Global_Picture Error in OE_LINE_UTIL.Delete_row');
             OE_DEBUG_PUB.ADD('Exiting OE_LINE_UTIL.DELETE_ROW', 1);
	     RAISE FND_API.G_EXC_ERROR;
         END IF;
       END LOOP;
     END IF; /*code_release_level*/
     -- notification framework end

    -- For the Multiple service for Standard Line
    DELETE  FROM OE_ORDER_LINES
      WHERE   SERVICE_REFERENCE_LINE_ID = p_line_id
      AND   SERVICE_REFERENCE_TYPE_CODE = 'ORDER';  -- bug 3056313
    /* AND NVL(ORG_ID,NVL(l_org_id,0))= NVL(l_org_id,0);*/

  END IF;


  IF (NVL(FND_PROFILE.VALUE('WSH_ENABLE_DCP'), -1)  = 1 OR
      NVL(FND_PROFILE.VALUE('WSH_ENABLE_DCP'), -1)  = 2) AND
      WSH_DCP_PVT.G_CALL_DCP_CHECK = 'Y' THEN

    WSH_DCP_PVT.G_INIT_MSG_COUNT := fnd_msg_pub.count_msg;

    BEGIN
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add(p_header_id ||'-----' || l_line_rec.header_id, 1);
      END IF;

      WSH_DCP_PVT.g_dc_table.DELETE;

      IF p_header_id is NULL OR
         p_header_id = FND_API.G_MISS_NUM THEN
        l_header_id :=  l_line_rec.header_id;
      ELSE
        l_header_id :=  p_header_id;
      END IF;

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('CALLING WSH_DCP_PVT.Check_Scripts '
                         ||'from delete row-'|| l_header_id, 1);
      END IF;

      WSH_DCP_PVT.Check_Scripts
      ( p_source_header_id  => l_header_id
       ,x_data_inconsistent => l_data);

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add
        ('CALLING WSH_DCP_PVT.Post_Process '|| l_data, 1);
       END IF;

      WSH_DCP_PVT.Post_Process
      ( p_action_code     => 'OM'
       ,p_raise_exception => 'Y');

    EXCEPTION
      WHEN WSH_DCP_PVT.dcp_caught THEN
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('OM call to WSH DCP Caught in delete', 1);
        END IF;

        WHEN others THEN
          IF l_debug_level  > 0 THEN
            oe_msg_pub.add_text
            ('Update_Shipping_From_OE, DCP post process'|| sqlerrm);
              oe_debug_pub.add('OM call to WSH DCP,others '|| sqlerrm, 1);
          END IF;
    END;
  END IF; -- profile is yes

  oe_debug_pub.add('Exiting OE_LINE_UTIL.DELETE_ROW', 1);

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    RAISE FND_API.G_EXC_ERROR ;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

  WHEN OTHERS THEN
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      OE_MSG_PUB.Add_Exc_Msg
      (   G_PKG_NAME
         ,'Delete_Row');
    END IF;

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Delete_Row;


/*----------------------------------------------------------
-- FUNCTION Query_Row
-- IMPORTANT: DO NOT CHANGE THE SPEC OF THIS FUNCTION
-- IT IS PUBLIC AND BEING CALLED BY OTHER PRODUCTS
-- Private OM callers should call the procedure query_row instead
-- as it has the nocopy option which would improve the performance
-----------------------------------------------------------*/

FUNCTION Query_Row
(   p_line_id                       IN  NUMBER
) RETURN OE_Order_PUB.Line_Rec_Type
IS
l_line_rec               OE_Order_PUB.Line_Rec_Type;
BEGIN

    Query_Row
        (   p_line_id                     => p_line_id
	    ,   x_line_rec                    => l_line_rec
        );

    RETURN l_line_rec;

END Query_Row;


/*----------------------------------------------------------
 Procedure Query_Row
-----------------------------------------------------------*/

PROCEDURE Query_Row
(   p_line_id                       IN  NUMBER
,   x_line_rec                      IN OUT NOCOPY OE_Order_PUB.Line_Rec_Type
)
IS

CURSOR l_line_csr IS
    SELECT  ACCOUNTING_RULE_ID
  , ACCOUNTING_RULE_DURATION
  , ACTUAL_ARRIVAL_DATE
  , ACTUAL_SHIPMENT_DATE
  , AGREEMENT_ID
  , ARRIVAL_SET_ID
  , ATO_LINE_ID
  , ATTRIBUTE1
  , ATTRIBUTE10
  , ATTRIBUTE11
  , ATTRIBUTE12
  , ATTRIBUTE13
  , ATTRIBUTE14
  , ATTRIBUTE15
  , ATTRIBUTE16   --For bug 2184255
  , ATTRIBUTE17
  , ATTRIBUTE18
  , ATTRIBUTE19
  , ATTRIBUTE2
  , ATTRIBUTE20
  , ATTRIBUTE3
  , ATTRIBUTE4
  , ATTRIBUTE5
  , ATTRIBUTE6
  , ATTRIBUTE7
  , ATTRIBUTE8
  , ATTRIBUTE9
  , AUTO_SELECTED_QUANTITY
  , AUTHORIZED_TO_SHIP_FLAG
  , BOOKED_FLAG
  , CANCELLED_FLAG
  , CANCELLED_QUANTITY
  , COMPONENT_CODE
  , COMPONENT_NUMBER
  , COMPONENT_SEQUENCE_ID
  , CONFIG_HEADER_ID
  , CONFIG_REV_NBR
  , CONFIG_DISPLAY_SEQUENCE
  , CONFIGURATION_ID
  , CONTEXT
  , CREATED_BY
  , CREATION_DATE
  , CREDIT_INVOICE_LINE_ID
  , CUSTOMER_DOCK_CODE
  , CUSTOMER_JOB
  , CUSTOMER_PRODUCTION_LINE
  , CUST_PRODUCTION_SEQ_NUM
  , CUSTOMER_TRX_LINE_ID
  , CUST_MODEL_SERIAL_NUMBER
  , CUST_PO_NUMBER
  , CUSTOMER_LINE_NUMBER
  , CUSTOMER_SHIPMENT_NUMBER
  , CUSTOMER_ITEM_NET_PRICE
  , DELIVERY_LEAD_TIME
  , DELIVER_TO_CONTACT_ID
  , DELIVER_TO_ORG_ID
  , DEMAND_BUCKET_TYPE_CODE
  , DEMAND_CLASS_CODE
  , DEP_PLAN_REQUIRED_FLAG
  , EARLIEST_ACCEPTABLE_DATE
  , END_ITEM_UNIT_NUMBER
  , EXPLOSION_DATE
  , FIRST_ACK_CODE
  , FIRST_ACK_DATE
  , FOB_POINT_CODE
  , FREIGHT_CARRIER_CODE
  , FREIGHT_TERMS_CODE
  , FULFILLED_QUANTITY
  , FULFILLED_FLAG
  , FULFILLMENT_METHOD_CODE
  , FULFILLMENT_DATE
  , GLOBAL_ATTRIBUTE1
  , GLOBAL_ATTRIBUTE10
  , GLOBAL_ATTRIBUTE11
  , GLOBAL_ATTRIBUTE12
  , GLOBAL_ATTRIBUTE13
  , GLOBAL_ATTRIBUTE14
  , GLOBAL_ATTRIBUTE15
  , GLOBAL_ATTRIBUTE16
  , GLOBAL_ATTRIBUTE17
  , GLOBAL_ATTRIBUTE18
  , GLOBAL_ATTRIBUTE19
  , GLOBAL_ATTRIBUTE2
  , GLOBAL_ATTRIBUTE20
  , GLOBAL_ATTRIBUTE3
  , GLOBAL_ATTRIBUTE4
  , GLOBAL_ATTRIBUTE5
  , GLOBAL_ATTRIBUTE6
  , GLOBAL_ATTRIBUTE7
  , GLOBAL_ATTRIBUTE8
  , GLOBAL_ATTRIBUTE9
  , GLOBAL_ATTRIBUTE_CATEGORY
  , HEADER_ID
  , INDUSTRY_ATTRIBUTE1
  , INDUSTRY_ATTRIBUTE10
  , INDUSTRY_ATTRIBUTE11
  , INDUSTRY_ATTRIBUTE12
  , INDUSTRY_ATTRIBUTE13
  , INDUSTRY_ATTRIBUTE14
  , INDUSTRY_ATTRIBUTE15
  , INDUSTRY_ATTRIBUTE16
  , INDUSTRY_ATTRIBUTE17
  , INDUSTRY_ATTRIBUTE18
  , INDUSTRY_ATTRIBUTE19
  , INDUSTRY_ATTRIBUTE20
  , INDUSTRY_ATTRIBUTE21
  , INDUSTRY_ATTRIBUTE22
  , INDUSTRY_ATTRIBUTE23
  , INDUSTRY_ATTRIBUTE24
  , INDUSTRY_ATTRIBUTE25
  , INDUSTRY_ATTRIBUTE26
  , INDUSTRY_ATTRIBUTE27
  , INDUSTRY_ATTRIBUTE28
  , INDUSTRY_ATTRIBUTE29
  , INDUSTRY_ATTRIBUTE30
  , INDUSTRY_ATTRIBUTE2
  , INDUSTRY_ATTRIBUTE3
  , INDUSTRY_ATTRIBUTE4
  , INDUSTRY_ATTRIBUTE5
  , INDUSTRY_ATTRIBUTE6
  , INDUSTRY_ATTRIBUTE7
  , INDUSTRY_ATTRIBUTE8
  , INDUSTRY_ATTRIBUTE9
  , INDUSTRY_CONTEXT
  , INTMED_SHIP_TO_CONTACT_ID
  , INTMED_SHIP_TO_ORG_ID
  , INVENTORY_ITEM_ID
  , INVOICE_INTERFACE_STATUS_CODE
  , INVOICE_TO_CONTACT_ID
  , INVOICE_TO_ORG_ID
  , INVOICED_QUANTITY
  , INVOICING_RULE_ID
  , ORDERED_ITEM_ID
  , ITEM_IDENTIFIER_TYPE
  , ORDERED_ITEM
  , ITEM_REVISION
  , ITEM_TYPE_CODE
  , LAST_ACK_CODE
  , LAST_ACK_DATE
  , LAST_UPDATED_BY
  , LAST_UPDATE_DATE
  , LAST_UPDATE_LOGIN
  , LATEST_ACCEPTABLE_DATE
  , LINE_CATEGORY_CODE
  , LINE_ID
  , LINE_NUMBER
  , LINE_TYPE_ID
  , LINK_TO_LINE_ID
  , MODEL_GROUP_NUMBER
  --  , MFG_COMPONENT_SEQUENCE_ID
  , MFG_LEAD_TIME
  , OPEN_FLAG
  , OPTION_FLAG
  , OPTION_NUMBER
  , ORDERED_QUANTITY
  , ORDERED_QUANTITY2              --OPM 02/JUN/00
  , ORDER_QUANTITY_UOM
  , ORDERED_QUANTITY_UOM2          --OPM 02/JUN/00
  , ORG_ID
  , ORIG_SYS_DOCUMENT_REF
  , ORIG_SYS_LINE_REF
  , ORIG_SYS_SHIPMENT_REF
  , OVER_SHIP_REASON_CODE
  , OVER_SHIP_RESOLVED_FLAG
  , PAYMENT_TERM_ID
  , PLANNING_PRIORITY
  , PREFERRED_GRADE                --OPM 02/JUN/00
  , PRICE_LIST_ID
  , PRICE_REQUEST_CODE             --PROMOTIONS MAY/01
  , PRICING_ATTRIBUTE1
  , PRICING_ATTRIBUTE10
  , PRICING_ATTRIBUTE2
  , PRICING_ATTRIBUTE3
  , PRICING_ATTRIBUTE4
  , PRICING_ATTRIBUTE5
  , PRICING_ATTRIBUTE6
  , PRICING_ATTRIBUTE7
  , PRICING_ATTRIBUTE8
  , PRICING_ATTRIBUTE9
  , PRICING_CONTEXT
  , PRICING_DATE
  , PRICING_QUANTITY
  , PRICING_QUANTITY_UOM
  , PROGRAM_APPLICATION_ID
  , PROGRAM_ID
  , PROGRAM_UPDATE_DATE
  , PROJECT_ID
  , PROMISE_DATE
  , RE_SOURCE_FLAG
  , REFERENCE_CUSTOMER_TRX_LINE_ID
  , REFERENCE_HEADER_ID
  , REFERENCE_LINE_ID
  , REFERENCE_TYPE
  , REQUEST_DATE
  , REQUEST_ID
  , RETURN_ATTRIBUTE1
  , RETURN_ATTRIBUTE10
  , RETURN_ATTRIBUTE11
  , RETURN_ATTRIBUTE12
  , RETURN_ATTRIBUTE13
  , RETURN_ATTRIBUTE14
  , RETURN_ATTRIBUTE15
  , RETURN_ATTRIBUTE2
  , RETURN_ATTRIBUTE3
  , RETURN_ATTRIBUTE4
  , RETURN_ATTRIBUTE5
  , RETURN_ATTRIBUTE6
  , RETURN_ATTRIBUTE7
  , RETURN_ATTRIBUTE8
  , RETURN_ATTRIBUTE9
  , RETURN_CONTEXT
  , RETURN_REASON_CODE
  , RLA_SCHEDULE_TYPE_CODE
  , SALESREP_ID
  , SCHEDULE_ARRIVAL_DATE
  , SCHEDULE_SHIP_DATE
  , SCHEDULE_STATUS_CODE
  , SHIPMENT_NUMBER
  , SHIPMENT_PRIORITY_CODE
  , SHIPPED_QUANTITY
  , SHIPPED_QUANTITY2 -- OPM B1661023 04/02/01
  , SHIPPING_METHOD_CODE
  , SHIPPING_QUANTITY
  , SHIPPING_QUANTITY2 -- OPM B1661023 04/02/01
  , SHIPPING_QUANTITY_UOM
  , SHIPPING_QUANTITY_UOM2 -- INVCONV
  , SHIP_FROM_ORG_ID
  , SUBINVENTORY
  , SHIP_SET_ID
  , SHIP_TOLERANCE_ABOVE
  , SHIP_TOLERANCE_BELOW
  , SHIPPABLE_FLAG
  , SHIPPING_INTERFACED_FLAG
  , SHIP_TO_CONTACT_ID
  , SHIP_TO_ORG_ID
  , SHIP_MODEL_COMPLETE_FLAG
  , SOLD_TO_ORG_ID
  , SOLD_FROM_ORG_ID
  , SORT_ORDER
  , SOURCE_DOCUMENT_ID
  , SOURCE_DOCUMENT_LINE_ID
  , SOURCE_DOCUMENT_TYPE_ID
  , SOURCE_TYPE_CODE
  , SPLIT_FROM_LINE_ID
  , LINE_SET_ID
  , SPLIT_BY
  , MODEL_REMNANT_FLAG
  , TASK_ID
  , TAX_CODE
  , TAX_DATE
  , TAX_EXEMPT_FLAG
  , TAX_EXEMPT_NUMBER
  , TAX_EXEMPT_REASON_CODE
  , TAX_POINT_CODE
  , TAX_RATE
  , TAX_VALUE
  , TOP_MODEL_LINE_ID
  , UNIT_LIST_PRICE
  , UNIT_LIST_PRICE_PER_PQTY
  , UNIT_SELLING_PRICE
  , UNIT_SELLING_PRICE_PER_PQTY
  , VISIBLE_DEMAND_FLAG
  , VEH_CUS_ITEM_CUM_KEY_ID
  , SHIPPING_INSTRUCTIONS
  , PACKING_INSTRUCTIONS
  , SERVICE_TXN_REASON_CODE
  , SERVICE_TXN_COMMENTS
  , SERVICE_DURATION
  , SERVICE_PERIOD
  , SERVICE_START_DATE
  , SERVICE_END_DATE
  , SERVICE_COTERMINATE_FLAG
  , UNIT_LIST_PERCENT
  , UNIT_SELLING_PERCENT
  , UNIT_PERCENT_BASE_PRICE
  , SERVICE_NUMBER
  , SERVICE_REFERENCE_TYPE_CODE
  , SERVICE_REFERENCE_LINE_ID
  , SERVICE_REFERENCE_SYSTEM_ID
  , TP_CONTEXT
  , TP_ATTRIBUTE1
  , TP_ATTRIBUTE2
  , TP_ATTRIBUTE3
  , TP_ATTRIBUTE4
  , TP_ATTRIBUTE5
  , TP_ATTRIBUTE6
  , TP_ATTRIBUTE7
  , TP_ATTRIBUTE8
  , TP_ATTRIBUTE9
  , TP_ATTRIBUTE10
  , TP_ATTRIBUTE11
  , TP_ATTRIBUTE12
  , TP_ATTRIBUTE13
  , TP_ATTRIBUTE14
  , TP_ATTRIBUTE15
  , FLOW_STATUS_CODE
  , MARKETING_SOURCE_CODE_ID
  , CALCULATE_PRICE_FLAG
  , COMMITMENT_ID
  , ORDER_SOURCE_ID        -- aksingh
  , UPGRADED_FLAG
  , ORIGINAL_INVENTORY_ITEM_ID
  , ORIGINAL_ITEM_IDENTIFIER_TYPE
  , ORIGINAL_ORDERED_ITEM_ID
  , ORIGINAL_ORDERED_ITEM
  , ITEM_RELATIONSHIP_TYPE
  , ITEM_SUBSTITUTION_TYPE_CODE
  , LATE_DEMAND_PENALTY_FACTOR
  , OVERRIDE_ATP_DATE_CODE
  , FIRM_DEMAND_FLAG
  , EARLIEST_SHIP_DATE
  , USER_ITEM_DESCRIPTION
  , BLANKET_NUMBER
  , BLANKET_LINE_NUMBER
  , BLANKET_VERSION_NUMBER
  , UNIT_COST
  , LOCK_CONTROL
  , CHANGE_SEQUENCE
  , transaction_phase_code
  , source_document_version_number
  , MINISITE_ID
  , Ib_Owner
  , Ib_installed_at_location
  , Ib_current_location
  , End_customer_ID
  , End_customer_contact_ID
  , End_customer_site_use_ID
  , RETROBILL_REQUEST_ID
  , ORIGINAL_LIST_PRICE  -- Override List Price
  , order_firmed_date
  , actual_fulfillment_date
  , charge_periodicity_code
  , cancelled_quantity2
  , fulfilled_quantity2
  , CONTINGENCY_ID
  , REVREC_EVENT_CODE
  , REVREC_EXPIRATION_DAYS
  , ACCEPTED_QUANTITY
  , REVREC_COMMENTS
  , REVREC_SIGNATURE
  , REVREC_SIGNATURE_DATE
  , ACCEPTED_BY
  , REVREC_REFERENCE_DOCUMENT
  , REVREC_IMPLICIT_FLAG
  , BYPASS_SCH_FLAG
  , PRE_EXPLODED_FLAG
   FROM    OE_ORDER_LINES_ALL  -- Fix for FP bug 3391622
    WHERE LINE_ID = p_line_id;

    l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

BEGIN

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('Entering OE_LINE_UTIL.QUERY_ROW, line_id:'||p_line_id, 1);
    END IF;


    OPEN l_line_csr;

    --  Loop over fetched records

    FETCH l_line_csr INTO
    x_line_rec.ACCOUNTING_RULE_ID
  , x_line_rec.ACCOUNTING_RULE_DURATION
  , x_line_rec.ACTUAL_ARRIVAL_DATE
  , x_line_rec.ACTUAL_SHIPMENT_DATE
  , x_line_rec.AGREEMENT_ID
  , x_line_rec.ARRIVAL_SET_ID
  , x_line_rec.ATO_LINE_ID
  , x_line_rec.ATTRIBUTE1
  , x_line_rec.ATTRIBUTE10
  , x_line_rec.ATTRIBUTE11
  , x_line_rec.ATTRIBUTE12
  , x_line_rec.ATTRIBUTE13
  , x_line_rec.ATTRIBUTE14
  , x_line_rec.ATTRIBUTE15
  , x_line_rec.ATTRIBUTE16   --For bug 2184255
  , x_line_rec.ATTRIBUTE17
  , x_line_rec.ATTRIBUTE18
  , x_line_rec.ATTRIBUTE19
  , x_line_rec.ATTRIBUTE2
  , x_line_rec.ATTRIBUTE20
  , x_line_rec.ATTRIBUTE3
  , x_line_rec.ATTRIBUTE4
  , x_line_rec.ATTRIBUTE5
  , x_line_rec.ATTRIBUTE6
  , x_line_rec.ATTRIBUTE7
  , x_line_rec.ATTRIBUTE8
  , x_line_rec.ATTRIBUTE9
  , x_line_rec.AUTO_SELECTED_QUANTITY
  , x_line_rec.AUTHORIZED_TO_SHIP_FLAG
  , x_line_rec.BOOKED_FLAG
  , x_line_rec.CANCELLED_FLAG
  , x_line_rec.CANCELLED_QUANTITY
  , x_line_rec.COMPONENT_CODE
  , x_line_rec.COMPONENT_NUMBER
  , x_line_rec.COMPONENT_SEQUENCE_ID
  , x_line_rec.CONFIG_HEADER_ID
  , x_line_rec.CONFIG_REV_NBR
  , x_line_rec.CONFIG_DISPLAY_SEQUENCE
  , x_line_rec.CONFIGURATION_ID
  , x_line_rec.CONTEXT
  , x_line_rec.CREATED_BY
  , x_line_rec.CREATION_DATE
  , x_line_rec.CREDIT_INVOICE_LINE_ID
  , x_line_rec.CUSTOMER_DOCK_CODE
  , x_line_rec.CUSTOMER_JOB
  , x_line_rec.CUSTOMER_PRODUCTION_LINE
  , x_line_rec.CUST_PRODUCTION_SEQ_NUM
  , x_line_rec.CUSTOMER_TRX_LINE_ID
  , x_line_rec.CUST_MODEL_SERIAL_NUMBER
  , x_line_rec.CUST_PO_NUMBER
  , x_line_rec.CUSTOMER_LINE_NUMBER
  , x_line_rec.CUSTOMER_SHIPMENT_NUMBER
  , x_line_rec.CUSTOMER_ITEM_NET_PRICE
  , x_line_rec.DELIVERY_LEAD_TIME
  , x_line_rec.DELIVER_TO_CONTACT_ID
  , x_line_rec.DELIVER_TO_ORG_ID
  , x_line_rec.DEMAND_BUCKET_TYPE_CODE
  , x_line_rec.DEMAND_CLASS_CODE
  , x_line_rec.DEP_PLAN_REQUIRED_FLAG
  , x_line_rec.EARLIEST_ACCEPTABLE_DATE
  , x_line_rec.END_ITEM_UNIT_NUMBER
  , x_line_rec.EXPLOSION_DATE
  , x_line_rec.FIRST_ACK_CODE
  , x_line_rec.FIRST_ACK_DATE
  , x_line_rec.FOB_POINT_CODE
  , x_line_rec.FREIGHT_CARRIER_CODE
  , x_line_rec.FREIGHT_TERMS_CODE
  , x_line_rec.FULFILLED_QUANTITY
  , x_line_rec.FULFILLED_FLAG
  , x_line_rec.FULFILLMENT_METHOD_CODE
  , x_line_rec.FULFILLMENT_DATE
  , x_line_rec.GLOBAL_ATTRIBUTE1
  , x_line_rec.GLOBAL_ATTRIBUTE10
  , x_line_rec.GLOBAL_ATTRIBUTE11
  , x_line_rec.GLOBAL_ATTRIBUTE12
  , x_line_rec.GLOBAL_ATTRIBUTE13
  , x_line_rec.GLOBAL_ATTRIBUTE14
  , x_line_rec.GLOBAL_ATTRIBUTE15
  , x_line_rec.GLOBAL_ATTRIBUTE16
  , x_line_rec.GLOBAL_ATTRIBUTE17
  , x_line_rec.GLOBAL_ATTRIBUTE18
  , x_line_rec.GLOBAL_ATTRIBUTE19
  , x_line_rec.GLOBAL_ATTRIBUTE2
  , x_line_rec.GLOBAL_ATTRIBUTE20
  , x_line_rec.GLOBAL_ATTRIBUTE3
  , x_line_rec.GLOBAL_ATTRIBUTE4
  , x_line_rec.GLOBAL_ATTRIBUTE5
  , x_line_rec.GLOBAL_ATTRIBUTE6
  , x_line_rec.GLOBAL_ATTRIBUTE7
  , x_line_rec.GLOBAL_ATTRIBUTE8
  , x_line_rec.GLOBAL_ATTRIBUTE9
  , x_line_rec.GLOBAL_ATTRIBUTE_CATEGORY
  , x_line_rec.HEADER_ID
  , x_line_rec.INDUSTRY_ATTRIBUTE1
  , x_line_rec.INDUSTRY_ATTRIBUTE10
  , x_line_rec.INDUSTRY_ATTRIBUTE11
  , x_line_rec.INDUSTRY_ATTRIBUTE12
  , x_line_rec.INDUSTRY_ATTRIBUTE13
  , x_line_rec.INDUSTRY_ATTRIBUTE14
  , x_line_rec.INDUSTRY_ATTRIBUTE15
  , x_line_rec.INDUSTRY_ATTRIBUTE16
  , x_line_rec.INDUSTRY_ATTRIBUTE17
  , x_line_rec.INDUSTRY_ATTRIBUTE18
  , x_line_rec.INDUSTRY_ATTRIBUTE19
  , x_line_rec.INDUSTRY_ATTRIBUTE20
  , x_line_rec.INDUSTRY_ATTRIBUTE21
  , x_line_rec.INDUSTRY_ATTRIBUTE22
  , x_line_rec.INDUSTRY_ATTRIBUTE23
  , x_line_rec.INDUSTRY_ATTRIBUTE24
  , x_line_rec.INDUSTRY_ATTRIBUTE25
  , x_line_rec.INDUSTRY_ATTRIBUTE26
  , x_line_rec.INDUSTRY_ATTRIBUTE27
  , x_line_rec.INDUSTRY_ATTRIBUTE28
  , x_line_rec.INDUSTRY_ATTRIBUTE29
  , x_line_rec.INDUSTRY_ATTRIBUTE30
  , x_line_rec.INDUSTRY_ATTRIBUTE2
  , x_line_rec.INDUSTRY_ATTRIBUTE3
  , x_line_rec.INDUSTRY_ATTRIBUTE4
  , x_line_rec.INDUSTRY_ATTRIBUTE5
  , x_line_rec.INDUSTRY_ATTRIBUTE6
  , x_line_rec.INDUSTRY_ATTRIBUTE7
  , x_line_rec.INDUSTRY_ATTRIBUTE8
  , x_line_rec.INDUSTRY_ATTRIBUTE9
  , x_line_rec.INDUSTRY_CONTEXT
  , x_line_rec.INTERMED_SHIP_TO_CONTACT_ID
  , x_line_rec.INTERMED_SHIP_TO_ORG_ID
  , x_line_rec.INVENTORY_ITEM_ID
  , x_line_rec.INVOICE_INTERFACE_STATUS_CODE
  , x_line_rec.INVOICE_TO_CONTACT_ID
  , x_line_rec.INVOICE_TO_ORG_ID
  , x_line_rec.INVOICED_QUANTITY
  , x_line_rec.INVOICING_RULE_ID
  , x_line_rec.ORDERED_ITEM_ID
  , x_line_rec.ITEM_IDENTIFIER_TYPE
  , x_line_rec.ORDERED_ITEM
  , x_line_rec.ITEM_REVISION
  , x_line_rec.ITEM_TYPE_CODE
  , x_line_rec.LAST_ACK_CODE
  , x_line_rec.LAST_ACK_DATE
  , x_line_rec.LAST_UPDATED_BY
  , x_line_rec.LAST_UPDATE_DATE
  , x_line_rec.LAST_UPDATE_LOGIN
  , x_line_rec.LATEST_ACCEPTABLE_DATE
  , x_line_rec.LINE_CATEGORY_CODE
  , x_line_rec.LINE_ID
  , x_line_rec.LINE_NUMBER
  , x_line_rec.LINE_TYPE_ID
  , x_line_rec.LINK_TO_LINE_ID
  , x_line_rec.MODEL_GROUP_NUMBER
  --  , x_line_rec.MFG_COMPONENT_SEQUENCE_ID
  , x_line_rec.MFG_LEAD_TIME
  , x_line_rec.OPEN_FLAG
  , x_line_rec.OPTION_FLAG
  , x_line_rec.OPTION_NUMBER
  , x_line_rec.ORDERED_QUANTITY
  , x_line_rec.ORDERED_QUANTITY2              --OPM 02/JUN/00
  , x_line_rec.ORDER_QUANTITY_UOM
  , x_line_rec.ORDERED_QUANTITY_UOM2          --OPM 02/JUN/00
  , x_line_rec.ORG_ID
  , x_line_rec.ORIG_SYS_DOCUMENT_REF
  , x_line_rec.ORIG_SYS_LINE_REF
  , x_line_rec.ORIG_SYS_SHIPMENT_REF
  , x_line_rec.OVER_SHIP_REASON_CODE
  , x_line_rec.OVER_SHIP_RESOLVED_FLAG
  , x_line_rec.PAYMENT_TERM_ID
  , x_line_rec.PLANNING_PRIORITY
  , x_line_rec.PREFERRED_GRADE                --OPM 02/JUN/00
  , x_line_rec.PRICE_LIST_ID
  , x_line_rec.PRICE_REQUEST_CODE             --PROMOTIONS MAY/01
  , x_line_rec.PRICING_ATTRIBUTE1
  , x_line_rec.PRICING_ATTRIBUTE10
  , x_line_rec.PRICING_ATTRIBUTE2
  , x_line_rec.PRICING_ATTRIBUTE3
  , x_line_rec.PRICING_ATTRIBUTE4
  , x_line_rec.PRICING_ATTRIBUTE5
  , x_line_rec.PRICING_ATTRIBUTE6
  , x_line_rec.PRICING_ATTRIBUTE7
  , x_line_rec.PRICING_ATTRIBUTE8
  , x_line_rec.PRICING_ATTRIBUTE9
  , x_line_rec.PRICING_CONTEXT
  , x_line_rec.PRICING_DATE
  , x_line_rec.PRICING_QUANTITY
  , x_line_rec.PRICING_QUANTITY_UOM
  , x_line_rec.PROGRAM_APPLICATION_ID
  , x_line_rec.PROGRAM_ID
  , x_line_rec.PROGRAM_UPDATE_DATE
  , x_line_rec.PROJECT_ID
  , x_line_rec.PROMISE_DATE
  , x_line_rec.RE_SOURCE_FLAG
  , x_line_rec.REFERENCE_CUSTOMER_TRX_LINE_ID
  , x_line_rec.REFERENCE_HEADER_ID
  , x_line_rec.REFERENCE_LINE_ID
  , x_line_rec.REFERENCE_TYPE
  , x_line_rec.REQUEST_DATE
  , x_line_rec.REQUEST_ID
  , x_line_rec.RETURN_ATTRIBUTE1
  , x_line_rec.RETURN_ATTRIBUTE10
  , x_line_rec.RETURN_ATTRIBUTE11
  , x_line_rec.RETURN_ATTRIBUTE12
  , x_line_rec.RETURN_ATTRIBUTE13
  , x_line_rec.RETURN_ATTRIBUTE14
  , x_line_rec.RETURN_ATTRIBUTE15
  , x_line_rec.RETURN_ATTRIBUTE2
  , x_line_rec.RETURN_ATTRIBUTE3
  , x_line_rec.RETURN_ATTRIBUTE4
  , x_line_rec.RETURN_ATTRIBUTE5
  , x_line_rec.RETURN_ATTRIBUTE6
  , x_line_rec.RETURN_ATTRIBUTE7
  , x_line_rec.RETURN_ATTRIBUTE8
  , x_line_rec.RETURN_ATTRIBUTE9
  , x_line_rec.RETURN_CONTEXT
  , x_line_rec.RETURN_REASON_CODE
  , x_line_rec.RLA_SCHEDULE_TYPE_CODE
  , x_line_rec.SALESREP_ID
  , x_line_rec.SCHEDULE_ARRIVAL_DATE
  , x_line_rec.SCHEDULE_SHIP_DATE
  , x_line_rec.SCHEDULE_STATUS_CODE
  , x_line_rec.SHIPMENT_NUMBER
  , x_line_rec.SHIPMENT_PRIORITY_CODE
  , x_line_rec.SHIPPED_QUANTITY
  , x_line_rec.SHIPPED_QUANTITY2 -- OPM B1661023 04/02/01
  , x_line_rec.SHIPPING_METHOD_CODE
  , x_line_rec.SHIPPING_QUANTITY
  , x_line_rec.SHIPPING_QUANTITY2 -- OPM B1661023 04/02/01
  , x_line_rec.SHIPPING_QUANTITY_UOM
  , x_line_rec.SHIPPING_QUANTITY_UOM2
  , x_line_rec.SHIP_FROM_ORG_ID
  , x_line_rec.SUBINVENTORY
  , x_line_rec.SHIP_SET_ID
  , x_line_rec.SHIP_TOLERANCE_ABOVE
  , x_line_rec.SHIP_TOLERANCE_BELOW
  , x_line_rec.SHIPPABLE_FLAG
  , x_line_rec.SHIPPING_INTERFACED_FLAG
  , x_line_rec.SHIP_TO_CONTACT_ID
  , x_line_rec.SHIP_TO_ORG_ID
  , x_line_rec.SHIP_MODEL_COMPLETE_FLAG
  , x_line_rec.SOLD_TO_ORG_ID
  , x_line_rec.SOLD_FROM_ORG_ID
  , x_line_rec.SORT_ORDER
  , x_line_rec.SOURCE_DOCUMENT_ID
  , x_line_rec.SOURCE_DOCUMENT_LINE_ID
  , x_line_rec.SOURCE_DOCUMENT_TYPE_ID
  , x_line_rec.SOURCE_TYPE_CODE
  , x_line_rec.SPLIT_FROM_LINE_ID
  , x_line_rec.LINE_SET_ID
  , x_line_rec.SPLIT_BY
  , x_line_rec.MODEL_REMNANT_FLAG
  , x_line_rec.TASK_ID
  , x_line_rec.TAX_CODE
  , x_line_rec.TAX_DATE
  , x_line_rec.TAX_EXEMPT_FLAG
  , x_line_rec.TAX_EXEMPT_NUMBER
  , x_line_rec.TAX_EXEMPT_REASON_CODE
  , x_line_rec.TAX_POINT_CODE
  , x_line_rec.TAX_RATE
  , x_line_rec.TAX_VALUE
  , x_line_rec.TOP_MODEL_LINE_ID
  , x_line_rec.UNIT_LIST_PRICE
  , x_line_rec.UNIT_LIST_PRICE_PER_PQTY
  , x_line_rec.UNIT_SELLING_PRICE
  , x_line_rec.UNIT_SELLING_PRICE_PER_PQTY
  , x_line_rec.VISIBLE_DEMAND_FLAG
  , x_line_rec.VEH_CUS_ITEM_CUM_KEY_ID
  , x_line_rec.SHIPPING_INSTRUCTIONS
  , x_line_rec.PACKING_INSTRUCTIONS
  , x_line_rec.SERVICE_TXN_REASON_CODE
  , x_line_rec.SERVICE_TXN_COMMENTS
  , x_line_rec.SERVICE_DURATION
  , x_line_rec.SERVICE_PERIOD
  , x_line_rec.SERVICE_START_DATE
  , x_line_rec.SERVICE_END_DATE
  , x_line_rec.SERVICE_COTERMINATE_FLAG
  , x_line_rec.UNIT_LIST_PERCENT
  , x_line_rec.UNIT_SELLING_PERCENT
  , x_line_rec.UNIT_PERCENT_BASE_PRICE
  , x_line_rec.SERVICE_NUMBER
  , x_line_rec.SERVICE_REFERENCE_TYPE_CODE
  , x_line_rec.SERVICE_REFERENCE_LINE_ID
  , x_line_rec.SERVICE_REFERENCE_SYSTEM_ID
  , x_line_rec.TP_CONTEXT
  , x_line_rec.TP_ATTRIBUTE1
  , x_line_rec.TP_ATTRIBUTE2
  , x_line_rec.TP_ATTRIBUTE3
  , x_line_rec.TP_ATTRIBUTE4
  , x_line_rec.TP_ATTRIBUTE5
  , x_line_rec.TP_ATTRIBUTE6
  , x_line_rec.TP_ATTRIBUTE7
  , x_line_rec.TP_ATTRIBUTE8
  , x_line_rec.TP_ATTRIBUTE9
  , x_line_rec.TP_ATTRIBUTE10
  , x_line_rec.TP_ATTRIBUTE11
  , x_line_rec.TP_ATTRIBUTE12
  , x_line_rec.TP_ATTRIBUTE13
  , x_line_rec.TP_ATTRIBUTE14
  , x_line_rec.TP_ATTRIBUTE15
  , x_line_rec.FLOW_STATUS_CODE
  , x_line_rec.MARKETING_SOURCE_CODE_ID
  , x_line_rec.CALCULATE_PRICE_FLAG
  , x_line_rec.COMMITMENT_ID
  , x_line_rec.ORDER_SOURCE_ID        -- aksingh
  , x_line_rec.UPGRADED_FLAG
  , x_line_rec.ORIGINAL_INVENTORY_ITEM_ID
  , x_line_rec.ORIGINAL_ITEM_IDENTIFIER_TYPE
  , x_line_rec.ORIGINAL_ORDERED_ITEM_ID
  , x_line_rec.ORIGINAL_ORDERED_ITEM
  , x_line_rec.ITEM_RELATIONSHIP_TYPE
  , x_line_rec.ITEM_SUBSTITUTION_TYPE_CODE
  , x_line_rec.LATE_DEMAND_PENALTY_FACTOR
  , x_line_rec.OVERRIDE_ATP_DATE_CODE
  , x_line_rec.FIRM_DEMAND_FLAG
  , x_line_rec.EARLIEST_SHIP_DATE
  , x_line_rec.USER_ITEM_DESCRIPTION
  , x_line_rec.BLANKET_NUMBER
  , x_line_rec.BLANKET_LINE_NUMBER
  , x_line_rec.BLANKET_VERSION_NUMBER
  , x_line_rec.UNIT_COST
  , x_line_rec.LOCK_CONTROL
  , x_line_rec.CHANGE_SEQUENCE
  , x_line_rec.transaction_phase_code
  , x_line_rec.source_document_version_number
  , x_line_rec.MINISITE_ID
   , x_line_rec.Ib_Owner
   , x_line_rec.Ib_installed_at_location
   , x_line_rec.Ib_current_location
   , x_line_rec.End_customer_ID
   , x_line_rec.End_customer_contact_ID
   , x_line_rec.End_customer_site_use_ID
   , x_line_rec.RETROBILL_REQUEST_ID
   , x_line_rec.ORIGINAL_LIST_PRICE  -- Override List Price
   , x_line_rec.order_firmed_date
   , x_line_rec.actual_fulfillment_date
   , x_line_rec.charge_periodicity_code
   , x_line_rec.cancelled_quantity2
   , x_line_rec.fulfilled_quantity2
   , x_line_rec.CONTINGENCY_ID
   , x_line_rec.REVREC_EVENT_CODE
   , x_line_rec.REVREC_EXPIRATION_DAYS
   , x_line_rec.ACCEPTED_QUANTITY
   , x_line_rec.REVREC_COMMENTS
   , x_line_rec.REVREC_SIGNATURE
   , x_line_rec.REVREC_SIGNATURE_DATE
   , x_line_rec.ACCEPTED_BY
   , x_line_rec.REVREC_REFERENCE_DOCUMENT
   , x_line_rec.REVREC_IMPLICIT_FLAG
   -- Added for DOO/O2C Integration purpose.
   , x_line_rec.BYPASS_SCH_FLAG
   , x_line_rec.PRE_EXPLODED_FLAG;

  --Added for bug5068941 start
  if l_line_csr%notfound then
     raise NO_DATA_FOUND;
  end if;
  --Added for bug5068941 end

If NOT OE_FEATURES_PVT.Is_Margin_Avail Then
   IF l_debug_level  > 0 THEN
     oe_debug_pub.add('inside margin ',1);
   END IF;
   x_line_rec.unit_cost:= NULL;
End If;

	   -- set values for non-DB fields
	x_line_rec.db_flag 		:= FND_API.G_TRUE;
	x_line_rec.operation 		:= FND_API.G_MISS_CHAR;
	x_line_rec.return_status 	:= FND_API.G_MISS_CHAR;

	x_line_rec.schedule_action_code 	:= FND_API.G_MISS_CHAR;
	x_line_rec.reserved_quantity 	:= FND_API.G_MISS_NUM;
	x_line_rec.reserved_quantity2 	:= FND_API.G_MISS_NUM; -- INVCONV
	x_line_rec.change_reason 		:= FND_API.G_MISS_CHAR;
	x_line_rec.change_comments 		:= FND_API.G_MISS_CHAR;
	x_line_rec.arrival_set      	:= FND_API.G_MISS_CHAR;
	x_line_rec.ship_set 			:= FND_API.G_MISS_CHAR;
	x_line_rec.fulfillment_set 		:= FND_API.G_MISS_CHAR;
	x_line_rec.split_action_code 	:= FND_API.G_MISS_CHAR;


    CLOSE l_line_csr;

   IF l_debug_level  > 0 THEN
      oe_debug_pub.add('Exiting OE_LINE_UTIL.QUERY_ROW', 1);
    END IF;


EXCEPTION

    WHEN NO_DATA_FOUND THEN

       RAISE NO_DATA_FOUND;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
          ,   'Query_Row'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Query_Row;


/*----------------------------------------------------------
 PROCEDURE Query_Rows

 When you add/delete columns to query_rows function,
 Please do the same changes in OE_Config_Util package body
 Query_Config function.
-----------------------------------------------------------*/

PROCEDURE Query_Rows
(   p_line_id                       IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_header_id                     IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_line_set_id                   IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   x_line_tbl                      IN OUT NOCOPY OE_Order_PUB.Line_Tbl_Type
 )
IS
l_org_id 		      	NUMBER;
i				NUMBER;
l_entity                        NUMBER;

-- OPM 02/JUN/00 - Include process columns
--                (ordered_quantity2,ordered_quantity_uom2,preferred_grade)
-- =======================================================================

-- Fix bug 2868226: The SQL has been modified to use 3 separate cursors,
-- allowing for a simpler explain plan and significantly reduced shared
-- memory usage.

CURSOR l_line_csr_h IS
    SELECT  ACCOUNTING_RULE_ID
  , ACCOUNTING_RULE_DURATION
  , ACTUAL_ARRIVAL_DATE
  , ACTUAL_SHIPMENT_DATE
  , AGREEMENT_ID
  , ARRIVAL_SET_ID
  , ATO_LINE_ID
  , ATTRIBUTE1
  , ATTRIBUTE10
  , ATTRIBUTE11
  , ATTRIBUTE12
  , ATTRIBUTE13
  , ATTRIBUTE14
  , ATTRIBUTE15
  , ATTRIBUTE16   --For bug 2184255
  , ATTRIBUTE17
  , ATTRIBUTE18
  , ATTRIBUTE19
  , ATTRIBUTE2
  , ATTRIBUTE20
  , ATTRIBUTE3
  , ATTRIBUTE4
  , ATTRIBUTE5
  , ATTRIBUTE6
  , ATTRIBUTE7
  , ATTRIBUTE8
  , ATTRIBUTE9
  , AUTO_SELECTED_QUANTITY
  , AUTHORIZED_TO_SHIP_FLAG
  , BOOKED_FLAG
  , CANCELLED_FLAG
  , CANCELLED_QUANTITY
  , COMPONENT_CODE
  , COMPONENT_NUMBER
  , COMPONENT_SEQUENCE_ID
  , CONFIG_HEADER_ID
  , CONFIG_REV_NBR
  , CONFIG_DISPLAY_SEQUENCE
  , CONFIGURATION_ID
  , CONTEXT

  , CREATED_BY
  , CREATION_DATE
  , CREDIT_INVOICE_LINE_ID
  , CUSTOMER_DOCK_CODE
  , CUSTOMER_JOB
  , CUSTOMER_PRODUCTION_LINE
  , CUST_PRODUCTION_SEQ_NUM
  , CUSTOMER_TRX_LINE_ID
  , CUST_MODEL_SERIAL_NUMBER
  , CUST_PO_NUMBER
  , CUSTOMER_LINE_NUMBER
  , CUSTOMER_SHIPMENT_NUMBER
  , CUSTOMER_ITEM_NET_PRICE
  , DELIVERY_LEAD_TIME
  , DELIVER_TO_CONTACT_ID
  , DELIVER_TO_ORG_ID
  , DEMAND_BUCKET_TYPE_CODE
  , DEMAND_CLASS_CODE
  , DEP_PLAN_REQUIRED_FLAG

  , EARLIEST_ACCEPTABLE_DATE
  , END_ITEM_UNIT_NUMBER
  , EXPLOSION_DATE
  , FIRST_ACK_CODE
  , FIRST_ACK_DATE
  , FOB_POINT_CODE
  , FREIGHT_CARRIER_CODE
  , FREIGHT_TERMS_CODE
  , FULFILLED_QUANTITY
  , FULFILLED_FLAG
  , FULFILLMENT_METHOD_CODE
  , FULFILLMENT_DATE
  , GLOBAL_ATTRIBUTE1
  , GLOBAL_ATTRIBUTE10
  , GLOBAL_ATTRIBUTE11
  , GLOBAL_ATTRIBUTE12
  , GLOBAL_ATTRIBUTE13
  , GLOBAL_ATTRIBUTE14
  , GLOBAL_ATTRIBUTE15
  , GLOBAL_ATTRIBUTE16
  , GLOBAL_ATTRIBUTE17
  , GLOBAL_ATTRIBUTE18
  , GLOBAL_ATTRIBUTE19
  , GLOBAL_ATTRIBUTE2
  , GLOBAL_ATTRIBUTE20
  , GLOBAL_ATTRIBUTE3
  , GLOBAL_ATTRIBUTE4
  , GLOBAL_ATTRIBUTE5
  , GLOBAL_ATTRIBUTE6
  , GLOBAL_ATTRIBUTE7
  , GLOBAL_ATTRIBUTE8
  , GLOBAL_ATTRIBUTE9
  , GLOBAL_ATTRIBUTE_CATEGORY
  , HEADER_ID
  , INDUSTRY_ATTRIBUTE1
  , INDUSTRY_ATTRIBUTE10
  , INDUSTRY_ATTRIBUTE11
  , INDUSTRY_ATTRIBUTE12
  , INDUSTRY_ATTRIBUTE13
  , INDUSTRY_ATTRIBUTE14
  , INDUSTRY_ATTRIBUTE15
  , INDUSTRY_ATTRIBUTE16
  , INDUSTRY_ATTRIBUTE17
  , INDUSTRY_ATTRIBUTE18
  , INDUSTRY_ATTRIBUTE19
  , INDUSTRY_ATTRIBUTE20
  , INDUSTRY_ATTRIBUTE21
  , INDUSTRY_ATTRIBUTE22
  , INDUSTRY_ATTRIBUTE23
  , INDUSTRY_ATTRIBUTE24
  , INDUSTRY_ATTRIBUTE25
  , INDUSTRY_ATTRIBUTE26
  , INDUSTRY_ATTRIBUTE27
  , INDUSTRY_ATTRIBUTE28
  , INDUSTRY_ATTRIBUTE29
  , INDUSTRY_ATTRIBUTE30
  , INDUSTRY_ATTRIBUTE2
  , INDUSTRY_ATTRIBUTE3
  , INDUSTRY_ATTRIBUTE4
  , INDUSTRY_ATTRIBUTE5
  , INDUSTRY_ATTRIBUTE6
  , INDUSTRY_ATTRIBUTE7
  , INDUSTRY_ATTRIBUTE8
  , INDUSTRY_ATTRIBUTE9
  , INDUSTRY_CONTEXT
  , INTMED_SHIP_TO_CONTACT_ID
  , INTMED_SHIP_TO_ORG_ID
  , INVENTORY_ITEM_ID
  , INVOICE_INTERFACE_STATUS_CODE

  , INVOICE_TO_CONTACT_ID
  , INVOICE_TO_ORG_ID
  , INVOICED_QUANTITY
  , INVOICING_RULE_ID
  , ORDERED_ITEM_ID
  , ITEM_IDENTIFIER_TYPE
  , ORDERED_ITEM
  , ITEM_REVISION
  , ITEM_TYPE_CODE
  , LAST_ACK_CODE
  , LAST_ACK_DATE
  , LAST_UPDATED_BY
  , LAST_UPDATE_DATE
  , LAST_UPDATE_LOGIN
  , LATEST_ACCEPTABLE_DATE
  , LINE_CATEGORY_CODE
  , LINE_ID
  , LINE_NUMBER
  , LINE_TYPE_ID
  , LINK_TO_LINE_ID

  , MODEL_GROUP_NUMBER
  --  , MFG_COMPONENT_SEQUENCE_ID
  , MFG_LEAD_TIME
  , OPEN_FLAG
  , OPTION_FLAG
  , OPTION_NUMBER
  , ORDERED_QUANTITY
  , ORDERED_QUANTITY2              --OPM 02/JUN/00
  , ORDER_QUANTITY_UOM
  , ORDERED_QUANTITY_UOM2          --OPM 02/JUN/00
  , ORG_ID
  , ORIG_SYS_DOCUMENT_REF
  , ORIG_SYS_LINE_REF
  , ORIG_SYS_SHIPMENT_REF
  , OVER_SHIP_REASON_CODE
  , OVER_SHIP_RESOLVED_FLAG
  , PAYMENT_TERM_ID
  , PLANNING_PRIORITY
  , PREFERRED_GRADE                --OPM 02/JUN/00
  , PRICE_LIST_ID
  , PRICE_REQUEST_CODE             --PROMOTIONS SEP/01
  , PRICING_ATTRIBUTE1
  , PRICING_ATTRIBUTE10
  , PRICING_ATTRIBUTE2
  , PRICING_ATTRIBUTE3
  , PRICING_ATTRIBUTE4
  , PRICING_ATTRIBUTE5
  , PRICING_ATTRIBUTE6
  , PRICING_ATTRIBUTE7
  , PRICING_ATTRIBUTE8
  , PRICING_ATTRIBUTE9
  , PRICING_CONTEXT
  , PRICING_DATE
  , PRICING_QUANTITY
  , PRICING_QUANTITY_UOM
  , PROGRAM_APPLICATION_ID
  , PROGRAM_ID
  , PROGRAM_UPDATE_DATE
  , PROJECT_ID
  , PROMISE_DATE
  , RE_SOURCE_FLAG
  , REFERENCE_CUSTOMER_TRX_LINE_ID
  , REFERENCE_HEADER_ID
  , REFERENCE_LINE_ID
  , REFERENCE_TYPE

  , REQUEST_DATE
  , REQUEST_ID
  , RETURN_ATTRIBUTE1
  , RETURN_ATTRIBUTE10
  , RETURN_ATTRIBUTE11
  , RETURN_ATTRIBUTE12
  , RETURN_ATTRIBUTE13
  , RETURN_ATTRIBUTE14
  , RETURN_ATTRIBUTE15
  , RETURN_ATTRIBUTE2
  , RETURN_ATTRIBUTE3
  , RETURN_ATTRIBUTE4
  , RETURN_ATTRIBUTE5
  , RETURN_ATTRIBUTE6
  , RETURN_ATTRIBUTE7
  , RETURN_ATTRIBUTE8
  , RETURN_ATTRIBUTE9
  , RETURN_CONTEXT
  , RETURN_REASON_CODE
  , RLA_SCHEDULE_TYPE_CODE
  , SALESREP_ID
  , SCHEDULE_ARRIVAL_DATE
  , SCHEDULE_SHIP_DATE
  , SCHEDULE_STATUS_CODE
  , SHIPMENT_NUMBER
  , SHIPMENT_PRIORITY_CODE
  , SHIPPED_QUANTITY
  , SHIPPED_QUANTITY2 -- OPM B1661023 04/02/01
  , SHIPPING_METHOD_CODE
  , SHIPPING_QUANTITY
  , SHIPPING_QUANTITY2 -- OPM B1661023 04/02/01
  , SHIPPING_QUANTITY_UOM
  , SHIPPING_QUANTITY_UOM2 -- INVCONV
  , SHIP_FROM_ORG_ID
  , SUBINVENTORY
  , SHIP_SET_ID
  , SHIP_TOLERANCE_ABOVE
  , SHIP_TOLERANCE_BELOW
  , SHIPPABLE_FLAG
  , SHIPPING_INTERFACED_FLAG
  , SHIP_TO_CONTACT_ID
  , SHIP_TO_ORG_ID
  , SHIP_MODEL_COMPLETE_FLAG
  , SOLD_TO_ORG_ID
  , SOLD_FROM_ORG_ID
  , SORT_ORDER
  , SOURCE_DOCUMENT_ID
  , SOURCE_DOCUMENT_LINE_ID
  , SOURCE_DOCUMENT_TYPE_ID
  , SOURCE_TYPE_CODE
  , SPLIT_FROM_LINE_ID
  , LINE_SET_ID
  , SPLIT_BY
  , MODEL_REMNANT_FLAG
  , TASK_ID
  , TAX_CODE
  , TAX_DATE
  , TAX_EXEMPT_FLAG
  , TAX_EXEMPT_NUMBER
  , TAX_EXEMPT_REASON_CODE
  , TAX_POINT_CODE
  , TAX_RATE
  , TAX_VALUE
  , TOP_MODEL_LINE_ID
  , UNIT_LIST_PRICE
  , UNIT_LIST_PRICE_PER_PQTY
  , UNIT_SELLING_PRICE
  , UNIT_SELLING_PRICE_PER_PQTY
  , VISIBLE_DEMAND_FLAG
  , VEH_CUS_ITEM_CUM_KEY_ID
  , SHIPPING_INSTRUCTIONS
  , PACKING_INSTRUCTIONS
  , SERVICE_TXN_REASON_CODE
  , SERVICE_TXN_COMMENTS
  , SERVICE_DURATION
  , SERVICE_PERIOD
  , SERVICE_START_DATE
  , SERVICE_END_DATE
  , SERVICE_COTERMINATE_FLAG
  , UNIT_LIST_PERCENT
  , UNIT_SELLING_PERCENT
  , UNIT_PERCENT_BASE_PRICE
  , SERVICE_NUMBER
  , SERVICE_REFERENCE_TYPE_CODE
  , SERVICE_REFERENCE_LINE_ID
  , SERVICE_REFERENCE_SYSTEM_ID
  , TP_CONTEXT
  , TP_ATTRIBUTE1
  , TP_ATTRIBUTE2
  , TP_ATTRIBUTE3
  , TP_ATTRIBUTE4
  , TP_ATTRIBUTE5
  , TP_ATTRIBUTE6
  , TP_ATTRIBUTE7
  , TP_ATTRIBUTE8
  , TP_ATTRIBUTE9
  , TP_ATTRIBUTE10
  , TP_ATTRIBUTE11
  , TP_ATTRIBUTE12
  , TP_ATTRIBUTE13
  , TP_ATTRIBUTE14
  , TP_ATTRIBUTE15
  , FLOW_STATUS_CODE
  , MARKETING_SOURCE_CODE_ID
  , CALCULATE_PRICE_FLAG
  , COMMITMENT_ID
  , ORDER_SOURCE_ID        -- aksingh
  , upgraded_flag
  , ORIGINAL_INVENTORY_ITEM_ID
  , ORIGINAL_ITEM_IDENTIFIER_TYPE
  , ORIGINAL_ORDERED_ITEM_ID
  , ORIGINAL_ORDERED_ITEM
  , ITEM_RELATIONSHIP_TYPE
  , ITEM_SUBSTITUTION_TYPE_CODE
  , LATE_DEMAND_PENALTY_FACTOR
  , OVERRIDE_ATP_DATE_CODE
  , FIRM_DEMAND_FLAG
  , EARLIEST_SHIP_DATE
  , USER_ITEM_DESCRIPTION
  , BLANKET_NUMBER
  , BLANKET_LINE_NUMBER
  , BLANKET_VERSION_NUMBER
    --MRG B
  , UNIT_COST
    --MRG E
  , LOCK_CONTROL
  , NVL(OPTION_NUMBER, -1)  OPN
  , NVL(COMPONENT_NUMBER, -1)  CPN
  , NVL(SERVICE_NUMBER, -1)  SVN
  , CHANGE_SEQUENCE
	-- Changes to quoting
  , transaction_phase_code
   ,      source_document_version_number
	-- End changes to quoting
  , MINISITE_ID
   ,  Ib_Owner
   ,  Ib_installed_at_location
   ,  Ib_current_location
   ,  End_customer_ID
   ,  End_customer_contact_ID
   ,  End_customer_site_use_ID
/*   ,  Supplier_signature
   ,  Supplier_signature_date
   ,  Customer_signature
   ,  Customer_signature_date  */
   --retro{
   , RETROBILL_REQUEST_ID
   --retro}
   , ORIGINAL_LIST_PRICE  -- Override List Price
 -- key Transaction Dates
   , order_firmed_date
   , actual_fulfillment_date

   --recurring charges
   , charge_periodicity_code
-- INVCONV
    , CANCELLED_QUANTITY2
    , FULFILLED_QUANTITY2
  --Customer Acceptance
   ,CONTINGENCY_ID
   ,REVREC_EVENT_CODE
   ,REVREC_EXPIRATION_DAYS
   ,ACCEPTED_QUANTITY
   ,REVREC_COMMENTS
   ,REVREC_SIGNATURE
   ,REVREC_SIGNATURE_DATE
   ,ACCEPTED_BY
   ,REVREC_REFERENCE_DOCUMENT
   ,REVREC_IMPLICIT_FLAG
    FROM    OE_ORDER_LINES_ALL  -- Fix for FP bug 3391622
    WHERE HEADER_ID = p_header_id
    ORDER BY LINE_NUMBER,SHIPMENT_NUMBER,OPN, CPN, SVN;


CURSOR l_line_csr_s IS
    SELECT  ACCOUNTING_RULE_ID
  , ACCOUNTING_RULE_DURATION
  , ACTUAL_ARRIVAL_DATE
  , ACTUAL_SHIPMENT_DATE
  , AGREEMENT_ID
  , ARRIVAL_SET_ID
  , ATO_LINE_ID
  , ATTRIBUTE1
  , ATTRIBUTE10
  , ATTRIBUTE11
  , ATTRIBUTE12
  , ATTRIBUTE13
  , ATTRIBUTE14
  , ATTRIBUTE15
  , ATTRIBUTE16   --For bug 2184255
  , ATTRIBUTE17
  , ATTRIBUTE18
  , ATTRIBUTE19
  , ATTRIBUTE2
  , ATTRIBUTE20
  , ATTRIBUTE3
  , ATTRIBUTE4
  , ATTRIBUTE5
  , ATTRIBUTE6
  , ATTRIBUTE7
  , ATTRIBUTE8
  , ATTRIBUTE9
  , AUTO_SELECTED_QUANTITY
  , AUTHORIZED_TO_SHIP_FLAG
  , BOOKED_FLAG
  , CANCELLED_FLAG
  , CANCELLED_QUANTITY
  , COMPONENT_CODE
  , COMPONENT_NUMBER
  , COMPONENT_SEQUENCE_ID
  , CONFIG_HEADER_ID
  , CONFIG_REV_NBR
  , CONFIG_DISPLAY_SEQUENCE
  , CONFIGURATION_ID
  , CONTEXT

  , CREATED_BY
  , CREATION_DATE
  , CREDIT_INVOICE_LINE_ID
  , CUSTOMER_DOCK_CODE
  , CUSTOMER_JOB
  , CUSTOMER_PRODUCTION_LINE
  , CUST_PRODUCTION_SEQ_NUM
  , CUSTOMER_TRX_LINE_ID
  , CUST_MODEL_SERIAL_NUMBER
  , CUST_PO_NUMBER
  , CUSTOMER_LINE_NUMBER
  , CUSTOMER_SHIPMENT_NUMBER
  , CUSTOMER_ITEM_NET_PRICE
  , DELIVERY_LEAD_TIME
  , DELIVER_TO_CONTACT_ID
  , DELIVER_TO_ORG_ID
  , DEMAND_BUCKET_TYPE_CODE
  , DEMAND_CLASS_CODE
  , DEP_PLAN_REQUIRED_FLAG

  , EARLIEST_ACCEPTABLE_DATE
  , END_ITEM_UNIT_NUMBER
  , EXPLOSION_DATE
  , FIRST_ACK_CODE
  , FIRST_ACK_DATE
  , FOB_POINT_CODE
  , FREIGHT_CARRIER_CODE
  , FREIGHT_TERMS_CODE
  , FULFILLED_QUANTITY
  , FULFILLED_FLAG
  , FULFILLMENT_METHOD_CODE
  , FULFILLMENT_DATE
  , GLOBAL_ATTRIBUTE1
  , GLOBAL_ATTRIBUTE10
  , GLOBAL_ATTRIBUTE11
  , GLOBAL_ATTRIBUTE12
  , GLOBAL_ATTRIBUTE13
  , GLOBAL_ATTRIBUTE14
  , GLOBAL_ATTRIBUTE15
  , GLOBAL_ATTRIBUTE16
  , GLOBAL_ATTRIBUTE17
  , GLOBAL_ATTRIBUTE18
  , GLOBAL_ATTRIBUTE19
  , GLOBAL_ATTRIBUTE2
  , GLOBAL_ATTRIBUTE20
  , GLOBAL_ATTRIBUTE3
  , GLOBAL_ATTRIBUTE4
  , GLOBAL_ATTRIBUTE5
  , GLOBAL_ATTRIBUTE6
  , GLOBAL_ATTRIBUTE7
  , GLOBAL_ATTRIBUTE8
  , GLOBAL_ATTRIBUTE9
  , GLOBAL_ATTRIBUTE_CATEGORY
  , HEADER_ID
  , INDUSTRY_ATTRIBUTE1
  , INDUSTRY_ATTRIBUTE10
  , INDUSTRY_ATTRIBUTE11
  , INDUSTRY_ATTRIBUTE12
  , INDUSTRY_ATTRIBUTE13
  , INDUSTRY_ATTRIBUTE14
  , INDUSTRY_ATTRIBUTE15
  , INDUSTRY_ATTRIBUTE16
  , INDUSTRY_ATTRIBUTE17
  , INDUSTRY_ATTRIBUTE18
  , INDUSTRY_ATTRIBUTE19
  , INDUSTRY_ATTRIBUTE20
  , INDUSTRY_ATTRIBUTE21
  , INDUSTRY_ATTRIBUTE22
  , INDUSTRY_ATTRIBUTE23
  , INDUSTRY_ATTRIBUTE24
  , INDUSTRY_ATTRIBUTE25
  , INDUSTRY_ATTRIBUTE26
  , INDUSTRY_ATTRIBUTE27
  , INDUSTRY_ATTRIBUTE28
  , INDUSTRY_ATTRIBUTE29
  , INDUSTRY_ATTRIBUTE30
  , INDUSTRY_ATTRIBUTE2
  , INDUSTRY_ATTRIBUTE3
  , INDUSTRY_ATTRIBUTE4
  , INDUSTRY_ATTRIBUTE5
  , INDUSTRY_ATTRIBUTE6
  , INDUSTRY_ATTRIBUTE7
  , INDUSTRY_ATTRIBUTE8
  , INDUSTRY_ATTRIBUTE9
  , INDUSTRY_CONTEXT
  , INTMED_SHIP_TO_CONTACT_ID
  , INTMED_SHIP_TO_ORG_ID
  , INVENTORY_ITEM_ID
  , INVOICE_INTERFACE_STATUS_CODE



  , INVOICE_TO_CONTACT_ID
  , INVOICE_TO_ORG_ID
  , INVOICED_QUANTITY
  , INVOICING_RULE_ID
  , ORDERED_ITEM_ID
  , ITEM_IDENTIFIER_TYPE
  , ORDERED_ITEM
  , ITEM_REVISION
  , ITEM_TYPE_CODE
  , LAST_ACK_CODE
  , LAST_ACK_DATE
  , LAST_UPDATED_BY
  , LAST_UPDATE_DATE
  , LAST_UPDATE_LOGIN
  , LATEST_ACCEPTABLE_DATE
  , LINE_CATEGORY_CODE
  , LINE_ID
  , LINE_NUMBER
  , LINE_TYPE_ID
  , LINK_TO_LINE_ID

  , MODEL_GROUP_NUMBER
  --  , MFG_COMPONENT_SEQUENCE_ID
  , MFG_LEAD_TIME
  , OPEN_FLAG
  , OPTION_FLAG
  , OPTION_NUMBER
  , ORDERED_QUANTITY
  , ORDERED_QUANTITY2              --OPM 02/JUN/00
  , ORDER_QUANTITY_UOM
  , ORDERED_QUANTITY_UOM2          --OPM 02/JUN/00
  , ORG_ID
  , ORIG_SYS_DOCUMENT_REF
  , ORIG_SYS_LINE_REF
  , ORIG_SYS_SHIPMENT_REF
  , OVER_SHIP_REASON_CODE
  , OVER_SHIP_RESOLVED_FLAG
  , PAYMENT_TERM_ID
  , PLANNING_PRIORITY
  , PREFERRED_GRADE                --OPM 02/JUN/00
  , PRICE_LIST_ID
  , PRICE_REQUEST_CODE             --PROMOTIONS SEP/01
  , PRICING_ATTRIBUTE1
  , PRICING_ATTRIBUTE10
  , PRICING_ATTRIBUTE2
  , PRICING_ATTRIBUTE3
  , PRICING_ATTRIBUTE4
  , PRICING_ATTRIBUTE5
  , PRICING_ATTRIBUTE6
  , PRICING_ATTRIBUTE7
  , PRICING_ATTRIBUTE8
  , PRICING_ATTRIBUTE9
  , PRICING_CONTEXT
  , PRICING_DATE
  , PRICING_QUANTITY
  , PRICING_QUANTITY_UOM
  , PROGRAM_APPLICATION_ID
  , PROGRAM_ID
  , PROGRAM_UPDATE_DATE
  , PROJECT_ID
  , PROMISE_DATE
  , RE_SOURCE_FLAG
  , REFERENCE_CUSTOMER_TRX_LINE_ID
  , REFERENCE_HEADER_ID
  , REFERENCE_LINE_ID
  , REFERENCE_TYPE

  , REQUEST_DATE
  , REQUEST_ID
  , RETURN_ATTRIBUTE1
  , RETURN_ATTRIBUTE10
  , RETURN_ATTRIBUTE11
  , RETURN_ATTRIBUTE12
  , RETURN_ATTRIBUTE13
  , RETURN_ATTRIBUTE14
  , RETURN_ATTRIBUTE15
  , RETURN_ATTRIBUTE2
  , RETURN_ATTRIBUTE3
  , RETURN_ATTRIBUTE4
  , RETURN_ATTRIBUTE5
  , RETURN_ATTRIBUTE6
  , RETURN_ATTRIBUTE7
  , RETURN_ATTRIBUTE8
  , RETURN_ATTRIBUTE9
  , RETURN_CONTEXT
  , RETURN_REASON_CODE
  , RLA_SCHEDULE_TYPE_CODE
  , SALESREP_ID
  , SCHEDULE_ARRIVAL_DATE
  , SCHEDULE_SHIP_DATE
  , SCHEDULE_STATUS_CODE
  , SHIPMENT_NUMBER
  , SHIPMENT_PRIORITY_CODE
  , SHIPPED_QUANTITY
  , SHIPPED_QUANTITY2 -- OPM B1661023 04/02/01
  , SHIPPING_METHOD_CODE
  , SHIPPING_QUANTITY
  , SHIPPING_QUANTITY2 -- OPM B1661023 04/02/01
  , SHIPPING_QUANTITY_UOM
  , SHIPPING_QUANTITY_UOM2 -- INVCONV
  , SHIP_FROM_ORG_ID
  , SUBINVENTORY
  , SHIP_SET_ID
  , SHIP_TOLERANCE_ABOVE
  , SHIP_TOLERANCE_BELOW
  , SHIPPABLE_FLAG
  , SHIPPING_INTERFACED_FLAG
  , SHIP_TO_CONTACT_ID
  , SHIP_TO_ORG_ID
  , SHIP_MODEL_COMPLETE_FLAG
  , SOLD_TO_ORG_ID
  , SOLD_FROM_ORG_ID
  , SORT_ORDER
  , SOURCE_DOCUMENT_ID
  , SOURCE_DOCUMENT_LINE_ID
  , SOURCE_DOCUMENT_TYPE_ID
  , SOURCE_TYPE_CODE
  , SPLIT_FROM_LINE_ID
  , LINE_SET_ID
  , SPLIT_BY
  , MODEL_REMNANT_FLAG
  , TASK_ID
  , TAX_CODE
  , TAX_DATE
  , TAX_EXEMPT_FLAG
  , TAX_EXEMPT_NUMBER
  , TAX_EXEMPT_REASON_CODE
  , TAX_POINT_CODE
  , TAX_RATE
  , TAX_VALUE
  , TOP_MODEL_LINE_ID
  , UNIT_LIST_PRICE
  , UNIT_LIST_PRICE_PER_PQTY
  , UNIT_SELLING_PRICE
  , UNIT_SELLING_PRICE_PER_PQTY
  , VISIBLE_DEMAND_FLAG
  , VEH_CUS_ITEM_CUM_KEY_ID
  , SHIPPING_INSTRUCTIONS
  , PACKING_INSTRUCTIONS
  , SERVICE_TXN_REASON_CODE
  , SERVICE_TXN_COMMENTS
  , SERVICE_DURATION
  , SERVICE_PERIOD
  , SERVICE_START_DATE
  , SERVICE_END_DATE
  , SERVICE_COTERMINATE_FLAG
  , UNIT_LIST_PERCENT
  , UNIT_SELLING_PERCENT
  , UNIT_PERCENT_BASE_PRICE
  , SERVICE_NUMBER
  , SERVICE_REFERENCE_TYPE_CODE
  , SERVICE_REFERENCE_LINE_ID
  , SERVICE_REFERENCE_SYSTEM_ID
  , TP_CONTEXT
  , TP_ATTRIBUTE1
  , TP_ATTRIBUTE2
  , TP_ATTRIBUTE3
  , TP_ATTRIBUTE4
  , TP_ATTRIBUTE5
  , TP_ATTRIBUTE6
  , TP_ATTRIBUTE7
  , TP_ATTRIBUTE8
  , TP_ATTRIBUTE9
  , TP_ATTRIBUTE10
  , TP_ATTRIBUTE11
  , TP_ATTRIBUTE12
  , TP_ATTRIBUTE13
  , TP_ATTRIBUTE14
  , TP_ATTRIBUTE15
  , FLOW_STATUS_CODE
  , MARKETING_SOURCE_CODE_ID
  , CALCULATE_PRICE_FLAG
  , COMMITMENT_ID
  , ORDER_SOURCE_ID        -- aksingh
  , upgraded_flag
  , ORIGINAL_INVENTORY_ITEM_ID
  , ORIGINAL_ITEM_IDENTIFIER_TYPE
  , ORIGINAL_ORDERED_ITEM_ID
  , ORIGINAL_ORDERED_ITEM
  , ITEM_RELATIONSHIP_TYPE
  , ITEM_SUBSTITUTION_TYPE_CODE
  , LATE_DEMAND_PENALTY_FACTOR
  , OVERRIDE_ATP_DATE_CODE
  , FIRM_DEMAND_FLAG
  , EARLIEST_SHIP_DATE
  , USER_ITEM_DESCRIPTION
  , BLANKET_NUMBER
  , BLANKET_LINE_NUMBER
  , BLANKET_VERSION_NUMBER
--MRG B
  , UNIT_COST
--MRG E
  , LOCK_CONTROL
  , NVL(OPTION_NUMBER, -1)  OPN
  , NVL(COMPONENT_NUMBER, -1)  CPN
  , NVL(SERVICE_NUMBER, -1)  SVN
  , CHANGE_SEQUENCE
	-- Changes to quoting
  , transaction_phase_code
   ,      source_document_version_number
	-- End changes to quoting
  , MINISITE_ID
   ,  Ib_Owner
   ,  Ib_installed_at_location
   ,  Ib_current_location
   ,  End_customer_ID
   ,  End_customer_contact_ID
   ,  End_customer_site_use_ID
/*   ,  Supplier_signature
   ,  Supplier_signature_date
   ,  Customer_signature
   ,  Customer_signature_date  */
   --retro{
   , RETROBILL_REQUEST_ID
   --retro}
   , ORIGINAL_LIST_PRICE  -- Override List Price
 -- key Transaction Dates
   , order_firmed_date
   , actual_fulfillment_date
   --recurring charges
   , charge_periodicity_code
   -- INVCONV
    , CANCELLED_QUANTITY2
    , FULFILLED_QUANTITY2
  --Customer Acceptance
   ,CONTINGENCY_ID
   ,REVREC_EVENT_CODE
   ,REVREC_EXPIRATION_DAYS
   ,ACCEPTED_QUANTITY
   ,REVREC_COMMENTS
   ,REVREC_SIGNATURE
   ,REVREC_SIGNATURE_DATE
   ,ACCEPTED_BY
   ,REVREC_REFERENCE_DOCUMENT
   ,REVREC_IMPLICIT_FLAG
    FROM    OE_ORDER_LINES_ALL  -- Fix for FP bug 3391622
    WHERE LINE_SET_ID = p_line_set_id
    ORDER BY LINE_NUMBER,SHIPMENT_NUMBER,OPN, CPN, SVN;

    l_OPN   NUMBER;
    l_CPN   NUMBER;
    l_SVN   NUMBER;


--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
l_line_rec OE_ORDER_PUB.line_rec_type;
BEGIN

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('Entering OE_LINE_UTIL.QUERY_ROWS, line_id:'||p_line_id, 1);
    END IF;

    IF
    (p_line_id IS NOT NULL
     AND
     p_line_id <> FND_API.G_MISS_NUM)
    AND
    (p_header_id IS NOT NULL
     AND
     p_header_id <> FND_API.G_MISS_NUM)
    THEN
            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                OE_MSG_PUB.Add_Exc_Msg
                (   G_PKG_NAME
              ,   'Query Rows'
              ,   'Keys are mutually exclusive: line_id = '|| p_line_id || ', header_id = '|| p_header_id
                );
            END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;

    -----------------------------------------------------------------
    -- Fix bug 1275972: Setup the l_entity variable based on the ID
    -- variable that is passed.
    -----------------------------------------------------------------

    IF nvl(p_line_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN

	   l_entity := 1;
        Query_Row(p_line_id => p_line_id,
                  x_line_rec => l_line_rec);
        x_line_tbl(1) := l_line_rec;
        RETURN;
    ELSIF nvl(p_header_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN

	   l_entity := 2;
           OPEN l_line_csr_h;

    ELSIF nvl(p_line_set_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN

	   l_entity := 3;
           OPEN l_line_csr_s;

    END IF;

    --Commented for MOAC start
    /*l_org_id := OE_GLOBALS.G_ORG_ID;
    if l_org_id IS NULL THEN
       OE_GLOBALS.Set_Context;
       l_org_id := OE_GLOBALS.G_ORG_ID;
    end if;
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('Entering '||to_char(l_org_id), 1);
    END IF;*/
  --Commented for MOAC end

    --  Loop over fetched records

    i := 1;

    LOOP

        IF l_entity = 2 THEN
             FETCH l_line_csr_h INTO
              x_line_tbl(i).ACCOUNTING_RULE_ID
            , x_line_tbl(i).ACCOUNTING_RULE_DURATION
            , x_line_tbl(i).ACTUAL_ARRIVAL_DATE
            , x_line_tbl(i).ACTUAL_SHIPMENT_DATE
            , x_line_tbl(i).AGREEMENT_ID
            , x_line_tbl(i).ARRIVAL_SET_ID
            , x_line_tbl(i).ATO_LINE_ID
            , x_line_tbl(i).ATTRIBUTE1
            , x_line_tbl(i).ATTRIBUTE10
            , x_line_tbl(i).ATTRIBUTE11
            , x_line_tbl(i).ATTRIBUTE12
            , x_line_tbl(i).ATTRIBUTE13
            , x_line_tbl(i).ATTRIBUTE14
            , x_line_tbl(i).ATTRIBUTE15
            , x_line_tbl(i).ATTRIBUTE16   --For bug 2184255
            , x_line_tbl(i).ATTRIBUTE17
            , x_line_tbl(i).ATTRIBUTE18
            , x_line_tbl(i).ATTRIBUTE19
            , x_line_tbl(i).ATTRIBUTE2
            , x_line_tbl(i).ATTRIBUTE20
            , x_line_tbl(i).ATTRIBUTE3
            , x_line_tbl(i).ATTRIBUTE4
            , x_line_tbl(i).ATTRIBUTE5
            , x_line_tbl(i).ATTRIBUTE6
            , x_line_tbl(i).ATTRIBUTE7
            , x_line_tbl(i).ATTRIBUTE8
            , x_line_tbl(i).ATTRIBUTE9
            , x_line_tbl(i).AUTO_SELECTED_QUANTITY
            , x_line_tbl(i).AUTHORIZED_TO_SHIP_FLAG
            , x_line_tbl(i).BOOKED_FLAG
            , x_line_tbl(i).CANCELLED_FLAG
            , x_line_tbl(i).CANCELLED_QUANTITY
            , x_line_tbl(i).COMPONENT_CODE
            , x_line_tbl(i).COMPONENT_NUMBER
            , x_line_tbl(i).COMPONENT_SEQUENCE_ID
            , x_line_tbl(i).CONFIG_HEADER_ID
            , x_line_tbl(i).CONFIG_REV_NBR
            , x_line_tbl(i).CONFIG_DISPLAY_SEQUENCE
            , x_line_tbl(i).CONFIGURATION_ID
            , x_line_tbl(i).CONTEXT
            , x_line_tbl(i).CREATED_BY
            , x_line_tbl(i).CREATION_DATE
            , x_line_tbl(i).CREDIT_INVOICE_LINE_ID
            , x_line_tbl(i).CUSTOMER_DOCK_CODE
            , x_line_tbl(i).CUSTOMER_JOB
            , x_line_tbl(i).CUSTOMER_PRODUCTION_LINE
            , x_line_tbl(i).CUST_PRODUCTION_SEQ_NUM
            , x_line_tbl(i).CUSTOMER_TRX_LINE_ID
            , x_line_tbl(i).CUST_MODEL_SERIAL_NUMBER
            , x_line_tbl(i).CUST_PO_NUMBER
            , x_line_tbl(i).CUSTOMER_LINE_NUMBER
            , x_line_tbl(i).CUSTOMER_SHIPMENT_NUMBER
            , x_line_tbl(i).CUSTOMER_ITEM_NET_PRICE
            , x_line_tbl(i).DELIVERY_LEAD_TIME
            , x_line_tbl(i).DELIVER_TO_CONTACT_ID
            , x_line_tbl(i).DELIVER_TO_ORG_ID
            , x_line_tbl(i).DEMAND_BUCKET_TYPE_CODE
            , x_line_tbl(i).DEMAND_CLASS_CODE
            , x_line_tbl(i).DEP_PLAN_REQUIRED_FLAG
            , x_line_tbl(i).EARLIEST_ACCEPTABLE_DATE
            , x_line_tbl(i).END_ITEM_UNIT_NUMBER
            , x_line_tbl(i).EXPLOSION_DATE
            , x_line_tbl(i).FIRST_ACK_CODE
            , x_line_tbl(i).FIRST_ACK_DATE
            , x_line_tbl(i).FOB_POINT_CODE
            , x_line_tbl(i).FREIGHT_CARRIER_CODE
            , x_line_tbl(i).FREIGHT_TERMS_CODE
            , x_line_tbl(i).FULFILLED_QUANTITY
            , x_line_tbl(i).FULFILLED_FLAG
            , x_line_tbl(i).FULFILLMENT_METHOD_CODE
            , x_line_tbl(i).FULFILLMENT_DATE
            , x_line_tbl(i).GLOBAL_ATTRIBUTE1
            , x_line_tbl(i).GLOBAL_ATTRIBUTE10
            , x_line_tbl(i).GLOBAL_ATTRIBUTE11
            , x_line_tbl(i).GLOBAL_ATTRIBUTE12
            , x_line_tbl(i).GLOBAL_ATTRIBUTE13
            , x_line_tbl(i).GLOBAL_ATTRIBUTE14
            , x_line_tbl(i).GLOBAL_ATTRIBUTE15
            , x_line_tbl(i).GLOBAL_ATTRIBUTE16
            , x_line_tbl(i).GLOBAL_ATTRIBUTE17
            , x_line_tbl(i).GLOBAL_ATTRIBUTE18
            , x_line_tbl(i).GLOBAL_ATTRIBUTE19
            , x_line_tbl(i).GLOBAL_ATTRIBUTE2
            , x_line_tbl(i).GLOBAL_ATTRIBUTE20
            , x_line_tbl(i).GLOBAL_ATTRIBUTE3
            , x_line_tbl(i).GLOBAL_ATTRIBUTE4
            , x_line_tbl(i).GLOBAL_ATTRIBUTE5
            , x_line_tbl(i).GLOBAL_ATTRIBUTE6
            , x_line_tbl(i).GLOBAL_ATTRIBUTE7
            , x_line_tbl(i).GLOBAL_ATTRIBUTE8
            , x_line_tbl(i).GLOBAL_ATTRIBUTE9
            , x_line_tbl(i).GLOBAL_ATTRIBUTE_CATEGORY
            , x_line_tbl(i).HEADER_ID
            , x_line_tbl(i).INDUSTRY_ATTRIBUTE1
            , x_line_tbl(i).INDUSTRY_ATTRIBUTE10
            , x_line_tbl(i).INDUSTRY_ATTRIBUTE11
            , x_line_tbl(i).INDUSTRY_ATTRIBUTE12
            , x_line_tbl(i).INDUSTRY_ATTRIBUTE13
            , x_line_tbl(i).INDUSTRY_ATTRIBUTE14
            , x_line_tbl(i).INDUSTRY_ATTRIBUTE15
            , x_line_tbl(i).INDUSTRY_ATTRIBUTE16
            , x_line_tbl(i).INDUSTRY_ATTRIBUTE17
            , x_line_tbl(i).INDUSTRY_ATTRIBUTE18
            , x_line_tbl(i).INDUSTRY_ATTRIBUTE19
            , x_line_tbl(i).INDUSTRY_ATTRIBUTE20
            , x_line_tbl(i).INDUSTRY_ATTRIBUTE21
            , x_line_tbl(i).INDUSTRY_ATTRIBUTE22
            , x_line_tbl(i).INDUSTRY_ATTRIBUTE23
            , x_line_tbl(i).INDUSTRY_ATTRIBUTE24
            , x_line_tbl(i).INDUSTRY_ATTRIBUTE25
            , x_line_tbl(i).INDUSTRY_ATTRIBUTE26
            , x_line_tbl(i).INDUSTRY_ATTRIBUTE27
            , x_line_tbl(i).INDUSTRY_ATTRIBUTE28
            , x_line_tbl(i).INDUSTRY_ATTRIBUTE29
            , x_line_tbl(i).INDUSTRY_ATTRIBUTE30
            , x_line_tbl(i).INDUSTRY_ATTRIBUTE2
            , x_line_tbl(i).INDUSTRY_ATTRIBUTE3
            , x_line_tbl(i).INDUSTRY_ATTRIBUTE4
            , x_line_tbl(i).INDUSTRY_ATTRIBUTE5
            , x_line_tbl(i).INDUSTRY_ATTRIBUTE6
            , x_line_tbl(i).INDUSTRY_ATTRIBUTE7
            , x_line_tbl(i).INDUSTRY_ATTRIBUTE8
            , x_line_tbl(i).INDUSTRY_ATTRIBUTE9
            , x_line_tbl(i).INDUSTRY_CONTEXT
            , x_line_tbl(i).INTERMED_SHIP_TO_CONTACT_ID
            , x_line_tbl(i).INTERMED_SHIP_TO_ORG_ID
            , x_line_tbl(i).INVENTORY_ITEM_ID
            , x_line_tbl(i).INVOICE_INTERFACE_STATUS_CODE
            , x_line_tbl(i).INVOICE_TO_CONTACT_ID
            , x_line_tbl(i).INVOICE_TO_ORG_ID
            , x_line_tbl(i).INVOICED_QUANTITY
            , x_line_tbl(i).INVOICING_RULE_ID
            , x_line_tbl(i).ORDERED_ITEM_ID
            , x_line_tbl(i).ITEM_IDENTIFIER_TYPE
            , x_line_tbl(i).ORDERED_ITEM
            , x_line_tbl(i).ITEM_REVISION
            , x_line_tbl(i).ITEM_TYPE_CODE
            , x_line_tbl(i).LAST_ACK_CODE
            , x_line_tbl(i).LAST_ACK_DATE
            , x_line_tbl(i).LAST_UPDATED_BY
            , x_line_tbl(i).LAST_UPDATE_DATE
            , x_line_tbl(i).LAST_UPDATE_LOGIN
            , x_line_tbl(i).LATEST_ACCEPTABLE_DATE
            , x_line_tbl(i).LINE_CATEGORY_CODE
            , x_line_tbl(i).LINE_ID
            , x_line_tbl(i).LINE_NUMBER
            , x_line_tbl(i).LINE_TYPE_ID
            , x_line_tbl(i).LINK_TO_LINE_ID
            , x_line_tbl(i).MODEL_GROUP_NUMBER
            --  , x_line_tbl(i).MFG_COMPONENT_SEQUENCE_ID
            , x_line_tbl(i).MFG_LEAD_TIME
            , x_line_tbl(i).OPEN_FLAG
            , x_line_tbl(i).OPTION_FLAG
            , x_line_tbl(i).OPTION_NUMBER
            , x_line_tbl(i).ORDERED_QUANTITY
            , x_line_tbl(i).ORDERED_QUANTITY2              --OPM 02/JUN/00
            , x_line_tbl(i).ORDER_QUANTITY_UOM
            , x_line_tbl(i).ORDERED_QUANTITY_UOM2          --OPM 02/JUN/00
            , x_line_tbl(i).ORG_ID
            , x_line_tbl(i).ORIG_SYS_DOCUMENT_REF
            , x_line_tbl(i).ORIG_SYS_LINE_REF
            , x_line_tbl(i).ORIG_SYS_SHIPMENT_REF
            , x_line_tbl(i).OVER_SHIP_REASON_CODE
            , x_line_tbl(i).OVER_SHIP_RESOLVED_FLAG
            , x_line_tbl(i).PAYMENT_TERM_ID
            , x_line_tbl(i).PLANNING_PRIORITY
            , x_line_tbl(i).PREFERRED_GRADE                --OPM 02/JUN/00
            , x_line_tbl(i).PRICE_LIST_ID
            , x_line_tbl(i).PRICE_REQUEST_CODE             --PROMOTIONS MAY/01
            , x_line_tbl(i).PRICING_ATTRIBUTE1
            , x_line_tbl(i).PRICING_ATTRIBUTE10
            , x_line_tbl(i).PRICING_ATTRIBUTE2
            , x_line_tbl(i).PRICING_ATTRIBUTE3
            , x_line_tbl(i).PRICING_ATTRIBUTE4
            , x_line_tbl(i).PRICING_ATTRIBUTE5
            , x_line_tbl(i).PRICING_ATTRIBUTE6
            , x_line_tbl(i).PRICING_ATTRIBUTE7
            , x_line_tbl(i).PRICING_ATTRIBUTE8
            , x_line_tbl(i).PRICING_ATTRIBUTE9
            , x_line_tbl(i).PRICING_CONTEXT
            , x_line_tbl(i).PRICING_DATE
            , x_line_tbl(i).PRICING_QUANTITY
            , x_line_tbl(i).PRICING_QUANTITY_UOM
            , x_line_tbl(i).PROGRAM_APPLICATION_ID
            , x_line_tbl(i).PROGRAM_ID
            , x_line_tbl(i).PROGRAM_UPDATE_DATE
            , x_line_tbl(i).PROJECT_ID
            , x_line_tbl(i).PROMISE_DATE
            , x_line_tbl(i).RE_SOURCE_FLAG
            , x_line_tbl(i).REFERENCE_CUSTOMER_TRX_LINE_ID
            , x_line_tbl(i).REFERENCE_HEADER_ID
            , x_line_tbl(i).REFERENCE_LINE_ID
            , x_line_tbl(i).REFERENCE_TYPE
            , x_line_tbl(i).REQUEST_DATE
            , x_line_tbl(i).REQUEST_ID
            , x_line_tbl(i).RETURN_ATTRIBUTE1
            , x_line_tbl(i).RETURN_ATTRIBUTE10
            , x_line_tbl(i).RETURN_ATTRIBUTE11
            , x_line_tbl(i).RETURN_ATTRIBUTE12
            , x_line_tbl(i).RETURN_ATTRIBUTE13
            , x_line_tbl(i).RETURN_ATTRIBUTE14
            , x_line_tbl(i).RETURN_ATTRIBUTE15
            , x_line_tbl(i).RETURN_ATTRIBUTE2
            , x_line_tbl(i).RETURN_ATTRIBUTE3
            , x_line_tbl(i).RETURN_ATTRIBUTE4
            , x_line_tbl(i).RETURN_ATTRIBUTE5
            , x_line_tbl(i).RETURN_ATTRIBUTE6
            , x_line_tbl(i).RETURN_ATTRIBUTE7
            , x_line_tbl(i).RETURN_ATTRIBUTE8
            , x_line_tbl(i).RETURN_ATTRIBUTE9
            , x_line_tbl(i).RETURN_CONTEXT
            , x_line_tbl(i).RETURN_REASON_CODE
            , x_line_tbl(i).RLA_SCHEDULE_TYPE_CODE
            , x_line_tbl(i).SALESREP_ID
            , x_line_tbl(i).SCHEDULE_ARRIVAL_DATE
            , x_line_tbl(i).SCHEDULE_SHIP_DATE
            , x_line_tbl(i).SCHEDULE_STATUS_CODE
            , x_line_tbl(i).SHIPMENT_NUMBER
            , x_line_tbl(i).SHIPMENT_PRIORITY_CODE
            , x_line_tbl(i).SHIPPED_QUANTITY
            , x_line_tbl(i).SHIPPED_QUANTITY2 -- OPM B1661023 04/02/01
            , x_line_tbl(i).SHIPPING_METHOD_CODE
            , x_line_tbl(i).SHIPPING_QUANTITY
            , x_line_tbl(i).SHIPPING_QUANTITY2 -- OPM B1661023 04/02/01
            , x_line_tbl(i).SHIPPING_QUANTITY_UOM
            , x_line_tbl(i).SHIPPING_QUANTITY_UOM2
            , x_line_tbl(i).SHIP_FROM_ORG_ID
            , x_line_tbl(i).SUBINVENTORY
            , x_line_tbl(i).SHIP_SET_ID
            , x_line_tbl(i).SHIP_TOLERANCE_ABOVE
            , x_line_tbl(i).SHIP_TOLERANCE_BELOW
            , x_line_tbl(i).SHIPPABLE_FLAG
            , x_line_tbl(i).SHIPPING_INTERFACED_FLAG
            , x_line_tbl(i).SHIP_TO_CONTACT_ID
            , x_line_tbl(i).SHIP_TO_ORG_ID
            , x_line_tbl(i).SHIP_MODEL_COMPLETE_FLAG
            , x_line_tbl(i).SOLD_TO_ORG_ID
            , x_line_tbl(i).SOLD_FROM_ORG_ID
            , x_line_tbl(i).SORT_ORDER
            , x_line_tbl(i).SOURCE_DOCUMENT_ID
            , x_line_tbl(i).SOURCE_DOCUMENT_LINE_ID
            , x_line_tbl(i).SOURCE_DOCUMENT_TYPE_ID
            , x_line_tbl(i).SOURCE_TYPE_CODE
            , x_line_tbl(i).SPLIT_FROM_LINE_ID
            , x_line_tbl(i).LINE_SET_ID
            , x_line_tbl(i).SPLIT_BY
            , x_line_tbl(i).MODEL_REMNANT_FLAG
            , x_line_tbl(i).TASK_ID
            , x_line_tbl(i).TAX_CODE
            , x_line_tbl(i).TAX_DATE
            , x_line_tbl(i).TAX_EXEMPT_FLAG
            , x_line_tbl(i).TAX_EXEMPT_NUMBER
            , x_line_tbl(i).TAX_EXEMPT_REASON_CODE
            , x_line_tbl(i).TAX_POINT_CODE
            , x_line_tbl(i).TAX_RATE
            , x_line_tbl(i).TAX_VALUE
            , x_line_tbl(i).TOP_MODEL_LINE_ID
            , x_line_tbl(i).UNIT_LIST_PRICE
            , x_line_tbl(i).UNIT_LIST_PRICE_PER_PQTY
            , x_line_tbl(i).UNIT_SELLING_PRICE
            , x_line_tbl(i).UNIT_SELLING_PRICE_PER_PQTY
            , x_line_tbl(i).VISIBLE_DEMAND_FLAG
            , x_line_tbl(i).VEH_CUS_ITEM_CUM_KEY_ID
            , x_line_tbl(i).SHIPPING_INSTRUCTIONS
            , x_line_tbl(i).PACKING_INSTRUCTIONS
            , x_line_tbl(i).SERVICE_TXN_REASON_CODE
            , x_line_tbl(i).SERVICE_TXN_COMMENTS
            , x_line_tbl(i).SERVICE_DURATION
            , x_line_tbl(i).SERVICE_PERIOD
            , x_line_tbl(i).SERVICE_START_DATE
            , x_line_tbl(i).SERVICE_END_DATE
            , x_line_tbl(i).SERVICE_COTERMINATE_FLAG
            , x_line_tbl(i).UNIT_LIST_PERCENT
            , x_line_tbl(i).UNIT_SELLING_PERCENT
            , x_line_tbl(i).UNIT_PERCENT_BASE_PRICE
            , x_line_tbl(i).SERVICE_NUMBER
            , x_line_tbl(i).SERVICE_REFERENCE_TYPE_CODE
            , x_line_tbl(i).SERVICE_REFERENCE_LINE_ID
            , x_line_tbl(i).SERVICE_REFERENCE_SYSTEM_ID
            , x_line_tbl(i).TP_CONTEXT
            , x_line_tbl(i).TP_ATTRIBUTE1
            , x_line_tbl(i).TP_ATTRIBUTE2
            , x_line_tbl(i).TP_ATTRIBUTE3
            , x_line_tbl(i).TP_ATTRIBUTE4
            , x_line_tbl(i).TP_ATTRIBUTE5
            , x_line_tbl(i).TP_ATTRIBUTE6
            , x_line_tbl(i).TP_ATTRIBUTE7
            , x_line_tbl(i).TP_ATTRIBUTE8
            , x_line_tbl(i).TP_ATTRIBUTE9
            , x_line_tbl(i).TP_ATTRIBUTE10
            , x_line_tbl(i).TP_ATTRIBUTE11
            , x_line_tbl(i).TP_ATTRIBUTE12
            , x_line_tbl(i).TP_ATTRIBUTE13
            , x_line_tbl(i).TP_ATTRIBUTE14
            , x_line_tbl(i).TP_ATTRIBUTE15
            , x_line_tbl(i).FLOW_STATUS_CODE
            , x_line_tbl(i).MARKETING_SOURCE_CODE_ID
            , x_line_tbl(i).CALCULATE_PRICE_FLAG
            , x_line_tbl(i).COMMITMENT_ID
            , x_line_tbl(i).ORDER_SOURCE_ID        -- aksingh
            , x_line_tbl(i).UPGRADED_FLAG
            , x_line_tbl(i).ORIGINAL_INVENTORY_ITEM_ID
            , x_line_tbl(i).ORIGINAL_ITEM_IDENTIFIER_TYPE
            , x_line_tbl(i).ORIGINAL_ORDERED_ITEM_ID
            , x_line_tbl(i).ORIGINAL_ORDERED_ITEM
            , x_line_tbl(i).ITEM_RELATIONSHIP_TYPE
            , x_line_tbl(i).ITEM_SUBSTITUTION_TYPE_CODE
            , x_line_tbl(i).LATE_DEMAND_PENALTY_FACTOR
            , x_line_tbl(i).OVERRIDE_ATP_DATE_CODE
            , x_line_tbl(i).FIRM_DEMAND_FLAG
            , x_line_tbl(i).EARLIEST_SHIP_DATE
            , x_line_tbl(i).USER_ITEM_DESCRIPTION
            , x_line_tbl(i).BLANKET_NUMBER
            , x_line_tbl(i).BLANKET_LINE_NUMBER
            , x_line_tbl(i).BLANKET_VERSION_NUMBER
            , x_line_tbl(i).UNIT_COST
            , x_line_tbl(i).LOCK_CONTROL
            , l_opn    --OPN
            , l_cpn    --CPN
            , l_svn    --SVN
            , x_line_tbl(i).CHANGE_SEQUENCE
            , x_line_tbl(i).transaction_phase_code
            , x_line_tbl(i).source_document_version_number
            , x_line_tbl(i).MINISITE_ID
             , x_line_tbl(i).Ib_Owner
             , x_line_tbl(i).Ib_installed_at_location
             , x_line_tbl(i).Ib_current_location
             , x_line_tbl(i).End_customer_ID
             , x_line_tbl(i).End_customer_contact_ID
             , x_line_tbl(i).End_customer_site_use_ID
             , x_line_tbl(i).RETROBILL_REQUEST_ID
             , x_line_tbl(i).ORIGINAL_LIST_PRICE  -- Override List Price
             , x_line_tbl(i).order_firmed_date
             , x_line_tbl(i).actual_fulfillment_date
             , x_line_tbl(i).charge_periodicity_code
             , x_line_tbl(i).cancelled_quantity2
             , x_line_tbl(i).fulfilled_quantity2
             , x_line_tbl(i).CONTINGENCY_ID
             , x_line_tbl(i).REVREC_EVENT_CODE
             , x_line_tbl(i).REVREC_EXPIRATION_DAYS
             , x_line_tbl(i).ACCEPTED_QUANTITY
             , x_line_tbl(i).REVREC_COMMENTS
             , x_line_tbl(i).REVREC_SIGNATURE
             , x_line_tbl(i).REVREC_SIGNATURE_DATE
             , x_line_tbl(i).ACCEPTED_BY
             , x_line_tbl(i).REVREC_REFERENCE_DOCUMENT
             , x_line_tbl(i).REVREC_IMPLICIT_FLAG;

             EXIT WHEN l_line_csr_h%NOTFOUND;

        ELSIF l_entity = 3 THEN
             FETCH l_line_csr_s INTO
              x_line_tbl(i).ACCOUNTING_RULE_ID
            , x_line_tbl(i).ACCOUNTING_RULE_DURATION
            , x_line_tbl(i).ACTUAL_ARRIVAL_DATE
            , x_line_tbl(i).ACTUAL_SHIPMENT_DATE
            , x_line_tbl(i).AGREEMENT_ID
            , x_line_tbl(i).ARRIVAL_SET_ID
            , x_line_tbl(i).ATO_LINE_ID
            , x_line_tbl(i).ATTRIBUTE1
            , x_line_tbl(i).ATTRIBUTE10
            , x_line_tbl(i).ATTRIBUTE11
            , x_line_tbl(i).ATTRIBUTE12
            , x_line_tbl(i).ATTRIBUTE13
            , x_line_tbl(i).ATTRIBUTE14
            , x_line_tbl(i).ATTRIBUTE15
            , x_line_tbl(i).ATTRIBUTE16   --For bug 2184255
            , x_line_tbl(i).ATTRIBUTE17
            , x_line_tbl(i).ATTRIBUTE18
            , x_line_tbl(i).ATTRIBUTE19
            , x_line_tbl(i).ATTRIBUTE2
            , x_line_tbl(i).ATTRIBUTE20
            , x_line_tbl(i).ATTRIBUTE3
            , x_line_tbl(i).ATTRIBUTE4
            , x_line_tbl(i).ATTRIBUTE5
            , x_line_tbl(i).ATTRIBUTE6
            , x_line_tbl(i).ATTRIBUTE7
            , x_line_tbl(i).ATTRIBUTE8
            , x_line_tbl(i).ATTRIBUTE9
            , x_line_tbl(i).AUTO_SELECTED_QUANTITY
            , x_line_tbl(i).AUTHORIZED_TO_SHIP_FLAG
            , x_line_tbl(i).BOOKED_FLAG
            , x_line_tbl(i).CANCELLED_FLAG
            , x_line_tbl(i).CANCELLED_QUANTITY
            , x_line_tbl(i).COMPONENT_CODE
            , x_line_tbl(i).COMPONENT_NUMBER
            , x_line_tbl(i).COMPONENT_SEQUENCE_ID
            , x_line_tbl(i).CONFIG_HEADER_ID
            , x_line_tbl(i).CONFIG_REV_NBR
            , x_line_tbl(i).CONFIG_DISPLAY_SEQUENCE
            , x_line_tbl(i).CONFIGURATION_ID
            , x_line_tbl(i).CONTEXT
            , x_line_tbl(i).CREATED_BY
            , x_line_tbl(i).CREATION_DATE
            , x_line_tbl(i).CREDIT_INVOICE_LINE_ID
            , x_line_tbl(i).CUSTOMER_DOCK_CODE
            , x_line_tbl(i).CUSTOMER_JOB
            , x_line_tbl(i).CUSTOMER_PRODUCTION_LINE
            , x_line_tbl(i).CUST_PRODUCTION_SEQ_NUM
            , x_line_tbl(i).CUSTOMER_TRX_LINE_ID
            , x_line_tbl(i).CUST_MODEL_SERIAL_NUMBER
            , x_line_tbl(i).CUST_PO_NUMBER
            , x_line_tbl(i).CUSTOMER_LINE_NUMBER
            , x_line_tbl(i).CUSTOMER_SHIPMENT_NUMBER
            , x_line_tbl(i).CUSTOMER_ITEM_NET_PRICE
            , x_line_tbl(i).DELIVERY_LEAD_TIME
            , x_line_tbl(i).DELIVER_TO_CONTACT_ID
            , x_line_tbl(i).DELIVER_TO_ORG_ID
            , x_line_tbl(i).DEMAND_BUCKET_TYPE_CODE
            , x_line_tbl(i).DEMAND_CLASS_CODE
            , x_line_tbl(i).DEP_PLAN_REQUIRED_FLAG
            , x_line_tbl(i).EARLIEST_ACCEPTABLE_DATE
            , x_line_tbl(i).END_ITEM_UNIT_NUMBER
            , x_line_tbl(i).EXPLOSION_DATE
            , x_line_tbl(i).FIRST_ACK_CODE
            , x_line_tbl(i).FIRST_ACK_DATE
            , x_line_tbl(i).FOB_POINT_CODE
            , x_line_tbl(i).FREIGHT_CARRIER_CODE
            , x_line_tbl(i).FREIGHT_TERMS_CODE
            , x_line_tbl(i).FULFILLED_QUANTITY
            , x_line_tbl(i).FULFILLED_FLAG
            , x_line_tbl(i).FULFILLMENT_METHOD_CODE
            , x_line_tbl(i).FULFILLMENT_DATE
            , x_line_tbl(i).GLOBAL_ATTRIBUTE1
            , x_line_tbl(i).GLOBAL_ATTRIBUTE10
            , x_line_tbl(i).GLOBAL_ATTRIBUTE11
            , x_line_tbl(i).GLOBAL_ATTRIBUTE12
            , x_line_tbl(i).GLOBAL_ATTRIBUTE13
            , x_line_tbl(i).GLOBAL_ATTRIBUTE14
            , x_line_tbl(i).GLOBAL_ATTRIBUTE15
            , x_line_tbl(i).GLOBAL_ATTRIBUTE16
            , x_line_tbl(i).GLOBAL_ATTRIBUTE17
            , x_line_tbl(i).GLOBAL_ATTRIBUTE18
            , x_line_tbl(i).GLOBAL_ATTRIBUTE19
            , x_line_tbl(i).GLOBAL_ATTRIBUTE2
            , x_line_tbl(i).GLOBAL_ATTRIBUTE20
            , x_line_tbl(i).GLOBAL_ATTRIBUTE3
            , x_line_tbl(i).GLOBAL_ATTRIBUTE4
            , x_line_tbl(i).GLOBAL_ATTRIBUTE5
            , x_line_tbl(i).GLOBAL_ATTRIBUTE6
            , x_line_tbl(i).GLOBAL_ATTRIBUTE7
            , x_line_tbl(i).GLOBAL_ATTRIBUTE8
            , x_line_tbl(i).GLOBAL_ATTRIBUTE9
            , x_line_tbl(i).GLOBAL_ATTRIBUTE_CATEGORY
            , x_line_tbl(i).HEADER_ID
            , x_line_tbl(i).INDUSTRY_ATTRIBUTE1
            , x_line_tbl(i).INDUSTRY_ATTRIBUTE10
            , x_line_tbl(i).INDUSTRY_ATTRIBUTE11
            , x_line_tbl(i).INDUSTRY_ATTRIBUTE12
            , x_line_tbl(i).INDUSTRY_ATTRIBUTE13
            , x_line_tbl(i).INDUSTRY_ATTRIBUTE14
            , x_line_tbl(i).INDUSTRY_ATTRIBUTE15
            , x_line_tbl(i).INDUSTRY_ATTRIBUTE16
            , x_line_tbl(i).INDUSTRY_ATTRIBUTE17
            , x_line_tbl(i).INDUSTRY_ATTRIBUTE18
            , x_line_tbl(i).INDUSTRY_ATTRIBUTE19
            , x_line_tbl(i).INDUSTRY_ATTRIBUTE20
            , x_line_tbl(i).INDUSTRY_ATTRIBUTE21
            , x_line_tbl(i).INDUSTRY_ATTRIBUTE22
            , x_line_tbl(i).INDUSTRY_ATTRIBUTE23
            , x_line_tbl(i).INDUSTRY_ATTRIBUTE24
            , x_line_tbl(i).INDUSTRY_ATTRIBUTE25
            , x_line_tbl(i).INDUSTRY_ATTRIBUTE26
            , x_line_tbl(i).INDUSTRY_ATTRIBUTE27
            , x_line_tbl(i).INDUSTRY_ATTRIBUTE28
            , x_line_tbl(i).INDUSTRY_ATTRIBUTE29
            , x_line_tbl(i).INDUSTRY_ATTRIBUTE30
            , x_line_tbl(i).INDUSTRY_ATTRIBUTE2
            , x_line_tbl(i).INDUSTRY_ATTRIBUTE3
            , x_line_tbl(i).INDUSTRY_ATTRIBUTE4
            , x_line_tbl(i).INDUSTRY_ATTRIBUTE5
            , x_line_tbl(i).INDUSTRY_ATTRIBUTE6
            , x_line_tbl(i).INDUSTRY_ATTRIBUTE7
            , x_line_tbl(i).INDUSTRY_ATTRIBUTE8
            , x_line_tbl(i).INDUSTRY_ATTRIBUTE9
            , x_line_tbl(i).INDUSTRY_CONTEXT
            , x_line_tbl(i).INTERMED_SHIP_TO_CONTACT_ID
            , x_line_tbl(i).INTERMED_SHIP_TO_ORG_ID
            , x_line_tbl(i).INVENTORY_ITEM_ID
            , x_line_tbl(i).INVOICE_INTERFACE_STATUS_CODE
            , x_line_tbl(i).INVOICE_TO_CONTACT_ID
            , x_line_tbl(i).INVOICE_TO_ORG_ID
            , x_line_tbl(i).INVOICED_QUANTITY
            , x_line_tbl(i).INVOICING_RULE_ID
            , x_line_tbl(i).ORDERED_ITEM_ID
            , x_line_tbl(i).ITEM_IDENTIFIER_TYPE
            , x_line_tbl(i).ORDERED_ITEM
            , x_line_tbl(i).ITEM_REVISION
            , x_line_tbl(i).ITEM_TYPE_CODE
            , x_line_tbl(i).LAST_ACK_CODE
            , x_line_tbl(i).LAST_ACK_DATE
            , x_line_tbl(i).LAST_UPDATED_BY
            , x_line_tbl(i).LAST_UPDATE_DATE
            , x_line_tbl(i).LAST_UPDATE_LOGIN
            , x_line_tbl(i).LATEST_ACCEPTABLE_DATE
            , x_line_tbl(i).LINE_CATEGORY_CODE
            , x_line_tbl(i).LINE_ID
            , x_line_tbl(i).LINE_NUMBER
            , x_line_tbl(i).LINE_TYPE_ID
            , x_line_tbl(i).LINK_TO_LINE_ID
            , x_line_tbl(i).MODEL_GROUP_NUMBER
            --  , x_line_tbl(i).MFG_COMPONENT_SEQUENCE_ID
            , x_line_tbl(i).MFG_LEAD_TIME
            , x_line_tbl(i).OPEN_FLAG
            , x_line_tbl(i).OPTION_FLAG
            , x_line_tbl(i).OPTION_NUMBER
            , x_line_tbl(i).ORDERED_QUANTITY
            , x_line_tbl(i).ORDERED_QUANTITY2              --OPM 02/JUN/00
            , x_line_tbl(i).ORDER_QUANTITY_UOM
            , x_line_tbl(i).ORDERED_QUANTITY_UOM2          --OPM 02/JUN/00
            , x_line_tbl(i).ORG_ID
            , x_line_tbl(i).ORIG_SYS_DOCUMENT_REF
            , x_line_tbl(i).ORIG_SYS_LINE_REF
            , x_line_tbl(i).ORIG_SYS_SHIPMENT_REF
            , x_line_tbl(i).OVER_SHIP_REASON_CODE
            , x_line_tbl(i).OVER_SHIP_RESOLVED_FLAG
            , x_line_tbl(i).PAYMENT_TERM_ID
            , x_line_tbl(i).PLANNING_PRIORITY
            , x_line_tbl(i).PREFERRED_GRADE                --OPM 02/JUN/00
            , x_line_tbl(i).PRICE_LIST_ID
            , x_line_tbl(i).PRICE_REQUEST_CODE             --PROMOTIONS MAY/01
            , x_line_tbl(i).PRICING_ATTRIBUTE1
            , x_line_tbl(i).PRICING_ATTRIBUTE10
            , x_line_tbl(i).PRICING_ATTRIBUTE2
            , x_line_tbl(i).PRICING_ATTRIBUTE3
            , x_line_tbl(i).PRICING_ATTRIBUTE4
            , x_line_tbl(i).PRICING_ATTRIBUTE5
            , x_line_tbl(i).PRICING_ATTRIBUTE6
            , x_line_tbl(i).PRICING_ATTRIBUTE7
            , x_line_tbl(i).PRICING_ATTRIBUTE8
            , x_line_tbl(i).PRICING_ATTRIBUTE9
            , x_line_tbl(i).PRICING_CONTEXT
            , x_line_tbl(i).PRICING_DATE
            , x_line_tbl(i).PRICING_QUANTITY
            , x_line_tbl(i).PRICING_QUANTITY_UOM
            , x_line_tbl(i).PROGRAM_APPLICATION_ID
            , x_line_tbl(i).PROGRAM_ID
            , x_line_tbl(i).PROGRAM_UPDATE_DATE
            , x_line_tbl(i).PROJECT_ID
            , x_line_tbl(i).PROMISE_DATE
            , x_line_tbl(i).RE_SOURCE_FLAG
            , x_line_tbl(i).REFERENCE_CUSTOMER_TRX_LINE_ID
            , x_line_tbl(i).REFERENCE_HEADER_ID
            , x_line_tbl(i).REFERENCE_LINE_ID
            , x_line_tbl(i).REFERENCE_TYPE
            , x_line_tbl(i).REQUEST_DATE
            , x_line_tbl(i).REQUEST_ID
            , x_line_tbl(i).RETURN_ATTRIBUTE1
            , x_line_tbl(i).RETURN_ATTRIBUTE10
            , x_line_tbl(i).RETURN_ATTRIBUTE11
            , x_line_tbl(i).RETURN_ATTRIBUTE12
            , x_line_tbl(i).RETURN_ATTRIBUTE13
            , x_line_tbl(i).RETURN_ATTRIBUTE14
            , x_line_tbl(i).RETURN_ATTRIBUTE15
            , x_line_tbl(i).RETURN_ATTRIBUTE2
            , x_line_tbl(i).RETURN_ATTRIBUTE3
            , x_line_tbl(i).RETURN_ATTRIBUTE4
            , x_line_tbl(i).RETURN_ATTRIBUTE5
            , x_line_tbl(i).RETURN_ATTRIBUTE6
            , x_line_tbl(i).RETURN_ATTRIBUTE7
            , x_line_tbl(i).RETURN_ATTRIBUTE8
            , x_line_tbl(i).RETURN_ATTRIBUTE9
            , x_line_tbl(i).RETURN_CONTEXT
            , x_line_tbl(i).RETURN_REASON_CODE
            , x_line_tbl(i).RLA_SCHEDULE_TYPE_CODE
            , x_line_tbl(i).SALESREP_ID
            , x_line_tbl(i).SCHEDULE_ARRIVAL_DATE
            , x_line_tbl(i).SCHEDULE_SHIP_DATE
            , x_line_tbl(i).SCHEDULE_STATUS_CODE
            , x_line_tbl(i).SHIPMENT_NUMBER
            , x_line_tbl(i).SHIPMENT_PRIORITY_CODE
            , x_line_tbl(i).SHIPPED_QUANTITY
            , x_line_tbl(i).SHIPPED_QUANTITY2 -- OPM B1661023 04/02/01
            , x_line_tbl(i).SHIPPING_METHOD_CODE
            , x_line_tbl(i).SHIPPING_QUANTITY
            , x_line_tbl(i).SHIPPING_QUANTITY2 -- OPM B1661023 04/02/01
            , x_line_tbl(i).SHIPPING_QUANTITY_UOM
            , x_line_tbl(i).SHIPPING_QUANTITY_UOM2
            , x_line_tbl(i).SHIP_FROM_ORG_ID
            , x_line_tbl(i).SUBINVENTORY
            , x_line_tbl(i).SHIP_SET_ID
            , x_line_tbl(i).SHIP_TOLERANCE_ABOVE
            , x_line_tbl(i).SHIP_TOLERANCE_BELOW
            , x_line_tbl(i).SHIPPABLE_FLAG
            , x_line_tbl(i).SHIPPING_INTERFACED_FLAG
            , x_line_tbl(i).SHIP_TO_CONTACT_ID
            , x_line_tbl(i).SHIP_TO_ORG_ID
            , x_line_tbl(i).SHIP_MODEL_COMPLETE_FLAG
            , x_line_tbl(i).SOLD_TO_ORG_ID
            , x_line_tbl(i).SOLD_FROM_ORG_ID
            , x_line_tbl(i).SORT_ORDER
            , x_line_tbl(i).SOURCE_DOCUMENT_ID
            , x_line_tbl(i).SOURCE_DOCUMENT_LINE_ID
            , x_line_tbl(i).SOURCE_DOCUMENT_TYPE_ID
            , x_line_tbl(i).SOURCE_TYPE_CODE
            , x_line_tbl(i).SPLIT_FROM_LINE_ID
            , x_line_tbl(i).LINE_SET_ID
            , x_line_tbl(i).SPLIT_BY
            , x_line_tbl(i).MODEL_REMNANT_FLAG
            , x_line_tbl(i).TASK_ID
            , x_line_tbl(i).TAX_CODE
            , x_line_tbl(i).TAX_DATE
            , x_line_tbl(i).TAX_EXEMPT_FLAG
            , x_line_tbl(i).TAX_EXEMPT_NUMBER
            , x_line_tbl(i).TAX_EXEMPT_REASON_CODE
            , x_line_tbl(i).TAX_POINT_CODE
            , x_line_tbl(i).TAX_RATE
            , x_line_tbl(i).TAX_VALUE
            , x_line_tbl(i).TOP_MODEL_LINE_ID
            , x_line_tbl(i).UNIT_LIST_PRICE
            , x_line_tbl(i).UNIT_LIST_PRICE_PER_PQTY
            , x_line_tbl(i).UNIT_SELLING_PRICE
            , x_line_tbl(i).UNIT_SELLING_PRICE_PER_PQTY
            , x_line_tbl(i).VISIBLE_DEMAND_FLAG
            , x_line_tbl(i).VEH_CUS_ITEM_CUM_KEY_ID
            , x_line_tbl(i).SHIPPING_INSTRUCTIONS
            , x_line_tbl(i).PACKING_INSTRUCTIONS
            , x_line_tbl(i).SERVICE_TXN_REASON_CODE
            , x_line_tbl(i).SERVICE_TXN_COMMENTS
            , x_line_tbl(i).SERVICE_DURATION
            , x_line_tbl(i).SERVICE_PERIOD
            , x_line_tbl(i).SERVICE_START_DATE
            , x_line_tbl(i).SERVICE_END_DATE
            , x_line_tbl(i).SERVICE_COTERMINATE_FLAG
            , x_line_tbl(i).UNIT_LIST_PERCENT
            , x_line_tbl(i).UNIT_SELLING_PERCENT
            , x_line_tbl(i).UNIT_PERCENT_BASE_PRICE
            , x_line_tbl(i).SERVICE_NUMBER
            , x_line_tbl(i).SERVICE_REFERENCE_TYPE_CODE
            , x_line_tbl(i).SERVICE_REFERENCE_LINE_ID
            , x_line_tbl(i).SERVICE_REFERENCE_SYSTEM_ID
            , x_line_tbl(i).TP_CONTEXT
            , x_line_tbl(i).TP_ATTRIBUTE1
            , x_line_tbl(i).TP_ATTRIBUTE2
            , x_line_tbl(i).TP_ATTRIBUTE3
            , x_line_tbl(i).TP_ATTRIBUTE4
            , x_line_tbl(i).TP_ATTRIBUTE5
            , x_line_tbl(i).TP_ATTRIBUTE6
            , x_line_tbl(i).TP_ATTRIBUTE7
            , x_line_tbl(i).TP_ATTRIBUTE8
            , x_line_tbl(i).TP_ATTRIBUTE9
            , x_line_tbl(i).TP_ATTRIBUTE10
            , x_line_tbl(i).TP_ATTRIBUTE11
            , x_line_tbl(i).TP_ATTRIBUTE12
            , x_line_tbl(i).TP_ATTRIBUTE13
            , x_line_tbl(i).TP_ATTRIBUTE14
            , x_line_tbl(i).TP_ATTRIBUTE15
            , x_line_tbl(i).FLOW_STATUS_CODE
            , x_line_tbl(i).MARKETING_SOURCE_CODE_ID
            , x_line_tbl(i).CALCULATE_PRICE_FLAG
            , x_line_tbl(i).COMMITMENT_ID
            , x_line_tbl(i).ORDER_SOURCE_ID        -- aksingh
            , x_line_tbl(i).UPGRADED_FLAG
            , x_line_tbl(i).ORIGINAL_INVENTORY_ITEM_ID
            , x_line_tbl(i).ORIGINAL_ITEM_IDENTIFIER_TYPE
            , x_line_tbl(i).ORIGINAL_ORDERED_ITEM_ID
            , x_line_tbl(i).ORIGINAL_ORDERED_ITEM
            , x_line_tbl(i).ITEM_RELATIONSHIP_TYPE
            , x_line_tbl(i).ITEM_SUBSTITUTION_TYPE_CODE
            , x_line_tbl(i).LATE_DEMAND_PENALTY_FACTOR
            , x_line_tbl(i).OVERRIDE_ATP_DATE_CODE
            , x_line_tbl(i).FIRM_DEMAND_FLAG
            , x_line_tbl(i).EARLIEST_SHIP_DATE
            , x_line_tbl(i).USER_ITEM_DESCRIPTION
            , x_line_tbl(i).BLANKET_NUMBER
            , x_line_tbl(i).BLANKET_LINE_NUMBER
            , x_line_tbl(i).BLANKET_VERSION_NUMBER
            , x_line_tbl(i).UNIT_COST
            , x_line_tbl(i).LOCK_CONTROL
            , l_opn    --OPN
            , l_cpn    --CPN
            , l_svn    --SVN
            , x_line_tbl(i).CHANGE_SEQUENCE
            , x_line_tbl(i).transaction_phase_code
            , x_line_tbl(i).source_document_version_number
            , x_line_tbl(i).MINISITE_ID
            , x_line_tbl(i).Ib_Owner
            , x_line_tbl(i).Ib_installed_at_location
            , x_line_tbl(i).Ib_current_location
            , x_line_tbl(i).End_customer_ID
            , x_line_tbl(i).End_customer_contact_ID
            , x_line_tbl(i).End_customer_site_use_ID
            , x_line_tbl(i).RETROBILL_REQUEST_ID
            , x_line_tbl(i).ORIGINAL_LIST_PRICE  -- Override List Price
            , x_line_tbl(i).order_firmed_date
            , x_line_tbl(i).actual_fulfillment_date
            , x_line_tbl(i).charge_periodicity_code
            , x_line_tbl(i).cancelled_quantity2
            , x_line_tbl(i).fulfilled_quantity2
            , x_line_tbl(i).CONTINGENCY_ID
            , x_line_tbl(i).REVREC_EVENT_CODE
            , x_line_tbl(i).REVREC_EXPIRATION_DAYS
            , x_line_tbl(i).ACCEPTED_QUANTITY
            , x_line_tbl(i).REVREC_COMMENTS
            , x_line_tbl(i).REVREC_SIGNATURE
            , x_line_tbl(i).REVREC_SIGNATURE_DATE
            , x_line_tbl(i).ACCEPTED_BY
            , x_line_tbl(i).REVREC_REFERENCE_DOCUMENT
            , x_line_tbl(i).REVREC_IMPLICIT_FLAG;

            EXIT WHEN l_line_csr_s%NOTFOUND;

        ELSE
          EXIT;
        END IF;

        IF NOT OE_FEATURES_PVT.Is_Margin_Avail Then
            x_line_tbl(i).unit_cost:= NULL;
        END IF;


	   -- set values for non-DB fields
        x_line_tbl(i).db_flag 		:= FND_API.G_TRUE;
        x_line_tbl(i).operation 		:= FND_API.G_MISS_CHAR;
        x_line_tbl(i).return_status 	:= FND_API.G_MISS_CHAR;
        x_line_tbl(i).schedule_action_code 	:= FND_API.G_MISS_CHAR;
        x_line_tbl(i).reserved_quantity 	:= FND_API.G_MISS_NUM;
        x_line_tbl(i).reserved_quantity2 	:= FND_API.G_MISS_NUM; -- INVCONV
        x_line_tbl(i).change_reason 		:= FND_API.G_MISS_CHAR;
        x_line_tbl(i).change_comments 		:= FND_API.G_MISS_CHAR;
        x_line_tbl(i).arrival_set 		:= FND_API.G_MISS_CHAR;
        x_line_tbl(i).ship_set 			:= FND_API.G_MISS_CHAR;
        x_line_tbl(i).fulfillment_set 		:= FND_API.G_MISS_CHAR;
        x_line_tbl(i).split_action_code 	:= FND_API.G_MISS_CHAR;

        i := i + 1;

    END LOOP;

    IF l_entity = 2 THEN
        CLOSE l_line_csr_h;
    ELSIF l_entity = 3 THEN
        CLOSE l_line_csr_s;
    END IF;

    --  PK sent and no rows found

    IF
    (p_line_id IS NOT NULL
     AND
     p_line_id <> FND_API.G_MISS_NUM)
    AND
    (x_line_tbl.COUNT = 0)
    THEN
        RAISE NO_DATA_FOUND;
    END IF;


    --  Return fetched table
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('Exiting OE_LINE_UTIL.QUERY_ROWS', 1);
    END IF;

EXCEPTION

    WHEN NO_DATA_FOUND THEN
        IF l_debug_level  > 0 THEN
           oe_debug_pub.add('Inside no data found ', 1);
        END IF;

	   RAISE NO_DATA_FOUND;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        IF l_debug_level  > 0 THEN
           oe_debug_pub.add('Inside Unexpected error ', 1);
        END IF;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
          ,   'Query_Rows'
            );
        END IF;
        IF l_debug_level  > 0 THEN
           oe_debug_pub.add('Inside Others Exception ', 1);
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Query_Rows;


/*----------------------------------------------------------
 Procedure  lock_Row

 lock by ID or value will be decided by, if lock_control is
 passed or not. we are doing this so that other products, can
 still call lock_order API which does not take only primary
 key and takes only entire records. However if they do not
 set lokc_control on rec, we will still lock by ID that way
 they do not need to query up the records before sending them
 in. OM calls can directly fo to util.lock row, thus can send
 only line_id.
-----------------------------------------------------------*/

PROCEDURE Lock_Row
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_x_line_rec                    IN OUT NOCOPY  OE_Order_PUB.Line_Rec_Type
,   p_line_id			           IN  NUMBER
					               := FND_API.G_MISS_NUM
)
IS
l_line_id		      NUMBER;
l_top_model_line_id           NUMBER;
l_dummy                       NUMBER;
l_lock_control                NUMBER;
l_db_lock_control             NUMBER;
CAN_NOT_LOCK_MODEL            EXCEPTION;
/* bug 4344310 */
CURSOR C_Lock (c_top_model_line_id  NUMBER ,
	        c_line_id  NUMBER ) IS
SELECT line_id ,lock_control
FROM oe_order_lines_all
WHERE line_id IN (c_top_model_line_id, c_line_id)
FOR UPDATE NOWAIT ;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('Entering OE_LINE_UTIL.LOCK_ROW', 1);
    END IF;

    SAVEPOINT Lock_Row;

    l_lock_control := NULL;

    -- if l_lock_control is NULL, lock by ID.
    -- Retrieve the primary key.

    IF p_line_id <> FND_API.G_MISS_NUM THEN
	l_line_id := p_line_id;
        IF (OE_GLOBALS.G_UI_FLAG) THEN  -- 3025978
            l_lock_control := p_x_line_rec.lock_control;
        END IF;
    ELSE
	l_line_id := p_x_line_rec.line_id;
        l_lock_control := p_x_line_rec.lock_control;
        IF l_debug_level  > 0 THEN
           oe_debug_pub.add('in lock_control: '|| l_lock_control, 1);
        END IF;
    END IF;

    -- this code is for configurations. Whenever someone
    -- tries to modify an option line, we try to get a
    -- lock on the model line by ID.
    -- if we can get a lock on the model,
    -- this user can modify the configuration by
    -- changing any options. IF we can not get a
    -- lock on the model, that means some other person
    -- is already working on the configuration.
    -- in this case, we will give a message to the user
    -- to try his modifications later and that he should
    -- query lines to see latest changes.

    --changes for bug 4344310
   /* IF p_line_id <> FND_API.G_MISS_NUM THEN

      SELECT top_model_line_id
      INTO l_top_model_line_id
      FROM OE_ORDER_LINES_ALL  -- Fix for FP bug 3391622
      WHERE line_id = l_line_id;
    ELSE
      l_top_model_line_id := p_x_line_rec.top_model_line_id;
    END IF; */
      IF p_x_line_rec.top_model_line_id <> FND_API.G_MISS_NUM
		AND
       p_x_line_rec.top_model_line_id is not null THEN
           l_top_model_line_id := p_x_line_rec.top_model_line_id;
	   IF l_debug_level  > 0 THEN
	     oe_debug_pub.add('get top_model_line_id from the record' );
	   END IF ;
    ELSE
       SELECT top_model_line_id
       INTO l_top_model_line_id
       FROM OE_ORDER_LINES_ALL  -- Fix for FP bug 3391622
       WHERE line_id = l_line_id;

	 IF l_debug_level  > 0 THEN
	   oe_debug_pub.add('get top_model_line_id from the query' );
	 END IF ;
   END IF;
  -- end bug 4344310

    IF l_debug_level  > 0 THEN
       oe_debug_pub.add('got top model line id', 1);
    END IF;

    BEGIN

      IF l_top_model_line_id IS NOT NULL AND
         l_top_model_line_id <> FND_API.G_MISS_NUM AND
         l_top_model_line_id <> l_line_id THEN

         IF l_debug_level  > 0 THEN
            oe_debug_pub.add('trying to lock model: '|| p_line_id, 1);
         END IF;

	 -- changes for bug 4344310
        /* SELECT line_id
         INTO   l_dummy
         FROM   oe_order_lines_all
         WHERE  line_id = l_top_model_line_id
         FOR UPDATE NOWAIT; */

	 FOR I IN c_lock(l_top_model_line_id ,l_line_id ) LOOP
           if I.line_id =l_line_id then
		  l_line_id := I.line_id ;
                  l_db_lock_control := I.lock_control ;
           end if;
	END LOOP ;

     ELSE
	    SELECT line_id,lock_control
	    INTO   l_line_id,l_db_lock_control
	    FROM   oe_order_lines_all
	    WHERE  line_id = l_line_id
	    FOR UPDATE NOWAIT;
      END IF;
      --end bug 4344310
         IF l_debug_level  > 0 THEN
            oe_debug_pub.add('lock model successful ', 1);
         END IF;

    EXCEPTION

       WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN
         -- some one else is currently working on this model
         IF l_debug_level  > 0 THEN
            oe_debug_pub.add('in lock model exception');
         END IF;

         FND_MESSAGE.Set_Name('ONT', 'OE_LINE_LOCKED');
         OE_MSG_PUB.Add;

         RAISE CAN_NOT_LOCK_MODEL;

       WHEN NO_DATA_FOUND THEN
           IF l_debug_level  > 0 THEN
              oe_debug_pub.add('no_data_found, model lock exception');
           END IF;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

       WHEN OTHERS THEN
           IF l_debug_level  > 0 THEN
              oe_debug_pub.add('model lock exception, others');
              oe_debug_pub.add('options: '|| l_line_id , 1);
              oe_debug_pub.add('lock model successful: '|| l_top_model_line_id, 1);
           END IF;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END;


    IF l_debug_level  > 0 THEN
       oe_debug_pub.add(' ', 1);
    END IF;

    --commented out for bug 4344310
    /*SELECT line_id,lock_control
    INTO   l_line_id,l_db_lock_control
    FROM   oe_order_lines_all
    WHERE  line_id = l_line_id
    FOR UPDATE NOWAIT; */

    IF l_debug_level  > 0 THEN
       oe_debug_pub.add('selected for update', 1);
       oe_debug_pub.add('queried lock_control: '|| l_db_lock_control, 1);
    END IF;

    IF l_lock_control IS NULL
    OR (l_lock_control <> l_db_lock_control)
    OR (OE_GLOBALS.G_UI_FLAG = TRUE ) THEN  -- 3025978

        oe_line_util.Query_Row
	    (p_line_id  => l_line_id
	    ,x_line_rec => p_x_line_rec
        );

   END IF;

    IF l_debug_level  > 0 THEN
       oe_debug_pub.add('queried lock_control: '|| p_x_line_rec.lock_control, 1);
    END IF;

    -- If lock_control is not passed(is null or missing), then return the locked record.


    IF l_lock_control is null OR
       l_lock_control = FND_API.G_MISS_NUM
    THEN

        --  Set return status
        x_return_status                := FND_API.G_RET_STS_SUCCESS;
        p_x_line_rec.return_status     := FND_API.G_RET_STS_SUCCESS;

        -- return for lock by ID.
	RETURN;

    END IF;

    --  Row locked. If the whole record is passed, then
    --  Compare IN attributes to DB attributes.

    IF l_debug_level  > 0 THEN
       oe_debug_pub.add('compare ', 1);
    END IF;

-- following constants are used to debug lock_order,
-- please do not use them for any other purpose.
-- set G_LOCK_TEST := 'Y', for debugging.

    OE_GLOBALS.G_LOCK_CONST := 0;
    --OE_GLOBALS.G_LOCK_TEST := 'Y';
    OE_GLOBALS.G_LOCK_TEST := 'N';

    IF      OE_GLOBALS.Equal(p_x_line_rec.lock_control,
                             l_lock_control)
   THEN

        --  Row has not changed. Set out parameter.

        IF l_debug_level  > 0 THEN
           oe_debug_pub.add('locked row', 1);
        END IF;

        --  Set return status

        x_return_status                := FND_API.G_RET_STS_SUCCESS;
        p_x_line_rec.return_status       := FND_API.G_RET_STS_SUCCESS;

    ELSE

        --  Row has changed by another user.
        IF l_debug_level  > 0 THEN
           oe_debug_pub.add('row changed by other user', 1);
        END IF;

        x_return_status                := FND_API.G_RET_STS_ERROR;
        p_x_line_rec.return_status       := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            -- Release the lock
            ROLLBACK TO Lock_Row;

            fnd_message.set_name('ONT','OE_LOCK_ROW_CHANGED');
            OE_MSG_PUB.Add;

        END IF;

    END IF;

    OE_GLOBALS.G_LOCK_TEST := 'N';

    IF l_debug_level  > 0 THEN
       oe_debug_pub.add('Exiting OE_LINE_UTIL.LOCK_ROW', 1);
       oe_debug_pub.add(' ', 1);
       oe_debug_pub.add('lock const: '|| oe_globals.g_lock_const, 1);
    END IF;

EXCEPTION

    WHEN CAN_NOT_LOCK_MODEL THEN
        OE_GLOBALS.G_LOCK_TEST := 'N';
        IF l_debug_level  > 0 THEN
           oe_debug_pub.add('model locking exception', 1);
        END IF;
        x_return_status                := FND_API.G_RET_STS_ERROR;
        p_x_line_rec.return_status       := FND_API.G_RET_STS_ERROR;


    WHEN NO_DATA_FOUND THEN
        OE_GLOBALS.G_LOCK_TEST := 'N';
        x_return_status                := FND_API.G_RET_STS_ERROR;
        p_x_line_rec.return_status       := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_LOCK_ROW_DELETED');
            OE_MSG_PUB.Add;

        END IF;
    WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN
        OE_GLOBALS.G_LOCK_TEST := 'N';
        x_return_status                := FND_API.G_RET_STS_ERROR;
        p_x_line_rec.return_status       := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_LOCK_ROW_ALREADY_LOCKED');
            OE_MSG_PUB.Add;

        END IF;
    WHEN OTHERS THEN
        OE_GLOBALS.G_LOCK_TEST := 'N';
        x_return_status                := FND_API.G_RET_STS_UNEXP_ERROR;
        p_x_line_rec.return_status       := FND_API.G_RET_STS_UNEXP_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
          ,   'Lock_Row'
            );
        END IF;

END Lock_Row;


/*----------------------------------------------------------
 Procedure  lock_Rows
-----------------------------------------------------------*/

PROCEDURE Lock_Rows
(   p_line_id                       IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_header_id                     IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   x_line_tbl                      OUT NOCOPY OE_Order_PUB.Line_Tbl_Type
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
 )
IS
  CURSOR lock_lines(p_header_id  NUMBER) IS
  SELECT line_id
  FROM   oe_order_lines_all
  WHERE  header_id = p_header_id
    FOR  UPDATE NOWAIT;

l_line_id    NUMBER;

l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

    IF (p_line_id IS NOT NULL AND
        p_line_id <> FND_API.G_MISS_NUM) AND
       (p_header_id IS NOT NULL AND
        p_header_id <> FND_API.G_MISS_NUM)
    THEN
      IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        OE_MSG_PUB.Add_Exc_Msg
        (   G_PKG_NAME
        , 'Lock Rows'
        , 'Keys are mutually exclusive: line_id = '||
             p_line_id || ', header_id = '|| p_header_id );
      END IF;

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;

   IF p_line_id <> FND_API.G_MISS_NUM THEN

     SELECT line_id
     INTO   l_line_id
     FROM   OE_ORDER_LINES_ALL
     WHERE  line_id   = p_line_id
     FOR UPDATE NOWAIT;

   END IF;

   -- people should not pass in null header_id unnecessarily,
   -- if they already passed in line_id.

   BEGIN

     IF p_header_id <> FND_API.G_MISS_NUM THEN

       SAVEPOINT LOCK_ROWS;

       OPEN lock_lines(p_header_id);
       LOOP
         FETCH lock_lines INTO l_line_id;
         EXIT WHEN lock_lines%NOTFOUND;
       END LOOP;
       CLOSE lock_lines;

     END IF;

   EXCEPTION
     WHEN OTHERS THEN
       ROLLBACK TO LOCK_ROWS;

       IF lock_lines%ISOPEN THEN
         CLOSE lock_lines;
       END IF;

       RAISE;
   END;

   -- locked all lines

   oe_line_util.Query_Rows
     (p_line_id          => p_line_id
     ,p_header_id        => p_header_id
     ,x_line_tbl         => x_line_tbl
     );

  IF l_debug_level  > 0 THEN
   oe_debug_pub.add('Entering OE_LINE_UTIL.QUERY_ROWS', 1);
  END IF;

   x_return_status  := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
   WHEN NO_DATA_FOUND THEN

     x_return_status                := FND_API.G_RET_STS_ERROR;

     IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
     THEN
       fnd_message.set_name('ONT','OE_LOCK_ROW_DELETED');
       OE_MSG_PUB.Add;
     END IF;

    WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN

      x_return_status                := FND_API.G_RET_STS_ERROR;
      IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
      THEN
        fnd_message.set_name('ONT','OE_LOCK_ROW_ALREADY_LOCKED');
        OE_MSG_PUB.Add;
      END IF;

    WHEN OTHERS THEN

        x_return_status                := FND_API.G_RET_STS_UNEXP_ERROR;

      IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        OE_MSG_PUB.Add_Exc_Msg
        (   G_PKG_NAME
       ,   'Lock_Row'
        );
      END IF;
END Lock_Rows;


/*----------------------------------------------------------
 Function Get_Values
-----------------------------------------------------------*/

FUNCTION Get_Values
(   p_line_rec                      IN  OE_Order_PUB.Line_Rec_Type
,   p_old_line_rec                  IN  OE_Order_PUB.Line_Rec_Type :=
                                        OE_Order_PUB.G_MISS_LINE_REC
) RETURN OE_Order_PUB.Line_Val_Rec_Type
IS
l_customer_number         	VARCHAR2(30);
l_line_val_rec                OE_Order_PUB.Line_Val_Rec_Type;
l_organization_id NUMBER :=  OE_SYS_PARAMETERS.VALUE('MASTER_ORGANIZATION_ID');

l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

  if l_debug_level > 0 then
    OE_DEBUG_PUB.add('Entering OE_LINE_UTIL.Get_Values');
  end if;

    IF (p_line_rec.calculate_price_flag IS NULL OR
        p_line_rec.calculate_price_flag <> FND_API.G_MISS_CHAR) AND
        NOT OE_GLOBALS.Equal(p_line_rec.calculate_price_flag,
        p_old_line_rec.calculate_price_flag)
    THEN
  l_line_val_rec.calculate_price_descr := OE_Id_To_Value.Calculate_price_Flag (   p_calculate_price_flag          => p_line_rec.calculate_price_flag
        );

          if l_debug_level > 0 then
	   oe_debug_pub.add('Geresh ' || l_line_val_rec.calculate_price_descr );
          end if;
    END IF;


    IF (p_line_rec.accounting_rule_id IS NULL OR
        p_line_rec.accounting_rule_id <> FND_API.G_MISS_NUM) AND
        NOT OE_GLOBALS.Equal(p_line_rec.accounting_rule_id,
        p_old_line_rec.accounting_rule_id)
    THEN
        l_line_val_rec.accounting_rule := OE_Id_To_Value.Accounting_Rule
        (   p_accounting_rule_id          => p_line_rec.accounting_rule_id
        );
    END IF;

    IF (p_line_rec.agreement_id IS NULL OR
        p_line_rec.agreement_id <> FND_API.G_MISS_NUM) AND
        NOT OE_GLOBALS.Equal(p_line_rec.agreement_id,
        p_old_line_rec.agreement_id)
    THEN
        l_line_val_rec.agreement := OE_Id_To_Value.Agreement
        (   p_agreement_id                => p_line_rec.agreement_id
        );
    END IF;

    IF (p_line_rec.deliver_to_contact_id IS NULL OR
        p_line_rec.deliver_to_contact_id <> FND_API.G_MISS_NUM) AND
        NOT OE_GLOBALS.Equal(p_line_rec.deliver_to_contact_id,
        p_old_line_rec.deliver_to_contact_id)
    THEN
        l_line_val_rec.deliver_to_contact := OE_Id_To_Value.Deliver_To_Contact
        (   p_deliver_to_contact_id       => p_line_rec.deliver_to_contact_id
        );
    END IF;

    IF (p_line_rec.deliver_to_org_id IS NULL OR
        p_line_rec.deliver_to_org_id <> FND_API.G_MISS_NUM) AND
        NOT OE_GLOBALS.Equal(p_line_rec.deliver_to_org_id,
        p_old_line_rec.deliver_to_org_id)
    THEN
        get_customer_details
        (   p_org_id             => p_line_rec.deliver_to_org_id
      ,   p_site_use_code      =>'DELIVER_TO'
      ,   x_customer_name      => l_line_val_rec.deliver_to_customer_name
      ,   x_customer_number    => l_line_val_rec.deliver_to_customer_number
      ,   x_customer_id        => l_line_val_rec.deliver_to_customer_id
      ,   x_location        => l_line_val_rec.deliver_to_location
      ,   x_address1        => l_line_val_rec.deliver_to_address1
      ,   x_address2        => l_line_val_rec.deliver_to_address2
      ,   x_address3        => l_line_val_rec.deliver_to_address3
      ,   x_address4        => l_line_val_rec.deliver_to_address4
      ,   x_city        => l_line_val_rec.deliver_to_city
      ,   x_state        => l_line_val_rec.deliver_to_state
      ,   x_zip        => l_line_val_rec.deliver_to_zip
      ,   x_country        => l_line_val_rec.deliver_to_country
        );
        l_line_val_rec.deliver_to_org :=l_line_val_rec.deliver_to_location;

    END IF;

    IF (p_line_rec.demand_bucket_type_code IS NULL OR
        p_line_rec.demand_bucket_type_code <> FND_API.G_MISS_CHAR) AND
        NOT OE_GLOBALS.Equal(p_line_rec.demand_bucket_type_code,
        p_old_line_rec.demand_bucket_type_code)
    THEN
        l_line_val_rec.demand_bucket_type := OE_Id_To_Value.Demand_Bucket_Type
        (   p_demand_bucket_type_code     => p_line_rec.demand_bucket_type_code
        );
    END IF;

    IF (p_line_rec.fob_point_code IS NULL OR
        p_line_rec.fob_point_code <> FND_API.G_MISS_CHAR) AND
        NOT OE_GLOBALS.Equal(p_line_rec.fob_point_code,
        p_old_line_rec.fob_point_code)
    THEN
        l_line_val_rec.fob_point := OE_Id_To_Value.Fob_Point
        (   p_fob_point_code              => p_line_rec.fob_point_code
        );
    END IF;

    IF (p_line_rec.freight_terms_code IS NULL OR
        p_line_rec.freight_terms_code <> FND_API.G_MISS_CHAR) AND
        NOT OE_GLOBALS.Equal(p_line_rec.freight_terms_code,
        p_old_line_rec.freight_terms_code)
    THEN
        l_line_val_rec.freight_terms := OE_Id_To_Value.Freight_Terms
        (   p_freight_terms_code          => p_line_rec.freight_terms_code
        );
    END IF;

    IF (p_line_rec.freight_carrier_code IS NULL OR
        p_line_rec.freight_carrier_code <> FND_API.G_MISS_CHAR) AND
        NOT OE_GLOBALS.Equal(p_line_rec.freight_carrier_code,
        p_old_line_rec.freight_carrier_code)
    THEN
        l_line_val_rec.freight_carrier := OE_Id_To_Value.Freight_Carrier
        (   p_freight_carrier_code          => p_line_rec.freight_carrier_code
	   ,   p_ship_from_org_id		    => p_line_rec.ship_from_org_id
        );
    END IF;
    IF (p_line_rec.shipping_method_code IS NULL OR
        p_line_rec.shipping_method_code <> FND_API.G_MISS_CHAR) AND
        NOT OE_GLOBALS.Equal(p_line_rec.shipping_method_code,
        p_old_line_rec.shipping_method_code)
    THEN
        l_line_val_rec.shipping_method := OE_Id_To_Value.ship_method
        (   p_ship_method_code      => p_line_rec.shipping_method_code
        );
    END IF;

    IF (p_line_rec.intermed_ship_to_contact_id IS NULL OR
        p_line_rec.intermed_ship_to_contact_id <> FND_API.G_MISS_NUM) AND
        NOT OE_GLOBALS.Equal(p_line_rec.intermed_ship_to_contact_id,
        p_old_line_rec.intermed_ship_to_contact_id)
    THEN
       l_line_val_rec.intermed_ship_to_contact := OE_Id_To_Value.Intermed_Ship_To_Contact
        (   p_intermed_ship_to_contact_id       => p_line_rec.intermed_ship_to_contact_id
        );
    END IF;

/*1621182*/
    IF (p_line_rec.intermed_ship_to_org_id IS NULL OR
        p_line_rec.intermed_ship_to_org_id <> FND_API.G_MISS_NUM) AND
        NOT OE_GLOBALS.Equal(p_line_rec.intermed_ship_to_org_id,
        p_old_line_rec.intermed_ship_to_org_id)
    THEN
        OE_Id_To_Value.Intermed_Ship_To_Org
        (   p_intermed_ship_to_org_id      => p_line_rec.intermed_ship_to_org_id
      ,   x_intermed_ship_to_address1    => l_line_val_rec.intermed_ship_to_address1
      ,   x_intermed_ship_to_address2    => l_line_val_rec.intermed_ship_to_address2
      ,   x_intermed_ship_to_address3    => l_line_val_rec.intermed_ship_to_address3
      ,   x_intermed_ship_to_address4    => l_line_val_rec.intermed_ship_to_address4
      ,   x_intermed_ship_to_location    => l_line_val_rec.intermed_ship_to_location
      ,   x_intermed_ship_to_org         => l_line_val_rec.intermed_ship_to_org
      ,   x_intermed_ship_to_city        => l_line_val_rec.intermed_ship_to_city
      ,   x_intermed_ship_to_state       => l_line_val_rec.intermed_ship_to_state
      ,   x_intermed_ship_to_postal_code => l_line_val_rec.intermed_ship_to_zip
      ,   x_intermed_ship_to_country     => l_line_val_rec.intermed_ship_to_country
        );
    END IF;
/*1621182*/

    IF (p_line_rec.inventory_item_id IS NULL OR
        p_line_rec.inventory_item_id <> FND_API.G_MISS_NUM) AND
        NOT OE_GLOBALS.Equal(p_line_rec.inventory_item_id,
        p_old_line_rec.inventory_item_id)
    THEN
        l_line_val_rec.inventory_item := OE_Id_To_Value.Inventory_Item
        (   p_inventory_item_id           => p_line_rec.inventory_item_id
        );
    END IF;

    IF (p_line_rec.invoice_to_contact_id IS NULL OR
        p_line_rec.invoice_to_contact_id <> FND_API.G_MISS_NUM) AND
        NOT OE_GLOBALS.Equal(p_line_rec.invoice_to_contact_id,
        p_old_line_rec.invoice_to_contact_id)
    THEN
        l_line_val_rec.invoice_to_contact := OE_Id_To_Value.Invoice_To_Contact
        (   p_invoice_to_contact_id       => p_line_rec.invoice_to_contact_id
        );
    END IF;

    IF (p_line_rec.invoice_to_org_id IS NULL OR
        p_line_rec.invoice_to_org_id <> FND_API.G_MISS_NUM) AND
        NOT OE_GLOBALS.Equal(p_line_rec.invoice_to_org_id,
        p_old_line_rec.invoice_to_org_id)
    THEN

        get_customer_details
        (   p_org_id             => p_line_rec.invoice_to_org_id
      ,   p_site_use_code      =>'BILL_TO'
      ,   x_customer_name      => l_line_val_rec.invoice_to_customer_name
      ,   x_customer_number    => l_line_val_rec.invoice_to_customer_number
      ,   x_customer_id        => l_line_val_rec.invoice_to_customer_id
      ,   x_location        => l_line_val_rec.invoice_to_location
      ,   x_address1        => l_line_val_rec.invoice_to_address1
      ,   x_address2        => l_line_val_rec.invoice_to_address2
      ,   x_address3        => l_line_val_rec.invoice_to_address3
      ,   x_address4        => l_line_val_rec.invoice_to_address4
      ,   x_city        => l_line_val_rec.invoice_to_city
      ,   x_state        => l_line_val_rec.invoice_to_state
      ,   x_zip        => l_line_val_rec.invoice_to_zip
      ,   x_country        => l_line_val_rec.invoice_to_country
        );
        l_line_val_rec.invoice_to_org :=l_line_val_rec.invoice_to_location;

    END IF;

    IF (p_line_rec.invoicing_rule_id IS NULL OR
        p_line_rec.invoicing_rule_id <> FND_API.G_MISS_NUM) AND
        NOT OE_GLOBALS.Equal(p_line_rec.invoicing_rule_id,
        p_old_line_rec.invoicing_rule_id)
    THEN
        l_line_val_rec.invoicing_rule := OE_Id_To_Value.Invoicing_Rule
        (   p_invoicing_rule_id           => p_line_rec.invoicing_rule_id
        );
    END IF;

    IF (p_line_rec.item_type_code IS NULL OR
        p_line_rec.item_type_code <> FND_API.G_MISS_CHAR) AND
        NOT OE_GLOBALS.Equal(p_line_rec.item_type_code,
        p_old_line_rec.item_type_code)
    THEN
        l_line_val_rec.item_type := OE_Id_To_Value.Item_Type
        (   p_item_type_code              => p_line_rec.item_type_code
        );
    END IF;

    IF (p_line_rec.line_type_id IS NULL OR
        p_line_rec.line_type_id <> FND_API.G_MISS_NUM) AND
        NOT OE_GLOBALS.Equal(p_line_rec.line_type_id,
        p_old_line_rec.line_type_id)
    THEN
        l_line_val_rec.line_type := OE_Id_To_Value.Line_Type
        (   p_line_type_id                => p_line_rec.line_type_id
        );
    END IF;

    IF (p_line_rec.over_ship_reason_code IS NULL OR
        p_line_rec.over_ship_reason_code <> FND_API.G_MISS_CHAR) AND
        NOT OE_GLOBALS.Equal(p_line_rec.over_ship_reason_code,
        p_old_line_rec.over_ship_reason_code)
    THEN
        l_line_val_rec.over_ship_reason := OE_Id_To_Value.over_ship_reason
        (   p_over_ship_reason_code  => p_line_rec.over_ship_reason_code
        );
    END IF;

    IF (p_line_rec.payment_term_id IS NULL OR
        p_line_rec.payment_term_id <> FND_API.G_MISS_NUM) AND
        NOT OE_GLOBALS.Equal(p_line_rec.payment_term_id,
        p_old_line_rec.payment_term_id)
    THEN
        l_line_val_rec.payment_term := OE_Id_To_Value.Payment_Term
        (   p_payment_term_id             => p_line_rec.payment_term_id
        );
    END IF;

    IF (p_line_rec.price_list_id IS NULL OR
        p_line_rec.price_list_id <> FND_API.G_MISS_NUM) AND
        NOT OE_GLOBALS.Equal(p_line_rec.price_list_id,
        p_old_line_rec.price_list_id)
    THEN
        l_line_val_rec.price_list := OE_Id_To_Value.Price_List
        (   p_price_list_id               => p_line_rec.price_list_id
        );
    END IF;

    IF (p_line_rec.project_id IS NULL OR
        p_line_rec.project_id <> FND_API.G_MISS_NUM) AND
        NOT OE_GLOBALS.Equal(p_line_rec.project_id,
        p_old_line_rec.project_id)
    THEN
        l_line_val_rec.project := OE_Id_To_Value.Project
        (   p_project_id                  => p_line_rec.project_id
        );
    END IF;


    IF (p_line_rec.source_type_code IS NULL OR
        p_line_rec.source_type_code <> FND_API.G_MISS_CHAR) AND
        NOT OE_GLOBALS.Equal(p_line_rec.source_type_code,
        p_old_line_rec.source_type_code)
    THEN

        l_line_val_rec.source_type := OE_Id_To_Value.source_type
        (   p_source_type_code  => p_line_rec.source_type_code
        );
    END IF;


    IF (p_line_rec.return_reason_code IS NULL OR
        p_line_rec.return_reason_code <> FND_API.G_MISS_CHAR) AND
        NOT OE_GLOBALS.Equal(p_line_rec.return_reason_code,
        p_old_line_rec.return_reason_code)
    THEN

        l_line_val_rec.return_reason := OE_Id_To_Value.return_reason
        (   p_return_reason_code  => p_line_rec.return_reason_code
        );
    END IF;

    IF (p_line_rec.reference_line_id IS NULL OR
        p_line_rec.reference_line_id <> FND_API.G_MISS_NUM) AND
        NOT OE_GLOBALS.Equal(p_line_rec.reference_line_id,
        p_old_line_rec.reference_line_id)
    THEN
        OE_Id_To_Value.reference_line
        (   p_reference_line_id   => p_line_rec.reference_line_id
       ,  x_ref_order_number    => l_line_val_rec.ref_order_number
       ,  x_ref_line_number     => l_line_val_rec.ref_line_number
       ,  x_ref_shipment_number => l_line_val_rec.ref_shipment_number
       ,  x_ref_option_number   => l_line_val_rec.ref_option_number
       ,  x_ref_component_number => l_line_val_rec.ref_component_number
        );

    END IF;

    IF (p_line_rec.reference_customer_trx_line_id IS NULL OR
        p_line_rec.reference_customer_trx_line_id <> FND_API.G_MISS_NUM) AND
        NOT OE_GLOBALS.Equal(p_line_rec.reference_customer_trx_line_id,
        p_old_line_rec.reference_customer_trx_line_id)
    THEN
        OE_Id_To_Value.Reference_Cust_Trx_Line
        (   p_reference_cust_trx_line_id => p_line_rec.reference_customer_trx_line_id
       ,  x_ref_invoice_number        => l_line_val_rec.ref_invoice_number
       ,  x_ref_invoice_line_number   => l_line_val_rec.ref_invoice_line_number
        );
    END IF;

    IF (p_line_rec.credit_invoice_line_id IS NULL OR
        p_line_rec.credit_invoice_line_id <> FND_API.G_MISS_NUM) AND
        NOT OE_GLOBALS.Equal(p_line_rec.credit_invoice_line_id,
        p_old_line_rec.credit_invoice_line_id)
    THEN
        l_line_val_rec.credit_invoice_number
            := OE_Id_To_Value.credit_invoice_line
        (   p_credit_invoice_line_id   => p_line_rec.credit_invoice_line_id
        );
    END IF;

    IF (p_line_rec.rla_schedule_type_code IS NULL OR
        p_line_rec.rla_schedule_type_code <> FND_API.G_MISS_CHAR) AND
        NOT OE_GLOBALS.Equal(p_line_rec.rla_schedule_type_code,
        p_old_line_rec.rla_schedule_type_code)
    THEN
        l_line_val_rec.rla_schedule_type := OE_Id_To_Value.Rla_Schedule_Type
        (   p_rla_schedule_type_code      => p_line_rec.rla_schedule_type_code
        );
    END IF;

    IF (p_line_rec.salesrep_id IS NULL OR
        p_line_rec.salesrep_id <> FND_API.G_MISS_NUM) AND
        NOT OE_GLOBALS.Equal(p_line_rec.salesrep_id,
        p_old_line_rec.salesrep_id)
    THEN
        l_line_val_rec.salesrep := OE_Id_To_Value.salesrep
        (   p_salesrep_id          => p_line_rec.salesrep_id
        );
    END IF;

    IF (p_line_rec.commitment_id IS NULL OR
        p_line_rec.commitment_id <> FND_API.G_MISS_NUM) AND
        NOT OE_GLOBALS.Equal(p_line_rec.commitment_id,
        p_old_line_rec.commitment_id)
    THEN
        l_line_val_rec.commitment := OE_Id_To_Value.Commitment
        (   p_commitment_id        => p_line_rec.commitment_id
        );
    END IF;


    IF (p_line_rec.shipment_priority_code IS NULL OR
        p_line_rec.shipment_priority_code <> FND_API.G_MISS_CHAR) AND
        NOT OE_GLOBALS.Equal(p_line_rec.shipment_priority_code,
        p_old_line_rec.shipment_priority_code)
    THEN
        l_line_val_rec.shipment_priority := OE_Id_To_Value.Shipment_Priority
        (   p_shipment_priority_code      => p_line_rec.shipment_priority_code
        );
    END IF;

    IF (p_line_rec.demand_class_code IS NULL OR
        p_line_rec.demand_class_code <> FND_API.G_MISS_CHAR) AND
        NOT OE_GLOBALS.Equal(p_line_rec.demand_class_code,
        p_old_line_rec.demand_class_code)
    THEN
        l_line_val_rec.demand_class := OE_Id_To_Value.Demand_Class
        (   p_demand_class_code      => p_line_rec.demand_class_code
        );
    END IF;

    IF (p_line_rec.ship_from_org_id IS NULL OR
        p_line_rec.ship_from_org_id <> FND_API.G_MISS_NUM) AND
        NOT OE_GLOBALS.Equal(p_line_rec.ship_from_org_id,
        p_old_line_rec.ship_from_org_id)
    THEN
        OE_Id_To_Value.Ship_From_Org
        (   p_ship_from_org_id            => p_line_rec.ship_from_org_id
      ,   x_ship_from_address1          => l_line_val_rec.ship_from_address1
      ,   x_ship_from_address2          => l_line_val_rec.ship_from_address2
      ,   x_ship_from_address3          => l_line_val_rec.ship_from_address3
      ,   x_ship_from_address4          => l_line_val_rec.ship_from_address4
      ,   x_ship_from_location          => l_line_val_rec.ship_from_location
      ,   x_ship_from_org               => l_line_val_rec.ship_from_org
        );
    END IF;

    IF (p_line_rec.ship_to_contact_id IS NULL OR
        p_line_rec.ship_to_contact_id <> FND_API.G_MISS_NUM) AND
        NOT OE_GLOBALS.Equal(p_line_rec.ship_to_contact_id,
        p_old_line_rec.ship_to_contact_id)
    THEN
        l_line_val_rec.ship_to_contact := OE_Id_To_Value.Ship_To_Contact
        (   p_ship_to_contact_id          => p_line_rec.ship_to_contact_id
        );
    END IF;

    IF (p_line_rec.ship_to_org_id IS NULL OR
        p_line_rec.ship_to_org_id <> FND_API.G_MISS_NUM) AND
        NOT OE_GLOBALS.Equal(p_line_rec.ship_to_org_id,
        p_old_line_rec.ship_to_org_id)
    THEN
        get_customer_details
        (   p_org_id             => p_line_rec.ship_to_org_id
      ,   p_site_use_code      =>'SHIP_TO'
      ,   x_customer_name      => l_line_val_rec.ship_to_customer_name
      ,   x_customer_number    => l_line_val_rec.ship_to_customer_number
      ,   x_customer_id        => l_line_val_rec.ship_to_customer_id
      ,   x_location        => l_line_val_rec.ship_to_location
      ,   x_address1        => l_line_val_rec.ship_to_address1
      ,   x_address2        => l_line_val_rec.ship_to_address2
      ,   x_address3        => l_line_val_rec.ship_to_address3
      ,   x_address4        => l_line_val_rec.ship_to_address4
      ,   x_city        => l_line_val_rec.ship_to_city
      ,   x_state        => l_line_val_rec.ship_to_state
      ,   x_zip        => l_line_val_rec.ship_to_zip
      ,   x_country        => l_line_val_rec.ship_to_country
        );
        l_line_val_rec.ship_to_org :=l_line_val_rec.ship_to_location;

    END IF;


    IF (p_line_rec.sold_to_org_id IS NULL OR
        p_line_rec.sold_to_org_id <> FND_API.G_MISS_NUM) AND
        NOT OE_GLOBALS.Equal(p_line_rec.sold_to_org_id,
        p_old_line_rec.sold_to_org_id)
    THEN
        OE_Id_To_Value.Sold_To_Org
        (   p_sold_to_org_id              => p_line_rec.sold_to_org_id
      ,   x_org                         => l_line_val_rec.sold_to_org
      ,   x_customer_number             => l_customer_number
        );
    END IF;

    IF (p_line_rec.task_id IS NULL OR
        p_line_rec.task_id <> FND_API.G_MISS_NUM) AND
        NOT OE_GLOBALS.Equal(p_line_rec.task_id,
        p_old_line_rec.task_id)
    THEN
        l_line_val_rec.task := OE_Id_To_Value.Task
        (   p_task_id                     => p_line_rec.task_id
        );
    END IF;

    IF (p_line_rec.tax_exempt_flag IS NULL OR
        p_line_rec.tax_exempt_flag <> FND_API.G_MISS_CHAR) AND
        NOT OE_GLOBALS.Equal(p_line_rec.tax_exempt_flag,
        p_old_line_rec.tax_exempt_flag)
    THEN
        l_line_val_rec.tax_exempt := OE_Id_To_Value.Tax_Exempt
        (   p_tax_exempt_flag             => p_line_rec.tax_exempt_flag
        );
    END IF;

    IF (p_line_rec.tax_exempt_reason_code IS NULL OR
        p_line_rec.tax_exempt_reason_code <> FND_API.G_MISS_CHAR) AND
        NOT OE_GLOBALS.Equal(p_line_rec.tax_exempt_reason_code,
        p_old_line_rec.tax_exempt_reason_code)
    THEN
        l_line_val_rec.tax_exempt_reason := OE_Id_To_Value.Tax_Exempt_Reason
        (   p_tax_exempt_reason_code      => p_line_rec.tax_exempt_reason_code
        );
    END IF;

    IF (p_line_rec.tax_point_code IS NULL OR
        p_line_rec.tax_point_code <> FND_API.G_MISS_CHAR) AND
        NOT OE_GLOBALS.Equal(p_line_rec.tax_point_code,
        p_old_line_rec.tax_point_code)
    THEN
        l_line_val_rec.tax_point := OE_Id_To_Value.Tax_Point
        (   p_tax_point_code              => p_line_rec.tax_point_code
        );
    END IF;

    /*IF  (p_line_rec.tax_code IS NULL OR
        p_line_rec.tax_code <> FND_API.G_MISS_CHAR) AND
        NOT OE_GLOBALS.Equal(p_line_rec.tax_code,
        p_old_line_rec.tax_code)
    THEN
        l_line_val_rec.tax_group := OE_Id_To_Value.Tax_Group
        (   p_tax_code             => p_line_rec.tax_code
        );
    END IF;*/

    IF (p_line_rec.veh_cus_item_cum_key_id IS NULL OR
        p_line_rec.veh_cus_item_cum_key_id <> FND_API.G_MISS_NUM) AND
        NOT OE_GLOBALS.Equal(p_line_rec.veh_cus_item_cum_key_id,
        p_old_line_rec.veh_cus_item_cum_key_id)
    THEN
      l_line_val_rec.veh_cus_item_cum_key := OE_Id_To_Value.veh_cus_item_cum_key
        (   p_veh_cus_item_cum_key_id => p_line_rec.veh_cus_item_cum_key_id
        );
    END IF;


   IF (p_line_rec.Original_inventory_item_id IS NOT NULL  OR
        p_line_rec.original_inventory_item_id <> FND_API.G_MISS_NUM)
   THEN
    OE_ID_TO_VALUE.Ordered_Item
    (p_Item_Identifier_type    => p_line_rec.original_item_identifier_Type
    ,p_inventory_item_id       => p_line_rec.original_Inventory_Item_Id
    ,p_organization_id         => l_organization_id
    ,p_ordered_item_id         => p_line_rec.original_ordered_item_id
    ,p_sold_to_org_id          => p_line_rec.sold_to_org_id
    ,p_ordered_item            => p_line_rec.original_ordered_item
    ,x_ordered_item            => l_line_val_rec.original_ordered_item
    ,x_inventory_item          => l_line_val_rec.original_inventory_item);
   END IF;

   IF (p_line_rec.original_item_identifier_type IS NOT NULL  OR
        p_line_rec.original_item_identifier_type <> FND_API.G_MISS_CHAR)
   THEN
    OE_ID_TO_VALUE.item_identifier
         (p_Item_Identifier_type   => p_line_rec.Original_item_identifier_Type
         ,x_Item_Identifier        => l_line_val_rec.Original_item_identifier_type);
   END IF;

   IF (p_line_rec.item_relationship_type IS NOT NULL  OR
        p_line_rec.item_relationship_type <> FND_API.G_MISS_NUM)
   THEN
    OE_ID_TO_VALUE.item_relationship_type
         (p_Item_relationship_type     => p_line_rec.item_relationship_type
         ,x_Item_relationship_type_dsp => l_line_val_rec.item_relationship_type_dsp);
   END IF;

   IF (p_line_rec.end_customer_id IS NOT NULL  AND
        p_line_rec.end_customer_id <> FND_API.G_MISS_NUM)
   THEN
      OE_ID_TO_VALUE.End_Customer(
				  p_end_customer_id     => p_line_rec.end_customer_id
				  ,x_end_customer_name   => l_line_val_rec.end_customer_name
				  ,x_end_customer_number => l_line_val_rec.end_customer_number);
   END IF;

   IF (p_line_rec.end_customer_contact_id IS NOT NULL   AND
        p_line_rec.end_customer_contact_id <> FND_API.G_MISS_NUM)
   THEN
    l_line_val_rec.end_customer_contact :=
	 OE_ID_TO_VALUE.end_customer_Contact(p_end_customer_contact_id => p_line_rec.end_customer_contact_id);
   END IF;

   IF (p_line_rec.end_customer_site_use_id IS NOT NULL   AND
        p_line_rec.end_customer_site_use_id <> FND_API.G_MISS_NUM)
   THEN
    OE_ID_TO_VALUE.end_customer_site_use(
					 p_end_customer_site_use_id => p_line_rec.end_customer_site_use_id
					 ,x_end_customer_address1    => l_line_val_rec.end_customer_site_address1
					 ,x_end_customer_address2    => l_line_val_rec.end_customer_site_address2
					 ,x_end_customer_address3    => l_line_val_rec.end_customer_site_address3
					 ,x_end_customer_address4    => l_line_val_rec.end_customer_site_address4
					 ,x_end_customer_location    => l_line_val_rec.end_customer_site_location
					 ,x_end_customer_city        => l_line_val_rec.end_customer_site_city
					 ,x_end_customer_state       => l_line_val_rec.end_customer_site_state
					 ,x_end_customer_postal_code => l_line_val_rec.end_customer_site_postal_code
					 ,x_end_customer_country     => l_line_val_rec.end_customer_site_country    );
   END IF;
 -- Start BSA pricing
   IF (p_line_rec.blanket_number IS NOT NULL  OR
        p_line_rec.blanket_number <> FND_API.G_MISS_NUM)
   THEN
                oe_blanket_util_misc.get_blanketAgrName
                              (p_blanket_number   => p_line_rec.blanket_number,
                               x_blanket_agr_name => l_line_val_rec.blanket_agreement_name);
   END if;
 -- END BSA pricing
--Macd
   IF (p_line_rec.ib_owner IS NOT NULL   AND
        p_line_rec.ib_owner <> FND_API.G_MISS_CHAR)
   THEN
    l_line_val_rec.ib_owner_dsp :=
	 OE_ID_TO_VALUE.ib_owner(p_ib_owner => p_line_rec.ib_owner);
   END IF;

   IF (p_line_rec.ib_current_location IS NOT NULL   AND
        p_line_rec.ib_current_location <> FND_API.G_MISS_CHAR)
   THEN
    l_line_val_rec.ib_current_location_dsp :=
	 OE_ID_TO_VALUE.ib_current_location(p_ib_current_location => p_line_rec.ib_current_location);
   END IF;

   IF (p_line_rec.ib_installed_at_location IS NOT NULL   AND
        p_line_rec.ib_installed_at_location <> FND_API.G_MISS_CHAR)
   THEN
    l_line_val_rec.ib_installed_at_location_dsp :=
	 OE_ID_TO_VALUE.ib_installed_at_location(p_ib_installed_at_location => p_line_rec.ib_installed_at_location);
   END IF;
--Macd
 /*3605052*/
   IF (p_line_rec.service_period IS NOT NULL   AND
        p_line_rec.service_period <> FND_API.G_MISS_CHAR)
   THEN
    l_line_val_rec.service_period_dsp :=
	 OE_ID_TO_VALUE.service_period(p_service_period => p_line_rec.service_period
				       ,p_inventory_item_id => p_line_rec.inventory_item_id);
   END IF;
   /*3605052*/


-- 5701246 begin
   IF (p_line_rec.service_reference_type_code IS NOT NULL   AND
        p_line_rec.service_reference_type_code <> FND_API.G_MISS_CHAR)
   THEN
    l_line_val_rec.service_reference_type :=
	OE_ID_TO_VALUE.service_reference_type(p_service_reference_type_code => p_line_rec.service_reference_type_code);
   END IF;
-- 5701246 end


  --Customer Acceptance
    IF (p_line_rec.contingency_id IS NOT NULL AND
        p_line_rec.contingency_id <> FND_API.G_MISS_NUM)
    THEN
       OE_ID_TO_VALUE.Get_Contingency_Attributes(
				p_contingency_id  => p_line_rec.contingency_id
			        , x_contingency_name =>  l_line_val_rec.contingency_name
                                , x_contingency_description  =>  l_line_val_rec.contingency_description
                                , x_expiration_event_attribute  =>  l_line_val_rec.expiration_event_attribute);

    END IF;
    IF (p_line_rec.revrec_event_code IS NOT NULL  AND
        p_line_rec.revrec_event_code <> FND_API.G_MISS_CHAR)
    THEN
     l_line_val_rec.Revrec_Event:=  OE_ID_TO_VALUE.Revrec_Event(
				p_Revrec_Event_code  => p_line_rec.Revrec_Event_code);

    END IF;

    IF (p_line_rec.accepted_by IS NOT NULL  AND
        p_line_rec.accepted_by <> FND_API.G_MISS_NUM)
    THEN
     l_line_val_rec.accepted_by_dsp:=  OE_ID_TO_VALUE.accepted_by(
				p_accepted_by  => p_line_rec.accepted_by);

    END IF;
 --

  if l_debug_level > 0 then
    oe_debug_pub.add('original item identifier type='||p_line_rec.original_item_identifier_type);
    oe_debug_pub.add('original ordered item ' ||p_line_rec.original_ordered_item);
    oe_debug_pub.add('original inventory item id ' ||p_line_rec.original_inventory_item_id);
    oe_debug_pub.add('original ordered_item id '||p_line_rec.original_ordered_item_id);
    oe_debug_pub.add('item relationship type '||p_line_rec.item_relationship_type);
    oe_debug_pub.add('original inventory item'||l_line_val_rec.original_inventory_item);
    oe_debug_pub.add('original ordered item'||l_line_val_rec.original_ordered_item);
    oe_debug_pub.add('original original item ident type'||l_line_val_rec.original_item_identifier_type);
    oe_debug_pub.add('item relationship type dsp='||l_line_val_rec.item_relationship_type_dsp);
    oe_debug_pub.add('the service_reference_type_code: '||p_line_rec.service_reference_type_code);
    oe_debug_pub.add('the service_reference_type: '||l_line_val_rec.service_reference_type);
  end if;
    RETURN l_line_val_rec;

END Get_Values;


/*----------------------------------------------------------
  Function Get_Ids
-----------------------------------------------------------*/

PROCEDURE Get_Ids
(   p_x_line_rec                    IN OUT NOCOPY  OE_Order_PUB.Line_Rec_Type
,   p_line_val_rec                  IN  OE_Order_PUB.Line_Val_Rec_Type
)
IS
l_sold_to_org_id           NUMBER;
l_deliver_to_org_id        NUMBER;
l_invoice_to_org_id        NUMBER;
l_ship_to_org_id           NUMBER;
BEGIN

    p_x_line_rec.return_status := FND_API.G_RET_STS_SUCCESS;

    IF  p_line_val_rec.accounting_rule <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_line_rec.accounting_rule_id <> FND_API.G_MISS_NUM THEN

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','accounting_rule');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_line_rec.accounting_rule_id := OE_Value_To_Id.accounting_rule
            (   p_accounting_rule             => p_line_val_rec.accounting_rule
            );

            IF p_x_line_rec.accounting_rule_id = FND_API.G_MISS_NUM THEN
                p_x_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_line_val_rec.agreement <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_line_rec.agreement_id <> FND_API.G_MISS_NUM THEN

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','agreement');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_line_rec.agreement_id := OE_Value_To_Id.agreement
            (   p_agreement                   => p_line_val_rec.agreement
            );

            IF p_x_line_rec.agreement_id = FND_API.G_MISS_NUM THEN
                p_x_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_line_val_rec.demand_bucket_type <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_line_rec.demand_bucket_type_code <> FND_API.G_MISS_CHAR THEN

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','demand_bucket_type');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_line_rec.demand_bucket_type_code := OE_Value_To_Id.demand_bucket_type
            (   p_demand_bucket_type          => p_line_val_rec.demand_bucket_type
            );

            IF p_x_line_rec.demand_bucket_type_code = FND_API.G_MISS_CHAR THEN
                p_x_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_line_val_rec.fob_point <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_line_rec.fob_point_code <> FND_API.G_MISS_CHAR THEN

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','fob_point');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_line_rec.fob_point_code := OE_Value_To_Id.fob_point
            (   p_fob_point                   => p_line_val_rec.fob_point
            );

            IF p_x_line_rec.fob_point_code = FND_API.G_MISS_CHAR THEN
                p_x_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_line_val_rec.freight_terms <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_line_rec.freight_terms_code <> FND_API.G_MISS_CHAR THEN

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','freight_terms');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_line_rec.freight_terms_code := OE_Value_To_Id.freight_terms
            (   p_freight_terms               => p_line_val_rec.freight_terms
            );

            IF p_x_line_rec.freight_terms_code = FND_API.G_MISS_CHAR THEN
                p_x_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_line_val_rec.shipping_method <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_line_rec.shipping_method_code <> FND_API.G_MISS_CHAR THEN

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','shipping_method');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_line_rec.shipping_method_code := OE_Value_To_Id.ship_method
            (   p_ship_method           => p_line_val_rec.shipping_method
            );

            IF p_x_line_rec.shipping_method_code = FND_API.G_MISS_CHAR THEN
		  oe_debug_pub.add('Ship Method Conversion Error');
                p_x_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;


    IF  p_line_val_rec.freight_carrier <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_line_rec.freight_carrier_code <> FND_API.G_MISS_CHAR THEN

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','freight_carrier');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_line_rec.freight_carrier_code := OE_Value_To_Id.freight_carrier
            (   p_freight_carrier               => p_line_val_rec.freight_carrier
		  ,   p_ship_from_org_id			   => p_x_line_rec.ship_from_org_id
            );

            IF p_x_line_rec.freight_carrier_code = FND_API.G_MISS_CHAR THEN
                p_x_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_line_val_rec.intermed_ship_to_contact <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_line_rec.intermed_ship_to_contact_id <> FND_API.G_MISS_NUM THEN

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','intermed_ship_to_contact');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_line_rec.intermed_ship_to_contact_id := OE_Value_To_Id.intermed_ship_to_contact
            (   p_intermed_ship_to_contact    => p_line_val_rec.intermed_ship_to_contact
		  ,   p_intermed_ship_to_org_id     => p_x_line_rec.intermed_ship_to_org_id
            );

            IF p_x_line_rec.intermed_ship_to_contact_id = FND_API.G_MISS_NUM THEN
                p_x_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_line_val_rec.intermed_ship_to_address1 <> FND_API.G_MISS_CHAR
    OR  p_line_val_rec.intermed_ship_to_address2 <> FND_API.G_MISS_CHAR
    OR  p_line_val_rec.intermed_ship_to_address3 <> FND_API.G_MISS_CHAR
    OR  p_line_val_rec.intermed_ship_to_address4 <> FND_API.G_MISS_CHAR
    OR  p_line_val_rec.intermed_ship_to_location <> FND_API.G_MISS_CHAR
    OR  p_line_val_rec.intermed_ship_to_org <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_line_rec.intermed_ship_to_org_id <> FND_API.G_MISS_NUM THEN

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','intermed_ship_to_org');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

/*1621182*/
            p_x_line_rec.intermed_ship_to_org_id := OE_Value_To_Id.intermed_ship_to_org
            (   p_intermed_ship_to_address1     => p_line_val_rec.intermed_ship_to_address1
          ,   p_intermed_ship_to_address2     => p_line_val_rec.intermed_ship_to_address2
          ,   p_intermed_ship_to_address3     => p_line_val_rec.intermed_ship_to_address3
          ,   p_intermed_ship_to_address4     => p_line_val_rec.intermed_ship_to_address4
          ,   p_intermed_ship_to_location     => p_line_val_rec.intermed_ship_to_location
          ,   p_intermed_ship_to_org          => p_line_val_rec.intermed_ship_to_org
          ,   p_intermed_ship_to_city         => p_line_val_rec.intermed_ship_to_city
          ,   p_intermed_ship_to_state        => p_line_val_rec.intermed_ship_to_state
          ,   p_intermed_ship_to_postal_code  => p_line_val_rec.intermed_ship_to_zip
          ,   p_intermed_ship_to_country      => p_line_val_rec.intermed_ship_to_country
		  ,   p_sold_to_org_id          => p_x_line_rec.sold_to_org_id
            );
/*1621182*/
            IF p_x_line_rec.intermed_ship_to_org_id = FND_API.G_MISS_NUM THEN
                p_x_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;


    IF  p_line_val_rec.inventory_item <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_line_rec.inventory_item_id <> FND_API.G_MISS_NUM THEN

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','inventory_item');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_line_rec.inventory_item_id := OE_Value_To_Id.inventory_item
            (   p_inventory_item              => p_line_val_rec.inventory_item
            );

            IF p_x_line_rec.inventory_item_id = FND_API.G_MISS_NUM THEN
                p_x_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_line_val_rec.invoicing_rule <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_line_rec.invoicing_rule_id <> FND_API.G_MISS_NUM THEN

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','invoicing_rule');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_line_rec.invoicing_rule_id := OE_Value_To_Id.invoicing_rule
            (   p_invoicing_rule              => p_line_val_rec.invoicing_rule
            );

            IF p_x_line_rec.invoicing_rule_id = FND_API.G_MISS_NUM THEN
                p_x_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_line_val_rec.item_type <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_line_rec.item_type_code <> FND_API.G_MISS_CHAR THEN

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','item_type');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_line_rec.item_type_code := OE_Value_To_Id.item_type
            (   p_item_type                   => p_line_val_rec.item_type
            );

            IF p_x_line_rec.item_type_code = FND_API.G_MISS_CHAR THEN
                p_x_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_line_val_rec.line_type <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_line_rec.line_type_id <> FND_API.G_MISS_NUM THEN

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','line_type');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_line_rec.line_type_id := OE_Value_To_Id.line_type
            (   p_line_type                   => p_line_val_rec.line_type
            );

            IF p_x_line_rec.line_type_id = FND_API.G_MISS_NUM THEN
                p_x_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_line_val_rec.over_ship_reason <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_line_rec.over_ship_reason_code <> FND_API.G_MISS_CHAR THEN

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Over_shipo_reason');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_line_rec.over_ship_reason_code := OE_Value_To_Id.over_ship_reason
            (   p_over_ship_reason  => p_line_val_rec.over_ship_reason
            );

            IF p_x_line_rec.over_ship_reason_code = FND_API.G_MISS_CHAR THEN
                p_x_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_line_val_rec.payment_term <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_line_rec.payment_term_id <> FND_API.G_MISS_NUM THEN

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','payment_term');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_line_rec.payment_term_id := OE_Value_To_Id.payment_term
            (   p_payment_term                => p_line_val_rec.payment_term
            );

            IF p_x_line_rec.payment_term_id = FND_API.G_MISS_NUM THEN
                p_x_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_line_val_rec.price_list <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_line_rec.price_list_id <> FND_API.G_MISS_NUM THEN

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','price_list');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_line_rec.price_list_id := OE_Value_To_Id.price_list
            (   p_price_list                  => p_line_val_rec.price_list
            );

            IF p_x_line_rec.price_list_id = FND_API.G_MISS_NUM THEN
                p_x_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_line_val_rec.project <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_line_rec.project_id <> FND_API.G_MISS_NUM THEN

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','project');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_line_rec.project_id := OE_Value_To_Id.project
            (   p_project                     => p_line_val_rec.project
            );

            IF p_x_line_rec.project_id = FND_API.G_MISS_NUM THEN
                p_x_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_line_val_rec.return_reason <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_line_rec.return_reason_code <> FND_API.G_MISS_CHAR THEN

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','return_reason');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_line_rec.return_reason_code := OE_Value_To_Id.return_reason
            (   p_return_reason  => p_line_val_rec.return_reason
            );

            IF p_x_line_rec.return_reason_code = FND_API.G_MISS_CHAR THEN
                p_x_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;



    IF  p_line_val_rec.rla_schedule_type <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_line_rec.rla_schedule_type_code <> FND_API.G_MISS_CHAR THEN

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','rla_schedule_type');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_line_rec.rla_schedule_type_code := OE_Value_To_Id.rla_schedule_type
            (   p_rla_schedule_type           => p_line_val_rec.rla_schedule_type
            );

            IF p_x_line_rec.rla_schedule_type_code = FND_API.G_MISS_CHAR THEN
                p_x_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_line_val_rec.salesrep <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_line_rec.salesrep_id <> FND_API.G_MISS_NUM THEN

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','salesrep');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_line_rec.salesrep_id := OE_Value_To_Id.salesrep
            (   p_salesrep  => p_line_val_rec.salesrep
            );

            IF p_x_line_rec.salesrep_id = FND_API.G_MISS_NUM THEN
                p_x_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_line_val_rec.shipment_priority <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_line_rec.shipment_priority_code <> FND_API.G_MISS_CHAR THEN

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','shipment_priority');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_line_rec.shipment_priority_code := OE_Value_To_Id.shipment_priority
            (   p_shipment_priority           => p_line_val_rec.shipment_priority
            );

            IF p_x_line_rec.shipment_priority_code = FND_API.G_MISS_CHAR THEN
                p_x_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_line_val_rec.ship_from_address1 <> FND_API.G_MISS_CHAR
    OR p_line_val_rec.ship_from_address2 <> FND_API.G_MISS_CHAR
    OR p_line_val_rec.ship_from_address3 <> FND_API.G_MISS_CHAR
    OR p_line_val_rec.ship_from_address4 <> FND_API.G_MISS_CHAR
    OR p_line_val_rec.ship_from_location <> FND_API.G_MISS_CHAR
    OR p_line_val_rec.ship_from_org <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_line_rec.ship_from_org_id <> FND_API.G_MISS_NUM THEN

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','ship_from_org');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_line_rec.ship_from_org_id := OE_Value_To_Id.ship_from_org
            (   p_ship_from_address1          => p_line_val_rec.ship_from_address1
          ,   p_ship_from_address2          => p_line_val_rec.ship_from_address2
          ,   p_ship_from_address3          => p_line_val_rec.ship_from_address3
          ,   p_ship_from_address4          => p_line_val_rec.ship_from_address4
          ,   p_ship_from_location          => p_line_val_rec.ship_from_location
          ,   p_ship_from_org               => p_line_val_rec.ship_from_org
            );

            IF p_x_line_rec.ship_from_org_id = FND_API.G_MISS_NUM THEN
                p_x_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_line_val_rec.task <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_line_rec.task_id <> FND_API.G_MISS_NUM THEN

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','task');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_line_rec.task_id := OE_Value_To_Id.task
            (   p_task                        => p_line_val_rec.task
            );

            IF p_x_line_rec.task_id = FND_API.G_MISS_NUM THEN
                p_x_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_line_val_rec.tax_exempt <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_line_rec.tax_exempt_flag <> FND_API.G_MISS_CHAR THEN

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','tax_exempt');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_line_rec.tax_exempt_flag := OE_Value_To_Id.tax_exempt
            (   p_tax_exempt                  => p_line_val_rec.tax_exempt
            );

            IF p_x_line_rec.tax_exempt_flag = FND_API.G_MISS_CHAR THEN
                p_x_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_line_val_rec.tax_exempt_reason <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_line_rec.tax_exempt_reason_code <> FND_API.G_MISS_CHAR THEN

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','tax_exempt_reason');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_line_rec.tax_exempt_reason_code := OE_Value_To_Id.tax_exempt_reason
            (   p_tax_exempt_reason           => p_line_val_rec.tax_exempt_reason
            );

            IF p_x_line_rec.tax_exempt_reason_code = FND_API.G_MISS_CHAR THEN
                p_x_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_line_val_rec.tax_point <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_line_rec.tax_point_code <> FND_API.G_MISS_CHAR THEN

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','tax_point');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_line_rec.tax_point_code := OE_Value_To_Id.tax_point
            (   p_tax_point                   => p_line_val_rec.tax_point
            );

            IF p_x_line_rec.tax_point_code = FND_API.G_MISS_CHAR THEN
                p_x_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;


    IF  p_line_val_rec.veh_cus_item_cum_key <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_line_rec.veh_cus_item_cum_key_id <> FND_API.G_MISS_NUM THEN

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','veh_cus_item_cum_key');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

       p_x_line_rec.veh_cus_item_cum_key_id := OE_Value_To_Id.veh_cus_item_cum_key
            (   p_veh_cus_item_cum_key  => p_line_val_rec.veh_cus_item_cum_key
            );

            IF p_x_line_rec.veh_cus_item_cum_key_id = FND_API.G_MISS_NUM THEN
                p_x_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    ----------------------------------------------------------------------
    -- Retreiving ids for invoice_to_customer
    ----------------------------------------------------------------------

    oe_debug_pub.add('line Invoice_to_cust_id='||p_x_line_rec.invoice_to_customer_id);
    IF  p_line_val_rec.invoice_to_customer_name_oi <> FND_API.G_MISS_CHAR
    OR  p_line_val_rec.invoice_to_customer_number_oi <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_line_rec.invoice_to_customer_id <> FND_API.G_MISS_NUM THEN


            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','invoice_to_customer line');
                OE_MSG_PUB.Add;

            END IF;

        ELSE
           IF p_x_line_rec.invoice_to_org_id = FND_API.G_MISS_NUM THEN -- bug 4231603
            p_x_line_rec.invoice_to_customer_id:=OE_Value_To_Id.site_customer
            ( p_site_customer       => p_line_val_rec.invoice_to_customer_name_oi
             ,p_site_customer_number=> p_line_val_rec.invoice_to_customer_number_oi
             ,p_type =>'INVOICE_TO'
            );

            IF p_x_line_rec.invoice_to_customer_id = FND_API.G_MISS_NUM THEN
                p_x_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;
          END IF;
        END IF;

    END IF;

    ----------------------------------------------------------------------
    -- Retreiving ids for ship_to_customer
    ----------------------------------------------------------------------

    IF  p_line_val_rec.ship_to_customer_name_oi <> FND_API.G_MISS_CHAR
    OR  p_line_val_rec.ship_to_customer_number_oi <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_line_rec.ship_to_customer_id <> FND_API.G_MISS_NUM THEN


            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','ship_to_customer line');
                OE_MSG_PUB.Add;

            END IF;

        ELSE
           IF p_x_line_rec.ship_to_org_id = FND_API.G_MISS_NUM THEN --4231603
            p_x_line_rec.ship_to_customer_id:=OE_Value_To_Id.site_customer
            ( p_site_customer       => p_line_val_rec.ship_to_customer_name_oi
             ,p_site_customer_number=> p_line_val_rec.ship_to_customer_number_oi
             ,p_type =>'SHIP_TO'
            );

            IF p_x_line_rec.ship_to_customer_id = FND_API.G_MISS_NUM THEN
                p_x_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;
          END IF;
        END IF;

    END IF;


    ----------------------------------------------------------------------
    -- Retreiving ids for deliver_to_customer
    ----------------------------------------------------------------------

    IF  p_line_val_rec.deliver_to_customer_name_oi <> FND_API.G_MISS_CHAR
    OR  p_line_val_rec.deliver_to_customer_number_oi <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_line_rec.deliver_to_customer_id <> FND_API.G_MISS_NUM THEN


            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','deliver_to_customer line');
                OE_MSG_PUB.Add;

            END IF;

        ELSE
           IF p_x_line_rec.deliver_to_org_id = FND_API.G_MISS_NUM THEN  -- 4231603
            p_x_line_rec.deliver_to_customer_id:=OE_Value_To_Id.site_customer
            ( p_site_customer       => p_line_val_rec.ship_to_customer_name_oi
             ,p_site_customer_number=> p_line_val_rec.ship_to_customer_number_oi
             ,p_type =>'DELIVER_TO'
            );

            IF p_x_line_rec.deliver_to_customer_id = FND_API.G_MISS_NUM THEN
                p_x_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;
          END IF;
        END IF;

    END IF;


    -------------------------------------------------------------------
    -- For customer related fields, IDs should be retrieved in the
    -- following order.
    -------------------------------------------------------------------

    -- Retrieve the sold_to_org_id if not passed on the line record. This
    -- will be needed by the value_to_id functions for related fields.
    -- For e.g. oe_value_to_id.ship_to_org_id requires sold_to_org_id

    IF  p_x_line_rec.sold_to_org_id = FND_API.G_MISS_NUM
    THEN

      IF p_x_line_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN

         -- bug 2411783
         -- for a newly created order, since the line is not posted,
         -- in Order import, there will be no Header record.
         --OE_Order_Cache.Load_Order_Header(p_x_line_rec.header_id);
         --l_sold_to_org_id := OE_Order_Cache.g_header_rec.sold_to_org_id;
         null;

      ELSIF p_x_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE THEN

	   SELECT SOLD_TO_ORG_ID
	   INTO l_sold_to_org_id
	   FROM OE_ORDER_LINES
	   WHERE LINE_ID = p_x_line_rec.line_id;

      END IF;

    ELSE

	  l_sold_to_org_id := p_x_line_rec.sold_to_org_id;

    END IF;

    IF  p_line_val_rec.deliver_to_address1 <> FND_API.G_MISS_CHAR
    OR p_line_val_rec.deliver_to_address2 <> FND_API.G_MISS_CHAR
    OR p_line_val_rec.deliver_to_address3 <> FND_API.G_MISS_CHAR
    OR p_line_val_rec.deliver_to_address4 <> FND_API.G_MISS_CHAR
    OR p_line_val_rec.deliver_to_location <> FND_API.G_MISS_CHAR
    OR p_line_val_rec.deliver_to_org <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_line_rec.deliver_to_org_id <> FND_API.G_MISS_NUM THEN


            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','deliver_to_org');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

/*1621182*/
            p_x_line_rec.deliver_to_org_id := OE_Value_To_Id.deliver_to_org
            (   p_deliver_to_address1         => p_line_val_rec.deliver_to_address1
          ,   p_deliver_to_address2         => p_line_val_rec.deliver_to_address2
          ,   p_deliver_to_address3         => p_line_val_rec.deliver_to_address3
          ,   p_deliver_to_address4         => p_line_val_rec.deliver_to_address4
          ,   p_deliver_to_location         => p_line_val_rec.deliver_to_location
          ,   p_deliver_to_org              => p_line_val_rec.deliver_to_org
          ,   p_deliver_to_city             => p_line_val_rec.deliver_to_city
          ,   p_deliver_to_state            => p_line_val_rec.deliver_to_state
          ,   p_deliver_to_postal_code      => p_line_val_rec.deliver_to_zip
          ,   p_deliver_to_country          => p_line_val_rec.deliver_to_country
		  ,   p_sold_to_org_id        => l_sold_to_org_id
          , p_deliver_to_customer_id => p_x_line_rec.deliver_to_customer_id
            );
/*1621182*/
            IF p_x_line_rec.deliver_to_org_id = FND_API.G_MISS_NUM THEN
                p_x_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_line_val_rec.invoice_to_address1 <> FND_API.G_MISS_CHAR
    OR p_line_val_rec.invoice_to_address2 <> FND_API.G_MISS_CHAR
    OR p_line_val_rec.invoice_to_address3 <> FND_API.G_MISS_CHAR
    OR p_line_val_rec.invoice_to_address4 <> FND_API.G_MISS_CHAR
    OR p_line_val_rec.invoice_to_location <> FND_API.G_MISS_CHAR
    OR p_line_val_rec.invoice_to_org <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_line_rec.invoice_to_org_id <> FND_API.G_MISS_NUM THEN


            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','invoice_to_org');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

/*1621182*/
            p_x_line_rec.invoice_to_org_id := OE_Value_To_Id.invoice_to_org
            (   p_invoice_to_address1         => p_line_val_rec.invoice_to_address1
          ,   p_invoice_to_address2         => p_line_val_rec.invoice_to_address2
          ,   p_invoice_to_address3         => p_line_val_rec.invoice_to_address3
          ,   p_invoice_to_address4         => p_line_val_rec.invoice_to_address4
          ,   p_invoice_to_location         => p_line_val_rec.invoice_to_location
          ,   p_invoice_to_org              => p_line_val_rec.invoice_to_org
          ,   p_invoice_to_city             => p_line_val_rec.invoice_to_city
          ,   p_invoice_to_state            => p_line_val_rec.invoice_to_state
          ,   p_invoice_to_postal_code      => p_line_val_rec.invoice_to_zip
          ,   p_invoice_to_country          => p_line_val_rec.invoice_to_country
		  ,   p_sold_to_org_id        => l_sold_to_org_id
          , p_invoice_to_customer_id => p_x_line_rec.invoice_to_customer_id
            );
/*1621182*/
            IF p_x_line_rec.invoice_to_org_id = FND_API.G_MISS_NUM THEN
                p_x_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_line_val_rec.ship_to_address1 <> FND_API.G_MISS_CHAR
    OR p_line_val_rec.ship_to_address2 <> FND_API.G_MISS_CHAR
    OR p_line_val_rec.ship_to_address3 <> FND_API.G_MISS_CHAR
    OR p_line_val_rec.ship_to_address4 <> FND_API.G_MISS_CHAR
    OR p_line_val_rec.ship_to_location <> FND_API.G_MISS_CHAR
    OR p_line_val_rec.ship_to_org <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_line_rec.ship_to_org_id <> FND_API.G_MISS_NUM THEN


            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','ship_to_org');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

/*1621182*/
            p_x_line_rec.ship_to_org_id := OE_Value_To_Id.ship_to_org
            (   p_ship_to_address1            => p_line_val_rec.ship_to_address1
          ,   p_ship_to_address2            => p_line_val_rec.ship_to_address2
          ,   p_ship_to_address3            => p_line_val_rec.ship_to_address3
          ,   p_ship_to_address4            => p_line_val_rec.ship_to_address4
          ,   p_ship_to_location            => p_line_val_rec.ship_to_location
          ,   p_ship_to_org                 => p_line_val_rec.ship_to_org
          ,   p_ship_to_city                => p_line_val_rec.ship_to_city
          ,   p_ship_to_state               => p_line_val_rec.ship_to_state
          ,   p_ship_to_postal_code         => p_line_val_rec.ship_to_zip
          ,   p_ship_to_country             => p_line_val_rec.ship_to_country
		  ,   p_sold_to_org_id        => l_sold_to_org_id
          , p_ship_to_customer_id => p_x_line_rec.ship_to_customer_id
            );

/*1621182*/
            IF p_x_line_rec.ship_to_org_id = FND_API.G_MISS_NUM THEN
                p_x_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    -- Retrieve the org_ids if not passed on the line record. These
    -- IDs will be needed by the value_to_id functions for CONTACT fields.
    -- For e.g. oe_value_to_id.ship_to_contact_id requires ship_to_org_id

    -- bug 3487597, added clause for line_id

    IF p_x_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE
	  AND ( p_x_line_rec.ship_to_org_id = FND_API.G_MISS_NUM
	       OR p_x_line_rec.invoice_to_org_id = FND_API.G_MISS_NUM
	       OR p_x_line_rec.deliver_to_org_id = FND_API.G_MISS_NUM )
          AND p_x_line_rec.line_id <> FND_API.G_MISS_NUM
    THEN

	  SELECT SHIP_TO_ORG_ID, INVOICE_TO_ORG_ID, DELIVER_TO_ORG_ID
	  INTO l_sold_to_org_id, l_invoice_to_org_id, l_deliver_to_org_id
	  FROM OE_ORDER_LINES
	  WHERE LINE_ID = p_x_line_rec.line_id;

	  IF p_x_line_rec.ship_to_org_id <> FND_API.G_MISS_NUM THEN
		l_ship_to_org_id := p_x_line_rec.ship_to_org_id;
       END IF;

	  IF p_x_line_rec.invoice_to_org_id <> FND_API.G_MISS_NUM THEN
		l_invoice_to_org_id := p_x_line_rec.invoice_to_org_id;
       END IF;

	  IF p_x_line_rec.deliver_to_org_id <> FND_API.G_MISS_NUM THEN
		l_deliver_to_org_id := p_x_line_rec.deliver_to_org_id;
       END IF;

    ELSE

	  l_sold_to_org_id := p_x_line_rec.sold_to_org_id;
	  l_invoice_to_org_id := p_x_line_rec.invoice_to_org_id;
	  l_deliver_to_org_id := p_x_line_rec.deliver_to_org_id;

    END IF;

    IF  p_line_val_rec.deliver_to_contact <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_line_rec.deliver_to_contact_id <> FND_API.G_MISS_NUM THEN


            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','deliver_to_contact');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_line_rec.deliver_to_contact_id := OE_Value_To_Id.deliver_to_contact
            (   p_deliver_to_contact          => p_line_val_rec.deliver_to_contact
		  ,   p_deliver_to_org_id           => l_deliver_to_org_id
            );

            IF p_x_line_rec.deliver_to_contact_id = FND_API.G_MISS_NUM THEN
                p_x_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_line_val_rec.invoice_to_contact <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_line_rec.invoice_to_contact_id <> FND_API.G_MISS_NUM THEN


            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','invoice_to_contact');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_line_rec.invoice_to_contact_id := OE_Value_To_Id.invoice_to_contact
            (   p_invoice_to_contact          => p_line_val_rec.invoice_to_contact
		  ,   p_invoice_to_org_id           => l_invoice_to_org_id
            );

            IF p_x_line_rec.invoice_to_contact_id = FND_API.G_MISS_NUM THEN
                p_x_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_line_val_rec.ship_to_contact <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_line_rec.ship_to_contact_id <> FND_API.G_MISS_NUM THEN


            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','ship_to_contact');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_line_rec.ship_to_contact_id := OE_Value_To_Id.ship_to_contact
            (   p_ship_to_contact             => p_line_val_rec.ship_to_contact
		  ,   p_ship_to_org_id              => l_ship_to_org_id
            );

            IF p_x_line_rec.ship_to_contact_id = FND_API.G_MISS_NUM THEN
                p_x_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    -- added code for commitment for bug 1851006.
    IF  p_line_val_rec.commitment <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_line_rec.commitment_id <> FND_API.G_MISS_NUM THEN

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','commitment');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_line_rec.commitment_id := OE_Value_To_Id.commitment
            (   p_commitment                   => p_line_val_rec.commitment
            );

            IF p_x_line_rec.commitment_id = FND_API.G_MISS_NUM THEN
                p_x_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;
      END IF;

      /* mvijayku */
    IF  p_line_val_rec.end_customer_name <> FND_API.G_MISS_CHAR
    OR  p_line_val_rec.end_customer_number <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_line_rec.end_customer_id <> FND_API.G_MISS_NUM THEN


            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','end_customer');
                OE_MSG_PUB.Add;

            END IF;

        ELSE
          IF p_x_line_rec.end_customer_site_use_id = FND_API.G_MISS_NUM THEN -- 4231603
            p_x_line_rec.end_customer_id:=OE_Value_To_Id.end_customer
            ( p_end_customer       => p_line_val_rec.end_customer_name
             ,p_end_customer_number=> p_line_val_rec.end_customer_number
              );

            IF p_x_line_rec.end_customer_id = FND_API.G_MISS_NUM THEN
                p_x_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;
          END IF;
        END IF;

    END IF;

    IF  p_line_val_rec.end_customer_contact <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_line_rec.end_customer_id <>FND_API.G_MISS_NUM and
                p_x_line_rec.end_customer_contact_id <> FND_API.G_MISS_NUM THEN


            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','end_customer_contact');
                OE_MSG_PUB.Add;

            END IF;

        ELSE
                oe_debug_pub.add('before calling aend customer contact value to id');
            p_x_line_rec.end_customer_contact_id := OE_Value_To_Id.end_customer_contact
            (   p_end_customer_contact             => p_line_val_rec.end_customer_contact
		  ,p_end_customer_id              =>p_x_line_rec.end_customer_id
            );
	    oe_debug_pub.add('End customer contact id is '||p_x_line_rec.end_customer_contact_id);

            IF p_x_line_rec.end_customer_contact_id = FND_API.G_MISS_NUM THEN
                p_x_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

  IF (p_line_val_rec.end_customer_name <> FND_API.G_MISS_CHAR
      OR p_line_val_rec.end_customer_number <> FND_API.G_MISS_CHAR
      OR p_x_line_rec.end_customer_id <> FND_API.G_MISS_NUM)
	 AND
     (p_line_val_rec.end_customer_site_address1 <> FND_API.G_MISS_CHAR
    OR p_line_val_rec.end_customer_site_address2 <> FND_API.G_MISS_CHAR
    OR p_line_val_rec.end_customer_site_address3 <> FND_API.G_MISS_CHAR
    OR p_line_val_rec.end_customer_site_address4 <> FND_API.G_MISS_CHAR
    OR p_line_val_rec.end_customer_site_location          <> FND_API.G_MISS_CHAR)

    THEN

        IF p_x_line_rec.end_customer_site_use_id <> FND_API.G_MISS_NUM THEN


            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','end_Customer_Location');
                OE_MSG_PUB.Add;

            END IF;

        ELSE
	   oe_debug_pub.add('Before calling End custoemr site use value to id');
            p_x_line_rec.end_customer_site_use_id := OE_Value_To_Id.end_customer_site
            (   p_end_customer_site_address1            => p_line_val_rec.end_customer_site_address1
            ,   p_end_customer_site_address2            => p_line_val_rec.end_customer_site_address2
            ,   p_end_customer_site_address3            => p_line_val_rec.end_customer_site_address3
            ,   p_end_customer_site_address4            => p_line_val_rec.end_customer_site_address4
            ,   p_end_customer_site_location                     => p_line_val_rec.end_customer_site_location
	    ,   p_end_customer_site_org                       => NULL
		,   p_end_customer_id                         => p_x_line_rec.end_customer_id
            ,   p_end_customer_site_city                => p_line_val_rec.end_customer_site_city
            ,   p_end_customer_site_state               => p_line_val_rec.end_customer_site_state
            ,   p_end_customer_site_postalcode         => p_line_val_rec.end_customer_site_postal_code
            ,   p_end_customer_site_country             => p_line_val_rec.end_customer_site_country
            ,   p_end_customer_site_use_code           => NULL
            );


    oe_debug_pub.add('after hdr sold_to_site_use_id='||p_x_line_rec.end_customer_site_use_id);

            IF p_x_line_rec.end_customer_site_use_id = FND_API.G_MISS_NUM THEN
                p_x_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    -- {added for bug 4240715
    IF  p_line_val_rec.ib_owner_dsp <> FND_API.G_MISS_CHAR
    THEN
        IF p_x_line_rec.ib_owner <> FND_API.G_MISS_CHAR THEN

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','IB_Owner');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_line_rec.ib_owner:=OE_Value_To_Id.ib_owner
            ( p_ib_owner       => p_line_val_rec.ib_owner_dsp
              );

            IF p_x_line_rec.ib_owner = FND_API.G_MISS_CHAR THEN
                p_x_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_line_val_rec.ib_installed_at_location_dsp <> FND_API.G_MISS_CHAR
    THEN
        IF p_x_line_rec.ib_installed_at_location <> FND_API.G_MISS_CHAR THEN

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','IB_Installed_at_location');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_line_rec.ib_installed_at_location:=OE_Value_To_Id.ib_installed_at_location
            ( p_ib_installed_at_location       => p_line_val_rec.ib_installed_at_location_dsp
              );

            IF p_x_line_rec.ib_installed_at_location = FND_API.G_MISS_CHAR THEN
                p_x_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

     IF  p_line_val_rec.ib_current_location_dsp <> FND_API.G_MISS_CHAR
    THEN
        IF p_x_line_rec.ib_current_location <> FND_API.G_MISS_CHAR THEN

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','IB_current_location');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_line_rec.ib_current_location:=OE_Value_To_Id.ib_current_location
            ( p_ib_current_location       => p_line_val_rec.ib_current_location_dsp
              );

            IF p_x_line_rec.ib_current_location = FND_API.G_MISS_CHAR THEN
                p_x_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;
    --bug 4240715}

    -------------------------------------------------------------------
    -- End of get IDs for customer related fields
    -------------------------------------------------------------------


END Get_Ids;



/*----------------------------------------------------------
Procedure Query_Header
-----------------------------------------------------------*/

Procedure Query_Header
(   p_line_id                       IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   x_header_id                     OUT NOCOPY /* file.sql.39 change */ NUMBER
)IS
BEGIN

	Select header_id into x_header_id
	from oe_order_lines
	where line_id = p_line_id;
	IF sql%notfound then
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;


END Query_Header;

-- INVCONV for SAO

PROCEDURE get_reserved_quantities
( p_header_id                       IN NUMBER
 ,p_line_id                         IN NUMBER
 ,p_org_id                          IN NUMBER
 ,p_order_quantity_uom              IN VARCHAR2 DEFAULT NULL
 ,p_inventory_item_id		    				IN NUMBER DEFAULT NULL
 ,x_reserved_quantity               OUT NOCOPY NUMBER
 ,x_reserved_quantity2              OUT NOCOPY NUMBER )

IS

l_reserved_quantity     NUMBER := 0;
l_reserved_quantity2    NUMBER := 0;
l_return_status         VARCHAR2(1);
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(240);

l_rsv_rec               inv_reservation_global.mtl_reservation_rec_type;
l_rsv_tbl               inv_reservation_global.mtl_reservation_tbl_type;
l_count                 NUMBER;
l_x_error_code          NUMBER;
l_lock_records          VARCHAR2(1);
l_sort_by_req_date      NUMBER;
--- 2346233
l_converted_qty         NUMBER;
l_inventory_item_id     NUMBER;
l_order_quantity_uom    VARCHAR2(30);
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

BEGIN
	 if l_debug_level > 0 then -- INVCONV
          oe_debug_pub.add('in get_reserved_quantities' );
   end if;
   l_rsv_rec.demand_source_header_id  := p_header_id;
   l_rsv_rec.demand_source_line_id    := p_line_id;

   l_rsv_rec.organization_id           := p_org_id;

   inv_reservation_pub.query_reservation_om_hdr_line
   (  p_api_version_number        => 1.0
  , p_init_msg_lst              => fnd_api.g_true
  , x_return_status             => l_return_status
  , x_msg_count                 => l_msg_count
  , x_msg_data                  => l_msg_data
  , p_query_input               => l_rsv_rec
  , x_mtl_reservation_tbl       => l_rsv_tbl
  , x_mtl_reservation_tbl_count => l_count
  , x_error_code                => l_x_error_code
  , p_lock_records              => l_lock_records
  , p_sort_by_req_date          => l_sort_by_req_date
   );


   IF ((p_order_quantity_uom IS NULL ) AND (p_inventory_item_id IS NULL)) THEN 	   --added condition for 3745318
   -- Start 2346233
	   BEGIN
	      Select order_quantity_uom, inventory_item_id
	      Into   l_order_quantity_uom, l_inventory_item_id
	      From   oe_order_lines_all
	      Where  line_id = p_line_id;

	   EXCEPTION
	      WHEN OTHERS THEN
		  l_order_quantity_uom := Null;
	   END;
	   ---- End 2346233
   ELSE
      l_order_quantity_uom :=p_order_quantity_uom;
      l_inventory_item_id  :=p_inventory_item_id;
   END IF;


   FOR I IN 1..l_rsv_tbl.COUNT LOOP

      ----
      IF nvl(l_order_quantity_uom,l_rsv_tbl(I).reservation_uom_code)
                                <> l_rsv_tbl(I).reservation_uom_code THEN
         l_converted_qty := INV_CONVERT.INV_UM_CONVERT(l_inventory_item_id -- INVCONV
                                                      ,5 --NULL
                                                      ,l_rsv_tbl(I).reservation_quantity
                                                      ,l_rsv_tbl(I).reservation_uom_code
                                                      ,l_order_quantity_uom
                                                      ,NULL -- From uom name
                                                      ,NULL -- To uom name
                                                      );


        l_reserved_quantity := l_reserved_quantity + l_converted_qty;
     ELSE
     --- End 2346233

        l_reserved_quantity := l_reserved_quantity +
                                l_rsv_tbl(I).reservation_quantity;
     END IF;
     l_reserved_quantity2 := l_reserved_quantity2 +
                                 l_rsv_tbl(I).secondary_reservation_quantity;

  END LOOP;

	if l_debug_level > 0 then -- INVCONV
      oe_debug_pub.add('leaving get_reserved_quantities  qty = :' || l_reserved_quantity  );
      oe_debug_pub.add('leaving get_reserved_quantities  qty2 = :' || l_reserved_quantity2  );
 	end if;

  x_reserved_quantity  := l_reserved_quantity;
  x_reserved_quantity2  := l_reserved_quantity2;

end get_reserved_quantities;
-- INVCONV





/*----------------------------------------------------------
FUNCTION Get_Reserved_Quantity
-- mpetrosi 02-Jun-2000 added org_id start change
-----------------------------------------------------------*/

FUNCTION Get_Reserved_Quantity
( p_header_id                       IN NUMBER
 ,p_line_id                         IN NUMBER
 ,p_org_id                          IN NUMBER
 ,p_order_quantity_uom                IN VARCHAR2 DEFAULT NULL	--3745318
 ,p_inventory_item_id		    IN NUMBER DEFAULT NULL	--3745318
)RETURN NUMBER
IS

-- mpetrosi 02-Jun-2000 added org_id end change

l_reserved_quantity     NUMBER := 0;
l_return_status         VARCHAR2(1);
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(240);

l_rsv_rec               inv_reservation_global.mtl_reservation_rec_type;
l_rsv_tbl               inv_reservation_global.mtl_reservation_tbl_type;
l_count                 NUMBER;
l_x_error_code          NUMBER;
l_lock_records          VARCHAR2(1);
l_sort_by_req_date      NUMBER;
--- 2346233
l_converted_qty         NUMBER;
l_inventory_item_id     NUMBER;
l_order_quantity_uom    VARCHAR2(30);
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

BEGIN
		if l_debug_level > 0 then -- INVCONV
                	oe_debug_pub.add('in get_reserved_quantity ' );
                 end if;
   l_rsv_rec.demand_source_header_id  := p_header_id;
   l_rsv_rec.demand_source_line_id    := p_line_id;

   -- mpetrosi OPM 02-jun-2000 added org_id start change
   l_rsv_rec.organization_id           := p_org_id;
   -- mpetrosi OPM 02-jun-2000 added org_id end change

   inv_reservation_pub.query_reservation_om_hdr_line
   (  p_api_version_number        => 1.0
  , p_init_msg_lst              => fnd_api.g_true
  , x_return_status             => l_return_status
  , x_msg_count                 => l_msg_count
  , x_msg_data                  => l_msg_data
  , p_query_input               => l_rsv_rec
  , x_mtl_reservation_tbl       => l_rsv_tbl
  , x_mtl_reservation_tbl_count => l_count
  , x_error_code                => l_x_error_code
  , p_lock_records              => l_lock_records
  , p_sort_by_req_date          => l_sort_by_req_date
   );


   IF ((p_order_quantity_uom IS NULL ) AND (p_inventory_item_id IS NULL)) THEN 	   --added condition for 3745318
   -- Start 2346233
	   BEGIN
	      Select order_quantity_uom, inventory_item_id
	      Into   l_order_quantity_uom, l_inventory_item_id
	      From   oe_order_lines_all
	      Where  line_id = p_line_id;

	   EXCEPTION
	      WHEN OTHERS THEN
		  l_order_quantity_uom := Null;
	   END;
	   ---- End 2346233
   ELSE
      l_order_quantity_uom :=p_order_quantity_uom;
      l_inventory_item_id  :=p_inventory_item_id;
   END IF;


   FOR I IN 1..l_rsv_tbl.COUNT LOOP

      l_rsv_rec := l_rsv_tbl(I);
      ---- Start 2346233
      IF nvl(l_order_quantity_uom,l_rsv_rec.reservation_uom_code)
                                <> l_rsv_rec.reservation_uom_code THEN
         l_converted_qty := INV_CONVERT.INV_UM_CONVERT(l_inventory_item_id -- INVCONV
                                                      ,5 --NULL
                                                      ,l_rsv_rec.reservation_quantity
                                                      ,l_rsv_rec.reservation_uom_code
                                                      ,l_order_quantity_uom
                                                      ,NULL -- From uom name
                                                      ,NULL -- To uom name
                                                      );


        l_reserved_quantity := l_reserved_quantity + l_converted_qty;
     ELSE
     --- End 2346233

        l_reserved_quantity := l_reserved_quantity +
                                 l_rsv_rec.reservation_quantity;
     END IF; -- 2346233

   END LOOP;


if l_debug_level > 0 then -- INVCONV
                	oe_debug_pub.add('leaving get_reserved_quantity. qty = :' || l_reserved_quantity  );
end if;
   return (l_reserved_quantity);

END Get_Reserved_Quantity;

/*----------------------------------------------------------
FUNCTION Get_Reserved_Quantity2   INVCONV
-----------------------------------------------------------*/

FUNCTION Get_Reserved_Quantity2
( p_header_id                       IN NUMBER
 ,p_line_id                         IN NUMBER
 ,p_org_id                          IN NUMBER
)RETURN NUMBER
IS

l_reserved_quantity2     NUMBER := 0;
l_return_status         VARCHAR2(1);
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(240);

l_rsv_rec               inv_reservation_global.mtl_reservation_rec_type;
l_rsv_tbl               inv_reservation_global.mtl_reservation_tbl_type;
l_count                 NUMBER;
l_x_error_code          NUMBER;
l_lock_records          VARCHAR2(1);
l_sort_by_req_date      NUMBER;
--- 2346233
l_converted_qty         NUMBER;
l_inventory_item_id     NUMBER;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;


BEGIN
   if l_debug_level > 0 then -- INVCONV
                	oe_debug_pub.add('in get_reserved_quantity ' );
    end if;
   l_rsv_rec.demand_source_header_id  := p_header_id;
   l_rsv_rec.demand_source_line_id    := p_line_id;

   l_rsv_rec.organization_id           := p_org_id;

   inv_reservation_pub.query_reservation_om_hdr_line
   (  p_api_version_number        => 1.0
  , p_init_msg_lst              => fnd_api.g_true
  , x_return_status             => l_return_status
  , x_msg_count                 => l_msg_count
  , x_msg_data                  => l_msg_data
  , p_query_input               => l_rsv_rec
  , x_mtl_reservation_tbl       => l_rsv_tbl
  , x_mtl_reservation_tbl_count => l_count
  , x_error_code                => l_x_error_code
  , p_lock_records              => l_lock_records
  , p_sort_by_req_date          => l_sort_by_req_date
   );

   FOR I IN 1..l_rsv_tbl.COUNT LOOP

      l_rsv_rec := l_rsv_tbl(I);
      l_reserved_quantity2 := l_reserved_quantity2 +
                                 l_rsv_rec.secondary_reservation_quantity;

   END LOOP;
if l_debug_level > 0 then -- INVCONV
       oe_debug_pub.add('leaving get_reserved_quantity2. qty2 = :' || l_reserved_quantity2  );
end if;

   return (l_reserved_quantity2);

END Get_Reserved_Quantity2;




/*----------------------------------------------------------
FUNCTION Get_Open_Quantity
-----------------------------------------------------------*/

FUNCTION Get_Open_Quantity(p_header_id        IN NUMBER,
                           p_line_id          IN NUMBER,
                           p_ordered_quantity IN NUMBER,
                           p_shipped_quantity IN NUMBER)
RETURN NUMBER
IS
l_open_quantity         NUMBER := 0;
l_reserved_quantity     NUMBER := 0;
l_mtl_sales_order_id    NUMBER;
l_return_status         VARCHAR2(1);
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(240);

l_rsv_rec               inv_reservation_global.mtl_reservation_rec_type;
l_rsv_tbl               inv_reservation_global.mtl_reservation_tbl_type;
l_count                 NUMBER;
l_x_error_code          NUMBER;
l_lock_records          VARCHAR2(1);
l_sort_by_req_date      NUMBER;
l_converted_qty         NUMBER;
l_inventory_item_id     NUMBER;
l_order_quantity_uom    VARCHAR2(30);
BEGIN

   l_mtl_sales_order_id := OE_HEADER_UTIL.Get_Mtl_Sales_Order_Id
                          (p_header_id=>p_header_id);


/* This part is commented to fix the bug 2136256.
   Once we fix the uom conversion issue in Get_Reserved_Quantity
   we will revert the changes.
   l_reserved_quantity  := Get_Reserved_Quantity (l_mtl_sales_order_id,
                                                 p_line_id);
*/



   l_rsv_rec.demand_source_header_id  := l_mtl_sales_order_id;
   l_rsv_rec.demand_source_line_id    := p_line_id;

   -- mpetrosi OPM 02-jun-2000 added org_id start change
   l_rsv_rec.organization_id           := Null;
   -- mpetrosi OPM 02-jun-2000 added org_id end change

   inv_reservation_pub.query_reservation_om_hdr_line
   (  p_api_version_number        => 1.0
  , p_init_msg_lst              => fnd_api.g_true
  , x_return_status             => l_return_status
  , x_msg_count                 => l_msg_count
  , x_msg_data                  => l_msg_data
  , p_query_input               => l_rsv_rec
  , x_mtl_reservation_tbl       => l_rsv_tbl
  , x_mtl_reservation_tbl_count => l_count
  , x_error_code                => l_x_error_code
  , p_lock_records              => l_lock_records
  , p_sort_by_req_date          => l_sort_by_req_date
   );

   BEGIN

        Select order_quantity_uom, inventory_item_id
        Into   l_order_quantity_uom, l_inventory_item_id
        From   oe_order_lines_all
        Where  line_id = p_line_id;

   EXCEPTION
    WHEN OTHERS THEN

     l_order_quantity_uom := Null;
   END;
   FOR I IN 1..l_rsv_tbl.COUNT LOOP

      l_rsv_rec := l_rsv_tbl(I);

      IF nvl(l_order_quantity_uom,l_rsv_rec.reservation_uom_code)
                                <> l_rsv_rec.reservation_uom_code THEN

        oe_debug_pub.add('reservation_uom_code :' ||
                              l_rsv_rec.reservation_uom_code,3);
        oe_debug_pub.add('l_order_quantity_uom :' ||
                              l_order_quantity_uom,3);
        oe_debug_pub.add('reservation_quantity :' ||
                              l_rsv_rec.reservation_quantity,3);
        l_converted_qty :=
        Oe_Order_Misc_Util.convert_uom( l_inventory_item_id,
				     l_rsv_rec.reservation_uom_code,
				     l_order_quantity_uom,
			             l_rsv_rec.reservation_quantity);

        oe_debug_pub.add('l_converted_qty :' || l_converted_qty,3);
        l_reserved_quantity := l_reserved_quantity +
                               l_converted_qty;
      ELSE

        oe_debug_pub.add('2 reservation_quantity :' ||
                              l_rsv_rec.reservation_quantity);
        l_reserved_quantity := l_reserved_quantity +
                                 l_rsv_rec.reservation_quantity;
      END IF;

   END LOOP;

   l_open_quantity      := p_ordered_quantity -
                           nvl(p_shipped_quantity,0) -
                           l_reserved_quantity;

  RETURN l_open_quantity;

EXCEPTION

WHEN NO_DATA_FOUND THEN
		RETURN NULL;

END Get_Open_Quantity;



/*----------------------------------------------------------
FUNCTION Get_Primary_Uom_Quantity
-----------------------------------------------------------*/

FUNCTION Get_Primary_Uom_Quantity(p_ordered_quantity IN NUMBER,
                                  p_order_quantity_uom IN VARCHAR2)
RETURN NUMBER
IS
BEGIN
    RETURN p_ordered_quantity;

EXCEPTION

WHEN NO_DATA_FOUND THEN
		RETURN NULL;

END Get_Primary_Uom_Quantity;


-- check whether total returned quantity (this line plus all previous
-- lines ) is more than ordered



/*----------------------------------------------------------
Function Is_Over_Return
-----------------------------------------------------------*/

Function Is_Over_Return
(   p_line_rec                      IN OE_Order_PUB.Line_Rec_Type
) RETURN BOOLEAN
IS
l_total NUMBER;
l_orig_quantity NUMBER;
l_upgraded_flag varchar2(1);
l_srl_num_count NUMBER;

l_overship_invoice_basis    varchar2(30) := null;  --bug# 6617423

CURSOR C_LOT_SERIAL(p_serial_num VARCHAR2) IS
    SELECT line_id,line_set_id,from_serial_number,to_serial_number
    FROM oe_lot_serial_numbers
    WHERE from_serial_number = p_serial_num
    OR to_serial_number = p_serial_num;
    l_ref_line_id NUMBER;

BEGIN

 oe_debug_pub.ADD('Entering Over Return',1);

 /*
 ** Fix Bug # 2971412
 ** Since this validation used to get performed even in older
 ** releases. There is no need to suppress it for upgraded orders
 **
 IF p_line_rec.reference_line_id is not null THEN

	select nvl(upgraded_flag,'-') into l_upgraded_flag
     from oe_order_lines
     where line_id = p_line_rec.reference_line_id;

     IF l_upgraded_flag in ('Y','P') THEN
          return FALSE;
     END IF;

  END IF;
  */

  oe_debug_pub.ADD('Return Context is: '||p_line_rec.return_context,1);
  oe_debug_pub.ADD('Line Id is: '||to_char(p_line_rec.line_id),1);
  oe_debug_pub.ADD('Reference Line Id is: '||to_char(p_line_rec.reference_line_id),1);

  -- Fix for Bug # 1613371
  IF p_line_rec.return_context = 'SERIAL' THEN

       FOR C2 IN C_LOT_SERIAL(p_line_rec.return_attribute2) LOOP

       -- If record exists in oe_lot_serial_numbers for the entered SN,
       -- check the line_set_id on it. There will be a value for line_set_id
       -- if the RMA line has got split. Get the reference line_id from the
       -- following queries.

            IF C2.line_set_id is not null THEN
                 select distinct reference_line_id
                 into l_ref_line_id
                 from oe_line_sets a,
                      oe_order_lines b
                 where a.set_id = C2.line_set_id
                 and a.line_id = b.line_id
                 and b.booked_flag = 'Y'
                 and b.line_id <> p_line_rec.line_id
                 and b.cancelled_flag <> 'Y';
            ELSE
                 select reference_line_id
                 into l_ref_line_id
                 from oe_order_lines
                 where line_id = C2.line_id
                 and line_id <> p_line_rec.line_id
                 and booked_flag = 'Y'
                 and cancelled_flag <> 'Y';
            END IF;
            IF l_ref_line_id = p_line_rec.reference_line_id THEN
                RETURN TRUE;
            END IF;
       END LOOP;
  END IF;

  oe_debug_pub.ADD('Before checking the total for the Outbound line',1);
  SELECT sum(nvl(ordered_quantity, 0))
  INTO l_total
  FROM   oe_order_lines
  WHERE reference_line_id = p_line_rec.reference_line_id
  AND ((booked_flag = 'Y' and header_id <> p_line_rec.header_id)
    OR (header_id = p_line_rec.header_id))
  AND cancelled_flag <> 'Y'
  AND line_category_code = 'RETURN'
  AND line_id <> p_line_rec.line_id;

  oe_debug_pub.ADD('l_total : '||to_char(l_total),1);


    -- bug# 6617423 : Start  -----------
  /*
      SELECT nvl(ordered_quantity, 0)
      INTO l_orig_quantity
      FROM oe_order_lines
      WHERE line_id = p_line_rec.reference_line_id;
   */

    oe_debug_pub.add( ' <in Is_Over_Return >    p_line_rec.org_id = '|| p_line_rec.org_id, 5 ) ;
    IF p_line_rec.org_id = FND_API.G_MISS_NUM THEN   ---no need to handle null, automatically handled
       l_overship_invoice_basis := oe_sys_parameters.value('OE_OVERSHIP_INVOICE_BASIS',NULL);
    ELSE
       l_overship_invoice_basis := oe_sys_parameters.value('OE_OVERSHIP_INVOICE_BASIS',p_line_rec.org_id);
    END IF;
    oe_debug_pub.add(  ' <in Is_Over_Return >  l_overship_invoice_basis = '|| l_overship_invoice_basis , 5 ) ;
    oe_debug_pub.add(  ' <in Is_Over_Return >  p_line_rec.reference_line_id = '|| p_line_rec.reference_line_id , 5) ;

    IF l_overship_invoice_basis = 'SHIPPED' then
      SELECT nvl(shipped_quantity, ordered_quantity)  --- get from ord_qty if original line not shipped/invoiced....
      INTO l_orig_quantity
      FROM oe_order_lines
      WHERE line_id = p_line_rec.reference_line_id;
    ELSE
      SELECT nvl(ordered_quantity, 0)
      INTO l_orig_quantity
      FROM oe_order_lines
      WHERE line_id = p_line_rec.reference_line_id;
    end if;
    -- bug# 6617423: End -------


  oe_debug_pub.ADD('l_orig_quantity : '||to_char(l_orig_quantity),1);

  IF nvl(l_total,0) + p_line_rec.ordered_quantity > l_orig_quantity THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
   oe_debug_pub.ADD('In NO DATA FOUND ',1);
    RETURN FALSE;
END Is_Over_Return;



/*----------------------------------------------------------
PROCEDURE Get_Inventory_Item
-----------------------------------------------------------*/

PROCEDURE Get_Inventory_Item
(p_x_line_rec       IN OUT NOCOPY    OE_Order_Pub.Line_Rec_Type
,x_return_status  OUT NOCOPY /* file.sql.39 change */  VARCHAR2
)
IS
/* Variables to call process order */
l_line_tbl                         OE_ORDER_PUB.Line_Tbl_Type;
l_old_line_tbl					OE_ORDER_PUB.Line_Tbl_Type;
l_control_rec                 	OE_GLOBALS.Control_Rec_Type;

l_attribute_value             VARCHAR2(2000);
l_address_id                  VARCHAR2(2000):= NULL;
l_cust_id                     NUMBER:= NULL;
l_update_inventory_item       VARCHAR2(1) := FND_API.G_FALSE;
l_inventory_item_id           NUMBER;
l_error_code                  VARCHAR2(2000);
l_error_flag                  VARCHAR2(2000);
l_error_message               VARCHAR2(2000);
BEGIN

        /*
         1.call  INV_CUSTOMER_ITEM_GRP.CI_Attribute_Value
           to get the inventory_item_id
           given the customer_item_id, and the new ship_from_org_id.

         2.check the value of the inventory_item_id returned:
           if internal item number return is not null, then
           assign the inventory_item_id to the out parameter
           otherwise
           post  message OE_INVALIDATES_CUSTOMER_ITEM
           set return status to error.
          */

    oe_debug_pub.add('Entering Get_Inventory_Item', 1);
    IF (p_x_line_rec.ship_to_org_id IS NOT NULL AND
        p_x_line_rec.ship_to_org_id <> FND_API.G_MISS_NUM) THEN
        /* Replaced with the following SELECT and IF statements
           to fix bug 2163988
        SELECT  cust_acct_site_id
        INTO  l_address_id
        FROM  HZ_CUST_SITE_USES
        WHERE  site_use_id = p_x_line_rec.ship_to_org_id
        AND  site_use_code = 'SHIP_TO';
        */

        SELECT  /*MOAC_SQL_CHANGES*/ u.cust_acct_site_id,
                s.cust_account_id
        INTO  l_address_id,
              l_cust_id
        FROM  HZ_CUST_SITE_USES_ALL u,
              HZ_CUST_ACCT_SITES s
        WHERE  u.cust_acct_site_id = s.cust_acct_site_id
        AND    u.site_use_id = p_x_line_rec.ship_to_org_id
        AND    u.site_use_code = 'SHIP_TO';
        oe_debug_pub.add('ship to address:' || l_address_id||' - Customer:'||to_char(l_cust_id));

        IF l_cust_id <> p_x_line_rec.sold_to_org_id  THEN
          oe_debug_pub.add('Sold-To Customer:'||to_char(p_x_line_rec.sold_to_org_id));
          l_address_id := NULL;
        END IF;

    END IF;

    oe_debug_pub.add('INVENTORY_ITEM_ID Before calling CI_Attribute_Value '
	||to_char(p_x_line_rec.inventory_item_id), 1);
    --Start of bug# 13574394
    oe_debug_pub.add('p_x_line_rec.line_category_code = '||p_x_line_rec.line_category_code);

    IF  p_x_line_rec.line_category_code = 'RETURN' THEN
        oe_debug_pub.add('Its a Return Order Line ');

    INV_CUSTOMER_ITEM_GRP.CI_Attribute_Value(
                       Z_Customer_Item_Id => p_x_line_rec.ordered_item_id
                   , Z_Customer_Id => p_x_line_rec.sold_to_org_id
                   , Z_Address_Id => l_address_id
                   , Z_Organization_Id => nvl(p_x_line_rec.ship_from_org_id, OE_Sys_Parameters.value('MASTER_ORGANIZATION_ID'))
    -- This change is required since we are dropping the profile OE_ORGANIZATION    -- _ID. Change made by Esha.
                   , Z_Inventory_Item_Id => p_x_line_rec.inventory_item_id
                   , Attribute_Name => 'INVENTORY_ITEM_ID'
                   , Error_Code => l_error_code
                   , Error_Flag => l_error_flag
                   , Error_Message => l_error_message
                   , Attribute_Value => l_attribute_value
                   , Z_Line_Category_Code => 'RETURN'
                     );
    ELSE
       OE_DEBUG_PUB.ADD('Its a Normal Order Line');

       INV_CUSTOMER_ITEM_GRP.CI_Attribute_Value(
                       Z_Customer_Item_Id => p_x_line_rec.ordered_item_id
                   , Z_Customer_Id => p_x_line_rec.sold_to_org_id
                   , Z_Address_Id => l_address_id
                   , Z_Organization_Id => nvl(p_x_line_rec.ship_from_org_id, OE_Sys_Parameters.value('MASTER_ORGANIZATION_ID'))
    -- This change is required since we are dropping the profile OE_ORGANIZATION    -- _ID. Change made by Esha.
                   , Z_Inventory_Item_Id => p_x_line_rec.inventory_item_id
                   , Attribute_Name => 'INVENTORY_ITEM_ID'
                   , Error_Code => l_error_code
                   , Error_Flag => l_error_flag
                   , Error_Message => l_error_message
                   , Attribute_Value => l_attribute_value
                   , Z_Line_Category_Code => 'ORDER'
                     );
   END IF;		--End of bug# 13574394


    oe_debug_pub.add('INVENTORY_ITEM_ID After call is '||l_attribute_value, 1);
    IF (l_attribute_value IS NOT NULL AND
       to_number(l_attribute_value) <> p_x_line_rec.inventory_item_id) THEN
       oe_debug_pub.add('Assigning new inventory_item_id', 1);
       l_update_inventory_item := FND_API.G_TRUE;
       l_inventory_item_id := TO_NUMBER(l_attribute_value);
    ELSIF to_number(l_attribute_value) = p_x_line_rec.inventory_item_id THEN
       NULL;
    ELSE
       oe_debug_pub.add('Issue error message', 1);
       oe_debug_pub.add('l_error_code: ' || l_error_code, 1);
       oe_debug_pub.add('l_error_flag: ' || l_error_flag, 1);
       oe_debug_pub.add('l_error_message: ' || l_error_message, 1);
       oe_debug_pub.add('p_x_line_rec.ordered_item_id:'||p_x_line_rec.ordered_item_id,1);
       fnd_message.set_name('ONT','OE_INVALIDATES_CUSTOMER_ITEM');
       OE_MSG_PUB.Add;
       x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    oe_debug_pub.add('Return Status after calling CI_Attribute_Value '||x_return_status, 1);
    IF l_update_inventory_item = FND_API.G_TRUE THEN

     -- Call Process Order

     oe_debug_pub.add('Calling Process order to update inventory item', 1);
	l_control_rec.controlled_operation := TRUE;
	l_control_rec.check_security		:= TRUE;
    	l_control_rec.clear_dependents 	:= TRUE;
	l_control_rec.default_attributes	:= TRUE;
	l_control_rec.change_attributes	:= TRUE;
	l_control_rec.validate_entity		:= TRUE;
    	l_control_rec.write_to_DB          := FALSE;
    	l_control_rec.process := FALSE;

	l_old_line_tbl(1) 				:= p_x_line_rec;
     l_line_tbl(1) 					:= p_x_line_rec;
     l_line_tbl(1).inventory_item_id 	:= l_inventory_item_id;

	Oe_Order_Pvt.Lines
	(    p_validation_level			=> FND_API.G_VALID_LEVEL_NONE
	,	p_control_rec				=> l_control_rec
	,	p_x_line_tbl				=> l_line_tbl
	,	p_x_old_line_tbl			=> l_old_line_tbl
	,    x_return_status               => x_return_status
	);

     oe_debug_pub.add('Return Status after calling Process order'||x_return_status, 1);

     p_x_line_rec := l_line_tbl(1);

   END IF;

   oe_debug_pub.add('Exiting Get_Inventory_Item', 1);

END Get_Inventory_Item;



/*----------------------------------------------------------
PROCEDURE Clear_Shipping_Method
-----------------------------------------------------------*/

PROCEDURE Clear_Shipping_Method
(p_x_line_rec				IN OUT NOCOPY OE_Order_PUB.Line_Rec_Type)
IS
l_old_line_tbl				OE_Order_PUB.Line_Tbl_Type;
l_line_tbl				OE_Order_PUB.Line_Tbl_Type;
l_control_rec				OE_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(30);
BEGIN

	l_control_rec.controlled_operation := TRUE;
	l_control_rec.check_security		:= TRUE;
    	l_control_rec.clear_dependents 	:= FALSE;
	l_control_rec.default_attributes	:= FALSE;
	l_control_rec.change_attributes	:= TRUE;
	l_control_rec.validate_entity		:= FALSE;
    	l_control_rec.write_to_DB          := FALSE;
    	l_control_rec.process := FALSE;

	l_old_line_tbl(1) 				:= p_x_line_rec;
	l_line_tbl(1) 					:= p_x_line_rec;
	l_line_tbl(1).freight_carrier_code := NULL;
	l_line_tbl(1).shipping_method_code := NULL;

	Oe_Order_Pvt.Lines
	(    p_validation_level			=> FND_API.G_VALID_LEVEL_NONE
	,	p_control_rec			=> l_control_rec
	,	p_x_line_tbl			=> l_line_tbl
	,	p_x_old_line_tbl		=> l_old_line_tbl
	,    x_return_status          => l_return_status
	);

	IF l_return_status = FND_API.G_RET_STS_ERROR THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	p_x_line_rec := l_line_tbl(1);

END Clear_Shipping_Method;



/*----------------------------------------------------------
PROCEDURE Clear_Commitment_Id
-----------------------------------------------------------*/

PROCEDURE Clear_Commitment_Id
      (p_x_line_rec                 IN OUT NOCOPY OE_Order_PUB.Line_Rec_Type)
IS
l_old_line_tbl                OE_Order_PUB.Line_Tbl_Type;
l_line_tbl                    OE_Order_PUB.Line_Tbl_Type;
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(30);
BEGIN

     l_control_rec.controlled_operation := TRUE;
     l_control_rec.check_security       := TRUE;
     l_control_rec.clear_dependents     := FALSE;
     l_control_rec.default_attributes   := FALSE;
     l_control_rec.change_attributes    := TRUE;
     l_control_rec.validate_entity      := FALSE;
     l_control_rec.write_to_DB          := FALSE;
     l_control_rec.process := FALSE;

     l_old_line_tbl(1)                  := p_x_line_rec;
     l_line_tbl(1)                      := p_x_line_rec;
     l_line_tbl(1).commitment_id        := NULL;
     --l_line_tbl(1).shipping_method_code := NULL;

     Oe_Order_Pvt.Lines
     (    p_validation_level            => FND_API.G_VALID_LEVEL_NONE
   ,    p_control_rec            => l_control_rec
   ,    p_x_line_tbl             => l_line_tbl
   ,    p_x_old_line_tbl         => l_old_line_tbl
   ,    x_return_status          => l_return_status
     );

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     p_x_line_rec := l_line_tbl(1);

END Clear_Commitment_Id;

--7688372 start
PROCEDURE Load_attachment_rules_Line
IS
   CURSOR line_attributes IS
   SELECT oare.ATTRIBUTE_CODE  attribute_code,Count(1) attachment_count
   FROM   oe_attachment_rule_elements oare, oe_attachment_rules  oar
   WHERE  oare.rule_id=oar.rule_id
   AND    oar.DATABASE_OBJECT_NAME='OE_AK_ORDER_LINES_V'
   GROUP BY oare.ATTRIBUTE_CODE;

l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

BEGIN
 IF l_debug_level > 0 then
  oe_debug_pub.add('Entering Line Load_attachment_rules');
 End IF;

 IF g_attachrule_count_line_tab.count = 0 THEN
   FOR line_attributes_rec IN line_attributes LOOP
      g_attachrule_count_line_tab(line_attributes_rec.attribute_code) := line_attributes_rec.attachment_count;
   END LOOP;
 END IF;

 IF l_debug_level > 0 then
  oe_debug_pub.add('Exiting Line Load_attachment_rules');
 End IF;

END Load_attachment_rules_Line;
--7688372 end




/*----------------------------------------------------------
 PROCEDURE Pre_Write_Process
-----------------------------------------------------------*/

PROCEDURE Pre_Write_Process
(   p_x_line_rec                    IN OUT NOCOPY  OE_Order_PUB.Line_Rec_Type
,   p_old_line_rec                  IN  OE_Order_PUB.Line_Rec_Type :=
								OE_Order_PUB.G_MISS_LINE_REC
) IS
l_atp_tbl               OE_ATP.atp_tbl_type;
l_return_status         varchar2(30);
l_split_action_code     varchar2(30);
l_param1                VARCHAR2(2000):= null;
l_param2                VARCHAR2(240) := null;
l_param3                VARCHAR2(240) := null;
l_param4                VARCHAR2(240) := null;
l_param5                VARCHAR2(240) := null;
l_param6                VARCHAR2(240) := null;
l_param9                VARCHAR2(240) := null;
l_param10               VARCHAR2(240) := null;
l_param11               VARCHAR2(240) := null;
l_param12               VARCHAR2(240) := null;
l_flag                  BOOLEAN;
l_count			NUMBER;
l_num                   NUMBER;
l_msg_count                 NUMBER;
l_msg_data                  VARCHAR2(2000);

l_delta_qty                 NUMBER;
l_delta_extended_amount     NUMBER;
l_old_qty                   NUMBER;
l_new_qty                   NUMBER;
l_new_unit_selling_price    NUMBER;
l_old_unit_selling_price    NUMBER;
l_old_extended_amount       NUMBER;
l_new_extended_amount       NUMBER;
l_parent_document_type_id   NUMBER;
l_pricing_event             VARCHAR2(30);
l_require_reason            BOOLEAN ; -- 2921731
l_promise_date_flag         VARCHAR2(2);
--bug 4190357
v_count                     NUMBER;
l_meaning                   VARCHAR2(80);
--bug 4190357
l_modified_from             VARCHAR2(30);

l_line_payment_type_code    VARCHAR2(30);


--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
l_attr_attach_change         boolean := FALSE;  --6896311

-- Bug 8940667,8947394 begin
i number;
l_G_Delayed_Requests OE_ORDER_PUB.Request_Tbl_Type;
-- Bug 8940667,8947394 end

l_ship_to_org_id           NUMBER;  --Bug# 5521035

BEGIN

if l_debug_level > 0 then
 oe_debug_pub.Add('Entering pre_write_process for line ID  : '||p_x_line_rec.line_id, 1);
end if;

-- bug fix 3350185:
-- Audit Trail/Versioning moved to separate procedure below
   Version_Audit_Process( p_x_line_rec => p_x_line_rec,
                          p_old_line_rec => p_old_line_rec,
                          p_process_step => 1 );


if l_debug_level > 0 then
   oe_debug_pub.Add('After Assign out rec', 1);
end if;

   ------------------------------------------------------------------------
   -- Copy corresponding inventory item to the line if it is a CUST item
   ------------------------------------------------------------------------

   IF NOT OE_GLOBALS.EQUAL(p_x_line_rec.ship_from_org_id ,
                           p_old_line_rec.ship_from_org_id) OR
      NOT OE_GLOBALS.EQUAL(p_x_line_rec.ship_to_org_id ,
                        p_old_line_rec.ship_to_org_id) THEN
      if l_debug_level > 0 then
         oe_debug_pub.Add('RR:I1', 1);
      end if;
      IF p_x_line_rec.item_identifier_type = 'CUST' THEN
         if l_debug_level > 0 then
            oe_debug_pub.Add('RR:I2', 1);
         end if;
         IF (p_x_line_rec.ordered_item_id IS NOT NULL AND
             p_x_line_rec.ordered_item_id <> FND_API.G_MISS_NUM) THEN
            if l_debug_level > 0 then
               oe_debug_pub.add('return_status before calling Get_Inventory_Item '
				||l_return_status, 1);
            end if;
            Get_Inventory_Item
			( p_x_line_rec  	=> p_x_line_rec
            	, x_return_status	=> l_return_status);

            if l_debug_level > 0 then
               oe_debug_pub.add('return_status after calling Get_Inventory_Item '||l_return_status, 1);
            end if;
         END IF;
      END IF;
   if l_debug_level > 0 then
      oe_debug_pub.Add('RR:I2.5', 1);
   end if;
   END IF;

   if l_debug_level > 0 then
      oe_debug_pub.Add('RR:I3', 1);
   end if;

   IF l_return_status = FND_API.G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR;
   END IF;
   IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;


   ------------------------------------------------------------------------
   -- Populate ordered item field if item identifier type is INT or CUST
   /*Bug 2411113*/
   ------------------------------------------------------------------------

   IF (NOT OE_GLOBALS.EQUAL(p_x_line_rec.inventory_item_id ,
                           p_old_line_rec.inventory_item_id)
   AND p_x_line_rec.item_identifier_type in ('INT', 'CUST'))
OR
   (p_x_line_rec.ordered_item =  FND_API.G_MISS_CHAR
   AND p_x_line_rec.item_identifier_type in ('INT', 'CUST')) THEN

      if l_debug_level > 0 then
         oe_debug_pub.Add('Before calling get_ordered_item', 1);
         oe_debug_pub.add('return_status before calling Get_ordered_Item '
				||l_return_status, 1);
      end if;
         Oe_Oe_Form_Line.Get_Ordered_Item
            	 (x_return_status	=> l_return_status,
                  x_msg_count => l_msg_count,
                  x_msg_data => l_msg_data,
                  p_item_identifier_type =>p_x_line_rec.item_identifier_type,
                  p_inventory_item_id => p_x_line_rec.inventory_item_id,
                  p_ordered_item_id => p_x_line_rec.ordered_item_id,
                  p_sold_to_org_id => p_x_line_rec.sold_to_org_id,
                  x_ordered_item => p_x_line_rec.ordered_item);

      if l_debug_level > 0 then
         oe_debug_pub.add('return_status after calling Get_Ordered_Item '||l_return_status, 1);
      end if;

       --Fix for bug 3728638.
       IF p_x_line_rec.item_identifier_type='INT'
          and p_x_line_rec.ordered_item_id is NULL then
             p_x_line_rec.ordered_item_id:=p_x_line_rec.inventory_item_id;
       END IF;

   END IF;


   IF l_return_status = FND_API.G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR;
   END IF;
   IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;


   -------------------------------------------------------------------------
   -- lkxu: log a request to copy pricing attributes from top model line
   -- to the children lines
   --
   -- rlanka: changes made to fix bug 1730452
   -- rlanka: changes made to fix bug 1857538
   -------------------------------------------------------------------------

   IF (p_x_line_rec.item_type_code = OE_GLOBALS.G_ITEM_OPTION OR
       p_x_line_rec.item_type_code = OE_GLOBALS.G_ITEM_CLASS OR
      (p_x_line_rec.item_type_code = OE_GLOBALS.G_ITEM_KIT and
       p_x_line_rec.line_id <> p_x_line_rec.top_model_line_id)) AND
       p_x_line_rec.operation = OE_GLOBALS.G_OPR_CREATE AND
	  p_x_line_rec.split_from_line_id IS NULL THEN


	/* Fix for bug 1730452 (May 1, 2001)
	   if (model line has been copied from another order)
	      Do NOT copy the pricing attributes of the model
	      to its option/kit/class items.
	   else
	      Log a request to copy the pricing attributes of
	      the top model line to its option/kit/class items.
	   end if;
        */

      if l_debug_level > 0 then
       oe_debug_pub.add('Checking if it is a model line copied from another order');
      end if;

       begin
         select source_document_type_id
         into l_parent_document_type_id
         from oe_order_lines_all
         where line_id = p_x_line_rec.top_model_line_id;

	 exception
	    when NO_DATA_FOUND then NULL;

       end;

 	/* Note: Bug 1857538
	  if source_document_type_id != 2 OR
	     source_document_line_id = NULL, then
		this line has newly been added as an option line (or)
		this line has not been copied from another order
		Log a request to copy pricing attributes from the top model line
	  end if;

       */

      if l_debug_level > 0 then
       oe_debug_pub.add('parent source_document_type_id = ' || l_parent_document_type_id);
      end if;

      if ((nvl(l_parent_document_type_id,0) <> 2) OR
	  (p_x_line_rec.source_document_line_id IS NULL) OR
	  (p_x_line_rec.source_document_line_id = FND_API.G_MISS_NUM)) then

        if l_debug_level > 0 then
         oe_debug_pub.add('This class/kit/option line has not been copied');
	 oe_debug_pub.add('from another order: So, log a delayed request');
	 oe_debug_pub.add('to copy the model pricing attributes');
         oe_debug_pub.add('logging request for line  '||p_x_line_rec.line_id, 1);
        end if;

	/* Fix for bug1857538
           - Log a delayed request to copy pricing attributes, using line_id
             as the entity id.  The corresponding change will be in
             OEXULPAB.pls
	   - Idea is, copy_model_pattr for each option line.
        */
        OE_delayed_requests_Pvt.log_request(
			p_entity_code 		=> OE_GLOBALS.G_ENTITY_LINE,
			p_entity_id         	=> p_x_line_rec.line_id,
			p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
			p_requesting_entity_id   => p_x_line_rec.line_id,
               		p_param1                 => p_x_line_rec.line_id,
	 		p_request_type           => OE_GLOBALS.G_COPY_MODEL_PATTR,
	 		x_return_status          => l_return_status);
      end if;

   END IF;

   -- 2921731, storing and resetting the global cancel variable
   l_require_reason := OE_SALES_CAN_UTIL.G_REQUIRE_REASON;
   --1503357
   OE_LINE_ADJ_UTIL.Check_Canceled_PRG(p_old_line_rec => p_old_line_rec,
                                       p_new_line_rec => p_x_line_rec);

   OE_SALES_CAN_UTIL.G_REQUIRE_REASON := l_require_reason;

/*sdatti*/
   IF (p_x_line_rec.operation = OE_GLOBALS.G_OPR_DELETE OR
       p_x_line_rec.ordered_quantity = 0)
       and OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110509' THEN

       IF Nvl(oe_globals.g_pricing_recursion,'N') = 'N'  THEN
          update_adjustment_flags(p_old_line_rec,p_x_line_rec);
       END IF;
    END IF;
/*sdatti*/

   --Customer Acceptance
    IF NVL(OE_SYS_PARAMETERS.VALUE('ENABLE_FULFILLMENT_ACCEPTANCE'), 'N') = 'Y'
       AND p_x_line_rec.item_type_code= 'SERVICE' and p_x_line_rec.accepted_quantity is NULL THEN
       /*Default Parent acceptance details*/
         OE_ACCEPTANCE_UTIL.Default_Parent_Accept_Details(p_x_line_rec);
    END IF;
   --Customer Acceptance end

   ------------------------------------------------------------------------
   -- log a split payment request to cascade payment information from
   -- the parent line if the line is split
   ------------------------------------------------------------------------

   	IF  p_x_line_rec.operation = OE_GLOBALS.G_OPR_CREATE
	    AND p_x_line_rec.split_from_line_id is not null
            AND  OE_PREPAYMENT_UTIL.IS_MULTIPLE_PAYMENTS_ENABLED
	   THEN

           BEGIN
             SELECT payment_type_code
             INTO   l_line_payment_type_code
             FROM   oe_payments
             WHERE  header_id = p_x_line_rec.header_id
             AND    line_id   = p_x_line_rec.split_from_line_id
             AND    payment_type_code IS NOT NULL
             AND    rownum = 1;
           EXCEPTION WHEN NO_DATA_FOUND THEN
             null;
           END;

           IF l_line_payment_type_code IS NOT NULL THEN
	     oe_debug_pub.add('Log delayed request to cascade payment information for line: '||p_x_line_rec.line_id, 1);
	     OE_Delayed_Requests_Pvt.Log_Request(
	               p_entity_code            =>   OE_GLOBALS.G_ENTITY_LINE,
	               p_entity_id             	=>   p_x_line_rec.line_id,
	               p_requesting_entity_code	=>   OE_GLOBALS.G_ENTITY_LINE,
	               p_requesting_entity_id  	=>   p_x_line_rec.line_id,
	               p_request_type          	=>   OE_GLOBALS.G_SPLIT_PAYMENT,
	               p_param1                 =>   p_x_line_rec.split_from_line_id,
	               p_param2                 =>   p_x_line_rec.header_id,
	               x_return_status          =>   l_return_status);
           END IF;
	 END IF;



   ------------------------------------------------------------------------
   -- log a split hold request if the line is split
   ------------------------------------------------------------------------

   IF  p_x_line_rec.operation = OE_GLOBALS.G_OPR_CREATE AND
    p_x_line_rec.split_from_line_id is not null
   THEN
      if l_debug_level > 0 then
         oe_debug_pub.add('This is a new line after split', 1);
      end if;
         OE_Delayed_Requests_Pvt.Log_Request(
               p_entity_code             =>   OE_GLOBALS.G_ENTITY_LINE,
               p_entity_id               =>   p_x_line_rec.line_id,
               p_requesting_entity_code  =>   OE_GLOBALS.G_ENTITY_LINE,
               p_requesting_entity_id    =>   p_x_line_rec.line_id,
               p_request_type            =>   OE_GLOBALS.G_SPLIT_HOLD,
               p_param1                  =>   p_x_line_rec.split_from_line_id,
               x_return_status           =>   l_return_status);
   END IF;


   ------------------------------------------------------------------------
   -- Log the delayed request for Update Shipping if the line is deleted and
   -- it is interfaced with Shipping.
   ------------------------------------------------------------------------

   -- code fix for 3554622
   -- IF condition modified to log update_shipping delayed request when operations is UPDATE and ship set
   -- nulled out
   IF  l_debug_level > 0
   THEN
       oe_debug_pub.add('New Ship set Id :' || p_x_line_rec.ship_set_id,2);
       oe_debug_pub.add('Old Ship set Id :' || p_old_line_rec.ship_set_id,2);
       oe_debug_pub.add('Split Action:'||p_x_line_rec.split_Action_code,2);
   END IF;
   --8979782 : Logged request for change in warehouse while spliting
   --9366512 : Request to be logged for change of request date and ship_to
   --13444768: Group the attributes correctly in case of split
   -- Bug 12355310 : Replacing check on SI flag by new API
   -- IF	p_x_line_rec.shipping_interfaced_flag = 'Y'             AND
   IF (p_x_line_rec.shipping_interfaced_flag = 'Y' OR
      (p_x_line_rec.shippable_flag = 'Y' AND p_x_line_rec.booked_flag = 'Y'
       AND Shipping_Interfaced_Status(p_x_line_rec.line_id) = 'Y')) AND
     	(  (p_x_line_rec.operation = OE_GLOBALS.G_OPR_CREATE) OR
	   (p_x_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE AND
           (
	    (p_x_line_rec.ship_set_id IS NULL                 AND
	    p_old_line_rec.ship_set_id IS NOT NULL)           --AND
            OR (NOT OE_GLOBALS.Equal(p_x_line_rec.ship_from_org_id,
                          p_old_line_rec.ship_from_org_id))
            OR (NOT OE_GLOBALS.Equal(p_x_line_rec.request_date,
                          p_old_line_rec.request_date))
            OR (NOT OE_GLOBALS.Equal(p_x_line_rec.ship_to_org_id,
                          p_old_line_rec.ship_to_org_id))
           ) AND
	    p_x_line_rec.split_action_code = 'SPLIT'
	   )
	)
   THEN
   -- code fix for 3554622

      if l_debug_level > 0 then
        oe_debug_pub.ADD('Update Shipping : '|| p_x_line_rec.line_id ,1);
      end if;
		OE_Delayed_Requests_Pvt.Log_Request(
		p_entity_code               => OE_GLOBALS.G_ENTITY_LINE,
		p_entity_id                 => p_x_line_rec.line_id,
		p_requesting_entity_code    => OE_GLOBALS.G_ENTITY_LINE,
		p_requesting_entity_id      => p_x_line_rec.line_id,
		p_request_type              => OE_GLOBALS.G_UPDATE_SHIPPING,
		p_request_unique_key1       => p_x_line_rec.operation,
		p_param1                    => FND_API.G_TRUE,
		p_param2                    => FND_API.G_FALSE,
		x_return_status             => l_return_status);

   END IF;
   --bsadri call pricing for deleted lines

   IF p_x_line_rec.operation = OE_GLOBALS.G_OPR_DELETE AND
      p_x_line_rec.order_quantity_uom IS NOT NULL AND
      p_x_line_rec.order_quantity_uom <> FND_API.G_MISS_CHAR AND
      NVL(p_x_line_rec.ordered_quantity,0) <> 0 AND
      p_x_line_rec.Ordered_Quantity <> FND_API.G_MISS_NUM   THEN

         IF (OE_GLOBALS.G_UI_FLAG) and
             OE_GLOBALS.G_DEFER_PRICING='N' and
          (nvl(Oe_Config_Pvt.oecfg_configuration_pricing,'N')='N') THEN
           if l_debug_level > 0 then
              oe_debug_pub.add('ui mode - delete');
           end if;
           IF p_x_line_rec.booked_flag='Y' THEN  --2442012
              l_pricing_event := 'BATCH,ORDER,BOOK';    --7494393
           ELSE
              l_pricing_event := 'ORDER';
           END IF;
           OE_delayed_requests_Pvt.log_request(
             p_entity_code                => OE_GLOBALS.G_ENTITY_ALL,
             p_entity_id                  => p_x_line_rec.Header_Id,
             p_requesting_entity_code     => OE_GLOBALS.G_ENTITY_ALL,
             p_requesting_entity_id       => p_x_line_rec.Header_Id,
             p_request_unique_key1        => l_pricing_event,
             p_param1                     => p_x_line_rec.header_id,
             p_param2                     => l_pricing_event,
             p_request_type               => OE_GLOBALS.G_PRICE_ORDER,
             x_return_status              => l_return_status);
         ELSE
           if l_debug_level > 0 then
              oe_debug_pub.add('batch mode - delete');
           end if;
           IF p_x_line_rec.booked_flag='Y' THEN
              l_pricing_event := 'BATCH,BOOK';
           ELSE
              l_pricing_event := 'BATCH';
           END IF;
          --bug 3018331
          if p_x_line_rec.source_document_type_id = 5 and
           nvl(fnd_profile.value('ONT_GRP_PRICE_FOR_DSP'),'N') = 'N' then
           null;
           if l_debug_level > 0 then
              oe_debug_pub.add('not logging price order - delete operation ');
           end if;
          else
           if l_debug_level > 0 then
              oe_debug_pub.add('logging price order - delete operation');
           end if;
           OE_delayed_requests_Pvt.log_request(
              p_entity_code               => OE_GLOBALS.G_ENTITY_ALL,
              p_entity_id                 => p_x_line_rec.Header_Id,
              p_requesting_entity_code    => OE_GLOBALS.G_ENTITY_ALL,
              p_requesting_entity_id      => p_x_line_rec.Header_Id,
              p_request_unique_key1       => l_pricing_event,
              p_param1                    => p_x_line_rec.header_id,
              p_param2                    => l_pricing_event,
              p_request_type              => OE_GLOBALS.G_PRICE_ORDER,
              x_return_status             => l_return_status);
          end if;
         END IF;
         --
  /*       IF p_x_line_rec.booked_flag='Y' THEN
           if l_debug_level > 0 then
              oe_debug_pub.add('bokked - delete');
           end if;
           OE_delayed_requests_Pvt.log_request(
              p_entity_code               => OE_GLOBALS.G_ENTITY_ALL,
              p_entity_id                 => p_x_line_rec.Header_Id,
              p_requesting_entity_code    => OE_GLOBALS.G_ENTITY_ALL,
              p_requesting_entity_id      => p_x_line_rec.Header_Id,
              p_request_unique_key1       => 'BOOK',
              p_param1                    => p_x_line_rec.header_id,
              p_param2                    => 'BOOK',
              p_request_type              => OE_GLOBALS.G_PRICE_ORDER,
              x_return_status             => l_return_status);
         END IF;   --2442012
 */
   END IF;


   --Bug# 9434723 - Start -
   -- Logging delayed request on DELETE Operation to delete header-level charges if there is no more qty on SO
    IF p_x_line_rec.operation = OE_GLOBALS.G_OPR_DELETE THEN
        oe_debug_pub.add(' Logging delayed request to delete header-level charges ');
        oe_delayed_requests_pvt.log_request(
            p_entity_code                => OE_GLOBALS.G_ENTITY_ALL,
            p_entity_id                  => p_x_line_rec.header_id,
            p_requesting_entity_code     => OE_GLOBALS.G_ENTITY_ALL,
            p_requesting_entity_id       => p_x_line_rec.header_id,
            p_request_type               => OE_GLOBALS.G_DELETE_CHARGES,
            x_return_status              => l_return_status);
        oe_debug_pub.add('  After logging G_DELETE_CHARGES delayed request - l_return_status= '||l_return_status);
    END IF;
   --- Bug# 9434723  -- End


   if l_debug_level > 0 then
      oe_debug_pub.ADD('Raj:Split-Inside Request' ,1);
   end if;

   IF (p_x_line_rec.operation = oe_globals.g_opr_update) and
       NOT (p_x_line_rec.split_action_code IS NOT NULL AND
	       p_x_line_rec.split_action_code <> FND_API.G_MISS_CHAR) AND
       (p_x_line_rec.line_set_id IS NOT NULL AND
        p_x_line_rec.line_set_id <> FND_API.G_MISS_NUM) THEN

     -- Addded project and task to fix bug #1229811
        if l_debug_level > 0 then
           oe_debug_pub.ADD('Raj:Split-Inside Request' ,1);
        end if;
	IF NOT OE_GLOBALS.EQUAL(p_x_line_rec.inventory_item_id ,
				p_old_line_rec.inventory_item_id) OR
	 NOT OE_GLOBALS.EQUAL(p_x_line_rec.order_quantity_uom ,
				p_old_line_rec.order_quantity_uom) OR
	 NOT OE_GLOBALS.EQUAL(p_x_line_rec.ship_tolerance_above ,
				p_old_line_rec.ship_tolerance_above) OR
	 NOT OE_GLOBALS.EQUAL(p_x_line_rec.ship_tolerance_below ,
				p_old_line_rec.ship_tolerance_below) OR
	 NOT OE_GLOBALS.EQUAL(p_x_line_rec.project_id ,
				p_old_line_rec.project_id) OR
	 NOT OE_GLOBALS.EQUAL(p_x_line_rec.task_id ,
				p_old_line_rec.task_id) THEN
		OE_Delayed_Requests_Pvt.Log_Request(
		p_entity_code				=>	OE_GLOBALS.G_ENTITY_LINE,
		p_entity_id                   =>   p_x_line_rec.line_set_id,
		p_requesting_entity_code  	=>	OE_GLOBALS.G_ENTITY_LINE,
		p_requesting_entity_id  	     =>	p_x_line_rec.line_id,
		p_request_type				=>	OE_GLOBALS.G_VALIDATE_LINE_SET,
		x_return_status			=>	l_return_status);
     END IF;

   END IF;


   ------------------------------------------------------------------------
   -- Perform Cancellation if necessary
   ------------------------------------------------------------------------

   -- QUOTING change
   IF NOT OE_GLOBALS.Equal(p_x_line_rec.ordered_quantity,p_old_line_rec.ordered_quantity)
      AND nvl(p_x_line_rec.transaction_phase_code,'F') = 'F'
   THEN
      IF (p_x_line_rec.operation = oe_globals.G_OPR_UPDATE AND
       (p_old_line_rec.ordered_quantity <> FND_API.G_MISS_NUM OR
        p_old_line_rec.ordered_quantity IS NOT NULL)) then

          OE_SALES_CAN_UTIL.Perform_Line_change(p_x_line_rec,
                                   p_old_line_rec,
                                   l_return_status);
          IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
             --bug 6653192
          ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
       END IF;
   END IF;


   ------------------------------------------------------------------------
    --Check over return
   ------------------------------------------------------------------------
/*
  Moving this check to check_book_required_attributes in OEXLLINB
*/
/*
  IF p_x_line_rec.line_category_code = 'RETURN' AND
     p_x_line_rec.reference_line_id is not NULL AND
     p_x_line_rec.booked_flag = 'Y' AND
     p_x_line_rec.cancelled_flag <> 'Y'
  THEN
   if l_debug_level > 0 then
      oe_debug_pub.ADD('Calling IS_OVER_RETURN ',1);
   end if;
      IF (OE_LINE_UTIL.Is_Over_Return(p_x_line_rec)) THEN
          FND_MESSAGE.Set_Name('ONT', 'OE_RETURN_INVALID_QUANTITY');
          OE_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
      END IF;
  END IF;
*/

   ------------------------------------------------------------------------
	-- If ship from org has been changed validate the Shipping Method. If
	-- Shipping Method is not a valid one for the ship from org clear the
	-- Shipping Method field.
   ------------------------------------------------------------------------

   IF (p_x_line_rec.line_category_code <> 'RETURN') THEN

     IF (NOT OE_GLOBALS.Equal(p_x_line_rec.ship_from_org_id
	,p_old_line_rec.ship_from_org_id) OR
	NOT OE_GLOBALS.Equal(p_x_line_rec.shipping_method_code,
	    p_old_line_rec.shipping_method_code))  THEN
	    IF (p_x_line_rec.shipping_method_code IS NOT NULL AND
		  p_x_line_rec.ship_from_org_id IS NOT NULL) THEN

                      IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110509' THEN
                         SELECT count(*)
                         INTO   l_count
                         FROM   wsh_carrier_services wsh,
                                wsh_org_carrier_services wsh_org
                         WHERE  wsh_org.organization_id      = p_x_line_rec.ship_from_org_id
                           AND  wsh.carrier_service_id       = wsh_org.carrier_service_id
                           AND  wsh.ship_method_code         = p_x_line_rec.shipping_method_code
                           AND  wsh_org.enabled_flag         = 'Y';
                      ELSE

                         SELECT count(*)
                	   INTO	l_count
                           FROM    wsh_carrier_ship_methods
                          WHERE   ship_method_code = p_x_line_rec.shipping_method_code
   	                    AND   organization_id = p_x_line_rec.ship_from_org_id;
                     END IF;
	   	--  Valid Shipping Method Code.

                 if l_debug_level > 0 then
                    oe_debug_pub.add('Split By:'||p_x_line_rec.split_by);
                    oe_debug_pub.add('Split Action:'||p_x_line_rec.split_action_code);
                 end if;
	   	IF	l_count  = 0 THEN

                  IF (nvl(p_x_line_rec.split_by,'X') <> 'SYSTEM' and
                                  NVL(p_x_line_rec.split_action_code,'X') <> 'SPLIT') THEN

                    --bug 4190357
                    select count(*) into v_count from oe_price_adjustments
                    where line_id = p_x_line_rec.line_id
                      and substitution_attribute = 'QUALIFIER_ATTRIBUTE11'
                      and list_line_type_code = 'TSN'
                      and modified_to = p_x_line_rec.shipping_method_code;
                    IF v_count > 0 THEN
                       IF l_debug_level > 0 THEN
                          oe_debug_pub.add('Deleting the tsn adjustments');
                       END IF;
                       DELETE FROM OE_PRICE_ADJUSTMENTS
                       WHERE LINE_ID = p_x_line_rec.line_id
                         AND LIST_LINE_TYPE_CODE = 'TSN'
                         AND SUBSTITUTION_ATTRIBUTE = 'QUALIFIER_ATTRIBUTE11'
                         AND MODIFIED_TO = p_x_line_rec.shipping_method_code
                       RETURNING MODIFIED_FROM into l_modified_from;
                    END IF;
                    --bug 4190357


                    if l_debug_level > 0 then
	              oe_debug_pub.add('Calling process_order to clear the Shipping Method',2);
	              oe_debug_pub.add('Value of shipping_method_code :'||p_x_line_rec.shipping_method_code,2);
                    end if;
                            --bug 4190357
                            select meaning into l_meaning from oe_ship_methods_v where lookup_type = 'SHIP_METHOD' and lookup_code=p_x_line_rec.shipping_method_code;
                            --bug 4190357
                            If v_count = 0 Then
                     	       Clear_Shipping_Method
			  	 ( p_x_line_rec	=> p_x_line_rec);
                            Else
                               p_x_line_rec.shipping_method_code := l_modified_from;
                            End If;
                       ELSE
                            if l_debug_level > 0 then
                               oe_debug_pub.add('SYSTEM SPLIT Donot clear the Shipping Method',2);
                            end if;
                       END IF;

               OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'SHIPPING_METHOD');
		     fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
                    --bug 4190357 added l_meaning to the token
			FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                        OE_Order_Util.Get_Attribute_Name('shipping_method_code') || ' ' || l_meaning);
			OE_MSG_PUB.Add;
			OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

               if l_debug_level > 0 then
   	          oe_debug_pub.add('Value of freight_carrier after the call :'
	         		||p_x_line_rec.shipping_method_code,2);
               end if;

		END IF;

	END IF;
	END IF;
	--14076417 start
	 if l_debug_level > 0 then
   	    oe_debug_pub.add('OEXULINB1- SplitActionCode = ' ||p_x_line_rec.split_action_code
		                            ||' -SplitLineID- '||p_x_line_rec.split_from_line_id);
		oe_debug_pub.add('OEXULINB2- commitment_id = ' ||p_x_line_rec.commitment_id
		                            ||' -OldCommitment- '||p_old_line_rec.commitment_id);
     end if;
    --14076417 end
     -- Also redo commitment if any the following attribute has changed.
	-- and Commitment ID is not null
     -- QUOTING change
     IF (p_x_line_rec.commitment_id IS NOT NULL)
        AND nvl(p_x_line_rec.transaction_phase_code,'F') = 'F'
		--14076417 start (to take care of parent 1.1 and new line 1.2 both conditions are required)
		AND ( NVL(p_x_line_rec.split_action_code,'X') <> 'SPLIT' AND p_x_line_rec.split_from_line_id is NULL)
		--14076417 end
     THEN
         IF
       ((
      OE_Quote_Util.G_COMPLETE_NEG = 'Y'
              AND
      NOT OE_GLOBALS.EQUAL(p_x_line_rec.transaction_phase_code
                      ,p_old_line_rec.transaction_phase_code)
              ) OR
          NOT OE_GLOBALS.Equal(p_x_line_rec.inventory_item_id,
                                p_old_line_rec.inventory_item_id) OR
          NOT OE_GLOBALS.Equal(p_x_line_rec.sold_to_org_id,
                                p_old_line_rec.sold_to_org_id) OR
          NOT OE_GLOBALS.Equal(p_x_line_rec.unit_selling_price,
                                p_old_line_rec.unit_selling_price) OR
          NOT OE_GLOBALS.Equal(p_x_line_rec.commitment_id,
                                p_old_line_rec.commitment_id) OR
          NOT OE_GLOBALS.Equal(p_x_line_rec.ordered_quantity,p_old_line_rec.ordered_quantity)) And
          --fix bug 1669076
          NOT OE_GLOBALS.Equal(p_x_line_rec.commitment_id,
                                p_old_line_rec.commitment_id)
          THEN

           IF NOT OE_GLOBALS.Equal(p_x_line_rec.ordered_quantity,p_old_line_rec.ordered_quantity)
              OR NOT OE_GLOBALS.Equal(p_x_line_rec.unit_selling_price,p_old_line_rec.unit_selling_price)          --OR NOT OE_GLOBALS.Equal(p_x_
          Then

          If p_x_line_rec.ordered_quantity IS NULL OR
             p_x_line_rec.ordered_quantity = FND_API.G_MISS_NUM Then
             l_new_qty := 0;
          Else
             l_new_qty := p_x_line_rec.ordered_quantity;
          End If;

          If p_old_line_rec.ordered_quantity IS NULL OR
             p_old_line_rec.ordered_quantity = FND_API.G_MISS_NUM Then
             l_old_qty := 0;
          Else
             l_old_qty:= p_old_line_rec.ordered_quantity;
          End If;

          If p_x_line_rec.unit_selling_price Is NULL or
             p_x_line_rec.unit_selling_price = FND_API.G_MISS_NUM Then
             l_new_unit_selling_price := 0;
          Else
             l_new_unit_selling_price := p_x_line_rec.unit_selling_price;
          End If;

          If p_old_line_rec.unit_selling_price is NULL or
             p_old_line_rec.unit_selling_price = FND_API.G_MISS_NUM Then

             l_old_unit_selling_price :=0;
          Else
             l_old_unit_selling_price :=p_old_line_rec.unit_selling_price;
          End If;


         If NOT OE_GLOBALS.Equal(p_x_line_rec.commitment_id,
                                p_old_line_rec.commitment_id) Then
           /* commtiment can change event quantity can change
              We always pass in the new, not the delta when commitment changes */

            l_delta_extended_amount := p_x_line_rec.ordered_quantity *
                                       p_x_line_rec.unit_selling_price;

         Else
          /* Only quantity or unit selling price change, therefore delta */
          l_new_extended_amount := l_new_unit_selling_price * l_new_qty;
          l_old_extended_amount := l_old_unit_selling_price * l_old_qty;
          l_delta_extended_amount := l_new_extended_amount - l_old_extended_amount;

         End If;



          Else
             /* commtiment can change but quantity will not change
                We always pass in the new, not the delta when commitment changes*/
            l_delta_extended_amount := p_x_line_rec.ordered_quantity *
                                       p_x_line_rec.unit_selling_price;
          End If;


      -- commented out the IF condition for bug 1905467.
      -- IF p_x_line_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN

      -- retain the original commitment functionality
      IF Not Oe_Commitment_pvt.do_commitment_sequencing THEN
          if l_debug_level > 0 then
             oe_debug_pub.add('entering evaluate commitment!',1);
          end if;
          oe_commitment_pvt.evaluate_commitment(
                            p_commitment_id      => p_x_line_rec.commitment_id,
 		 	    p_header_id          => p_x_line_rec.header_id,
                            p_unit_selling_price => l_delta_extended_amount,
                            x_return_status      => l_return_status,
                            x_msg_count          => l_msg_count,
                            x_msg_data           => l_msg_data);
          IF l_return_status = FND_API.G_RET_STS_ERROR THEN
              if l_debug_level > 0 then
                 oe_debug_pub.add('Value of Commitment_Id B4 Clear_Commitment_Id:'
                                 ||p_x_line_rec.commitment_id,1);
              end if;
              Clear_Commitment_Id
                    ( p_x_line_rec => p_x_line_rec);
              if l_debug_level > 0 then
                 oe_debug_pub.add('Value of Commitment_Id after the call :'
                    ||p_x_line_rec.commitment_id,1);
              end if;
              Raise FND_API.G_EXC_ERROR;

          ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
       END IF;
       -- END IF;


       END IF;
     END IF; --(p_x_line_rec.commitment_id IS NOT NULL)
     --------------------------------

  END IF; -- IF (p_x_line_rec.line_category_code <> 'RETURN')

  -- QUOTING change - log request only for fulfillment phase
  --4504362 : Branch scheduling checks removed
	-- If this is a split line then put this in fulfilment set if any.

	IF (p_x_line_rec.operation = OE_GLOBALS.G_OPR_CREATE AND
	    p_x_line_rec.split_from_line_id IS NOT NULL ) THEN
	    oe_split_util.Add_To_Fulfillment_Set(p_line_rec => p_x_line_rec);
	END IF;

    ------------------------------------------------------------------------
     -- If line is being created by a split operation, then log request
     -- to copy attachments else log request to apply automatic attachments
    ------------------------------------------------------------------------

     IF p_x_line_rec.operation = OE_GLOBALS.G_OPR_CREATE  THEN

        IF NVL(p_x_line_rec.split_from_line_id,FND_API.G_MISS_NUM)
            = FND_API.G_MISS_NUM
        THEN

            -- Performance Improvement Bug 1929163:
            -- Log request to apply automatic attachments based on profile
            IF G_APPLY_AUTOMATIC_ATCHMT = 'Y' THEN
               if l_debug_level > 0 then
                  oe_debug_pub.add('log request to apply atchmt',1);
               end if;
               OE_delayed_requests_Pvt.Log_Request
                    (p_entity_code       => OE_GLOBALS.G_ENTITY_LINE,
                     p_entity_id         => p_x_line_rec.line_id,
                     p_request_type      => OE_GLOBALS.G_APPLY_AUTOMATIC_ATCHMT,
                     p_requesting_entity_code     => OE_GLOBALS.G_ENTITY_LINE,
                     p_requesting_entity_id       => p_x_line_rec.line_id,
                     x_return_status              => l_return_status
                     );
            END IF;

        ELSE

            IF p_x_line_rec.split_by = 'SYSTEM' THEN
               if l_debug_level > 0 then
                  oe_debug_pub.add('log request to copy all atchmt',1);
               end if;
               OE_delayed_requests_Pvt.Log_Request
                    (p_entity_code       => OE_GLOBALS.G_ENTITY_LINE,
                     p_entity_id         => p_x_line_rec.line_id,
                     p_param1            => p_x_line_rec.split_from_line_id,
                     p_param2            => 'N', -- copy ALL attachments
                     p_request_type      => OE_GLOBALS.G_COPY_ATCHMT,
                     p_requesting_entity_code     => OE_GLOBALS.G_ENTITY_LINE,
                     p_requesting_entity_id       => p_x_line_rec.line_id,
                     x_return_status              => l_return_status
                     );

            ELSE
	       --Start of bug# 5521035
               IF G_APPLY_AUTOMATIC_ATCHMT = 'Y' THEN

                  BEGIN
                    SELECT ship_to_org_id
                      INTO l_ship_to_org_id
                      FROM oe_order_lines
                     WHERE line_id = p_x_line_rec.split_from_line_id;

                  EXCEPTION
                      WHEN OTHERS THEN
                      	   IF l_debug_level > 0 THEN
                              oe_debug_pub.add('SQL error - '||sqlerrm);
                           END IF;
                  END;


                  IF nvl(l_ship_to_org_id,-1) = nvl(p_x_line_rec.ship_to_org_id,-1) THEN  --<Ship To is same as that of the original line_id i.e split_from_line_id>
                     IF l_debug_level > 0 THEN
                        oe_debug_pub.add('log request to copy all atchmt',1);
                     END IF;
                     OE_delayed_requests_Pvt.Log_Request
                     (p_entity_code       => OE_GLOBALS.G_ENTITY_LINE,
                      p_entity_id         => p_x_line_rec.line_id,
                      p_param1            => p_x_line_rec.split_from_line_id,
                      p_param2            => 'N', -- copy ALL attachments
                      p_request_type      => OE_GLOBALS.G_COPY_ATCHMT,
                      p_requesting_entity_code     =>OE_GLOBALS.G_ENTITY_LINE,
	  	      p_requesting_entity_id       => p_x_line_rec.line_id,
	  	      x_return_status              => l_return_status
                     );

                  ELSE --<Ship To is different>
                     IF l_debug_level > 0 THEN
                      oe_debug_pub.add('log request to apply atchmt',1);
                     END IF;
                     OE_delayed_requests_Pvt.Log_Request
                     (p_entity_code       => OE_GLOBALS.G_ENTITY_LINE,
                      p_entity_id         => p_x_line_rec.line_id,
                      p_request_type      =>OE_GLOBALS.G_APPLY_AUTOMATIC_ATCHMT,
                      p_requesting_entity_code     => OE_GLOBALS.G_ENTITY_LINE,
                      p_requesting_entity_id       => p_x_line_rec.line_id,
                      x_return_status              => l_return_status
                     );
                     IF l_debug_level > 0 THEN
                  	oe_debug_pub.add('log request to copy manual atchmt',1);
               	     END IF;
                     OE_delayed_requests_Pvt.Log_Request
                     (p_entity_code       => OE_GLOBALS.G_ENTITY_LINE,
                      p_entity_id         => p_x_line_rec.line_id,
                      p_param1            => p_x_line_rec.split_from_line_id,
                      p_param2            => 'Y', -- copy only manual attachments
                      p_request_type      => OE_GLOBALS.G_COPY_ATCHMT,
                      p_requesting_entity_code     => OE_GLOBALS.G_ENTITY_LINE,
                      p_requesting_entity_id       => p_x_line_rec.line_id,
                      x_return_status              => l_return_status
                     );

                  END IF;
               ELSE  -- G_APPLY_AUTOMATIC_ATCHMT <> 'Y'
                  IF l_debug_level > 0 THEN
                     oe_debug_pub.add('log request to copy manual atchmt',1);
                  END IF;
                  OE_delayed_requests_Pvt.Log_Request
                  (p_entity_code       => OE_GLOBALS.G_ENTITY_LINE,
                   p_entity_id         => p_x_line_rec.line_id,
                   p_param1            => p_x_line_rec.split_from_line_id,
                   p_param2            => 'Y', -- copy only manual attachments
                   p_request_type      => OE_GLOBALS.G_COPY_ATCHMT,
                   p_requesting_entity_code     => OE_GLOBALS.G_ENTITY_LINE,
                   p_requesting_entity_id       => p_x_line_rec.line_id,
                   x_return_status              => l_return_status
                  );
               END IF;  -- if  G_APPLY_AUTOMATIC_ATCHMT = 'Y' , --End of bug# 5521035

            END IF; --  if SYSTEM split else

        END IF; -- if split else
    ELSE  -- 5893276
       IF p_x_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE AND
            G_APPLY_AUTOMATIC_ATCHMT = 'Y' THEN
               if l_debug_level > 0 then
                  oe_debug_pub.add('log request to apply atchmt for UPDATE ',1);
               end if;

--6896311

--7688372 start
            Load_attachment_rules_Line;
--7688372 end

            IF (NOT OE_GLOBALS.Equal(p_x_line_rec.INVOICE_TO_ORG_ID
                                    ,p_old_line_rec.INVOICE_TO_ORG_ID) AND g_attachrule_count_line_tab.exists('INVOICE_TO_ORG_ID'))  --7688372
            OR (NOT OE_GLOBALS.Equal(p_x_line_rec.SOLD_TO_ORG_ID
                                    ,p_old_line_rec.SOLD_TO_ORG_ID) AND g_attachrule_count_line_tab.exists('SOLD_TO_ORG_ID'))  --7688372
            OR (NOT OE_GLOBALS.Equal(p_x_line_rec.CUST_PO_NUMBER
                                    ,p_old_line_rec.CUST_PO_NUMBER) AND g_attachrule_count_line_tab.exists('CUST_PO_NUMBER'))  --7688372
            OR (NOT OE_GLOBALS.Equal(p_x_line_rec.INVENTORY_ITEM_ID
                                    ,p_old_line_rec.INVENTORY_ITEM_ID) AND g_attachrule_count_line_tab.exists('INVENTORY_ITEM_ID'))  --7688372
            OR (NOT OE_GLOBALS.Equal(p_x_line_rec.LINE_CATEGORY_CODE
                                    ,p_old_line_rec.LINE_CATEGORY_CODE) AND g_attachrule_count_line_tab.exists('LINE_CATEGORY_CODE'))  --7688372
            OR (NOT OE_GLOBALS.Equal(p_x_line_rec.LINE_TYPE_ID
                                    ,p_old_line_rec.LINE_TYPE_ID) AND g_attachrule_count_line_tab.exists('LINE_TYPE_ID'))  --7688372
            OR (NOT OE_GLOBALS.Equal(p_x_line_rec.SHIP_TO_ORG_ID
                                    ,p_old_line_rec.SHIP_TO_ORG_ID) AND g_attachrule_count_line_tab.exists('SHIP_TO_ORG_ID'))  --7688372
            THEN

                l_attr_attach_change := TRUE;

            END IF;
--6896311
             IF l_attr_attach_change THEN  --6896311
               OE_delayed_requests_Pvt.Log_Request
                    (p_entity_code       => OE_GLOBALS.G_ENTITY_LINE,
                     p_entity_id         => p_x_line_rec.line_id,
                     p_request_type      => OE_GLOBALS.G_APPLY_AUTOMATIC_ATCHMT,
                     p_requesting_entity_code     => OE_GLOBALS.G_ENTITY_LINE,
                     p_requesting_entity_id       => p_x_line_rec.line_id,
                     x_return_status              => l_return_status
                     );
             END IF;  --6896311

         END IF;

     END IF; -- if CREATE operation log request for attachments


   ------------------------------------------------------------------------
     -- Fix for bug1167537
     -- Clear the line record cached by defaulting APIs so that the
     -- default values on the child entities of line record are
     -- obtained from the updated line record
   ------------------------------------------------------------------------

     IF p_x_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE THEN
          ONT_LINE_Def_Util.Clear_LINE_Cache;
     END IF;


   ------------------------------------------------------------------------
     -- if there is an update operation on model line,
     -- clear the cached model line record if any.
   ------------------------------------------------------------------------

     IF p_x_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE AND
        p_x_line_rec.item_type_code = OE_GLOBALS.G_ITEM_MODEL THEN
        if l_debug_level > 0 then
           oe_debug_pub.add('clear the cached top model record', 1);
           oe_debug_pub.add('model line: '|| p_x_line_rec.line_id, 1);
        end if;
        OE_Order_Cache.Clear_Top_Model_Line(p_key => p_x_line_rec.line_id);
     END IF;

    -- Changes for Late Demand Penalty Factor
      if l_debug_level > 0 then
         oe_debug_pub.add('Late Demand Penalty Factor',1);
      end if;
     IF(p_x_line_rec.late_demand_penalty_factor IS NOT NULL AND
        p_x_line_rec.late_demand_penalty_factor  <>  FND_API.G_MISS_NUM AND
            p_x_line_rec.late_demand_penalty_factor < 0) THEN

                FND_MESSAGE.SET_NAME('ONT','ONT_SCH_DEMAND_FACTOR_ZERO');
                OE_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
     END IF;
   ------------------------------------------------------------------------
   -- Call Scheduling to perform any scheduling on the line, if needed
   ------------------------------------------------------------------------

    -- Added code in delete_dependency for delete operation.
    --4504362 : branch scheduling checks removed
      IF OE_SCHEDULE_UTIL.OESCH_PERFORM_SCHEDULING = 'Y' THEN
        -- After the restructure post write code will call
        -- scheduling and scheduling may or may not require on the
        -- line. However, we need to set the resource flag.

        if l_debug_level > 0 then
           oe_debug_pub.add('Setting the resource ',1);
        end if;
        IF NOT OE_GLOBALS.Equal(p_old_line_rec.ship_from_org_id,
                              p_x_line_rec.ship_from_org_id)
        THEN
         IF p_x_line_rec.ship_from_org_id is not null
         THEN
             if l_debug_level > 0 then
                oe_debug_pub.add('Setting re_source_flag to N',1);
             end if;
             p_x_line_rec.re_source_flag := 'N';
         ELSE
             if l_debug_level > 0 then
                oe_debug_pub.add('1.Setting re_source_flag to null',1);
             end if;
             p_x_line_rec.re_source_flag := '';
         END IF;
        ELSIF p_x_line_rec.ship_from_org_id is null
        THEN
          if l_debug_level > 0 then
             oe_debug_pub.add('2.Setting re_source_flag to null',1);
          end if;
          p_x_line_rec.re_source_flag := '';
        END IF;

        -- If inventory item is changed on a unscheduled substituted
        -- item, clear the original item information.
        -- Scheduling code will take care of clearing original
        -- inventory information on scheduled line since if we
        -- place the clearing logic here for a scheduled line, some
        -- of the delayed request may clear the original item information
        -- after substitution.

        IF NOT OE_GLOBALS.Equal(p_x_line_rec.Inventory_Item_Id,
                                p_old_line_rec.Inventory_Item_Id)
        AND p_x_line_rec.schedule_status_code is null
        AND p_x_line_rec.Original_Inventory_Item_Id IS NOT NULL
        AND p_x_line_rec.item_relationship_type IS NULL
        THEN

           if l_debug_level > 0 then
              oe_debug_pub.add('PWP: clearing out original item fields');
           end if;
           p_x_line_rec.Original_Inventory_Item_Id    := Null;
           p_x_line_rec.Original_item_identifier_Type := Null;
           p_x_line_rec.Original_ordered_item_id      := Null;
           p_x_line_rec.Original_ordered_item         := Null;


        END IF;
      END IF; -- perform scheduling.


    -- following 3 calls are mainly related to configuration lines.
    -- do not move Log_CTO_Requests above scheduling
    -- 4504362 :branch scheduling checks removed

    -- bug fix : 2307423, do not log if remnant.
    IF p_x_line_rec.top_model_line_id is NOT NULL THEN

      Log_Config_Requests( p_x_line_rec    => p_x_line_rec
                          ,p_old_line_rec  => p_old_line_rec
                          ,x_return_status => l_return_status);

      IF nvl(p_x_line_rec.model_remnant_flag, 'N') = 'N' THEN
        IF NOT(OE_GENESIS_UTIL.G_INCOMING_FROM_DOO OR OE_GENESIS_UTIL.G_INCOMING_FROM_SIEBEL) THEN -- DOO Pre Exploded Kit ER 9339742
         -- This Global is checked here and not inside the procedure
         -- Log_Cascade_Requests because we are currently considering
         -- only PTO and Kit, while ATO flow is not supported in DOO

         Log_Cascade_Requests( p_x_line_rec    => p_x_line_rec
                             ,p_old_line_rec  => p_old_line_rec
                             ,x_return_status => l_return_status);
        END IF;
      END IF;
    END IF;


/* 7576948: Commenting for IR ISO CMS Project

  if l_debug_level > 0 then
     oe_debug_pub.add('Before checking for system split on int ord');
  end if;
  IF (p_x_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE) AND
	  (p_x_line_rec.split_by = 'SYSTEM') AND
	  (p_x_line_rec.order_source_id = 10) THEN
            FND_MESSAGE.SET_NAME('ONT','OE_CHG_CORR_REQ');
            -- { start fix for 2648277
	    FND_MESSAGE.SET_TOKEN('CHG_ATTR',
               OE_Order_Util.Get_Attribute_Name('ordered_quantity'));
            -- end fix for 2648277}
	 OE_MSG_PUB.ADD;
    END IF;

*/ -- Commented for IR ISO CMS project

-- bug fix 3350185:
-- Audit Trail/Versioning moved to separate procedure below
   Version_Audit_Process( p_x_line_rec => p_x_line_rec,
                          p_old_line_rec => p_old_line_rec,
                          p_process_step => 2 );

-- Log Drop Ship CMS Delayed Request for Externally sources
-- lines. Do not log for System Split Lines.

IF p_x_line_rec.source_type_code  = 'EXTERNAL' AND
   p_x_line_rec.booked_flag       = 'Y'  AND
    NOT (p_x_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE AND
        p_x_line_rec.split_by = 'SYSTEM' AND
          NVL(p_x_line_rec.split_action_code,'X') = 'SPLIT') AND
   (PO_CODE_RELEASE_GRP.Current_Release >=
         PO_CODE_RELEASE_GRP.PRC_11i_Family_Pack_J) AND
             OE_CODE_CONTROL.Code_Release_Level  >= '110510' THEN

       Log_Dropship_CMS_Request
                      (p_x_line_rec    =>   p_x_line_rec
                      ,p_old_line_rec  =>   p_old_line_rec
                      );

       -- Bug 8940667,8947394 begin
       -- Processing the request logged above for CONFIG Lines
       -- since deletion of CONFIG Lines removes the Delayed Request
       -- For Dropship Change Management.

       IF (p_x_line_rec.operation = OE_GLOBALS.G_OPR_DELETE AND
           p_x_line_rec.item_type_code = 'CONFIG') THEN

          IF l_debug_level > 0 THEN
       	     oe_debug_pub.ADD('Processing DROPSHIP_CMS Request for CONFIG Line');
          END IF;

          i := oe_delayed_requests_pvt.G_Delayed_Requests.first;

          WHILE i IS NOT NULL LOOP

       	     IF (oe_delayed_requests_pvt.G_Delayed_Requests(i).request_type = OE_GLOBALS.G_DROPSHIP_CMS
                AND oe_delayed_requests_pvt.G_Delayed_Requests(i).entity_code = OE_GLOBALS.G_ENTITY_ALL
                AND oe_delayed_requests_pvt.G_Delayed_Requests(i).entity_id = p_x_line_rec.line_id) THEN

       	        IF l_debug_level > 0 THEN
                    oe_debug_pub.add('G_Delayed_Requests.entity_code/entity_id' ||
                    oe_delayed_requests_pvt.G_Delayed_Requests(i).entity_code || '/' ||
                    oe_delayed_requests_pvt.G_Delayed_Requests(i).entity_id);
                    oe_debug_pub.add('G_Delayed_Requests.request_type' ||
                    oe_delayed_requests_pvt.G_Delayed_Requests(i).request_type);

                END IF;

                l_G_Delayed_Requests(1) := oe_delayed_requests_pvt.G_Delayed_Requests(i);

                oe_purchase_release_pvt.Process_DropShip_CMS_Requests
                  (p_request_tbl => l_G_Delayed_Requests
                  ,x_return_status => l_return_status);

             END IF;

             i := oe_delayed_requests_pvt.G_Delayed_Requests.Next(i);

          END LOOP;

       END IF;

       -- Bug 8940667,8947394 end

END IF;

-- If the ordered quantity on a line becoming Zero thatcan be a cancellation
-- Or mere decrement of quantity the line is taken out of ship sets and
-- ariival sets

                IF p_x_line_rec.ordered_quantity = 0 THEN
                        p_x_line_rec.ship_set_id := null;
                        p_x_line_rec.arrival_set_id := null;
                END IF;
    -- Pack J
    -- Promise Date setup with Request date
    -- 'FR' - With First Request date
    -- 'R'  -- For all change in Request date
    IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510' THEN
       l_promise_date_flag := OE_SYS_PARAMETERS.value('PROMISE_DATE_FLAG');

       IF l_promise_date_flag = 'FR'
        AND (p_old_line_rec.request_date = FND_API.G_MISS_DATE
           OR p_old_line_rec.request_date IS NULL) THEN
         p_x_line_rec.promise_date := p_x_line_rec.request_date;
       ELSIF l_promise_date_flag = 'R' THEN
          p_x_line_rec.promise_date := p_x_line_rec.request_date;
       END IF;
    END IF;


   if l_debug_level > 0 then
      OE_DEBUG_PUB.add('Exiting from Lines Pre-Write process',1);
   end if;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        RAISE;
    WHEN OTHERS THEN
        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
          ,   'Pre_Write_Process'
            );
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Pre_Write_Process;

PROCEDURE Version_Audit_Process
(   p_x_line_rec                    IN OUT NOCOPY  OE_Order_PUB.Line_Rec_Type
,   p_old_line_rec                  IN  OE_Order_PUB.Line_Rec_Type :=
                                        OE_Order_PUB.G_MISS_LINE_REC
,   p_process_step                  IN NUMBER := 3
)
IS

l_ind                       NUMBER;
l_code_level                varchar2(6) := OE_CODE_CONTROL.GET_CODE_RELEASE_LEVEL;
l_audit_trail_enabled       VARCHAR2(1) := OE_SYS_PARAMETERS.VALUE('AUDIT_TRAIL_ENABLE_FLAG');

l_return_status                VARCHAR2(30);
l_reason_code VARCHAR2(30);
l_reason_comments VARCHAR2(2000);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
/*
The p_process_step value passed in determines the processes run. The first time it is called
from Pre_Write_Process, this procedure first performs process 1. Later in Pre_Write it is
called with process 2. From Pricing we are calling with process 3 to perform both actions.
*/

IF p_process_step IN (1,3) THEN

/* Start AuditTrail */

IF l_code_level >= '110508' and nvl(l_audit_trail_enabled,'D') <> 'D' THEN
   IF (p_x_line_rec.operation  = OE_GLOBALS.G_OPR_UPDATE) then
       IF OE_GLOBALS.OE_AUDIT_HISTORY_TBL.count > 0 THEN
          FOR l_ind in 1..OE_GLOBALS.oe_audit_history_tbl.last LOOP
              IF OE_GLOBALS.OE_AUDIT_HISTORY_TBL.exists(l_ind) THEN
                 IF OE_GLOBALS.oe_audit_history_tbl(l_ind).LINE_ID = p_x_line_rec.line_id AND
                    OE_GLOBALS.oe_audit_history_tbl(l_ind).HISTORY_TYPE = 'R' THEN   -- flag 'R' denotes requires reason
                    if l_debug_level > 0 then
                       OE_DEBUG_PUB.add('OEXULINB- Audit Reason Required', 5);
                    end if;
                    IF (p_x_line_rec.change_reason IS NULL OR
                        p_x_line_rec.change_reason = FND_API.G_MISS_CHAR OR
                        NOT OE_Validate.Change_Reason_Code(p_x_line_rec.change_reason)) THEN

                       IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510' THEN
                         IF OE_Versioning_Util.Captured_Reason IS NULL THEN
                            OE_Versioning_Util.Get_Reason_Info(l_reason_code, l_reason_comments);
                            IF l_reason_code IS NULL THEN
                             -- bug 3636884, defaulting reason from group API
                             IF OE_GLOBALS.G_DEFAULT_REASON THEN
                               if l_debug_level > 0 then
                                 oe_debug_pub.add('Defaulting Audit Reason for Order Line', 1);
                               end if;
                               p_x_line_rec.change_reason := 'SYSTEM';
                             ELSE
                               OE_DEBUG_PUB.add('Reason code for change is missing or invalid', 1);
                               fnd_message.set_name('ONT','OE_AUDIT_REASON_RQD');
                               fnd_message.set_token('OBJECT','ORDER LINE');
                               oe_msg_pub.add;
                               RAISE FND_API.G_EXC_ERROR;
                             END IF;
                            END IF;
                         END IF;
                       ELSE
                            if l_debug_level > 0 then
                               OE_DEBUG_PUB.add('Reason code for change is missing or invalid', 1);
                            end if;
                            fnd_message.set_name('ONT','OE_AUDIT_REASON_RQD');
                            fnd_message.set_token('OBJECT','ORDER LINE');
                            oe_msg_pub.add;
                            raise FND_API.G_EXC_ERROR;
                       END IF;
                    END IF;
                 END IF;
             END IF;
          END LOOP;
       END IF;
  END IF;
END IF;

/* End Audit Trail */

END IF;

IF p_process_step IN (2,3) THEN

  IF (p_x_line_rec.operation=OE_GLOBALS.G_OPR_UPDATE) AND
     (p_x_line_rec.split_action_code = 'SPLIT') THEN

       --11.5.10 Versioning/Audit Trail updates
     IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510' THEN
          OE_Versioning_Util.Capture_Audit_Info(p_entity_code => OE_GLOBALS.G_ENTITY_LINE,
                                           p_entity_id => p_x_line_rec.line_id,
                                           p_hist_type_code =>  'SPLIT');
           --log delayed request
             OE_Delayed_Requests_Pvt.Log_Request(p_entity_code => OE_GLOBALS.G_ENTITY_ALL,
                                   p_entity_id => p_x_line_rec.header_id,
                                   p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
                                   p_requesting_entity_id => p_x_line_rec.line_id,
                                   p_request_type => OE_GLOBALS.G_VERSION_AUDIT,
                                   x_return_status => l_return_status);
          OE_GLOBALS.G_AUDIT_HISTORY_RQD_FLAG := 'N';
     ELSE
       OE_CHG_ORDER_PVT.RecordLineHist
          (p_line_id => p_x_line_rec.line_id,
           p_line_rec => null,
           p_hist_type_code => 'SPLIT',
           p_reason_code => NULL,
           p_comments => NULL,
           p_wf_activity_code => null,
           p_wf_result_code => null,
           x_return_status => l_return_status);

      if l_debug_level > 0 then
          OE_DEBUG_PUB.add('Return status after inserting split history : '||l_return_status,5);
      end if;

       IF l_return_status <> FND_API.G_RET_STS_SUCCESS then
          if l_debug_level > 0 then
             oe_debug_pub.add('Error while inserting Line split History ',1);
          end if;
          IF l_return_status = FND_API.G_RET_STS_ERROR then
             raise FND_API.G_EXC_ERROR;
          ELSE
             raise FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
       END IF;
     END IF;

  END IF;

       --11.5.10 Versioning/Audit Trail updates
     IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510'
      AND   OE_GLOBALS.G_ROLL_VERSION <> 'N'  THEN
       IF OE_GLOBALS.G_REASON_CODE IS NULL AND
       OE_GLOBALS.G_CAPTURED_REASON IN ('V','A') THEN
          IF p_x_line_rec.change_reason <> FND_API.G_MISS_CHAR THEN
              OE_GLOBALS.G_REASON_CODE := p_x_line_rec.change_reason;
              OE_GLOBALS.G_REASON_COMMENTS := p_x_line_rec.change_comments;
              OE_GLOBALS.G_CAPTURED_REASON := 'Y';
          ELSE
             if l_debug_level > 0 then
                OE_DEBUG_PUB.add('Reason code for versioning is missing or invalid', 1);
             end if;
            -- if OE_GLOBALS.G_UI_FLAG then --bug5716140
               IF  OE_GLOBALS.G_UI_FLAG
                       OR ( p_x_line_rec.split_action_code = 'SPLIT'
                        AND nvl(p_x_line_rec.split_by,'SYSTEM') = 'USER' ) THEN  --bug5716140
                raise FND_API.G_EXC_ERROR;
             end if;
          END IF;
       END IF;

       --log delayed request
       if l_debug_level > 0 then
          oe_debug_pub.add('log versioning request',1);
       end if;
          OE_Delayed_Requests_Pvt.Log_Request(p_entity_code => OE_GLOBALS.G_ENTITY_ALL,
                                   p_entity_id => p_x_line_rec.header_id,
                                   p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
                                   p_requesting_entity_id => p_x_line_rec.line_id,
                                   p_request_type => OE_GLOBALS.G_VERSION_AUDIT,
                                   x_return_status => l_return_status);
     END IF;

   /* Start Audit Trail - Insert Lines history */

IF l_code_level >= '110508' and nvl(l_audit_trail_enabled,'D') <> 'D' THEN
   IF OE_GLOBALS.OE_AUDIT_HISTORY_TBL.count > 0 THEN
      FOR l_ind in 1..OE_GLOBALS.oe_audit_history_tbl.last LOOP
          IF OE_GLOBALS.OE_AUDIT_HISTORY_TBL.exists(l_ind) THEN
             IF OE_GLOBALS.oe_audit_history_tbl(l_ind).line_id = p_x_line_rec.line_id THEN
                if l_debug_level > 0 then
                   OE_DEBUG_PUB.add('OEXULINB:calling oe_order_chg_pvt.recordlinehist', 5);
                end if;

              /* Commenting the below code for bug#14282904
	      --11.5.10 Versioning/Audit Trail updates
              IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510' THEN
                OE_Versioning_Util.Capture_Audit_Info(p_entity_code => OE_GLOBALS.G_ENTITY_LINE,
                                           p_entity_id => p_x_line_rec.line_id,
                                           p_hist_type_code =>  'UPDATE');
                 --log delayed request
                   OE_Delayed_Requests_Pvt.Log_Request(p_entity_code => OE_GLOBALS.G_ENTITY_ALL,
                                   p_entity_id => p_x_line_rec.header_id,
                                   p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
                                   p_requesting_entity_id => p_x_line_rec.line_id,
                                   p_request_type => OE_GLOBALS.G_VERSION_AUDIT,
                                   x_return_status => l_return_status);
                OE_GLOBALS.G_AUDIT_HISTORY_RQD_FLAG := 'N';
              ELSE
	      */
                OE_CHG_ORDER_PVT.RecordLineHist
                  (p_line_id => p_x_line_rec.line_id,
                   p_line_rec => null,
                   p_hist_type_code => 'UPDATE',
                   p_reason_code => p_x_line_rec.change_reason,
                   p_comments => p_x_line_rec.change_comments,
                   p_wf_activity_code => null,
                   p_wf_result_code => null,
                   x_return_status => l_return_status);
                if l_debug_level > 0 then
                   OE_DEBUG_PUB.add('IN OEXULINB:After'||l_return_status,5);
                end if;

                IF l_return_status <> FND_API.G_RET_STS_SUCCESS then
                   if l_debug_level > 0 then
                      oe_debug_pub.add('Inserting Line Audit History error',1);
                   end if;
                   IF l_return_status = FND_API.G_RET_STS_ERROR then
                      raise FND_API.G_EXC_ERROR;
                   ELSE
                   raise FND_API.G_EXC_UNEXPECTED_ERROR;
                   END IF;
                END IF;

              -- commenting out for bug#14282904
	      -- END IF;
                -- now the history is inserted successfully, remove the entry from pl/sql table
                if l_debug_level > 0 then
                   oe_debug_pub.add('Deleting the history entry for line ID : '||OE_GLOBALS.oe_audit_history_tbl(l_ind).line_id,1);
                end if;
                OE_GLOBALS.oe_audit_history_tbl.delete(l_ind);
             END IF;
          END IF;

      END LOOP;
   END IF;
END IF;
/* End Audit Trail */

END IF; --p_process_step in (2,3)

END Version_Audit_Process;


/*----------------------------------------------------------
PROCEDURE Cascade_Line_Number

-- Fixed bug 1914885: passing p_header_id and using it in the condition
-- to select lines where the line number update is to be cascaded.
-- This will result in using the header_id index instead of
-- full table scans on lines tables.
-----------------------------------------------------------*/

PROCEDURE Cascade_Line_Number( p_header_id IN NUMBER,
                                            p_line_id IN NUMBER,
					    p_line_set_id IN NUMBER,
					    p_item_type_code IN VARCHAR2,
					    p_line_number IN NUMBER)
IS

l_line_id NUMBER;
l_header_id NUMBER;
l_line_number NUMBER;
l_shipment_number NUMBER;
l_option_number NUMBER;
l_service_number NUMBER;
l_dummy NUMBER;

-- Fetches Service lines pertaining to Standard
--and related line set records.
--lchen rewrite cursor standard_line_number to fix performance bug 1869179

CURSOR STANDARD_LINE_NUMBER IS
select /*MOAC_SQL_CHANGES*/ a.line_id, a.header_id, a.line_number, a.shipment_number, a.option_number, a.service_number
from oe_order_lines a
where a.service_reference_line_id= p_line_id
UNION
select a.line_id, a.header_id, a.line_number, a.shipment_number, a.option_number, a.service_number
from oe_order_lines a
where a.line_set_id = p_line_set_id
UNION
select a.line_id, a.header_id, a.line_number, a.shipment_number, a.option_number, a.service_number
from oe_order_lines a
where exists
      (select 'x'
       from oe_order_lines_all b
       where a.service_reference_line_id=b.line_id
       and b.line_set_id = p_line_set_id)
      and a.line_Id <> p_line_id;


--Fetches Options/classes/services pertaining to Model/Kit
--and related line set records.

CURSOR MODEL_LINE_NUMBER IS
      SELECT /*MOAC_SQL_CHANGES*/ line_id, header_id,line_number,shipment_number,
		   option_number,service_number
      FROM   oe_order_lines
      WHERE  (top_model_line_id = p_line_id
	 OR      line_set_id = p_line_set_id
	 OR     top_model_line_id in (SELECT line_id
							FROM   oe_order_lines_all
							WHERE header_id = p_header_id
                            AND line_set_id = p_line_set_id))
      AND     line_id <> p_line_id
      AND     header_id = p_header_id
      FOR UPDATE OF line_number NOWAIT;



--Fetches services attached to options/model/classes to update
--line_number.
--lchen rewrite cursor service_line_number to fix performance bug 1869179

CURSOR SERVICE_LINE_NUMBER IS
  select /*MOAC_SQL_CHANGES*/ a.line_id, a.header_id, a.line_number, a.shipment_number, a.option_number, a.service_number
  from oe_order_lines a, oe_order_lines_all b
  where a.service_reference_line_id=b.line_id
  and b.line_set_id = p_line_set_id
  UNION
  select a.line_id, a.header_id, a.line_number, a.shipment_number, a.option_number, a.service_number
  from oe_order_lines a, oe_order_lines_all b
  Where a.service_reference_line_id=b.line_id
  and  b.top_model_line_id= p_line_id
  UNION
  select a.line_id, a.header_id, a.line_number, a.shipment_number, a.option_number, a.service_number
  from oe_order_lines a, oe_order_lines_all b
  Where a.service_reference_line_id=b.line_id
  and  EXISTS (select 'X'
           from oe_order_lines_all c
           where line_set_id = p_line_set_id
           and c.line_id = b.top_model_line_id);


l_line_rec      OE_Order_PUB.Line_Rec_Type;
l_cursor_flag   VARCHAR2(1) := null;

BEGIN
       oe_debug_pub.add('Entering OE_LINE_UTIL.CASCADE_LINE_NUMBER ');
              oe_debug_pub.add('AK line_id ' || p_line_id);
              oe_debug_pub.add('AK line_iset_d ' || p_line_set_id);
              oe_debug_pub.add('AK line_number' || p_line_number);
              oe_debug_pub.add('AK item_type_code' || p_item_type_code);

       IF p_item_type_code = OE_GLOBALS.G_ITEM_STANDARD THEN

              OPEN Standard_line_number;
               l_cursor_flag := 'S';

    -- Update  line number on the child service lines
 /*lchen rewrite the update statement to fix performance bug 1869179 */
      oe_debug_pub.add('l_cursor_flag= ' ||l_cursor_flag );

            LOOP
            FETCH standard_line_number
            INTO  l_line_id,
	          l_header_id,
	          l_line_number,
	          l_shipment_number,
	          l_option_number,
	          l_service_number;
            EXIT when standard_line_number%NOTFOUND;

            BEGIN
            SELECT line_id
            INTO  l_dummy
            FROM   oe_order_lines
            WHERE  line_id=l_line_id
            FOR UPDATE OF line_number NOWAIT;
            EXCEPTION
            WHEN OTHERS THEN
            l_dummy := 0;
            END;

      oe_debug_pub.add('l_line_id= ' || l_line_id);
       oe_debug_pub.add('In the loop of standard_line_number, update child service line numbers');

        UPDATE oe_order_lines
          Set    line_number = p_line_number,
                 lock_control = lock_control + 1
         WHERE  line_id=l_line_id;

       END LOOP;
     CLOSE Standard_line_number;

     OPEN Standard_line_number;
          IF SQL%FOUND THEN
	     OE_GLOBALS.G_CASCADING_REQUEST_LOGGED := TRUE;

              		LOOP
				 FETCH Standard_line_number
				 INTO  l_line_rec.line_id,
					  l_line_rec.header_id,
				 	  l_line_rec.line_number,
					  l_line_rec.shipment_number,
					  l_line_rec.option_number,
					  l_line_rec.service_number;
 			      EXIT WHEN Standard_line_number%NOTFOUND;

               oe_debug_pub.add(' before calling wf_util');
	       oe_debug_pub.add('line_rec.line_id=' || l_line_rec.line_id);

                        oe_order_wf_util.set_line_user_key(l_line_rec);

                      END LOOP;

               END IF;
              CLOSE Standard_line_number;

         ELSIF p_item_type_code = OE_GLOBALS.G_ITEM_MODEL
         OR    p_item_type_code = OE_GLOBALS.G_ITEM_KIT
         THEN


               OPEN Model_line_number;
                l_cursor_flag := 'M';

                oe_debug_pub.add('l_cursor_flag= ' ||l_cursor_flag );
	      -- Update line number on the child option/service/class lines

               UPDATE oe_order_lines
               Set    line_number = p_line_number,
                      lock_control = lock_control + 1
               WHERE  (top_model_line_id = p_line_id
	          OR      line_set_id = p_line_set_id
	          OR     top_model_line_id in (SELECT line_id
				FROM   oe_order_lines
				WHERE header_id = p_header_id
                AND line_set_id = p_line_set_id))
                  AND    line_id <> p_line_id
                  AND    header_id = p_header_id;  -- 2508099

		IF SQL%FOUND THEN
			    OE_GLOBALS.G_CASCADING_REQUEST_LOGGED := TRUE;

			  LOOP
				FETCH Model_line_number
				INTO  l_line_rec.line_id,
				 l_line_rec.header_id,
				 l_line_rec.line_number,
				 l_line_rec.shipment_number,
				 l_line_rec.option_number,
				 l_line_rec.service_number;
 			 	EXIT WHEN Model_Line_Number%NOTFOUND;

                oe_debug_pub.add(' before calling wf_util');
		oe_debug_pub.add('line_rec.line_id=' || l_line_rec.line_id);

                              oe_order_wf_util.set_line_user_key(l_line_rec);

			  END LOOP;
               END IF;
               CLOSE Model_line_number;


      -- Update line numbers for service lines

      OPEN SERVICE_line_number;
      l_cursor_flag := 'O';
      oe_debug_pub.add('l_cursor_flag= ' ||l_cursor_flag );

-- Update line number on the child option/service/class lines
 --lchen rewrite the update statement to fix performance bug 1869179

     LOOP
      FETCH service_line_number
  	INTO  l_line_id,
	      l_header_id,
	      l_line_number,
	      l_shipment_number,
	      l_option_number,
	      l_service_number;

        EXIT when service_line_number%NOTFOUND;

      BEGIN
        SELECT line_id
        INTO  l_dummy
        FROM   oe_order_lines
        WHERE  line_id=l_line_id
      FOR UPDATE OF line_number NOWAIT;
        EXCEPTION
        WHEN OTHERS THEN
         l_dummy := 0;
     END;

   oe_debug_pub.add('l_line_id = ' ||l_dummy);
  oe_debug_pub.add('in service_line_number loop, update service line number');

      UPDATE oe_order_lines
      Set    line_number = p_line_number,
             lock_control = lock_control + 1
      WHERE  line_id=l_line_id;
    END LOOP;
   CLOSE service_line_number;

     OPEN service_line_number;
	IF SQL%FOUND THEN
	   OE_GLOBALS.G_CASCADING_REQUEST_LOGGED := TRUE;

			  LOOP
				FETCH service_line_number
				INTO  l_line_rec.line_id,
				 l_line_rec.header_id,
				 l_line_rec.line_number,
				 l_line_rec.shipment_number,
				 l_line_rec.option_number,
				 l_line_rec.service_number;
 			 	EXIT WHEN service_Line_Number%NOTFOUND;

                oe_debug_pub.add(' before calling wf_util');
		oe_debug_pub.add('line_rec.line_id=' || l_line_rec.line_id);

                            oe_order_wf_util.set_line_user_key(l_line_rec);
	                END LOOP;
           END IF;
        CLOSE Service_line_number;

       END IF;   /*p_item_type_code*/

     oe_debug_pub.add('Exiting OE_LINE_UTIL.CASCADE_LINE_NUMBER ');

EXCEPTION

    WHEN NO_DATA_FOUND THEN
          IF l_cursor_flag = 'S' THEN
            CLOSE Standard_line_number;
          ELSIF l_cursor_flag = 'M' THEN
		  CLOSE Model_Line_Number;
          ELSIF l_cursor_flag = 'O' THEN
               CLOSE Service_line_number;
          END IF;

    WHEN  APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN

          IF p_item_type_code = OE_GLOBALS.G_ITEM_STANDARD THEN
            CLOSE Standard_line_number;
          ELSE
		  CLOSE Model_Line_Number;
          END IF;

          IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
          THEN

       	   fnd_message.set_name('ONT','OE_LOCK_ROW_ALREADY_LOCKED');
        	   OE_MSG_PUB.Add;
	        RAISE FND_API.G_EXC_ERROR;

        	END IF;

     WHEN OTHERS THEN

          IF l_cursor_flag = 'S' THEN
            CLOSE Standard_line_number;
          ELSIF l_cursor_flag = 'M' THEN
		  CLOSE Model_Line_Number;
          ELSIF l_cursor_flag = 'O' THEN
               CLOSE Service_line_number;
          END IF;

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
          ,   'Cascade_line_number'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Cascade_Line_Number;


/*----------------------------------------------------------
PROCEDURE Post_Write_Process
-----------------------------------------------------------*/

PROCEDURE Post_Write_Process
(   p_x_line_rec                    IN OUT NOCOPY  OE_Order_PUB.Line_Rec_Type
,   p_old_line_rec                  IN  OE_Order_PUB.Line_Rec_Type :=
                                        OE_Order_PUB.G_MISS_LINE_REC
) IS
l_return_status    VARCHAR2(30):= FND_API.G_RET_STS_SUCCESS;
I                  NUMBER;
l_ship_authorize   VARCHAR2(1);
l_operation        VARCHAR2(30);

l_qty_to_reserve   NUMBER;
l_qty2_to_reserve   NUMBER; -- INVCONV
l_msg_count        NUMBER;
l_msg_data         VARCHAR2(2000);
l_line_id		    NUMBER;
l_old_recursion_mode VARCHAR2(1);

-- For reservations
l_reservation_rec         inv_reservation_global.mtl_reservation_rec_type;
l_dummy_sn                inv_reservation_global.serial_number_tbl_type;
l_quantity_reserved       NUMBER;
l_quantity2_reserved       NUMBER; -- INVCONV
l_rsv_id                  NUMBER;
l_reservable_type         NUMBER;

l_atp_tbl      OE_ATP.atp_tbl_type;
l_buffer                  VARCHAR2(2000);
l_lock_control            NUMBER;

-- subinventory
l_revision_code    NUMBER;
l_lot_code         NUMBER;

/* Fix Bug # 3184597 */
l_ctr              NUMBER;
l_set_id	   NUMBER;

CURSOR ship_authorize IS
    SELECT 'Y' from
    WF_ITEM_ACTIVITY_STATUSES WIAS
  , WF_PROCESS_ACTIVITIES WPA
    where WIAS.item_type = 'OEOL'
    AND WIAS.item_key = to_char(p_x_line_rec.line_id)
    AND WIAS.activity_status = 'NOTIFIED'
    AND WPA.activity_name = 'AUTHORIZE_TO_SHIP_WAIT'
    AND WPA.instance_id = WIAS.process_activity;

l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

l_close_act_complete NUMBER := 0;

BEGIN

 if l_debug_level > 0 then
  oe_debug_pub.add('Entering Post_Write_Process',1);
 end if;

   -- QUOTING change
   IF (p_x_line_rec.operation = OE_GLOBALS.G_OPR_CREATE
	 AND p_x_line_rec.split_from_line_id IS NULL
         AND nvl(p_x_line_rec.transaction_phase_code,'F') = 'F'
      )
      OR (
  OE_Quote_Util.G_COMPLETE_NEG = 'Y'
          AND NOT OE_GLOBALS.EQUAL(p_x_line_rec.transaction_phase_code
                     ,p_old_line_rec.transaction_phase_code)
          )
   THEN
    if l_debug_level > 0 then
     oe_debug_pub.add('Call evaluate_holds_post_write for CREATE');
    end if;
     OE_Holds_PUB.evaluate_holds_post_write
      (p_entity_code => OE_GLOBALS.G_ENTITY_LINE
      ,p_entity_id => p_x_line_rec.line_id
      ,x_msg_count => l_msg_count
      ,x_msg_data => l_msg_data
      ,x_return_status => l_return_status
      );

         IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

    if l_debug_level > 0 then
      oe_debug_pub.add('After evaluate_holds_post_write in LINE Post Write');
    end if;
  END IF;
  /* bug 8471521   --- Moved the code after scheduling ---
   --Call the delayed request for holds evaluation. This is needed for a
   --scheduling fix.
   IF p_x_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE THEN

   if l_debug_level > 0 then
    oe_debug_pub.add('Calling DelayedReg for evaluate_holds in post_write for UPDATE');
   end if;

    OE_DELAYED_REQUESTS_PVT.Process_Request_for_Reqtype
         (p_request_type   =>OE_GLOBALS.G_EVAL_HOLD_SOURCE
          ,p_delete        => FND_API.G_TRUE
          ,x_return_status => l_return_status
          );
    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
    END IF;


   END IF; --- Moved the code after scheduling --- bug 8471521  */


  -- Start the Line Workflow
  --------------------------------------------------------------------

  -- QUOTING change
  IF (p_x_line_rec.operation = OE_GLOBALS.G_OPR_CREATE
      OR (OE_Quote_Util.G_COMPLETE_NEG = 'Y'
           AND NOT OE_GLOBALS.EQUAL(p_x_line_rec.transaction_phase_code
                      ,p_old_line_rec.transaction_phase_code)
           )
      )
     AND nvl(p_x_line_rec.transaction_phase_code,'F') = 'F'
  THEN
      OE_Order_WF_Util.CreateStart_LineProcess(p_x_line_rec);
  END IF;


  --------------------------------------------------------------------
   -- If freeze_included_options profile value is ENTRY,
   -- we have populated a global pl/sql table,
   -- now call function to freeze included items.
   -- Since process included items cannot set recursion mode, caler needs to set
   -- the recursion mode.
  --------------------------------------------------------------------

   l_old_recursion_mode := OE_GLOBALS.G_RECURSION_MODE;
   --   OE_GLOBALS.G_RECURSION_MODE := 'Y';

   I := OE_Config_Pvt.OE_FREEZE_INC_ITEMS_TBL.FIRST;
   WHILE I is not null
   LOOP
          if l_debug_level > 0 then
	    oe_debug_pub.add(I || ' freeze inc items call looping '||p_x_line_rec.line_id, 4);
          end if;
	    IF p_x_line_rec.line_id = OE_Config_Pvt.OE_FREEZE_INC_ITEMS_TBL(I)
	    THEN
/* Start DOO Pre Exploded Kit ER 9339742 */
        IF   (OE_GENESIS_UTIL.G_INCOMING_FROM_DOO OR OE_GENESIS_UTIL.G_INCOMING_FROM_SIEBEL)
          -- p_x_line_rec.pre_exploded_flag = 'Y'
/* Note: Here we are checking on the global G_Incoming_From_DOO and not the
Pre_Exploded_Flag attribute because user can change a DOO created Sales Order in
EBS OM Sales order pad or by directly calling the Process Order api without
settting the above global. Since the trade off is: we should allow the user to
successfully update the order, and the validation should be standard. The
validation should NOT be of Pre Exploded Kit functionality. Hence, the below
delayed request OE_GLOBALS.G_PRE_EXPLODED_KIT should get logged only if the above
global is TRUE. It should be irrespective of the Pre_Exploded_Flag attribute value. */

        AND  p_x_line_rec.ato_line_id is NULL
        AND  ((p_x_line_rec.item_type_code = OE_GLOBALS.G_ITEM_KIT
           AND p_x_line_rec.line_id = p_x_line_rec.top_model_line_id)
            -- Bug 11928288 : Start
            OR (p_x_line_rec.item_type_code = OE_GLOBALS.G_ITEM_MODEL
            AND p_x_line_rec.line_id = p_x_line_rec.top_model_line_id)
            -- Bug 11928288 : End
            OR p_x_line_rec.item_type_code = OE_GLOBALS.G_ITEM_CLASS )  THEN
          -- Importing Pre Exploded Kit.
          -- Log a delayed request for its execution after the whole Kit is
          -- imported and records are posted to OE_Order_Lines_All table
          -- This request will be logged for Kit model line

          oe_debug_pub.add(' Logging G_PRE_EXPLODED_KIT delayed requests');
          OE_delayed_requests_Pvt.log_request(
           p_entity_code            => OE_GLOBALS.G_ENTITY_LINE,
           p_entity_id              => p_x_line_rec.top_model_line_id, -- The top model line
           p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
           p_requesting_entity_id   => p_x_line_rec.line_id,
           p_date_param1            => p_x_line_rec.explosion_date,
           p_request_type           => OE_GLOBALS.G_PRE_EXPLODED_KIT,
           x_return_status          => l_return_status);
        ELSE
/* End DOO Pre Exploded Kit ER 9339742 */
                  if l_debug_level > 0 then
		    oe_debug_pub.add('PO: Calling freeze_inc_items call', 2);
                  end if;
		    l_return_status :=
		    OE_Config_Util.Process_Included_Items
						   (p_line_rec => p_x_line_rec,
		 				    p_freeze   => TRUE);

          if l_debug_level > 0 then
            oe_debug_pub.add('PO: After Calling Process_Included_Items call: ' ||
                           l_return_status, 2);
          end if;

       END IF; -- DOO Preexploded kit ER

            IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

               OE_Config_Pvt.OE_FREEZE_INC_ITEMS_TBL.DELETE(I);

            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN

                OE_Config_Pvt.OE_FREEZE_INC_ITEMS_TBL.DELETE;
                RAISE FND_API.G_EXC_ERROR;

            ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

                OE_Config_Pvt.OE_FREEZE_INC_ITEMS_TBL.DELETE;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

            END IF;

        END IF;

      I := OE_Config_Pvt.OE_FREEZE_INC_ITEMS_TBL.NEXT(I);

   END LOOP;

   ------------------------------------------------------------------------
   -- Call Scheduling to perform any scheduling on the line, if needed
   ------------------------------------------------------------------------

    -- Added code in delete_dependency for delete operation.

    --4504362: Branch scheduling check removed

      if l_debug_level > 0 then
       oe_debug_pub.add('OESCH_PERFORM_SCHEDULING :' ||
                           OE_SCHEDULE_UTIL.OESCH_PERFORM_SCHEDULING,1);
      end if;

/* 7576948: IR ISO Change Management project Start */
--
-- This check is performed to ensure if there is a line cancellation
-- from Planning workbench or DRP user in ASCP then scheduling should be
-- done to Unschedule/Undemand the order line. Other than this case,
-- if Planning user updates the order line then scheduling action
-- is not performed.
-- The global OE_Schedule_GRP.G_ISO_Planning_Update is set to TRUE
-- in package OE_Schedule_GRP.Process_Order
-- This change is done as a very specific case for IR ISO CMS project
-- when changes been done by Planning user
--

    IF OE_Schedule_GRP.G_ISO_Planning_Update AND
     NOT OE_GLOBALS.EQUAL(p_x_line_rec.ordered_quantity, p_old_line_rec.ordered_quantity) THEN
--     nvl(p_x_line_rec.ordered_quantity,0) = 0 THEN  -- Commented for bug 7611039
      OE_SCHEDULE_UTIL.OESCH_PERFORM_SCHEDULING := 'Y';

      IF l_debug_level > 0 THEN
        oe_debug_pub.add(' Setting global OE_Schedule_GRP.G_ISO_Planning_Update to TRUE',5);
      END IF;
    END IF;

/* ============================= */
/* IR ISO Change Management Ends */


       IF  OE_SCHEDULE_UTIL.OESCH_PERFORM_SCHEDULING = 'Y'
       AND p_x_line_rec.line_category_code <> 'RETURN'
       AND p_x_line_rec.operation <> OE_GLOBALS.G_OPR_DELETE
       THEN

        if l_debug_level > 0 then
         oe_debug_pub.add('PO: Calling new Schedule_line from post write',1);
        end if;

         oe_split_util.g_sch_recursion := 'TRUE';

        if l_debug_level > 0 then
         oe_debug_pub.add(' New Schedule Line',1);
        end if;
         OE_SCHEDULE_UTIL.Schedule_Line
         (p_x_line_rec    => p_x_line_rec
         ,p_old_line_rec  => p_old_line_rec
         ,x_return_status => l_return_status);

        IF OE_Schedule_GRP.G_ISO_Planning_Update THEN
           OE_SCHEDULE_UTIL.OESCH_PERFORM_SCHEDULING := 'N';
        END IF; -- Added for bug 7611039
	--  fix for bug 8217093 start

       elsIF OE_SCHEDULE_UTIL.OESCH_PERFORM_SCHEDULING ='N'
       AND  (p_x_line_rec.ship_set_id is not null
	    or p_x_line_rec.arrival_set_id is not null)
       AND (NOT oe_globals.equal(p_x_line_rec.schedule_ship_date,p_old_line_rec.schedule_ship_date) OR
                    NOT oe_globals.equal(p_x_line_rec.schedule_arrival_date,p_old_line_rec.schedule_arrival_date) OR
                    NOT oe_globals.equal(p_x_line_rec.ship_from_org_id,p_old_line_rec.ship_from_org_id) OR
                    NOT oe_globals.equal(p_x_line_rec.shipping_method_code,p_old_line_rec.shipping_method_code))
       then

	 if p_x_line_rec.ship_set_id is not null then
	   l_set_id:=p_x_line_rec.ship_set_id;
	 elsif p_x_line_rec.arrival_set_id is not null then
	   l_set_id:=p_x_line_rec.arrival_set_id;
	 end if;
        if l_debug_level > 0 then
      	 oe_debug_pub.add(' Line has set information, update the sets');
        end if;
       OE_Set_Util.Update_Set
        (p_Set_Id                   =>l_set_id,
         p_Ship_From_Org_Id         =>p_x_line_rec.Ship_From_Org_Id,
         p_Ship_To_Org_Id           =>p_x_line_rec.Ship_To_Org_Id,
         p_Schedule_Ship_Date       =>p_x_line_rec.Schedule_Ship_Date,
         p_Schedule_Arrival_Date    =>p_x_line_rec.Schedule_Arrival_Date,
         p_Freight_Carrier_Code     =>p_x_line_rec.Freight_Carrier_Code,
         p_Shipping_Method_Code     =>p_x_line_rec.Shipping_Method_Code,
         p_shipment_priority_code   =>p_x_line_rec.shipment_priority_code,
         X_Return_Status            =>l_return_status,
         x_msg_count                =>l_msg_count,
         x_msg_data                 =>l_msg_data
        );

      -- changes for bug 8217093 end

       END IF;

       oe_split_util.g_sch_recursion := 'FALSE';

      if l_debug_level > 0 then
       oe_debug_pub.add('PO: After Calling Schedule_line: ' ||
                                 l_return_status,1);
       oe_debug_pub.add('SCH: p_x_line_rec.schedule_status_code '||
                 p_x_line_rec.schedule_status_code,1);
      end if;

       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

     -- do not move Log_CTO_Requests above scheduling

      IF (p_x_line_rec.top_model_line_id is NOT NULL OR
          p_x_line_rec.ato_line_id is NOT NULL) AND
          NOT  p_x_line_rec.item_type_code = OE_GLOBALS.G_ITEM_CONFIG
      THEN

        Log_CTO_Requests( p_x_line_rec    => p_x_line_rec
                         ,p_old_line_rec  => p_old_line_rec
                         ,x_return_status => l_return_status);
      END IF;



   -- re-set the old recursion mode after process included items call.
   -- OE_GLOBALS.G_RECURSION_MODE := l_old_recursion_mode;

    -- 4504362 :Branch scheduling check removed.
-- This is moved from cancellations logic since closing the line is
-- based on the cancellation flag and ordered quantity

     IF (oe_sales_can_util.G_REQUIRE_REASON) THEN

       IF Nvl(p_x_line_rec.split_action_code,'X') <> 'SPLIT' THEN

          If (p_x_line_rec.ordered_quantity = 0 AND
		 p_x_line_rec.operation = oe_globals.G_OPR_UPDATE )then

          -- OE_GLOBALS.G_RECURSION_MODE := 'Y';
/*
-- Log a request to cancel the workflow.


        OE_delayed_requests_Pvt.log_request
        (p_entity_code                          => OE_GLOBALS.G_ENTITY_ALL,
        p_entity_id                             => p_x_line_rec.line_id,
        p_requesting_entity_code        => OE_GLOBALS.G_ENTITY_ALL,
        p_requesting_entity_id          => p_x_line_rec.line_id,
        p_request_type                  => OE_GLOBALS.G_CANCEL_WF,
	p_param1                 => OE_GLOBALS.G_ENTITY_LINE,
        x_return_status                         => l_return_status);
*/

-- commented the code to move the logic to delayed request
-- reopened to revert the changes
          wf_engine.handleerror(OE_Globals.G_WFI_LIN
                    ,to_char(p_x_line_rec.line_id)
                    ,'CLOSE_LINE',
                    'RETRY','CANCEL');
                       if l_debug_level > 0 then
			OE_DEBUG_PUB.ADD('After Calling Wf Handle Error ');
                       end if;

-- Added for FP bug 6682329. The below query is added to fix the data corruption
-- issues where both cancelled_flag and open_flag were getting set to 'Y'.

        IF nvl(p_x_line_rec.cancelled_flag,'N') = 'Y' THEN
           oe_debug_pub.add(' Line is cancelled, Close_Line WF act is ? ');
           select count(*) into l_close_act_complete
           from   wf_item_activity_statuses s,
                  wf_process_activities p
           where  s.process_activity = p.instance_id
           and    s.item_type = 'OEOL'
           and    s.item_key = to_char(p_x_line_rec.line_id)
           and    p.activity_name = 'CLOSE_LINE'
           and    activity_result_code in ('NOT_ELIGIBLE','COMPLETE')
           and    s.activity_status = 'COMPLETE';
           IF l_close_act_complete = 0 THEN
             oe_debug_pub.add(' Close_Line failed. Rollback the changes');
                FND_MESSAGE.SET_NAME('ONT','OE_CLOSE_LINE_ERROR');
                OE_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
           END IF;
        END IF;

          -- OE_GLOBALS.G_RECURSION_MODE := 'N';


            /*
            ** Fix Bug # 3184597 Start
            ** Check if the cancelled line is waiting on the flow to be
            ** started. If so, delete entry from G_START_LINE_FLOWS_TBL
            */
            IF (OE_GLOBALS.G_START_LINE_FLOWS_TBL.COUNT > 0) THEN
              l_ctr := OE_GLOBALS.G_START_LINE_FLOWS_TBL.FIRST;
              WHILE (l_ctr IS NOT NULL) LOOP
                IF (OE_GLOBALS.G_START_LINE_FLOWS_TBL(l_ctr).LINE_ID =
                                             p_x_line_rec.line_id) THEN
                  oe_debug_pub.add('Cancellation:Deleting from OE_GLOBALS.G_START_LINE_FLOWS_TBL for lineID:' || p_x_line_rec.line_id);
                 OE_GLOBALS.G_START_LINE_FLOWS_TBL.DELETE(l_ctr);
                 EXIT;
                END IF;
                l_ctr := OE_GLOBALS.G_START_LINE_FLOWS_TBL.NEXT(l_ctr);
              END LOOP;
            END IF;
            /* Fix Bug # 3184597 End */
	    -- Added below IF condition for FP bug 6628653 base bug 6513023
	                IF NOT(OE_OE_FORM_CANCEL_LINE.g_ord_lvl_can) THEN
	                   IF p_x_line_rec.top_model_line_id IS NOT NULL AND
	                      p_x_line_rec.ato_line_id IS NULL AND
	                      p_x_line_rec.item_type_code = 'INCLUDED' AND
	                          nvl(p_x_line_rec.model_remnant_flag, 'N') = 'Y'
	                   THEN
	                        oe_debug_pub.add('In case of line level cancellation: calling Handle_RFR() ');
	                         Handle_RFR(p_top_model_line_id => p_x_line_rec.top_model_line_id,
	                                    p_line_id => p_x_line_rec.line_id,
	                                    p_link_to_line_id => p_x_line_rec.link_to_line_id );
	                   END IF;
	                END IF;
	                    -- End of FP bug 6628653 base bug 6513023

		 OE_SALES_CAN_UTIL.G_REQUIRE_REASON := FALSE;
        end if;
       END IF;
	END IF;

 if l_debug_level > 0 then
  oe_debug_pub.add('RQ: ' || p_x_line_rec.reserved_quantity,1);
 end if;

 -- bug 8471521 Moved the code after scheduling call to avoid the issue happens because of the ware house change..
    --Call the delayed request for holds evaluation. This is needed for a
    --scheduling fix.
    IF p_x_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE THEN

    if l_debug_level > 0 then
     oe_debug_pub.add('Calling DelayedReg for evaluate_holds in post_write for UPDATE');
    end if;

     OE_DELAYED_REQUESTS_PVT.Process_Request_for_Reqtype
          (p_request_type   =>OE_GLOBALS.G_EVAL_HOLD_SOURCE
           ,p_delete        => FND_API.G_TRUE
           ,x_return_status => l_return_status
           );
     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
     END IF;


    END IF; --- Moved the code after scheduling --- bug 8471521
-- bug 8471521 Moved the code after scheduling call to avoid the issue happens because of the ware house change..

   -- Adding code to create reservation when item is changed on
   -- the line, since inventory expects the item to be stored on the line
   --before making any reservations. --1913263.
  -- 4504362 :Branch scheduling checks removed.

  --------------------------------------------------------------------
  -- Complete the block activity for Shipping Authorization based on the
  -- the value of the authorized_to_ship_flag in the lines table
  -- Check if the ship authorization activity is in a NOTIFIED state
  --------------------------------------------------------------------

  IF p_x_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE THEN
   if l_debug_level > 0 then
    oe_debug_pub.add('Authorization flag is: ' ||
                                 p_x_line_rec.authorized_to_ship_flag);
   end if;
    IF p_x_line_rec.authorized_to_ship_flag = 'Y' AND
 	  NOT OE_GLOBALS.Equal(p_x_line_rec.authorized_to_ship_flag,
					p_old_line_rec.authorized_to_ship_flag)
    THEN
      OPEN ship_authorize;
      FETCH ship_authorize INTO l_ship_authorize;
      CLOSE ship_authorize;
      IF (l_ship_authorize = 'Y')
      THEN
         WF_ENGINE.CompleteActivityInternalName('OEOL', p_x_line_rec.line_id,
                      'AUTHORIZE_TO_SHIP_WAIT', 'COMPLETE');
      END IF;
    END IF;
  END IF;

  --------------------------------------------------------------------
   -- Line Number update logic.
   -- Update/Cascade linenumber changes to it children.
   -- If the line number is updated at Standard line then update all
   -- its children (Service).
   -- If the line number is updated at Model/Kit then update all its
   -- children and sub children(like options,classes,services,service
   -- attached to children).
  --------------------------------------------------------------------

   IF p_x_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE THEN

      IF NOT OE_GLOBALS.EQUAL(p_x_line_rec.line_number ,
	 					p_old_line_rec.line_number)
      THEN
	   Cascade_Line_Number
			( p_x_line_rec.header_id,
                        p_x_line_rec.line_id,
	    		p_x_line_rec.line_set_id,
         		p_x_line_rec.item_type_code,
         		p_x_line_rec.line_number
			);
      END IF; -- Equal.

   END IF; -- G_OPR_UPDATE.


  --------------------------------------------------------------------
   -- Create sales credits if sales rep on the line is different than header
   -- The reason to call procedure to evaluate this is to validate couple of
   -- other cases.
  --------------------------------------------------------------------

   IF  NOT (nvl(p_x_line_rec.split_action_code,'X') = 'SPLIT' and
               p_x_line_rec.operation = oe_globals.g_opr_update)
   THEN

     IF  NOT( (nvl(p_x_line_rec.split_from_line_id,FND_API.G_MISS_NUM)
				<> FND_API.G_MISS_NUM)
               AND p_x_line_rec.operation = oe_globals.g_opr_create
             )
     THEN

        if l_debug_level > 0 then
	 oe_debug_pub.add('Before Calling Create Credit');
        end if;

   -- Bug# 5726848 IF condition modified for allowing update of sales credit for copied orders.
   	 IF NOT (nvl(p_x_line_rec.source_document_type_id,-99) = 2 AND
	         p_x_line_rec.operation = oe_globals.g_opr_create) THEN
   -- End of change Bug# 5726848
                 OE_Line_Scredit_Util.Create_Credit
		(p_line_rec => p_x_line_rec,p_old_line_rec => p_old_line_rec);
      END IF;

     END IF;

   END IF;

   -- Executing the RMA child creation request here so that line numbers of
   -- child RMA lines are in sequence with the parent line. FOR ER:1480867

   IF p_x_line_rec.line_category_code = 'RETURN' AND
      p_x_line_rec.reference_line_id IS NOT NULL AND
      OE_GLOBALS.G_RETURN_CHILDREN_MODE = 'N' AND
      NOT OE_GLOBALS.EQUAL(p_x_line_rec.reference_line_id ,
                        p_old_line_rec.reference_line_id)

   THEN
       OE_DELAYED_REQUESTS_PVT.Process_Request_for_Reqtype
         (p_request_type   =>OE_GLOBALS.G_INSERT_RMA
          ,p_delete        => FND_API.G_TRUE
          ,x_return_status => l_return_status
          );
   END IF;

   -- BLANKETS: Log requests to validate and update release qty/amount
   -- Not needed for returns, returned qty on blanket would
   -- be updated when return is fulfilled!
   -- Changed to enable to accept CONFIG and SERVICE items for Pack -J onwards.
   IF ((OE_CODE_CONTROL.Get_Code_Release_Level >= '110510'
        AND p_x_line_rec.item_type_code <> 'INCLUDED')
       -- Blanket reference can only be specified for standard items
       -- and kit items
      OR (OE_CODE_CONTROL.Get_Code_Release_Level >= '110509'
           AND p_x_line_rec.item_type_code IN ('STANDARD','KIT')))
      AND (p_x_line_rec.blanket_number IS NOT NULL
       OR p_old_line_rec.blanket_number IS NOT NULL)
      AND p_x_line_rec.line_category_code = 'ORDER'
      -- QUOTING change
      AND nvl(p_x_line_rec.transaction_phase_code,'F') = 'F'
   THEN

     -- Blanket Request should not be logged for system splits.
     IF (nvl(p_x_line_rec.split_action_code,'X') = 'SPLIT'
         AND p_x_line_rec.operation = oe_globals.g_opr_update
         AND nvl(p_x_line_rec.split_by,'USER') = 'SYSTEM'
         )
     OR (nvl(p_x_line_rec.split_from_line_id,FND_API.G_MISS_NUM)
				<> FND_API.G_MISS_NUM
         AND p_x_line_rec.operation = oe_globals.g_opr_create
         AND nvl(p_x_line_rec.split_by,'USER') = 'SYSTEM'
         )
     THEN
        NULL;
     ELSE
        Log_Blanket_Request(p_x_line_rec,p_old_line_rec);
     END IF;

   END IF;

  if l_debug_level > 0 then
   oe_debug_pub.add('Exiting Post_Write_Process',1);
  end if;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        RAISE;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN


        RAISE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
          ,   'Post_Write_Process'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Post_Write_Process;



/*----------------------------------------------------------
PROCEDURE Post_Line_Process
-----------------------------------------------------------*/

PROCEDURE Post_Line_Process
(   p_control_rec		    		IN  OE_GLOBALS.Control_Rec_Type
,   p_x_line_tbl                   IN OUT NOCOPY  OE_Order_PUB.Line_Tbl_Type
)
IS
l_return_status    VARCHAR2(1);
I                  NUMBER;
l_count            NUMBER;
l_valid_line_number VARCHAR2(1) := 'Y';
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

 if l_debug_level > 0 then
  oe_debug_pub.add('entering Post_Line_Process', 1);
 end if;

  -- Create Sets for lines and call group scheduling if any
  /*
  IF (p_control_rec.process AND
	OE_GLOBALS.G_RECURSION_MODE <> 'Y')THEN
      OE_Set_Util.Process_Sets
		(p_x_line_tbl => p_x_line_tbl);
  END IF;
  */

  IF (p_control_rec.process AND
	OE_GLOBALS.G_RECURSION_MODE <> 'Y') THEN

      -- batch validation request is executed in post_lines
      -- so that it gets executed before any other delayed requests
      -- like pricing, scheduling for models.

      OE_DELAYED_REQUESTS_PVT.Process_Request_for_Reqtype
         (p_request_type   =>OE_GLOBALS.G_VALIDATE_CONFIGURATION
          ,p_delete        => FND_API.G_TRUE
          ,x_return_status => l_return_status
          );

     if l_debug_level > 0 then
      oe_debug_pub.add('ret sts: '|| l_return_status, 4);
     end if;

      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- cascading of changes from model to options
      -- is done before executing other requests.

      OE_DELAYED_REQUESTS_PVT.Process_Request_for_Reqtype
         (p_request_type   =>OE_GLOBALS.G_CASCADE_CHANGES
          ,p_delete        => FND_API.G_TRUE
          ,x_return_status => l_return_status
          );

      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Making change to whole configuration is done before all
      -- other delayed requests are fired.

      OE_DELAYED_REQUESTS_PVT.Process_Request_for_Reqtype
         (p_request_type   => OE_GLOBALS.G_CHANGE_CONFIGURATION
          ,p_delete        => FND_API.G_TRUE
          ,x_return_status => l_return_status
          );
      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- handling split of models

      OE_DELAYED_REQUESTS_PVT.Process_Request_for_Reqtype
         (p_request_type   => OE_GLOBALS.G_COPY_CONFIGURATION
          ,p_delete        => FND_API.G_TRUE
          ,x_return_status => l_return_status
          );

      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      IF OE_Config_Pvt.OE_MODIFY_INC_ITEMS_TBL.COUNT > 0 THEN
        oe_debug_pub.add('calling modufy inc items', 3);
        OE_Config_Pvt.Modify_Included_Items
        (x_return_status => l_return_status);
        OE_Config_Pvt.OE_MODIFY_INC_ITEMS_TBL.DELETE;

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;


      OE_SERVICE_UTIL.Update_Service_Lines
               (p_x_line_tbl      => p_x_line_tbl,
                x_return_status   => l_return_status);

      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;


    -- added for bug fix 2375829

  if l_debug_level > 0 then
    oe_debug_pub.add('line tbl count: '||p_x_line_tbl.COUNT, 3);
  end if;

    I := p_x_line_tbl.FIRST;

    WHILE I is NOT NULL
    LOOP

      IF nvl(p_x_line_tbl(I).booked_flag, 'N') = 'N' THEN
       if l_debug_level > 0 then
        oe_debug_pub.add('not booked ', 3);
       end if;
            --below two lines are commented for bug 14298754
      --  EXIT;
     -- END IF;
      ELSE       -- Added for bug 14298754
     if l_debug_level > 0 then
      oe_debug_pub.add(p_x_line_tbl(I).operation ||
      ' cancelled flag ' || p_x_line_tbl(I).cancelled_flag||
      ' shp interf '||p_x_line_tbl(I).shipping_interfaced_flag, 3);
     end if;

      IF (p_x_line_tbl(I).operation = 'DELETE' OR
         (p_x_line_tbl(I).operation = 'UPDATE' AND
          p_x_line_tbl(I).cancelled_flag = 'Y')) AND
          p_x_line_tbl(I).top_model_line_id is not NULL AND
          nvl(p_x_line_tbl(I).ship_model_complete_flag, 'N') = 'Y' AND
          nvl(p_x_line_tbl(I).shipping_interfaced_flag, 'N') = 'N' AND
          nvl(p_x_line_tbl(I).model_remnant_flag, 'N') = 'N'
      THEN
        oe_debug_pub.add('cancel or delete, call smc shipping', 1);

        SELECT count(*)
        INTO   l_count
        FROM   oe_order_lines
        WHERE  top_model_line_id = p_x_line_tbl(I).top_model_line_id
        AND    shipping_interfaced_flag = 'Y';

        IF l_count = 0 THEN

          oe_debug_pub.add('need to call smc shipping', 1);

          OE_Shipping_Integration_PVT.Process_SMC_Shipping
          (p_line_id           => p_x_line_tbl(I).line_id
          ,p_top_model_line_id => p_x_line_tbl(I).top_model_line_id
          ,x_return_status     => l_return_status);

          IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
          END IF;
        END IF;

      END IF;
     END IF;  --Added for bug 14298754
-- Validate line number for bug no 5493479 start

      IF  (p_x_line_tbl(I).item_type_code = 'STANDARD'
            --below line commented to handle bugs 14298754 ,6186920
        -- OR (p_x_line_tbl(I).top_model_line_id <> p_x_line_tbl(I).line_id
           OR (p_x_line_tbl(I).top_model_line_id = p_x_line_tbl(I).line_id    --Added for bugs 14298754 ,6186920
           AND p_x_line_tbl(I).item_type_code = 'MODEL'))
           AND OE_ORDER_IMPORT_MAIN_PVT.G_CONTEXT_ID IS NOT NULL
        THEN
         IF p_x_line_tbl(I).line_set_id IS NULL OR p_x_line_tbl(I).line_set_id = FND_API.G_MISS_NUM THEN  --If part added for bug# 14298754
          BEGIN

           SELECT 'N'
           INTO   l_valid_line_number
           FROM   oe_order_lines L
           WHERE  L.line_number = p_x_line_tbl(I).line_number
           AND    L.header_id = p_x_line_tbl(I).header_id
           AND    L.line_id <> p_x_line_tbl(I).line_id
           AND    ( L.item_type_code = 'STANDARD'
           OR     ( L.top_model_line_id = L.line_id
           AND      L.item_type_code = 'MODEL'));

          EXCEPTION
                WHEN no_data_found THEN
                   l_valid_line_number := 'Y';
             -- Too many rows exception would be raised if there are split
                -- lines with the same line number
                WHEN too_many_rows THEN
                   l_valid_line_number := 'N';
                WHEN OTHERS THEN
                   l_valid_line_number := 'N';
          END;
         ELSE
          BEGIN

           SELECT 'N'
           INTO   l_valid_line_number
           FROM   oe_order_lines L
           WHERE  L.line_number = p_x_line_tbl(I).line_number
           AND    L.header_id = p_x_line_tbl(I).header_id
           AND    L.line_id <> p_x_line_tbl(I).line_id
           AND    nvl(L.line_set_id,-9999) <>nvl( p_x_line_tbl(I).line_set_id,-9999) -- bug 10414075
           AND    ( L.item_type_code = 'STANDARD'
           OR     ( L.top_model_line_id = L.line_id
           AND      L.item_type_code = 'MODEL'));

          EXCEPTION
                WHEN no_data_found THEN
                   l_valid_line_number := 'Y';
             -- Too many rows exception would be raised if there are split
                -- lines with the same line number
                WHEN too_many_rows THEN
                   l_valid_line_number := 'N';
                WHEN OTHERS THEN
                   l_valid_line_number := 'N';
          END;
	 END IF;   --Added for bug 14298754
          IF l_valid_line_number = 'N' THEN
                FND_MESSAGE.SET_NAME('ONT','OE_LINE_NUMBER_EXISTS');
                OE_MSG_PUB.ADD;
                l_return_status := FND_API.G_RET_STS_ERROR;
                RAISE FND_API.G_EXC_ERROR; --added for bug 14298754
          END IF;

         END IF;
-- Validate line number for bug no 5493479 end
      I := p_x_line_tbl.NEXT(I);

    END LOOP;

  END IF; -- if not recursion and process = true.


  -- Move the code below so that cascading will happen if any before
  -- scheduling. 2404695

  -- Create Sets for lines and call group scheduling if any

  IF (p_control_rec.process AND
    OE_GLOBALS.G_RECURSION_MODE <> 'Y')THEN

      OE_Set_Util.Process_Sets
        (p_x_line_tbl => p_x_line_tbl);

    IF OE_SPLIT_UTIL.G_SPLIT_ACTION = TRUE THEN

      -- We will call split_scheduling here for lines which got created
      -- thru splits.

     if l_debug_level > 0 then
      oe_debug_pub.add('Calling Split Scheduling',1);
     end if;

      -- 4504362 :Branch Scheduling checks removed.
     IF p_x_line_tbl.count > 0 THEN -- 10626432

        OE_SCHEDULE_UTIL.Split_Scheduling
          (p_x_line_tbl      => p_x_line_tbl,
           x_return_status   => l_return_status);
     END IF;

      OE_SPLIT_UTIL.G_SPLIT_ACTION := FALSE;

      if l_debug_level > 0 then
       oe_debug_pub.add('After Calling Split Scheduling: ' ||
                         l_return_status,1);
      end if;

       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
       END IF;

    END IF; -- if split action

  END IF;

  IF OE_SPLIT_UTIL.G_SPLIT_ACTION = TRUE THEN

   if l_debug_level > 0 then
    oe_debug_pub.add('Logging g_split_action',2);
   end if;

    I := p_x_line_tbl.FIRST;
    WHILE I is NOT NULL
    LOOP


      IF  (NVL(p_x_line_tbl(I).split_by ,'USER') = 'SYSTEM' AND
          NVL(p_x_line_tbl(I).split_action_code,'X') = 'SPLIT' AND
          p_x_line_tbl(I).schedule_status_code IS NOT NULL)
      OR (NVL(p_x_line_tbl(I).split_by ,'USER') = 'SYSTEM' AND
          p_x_line_tbl(I).split_from_line_id is not null AND
          p_x_line_tbl(I).split_from_line_id <> FND_API.G_MISS_NUM AND
          p_x_line_tbl(I).operation = OE_GLOBALS.G_OPR_CREATE) THEN

         if l_debug_level > 0 then
          oe_debug_pub.add('Logging G_SPLIT_SCHEDULE' ||
                            p_x_line_tbl(I).line_id, 2);
         end if;

          OE_delayed_requests_Pvt.log_request(
          p_entity_code            => OE_GLOBALS.G_ENTITY_LINE,
          p_entity_id              => p_x_line_tbl(I).line_id,
          p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
          p_requesting_entity_id   => p_x_line_tbl(I).line_id,
          p_request_type           => OE_GLOBALS.G_SPLIT_SCHEDULE,
          p_param1                 => p_x_line_tbl(I).schedule_status_code,
          p_param2                 => p_x_line_tbl(I).arrival_set_id,
          p_param3                 => p_x_line_tbl(I).ship_set_id,
          p_param4                 => p_x_line_tbl(I).ship_model_complete_flag,
          p_param5                 => p_x_line_tbl(I).model_remnant_flag,
          p_param6                 => p_x_line_tbl(I).top_model_line_id,
          p_param7                 => p_x_line_tbl(I).ato_line_id,
          p_param8                 => p_x_line_tbl(I).item_type_code,
          p_param9                 => p_x_line_tbl(I).source_type_code,  --added for bug 12757660
          x_return_status          => l_return_status);


           OE_SPLIT_UTIL.G_SPLIT_ACTION := FALSE;

      END IF;

      I := p_x_line_tbl.NEXT(I);

    END LOOP;

  END IF; -- if not recursion and process = true.


 if l_debug_level > 0 then
  oe_debug_pub.add('leaving Post_Line_Process', 1);
 end if;
EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
        oe_debug_pub.add('execution error', 1);
        RAISE;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        oe_debug_pub.add('unexp error', 1);
        RAISE;

    WHEN OTHERS THEN
        oe_debug_pub.add('others error', 1);
        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
          ,   'Pre_Line_Process'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Post_Line_Process;


/*----------------------------------------------------------
Function Get_Return_Item_Type_Code
-----------------------------------------------------------*/
Function Get_Return_Item_Type_Code
(   p_line_rec                      IN OE_Order_PUB.Line_Rec_Type
) RETURN varchar2
IS
l_item_type_code varchar2(30);
BEGIN

  IF p_line_rec.line_category_code = 'RETURN'
  and p_line_rec.reference_line_id is not null THEN

  	SELECT item_type_code
  	INTO l_item_type_code
  	FROM oe_order_lines
     WHERE line_id = p_line_rec.reference_line_id;

     RETURN l_item_type_code;
  ELSE
     RETURN p_line_rec.item_type_code;
  END IF;

  RETURN p_line_rec.item_type_code;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN null;
  WHEN OTHERS THEN
    RETURN null;
END Get_Return_Item_Type_Code;



/*----------------------------------------------------------

--  OPM 02/JUN/00  BEGIN
--  ====================

FUNCTION dual_uom_control renamed from process_characteristics
-----------------------------------------------------------*/

FUNCTION dual_uom_control -- INVCONV renamed from process_characteristics
(
  p_inventory_item_id IN NUMBER
 ,p_ship_from_org_id  IN NUMBER
 ,x_item_rec          OUT NOCOPY OE_ORDER_CACHE.item_rec_type
)
RETURN BOOLEAN
IS

l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

BEGIN
/*   INVCONV
IF FND_PROFILE.VALUE ('ONT_PROCESS_INSTALLED_FLAG') = 'N' THEN
  RETURN FALSE;
END IF;  */

/* If item and warehouse are both present, assess if this is
   a dual controlled ine:
 ======================================================================*/
IF (p_inventory_item_id IS NOT NULL AND
  p_inventory_item_id <> FND_API.G_MISS_NUM) AND
  (p_ship_from_org_id  IS NOT NULL AND
  p_ship_from_org_id <> FND_API.G_MISS_NUM) THEN
    x_item_rec :=
    	     OE_Order_Cache.Load_Item (p_inventory_item_id
                                    ,p_ship_from_org_id);
--  IF x_item_rec.process_warehouse_flag = 'Y'  INVCONV
-- AND INVCONV
  oe_debug_pub.add('in function Dual_uom_control - tracking_quantity_ind  = ' || x_item_rec.tracking_quantity_ind);
  IF x_item_rec.tracking_quantity_ind = 'PS' -- INVCONV
    THEN

    IF l_debug_level  > 0 THEN
    	oe_debug_pub.add('Dual_uom_control is TRUE ', 1);
    end if;
    RETURN TRUE;
  END IF;
END IF;

IF l_debug_level  > 0 THEN
    	oe_debug_pub.add('Dual_uom_control is FALSE ', 1);
end if;

RETURN FALSE;


EXCEPTION
WHEN NO_DATA_FOUND THEN
  RETURN NULL;
WHEN OTHERS THEN
     IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
         OE_MSG_PUB.Add_Exc_Msg
         (     G_PKG_NAME         ,
             'dual_uom_control'
         );
     END IF;
        oe_debug_pub.add('others in dual_uom_control', 1);
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END dual_uom_control ;


/*----------------------------------------------------------
FUNCTION Get_Dual_Uom
----------------------------------------------------------- INVCONV REMOVEd to OE_Default_Line

FUNCTION Get_Dual_Uom(p_line_rec OE_ORDER_PUB.Line_Rec_Type)
RETURN VARCHAR2
IS
-- l_APPS_UOM2  VARCHAR2(3) := NULL; INVCONV
l_status     VARCHAR2(1);
l_msg_count  NUMBER;
l_msg_data   VARCHAR2(2000);
l_item_rec   OE_ORDER_CACHE.item_rec_type;

l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

BEGIN
       if l_debug_level > 0 then
	oe_debug_pub.add('Enter Get dual uom');
       end if;

IF dual_uom_control   -- INVCONV  Process_Characteristics
  (p_line_rec.inventory_item_id,p_line_rec.ship_from_org_id,l_item_rec) THEN
  IF l_item_rec.tracking_quantity_ind = 'PS' THEN -- INVCONV
       if l_debug_level > 0 then
					oe_debug_pub.add('Get dual uom - tracking in P and S ');
       end if;
      -- convert 4 digit apps OPM codes to equivalent 3 byte APPS codes
      -- Primary UM
      GMI_Reservation_Util.Get_AppsUOM_from_OPMUOM
					 (p_OPM_UOM        => l_item_rec.opm_item_um2
					 ,x_Apps_UOM       => l_APPS_UOM2
					 ,x_return_status  => l_status
					 ,x_msg_count      => l_msg_count
					 ,x_msg_data       => l_msg_data);



       if l_debug_level > 0 then
					oe_debug_pub.add('Get  Dual Uom returns dual UM of ' || l_item_rec.secondary_uom_code);
       end if;
  END IF;
END IF;
RETURN l_item_rec.secondary_uom_code; -- INVCONV

EXCEPTION

WHEN NO_DATA_FOUND THEN

       if l_debug_level > 0 then
	oe_debug_pub.add('No Data Found Get Dual Uom' );
       end if;
RETURN NULL;

WHEN OTHERS THEN
     IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
         OE_MSG_PUB.Add_Exc_Msg
         (     G_PKG_NAME         ,
             'Get_Dual_Uom'
         );
     END IF;
       if l_debug_level > 0 then
        oe_debug_pub.add('others in get_dual uom', 1);
       end if;
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;


END Get_Dual_Uom;   */


/*----------------------------------------------------------
FUNCTION Get_Preferred_Grade
-----------------------------------------------------------   INVCONV removed

FUNCTION Get_Preferred_Grade(p_line_rec OE_ORDER_PUB.Line_Rec_Type,
					    p_old_line_rec OE_ORDER_PUB.Line_Rec_Type)
RETURN VARCHAR2
IS
l_grade_ctl       NUMBER(5):= NULL;
l_preferred_grade VARCHAR2(4) := NULL;
l_item_rec        OE_ORDER_CACHE.item_rec_type;

CURSOR C_GRADE1 IS
SELECT alot.prefqc_grade
FROM op_alot_prm alot, ic_item_mst item, op_cust_mst cust
WHERE item.item_id = l_item_rec.opm_item_id
          and alot.cust_id = cust.cust_id
		  and item.alloc_class = alot.alloc_class
		  and alot.delete_mark = 0
		  and cust.of_ship_to_site_use_id = p_line_rec.ship_to_org_id;

CURSOR C_GRADE2 IS
SELECT alot.prefqc_grade
FROM op_alot_prm alot, ic_item_mst item
WHERE item.item_id = l_item_rec.opm_item_id
	       and alot.cust_id IS NULL
		  and item.alloc_class = alot.alloc_class
		  and alot.delete_mark = 0;
BEGIN

IF oe_line_util.Process_Characteristics
  (p_line_rec.inventory_item_id,p_line_rec.ship_from_org_id,l_item_rec) AND
  ((NOT OE_GLOBALS.EQUAL(p_line_rec.ordered_item
                       ,p_old_line_rec.ordered_item)) OR
  (NOT OE_GLOBALS.EQUAL(p_line_rec.ship_from_org_id
                       ,p_old_line_rec.ship_from_org_id))) AND
  (p_line_rec.preferred_grade IS NULL OR
    p_line_rec.preferred_grade = FND_API.G_MISS_CHAR) THEN
  NULL;
ELSE
  RETURN p_line_rec.preferred_grade;
END IF;
oe_debug_pub.add('OPM Test grade ctl for preferred grade');

IF l_item_rec.grade_ctl = 1 THEN
  OPEN C_GRADE1;
  FETCH C_GRADE1 into l_preferred_grade;
  IF (C_GRADE1%NOTFOUND) THEN
    CLOSE C_GRADE1;
    OPEN C_GRADE2;
    FETCH C_GRADE2 into l_preferred_grade;
    IF (C_GRADE2%NOTFOUND) THEN
      CLOSE C_GRADE2;
	 RETURN NULL;
    END IF;
  END IF;
END IF;
RETURN l_preferred_grade;

EXCEPTION


WHEN OTHERS THEN
     IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
         OE_MSG_PUB.Add_Exc_Msg
         (     G_PKG_NAME         ,
             'Get_Preferred_Grade'
         );
     END IF;
        oe_debug_pub.add('others in get_preferred_grade', 1);
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;


END Get_Preferred_Grade;   */

-- Comment Label for procedure added as part of Inline Documentation Drive.
------------------------------------------------------------------------------------
-- Procedure Name : Sync_Dual_Qty
-- Input Params   : p_x_line_rec        : New Line Record for POAPI Processing.
--                  p_old_line_rec      : Old Line Record for POAPI Processing.
-- Output Params  : p_x_line_rec        : New Line Record for POAPI Processing.
-- Description    : This procedure does a sync up of the dual quantity i.e.
--                  syncs up the qrdered_quantity2 as per the ordered_quantity
--                  on line getting processed, if it is needed, i.e. if its a
--                  split line, or some update is happening on warehouse.
--                  There are several conditions of Early Exit from the procedure
--                  if processing/recalculation of Ordered_Quantity2 is not needed.
--                  In the end, if there is no early exit, the ordered_quantity2 is
--                  recalculated from ordered_quantity based on UOMs and conversion
--                  setup.
--                  This procedure is called only from this package and is useful
--                  during creation of SPLIT Line in ITS and also during update
--                  of Warehouse on the Order Line.
--                  The conditions of early exit are like below:
--                  a) Non Dual Control
--                  b) Cancellation of Line.
--                  c) If Secondary_Default_Index is not "Fixed" for OPM.
--                  d) While Splitting during ITS,so as to directly populate data
--                     from Shipping, rather than recalculating.
--                  e) If neither qordered_quantity of ordered_quantity2 are present.
--                  f) Early return if no Sync is required, due to no change.
------------------------------------------------------------------------------------
/*----------------------------------------------------------
PROCEDURE Sync_Dual_Qty
-----------------------------------------------------------*/
PROCEDURE Sync_Dual_Qty
(
   P_X_LINE_REC        IN OUT NOCOPY OE_ORDER_PUB.Line_Rec_Type
  ,P_OLD_LINE_REC      IN OE_ORDER_PUB.Line_Rec_Type
)
IS

l_converted_qty        NUMBER(19,9);          -- OPM 25/AUG/00
l_item_rec             OE_ORDER_CACHE.item_rec_type;
-- l_OPM_UOM              VARCHAR2(4); INVCONV
l_return               NUMBER;
l_status               VARCHAR2(1);
l_msg_count            NUMBER;
-- l_msg_data             VARCHAR2(2000); -- INVCONV
UOM_CONVERSION_FAILED  EXCEPTION;             -- OPM B1478461
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_buffer                  VARCHAR2(2000); -- INVCONV

--X_message VARCHAR2(1000);       -- INVCONV
--X_temp NUMBER;



BEGIN


IF l_debug_level  > 0 THEN
 		oe_debug_pub.add('Entering Sync Dual Qty');
END IF;


  /* Moved this code from below to here - 2999767 */
 /* If this is a dual_control item line, load the item details from cache
 ==============================================================*/
IF dual_uom_control
 (p_x_line_rec.inventory_item_id,p_x_line_rec.ship_from_org_id,
 l_item_rec) THEN
--   IF l_item_rec.dualum_ind not in (1,2,3) INVCONV
    IF l_item_rec.tracking_quantity_ind <> 'PS'

    THEN
      IF l_debug_level  > 0 THEN
 					oe_debug_pub.add('Sync Dual Qty not dual controlled  - return');   -- INVCONV
			END IF;
      p_x_line_rec.ordered_quantity2 := NULL;
      RETURN;
   END IF;
ELSE

  IF l_debug_level  > 0 THEN
 					oe_debug_pub.add('not dual controlled -  return');
	END IF;

  --  p_x_line_rec.ordered_quantity2 := NULL;      OPM 2711743
  RETURN;
END IF;

IF (OE_OE_FORM_CANCEL_LINE.g_ord_lvl_can) THEN -- 5141545
	       oe_debug_pub.add ('Sync Dual Qty - Cancellation so return ' );
	       return;
	 else
	    oe_debug_pub.add ('Sync Dual Qty - NOT a cancellation ' );
END IF;


IF l_debug_level  > 0 THEN
	oe_debug_pub.add ('In sync_dual_qty');
	oe_debug_pub.add ('ordered_quantity = ' || p_x_line_rec.ordered_quantity );
	oe_debug_pub.add ('ordered_quantity2 = ' || p_x_line_rec.ordered_quantity2 );

	oe_debug_pub.add ('ordered_quantity_uom = ' || p_x_line_rec.order_quantity_uom );
	oe_debug_pub.add ('ordered_quantity_uom2 = ' || p_x_line_rec.ordered_quantity_uom2 );
	oe_debug_pub.add ('inventory_item_id = ' || p_x_line_rec.inventory_item_id );
	oe_debug_pub.add ('ship_from_org_id = ' || p_x_line_rec.ship_from_org_id );
	oe_debug_pub.add ('secondary_default_ind  =  ' || l_item_rec.secondary_default_ind   );
	oe_debug_pub.add ('p_x_line_rec.source_document_type_id = ' || p_x_line_rec.source_document_type_id );

	IF p_x_line_rec.ordered_quantity_uom2 = FND_API.G_MISS_CHAR THEN
	 		oe_debug_pub.add ('ordered_quantity_uom2 = G_MISS_CHAR  ' );
	ELSIF
	  p_x_line_rec.ordered_quantity_uom2 is null THEN
	   	oe_debug_pub.add ('ordered_quantity_uom2 = null' );
	END IF;
	IF p_x_line_rec.ordered_quantity2 = FND_API.G_MISS_NUM THEN
	 		oe_debug_pub.add ('ordered_quantity2 = G_MISS_NUM  ' );
	ELSIF
	  p_x_line_rec.ordered_quantity2 is null THEN
	   	oe_debug_pub.add ('ordered_quantity2 = null' );
	END IF;


END IF;




-- secondary_default_ind value of ' ' = type 0
-- secondary_default_ind value of F   = type 1
-- secondary_default_ind value of D   = type 2
-- secondary_default_ind value of N   = type 3

-- bug 4053117 start  pal
 IF  OE_GLOBALS.Equal(p_x_line_rec.ship_from_org_id,p_old_line_rec.ship_from_org_id)
    and l_item_rec.secondary_default_ind <> 'F'
         and (
   				(p_x_line_rec.ordered_quantity IS NOT NULL and
 					 p_x_line_rec.ordered_quantity <> FND_API.G_MISS_NUM )  AND
  					(p_x_line_rec.ordered_quantity2 IS NOT NULL and
  					p_x_line_rec.ordered_quantity2 <> FND_API.G_MISS_NUM )
  					) THEN
    		 IF l_debug_level  > 0 THEN
 						oe_debug_pub.add('Sync_dual_qty IF (OE_GLOBALS.G_UI_FLAG) and ship froms = -   early exit ');
				 END IF;
 				 RETURN;
END IF;
-- bug 4053117 end

-- 5172701 pal
IF NOT ( OE_GLOBALS.Equal(p_x_line_rec.ship_from_org_id,p_old_line_rec.ship_from_org_id) )
and l_item_rec.secondary_uom_code is NOT NULL
  THEN
   p_x_line_rec.ordered_quantity_uom2 := l_item_rec.secondary_uom_code;
END IF;




IF ( (nvl(p_x_line_rec.shipping_quantity2,0) > 0)
     -- OPM B1661023 04/02/01 PARENT with a SYSTEM split from SHIPPING
     AND ((nvl(P_X_LINE_REC.ordered_quantity,0) =  nvl(P_OLD_LINE_REC.ordered_quantity,0)
         AND (nvl(P_X_LINE_REC.ordered_quantity2,0) =  nvl(P_OLD_LINE_REC.ordered_quantity2,0)))
     -- OPM B2169135 03/18/01  Qty 1 or 2 should default with item controls when one qty is changed.
         )
 OR
     (p_x_line_rec.split_from_line_id IS NOT NULL AND
      -- CHILD with a SYSTEM split from SHIPPING
      p_x_line_rec.split_by = 'SYSTEM' AND
      -- need to check if user or system  , early exit if system else sync
      p_x_line_rec.line_category_code <> 'RETURN'
      AND ((nvl(P_X_LINE_REC.ordered_quantity,0) =  nvl(P_OLD_LINE_REC.ordered_quantity,0)
           AND (nvl(P_X_LINE_REC.ordered_quantity2,0) =  nvl(P_OLD_LINE_REC.ordered_quantity2,0)))))
      -- OPM B2169135 03/18/01  Qty 1 or 2 should default with item controls when one qty is changed.
   )

 /* Begin 2999767 */
-- OR   ( l_item_rec.dualum_ind = 1
   OR   ( l_item_rec.secondary_default_ind  = 'F' -- INVCONV
      AND (nvl(p_x_line_rec.shipping_quantity2,0) > 0) -- OPM  PARENT with a SYSTEM split from SHIPPING
      AND (nvl(P_X_LINE_REC.ordered_quantity,0) <> 0)
      AND (nvl(P_X_LINE_REC.ordered_quantity2,0) <> 0)
      )
 --OR   ( l_item_rec.dualum_ind = 1
 OR   ( l_item_rec.secondary_default_ind  = 'F' -- INVCONV
      AND p_x_line_rec.split_from_line_id IS NOT NULL  -- CHILD with a SYSTEM split from SHIPPING
      AND p_x_line_rec.split_by = 'SYSTEM'
      -- need to check if user or system  , early exit if system else sync
      AND p_x_line_rec.operation = OE_GLOBALS.G_OPR_CREATE --13446725
      AND p_x_line_rec.line_category_code <> 'RETURN'
      AND ((nvl(P_X_LINE_REC.ordered_quantity,0) <> 0) )
      AND ((nvl(P_X_LINE_REC.ordered_quantity2,0) <> 0)) )  --added for bug 7418730
-- Bug 7418730 is for secondary quantity getting cleared on change of warehouse
-- on system split line.This part of code was causing early exit and not allowing
-- the secondary quantity to be populated. Added extra condition to avoid the early exit.
 /* End Bug2999767 */
THEN

	 IF l_debug_level  > 0 THEN
 			oe_debug_pub.add('Sync_dual_qty -  early exit ');
	 END IF;

   RETURN;
END IF;  -- OPM B1661023 04/02/01


/* If neither quantity is present, no sync is required
======================================================*/
IF (p_x_line_rec.ordered_quantity IS NULL OR
  p_x_line_rec.ordered_quantity = FND_API.G_MISS_NUM ) AND
  (p_x_line_rec.ordered_quantity2 IS NULL OR
  p_x_line_rec.ordered_quantity2 = FND_API.G_MISS_NUM ) THEN

	  IF l_debug_level  > 0 THEN
  		oe_debug_pub.add ('Sync_dual_qty -  both quantities empty so early return');
  	END IF;

    RETURN;
END IF;

IF l_debug_level  > 0 THEN
	oe_debug_pub.add('Sync_dual_qty - Convert for dual Scenario',1); -- INVCONV
END IF;

/* -- Bug3052287  INVCONV
-- When the primary UOM1 itself is not populated, derive it from l_item_rec.
  IF (p_x_line_rec.order_quantity_uom is NULL)
 or (p_x_line_rec.order_quantity_uom = FND_API.G_MISS_CHAR )
 THEN
   GMI_Reservation_Util.Get_AppsUOM_from_OPMUOM
					 (p_OPM_UOM        => l_item_rec.opm_item_um
					 ,x_Apps_UOM       => p_x_line_rec.order_quantity_uom
					 ,x_return_status  => l_status
					 ,x_msg_count      => l_msg_count
					 ,x_msg_data       => l_msg_data);

 END IF; */
-- End bug3052287

/* If the ordered_quantity_um has changed, force recalculation of quantity2
unless we have a no default process item where there is no
automatic calculation
==========================================================================*/
IF (NOT OE_GLOBALS.EQUAL(p_x_line_rec.order_quantity_uom
         			    ,p_old_line_rec.order_quantity_uom ))
  AND p_old_line_rec.order_quantity_uom is not NULL  -- OPM 24/OCT/00 B1458751
 -- AND l_item_rec.dualum_ind <> 3  -- INVCONV
  AND l_item_rec.secondary_default_ind <> 'N' -- INVCONV
 THEN
  p_x_line_rec.ordered_quantity2 := NULL;
END IF;

/* Has one of the two quantities changed */

IF (NOT OE_GLOBALS.EQUAL(p_x_line_rec.ordered_quantity
         			    ,p_old_line_rec.ordered_quantity )) OR
   (NOT OE_GLOBALS.EQUAL(p_x_line_rec.ordered_quantity2
         			    ,p_old_line_rec.ordered_quantity2)) OR
   (p_x_line_rec.ordered_quantity  IS NULL) OR
   (p_x_line_rec.ordered_quantity2 IS NULL) THEN

      IF l_debug_level  > 0 THEN
      	oe_debug_pub.add('Sync_dual_qty - change detected ',1);
      END IF;

 --  IF l_item_rec.dualum_ind in (0,3)  INVCONV
     IF (l_item_rec.secondary_default_ind = 'N' or
        l_item_rec.secondary_default_ind is null )
        --and ( p_x_line_rec.source_type_code  <> 'INTERNAL' )  -- INVCONV internal orders fix for PO reqs
        and NOT (nvl(p_x_line_rec.source_document_type_id,-99) = 10 ) -- INVCONV DEC 23

  		THEN

	/* NO UM Conversion required for types 3 so return here and not internal order line  -- INVCONV
	============================================================*/
	    IF l_debug_level  > 0 THEN
      	oe_debug_pub.add('Sync_dual_qty - default ind is N or null - early return ',1);
      END IF;

      RETURN;
    END IF;
ELSE
   /* No sync required
   ==================*/
   IF l_debug_level  > 0 THEN
      	oe_debug_pub.add('Sync_dual_qty - no change detected so no sync',1);
    END IF;

   RETURN;
END IF; -- IF (NOT OE_GLOBALS.EQUAL(p_x_line_rec.ordered_quantity

oe_debug_pub.add('Sync_dual_qty - here 1 ',1);

IF (NOT OE_GLOBALS.EQUAL(p_x_line_rec.ordered_quantity
         			    ,p_old_line_rec.ordered_quantity )) OR
				     p_x_line_rec.ordered_quantity2 IS NULL THEN
  /* Primary quantity has changed so recalculate secondary */

--  IF l_item_rec.dualum_ind = 2  INVCONV
    IF l_item_rec.secondary_default_ind  = 'D' and  -- INVCONV
    p_x_line_rec.ordered_quantity is NOT NULL AND
    p_x_line_rec.order_quantity_uom <> p_x_line_rec.ordered_quantity_uom2 AND -- B1390859
    /* Only do tolerance check if both quantities populated */
    p_x_line_rec.ordered_quantity2 is NOT NULL
    and   ( p_x_line_rec.ordered_quantity2 <> FND_API.G_MISS_NUM  and -- INVCONV for PO req
    NOT (nvl(p_x_line_rec.source_document_type_id,-99) = 10) )   -- INVCONV DEC 23 not for internal order line
     THEN

	  IF l_debug_level  > 0 THEN
	  	  oe_debug_pub.add('Check the deviation  ');
    END IF;



 /*   l_return := GMICVAL.dev_validation(l_item_rec.opm_item_id  INVCONV
                                      ,0
					             ,p_x_line_rec.ordered_quantity
					             ,l_OPM_UOM
					             ,p_x_line_rec.ordered_quantity2
                                      ,l_item_rec.opm_item_um2
					             ,0);    */
    -- if change is within of tolerance, no further action

     l_return := INV_CONVERT.Within_Deviation  -- INVCONV
                       ( p_organization_id   =>
                                 p_x_line_rec.ship_from_org_id
                       , p_inventory_item_id =>
                                 p_x_line_rec.inventory_item_id
                       , p_precision         => 5
                       , p_quantity          => abs(p_x_line_rec.ordered_quantity) -- 5128490
                       , p_uom_code1         => p_x_line_rec.order_quantity_uom
                       , p_quantity2         => abs(p_x_line_rec.ordered_quantity2) -- 5128490
                       , p_uom_code2         => l_item_rec.secondary_uom_code );
      IF l_return = 0
      	then
      	    IF l_debug_level  > 0 THEN
    	  			oe_debug_pub.add('Sync_dual_qty - tolerance error 1 ' ,1);
    			 END IF;

    			 l_buffer          := FND_MSG_PUB.GET(p_msg_index => FND_MSG_PUB.G_LAST, -- INVCONV
                                         p_encoded => 'F');
           oe_msg_pub.add_text(p_message_text => l_buffer);
           IF l_debug_level  > 0 THEN
              oe_debug_pub.add(l_buffer,1);
    			 END IF;
    			 RAISE fnd_api.g_exc_error;

   		else
      	IF l_debug_level  > 0 THEN
    	  		oe_debug_pub.add('Sync_dual_qty - No tolerance error so return ',1);
    		END IF;
     	RETURN;
     END IF; -- IF l_return = 0



  END IF;  --   IF l_item_rec.secondary_default_ind  = 'D'


  IF l_debug_level  > 0 THEN
  	oe_debug_pub.add('Sync_dual_qty  - uom conversion primary to secondary');
  END IF;

-- OPM June 2003 3011880 begin - when converting qtys, if the p_x_line_rec.ordered_quantity_uom2 is not available yet,
-- then convert the opm um2 to the apps um for the call to get_opm_converted_qty below which requires apps uoms
--

/*	 IF ( p_x_line_rec.ordered_quantity_uom2 is NULL  INVCONV
           or p_x_line_rec.ordered_quantity_uom2 = FND_API.G_MISS_CHAR )
	  THEN
      	-- convert 4 digit apps OPM codes to equivalent 3 byte APPS codes
      	-- Primary UM
      		GMI_Reservation_Util.Get_AppsUOM_from_OPMUOM
					 (p_OPM_UOM        => l_item_rec.opm_item_um2
					 ,x_Apps_UOM       => p_x_line_rec.ordered_quantity_uom2
					 ,x_return_status  => l_status
					 ,x_msg_count      => l_msg_count
					 ,x_msg_data       => l_msg_data);
		oe_debug_pub.add('OPM in sync_dual - Get_AppsUOM_from_OPMUOM returns dual UM of ' || p_x_line_rec.ordered_quantity_uom2);
  	END IF;   */

-- OPM June 2003 3011880 end



-- OPM 25/AUG/00 - use precision of 19,9 to match OPM processing
/*  l_converted_qty :=GMICUOM.uom_conversion
 	            (l_item_rec.opm_item_id,0
     	    	  ,p_x_line_rec.ordered_quantity
                 ,l_OPM_UOM
    	    	       ,l_item_rec.opm_item_um2,0);

-- Feb 2003 2683316 - changed the call to GMI uom_conversion above to get_opm_converted_qty
-- to resolve rounding issues

      l_converted_qty  := GMI_Reservation_Util.get_opm_converted_qty(
              p_apps_item_id    => p_x_line_rec.inventory_item_id,
              p_organization_id => p_x_line_rec.ship_from_org_id,
              p_apps_from_uom   => p_x_line_rec.order_quantity_uom,
              p_apps_to_uom     => p_x_line_rec.ordered_quantity_uom2,
              p_original_qty    => p_x_line_rec.ordered_quantity); */
    --start 8501046
      /*Bug#8947452 Modified the below condition so that the secondary
quantity gets calculated for the fixed items. */
   If(p_x_line_rec.ordered_quantity2 is NULL OR l_item_rec.secondary_default_ind = 'F') then
      l_converted_qty := INV_CONVERT.INV_UM_CONVERT(p_x_line_rec.inventory_item_id -- INVCONV
      																									, NULL
      																								 ,p_x_line_rec.SHIP_FROM_ORG_id -- invconv
                                                      ,5 --NULL
                                                      ,p_x_line_rec.ordered_quantity
                                                      ,p_x_line_rec.order_quantity_uom
                                                      ,l_item_rec.secondary_uom_code
                                                      ,NULL -- From uom name
                                                      ,NULL -- To uom name
                                                      );

      IF l_debug_level  > 0 THEN
      	oe_debug_pub.add('Sync_dual_qty - secondary qty after conversion is  '||l_converted_qty);
 			END IF;
-- Feb 2003 2683316 end

  IF (l_converted_qty < 0) THEN    -- OPM B1478461 Start
    raise UOM_CONVERSION_FAILED;
  END IF;                          -- OPM B1478461 End
  p_x_line_rec.ordered_quantity2 := l_converted_qty;      -- OPM 25/AUG/00

  end if;  --end 8501046


ELSIF (NOT OE_GLOBALS.EQUAL(p_x_line_rec.ordered_quantity2
         			        ,p_old_line_rec.ordered_quantity2 )) THEN
  /* Secondary quantity has changed so recalculate primary
  =======================================================*/


  -- IF l_item_rec.dualum_ind = 2 and p_x_line_rec.ordered_quantity2 is NOT NULL AND   -- INVCONV
     IF l_item_rec.secondary_default_ind  = 'D' and  -- INVCONV
    p_x_line_rec.ordered_quantity2 is NOT NULL AND
    p_x_line_rec.order_quantity_uom <> p_x_line_rec.ordered_quantity_uom2 AND -- B1390859
    p_x_line_rec.ordered_quantity is NOT NULL THEN
    /* Only do tolerance check if both quantities populated */

    -- if change is within of tolerance, no further action
    l_return := INV_CONVERT.Within_Deviation  -- INVCONV
                       ( p_organization_id   =>
                                 p_x_line_rec.ship_from_org_id
                       , p_inventory_item_id =>
                                 p_x_line_rec.inventory_item_id
                       , p_precision         => 5
                       , p_quantity          => abs(p_x_line_rec.ordered_quantity) -- 5128490
                       , p_uom_code1         => p_x_line_rec.order_quantity_uom
                       , p_quantity2         => abs(p_x_line_rec.ordered_quantity2)  -- 5128490
                       , p_uom_code2         => l_item_rec.secondary_uom_code );

      IF l_return = 0
      	then
       	   IF l_debug_level  > 0 THEN
    	  			oe_debug_pub.add('Sync_dual_qty - tolerance error 2' ,1);
    			 END IF;

    			 l_buffer          := FND_MSG_PUB.GET(p_msg_index => FND_MSG_PUB.G_LAST, -- INVCONV
                                         p_encoded => 'F');
           oe_msg_pub.add_text(p_message_text => l_buffer);
           IF l_debug_level  > 0 THEN
              oe_debug_pub.add(l_buffer,1);
    			 END IF;
    			 RAISE fnd_api.g_exc_error;


   		else
      	IF l_debug_level  > 0 THEN
    	  		oe_debug_pub.add('Sync_dual_qty - No tolerance error so return ',1);
    		END IF;
     	RETURN;
     END IF; -- IF l_return = 0



  /*  l_return := GMICVAL.dev_validation(l_item_rec.opm_item_id
                                      ,0
					             ,p_x_line_rec.ordered_quantity
					             ,l_OPM_UOM
					             ,p_x_line_rec.ordered_quantity2
                                      ,l_item_rec.opm_item_um2
					             ,0);
    -- if change is within tolerance, no further action
    --===================================================
    IF (l_return NOT in (-68, -69)) THEN
       RETURN;
    END IF;   */


  END IF; --  IF l_item_rec.secondary_default_ind  = 'D' and  -- INVCONV

  /* Convert secondary quantity to derive primary
  ==============================================*/

  -- OPM 25/AUG/00
  -- use l_converted_qty with precision of 19,9 to match OPM processing


-- Feb 2003 2683316 - changed the call to GMI uom_conversion above to get_opm_converted_qty
-- to resolve rounding issues

      /*l_converted_qty  := GMI_Reservation_Util.get_opm_converted_qty(  -- INVCONV
              p_apps_item_id    => p_x_line_rec.inventory_item_id,
              p_organization_id => p_x_line_rec.ship_from_org_id,
              p_apps_from_uom   => p_x_line_rec.ordered_quantity_uom2,
              p_apps_to_uom     => p_x_line_rec.order_quantity_uom ,
              p_original_qty    => p_x_line_rec.ordered_quantity2);  */
    /*Bug#8433348 - code below is not to reconvert the secondary to primary when
 * it exists and secondary is the
 *        change from null to non null value */

      IF l_item_rec.secondary_default_ind  = 'F' and
         OE_GLOBALS.EQUAL(p_x_line_rec.ordered_quantity2 ,NVL(p_old_line_rec.ordered_quantity2 ,p_x_line_rec.ordered_quantity2))
          and p_x_line_rec.ordered_quantity is not null THEN

          IF l_debug_level  > 0 THEN oe_debug_pub.add('Sync_dual_qty  - do not reconvert the secondary to primary when it exists and secondary is changed
from null to non null - early return');
                          END IF;
         return;
      END IF;
      -- end of Bug#8433348

       l_converted_qty := INV_CONVERT.INV_UM_CONVERT(p_x_line_rec.inventory_item_id -- INVCONV
       																								, NULL
       																								,p_x_line_rec.ship_from_org_id -- INVCONV
                                                      ,5 --NULL
                                                      ,p_x_line_rec.ordered_quantity2
                                                      ,l_item_rec.secondary_uom_code
                                                      ,p_x_line_rec.order_quantity_uom
                                                      ,NULL -- From uom name
                                                      ,NULL -- To uom name
                                                      );


  		IF (l_converted_qty < 0) THEN    -- OPM B1478461 Start
   	 		raise UOM_CONVERSION_FAILED;
  		END IF;                          -- OPM B1478461 End

      IF l_debug_level  > 0 THEN
      	oe_debug_pub.add(' Sync_dual_qty - primary qty after conversion is  '||l_converted_qty);
      END IF;

      p_x_line_rec.ordered_quantity := l_converted_qty;

END IF; -- IF (NOT OE_GLOBALS.EQUAL(p_x_line_rec.ordered_quantity


EXCEPTION

--OPM B1478461 Start
WHEN UOM_CONVERSION_FAILED THEN

     --   FND_MESSAGE.SET_NAME('GMI','IC_API_UOM_CONVERSION_ERROR');     -- INVCONV
     --
     -- OPM BEGIN - BUG 2586841 - Added if condition for the message tokens to mask FND errors (why?)
     --
    /* IF ( p_x_line_rec.ordered_item is NULL  OR
          p_x_line_rec.ordered_item = FND_API.G_MISS_CHAR) THEN
         FND_MESSAGE.SET_TOKEN('ITEM_NO',to_char(nvl(p_x_line_rec.inventory_item_id, 0)));
     END IF;       */ -- INVCONV
    FND_MESSAGE.SET_NAME('INV','INV_NO_CONVERSION_ERR'); -- INVCONV

     --
     -- OPM END - BUG 2586841
     --
     OE_MSG_PUB.Add;
     RAISE FND_API.G_EXC_ERROR;
--OPM B1478461 End

WHEN fnd_api.g_exc_error THEN -- INVCONV
      RAISE FND_API.G_EXC_ERROR;

WHEN OTHERS THEN
     IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
         OE_MSG_PUB.Add_Exc_Msg
         (     G_PKG_NAME         ,
             'Sync_Dual_Qty'
         );
     END IF;
        oe_debug_pub.add('Exception handling: others in Sync_Dual_Qty', 1);
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;


END Sync_Dual_Qty;

/*-----------------------------------------------------------
FUNCTION Calculate_Ordered_Quantity2
------------------------------------------------------------  -- INVCONV
--   comment out this as it will not be used in the converged inventory code  replaced by calculate_dual_quantity

FUNCTION Calculate_Ordered_Quantity2
(
   P_LINE_REC          IN OE_ORDER_PUB.Line_Rec_Type
)  RETURN NUMBER
IS

l_item_rec             OE_ORDER_CACHE.item_rec_type;
-- OPM 25/AUG/00 - add precision of 19,9
l_ordered_quantity2    NUMBER(19,9) := p_line_rec.ordered_quantity2;
l_OPM_UOM              VARCHAR2(4);
l_return               NUMBER;
l_status               VARCHAR2(1);
l_msg_count            NUMBER;
l_msg_data             VARCHAR2(2000);

BEGIN

oe_debug_pub.add('OPM Enter Calculate_Ordered_Quantity2');


-- If this is a process line, load the item details from cache
--==============================================================
IF oe_line_util.Process_Characteristics
  (p_line_rec.inventory_item_id,p_line_rec.ship_from_org_id,l_item_rec) THEN
   NULL;
ELSE
  RETURN p_line_rec.ordered_quantity2;
END IF;


-- Usually ordered_quantity2 is not calculated for items where
dualum_ind=3, but in a split scenario, the calc IS automated.
--============================================================
IF l_item_rec.dualum_ind in (1,2,3) THEN
  oe_debug_pub.add('OPM Dualum ind 3 is true');


 -- Feb 2003 2683316 - changed the call to GMI uom_conversion above to get_opm_converted_qty
-- to resolve rounding issues

      l_ordered_quantity2 := GMI_Reservation_Util.get_opm_converted_qty(
              p_apps_item_id    => p_line_rec.inventory_item_id,
              p_organization_id => p_line_rec.ship_from_org_id,
              p_apps_from_uom   => p_line_rec.order_quantity_uom ,
              p_apps_to_uom     => p_line_rec.ordered_quantity_uom2,
              p_original_qty    => p_line_rec.ordered_quantity);

      oe_debug_pub.add('OPM secondary in Calculate_Ordered_Quantity2 after new get_opm_converted_qty is  '||l_ordered_quantity2);

-- Feb 2003 2683316 end

ELSE
  l_ordered_quantity2 := NULL;
END IF;

  oe_debug_pub.add('OPM Return ordered_quantity2 set to '|| l_ordered_quantity2);
RETURN l_ordered_quantity2;

EXCEPTION

WHEN OTHERS THEN
     IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
         OE_MSG_PUB.Add_Exc_Msg
         (          G_PKG_NAME         ,
                    'Calculate Ordered Quantity2'
         );
     END IF;
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;


END Calculate_Ordered_Quantity2;
--   OPM 02/JUN/00 END of OPM added procedures

*/

/*-----------------------------------------------------------
PROCEDURE Pre_Attribute_Security
------------------------------------------------------------*/
PROCEDURE Pre_Attribute_Security
(   p_x_line_rec       IN OUT  NOCOPY OE_ORDER_PUB.Line_Rec_Type
,   p_old_line_rec        IN          OE_ORDER_PUB.Line_Rec_Type
,   p_index               IN          NUMBER
) IS
   l_return_status VARCHAR2(1);
   --Added for bug 13808309
   l_shipping_uom  VARCHAR2(3) := NULL;

   l_return_code           		NUMBER; -- INVCONV
   l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level; -- INVCONV
   l_qty number; -- INVCONV
   l_qty2 number; -- INVCONV
   l_ordered_qty number;  --nocopy impact changes
 BEGIN

	if l_debug_level > 0 then -- INVCONV
  		oe_debug_pub.add('Entering Pre_Attribute_Security - reserved_quantity = ' || p_x_line_rec.reserved_quantity );
  end if;

      -- Added this code for Splits
      -- Need to send the rounded QTY for line if the
      -- Operations is Create and Split_From_Line_Id is not null or
      -- Operation is Update and action is split
      -- Bug #3705273
   IF (NVL(p_x_line_rec.shipping_quantity_uom,p_x_line_rec.order_quantity_uom)
         = p_x_line_rec.order_quantity_uom) THEN  -- added 13808309

      IF (p_x_line_rec.split_action_code = 'SPLIT'
         AND p_x_line_rec.operation = oe_globals.g_opr_update
         )
      OR (p_x_line_rec.split_from_line_id is not null
         AND p_x_line_rec.split_from_line_id <> fnd_api.g_miss_num
         AND p_x_line_rec.operation = oe_globals.g_opr_create
         )
      THEN

      --In case of create operation, line has shipping quantity uom 13808309
         IF p_x_line_rec.split_from_line_id is not null then
         --bug 6196000
           begin
           select shipping_quantity_uom INTO l_shipping_uom
             from oe_order_lines_all
            where line_id = p_x_line_rec.split_from_line_id;
	   exception
	   when no_data_found then
	    oe_debug_pub.add('setting the uom to null');
	    l_shipping_uom:=null;
	   end;
         --bug 6196000
         END IF;
        IF l_shipping_uom is null then  --13808309

        --Then you need to call the Quantity rounding API to round off the qty on the line
        l_ordered_qty :=  p_x_line_rec.ordered_quantity;  --nocopy impact changes
	OE_Validate_Line.Validate_Decimal_Quantity
  	(p_item_id	    => p_x_line_rec.inventory_item_id
	,p_item_type_code   => p_x_line_rec.item_type_code
	,p_input_quantity   => l_ordered_qty                                      --nocopy impact changes
	,p_uom_code         => p_x_line_rec.order_quantity_uom
        ,p_ato_line_id      => p_x_line_rec.ato_line_id
        ,p_line_id          => p_x_line_rec.line_id
        ,p_line_num         => p_x_line_rec.line_number
	,p_action_split     => 'Y'
        ,x_output_quantity  => p_x_line_rec.ordered_quantity
	,x_return_status    => l_return_status);

	IF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;-- ship uom is null
      END IF ;
      END IF ; -- same UOM condition
      oe_debug_pub.add('PAS 2 Qty :'||p_x_line_rec.ordered_quantity);

      -- Populate Set Ids IF Set Names are given
      -- This will harcode the defaulting for schduling attributes
      -- THis is kept outside defaulting framework to handle cases
      -- Asd Default_attributes = FALSE
      -- Another call is for create time in defaulint to cover line_id

      -- As part of scheduling restructure. dependency will added with
      -- bug 2164440.
      --4504362 : Branch Scheduling check removed.
     -- OPM 02/JUN/00
	   oe_line_util.Sync_Dual_Qty (p_x_line_rec => p_x_line_rec
							 ,p_old_line_rec => p_old_line_rec);
     -- OPM 02/JUN/00 END
-- INVCONV
 -- check this - why call here ??  need to know where to call in proper place - ask OM team

 --oe_debug_pub.add('reserved_quantity = ' || p_x_line_rec.reserved_quantity );
-- oe_debug_pub.add('reserved_quantity2 = ' || p_x_line_rec.reserved_quantity2 );
             IF NOT(OE_GLOBALS.G_UI_FLAG) and -- 4958890
               p_x_line_rec.ordered_quantity <> FND_API.G_MISS_NUM And
                       p_x_line_rec.ordered_quantity IS NOT NULL and
                       p_x_line_rec.ordered_quantity2 <> FND_API.G_MISS_NUM And
                       p_x_line_rec.ordered_quantity2 IS NOT NULL and
                       p_x_line_rec.ordered_quantity_uom2 is not null  and
                       p_x_line_rec.ordered_quantity_uom2 <> FND_API.G_MISS_CHAR and
                      (  (  p_x_line_rec.reserved_quantity <> FND_API.G_MISS_NUM And
                       p_x_line_rec.reserved_quantity IS NOT NULL )
                      or (  p_x_line_rec.reserved_quantity2 <> FND_API.G_MISS_NUM And
                       p_x_line_rec.reserved_quantity2 IS NOT NULL ) )
                       Then

 		        							IF p_x_line_rec.reserved_quantity <> FND_API.G_MISS_NUM And
                            p_x_line_rec.reserved_quantity IS NOT NULL then
                               l_qty := p_x_line_rec.reserved_quantity;

                        	end if;
                        	IF p_x_line_rec.reserved_quantity2 <> FND_API.G_MISS_NUM And
                            p_x_line_rec.reserved_quantity2 IS NOT NULL then
                               l_qty2 := p_x_line_rec.reserved_quantity2;

                        	end if;


 					  							if l_debug_level > 0 then -- INVCONV
                						oe_debug_pub.add('pre_attribute_security - about to call calculate_dual_quantity. l_qty = ' || l_qty);
                						oe_debug_pub.add('pre_attribute_security - about to call calculate_dual_quantity. l_qty2 = ' || l_qty2);
                        	end if;
                        IF l_qty <>0 or
                           l_qty2 <> 0
                        then
		 										oe_line_util.calculate_dual_quantity(
                         p_ordered_quantity => l_qty
                        ,p_old_ordered_quantity => NULL
                        ,p_ordered_quantity2 => l_qty2 -- p_x_line_rec.reserved_quantity2
                        ,p_old_ordered_quantity2 => NULL
                        ,p_ordered_quantity_uom  => p_x_line_rec.order_quantity_uom
                        ,p_ordered_quantity_uom2 => p_x_line_rec.ordered_quantity_uom2
                        ,p_inventory_item_id     => p_x_line_rec.inventory_item_id
                        ,p_ship_from_org_id      => p_x_line_rec.ship_from_org_id
                        ,x_ui_flag 		 => 0
                        ,x_return_status         => l_return_code
                        );


                        IF l_return_code <> 0 THEN -- INVCONV
	     										 IF l_return_status = -1  or
	     										    l_return_status = -99999
	     										 THEN
															p_x_line_rec.return_status := FND_API.G_RET_STS_ERROR;
															RAISE FND_API.G_EXC_ERROR;
														else
															p_x_line_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
															RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

														END IF;

												ELSE
												  p_x_line_rec.reserved_quantity2 := l_qty2;
												  p_x_line_rec.reserved_quantity := l_qty;

												END IF; --  IF l_return_code <> 0 THEN -- INVCONV


      									IF l_debug_level  > 0 THEN
       	  								oe_debug_pub.add('Pre_Attribute_Security after call to calculate_dual_quantity for reserved_quantities - return status = : ' || l_return_code);
													oe_debug_pub.add('reserved_quantity =  : ' || p_x_line_rec.reserved_quantity);
													oe_debug_pub.add('reserved_quantity2 = : ' || p_x_line_rec.reserved_quantity2);

   											END IF;

   											END IF;  -- IF l_qty <>0 then

    			END IF; -- INVCONV



END Pre_Attribute_Security;


/*---------------------------------------------------------------------
Procedure Log_CTO_Requests

This procedure is added only because code in pre_write is
getting cluttered and there are many CTO chg order
related requests which we will have in one place.
We need to notify CTO
1) for changes to ato model/options if config item exists.
2) for ato item if it is scheduled.(both item_type = standard and option)
3) in case of pto+ato, if new option is created and
   even 1 config item exist.
----------------------------------------------------------------------*/
PROCEDURE Log_CTO_Requests
(p_x_line_rec    IN OUT NOCOPY  OE_Order_PUB.Line_Rec_Type
,p_old_line_rec  IN             OE_Order_PUB.Line_Rec_Type :=
                                   OE_Order_PUB.G_MISS_LINE_REC
,x_return_status OUT NOCOPY /* file.sql.39 change */ VARCHAR2)
IS
  l_num                   NUMBER;
  l_flag                  BOOLEAN;
  l_notify_cto            BOOLEAN;
  l_ato_item_qty_change   BOOLEAN;
  l_pto_ato_create        BOOLEAN;
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN
 if l_debug_level > 0 then
  oe_debug_pub.add('entering Log_CTO_Requests', 1);
 end if;

  l_flag := FALSE;

  IF p_x_line_rec.ato_line_id is not NULL AND
     ((p_x_line_rec.schedule_status_code is NULL AND
       p_x_line_rec.operation = 'CREATE' ) OR
      (p_x_line_rec.schedule_ship_date is NOT NULL)) AND
     ((nvl(p_x_line_rec.split_action_code, 'X') <> 'SPLIT' OR
      (p_x_line_rec.split_action_code = FND_API.G_MISS_CHAR AND
       NOT (p_x_line_rec.split_from_line_id is NOT NULL))) OR
      OE_Code_Control.Code_Release_Level >= '110510')
  THEN

   if l_debug_level > 0 then
    oe_debug_pub.add('configuration scheduled', 5);
   end if;

    IF OE_Code_Control.Code_release_Level < '110510' THEN

      BEGIN
        SELECT line_id
        INTO   l_num
        FROM   oe_order_lines
        WHERE  ato_line_id = p_x_line_rec.ato_line_id
        AND    top_model_line_id = p_x_line_rec.top_model_line_id
        AND    item_type_code = OE_GLOBALS.G_ITEM_CONFIG;

        l_flag := TRUE;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
         if l_debug_level > 0 then
          oe_debug_pub.add('config item not yet created', 2);
         end if;
      END;
    ELSE
      l_flag := TRUE;
    END IF;
  ELSE
  if l_debug_level > 0 then
   oe_debug_pub.add('flag is false', 2);
  end if;
  END IF;

  l_ato_item_qty_change := FALSE;

  IF p_x_line_rec.ato_line_id = p_x_line_rec.line_id AND
     (p_x_line_rec.item_type_code = OE_GLOBALS.G_ITEM_STANDARD OR
      p_x_line_rec.item_type_code = OE_GLOBALS.G_ITEM_OPTION OR --##1820608
      p_x_line_rec.item_type_code = OE_GLOBALS.G_ITEM_INCLUDED) AND --9775352
     p_old_line_rec.schedule_status_code is NOT NULL AND
     p_x_line_rec.operation <> OE_GLOBALS.G_OPR_CREATE
  THEN
    if l_debug_level > 0 then
     oe_debug_pub.add('ato item, may need to notify cto', 4);
    end if;
     l_flag := TRUE;

     IF p_x_line_rec.ordered_quantity = 0 AND
        p_x_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE THEN

       if l_debug_level > 0 then
        oe_debug_pub.add('ato item qty made to 0'|| p_x_line_rec.open_flag, 4);
       end if;
        l_ato_item_qty_change := TRUE;

     END IF;

  END IF;

 if l_debug_level > 0 then
  oe_debug_pub.add('split?     : ' || p_x_line_rec.split_action_code, 3);
  oe_debug_pub.add('split from : ' || p_x_line_rec.split_from_line_id, 3);
  oe_debug_pub.add('line id:     ' || p_x_line_rec.line_id, 3);
  oe_debug_pub.add('ato line id: ' || p_x_line_rec.ato_line_id , 3);
  oe_debug_pub.add('item type:   ' || p_x_line_rec.item_type_code, 3);
  oe_debug_pub.add('operation:   ' || p_x_line_rec.operation, 3);
  oe_debug_pub.add('old qty:     ' || p_old_line_rec.ordered_quantity, 3);
  oe_debug_pub.add('new qty:     ' || p_x_line_rec.ordered_quantity, 3);
  oe_debug_pub.add('old ssd:     ' || p_old_line_rec.schedule_ship_date, 3);
  oe_debug_pub.add('new ssd:     ' || p_x_line_rec.schedule_ship_date, 3);
  oe_debug_pub.add('old rd:      ' || p_old_line_rec.request_date, 3);
  oe_debug_pub.add('new rd:      ' || p_x_line_rec.request_date, 3);
  oe_debug_pub.add('old sad:     ' || p_old_line_rec.schedule_arrival_date,3);
  oe_debug_pub.add('new sad:     ' || p_x_line_rec.schedule_arrival_date,3);
  oe_debug_pub.add('new sch sts: ' || p_x_line_rec.schedule_status_code,3);
  oe_debug_pub.add('old sch sts: ' || p_old_line_rec.schedule_status_code,3);
  oe_debug_pub.add('open flag:   ' || p_x_line_rec.open_flag,3);
  oe_debug_pub.add('cascade:     ' || oe_config_util.CASCADE_CHANGES_FLAG, 3);
  oe_debug_pub.add('validate:    ' || OE_CONFIG_PVT.OECFG_VALIDATE_CONFIG, 3);
  oe_debug_pub.add('ui:          ' || OE_CONFIG_UTIL.G_CONFIG_UI_USED, 3);

  oe_debug_pub.add('old qty2:     ' || p_old_line_rec.ordered_quantity2, 3); -- INVCONV
  oe_debug_pub.add('new qty2:     ' || p_x_line_rec.ordered_quantity2, 3);
  oe_debug_pub.add('old uom2:     ' || p_old_line_rec.ordered_quantity_uom2, 3); -- INVCONV
  oe_debug_pub.add('new uom2:     ' || p_x_line_rec.ordered_quantity_uom2, 3);
  oe_debug_pub.add('old uom:     ' || p_old_line_rec.order_quantity_uom, 3); -- INVCONV
  oe_debug_pub.add('new uom:     ' || p_x_line_rec.order_quantity_uom, 3);


  oe_debug_pub.add('ssd old' ||
  to_char (new_time (p_old_line_rec.schedule_ship_date, 'PST', 'EST'),
                                 'DD-MON-YY HH24:MI:SS'), 3);
  oe_debug_pub.add('ssd new' ||
  to_char (new_time (p_x_line_rec.schedule_ship_date, 'PST', 'EST'),
                                 'DD-MON-YY HH24:MI:SS'), 3);
 end if;

  l_notify_cto := FALSE;

  -- only for ATO models and ATO under PTO, all are oprn = update

  IF p_x_line_rec.ato_line_id = p_x_line_rec.line_id AND
     l_flag AND
     NOT (p_x_line_rec.split_from_line_id IS NOT NULL  AND
          p_x_line_rec.split_from_line_id <> FND_API.G_MISS_NUM AND
          p_x_line_rec.operation = 'CREATE') THEN

   if l_debug_level > 0 then
    oe_debug_pub.add('compare for ato model now', 3);
   end if;

    IF NOT OE_GLOBALS.Equal(p_x_line_rec.ship_from_org_id,
                           p_old_line_rec.ship_from_org_id) THEN

     if l_debug_level > 0 then
      oe_debug_pub.add('cto_change logged for warehouse change', 3);
     end if;
      l_notify_cto := TRUE;

      OE_delayed_requests_Pvt.log_request
      (p_entity_code            => OE_GLOBALS.G_ENTITY_LINE, --Bug 14375128
       p_entity_id              => p_x_line_rec.line_id,
       p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
       p_requesting_entity_id   => p_x_line_rec.line_id,
       p_request_type           => OE_GLOBALS.G_CTO_CHANGE,
       p_request_unique_key1    => 'Warehouse',
       p_param1                 => p_old_line_rec.ship_from_org_id,
       p_param2                 => p_x_line_rec.ship_from_org_id,
       p_param3                 => p_x_line_rec.ato_line_id,
       x_return_status          => x_return_status);

    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_line_rec.ordered_quantity,
                            p_old_line_rec.ordered_quantity) THEN

     if l_debug_level > 0 then
      oe_debug_pub.add('cto_change logged for qty change', 3);
     end if;

      l_notify_cto := TRUE;

      OE_delayed_requests_Pvt.log_request
      (p_entity_code            => OE_GLOBALS.G_ENTITY_LINE, --Bug 14375128
       p_entity_id              => p_x_line_rec.line_id,
       p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
       p_requesting_entity_id   => p_x_line_rec.line_id,
       p_request_type           => OE_GLOBALS.G_CTO_CHANGE,
       p_request_unique_key1    => 'Quantity',
       p_param1                 => p_old_line_rec.ordered_quantity,
       p_param2                 => p_x_line_rec.ordered_quantity,
       p_param3                 => p_x_line_rec.ato_line_id,
       x_return_status          => x_return_status);

    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_line_rec.request_date,
                            p_old_line_rec.request_date) THEN

     if l_debug_level > 0 then
      oe_debug_pub.add('cto_change logged for req date change', 3);
     end if;
      l_notify_cto := TRUE;

       OE_delayed_requests_Pvt.log_request
       (p_entity_code            => OE_GLOBALS.G_ENTITY_LINE, --Bug 14375128
        p_entity_id              => p_x_line_rec.line_id,
        p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
        p_requesting_entity_id   => p_x_line_rec.line_id,
        p_request_type           => OE_GLOBALS.G_CTO_CHANGE,
        p_request_unique_key1    => 'Req Date',
        p_param1                 => p_old_line_rec.request_date,
        p_param2                 => p_x_line_rec.request_date,
        p_param3                 => p_x_line_rec.ato_line_id,
        x_return_status          => x_return_status);

    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_line_rec.schedule_ship_date,
                            p_old_line_rec.schedule_ship_date) AND
       NOT l_ato_item_qty_change
    THEN

     if l_debug_level > 0 then
      oe_debug_pub.add('cto_change logged for sch ship date change', 3);
     end if;
      l_notify_cto := TRUE;

      OE_delayed_requests_Pvt.log_request
       (p_entity_code            => OE_GLOBALS.G_ENTITY_LINE, --Bug 14375128
        p_entity_id              => p_x_line_rec.line_id,
        p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
        p_requesting_entity_id   => p_x_line_rec.line_id,
        p_request_type           => OE_GLOBALS.G_CTO_CHANGE,
        p_request_unique_key1    => 'Ship Date',
        p_param1                 => p_old_line_rec.schedule_ship_date,
        p_param2                 => p_x_line_rec.schedule_ship_date,
        p_param3                 => p_x_line_rec.ato_line_id,
        x_return_status          => x_return_status);

    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_line_rec.schedule_arrival_date,
                            p_old_line_rec.schedule_arrival_date) AND
       NOT l_ato_item_qty_change THEN

     if l_debug_level > 0 then
      oe_debug_pub.add('cto_change logged for sch arr date change', 3);
     end if;
      l_notify_cto := TRUE;

      OE_delayed_requests_Pvt.log_request
       (p_entity_code            => OE_GLOBALS.G_ENTITY_LINE, --Bug 14375128
        p_entity_id              => p_x_line_rec.line_id,
        p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
        p_requesting_entity_id   => p_x_line_rec.line_id,
        p_request_type           => OE_GLOBALS.G_CTO_CHANGE,
        p_request_unique_key1    => 'Arr Date',
        p_param1                 => p_old_line_rec.schedule_arrival_date,
        p_param2                 => p_x_line_rec.schedule_arrival_date,
        p_param3                 => p_x_line_rec.ato_line_id,
        x_return_status          => x_return_status);

    END IF;

   -- INVCONV

     IF NOT OE_GLOBALS.Equal(p_x_line_rec.ordered_quantity2,
                            p_old_line_rec.ordered_quantity2) THEN

     if l_debug_level > 0 then
      oe_debug_pub.add('cto_change logged for qty2 change', 3);
     end if;

      l_notify_cto := TRUE;

      OE_delayed_requests_Pvt.log_request
      (p_entity_code            => OE_GLOBALS.G_ENTITY_LINE, --Bug 14375128
       p_entity_id              => p_x_line_rec.line_id,
       p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
       p_requesting_entity_id   => p_x_line_rec.line_id,
       p_request_type           => OE_GLOBALS.G_CTO_CHANGE,
       p_request_unique_key1    => 'Quantity2',
       p_param1                 => p_old_line_rec.ordered_quantity2,
       p_param2                 => p_x_line_rec.ordered_quantity2,
       p_param3                 => p_x_line_rec.ato_line_id,
       x_return_status          => x_return_status);

    END IF;

		IF NOT OE_GLOBALS.Equal(p_x_line_rec.ordered_quantity_uom2,
                            p_old_line_rec.ordered_quantity_uom2) THEN

     if l_debug_level > 0 then
      oe_debug_pub.add('cto_change logged for Uom2 change', 3);
     end if;

      l_notify_cto := TRUE;

      OE_delayed_requests_Pvt.log_request
      (p_entity_code            => OE_GLOBALS.G_ENTITY_LINE, --Bug 14375128
       p_entity_id              => p_x_line_rec.line_id,
       p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
       p_requesting_entity_id   => p_x_line_rec.line_id,
       p_request_type           => OE_GLOBALS.G_CTO_CHANGE,
       p_request_unique_key1    => 'Uom2',
       p_param1                 => p_old_line_rec.ordered_quantity_uom2,
       p_param2                 => p_x_line_rec.ordered_quantity_uom2,
       p_param3                 => p_x_line_rec.ato_line_id,
       x_return_status          => x_return_status);

    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_line_rec.order_quantity_uom,
                            p_old_line_rec.order_quantity_uom) THEN

     if l_debug_level > 0 then
      oe_debug_pub.add('cto_change logged for Uom change', 3);
     end if;

      l_notify_cto := TRUE;

      OE_delayed_requests_Pvt.log_request
      (p_entity_code            => OE_GLOBALS.G_ENTITY_LINE, --Bug 14375128
       p_entity_id              => p_x_line_rec.line_id,
       p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
       p_requesting_entity_id   => p_x_line_rec.line_id,
       p_request_type           => OE_GLOBALS.G_CTO_CHANGE,
       p_request_unique_key1    => 'Uom',
       p_param1                 => p_old_line_rec.order_quantity_uom,
       p_param2                 => p_x_line_rec.order_quantity_uom,
       p_param3                 => p_x_line_rec.ato_line_id,
       x_return_status          => x_return_status);

    END IF;
-- INVCONV END


  ELSIF p_x_line_rec.ato_line_id = p_x_line_rec.line_id AND
        OE_Code_Control.Code_Release_Level >= '110510' AND
        p_x_line_rec.schedule_status_code is NULL AND
        p_x_line_rec.schedule_ship_date is NULL AND
        p_old_line_rec.schedule_ship_date is NOT NULL THEN

   if l_debug_level > 0 then
    oe_debug_pub.add('cto_change logged for unschedule', 3);
   end if;

    l_notify_cto := TRUE;

    OE_delayed_requests_Pvt.log_request
     (p_entity_code            => OE_GLOBALS.G_ENTITY_LINE, --Bug 14375128
      p_entity_id              => p_x_line_rec.line_id,
      p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
      p_requesting_entity_id   => p_x_line_rec.line_id,
      p_request_type           => OE_GLOBALS.G_CTO_CHANGE,
      p_request_unique_key1    => 'Ship Date',
      p_param1                 => p_old_line_rec.schedule_ship_date,
      p_param2                 => p_x_line_rec.schedule_ship_date,
      p_param3                 => p_x_line_rec.ato_line_id,
      x_return_status          => x_return_status);

  END IF; -- update on model line logged

  IF p_x_line_rec.ato_line_id is NOT NULL AND
     p_x_line_rec.ato_line_id <> p_x_line_rec.line_id AND
     p_x_line_rec.item_type_code <> OE_GLOBALS.G_ITEM_CONFIG AND
     ((oe_config_util.CASCADE_CHANGES_FLAG = 'N' AND
       OE_CONFIG_PVT.OECFG_VALIDATE_CONFIG = 'Y') OR
       OE_CONFIG_UTIL.G_CONFIG_UI_USED = 'Y') AND
     l_flag AND
     nvl(p_x_line_rec.split_action_code, 'X') <> 'SPLIT' AND -- split update
     NOT (p_x_line_rec.split_from_line_id is NOT NULL AND
          p_x_line_rec.operation = OE_GLOBALS.G_OPR_CREATE) -- split create
  THEN
   if l_debug_level > 0 then
    oe_debug_pub.add('part of ato', 3);
   end if;

    l_pto_ato_create := FALSE;

    BEGIN
      SELECT 1
      INTO   l_num
      FROM   oe_order_lines
      WHERE  line_id = p_x_line_rec.top_model_line_id
      AND    top_model_line_id = nvl(ato_line_id, -1);

    EXCEPTION
      WHEN NO_DATA_FOUND THEN

        IF p_x_line_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN
         if l_debug_level > 0 then
          oe_debug_pub.add('pto top model and opr create', 1);
         end if;
          l_pto_ato_create := TRUE;
        END IF;
    END;


    IF (p_x_line_rec.operation = OE_GLOBALS.G_OPR_CREATE AND
        NOT l_pto_ato_create) OR
       p_x_line_rec.operation = OE_GLOBALS.G_OPR_DELETE OR
       (p_x_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE AND
        NOT OE_GLOBALS.Equal(p_x_line_rec.ordered_quantity,
                             p_old_line_rec.ordered_quantity))

    THEN

     if l_debug_level > 0 then
      oe_debug_pub.add('cto_change logged for config change', 3);
     end if;

      l_notify_cto := TRUE;

      OE_delayed_requests_Pvt.log_request
      (p_entity_code            => OE_GLOBALS.G_ENTITY_LINE, --Bug 14375128
       p_entity_id              => p_x_line_rec.ato_line_id,
       p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
       p_requesting_entity_id   => p_x_line_rec.line_id,
       p_request_type           => OE_GLOBALS.G_CTO_CHANGE,
       p_request_unique_key1    => 'Config Chg',
       p_param3                 => p_x_line_rec.ato_line_id,
       x_return_status          => x_return_status);

      IF p_x_line_rec.operation <> OE_GLOBALS.G_OPR_DELETE AND
         OE_Code_Control.Code_Release_Level >= '110510' THEN

       if l_debug_level > 0 then
        oe_debug_pub.add('cto_change logged for decimal change', 3);
       end if;

        OE_delayed_requests_Pvt.log_request
        (p_entity_code            => OE_GLOBALS.G_ENTITY_LINE, --Bug 14375128
         p_entity_id              => p_x_line_rec.line_id,
         p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
         p_requesting_entity_id   => p_x_line_rec.line_id,
         p_request_type           => OE_GLOBALS.G_CTO_CHANGE,
         p_request_unique_key1    => 'Decimal Chg',
         p_param1                 => p_x_line_rec.operation,
         p_param3                 => p_x_line_rec.ato_line_id,
         p_param4                 => p_x_line_rec.ordered_quantity,
         p_param5                 => p_old_line_rec.ordered_quantity,
         p_param6                 => p_x_line_rec.inventory_item_id,
         x_return_status          => x_return_status);
      END IF;

    END IF;
  ELSE
   if l_debug_level > 0 then
    oe_debug_pub.add('no need to log here', 3);
   end if;
  END IF;

  l_num := 0;

  IF p_x_line_rec.split_from_line_id is NOT NULL AND
     p_x_line_rec.operation = 'CREATE' AND
     OE_Code_Control.Code_Release_Level >= '110510' THEN

    IF p_x_line_rec.ato_line_id = p_x_line_rec.line_id AND
      (p_x_line_rec.item_type_code = OE_GLOBALS.G_ITEM_MODEL OR
       p_x_line_rec.item_type_code = OE_GLOBALS.G_ITEM_STANDARD OR
       p_x_line_rec.item_type_code = OE_GLOBALS.G_ITEM_OPTION)THEN
       l_num := 1;
    END IF;

    IF p_x_line_rec.ato_line_id is NOT NULL AND
       p_x_line_rec.item_type_code = 'CLASS' THEN

      BEGIN
        SELECT 1
        INTO   l_num
        FROM   oe_order_lines
        WHERE  line_id = p_x_line_rec.split_from_line_id
        AND    ato_line_id = line_id
        AND    item_type_code = 'CLASS';

      EXCEPTION
        when no_data_found then
         if l_debug_level > 0 then
          oe_debug_pub.add('was not a ato model', 3);
         end if;
      END;
    END IF;

    IF l_num = 1 THEN
     if l_debug_level > 0 then
      oe_debug_pub.add('new split ato model '|| p_x_line_rec.line_id, 3);
     end if;

      OE_delayed_requests_Pvt.log_request
      (p_entity_code            => OE_GLOBALS.G_ENTITY_LINE, --Bug 14375128
       p_entity_id              => p_x_line_rec.ato_line_id,
       p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
       p_requesting_entity_id   => p_x_line_rec.line_id,
       p_request_type           => OE_GLOBALS.G_CTO_CHANGE,
       p_request_unique_key1    => 'Split Create',
       p_param3                 => p_x_line_rec.split_from_line_id,
       p_param4                 => p_x_line_rec.line_id,
       x_return_status          => x_return_status);
    END IF;

  END IF;

  IF l_notify_cto THEN

   if l_debug_level > 0 then
    oe_debug_pub.add('notify_cto logged', 3);
   end if;

    OE_delayed_requests_Pvt.log_request
    (p_entity_code            => OE_GLOBALS.G_ENTITY_LINE, --Bug 14375128
     p_entity_id              => p_x_line_rec.ato_line_id,
     p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
     p_requesting_entity_id   => p_x_line_rec.ato_line_id,
     p_request_type           => OE_GLOBALS.G_CTO_NOTIFICATION,
     x_return_status          => x_return_status);
  END IF;


  -- for a pto-ato create case
  -- as per bug 1650811, we call cto for any new create if 1 config exists.
  -- now ato_line_id is set indefaulting, but may be incorrect
  -- for a class line till validate config

  l_flag := FALSE;
  IF l_pto_ato_create AND    --6873069
     ((p_x_line_rec.schedule_status_code is NULL AND
       p_x_line_rec.operation = 'CREATE' ) OR
      (p_x_line_rec.schedule_ship_date is NOT NULL)) THEN

    IF OE_Code_Control.Code_Release_Level < '110510' THEN
      BEGIN
        SELECT line_id
        INTO   l_num
        FROM   oe_order_lines
        WHERE  top_model_line_id = p_x_line_rec.top_model_line_id
        AND    item_type_code = OE_GLOBALS.G_ITEM_CONFIG;

        l_flag := TRUE;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
         if l_debug_level > 0 then
          oe_debug_pub.add('config item not yet created', 2);
         end if;
        WHEN TOO_MANY_ROWS THEN
         if l_debug_level > 0 then
          oe_debug_pub.add('many config items', 2);
         end if;
          l_flag := TRUE;
      END;
    ELSE
      l_flag := TRUE;
    END IF;
  ELSE
   if l_debug_level > 0 then
    oe_debug_pub.add('not pto/ato config create, flag false', 2);
   end if;
  END IF;


  IF l_flag THEN
   if l_debug_level > 0 then
    oe_debug_pub.add('pto ato and config exist'|| p_x_line_rec.line_id, 2);
   end if;

    OE_delayed_requests_Pvt.log_request
    (p_entity_code            => OE_GLOBALS.G_ENTITY_LINE, --Bug 14375128
     p_entity_id              => p_x_line_rec.line_id,
     p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
     p_requesting_entity_id   => p_x_line_rec.line_id,
     p_request_type           => OE_GLOBALS.G_CTO_CHANGE,
     p_request_unique_key1    => 'Config Chg pto_ato',
     p_param3                 => p_x_line_rec.top_model_line_id,
     p_param2                 => 'Y',
     p_param4                 => p_x_line_rec.line_id,
     p_param5                 => p_x_line_rec.ato_line_id,
     x_return_status          => x_return_status);

    OE_delayed_requests_Pvt.log_request
    (p_entity_code            => OE_GLOBALS.G_ENTITY_LINE, --Bug 14375128
     p_entity_id              => p_x_line_rec.top_model_line_id,
     p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
     p_requesting_entity_id   => p_x_line_rec.top_model_line_id,
     p_request_type           => OE_GLOBALS.G_CTO_NOTIFICATION,
     x_return_status          => x_return_status);

  END IF;

 if l_debug_level > 0 then
  oe_debug_pub.add('leaving Log_CTO_Requests', 1);
 end if;
EXCEPTION
  WHEN OTHERS THEN
   if l_debug_level > 0 then
    oe_debug_pub.add('exception in Log_CTO_Requests'|| sqlerrm, 1);
   end if;
    RAISE;
END Log_CTO_Requests;


/*---------------------------------------------------------------------
Procedure Log_Config_Requests

This procedure is added only because code in pre_write is
getting cluttered and there are many Configurations
related requests which we will have in one place.

requests logged.
1) validate configuration.
     Log the delayed request to Validate the Configuration
     if an option or class is deleted.
     no need not consider split in case of deletes.

     Log the delayed request to Validate the Configuration
     if an option or class is updated or created or model
     is created.

2) copy configuration.
     Log a copy config request if model/kit is proportionally split.

Change Record:
bug 2075105: the delete_option request will be looged against
top model line with request_unique_key of line_id.
----------------------------------------------------------------------*/

PROCEDURE Log_Config_Requests
(p_x_line_rec    IN OUT NOCOPY  OE_Order_PUB.Line_Rec_Type
,p_old_line_rec  IN             OE_Order_PUB.Line_Rec_Type :=
                                   OE_Order_PUB.G_MISS_LINE_REC
,x_return_status OUT NOCOPY /* file.sql.39 change */ VARCHAR2)
IS
  l_flag                  BOOLEAN;
  l_cancellation          VARCHAR2(1);
  l_config_header_id      NUMBER;
  l_config_rev_nbr        NUMBER;
  l_configuration_id      NUMBER;
  l_model_open_flag       VARCHAR2(1) := 'Y';
  l_fulfilled_flag        VARCHAR2(1) := 'N';
  l_model_item            VARCHAR2(2000);
  l_config_rev_change     VARCHAR2(1) := 'N';
  l_ord_item              VARCHAR2(2000);
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN
 if l_debug_level > 0 then
  oe_debug_pub.add('entering Log_Config_Requests', 1);
 end if;


  ------------------------ copy for model split -------------

  IF p_x_line_rec.top_model_line_id = p_x_line_rec.line_id AND
    p_x_line_rec.operation = OE_GLOBALS.G_OPR_CREATE AND
    p_x_line_rec.split_from_line_id is not null  -- split
  THEN

   if l_debug_level > 0 then
    oe_debug_pub.add
    ('split_from_line_id: '|| p_x_line_rec.split_from_line_id, 1);
    oe_debug_pub.add('new model: '|| p_x_line_rec.line_id, 1);
   end if;

    BEGIN
      SELECT config_header_id, config_rev_nbr, configuration_id
      INTO   l_config_header_id,l_config_rev_nbr, l_configuration_id
      FROM   oe_order_lines
      WHERE  line_id = p_x_line_rec.split_from_line_id;
    EXCEPTION
      WHEN no_data_found THEN
       if l_debug_level > 0 then
        oe_debug_pub.add('Parent model is not validated', 1);
       end if;
        -- should we raise exception??
    END;

   if l_debug_level > 0 then
    oe_debug_pub.add('Logging a request after spllit
                      to copy the configuration in SPC', 1);
   end if;
    OE_Delayed_Requests_Pvt.Log_Request(
               p_entity_code             =>   OE_GLOBALS.G_ENTITY_LINE,
               p_entity_id               =>   p_x_line_rec.line_id,
               p_requesting_entity_code  =>   OE_GLOBALS.G_ENTITY_LINE,
               p_requesting_entity_id    =>   p_x_line_rec.line_id,
               p_request_type            =>   OE_GLOBALS.G_COPY_CONFIGURATION,
               p_param1                  =>   l_config_header_id,
               p_param2                  =>   l_config_rev_nbr,
               p_param3                  =>   p_x_line_rec.model_remnant_flag,
               p_param4                  =>   l_configuration_id,
               x_return_status           =>   x_return_status);

  END IF;

  if l_debug_level > 0 then
   oe_debug_pub.add('after copy config request ', 3);
  end if;

  -------------------------- copy config done -----------------------


  IF nvl(p_x_line_rec.model_remnant_flag, 'N') = 'Y'  THEN
   if l_debug_level > 0 then
    oe_debug_pub.add('returning from log_config as remnant', 1);
   end if;
    RETURN;
  END IF;

  IF p_x_line_rec.line_id <> p_x_line_rec.top_model_line_id THEN
    SELECT open_flag, ordered_item, fulfilled_flag
    INTO   l_model_open_flag, l_model_item, l_fulfilled_flag
    FROM   oe_order_lines
    WHERE  line_id = p_x_line_rec.top_model_line_id;
  END IF;

  ---------------------- deletes ----------------------------------

  IF(p_x_line_rec.item_type_code = OE_GLOBALS.G_ITEM_OPTION OR
     p_x_line_rec.item_type_code = OE_GLOBALS.G_ITEM_CLASS OR
    (p_x_line_rec.item_type_code = OE_GLOBALS.G_ITEM_KIT AND
     p_x_line_rec.line_id <> p_x_line_rec.top_model_line_id)) AND
     p_x_line_rec.operation = OE_GLOBALS.G_OPR_DELETE AND
     OE_CONFIG_PVT.OECFG_VALIDATE_CONFIG = 'Y' THEN

     IF l_model_open_flag = 'N' THEN
       FND_MESSAGE.Set_Name('ONT', 'OE_CONFIG_MODEL_CLOSED');
       FND_MESSAGE.Set_Token('MODEL', l_model_item);
       OE_MSG_PUB.Add;
      if l_debug_level > 0 then
       oe_debug_pub.add('model line is closed', 1);
      end if;
       RAISE FND_API.G_EXC_ERROR;
     END IF;

     IF l_fulfilled_flag  = 'Y' THEN
       FND_MESSAGE.Set_Name('ONT', 'OE_CONFIG_MODEL_FULFILLED');
       FND_MESSAGE.Set_Token('MODEL', l_model_item);
       OE_MSG_PUB.Add;
      if l_debug_level > 0 then
       oe_debug_pub.add('model line is fulfilled', 1);
      end if;
       RAISE FND_API.G_EXC_ERROR;
     END IF;

    if l_debug_level > 0 then
     oe_debug_pub.add('Logging a request to validate configuration  ', 1);
    end if;

     OE_delayed_requests_Pvt.log_request(
            p_entity_code            => OE_GLOBALS.G_ENTITY_LINE,
            p_entity_id              => p_x_line_rec.top_model_line_id,
            p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
            p_requesting_entity_id   => p_x_line_rec.line_id,
            p_request_type           => OE_GLOBALS.G_VALIDATE_CONFIGURATION,
            x_return_status          => x_return_status);

    if l_debug_level > 0 then
     oe_debug_pub.add('Logging a request to delete option from oe/spc', 1);
    end if;

     OE_Delayed_Requests_Pvt.Log_Request(
            p_entity_code             =>   OE_GLOBALS.G_ENTITY_LINE,
            p_entity_id               =>   p_x_line_rec.top_model_line_id,
            p_requesting_entity_code  =>   OE_GLOBALS.G_ENTITY_LINE,
            p_requesting_entity_id    =>   p_x_line_rec.line_id,
            p_request_unique_key1     =>   p_x_line_rec.line_id,
            p_request_type            =>   OE_GLOBALS.G_DELETE_OPTION,
            p_param1                  =>   p_x_line_rec.top_model_line_id,
            p_param2                  =>   p_x_line_rec.component_code,
            p_param3                  =>   p_x_line_rec.item_type_code,
            p_param9                  =>   p_x_line_rec.configuration_id,
            p_param10                 =>   p_x_line_rec.ordered_item, -- 3563690
            x_return_status           =>   x_return_status);

  END IF;



  ---------------- update/create-------------------------------------

 if l_debug_level > 0 then
  oe_debug_pub.add('item_type_code: '||p_x_line_rec.item_type_code, 1);
  oe_debug_pub.add('validate flag: '||OE_CONFIG_PVT.OECFG_VALIDATE_CONFIG, 1);
 end if;

  l_flag := FALSE;

  IF p_x_line_rec.item_type_code = OE_GLOBALS.G_ITEM_MODEL AND
     p_x_line_rec.operation = OE_GLOBALS.G_OPR_CREATE      AND
     p_x_line_rec.booked_flag = 'Y' THEN
    if l_debug_level > 0 then
     oe_debug_pub.add('setting flag to true for model', 1);
    end if;
     l_flag := TRUE;
  END IF;

  IF (p_x_line_rec.item_type_code = OE_GLOBALS.G_ITEM_OPTION OR
      p_x_line_rec.item_type_code = OE_GLOBALS.G_ITEM_CLASS OR
     (p_x_line_rec.item_type_code = OE_GLOBALS.G_ITEM_KIT AND
      p_x_line_rec.line_id <> p_x_line_rec.top_model_line_id)) AND
      NOT OE_GLOBALS.Equal(p_x_line_rec.ordered_quantity,
                           p_old_line_rec.ordered_quantity )
  THEN
   if l_debug_level > 0 then
    oe_debug_pub.add('set flag to true'|| p_old_line_rec.ordered_quantity, 1);
    oe_debug_pub.add('new qty ' || p_x_line_rec.ordered_quantity, 1);
   end if;
    l_flag := TRUE;
  END IF;

   IF  p_x_line_rec.line_id = p_x_line_rec.top_model_line_id AND
       NOT OE_GLOBALS.Equal(p_x_line_rec.config_rev_nbr,
                            p_old_line_rec.config_rev_nbr)
  THEN
   if l_debug_level > 0 then
    oe_debug_pub.add('set flag to true, old rev '|| p_old_line_rec.config_rev_nbr, 1);
    oe_debug_pub.add('new rev ' || p_x_line_rec.config_rev_nbr, 1);
   end if;
    l_config_rev_change := 'Y';
    l_flag := TRUE;
  END IF;

  IF l_flag AND OE_CONFIG_PVT.OECFG_VALIDATE_CONFIG = 'Y' THEN

    if l_debug_level > 0 then
     oe_debug_pub.add('p_x_line_rec.operation' || p_x_line_rec.operation, 1);
     oe_debug_pub.add
     ('Split_from_line_id: '||p_x_line_rec.split_from_line_id ,3);
     oe_debug_pub.add
     ('Split_action_code: '|| p_x_line_rec.split_action_code ,3);
    end if;


     -- in case of splits, we dont want to batch validate

     IF  p_x_line_rec.operation = OE_GLOBALS.G_OPR_CREATE AND
         p_x_line_rec.split_from_line_id is not null
     THEN
        if l_debug_level > 0 then
         oe_debug_pub.add('This is a new model after split', 1);
        end if;

     ELSIF p_x_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE AND
         nvl(p_x_line_rec.split_action_code, 'X') = 'SPLIT'
     THEN
        if l_debug_level > 0 then
         oe_debug_pub.add('This is a parent split model', 1);
        end if;

     ELSE
         -- If we got here, it means this isn't a split.
        if l_debug_level > 0 then
         oe_debug_pub.add('Logging a request to validate configuration',1);
        end if;

         IF l_model_open_flag = 'N' THEN
           FND_MESSAGE.Set_Name('ONT', 'OE_CONFIG_MODEL_CLOSED');
           FND_MESSAGE.Set_Token('MODEL', l_model_item);
           OE_MSG_PUB.Add;
          if l_debug_level > 0 then
           oe_debug_pub.add('model line is closed', 1);
          end if;
           RAISE FND_API.G_EXC_ERROR;
         END IF;

         IF l_fulfilled_flag  = 'Y' THEN
           FND_MESSAGE.Set_Name('ONT', 'OE_CONFIG_MODEL_FULFILLED');
           FND_MESSAGE.Set_Token('MODEL', l_model_item);
           OE_MSG_PUB.Add;
          if l_debug_level > 0 then
           oe_debug_pub.add('model line is fulfilled', 1);
          end if;
           RAISE FND_API.G_EXC_ERROR;
         END IF;

         -- 2917547 starts
         IF p_x_line_rec.operation = OE_GLOBALS.G_OPR_CREATE AND
            p_x_line_rec.ordered_quantity = 0 THEN

           IF p_x_line_rec.ordered_item IS NULL OR
              p_x_line_rec.ordered_item = fnd_api.g_miss_char THEN
             l_ord_item := p_x_line_rec.inventory_item_id;
           ELSE
             l_ord_item := p_x_line_rec.ordered_item;
           END IF;

           FND_MESSAGE.Set_Name('ONT', 'OE_ZERO_CHILD_QTY');
           FND_MESSAGE.Set_Token('ITEM', l_ord_item);
           OE_MSG_PUB.Add;

           IF l_debug_level > 0 THEN
             oe_debug_pub.add
             ('Child lines with zero qty can not be created', 1);
           END IF;
           RAISE FND_API.G_EXC_ERROR;
         END IF;

         OE_delayed_requests_Pvt.log_request(
            p_entity_code            => OE_GLOBALS.G_ENTITY_LINE,
            p_entity_id              => p_x_line_rec.top_model_line_id,
            p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
            p_requesting_entity_id   => p_x_line_rec.line_id,
            p_request_type           => OE_GLOBALS.G_VALIDATE_CONFIGURATION,
            x_return_status          => x_return_status);

         -- log only if operation is update and not for create
         IF p_x_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE AND
            l_config_rev_change = 'N' THEN

           if l_debug_level > 0 then
            oe_debug_pub.add('Logging a request to update configuration', 1);
           end if;

            l_cancellation := 'N';

            IF OE_Sales_Can_Util.G_Require_Reason THEN
             if l_debug_level > 0 then
              oe_debug_pub.add('this is a cancellation', 1);
             end if;
              l_cancellation := 'Y';
            ELSE
             if l_debug_level > 0 then
              oe_debug_pub.add('this is not a cancellation', 1);
             end if;
            END IF;

           if l_debug_level > 0 then
            oe_debug_pub.add
            (p_x_line_rec.item_type_code || p_x_line_rec.ordered_quantity, 1);
           end if;

            OE_Delayed_Requests_Pvt.Log_Request(
               p_entity_code             =>   OE_GLOBALS.G_ENTITY_LINE,
               p_entity_id               =>   p_x_line_rec.line_id,
               p_requesting_entity_code  =>   OE_GLOBALS.G_ENTITY_LINE,
               p_requesting_entity_id    =>   p_x_line_rec.line_id,
               p_request_type            =>   OE_GLOBALS.G_UPDATE_OPTION,
               p_param1                  =>   p_x_line_rec.top_model_line_id,
               p_param2                  =>   p_x_line_rec.component_code,
               p_param3                  =>   p_x_line_rec.item_type_code,
               p_param4                  =>   p_old_line_rec.ordered_quantity,
               p_param5                  =>   p_x_line_rec.ordered_quantity,
               p_param6                  =>   p_x_line_rec.change_reason,
               p_param7                  =>   p_x_line_rec.change_comments,
               p_param8                  =>   l_cancellation,
               p_param9                  =>   p_x_line_rec.configuration_id,
               x_return_status           =>   x_return_status);

         END IF; -- end of update.

      END IF;  -- end of split check.

  END IF;

 if l_debug_level > 0 then
  oe_debug_pub.add('leaving Log_Config_Requests', 1);
 end if;
EXCEPTION
  WHEN OTHERS THEN
   if l_debug_level > 0 then
    oe_debug_pub.add('exception in Log_Config_Requests'|| sqlerrm, 1);
   end if;
    RAISE;
END Log_Config_Requests;


/*----------------------------------------------------------------------
Procedure Log_Cascade_Requests


1) cascading.
     Log the delayed request to Cascade Changes if any of the cascading
     relevant attribute has changes on the model.

     only from the top model/ top kit
       ordered_quantity

     for top model / top kit / ato sub config
       project_id
       task_id
       ship_tolerance_above
       ship_tolerance_below

     for non smc pto top model / top kit
       ship_to_org_id
       request_date

     for top ato model only
       shipped_quantity
       actual_shipment_date (in ucfgb)

2) change configuration.
     change in warehouse of an ato model, smc pto, or ato subconfig
     cascade only if configuration was not scheduled.
     If it was scheduled, scheduling will take care of cascading.

     only for non scheduled lines which are part of
     top ato and ato subconfig / smc
       ship_to_org_id
       ship_from_org_id

     lines which are part of top ato and ato subconfig / smc
       request_date

3) modify included items.
     when a class/kit under a pto model, is odified, we need to modify
     the included items under it. We use a global table here to capture the
     old and new qty, operation, reason and commet. This table is used in the
     post_lines process to modify the included items. We did not use a delayed
     reuest because we need to capture the old and new qty per class and
     it needs 3 types of requests, ex: validate configuration req to do that.

----------------------------------------------------------------------*/

PROCEDURE Log_Cascade_Requests
(p_x_line_rec    IN OUT NOCOPY  OE_Order_PUB.Line_Rec_Type
,p_old_line_rec  IN             OE_Order_PUB.Line_Rec_Type :=
                                   OE_Order_PUB.G_MISS_LINE_REC
,x_return_status OUT NOCOPY /* file.sql.39 change */ VARCHAR2)
IS
  l_param1                VARCHAR2(2000):= FND_API.G_MISS_NUM;
  l_param2                VARCHAR2(240) := FND_API.G_MISS_NUM;
  l_param3                VARCHAR2(240) := null;
  l_param4                VARCHAR2(2000):= null;    --4495205
  l_param5                VARCHAR2(240) := FND_API.G_MISS_NUM;
  l_param6                VARCHAR2(240) := FND_API.G_MISS_NUM;
  l_param7                VARCHAR2(240) := FND_API.G_MISS_CHAR;
  l_param8                VARCHAR2(240) := FND_API.G_MISS_NUM;
  l_param9                VARCHAR2(240) := FND_API.G_MISS_NUM;
  l_param10               VARCHAR2(240) := null;
  l_param11               VARCHAR2(240) := FND_API.G_MISS_NUM;
  l_param12               VARCHAR2(240) := FND_API.G_MISS_NUM;
  l_param14               VARCHAR2(240) := FND_API.G_MISS_NUM;
/* Added the following variable to fix the bug 2217336 */
  l_param16               VARCHAR2(240) := FND_API.G_MISS_CHAR;
  l_date_param1           DATE          := FND_API.G_MISS_DATE;
  l_date_param2           DATE          := FND_API.G_MISS_DATE;
  l_num                   NUMBER;
  l_cancellation          VARCHAR2(1);
  l_cascade_changes       BOOLEAN := FALSE;
  l_change_configuration  BOOLEAN := FALSE;
  l_modify_included_items BOOLEAN := FALSE;
  l_return_status         VARCHAR2(1);
  l_entity_id             NUMBER;
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN
 if l_debug_level > 0 then
  oe_debug_pub.add('entering Log_Cascade_Requests', 1);
 end if;

  -------- cascading from parent to child only -------------


  IF OE_CONFIG_UTIL.G_CONFIG_UI_USED = 'N' AND
     OE_CONFIG_UTIL.CASCADE_CHANGES_FLAG = 'N'  AND
     p_x_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE AND
     nvl(p_x_line_rec.split_action_code, 'X') <> 'SPLIT'
  THEN
    -- 1. change in ordered qty of model/kit
    --    at subconfig cascade qty is actually in validate_config

    IF p_x_line_rec.top_model_line_id = p_x_line_rec.line_id
    THEN

      IF NOT OE_GLOBALS.Equal(p_x_line_rec.ordered_quantity,
                              p_old_line_rec.ordered_quantity) AND
         OE_Config_Util.G_Config_UI_Used = 'N'
      THEN
        l_param1 := p_old_line_rec.ordered_quantity;
        l_param2 := p_x_line_rec.ordered_quantity;
        l_param3 := p_x_line_rec.change_reason;
        l_param4 := p_x_line_rec.change_comments;

       if l_debug_level > 0 then
        oe_debug_pub.add('ordered qty of model/kit changed:' ||l_param2,1);
       end if;

        l_cascade_changes := TRUE;

      END IF;

    END IF;


    -- 2. change in project and task of model/ ato subconfig

    IF  p_x_line_rec.top_model_line_id = p_x_line_rec.line_id OR -- model/kit
       (p_x_line_rec.item_type_code = OE_GLOBALS.G_ITEM_CLASS AND
        p_x_line_rec.line_id = p_x_line_rec.ato_line_id) -- ato subconfig
    THEN

      IF NOT OE_GLOBALS.Equal(p_x_line_rec.project_id,
                              p_old_line_rec.project_id)
      THEN
        l_param5 := p_x_line_rec.project_id;
       if l_debug_level > 0 then
        oe_debug_pub.add('model/ATO sub,project_id changed: '||l_param5,1);
       end if;
        l_cascade_changes := TRUE;
      END IF;

      IF NOT OE_GLOBALS.Equal(p_x_line_rec.task_id,p_old_line_rec.task_id)
      THEN
        l_param6 := p_x_line_rec.task_id;
       if l_debug_level > 0 then
        oe_debug_pub.add('model /ATO sub,task_id changed: '||l_param6,1);
       end if;
        l_cascade_changes := TRUE;
      END IF;


      -- 3. cascade change in ship_tolerance_above and ship_tolerance_above
      -- at the model level to all the options.

      IF NOT OE_GLOBALS.Equal(p_x_line_rec.ship_tolerance_above,
                              p_old_line_rec.ship_tolerance_above)
      THEN
        l_param11 := p_x_line_rec.ship_tolerance_above;
        l_cascade_changes := TRUE;
      END IF;

      IF NOT OE_GLOBALS.Equal(p_x_line_rec.ship_tolerance_below,
                              p_old_line_rec.ship_tolerance_below)
      THEN
        l_param12 := p_x_line_rec.ship_tolerance_below;
        l_cascade_changes := TRUE;
      END IF;
    END IF;


    -- 4. cascade request_date and ship_to_org_id, this should be done
    --    only in case of nonsmc pto model/kit, rest is handled in
    --    change_configuration request.

    IF  p_x_line_rec.top_model_line_id = p_x_line_rec.line_id AND
        nvl(p_x_line_rec.ship_model_complete_flag, 'N') = 'N' AND
        p_x_line_rec.ato_line_id IS NULL
    THEN
      IF NOT OE_GLOBALS.Equal(p_x_line_rec.ship_to_org_id,
                              p_old_line_rec.ship_to_org_id)
      THEN
        l_param14 := p_x_line_rec.ship_to_org_id;
        l_cascade_changes := TRUE;
      END IF;

      IF NOT OE_GLOBALS.Equal(p_x_line_rec.request_date,
                              p_old_line_rec.request_date)
      THEN
        l_date_param1 := p_x_line_rec.request_date;
        l_cascade_changes := TRUE;
      END IF;

    END IF;


    -- 5. change in shipped qty of ato model, specifically for top most ato.

    IF  p_x_line_rec.item_type_code = OE_GLOBALS.G_ITEM_MODEL AND
        p_x_line_rec.ato_line_id IS NOT NULL
    THEN

      IF NOT OE_GLOBALS.Equal(p_x_line_rec.shipped_quantity,
                             p_old_line_rec.shipped_quantity)
      THEN
        l_param9  := to_char(p_x_line_rec.shipped_quantity);
       if l_debug_level > 0 then
        oe_debug_pub.add
        ('model / ATO subconfig, shipped quantity changed: '||l_param9,1);
       end if;

        l_cascade_changes := TRUE;
      END IF;

    END IF;


    -- 6. cascade source_type for ATO configurations.

    IF  p_x_line_rec.line_id = p_x_line_rec.ato_line_id AND
       (p_x_line_rec.item_type_code = OE_GLOBALS.G_ITEM_MODEL OR
        p_x_line_rec.item_type_code = OE_GLOBALS.G_ITEM_CLASS )
    THEN

      IF NOT OE_GLOBALS.Equal(p_x_line_rec.source_type_code,
                              p_old_line_rec.source_type_code)
      THEN
        l_param7 := p_x_line_rec.source_type_code;
       if l_debug_level > 0 then
        oe_debug_pub.add('ATO cascade source type '|| l_param7,1);
       end if;
        l_cascade_changes := TRUE;
      END IF;

    END IF;


    -- 7. Cascade change in freight_term_code
    --    added this code to fix the bug 2217336

    IF (  p_x_line_rec.item_type_code = OE_GLOBALS.G_ITEM_MODEL  OR
          p_x_line_rec.item_type_code = OE_GLOBALS.G_ITEM_KIT )
    THEN

      IF NOT OE_GLOBALS.Equal(p_x_line_rec.freight_terms_code,
                              p_old_line_rec.freight_terms_code)
      THEN
        l_param16  := p_x_line_rec.freight_terms_code;

       if l_debug_level > 0 then
        oe_debug_pub.add
        ('Freight term code changed: '||l_param16,1);
       end if;

        l_cascade_changes := TRUE;
      END IF;

    END IF;

     -- 8. Cascade change in promise date

    IF (  p_x_line_rec.item_type_code = OE_GLOBALS.G_ITEM_MODEL  OR
          p_x_line_rec.item_type_code = OE_GLOBALS.G_ITEM_KIT )
    THEN

      IF NOT OE_GLOBALS.Equal(p_x_line_rec.promise_date,
                              p_old_line_rec.promise_date)
      THEN
        l_date_param2  := p_x_line_rec.promise_date;

       if l_debug_level > 0 then
        oe_debug_pub.add('Promise date changed: '||l_date_param2,1);
       end if;

        l_cascade_changes := TRUE;
      END IF;

    END IF;


    -- log a request only if not a split

   if l_debug_level > 0 then
    oe_debug_pub.add
    ('CASCADE_CHANGES_FLAG, N means cascade : '
     ||OE_CONFIG_UTIL.CASCADE_CHANGES_FLAG, 1);
   end if;


    IF l_cascade_changes THEN
     if l_debug_level > 0 then
      oe_debug_pub.add('Logging Request to Cascade changes',1);
      oe_debug_pub.add('Item Type is: ' || p_x_line_rec.item_type_code,3);
      oe_debug_pub.add('Comp Code is: ' || p_x_line_rec.component_code,3);
     end if;

      l_cancellation := 'N';
      IF OE_Sales_Can_Util.G_Require_Reason THEN
       if l_debug_level > 0 then
        oe_debug_pub.add('this is a cancellation', 1);
       end if;
        l_cancellation := 'Y';
      END IF;

      OE_delayed_requests_Pvt.log_request(
        p_entity_code            => OE_GLOBALS.G_ENTITY_LINE,
        p_entity_id              => p_x_line_rec.line_id,
        p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
        p_requesting_entity_id   => p_x_line_rec.line_id,
        p_request_type           => OE_GLOBALS.G_CASCADE_CHANGES,
        p_param1                 => l_param1,   -- old old qty
        p_param2                 => l_param2,   -- new ord qty
        p_param3                 => l_param3,   -- chg reason
        p_param4                 => l_param4,   -- chg comment
        p_param5                 => l_param5,   -- proj id
        p_param6                 => l_param6,   -- task id
        p_param7                 => p_x_line_rec.item_type_code,
        p_param9                 => l_param9,   -- ship qty
        p_param10                => l_param10,  -- warehouse
        p_param11                => l_param11,  -- Ship tol above
        p_param12                => l_param12,  -- Ship tol below
        p_param13                => l_cancellation,
        p_param14                => l_param14,  -- ship to org id
        p_param15                => l_param7,   -- source_type_code
        p_param16                => l_param16,   -- Freight_terms_code
        p_date_param1            => l_date_param1, -- request date
        p_date_param2            => l_date_param2, -- promise date
        x_return_status          => l_return_status);

    END IF;

  END IF; -- if the globals are set.



   ------------ changing from any line to all lines -------------

 if l_debug_level > 0 then
  oe_debug_pub.add('change configuration requests', 3);
 end if;

   --6717302:
   -- 5932543 - do not call process order if the split is happening through
   -- ITS partial shipment. split_by=system
   -- 6678897 - comparision of split_action_code and split_by WITH NVL
   -- if not done so, following if condition will always fail and cascading
   -- changed field values to child item lines will fail.
   -- (warehous field for 6678897)

   IF  OE_GLOBALS.G_CHANGE_CFG_FLAG = 'Y' AND
      ((p_x_line_rec.ato_line_id is not null AND
        p_x_line_rec.item_type_code <> OE_GLOBALS.G_ITEM_STANDARD) OR
       (nvl(p_x_line_rec.ship_model_complete_flag,'N')='Y')) AND
        p_x_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE
        AND nvl(p_x_line_rec.split_action_code,'N') <> 'SPLIT' --6717302
        AND nvl(p_x_line_rec.split_by,'N') <> 'SYSTEM' --6717302
   THEN

     IF  p_x_line_rec.schedule_status_code is null THEN

       -- 1.
       IF NOT OE_GLOBALS.Equal(p_x_line_rec.SHIP_FROM_ORG_ID,
                             p_old_line_rec.SHIP_FROM_ORG_ID)
       THEN
         l_change_configuration := TRUE;
       END IF;

       -- 2.
       IF NOT OE_GLOBALS.Equal(p_x_line_rec.SHIP_TO_ORG_ID,
                             p_old_line_rec.SHIP_TO_ORG_ID)
       THEN
         l_change_configuration := TRUE;
       END IF;

     END IF;

     -- 3. note that this is logged even if scheduled.

     IF NOT OE_GLOBALS.Equal(p_x_line_rec.REQUEST_DATE,
                           p_old_line_rec.REQUEST_DATE) AND
        OE_CONFIG_UTIL.CASCADE_CHANGES_FLAG = 'N'
     THEN
        l_change_configuration := TRUE;
     END IF;

     IF NOT OE_GLOBALS.Equal(p_x_line_rec.SHIPPING_METHOD_CODE,
                           p_old_line_rec.SHIPPING_METHOD_CODE)
     THEN
        l_change_configuration := TRUE;
     END IF;

     IF NOT OE_GLOBALS.Equal(p_x_line_rec.SHIPMENT_PRIORITY_CODE,
                           p_old_line_rec.SHIPMENT_PRIORITY_CODE)
     THEN
        l_change_configuration := TRUE;
     END IF;

     IF NOT OE_GLOBALS.Equal(p_x_line_rec.DEMAND_CLASS_CODE,
                           p_old_line_rec.DEMAND_CLASS_CODE)
     THEN
        l_change_configuration := TRUE;
     END IF;


     IF l_change_configuration THEN

       IF (nvl(p_x_line_rec.ship_model_complete_flag,'N')='Y') THEN
          l_entity_id := p_x_line_rec.top_model_line_id;

       ELSIF  (p_x_line_rec.ato_line_id is not null ) THEN
          l_entity_id := p_x_line_rec.ato_line_id;

       END IF;

      if l_debug_level > 0 then
       oe_debug_pub.add('logging a req. to chg config', 1);
      end if;

       OE_Delayed_Requests_Pvt.Log_Request(
        p_entity_code             =>   OE_GLOBALS.G_ENTITY_LINE,
        p_entity_id               =>   l_entity_id,
        p_requesting_entity_code  =>   OE_GLOBALS.G_ENTITY_LINE,
        p_requesting_entity_id    =>   p_x_line_rec.line_id,
        p_request_type            =>   OE_GLOBALS.G_CHANGE_CONFIGURATION,
        p_param1                  =>   p_x_line_rec.line_id,
        x_return_status           =>   l_return_status);

     END IF;

   END IF;

   ------ cascading from class/kitclass to included items only ---------

   l_num := 0;

BEGIN
   SELECT 1
   INTO   l_num
   FROM   oe_order_lines
   WHERE  top_model_line_id = p_x_line_rec.top_model_line_id
   AND    link_to_line_id   = p_x_line_rec.line_id
   AND    item_type_code = OE_GLOBALS.G_ITEM_INCLUDED
   AND    rownum = 1;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
   if l_debug_level > 0 then
    oe_debug_pub.add('modify inc items requests NOT reqd', 3);
   end if;
    RETURN;
END;

 if l_debug_level > 0 then
  oe_debug_pub.add('modify inc items request reqd', 3);
 end if;

  -- Modified for bug 8636027
  -- l_num := p_x_line_rec.line_id;
  l_num := mod(p_x_line_rec.line_id, G_BINARY_LIMIT);

  IF NOT OE_Config_Pvt.OE_MODIFY_INC_ITEMS_TBL.EXISTS(l_num) THEN
    OE_Config_Pvt.OE_MODIFY_INC_ITEMS_TBL(l_num).param1
                  := FND_API.G_MISS_NUM;
    OE_Config_Pvt.OE_MODIFY_INC_ITEMS_TBL(l_num).param2
                  := FND_API.G_MISS_NUM;
    OE_Config_Pvt.OE_MODIFY_INC_ITEMS_TBL(l_num).param3 := null;
    OE_Config_Pvt.OE_MODIFY_INC_ITEMS_TBL(l_num).param4 := null;
    OE_Config_Pvt.OE_MODIFY_INC_ITEMS_TBL(l_num).param5
                  := FND_API.G_MISS_NUM;
    OE_Config_Pvt.OE_MODIFY_INC_ITEMS_TBL(l_num).param6
                  := FND_API.G_MISS_NUM;
    OE_Config_Pvt.OE_MODIFY_INC_ITEMS_TBL(l_num).param7
                  := FND_API.G_MISS_NUM;
    OE_Config_Pvt.OE_MODIFY_INC_ITEMS_TBL(l_num).param8
                  := FND_API.G_MISS_NUM;
    OE_Config_Pvt.OE_MODIFY_INC_ITEMS_TBL(l_num).param9
                  := FND_API.G_MISS_NUM;
    OE_Config_Pvt.OE_MODIFY_INC_ITEMS_TBL(l_num).date_param1
                  := FND_API.G_MISS_DATE;
  END IF;

  IF   p_x_line_rec.operation <> OE_GLOBALS.G_OPR_CREATE AND
       p_x_line_rec.ato_line_id is null AND
       p_x_line_rec.top_model_line_id <> p_x_line_rec.line_id AND
       (p_x_line_rec.item_type_code = OE_GLOBALS.G_ITEM_CLASS OR
        p_x_line_rec.item_type_code = OE_GLOBALS.G_ITEM_KIT) AND
	nvl(p_x_line_rec.split_action_code, 'X') <> 'SPLIT'  AND
        OE_CONFIG_UTIL.CASCADE_CHANGES_FLAG = 'N' -- not for  model change
  THEN
    if l_debug_level > 0 then
     oe_debug_pub.add('cascade class changes to included items', 1);
    end if;

     IF NOT OE_GLOBALS.Equal(p_x_line_rec.ordered_quantity,
                             p_old_line_rec.ordered_quantity) THEN

       IF OE_Config_Pvt.OE_MODIFY_INC_ITEMS_TBL(l_num).param1 =
          FND_API.G_MISS_NUM THEN
         OE_Config_Pvt.OE_MODIFY_INC_ITEMS_TBL(l_num).param1
                       := p_old_line_rec.ordered_quantity;
        if l_debug_level > 0 then
         oe_debug_pub.add('qty changed 1st time ' || l_param1, 4);
        end if;
       END IF;

       OE_Config_Pvt.OE_MODIFY_INC_ITEMS_TBL(l_num).param2
                       := p_x_line_rec.ordered_quantity;
       -- new qty

       OE_Config_Pvt.OE_MODIFY_INC_ITEMS_TBL(l_num).param3
                       := p_x_line_rec.change_reason;
       -- change_reason

       OE_Config_Pvt.OE_MODIFY_INC_ITEMS_TBL(l_num).param4
                       := p_x_line_rec.change_comments;
       --  change_comments

      if l_debug_level > 0 then
       oe_debug_pub.add
       ('ord qty of class changed:' || p_x_line_rec.ordered_quantity,1);
      end if;

       l_modify_included_items := TRUE;

     END IF;

     IF NOT OE_GLOBALS.Equal(p_x_line_rec.project_id,p_old_line_rec.project_id) THEN
      OE_Config_Pvt.OE_MODIFY_INC_ITEMS_TBL(l_num).param5
                       := p_x_line_rec.project_id;
     if l_debug_level > 0 then
      oe_debug_pub.add('model/ATO subconfig,project changed: '||l_param5,1);
     end if;
      l_modify_included_items := TRUE;
     END IF;


     IF NOT OE_GLOBALS.Equal(p_x_line_rec.task_id,p_old_line_rec.task_id)
     THEN
       OE_Config_Pvt.OE_MODIFY_INC_ITEMS_TBL(l_num).param6
                       := p_x_line_rec.task_id;
     if l_debug_level > 0 then
       oe_debug_pub.add('model /ATO subconfig,task changed: '||l_param6,1);
     end if;
       l_modify_included_items := TRUE;
     END IF;


     IF NOT OE_GLOBALS.Equal(p_x_line_rec.ship_tolerance_above,
                             p_old_line_rec.ship_tolerance_above)
      THEN
        OE_Config_Pvt.OE_MODIFY_INC_ITEMS_TBL(l_num).param7
                       := p_x_line_rec.ship_tolerance_above;
        l_modify_included_items := TRUE;
      END IF;

      IF NOT OE_GLOBALS.Equal(p_x_line_rec.ship_tolerance_below,
                              p_old_line_rec.ship_tolerance_below)
      THEN
         OE_Config_Pvt.OE_MODIFY_INC_ITEMS_TBL(l_num).param8
                       := p_x_line_rec.ship_tolerance_below;
         l_modify_included_items := TRUE;
      END IF;

      IF OE_GLOBALS.G_CHANGE_CFG_FLAG = 'Y' THEN
        IF NOT OE_GLOBALS.Equal(p_x_line_rec.ship_to_org_id,
                                p_old_line_rec.ship_to_org_id)
        THEN
           OE_Config_Pvt.OE_MODIFY_INC_ITEMS_TBL(l_num).param9
                       := p_x_line_rec.ship_to_org_id;
           l_modify_included_items := TRUE;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_line_rec.request_date,
                              p_old_line_rec.request_date)
        THEN
           OE_Config_Pvt.OE_MODIFY_INC_ITEMS_TBL(l_num).date_param1
                       := p_x_line_rec.request_date;
           l_modify_included_items := TRUE;
        END IF;
      END IF;

      IF p_x_line_rec.operation = OE_GLOBALS.G_OPR_DELETE THEN
        l_modify_included_items := TRUE;
      END IF;

   END IF;


   IF l_modify_included_items THEN
    if l_debug_level > 0 then
     oe_debug_pub.add('something changed'|| p_x_line_rec.operation, 2);
    end if;

     OE_Config_Pvt.OE_MODIFY_INC_ITEMS_TBL(l_num).param10 :=
                      p_x_line_rec.operation;

     IF OE_Sales_Can_Util.G_Require_Reason THEN
       OE_Config_Pvt.OE_MODIFY_INC_ITEMS_TBL(l_num).param11 := 'Y';
     ELSE
       OE_Config_Pvt.OE_MODIFY_INC_ITEMS_TBL(l_num).param11 := 'N';
     END IF;

     OE_Config_Pvt.OE_MODIFY_INC_ITEMS_TBL(l_num).param12 :=
                    p_x_line_rec.line_id;

     OE_Config_Pvt.OE_MODIFY_INC_ITEMS_TBL(l_num).param13 :=
                    p_x_line_rec.top_model_line_id;
   END IF;

  x_return_status := l_return_status;

 if l_debug_level > 0 then
  oe_debug_pub.add('leaving Log_Config_Requests', 1);
 end if;
EXCEPTION
  WHEN OTHERS THEN
   if l_debug_level > 0 then
    oe_debug_pub.add('exception in Log_Cascade_Requests'|| sqlerrm, 1);
   end if;
    RAISE;
END Log_Cascade_Requests;



/*-----------------------------------------------------------
PROCEDURE get_customer_details
------------------------------------------------------------*/

PROCEDURE get_customer_details
(   p_org_id                IN  NUMBER
,   p_site_use_code         IN  VARCHAR2
,   x_customer_name         OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_customer_number       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_customer_id           OUT NOCOPY /* file.sql.39 change */ number
,   x_location              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_address1              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_address2              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_address3              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_address4              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_city                  OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_state                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_zip                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_country               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)

IS
BEGIN

    IF p_org_id is NOT NULL THEN

        SELECT  /*MOAC_SQL_CHANGES*/ cust.cust_account_id,
                party.party_name,
                cust.account_number,
                site.location,
                addr.address1,
                addr.address2,
                addr.address3,
                addr.address4,
                addr.city,
                nvl(addr.state,addr.province), -- 3603600
	        addr.postal_code,
	        addr.country
        INTO    x_customer_id,
                x_customer_name,
                x_customer_number,
                x_location,
	        x_address1,
	        x_address2,
	        x_address3,
	        x_address4,
	        x_city,
                x_state,
                x_zip,
                x_country
        FROM    HZ_CUST_SITE_USES_ALL site,
                HZ_CUST_ACCT_SITES cas,
                hz_cust_accounts cust,
                hz_parties party,
                hz_party_sites ps,
                hz_locations addr
        WHERE   site.cust_acct_site_id=cas.cust_acct_site_id
        AND     site.site_use_code=p_site_use_code
        AND     site.site_use_id=p_org_id
        AND     cust.cust_account_id = cas.cust_account_id
        AND     cas.party_site_id = ps.party_site_id
        AND     ps.location_id = addr.location_id
        AND     party.party_id = cust.party_id;

    ELSE

        x_customer_name    :=  NULL    ;
        x_customer_number  :=  NULL    ;
        x_customer_id      :=  NULL    ;
        x_location         :=  NULL;
        x_address1         := nULL;
        x_address2         := nULL;
        x_address3         := nULL;
        x_address4         := nULL;
        x_city             := nULL;
        x_state            := nULL;
        x_zip              := nULL;
        x_country          := nULL;

    END IF;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','get_customer_details');
            OE_MSG_PUB.Add;

        END IF;


    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
          ,   'get_customer_details'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END get_customer_details;


/*-----------------------------------------------------------
PROCEDURE Log_Scheduling_Requests
------------------------------------------------------------*/

PROCEDURE Log_Scheduling_Requests
(p_x_line_rec    IN  OUT NOCOPY OE_Order_PUB.Line_Rec_Type
,p_old_line_rec  IN  OE_Order_PUB.Line_Rec_Type
,p_caller        IN  VARCHAR2
,p_order_type_id IN  NUMBER
,x_return_status OUT NOCOPY /* file.sql.39 change */ VARCHAR2)
IS
l_count NUMBER;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

if l_debug_level > 0 then
 oe_debug_pub.add('Entering Log_Scheduling_Requests',1);
 oe_debug_pub.add('p_caller' || p_caller,1);
end if;
  IF NOT OE_GLOBALS.Equal(p_x_line_rec.schedule_ship_date,
                          p_old_line_rec.schedule_ship_date)
  THEN
    if l_debug_level > 0 then
     oe_debug_pub.add('Schedule shipdate  is changed',1);
    end if;

/* 7576948: Commented for IR ISO CMS Project

     IF p_x_line_rec.order_source_id = 10 AND
        p_old_line_rec.schedule_ship_date IS NOT NULL
     THEN

        FND_MESSAGE.SET_NAME('ONT','OE_CHG_CORR_REQ');
        -- { start fix for 2648277
	FND_MESSAGE.SET_TOKEN('CHG_ATTR',
            OE_Order_Util.Get_Attribute_Name('schedule_ship_date'));
        -- end fix for 2648277}
        OE_MSG_PUB.Add;

     END IF;

*/ -- COmmented for IR ISO CMS Project

       -- Bug 12355310 : Replacing check on SI flag by new API
       --IF	p_x_line_rec.shipping_interfaced_flag = 'Y'
       IF (p_x_line_rec.shipping_interfaced_flag = 'Y' OR
          (p_x_line_rec.shippable_flag = 'Y' AND p_x_line_rec.booked_flag = 'Y'
           AND Shipping_Interfaced_Status(p_x_line_rec.line_id) = 'Y'))
       AND p_x_line_rec.ordered_quantity > 0  THEN

    -- Fix for bug 2347447
       if l_debug_level > 0 then
        oe_debug_pub.ADD('Update Shipping : logging delayed request for '
                                || to_char(p_x_line_rec.line_id) ,1);
       end if;

		OE_Delayed_Requests_Pvt.Log_Request(
		p_entity_code				=>	OE_GLOBALS.G_ENTITY_LINE,
		p_entity_id					=>	p_x_line_rec.line_id,
		p_requesting_entity_code	=>	OE_GLOBALS.G_ENTITY_LINE,
		p_requesting_entity_id  	=>	p_x_line_rec.line_id,
		p_request_type				=>	OE_GLOBALS.G_UPDATE_SHIPPING,
		p_request_unique_key1		=>  OE_GLOBALS.G_OPR_UPDATE,
		p_param1             		=>	FND_API.G_TRUE,
		x_return_status				=>	x_return_status);

	END IF;
  END IF;

   -- End of apply attributes.
   -- Begin Pre write.

   -- Start AuditTrail

   IF  OE_GLOBALS.G_AUDIT_REASON_RQD_FLAG = 'Y'
   AND ( p_x_line_rec.change_reason IS NULL OR
         p_x_line_rec.change_reason = FND_API.G_MISS_CHAR)
   THEN

      -- bug 3636884, defaulting reason from group API
      IF OE_GLOBALS.G_DEFAULT_REASON THEN
        if l_debug_level > 0 then
         oe_debug_pub.add('Defaulting Audit Reason for Order Line', 1);
        end if;
         p_x_line_rec.change_reason := 'SYSTEM';
      ELSE
        if l_debug_level > 0 then
         oe_debug_pub.add('Audit Required Reason missing - error', 1);
        end if;
         fnd_message.set_name('ONT','OE_AUDIT_REASON_RQD');
         fnd_message.set_token('OBJECT','ORDER LINE');
         oe_msg_pub.add;
         RAISE FND_API.G_EXC_ERROR;
      END IF;

   END IF;


 -- If we move scheduling call to post write.
  IF p_caller = 'EXTERNAL' THEN

    IF ((p_x_line_rec.top_model_line_id is NOT NULL OR
        p_x_line_rec.ato_line_id is NOT NULL)) AND
        p_x_line_rec.item_type_code <> OE_GLOBALS.G_ITEM_CONFIG
    THEN
     if l_debug_level > 0 then
      oe_debug_pub.add('Before logging Log_CTO_Requests', 1);
     end if;
      Log_CTO_Requests( p_x_line_rec    => p_x_line_rec
                       ,p_old_line_rec  => p_old_line_rec
                       ,x_return_status => x_return_status);
    END IF;


  END IF; -- External
--bug  3988559 modify sfadnavi  BEGIN

 if l_debug_level > 0 then
  oe_debug_pub.add('Before calling Version_Audit_Process',1);
 end if;

--Adding code to log versioning/audit request
OE_Line_Util.Version_Audit_Process(p_x_line_rec => p_x_line_rec,
                        p_old_line_rec => p_old_line_rec);

--bug 3988559 modify sfadnavi  END



 if l_debug_level > 0 then
  oe_debug_pub.add('Exiting Log_Scheduling_Requests',1);
 end if;


END Log_Scheduling_Requests;

/* LG. May 03 changed all the calls to GMI uom_conversion to get_opm_converted_qty
 * to resolved rounding issues
 */

 PROCEDURE calculate_dual_quantity
(
   p_ordered_quantity       IN OUT NOCOPY /* file.sql.39 change */ NUMBER
  ,p_old_ordered_quantity   IN NUMBER
  ,p_ordered_quantity2      IN OUT NOCOPY /* file.sql.39 change */ NUMBER
  ,p_old_ordered_quantity2  IN NUMBER
  ,p_ordered_quantity_uom   IN VARCHAR2
  ,p_ordered_quantity_uom2  IN VARCHAR2
  ,p_inventory_item_id      IN NUMBER
  ,p_ship_from_org_id       IN NUMBER
  ,x_ui_flag	            IN NUMBER
  ,x_return_status	    OUT NOCOPY /* file.sql.39 change */ NUMBER
 -- ,p_lot_id                 IN  NUMBER DEFAULT 0 -- OPM 2380194 added for RMA quantity2 OM pack J project
	,p_lot_number             IN  VARCHAR2 DEFAULT NULL -- INVCONV for 2380194 added for RMA quantity2 OM pack J project
)

IS

l_converted_qty        NUMBER(19,9);
l_item_rec             OE_ORDER_CACHE.item_rec_type;
--l_OPM_UOM              VARCHAR2(4);  -- INVCONV
l_error_message        VARCHAR2(1000); -- INVCONV
l_debug_level  CONSTANT NUMBER := oe_debug_pub.g_debug_level; -- INVCONV
l_return               NUMBER;
l_status               VARCHAR2(1);
l_return_status        VARCHAR2(30);
l_msg_count            NUMBER;
-- l_msg_data             VARCHAR2(2000); INVCONV
l_buffer                  VARCHAR2(2000); -- INVCONV
UOM_CONVERSION_FAILED  EXCEPTION;             -- INVCONV
TOLERANCE_ERROR EXCEPTION;             -- INVCONV

BEGIN



-- First of all, if this procedure is called from a source other then UI

IF l_debug_level  > 0 THEN
	oe_debug_pub.add ('Enter Calculate_dual_quantity');
	oe_debug_pub.add ('p_ordered_quantity = ' || p_ordered_quantity );
	oe_debug_pub.add ('p_old_ordered_quantity = ' || p_old_ordered_quantity );
	oe_debug_pub.add ('p_ordered_quantity2 = ' || p_ordered_quantity2 );
	oe_debug_pub.add ('p_old_ordered_quantity2 = ' || p_old_ordered_quantity2 );
	oe_debug_pub.add ('p_ordered_quantity_uom = ' || p_ordered_quantity_uom );
	oe_debug_pub.add ('p_ordered_quantity_uom2 = ' || p_ordered_quantity_uom2 );
	oe_debug_pub.add ('p_inventory_item_id = ' || p_inventory_item_id );
	oe_debug_pub.add ('p_ship_from_org_id = ' || p_ship_from_org_id );
	oe_debug_pub.add ('p_lot_number = ' || p_lot_number );
  oe_debug_pub.add ('x_ui_flag = ' || x_ui_flag );
END IF;

-- First of all, if this procedure is called from a source other then UI
/* If neither quantity is present, no calculation is required
======================================================*/

IF p_ordered_quantity2 = fnd_api.g_miss_num THEN
   p_ordered_quantity2 := 0;
   IF l_debug_level  > 0 THEN
	oe_debug_pub.add('Calculate_dual_quantity - p_ordered_quantity2 = fnd_api.g_miss_num' );
   END IF;

END IF;

IF( X_UI_FLAG = 1 ) THEN
  IF (p_ordered_quantity IS NULL OR
    p_ordered_quantity = FND_API.G_MISS_NUM ) AND
   (p_ordered_quantity2 IS NULL OR
    p_ordered_quantity2 = FND_API.G_MISS_NUM ) THEN
    IF l_debug_level  > 0 THEN
    		oe_debug_pub.add ('Calculate_dual_quantity - both quantities empty so early return');
    END IF;
    RETURN;
   END IF;
END IF; -- IF( X_UI_FLAG = 1 ) THEN

/* If this is a dual uom control line, load the item details from cache
==============================================================*/
IF dual_uom_control
  (p_inventory_item_id,p_ship_from_org_id,l_item_rec) THEN
  -- IF l_item_rec.dualum_ind not in (1,2,3) THEN -- INVCONV
  IF l_item_rec.tracking_quantity_ind <> 'PS' then -- INVCONV

    p_ordered_quantity2 := NULL;
    RETURN;
  END IF;
ELSE
  p_ordered_quantity2 := NULL;
  RETURN;
END IF;

IF l_debug_level  > 0 THEN
	oe_debug_pub.add('Calculate_dual_quantity secondary_default_ind is ' || l_item_rec.secondary_default_ind);
END IF;

IF ( X_UI_FLAG = 0 ) THEN
   IF (NVL(p_ordered_quantity2,0) = 0
      OR l_item_rec.secondary_default_ind  = 'F' ) -- INVCONV
     THEN

      	IF l_debug_level  > 0 THEN
      			oe_debug_pub.add('Calculate_dual_quantity : quantity2 is null OR is type F - so calculate it');
      	END IF;

           /* p_ordered_quantity2 := GMI_Reservation_Util.get_opm_converted_qty( INVCONV
              p_apps_item_id    => p_inventory_item_id,
              p_organization_id => p_ship_from_org_id,
              p_apps_from_uom   => p_ordered_quantity_uom,
              p_apps_to_uom     => p_ordered_quantity_uom2,
              p_original_qty    => p_ordered_quantity,
              p_lot_id          => nvl(p_lot_id, 0) );  */-- OPM 2380194

			  l_converted_qty := INV_CONVERT.INV_UM_CONVERT(p_inventory_item_id -- INVCONV
			  																						  ,p_lot_number     -- INVCONV
			  																							,p_ship_from_org_id -- INVCONV
			  																						  ,5 --NULL
                                                      ,p_ordered_quantity
                                                      ,p_ordered_quantity_uom
                                                      ,p_ordered_quantity_uom2
                                                      ,NULL -- From uom name
                                                      ,NULL -- To uom name
                                                      );
       IF (l_converted_qty < 0) THEN    -- INVCONV
              raise UOM_CONVERSION_FAILED;
       END IF;
        p_ordered_quantity2 :=       l_converted_qty; -- INVCONV
      	IF l_debug_level  > 0 THEN
      			oe_debug_pub.add('Calculate_dual_quantity : calculated quantity2 is '||p_ordered_quantity2);
      	END IF;

   -- ELSIF (l_item_rec.dualum_ind in (2,3) ) THEN
   /* passed quantity is not null and secondary_default_ind in ('D','N (dualum_ind is 2 or 3) */
   ELSIF (l_item_rec.secondary_default_ind in ('D','N') )  tHEN -- INVCONV

       -- check the deviation and error out
       l_return := INV_CONVERT.Within_Deviation  -- INVCONV
                       ( p_organization_id   =>
                                 p_ship_from_org_id
                       , p_inventory_item_id =>
                                 p_inventory_item_id
                       , p_lot_number  => p_lot_number -- INVCONV
                       , p_precision         => 5
                       , p_quantity          => abs(p_ordered_quantity)   -- 5128490
                       , p_uom_code1         => p_ordered_quantity_uom -- INVCONV
                       , p_quantity2         => abs(p_ordered_quantity2)   -- 5128490
                       , p_uom_code2         => l_item_rec.secondary_uom_code );

      IF l_return = 0
      	then
      	    IF l_debug_level  > 0 THEN
    	  			oe_debug_pub.add('Calculate_dual_quantity - tolerance error 1' ,1);
    			 END IF;

    			 l_buffer          := FND_MSG_PUB.GET(p_msg_index => FND_MSG_PUB.G_LAST, -- INVCONV
                                         p_encoded => 'F');
           oe_msg_pub.add_text(p_message_text => l_buffer);
           IF l_debug_level  > 0 THEN
              oe_debug_pub.add(l_buffer,1);
    			 END IF;
    			 RAISE TOLERANCE_ERROR ;

   		else
      	IF l_debug_level  > 0 THEN
    	  		oe_debug_pub.add('Calculate_dual_quantity - No tolerance error so return ',1);
    		END IF;
    		x_return_status := 0;
     	RETURN;
     END IF; -- IF l_return = 0


      /* l_return := GMICVAL.dev_validation(l_item_rec.opm_item_id INVCONV
                                      ,nvl(p_lot_id, 0) --  2380194
                                      ,p_ordered_quantity
                                      ,l_OPM_UOM
                                      ,p_ordered_quantity2
                                      ,l_item_rec.opm_item_um2
                                      ,0);
      IF (l_return = -68 ) THEN
         x_return_status := -1;
         FND_MESSAGE.set_name('GMI','IC_DEVIATION_HI_ERR');
         OE_MSG_PUB.Add;
      ELSIF(l_return = -69 ) THEN
         x_return_status := -1;
         FND_MESSAGE.set_name('GMI','IC_DEVIATION_HI_ERR');
         OE_MSG_PUB.Add;
      END IF; */


   END IF;    -- IF (NVL(p_ordered_quantity2,0) = 0

   IF(x_return_status = -1 ) THEN
     RAISE FND_API.G_EXC_ERROR;
   END IF;

   RETURN;

END IF; -- IF ( X_UI_FLAG = 0 ) THEN


IF l_debug_level  > 0 THEN
	oe_debug_pub.add('Calculate_dual_quantity  - Convert for dual controlled item Scenario',1);
END IF;

/* Has one of the two quantities changed
=======================================*/
IF (NOT OE_GLOBALS.EQUAL(p_ordered_quantity
         			    ,p_old_ordered_quantity )) OR
   (NOT OE_GLOBALS.EQUAL(p_ordered_quantity2
         			    ,p_old_ordered_quantity2)) OR
   (p_ordered_quantity  IS NULL) OR
   (p_ordered_quantity2 IS NULL) THEN

      IF l_debug_level  > 0 THEN
      	oe_debug_pub.add('Calculate_dual_quantity - change detected ',1);
      END IF;

   /*
   IF l_item_rec.dualum_ind = 1 THEN
     RETURN;
   END IF;
   */
ELSE
   /* No calculation  required
   ==================*/
   RETURN;
END IF; -- IF (NOT OE_GLOBALS.EQUAL(p_ordered_quantity




/* Get the OPM equivalent code for order_quantity_uom
=====================================================   INVCONV
GMI_Reservation_Util.Get_OPMUOM_from_AppsUOM
				 (p_Apps_UOM       => p_ordered_quantity_uom
				 ,x_OPM_UOM        => l_OPM_UOM
				 ,x_return_status  => l_status
				 ,x_msg_count      => l_msg_count
				 ,x_msg_data       => l_msg_data);

   IF (l_status <> FND_API.G_RET_STS_SUCCESS)
   THEN
      x_return_status := -1;
      oe_debug_pub.add('OPM After Get_OPMUOM_from_appsUOM -  failed : apps_uom =  ' || p_ordered_quantity_uom || 'opm_uom = ' || l_opm_uom );
   ELSE
      x_return_status := 1;
      oe_debug_pub.add('OPM After Get_OPMUOM_from_appsUOM : apps_uom =  ' || p_ordered_quantity_uom || 'opm_uom = ' || l_opm_uom );
   END IF;   */


IF (NOT OE_GLOBALS.EQUAL(p_ordered_quantity
         			    ,p_old_ordered_quantity )) OR
				     p_ordered_quantity2 IS NULL THEN

  /* Primary quantity has changed so recalculate secondary */

  -- IF l_item_rec.dualum_ind in (2,3)
     IF (l_item_rec.secondary_default_ind in ('D','N') ) -- INVCONV
    and p_ordered_quantity is NOT NULL AND
    p_ordered_quantity_uom <> p_ordered_quantity_uom2 AND
    p_ordered_quantity2 is NOT NULL THEN

    /* Only do tolerance check if both quantities populated */
			IF l_debug_level  > 0 THEN
       		oe_debug_pub.add('Calculate_dual_quantity - Check the deviation  ');
      END IF;

      l_return := INV_CONVERT.Within_Deviation  -- INVCONV
                       ( p_organization_id   =>
                                 p_ship_from_org_id
                       , p_inventory_item_id =>
                                 p_inventory_item_id
                       , p_lot_number  => p_lot_number -- INVCONV
                       , p_precision         => 5
                       , p_quantity          => abs(p_ordered_quantity) -- 5128490
                       , p_uom_code1         => p_ordered_quantity_uom
                       , p_quantity2         => abs(p_ordered_quantity2)  -- 5128490
                       , p_uom_code2         => l_item_rec.secondary_uom_code);

      IF l_return = 0
      	then
      	   IF l_debug_level  > 0 THEN
    	  			oe_debug_pub.add('Calculate_dual_quantity - tolerance error 2' ,1);
    			 END IF;
     			 l_buffer := FND_MSG_PUB.GET(p_msg_index => FND_MSG_PUB.G_LAST, -- INVCONV
                                         p_encoded => 'F');
           oe_msg_pub.add_text(p_message_text => l_buffer);
           IF l_debug_level  > 0 THEN
              oe_debug_pub.add(l_buffer,1);
    			 END IF;
    			 RAISE TOLERANCE_ERROR ;

   		else
      	IF l_debug_level  > 0 THEN
    	  		oe_debug_pub.add('Calculate_dual_quantity - No tolerance error so return ',1);
    		END IF;
    	  x_return_status := 0;
     	  RETURN;
     END IF; -- IF l_return = 0


     /* l_return := GMICVAL.dev_validation(l_item_rec.opm_item_id
                                      ,nvl(p_lot_id, 0) --  2380194
				      ,p_ordered_quantity
				      ,l_OPM_UOM
				      ,p_ordered_quantity2
                                      ,l_item_rec.opm_item_um2
				      ,0);
    -- if change is within of tolerance, no further action

    IF (l_return NOT in (-68, -69)) THEN
       oe_debug_pub.add(' OPM : calculate_dual_qty .No tolerance error so return  ');
       RETURN;
    ELSE   ---  IF (l_item_rec.dualum_ind = 3 )THEN
       x_return_status := l_return;
       oe_debug_pub.add('Calculate_dual_quantity - deviation error so return  ');
       RETURN;
    END IF;    */

  END IF; -- IF (l_item_rec.secondary_default_ind in ('D','N')THEN

 -- IF (l_item_rec.dualum_ind in (1,2) )THEN    INVCONV
    IF (l_item_rec.secondary_default_ind in ('F','D') ) THEN -- INVCONV
 							IF l_debug_level  > 0 THEN
              		oe_debug_pub.add('Calculate_dual_qty - uom conversion primary to secondary');
              END IF;
     /*l_converted_qty :=GMICUOM.uom_conversion
 	            (l_item_rec.opm_item_id,0
     	    	     ,p_ordered_quantity
                     ,l_OPM_UOM
    	    	     ,l_item_rec.opm_item_um2
	             ,0);

     IF (l_converted_qty < 0) THEN
        x_return_status := -11 ;
     END IF;
     p_ordered_quantity2 := l_converted_qty;    */

      /*p_ordered_quantity2 := GMI_Reservation_Util.get_opm_converted_qty( INVCONV
              p_apps_item_id    => p_inventory_item_id,
              p_organization_id => p_ship_from_org_id,
              p_apps_from_uom   => p_ordered_quantity_uom,
              p_apps_to_uom     => p_ordered_quantity_uom2,
              p_original_qty    => p_ordered_quantity,
              p_lot_id          => nvl(p_lot_id, 0) ); -- OPM 2380194  */

     p_ordered_quantity2 := INV_CONVERT.INV_UM_CONVERT(p_inventory_item_id -- INVCONV
     																									,p_lot_number     -- INVCONV
     																									,p_ship_from_org_id -- INVCONV
                                                      ,5 --NULL
                                                      ,p_ordered_quantity
                                                      ,p_ordered_quantity_uom
                                                      ,p_ordered_quantity_uom2
                                                      ,NULL -- From uom name
                                                      ,NULL -- To uom name
                                                      );
    IF (p_ordered_quantity2 < 0) THEN    -- INVCONV
              raise UOM_CONVERSION_FAILED;
    END IF;


      	IF l_debug_level  > 0 THEN
      			oe_debug_pub.add('Calculate_dual_quantity : calculated quantity2 is '||p_ordered_quantity2);
      	END IF;




 END IF; -- IF (l_item_rec.secondary_default_ind in ('F','D')THEN

ELSIF (NOT OE_GLOBALS.EQUAL(p_ordered_quantity2
         			        ,p_old_ordered_quantity2 )) THEN
  /* Secondary quantity has changed so recalculate primary */



  -- IF l_item_rec.dualum_ind in (2,3) and  INVCONV
    IF (l_item_rec.secondary_default_ind in ('D','N')  )and  -- INVCONV
    p_ordered_quantity2 is NOT NULL AND
    p_ordered_quantity_uom <> p_ordered_quantity_uom2 AND
    p_ordered_quantity is NOT NULL THEN

    /* Only do tolerance check if both quantities populated */
   l_return := INV_CONVERT.Within_Deviation  -- INVCONV
                       ( p_organization_id   =>
                                 p_ship_from_org_id
                       , p_inventory_item_id =>
                                 p_inventory_item_id
                       , p_lot_number  => p_lot_number -- INVCONV
                       , p_precision         => 5
                       , p_quantity          => abs(p_ordered_quantity) -- 5128490
                       , p_uom_code1         => p_ordered_quantity_uom
                       , p_quantity2         => abs(p_ordered_quantity2) -- 5128490
                       , p_uom_code2         => l_item_rec.secondary_uom_code );

       IF l_return = 0
      	then
      	    IF l_debug_level  > 0 THEN
    	  			oe_debug_pub.add('Calculate_dual_quantity - tolerance error 3' ,1);
    			 END IF;

    			 l_buffer := FND_MSG_PUB.GET(p_msg_index => FND_MSG_PUB.G_LAST, -- INVCONV
                                         p_encoded => 'F');
           oe_msg_pub.add_text(p_message_text => l_buffer);
           IF l_debug_level  > 0 THEN
              oe_debug_pub.add(l_buffer,1);
    			 END IF;
    			 RAISE TOLERANCE_ERROR ;

   		else
      	IF l_debug_level  > 0 THEN
    	  		oe_debug_pub.add('Calculate_dual_quantity - No tolerance error so return ',1);
    		END IF;
     	RETURN;
     END IF; -- IF l_return = 0


     /* l_return := GMICVAL.dev_validation(l_item_rec.opm_item_id
                                      ,nvl(p_lot_id, 0) --  2380194
	           	              ,p_ordered_quantity
				      ,l_OPM_UOM
				      ,p_ordered_quantity2
                                      ,l_item_rec.opm_item_um2
				      ,0);
    --  if change is within tolerance, no further action
    IF (l_return NOT in (-68, -69)) THEN
       oe_debug_pub.add(' OPM : calculate_dual_qty .No tolerance error so return  ');
       RETURN;
    ELSE  -- IF (l_item_rec.dualum_ind = 3 )THEN
       x_return_status := l_return;
       oe_debug_pub.add('Calculate_dual_quantity .deviation error so return  ');
       RETURN;
    END IF;   */

  END IF;   -- IF (l_item_rec.secondary_default_ind in ('D','N')and  -- INVCONV

  --IF (l_item_rec.dualum_ind in (1,2) )THEN
    IF (l_item_rec.secondary_default_ind in ('F','D'))  then -- INVCONV
     /* Convert secondary quantity to derive primary */
    -- use l_converted_qty with precision of 19,9 to match OPM processing
    /*l_converted_qty  :=GMICUOM.uom_conversion
 	   	        (l_item_rec.opm_item_id,0
    	                ,p_ordered_quantity2
    	       	        ,l_item_rec.opm_item_um2
    	                ,l_OPM_UOM
			,0);

    IF (l_converted_qty < 0) THEN
       x_return_status := -11;
    END IF;

    p_ordered_quantity := l_converted_qty;          */
    /* p_ordered_quantity := GMI_Reservation_Util.get_opm_converted_qty(
              p_apps_item_id    => p_inventory_item_id,
              p_organization_id => p_ship_from_org_id,
              p_apps_from_uom   => p_ordered_quantity_uom2,
              p_apps_to_uom     => p_ordered_quantity_uom,
              p_original_qty    => p_ordered_quantity2,
              p_lot_id          => nvl(p_lot_id, 0) ); -- OPM 2380194 */

    p_ordered_quantity := INV_CONVERT.INV_UM_CONVERT(p_inventory_item_id -- INVCONV
    																									,p_lot_number     -- INVCONV
    																									,p_ship_from_org_id -- INVCONV
                                                      ,5 --NULL
                                                      ,p_ordered_quantity2
                                                      ,p_ordered_quantity_uom2
                                                      ,p_ordered_quantity_uom
                                                      ,NULL -- From uom name
                                                      ,NULL -- To uom name
                                                      );
    IF (p_ordered_quantity < 0) THEN    -- INVCONV
              raise UOM_CONVERSION_FAILED;
    END IF;

    IF l_debug_level  > 0 THEN
       oe_debug_pub.add('Calculate_dual_quantity  - convert to ordered qty gives ' || p_ordered_quantity);
    END IF;
 END IF; --    IF (l_item_rec.secondary_default_ind in ('F','D')  -- INVCONV

END IF; --  IF (NVL(p_ordered_quantity2,0) = 0

IF l_debug_level  > 0 THEN
 			 oe_debug_pub.add('Calculate_dual_quantity  - exiting ordered qty = ' || p_ordered_quantity);
       oe_debug_pub.add('Calculate_dual_quantity  - exiting ordered qty2 = ' || p_ordered_quantity2);
    END IF;
EXCEPTION

WHEN UOM_CONVERSION_FAILED THEN
				oe_debug_pub.add('Exception handling: UOM_CONVERSION_FAILED in calculate_dual_qty', 1);
    FND_MESSAGE.SET_NAME('INV','INV_NO_CONVERSION_ERR'); -- INVCONV
    OE_MSG_PUB.Add;
       x_return_status := -99999;
     --RAISE FND_API.G_EXC_ERROR;


WHEN TOLERANCE_ERROR THEN -- INVCONV
				oe_debug_pub.add('Exception handling: TOLERANCE_ERROR in calculate_dual_qty', 1);
 				 x_return_status := -1;
         --RAISE -- FND_API.G_EXC_ERROR; -- INVCONV

WHEN OTHERS THEN
     IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
         OE_MSG_PUB.Add_Exc_Msg
         (     G_PKG_NAME         ,
             'Calculate_dual_quantity'
         );
     END IF;
        oe_debug_pub.add('Exception handling: others in calculate_dual_qty', 1);
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END calculate_dual_quantity;



PROCEDURE Log_Blanket_Request
(   p_x_line_rec                    IN OUT NOCOPY  OE_Order_PUB.Line_Rec_Type
,   p_old_line_rec                  IN OE_Order_PUB.Line_Rec_Type
)
IS
  l_return_status                VARCHAR2(30);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    if l_debug_level > 0 then
       oe_debug_pub.add('line id : '||p_x_line_rec.line_id);
       oe_debug_pub.add('new blanket number : '||p_x_line_rec.blanket_number);
       oe_debug_pub.add('old blanket number : '||p_old_line_rec.blanket_number);
       oe_debug_pub.add('fulfilled flag : '||p_x_line_rec.fulfilled_flag);
       oe_debug_pub.add('operation : '||p_x_line_rec.operation);
       oe_debug_pub.add('split from line ID : '||p_x_line_rec.split_from_line_id);
       oe_debug_pub.add('split action code : '||p_x_line_rec.split_action_code);
       oe_debug_pub.add('split by : '||p_x_line_rec.split_by);
    end if;

    -- BUG 2746595, send currency code as request_unique_key1 parameter to
    -- process release request. This is required as 2 distinct requests need to
    -- be logged for currency updates.

    IF p_x_line_rec.operation = OE_GLOBALS.G_OPR_DELETE
    THEN

       OE_Order_Cache.Load_Order_Header(p_x_line_rec.header_id);

       -- For DELETES, log process releases request with new values as
       -- null or 0 so that quantity/amount cumulations see negative
       -- changes thus resulting in decrementing final released qty/amount
       OE_Delayed_Requests_Pvt.Log_Request
           (p_entity_code               => OE_GLOBALS.G_ENTITY_ALL
           ,p_entity_id                 => p_x_line_rec.line_id
           ,p_requesting_entity_code    => OE_GLOBALS.G_ENTITY_LINE
           ,p_requesting_entity_id      => p_x_line_rec.line_id
           ,p_request_type              => OE_GLOBALS.G_PROCESS_RELEASE
           -- Old values
           ,p_param1                    => p_x_line_rec.blanket_number
           ,p_param2                    => p_x_line_rec.blanket_line_number
           ,p_param3                    => p_x_line_rec.ordered_quantity
           ,p_param4                    => p_x_line_rec.order_quantity_uom
           ,p_param5                    => p_x_line_rec.unit_selling_price
           ,p_param6                    => p_x_line_rec.inventory_item_id
           -- New values
           ,p_param11                   => null
           ,p_param12                   => null
           ,p_param13                   => 0
           ,p_param14                   => null
           ,p_param15                   => 0
           ,p_param16                   => null
           -- Other parameters
           ,p_param8                    => p_x_line_rec.fulfilled_flag
           ,p_param9                    => p_x_line_rec.line_set_id
           ,p_request_unique_key1       =>
                        OE_Order_Cache.g_header_rec.transactional_curr_code

           ,x_return_status             => l_return_status
          );

       -- If this is a shipment line, log request against the line set
       -- to validate that sum of quantities/amounts across all shipments
       -- in this line set are within the release min/max limits on blanket
       IF p_x_line_rec.line_set_id IS NOT NULL THEN
         OE_Delayed_Requests_Pvt.Log_Request
           (p_entity_code               => OE_GLOBALS.G_ENTITY_ALL
           ,p_entity_id                 => p_x_line_rec.line_set_id
           ,p_requesting_entity_code    => OE_GLOBALS.G_ENTITY_LINE
           ,p_requesting_entity_id      => p_x_line_rec.line_id
           ,p_request_type              => OE_GLOBALS.G_VALIDATE_RELEASE_SHIPMENTS
           ,p_request_unique_key1       => p_x_line_rec.blanket_number
           ,p_request_unique_key2       => p_x_line_rec.blanket_line_number
           ,p_param1                    =>
                        OE_Order_Cache.g_header_rec.transactional_curr_code
           ,x_return_status             => l_return_status
           );
       END IF;

     ELSIF (
               OE_Quote_Util.G_COMPLETE_NEG = 'Y'
            AND
      NOT OE_GLOBALS.EQUAL(p_x_line_rec.transaction_phase_code
                      ,p_old_line_rec.transaction_phase_code)
           )
     THEN

       if l_debug_level > 0 then
          oe_debug_pub.add('log blanket requests for complete neg');
       end if;

       OE_Order_Cache.Load_Order_Header(p_x_line_rec.header_id);

       -- Qty/amount against the blanket should be incremented by
       -- total qty/amount of this line, as complete negotiation is
       -- running consumption logic for this order first time.
       -- Hence, send old parameter (param1-6) values as null.
       OE_Delayed_Requests_Pvt.Log_Request
           (p_entity_code               => OE_GLOBALS.G_ENTITY_ALL
           ,p_entity_id                 => p_x_line_rec.line_id
           ,p_requesting_entity_code    => OE_GLOBALS.G_ENTITY_LINE
           ,p_requesting_entity_id      => p_x_line_rec.line_id
           ,p_request_type              => OE_GLOBALS.G_PROCESS_RELEASE
           -- Old values
           ,p_param1                    => null
           ,p_param2                    => null
           ,p_param3                    => null
           ,p_param4                    => null
           ,p_param5                    => null
           ,p_param6                    => null
           -- New values
           ,p_param11                   => p_x_line_rec.blanket_number
           ,p_param12                   => p_x_line_rec.blanket_line_number
           ,p_param13                   => p_x_line_rec.ordered_quantity
           ,p_param14                   => p_x_line_rec.order_quantity_uom
           ,p_param15                   => p_x_line_rec.unit_selling_price
           ,p_param16                   => p_x_line_rec.inventory_item_id
           -- Other parameters
           ,p_param8                    => p_x_line_rec.fulfilled_flag
           ,p_param9                    => p_x_line_rec.line_set_id
           ,p_request_unique_key1       =>
                        OE_Order_Cache.g_header_rec.transactional_curr_code
           ,x_return_status             => l_return_status
          );

       -- If this is a shipment line, log request against the line set
       -- to validate that sum of quantities/amounts across all shipments
       -- in this line set are within the release min/max limits on blanket
       IF p_x_line_rec.line_set_id IS NOT NULL THEN

          IF p_x_line_rec.blanket_number IS NOT NULL THEN
              OE_Delayed_Requests_Pvt.Log_Request
               (p_entity_code               => OE_GLOBALS.G_ENTITY_ALL
                ,p_entity_id                 => p_x_line_rec.line_set_id
                ,p_requesting_entity_code    => OE_GLOBALS.G_ENTITY_LINE
                ,p_requesting_entity_id      => p_x_line_rec.line_id
                ,p_request_type              => OE_GLOBALS.G_VALIDATE_RELEASE_SHIPMENTS
                ,p_request_unique_key1       => p_x_line_rec.blanket_number
                ,p_request_unique_key2       => p_x_line_rec.blanket_line_number
                ,p_param1                    =>
                        OE_Order_Cache.g_header_rec.transactional_curr_code
                ,x_return_status             => l_return_status
                );
          END IF;

       END IF; -- if line_set_id is not null

    ELSIF (NOT OE_GLOBALS.EQUAL(p_x_line_rec.blanket_number
                            ,p_old_line_rec.blanket_number)
         OR NOT OE_GLOBALS.EQUAL(p_x_line_rec.blanket_line_number
                            ,p_old_line_rec.blanket_line_number)
         OR NOT OE_GLOBALS.EQUAL(p_x_line_rec.ordered_quantity
                            ,p_old_line_rec.ordered_quantity)
         OR NOT OE_GLOBALS.EQUAL(p_x_line_rec.unit_selling_price
                            ,p_old_line_rec.unit_selling_price)
         OR NOT OE_GLOBALS.EQUAL(p_x_line_rec.order_quantity_uom
                            ,p_old_line_rec.order_quantity_uom)
          )
    THEN

       -- For creates and updates, log request if any fields affecting
       -- quantities/amounts are changed

       OE_Order_Cache.Load_Order_Header(p_x_line_rec.header_id);

       OE_Delayed_Requests_Pvt.Log_Request
           (p_entity_code               => OE_GLOBALS.G_ENTITY_ALL
           ,p_entity_id                 => p_x_line_rec.line_id
           ,p_requesting_entity_code    => OE_GLOBALS.G_ENTITY_LINE
           ,p_requesting_entity_id      => p_x_line_rec.line_id
           ,p_request_type              => OE_GLOBALS.G_PROCESS_RELEASE
           -- Old values
           ,p_param1                    => p_old_line_rec.blanket_number
           ,p_param2                    => p_old_line_rec.blanket_line_number
           ,p_param3                    => p_old_line_rec.ordered_quantity
           ,p_param4                    => p_old_line_rec.order_quantity_uom
           ,p_param5                    => p_old_line_rec.unit_selling_price
           ,p_param6                    => p_old_line_rec.inventory_item_id
           -- New values
           ,p_param11                   => p_x_line_rec.blanket_number
           ,p_param12                   => p_x_line_rec.blanket_line_number
           ,p_param13                   => p_x_line_rec.ordered_quantity
           ,p_param14                   => p_x_line_rec.order_quantity_uom
           ,p_param15                   => p_x_line_rec.unit_selling_price
           ,p_param16                   => p_x_line_rec.inventory_item_id
           -- Other parameters
           ,p_param8                    => p_x_line_rec.fulfilled_flag
           ,p_param9                    => p_x_line_rec.line_set_id
           ,p_request_unique_key1       =>
                        OE_Order_Cache.g_header_rec.transactional_curr_code
           ,x_return_status             => l_return_status
          );

       -- If this is a shipment line, log request against the line set
       -- to validate that sum of quantities/amounts across all shipments
       -- in this line set are within the release min/max limits on blanket
       IF p_x_line_rec.line_set_id IS NOT NULL THEN

          IF p_x_line_rec.blanket_number IS NOT NULL THEN
              OE_Delayed_Requests_Pvt.Log_Request
               (p_entity_code               => OE_GLOBALS.G_ENTITY_ALL
                ,p_entity_id                 => p_x_line_rec.line_set_id
                ,p_requesting_entity_code    => OE_GLOBALS.G_ENTITY_LINE
                ,p_requesting_entity_id      => p_x_line_rec.line_id
                ,p_request_type              => OE_GLOBALS.G_VALIDATE_RELEASE_SHIPMENTS
                ,p_request_unique_key1       => p_x_line_rec.blanket_number
                ,p_request_unique_key2       => p_x_line_rec.blanket_line_number
                ,p_param1                    =>
                        OE_Order_Cache.g_header_rec.transactional_curr_code
                ,x_return_status             => l_return_status
                );
          END IF;

          -- If blanket number is being updated on the shipment, also
          -- need to run shipment validation for the old blanket reference
          IF p_old_line_rec.blanket_number IS NOT NULL
             AND (NOT OE_GLOBALS.EQUAL(p_x_line_rec.blanket_number
                                    ,p_old_line_rec.blanket_number)
                  OR NOT OE_GLOBALS.EQUAL(p_x_line_rec.blanket_line_number
                                     ,p_old_line_rec.blanket_line_number)
                  )
          THEN
              OE_Delayed_Requests_Pvt.Log_Request
               (p_entity_code               => OE_GLOBALS.G_ENTITY_ALL
                ,p_entity_id                 => p_x_line_rec.line_set_id
                ,p_requesting_entity_code    => OE_GLOBALS.G_ENTITY_LINE
                ,p_requesting_entity_id      => p_x_line_rec.line_id
                ,p_request_type              => OE_GLOBALS.G_VALIDATE_RELEASE_SHIPMENTS
                ,p_request_unique_key1       => p_old_line_rec.blanket_number
                ,p_request_unique_key2       => p_old_line_rec.blanket_line_number
                ,p_param1                    =>
                        OE_Order_Cache.g_header_rec.transactional_curr_code
                ,x_return_status             => l_return_status
                );
          END IF;

       END IF; -- if line_set_id is not null

    END IF; -- if operation is DELETE

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   WHEN OTHERS THEN
     oe_debug_pub.add('Others error in Log_Blanket_Request');
     oe_debug_pub.add('Error :'||substr(sqlerrm,1,200));
     IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
         OE_MSG_PUB.Add_Exc_Msg
         (     G_PKG_NAME         ,
             'Log_Blanket_Request'
         );
     END IF;
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Log_Blanket_Request;


/*sdatti*/
--procedure to update the adjustments of a line when the item is changed.
--should handle deleting the IUE associations and the updating the
--parent adjustments for free goods
--see bug#2643552

PROCEDURE  update_adjustment_flags
  ( p_old_line_rec IN OE_Order_PUB.line_rec_type,
    p_x_line_rec IN OE_Order_PUB.line_rec_type)
  IS

--cursor to return the current line association id and the
--parent line assocation id through the OE_PRICE_ADJ_ASSOCS table
CURSOR C1 IS
   SELECT opa1.price_adjustment_id, opa2.price_adjustment_id, opa1.line_id
     FROM
      oe_price_adjustments opa1,
      oe_price_adj_assocs opaa,
      oe_price_adjustments opa2
     WHERE
     opa1.line_id = p_old_line_rec.line_id
     AND opa1.price_adjustment_id = opaa.rltd_price_adj_id
     AND opaa.price_adjustment_id = opa2.price_adjustment_id
     AND opa2.list_line_type_code = 'PRG';

--cursor to find the IUE adjustments for this line
CURSOR c2 IS
   SELECT price_adjustment_id
     FROM oe_price_adjustments
     where line_id=p_old_line_rec.line_id AND list_line_type_code='IUE';

--variables to read the cursor C1 into
parent_adj_id                oe_price_adjustments.price_adjustment_id%TYPE;
child_adj_id                 oe_price_adjustments.price_adjustment_id%TYPE;
child_line_id		     oe_price_adjustments.line_id%TYPE;

iue_adj_id                   oe_price_adjustments.price_adjustment_id%TYPE;
app_f			     oe_price_adjustments.applied_flag%TYPE;
up_f			     oe_price_adjustments.updated_flag%TYPE;
row_count                    NUMBER;

BEGIN
   oe_debug_pub.ADD('Entering OE_LINE_UTIL.UPDATE_ADJUSTMENT_FLAGS',1);

   IF p_old_line_rec.inventory_item_id IS NULL THEN
      --new item, dont need to do anything
      oe_debug_pub.ADD('New Item, dont have to do anything',1);
      oe_debug_pub.ADD('Exiting OE_LINE_UTIL.UPDATE_ADJUSTMENT_FLAGS',1);
      RETURN;
   END IF;

   --deleting the IUE adjustment
   /*   DELETE FROM oe_price_adjustments
   where line_id=p_old_line_rec.line_id AND list_line_type_code='IUE';*/

   oe_debug_pub.ADD('trying to delete IUE adjustments...',1);
   OPEN c2;
   FETCH c2 INTO iue_adj_id;
   IF c2%found THEN
      oe_line_adj_util.delete_row(p_price_adjustment_id=>iue_adj_id);
      oe_debug_pub.ADD('deleted IUE association:'||SQL%rowcount||' row(s)',1);
      oe_debug_pub.ADD('looking for item parent lines...',1);
   END IF;
   CLOSE c2;



   OPEN c1;
	     loop
		--loop through all the parents
		FETCH c1 INTO child_adj_id, parent_adj_id,child_line_id;
		EXIT WHEN c1%notfound;

		oe_debug_pub.ADD('found parent line:'||parent_adj_id||' for child line:'||child_adj_id,1);

			--delete the adjustment if this is the child line.
		IF child_line_id=p_old_line_rec.line_id then
		   oe_debug_pub.ADD('trying to delete adjustments for line_id:'||p_old_line_rec.line_id,1);
		   oe_line_adj_util.delete_row(p_line_id=>p_old_line_rec.line_id);
		   oe_debug_pub.ADD('child adj id '||child_adj_id,1);
	           OE_Line_Adj_Assocs_Util.delete_row(
			p_price_adjustment_id=>child_adj_id);
		END IF;

		--Find out the number of free items adjustments associated with this parent
		--(other then this item, we already deleted its adjustment)
		SELECT COUNT(*) INTO row_count
		  FROM oe_price_adj_assocs opaa,oe_price_adjustments opa
		  WHERE opaa.price_adjustment_id=parent_adj_id
		  AND opaa.rltd_price_adj_id=opa.price_adjustment_id;
		oe_debug_pub.ADD('total '||row_count||' free child record(s)',1);

		IF  row_count>0 THEN
		   --not the only free item, this adjustment is applied _and_ updated = 'Y'
		   UPDATE oe_price_adjustments
		     SET applied_flag='Y',updated_flag='Y'
		     WHERE price_adjustment_id=parent_adj_id;
		   oe_debug_pub.ADD('updated parent adjustment: applied_flag=Y,updated_flag=Y:'||SQL%rowcount||' row(s)',1);
                   UPDATE oe_price_adjustments
                     SET updated_flag = 'Y' where price_adjustment_id in
                      (select rltd_price_adj_id from oe_price_adj_assocs
                       where price_adjustment_id = parent_adj_id);
		 ELSE
		   --the last (or only) free item, make parent adjustment applied='N'
		   UPDATE oe_price_adjustments
		     SET applied_flag='N',updated_flag='Y'
		     WHERE price_adjustment_id=parent_adj_id;
		   oe_debug_pub.ADD('updated parent adjustment: applied_flag=N,updated_flag=Y:'||SQL%rowcount||' rows',1);
		END IF;
		SELECT applied_flag,updated_flag INTO app_f,up_f
		  FROM oe_price_adjustments
		  WHERE price_adjustment_id=parent_adj_id;
		oe_debug_pub.ADD('price_adjustment_id:'||parent_adj_id||' applied_flag='||app_f||' updated_flag='||up_f,1);


	     END LOOP;
	     CLOSE c1;
	     oe_debug_pub.ADD('...done looking for item parent lines',1);
	     oe_debug_pub.ADD('Exiting OE_LINE_UTIL.UPDATE_ADJUSTMENT_FLAGS',1);
	     RETURN;

END update_adjustment_flags;

/*sdatti*/


/* Procedure Get_Item_Info
-------------------------------------------------------
This procedure will return ordered_item, ordered_item_description and
inventory_item based on passing in item_identifier_type */

PROCEDURE GET_ITEM_INFO
(   x_return_status         OUT NOCOPY VARCHAR2
,   x_msg_count             OUT NOCOPY NUMBER
,   x_msg_data              OUT NOCOPY VARCHAR2
,   p_item_identifier_type          IN VARCHAR2
,   p_inventory_item_id             IN Number
,   p_ordered_item_id               IN Number
,   p_sold_to_org_id                IN Number
,   p_ordered_item                  IN VARCHAR2
,   x_ordered_item          OUT NOCOPY VARCHAR2
,   x_ordered_item_desc     OUT NOCOPY VARCHAR2
,   x_inventory_item        OUT NOCOPY VARCHAR2
,   p_org_id                        IN Number DEFAULT NULL
) IS

BEGIN

-- Bug 5244726
OE_ORDER_MISC_UTIL.GET_ITEM_INFO( x_return_status
,   x_msg_count
,   x_msg_data
,   p_item_identifier_type
,   p_inventory_item_id
,   p_ordered_item_id
,   p_sold_to_org_id
,   p_ordered_item
,   x_ordered_item
,   x_ordered_item_desc
,   x_inventory_item
,   p_org_id );

EXCEPTION

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg (   G_PKG_NAME ,   'GET_ITEM_INFO');
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END GET_ITEM_INFO;


-----------------------------------------------------------------
--      *** Enhanced Dropshipments ***
-----------------------------------------------------------------
/*--------------------------------------------------------------+
Name          : Log_Dropship_CMS_Request
Description   : This Procedure will log CMS Delayed Request when
                ever there is a change in the CMS attributes
                This procedure will be called from Pre Write
                Process and delayed request will be executed at
                the commit time.
Change Record :
+--------------------------------------------------------------*/
Procedure Log_Dropship_CMS_Request
( p_x_line_rec            IN OUT NOCOPY  OE_Order_PUB.Line_Rec_Type
, p_old_line_rec          IN OE_Order_PUB.Line_Rec_Type
)
IS
 l_return_status         VARCHAR2(30);
 l_debug_level CONSTANT  NUMBER := oe_debug_pub.g_debug_level;
 l_operation             VARCHAR2(30) := p_x_line_rec.operation;
 l_count                 NUMBER;
 l_ref_data_elem_changed VARCHAR2(1) := 'N';
 l_cust_po_attr_change   BOOLEAN := FALSE ;
 l_rcv_count             NUMBER := 0;
 l_log_cust_po_change    boolean:=TRUE;
 l_ref_data_only         boolean:=FALSE;
BEGIN

  IF l_debug_level >  0 THEN
     OE_DEBUG_PUB.Add('Entering Log_Dropship_CMS_Request...', 2);
  END IF;

  SELECT  count(*)
    INTO  l_count
    FROM  oe_drop_ship_sources
   WHERE  line_id   = p_x_line_rec.line_id
     AND  header_id = p_x_line_rec.header_id;

  IF l_count = 0 THEN
     IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.Add('No Records in Drop Ship Sources,Returning...', 2);
     END IF;
     RETURN;
  END IF;

  IF OE_DS_PVT.Check_Req_PO_Cancelled
              (p_line_id    =>   p_x_line_rec.line_id
              ,p_header_id  =>   p_x_line_rec.header_id)  THEN

        FND_MESSAGE.Set_Name('ONT', 'ONT_DS_PO_CANCELLED');
        OE_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
  END IF;


  IF NOT OE_GLOBALS.EQUAL(p_x_line_rec.shipping_instructions
                              ,p_old_line_rec.shipping_instructions)
     OR NOT OE_GLOBALS.EQUAL(p_x_line_rec.packing_instructions
                              ,p_old_line_rec.packing_instructions)
     OR NOT OE_GLOBALS.EQUAL(p_x_line_rec.ship_to_contact_id
                              ,p_old_line_rec.ship_to_contact_id)
     OR NOT OE_GLOBALS.EQUAL(p_x_line_rec.deliver_to_org_id
                              ,p_old_line_rec.deliver_to_org_id)
     OR NOT OE_GLOBALS.EQUAL(p_x_line_rec.deliver_to_contact_id
                              ,p_old_line_rec.deliver_to_contact_id)
     OR NOT OE_GLOBALS.EQUAL(p_x_line_rec.user_item_description
                              ,p_old_line_rec.user_item_description)
    /* OR NOT OE_GLOBALS.EQUAL(p_x_line_rec.cust_po_number
                              ,p_old_line_rec.cust_po_number)  	    --commented for ER 6072870
     OR NOT OE_GLOBALS.EQUAL(p_x_line_rec.customer_line_number
                              ,p_old_line_rec.customer_line_number)
     OR NOT OE_GLOBALS.EQUAL(p_x_line_rec.customer_shipment_number
                              ,p_old_line_rec.customer_shipment_number) */
     OR NOT OE_GLOBALS.EQUAL(p_x_line_rec.shipping_method_code
                              ,p_old_line_rec.shipping_method_code) THEN

     IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.Add('Change in Reference Data Elements...', 2);
     END IF;

     l_ref_data_elem_changed   :=   'Y';
     l_ref_data_only := true;

  END IF;
/* Added for ER 6072870*/

if NOT OE_GLOBALS.EQUAL(p_x_line_rec.cust_po_number
                              ,p_old_line_rec.cust_po_number)
     OR NOT OE_GLOBALS.EQUAL(p_x_line_rec.customer_line_number
                              ,p_old_line_rec.customer_line_number)
     OR NOT OE_GLOBALS.EQUAL(p_x_line_rec.customer_shipment_number
                             ,p_old_line_rec.customer_shipment_number) THEN
    --{
	IF l_debug_level > 0 THEN
		OE_DEBUG_PUB.Add('Change in customer PO Reference Data Elements...', 2);
	END IF;
	l_ref_data_elem_changed   :=   'Y';
	l_cust_po_attr_change:=true;
    --}
  end if;

  IF l_cust_po_attr_change THEN
  --{
   IF Nvl(p_x_line_rec.shipped_quantity,0)>0 THEN
   --{
    if l_debug_level > 0 then
         oe_debug_pub.add('Drop ship line is already received.So do not log CMS request', 1);
	 l_log_cust_po_change:=FALSE;
    end if;
   --}
   ELSE
   --{
	BEGIN
		SELECT Count(1)
		INTO l_rcv_count
		FROM rcv_transactions rcv,
		oe_drop_ship_sources odss,
		po_line_locations_all pol
		WHERE rcv.PO_LINE_ID=odss.po_line_id
		AND pol.line_location_id=odss.line_location_id
		AND odss.line_id=p_x_line_rec.line_id
		AND RCV.PO_LINE_LOCATION_ID=pol.LINE_LOCATION_ID
		AND TRANSACTION_TYPE='DELIVER'
		AND Nvl(rcv.quantity,0)>0
		AND INTERFACE_SOURCE_CODE='RCV'
		AND SOURCE_DOCUMENT_CODE='PO';

		if l_debug_level > 0 then
		oe_debug_pub.add('line has been received either fully or partially do not log request', 1);
		l_log_cust_po_change:=FALSE;
		end if;

	EXCEPTION
	WHEN No_Data_Found THEN
		if l_debug_level > 0 then
		oe_debug_pub.add('line is not yet received can interface to PO', 1);
		end if;
	        l_log_cust_po_change:=TRUE;
        END;
   --}
   END IF;
  --}
  END IF;

 /* IF NOT OE_GLOBALS.EQUAL(p_x_line_rec.ordered_quantity2  - remove this as valid now for INVCONV
                              ,p_old_line_rec.ordered_quantity2) THEN

     FND_MESSAGE.Set_Name('ONT','ONT_DS_OPM_QTY_CHANGED');
     OE_MSG_PUB.Add;

     IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.Add('Warning!! Secondary Qty Changed...', 2);
     END IF;
  END IF;

  IF NOT OE_GLOBALS.EQUAL(p_x_line_rec.ordered_quantity_uom2
                              ,p_old_line_rec.ordered_quantity_uom2) THEN

     FND_MESSAGE.Set_Name('ONT','ONT_DS_OPM_UOM_CHANGED');
     OE_MSG_PUB.Add;

     IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.Add('Warning!! Secondary Qty UOM Changed...', 2);
     END IF;
  END IF;

  IF NOT OE_GLOBALS.EQUAL(p_x_line_rec.preferred_grade
                              ,p_old_line_rec.preferred_grade) THEN

     FND_MESSAGE.Set_Name('ONT', 'ONT_DS_OPM_GRADE_CHANGED');
     OE_MSG_PUB.Add;

     IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.Add('Warning!! OPM Grade Changed...', 2);
     END IF;

  END IF; */


  IF NOT OE_GLOBALS.EQUAL(p_x_line_rec.ordered_quantity
                             ,p_old_line_rec.ordered_quantity)
     OR NOT OE_GLOBALS.EQUAL(p_x_line_rec.order_quantity_uom
                              ,p_old_line_rec.order_quantity_uom)
     OR NOT OE_GLOBALS.EQUAL(p_x_line_rec.ordered_quantity2
                              ,p_old_line_rec.ordered_quantity2)
     OR NOT OE_GLOBALS.EQUAL(p_x_line_rec.ordered_quantity_uom2
                              ,p_old_line_rec.ordered_quantity_uom2)
     OR NOT OE_GLOBALS.EQUAL(p_x_line_rec.preferred_grade
                              ,p_old_line_rec.preferred_grade)
     OR NOT OE_GLOBALS.EQUAL(p_x_line_rec.schedule_ship_date
                              ,p_old_line_rec.schedule_ship_date)
     OR NOT OE_GLOBALS.EQUAL(p_x_line_rec.ship_to_org_id
                              ,p_old_line_rec.ship_to_org_id)
     OR (l_ref_data_only )	 -- Added for ER 6072870
     OR (l_cust_po_attr_change and not l_ref_data_only and l_log_cust_po_change )
     OR p_x_line_rec.operation  ='DELETE'

     THEN



       IF (p_x_line_rec.ordered_quantity = 0 AND
             OE_SALES_CAN_UTIL.G_REQUIRE_REASON) OR
                   p_x_line_rec.operation = 'DELETE' THEN
          l_operation   :=  'CANCEL';
       END IF;

       IF l_debug_level >  0 THEN
        OE_DEBUG_PUB.Add('-----Logging Dropship_CMS_Request----for Entity:'||
                                                     p_x_line_rec.line_id, 2);
       END IF;

       OE_Delayed_Requests_Pvt.Log_Request
             (p_entity_code             =>   OE_GLOBALS.G_ENTITY_ALL
             ,p_entity_id               =>   p_x_line_rec.line_id
             ,p_requesting_entity_code  =>   OE_GLOBALS.G_ENTITY_LINE
             ,p_requesting_entity_id    =>   p_x_line_rec.line_id
             ,p_request_type            =>   OE_GLOBALS.G_DROPSHIP_CMS
             ,p_param1                  =>   p_old_line_rec.ordered_quantity
             ,p_param2                  =>   p_old_line_rec.order_quantity_uom
             ,p_param3                  =>   p_old_line_rec.ship_to_org_id
             ,p_param4                  =>   p_old_line_rec.ordered_quantity2
             ,p_param5                  =>   p_old_line_rec.ordered_quantity_uom2
             ,p_param6                  =>   p_old_line_rec.preferred_grade
  --         ,p_param7                  =>   p_old_line_rec.schedule_ship_date  --commented for bug#6918700
             ,p_param8                  =>   p_x_line_rec.ordered_quantity
             ,p_param9                  =>   p_x_line_rec.order_quantity_uom
             ,p_param10                 =>   p_x_line_rec.ship_to_org_id
             ,p_param11                 =>   p_x_line_rec.ordered_quantity2
             ,p_param12                 =>   p_x_line_rec.ordered_quantity_uom2
             ,p_param13                 =>   p_x_line_rec.preferred_grade
  --         ,p_param14                 =>   p_x_line_rec.schedule_ship_date    --commented for bug#6918700
             ,p_param15                 =>   l_operation
             ,p_param16                 =>   l_ref_data_elem_changed
/*****Begin changes for bug#6918700*********/
	     ,p_date_param1             =>   p_old_line_rec.schedule_ship_date
	     ,p_date_param2             =>   p_x_line_rec.schedule_ship_date
/*****End changes for bug#6918700*********/
             ,x_return_status           =>   l_return_status
            );

END IF;

     IF l_debug_level >  0 THEN
        OE_DEBUG_PUB.Add('After Logging CMS_Request...'||l_return_status, 2);
     END IF;

     IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     IF l_debug_level >  0 THEN
        OE_DEBUG_PUB.Add('Exiting Log_Dropship_CMS_Request...', 2);
     END IF;


EXCEPTION

    WHEN  FND_API.G_EXC_ERROR THEN
       IF l_debug_level >  0 THEN
          OE_DEBUG_PUB.Add('Execution Error in Log_Dropship_CMS_Request', 2);
       END IF;
       RAISE FND_API.G_EXC_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       IF l_debug_level >  0 THEN
          OE_DEBUG_PUB.Add('Unexpected Error in Log_Dropship_CMS_Request'||
                                 sqlerrm, 1);
       END IF;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    WHEN OTHERS THEN

      IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        OE_MSG_PUB.Add_Exc_Msg
        (   G_PKG_NAME,
          'Log_Dropship_CMS_Request');
      END IF;

END Log_Dropship_CMS_Request;


-- Added new API (HANDLE_RFR proc) for FP bug 6628653 base bug 6513023
PROCEDURE HANDLE_RFR
(
p_line_id            IN NUMBER,
p_top_model_line_id  IN NUMBER,
p_link_to_line_id     IN NUMBER
)
IS
   l_is_rfr          NUMBER;
   l_open_rfr_lines  NUMBER;
   l_activity_status_code  VARCHAR2(30);
   l_result_out      VARCHAR2(30);
   l_return_status   VARCHAR2(30);
   l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

BEGIN
   IF l_debug_level > 0 THEN
      oe_debug_pub.add('Entering HANDLE_RFR ... ', 1);
      oe_debug_pub.add(' with p_line_id  '|| p_line_id , 1);
      oe_debug_pub.add(' with p_top_model_line_id  '|| p_top_model_line_id , 1);
      oe_debug_pub.add(' with p_link_to_line_id  '|| p_link_to_line_id , 1);
   END IF;

       SELECT nvl(bic.required_for_revenue, 0)
       INTO   l_is_rfr
       FROM   oe_order_lines Line,
              bom_inventory_components bic
       WHERE  Line.line_id = p_line_id
       AND    Line.open_flag = 'N'
       AND    bic.component_sequence_id = Line.component_sequence_id
       AND    bic.component_item_id = Line.inventory_item_id;

       IF l_is_rfr = 1 THEN
          IF l_debug_level > 0 THEN
             oe_debug_pub.add('Component being cancelled is marked as RFR, checking if any other RFR Lines are open', 5);
          END IF;

          SELECT count(1)
          INTO   l_open_rfr_lines
          FROM   oe_order_lines Line,
                 bom_inventory_components bic
          WHERE  Line.line_id <> p_line_id
          AND    Line.top_model_line_id = p_top_model_line_id
          AND    Line.link_to_line_id = p_link_to_line_id
          AND    Line.open_flag = 'Y'
          AND    bic.component_sequence_id = Line.component_sequence_id
          AND    bic.component_item_id = Line.inventory_item_id
          AND    bic.required_for_revenue = 1;

          IF l_open_rfr_lines = 0 THEN

             IF l_debug_level > 0 THEN
                oe_debug_pub.add('No more pending RFR lines under current parent, checking status of Parent Line', 5);
             END IF;

             BEGIN
                SELECT ACTIVITY_STATUS
                INTO   l_activity_status_code
                FROM   wf_item_activity_statuses wias,
                       wf_process_activities wpa
                WHERE  wias.item_type = 'OEOL'
                AND    wias.item_key  = to_char(p_link_to_line_id)
                AND    wias.process_activity = wpa.instance_id
                AND    wpa.activity_item_type = 'OEOL'
                AND    wpa.activity_name = 'INVOICING_WAIT_FOR_RFR'
                AND    wias.activity_status = 'NOTIFIED';

                EXCEPTION
                WHEN OTHERS THEN
                   l_activity_status_code := null;
                   oe_debug_pub.add(' in exception block -  '||SQLERRM, 5);
             END;

             IF l_activity_status_code = 'NOTIFIED' THEN
                IF l_debug_level > 0 THEN
                   oe_debug_pub.add('Parent Line waiting to be invoiced, calling API to Invoice Parent ', 5);
                END IF;

               OE_Invoice_PUB.Interface_Line(  p_link_to_line_id
                                              ,OE_GLOBALS.G_WFI_LIN
                                              ,l_result_out
                                              ,l_return_status);

                IF l_debug_level  > 0 THEN
                    oe_debug_pub.add(  ' after call to invoice api:   l_result_out: '||l_result_out ) ;
                    oe_debug_pub.add(  ' after call to invoice api:   l_return_status: '|| l_return_status ) ;
                END IF;

                /*
                  Need to check only l_return_status. If SUCCESS, do COMPLETE with default transition
                */
                IF l_return_status = FND_API.G_RET_STS_SUCCESS  THEN
                    IF l_debug_level  > 0 THEN
                         oe_debug_pub.add(  'Updating Line Flow Status and pushing WF ');
                    END IF;
                    Update oe_order_lines
                    Set flow_status_code = 'INVOICED'
                    Where line_id = p_link_to_line_id;

                    BEGIN
                        WF_ENGINE.CompleteActivityInternalName(OE_GLOBALS.G_WFI_LIN, p_link_to_line_id, 'INVOICING_WAIT_FOR_RFR', null);
                    EXCEPTION
                        WHEN OTHERS THEN
                           oe_debug_pub.add(' Error in completing activity; SQL Message -  '||SQLERRM, 5);
                    END;
                ELSE
                   oe_debug_pub.add(' l_return_status is not equal to Success, do nothing  ', 5);
                END IF; --checking l_return_status

             ELSE
                IF l_debug_level > 0 THEN
                   oe_debug_pub.add('Parent Line is not waiting to be Invoiced, do nothing', 5);
                END IF;
             END IF; -- activity_status=NOTIFIED
          ELSE
             IF l_debug_level > 0 THEN
                oe_debug_pub.add('Other RFR lines are still open, no need to Invoice Parent Line', 5);
             END IF;
          END IF; -- IF l_open_rfr_lines ...
       ELSE
          IF l_debug_level > 0 THEN
            oe_debug_pub.add('Current line being cancelled is not RFR', 5);
          END IF;
       END IF; -- IF l_is_rfr ...


      IF l_debug_level > 0 THEN
          oe_debug_pub.add('Exiting HANDLE_RFR ...', 1);
      END IF;

END HANDLE_RFR;


--ER7675548
Procedure Get_customer_info_ids
( p_line_customer_info_tbl IN OUT NOCOPY OE_Order_Pub.CUSTOMER_INFO_TABLE_TYPE,
  p_x_line_tbl       IN OUT NOCOPY OE_Order_Pub.Line_Tbl_Type,
  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_count    OUT NOCOPY NUMBER,
  x_msg_data    OUT NOCOPY VARCHAR2
) IS

x_sold_to_customer_id   NUMBER;
x_ship_to_customer_id   NUMBER;
x_bill_to_customer_id   NUMBER;
x_deliver_to_customer_id  NUMBER;

x_ship_to_org_id NUMBER;
x_invoice_to_org_id NUMBER;
x_deliver_to_org_id NUMBER;
x_sold_to_site_use_id NUMBER;

x_sold_to_contact_id  NUMBER;
x_ship_to_contact_id  NUMBER;
x_invoice_to_contact_id   NUMBER;
x_deliver_to_contact_id   NUMBER;

l_index NUMBER;
l_sold_to_org_id NUMBER;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

x_return_status := FND_API.G_RET_STS_SUCCESS;

IF l_debug_level >0 then
	oe_debug_pub.add('Entering OE_LINE_UTIL.Get_customer_info_ids :'||p_line_customer_info_tbl.count);
End IF;

    IF p_line_customer_info_tbl.count = 0 THEN
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	RETURN;
    END IF;

    l_index := p_x_line_tbl.FIRST;

    WHILE l_index IS NOT NULL LOOP

	OE_MSG_PUB.set_msg_context
        ( p_entity_code                 => 'LINE'
         ,p_entity_id                   => p_x_line_tbl(l_index).line_id
         ,p_header_id                   => p_x_line_tbl(l_index).header_id
         ,p_line_id                     => p_x_line_tbl(l_index).line_id
         ,p_orig_sys_document_ref       => p_x_line_tbl(l_index).orig_sys_document_ref
         ,p_orig_sys_document_line_ref  => p_x_line_tbl(l_index).orig_sys_line_ref
         ,p_orig_sys_shipment_ref       => p_x_line_tbl(l_index).orig_sys_shipment_ref
         ,p_change_sequence             => p_x_line_tbl(l_index).change_sequence
         ,p_source_document_id          => p_x_line_tbl(l_index).source_document_id
         ,p_source_document_line_id     => p_x_line_tbl(l_index).source_document_line_id
         ,p_order_source_id             => p_x_line_tbl(l_index).order_source_id
         ,p_source_document_type_id     => p_x_line_tbl(l_index).source_document_type_id);


	 /* Below code is necessary to pass a value for the sold_to_org_id as value to id
	    routines expects it */

	 IF p_x_line_tbl(l_index).operation = OE_GLOBALS.G_OPR_UPDATE
	     AND p_x_line_tbl(l_index).sold_to_org_id = FND_API.G_MISS_NUM THEN

		l_sold_to_org_id := p_x_line_tbl(l_index).sold_to_org_id;

		BEGIN
			select NVL(sold_to_org_id,p_x_line_tbl(l_index).sold_to_org_id)
			into   l_sold_to_org_id
			from oe_order_lines_all
			where line_id = p_x_line_tbl(l_index).line_id;

		EXCEPTION
			WHEN OTHERS THEN
			NULL;
		END;

	  ELSIF p_x_line_tbl(l_index).operation = OE_GLOBALS.G_OPR_CREATE
	        AND p_x_line_tbl(l_index).sold_to_org_id = FND_API.G_MISS_NUM THEN

		IF OE_CUSTOMER_INFO_PVT.G_SOLD_TO_CUSTOMER_ID IS NOT NULL THEN
			l_sold_to_org_id := OE_CUSTOMER_INFO_PVT.G_SOLD_TO_CUSTOMER_ID;
		ELSE
			l_sold_to_org_id := p_x_line_tbl(l_index).sold_to_org_id;
		END IF;

	  END IF;

	  OE_CUSTOMER_INFO_PVT.get_customer_info_ids (
                          p_customer_info_tbl  => p_line_customer_info_tbl,
		          p_operation_code     => p_x_line_tbl(l_index).operation,
			  p_sold_to_customer_ref => p_x_line_tbl(l_index).sold_to_customer_ref,
			  p_ship_to_customer_ref => p_x_line_tbl(l_index).ship_to_customer_ref,
			  p_bill_to_customer_ref => p_x_line_tbl(l_index).invoice_to_customer_ref,
			  p_deliver_to_customer_ref => p_x_line_tbl(l_index).deliver_to_customer_ref,

			  p_ship_to_address_ref => p_x_line_tbl(l_index).ship_to_address_ref,
			  p_bill_to_address_ref => p_x_line_tbl(l_index).invoice_to_address_ref,
			  p_deliver_to_address_ref => p_x_line_tbl(l_index).deliver_to_address_ref,
			  p_sold_to_address_ref => NULL, --Attribute not avaiable at line level

			  p_sold_to_contact_ref => NULL,  --Attribute not avaiable at line level
			  p_ship_to_contact_ref => p_x_line_tbl(l_index).ship_to_contact_ref,
			  p_bill_to_contact_ref => p_x_line_tbl(l_index).invoice_to_contact_ref,
			  p_deliver_to_contact_ref => p_x_line_tbl(l_index).deliver_to_contact_ref,

			  p_sold_to_customer_id => l_sold_to_org_id,
			  p_ship_to_customer_id => p_x_line_tbl(l_index).ship_to_customer_id,
			  p_bill_to_customer_id  => p_x_line_tbl(l_index).invoice_to_customer_id,
			  p_deliver_to_customer_id  => p_x_line_tbl(l_index).deliver_to_customer_id,

			  p_ship_to_org_id     => p_x_line_tbl(l_index).ship_to_org_id,
			  p_invoice_to_org_id  => p_x_line_tbl(l_index).invoice_to_org_id,
			  p_deliver_to_org_id  => p_x_line_tbl(l_index).deliver_to_org_id,
			  p_sold_to_site_use_id => NULL,  --Attribute not avaiable at line level

			  p_sold_to_contact_id  => OE_CUSTOMER_INFO_PVT.G_SOLD_TO_CONTACT_ID,
			  p_ship_to_contact_id  => p_x_line_tbl(l_index).ship_to_contact_id,
			  p_invoice_to_contact_id => p_x_line_tbl(l_index).invoice_to_contact_id,
			  p_deliver_to_contact_id => p_x_line_tbl(l_index).deliver_to_contact_id,


			  x_sold_to_customer_id => x_sold_to_customer_id,
			  x_ship_to_customer_id => x_ship_to_customer_id,
			  x_bill_to_customer_id => x_bill_to_customer_id,
			  x_deliver_to_customer_id => x_deliver_to_customer_id,


			  x_ship_to_org_id => x_ship_to_org_id,
			  x_invoice_to_org_id => x_invoice_to_org_id,
			  x_deliver_to_org_id => x_deliver_to_org_id,
			  x_sold_to_site_use_id => x_sold_to_site_use_id,

			  x_sold_to_contact_id => x_sold_to_contact_id,
			  x_ship_to_contact_id => x_ship_to_contact_id,
			  x_invoice_to_contact_id => x_invoice_to_contact_id,
			  x_deliver_to_contact_id => x_deliver_to_contact_id ,


			  x_return_status   => x_return_status,
			  x_msg_count       => x_msg_count,
			  x_msg_data        => x_msg_data

			 );

p_x_line_tbl(l_index).sold_to_org_id := x_sold_to_customer_id;
p_x_line_tbl(l_index).ship_to_customer_id := x_ship_to_customer_id;
p_x_line_tbl(l_index).invoice_to_customer_id := x_bill_to_customer_id;
p_x_line_tbl(l_index).deliver_to_customer_id := x_deliver_to_customer_id;

p_x_line_tbl(l_index).ship_to_org_id := x_ship_to_org_id;
p_x_line_tbl(l_index).invoice_to_org_id := x_invoice_to_org_id;
p_x_line_tbl(l_index).deliver_to_org_id := x_deliver_to_org_id;


p_x_line_tbl(l_index).ship_to_contact_id := x_ship_to_contact_id;
p_x_line_tbl(l_index).invoice_to_contact_id := x_invoice_to_contact_id;
p_x_line_tbl(l_index).deliver_to_contact_id := x_deliver_to_contact_id;

IF l_debug_level > 0 THEN
	oe_debug_pub.add('p_x_line_tbl('||l_index||').sold_to_org_id :'||p_x_line_tbl(l_index).sold_to_org_id);
	oe_debug_pub.add('p_x_line_tbl('||l_index||').ship_to_customer_id :'||p_x_line_tbl(l_index).ship_to_customer_id);
	oe_debug_pub.add('p_x_line_tbl('||l_index||').invoice_to_customer_id :'||p_x_line_tbl(l_index).invoice_to_customer_id);
	oe_debug_pub.add('p_x_line_tbl('||l_index||').deliver_to_customer_id :'||p_x_line_tbl(l_index).deliver_to_customer_id);

	oe_debug_pub.add('p_x_line_tbl('||l_index||').ship_to_org_id :'||p_x_line_tbl(l_index).ship_to_org_id);
	oe_debug_pub.add('p_x_line_tbl('||l_index||').invoice_to_org_id :'||p_x_line_tbl(l_index).invoice_to_org_id);
	oe_debug_pub.add('p_x_line_tbl('||l_index||').deliver_to_org_id :'||p_x_line_tbl(l_index).deliver_to_org_id);

	oe_debug_pub.add('p_x_line_tbl('||l_index||').ship_to_contact_id :'||p_x_line_tbl(l_index).ship_to_contact_id);
	oe_debug_pub.add('p_x_line_tbl('||l_index||').invoice_to_contact_id :'||p_x_line_tbl(l_index).invoice_to_contact_id);
	oe_debug_pub.add('p_x_line_tbl('||l_index||').deliver_to_contact_id :'||p_x_line_tbl(l_index).deliver_to_contact_id);

END IF;


	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	        OE_MSG_PUB.reset_msg_context('LINE');
		RETURN;
        END IF;

        l_index := p_x_line_tbl.NEXT(l_index);

        OE_MSG_PUB.reset_msg_context('LINE');

END LOOP;

OE_CUSTOMER_INFO_PVT.G_SOLD_TO_CUSTOMER_ID := NULL;

IF l_debug_level >0 then
	oe_debug_pub.add('Entering OE_LINE_UTIL.Get_customer_info_ids :'||p_line_customer_info_tbl.count);
End IF;



EXCEPTION
	WHEN OTHERS THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Get_customer_info_ids'
            );
        END IF;

END Get_customer_info_ids;
--ER7675548

-- Added new API for 12355310
FUNCTION Shipping_Interfaced_Status
(
p_line_id NUMBER
) RETURN VARCHAR2
IS
l_delivery_detail_count NUMBER;

BEGIN

    SELECT count(1)
    INTO   l_delivery_detail_count
    FROM   wsh_delivery_details
    WHERE  source_code = 'OE'
    AND    source_line_id = p_line_id
    AND    released_status NOT IN ('C','D');

    IF l_delivery_detail_count > 0 THEN
        RETURN 'Y';
    ELSE
	    RETURN 'N';
	END IF;

END Shipping_Interfaced_Status;

END oe_line_util;

/
