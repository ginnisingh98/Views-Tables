--------------------------------------------------------
--  DDL for Package Body OE_BLANKET_PRICING_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_BLANKET_PRICING_UTIL" AS
/* $Header: OEXQPBLB.pls 120.4.12010000.3 2009/09/24 09:02:04 smanian ship $ */
G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_Blanket_Pricing_Util';
G_BINARY_LIMIT CONSTANT NUMBER := OE_GLOBALS.G_BINARY_LIMIT; --bug8465849

FUNCTION IS_BLANKET_PRICE_LIST(p_price_list_id NUMBER
                               -- 11i10 Pricing Change
                               ,p_blanket_header_id NUMBER DEFAULT NULL)
RETURN BOOLEAN IS
l_dummy VARCHAR2(30);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

     if l_debug_level > 0 then
        oe_debug_pub.add('Enter OEXQPBLB IS_BLANKET_PRICE_LIST');
     end if;


        SELECT 'VALID'
        INTO l_dummy
        FROM QP_LIST_HEADERS
        WHERE LIST_HEADER_ID = p_price_list_id
        AND LIST_SOURCE_CODE = 'BSO'
        AND orig_system_header_ref = to_char(p_blanket_header_id);

     RETURN TRUE;

EXCEPTION
WHEN NO_DATA_FOUND THEN
   if l_debug_level > 0 then
     oe_debug_pub.ADD('Not a blanket price list', 1);
   end if;
     RETURN FALSE;

END IS_BLANKET_PRICE_LIST;

--------------------------------------------------------------------------
-- 11i10 Pricing Changes
-- Procedure to create modifier header and lines
-- Common procedure to process requests of type 'CREATE_MODIFIER_LIST'
-- and 'ADD_MODIFIER_LIST_LINE'
--------------------------------------------------------------------------
PROCEDURE Create_Modifiers
(p_index                        IN NUMBER,
 x_return_status                OUT NOCOPY VARCHAR2
)IS

   l_request_rec                OE_Order_PUB.Request_Rec_Type;
   l_modifier_list_id           NUMBER;
   l_blanket_header_id          NUMBER;
   I                            NUMBER;
   J                            NUMBER;
   l_return_status              varchar2(1);
   l_msg_count                  NUMBER;
   l_msg_data                   varchar2(2000);

   l_modifier_list_rec          QP_Modifiers_PUB.Modifier_List_Rec_Type;
   l_modifier_list_val_rec      QP_Modifiers_PUB.Modifier_List_Val_Rec_Type;
   l_modifiers_tbl              QP_Modifiers_PUB.Modifiers_Tbl_Type;
   l_modifiers_val_tbl          QP_Modifiers_PUB.Modifiers_Val_Tbl_Type;
   l_qualifiers_tbl             QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type;
   l_qualifiers_val_tbl         QP_Qualifier_Rules_PUB.Qualifiers_Val_Tbl_Type;
   l_pricing_attr_tbl           QP_Modifiers_PUB.Pricing_Attr_Tbl_Type;
   l_pricing_attr_val_tbl       QP_Modifiers_PUB.Pricing_Attr_Val_Tbl_Type;
   l_x_modifier_list_rec        QP_Modifiers_PUB.Modifier_List_Rec_Type;
   l_x_modifier_list_val_rec    QP_Modifiers_PUB.Modifier_List_Val_Rec_Type;
   l_x_modifiers_tbl            QP_Modifiers_PUB.Modifiers_Tbl_Type;
   l_x_modifiers_val_tbl        QP_Modifiers_PUB.Modifiers_Val_Tbl_Type;
   l_x_qualifiers_tbl           QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type;
   l_x_qualifiers_val_tbl       QP_Qualifier_Rules_PUB.Qualifiers_Val_Tbl_Type;
   l_x_qualifier_rules_rec      QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type;
   l_x_qualifier_rules_val_rec  QP_Qualifier_Rules_PUB.Qualifier_Rules_Val_Rec_Type;
   l_x_pricing_attr_tbl         QP_Modifiers_PUB.Pricing_Attr_Tbl_Type;
   l_x_pricing_attr_val_tbl     QP_Modifiers_PUB.Pricing_Attr_Val_Tbl_Type;
   l_control_rec                QP_GLOBALS.Control_Rec_Type;

   l_line_id_tbl                OE_GLOBALS.Number_Tbl_Type;
   l_hdr_req_index              NUMBER;
   l_line_req_index_tbl         OE_GLOBALS.Number_Tbl_Type;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
l_user_precedence NUMBER; --Bug#8468331

