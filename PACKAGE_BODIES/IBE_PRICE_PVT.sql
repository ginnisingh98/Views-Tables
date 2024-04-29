--------------------------------------------------------
--  DDL for Package Body IBE_PRICE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_PRICE_PVT" as
/* $Header: IBEVPRCB.pls 120.5 2006/07/17 07:03:01 apgupta ship $ */

g_use_header_qual	CONSTANT varchar2(1) := 'Y';

PROCEDURE GET_TIME(t out NOCOPY number)
IS
BEGIN
 t := to_char(sysdate, 'ssss');
 t := t*10;
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

	--gzhang 12/03/01 model bundle
	,p_model_id		number --:= FND_API.G_MISS_NUM

) return aso_pricing_int.PRICING_line_REC_TYPE
is
	l_pricing_line_rec	 aso_pricing_int.PRICING_line_REC_TYPE;
begin
	l_pricing_line_rec.inventory_item_id := p_inventory_item_id;
	l_pricing_line_rec.uom_code:= p_uom_code;
	l_pricing_line_rec.quantity:= 1;
	l_pricing_line_rec.price_list_id := p_price_list_id;

	--gzhang 12/03/01 model bundle
	l_pricing_line_rec.model_id := p_model_id;

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
    l_attr_index	number ;
    l_qual_index	number ;
BEGIN
    l_attr_index := nvl(px_Req_line_attr_tbl.last,0);
    l_qual_index := nvl(px_Req_qual_tbl.last,0);

    for i in 1..p_pricing_contexts_Tbl.count loop
	l_attr_index := l_attr_index +1;
	IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
	ibe_util.debug(' Copy_attribs_to_req: pricing_context p_line_index = '
                        ||  to_char(p_line_index) ||
			'l_attr_index = ' || to_char(l_attr_index)  );
	END IF;

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
	IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
	ibe_util.debug('  Copy_attribs_to_req: pricing_context = '
                          ||  to_char(p_line_index) ||
	  		'l_qual_index = ' || to_char(l_qual_index)  );
	END IF;

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

	--gzhang 12/03/01 model bundle
	,p_model_id 	in	number  --:=  FND_API.G_MISS_NUM

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

	aso_pricing_int.G_LINE_rec :=set_aso_line_rec(
			p_inventory_item_id => p_inventory_item_id
			,p_uom_code => p_uom_code
			,p_price_list_id => p_price_list_id
			,p_party_id => p_party_id
			,p_cust_account_id => p_cust_account_id

			--gzhang 12/03/01 model bundle
			,p_model_id => p_model_id);


	QP_ATTR_MAPPING_PUB.Build_Contexts (
	P_REQUEST_TYPE_CODE	=> p_request_type_code,
	P_PRICING_TYPE		=> 'L',
	X_PRICE_CONTEXTS_RESULT_TBL	=> l_pricing_contexts_tbl,
	X_QUAL_CONTEXTS_RESULT_TBL	=> l_qual_contexts_tbl);

        IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
        ibe_util.debug('getReqLineAttrAndQual last_attr_in='
                       || to_char(nvl(px_req_line_attr_tbl.last,0)));
	ibe_util.debug('getReqLineAttrAndQual  last_qual_in='
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

	--gzhang 12/03/01 model bundle
	--,p_model_id	in number :=  FND_API.G_MISS_NUM

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
			p_price_list_id => p_price_list_id);


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

	--gzhang 12/03/01 model bundle
	--,p_model_id	in number :=  FND_API.G_MISS_NUM

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

			--gzhang 12/03/01 model bundle
			--p_model_id => p_model_id,

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
	IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
        ibe_util.debug('Set_Line_Rec: uom_code=' || p_uom_code);
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
    l_index	number;
    l_line_rec	QP_PREQ_GRP.Line_REC_TYPE;

BEGIN
	l_index	:= nvl(px_line_tbl.last,0);

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
    l_index	number;
  l_line_attr_rec           QP_PREQ_GRP.LINE_ATTR_REC_TYPE;
