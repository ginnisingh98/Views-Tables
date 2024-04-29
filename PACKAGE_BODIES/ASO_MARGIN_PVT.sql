--------------------------------------------------------
--  DDL for Package Body ASO_MARGIN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_MARGIN_PVT" AS
/* $Header: asovgmrb.pls 120.0.12010000.2 2015/05/28 19:48:45 rassharm noship $ */
G_COMPUTE_METHOD     VARCHAR2(5):=NULL;
----------------------------------------------------------------
FUNCTION Get_Cost (p_line_rec       IN  ASO_QUOTE_PUB.Qte_Line_Rec_Type   DEFAULT ASO_QUOTE_PUB.G_MISS_QTE_LINE_REC
                   )
----------------------------------------------------------------
RETURN NUMBER IS
l_line_rec        ASO_QUOTE_PUB.Qte_Line_Rec_Type;
l_unit_cost       NUMBER;
l_unit_cost_gl    NUMBER;
l_order_currency  VARCHAR2(30);
l_org_currency    VARCHAR2(30);

l_uom_rate      NUMBER;
l_primary_uom_code VARCHAR2(30);

l_SHIP_FROM_ORG_ID number;

l_conversion_date date;

l_ato_line_id number;
l_top_model_line_id number;
L_SHIPMENT_ID       number;


cursor c_get_warehouse (p_qte_line_id number, p_qte_header_id number ) is
select ship_from_org_id
from aso_shipments
where quote_line_id = p_qte_line_id
and quote_header_id = p_qte_header_id;


cursor c_get_ids (p_qte_line_id number) is
select ato_line_id,top_model_line_id
from aso_quote_line_details
where quote_line_id = p_qte_line_id;

cursor c_shipment_id(p_quote_line_id number) is
select shipment_id from aso_shipments
where quote_line_id = p_quote_line_id;

cursor c_ship_org_id(p_shipment_id number) is
  select ship_from_org_id
  from aso_shipments
  where  shipment_id=p_shipment_id;



BEGIN
IF aso_debug_pub.g_debug_flag = 'Y' THEN
   aso_debug_pub.add('Entering ASO_Margin_Pvt.get_cost');
end if;


 IF G_COMPUTE_METHOD IS NULL THEN
  G_COMPUTE_METHOD:=Oe_Sys_Parameters.Value('COMPUTE_MARGIN');
 END IF;

   IF aso_debug_pub.g_debug_flag = 'Y' THEN
	aso_debug_pub.add(' G_COMPUTE_METHOD'||G_COMPUTE_METHOD);
  end if;

 /* Commented for bug 18303630
 IF G_COMPUTE_METHOD = 'N' THEN
  IF aso_debug_pub.g_debug_flag = 'Y' THEN
	aso_debug_pub.add(' Not computing cost, compute method is N');
  end if;
  RETURN NULL;
 END IF;
*/

 l_line_rec := p_line_rec;

 open   c_get_warehouse(l_line_rec.quote_line_id, l_line_rec.quote_header_id);
 fetch  c_get_warehouse into l_SHIP_FROM_ORG_ID;
 close  c_get_warehouse;

 IF aso_debug_pub.g_debug_flag = 'Y' THEN
	 aso_debug_pub.add(' Quote line level ship of org from warehouse :'||l_ship_from_org_id);