BEGIN

   if l_debug_level > 0 then
     oe_debug_pub.add('Enter Create_Modifiers',1);
   end if;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   l_request_rec := oe_delayed_requests_pvt.g_delayed_requests(p_index);

   IF l_request_rec.request_type = 'CREATE_MODIFIER_LIST' THEN

      l_blanket_header_id := l_request_rec.entity_id;

      -----------------------------------------------------------
      -- Set up the list header record
      -----------------------------------------------------------
      l_modifier_list_rec.list_type_code := 'DLT';  -- simple discount modifier
      l_modifier_list_rec.name := l_request_rec.param1;
      -- description is also a required field so send name for description also
      l_modifier_list_rec.description := l_request_rec.param1;
      l_modifier_list_rec.currency_code := l_request_rec.param2;
      l_modifier_list_rec.orig_system_header_ref := l_blanket_header_id;
      l_modifier_list_rec.list_source_code := 'BSO';
      l_modifier_list_rec.shareable_flag := 'N';
      --Add MOAC changes
      l_modifier_list_rec.org_id := mo_global.get_current_org_id;
      l_modifier_list_rec.global_flag := 'N';
      -- Bug 3210361 -
      -- Blanket modifiers were not being applied
      l_modifier_list_rec.start_date_active := trunc(sysdate);
      l_modifier_list_rec.automatic_flag := 'Y';
      l_modifier_list_rec.operation := QP_GLOBALS.G_OPR_CREATE;
      l_hdr_req_index := p_index;

      -- Add blanket header qualifier
        l_qualifiers_tbl(1).excluder_flag := 'N';
        l_qualifiers_tbl(1).comparison_operator_code := '=';
        l_qualifiers_tbl(1).qualifier_context := 'ORDER';
        --Bug#8468331
	/*The precedence with which pricing was being called was hardcoded as 700(the seeded value)
	so even if this value is changed in Pricing Setup the price list being created via BSO has
	the precedence as 700 and not the user updated value.*/
	SELECT a.user_precedence INTO l_user_precedence
	FROM   qp_segments_v a,
	       qp_prc_contexts_b b,
	       qp_pte_segments c
	WHERE
		b.prc_context_type = 'QUALIFIER' and
		b.prc_context_code = 'ORDER' and
		b.prc_context_id = a.prc_context_id and
		a.segment_mapping_column = 'QUALIFIER_ATTRIBUTE5' and
		a.segment_id = c.segment_id and
	        c.pte_code = 'ORDFUL';
	--Bug#8468331
	--l_qualifiers_tbl(1).qualifier_precedence := 700; --commented Bug#8468331
	l_qualifiers_tbl(1).qualifier_precedence := l_user_precedence; --Bug#8468331

        l_qualifiers_tbl(1).qualifier_attribute := 'QUALIFIER_ATTRIBUTE5';
        -- Blanket Header ID is the qualifier attribute value
        l_qualifiers_tbl(1).qualifier_attr_value := l_blanket_header_id;
        l_qualifiers_tbl(1).qualifier_grouping_no := 1;
        l_qualifiers_tbl(1).operation := QP_GLOBALS.G_OPR_CREATE;
        -- Bug 3314789
        l_qualifiers_tbl(1).active_flag := 'Y';      /* jhkuo */
        l_qualifiers_tbl(1).list_type_code := 'DLT'; /* jhkuo */

      if l_debug_level > 0 then
         oe_debug_pub.add('Modifier Name :'||l_modifier_list_rec.name);
         oe_debug_pub.add('Modifier Currency :'||l_modifier_list_rec.currency_code);
      end if;

   ELSIF l_request_rec.request_type = 'ADD_MODIFIER_LIST_LINE' THEN

      l_blanket_header_id := l_request_rec.param6;

      SELECT /* MOAC_SQL_CHANGE */ he.new_modifier_list_id
        INTO l_modifier_list_id
        FROM oe_blanket_headers_ext he, oe_blanket_headers_all h
       WHERE h.header_id = l_blanket_header_id
         AND he.order_number = h.order_number
         AND h.org_id = mo_global.get_current_org_id;

      -- If there is no new modifier list at header level, this should
      -- have been caught in entity validation hence raise unexp error.
      IF l_modifier_list_id IS NULL THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

   END IF;


   -------------------------------------------------------------------
   -- Loop over the requests table, identify blanket lines where discounts
   -- were entered inline and add to modifier lines table.
   -------------------------------------------------------------------

   I := oe_delayed_requests_pvt.g_delayed_requests.first;
   J := 1;

   WHILE I IS NOT NULL LOOP

      l_request_rec := oe_delayed_requests_pvt.g_delayed_requests(I);
      oe_debug_pub.add('Req Type :'||l_request_rec.request_type);

      IF l_request_rec.request_type = 'ADD_MODIFIER_LIST_LINE' THEN

        -----------------------------------------------------------
        -- Set up the list line record
        -----------------------------------------------------------
        --for bug 3229225
        IF  (l_request_rec.param1 IS NULL OR l_request_rec.param1=FND_API.G_MISS_NUM)
        AND (l_request_rec.param2 IS NULL OR l_request_rec.param2=FND_API.G_MISS_NUM)
        THEN
           IF l_debug_level > 0
           THEN
              oe_debug_pub.add('Skip for null values');
           END IF;
           oe_delayed_requests_pvt.g_delayed_requests.delete(I);
           GOTO SKIP_LINE;
        END IF;
        --end bug 3229225
        -- simple discount line
        l_modifiers_tbl(J).list_line_type_code := 'DIS';
        -- will be not null if it is being added to an existing modifier
        l_modifiers_tbl(J).list_header_id := l_modifier_list_id;
        l_modifiers_tbl(J).automatic_flag:= 'Y';
        l_modifiers_tbl(J).modifier_level_code := 'LINE';
        -- Bug 3210361 -
        -- Blanket modifiers were not being applied
        l_modifiers_tbl(J).start_date_active := trunc(sysdate);
        -- 'List Line Adjustment' phase
        l_modifiers_tbl(J).pricing_phase_id := 2;
        l_modifiers_tbl(J).product_precedence := 1;
        -- if discount percent is specified on the blanket line
        IF l_request_rec.param1 IS NOT NULL THEN
           l_modifiers_tbl(J).arithmetic_operator := '%';
           l_modifiers_tbl(J).operand := l_request_rec.param1;
        -- if discount amount is specified on the blanket line
        ELSIF l_request_rec.param2 IS NOT NULL THEN
           l_modifiers_tbl(J).arithmetic_operator := 'AMT';
           l_modifiers_tbl(J).operand := l_request_rec.param2;
        END IF;
        l_modifiers_tbl(J).operation := QP_GLOBALS.G_OPR_CREATE;

        -----------------------------------------------------------
        -- Set up the item context on pricing attributes record
        -----------------------------------------------------------
        l_pricing_attr_tbl(J).product_attribute_context:= 'ITEM';
        -- if item category context
        if l_request_rec.param4 = 'CAT' then
           l_pricing_attr_tbl(J).PRODUCT_ATTRIBUTE := 'PRICING_ATTRIBUTE2';
           l_pricing_attr_tbl(J).PRODUCT_ATTR_VALUE := l_request_rec.param3;
        -- if all items context
        elsif l_request_rec.param4 = 'ALL' then
           l_pricing_attr_tbl(J).PRODUCT_ATTRIBUTE := 'PRICING_ATTRIBUTE3';
           l_pricing_attr_tbl(J).PRODUCT_ATTR_VALUE := 'ALL';
        -- if a specific item context
        else
           l_pricing_attr_tbl(J).product_attribute:= 'PRICING_ATTRIBUTE1';
           l_pricing_attr_tbl(J).PRODUCT_ATTR_VALUE := l_request_rec.param3;
        end if;
        l_pricing_attr_tbl(J).modifiers_index := J;
        l_pricing_attr_tbl(J).operation := QP_GLOBALS.G_OPR_CREATE;

        -- Keep track of which modifier line index corresponds to which
        -- blanket line ID.
        l_line_id_tbl(J) := l_request_rec.entity_id;
        l_line_req_index_tbl(J) := I;

        if l_debug_level > 0 then
           oe_debug_pub.add('Operator :'||l_modifiers_tbl(J).arithmetic_operator);
           oe_debug_pub.add('Operand :'||l_modifiers_tbl(J).operand);
           oe_debug_pub.add('Prod Attr :'||l_pricing_attr_tbl(J).product_attribute);
           oe_debug_pub.add('Prod Attr Val :'||l_pricing_attr_tbl(J).product_attr_value);
        end if;
        J := J + 1;

      END IF;
      --for bug 3229225
      <<SKIP_LINE>>
      I := oe_delayed_requests_pvt.g_delayed_requests.next(I);

   END LOOP;


   -------------------------------------------------------------------
   -- Call Pricing Group API to create modifier header and modifier lines
   -------------------------------------------------------------------
   l_control_rec.called_from_ui := 'N';

   QP_Modifiers_GRP.Process_Modifiers
      ( p_api_version_number     => 1.0
      , p_init_msg_list          => FND_API.G_FALSE
      , p_return_values          => FND_API.G_FALSE
      , p_commit                 => FND_API.G_FALSE
      , x_return_status          => l_return_status
      , x_msg_count              => l_msg_count
      , x_msg_data               => l_msg_data
      , p_control_rec            => l_control_rec
      , p_modifier_list_rec      => l_modifier_list_rec
      , p_modifiers_tbl          => l_modifiers_tbl
      , p_qualifiers_tbl         => l_qualifiers_tbl
      , p_pricing_attr_tbl       => l_pricing_attr_tbl
      , x_modifier_list_rec      => l_x_modifier_list_rec
      , x_modifier_list_val_rec  => l_x_modifier_list_val_rec
      , x_modifiers_tbl          => l_x_modifiers_tbl
      , x_modifiers_val_tbl      => l_x_modifiers_val_tbl
      , x_qualifiers_tbl         => l_x_qualifiers_tbl
      , x_qualifiers_val_tbl     => l_x_qualifiers_val_tbl
      , x_pricing_attr_tbl       => l_x_pricing_attr_tbl
      , x_pricing_attr_val_tbl   => l_x_pricing_attr_val_tbl
      );

   if l_return_status = fnd_api.g_ret_sts_error then
      raise fnd_api.g_exc_error;
   elsif l_return_status = fnd_api.g_ret_sts_unexp_error then
      raise fnd_api.g_exc_unexpected_error;
   end if;

   -- As line level qualifiers cannot be created without list line IDs,
   -- modifier list lines must be created in previous call to qp_modifiers_grp.
   -- And a separate call is made to qp_qualifiers_pub to create the
   -- line qualifiers with created list line IDs.

   if l_x_modifiers_tbl.FIRST is not null then

      l_qualifiers_tbl.DELETE;
      J := l_x_modifiers_tbl.FIRST;

      WHILE J IS NOT NULL LOOP

          -----------------------------------------------------------
          -- Set up the blanket line qualifier record
          -----------------------------------------------------------
          l_qualifiers_tbl(J).excluder_flag := 'N';
          l_qualifiers_tbl(J).comparison_operator_code := '=';
          l_qualifiers_tbl(J).qualifier_context := 'ORDER';
          l_qualifiers_tbl(J).qualifier_precedence := 800;
          l_qualifiers_tbl(J).qualifier_attribute := 'QUALIFIER_ATTRIBUTE6';
          -- Blanket Line ID is the qualifier attribute value
          oe_debug_pub.add('entity id :'||l_line_id_tbl(J));
          l_qualifiers_tbl(J).qualifier_attr_value := l_line_id_tbl(J);
          l_qualifiers_tbl(J).qualifier_grouping_no := 1;
          l_qualifiers_tbl(J).operation := QP_GLOBALS.G_OPR_CREATE;
          -- Copy list line ID from created modiifer lines table
          l_qualifiers_tbl(J).list_header_id :=
                        l_x_modifiers_tbl(J).list_header_id;
          l_qualifiers_tbl(J).list_line_id :=
                      l_x_modifiers_tbl(J).list_line_id;
          oe_debug_pub.add('sending list header id on qual :'||
                             l_qualifiers_tbl(J).list_header_id);
          oe_debug_pub.add('sending list line id on qual :'||
                             l_qualifiers_tbl(J).list_line_id);

          J := l_x_modifiers_tbl.NEXT(J);

      END LOOP;

      QP_Qualifier_Rules_PUB.Process_Qualifier_Rules
         ( p_api_version_number     => 1.0
         , p_init_msg_list          => FND_API.G_FALSE
         , p_return_values          => FND_API.G_FALSE
         , p_commit                 => FND_API.G_FALSE
         , x_return_status          => l_return_status
         , x_msg_count              => l_msg_count
         , x_msg_data               => l_msg_data
         , p_qualifiers_tbl         => l_qualifiers_tbl
         , x_qualifiers_tbl         => l_x_qualifiers_tbl
         , x_qualifiers_val_tbl     => l_x_qualifiers_val_tbl
         , x_qualifier_rules_rec    => l_x_qualifier_rules_rec
         , x_qualifier_rules_val_rec => l_x_qualifier_rules_val_rec
         );

   end if;

   if l_return_status = fnd_api.g_ret_sts_error then
      raise fnd_api.g_exc_error;
   elsif l_return_status = fnd_api.g_ret_sts_unexp_error then
      raise fnd_api.g_exc_unexpected_error;
   end if;

   -------------------------------------------------------------------
   -- Update modifier IDs on blanket tables
   -------------------------------------------------------------------

   -- Update modifier list header id on blanket header table
   IF l_modifier_list_rec.operation = QP_GLOBALS.G_OPR_CREATE THEN

      if l_debug_level > 0 then
         oe_debug_pub.add('blanket header id :'||l_blanket_header_id);
         oe_debug_pub.add('set modifier list id :'||
                       l_x_modifier_list_rec.list_header_id);
      end if;

      update oe_blanket_headers
         set lock_control = lock_control + 1
             ,last_updated_by = FND_GLOBAL.USER_ID
             ,last_update_date = sysdate
       where header_id = l_blanket_header_id;

      update oe_blanket_headers_ext
         set new_modifier_list_id = l_x_modifier_list_rec.list_header_id
       where order_number = (select  /* MOAC_SQL_CHANGE */ order_number
                               from oe_blanket_headers_all
                              where header_id = l_blanket_header_id
                              and org_id = mo_global.get_current_org_id);

      oe_delayed_requests_pvt.g_delayed_requests.delete(l_hdr_req_index);
      oe_blanket_util.g_header_rec.new_modifier_list_id := l_x_modifier_list_rec.list_header_id;

   END IF;

   -- Update modifier list line id on blanket line table
   I := l_line_id_tbl.FIRST;
   WHILE I IS NOT NULL LOOP

      if l_debug_level > 0 then
         oe_debug_pub.add('blanket line id :'||l_line_id_tbl(I));
         oe_debug_pub.add('modifier list line id :'||l_x_modifiers_tbl(I).list_line_id);
      end if;

      update oe_blanket_lines
         set lock_control = lock_control + 1
             ,last_updated_by = FND_GLOBAL.USER_ID
             ,last_update_date = sysdate
       where line_id = l_line_id_tbl(I);

      update oe_blanket_lines_ext
         set modifier_list_line_id = l_x_modifiers_tbl(I).list_line_id
       where line_id = l_line_id_tbl(I);

      oe_delayed_requests_pvt.g_delayed_requests.delete
                                      (l_line_req_index_tbl(I));

      I := l_line_id_tbl.NEXT(I);

   END LOOP;

   OE_GLOBALS.G_CASCADING_REQUEST_LOGGED := TRUE;
   oe_blanket_util.g_new_modifier_list := FALSE;

   if l_debug_level > 0 then
     oe_debug_pub.add('Exit Create_Modifiers',1);
   end if;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
   x_return_status := fnd_api.g_ret_sts_error;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   x_return_status := fnd_api.g_ret_sts_unexp_error;
   WHEN OTHERS THEN
   x_return_status := fnd_api.g_ret_sts_unexp_error;
   IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
   THEN
      OE_MSG_PUB.Add_Exc_Msg
         (G_PKG_NAME
          ,'Create_Modifiers'
          );
   END IF;
