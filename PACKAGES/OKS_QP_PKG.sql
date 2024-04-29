--------------------------------------------------------
--  DDL for Package OKS_QP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_QP_PKG" AUTHID CURRENT_USER AS
/* $Header: OKSRAQPS.pls 120.2.12000000.1 2007/01/16 22:09:04 appldev ship $ */

G_REQUIRED_VALUE       CONSTANT VARCHAR2(200) := OKC_API.G_REQUIRED_VALUE;
G_INVALID_VALUE        CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
G_COL_NAME_TOKEN       CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
G_PARENT_TABLE_TOKEN   CONSTANT VARCHAR2(200) := OKC_API.G_PARENT_TABLE_TOKEN;
G_CHILD_TABLE_TOKEN    CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;
G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKS_UNEXPECTED_ERROR';
G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'ERROR_MESSAGE';
G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'ERROR_CODE';
G_UPPERCASE_REQUIRED   CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UPPERCASE_REQD';
G_QP_ENGINE_ERROR      CONSTANT VARCHAR2(200) := 'OKS_QP_ENGINE_API_ERROR';


------------------------------------------------------------------------------------

  -- GLOBAL EXCEPTION

---------------------------------------------------------------------------

G_EXCEPTION_HALT_VALIDATION     EXCEPTION;
G_BUILD_RECORD_FAILED           EXCEPTION;
G_REQUIRED_ATTR_FAILED          EXCEPTION;
G_CALL_QP_FAILED                EXCEPTION;

--  Global constant holding the package name

G_PKG_NAME              CONSTANT VARCHAR2(30) := 'OKS_QP_PKG';
G_APP_NAME              CONSTANT VARCHAR2(3) := 'OKS';


G_LIST_CONTEXT          CONSTANT VARCHAR2(30) := 'MODLIST';
G_LIST_PRICE_ATTR       CONSTANT VARCHAR2(30) := 'QUALIFIER_ATTRIBUTE4';
G_LIST_MODIFIER_ATTR    CONSTANT VARCHAR2(30) := 'QUALIFIER_ATTRIBUTE6';

G_ITEM_CONTEXT          CONSTANT VARCHAR2(30) := 'ITEM';
G_ITEM_ATTR             CONSTANT VARCHAR2(30) := 'PRICING_ATTRIBUTE1';

G_VOLUME_CONTEXT        CONSTANT VARCHAR2(30) := 'VOLUME';
G_VOLUME_ATTR           CONSTANT VARCHAR2(30) := 'PRICING_ATTRIBUTE1';

G_REQUEST_TYPE_CODE     CONSTANT VARCHAR2(30) := 'ASO';
--G_PRICING_EVENT         CONSTANT VARCHAR2(30) := 'PRICE';
--9/25 Changed to
G_PRICING_EVENT         CONSTANT VARCHAR2(30) := 'LINE';

G_LINE_TYPE             CONSTANT VARCHAR2(30) := 'SERVICE CONTRACT LINE';
G_CONTROL_REC		QP_PREQ_GRP.CONTROL_RECORD_TYPE;


G_JTF_Party        CONSTANT  VARCHAR2(30)  := 'OKX_PARTY';
G_JTF_Covlvl       CONSTANT  VARCHAR2(30)  := 'OKX_COVSYST';
G_JTF_Custacct     CONSTANT  VARCHAR2(30)  := 'OKX_CUSTACCT';
G_JTF_CusProd      CONSTANT  VARCHAR2(40)  := 'OKX_CUSTPROD';

--G_JTF_Sysitem    CONSTANT  VARCHAR2(30)  := 'X_
G_JTF_Billto       CONSTANT  VARCHAR2(30)  := 'OKX_BILLTO';
G_JTF_Shipto       CONSTANT  VARCHAR2(30)  := 'OKX_SHIPTO';
G_JTF_Warr         CONSTANT  VARCHAR2(30)  := 'OKX_WARRANTY';
G_JTF_Extwar       CONSTANT  VARCHAR2(30)  := 'OKX_SERVICE';


G_JTF_usage        CONSTANT  VARCHAR2(30)  := 'OKX_USAGE';
G_JTF_service      CONSTANT  VARCHAR2(30)  := 'OKX_SERVICE';

