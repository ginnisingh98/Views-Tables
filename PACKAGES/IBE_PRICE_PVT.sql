--------------------------------------------------------
--  DDL for Package IBE_PRICE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBE_PRICE_PVT" AUTHID CURRENT_USER as
/* $Header: IBEVPRCS.pls 115.34 2003/08/30 06:02:03 gzhang ship $ */


g_pkg_name   CONSTANT VARCHAR2(30) :=' IBE_PRICE_PVT';

type PRICE_REFCURSOR_TYPE is REF CURSOR;

-- test part--
Procedure getReqLineAttrAndQual(
	p_inventory_item_id 	IN NUMBER
	,p_uom_code		IN VARCHAR2
	,p_price_list_id	IN NUMBER :=   FND_API.G_MISS_NUM
	,p_party_id		IN NUMBER  :=  FND_API.G_MISS_NUM
	,p_cust_account_id 	IN NUMBER  :=  FND_API.G_MISS_NUM

	--gzhang 12/03/01 model bundle
	,p_model_id 	IN NUMBER  :=  FND_API.G_MISS_NUM

	,p_line_index		IN NUMBER
	,p_request_type_code	IN VARCHAR2
	,px_req_line_attr_tbl	IN OUT NOCOPY   QP_PREQ_GRP.LINE_ATTR_TBL_TYPE
	,px_req_qual_tbl  	IN OUT NOCOPY   QP_PREQ_GRP.qual_TBL_TYPE
);

Procedure getReqHeaderAttrAndQual(
	p_party_id              IN NUMBER :=  FND_API.G_MISS_NUM
	,p_cust_account_id	IN NUMBER :=  FND_API.G_MISS_NUM
	,p_price_list_id 	IN NUMBER :=  FND_API.G_MISS_NUM

	--gzhang 12/03/01 model bundle
	--,p_model_id 	IN NUMBER :=  FND_API.G_MISS_NUM

	,p_line_index		IN NUMBER
	,p_request_type_code	IN VARCHAR2
	,px_req_line_attr_tbl	IN OUT NOCOPY QP_PREQ_GRP.LINE_ATTR_TBL_TYPE
	,px_req_qual_tbl  	IN OUT NOCOPY QP_PREQ_GRP.qual_TBL_TYPE
);

-- 2.a  [using qp] get price of one item base on price_list_id
PROCEDURE GetPrice(
	   p_price_list_id		IN  NUMBER

	   --gzhang 12/03/01 model bundle
	   ,p_model_id			IN  NUMBER := FND_API.G_MISS_NUM
	   ,p_organization_id		IN  NUMBER := FND_API.G_MISS_NUM
	   ,p_currency_code		IN  VARCHAR2
           ,p_inventory_item_id		IN  NUMBER
           ,p_uom_code			IN  VARCHAR2

	   --01/21/01 gzhang, model bundle cache, 02/12/02 bug fix#2222002
	   ,p_model_bundle_flag		IN 	VARCHAR2 := NULL

	   ,p_request_type_code		IN  VARCHAR2
	   ,p_pricing_event		IN  VARCHAR2
           ,x_listprice			OUT NOCOPY NUMBER
	   ,x_bestprice			OUT NOCOPY NUMBER
	   ,x_status_code		OUT NOCOPY VARCHAR2
	   ,x_status_text		OUT NOCOPY VARCHAR2
);

--2.b  [using qp] get price of one item base on party_id and cust_account_id
PROCEDURE GetPrice(
	   p_party_id			IN  NUMBER
	   ,p_cust_account_id		IN  NUMBER

	   --gzhang 12/03/01 model bundle
	   ,p_model_id			IN  NUMBER := FND_API.G_MISS_NUM
	   ,p_organization_id		IN  NUMBER := FND_API.G_MISS_NUM

	   ,p_currency_code		IN  VARCHAR2
           ,p_inventory_item_id		IN  NUMBER
           ,p_uom_code			IN  VARCHAR2
--	   ,p_calculate_flag		IN  CHAR(1) :='Y'

	   --01/21/01 gzhang, model bundle cache, 02/12/02 bug fix#2222002
	   ,p_model_bundle_flag		IN 	VARCHAR2 := NULL

	   ,p_request_type_code	        IN  VARCHAR2
	   ,p_pricing_event		IN  VARCHAR2
           ,x_listprice			OUT NOCOPY NUMBER
	   ,x_bestprice			OUT NOCOPY NUMBER
	   ,x_status_code		OUT NOCOPY VARCHAR2
	   ,x_status_text		OUT NOCOPY VARCHAR2
);