end if;

 if l_SHIP_FROM_ORG_ID is null then
   open c_get_ids(l_line_rec.quote_line_id);
   fetch c_get_ids into l_ato_line_id,l_top_model_line_id;
   close c_get_ids;
    IF aso_debug_pub.g_debug_flag = 'Y' THEN
	 aso_debug_pub.add(' ATO line id :'||l_ato_line_id);
	  aso_debug_pub.add(' Top model line id :'||l_top_model_line_id);
   end if;
   -- if the line is an option under ATO
   if (l_ato_line_id is not null and l_top_model_line_id is not null )then
       -- check if record has been passed in , then honor that
       open c_shipment_id(l_ato_line_id);
       fetch c_shipment_id into l_shipment_id;
       close c_shipment_id;

       open c_ship_org_id(l_shipment_id);
       fetch c_ship_org_id into l_SHIP_FROM_ORG_ID;
       close c_ship_org_id;

        IF aso_debug_pub.g_debug_flag = 'Y' THEN
	 aso_debug_pub.add(' ATO line id ship of org:'||l_ship_from_org_id);
	end if;

       if l_SHIP_FROM_ORG_ID is null then
         -- try to cascade from top model
            if l_ato_line_id <> l_top_model_line_id then
            -- check if PTO Model record has been passed in , then honor that
		open c_shipment_id(l_top_model_line_id);
		fetch c_shipment_id into l_shipment_id;
		close c_shipment_id;

		open c_ship_org_id(l_shipment_id);
		fetch c_ship_org_id into l_SHIP_FROM_ORG_ID;
		close c_ship_org_id;

		IF aso_debug_pub.g_debug_flag = 'Y' THEN
			aso_debug_pub.add(' PTO line id ship of org:'||l_ship_from_org_id);
		 end if;

	 end if;
       end if;
    elsif (l_ato_line_id is null and l_top_model_line_id is not null )then
       open c_shipment_id(l_top_model_line_id);
       fetch c_shipment_id into l_shipment_id;
       close c_shipment_id;

	open c_ship_org_id(l_shipment_id);
	fetch c_ship_org_id into l_SHIP_FROM_ORG_ID;
	close c_ship_org_id;

	IF aso_debug_pub.g_debug_flag = 'Y' THEN
		aso_debug_pub.add(' TOP model line id ship of org:'||l_ship_from_org_id);
	end if;

  end if;  -- end ATO and top model line id not null
end if; -- end l_ship_from_org null


if l_SHIP_FROM_ORG_ID is null then
-- Use the profile value ASO: Default Ship From Org
   l_ship_from_org_id := fnd_profile.value(name => 'ASO_SHIP_FROM_ORG_ID');
 end if;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
	 aso_debug_pub.add(' Ship from Org using profile:'||l_ship_from_org_id);
end if;


if l_ship_from_org_id is null then
  l_ship_from_org_id:=l_line_rec.ORGANIZATION_ID;
end if;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
	 aso_debug_pub.add(' Final value of Ship from Org :'||l_ship_from_org_id);
end if;



  -- Fetching primary UOM
  BEGIN
   SELECT primary_uom_code
    INTO l_primary_uom_code
    FROM mtl_system_items
    WHERE inventory_item_id = l_line_rec.inventory_item_id
    AND  organization_id = l_line_rec.organization_id;
  EXCEPTION
   WHEN OTHERS THEN
       IF aso_debug_pub.g_debug_flag = 'Y' THEN
	 aso_debug_pub.add(' Error in fetching primary UOM:'||SQLERRM);
        end if;
  END;



    l_unit_cost:=cst_cost_api.get_item_cost
                 (p_api_version=>1
                 ,p_inventory_item_id=>l_line_rec.inventory_item_id
                 ,p_organization_id=>L_SHIP_FROM_ORG_ID
                 ,p_cost_group_id=>null
                 ,p_cost_type_id=>null);

IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add(' unit cost before convert:'||l_unit_cost);
    aso_debug_pub.add('Order_quantity_uom : '||l_Line_rec.uom_code);
    aso_debug_pub.add('Inventory_item_id : '||l_Line_rec.Inventory_item_id);
end if;
    If l_primary_uom_code <> l_Line_rec.uom_code
       and l_unit_cost is not null and l_unit_cost <> fnd_api.g_miss_num Then
       INV_CONVERT.INV_UM_CONVERSION(   From_Unit => l_primary_uom_code
                                        ,To_Unit   => l_Line_rec.uom_code
                                        ,Item_ID   => l_Line_rec.Inventory_item_id
                                        ,Uom_Rate  => l_Uom_rate);
       l_unit_cost := l_unit_cost * l_Uom_rate;
       IF aso_debug_pub.g_debug_flag = 'Y' THEN
	  aso_debug_pub.add('l_Uom_rate : '||l_Uom_rate);
	  aso_debug_pub.add(' Unit cost for item after convert:'||l_unit_cost);
       end if;



    End If;


