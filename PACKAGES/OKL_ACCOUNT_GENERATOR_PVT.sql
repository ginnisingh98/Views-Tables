--------------------------------------------------------
--  DDL for Package OKL_ACCOUNT_GENERATOR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_ACCOUNT_GENERATOR_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRAGTS.pls 120.5 2006/07/11 09:40:22 dkagrawa noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
-- Record type which holds the account generator rule lines.
TYPE acc_rul_lns_rec_type IS RECORD (
  id                    NUMBER := okc_api.g_miss_num,
  segment		OKL_ACC_GEN_RUL_LNS.segment%TYPE := okc_api.g_miss_char,
  segment_number	NUMBER := okc_api.g_miss_num,
  agr_id		NUMBER := okc_api.g_miss_num,
  source		OKL_ACC_GEN_RUL_LNS.source%TYPE := okc_api.g_miss_char,
  constants		OKL_ACC_GEN_RUL_LNS.constants%TYPE := okc_api.g_miss_char
 );

TYPE acc_rul_lns_tbl_type IS TABLE OF acc_rul_lns_rec_type INDEX BY BINARY_INTEGER;


-- Table type which holds the account generator source  related information

TYPE primary_key_rec IS RECORD
     (source_table 		okl_ag_source_maps.source%TYPE,
      primary_key_column 	VARCHAR2(100)
     );

TYPE primary_key_tbl IS TABLE OF primary_key_rec INDEX BY BINARY_INTEGER;

TYPE  acc_gen_wf_sources_rec IS RECORD
  (PRODUCT_ID             NUMBER    := OKL_API.G_MISS_NUM,
   TRANSACTION_TYPE_ID    NUMBER    := OKL_API.G_MISS_NUM,
   STREAM_TYPE_ID         NUMBER    := OKL_API.G_MISS_NUM,
   FACTORING_SYND_FLAG    OKL_AE_TEMPLATES.FACTORING_SYND_FLAG%TYPE := OKL_API.G_MISS_CHAR,
   SYNDICATION_CODE       OKL_AE_TEMPLATES.SYT_CODE%TYPE := OKL_API.G_MISS_CHAR,
   FACTORING_CODE         OKL_AE_TEMPLATES.FAC_CODE%TYPE := OKL_API.G_MISS_CHAR,
   INVESTOR_CODE         OKL_AE_TEMPLATES.INV_CODE%TYPE := OKL_API.G_MISS_CHAR,
   MEMO_YN                OKL_AE_TEMPLATES.MEMO_YN%TYPE := OKL_API.G_MISS_CHAR,
   REV_REC_FLAG 		  VARCHAR2(1) := 'N',
   SOURCE_ID                NUMBER                                 := OKL_API.G_MISS_NUM,
   SOURCE_TABLE             OKL_TRNS_ACC_DSTRS.SOURCE_TABLE%TYPE := OKL_API.G_MISS_CHAR,
   ACCOUNTING_DATE          OKL_TRNS_ACC_DSTRS.GL_DATE%TYPE      := OKL_API.G_MISS_DATE,
   CONTRACT_ID              NUMBER       := OKL_API.G_MISS_NUM,
   CONTRACT_LINE_ID         NUMBER       := OKL_API.G_MISS_NUM);

SUBTYPE error_message_type IS okl_accounting_util.error_message_type;


  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP			CONSTANT VARCHAR2(200) := Okl_Api.G_FND_APP;
  G_UNEXPECTED_ERROR		CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN		CONSTANT VARCHAR2(200) := 'OKL_SQLERRM';
  G_SQLCODE_TOKEN		CONSTANT VARCHAR2(200) := 'OKL_SQLCODE';
  G_AE_LINE_TYPE_TOKEN		CONSTANT VARCHAR2(200) := 'AE_LINE_TYPE';
  G_ACC_GEN_RULE_ID		CONSTANT VARCHAR2(200) := 'ACC_GEN_ RULE_ID';
  G_REQUIRED_VALUE              CONSTANT VARCHAR2(200) := OKL_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE               CONSTANT VARCHAR2(200) := OKL_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN              CONSTANT VARCHAR2(200) := OKL_API.G_COL_NAME_TOKEN;
  G_RET_STS_SUCCESS		CONSTANT VARCHAR2(1) 	:= OKL_API.G_RET_STS_SUCCESS;
  G_RET_STS_UNEXP_ERROR		CONSTANT VARCHAR2(1) 	:= OKL_API.G_RET_STS_UNEXP_ERROR;
  G_RET_STS_ERROR		CONSTANT VARCHAR2(1) 	:= OKL_API.G_RET_STS_ERROR;
  G_EXCEPTION_ERROR		EXCEPTION;
  G_EXCEPTION_UNEXPECTED_ERROR	EXCEPTION;


  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTION
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION  EXCEPTION;
  ---------------------------------------------------------------------------
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_ACCOUNT_GENERATOR_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  Okl_Api.G_APP_NAME;

  -------------------------------------------------------------------------------
  -- PACKAGE LEVEL GLOBAL VARIABLES
  -------------------------------------------------------------------------------
  G_GL_APP_SHORT_NAME 		CONSTANT VARCHAR2(10) 	:= 'SQLGL';
  G_ACC_KEY_FLEX_CODE 		CONSTANT VARCHAR2(3) 	:= 'GL#';


  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------
-- Main account generator function which is getting invoked from outside. This is the
-- interface for account generator.

-- Changed by Santonyr on 22-Sep-2004 to fix bug 3901209.
-- Added a new parameter 'p_ae_tmpt_line_id'.
-- If Account Generator fails due to lack of sources, it picks up the
-- default account code for the passed account template line and returns.

-- Changed the signature for bug 4157521

FUNCTION GET_CCID
(
  p_api_version          	IN NUMBER,
  p_init_msg_list        	IN VARCHAR2,
  x_return_status        	OUT NOCOPY VARCHAR2,
  x_msg_count            	OUT NOCOPY NUMBER,
  x_msg_data             	OUT NOCOPY VARCHAR2,
  p_acc_gen_wf_sources_rec     IN  acc_gen_wf_sources_rec,
  p_ae_line_type		IN okl_acc_gen_rules.ae_line_type%TYPE,
  p_primary_key_tbl		IN primary_key_tbl,
  p_ae_tmpt_line_id		IN NUMBER DEFAULT NULL
)
RETURN NUMBER;

END OKL_ACCOUNT_GENERATOR_PVT;

/
