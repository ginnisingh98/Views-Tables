--------------------------------------------------------
--  DDL for Package OKL_BPD_TERMINATION_ADJ_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_BPD_TERMINATION_ADJ_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRBAJS.pls 120.4 2005/09/23 12:17:55 varangan noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------

  --define input record type
  TYPE input_rec_type IS RECORD (
    khr_id                         NUMBER ,
    kle_id                         NUMBER ,
    term_date_from                 OKL_STRM_ELEMENTS.STREAM_ELEMENT_DATE%TYPE,
    term_date_to                   OKL_STRM_ELEMENTS.STREAM_ELEMENT_DATE%TYPE
    );

  g_miss_input_rec                 input_rec_type;

  TYPE input_tbl_type IS TABLE OF input_rec_type
        INDEX BY BINARY_INTEGER;

  --define Adjusment record type
  TYPE baj_rec_type IS RECORD (
    khr_id                         NUMBER ,
    kle_id                         NUMBER ,
    stream_element_date            OKL_STRM_ELEMENTS.STREAM_ELEMENT_DATE%TYPE,
    sel_id                         NUMBER,
    stm_id                         NUMBER,
    sty_id                         NUMBER ,
    sty_name                       OKL_STRM_TYPE_V.NAME%TYPE,
    amount                         NUMBER,
    se_line_number                 OKL_STRM_ELEMENTS.SE_LINE_NUMBER%TYPE,
    source_id			                 NUMBER,
    source_table 		               OKL_STRM_ELEMENTS.SOURCE_TABLE%TYPE
    );

  g_miss_baj_rec                   baj_rec_type;

  TYPE baj_tbl_type IS TABLE OF baj_rec_type
        INDEX BY BINARY_INTEGER;

  -- for rebook adj type by fmiao
  SUBTYPE rebook_adj_tbl IS OKL_REBOOK_CM_PVT.rebook_adj_tbl_type;
  SUBTYPE disb_rec_type  IS OKL_PAY_INVOICES_DISB_PVT.disb_rec_type;
  -- end  rebook adj type by fmiao

  ------------------------------------------------------------------------------
  -- Global Variables
  ------------------------------------------------------------------------------
  G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_BPD_TERMINATION_ADJ_PVT';
  G_APP_NAME             CONSTANT VARCHAR2(3)   := 'OKL';
  G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLERRM';
  G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLCODE';

  ------------------------------------------------------------------------------
   --Global Exception
  ------------------------------------------------------------------------------
   G_EXCEPTION_HALT_VALIDATION	EXCEPTION;

  FUNCTION get_kle_status_code(p_kle_id IN NUMBER) RETURN VARCHAR2;
  PRAGMA RESTRICT_REFERENCES(get_kle_status_code, WNDS);

  --return billing adjustment amount, stream type, and Asset Id from
  --termination date (for prior dated termination)
  PROCEDURE get_billing_adjust(
     p_api_version              IN NUMBER,
     p_init_msg_list            IN VARCHAR2 DEFAULT okl_api.G_FALSE,
     p_input_tbl                IN input_tbl_type,
     x_baj_tbl                  OUT NOCOPY baj_tbl_type,
     x_return_status            OUT NOCOPY VARCHAR2,
     x_msg_count                OUT NOCOPY NUMBER,
     x_msg_data                 OUT NOCOPY VARCHAR2);

  --return future billing amount, stream type, and Asset Id from
  --termination date (for future dated termination)
  PROCEDURE get_unbilled_recvbl(
     p_api_version              IN NUMBER,
     p_init_msg_list            IN VARCHAR2 DEFAULT okl_api.G_FALSE,
     p_input_tbl                IN input_tbl_type,
     x_baj_tbl                  OUT NOCOPY baj_tbl_type,
     x_return_status            OUT NOCOPY VARCHAR2,
     x_msg_count                OUT NOCOPY NUMBER,
     x_msg_data                 OUT NOCOPY VARCHAR2);

  --return unbilled estimated property tax amount
  PROCEDURE get_unbilled_prop_tax(
     p_api_version              IN NUMBER,
     p_init_msg_list            IN VARCHAR2 DEFAULT okl_api.G_FALSE,
     p_input_tbl                IN input_tbl_type,
     x_baj_tbl                  OUT NOCOPY baj_tbl_type,
     x_return_status            OUT NOCOPY VARCHAR2,
     x_msg_count                OUT NOCOPY NUMBER,
     x_msg_data                 OUT NOCOPY VARCHAR2);


  --create adjustments of passthru from the termination date
  PROCEDURE create_passthru_adj(
     p_api_version              IN NUMBER,
     p_init_msg_list            IN VARCHAR2 DEFAULT okl_api.G_FALSE,
     p_baj_tbl                  IN baj_tbl_type,
     x_return_status            OUT NOCOPY VARCHAR2,
     x_msg_count                OUT NOCOPY NUMBER,
     x_msg_data                 OUT NOCOPY VARCHAR2);


  --interface between rebook api and bpd processing apis by fmiao
  PROCEDURE create_rbk_passthru_adj(
     p_api_version              IN NUMBER,
     p_init_msg_list            IN VARCHAR2 DEFAULT okl_api.G_FALSE,
     p_rebook_adj_tbl           IN rebook_adj_tbl,
	 x_disb_rec					OUT NOCOPY disb_rec_type,
     x_return_status            OUT NOCOPY VARCHAR2,
     x_msg_count                OUT NOCOPY NUMBER,
     x_msg_data                 OUT NOCOPY VARCHAR2);


END OKL_BPD_TERMINATION_ADJ_PVT;

 

/
