--------------------------------------------------------
--  DDL for Package OKS_EXTWARPRGM_OSO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_EXTWARPRGM_OSO_PVT" AUTHID CURRENT_USER AS
/* $Header: OKSRXRXS.pls 120.1 2005/08/10 03:32:25 hkamdar noship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_REQUIRED_VALUE		CONSTANT VARCHAR2(200) := OKC_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE			CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;
  G_UNEXPECTED_ERROR          CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXP_ERROR';
  G_SQLERRM_TOKEN             CONSTANT VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN             CONSTANT VARCHAR2(200) := 'SQLcode';
  G_UPPERCASE_REQUIRED		CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UPPERCASE_REQUIRED';

  ------------------------------------------------------------------------------------
  -- GLOBAL EXCEPTION
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;

  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKSOMINT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   := 'OKS';

  G_JTF_ORDER_HDR             CONSTANT VARCHAR2(200) := 'OKX_ORDERHEAD';
  G_JTF_ORDER_LN              CONSTANT VARCHAR2(200) := 'OKX_ORDERLINE';

  G_INVOICE_CONTACT		CONSTANT VARCHAR2(200) := 'BILLING';
  G_RULE_GROUP_CODE           CONSTANT VARCHAR2(200) := 'SVC_K';

  G_JTF_EXTWARR			CONSTANT VARCHAR2(200) := 'OKX_SERVICE';
  G_JTF_WARR			CONSTANT VARCHAR2(200) := 'OKX_WARRANTY';
  G_JTF_PARTY			CONSTANT VARCHAR2(200) := 'OKX_PARTY';
  G_JTF_PARTY_VENDOR          CONSTANT VARCHAR2(200) := 'OKX_OPERUNIT';
  G_JTF_INVOICE_CONTACT       CONSTANT VARCHAR2(200) := 'OKX_PCONTACT';
  G_JTF_BILLTO		      CONSTANT VARCHAR2(200) := 'OKX_BILLTO';
  G_JTF_COUNTER               CONSTANT VARCHAR2(200) := 'OKX_COUNTER';
  G_JTF_USAGE                 CONSTANT VARCHAR2(200) := 'OKX_USAGE';
  G_JTF_SHIPTO		      CONSTANT VARCHAR2(200) := 'OKX_SHIPTO';
  G_JTF_ARL		            CONSTANT VARCHAR2(200) := 'OKX_ACCTRULE';
  G_JTF_IRE		            CONSTANT VARCHAR2(200) := 'OKX_INVRULE';
  G_JTF_CUSTPROD	            CONSTANT VARCHAR2(200) := 'OKX_CUSTPROD';
  G_JTF_CUSTACCT	            CONSTANT VARCHAR2(200) := 'OKX_CUSTACCT';
  G_JTF_PRICE                 CONSTANT VARCHAR2(200) := 'OKX_PRICE';
  G_JTF_PAYMENT_TERM          CONSTANT VARCHAR2(200) := 'OKX_PPAYTERM';
  G_JTF_CONV_TYPE             CONSTANT VARCHAR2(200) := 'OKX_CONVTYPE';
  G_JTF_TAXEXEMP  		CONSTANT VARCHAR2(200) := 'OKX_TAXEXEMP';
  G_JTF_TAXCTRL  		      CONSTANT VARCHAR2(200) := 'OKX_TAXCTRL';


  ---------------------------------------------------------------------------

TYPE Pricing_Attributes_Type Is Record
(
    pricing_context                OKC_PRICE_ATT_VALUES.PRICING_CONTEXT%TYPE    := OKC_API.G_MISS_CHAR,
    pricing_attribute1             OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute2             OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute3             OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute4             OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute5             OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute6             OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute7             OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute8             OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute9             OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute10            OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute11            OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute12            OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute13            OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute14            OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute15            OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute16            OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE16%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute17            OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE17%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute18            OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE18%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute19            OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE19%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute20            OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE20%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute21            OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE21%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute22            OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE22%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute23            OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE23%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute24            OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE24%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute25            OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE25%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute26            OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE26%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute27            OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE27%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute28            OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE28%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute29            OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE29%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute30            OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE30%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute31            OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE31%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute32            OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE32%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute33            OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE33%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute34            OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE34%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute35            OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE35%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute36            OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE36%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute37            OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE37%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute38            OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE38%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute39            OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE39%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute40            OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE40%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute41            OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE41%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute42            OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE42%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute43            OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE43%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute44            OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE44%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute45            OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE45%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute46            OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE46%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute47            OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE47%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute48            OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE48%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute49            OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE49%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute50            OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE50%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute51            OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE51%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute52            OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE52%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute53            OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE53%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute54            OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE54%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute55            OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE55%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute56            OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE56%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute57            OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE57%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute58            OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE58%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute59            OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE59%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute60            OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE60%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute61            OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE61%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute62            OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE62%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute63            OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE63%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute64            OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE64%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute65            OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE65%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute66            OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE66%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute67            OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE67%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute68            OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE68%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute69            OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE69%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute70            OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE70%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute71            OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE71%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute72            OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE72%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute73            OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE73%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute74            OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE74%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute75            OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE75%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute76            OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE76%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute77            OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE77%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute78            OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE78%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute79            OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE79%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute80            OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE80%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute81            OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE81%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute82            OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE82%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute83            OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE83%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute84            OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE84%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute85            OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE85%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute86            OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE86%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute87            OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE87%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute88            OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE88%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute89            OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE89%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute90            OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE90%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute91            OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE91%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute92            OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE92%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute93            OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE93%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute94            OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE94%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute95            OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE95%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute96            OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE96%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute97            OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE97%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute98            OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE98%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute99            OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE99%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute100           OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE100%TYPE := OKC_API.G_MISS_CHAR
);

TYPE PartyRole_Type Is Record
(
     party_role           Varchar2 (30)
,    object1_id1          Number
,    object1_code         Varchar2 (30)
);

Type PartyRole_tbl is TABLE of PartyRole_type index by binary_integer;

TYPE Contact_Type Is  Record
(
     party_role           Varchar2(30)
,    contact_role         Varchar2(30)
,    contact_object_code  Varchar2(30)
,    contact_id           Number
);

Type Contact_tbl is TABLE of Contact_type index by binary_integer;


TYPE SalesCredit_Type Is  Record
(
     ctc_id               Number
,    sales_credit_type_id Number
,    percent              Number
);

Type SalesCredit_tbl is TABLE of SalesCredit_type index by binary_integer;


TYPE K_Header_Rec_Type Is Record
(
	contract_number		Varchar2(120)
,	start_date			Date
,	end_date			Date
,	sts_code			Varchar2(30)
,	class_code			Varchar2(30)
,	authoring_org_id		Number
,     short_description       Varchar2(1995)
,     chr_group               Number
,     pdf_id                  Number
,     party_id                Number
,	bill_to_id			Number
,	ship_to_id			Number
,     price_list_id           Number
,	cust_po_number		Varchar2(240)
,	agreement_id		Number
,	currency			Varchar2(15)
,	accounting_rule_id	Number
, 	invoice_rule_id		Number
,	order_hdr_id		Number
,     payment_term_id         Number
,     cvn_type                Varchar2(25)
,     cvn_rate                Number
,     cvn_date                Date
,     cvn_euro_rate           Number
,     tax_exemption_id        Number
,     tax_status_flag         Varchar2(30)
,     third_party_role        Varchar2(30)
,     merge_type              Varchar2(10)
,     merge_object_id         Number
,     renewal_type            Varchar2(3) --'NSR/SFA/DNR/EVN'
,     renewal_pricing_type    Varchar2(3) --'LST/PCT/MAN'
,     renewal_price_list_id   Number
,     renewal_markup          Number
,     renewal_po              Varchar2(1) --'Y/N'
,     first_billon_date            DATE
,     first_billupto_date            DATE
,     Billing_freq             VARCHAR2(30)
,     offset_Duration          Varchar2(30)
,     ATTRIBUTE1              VARCHAR2(450)
,     ATTRIBUTE2              VARCHAR2(450)
,     ATTRIBUTE3              VARCHAR2(450)
,     ATTRIBUTE4              VARCHAR2(450)
,     ATTRIBUTE5              VARCHAR2(450)
,     ATTRIBUTE6              VARCHAR2(450)
,     ATTRIBUTE7              VARCHAR2(450)
,     ATTRIBUTE8              VARCHAR2(450)
,     ATTRIBUTE9              VARCHAR2(450)
,     ATTRIBUTE10             VARCHAR2(450)
,     ATTRIBUTE11             VARCHAR2(450)
,     ATTRIBUTE12             VARCHAR2(450)
,     ATTRIBUTE13             VARCHAR2(450)
,     ATTRIBUTE14             VARCHAR2(450)
,     ATTRIBUTE15             VARCHAR2(450)
);


Type K_line_Service_Rec_Type Is Record
(
	k_id				Number
,	k_line_number		Varchar2(150)
,     line_sts_code           Varchar2(30)
,     cust_account            Number
,	org_id			Number
,organization_id                Number
,     srv_id			Number
,	object_name			Varchar2(30)
,	srv_segment1		Varchar2(440)
,	srv_desc			Varchar2(440)
,	srv_sdt			Date
,	srv_edt			Date
,	bill_to_id			Number
,	ship_to_id			Number
,	order_line_id		Number
,	accounting_rule_id	Number
,	warranty_flag		Char
,     Coverage_template_id	Number
,	currency			Varchar2(15)
,     reason_code             Varchar2(30)
,     reason_comments         Varchar2(1995)
,     line_renewal_type       Varchar2(3) -- 'FUL/KEP/DNR'
,     l_usage_type            VARCHAR2(30)
,     first_billon_date            DATE
,     first_billupto_date            DATE
,     Billing_freq             VARCHAR2(30)
,     offset_Duration          Varchar2(30)
,     period                   Varchar2(30)
,amcv_flag                     Varchar2(1)
,level_yn                      Varchar2(1)

,     INvoicing_rule_id        NUMBER
,     ATTRIBUTE1              VARCHAR2(450)
,     ATTRIBUTE2              VARCHAR2(450)
,     ATTRIBUTE3              VARCHAR2(450)
,     ATTRIBUTE4              VARCHAR2(450)
,     ATTRIBUTE5              VARCHAR2(450)
,     ATTRIBUTE6              VARCHAR2(450)
,     ATTRIBUTE7              VARCHAR2(450)
,     ATTRIBUTE8              VARCHAR2(450)
,     ATTRIBUTE9              VARCHAR2(450)
,     ATTRIBUTE10             VARCHAR2(450)
,     ATTRIBUTE11             VARCHAR2(450)
,     ATTRIBUTE12             VARCHAR2(450)
,     ATTRIBUTE13             VARCHAR2(450)
,     ATTRIBUTE14             VARCHAR2(450)
,     ATTRIBUTE15             VARCHAR2(450)
);

Type K_Line_Covered_level_Rec_Type Is Record
(
	k_id				Number
,	Attach_2_Line_id		Number
,	line_number			Varchar2(150)
,     product_sts_code        Varchar2(30)
,	Customer_Product_Id	Number
,	Product_Item_Id		Number
,	Product_Segment1		Varchar2(440)
,	Product_Desc		Varchar2(440)
,	Product_Start_Date	Date
,	Product_End_Date		Date
,	Quantity			Number
,     Uom_Code                Varchar2(3)
,     list_price              Number
,	negotiated_amount		Number
,    currency_code            Varchar2(15)
,     warranty_flag           Char
,     reason_code             Varchar2(30)
,     reason_comments         Varchar2(1995)
,     srv_id			     Number
,     line_renewal_type       Varchar2(3) -- 'FUL/KEP/DNR'
,     ATTRIBUTE1              VARCHAR2(450)
,     ATTRIBUTE2              VARCHAR2(450)
,     ATTRIBUTE3              VARCHAR2(450)
,     ATTRIBUTE4              VARCHAR2(450)
,     ATTRIBUTE5              VARCHAR2(450)
,     ATTRIBUTE6              VARCHAR2(450)
,     ATTRIBUTE7              VARCHAR2(450)
,     ATTRIBUTE8              VARCHAR2(450)
,     ATTRIBUTE9              VARCHAR2(450)
,     ATTRIBUTE10             VARCHAR2(450)
,     ATTRIBUTE11             VARCHAR2(450)
,     ATTRIBUTE12             VARCHAR2(450)
,     ATTRIBUTE13             VARCHAR2(450)
,     ATTRIBUTE14             VARCHAR2(450)
,     ATTRIBUTE15             VARCHAR2(450)
,     period                  VARCHAR2(30)
,     minimum_qty             VARCHAR2(30)
,     default_qty             VARCHAR2(30)
,     amcv_flag                VARCHAR2(30)
,     fixed_qty                VARCHAR2(30)
,     duration                 VARCHAR2(30)
,     level_yn                 VARCHAR2(30)
,     base_reading             VARCHAR2(30)
,org_id                        NUMBER
);


Type ExtWar_Rec_Type Is Record
(
	warranty_flag		Char
,     merge_type              Varchar2(10)
,     merge_object_id         Number
,	hdr_sdt			Date
,	hdr_edt			Date
,	hdr_org_id	  	      Number
,	hdr_party_id		Number
,     hdr_third_party_role    Varchar2(30)
,	hdr_bill_2_id		Number
,	hdr_ship_2_id		Number
,     hdr_price_list_id       Number
,	hdr_cust_po_number	Varchar2(240)
,	hdr_agreement_id	      Number
,	hdr_currency		Varchar2(15)
,	hdr_acct_rule_id	      Number
, 	hdr_inv_rule_id	      Number
,	hdr_order_hdr_id	      Number
,     hdr_status              Varchar2(30)
,     hdr_payment_term_id     Number
,     hdr_cvn_type            Varchar2(25)
,     hdr_cvn_rate            Number
,     hdr_cvn_date            Date
,     hdr_cvn_euro_rate       Number
,     hdr_chr_group           Number
,     hdr_pdf_id              Number
,     hdr_tax_exemption_id    Number
,     hdr_tax_status_flag     Varchar2(30)
,     hdr_renewal_type        Varchar2(3)
,     hdr_renewal_pricing_type Varchar2(3)
,     hdr_renewal_price_list_id Number
,     hdr_renewal_markup      Number
,     hdr_renewal_po          Varchar2(1)
,     cust_account            Number
,     srv_id			Number
,	srv_name			Varchar2(440)
,	srv_desc			Varchar2(440)
,	srv_sdt			Date
,	srv_edt			Date
,	srv_bill_2_id		Number
,	srv_ship_2_id		Number
,	srv_order_line_id	      Number
,	srv_amount		      Number
,	srv_unit_price		Number
,     srv_price_percent       Number
,	srv_currency		Varchar2(15)
,	srv_Cov_template_id	Number
,	lvl_cp_id			Number
,	lvl_inventory_id        Number
,	lvl_inventory_name	Varchar2(440)
,	lvl_inventory_desc	Varchar2(440)
,	lvl_Quantity		Number
,     lvl_uom_code            Varchar2(3)
,     lvl_order_line_id       Number
,     lvl_sts_code            Varchar2(40)
,     lvl_line_renewal_type   Varchar2(3)
,     l_usage_type            VARCHAR2(30)
,     period                  VARCHAR2(30)
,     minimum_qty             VARCHAR2(30)
,     default_qty             VARCHAR2(30)
,     amcv_flag                VARCHAR2(30)
,     fixed_qty                VARCHAR2(30)
,     duration                 VARCHAR2(30)
,     level_yn                 VARCHAR2(30)
,     base_reading             VARCHAR2(30)
,     first_billon_date        DATE
,     first_billupto_date      DATE
,     Billing_freq             VARCHAR2(30)
,     offset_Duration          Varchar2(30)
,organization_id                NUMBER
);








Procedure Update_Cov_level
(
	p_covered_line_id	    IN Number,
	p_new_end_date	    IN Date,
	p_K_item_id		    IN Number,
	p_new_negotiated_amt  IN Number,
	p_new_cp_qty	    IN Number,
	x_return_status	   OUT NOCOPY Varchar2
,     x_msg_count          OUT NOCOPY Number
,     x_msg_data           OUT NOCOPY Varchar2
);

Procedure Create_K_Hdr
(
	p_k_header_rec		IN  	K_HEADER_REC_TYPE
,     p_Contact_tbl           IN    Contact_Tbl
,	x_chr_id		     OUT NOCOPY 	Number
,	x_return_status	     OUT NOCOPY 	Varchar2
,     x_msg_count            OUT  NOCOPY   Number
,     x_msg_data             OUT  NOCOPY   Varchar2
);

Procedure Create_OSO_Contract_IBNEW
(
	p_extwar_rec		IN	ExtWar_Rec_Type
,     p_contact_tbl_in        IN    OKS_EXTWARPRGM_OSO_PVT.contact_tbl
,     p_salescredit_tbl_in    IN    OKS_EXTWARPRGM_OSO_PVT.salescredit_tbl
,     p_price_attribs_in      IN    OKS_EXTWARPRGM_OSO_PVT.pricing_attributes_type
,     x_chrid                OUT   NOCOPY  Number
,	x_return_status	     OUT NOCOPY 	Varchar2
,     x_msg_count            OUT   NOCOPY  Number
,     x_msg_data             OUT  NOCOPY   Varchar2
);

Procedure Create_OSO_K_Covered_Levels
(
	p_k_covd_rec			IN	K_line_Covered_Level_Rec_type
,     p_PRICE_ATTRIBS               IN    Pricing_attributes_Type
,	x_return_status		     OUT NOCOPY 	Varchar2
,     x_msg_count                  OUT  NOCOPY   Number
,     x_msg_data                   OUT  NOCOPY   Varchar2
);

Procedure Create_OSO_K_Service_Lines
(
	p_k_line_rec			IN	K_line_Service_Rec_type
,    p_Contact_tbl      IN   Contact_Tbl
,    p_salescredit_tbl_in          IN    SalesCredit_Tbl
,	x_service_line_id	     	     OUT NOCOPY 	Number
,	x_return_status		     OUT NOCOPY 	Varchar2
,    x_msg_count                  OUT  NOCOPY   Number
,    x_msg_data                   OUT NOCOPY    Varchar2
);

End OKS_EXTWARPRGM_OSO_PVT;

 

/