END Create_Modifiers;

PROCEDURE Deactivate_Price_List
          (p_list_header_id          IN NUMBER DEFAULT NULL
          ,p_list_line_id            IN NUMBER DEFAULT NULL
          ,x_return_status           IN OUT NOCOPY VARCHAR2
          )
IS
 gpr_msg_count number := 0;
 gpr_msg_data varchar2(2000);
 gpr_price_list_rec QP_PRICE_LIST_PUB.Price_List_Rec_Type;
 gpr_price_list_line_tbl QP_PRICE_LIST_PUB.Price_List_Line_Tbl_Type;
 ppr_price_list_rec QP_PRICE_LIST_PUB.Price_List_Rec_Type;
 ppr_price_list_val_rec QP_PRICE_LIST_PUB.Price_List_Val_Rec_Type;
 ppr_price_list_line_tbl QP_PRICE_LIST_PUB.Price_List_Line_Tbl_Type;
 ppr_price_list_line_val_tbl QP_PRICE_LIST_PUB.Price_List_Line_Val_Tbl_Type;
 ppr_qualifiers_tbl QP_Qualifier_Rules_Pub.Qualifiers_Tbl_Type;
 ppr_qualifiers_val_tbl QP_Qualifier_Rules_Pub.Qualifiers_Val_Tbl_Type;
 ppr_pricing_attr_tbl QP_PRICE_LIST_PUB.Pricing_Attr_Tbl_Type;
 ppr_pricing_attr_val_tbl QP_PRICE_LIST_PUB.Pricing_Attr_Val_Tbl_Type;
 --
 l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
 --
