--------------------------------------------------------
--  DDL for Package Body AMS_PRICE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_PRICE_PVT" as
/* $Header: amsvprcb.pls 120.0 2005/05/31 22:35:26 appldev noship $ */

g_use_header_qual	CONSTANT varchar2(1) := 'Y';

AMS_DEBUG_HIGH_ON constant boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON constant boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON constant boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE GET_TIME(t OUT NOCOPY number)
IS
BEGIN
 t := to_char(sysdate, 'ssss');
--select to_char(sysdate, 'sssss') into t from dual;
END GET_TIME;

Function set_oe_Header_rec (
	 p_party_id		number :=  FND_API.G_MISS_NUM
	,p_cust_account_id	number :=  FND_API.G_MISS_NUM
	,p_price_list_id	number :=  FND_API.G_MISS_NUM
) return oe_order_pub.header_rec_type
is
	l_pricing_header_rec	oe_order_pub.header_rec_type;
begin
--	l_pricing_header_rec.party_id := p_party_id;
	l_pricing_header_rec.sold_to_org_id := p_cust_account_id;
	l_pricing_header_rec.price_list_id:= p_price_list_id;
	return l_pricing_header_rec;
end set_oe_header_rec;

Function set_aso_Header_rec (
	 p_party_id		number :=  FND_API.G_MISS_NUM
	,p_cust_account_id	number :=  FND_API.G_MISS_NUM
	,p_price_list_id	number :=  FND_API.G_MISS_NUM
) return aso_pricing_int.PRICING_HEADER_REC_TYPE
IS
	l_pricing_header_rec	aso_pricing_int.PRICING_HEADER_REC_TYPE;
BEGIN
	l_pricing_header_rec.party_id := p_party_id;
	l_pricing_header_rec.cust_account_id := p_cust_account_id;
	l_pricing_header_rec.price_list_id:= p_price_list_id;
	return l_pricing_header_rec;
END set_aso_header_rec;


Function set_oe_line_rec (
	p_inventory_item_id	number := FND_API.G_MISS_NUM
	,p_uom_code		varchar2 := FND_API.G_MISS_CHAR
	,p_price_list_id	number := FND_API.G_MISS_NUM
	,p_party_id		number := FND_API.G_MISS_NUM
	,p_cust_account_id	number := FND_API.G_MISS_NUM
) return oe_order_pub.line_rec_type
is
	l_pricing_line_rec	 oe_order_pub.line_rec_type;
begin
	l_pricing_line_rec.inventory_item_id := p_inventory_item_id;
	l_pricing_line_rec.order_quantity_uom:= p_uom_code;
	l_pricing_line_rec.ordered_quantity:= 1;
	l_pricing_line_rec.price_list_id := p_price_list_id;
--	l_pricing_line_rec.party_id := p_party_id;
--	l_pricing_line_rec.cust_account_id := p_cust_account_id;
	return l_pricing_line_rec;
end set_oe_line_rec;


Function set_aso_line_rec (
	p_inventory_item_id	number := FND_API.G_MISS_NUM
	,p_uom_code		varchar2 := FND_API.G_MISS_CHAR
	,p_price_list_id	number := FND_API.G_MISS_NUM
	,p_party_id		number := FND_API.G_MISS_NUM
	,p_cust_account_id	number := FND_API.G_MISS_NUM
) return aso_pricing_int.PRICING_line_REC_TYPE
is
	l_pricing_line_rec	 aso_pricing_int.PRICING_line_REC_TYPE;
begin
	l_pricing_line_rec.inventory_item_id := p_inventory_item_id;
	l_pricing_line_rec.uom_code:= p_uom_code;
	l_pricing_line_rec.quantity:= 1;
	l_pricing_line_rec.price_list_id := p_price_list_id;
--	l_pricing_line_rec.party_id := p_party_id;
--	l_pricing_line_rec.cust_account_id := p_cust_account_id;
	return l_pricing_line_rec;
end set_aso_line_rec;



PROCEDURE Copy_Attribs_To_Req(
    p_line_index		number,
    p_pricing_contexts_Tbl 	QP_Attr_Mapping_PUB.Contexts_Result_Tbl_Type,
    p_qualifier_contexts_Tbl 	QP_Attr_Mapping_PUB.Contexts_Result_Tbl_Type,
    px_Req_line_attr_tbl	in out nocopy  QP_PREQ_GRP.LINE_ATTR_TBL_TYPE,
    px_Req_qual_tbl		in out	nocopy	QP_PREQ_GRP.QUAL_TBL_TYPE)
IS
    l_attr_index	number := nvl(px_Req_line_attr_tbl.last,0);
    l_qual_index	number := nvl(px_Req_qual_tbl.last,0);
BEGIN
    for i in 1..p_pricing_contexts_Tbl.count loop
	l_attr_index := l_attr_index +1;
	AMS_UTILITY_PVT.debug_message(' Copy_attribs_to_req: pricing_context p_line_index = '
                        ||  to_char(p_line_index) ||
			'l_attr_index = ' || to_char(l_attr_index)  );

	px_Req_line_attr_tbl(l_attr_index).VALIDATED_FLAG := 'N';
	px_Req_line_attr_tbl(l_attr_index).line_index := p_line_index;
	-- Product and Pricing Contexts go into pricing contexts...
	px_Req_line_attr_tbl(l_attr_index).PRICING_CONTEXT :=
					p_pricing_contexts_Tbl(i).context_name;
	px_Req_line_attr_tbl(l_attr_index).PRICING_ATTRIBUTE :=
					p_pricing_contexts_Tbl(i).Attribute_Name;
	px_Req_line_attr_tbl(l_attr_index).PRICING_ATTR_VALUE_FROM :=
					p_pricing_contexts_Tbl(i).attribute_value;
    end loop;
    -- Copy the qualifiers
    for i in 1..p_qualifier_contexts_Tbl.count loop
	l_qual_index := l_qual_index +1;
	AMS_UTILITY_PVT.debug_message('  Copy_attribs_to_req: pricing_context = '
                          ||  to_char(p_line_index) ||
	  		'l_qual_index = ' || to_char(l_qual_index)  );

	px_Req_qual_tbl(l_qual_index).VALIDATED_FLAG := 'Y';
	px_Req_qual_tbl(l_qual_index).line_index := p_line_index;
	px_Req_qual_tbl(l_qual_index).QUALIFIER_CONTEXT :=
					p_qualifier_contexts_Tbl(i).context_name;
	px_Req_qual_tbl(l_qual_index).QUALIFIER_ATTRIBUTE :=
					p_qualifier_contexts_Tbl(i).Attribute_Name;
	px_Req_qual_tbl(l_qual_index).QUALIFIER_ATTR_VALUE_FROM :=
					p_qualifier_contexts_Tbl(i).attribute_value;
    end loop;
end copy_attribs_to_Req;

Procedure getReqLineAttrAndQual(
	p_inventory_item_id 	in	number
	,p_uom_code		in	varchar2
	,p_price_list_id	in	number  :=  FND_API.G_MISS_NUM
	,p_party_id		in	number  :=  FND_API.G_MISS_NUM
	,p_cust_account_id 	in	number  :=  FND_API.G_MISS_NUM
	,p_line_index		in 	number
	,p_request_type_code	in 	varchar2
	,px_req_line_attr_tbl	in out   nocopy  QP_PREQ_GRP.LINE_ATTR_TBL_TYPE
	,px_req_qual_tbl  	in out   nocopy QP_PREQ_GRP.qual_TBL_TYPE
)
is
	l_pricing_contexts_Tbl	QP_Attr_Mapping_PUB.Contexts_Result_Tbl_Type;
	l_qual_contexts_Tbl	QP_Attr_Mapping_PUB.Contexts_Result_Tbl_Type;

--	l_Req_qual_tbl	QP_PREQ_GRP.QUAL_TBL_TYPE;
--	l_Req_line_attr_tbl	QP_PREQ_GRP.LINE_ATTR_TBL_TYPE;

begin