-- Code for currency conversion in case functional currency is different from quote currency
Begin
Select CURRENCY_CODE
into l_org_currency
from CST_ORGANIZATION_DEFINITIONS
where ORGANIZATION_ID = L_SHIP_FROM_ORG_ID;
exception
 WHEN OTHERS THEN
    IF aso_debug_pub.g_debug_flag = 'Y' THEN
         aso_debug_pub.add(' Error in fetching Cost Currency:'||SQLERRM);
    end if;
 END;

select currency_code,nvl(Price_frozen_date,NVL(PRICE_UPDATED_DATE, last_update_date)) dt
into l_order_currency,l_conversion_date
from aso_quote_headers_all
where quote_header_id=l_line_rec.quote_header_id;

if l_org_currency<>l_order_currency then
   BEGIN

        l_unit_cost_gl:=gl_currency_api.convert_closest_amount_sql(
			x_from_currency =>  l_ORG_CURRENCY, -- functional currency ,
			x_to_currency =>    l_order_currency, -- line currency,
			x_conversion_date => l_conversion_date,
                        x_conversion_type => nvl(fnd_profile.VALUE('ASO_QUOTE_CONVERSION_TYPE'),'Corporate'),
                        x_user_rate => 1 ,
                        x_amount => l_unit_cost,
                        x_max_roll_days => -1);
       l_unit_cost := l_unit_cost_gl;
       IF aso_debug_pub.g_debug_flag = 'Y' THEN
	       aso_debug_pub.add(' Converted unit cost:'||l_unit_cost);
        end if;
    EXCEPTION

      WHEN OTHERS THEN
        IF aso_debug_pub.g_debug_flag = 'Y' THEN
	       aso_debug_pub.add('Gl_Currency_Api.Convert_Amount returns errors:'||SQLERRM);
        end if;
       RETURN NULL;
    END;

end if;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
	aso_debug_pub.add('just before return ASO_MARGIN_PVT.get_cost');
	aso_debug_pub.add('l_unit_cost ='||l_unit_cost);
end if;

 RETURN l_unit_cost;


EXCEPTION
WHEN OTHERS THEN
  IF aso_debug_pub.g_debug_flag = 'Y' THEN
     aso_debug_pub.add(' ASO_MARGIN_PVT:Unable to get cost:'||SQLERRM);
  end if;
  Return null;
END GET_COST;

-----------------------------------------------------------------------------
Procedure Get_Line_Margin
----------------------------------------------------------------------------
                         (p_qte_line_id IN NUMBER,
                          x_unit_cost Out NOCOPY Number,
                          x_unit_margin_amount Out NOCOPY Number,
                          x_margin_percent Out NOCOPY Number) As
l_cost            Number;
l_margin_amt      Number;
l_margin_percent  Number;
l_line_rec        ASO_QUOTE_PUB.Qte_Line_Rec_Type;

X_MARGIN_LINE_TBL ASO_QUOTE_HOOK.MARGIN_LINE_Tbl_Type;
Begin
 l_line_rec:= aso_utility_pvt.Query_Qte_Line_Row(p_qte_line_id);

 if fnd_profile.value('ASO_GROSS_MARGIN_COMPUTE')='CALLBACK FUNCTION' then  -- bug 18294325
	   --Use ASO_QUOTE_HOOK.COMPUTE_MARGIN to fetch the unit cost, margin amount and margin percent
	   ASO_QUOTE_HOOK.COMPUTE_MARGIN    ( P_QUOTE_HEADER_ID =>   l_line_rec.quote_header_id,
	     P_QUOTE_LINE_ID =>     l_line_rec.quote_line_id,
	     X_MARGIN_LINE_TBL =>   X_MARGIN_LINE_TBL,
	     X_QUOTE_UNIT_COST =>   l_cost,
	     X_QUOTE_MARGIN    =>   l_margin_amt,
	     X_QUOTE_MARGIN_PER  => l_margin_percent);

	     x_unit_cost:=X_MARGIN_LINE_TBL(1).UNIT_COST;
             x_unit_margin_amount:=X_MARGIN_LINE_TBL(1).MARGIN_AMOUNT;
	     x_margin_percent:=X_MARGIN_LINE_TBL(1).MARGIN_PERCENT;

	    return;
