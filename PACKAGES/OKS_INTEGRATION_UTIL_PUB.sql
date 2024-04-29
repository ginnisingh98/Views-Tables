--------------------------------------------------------
--  DDL for Package OKS_INTEGRATION_UTIL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_INTEGRATION_UTIL_PUB" AUTHID CURRENT_USER AS
/* $Header: OKSRIUTS.pls 120.0 2005/05/25 18:32:12 appldev noship $ */

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
  G_JTF_SHIPTO		      CONSTANT VARCHAR2(200) := 'OKX_SHIPTO';
  G_JTF_ARL		            CONSTANT VARCHAR2(200) := 'OKX_ACCTRULE';
  G_JTF_IRE		            CONSTANT VARCHAR2(200) := 'OKX_INVRULE';
  G_JTF_CUSTPROD	            CONSTANT VARCHAR2(200) := 'OKX_CUSTPROD';
  G_JTF_CUSTACCT	            CONSTANT VARCHAR2(200) := 'OKX_CUSTACCT';
  G_JTF_PRICE                 CONSTANT VARCHAR2(200) := 'OKX_PRICE';
  G_JTF_PAYMENT_TERM          CONSTANT VARCHAR2(200) := 'OKX_PPAYTERM';
  G_JTF_CONV_TYPE             CONSTANT VARCHAR2(200) := 'OKX_CONVTYPE';

  ---------------------------------------------------------------------------


Procedure Create_K_Order_Details
(
      p_header_id	     IN     NUMBER
,     x_return_status	     OUT  NOCOPY  Varchar2
,     x_msg_count            OUT  NOCOPY  Number
,     x_msg_data             OUT  NOCOPY  Varchar2
);

-------------- Procedures for fixing date format ------------------------

PROCEDURE Get_Dates(p_from_id    IN   Number DEFAULT NULL,
                    p_to_id      IN   Number DEFAULT NULL
                    );

/**
PROCEDURE Convert_Dates(p_category_code IN VARCHAR2,
                        p_format        IN VARCHAR2,
                        p_date          IN VARCHAR2,
                        p_rule_num      IN NUMBER,
                        p_rule_id        IN NUMBER,
                        x_return_status OUT NOCOPY VARCHAR2,
                        x_msg_data      OUT NOCOPY VARCHAR2,
                        x_msg_count     OUT NOCOPY NUMBER
                        );
***/

Procedure Debug_Log(p_error_msg           IN VARCHAR2 DEFAULT NULL,
                    x_msg_data            OUT NOCOPY VARCHAR2,
                    x_msg_count           OUT NOCOPY NUMBER,
                    x_return_status       OUT NOCOPY VARCHAR2);

-- Added for performance tuning
procedure upgrade_rule_dates(x_return_status   out  NOCOPY  varchar2);

-- Added for performance tuning
function generate_ranges (
	p_lo number,
	p_hi number,
	p_avg number,
	p_stddev number,
	p_total number) return integer;

End OKS_INTEGRATION_UTIL_PUB;

 

/