/*
	oe_order_pub.G_LINE :=set_oe_line_rec(
			p_inventory_item_id => p_inventory_item_id
			,p_uom_code => p_uom_code
			,p_price_list_id => p_price_list_id
			,p_party_id => p_party_id
			,p_cust_account_id => p_cust_account_id);
*/

	aso_pricing_int.G_LINE_rec :=set_aso_line_rec(
			p_inventory_item_id => p_inventory_item_id
			,p_uom_code => p_uom_code
			,p_price_list_id => p_price_list_id
			,p_party_id => p_party_id
			,p_cust_account_id => p_cust_account_id);


	QP_ATTR_MAPPING_PUB.Build_Contexts (
	P_REQUEST_TYPE_CODE	=> p_request_type_code,
	P_PRICING_TYPE		=> 'L',
	X_PRICE_CONTEXTS_RESULT_TBL	=> l_pricing_contexts_tbl,
	X_QUAL_CONTEXTS_RESULT_TBL	=> l_qual_contexts_tbl);

        IF (AMS_DEBUG_HIGH_ON) THEN



        AMS_UTILITY_PVT.debug_message('getReqLineAttrAndQual last_attr_in='
                       || to_char(nvl(px_req_line_attr_tbl.last,0)));

        END IF;
	IF (AMS_DEBUG_HIGH_ON) THEN

	AMS_UTILITY_PVT.debug_message('getReqLineAttrAndQual  last_qual_in='
                       || to_char(nvl(px_req_qual_tbl.last,0)));
	END IF;

	Copy_attribs_to_req(p_line_index		=> p_line_index,
	p_pricing_contexts_tbl	=> l_pricing_contexts_tbl,
	p_qualifier_contexts_tbl=> l_qual_contexts_tbl,
	px_req_line_attr_tbl	=> px_req_line_attr_tbl,
	px_req_qual_tbl		=> px_req_qual_tbl);

end getREQLineAttrAndQual;


Procedure getHeaderAttrAndQual(
	p_party_id	in	number :=  FND_API.G_MISS_NUM
	,p_cust_account_id	in number :=  FND_API.G_MISS_NUM
	,p_price_list_id	in number :=  FND_API.G_MISS_NUM
	,p_request_type_code	in 	varchar2
	,x_pricing_contexts_tbl out nocopy QP_Attr_Mapping_PUB.Contexts_Result_Tbl_Type
	,x_qual_contexts_tbl	out nocopy QP_Attr_Mapping_PUB.Contexts_Result_Tbl_Type
)
is
--	l_pricing_contexts_Tbl	QP_Attr_Mapping_PUB.Contexts_Result_Tbl_Type;
--	l_qual_contexts_Tbl	QP_Attr_Mapping_PUB.Contexts_Result_Tbl_Type;


begin

/*
	oe_order_pub.g_hdr :=set_oe_Header_rec(
			p_party_id => p_party_id,
			p_cust_account_id => p_cust_account_id,
			p_price_list_id => p_price_list_id );

*/
	aso_pricing_int.g_header_rec := set_aso_Header_rec(
			p_party_id => p_party_id,
			p_cust_account_id => p_cust_account_id,
			p_price_list_id => p_price_list_id );


	QP_ATTR_MAPPING_PUB.Build_Contexts (
	P_REQUEST_TYPE_CODE	=> p_request_type_code,
	P_PRICING_TYPE		=> 'H',
	X_PRICE_CONTEXTS_RESULT_TBL	=> x_pricing_contexts_tbl,
	X_QUAL_CONTEXTS_RESULT_TBL	=> x_qual_contexts_tbl);

end getHeaderAttrAndQual;



--- wendy start only used by testing purpose

Procedure getReqHeaderAttrAndQual(
	p_party_id	in	number :=  FND_API.G_MISS_NUM
	,p_cust_account_id	in number :=  FND_API.G_MISS_NUM
	,p_price_list_id	in number :=  FND_API.G_MISS_NUM
	,p_line_index		in 	number
	,p_request_type_code	in 	varchar2
	,px_req_line_attr_tbl	in out   nocopy  QP_PREQ_GRP.LINE_ATTR_TBL_TYPE
	,px_req_qual_tbl  	in out   nocopy QP_PREQ_GRP.qual_TBL_TYPE
)
is
	l_pricing_contexts_Tbl	QP_Attr_Mapping_PUB.Contexts_Result_Tbl_Type;
	l_qual_contexts_Tbl	QP_Attr_Mapping_PUB.Contexts_Result_Tbl_Type;
--	l_Req_qual_tbl	QP_PREQ_GRP.QUAL_TBL_TYPE;
--	l_Req_line_attr_tbl	QP_PREQ_GRP.LINE_ATTR_TBL_TYPE;

begin
	getHeaderAttrAndQual(
			p_party_id => p_party_id,
			p_cust_account_id => p_cust_account_id,
			p_price_list_id => p_price_list_id,
			p_request_type_code => p_request_type_code,
			x_pricing_contexts_tbl => l_pricing_contexts_tbl,
			x_qual_contexts_tbl => l_qual_contexts_tbl);

	Copy_attribs_to_req(p_line_index	=> p_line_index,
	p_pricing_contexts_tbl	=> l_pricing_contexts_tbl,
	p_qualifier_contexts_tbl=> l_qual_contexts_tbl,
	px_req_line_attr_tbl	=> px_req_line_attr_tbl,
	px_req_qual_tbl		=> px_req_qual_tbl);

end getReqHeaderAttrAndQual;


--- end




PROCEDURE Set_Control_Rec(
	p_pricing_event		in 	varchar2
	,x_control_rec		OUT nocopy   QP_PREQ_GRP.CONTROL_RECORD_TYPE
)
IS
BEGIN
	-- setup control record
--	x_control_rec.pricing_event := 'LINE';
	x_control_rec.pricing_event := p_pricing_event;
	x_control_rec.calculate_flag := 'Y';
	x_control_rec.simulation_flag := 'N';
END Set_Control_Rec;


PROCEDURE Set_Line_Rec(
	p_line_id		IN 	Number
	,p_line_index 		IN 	Number
	,p_uom_code		IN	VARCHAR2
	,p_request_type_code	IN	varchar2
	,px_line_rec		IN OUT	NOCOPY	QP_PREQ_GRP.LINE_REC_TYPE
)
IS
BEGIN

        IF (AMS_DEBUG_HIGH_ON) THEN



        AMS_UTILITY_PVT.debug_message('Set_Line_Rec: uom_code=' || p_uom_code);

        END IF;

	px_line_rec.request_type_code := p_request_type_code;
 	px_line_rec.line_id :=p_line_id;
 	px_line_rec.line_Index :=p_line_index;
 	px_line_rec.line_type_code := 'LINE';
 	px_line_rec.pricing_effective_date := sysdate;
 	px_line_rec.line_quantity := 1;
 	px_line_rec.line_uom_code := p_uom_code;
	px_line_rec.currency_code := 'USD';
 	px_line_rec.price_flag :='Y';
END Set_Line_Rec;

PROCEDURE getReqLine(
    p_uom_code		in 		varchar2
    ,p_currency_code	in		varchar2
    ,p_line_id		in		number
    ,p_line_index		in	number
    ,p_request_type_code	in	varchar2
    ,px_line_tbl	in out	nocopy	QP_PREQ_GRP.Line_TBL_TYPE)
IS
    l_index	number := nvl(px_line_tbl.last,0);
    l_line_rec	QP_PREQ_GRP.Line_REC_TYPE;

BEGIN

	l_line_rec.request_type_code := p_request_type_code;
 	l_line_rec.line_id :=p_line_id;
 	l_line_rec.line_Index :=p_line_index;
 	l_line_rec.line_type_code := 'LINE';
 	l_line_rec.pricing_effective_date := sysdate;
 	l_line_rec.line_quantity := 1;
 	l_line_rec.line_uom_code := p_uom_code;
	l_line_rec.currency_code := p_currency_code;
 	l_line_rec.price_flag :='Y';

--	set_line_rec(p_line_id, p_line_index, p_uom_code, p_request_type_code, l_line_rec);
	l_index := l_index +1;
	px_line_Tbl(l_index) := l_line_rec;

end getReqLine;