--2.b1  [using qp] get price of one item base on price_list_id, party_id and cust_account_id
PROCEDURE GetPrice(
           p_price_list_id              IN  NUMBER
	   ,p_party_id			IN  NUMBER
	   ,p_cust_account_id		IN  NUMBER

	   --gzhang 12/03/01 model bundle
	   ,p_model_id			IN  NUMBER := FND_API.G_MISS_NUM
	   ,p_organization_id		IN  NUMBER := FND_API.G_MISS_NUM

	   ,p_currency_code		IN  VARCHAR2
           ,p_inventory_item_id		IN  NUMBER
           ,p_uom_code			IN  VARCHAR2
--	   ,p_calculate_flag		IN  CHAR(1) :='Y'

	   --01/21/01 gzhang, model bundle cache, 02/12/02 bug fix#2222002
	   ,p_model_bundle_flag		IN 	VARCHAR2 := NULL

	   ,p_request_type_code	        IN  VARCHAR2
	   ,p_pricing_event		IN  VARCHAR2
           ,x_listprice			OUT NOCOPY NUMBER
	   ,x_bestprice			OUT NOCOPY NUMBER
	   ,x_status_code		OUT NOCOPY VARCHAR2
	   ,x_status_text		OUT NOCOPY VARCHAR2
);

-- 2.c [using qp] get price of one item base on price_list_id for service support
PROCEDURE GetPrice(
	   p_price_list_id		IN  NUMBER

	   --gzhang 12/03/01 model bundle
	   ,p_model_id			IN  NUMBER := FND_API.G_MISS_NUM
	   ,p_organization_id		IN  NUMBER := FND_API.G_MISS_NUM

	   ,p_currency_code		IN  VARCHAR2
           ,p_inventory_item_id		IN  NUMBER
           ,p_uom_code			IN  VARCHAR2
	   ,p_related_inventory_item_id	IN  NUMBER
	   ,p_related_uom_code		IN  VARCHAR2
--	   ,p_calculate_flag		IN  CHAR(1) :='Y'

	   --01/21/01 gzhang, model bundle cache, 02/12/02 bug fix#2222002
	   ,p_model_bundle_flag		IN 	VARCHAR2 := NULL

	   ,p_request_type_code	        IN  VARCHAR2
	   ,p_pricing_event		IN  VARCHAR2
           ,x_listprice			OUT NOCOPY NUMBER
	   ,x_bestprice			OUT NOCOPY NUMBER
	   ,x_status_code		OUT NOCOPY VARCHAR2
	   ,x_status_text		OUT NOCOPY VARCHAR2
	   ,x_related_listprice		OUT NOCOPY NUMBER
	   ,x_related_bestprice		OUT NOCOPY NUMBER
	   ,x_related_status_code	OUT NOCOPY VARCHAR2
	   ,x_related_status_text	OUT NOCOPY VARCHAR2
);

-- 2.d [using qp] get price of one item base customer info for service support
PROCEDURE GetPrice(
	   p_party_id			IN  NUMBER
	   ,p_cust_account_id		IN  NUMBER

	   --gzhang 12/03/01 model bundle
	   ,p_model_id			IN  NUMBER := FND_API.G_MISS_NUM
	   ,p_organization_id		IN  NUMBER := FND_API.G_MISS_NUM

	   ,p_currency_code		IN  VARCHAR2
           ,p_inventory_item_id		IN  NUMBER
           ,p_uom_code			IN  VARCHAR2
	   ,p_related_inventory_item_id	IN  NUMBER
	   ,p_related_uom_code		IN  VARCHAR2
--	   ,p_calculate_flag		IN  CHAR(1) :='Y'

	   --01/21/01 gzhang, model bundle cache, 02/12/02 bug fix#2222002
	   ,p_model_bundle_flag		IN 	VARCHAR2 := NULL

	   ,p_request_type_code	        IN  VARCHAR2
	   ,p_pricing_event		IN  VARCHAR2
           ,x_listprice			OUT NOCOPY NUMBER
	   ,x_bestprice			OUT NOCOPY NUMBER
	   ,x_status_code		OUT NOCOPY VARCHAR2
	   ,x_status_text		OUT NOCOPY VARCHAR2
	   ,x_related_listprice		OUT NOCOPY NUMBER
	   ,x_related_bestprice		OUT NOCOPY NUMBER
	   ,x_related_status_code	OUT NOCOPY VARCHAR2
	   ,x_related_status_text	OUT NOCOPY VARCHAR2
);