BEGIN

   if l_debug_level > 0 then
   oe_debug_pub.add('Enter Deactivate_Price_List');
   oe_debug_pub.add('p_list_header_id :'||p_list_header_id);
   oe_debug_pub.add('p_list_line_id :'||p_list_line_id);
   end if;

   IF p_list_header_id IS NOT NULL THEN
      gpr_price_list_rec.list_header_id := p_list_header_id;
      gpr_price_list_rec.operation := QP_GLOBALS.G_OPR_UPDATE;
      gpr_price_list_rec.end_date_active := trunc(sysdate);
   END IF;

   IF p_list_line_id IS NOT NULL THEN
      gpr_price_list_line_tbl(1).list_line_id := p_list_line_id;
      gpr_price_list_line_tbl(1).operation := QP_GLOBALS.G_OPR_UPDATE;
      gpr_price_list_line_tbl(1).end_date_active := trunc(sysdate);
   END IF;

   QP_PRICE_LIST_GRP.Process_Price_List
     (   p_api_version_number            => 1
     ,   p_init_msg_list                 => FND_API.G_FALSE
     ,   p_return_values                 => FND_API.G_FALSE
     ,   p_commit                        => FND_API.G_FALSE
     ,   x_return_status                 => x_return_status
     ,   x_msg_count                     => gpr_msg_count
     ,   x_msg_data                      => gpr_msg_data
     ,   p_PRICE_LIST_rec                => gpr_price_list_rec
     ,   p_PRICE_LIST_LINE_tbl           => gpr_price_list_line_tbl
     ,   x_PRICE_LIST_rec                => ppr_price_list_rec
     ,   x_PRICE_LIST_val_rec            => ppr_price_list_val_rec
     ,   x_PRICE_LIST_LINE_tbl           => ppr_price_list_line_tbl
     ,   x_PRICE_LIST_LINE_val_tbl       => ppr_price_list_line_val_tbl
     ,   x_QUALIFIERS_tbl                => ppr_qualifiers_tbl
     ,   x_QUALIFIERS_val_tbl            => ppr_qualifiers_val_tbl
     ,   x_PRICING_ATTR_tbl              => ppr_pricing_attr_tbl
     ,   x_PRICING_ATTR_val_tbl          => ppr_pricing_attr_val_tbl
     );

   if l_debug_level > 0 then
   oe_debug_pub.add('Exit Deactivate_Price_List');
   end if;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
   x_return_status := fnd_api.g_ret_sts_error;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   x_return_status := fnd_api.g_ret_sts_unexp_error;
   WHEN OTHERS THEN
   x_return_status := fnd_api.g_ret_sts_unexp_error;
   IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
   THEN
      OE_MSG_PUB.Add_Exc_Msg
         (G_PKG_NAME
          ,'Deactivate_Price_List'
          );
   END IF;