PROCEDURE Set_Line_Attr_Rec(
	p_line_index 		IN 		Number
	,p_inventory_item_id	IN		VARCHAR2
	,px_line_attr_rec	IN OUT	NOCOPY	QP_PREQ_GRP.LINE_ATTR_REC_TYPE
)
IS
BEGIN
	-- setup line_attr_rec
	px_line_attr_rec.LINE_INDEX := p_line_index;
 	px_line_attr_rec.PRICING_CONTEXT :='ITEM';
 	px_line_attr_rec.PRICING_ATTRIBUTE :='PRICING_ATTRIBUTE1';
	px_line_attr_rec.PRICING_ATTR_VALUE_FROM  :=p_inventory_item_id;
	px_line_attr_rec.VALIDATED_FLAG :='N';
END Set_Line_Attr_Rec;


PROCEDURE GetReqLineAttr(
	p_line_index 		IN 		Number
	,p_inventory_item_id	IN		VARCHAR2
	,px_line_attr_tbl	IN OUT	NOCOPY	QP_PREQ_GRP.LINE_ATTR_TBL_TYPE
)
is
    l_index	number := nvl(px_line_attr_tbl.last,0);
  l_line_attr_rec           QP_PREQ_GRP.LINE_ATTR_REC_TYPE;
begin
	set_line_attr_rec(p_line_index, p_inventory_item_id, l_line_attr_rec);
	l_index := l_index +1;
	px_line_attr_tbl(l_index) := l_line_attr_rec;
end GetReqLineAttr;


PROCEDURE Set_Qual_Rec(
	p_line_index 		IN 		Number
	,p_price_list_id	IN		VARCHAR2
	,px_qual_rec	IN OUT	NOCOPY	QP_PREQ_GRP.QUAL_REC_TYPE
)
IS
BEGIN
	IF (AMS_DEBUG_HIGH_ON) THEN

	AMS_UTILITY_PVT.debug_message('Set_Qual_Rec price_list_id='
                        || p_price_list_id);
	END IF;
	px_qual_rec.LINE_INDEX := p_line_index;
 	px_qual_rec.QUALIFIER_CONTEXT :='MODLIST';
	px_qual_rec.QUALIFIER_ATTRIBUTE :='QUALIFIER_ATTRIBUTE4';
	px_qual_rec.QUALIFIER_ATTR_VALUE_FROM :=p_price_list_id;
	px_qual_rec.QUALIFIER_ATTR_VALUE_TO :=p_price_list_id;
	px_qual_rec.COMPARISON_OPERATOR_CODE := '=';
	px_qual_rec.VALIDATED_FLAG :='Y';
END Set_Qual_Rec;

PROCEDURE GetReqQual(
	p_line_index 		IN 		Number
	,p_price_list_id	IN		VARCHAR2
	,px_qual_tbl	IN OUT	NOCOPY	QP_PREQ_GRP.QUAL_TBL_TYPE
)
is
    l_index	number := nvl(px_qual_tbl.last,0);
 l_qual_rec           QP_PREQ_GRP.QUAL_REC_TYPE;
begin
	set_qual_rec(p_line_index, p_price_list_id, l_qual_rec);
	l_index := l_index +1;
	px_qual_tbl(l_index) := l_qual_rec;
end GetReqQual;


-- wendy start
PROCEDURE SetRequest(
	p_inventory_item_id	in number
	,p_uom_code		in varchar2
	,p_currency_code	in varchar2
	,p_price_list_id	in number := FND_API.G_MISS_NUM
	,p_party_id		in number := FND_API.G_MISS_NUM
	,p_cust_account_id	in number := FND_API.G_MISS_NUM
	,p_line_id		in number
	,p_line_index		in number
	,p_request_type_code	varchar2
	,p_pricing_contexts_tbl	in QP_Attr_Mapping_PUB.Contexts_Result_Tbl_Type
	,p_qual_contexts_tbl	in QP_Attr_Mapping_PUB.Contexts_Result_Tbl_Type
	,px_line_tbl		in out  nocopy QP_PREQ_GRP.Line_TBL_TYPE
	,px_req_line_attr_tbl	in out   nocopy  QP_PREQ_GRP.LINE_ATTR_TBL_TYPE
	,px_req_qual_tbl  	in out   nocopy QP_PREQ_GRP.qual_TBL_TYPE

)
IS
BEGIN
	-- setup request line
	GetReqLine(p_uom_code, p_currency_code,
		p_line_id, p_line_index, p_request_type_code, px_line_tbl);
	if (g_use_header_qual = 'Y') then
	  IF (AMS_DEBUG_HIGH_ON) THEN

	  AMS_UTILITY_PVT.debug_message('set_request: Using header Qualify');
	  END IF;
	  getReqLineAttrAndQual(
		p_inventory_item_id => p_inventory_item_id,
		p_uom_code => p_uom_code,
		p_line_index => p_line_index,
		p_request_type_code => p_request_type_code,
		px_req_line_attr_tbl => px_req_line_attr_tbl,
		px_req_qual_tbl => px_req_qual_tbl);
	  copy_attribs_to_req(
		p_line_index => p_line_index,
		p_pricing_contexts_tbl => p_pricing_contexts_tbl,
		p_qualifier_contexts_tbl => p_qual_contexts_tbl,
		px_req_line_attr_tbl => px_req_line_attr_tbl,
		px_req_qual_tbl  => px_req_qual_tbl);

	else
	  IF (AMS_DEBUG_HIGH_ON) THEN

	  AMS_UTILITY_PVT.debug_message('set_request: Using Line Qualify');
	  END IF;

	  getReqLineAttrAndQual(
		p_inventory_item_id => p_inventory_item_id,
		p_uom_code => p_uom_code,
		p_price_list_id => p_price_list_id,
		p_party_id => p_party_id,
		p_cust_account_id => p_cust_account_id,
		p_line_index => p_line_index,
		p_request_type_code => p_request_type_code,
		px_req_line_attr_tbl => px_req_line_attr_tbl,
		px_req_qual_tbl => px_req_qual_tbl);
	end if;
END SetRequest;

-- wendy end

-- clears the values in global structures
procedure clear_Global_Structures IS
  BEGIN
	aso_pricing_int.G_LINE_rec := NULL;
	aso_pricing_int.g_header_rec := NULL;
   END clear_Global_Structures;


