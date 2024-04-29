--------------------------------------------------------
--  DDL for Package OKS_CONTRACTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_CONTRACTS_PUB" AUTHID CURRENT_USER AS
/* $Header: OKSPKCRS.pls 120.0 2005/05/25 18:28:48 appldev noship $ */


G_REQUIRED_VALUE		    CONSTANT VARCHAR2(200)     := OKC_API.G_REQUIRED_VALUE;
G_INVALID_VALUE			    CONSTANT VARCHAR2(200)     := OKC_API.G_INVALID_VALUE;
G_COL_NAME_TOKEN		    CONSTANT VARCHAR2(200)     := OKC_API.G_COL_NAME_TOKEN;
G_PARENT_TABLE_TOKEN		    CONSTANT VARCHAR2(200)     := OKC_API.G_PARENT_TABLE_TOKEN;
G_CHILD_TABLE_TOKEN		    CONSTANT VARCHAR2(200)     := OKC_API.G_CHILD_TABLE_TOKEN;
G_UNEXPECTED_ERROR                  CONSTANT VARCHAR2(200)     := 'OKC_CONTRACTS_UNEXP_ERROR';
G_SQLERRM_TOKEN                     CONSTANT VARCHAR2(200)     := 'SQLerrm';
G_SQLCODE_TOKEN                     CONSTANT VARCHAR2(200)     := 'SQLcode';
G_UPPERCASE_REQUIRED		    CONSTANT VARCHAR2(200)     := 'OKC_CONTRACTS_UPPERCASE_REQUIRED';

------------------------------------------------------------------------------------
-- GLOBAL EXCEPTION
---------------------------------------------------------------------------
G_EXCEPTION_HALT_VALIDATION	EXCEPTION;

--global variables

 ---------------------------------------------------------------------------
G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKSOMINT';
G_APP_NAME			CONSTANT VARCHAR2(3)   := 'OKS';

G_JTF_ORDER_HDR                 CONSTANT VARCHAR2(200) := 'OKX_ORDERHEAD';
G_JTF_ORDER_LN                  CONSTANT VARCHAR2(200) := 'OKX_ORDERLINE';

G_INVOICE_CONTACT		CONSTANT VARCHAR2(200) := 'BILLING';
G_RULE_GROUP_CODE               CONSTANT VARCHAR2(200) := 'SVC_K';

G_JTF_EXTWARR			CONSTANT VARCHAR2(200) := 'OKX_SERVICE';
G_JTF_WARR			CONSTANT VARCHAR2(200) := 'OKX_WARRANTY';
G_JTF_PARTY			CONSTANT VARCHAR2(200) := 'OKX_PARTY';
G_JTF_PARTY_VENDOR              CONSTANT VARCHAR2(200) := 'OKX_OPERUNIT';
G_JTF_INVOICE_CONTACT           CONSTANT VARCHAR2(200) := 'OKX_PCONTACT';
G_JTF_BILLTO		        CONSTANT VARCHAR2(200) := 'OKX_BILLTO';
G_JTF_COUNTER                   CONSTANT VARCHAR2(200) := 'OKX_COUNTER';
G_JTF_USAGE                     CONSTANT VARCHAR2(200) := 'OKX_USAGE';
G_JTF_SHIPTO		        CONSTANT VARCHAR2(200) := 'OKX_SHIPTO';
G_JTF_ARL		        CONSTANT VARCHAR2(200) := 'OKX_ACCTRULE';
G_JTF_IRE		        CONSTANT VARCHAR2(200) := 'OKX_INVRULE';
G_JTF_CUSTPROD	                CONSTANT VARCHAR2(200) := 'OKX_CUSTPROD';
G_JTF_CUSTACCT	                CONSTANT VARCHAR2(200) := 'OKX_CUSTACCT';
G_JTF_PRICE                     CONSTANT VARCHAR2(200) := 'OKX_PRICE';
G_JTF_PAYMENT_TERM              CONSTANT VARCHAR2(200) := 'OKX_RPAYTERM';
G_JTF_CONV_TYPE                 CONSTANT VARCHAR2(200) := 'OKX_CONVTYPE';
G_JTF_TAXEXEMP  		CONSTANT VARCHAR2(200) := 'OKX_TAXEXEMP';
G_JTF_TAXCTRL  		        CONSTANT VARCHAR2(200) := 'OKX_TAXCTRL';
----