END Deactivate_Price_List;

PROCEDURE Deactivate_Modifier
          (p_list_header_id          IN NUMBER DEFAULT NULL
          ,p_list_line_id            IN NUMBER DEFAULT NULL
          ,x_return_status           IN OUT NOCOPY VARCHAR2
          )
IS
 l_return_status                varchar2(30);
 l_msg_count number := 0;
 l_msg_data varchar2(2000);
 --
 l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
 --
   l_modifier_list_rec          QP_Modifiers_PUB.Modifier_List_Rec_Type;
   l_modifiers_tbl              QP_Modifiers_PUB.Modifiers_Tbl_Type;
   l_x_modifier_list_rec        QP_Modifiers_PUB.Modifier_List_Rec_Type;
   l_x_modifier_list_val_rec    QP_Modifiers_PUB.Modifier_List_Val_Rec_Type;
   l_x_modifiers_tbl            QP_Modifiers_PUB.Modifiers_Tbl_Type;
   l_x_modifiers_val_tbl        QP_Modifiers_PUB.Modifiers_Val_Tbl_Type;
   l_x_qualifiers_tbl           QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type;
   l_x_qualifiers_val_tbl       QP_Qualifier_Rules_PUB.Qualifiers_Val_Tbl_Type;
   l_x_pricing_attr_tbl         QP_Modifiers_PUB.Pricing_Attr_Tbl_Type;
   l_x_pricing_attr_val_tbl     QP_Modifiers_PUB.Pricing_Attr_Val_Tbl_Type;
   l_control_rec                QP_GLOBALS.Control_Rec_Type;
BEGIN

   if l_debug_level > 0 then
   oe_debug_pub.add('Enter Deactivate_Modifier');
   oe_debug_pub.add('p_list_header_id :'||p_list_header_id);
   oe_debug_pub.add('p_list_line_id :'||p_list_line_id);
   end if;

   IF p_list_header_id IS NOT NULL THEN
      l_modifier_list_rec.list_header_id := p_list_header_id;
      l_modifier_list_rec.operation := QP_GLOBALS.G_OPR_UPDATE;
      l_modifier_list_rec.end_date_active := trunc(sysdate);
   END IF;

   IF p_list_line_id IS NOT NULL THEN
      l_modifiers_tbl(1).list_line_id := p_list_line_id;
      l_modifiers_tbl(1).operation := QP_GLOBALS.G_OPR_UPDATE;
      l_modifiers_tbl(1).end_date_active := trunc(sysdate);
   END IF;

   -------------------------------------------------------------------
   -- Call Pricing Group API to update modifier header and modifier lines
   -------------------------------------------------------------------
   l_control_rec.called_from_ui := 'N';

   QP_Modifiers_GRP.Process_Modifiers
      ( p_api_version_number     => 1.0
      , p_init_msg_list          => FND_API.G_FALSE
      , p_return_values          => FND_API.G_FALSE
      , p_commit                 => FND_API.G_FALSE
      , x_return_status          => l_return_status
      , x_msg_count              => l_msg_count
      , x_msg_data               => l_msg_data
      , p_control_rec            => l_control_rec
      , p_modifier_list_rec      => l_modifier_list_rec
      , p_modifiers_tbl          => l_modifiers_tbl
      , x_modifier_list_rec      => l_x_modifier_list_rec
      , x_modifier_list_val_rec  => l_x_modifier_list_val_rec
      , x_modifiers_tbl          => l_x_modifiers_tbl
      , x_modifiers_val_tbl      => l_x_modifiers_val_tbl
      , x_qualifiers_tbl         => l_x_qualifiers_tbl
      , x_qualifiers_val_tbl     => l_x_qualifiers_val_tbl
      , x_pricing_attr_tbl       => l_x_pricing_attr_tbl
      , x_pricing_attr_val_tbl   => l_x_pricing_attr_val_tbl
      );

   if l_return_status = fnd_api.g_ret_sts_error then
      raise fnd_api.g_exc_error;
   elsif l_return_status = fnd_api.g_ret_sts_unexp_error then
      raise fnd_api.g_exc_unexpected_error;
   end if;

   if l_debug_level > 0 then
   oe_debug_pub.add('Exit Deactivate_Modifier');
   end if;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
   x_return_status := fnd_api.g_ret_sts_error;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   x_return_status := fnd_api.g_ret_sts_unexp_error;
   WHEN OTHERS THEN
   x_return_status := fnd_api.g_ret_sts_unexp_error;
   IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
   THEN
      OE_MSG_PUB.Add_Exc_Msg
         (G_PKG_NAME
          ,'Deactivate_Modifier'
          );
   END IF;
