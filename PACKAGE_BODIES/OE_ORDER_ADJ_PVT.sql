--------------------------------------------------------
--  DDL for Package Body OE_ORDER_ADJ_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_ORDER_ADJ_PVT" AS
/* $Header: OEXVADJB.pls 120.13.12010000.13 2009/10/03 16:13:38 smanian ship $ */

G_DEBUG BOOLEAN;
G_Pricing_Phase_Id_Tbl Char_Tbl_Type;
G_11iG_PERFORMANCE varchar2(1)
      := nvl(fnd_profile.value('ONT_11IG_PERFORMANCE'),'Y');
G_CHARGES_FOR_INCLUDED_ITEM Varchar2(1) := nvl(fnd_profile.value('ONT_CHARGES_FOR_INCLUDED_ITEM'),'N');
G_REQUEST_ID NUMBER:=NULL;
G_ORDER_CURRENCY VARCHAR2(30);
G_IPL_ERRORS_TBL Index_Tbl_Type;
G_BINARY_LIMIT CONSTANT NUMBER := OE_GLOBALS.G_BINARY_LIMIT; -- Added for bug 8631297


procedure Adj_Debug (p_text IN VARCHAR2, p_dummy IN NUMBER:=0) As
Begin
  If G_DEBUG Then
     oe_debug_pub.add(p_text,3);
  End If;
End;

--btea perf end


Function get_version Return Varchar2 is
Begin

 Return('/* $Header: OEXVADJB.pls 120.13.12010000.13 2009/10/03 16:13:38 smanian ship $ */');

End;

-- BLANKETS: Start Code Merge, Local Functions

Function Get_List_Type (p_price_list_id in number)
Return VARCHAR2
IS
l_list_type             VARCHAR2(30);
Begin

   SELECT list_type_code
     INTO l_list_type
     FROM QP_LIST_HEADERS
    WHERE LIST_HEADER_ID = p_price_list_id;

  RETURN l_list_type;

Exception
  WHEN OTHERS THEN
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
       OE_MSG_PUB.Add_Exc_Msg
           (   G_PKG_NAME
            ,   'Get_List_Type'
           );
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
End Get_List_Type;

Function Get_Enforce_Price_List
       (p_blanket_number in number
        ,p_blanket_line_number in number)
Return VARCHAR2
IS
l_flag             VARCHAR2(1);
Begin

   SELECT enforce_price_list_flag
     INTO l_flag
     FROM OE_BLANKET_LINES_EXT E
    WHERE E.ORDER_NUMBER = p_blanket_number
      AND E.LINE_NUMBER = p_blanket_line_number;

  RETURN l_flag;

Exception
  WHEN OTHERS THEN
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
       OE_MSG_PUB.Add_Exc_Msg
           (   G_PKG_NAME
            ,   'Get_Enforce_Price_List'
           );
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
End Get_Enforce_Price_List;

-- BLANKETS: End Code Merge, Local Functions


--As per discussion with AMY and RAVI
--If error occurs from pricing engine we need to look at pricing temp table
--copy the temp table unit selling price to the line
Procedure Reset_Fields(p_line_rec in Oe_Order_Pub.Line_Rec_Type)As

Cursor get_price(p_line_id in Number) is
Select Unit_Price,
       Adjusted_Unit_Price,
       priced_quantity,
       priced_uom_code
From   QP_PREQ_LINES_TMP
Where  Line_Id = p_line_id;

Cursor c_line(p_line_id in Number) is
Select line_id,
       blanket_number,
       blanket_line_number,
       unit_selling_price,
       ordered_quantity,
       order_quantity_uom,
       inventory_item_id,
       line_set_id,
       fulfilled_flag,
       header_id,
       line_category_code,
       commitment_id,
       transaction_phase_code --for bug 3108881
From   OE_ORDER_LINES
Where  Line_Id = p_line_id;

l_qp_unit_price          Number;
l_qp_adjusted_unit_price Number;
l_pricing_quantity       Number;
l_pricing_quantity_uom   Varchar2(15);
l_unit_price Number;
l_selling_price Number;
l_tax_value              Number;

l_return_status          Varchar2(30);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--

Begin
  oe_debug_pub.add('Entering Reset Field:line_id:'||(p_line_rec.line_id));
  open get_price(p_line_rec.line_id);
  fetch get_price into l_qp_unit_price,
                       l_qp_adjusted_unit_price,
                       l_pricing_quantity,
                       l_pricing_quantity_uom;
  close get_price;

  If l_qp_adjusted_unit_price is not null OR
     l_qp_unit_price is not null Then
    If nvl(p_line_rec.ordered_quantity,0) <> 0 Then
      If OE_CODE_CONTROL.Get_Code_Release_Level >= '110509' THEN
        l_unit_price := Null;
        l_selling_price := Null;
        l_qp_unit_price := Null;
        l_qp_adjusted_unit_price := Null;
      else
     l_unit_price :=
      (l_qp_unit_price * p_line_rec.pricing_quantity)/ p_line_rec.ordered_quantity;
     l_selling_price :=
      (l_qp_adjusted_unit_price * p_line_rec.pricing_quantity)/ p_line_rec.ordered_quantity;
      end if;
    Else
     l_unit_price := Null;
     l_selling_price := Null;
    End If;

  End If;

  -- Bug 2757443, need to set tax value accordingly if unit selling
  -- price gets set to null.
  IF l_selling_price is null THEN
     l_tax_value := null;
  ELSE
     l_tax_value := p_line_rec.tax_value;
  END IF;

  -- BUG 2746595 => if a valid price list is not found when currency is updated,
  -- the price list and price is nulled out in this procedure. This should log
  -- a request to update the total released amount on the blanket.
  -- BLANKETS: log request to update blanket amounts if price changes
  IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110509'
  THEN

    FOR update_line IN c_line(p_line_rec.line_id) LOOP

      IF update_line.line_category_code = 'ORDER'
         AND update_line.blanket_number IS NOT NULL
      THEN

       IF l_debug_level > 0 THEN
          oe_debug_pub.add('OEXVADJB log blanket request');
          oe_debug_pub.add('old SP :'||update_line.unit_selling_price);
          oe_debug_pub.add('new SP :'||l_selling_price);
       END IF;

       OE_Order_Cache.Load_Order_Header(update_line.header_id);
--for bug 3108881.Log the request for Orders only
       IF nvl(update_line.transaction_phase_code,'F') = 'F' THEN

	       OE_Delayed_Requests_Pvt.Log_Request
	       (p_entity_code               => OE_GLOBALS.G_ENTITY_ALL
      	 	,p_entity_id                 => update_line.line_id
       		,p_requesting_entity_code    => OE_GLOBALS.G_ENTITY_LINE
       		,p_requesting_entity_id      => update_line.line_id
       		,p_request_type              => OE_GLOBALS.G_PROCESS_RELEASE
       		-- Old values
       		,p_param1                    => update_line.blanket_number
       		,p_param2                    => update_line.blanket_line_number
       		,p_param3                    => update_line.ordered_quantity
       		,p_param4                    => update_line.order_quantity_uom
       		,p_param5                    => update_line.unit_selling_price
       		,p_param6                    => update_line.inventory_item_id
       		-- New values
       		,p_param11                   => update_line.blanket_number
       		,p_param12                   => update_line.blanket_line_number
       		,p_param13                   => update_line.ordered_quantity
       		,p_param14                   => update_line.order_quantity_uom
       		,p_param15                   => l_selling_price
       		,p_param16                   => update_line.inventory_item_id
       		-- Other parameters
       		,p_param8                    => update_line.fulfilled_flag
       		,p_param9                    => update_line.line_set_id
       		,p_request_unique_key1       =>
                        OE_Order_Cache.g_header_rec.transactional_curr_code
       		,x_return_status             => l_return_status
       		);

		IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       		ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
       		   RAISE FND_API.G_EXC_ERROR;
       		END IF;

       		IF update_line.line_set_id IS NOT NULL THEN
         		OE_Delayed_Requests_Pvt.Log_Request
         		  (p_entity_code               => OE_GLOBALS.G_ENTITY_ALL
         		  ,p_entity_id                 => update_line.line_set_id
         		  ,p_requesting_entity_code    => OE_GLOBALS.G_ENTITY_LINE
         		  ,p_requesting_entity_id      => update_line.line_id
         		  ,p_request_type              => 'VALIDATE_RELEASE_SHIPMENTS'
         		  ,p_request_unique_key1       => update_line.blanket_number
         		  ,p_request_unique_key2       => update_line.blanket_line_number
         		  ,p_param1                    =>
                        	OE_Order_Cache.g_header_rec.transactional_curr_code
         		  ,x_return_status             => l_return_status
         		  );
         		IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
              		   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         	  	ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
              	   	   RAISE FND_API.G_EXC_ERROR;
           		END IF;
       		END IF;
	END IF;--End of check for order/quote

      END IF; -- End of log blanket request for release order line

      -- bug 2757443.
      IF update_line.commitment_id IS NOT NULL
         AND OE_Commitment_Pvt.Do_Commitment_Sequencing THEN

           oe_debug_pub.add('Logging delayed request for Commitment.', 2);
           OE_Delayed_Requests_Pvt.Log_Request(
           p_entity_code                => OE_GLOBALS.G_ENTITY_LINE,
           p_entity_id                  => update_line.line_id,
           p_requesting_entity_code     => OE_GLOBALS.G_ENTITY_LINE,
           p_requesting_entity_id       => update_line.line_id,
           p_request_type               => OE_GLOBALS.G_CALCULATE_COMMITMENT,
           x_return_status              => l_return_status);

      END IF;


    END LOOP; -- End of loop to fetch line fields

  END IF; -- End of check for code release level

  Update Oe_Order_Lines
  Set    Unit_Selling_Price= l_selling_price,
         Unit_List_Price = l_unit_price,
         unit_selling_price_per_pqty = l_qp_adjusted_unit_price,
         unit_list_price_per_pqty = l_qp_unit_price,
         pricing_quantity         = l_pricing_quantity,
         pricing_quantity_uom     = l_pricing_quantity_uom,
         tax_value                = l_tax_value,
         lock_control             = lock_control +1
  Where  Line_id = p_line_rec.line_id;

  --Delete all related adjustments
  oe_line_adj_util.delete_row(p_line_id => p_line_rec.line_id);

  --set cascade flag to reflect changes.
  OE_GLOBALS.G_CASCADING_REQUEST_LOGGED := TRUE;
  Oe_Debug_Pub.add('Leaving reset_fields');
Exception When Others Then
  Oe_Debug_Pub.add('In procedure reset_fields:'||SQLERRM);
End;


Function Get_List_Lines (p_line_id Number) Return Varchar2 As
 Cursor list_lines_no is
 Select c.name,
        a.list_line_no
 From   qp_preq_ldets_tmp a,
        qp_preq_lines_tmp b,
        qp_list_headers_vl c
 Where  b.line_id = p_line_id
 And    b.line_index = a.line_index
 And    a.created_from_list_header_id = c.list_header_id
 And    a.automatic_flag = 'Y'
 And    a.pricing_status_code = 'N'
 And    a.created_from_list_line_type <> 'PLL';

 l_list_line_nos Varchar2(2000):=' ';
 l_sperator Varchar2(1):='';
Begin
 For i in List_Lines_no Loop
   l_list_line_nos := i.name||':'||i.list_line_no||l_sperator||l_list_line_nos;
   l_sperator := ',';
 End Loop;
 Return l_list_line_nos;
End;


PROCEDURE Header_Adjs
(   p_init_msg_list                 IN VARCHAR2:=FND_API.G_FALSE
,   p_validation_level              IN  NUMBER
,   p_control_rec                   IN  OE_GLOBALS.Control_Rec_Type
,   p_x_Header_Adj_tbl              IN OUT NOCOPY  OE_Order_PUB.Header_Adj_Tbl_Type
,   p_x_old_Header_Adj_tbl          IN OUT NOCOPY  OE_Order_PUB.Header_Adj_Tbl_Type
)
IS
l_return_status               VARCHAR2(1);
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_Header_Adj_rec              OE_Order_PUB.Header_Adj_Rec_Type;
l_old_Header_Adj_rec          OE_Order_PUB.Header_Adj_Rec_Type;
-- local variables to store OUT parameters from security check procedures
l_sec_result            NUMBER;
l_on_operation_action   NUMBER;
I 				    pls_integer; -- Used as index for while loop
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
  l_order_source_id           NUMBER;
  l_orig_sys_document_ref     VARCHAR2(50);
  l_change_sequence           VARCHAR2(50);
  l_source_document_type_id   NUMBER;
  l_source_document_id        NUMBER;

BEGIN

    IF l_debug_level > 0 THEN
      G_DEBUG:=TRUE;
    END IF;

    oe_order_pvt.set_recursion_mode(p_Entity_Code => 3,
                                   p_In_out  => 1);

    IF FND_API.to_Boolean(p_init_msg_list) THEN
        OE_MSG_PUB.initialize;
    END IF;

IF l_control_rec.Process_Partial THEN
SAVEPOINT Header_Adjs;
END IF;

    --  Init local table variables.

    adj_debug('Entering oe_order_Adj_pvt.HEADER_ADJS', 1);


--    FOR I IN 1..p_x_Header_Adj_tbl.COUNT LOOP

    I := p_x_header_adj_tbl.FIRST;

    WHILE I IS NOT NULL LOOP
    BEGIN

        --  Load local records.

        l_Header_Adj_rec := p_x_header_adj_tbl(I);

        IF p_x_old_Header_Adj_tbl.EXISTS(I) THEN
            l_old_Header_Adj_rec := p_x_old_Header_Adj_tbl(I);
        ELSE
            l_old_Header_Adj_rec := OE_Order_PUB.G_MISS_HEADER_ADJ_REC;
        END IF;

    if l_old_header_adj_rec.price_adjustment_id = FND_API.G_MISS_NUM  then

      IF l_header_adj_rec.header_Id IS NOT NULL AND
         l_header_adj_rec.header_Id <> FND_API.G_MISS_NUM THEN
           BEGIN
               IF l_debug_level  > 0 THEN
                  oe_debug_pub.add('Getting reference data for header_id:'||l_header_adj_rec.header_Id);
               END IF;
               SELECT order_source_id, orig_sys_document_ref, change_sequence,
               source_document_type_id, source_document_id
               INTO l_order_source_id, l_orig_sys_document_ref, l_change_sequence,
               l_source_document_type_id, l_source_document_id
               FROM   OE_ORDER_HEADERS_ALL
               WHERE  header_id = l_header_adj_rec.header_Id;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                   l_order_source_id := null;
                   l_orig_sys_document_ref := null;
                   l_change_sequence := null;
                   l_source_document_type_id := null;
                   l_source_document_id := null;
               WHEN OTHERS THEN
                   l_order_source_id := null;
                   l_orig_sys_document_ref := null;
                   l_change_sequence := null;
                   l_source_document_type_id := null;
                   l_source_document_id := null;
            END;
      END IF;

      OE_MSG_PUB.set_msg_context(
	 p_entity_code			=> 'HEADER_ADJ'
  	,p_entity_id         		=> l_header_adj_rec.price_adjustment_id
    	,p_header_id         		=> l_header_adj_rec.header_Id
        ,p_line_id                      => null
        ,p_order_source_id              => l_order_source_id
        ,p_orig_sys_document_ref        => l_orig_sys_document_ref
        ,p_orig_sys_document_line_ref   => null
        ,p_change_sequence              => l_change_sequence
        ,p_source_document_type_id      => l_source_document_type_id
        ,p_source_document_id           => l_source_document_id
        ,p_source_document_line_id      => null );

    else

      IF l_old_header_adj_rec.header_Id IS NOT NULL AND
         l_old_header_adj_rec.header_Id <> FND_API.G_MISS_NUM THEN

            BEGIN
               IF l_debug_level  > 0 THEN
                  oe_debug_pub.add('Getting reference data for old header_id:'||l_old_header_adj_rec.header_id);
               END IF;
               SELECT order_source_id, orig_sys_document_ref, change_sequence,
               source_document_type_id, source_document_id
               INTO l_order_source_id, l_orig_sys_document_ref, l_change_sequence,
               l_source_document_type_id, l_source_document_id
               FROM   OE_ORDER_HEADERS_ALL
               WHERE  header_id = l_old_header_adj_rec.header_id;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                   l_order_source_id := null;
                   l_orig_sys_document_ref := null;
                   l_change_sequence := null;
                   l_source_document_type_id := null;
                   l_source_document_id := null;
               WHEN OTHERS THEN
                   l_order_source_id := null;
                   l_orig_sys_document_ref := null;
                   l_change_sequence := null;
                   l_source_document_type_id := null;
                   l_source_document_id := null;
            END;
      END IF;

      OE_MSG_PUB.set_msg_context(
	 p_entity_code			=> 'HEADER_ADJ'
  	,p_entity_id         		=> l_old_header_adj_rec.price_adjustment_id
    	,p_header_id         		=> l_old_header_adj_rec.header_Id
        ,p_line_id                      => null
        ,p_order_source_id              => l_order_source_id
        ,p_orig_sys_document_ref        => l_orig_sys_document_ref
        ,p_orig_sys_document_line_ref   => null
        ,p_change_sequence              => l_change_sequence
        ,p_source_document_type_id      => l_source_document_type_id
        ,p_source_document_id           => l_source_document_id
        ,p_source_document_line_id      => null );

    end if;

        --  Load API control record

        l_control_rec := OE_GLOBALS.Init_Control_Rec
        (   p_operation     => l_Header_Adj_rec.operation
        ,   p_control_rec   => p_control_rec
        );

        --  Set record return status.

        l_Header_Adj_rec.return_status := FND_API.G_RET_STS_SUCCESS;
        p_x_Header_Adj_tbl(I).return_status := FND_API.G_RET_STS_SUCCESS;

        --  Prepare record.

        IF l_Header_Adj_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN

            l_Header_Adj_rec.db_flag := FND_API.G_FALSE;

            --  Set missing old record elements to NULL.

   		 adj_debug('Entering OE_Header_Adj_Util.Convert_Miss_To_Null', 1);
          /* change to nocopy procedure
            l_old_Header_Adj_rec :=
            OE_Header_Adj_Util.Convert_Miss_To_Null (l_old_Header_Adj_rec);
           */
            OE_Header_Adj_Util.Convert_Miss_To_Null(l_old_Header_Adj_rec);

        ELSIF l_Header_Adj_rec.operation = OE_GLOBALS.G_OPR_UPDATE
        OR    l_Header_Adj_rec.operation = OE_GLOBALS.G_OPR_DELETE
        THEN

            l_Header_Adj_rec.db_flag := FND_API.G_TRUE;

            --  Query Old if missing

            IF  l_old_Header_Adj_rec.price_adjustment_id = FND_API.G_MISS_NUM
              OR l_old_Header_Adj_rec.price_adjustment_id IS NULL
            THEN

                OE_Header_Adj_Util.Query_Row
                (   p_price_adjustment_id         => l_Header_Adj_rec.price_adjustment_id
                ,   x_Header_Adj_Rec              => l_old_Header_Adj_rec
                );
                  p_x_old_Header_Adj_tbl(I) := l_old_Header_Adj_rec;

            ELSE

                --  Set missing old record elements to NULL.

--                l_old_Header_Adj_rec :=
                OE_Header_Adj_Util.Convert_Miss_To_Null (l_old_Header_Adj_rec);

            END IF;

            --  Complete new record from old

--            l_Header_Adj_rec :=
            OE_Header_Adj_Util.Complete_Record
            (   p_x_Header_Adj_rec              => l_Header_Adj_rec
            ,   p_old_Header_Adj_rec          => l_old_Header_Adj_rec
            );

      	   OE_MSG_PUB.update_msg_context(
	 	 p_entity_code			=> 'HEADER_ADJ'
  		,p_entity_id         		=> l_header_adj_rec.price_adjustment_id
    		,p_header_id         		=> l_header_adj_rec.header_Id);

        END IF;

        IF I = p_x_header_adj_tbl.FIRST THEN
	       IF NOT oe_order_pvt.Valid_Upgraded_Order(l_header_adj_rec.header_id) THEN
                 RAISE FND_API.G_EXC_ERROR;
            END IF;
        END IF;

   -- Check security
   IF l_control_rec.check_security
      AND (l_header_adj_rec.operation = OE_GLOBALS.G_OPR_CREATE
         OR l_header_adj_rec.operation = OE_GLOBALS.G_OPR_UPDATE)
   THEN

        adj_debug('Check Attributes Security');
        -- check if this operation is allowed
        -- on all the changed attributes
           OE_Header_Adj_Security.Attributes
                (p_header_adj_rec   	=> l_header_adj_rec
                , p_old_header_adj_rec	=> l_old_header_adj_rec
                , x_result      	=> l_sec_result
                , x_return_status 	=> l_return_status
                );

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

           IF l_sec_result = OE_PC_GLOBALS.YES THEN
                RAISE FND_API.G_EXC_ERROR;
           END IF;

    END IF;

        --  Attribute level validation.

            IF p_validation_level > FND_API.G_VALID_LEVEL_NONE THEN

                OE_Validate_Header_Adj.Attributes
                (   x_return_status               => l_return_status
                ,   p_Header_Adj_rec              => l_Header_Adj_rec
                ,   p_old_Header_Adj_rec          => l_old_Header_Adj_rec
                );

                IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                    RAISE FND_API.G_EXC_ERROR;
                END IF;

            END IF;


            --  Clear dependent attributes.

        IF  l_control_rec.clear_dependents THEN

            OE_Header_Adj_Util.Clear_Dependent_Attr
            (   p_x_Header_Adj_rec              => l_Header_Adj_rec
            ,   p_old_Header_Adj_rec          => l_old_Header_Adj_rec
            --,   x_Header_Adj_rec              => l_Header_Adj_rec
            );

        END IF;

        --  Default missing attributes

        IF  l_control_rec.default_attributes
        THEN

           OE_Default_Header_Adj.Attributes
            (   p_x_Header_Adj_rec              => l_Header_Adj_rec
            ,   p_old_header_adj_rec	      => l_old_header_adj_rec
            --,   x_Header_Adj_rec              => l_Header_Adj_rec
            );
		  null;

        END IF;

        --  Apply attribute changes

        IF  l_control_rec.change_attributes
        THEN

	   -- This will also log request/s to check duplicity of
	   -- price adjustment entered
            OE_Header_Adj_Util.Apply_Attribute_Changes
            (   p_x_Header_Adj_rec              => l_Header_Adj_rec
            ,   p_old_Header_Adj_rec          => l_old_Header_Adj_rec
            --,   x_Header_Adj_rec              => l_Header_Adj_rec
            );

        END IF;

	-- If there has any activity causing a change in any attribute
	-- log a request for repricing

        --  Entity level validation.

        IF l_control_rec.validate_entity THEN

            IF l_Header_Adj_rec.operation = OE_GLOBALS.G_OPR_DELETE THEN

                OE_Validate_Header_Adj.Entity_Delete
                (   x_return_status               => l_return_status
                ,   p_Header_Adj_rec              => l_Header_Adj_rec
                );

            ELSE

                OE_Validate_Header_Adj.Entity
                (   x_return_status               => l_return_status
                ,   p_Header_Adj_rec              => l_Header_Adj_rec
                ,   p_old_Header_Adj_rec          => l_old_Header_Adj_rec
                );

            END IF;

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

        END IF;

    -- Check entity level security again as some attributes
    -- may have changed due to defaulting.
    --IF l_control_rec.check_security THEN
    --bug5467785
    IF NOT (l_Header_Adj_rec.operation = OE_GLOBALS.G_OPR_UPDATE
               AND OE_Header_Adj_Security.g_check_all_cols_constraint = 'Y')
    AND  l_control_rec.check_security THEN

        adj_debug('Check Entity Security');

           OE_Header_Adj_Security.Entity
                (p_header_adj_rec   	=> l_header_adj_rec
                , x_result      	=> l_sec_result
                , x_return_status 	=> l_return_status
                );

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

           IF l_sec_result = OE_PC_GLOBALS.YES THEN
                RAISE FND_API.G_EXC_ERROR;
           END IF;

    END IF;

        --  Step 4. Write to DB

        IF l_control_rec.write_to_db THEN

           /* Start AuditTrail */
           OE_DEBUG_PUB.add('OEXVADJB:calling to insert audit history reason for header adj in pre_write_process', 2);

	       Oe_Header_ADJ_Util.Pre_Write_Process
		    (p_x_header_adj_rec => l_header_adj_rec,
			p_old_header_adj_rec => l_old_header_adj_rec);

           oe_debug_pub.add('OEXVADJB:After calling to insert audit history');
           /* End AuditTrail */

            IF l_Header_Adj_rec.operation = OE_GLOBALS.G_OPR_DELETE THEN

                OE_Header_Adj_Util.Delete_Row
                (   p_price_adjustment_id         => l_Header_Adj_rec.price_adjustment_id
                );

		-- Log a delayed request to cause repricing due to deleted
		-- record
		-- NOTE: Requesting entity is header, not header adj. as the adj. itself
		-- has been deleted and this request should be deleted when the order is
		-- deleted. Should be revisited if the entity logged against is changed
		-- to header.
		  	IF OE_Globals.G_RECURSION_MODE <> 'Y' AND
			   l_header_adj_rec.list_line_type_code NOT IN ('COST','TAX')
		     then

			        adj_debug('Log header level PRICE_ADJ');
		    	 	oe_delayed_requests_pvt.log_request(p_entity_code     => OE_GLOBALS.G_ENTITY_ALL,
					p_entity_id              => l_header_adj_rec.Header_id,
					p_requesting_entity_code => OE_GLOBALS.G_ENTITY_HEADER,
					p_requesting_entity_id   => l_header_adj_rec.HEader_id,
					p_request_type           => OE_GLOBALS.G_PRICE_ADJ,
					x_return_status          => l_return_status);
			End If;

		IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		 ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
		   RAISE FND_API.G_EXC_ERROR;
		END IF;

            ELSE

                --  Get Who Information

                l_Header_Adj_rec.last_update_date := SYSDATE;
                l_Header_Adj_rec.last_updated_by := FND_GLOBAL.USER_ID;
                l_Header_Adj_rec.last_update_login := FND_GLOBAL.LOGIN_ID;

                IF l_Header_Adj_rec.operation = OE_GLOBALS.G_OPR_UPDATE THEN

                    OE_Header_Adj_Util.Update_Row (l_Header_Adj_rec);

                ELSIF l_Header_Adj_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN

                    l_Header_Adj_rec.creation_date := SYSDATE;
                    l_Header_Adj_rec.created_by    := FND_GLOBAL.USER_ID;

                    OE_Header_Adj_Util.Insert_Row (l_Header_Adj_rec);

                END IF;

            END IF;

        END IF;

        --  Load tables.

        p_x_header_adj_tbl(I)            := l_Header_Adj_rec;
        p_x_old_Header_Adj_tbl(I)        := l_old_Header_Adj_rec;

         IF l_header_adj_rec.return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         ELSIF l_header_adj_rec.return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
         END IF;

    OE_Header_Adj_Security.g_check_all_cols_constraint := 'Y';
        OE_MSG_PUB.reset_msg_context('HEADER_ADJ');
    --   loop exception handler.




    --
-- Start : Changes made as a part of DBI ER # 4185227
--
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'CALLING OE_DBI_UTIL FOR HEADER PRICE ADJUSTMENTS' , 1 ) ;
        oe_debug_pub.add(  'CACHED VALUE' || OE_ORDER_CACHE.G_HEADER_REC.BOOKED_FLAG ) ;
        oe_debug_pub.add(  'RECURSION VALUE' || OE_ORDER_UTIL.G_RECURSION_WITHOUT_EXCEPTION ) ;
        oe_debug_pub.add(  'PROFILE VALUE' || FND_PROFILE.VALUE ( 'ONT_DBI_INSTALLED' ) ) ;
    END IF;

    IF  NVL(FND_PROFILE.VALUE('ONT_DBI_INSTALLED'), 'N') = 'Y' AND
        oe_order_cache.g_header_rec.booked_flag = 'Y' AND
        oe_order_util.g_recursion_without_exception = 'N' AND
        l_control_rec.write_to_db
    THEN

      OE_DBI_UTIL.Update_DBI_Log( x_return_status  => l_return_status);

     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     END IF;
    END IF;

--
-- End : Changes made as a part of DBI ER # 4185227
--


    EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN

            l_Header_Adj_rec.return_status := FND_API.G_RET_STS_ERROR;
            p_x_header_adj_tbl(I)            := l_Header_Adj_rec;
            p_x_old_Header_Adj_tbl(I)        := l_old_Header_Adj_rec;
    	    OE_Header_Adj_Security.g_check_all_cols_constraint := 'Y';
            OE_MSG_PUB.reset_msg_context('HEADER_ADJ');
oe_delayed_requests_pvt.delete_request(p_entity_code =>OE_GLOBALS.G_ENTITY_HEADER_ADJ,
		  	   p_entity_id => l_header_adj_rec.Price_adjustment_id,
	                   p_request_type => NULL,
	                   x_return_status => l_return_status);
		IF l_control_rec.Process_Partial THEN
			ROLLBACK TO SAVEPOINT Header_Adjs;
		ELSE
                RAISE FND_API.G_EXC_ERROR;
	        END IF;


        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

            l_Header_Adj_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            p_x_header_adj_tbl(I)            := l_Header_Adj_rec;
            p_x_old_Header_Adj_tbl(I)        := l_old_Header_Adj_rec;
    	    OE_Header_Adj_Security.g_check_all_cols_constraint := 'Y';
            OE_MSG_PUB.reset_msg_context('HEADER_ADJ');
oe_delayed_requests_pvt.delete_request(p_entity_code =>OE_GLOBALS.G_ENTITY_HEADER_ADJ,
		  	   p_entity_id => l_header_adj_rec.Price_adjustment_id,
	                   p_request_type => NULL,
	                   x_return_status => l_return_status);
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        WHEN OTHERS THEN

            l_Header_Adj_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            p_x_header_adj_tbl(I)            := l_Header_Adj_rec;
            p_x_old_Header_Adj_tbl(I)        := l_old_Header_Adj_rec;
    	    OE_Header_Adj_Security.g_check_all_cols_constraint := 'Y';
oe_delayed_requests_pvt.delete_request(p_entity_code =>OE_GLOBALS.G_ENTITY_HEADER_ADJ,
		  	   p_entity_id => l_header_adj_rec.Price_adjustment_id,
	                   p_request_type => NULL,
	                   x_return_status => l_return_status);

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                OE_MSG_PUB.Add_Exc_Msg
                (   G_PKG_NAME
                ,   'Header_Adjs'
                );
            END IF;

            OE_MSG_PUB.reset_msg_context('HEADER_ADJ');
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END;
    I := p_x_header_adj_tbl.NEXT(I);
    END LOOP;

    --  Load OUT parameters

      adj_debug('Exiting oe_order_Adj_pvt.HEADER_ADJS', 1);
      OE_MSG_PUB.reset_msg_context('HEADER_ADJ');

      oe_order_pvt.set_recursion_mode(p_Entity_Code => 3,
                                   p_In_out  => 0);

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      oe_order_pvt.set_recursion_mode(p_Entity_Code => 3,
                                   p_In_out  => 0);

      OE_MSG_PUB.reset_msg_context('HEADER_ADJ');
      RAISE;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      oe_order_pvt.set_recursion_mode(p_Entity_Code => 3,
                                   p_In_out  => 0);

      OE_MSG_PUB.reset_msg_context('HEADER_ADJ');
      RAISE;

    WHEN OTHERS THEN
      oe_order_pvt.set_recursion_mode(p_Entity_Code => 3,
                                   p_In_out  => 0);

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Header_Adjs'
            );
        END IF;


        OE_MSG_PUB.reset_msg_context('HEADER_ADJ');
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Header_Adjs;

--  Line_Adjs

PROCEDURE Line_Adjs
(   p_init_msg_list                 IN VARCHAR2 := FND_API.G_FALSE
,   p_validation_level              IN  NUMBER
,   p_control_rec                   IN  OE_GLOBALS.Control_Rec_Type
,   p_x_Line_Adj_tbl                IN OUT NOCOPY  OE_Order_PUB.Line_Adj_Tbl_Type
,   p_x_old_Line_Adj_tbl            IN OUT NOCOPY  OE_Order_PUB.Line_Adj_Tbl_Type
)
IS
l_return_status               VARCHAR2(1);
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_Line_Adj_rec                OE_Order_PUB.Line_Adj_Rec_Type;
l_old_Line_Adj_rec            OE_Order_PUB.Line_Adj_Rec_Type;
-- local variables to store OUT parameters from security check procedures
l_sec_result            NUMBER;
l_on_operation_action   NUMBER;
I                       pls_integer; -- Used as table index for the loop.
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
l_last_line_id  Number;    --bug 2721485
l_line_found  Varchar2(1); --bug 2721485

l_order_source_id           NUMBER;
l_orig_sys_document_ref     VARCHAR2(50);
l_orig_sys_line_ref     VARCHAR2(50);
l_orig_sys_shipment_ref     VARCHAR2(50);
l_change_sequence           VARCHAR2(50);
l_source_document_type_id   NUMBER;
l_source_document_id        NUMBER;
l_source_document_line_id        NUMBER;
l_line_temp_rec  OE_Order_PUB.Line_Rec_Type;

BEGIN

 IF l_debug_level > 0 THEN
   G_DEBUG := TRUE;
 END IF;

    adj_debug('Entering oe_order_Adj_pvt.LINE_ADJS', 1);
    oe_order_pvt.set_recursion_mode(p_Entity_Code => 6,
                                   p_In_out  => 1);

    IF FND_API.to_Boolean(p_init_msg_list) THEN
        OE_MSG_PUB.initialize;
    END IF;

IF l_control_rec.Process_Partial THEN
SAVEPOINT Line_Adjs;
END IF;


--    FOR I IN 1..p_x_Line_Adj_tbl.COUNT LOOP

    I := p_x_Line_Adj_tbl.FIRST;

    WHILE I IS NOT NULL LOOP
    BEGIN

        --  Load local records.

        l_Line_Adj_rec := p_x_Line_Adj_tbl(I);

	   adj_debug('price_adj_id :'||l_line_adj_rec.price_adjustment_id,3);
	   adj_debug('operation is  :'||l_line_adj_rec.operation,3);

        IF p_x_old_Line_Adj_tbl.EXISTS(I) THEN
            l_old_Line_Adj_rec := p_x_old_Line_Adj_tbl(I);
        ELSE
            l_old_Line_Adj_rec := OE_Order_PUB.G_MISS_LINE_ADJ_REC;
        END IF;

        if l_old_line_Adj_rec.price_adjustment_id = FND_API.G_MISS_NUM then

           IF l_line_adj_rec.line_id IS NOT NULL AND
              l_line_adj_rec.line_id <> FND_API.G_MISS_NUM THEN
              BEGIN
               IF l_debug_level  > 0 THEN
                  oe_debug_pub.add('Getting reference data for line_id:'||l_line_adj_rec.line_id);
               END IF;
               SELECT order_source_id, orig_sys_document_ref, change_sequence,
               source_document_type_id, source_document_id, orig_sys_line_ref,
               source_document_line_id, orig_sys_shipment_ref
               INTO l_order_source_id, l_orig_sys_document_ref, l_change_sequence,
               l_source_document_type_id, l_source_document_id, l_orig_sys_line_ref,
               l_source_document_line_id, l_orig_sys_shipment_ref
               FROM   OE_ORDER_LINES_ALL
               WHERE  line_id = l_line_adj_rec.line_id;
              EXCEPTION
               WHEN NO_DATA_FOUND THEN
                   l_order_source_id := null;
                   l_orig_sys_document_ref := null;
                   l_change_sequence := null;
                   l_source_document_type_id := null;
                   l_source_document_id := null;
                   l_orig_sys_line_ref := null;
                   l_source_document_line_id := null;
                   l_orig_sys_shipment_ref := null;
               WHEN OTHERS THEN
                   l_order_source_id := null;
                   l_orig_sys_document_ref := null;
                   l_change_sequence := null;
                   l_source_document_type_id := null;
                   l_source_document_id := null;
                   l_orig_sys_line_ref := null;
                   l_source_document_line_id := null;
                   l_orig_sys_shipment_ref := null;
              END;
           END IF;

           OE_MSG_PUB.set_msg_context(
		 p_entity_code			=> 'LINE_ADJ'
  		,p_entity_id         		=> l_line_adj_rec.price_adjustment_id
    		,p_header_id         		=> l_line_adj_rec.header_id
    		,p_line_id           		=> l_line_adj_rec.line_id
                ,p_order_source_id              => l_order_source_id
                ,p_orig_sys_document_ref        => l_orig_sys_document_ref
                ,p_orig_sys_document_line_ref   => l_orig_sys_line_ref
                ,p_orig_sys_shipment_ref        => l_orig_sys_shipment_ref
                ,p_change_sequence              => l_change_sequence
                ,p_source_document_type_id      => l_source_document_type_id
                ,p_source_document_id           => l_source_document_id
                ,p_source_document_line_id      => l_source_document_line_id );

        else

           IF l_old_line_adj_rec.line_id IS NOT NULL AND
              l_old_line_adj_rec.line_id <> FND_API.G_MISS_NUM THEN
              BEGIN
               IF l_debug_level  > 0 THEN
                  oe_debug_pub.add('Getting reference data for old line_id:'||l_old_line_adj_rec.line_id);
               END IF;
               SELECT order_source_id, orig_sys_document_ref, change_sequence,
               source_document_type_id, source_document_id, orig_sys_line_ref,
               source_document_line_id, orig_sys_shipment_ref
               INTO l_order_source_id, l_orig_sys_document_ref, l_change_sequence,
               l_source_document_type_id, l_source_document_id, l_orig_sys_line_ref,
               l_source_document_line_id, l_orig_sys_shipment_ref
               FROM   OE_ORDER_LINES_ALL
               WHERE  line_id = l_old_line_adj_rec.line_id;
              EXCEPTION
               WHEN NO_DATA_FOUND THEN
                   l_order_source_id := null;
                   l_orig_sys_document_ref := null;
                   l_change_sequence := null;
                   l_source_document_type_id := null;
                   l_source_document_id := null;
                   l_orig_sys_line_ref := null;
                   l_source_document_line_id := null;
                   l_orig_sys_shipment_ref := null;
               WHEN OTHERS THEN
                   l_order_source_id := null;
                   l_orig_sys_document_ref := null;
                   l_change_sequence := null;
                   l_source_document_type_id := null;
                   l_source_document_id := null;
                   l_orig_sys_line_ref := null;
                   l_source_document_line_id := null;
                   l_orig_sys_shipment_ref := null;
              END;
           END IF;

           OE_MSG_PUB.set_msg_context(
		 p_entity_code			=> 'LINE_ADJ'
  		,p_entity_id         		=> l_old_line_adj_rec.price_adjustment_id
    		,p_header_id         		=> l_old_line_adj_rec.header_id
    		,p_line_id           		=> l_old_line_adj_rec.line_id
                ,p_order_source_id              => l_order_source_id
                ,p_orig_sys_document_ref        => l_orig_sys_document_ref
                ,p_orig_sys_document_line_ref   => l_orig_sys_line_ref
                ,p_orig_sys_shipment_ref        => l_orig_sys_shipment_ref
                ,p_change_sequence              => l_change_sequence
                ,p_source_document_type_id      => l_source_document_type_id
                ,p_source_document_id           => l_source_document_id
                ,p_source_document_line_id      => l_source_document_line_id );
        end if;

        --  Load API control record

        l_control_rec := OE_GLOBALS.Init_Control_Rec
        (   p_operation     => l_Line_Adj_rec.operation
        ,   p_control_rec   => p_control_rec
        );

        --  Set record return status.

        l_Line_Adj_rec.return_status   := FND_API.G_RET_STS_SUCCESS;
        p_x_line_adj_tbl(I).return_status       := FND_API.G_RET_STS_SUCCESS;

        --  Prepare record.

        IF l_Line_Adj_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN

            l_Line_Adj_rec.db_flag := FND_API.G_FALSE;

            --  Set missing old record elements to NULL.

--            l_old_Line_Adj_rec :=
            OE_Line_Adj_Util.Convert_Miss_To_Null (l_old_Line_Adj_rec);
       --bug 2721485  Begin
	 adj_debug('Line id :'||l_line_adj_rec.line_id,3);
         if OE_GLOBALS.G_PRICING_RECURSION = 'N' and
         l_line_adj_rec.line_id is not null then
          if l_last_line_id = l_line_adj_rec.line_id
          and l_line_found = 'Y' then
            null;
          elsif l_last_line_id = l_line_adj_rec.line_id
          and l_line_found = 'N' then
	   adj_debug('Line ID not found 1',3);
           GOTO line_not_in_db;
          else
           Begin
            --bug 2825766 begin
             oe_oe_form_line.get_line(p_db_record => FALSE,
                                  p_line_id => l_line_adj_rec.line_id,
                                  x_line_rec => l_line_temp_rec);
            l_last_line_id := l_line_adj_rec.line_id;
            if nvl(l_line_temp_rec.line_id,FND_API.G_MISS_NUM) <>
             FND_API.G_MISS_NUM then
               l_line_found := 'Y';
             adj_debug('Line id found:');
            else
             l_line_found := 'N';
             adj_debug('Line id not found 1:');
             GOTO line_not_in_db;
            end if;
            --bug 2825766 end
           Exception
             when others then
	     adj_debug('line adjs - others 2 ',3);
             l_line_found := 'N';
             l_last_line_id := l_line_adj_rec.line_id;
             GOTO line_not_in_db;
           end;
          end if;
         end if;
       --bug 2721485 End

        ELSIF l_Line_Adj_rec.operation = OE_GLOBALS.G_OPR_UPDATE
        OR    l_Line_Adj_rec.operation = OE_GLOBALS.G_OPR_DELETE
        THEN

            l_Line_Adj_rec.db_flag := FND_API.G_TRUE;

            --  Query Old if missing

            IF  l_old_Line_Adj_rec.price_adjustment_id = FND_API.G_MISS_NUM
                       OR l_old_Line_Adj_rec.line_id IS NULL
            THEN

                 OE_Line_Adj_Util.Query_Row
                (   p_price_adjustment_id         => l_Line_Adj_rec.price_adjustment_id
                ,   x_line_adj_rec =>                 l_old_Line_Adj_rec
                );

               p_x_old_line_adj_tbl(I) := l_old_line_adj_rec;

            ELSE

                --  Set missing old record elements to NULL.

--                l_old_Line_Adj_rec :=
                OE_Line_Adj_Util.Convert_Miss_To_Null (l_old_Line_Adj_rec);

            END IF;

            --  Complete new record from old

--            l_Line_Adj_rec :=
            OE_Line_Adj_Util.Complete_Record
            (   p_x_Line_Adj_rec                => l_Line_Adj_rec
            ,   p_old_Line_Adj_rec            => l_old_Line_Adj_rec
            );

            OE_MSG_PUB.update_msg_context(
		 p_entity_code			=> 'LINE_ADJ'
  		,p_entity_id         		=> l_line_adj_rec.price_adjustment_id
    		,p_header_id         		=> l_line_adj_rec.header_id
    		,p_line_id           		=> l_line_adj_rec.line_id);

        END IF;


        IF I = p_x_line_adj_tbl.FIRST THEN
	       IF NOT oe_order_pvt.Valid_Upgraded_Order(l_line_adj_rec.header_id) THEN
                 RAISE FND_API.G_EXC_ERROR;
            END IF;
        END IF;

   -- Check security
   IF l_control_rec.check_security
      AND (l_line_adj_rec.operation = OE_GLOBALS.G_OPR_CREATE
         OR l_line_adj_rec.operation = OE_GLOBALS.G_OPR_UPDATE)
   THEN

        adj_debug('Check Attributes Security',2);
        -- check if this operation is allowed
        -- on all the changed attributes
           OE_Line_Adj_Security.Attributes
                (p_line_Adj_rec   	=> l_line_adj_rec
                , p_old_line_adj_rec	=> l_old_line_adj_rec
                , x_result      	=> l_sec_result
                , x_return_status 	=> l_return_status
                );

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

           IF l_sec_result = OE_PC_GLOBALS.YES THEN
                RAISE FND_API.G_EXC_ERROR;
           END IF;

    END IF;

        --  Attribute level validation.

            IF p_validation_level > FND_API.G_VALID_LEVEL_NONE THEN

	       adj_debug('Before OE_Validate_Line_Adj.Attributes . ' ||
			' adj_id = '|| To_char(l_line_adj_rec.price_adjustment_id), 2);

                OE_Validate_Line_Adj.Attributes
                (   x_return_status               => l_return_status
                ,   p_Line_Adj_rec                => l_Line_Adj_rec
                ,   p_old_Line_Adj_rec            => l_old_Line_Adj_rec
                );

                IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                    RAISE FND_API.G_EXC_ERROR;
                END IF;


            END IF;


            --  Clear dependent attributes.

        IF  l_control_rec.clear_dependents THEN

            OE_Line_Adj_Util.Clear_Dependent_Attr
            (   p_x_Line_Adj_rec                => l_Line_Adj_rec
            ,   p_old_Line_Adj_rec            => l_old_Line_Adj_rec
            --,   x_Line_Adj_rec                => l_Line_Adj_rec
            );

        END IF;

        --  Default missing attributes

        IF  l_control_rec.default_attributes
        THEN

            OE_Default_Line_Adj.Attributes
            (   p_x_Line_Adj_rec                => l_Line_Adj_rec
	    ,   p_old_line_adj_rec            => l_old_line_adj_rec
            --,   x_Line_Adj_rec                => l_Line_Adj_rec
            );

/*	    adj_debug('After OE_Default_Line_Adj.Attributes . ' ||
			     'discount_id = ' || To_char(l_line_adj_rec.discount_id)
			     || ' discount_line_id = '||
			     To_char(l_line_adj_rec.discount_line_id)
			     || ' percent = '|| To_char(l_line_adj_rec.percent), 2);
*/

        END IF;

        --  Apply attribute changes

        IF  l_control_rec.change_attributes
        THEN

	   -- This will also log request/s to check duplicity/fixed_price
	   -- check of price adjustment entered
		  adj_debug('Before OE_Line_Adj_Util.Apply_Attribute_Changes ',2);
            OE_Line_Adj_Util.Apply_Attribute_Changes
            (   p_x_Line_Adj_rec                => l_Line_Adj_rec
            ,   p_old_Line_Adj_rec            => l_old_Line_Adj_rec
            --,   x_Line_Adj_rec                => l_Line_Adj_rec
            );
		  adj_debug('After OE_Line_Adj_Util.Apply_Attribute_Changes ',2);

        END IF;


	-- If there has any activity causing a change in any attribute
	-- log a request for repricing
/*	IF l_control_rec.change_attributes
	  THEN
	   oe_line_adj_util.log_adj_requests(l_return_status,
						l_line_adj_rec,
						l_old_line_adj_rec);

	   IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	      RAISE FND_API.G_EXC_ERROR;
	   END IF;

	END IF; */



        --  Entity level validation.

        IF l_control_rec.validate_entity THEN

            IF l_Line_Adj_rec.operation = OE_GLOBALS.G_OPR_DELETE THEN

                OE_Validate_Line_Adj.Entity_Delete
                (   x_return_status               => l_return_status
                ,   p_Line_Adj_rec                => l_Line_Adj_rec
                );

			 adj_debug('After OE_Validate_Line_Adj.delete ',2);
            ELSE

	       -- logs maximum percentage request check also
			 adj_debug('Before OE_Validate_Line_Adj.Entity ',2);
                OE_Validate_Line_Adj.Entity
                (   x_return_status               => l_return_status
                ,   p_Line_Adj_rec                => l_Line_Adj_rec
                ,   p_old_Line_Adj_rec            => l_old_Line_Adj_rec
                );
			 adj_debug('After OE_Validate_Line_Adj.Entity ',2);

            END IF;

		  adj_debug('Stt '||l_return_status,3);
            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

        END IF;
		adj_debug('Before Check_security..',2);

    -- Check entity level security again as some attributes
    -- may have changed due to defaulting.
    IF l_control_rec.check_security THEN

        adj_debug('Check Entity Security',2);

           OE_Line_Adj_Security.Entity
                (p_line_adj_rec   	=> l_line_adj_rec
                , x_result      	=> l_sec_result
                , x_return_status 	=> l_return_status
                );

        adj_debug('After Check Entity Security',2);

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

           IF l_sec_result = OE_PC_GLOBALS.YES THEN
                RAISE FND_API.G_EXC_ERROR;
           END IF;

    END IF;

        --  Step 4. Write to DB

	   adj_debug('Before write_to_db',2);
        IF l_control_rec.write_to_db THEN

           /* Start AuditTrail */
           OE_DEBUG_PUB.add('OEXVADJB:calling to insert audit history for line adj from  pre_write_process', 2);

	       Oe_LINE_ADJ_Util.Pre_Write_Process
		    (p_x_line_adj_rec => l_line_adj_rec,
			p_old_line_adj_rec => l_old_line_adj_rec);
           OE_DEBUG_PUB.add('OEXVADJB:After calling to insert audit history for line adj from  pre_write_process', 2);
           /* End AuditTrail */

            IF l_Line_Adj_rec.operation = OE_GLOBALS.G_OPR_DELETE THEN

                OE_Line_Adj_Util.Delete_Row
                (   p_price_adjustment_id         => l_Line_Adj_rec.price_adjustment_id
                );

		-- Log a delayed request to cause repricing due to deleted
		-- record
		-- NOTE: Requesting entity is line, not line adj. as the adj. itself
		-- has been deleted and this request should be deleted when the line gets
		-- deleted. Should be revisited if the entity logged against is changed
		-- to line.
		  	IF OE_Globals.G_RECURSION_MODE <> 'Y' and
			   l_Line_adj_rec.list_line_type_code NOT IN ('COST','TAX')
               THEN

				/* 1905650 - G_PRICE_ADJ request should be logged against LINE entity,
	    			   not against LINE_ADJ entity
				   1503357 - Minor change to handle header level adjustments
	 			*/

			        if (l_line_adj_rec.line_id is NULL) Then
				   oe_delayed_requests_pvt.log_request(
					p_entity_code     => OE_GLOBALS.G_ENTITY_ALL,
					p_entity_id              => l_Line_adj_rec.header_id,
					p_requesting_entity_code => OE_GLOBALS.G_ENTITY_HEADER,
					p_requesting_entity_id   => l_Line_adj_rec.header_id,
					p_request_type           => OE_GLOBALS.G_PRICE_ADJ,
					x_return_status          => l_return_status);
				else
		    	 	  If OE_GLOBALS.G_UI_FLAG and nvl(l_Line_adj_rec.automatic_flag,'Y') = 'N' Then
                                      oe_delayed_requests_pvt.log_request(
	                                  p_entity_code                => OE_GLOBALS.G_ENTITY_LINE,
	                                  p_entity_id                     => l_Line_adj_rec.Line_id,
	                                  p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE_ADJ,
                               	          p_requesting_entity_id   => l_Line_adj_rec.Line_id,
	                                  p_request_type           => OE_GLOBALS.G_PRICE_ADJ,
                                          p_param1                 => 'UI',
	                                  x_return_status          => l_return_status);

				  else
		    	 	        oe_delayed_requests_pvt.log_request(
					p_entity_code     => OE_GLOBALS.G_ENTITY_LINE,
					p_entity_id              => l_Line_adj_rec.Line_id,
					p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
					p_requesting_entity_id   => l_Line_adj_rec.Line_id,
					p_request_type           => OE_GLOBALS.G_PRICE_ADJ,
					x_return_status          => l_return_status);
				  end if;
				end if;
			End If;

		IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		 ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
		   RAISE FND_API.G_EXC_ERROR;
		END IF;


            ELSE

                --  Get Who Information

                l_Line_Adj_rec.last_update_date := SYSDATE;
                l_Line_Adj_rec.last_updated_by := FND_GLOBAL.USER_ID;
                l_Line_Adj_rec.last_update_login := FND_GLOBAL.LOGIN_ID;

                IF l_Line_Adj_rec.operation = OE_GLOBALS.G_OPR_UPDATE THEN
                    oe_debug_pub.add(' updating list line id:'||l_Line_Adj_rec.list_line_id);
                    oe_debug_pub.add(' l_line_adj_rec adjusted_amount:'||l_Line_Adj_rec.adjusted_amount);
                    oe_debug_pub.add(' line_id:'||l_Line_Adj_rec.line_id);
                    OE_Line_Adj_Util.Update_Row (l_Line_Adj_rec);

                ELSIF l_Line_Adj_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN

                    l_Line_Adj_rec.creation_date   := SYSDATE;
                    l_Line_Adj_rec.created_by      := FND_GLOBAL.USER_ID;

       			 adj_debug('Before  insert row',2);
                    OE_Line_Adj_Util.Insert_Row (l_Line_Adj_rec);
       			 adj_debug('After  insert row',2);

                END IF;

            END IF;

        END IF;

        --  Load tables.

        p_x_Line_Adj_tbl(I)              := l_Line_Adj_rec;
        p_x_old_Line_Adj_tbl(I)          := l_old_Line_Adj_rec;

    	OE_Line_Adj_Security.g_check_all_cols_constraint := 'Y';
        OE_MSG_PUB.reset_msg_context('LINE_ADJ');
	-- Check return status and rollaback

	IF l_line_adj_rec.return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         ELSIF l_line_adj_rec.return_status = FND_API.G_RET_STS_ERROR THEN
		   RAISE FND_API.G_EXC_ERROR;
		END IF;

    --  loop exception handler.

/*
-- Bug 6838610 below Code is comented to Imporve Performance
--
-- Start : Changes made as a part of DBI ER # 4185227
--
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'CALLING OE_DBI_UTIL FOR ORDER LINE PRICE ADJUSTMENTS' , 1 ) ;
        oe_debug_pub.add(  'CACHED VALUE' || OE_ORDER_CACHE.G_HEADER_REC.BOOKED_FLAG ) ;
        oe_debug_pub.add(  'RECURSION VALUE' || OE_ORDER_UTIL.G_RECURSION_WITHOUT_EXCEPTION ) ;
        oe_debug_pub.add(  'PROFILE VALUE' || FND_PROFILE.VALUE ( 'ONT_DBI_INSTALLED' ) ) ;
    END IF;

    IF  NVL(FND_PROFILE.VALUE('ONT_DBI_INSTALLED'), 'N') = 'Y' AND
        oe_order_cache.g_header_rec.booked_flag = 'Y' AND
        oe_order_util.g_recursion_without_exception = 'N' AND
        l_control_rec.write_to_db
    THEN
      OE_DBI_UTIL.Update_DBI_Log( x_return_status  => l_return_status);

     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     END IF;
    END IF;

--
-- End : Changes made as a part of DBI ER # 4185227
--

*/
--End of changes for 6838610





    EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN

            l_Line_Adj_rec.return_status   := FND_API.G_RET_STS_ERROR;
            p_x_Line_Adj_tbl(I)              := l_Line_Adj_rec;
            p_x_old_Line_Adj_tbl(I)          := l_old_Line_Adj_rec;
    	    OE_Line_Adj_Security.g_check_all_cols_constraint := 'Y';
            OE_MSG_PUB.reset_msg_context('LINE_ADJ');
oe_delayed_requests_pvt.delete_request(p_entity_code =>OE_GLOBALS.G_ENTITY_LINE_ADJ,
		  	   p_entity_id => l_line_adj_rec.Price_adjustment_id,
	                   p_request_type => NULL,
	                   x_return_status => l_return_status);
	    IF l_control_rec.Process_Partial THEN
		ROLLBACK TO SAVEPOINT Line_Adjs;
	    ELSE
		   RAISE FND_API.G_EXC_ERROR;
	    END IF;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

            l_Line_Adj_rec.return_status   := FND_API.G_RET_STS_UNEXP_ERROR;
            p_x_Line_Adj_tbl(I)              := l_Line_Adj_rec;
            p_x_old_Line_Adj_tbl(I)          := l_old_Line_Adj_rec;
    	    OE_Line_Adj_Security.g_check_all_cols_constraint := 'Y';
            OE_MSG_PUB.reset_msg_context('LINE_ADJ');
oe_delayed_requests_pvt.delete_request(p_entity_code =>OE_GLOBALS.G_ENTITY_LINE_ADJ,
		  	   p_entity_id => l_line_adj_rec.Price_adjustment_id,
	                   p_request_type => NULL,
	                   x_return_status => l_return_status);
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        WHEN OTHERS THEN

            l_Line_Adj_rec.return_status   := FND_API.G_RET_STS_UNEXP_ERROR;
            p_x_Line_Adj_tbl(I)              := l_Line_Adj_rec;
            p_x_old_Line_Adj_tbl(I)          := l_old_Line_Adj_rec;
    	    OE_Line_Adj_Security.g_check_all_cols_constraint := 'Y';
oe_delayed_requests_pvt.delete_request(p_entity_code =>OE_GLOBALS.G_ENTITY_LINE_ADJ,
		  	   p_entity_id => l_line_adj_rec.Price_adjustment_id,
	                   p_request_type => NULL,
	                   x_return_status => l_return_status);

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                OE_MSG_PUB.Add_Exc_Msg
                (   G_PKG_NAME
                ,   'Line_Adjs'
                );
            END IF;

            OE_MSG_PUB.reset_msg_context('LINE_ADJ');
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END;
        <<line_not_in_db>>  --bug 2721485
		I := p_x_Line_Adj_tbl.NEXT(I);
    END LOOP;

    --  Load OUT parameters

    OE_MSG_PUB.reset_msg_context('LINE_ADJ');

    oe_order_pvt.set_recursion_mode(p_Entity_Code => 6,
                                   p_In_out  => 0);

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

    oe_order_pvt.set_recursion_mode(p_Entity_Code => 6,
                                   p_In_out  => 0);

        adj_debug('Exiting oe_order_Adj_pvt.LINE_ADJS', 1);
        OE_MSG_PUB.reset_msg_context('LINE_ADJ');
        RAISE;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    oe_order_pvt.set_recursion_mode(p_Entity_Code => 6,
                                   p_In_out  => 0);


        OE_MSG_PUB.reset_msg_context('LINE_ADJ');
        RAISE;

    WHEN OTHERS THEN
    oe_order_pvt.set_recursion_mode(p_Entity_Code => 6,
                                   p_In_out  => 0);

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Line_Adjs'
            );
        END IF;


        OE_MSG_PUB.reset_msg_context('LINE_ADJ');
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Line_Adjs;

PROCEDURE HEader_Price_Atts
(   p_init_msg_list                 IN VARCHAR2:=FND_API.G_FALSE
,   p_validation_level              IN  NUMBER
,   p_control_rec                   IN  OE_GLOBALS.Control_Rec_Type
,   p_x_HEader_Price_Att_tbl        IN OUT NOCOPY  OE_Order_PUB.HEader_Price_Att_Tbl_Type
,   p_x_old_HEader_Price_Att_tbl    IN OUT NOCOPY  OE_Order_PUB.HEader_Price_Att_Tbl_Type
)
is
l_return_status               VARCHAR2(1);
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_Header_Price_Att_rec        OE_Order_PUB.Header_Price_Att_Rec_Type;
l_old_Header_Price_Att_rec    OE_Order_PUB.Header_Price_Att_Rec_Type;
-- local variables to store OUT parameters from security check procedures
l_sec_result            NUMBER;
l_on_operation_action   NUMBER;
I 				    pls_integer; -- Used as index for while loop
l_booked_flag			varchar2(1);
l_Shipped_quantity		number;
l_pricing_event                 varchar2(30);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
  l_order_source_id           NUMBER;
  l_orig_sys_document_ref     VARCHAR2(50);
  l_change_sequence           VARCHAR2(50);
  l_source_document_type_id   NUMBER;
  l_source_document_id        NUMBER;

BEGIN

    l_control_rec := p_control_rec;  -- Added for Bug #5679839

    IF FND_API.to_Boolean(p_init_msg_list) THEN
        OE_MSG_PUB.initialize;
    END IF;

IF l_control_rec.Process_Partial THEN
	SAVEPOINT Header_Price_Atts;
END IF;

    --  Init local table variables.

        --dbms_output.put_line('Entering oe_order_Adj_pvt.HEader_Price_Atts');
        oe_debug_pub.add('Entering oe_order_Adj_pvt.HEader_Price_Atts', 1);


    I := p_x_Header_Price_Att_tbl.FIRST;

    WHILE I IS NOT NULL LOOP
    BEGIN

        --  Load local records.

        l_Header_Price_Att_rec := p_x_Header_Price_Att_tbl(I);

        IF p_x_old_Header_Price_Att_tbl.EXISTS(I) THEN
            l_old_Header_Price_Att_rec := p_x_old_Header_Price_Att_tbl(I);
        ELSE
            l_old_Header_Price_Att_rec := OE_Order_PUB.G_MISS_HEADER_Price_Att_REC;
        END IF;

    if l_old_header_Price_Att_rec.Order_price_attrib_id = FND_API.G_MISS_NUM  then
      IF l_header_Price_Att_rec.header_Id IS NOT NULL AND
         l_header_Price_Att_rec.header_Id <> FND_API.G_MISS_NUM THEN
         BEGIN
               IF l_debug_level  > 0 THEN
                  oe_debug_pub.add('Getting reference data for header_id:'||l_header_Price_Att_rec.header_Id);
               END IF;
               SELECT order_source_id, orig_sys_document_ref, change_sequence,
               source_document_type_id, source_document_id
               INTO l_order_source_id, l_orig_sys_document_ref, l_change_sequence,
               l_source_document_type_id, l_source_document_id
               FROM   OE_ORDER_HEADERS_ALL
               WHERE  header_id = l_header_Price_Att_rec.header_Id;
         EXCEPTION
               WHEN NO_DATA_FOUND THEN
                   l_order_source_id := null;
                   l_orig_sys_document_ref := null;
                   l_change_sequence := null;
                   l_source_document_type_id := null;
                   l_source_document_id := null;
               WHEN OTHERS THEN
                   l_order_source_id := null;
                   l_orig_sys_document_ref := null;
                   l_change_sequence := null;
                   l_source_document_type_id := null;
                   l_source_document_id := null;
         END;
      END IF;

      OE_MSG_PUB.set_msg_context(
	 p_entity_code			=> 'HEADER_PATTS'
  	,p_entity_id         		=> l_header_Price_Att_rec.Order_price_attrib_id
    	,p_header_id         		=> l_header_Price_Att_rec.header_Id
        ,p_line_id                      => null
        ,p_order_source_id              => l_order_source_id
        ,p_orig_sys_document_ref        => l_orig_sys_document_ref
        ,p_orig_sys_document_line_ref   => null
        ,p_change_sequence              => l_change_sequence
        ,p_source_document_type_id      => l_source_document_type_id
        ,p_source_document_id           => l_source_document_id
        ,p_source_document_line_id      => null );

    else

      IF l_old_header_Price_Att_rec.header_Id IS NOT NULL AND
         l_old_header_Price_Att_rec.header_Id <> FND_API.G_MISS_NUM THEN

            BEGIN
               IF l_debug_level  > 0 THEN
                  oe_debug_pub.add('Getting reference data for old header_id:'||l_old_header_Price_Att_rec.header_Id);
               END IF;
               SELECT order_source_id, orig_sys_document_ref, change_sequence,
               source_document_type_id, source_document_id
               INTO l_order_source_id, l_orig_sys_document_ref, l_change_sequence,
               l_source_document_type_id, l_source_document_id
               FROM   OE_ORDER_HEADERS_ALL
               WHERE  header_id = l_old_header_Price_Att_rec.header_Id;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                   l_order_source_id := null;
                   l_orig_sys_document_ref := null;
                   l_change_sequence := null;
                   l_source_document_type_id := null;
                   l_source_document_id := null;
               WHEN OTHERS THEN
                   l_order_source_id := null;
                   l_orig_sys_document_ref := null;
                   l_change_sequence := null;
                   l_source_document_type_id := null;
                   l_source_document_id := null;
            END;
      END IF;

      OE_MSG_PUB.set_msg_context(
	 p_entity_code			=> 'HEADER_PATTS'
  	,p_entity_id         		=> l_old_header_Price_Att_rec.Order_price_attrib_id
    	,p_header_id         		=> l_old_header_Price_Att_rec.header_Id
        ,p_line_id                      => null
        ,p_order_source_id              => l_order_source_id
        ,p_orig_sys_document_ref        => l_orig_sys_document_ref
        ,p_orig_sys_document_line_ref   => null
        ,p_change_sequence              => l_change_sequence
        ,p_source_document_type_id      => l_source_document_type_id
        ,p_source_document_id           => l_source_document_id
        ,p_source_document_line_id      => null );

    end if;

        --  Load API control record

        l_control_rec := OE_GLOBALS.Init_Control_Rec
        (   p_operation     => l_Header_Price_Att_rec.operation
        ,   p_control_rec   => p_control_rec
        );

        --  Set record return status.

        l_Header_Price_Att_rec.return_status := FND_API.G_RET_STS_SUCCESS;

        oe_debug_pub.add('  After initializing record,operation:'||l_Header_Price_Att_rec.operation);
        --  Prepare record.

        IF l_Header_Price_Att_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN

            l_Header_Price_Att_rec.db_flag := FND_API.G_FALSE;

            --  Set missing old record elements to NULL.

   		 oe_debug_pub.add('Entering OE_Header_Price_Att_Util.Convert_Miss_To_Null', 2);
--            l_old_Header_Price_Att_rec :=
            OE_Header_PAttr_Util.Convert_Miss_To_Null (l_old_Header_Price_Att_rec);

        ELSIF l_Header_Price_Att_rec.operation = OE_GLOBALS.G_OPR_UPDATE
        OR    l_Header_Price_Att_rec.operation = OE_GLOBALS.G_OPR_DELETE
        THEN

            l_Header_Price_Att_rec.db_flag := FND_API.G_TRUE;

            --  Query Old if missing

            IF  l_old_Header_Price_Att_rec.order_price_attrib_id = FND_API.G_MISS_NUM
            THEN


                OE_Header_PAttr_Util.Query_Row
                (   p_order_price_attrib_id => l_Header_Price_Att_rec.order_price_attrib_id
                ,   x_Header_Price_Att_rec =>  l_old_Header_Price_Att_rec
                );

            ELSE

                --  Set missing old record elements to NULL.

--                l_old_Header_Price_Att_rec :=
                OE_Header_PAttr_Util.Convert_Miss_To_Null (l_old_Header_Price_Att_rec);

            END IF;

            --  Complete new record from old

--            l_Header_Price_Att_rec :=
            OE_Header_PAttr_Util.Complete_Record
            (   p_x_Header_Price_Att_rec              => l_Header_Price_Att_rec
            ,   p_old_Header_Price_Att_rec          => l_old_Header_Price_Att_rec
            );

      	   OE_MSG_PUB.update_msg_context(
	 	 p_entity_code			=> 'HEADER_ADJ'
  		,p_entity_id         		=> l_header_Price_Att_rec.order_price_attrib_id
    		,p_header_id         		=> l_header_Price_Att_rec.header_Id);

        END IF;


        IF I = p_x_header_Price_Att_tbl.FIRST THEN
	       IF NOT oe_order_pvt.Valid_Upgraded_Order(l_header_Price_Att_rec.header_id) THEN
                 RAISE FND_API.G_EXC_ERROR;
            END IF;
        END IF;


        --  Attribute level validation.

            IF p_validation_level > FND_API.G_VALID_LEVEL_NONE THEN
                oe_debug_pub.add('  In OE_Validate_Header_Pattr.Attributes');
                OE_Validate_Header_Pattr.Attributes
                (   x_return_status               => l_return_status
                ,   p_Header_Price_Attr_rec       => l_Header_Price_Att_rec
                ,   p_old_Header_Price_Attr_rec   => l_old_Header_Price_Att_rec
			 ,   p_validation_level			=> p_validation_level
                );

                IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                    RAISE FND_API.G_EXC_ERROR;
                END IF;

            END IF;

            --  Clear dependent attributes.

        IF  l_control_rec.clear_dependents THEN

            OE_Header_PAttr_Util.Clear_Dependent_Attr
            (   p_x_Header_Price_Att_rec              => l_Header_Price_Att_rec
            ,   p_old_Header_Price_Att_rec          => l_old_Header_Price_Att_rec
            --,   x_Header_Price_Att_rec              => l_Header_Price_Att_rec
            );

        END IF;

        --  Default missing attributes
        IF  l_control_rec.default_attributes
        THEN

           OE_Default_Header_Pattr.Attributes
            (   p_x_Header_Price_Att_rec              => l_Header_Price_Att_rec
            --,   p_old_header_Price_Att_rec	      => l_old_header_Price_Att_rec
            --,   x_Header_Price_Att_rec              => l_Header_Price_Att_rec
            );

        END IF;

        --  Apply attribute changes

        IF  l_control_rec.change_attributes
        THEN

	   -- This will also log request/s to check duplicity of
	   -- price adjustment entered
            oe_debug_pub.add('  In apply attribute changes');
            OE_Header_PAttr_Util.Apply_Attribute_Changes
            (   p_x_Header_Price_Att_rec              => l_Header_Price_Att_rec
            ,   p_old_Header_Price_Att_rec          => l_old_Header_Price_Att_rec
            );

        END IF;

	-- If there has any activity causing a change in any attribute
	-- log a request for repricing

        --  Entity level validation.

        IF l_control_rec.validate_entity THEN

            IF l_Header_Price_Att_rec.operation = OE_GLOBALS.G_OPR_DELETE THEN

                OE_Validate_Header_Pattr.Entity_Delete
                (   x_return_status               => l_return_status
                ,   p_Header_Price_Attr_rec              => l_Header_Price_Att_rec
                );

            ELSE

                /*OE_Validate_Header_Pattr.Entity
                (   x_return_status               => l_return_status
                ,   p_Header_Price_Attr_rec              => l_Header_Price_Att_rec
                ,   p_old_Header_Price_Attr_rec          => l_old_Header_Price_Att_rec
                );*/

                null;

            END IF;

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

        END IF;

        --  Step 4. Write to DB

        IF l_control_rec.write_to_db THEN

            IF l_Header_Price_Att_rec.operation = OE_GLOBALS.G_OPR_DELETE THEN

                OE_Header_PAttr_Util.Delete_Row
                (   p_order_price_attrib_id         => l_Header_Price_Att_rec.order_price_attrib_id
                );

		-- Log a delayed request to cause repricing due to deleted
		-- record
--2442012

   /*     		OE_delayed_requests_Pvt.log_request(
				p_entity_code 			=> OE_GLOBALS.G_ENTITY_HEader_Price_Att,
				p_entity_id         	=> l_Header_Price_Att_Rec.Header_Id,
				p_requesting_entity_code => OE_GLOBALS.G_ENTITY_HEader_Price_Att,
				p_requesting_entity_id   => l_Header_Price_Att_Rec.Header_Id,
		 		p_param1                 => l_Header_Price_Att_Rec.Header_Id,
                 	        p_param2                 => 'LINE',
		 		p_request_type           => OE_GLOBALS.G_PRICE_ORDER,
		 		x_return_status          => l_return_status);

        		OE_delayed_requests_Pvt.log_request(
				p_entity_code 			=> OE_GLOBALS.G_ENTITY_ALL,
				p_entity_id         	=> l_Header_Price_Att_Rec.Header_Id,
				p_requesting_entity_code => OE_GLOBALS.G_ENTITY_ALL,
				p_requesting_entity_id   => l_Header_Price_Att_Rec.Header_Id,
		 		p_param1                 => l_Header_Price_Att_Rec.Header_Id,
                 	        p_param2                 => 'ORDER',
		 		p_request_type           => OE_GLOBALS.G_PRICE_ORDER,
		 		x_return_status          => l_return_status);
*/
				Begin
				   -- use order_header cache instead of sql : bug 4200055
				   if ( OE_Order_Cache.g_header_rec.header_id <> FND_API.G_MISS_NUM
					and OE_Order_Cache.g_header_rec.header_id IS NOT NULL
					and OE_Order_Cache.g_header_rec.header_id = l_header_price_att_rec.header_id ) then
				            l_booked_flag := OE_Order_Cache.g_header_rec.booked_flag ;
				  else
				           OE_ORDER_CACHE.Load_Order_Header(l_header_price_att_rec.header_id);
					   l_booked_flag := OE_Order_Cache.g_header_rec.booked_flag ;
				 end if ;
					/*Select booked_flag	Into
						l_booked_flag
					From OE_Order_Headers where
					Header_id =	l_Header_Price_Att_Rec.Header_Id;
					Exception when no_data_found then
						Null;
                                         -- we shouldn't supress no_data_found error.
                                         */
				 --end bug 4200055
				End;

	    			If l_booked_flag='Y' Then
                                 l_pricing_event := 'BATCH,BOOK,SHIP';
    /*       				OE_delayed_requests_Pvt.log_request(
								p_entity_code 			=> OE_GLOBALS.G_ENTITY_ALL,
								p_entity_id         	=> l_Header_Price_Att_Rec.Header_Id,
								p_requesting_entity_code => OE_GLOBALS.G_ENTITY_ALL,
								p_requesting_entity_id   => l_Header_Price_Att_Rec.Header_Id,
		 						p_param1                 => l_Header_Price_Att_Rec.Header_Id,
                 					p_param2                 => 'BOOK',
		 						p_request_type           => OE_GLOBALS.G_PRICE_ORDER,
		 						x_return_status          => l_return_status);
  */
                                Else
                                 l_pricing_event := 'BATCH';
				End If;

          		OE_delayed_requests_Pvt.log_request(
						p_entity_code 			=> OE_GLOBALS.G_ENTITY_ALL,
						p_entity_id         	=> l_Header_Price_Att_Rec.Header_Id,
						p_requesting_entity_code => OE_GLOBALS.G_ENTITY_ALL,
						p_requesting_entity_id   => l_Header_Price_Att_Rec.Header_Id,
                                                p_request_unique_key1    => l_pricing_event,
		 				p_param1                 => l_Header_Price_Att_Rec.Header_Id,
                 			p_param2                 => l_pricing_event,
		 				p_request_type           => OE_GLOBALS.G_PRICE_ORDER,
		 				x_return_status          => l_return_status);


				IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		   				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		 		ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
		   				RAISE FND_API.G_EXC_ERROR;
				END IF;
--2442012
            ELSE

                --  Get Who Information

                l_Header_Price_Att_rec.last_update_date := SYSDATE;
                l_Header_Price_Att_rec.last_updated_by := FND_GLOBAL.USER_ID;
                l_Header_Price_Att_rec.last_update_login := FND_GLOBAL.LOGIN_ID;

                IF l_Header_Price_Att_rec.operation = OE_GLOBALS.G_OPR_UPDATE THEN

                    OE_Header_PAttr_Util.Update_Row (l_Header_Price_Att_rec);

                ELSIF l_Header_Price_Att_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN

                    l_Header_Price_Att_rec.creation_date := SYSDATE;
                    l_Header_Price_Att_rec.created_by    := FND_GLOBAL.USER_ID;
                    oe_debug_pub.add('  Before calling pattr_util.insert_row');

                    select OE_ORDER_PRICE_ATTRIBS_S.nextval
                    into   l_header_price_att_rec.order_price_attrib_id
                    from dual;

                    OE_Header_PAttr_Util.Insert_Row (l_Header_Price_Att_rec);

                END IF;

            END IF;

        END IF;

        --  Load tables.

        p_x_Header_Price_Att_tbl(I)            := l_Header_Price_Att_rec;
        p_x_old_Header_Price_Att_tbl(I)        := l_old_Header_Price_Att_rec;

         IF l_header_Price_Att_rec.return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         ELSIF l_header_Price_Att_rec.return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
         END IF;
/*

    OE_Header_PAttr_Security.g_check_all_cols_constraint := 'Y';
*/
        OE_MSG_PUB.reset_msg_context('HEADER_ADJ');
    --   loop exception handler.

    EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN

            l_Header_Price_Att_rec.return_status := FND_API.G_RET_STS_ERROR;
            p_x_Header_Price_Att_tbl(I)            := l_Header_Price_Att_rec;
            p_x_old_Header_Price_Att_tbl(I)        := l_old_Header_Price_Att_rec;
	    /*
    	    OE_Header_PAttr_Security.g_check_all_cols_constraint := 'Y';
            OE_MSG_PUB.reset_msg_context('HEADER_ADJ');
			oe_delayed_requests_pvt.delete_request
			(p_entity_code =>OE_GLOBALS.G_ENTITY_HEADER_ADJ,
		  	   p_entity_id => l_header_Price_Att_rec.order_price_attrib_id,
	                   p_request_type => NULL,
	                   x_return_status => l_return_status);
				    */
		IF l_control_rec.Process_Partial THEN
			ROLLBACK TO SAVEPOINT Header_Price_Atts;
		ELSE
                RAISE FND_API.G_EXC_ERROR;
	        END IF;


        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

            l_Header_Price_Att_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            p_x_Header_Price_Att_tbl(I)            := l_Header_Price_Att_rec;
            p_x_old_Header_Price_Att_tbl(I)        := l_old_Header_Price_Att_rec;
	    /*
    	    OE_Header_PAttr_Security.g_check_all_cols_constraint := 'Y';
            OE_MSG_PUB.reset_msg_context('HEADER_ADJ');
			oe_delayed_requests_pvt.delete_request
				(p_entity_code =>OE_GLOBALS.G_ENTITY_HEADER_ADJ,
		  	   p_entity_id => l_header_Price_Att_rec.order_price_attrib_id,
	                   p_request_type => NULL,
	                   x_return_status => l_return_status);
				    */
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        WHEN OTHERS THEN

            l_Header_Price_Att_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            p_x_Header_Price_Att_tbl(I)            := l_Header_Price_Att_rec;
            p_x_old_Header_Price_Att_tbl(I)        := l_old_Header_Price_Att_rec;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                OE_MSG_PUB.Add_Exc_Msg
                (   G_PKG_NAME
                ,   'Header_Price_Atts'
                );
            END IF;

            OE_MSG_PUB.reset_msg_context('HEADER_PATTS');
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END;
    I := p_x_Header_Price_Att_tbl.NEXT(I);
    END LOOP;

    --  Load OUT parameters


      oe_debug_pub.add('Exiting oe_order_Price_Att_pvt.HEADER_Price_Atts', 1);
      OE_MSG_PUB.reset_msg_context('HEADER_PATTS');

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

      OE_MSG_PUB.reset_msg_context('HEADER_PATTS');
      RAISE;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      OE_MSG_PUB.reset_msg_context('HEADER_PATTS');
      RAISE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Header_Price_Atts'
            );
        END IF;


        OE_MSG_PUB.reset_msg_context('HEADER_PATTS');
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        adj_debug('Exiting oe_order_Adj_pvt.HEader_Price_Atts', 1);

end HEader_Price_Atts;

PROCEDURE Header_Adj_Atts
(   p_init_msg_list                 IN VARCHAR2:=FND_API.G_FALSE
,   p_validation_level              IN  NUMBER
,   p_control_rec                   IN  OE_GLOBALS.Control_Rec_Type
,   p_x_Header_Adj_Att_tbl          IN OUT NOCOPY OE_Order_PUB.Header_Adj_Att_Tbl_Type
,   p_x_old_Header_Adj_Att_tbl      IN OUT NOCOPY  OE_Order_PUB.Header_Adj_Att_Tbl_Type
)
is
l_return_status               VARCHAR2(1);
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_Header_Adj_Att_rec        	OE_Order_PUB.Header_Adj_Att_Rec_Type;
l_old_Header_Adj_Att_rec    	OE_Order_PUB.Header_Adj_Att_Rec_Type;
-- local variables to store OUT parameters from security check procedures
I 				    pls_integer; -- Used as index for while loop
BEGIN

    IF FND_API.to_Boolean(p_init_msg_list) THEN
        OE_MSG_PUB.initialize;
    END IF;


IF l_control_rec.Process_Partial THEN
	SAVEPOINT Header_price_atts;
END IF;

    --  Init local table variables.

	   --dbms_output.put_line('Entering oe_order_Adj_pvt.Header_price_atts');
        adj_debug('Enetring oe_order_Adj_pvt.HEader_Adj_Atts', 1);

    I := p_x_Header_Adj_Att_tbl.FIRST;

    WHILE I IS NOT NULL LOOP
    BEGIN

        --  Load local records.

        l_Header_Adj_Att_rec := p_x_Header_Adj_Att_tbl(I);

        IF p_x_old_Header_Adj_Att_tbl.EXISTS(I) THEN
            l_old_Header_Adj_Att_rec := p_x_old_Header_Adj_Att_tbl(I);
        ELSE
            l_old_Header_Adj_Att_rec := OE_Order_PUB.G_MISS_Header_Adj_Att_REC;
        END IF;

    if l_old_Header_Adj_Att_rec.Price_Adj_attrib_id = FND_API.G_MISS_NUM  then

      OE_MSG_PUB.set_msg_context(
	 p_entity_code			=> 'ADJ_ATTS'
  	,p_entity_id         		=> l_Header_Adj_Att_rec.Price_adj_attrib_id);

    else

      OE_MSG_PUB.set_msg_context(
	 p_entity_code			=> 'ADJ_ATTS'
  	,p_entity_id         		=> l_old_Header_Adj_Att_rec.Price_adj_attrib_id);

    end if;

        --  Load API control record

        l_control_rec := OE_GLOBALS.Init_Control_Rec
        (   p_operation     => l_Header_Adj_Att_rec.operation
        ,   p_control_rec   => p_control_rec
        );

        --  Set record return status.

        l_Header_Adj_Att_rec.return_status := FND_API.G_RET_STS_SUCCESS;

        --  Prepare record.

        IF l_Header_Adj_Att_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN

            l_Header_Adj_Att_rec.db_flag := FND_API.G_FALSE;

            --  Set missing old record elements to NULL.

   		 adj_debug('Entering OE_Header_Adj_Att_Util.Convert_Miss_To_Null', 1);
--            l_old_Header_Adj_Att_rec :=
            Oe_Header_Price_Aattr_util.Convert_Miss_To_Null (l_old_Header_Adj_Att_rec);

        ELSIF l_Header_Adj_Att_rec.operation = OE_GLOBALS.G_OPR_UPDATE
        OR    l_Header_Adj_Att_rec.operation = OE_GLOBALS.G_OPR_DELETE
        THEN

            l_Header_Adj_Att_rec.db_flag := FND_API.G_TRUE;

            --  Query Old if missing

            IF  l_old_Header_Adj_Att_rec.Price_adj_attrib_id = FND_API.G_MISS_NUM
            THEN


                Oe_Header_Price_Aattr_util.Query_Row
                (   p_Price_Adj_Attrib_id => l_Header_Adj_Att_rec.Price_adj_attrib_id
                ,   x_Header_Adj_Att_rec  => l_old_Header_Adj_Att_rec
                );

            ELSE

                --  Set missing old record elements to NULL.

--                l_old_Header_Adj_Att_rec :=
                Oe_Header_Price_Aattr_util.Convert_Miss_To_Null (l_old_Header_Adj_Att_rec);

            END IF;

            --  Complete new record from old

--            l_Header_Adj_Att_rec :=
            Oe_Header_Price_Aattr_util.Complete_Record
            (   p_x_Header_Adj_Att_rec              => l_Header_Adj_Att_rec
            ,   p_old_Header_Adj_Att_rec          => l_old_Header_Adj_Att_rec
            );

      	   OE_MSG_PUB.update_msg_context(
	 	 p_entity_code			=> 'ADJ_ATTS'
  		,p_entity_id         		=> l_Header_Adj_Att_rec.Price_adj_attrib_id);

        END IF;

        --  Default missing attributes
        IF  l_control_rec.default_attributes
        THEN

           OE_DEfault_Header_Aattr.Attributes
            (   p_Header_Adj_Att_rec              => l_Header_Adj_Att_rec
            --,   x_Header_Adj_Att_rec              => l_Header_Adj_Att_rec
            );

        END IF;

        --  Apply attribute changes

        IF  l_control_rec.change_attributes
        THEN

	   -- This will also log request/s to check duplicity of
	   -- price adjustment entered
            Oe_Header_Price_Aattr_util.Apply_Attribute_Changes
            (   p_x_Header_Adj_Att_rec              => l_Header_Adj_Att_rec
            ,   p_old_Header_Adj_Att_rec          => l_old_Header_Adj_Att_rec
            --,   x_Header_Adj_Att_rec              => l_Header_Adj_Att_rec
            );

        END IF;

	-- If there has any activity causing a change in any attribute
	-- log a request for repricing

        --  Entity level validation.

        --  Step 4. Write to DB

        IF l_control_rec.write_to_db THEN

            IF l_Header_Adj_Att_rec.operation = OE_GLOBALS.G_OPR_DELETE THEN

                Oe_Header_Price_Aattr_util.Delete_Row
                (   p_Price_Adj_Attrib_id         => l_Header_Adj_Att_rec.Price_adj_attrib_id
                );

            ELSE

                --  Get Who Information

                l_Header_Adj_Att_rec.last_update_date := SYSDATE;
                l_Header_Adj_Att_rec.last_updated_by := FND_GLOBAL.USER_ID;
                l_Header_Adj_Att_rec.last_update_login := FND_GLOBAL.LOGIN_ID;

                IF l_Header_Adj_Att_rec.operation = OE_GLOBALS.G_OPR_UPDATE THEN

                    Oe_Header_Price_Aattr_util.Update_Row (l_Header_Adj_Att_rec);

                ELSIF l_Header_Adj_Att_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN

                    l_Header_Adj_Att_rec.creation_date := SYSDATE;
                    l_Header_Adj_Att_rec.created_by    := FND_GLOBAL.USER_ID;

                    Oe_Header_Price_Aattr_util.Insert_Row (l_Header_Adj_Att_rec);

                END IF;

            END IF;

        END IF;

        --  Load tables.

        p_x_Header_Adj_Att_tbl(I)            := l_Header_Adj_Att_rec;
        p_x_old_Header_Adj_Att_tbl(I)        := l_old_Header_Adj_Att_rec;

         IF l_Header_Adj_Att_rec.return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         ELSIF l_Header_Adj_Att_rec.return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
         END IF;

        OE_MSG_PUB.reset_msg_context('ADJ_ATTS');
    --   loop exception handler.

    EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN

            l_Header_Adj_Att_rec.return_status := FND_API.G_RET_STS_ERROR;
            p_x_Header_Adj_Att_tbl(I)            := l_Header_Adj_Att_rec;
            p_x_old_Header_Adj_Att_tbl(I)        := l_old_Header_Adj_Att_rec;

		IF l_control_rec.Process_Partial THEN
			ROLLBACK TO SAVEPOINT Header_price_atts;
		ELSE
                RAISE FND_API.G_EXC_ERROR;
	        END IF;


        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

            l_Header_Adj_Att_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            p_x_Header_Adj_Att_tbl(I)            := l_Header_Adj_Att_rec;
            p_x_old_Header_Adj_Att_tbl(I)        := l_old_Header_Adj_Att_rec;

            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        WHEN OTHERS THEN

            l_Header_Adj_Att_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            p_x_Header_Adj_Att_tbl(I)            := l_Header_Adj_Att_rec;
            p_x_old_Header_Adj_Att_tbl(I)        := l_old_Header_Adj_Att_rec;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                OE_MSG_PUB.Add_Exc_Msg
                (   G_PKG_NAME
                ,   'Header_price_atts'
                );
            END IF;

            OE_MSG_PUB.reset_msg_context('ADJ_ATTS');
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END;
    I := p_x_Header_Adj_Att_tbl.NEXT(I);
    END LOOP;

    --  Load OUT parameters

      adj_debug('Exiting oe_order_Adj_pvt.Header_Adj_Atts', 1);
      OE_MSG_PUB.reset_msg_context('ADJ_ATTS');

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

      OE_MSG_PUB.reset_msg_context('ADJ_ATTS');
      RAISE;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      OE_MSG_PUB.reset_msg_context('ADJ_ATTS');
      RAISE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Header_Adj_Atts'
            );
        END IF;


        OE_MSG_PUB.reset_msg_context('ADJ_ATTS');
        adj_debug('Exiting oe_order_Adj_pvt.HEader_Adj_Atts', 1);

end Header_Adj_Atts;

PROCEDURE Header_Adj_Assocs
(   p_init_msg_list                 IN VARCHAR2:=FND_API.G_FALSE
,   p_validation_level              IN  NUMBER
,   p_control_rec                   IN  OE_GLOBALS.Control_Rec_Type
,   p_x_Header_Adj_Assoc_tbl        IN OUT NOCOPY  OE_Order_PUB.Header_Adj_Assoc_Tbl_Type
,   p_x_old_Header_Adj_Assoc_tbl    IN OUT NOCOPY  OE_Order_PUB.Header_Adj_Assoc_Tbl_Type
)
is
l_return_status               VARCHAR2(1);
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_Header_Adj_Assoc_rec        	OE_Order_PUB.Header_Adj_Assoc_Rec_Type;
l_old_Header_Adj_Assoc_rec    	OE_Order_PUB.Header_Adj_Assoc_Rec_Type;
-- local variables to store OUT parameters from security check procedures
I 				    pls_integer; -- Used as index for while loop
BEGIN

    IF FND_API.to_Boolean(p_init_msg_list) THEN
        OE_MSG_PUB.initialize;
    END IF;

IF l_control_rec.Process_Partial THEN
	SAVEPOINT Header_Adj_Assocs;
END IF;

    --  Init local table variables.

	   --dbms_output.put_line('Entering oe_order_Adj_pvt.HEader_Price_assocs');
        adj_debug('Enetring oe_order_Adj_pvt.Header_Adj_Assocs', 1);


    I := p_x_Header_Adj_Assoc_tbl.FIRST;

    WHILE I IS NOT NULL LOOP
    BEGIN

        --  Load local records.

        l_Header_Adj_Assoc_rec := p_x_Header_Adj_Assoc_tbl(I);

        IF p_x_old_Header_Adj_Assoc_tbl.EXISTS(I) THEN
            l_old_Header_Adj_Assoc_rec := p_x_old_Header_Adj_Assoc_tbl(I);
        ELSE
            l_old_Header_Adj_Assoc_rec := OE_Order_PUB.G_MISS_Header_Adj_Assoc_REC;
        END IF;

    if l_old_Header_Adj_Assoc_rec.Price_Adj_assoc_id = FND_API.G_MISS_NUM  then

      OE_MSG_PUB.set_msg_context(
	 p_entity_code			=> 'ADJ_ATTS'
  	,p_entity_id         		=> l_Header_Adj_Assoc_rec.Price_Adj_assoc_id);

    else

      OE_MSG_PUB.set_msg_context(
	 p_entity_code			=> 'ADJ_ATTS'
  	,p_entity_id         		=> l_old_Header_Adj_Assoc_rec.Price_Adj_assoc_id);

    end if;

        --  Load API control record

        l_control_rec := OE_GLOBALS.Init_Control_Rec
        (   p_operation     => l_Header_Adj_Assoc_rec.operation
        ,   p_control_rec   => p_control_rec
        );

        --  Set record return status.

        l_Header_Adj_Assoc_rec.return_status := FND_API.G_RET_STS_SUCCESS;

        --  Prepare record.

        IF l_Header_Adj_Assoc_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN

            l_Header_Adj_Assoc_rec.db_flag := FND_API.G_FALSE;

            --  Set missing old record elements to NULL.

   		 adj_debug('Entering OE_Header_Adj_Assoc_Util.Convert_Miss_To_Null', 1);
--            l_old_Header_Adj_Assoc_rec :=
            Oe_Header_Adj_Assocs_util.Convert_Miss_To_Null (l_old_Header_Adj_Assoc_rec);

        ELSIF l_Header_Adj_Assoc_rec.operation = OE_GLOBALS.G_OPR_UPDATE
        OR    l_Header_Adj_Assoc_rec.operation = OE_GLOBALS.G_OPR_DELETE
        THEN

            l_Header_Adj_Assoc_rec.db_flag := FND_API.G_TRUE;

            --  Query Old if missing

            IF  l_old_Header_Adj_Assoc_rec.Price_Adj_assoc_id = FND_API.G_MISS_NUM
            THEN


                Oe_Header_Adj_Assocs_util.Query_Row
                (   p_Price_Adj_assoc_id => l_Header_Adj_Assoc_rec.Price_Adj_assoc_id
                ,   x_header_adj_Assoc_rec =>                 l_old_Header_Adj_Assoc_rec
                );

            ELSE

                --  Set missing old record elements to NULL.

--                l_old_Header_Adj_Assoc_rec :=
                Oe_Header_Adj_Assocs_util.Convert_Miss_To_Null (l_old_Header_Adj_Assoc_rec);

            END IF;

            --  Complete new record from old

--            l_Header_Adj_Assoc_rec :=
            Oe_Header_Adj_Assocs_util.Complete_Record
            (   p_x_Header_Adj_Assoc_rec              => l_Header_Adj_Assoc_rec
            ,   p_old_Header_Adj_Assoc_rec          => l_old_Header_Adj_Assoc_rec
            );

      	   OE_MSG_PUB.update_msg_context(
	 	 p_entity_code			=> 'ADJ_ATTS'
  		,p_entity_id         		=> l_Header_Adj_Assoc_rec.Price_Adj_assoc_id);

        END IF;

        --  Default missing attributes
        IF  l_control_rec.default_attributes
        THEN

           OE_DEfault_Header_Adj_Assocs.Attributes
            (   p_x_Header_Adj_Assoc_rec              => l_Header_Adj_Assoc_rec
            --,   x_Header_Adj_Assoc_rec              => l_Header_Adj_Assoc_rec
            );

        END IF;

        --  Apply attribute changes

        IF  l_control_rec.change_attributes
        THEN

	   -- This will also log request/s to check duplicity of
	   -- price adjustment entered
            Oe_Header_Adj_Assocs_util.Apply_Attribute_Changes
            (   p_x_Header_Adj_Assoc_rec              => l_Header_Adj_Assoc_rec
            ,   p_old_Header_Adj_Assoc_rec          => l_old_Header_Adj_Assoc_rec
            --,   x_Header_Adj_Assoc_rec              => l_Header_Adj_Assoc_rec
            );

        END IF;

	-- If there has any activity causing a change in any attribute
	-- log a request for repricing

        --  Entity level validation.

        --  Step 4. Write to DB

        IF l_control_rec.write_to_db THEN

            IF l_Header_Adj_Assoc_rec.operation = OE_GLOBALS.G_OPR_DELETE THEN

                Oe_Header_Adj_Assocs_util.Delete_Row
                (   p_Price_Adj_assoc_id         => l_Header_Adj_Assoc_rec.Price_Adj_assoc_id
                );

            ELSE

                --  Get Who Information

                l_Header_Adj_Assoc_rec.last_update_date := SYSDATE;
                l_Header_Adj_Assoc_rec.last_updated_by := FND_GLOBAL.USER_ID;
                l_Header_Adj_Assoc_rec.last_update_login := FND_GLOBAL.LOGIN_ID;

                IF l_Header_Adj_Assoc_rec.operation = OE_GLOBALS.G_OPR_UPDATE THEN

                    Oe_Header_Adj_Assocs_util.Update_Row (l_Header_Adj_Assoc_rec);

                ELSIF l_Header_Adj_Assoc_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN

                    l_Header_Adj_Assoc_rec.creation_date := SYSDATE;
                    l_Header_Adj_Assoc_rec.created_by    := FND_GLOBAL.USER_ID;

                    Oe_Header_Adj_Assocs_util.Insert_Row (l_Header_Adj_Assoc_rec);

                END IF;

            END IF;

        END IF;

        --  Load tables.

        p_x_Header_Adj_Assoc_tbl(I)            := l_Header_Adj_Assoc_rec;
        p_x_old_Header_Adj_Assoc_tbl(I)        := l_old_Header_Adj_Assoc_rec;

         IF l_Header_Adj_Assoc_rec.return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         ELSIF l_Header_Adj_Assoc_rec.return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
         END IF;

        OE_MSG_PUB.reset_msg_context('ADJ_ATTS');
    --   loop exception handler.

    EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN

            l_Header_Adj_Assoc_rec.return_status := FND_API.G_RET_STS_ERROR;
            p_x_Header_Adj_Assoc_tbl(I)            := l_Header_Adj_Assoc_rec;
            p_x_old_Header_Adj_Assoc_tbl(I)        := l_old_Header_Adj_Assoc_rec;

		IF l_control_rec.Process_Partial THEN
			ROLLBACK TO SAVEPOINT Header_Price_Assocs;
		ELSE
                RAISE FND_API.G_EXC_ERROR;
	        END IF;


        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

            l_Header_Adj_Assoc_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            p_x_Header_Adj_Assoc_tbl(I)            := l_Header_Adj_Assoc_rec;
            p_x_old_Header_Adj_Assoc_tbl(I)        := l_old_Header_Adj_Assoc_rec;

            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        WHEN OTHERS THEN

            l_Header_Adj_Assoc_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            p_x_Header_Adj_Assoc_tbl(I)            := l_Header_Adj_Assoc_rec;
            p_x_old_Header_Adj_Assoc_tbl(I)        := l_old_Header_Adj_Assoc_rec;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                OE_MSG_PUB.Add_Exc_Msg
                (   G_PKG_NAME
                ,   'Header_price_atts'
                );
            END IF;

            OE_MSG_PUB.reset_msg_context('ADJ_ATTS');
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END;
    I := p_x_Header_Adj_Assoc_tbl.NEXT(I);
    END LOOP;

    --  Load OUT parameters

      adj_debug('Exiting oe_order_Adj_pvt.Header_Adj_Assocs', 1);
      OE_MSG_PUB.reset_msg_context('ADJ_ATTS');

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

      OE_MSG_PUB.reset_msg_context('ADJ_ATTS');
      RAISE;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      OE_MSG_PUB.reset_msg_context('ADJ_ATTS');
      RAISE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Header_Adj_Assocs'
            );
        END IF;


        OE_MSG_PUB.reset_msg_context('ADJ_ATTS');
        adj_debug('Exiting oe_order_Adj_pvt.Header_Adj_Assocs', 1);
end Header_Adj_Assocs;

PROCEDURE Line_Price_Atts
(   p_init_msg_list                 IN VARCHAR2:=FND_API.G_FALSE
,   p_validation_level              IN  NUMBER
,   p_control_rec                   IN  OE_GLOBALS.Control_Rec_Type
,   p_x_Line_Price_Att_tbl          IN OUT NOCOPY  OE_Order_PUB.Line_Price_Att_Tbl_Type
,   p_x_old_Line_Price_Att_tbl      IN OUT NOCOPY  OE_Order_PUB.Line_Price_Att_Tbl_Type
)
is
l_return_status               VARCHAR2(1);
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_Line_price_att_rec        OE_Order_PUB.Line_Price_Att_Rec_Type;
l_old_Line_price_att_rec    OE_Order_PUB.Line_Price_Att_Rec_Type;
-- local variables to store OUT parameters from security check procedures
l_sec_result            NUMBER;
l_on_operation_action   NUMBER;
I 				    pls_integer; -- Used as index for while loop
l_booked_flag			varchar2(1);
l_Shipped_quantity		number;
l_pricing_event                 varchar2(30);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
l_order_source_id           NUMBER;
l_orig_sys_document_ref     VARCHAR2(50);
l_orig_sys_line_ref     VARCHAR2(50);
l_orig_sys_shipment_ref     VARCHAR2(50);
l_change_sequence           VARCHAR2(50);
l_source_document_type_id   NUMBER;
l_source_document_id        NUMBER;
l_source_document_line_id        NUMBER;

BEGIN
l_control_rec := p_control_rec;  -- Added for 1433292
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        OE_MSG_PUB.initialize;
    END IF;

IF l_control_rec.Process_Partial THEN
	SAVEPOINT Line_price_atts;
END IF;

    --  Init local table variables.

	   --dbms_output.put_line('Entering oe_order_Adj_pvt.Line_price_atts');
        adj_debug('Entering oe_order_Adj_pvt.Line_price_atts', 1);

    I := p_x_Line_price_att_tbl.FIRST;

    WHILE I IS NOT NULL LOOP
    BEGIN

        --  Load local records.

        l_Line_price_att_rec := p_x_Line_price_att_tbl(I);

        IF p_x_old_Line_price_att_tbl.EXISTS(I) THEN
            l_old_Line_price_att_rec := p_x_old_Line_price_att_tbl(I);
        ELSE
            l_old_Line_price_att_rec := OE_Order_PUB.G_MISS_Line_Price_Att_REC;
        END IF;

    if l_old_Line_price_att_rec.Order_price_attrib_id = FND_API.G_MISS_NUM  then

      IF l_Line_price_att_rec.Line_Id IS NOT NULL AND
         l_Line_price_att_rec.Line_Id <> FND_API.G_MISS_NUM THEN
         BEGIN
            IF l_debug_level  > 0 THEN
               oe_debug_pub.add('Getting reference data for line_id:'||l_Line_price_att_rec.Line_Id);
            END IF;
            SELECT order_source_id, orig_sys_document_ref, change_sequence,
            source_document_type_id, source_document_id, orig_sys_line_ref,
            source_document_line_id, orig_sys_shipment_ref
            INTO l_order_source_id, l_orig_sys_document_ref, l_change_sequence,
            l_source_document_type_id, l_source_document_id, l_orig_sys_line_ref,
            l_source_document_line_id, l_orig_sys_shipment_ref
            FROM   OE_ORDER_LINES_ALL
            WHERE  line_id = l_Line_price_att_rec.Line_Id;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
                l_order_source_id := null;
                l_orig_sys_document_ref := null;
                l_change_sequence := null;
                l_source_document_type_id := null;
                l_source_document_id := null;
                l_orig_sys_line_ref := null;
                l_source_document_line_id := null;
                l_orig_sys_shipment_ref := null;
            WHEN OTHERS THEN
                l_order_source_id := null;
                l_orig_sys_document_ref := null;
                l_change_sequence := null;
                l_source_document_type_id := null;
                l_source_document_id := null;
                l_orig_sys_line_ref := null;
                l_source_document_line_id := null;
                l_orig_sys_shipment_ref := null;
         END;
      END IF;

      OE_MSG_PUB.set_msg_context(
	 p_entity_code			=> 'LINE_PATTS'
  	,p_entity_id         		=> l_Line_price_att_rec.Order_price_attrib_id
    	,p_header_id         		=> l_Line_price_att_rec.header_Id
    	,p_line_id           		=> l_Line_price_att_rec.Line_Id
        ,p_order_source_id              => l_order_source_id
        ,p_orig_sys_document_ref        => l_orig_sys_document_ref
        ,p_orig_sys_document_line_ref   => l_orig_sys_line_ref
        ,p_orig_sys_shipment_ref        => l_orig_sys_shipment_ref
        ,p_change_sequence              => l_change_sequence
        ,p_source_document_type_id      => l_source_document_type_id
        ,p_source_document_id           => l_source_document_id
        ,p_source_document_line_id      => l_source_document_line_id );

    else

      IF l_old_Line_price_att_rec.Line_Id IS NOT NULL AND
         l_old_Line_price_att_rec.Line_Id <> FND_API.G_MISS_NUM THEN
         BEGIN
               IF l_debug_level  > 0 THEN
                  oe_debug_pub.add('Getting reference data for old line_id:'||l_old_Line_price_att_rec.Line_Id);
               END IF;
               SELECT order_source_id, orig_sys_document_ref, change_sequence,
               source_document_type_id, source_document_id, orig_sys_line_ref,
               source_document_line_id, orig_sys_shipment_ref
               INTO l_order_source_id, l_orig_sys_document_ref, l_change_sequence,
               l_source_document_type_id, l_source_document_id, l_orig_sys_line_ref,
               l_source_document_line_id, l_orig_sys_shipment_ref
               FROM   OE_ORDER_LINES_ALL
               WHERE  line_id = l_old_Line_price_att_rec.Line_Id;
         EXCEPTION
               WHEN NO_DATA_FOUND THEN
                   l_order_source_id := null;
                   l_orig_sys_document_ref := null;
                   l_change_sequence := null;
                   l_source_document_type_id := null;
                   l_source_document_id := null;
                   l_orig_sys_line_ref := null;
                   l_source_document_line_id := null;
                   l_orig_sys_shipment_ref := null;
               WHEN OTHERS THEN
                   l_order_source_id := null;
                   l_orig_sys_document_ref := null;
                   l_change_sequence := null;
                   l_source_document_type_id := null;
                   l_source_document_id := null;
                   l_orig_sys_line_ref := null;
                   l_source_document_line_id := null;
                   l_orig_sys_shipment_ref := null;
         END;
      END IF;

      OE_MSG_PUB.set_msg_context(
	 p_entity_code			=> 'LINE_PATTS'
  	,p_entity_id         		=> l_old_Line_price_att_rec.Order_price_attrib_id
    	,p_header_id         		=> l_old_Line_price_att_rec.header_Id
    	,p_line_id           		=> l_old_Line_price_att_rec.Line_Id
        ,p_order_source_id              => l_order_source_id
        ,p_orig_sys_document_ref        => l_orig_sys_document_ref
        ,p_orig_sys_document_line_ref   => l_orig_sys_line_ref
        ,p_orig_sys_shipment_ref        => l_orig_sys_shipment_ref
        ,p_change_sequence              => l_change_sequence
        ,p_source_document_type_id      => l_source_document_type_id
        ,p_source_document_id           => l_source_document_id
        ,p_source_document_line_id      => l_source_document_line_id );

    end if;

        --  Load API control record

        l_control_rec := OE_GLOBALS.Init_Control_Rec
        (   p_operation     => l_Line_price_att_rec.operation
        ,   p_control_rec   => p_control_rec
        );

        --  Set record return status.

        l_Line_price_att_rec.return_status := FND_API.G_RET_STS_SUCCESS;

        --  Prepare record.

        IF l_Line_price_att_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN

            l_Line_price_att_rec.db_flag := FND_API.G_FALSE;

            --  Set missing old record elements to NULL.

   		 adj_debug('Entering OE_Line_price_att_Util.Convert_Miss_To_Null', 1);
--            l_old_Line_price_att_rec :=
            OE_Line_Pattr_Util.Convert_Miss_To_Null (l_old_Line_price_att_rec);

        ELSIF l_Line_price_att_rec.operation = OE_GLOBALS.G_OPR_UPDATE
        OR    l_Line_price_att_rec.operation = OE_GLOBALS.G_OPR_DELETE
        THEN

            l_Line_price_att_rec.db_flag := FND_API.G_TRUE;

            --  Query Old if missing

            IF  l_old_Line_price_att_rec.order_price_attrib_id = FND_API.G_MISS_NUM
            THEN

                OE_Line_Pattr_Util.Query_Row
                (   p_order_price_attrib_id => l_Line_price_att_rec.order_price_attrib_id
                ,    x_Line_price_att_rec =>                 l_old_Line_price_att_rec
                );

            ELSE

                --  Set missing old record elements to NULL.

--                l_old_Line_price_att_rec :=
                OE_Line_Pattr_Util.Convert_Miss_To_Null (l_old_Line_price_att_rec);

            END IF;

            --  Complete new record from old

--            l_Line_price_att_rec :=
            OE_Line_Pattr_Util.Complete_Record
            (   p_x_Line_price_att_rec              => l_Line_Price_Att_rec
            ,   p_old_Line_price_att_rec          => l_old_Line_Price_Att_rec
            );

      	   OE_MSG_PUB.update_msg_context(
	 	 p_entity_code			=> 'LINE_PATTS'
  		,p_entity_id         		=> l_Line_price_att_rec.order_price_attrib_id
    		,p_header_id         		=> l_Line_price_att_rec.header_Id
    		,p_line_id           		=> l_Line_price_att_rec.line_id);

        END IF;


        IF I = p_x_line_Price_Att_tbl.FIRST THEN
	       IF NOT oe_order_pvt.Valid_Upgraded_Order(l_line_Price_Att_rec.header_id) THEN
                 RAISE FND_API.G_EXC_ERROR;
            END IF;
        END IF;

/*
   -- Check security
   IF l_control_rec.check_security
      AND (l_Line_price_att_rec.operation = OE_GLOBALS.G_OPR_CREATE
         OR l_Line_price_att_rec.operation = OE_GLOBALS.G_OPR_UPDATE)
   THEN

        adj_debug('Check Attributes Security');
        -- check if this operation is allowed
        -- on all the changed attributes
           OE_Line_price_att_Security.Attributes
                (p_Line_price_att_rec   	=> l_Line_Price_Att_rec
                , p_old_Line_price_att_rec	=> l_old_Line_Price_Att_rec
                , x_result      	=> l_sec_result
                , x_return_status 	=> l_return_status
                );

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

           IF l_sec_result = OE_PC_GLOBALS.YES THEN
                RAISE FND_API.G_EXC_ERROR;
           END IF;

    END IF;
*/
        --  Attribute level validation.

            IF p_validation_level > FND_API.G_VALID_LEVEL_NONE THEN

                OE_Validate_Line_Pattr.Attributes
                (   x_return_status               => l_return_status
                ,   p_Line_price_attr_rec         => l_Line_Price_Att_rec
                ,   p_old_Line_price_attr_rec     => l_old_Line_Price_Att_rec
			 ,   p_validation_level			=> p_validation_level
                );

                IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                    RAISE FND_API.G_EXC_ERROR;
                END IF;

            END IF;

            --  Clear dependent attributes.

        IF  l_control_rec.clear_dependents THEN

            OE_Line_Pattr_Util.Clear_Dependent_Attr
            (   p_x_Line_price_att_rec              => l_Line_Price_Att_rec
            ,   p_old_Line_price_att_rec          => l_old_Line_Price_Att_rec
            --,   x_Line_price_att_rec              => l_Line_Price_Att_rec
            );

        END IF;

        --  Default missing attributes
        IF  l_control_rec.default_attributes
        THEN

           OE_Default_Line_Pattr.Attributes
            (   p_x_Line_price_att_rec              => l_Line_Price_Att_rec
            --,   p_old_Line_price_att_rec	      => l_old_Line_Price_Att_rec
            --,   x_Line_price_att_rec              => l_Line_Price_Att_rec
            );

        END IF;

        --  Apply attribute changes

        IF  l_control_rec.change_attributes
        THEN

	   -- This will also log request/s to check duplicity of
	   -- price adjustment entered
            OE_Line_Pattr_Util.Apply_Attribute_Changes
            (   p_x_Line_price_att_rec              => l_Line_Price_Att_rec
            ,   p_old_Line_price_att_rec          => l_old_Line_Price_Att_rec
            --,   x_Line_price_att_rec              => l_Line_Price_Att_rec
            );

        END IF;

	-- If there has any activity causing a change in any attribute
	-- log a request for repricing

        --  Entity level validation.

        IF l_control_rec.validate_entity THEN

            IF l_Line_price_att_rec.operation = OE_GLOBALS.G_OPR_DELETE THEN

                OE_Validate_Line_Pattr.Entity_Delete
                (   x_return_status               => l_return_status
                ,   p_Line_price_attr_rec              => l_Line_Price_Att_rec
                );

            ELSE

                /*OE_Validate_Line_Pattr.Entity
                (   x_return_status               => l_return_status
                ,   p_Line_price_attr_rec              => l_Line_Price_Att_rec
                ,   p_old_Line_price_attr_rec          => l_old_Line_Price_Att_rec
                );*/

               NULL;

            END IF;

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

        END IF;

        --  Step 4. Write to DB

        IF l_control_rec.write_to_db THEN

            IF l_Line_price_att_rec.operation = OE_GLOBALS.G_OPR_DELETE THEN

                OE_Line_Pattr_Util.Delete_Row
                (   p_order_price_attrib_id         => l_Line_price_att_rec.order_price_attrib_id
                );
--2442012
    /*    		OE_delayed_requests_Pvt.log_request(
				p_entity_code 			=> OE_GLOBALS.G_ENTITY_Line_Price_Att,
				p_entity_id         	=> l_Line_Price_Att_rec.line_id,
				p_requesting_entity_code => OE_GLOBALS.G_ENTITY_Line_Price_Att,
				p_requesting_entity_id   => l_Line_Price_Att_rec.line_id,
		 		p_param1                 => l_Line_Price_Att_rec.header_id,
                 	        p_param2                 => 'LINE',
		 		p_request_type           => OE_GLOBALS.G_PRICE_LINE,
		 		x_return_status          => l_return_status);

        		OE_delayed_requests_Pvt.log_request(
				p_entity_code 			=> OE_GLOBALS.G_ENTITY_ALL,
				p_entity_id         	=> l_Line_Price_Att_rec.Header_Id,
				p_requesting_entity_code => OE_GLOBALS.G_ENTITY_ALL,
				p_requesting_entity_id   => l_Line_Price_Att_rec.Header_Id,
		 		p_param1                 => l_Line_Price_Att_rec.header_id,
                 	p_param2                 => 'ORDER',
		 		p_request_type           => OE_GLOBALS.G_PRICE_ORDER,
		 		x_return_status          => l_return_status);
 */
			Begin
				Select booked_flag,Shipped_quantity into
				l_booked_flag,l_Shipped_quantity
				From OE_Order_lines where
				Line_id =	l_Line_Price_Att_rec.Line_Id;
				Exception when no_data_found then
				Null;
			End;

	    		If l_booked_flag='Y' Then
                           l_pricing_event := 'ORDER,BOOK';
                        Else
                           l_pricing_event := 'ORDER';
                        End If;
           		OE_delayed_requests_Pvt.log_request(
					p_entity_code 			=> OE_GLOBALS.G_ENTITY_ALL,
					p_entity_id         	=> l_Line_Price_Att_rec.Header_Id,
					p_requesting_entity_code => OE_GLOBALS.G_ENTITY_ALL,
					p_requesting_entity_id   => l_Line_Price_Att_rec.Header_Id,
                                        p_request_unique_key1    => l_pricing_event,
		 			p_param1                 => l_Line_Price_Att_rec.header_id,
                 		        p_param2                 => l_pricing_event,
		 			p_request_type           => OE_GLOBALS.G_PRICE_ORDER,
		 			x_return_status          => l_return_status);
--			End If;

	    		If l_Shipped_quantity > 0 Then
                         l_pricing_event := 'LINE,SHIP';
                        Else
                         l_pricing_event := 'LINE';
                        End if;
           		OE_delayed_requests_Pvt.log_request(
					p_entity_code 			=> OE_GLOBALS.G_ENTITY_ALL,
					p_entity_id         	=> l_Line_Price_Att_rec.Line_Id,
					p_requesting_entity_code => OE_GLOBALS.G_ENTITY_ALL,
					p_requesting_entity_id   => l_Line_Price_Att_rec.Line_Id,
                                        p_request_unique_key1    => l_pricing_event,
		 			p_param1                 => l_Line_Price_Att_rec.header_id,
                 		p_param2                 => l_pricing_event,
		 			p_request_type           => OE_GLOBALS.G_PRICE_LINE,
		 			x_return_status          => l_return_status);
--2442012			End If;


            ELSE

                --  Get Who Information


                l_Line_price_att_rec.last_update_date := SYSDATE;
                l_Line_price_att_rec.last_updated_by := FND_GLOBAL.USER_ID;
                l_Line_price_att_rec.last_update_login := FND_GLOBAL.LOGIN_ID;

                IF l_Line_price_att_rec.operation = OE_GLOBALS.G_OPR_UPDATE THEN

                    OE_Line_Pattr_Util.Update_Row (l_Line_price_att_rec);

                ELSIF l_Line_price_att_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN

                    l_Line_price_att_rec.creation_date := SYSDATE;
                    l_Line_price_att_rec.created_by    := FND_GLOBAL.USER_ID;

                    --BT
            --Added the If loop for Bug 3402434
            If(l_Line_price_att_rec.order_price_attrib_id is NULL or
               l_Line_price_att_rec.order_price_attrib_id=FND_API.G_MISS_NUM)               THEN
                    select OE_ORDER_PRICE_ATTRIBS_S.nextval
                    into   l_Line_price_att_rec.order_price_attrib_id
                    from dual;
            End If;
                    OE_Line_Pattr_Util.Insert_Row (l_Line_price_att_rec);

                END IF;

            END IF;

        END IF;

        --  Load tables.

        p_x_Line_price_att_tbl(I)            := l_Line_Price_Att_rec;
        p_x_old_Line_price_att_tbl(I)        := l_old_Line_Price_Att_rec;

         IF l_Line_price_att_rec.return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         ELSIF l_Line_price_att_rec.return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
         END IF;

        OE_MSG_PUB.reset_msg_context('HEADER_ADJ');
    --   loop exception handler.

    EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN

            l_Line_price_att_rec.return_status := FND_API.G_RET_STS_ERROR;
            p_x_Line_price_att_tbl(I)            := l_Line_Price_Att_rec;
            p_x_old_Line_price_att_tbl(I)        := l_old_Line_Price_Att_rec;

		IF l_control_rec.Process_Partial THEN
			ROLLBACK TO SAVEPOINT Line_price_atts;
		ELSE
                RAISE FND_API.G_EXC_ERROR;
	        END IF;


        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

            l_Line_price_att_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            p_x_Line_price_att_tbl(I)            := l_Line_Price_Att_rec;
            p_x_old_Line_price_att_tbl(I)        := l_old_Line_Price_Att_rec;

            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        WHEN OTHERS THEN

            l_Line_price_att_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            p_x_Line_price_att_tbl(I)            := l_Line_Price_Att_rec;
            p_x_old_Line_price_att_tbl(I)        := l_old_Line_Price_Att_rec;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                OE_MSG_PUB.Add_Exc_Msg
                (   G_PKG_NAME
                ,   'Line_price_atts'
                );
            END IF;

            OE_MSG_PUB.reset_msg_context('HEADER_PATTS');
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END;
    I := p_x_Line_price_att_tbl.NEXT(I);
    END LOOP;

    --  Load OUT parameters

      adj_debug('Exiting oe_order_Adj_pvt.Line_price_atts', 1);
      OE_MSG_PUB.reset_msg_context('HEADER_PATTS');

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

      OE_MSG_PUB.reset_msg_context('HEADER_PATTS');
      RAISE;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      OE_MSG_PUB.reset_msg_context('HEADER_PATTS');
      RAISE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Line_price_atts'
            );
        END IF;


        OE_MSG_PUB.reset_msg_context('LINE_PATTS');
        adj_debug('Exiting oe_order_Adj_pvt.Line_Price_Atts', 1);
end Line_Price_Atts;


PROCEDURE Insert_Adj_Atts
(p_Line_Adj_attribs_tbl          IN OE_Order_PUB.Line_Adj_Att_Tbl_Type
)
is
  I PLS_INTEGER;
  l_line_dummy_adj_att_tbl OE_Order_PUB.Line_Adj_Att_Tbl_Type;
  l_line_adj_att_tbl       OE_Order_PUB.Line_Adj_Att_Tbl_Type;
  l_control_rec              OE_GLOBALS.Control_Rec_Type;
Begin
 l_line_adj_att_tbl :=  p_Line_Adj_attribs_tbl;

 l_control_rec.private_call         := TRUE;
 l_control_rec.controlled_operation := TRUE;
 l_control_rec.check_security       := TRUE;
 l_control_rec.validate_entity      := FALSE;
 l_control_rec.write_to_db          := TRUE;
 l_control_rec.change_attributes    := FALSE;

  I :=  p_Line_Adj_attribs_tbl.first;

  While I Is Not Null Loop
    --l_line_adj_assoc_tbl(i)            := OE_ORDER_PUB.G_MISS_LINE_ADJ_ASSOC_REC;
    l_line_adj_att_tbl(i).Operation  := OE_Globals.G_OPR_CREATE;

    Select OE_PRICE_ADJ_ATTRIBS_S.nextval
    Into   l_line_adj_att_tbl(i).price_adj_attrib_id
    From   dual;

    I:= p_Line_Adj_attribs_tbl.Next(I);
  End Loop;

Oe_Order_Adj_Pvt.Line_Adj_Atts(  p_validation_level=>FND_API.G_VALID_LEVEL_NONE,
                                   p_control_rec=>l_control_rec,
                                   p_x_Line_Adj_Att_tbl =>l_line_adj_att_tbl,
                                   p_x_old_Line_Adj_Att_tbl=>l_line_dummy_adj_att_tbl);

End Insert_Adj_Atts;



PROCEDURE Line_Adj_Atts
(   p_init_msg_list                 IN VARCHAR2:=FND_API.G_FALSE
,   p_validation_level              IN  NUMBER
,   p_control_rec                   IN  OE_GLOBALS.Control_Rec_Type
,   p_x_Line_Adj_Att_tbl            IN OUT NOCOPY  OE_Order_PUB.Line_Adj_Att_Tbl_Type
,   p_x_old_Line_Adj_Att_tbl        IN OUT NOCOPY  OE_Order_PUB.Line_Adj_Att_Tbl_Type
)
is
l_return_status               VARCHAR2(1);
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_Line_Adj_att_rec        	OE_Order_PUB.Line_Adj_Att_Rec_Type;
l_old_Line_Adj_att_rec    	OE_Order_PUB.Line_Adj_Att_Rec_Type;
-- local variables to store OUT parameters from security check procedures
I 				    pls_integer; -- Used as index for while loop
BEGIN

    IF FND_API.to_Boolean(p_init_msg_list) THEN
        OE_MSG_PUB.initialize;
    END IF;

IF l_control_rec.Process_Partial THEN
	SAVEPOINT Line_Adj_atts;
END IF;

    --  Init local table variables.

	   --dbms_output.put_line('Entering oe_order_Adj_pvt.Line_price_atts');
        adj_debug('Entering oe_order_Adj_pvt.Line_Adj_atts', 1);

    I := p_x_Line_Adj_Att_tbl.FIRST;

    WHILE I IS NOT NULL LOOP
    BEGIN

        --  Load local records.

        l_Line_Adj_Att_rec := p_x_Line_Adj_Att_tbl(I);

        IF p_x_old_Line_Adj_Att_tbl.EXISTS(I) THEN
            l_old_Line_Adj_Att_rec := p_x_old_Line_Adj_Att_tbl(I);
        ELSE
            l_old_Line_Adj_Att_rec := OE_Order_PUB.G_MISS_Line_Adj_Att_REC;
        END IF;

    if l_old_Line_Adj_Att_rec.Price_Adj_attrib_id = FND_API.G_MISS_NUM  then

      OE_MSG_PUB.set_msg_context(
	 p_entity_code			=> 'ADJ_ATTS'
  	,p_entity_id         		=> l_Line_Adj_Att_rec.Price_adj_attrib_id);

    else

      OE_MSG_PUB.set_msg_context(
	 p_entity_code			=> 'ADJ_ATTS'
  	,p_entity_id         		=> l_old_Line_Adj_Att_rec.Price_adj_attrib_id);

    end if;

        --  Load API control record

        l_control_rec := OE_GLOBALS.Init_Control_Rec
        (   p_operation     => l_Line_Adj_Att_rec.operation
        ,   p_control_rec   => p_control_rec
        );

        --  Set record return status.

        l_Line_Adj_Att_rec.return_status := FND_API.G_RET_STS_SUCCESS;

        --  Prepare record.

        IF l_Line_Adj_Att_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN

            l_Line_Adj_Att_rec.db_flag := FND_API.G_FALSE;

            --  Set missing old record elements to NULL.

   		 adj_debug('Entering OE_Line_Adj_Att_Util.Convert_Miss_To_Null', 1);
--            l_old_Line_Adj_Att_rec :=
            Oe_Line_Price_Aattr_util.Convert_Miss_To_Null (l_old_Line_Adj_Att_rec);

        ELSIF l_Line_Adj_Att_rec.operation = OE_GLOBALS.G_OPR_UPDATE
        OR    l_Line_Adj_Att_rec.operation = OE_GLOBALS.G_OPR_DELETE
        THEN

            l_Line_Adj_Att_rec.db_flag := FND_API.G_TRUE;

            --  Query Old if missing

            IF  l_old_Line_Adj_Att_rec.Price_adj_attrib_id = FND_API.G_MISS_NUM
            THEN


                Oe_Line_Price_Aattr_util.Query_Row
                (   p_Price_Adj_Attrib_id => l_Line_Adj_Att_rec.Price_adj_attrib_id
                 ,  x_Line_Adj_Att_rec =>                 l_old_Line_Adj_Att_rec
                );

            ELSE

                --  Set missing old record elements to NULL.

--                l_old_Line_Adj_Att_rec :=
                Oe_Line_Price_Aattr_util.Convert_Miss_To_Null (l_old_Line_Adj_Att_rec);

            END IF;

            --  Complete new record from old

--            l_Line_Adj_Att_rec :=
            Oe_Line_Price_Aattr_util.Complete_Record
            (   p_x_Line_Adj_Att_rec              => l_Line_Adj_Att_rec
            ,   p_old_Line_Adj_Att_rec          => l_old_Line_Adj_Att_rec
            );

      	   OE_MSG_PUB.update_msg_context(
	 	 p_entity_code			=> 'ADJ_ATTS'
  		,p_entity_id         		=> l_Line_Adj_Att_rec.Price_adj_attrib_id);

        END IF;

	   /*
        --  Attribute level validation.

            IF p_validation_level > FND_API.G_VALID_LEVEL_NONE THEN

                OE_Validate_Line_Pattr.Attributes
                (   x_return_status               => l_return_status
                ,   p_Line_price_attr_rec         => l_Line_Adj_Att_rec
                ,   p_old_Line_price_attr_rec     => l_old_Line_Adj_Att_rec
			 ,   p_validation_level			=> p_validation_level
                );

                IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                    RAISE FND_API.G_EXC_ERROR;
                END IF;

            END IF;
	*/

        --  Default missing attributes
        IF  l_control_rec.default_attributes
        THEN

           OE_DEfault_Line_Aattr.Attributes
            (   p_Line_Adj_Att_rec              => l_Line_Adj_Att_rec
            --,   x_Line_Adj_Att_rec              => l_Line_Adj_Att_rec
            );

        END IF;

        --  Apply attribute changes

        IF  l_control_rec.change_attributes
        THEN

	   -- This will also log request/s to check duplicity of
	   -- price adjustment entered
            Oe_Line_Price_Aattr_util.Apply_Attribute_Changes
            (   p_x_Line_Adj_Att_rec              => l_Line_Adj_Att_rec
            ,   p_old_Line_Adj_Att_rec          => l_old_Line_Adj_Att_rec
            --,   x_Line_Adj_Att_rec              => l_Line_Adj_Att_rec
            );

        END IF;

	-- If there has any activity causing a change in any attribute
	-- log a request for repricing

        --  Entity level validation.

        --  Step 4. Write to DB

        IF l_control_rec.write_to_db THEN

            IF l_Line_Adj_Att_rec.operation = OE_GLOBALS.G_OPR_DELETE THEN

                Oe_Line_Price_Aattr_util.Delete_Row
                (   p_Price_Adj_Attrib_id         => l_Line_Adj_Att_rec.Price_adj_attrib_id
                );

            ELSE

                --  Get Who Information

                l_Line_Adj_Att_rec.last_update_date := SYSDATE;
                l_Line_Adj_Att_rec.last_updated_by := FND_GLOBAL.USER_ID;
                l_Line_Adj_Att_rec.last_update_login := FND_GLOBAL.LOGIN_ID;

                IF l_Line_Adj_Att_rec.operation = OE_GLOBALS.G_OPR_UPDATE THEN

                    Oe_Line_Price_Aattr_util.Update_Row (l_Line_Adj_Att_rec);

                ELSIF l_Line_Adj_Att_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN

                    l_Line_Adj_Att_rec.creation_date := SYSDATE;
                    l_Line_Adj_Att_rec.created_by    := FND_GLOBAL.USER_ID;

                    Oe_Line_Price_Aattr_util.Insert_Row (l_Line_Adj_Att_rec);

                END IF;

            END IF;

        END IF;

        --  Load tables.

        p_x_Line_Adj_Att_tbl(I)            := l_Line_Adj_Att_rec;
        p_x_old_Line_Adj_Att_tbl(I)        := l_old_Line_Adj_Att_rec;

         IF l_Line_Adj_Att_rec.return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         ELSIF l_Line_Adj_Att_rec.return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
         END IF;

        OE_MSG_PUB.reset_msg_context('ADJ_ATTS');
    --   loop exception handler.

    EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN

            l_Line_Adj_Att_rec.return_status := FND_API.G_RET_STS_ERROR;
            p_x_Line_Adj_Att_tbl(I)            := l_Line_Adj_Att_rec;
            p_x_old_Line_Adj_Att_tbl(I)        := l_old_Line_Adj_Att_rec;

		IF l_control_rec.Process_Partial THEN
			ROLLBACK TO SAVEPOINT Line_Adj_atts;
		ELSE
                RAISE FND_API.G_EXC_ERROR;
	        END IF;


        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

            l_Line_Adj_Att_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            p_x_Line_Adj_Att_tbl(I)            := l_Line_Adj_Att_rec;
            p_x_old_Line_Adj_Att_tbl(I)        := l_old_Line_Adj_Att_rec;

            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        WHEN OTHERS THEN

            l_Line_Adj_Att_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            p_x_Line_Adj_Att_tbl(I)            := l_Line_Adj_Att_rec;
            p_x_old_Line_Adj_Att_tbl(I)        := l_old_Line_Adj_Att_rec;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                OE_MSG_PUB.Add_Exc_Msg
                (   G_PKG_NAME
                ,   'Line_Adj_atts'
                );
            END IF;

            OE_MSG_PUB.reset_msg_context('ADJ_ATTS');
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END;
    I := p_x_Line_Adj_Att_tbl.NEXT(I);
    END LOOP;

    --  Load OUT parameters

      adj_debug('Exiting oe_order_Adj_pvt.Line_Adj_atts', 1);
      OE_MSG_PUB.reset_msg_context('ADJ_ATTS');

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

      OE_MSG_PUB.reset_msg_context('ADJ_ATTS');
      RAISE;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      OE_MSG_PUB.reset_msg_context('ADJ_ATTS');
      RAISE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Line_Adj_atts'
            );
        END IF;


        OE_MSG_PUB.reset_msg_context('ADJ_ATTS');

        adj_debug('Exiting oe_order_Adj_pvt.Line_Adj_Atts', 1);
end Line_Adj_Atts;

PROCEDURE Insert_Adj_Assocs
(p_Line_Adj_Assoc_tbl          IN OE_Order_PUB.Line_Adj_Assoc_Tbl_Type
)
is
  I PLS_INTEGER;
  l_line_dummy_adj_assoc_tbl OE_Order_PUB.Line_Adj_Assoc_Tbl_Type;
  l_line_adj_assoc_tbl       OE_Order_PUB.Line_Adj_Assoc_Tbl_Type;
  l_control_rec              OE_GLOBALS.Control_Rec_Type;
Begin
 l_line_adj_assoc_tbl :=  p_Line_Adj_Assoc_tbl;
 l_control_rec.private_call         := TRUE;
 l_control_rec.controlled_operation := TRUE;
 l_control_rec.check_security       := TRUE;
 l_control_rec.validate_entity      := FALSE;
 l_control_rec.write_to_db          := TRUE;
 l_control_rec.change_attributes    := FALSE;

  I := p_line_adj_assoc_tbl.first;

  While I Is Not Null Loop
    --l_line_adj_assoc_tbl(i)            := OE_ORDER_PUB.G_MISS_LINE_ADJ_ASSOC_REC;
    l_Line_Adj_Assoc_tbl(i).Operation  := OE_Globals.G_OPR_CREATE;

    Select oe_price_adj_assocs_s.nextval
    Into   l_line_adj_assoc_tbl(i).price_adj_assoc_id
    From   dual;

    I:= p_line_adj_assoc_tbl.Next(I);
  End Loop;

  Oe_Order_Adj_Pvt.Line_Adj_Assocs(p_validation_level=>FND_API.G_VALID_LEVEL_NONE,
                                   p_control_rec=>l_control_rec,
                                   p_x_line_adj_assoc_tbl=>l_line_adj_assoc_tbl,
                                   p_x_old_line_adj_assoc_tbl=>l_line_dummy_adj_assoc_tbl);

End;


PROCEDURE Line_Adj_Assocs
(   p_init_msg_list                 IN VARCHAR2:=FND_API.G_FALSE
,   p_validation_level              IN  NUMBER
,   p_control_rec                   IN  OE_GLOBALS.Control_Rec_Type
,   p_x_Line_Adj_Assoc_tbl          IN OUT NOCOPY  OE_Order_PUB.Line_Adj_Assoc_Tbl_Type
,   p_x_old_Line_Adj_Assoc_tbl      IN OUT NOCOPY  OE_Order_PUB.Line_Adj_Assoc_Tbl_Type
)
is
l_return_status               VARCHAR2(1);
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_Line_Adj_Assoc_rec        	OE_Order_PUB.Line_Adj_Assoc_Rec_Type;
l_old_Line_Adj_Assoc_rec    	OE_Order_PUB.Line_Adj_Assoc_Rec_Type;
-- local variables to store OUT parameters from security check procedures
I 				    pls_integer; -- Used as index for while loop
BEGIN

    IF FND_API.to_Boolean(p_init_msg_list) THEN
        OE_MSG_PUB.initialize;
    END IF;

IF l_control_rec.Process_Partial THEN
	SAVEPOINT Line_Adj_Assocs;
END IF;

    --  Init local table variables.

	   --dbms_output.put_line('Entering oe_order_Adj_pvt.Line_price_atts');
        adj_debug('Entering oe_order_Adj_pvt.Line_Adj_Assocs', 1);

    I := p_x_Line_Adj_Assoc_tbl.FIRST;

    WHILE I IS NOT NULL LOOP
    BEGIN

        --  Load local records.

        l_Line_Adj_Assoc_rec := p_x_Line_Adj_Assoc_tbl(I);

	   adj_debug('The operation is '||l_Line_Adj_Assoc_rec.operation,2);
	   adj_debug('rltd_Adj '||l_Line_Adj_Assoc_rec.RLTD_PRICE_ADJ_ID,2);
	   adj_debug('price adj '||l_Line_Adj_Assoc_rec.PRICE_ADJUSTMENT_ID,2);
        IF p_x_old_Line_Adj_Assoc_tbl.EXISTS(I) THEN
            l_old_Line_Adj_Assoc_rec := p_x_old_Line_Adj_Assoc_tbl(I);
        ELSE
            l_old_Line_Adj_Assoc_rec := OE_Order_PUB.G_MISS_Line_Adj_Assoc_REC;
        END IF;

    if l_old_Line_Adj_Assoc_rec.Price_Adj_assoc_id = FND_API.G_MISS_NUM  then

      OE_MSG_PUB.set_msg_context(
	 p_entity_code			=> 'ADJ_ATTS'
  	,p_entity_id         		=> l_Line_Adj_Assoc_rec.Price_Adj_assoc_id);

    else

      OE_MSG_PUB.set_msg_context(
	 p_entity_code			=> 'ADJ_ATTS'
  	,p_entity_id         		=> l_old_Line_Adj_Assoc_rec.Price_Adj_assoc_id);

    end if;

        --  Load API control record

        l_control_rec := OE_GLOBALS.Init_Control_Rec
        (   p_operation     => l_Line_Adj_Assoc_rec.operation
        ,   p_control_rec   => p_control_rec
        );

        --  Set record return status.

        l_Line_Adj_Assoc_rec.return_status := FND_API.G_RET_STS_SUCCESS;

        --  Prepare record.


        IF l_Line_Adj_Assoc_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN

            l_Line_Adj_Assoc_rec.db_flag := FND_API.G_FALSE;

            --  Set missing old record elements to NULL.

   		 adj_debug('Entering OE_Line_Adj_Assoc_Util.Convert_Miss_To_Null', 1);
--            l_old_Line_Adj_Assoc_rec :=
            Oe_Line_Adj_Assocs_util.Convert_Miss_To_Null (l_old_Line_Adj_Assoc_rec);

        ELSIF l_Line_Adj_Assoc_rec.operation = OE_GLOBALS.G_OPR_UPDATE
        OR    l_Line_Adj_Assoc_rec.operation = OE_GLOBALS.G_OPR_DELETE
        THEN

            l_Line_Adj_Assoc_rec.db_flag := FND_API.G_TRUE;

            --  Query Old if missing

            IF  l_old_Line_Adj_Assoc_rec.Price_Adj_assoc_id = FND_API.G_MISS_NUM
            THEN


                Oe_Line_Adj_Assocs_util.Query_Row
                (   p_Price_Adj_assoc_id => l_Line_Adj_Assoc_rec.Price_Adj_assoc_id
                 ,  x_Line_Adj_Assoc_rec =>                 l_old_Line_Adj_Assoc_rec
                );

            ELSE

                --  Set missing old record elements to NULL.

--                l_old_Line_Adj_Assoc_rec :=
                Oe_Line_Adj_Assocs_util.Convert_Miss_To_Null (l_old_Line_Adj_Assoc_rec);

            END IF;

            --  Complete new record from old

--            l_Line_Adj_Assoc_rec :=
            Oe_Line_Adj_Assocs_util.Complete_Record
            (   p_x_Line_Adj_Assoc_rec              => l_Line_Adj_Assoc_rec
            ,   p_old_Line_Adj_Assoc_rec          => l_old_Line_Adj_Assoc_rec
            );

      	   OE_MSG_PUB.update_msg_context(
	 	 p_entity_code			=> 'ADJ_ATTS'
  		,p_entity_id         		=> l_Line_Adj_Assoc_rec.Price_Adj_assoc_id);

        END IF;

        --  Default missing attributes
        IF  l_control_rec.default_attributes
        THEN

   	 adj_debug('defaulting line adj attributes',2);
           OE_DEfault_Line_Adj_Assocs.Attributes
            (   p_x_Line_Adj_Assoc_rec              => l_Line_Adj_Assoc_rec
           -- ,   x_Line_Adj_Assoc_rec              => l_Line_Adj_Assoc_rec
            );

        END IF;

        --  Apply attribute changes

        IF  l_control_rec.change_attributes
        THEN

	   -- This will also log request/s to check duplicity of
	   -- price adjustment entered
            Oe_Line_Adj_Assocs_util.Apply_Attribute_Changes
            (   p_x_Line_Adj_Assoc_rec              => l_Line_Adj_Assoc_rec
            ,   p_old_Line_Adj_Assoc_rec          => l_old_Line_Adj_Assoc_rec
            --,   x_Line_Adj_Assoc_rec              => l_Line_Adj_Assoc_rec
            );

        END IF;

	-- If there has any activity causing a change in any attribute
	-- log a request for repricing

        --  Entity level validation.

        --  Step 4. Write to DB

        IF l_control_rec.write_to_db THEN

            IF l_Line_Adj_Assoc_rec.operation = OE_GLOBALS.G_OPR_DELETE THEN


     	        adj_debug('deleting line adj assocs',2);
                Oe_Line_Adj_Assocs_util.Delete_Row
                (   p_Price_Adj_assoc_id         => l_Line_Adj_Assoc_rec.Price_Adj_assoc_id
                );

            ELSE

                --  Get Who Information

                l_Line_Adj_Assoc_rec.last_update_date := SYSDATE;
                l_Line_Adj_Assoc_rec.last_updated_by := FND_GLOBAL.USER_ID;
                l_Line_Adj_Assoc_rec.last_update_login := FND_GLOBAL.LOGIN_ID;

                IF l_Line_Adj_Assoc_rec.operation = OE_GLOBALS.G_OPR_UPDATE THEN
     	            adj_debug('updating line adj assocs',2);
                    Oe_Line_Adj_Assocs_util.Update_Row (l_Line_Adj_Assoc_rec);

                ELSIF l_Line_Adj_Assoc_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN
     	            adj_debug('inserting into line adj assocs',2);
                    l_Line_Adj_Assoc_rec.creation_date := SYSDATE;
                    l_Line_Adj_Assoc_rec.created_by    := FND_GLOBAL.USER_ID;

                    Oe_Line_Adj_Assocs_util.Insert_Row (l_Line_Adj_Assoc_rec);

                END IF;

            END IF;

        END IF;

        --  Load tables.

        p_x_Line_Adj_Assoc_tbl(I)            := l_Line_Adj_Assoc_rec;
        p_x_old_Line_Adj_Assoc_tbl(I)        := l_old_Line_Adj_Assoc_rec;

         IF l_Line_Adj_Assoc_rec.return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         ELSIF l_Line_Adj_Assoc_rec.return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
         END IF;

        OE_MSG_PUB.reset_msg_context('ADJ_ATTS');
    --   loop exception handler.

    EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN

            l_Line_Adj_Assoc_rec.return_status := FND_API.G_RET_STS_ERROR;
            p_x_Line_Adj_Assoc_tbl(I)            := l_Line_Adj_Assoc_rec;
            p_x_old_Line_Adj_Assoc_tbl(I)        := l_old_Line_Adj_Assoc_rec;

		IF l_control_rec.Process_Partial THEN
			ROLLBACK TO SAVEPOINT Line_price_atts;
		ELSE
                RAISE FND_API.G_EXC_ERROR;
	        END IF;


        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

            l_Line_Adj_Assoc_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            p_x_Line_Adj_Assoc_tbl(I)            := l_Line_Adj_Assoc_rec;
            p_x_old_Line_Adj_Assoc_tbl(I)        := l_old_Line_Adj_Assoc_rec;

            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        WHEN OTHERS THEN

            l_Line_Adj_Assoc_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            p_x_Line_Adj_Assoc_tbl(I)            := l_Line_Adj_Assoc_rec;
            p_x_old_Line_Adj_Assoc_tbl(I)        := l_old_Line_Adj_Assoc_rec;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                OE_MSG_PUB.Add_Exc_Msg
                (   G_PKG_NAME
                ,   'Header_price_atts'
                );
            END IF;

            OE_MSG_PUB.reset_msg_context('ADJ_ATTS');
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END;
    I := p_x_Line_Adj_Assoc_tbl.NEXT(I);
    END LOOP;

    --  Load OUT parameters

      adj_debug('Exiting oe_order_Adj_pvt.Line_Adj_Assocs', 1);
      OE_MSG_PUB.reset_msg_context('ADJ_ATTS');

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

      OE_MSG_PUB.reset_msg_context('ADJ_ATTS');
      RAISE;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      OE_MSG_PUB.reset_msg_context('ADJ_ATTS');
      RAISE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Line_Adj_Assocs'
            );
        END IF;


        OE_MSG_PUB.reset_msg_context('ADJ_ATTS');
        adj_debug('Exiting oe_order_Adj_pvt.Line_Adj_Assocs', 1);
end Line_Adj_Assocs;

Function Enforce_list_Price
return varchar2
is
l_enforce_price_flag	varchar2(1);
begin
	adj_debug('Entering oe_order_Adj_pvt.Enforce_Price_lists_Flag',1);
begin

	G_STMT_NO := 'Enforce_Price_lists_Flag#10';
	select nvl(enforce_line_prices_flag,'N') into l_enforce_price_flag
	from oe_line_types_v where line_type_id=OE_Order_PUB.G_Line.Line_Type_id;
	exception when no_data_found then
		l_enforce_price_flag := 'N';
end ;

If l_enforce_price_flag='N' then
begin
	G_STMT_NO := 'Enforce_Price_lists_Flag#20';
	select nvl(enforce_line_prices_flag,'N') into l_enforce_price_flag
	from oe_Order_types_v where Order_type_id=OE_Order_PUB.g_hdr.Order_Type_Id;
	exception when no_data_found then
		l_enforce_price_flag := 'N';
end ;
end if;

	adj_debug('Exiting oe_order_Adj_pvt.Enforce_Price_lists_Flag',1);

Return l_enforce_price_flag;

end Enforce_list_Price;

Procedure Enforce_list_Price(
p_line_id IN NUMBER,
p_header_id IN NUMBER,
p_line_type_id IN NUMBER,
px_order_enforce_list_price IN OUT NOCOPY VARCHAR2,
x_line_enforce_list_price OUT NOCOPY VARCHAR2)

is
l_literal_order varchar2(5):='ORDER';
begin
  adj_debug('Entering oe_order_Adj_pvt.Enforce_Price_lists_Flag',1);
    adj_debug('line id:'||p_line_id||' line type:'||p_line_Type_id);
	G_STMT_NO := 'Enforce_Price_lists_Flag#10';
       IF (px_order_enforce_list_price IS NULL) THEN
         begin
             select /* MOAC_SQL_CHANGE */ nvl(enforce_line_prices_flag,'N') into px_order_enforce_list_price
             from oe_transaction_types_all o,oe_order_headers h
             where h.header_id=p_header_id and h.order_type_id=o.transaction_type_id
             and o.transaction_type_code=l_literal_order;
         exception when no_data_found then
              px_order_enforce_list_price := 'N';
        end;
        IF (px_order_enforce_list_price IS NULL) THEN
             px_order_enforce_list_price := 'N';
        END IF;
       END IF;
       IF (px_order_enforce_list_price = 'Y') THEN
           x_line_enforce_list_price := 'Y';
       ELSE
        begin
  	  select nvl(enforce_line_prices_flag,'N') into x_line_enforce_list_price
	  from oe_line_types_v where line_type_id=p_line_type_id;
        exception when no_data_found then
	   x_line_enforce_list_price := 'N';
        end ;
       END IF;
  adj_debug('Exiting oe_order_Adj_pvt.Enforce_Price_lists_Flag',1);

end Enforce_list_Price;

Function Get_Rounding_factor(p_list_header_id number)
return number
is
begin
	If g_rounding_factor_rec.list_header_id = p_list_header_id then
		Return g_rounding_factor_rec.rounding_factor;
	Else
		g_rounding_factor_rec.list_header_id := p_list_header_id;
		select rounding_factor into g_rounding_factor_rec.rounding_factor from
		qp_list_headers_b where list_header_id=p_list_header_id;

		If g_rounding_factor_rec.rounding_factor = fnd_api.g_miss_num then
			g_rounding_factor_rec.rounding_factor:= Null;
		End If;

		Return g_rounding_factor_rec.rounding_factor;

	End if;
	Exception when no_data_found then
		Return Null;
end Get_Rounding_factor;

procedure copy_Header_to_request(
 p_header_rec	 	OE_Order_PUB.Header_Rec_Type
,px_req_line_tbl   in out nocopy	QP_PREQ_GRP.LINE_TBL_TYPE
--,p_pricing_event	varchar2
,p_Request_Type_Code	varchar2
,p_calculate_price_flag varchar2
)
is
l_line_index	pls_integer := px_req_line_tbl.count;
begin
	G_STMT_NO := 'copy_Header_to_request#10';
	adj_debug('Entering oe_order_Adj_pvt.copy_Header_to_request',1);

	l_line_index := l_line_index+1;
	px_req_line_tbl(l_line_index).REQUEST_TYPE_CODE :=p_Request_Type_Code;
	--px_req_line_tbl(l_line_index).PRICING_EVENT :=p_pricing_event;
	--px_req_line_tbl(l_line_index).LIST_LINE_LEVEL_CODE :=p_Request_Type_Code;
	px_req_line_tbl(l_line_index).LINE_INDEX := l_line_index;
	px_req_line_tbl(l_line_index).LINE_TYPE_CODE := 'ORDER';
	-- Hold the header_id in line_id for 'HEADER' Records
	px_req_line_tbl(l_line_index).line_id := p_Header_rec.header_id;
	if  p_header_rec.pricing_date is null or
		 p_header_rec.pricing_date = fnd_api.g_miss_date then
		px_req_line_tbl(l_line_index).PRICING_EFFECTIVE_DATE := trunc(sysdate);
	Else
		px_req_line_tbl(l_line_index).PRICING_EFFECTIVE_DATE := p_header_rec.pricing_date;
	End If;
	px_req_line_tbl(l_line_index).CURRENCY_CODE := p_Header_rec.transactional_curr_code;
	px_req_line_tbl(l_line_index).PRICE_FLAG := p_calculate_price_flag;
	px_req_line_tbl(l_line_index).Active_date_first_type := 'ORD';
	px_req_line_tbl(l_line_index).Active_date_first := p_Header_rec.Ordered_date;

        If p_Header_rec.transactional_curr_code is Not Null Then
         G_ORDER_CURRENCY := p_Header_rec.transactional_curr_code;
        Else
         G_ORDER_CURRENCY := OE_Order_PUB.g_hdr.transactional_curr_code;
        End If;

        --Rounding factor now will be handled by pricing engine.

        px_req_line_tbl(l_line_index).price_request_code := p_header_rec.price_request_code; -- PROMOTIONS SEP/01
	adj_debug('Existing oe_order_Adj_pvt.copy_Header_to_request',1);

end copy_Header_to_request;

procedure copy_Line_to_request(
 p_Line_rec	 		OE_Order_PUB.Line_Rec_Type
,px_req_line_tbl   		in out nocopy 	QP_PREQ_GRP.LINE_TBL_TYPE
,p_pricing_event		varchar2
,p_Request_Type_Code	varchar2
,p_honor_price_flag		VARCHAR2 	Default 'Y'
)
is
l_line_index	pls_integer := nvl(px_req_line_tbl.count,0);
l_uom_rate      NUMBER;
v_discounting_privilege VARCHAR2(30);
l_item_type_code VARCHAR2(30);

l_item_rec                    OE_ORDER_CACHE.item_rec_type; --OPM 2046190

begin
	G_STMT_NO := 'copy_Line_to_request#10';
	adj_debug('Entering oe_order_Adj_pvt.copy_Line_to_request',1);
	l_line_index := l_line_index+1;
	px_req_line_tbl(l_line_index).Line_id := p_Line_rec.line_id;
	px_req_line_tbl(l_line_index).REQUEST_TYPE_CODE := p_Request_Type_Code;
	--px_req_line_tbl(l_line_index).PRICING_EVENT :=p_pricing_event;
	--px_req_line_tbl(l_line_index).LIST_LINE_LEVEL_CODE :=p_price_level_code;
	px_req_line_tbl(l_line_index).LINE_INDEX := l_line_index;
	px_req_line_tbl(l_line_index).LINE_TYPE_CODE := 'LINE';
	If p_Line_rec.pricing_date is null or
		p_Line_rec.pricing_date = fnd_api.g_miss_date then
		px_req_line_tbl(l_line_index).PRICING_EFFECTIVE_DATE := trunc(sysdate);
	Else
		px_req_line_tbl(l_line_index).PRICING_EFFECTIVE_DATE := p_Line_rec.pricing_date;
	End If;

	px_req_line_tbl(l_line_index).LINE_QUANTITY := p_Line_rec.Ordered_quantity ;

	/* -- No need to substract cancell quantity
	If p_Line_rec.cancelled_quantity = fnd_api.g_miss_num Then
	else
		px_req_line_tbl(l_line_index).LINE_QUANTITY := p_Line_rec.Ordered_quantity -
								nvl(p_Line_rec.cancelled_quantity,0);
	End If;
	*/
	px_req_line_tbl(l_line_index).LINE_UOM_CODE := p_Line_rec.Order_quantity_uom;
	px_req_line_tbl(l_line_index).PRICED_QUANTITY := p_Line_rec.pricing_quantity; -- OPM 2547940 moved this up to here from below next block

-- start OPM  2046190
			     -- IF oe_line_util.Process_Characteristics -- INVCONV
        	 IF oe_line_util.dual_uom_control  -- INVCONV
                        (p_line_rec.inventory_item_id
                        ,p_line_rec.ship_from_org_id
                        ,l_item_rec) THEN

           IF l_item_rec.ont_pricing_qty_source = 'S'   THEN -- price by quantity 2 -- invconv
   		oe_debug_pub.add('OPM - ont_pricing_qty_source = S in OEXVADJB.pls  ');
   		        px_req_line_tbl(l_line_index).LINE_QUANTITY := p_Line_rec.Ordered_quantity2 ;
			px_req_line_tbl(l_line_index).LINE_UOM_CODE := p_Line_rec.Ordered_quantity_uom2 ;
				-- OPM 2547940 start
			IF p_line_rec.CALCULATE_PRICE_FLAG in ( 'N', 'P' ) THEN   -- usually split from shipping
			--    below line - need a UOM conversion below if pricing UOM off price list not same as secondary UOM
			--    need check whether split from shipping or not
				IF (p_Line_rec.pricing_quantity_uom = p_Line_rec.Ordered_quantity_uom2) Then
        				px_req_line_tbl(l_line_index).PRICED_QUANTITY := nvl(p_Line_rec.shipped_quantity2,p_Line_rec.Ordered_quantity2);
  	  			Else
        			        adj_debug('OPM in split scenario about to convert ') ;
          				INV_CONVERT.INV_UM_CONVERSION(From_Unit => p_Line_rec.Ordered_quantity_uom2
                                       ,To_Unit   => p_Line_rec.pricing_quantity_uom
                                       ,Item_ID   => p_Line_rec.Inventory_item_id
                                       ,Uom_Rate  => l_Uom_rate);
        		 	 	px_req_line_tbl(l_line_index).PRICED_QUANTITY := nvl(p_Line_rec.shipped_quantity2,p_Line_rec.Ordered_quantity2) * l_uom_rate;
        		 	 	adj_debug('OPM priced quantity after convert is : ' ||px_req_line_tbl(l_line_index).PRICED_QUANTITY) ;
        			END IF;

			END IF;	-- OPM 2547940 end


		else
			px_req_line_tbl(l_line_index).LINE_QUANTITY := p_Line_rec.Ordered_quantity ;
	   		px_req_line_tbl(l_line_index).LINE_UOM_CODE := p_Line_rec.Order_quantity_uom ;
               	END IF;

        adj_debug('OPM pricing quantity is : ' ||px_req_line_tbl(l_line_index).LINE_QUANTITY) ;
	adj_debug('OPM pricing quantity uom is : ' ||px_req_line_tbl(l_line_index).LINE_UOM_CODE) ;

        END IF;

-- end OPM 2046190



	px_req_line_tbl(l_line_index).PRICED_UOM_CODE := p_Line_rec.pricing_quantity_uom;

	px_req_line_tbl(l_line_index).CURRENCY_CODE :=
					OE_Order_PUB.g_hdr.transactional_curr_code;
        -- uom begin
	If p_Line_rec.unit_list_price_per_pqty <> FND_API.G_MISS_NUM Then
		px_req_line_tbl(l_line_index).UNIT_PRICE := p_Line_rec.unit_list_price_per_pqty;

	-- Fix for bug 1834409
	-- Patch 1766558 introduced two new columns in oe_order_lines_all
	-- namely, unit_list_price_per_pqty and unit_selling_price_per_pqty
	-- So, when adding new order lines to upgraded sales orders,
        -- pass the values of unit_list_price and unit_selling_price
	-- to pricing engine for the old order lines

	Elsif p_line_rec.unit_list_price <> FND_API.G_MISS_NUM Then
		px_req_line_tbl(l_line_index).UNIT_PRICE := p_line_rec.unit_list_price;
	else
		 px_req_line_tbl(l_line_index).UNIT_PRICE := Null;
	End If;
        -- uom end

	px_req_line_tbl(l_line_index).PERCENT_PRICE := p_Line_rec.unit_list_percent;

        If (p_Line_rec.service_period = p_Line_rec.Order_quantity_uom) Then
  	  px_req_line_tbl(l_line_index).UOM_QUANTITY := p_Line_rec.service_duration;
        Else
          INV_CONVERT.INV_UM_CONVERSION(From_Unit => p_Line_rec.service_period
                                       ,To_Unit   => p_Line_rec.Order_quantity_uom
                                       ,Item_ID   => p_Line_rec.Inventory_item_id
                                       ,Uom_Rate  => l_Uom_rate);
          px_req_line_tbl(l_line_index).UOM_QUANTITY := p_Line_rec.service_duration * l_uom_rate;
        End If;

         --Rounding factor is now handled by pricing engine

	-- modified by lkxu
     IF p_honor_price_flag = 'N' THEN
	  IF p_line_rec.CALCULATE_PRICE_FLAG = 'X' THEN
		-- this is service parent line, for information only, so don't price it.
		px_req_line_tbl(l_line_index).PRICE_FLAG := 'N';
       ELSE
		px_req_line_tbl(l_line_index).PRICE_FLAG := 'Y';
       END IF;

     ELSE
	  If p_Line_rec.calculate_Price_flag = fnd_api.g_miss_char then
		px_req_line_tbl(l_line_index).PRICE_FLAG := 'Y';
           --included for bug 2046841    Begin
          elsif p_line_rec.calculate_price_flag = 'X' then
		px_req_line_tbl(l_line_index).PRICE_FLAG := 'N';
           --included for bug 2046841    End
	  else
		px_req_line_tbl(l_line_index).PRICE_FLAG := nvl(p_Line_rec.calculate_Price_flag,'Y');
	  end if;
     END IF;

     -- end of modification made by lkxu

        -- Added by JAUTOMO on 20-DEC-00

        -- Get Discounting Privilege Profile Option value
        fnd_profile.get('ONT_DISCOUNTING_PRIVILEGE', v_discounting_privilege);

        -- If the profile is set to UNLIMITED, then even if the Order Type
        -- restrict price changes, the user can change the price

	-- If Enforce list price then execute only the PRICE Event
	If p_pricing_event <> 'PRICE' and
           Enforce_list_price = 'Y' and
           px_req_line_tbl(l_line_index).PRICE_FLAG = 'Y' and
           v_discounting_privilege <> 'UNLIMITED' then

		px_req_line_tbl(l_line_index).PRICE_FLAG := 'P';

	End If;

	-- Execute the pricing phase if the list price is null

	If p_pricing_event = 'PRICE' and
		 px_req_line_tbl(l_line_index).UNIT_PRICE is null then

		px_req_line_tbl(l_line_index).PRICE_FLAG := 'Y' ;

	End If;
	-- Do not execute SHIP event for a line if the line is not ship interfaced.
	If px_req_line_tbl(l_line_index).PRICE_FLAG = 'Y' and
		(p_Line_rec.Shipped_quantity is null or
		p_Line_rec.Shipped_quantity = fnd_api.g_miss_num or
		p_Line_rec.Shipped_quantity = 0 ) and
                --cc1
		p_pricing_event ='SHIP' Then
		px_req_line_tbl(l_line_index).PRICE_FLAG := 'N';
	End If;

        l_item_type_code := oe_line_util.Get_Return_Item_Type_Code(p_Line_rec);

        -- Do not fetch the price for Configuration items and Included Items
        If l_item_type_code in( 'CONFIG','INCLUDED')
	Then

            IF p_line_rec.calculate_price_flag in ( 'Y', 'P' )
            Then
                If ( G_CHARGES_FOR_INCLUDED_ITEM = 'N' and
                       l_item_type_code = 'INCLUDED')
                Then
                  px_req_line_tbl(l_line_index).PRICE_FLAG := 'N';
                Else
                  px_req_line_tbl(l_line_index).PRICE_FLAG := 'P';
                End If;
            Else
                px_req_line_tbl(l_line_index).PRICE_FLAG := 'N';

            End IF;

	End If;

	px_req_line_tbl(l_line_index).Active_date_first_type := 'ORD';
	px_req_line_tbl(l_line_index).Active_date_first := OE_Order_Pub.G_HDR.Ordered_date;

	If p_Line_rec.schedule_ship_date is not null then
	  px_req_line_tbl(l_line_index).Active_date_Second_type := 'SHIP';
	  px_req_line_tbl(l_line_index).Active_date_Second := p_Line_rec.schedule_ship_date;
	End If;
        px_req_line_tbl(l_line_index).price_request_code := p_line_rec.price_request_code; -- PROMOTIONS  SEP/01
        px_req_line_tbl(l_line_index).line_category
               := p_line_rec.line_category_code;

	adj_debug('Existing oe_order_Adj_pvt.copy_Line_to_request',1);

end copy_Line_to_request;

procedure copy_adjs_to_request(
p_line_index					pls_integer
,p_adj_index					pls_integer
,p_Line_adj_rec	 			OE_Order_PUB.Line_Adj_Rec_Type
,px_Req_LINE_DETAIL_tbl   	in out nocopy 	QP_PREQ_GRP.LINE_DETAIL_tbl_Type
)
is
l_RLD_Index 		pls_integer	:= p_adj_index;
begin

			adj_debug('Entering oe_order_Adj_pvt.copy_adjs_to_request',1);

			G_STMT_NO := 'copy_adjs_to_request#10';

			--l_RLD_Index := l_RLD_Index +1 ;

			  -- We want to retain the same index as that of Adj
			  px_Req_LINE_DETAIL_tbl(l_RLD_Index).Line_Detail_Index := l_RLD_Index;
			  px_Req_LINE_DETAIL_tbl(l_RLD_Index).Line_Detail_Type_Code := 'NULL';

			  px_Req_LINE_DETAIL_tbl(l_RLD_Index).Line_Index := p_line_index;

			  px_Req_LINE_DETAIL_tbl(l_RLD_Index).List_header_id := p_Line_Adj_rec.List_Header_Id;
			  px_Req_LINE_DETAIL_tbl(l_RLD_Index).List_Line_Id := p_Line_Adj_rec.List_Line_id;
			  px_Req_LINE_DETAIL_tbl(l_RLD_Index).List_Line_type_Code := p_Line_Adj_rec.List_Line_type_Code;
                 Begin
                    Select list_type_code into
                         px_Req_LINE_DETAIL_tbl(l_RLD_Index).created_from_list_type_code
                    from qp_list_headers_b where
                    list_header_id= p_Line_Adj_rec.List_Header_Id;
                    Exception when no_data_found then
                    adj_debug('Invalid list header '|| p_Line_Adj_rec.List_Header_Id,1);
                 End;

			  px_Req_LINE_DETAIL_tbl(l_RLD_Index).substitution_from := p_Line_Adj_rec.modified_from;
			  px_Req_LINE_DETAIL_tbl(l_RLD_Index).substitution_to := p_Line_Adj_rec.modified_to;
			  px_Req_LINE_DETAIL_tbl(l_RLD_Index).automatic_flag := p_Line_Adj_rec.automatic_flag;
			  px_Req_LINE_DETAIL_tbl(l_RLD_Index).override_flag := p_Line_Adj_rec.update_allowed;
			  px_Req_LINE_DETAIL_tbl(l_RLD_Index).Operand_Calculation_Code :=
					  p_Line_Adj_rec.Arithmetic_Operator;
			  px_Req_LINE_DETAIL_tbl(l_RLD_Index).Operand_Value := p_Line_Adj_rec.Operand_Per_Pqty;
			  px_Req_LINE_DETAIL_tbl(l_RLD_Index).pricing_group_sequence := p_Line_Adj_rec.pricing_group_sequence;
			  px_Req_LINE_DETAIL_tbl(l_RLD_Index).price_break_type_code := p_Line_Adj_rec.price_break_type_code;
			  px_Req_LINE_DETAIL_tbl(l_RLD_Index).pricing_phase_id := p_Line_Adj_rec.pricing_phase_id;
			  px_Req_LINE_DETAIL_tbl(l_RLD_Index).line_quantity := p_Line_Adj_rec.range_break_quantity;
			  px_Req_LINE_DETAIL_tbl(l_RLD_Index).adjustment_amount := p_Line_Adj_rec.adjusted_amount_per_pqty;
			  px_Req_LINE_DETAIL_tbl(l_RLD_Index).applied_flag := p_Line_Adj_rec.applied_flag;

end copy_adjs_to_request;

procedure copy_attribs_to_Req(
p_line_index				number
,p_pricing_contexts_Tbl 		QP_Attr_Mapping_PUB.Contexts_Result_Tbl_Type
,p_qualifier_contexts_Tbl 	QP_Attr_Mapping_PUB.Contexts_Result_Tbl_Type
,px_Req_line_attr_tbl		in out nocopy  QP_PREQ_GRP.LINE_ATTR_TBL_TYPE
,px_Req_qual_tbl			in out  nocopy  QP_PREQ_GRP.QUAL_TBL_TYPE
)
is
i			pls_integer := 0;
l_attr_index	pls_integer := nvl(px_Req_line_attr_tbl.last,0);
l_qual_index	pls_integer := nvl(px_Req_qual_tbl.last,0);
begin
	adj_debug('Entering oe_order_Adj_pvt.copy_attribs_to_Req',1);
	i := p_pricing_contexts_Tbl.First;
	While i is not null loop
		l_attr_index := l_attr_index +1;
		px_Req_line_attr_tbl(l_attr_index).VALIDATED_FLAG := 'N';
		px_Req_line_attr_tbl(l_attr_index).line_index := p_line_index;

			-- Product and Pricing Contexts go into pricing contexts...
			px_Req_line_attr_tbl(l_attr_index).PRICING_CONTEXT :=
								p_pricing_contexts_Tbl(i).context_name;
			px_Req_line_attr_tbl(l_attr_index).PRICING_ATTRIBUTE :=
							p_pricing_contexts_Tbl(i).Attribute_Name;
			px_Req_line_attr_tbl(l_attr_index).PRICING_ATTR_VALUE_FROM :=
							p_pricing_contexts_Tbl(i).attribute_value;

		i := p_pricing_contexts_Tbl.Next(i);
	end loop;
-- Copy the qualifiers
	G_STMT_NO := 'copy_attribs_to_Req#20';
	i := p_qualifier_contexts_Tbl.First;
	While i is not null loop
		l_qual_index := l_qual_index +1;

		If p_qualifier_contexts_Tbl(i).context_name ='MODLIST' and
			p_qualifier_contexts_Tbl(i).Attribute_Name ='QUALIFIER_ATTRIBUTE4' then

			If OE_Order_PUB.G_Line.agreement_id is not null and
				OE_Order_PUB.G_Line.agreement_id <> fnd_api.g_miss_num then
          			px_Req_Qual_Tbl(l_qual_index).Validated_Flag := 'Y';
                        -- BLANKETS: Start Code Merge
                        Elsif OE_Code_Control.Code_Release_Level >= '110509' and
                              OE_Order_PUB.G_Line.blanket_number is not null and
                              OE_Order_PUB.G_Line.blanket_number <> fnd_api.g_miss_num and
                              OE_Order_PUB.G_Line.blanket_line_number is not null and
                              OE_Order_PUB.G_Line.blanket_line_number <> fnd_api.g_miss_num
                        Then

                           -- Set validated_flag to 'Y' if price list is AGR
                           -- type or enforce price list is checked on blanket.
                           If Get_List_Type
                               (OE_Order_PUB.G_Line.price_list_id) = 'AGR'
                              OR Get_Enforce_Price_List
                               (OE_Order_PUB.G_Line.blanket_number
                               ,OE_Order_PUB.G_Line.blanket_line_number)='Y'
                           Then

				px_Req_Qual_Tbl(l_qual_index).Validated_Flag := 'Y';

                           Else

				px_Req_Qual_Tbl(l_qual_index).Validated_Flag := 'N';

                           End If;

                        -- BLANKETS: End Code Merge

			Else
				px_Req_Qual_Tbl(l_qual_index).Validated_Flag := 'N';
			End If;

		Else
          	px_Req_Qual_Tbl(l_qual_index).Validated_Flag := 'N';
		End If;

		px_Req_qual_tbl(l_qual_index).line_index := p_line_index;

		px_Req_qual_tbl(l_qual_index).QUALIFIER_CONTEXT :=
					p_qualifier_contexts_Tbl(i).context_name;
		px_Req_qual_tbl(l_qual_index).QUALIFIER_ATTRIBUTE :=
						p_qualifier_contexts_Tbl(i).Attribute_Name;
		px_Req_qual_tbl(l_qual_index).QUALIFIER_ATTR_VALUE_FROM :=
						p_qualifier_contexts_Tbl(i).attribute_value;

		i := p_qualifier_contexts_Tbl.Next(i);
	end loop;

	adj_debug('Exiting oe_order_Adj_pvt.copy_attribs_to_Req',1);

end copy_attribs_to_Req;

procedure  Append_asked_for(
	p_header_id		number default null
	,p_Line_id			number default null
	,p_line_index				number
	,px_Req_line_attr_tbl		in out nocopy  QP_PREQ_GRP.LINE_ATTR_TBL_TYPE
	,px_Req_qual_tbl			in out  nocopy  QP_PREQ_GRP.QUAL_TBL_TYPE
)
is
i	pls_integer;
-- Using union all to eliminate sort unique
cursor asked_for_cur is
	select flex_title, pricing_context, pricing_attribute1,
	pricing_attribute2 , pricing_attribute3 , pricing_attribute4 , pricing_attribute5 ,
	pricing_attribute6 , pricing_attribute7 , pricing_attribute8 , pricing_attribute9 ,
	pricing_attribute10 , pricing_attribute11 , pricing_attribute12 , pricing_attribute13 ,
	pricing_attribute14 , pricing_attribute15 , pricing_attribute16 , pricing_attribute17 ,
	pricing_attribute18 , pricing_attribute19 , pricing_attribute20 , pricing_attribute21 ,
	pricing_attribute22 , pricing_attribute23 , pricing_attribute24 , pricing_attribute25 ,
	pricing_attribute26 , pricing_attribute27 , pricing_attribute28 , pricing_attribute29 ,
	pricing_attribute30 , pricing_attribute31 , pricing_attribute32 , pricing_attribute33 ,
	pricing_attribute34 , pricing_attribute35 , pricing_attribute36 , pricing_attribute37 ,
	pricing_attribute38 , pricing_attribute39 , pricing_attribute40 , pricing_attribute41 ,
	pricing_attribute42 , pricing_attribute43 , pricing_attribute44 , pricing_attribute45 ,
	pricing_attribute46 , pricing_attribute47 , pricing_attribute48 , pricing_attribute49 ,
	pricing_attribute50 , pricing_attribute51 , pricing_attribute52 , pricing_attribute53 ,
	pricing_attribute54 , pricing_attribute55 , pricing_attribute56 , pricing_attribute57 ,
	pricing_attribute58 , pricing_attribute59 , pricing_attribute60 , pricing_attribute61 ,
	pricing_attribute62 , pricing_attribute63 , pricing_attribute64 , pricing_attribute65 ,
	pricing_attribute66 , pricing_attribute67 , pricing_attribute68 , pricing_attribute69 ,
	pricing_attribute70 , pricing_attribute71 , pricing_attribute72 , pricing_attribute73 ,
	pricing_attribute74 , pricing_attribute75 , pricing_attribute76 , pricing_attribute77 ,
	pricing_attribute78 , pricing_attribute79 , pricing_attribute80 , pricing_attribute81 ,
	pricing_attribute82 , pricing_attribute83 , pricing_attribute84 , pricing_attribute85 ,
	pricing_attribute86 , pricing_attribute87 , pricing_attribute88 , pricing_attribute89 ,
	pricing_attribute90 , pricing_attribute91 , pricing_attribute92 , pricing_attribute93 ,
	pricing_attribute94 , pricing_attribute95 , pricing_attribute96 , pricing_attribute97 ,
	pricing_attribute98 , pricing_attribute99 , pricing_attribute100
	,Override_Flag
 from oe_order_price_attribs a
 where (a.line_id is null and a.header_id = p_header_id )
union all
	select flex_title, pricing_context, pricing_attribute1,
	pricing_attribute2 , pricing_attribute3 , pricing_attribute4 , pricing_attribute5 ,
	pricing_attribute6 , pricing_attribute7 , pricing_attribute8 , pricing_attribute9 ,
	pricing_attribute10 , pricing_attribute11 , pricing_attribute12 , pricing_attribute13 ,
	pricing_attribute14 , pricing_attribute15 , pricing_attribute16 , pricing_attribute17 ,
	pricing_attribute18 , pricing_attribute19 , pricing_attribute20 , pricing_attribute21 ,
	pricing_attribute22 , pricing_attribute23 , pricing_attribute24 , pricing_attribute25 ,
	pricing_attribute26 , pricing_attribute27 , pricing_attribute28 , pricing_attribute29 ,
	pricing_attribute30 , pricing_attribute31 , pricing_attribute32 , pricing_attribute33 ,
	pricing_attribute34 , pricing_attribute35 , pricing_attribute36 , pricing_attribute37 ,
	pricing_attribute38 , pricing_attribute39 , pricing_attribute40 , pricing_attribute41 ,
	pricing_attribute42 , pricing_attribute43 , pricing_attribute44 , pricing_attribute45 ,
	pricing_attribute46 , pricing_attribute47 , pricing_attribute48 , pricing_attribute49 ,
	pricing_attribute50 , pricing_attribute51 , pricing_attribute52 , pricing_attribute53 ,
	pricing_attribute54 , pricing_attribute55 , pricing_attribute56 , pricing_attribute57 ,
	pricing_attribute58 , pricing_attribute59 , pricing_attribute60 , pricing_attribute61 ,
	pricing_attribute62 , pricing_attribute63 , pricing_attribute64 , pricing_attribute65 ,
	pricing_attribute66 , pricing_attribute67 , pricing_attribute68 , pricing_attribute69 ,
	pricing_attribute70 , pricing_attribute71 , pricing_attribute72 , pricing_attribute73 ,
	pricing_attribute74 , pricing_attribute75 , pricing_attribute76 , pricing_attribute77 ,
	pricing_attribute78 , pricing_attribute79 , pricing_attribute80 , pricing_attribute81 ,
	pricing_attribute82 , pricing_attribute83 , pricing_attribute84 , pricing_attribute85 ,
	pricing_attribute86 , pricing_attribute87 , pricing_attribute88 , pricing_attribute89 ,
	pricing_attribute90 , pricing_attribute91 , pricing_attribute92 , pricing_attribute93 ,
	pricing_attribute94 , pricing_attribute95 , pricing_attribute96 , pricing_attribute97 ,
	pricing_attribute98 , pricing_attribute99 , pricing_attribute100
	,Override_Flag
 from oe_order_price_attribs a
 where (p_line_id is not null and a.line_id = p_line_id )
	  ;
begin
	G_STMT_NO := 'Append_asked_for#10';
	adj_debug('Entering oe_order_Adj_pvt.Append_asked_for',1);
	for asked_for_rec in asked_for_cur loop
		If asked_for_rec.flex_title = 'QP_ATTR_DEFNS_PRICING' then
		  if asked_for_rec.PRICING_ATTRIBUTE1 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE1';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := asked_for_rec.PRICING_ATTRIBUTE1;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE2 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE2';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := asked_for_rec.PRICING_ATTRIBUTE2;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE3 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE3';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := asked_for_rec.PRICING_ATTRIBUTE3;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE4 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE4';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := asked_for_rec.PRICING_ATTRIBUTE4;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE5 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE5';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := asked_for_rec.PRICING_ATTRIBUTE5;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE6 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE6';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := asked_for_rec.PRICING_ATTRIBUTE6;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE7 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE7';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := asked_for_rec.PRICING_ATTRIBUTE7;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE8 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE8';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := asked_for_rec.PRICING_ATTRIBUTE8;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE9 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE9';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := asked_for_rec.PRICING_ATTRIBUTE9;
		  end if;

		  if asked_for_rec.PRICING_ATTRIBUTE10 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE10';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE10;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE11 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE11';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE11;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE12 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE12';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE12;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE13 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE13';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE13;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE14 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE14';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE14;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE15 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE15';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE15;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE16 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE16';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE16;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE17 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE17';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE17;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE18 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE18';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE18;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE19 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE19';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE19;
		  end if;

		  if asked_for_rec.PRICING_ATTRIBUTE20 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE20';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE20;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE21 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE21';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE21;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE22 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE22';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE22;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE23 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE23';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE23;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE24 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE24';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE24;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE25 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE25';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE25;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE26 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE26';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE26;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE27 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE27';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE27;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE28 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE28';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE28;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE29 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE29';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE29;
		  end if;

		  if asked_for_rec.PRICING_ATTRIBUTE30 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE30';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE30;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE31 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE31';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE31;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE32 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE32';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE32;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE33 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE33';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE33;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE34 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE34';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE34;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE35 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE35';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE35;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE36 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE36';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE36;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE37 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE37';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE37;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE38 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE38';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE38;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE39 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE39';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE39;
		  end if;

		  if asked_for_rec.PRICING_ATTRIBUTE40 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE40';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE40;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE41 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE41';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE41;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE42 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE42';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE42;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE43 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE43';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE43;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE44 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE44';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE44;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE45 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE45';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE45;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE46 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE46';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE46;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE47 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE47';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE47;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE48 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE48';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE48;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE49 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE49';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE49;
		  end if;

		  if asked_for_rec.PRICING_ATTRIBUTE50 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE50';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE50;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE51 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE51';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE51;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE52 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE52';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE52;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE53 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE53';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE53;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE54 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE54';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE54;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE55 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE55';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE55;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE56 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE56';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE56;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE57 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE57';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE57;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE58 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE58';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE58;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE59 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE59';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE59;
		  end if;

		  if asked_for_rec.PRICING_ATTRIBUTE60 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE60';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE60;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE61 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE61';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE61;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE62 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE62';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE62;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE63 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE63';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE63;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE64 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE64';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE64;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE65 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE65';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE65;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE66 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE66';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE66;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE67 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE67';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE67;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE68 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE68';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE68;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE69 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE69';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE69;
		  end if;

		  if asked_for_rec.PRICING_ATTRIBUTE70 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE70';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE70;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE71 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE71';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE71;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE72 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE72';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE72;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE73 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE73';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE73;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE74 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE74';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE74;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE75 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE75';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE75;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE76 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE76';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE76;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE77 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE77';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE77;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE78 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE78';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE78;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE79 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE79';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE79;
		  end if;

		  if asked_for_rec.PRICING_ATTRIBUTE80 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE80';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE80;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE81 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE81';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE81;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE82 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE82';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE82;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE83 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE83';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE83;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE84 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE84';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE84;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE85 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE85';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE85;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE86 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE86';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE86;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE87 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE87';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE87;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE88 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE88';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE88;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE89 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE89';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE89;
		  end if;

		  if asked_for_rec.PRICING_ATTRIBUTE90 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE90';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE90;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE91 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE91';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE91;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE92 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE92';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE92;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE93 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE93';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE93;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE94 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE94';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE94;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE95 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE95';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE95;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE96 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE96';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE96;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE97 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE97';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE97;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE98 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE98';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE98;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE99 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE99';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=asked_for_rec.PRICING_ATTRIBUTE99;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE100 is not null then
			i := px_Req_line_attr_tbl.count+1;
               px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
               px_Req_line_attr_tbl(i).Validated_Flag := 'N';
		  	px_Req_line_attr_tbl(i).pricing_context := asked_for_rec.pricing_context;
		  	px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE100';
		  	px_Req_line_attr_tbl(i).Pricing_Attr_Value_From:=asked_for_rec.PRICING_ATTRIBUTE100;
		  end if;

		else -- Copy the Qualifiers
		G_STMT_NO := 'Append_asked_for#20';
		  if asked_for_rec.PRICING_ATTRIBUTE1 is not null and asked_for_rec.PRICING_ATTRIBUTE2 is null then -- Promotion
			i := px_Req_Qual_Tbl.count+1;
               px_Req_Qual_Tbl(i).Line_Index := p_Line_Index;
               px_Req_Qual_Tbl(i).Validated_Flag := nvl(asked_for_rec.Override_Flag,'N');
		  	px_Req_Qual_Tbl(i).Qualifier_Context := asked_for_rec.pricing_context;
		  	px_Req_Qual_Tbl(i).Qualifier_Attribute := 'QUALIFIER_ATTRIBUTE1';
		  	px_Req_Qual_Tbl(i).Qualifier_Attr_Value_From := asked_for_rec.PRICING_ATTRIBUTE1;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE2 is not null then --Deal Component
			i := px_Req_Qual_Tbl.count+1;
               px_Req_Qual_Tbl(i).Line_Index := p_Line_Index;
               px_Req_Qual_Tbl(i).Validated_Flag := nvl(asked_for_rec.Override_Flag,'N');
		  	px_Req_Qual_Tbl(i).Qualifier_Context := asked_for_rec.pricing_context;
		  	px_Req_Qual_Tbl(i).Qualifier_Attribute := 'QUALIFIER_ATTRIBUTE2';
		  	px_Req_Qual_Tbl(i).Qualifier_Attr_Value_From := asked_for_rec.PRICING_ATTRIBUTE2;
		  end if;
		  if asked_for_rec.PRICING_ATTRIBUTE3 is not null then -- Coupons
			i := px_Req_Qual_Tbl.count+1;
               px_Req_Qual_Tbl(i).Line_Index := p_Line_Index;
               px_Req_Qual_Tbl(i).Validated_Flag := nvl(asked_for_rec.Override_Flag,'N');
		  	px_Req_Qual_Tbl(i).Qualifier_Context := asked_for_rec.pricing_context;
		  	px_Req_Qual_Tbl(i).Qualifier_Attribute := 'QUALIFIER_ATTRIBUTE3';
		  	px_Req_Qual_Tbl(i).Qualifier_Attr_Value_From := asked_for_rec.PRICING_ATTRIBUTE3;
		  end if;

		end if;
	end loop;

	adj_debug('Exiting oe_order_Adj_pvt.Append_asked_for',1);

end Append_asked_for;

procedure Get_the_parent_Line(p_Reference_line_Id	Number,
					px_Line_Tbl  in out nocopy OE_Order_Pub.Line_Tbl_Type,
					px_Req_related_lines_tbl  in out nocopy QP_PREQ_GRP.Related_Lines_Tbl_Type,
					p_line_Tbl_index	Number)
is
l_Line_Rec		 OE_Order_Pub.Line_Rec_Type;
line_Tbl_Index			pls_integer;
l_related_lines_Index		pls_integer;
Begin
	G_STMT_NO := 'Get_the_parent_Line#10';
	adj_debug('Entering oe_order_Adj_pvt.Get_the_parent_Line',1);
	line_Tbl_Index := px_Line_Tbl.First;
	While line_Tbl_Index is not null loop
		If px_Line_Tbl(line_Tbl_Index).line_Id = p_Reference_line_Id  Then
			Exit;
		End If;
		line_Tbl_Index := px_Line_Tbl.Next(line_Tbl_Index);
	End Loop;

	G_STMT_NO := 'Get_the_parent_Line#20';

	If line_Tbl_Index is null Then
	-- Parent Line is not found in px_line_tbl
		Begin
			line_Tbl_index := px_line_tbl.count+1;

                        oe_line_util.query_row(p_Reference_line_Id,L_Line_Rec );
			px_Line_Tbl(line_Tbl_index) := L_Line_Rec;
                        -- Parent Line is only for info purpose, don't calculate price
                     -- px_Line_Tbl(line_Tbl_index).calculate_price_flag := 'N';
				 -- modified by lkxu, to be used in repricing
                        px_Line_Tbl(line_Tbl_index).calculate_price_flag := 'X';
		Exception when No_Data_Found Then
			Null;
		End;
	End If;
			-- Populate the Relationship
	l_related_lines_Index	:= px_Req_related_lines_tbl.count+1;
	px_Req_related_lines_tbl(l_related_lines_Index).Line_Index := line_Tbl_index;
	px_Req_related_lines_tbl(l_related_lines_Index).Related_Line_Index := p_line_Tbl_index;
	px_Req_related_lines_tbl(l_related_lines_Index).Relationship_Type_Code
											:= QP_PREQ_GRP.G_SERVICE_LINE;

	adj_debug('Exiting oe_order_Adj_pvt.Get_the_parent_Line',1);

End Get_the_parent_Line;

procedure set_item_for_iue(
px_line_rec	 in out nocopy OE_Order_PUB.line_rec_type
,p_req_line_detail_rec 		QP_PREQ_GRP.line_detail_rec_type
)
is
-- This change is required since we are dropping the profile OE_ORGANIZATION    -- _ID. Change made by Esha.
/*l_org_id                 NUMBER := FND_PROFILE.Value('OE_ORGANIZATION_ID');*/
l_org_id NUMBER := OE_Sys_Parameters.VALUE('MASTER_ORGANIZATION_ID');
l_ordered_item			varchar2(300);

begin
	 adj_debug('Entering oe_order_Adj_pvt.set_item_for_iue');

/*begin original item*/
	 oe_debug_pub.ADD('px_line_rec.original_inventory_item_id:'||px_line_rec.INVENTORY_ITEM_ID,1);
	 oe_debug_pub.ADD('px_line_rec.original_inventory_item_id:'||px_line_rec.original_INVENTORY_ITEM_ID,1);
	 oe_debug_pub.ADD('px_line_rec.original_ordered_item_id:'||px_line_rec.ordered_item_id,1);
	 oe_debug_pub.ADD('px_line_rec.original_item_identifier_type:'||px_line_rec.item_identifier_type,1);
	 oe_debug_pub.ADD('px_line_rec.original_ordered_item:'||px_line_rec.ordered_item,1);

	 IF px_line_rec.original_inventory_item_id IS NULL THEN
	 px_line_rec.original_inventory_item_id :=px_line_rec.INVENTORY_ITEM_ID;
	 px_line_rec.original_ordered_item_id :=px_line_rec.ORDERED_ITEM_ID;
	 px_line_rec.original_item_identifier_type :=px_line_rec.item_identifier_type;
	 px_line_rec.original_ordered_item :=px_line_rec.ordered_item;
	 px_line_rec.item_relationship_type :=14;
         END IF;

/*end original item*/

	  -- There is an item upgrade for this line
	 px_line_rec.inventory_item_id := p_req_line_detail_rec.RELATED_ITEM_ID;
	 px_line_rec.item_identifier_type := 'INT'; --bug 2281351
	   If px_line_rec.item_identifier_type ='INT' then
	   	px_line_rec.ordered_item_id := p_req_line_detail_rec.RELATED_ITEM_ID;
	   	Begin
			SELECT concatenated_segments
			INTO   px_line_rec.ordered_item
			FROM   mtl_system_items_kfv
			WHERE  inventory_item_id = px_line_rec.inventory_item_id
			AND    organization_id = l_org_id;
			Exception when no_data_found then
		 	Null;
	  	End;
	  End If;

	 adj_debug('Exiting oe_order_Adj_pvt.set_item_for_iue');
end set_item_for_iue;

procedure Get_item_for_iue(px_line_rec	 in out nocopy OE_Order_PUB.line_rec_type)
is
-- This change is required since we are dropping the profile OE_ORGANIZATION    -- _ID. Change made by Esha.
l_org_id Number:= OE_Sys_Parameters.VALUE('MASTER_ORGANIZATION_ID');
/*l_org_id                 NUMBER := FND_PROFILE.Value('OE_ORGANIZATION_ID');*/
l_ordered_item			varchar2(300);
cursor adj_cur is
	select modified_from from oe_price_adjustments
	where line_id=px_line_rec.line_id
		and list_line_type_code='IUE';
begin
	 adj_debug('Entering oe_order_Adj_pvt.Get_item_for_iue',1);
	 For Adj_rec in Adj_cur loop
	  -- There is an item upgrade for this line
	   px_line_rec.inventory_item_id := to_number(Adj_rec.modified_from);


	   If px_line_rec.item_identifier_type ='INT' then
	   	px_line_rec.ordered_item_id := to_number(Adj_rec.modified_from);
	     Begin
			SELECT concatenated_segments
			INTO   px_line_rec.ordered_item
			FROM   mtl_system_items_kfv
			WHERE  inventory_item_id = px_line_rec.inventory_item_id
			AND    organization_id = l_org_id;
			Exception when no_data_found then
		 	Null;
	  	End;
	  End If;
	  Exit;
	End Loop;

	 adj_debug('Exiting oe_order_Adj_pvt.Get_item_for_iue',1);
end Get_item_for_iue;

procedure calculate_adjustments(
x_return_status out nocopy varchar2,

p_line_id					number default null,
p_header_id				number Default null,
p_Request_Type_Code			varchar2 ,
p_Control_Rec				QP_PREQ_GRP.CONTROL_RECORD_TYPE,
x_req_line_tbl                out  nocopy QP_PREQ_GRP.LINE_TBL_TYPE,
x_Req_qual_tbl                out  nocopy QP_PREQ_GRP.QUAL_TBL_TYPE,
x_Req_line_attr_tbl           out  nocopy QP_PREQ_GRP.LINE_ATTR_TBL_TYPE,
x_Req_LINE_DETAIL_tbl         out  nocopy QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE,
x_Req_LINE_DETAIL_qual_tbl    out  nocopy QP_PREQ_GRP.LINE_DETAIL_QUAL_TBL_TYPE,
x_Req_LINE_DETAIL_attr_tbl    out  nocopy QP_PREQ_GRP.LINE_DETAIL_ATTR_TBL_TYPE,
x_Req_related_lines_tbl       out  nocopy QP_PREQ_GRP.RELATED_LINES_TBL_TYPE,
p_use_current_header          in   Boolean      Default FALSE
--if use_current_header set to true, it will not set the header info
--and it will use current header information set by the caller.
--It is useful when getting a quote where header_id is not available.
--in this case the caller will need to set Oe_Order_Pub.G_Hdr values
,p_write_to_db			  Boolean 	Default TRUE
,x_any_frozen_line out nocopy Boolean

,x_Header_Rec out nocopy oe_Order_Pub.Header_REc_Type

,x_line_Tbl			   in out nocopy  oe_Order_Pub.Line_Tbl_Type
,p_honor_price_flag			VARCHAR2 Default 'Y'
,p_multiple_events                 in   VARCHAR2 Default 'N'
,p_action_code                in VARCHAR2 Default 'NONE'
)
is
l_return_status	 varchar2(1) := FND_API.G_RET_STS_SUCCESS;
l_return_status_Text	 varchar2(240) ;
l_header_rec		OE_Order_PUB.Header_Rec_Type;
l_Line_Tbl		OE_Order_PUB.Line_Tbl_Type;
l_line_tbl_tmp          OE_Order_PUB.Line_Tbl_Type;
--1472635
l_temp_line_tbl         OE_Order_PUB.Line_Tbl_type;
i2                      PLS_INTEGER;
l_all_lines_from_db         Boolean :=False;

l_Line_Rec		OE_Order_PUB.Line_Rec_Type;
l_req_line_tbl                  QP_PREQ_GRP.LINE_TBL_TYPE;
l_Req_qual_tbl                  QP_PREQ_GRP.QUAL_TBL_TYPE;
l_Req_line_attr_tbl             QP_PREQ_GRP.LINE_ATTR_TBL_TYPE;
l_Req_LINE_DETAIL_tbl           QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE;
l_Req_LINE_DETAIL_qual_tbl      QP_PREQ_GRP.LINE_DETAIL_QUAL_TBL_TYPE;
l_Req_LINE_DETAIL_attr_tbl      QP_PREQ_GRP.LINE_DETAIL_ATTR_TBL_TYPE;
l_Req_related_lines_tbl         QP_PREQ_GRP.RELATED_LINES_TBL_TYPE;
l_pricing_contexts_Tbl		  QP_Attr_Mapping_PUB.Contexts_Result_Tbl_Type;
l_qualifier_contexts_Tbl		  QP_Attr_Mapping_PUB.Contexts_Result_Tbl_Type;
lx_req_line_tbl                  QP_PREQ_GRP.LINE_TBL_TYPE;
lx_Req_qual_tbl                  QP_PREQ_GRP.QUAL_TBL_TYPE;
lx_Req_line_attr_tbl             QP_PREQ_GRP.LINE_ATTR_TBL_TYPE;
lx_Req_LINE_DETAIL_tbl           QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE;
lx_Req_LINE_DETAIL_qual_tbl      QP_PREQ_GRP.LINE_DETAIL_QUAL_TBL_TYPE;
lx_Req_LINE_DETAIL_attr_tbl      QP_PREQ_GRP.LINE_DETAIL_ATTR_TBL_TYPE;
lx_Req_related_lines_tbl         QP_PREQ_GRP.RELATED_LINES_TBL_TYPE;
Process_Service_Lines		   Boolean := FALSE;
l_related_lines_Index		   pls_integer;
line_tbl_index				   pls_integer;
i				   pls_integer;
l_bypass_pricing				varchar2(30) :=  nvl(FND_PROFILE.VALUE('QP_BYPASS_PRICING'),'N');
l_dummy					Varchar2(1);
l_header_id                             NUMBER;
l_any_frozen_line BOOLEAN:=FALSE;
l_calculate_price_flag varchar2(1);
l_message_displayed Boolean:=FALSE;
/* Variables added for bug 1828553 */
l_order_line_id  number;
l_service_reference_line_id  number;
--btea begin
l_Control_Rec				QP_PREQ_GRP.CONTROL_RECORD_TYPE;
--btea end
-- Variable for Bug 2124989
l_agreement_name  varchar2(240);
l_revision        varchar2(50);
OE_AGREEMENT_ERROR  Exception;
-- End of 21249898

QP_ATTR_MAPPING_ERROR Exception;
l_completely_frozen BOOLEAN := TRUE;

l_order_status_rec QP_UTIL_PUB.ORDER_LINES_STATUS_REC_TYPE;
l_pass_all_lines	VARCHAR2(30);
l_exists_phase	  	VARCHAR2(1) := 'N';
l_set_of_books Oe_Order_Cache.Set_Of_Books_Rec_Type;
j PLS_INTEGER :=1;
G_INT_CHANGED_LINE_ON Varchar2(3):= nvl(FND_PROFILE.VALUE('ONT_INTERNAL_CHANGED_LINE'),'Y');
l_header_id2 NUMBER;
begin


	  adj_debug('Entering oe_line_adj.calulate_adjustments', 1);

	G_STMT_NO := 'calculate_adjustments#10';
	if (p_line_id is null or p_line_id = FND_API.G_MISS_NUM)
	   and ( p_header_id is null or p_header_id = FND_API.G_MISS_NUM)
	   and  x_line_Tbl.count =0
           and  p_use_current_header = FALSE
	then
		   l_return_status := FND_API.G_RET_STS_ERROR;

		IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
		THEN

		    FND_MESSAGE.SET_NAME('ONT','OE_ATTRIBUTE_REQUIRED');
		    FND_MESSAGE.SET_TOKEN('ATTRIBUTE','line_id or Header Id ');
		    OE_MSG_PUB.Add;
		END IF;
		RAISE FND_API.G_EXC_ERROR;
	end if;

	G_STMT_NO := 'calculate_adjustments#20';
	if p_Line_id is not null and p_Header_id is not null then
		IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
			OE_MSG_PUB.Add_Exc_Msg (   G_PKG_NAME ,
			'oe_line_adj.calulate_adjustments'
			,'Keys are mutually exclusive');
		END IF;
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	end if;

--	Query the header Record
	if p_header_id is not null  and p_Header_id <> FND_API.G_MISS_NUM then

	G_STMT_NO := 'calculate_adjustments#30';

	   Begin

                oe_Header_util.query_row (p_header_id => p_Header_id
                                          ,x_header_rec=>OE_Order_PUB.g_hdr );
		Exception when no_data_found then
			x_return_status := 'NOOP';
			adj_debug(G_STMT_NO||'Invalid header_id '||p_Header_id,1);
			Return;
	   End;
	G_STMT_NO := 'calculate_adjustments#40';

           oe_debug_pub.add('Passed in event code:'||p_control_rec.pricing_event);

	     QP_UTIL_PUB.Get_Order_Lines_Status
               (p_control_rec.pricing_event,l_order_status_rec);

           oe_debug_pub.add('Pricing Engine return pass all_lines value:'||l_order_status_rec.ALL_LINES_FLAG);
           oe_debug_pub.add('Pricing Engine return pass changed line value:'||l_order_status_rec.Changed_Lines_Flag);
           oe_debug_pub.add('Cache header operation:'||oe_order_pub.g_hdr.operation);


        If  G_INT_CHANGED_LINE_ON = 'Y' Then
             If (l_order_status_rec.ALL_LINES_FLAG = 'Y' and nvl(OE_LINE_ADJ_UTIL.G_SEND_ALL_LINES_FOR_DSP,'Y') = 'Y') --bug 2965218
             --   or p_multiple_events = 'Y'
                or (OE_GLOBALS.G_RECURSION_MODE <> FND_API.G_TRUE
                    and p_control_rec.pricing_event = 'BOOK')
                or p_action_code = 'PRICE_ORDER' --user request to reprice all lines
                or Oe_Line_Adj_Util.has_service_lines(p_header_id)
             Then
               ----------------------------------------------------------------
               --Pricing says pass all lines, use query_lines is more efficient
               ----------------------------------------------------------------
               adj_debug('Query all_lines');
               oe_Line_util.query_rows(p_header_id => p_Header_id, x_line_tbl => l_Line_Tbl);
               g_pass_all_lines:='Y';
             Elsif l_order_status_rec.CHANGED_LINES_FLAG = 'Y' OR nvl(OE_LINE_ADJ_UTIL.G_SEND_ALL_LINES_FOR_DSP,'Y') = 'N' Then
               -------------------------------------------------------------------
               --Pricing says pass only changed lines, use query_line
               --------------------------------------------------------------------
               oe_debug_pub.add('Query individual line');
               g_pass_all_lines:='N';
               i := Oe_Line_Adj_Util.G_CHANGED_LINE_TBL.FIRST;
               While i is Not Null Loop
                  Begin
   --bug 3020702
               oe_debug_pub.add(' header_id:'||Oe_Line_Adj_Util.G_CHANGED_LINE_TBL(i).header_id);
     if oe_line_adj_util.G_CHANGED_LINE_TBL(i).header_id = p_header_id then
                  oe_debug_pub.add(' trying to query line_id:'||Oe_Line_Adj_Util.G_CHANGED_LINE_TBL(i).line_id);
                  l_line_tbl(j):=oe_line_util.query_row(p_line_id =>Oe_Line_Adj_Util.G_CHANGED_LINE_TBL(i).line_id);
                  j:=j+1;
     end if;
                  Exception when no_data_found then
                     oe_debug_pub.add('Not found line id:'||Oe_Line_Adj_Util.G_CHANGED_LINE_TBL(i).line_id);
                  End;
                  i:= Oe_Line_Adj_Util.G_CHANGED_LINE_TBL.Next(i);
               End Loop;
             End If;

        Else

          If p_multiple_events = 'N' Then
             -- bug 2089312, call QP API to determine whether or not to
             -- all lines to pricing engine.
           If  l_order_status_rec.ALL_LINES_FLAG = 'Y' Or
               l_order_status_rec.Changed_Lines_Flag = 'Y' Then
               G_PASS_ALL_LINES := 'Y';
           End If;
          Else  --it is a multiple events we always pass all lines when it is a multiple events call
          --  G_PASS_ALL_LINES := 'Y';
              null;
          End If;

             --temporary fix for bug 2199678 for patchset G, we will need
             --to change this later for performacne in book event
             If p_control_rec.pricing_event = 'BOOK' or p_action_code = 'PRICE_ORDER' Then
                G_PASS_ALL_LINES := 'Y';
             End If;

             adj_debug('in calculate_adjustments, all_lines_flag is: '||G_PASS_ALL_LINES,1);
             -- only to pass all lines when the returned all_lines_flag is Y.
             IF G_PASS_ALL_LINES = 'Y' THEN
	       Begin
                 adj_debug('querying up all lines in header: '||p_Header_id,3);
                 oe_Line_util.query_rows(p_header_id => p_Header_id, x_line_tbl => l_Line_Tbl);
                 --1472635
                 l_all_lines_from_db := True;
	       Exception when no_data_found then
	         -- No need to process this order
		 x_return_status := 'NOOP';
		 adj_debug(G_STMT_NO||'Invalid header_id '||p_Header_id,1);
		 Return;
	       End ;
             END IF;
	 End If;  --G_INT_CHANGED_LINE_ON
	else -- Query the line Record
	  G_STMT_NO := 'calculate_adjustments#50';
       If x_line_Tbl.count = 0	Then
		Begin

                   oe_line_util.query_rows(p_line_id =>p_line_id, x_line_tbl=>l_Line_Tbl );


		   Exception when no_data_found then
		   -- No need to process this line
			x_return_status := 'NOOP';
			adj_debug(G_STMT_NO||'Invalid line_id '||p_line_id,1);
			Return;
		End ;
	  Else
		l_Line_Tbl := x_line_Tbl;
	  End If;
	  G_STMT_NO := 'calculate_adjustments#60';

          If p_use_current_header = FALSE Then
	    Begin
	  	If l_line_tbl.first is not null Then
                 oe_Header_util.query_row
		(p_header_id=> l_line_Tbl(l_line_tbl.first).Header_id, x_header_rec => OE_Order_PUB.g_hdr );
                Else
                   oe_debug_pub.add(' Error: No line records in l_line_tbl');
                End If;

		Exception when no_data_found then
		   -- No need to process this order
			x_return_status := 'NOOP';
			adj_debug(G_STMT_NO||'Invalid header_id '||l_line_Tbl(1).Header_id,1);
			Return;
	    End ;
          Else
             --Do Nothing since the flag says that the global record has been set
            NULL;
          End If;
	end if;

	G_STMT_NO := 'calculate_adjustments#110';
	line_Tbl_Index := l_Line_Tbl.First;
	While line_Tbl_Index is not null loop

-- Added to check if Agreement is Active for Bug#2124989


            If l_line_tbl(line_Tbl_Index).agreement_id is not null Then
           BEGIN
                Select 'x' into l_dummy from dual
                where exists (select 'x' from oe_agreements_vl where
                agreement_id = l_line_tbl(line_Tbl_Index).agreement_id and
               ( trunc(nvl(l_line_tbl(line_Tbl_Index).PRICING_DATE,sysdate))
                between
                trunc(nvl(start_date_active, nvl(l_line_tbl(line_Tbl_Index).PRICING_DATE,sysdate)))
                and
                trunc(nvl(end_date_active, nvl(l_line_tbl(line_Tbl_Index).PRICING_DATE, sysdate)))));

               --If l_dummy <>'x' then

              Exception
               When no_data_found then
               Begin
               select name, revision into l_agreement_name, l_revision
               from oe_agreements_vl where agreement_id =
               l_line_tbl(line_Tbl_Index).agreement_id;

               Exception
               When no_data_found then
               null;
               End;
              fnd_message.set_name('ONT','ONT_INVALID_AGR_REVISION');
              fnd_message.set_TOKEN('AGREEMENT',l_agreement_name||' : '||l_revision);
              fnd_message.set_TOKEN('PRICING_DATE',l_line_tbl(line_Tbl_Index).PRICING_DATE);
              OE_MSG_PUB.Add;
              RAISE OE_AGREEMENT_ERROR;
         END;
           End If;
--End 2124989

		-- Do not price the config items
	   --If oe_line_util.Get_Return_Item_Type_Code(l_Line_Tbl(line_Tbl_Index)) <> 'CONFIG' Then


		-- Populate that Global Structure
		OE_Order_PUB.G_LINE := l_Line_Tbl(line_Tbl_Index);
                -- uom begin
		If OE_Order_PUB.G_LINE.unit_list_price_per_pqty = fnd_api.g_miss_num then
			OE_Order_PUB.G_LINE.unit_list_price_per_pqty:= Null;
		End If;
                -- uom end

		-- Check if the line is service item

		G_STMT_NO := 'calculate_adjustments#120';
		If  (OE_Order_PUB.G_LINE.Service_Reference_Line_Id <>
				FND_API.G_MISS_NUM and
			 OE_Order_PUB.G_LINE.Service_Reference_Line_Id is not null)
		Then

/* Added the following if condition for fixing the bug 1828553 */
     /* If the service reference context is ORDER, then the service_reference*/
     /*line_id is the line_id of the parent. However, if the service ref */
     /*context is Customer Product then we need to first retrieve the */
     /*original order line id */

     IF l_Line_Tbl(line_Tbl_Index).item_type_code = 'SERVICE' AND
        l_Line_Tbl(line_Tbl_Index).service_reference_type_code='CUSTOMER_PRODUCT' AND
        l_Line_Tbl(line_Tbl_Index).service_reference_line_id IS NOT NULL THEN
                 oe_debug_pub.add('1828553: Line is a customer product');
           OE_SERVICE_UTIL.Get_Cust_Product_Line_Id
           ( x_return_status    => l_return_status
           , p_reference_line_id => l_Line_Tbl(line_Tbl_Index).service_reference_line_id
           , p_customer_id       => l_Line_Tbl(line_Tbl_Index).sold_to_org_id
           , x_cust_product_line_id => l_order_line_id
           );
        IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
                 oe_debug_pub.add('1828553: Success');
                 oe_debug_pub.add('1828553: Service line id is ' || l_order_line_id)
;
           l_service_reference_line_id := l_order_line_id;
        ELSE
           oe_debug_pub.add('Not able to retrieve cust product line id');
                 RAISE NO_DATA_FOUND;
        END IF;

     ELSE
        l_service_reference_line_id := l_Line_Tbl(line_Tbl_Index).service_reference_line_id;
     END IF;


                 oe_debug_pub.add('1828553: l_Service_Reference_Line_Id: '||l_Service_Reference_Line_Id);
--3273289{
            If(l_Service_Reference_Line_Id is NOT NULL) THEN

		  Get_the_parent_Line(p_Reference_line_Id	=>
					l_Service_Reference_Line_Id,
					p_line_Tbl_Index => line_Tbl_Index,
					px_Req_related_lines_tbl => l_Req_related_lines_tbl,
					px_Line_Tbl => l_Line_Tbl) ;
           END IF;
--3273289}
End If;

		-- Get Line Attributes
		G_STMT_NO := 'calculate_adjustments#130';
                Get_Item_For_Iue(px_line_rec => OE_Order_Pub.G_Line);

	       If l_bypass_pricing = 'Y' Then

			adj_debug('Bypassing the qualifier build',1);
		  Else
			  adj_debug('Before QP_Attr_Mapping_PUB.Build_Contexts for line',1);
                        Begin
		  	  QP_Attr_Mapping_PUB.Build_Contexts(
			     p_request_type_code => 'ONT',
			     p_pricing_type	=>	'L',
			     x_price_contexts_result_tbl => l_pricing_contexts_Tbl,
			     x_qual_contexts_result_tbl  => l_qualifier_Contexts_Tbl
			     );
                         Exception when others then
                          Raise QP_ATTR_MAPPING_ERROR;
                         End;
		  End if;

			G_STMT_NO := 'calculate_adjustments#135';

                --Manual Begin
                If l_line_tbl(line_tbl_index).open_flag = 'N' Then
                 l_line_tbl(line_tbl_index).calculate_price_flag := 'N';
                End If;
                --Manaul End

                --Set a flag if this line has a calculate flag of N or P
                --which is frozen line. This flag will be used later
                --when passing summary line (order level) to pricing engine
                --with calculate_price of N (do not touch the order level amount).

            IF l_line_tbl(line_tbl_index).item_type_code not in ('CONFIG', 'INCLUDED') THEN
                IF ( l_line_tbl(line_tbl_index).calculate_price_flag IN ('N','P') AND
		     l_line_tbl(line_tbl_index).cancelled_flag = 'N') THEN

                   l_any_frozen_line := TRUE;
                   x_any_frozen_line := TRUE;
                   adj_debug('Any frozen line is true');

                  IF l_line_tbl(line_tbl_index).calculate_price_flag = 'P' THEN
                    l_completely_frozen := FALSE;
                   END IF;

                ELSIF l_line_tbl(line_tbl_index).calculate_price_flag = 'Y' THEN
                   l_completely_frozen := FALSE;
                END IF;

         END IF;  /* if item_type_code not in config and included */

		   copy_Line_to_request(
 			   p_Line_rec	 		=> l_Line_Tbl(line_Tbl_Index)
			   ,p_pricing_event		=> p_control_rec.pricing_event
	 		   ,px_req_line_tbl   	=> l_req_line_tbl
	 		   ,p_Request_Type_Code 	=> p_Request_Type_Code
			   ,p_honor_price_flag	=> p_honor_price_flag
	 		   );

		   -- added by lkxu, to set the value back to 'N' after setting price flag.
		   IF l_line_Tbl(line_Tbl_Index).calculate_price_flag = 'X' THEN
		     l_line_Tbl(line_Tbl_Index).calculate_price_flag := 'N';
             	   END IF;

			G_STMT_NO := 'calculate_adjustments#140';
		   copy_attribs_to_Req(
			   p_line_index            => 	l_req_line_tbl.count
			   ,p_pricing_contexts_Tbl 	=> 	l_pricing_contexts_Tbl
			   ,p_qualifier_contexts_Tbl =>	l_qualifier_Contexts_Tbl
			   ,px_Req_line_attr_tbl    =>	l_Req_line_attr_tbl
			   ,px_Req_qual_tbl         =>	l_Req_qual_tbl
				   );


			G_STMT_NO := 'calculate_adjustments#150';
		   Begin
                        l_header_id2:=nvl(p_header_id,l_line_tbl(line_tbl_index).header_id);
			Select 'x' into l_dummy from dual
                        Where exists
                        (select 'x' from
                        oe_order_price_attribs oopa
			where
		        nvl(oopa.line_id,l_Line_Tbl(line_Tbl_Index).line_id) = l_Line_Tbl(line_Tbl_Index).line_id
		      and oopa.header_id = l_header_id2);

		   	Append_asked_for(p_header_id	=> l_header_id2,
			   p_line_id 		=> l_Line_Tbl(line_Tbl_Index).line_id,
			   p_line_index            => 	l_req_line_tbl.count ,
			   px_Req_line_attr_tbl => l_Req_line_attr_tbl,
			   px_Req_qual_tbl  	=> l_Req_qual_tbl
			   );
			Exception when no_data_found then null;
		   End;

                   If G_DEBUG Then
		   for i in 1..l_Req_line_attr_tbl.count
		   loop
			   adj_debug('Pricing context '|| l_Req_line_attr_tbl(i).pricing_Context,3);
			   adj_debug('Value '|| l_Req_line_attr_tbl(i).Pricing_Attribute,3);
			   adj_debug('Name '|| l_Req_line_attr_tbl(i).Pricing_attr_value_from,3);
		   end loop;

		   for i in 1..l_Req_qual_tbl.Count
		   loop
			   adj_debug('qualifier context '|| l_Req_qual_tbl(i).Qualifier_Context,3);
			   adj_debug('Value '|| l_Req_qual_tbl(i).Qualifier_Attribute,3);
			   adj_debug('Name '|| l_Req_qual_tbl(i).Qualifier_Attr_Value_From,3);
		   end loop;
                   End If;

	   --End If; -- Item is not Config

	   line_Tbl_Index := l_Line_Tbl.Next(line_Tbl_Index);

	end loop;

	-- Get Header Attributes

	G_STMT_NO := 'calculate_adjustments#70';

	If l_bypass_pricing = 'Y' Then

		adj_debug('Bypassing the qualifier build',1);
	Else
		adj_debug('Before QP_Attr_Mapping_PUB.Build_Contexts for Header',1);
                Begin
		  QP_Attr_Mapping_PUB.Build_Contexts(
			 p_request_type_code => 'ONT',
			 p_pricing_type	=>	'H',
			 x_price_contexts_result_tbl => l_pricing_contexts_Tbl,
			 x_qual_contexts_result_tbl  => l_qualifier_Contexts_Tbl
			 );
                Exception when others then
                          Raise QP_ATTR_MAPPING_ERROR;
                End;

	end if;
	-- Build header Request

	G_STMT_NO := 'calculate_adjustments#80';

        IF (l_any_frozen_line=TRUE) THEN

          IF l_completely_frozen = FALSE THEN
             l_calculate_price_flag := 'P';
          ELSE
           l_calculate_price_flag := 'N';
          END IF;


            If Not l_message_displayed Then
           --   FND_MESSAGE.SET_NAME('ONT','ONT_LINE_FROZEN');
              --need to a method to display message as hint in the future
              l_message_displayed := TRUE;
            End If;
            l_any_frozen_line:=FALSE;
            --adj_debug('BCT:ONT_LINE_FROZEN');
        Elsif   l_all_lines_from_db = False Then
                --1472635
                --Didn't query from db, need to do that to check if
                --all other previously save lines is frozen
                --adj_debug('BCT all line from db is false');

                If p_header_id is null then
                  --ine_tbl_index := l_line_tbl.first;
                  l_header_id := l_line_tbl(l_line_tbl.first).header_id;
                Else
                  l_header_id := p_header_id;
                End If;
                --adj_debug('BCT order header id '||l_header_id);

                /*oe_line_util.query_rows(p_header_id =>l_header_id, x_line_tbl=>l_temp_Line_Tbl );
                i2 := l_temp_line_tbl.first;
                While i2 is not Null Loop
                  If l_temp_line_tbl(i2).calculate_price_flag In ('N','P') Then
                    --adj_debug('BCT2000 any frozen line found');
                    l_any_frozen_line :=True;
                    x_any_frozen_line :=True;
                    l_calculate_price_flag := 'N';
                    Exit;
                  End If;
                    i2:=l_temp_line_tbl.next(i2);

                End Loop;*/

               Begin

                  BEGIN

                         Select 'x' into l_dummy
                         from dual where
                         exists(select 'x' from oe_order_lines
                                Where header_id = l_header_id
                                and   calculate_price_flag in ('Y','P')
                                and item_type_code not in ('CONFIG', 'INCLUDED'));

                         l_completely_frozen := FALSE;

                  EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                          l_completely_frozen := TRUE;
                          l_any_frozen_line :=True;
                          x_any_frozen_line :=True;
                          l_calculate_price_flag := 'N';
                  END;

                  IF l_completely_frozen = FALSE THEN

                     Select 'p' into l_dummy
                     from dual where
                     exists (select 'x' from oe_order_lines
                             where header_id = l_header_id
                             and calculate_price_flag in ('N', 'P')
			     and cancelled_flag = 'N'
                             and item_type_code not in ('CONFIG', 'INCLUDED') );

                     l_any_frozen_line := TRUE;
                     x_any_frozen_line := TRUE;
                     l_calculate_price_flag := 'P';

                  END IF;

               Exception when no_data_found then
                  null;
               End;

           If nvl(l_calculate_price_flag,'X') not in ('N', 'P') Then
                    l_calculate_price_flag:='Y';
           End If;

        ELSE
           l_calculate_price_flag := 'Y';
        END IF;

	  copy_Header_to_request(
		 p_header_rec       => OE_Order_PUB.g_hdr
		 ,px_req_line_tbl   => l_req_line_tbl
		 ,p_Request_Type_Code => p_Request_Type_Code
                 ,p_calculate_price_flag =>l_calculate_price_flag
		 );

	G_STMT_NO := 'calculate_adjustments#90';
	copy_attribs_to_Req(
		p_line_index             => l_req_line_tbl.count
		,p_pricing_contexts_Tbl 	=> 	l_pricing_contexts_Tbl
		,p_qualifier_contexts_Tbl =>	l_qualifier_Contexts_Tbl
		,px_Req_line_attr_tbl    =>	l_Req_line_attr_tbl
		,px_Req_qual_tbl         =>	l_Req_qual_tbl
					);

	G_STMT_NO := 'calculate_adjustments#100';
	Begin
                -- Modified for bug 3502454
	        --l_header_id2:= nvl(p_header_id,l_line_tbl(l_line_tbl.first).header_id);
                IF ( p_header_id IS NULL ) THEN
                  l_header_id2 := l_line_tbl(l_line_tbl.first).header_id;
                ELSE
                  l_header_id2 := p_header_id;
                END IF;
                -- End of 3502454

		  Select 'x' into l_dummy from dual
                  where exists(
                   Select 'X' from oe_order_price_attribs oopa
		   where oopa.header_id = l_header_id2 and oopa.line_id is null);

		   Append_asked_for(
			p_header_id		=> l_header_id2
			,p_line_index           => l_req_line_tbl.count
			,px_Req_line_attr_tbl   => l_Req_line_attr_tbl
			,px_Req_qual_tbl        => l_Req_qual_tbl
			);

	Exception when no_data_found then null;
                  when others then
                oe_debug_pub.add(sqlerrm);
                oe_debug_pub.add('l_line_tbl.first'||l_line_tbl.first);
	End;

         G_STMT_NO := 'calculate_adjustments#101';

          If G_Debug Then
             for i in 1..l_Req_line_attr_tbl.count
		loop
			adj_debug('Pricing context '|| l_Req_line_attr_tbl(i).pricing_Context,3);
			adj_debug('Value '|| l_Req_line_attr_tbl(i).Pricing_Attribute,3);
			adj_debug('Name '|| l_Req_line_attr_tbl(i).Pricing_attr_value_from,3);
			adj_debug('---------------------------------------------',3);
		end loop;

		for i in 1..l_Req_qual_tbl.Count
		loop
			adj_debug('qualifier context '|| l_Req_qual_tbl(i).Qualifier_Context,3);
			adj_debug('Value '|| l_Req_qual_tbl(i).Qualifier_Attribute,3);
			adj_debug('Name '|| l_Req_qual_tbl(i).Qualifier_Attr_Value_From,3);
			adj_debug('---------------------------------------------',3);
		end loop;


	i:= l_Req_line_tbl.First;
	While i is not null loop
		adj_debug('The Line Index '||l_Req_line_tbl(i).line_index,3);
		adj_debug('The Line_id  '||l_Req_line_tbl(i).line_id,3);
		adj_debug('The Line Type  '||l_Req_line_tbl(i).Line_type_code,3);
		adj_debug('---------------------------------------------',3);
		i:= l_Req_line_tbl.Next(i);
	end loop;

          End If;  --g_debug

	G_STMT_NO := 'calculate_adjustments#160';
	adj_debug('Before  QP_PREQ_GRP.PRICE_REQUEST',1);

        --btea begin
        l_control_rec := p_control_rec;

        --Q means ask pricing engine to determine rounding options.
        l_control_rec.rounding_flag := 'Q';
        l_control_rec.use_multi_currency:='Y';
        l_control_rec.USER_CONVERSION_RATE:= OE_ORDER_PUB.G_HDR.CONVERSION_RATE;
        l_control_rec.USER_CONVERSION_TYPE:= OE_ORDER_PUB.G_HDR.CONVERSION_TYPE_CODE;
        l_set_of_books := Oe_Order_Cache.Load_Set_Of_Books;
        l_control_rec.FUNCTION_CURRENCY   := l_set_of_books.currency_code;

        G_STMT_NO := 'QP_PRICE_REQUEST_GRP';
	QP_PREQ_GRP.PRICE_REQUEST
		(p_control_rec		 => l_control_rec
		,p_line_tbl              => l_Req_line_tbl
 		,p_qual_tbl              => l_Req_qual_tbl
  		,p_line_attr_tbl         => l_Req_line_attr_tbl
		,p_line_detail_tbl       =>l_req_line_detail_tbl
	 	,p_line_detail_qual_tbl  =>l_req_line_detail_qual_tbl
	  	,p_line_detail_attr_tbl  =>l_req_line_detail_attr_tbl
	   	,p_related_lines_tbl     =>l_req_related_lines_tbl
		,x_line_tbl              =>x_req_line_tbl
	   	,x_line_qual             =>x_Req_qual_tbl
	    	,x_line_attr_tbl         =>x_Req_line_attr_tbl
		,x_line_detail_tbl       =>x_req_line_detail_tbl
	 	,x_line_detail_qual_tbl  =>x_req_line_detail_qual_tbl
	  	,x_line_detail_attr_tbl  =>x_req_line_detail_attr_tbl
	   	,x_related_lines_tbl     =>x_req_related_lines_tbl
	    	,x_return_status         =>l_return_status
	    	,x_return_status_Text         =>l_return_status_Text
		);
        --btea end
        G_STMT_NO := 'calculate_adjustments#161';
		adj_debug('------------ After the Price_Request CAll -----------');

        If G_DEBUG Then
	i:= x_Req_line_tbl.First;
	While i is not null loop
		adj_debug('The Line Index '||x_Req_line_tbl(i).line_index,3);
		adj_debug('The Line_id  '||x_Req_line_tbl(i).line_id,3);
		adj_debug('The Line Type  '||x_Req_line_tbl(i).Line_type_code,3);
		adj_debug('Status code  '||x_Req_line_tbl(i).status_code,3);
		adj_debug('---------------------------------------------',3);
		i:= x_Req_line_tbl.Next(i);
	end loop;
	i:= x_req_line_detail_tbl.First;
	While i is not null loop
		adj_debug('('||i||')The line Index '||x_req_line_detail_tbl(i).Line_index,3);
		adj_debug('The line Detail Index '||x_req_line_detail_tbl(i).Line_Detail_Index,3);
		adj_debug('The List Line '||x_req_line_detail_tbl(i).List_Line_id,3);
		adj_debug('------------------------------------------------',3);
		i:= x_req_line_detail_tbl.Next(i);
	End Loop;
	i:= x_Req_related_lines_tbl.First;
	While i is not null loop
		adj_debug('Line Detail '||x_Req_related_lines_tbl(i).Line_detail_index,3);
		adj_debug('relation type '||x_Req_related_lines_tbl(i).relationship_type_code,3);
		adj_debug('rltd line detail index '||x_Req_related_lines_tbl(i).related_line_detail_index,3);
	 adj_debug('--------------------------------------------------------',3);
		i:= x_Req_related_lines_tbl.Next(i);
	 end loop;
         End If;

		IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
			RAISE FND_API.G_EXC_ERROR;
		END IF;

	    	x_return_status         		:= 	l_return_status;
		/*
		x_Req_line_tbl              	:=	l_req_line_tbl;
	   	x_Req_qual_Tbl             	:=	l_Req_qual_tbl;
	    	x_Req_line_attr_tbl         	:=	l_Req_line_attr_tbl;
		x_Req_line_detail_tbl       	:=	l_req_line_detail_tbl;
	 	x_Req_line_detail_qual_tbl  	:=	l_req_line_detail_qual_tbl;
	  	x_Req_line_detail_attr_tbl  	:=	l_req_line_detail_attr_tbl;
	   	x_Req_related_lines_tbl     	:=	l_req_related_lines_tbl;
		*/

		x_header_Rec				:=   OE_Order_PUB.g_hdr;
		x_line_tbl				:=   l_line_tbl;

                --reseting global structure after engine call
                OE_Order_PUB.G_LINE := NULL;
                OE_Order_PUB.G_HDR  := NULL;
	  -- Process the lines...

	  adj_debug('Exiting oe_order_Adj_pvt.calulate_adjustments', 1);

    EXCEPTION

	    WHEN FND_API.G_EXC_ERROR THEN

		  FND_MESSAGE.SET_NAME('ONT','OE_PRICING_ERROR');
		  FND_MESSAGE.SET_TOKEN('ERR_TEXT',l_return_status_Text);
		  OE_MSG_PUB.Add;
		  x_return_status := FND_API.G_RET_STS_ERROR;

			adj_debug('g_exc_error is '||g_stmt_no||' '||sqlerrm,1);
			adj_debug('g_exc_error is '||l_return_status_Text);

			RAISE FND_API.G_EXC_ERROR;

                      /* Added for Bug 2124989 */
               WHEN OE_AGREEMENT_ERROR Then
                 x_return_status := FND_API.G_RET_STS_ERROR;
                 oe_debug_pub.add('Error: Invalid AAgreement');
                 RAISE FND_API.G_EXC_ERROR;

               /* END 2124989 */
                WHEN QP_ATTR_MAPPING_ERROR THEN
                   FND_MESSAGE.SET_NAME('ONT','OE_PRICING_ERROR');
                   FND_MESSAGE.SET_TOKEN('ERR_TEXT','Please make sure Run QP Build Sourcing Rule has completed sucessfully');
                   OE_MSG_PUB.Add;
                   oe_debug_pub.add(' QP Attr Mapping threw exception');
                   RAISE FND_API.G_EXC_ERROR;
		WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

		  FND_MESSAGE.SET_NAME('ONT','OE_PRICING_ERROR');
		  FND_MESSAGE.SET_TOKEN('ERR_TEXT',l_return_status_Text);
		  OE_MSG_PUB.Add;
			x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
			adj_debug('G_EXC_UNEXPECTED_ERROR is '||g_stmt_no||' '||sqlerrm,1);
			adj_debug('G_EXC_UNEXPECTED_ERROR is '||l_return_status_Text);

			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

		WHEN OTHERS THEN

			x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
			--dbms_output.put_line('Error is '||sqlerrm);
			adj_debug('Error Code is '||g_stmt_no||' '||sqlerrm,1);

			IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
			THEN
				OE_MSG_PUB.Add_Exc_Msg
				(   G_PKG_NAME
				,   'oe_line_adj.calulate_adjustments',
					g_stmt_no||' '||sqlerrm
				);
			END IF;

			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

end calculate_adjustments;

Function Update_Adj_Line_rec(
		p_Line_Adj_Rec		in out nocopy OE_Order_Pub.Line_Adj_Rec_Type
		,p_req_line_detail_Rec   qp_preq_grp.line_detail_rec_type
		)
Return Boolean
is
l_updated_Flag		Boolean := False;
x_return_status            VARCHAR2(240);
x_return_status_txt        VARCHAR2(240);
Begin
          /* Start: Added by Manish */
          IF p_Line_Adj_Rec.OPERATION <> OE_GLOBALS.G_OPR_CREATE THEN
			p_Line_Adj_Rec.operation := OE_GLOBALS.G_OPR_UPDATE;
		END IF;
          /* End: Added by Manish */

		adj_debug('Entering oe_order_Adj_pvt.Update_Adj_Line_rec',1);
		G_STMT_NO := 'Update_Adj_Line_rec#10';

		   if not OE_GLOBALS.Equal(p_Line_Adj_Rec.list_header_id,
					p_req_line_detail_Rec.list_header_id) then
			p_Line_Adj_Rec.list_header_id :=
				p_req_line_detail_Rec.list_header_id;
			l_updated_Flag := True;
		   end If;

		   If not OE_GLOBALS.Equal(p_Line_Adj_Rec.list_Line_id,
				p_req_line_detail_Rec.list_Line_id) Then
			p_Line_Adj_Rec.list_Line_id :=
				p_req_line_detail_Rec.list_Line_id;
			l_updated_Flag := True;
		   end If;

		   if not OE_GLOBALS.Equal(p_Line_Adj_Rec.Automatic_flag,
				p_req_line_detail_Rec.Automatic_flag) Then
			p_Line_Adj_Rec.Automatic_flag :=
					p_req_line_detail_Rec.Automatic_flag;
			l_updated_Flag := True;
		   end If;

		   if not OE_GLOBALS.Equal(p_Line_Adj_Rec.list_line_type_code,
					p_req_line_detail_Rec.list_line_type_code) Then
			p_Line_Adj_Rec.list_line_type_code :=
					p_req_line_detail_Rec.list_line_type_code;
			l_updated_Flag := True;
		   end If;

             if not OE_GLOBALS.Equal(p_Line_Adj_Rec.list_line_no, p_req_line_detail_Rec.list_line_no) Then
                      if (not l_updated_flag) and p_Line_Adj_Rec.list_line_type_code = 'CIE' Then
                       adj_debug('CIE:to delete coupon'||p_req_line_detail_rec.list_line_no);
                         -- retain the original coupon number, delete the new number
                         QP_COUPON_PVT.Delete_Coupon(p_req_line_detail_Rec.list_line_no,
                                                     x_return_status,
                                                     x_return_status_txt
                                                    );
                         IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
  		  	   FND_MESSAGE.SET_NAME('ONT','OE_PRICING_ERROR');
		  	   FND_MESSAGE.SET_TOKEN('ERR_TEXT',x_return_status_txt);
 		  	   OE_MSG_PUB.Add;
                           RAISE FND_API.G_EXC_ERROR;
                         END IF;
                      else
			p_Line_Adj_Rec.list_line_no :=  p_req_line_detail_Rec.list_line_no;
			l_updated_Flag := True;
                      end If;
		   end If;

		   if p_Line_Adj_Rec.list_line_type_code = 'TSN' and  -- Terms substitution
		   	not OE_GLOBALS.Equal(p_Line_Adj_Rec.modified_from,
					p_req_line_detail_Rec.substitution_from) Then

			Begin
				p_Line_Adj_Rec.modified_from := p_req_line_detail_Rec.substitution_from;
				l_updated_Flag := True;
			Exception when value_error then
				adj_debug('Value error , The term is not updated '||p_req_line_detail_Rec.substitution_From);
			End;

		   end If;

		   if p_Line_Adj_Rec.list_line_type_code = 'TSN' and  -- Terms substitution
		   	not OE_GLOBALS.Equal(p_Line_Adj_Rec.modified_to,
					p_req_line_detail_Rec.substitution_to) Then

			Begin
		   		p_Line_Adj_Rec.modified_to := p_req_line_detail_Rec.substitution_to;
			 	l_updated_Flag := True;
			Exception when value_error then
				adj_debug('Value error , The term is not updated '||p_req_line_detail_Rec.substitution_to);
			End;

		   end If;

		   if p_Line_Adj_Rec.list_line_type_code = 'IUE' and  -- Terms substitution
		   	not OE_GLOBALS.Equal(p_Line_Adj_Rec.modified_from,
					to_char(p_req_line_detail_Rec.INVENTORY_ITEM_ID)) Then

		   	p_Line_Adj_Rec.modified_from := to_char(p_req_line_detail_Rec.INVENTORY_ITEM_ID);
			l_updated_Flag := True;

		   end If;

		   if p_Line_Adj_Rec.list_line_type_code = 'IUE' and  -- Terms substitution
		   	not OE_GLOBALS.Equal(p_Line_Adj_Rec.modified_to,
					to_char(p_req_line_detail_Rec.RELATED_ITEM_ID)) Then

		   	p_Line_Adj_Rec.modified_to := to_char(p_req_line_detail_Rec.RELATED_ITEM_ID);
			l_updated_Flag := True;

		   end If;

		   if not OE_GLOBALS.Equal(p_Line_Adj_Rec.arithmetic_operator,
					p_req_line_detail_Rec.Operand_Calculation_Code) Then
			p_Line_Adj_Rec.arithmetic_operator := p_req_line_detail_Rec.Operand_Calculation_Code;
			l_updated_Flag := True;
		   end If;

		   if not OE_GLOBALS.Equal(p_Line_Adj_Rec.operand_per_pqty,
					p_req_line_detail_Rec.Operand_Value) Then
			p_Line_Adj_Rec.operand_per_pqty := p_req_line_detail_Rec.Operand_Value;
                        If  p_req_line_detail_Rec.Operand_Value is null Then
                           Oe_Debug_Pub.add(' Null operand returned by pricing');
                           Oe_Debug_pub.add(' List line type:'||p_req_line_detail_Rec.list_line_type_code);
                           Oe_debug_pub.add(' list line id:'||p_req_line_detail_Rec.list_line_id);
                        End If;
			l_updated_Flag := True;
		   end If;

		   if not OE_GLOBALS.Equal(p_Line_Adj_Rec.Applied_flag ,
					p_req_line_detail_Rec.Applied_Flag) or p_Line_Adj_Rec.Applied_flag is null
					Then
			p_Line_Adj_Rec.Applied_flag :=  nvl(p_req_line_detail_Rec.Applied_Flag,'N');
			l_updated_Flag := True;
		   end If;

		   if not OE_GLOBALS.Equal(p_Line_Adj_Rec.update_allowed,
					p_req_line_detail_Rec.Override_flag) Then
			p_Line_Adj_Rec.update_allowed :=  p_req_line_detail_Rec.Override_flag;
			l_updated_Flag := True;
		   end If;

		   if not OE_GLOBALS.Equal(p_Line_Adj_Rec.Pricing_phase_id,
					p_req_line_detail_Rec.Pricing_phase_id) Then
			p_Line_Adj_Rec.Pricing_phase_id :=  p_req_line_detail_Rec.Pricing_phase_id;
			l_updated_Flag := True;
		   end If;

		   if not OE_GLOBALS.Equal(p_Line_Adj_Rec.adjusted_amount_per_pqty,
					p_req_line_detail_Rec.Adjustment_Amount) Then
			p_Line_Adj_Rec.adjusted_amount_per_pqty :=  p_req_line_detail_Rec.Adjustment_Amount;
			l_updated_Flag := True;
		   end If;

		   if not OE_GLOBALS.Equal(p_Line_Adj_Rec.pricing_group_sequence,
					p_req_line_detail_Rec.pricing_group_sequence) Then
			p_Line_Adj_Rec.pricing_group_sequence :=  p_req_line_detail_Rec.pricing_group_sequence;
			l_updated_Flag := True;
		   end If;

		   if not OE_GLOBALS.Equal(p_Line_Adj_Rec.range_break_quantity,
					p_req_line_detail_Rec.line_quantity) Then
			p_Line_Adj_Rec.range_break_quantity :=  p_req_line_detail_Rec.line_quantity;
			l_updated_Flag := True;
		   end If;

		   if not OE_GLOBALS.Equal(p_Line_Adj_Rec.price_break_type_code,
					p_req_line_detail_Rec.price_break_type_code) Then
			p_Line_Adj_Rec.price_break_type_code :=  p_req_line_detail_Rec.price_break_type_code;
			l_updated_Flag := True;
		   end If;

		   if not OE_GLOBALS.Equal(p_Line_Adj_Rec.print_on_invoice_flag,
					p_req_line_detail_Rec.print_on_invoice_flag) Then
			p_Line_Adj_Rec.print_on_invoice_flag :=  p_req_line_detail_Rec.print_on_invoice_flag;
			l_updated_Flag := True;
		   end If;

		   if not OE_GLOBALS.Equal(p_Line_Adj_Rec.print_on_invoice_flag,
					p_req_line_detail_Rec.print_on_invoice_flag) Then
			p_Line_Adj_Rec.print_on_invoice_flag :=  p_req_line_detail_Rec.print_on_invoice_flag;
			l_updated_Flag := True;
		   end If;

		   if not OE_GLOBALS.Equal(p_Line_Adj_Rec.substitution_attribute,
					p_req_line_detail_Rec.substitution_attribute) Then
			p_Line_Adj_Rec.substitution_attribute :=  p_req_line_detail_Rec.substitution_attribute;
			l_updated_Flag := True;
		   end If;

		   if not OE_GLOBALS.Equal(p_Line_Adj_Rec.Accrual_flag,
					p_req_line_detail_Rec.Accrual_flag) Then
			p_Line_Adj_Rec.Accrual_flag :=  p_req_line_detail_Rec.Accrual_flag;
			l_updated_Flag := True;
		   end If;

		   if not OE_GLOBALS.Equal(p_Line_Adj_Rec.accrual_conversion_rate,
					p_req_line_detail_Rec.accrual_conversion_rate) Then
			p_Line_Adj_Rec.accrual_conversion_rate :=  p_req_line_detail_Rec.accrual_conversion_rate;
			l_updated_Flag := True;
		   end If;

		   if not OE_GLOBALS.Equal(p_Line_Adj_Rec.charge_type_code,
					p_req_line_detail_Rec.charge_type_code) Then
			p_Line_Adj_Rec.charge_type_code :=  p_req_line_detail_Rec.charge_type_code;
			l_updated_Flag := True;
		   end If;

		   if not OE_GLOBALS.Equal(p_Line_Adj_Rec.charge_subtype_code,
					p_req_line_detail_Rec.charge_subtype_code) Then
			p_Line_Adj_Rec.charge_subtype_code :=  p_req_line_detail_Rec.charge_subtype_code;
			l_updated_Flag := True;
		   end If;


		   if not OE_GLOBALS.Equal(p_Line_Adj_Rec.include_on_returns_flag,
					p_req_line_detail_Rec.include_on_returns_flag) Then
			p_Line_Adj_Rec.include_on_returns_flag :=  p_req_line_detail_Rec.include_on_returns_flag;
			l_updated_Flag := True;
		   end If;

		   if not OE_GLOBALS.Equal(p_Line_Adj_Rec.benefit_uom_code,
					p_req_line_detail_Rec.benefit_uom_code) Then
			p_Line_Adj_Rec.benefit_uom_code :=  p_req_line_detail_Rec.benefit_uom_code;
			l_updated_Flag := True;
		   end If;

		   if not OE_GLOBALS.Equal(p_Line_Adj_Rec.Benefit_qty, p_req_line_detail_Rec.Benefit_qty) Then
			p_Line_Adj_Rec.Benefit_qty :=  p_req_line_detail_Rec.Benefit_qty;
			l_updated_Flag := True;
		   end If;

		   if not OE_GLOBALS.Equal(p_Line_Adj_Rec.proration_type_code,
					p_req_line_detail_Rec.proration_type_code) Then
			p_Line_Adj_Rec.proration_type_code :=  p_req_line_detail_Rec.proration_type_code;
			l_updated_Flag := True;
		   end If;

/*		   if not OE_GLOBALS.Equal(p_Line_Adj_Rec.list_line_no, p_req_line_detail_Rec.list_line_no) Then
			p_Line_Adj_Rec.list_line_no :=  p_req_line_detail_Rec.list_line_no;
			l_updated_Flag := True;
		   end If;
*/
		   if not OE_GLOBALS.Equal(p_Line_Adj_Rec.source_system_code,
					p_req_line_detail_Rec.source_system_code) Then
			p_Line_Adj_Rec.source_system_code :=  p_req_line_detail_Rec.source_system_code;
			l_updated_Flag := True;
		   end If;

		   if not OE_GLOBALS.Equal(p_Line_Adj_Rec.expiration_date,
					p_req_line_detail_Rec.expiration_date) Then
			p_Line_Adj_Rec.expiration_date :=  p_req_line_detail_Rec.expiration_date;
			l_updated_Flag := True;
		   end If;

		   if not OE_GLOBALS.Equal(p_Line_Adj_Rec.Rebate_transaction_type_code,
					p_req_line_detail_Rec.Rebate_transaction_type_code) Then
			p_Line_Adj_Rec.Rebate_transaction_type_code :=
					p_req_line_detail_Rec.Rebate_transaction_type_code;
			l_updated_Flag := True;
		   end If;

		   if not OE_GLOBALS.Equal(p_Line_Adj_Rec.modifier_level_code,
					p_req_line_detail_Rec.modifier_level_code) Then
			p_Line_Adj_Rec.modifier_level_code :=
					p_req_line_detail_Rec.modifier_level_code;
			l_updated_Flag := True;
		   end If;
             if not OE_GLOBALS.Equal(p_Line_Adj_Rec.group_value,
                         p_req_line_detail_Rec.group_value) Then
               p_Line_Adj_Rec.group_value :=
                         p_req_line_detail_Rec.group_value;
               l_updated_Flag := True;
             end If;

  /* bug 1915846 */

            IF  (    p_line_adj_rec.list_line_type_code = 'FREIGHT_CHARGE'
                 and p_line_adj_rec.modifier_level_code = 'ORDER'
                 and p_line_adj_rec.arithmetic_operator = 'LUMPSUM' ) THEN

     p_line_adj_rec.adjusted_amount := p_line_adj_rec.adjusted_amount_per_pqty;

                p_line_adj_rec.operand := p_line_adj_rec.operand_per_pqty;

            END IF;

      /* end bug 1915846 */


		adj_debug('Exiting oe_order_Adj_pvt.Update_Adj_Line_rec',1);

	Return l_updated_Flag;

End Update_Adj_Line_rec;

--Function line_quantity_changed

Procedure Find_Duplicate_Adj_Lines(
	p_header_Id 			Number default null
	,p_Line_id  			Number default null
	,p_req_line_detail_Rec   qp_preq_grp.line_detail_rec_type
	,px_Line_Adj_Tbl 	in out nocopy	OE_Order_Pub.Line_Adj_Tbl_Type
,X_Adj_Index out nocopy Number

        ,p_mode         in              Varchar2
        ,px_line_key_tbl in out nocopy  key_tbl_type
        ,px_header_key_tbl in out nocopy key_tbl_type
	)
is
   l_end_index PLS_INTEGER;
   l_temp NUMBER;
Begin

		adj_debug('Entering oe_order_Adj_pvt.Find_Duplicate_Adj_Lines'||p_mode||'line_id'||p_line_id,1);
               adj_debug('BCT x_adj_index '||x_adj_index);
		G_STMT_NO := 'Find_Duplicate_Adj_Lines#10';

                  --retrieve start and end index from key_table to save extra scaning

                  IF p_mode = 'L' and px_line_key_tbl.exists(nvl(MOD(p_line_id,G_BINARY_LIMIT),-1)) Then -- Bug 8631297
                   x_adj_index := px_line_key_tbl(MOD(p_line_id,G_BINARY_LIMIT)).db_start;               -- Bug 8631297
                   l_end_index := px_line_key_tbl(MOD(p_line_id,G_BINARY_LIMIT)).db_end;                 -- Bug 8631297
                   adj_debug('BCT line id :'||p_line_id);
                   adj_debug('BCT x_adj_index :'||x_adj_index);
                   adj_debug('BCT l_end_index :'||l_end_index);
                  Elsif  p_mode = 'H' and px_header_key_tbl.exists(nvl(p_header_id,-1)) Then
                   x_adj_index := px_header_key_tbl(p_header_id).db_start;
                   l_end_index := px_header_key_tbl(p_header_id).db_end;
                  Else
                   --no record exists in key_tbl
                   --reset the index so that it can skip the subsequence loop
                   x_adj_index := -1;
                   l_end_index := -2;
                  End If;

                --for the freight we need to loop thru everything, no shortcut
                  If p_req_line_detail_Rec.list_line_type_code = 'FREIGHT_CHARGE'
                     and px_line_adj_tbl.count > 0 Then
                    x_adj_index := px_line_adj_tbl.first;
                    l_end_index := px_line_adj_tbl.last;
                  End If;

		--G_STMT_NO := 'Find_Duplicate_Adj_Lines#10.5';

		While nvl(X_Adj_Index,l_end_index + 1) <= l_end_index Loop
			If (px_Line_Adj_Tbl(X_Adj_Index).line_id = p_Line_id
					or
					px_Line_Adj_Tbl(X_Adj_Index).line_index = p_req_line_detail_Rec.line_index
					or -- for header adjustments
					( px_Line_Adj_Tbl(X_Adj_Index).header_id = p_header_id and
					  ( px_Line_Adj_Tbl(X_Adj_Index).line_id is null or
					    px_Line_Adj_Tbl(X_Adj_Index).line_id = fnd_api.g_miss_num ) and
					  ( px_Line_Adj_Tbl(X_Adj_Index).line_index is null or
					    px_Line_Adj_Tbl(X_Adj_Index).line_index = fnd_api.g_miss_num )
					))
			then

			if px_Line_Adj_Tbl(X_Adj_Index).list_Line_id=p_req_line_detail_Rec.list_Line_id
			Then
                                adj_debug('BCT found duplicate list line id:'||px_line_adj_tbl(x_adj_index).list_line_id);
				Exit;
			End if;

		--G_STMT_NO := 'Find_Duplicate_Adj_Lines#10.55';
                adj_debug('BCT x_adj_index '||x_adj_index);
               IF px_Line_Adj_Tbl(X_Adj_Index).list_line_type_code
                          = 'FREIGHT_CHARGE'
                  AND px_Line_Adj_Tbl(X_Adj_Index).charge_type_code
                          = p_req_line_detail_Rec.charge_type_code
                  AND NVL(px_Line_Adj_Tbl(X_Adj_Index).charge_subtype_code
                  ,'SUB') = NVL(p_req_line_detail_Rec.charge_subtype_code,'SUB')
			   and
			   nvl(px_Line_Adj_Tbl(X_Adj_Index).applied_flag,'Y') ='Y' and
			   nvl(p_req_line_detail_Rec.Applied_Flag,'Y') = 'Y'

			 Then
                                adj_debug('BCT found duplicate list line id:'||px_line_adj_tbl(x_adj_index).list_line_id);
				Exit;
			 End If;

		end if;
                        --G_STMT_NO := 'Find_Duplicate_Adj_Lines#10.551';
			x_Adj_Index := px_Line_Adj_Tbl.Next(X_Adj_Index);
		end loop;

             -- IF x_adj_index is not null THEN
                If x_adj_index is Null then x_adj_index := -1;  end if;

		If x_adj_index= -1 or x_adj_index > l_end_index Then
		-- This is a new Record
                    --
                    x_Adj_Index := px_line_adj_Tbl.count + 1;
                    px_line_adj_tbl(x_adj_index) := OE_ORDER_PUB.G_MISS_LINE_ADJ_REC;
      	            px_line_adj_Tbl(x_Adj_Index).operation := OE_GLOBALS.G_OPR_CREATE;
      	            px_line_adj_Tbl(x_Adj_Index).Updated_Flag := 'N';
		    px_line_adj_Tbl(x_Adj_Index).adjusted_amount_per_pqty := null;
                    --
		elsif px_Line_Adj_Tbl(x_Adj_Index).price_adjustment_id is null or
		      px_Line_Adj_Tbl(x_Adj_Index).price_adjustment_id = FND_API.g_miss_num Then
			--Record is not yet created in the database
      	              px_line_adj_Tbl(x_Adj_Index).Updated_Flag := 'N';
      	              px_line_adj_Tbl(x_Adj_Index).operation := OE_GLOBALS.G_OPR_CREATE;
/* Taking out nocopy this part to be set in update_adj_line_rec: Manish */

--		Else
--     	              px_Line_Adj_Tbl(x_Adj_Index).operation := OE_GLOBALS.G_OPR_UPDATE;
		end if;

		--G_STMT_NO := 'Find_Duplicate_Adj_Lines#10.57';

                oe_debug_pub.add('list_line_id:'||px_Line_Adj_Tbl(x_Adj_Index).list_line_id);
                oe_debug_pub.add('updated_flag:'||px_Line_Adj_Tbl(x_Adj_Index).updated_Flag);
		if px_Line_Adj_Tbl(x_Adj_Index).updated_Flag = 'Y' Then
				-- User has updated this record Do not touch this
			px_Line_Adj_Tbl(x_Adj_Index).Operation :=  FND_API.G_MISS_CHAR;

		elsif px_Line_Adj_Tbl(X_Adj_Index).list_line_type_code =
			 'FREIGHT_CHARGE'
			 AND
               (NOT OE_GLOBALS.EQUAL(px_Line_Adj_Tbl(X_Adj_Index).list_Line_id,
				p_req_line_detail_Rec.list_Line_id))
			 AND
                px_line_adj_Tbl(X_Adj_Index).operation <>
									OE_GLOBALS.G_OPR_DELETE
		      AND
		      nvl(px_Line_Adj_Tbl(x_Adj_Index).adjusted_amount_per_pqty,0) >=
					nvl(p_req_line_detail_Rec.adjustment_amount,0)
		Then
			-- Retain the freight charge of higher amount.
			Null;
		adj_debug('In Freight Compare',3);

		elsif Not Update_Adj_Line_rec(
					p_Line_Adj_Rec			=>	px_Line_Adj_Tbl(x_Adj_Index)
					,p_req_line_detail_Rec  	=> p_req_line_detail_Rec
					)
		Then
			-- There is no change in the adjustment record

			px_Line_Adj_Tbl(x_Adj_Index).Operation := FND_API.G_MISS_CHAR;

                        --fix bug 1461198
                        --if pricing engine return a prg line set the operation
                        --to update because parent quantity might have changed

			If p_req_line_detail_rec.list_line_type_code = 'PRG' Then
                          px_line_adj_tbl(x_adj_index).operation := OE_GLOBALS.G_OPR_UPDATE;
                        End If;

	     End If; -- Check Updated_Flag

   --END IF;

                adj_debug(' x_adj_index:'||x_Adj_Index);
		adj_debug('Exiting oe_order_Adj_pvt.Find_Duplicate_Adj_Lines',1);





End Find_Duplicate_Adj_Lines;

Procedure Query_Adj_Assocs(
					p_price_adjustment_id	 Number,
					p_Adj_Index			Number,
					p_Line_Adj_Assoc_Tbl    in out nocopy OE_Order_Pub.line_adj_Assoc_tbl_Type,
                                        p_delete_flag           in Varchar2 default 'Y'
					) Is
L_Line_Adj_Assoc_Tbl		OE_Order_Pub.line_adj_Assoc_tbl_Type;
l_index				pls_integer;
i pls_integer;
Begin
	adj_debug('Entering oe_order_Adj_pvt.Query_Adj_Assocs',1);
	G_STMT_NO := 'Query_Adj_Assocs#10';

	-- Check If the price adjustment has been already queried

	l_index := p_Line_Adj_Assoc_Tbl.First;

	While l_index is not null loop
		If p_Line_Adj_Assoc_Tbl(l_index).price_adjustment_id = p_price_adjustment_id then
			Return;
		End If;
		l_index := p_Line_Adj_Assoc_Tbl.Next(l_Index);

	End Loop;

         adj_debug('query line adj assocs for price adjustment:'||p_price_adjustment_id, 2);
         OE_Line_Adj_Assocs_Util.Query_Rows(
				p_price_adjustment_id => p_price_adjustment_id
                             ,  x_Line_Adj_Assoc_Tbl => L_Line_Adj_Assoc_Tbl );

	-- Append to the tbl with Delete flag set.
	-- The row would be removed from this structure if there is a match.

	G_STMT_NO := 'Query_Adj_Assocs#20';

	--For i in 1..L_Line_Adj_Assoc_Tbl.count loop
          oe_debug_pub.add('zBefore Assoc QUery:');
          i:= L_Line_Adj_Assoc_Tbl.FIRST;
         WHILE i IS NOT NULL LOOP
                oe_debug_pub.add('zInside Assoc Query i value:'||i);
		l_index := p_Line_Adj_Assoc_Tbl.count+1;
                If p_delete_flag = 'Y' Then
		  p_Line_Adj_Assoc_Tbl(l_index).Operation :=  OE_GLOBALS.G_OPR_DELETE;
                Else
                  p_line_adj_assoc_tbl(l_index).Operation :=  FND_API.G_MISS_CHAR;
                End If;
                oe_debug_pub.add('zl_index:'||l_index);
		p_Line_Adj_Assoc_Tbl(l_index).Adj_Index :=  p_Adj_Index;
		p_Line_Adj_Assoc_Tbl(l_index).price_adjustment_id :=  p_price_adjustment_id;
		p_Line_Adj_Assoc_tbl(l_index).Rltd_Price_Adj_Id := l_Line_Adj_Assoc_tbl(i).Rltd_Price_Adj_Id;
		p_Line_Adj_Assoc_tbl(l_index).Line_Id := l_Line_Adj_Assoc_tbl(i).Line_Id;
		p_Line_Adj_Assoc_tbl(l_index).price_adj_assoc_id := l_Line_Adj_Assoc_tbl(i).price_adj_assoc_id;
           oe_debug_pub.add('z10');
          i:=l_Line_Adj_Assoc_tbl.NEXT(i);
           oe_debug_pub.add('z14');
          END LOOP;
	--end loop;

	adj_debug('Exiting oe_order_Adj_pvt.Query_Adj_Assocs',1);

End Query_Adj_Assocs;

Procedure Append_Adjustment_Lines(
				p_header_id 		Number default null,
				p_line_id 		Number default null,
				p_Pricing_Event	Varchar2 default null,
                                p_any_frozen_line   Boolean default FALSE,
				p_price_flag		VARCHAR2 default null,
				px_Line_Adj_Tbl in out nocopy OE_Order_Pub.Line_Adj_Tbl_Type,
                                px_line_key_tbl         in out nocopy key_tbl_type,
                                px_header_key_tbl       in out nocopy key_tbl_type,
                                p_mode                  in varchar2 default NULL,
                                px_line_rec             in out nocopy Oe_Order_Pub.Line_Rec_Type,
                                px_line_adj_assoc_tbl   in out nocopy OE_Order_PUB.Line_Adj_Assoc_Tbl_type,
x_updated_flag out nocopy varchar2,

                                p_multiple_events       in VARCHAR2 Default 'N'
                                )
is
l_Pricing_Phase_id		Index_Tbl_Type;
l_Line_Adj_Tbl			OE_Order_Pub.Line_Adj_Tbl_Type;
i					pls_integer;
J					pls_integer;
p_override_freeze_flag 	VARCHAR2(1) := NULL;
l_visited_flag                  BOOLEAN Default FALSE;
l_dummy               VARCHAR2(1);
l_event_code1 Varchar2(240);
l_mark_for_delete Varchar2(1);
begin

	adj_debug('Entering oe_order_Adj_pvt.Append_Adjustment_Lines, line_id = ' || p_line_id);
        adj_debug('price flag = ' || p_price_flag);

        --If p_any_frozen_line Then l_dummy:='Y'; else l_dummy:='N'; End If;
        --adj_debug('BCT p_any_frozen_line '||l_dummy);
	G_STMT_NO := 'Append_Adjustment_Lines#10';

     IF (p_price_flag = 'P') THEN
	  p_override_freeze_flag := 'Y';
     END IF;


	if p_line_id is not null then
		G_STMT_NO := 'Append_Adjustment_Lines#20';
		adj_debug('BCT p_line_id is not null:'||TO_CHAR(p_line_id));
                OE_Line_Adj_Util.Query_Rows(p_Line_Id => p_line_id,x_line_adj_tbl=>l_Line_Adj_Tbl );
	else
                adj_debug('BCT p_line_id is null');
		G_STMT_NO := 'Append_Adjustment_Lines#25';

                 OE_Line_Adj_Util.Query_Rows(p_header_Id => p_header_id,x_line_adj_tbl=>l_Line_Adj_Tbl);
	End If;

        x_updated_flag := 'N';
	i:= l_Line_Adj_Tbl.First;
	While i is not Null Loop
          IF l_Line_Adj_Tbl(i).updated_flag = 'Y' and x_updated_flag = 'N' THEN
            x_updated_flag := 'Y';
          END IF;

          --The index of  G_Pricing_Phase_Id_Tbl stores pricing phase id
          --and the content of this table stores freeze_override_flag
          If p_Pricing_Event is Not Null Then

          If l_Line_Adj_Tbl(i).pricing_Phase_id is null
              or l_Line_Adj_Tbl(i).pricing_Phase_id = fnd_api.g_miss_num Then
             l_mark_for_delete:='Y';
          Elsif G_Pricing_Phase_Id_Tbl.Exists(l_Line_Adj_Tbl(i).pricing_Phase_id) Then
             If (G_Pricing_Phase_Id_Tbl(l_Line_Adj_Tbl(i).pricing_Phase_id) = 'Y' and p_price_flag = 'P')
               or p_price_flag = 'Y'
             Then
               l_mark_for_delete := 'Y';
             Else
               l_mark_for_delete := 'N';
             End If;
          Else
             l_mark_for_delete := 'N';
          End If;

          adj_debug('Delete ' || l_Line_adj_tbl(i).price_adjustment_id || '? ' || l_mark_for_delete);

          If l_mark_for_delete = 'Y' Then
		G_STMT_NO := 'Append_Adjustment_Lines#30';
             if l_Line_Adj_Tbl(i).Modifier_Level_Code= 'ORDER'
                and p_any_frozen_line
                and px_line_rec.ordered_quantity > 0 then

                     --We need to mark it as unchanged for the order level adjustments
                     --that have a frozen line

                        L_Line_Adj_Tbl(i).operation :=  FND_API.G_MISS_CHAR;

	     elsif nvl(l_Line_Adj_Tbl(i).Updated_Flag,'N') = 'N' or
		    l_Line_Adj_Tbl(i).Updated_Flag = fnd_api.g_miss_char then
                        adj_debug('BCT'||l_Line_Adj_Tbl(i).price_adjustment_id);
			L_Line_Adj_Tbl(i).operation := OE_GLOBALS.G_OPR_DELETE;

                        --Fix bug 1758251
                        If l_line_adj_tbl(i).list_line_type_code = 'IUE' Then
                            get_item_for_iue(px_line_rec => px_line_rec);
                        End If;

	     end if;

	   End if;

	End If;

          G_STMT_NO := 'Append_Adjustment_Lines#31';

          -- bug 1834409

	  if ((l_line_adj_tbl(i).operand_per_pqty IS NULL) OR
		(L_line_adj_Tbl(i).operand_per_pqty =  FND_API.G_MISS_NUM))
	  then
		l_line_adj_tbl(i).operand_per_pqty :=
			l_line_adj_tbl(i).operand;
	  end if;

 	if ((l_line_adj_tbl(i).adjusted_amount_per_pqty IS NULL) OR
	     (L_line_adj_Tbl(i).adjusted_amount_per_pqty = FND_API.G_MISS_NUM))
	then
		l_line_adj_tbl(i).adjusted_amount_per_pqty := l_line_adj_tbl(i).adjusted_amount;
	end if;

	 --  end 1834409

	  px_line_adj_tbl(px_line_adj_tbl.count+1) := L_Line_Adj_Tbl(i);

          If px_line_adj_tbl(px_line_adj_tbl.count).list_line_type_code In('PBH','PRG','OID','CIE')
          Then
             If px_line_adj_tbl(px_line_adj_tbl.count).operation = OE_GLOBALS.G_OPR_DELETE
      Then
             Query_Adj_Assocs(p_price_adjustment_id=>px_line_adj_tbl(px_line_adj_tbl.count).price_adjustment_id,
	  	 p_Adj_Index		=> px_line_adj_tbl.count,
	 	 p_Line_Adj_Assoc_Tbl 	=> px_line_adj_Assoc_tbl,
                 p_delete_flag          => 'Y');
             Else

               Query_Adj_Assocs(p_price_adjustment_id=>px_line_adj_tbl(px_line_adj_tbl.count).price_adjustment_id,
	  	 p_Adj_Index		=> px_line_adj_tbl.count,
	 	 p_Line_Adj_Assoc_Tbl 	=> px_line_adj_Assoc_tbl,
                 p_delete_flag          => 'N');

           End If;
          End If;

           --This code is to set the begin and end key of adjustments for a given line
           --with this begin and end key find_duplicate_adj_line will find adjustments for
           --a given line more effieciently hence improve performance.
           adj_debug('BCT *** append list line id'||px_line_adj_tbl(px_line_adj_tbl.count).list_line_id);
           If not l_visited_flag Then
            If p_mode = 'L' Then
              px_line_key_tbl(MOD(p_line_id,G_BINARY_LIMIT)).db_start := px_line_adj_tbl.count;                       -- Bug 8631297
              adj_debug('line '||p_line_id||' line key:'||px_line_key_tbl(MOD(p_line_id,G_BINARY_LIMIT)).db_start);   -- Bug 8631297
              G_STMT_NO := 'Append_Adjustment_Lines#32';
            Elsif p_mode = 'H' Then
              px_header_key_tbl(p_header_id).db_start := px_line_adj_tbl.count;
              adj_debug('header '||p_header_id||' header key:'||px_header_key_tbl(p_header_id).db_start);
              G_STMT_NO := 'Append_Adjustment_Lines#33';
            End If;
             l_visited_flag := TRUE;
           End If;

	  i:= l_Line_Adj_Tbl.Next(i);
	end loop;

            --record the end index
          If l_line_adj_tbl.count > 0 Then  --make sure there are adjustments
            If p_mode = 'L' Then
              px_line_key_tbl(MOD(p_line_id,G_BINARY_LIMIT)).db_end := px_line_adj_tbl.count;          -- Bug 8631297
              adj_debug('line end key: '||px_line_key_tbl(MOD(p_line_id, G_BINARY_LIMIT)).db_end);     -- Bug 8631297

            Elsif p_mode = 'H' Then
              px_header_key_tbl(p_header_id).db_end := px_line_adj_tbl.count;
            End If;
          End if;

	i:=l_line_adj_tbl.first;

adj_debug('Exiting oe_order_Adj_pvt.Append_Adjustment_Lines',1);
end Append_Adjustment_Lines;

Procedure Query_Adj_Attribs(
					p_price_adjustment_id	 Number,
					p_Adj_Index			Number,
					p_Line_Adj_Att_Tbl    in out nocopy OE_Order_Pub.line_adj_att_tbl_Type
					) Is
L_Line_Adj_Att_Tbl		OE_Order_Pub.line_adj_att_tbl_Type;
l_index				pls_integer;
Begin
	adj_debug('Entering oe_order_Adj_pvt.Query_Adj_Attribs',1);

	G_STMT_NO := 'Query_Adj_Attribs#10';

	adj_debug('Query for price Adjustment '||p_price_adjustment_id,2);

	-- Check If the price adjustment has been already queried

	l_index := p_Line_Adj_Att_Tbl.First;

	While l_index is not null loop
		If p_Line_Adj_Att_Tbl(l_index).price_adjustment_id = p_price_adjustment_id then
			Return;
		End If;
		l_index := p_Line_Adj_Att_Tbl.Next(l_Index);

	End Loop;

	G_STMT_NO := 'Query_Adj_Attribs#15';


        Oe_Line_Price_Aattr_util.Query_Rows(
				p_price_adjustment_id => p_price_adjustment_id
                              , x_Line_Adj_Att_Tbl=>L_Line_Adj_Att_Tbl);

	-- Append to the tbl with Delete flag set.
	-- The row would be removed from this structure if there is a match.

	G_STMT_NO := 'Query_Adj_Attribs#20';

	For i in 1..L_Line_Adj_Att_Tbl.count loop

		l_index := p_Line_Adj_Att_Tbl.count+1;
		 p_Line_Adj_Att_Tbl(l_index) := l_Line_Adj_Att_tbl(i);
		p_Line_Adj_Att_Tbl(l_index).Operation :=  OE_GLOBALS.G_OPR_DELETE;
		p_Line_Adj_Att_Tbl(l_index).Adj_Index :=  p_Adj_Index;
		p_Line_Adj_Att_Tbl(l_index).price_adjustment_id :=  p_price_adjustment_id;

	 end loop;


	adj_debug('Exiting oe_order_Adj_pvt.Query_Adj_Attribs',1);

End Query_Adj_Attribs;

Procedure Find_Duplicate_Adj_Attribs(
			p_Req_Line_Detail_Qual_Rec
							QP_PREQ_GRP.Line_Detail_Qual_Rec_Type,
			p_Req_Line_Detail_Attr_Rec
							QP_PREQ_GRP.Line_Detail_Attr_Rec_Type,
			p_Adj_index 		Number,
			p_Line_Adj_Att_Tbl  in out nocopy OE_Order_Pub.Line_Adj_Att_Tbl_Type,
			p_att_type		Varchar2,
			p_price_adjustment_id	Number
	)
is
l_Index		pls_integer;
I			pls_integer;
Begin

	adj_debug('Entering oe_order_Adj_pvt.Find_Duplicate_Adj_Attribs',1);
	G_STMT_NO := 'Find_Duplicate_Adj_Attribs#10';

    If p_att_Type='QUALIFIER' and p_Req_Line_Detail_Qual_Rec.Qualifier_Context IS Not Null Then

	i:= p_Line_Adj_Att_Tbl.First;
	While i is not null loop
	  If  p_Line_Adj_Att_Tbl(i).Adj_Index = p_Adj_index Then

	   If OE_GLOBALS.Equal(p_Line_Adj_Att_tbl(i).flex_title ,
								'QP_ATTR_DEFNS_QUALIFIER') and
		OE_GLOBALS.Equal(p_Line_Adj_Att_tbl(i).pricing_context,
				p_Req_LINE_DETAIL_qual_Rec.Qualifier_Context) And
		OE_GLOBALS.Equal(p_Line_Adj_Att_tbl(i).pricing_attribute ,
				p_Req_LINE_DETAIL_qual_Rec.Qualifier_Attribute) And
		OE_GLOBALS.Equal(p_Line_Adj_Att_tbl(i).pricing_attr_value_from ,
				p_Req_LINE_DETAIL_qual_Rec.Qualifier_Attr_Value_From) And
		OE_GLOBALS.Equal(p_Line_Adj_Att_tbl(i).pricing_attr_value_To ,
				p_Req_LINE_DETAIL_qual_Rec.Qualifier_Attr_Value_To) And
		OE_GLOBALS.Equal(p_Line_Adj_Att_tbl(i).comparison_operator ,
				p_Req_LINE_DETAIL_qual_Rec.comparison_operator_Code)
	   Then
		-- Do not delete the record from oe_order_Price_adj_Attribs

		If p_Line_Adj_Att_Tbl(i).Operation = OE_GLobals.g_opr_delete then
			p_Line_Adj_Att_Tbl(i).Operation := FND_API.G_MISS_CHAR;
		End If;

		Return;

	   End If;

	  End if; -- Adj_Index
	  i:= p_Line_Adj_Att_Tbl.Next(i);
	End Loop;

	G_STMT_NO := 'Find_Duplicate_Adj_Attribs#20';
	-- Create a New Record
	l_index := p_Line_Adj_Att_Tbl.count+1;
     p_Line_Adj_Att_Tbl(l_index) := OE_ORDER_PUB.G_MISS_LINE_ADJ_ATT_REC;
     p_Line_Adj_Att_Tbl(l_index).operation := OE_GLOBALS.G_OPR_CREATE;
	p_Line_Adj_Att_Tbl(l_index).Adj_index := P_Adj_Index;
	p_Line_Adj_Att_Tbl(l_index).price_adjustment_id := p_price_adjustment_id;
	p_Line_Adj_Att_Tbl(l_index).flex_title := 'QP_ATTR_DEFNS_QUALIFIER';
	p_Line_Adj_Att_Tbl(l_index).pricing_context :=
				p_Req_LINE_DETAIL_qual_Rec.Qualifier_Context;
	p_Line_Adj_Att_Tbl(l_index).pricing_attribute :=
				p_Req_LINE_DETAIL_qual_Rec.Qualifier_Attribute;
	p_Line_Adj_Att_Tbl(l_index).pricing_attr_value_from :=
				p_Req_LINE_DETAIL_qual_Rec.Qualifier_Attr_Value_From;
	p_Line_Adj_Att_Tbl(l_index).pricing_attr_value_To :=
				p_Req_LINE_DETAIL_qual_Rec.Qualifier_Attr_Value_To;
	p_Line_Adj_Att_Tbl(l_index).comparison_operator :=
				p_Req_LINE_DETAIL_qual_Rec.comparison_operator_Code;

   End If; -- Qualifier Contexts


	G_STMT_NO := 'Find_Duplicate_Adj_Attribs#30';
    If p_att_type='PRICING' and p_Req_Line_Detail_Attr_Rec.Pricing_Context IS Not Null Then

	i:= p_Line_Adj_Att_Tbl.First;
	While i is not null loop

	  If p_Line_Adj_Att_Tbl(i).Adj_Index = p_Adj_index Then

	   If OE_GLOBALS.Equal(p_Line_Adj_Att_tbl(i).flex_title ,
								'QP_ATTR_DEFNS_PRICING') and
		OE_GLOBALS.Equal(p_Line_Adj_Att_tbl(i).pricing_context,
				p_Req_Line_Detail_Attr_Rec.Pricing_Context) And
		OE_GLOBALS.Equal(p_Line_Adj_Att_tbl(i).pricing_attribute ,
				p_Req_Line_Detail_Attr_Rec.Pricing_Attribute) And
		OE_GLOBALS.Equal(p_Line_Adj_Att_tbl(i).pricing_attr_value_from ,
				p_Req_Line_Detail_Attr_Rec.Pricing_Attr_Value_From) And
		OE_GLOBALS.Equal(p_Line_Adj_Att_tbl(i).pricing_attr_value_To ,
				p_Req_Line_Detail_Attr_Rec.Pricing_Attr_Value_To)
				--And
		--OE_GLOBALS.Equal(p_Line_Adj_Att_tbl(i).comparison_operator ,
				--p_Req_Line_Detail_Attr_Rec.comparison_operator_Code)
	   Then
		-- Do not delete the record from oe_order_Price_adj_Attribs

		If p_Line_Adj_Att_Tbl(i).Operation = oe_globals.g_opr_delete Then
			p_Line_Adj_Att_Tbl(i).Operation := FND_API.G_MISS_CHAR;
		End If;

		Return;

	   End If;
	  End if; -- Adj_Index
	  i:= p_Line_Adj_Att_Tbl.Next(I);
	End Loop;

	-- Create a New Record
	l_index := p_Line_Adj_Att_Tbl.count+1;
     p_line_adj_att_tbl(l_index) := OE_ORDER_PUB.G_MISS_LINE_ADJ_ATT_REC;
     p_Line_Adj_Att_Tbl(l_index).operation := OE_GLOBALS.G_OPR_CREATE;
	p_Line_Adj_Att_Tbl(l_index).Adj_index := P_Adj_Index;
	p_Line_Adj_Att_Tbl(l_index).price_adjustment_id := p_price_adjustment_id;
	p_Line_Adj_Att_Tbl(l_index).flex_title := 'QP_ATTR_DEFNS_PRICING';
	p_Line_Adj_Att_Tbl(l_index).pricing_context :=
				p_Req_Line_Detail_Attr_Rec.Pricing_Context;
	p_Line_Adj_Att_Tbl(l_index).pricing_attribute :=
				p_Req_Line_Detail_Attr_Rec.Pricing_Attribute;
	p_Line_Adj_Att_Tbl(l_index).pricing_attr_value_from :=
				p_Req_Line_Detail_Attr_Rec.Pricing_Attr_Value_From;
	p_Line_Adj_Att_Tbl(l_index).pricing_attr_value_To :=
				p_Req_Line_Detail_Attr_Rec.Pricing_Attr_Value_To;
   End If;

		adj_debug('Exiting oe_order_Adj_pvt.Find_Duplicate_Adj_Attribs',1);

End Find_Duplicate_Adj_Attribs;

Function Match_Product_Ids(
		p_price_Adjustment_Id		Number,
		p_Line_Detail_Index			Number ,
		p_Req_line_detail_Attr_Tbl	QP_PREQ_GRP.line_detail_Attr_Tbl_Type
		)
Return Boolean
is
l_inventory_item_id			Varchar2(240);
Begin
	adj_debug('Entering oe_order_Adj_pvt.Match_Product_Ids',1);
	G_STMT_NO := 'Match_Product_Ids#10';
	Begin
	/*
	select PRICING_ATTR_VALUE_FROM into l_inventory_item_id
	from oe_price_adj_attribs opaa
	where price_adjustment_id =p_price_Adjustment_Id and
		Flex_Title ='QP_ATTR_DEFNS_PRICING' and
		Pricing_Context='ITEM' and
		Pricing_attribute='PRICING_ATTRIBUTE1' and
		Rownum < 2;
		*/

	Select inventory_item_id into l_inventory_item_id
	from oe_price_adjustments opa,oe_order_lines_all ola
	where opa.line_id=ola.line_id and
		opa.price_adjustment_id=p_price_Adjustment_Id;

	Exception when no_data_found then
		Return False; -- Treat this as new Item
	End;

	G_STMT_NO := 'Match_Product_Ids#20';
	for i in 1..p_Req_line_detail_Attr_Tbl.count loop
		if p_Req_line_detail_Attr_Tbl(i).line_detail_index = p_Line_Detail_Index and
			 p_Req_line_detail_Attr_Tbl(i).Pricing_Context='ITEM' and
			 p_Req_line_detail_Attr_Tbl(i).Pricing_attribute='PRICING_ATTRIBUTE1' and
			 p_Req_line_detail_Attr_Tbl(i).Pricing_Attr_Value_From = l_inventory_item_id
		Then
		-- Got a match
			adj_debug('Exiting oe_order_Adj_pvt.Match_Product_Ids',1);
			Return True;
		End If;
	End Loop;
	Return False;

End Match_Product_Ids;

Procedure Process_Other_Item_Line (
	p_Line_Detail_Index 			Number
	,p_req_line_Tbl 			QP_PREQ_GRP.LINE_TBL_TYPE
	,p_req_line_detail_Tbl 		QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE
	,p_Req_line_detail_Attr_Tbl	QP_PREQ_GRP.line_detail_Attr_Tbl_Type
	,p_Price_Adjustment_Id		Number
	,p_Header_Id				Number
	,p_Parent_Adj_Index			Number
	,p_parent_line_index		Number
	,p_Rltd_line_details_prcd in out nocopy Index_Tbl_Type
	,p_Rltd_lines_prcd		 in out nocopy Index_Tbl_Type
	,p_Line_Tbl			in out nocopy	OE_Order_Pub.Line_Tbl_Type
	,p_Line_Adj_Tbl		in out nocopy	OE_Order_Pub.Line_Adj_Tbl_Type
	,p_Line_Adj_Assoc_Tbl	in out nocopy	OE_Order_Pub.Line_Adj_Assoc_Tbl_Type
        ,p_line_detail_replaced       in out nocopy   Index_Tbl_Type
        ,p_buy_line_rec         in Oe_Order_Pub.Line_Rec_Type
	)
is
l_line_Adj_Rec			OE_Order_Pub.Line_Adj_Rec_Type;
l_line_Rec			OE_Order_Pub.Line_Rec_Type;
l_Match_Exists			Boolean := False;
l_Req_Line_Index		pls_integer;
l_Adj_Index			pls_integer;
l_assoc_index			pls_integer;
i					Pls_Integer;
j                                       Pls_Integer;
-- Including variables for bug 1820961  begin
l_first          pls_integer;
l_tot_qty        OE_ORDER_LINES_ALL.ordered_quantity%TYPE;
l_tot_price_qty  OE_ORDER_LINES_ALL.pricing_quantity%TYPE;
-- Including variables for bug 1820961  end
l_found_discount_line boolean:=FALSE;
-- This change is required since we are dropping the profile OE_ORGANIZATION    -- _ID. Change made by Esha.
l_org_id Number:= OE_Sys_Parameters.VALUE('MASTER_ORGANIZATION_ID');
E_CLOSED_PRG_LINE Exception;
l_new_prg_created boolean := FALSE;
Begin
	adj_debug('Entering oe_order_Adj_pvt.Process_Other_Item_Line',1);
	G_STMT_NO := 'Process_Other_Item_Line#10';

	If p_Price_Adjustment_Id <> FND_API.G_MISS_NUM And
		p_Price_Adjustment_Id is not null Then
		-- The Adjustment Record for OID Adlready exits
		-- That Also means that the "Other Item Line" also exists in the order
		-- Find the "Other Item" Line and update the attributes

		adj_debug('The PRG already exists '||p_Price_Adjustment_Id);
		-- First find the related Adjustment record
		i:= p_Line_Adj_Assoc_Tbl.First;
-- making changes for bug 1820961   begin
                l_first := i;
-- making changes for bug 1820961   end
		While i is not null loop
                Begin
		 If p_Line_Adj_Assoc_Tbl(i).price_adjustment_id = p_Price_Adjustment_Id
		 Then
			-- Get the Product ID Associated with the adjustment
			IF Match_Product_Ids(
				p_price_Adjustment_Id		=> p_Line_Adj_Assoc_Tbl(i).rltd_Price_Adj_Id,
				p_Line_Detail_Index			=> p_Line_Detail_Index,
				p_Req_line_detail_Attr_Tbl	=> p_Req_line_detail_Attr_Tbl
				)  Then

			 l_Match_Exists := True;
			 -- Retain the Association Record
				G_STMT_NO := 'Process_Other_Item_Line#15';

			-- Update The Adjustment Record of the "Other Item"
                        -- bug 1843872, find whether the discount line is in memory
                        j := p_line_adj_tbl.first;
                        while j is not null loop
                           if p_line_adj_tbl(j).price_adjustment_id
                               = p_line_adj_assoc_tbl(i).rltd_price_adj_id THEN
                             l_line_adj_rec := p_line_adj_tbl(j);
                             l_found_discount_line := TRUE;
                             exit;
                           end if;
                           j:=p_line_adj_tbl.next(j);
                       end loop;
                       IF NOT l_found_discount_line THEN
                         OE_Line_Adj_Util.Query_Row
			(p_price_Adjustment_Id => p_Line_Adj_Assoc_Tbl(i).rltd_Price_Adj_Id
                        , x_line_adj_rec => l_line_adj_rec);
                        j:=p_line_adj_tbl.count+1;
			p_Line_Adj_Tbl(p_Line_Adj_Tbl.count+1) := l_Line_Adj_Rec;
                       END IF;

			p_Line_Adj_Assoc_Tbl.delete(i);

    -- Bug 2270949
    IF (p_Rltd_line_details_prcd.exists(p_line_detail_index)
and p_line_adj_tbl(p_Rltd_line_details_prcd(p_line_detail_index)).operation = OE_GLOBALS.G_OPR_CREATE) THEN
      adj_debug('2270949:replace '||p_Rltd_line_details_prcd(p_line_detail_index)||' with '||j);
      p_line_adj_tbl(p_Rltd_line_details_prcd(p_line_detail_index)).operation :=NULL;
      p_line_detail_replaced(p_Rltd_line_details_prcd(p_line_detail_index)) := j;
    End If;

    p_Rltd_line_Details_prcd(p_Line_detail_Index) := j;
    -- End 2270949

			 If Update_Adj_Line_rec(
					p_Line_Adj_Rec			=>	l_line_Adj_Rec
					,p_req_line_detail_Rec  	=> 	p_req_line_detail_Tbl(p_Line_Detail_Index)
					)
			 Then
				-- There is a Change is the Adjsutment Record
      	   		        l_Line_Adj_Rec.operation := OE_GLOBALS.G_OPR_UPDATE;
				p_Line_Adj_Tbl(j) := l_Line_Adj_Rec;
			 End If;

			 l_Req_Line_Index :=  p_req_line_detail_Tbl(p_Line_Detail_Index).Line_Index;

			 -- Check If this Related Line Has Already been processed in an earlier loop
                         G_STMT_NO := 'Process_Other_Item_Line#18';
                         -- 2270949
                         If p_Rltd_lines_prcd.exists(l_Req_Line_Index) Then
                             adj_debug('req line index'||l_Req_Line_Index||' '||p_Rltd_lines_prcd(l_Req_line_Index));
                             adj_debug('operation:'||p_line_tbl(p_Rltd_lines_prcd(l_Req_line_index)).operation);
                           if p_line_tbl(p_Rltd_lines_prcd(l_Req_Line_Index)).operation = OE_GLOBALS.G_OPR_CREATE THEN
                             -- replace this line with the old line
                             adj_debug('delete line'||p_rltd_lines_prcd(l_req_line_index));
                            l_new_prg_created := TRUE;

                           End If;
                         End If;

                         If l_new_prg_created OR NOT p_Rltd_lines_prcd.exists(l_Req_Line_Index) Then
                            -- End 2270949

				G_STMT_NO := 'Process_Other_Item_Line#20';

                                 OE_Line_Util.Query_Row
		    	  	 (   p_Line_id   => l_line_Adj_Rec.Line_Id
                                  ,  x_line_rec  => l_line_rec);

			   if l_line_rec.operation = FND_API.G_MISS_CHAR then
      		   	      l_line_rec.operation := OE_GLOBALS.G_OPR_UPDATE;
			   End If;

                   adj_debug(' GET line, line_id:'||l_line_rec.line_id);
                   adj_debug(' GET line, open_flag:'||l_line_rec.open_flag);

                   --Do not process if open_flag set to 'N'
                   --BT
                   If l_line_rec.open_flag = 'N' Then
                      Raise E_Closed_PRG_Line;
                   End If;

                   --adj_debug('BCT!!!Adjusted_unit_price:'||p_req_line_tbl(l_Req_Line_Index).adjusted_unit_price);
      		   l_line_rec.unit_selling_price_per_pqty := p_req_line_tbl(l_Req_Line_Index).adjusted_unit_price ;
      		   l_line_rec.unit_list_price_per_pqty := p_req_line_tbl(l_Req_Line_Index).unit_price ;
      		   l_line_rec.unit_list_percent := p_req_line_tbl(l_Req_Line_Index).percent_price ;
	 		   if  nvl(p_req_line_tbl(l_Req_Line_Index).percent_price,0) <> 0 then
      			   l_line_rec.unit_selling_percent :=
		  		   ( l_line_rec.unit_selling_price_per_pqty * l_line_rec.unit_list_percent)/
						   p_req_line_tbl(l_Req_Line_Index).percent_price ;
                            end if;
                    adj_debug('populate change reason!!!',3);

                   -- For bug 1916585, cancellation needs reason
                   IF (l_line_rec.change_reason IS NULL
                      or l_line_rec.change_reason = fnd_api.g_miss_char) THEN
                     l_line_rec.change_reason := 'SYSTEM';
                     l_line_rec.change_comments := 'REPRICING';
                   END IF;
-- Code included for bug 1820961   begin
  -- header_id validation is added for the Bug 2215903
   if l_first = i then
     begin
      select nvl(sum(ordered_quantity),0),nvl(sum(pricing_quantity),0)
      into l_tot_qty,l_tot_price_qty
      from oe_order_lines
      where split_from_line_id = l_line_rec.line_id
      and  header_id = l_line_rec.header_id;
     exception
      when others then
       null;
     end;
     l_line_rec.pricing_quantity :=
     p_req_line_tbl(l_req_line_index).priced_quantity - nvl(l_tot_price_qty,0);
     l_line_rec.ordered_quantity :=
     p_req_line_tbl(l_req_line_index).line_quantity - nvl(l_tot_qty,0);
   else
    l_line_rec.pricing_quantity :=
    p_req_line_tbl(l_Req_Line_Index).priced_quantity ;
    l_line_rec.ordered_quantity :=
    p_req_line_tbl(l_req_line_index).line_quantity;
   end if;


 l_line_rec.pricing_quantity_uom := p_req_line_tbl(l_Req_Line_Index).priced_uom_code ;
 l_line_rec.price_request_code := p_req_line_tbl(l_Req_Line_Index).price_request_code; -- PROMOTIONS SEP/01

      --for bug 2412868  begin
         oe_debug_pub.add('bug 2412868 in update1:');
        if p_req_line_tbl(l_req_line_index).line_quantity < 0
         and ( p_req_line_tbl(l_req_line_index).line_category is null or
           p_req_line_tbl(l_req_line_index).line_category  = 'ORDER'
           )  then
         l_line_rec.line_category_code := 'RETURN' ;
         l_line_rec.return_reason_code := 'RETURN' ;
         oe_debug_pub.add('bug 2412868 in update:');
        elsif p_req_line_tbl(l_req_line_index).line_category = 'RETURN'
        then
         l_line_rec.line_category_code := 'ORDER' ;
        end if;
         if l_line_rec.pricing_quantity < 0 and
            l_line_rec.ordered_quantity < 0 then
            l_line_rec.pricing_quantity :=
               abs(p_req_line_tbl(l_Req_Line_Index).priced_quantity);
            l_line_rec.ordered_quantity :=
               abs(p_req_line_tbl(l_req_line_index).line_quantity);
         end if;
      --for bug 2412868  end
                     IF (l_new_prg_created) THEN
                           p_Line_Tbl(p_Rltd_lines_prcd(l_Req_Line_Index)) := l_line_rec;
                     Else
                           p_Line_Tbl(p_Line_Tbl.last+1) := l_line_rec;

                         p_Rltd_lines_prcd(l_Req_Line_Index) := p_line_Tbl.last;
                         -- p_Line_Tbl(p_Line_Tbl.count+1) := l_line_rec;

                          -- p_Rltd_lines_prcd(l_Req_Line_Index) := p_line_Tbl.count;
                     End If;

			 End If; -- p_Rltd_lines_prcd

		    End If;  -- Match Exists for Item
		  End If;

                  Exception
                     When E_Closed_PRG_Line Then
                       oe_debug_pub.add('  PRG ignore, Closed line!');
                  End; --End for the begin in 'FOR' loop

		  i:= p_Line_Adj_Assoc_Tbl.Next(i);
		End loop; -- Process Adjustments
      End If;

	G_STMT_NO := 'Process_Other_Item_Line#30';

	 If Not l_Match_exists Then

	 adj_debug('There is no existing product match');
	 l_Req_Line_Index :=  p_req_line_detail_Tbl(p_Line_Detail_Index).Line_Index;

		-- Introduce New Order Line , Order Adjustments and Association Record
		--
		-- Check If this Related Line Has Already been processed in an earlier loop
	   If Not p_Rltd_lines_prcd.exists(l_Req_Line_Index) Then

		adj_debug('Creating a new line record for header  '||P_Header_Id);
        l_line_rec:=OE_ORDER_PUB.G_MISS_LINE_REC;
      	l_line_rec.operation := OE_GLOBALS.G_OPR_CREATE;

      	l_line_rec.Header_id := P_Header_Id;
   --for bug 2412868  Begin
 oe_debug_pub.add('b2412868:'||p_req_line_tbl(l_req_line_index).line_quantity);
 oe_debug_pub.add('b2412868:'||p_req_line_tbl(l_req_line_index).priced_quantity);
        if p_req_line_tbl(l_req_line_index).line_quantity < 0
         and
         ( p_req_line_tbl(l_req_line_index).line_category is null or
           p_req_line_tbl(l_req_line_index).line_category  = 'ORDER'
           )  then
         l_line_rec.line_category_code := 'RETURN' ;
         l_line_rec.return_reason_code := 'RETURN' ;
         oe_debug_pub.add('bug 2412868 in if :');
        elsif p_req_line_tbl(l_req_line_index).line_category = 'RETURN' then
         l_line_rec.line_category_code := 'ORDER';
        end if;
   --for bug 2412868  end
        -- uom begin
      	l_line_rec.unit_selling_price_per_pqty := p_req_line_tbl(l_Req_Line_Index).adjusted_unit_price ;
      	l_line_rec.unit_list_price_per_pqty := p_req_line_tbl(l_Req_Line_Index).unit_price ;
       --for bug 2412868 begin
        if l_line_rec.unit_selling_price_per_pqty < 0
        --bug 2992310
        and p_req_line_tbl(l_req_line_index).line_quantity < 0  then
      	l_line_rec.unit_selling_price_per_pqty :=
         abs(p_req_line_tbl(l_Req_Line_Index).adjusted_unit_price ) ;
      	l_line_rec.unit_list_price_per_pqty :=
         abs(p_req_line_tbl(l_Req_Line_Index).unit_price );
        end if;
       --for bug 2412868  end
        -- uom end
      	l_line_rec.unit_list_percent := p_req_line_tbl(l_Req_Line_Index).percent_price ;
	 	if  nvl(p_req_line_tbl(l_Req_Line_Index).percent_price,0) <> 0 then
      		l_line_rec.unit_selling_percent :=
		  		 ( l_line_rec.unit_selling_price_per_pqty * l_line_rec.unit_list_percent)/
				p_req_line_tbl(l_Req_Line_Index).percent_price ;
	 	end if;
      	l_line_rec.pricing_quantity := p_req_line_tbl(l_Req_Line_Index).priced_quantity ;
      	l_line_rec.Ordered_Quantity := p_req_line_tbl(l_Req_Line_Index).priced_quantity ;
     --for bug 2412868  begin
 if l_line_rec.pricing_quantity < 0 and l_line_rec.Ordered_quantity < 0
 then
    l_line_rec.pricing_quantity := abs(l_line_rec.pricing_quantity);
    l_line_rec.ordered_quantity := abs(l_line_rec.ordered_quantity);
  end if;
     --for bug 2412868  end
      	l_line_rec.pricing_quantity_uom := p_req_line_tbl(l_Req_Line_Index).priced_uom_code ;
      	l_line_rec.price_request_code := p_req_line_tbl(l_Req_Line_Index).price_request_code;

        --Why hardcode to INT ?
      	l_line_rec.item_identifier_type := 'INT';

        --This is a return, need to copy the return reason code from buy item
        If p_buy_line_rec.return_reason_code is Not Null Then
            l_line_rec.return_reason_code := p_buy_line_rec.return_reason_code;
        End If;

	/* Fix for Bug 1805134
           Set the UOM for the new line created by PRG to be
           the same as defined in the modifer
           and NOT the base UOM
        */

	oe_debug_pub.add('rlanka: setting ordered quantity UOM');
	oe_debug_pub.add('UOM = ' || p_req_line_tbl(l_Req_Line_Index).line_uom_code);
        l_line_rec.order_quantity_uom := p_req_line_tbl(l_Req_Line_Index).line_uom_code;

	--end Bug 1805134

	/*
	  Fix for Bug 1729372 : Change calculate_price_flag to 'R'
	  so that charges can be applied to the new line.  This will be
	  handled in OEXULINB.pls
	*/

      	l_line_rec.calculate_price_flag := 'R';
		-- Create the new line in the same ship set as the parent line.
      	l_line_rec.ship_set_id := p_line_tbl(p_parent_line_index).ship_set_id;

		G_STMT_NO := 'Process_Other_Item_Line#35';
		i:= p_req_line_detail_Tbl.First;
		While i is not null loop
			If p_req_line_detail_Tbl(i).line_index = l_Req_Line_Index and
				(p_req_line_detail_Tbl(i).created_from_list_type_code = 'PRL' or
				 p_req_line_detail_Tbl(i).created_from_list_type_code = 'AGR' or
				 p_req_line_detail_Tbl(i).list_line_type_code = 'PLL')
			Then

				l_line_rec.price_list_id := p_req_line_detail_Tbl(i).list_header_id;

				exit;

			End if;
		   i:= p_req_line_detail_Tbl.next(i);

		End loop;

		G_STMT_NO := 'Process_Other_Item_Line#135';
		i:= p_Req_line_detail_Attr_Tbl.First;
		While i is not null loop
			if p_Req_line_detail_Attr_Tbl(i).line_detail_index = p_Line_Detail_Index and
				 p_Req_line_detail_Attr_Tbl(i).Pricing_Context='ITEM' and
				 p_Req_line_detail_Attr_Tbl(i).Pricing_attribute='PRICING_ATTRIBUTE1'
			Then
				 adj_debug('The PRG item is '||p_Req_line_detail_Attr_Tbl(i).Pricing_Attr_Value_From);
				 l_line_rec.Inventory_Item_id := p_Req_line_detail_Attr_Tbl(i).Pricing_Attr_Value_From ;
				G_STMT_NO := 'Process_Other_Item_Line#140';
	   			Begin
					SELECT concatenated_segments
					INTO   l_line_rec.ordered_item
					FROM   mtl_system_items_kfv
					WHERE  inventory_item_id = l_line_rec.inventory_item_id
					AND    organization_id = l_org_id;
					Exception when no_data_found then
		 			Null;
	  			End;


			Exit;

			End If;

		  i := p_Req_line_detail_Attr_Tbl.next(i);
		End Loop;

		p_Line_Tbl(p_Line_Tbl.last+1) := l_line_rec;

		 -- Display the PRG Item
                 /* 2270949 : delay logging message
		 FND_MESSAGE.SET_NAME('ONT','ONT_CREATED_NEW_LINE');
		 FND_MESSAGE.SET_TOKEN('ITEM',l_line_rec.ordered_item);
		 FND_MESSAGE.SET_TOKEN('QUANTITY',l_line_rec.Ordered_quantity);
		 OE_MSG_PUB.Add('N');
                  */
                 adj_debug('inside price line: setting cascade');

		p_Rltd_lines_prcd(l_Req_Line_Index) := p_line_Tbl.last;

	   End If; -- p_Rltd_lines_prcd


		-- Insert Adjustment Records

		-- Check If this Related Adjustment Line Has Already been processed in an earlier loop

		G_STMT_NO := 'Process_Other_Item_Line#40';

	   If Not p_Rltd_line_details_prcd.exists(p_Line_detail_Index) Then

		   l_Adj_Index := p_line_adj_Tbl.count+1;
           p_line_adj_tbl(l_adj_index) := OE_ORDER_PUB.G_MISS_LINE_ADJ_REC;
      	   p_line_adj_Tbl(l_Adj_Index).operation := OE_GLOBALS.G_OPR_CREATE;

			adj_debug('Creating an adjustment record for PRG '||l_Adj_Index);
		  If Update_Adj_Line_rec(
					p_Line_Adj_Rec			=>	p_Line_Adj_Tbl(l_Adj_Index)
					,p_req_line_detail_Rec  	=> p_req_line_detail_Tbl(p_Line_Detail_Index)
					)
		  Then
      	   	p_line_adj_Tbl(l_Adj_Index).Updated_Flag := 'N';
      	   	p_line_adj_Tbl(l_Adj_Index).Header_id := p_Header_Id;
      	   	p_line_adj_Tbl(l_Adj_Index).Line_Index :=  p_Rltd_lines_prcd(l_Req_Line_Index);
		  End If;

		  p_Rltd_line_Details_prcd(p_Line_detail_Index) := l_Adj_Index;

	   End If; -- p_Rltd_lines_prcd

		G_STMT_NO := 'Process_Other_Item_Line#50';
		-- Process the Relationship recordS

                 /* Added following if condition for Bug2211670 */
                  If p_Line_Adj_Assoc_tbl.Count > 0 Then
		  l_assoc_index := p_Line_Adj_Assoc_tbl.last+1;
                  Else
                  l_assoc_index := 1;
                  End If;

                     --Commented for Bug2211670
		 -- l_assoc_index := p_Line_Adj_Assoc_tbl.count+1;

                  p_line_adj_assoc_tbl(l_assoc_index) := OE_ORDER_PUB.G_MISS_LINE_ADJ_ASSOC_REC;
		  p_Line_Adj_Assoc_tbl(l_assoc_index).line_index := Null;
		  p_Line_Adj_Assoc_tbl(l_assoc_index).Adj_Index := P_Parent_Adj_Index;
		  p_Line_Adj_Assoc_tbl(l_assoc_index).Rltd_Adj_Index :=
									p_Rltd_line_Details_prcd(p_Line_detail_Index);
		  p_Line_Adj_Assoc_tbl(l_assoc_index).Operation := OE_Globals.G_OPR_CREATE;

	End If; -- Match_exists

		adj_debug('Exiting oe_order_Adj_pvt.Process_Other_Item_Line',1);

End Process_Other_Item_Line;

Procedure Shell_Sort(p_sorted_tbl in out Nocopy oe_order_adj_pvt.sorted_adjustment_tbl_type) Is
h PLS_INTEGER:=1;
i PLS_INTEGER;
j PLS_INTEGER;
N PLS_INTEGER;

adj_rec oe_order_adj_pvt.Sorted_Adjustment_Rec_Type;

Begin
N := p_sorted_tbl.count;

--DBMS_OUTPUT.PUT_LINE('Determining h step size...');

For k in 1..N Loop
  h:= h*3 + 1;
  exit when h*3 + 1 > N;
End Loop;

--DBMS_OUTPUT.PUT_LINE('h: '||h);

For k in 1..h Loop
--DBMS_OUTPUT.PUT_LINE('h2:'||h);
  i:= h + 1;
  For i in h+1..N Loop
    adj_rec := p_sorted_tbl(i);
    j:=i;

    While ((j > h)
           and adj_rec.pricing_group_sequence IS NOT NULL
           and (p_sorted_tbl(j-h).pricing_group_sequence IS NULL OR
           p_sorted_tbl(j-h).pricing_group_sequence > adj_rec.pricing_group_sequence))
      Loop
        p_sorted_tbl(j) := p_sorted_tbl(j-h);
        j:=j-h;
      END Loop;
    p_sorted_tbl(j):=adj_rec;
  End Loop;
h:= h/3;
Exit When h < 1;
End Loop;

End;

Procedure sort_on_pgs(
p_Sorted_Tbl in out nocopy Oe_Order_Adj_Pvt.Sorted_Adjustment_Tbl_Type
,p_lo		pls_integer
,p_hi		pls_integer)
is
l_lo		pls_integer := p_lo;
l_hi		pls_integer := p_hi;
l_Sorted_Adjustment_Rec1				 Oe_Order_Adj_Pvt.Sorted_Adjustment_Rec_Type;
l_Sorted_Adjustment_Rec				Oe_Order_Adj_Pvt.Sorted_Adjustment_Rec_Type;
begin
  if p_lo >= p_hi Then
	Return;
  Elsif p_lo = p_hi -1 then
	if nvl(p_Sorted_Tbl(l_lo).pricing_group_sequence,-1) >
			nvl(p_Sorted_Tbl(l_hi).pricing_group_sequence,-1)
	Then
		l_Sorted_Adjustment_Rec1 := p_Sorted_Tbl(l_lo);
		p_Sorted_Tbl(l_lo) := p_Sorted_Tbl(l_hi);
		p_Sorted_Tbl(l_hi) := l_Sorted_Adjustment_Rec1;
	End If;
	Return;
  End If;

  l_Sorted_Adjustment_Rec := p_Sorted_Tbl((l_lo+l_hi)/2);
  p_Sorted_Tbl((l_lo+l_hi)/2):= p_Sorted_Tbl(l_hi);
  p_Sorted_Tbl(l_hi) :=  l_Sorted_Adjustment_Rec;

  While l_lo < l_hi loop

	While nvl(p_Sorted_Tbl(l_lo).pricing_group_sequence,fnd_api.g_miss_num) <=
		nvl(l_Sorted_Adjustment_Rec.pricing_group_sequence,fnd_api.g_miss_num)  and
		l_lo < l_hi loop

		l_lo := l_lo+1;
	end loop;

	While nvl(l_Sorted_Adjustment_Rec.pricing_group_sequence ,fnd_api.g_miss_num)<=
		nvl(p_Sorted_Tbl(l_hi).pricing_group_sequence,fnd_api.g_miss_num) and
		l_lo < l_hi loop
		l_hi := l_hi-1;
	end loop;

	If l_lo < l_hi then
		l_Sorted_Adjustment_Rec1 := p_Sorted_Tbl(l_lo);
		p_Sorted_Tbl(l_lo) := p_Sorted_Tbl(l_hi);
		p_Sorted_Tbl(l_hi) := l_Sorted_Adjustment_Rec1;
	end if;

  End loop;

  p_Sorted_Tbl(p_hi) :=  p_Sorted_Tbl(l_hi);
  p_Sorted_Tbl(l_hi) :=  l_Sorted_Adjustment_Rec;
  l_lo := l_lo -1;
  l_hi := l_hi+1;

  sort_on_pgs( p_Sorted_Tbl => p_Sorted_Tbl
		,p_lo			=> p_lo
		,p_hi			=> l_lo);

  sort_on_pgs( p_Sorted_Tbl => p_Sorted_Tbl
		,p_lo			=> l_hi
		,p_hi			=> p_hi);

End sort_on_pgs;

Function find_updated_adjustments(
	p_header_id 			number default null
	,p_Line_id 			number default null
	,p_Line_Adj_Tbl 		oe_order_pub.line_adj_tbl_type
	)
Return boolean
is
i		pls_integer;
begin
	i := p_Line_Adj_Tbl.first;
	while i is not null loop
	  If ( p_Line_Adj_Tbl(i).line_id = p_Line_id or
		  p_line_id is null and p_Line_Adj_Tbl(i).header_id = p_header_id ) and
		p_Line_Adj_Tbl(i).updated_flag = 'Y' and
		p_Line_Adj_Tbl(i).Applied_Flag = 'Y' then
		Return True; -- Atleast one adjustment has been updated
	  end if;
	  i := p_Line_Adj_Tbl.Next(i);
	end loop;
	Return False;
end find_updated_adjustments;

Procedure Gsa_Check(
p_header_id                             Number
,p_line_id				Number
,p_inventory_item_id    Varchar2 --bug 2673506
,p_pricing_date		date
,p_request_type_code	Varchar2
,p_unit_selling_price_per_pqty	number
,p_gsa_violation_action	Varchar2
,p_price_event1  Varchar2 default null  --for bug 2273446
)
is
l_hold_source_rec			OE_Holds_Pvt.hold_source_rec_type;
l_hold_release_rec  		OE_Holds_Pvt.Hold_Release_REC_Type;
l_return_status			varchar2(30);
l_x_msg_count                   number;
l_x_msg_data                    Varchar2(2000);
l_x_result_out                 Varchar2(30);
l_list_name				varchar2(240);
--for bug 2028480 Begin
l_gsa_released   varchar2(1):= 'N';
--for bug 2028480 end
l_operand					number;
l_msg_text				Varchar2(200);
l_org_id 					Number:= OE_Sys_Parameters.VALUE('MASTER_ORGANIZATION_ID');

Cursor get_gsa_list_lines is
Select/*+ ordered use_nl(qpq qppa qpll qplh) */ min(qpll.operand)
 From
      qp_qualifiers qpq
 ,    qp_pricing_attributes qppa
 ,    qp_list_lines qpll
 ,    qp_list_headers_b qplh
 ,    qp_price_req_sources qpprs
 where
 qpq.qualifier_context='CUSTOMER'
 and qpq.qualifier_attribute='QUALIFIER_ATTRIBUTE15'
 and qpq.qualifier_attr_value='Y'
 and qppa.list_header_id=qplh.list_header_id
 and qplh.Active_flag='Y'
 and qpprs.request_type_code = p_request_type_code
 and qpprs.source_system_code=qplh.source_system_code
 and    qppa.pricing_phase_id  = 2
 and    qppa.qualification_ind = 6
 and qppa.product_attribute_context ='ITEM'
 and qppa.product_attribute='PRICING_ATTRIBUTE1'
 and qppa.product_attr_value= p_inventory_item_id
 and qppa.excluder_flag = 'N'
 and qppa.list_header_id=qpq.list_header_id
 and qppa.list_line_id=qpll.list_line_id
 and  p_pricing_date between nvl(trunc(qplh.start_date_active),p_pricing_date)
 and nvl(trunc(qplh.End_date_active),p_pricing_date);


Begin

	 G_STMT_NO := 'Gsa_Check#10';
	 open get_gsa_list_lines;
	 fetch get_gsa_list_lines into l_operand;
	 close get_gsa_list_lines;

	 G_STMT_NO := 'Gsa_Check#20';
  	  if p_unit_selling_price_per_pqty <= l_operand then
		--Check if the GSA check needs to be done.
			If p_gsa_violation_action = 'WARNING' then
				Begin
					SELECT concatenated_segments
					INTO   l_msg_text
					FROM   mtl_system_items_kfv
					WHERE  inventory_item_id = p_inventory_item_id
					AND    organization_id = l_org_id;
					Exception when no_data_found then
		 			Null;
				End;
                     if nvl(p_price_event1,'N') <> 'PRICE' then --bug 2273446
  			FND_MESSAGE.SET_NAME('ONT','OE_GSA_VIOLATION');
			l_msg_text := l_operand||' ( '||l_msg_text||' )';
  			FND_MESSAGE.SET_TOKEN('GSA_PRICE',l_msg_text);
  			OE_MSG_PUB.Add;
                     end if; --bug 2273446

			Else
	 			G_STMT_NO := 'Gsa_Check#20.15';
                                -- bug 1381660, duplicate holds with type_code='GSA'
                                -- use the seeded hold_id
                                l_hold_source_rec.hold_id := G_SEEDED_GSA_HOLD_ID;
				/*Begin
					Select hold_id into l_hold_source_rec.hold_id
					from oe_hold_definitions where type_code='GSA';
					Exception when no_data_found then
		  			FND_MESSAGE.SET_NAME('ONT','OE_PRICING_ERROR');
		  			FND_MESSAGE.SET_TOKEN('ERR_TEXT','Missing hold_definition for type_code GSA');
		  			OE_MSG_PUB.Add;
					adj_debug('Missing hold_definition for type_code GSA');
				End;*/

				If p_line_id is null or
					p_line_id = fnd_api.g_miss_num then
		  			FND_MESSAGE.SET_NAME('ONT','OE_PRICING_ERROR');
		  			FND_MESSAGE.SET_TOKEN('ERR_TEXT','GSA_INVALID_LINE_ID');
		  			OE_MSG_PUB.Add;
					 RAISE FND_API.G_EXC_ERROR;
				End if;

	 			G_STMT_NO := 'Gsa_Check#20.20';
				l_hold_source_rec.hold_entity_id := p_header_id;
                                l_hold_source_rec.header_id := p_header_id;
                                l_hold_source_rec.line_id := p_line_id;
				l_hold_source_rec.Hold_Entity_code := 'O';
--for bug 2028480   Begin
--check if hold released earlier for this line , if so, do not go
--thru the holds logic
        adj_debug('Hold Id :'||l_hold_source_rec.hold_id);
        Begin
--changed select below to fix bug 3039915
          select 'Y' into l_gsa_released from
          oe_order_holds ooh,oe_hold_sources ohs,oe_hold_releases ohr
          where ooh.line_id = p_line_id
          and ooh.hold_source_id = ohs.hold_source_id
          and ohr.hold_release_id = ooh.hold_release_id
          and ohs.hold_id = l_hold_source_rec.hold_id
          and ohr.created_by <> 1
          and ohr.release_reason_code <> 'PASS_GSA';
        exception
          when others then
            l_gsa_released := 'N';
        end;
        adj_debug('GSA released value :'||l_gsa_released);
--for bug 2028480   end
                        if l_gsa_released = 'N' then --for bug 2028480
               -- check if line already on gsa hold, place hold if not
  			        OE_Holds_Pub.Check_Holds(
					p_api_version		=> 1.0
                                        ,p_header_id            => p_header_id
					,p_line_id		=> p_line_id
					,p_hold_id		=> l_hold_source_rec.Hold_id
					,x_return_status	=> l_return_status
					,x_msg_count		=> l_x_msg_count
					,x_msg_data		=> l_x_msg_data
					,x_result_out		=> l_x_result_out
					);

  			        If  l_x_result_out = FND_API.G_FALSE then
                                  adj_debug('hold line with header_id:'||p_header_id||' line_id: '||p_line_id,1);
				  OE_HOLDS_PUB.Apply_Holds(
					p_api_version	=> 1.0
					,p_hold_source_rec	=> l_hold_source_rec
					,x_return_status	=> l_return_status
					,x_msg_count		=> l_x_msg_count
					,x_msg_data		=> l_x_msg_data
					);

				  If l_return_status = FND_API.g_ret_sts_success then
                        if nvl(p_price_event1,'N') <> 'PRICE' then --bug 2273446

		     	  FND_MESSAGE.SET_NAME('ONT','OE_GSA_HOLD_APPLIED');
		  	  OE_MSG_PUB.Add;
                        end if; --bug 2273446
				  Else
		  			FND_MESSAGE.SET_NAME('ONT','OE_PRICING_ERROR');
		  			FND_MESSAGE.SET_TOKEN('ERR_TEXT','APPLY_GSA_HOLD');
		  			OE_MSG_PUB.Add;
					RAISE FND_API.G_EXC_ERROR;
				  End If;
                                End If; /* check hold */
                         End If; --for bug 2028480 end
			End if;  /* violation action */

	 Else -- Check if a hold was placed before , release the hold
		If p_line_id is not null and
			p_line_id <> fnd_api.g_miss_num then

			If l_hold_source_rec.hold_id is null or
					l_hold_source_rec.hold_id = fnd_api.g_miss_num then
	 			G_STMT_NO := 'Gsa_Check#20.25';
                                -- bug 1381660, duplicate holds with type_code='GSA'
                                -- use the seeded hold_id
                                l_hold_source_rec.hold_id := G_SEEDED_GSA_HOLD_ID;
				/*Begin
					Select hold_id into l_hold_source_rec.hold_id
					from oe_hold_definitions where type_code='GSA';
					Exception when no_data_found then
		  			FND_MESSAGE.SET_NAME('ONT','OE_PRICING_ERROR');
		  			FND_MESSAGE.SET_TOKEN('ERR_TEXT','Missing hold_definition for type_code GSA');
		  			OE_MSG_PUB.Add;
					adj_debug('Missing hold_definition for type_code GSA');
				End;*/

			End if; -- Hold id
	 		G_STMT_NO := 'Gsa_Check#20.30';

				l_hold_source_rec.hold_entity_id := p_header_id;
                                l_hold_source_rec.header_id := p_header_id;
                                l_hold_source_rec.line_id := p_line_id;
				l_hold_source_rec.Hold_Entity_code := 'O';


			OE_Holds_Pub.Check_Holds(
					p_api_version		=> 1.0
                                        ,p_header_id            => p_header_id
					,p_line_id		=> p_line_id
					,p_hold_id		=> l_hold_source_rec.Hold_id
					,x_return_status	=> l_return_status
					,x_msg_count		=> l_x_msg_count
					,x_msg_data		=> l_x_msg_data
					,x_result_out		=> l_x_result_out
					);


			If  l_x_result_out = FND_API.G_TRUE then
				-- Hold is found , Release the hold.

	 			G_STMT_NO := 'Gsa_Check#20.35';
			l_hold_release_rec.release_reason_code :='PASS_GSA';
  --for bug 3039915 set created_by = 1  to indicate automatic hold release
		l_hold_release_rec.created_by := 1;

				OE_Holds_Pub.Release_Holds(
					p_api_version	=> 1.0
--					,p_hold_id		=> l_hold_source_rec.Hold_id
--					,p_entity_code 	=> l_hold_source_rec.Hold_entity_code
--					,p_entity_id		=> l_hold_source_rec.Hold_entity_id
                                        ,p_hold_source_rec      => l_hold_source_rec
					,p_hold_release_rec	=> l_hold_release_rec
					,x_return_status	=> l_return_status
					,x_msg_count		=> l_x_msg_count
					,x_msg_data		=> l_x_msg_data
					);

				IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
					adj_debug('Error while releasing GSA Hold');
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
					adj_debug('Error while releasing GSA Hold');
					RAISE FND_API.G_EXC_ERROR;
				END IF;
			End if; -- Release Hold

		End if; -- GSA Check Hold

	 End If; -- GSA Violation


End Gsa_Check;

Procedure CAlculate_Adjusted_Price(
p_bucketed_price   			Number
,p_line_category                          Varchar2
,p_arithmetic_operator			Varchar2
,p_operand					Number
,p_Pricing_Quantity				Number
,p_rounding_Factor				Number
,p_modifier_level_code                          Varchar2 := NULL
,p_group_value                                  Number   := NULL
,x_Adjusted_Amount out nocopy NUMBER

)
Is
Begin
	adj_debug('Entering oe_order_Adj_pvt.CAlculate_Adjusted_Price');
	If p_arithmetic_operator = 'AMT' Then
		x_Adjusted_Amount := p_operand;
	Elsif p_arithmetic_operator = '%' then
               --bug 2764291
		x_Adjusted_Amount := abs(p_bucketed_price) *p_operand /100;
	Elsif p_arithmetic_operator = 'NEWPRICE' Then
                x_Adjusted_Amount := - p_bucketed_price + p_operand;

	Elsif p_arithmetic_operator = 'LUMPSUM' then
     --
             IF (p_modifier_level_code  = QP_PREQ_GRP.G_LINE_GROUP) THEN
	        --
		   -- p_modifier_level_code = 'LINEGROUP'
		   --
                 adj_debug('LINEGROUP');
			  IF nvl(p_group_value,0) <> 0 THEN
                     x_Adjusted_Amount := p_operand / p_group_value;
				 adj_debug('p_group_value');
                 ELSE
                     --x_Adjusted_Amount := p_operand;
                     x_adjusted_amount:=0;
                     adj_debug('p_group_value is 0');
                 END IF;
             ELSE
                If nvl(p_Pricing_Quantity,0) <> 0 then
			    x_Adjusted_Amount := p_operand / p_Pricing_Quantity;
		      Else
			    x_Adjusted_Amount := p_operand;
                END IF;
		   End IF;
	End If;


	adj_debug('Exiting oe_order_Adj_pvt.CAlculate_Adjusted_Price');

end CAlculate_Adjusted_Price;

Procedure Calculate_Price (
p_Header_Rec					Oe_Order_Pub.Header_Rec_Type
,p_Line_Tbl		in out nocopy	Oe_Order_Pub.Line_Tbl_Type
,p_Line_Adj_Tbl	in out nocopy Oe_Order_Pub.Line_Adj_Tbl_Type
,p_line_adj_assoc_Tbl		Oe_Order_Pub.line_adj_assoc_Tbl_Type
,p_allow_Negative_Price		Varchar2
,p_request_Type_Code		Varchar2
,p_any_line_frozen              Boolean default False
,p_price_event  Varchar2 default null  --for bug 2273446
,p_honor_price_flag   Varchar2  default  'Y'   --bug 2503186
)
is
lx_return_status	 varchar2(1) := FND_API.G_RET_STS_SUCCESS;
lx_return_status_Text	 varchar2(240) ;
l_discount_surcharge		Boolean;
i						pls_integer;
J						pls_integer;
J1						pls_integer;
J2						pls_integer;
l_Bucketed_price			Number;
l_pricing_group_sequence		Number := fnd_api.g_miss_num;
l_Total_Quantity			Number;
l_sign					Number;
l_rounding_factor			Number;
l_gsa_violation_action		Varchar2(30); --moac moving the initialization to the body
l_GSA_Enabled_Flag 			Varchar2(30) := FND_PROFILE.VALUE('QP_VERIFY_GSA');
l_Sorted_Adjustment_Tbl		oe_order_Adj_pvt.Sorted_Adjustment_Tbl_Type;
l_Sort_Index				Pls_Integer;
l_pricing_quantity			Number;
l_assoc_exist				Boolean;
l_adjusted_amt_changed                  Boolean;
-- for bug 1717501  Begin
l_gsa_cust_check varchar2(1);
-- for bug 1717501 end
l_status_code Varchar2(5);

l_item_rec                    OE_ORDER_CACHE.item_rec_type; -- OPM 2547940
l_process		      Boolean; -- OPM 2547940

Begin

	adj_debug('Entering oe_order_Adj_pvt.Calculate_Price');

	--moac
        l_gsa_violation_action    := oe_sys_parameters.value('ONT_GSA_VIOLATION_ACTION',p_header_rec.org_id);

	 --OE_Order_Pub.G_HDR := p_header_rec;

	G_STMT_NO := 'Calculate_Price#05';
	i := p_Line_Adj_Tbl.First;

	While i is not null loop
		l_Sorted_Adjustment_Tbl(i).Adj_Index := i;
		l_Sorted_Adjustment_Tbl(i).pricing_group_sequence := p_Line_Adj_Tbl(i).pricing_group_sequence;
		i := p_Line_Adj_Tbl.Next(i);
	End Loop;

	shell_sort(p_Sorted_Tbl => l_Sorted_Adjustment_Tbl);

	G_STMT_NO := 'Calculate_Price#10';
	i:= p_Line_Tbl.First;
	 adj_debug('Honor Price flag :'||p_honor_price_flag,2);
	While  i is not null Loop
	l_process := 											-- INVCONV oe_line_util.Process_Characteristics -- OPM 2547940
                        oe_line_util.dual_uom_control  -- INVCONV
                       (p_line_tbl(i).inventory_item_id
                        ,p_line_tbl(i).ship_from_org_id
                        ,l_item_rec);

         If p_line_tbl(i).calculate_price_flag in ('Y','P')
            OR (p_price_event is NULL and
                p_line_tbl(i).operation = oe_globals.G_OPR_UPDATE)
            OR p_honor_price_flag = 'N'  --bug 2503186
            OR  -- OPM 2547940 start - for copy of order OR split from shipping - need to re-price as these lines
                -- as may have freeze price for calulate price flag when pricing by quantity2
             (
                   ( l_process)
                   and  (l_item_rec.ont_pricing_qty_source = 1 ) -- price by quantity 2
                   and  ( p_line_tbl(i).calculate_price_flag In ('N','P') )
		   and ( p_line_tbl(i).split_by is not null )
		   and ( p_line_tbl(i).split_from_line_id is not null and p_line_tbl(i).split_from_line_id <> FND_API.G_MISS_NUM)
             ) --  OPM 2547940 end


         Then
	 adj_debug('Processing Line id '||p_line_tbl(i).line_id,2);

	 If p_Line_Tbl(i).operation in (oe_globals.g_opr_delete, oe_globals.g_opr_lock) or
            (p_Line_Tbl(i).Unit_list_price is null
             and p_Line_Tbl(i).Unit_list_price_per_pqty is null)
         Then
            adj_debug('Line '||p_line_tbl(i).line_id||' price is not calculated');
            adj_debug(' Unit_list_price:'||p_Line_Tbl(i).Unit_list_price);
            adj_debug(' Unit_list_price_per_pqty:'||p_Line_Tbl(i).Unit_list_price_per_pqty);
            adj_debug(' Line opr '||p_Line_Tbl(i).operation);
         Else


                adj_debug('selling price before ..'||p_Line_Tbl(i).Unit_Selling_Price_Per_Pqty);

                --For backward compatiblity, to correct the old data
                If  nvl(p_Line_Tbl(i).unit_list_price_Per_Pqty,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM and
                    p_Line_Tbl(i).unit_list_price is Not Null Then
                    If nvl(p_line_tbl(i).pricing_quantity,0) <> 0 and
                       p_line_tbl(i).pricing_quantity <> FND_API.G_MISS_NUM
                    Then
                      p_line_tbl(i).unit_list_price_per_pqty :=(p_line_tbl(i).unit_list_price * p_line_tbl(i).ordered_quantity)/p_line_tbl(i).pricing_quantity;
                    Else
                      p_Line_Tbl(i).unit_list_price_Per_Pqty := p_Line_Tbl(i).unit_list_price;
                    End If;
                End If;

                If nvl(p_Line_Tbl(i).unit_selling_price_per_pqty,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM and
                   p_Line_Tbl(i).unit_selling_price Is Not Null Then
                     If nvl(p_line_tbl(i).pricing_quantity,0) <> 0 and
                        p_line_tbl(i).pricing_quantity <> FND_API.G_MISS_NUM
                     Then
                      p_line_tbl(i).unit_selling_price_per_pqty :=(p_Line_Tbl(i).unit_selling_price * p_line_tbl(i).ordered_quantity)/p_line_tbl(i).pricing_quantity;
                     Else
                      p_Line_Tbl(i).unit_selling_price_per_pqty := p_Line_Tbl(i).unit_selling_price;
                     End If;
                End If;

                -- uom begin
		  p_line_tbl(i).Unit_Selling_Price_Per_Pqty := p_Line_Tbl(i).unit_list_price_Per_Pqty;
		  l_bucketed_price := p_line_Tbl(i).unit_list_price_per_pqty;
                -- uom end

		l_pricing_group_sequence		:= fnd_api.g_miss_num;


		adj_debug('No of adjs in Calculate_Price '||p_Line_Adj_Tbl.count);
		l_Sort_Index:= l_Sorted_Adjustment_Tbl.First;
		While l_Sort_Index is not null Loop

		J := l_Sorted_Adjustment_Tbl(l_Sort_Index).Adj_Index;
                l_adjusted_amt_changed := FALSE;
                oe_debug_pub.add('  Sorted index value:'||J);
		G_STMT_NO := 'Calculate_Price#20';

		  If ( p_Line_Adj_Tbl(j).Line_Index = i  or
			  (p_Line_Adj_Tbl(j).line_id = p_Line_Tbl(i).line_id and
			 	p_Line_Adj_Tbl(j).line_id <> fnd_api.g_miss_num
			  )or
			  ( ( p_Line_Adj_Tbl(j).line_id is null or
				 p_Line_Adj_Tbl(j).line_id = fnd_api.g_miss_num ) and
				 (p_Line_Adj_Tbl(j).line_index is null or
				 p_Line_Adj_Tbl(j).line_index = fnd_api.g_miss_num) and
				 p_Line_Adj_Tbl(j).Header_Id = p_header_Rec.Header_Id
				 )) and -- Header Level Adjustments
			  p_Line_Adj_Tbl(j).Operation <> OE_Globals.G_OPR_DELETE and
			  nvl(p_Line_Adj_Tbl(j).applied_flag,'N')='Y' and
/* Modified the nvl to 'N' in the above statement to fix the bug 2164508 */
			  p_Line_Adj_Tbl(j).list_line_type_code in ('DIS','SUR','FREIGHT_CHARGE','PBH')
		  then

                        --adj_debug('BCT+fullfilled calculate');
			If p_Line_Adj_Tbl(j).pricing_group_sequence is null then
                            If nvl(p_line_Tbl(i).unit_list_price_per_pqty,FND_API.G_MISS_NUM)
                               <> FND_API.G_MISS_NUM
                            Then
                            	l_bucketed_price := p_line_Tbl(i).unit_list_price_per_pqty;
                            Else
                                l_bucketed_price := p_line_Tbl(i).unit_list_price;
                            End If;
			Elsif p_Line_Adj_Tbl(j).pricing_group_sequence <> l_pricing_group_sequence then
                            If nvl(p_line_Tbl(i).unit_selling_price_per_pqty,FND_API.G_MISS_NUM)
                               <> FND_API.G_MISS_NUM
                            Then
                            	l_bucketed_price := p_line_Tbl(i).unit_selling_price_per_pqty;
                            Else
                                l_bucketed_price := p_line_Tbl(i).unit_selling_price;
                            End If;
			End If;

			If p_Line_Adj_Tbl(j).List_line_type_code = 'PBH' Then

			  adj_debug('First Time Adj Amount: ' || p_Line_Adj_Tbl(j).Adjusted_Amount_Per_Pqty,3);
                          --reset adj amount for parent PBH.
                          --will be recalculated.
                          If p_line_adj_tbl(j).price_break_type_code = QP_PREQ_GRP.G_RANGE_BREAK Then
                             p_Line_Adj_Tbl(j).adjusted_amount_per_pqty:=0;
                          End If;
                            oe_debug_pub.add('xNo of assoc in assoc_tbl:'|| p_line_adj_assoc_Tbl.count);
		    	  J1 := p_line_adj_assoc_Tbl.First;
			  l_Total_Quantity := 0;
			  l_assoc_exist := FALSE;
			  While J1 is not null loop
			 	If ( (p_line_adj_assoc_Tbl(j1).Adj_index = J Or
					    (p_line_adj_assoc_Tbl(j1).Price_adjustment_id =
						  p_Line_Adj_Tbl(j).Price_Adjustment_id and
						  p_Line_Adj_Tbl(j).Price_Adjustment_id <> fnd_api.g_miss_num )) and (nvl(p_line_adj_assoc_Tbl(j1).operation,'xxyz') <>  OE_GLOBALS.G_OPR_DELETE)
					)  Then
				  l_assoc_exist := TRUE;
			       p_Line_Adj_Tbl(j).Adjusted_Amount_Per_Pqty := 0;
                               l_adjusted_amt_changed := TRUE;
				End If;
			 	J1 := p_line_adj_assoc_Tbl.Next(J1);
			  End Loop;

			  If (p_Line_Adj_Tbl(j).Adjusted_Amount_Per_Pqty <> 0 and l_assoc_exist = FALSE) Then
			   adj_debug('Adjusted Amount  pqty : ' || nvl(p_line_adj_tbl(j).adjusted_amount_per_pqty,0));
                           adj_debug('adjusted amount :'||p_line_adj_tbl(j).adjusted_amount);
			   adj_debug('Unit Selling Price #100 : ' || nvl(p_line_tbl(i).Unit_Selling_Price,0));


			   p_line_tbl(i).Unit_Selling_Price_Per_Pqty :=
			   p_line_tbl(i).Unit_Selling_Price_Per_Pqty + nvl(p_Line_Adj_Tbl(j).Adjusted_Amount_Per_Pqty,0);
			   p_Line_Adj_Tbl(j).Adjusted_Amount_Per_Pqty := 0;
                           l_adjusted_amt_changed := TRUE;
			  End If;

		    	  J1 := p_line_adj_assoc_Tbl.First;
			  G_STMT_NO := 'Calculate_Price#30';

			  adj_debug('Calculate_Price: PBH Line ('||j||')'||
										p_Line_Adj_Tbl(j).price_adjustment_id,2);
			  adj_debug('PBH Adjustment ('||j||')'||
										p_Line_Adj_Tbl(j).adjusted_amount_per_pqty,2);
		    	  While J1 is not null loop
			 	If ( (p_line_adj_assoc_Tbl(j1).Adj_index = J Or
					    (p_line_adj_assoc_Tbl(j1).Price_adjustment_id =
						  p_Line_Adj_Tbl(j).Price_Adjustment_id and
						  p_Line_Adj_Tbl(j).Price_Adjustment_id <> fnd_api.g_miss_num )) And (nvl(p_line_adj_assoc_Tbl(j1).operation,'xxyz') <>  OE_GLOBALS.G_OPR_DELETE)

					)  Then

				adj_debug('Got an association Rltd_index '||p_line_adj_assoc_Tbl(j1).Rltd_Adj_index,2);
                                adj_debug('line_adj_assoc_operation:'||p_line_adj_assoc_Tbl(j1).operation);
				-- Get the Related Adj Line
				J2 := p_Line_Adj_Tbl.First;

				G_STMT_NO := 'Calculate_Price#40';
				  While J2 is not null loop
				  	If ( p_line_adj_assoc_Tbl(j1).Rltd_Adj_index = J2 Or
					  	     ( p_line_adj_assoc_Tbl(j1).Rltd_Price_Adj_Id =
							p_Line_Adj_Tbl(j2).Price_adjustment_id  and
							p_line_adj_assoc_Tbl(j1).Rltd_Price_Adj_Id <> fnd_api.g_miss_num )
							) and
							p_Line_Adj_Tbl(j2).Range_Break_Quantity > 0 and
							p_Line_Adj_Tbl(j2).list_line_type_code in ('DIS','SUR','FREIGHT_CHARGE')
					Then

						adj_debug(j2||')The Child line is '||p_Line_Adj_Tbl(j2).list_line_type_code,2);
						adj_debug('List line id '||p_Line_Adj_Tbl(j2).list_line_id,2);
						adj_debug('Pricing Qty #150 '||p_Line_Tbl(i).pricing_quantity,2);
						adj_debug('Range Break Qty #151 '||p_Line_adj_Tbl(j2).range_break_quantity,2);

						If p_Line_Adj_Tbl(j2).list_line_type_code in ('DIS','SUR') Then
							l_discount_surcharge := TRUE;
						Else
							l_discount_surcharge := FALSE;
						End If;
						If p_Line_Adj_Tbl(j2).list_line_type_code = 'DIS'
						   AND p_Line_Adj_Tbl(j2).arithmetic_operator <> 'NEWPRICE' Then
							l_sign	:= -1;
						Else
							l_sign    := +1;
						End If;

                                            IF p_Line_Adj_Tbl(j2).updated_flag = 'Y' and p_Line_Adj_Tbl(j).updated_flag <> 'Y' THEN
                                                p_Line_Adj_Tbl(j).updated_flag := 'Y';
                                                p_Line_Adj_Tbl(j).change_reason_code := p_Line_Adj_Tbl(J2).change_reason_code;
                                                p_Line_Adj_Tbl(j).change_reason_text := p_Line_Adj_Tbl(J2).change_reason_text;

                                            END IF;

					    G_STMT_NO := 'Calculate_Price#50';

						If p_Line_Adj_Tbl(j).Price_break_Type_Code = QP_PREQ_GRP.G_RANGE_BREAK Then
						 l_pricing_quantity := p_line_adj_tbl(j2).Range_Break_Quantity;

					     Else
						 l_pricing_quantity := p_line_tbl(i).pricing_quantity;
					     End If;

If p_Line_Adj_Tbl(j2).Operand_per_pqty is Null Then
   p_Line_Adj_Tbl(j2).Operand_per_pqty := p_Line_Adj_Tbl(j2).Operand;
End If;

                            /* Added for the bug#2647485 */
                            IF (
                              --p_line_adj_tbl(j).list_line_type_code <> 'FREIGHT_CHARGE' AND ** Commented for bug#3594917 **
                                p_line_tbl(i).calculate_price_flag = 'P' AND
                                p_line_tbl(i).line_category_code = 'RETURN' AND
                                p_Line_Adj_Tbl(j2).Arithmetic_operator = 'LUMPSUM' ) THEN
                            	NULL;
                            ELSE
                               --For bug 2874499.
                               If (p_Line_Adj_Tbl(j2).Arithmetic_operator = 'LUMPSUM'
                                  and p_line_adj_tbl(j2).modifier_level_code = QP_PREQ_GRP.G_LINE_GROUP and
                                  p_line_adj_tbl(j2).automatic_flag = 'N')then
                                      p_line_adj_tbl(j2).group_value := 1;
                               end if ;
					  CAlculate_Adjusted_Price(
							p_bucketed_price=> l_bucketed_price,
                                                        p_line_category=> p_line_tbl(i).line_category_code,
							p_arithmetic_operator=> p_Line_Adj_Tbl(j2).Arithmetic_operator,
							p_operand	=> l_sign*p_Line_Adj_Tbl(j2).Operand_per_pqty,
							p_Pricing_Quantity=> l_pricing_quantity,
							p_rounding_Factor=> l_rounding_FActor,
                                   p_modifier_level_code => p_line_adj_tbl(j2).modifier_level_code,
                                   p_group_value         => p_line_adj_tbl(j2).group_value,
							x_Adjusted_Amount=> p_Line_Adj_Tbl(j2).Adjusted_Amount_Per_Pqty
							);
                            END IF;

					    G_STMT_NO := 'Calculate_Price#60';
						If p_Line_Adj_Tbl(j).Price_break_Type_Code = QP_PREQ_GRP.G_RANGE_BREAK Then
							 If nvl(p_Line_Adj_Tbl(j).Adjusted_Amount_Per_Pqty,FND_API.G_MISS_NUM)=FND_API.G_MISS_NUM Then
                                                            p_Line_Adj_Tbl(j).Adjusted_Amount_Per_Pqty:=0;
                                                       End If;

							p_Line_Adj_Tbl(j).Adjusted_Amount_Per_Pqty	:=
								p_Line_Adj_Tbl(j).Adjusted_Amount_Per_Pqty +
									p_Line_Adj_Tbl(j2).Adjusted_Amount_Per_Pqty * p_Line_Adj_Tbl(j2).Range_break_Quantity;
                                                        l_adjusted_amt_changed := TRUE;
							l_total_Quantity := l_total_Quantity + p_Line_Adj_Tbl(j2).Range_break_Quantity;

                         oe_debug_pub.add(' Rounding adj list line ty:'|| p_Line_Adj_Tbl(j).list_line_type_code);
                         oe_debug_pub.add(' Rounding adj list line id:'||p_Line_Adj_Tbl(j).list_line_id);
                         oe_debug_pub.add(' Rounding adj operand:'||p_Line_Adj_Tbl(j).operand);

						Else
							p_Line_Adj_Tbl(j).Adjusted_Amount_Per_Pqty := p_Line_Adj_Tbl(j2).Adjusted_Amount_Per_Pqty;
                                                        l_adjusted_amt_changed := TRUE;
						End If; -- Break Type

					adj_debug('Adj Amount '||p_Line_Adj_Tbl(j).Adjusted_Amount_Per_Pqty,2);

				  	End If; -- Rltd Lines ( Child lines for PBH )

				     J2:= p_Line_Adj_Tbl.Next(J2);

				  End Loop; -- J2

			 	End If; -- J1 if
			 	J1 := p_line_adj_assoc_Tbl.Next(J1);
		       End loop; -- J1

   If  p_Line_Adj_Tbl(j).Price_Break_Type_Code = QP_PREQ_GRP.G_RANGE_BREAK Then
oe_debug_pub.add('xAdj_amt_pqty:'||p_line_adj_tbl(j).adjusted_amount_per_pqty);
   if p_line_adj_tbl(j).range_break_quantity is null and l_total_quantity > 0
   then --bug 2813670
    oe_debug_pub.add('Value of l_tot_qty :'||l_total_quantity);
    p_line_adj_tbl(j).adjusted_amount_per_pqty :=
    p_line_adj_tbl(j).adjusted_amount_per_pqty/l_total_quantity;
   else
    p_line_adj_tbl(j).adjusted_amount_per_pqty :=
    p_line_adj_tbl(j).adjusted_amount_per_pqty/p_line_adj_tbl(j).range_break_quantity;
   end if;
oe_debug_pub.add('xRange break qty:'||p_line_adj_tbl(j).range_break_quantity);

oe_debug_pub.add('xFinal Range break adj amt:'||p_line_adj_tbl(j).adjusted_amount_per_pqty);
   End If;

                        If p_Line_Adj_Tbl(j).operand is not null Then
                           QP_UTIL_PUB.round_price
                              (p_operand                => p_Line_Adj_Tbl(j).adjusted_amount_per_pqty,
			       p_rounding_factor        => NULL,
			       p_use_multi_currency     => 'Y',
			       p_price_list_id          => p_line_tbl(i).price_list_id,
			       p_currency_code          => g_order_currency,
			       p_pricing_effective_date => p_line_tbl(i).pricing_date,
			       x_rounded_operand        => p_Line_Adj_Tbl(j).adjusted_amount_per_pqty,
			       x_status_code            => l_status_code,
                               p_operand_type           => 'A'
                               );
                         Else
                             p_Line_Adj_Tbl(j).adjusted_amount_per_pqty:=nvl(p_Line_Adj_Tbl(j).adjusted_amount_per_pqty,0);
                             p_Line_Adj_Tbl(j).operand:=0;
                         End if;


		     Else -- Not a Price Break Line

			  G_STMT_NO := 'Calculate_Price#80';
				If p_Line_Adj_Tbl(j).list_line_type_code in ('DIS','SUR') Then
					l_discount_surcharge := TRUE;
				Else
					l_discount_surcharge := FALSE;
				End If;
				If p_Line_Adj_Tbl(j).list_line_type_code = 'DIS'
				   AND p_Line_Adj_Tbl(j).arithmetic_operator <> 'NEWPRICE' Then
					l_sign	:= -1;
				Else
					l_sign    := +1;
				End If;

			     G_STMT_NO := 'Calculate_Price#90';

				adj_debug(j||')Line Index '||p_Line_Adj_Tbl(j).line_index,3);
				adj_debug('Operand '||p_Line_Adj_Tbl(j).operand_per_pqty,3);
				adj_debug('Arithmetic op '||p_Line_Adj_Tbl(j).Arithmetic_operator,3);
				adj_debug('Pricing Quantity '||p_line_tbl(i).Pricing_Quantity,3);
				adj_debug('Bucketed price '||l_bucketed_price,3);
				adj_debug('-----------------',3);

                            /* Added for the bug#2647485 */
                            IF (
                              --p_line_adj_tbl(j).list_line_type_code <> 'FREIGHT_CHARGE' AND ** Commented for bug#3594917 **
                                p_line_tbl(i).calculate_price_flag = 'P' AND
                                p_line_tbl(i).line_category_code = 'RETURN' AND
                                p_Line_Adj_Tbl(j).Arithmetic_operator = 'LUMPSUM' ) THEN

                                p_Line_Adj_Tbl(j).operand := p_line_tbl(i).Ordered_Quantity
                                                           * p_Line_Adj_Tbl(j).Adjusted_Amount
                                                           * l_sign;
                                p_Line_Adj_Tbl(j).operand_per_pqty := NULL;

                            ELSE
                               --For bug 2874499.
                               If (p_Line_Adj_Tbl(j).Arithmetic_operator = 'LUMPSUM'
                                  and p_line_adj_tbl(j).modifier_level_code = QP_PREQ_GRP.G_LINE_GROUP and
                                  p_line_adj_tbl(j).automatic_flag = 'N')then
                                      p_line_adj_tbl(j).group_value := 1;
                               end if ;

				CAlculate_Adjusted_Price(
					p_bucketed_price   			=> l_bucketed_price,
                                        p_line_category=> p_line_tbl(i).line_category_code,
					p_arithmetic_operator		=> p_Line_Adj_Tbl(j).Arithmetic_operator,
					p_operand					=>  l_sign*p_Line_Adj_Tbl(j).Operand_per_pqty,
					p_Pricing_Quantity			=>  p_line_tbl(i).pricing_quantity,
					p_rounding_Factor			=>  l_rounding_FActor,
					p_modifier_level_code         => p_line_adj_tbl(j).modifier_level_code,
					p_group_value                 => p_line_adj_tbl(j).group_value,
                                        --p_price_list_id               => p_line_tbl(i).price_list_id,
                                        --p_pricing_effecitve_date      => p_line_tbl(i).pricing_date,
					x_Adjusted_Amount			=>  p_Line_Adj_Tbl(j).Adjusted_Amount_Per_Pqty
					);
                            END IF;
                                l_adjusted_amt_changed := TRUE;

				adj_debug('+Adjusted_Amount pqty '||p_Line_Adj_Tbl(j).Adjusted_Amount_Per_Pqty,2);
                                adj_debug('+Adjusted_Amount '||p_Line_Adj_Tbl(j).Adjusted_Amount,2);

                       If p_Line_Adj_Tbl(j).operand is not null Then
                   --commenting call to round price to fix bug 3043251
                         /* QP_UTIL_PUB.round_price
                              (p_operand                => p_Line_Adj_Tbl(j).adjusted_amount_per_pqty,
			       p_rounding_factor        => NULL,
			       p_use_multi_currency     => 'Y',
			       p_price_list_id          => p_line_tbl(i).price_list_id,
			       p_currency_code          => g_order_currency,
			       p_pricing_effective_date => p_line_tbl(i).pricing_date,
			       x_rounded_operand        => p_Line_Adj_Tbl(j).adjusted_amount_per_pqty,
			       x_status_code            => l_status_code,
                               p_operand_type           => 'A'
                               ); */
                          NULL;
                         Else
                             p_Line_Adj_Tbl(j).adjusted_amount_per_pqty:=nvl(p_Line_Adj_Tbl(j).adjusted_amount_per_pqty,0);
                             p_Line_Adj_Tbl(j).operand:=0;
                         End if;

		     End If; -- Check list line type for price break

			     G_STMT_NO := 'Calculate_Price#100';
			If l_discount_surcharge and nvl(p_Line_Adj_Tbl(j).Accrual_Flag,'N') <> 'Y'
			then -- Do not Add Freight charges to the selling price
			 adj_debug('Adjusted Amount : ' || nvl(p_line_adj_tbl(j).adjusted_amount_per_pqty,0),3);
			 adj_debug('Unit Selling Price #100 : ' || nvl(p_line_tbl(i).Unit_Selling_Price_Per_Pqty,0),3);
				p_line_tbl(i).Unit_Selling_Price_Per_Pqty := p_line_tbl(i).Unit_Selling_Price_Per_Pqty + nvl(p_Line_Adj_Tbl(j).Adjusted_Amount_Per_Pqty,0);
			End If;

		  	l_pricing_group_sequence := p_Line_Adj_Tbl(j).pricing_group_sequence;
		  End If; -- Adj Lines
                  If (l_adjusted_amt_changed AND p_Line_Adj_Tbl(j).operation = FND_API.G_MISS_CHAR) Then

                    If not (p_any_line_frozen and p_line_adj_tbl(j).modifier_level_code = 'ORDER') Then
                    adj_debug('Calculate Price:'||p_Line_Adj_Tbl(j).list_line_id);
                      If p_Line_Adj_Tbl(j).updated_flag = 'N' Then
                        p_Line_Adj_Tbl(j).operation := OE_GLOBALS.G_OPR_UPDATE;
                      End If;
                    End If;
                  End If;
		  l_Sort_Index:= l_Sorted_Adjustment_Tbl.Next(l_Sort_Index);

                  -- uom begin
                  If p_line_adj_tbl(j).arithmetic_operator IN ('AMT','NEWPRICE') Then
                  --bsadri fixed zero division error for cancelled lines
                    IF NVL(p_line_tbl(i).ordered_quantity,0) <> 0 AND
                     p_line_tbl(i).ordered_quantity <> fnd_api.g_miss_num THEN
                      p_Line_Adj_Tbl(j).operand := p_Line_Adj_tbl(j).operand_per_pqty * p_line_tbl(i).pricing_quantity/p_line_tbl(i).ordered_quantity;
                    END IF;

                    -- OPM 2547940  start - if pricing by quantity2 then if line is shipped and has shipped qty2 != ordered qty2
--  need to adjust the operand so that invoicing will show correct amount (ordered qty * USP (adjusted) )
 		    IF oe_line_util.dual_uom_control  -- INVCONV
                   -- Process_Characteristics  invconv
              		(p_line_tbl(i).inventory_item_id
              		,p_line_tbl(i).ship_from_org_id
              		,l_item_rec) THEN
                   		oe_debug_pub.add('OPM - this IS a process line in proc calculate_price in OEXVADJB.pls ');
                        	IF l_item_rec.ont_pricing_qty_source = 'S'  THEN -- price by quantity 2 INVCONV

   				  	IF (p_line_tbl(i).ordered_quantity2 IS NOT NULL and p_line_tbl(i).ordered_quantity2 <> 0	)
                        		AND ( p_line_tbl(i).shipped_quantity2 IS NOT NULL and p_line_tbl(i).shipped_quantity2 <> 0	)
                        		AND  (p_line_tbl(i).ordered_quantity2 <> p_line_tbl(i).shipped_quantity2)   THEN
                        		 oe_debug_pub.add('OPM Updating operand ' ,5);
                       		     p_Line_Adj_Tbl(j).operand := (p_Line_Adj_tbl(j).operand_per_pqty* p_line_tbl(i).pricing_quantity )/p_line_tbl(i).ordered_quantity2
                       		      * (p_line_tbl(i).shipped_quantity2/p_line_tbl(i).ordered_quantity);
                       		      oe_debug_pub.ADD('OPM NEW operand : '|| to_char(p_Line_Adj_Tbl(j).operand),5);
               				 END IF;
               			END IF;
		    END IF;  --oe_line_util.dual_uom_control  -- INVCONV
	-- OPM 2547940 end


                  Else
                    --for the % discount and lumpsum there is no difference
                    p_line_adj_tbl(j).operand :=  p_Line_Adj_tbl(j).operand_per_pqty;
                  End If;

                  IF NVL(p_line_tbl(i).ordered_quantity,0) <> 0 AND
                     p_line_tbl(i).ordered_quantity <> FND_API.G_MISS_NUM THEN

                      IF (    p_line_adj_tbl(j).modifier_level_code = 'ORDER'
                          and p_line_adj_tbl(j).list_line_type_code = 'FREIGHT_CHARGE'
                          and p_line_adj_tbl(j).arithmetic_operator = 'LUMPSUM') THEN    /* bug 1915846 */

                        p_line_adj_tbl(j).adjusted_amount := p_line_adj_tbl(j).adjusted_amount_per_pqty;

                      ELSE   /* bug 1915846 */
                       If  p_Line_Adj_Tbl(j).line_id =  p_line_tbl(i).line_id Then
                        p_Line_Adj_Tbl(j).adjusted_amount := p_Line_Adj_tbl(j).adjusted_amount_per_pqty * p_line_tbl(i).pricing_quantity/p_line_tbl(i).ordered_quantity;

                      -- OPM 2547940  start - if pricing by quantity2 then if line is shipped and has shipped qty2 != ordered qty2
     --  need to adjust the adjusted_amount so that invoicing will show correct amount (ordered qty * USP (adjusted) )

                        IF oe_line_util.dual_uom_control  -- INVCONV  PROCESS_CHAR

              		(p_line_tbl(i).inventory_item_id
              		,p_line_tbl(i).ship_from_org_id
              		,l_item_rec) THEN
                   		IF l_item_rec.ont_pricing_qty_source = 'S'   THEN -- price by quantity 2 -- INVCONV

   				  	IF (p_line_tbl(i).ordered_quantity2 IS NOT NULL and p_line_tbl(i).ordered_quantity2 <> 0	)
                        		AND ( p_line_tbl(i).shipped_quantity2 IS NOT NULL and p_line_tbl(i).shipped_quantity2 <> 0	)
                        		 AND p_line_tbl(i).ordered_quantity2 <> p_line_tbl(i).shipped_quantity2 THEN
			                   oe_debug_pub.add('OPM Updating adjusted amount ' ,5);
                       		     p_Line_Adj_Tbl(j).adjusted_amount := (p_Line_Adj_tbl(j).adjusted_amount_per_pqty* p_line_tbl(i).pricing_quantity )/p_line_tbl(i).ordered_quantity2
                       		      * (p_line_tbl(i).shipped_quantity2/p_line_tbl(i).ordered_quantity);
                       		   	END IF;
               			END IF;
		        END IF;  --oe_line_util.dual_uom_control -- INVCONV
    -- OPM 2547940 end


                        If G_DEBUG Then
                         oe_debug_pub.add(' p_line_tbl(i).line_id:'||i||' '||p_line_tbl(i).line_id);
                         oe_debug_pub.add(' p_line_tbl(i).pricing_quantity:'||i||': '||p_line_tbl(i).pricing_quantity);
                         oe_debug_pub.add(' p_line_tbl(i).ordered_quantity:'||i||': '||p_line_tbl(i).ordered_quantity);
                         oe_debug_pub.add(' p_Line_Adj_Tbl(j).adjusted_amount:'||j||': '|| p_Line_Adj_Tbl(j).adjusted_amount);
                         oe_debug_pub.add(' p_line_adj_tbl(j).list_line_id:'||j||': '||p_line_adj_tbl(j).list_line_id);
                         oe_debug_pub.add(' p_line_adj_tbl(j).adjusted_amount_per_pqty:'||p_line_adj_tbl(j).adjusted_amount_per_pqty);
                        End If;
                       End If;

                      END IF;


                  END IF;
                  -- uom end
                       IF nvl(p_line_adj_tbl(j).adjusted_amount_per_pqty,0) <> 0 Then
                              QP_UTIL_PUB.round_price
                              (p_operand                => p_Line_Adj_Tbl(j).adjusted_amount_per_pqty,
			       p_rounding_factor        => NULL,
			       p_use_multi_currency     => 'Y',
			       p_price_list_id          => p_line_tbl(i).price_list_id,
			       p_currency_code          => g_order_currency,
			       p_pricing_effective_date => p_line_tbl(i).pricing_date,
			       x_rounded_operand        => p_Line_Adj_Tbl(j).adjusted_amount_per_pqty,
			       x_status_code            => l_status_code,
                               p_operand_type           => 'A'
                               );

                        END If;

                        IF nvl(p_line_adj_tbl(j).adjusted_amount,0) <> 0 Then
                              QP_UTIL_PUB.round_price
                              (p_operand                => p_Line_Adj_Tbl(j).adjusted_amount,
			       p_rounding_factor        => NULL,
			       p_use_multi_currency     => 'Y',
			       p_price_list_id          => p_line_tbl(i).price_list_id,
			       p_currency_code          => g_order_currency,
			       p_pricing_effective_date => p_line_tbl(i).pricing_date,
			       x_rounded_operand        => p_Line_Adj_Tbl(j).adjusted_amount,
			       x_status_code            => l_status_code,
                               p_operand_type           => 'A'
                               );

                        END If;

		End Loop; -- Adj Lines

		G_STMT_NO := 'Calculate_Price#200';
		-- Do GSA Check

		If l_gsa_enabled_flag = 'Y' Then
	-- for bug 1717501 begin
        --Added condition to check item type code for bug 2693025
          l_gsa_cust_check := oe_gsa_util.check_gsa_indicator(p_line_tbl(i));
	     if l_gsa_cust_check = 'N'
             and p_line_tbl(i).item_type_code not in ('INCLUDED','CONFIG')
             then
		Gsa_Check(
                p_header_id             => p_line_tbl(i).header_id
		,p_line_id		=> p_line_tbl(i).line_id
		,p_inventory_item_id 	=> to_char(p_line_tbl(i).inventory_item_id) --bug 2673506
		,p_pricing_date		=> p_line_tbl(i).pricing_date
		,p_request_type_code	=> p_request_type_code
,p_unit_selling_price_per_pqty	=> p_line_tbl(i).unit_selling_price_per_pqty
		,p_gsa_violation_action	=> l_gsa_violation_action
                ,p_price_event1 => p_price_event       --bug 2273446
			);
		 end if;
		End If;

		-- DO Negative price Check

		If   p_line_tbl(i).unit_selling_price_per_pqty < 0 And
			p_allow_negative_price = 'N' then

		 	adj_debug('Negative list price '||p_line_tbl(i).unit_List_price_per_pqty ||
						'Or selling price '||p_line_tbl(i).Unit_Selling_price_per_pqty);
		 	FND_MESSAGE.SET_NAME('ONT','ONT_NEGATIVE_PRICE');
		 	FND_MESSAGE.SET_TOKEN('ITEM',p_line_tbl(i).Ordered_Item);
		 	FND_MESSAGE.SET_TOKEN('LIST_PRICE',p_line_tbl(i).unit_List_price_per_pqty);
		 	FND_MESSAGE.SET_TOKEN('SELLING_PRICE',p_line_tbl(i).Unit_Selling_price_per_pqty);
		  	OE_MSG_PUB.Add;
                        FND_MESSAGE.SET_NAME('ONT','ONT_NEGATIVE_MODIFIERS');
                        FND_MESSAGE.SET_TOKEN('LIST_LINE_NO',get_list_lines(p_line_tbl(i).line_id));
                        OE_MSG_PUB.ADD;

		 	RAISE FND_API.G_EXC_ERROR;

		End If; -- Negative Price

	 End If ; -- Of lines.operation in update or create
	   adj_debug('selling price after ..'||p_Line_Tbl(i).Unit_Selling_Price_Per_Pqty);
       End If;  --calculate price flag in ('Y','P');
      I := p_Line_Tbl.Next(I);
    End Loop; -- Lines

	adj_debug('Exiting oe_order_Adj_pvt.Calculate_Price');

End Calculate_Price;

Function	Get_unit_precision(p_header_id	number)
return Number
is
l_currency_code 	varchar2(30) := 'USD';
l_precision				Number;
l_ext_precision			number;
l_min_acct_unit				number;
begin
	begin
		select nvl(transactional_curr_code,'USD') into l_currency_code from oe_order_headers
		where header_id=p_header_id;
		exception when no_data_found then
		l_currency_code := 'USD';
	end ;

     FND_CURRENCY.Get_Info(l_currency_code,  -- IN variable
		l_precision,
		l_ext_precision,
		l_min_acct_unit);

	if fnd_profile.value('OE_UNIT_PRICE_PRECISION_TYPE') = 'STANDARD' then
		return l_precision;
	else
		return l_ext_precision;
	end if;

end Get_unit_precision;


/* Bug 1503357
   Order no longer qualifies for PRG modifier.  Either delete (or) update
   the free goods lines, depending on whether they are shipped or not
*/
PROCEDURE change_prg_lines(p_price_adjustment_id IN NUMBER,
			   p_line_tbl            IN OUT NoCopy  OE_Order_PUB.Line_Tbl_Type,
			   p_line_adj_tbl        IN OUT NoCopy  OE_Order_PUB.Line_Adj_Tbl_Type,
			   p_delete_prg_lines    IN OUT NoCopy  index_tbl_type) IS

 Cursor prg_lines is
  Select radj.line_id
  from oe_price_adjustments radj,
  oe_price_adj_assocs assoc
  where radj.price_adjustment_id =assoc.rltd_price_adj_id and
  assoc.price_adjustment_id = p_price_adjustment_id;

 Cursor ph_ids IS
  Select pricing_phase_id
  from qp_event_phases
  where pricing_event_code like 'BOOK';

 l_prg_line_id         NUMBER;
 l_found_prg_line      BOOLEAN;
 l_match_phase_id      BOOLEAN := FALSE;
 l_line_rec            OE_ORDER_PUB.line_rec_type;
 l_phase_id            NUMBER;
 pricing_ph_id         NUMBER;
 j 		       PLS_INTEGER;
 l_return_status       VARCHAR2(30);
 l_replaced	       BOOLEAN := FALSE;
 l_pricing_event       varchar2(30);

Begin
  adj_debug('Entering VADJB.CHANGE_PRG_LINES');
  adj_debug('price_adjustment_id = ' || p_price_adjustment_id);
  begin
   select pricing_phase_id
   into pricing_ph_id
   from oe_price_adjustments
   where price_adjustment_id = p_price_adjustment_id;
   exception when no_data_found Then
      adj_debug('No pricing phase id for this price adjustment');
      pricing_ph_id := NULL;
  end;

  --Determine if modifier is in Book phase
  if (pricing_ph_id is not NULL) Then
   OPEN ph_ids;
   FETCH ph_ids into l_phase_id;
    WHILE ph_ids%FOUND Loop
      if (l_phase_id = pricing_ph_id) Then
        l_match_phase_id := TRUE;
        exit;
      end if;
      FETCH ph_ids into l_phase_id;
    End Loop;
  End if;
  CLOSE ph_ids;

  OPEN prg_lines;
  FETCH prg_lines into l_prg_line_id;
  while prg_lines%FOUND Loop
     adj_debug('PRG Line id = ' || l_prg_line_id);

     IF (l_prg_line_id is not NULL) THEN
       l_found_prg_line := FALSE;
       j := p_line_tbl.first;
       while j is not null Loop
          if (p_line_tbl(j).line_id = l_prg_line_id) Then
	    adj_debug('found prg line '||l_prg_line_id);
            l_line_rec := p_line_tbl(j);
	    l_found_prg_line := TRUE;
	    exit;
	  end if;
          j := p_line_tbl.next(j);
       End Loop;
     END IF;

     IF NOT l_found_prg_line then
       adj_debug('PRG not in p_line_tbl, so query for line '||l_prg_line_id);
       OE_Line_Util.Query_Row(p_Line_id   => l_prg_line_id,
                              x_line_rec  => l_line_rec);
     END IF;

     if (l_line_rec.booked_flag <> 'Y' OR
	 l_line_rec.booked_flag is NULL) Then
       adj_debug('Order not booked');
       l_line_rec.operation := OE_GLOBALS.G_OPR_DELETE;
       p_delete_prg_lines(l_line_rec.line_id) := l_line_rec.line_id;
     else
       l_line_rec.change_reason := 'SYSTEM';
       l_line_rec.change_comments := 'REPRICING';
       if (l_line_rec.shipped_quantity is NULL) Then
	 adj_debug('Booked order, line not shipped');
	 l_line_rec.operation := OE_GLOBALS.G_OPR_UPDATE;
  	 l_line_rec.ordered_quantity := 0;
	 l_line_rec.pricing_quantity := 0;
          p_delete_prg_lines(l_line_rec.line_id) := l_line_rec.line_id;
       else
	 adj_debug('Booked order, shipped line');
	 l_line_rec.operation := OE_GLOBALS.G_OPR_UPDATE;
	 l_line_rec.calculate_price_flag := 'Y';
       adj_debug('logging delayed request to price line');
         l_pricing_event := 'BATCH'; --2442012
 /*      OE_delayed_requests_Pvt.log_request(
		p_entity_code 		=> OE_GLOBALS.G_ENTITY_ALL,
		p_entity_id         	=> l_line_rec.line_id,
		p_requesting_entity_code => OE_GLOBALS.G_ENTITY_ALL,
		p_requesting_entity_id   => l_line_rec.line_id,
		p_request_unique_key1  	=> 'BATCH',
		p_param1                 => l_line_rec.header_id,
                p_param2                 => 'BATCH',
		p_request_type           => OE_GLOBALS.G_PRICE_LINE,
		x_return_status          => l_return_status);
 */
	if (l_match_phase_id) Then
	  -- modifier in BOOK phase
             l_pricing_event := 'BATCH,BOOK';
        end if;
	  OE_delayed_requests_Pvt.log_request(
                p_entity_code           =>OE_GLOBALS.G_ENTITY_ALL,
                p_entity_id             => l_line_rec.line_Id,
                p_requesting_entity_code => OE_GLOBALS.G_ENTITY_ALL,
                p_requesting_entity_id   => l_line_rec.line_Id,
                p_request_unique_key1   => l_pricing_event,
                p_param1                 => l_line_rec.header_id,
                p_param2                 => l_pricing_event,
                p_request_type           => OE_GLOBALS.G_PRICE_LINE,
                x_return_status          => l_return_status);
   --2442012     end if;
       end if;
      end if;

      -- Now replace/append this record in p_line_tbl
      if (l_found_prg_line) Then
	adj_debug('Replacing line in p_line_tbl ' || l_line_rec.line_id);
	p_line_tbl(j) := l_line_rec;
      else
        adj_debug('Appended to p_line_tbl ' || l_line_rec.line_id);
        p_line_tbl(p_line_tbl.last+1) := l_line_rec;
      end if;

      FETCH prg_lines into l_prg_line_id;
  End Loop;

  CLOSE prg_lines;
  adj_debug('Exiting VADJB.CHANGE_PRG_LINES');

End change_prg_lines;



procedure process_adjustments
(
p_request_type_code				varchar2,
x_return_status out nocopy Varchar2,

p_Req_Control_Rec			   QP_PREQ_GRP.Control_record_type,
p_req_line_tbl                   QP_PREQ_GRP.line_tbl_type,
p_Req_qual_tbl                   QP_PREQ_GRP.qual_tbl_type,
p_Req_line_attr_tbl              QP_PREQ_GRP.line_attr_tbl_type,
p_Req_Line_Detail_tbl            QP_PREQ_GRP.line_detail_tbl_type,
p_Req_Line_Detail_Qual_tbl       QP_PREQ_GRP.line_detail_qual_tbl_type,
p_Req_Line_Detail_Attr_tbl       QP_PREQ_GRP.line_detail_attr_tbl_type,
p_Req_related_lines_tbl          QP_PREQ_GRP.related_lines_tbl_type
,p_write_to_db					Boolean
,p_any_frozen_line              in              Boolean
,x_line_Tbl			in out nocopy     oe_Order_Pub.Line_Tbl_Type
,p_header_rec				   oe_Order_Pub.header_rec_type
,p_multiple_events  in Varchar2 Default 'N'
,p_honor_price_flag  in Varchar2 Default 'Y'   --bug 2503186
)
is
l_Req_Line_Detail_qual_Rec      QP_PREQ_GRP.line_detail_qual_rec_type;
l_Req_Line_Detail_attr_Rec       QP_PREQ_GRP.line_detail_attr_rec_type;
l_req_line_rec				qp_preq_grp.line_rec_type;
l_control_rec				Oe_Globals.Control_rec_type;
l_header_rec				   oe_Order_Pub.header_rec_type := p_header_rec;
--l_old_line_rec				oe_order_pub.line_rec_type;
l_line_rec				oe_order_pub.line_rec_type;
l_old_line_tbl                OE_Order_PUB.Line_Tbl_Type;
l_line_tbl                    OE_Order_PUB.Line_Tbl_Type;
l_line_tbl_Final              OE_Order_PUB.Line_Tbl_Type;
l_Line_Adj_rec                OE_Order_PUB.Line_Adj_Rec_Type;
l_Line_Adj_tbl                OE_Order_PUB.Line_Adj_Tbl_Type;
l_Line_Adj_Att_Rec  		OE_Order_PUB.Line_Adj_Att_Rec_type;
l_Line_Adj_Att_tbl  		OE_Order_PUB.Line_Adj_Att_tbl_type;
l_Line_Adj_Assoc_Rec    		OE_Order_PUB.Line_Adj_Assoc_Rec_type;
l_Line_Adj_Assoc_tbl    		OE_Order_PUB.Line_Adj_Assoc_tbl_type;
--l_x_header_rec                OE_Order_PUB.Header_Rec_Type;
l_x_Header_Adj_tbl            OE_Order_PUB.Header_Adj_Tbl_Type;
l_x_Header_Scredit_tbl        OE_Order_PUB.Header_Scredit_Tbl_Type;
--l_x_line_tbl                  OE_Order_PUB.Line_Tbl_Type;
--l_x_Line_Adj_tbl              OE_Order_PUB.Line_Adj_Tbl_Type;
l_x_Line_Scredit_tbl          OE_Order_PUB.Line_Scredit_Tbl_Type;
l_x_action_request_tbl        OE_Order_PUB.request_tbl_type;
l_x_lot_serial_tbl	      	OE_Order_PUB.lot_serial_tbl_type;
l_x_Header_price_Att_tbl 	OE_Order_PUB.Header_price_Att_tbl_type;
l_x_Header_Adj_Att_tbl 		OE_Order_PUB.Header_Adj_Att_tbl_type;
l_x_Header_Adj_Assoc_tbl	    	OE_Order_PUB.Header_Adj_Assoc_tbl_type;
l_x_Line_price_Att_tbl		OE_Order_PUB.Line_price_Att_tbl_type;
--l_x_Line_Adj_Att_tbl  		OE_Order_PUB.Line_Adj_Att_tbl_type;
--l_x_Line_Adj_Assoc_tbl    	OE_Order_PUB.Line_Adj_Assoc_tbl_type;
l_x_msg_count                   number;
l_x_msg_data                    Varchar2(2000);
l_x_result_out                 Varchar2(30);
l_line_details_prcd			Index_Tbl_Type;
l_Rltd_lines_prcd			Index_Tbl_Type;
l_Rltd_line_details_prcd		Index_Tbl_Type;
l_lines_prcd				Index_Tbl_Type;
l_index					pls_Integer;
l_Adj_index				pls_Integer;
l_assoc_index				pls_Integer;
i						pls_Integer;
j						pls_Integer;
k						pls_Integer;
l                                               pls_Integer;
l_line_term				Boolean := FALSE;
l_price_list				Varchar2(240);
l_price_adjustment_id		number;
l_allow_negative_price		Varchar2(30) := nvl(fnd_profile.value('ONT_NEGATIVE_PRICING'),'N');
l_return_status			varchar2(30);
l_index                         NUMBER;
l_request_id                    NUMBER;
--btea perf begin
l_header_key_tbl key_tbl_type;
l_line_key_tbl   key_tbl_type;
--btea perf end
l_updated_flag varchar2(1);
-- Added by JAUTOMO on 20-DEC-00 (bug# 1303352)
v_discounting_privilege VARCHAR2(30);
-- Added by JAUTOMO on 10-APR-01
l_item_type_code		VARCHAR2(30);
v_order_enforce_list_price varchar2(1):=NULL;
v_line_enforce_list_price varchar2(1);
l_invalid_line Varchar2(1):= 'N';
--Manual begin
l_preinsert_manual_adj  VARCHAR2(1):= Nvl(Fnd_Profile.Value('ONT_PREINSERT_MANUAL_ADJ'),'N');
--Manual end
l_dummy_line_rec Oe_Order_Pub.Line_Rec_Type;
l_limit_hold_action varchar2(30):=NVL(fnd_profile.value('ONT_PROMOTION_LIMIT_VIOLATION_ACTION'), 'NO_HOLD'); -- PROMOTIONS SEP/01

/* Promotional modifier issues - Bug 1503357 */
l_delete_prg_lines   index_tbl_type;
l_num_changed_lines PLS_INTEGER := 0;

l_status_code Varchar2(5);
l_line_detail_replaced                        Index_Tbl_Type;

l_item_rec                    OE_ORDER_CACHE.item_rec_type; -- OPM 2547940
l_process			Boolean; -- OPM 2547940

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
l_order_source_id           NUMBER;
l_orig_sys_document_ref     VARCHAR2(50);
l_orig_sys_line_ref     VARCHAR2(50);
l_orig_sys_shipment_ref     VARCHAR2(50);
l_change_sequence           VARCHAR2(50);
l_source_document_type_id   NUMBER;
l_source_document_id        NUMBER;
l_source_document_line_id        NUMBER;

rec_cnt NUMBER := 0;
--serla begin
l_x_Header_Payment_tbl        OE_Order_PUB.Header_Payment_Tbl_Type;
l_x_Line_Payment_tbl          OE_Order_PUB.Line_Payment_Tbl_Type;
--serla end
begin

x_return_status :=  FND_API.G_RET_STS_SUCCESS;
adj_debug('Entering oe_order_Adj_pvt.process_adjustments',1);
G_STMT_NO := 'process_adjustments#10';

i:=  p_req_line_tbl.first;
While I is not null Loop

      If x_Line_Tbl.count = 0 Then
      Begin

         OE_Line_Util.Query_Row
	 (   p_Line_id             => p_req_line_tbl(i).line_id
         ,   x_line_rec            => l_line_rec);
	Exception when no_data_found then
        null;
	adj_debug('process_adjustments OE_Line_Util.Query_Row , no data found');
      End;
	 Else
		J:= x_Line_Tbl.First;
		While J is not null loop
			If x_Line_Tbl(j).line_id = p_req_line_tbl(i).line_id or
				J = p_req_line_tbl(i).line_index then
					l_line_rec := x_Line_Tbl(J);
					exit;
			End if;
			J:= x_Line_Tbl.next(j);
		end loop;
	End If;
	adj_debug('The status code '||p_req_line_tbl(i).status_code);
        l_invalid_line := 'N';
	if p_req_line_tbl(i).line_Type_code ='LINE' and
  	  p_req_line_tbl(i).status_code in ( QP_PREQ_GRP.G_STATUS_INVALID_PRICE_LIST,
				QP_PREQ_GRP.G_STS_LHS_NOT_FOUND,
				QP_PREQ_GRP.G_STATUS_FORMULA_ERROR,
				QP_PREQ_GRP.G_STATUS_OTHER_ERRORS,
				FND_API.G_RET_STS_UNEXP_ERROR,
				FND_API.G_RET_STS_ERROR,
				QP_PREQ_GRP.G_STATUS_CALC_ERROR,
				QP_PREQ_GRP.G_STATUS_UOM_FAILURE,
				QP_PREQ_GRP.G_STATUS_INVALID_UOM,
				QP_PREQ_GRP.G_STATUS_DUP_PRICE_LIST,
				QP_PREQ_GRP.G_STATUS_INVALID_UOM_CONV,
				QP_PREQ_GRP.G_STATUS_INVALID_INCOMP,
				QP_PREQ_GRP.G_STATUS_BEST_PRICE_EVAL_ERROR)
	then
                   OE_MSG_PUB.set_msg_context
      			( p_entity_code                => 'LINE'
         		,p_entity_id                   => l_line_rec.line_id
         		,p_header_id                   => l_line_rec.header_id
         		,p_line_id                     => l_line_rec.line_id
                        ,p_order_source_id             => l_line_rec.order_source_id
                        ,p_orig_sys_document_ref       => l_line_rec.orig_sys_document_ref
                        ,p_orig_sys_document_line_ref  => l_line_rec.orig_sys_line_ref
                        ,p_orig_sys_shipment_ref       => l_line_rec.orig_sys_shipment_ref
                        ,p_change_sequence             => l_line_rec.change_sequence
                        ,p_source_document_type_id     => l_line_rec.source_document_type_id
                        ,p_source_document_id          => l_line_rec.source_document_id
                        ,p_source_document_line_id     => l_line_rec.source_document_line_id
         		);

                 l_invalid_line := 'Y';
		 Begin
			Select name into l_price_list
			from qp_list_headers_vl where
			list_header_id = l_line_rec.price_list_id;
			Exception When No_data_found then
			l_price_list := l_line_rec.price_list_id;
		 End;

		 If p_req_line_tbl(i).status_code  = QP_PREQ_GRP.G_STATUS_INVALID_PRICE_LIST then
		 	adj_debug('Invalid Item/Price List combination');
                        If not G_IPL_ERRORS_TBL.exists(MOD(l_line_rec.line_id, G_BINARY_LIMIT))                    -- Bug 8631297
                         or (G_IPL_ERRORS_TBL.exists(MOD(l_line_rec.line_id, G_BINARY_LIMIT))                      -- Bug 8631297
                             and
                             G_IPL_ERRORS_TBL(MOD(l_line_rec.line_id,G_BINARY_LIMIT))<>l_line_rec.price_list_id)   -- Bug 8631297
                        Then
		 	  FND_MESSAGE.SET_NAME('ONT','OE_PRC_NO_LIST_PRICE');
		 	  FND_MESSAGE.SET_TOKEN('ITEM',l_line_rec.Ordered_Item);
		 	  FND_MESSAGE.SET_TOKEN('UNIT',l_line_rec.Order_Quantity_uom);
		 	  FND_MESSAGE.SET_TOKEN('PRICE_LIST',l_Price_List);
		  	  OE_MSG_PUB.Add;
                        End If;

                        G_IPL_ERRORS_TBL(MOD(l_line_rec.line_id,G_BINARY_LIMIT)):=l_line_rec.price_list_id;       -- Bug 8631297
                         oe_debug_pub.add('Before checking book flag');
                         oe_debug_pub.add('Invalid line flag:'||l_invalid_line);

                        If nvl(l_line_rec.booked_flag,'X') = 'Y' Then
                            oe_debug_pub.add(' Before setting message');
                            FND_MESSAGE.SET_NAME('ONT','OE_BOOK_REQD_LINE_ATTRIBUTE');
                            oe_debug_pub.add(' Before setting token');
                            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','price list');
     	                    OE_MSG_PUB.ADD;
                            oe_debug_pub.add('Process adjustments before raising g_exc_error');
                            RAISE FND_API.G_EXC_ERROR;
                        End If;

                        --Fix bug 1650637
                        --If l_line_rec.unit_selling_price Is Not Null or
                        --l_line_rec.unit_list_price Is Not Null  Then
                        /*  Begin
                            Update Oe_Order_Lines
                            set    Unit_Selling_Price = Null,Unit_list_price = Null
                            where  line_id = l_line_rec.line_id;

                            oe_line_adj_util.delete_row(p_line_id => l_line_rec.line_id);
                            oe_debug_pub.add('  Updating unit price to null');

                            l_line_rec.unit_selling_price := NULL;
                            l_line_rec.unit_list_price:=NULL;
                            l_line_rec.unit_selling_price_per_pqty :=NULL;
                            l_line_rec.unit_list_price_per_pqty:=NULL;
                           Exception When Others Then
                            Oe_Debug_Pub.add('Oe_Order_Adj_Pvt:Failed to update price:'||SQLERRM);
                           End;*/
                        --End If;

                            l_line_rec.unit_selling_price := NULL;
                            l_line_rec.unit_list_price:=NULL;
                            l_line_rec.unit_selling_price_per_pqty :=NULL;
                            l_line_rec.unit_list_price_per_pqty:=NULL;

		Elsif p_req_line_tbl(i).status_code = QP_PREQ_GRP.G_STS_LHS_NOT_FOUND Then
		 	adj_debug('Price List Not found');
		 	FND_MESSAGE.SET_NAME('ONT','ONT_NO_PRICE_LIST_FOUND');
		 	FND_MESSAGE.SET_TOKEN('ITEM',l_line_rec.Ordered_Item);
		 	FND_MESSAGE.SET_TOKEN('UOM',l_line_rec.Order_Quantity_uom);
		  	OE_MSG_PUB.Add;
		Elsif p_req_line_tbl(i).status_code = QP_PREQ_GRP.G_STATUS_FORMULA_ERROR then
		 	adj_debug('Error in Formula processing');
		 	FND_MESSAGE.SET_NAME('ONT','ONT_PRC_ERROR_IN_FORMULA');
		 	FND_MESSAGE.SET_TOKEN('ERR_TEXT',p_req_line_tbl(i).status_text||SQLERRM);
		  	OE_MSG_PUB.Add;
		Elsif p_req_line_tbl(i).status_code in
				( QP_PREQ_GRP.G_STATUS_OTHER_ERRORS , FND_API.G_RET_STS_UNEXP_ERROR,
						FND_API.G_RET_STS_ERROR)
		then
		 	adj_debug('Other errors processing');
		 	FND_MESSAGE.SET_NAME('ONT','ONT_PRICING_ERRORS'); --bug#7149497
		 	FND_MESSAGE.SET_TOKEN('ERR_TEXT',p_req_line_tbl(i).status_text||SQLERRM);
		  	OE_MSG_PUB.Add;
		Elsif p_req_line_tbl(i).status_code = QP_PREQ_GRP.G_STATUS_INVALID_UOM then
		 	adj_debug('Invalid uom');
		 	FND_MESSAGE.SET_NAME('ONT','ONT_PRC_INVALID_UOM');
		 	FND_MESSAGE.SET_TOKEN('ITEM',l_line_rec.Ordered_Item);
		 	FND_MESSAGE.SET_TOKEN('UOM',l_line_rec.Order_Quantity_uom);
		  	OE_MSG_PUB.Add;
		Elsif p_req_line_tbl(i).status_code = QP_PREQ_GRP.G_STATUS_DUP_PRICE_LIST then
		 	adj_debug('Duplicate price list');
		 	FND_MESSAGE.SET_NAME('ONT','ONT_PRC_DUPLICATE_PRICE_LIST');

		 	Begin
				Select name into l_price_list
				from qp_list_headers_vl a,qp_list_lines b where
				b.list_line_id =  to_number(substr(p_req_line_tbl(i).status_text,1,
									instr(p_req_line_tbl(i).status_text,',')-1))
				and a.list_header_id=b.list_header_id
				;
				Exception When No_data_found then
				l_price_list := to_number(substr(p_req_line_tbl(i).status_text,1,
								instr(p_req_line_tbl(i).status_text,',')-1));
				When invalid_number then
				l_price_list := substr(p_req_line_tbl(i).status_text,1,
								instr(p_req_line_tbl(i).status_text,',')-1);

		 	End;

		 	FND_MESSAGE.SET_TOKEN('PRICE_LIST1','( '||l_line_rec.Ordered_Item||' ) '||
																	l_price_list);
		 	Begin
				Select name into l_price_list
				from qp_list_headers_vl a,qp_list_lines b where
				b.list_line_id =  to_number(substr(p_req_line_tbl(i).status_text,
									instr(p_req_line_tbl(i).status_text,',')+1))
				and a.list_header_id=b.list_header_id	;
				Exception When No_data_found then
				l_price_list := to_number(substr(p_req_line_tbl(i).status_text,
								instr(p_req_line_tbl(i).status_text,',')+1));
				When invalid_number then
				l_price_list := substr(p_req_line_tbl(i).status_text,
								instr(p_req_line_tbl(i).status_text,',')+1);

		 	End;
		 	FND_MESSAGE.SET_TOKEN('PRICE_LIST2',l_price_list);
		  	OE_MSG_PUB.Add;
		Elsif p_req_line_tbl(i).status_code = QP_PREQ_GRP.G_STATUS_INVALID_UOM_CONV then
		 	adj_debug('Invalid UOM Conversion');
		 	FND_MESSAGE.SET_NAME('ONT','ONT_PRC_INVALID_UOM_CONVERSION');
		 	FND_MESSAGE.SET_TOKEN('UOM_TEXT','( '||l_line_rec.Ordered_Item||' ) '||
													p_req_line_tbl(i).status_text);
		  	OE_MSG_PUB.Add;
		Elsif p_req_line_tbl(i).status_code = QP_PREQ_GRP.G_STATUS_INVALID_INCOMP then
		 	adj_debug('Unable to resolve incompatibility');
		 	FND_MESSAGE.SET_NAME('ONT','ONT_PRC_INVALID_INCOMP');
		 	FND_MESSAGE.SET_TOKEN('ERR_TEXT','( '||l_line_rec.Ordered_Item||' ) '||
												p_req_line_tbl(i).status_text);
		  	OE_MSG_PUB.Add;
		Elsif p_req_line_tbl(i).status_code = QP_PREQ_GRP.G_STATUS_BEST_PRICE_EVAL_ERROR then
		 	adj_debug('Error while evaluating the best price');
		 	FND_MESSAGE.SET_NAME('ONT','ONT_PRC_BEST_PRICE_ERROR');
		 	FND_MESSAGE.SET_TOKEN('ITEM',l_line_rec.Ordered_Item);
		 	FND_MESSAGE.SET_TOKEN('ERR_TEXT',p_req_line_tbl(i).status_text);
		  	OE_MSG_PUB.Add;
		End if;

		 --RAISE FND_API.G_EXC_ERROR;
                 --btea begin if do not write to db, we still need to
                 --return line and status code to the caller
                 If Not p_write_to_db Then
                   l_line_rec.Header_id := p_header_rec.Header_id;
                   l_line_rec.line_id := p_req_line_tbl(i).line_id;
                   -- uom begin
                   l_line_rec.unit_selling_price_per_pqty := p_req_line_tbl(i).adjusted_unit_price ;
                   l_line_rec.unit_list_price_per_pqty := p_req_line_tbl(i).unit_price ;
                   -- uom end
                   l_line_rec.pricing_quantity := p_req_line_tbl(i).priced_quantity ;
                   l_line_rec.pricing_quantity_uom := p_req_line_tbl(i).priced_uom_code ;
                   l_line_rec.price_request_code := p_req_line_tbl(i).price_request_code; -- PROMOTIONS SEP/01
                 --use industry_attribute30 as the place holder to hold error status
                 --since the line_rec doesn't have the place holder to hold error status
                   l_line_rec.industry_attribute30 := p_req_line_tbl(i).status_code;
                   l_line_tbl(i) := l_line_rec;
                 End If;
                 --btea end

	elsif ( p_req_line_tbl(i).unit_price < 0 or p_req_line_tbl(i).Adjusted_unit_price < 0) and l_allow_negative_price = 'N' then

		 adj_debug('Negative list price '||p_req_line_tbl(i).unit_price ||'Or selling price '||p_req_line_tbl(i).Adjusted_unit_price);
		 FND_MESSAGE.SET_NAME('ONT','ONT_NEGATIVE_PRICE');
		 FND_MESSAGE.SET_TOKEN('ITEM',l_line_rec.Ordered_Item);
		 FND_MESSAGE.SET_TOKEN('LIST_PRICE',p_req_line_tbl(i).unit_price);
		 FND_MESSAGE.SET_TOKEN('SELLING_PRICE',p_req_line_tbl(i).Adjusted_unit_price);
		 OE_MSG_PUB.Add;
                 FND_MESSAGE.SET_NAME('ONT','ONT_NEGATIVE_MODIFIERS');
                 FND_MESSAGE.SET_TOKEN('LIST_LINE_NO',get_list_lines(p_req_line_tbl(i).line_id));
                 OE_MSG_PUB.Add;

		 RAISE FND_API.G_EXC_ERROR;
	elsif
	   p_req_line_tbl(i).line_Type_code ='LINE' and
	   p_req_line_tbl(i).status_code = QP_PREQ_GRP.G_STATUS_OTHER_ERRORS
	Then

		  	FND_MESSAGE.SET_NAME('ONT','OE_PRICING_ERROR');
		  	FND_MESSAGE.SET_TOKEN('ERR_TEXT','( '||l_line_rec.Ordered_Item||' ) '||
													p_req_line_tbl(i).STATUS_TEXT);
		  	OE_MSG_PUB.Add;

	elsif
	   ( p_req_line_tbl(i).line_Type_code ='LINE' and
	   p_req_line_tbl(i).status_code in
				( QP_PREQ_GRP.G_STATUS_UPDATED,
                                  QP_PREQ_GRP.G_STATUS_GSA_VIOLATION,
                                  QP_PREQ_GRP.G_STATUS_UNCHANGED) and
	   nvl(p_req_line_tbl(i).processed_code,'0') <> QP_PREQ_GRP.G_BY_ENGINE
	   and p_req_line_tbl(i).price_flag IN ('Y','P') )

	   or  -- OPM 2547940 start
	       -- pricing by quantity2 - this is for case when order line is split from shipping and new line gets generated
	       -- and this line has to be re-priced for catchweight pricing for OPM if pricing in secondary quantity
	   ( ( oe_line_util.dual_uom_control -- INVCONV
              (l_line_rec.inventory_item_id
              ,l_line_rec.ship_from_org_id
              ,l_item_rec) )
                   and  p_req_line_tbl(i).line_Type_code ='LINE'
                   and  (l_item_rec.ont_pricing_qty_source = 'S' ) -- price by quantity 2 -- INVCONV
                   and  ( p_req_line_tbl(i).price_flag In ('N','P') )
		   and ( l_line_rec.split_by is not null )
		   and ( l_line_rec.split_from_line_id is not null and l_line_rec.split_from_line_id <> FND_API.G_MISS_NUM) )
                 -- OPM 2547940 end

           --we do not want to go in this loop if price_flag is set up 'N' because
           --engine doesn't look at the line and will not return adjustments. In this
           --case we DON't want to remove the adjustments that engine doesn't return.
	then

	 G_STMT_NO := 'process_adjustments11.5';
      l_invalid_line := 'N';
      l_line_rec.Header_id := p_header_rec.Header_id;
      l_line_rec.line_id := p_req_line_tbl(i).line_id;
      -- uom begin
      l_line_rec.unit_selling_price_per_pqty := p_req_line_tbl(i).adjusted_unit_price ;
      l_line_rec.unit_list_price_per_pqty := p_req_line_tbl(i).unit_price ;
      -- uom end

      If l_line_rec.item_type_code in ('INCLUDED', 'CONFIG') Then
        l_line_rec.pricing_quantity := l_line_rec.ordered_quantity;
        l_line_rec.pricing_quantity_uom := l_line_rec.order_quantity_uom;
      Else
        l_line_rec.pricing_quantity := p_req_line_tbl(i).priced_quantity ;
        l_line_rec.pricing_quantity_uom := p_req_line_tbl(i).priced_uom_code ;
      End If;

      l_line_rec.price_request_code := p_req_line_tbl(i).price_request_code; -- PROMOTIONS SEP/01

	 -- Handle the percent Price

	If nvl(p_req_line_tbl(i).Percent_Price,0) <> 0 and
			p_req_line_tbl(i).Percent_Price <> fnd_api.g_miss_num then

		l_line_rec.unit_list_percent  := p_req_line_tbl(i).Percent_Price ;
		l_line_rec.unit_percent_base_price := p_req_line_tbl(i).Parent_price;
                -- For bug 1367793, avoid dividing by zero

                If nvl(l_line_rec.unit_percent_base_price, 0) <> 0 Then
  		  l_line_rec.unit_selling_percent  :=
			l_line_rec.Unit_Selling_Price_Per_Pqty * 100 / l_line_rec.unit_percent_base_price;
                Else
                        l_line_rec.unit_selling_percent := 0;
                End If;

	end if;


	 -- Query the adjustment Lines for this line

		G_STMT_NO := 'process_adjustments#30';
           --adj_debug('BCT+***L line id: '||p_req_line_tbl(i).line_id);
	   Append_Adjustment_Lines(p_line_id => l_line_rec.line_id,
				p_pricing_event    => p_Req_Control_Rec.Pricing_Event,
				p_price_flag		=> p_req_line_tbl(i).price_flag,
                                p_any_frozen_line  	=> p_any_frozen_line,
				px_Line_Adj_Tbl => l_line_adj_Tbl,
                                px_line_key_tbl    => l_line_key_tbl,
                                px_header_key_tbl  => l_header_key_tbl,
                                p_mode             =>  'L',
                                px_line_rec        => l_line_rec,
                                px_line_adj_assoc_tbl => l_line_adj_assoc_tbl,
                                x_updated_flag => l_updated_flag,
                                p_multiple_events => p_multiple_events);

	-- Using the same index as that in p_req_line_tbl although there is going to be holes.

      --l_line_tbl(l_line_tbl.count+1) := l_line_rec;
      --l_old_line_tbl(l_line_tbl.count) := l_old_line_rec;
      adj_debug('Setting l_line_tbl...'||l_line_tbl.count||' '||i||' '||l_line_rec.line_id);
      l_line_tbl(i) := l_line_rec;
      --l_old_line_tbl(i) := l_old_line_rec;

	Elsif  -- Process header level adjustments
		 p_req_line_tbl(i).line_type_code ='ORDER' and
		(p_req_line_tbl(i).status_code in ( QP_PREQ_GRP.G_STATUS_UPDATED ,
					QP_PREQ_GRP.G_STATUS_GSA_VIOLATION)
                 --btea
                 --In this case even engine doesn't update the order (status = UNCHANGED)
                 --because of one of the lined is frozen,
                 --there can be some order level adjustments in database which
                 --need to be pulled out by append_adjustment_lines routine
                 or (p_req_line_tbl(i).status_code = QP_PREQ_GRP.G_STATUS_UNCHANGED
--                     and p_any_frozen_line = TRUE -- bug 1675449
				 ))
	Then
		G_STMT_NO := 'Process_Adjustments#35';
                --adj_debug('BCT'||G_STMT_NO);
                --adj_debug('BCT+***H line id: '||p_req_line_tbl(i).line_id);

                IF (l_header_rec.price_request_code IS NULL OR   		-- PROMOTIONS SEP/01
                    l_header_rec.price_request_code = FND_API.G_MISS_CHAR) THEN
                   l_header_rec.price_request_code := p_req_line_tbl(i).price_request_code;
                   l_header_rec.operation := OE_GLOBALS.G_OPR_UPDATE;
                END IF;

	 	append_Adjustment_Lines(p_header_id => p_req_line_tbl(i).line_id,
					-- line_id contains header_id for line_type_code='ORDER'
				p_pricing_event	=> p_Req_Control_Rec.Pricing_Event,
				p_price_flag		=> p_req_line_tbl(i).price_flag,
                                p_any_frozen_line  	=> p_any_frozen_line,
				px_Line_Adj_Tbl 	=> l_line_adj_Tbl,
                                px_line_key_tbl    => l_line_key_tbl,
                                px_header_key_tbl  => l_header_key_tbl,
                                p_mode             => 'H',
                                px_line_rec        => l_dummy_line_rec,
                                px_line_adj_assoc_tbl => l_line_adj_assoc_tbl,
                                x_updated_flag     => l_updated_flag,
                                p_multiple_events  => p_multiple_events);

     End If;-- Status_Code

        oe_debug_pub.add('Before Reset_fields');
     If l_invalid_line = 'Y' Then
        select oe_msg_request_id_s.nextval into l_request_id from dual;
        OE_MSG_PUB.INSERT_MESSAGE(OE_MSG_PUB.COUNT_MSG, l_request_id,'U');
        Reset_Fields(l_line_rec);
        l_invalid_line := 'N';
     End If;

     G_STMT_NO := 'Process_Adjustments#36';
      --          adj_debug('PAL PROMOTIONS '||G_STMT_NO);
 	--	adj_debug('PROMOTIONS - status code is ' ||p_req_line_tbl(i).status_code);

     -- Process header level adjustments     -- PROMOTIONS SEP/01 start
      adj_debug('limit profile:'||l_limit_hold_action,3);

        IF (p_req_line_tbl(i).hold_code = QP_PREQ_GRP.G_STATUS_LIMIT_HOLD) or
            p_req_line_tbl(i).hold_code = QP_PREQ_GRP.G_STATUS_LIMIT_ADJUSTED THEN
          IF (l_limit_hold_action = 'NO_HOLD') THEN
            FND_MESSAGE.SET_NAME('ONT','ONT_PROMO_LIMIT_EXCEEDED');
            OE_MSG_PUB.ADD;
        ELSE
	  IF	( p_req_line_tbl(i).line_type_code = 'LINE' )
		Then
		-- adj_debug('PAL PROMOTIONS - putting entity on HOLD - line type code is ' || p_req_line_tbl(i).line_type_code);
	  	Promotion_Put_Hold (p_header_id   => p_header_rec.Header_id,
			      p_line_id     => p_req_line_tbl(i).line_id);
                IF (l_limit_hold_action = 'ORDER_HOLD') THEN
                 Promotion_Put_Hold(p_header_id => p_header_rec.header_id,
                                    p_line_id => NULL);
                END IF;

	  ELSIF  ( p_req_line_tbl(i).line_type_code = 'ORDER' )
	  	Then
		-- adj_debug('PAL PROMOTIONS - putting entity on HOLD - line type code is ' || p_req_line_tbl(i).line_type_code);
	 	Promotion_Put_Hold (p_header_id   => p_req_line_tbl(i).line_id,
			      p_line_id     => NULL) ;

	  END IF; -- ( p_req_line_tbl(i).line_type_code = 'LINE' )
	 END IF;  -- limit violation action
	END IF; -- (p_req_line_tbl(i).hold_code = QP_PREQ_GRP.G_STATUS_LIMIT_HOLD)
        IF p_req_line_tbl(i).line_id IS NOT NULL AND
           p_req_line_tbl(i).line_id <> FND_API.G_MISS_NUM THEN
           BEGIN
               IF l_debug_level  > 0 THEN
                  oe_debug_pub.add('Getting reference data for line_id:'||p_req_line_tbl(i).line_id);
               END IF;
               SELECT order_source_id, orig_sys_document_ref, change_sequence,
               source_document_type_id, source_document_id, orig_sys_line_ref,
               source_document_line_id, orig_sys_shipment_ref
               INTO l_order_source_id, l_orig_sys_document_ref, l_change_sequence,
               l_source_document_type_id, l_source_document_id, l_orig_sys_line_ref,
               l_source_document_line_id, l_orig_sys_shipment_ref
               FROM   OE_ORDER_LINES_ALL
               WHERE  line_id = p_req_line_tbl(i).line_id;
           EXCEPTION
               WHEN NO_DATA_FOUND THEN
                   l_order_source_id := null;
                   l_orig_sys_document_ref := null;
                   l_change_sequence := null;
                   l_source_document_type_id := null;
                   l_source_document_id := null;
                   l_orig_sys_line_ref := null;
                   l_source_document_line_id := null;
                   l_orig_sys_shipment_ref := null;
               WHEN OTHERS THEN
                   l_order_source_id := null;
                   l_orig_sys_document_ref := null;
                   l_change_sequence := null;
                   l_source_document_type_id := null;
                   l_source_document_id := null;
                   l_orig_sys_line_ref := null;
                   l_source_document_line_id := null;
                   l_orig_sys_shipment_ref := null;
           END;
        END IF;

	OE_MSG_PUB.set_msg_context
	        ( p_entity_code                 => 'LINE'
	         ,p_entity_id                   => p_req_line_tbl(i).line_id
	         ,p_header_id                   => p_req_line_tbl(i).header_id
	         ,p_line_id                     => p_req_line_tbl(i).line_id
                 ,p_order_source_id             => l_order_source_id
                 ,p_orig_sys_document_ref       => l_orig_sys_document_ref
                 ,p_orig_sys_document_line_ref  => l_orig_sys_line_ref
                 ,p_orig_sys_shipment_ref       => l_orig_sys_shipment_ref
                 ,p_change_sequence             => l_change_sequence
                 ,p_source_document_type_id     => l_source_document_type_id
                 ,p_source_document_id          => l_source_document_id
                 ,p_source_document_line_id     => l_source_document_line_id);   -- PROMOTIONS MAY/01 end

	i:=  p_req_line_tbl.Next(i);
    end loop; -- Req_line_tbl

	G_STMT_NO := 'process_adjustments#40';

	 J:= p_req_line_detail_Tbl.First;
	 While J is Not null loop
	   if  p_req_line_tbl( p_req_line_detail_Tbl(j).line_index).status_code in (
				QP_PREQ_GRP.G_STATUS_UPDATED ,QP_PREQ_GRP.G_STATUS_GSA_VIOLATION )
			and nvl(p_req_line_tbl( p_req_line_detail_Tbl(j).line_index).processed_code,'0')
			    <> QP_PREQ_GRP.G_BY_ENGINE

                        --only process/insert automatic adjustments, with freight charge as exception
                        and (p_req_line_detail_Tbl(j).automatic_flag = 'Y' or
                             (p_req_line_detail_Tbl(j).automatic_flag = 'N' and (p_req_line_detail_Tbl(j).list_line_type_code = 'FREIGHT_CHARGE' or l_preinsert_manual_adj = 'Y' )))
			and (
				((
                                  ( l_line_tbl.exists( p_req_line_detail_Tbl(j).line_index)
                                    and
				    oe_line_util.Get_Return_Item_Type_Code
                                    (l_line_tbl( p_req_line_detail_Tbl(j).line_index))<> 'INCLUDED'
                                  )
				  Or not l_line_tbl.exists (p_req_line_detail_Tbl(j).line_index )

                                  )
                                  And
                                  G_CHARGES_FOR_INCLUDED_ITEM = 'N'
                                )
                                Or
                                G_CHARGES_FOR_INCLUDED_ITEM = 'Y'
			     )


	   then
                --adj_debug('BCT+Engine returned status fullfilled');
                --adj_debug('BCT+list_line_type_code+'||p_req_line_detail_Tbl(j).list_line_type_code);
		if p_req_line_detail_Tbl(j).created_from_list_type_code = 'PRL' or
		   p_req_line_detail_Tbl(j).created_from_list_type_code = 'AGR' or
		   p_req_line_detail_Tbl(j).list_line_type_code = 'PLL'
		then
			If l_line_tbl.exists( p_req_line_detail_Tbl(j).line_index) then
				l_line_tbl( p_req_line_detail_Tbl(j).line_index).price_list_id :=
						p_req_line_detail_Tbl(j).list_header_id;
			End if;

		else
			G_STMT_NO := 'process_adjustments#50';

		     If p_req_line_tbl( p_req_line_detail_Tbl(j).line_index).line_type_code =  'LINE' Then

                  -- Changes by JAUTOMO on 20-DEC-00 (bug# 1303352)

                  -- Get Discounting Privilege Profile Option value
                  fnd_profile.get('ONT_DISCOUNTING_PRIVILEGE', v_discounting_privilege);

                  IF (v_order_enforce_list_price = 'Y') THEN
                      v_line_enforce_list_price := 'Y';
                  ELSE
                                 enforce_list_price(
                                       p_req_line_tbl(p_req_line_detail_tbl(j).line_index).line_id,
                                       l_line_tbl(p_req_line_detail_tbl(j).line_index).header_id,
                                       l_line_tbl(p_req_line_detail_tbl(j).line_index).line_type_id,
                                       v_order_enforce_list_price,
                                       v_line_enforce_list_price);
                  END IF;

                  adj_debug('2441779 line_id '||p_req_line_detail_tbl(j).line_index||' '||p_req_line_tbl(p_req_line_detail_tbl(j).line_index).line_id);
                  adj_debug('2441779'||l_line_tbl(p_req_line_detail_tbl(j).line_index).line_id);
                  IF      (nvl(v_line_enforce_list_price,'N') <> 'Y'
                           AND p_req_line_detail_Tbl(j).automatic_flag = 'Y')
                           OR
                           p_req_line_detail_tbl(j).list_line_type_code = 'FREIGHT_CHARGE' THEN

			   If p_req_line_detail_Tbl(j).list_line_type_code ='TSN' then
			   	adj_debug('Before Terms-- Line Level');
			   	-- Updated the Terms at Line Level
			   	If p_req_line_detail_Tbl(j).Substitution_Attribute ='QUALIFIER_ATTRIBUTE1' Then
				   	adj_debug('Payment_term updated to '||p_req_line_detail_Tbl(j).Substitution_to);
				   	l_line_tbl( p_req_line_detail_Tbl(j).line_index).payment_term_id :=
							p_req_line_detail_Tbl(j).Substitution_to;
			   	elsIf p_req_line_detail_Tbl(j).Substitution_Attribute ='QUALIFIER_ATTRIBUTE11' Then
				   	adj_debug('shipping_method_code updated to '||p_req_line_detail_Tbl(j).Substitution_to);
				   	l_line_tbl( p_req_line_detail_Tbl(j).line_index).shipping_method_code :=
							p_req_line_detail_Tbl(j).Substitution_to;
			   	elsIf p_req_line_detail_Tbl(j).Substitution_Attribute ='QUALIFIER_ATTRIBUTE10' Then
				   	adj_debug('freight_terms_code updated to '||p_req_line_detail_Tbl(j).Substitution_to);
				   	l_line_tbl( p_req_line_detail_Tbl(j).line_index).freight_terms_code :=
							p_req_line_detail_Tbl(j).Substitution_to;
			   	End If;

			   End If; -- TSN


			-- Check If the List_Header/ Line  Combination Exists
                                l_adj_index := NULL;
				Find_Duplicate_Adj_Lines(
				p_Line_id   	=>
					l_line_tbl( p_req_line_detail_Tbl(j).line_index).line_id,
				p_req_line_detail_Rec =>  p_req_line_detail_Tbl(j),
				px_Line_Adj_Tbl => 	l_line_adj_Tbl,
				x_Adj_Index	=>   l_Adj_Index,
			        p_mode          =>   'L',
                                px_line_key_tbl =>   l_line_key_tbl,
                                px_header_key_tbl => l_header_key_tbl) ;

                          END IF; -- For Unlimited Discouting Privilege
 adj_debug('2441779:'||l_line_tbl(p_req_line_detail_tbl(j).line_index).line_id);

		     Else -- HEader Level

			   If p_req_line_detail_Tbl(j).list_line_type_code ='TSN' then
			   	adj_debug('Before Terms-- Header Level');
			   	-- Updated the Terms at Line Level
			   	If p_req_line_detail_Tbl(j).Substitution_Attribute ='QUALIFIER_ATTRIBUTE1' Then
				   	adj_debug('Payment_term updated to '||p_req_line_detail_Tbl(j).Substitution_to);
				   	l_header_rec.payment_term_id :=  p_req_line_detail_Tbl(j).Substitution_to;
			   	elsIf p_req_line_detail_Tbl(j).Substitution_Attribute ='QUALIFIER_ATTRIBUTE11' Then
				   	adj_debug('shipping_method_code updated to '||p_req_line_detail_Tbl(j).Substitution_to);
				   	l_header_rec.shipping_method_code :=  p_req_line_detail_Tbl(j).Substitution_to;
			   	elsIf p_req_line_detail_Tbl(j).Substitution_Attribute ='QUALIFIER_ATTRIBUTE10' Then
				   	adj_debug('freight_terms_code updated to '||p_req_line_detail_Tbl(j).Substitution_to);
				   	l_header_rec.freight_terms_code :=  p_req_line_detail_Tbl(j).Substitution_to;
			   	End If;

				   	l_header_rec.operation :=  OE_GLOBALS.G_OPR_UPDATE;

			   End If; -- TSN


			-- Check If the List_Header/ header  Combination Exists

				G_STMT_NO := 'process_adjustments#55';
                                l_adj_index:=NULL;
				Find_Duplicate_Adj_Lines(
				p_header_Id 	=>
					 p_req_line_tbl(p_req_line_detail_Tbl(j).line_index).line_id,
							-- line_id hold header_id for 'HEADER'
				p_req_line_detail_Rec =>  p_req_line_detail_Tbl(j),
				px_Line_Adj_Tbl => 	l_line_adj_Tbl,
				x_Adj_Index	=>   l_Adj_Index,
                                p_mode          =>   'H',
                                px_line_key_tbl =>   l_line_key_tbl,
                                px_header_key_tbl => l_header_key_tbl
					) ;

		     End if;  --header_level

                        If nvl(l_adj_index,-1) > 0 Then
			-- Populate the line_details processed table
			l_line_details_prcd(j) := l_Adj_Index;

                        adj_debug('details_prcd: ('||J||')'||l_Adj_Index,2);

			-- Mark Adjustment Attributes and Adjustment Associations to
			-- Delete
			-- Subsequently these rows would be reinstated
			-- Delete is cascaded to children when adjustment is deleted.


			G_STMT_NO := 'process_adjustments#60';

			   Query_Adj_Attribs(
					p_price_adjustment_id=>
					l_line_adj_Tbl(l_Adj_Index).price_adjustment_id,
					p_Adj_Index		=> l_Adj_Index,
					p_Line_Adj_Att_Tbl 	=> l_line_adj_att_tbl);

				G_STMT_NO := 'process_adjustments#70';



			--adj_debug('BCT+operation:'||l_line_adj_Tbl(l_Adj_Index).operation);
			if  l_line_adj_Tbl(l_Adj_Index).operation in ( OE_GLOBALS.G_OPR_CREATE,
							 OE_GLOBALS.G_OPR_UPDATE ) Then
				-- This Record Needs to be processed
		    	  if p_req_line_tbl( p_req_line_detail_Tbl(j).line_index).line_type_code =  'LINE'
			  Then

			   if  p_req_line_detail_Tbl(j).list_line_type_code ='IUE' then
			   -- Do not give item upgrades to config items.
				If l_line_tbl( p_req_line_detail_Tbl(j).line_index).top_model_line_id is null
				or  l_line_tbl( p_req_line_detail_Tbl(j).line_index).top_model_line_id= fnd_api.g_miss_num
				then
				If  -- Allow Item upgrade only if the order is not booked.
				nvl(l_line_tbl( p_req_line_detail_Tbl(j).line_index).booked_flag,'N')
							= 'N'
		          then

			     -- Set the Line Item to the new item

				   Set_item_for_iue(
					px_line_rec   => l_line_tbl( p_req_line_detail_Tbl(j).line_index)
					,p_req_line_detail_rec => p_req_line_detail_Tbl(j)
					);


				Elsif to_char(l_line_tbl( p_req_line_detail_Tbl(j).line_index).Inventory_item_id ) <>
										p_req_line_detail_Tbl(j).RELATED_ITEM_ID Then

		  			FND_MESSAGE.SET_NAME('ONT','ONT_ITEM_UPGRADE_NOT_ALLOWED');
		  			OE_MSG_PUB.Add;
				   adj_debug('Item Upgrade not allowed after booking...');
				   l_line_adj_Tbl(l_Adj_Index).operation := fnd_api.g_miss_char;

				End If; -- Booked_Flag

			   End if ; -- Config item
		 	   end if;	 -- IUE

			   l_line_adj_Tbl(l_Adj_Index).line_id :=
					l_line_tbl( p_req_line_detail_Tbl(j).line_index).line_id;
			   l_line_adj_Tbl(l_Adj_Index).Header_id :=
					l_line_tbl( p_req_line_detail_Tbl(j).line_index).Header_id;
			   l_line_adj_Tbl(l_Adj_Index).Line_index := p_req_line_detail_Tbl(j).line_index;

			 else -- HEADER Level

			   l_line_adj_Tbl(l_Adj_Index).line_id :=  null;
			   l_line_adj_Tbl(l_Adj_Index).Header_id :=
					p_req_line_tbl(p_req_line_detail_Tbl(j).line_index).line_id;
							-- line_id hold header_id for 'HEADER'
			   l_line_adj_Tbl(l_Adj_Index).Line_index := null;

				--OE_GLOBALS.G_CASCADING_REQUEST_LOGGED := TRUE;

			 End If ; -- list_line_level


			 -- Process "Other Item Discounts" (Including Free goods)

				G_STMT_NO := 'process_adjustments#80';


			 -- Process Promotional Goods

			 If p_req_line_detail_Tbl(j).list_line_type_code ='PRG' Then
				adj_debug('The Detail is a PRG '||p_req_line_detail_Tbl(j).line_detail_index);

				i:= p_Req_Related_Lines_Tbl.First;
				While i is not null loop

				  if p_Req_Related_Lines_Tbl(i).Line_Detail_Index =
									p_req_line_detail_Tbl(j).line_detail_index and
					p_Req_Related_Lines_Tbl(i).Relationship_Type_Code
						=QP_PREQ_GRP.G_GENERATED_LINE Then

					adj_debug('The related line is '||p_Req_Related_Lines_Tbl(i).Related_Line_Detail_Index);
				    -- Process the "Other Item"

				    If p_Req_Related_Lines_Tbl(i).Related_Line_Detail_Index is not Null
				    Then
					-- Inserts Rows into Line_Tbl and Adjustments

					G_STMT_NO := 'process_adjustments#90';

                                        Begin
                                          oe_debug_pub.add('Line id:'||
                                          l_line_tbl(p_req_line_detail_Tbl(p_req_related_lines_tbl(i).line_detail_index).line_index).line_id);

                                          oe_debug_pub.add('Reason:'||
                                          l_line_tbl(p_req_line_detail_Tbl(p_req_related_lines_tbl(i).line_detail_index).line_index).return_reason_code);
                                        Exception when others then
                                          oe_debug_pub.add(SQLERRM||G_STMT_NO);
                                        End;

					Process_Other_Item_Line
					(p_Line_Detail_Index 			=>
							p_Req_Related_Lines_Tbl(i).Related_Line_Detail_Index,
					 p_req_line_Tbl 		=> p_req_line_Tbl,
					 p_req_line_detail_Tbl 	=> p_req_line_detail_Tbl,
					 p_req_line_detail_Attr_Tbl 	=> p_req_line_detail_Attr_Tbl,
					 p_Price_Adjustment_Id	=> l_line_adj_Tbl(l_Adj_Index).Price_Adjustment_Id,
					 p_Header_id			=> p_header_rec.Header_id,
					 p_Parent_Adj_Index		=> l_Adj_Index,
					 p_parent_line_index	=>  p_req_line_detail_Tbl(j).line_index,
					 p_Rltd_line_details_prcd=> l_Rltd_line_details_prcd,
					 --p_Rltd_line_details_prcd=> l_line_details_prcd,
					 p_Rltd_lines_prcd		=> l_Rltd_lines_prcd,
					 p_Line_Tbl			=> l_Line_Tbl,
					 p_Line_Adj_Tbl		=> l_line_adj_Tbl,
					 p_Line_Adj_Assoc_Tbl	=> l_line_adj_Assoc_Tbl,
                                         p_line_detail_replaced => l_line_detail_replaced,
                                         p_buy_line_rec         =>  l_line_tbl(p_req_line_detail_Tbl(p_req_related_lines_tbl(i).line_detail_index).line_index));

				    End If; -- RelationShips
				  End If;
				  i:= p_Req_Related_Lines_Tbl.next(i);
				End Loop;

			 End If; -- PRG

		   end if; -- Duplicate list lines in the adjustments
			-- Process the Qualifiers
  		end if; -- for list_line_type

	   end if;  -- Status_code = Updated.

	   If ( (p_req_line_detail_Tbl(j).limit_code = QP_PREQ_GRP.G_STATUS_LIMIT_EXCEEDED ) -- PROMOTIONS SEP/01 START
            or (p_req_line_detail_Tbl(j).limit_code = QP_PREQ_GRP.G_STATUS_LIMIT_ADJUSTED ) )
   	     then
	      --  adj_debug('PAL PROMOTIONS - G_STATUS_LIMIT_EXCEEDED or G_STATUS_LIMIT_ADJUSTED IN _Adj_pvt.process_adjustments',1);
		IF (p_req_line_tbl(p_req_line_detail_tbl(j).line_index).LINE_TYPE_CODE='ORDER') THEN
			OE_MSG_PUB.set_msg_context
      			( p_entity_code                 => 'HEADER'
         		,p_entity_id                   => p_header_rec.header_id--p_req_line_tbl(j).line_id
         		,p_header_id                   => p_header_rec.header_id
         		,p_line_id                     => NULL--p_req_line_tbl(j).line_id
         		,p_orig_sys_document_ref       => p_header_rec.orig_sys_document_ref
         		,p_orig_sys_document_line_ref  => NULL
         		,p_change_sequence             => p_header_rec.change_sequence
         		,p_source_document_id          => p_header_rec.source_document_id
         		,p_source_document_line_id     => NULL
         		,p_order_source_id             => p_header_rec.order_source_id
         		,p_source_document_type_id     => p_header_rec.source_document_type_id);
		ELSE
                  IF p_req_line_tbl(p_req_line_detail_tbl(j).line_index).line_id IS NOT NULL AND
                     p_req_line_tbl(p_req_line_detail_tbl(j).line_index).line_id <> FND_API.G_MISS_NUM THEN
                     BEGIN
                       IF l_debug_level  > 0 THEN
                          oe_debug_pub.add('Getting reference data for line_id:'||p_req_line_tbl(p_req_line_detail_tbl(j).line_index).line_id);
                       END IF;
                       SELECT order_source_id, orig_sys_document_ref, change_sequence,
                       source_document_type_id, source_document_id, orig_sys_line_ref,
                       source_document_line_id, orig_sys_shipment_ref
                       INTO l_order_source_id, l_orig_sys_document_ref, l_change_sequence,
                       l_source_document_type_id, l_source_document_id, l_orig_sys_line_ref,
                       l_source_document_line_id, l_orig_sys_shipment_ref
                       FROM   OE_ORDER_LINES_ALL
                       WHERE  line_id = p_req_line_tbl(p_req_line_detail_tbl(j).line_index).line_id;
                     EXCEPTION
                       WHEN NO_DATA_FOUND THEN
                           l_order_source_id := null;
                           l_orig_sys_document_ref := null;
                           l_change_sequence := null;
                           l_source_document_type_id := null;
                           l_source_document_id := null;
                           l_orig_sys_line_ref := null;
                           l_source_document_line_id := null;
                           l_orig_sys_shipment_ref := null;
                       WHEN OTHERS THEN
                           l_order_source_id := null;
                           l_orig_sys_document_ref := null;
                           l_change_sequence := null;
                           l_source_document_type_id := null;
                           l_source_document_id := null;
                           l_orig_sys_line_ref := null;
                           l_source_document_line_id := null;
                           l_orig_sys_shipment_ref := null;
                     END;
                  END IF;
               		OE_MSG_PUB.set_msg_context
      			( p_entity_code                 => 'LINE'
         		,p_entity_id                   => p_req_line_tbl(p_req_line_detail_tbl(j).line_index).LINE_ID
         		,p_header_id                   => p_header_rec.header_id
         		,p_line_id                     => p_req_line_tbl(p_req_line_detail_tbl(j).line_index).line_id
                        ,p_order_source_id              => l_order_source_id
                        ,p_orig_sys_document_ref        => l_orig_sys_document_ref
                        ,p_orig_sys_document_line_ref   => l_orig_sys_line_ref
                        ,p_orig_sys_shipment_ref        => l_orig_sys_shipment_ref
                        ,p_change_sequence              => l_change_sequence
                        ,p_source_document_type_id      => l_source_document_type_id
                        ,p_source_document_id           => l_source_document_id
                        ,p_source_document_line_id      => l_source_document_line_id);
		END IF;

		FND_MESSAGE.SET_NAME('ONT','ONT_PROMO_LIMIT_EXCEEDED');
		FND_MESSAGE.SET_TOKEN('ERR_TEXT', p_req_line_detail_tbl(j).LIMIT_TEXT);
		OE_MSG_PUB.Add;
   		IF (OE_GLOBALS.G_UI_FLAG ) THEN
       			IF (G_REQUEST_ID IS NULL) THEN
         			select oe_msg_request_id_s.nextval into g_request_id from dual;
       			END IF;
      			OE_MSG_PUB.INSERT_MESSAGE(OE_MSG_PUB.COUNT_MSG, G_REQUEST_ID,'U');
      			OE_MSG_PUB.DELETE_MSG(OE_MSG_PUB.COUNT_MSG);
  		END IF;

 	    end if; --PROMOTIONS SEP/01 end

           end if; --l_adj_line_index is either postive of 0 nvl(l_adj_index,-1)

	   J:=p_req_line_detail_Tbl.Next(j);

	 end loop; -- p_req_line_detail_Tbl

	G_STMT_NO := 'process_adjustments#100';

--No adjustment records, or relationsip,attributes record need to be looked at becasue
--enforce list price is set to 'Y'
If nvl(v_line_enforce_list_price,'N') <> 'Y' Then
	-- Process Price Break Lines
		i:= p_Req_Related_Lines_Tbl.First;
		While i is not null loop
			if
			p_Req_Related_Lines_Tbl(i).Relationship_Type_Code in (
				QP_PREQ_GRP.G_PBH_LINE ,QP_PREQ_GRP.G_GENERATED_LINE ) and
				p_Req_Related_Lines_Tbl(i).Line_Detail_Index is not null and
				p_Req_Related_Lines_Tbl(i).Related_Line_Detail_Index is not null and
				l_line_details_prcd.exists(p_Req_Related_Lines_Tbl(i).Line_Detail_Index) and
				l_line_details_prcd.exists(p_Req_Related_Lines_Tbl(i).Related_Line_Detail_Index)
  and l_line_adj_tbl(l_line_details_prcd(p_Req_Related_Lines_Tbl(i).Line_Detail_Index)).updated_flag = 'N'
			Then
                                If G_DEBUG Then
				adj_debug('RLTD: line detail '||p_Req_Related_Lines_Tbl(i).Line_Detail_Index,2);
				adj_debug('RLTD: rltd line detail '||p_Req_Related_Lines_Tbl(i).Related_Line_Detail_Index,2);
				adj_debug('RLTD: Relationship type '||p_Req_Related_Lines_Tbl(i).Relationship_Type_Code,2);
                                End If;

			-- Process the Relationship records
			--	l_assoc_index := l_Line_Adj_Assoc_tbl.count+1;
/* Commented the above line and added following 5 lines to fix the bug 2312402 */
                                IF (l_Line_Adj_Assoc_tbl.count > 0) THEN
                                  l_assoc_index := l_Line_Adj_Assoc_tbl.last+1;
                                ELSE
                                  l_assoc_index := 1;
                                END IF;
                                l_Line_Adj_Assoc_tbl(l_assoc_index) := OE_ORDER_PUB.G_MISS_LINE_ADJ_ASSOC_REC;
				l_Line_Adj_Assoc_tbl(l_assoc_index).Line_Index := Null;
				l_Line_Adj_Assoc_tbl(l_assoc_index).Adj_Index :=
					l_line_details_prcd(p_Req_Related_Lines_Tbl(i).Line_Detail_Index);
				l_Line_Adj_Assoc_tbl(l_assoc_index).Rltd_Adj_Index :=
					l_line_details_prcd(p_Req_Related_Lines_Tbl(i).Related_Line_Detail_Index);
				l_Line_Adj_Assoc_tbl(l_assoc_index).Operation := OE_Globals.G_OPR_CREATE;

				If  l_line_adj_Tbl.exists(l_line_details_prcd(p_Req_Related_Lines_Tbl(i).line_detail_Index))
				and l_line_adj_Tbl(l_line_details_prcd(p_Req_Related_Lines_Tbl(i).line_detail_Index)).price_adjustment_id <> FND_API.G_MISS_NUM and
				l_line_adj_Tbl(l_line_details_prcd(p_Req_Related_Lines_Tbl(i).line_detail_Index)).price_adjustment_id is not null then

					l_Line_Adj_Assoc_tbl(l_assoc_index).price_adjustment_id :=
					l_line_adj_Tbl(l_line_details_prcd(p_Req_Related_Lines_Tbl(i).line_detail_Index)).price_adjustment_id ;
				End If; -- Populate Adjustment_id
				If  l_line_adj_Tbl.exists(l_line_details_prcd(p_Req_Related_Lines_Tbl(i).Related_Line_Detail_Index))
				and l_line_adj_Tbl(l_line_details_prcd(p_Req_Related_Lines_Tbl(i).Related_Line_Detail_Index)).price_adjustment_id <> FND_API.G_MISS_NUM and
				l_line_adj_Tbl(l_line_details_prcd(p_Req_Related_Lines_Tbl(i).Related_Line_Detail_Index)).price_adjustment_id is not null then

					l_Line_Adj_Assoc_tbl(l_assoc_index).rltd_price_adj_id :=
					l_line_adj_Tbl(l_line_details_prcd(p_Req_Related_Lines_Tbl(i).Related_Line_Detail_Index)).price_adjustment_id ;
				End If; -- Populate Adjustment_id

			End If; -- RelationShips
			i:= p_Req_Related_Lines_Tbl.Next(i);
		End Loop;

	 -- Process Qualifier Attributes

	 i:= p_Req_LINE_DETAIL_qual_tbl.First;
	 While i is not null Loop
	 --For i in  1..p_Req_LINE_DETAIL_qual_tbl.count loop
        if l_line_details_prcd.exists(p_Req_LINE_DETAIL_qual_tbl(i).line_detail_index)
	   --or l_Rltd_line_details_prcd.exists(p_Req_LINE_DETAIL_qual_tbl(i).line_detail_index)
		then

		G_STMT_NO := 'process_adjustments#110';
		If  l_line_adj_Tbl.exists(l_line_details_prcd(p_Req_LINE_DETAIL_qual_tbl(i).line_detail_Index))
			and l_line_adj_Tbl(l_line_details_prcd(p_Req_LINE_DETAIL_qual_tbl(i).line_detail_Index)).price_adjustment_id <> FND_API.G_MISS_NUM and
			l_line_adj_Tbl(l_line_details_prcd(p_Req_LINE_DETAIL_qual_tbl(i).line_detail_Index)).price_adjustment_id is not null then

			l_price_adjustment_id :=
			l_line_adj_Tbl(l_line_details_prcd(p_Req_LINE_DETAIL_qual_tbl(i).line_detail_Index)).price_adjustment_id ;
                Else
                  l_price_adjustment_id := NULL;
		End If; -- Populate Adjustment_id

		adj_debug('In Qual loop',2);
		Find_Duplicate_Adj_Attribs(
			p_Req_LINE_DETAIL_qual_Rec 	=> p_Req_LINE_DETAIL_qual_tbl(i),
			p_Req_Line_Detail_Attr_Rec    => l_Req_Line_Detail_Attr_Rec,
			p_Adj_index 				=>
					l_line_details_prcd(
						p_Req_LINE_DETAIL_qual_tbl(i).line_detail_Index),
			p_Line_Adj_Att_Tbl 			=> l_Line_Adj_Att_tbl,
			p_Att_Type		=> 'QUALIFIER',
			p_price_adjustment_id	=> l_price_adjustment_id
				);

	   End If;
	   i:= p_Req_LINE_DETAIL_qual_tbl.next(i);
	 end loop;

	 -- Process Pricing Attributes

	 i:= p_Req_LINE_DETAIL_Attr_tbl.First;
	 While i is not null Loop
	 --For i in  1..p_Req_LINE_DETAIL_Attr_tbl.count loop

        if l_line_details_prcd.exists(p_Req_LINE_DETAIL_Attr_tbl(i).line_detail_index)
	   --or l_Rltd_line_details_prcd.exists(p_Req_LINE_DETAIL_Attr_tbl(i).line_detail_index)
	   Then

		If  l_line_adj_Tbl.exists(l_line_details_prcd(p_Req_LINE_DETAIL_attr_tbl(i).line_detail_Index))
			and l_line_adj_Tbl(l_line_details_prcd(p_Req_LINE_DETAIL_attr_tbl(i).line_detail_Index)).price_adjustment_id <> FND_API.G_MISS_NUM and
			l_line_adj_Tbl(l_line_details_prcd(p_Req_LINE_DETAIL_attr_tbl(i).line_detail_Index)).price_adjustment_id is not null
			then

			l_price_adjustment_id :=
			l_line_adj_Tbl(l_line_details_prcd(p_Req_LINE_DETAIL_attr_tbl(i).line_detail_Index)).price_adjustment_id ;
                Else
                  l_price_adjustment_id := NULL;
		End If; -- Populate Adjustment_id

		G_STMT_NO := 'process_adjustments#120';
		adj_debug('In Attr loop Index '||p_Req_LINE_DETAIL_Attr_tbl(i).line_detail_index,2);
		Find_Duplicate_Adj_Attribs(
			p_Req_LINE_DETAIL_qual_Rec 	=> l_Req_LINE_DETAIL_qual_Rec,
			p_Req_LINE_DETAIL_Attr_Rec 	=> p_Req_LINE_DETAIL_Attr_tbl(i),
			p_Adj_index 				=>
					l_line_details_prcd(
						p_Req_LINE_DETAIL_Attr_tbl(i).line_detail_Index),
			p_Line_Adj_Att_Tbl 			=> l_Line_Adj_Att_tbl,
			p_Att_Type		=> 'PRICING',
			p_price_adjustment_id	=> l_price_adjustment_id
				);
	   End If;
	   i:= p_Req_LINE_DETAIL_Attr_tbl.Next(i);
	 end loop;

	adj_debug('Before cal #adjs '||l_Line_Adj_Tbl.count);

	--If p_Req_Control_Rec.Calculate_Flag = QP_PREQ_GRP.G_SEARCH_ONLY Then
	-- The calculation Engine was not called , when the price request was made
		G_STMT_NO := 'process_adjustments#130';

                i:=l_line_adj_tbl.first;
		adj_debug('before calling calculate_price');
                while i is not null loop
                    adj_debug('line_index:'||l_line_adj_tbl(i).line_index);
                    adj_debug('list line id:'||l_line_adj_tbl(i).list_line_id);
		    adj_debug('operation : ' || l_line_adj_tbl(i).operation);
 		    IF (l_line_adj_tbl(i).operation = oe_globals.g_opr_delete
			  and l_line_adj_tbl(i).list_line_type_code='PRG') THEN

                        adj_debug('Need to delete/update free goods line');
		        /* 1503357 */
                        OE_ORDER_ADJ_PVT.change_prg_lines(
		           p_price_adjustment_id => l_line_adj_tbl(i).price_adjustment_id,
                           p_line_tbl            => l_line_tbl,
                           p_line_adj_tbl        => l_line_adj_tbl,
                           p_delete_prg_lines    => l_delete_prg_lines);
		     END IF;
                     i:=l_line_adj_tbl.next(i);
                  End loop;

end if;  ---enforce list price flag checked

		Calculate_Price (
			p_Header_Rec            => p_Header_Rec
			,p_Line_Tbl         	=> l_line_Tbl
			,p_Line_Adj_Tbl     	=> l_Line_Adj_Tbl
			,p_line_adj_assoc_Tbl   => l_line_adj_assoc_Tbl
			,p_allow_negative_price => l_allow_negative_price
			,p_request_Type_Code	=> p_request_Type_Code
                        ,p_any_line_frozen      => p_any_frozen_line
   ,p_price_event   => p_req_control_rec.pricing_event  --bug 2273446
   ,p_honor_price_flag  => p_honor_price_flag   --bug 2503186
			);


	adj_debug('After cal #adjs '||l_Line_Adj_Tbl.count);


	G_STMT_NO := 'process_adjustments#161';
   I:= l_line_tbl.First;
   while i is not null loop

        If G_DEBUG Then
    	 adj_debug('--------------------------------------',2);
    	 adj_debug('index '||i,2);
    	 adj_debug('The list price before call'||l_line_tbl(i).unit_list_price_per_pqty,2);
     	 adj_debug('The selling price before call'||l_line_tbl(i).unit_Selling_price_per_pqty,2);
    	 adj_debug('The line id'||l_line_tbl(i).Line_id,2);
    	 adj_debug('The Inventory_item_id '||l_line_tbl(i).Inventory_item_id,2);
    	 adj_debug('The header id'||l_line_tbl(i).header_id,2);
         adj_debug('Payment_term , before process order '||l_line_tbl(i).payment_term_id,2);
        End If;

        -- uom begin
	If oe_line_util.Get_Return_Item_Type_Code(l_line_tbl(i)) in ('INCLUDED', 'CONFIG') then
		l_line_tbl(i).unit_list_price_per_pqty := 0;
	end if;

	If l_line_tbl(i).unit_Selling_price_per_pqty is null  or
	oe_line_util.Get_Return_Item_Type_Code(l_line_tbl(i)) in ('INCLUDED', 'CONFIG')
	then
		l_line_tbl(i).unit_Selling_price_per_pqty := l_line_tbl(i).unit_list_price_per_pqty;
	end if;

        If l_line_tbl(i).ordered_quantity IS NOT NULL and l_line_tbl(i).ordered_quantity <> 0
        then
          l_line_tbl(i).unit_selling_price := l_line_tbl(i).unit_selling_price_per_pqty * l_line_tbl(i).pricing_quantity/l_line_tbl(i).ordered_quantity;

          l_line_tbl(i).unit_list_price := l_line_tbl(i).unit_list_price_per_pqty * l_line_tbl(i).pricing_quantity/l_line_tbl(i).ordered_quantity;
        end if;

      -- OPM 2547940  start - if pricing by quantity2 then if line is shipped and has shipped qty2 != ordered qty2
   --  need to adjust the unit selling price so that invoicing will show correct amount (ordered qty * USP (adjusted) )

	IF oe_line_util.dual_uom_control -- INVCONV
              (l_line_tbl(i).inventory_item_id
              ,l_line_tbl(i).ship_from_org_id
              ,l_item_rec) THEN
                   		IF l_item_rec.ont_pricing_qty_source = 'S'   THEN -- price by quantity 2 -- INVCONV
                		  	IF (l_line_tbl(i).ordered_quantity2 IS NOT NULL and l_line_tbl(i).ordered_quantity2 <> 0	)
                        		AND ( l_line_tbl(i).shipped_quantity2 IS NOT NULL and l_line_tbl(i).shipped_quantity2 <> 0	)
                        		 AND l_line_tbl(i).ordered_quantity2 <> l_line_tbl(i).shipped_quantity2 THEN
			              l_line_tbl(i).unit_selling_price := (l_line_tbl(i).unit_selling_price_per_pqty * l_line_tbl(i).pricing_quantity )/l_line_tbl(i).ordered_quantity2
                       		      * (l_line_tbl(i).shipped_quantity2/l_line_tbl(i).ordered_quantity);
                       		      l_line_tbl(i).unit_list_price := (l_line_tbl(i).unit_list_price_per_pqty * l_line_tbl(i).pricing_quantity )/l_line_tbl(i).ordered_quantity2
                       		      * (l_line_tbl(i).shipped_quantity2/l_line_tbl(i).ordered_quantity);
               				oe_debug_pub.ADD('OPM NEW USP : '|| to_char(l_line_tbl(i).unit_selling_price),5);
               				 END IF;
               	                END IF;
	END IF;  --oe_line_util.dual_uom_control -- INVCONV
-- OPM 2547940 end


        -- uom end


       adj_debug(' Values passed into QP_UTIL_PUB.round_price api:');
       adj_debug('  p_operand:'||l_line_tbl(i).unit_selling_price);
       adj_debug('  price_list_id:'||l_line_tbl(i).price_list_id);
       adj_debug('  currency_code:'||g_order_currency);
       adj_debug('  pricing_effective_date:'||l_line_tbl(i).pricing_date);
       If l_line_tbl(i).unit_selling_price is not null Then
        QP_UTIL_PUB.round_price(p_operand                => l_line_tbl(i).unit_selling_price,
			       p_rounding_factor        => NULL,
			       p_use_multi_currency     => 'Y',
			       p_price_list_id          => l_line_tbl(i).price_list_id,
			       p_currency_code          => g_order_currency,
			       p_pricing_effective_date => l_line_tbl(i).pricing_date,
			       x_rounded_operand        => l_line_tbl(i).unit_selling_price,
			       x_status_code            => l_status_code);
        adj_debug(' Rounded Unit Selling Price Returned By pricing API:'||l_line_tbl(i).unit_selling_price);
        adj_debug(' x_status_code:'||l_status_code);
       End If;


    -- If a service reference line of different order is present set the operation.
     If l_line_tbl(i).header_id <> l_header_rec.header_id then
		l_line_tbl(i).operation := oe_globals.g_opr_none;
     End If;


	-- Remove the holes in the structure.
	l_lines_prcd(i) := l_Line_Tbl_Final.Count+1;

    l_Line_Tbl_Final(l_lines_prcd(i)) := l_line_tbl(i);

    J:= x_line_tbl.First;
    While J is not null loop
	If x_line_tbl(j).line_id = l_line_tbl(i).line_id and
		l_line_tbl(i).line_id <> fnd_api.g_miss_num then
		l_old_line_tbl(l_Line_Tbl_Final.Count) := x_line_tbl(j);
		Exit;
	end if;

	j:= x_line_tbl.next(j);
    End Loop;

   l := l_line_tbl_final.count;
   adj_debug('operation'||l_line_tbl_final(l).operation,1);
     -- 2270949: logging message about free goods line
     if (l_line_Tbl_final(l).operation = OE_GLOBALS.G_OPR_CREATE) and p_write_to_db = TRUE then
                 -- Display the PRG Item
                 FND_MESSAGE.SET_NAME('ONT','ONT_CREATED_NEW_LINE');
              FND_MESSAGE.SET_TOKEN('ITEM',l_line_tbl_final(l).ordered_item);
   --bug 2412868  begin
  if l_line_tbl_final(l).line_category_code = 'RETURN' then
  FND_MESSAGE.SET_TOKEN('QUANTITY',(-1) * l_line_tbl_final(l).Ordered_quantity);
  else
   --bug 2412868  end
   FND_MESSAGE.SET_TOKEN('QUANTITY',l_line_tbl_final(l).Ordered_quantity);
  end if;
                 OE_MSG_PUB.Add('N');
                 OE_GLOBALS.G_CASCADING_REQUEST_LOGGED := TRUE;
     end if;
     -- end 2270949

     -- only Lock the lines that needs to be updated
	 if (l_line_tbl_final(l).operation = FND_API.G_MISS_CHAR or
		l_line_tbl_final(l).operation = OE_GLOBALS.G_OPR_NONE or
		l_line_tbl_final(l).operation is null )
                and p_write_to_db = TRUE then


	/* Fix for bug 1889762
	   Added condition to check if the old and new unit selling price are the same
	*/
        /* Added an extra condition in the following If condition to check price_list has changed.
           This is done to fix the bug 2242256 */
       If (l_line_tbl_final(l).unit_selling_price_per_pqty = l_old_line_tbl(l).unit_selling_price_per_pqty AND
           l_line_tbl_final(l).unit_list_price_per_pqty = l_old_line_tbl(l).unit_list_price_per_pqty AND
	   l_line_tbl_final(l).unit_selling_price = l_old_line_tbl(l).unit_selling_price AND
           l_line_tbl_final(l).price_list_id = l_old_line_tbl(l).price_list_id AND
           l_line_tbl_final(l).pricing_quantity = l_old_line_tbl(l).pricing_quantity AND
           l_line_tbl_final(l).pricing_quantity_uom = l_old_line_tbl(l).pricing_quantity_uom AND
           l_line_tbl_final(l).inventory_item_id = l_old_line_tbl(l).inventory_item_id AND
           ((l_line_tbl_final(l).payment_term_id IS NULL AND l_old_line_tbl(l).payment_term_id IS NULL) OR
            l_line_tbl_final(l).payment_term_id = l_old_line_tbl(l).payment_term_id) AND
           ((l_line_tbl_final(l).shipping_method_code IS NULL AND l_old_line_tbl(l).shipping_method_code IS NULL) OR
            l_line_tbl_final(l).shipping_method_code = l_old_line_tbl(l).shipping_method_code) AND
           ((l_line_tbl_final(l).freight_terms_code IS NULL AND l_old_line_tbl(l).freight_terms_code IS NULL) OR
            l_line_tbl_final(l).freight_terms_code = l_old_line_tbl(l).freight_terms_code)
           )AND
          ((l_line_tbl_final(l).price_request_code IS NULL AND l_old_line_tbl(l).price_request_code IS NULL) OR
            l_line_tbl_final(l).price_request_code =l_old_line_tbl(l).price_request_code)

       then
           l_line_tbl_final(l).operation := OE_GLOBALS.G_OPR_NONE;
       adj_debug('do nothing to '||i||' '||l_old_line_tbl(l).line_id,1);
       Else
      	l_line_tbl_final(l).operation := OE_GLOBALS.G_OPR_UPDATE;
        l_num_changed_lines := l_num_changed_lines + 1;
       adj_debug('lock row '||i||' '||l_old_line_tbl(l).line_id,1);
         OE_LINE_UTIL.Lock_Row(x_return_status => x_return_status,
                                 p_x_line_rec => l_old_line_tbl(l)
                                );

        IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
		RAISE FND_API.G_EXC_ERROR;
	END IF;

       End If;
     ELSIF p_write_to_db = TRUE THEN
        adj_debug('original operation'||l_line_tbl_final(l).operation);
        l_num_changed_lines := l_num_changed_lines + 1;
     End If;

    i:= l_line_tbl.next(i);
  end loop;
adj_debug('number of changed lines'||l_num_changed_lines||' out nocopy of'||l_line_tbl_final.count);


   -- Delete the record with operation not set
	G_STMT_NO := 'process_adjustments#140';

   --currently for NOT write to db mode,  which is getting-a-quote mode
   --this procedure is not returning adjustments details. Will
   --need to implement it in the later version where will return
   --adustment detail even if it is only a getting-a-quote mode.
   If p_write_to_db Then

   i := l_line_adj_tbl.First;

   While i is not null loop

        If G_DEBUG Then
	 adj_debug('----------------------',3);
	 adj_debug('The Adjustment_id '||l_Line_Adj_Tbl(i).price_adjustment_id,3);
	 adj_debug('The list_line_id '||l_Line_Adj_Tbl(i).list_line_id,3);
	 adj_debug('The line_id '||l_Line_Adj_Tbl(i).line_id,3);
	 adj_debug('The line_typ '||l_Line_Adj_Tbl(i).list_line_type_code,3);
	 adj_debug('The operation '||l_Line_Adj_Tbl(i).operation,3);
         adj_debug('The adjusted amount '||l_Line_Adj_Tbl(i).adjusted_amount);
        End If;

	-- Assign the new line index
	If l_line_adj_tbl(i).Line_Index is not null and
				l_line_adj_tbl(i).Line_Index <> fnd_api.g_miss_num and
				l_lines_prcd.exists(l_line_adj_tbl(i).Line_Index) then
		l_line_adj_tbl(i).Line_Index := l_lines_prcd(l_line_adj_tbl(i).Line_Index);
	End If;

        adj_debug(' The line_index:'||l_line_adj_tbl(i).Line_Index);
        -- bug 2089312
        -- to check if it is a Header Level Adjustment
        IF (l_Line_Adj_Tbl(i).line_id is null or
	    l_Line_Adj_Tbl(i).line_id = fnd_api.g_miss_num)
	    AND (l_Line_Adj_Tbl(i).line_index is null or
	         l_Line_Adj_Tbl(i).line_index = fnd_api.g_miss_num)
	    AND l_Line_Adj_Tbl(i).Header_Id = p_header_Rec.Header_Id
            AND l_Line_Adj_Tbl(i).operation IN (OE_GLOBALS.G_OPR_CREATE, OE_GLOBALS.G_OPR_UPDATE, OE_GLOBALS.G_OPR_DELETE)
            AND l_Line_Adj_Tbl(i).list_line_type_code NOT IN ('FREIGHT_CHARGE','TAX','COST')
            AND nvl(g_pass_all_lines,'N') <> 'Y' THEN
	    -- This is a header level adjustments, and not a freight charge.
            -- Need to log a delayed request to apply this header level adjustment
            -- to all lines on this order if not all lines were passed to pricing engine.

            adj_debug('Logging request to update all lines for header level adjustment.', 1);
	    OE_DELAYED_REQUESTS_PVT.LOG_REQUEST(
			p_entity_code     	 => OE_GLOBALS.G_ENTITY_ALL,
			p_entity_id              => l_Line_adj_tbl(i).header_id,
			p_requesting_entity_code => OE_GLOBALS.G_ENTITY_HEADER,
			p_requesting_entity_id   => l_Line_adj_tbl(i).header_id,
			p_request_type           => OE_GLOBALS.G_PRICE_ADJ,
			x_return_status          => l_return_status);

        END IF;


	G_STMT_NO := 'process_adjustments#140.1';
	-- Update the Header Level TERM Substitution on all Lines.
	If l_header_rec.operation = oe_globals.g_opr_update then
	  If l_line_adj_tbl(i).list_line_type_code = 'TSN' and
		l_line_adj_tbl(i).modifier_level_code ='ORDER'
	  then
		adj_debug('In Header TSN ');
		adj_debug('Attribute '||l_line_adj_tbl(i).substitution_attribute);
		-- Loop through all the lines and update
		j:= l_Line_Tbl_Final.first;
		while j is not null loop
			-- Check if there is a line level term substitution
			l_Line_Term := FALSE;
			k:= l_line_adj_tbl.First;
			while k is not null loop
				If l_line_adj_tbl(k).line_index =  J and
					l_line_adj_tbl(k).list_line_type_code = 'TSN' and
					l_line_adj_tbl(k).substitution_attribute = l_line_adj_tbl(i).substitution_attribute
				Then
					l_line_term := TRUE;
					Exit;
				End If;
				k:= l_line_adj_tbl.Next(k);
			End Loop; -- line_adj K

			If not l_line_term then

			   	If l_line_adj_tbl(i).Substitution_Attribute ='QUALIFIER_ATTRIBUTE1' Then
					adj_debug('Updating Payment term '||l_line_adj_tbl(i).Modified_to);
				   	l_Line_Tbl_Final(j).payment_term_id :=  l_line_adj_tbl(i).Modified_to;
			   	elsIf l_line_adj_tbl(i).Substitution_Attribute ='QUALIFIER_ATTRIBUTE11' Then
					adj_debug('Updating shipping_method_code '||l_line_adj_tbl(i).Modified_to);
				   	l_Line_Tbl_Final(j).shipping_method_code :=  l_line_adj_tbl(i).Modified_to;

			   	elsIf l_line_adj_tbl(i).Substitution_Attribute ='QUALIFIER_ATTRIBUTE10' Then
					adj_debug('Updating freight_terms_code '||l_line_adj_tbl(i).Modified_to);
				   	l_Line_Tbl_Final(j).freight_terms_code :=  l_line_adj_tbl(i).Modified_to;

			   	End If;
                                If (l_Line_Tbl_Final(j).operation = OE_GLOBALS.G_OPR_NONE) Then
                                        l_Line_Tbl_Final(j).operation := OE_GLOBALS.G_OPR_UPDATE;
                                End If;
				--adj_debug('----------------------');
			End If;

                        --
                        IF l_Line_Tbl_Final(j).booked_flag = 'Y' THEN
                          --
                          IF l_Line_Tbl_Final(j).unit_selling_price IS NULL
                             OR l_line_tbl_final(j).unit_list_price IS NULL
                             OR l_line_tbl_final(j).price_list_id IS NULL THEN
                            --
                            l_item_type_code := oe_line_util.Get_Return_Item_Type_Code(l_Line_Tbl_Final(j));
                            --
                            IF (l_item_type_code <> 'CONFIG'
                               AND l_item_type_code <> 'INCLUDED') THEN
                              --
                              --
                              If l_Line_Tbl_Final(j).unit_selling_price IS NULL Then
                               FND_MESSAGE.SET_NAME('ONT','OE_BOOK_REQD_LINE_ATTRIBUTE');
	                       FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
	                         OE_Order_UTIL.Get_Attribute_Name('UNIT_SELLING_PRICE'));
     	                       OE_MSG_PUB.ADD;
                              End If;

                              If l_line_tbl_final(j).unit_list_price IS NULL Then
                                FND_MESSAGE.SET_NAME('ONT','OE_BOOK_REQD_LINE_ATTRIBUTE');
	                        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
	                        OE_Order_UTIL.Get_Attribute_Name('UNIT_LIST_PRICE'));
     	                        OE_MSG_PUB.ADD;
                              End If;

                              If l_line_tbl_final(j).price_list_id IS NULL Then
                                FND_MESSAGE.SET_NAME('ONT','OE_BOOK_REQD_LINE_ATTRIBUTE');
	                        FND_MESSAGE.SET_TOKEN('ATTRIBUTE','LIST PRICE');
     	                        OE_MSG_PUB.ADD;
                              End If;

                              RAISE FND_API.G_EXC_ERROR;
                              --
                            END IF;
                            --
                          END IF;
                          --
                        END IF;
                        --

		 j:= l_Line_Tbl_Final.next(j);
		end loop;

	  End If;
	end if;
	G_STMT_NO := 'process_adjustments#140.2';
	if l_line_adj_tbl(i).operation = fnd_api.g_miss_char  or
		l_Line_Adj_Tbl(i).list_line_type_code in ('TAX','COST')
		or l_line_adj_tbl(i).operation is null
		or l_line_adj_tbl(i).operation =oe_globals.g_opr_none then
		l_line_adj_tbl.delete(i);
	Elsif l_line_adj_tbl(i).operation = oe_globals.g_opr_update and
		( l_line_adj_tbl(i).price_adjustment_id is null or
		l_line_adj_tbl(i).price_adjustment_id = fnd_api.g_miss_num ) then
		l_line_adj_tbl(i).operation := oe_globals.g_opr_Create;
  	ELsif l_line_adj_tbl(i).line_id IS NOT NULL and
	      l_line_adj_tbl(i).line_id <> FND_API.G_MISS_NUM and
	      l_delete_prg_lines.exists(l_line_adj_tbl(i).line_id) THEN
              l_line_adj_tbl.delete(i);
	End if;


	i:= l_line_adj_tbl.next(i);
   End loop;

   G_STMT_NO := 'process_adjustments#150';
   i:= l_line_adj_att_tbl.First;

   while i is not null loop
                If G_DEBUG Then
		 adj_debug('Adj Index '||l_line_adj_Att_tbl(i).Adj_Index,3);
		 Adj_Debug('The Price Adj '||l_line_adj_Att_tbl(i).price_adjustment_id,3);
		 Adj_Debug('Operation '||l_line_adj_Att_tbl(i).operation,3);
		 Adj_Debug('flex_title '||l_line_adj_Att_tbl(i).flex_title,3);
		 Adj_Debug('pricing_context '||l_line_adj_Att_tbl(i).pricing_context,3);
		 Adj_Debug('pricing_attribute '||l_line_adj_Att_tbl(i).pricing_attribute,3);
		 Adj_Debug('pricing_attr_value_from '||l_line_adj_Att_tbl(i).pricing_attr_value_from,3);
		 Adj_Debug('pricing_attr_value_To '||l_line_adj_Att_tbl(i).pricing_attr_value_To,3);
		 Adj_Debug('comparison_operator '||l_line_adj_Att_tbl(i).comparison_operator,3);
		 Adj_Debug('------------------------------',3);
                End If;

	if l_line_adj_Att_tbl(i).operation = fnd_api.g_miss_char then
		l_line_adj_Att_tbl.delete(i);
	Elsif l_line_adj_Att_tbl(i).price_adjustment_id = fnd_api.g_miss_num or
		l_line_adj_Att_tbl(i).price_adjustment_id is null Then

		-- Check if the adjustment record exists
		If l_line_adj_Att_tbl(i).Adj_Index = fnd_api.g_miss_num Then
			l_line_adj_Att_tbl.delete(i);
		ElsIf Not l_line_adj_tbl.exists(l_line_adj_Att_tbl(i).Adj_Index) Then
			l_line_adj_Att_tbl.delete(i);
		End If;

	end if;

	i:= l_line_adj_att_tbl.next(i);

   End loop;


   G_STMT_NO := 'process_adjustments#160';
  i:= l_Line_Adj_Assoc_tbl.First;
  While i is not null loop
        If G_Debug Then
	 adj_debug('Assocs: adj index '||l_Line_Adj_Assoc_tbl(i).adj_index,3);
	 adj_debug('Assocs: rltd adj index '||l_Line_Adj_Assoc_tbl(i).Rltd_Adj_Index,3);
	 adj_debug('Assocs: price adj '||l_Line_Adj_Assoc_tbl(i).price_adjustment_id,3);
	 adj_debug('Assocs: rltd price adj '||l_Line_Adj_Assoc_tbl(i).rltd_Price_Adj_Id,3);
	 adj_debug('---------------------------',3);
        End If;
	If l_Line_Adj_Assoc_tbl(i).operation = Fnd_Api.g_Miss_Char Then
		l_Line_Adj_Assoc_tbl.delete(i);
	Else
		if l_Line_Adj_Assoc_tbl(i).Price_Adjustment_Id = fnd_Api.g_miss_num and
			l_Line_Adj_Assoc_tbl(i).adj_index = fnd_Api.g_miss_num Then
					l_Line_Adj_Assoc_tbl.delete(i);
		Elsif   l_Line_Adj_Assoc_tbl(i).Adj_Index <> fnd_Api.g_miss_num and
				Not l_line_adj_tbl.exists(l_Line_Adj_Assoc_tbl(i).Adj_Index) Then
			l_Line_Adj_Assoc_tbl.delete(i);
		Elsif	l_Line_Adj_Assoc_tbl(i).rltd_Price_Adj_Id = fnd_Api.g_miss_num and
			l_Line_Adj_Assoc_tbl(i).Rltd_Adj_Index = fnd_Api.g_miss_num Then
			l_Line_Adj_Assoc_tbl.delete(i);
		Elsif l_Line_Adj_Assoc_tbl(i).Rltd_Adj_Index <> fnd_Api.g_miss_num and
			Not l_line_adj_tbl.exists(l_Line_Adj_Assoc_tbl(i).Rltd_Adj_Index) Then
                IF l_line_detail_replaced.exists(l_line_adj_assoc_tbl(i).rltd_adj_index) THEN
                      l_line_adj_assoc_tbl(i).rltd_adj_index
                          := l_line_detail_replaced(l_line_adj_assoc_tbl(i).rltd_adj_index);
                 ELSE
                    l_Line_Adj_Assoc_tbl.delete(i);
                 END IF;
		End If;
	End If;
	i:= l_Line_Adj_Assoc_tbl.next(i);
  End Loop;

   G_STMT_NO := 'process_adjustments#170.0';
        If G_Debug Then
	 adj_debug('Header id '||l_header_rec.header_id);
	 adj_debug('payment term '||l_header_rec.payment_term_id);
	 adj_debug('Ship term '||l_header_rec.shipping_method_code);
	 adj_debug('Freight  term '||l_header_rec.freight_terms_code);
	 adj_debug('operantion  '||l_header_rec.operation);
	 adj_debug('---------------------------');
        End If;

   G_STMT_NO := 'process_adjustments#170';
End If;  --end if for p_write_to_db mode

  -- Audit Trail reason code passed #3006072 */

  adj_debug('Line final table count is : '||l_line_tbl_final.count);

  IF l_line_tbl_final.count > 0 THEN

     FOR rec_cnt in l_line_tbl_final.first..l_line_tbl_final.last LOOP

         adj_debug('Line ID processed : '||l_line_tbl_final(rec_cnt).line_id);

         l_line_tbl_final(rec_cnt).change_reason := 'SYSTEM';
         l_line_tbl_final(rec_cnt).change_comments := 'PRICING';

     END LOOP;

  END IF;

  -- bug 2404990 begin
  x_line_tbl := l_line_tbl_final;
  IF (p_write_to_db and l_num_changed_lines<1+l_line_tbl_final.count/2) THEN
                j:= l_Line_Tbl_Final.first;
                while j is not null loop
                   IF (l_line_tbl_final(j).operation = OE_GLOBALS.G_OPR_NONE) THEN
                     l_line_tbl_Final.delete(j);
                   END IF;
                 j:= l_Line_Tbl_Final.next(j);
                end loop;

  End If;  --end if for p_write_to_db mode
  -- bug 2404990 end


  If p_Write_To_Db  and
	(	l_line_tbl_Final.count > 0 or
		l_Line_Adj_tbl.count > 0 or
		l_Line_Adj_att_tbl.count > 0 or
		l_Line_Adj_Assoc_tbl.count > 0
	 )
	Then


   -- set control record
   l_control_rec.controlled_operation := TRUE;
   l_control_rec.write_to_DB          := TRUE;
   l_control_rec.change_attributes    := TRUE;
   l_control_rec.default_attributes   := TRUE;
   l_control_rec.validate_entity      := TRUE;
   l_control_rec.clear_dependents     := TRUE;
   --change made for bug 2351099    Begin
   --2366123: execute delayed requests if not from UI
   if (NOT OE_GLOBALS.G_UI_FLAG ) then
    l_control_rec.process   := TRUE;
   else
     l_control_rec.process  := FALSE;
   end if;
   --change made for bug 2351099    End
   l_control_rec.clear_api_cache      := FALSE;
   l_control_rec.clear_api_requests   := FALSE;


    --  Call OE_Order_PVT.Process_order

	adj_debug('Before OE_Order_PVT.Process_order',1);
   IF (oe_globals.G_CASCADING_REQUEST_LOGGED) THEN
     adj_debug('inside price line: cascading set');
   ELSE
     adj_debug('inside price line: cascading not set');
   END IF;
	--  OE_Globals.G_RECURSION_MODE := 'Y';
	 OE_Globals.G_PRICING_RECURSION := 'Y';

		G_STMT_NO := 'Failure in Process_Order API Call';
  --cc1
  IF (p_Req_Control_Rec.pricing_event = 'PRICE' AND
     l_Line_Adj_tbl.count = 0 AND
     l_Line_Adj_att_tbl.count = 0 AND
     l_Line_Adj_Assoc_tbl.count = 0
   ) THEN
    OE_ORDER_PVT.Lines
    (   p_validation_level            => FND_API.G_VALID_LEVEL_FULL
    ,   p_control_rec                 => l_control_rec
    ,   p_x_line_tbl                    => l_line_tbl_Final
    ,   p_x_old_line_tbl                => l_old_line_tbl
    ,   x_return_status                => x_return_status
    );

    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
		RAISE FND_API.G_EXC_ERROR;
	END IF;

  ELSE
    OE_Order_PVT.Process_order
    (   p_api_version_number          => 1.0
    ,   x_return_status               => x_return_status
    ,   x_msg_count                   => l_x_msg_count
    ,   x_msg_data                    => l_x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_x_Header_rec                    => l_header_rec
    ,   p_x_line_tbl                    => l_line_tbl_Final
    ,   p_x_Line_Adj_tbl                => l_Line_Adj_tbl
    ,   p_x_Line_Adj_att_tbl            => l_Line_Adj_att_tbl
    ,   p_x_Line_Adj_Assoc_tbl          => l_Line_Adj_Assoc_tbl
    ,   p_old_line_tbl                => l_old_line_tbl
--    ,   x_header_rec                  => l_x_header_rec
    ,   p_x_Header_Adj_tbl              => l_x_Header_Adj_tbl
    ,   p_x_header_price_att_tbl        => l_x_header_price_att_tbl
    ,   p_x_Header_Adj_att_tbl          => l_x_Header_Adj_att_tbl
    ,   p_x_Header_Adj_Assoc_tbl        => l_x_Header_Adj_Assoc_tbl
    ,   p_x_Header_Scredit_tbl          => l_x_Header_Scredit_tbl
--serla begin
    ,   p_x_Header_Payment_tbl          => l_x_Header_Payment_tbl
--serla end
--    ,   x_line_tbl                    => l_x_line_tbl
--    ,   x_Line_Adj_tbl                => l_x_Line_Adj_tbl
    ,   p_x_Line_Price_att_tbl          => l_x_Line_Price_att_tbl
--    ,   x_Line_Adj_att_tbl            => l_x_Line_Adj_att_tbl
--    ,   x_Line_Adj_Assoc_tbl          => l_x_Line_Adj_Assoc_tbl
    ,   p_x_Line_Scredit_tbl            => l_x_Line_Scredit_tbl
--serla begin
    ,   p_x_Line_Payment_tbl            => l_x_Line_Payment_tbl
--serla end
    ,   p_x_Lot_Serial_tbl              => l_x_Lot_Serial_Tbl
    ,   p_x_action_request_tbl	      => l_x_Action_Request_tbl
    );

     -- OE_Globals.G_RECURSION_MODE := 'N';
     OE_Globals.G_PRICING_RECURSION := 'N';

    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
		RAISE FND_API.G_EXC_ERROR;
    END IF;

END IF;

 G_STMT_NO := 'process_adjustments#140';
/*
 -- Process Requests for Pricing line (for new line created for PRG)
    OE_DELAYED_REQUESTS_PVT.Process_Request_for_Reqtype
         (p_request_type   =>OE_GLOBALS.G_PRICE_LINE
          ,p_delete        => FND_API.G_TRUE
          ,x_return_status => x_return_status
          );
    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
    END IF;
*/
  End If;

--	x_Line_Tbl	 := l_Line_Tbl_Final;
	G_STMT_NO := 'process_adjustments#150';

         -- Performance change for Legato
         -- Not refresh order when no attributes changed
         -- Freight charge change doesn't result in line change
         If p_req_control_rec.pricing_event in ('ORDER','SHIP','BOOK', 'BATCH') then
           IF (l_num_changed_lines > 0) THEN
            adj_debug('setting cascading flag to refresh order');
            OE_GLOBALS.G_CASCADING_REQUEST_LOGGED := TRUE;
           END IF;
         Elsif INSTR(p_req_control_rec.pricing_event,'ORDER') > 0  or
               INSTR(p_req_control_rec.pricing_event,'BOOK')  > 0  or
               INSTR(p_req_control_rec.pricing_event,'BATCH')  > 0  or
               INSTR(p_req_control_rec.pricing_event,'SHIP')  > 0  then
           IF (l_num_changed_lines > 0) THEN
            adj_debug(' multiple events setting cascading flag to refresh order');
            OE_GLOBALS.G_CASCADING_REQUEST_LOGGED := TRUE;
           END IF;
         End if;

	adj_debug('Exiting oe_order_Adj_pvt.process_adjustments',1);


    EXCEPTION

	    WHEN FND_API.G_EXC_ERROR THEN

		  x_return_status := FND_API.G_RET_STS_ERROR;
			adj_debug('		exc_error'||g_stmt_no||' '||sqlerrm||' '||l_x_msg_data,1);
                        -- OE_Globals.G_RECURSION_MODE := 'N';
                        OE_Globals.G_PRICING_RECURSION := 'N';

			RAISE FND_API.G_EXC_ERROR;
		WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

			x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
			adj_debug('		'||g_stmt_no||' '||sqlerrm||' '||l_x_msg_data,1);

                        -- OE_Globals.G_RECURSION_MODE := 'N';
                        OE_Globals.G_PRICING_RECURSION := 'N';
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

		WHEN OTHERS THEN

			x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
			--dbms_output.put_line('Error is '||sqlerrm);
			adj_debug('Error in oe_order_Adj_pvt.process_adjustments',1);
			adj_debug('		'||g_stmt_no||' '||sqlerrm,1);

			IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
			THEN
				OE_MSG_PUB.Add_Exc_Msg
				(   G_PKG_NAME
				,   'oe_order_Adj_pvt.process_adjustments',
					g_stmt_no||' '||sqlerrm
				);
			END IF;

                        -- OE_Globals.G_RECURSION_MODE := 'N';
                        OE_Globals.G_PRICING_RECURSION := 'N';
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

end process_adjustments;

Procedure Populate_Pricing_Phases(p_pricing_event in Varchar2) Is

Cursor get_phases(l_event_code1 in Varchar2) Is
 Select e.Pricing_Phase_Id,nvl(p.user_freeze_override_flag,p.freeze_override_flag) freeze_override_flag
		   from qp_event_Phases e, qp_pricing_phases p
		   where e.pricing_phase_id = p.pricing_phase_id and
		   trunc(sysdate) between Trunc(nvl(start_date_active,sysdate)) and
			 trunc(nvl(End_Date_Active,sysdate))
                       and e.pricing_event_code IN
                    (SELECT decode(rownum
          ,1 ,substr(p_pricing_event,1,instr(l_event_code1,',',1,1)-1)
          ,2 ,substr(p_pricing_event , instr(l_event_code1,',',1,rownum-1) + 1,
             instr(l_event_code1,',',1,rownum)-1 - instr(l_event_code1,',',1,rownum-1))
          ,3 ,substr(p_pricing_event , instr(l_event_code1,',',1,rownum-1) + 1,
              instr(l_event_code1,',',1,rownum)-1 - instr(l_event_code1,',',1,rownum-1))
          ,4 ,substr(p_pricing_event , instr(l_event_code1,',',1,rownum-1) + 1,
              instr(l_event_code1,',',1,rownum)-1 - instr(l_event_code1,',',1,rownum-1))
          ,5 ,substr(p_pricing_event , instr(l_event_code1,',',1,rownum-1) + 1,
              instr(l_event_code1,',',1,rownum)-1 - instr(l_event_code1,',',1,rownum-1))
          ,6 ,substr(p_pricing_event , instr(l_event_code1,',',1,rownum-1) + 1,
              instr(l_event_code1,',',1,rownum)-1 - instr(l_event_code1,',',1,rownum-1)))
         FROM  qp_event_phases
         WHERE rownum < 7);
Begin

G_Pricing_Phase_Id_Tbl.delete;
  --null;
 For i in get_phases(p_pricing_event||',') Loop
  G_Pricing_Phase_id_Tbl(i.pricing_phase_id):=i.freeze_override_flag;
  adj_debug('Pricing Phase:'||i.pricing_phase_id);
  adj_debug('Freeze Override:'||i.freeze_override_flag);
 End Loop;
End;

Function Bypass_Performance_Path(
  p_Header_id        Number Default Null
, p_Line_id          Number Default Null
, px_line_tbl         IN OUT NOCOPY OE_Order_Pub.Line_Tbl_Type
) Return Boolean
IS
l_source_document_type_id NUMBER;
l_booked_flag Varchar2(1);
l_header_rec OE_Order_PUB.Header_Rec_Type;
l_header_id NUMBER;
l_tmp_no number;
Begin

  IF OE_GLOBALS.G_GMI_INSTALLED IS NULL THEN -- OPM 2547940 start GMA = OPM
      OE_GLOBALS.G_GMI_INSTALLED := OE_GLOBALS.CHECK_PRODUCT_INSTALLED(550);
  END IF;

  If (OE_GLOBALS.G_GMI_INSTALLED = 'Y')
                and nvl(OE_LINE_ADJ_UTIL.G_OPM_ITEM_CATCHWEIGHT_USED,'N') = 'Y'   -- bug 2965218
  Then
      adj_debug('OPM - GMA installed');
      RETURN TRUE;
  End If;   -- OPM 2547940 end


  IF OE_GLOBALS.G_ASO_INSTALLED IS NULL THEN
      OE_GLOBALS.G_ASO_INSTALLED := OE_GLOBALS.CHECK_PRODUCT_INSTALLED(697);
  END IF;

  If (OE_GLOBALS.G_ASO_INSTALLED = 'N') Then
    adj_debug('aso not installed');
    RETURN FALSE;
  End If;

  IF (nvl(fnd_profile.value('ONT_ALWAYS_PERF_PATH'), 'N') = 'Y') THEN
    adj_debug('always use performance path');
    RETURN FALSE;
  END IF;

  -- ASO installed; check whether it's a CRM order
  If (p_Header_id Is Not Null AND p_header_id <> FND_API.G_MISS_NUM) Then
      adj_debug('query source document type for header :'||p_header_id);
     OE_Header_Util.Query_Row(p_header_id => p_header_id
                            , x_header_rec => l_header_rec);
      l_source_document_type_id := l_header_rec.source_document_type_id;
      l_booked_flag := l_header_rec.booked_flag;
      l_header_id := p_header_id;
  Else
    if (px_line_tbl.count = 0 and (p_line_id is Null OR p_line_id = FND_API.G_MISS_NUM)) Then

		IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
		THEN

		    FND_MESSAGE.SET_NAME('ONT','OE_ATTRIBUTE_REQUIRED');
		    FND_MESSAGE.SET_TOKEN('ATTRIBUTE','line_id or Header Id ');
		    OE_MSG_PUB.Add;
		END IF;
		RAISE FND_API.G_EXC_ERROR;
    elsif (px_line_Tbl.count = 0) Then
     OE_Line_Util.Query_Rows(p_line_id => p_line_id
                            , x_line_tbl => px_line_tbl);
    end if;
    adj_debug('lines count'||px_line_tbl.count);
    l_source_document_type_id := px_line_Tbl(1).source_document_type_id;
    l_booked_flag := px_line_Tbl(1).booked_flag;
    l_header_id := px_line_tbl(1).header_id;
  End If;

  adj_debug('source_document_type:'||l_source_document_type_id);
  If (nvl(l_booked_flag, 'N') = 'Y'
      and nvl(l_source_document_type_id, 0) IN (1, 3, 4, 7, 8, 11, 12, 13, 14, 15, 16, 17, 18 , 19))
  Then
      adj_debug('booked CRM order');
      Return TRUE;
  Elsif (nvl(l_booked_flag, 'N') = 'Y')  --begin 2608577
  Then
     -- check whether there is an AMS modifier defined
      adj_debug('in ams mod check ');
     BEGIN
       SELECT 1 into l_tmp_no from dual where exists (
        select 1 from qp_list_headers_b qh
        , oe_order_headers_all oh
        where qh.currency_code = oh.transactional_curr_code
        and oh.header_id =  l_header_id
        and qh.source_system_code='AMS'
        and qh.active_flag = 'Y');
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         RETURN FALSE;
       WHEN OTHERS THEN
         NULL;
     END;
     RETURN TRUE;    -- end 2608577
  Else
      Return FALSE;
  End If;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  WHEN OTHERS THEN
   adj_debug('error in bypass_performance_path'||sqlerrm);
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
End Bypass_Performance_Path;

Procedure Price_line(
X_Return_Status out nocopy Varchar2

		,p_Line_id          	Number	Default Null
		,p_Header_id        	Number 	Default Null
		,p_Request_Type_code	Varchar2
		,p_Control_Rec			QP_PREQ_GRP.control_record_type
		,p_write_to_db			Boolean 	Default TRUE
		,p_request_rec          OE_Order_PUB.request_rec_type default oe_order_pub.G_MISS_REQUEST_REC
		,x_line_Tbl		in out nocopy oe_Order_Pub.Line_Tbl_Type
		,p_honor_price_flag		VARCHAR2	Default 'Y'
                ,p_multiple_events       in Varchar2 default 'N'
                ,p_action_code          in Varchar2 default Null
		)
is
l_return_status 			varchar2(10);
l_Control_Rec                 QP_PREQ_GRP.CONTROL_RECORD_TYPE;
l_req_line_tbl                QP_PREQ_GRP.LINE_TBL_TYPE;
l_Req_qual_tbl                QP_PREQ_GRP.QUAL_TBL_TYPE;
l_Req_line_attr_tbl           QP_PREQ_GRP.LINE_ATTR_TBL_TYPE;
l_Req_LINE_DETAIL_tbl         QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE;
l_Req_LINE_DETAIL_qual_tbl    QP_PREQ_GRP.LINE_DETAIL_QUAL_TBL_TYPE;
l_Req_LINE_DETAIL_attr_tbl    QP_PREQ_GRP.LINE_DETAIL_ATTR_TBL_TYPE;
l_Req_related_lines_tbl       QP_PREQ_GRP.RELATED_LINES_TBL_TYPE;
lx_Header_Rec				oe_Order_Pub.Header_REc_Type;
l_dummy varchar2(1);
l_any_frozen_line Boolean;
l_price_control_rec           OE_ORDER_PRICE_pvt.control_rec_type;
--For bug#2675212
i pls_integer;
l_call_process_adjustments varchar2(1) := 'N';
cursor check_lines is
  select 'x' from qp_event_phases ep
  where ep.pricing_event_code = p_control_rec.pricing_event
  and trunc(sysdate) between trunc(nvl(start_date_active, sysdate)) and
				  trunc(nvl(end_date_active, sysdate));
/*cursor check_lines2 is
  select 'x' from qp_event_phases ep
  where ep.pricing_event_code IN ('BATCH','BOOK','SHIP')
  and trunc(sysdate) between trunc(nvl(start_date_active, sysdate)) and
				  trunc(nvl(end_date_active, sysdate));*/

cursor check_lines2 is
  select 'x' from qp_event_phases ep
  where instr(p_control_rec.pricing_event||',',
ep.pricing_event_code||',') > 0
  and trunc(sysdate) between trunc(nvl(start_date_active, sysdate)) and
                                  trunc(nvl(end_date_active, sysdate));

l_multiple_events VARCHAR2(1);
cursor unfrozen_lines is
  select 'x' from dual where
   exists (select 'x' from oe_order_lines where header_id = p_header_id
           and calculate_price_flag in ('Y','P'));
begin
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --btea perf begin
   If OE_DEBUG_PUB.G_DEBUG = FND_API.G_TRUE Then
    G_DEBUG := TRUE;
    adj_debug('Entering  oe_order_Adj_pvt.Price_line',1);
    adj_debug('Version:'||get_version);
   Else
    G_DEBUG := FALSE;
   End If;
   --btea perf end


Populate_Pricing_Phases(p_control_rec.pricing_event);

IF (INSTR(p_control_rec.pricing_event, ',') > 0) THEN
 l_multiple_events := 'Y';
ELSE
 l_multiple_events := 'N';
END IF;

If l_multiple_events = 'N' Then
  open check_lines;
  fetch check_lines into l_dummy;
  IF check_lines%NOTFOUND THEN
    close check_lines;
    RETURN;
  End If;
Else
  Oe_Debug_Pub.add('In Multiple events');
  open check_lines2;
  fetch check_lines2 into l_dummy;
  IF check_lines2%NOTFOUND THEN
    close check_lines2;
    RETURN;
  End If;
END IF;

  -- 2378843: check the existence of any line with 'Partial Price' or 'Calculate Price'
  IF (p_header_id IS NOT NULL and p_honor_price_flag = 'Y' and p_control_rec.pricing_event <> 'SHIP') THEN
    open unfrozen_lines;
    fetch unfrozen_lines into l_dummy;
    IF unfrozen_lines%NOTFOUND THEN
      close unfrozen_lines;
      adj_debug('all lines frozen, returning from price_line');
      RETURN;
    END IF;
    close unfrozen_lines;
  END IF;
  -- End 2378843

  IF (G_11IG_PERFORMANCE = 'Y' AND QP_UTIL_PUB.Basic_Pricing_Setup = 'Y'
  AND Not Bypass_Performance_Path(  p_header_id => p_header_id
                                  , p_line_id   => p_line_id
                                  , px_line_Tbl  => x_line_tbl))
   OR OE_CODE_CONTROL.Get_Code_Release_Level >= '110509' THEN
  l_price_control_rec.p_request_type_code:=p_request_type_code;
  l_Price_control_rec.p_write_to_db:=p_write_to_db;
  l_price_control_rec.p_honor_price_flag:=p_honor_price_flag;
  l_price_control_rec.p_multiple_events:=l_multiple_events;
  l_price_control_rec.p_get_freight_flag := p_Control_rec.get_freight_flag;

  oe_order_price_pvt.price_line
                 (p_Header_id    => p_Header_id
                 ,p_Line_id             =>p_Line_id
                 ,px_line_Tbl           =>x_line_tbl
                 ,p_Control_Rec         =>l_price_control_rec
                 ,p_action_code         =>p_action_code
                 ,p_Pricing_Events      =>p_Control_rec.pricing_event
                 ,p_request_rec          =>p_request_rec
                 ,x_Return_Status       =>l_return_status
                 );

  If nvl(l_return_status,'x-x') NOT IN (FND_API.G_RET_STS_UNEXP_ERROR,FND_API.G_RET_STS_ERROR) Then
     l_return_status:=FND_API.G_RET_STS_SUCCESS;
  End If;

-- added for HVOP Tax project
 IF OE_BULK_ORDER_PVT.G_HEADER_REC.HEADER_ID.COUNT > 0 THEN
     OE_BULK_PRICE_PVT.Update_Pricing_Attributes(p_line_tbl => x_line_tbl);
 END IF;


  x_return_status := l_return_status;
  RETURN;
END IF;


adj_debug('Exiting oe_order_Adj_pvt.Price_line',1);



	Exception
	    WHEN FND_API.G_EXC_ERROR THEN

		  x_return_status := FND_API.G_RET_STS_ERROR;

                --Bug 7566697
                adj_debug('Setting prcing error flag for mass change');
                OE_MASS_CHANGE_PVT.G_PRICING_ERROR := 'Y';

		adj_debug('Exiting oe_order_Adj_pvt.Price_line',1);
		WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

			x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                        --Bug 7566697
                        adj_debug('Setting prcing error flag for mass change');
                        OE_MASS_CHANGE_PVT.G_PRICING_ERROR := 'Y';

			adj_debug('Exiting oe_order_Adj_pvt.Price_line',1);
	    WHEN OTHERS THEN

			x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
			adj_debug('Error in oe_order_Adj_pvt.Price_line',1);
			adj_debug(sqlerrm,1);

			IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
			THEN
				OE_MSG_PUB.Add_Exc_Msg
				(   G_PKG_NAME
				,   'Price_line',
					sqlerrm
				);
			END IF;

                        --Bug 7566697
                        adj_debug('Setting prcing error flag for mass change');
                        OE_MASS_CHANGE_PVT.G_PRICING_ERROR := 'Y';

			adj_debug('Exiting oe_order_Adj_pvt.Price_line',1);
			--RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

End Price_line;

Procedure Price_Adjustments(
X_Return_Status out nocopy Varchar2

	,p_Header_id             Number    DEfault null
	,p_Line_id               Number    DEfault null
	,p_request_type_code	varchar2
	,p_request_rec          OE_Order_PUB.request_rec_type default oe_order_pub.G_MISS_REQUEST_REC

)
is
l_Req_Control_Rec             QP_PREQ_GRP.CONTROL_RECORD_TYPE;
l_control_rec				Oe_Globals.Control_rec_type;
l_Line_tbl            		OE_Order_PUB.Line_tbl_type;
l_old_Line_tbl                  OE_Order_PUB.Line_tbl_type;
l_Line_tbl1            		OE_Order_PUB.Line_tbl_type;
l_Line_Adj_Att_tbl            OE_Order_PUB.Line_Adj_Att_tbl_type;
l_Line_Adj_tbl                OE_Order_PUB.Line_Adj_Tbl_Type;
l_Old_Line_Adj_tbl            OE_Order_PUB.Line_Adj_Tbl_Type;
l_Line_Adj_Assoc_tbl          OE_Order_PUB.Line_Adj_Assoc_tbl_type;
l_dummy_adj_assoc_tbl         OE_Order_PUB.line_adj_assoc_tbl_type;
l_header_rec                  OE_Order_PUB.Header_Rec_Type;
l_x_header_rec                OE_Order_PUB.Header_Rec_Type;
l_x_Header_Adj_tbl            OE_Order_PUB.Header_Adj_Tbl_Type;
l_x_Header_Scredit_tbl        OE_Order_PUB.Header_Scredit_Tbl_Type;
--l_x_line_tbl                  OE_Order_PUB.Line_Tbl_Type;
--l_x_Line_Adj_tbl              OE_Order_PUB.Line_Adj_Tbl_Type;
l_x_Line_Scredit_tbl          OE_Order_PUB.Line_Scredit_Tbl_Type;
l_x_action_request_tbl        OE_Order_PUB.request_tbl_type;
l_x_lot_serial_tbl            OE_Order_PUB.lot_serial_tbl_type;
l_x_Header_price_Att_tbl      OE_Order_PUB.Header_price_Att_tbl_type;
l_x_Header_Adj_Att_tbl        OE_Order_PUB.Header_Adj_Att_tbl_type;
l_x_Header_Adj_Assoc_tbl      OE_Order_PUB.Header_Adj_Assoc_tbl_type;
l_x_Line_price_Att_tbl        OE_Order_PUB.Line_price_Att_tbl_type;
l_x_Line_Adj_Att_tbl          OE_Order_PUB.Line_Adj_Att_tbl_type;
l_x_Line_Adj_Assoc_tbl        OE_Order_PUB.Line_Adj_Assoc_tbl_type;
l_x_msg_count                   number;
l_x_msg_data                    Varchar2(2000);
i						pls_integer;
l_line_index				pls_integer;
l_allow_negative_price		Varchar2(30) := nvl(fnd_profile.value('ONT_NEGATIVE_PRICING'),'N');
--Manual Begin
--Set calculate price flag to 'P'  when manual adjustment is applied
l_set_price_flag_on_manual   Varchar2(30) := nvl(fnd_profile.value('ONT_SET_PRICE_FLAG_ON_MANUAL'),'N');
--Manual End
l_dummy key_tbl_type;
l_updated_flag varchar2(1);
l_dummy_line_rec Oe_Order_Pub.Line_Rec_Type;
l_price_control_rec OE_ORDER_PRICE_PVT.CONTROL_REC_TYPE;
x_line_tbl oe_order_pub.line_tbl_type;
l_status_code Varchar2(5);
l_item_rec                    OE_ORDER_CACHE.item_rec_type; -- OPM 2547940
--serla begin
l_x_Header_Payment_tbl        OE_Order_PUB.Header_Payment_Tbl_Type;
l_x_Line_Payment_tbl          OE_Order_PUB.Line_Payment_Tbl_Type;
--serla end
begin

	adj_debug('Entering oe_order_Adj_pvt.Price_adjustments',1);

   --btea perf begin
   If OE_DEBUG_PUB.G_DEBUG = FND_API.G_TRUE Then
    G_DEBUG := TRUE;
    adj_debug('BCT G_DEBUG IS:'||OE_DEBUG_PUB.G_DEBUG );
   Else
    G_DEBUG := FALSE;
   End If;
   --btea perf end



  IF OE_GLOBALS.G_ASO_INSTALLED IS NULL THEN
      OE_GLOBALS.G_ASO_INSTALLED := OE_GLOBALS.CHECK_PRODUCT_INSTALLED(697);
  END IF;

   IF OE_GLOBALS.G_GMI_INSTALLED IS NULL THEN -- OPM 2547940
      OE_GLOBALS.G_GMI_INSTALLED := OE_GLOBALS.CHECK_PRODUCT_INSTALLED(550);
   END IF;


  IF (OE_GLOBALS.G_ASO_INSTALLED = 'N'    AND
     OE_GLOBALS.G_GMI_INSTALLED = 'N'     AND -- OPM 2547940
    G_11IG_PERFORMANCE = 'Y'              AND
    QP_UTIL_PUB.Basic_Pricing_Setup = 'Y' AND
    nvl(p_request_rec.param1,'XX') <> 'UI') OR
OE_CODE_CONTROL.Get_Code_Release_Level >= '110509'
  THEN
  l_price_control_rec.p_request_type_code:=p_request_type_code;
  l_price_control_rec.p_calculate_flag := QP_PREQ_GRP.G_CALCULATE_ONLY;
  IF (p_line_id IS NOT NULL and nvl(p_request_rec.param1,'XX') = 'UI') THEN
    l_price_control_rec.p_honor_price_flag := 'N';
  END IF;
  oe_order_price_pvt.price_line
                 (p_Header_id    => p_Header_id
                ,p_Line_id             =>p_Line_id
                ,px_line_Tbl           =>x_line_tbl
                ,p_Control_Rec         =>l_price_control_rec
                ,p_Pricing_Events      =>NULL
                ,x_Return_Status       =>x_return_status
                );
  RETURN;
END IF;
	-- Query Line Record

l_Req_Control_Rec.Simulation_Flag := 'N';

	If p_header_id is null then

               oe_line_util.query_rows(
                 p_line_id => p_line_id
               , x_line_tbl => l_line_tbl1
               );

               OE_Header_Util.Query_Row(
                   p_header_id => l_Line_Tbl1(1).header_id
                ,  x_header_rec => l_header_rec
                );
	Else

                OE_Header_Util.Query_Row(
                   p_header_id => p_header_id
                ,  x_header_rec  => l_header_rec
                );

              oe_line_util.query_rows(
                 p_header_id => p_header_id
              ,  x_line_tbl => l_Line_Tbl1
              );
	end if;
 g_order_currency := l_header_rec.transactional_curr_code; --bug 2595626

        oe_debug_pub.add(' Param1 UI Flag value:'|| p_request_rec.param1);
	l_line_index := l_Line_Tbl1.First;
	While l_line_index is not null loop  -- Retain the ones with calculate_price_flag=Y'
               /* Added elsif condition so that price is calculated even if price flag is N
                  when request is logged for a line */
		If nvl(l_Line_Tbl1(l_line_index).calculate_price_flag,'Y') in ('Y','P') then
			l_Line_Tbl(l_Line_Tbl.count+1) := l_Line_Tbl1(l_line_index);
                Elsif p_line_id is not NULL
                      and l_Line_Tbl1(l_line_index).line_id = p_line_id
                      and p_request_rec.param1 = 'UI' Then  --bug 2354465
                      l_Line_Tbl(l_Line_Tbl.count+1) :=l_Line_Tbl1(l_line_index);
		end if;
		l_line_index := l_Line_Tbl1.Next(l_line_index);
	end loop;

	l_line_index := l_Line_Tbl.First;

	While l_line_index is not null loop
	-- Query the Adjustments

         -- added by lkxu
	    l_line_tbl(l_line_index).operation := OE_GLOBALS.G_OPR_UPDATE;

		append_Adjustment_lines(p_line_id	=> l_Line_Tbl(l_line_index).line_id,
				px_line_adj_tbl	=>	l_Line_Adj_Tbl
                                ,px_line_key_tbl        => l_dummy
                                ,px_header_key_tbl      => l_dummy
                                ,px_line_adj_assoc_tbl  =>l_dummy_adj_assoc_tbl
                                ,px_line_rec            => l_line_tbl(l_line_index)
                                , x_updated_flag        =>l_updated_flag);

                 If (l_updated_flag = 'Y' and l_line_tbl(l_line_index).calculate_price_flag = 'Y') THEN
                    If l_set_price_flag_on_manual = 'Y' Then
                     l_line_tbl(l_line_index).calculate_price_flag := 'P';
                   End If;
                 End if;
	l_line_index := l_Line_Tbl.next(l_line_index);
	End loop;

	append_Adjustment_Lines(p_header_id => l_header_rec.header_id
				,px_Line_Adj_Tbl 	=> l_line_adj_Tbl
                                ,px_line_key_tbl        => l_dummy
                                ,px_header_key_tbl      => l_dummy
                                ,px_line_adj_assoc_tbl  => l_dummy_adj_assoc_tbl
                                ,px_line_rec            => l_dummy_line_rec
                                ,x_updated_flag => l_updated_flag);

	l_old_line_adj_tbl := l_line_adj_tbl;

	-- Query the assocs
	i:= l_Line_Adj_Tbl.First;
	While I is not null loop
		Query_Adj_Assocs(
			p_price_adjustment_id=> l_line_adj_Tbl(i).price_adjustment_id,
			p_Adj_Index         => i,
			p_Line_Adj_Assoc_Tbl     => l_line_adj_Assoc_tbl,
                        p_delete_flag  =>  'N');

                oe_debug_pub.add('xPrice_Adj query assocs-adj_id:'|| l_line_adj_Tbl(i).price_adjustment_id);
                oe_debug_pub.add('xAdj asso count:'||l_line_adj_Assoc_tbl.count);
		i:= l_Line_Adj_Tbl.Next(i);
	End loop;

        --Performance change: To update only changed lines
        l_old_line_tbl := l_line_tbl;

	--Return;
	Calculate_Price (
		p_Header_Rec            => l_Header_Rec
		,p_Line_Tbl         	=> l_line_Tbl
		,p_Line_Adj_Tbl     	=> l_Line_Adj_Tbl
		,p_line_adj_assoc_Tbl   	=> l_line_adj_assoc_Tbl
		,p_allow_negative_price  => l_allow_negative_price
		,p_request_Type_Code	=> p_request_Type_Code
		)	 ;

     -- lkxu, only retain those records with changed adjusted_amount
	i:= l_Line_Adj_Tbl.First;
	While i is not Null Loop
	  IF OE_GLOBALS.Equal(l_Old_Line_Adj_Tbl(i).adjusted_amount_per_pqty,
				l_Line_Adj_Tbl(i).adjusted_amount_per_pqty) THEN
	    l_Line_Adj_Tbl.delete(i);
       ELSE
            oe_debug_pub.add(' price adj amount:'|| L_Line_Adj_Tbl(i).adjusted_amount);
            L_Line_Adj_Tbl(i).operation := OE_GLOBALS.G_OPR_UPDATE;
       END IF;
	  i:= l_Line_Adj_Tbl.next(i);
     END LOOP;


   -- set control record
   l_control_rec.controlled_operation := TRUE;
   l_control_rec.write_to_DB          := TRUE;
   l_control_rec.change_attributes    := TRUE;
   l_control_rec.default_attributes   := TRUE;
   l_control_rec.validate_entity      := TRUE;
   l_control_rec.clear_dependents     := TRUE;

   l_control_rec.process              := FALSE;
   l_control_rec.clear_api_cache      := FALSE;
   l_control_rec.clear_api_requests   := FALSE;


    --  Call OE_Order_PVT.Process_order

	 -- OE_Globals.G_RECURSION_MODE := 'Y';
	 OE_Globals.G_PRICING_RECURSION := 'Y';


    I:= l_line_tbl.First;
    While I is not null loop

         -- 3129046
         adj_debug('Line ID processed : '||l_line_tbl(i).line_id,1);
         l_line_tbl(i).change_reason := 'SYSTEM';
         l_line_tbl(i).change_comments := 'PRICING';
         adj_debug('Audit Reason passed as '||l_line_tbl(i).change_reason,1);

        -- uom begin
	If oe_line_util.Get_Return_Item_Type_Code(l_line_tbl(i)) in ('INCLUDED', 'CONFIG') then
		l_line_tbl(i).unit_list_price_per_pqty := 0;
                l_line_tbl(i).pricing_quantity := l_line_tbl(i).ordered_quantity;
                l_line_tbl(i).pricing_quantity_uom := l_line_tbl(i).order_quantity_uom;
	end if;

	If l_line_tbl(i).unit_Selling_price_per_pqty is null  or
	oe_line_util.Get_Return_Item_Type_Code(l_line_tbl(i)) in ('INCLUDED', 'CONFIG')
	then
		l_line_tbl(i).unit_Selling_price_per_pqty := l_line_tbl(i).unit_list_price_per_pqty;

	End If;

        If l_line_tbl(i).ordered_quantity IS NOT NULL and l_line_tbl(i).ordered_quantity <> 0
        then
        l_line_tbl(i).unit_selling_price := l_line_tbl(i).unit_selling_price_per_pqty * l_line_tbl(i).pricing_quantity/l_line_tbl(i).ordered_quantity;

        l_line_tbl(i).unit_list_price := l_line_tbl(i).unit_list_price_per_pqty * l_line_tbl(i).pricing_quantity/l_line_tbl(i).ordered_quantity;
        end if;

	  -- OPM 2547940  start - if pricing by quantity2 then if line is shipped and has shipped qty2 != ordered qty2
        --  need to adjust the adjusted_amount so that invoicing will show correct amount (ordered qty * USP (adjusted) )

        IF oe_line_util.dual_uom_control -- invconv
              (l_line_tbl(i).inventory_item_id
              ,l_line_tbl(i).ship_from_org_id
              ,l_item_rec) THEN
                              	IF l_item_rec.ont_pricing_qty_source = 'S'   THEN -- price by quantity 2 -- INVCONV

   				  	IF (l_line_tbl(i).ordered_quantity2 IS NOT NULL and l_line_tbl(i).ordered_quantity2 <> 0	)
                        		AND ( l_line_tbl(i).shipped_quantity2 IS NOT NULL and l_line_tbl(i).shipped_quantity2 <> 0	)
                        		 AND l_line_tbl(i).ordered_quantity2 <> l_line_tbl(i).shipped_quantity2 THEN

                       		     l_line_tbl(i).unit_selling_price := (l_line_tbl(i).unit_selling_price_per_pqty * l_line_tbl(i).pricing_quantity )/l_line_tbl(i).ordered_quantity2
                       		      * (l_line_tbl(i).shipped_quantity2/l_line_tbl(i).ordered_quantity);
                       		      l_line_tbl(i).unit_list_price := (l_line_tbl(i).unit_list_price_per_pqty * l_line_tbl(i).pricing_quantity )/l_line_tbl(i).ordered_quantity2
                       		      * (l_line_tbl(i).shipped_quantity2/l_line_tbl(i).ordered_quantity);

               				 END IF;
               			     END IF;
	END IF;  --oe_line_util.dual_uom_control -- INVCONV
	-- OPM 2547940 end

    oe_debug_pub.add('unit price'||l_line_tbl(i).unit_list_price||'+'||l_line_tbl(i).unit_selling_price,1);
    oe_debug_pub.add('unit price per pqty'||l_line_tbl(i).unit_list_price_per_pqty||'+'||l_line_tbl(i).unit_selling_price_per_pqty,1);

        -- uom end

 -- commented the assigment below and included above to fix bug 2595626
 -- g_order_currency := l_header_rec.transactional_curr_code;


       adj_debug('  Values passed into QP_UTIL_PUB.round_price api:');
       adj_debug('  p_operand:'||l_line_tbl(i).unit_selling_price);
       adj_debug('  price_list_id:'||l_line_tbl(i).price_list_id);
       adj_debug('  currency_code:'||l_header_rec.transactional_curr_code);
       adj_debug('  pricing_effective_date:'||l_line_tbl(i).pricing_date);
       QP_UTIL_PUB.round_price(p_operand                => l_line_tbl(i).unit_selling_price,
			       p_rounding_factor        => NULL,
			       p_use_multi_currency     => 'Y',
			       p_price_list_id          => l_line_tbl(i).price_list_id,
			       p_currency_code          => l_header_rec.transactional_curr_code,
			       p_pricing_effective_date => l_line_tbl(i).pricing_date,
			       x_rounded_operand        => l_line_tbl(i).unit_selling_price,
			       x_status_code            => l_status_code);
       adj_debug(' Rounded Unit Selling Price Returned By pricing API:'||l_line_tbl(i).unit_selling_price);
       adj_debug(' x_status_code:'||l_status_code);


      -- Performance change: not update line if no change
      IF (OE_GLOBALS.Equal(l_line_tbl(i).unit_list_price, l_old_line_tbl(i).unit_list_price) AND
          OE_GLOBALS.Equal(l_line_tbl(i).unit_selling_price, l_old_line_tbl(i).unit_selling_price) AND
          OE_GLOBALS.Equal(l_line_tbl(i).unit_list_price_per_pqty, l_old_line_tbl(i).unit_list_price_per_pqty) AND
          OE_GLOBALS.Equal(l_line_tbl(i).unit_selling_price_per_pqty, l_old_line_tbl(i).unit_selling_price_per_pqty)) THEN
          adj_debug('not updating '||l_line_tbl(i).line_id);
          -- l_line_tbl(i).operation := OE_GLOBALS.G_OPR_NONE;
          l_line_tbl.delete(i);
      ELSE
        OE_GLOBALS.G_CASCADING_REQUEST_LOGGED := TRUE;
      END IF;

     i:= l_line_tbl.next(i);
    end loop;

	adj_debug('Before OE_Order_PVT.Process_order',1);

    OE_Order_PVT.Process_order
    (   p_api_version_number          => 1.0
    ,   x_return_status               => x_return_status
    ,   x_msg_count                   => l_x_msg_count
    ,   x_msg_data                    => l_x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_x_line_tbl                    => l_line_tbl
    ,   p_x_Line_Adj_tbl                => l_Line_Adj_tbl
    ,   p_x_header_rec                  => l_x_header_rec
    ,   p_x_Header_Adj_tbl              => l_x_Header_Adj_tbl
    ,   p_x_header_price_att_tbl        => l_x_header_price_att_tbl
    ,   p_x_Header_Adj_att_tbl          => l_x_Header_Adj_att_tbl
    ,   p_x_Header_Adj_Assoc_tbl        => l_x_Header_Adj_Assoc_tbl
    ,   p_x_Header_Scredit_tbl          => l_x_Header_Scredit_tbl
--serla begin
    ,   p_x_Header_Payment_tbl          => l_x_Header_Payment_tbl
--serla end
--    ,   p_x_line_tbl                    => l_x_line_tbl
--    ,   p_x_Line_Adj_tbl                => l_x_Line_Adj_tbl
    ,   p_x_Line_Price_att_tbl          => l_x_Line_Price_att_tbl
    ,   p_x_Line_Adj_att_tbl            => l_x_Line_Adj_att_tbl
    ,   p_x_Line_Adj_Assoc_tbl          => l_x_Line_Adj_Assoc_tbl
    ,   p_x_Line_Scredit_tbl            => l_x_Line_Scredit_tbl
--serla begin
    ,   p_x_Line_Payment_tbl            => l_x_Line_Payment_tbl
--serla end
    ,   p_x_Lot_Serial_tbl              => l_x_Lot_Serial_Tbl
    ,   p_x_action_request_tbl	      => l_x_Action_Request_tbl
    );


   -- OE_Globals.G_RECURSION_MODE := 'N';
   OE_Globals.G_PRICING_RECURSION := 'N';

    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
		RAISE FND_API.G_EXC_ERROR;
	END IF;

	adj_debug('Exiting oe_order_Adj_pvt.Price_adjustments',1);


    EXCEPTION

	    WHEN FND_API.G_EXC_ERROR THEN

		  x_return_status := FND_API.G_RET_STS_ERROR;
			adj_debug('		'||g_stmt_no||' '||sqlerrm||' '||l_x_msg_data,1);

		WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

			x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
			adj_debug('		'||g_stmt_no||' '||sqlerrm||' '||l_x_msg_data,1);

		WHEN OTHERS THEN

			x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
			--dbms_output.put_line('Error is '||sqlerrm);
			adj_debug('Error in oe_order_Adj_pvt.Price_adjustments',1);
			adj_debug('		'||g_stmt_no||' '||sqlerrm,1);

End Price_Adjustments;

procedure price_action
		(
		 p_selected_records	       Oe_Globals.Selected_Record_Tbl
		,P_price_level	               varchar2
                ,p_header_id                   Number  default null
,x_Return_Status out nocopy varchar2

,x_msg_count out nocopy number

,x_msg_data out nocopy varchar2

		)
is
l_Price_Control_rec		QP_PREQ_GRP.control_record_type;
l_return_status		varchar2(1);
l_x_line_tbl			oe_order_pub.line_tbl_type;
l_line_id				number;
l_header_id			number;
l_delimiter1			number;
l_delimiter2			number;
l_delimiter			number;
l_booked_flag			varchar2(1);
l_multiple_events               Varchar2(1);
l_order_status_rec QP_UTIL_PUB.ORDER_LINES_STATUS_REC_TYPE;
l_prev_line_hdr_id              Number;

cursor has_prg_lines(p_line_id IN NUMBER) is
Select 'Y'
From OE_PRICE_ADJUSTMENTS a,  OE_ORDER_LINES_ALL b
Where b.line_id = p_line_id
AND   b.header_id = a.header_id
And   a.list_line_type_code = 'PRG';

l_has_prg_lines varchar2(1):= 'Q';
--MOAC PI
J                               Number := 1;
L_org_id                        Number;
L_prev_org_id                   Number;
L_prev_hdr_id                   Number;
L_call_pricing                  varchar2(1) := 'N';
last_record_line_id             Number := p_selected_records(p_selected_records.count).id1;
L_new_header                    Boolean;
L_ID3                           Boolean := TRUE;
i                               Number;
--MOAC PI

begin
	adj_debug('Performing Price Action for level '||P_price_level);

	If P_price_level ='LINE' then

		l_Price_Control_Rec.pricing_event := 'LINE';
		l_Price_Control_Rec.calculate_flag := QP_PREQ_GRP.G_SEARCH_N_CALCULATE;
		l_Price_Control_Rec.Simulation_Flag := 'N';
                l_has_prg_lines := 'Q';

                --MOAC PI BEGIN
                oe_debug_pub.add('p_header_id : ' || p_header_id);
                IF p_header_id is not null THEN
                   oe_debug_pub.add('before the loop');
                   i := p_selected_records.first;
                   while I is not null loop
                       L_line_id := p_selected_records(i).id1;
                   --Bug 7330561
  			l_has_prg_lines := 'Q';
			Begin
                   	  open  has_prg_lines(L_line_id);
                   	  fetch has_prg_lines into l_has_prg_lines;
                   	  close has_prg_lines;
                   	Exception
                   	  When no_data_found Then
                   	   l_has_prg_lines:='N';
                   	  When others Then
                   	   l_has_prg_lines:='Y';
                   	End;
                    oe_debug_pub.add('Lalit calling Price Line with l_has_prg_lines-' || l_has_prg_lines );
			    IF l_has_prg_lines = 'Y' THEN
                              oe_order_Adj_pvt.Price_line(
                                    X_Return_Status     => l_Return_Status
                                    ,p_Request_Type_code=> 'ONT'
                                    ,p_Control_rec      => l_Price_Control_Rec
                                    ,p_Write_To_Db      => TRUE
                                    ,p_Line_id          => l_line_id
                                    ,x_Line_Tbl         => l_x_Line_Tbl
                              );
                       ELSE
                              adj_debug('Old price_action way, order has no prg');
                              Begin
                                    l_x_line_tbl(i).Line_id := l_Line_id;
                                    oe_Line_util.query_row(
                                          p_Line_id => l_Line_id
                                       ,  x_line_rec => l_x_Line_Tbl(i)
                                    );
                              Exception when no_data_found then
                                null;
                              End;

                       END IF;
                       i := p_selected_records.next(i);
                   End Loop;
                   IF l_has_prg_lines IN ('N','Q') THEN
                          oe_order_Adj_pvt.Price_line(
                                X_Return_Status     => l_Return_Status
                               ,p_Request_Type_code=> 'ONT'
                               ,p_Control_rec      => l_Price_Control_Rec
                               ,p_Write_To_Db      => TRUE
                               ,x_Line_Tbl         => l_x_Line_Tbl
                           );
                   END IF;

                ELSE
                   i := p_selected_records.first;
                   while i is not null loop
                          oe_debug_pub.add('id1 : ' || p_selected_records(i).id1);
                          oe_debug_pub.add('org_id : ' || p_selected_records(i).org_id);
                          oe_debug_pub.add('id3 : ' || p_selected_records(i).id3);
                          l_line_id := p_selected_records(i).id1;
                          l_org_id := p_selected_records(i).org_id;
                          L_header_id := p_selected_records(i).id3;
                          If  l_prev_org_id is null or l_prev_org_id <> l_org_id Then
                              MO_GLOBAL.set_policy_context(p_access_mode => 'S',  p_org_id => l_Org_Id);
                              l_prev_org_id := l_org_id;
                          End If;
                          L_new_header := FALSE;
                          IF l_prev_hdr_id Is Null Or l_prev_hdr_id <> l_header_id Then
                             L_new_header := TRUE;
                             l_has_prg_lines:='Q';
                             j := 1;
                             l_prev_hdr_id := l_header_id;
                             Begin
                                open  has_prg_lines(l_header_id);
                                fetch has_prg_lines into l_has_prg_lines;
                                close has_prg_lines;
                             Exception
                                When no_data_found Then
                                  l_has_prg_lines:='N';
                                When others Then
                                  l_has_prg_lines:='Y';
                             End;
                          End If;

                          IF l_has_prg_lines = 'Y' THEN
                                oe_order_Adj_pvt.Price_line(
                                    X_Return_Status     => l_Return_Status
                                    ,p_Request_Type_code=> 'ONT'
                                    ,p_Control_rec      => l_Price_Control_Rec
                                    ,p_Write_To_Db      => TRUE
                                    ,p_Line_id          => l_line_id
                                    ,x_Line_Tbl         => l_x_Line_Tbl
                                );
                          ELSE
                             IF (l_new_header or last_record_line_id = l_line_id) and l_x_line_tbl.count > 0 THEN
                                IF last_record_line_id = l_line_id and l_prev_line_hdr_id = l_header_id THEN
                                   Begin
                                              l_x_line_tbl(j).Line_id := l_Line_id;
                                              oe_Line_util.query_row(
                                                    p_Line_id => l_Line_id
                                                 ,  x_line_rec => l_x_Line_Tbl(j)
                                              );
                                   Exception when no_data_found then
                                              null;
                                   End;
                                END IF;

                                oe_order_Adj_pvt.Price_line(
                                            X_Return_Status     => l_Return_Status
                                           ,p_Request_Type_code=> 'ONT'
                                           ,p_Control_rec      => l_Price_Control_Rec
                                           ,p_Write_To_Db      => TRUE
                                           ,x_Line_Tbl         => l_x_Line_Tbl
                                       );

                                IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                                ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                                        RAISE FND_API.G_EXC_ERROR;
                                END IF;

                                L_x_line_tbl.delete;
                             END IF;

                             adj_debug('Old price_action way, order has no prg');
                             Begin
                                      l_x_line_tbl(j).Line_id := l_Line_id;
                                      oe_Line_util.query_row(
                                           p_Line_id => l_Line_id
                                        ,  x_line_rec => l_x_Line_Tbl(j)
                                     );
                                     j := j + 1;
                             Exception when no_data_found then
                                     null;
                             End;
                          END IF;
                          l_prev_line_hdr_id := l_header_id;
                          i := p_selected_records.next(i);
                   End Loop;
                   IF l_x_line_tbl.count > 0 THEN
                                oe_order_Adj_pvt.Price_line(
                                            X_Return_Status     => l_Return_Status
                                           ,p_Request_Type_code=> 'ONT'
                                           ,p_Control_rec      => l_Price_Control_Rec
                                           ,p_Write_To_Db      => TRUE
                                           ,x_Line_Tbl         => l_x_Line_Tbl
                                       );

                                IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                                ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                                        RAISE FND_API.G_EXC_ERROR;
                                END IF;

                                L_x_line_tbl.delete;
                   END IF;

                END IF;
        ELSE
                IF p_selected_records(1).id3 IS NULL THEN
                   L_id3 := FALSE;
                END IF;
                IF NOT L_id3 THEN
                   i := p_selected_records.first;
                   while i is not null loop
                       l_header_id := p_selected_records(i).id1;
                       l_org_id := p_selected_records(i).org_id;
                       IF l_prev_org_id Is Null or l_prev_org_id <> l_org_id Then
                          MO_GLOBAL.set_policy_context(p_access_mode => 'S',  p_org_id => l_Org_Id);
                          l_prev_org_id := l_org_id;
                       END IF;
                       adj_debug('Price Action Header_id :'||l_HEader_id);

		        -- use order_header cache instead of sql : bug 4200055
		       if ( OE_Order_Cache.g_header_rec.header_id <> FND_API.G_MISS_NUM
			    and OE_Order_Cache.g_header_rec.header_id IS NOT NULL
			    and OE_Order_Cache.g_header_rec.header_id = l_header_id ) then
			        l_booked_flag := OE_Order_Cache.g_header_rec.booked_flag ;
		       else
			        OE_ORDER_CACHE.Load_Order_Header(l_header_id);
				l_booked_flag := OE_Order_Cache.g_header_rec.booked_flag ;
		       end if ;
                       /*Select booked_flag into l_booked_flag from oe_order_headers_all
                       where header_id=l_header_id; */
		       --end bug 4200055

                       If l_booked_flag <> 'Y' Then
                          l_price_control_rec.pricing_event := 'BATCH';
                          l_multiple_events := 'N';
                       Elsif  l_booked_flag = 'Y' Then
                          l_price_control_rec.pricing_event  := 'BATCH,BOOK,SHIP';
                          l_multiple_events := 'Y';
                       End If;

                       l_Price_Control_Rec.calculate_flag := QP_PREQ_GRP.G_SEARCH_N_CALCULATE;
                       l_Price_Control_Rec.Simulation_Flag := 'N';

                       oe_order_Adj_pvt.Price_line(
                        X_Return_Status     => l_Return_Status
                        ,p_header_id            => l_header_id
                        ,p_Request_Type_code=> 'ONT'
                        ,p_Control_rec      => l_Price_Control_Rec
                        ,p_Write_To_Db      => TRUE
                        ,x_Line_Tbl         => l_x_Line_Tbl
                        ,p_multiple_events  => l_multiple_events
                        ,p_action_code      => 'PRICE_ORDER');

                       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                          RAISE FND_API.G_EXC_ERROR;
                       END IF;
                       i := p_selected_records.next(i);
                   end loop;
                ELSE
                   i := p_selected_records.first;
                   while i is not null loop
                       l_header_id := p_selected_records(i).id3;
                       l_org_id := p_selected_records(i).org_id;
                       IF l_prev_org_id Is Null or l_prev_org_id <> l_org_id Then
                          MO_GLOBAL.set_policy_context(p_access_mode => 'S',  p_org_id => l_Org_Id);
                          l_prev_org_id := l_org_id;
                       END IF;
                       IF l_prev_hdr_id IS NULL OR l_prev_hdr_id <> l_header_id THEN
                          adj_debug('Price Action Header_id :'||l_HEader_id);
                          Select booked_flag into l_booked_flag from oe_order_headers_all
                          where header_id=l_header_id;
                          If l_booked_flag <> 'Y' Then
                             l_price_control_rec.pricing_event := 'BATCH';
                             l_multiple_events := 'N';
                          Elsif  l_booked_flag = 'Y' Then
                             l_price_control_rec.pricing_event  := 'BATCH,BOOK,SHIP';
                             l_multiple_events := 'Y';
                          End If;

                          l_Price_Control_Rec.calculate_flag := QP_PREQ_GRP.G_SEARCH_N_CALCULATE;
                          l_Price_Control_Rec.Simulation_Flag := 'N';

                          oe_order_Adj_pvt.Price_line(
                             X_Return_Status     => l_Return_Status
                            ,p_header_id            => l_header_id
                            ,p_Request_Type_code=> 'ONT'
                            ,p_Control_rec      => l_Price_Control_Rec
                            ,p_Write_To_Db      => TRUE
                            ,x_Line_Tbl         => l_x_Line_Tbl
                            ,p_multiple_events  => l_multiple_events
                            ,p_action_code      => 'PRICE_ORDER');

                          IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                          ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                             RAISE FND_API.G_EXC_ERROR;
                          END IF;
                          l_prev_hdr_id := l_header_id;
                       END IF;
                       i := p_selected_records.next(i);
                   end loop;
                END IF;

        END IF;

        --MOAC PI END

     OE_MSG_PUB.Count_And_Get
     (   p_count                       => x_msg_count
     ,   p_data                        => x_msg_data
     );

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
		RAISE FND_API.G_EXC_ERROR;
	END IF;

	x_Return_Status := FND_API.G_RET_STS_SUCCESS;

	adj_debug('Exiting oe_order_Adj_pvt.Price_adjustments',1);


    EXCEPTION

	    WHEN FND_API.G_EXC_ERROR THEN
		  x_return_status := FND_API.G_RET_STS_ERROR;
     	  OE_MSG_PUB.Count_And_Get
     	  ( p_count                       => x_msg_count
    		   ,p_data                        => x_msg_data
     	   );

	   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     	  OE_MSG_PUB.Count_And_Get
     	  ( p_count                       => x_msg_count
     	   ,p_data                        => x_msg_data
     	  );

	   WHEN OTHERS THEN
		  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		  adj_debug('		'||sqlerrm,1);
     	  OE_MSG_PUB.Count_And_Get
     	  (  p_count                       => x_msg_count
     	   , p_data                        => x_msg_data
     	  );

end price_action;


/* For Backward Compatibility */

procedure price_action
                (p_Header_count                 Number
                ,p_Header_list                  varchar2
                ,p_line_count                   number
                ,p_line_List                    Varchar2
                ,P_price_level                  varchar2
,x_Return_Status out nocopy varchar2

,x_msg_count out nocopy number

,x_msg_data out nocopy varchar2

                )
is
l_Price_Control_rec             QP_PREQ_GRP.control_record_type;
l_return_status         varchar2(1);
l_x_line_tbl                    oe_order_pub.line_tbl_type;
l_line_list                     varchar2(32000) := p_line_list;
l_Header_list                   varchar2(32000) := p_Header_list;
l_line_id                               number;
l_header_id                     number;
l_delimiter1                    number;
l_delimiter2                    number;
l_delimiter                     number;
l_booked_flag                   varchar2(1);
l_multiple_events               Varchar2(1);
l_order_status_rec QP_UTIL_PUB.ORDER_LINES_STATUS_REC_TYPE;

cursor has_prg_lines(p_line_id IN NUMBER) is
Select 'Y'
From OE_PRICE_ADJUSTMENTS a,  OE_ORDER_LINES_ALL b
Where b.line_id = p_line_id
AND   b.header_id = a.header_id
And   a.list_line_type_code = 'PRG';

l_has_prg_lines varchar2(1):= 'Q';

begin
        adj_debug('Performing Price Action for level '||P_price_level);

        If P_price_level ='LINE' then

                l_Price_Control_Rec.pricing_event := 'LINE';
                l_Price_Control_Rec.calculate_flag := QP_PREQ_GRP.G_SEARCH_N_CALCULATE;
                l_Price_Control_Rec.Simulation_Flag := 'N';
                l_has_prg_lines := 'Q';

                -- Made changes to get line_id from p_line_list for Bug 2532740

                  l_delimiter2 := 0;
                for i in 1..p_line_count loop
                   l_delimiter1     := l_delimiter2;
                   l_delimiter2     := INSTR(p_line_list,',',l_delimiter1+1);

                   If l_delimiter2 = 0 Then
                     l_line_id := to_number(substr(p_line_list,l_delimiter1+1));
                   else
                   -- 2665650 fix
                     l_line_id := to_number(substr(p_line_list,l_delimiter1+1,l_delimiter2-1-l_delimiter1));
                   end if;

                   IF  l_has_prg_lines = 'Q' THEN
                    Begin
                     open  has_prg_lines(l_line_id);
                     fetch has_prg_lines into l_has_prg_lines;
                     close has_prg_lines;
                    Exception
                     When no_data_found Then
                      l_has_prg_lines:='N';
                     When others Then
                      l_has_prg_lines:='Y';
                    End;
                   END IF;

                   adj_debug('Price Action Line_Id:'||l_line_id);
                -- End of changes for 2532740

                     adj_debug('all_lines_flag from pricing api:'|| l_order_status_rec.ALL_LINES_FLAG);
                     IF l_has_prg_lines = 'Y' THEN
                        --fix bug 2788649,if PRG exists we will need to do price_line line per line                         --Need to call price_line line by line because PRG exists
                       adj_debug('New price action, line by line because the order has prg');

                       oe_order_Adj_pvt.Price_line(
                           X_Return_Status     => l_Return_Status
                           ,p_Request_Type_code=> 'ONT'
                           ,p_Control_rec      => l_Price_Control_Rec
                           ,p_Write_To_Db      => TRUE
                           ,p_Line_id          => l_line_id
                           ,x_Line_Tbl         => l_x_Line_Tbl
                           );

                     ELSE
                        --Regular old way,prepare all lines in one pl/sql table
                       adj_debug('Old price_action way, order has no prg');
                       Begin

                             l_x_line_tbl(i).Line_id := l_Line_id;
                             oe_Line_util.query_row(
                                p_Line_id => l_Line_id
                             ,  x_line_rec => l_x_Line_Tbl(i)
                             );
                       Exception when no_data_found then
                                null;
                       End;

                     END IF;

                End loop;

                IF l_has_prg_lines IN ('N','Q') THEN
                  oe_order_Adj_pvt.Price_line(
                        X_Return_Status     => l_Return_Status
                        ,p_Request_Type_code=> 'ONT'
                        ,p_Control_rec      => l_Price_Control_Rec
                        ,p_Write_To_Db      => TRUE
                        ,x_Line_Tbl         => l_x_Line_Tbl
                        );
                END IF;

                 IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                 ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                   RAISE FND_API.G_EXC_ERROR;
                 END IF;



        Else
                 -- Made changes to get Header Id from p_Header_list for Bug 2532740

                  l_delimiter2 := 0;
                for i in 1..p_Header_count loop
                  l_delimiter1     := l_delimiter2;
                  l_delimiter2     := INSTR(p_Header_list,',',l_delimiter1+1);

                  If l_delimiter2 = 0 Then
                  l_HEader_id := to_number(substr(p_Header_list,l_delimiter1+1));
                  else
                  -- 2665650 fix
                  l_HEader_id := to_number(substr(p_Header_list,l_delimiter1+1,l_delimiter2-1-l_delimiter1));
                  end if;

                  adj_debug('Price Action Header_id :'||l_HEader_id);
                  -- End of changes for 2532740

                  Select booked_flag into l_booked_flag from oe_order_headers_all
                        where header_id=l_header_id;

                  --Following code are commented out due to unresolved dependencies issue
                  --with Oracle Pricing.  However, this code will greatly improve performance
                  --of action-->price_order if restored.
                  --In order for this commented code to work pricing patch
                  --1802580,1806021 and 1796034 must get applied.

                  If l_booked_flag <> 'Y' Then
                    l_price_control_rec.pricing_event := 'BATCH';
                    l_multiple_events := 'N';
                  Elsif  l_booked_flag = 'Y' Then
                    l_price_control_rec.pricing_event  := 'BATCH,BOOK,SHIP';
                    l_multiple_events := 'Y';
                  End If;

                    l_Price_Control_Rec.calculate_flag := QP_PREQ_GRP.G_SEARCH_N_CALCULATE;
                    l_Price_Control_Rec.Simulation_Flag := 'N';

                    oe_order_Adj_pvt.Price_line(
                        X_Return_Status     => l_Return_Status
                        ,p_header_id            => l_header_id
                        ,p_Request_Type_code=> 'ONT'
                        ,p_Control_rec      => l_Price_Control_Rec
                        ,p_Write_To_Db      => TRUE
                        ,x_Line_Tbl         => l_x_Line_Tbl
                        ,p_multiple_events  => l_multiple_events
                        ,p_action_code      => 'PRICE_ORDER');

                    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                     RAISE FND_API.G_EXC_ERROR;
                    END IF;

                end loop; -- Headers

        End If;

     OE_MSG_PUB.Count_And_Get
     (   p_count                       => x_msg_count
     ,   p_data                        => x_msg_data
     );

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
        END IF;

        x_Return_Status := FND_API.G_RET_STS_SUCCESS;

        adj_debug('Exiting oe_order_Adj_pvt.Price_adjustments',1);


    EXCEPTION

            WHEN FND_API.G_EXC_ERROR THEN
                  x_return_status := FND_API.G_RET_STS_ERROR;
          OE_MSG_PUB.Count_And_Get
          ( p_count                       => x_msg_count
                   ,p_data                        => x_msg_data
           );

           WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          OE_MSG_PUB.Count_And_Get
          ( p_count                       => x_msg_count
           ,p_data                        => x_msg_data
          );

           WHEN OTHERS THEN
                  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                  adj_debug('           '||sqlerrm,1);
          OE_MSG_PUB.Count_And_Get
          (  p_count                       => x_msg_count
           , p_data                        => x_msg_data
          );

end price_action;


Procedure Set_Header(p_header IN quote_header_rec_type) As
Begin
oe_order_pub.g_hdr.accounting_rule_id            :=p_header.accounting_rule_id          ;
oe_order_pub.g_hdr.agreement_id                  :=p_header.agreement_id                ;
oe_order_pub.g_hdr.booked_flag                   :=p_header.booked_flag                 ;
oe_order_pub.g_hdr.cancelled_flag                :=p_header.cancelled_flag              ;
oe_order_pub.g_hdr.context                       :=p_header.context                     ;
oe_order_pub.g_hdr.conversion_rate               :=p_header.conversion_rate             ;
oe_order_pub.g_hdr.conversion_rate_date          :=p_header.conversion_rate_date        ;
oe_order_pub.g_hdr.conversion_type_code          :=p_header.conversion_type_code        ;
oe_order_pub.g_hdr.customer_preference_set_code  :=p_header.customer_preference_set_code;
oe_order_pub.g_hdr.cust_po_number                :=p_header.cust_po_number              ;
oe_order_pub.g_hdr.deliver_to_contact_id         :=p_header.deliver_to_contact_id       ;
oe_order_pub.g_hdr.deliver_to_org_id             :=p_header.deliver_to_org_id           ;
oe_order_pub.g_hdr.demand_class_code             :=p_header.demand_class_code           ;
oe_order_pub.g_hdr.expiration_date               :=p_header.expiration_date             ;
oe_order_pub.g_hdr.fob_point_code                :=p_header.fob_point_code              ;
oe_order_pub.g_hdr.freight_carrier_code          :=p_header.freight_carrier_code        ;
oe_order_pub.g_hdr.freight_terms_code            :=p_header.freight_terms_code          ;
oe_order_pub.g_hdr.invoice_to_contact_id         :=p_header.invoice_to_contact_id       ;
oe_order_pub.g_hdr.invoice_to_org_id             :=p_header.invoice_to_org_id           ;
oe_order_pub.g_hdr.invoicing_rule_id             :=p_header.invoicing_rule_id           ;
oe_order_pub.g_hdr.order_category_code           :=p_header.order_category_code         ;
oe_order_pub.g_hdr.ordered_date                  :=p_header.ordered_date                ;
oe_order_pub.g_hdr.order_date_type_code          :=p_header.order_date_type_code        ;
oe_order_pub.g_hdr.order_number                  :=p_header.order_number                ;
oe_order_pub.g_hdr.order_source_id               :=p_header.order_source_id             ;
oe_order_pub.g_hdr.order_type_id                 :=p_header.order_type_id               ;
oe_order_pub.g_hdr.org_id                        :=p_header.org_id                      ;
oe_order_pub.g_hdr.payment_term_id               :=p_header.payment_term_id             ;
oe_order_pub.g_hdr.price_list_id                 :=p_header.price_list_id               ;
oe_order_pub.g_hdr.pricing_date                  :=p_header.pricing_date                ;
oe_order_pub.g_hdr.request_date                  :=p_header.request_date                ;
oe_order_pub.g_hdr.request_id                    :=p_header.request_id                  ;
oe_order_pub.g_hdr.salesrep_id                   :=p_header.salesrep_id                 ;
oe_order_pub.g_hdr.sales_channel_code            :=p_header.sales_channel_code          ;
oe_order_pub.g_hdr.shipment_priority_code        :=p_header.shipment_priority_code      ;
oe_order_pub.g_hdr.shipping_method_code          :=p_header.shipping_method_code        ;
oe_order_pub.g_hdr.ship_from_org_id              :=p_header.ship_from_org_id            ;
oe_order_pub.g_hdr.ship_to_contact_id            :=p_header.ship_to_contact_id          ;
oe_order_pub.g_hdr.ship_to_org_id                :=p_header.ship_to_org_id              ;
oe_order_pub.g_hdr.sold_from_org_id              :=p_header.sold_from_org_id            ;
oe_order_pub.g_hdr.sold_to_contact_id            :=p_header.sold_to_contact_id          ;
oe_order_pub.g_hdr.sold_to_org_id                :=p_header.sold_to_org_id              ;
oe_order_pub.g_hdr.source_document_id            :=p_header.source_document_id          ;
oe_order_pub.g_hdr.source_document_type_id       :=p_header.source_document_type_id     ;
oe_order_pub.g_hdr.transactional_curr_code       :=p_header.transactional_curr_code     ;
oe_order_pub.g_hdr.drop_ship_flag                :=p_header.drop_ship_flag              ;
oe_order_pub.g_hdr.customer_payment_term_id      :=p_header.customer_payment_term_id    ;
oe_order_pub.g_hdr.payment_type_code             :=p_header.payment_type_code           ;
oe_order_pub.g_hdr.payment_amount                :=p_header.payment_amount              ;
oe_order_pub.g_hdr.credit_card_code              :=p_header.credit_card_code            ;
oe_order_pub.g_hdr.credit_card_holder_name       :=p_header.credit_card_holder_name     ;
oe_order_pub.g_hdr.credit_card_number            :=p_header.credit_card_number          ;
oe_order_pub.g_hdr.marketing_source_code_id      :=p_header.marketing_source_code_id    ;

End Set_Header;

Procedure Load_Line_Tbl(p_quote_line_tbl in  quote_line_tbl_type,
x_line_tbl out nocopy Oe_Order_Pub.line_tbl_type) As

i PLS_INTEGER;
Begin
  --DBMS_OUTPUT.PUT_LINE('In load line tbl');
  i := p_quote_line_tbl.First;
  While i Is Not Null Loop
     x_line_tbl(i).actual_arrival_date        :=p_quote_line_tbl(i).actual_arrival_date        ;
     x_line_tbl(i).actual_shipment_date       :=p_quote_line_tbl(i).actual_shipment_date       ;
     x_line_tbl(i).agreement_id               :=p_quote_line_tbl(i).agreement_id               ;
     x_line_tbl(i).cancelled_quantity         :=p_quote_line_tbl(i).cancelled_quantity         ;
     x_line_tbl(i).cust_po_number             :=p_quote_line_tbl(i).cust_po_number             ;
     x_line_tbl(i).deliver_to_contact_id      :=p_quote_line_tbl(i).deliver_to_contact_id      ;
     x_line_tbl(i).deliver_to_org_id          :=p_quote_line_tbl(i).deliver_to_org_id          ;
     x_line_tbl(i).freight_carrier_code       :=p_quote_line_tbl(i).freight_carrier_code       ;
     x_line_tbl(i).freight_terms_code         :=p_quote_line_tbl(i).freight_terms_code         ;
     x_line_tbl(i).intermed_ship_to_org_id    :=p_quote_line_tbl(i).intermed_ship_to_org_id    ;
     x_line_tbl(i).intermed_ship_to_contact_id:=p_quote_line_tbl(i).intermed_ship_to_contact_id;
     x_line_tbl(i).inventory_item_id          :=p_quote_line_tbl(i).inventory_item_id          ;
     x_line_tbl(i).invoice_interface_status_code:=p_quote_line_tbl(i).invoice_interface_status_code;
     x_line_tbl(i).invoice_to_contact_id      :=p_quote_line_tbl(i).invoice_to_contact_id      ;
     x_line_tbl(i).invoice_to_org_id          :=p_quote_line_tbl(i).invoice_to_org_id          ;
     x_line_tbl(i).ordered_item               :=p_quote_line_tbl(i).ordered_item               ;
     x_line_tbl(i).item_type_code             :=p_quote_line_tbl(i).item_type_code             ;
     x_line_tbl(i).line_type_id               :=p_quote_line_tbl(i).line_type_id               ;
     x_line_tbl(i).ordered_quantity           :=p_quote_line_tbl(i).ordered_quantity           ;
     x_line_tbl(i).ordered_quantity2          :=p_quote_line_tbl(i).ordered_quantity2          ;
     x_line_tbl(i).order_quantity_uom         :=p_quote_line_tbl(i).order_quantity_uom         ;
     x_line_tbl(i).ordered_quantity_uom2      :=p_quote_line_tbl(i).ordered_quantity_uom2      ;
     x_line_tbl(i).org_id                     :=p_quote_line_tbl(i).org_id                     ;
     x_line_tbl(i).payment_term_id            :=p_quote_line_tbl(i).payment_term_id            ;
     x_line_tbl(i).price_list_id              :=p_quote_line_tbl(i).price_list_id              ;
     x_line_tbl(i).pricing_context            :=p_quote_line_tbl(i).pricing_context            ;
     x_line_tbl(i).pricing_date               :=p_quote_line_tbl(i).pricing_date               ;
     x_line_tbl(i).pricing_quantity           :=p_quote_line_tbl(i).pricing_quantity           ;
     x_line_tbl(i).pricing_quantity_uom       :=p_quote_line_tbl(i).pricing_quantity_uom       ;
     x_line_tbl(i).project_id                 :=p_quote_line_tbl(i).project_id                 ;
     x_line_tbl(i).promise_date               :=p_quote_line_tbl(i).promise_date               ;
     x_line_tbl(i).salesrep_id                :=p_quote_line_tbl(i).salesrep_id                ;
     x_line_tbl(i).schedule_arrival_date      :=p_quote_line_tbl(i).schedule_arrival_date      ;
     x_line_tbl(i).schedule_ship_date         :=p_quote_line_tbl(i).schedule_ship_date         ;
     x_line_tbl(i).ship_from_org_id           :=p_quote_line_tbl(i).ship_from_org_id           ;
     x_line_tbl(i).ship_to_org_id             :=p_quote_line_tbl(i).ship_to_org_id             ;
     x_line_tbl(i).sold_to_org_id             :=p_quote_line_tbl(i).sold_to_org_id             ;
     x_line_tbl(i).sold_from_org_id           :=p_quote_line_tbl(i).sold_from_org_id           ;
     x_line_tbl(i).source_document_type_id    :=p_quote_line_tbl(i).source_document_type_id    ;
     x_line_tbl(i).task_id                    :=p_quote_line_tbl(i).task_id                    ;
     x_line_tbl(i).tax_code                   :=p_quote_line_tbl(i).tax_code                   ;
     x_line_tbl(i).unit_list_price_per_pqty   :=p_quote_line_tbl(i).unit_list_price            ;
     x_line_tbl(i).unit_selling_price_per_pqty:=p_quote_line_tbl(i).unit_selling_price         ;
     x_line_tbl(i).order_source_id            :=p_quote_line_tbl(i).order_source_id            ;
     x_line_tbl(i).customer_payment_term_id   :=p_quote_line_tbl(i).customer_payment_term_id   ;
     x_line_tbl(i).ordered_item_id            :=p_quote_line_tbl(i).ordered_item_id            ;
     x_line_tbl(i).item_identifier_type       :=p_quote_line_tbl(i).item_identifier_type       ;
     x_line_tbl(i).unit_list_percent          :=p_quote_line_tbl(i).unit_list_percent          ;
     x_line_tbl(i).unit_selling_percent       :=p_quote_line_tbl(i).unit_selling_percent       ;
     x_line_tbl(i).unit_percent_base_price    :=p_quote_line_tbl(i).unit_percent_base_price    ;
     x_line_tbl(i).service_number             :=p_quote_line_tbl(i).service_number             ;
     x_line_tbl(i).revenue_amount             :=p_quote_line_tbl(i).revenue_amount             ;
     x_line_tbl(i).line_id                    :=p_quote_line_tbl(i).line_id                    ;
    i :=p_quote_line_tbl.Next(i);
    /*if i > 100 then DBMS_OUTPUT.PUT_LINE('Inf Loop2'); end if;
    exit when i > 100; */
  End Loop;

End;

Procedure Load_Out_Quote_Line (p_line_tbl       In  Oe_Order_Pub.Line_tbl_Type,
                               p_req_line_tbl   In  QP_PREQ_GRP.LINE_TBL_TYPE,
x_quote_line_tbl out nocopy quote_line_tbl_type) As

i PLS_INTEGER;
Begin
 --DBMS_OUTPUT.PUT_LINE('In load out quote');
 i := p_line_tbl.First;
 While i Is Not Null Loop
     x_quote_line_tbl(i).actual_arrival_date        :=p_line_tbl(i).actual_arrival_date        ;
     x_quote_line_tbl(i).actual_shipment_date       :=p_line_tbl(i).actual_shipment_date       ;
     x_quote_line_tbl(i).agreement_id               :=p_line_tbl(i).agreement_id               ;
     x_quote_line_tbl(i).cancelled_quantity         :=p_line_tbl(i).cancelled_quantity         ;
     x_quote_line_tbl(i).cust_po_number             :=p_line_tbl(i).cust_po_number             ;
     x_quote_line_tbl(i).deliver_to_contact_id      :=p_line_tbl(i).deliver_to_contact_id      ;
     x_quote_line_tbl(i).deliver_to_org_id          :=p_line_tbl(i).deliver_to_org_id          ;
     x_quote_line_tbl(i).freight_carrier_code       :=p_line_tbl(i).freight_carrier_code       ;
     x_quote_line_tbl(i).freight_terms_code         :=p_line_tbl(i).freight_terms_code         ;
     x_quote_line_tbl(i).intermed_ship_to_org_id    :=p_line_tbl(i).intermed_ship_to_org_id    ;
     x_quote_line_tbl(i).intermed_ship_to_contact_id:=p_line_tbl(i).intermed_ship_to_contact_id;
     x_quote_line_tbl(i).inventory_item_id          :=p_line_tbl(i).inventory_item_id          ;
     x_quote_line_tbl(i).invoice_interface_status_code:=p_line_tbl(i).invoice_interface_status_code;
     x_quote_line_tbl(i).invoice_to_contact_id      :=p_line_tbl(i).invoice_to_contact_id      ;
     x_quote_line_tbl(i).invoice_to_org_id          :=p_line_tbl(i).invoice_to_org_id          ;
     x_quote_line_tbl(i).ordered_item               :=p_line_tbl(i).ordered_item               ;
     x_quote_line_tbl(i).item_type_code             :=p_line_tbl(i).item_type_code             ;
     x_quote_line_tbl(i).line_type_id               :=p_line_tbl(i).line_type_id               ;
     x_quote_line_tbl(i).ordered_quantity           :=p_line_tbl(i).ordered_quantity           ;
     x_quote_line_tbl(i).ordered_quantity2          :=p_line_tbl(i).ordered_quantity2          ;
     x_quote_line_tbl(i).order_quantity_uom         :=p_line_tbl(i).order_quantity_uom         ;
     x_quote_line_tbl(i).ordered_quantity_uom2      :=p_line_tbl(i).ordered_quantity_uom2      ;
     x_quote_line_tbl(i).org_id                     :=p_line_tbl(i).org_id                     ;
     x_quote_line_tbl(i).payment_term_id            :=p_line_tbl(i).payment_term_id            ;
     x_quote_line_tbl(i).price_list_id              :=p_line_tbl(i).price_list_id              ;
     x_quote_line_tbl(i).pricing_context            :=p_line_tbl(i).pricing_context            ;
     x_quote_line_tbl(i).pricing_date               :=p_line_tbl(i).pricing_date               ;
     x_quote_line_tbl(i).pricing_quantity           :=p_line_tbl(i).pricing_quantity           ;
     x_quote_line_tbl(i).pricing_quantity_uom       :=p_line_tbl(i).pricing_quantity_uom       ;
     x_quote_line_tbl(i).project_id                 :=p_line_tbl(i).project_id                 ;
     x_quote_line_tbl(i).promise_date               :=p_line_tbl(i).promise_date               ;
     x_quote_line_tbl(i).salesrep_id                :=p_line_tbl(i).salesrep_id                ;
     x_quote_line_tbl(i).schedule_arrival_date      :=p_line_tbl(i).schedule_arrival_date      ;
     x_quote_line_tbl(i).schedule_ship_date         :=p_line_tbl(i).schedule_ship_date         ;
     x_quote_line_tbl(i).ship_from_org_id           :=p_line_tbl(i).ship_from_org_id           ;
     x_quote_line_tbl(i).ship_to_org_id             :=p_line_tbl(i).ship_to_org_id             ;
     x_quote_line_tbl(i).sold_to_org_id             :=p_line_tbl(i).sold_to_org_id             ;
     x_quote_line_tbl(i).sold_from_org_id           :=p_line_tbl(i).sold_from_org_id           ;
     x_quote_line_tbl(i).source_document_type_id    :=p_line_tbl(i).source_document_type_id    ;
     x_quote_line_tbl(i).task_id                    :=p_line_tbl(i).task_id                    ;
     x_quote_line_tbl(i).tax_code                   :=p_line_tbl(i).tax_code                   ;
     x_quote_line_tbl(i).unit_list_price            :=p_line_tbl(i).unit_list_price_per_pqty   ;
     x_quote_line_tbl(i).unit_selling_price         :=p_line_tbl(i).unit_selling_price_per_pqty;
     x_quote_line_tbl(i).order_source_id            :=p_line_tbl(i).order_source_id            ;
     x_quote_line_tbl(i).customer_payment_term_id   :=p_line_tbl(i).customer_payment_term_id   ;
     x_quote_line_tbl(i).ordered_item_id            :=p_line_tbl(i).ordered_item_id            ;
     x_quote_line_tbl(i).item_identifier_type       :=p_line_tbl(i).item_identifier_type       ;
     x_quote_line_tbl(i).unit_list_percent          :=p_line_tbl(i).unit_list_percent          ;
     x_quote_line_tbl(i).unit_selling_percent       :=p_line_tbl(i).unit_selling_percent       ;
     x_quote_line_tbl(i).unit_percent_base_price    :=p_line_tbl(i).unit_percent_base_price    ;
     x_quote_line_tbl(i).service_number             :=p_line_tbl(i).service_number             ;
     x_quote_line_tbl(i).revenue_amount             :=p_line_tbl(i).revenue_amount             ;
     x_quote_line_tbl(i).line_id                    :=p_line_tbl(i).line_id                    ;
     --use this attribute for place holder of status code. Because there are
     --no place holder for status on line_rec record type
     If (p_line_tbl(i).industry_attribute30) In
                               (QP_PREQ_GRP.G_STATUS_INVALID_PRICE_LIST,
				QP_PREQ_GRP.G_STS_LHS_NOT_FOUND,
				QP_PREQ_GRP.G_STATUS_FORMULA_ERROR,
				QP_PREQ_GRP.G_STATUS_OTHER_ERRORS,
				FND_API.G_RET_STS_UNEXP_ERROR,
				FND_API.G_RET_STS_ERROR,
				QP_PREQ_GRP.G_STATUS_CALC_ERROR,
				QP_PREQ_GRP.G_STATUS_UOM_FAILURE,
				QP_PREQ_GRP.G_STATUS_INVALID_UOM,
				QP_PREQ_GRP.G_STATUS_DUP_PRICE_LIST,
				QP_PREQ_GRP.G_STATUS_INVALID_UOM_CONV,
				QP_PREQ_GRP.G_STATUS_INVALID_INCOMP,
				QP_PREQ_GRP.G_STATUS_BEST_PRICE_EVAL_ERROR
                                ) Then

       x_quote_line_tbl(i).Status_Code:= p_line_tbl(i).industry_attribute30;
        --DBMS_OUTPUT.PUT_LINE('+++F++:'||x_quote_line_tbl(i).Status_Code);
     Else
        x_quote_line_tbl(i).Status_Code:=FND_API.G_RET_STS_SUCCESS;
        --DBMS_OUTPUT.PUT_LINE('+++S++:'|| x_quote_line_tbl(i).Status_Code);
     End If;

     i:= p_line_tbl.Next(i);

 End Loop;

End;

Procedure Get_Quote(p_quote_header       in  quote_header_rec_type,
                    p_quote_line_tbl     in  quote_line_tbl_type,
                    p_request_type_code  in  Varchar2,  --'ONT','QP' etc
                    p_event              in  varchar2 default 'BATCH',
x_quote_line_tbl out nocopy quote_line_tbl_type,

x_return_status out nocopy Varchar2,

x_return_status_text out nocopy Varchar2) As


l_line_tbl Oe_Order_Pub.line_tbl_type;
l_control_rec Qp_Preq_Grp.control_record_type;
l_req_line_tbl                 QP_PREQ_GRP.LINE_TBL_TYPE;
l_Req_qual_tbl                 QP_PREQ_GRP.QUAL_TBL_TYPE;
l_Req_line_attr_tbl            QP_PREQ_GRP.LINE_ATTR_TBL_TYPE;
l_Req_LINE_DETAIL_tbl          QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE;
l_Req_LINE_DETAIL_qual_tbl     QP_PREQ_GRP.LINE_DETAIL_QUAL_TBL_TYPE;
l_Req_LINE_DETAIL_attr_tbl     QP_PREQ_GRP.LINE_DETAIL_ATTR_TBL_TYPE;
l_Req_related_lines_tbl        QP_PREQ_GRP.RELATED_LINES_TBL_TYPE;
l_any_frozen_line              Boolean;
l_hdr_rec                      Oe_Order_Pub.Header_Rec_Type;
l_stmt                         Varchar2(50);
i PLS_INTEGER;
Begin

 Set_Header(p_quote_header);
 Load_line_Tbl(p_quote_line_tbl,l_line_tbl);

 --getting a quote is always a batch event
 l_control_rec.pricing_event := p_event;

 l_control_rec.calculate_flag  := QP_PREQ_GRP.G_SEARCH_N_CALCULATE;
 l_control_rec.simulation_Flag := 'N';
           l_stmt := 'quote 1';
           calculate_adjustments
                       (x_return_status		     =>x_return_status             ,
                        p_Request_Type_Code	     =>p_request_type_code         ,
                        p_Control_Rec		     =>l_control_rec               ,
                        x_req_line_tbl               =>l_req_line_tbl              ,
                        x_Req_qual_tbl               =>l_Req_qual_tbl              ,
                        x_Req_line_attr_tbl          =>l_Req_line_attr_tbl         ,
                        x_Req_LINE_DETAIL_tbl        =>l_Req_LINE_DETAIL_tbl       ,
                        x_Req_LINE_DETAIL_qual_tbl   =>l_Req_LINE_DETAIL_qual_tbl  ,
                        x_Req_LINE_DETAIL_attr_tbl   =>l_Req_LINE_DETAIL_attr_tbl  ,
                        x_Req_related_lines_tbl      =>l_Req_related_lines_tbl     ,
                        p_use_current_header         =>TRUE,
                        p_write_to_db		     =>FALSE,
                        x_any_frozen_line            =>l_any_frozen_line,
                        x_Header_Rec		     =>l_hdr_rec,
                        x_line_Tbl                   =>l_line_tbl);

           l_stmt := 'quote 2';

          process_adjustments
	  (
	  p_Request_Type_Code 	           => p_request_type_code,
	  x_return_status         	   => x_Return_Status,
	  p_Req_Control_Rec                => l_control_rec,
	  p_req_line_tbl                   => l_req_line_tbl,
	  p_Req_qual_tbl                   => l_Req_qual_tbl,
	  p_Req_line_attr_tbl              => l_Req_line_attr_tbl,
	  p_Req_Line_Detail_tbl            => l_Req_LINE_DETAIL_tbl,
	  p_Req_Line_Detail_Qual_tbl       => l_Req_LINE_DETAIL_qual_tbl,
	  p_Req_Line_Detail_Attr_tbl       => l_Req_LINE_DETAIL_attr_tbl,
	  p_Req_related_lines_tbl          => l_Req_related_lines_tbl,
	  p_write_to_db			   => FALSE,
          p_any_frozen_line                => l_any_frozen_line,
	  p_Header_Rec			   => l_Hdr_Rec,
	  x_line_Tbl			   => l_Line_Tbl,
          p_honor_price_flag    => 'Y'  --bug 2503186
	  );

         Load_Out_Quote_Line(l_Line_Tbl,l_req_line_tbl,x_quote_line_tbl);

Exception
  When Others Then
  x_return_status := FND_API.G_RET_STS_ERROR;
  x_return_status_text := 'Oe_Order_Adj_Pvt.Get_Quote: '||l_stmt||': '||SQLERRM;

End get_quote;

/***************************************************************************************************
Procedure Create_Manual_Adjustments
Purpose     : Insert manual overriable adjustment into Oe_Price_Adjustments
Called by   : Mass Change pld
Known Issues: Doesn't handle order level manual overriable adjustment
****************************************************************************************************/
Procedure Create_Manual_Adjustments(p_line_id In Number)
As
l_return_stauts   Varchar2(15);
l_manual_adj_tbl  Oe_Order_Adj_Pvt.Manual_Adj_Tbl_Type;
l_line_adj_tbl    Oe_Order_Pub.line_adj_tbl_type;
l_dummy_tbl       Oe_Order_Pub.line_adj_tbl_type;
l_control_rec     OE_GLOBALS.Control_Rec_Type;
i PLS_INTEGER;
k PLS_INTEGER:=1;
l_return_status Varchar2(15);
l_found Varchar2(1):='N';
stmt Varchar2(240);
l_header_id NUMBER;


Begin
  l_control_rec.private_call         := TRUE;
  l_control_rec.controlled_operation := TRUE;
  l_control_rec.check_security       := FALSE;
  l_control_rec.validate_entity      := FALSE;
  l_control_rec.write_to_db          := TRUE;
  l_control_rec.change_attributes    := FALSE;

  Oe_Debug_Pub.add('Mass Change line id: '||p_line_id);
  stmt:='1';

  --For mass change it could be different order headers for lines therefore p_cross_order = 'Y'
  Get_Manual_Adjustments(p_line_id        => p_line_id,
                         p_cross_order    => 'Y',
                         x_manual_adj_tbl => l_manual_adj_tbl,
                         x_return_status  => l_return_status,
                         x_header_id      => l_header_id,
                         p_called_from    => 'SO');
  stmt:='2';
  i := l_manual_adj_tbl.First;
  While i Is Not Null Loop
    If l_manual_adj_tbl(i).override_flag = 'Y' Then
      --check if such modifier list exists in Oe_Price_Adjustments
      --If it is there don't insert a new one
      Oe_debug_Pub.add('  Override_flag:'||l_manual_adj_tbl(i).override_flag);
      Begin
       Select 'Y' Into l_found
       From Dual
       Where exists (Select 'X' From Oe_Price_Adjustments
                     Where  line_id = p_line_id
                     and    list_line_id = l_manual_adj_tbl(i).list_line_id);
       l_found:='Y';
      Exception
         When No_Data_Found Then
         l_found := 'N';
      End;
         stmt:='10';
        --Insert only if no modifier list line found.
        If l_found = 'N' Then
         oe_debug_pub.add(' Creating overridable manual in oe_price_adjustments');
         l_line_adj_tbl(1).list_line_no          := l_manual_adj_tbl(i).modifier_number; /* Bug #3738023 */
         l_line_adj_tbl(1).list_header_id        := l_manual_adj_tbl(i).list_header_id;
         l_line_adj_tbl(1).list_line_id          := l_manual_adj_tbl(i).list_line_id;
         l_line_adj_tbl(1).list_line_type_code   := l_manual_adj_tbl(i).list_line_type_code;
         l_line_adj_tbl(1).modifier_level_code   := l_manual_adj_tbl(i).modifier_level_code;
         l_line_adj_tbl(1).operand               := l_manual_adj_tbl(i).operand;
         l_line_adj_tbl(1).arithmetic_operator   := l_manual_adj_tbl(i).operator;
         l_line_adj_tbl(1).update_allowed        := l_manual_adj_tbl(i).override_flag;
         l_line_adj_tbl(k).header_id             := l_header_id;
         l_line_adj_tbl(1).line_id               := p_line_id;
         l_line_adj_tbl(1).applied_flag          := 'N';
         l_line_adj_tbl(1).updated_flag          := 'N';
         l_line_adj_tbl(1).automatic_flag        := 'N';
         l_line_adj_tbl(1).operation             := OE_GLOBALS.G_OPR_CREATE;
         Select Oe_Price_Adjustments_S.Nextval
         Into   l_line_adj_tbl(1).price_adjustment_id
         From   dual;
          stmt:='20';
         Line_Adjs(p_validation_level => FND_API.G_VALID_LEVEL_NONE,
                   p_control_rec              => l_control_rec,
                   p_x_line_adj_tbl           => l_line_adj_tbl,
                   p_x_old_line_adj_tbl       => l_dummy_tbl);
           stmt:='30';
       End If;
      --k:=k+1;
    End If;
   i:= l_manual_adj_tbl.Next(i);
  End Loop;

Exception When Others Then
  Oe_Debug_Pub.Add('Error occured in oe_order_adj_pvt.create_manual_adjustments:'||stmt||':'||SQLERRM);
  Raise;
End Create_Manual_Adjustments;



/******************************************************************************************************
 Procedure Get_Manual_Adjustments
 Called by: Unit selling price lov
 Purpose: Return manual adjustments
 Input:
 p_header_id: For the case of linegroup manual adjustment, all lines will need to pass to engine
              for evaluation.
 p_line_rec:  For the case of no linegroup manual adjustment, one line rec is sufficient
*******************************************************************************************************/

Procedure Get_Manual_Adjustments (
p_header_id        in  number                     Default Null,
p_line_id          in  number                     Default Null,
p_line_rec         in  oe_Order_Pub.Line_Rec_Type Default oe_order_pub.g_miss_line_rec,
p_level            in  Varchar2 default 'LINE',
p_pbh_mode         in  Varchar2 default 'CHILD',
p_cross_order      in  Varchar2 Default 'N',
p_line_level       in  Varchar2 Default 'N',
x_manual_adj_tbl   out Nocopy  Oe_Order_Adj_Pvt.Manual_Adj_Tbl_Type,
x_return_status out nocopy Varchar2,

x_header_id out nocopy Number,
p_freight_flag     in boolean default false,
p_called_from      in varchar2 default null

 --if no header id passed in this procedure it will return header id based on line id passed in
)
As
l_profile_value                 Varchar2(1):= Nvl(Fnd_Profile.Value('ONT_MANUAL_LINEGROUP'),'Y');
l_line_tbl                      oe_Order_Pub.Line_tbl_Type;
l_line_rec                      oe_order_pub.line_rec_type;
l_pricing_contexts_Tbl		QP_Attr_Mapping_PUB.Contexts_Result_Tbl_Type;
l_qualifier_contexts_Tbl	QP_Attr_Mapping_PUB.Contexts_Result_Tbl_Type;
l_Req_qual_tbl                  QP_PREQ_GRP.QUAL_TBL_TYPE;
l_Req_line_attr_tbl             QP_PREQ_GRP.LINE_ATTR_TBL_TYPE;
l_req_line_tbl                  QP_PREQ_GRP.LINE_TBL_TYPE;
l_Req_LINE_DETAIL_tbl           QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE;
l_Req_LINE_DETAIL_qual_tbl      QP_PREQ_GRP.LINE_DETAIL_QUAL_TBL_TYPE;
l_Req_LINE_DETAIL_attr_tbl      QP_PREQ_GRP.LINE_DETAIL_ATTR_TBL_TYPE;
l_Req_related_lines_tbl         QP_PREQ_GRP.RELATED_LINES_TBL_TYPE;
lx_Req_qual_tbl                  QP_PREQ_GRP.QUAL_TBL_TYPE;
lx_Req_line_attr_tbl             QP_PREQ_GRP.LINE_ATTR_TBL_TYPE;
lx_req_line_tbl                  QP_PREQ_GRP.LINE_TBL_TYPE;
lx_Req_LINE_DETAIL_tbl           QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE;
lx_Req_LINE_DETAIL_qual_tbl      QP_PREQ_GRP.LINE_DETAIL_QUAL_TBL_TYPE;
lx_Req_LINE_DETAIL_attr_tbl      QP_PREQ_GRP.LINE_DETAIL_ATTR_TBL_TYPE;
lx_Req_related_lines_tbl         QP_PREQ_GRP.RELATED_LINES_TBL_TYPE;
l_Control_Rec			QP_PREQ_GRP.CONTROL_RECORD_TYPE;
l_event                         Varchar2(30) Default 'BATCH';
l_return_status                 Varchar2(10);
l_return_status_text            Varchar2(240);
i PLS_INTEGER;
j PLS_INTEGER;
k PLS_INTEGER;
line_tbl_index PLS_INTEGER;
QP_ATTR_MAPPING_ERRORS Exception;

l_ask_for_profile              Varchar2(1):=NVL(Fnd_Profile.Value('ONT_ASK_FOR_PROMOTION'),'Y');
l_dummy                        Varchar2(1);

l_header_id Number;
--indicates whether line has already been written to DB
l_posted_to_DB BOOLEAN := FALSE;
l_header_id2 NUMBER;
--bucket man
l_pass_line varchar2(1);
l_check_line_flag varchar2(1); --5598523
l_line_index NUMBER := 0;
l_line_attr_index number:=0;
--bug 3531938
l_order_status_rec QP_UTIL_PUB.ORDER_LINES_STATUS_REC_TYPE;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

l_manual_all_lines_status         Varchar2(1); --bug 7600510

cursor man_adj is
       select ld.automatic_flag, ld.line_index, ld.modifier_level_code,
       ld.line_quantity, ld.line_detail_type_code,
       ld.CREATED_FROM_LIST_LINE_TYPE list_line_type_code,
       ld.list_line_no, ld.operand_value,
       ld.CREATED_FROM_LIST_LINE_ID list_line_id,
       ld.CREATED_FROM_LIST_HEADER_ID list_header_id,
       ld.pricing_phase_id, ll.override_flag, ld.operand_calculation_code,
       ld.ADJUSTMENT_AMOUNT, ll.CHARGE_TYPE_CODE, ll.CHARGE_SUBTYPE_CODE,
       l.line_type_code, l.line_id, ld.PRICE_BREAK_TYPE_CODE,
       ld.pricing_group_sequence
       from QP_PREQ_LINES_TMP l, QP_PREQ_LDETS_TMP ld, QP_LIST_LINES ll
       where l.line_index = ld.line_index
         and ld.CREATED_FROM_LIST_LINE_ID = ll.LIST_LINE_ID
         and ld.PRICING_STATUS_CODE = QP_PREQ_GRP.G_STATUS_NEW
       ORDER BY ld.list_line_no; -- bug 6323362

--bucket man
Begin
    if p_freight_flag then
       oe_debug_pub.add('freight flag is true');
    else
       oe_debug_pub.add('freight flag is false');
    end if;
   x_return_status:=FND_API.G_RET_STS_SUCCESS;
   --l_profile_value := Fnd_Profile.Value('QP_MANUAL_LINEGROUP');
   oe_debug_pub.add('Entering Get Manual Adj');
 --bucket man
   IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110510' THEN
        oe_order_price_pvt.reset_all_tbls;
        qp_price_request_context.set_request_id;
   END IF;
 -- bucket man

   G_STMT_NO := 'Get_manual_adjustment#0';


   --this profile_value is to indicate if want to pass all the lines or just one line
   --to pricing engine
   --In the case of order level manual adjustments we will always pass in
   --all the lines regardless of profile_value
   --bug 3531938 calling qp api to determine whether to pass all lines
                QP_UTIL_PUB.Get_Order_Lines_Status('BATCH',l_order_status_rec);

                oe_debug_pub.add('  All_lines_flag returned from pricing:'||l_order_status_rec.all_lines_flag);
-- bug 6817566
    oe_debug_pub.add(' manual_adv_modifier '||OE_GLOBALS.G_MANUAL_ADV_MODIFIER);

   IF (OE_GLOBALS.G_MANUAL_ADV_MODIFIER IS NULL AND (p_level = 'ORDER' or l_order_status_rec.ALL_LINES_FLAG = 'Y')) THEN
        oe_debug_pub.add(' manual_adv_modifier 1 '||OE_GLOBALS.G_MANUAL_ADV_MODIFIER);
        oe_debug_pub.add(' p_level '||p_level);
        oe_debug_pub.add(' Check for Manual Advanced modifiers ',3);
        --- bug# 7600510  Start
--        GET_MANUAL_ADV_STATUS('BATCH');
        QP_UTIL_PUB.Get_Manual_All_Lines_Status ('BATCH', l_manual_all_lines_status ) ;
        OE_GLOBALS.G_MANUAL_ADV_MODIFIER := l_manual_all_lines_status;
        --- bug# 7600510  End
        oe_debug_pub.add(' manual_adv_modifier 2 '||OE_GLOBALS.G_MANUAL_ADV_MODIFIER);
   END IF;

   IF (((p_level = 'ORDER' or l_order_status_rec.ALL_LINES_FLAG = 'Y')
   AND(p_level = 'ORDER' or  OE_GLOBALS.G_MANUAL_ADV_MODIFIER = 'Y')) -- 6851818
   AND p_header_id Is Not Null) Then

    if  not (p_level = 'ORDER' and p_freight_flag) then --- bug 7655559
	      --passing all lines under this header
	      oe_debug_pub.add('  Query Rows under same header');

	      oe_Line_util.query_rows(p_header_id => p_Header_id, x_line_tbl => l_Line_Tbl);
	      oe_debug_pub.add('#of rows returned='|| to_char(l_line_tbl.count));
	      oe_debug_pub.add('no.rows in l_line_tbl = '|| to_char(l_line_tbl.count));

	      -- Bug 1713035
	      -- Loop through all the lines in database
	      -- Replace with the line in memory if found
	      -- else append

	      oe_debug_pub.add('Get line currently in memory');
	      OE_OE_FORM_LINE.get_line(p_line_id => p_line_id,
				       x_line_rec => l_line_rec);
	      For i in 1..l_line_tbl.count Loop
		if (l_line_tbl(i).line_id = l_line_rec.line_id) then
			oe_debug_pub.add('Line already posted to DB, so replace');
			l_posted_to_db := TRUE;
			l_line_tbl(i) := l_line_rec;
			exit;
		end if;
	      end loop;

	      if NOT l_posted_to_db then
		oe_debug_pub.add('line not in DB, new line');
		oe_debug_pub.add('appending line with line_id '
				|| to_char(p_line_id) ||
				' to l_line_tbl');
		/*Bug 3280291*/
		IF l_line_rec.line_id is not NULL THEN
		   l_line_tbl(l_line_tbl.count + 1) := l_line_rec;
		END IF;
	      end if;
    end if;--- bug 7655559

   Elsif p_line_id is not null Then
      --just pass one line
      oe_debug_pub.add('  Query Rows under for line line id:'||p_line_id);
      --oe_line_util.query_row(p_line_id =>p_line_id,x_line_rec=>l_line_rec);

      -- Bug 1713035
      -- Use oe_oe_form_line.get_line instead of query_rows
      oe_debug_pub.add('calling get_line in oe_oe_form_line');
      OE_OE_FORM_LINE.get_line(
			p_line_id => p_line_id,
			x_line_rec => l_line_rec);

      l_line_tbl(1):=l_line_rec;
   Else
      l_line_tbl(1):= p_line_rec;
   End If;

   OE_Order_PUB.G_LINE := NULL;
   OE_Order_PUB.G_HDR  := NULL;

   If p_header_id is Not Null and p_cross_order = 'N' Then
     oe_Header_util.query_row(p_header_id=>p_header_id,x_header_rec => OE_Order_PUB.g_hdr );
   End If;


   G_STMT_NO := 'Get_manual_adjustment#1';
   line_tbl_index := l_line_tbl.First;
   While line_Tbl_Index is not null loop

     --Cross order lines, lines may not came from same header need to query header for each line
     If p_cross_order = 'Y' and  p_header_id Is  Null Then
       oe_Header_util.query_row(p_header_id=>l_line_tbl(line_tbl_index).header_id,
                                x_header_rec => OE_Order_PUB.g_hdr );
       oe_debug_pub.add('  Currency Code:'||OE_Order_PUB.g_hdr.transactional_curr_code);
       x_header_id := l_line_tbl(line_tbl_index).header_id;
     End If;

      --Populate global structure since attribute mapping only read global structure
       OE_Order_PUB.G_LINE := l_Line_Tbl(line_Tbl_Index);
     Begin
       IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110510' THEN
              --5598523
          IF l_line_tbl(line_tbl_index).line_id=p_line_id THEN
		l_check_line_flag := 'N';
	  ELSE
		l_check_line_flag := 'Y';
          END IF;

    	   l_line_index := l_line_index + 1; --added for BUG#8945171
	   /* will increment the index by 1 initially, un-conditionally and will retain it or decrement it
	   based on the the o/p for its Build Context.
	   If -- QP says pass this line we will retain the index else we will decrement it. */

           QP_Attr_Mapping_PUB.Build_Contexts(p_request_type_code => 'ONT',
                                       p_pricing_type_code      =>      'L',
                                       --p_line_index => line_Tbl_Index, commeneted for BUG#8945171 --l_line_tbl(line_tbl_index).header_id + l_line_tbl(line_tbl_index).line_id,
                                       p_line_index => l_line_index, --added for BUG#8945171 from now on we will use  l_line_index instead of line_Tbl_Index to build context for lines as this is the index we use to build the context for header also.
                                       p_check_line_flag         => l_check_line_flag,  --5598523
                                       p_pricing_event           => l_event,
                                       x_pass_line               => l_pass_line);
       ELSE
           QP_Attr_Mapping_PUB.Build_Contexts(p_request_type_code => 'ONT',
			               p_pricing_type	=>	'L',
			               x_price_contexts_result_tbl => l_pricing_contexts_Tbl,
			               x_qual_contexts_result_tbl  => l_qualifier_Contexts_Tbl);
       END IF;
       OE_Order_PUB.G_LINE := NULL;
     Exception
         When Others then
           oe_debug_pub.add('  QP ATTR MAPPING ERRORS 1');
         Raise QP_ATTR_MAPPING_ERRORS;
     End;
    G_STMT_NO := 'Get_manual_adjustment#2';

     -- Fix for bug 1807636
     -- Pass 'N' as the value of the p_honor_price_flag
     -- so that manual modifiers can be applied to RMA
     -- which is a copy of an order
-- bucket man
     IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110510' THEN
      IF l_pass_line='Y' OR l_check_line_flag = 'N' THEN  --5598523
        --l_line_index := l_line_index + 1; --commented for BUG#8945171. we are now handling this above build context for lines.
        oe_order_price_pvt.copy_Line_to_request( p_Line_rec
=> l_Line_Tbl(line_Tbl_Index)
                           ,p_pricing_events            => l_event
                           ,px_req_line_tbl             => l_req_line_tbl
                           ,p_Request_Type_Code         => 'ONT'
                           ,p_honor_price_flag          => 'N'
                           ,px_line_index       => l_line_index
                           );
        ELSE --added for BUG#8945171
        -- if pricing says not to pass the line we will decrement the index
        l_line_index := l_line_index - 1;--added fpr BUG#8945171
	END IF; --5598523
     ELSE
        copy_Line_to_request( p_Line_rec	 		=> l_Line_Tbl(line_Tbl_Index)
			   ,p_pricing_event		=> l_event
	 		   ,px_req_line_tbl   	        => l_req_line_tbl
	 		   ,p_Request_Type_Code 	=> 'ONT'
			   ,p_honor_price_flag		=> 'N'
			   );
     END IF;
/* --5598523 No need for this code as change done by this logic is not reflected while inserting data
   --into qp tables because direct insert is done using global str and hence changes made here are not used.
      --In the case of Order level manual adjustments we will need to set calculate price
      --flag for all the lines to 'N'and summary line to 'Y'
     If p_level = 'ORDER' or l_profile_value = 'Y' Then
       l_req_line_tbl(l_req_line_tbl.count).price_flag := 'N';
       null;
     End If;

     If l_profile_value = 'Y' and l_req_line_tbl(l_req_line_tbl.count).line_id = p_line_id Then
        --set the current line to 'Y' in the case of linegroup option.  We need to pass all other lines
        --to pricing engine with N.
        l_req_line_tbl(l_req_line_tbl.count).price_flag := 'Y';
     End If;
*/
 -- bucket man
     IF OE_CODE_CONTROL.Get_Code_Release_Level < '110510' THEN
        copy_attribs_to_Req(   p_line_index            => 	l_req_line_tbl.count
			   ,p_pricing_contexts_Tbl 	=> 	l_pricing_contexts_Tbl
			   ,p_qualifier_contexts_Tbl =>	l_qualifier_Contexts_Tbl
			   ,px_Req_line_attr_tbl    =>	l_Req_line_attr_tbl
			   ,px_Req_qual_tbl         =>	l_Req_qual_tbl );
     END IF;

     If l_ask_for_profile = 'Y' Then
     Begin
       l_header_id2:=nvl(p_header_id,l_line_tbl(line_tbl_index).header_id);

         Select 'x' into l_dummy from dual
         Where exists
         (select 'x' from
         oe_order_price_attribs oopa
         where
         nvl(oopa.line_id,l_Line_Tbl(line_Tbl_Index).line_id) = l_Line_Tbl(line_Tbl_Index).line_id
         and oopa.header_id = l_header_id2);

 -- bucket man
        IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110510' THEN
		IF l_pass_line='Y' THEN  --5598523
           oe_order_price_pvt.Append_asked_for(p_header_id    => l_header_id2,

              p_line_id            => l_Line_Tbl(line_Tbl_Index).line_id,

              p_line_index            =>   l_line_index,

              px_line_attr_index => l_line_attr_index
              );
	    END IF; --5598523

        ELSE
           Append_asked_for(p_header_id    => l_header_id2,
              p_line_id            => l_Line_Tbl(line_Tbl_Index).line_id,
              p_line_index            =>   l_req_line_tbl.count ,
              px_Req_line_attr_tbl => l_Req_line_attr_tbl,
              px_Req_qual_tbl      => l_Req_qual_tbl
              );
        END IF;
     Exception when no_data_found then null;
     End;
     End If;



     line_Tbl_Index := l_Line_Tbl.Next(line_Tbl_Index);

   End Loop;
   G_STMT_NO := 'Get_manual_adjustment#3';

   Begin
-- bucket man
    IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110510' THEN
       QP_Attr_Mapping_PUB.Build_Contexts(
                        p_request_type_code => 'ONT',
                        p_pricing_type_code     =>      'H',
                        p_line_index=> l_line_index + 1 --oe_order_pub.g_hdr.header_id
                        );
    ELSE
       QP_Attr_Mapping_PUB.Build_Contexts(
			p_request_type_code => 'ONT',
			p_pricing_type	=>	'H',
			x_price_contexts_result_tbl => l_pricing_contexts_Tbl,
			x_qual_contexts_result_tbl  => l_qualifier_Contexts_Tbl
			);
    END IF;
   Exception
         --when no_data_found then
          --('  QP ATTR MAPPING ERRORS 2');
         When Others then
           Oe_Debug_Pub.Add('  QP ATTR MAPPING ERRORS 2');
         Raise QP_ATTR_MAPPING_ERRORS;

  End;

   -- bucket man
  IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110510' THEN
     oe_order_price_pvt.copy_Header_to_request(
                 p_header_rec       => OE_Order_PUB.g_hdr
                 ,px_req_line_tbl   => l_req_line_tbl
                 ,p_Request_Type_Code => 'ONT'
                 ,p_calculate_price_flag =>'Y'
                 ,px_line_index => l_line_index
                 );
  ELSE
     copy_Header_to_request(
		 p_header_rec       => OE_Order_PUB.g_hdr
		 ,px_req_line_tbl   => l_req_line_tbl
		 ,p_Request_Type_Code => 'ONT'
                 ,p_calculate_price_flag =>'Y'
		 );
  END IF;

	G_STMT_NO := 'Get_manual_adjustment#90';
  IF OE_CODE_CONTROL.Get_Code_Release_Level < '110510' THEN
	copy_attribs_to_Req(
		p_line_index             => l_req_line_tbl.count
		,p_pricing_contexts_Tbl 	=> 	l_pricing_contexts_Tbl
		,p_qualifier_contexts_Tbl =>	l_qualifier_Contexts_Tbl
		,px_Req_line_attr_tbl    =>	l_Req_line_attr_tbl
		,px_Req_qual_tbl         =>	l_Req_qual_tbl
					);
  END IF;

       If l_ask_for_profile = 'Y' Then
        Begin
	        --Modified for bug 3502454
                --l_header_id2:=nvl(p_header_id,l_line_tbl(l_line_tbl.first).header_id);
                IF ( p_header_id IS NULL ) THEN
                  l_header_id2 := l_line_tbl(l_line_tbl.first).header_id;
                ELSE
                  l_header_id2 := p_header_id;
                END IF;
                -- End of 3502454
		Select 'x' into l_dummy from dual
                where exists(
                  Select 'X' from oe_order_price_attribs oopa
		where oopa.header_id = l_header_id2 and oopa.line_id is null);

                IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110510' THEN
                   oe_order_price_pvt.Append_asked_for(
                        p_header_id                     => l_header_id2
                        , p_line_id                       => NULL
                        ,p_line_index             => l_line_index
                        , px_line_attr_index => l_line_attr_index
                        );
                ELSE
                   Append_asked_for(
			p_header_id			=> l_header_id2
			,p_line_index             => l_req_line_tbl.count
			,px_Req_line_attr_tbl    =>	l_Req_line_attr_tbl
			,px_Req_qual_tbl         =>	l_Req_qual_tbl
			);
                END IF;
	 Exception when no_data_found then null;
	 End;
        End If;

   If l_req_line_tbl(l_req_line_tbl.count).line_type_code = 'ORDER' and
      p_level = 'ORDER' Then
        l_req_line_tbl(l_req_line_tbl.count).price_flag := 'Y';
   End If;

   IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110510' THEN
      IF l_line_index > 0 THEN
         If l_debug_level > 0 Then
             oe_debug_pub.add('before Populate_Temp_Table');
         End If;
         oe_order_price_pvt.Populate_Temp_Table;
      END IF;
      l_control_rec.request_type_code := 'ONT';
      l_control_rec.temp_table_insert_flag := 'N';
   END IF;
l_control_rec.pricing_event := l_event;
l_control_rec.calculate_flag:= qp_preq_grp.G_SEARCH_N_CALCULATE;
l_control_rec.manual_adjustments_call_flag:=qp_preq_grp.G_YES;
 --Will need to do the same thing for header level manual adjustment
-- sgowtham
if( p_freight_flag = TRUE) then
l_control_rec.GET_FREIGHT_FLAG := 'Y';
else
l_control_rec.GET_FREIGHT_FLAG := 'N';
end if;

   IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110510' THEN
      QP_PREQ_PUB.PRICE_REQUEST
                (p_control_rec           => l_control_rec
                ,x_return_status         =>l_return_status
                ,x_return_status_Text    =>l_return_status_Text
                );
   ELSE
      QP_PREQ_GRP.PRICE_REQUEST
		(p_control_rec		 => l_control_rec
		,p_line_tbl              => l_Req_line_tbl
 		,p_qual_tbl              => l_Req_qual_tbl
  		,p_line_attr_tbl         => l_Req_line_attr_tbl
		,p_line_detail_tbl       =>l_req_line_detail_tbl
	 	,p_line_detail_qual_tbl  =>l_req_line_detail_qual_tbl
	  	,p_line_detail_attr_tbl  =>l_req_line_detail_attr_tbl
	   	,p_related_lines_tbl     =>l_req_related_lines_tbl
		,x_line_tbl              =>lx_req_line_tbl
	   	,x_line_qual             =>lx_Req_qual_tbl
	    	,x_line_attr_tbl         =>lx_Req_line_attr_tbl
		,x_line_detail_tbl       =>lx_req_line_detail_tbl
	 	,x_line_detail_qual_tbl  =>lx_req_line_detail_qual_tbl
	  	,x_line_detail_attr_tbl  =>lx_req_line_detail_attr_tbl
	   	,x_related_lines_tbl     =>lx_req_related_lines_tbl
	    	,x_return_status         =>l_return_status
	    	,x_return_status_Text    =>l_return_status_Text
		);
   END IF;

                IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
			RAISE FND_API.G_EXC_ERROR;
		END IF;
                g_stmt_no :='Get Manual Adj#5';
      IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110510' THEN
         i := 1;
                g_stmt_no :='Get Manual Adj#5.5';
                for k In man_adj Loop
                  If k.automatic_flag = 'N' Then
                    If l_debug_level > 0 Then
                       Oe_Debug_Pub.Add('+Line_type_code:'||k.line_type_code);
                       Oe_Debug_Pub.Add('+List_line_no:'||k.list_line_no);
                    End If;

                   --Only return 1 set of lov per line id or per header id
                   If (p_level In ('ORDER') and
                      (k.line_type_code = 'ORDER' or
                      k.modifier_level_code = 'LINEGROUP'))
                      Or
                      (p_level in ('LINE','LINEGROUP') and
                       k.line_type_code = 'LINE' and
                       k.line_id=p_line_id)
                      Or
                       (p_level = 'ALL' and
                       ((k.line_type_code = 'LINE' and
                        k.line_id=p_line_id)
                        or
                        k.line_type_code = 'ORDER')
                        )

                   Then
                     If (p_pbh_mode = 'CHILD' and nvl(k.line_quantity,0) > 0
                        and k.line_detail_type_code = QP_PREQ_GRP.G_CHILD_DETAIL_TYPE)
                        --Regular discount lines
                        or (k.list_line_type_code <> 'PBH' AND
                            k.line_detail_type_code <> QP_PREQ_GRP.G_CHILD_DETAIL_TYPE)
                        --Price break header (parent)
                        or (p_pbh_mode = 'PARENT' and k.list_line_type_code = 'PBH')
                     Then
                      If p_called_from = 'SO' Then
                       If k.pricing_group_sequence is null then
                        x_manual_adj_tbl(i).modifier_number:=k.list_line_no;
                        x_manual_adj_tbl(i).list_line_type_code :=k.list_line_type_code;
                        x_manual_adj_tbl(i).operand := k.operand_value;
                        x_manual_adj_tbl(i).list_line_id     :=k.list_line_id;
                        x_manual_adj_tbl(i).list_header_id   :=k.list_header_id;
                        x_manual_adj_tbl(i).pricing_phase_id :=k.pricing_phase_id;
                        x_manual_adj_tbl(i).automatic_flag   :=k.automatic_flag;
                        x_manual_adj_tbl(i).modifier_level_code:=k.modifier_level_code;
                        x_manual_adj_tbl(i).override_flag   :=k.override_flag;
                        x_manual_adj_tbl(i).operator        :=k.operand_calculation_code;
                        x_manual_adj_tbl(i).adjusted_amount :=k.ADJUSTMENT_AMOUNT;
                        x_manual_adj_tbl(i).charge_type_code :=k.CHARGE_TYPE_CODE;
                        x_manual_adj_tbl(i).CHARGE_SUBTYPE_CODE :=k.CHARGE_SUBTYPE_CODE;
                        x_manual_adj_tbl(i).PRICE_BREAK_TYPE_CODE := k.PRICE_BREAK_TYPE_CODE;
                        i := i + 1;
                       End If;
                      Else
                        x_manual_adj_tbl(i).modifier_number:=k.list_line_no;
                        x_manual_adj_tbl(i).list_line_type_code :=k.list_line_type_code;
                        x_manual_adj_tbl(i).operand := k.operand_value;
                        x_manual_adj_tbl(i).list_line_id     :=k.list_line_id;
                        x_manual_adj_tbl(i).list_header_id   :=k.list_header_id;                        x_manual_adj_tbl(i).pricing_phase_id :=k.pricing_phase_id;
                        x_manual_adj_tbl(i).automatic_flag   :=k.automatic_flag;                        x_manual_adj_tbl(i).modifier_level_code:=k.modifier_level_code;
                        x_manual_adj_tbl(i).override_flag   :=k.override_flag;
                        x_manual_adj_tbl(i).operator        :=k.operand_calculation_code;
                        x_manual_adj_tbl(i).adjusted_amount :=k.ADJUSTMENT_AMOUNT;
                        x_manual_adj_tbl(i).charge_type_code :=k.CHARGE_TYPE_CODE;
                         x_manual_adj_tbl(i).CHARGE_SUBTYPE_CODE :=k.CHARGE_SUBTYPE_CODE;
                        x_manual_adj_tbl(i).PRICE_BREAK_TYPE_CODE := k.PRICE_BREAK_TYPE_CODE;
                        x_manual_adj_tbl(i).PRICING_GROUP_SEQUENCE := k.PRICING_GROUP_SEQUENCE;
                        i := i + 1;
                      End If;
                     End If;

                   End If;
                  End If;


                End Loop;
      ELSE
	    	i:=lx_req_line_detail_tbl.first;
                g_stmt_no :='Get Manual Adj#5.5';
	        While i Is not Null Loop
                  If lx_req_line_detail_tbl(i).automatic_flag = 'N' Then
                  Oe_Debug_Pub.Add('+Line_type_code:'||l_req_line_tbl(lx_req_line_detail_tbl(i).line_index).line_type_code);
                  Oe_Debug_Pub.Add('+List_line_no:'||lx_req_line_detail_tbl(i).list_line_no);

                   --Only return 1 set of lov per line id or per header id
                   If (p_level In ('ORDER') and
                      (l_req_line_tbl(lx_req_line_detail_tbl(i).line_index).line_type_code = 'ORDER' or
                      lx_req_line_detail_tbl(i).modifier_level_code = 'LINEGROUP'))
                      Or
                      (p_level in ('LINE','LINEGROUP') and
                       l_req_line_tbl(lx_req_line_detail_tbl(i).line_index).line_type_code = 'LINE' and
                       l_req_line_tbl(lx_req_line_detail_tbl(i).line_index).line_id=p_line_id)
                      Or
                       (p_level = 'ALL' and
                        ((l_req_line_tbl(lx_req_line_detail_tbl(i).line_index).line_type_code = 'LINE' and
                        l_req_line_tbl(lx_req_line_detail_tbl(i).line_index).line_id=p_line_id)
                        or
                        l_req_line_tbl(lx_req_line_detail_tbl(i).line_index).line_type_code = 'ORDER')
                        )

                   Then
                     If (p_pbh_mode = 'CHILD' and nvl(lx_req_line_detail_tbl(i).line_quantity,0) > 0
                        and lx_req_line_detail_tbl(i).line_detail_type_code = QP_PREQ_GRP.G_CHILD_DETAIL_TYPE)
                        --Regular discount lines
                        or (lx_req_line_detail_tbl(i).list_line_type_code <> 'PBH' AND
                            lx_req_line_detail_tbl(i).line_detail_type_code <> QP_PREQ_GRP.G_CHILD_DETAIL_TYPE)
                        --Price break header (parent)
                        or (p_pbh_mode = 'PARENT' and lx_req_line_detail_tbl(i).list_line_type_code = 'PBH')
                     Then
                       x_manual_adj_tbl(i).modifier_number:=lx_req_line_detail_tbl(i).list_line_no;
                       x_manual_adj_tbl(i).list_line_type_code :=lx_req_line_detail_tbl(i).list_line_type_code;
                       x_manual_adj_tbl(i).operand          :=lx_req_line_detail_tbl(i).operand_value;
                       x_manual_adj_tbl(i).list_line_id     :=lx_req_line_detail_tbl(i).list_line_id;
                       x_manual_adj_tbl(i).list_header_id   :=lx_req_line_detail_tbl(i).list_header_id;
                       x_manual_adj_tbl(i).pricing_phase_id :=lx_req_line_detail_tbl(i).pricing_phase_id;
                       x_manual_adj_tbl(i).automatic_flag   :=lx_req_line_detail_tbl(i).automatic_flag;
                       x_manual_adj_tbl(i).modifier_level_code:=lx_req_line_detail_tbl(i).modifier_level_code;
                       x_manual_adj_tbl(i).override_flag   :=lx_req_line_detail_tbl(i).override_flag;
                       x_manual_adj_tbl(i).operator        :=lx_req_line_detail_tbl(i).operand_calculation_code;
                       x_manual_adj_tbl(i).adjusted_amount :=round(lx_req_line_detail_tbl(i).ADJUSTMENT_AMOUNT,6);
oe_debug_pub.add('get manual adj:after round:'||x_manual_adj_tbl(i).adjusted_amount);
                       x_manual_adj_tbl(i).charge_type_code :=lx_req_line_detail_tbl(i).CHARGE_TYPE_CODE;
                       x_manual_adj_tbl(i).CHARGE_SUBTYPE_CODE :=lx_req_line_detail_tbl(i).CHARGE_SUBTYPE_CODE;
                     End If;

                   End If;
                  End If;


                  i:=lx_req_line_detail_tbl.next(i);
                End Loop;

      END IF;
	  -- Bug 1713035
          -- if p_line_level='Y', then we want
          -- only line/linegroup level manual adjustments
          -- Loop through x_manual_adj_tbl and delete all ORDER
          -- level adjustments in case p_line_level='Y'


         if (p_line_level = 'Y') then
	   j:=x_manual_adj_tbl.first;
 	   while j is NOT NULL Loop
            IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110510' THEN
              if (x_manual_adj_tbl(j).modifier_level_code   = 'ORDER' or
                 (x_manual_adj_tbl(j).price_break_type_code = 'RANGE' --bucket man
                  and p_pbh_mode <> 'PARENT'
                  )
                 ) then
                    oe_debug_pub.add(' Manual adj call: deleting order level adjustment');
                 oe_debug_pub.add(' Manual adj call: remove RANGE break');
                 x_manual_adj_tbl.delete(j);
             end if;
            ELSE
	     if (x_manual_adj_tbl(j).modifier_level_code   = 'ORDER' or
                 (lx_req_line_detail_tbl(j).price_break_type_code = 'RANGE'
                  and p_pbh_mode <> 'PARENT'
                  )
                 ) then

                 --we do not support range break from 'LINE' tab of sales order form.
                 --because due to the fact that in 'LINE' tab we only shows
                 --eligible child break.  And, 'RANGE' break goes across multiple
                 --children. We support manual range break from view adjustments form
                 --because in view adjustments, it is the parent PBH a user get to choose
                 --and the system will insert all range break children.

                 oe_debug_pub.add(' Manual adj call: deleting order level adjustment');
                 oe_debug_pub.add(' Manual adj call: remove RANGE break');
		 x_manual_adj_tbl.delete(j);
             end if;
            END IF;
	     j := x_manual_adj_tbl.next(j);
           End loop;
	  end if;

          Oe_Debug_Pub.add('Exiting Get manual adj');

    EXCEPTION

	      WHEN FND_API.G_EXC_ERROR THEN

		  FND_MESSAGE.SET_NAME('ONT','OE_PRICING_ERROR');
		  FND_MESSAGE.SET_TOKEN('ERR_TEXT',l_return_status_Text);
		  OE_MSG_PUB.Add;
		  x_return_status := FND_API.G_RET_STS_ERROR;

			Oe_Debug_Pub.add('g_exc_error is '||g_stmt_no||' '||sqlerrm,1);
			Oe_Debug_Pub.add('g_exc_error is '||l_return_status_Text);
                        --DBMS_OUTPUT.PUT_LINE('g_exc_error is '||l_return_status_Text);
			RAISE FND_API.G_EXC_ERROR;

		WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

		  FND_MESSAGE.SET_NAME('ONT','OE_PRICING_ERROR');
		  FND_MESSAGE.SET_TOKEN('ERR_TEXT',l_return_status_Text);
		  OE_MSG_PUB.Add;
			x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
			Oe_Debug_Pub.add('G_EXC_UNEXPECTED_ERROR is '||g_stmt_no||' '||sqlerrm,1);
			Oe_Debug_Pub.add('G_EXC_UNEXPECTED_ERROR is '||l_return_status_Text);
                        --DBMS_OUTPUT.PUT_LINE('G_EXC_UNEXPECTED_ERROR is '||l_return_status_Text);
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                WHEN QP_ATTR_MAPPING_ERRORS Then
                  FND_MESSAGE.SET_NAME('ONT','OE_PRICING_ERROR');
		  FND_MESSAGE.SET_TOKEN('ERR_TEXT','Errors return from QP_Attr_Mapping_PUB.Build_Context');
		  OE_MSG_PUB.Add;
			x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
			Oe_Debug_Pub.add('G_EXC_UNEXPECTED_ERROR is: QP_Attr_Mapping_PUB.Build_Context'||sqlerrm,1);
			Oe_Debug_Pub.add('G_EXC_UNEXPECTED_ERROR is '||l_return_status_Text);
                        Oe_Debug_Pub.add('QP_ATTR_MAPPING_ERRORS');
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		WHEN OTHERS THEN

			x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
			Oe_Debug_Pub.add('Error is '||sqlerrm);
			Oe_Debug_Pub.add('Error Code is '||g_stmt_no||' '||sqlerrm,1);

			IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
			THEN
				OE_MSG_PUB.Add_Exc_Msg
				(   G_PKG_NAME
				,   'oe_line_adj.calulate_adjustments',
					g_stmt_no||' '||sqlerrm
				);
			END IF;

			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

End Get_Manual_Adjustments;

-- PROMOTIONS SEP/01
Procedure Promotion_Put_Hold(
p_header_id                             Number
,p_line_id				Number
)
is
l_hold_source_rec		OE_Holds_Pvt.hold_source_rec_type;
l_hold_release_rec  		OE_Holds_Pvt.Hold_Release_REC_Type;
l_return_status			varchar2(30);
l_x_msg_count                   number;
l_x_msg_data                    Varchar2(2000);
l_x_result_out                  Varchar2(30);
l_list_name			varchar2(240);
l_operand			number;
l_msg_text			Varchar2(200);

Begin

adj_debug('PROMOTIONS - start of procedure Promotion_Put_Hold ');

		-- use the seeded hold_id
  IF (p_line_id IS NULL) THEN
      adj_debug('putting header '||p_header_id||' on hold',3);

      l_hold_source_rec.hold_id := G_SEEDED_PROM_ORDER_HOLD_ID;
  ELSE
      adj_debug('putting line '||p_line_id||' on hold',3);
      l_hold_source_rec.hold_id := G_SEEDED_PROM_LINE_HOLD_ID;
  END IF;

--adj_debug('PAL PROMOTIONS - after select in procedure Promotion_Put_Hold ');
--adj_debug('PAL PROMOTIONS - hold id is '|| l_hold_source_rec.hold_id,2);
--adj_debug('PAL PROMOTIONS - header_id is '|| p_header_id,2);
--adj_debug('PAL PROMOTIONS - line_id is '|| p_line_id,2);


	l_hold_source_rec.hold_entity_id := p_header_id;
        l_hold_source_rec.header_id := p_header_id;
        l_hold_source_rec.line_id := p_line_id;
	l_hold_source_rec.Hold_Entity_code := 'O';

       -- check if line already on PROMOTION hold, place hold if not

  			        OE_Holds_Pub.Check_Holds(
					p_api_version		=> 1.0
                                        ,p_header_id            => p_header_id
					,p_line_id		=> p_line_id
					,p_hold_id		=> l_hold_source_rec.Hold_id
					,x_return_status	=> l_return_status
					,x_msg_count		=> l_x_msg_count
					,x_msg_data		=> l_x_msg_data
					,x_result_out		=> l_x_result_out
					);

--adj_debug('PAL PROMOTIONS - hold_entity_code is '|| l_hold_source_rec.Hold_Entity_code||l_x_result_out,2);

           IF (l_return_status <> FND_API.g_ret_sts_success) THEN
              RAISE FND_API.G_EXC_ERROR;
           END IF;
  	        If  l_x_result_out = FND_API.G_FALSE then
                                  adj_debug('PAL PROMOTIONS - apply holds in procedure Promotion_Put_Hold ');
                                  adj_debug('hold line with header_id:'||p_header_id||' line_id: '||p_line_id,1);
				  OE_HOLDS_PUB.Apply_Holds(
					p_api_version		=> 1.0
					,p_hold_source_rec	=> l_hold_source_rec
					,x_return_status	=> l_return_status
					,x_msg_count		=> l_x_msg_count
					,x_msg_data		=> l_x_msg_data
					);

	  If l_return_status = FND_API.g_ret_sts_success then
             IF (p_line_id IS NULL) THEN
		FND_MESSAGE.SET_NAME('ONT','ONT_PROMO_HOLD_APPLIED');
             ELSE
                FND_MESSAGE.SET_NAME('ONT', 'ONT_LINE_PROMO_HOLD_APPLIED');
             END IF;
		OE_MSG_PUB.Add;
	  Else
                adj_debug('error applying hold',3);
		RAISE FND_API.G_EXC_ERROR;
	  End If;
       End If; /* check hold */

-- adj_debug('PROMOTIONS - end of procedure Promotion_Put_Hold ');
end Promotion_Put_Hold; -- PROMOTIONS SEP/01

PROCEDURE GET_MANUAL_ADV_STATUS(p_event_code IN VARCHAR2) AS

CURSOR l_send_all_lines_cur(p_event_code1 VARCHAR2) IS
SELECT 'X'
FROM
         qp_list_headers_b qh,
         qp_list_lines ql,
         qp_pricing_attributes qppr
WHERE  ql.list_line_id = qppr.list_line_id
AND    ql.automatic_flag = 'N'
AND    qh.list_header_id = ql.list_header_id
AND    qh.active_flag = 'Y'
AND    qh.list_type_code not in ('AGR','PRL')
AND    ql.list_line_type_code <> 'PLL'
AND    (ql.list_line_type_code IN ('PRG','OID') OR ql.modifier_level_code =
'LINEGROUP')
AND    qppr.product_attribute_context='ITEM'     -- bug#7488440
AND    qppr.product_attribute='PRICING_ATTRIBUTE3'  -- bug#7488440
AND    qppr.product_attr_value='ALL'    -- bug#7488440
AND    qppr.pricing_phase_id
         IN ( SELECT  distinct a.pricing_phase_id
              FROM qp_pricing_phases a , qp_event_phases b
              WHERE
              a.pricing_phase_id = b.pricing_phase_id
--              AND (a.oid_exists = 'Y' OR a.line_group_exists = 'Y' OR a.rltd_exists = 'Y')  -- bug#7488440
              AND    b.pricing_event_code in (SELECT decode(rownum
          ,1 ,substr(p_event_code,1,instr(p_event_code1,',',1,1)-1)
          ,2 ,substr(p_event_code , instr(p_event_code1,',',1,rownum-1) + 1,
             instr(p_event_code1,',',1,rownum)-1 -
instr(p_event_code1,',',1,rownum-1))
          ,3 ,substr(p_event_code , instr(p_event_code1,',',1,rownum-1) + 1,
              instr(p_event_code1,',',1,rownum)-1 -
instr(p_event_code1,',',1,rownum-1))
          ,4 ,substr(p_event_code , instr(p_event_code1,',',1,rownum-1) + 1,
              instr(p_event_code1,',',1,rownum)-1 -
instr(p_event_code1,',',1,rownum-1))
          ,5 ,substr(p_event_code , instr(p_event_code1,',',1,rownum-1) + 1,
              instr(p_event_code1,',',1,rownum)-1 -
instr(p_event_code1,',',1,rownum-1))
          ,6 ,substr(p_event_code , instr(p_event_code1,',',1,rownum-1) + 1,
              instr(p_event_code1,',',1,rownum)-1 -
instr(p_event_code1,',',1,rownum-1)))
         FROM  qp_event_phases
         WHERE rownum < 7))
AND    ROWNUM = 1;

x_get_manual_adv VARCHAR2(1);

BEGIN
oe_debug_pub.add(' Inside GET_MANUAL_ADV_STATUS ',3);
x_get_manual_adv := NULL;

OPEN l_send_all_lines_cur(p_event_code || ',') ;
FETCH l_send_all_lines_cur INTO x_get_manual_adv;
CLOSE l_send_all_lines_cur;

        If x_get_manual_adv = 'X' THEN
        oe_debug_pub.add('Manual adv modifiers exist');
        OE_GLOBALS.G_MANUAL_ADV_MODIFIER := 'Y';
        ELSE
        oe_debug_pub.add('Manual adv modifiers do not exist');
        OE_GLOBALS.G_MANUAL_ADV_MODIFIER := 'N';
        END IF;


oe_debug_pub.add('return_value '||OE_GLOBALS.G_MANUAL_ADV_MODIFIER,3);
oe_debug_pub.add(' Leaving GET_MANUAL_ADV_STATUS ',3);
END GET_MANUAL_ADV_STATUS;

end Oe_Order_Adj_Pvt;

/