PROCEDURE GetPricesFromQP(
	   p_price_list_id		IN	NUMBER := FND_API.G_MISS_NUM
	   ,p_party_id			IN	NUMBER := FND_API.G_MISS_NUM
	   ,p_cust_account_id		IN	NUMBER := FND_API.G_MISS_NUM
	   ,p_currency_code		IN 	VARCHAR2
           ,p_item_tbl			IN	JTF_NUMBER_TABLE
           ,p_uom_tbl			IN	JTF_VARCHAR2_TABLE_100
	   ,p_parentIndex_tbl		IN	JTF_NUMBER_TABLE := null
	   ,p_childIndex_tbl		IN	JTF_NUMBER_TABLE := null
--	   ,p_calculate_flag		IN	CHAR(1) :='Y'
	   ,p_request_type_code		IN	VARCHAR2
	   ,p_pricing_event		IN 	VARCHAR2
           ,x_listprice_tbl		OUT	nocopy JTF_NUMBER_TABLE
	   ,x_bestprice_tbl		OUT	nocopy JTF_NUMBER_TABLE
	   ,x_status_code_tbl		OUT	nocopy JTF_VARCHAR2_TABLE_100
	   ,x_status_text_tbl		OUT     nocopy JTF_VARCHAR2_TABLE_300
	   ,x_parentIndex_tbl		OUT     nocopy JTF_NUMBER_TABLE
	   ,x_childIndex_tbl		out     nocopy JTF_NUMBER_TABLE
           ,x_return_status		out 	nocopy	varchar2
           ,x_return_status_text        out 	nocopy	varchar2
)
IS
 l_line_tbl                  QP_PREQ_GRP.LINE_TBL_TYPE;
 l_qual_tbl                  QP_PREQ_GRP.QUAL_TBL_TYPE;
 l_line_attr_tbl             QP_PREQ_GRP.LINE_ATTR_TBL_TYPE;
 l_LINE_DETAIL_tbl           QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE;
 l_LINE_DETAIL_qual_tbl      QP_PREQ_GRP.LINE_DETAIL_QUAL_TBL_TYPE;
 l_LINE_DETAIL_attr_tbl      QP_PREQ_GRP.LINE_DETAIL_ATTR_TBL_TYPE;
 l_related_lines_tbl         QP_PREQ_GRP.RELATED_LINES_TBL_TYPE;
 l_control_rec               QP_PREQ_GRP.CONTROL_RECORD_TYPE;
 x_line_tbl                  QP_PREQ_GRP.LINE_TBL_TYPE;
 x_line_qual                 QP_PREQ_GRP.QUAL_TBL_TYPE;
 x_line_attr_tbl             QP_PREQ_GRP.LINE_ATTR_TBL_TYPE;
 x_line_detail_tbl           QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE;
 x_line_detail_qual_tbl      QP_PREQ_GRP.LINE_DETAIL_QUAL_TBL_TYPE;
 x_line_detail_attr_tbl      QP_PREQ_GRP.LINE_DETAIL_ATTR_TBL_TYPE;
 x_related_lines_tbl         QP_PREQ_GRP.RELATED_LINES_TBL_TYPE;


 l_qual_rec                QP_PREQ_GRP.QUAL_REC_TYPE;
 l_line_attr_rec           QP_PREQ_GRP.LINE_ATTR_REC_TYPE;
 l_line_rec                QP_PREQ_GRP.LINE_REC_TYPE;
 l_rltd_rec                QP_PREQ_GRP.RELATED_LINES_REC_TYPE;

 l_pricing_contexts_Tbl	QP_Attr_Mapping_PUB.Contexts_Result_Tbl_Type;
 l_qual_contexts_Tbl	QP_Attr_Mapping_PUB.Contexts_Result_Tbl_Type;

 I BINARY_INTEGER;
 l_version VARCHAR2(240);

 l_line_index		NUMBER;
 l_line_id		number;


 l_related_inventory_item_id NUMBER;
 l_related_uom_code	VARCHAR2(100);

 l_related_line_index	number;
 l_t1	char(5);
 l_t2   char(5);
BEGIN
	-- setup control record
	set_control_rec(p_pricing_event,l_control_rec);

	-- get header qualify
	if (g_use_header_qual = 'Y') then
		getHeaderAttrAndQual(
			p_party_id => p_party_id,
			p_cust_account_id => p_cust_account_id,
			p_price_list_id => p_price_list_id,
			p_request_type_code => p_request_type_code,
			x_pricing_contexts_tbl => l_pricing_contexts_tbl,
			x_qual_contexts_tbl => l_qual_contexts_tbl);

	end if;

	for I in 1..p_item_tbl.count loop
	l_line_index := I ;
	SetRequest(
		p_inventory_item_id => p_item_tbl(I)
		,p_uom_code => p_uom_tbl(I)
		,p_currency_code => p_currency_code
		,p_price_list_id => p_price_list_id
		,p_party_id	=> p_party_id
 		,p_cust_account_id => p_cust_account_id
		,p_line_id => l_line_index
		,p_line_index => l_line_index
		,p_request_type_code => p_request_type_code
		,p_pricing_contexts_tbl => l_pricing_contexts_tbl
		,p_qual_contexts_tbl => l_qual_contexts_tbl
		,px_line_tbl => l_line_tbl
		,px_req_line_attr_tbl => l_line_attr_tbl
		,px_req_qual_tbl => l_qual_tbl);
	END LOOP;
	--	l_line_index := p_item_tbl.count;

	-- only for service item support
	IF (p_parentIndex_tbl is not null and p_childindex_tbl is not null) then
	    FOR I in 1..p_parentIndex_tbl.count Loop
	        l_rltd_rec.line_index :=  p_parentIndex_tbl(I);
	        IF (AMS_DEBUG_HIGH_ON) THEN

	        AMS_UTILITY_PVT.debug_message('getpricefromqp: Line index='||l_rltd_rec.line_index);
	        END IF;
	        l_rltd_rec.LINE_DETAIL_INDEX := 0;
	        l_rltd_rec.RELATED_LINE_INDEX :=p_childIndex_tbl(I);
	        IF (AMS_DEBUG_HIGH_ON) THEN

	        AMS_UTILITY_PVT.debug_message('getpricefromqp: Line index='||l_rltd_rec.related_line_index);
	        END IF;
	        l_rltd_rec.RELATIONSHIP_TYPE_CODE := QP_PREQ_GRP.G_SERVICE_LINE;
	        l_related_lines_tbl(I) := l_rltd_rec;
            END LOOP;
	END IF;


	get_time(l_t1);
	QP_PREQ_GRP.PRICE_REQUEST(l_line_tbl,
	l_qual_tbl,
        l_line_attr_tbl,
        l_line_detail_tbl,
        l_line_detail_qual_tbl,
        l_line_detail_attr_tbl,
        l_related_lines_tbl,
        l_control_rec,
        x_line_tbl,
        x_line_qual,
        x_line_attr_tbl,
        x_line_detail_tbl,
        x_line_detail_qual_tbl,
        x_line_detail_attr_tbl,
        x_related_lines_tbl,
        x_return_status,
        x_return_status_text);

	get_time(l_t2);
	IF (AMS_DEBUG_HIGH_ON) THEN

	AMS_UTILITY_PVT.debug_message('Call duration of price_request Time(secs) ='|| to_char(l_t2-l_t1));
	END IF;

	-- clear values in global structures that were used
	clear_Global_Structures;

	x_listprice_tbl := JTF_NUMBER_TABLE();
	x_bestprice_tbl := JTF_NUMBER_TABLE();
	x_status_code_tbl := JTF_VARCHAR2_TABLE_100();
	x_status_text_tbl := JTF_VARCHAR2_TABLE_300();

	x_parentIndex_tbl := JTF_NUMBER_TABLE();
	x_childIndex_tbl := JTF_NUMBER_TABLE();

	x_listprice_tbl.extend(l_line_tbl.count);
	x_bestprice_tbl.extend(l_line_tbl.count);
	x_status_code_tbl.extend(l_line_tbl.count);
	x_status_text_tbl.extend(l_line_tbl.count);

	for I in 1..x_line_tbl.count Loop
   	   x_listprice_tbl(I) := x_line_tbl(I).unit_price *
                                 x_line_tbl(I).priced_quantity;
	   x_bestprice_tbl(I) := x_line_tbl(I).adjusted_unit_price *
                                 x_line_tbl(I).priced_quantity;
	   x_status_code_tbl(I) := x_line_tbl(I).status_code;
	   x_status_text_tbl(I) := x_line_tbl(I).status_text;
	END LOOP;

	-- get related information
	x_parentIndex_tbl.extend(x_related_lines_tbl.count);
	x_childIndex_tbl.extend(x_related_lines_tbl.count);

	FOR I IN 1..x_related_lines_tbl.COUNT LOOP
	   x_parentIndex_tbl(I) := x_related_lines_tbl(I).line_index;
	   x_childIndex_tbl(I) := x_related_lines_tbl(I).related_line_index;
	END LOOP;

END GetPricesFromQP;

-- 2.a  [using qp] get price of one item base on price_list_id
PROCEDURE GetPrice(
	   p_price_list_id			IN	NUMBER
	   ,p_currency_code			IN 	VARCHAR2
           ,p_inventory_item_id			IN	NUMBER
           ,p_uom_code				IN	VARCHAR2
--	   ,p_calculate_flag			IN	CHAR(1) :='Y'
	   ,p_request_type_code	        IN	VARCHAR2
	   ,p_pricing_event			IN 	VARCHAR2
           ,x_listprice			 OUT NOCOPY NUMBER
	   ,x_bestprice			 OUT NOCOPY NUMBER
	   ,x_status_code		 OUT NOCOPY varchar2
	   ,x_status_text		 OUT NOCOPY     varchar2
)
IS
	l_item_tbl JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
	l_uom_tbl  JTF_VARCHAR2_TABLE_100 := JTF_VARCHAR2_TABLE_100();
	l_listprice_tbl JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
	l_bestprice_tbl	JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
	l_status_code_tbl JTF_VARCHAR2_TABLE_100 := JTF_VARCHAR2_TABLE_100();
	l_status_text_tbl JTF_VARCHAR2_TABLE_300 := JTF_VARCHAR2_TABLE_300();

	l_parentIndex_tbl   JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
	l_childIndex_tbl  JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();

	x_return_status		VARCHAR2(1);
	x_return_status_text	VARCHAR2(240);