END Deactivate_Modifier;

PROCEDURE Deactivate_Pricing
          (p_blanket_header_id    IN NUMBER DEFAULT NULL
          ,p_blanket_line_id      IN NUMBER DEFAULT NULL
          ,x_return_status        IN OUT NOCOPY VARCHAR2
          )
IS
 l_qp_list_line_id             NUMBER;
 l_mod_list_line_id            NUMBER;
 l_price_list_tbl              QP_Price_List_PUB.Price_List_Tbl_Type;
 l_modifier_list_tbl           QP_Modifiers_PUB.Modifier_List_Tbl_Type;
 l_return_status               VARCHAR2(30);
 l_msg_count                   NUMBER;
 l_msg_data                    VARCHAR2(2000);
 l_exist_qp_list_line_id       VARCHAR2(1) := 'Y';
 --
 l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
 --
BEGIN

  if l_debug_level > 0 then
     oe_debug_pub.add('Enter Deactivate_Pricing');
     oe_debug_pub.add('p_blanket_header_id :'||p_blanket_header_id);
     oe_debug_pub.add('p_blanket_line_id :'||p_blanket_line_id);
  end if;

  x_return_status := fnd_api.g_ret_sts_success;

  IF p_blanket_line_id IS NOT NULL THEN

     SELECT qp_list_line_id, modifier_list_line_id
       INTO l_qp_list_line_id, l_mod_list_line_id
       FROM OE_BLANKET_LINES_EXT
      WHERE line_id = p_blanket_line_id;
     -- Check if the QP line exist in the QP tables.
     -- For the bug #3985489
     begin
        select 'Y'
          into l_exist_qp_list_line_id
          from qp_list_lines
         where list_line_id = l_qp_list_line_id;
     exception
         when others then
           l_exist_qp_list_line_id := 'N';
     end;

     IF l_qp_list_line_id IS NOT NULL  and
        l_exist_qp_list_line_id = 'Y' THEN
        Deactivate_Price_List
          (p_list_line_id  => l_qp_list_line_id
          ,x_return_status => l_return_status
          );
        if l_return_status = fnd_api.g_ret_sts_error then
           raise fnd_api.g_exc_error;
        elsif l_return_status = fnd_api.g_ret_sts_unexp_error then
           raise fnd_api.g_exc_unexpected_error;
        end if;
     END IF;

     IF l_mod_list_line_id IS NOT NULL THEN
        Deactivate_Modifier
          (p_list_line_id  => l_mod_list_line_id
          ,x_return_status => l_return_status
          );
        if l_return_status = fnd_api.g_ret_sts_error then
           raise fnd_api.g_exc_error;
        elsif l_return_status = fnd_api.g_ret_sts_unexp_error then
           raise fnd_api.g_exc_unexpected_error;
        end if;
     END IF;

  ELSIF p_blanket_header_id IS NOT NULL THEN

     QP_UTIL_PUB.Get_Blanket_Pricelist_Modifier
        (p_blanket_header_id         => p_blanket_header_id
        ,x_price_list_tbl            => l_price_list_tbl
        ,x_modifier_list_tbl         => l_modifier_list_tbl
        ,x_return_status             => l_return_status
        ,x_msg_count                 => l_msg_count
        ,x_msg_data                  => l_msg_data
        );

     FOR I IN 1..l_price_list_tbl.COUNT LOOP
        Deactivate_Price_List
          (p_list_header_id  => l_price_list_tbl(I).list_header_id
          ,x_return_status   => l_return_status
          );
     END LOOP;

     FOR I IN 1..l_modifier_list_tbl.COUNT LOOP
        Deactivate_Modifier
          (p_list_header_id  => l_modifier_list_tbl(I).list_header_id
          ,x_return_status   => l_return_status
          );
     END LOOP;

  END IF;

  if l_debug_level > 0 then
     oe_debug_pub.add('Exit Deactivate_Pricing');
  end if;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
   x_return_status := fnd_api.g_ret_sts_error;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   x_return_status := fnd_api.g_ret_sts_unexp_error;
   WHEN OTHERS THEN
   x_return_status := fnd_api.g_ret_sts_unexp_error;
   IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
   THEN
      OE_MSG_PUB.Add_Exc_Msg
         (G_PKG_NAME
          ,'Deactivate_Pricing'
          );
   END IF;
END Deactivate_Pricing;


FUNCTION Get_Blanket_Header_ID
 (   p_blanket_number           IN NUMBER
)RETURN NUMBER IS
 l_blanket_header_id             NUMBER;
 --
 l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
 --
BEGIN

  if l_debug_level > 0 then
     oe_debug_pub.add('Enter Get_Blanket_Header_ID');
     oe_debug_pub.add('Blanket num :'||p_blanket_number);
  end if;

  IF p_blanket_number IS NOT NULL
     AND p_blanket_number <> FND_API.G_MISS_NUM
  THEN
     select /* MOAC_SQL_CHANGE */ header_id
       into l_blanket_header_id
       from oe_blanket_headers_all
      where order_number = p_blanket_number
      and org_id = mo_global.get_current_org_id;
  END IF;

  if l_debug_level > 0 then
     oe_debug_pub.add('Return Get_Blanket_Header_ID :'||l_blanket_header_id);
  end if;

  RETURN l_blanket_header_id;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        if l_debug_level > 0 then
          oe_debug_pub.add('No data found in Get_Blanket_Header_ID');
        end if;
        RETURN NULL;
    WHEN OTHERS THEN
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('other error :'||SQLERRM ) ;
        END IF;
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Get_Blanket_Header_ID'
            );
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Get_Blanket_Header_ID;

