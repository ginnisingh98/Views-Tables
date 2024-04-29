--------------------------------------------------------
--  DDL for Package OKL_AM_TERMNT_QUOTE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_AM_TERMNT_QUOTE_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRTNQS.pls 120.3 2005/10/30 04:39:13 appldev noship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
  ---------------------------------------------------------------------------
  G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_AM_TERMNT_QUOTE_PVT';
  G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLcode';

  G_YES                  CONSTANT VARCHAR2(200) := 'Y';
  G_NO                   CONSTANT VARCHAR2(200) := 'N';
  G_TERM_QTE             CONSTANT VARCHAR2(200) := 'TERMINATE_QUOTE';
  G_FALSE                CONSTANT VARCHAR2(1)   :=  OKC_API.G_FALSE;
  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTIONS
  ---------------------------------------------------------------------------
  G_EXCEPTION_CANNOT_TERM_CNT EXCEPTION;

  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE qte_ln_dtl_rec IS RECORD (qst_code           OKL_TRX_QUOTES_B.QST_CODE%TYPE := OKL_API.G_MISS_CHAR,
                                 qte_id             OKL_TRX_QUOTES_B.ID%TYPE := OKL_API.G_MISS_NUM,
                                 instance_quantity  OKL_TXD_QUOTE_LINE_DTLS.NUMBER_OF_UNITS%TYPE,
                                 tql_id             OKL_TXL_QUOTE_LINES_B.ID%TYPE := OKL_API.G_MISS_NUM,
                                 tqd_id             OKL_TXD_QUOTE_LINE_DTLS.ID%TYPE := OKL_API.G_MISS_NUM,
                                 select_yn          VARCHAR2(3) := NULL,
                                 ib_line_id         OKC_K_LINES_B.ID%TYPE := OKL_API.G_MISS_NUM,
                                 fin_line_id        OKC_K_LINES_B.ID%TYPE := OKL_API.G_MISS_NUM,
                                 dnz_chr_id         OKC_K_LINES_B.DNZ_CHR_ID%TYPE := OKL_API.G_MISS_NUM);
  TYPE qte_ln_dtl_tbl IS TABLE OF qte_ln_dtl_rec
            INDEX BY BINARY_INTEGER;
  SUBTYPE term_rec_type IS OKL_TRX_QUOTES_PUB.qtev_rec_type;
  SUBTYPE term_tbl_type IS OKL_TRX_QUOTES_PUB.qtev_tbl_type;
  SUBTYPE clev_tbl_type IS OKL_OKC_MIGRATION_PVT.clev_tbl_type;