-- 2.d1 [using qp] get price of one item based on price list and customer info
--      for service support
PROCEDURE GetPrice(
           p_price_list_id              IN  NUMBER
	   ,p_party_id			IN  NUMBER
	   ,p_cust_account_id		IN  NUMBER

	   --gzhang 12/03/01 model bundle
	   ,p_model_id			IN  NUMBER := FND_API.G_MISS_NUM
	   ,p_organization_id		IN  NUMBER := FND_API.G_MISS_NUM

	   ,p_currency_code		IN  VARCHAR2
           ,p_inventory_item_id		IN  NUMBER
           ,p_uom_code			IN  VARCHAR2
	   ,p_related_inventory_item_id	IN  NUMBER
	   ,p_related_uom_code		IN  VARCHAR2
--	   ,p_calculate_flag		IN  CHAR(1) :='Y'

	   --01/21/01 gzhang, model bundle cache, 02/12/02 bug fix#2222002
	   ,p_model_bundle_flag		IN 	VARCHAR2 := NULL

	   ,p_request_type_code	        IN  VARCHAR2
	   ,p_pricing_event		IN  VARCHAR2
           ,x_listprice			OUT NOCOPY NUMBER
	   ,x_bestprice			OUT NOCOPY NUMBER
	   ,x_status_code		OUT NOCOPY VARCHAR2
	   ,x_status_text		OUT NOCOPY VARCHAR2
	   ,x_related_listprice		OUT NOCOPY NUMBER
	   ,x_related_bestprice		OUT NOCOPY NUMBER
	   ,x_related_status_code	OUT NOCOPY VARCHAR2
	   ,x_related_status_text	OUT NOCOPY VARCHAR2
);



-- 2.e [using qp] get prices for a list of items based on price_list_id
PROCEDURE GetPrices(
	   p_price_list_id		IN  NUMBER

	   --gzhang 12/03/01 model bundle
	   ,p_model_id			IN  NUMBER := FND_API.G_MISS_NUM
	   ,p_organization_id		IN  NUMBER := FND_API.G_MISS_NUM

	   ,p_currency_code		IN  VARCHAR2
           ,p_item_tbl			IN  JTF_NUMBER_TABLE
           ,p_uom_tbl			IN  JTF_VARCHAR2_TABLE_100
--	   ,p_calculate_flag		IN  CHAR(1) :='Y'

	   --gzhang 01/21/01, model bundle cache
	   ,p_model_bundle_flag_tbl	IN	JTF_VARCHAR2_TABLE_100 := NULL

	   ,p_request_type_code		IN  VARCHAR2
	   ,p_pricing_event		IN  VARCHAR2
           ,x_listprice_tbl		OUT NOCOPY JTF_NUMBER_TABLE
	   ,x_bestprice_tbl		OUT NOCOPY JTF_NUMBER_TABLE
	   ,x_status_code_tbl		OUT NOCOPY JTF_VARCHAR2_TABLE_100
	   ,x_status_text_tbl		OUT NOCOPY JTF_VARCHAR2_TABLE_300
           ,x_return_status		out NOCOPY	VARCHAR2
           ,x_return_status_text        out NOCOPY	VARCHAR2

);

-- 2.f [using qp] get prices of a list of items based on party_id and cust_accoutn_id
PROCEDURE GetPrices(
	   p_party_id			IN  NUMBER
	   ,p_cust_account_id		IN  NUMBER

	   --gzhang 12/03/01 model bundle
	   ,p_model_id			IN  NUMBER := FND_API.G_MISS_NUM
	   ,p_organization_id		IN  NUMBER := FND_API.G_MISS_NUM

	   ,p_currency_code		IN  VARCHAR2
           ,p_item_tbl			IN  JTF_NUMBER_TABLE
           ,p_uom_tbl			IN  JTF_VARCHAR2_TABLE_100
--	   ,p_calculate_flag		IN  CHAR(1) :='Y'

	   --gzhang 01/21/01, model bundle cache
	   ,p_model_bundle_flag_tbl	IN	JTF_VARCHAR2_TABLE_100 := NULL

	   ,p_request_type_code		IN  VARCHAR2
	   ,p_pricing_event		IN  VARCHAR2
           ,x_listprice_tbl		OUT NOCOPY JTF_NUMBER_TABLE
	   ,x_bestprice_tbl		OUT NOCOPY JTF_NUMBER_TABLE
	   ,x_status_code_tbl		OUT NOCOPY JTF_VARCHAR2_TABLE_100
	   ,x_status_text_tbl		OUT NOCOPY JTF_VARCHAR2_TABLE_300
           ,x_return_status		OUT NOCOPY VARCHAR2
           ,x_return_status_text        OUT NOCOPY VARCHAR2

);