FUNCTION Get_Blanket_Line_ID
 (   p_blanket_number           IN NUMBER
  ,  p_blanket_line_number      IN NUMBER
)RETURN NUMBER IS
 l_blanket_line_id             NUMBER;
 --
 l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
 --
BEGIN

  if l_debug_level > 0 then
     oe_debug_pub.add('Enter Get_Blanket_Line_ID');
     oe_debug_pub.add('Blanket num :'||p_blanket_number);
     oe_debug_pub.add('Blanket line num :'||p_blanket_line_number);
  end if;

  IF p_blanket_number IS NOT NULL
     AND p_blanket_line_number IS NOT NULL
  THEN
     select line_id
       into l_blanket_line_id
       from oe_blanket_lines_ext
      where order_number = p_blanket_number
        and line_number = p_blanket_line_number;
  END IF;

  if l_debug_level > 0 then
     oe_debug_pub.add('Return Get_Blanket_Line_ID :'||l_blanket_line_id);
  end if;

  RETURN l_blanket_line_id;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        if l_debug_level > 0 then
          oe_debug_pub.add('No data found in Get_Blanket_Line_ID');
        end if;
        RETURN NULL;
    WHEN OTHERS THEN
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('other error :'||SQLERRM ) ;
        END IF;
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Get_Blanket_Line_ID'
            );
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Get_Blanket_Line_ID;

FUNCTION Get_List_Line_ID
 (   p_blanket_number           IN NUMBER
  ,  p_blanket_line_number      IN NUMBER
)RETURN NUMBER IS
 l_list_line_id             NUMBER;
 --
 l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
 --
BEGIN

  if l_debug_level > 0 then
     oe_debug_pub.add('Enter Get_List_Line_ID');
     oe_debug_pub.add('Blanket num :'||p_blanket_number);
     oe_debug_pub.add('Blanket line num :'||p_blanket_line_number);
  end if;

  IF p_blanket_number IS NOT NULL
     AND p_blanket_line_number IS NOT NULL
  THEN
     select qp_list_line_id
       into l_list_line_id
       from oe_blanket_lines_ext
      where order_number = p_blanket_number
        and line_number = p_blanket_line_number;
  END IF;

  if l_debug_level > 0 then
     oe_debug_pub.add('RETURN_Line_ID :'||l_list_line_id);
  end if;

  RETURN l_list_line_id;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        if l_debug_level > 0 then
          oe_debug_pub.add('No data found in Get_List_Line_ID');
        end if;
        RETURN NULL;
    WHEN OTHERS THEN
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Get_List_Line_ID'
            );
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Get_List_Line_ID;

FUNCTION Get_Blanket_Rel_Amt
 (   p_blanket_number           IN NUMBER
  ,  p_blanket_line_number      IN NUMBER
  ,  p_line_id                  IN NUMBER DEFAULT NULL
  ,  p_header_id                IN NUMBER DEFAULT NULL
  ,  p_transaction_phase_code   IN VARCHAR2 DEFAULT NULL
)RETURN NUMBER IS
 l_rel_amt                      NUMBER;
 l_released_amount              NUMBER;
 l_returned_amount              NUMBER;
 l_order_rel_amt                NUMBER := 0;
 l_blanket_header_id            NUMBER;
 --
 l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
 --
BEGIN

  if l_debug_level > 0 then
  oe_debug_pub.add('Enter Get_Blanket_Rel_Amt');
  oe_debug_pub.add('Blkt Num :'||p_blanket_number);
  oe_debug_pub.add('Blkt Line Num :'||p_blanket_line_number);
  oe_debug_pub.add('Line ID :'||p_line_id);
  oe_debug_pub.add('Header ID :'||p_header_id);
  end if;

  IF p_blanket_number IS NULL
     -- Bug 3350448 =>
     -- Cache blanket will raise a no data found if there is no blanket
     -- line number. In any case, blanket line number is mandatory
     -- blanket number is supplied on the release so execute this sourcing
     -- api also only when both blanket number and blanket line number exist.
     OR p_blanket_line_number IS NULL
  THEN
     RETURN NULL;
  ENd IF;

     select   /* MOAC_SQL_CHANGE */ nvl(bhe.released_amount,0)
            ,nvl(bhe.returned_amount,0)
            ,bh.header_id
       into  l_released_amount
            ,l_returned_amount
            ,l_blanket_header_id
       from oe_blanket_headers_ext bhe, oe_blanket_headers_all bh
      where bhe.order_number = p_blanket_number
        and bhe.order_number = bh.order_number
        and bh.org_id = mo_global.get_current_orG_id;
  oe_debug_pub.add('current blkt rel amt :'||l_released_amount);
  oe_debug_pub.add('current blkt ret amt :'||l_returned_amount);

  l_blanket_header_id := MOD(l_blanket_header_id,G_BINARY_LIMIT);--bug8465849

  IF nvl(p_transaction_phase_code,'F') = 'F' THEN

     OE_Blkt_Release_Util.Populate_Old_Values
        (p_blanket_number                => p_blanket_number
        ,p_blanket_line_number           => p_blanket_line_number
        ,p_line_id                       => p_line_id
        ,p_header_id                     => p_header_id
        );

     IF OE_Blkt_Release_Util.g_blkt_hdr_tbl.EXISTS(l_blanket_header_id) THEN
        l_order_rel_amt :=
           OE_Blkt_Release_Util.g_bh_order_val_tbl(l_blanket_header_id).order_released_amount;
        oe_debug_pub.add('order rel amt :'||l_order_rel_amt);
     END IF;

  END IF;

  l_rel_amt := l_released_amount - l_returned_amount - l_order_rel_amt;

  if l_debug_level > 0 then
     oe_debug_pub.add('Blanket Rel Amt :'||l_rel_amt);
  end if;

  RETURN l_rel_amt;

EXCEPTION
    WHEN OTHERS THEN
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Get_Blanket_Rel_Amt'
            );
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Get_Blanket_Rel_Amt;


