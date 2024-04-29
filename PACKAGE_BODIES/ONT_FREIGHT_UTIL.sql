--------------------------------------------------------
--  DDL for Package Body ONT_FREIGHT_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ONT_FREIGHT_UTIL" AS
/* $Header: OEXUFDBB.pls 120.1 2005/06/21 02:31:03 appldev ship $ */

  PROCEDURE dbms_debug(p_debug IN VARCHAR2)
       IS
	  i INTEGER;
	  m INTEGER;
	  c INTEGER := 80;
     BEGIN
	m := Ceil(Length(p_debug)/c);
	FOR i IN 1..m LOOP
	   execute immediate ('begin dbms' ||
			      '_output' ||
			      '.put_line(''' ||
			      REPLACE(Substr(p_debug, 1+c*(i-1), c), '''', '''''')||
			      '''); end;');
	END LOOP;
     EXCEPTION
	WHEN OTHERS THEN
	   NULL;
     END dbms_debug;

Procedure Freight_Debug(p_header_name  In Varchar2 default null,
                        p_list_line_id In Number   default null,
                        p_line_id      In Number)
As
l_list_header_id   Number;
l_list_header_name Varchar2(250);
l_pricing_phase_id Number;
l_list_line_id     Number;
l_line_rec         Oe_Order_Pub.Line_Rec_Type;
l_freeze_override_flag Varchar2(1);
l_cost_type_code   Varchar2(30);
l_cost_amount      Number;
l_pricing_contexts_tbl         QP_Attr_Mapping_PUB.Contexts_Result_Tbl_Type;
l_qualifier_contexts_Tbl      QP_Attr_Mapping_PUB.Contexts_Result_Tbl_Type;
l_found boolean default false;
l_dummy Varchar2(30);
l_inv_interfaced_flag Varchar2(1);
l_oe_interfaced_flag  Varchar2(1);
j Number;
l_Price_Control_rec		QP_PREQ_GRP.control_record_type;
l_return_status                 VARCHAR2(5);
l_x_line_tbl			oe_order_pub.line_tbl_type;
l_pricing_status_code           VARCHAR2(15);

Cursor list_line_info1 is
select b.list_header_id,
       b.list_line_id,
       b.list_line_type_code,
       b.start_date_active,
       b.end_date_active,
       b.modifier_level_code,
       b.pricing_phase_id,
       b.incompatibility_grp_code,
       b.price_break_type_code,
       b.operand,
       b.automatic_flag,
       b.arithmetic_operator,
       b.qualification_ind,
       b.product_precedence,
       b.price_by_formula_id
from qp_list_headers_vl a,
     qp_list_lines b
where a.name = p_header_name
and   a.list_header_id = b.list_header_id;

Cursor list_line_info2 is
select b.list_header_id,
       b.list_line_id,
       b.list_line_type_code,
       b.start_date_active,
       b.end_date_active,
       b.modifier_level_code,
       b.pricing_phase_id,
       b.incompatibility_grp_code,
       b.price_break_type_code,
       b.operand,
       b.automatic_flag,
       b.arithmetic_operator,
       b.qualification_ind,
       b.product_precedence,
       b.price_by_formula_id
From qp_list_lines b
where list_line_id = p_list_line_id;

Cursor pricing_attribute_info Is
select  list_line_id
	 , list_header_id
	 , pricing_phase_id
	 , product_attribute_context
	 , product_attribute
	 , product_attr_value
	 , product_uom_code
	 , comparison_operator_code
	 , pricing_attribute_context
	 , pricing_attribute
	 , pricing_attr_value_from
	 , pricing_attr_value_to
	 , attribute_grouping_no
	 , qualification_ind
	 , excluder_flag
from  qp_pricing_attributes
where list_line_id = p_list_line_id;

/*select dl.delivery_id,
       pa.line_id,
       pa.cost_id,
       pa.list_line_type_code,
       pa.adjusted_amount,
       pa.operand
from oe_price_adjustments pa,
    wsh_delivery_details dd,
    wsh_delivery_assignments da,
    wsh_new_deliveries dl
where dl.name = 'delivery_name'
and dl.delivery_id = da.delivery_id
and da.delivery_detail_id = dd.delivery_detail_id
and dd.source_code = 'OE'
and dd.source_line_id = pa.line_id
and pa.list_line_type_code = 'COST'; */

Cursor Other_Cost is
Select CHARGE_TYPE_CODE,Adjusted_amount
From   oe_price_adjustments
Where  line_id = l_line_rec.line_id
and    list_line_type_code = 'COST';

Cursor formula_attribute(p_price_formula_id In Number) is
Select a.pricing_attribute_context,
       a.pricing_attribute,
       a.price_formula_line_id,
       a.numeric_constant,
       a.step_number,
       a.start_date_active,
       a.end_date_active,
       b.name
From   qp_price_formula_lines a,
       qp_price_formulas_vl b
Where  a.price_formula_id = p_price_formula_id
and    b.price_formula_id = p_price_formula_id;

--Type list_line_info_type list_line_info1%rowtype;
l_list_line_info list_line_info1%rowtype;
l_pricing_attribute_info pricing_attribute_info%rowtype;
l_org_id Number;
Begin

  Begin
   Select org_id into l_org_id
   From   oe_order_lines_all
   Where  line_id = p_line_id;

  Exception
   When No_Data_Found Then
   DBMS_DEBUG('Error: Invalid line id, exiting');
   Return;
  End;
   --MOAC changes
   --dbms_application_info.set_client_info(l_org_id);
   mo_global.set_policy_context('S',l_org_id);
   --MOAC Changes
  --Hardcode it for now, need to revisit this later.
  l_cost_type_code := 'FREIGHT';

  If p_list_line_id is null and p_header_name is null Then
    DBMS_DEBUG('Please enter provide Modifier header name or list line id');
    Return;
  End If;

  If p_list_line_id is not null and p_header_name is not null Then
    DBMS_DEBUG('Please enter either header name or list line id. Not both');
    Return;
  End If;

  If p_list_line_id is not null Then
    Begin
     Open list_line_info2;
     Fetch list_line_info2 into l_list_line_info;

    Exception When Others Then
     DBMS_DEBUG(SQLERRM);
    End;
    Close list_line_info2;
  Elsif p_header_name is not null Then
    Begin
     Open list_line_info1;
     Fetch list_line_info1 into l_list_line_info;

     If list_line_info1%ROWCOUNT > 1 Then
      DBMS_DEBUG('This header has multiple modifiers, please specify one by just passing list line id');
      close list_line_info1;
      Return;
     End If;

   Exception When Others Then
     DBMS_DEBUG(SQLERRM);
   End;
   close list_line_info1;
  End If;

/*************************************************
--check if there is data qp_list_header_phases
--if not this is a pricing bug
*************************************************/
DBMS_DEBUG('Checking for pricing bug');
  Begin
    Select list_header_id,
           pricing_phase_id
    Into   l_list_header_id,l_pricing_phase_id
    from   qp_list_header_phases
    where  list_header_id = l_list_line_info.list_header_id;
  Exception
    when no_data_found Then
      --check if it has line level qualifier
      Begin
      Select list_line_id into l_dummy
      From   qp_qualifiers
      Where  list_header_id = l_list_line_info.list_header_id
      and    nvl(list_line_id,-1)   = l_list_line_id
      and    rownum = 1;

      DBMS_DEBUG(' Oracle Pricing bugs.');
      DBMS_DEBUG(' Please apply pricing patch 1806021 if this is an upgrade');
      DBMS_DEBUG(' Otherwise apply 1797603');

      Exception
        When no_data_found then null;
        DBMS_DEBUG(' Passed');
      End;
    when too_many_rows Then
      DBMS_DEBUG(' Passed');
      Null;
    when others Then
      DBMS_DEBUG(SQLERRM);
  End;

DBMS_DEBUG('--------------------------');
/*******************************************
--check if the freeze_override_flag set to Y
********************************************/
Begin
  select a.freeze_override_flag
  into l_freeze_override_flag
  from qp_pricing_phases a, qp_event_phases b
  where a.pricing_phase_id = b.pricing_phase_id
        and b.pricing_event_code='SHIP'
        and a.pricing_phase_id  =l_list_line_info.pricing_phase_id;

  If l_freeze_override_flag Is Null or l_freeze_override_flag = 'N' Then
   DBMS_DEBUG(' Freeze override flag for SHIP event and phase id '||l_list_line_info.pricing_phase_id ||'is ''N'' or nulll');
   DBMS_DEBUG(' Please contact Oracle Pricing to fix this problem');
  End If;

Exception
When no_data_found then
DBMS_DEBUG(SQLERRM||':Event phases check. Please make sure your the pricing phase for your modifier has been associated to SHIP event');
When Others then
DBMS_DEBUG(SQLERRM||':Event phases');
End;

--query line and header record
--Set org?
oe_line_util.query_row(p_line_id,l_line_rec);

If l_line_rec.line_id is null Then
  DBMS_DEBUG('Invalid line id or incorrect org_id');
  Return;
End If;


/*****************************
--testing qp attribute mapping
******************************/
DBMS_DEBUG('Checking if attributes sourced by Pricing');
OE_Order_Pub.G_Line := l_line_rec;

Begin
QP_Attr_Mapping_PUB.Build_Contexts(p_request_type_code => 'ONT',
                                     p_pricing_type	=>	'L',
			             x_price_contexts_result_tbl => l_pricing_contexts_Tbl,
			             x_qual_contexts_result_tbl  => l_qualifier_Contexts_Tbl);

Exception when others then
DBMS_DEBUG('QP Attribute mapping:'||SQLERRM);
End;
OE_Order_Pub.G_Line := NULL;

--Test if attribute mapping sorces required pricing attributes
For i in pricing_attribute_info Loop
  l_found:=false;
  DBMS_DEBUG('Check if attribute mapping sources:'||i.pricing_attribute_context||','||i.pricing_attribute||','||i.pricing_attr_value_from);

  j := l_pricing_contexts_tbl.first;
  While j is not null Loop
    if i.pricing_attribute_context = l_pricing_contexts_tbl(j).context_name
       and i.pricing_attribute =  l_pricing_contexts_tbl(j).attribute_name Then
       DBMS_DEBUG('  This attribute is sourced with value:'||l_pricing_contexts_tbl(j).attribute_value);
       l_found := True;
       exit;
    End If;
  j:= l_pricing_contexts_tbl.next(j);
  End Loop;


  If not l_found Then
    DBMS_DEBUG('  This attribute did not get sourced. The caused could be:');
    DBMS_DEBUG('  1. You have not run QP build sourcing concurent program');
    DBMS_DEBUG('  2. The cost record was not passed to OM');
  Else
    DBMS_DEBUG('Passed');
  End If;

End Loop;

  DBMS_DEBUG('Attribute setup in for formula id:'||l_list_line_info.price_by_formula_id);
  --DBMS_DEBUG('Formula Name:
  For f In formula_attribute(l_list_line_info.price_by_formula_id) Loop
   DBMS_DEBUG(' Context:'||f. pricing_attribute_context);
   DBMS_DEBUG(' Pricing Attribute:'||f.pricing_attribute);
   DBMS_DEBUG(' Numeric Constant:'||f.numeric_constant);
  End Loop;

  DBMS_DEBUG('Attribute sourced by QP_ATTRIBUTE_MAPPING:');
  j := l_pricing_contexts_tbl.first;
  While j is not null Loop
    DBMS_DEBUG(' Context sourced:'||l_pricing_contexts_tbl(j).context_name);
    DBMS_DEBUG(' Attribute sourced:'||l_pricing_contexts_tbl(j).attribute_name);
  j:= l_pricing_contexts_tbl.next(j);
  End Loop;

DBMS_DEBUG('--------------------------------');

/*********************************
--Check the pricing quantity of the line
**********************************/
DBMS_DEBUG('Checking pricing_quantity of the line');
If l_line_rec.pricing_quantity < 0 or l_line_rec.pricing_quantity = FND_API.G_MISS_NUM Then
  DBMS_DEBUG(' Error: Invalid pricing quantity:'|| l_line_rec.pricing_quantity);
  Return;
Else
  DBMS_DEBUG('Passed');
  DBMS_DEBUG('-------------');
End If;

/*********************************
--check if this is a shippable line
**********************************/
DBMS_DEBUG('Checking if the line is shippable');
If l_line_rec.shippable_flag = 'N' or nvl(l_line_rec.shipped_quantity,-999) <=  0 Then
  DBMS_DEBUG(' Error: Either this line is not shippable or has not been ship confirmed');
  DBMS_DEBUG(' Shippable flag:'||l_line_rec.shippable_flag);
  DBMS_DEBUG(' Shipped Qty:'||l_line_rec.shipped_quantity);
  Return;
Else
  DBMS_DEBUG('Passed');
  DBMS_DEBUG('-------------');
End If;

/*********************************
--check calculate_price_flag
**********************************/
DBMS_DEBUG('Checking if the calculate price is set to either ''Partial'' or ''Yes''');
If nvl(l_line_rec.calculate_price_flag,'N') = 'N' Then
  DBMS_DEBUG('  Error: The calculate price flag is set to ''No''. Freight charge will not come');
  --Return;
Else
  DBMS_DEBUG('Passed');
  DBMS_DEBUG('-------------');
End If;


/*************************************************
--Check if this line has been inventory interfaced
**************************************************/
DBMS_DEBUG('Checking if the line has been inventory interfaced');
Begin
 Select inv_interfaced_flag, oe_interfaced_flag
 Into   l_inv_interfaced_flag,l_oe_interfaced_flag
 From   wsh_delivery_details
 Where  source_line_id = l_line_rec.line_id;

If nvl(l_inv_interfaced_flag,'X') <> 'Y' Then
  DBMS_DEBUG('  This line has not been inventory interfaced. Shipping could not happen before inventory interface. Please check with inventory about this issue.');
  DBMS_DEBUG('  inv_interfaced_flag:'||l_inv_interfaced_flag);
  --Return;
Else
  DBMS_DEBUG('  Passed');
  DBMS_DEBUG('  This line has been inventory interfaced');
End If;

Exception
When no_data_found Then
  DBMS_DEBUG('Line Id:'||l_line_rec.line_id||' can not be found in wsh_delivery_details');
  Return;
When Others Then
  DBMS_DEBUG(SQLERRM);
End;
DBMS_DEBUG('-------------------------');
/***************************************************
--Check if this line has been om interfaced
****************************************************/
DBMS_DEBUG('Checking if the line has been OM interfaced');
DBMS_DEBUG(' oe_interfaced_flag:'||l_oe_interfaced_flag);

DBMS_DEBUG('-------------------------');
/************************************************
--check if cost record have been inserted into OM
*************************************************/
DBMS_DEBUG('Checking if freight cost has been passed to OM');

-- Cost records are stored in OE_PRICE_ADJUSTMENTS table with
-- list_line_type_code = 'COST'
Begin
       SELECT SUM(ADJUSTED_AMOUNT)
	  INTO l_cost_amount
	  FROM OE_PRICE_ADJUSTMENTS_V
	  WHERE LINE_ID = l_line_rec.line_id
	  AND LIST_LINE_TYPE_CODE = 'COST'
	  AND CHARGE_TYPE_CODE = l_cost_type_code;
If l_cost_amount is not Null Then
 DBMS_DEBUG('  Passed. Cost record inserted with value:'||l_cost_amount);
Else
  DBMS_DEBUG('  Error: Freight Cost record is not passed by Shipping or you have not entered the freight cost');
End If;

Exception
When No_Data_Found Then
 DBMS_DEBUG('  Error: Freight Cost record is not passed by Shipping or you have not entered the freight cost');
End;

For i in Other_Cost Loop
  DBMS_DEBUG(' Inserted charge cost type in OM:'||i.charge_type_code);
  DBMS_DEBUG(' Cost Amount:'||i.adjusted_amount);
End Loop;

/*****************************************************************************
Check for automatic flag, It must set to Y in order for cost to charge to work
******************************************************************************/
DBMS_DEBUG('----------------------------------');
DBMS_DEBUG('Check if automatic flag set to ''Y'' ');
If l_list_line_info.automatic_flag = 'N' Then
  DBMS_DEBUG('Error: You have set your modifier to None automatic (manual)');
  DBMS_DEBUG('       Please go to modifier form and check automatic check box to make it automatic');
Else
  DBMS_DEBUG('Passed');
End If;

DBMS_DEBUG('----------------------------------');
/*********************************************************************************************
Simulating pricing engine call to make sure pricing engine returns this freight charge modifier
**********************************************************************************************/
DBMS_DEBUG('Testing if pricing engine returns this modifier');
l_Price_Control_Rec.pricing_event := 'SHIP';
l_Price_Control_Rec.calculate_flag := QP_PREQ_GRP.G_SEARCH_N_CALCULATE;
l_Price_Control_Rec.Simulation_Flag := 'N';
oe_order_Adj_pvt.Price_line(X_Return_Status     => l_Return_Status
			    ,p_header_id	=> l_line_rec.header_id
			    ,p_Request_Type_code=> 'ONT'
			    ,p_Control_rec      => l_Price_Control_Rec
			    ,p_Write_To_Db      => FALSE
			    ,x_Line_Tbl         => l_x_Line_Tbl);
Begin
Select pricing_status_code
into   l_pricing_status_code
From   qp_preq_ldets_tmp
Where  created_from_list_line_id = l_list_line_info.list_line_id;

If l_pricing_status_code <> QP_PREQ_GRP.G_STATUS_NEW Then
DBMS_DEBUG('Error: Oracle Pricing did not find this modifier line:'||l_list_line_info.list_line_id);
DBMS_DEBUG('     : Pricing status code from pricing engine is:'||l_pricing_status_code);
Else
DBMS_DEBUG('Passed');
End If;

Exception when no_data_found Then
DBMS_DEBUG('Error: Oracle Pricing Engine does not return this modifier, please contact Pricing');
DBMS_DEBUG('Please run $QP_TOP/patch/115/sql/qp_list_line_detail.sql and provide the output to Pricing');
when others Then
DBMS_DEBUG('Pricing simulation:'||SQLERRM);
End;

End;

END ONT_FREIGHT_UTIL;

/