BEGIN
      l_item_tbl.extend();
	l_item_tbl(1) := p_inventory_item_id;
	l_uom_tbl.extend();
	l_uom_tbl(1) := p_uom_code;
	getpricesfromqp(
		p_price_list_id => p_price_list_id,
		p_currency_code => p_currency_code,
		p_item_tbl => l_item_tbl,
		p_uom_tbl => l_uom_tbl,
		p_request_type_code => p_request_type_code,
		p_pricing_event => p_pricing_event,
		x_listprice_tbl => l_listprice_tbl,
		x_bestprice_tbl => l_bestprice_tbl,
		x_status_code_tbl  => l_status_code_tbl,
		x_status_text_tbl => l_status_text_tbl,
		x_parentIndex_tbl => l_parentIndex_tbl,
		x_childIndex_tbl => l_childIndex_tbl,
 		x_return_status		=> x_return_status,
           	x_return_status_text    => x_return_status_text
		);
	x_listprice := l_listprice_tbl(1);
	x_bestprice := l_bestprice_tbl(1);
	x_status_code := l_status_code_tbl(1);
	x_status_text := l_status_text_tbl(1);
END GetPrice;


--2.b  [using qp] get price of one item base on party_id and cust_account_id
PROCEDURE GetPrice(
	   p_party_id			IN	NUMBER
	   ,p_cust_account_id		IN	NUMBER
	   ,p_currency_code		IN 	VARCHAR2
           ,p_inventory_item_id		IN	NUMBER
           ,p_uom_code			IN	VARCHAR2
--	   ,p_calculate_flag		IN	CHAR(1) :='Y'
	   ,p_request_type_code	        IN	VARCHAR2
	   ,p_pricing_event			IN 	VARCHAR2
           ,x_listprice		 OUT NOCOPY NUMBER
	   ,x_bestprice		 OUT NOCOPY NUMBER
	   ,x_status_code	 OUT NOCOPY varchar2
	   ,x_status_text	 OUT NOCOPY     varchar2
)
IS
	l_item_tbl JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
	l_uom_tbl  JTF_VARCHAR2_TABLE_100 := JTF_VARCHAR2_TABLE_100();
	l_listprice_tbl JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
	l_bestprice_tbl	JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
	l_status_code_tbl JTF_VARCHAR2_TABLE_100 := JTF_VARCHAR2_TABLE_100();
	l_status_text_tbl JTF_VARCHAR2_TABLE_300 := JTF_VARCHAR2_TABLE_300();

	l_parentIndex_tbl   JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
	l_childIndex_tbl  JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();


	x_return_status		VARCHAR2(1);
	x_return_status_text	VARCHAR2(240);


BEGIN
	l_item_tbl.extend();
	l_item_tbl(1) := p_inventory_item_id;
	l_uom_tbl.extend();
	l_uom_tbl(1) := p_uom_code;
	getpricesfromqp(
		p_party_id => p_party_id,
		p_cust_account_id => p_cust_account_id,
		p_currency_code => p_currency_code,
		p_item_tbl => l_item_tbl,
		p_uom_tbl => l_uom_tbl,
		p_request_type_code => p_request_type_code,
		p_pricing_event => p_pricing_event,
		x_listprice_tbl => l_listprice_tbl,
		x_bestprice_tbl => l_bestprice_tbl,
		x_status_code_tbl  => l_status_code_tbl,
		x_status_text_tbl => l_status_text_tbl,
		x_parentIndex_tbl => l_parentIndex_tbl,
		x_childIndex_tbl => l_childIndex_tbl,
	 	x_return_status		=> x_return_status,
           	x_return_status_text    => x_return_status_text
		);
	x_listprice := l_listprice_tbl(1);
	x_bestprice := l_bestprice_tbl(1);
	x_status_code := l_status_code_tbl(1);
	x_status_text := l_status_text_tbl(1);
END GetPrice;

--2.b1  [using qp] get price of one item base on price_list_id, party_id,
--      and cust_account_id
PROCEDURE GetPrice(
           p_price_list_id              IN      NUMBER
	   ,p_party_id			IN	NUMBER
	   ,p_cust_account_id		IN	NUMBER
	   ,p_currency_code		IN 	VARCHAR2
           ,p_inventory_item_id		IN	NUMBER
           ,p_uom_code			IN	VARCHAR2
--	   ,p_calculate_flag		IN	CHAR(1) :='Y'
	   ,p_request_type_code	        IN	VARCHAR2
	   ,p_pricing_event			IN 	VARCHAR2
           ,x_listprice		 OUT NOCOPY NUMBER
	   ,x_bestprice		 OUT NOCOPY NUMBER
	   ,x_status_code	 OUT NOCOPY varchar2
	   ,x_status_text	 OUT NOCOPY     varchar2
)
IS
	l_item_tbl JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
	l_uom_tbl  JTF_VARCHAR2_TABLE_100 := JTF_VARCHAR2_TABLE_100();
	l_listprice_tbl JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
	l_bestprice_tbl	JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
	l_status_code_tbl JTF_VARCHAR2_TABLE_100 := JTF_VARCHAR2_TABLE_100();
	l_status_text_tbl JTF_VARCHAR2_TABLE_300 := JTF_VARCHAR2_TABLE_300();

	l_parentIndex_tbl   JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
	l_childIndex_tbl  JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();


	x_return_status		VARCHAR2(1);
	x_return_status_text	VARCHAR2(240);


BEGIN
	l_item_tbl.extend();
	l_item_tbl(1) := p_inventory_item_id;
	l_uom_tbl.extend();
	l_uom_tbl(1) := p_uom_code;
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('price list: ' || p_price_list_id);
      END IF;
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('party: ' || p_party_id);
      END IF;
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('account: ' || p_cust_account_id);
      END IF;

	getpricesfromqp(
                p_price_list_id => p_price_list_id,
		p_party_id => p_party_id,
		p_cust_account_id => p_cust_account_id,
		p_currency_code => p_currency_code,
		p_item_tbl => l_item_tbl,
		p_uom_tbl => l_uom_tbl,
		p_request_type_code => p_request_type_code,
		p_pricing_event => p_pricing_event,
		x_listprice_tbl => l_listprice_tbl,
		x_bestprice_tbl => l_bestprice_tbl,
		x_status_code_tbl  => l_status_code_tbl,
		x_status_text_tbl => l_status_text_tbl,
		x_parentIndex_tbl => l_parentIndex_tbl,
		x_childIndex_tbl => l_childIndex_tbl,
	 	x_return_status		=> x_return_status,
           	x_return_status_text    => x_return_status_text
		);
	x_listprice := l_listprice_tbl(1);
	x_bestprice := l_bestprice_tbl(1);
	x_status_code := l_status_code_tbl(1);
	x_status_text := l_status_text_tbl(1);
END GetPrice;


