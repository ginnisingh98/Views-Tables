--------------------------------------------------------
--  DDL for Package Body OE_ADJ_PRIVILEGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_ADJ_PRIVILEGE" AS
/* $Header: OEXSADJB.pls 120.0 2005/06/01 01:09:57 appldev noship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_ADJ_PRIVILEGE';

FUNCTION Check_Item_Category
(   p_inv_item_id		IN NUMBER
,   p_ent_val			IN VARCHAR2
,   p_orgid			IN NUMBER
,   p_pricing_date		IN DATE
)
RETURN VARCHAR2
IS

l_dummy   VARCHAR2(1) := 'X';

CURSOR c_check_item_category IS
   SELECT 'Y'
   FROM   mtl_item_categories MTC,
          mtl_default_category_sets MTDCS,
          mtl_category_set_valid_cats MCSV,
          mtl_categories MC
   WHERE  MTDCS.functional_area_id = 7
     AND  MTC.category_set_id = MTDCS.category_set_id
     AND  MTC.inventory_item_id = TO_CHAR( p_inv_item_id )
     AND  MCSV.category_set_id = MTC.category_set_id
     AND  MCSV.category_id = MTC.category_id
     AND  MCSV.category_id = MC.category_id
     AND  p_pricing_date < nvl(MC.disable_date, p_pricing_date+1)
     AND  MTC.organization_id = NVL(p_orgid, MTC.organization_id)
     AND  MTC.category_id = to_number(p_ent_val);

--
--l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   OPEN c_check_item_category;
   FETCH c_check_item_category into l_dummy;
   CLOSE c_check_item_category;

   IF l_dummy = 'Y' then
      RETURN('Y');
    ELSE
      RETURN('N');
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      RETURN('N');
END;


PROCEDURE Check_Manual_Discount_Priv
(   p_api_version_number	IN    NUMBER
,   p_init_msg_list		IN    VARCHAR2 := FND_API.G_FALSE
, x_return_status OUT NOCOPY VARCHAR2

, x_msg_count OUT NOCOPY NUMBER

, x_msg_data OUT NOCOPY VARCHAR2

,   p_order_type_id		IN    NUMBER := FND_API.G_MISS_NUM
,   p_header_id                 IN    NUMBER
,   p_line_id                   IN    NUMBER
,   p_list_price                IN    NUMBER
,   p_discounting_privilege     IN    VARCHAR2
,   p_apply_order_adjs_flag	IN    VARCHAR2 := 'N'
,   p_check_multiple_adj_flag   IN    VARCHAR2 := 'Y'
, x_adjustment_total OUT NOCOPY NUMBER

, x_price_adjustment_id OUT NOCOPY NUMBER

)
IS
   l_api_version_number		CONSTANT NUMBER := 1.0;
   l_api_name			CONSTANT VARCHAR2(30) :=
						'Check_Manual_Discount_Priv';
   l_dummy			NUMBER;
   l_adjustment_total		NUMBER := 0;
   l_price_adjustment_id	NUMBER := NULL;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   --  Standard call to check for call compatibility
   IF NOT FND_API.Compatible_API_Call
     (l_api_version_number,
      p_api_version_number,
      l_api_name,
      G_PKG_NAME
      )
     THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;


   --  Initialize message list.
   IF FND_API.to_Boolean(p_init_msg_list) THEN
      OE_MSG_PUB.initialize;
   END IF;


   x_return_status := FND_API.G_RET_STS_SUCCESS;

   /********************************************************
   IF p_discounting_privilege = 'NONE' THEN

      fnd_message.set_name('QP', 'OE_MANDIS_DISALLOWED');
      fnd_message.set_token('REASON', 'OE_MANDIS_NO_PRIVILEGE', TRUE);
      OE_MSG_PUB.Add;

      RAISE FND_API.G_EXC_ERROR;

    ELSIF (p_list_price IS NULL
	   OR
	   p_list_price = 0)
      THEN

      fnd_message.set_name('QP', 'OE_MANDIS_DISALLOWED');
      fnd_message.set_token('REASON',
			    'OE_MANDIS_NO_LIST_PRICE',
			    TRUE);
      OE_MSG_PUB.Add;

      RAISE FND_API.G_EXC_ERROR;


      -- Check to make sure that the list price field is set
      -- otherwise you cannot apply manual discounts
      ELSIF p_list_price > 0
    ********************************************************/

      IF p_list_price > 0 THEN

      -- Check if the order type for this order enforces
      -- list prices: if it does not or if it does and you
      -- have 'UNLIMITED' discounting ability then you can
      -- apply manual discounts

      IF p_order_type_id <> FND_API.G_MISS_NUM THEN

         BEGIN
	    SELECT  NULL
	      INTO  L_Dummy
	      FROM  oe_transaction_types
	      WHERE transaction_type_id = p_order_type_id
	      AND   ((ENFORCE_LINE_PRICES_FLAG = 'Y'
		       AND
		       P_Discounting_Privilege = 'UNLIMITED')
		      OR
		      ENFORCE_LINE_PRICES_FLAG = 'N')
	      AND   ROWNUM = 1;

	    EXCEPTION WHEN NO_DATA_FOUND THEN
	      fnd_message.set_name('ONT', 'OE_MANDIS_DISALLOWED');
		 fnd_message.set_token('REASON',
				      'OE_MANDIS_PRICES_ENFORCED',
				      TRUE);
		 OE_MSG_PUB.Add;
		 RAISE FND_API.G_EXC_ERROR;
	    END;
       END IF;

       -- Select the price adjustment id of the single manual discount
       -- that might exist.
       IF (p_check_multiple_adj_flag = 'Y') THEN

          BEGIN
	     -- Count the number of price adjustments related to this
	     -- line which reference a manual discount
	     SELECT   price_adjustment_id
	       INTO   l_price_adjustment_id
	       FROM   OE_PRICE_ADJUSTMENTS
	       WHERE  HEADER_ID = P_HEADER_ID
	       AND    LINE_ID   = P_LINE_ID
	       AND    NVL( AUTOMATIC_FLAG, 'N' ) = 'N'
		  AND    (list_line_type_code = 'DIS'
				OR list_line_type_code = 'SUR')
		  AND	ROWNUM = 1;

		  x_price_adjustment_id := l_price_adjustment_id;
						IF l_debug_level  > 0 THEN
						    oe_debug_pub.add(  'OEXSADJB. ADJ_ID = '|| TO_CHAR ( L_PRICE_ADJUSTMENT_ID ) ) ;
						END IF;
		  x_return_status := FND_API.G_RET_STS_SUCCESS;

		  -- now calculate the total percentage on this
		  -- order line, excluding manual discounts
		SELECT  NVL( SUM( NVL( Adjusted_amount, 0) ), 0)
		  INTO  l_adjustment_total
		  FROM  oe_price_adjustments
		  WHERE header_id = p_header_id
		  AND   ((p_apply_order_adjs_flag = 'Y'
		         AND line_id IS NULL)
			    OR
			    (line_id = p_line_id
			    AND automatic_flag = 'Y'));

		  x_adjustment_total := l_adjustment_total;

	     EXCEPTION
	       WHEN NO_DATA_FOUND THEN
              x_return_status := FND_API.G_RET_STS_ERROR;
	     END;

        END IF;
      END IF;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

      x_return_status := FND_API.G_RET_STS_ERROR;

      --  Get message count and data
      OE_MSG_PUB.Count_And_Get
        (   p_count	=> x_msg_count
        ,   p_data	=> x_msg_data
        );


   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      --  Get message count and data
        OE_MSG_PUB.Count_And_Get
        (   p_count	=> x_msg_count
        ,   p_data	=> x_msg_data
        );


    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Check_Manual_Discount_Priv'
            );
        END IF;

        --  Get message count and data
        OE_MSG_PUB.Count_And_Get
        (   p_count	=> x_msg_count
        ,   p_data	=> x_msg_data
        );

END Check_Manual_Discount_Priv;


END OE_ADJ_PRIVILEGE;

/
