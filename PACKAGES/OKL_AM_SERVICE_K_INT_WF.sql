--------------------------------------------------------
--  DDL for Package OKL_AM_SERVICE_K_INT_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_AM_SERVICE_K_INT_WF" AUTHID CURRENT_USER AS
/* $Header: OKLRKWFS.pls 115.1 2003/12/24 01:12:23 rmunjulu noship $ */


  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_INVALID_VALUE	    CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN	    CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
  G_UNEXPECTED_ERROR    CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN       CONSTANT VARCHAR2(200) := 'ERROR_MESSAGE';
  G_SQLCODE_TOKEN       CONSTANT VARCHAR2(200) := 'ERROR_CODE';
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_AM_SERVICE_K_INT_WF';
  G_APP_NAME			CONSTANT VARCHAR2(3)   := OKL_API.G_APP_NAME;
  G_APP_NAME_1          CONSTANT VARCHAR2(3)   := OKC_API.G_APP_NAME;
  G_RET_STS_UNEXP_ERROR CONSTANT VARCHAR2(1)   := OKL_API.G_RET_STS_UNEXP_ERROR;
  G_RET_STS_ERROR       CONSTANT VARCHAR2(1)   := OKL_API.G_RET_STS_ERROR;
  G_RET_STS_SUCCESS     CONSTANT VARCHAR2(1)   := OKL_API.G_RET_STS_SUCCESS;
  G_API_VERSION         CONSTANT NUMBER        := 1;
  G_MISS_CHAR           CONSTANT VARCHAR2(1)   := OKL_API.G_MISS_CHAR;
  G_MISS_NUM            CONSTANT NUMBER        := OKL_API.G_MISS_NUM;
  G_MISS_DATE           CONSTANT DATE          := OKL_API.G_MISS_DATE;
  G_TRUE                CONSTANT VARCHAR2(1)   := OKL_API.G_TRUE;
  G_FALSE               CONSTANT VARCHAR2(1)   := OKL_API.G_FALSE;

  -- Rec Type and Tbl Type to store Asset Schedule details
  TYPE kle_rec_type IS RECORD (
     asset_number        OKC_K_LINES_TL.name%TYPE,
     item_number         OKC_K_LINES_B.line_number%TYPE,
     item_description    OKC_K_LINES_TL.item_description%TYPE,
     install_base_number CSI_ITEM_INSTANCES.instance_number%TYPE,
     serial_number       CSI_ITEM_INSTANCES.serial_number%TYPE,
     asset_quantity      CSI_ITEM_INSTANCES.quantity%TYPE);

  TYPE kle_tbl_type IS TABLE OF kle_rec_type INDEX BY BINARY_INTEGER;

  ---------------------------------------------------------------------------
  -- PROCEDURES
  ---------------------------------------------------------------------------

  PROCEDURE get_assets_schedule (
                     p_kle_id              IN NUMBER,
                     x_asset_schedule_tbl  OUT NOCOPY kle_tbl_type);

  PROCEDURE get_assets_schedule (
                     p_khr_id               IN NUMBER,
                     p_quote_id             IN NUMBER,
                     x_asset_schedule_tbl   OUT NOCOPY kle_tbl_type);

  PROCEDURE raise_service_k_int_event (
                     p_transaction_id   IN VARCHAR2,
                     p_source           IN VARCHAR2,
                     p_quote_id         IN VARCHAR2 DEFAULT NULL,
                     p_oks_contract     IN VARCHAR2 DEFAULT NULL, --RMUNJULU 23-DEC-03 SERVICE K UPDATES
                     p_transaction_date IN DATE);

  PROCEDURE populate_attributes(
                     itemtype	IN  VARCHAR2,
                     itemkey  	IN  VARCHAR2,
                     actid		IN  NUMBER,
                     funcmode	IN  VARCHAR2,
                     resultout  OUT NOCOPY VARCHAR2);

  PROCEDURE pop_return_noti_dtls(
                     document_id    IN VARCHAR2,
                     display_type   IN VARCHAR2,
                     document       IN OUT NOCOPY VARCHAR2,
                     document_type  IN OUT NOCOPY VARCHAR2);

  PROCEDURE pop_dispose_noti_dtls(
                     document_id    IN VARCHAR2,
                     display_type   IN VARCHAR2,
                     document       IN OUT NOCOPY VARCHAR2,
                     document_type  IN OUT NOCOPY VARCHAR2);

  PROCEDURE pop_term_noti_dtls(
                     document_id    IN VARCHAR2,
                     display_type   IN VARCHAR2,
                     document       IN OUT NOCOPY VARCHAR2,
                     document_type  IN OUT NOCOPY VARCHAR2);

  PROCEDURE pop_delink_err_noti_dtls(
                     document_id    IN VARCHAR2,
                     display_type   IN VARCHAR2,
                     document       IN OUT NOCOPY VARCHAR2,
                     document_type  IN OUT NOCOPY VARCHAR2);

  PROCEDURE pop_delink_noti_dtls(
                     document_id    IN VARCHAR2,
                     display_type   IN VARCHAR2,
                     document       IN OUT NOCOPY VARCHAR2,
                     document_type  IN OUT NOCOPY VARCHAR2);

  PROCEDURE check_source(
                     itemtype	IN  VARCHAR2,
                     itemkey  	IN  VARCHAR2,
                     actid		IN  NUMBER,
                     funcmode	IN  VARCHAR2,
                     resultout OUT NOCOPY VARCHAR2);

END OKL_AM_SERVICE_K_INT_WF;

 

/
