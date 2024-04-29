--------------------------------------------------------
--  DDL for Package OKS_QP_INT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_QP_INT_PVT" AUTHID CURRENT_USER AS
/* $Header: OKSQPRQS.pls 120.1 2005/10/06 11:17:28 skekkar noship $ */

G_REQUIRED_VALUE       CONSTANT VARCHAR2(200) := OKC_API.G_REQUIRED_VALUE;
G_INVALID_VALUE        CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
G_COL_NAME_TOKEN       CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKS_UNEXPECTED_ERROR';
G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'ERROR_MESSAGE';
G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'ERROR_CODE';

G_RET_STS_SUCCESS      CONSTANT VARCHAR2(1)   :=  OKC_API.G_RET_STS_SUCCESS;
G_RET_STS_ERROR        CONSTANT VARCHAR2(1)   :=  OKC_API.G_RET_STS_ERROR;
G_RET_STS_UNEXP_ERROR  CONSTANT VARCHAR2(1)   :=  OKC_API.G_RET_STS_UNEXP_ERROR;
------------------------------------------------------------------------------------

  -- GLOBAL EXCEPTION

---------------------------------------------------------------------------

G_EXC_ERROR                     EXCEPTION;
G_EXC_UNEXPECTED_ERROR 	        EXCEPTION;
G_SKIP_EXCEPTION                EXCEPTION;
G_EXC_CANT_PRICE                EXCEPTION; --3912685

--  Global constant holding the package name

G_PKG_NAME              CONSTANT VARCHAR2(30) := 'OKS_QP_INT_PVT';
G_APP_NAME              CONSTANT VARCHAR2(3)  := 'OKS';

TYPE Pricing_Status_Rec IS RECORD
     (service_name         Varchar2(800),
      Coverage_Level_Name  Varchar2(240),
      status_code          Varchar2(10),
      status_text          Varchar2(2000));

TYPE Pricing_Status_Tbl IS TABLE OF Pricing_Status_Rec INDEX BY BINARY_INTEGER;

TYPE k_details_rec IS RECORD
     (id                     NUMBER,
      object_version_number  NUMBER);

TYPE price_modifiers_rec IS RECORD
     (discount               NUMBER,
      surcharge              NUMBER,
      total                  NUMBER
      );

TYPE price_modifiers_tbl IS TABLE OF price_modifiers_rec INDEX BY BINARY_INTEGER;

G_HEADER_PRICING        CONSTANT VARCHAR2(3) := 'HP';
G_TOP_LINE_PRICING      CONSTANT VARCHAR2(3) := 'LP';
G_SUB_LINE_PRICING      CONSTANT VARCHAR2(3) := 'SP';
G_OVERRIDE_PRICING      CONSTANT VARCHAR2(3) := 'OA';
G_SUBSC_REG_PRICING     CONSTANT VARCHAR2(4) := 'SB_P';
G_SUBSC_OVR_PRICING     CONSTANT VARCHAR2(4) := 'SB_O';

G_STS_TXT_SUCCESS       VARCHAR2(100); -- 'SUCCESS'
G_STS_TXT_ERROR         VARCHAR2(100); -- 'ERROR'
G_MANUAL_ADJ_PRICE      VARCHAR2(400); -- 'PRICE DERIVED BY MANUAL ADJUSTMENT'
G_BILLED_LINE           VARCHAR2(400); -- 'Line is billed and cannot be priced'; --3912685


G_OKS_SUCCESS           CONSTANT VARCHAR2(10)  := 'OKS_S';  --3912685
G_BILLED                CONSTANT VARCHAR2(10)  := 'OKS_B';  --3912685
G_FULLY_BILLED          CONSTANT VARCHAR2(10)  := 'OKS_FB'; --3912685
G_PARTIAL_BILLED        CONSTANT VARCHAR2(10)  := 'OKS_PB'; --3912685

G_STS_CODE_SUCCESS      CONSTANT VARCHAR2(1)  := 'S';
G_STS_CODE_ERROR        CONSTANT VARCHAR2(1)  := 'E';
G_HDR_LEVEL             CONSTANT VARCHAR2(4)  := 'HDR';
G_LINE_LEVEL            CONSTANT VARCHAR2(4)  := 'TL';

G_OKC_HDR               CONSTANT VARCHAR2(4)  := 'CHR';
G_OKC_LINE              CONSTANT VARCHAR2(4)  := 'CLE';
G_OKS_HDR               CONSTANT VARCHAR2(4)  := 'KHR';
G_OKS_LINE              CONSTANT VARCHAR2(4)  := 'KLE';

G_SERVICE               CONSTANT NUMBER := 1;
G_EXT_WARRANTY          CONSTANT NUMBER := 19;
G_SUBSCRIPTION          CONSTANT NUMBER := 46;
G_USAGE                 CONSTANT NUMBER := 12;

G_SERVICE_CP            CONSTANT NUMBER := 9;
G_SERVICE_CI            CONSTANT NUMBER := 7;

G_PRICING_STATUS_TBL    Pricing_Status_Tbl;
G_INDEX                 NUMBER;

PROCEDURE COMPUTE_PRICE
(
    p_api_version                 IN         NUMBER,
    p_init_msg_list               IN         VARCHAR2,
    p_detail_rec                  IN         OKS_QP_PKG.INPUT_DETAILS,
    x_price_details               OUT NOCOPY OKS_QP_PKG.PRICE_DETAILS,
    x_modifier_details            OUT NOCOPY QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE,
    x_price_break_details         OUT NOCOPY OKS_QP_PKG.G_PRICE_BREAK_TBL_TYPE,
    x_return_status               OUT NOCOPY VARCHAR2,
    x_msg_count                   OUT NOCOPY NUMBER,
    x_msg_data                    OUT NOCOPY VARCHAR2
);

FUNCTION GET_PRICING_MESSAGES RETURN PRICING_STATUS_TBL;

PROCEDURE GET_K_DETAILS (
                 p_id            IN         NUMBER,
                 p_type          IN         VARCHAR2,
                 x_k_det_rec     OUT NOCOPY k_details_rec
   );

PROCEDURE GET_MODIFIER_DETAILS (
                 p_api_version       IN         NUMBER,
                 p_init_msg_list     IN         VARCHAR2,
                 p_chr_id            IN         NUMBER,
                 p_cle_id            IN         VARCHAR2,
                 x_modifiers_tbl     OUT NOCOPY price_modifiers_tbl,
                 x_return_status     OUT NOCOPY VARCHAR2,
                 x_msg_count         OUT NOCOPY NUMBER,
                 x_msg_data          OUT NOCOPY VARCHAR2
   );

PROCEDURE QUALIFIER_PARTY_MERGE
(
     p_from_fk_id           IN  NUMBER,
     p_to_fk_id             IN  NUMBER,
     x_return_status        OUT NOCOPY VARCHAR2
);

PROCEDURE QUALIFIER_ACCOUNT_MERGE
(
        req_id                       NUMBER,
        set_num                      NUMBER
);

END OKS_QP_INT_PVT;

 

/