-- 2.c [using qp] get price of one item base on price_list_id for service support
PROCEDURE GetPrice(
	   p_price_list_id			IN	NUMBER
	   ,p_currency_code			IN 	VARCHAR2
           ,p_inventory_item_id			IN	NUMBER
           ,p_uom_code				IN	VARCHAR2
	   ,p_related_inventory_item_id		IN	NUMBER
	   ,p_related_uom_code			IN	VARCHAR2
--	   ,p_calculate_flag			IN	CHAR(1) :='Y'
	   ,p_request_type_code	        IN	VARCHAR2
	   ,p_pricing_event			IN 	VARCHAR2
           ,x_listprice			 OUT NOCOPY NUMBER
	   ,x_bestprice			 OUT NOCOPY NUMBER
	   ,x_status_code		 OUT NOCOPY varchar2
	   ,x_status_text		 OUT NOCOPY     varchar2
           ,x_related_listprice		 OUT NOCOPY NUMBER
	   ,x_related_bestprice		 OUT NOCOPY NUMBER
	   ,x_related_status_code	 OUT NOCOPY varchar2
	   ,x_related_status_text	 OUT NOCOPY     varchar2
)
IS
	l_item_tbl JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
	l_uom_tbl  JTF_VARCHAR2_TABLE_100 := JTF_VARCHAR2_TABLE_100();
	l_listprice_tbl JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
	l_bestprice_tbl	JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
	l_status_code_tbl JTF_VARCHAR2_TABLE_100 := JTF_VARCHAR2_TABLE_100();
	l_status_text_tbl JTF_VARCHAR2_TABLE_300 := JTF_VARCHAR2_TABLE_300();

	l_parentIndex_tbl  JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
	l_childIndex_tbl  JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();

	lx_parentIndex_tbl  JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
	lx_childIndex_tbl  JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();

	x_return_status		VARCHAR2(1);
	x_return_status_text	VARCHAR2(240);

BEGIN
	l_item_tbl.extend();
	l_uom_tbl.extend();
	l_item_tbl(1) := p_inventory_item_id;
	l_uom_tbl(1) := p_uom_code;


	l_item_tbl.extend();
	l_uom_tbl.extend();
	l_item_tbl(2) := p_related_inventory_item_id;
	l_uom_tbl(2) := p_related_uom_code;

	l_parentIndex_tbl.extend();
	l_childIndex_tbl.extend();

	l_parentIndex_tbl(1) := 1;
	l_childIndex_tbl(1) := 2;

	getpricesfromqp(
		p_price_list_id => p_price_list_id,
		p_currency_code => p_currency_code,
		p_item_tbl => l_item_tbl,
		p_uom_tbl => l_uom_tbl,
		p_parentIndex_tbl => l_parentIndex_tbl,
		p_childIndex_tbl => l_childIndex_tbl,
		p_request_type_code => p_request_type_code,
		p_pricing_event => p_pricing_event,
		x_listprice_tbl => l_listprice_tbl,
		x_bestprice_tbl => l_bestprice_tbl,
		x_status_code_tbl  => l_status_code_tbl,
		x_status_text_tbl => l_status_text_tbl,
		x_parentIndex_tbl => lx_parentIndex_tbl,
		x_childIndex_tbl => lx_childIndex_tbl,
		x_return_status		=> x_return_status,
           	x_return_status_text    => x_return_status_text
		);

	x_listprice := l_listprice_tbl(1);
	x_bestprice := l_bestprice_tbl(1);
	x_status_code := l_status_code_tbl(1);
	x_status_text := l_status_text_tbl(1);

	x_related_listprice := l_listprice_tbl(2);
	x_related_bestprice := l_bestprice_tbl(2);
	x_related_status_code := l_status_code_tbl(2);
	x_related_status_text := l_status_text_tbl(2);

END GetPrice;



-- 2.d [using qp] get price of one item base customer info for service support
PROCEDURE GetPrice(
	   p_party_id			IN	NUMBER
	   ,p_cust_account_id		IN	NUMBER
	   ,p_currency_code			IN 	VARCHAR2
           ,p_inventory_item_id			IN	NUMBER
           ,p_uom_code				IN	VARCHAR2
	   ,p_related_inventory_item_id		IN	NUMBER
	   ,p_related_uom_code			IN	VARCHAR2
--	   ,p_calculate_flag			IN	CHAR(1) :='Y'
	   ,p_request_type_code	        IN	VARCHAR2
	   ,p_pricing_event			IN 	VARCHAR2
           ,x_listprice			 OUT NOCOPY NUMBER
	   ,x_bestprice			 OUT NOCOPY NUMBER
	   ,x_status_code		 OUT NOCOPY varchar2
	   ,x_status_text		 OUT NOCOPY     varchar2
           ,x_related_listprice		 OUT NOCOPY NUMBER
	   ,x_related_bestprice		 OUT NOCOPY NUMBER
	   ,x_related_status_code	 OUT NOCOPY varchar2
	   ,x_related_status_text	 OUT NOCOPY     varchar2
)
IS
	l_item_tbl JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
	l_uom_tbl  JTF_VARCHAR2_TABLE_100 := JTF_VARCHAR2_TABLE_100();
	l_listprice_tbl JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
	l_bestprice_tbl	JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
	l_status_code_tbl JTF_VARCHAR2_TABLE_100 := JTF_VARCHAR2_TABLE_100();
	l_status_text_tbl JTF_VARCHAR2_TABLE_300 := JTF_VARCHAR2_TABLE_300();

	l_parentIndex_tbl  JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
	l_childIndex_tbl  JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();

	lx_parentIndex_tbl  JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
	lx_childIndex_tbl  JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();


	x_return_status		VARCHAR2(1);
	x_return_status_text	VARCHAR2(240);

BEGIN
	l_item_tbl.extend();
	l_uom_tbl.extend();
	l_item_tbl(1) := p_inventory_item_id;
	l_uom_tbl(1) := p_uom_code;

	l_item_tbl.extend();
	l_uom_tbl.extend();
	l_item_tbl(2) := p_related_inventory_item_id;
	l_uom_tbl(2) := p_related_uom_code;

	l_parentIndex_tbl.extend();
	l_childIndex_tbl.extend();

	l_parentIndex_tbl(1) := 1;
	l_childIndex_tbl(1) := 2;


	getpricesfromqp(
		p_party_id => p_party_id,
		p_cust_account_id => p_cust_account_id,
		p_currency_code => p_currency_code,
		p_item_tbl => l_item_tbl,
		p_uom_tbl => l_uom_tbl,
		p_parentIndex_tbl => l_parentIndex_tbl,
		p_childIndex_tbl => l_childIndex_tbl,
		p_request_type_code => p_request_type_code,
		p_pricing_event => p_pricing_event,
		x_listprice_tbl => l_listprice_tbl,
		x_bestprice_tbl => l_bestprice_tbl,
		x_status_code_tbl  => l_status_code_tbl,
		x_status_text_tbl => l_status_text_tbl,
		x_parentIndex_tbl => lx_parentIndex_tbl,
		x_childIndex_tbl => lx_childIndex_tbl,
	 	x_return_status		=> x_return_status,
           	x_return_status_text    => x_return_status_text
		);
	x_listprice := l_listprice_tbl(1);
	x_bestprice := l_bestprice_tbl(1);
	x_status_code := l_status_code_tbl(1);
	x_status_text := l_status_text_tbl(1);


	x_related_listprice := l_listprice_tbl(2);
	x_related_bestprice := l_bestprice_tbl(2);
	x_related_status_code := l_status_code_tbl(2);
	x_related_status_text := l_status_text_tbl(2);


END GetPrice;


-- 2.d1 [using qp] get price of one item based on price_list_id and
--      customer info for service support
PROCEDURE GetPrice(
           p_price_list_id              IN      NUMBER
	   ,p_party_id			IN	NUMBER
	   ,p_cust_account_id		IN	NUMBER
	   ,p_currency_code			IN 	VARCHAR2
           ,p_inventory_item_id			IN	NUMBER
           ,p_uom_code				IN	VARCHAR2
	   ,p_related_inventory_item_id		IN	NUMBER
	   ,p_related_uom_code			IN	VARCHAR2
--	   ,p_calculate_flag			IN	CHAR(1) :='Y'
	   ,p_request_type_code	        IN	VARCHAR2
	   ,p_pricing_event			IN 	VARCHAR2
           ,x_listprice			 OUT NOCOPY NUMBER
	   ,x_bestprice			 OUT NOCOPY NUMBER
	   ,x_status_code		 OUT NOCOPY varchar2
	   ,x_status_text		 OUT NOCOPY     varchar2
           ,x_related_listprice		 OUT NOCOPY NUMBER
	   ,x_related_bestprice		 OUT NOCOPY NUMBER
	   ,x_related_status_code	 OUT NOCOPY varchar2
	   ,x_related_status_text	 OUT NOCOPY     varchar2
)
IS
	l_item_tbl JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
	l_uom_tbl  JTF_VARCHAR2_TABLE_100 := JTF_VARCHAR2_TABLE_100();
	l_listprice_tbl JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
	l_bestprice_tbl	JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
	l_status_code_tbl JTF_VARCHAR2_TABLE_100 := JTF_VARCHAR2_TABLE_100();
	l_status_text_tbl JTF_VARCHAR2_TABLE_300 := JTF_VARCHAR2_TABLE_300();

	l_parentIndex_tbl  JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
	l_childIndex_tbl  JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();

	lx_parentIndex_tbl  JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
	lx_childIndex_tbl  JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();


	x_return_status		VARCHAR2(1);
	x_return_status_text	VARCHAR2(240);

