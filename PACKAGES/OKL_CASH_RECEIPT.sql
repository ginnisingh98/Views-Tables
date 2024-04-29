--------------------------------------------------------
--  DDL for Package OKL_CASH_RECEIPT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CASH_RECEIPT" AUTHID CURRENT_USER AS
/* $Header: OKLRRTCS.pls 120.3 2007/08/02 15:51:02 nikshah ship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------

  SUBTYPE xcrv_rec_type IS Okl_Extrn_Pvt.xcrv_rec_type;
  SUBTYPE xcav_tbl_type IS Okl_Extrn_Pvt.xcav_tbl_type;

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------

  G_APP_NAME             CONSTANT   VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  G_UNEXPECTED_ERROR     CONSTANT   VARCHAR2(200) := 'OKL_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN        CONSTANT   VARCHAR2(200) := 'SQLERRM';
  G_SQLCODE_TOKEN        CONSTANT   VARCHAR2(200) := 'SQLCODE';

  G_PKG_NAME             CONSTANT   VARCHAR2(200) := 'OKL_CASH_RECEIPT';
  G_COL_NAME_TOKEN       CONSTANT   VARCHAR2(200) :=  OKL_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN   CONSTANT   VARCHAR2(200) :=  Okl_Api.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN    CONSTANT   VARCHAR2(200) :=  Okl_Api.G_CHILD_TABLE_TOKEN;
  G_NO_PARENT_RECORD     CONSTANT   VARCHAR2(200) := 'OKL_NO_PARENT_RECORD';
  G_INVALID_VALUE        CONSTANT   VARCHAR2(200) :=  OKC_API.G_INVALID_VALUE;
  G_REQUIRED_VALUE	     CONSTANT   VARCHAR2(200) :=  OKC_API.G_REQUIRED_VALUE;
  G_EXCEPTION_HALT_VALIDATION EXCEPTION;

  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------
  -- MODIFICATION HISTORY
  -- Person           Date        Comments
  -- --------------   ----------  ------------------------------------------
  -- Ajay Pimpariya   29-Oct-01   Creation.
  -- Bruno Vaghela    01-Nov-01   Modified to work.
  -- Bruno Vaghela    16-Mar-02   Included Currency Conversion.
  -- Bruno Vaghela    28-Oct-04   Addressed bug 3789514
  ---------------------------------------------------------------------------


   PROCEDURE CASH_RECEIPT( p_api_version      IN  NUMBER   := 1.0
                          ,p_init_msg_list    IN  VARCHAR2 := OKC_API.G_FALSE
                          ,x_return_status    OUT NOCOPY  VARCHAR2
                          ,x_msg_count        OUT NOCOPY  NUMBER
                          ,x_msg_data         OUT NOCOPY  VARCHAR2
                          ,p_over_pay         IN  VARCHAR2
                          ,p_conc_proc        IN  VARCHAR2
                          ,p_xcrv_rec         IN  xcrv_rec_type
                          ,p_xcav_tbl         IN  xcav_tbl_type
                          ,x_cash_receipt_id  OUT NOCOPY NUMBER
                         );

   PROCEDURE PAYMENT_RECEIPT( p_api_version   IN  NUMBER   := 1.0
                          ,p_init_msg_list    IN  VARCHAR2 := OKC_API.G_FALSE
                          ,x_return_status    OUT NOCOPY  VARCHAR2
                          ,x_msg_count        OUT NOCOPY  NUMBER
                          ,x_msg_data         OUT NOCOPY  VARCHAR2
                          ,p_over_pay         IN  VARCHAR2
                          ,p_conc_proc        IN  VARCHAR2
                          ,p_xcrv_rec         IN  xcrv_rec_type
                          ,p_xcav_tbl         IN  xcav_tbl_type
                          ,x_cash_receipt_id  OUT NOCOPY NUMBER
                         );

   PROCEDURE CREATE_RECEIPT( p_api_version      IN  NUMBER   := 1.0
                          ,p_init_msg_list    IN  VARCHAR2 := OKC_API.G_FALSE
                          ,x_return_status    OUT NOCOPY  VARCHAR2
                          ,x_msg_count        OUT NOCOPY  NUMBER
                          ,x_msg_data         OUT NOCOPY  VARCHAR2
                          ,p_rcpt_rec         IN  OKL_CASH_APPL_RULES.rcpt_rec_type
                          ,x_cash_receipt_id  OUT NOCOPY NUMBER
                         );
END OKL_CASH_RECEIPT; -- Package spec

/