--  SUBTYPE term_rec_type IS OKL_QTE_PVT.qtev_rec_type;
--  SUBTYPE term_tbl_type IS OKL_QTE_PVT.qtev_tbl_type;
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  -- terminates the quote.
  -- checks if accepted_yn is set to 'Y' then calls the terminate contract
  --Bug #3921591: pagarg +++ Rollover +++
  -- additional parameter has been added to the call, to identify the acceptance source
  PROCEDURE terminate_quote(
    p_api_version                  	IN NUMBER,
    p_init_msg_list                	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                	OUT NOCOPY VARCHAR2,
    x_msg_count                    	OUT NOCOPY NUMBER,
    x_msg_data                     	OUT NOCOPY VARCHAR2,
    p_term_rec                      IN term_rec_type,
    x_term_rec                      OUT NOCOPY term_rec_type,
    x_err_msg                       OUT NOCOPY VARCHAR2,
    p_acceptance_source             IN  VARCHAR2 DEFAULT null);

  -- terminates the quote for a input of tbl type
  --Bug #3921591: pagarg +++ Rollover +++
  -- additional parameter has been added to the call, to identify the acceptance source
  PROCEDURE terminate_quote(
    p_api_version                  	IN NUMBER,
    p_init_msg_list                	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                	OUT NOCOPY VARCHAR2,
    x_msg_count                    	OUT NOCOPY NUMBER,
    x_msg_data                     	OUT NOCOPY VARCHAR2,
    p_term_tbl                      IN term_tbl_type,
    x_term_tbl                      OUT NOCOPY term_tbl_type,
    x_err_msg                       OUT NOCOPY VARCHAR2,
    p_acceptance_source             IN  VARCHAR2 DEFAULT null);

  -- calls send quote workflow
  PROCEDURE submit_for_approval(
    p_api_version                  	IN NUMBER,
    p_init_msg_list                	IN VARCHAR2 DEFAULT G_FALSE,
    x_return_status                	OUT NOCOPY VARCHAR2,
    x_msg_count                    	OUT NOCOPY NUMBER,
    x_msg_data                     	OUT NOCOPY VARCHAR2,
    p_term_rec                      IN term_rec_type,
    x_term_rec                      OUT NOCOPY term_rec_type);

  -- Checks If the given asset line is serialized or not
  FUNCTION check_asset_sno(p_asset_line IN OKL_K_LINES.ID%TYPE,
                           x_sno_yn     OUT NOCOPY VARCHAR2,
                           x_clev_tbl   OUT NOCOPY clev_tbl_type) RETURN VARCHAR2;

  --  Create records in Quote Line details after proper validation
  PROCEDURE quote_line_dtls(p_api_version      IN  NUMBER,
                            p_init_msg_list    IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                            x_return_status    OUT NOCOPY VARCHAR2,
                            x_msg_count        OUT NOCOPY NUMBER,
                            x_msg_data         OUT NOCOPY VARCHAR2,
                            p_qld_tbl          IN OUT NOCOPY qte_ln_dtl_tbl);


  -- RMUNJULU 23-DEC-02 2726739 Added 2 new Subtypes and 4 new procedures for
  -- inserting and updating quote lines table
  SUBTYPE tqlv_rec_type IS OKL_TXL_QUOTE_LINES_PUB.tqlv_rec_type;
  SUBTYPE tqlv_tbl_type IS OKL_TXL_QUOTE_LINES_PUB.tqlv_tbl_type;

  -- Creates quote line
  PROCEDURE create_quote_line(
               p_api_version    IN NUMBER,
               p_init_msg_list  IN VARCHAR2 DEFAULT G_FALSE,
               x_return_status  OUT NOCOPY VARCHAR2,
               x_msg_count      OUT NOCOPY NUMBER,
               x_msg_data       OUT NOCOPY VARCHAR2,
               p_tqlv_rec       IN tqlv_rec_type,
               x_tqlv_rec       OUT NOCOPY tqlv_rec_type);


  -- Creates multiple quote lines
  PROCEDURE create_quote_line(
               p_api_version    IN NUMBER,
               p_init_msg_list  IN VARCHAR2 DEFAULT G_FALSE,
               x_return_status  OUT NOCOPY VARCHAR2,
               x_msg_count      OUT NOCOPY NUMBER,
               x_msg_data       OUT NOCOPY VARCHAR2,
               p_tqlv_tbl       IN tqlv_tbl_type,
               x_tqlv_tbl       OUT NOCOPY tqlv_tbl_type);


  -- Updates quote line
  PROCEDURE update_quote_line(
               p_api_version    IN NUMBER,
               p_init_msg_list  IN VARCHAR2 DEFAULT G_FALSE,
               x_return_status  OUT NOCOPY VARCHAR2,
               x_msg_count      OUT NOCOPY NUMBER,
               x_msg_data       OUT NOCOPY VARCHAR2,
               p_tqlv_rec       IN tqlv_rec_type,
               x_tqlv_rec       OUT NOCOPY tqlv_rec_type);


  -- Updates multiple quote lines
  PROCEDURE update_quote_line(
               p_api_version    IN NUMBER,
               p_init_msg_list  IN VARCHAR2 DEFAULT G_FALSE,
               x_return_status  OUT NOCOPY VARCHAR2,
               x_msg_count      OUT NOCOPY NUMBER,
               x_msg_data       OUT NOCOPY VARCHAR2,
               p_tqlv_tbl       IN tqlv_tbl_type,
               x_tqlv_tbl       OUT NOCOPY tqlv_tbl_type);

  -- RMUNJULU 08-JAN-03 2736865 New rec type and procedure for quote units
  -- Rec type to populate the quote units data
  TYPE unit_rec_type IS RECORD(
     quote_number NUMBER,
     qst_code VARCHAR2(30),
     qtp_code VARCHAR2(30),
     tql_id NUMBER,
     tqd_id NUMBER,
     asset_quantity NUMBER,
     quote_quantity NUMBER,
     ib_line_id NUMBER,
     fin_line_id NUMBER,
     dnz_chr_id NUMBER,
     serial_number VARCHAR2(300),
     instance_quantity NUMBER,
     instance_number NUMBER,
     asset_number VARCHAR2(300),
     asset_description VARCHAR2(2000),
     location_description VARCHAR2(2000),
     qte_id NUMBER);

  TYPE unit_tbl_type IS TABLE OF unit_rec_type  INDEX BY BINARY_INTEGER;

  -- gets the quote units for the quote line
  PROCEDURE get_quote_units(
               p_api_version    IN NUMBER,
               p_init_msg_list  IN VARCHAR2 DEFAULT G_FALSE,
               x_return_status  OUT NOCOPY VARCHAR2,
               x_msg_count      OUT NOCOPY NUMBER,
               x_msg_data       OUT NOCOPY VARCHAR2,
               p_tql_id         IN NUMBER,
               x_unit_tbl       OUT NOCOPY unit_tbl_type);

  -- RMUNJULU 16-JAN-03 2754574 Added delete procedures
  PROCEDURE delete_quote_line(
               p_api_version    IN NUMBER,
               p_init_msg_list  IN VARCHAR2 DEFAULT G_FALSE,
               x_return_status  OUT NOCOPY VARCHAR2,
               x_msg_count      OUT NOCOPY NUMBER,
               x_msg_data       OUT NOCOPY VARCHAR2,
               p_tqlv_rec       IN tqlv_rec_type);

  PROCEDURE delete_quote_line(
               p_api_version    IN NUMBER,
               p_init_msg_list  IN VARCHAR2 DEFAULT G_FALSE,
               x_return_status  OUT NOCOPY VARCHAR2,
               x_msg_count      OUT NOCOPY NUMBER,
               x_msg_data       OUT NOCOPY VARCHAR2,
               p_tqlv_tbl       IN tqlv_tbl_type);

  -- rmunjulu EDAT checks asset validity in Fixed Assets
  PROCEDURE check_asset_validity_in_fa(
                p_kle_id          IN NUMBER,
                p_trn_date        IN DATE, -- quote eff from date will be passed
                p_check_fa_year   IN VARCHAR2,
				p_check_fa_trn    IN VARCHAR2,
				p_contract_number IN VARCHAR2,
				x_return_status   OUT NOCOPY VARCHAR2);


END OKL_AM_TERMNT_QUOTE_PVT;

 

/