BEGIN
	l_item_tbl.extend();
	l_uom_tbl.extend();
	l_item_tbl(1) := p_inventory_item_id;
	l_uom_tbl(1) := p_uom_code;

	l_item_tbl.extend();
	l_uom_tbl.extend();
	l_item_tbl(2) := p_related_inventory_item_id;
	l_uom_tbl(2) := p_related_uom_code;

	l_parentIndex_tbl.extend();
	l_childIndex_tbl.extend();

	l_parentIndex_tbl(1) := 1;
	l_childIndex_tbl(1) := 2;


	getpricesfromqp(
                p_price_list_id => p_price_list_id,
		p_party_id => p_party_id,
		p_cust_account_id => p_cust_account_id,
		p_currency_code => p_currency_code,
		p_item_tbl => l_item_tbl,
		p_uom_tbl => l_uom_tbl,
		p_parentIndex_tbl => l_parentIndex_tbl,
		p_childIndex_tbl => l_childIndex_tbl,
		p_request_type_code => p_request_type_code,
		p_pricing_event => p_pricing_event,
		x_listprice_tbl => l_listprice_tbl,
		x_bestprice_tbl => l_bestprice_tbl,
		x_status_code_tbl  => l_status_code_tbl,
		x_status_text_tbl => l_status_text_tbl,
		x_parentIndex_tbl => lx_parentIndex_tbl,
		x_childIndex_tbl => lx_childIndex_tbl,
	 	x_return_status		=> x_return_status,
           	x_return_status_text    => x_return_status_text
		);
	x_listprice := l_listprice_tbl(1);
	x_bestprice := l_bestprice_tbl(1);
	x_status_code := l_status_code_tbl(1);
	x_status_text := l_status_text_tbl(1);


	x_related_listprice := l_listprice_tbl(2);
	x_related_bestprice := l_bestprice_tbl(2);
	x_related_status_code := l_status_code_tbl(2);
	x_related_status_text := l_status_text_tbl(2);
END GetPrice;


-- 2.e [using qp] get prices for a list of items based on price_list_id
PROCEDURE GetPrices(
	   p_price_list_id		IN	NUMBER
	   ,p_currency_code		IN 	VARCHAR2
           ,p_item_tbl			IN	JTF_NUMBER_TABLE
           ,p_uom_tbl			IN	JTF_VARCHAR2_TABLE_100
--	   ,p_calculate_flag		IN	CHAR(1) :='Y'
	   ,p_request_type_code		IN	VARCHAR2
	   ,p_pricing_event		IN 	VARCHAR2
           ,x_listprice_tbl		OUT	nocopy JTF_NUMBER_TABLE
	   ,x_bestprice_tbl		OUT	nocopy JTF_NUMBER_TABLE
	   ,x_status_code_tbl		OUT	nocopy JTF_VARCHAR2_TABLE_100
	   ,x_status_text_tbl		OUT     nocopy JTF_VARCHAR2_TABLE_300
           ,x_return_status		out 	nocopy	varchar2
           ,x_return_status_text        out 	nocopy	varchar2

)
IS
	l_version VARCHAR2(240);

	l_parentIndex_tbl   JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
	l_childIndex_tbl  JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();

BEGIN
	getpricesfromqp(
		p_price_list_id => p_price_list_id,
		p_currency_code => p_currency_code,
		p_item_tbl => p_item_tbl,
		p_uom_tbl => p_uom_tbl,
		p_request_type_code => p_request_type_code,
		p_pricing_event => p_pricing_event,
		x_listprice_tbl	=> x_listprice_tbl,
		x_bestprice_tbl => x_bestprice_tbl,
		x_status_code_tbl => x_status_code_tbl,
		x_status_text_tbl => x_status_text_tbl,
		x_parentIndex_tbl => l_parentIndex_tbl,
		x_childIndex_tbl => l_childIndex_tbl,
	 	x_return_status		=> x_return_status,
           	x_return_status_text    => x_return_status_text
		);
END GetPrices;

-- 2.f [using qp] get prices of a list of items based on party_id and cust_accoutn_id
PROCEDURE GetPrices(
	   p_party_id			IN	NUMBER
	   ,p_cust_account_id		IN	number
	   ,p_currency_code		IN 	VARCHAR2
           ,p_item_tbl			IN	JTF_NUMBER_TABLE
           ,p_uom_tbl			IN	JTF_VARCHAR2_TABLE_100
--	   ,p_calculate_flag		IN	CHAR(1) :='Y'
	   ,p_request_type_code		IN	VARCHAR2
	   ,p_pricing_event		IN 	VARCHAR2
           ,x_listprice_tbl		OUT	nocopy JTF_NUMBER_TABLE
	   ,x_bestprice_tbl		OUT	nocopy JTF_NUMBER_TABLE
	   ,x_status_code_tbl		OUT	nocopy JTF_VARCHAR2_TABLE_100
	   ,x_status_text_tbl		OUT     nocopy JTF_VARCHAR2_TABLE_300
           ,x_return_status		out 	nocopy	varchar2
           ,x_return_status_text        out 	nocopy	varchar2

)
IS
	l_parentIndex_tbl   JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
	l_childIndex_tbl  JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();

BEGIN
	getpricesfromqp(
		p_party_id => p_party_id,
		p_cust_account_id => p_cust_account_id,
		p_currency_code => p_currency_code,
		p_item_tbl => p_item_tbl,
		p_uom_tbl => p_uom_tbl,
		p_request_type_code => p_request_type_code,
		p_pricing_event => p_pricing_event,
		x_listprice_tbl	=> x_listprice_tbl,
		x_bestprice_tbl => x_bestprice_tbl,
		x_status_code_tbl => x_status_code_tbl,
		x_status_text_tbl => x_status_text_tbl,
		x_parentIndex_tbl => l_parentIndex_tbl,
		x_childIndex_tbl => l_childIndex_tbl,
	 	x_return_status		=> x_return_status,
           	x_return_status_text    => x_return_status_text

                 );
END GetPrices;

-- 2.f1 [using qp] get prices of a list of items based on price_list_id, party_id,
--      and cust_account_id
PROCEDURE GetPrices(
           p_price_list_id              IN      NUMBER
	   ,p_party_id			IN	NUMBER
	   ,p_cust_account_id		IN	number
	   ,p_currency_code		IN 	VARCHAR2
           ,p_item_tbl			IN	JTF_NUMBER_TABLE
           ,p_uom_tbl			IN	JTF_VARCHAR2_TABLE_100
--	   ,p_calculate_flag		IN	CHAR(1) :='Y'
	   ,p_request_type_code		IN	VARCHAR2
	   ,p_pricing_event		IN 	VARCHAR2
           ,x_listprice_tbl		OUT	nocopy JTF_NUMBER_TABLE
	   ,x_bestprice_tbl		OUT	nocopy JTF_NUMBER_TABLE
	   ,x_status_code_tbl		OUT	nocopy JTF_VARCHAR2_TABLE_100
	   ,x_status_text_tbl		OUT     nocopy JTF_VARCHAR2_TABLE_300
           ,x_return_status		out 	nocopy	varchar2
           ,x_return_status_text        out 	nocopy	varchar2

)
IS
	l_parentIndex_tbl   JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
	l_childIndex_tbl  JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();