else

 l_cost:=Get_Cost(p_line_rec=>l_line_rec);
 x_unit_cost:=l_cost;
 If (l_line_rec.line_quote_price is Null) or (l_cost is null) Then
   IF aso_debug_pub.g_debug_flag = 'Y' THEN
	   aso_debug_pub.add('Warning:- unit selling price is null,margin not relevant');
	   aso_debug_pub.add('Exiting aso_margin_pvt.get_line_margin');
    end if;
   Return;
 End If;
 l_margin_amt := nvl(l_line_rec.LINE_QUOTE_PRICE,0) - nvl(l_cost,0);
 x_unit_margin_amount:=l_margin_amt;

 IF (G_COMPUTE_METHOD = 'P') or (G_COMPUTE_METHOD='N') THEN -- bug 18303630
   If l_line_rec.line_quote_price = 0 Then
     IF aso_debug_pub.g_debug_flag = 'Y' THEN
	     aso_debug_pub.add('Warning: Price based margin calculation is invalid,because 0 selling price, divided by zero error would occur. Returning');
      end if;
     x_margin_percent:=NULL;
     Return;
   End If;

   l_margin_percent := l_margin_amt/l_line_rec.LINE_QUOTE_PRICE*100;
   x_margin_percent := l_margin_percent;
 Elsif G_COMPUTE_METHOD = 'C' THEN
     If nvl(l_cost,0) = 0 Then
       IF aso_debug_pub.g_debug_flag = 'Y' THEN
	aso_debug_pub.add('Warning: Cost based margin calculation is invalid,because 0 cost, divided by zero error would occur. Returning');
       end if;
     x_margin_percent:=NULL;
     Return;
   End If;

   x_margin_percent :=  l_margin_amt/l_cost*100;
 End If;
 END If;  -- profile endif
End Get_Line_Margin;


--------------------------------------------------
PROCEDURE Get_Quote_Margin
-------------------------------------------------
(p_qte_header_id              IN  NUMBER,
 p_org_id  IN NUMBER default NULL,
 x_quote_unit_cost OUT NOCOPY NUMBER,
 x_quote_margin_percent OUT NOCOPY NUMBER,
 x_quote_margin_amount OUT NOCOPY NUMBER) IS

 l_compute_method VARCHAR2(1);
 l_margin_ratio         NUMBER;
 l_margin_amount        NUMBER;


 l_total_selling_price  Number :=0;
 l_total_cost		Number :=0;
 l_unit_SP		Number;
 l_unit_cost		Number;
 l_ordered_qty		Number;

 X_MARGIN_LINE_TBL ASO_QUOTE_HOOK.MARGIN_LINE_Tbl_Type;

CURSOR MARGIN is
SELECT quantity, line_quote_price, nvl(line_unit_cost,0) unit_cost
  FROM  ASO_QUOTE_LINES_ALL
  WHERE quote_header_id = p_qte_header_id
  AND   line_unit_cost IS NOT NULL
  AND   line_category_code = 'ORDER';

BEGIN
  IF aso_debug_pub.g_debug_flag = 'Y' THEN
  aso_debug_pub.add('Entering ASO_Margin_Pvt.Get_Quote_Margin');
  aso_debug_pub.add('Profile value'||fnd_profile.value('ASO_GROSS_MARGIN_COMPUTE'));
  end if;

   if fnd_profile.value('ASO_GROSS_MARGIN_COMPUTE')='CALLBACK FUNCTION' then --bug 18294325
	   --Use ASO_QUOTE_HOOK.COMPUTE_MARGIN to fetch the unit cost, margin amount and margin percent
	   ASO_QUOTE_HOOK.COMPUTE_MARGIN    ( P_QUOTE_HEADER_ID =>   p_qte_header_id,
	     P_QUOTE_LINE_ID =>     null,
	     X_MARGIN_LINE_TBL =>   X_MARGIN_LINE_TBL,
	     X_QUOTE_UNIT_COST =>   x_quote_unit_cost,
	     X_QUOTE_MARGIN    =>   x_quote_margin_percent,
	     X_QUOTE_MARGIN_PER  => x_quote_margin_amount);



	    return;
    else



 --retrive margin calculation method perference
 l_compute_method:=Oe_Sys_Parameters.Value('COMPUTE_MARGIN', p_org_id);