G_JTF_Invrule      CONSTANT  VARCHAR2(30)  := 'OKX_INVRULE';
G_JTF_Acctrule     CONSTANT  VARCHAR2(30)  := 'OKX_ACCTRULE';
G_JTF_Payterm      CONSTANT  VARCHAR2(30)  := 'OKX_PPAYTERM';
G_JTF_Price        CONSTANT  VARCHAR2(30)  := 'OKX_PRICE';

TYPE G_PRICE_BREAK_REC_TYPE IS RECORD
(
      quantity_from  	NUMBER,
      quantity_to		NUMBER,
      list_price		NUMBER,
      break_method	VARCHAR2(10),
      break_uom_code            VARCHAR2(3),  /* Proration*/
      break_uom_context         VARCHAR2(30), /* Proration*/
      break_uom_attribute       VARCHAR2(30),  /* Proration*/
      unit_price        NUMBER,
      quantity          NUMBER,
      Amount            NUMBER
);

TYPE G_PRICE_BREAK_TBL_TYPE is TABLE OF G_PRICE_BREAK_REC_TYPE INDEX BY BINARY_INTEGER;


TYPE PRICE_DETAILS IS RECORD
(
      PROD_QTY                NUMBER,
      PROD_QTY_UOM            VARCHAR2(30),
      SERV_QTY                NUMBER,
      SERV_QTY_UOM            VARCHAR2(30),
      PROD_PRICE_LIST_ID      VARCHAR2(40),
      SERV_PRICE_LIST_ID      VARCHAR2(40),
      PROD_PRICE_LIST_LINE_ID VARCHAR2(40),
      SERV_PRICE_LIST_LINE_ID VARCHAR2(40),
      PROD_LIST_UNIT_PRICE    NUMBER,
      SERV_LIST_UNIT_PRICE    NUMBER,
      PROD_ADJ_UNIT_PRICE     NUMBER,
      SERV_ADJ_UNIT_PRICE     NUMBER,
      PROD_PRICED_QTY         NUMBER,
      PROD_PRICED_UOM         VARCHAR2(30),
      PROD_EXT_AMOUNT         NUMBER,
      SERV_PRICED_QTY         NUMBER,
      SERV_PRICED_UOM         VARCHAR2(30),
      SERV_EXT_AMOUNT         NUMBER,
      SERV_OPERAND            VARCHAR2(240),
      SERV_OPERATOR           VARCHAR2(240),
      STATUS_CODE             VARCHAR2(30),
      STATUS_TEXT             VARCHAR2(2000)
);

TYPE Input_details IS RECORD
(
      price_list                           Number,
      price_list_line_id                   Number,
      chr_id                               Number,
      line_id                              Number,
      subline_id                           Number,
      intent                               Varchar2(200),
      currency                             Varchar2(200),
      bcl_id                               Number,
      bsl_id                               Number,
      usage_qty                            Number,
      usage_uom_code                       Varchar2(200),
      break_uom_code                       Varchar2(200),
      proration_yn                         Varchar2(200),
      bill_from_date                       Date,
      bill_to_date                         Date,
      asking_unit_price                    Number
);

--  PROCEDURES

PROCEDURE CALC_PRICE
(
      p_detail_rec                   IN        Input_details,
      x_price_details               OUT NOCOPY Price_Details,
      x_modifier_details            OUT NOCOPY qp_preq_grp.line_detail_tbl_type,
      x_price_break_details         OUT NOCOPY g_price_break_tbl_type,
      x_return_status			OUT NOCOPY Varchar2,
      x_msg_count			      OUT NOCOPY Number,
      x_msg_data			      OUT NOCOPY Varchar2
);

Procedure Delete_locked_pricebreaks(
                                   p_api_version          IN NUMBER,
                                   p_list_line_id         IN NUMBER,
                                   p_init_msg_list        IN VARCHAR2,
                                   x_return_status        IN OUT NOCOPY VARCHAR2,
                                   x_msg_count            IN OUT NOCOPY NUMBER,
                                   x_msg_data             IN OUT NOCOPY VARCHAR2);

END;

 

/