Type Header_Rec_Type Is Record
(
      contract_number	      Varchar2(120)
,     start_date	      Date
,     end_date		      Date
,     sts_code		      Varchar2(30)
,     scs_code		      Varchar2(30)
,     authoring_org_id	      Number
,     short_description       Varchar2(1995)
,     chr_group               Number
,     pdf_id                  Number
,     party_id                Number
,     bill_to_id	      Number
,     ship_to_id	      Number
,     price_list_id           Number
,     cust_po_number	      Varchar2(240)
,     agreement_id	      Number
,     currency		      Varchar2(15)
,     accounting_rule_type      Number
,     invoice_rule_type	      Number
,     order_hdr_id	      Number
,     payment_term_id         Number
,     cvn_type                Varchar2(25)
,     cvn_rate                Number
,     cvn_date                Date
,     cvn_euro_rate           Number
,     tax_exemption_id        Number
,     qto_contact_id          Number
,     qto_email_id          Number
,     qto_phone_id          Number
,     qto_fax_id          Number
,     qto_site_id          Number
,     contact_id            Number
,     tax_status_flag         Varchar2(30)
,     third_party_role        Varchar2(30)
,     merge_type              Varchar2(10) --'NEW'
,     merge_object_id         Number       -- 'NULL'
,     renewal_type            Varchar2(3) --'NSR/SFA/DNR/EVN'
,     renewal_pricing_type    Varchar2(3) --'LST/PCT/MAN'
,     renewal_price_list_id   Number
,     renewal_markup          Number
,     renewal_po              Varchar2(1) --'Y/N'
,     estimate_percent        Number
,     estimate_duration       Number
,     estimate_period         Varchar2(25)
,     Credit_card_no          VARCHAR2(40)
,     Expiry_date             DATE
,     Organization_id         NUMBER
,     Ar_interface_yn         VARCHAR2(1)
,     transaction_type        VARCHAR2(40)
,     Summary_invoice_yn      VARCHAR2(1)
,     rve_percent             VARCHAR2(40)
,     rve_end_date            DATE
,     qcl_id                  NUMBER
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

Type Counter_Type Is  Record
(
    usage_item_id          Number
,   counter_id             Number
);
Type Counter_tbl is TABLE of Counter_type index by binary_integer;

Type Contact_Type Is  Record
(
     party_role               Varchar2(30)
,    contact_role             Varchar2(30)
,    contact_object_code      Varchar2(30)
,    contact_id               Number
);
Type Contact_tbl is TABLE of Contact_type index by binary_integer;

Type SalesCredit_Type Is  Record
(
     ctc_id                   Number
,    sales_credit_type_id     Number
,    percent                  Number
);
Type SalesCredit_tbl is TABLE of SalesCredit_type index by binary_integer;

Type line_Rec_Type Is Record
(
     k_hdr_id		        Number
,    k_line_number	        Varchar2(150)
,    line_sts_code          Varchar2(30)
,    cust_account           Number
,    org_id		            Number
,    organization_id        NUMBER
,    bill_to_id		    Number
,    ship_to_id		    Number
,    order_line_id	    Number
,    accounting_rule_type   Number
,    invoicing_rule_type    Number
,    line_type        	    VARCHAR(2)     ---E,U.W,S,SB,SU
,    currency		    Varchar2(15)
,    list_price              Number
,    negotiated_amount	     Number
,    reason_code            Varchar2(30)
,    reason_comments        Varchar2(1995)
,    line_renewal_type      Varchar2(3) -- 'FUL/KEP/DNR'
,    usage_type             VARCHAR2(30)
,    usage_period           Varchar2(30)
,    tax_exemption_id        Number
,    tax_status_flag         Varchar2(30)
,    customer_product_id    Number
,    ATTRIBUTE1             VARCHAR2(450)
,    ATTRIBUTE2             VARCHAR2(450)
,    ATTRIBUTE3             VARCHAR2(450)
,    ATTRIBUTE4             VARCHAR2(450)
,    ATTRIBUTE5             VARCHAR2(450)
,    ATTRIBUTE6             VARCHAR2(450)
,    ATTRIBUTE7             VARCHAR2(450)
,    ATTRIBUTE8             VARCHAR2(450)
,    ATTRIBUTE9             VARCHAR2(450)
,    ATTRIBUTE10            VARCHAR2(450)
,    ATTRIBUTE11            VARCHAR2(450)
,    ATTRIBUTE12            VARCHAR2(450)
,    ATTRIBUTE13            VARCHAR2(450)
,    ATTRIBUTE14            VARCHAR2(450)
,    ATTRIBUTE15            VARCHAR2(450)


,    customer_id	    NUMBER
,    cp_status_id	    NUMBER
,    start_date_active	    DATE
,    end_date_active	    DATE
--,    misc_order_info	     OrderInfo_Rec_Type
--,    misc_return_info		ReturnInfo_Rec_Type
,    quantity		    NUMBER
,    uom_code		    VARCHAR2(25)
,    net_amount		    NUMBER
,    currency_code	    VARCHAR2(15)
,    po_number		    VARCHAR2(50)
,    delivered_flag	    VARCHAR2(1)
,    shipped_flag	    VARCHAR2(1)
,    cp_type		    VARCHAR2(30)
,    system_id		    NUMBER
,    prod_agreement_id		NUMBER
,    ship_to_site_use_id	NUMBER
,    bill_to_site_use_id	NUMBER
,    install_site_use_id	NUMBER
,    installation_date		DATE
,    srv_id                 NUMBER
,    srv_sdt                DATE
,    srv_edt                DATE
,    srv_desc               VARCHAR2(1995)
--,    config_type		VARCHAR2(30)    --not req
--,    config_start_date	DATE            --not req
--,    config_parent_cp_id	NUMBER          --not req
--,    project_id			NUMBER          --not req
--,    task_id			NUMBER          --not req
--,    platform_version_id	NUMBER		 --not req
--,    customer_view_flag	VARCHAR2(1)	 --not req 'N'
--,    merchant_view_flag	VARCHAR2(1)	 --not req 'Y'
--,    desc_flex			DFF_Rec_Type -- null
--,    price_attribs		PRICE_ATT_Rec_Type
,    shipped_date			DATE
,    ship_to_contact_id       NUMBER
,    invoice_to_contact_id    NUMBER
,    expired_flag             VARCHAR2(1)
,    customer_product_status_id     NUMBER
,    split_flag               VARCHAR2(1)
,    returned_quantity        NUMBER
,    LOCATION_TYPE_CODE       VARCHAR2(30)
,    LOCATION_ID              NUMBER
,    INV_ORGANIZATION_ID      NUMBER
,    INV_SUBINVENTORY_NAME    VARCHAR2(10)
,    INV_LOCATOR_ID           NUMBER
,    PA_PROJECT_ID            NUMBER
,    PA_PROJECT_TASK_ID       NUMBER
,    IN_TRANSIT_ORDER_LINE_ID NUMBER
,    WIP_JOB_ID               NUMBER
,    PO_ORDER_LINE_ID         NUMBER
--,    commitment_id            NUMBER --to be added
) ;

Type Covered_level_Rec_Type Is Record
(
     k_id		     Number
,    Attach_2_Line_id	     Number
,    line_number	     Varchar2(150)
,    product_sts_code        Varchar2(30)
,    Customer_Product_Id     Number   --either cp id or counter id
,    Product_Desc	     Varchar2(440)
,    Product_Start_Date	     Date
,    Product_End_Date	     Date
,    Quantity		     Number
,    settlement_flag         varchar2(450)
,    average_bill_flag       Varchar2(450)
,    Uom_Code                Varchar2(3)
,    list_price              Number
,    negotiated_amount	     Number
,    currency_code           Varchar2(15)
,    reason_code             Varchar2(30)
,    reason_comments         Varchar2(1995)
,    line_renewal_type       Varchar2(3) -- 'FUL/KEP/DNR'
,    minimum_qty            VARCHAR2(30)
,    default_qty            VARCHAR2(30)
,    period                 Varchar2(30)  -- should be the same as usage_period at line level else errors out
,    amcv_flag              VARCHAR2(30)
,    fixed_qty              VARCHAR2(30)
,    level_yn               VARCHAR2(30)
,    base_reading           VARCHAR2(30)
,    invoice_print_flag     Varchar2(1)
,    ATTRIBUTE1              VARCHAR2(450)
,    ATTRIBUTE2              VARCHAR2(450)
,    ATTRIBUTE3              VARCHAR2(450)
,    ATTRIBUTE4              VARCHAR2(450)
,    ATTRIBUTE5              VARCHAR2(450)
,    ATTRIBUTE6              VARCHAR2(450)
,    ATTRIBUTE7              VARCHAR2(450)
,    ATTRIBUTE8              VARCHAR2(450)
,    ATTRIBUTE9              VARCHAR2(450)
,    ATTRIBUTE10             VARCHAR2(450)
,    ATTRIBUTE11             VARCHAR2(450)
,    ATTRIBUTE12             VARCHAR2(450)
,    ATTRIBUTE13             VARCHAR2(450)
,    ATTRIBUTE14             VARCHAR2(450)
,    ATTRIBUTE15             VARCHAR2(450)
);

Type Suspend_rec Is Record
(
 Customer_id    Number
,Subscription_id Number
);

TYPE obj_articles_rec IS RECORD
(
 name           VARCHAR2(150)
,subject_code   VARCHAR2(150)
,full_text_yn   VARCHAR2(3)
);

Type obj_articles_tbl is TABLE of obj_articles_rec index by binary_integer;


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


Procedure create_contract
(
      p_K_header_rec                   IN  OKS_CONTRACTS_PUB.header_rec_type
,     p_header_contacts_tbl            IN  OKS_CONTRACTS_PUB.contact_tbl
,     p_header_sales_crd_tbl           IN  OKS_CONTRACTS_PUB.SalesCredit_tbl
,     p_header_articles_tbl            IN  OKS_CONTRACTS_PUB.obj_articles_tbl
,     p_K_line_rec                     IN  OKS_CONTRACTS_PUB.line_rec_type
,     p_line_contacts_tbl              IN  OKS_CONTRACTS_PUB.contact_tbl
,     p_line_sales_crd_tbl             IN  OKS_CONTRACTS_PUB.SalesCredit_tbl
,     p_K_Support_rec                  IN  OKS_CONTRACTS_PUB.line_rec_type
,     p_Support_contacts_tbl           IN  OKS_CONTRACTS_PUB.contact_tbl
,     p_Support_sales_crd_tbl          IN  OKS_CONTRACTS_PUB.SalesCredit_tbl
--,     p_line_articles_tbl            IN  OKS_CONTRACTS_PUB.line_articles_tbl
,     p_K_covd_rec                     IN  OKS_CONTRACTS_PUB.Covered_level_Rec_Type
,     p_price_attribs_in               IN  OKS_CONTRACTS_PUB.pricing_attributes_type
,     p_merge_rule                     IN  Varchar2
,     p_usage_instantiate              IN  Varchar2
,     p_ib_creation                    IN  Varchar2
,     p_billing_sch_type               IN  Varchar2
,     p_strm_level_tbl                 IN  OKS_BILL_SCH.StreamLvl_tbl
,     x_chrid                          OUT NOCOPY Number
,     x_return_status	               OUT NOCOPY Varchar2
,     x_msg_count                      OUT NOCOPY Number
,     x_msg_data                       OUT NOCOPY Varchar2
);



/*Procedure Update_contract
(
      p_K_header_rec            IN  OKS_CONTRACTS_PUB.header_rec_type
,     p_header_contacts_tbl     IN  OKS_CONTRACTS_PUB.contact_tbl
,     p_header_sales_crd_tbl    IN  OKS_CONTRACTS_PUB.SalesCredit_tbl
--,     p_header_articles_tbl     IN  OKS_CONTRACTS_PUB.obj_articles_tbl
,     p_K_line_rec              IN  OKS_CONTRACTS_PUB.line_rec_type
,     p_line_contacts_tbl       IN  OKS_CONTRACTS_PUB.contact_tbl
,     p_line_sales_crd_tbl      IN  OKS_CONTRACTS_PUB.SalesCredit_tbl
--,     p_line_articles_tbl       IN  OKS_CONTRACTS_PUB.line_articles_tbl
,     p_K_covd_rec              IN  OKS_CONTRACTS_PUB.Covered_level_Rec_Type
,     x_chrid                   OUT Number
,     x_return_status	        OUT Varchar2
,     x_msg_count               OUT Number
,     x_msg_data                OUT Varchar2
);



Procedure suspend_subscription
(       p_api_version                  IN  NUMBER,
        p_init_msg_list                IN  VARCHAR2 ,
        x_return_status                OUT NOCOPY VARCHAR2,
        x_msg_count                    OUT NOCOPY NUMBER,
        x_msg_data                     OUT NOCOPY VARCHAR2,
        p_suspend_rec                  IN  OKS_CONTRACTS_PUB.suspend_rec,
        p_do_commit                    IN  VARCHAR2
);


Procedure  reactivate_subscription
(       p_api_version                  IN  NUMBER,
        p_init_msg_list                IN  VARCHAR2 ,
        x_return_status                OUT NOCOPY VARCHAR2,
        x_msg_count                    OUT NOCOPY NUMBER,
        x_msg_data                     OUT NOCOPY VARCHAR2,
        p_reactivate_rec               IN  OKS_CONTRACTS_PUB.suspend_rec,
        p_do_commit                    IN  VARCHAR2
);*/

Procedure Create_Covered_Line(
      p_k_covd_rec		    IN	  Covered_level_Rec_Type
,     p_PRICE_ATTRIBS               IN    Pricing_attributes_Type
,     x_cp_line_id                  OUT NOCOPY  NUMBER
,     x_return_status		    OUT	NOCOPY  Varchar2
,     x_msg_count                   OUT NOCOPY  Number
,     x_msg_data                    OUT NOCOPY  Varchar2
);

Procedure Create_Service_Line
(
 p_k_line_rec          IN     line_Rec_Type
,p_Contact_tbl         IN     Contact_Tbl
,p_line_sales_crd_tbl  IN     SalesCredit_Tbl
,x_service_line_id     OUT NOCOPY    Number
,x_return_status       OUT NOCOPY  Varchar2
,x_msg_count           OUT NOCOPY   Number
,x_msg_data            OUT NOCOPY   Varchar2
);

Procedure Create_Contract_Header
(
      p_K_header_rec                   IN  OKS_CONTRACTS_PUB.header_rec_type
,     p_header_contacts_tbl            IN  OKS_CONTRACTS_PUB.contact_tbl
,     p_header_sales_crd_tbl           IN  OKS_CONTRACTS_PUB.SalesCredit_tbl
,     p_header_articles_tbl            IN  OKS_CONTRACTS_PUB.obj_articles_tbl
,     x_chrid                          OUT NOCOPY Number
,     x_return_status	               OUT NOCOPY VARCHAR2
,     x_msg_count                      OUT NOCOPY Number
,     x_msg_data                       OUT NOCOPY VARCHAR2
);

/*************NOTE: MAPPING FOR THE FIELDS FOR BLIILING SCHEDULE

---mapping for SLH
common name          filed name
line id              Cle_Id           --required
stream_type_id1      Object1_Id1
stream_type_id2      Object1_Id2
stream_tp_code       Jtot_Object1_Code
slh_timeval_id1      Object2_Id1
slh_timeval_id2      Object2_Id2
slh_timeval_code     Jtot_Object2_Code
Bill_type            Rule_Information1     --required
                     Rule_Information_Category     ('SLH') --REQUIRED

----FOR SLL RULE TABLE
  Mapping of fields for SLL rules


   seq_no                 - RULE_INFORMATION1   --required
   Date start             - RULE_INFORMATION2
   level_period           - RULE_INFORMATION3   --required
   tuom_per_period        - RULE_INFORMATION4   --required
   tuomcode               - OBJECT1_ID1         --required
   amount                 - RULE_INFORMATION6  -- for Bill_type = 'T' NOT required for 'E' & 'P' required.
   action_offset_days     - RULE_INFORMATION7
   interface_offset_days  - RULE_INFORMATION8
   comments               - RULE_INFORMATION9
   due arr yn             - RULE_INFORMATION10
   amount actual yn       - RULE_INFORMATION11
   Lines detailed yn      - RULE_INFORMATION12

---
p_invoice_rule_id               --- whatever is given for header record
*******************************************/

Procedure Create_Bill_Schedule(p_billing_sch         IN	   Varchar2,
                               p_strm_level_tbl      IN    OKS_BILL_SCH.StreamLvl_tbl,
                               p_invoice_rule_id     IN    Number,
                               x_return_status       OUT NOCOPY  VARCHAR2
);

/*dummy procedure created for OKL */
Procedure Create_Bill_Schedule(p_Strm_hdr_rec        IN	   OKS_BILL_SCH.StreamHdr_Type,
                               p_strm_level_tbl      IN    OKS_BILL_SCH.StreamLvl_tbl,
                               p_invoice_rule_id     IN    Number,
                               x_return_status       OUT NOCOPY  VARCHAR2
);

END OKS_CONTRACTS_PUB;


 

/