IF aso_debug_pub.g_debug_flag = 'Y' THEN
  aso_debug_pub.add(' Margin_Compute_Method:'||l_compute_method);
end if;

 /* Commented for bug 18303630
  IF l_compute_method = 'N'  THEN
   x_quote_unit_cost := NULL;
   x_quote_margin_percent := NULL;
   x_quote_margin_amount  := NULL;
   IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add(' Margin not computed system parameter says N');
   end if;
   RETURN;
 End IF;
*/

open margin;
loop
	fetch margin into l_ordered_qty,l_unit_SP,l_unit_cost;
	exit when margin%NOTFOUND;
	l_total_selling_price := l_total_selling_price + (l_ordered_qty * l_unit_SP);
	l_total_cost := l_total_cost + (l_ordered_qty * l_unit_cost);
end loop;
close margin;
l_margin_amount := l_total_selling_price-l_total_cost;


 IF (l_compute_method = 'P') or (l_compute_method='N') THEN -- bug 18303630
  IF aso_debug_pub.g_debug_flag = 'Y' THEN
   aso_debug_pub.add(' Margin based on price');
  end if;
  --Margin percent based on price

    l_margin_ratio := l_margin_amount/l_total_selling_price;

    x_quote_unit_cost:=l_total_cost;
    x_quote_margin_amount :=l_margin_amount;

  IF l_margin_amount < 0 THEN
    --quote level margin amount less than 0, making a loss, percent should be negative also
    x_quote_margin_percent := -1 * ABS(l_margin_ratio * 100);
  ELSE
    x_quote_margin_percent := l_margin_ratio * 100;
  END IF;
  IF aso_debug_pub.g_debug_flag = 'Y' THEN
   aso_debug_pub.add('Leaving ASO_Margin_Pvt.Get_Quote_Margin');
  end if;
  RETURN;

 END IF;

 IF l_compute_method = 'C' THEN
  IF aso_debug_pub.g_debug_flag = 'Y' THEN
   aso_debug_pub.add(' Margin based on cost');
  end if;
  --Margin percent based on cost


  l_margin_ratio := l_margin_amount/l_total_cost;
  x_quote_unit_cost:=l_total_cost;
  x_quote_margin_amount := l_margin_amount;

  IF l_margin_amount < 0 THEN
    --order level margin amount less than 0, making a lost, percent should be negative also
    x_quote_margin_percent := -1 * ABS(l_margin_ratio * 100);
  ELSE
    x_quote_margin_percent := l_margin_ratio * 100;
  END IF;

 END IF;
 end if; -- profile end if

 IF aso_debug_pub.g_debug_flag = 'Y' THEN

  aso_debug_pub.add('Leaving ASO_Margin_Pvt.Get_Quote_Margin');
end if;

EXCEPTION
WHEN ZERO_DIVIDE THEN
 IF l_compute_method = 'P' THEN
   IF aso_debug_pub.g_debug_flag = 'Y' THEN
   aso_debug_pub.add(' ASO_Margin_Pvt.Get_Quote_Margin ZERO price');
   end if;

  x_quote_unit_cost:= null;
  x_quote_margin_amount := null;
  x_quote_margin_percent:= null;

 ElSIF l_compute_method = 'C' THEN

   IF aso_debug_pub.g_debug_flag = 'Y' THEN
   aso_debug_pub.add(' ASO_Margin_Pvt.Get_Quote_Margin ZERO cost:');
   end if;
  x_quote_unit_cost:= null;
  x_quote_margin_amount := null;
  x_quote_margin_percent:= null;

 ELSE
 IF aso_debug_pub.g_debug_flag = 'Y' THEN
  aso_debug_pub.add(' ASO_Margin_Pvt.Get_Quote_Margin:'||SQLERRM);
  end if;

 END IF;

WHEN OTHERS THEN
 IF aso_debug_pub.g_debug_flag = 'Y' THEN
 aso_debug_pub.add(' ASO_Margin_Pvt.Get_Quote_Margin unable get margin:'||SQLERRM);
 end if;
End Get_Quote_Margin;

End  ASO_MARGIN_PVT;

/