begin
	l_index := nvl(px_line_attr_tbl.last,0);
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
	IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
	ibe_util.debug('Set_Qual_Rec price_list_id='
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
    l_index	number;
 l_qual_rec           QP_PREQ_GRP.QUAL_REC_TYPE;
begin
	l_index := nvl(px_qual_tbl.last,0);
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

	--gzhang 12/03/01 model bundle
	,p_model_id		in number --:= FND_API.G_MISS_NUM

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
	  IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
	  ibe_util.debug('set_request: Using header Qualify');
	  END IF;

	  getReqLineAttrAndQual(
		p_inventory_item_id => p_inventory_item_id,
		p_uom_code => p_uom_code,

		--gzhang 12/06/01 model bundle
		p_model_id => p_model_id,

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
	  IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
	  ibe_util.debug('set_request: Using Line Qualify');
	  END IF;

	  getReqLineAttrAndQual(
		p_inventory_item_id => p_inventory_item_id,
		p_uom_code => p_uom_code,
		p_price_list_id => p_price_list_id,
		p_party_id => p_party_id,
		p_cust_account_id => p_cust_account_id,

		--gzhang 12/03/01 model bundle
		p_model_id => p_model_id,

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
        oe_order_pub.g_hdr := NULL;
        oe_order_pub.g_line := NULL;
   END clear_Global_Structures;


PROCEDURE GetPricesFromQP(
	   p_price_list_id		IN	NUMBER := FND_API.G_MISS_NUM
	   ,p_party_id			IN	NUMBER := FND_API.G_MISS_NUM
	   ,p_cust_account_id		IN	NUMBER := FND_API.G_MISS_NUM

	   --gzhang 12/03/01 model bundle support
	   ,p_model_id			IN	NUMBER --:= FND_API.G_MISS_NUM

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
 l_t0	char(5);
 l_t1	char(5);
 l_t2   char(5);
 l_t3   char(5);
BEGIN

	-- clear ASO and OE global pricing structures
	get_time(l_t0);
	clear_Global_Structures;

	-- setup control record
	set_control_rec(p_pricing_event,l_control_rec);

	-- get header qualify
	if (g_use_header_qual = 'Y') then
		getHeaderAttrAndQual(
			p_party_id => p_party_id,
			p_cust_account_id => p_cust_account_id,
			p_price_list_id => p_price_list_id,

			--gzhang 12/03/01, model bundle
			--p_model_id => p_model_id,

			p_request_type_code => p_request_type_code,
			x_pricing_contexts_tbl => l_pricing_contexts_tbl,
			x_qual_contexts_tbl => l_qual_contexts_tbl);

	end if;


	for I in 1..p_item_tbl.count loop
	l_line_index := I ;
	SetRequest(
		p_inventory_item_id => p_item_tbl(I)
		,p_uom_code => p_uom_tbl(I)
		--gzhang 12/03/01, model bundle
		,p_model_id => p_model_id
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

	        IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
	        ibe_util.debug('getpricefromqp: Line index='||l_rltd_rec.line_index);
	        END IF;

	        l_rltd_rec.LINE_DETAIL_INDEX := 0;
	        l_rltd_rec.RELATED_LINE_INDEX :=p_childIndex_tbl(I);

	        IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
	        ibe_util.debug('getpricefromqp: Line index='||l_rltd_rec.related_line_index);
	        END IF;

	        l_rltd_rec.RELATIONSHIP_TYPE_CODE := QP_PREQ_GRP.G_SERVICE_LINE;
	        l_related_lines_tbl(I) := l_rltd_rec;
            END LOOP;
	END IF;


	IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
	ibe_util.debug('total lines ='|| l_line_tbl.count);
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
	IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
	ibe_util.debug('Call duration of price_request Time(secs) ='|| to_char(l_t2-l_t1));
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

           if(lengthb(x_line_tbl(I).status_text)>300) then
             IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
             ibe_util.debug('status_text has more than 300 bytes and has been truncated to 300 bytes:' || x_line_tbl(I).status_text);
             END IF;

	     x_status_text_tbl(I) := substrb(x_line_tbl(I).status_text, 1, 300);
           else
             x_status_text_tbl(I) := x_line_tbl(I).status_text;
           end if;

	END LOOP;

	-- get related information
	x_parentIndex_tbl.extend(x_related_lines_tbl.count);
	x_childIndex_tbl.extend(x_related_lines_tbl.count);

	FOR I IN 1..x_related_lines_tbl.COUNT LOOP
	   x_parentIndex_tbl(I) := x_related_lines_tbl(I).line_index;
	   x_childIndex_tbl(I) := x_related_lines_tbl(I).related_line_index;
	END LOOP;
	get_time(l_t2);

	IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
	ibe_util.debug('Duration of populating Line Items Time(ms) ='|| to_char(l_t1-l_t0));
	ibe_util.debug('Duration of Price Request Time(ms) ='|| to_char(l_t2-l_t1));
	ibe_util.debug('Duration of Price Request Time(ms) ='|| to_char(l_t3-l_t2));
	END IF;

END GetPricesFromQP;


--gzhang 12/01/04 model bundle
-- new API
PROCEDURE CalculatePrices(
	   p_price_list_id		IN	NUMBER := FND_API.G_MISS_NUM
	   ,p_party_id			IN	NUMBER := FND_API.G_MISS_NUM
	   ,p_cust_account_id		IN	NUMBER := FND_API.G_MISS_NUM
	   ,p_model_id			IN	NUMBER --:= FND_API.G_MISS_NUM

	   ,p_organization_id		IN	NUMBER
	   ,p_currency_code		IN 	VARCHAR2
           ,p_item_tbl			IN	JTF_NUMBER_TABLE
           ,p_uom_tbl			IN	JTF_VARCHAR2_TABLE_100
	   ,p_parentIndex_tbl		IN	JTF_NUMBER_TABLE := null
	   ,p_childIndex_tbl		IN	JTF_NUMBER_TABLE := null

	   --gzhang 01/21/01, model bundle cache
	   ,p_model_bundle_flag_tbl	IN	JTF_VARCHAR2_TABLE_100 := NULL

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

	L_API			VARCHAR2(64);
	l_itm_id			NUMBER;

	l_sub_itm_tbl 			JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
	l_sub_uom_tbl			JTF_VARCHAR2_TABLE_100 := JTF_VARCHAR2_TABLE_100();
	l_sub_qty_tbl			JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();

        l_sub_listprice_tbl		JTF_NUMBER_TABLE;
	l_sub_bestprice_tbl		JTF_NUMBER_TABLE;

	l_sub_status_code_tbl		JTF_VARCHAR2_TABLE_100;
	l_sub_status_text_tbl		JTF_VARCHAR2_TABLE_300;

	l_sub_parentIndex_tbl		JTF_NUMBER_TABLE;
	l_sub_childIndex_tbl		JTF_NUMBER_TABLE;

        l_sub_return_status		varchar2(1);
        l_sub_return_status_text 	varchar2(30);

	--l_model_itm_id			NUMBER;
	l_index				NUMBER;
	l_model_bundle_flag		VARCHAR2(1);

	l_msg_data VARCHAR2(100);
 	l_msg_count NUMBER;
 	l_return_status VARCHAR2(30);
	l_item_csr IBE_CCTBOM_PVT.IBE_CCTBOM_REF_CSR_TYPE;
	l_bom_exp_rec IBE_CCTBOM_PVT.IBE_BOM_EXPLOSION_REC;

     l_bom_item_type		NUMBER;
     l_primary_uom_code		VARCHAR2(3);

     cursor l_bom_item_type_csr(l_itmid NUMBER) IS
	select MSIV.bom_item_type, MSIV.primary_uom_code
	from mtl_system_items_vl MSIV
	where MSIV.inventory_item_id = l_itmid  AND MSIV.organization_id = p_organization_id;

	l_resp_id 	NUMBER;
	l_resp_appl_id	NUMBER;
     	l_start_time	NUMBER;
     	l_end_time	NUMBER;

BEGIN
        L_API := 'CalculatePrices';
	IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
	IBE_UTIL.Debug(g_pkg_name||'.CalculatePrices: total items='||p_item_tbl.count);
	IBE_UTIL.Debug(g_pkg_name||'.CalculatePrices: Before calling QP:p_price_list_id='||p_price_list_id
		||',p_party_id='||p_party_id
		||',p_cust_account_id='||p_cust_account_id
		||',p_model_id='||p_model_id
		||',p_currency_code='||p_currency_code);
	END IF;

	l_start_time := DBMS_UTILITY.GET_TIME;
	GetPricesFromQP(
                p_price_list_id => p_price_list_id,
		p_party_id => p_party_id,
		p_cust_account_id => p_cust_account_id,
		p_model_id => p_model_id,
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

	IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
	IBE_UTIL.Debug(g_pkg_name||'.CalculatePrices:  Returned from GetPricesFromQP total items='||p_item_tbl.count);
	END IF;
	--ZHGG_UTIL.Debug(g_pkg_name||'.CalculatePrices:  Returned from GetPricesFromQP total items='||p_item_tbl.count);


	l_resp_id := FND_PROFILE.value('RESP_ID');
	l_resp_appl_id := FND_PROFILE.value('RESP_APPL_ID');

	FOR I IN 1..p_item_tbl.count LOOP
	    l_itm_id := p_item_tbl(I);

       	    OPEN l_bom_item_type_csr(l_itm_id);
            FETCH l_bom_item_type_csr INTO l_bom_item_type, l_primary_uom_code;
            CLOSE l_bom_item_type_csr;

	    IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
	    IBE_UTIL.Debug(g_pkg_name||'.CalculatePrices:  item='||l_itm_id||', bom_item_type = '|| l_bom_item_type
	        ||',uom='||p_uom_tbl(I)
	        ||',primary_uom_code='||l_primary_uom_code
	    	||',listPrice='||x_listprice_tbl(I)
	    	||',bestPrice='||x_bestprice_tbl(I));
	    END IF;

	    --gzhang 01/21/01, model bundle cache
	    IF p_model_bundle_flag_tbl IS NULL OR p_model_bundle_flag_tbl(I) IS NULL THEN
	        l_model_bundle_flag := IBE_CCTBOM_PVT.Is_Model_Bundle(p_api_version =>1.0, p_model_id =>l_itm_id, p_organization_id => p_organization_id);
	    ELSE
	        l_model_bundle_flag := p_model_bundle_flag_tbl(I);
	    END IF;

	    IF l_model_bundle_flag = FND_API.G_TRUE THEN
	      IF l_primary_uom_code = p_uom_tbl(I) THEN --Model Bundle only support pricing for primary uom code

	        IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
	        IBE_UTIL.Debug(g_pkg_name||'.CalculatePrices: Item '||l_itm_id||' is a model bundle.');
	        END IF;

	        IBE_CCTBOM_PVT.Load_Components(p_api_version =>1.0,
	            x_return_status=>l_return_status,
	            x_msg_data=>l_msg_data,
	            x_msg_count =>l_msg_count,
	            p_model_id =>l_itm_id,
	            p_organization_id =>p_organization_id,
	            x_item_csr =>l_item_csr);

	        IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
	        IBE_UTIL.Debug(g_pkg_name||'.CalculatePrices:  returned from IBE_CCTBOM_PVT');
	        END IF;

		IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN  --gzhang 05/24/2002, bug#2279562
	            l_index := 1;
	            FETCH l_item_csr INTO l_bom_exp_rec;
	            WHILE l_item_csr%FOUND LOOP
	    	        l_sub_itm_tbl.EXTEND;
	    	        l_sub_uom_tbl.EXTEND;
	    	        l_sub_qty_tbl.EXTEND;

	    	        l_sub_itm_tbl(l_index) := l_bom_exp_rec.component_item_id;

	    	        l_sub_uom_tbl(l_index) := l_bom_exp_rec.primary_uom_code;
	    	        l_sub_qty_tbl(l_index) := l_bom_exp_rec.component_quantity;

	    	        IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
	    	        IBE_UTIL.Debug(g_pkg_name||'.CalculatePrices: Component '||l_index||' of Model Item '||l_itm_id||': item_id='||l_sub_itm_tbl(l_index)||',uom='||l_sub_uom_tbl(l_index)||',qty='||l_sub_qty_tbl(l_index));
	    	        END IF;

	    	        l_index := l_index + 1;
		        FETCH l_item_csr INTO l_bom_exp_rec;
  	            END LOOP;
  	            CLOSE l_item_csr;

	    	    IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
	    	    IBE_UTIL.Debug(g_pkg_name||'.CalculatePrices: Currency Code for Model Item '||l_itm_id||':'||p_currency_code);
	    	    IBE_UTIL.Debug(g_pkg_name||'.CalculatePrices: Price List for Model Item '||l_itm_id||':'||p_price_list_id);
	    	    IBE_UTIL.Debug(g_pkg_name||'.CalculatePrices: Organization ID for Model Item '||l_itm_id||':'||p_organization_id);
	    	    IBE_UTIL.Debug(g_pkg_name||'.CalculatePrices: Request Type for Model Item '||l_itm_id||':'||p_request_type_code);
	    	    IBE_UTIL.Debug(g_pkg_name||'.CalculatePrices: Pricing Event for Model Item '||l_itm_id||':'||p_pricing_event);
  	            IBE_UTIL.Debug(g_pkg_name||'.CalculatePrices:  Before QP total items='||l_sub_itm_tbl.count);
  	            END IF;
  	            --ZHGG_UTIL.Debug(g_pkg_name||'.CalculatePrices: total component items='||l_sub_itm_tbl.count);
	            GetPricesFromQP(
		        p_price_list_id => p_price_list_id,
		        p_model_id => l_itm_id,
		        --p_organization_id => p_organization_id,
		        p_currency_code => p_currency_code,
		        p_item_tbl => l_sub_itm_tbl,
		        p_uom_tbl => l_sub_uom_tbl,
		        --p_parentIndex_tbl => l_non_model_bundle_parentIndex_tbl,
		        --p_childIndex_tbl => l_non_model_childIndex_tbl,
		        p_request_type_code => p_request_type_code,
		        p_pricing_event => p_pricing_event,
		        x_listprice_tbl => l_sub_listprice_tbl,
		        x_bestprice_tbl => l_sub_bestprice_tbl,
		        x_status_code_tbl  => l_sub_status_code_tbl,
		        x_status_text_tbl => l_sub_status_text_tbl,
		        x_parentIndex_tbl => l_sub_parentIndex_tbl,
		        x_childIndex_tbl => l_sub_childIndex_tbl,
 		        x_return_status  => l_sub_return_status,
           	        x_return_status_text    => l_sub_return_status_text
		    );

		    IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
  	            IBE_UTIL.Debug(g_pkg_name||'.CalculatePrices:  After QP total items='||l_sub_itm_tbl.count);
	    	    IBE_UTIL.Debug(g_pkg_name||'.CalculatePrices: Return Status for Model Item '||l_itm_id||':'||l_sub_return_status);
	    	    IBE_UTIL.Debug(g_pkg_name||'.CalculatePrices: Return Status Text for Model Item '||l_itm_id||':'||l_sub_return_status_text);
	    	    END IF;

		    IF l_sub_return_status = FND_API.G_RET_STS_SUCCESS THEN
		    	FOR J IN 1..l_sub_itm_tbl.count LOOP
	    	            IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
	    	            IBE_UTIL.Debug(g_pkg_name||'.CalculatePrices: Subprice for Model Item '||l_itm_id||'-'||l_sub_itm_tbl(J)||'-'||l_sub_uom_tbl(J)||':list='||l_sub_listprice_tbl(J)||',best='||l_sub_bestprice_tbl(J));
	    	            END IF;
		            x_listprice_tbl(I) := x_listprice_tbl(I) + l_sub_listprice_tbl(J)*l_sub_qty_tbl(J);
		            x_bestprice_tbl(I) := x_bestprice_tbl(I) + l_sub_bestprice_tbl(J)*l_sub_qty_tbl(J);
		    	END LOOP;
	    	    	IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
	    	    	IBE_UTIL.Debug(g_pkg_name||'.CalculatePrices: Total Price of Model Item '||l_itm_id||': list='||x_listprice_tbl(I)||',best='||x_bestprice_tbl(I));
	    	    	END IF;
	    	    ELSE -- Exception in component item pricing
			x_listprice_tbl(I) := NULL;
		        x_bestprice_tbl(I) := NULL;
		        IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
		        IBE_UTIL.Debug(g_pkg_name||'.CalculatePrices: Exception in component item pricing. set price to null');
		        END IF;
	    	    END IF;

	            l_sub_itm_tbl.DELETE;
	            l_sub_uom_tbl.DELETE;
	            l_sub_qty_tbl.DELETE;
	        ELSE --gzhang 05/24/2002, bug#2279562, BOM Exception
		    x_listprice_tbl(I) := NULL;
		    x_bestprice_tbl(I) := NULL;
		    IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
		    IBE_UTIL.Debug(g_pkg_name||'.CalculatePrices: BOM Explode Exception. set price to null');
		    END IF;
	        END IF;
	      ELSE -- Not a primary UOM code
	        x_listprice_tbl(I) := NULL;
	        x_bestprice_tbl(I) := NULL;
	        IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
	        IBE_UTIL.Debug(g_pkg_name||'.CalculatePrices: uom ='||p_uom_tbl(I)||', not primary uom code, set price null.');
	        END IF;
	      END IF;
	    /*gzhang 01/30/2003 bug fix#2690511
	    ELSIF l_bom_item_type = 1 AND CZ_CF_API.UI_FOR_ITEM(l_itm_id, p_organization_id, SYSDATE, 'DHTML', FND_API.G_MISS_NUM, l_resp_id, l_resp_appl_id) IS NULL THEN
	    -- invalid model bundle
	        x_listprice_tbl(I) := NULL;
	        x_bestprice_tbl(I) := NULL;
	        IBE_UTIL.Debug(g_pkg_name||'.CalculatePrices: invalid model bundle (item='||l_itm_id||', set price null.');*/
	    END IF;
	END LOOP;
	--gzhang 08/08/2002, bug#2488246
	--IBE_UTIL.Disable_Debug;
	l_end_time := DBMS_UTILITY.GET_TIME;
        --ZHGG_UTIL.debug(G_PKG_NAME||'.'||L_API||': end, elapsed time (s) ='||(l_end_time-l_start_time)/100);
        IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
        IBE_UTIL.debug(G_PKG_NAME||'.'||L_API||': end, elapsed time (s) ='||(l_end_time-l_start_time)/100);
        END IF;

END CalculatePrices;

-- 2.a  [using qp] get price of one item base on price_list_id
PROCEDURE GetPrice(
	   p_price_list_id			IN	NUMBER

	   --gzhang 12/03/01 model bundle
	   ,p_model_id			IN  NUMBER := FND_API.G_MISS_NUM
	   ,p_organization_id		IN	NUMBER := FND_API.G_MISS_NUM

	   ,p_currency_code			IN 	VARCHAR2
           ,p_inventory_item_id			IN	NUMBER
           ,p_uom_code				IN	VARCHAR2
--	   ,p_calculate_flag			IN	CHAR(1) :='Y'

	   --01/21/01 gzhang, model bundle cache
	   ,p_model_bundle_flag			IN 	VARCHAR2 := NULL

	   ,p_request_type_code	        	IN	VARCHAR2
	   ,p_pricing_event			IN 	VARCHAR2
           ,x_listprice				OUT	NOCOPY NUMBER
	   ,x_bestprice				OUT	NOCOPY NUMBER
	   ,x_status_code			OUT	NOCOPY varchar2
	   ,x_status_text			OUT     NOCOPY varchar2
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

	--gzhang 01/21/01, model bundle cache
	l_modelbundle_flag_tbl JTF_VARCHAR2_TABLE_100 := JTF_VARCHAR2_TABLE_100();

	x_return_status		VARCHAR2(1);
	x_return_status_text	VARCHAR2(240);

BEGIN
        --gzhang 08/08/2002, bug#2488246
        --ibe_util.enable_debug;
	l_item_tbl.extend();
	l_item_tbl(1) := p_inventory_item_id;
	l_uom_tbl.extend();
	l_uom_tbl(1) := p_uom_code;

	--gzhang 01/21/01, model bundle cache
	l_modelbundle_flag_tbl.extend;
	l_modelbundle_flag_tbl(1) := p_model_bundle_flag;

	CalculatePrices(
		p_price_list_id => p_price_list_id,

		--gzhang 12/03/01 model bundle
		p_model_id => p_model_id,
	   	p_organization_id => p_organization_id,

		p_currency_code => p_currency_code,
		p_item_tbl => l_item_tbl,
		p_uom_tbl => l_uom_tbl,

		--gzhang 01/21/01, model bundle cache
		p_model_bundle_flag_tbl => l_modelbundle_flag_tbl,

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
	--gzhang 08/08/2002, bug#2488246
	--ibe_util.disable_debug;
END GetPrice;


--2.b  [using qp] get price of one item base on party_id and cust_account_id
PROCEDURE GetPrice(
	   p_party_id			IN	NUMBER
	   ,p_cust_account_id		IN	NUMBER

	   --gzhang 12/03/01 model bundle
	   ,p_model_id			IN  	NUMBER := FND_API.G_MISS_NUM
	   ,p_organization_id		IN	NUMBER := FND_API.G_MISS_NUM

	   ,p_currency_code		IN 	VARCHAR2
           ,p_inventory_item_id		IN	NUMBER
           ,p_uom_code			IN	VARCHAR2
--	   ,p_calculate_flag		IN	CHAR(1) :='Y'

	   --01/21/01 gzhang, model bundle cache
	   ,p_model_bundle_flag		IN 	VARCHAR2 := NULL

	   ,p_request_type_code	        IN	VARCHAR2
	   ,p_pricing_event			IN 	VARCHAR2
           ,x_listprice			OUT	NOCOPY NUMBER
	   ,x_bestprice			OUT	NOCOPY NUMBER
	   ,x_status_code		OUT	NOCOPY varchar2
	   ,x_status_text		OUT     NOCOPY varchar2
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

	--gzhang 01/21/01, model bundle cache
	l_modelbundle_flag_tbl JTF_VARCHAR2_TABLE_100 := JTF_VARCHAR2_TABLE_100();

	x_return_status		VARCHAR2(1);
	x_return_status_text	VARCHAR2(240);


BEGIN
        --gzhang 08/08/2002, bug#2488246
        --ibe_util.enable_debug;
	l_item_tbl.extend();
	l_item_tbl(1) := p_inventory_item_id;
	l_uom_tbl.extend();
	l_uom_tbl(1) := p_uom_code;

	--gzhang 01/21/01, model bundle cache, bug fix#2222002
	l_modelbundle_flag_tbl.extend;
	l_modelbundle_flag_tbl(1) := p_model_bundle_flag;

	CalculatePrices(
		p_party_id => p_party_id,
		p_cust_account_id => p_cust_account_id,

		--gzhang 12/03/01 model bundle
		p_model_id => p_model_id,
	   	p_organization_id => p_organization_id,

		p_currency_code => p_currency_code,
		p_item_tbl => l_item_tbl,
		p_uom_tbl => l_uom_tbl,

		--gzhang 01/21/01, model bundle cache
		p_model_bundle_flag_tbl => l_modelbundle_flag_tbl,

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
        --gzhang 08/08/2002, bug#2488246
        --ibe_util.disable_debug;
END GetPrice;

--2.b1  [using qp] get price of one item base on price_list_id, party_id,
--      and cust_account_id
PROCEDURE GetPrice(
           p_price_list_id              IN      NUMBER
	   ,p_party_id			IN	NUMBER
	   ,p_cust_account_id		IN	NUMBER

	   --gzhang 12/03/01 model bundle
	   ,p_model_id			IN  NUMBER := FND_API.G_MISS_NUM
	   ,p_organization_id		IN	NUMBER := FND_API.G_MISS_NUM

	   ,p_currency_code		IN 	VARCHAR2
           ,p_inventory_item_id		IN	NUMBER
           ,p_uom_code			IN	VARCHAR2
--	   ,p_calculate_flag		IN	CHAR(1) :='Y'

	   --01/21/01 gzhang, model bundle cache
	   ,p_model_bundle_flag		IN 	VARCHAR2 := NULL

	   ,p_request_type_code	        IN	VARCHAR2
	   ,p_pricing_event			IN 	VARCHAR2
           ,x_listprice			OUT	NOCOPY NUMBER
	   ,x_bestprice			OUT	NOCOPY NUMBER
	   ,x_status_code		OUT	NOCOPY varchar2
	   ,x_status_text		OUT     NOCOPY varchar2
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

	--gzhang 01/21/01, model bundle cache
	l_modelbundle_flag_tbl JTF_VARCHAR2_TABLE_100 := JTF_VARCHAR2_TABLE_100();

	x_return_status		VARCHAR2(1);
	x_return_status_text	VARCHAR2(240);


BEGIN
        --gzhang 08/08/2002, bug#2488246
        --ibe_util.enable_debug;
	l_item_tbl.extend();
	l_item_tbl(1) := p_inventory_item_id;
	l_uom_tbl.extend();
	l_uom_tbl(1) := p_uom_code;
	IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
        IBE_UTIL.DEBUG('price list: ' || p_price_list_id);
        IBE_UTIL.DEBUG('party: ' || p_party_id);
        IBE_UTIL.DEBUG('account: ' || p_cust_account_id);
        END IF;

	--gzhang 01/21/01, model bundle cache, bug fix#2222002
	l_modelbundle_flag_tbl.extend;
	l_modelbundle_flag_tbl(1) := p_model_bundle_flag;

	CalculatePrices(
                p_price_list_id => p_price_list_id,
		p_party_id => p_party_id,
		p_cust_account_id => p_cust_account_id,

		--gzhang 12/03/01 model bundle
		p_model_id => p_model_id,
	   	p_organization_id => p_organization_id,

		p_currency_code => p_currency_code,
		p_item_tbl => l_item_tbl,
		p_uom_tbl => l_uom_tbl,

		--gzhang 01/21/01, model bundle cache
		p_model_bundle_flag_tbl => l_modelbundle_flag_tbl,

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
        --gzhang 08/08/2002, bug#2488246
        --ibe_util.disable_debug;
END GetPrice;


-- 2.c [using qp] get price of one item base on price_list_id for service support
PROCEDURE GetPrice(
	   p_price_list_id			IN	NUMBER

	   --gzhang 12/03/01 model bundle
	   ,p_model_id			IN  NUMBER := FND_API.G_MISS_NUM
	   ,p_organization_id		IN	NUMBER := FND_API.G_MISS_NUM

	   ,p_currency_code			IN 	VARCHAR2
           ,p_inventory_item_id			IN	NUMBER
           ,p_uom_code				IN	VARCHAR2
	   ,p_related_inventory_item_id		IN	NUMBER
	   ,p_related_uom_code			IN	VARCHAR2
--	   ,p_calculate_flag			IN	CHAR(1) :='Y'

	   --01/21/01 gzhang, model bundle cache
	   ,p_model_bundle_flag		IN 	VARCHAR2 := NULL

	   ,p_request_type_code	        IN	VARCHAR2
	   ,p_pricing_event			IN 	VARCHAR2
           ,x_listprice				OUT	NOCOPY NUMBER
	   ,x_bestprice				OUT	NOCOPY NUMBER
	   ,x_status_code			OUT	NOCOPY varchar2
	   ,x_status_text			OUT     NOCOPY varchar2
           ,x_related_listprice			OUT	NOCOPY NUMBER
	   ,x_related_bestprice			OUT	NOCOPY NUMBER
	   ,x_related_status_code		OUT	NOCOPY varchar2
	   ,x_related_status_text		OUT     NOCOPY varchar2
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

	--gzhang 01/21/01, model bundle cache
	l_modelbundle_flag_tbl JTF_VARCHAR2_TABLE_100 := JTF_VARCHAR2_TABLE_100();

	x_return_status		VARCHAR2(1);
	x_return_status_text	VARCHAR2(240);

BEGIN
	--gzhang 08/08/2002, bug#2488246
	--ibe_util.enable_debug;
	l_item_tbl.extend();
	l_uom_tbl.extend();
	l_item_tbl(1) := p_inventory_item_id;
	l_uom_tbl(1) := p_uom_code;


	l_item_tbl.extend();
	l_uom_tbl.extend();
	l_item_tbl(2) := p_related_inventory_item_id;
	l_uom_tbl(2) := p_related_uom_code;

	--gzhang 01/21/01, model bundle cache, bug fix#2222002
	l_modelbundle_flag_tbl.extend;
	l_modelbundle_flag_tbl(1) := p_model_bundle_flag;

	l_parentIndex_tbl.extend();
	l_childIndex_tbl.extend();

	l_parentIndex_tbl(1) := 1;
	l_childIndex_tbl(1) := 2;

	CalculatePrices(
		p_price_list_id => p_price_list_id,

		--gzhang 12/03/01 model bundle
		p_model_id => p_model_id,
	   	p_organization_id => p_organization_id,

		p_currency_code => p_currency_code,
		p_item_tbl => l_item_tbl,
		p_uom_tbl => l_uom_tbl,
		p_parentIndex_tbl => l_parentIndex_tbl,
		p_childIndex_tbl => l_childIndex_tbl,

		--gzhang 01/21/01, model bundle cache
		p_model_bundle_flag_tbl => l_modelbundle_flag_tbl,

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

	--gzhang 08/08/2002, bug#2488246
	--ibe_util.disable_debug;
END GetPrice;



-- 2.d [using qp] get price of one item base customer info for service support
PROCEDURE GetPrice(
	   p_party_id			IN	NUMBER
	   ,p_cust_account_id		IN	NUMBER

	   --gzhang 12/03/01 model bundle
	   ,p_model_id			IN  NUMBER := FND_API.G_MISS_NUM
	   ,p_organization_id		IN	NUMBER := FND_API.G_MISS_NUM

	   ,p_currency_code			IN 	VARCHAR2
           ,p_inventory_item_id			IN	NUMBER
           ,p_uom_code				IN	VARCHAR2
	   ,p_related_inventory_item_id		IN	NUMBER
	   ,p_related_uom_code			IN	VARCHAR2
--	   ,p_calculate_flag			IN	CHAR(1) :='Y'

	   --01/21/01 gzhang, model bundle cache
	   ,p_model_bundle_flag		IN 	VARCHAR2 := NULL

	   ,p_request_type_code	        IN	VARCHAR2
	   ,p_pricing_event			IN 	VARCHAR2
           ,x_listprice				OUT	NOCOPY NUMBER
	   ,x_bestprice				OUT	NOCOPY NUMBER
	   ,x_status_code			OUT	NOCOPY varchar2
	   ,x_status_text			OUT     NOCOPY varchar2
           ,x_related_listprice			OUT	NOCOPY NUMBER
	   ,x_related_bestprice			OUT	NOCOPY NUMBER
	   ,x_related_status_code		OUT	NOCOPY varchar2
	   ,x_related_status_text		OUT     NOCOPY varchar2
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

	--gzhang 01/21/01, model bundle cache
	l_modelbundle_flag_tbl JTF_VARCHAR2_TABLE_100 := JTF_VARCHAR2_TABLE_100();

	x_return_status		VARCHAR2(1);
	x_return_status_text	VARCHAR2(240);

BEGIN
	--gzhang 08/08/2002, bug#2488246
	--ibe_util.enable_debug;
	l_item_tbl.extend();
	l_uom_tbl.extend();
	l_item_tbl(1) := p_inventory_item_id;
	l_uom_tbl(1) := p_uom_code;

	l_item_tbl.extend();
	l_uom_tbl.extend();
	l_item_tbl(2) := p_related_inventory_item_id;
	l_uom_tbl(2) := p_related_uom_code;

	--gzhang 01/21/01, model bundle cache, bug fix#2222002
	l_modelbundle_flag_tbl.extend;
	l_modelbundle_flag_tbl(1) := p_model_bundle_flag;

	l_parentIndex_tbl.extend();
	l_childIndex_tbl.extend();

	l_parentIndex_tbl(1) := 1;
	l_childIndex_tbl(1) := 2;


	CalculatePrices(
		p_party_id => p_party_id,
		p_cust_account_id => p_cust_account_id,

		--gzhang 12/03/01 model bundle
		p_model_id => p_model_id,
	   	p_organization_id => p_organization_id,

		p_currency_code => p_currency_code,
		p_item_tbl => l_item_tbl,
		p_uom_tbl => l_uom_tbl,
		p_parentIndex_tbl => l_parentIndex_tbl,
		p_childIndex_tbl => l_childIndex_tbl,

		--gzhang 01/21/01, model bundle cache
		p_model_bundle_flag_tbl => l_modelbundle_flag_tbl,

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

        --gzhang 08/08/2002, bug#2488246
        --ibe_util.disable_debug;

END GetPrice;


-- 2.d1 [using qp] get price of one item based on price_list_id and
--      customer info for service support
PROCEDURE GetPrice(
           p_price_list_id              IN      NUMBER
	   ,p_party_id			IN	NUMBER
	   ,p_cust_account_id		IN	NUMBER

	   --gzhang 12/03/01 model bundle
	   ,p_model_id			IN  NUMBER := FND_API.G_MISS_NUM
	   ,p_organization_id		IN	NUMBER := FND_API.G_MISS_NUM

	   ,p_currency_code			IN 	VARCHAR2
           ,p_inventory_item_id			IN	NUMBER
           ,p_uom_code				IN	VARCHAR2
	   ,p_related_inventory_item_id		IN	NUMBER
	   ,p_related_uom_code			IN	VARCHAR2
--	   ,p_calculate_flag			IN	CHAR(1) :='Y'

	   --01/21/01 gzhang, model bundle cache
	   ,p_model_bundle_flag		IN 	VARCHAR2 := NULL

	   ,p_request_type_code	        IN	VARCHAR2
	   ,p_pricing_event			IN 	VARCHAR2
           ,x_listprice				OUT	NOCOPY NUMBER
	   ,x_bestprice				OUT	NOCOPY NUMBER
	   ,x_status_code			OUT	NOCOPY varchar2
	   ,x_status_text			OUT     NOCOPY varchar2
           ,x_related_listprice			OUT	NOCOPY NUMBER
	   ,x_related_bestprice			OUT	NOCOPY NUMBER
	   ,x_related_status_code		OUT	NOCOPY varchar2
	   ,x_related_status_text		OUT     NOCOPY varchar2
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

	--gzhang 01/21/01, model bundle cache
	l_modelbundle_flag_tbl JTF_VARCHAR2_TABLE_100 := JTF_VARCHAR2_TABLE_100();

	x_return_status		VARCHAR2(1);
	x_return_status_text	VARCHAR2(240);

BEGIN
	--gzhang 08/08/2002, bug#2488246
	--ibe_util.enable_debug;
	l_item_tbl.extend();
	l_uom_tbl.extend();
	l_item_tbl(1) := p_inventory_item_id;
	l_uom_tbl(1) := p_uom_code;

	l_item_tbl.extend();
	l_uom_tbl.extend();
	l_item_tbl(2) := p_related_inventory_item_id;
	l_uom_tbl(2) := p_related_uom_code;

	--gzhang 01/21/01, model bundle cache, bug fix#2222002
	l_modelbundle_flag_tbl.extend;
	l_modelbundle_flag_tbl(1) := p_model_bundle_flag;

	l_parentIndex_tbl.extend();
	l_childIndex_tbl.extend();

	l_parentIndex_tbl(1) := 1;
	l_childIndex_tbl(1) := 2;


	CalculatePrices(
                p_price_list_id => p_price_list_id,
		p_party_id => p_party_id,
		p_cust_account_id => p_cust_account_id,

		--gzhang 12/03/01 model bundle
		p_model_id => p_model_id,
	   	p_organization_id => p_organization_id,

		p_currency_code => p_currency_code,
		p_item_tbl => l_item_tbl,
		p_uom_tbl => l_uom_tbl,
		p_parentIndex_tbl => l_parentIndex_tbl,
		p_childIndex_tbl => l_childIndex_tbl,

		--gzhang 01/21/01, model bundle cache
		p_model_bundle_flag_tbl => l_modelbundle_flag_tbl,

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
        --gzhang 08/08/2002, bug#2488246
        --ibe_util.disable_debug;
END GetPrice;


-- 2.e [using qp] get prices for a list of items based on price_list_id
PROCEDURE GetPrices(
	   p_price_list_id		IN	NUMBER

	   --gzhang 12/03/01 model bundle
	   ,p_model_id			IN  	NUMBER := FND_API.G_MISS_NUM
	   ,p_organization_id		IN	NUMBER := FND_API.G_MISS_NUM

	   ,p_currency_code		IN 	VARCHAR2
           ,p_item_tbl			IN	JTF_NUMBER_TABLE
           ,p_uom_tbl			IN	JTF_VARCHAR2_TABLE_100
--	   ,p_calculate_flag		IN	CHAR(1) :='Y'

	   --gzhang 01/21/01, model bundle cache
	   ,p_model_bundle_flag_tbl	IN	JTF_VARCHAR2_TABLE_100 := NULL

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
        --gzhang 08/08/2002, bug#2488246
        --ibe_util.enable_debug;
	CalculatePrices(
		p_price_list_id => p_price_list_id,

		--gzhang 12/03/01 model bundle
		p_model_id => p_model_id,
	   	p_organization_id => p_organization_id,

		p_currency_code => p_currency_code,
		p_item_tbl => p_item_tbl,
		p_uom_tbl => p_uom_tbl,

		--gzhang 01/21/01, model bundle cache
		p_model_bundle_flag_tbl => p_model_bundle_flag_tbl,

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
         --gzhang 08/08/2002, bug#2488246
         --ibe_util.disable_debug;
END GetPrices;

-- 2.f [using qp] get prices of a list of items based on party_id and cust_accoutn_id
PROCEDURE GetPrices(
	   p_party_id			IN	NUMBER
	   ,p_cust_account_id		IN	number

	   --gzhang 12/03/01 model bundle
	   ,p_model_id			IN  	NUMBER := FND_API.G_MISS_NUM
	   ,p_organization_id		IN	NUMBER := FND_API.G_MISS_NUM

	   ,p_currency_code		IN 	VARCHAR2
           ,p_item_tbl			IN	JTF_NUMBER_TABLE
           ,p_uom_tbl			IN	JTF_VARCHAR2_TABLE_100
--	   ,p_calculate_flag		IN	CHAR(1) :='Y'

	   --gzhang 01/21/01, model bundle cache
	   ,p_model_bundle_flag_tbl	IN	JTF_VARCHAR2_TABLE_100 := NULL

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
        --gzhang 08/08/2002, bug#2488246
        --ibe_util.enable_debug;
	CalculatePrices(
		p_party_id => p_party_id,
		p_cust_account_id => p_cust_account_id,

		--gzhang 12/03/01 model bundle
		p_model_id => p_model_id,
	   	p_organization_id => p_organization_id,

		p_currency_code => p_currency_code,
		p_item_tbl => p_item_tbl,
		p_uom_tbl => p_uom_tbl,

		--gzhang 01/21/01, model bundle cache
		p_model_bundle_flag_tbl => p_model_bundle_flag_tbl,

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
        --gzhang 08/08/2002, bug#2488246
        --ibe_util.disable_debug;
END GetPrices;

-- 2.f1 [using qp] get prices of a list of items based on price_list_id, party_id,
--      and cust_account_id
PROCEDURE GetPrices(
           p_price_list_id              IN      NUMBER
	   ,p_party_id			IN	NUMBER
	   ,p_cust_account_id		IN	number

	   --gzhang 12/03/01 model bundle
	   ,p_model_id			IN  NUMBER := FND_API.G_MISS_NUM
	   ,p_organization_id		IN	NUMBER := FND_API.G_MISS_NUM

	   ,p_currency_code		IN 	VARCHAR2
           ,p_item_tbl			IN	JTF_NUMBER_TABLE
           ,p_uom_tbl			IN	JTF_VARCHAR2_TABLE_100
--	   ,p_calculate_flag		IN	CHAR(1) :='Y'

	   --gzhang 01/21/01, model bundle cache
	   ,p_model_bundle_flag_tbl	IN	JTF_VARCHAR2_TABLE_100 := NULL

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
        --gzhang 08/08/2002, bug#2488246
        --ibe_util.enable_debug;
	CalculatePrices(
                p_price_list_id => p_price_list_id,
		p_party_id => p_party_id,
		p_cust_account_id => p_cust_account_id,

		--gzhang 12/03/01 model bundle
		p_model_id => p_model_id,
	   	p_organization_id => p_organization_id,

		p_currency_code => p_currency_code,
		p_item_tbl => p_item_tbl,
		p_uom_tbl => p_uom_tbl,

		--gzhang 01/21/01, model bundle cache
		p_model_bundle_flag_tbl => p_model_bundle_flag_tbl,

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
        --gzhang 08/08/2002, bug#2488246
        --ibe_util.disable_debug;
END GetPrices;


-- 2.g [using qp] get prices of a list of items based on price_list_id for service support
PROCEDURE GetPrices(
	   p_price_list_id		IN	NUMBER

	   --gzhang 12/03/01 model bundle
	   ,p_model_id			IN  NUMBER := FND_API.G_MISS_NUM
	   ,p_organization_id		IN	NUMBER := FND_API.G_MISS_NUM

	   ,p_currency_code		IN 	VARCHAR2
           ,p_item_tbl			IN	JTF_NUMBER_TABLE
           ,p_uom_tbl			IN	JTF_VARCHAR2_TABLE_100
	   ,p_parentIndex_tbl		IN	JTF_NUMBER_TABLE
	   ,p_childIndex_tbl		IN	JTF_NUMBER_TABLE
--	   ,p_calculate_flag		IN	CHAR(1) :='Y'

	   --gzhang 01/21/01, model bundle cache
	   ,p_model_bundle_flag_tbl	IN	JTF_VARCHAR2_TABLE_100 := NULL

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
        --gzhang 08/08/2002, bug#2488246
        --ibe_util.enable_debug;
	CalculatePrices(
		p_price_list_id => p_price_list_id,

		--gzhang 12/03/01 model bundle
		p_model_id => p_model_id,
	   	p_organization_id => p_organization_id,

		p_currency_code => p_currency_code,
		p_item_tbl => p_item_tbl,
		p_uom_tbl => p_uom_tbl,
		p_parentIndex_tbl => p_parentIndex_tbl,
		p_childIndex_tbl => p_childIndex_tbl,

		--gzhang 01/21/01, model bundle cache
		p_model_bundle_flag_tbl => p_model_bundle_flag_tbl,

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
        --gzhang 08/08/2002, bug#2488246
        --ibe_util.disable_debug;
END GetPrices;



-- 2.h [using qp] get prices of a list of items based on party_id and cust_accoutn_id
PROCEDURE GetPrices(
	   p_party_id			IN	NUMBER
	   ,p_cust_account_id		IN	number

	   --gzhang 12/03/01 model bundle
	   ,p_model_id			IN  NUMBER := FND_API.G_MISS_NUM
	   ,p_organization_id		IN	NUMBER := FND_API.G_MISS_NUM

	   ,p_currency_code		IN 	VARCHAR2
           ,p_item_tbl			IN	JTF_NUMBER_TABLE
           ,p_uom_tbl			IN	JTF_VARCHAR2_TABLE_100
	   ,p_parentIndex_tbl		IN	JTF_NUMBER_TABLE
	   ,p_childIndex_tbl		IN	JTF_NUMBER_TABLE
--	   ,p_calculate_flag		IN	CHAR(1) :='Y'

	   --gzhang 01/21/01, model bundle cache
	   ,p_model_bundle_flag_tbl	IN	JTF_VARCHAR2_TABLE_100 := NULL

	   ,p_request_type_code		IN	VARCHAR2
	   ,p_pricing_event		IN 	VARCHAR2
           ,x_listprice_tbl		OUT	nocopy JTF_NUMBER_TABLE
	   ,x_bestprice_tbl		OUT	nocopy JTF_NUMBER_TABLE
	   ,x_status_code_tbl		OUT	nocopy JTF_VARCHAR2_TABLE_100
	   ,x_status_text_tbl		OUT     nocopy JTF_VARCHAR2_TABLE_300
	   ,x_parentIndex_tbl		OUT	NOCOPY JTF_NUMBER_TABLE
	   ,x_childIndex_tbl		OUT	NOCOPY JTF_NUMBER_TABLE
           ,x_return_status		out 	nocopy	varchar2
           ,x_return_status_text        out 	nocopy	varchar2

)
IS

BEGIN
        --gzhang 08/08/2002, bug#2488246
        --ibe_util.enable_debug;
	CalculatePrices(
		p_party_id => p_party_id,
		p_cust_account_id => p_cust_account_id,

		--gzhang 12/03/01 model bundle
		p_model_id => p_model_id,
	   	p_organization_id => p_organization_id,

		p_currency_code => p_currency_code,
		p_item_tbl => p_item_tbl,
		p_uom_tbl => p_uom_tbl,
		p_parentIndex_tbl => p_parentIndex_tbl,
		p_childIndex_tbl => p_childIndex_tbl,

		--gzhang 01/21/01, model bundle cache
		p_model_bundle_flag_tbl => p_model_bundle_flag_tbl,

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
         --gzhang 08/08/2002, bug#2488246
         --ibe_util.disable_debug;
END GetPrices;

-- 2.h1 [using qp] get prices of a list of items based on price_list_id,
--      party_id and cust_account_id
PROCEDURE GetPrices(
           p_price_list_id              IN      NUMBER
	   ,p_party_id			IN	NUMBER
	   ,p_cust_account_id		IN	number

	   --gzhang 12/03/01 model bundle
	   ,p_model_id			IN  NUMBER := FND_API.G_MISS_NUM
	   ,p_organization_id		IN	NUMBER := FND_API.G_MISS_NUM

	   ,p_currency_code		IN 	VARCHAR2
           ,p_item_tbl			IN	JTF_NUMBER_TABLE
           ,p_uom_tbl			IN	JTF_VARCHAR2_TABLE_100
	   ,p_parentIndex_tbl		IN	JTF_NUMBER_TABLE
	   ,p_childIndex_tbl		IN	JTF_NUMBER_TABLE
--	   ,p_calculate_flag		IN	CHAR(1) :='Y'

	   --gzhang 01/21/01, model bundle cache
	   ,p_model_bundle_flag_tbl	IN	JTF_VARCHAR2_TABLE_100 := NULL

	   ,p_request_type_code		IN	VARCHAR2
	   ,p_pricing_event		IN 	VARCHAR2
           ,x_listprice_tbl		OUT	nocopy JTF_NUMBER_TABLE
	   ,x_bestprice_tbl		OUT	nocopy JTF_NUMBER_TABLE
	   ,x_status_code_tbl		OUT	nocopy JTF_VARCHAR2_TABLE_100
	   ,x_status_text_tbl		OUT     nocopy JTF_VARCHAR2_TABLE_300
	   ,x_parentIndex_tbl		OUT	NOCOPY JTF_NUMBER_TABLE
	   ,x_childIndex_tbl		OUT	NOCOPY JTF_NUMBER_TABLE
           ,x_return_status		out 	nocopy	varchar2
           ,x_return_status_text        out 	nocopy	varchar2

)
IS

BEGIN
        --gzhang 08/08/2002, bug#2488246
        --ibe_util.enable_debug;
	CalculatePrices(
                p_price_list_id => p_price_list_id,
		p_party_id => p_party_id,
		p_cust_account_id => p_cust_account_id,

		--gzhang 12/03/01 model bundle
		p_model_id => p_model_id,
	   	p_organization_id => p_organization_id,

		p_currency_code => p_currency_code,
		p_item_tbl => p_item_tbl,
		p_uom_tbl => p_uom_tbl,
		p_parentIndex_tbl => p_parentIndex_tbl,
		p_childIndex_tbl => p_childIndex_tbl,

		--gzhang 01/21/01, model bundle cache
		p_model_bundle_flag_tbl => p_model_bundle_flag_tbl,

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
        --gzhang 08/08/2002, bug#2488246
        --ibe_util.disable_debug;
END GetPrices;

-- integration with QP TEMP table
PROCEDURE PRICE_REQUEST(
            p_price_list_id		IN	NUMBER := FND_API.G_MISS_NUM
	   ,p_party_id			IN	NUMBER := FND_API.G_MISS_NUM
	   ,p_cust_account_id		IN	NUMBER := FND_API.G_MISS_NUM
	   ,p_currency_code		IN 	VARCHAR2
           ,p_minisite_id		IN	NUMBER := NULL
           ,p_item_tbl			IN  	QP_PREQ_GRP.NUMBER_TYPE
           ,p_uom_code_tbl		IN OUT 	NOCOPY	QP_PREQ_GRP.VARCHAR_TYPE
	   ,p_model_id_tbl		IN	JTF_NUMBER_TABLE
	   ,p_line_quantity_tbl		IN OUT	NOCOPY QP_PREQ_GRP.NUMBER_TYPE
	   ,p_parentIndex_tbl		IN	QP_PREQ_GRP.NUMBER_TYPE
	   ,p_childIndex_tbl		IN	QP_PREQ_GRP.NUMBER_TYPE
	   ,p_request_type_code		IN	VARCHAR2 := 'ASO'
	   ,p_pricing_event		IN 	VARCHAR2
           ,x_price_csr			OUT	NOCOPY PRICE_REFCURSOR_TYPE
           ,x_line_index_tbl		OUT	NOCOPY JTF_VARCHAR2_TABLE_100
           ,x_return_status		OUT 	NOCOPY	VARCHAR2
           ,x_return_status_text        OUT 	NOCOPY	VARCHAR2
	   )
IS

 L_API			     VARCHAR2(64);

 l_control_rec               QP_PREQ_GRP.CONTROL_RECORD_TYPE;

 I BINARY_INTEGER;
 l_t0   NUMBER;
 l_t1	NUMBER;
 l_t2   NUMBER;
 l_ti   NUMBER;

 G_LINE_INDEX_TBL              	QP_PREQ_GRP.PLS_INTEGER_TYPE;
 G_LINE_TYPE_CODE_TBL          	QP_PREQ_GRP.VARCHAR_TYPE;
 G_PRICING_EFFECTIVE_DATE_TBL  	QP_PREQ_GRP.DATE_TYPE   ;
 G_ACTIVE_DATE_FIRST_TBL       	QP_PREQ_GRP.DATE_TYPE   ;
 G_ACTIVE_DATE_FIRST_TYPE_TBL  	QP_PREQ_GRP.VARCHAR_TYPE;
 G_ACTIVE_DATE_SECOND_TBL      	QP_PREQ_GRP.DATE_TYPE   ;
 G_ACTIVE_DATE_SECOND_TYPE_TBL 	QP_PREQ_GRP.VARCHAR_TYPE ;
 --G_LINE_QUANTITY_TBL         	QP_PREQ_GRP.NUMBER_TYPE ;
 --G_LINE_UOM_CODE_TBL          QP_PREQ_GRP.VARCHAR_TYPE;
 G_REQUEST_TYPE_CODE_TBL       	QP_PREQ_GRP.VARCHAR_TYPE;
 G_PRICED_QUANTITY_TBL         	QP_PREQ_GRP.NUMBER_TYPE;
 G_UOM_QUANTITY_TBL            	QP_PREQ_GRP.NUMBER_TYPE;
 G_PRICED_UOM_CODE_TBL         	QP_PREQ_GRP.VARCHAR_TYPE;
 G_CURRENCY_CODE_TBL           	QP_PREQ_GRP.VARCHAR_TYPE;
 G_UNIT_PRICE_TBL              	QP_PREQ_GRP.NUMBER_TYPE;
 G_PERCENT_PRICE_TBL           	QP_PREQ_GRP.NUMBER_TYPE;
 G_ADJUSTED_UNIT_PRICE_TBL     	QP_PREQ_GRP.NUMBER_TYPE;
 G_UPD_ADJUSTED_UNIT_PRICE_TBL 	QP_PREQ_GRP.NUMBER_TYPE;
 G_PROCESSED_FLAG_TBL          	QP_PREQ_GRP.VARCHAR_TYPE;
 G_PRICE_FLAG_TBL              	QP_PREQ_GRP.VARCHAR_TYPE;
 G_LINE_ID_TBL                 	QP_PREQ_GRP.NUMBER_TYPE;
 G_PROCESSING_ORDER_TBL        	QP_PREQ_GRP.PLS_INTEGER_TYPE;
 G_ROUNDING_FACTOR_TBL          QP_PREQ_GRP.PLS_INTEGER_TYPE;
 G_ROUNDING_FLAG_TBL            QP_PREQ_GRP.FLAG_TYPE;
 G_QUALIFIERS_EXIST_FLAG_TBL    QP_PREQ_GRP.VARCHAR_TYPE;
 G_PRICING_ATTRS_EXIST_FLAG_TBL QP_PREQ_GRP.VARCHAR_TYPE;
 G_PRICE_LIST_ID_TBL            QP_PREQ_GRP.NUMBER_TYPE;
 G_PL_VALIDATED_FLAG_TBL        QP_PREQ_GRP.VARCHAR_TYPE;
 G_PRICE_REQUEST_CODE_TBL       QP_PREQ_GRP.VARCHAR_TYPE;
 G_USAGE_PRICING_TYPE_TBL       QP_PREQ_GRP.VARCHAR_TYPE;
 G_LINE_CATEGORY_TBL            QP_PREQ_GRP.VARCHAR_TYPE;
 G_PRICING_STATUS_CODE_tbl      QP_PREQ_GRP.VARCHAR_TYPE;
 G_PRICING_STATUS_TEXT_tbl      QP_PREQ_GRP.VARCHAR_TYPE;
 G_RELATIONSHIP_TYPE_CODE	QP_PREQ_GRP.VARCHAR_TYPE;
 G_LINE_DETAIL_INDEX_tbl        QP_PREQ_GRP.NUMBER_TYPE;
 G_RLTD_LINE_DETAIL_INDEX_tbl   QP_PREQ_GRP.NUMBER_TYPE;

 L_PRICE_LIST	NUMBER := -9999;
 l_model_id 	NUMBER;
 l_cust_party_id NUMBER;
 l_service_duration NUMBER;
 l_service_duration_period_code VARCHAR2(10);
 l_target_duration NUMBER;
 l_organization_id NUMBER := -9999;
 l_operating_unit  NUMBER;
 CURSOR get_party_id_cur(l_cust_account_id NUMBER) IS
  SELECT party_id
  FROM   hz_cust_accounts
  WHERE  cust_account_id = l_cust_account_id;

 CURSOR get_organization_id_cur(l_operating_unit NUMBER) IS
  SELECT master_organization_id
  FROM   oe_system_parameters_all
  WHERE  org_id = l_operating_unit;

 CURSOR get_service_info_cur(l_item_id NUMBER, l_organization_id NUMBER) IS
  SELECT service_duration, service_duration_period_code
  FROM   mtl_system_items_vl
  WHERE  inventory_item_id = l_item_id
  AND    organization_id = l_organization_id;

BEGIN
	L_API := 'PRICE_REQUEST';
	IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
	IBE_UTIL.DEBUG(g_pkg_name||'.'||L_API||': QP Version'||QP_PREQ_GRP.GET_VERSION);
	END IF;

	l_t0 := DBMS_UTILITY.GET_TIME;
	IF p_price_list_id IS NOT NULL AND p_price_list_id <> FND_API.G_MISS_NUM THEN
	    L_PRICE_LIST := p_price_list_id;
	END IF;
	IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
	IBE_UTIL.DEBUG(g_pkg_name||'.'||L_API||': internal QP price list: '||L_PRICE_LIST);
	END IF;

	-- clear ASO global structures
	ASO_PRICING_INT.G_LINE_REC := NULL;
 	ASO_PRICING_INT.G_HEADER_REC := NULL;
	IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
	IBE_UTIL.DEBUG(g_pkg_name||'.'||L_API||': ASO Global structures were cleared');
	END IF;

	-- set the request_id
	QP_PRICE_REQUEST_CONTEXT.SET_REQUEST_ID();
	IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
	IBE_UTIL.DEBUG(g_pkg_name||'.'||L_API||': request id was set');
	END IF;

	-- setup control record
	l_control_rec.pricing_event := p_pricing_event;
	l_control_rec.calculate_flag := 'Y';
	l_control_rec.simulation_flag := 'N';
	l_control_rec.temp_table_insert_flag := 'N';
	l_control_rec.request_type_code := 'ASO';
	l_control_rec.rounding_flag := 'Q';
	IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
	IBE_UTIL.DEBUG(g_pkg_name||'.'||L_API||': control record was set');
	END IF;

	-- setup ASO G_HEADER_REC
	--gzhang 06/07/2003, bug#2987376
 	ASO_PRICING_INT.G_HEADER_REC.party_id := p_party_id;
 	ASO_PRICING_INT.G_HEADER_REC.cust_account_id := p_cust_account_id;

  	--ssekar 22/09/2005 bug#4529258
  	OPEN get_party_id_cur(p_cust_account_id);
  	FETCH get_party_id_cur INTO l_cust_party_id;
  	CLOSE get_party_id_cur;

  	ASO_PRICING_INT.G_HEADER_REC.cust_party_id:= l_cust_party_id;
 	ASO_PRICING_INT.G_HEADER_REC.price_list_id:= p_price_list_id;
 	ASO_PRICING_INT.G_HEADER_REC.minisite_id:= p_minisite_id;
	IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
	IBE_UTIL.DEBUG(g_pkg_name||'.'||L_API||': price_list_id='||
                       p_price_list_id||',cust_account_is='||p_cust_account_id||
                       ',party_id'||p_party_id);
	END IF;

	-- populate line items
	IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
	IBE_UTIL.DEBUG(g_pkg_name||'.'||L_API||
                       ': populating line items..., total line items='||p_item_tbl.count);
	END IF;

	X_LINE_INDEX_TBL := JTF_VARCHAR2_TABLE_100();
	X_LINE_INDEX_TBL.EXTEND(p_item_tbl.count+1);
	FOR I in p_item_tbl.FIRST..p_item_tbl.LAST LOOP
	    l_target_duration  := NULL;
	    l_service_duration := NULL;
	    l_service_duration_period_code := NULL;

	    IF p_model_id_tbl(I) = -1 THEN
	    	l_model_id := FND_API.G_MISS_NUM;
	    ELSE
	    	l_model_id := p_model_id_tbl(I);
	    END IF;
	    IF l_model_id = FND_API.G_MISS_NUM THEN
	        X_LINE_INDEX_TBL(I) := 'L:'||p_item_tbl(I);
	    ELSE
	        X_LINE_INDEX_TBL(I) := 'L:'||p_item_tbl(I)||':'||l_model_id;
	    END IF;

            -- bug 4890626 ssekar
            IF (p_childindex_tbl IS NOT NULL AND p_childindex_tbl.count >0) THEN
            	FOR J IN p_childindex_tbl.FIRST..p_childindex_tbl.LAST LOOP
            	  IF I = p_childindex_tbl(J) THEN
                    IF l_organization_id < 0 THEN
                      -- fetch the organization id for the current OU.
		      l_operating_unit := MO_GLOBAL.get_current_org_id();

                      OPEN get_organization_id_cur(l_operating_unit);
                      FETCH get_organization_id_cur INTO l_organization_id;
                      CLOSE get_organization_id_cur;
                    END IF;

                  -- obtain the service duration and the period for an item
  		  OPEN get_service_info_cur(p_item_tbl(I),l_organization_id);
  		  FETCH get_service_info_cur INTO
  		           l_service_duration, l_service_duration_period_code;
  		  CLOSE get_service_info_cur;

                  IF (p_uom_code_tbl(I) IS NOT NULL
                      AND l_service_duration_period_code IS NOT NULL
                      AND  l_service_duration_period_code <>  p_uom_code_tbl(I)) THEN
		      IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
	                 IBE_UTIL.DEBUG(g_pkg_name||'.'||L_API||
                          'Uom Code and Service Period Different for item '||
                          p_item_tbl(I));
	              END IF;
  		      l_target_duration := oks_omint_pub.get_target_duration (
                                          null,null,p_uom_code_tbl(I),
  		                          l_service_duration,l_service_duration_period_code,
  		                          l_operating_unit);
  		  ELSIF ((l_service_duration_period_code = p_uom_code_tbl(I)) AND
  		           l_service_duration > 1) THEN
		      IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
	                 IBE_UTIL.DEBUG(g_pkg_name||'.'||L_API||
                          'Uom Code and Service Period equal for item, but quantity >1'||
                          p_item_tbl(I));
	              END IF;
  		      l_target_duration := l_service_duration;
                  END IF;
  		  EXIT;
            	  END IF;
                END LOOP;
             END IF;
	    -- populate line item
 	    G_line_index_tbl(I) :=I;                                         -- 1: Request Line Index
 	    G_line_type_code_tbl(I) := 'LINE';                               -- 2: LINE or ORDER(Summary Line)
 	    G_pricing_effective_date_tbl(I) := trunc(sysdate);                      -- 3: Pricing as of what date ? sysdate
 	    G_active_date_first_tbl(I) := sysdate;                           -- 4:? Can be Ordered Date or Ship Date==> leave as sysdate
 	    G_active_date_first_type_tbl(I) := 'NO TYPE';                    -- 5: ORD/SHIP ==>'ORD'? what does 'NO TYPE' mean?
 	    G_active_date_second_tbl(I) := sysdate;                          -- 6:? Can be Ordered Date or Ship Date==>leave as sysdate
 	    G_active_date_second_type_tbl(I) :='NO TYPE';                    -- 7:ORD/SHIP ==?'ORD'? should be "NO TYPE'

 	    --G_line_quantity_tbl(I) := 1;                                     -- 8: Ordered Quantity
 	    --G_LINE_UOM_CODE_TBL(I) := p_uom_code_tbl(I);                   -- 9: Ordered UOM Code

	    G_REQUEST_TYPE_CODE_TBL(I) := 'ASO';                             --10:
	    G_PRICED_QUANTITY_TBL(I) := null;                                --11:used by qp
	    G_PRICED_UOM_CODE_TBL(I) := null;                                --12:used by qp
 	    G_CURRENCY_CODE_TBL(I) := p_currency_code;                       --13:Currency Code
	    G_UNIT_PRICE_TBL(I) := null;                                     --14:used by qp
	    G_PERCENT_PRICE_TBL(I) := null;                                  --15:used by qp
	    G_UOM_QUANTITY_TBL(I) := l_target_duration;                      --16:
	    G_ADJUSTED_UNIT_PRICE_TBL(I) := null;                            --17:
	    G_UPD_ADJUSTED_UNIT_PRICE_TBL(I) := null;                        --18:
	    G_PROCESSED_FLAG_TBL(I) := null;                                 --19:
 	    G_PRICE_FLAG_TBL(I) := 'Y';                                      --20: Price Flag can have 'Y' , 'N'(No pricing) , 'P'(Phase)
 	    G_LINE_ID_TBL(I) := I;		                             --21: Order Line Id.
	    G_PROCESSING_ORDER_TBL(I) := null;                               --22:
	    G_PRICING_STATUS_CODE_tbl(I) := QP_PREQ_GRP.G_STATUS_UNCHANGED;  --23:
	    G_PRICING_STATUS_TEXT_tbl(I) := null;                            --24:
	    G_ROUNDING_FLAG_TBL(I) := null;                                  --25:
	    G_ROUNDING_FACTOR_TBL(I) := null;                                --26:
	    G_QUALIFIERS_EXIST_FLAG_TBL(I) := 'N';                           --27:
	    G_PRICING_ATTRS_EXIST_FLAG_TBL(I) := 'N';                        --28:
	    G_PRICE_LIST_ID_TBL(I) := L_PRICE_LIST;                          --29:price list id used by qp
	    G_PL_VALIDATED_FLAG_TBL(I) := 'N';                               --30:
	    G_PRICE_REQUEST_CODE_TBL(I) := null;                             --31:
 	    G_usage_pricing_type_tbl(I) := QP_PREQ_GRP.G_REGULAR_USAGE_TYPE; --32: This can be 'REGULAR', 'AUTHORING', 'BILLING' --used in usage pricing
	    --G_LINE_CATEGORY_tbl(I) := null;                                  --33:

	    -- populate line attributes/qualifiers
	    IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
	    	IBE_UTIL.DEBUG(g_pkg_name||'.'||L_API||': building line attributes/qualifiers,line index='||I);
	    END IF;

 	    ASO_PRICING_INT.G_LINE_REC.inventory_item_id := p_item_tbl(I);
 	    ASO_PRICING_INT.G_LINE_REC.uom_code:= p_uom_code_tbl(I);
 	    ASO_PRICING_INT.G_LINE_REC.quantity:= p_line_quantity_tbl(I);
 	    ASO_PRICING_INT.G_LINE_REC.price_list_id := p_price_list_id;
 	    ASO_PRICING_INT.G_LINE_rec.model_id := l_model_id;
 	    ASO_PRICING_INT.G_LINE_REC.minisite_id := p_minisite_id;

	    IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
	    IBE_UTIL.DEBUG(g_pkg_name||'.'||L_API||': item id ='||p_item_tbl(I)||', uom code ='||p_uom_code_tbl(I)||', model id ='||l_model_id);
	    END IF;

	    QP_ATTR_MAPPING_PUB.BUILD_CONTEXTS
	    	(p_request_type_code => p_request_type_code,
	    	 p_line_index        => I,
	    	 p_pricing_type_code => 'L');

	    IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
	    IBE_UTIL.DEBUG(g_pkg_name||'.'||L_API||': line item populated,line index='||I);
	    END IF;

	END LOOP;

	-- populate summary line
	I := p_item_tbl.LAST;

	IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
	IBE_UTIL.DEBUG(g_pkg_name||'.'||L_API||': populating the summary line, last line index='||I);
	END IF;

	I := I + 1;
        G_LINE_INDEX_TBL(I) :=I;                                         -- 1: Request Line Index
        G_LINE_TYPE_CODE_TBL(I) := 'ORDER';                               -- 2: LINE or ORDER(Summary Line)
 	G_pricing_effective_date_tbl(I) :=trunc(sysdate);                      -- 3: Pricing as of what date ?
 	G_active_date_first_tbl(I) := sysdate;                           -- 4:? Can be Ordered Date or Ship Date
 	G_active_date_first_type_tbl(I) := 'NO TYPE';                    -- 5: ORD/SHIP ==>'ORD'? what does 'NO TYPE' mean?
 	G_active_date_second_tbl(I) := sysdate;                          -- 6:? Can be Ordered Date or Ship Date
 	G_active_date_second_type_tbl(I) :='NO TYPE';                    -- 7:? ORD/SHIP ==?'ORD'?

 	P_LINE_QUANTITY_TBL(I) := 1;                                     -- 8: Ordered Quantity
 	--G_LINE_UOM_CODE_TBL(I) := NULL;                                -- 9: Ordered UOM Code
 	P_UOM_CODE_TBL(I) := NULL;                                       -- 9: Ordered UOM Code
	G_request_type_code_tbl(I) := 'ASO';                             --10:
	G_PRICED_QUANTITY_TBL(I) := null;                                --11:?
	G_PRICED_UOM_CODE_TBL(I) := null;                                --12:?
 	G_currency_code_tbl(I) := p_currency_code;                       --13: Currency Code
	G_UNIT_PRICE_TBL(I) := null;                                     --14:?
	G_PERCENT_PRICE_TBL(I) := null;                                  --15:?
	G_UOM_QUANTITY_TBL(I) := null;                                   --16:
	G_ADJUSTED_UNIT_PRICE_TBL(I) := null;                            --17:
	G_UPD_ADJUSTED_UNIT_PRICE_TBL(I) := null;                        --18:
	G_PROCESSED_FLAG_TBL(I) := null;                                 --19:
 	G_PRICE_FLAG_TBL(I) := 'Y';                                      --20: Price Flag can have 'Y' , 'N'(No pricing) , 'P'(Phase)
 	G_LINE_ID_TBL(I) := I;                                           --21: Order Line Id.
	G_PROCESSING_ORDER_TBL(I) := null;                               --22:
	G_PRICING_STATUS_CODE_tbl(I) := QP_PREQ_GRP.G_STATUS_UNCHANGED;  --23:
	G_PRICING_STATUS_TEXT_tbl(I) := null;                            --24:
	G_ROUNDING_FLAG_TBL(I) := null;                                  --25:
	G_ROUNDING_FACTOR_TBL(I) := null;                                --26:
	G_QUALIFIERS_EXIST_FLAG_TBL(I) := 'N';                           --27:
	G_PRICING_ATTRS_EXIST_FLAG_TBL(I) := 'N';                        --28:
	G_PRICE_LIST_ID_TBL(I) := L_PRICE_LIST;                          --29:???
	G_PL_VALIDATED_FLAG_TBL(I) := 'N';                               --30:
	G_PRICE_REQUEST_CODE_TBL(I) := null;                             --31:
 	G_usage_pricing_type_tbl(I) := QP_PREQ_GRP.G_REGULAR_USAGE_TYPE; --32: This can be 'REGULAR', 'AUTHORING', 'BILLING' --used in usage pricing
	--G_LINE_CATEGORY_tbl(I) := null;                                  --33:

	-- populate header attibutes/qualifiers
	IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
	IBE_UTIL.DEBUG(g_pkg_name||'.'||L_API||': building header attributes/qualifiers, summary line index='||I);
	END IF;

	QP_ATTR_MAPPING_PUB.BUILD_CONTEXTS
	    	(p_request_type_code => p_request_type_code,
	    	 p_line_index        => I,
	    	 p_pricing_type_code => 'H');

	--X_LINE_INDEX_TBL.EXTEND;
	X_LINE_INDEX_TBL(I) := 'H:';
	IF p_price_list_id = FND_API.G_MISS_NUM THEN
	    X_LINE_INDEX_TBL(I) := X_LINE_INDEX_TBL(I)||':NULL';
	ELSE
	    X_LINE_INDEX_TBL(I) := X_LINE_INDEX_TBL(I)||':'||p_price_list_id;
	END IF;
	IF p_party_id = FND_API.G_MISS_NUM THEN
	    X_LINE_INDEX_TBL(I) := X_LINE_INDEX_TBL(I)||':NULL';
	ELSE
	    X_LINE_INDEX_TBL(I) := X_LINE_INDEX_TBL(I)||':'||p_party_id;
	END IF;
	IF p_cust_account_id = FND_API.G_MISS_NUM THEN
	    X_LINE_INDEX_TBL(I) := X_LINE_INDEX_TBL(I)||':NULL';
	ELSE
	    X_LINE_INDEX_TBL(I) := X_LINE_INDEX_TBL(I)||':'||p_cust_account_id;
	END IF;

	IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
	IBE_UTIL.DEBUG(g_pkg_name||'.'||L_API||': inserting request lines into QP temp table, total lines='||G_LINE_INDEX_TBL.count);
	END IF;

	l_ti := DBMS_UTILITY.GET_TIME;
        QP_PREQ_GRP.INSERT_LINES2
           (p_LINE_INDEX               => G_LINE_INDEX_TBL,
            p_LINE_TYPE_CODE           => G_LINE_TYPE_CODE_TBL,
            p_PRICING_EFFECTIVE_DATE   => G_PRICING_EFFECTIVE_DATE_TBL,
            p_ACTIVE_DATE_FIRST        => G_ACTIVE_DATE_FIRST_TBL,
            p_ACTIVE_DATE_FIRST_TYPE   => G_ACTIVE_DATE_FIRST_TYPE_TBL,
            p_ACTIVE_DATE_SECOND       => G_ACTIVE_DATE_SECOND_TBL,
            p_ACTIVE_DATE_SECOND_TYPE  => G_ACTIVE_DATE_SECOND_TYPE_TBL,
            p_LINE_QUANTITY            => P_LINE_QUANTITY_TBL,
            p_LINE_UOM_CODE            => P_UOM_CODE_TBL,
            p_REQUEST_TYPE_CODE        => G_REQUEST_TYPE_CODE_TBL,
            p_PRICED_QUANTITY          => G_PRICED_QUANTITY_TBL,
            p_PRICED_UOM_CODE          => P_UOM_CODE_TBL,
            p_CURRENCY_CODE            => G_CURRENCY_CODE_TBL,
            p_UNIT_PRICE               => G_UNIT_PRICE_TBL,
            p_PERCENT_PRICE            => G_PERCENT_PRICE_TBL,
            p_UOM_QUANTITY             => G_UOM_QUANTITY_TBL,
            p_ADJUSTED_UNIT_PRICE      => G_ADJUSTED_UNIT_PRICE_TBL,
            p_UPD_ADJUSTED_UNIT_PRICE  => G_UPD_ADJUSTED_UNIT_PRICE_TBL,
            p_PROCESSED_FLAG           => G_PROCESSED_FLAG_TBL,
            p_PRICE_FLAG               => G_PRICE_FLAG_TBL,
            p_LINE_ID                  => G_LINE_ID_TBL,
            p_PROCESSING_ORDER         => G_PROCESSING_ORDER_TBL,
            p_PRICING_STATUS_CODE      => G_PRICING_STATUS_CODE_TBL,
            p_PRICING_STATUS_TEXT      => G_PRICING_STATUS_TEXT_TBL,
            p_ROUNDING_FLAG            => G_ROUNDING_FLAG_TBL,
            p_ROUNDING_FACTOR          => G_ROUNDING_FACTOR_TBL,
            p_QUALIFIERS_EXIST_FLAG    => G_QUALIFIERS_EXIST_FLAG_TBL,
            p_PRICING_ATTRS_EXIST_FLAG => G_PRICING_ATTRS_EXIST_FLAG_TBL,
            p_PRICE_LIST_ID            => G_PRICE_LIST_ID_TBL,
            p_VALIDATED_FLAG           => G_PL_VALIDATED_FLAG_TBL,
            p_PRICE_REQUEST_CODE       => G_PRICE_REQUEST_CODE_TBL,
            p_USAGE_PRICING_TYPE       => G_USAGE_PRICING_TYPE_TBL,
            --p_line_category            => G_LINE_CATEGORY_TBL,
            x_status_code              => x_return_status,
            x_status_text              => x_return_status_text);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	    IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
	    IBE_UTIL.debug('Error in insert_lines '||x_return_status_text);
	    END IF;
	END IF;
	IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
	IBE_UTIL.DEBUG(g_pkg_name||'.'||L_API||': done, total lines='||G_LINE_INDEX_TBL.COUNT);
	END IF;

	-- populate related line records for service items
	IF (p_parentIndex_tbl IS NOT NULL AND p_parentIndex_tbl.count > 0 AND
	    p_childindex_tbl IS NOT NULL AND p_parentIndex_tbl.count = p_childindex_tbl.count) THEN
	    IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
	    IBE_UTIL.DEBUG(g_pkg_name||'.'||L_API||': populating related lines...');
	    END IF;
	    FOR I IN p_parentIndex_tbl.FIRST..p_parentIndex_tbl.LAST LOOP
	    	G_RELATIONSHIP_TYPE_CODE(I) := QP_PREQ_GRP.G_SERVICE_LINE;
	    	G_LINE_DETAIL_INDEX_TBL(I) := NULL;
	    	G_RLTD_LINE_DETAIL_INDEX_TBL(I) := NULL; --gzhang 06/07/2003
	    END LOOP;

	    IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
	    IBE_UTIL.DEBUG(g_pkg_name||'.'||L_API||': inserting related lines...');
	    END IF;

	    QP_PREQ_GRP.INSERT_RLTD_LINES2
	    (p_LINE_INDEX => p_parentIndex_tbl,
	     p_LINE_DETAIL_INDEX => G_LINE_DETAIL_INDEX_TBL,
	     p_RELATIONSHIP_TYPE_CODE => G_RELATIONSHIP_TYPE_CODE,
	     p_RELATED_LINE_INDEX => p_childindex_tbl,
	     p_RELATED_LINE_DETAIL_INDEX => G_RLTD_LINE_DETAIL_INDEX_TBL,
	     x_status_code => x_return_status,
	     x_status_text => x_return_status_text);

	    IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
	    IBE_UTIL.DEBUG(g_pkg_name||'.'||L_API||': related lines inserted, status='||x_return_status||', '||x_return_status_text);
	    END IF;

	END IF;

	-- calling pricing engine
        IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
        IBE_UTIL.DEBUG(g_pkg_name||'.'||L_API||': Calling pricing engine...');
        END IF;

	l_t1 := DBMS_UTILITY.GET_TIME;
	QP_PREQ_PUB.PRICE_REQUEST
		(p_control_rec => l_control_rec,
		 x_return_status => x_return_status,
		 x_return_status_text => x_return_status_text);
	l_t2 := DBMS_UTILITY.GET_TIME;

	IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
	ibe_util.debug(g_pkg_name||'.'||L_API||': Duration of Price Request Time(s) ='|| (l_t2-l_t1)/100);
	END IF;

	-- retrieve prices
	OPEN x_price_csr FOR --gzhang 01/30/03, bug#2774739
	    SELECT LINE_ID, LINE_UOM_CODE, LINE_QUANTITY, LINE_UNIT_PRICE, ORDER_UOM_SELLING_PRICE, PRICING_STATUS_CODE, PRICING_STATUS_TEXT
	    FROM QP_PREQ_LINES_TMP
	    WHERE PRICING_STATUS_CODE=QP_PREQ_PUB.G_STATUS_UPDATED
	    ORDER BY LINE_ID;

	IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
	IBE_UTIL.DEBUG(g_pkg_name||'.'||L_API||': RETURN');
	END IF;

EXCEPTION
	WHEN OTHERS THEN
	x_return_status := FND_API.G_RET_STS_ERROR;
  	x_return_status_text :=SQLERRM;

  	IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
  	IBE_UTIL.DEBUG(g_pkg_name||'.'||L_API||':'||SQLERRM);
  	END IF;
END Price_Request;

PROCEDURE PRICE_REQUEST(
            p_price_list_id		IN	NUMBER := FND_API.G_MISS_NUM
	   ,p_party_id			IN	NUMBER := FND_API.G_MISS_NUM
	   ,p_cust_account_id		IN	NUMBER := FND_API.G_MISS_NUM
	   ,p_currency_code		IN 	VARCHAR2
           ,p_minisite_id		IN	NUMBER := NULL
           ,p_item_tbl			IN	JTF_NUMBER_TABLE
           ,p_uom_code_tbl		IN	JTF_VARCHAR2_TABLE_100
	   ,p_model_id_tbl		IN	JTF_NUMBER_TABLE
	   ,p_line_quantity_tbl		IN	JTF_NUMBER_TABLE
	   ,p_parentIndex_tbl		IN	JTF_NUMBER_TABLE := NULL
	   ,p_childIndex_tbl		IN	JTF_NUMBER_TABLE := NULL
	   ,p_request_type_code		IN	VARCHAR2 := 'ASO'
	   ,p_pricing_event		IN 	VARCHAR2
           ,x_price_csr			OUT	NOCOPY PRICE_REFCURSOR_TYPE
           ,x_line_index_tbl		OUT	NOCOPY JTF_VARCHAR2_TABLE_100
           ,x_return_status		OUT 	NOCOPY	VARCHAR2
           ,x_return_status_text        OUT 	NOCOPY	VARCHAR2
)
IS
     L_API			VARCHAR2(64);
     l_itmid_tbl		QP_PREQ_GRP.NUMBER_TYPE;
     l_uom_code_tbl		QP_PREQ_GRP.VARCHAR_TYPE;
     l_line_quantity_tbl       	QP_PREQ_GRP.NUMBER_TYPE;
     l_parentIndex_tbl		QP_PREQ_GRP.NUMBER_TYPE;
     l_childIndex_tbl		QP_PREQ_GRP.NUMBER_TYPE;
     idx 			BINARY_INTEGER;
     l_total_lines		INTEGER;
     l_pricing_flag		BOOLEAN := TRUE;
     l_start_time		NUMBER;
     l_end_time			NUMBER;
     l_curr_time		NUMBER;
BEGIN
	L_API := 'PRICE_REQUEST';
        --IBE_UTIL.debug(G_PKG_NAME||'.'||L_API||': begin');
	l_start_time := DBMS_UTILITY.GET_TIME;
        IF p_item_tbl IS NOT NULL AND p_uom_code_tbl IS NOT NULL AND p_line_quantity_tbl IS NOT NULL THEN
            l_total_lines := p_item_tbl.COUNT;
	    --IBE_UTIL.debug(G_PKG_NAME||'.'||L_API||': total line items: '||l_total_lines);
            IF l_total_lines = p_uom_code_tbl.COUNT AND l_total_lines = p_line_quantity_tbl.COUNT THEN
        	--IBE_UTIL.debug(G_PKG_NAME||'.'||L_API||': converting JTF Tables to QP Tables - request lines ...');
        	FOR idx IN 1..l_total_lines LOOP
	    	    l_itmid_tbl(idx) := p_item_tbl(idx);
     	    	    l_uom_code_tbl(idx) := p_uom_code_tbl(idx);
     	    	    l_line_quantity_tbl(idx) := p_line_quantity_tbl(idx);
		END LOOP;
		l_curr_time := DBMS_UTILITY.GET_TIME;
		IF p_parentIndex_tbl IS NOT NULL AND p_childIndex_tbl IS NOT NULL THEN
		    l_total_lines := p_parentIndex_tbl.count;

	            IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
	            IBE_UTIL.debug(G_PKG_NAME||'.'||L_API||': total related lines: '||l_total_lines);
	            END IF;

		    IF l_total_lines >0 AND l_total_lines = p_childIndex_tbl.COUNT THEN

	                IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
	                IBE_UTIL.debug(G_PKG_NAME||'.'||L_API||': converting JTF Tables to QP Tables - related lines...');
	                END IF;

        	        FOR idx IN 1..l_total_lines LOOP
	    	            l_parentIndex_tbl(idx) := p_parentIndex_tbl(idx);
     	    	            l_childIndex_tbl(idx) := p_childIndex_tbl(idx);
		        END LOOP;

	                IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
	                IBE_UTIL.debug(G_PKG_NAME||'.'||L_API||': PL/SQL tables converted');
	                END IF;
	            ELSE
	                IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
	                IBE_UTIL.debug(G_PKG_NAME||'.'||L_API||': related lines mismatched');
	                IBE_UTIL.debug(G_PKG_NAME||'.'||L_API||': total child indexes: '||p_childIndex_tbl.COUNT);
	                END IF;

	                l_pricing_flag := FALSE;
		        x_return_status := FND_API.G_RET_STS_ERROR;
  		        x_return_status_text := 'invalid related lines - mismatched input tables';
	            END IF;
	        ELSE
	            IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
	            IBE_UTIL.debug(G_PKG_NAME||'.'||L_API||': no related lines found');
	            END IF;
	        END IF;

	        IF l_pricing_flag THEN
	            IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
	            IBE_UTIL.debug(G_PKG_NAME||'.'||l_api||':sending request...');
	            END IF;

		    l_curr_time := DBMS_UTILITY.GET_TIME;
		    IBE_PRICE_PVT.PRICE_REQUEST(
        	        p_price_list_id => p_price_list_id,
        	        p_party_id => p_party_id,
        	        p_cust_account_id => p_cust_account_id,
           	        p_currency_code => p_currency_code,
           	        p_minisite_id => p_minisite_id,
           	        p_item_tbl => l_itmid_tbl,
           	        p_uom_code_tbl => l_uom_code_tbl,
           	        p_model_id_tbl => p_model_id_tbl,
           	        p_line_quantity_tbl => l_line_quantity_tbl,
           	        p_parentIndex_tbl => l_parentIndex_tbl,
           	        p_childIndex_tbl => l_childIndex_tbl,
           	        p_request_type_code => p_request_type_code,
                        p_pricing_event => p_pricing_event,
                        x_price_csr => x_price_csr,
	                x_line_index_tbl=> x_line_index_tbl,
                        x_return_status => x_return_status,
                        x_return_status_text => x_return_status_text);
		    l_curr_time := DBMS_UTILITY.GET_TIME;

        	    IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
        	    IBE_UTIL.debug(G_PKG_NAME||'.'||l_api||':done, return status = '||x_return_status||': '||x_return_status_text);
        	    END IF;

	        END IF;
	    ELSE
	        IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
	        IBE_UTIL.debug(G_PKG_NAME||'.'||L_API||': request lines mismatched');
	        IBE_UTIL.debug(G_PKG_NAME||'.'||L_API||': total uom codes: '||p_uom_code_tbl.COUNT);
	        IBE_UTIL.debug(G_PKG_NAME||'.'||L_API||': total line quantities: '||p_line_quantity_tbl.COUNT);
	        END IF;

		x_return_status := FND_API.G_RET_STS_ERROR;
  		x_return_status_text := 'invalid request lines - mismatched input tables';
	    END IF;
        ELSE
            IF p_item_tbl IS NULL THEN
                IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
                IBE_UTIL.debug(G_PKG_NAME||'.'||L_API||':p_item_tbl is NULL');
                END IF;
            END IF;
            IF p_uom_code_tbl IS NULL THEN
                IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
                IBE_UTIL.debug(G_PKG_NAME||'.'||L_API||':p_uom_code_tbl is NULL');
                END IF;
            END IF;
            IF p_line_quantity_tbl IS NULL THEN
                IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
                IBE_UTIL.debug(G_PKG_NAME||'.'||L_API||':p_line_quantity_tbl is NULL');
                END IF;
            END IF;
	    x_return_status := FND_API.G_RET_STS_ERROR;
  	    x_return_status_text := 'invalid request lines - input table(s) is null';
        END IF;
	l_end_time := DBMS_UTILITY.GET_TIME;

        IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
        IBE_UTIL.debug(G_PKG_NAME||'.'||L_API||': end, elapsed time (s) ='||(l_end_time-l_start_time)/100);
        END IF;
EXCEPTION
	WHEN OTHERS THEN
	x_return_status := FND_API.G_RET_STS_ERROR;
  	x_return_status_text :=SQLERRM;

  	IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
  	IBE_UTIL.DEBUG(g_pkg_name||'.'||L_API||':'||SQLERRM);
  	END IF;
END Price_Request;
END IBE_PRICE_PVT;

/