-- 2.f1 [using qp] get prices of a list of items based on price_list_id, party_id,
--      and cust_account_id
PROCEDURE GetPrices(
           p_price_list_id              IN  NUMBER
	   ,p_party_id			IN  NUMBER
	   ,p_cust_account_id		IN  NUMBER

	   --gzhang 12/03/01 model bundle
	   ,p_model_id			IN  NUMBER := FND_API.G_MISS_NUM
	   ,p_organization_id		IN  NUMBER := FND_API.G_MISS_NUM

	   ,p_currency_code		IN  VARCHAR2
           ,p_item_tbl			IN  JTF_NUMBER_TABLE
           ,p_uom_tbl			IN  JTF_VARCHAR2_TABLE_100
--	   ,p_calculate_flag		IN  CHAR(1) :='Y'

	   --gzhang 01/21/01, model bundle cache
	   ,p_model_bundle_flag_tbl	IN	JTF_VARCHAR2_TABLE_100 := NULL

	   ,p_request_type_code		IN  VARCHAR2
	   ,p_pricing_event		IN  VARCHAR2
           ,x_listprice_tbl		OUT NOCOPY JTF_NUMBER_TABLE
	   ,x_bestprice_tbl		OUT NOCOPY JTF_NUMBER_TABLE
	   ,x_status_code_tbl		OUT NOCOPY JTF_VARCHAR2_TABLE_100
	   ,x_status_text_tbl		OUT NOCOPY JTF_VARCHAR2_TABLE_300
           ,x_return_status		out NOCOPY VARCHAR2
           ,x_return_status_text        out NOCOPY VARCHAR2

);


-- 2.g [using qp] get prices of a list of items based on price_list_id for service support
PROCEDURE GetPrices(
	   p_price_list_id		IN  NUMBER

	   --gzhang 12/03/01 model bundle
	   ,p_model_id			IN  NUMBER := FND_API.G_MISS_NUM
	   ,p_organization_id		IN  NUMBER := FND_API.G_MISS_NUM

	   ,p_currency_code		IN  VARCHAR2
           ,p_item_tbl			IN  JTF_NUMBER_TABLE
           ,p_uom_tbl			IN  JTF_VARCHAR2_TABLE_100
	   ,p_parentIndex_tbl		IN  JTF_NUMBER_TABLE
	   ,p_childIndex_tbl		IN  JTF_NUMBER_TABLE
--	   ,p_calculate_flag		IN  CHAR(1) :='Y'

	   --gzhang 01/21/01, model bundle cache
	   ,p_model_bundle_flag_tbl	IN	JTF_VARCHAR2_TABLE_100 := NULL

	   ,p_request_type_code		IN  VARCHAR2
	   ,p_pricing_event		IN  VARCHAR2
           ,x_listprice_tbl		OUT NOCOPY JTF_NUMBER_TABLE
	   ,x_bestprice_tbl		OUT NOCOPY JTF_NUMBER_TABLE
	   ,x_status_code_tbl		OUT NOCOPY JTF_VARCHAR2_TABLE_100
	   ,x_status_text_tbl		OUT NOCOPY JTF_VARCHAR2_TABLE_300
	   ,x_parentIndex_tbl		out NOCOPY JTF_NUMBER_TABLE
	   ,x_childIndex_tbl		out NOCOPY JTF_NUMBER_TABLE
           ,x_return_status		out NOCOPY VARCHAR2
           ,x_return_status_text        out NOCOPY VARCHAR2

);



-- 2.h [using qp] get prices of a list of items based on party_id and cust_accoutn_id
PROCEDURE GetPrices(
	   p_party_id			IN	NUMBER
	   ,p_cust_account_id		IN	number

	   --gzhang 12/03/01 model bundle
	   ,p_model_id			IN  NUMBER := FND_API.G_MISS_NUM
	   ,p_organization_id		IN  NUMBER := FND_API.G_MISS_NUM

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
	   ,x_parentIndex_tbl		out	NOCOPY JTF_NUMBER_TABLE
	   ,x_childIndex_tbl		out	NOCOPY JTF_NUMBER_TABLE
           ,x_return_status		out 	nocopy	varchar2
           ,x_return_status_text        out 	nocopy	varchar2

);

-- 2.h1 [using qp] get prices of a list of items based on price_list_id,
--      party_id and cust_account_id
PROCEDURE GetPrices(
           p_price_list_id              IN      NUMBER
	   ,p_party_id			IN	NUMBER
	   ,p_cust_account_id		IN	number

	   --gzhang 12/03/01 model bundle
	   ,p_model_id			IN  NUMBER := FND_API.G_MISS_NUM
	   ,p_organization_id		IN  NUMBER := FND_API.G_MISS_NUM

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
	   ,x_parentIndex_tbl		out	NOCOPY JTF_NUMBER_TABLE
	   ,x_childIndex_tbl		out	NOCOPY JTF_NUMBER_TABLE
           ,x_return_status		out 	nocopy	varchar2
           ,x_return_status_text        out 	nocopy	varchar2

);

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
);

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
);

END IBE_PRICE_PVT;

 

/