FUNCTION Get_Bl_Line_Rel_Amt
 (   p_blanket_number           IN NUMBER
  ,  p_blanket_line_number      IN NUMBER
  ,  p_line_id                  IN NUMBER DEFAULT NULL
  ,  p_header_id                IN NUMBER DEFAULT NULL
  ,  p_transaction_phase_code   IN VARCHAR2 DEFAULT NULL
)RETURN NUMBER IS
 l_rel_amt                      NUMBER;
 l_released_amount              NUMBER;
 l_returned_amount              NUMBER;
 l_order_rel_amt                NUMBER := 0;
 l_blanket_line_id              NUMBER;
 --
 l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
 --
BEGIN

  if l_debug_level > 0 then
  oe_debug_pub.add('Enter Get_Bl_Line_Rel_Amt');
  oe_debug_pub.add('Blkt Num :'||p_blanket_number);
  oe_debug_pub.add('Blkt Line Num :'||p_blanket_line_number);
  oe_debug_pub.add('Line ID :'||p_line_id);
  oe_debug_pub.add('Header ID :'||p_header_id);
  end if;

  IF p_blanket_number IS NULL
     OR p_blanket_line_number IS NULL
  THEN
     RETURN NULL;
  ENd IF;

     select  nvl(released_amount,0)
            ,nvl(returned_amount,0)
            ,line_id
       into  l_released_amount
            ,l_returned_amount
            ,l_blanket_line_id
       from oe_blanket_lines_ext
      where order_number = p_blanket_number
        and line_number = p_blanket_line_number;
  oe_debug_pub.add('current blkt rel amt :'||l_released_amount);
  oe_debug_pub.add('current blkt ret amt :'||l_returned_amount);

  l_blanket_line_id := MOD(l_blanket_line_id,G_BINARY_LIMIT);--bug8465849

  IF nvl(p_transaction_phase_code,'F') = 'F' THEN

     OE_Blkt_Release_Util.Populate_Old_Values
        (p_blanket_number                => p_blanket_number
        ,p_blanket_line_number           => p_blanket_line_number
        ,p_line_id                       => p_line_id
        ,p_header_id                     => p_header_id
        );

     IF OE_Blkt_Release_Util.g_blkt_line_tbl.EXISTS(l_blanket_line_id) THEN
        l_order_rel_amt :=
           OE_Blkt_Release_Util.g_bl_order_val_tbl(l_blanket_line_id).order_released_amount;
        oe_debug_pub.add('order rel amt :'||l_order_rel_amt);
     END IF;

  END IF;

  l_rel_amt := l_released_amount - l_returned_amount - l_order_rel_amt;

  if l_debug_level > 0 then
     oe_debug_pub.add('BL Line Rel Amt :'||l_rel_amt);
  end if;

  RETURN l_rel_amt;

EXCEPTION
    WHEN OTHERS THEN
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Get_Bl_Line_Rel_Amt'
            );
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Get_Bl_Line_Rel_Amt;

FUNCTION Get_Bl_Line_Rel_Qty
 (   p_blanket_number           IN NUMBER
  ,  p_blanket_line_number      IN NUMBER
  ,  p_line_id                  IN NUMBER DEFAULT NULL
  ,  p_header_id                IN NUMBER DEFAULT NULL
  ,  p_transaction_phase_code   IN VARCHAR2 DEFAULT NULL
)RETURN NUMBER IS
 l_rel_qty                      NUMBER;
 l_released_quantity            NUMBER;
 l_returned_quantity            NUMBER;
 l_order_rel_qty                NUMBER := 0;
 l_blanket_line_id              NUMBER;
 --
 l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
 --
BEGIN

  if l_debug_level > 0 then
  oe_debug_pub.add('Enter Get_Bl_Line_Rel_Qty');
  oe_debug_pub.add('Blkt Num :'||p_blanket_number);
  oe_debug_pub.add('Blkt Line Num :'||p_blanket_line_number);
  oe_debug_pub.add('Line ID :'||p_line_id);
  oe_debug_pub.add('Header ID :'||p_header_id);
  end if;

  IF p_blanket_number IS NULL
     OR p_blanket_line_number IS NULL
  THEN
     RETURN NULL;
  ENd IF;

     select  nvl(released_quantity,0)
            ,nvl(returned_quantity,0)
            ,line_id
       into  l_released_quantity
            ,l_returned_quantity
            ,l_blanket_line_id
       from oe_blanket_lines_ext
      where order_number = p_blanket_number
        and line_number = p_blanket_line_number;
  oe_debug_pub.add('current blkt rel qty :'||l_released_quantity);
  oe_debug_pub.add('current blkt ret qty :'||l_returned_quantity);

 l_blanket_line_id := MOD(l_blanket_line_id,G_BINARY_LIMIT);--bug8465849

  IF nvl(p_transaction_phase_code,'F') = 'F' THEN

     OE_Blkt_Release_Util.Populate_Old_Values
        (p_blanket_number                => p_blanket_number
        ,p_blanket_line_number           => p_blanket_line_number
        ,p_line_id                       => p_line_id
        ,p_header_id                     => p_header_id
        );

     IF OE_Blkt_Release_Util.g_blkt_line_tbl.EXISTS(l_blanket_line_id) THEN
        l_order_rel_qty :=
           OE_Blkt_Release_Util.g_bl_order_val_tbl(l_blanket_line_id).order_released_quantity;
        oe_debug_pub.add('order rel qty :'||l_order_rel_qty);
     END IF;

  END IF;

  l_rel_qty := l_released_quantity - l_returned_quantity - l_order_rel_qty;

  if l_debug_level > 0 then
     oe_debug_pub.add('BL Line Rel Qty :'||l_rel_qty);
  end if;

  RETURN l_rel_qty;

EXCEPTION
    WHEN OTHERS THEN
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('other error :'||SQLERRM ) ;
        END IF;
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Get_Bl_Line_Rel_Qty'
            );
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Get_Bl_Line_Rel_Qty;

END OE_Blanket_Pricing_Util;

/