BEGIN
	getpricesfromqp(
                p_price_list_id => p_price_list_id,
		p_party_id => p_party_id,
		p_cust_account_id => p_cust_account_id,
		p_currency_code => p_currency_code,
		p_item_tbl => p_item_tbl,
		p_uom_tbl => p_uom_tbl,
		p_request_type_code => p_request_type_code,
		p_pricing_event => p_pricing_event,
		x_listprice_tbl	=> x_listprice_tbl,
		x_bestprice_tbl => x_bestprice_tbl,
		x_status_code_tbl => x_status_code_tbl,
		x_status_text_tbl => x_status_text_tbl,
		x_parentIndex_tbl => l_parentIndex_tbl,
		x_childIndex_tbl => l_childIndex_tbl,
	 	x_return_status		=> x_return_status,
           	x_return_status_text    => x_return_status_text

                );
END GetPrices;


-- 2.g [using qp] get prices of a list of items based on price_list_id for service support
PROCEDURE GetPrices(
	   p_price_list_id		IN	NUMBER
	   ,p_currency_code		IN 	VARCHAR2
           ,p_item_tbl			IN	JTF_NUMBER_TABLE
           ,p_uom_tbl			IN	JTF_VARCHAR2_TABLE_100
	   ,p_parentIndex_tbl		IN	JTF_NUMBER_TABLE
	   ,p_childIndex_tbl		IN	JTF_NUMBER_TABLE
--	   ,p_calculate_flag		IN	CHAR(1) :='Y'
	   ,p_request_type_code		IN	VARCHAR2
	   ,p_pricing_event		IN 	VARCHAR2
           ,x_listprice_tbl		OUT	nocopy JTF_NUMBER_TABLE
	   ,x_bestprice_tbl		OUT	nocopy JTF_NUMBER_TABLE
	   ,x_status_code_tbl		OUT	nocopy JTF_VARCHAR2_TABLE_100
	   ,x_status_text_tbl		OUT     nocopy JTF_VARCHAR2_TABLE_300
	   ,x_parentIndex_tbl		out	nocopy JTF_NUMBER_TABLE
	   ,x_childIndex_tbl		out	nocopy JTF_NUMBER_TABLE
           ,x_return_status		out 	nocopy	varchar2
           ,x_return_status_text        out 	nocopy	varchar2
)
IS

BEGIN
	getpricesfromqp(
		p_price_list_id => p_price_list_id,
		p_currency_code => p_currency_code,
		p_item_tbl => p_item_tbl,
		p_uom_tbl => p_uom_tbl,
		p_parentIndex_tbl => p_parentIndex_tbl,
		p_childIndex_tbl => p_childIndex_tbl,
		p_request_type_code => p_request_type_code,
		p_pricing_event => p_pricing_event,
		x_listprice_tbl	=> x_listprice_tbl,
		x_bestprice_tbl => x_bestprice_tbl,
		x_status_code_tbl => x_status_code_tbl,
		x_status_text_tbl => x_status_text_tbl,
		x_parentIndex_tbl => x_parentIndex_tbl,
		x_childIndex_tbl => x_childIndex_tbl,
	 	x_return_status	=> x_return_status,
           	x_return_status_text    => x_return_status_text

                 );
END GetPrices;



-- 2.h [using qp] get prices of a list of items based on party_id and cust_accoutn_id
PROCEDURE GetPrices(
	   p_party_id			IN	NUMBER
	   ,p_cust_account_id		IN	number
	   ,p_currency_code		IN 	VARCHAR2
           ,p_item_tbl			IN	JTF_NUMBER_TABLE
           ,p_uom_tbl			IN	JTF_VARCHAR2_TABLE_100
	   ,p_parentIndex_tbl		IN	JTF_NUMBER_TABLE
	   ,p_childIndex_tbl		IN	JTF_NUMBER_TABLE
--	   ,p_calculate_flag		IN	CHAR(1) :='Y'
	   ,p_request_type_code		IN	VARCHAR2
	   ,p_pricing_event		IN 	VARCHAR2
           ,x_listprice_tbl		OUT	nocopy JTF_NUMBER_TABLE
	   ,x_bestprice_tbl		OUT	nocopy JTF_NUMBER_TABLE
	   ,x_status_code_tbl		OUT	nocopy JTF_VARCHAR2_TABLE_100
	   ,x_status_text_tbl		OUT     nocopy JTF_VARCHAR2_TABLE_300
	   ,x_parentIndex_tbl	 OUT NOCOPY JTF_NUMBER_TABLE
	   ,x_childIndex_tbl	 OUT NOCOPY JTF_NUMBER_TABLE
           ,x_return_status		out 	nocopy	varchar2
           ,x_return_status_text        out 	nocopy	varchar2

)
IS

BEGIN
	getpricesfromqp(
		p_party_id => p_party_id,
		p_cust_account_id => p_cust_account_id,
		p_currency_code => p_currency_code,
		p_item_tbl => p_item_tbl,
		p_uom_tbl => p_uom_tbl,
		p_parentIndex_tbl => p_parentIndex_tbl,
		p_childIndex_tbl => p_childIndex_tbl,
		p_request_type_code => p_request_type_code,
		p_pricing_event => p_pricing_event,
		x_listprice_tbl	=> x_listprice_tbl,
		x_bestprice_tbl => x_bestprice_tbl,
		x_status_code_tbl => x_status_code_tbl,
		x_status_text_tbl => x_status_text_tbl,
		x_parentIndex_tbl => x_parentIndex_tbl,
		x_childIndex_tbl => x_childIndex_tbl,
	 	x_return_status		=> x_return_status,
           	x_return_status_text    => x_return_status_text

		);
END GetPrices;

-- 2.h1 [using qp] get prices of a list of items based on price_list_id,
--      party_id and cust_account_id
PROCEDURE GetPrices(
           p_price_list_id              IN      NUMBER
	   ,p_party_id			IN	NUMBER
	   ,p_cust_account_id		IN	number
	   ,p_currency_code		IN 	VARCHAR2
           ,p_item_tbl			IN	JTF_NUMBER_TABLE
           ,p_uom_tbl			IN	JTF_VARCHAR2_TABLE_100
	   ,p_parentIndex_tbl		IN	JTF_NUMBER_TABLE
	   ,p_childIndex_tbl		IN	JTF_NUMBER_TABLE
--	   ,p_calculate_flag		IN	CHAR(1) :='Y'
	   ,p_request_type_code		IN	VARCHAR2
	   ,p_pricing_event		IN 	VARCHAR2
           ,x_listprice_tbl		OUT	nocopy JTF_NUMBER_TABLE
	   ,x_bestprice_tbl		OUT	nocopy JTF_NUMBER_TABLE
	   ,x_status_code_tbl		OUT	nocopy JTF_VARCHAR2_TABLE_100
	   ,x_status_text_tbl		OUT     nocopy JTF_VARCHAR2_TABLE_300
	   ,x_parentIndex_tbl	 OUT NOCOPY JTF_NUMBER_TABLE
	   ,x_childIndex_tbl	 OUT NOCOPY JTF_NUMBER_TABLE
           ,x_return_status		out 	nocopy	varchar2
           ,x_return_status_text        out 	nocopy	varchar2

)
IS

BEGIN
	getpricesfromqp(
                p_price_list_id => p_price_list_id,
		p_party_id => p_party_id,
		p_cust_account_id => p_cust_account_id,
		p_currency_code => p_currency_code,
		p_item_tbl => p_item_tbl,
		p_uom_tbl => p_uom_tbl,
		p_parentIndex_tbl => p_parentIndex_tbl,
		p_childIndex_tbl => p_childIndex_tbl,
		p_request_type_code => p_request_type_code,
		p_pricing_event => p_pricing_event,
		x_listprice_tbl	=> x_listprice_tbl,
		x_bestprice_tbl => x_bestprice_tbl,
		x_status_code_tbl => x_status_code_tbl,
		x_status_text_tbl => x_status_text_tbl,
		x_parentIndex_tbl => x_parentIndex_tbl,
		x_childIndex_tbl => x_childIndex_tbl,
	 	x_return_status		=> x_return_status,
           	x_return_status_text    => x_return_status_text

		);
END GetPrices;


END AMS_PRICE_PVT;

/
