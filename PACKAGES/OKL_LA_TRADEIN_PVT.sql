--------------------------------------------------------
--  DDL for Package OKL_LA_TRADEIN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_LA_TRADEIN_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRTRIS.pls 120.2 2006/09/11 23:20:54 smereddy noship $ */

-- GLOBAL VARIABLES
---------------------------------------------------------------------------
G_PKG_NAME              CONSTANT VARCHAR2(200) := 'OKL_LA_TRADEIN_PVT';
G_APP_NAME              CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
G_API_TYPE		CONSTANT VARCHAR2(4)   := '_PVT';
G_FALSE                 CONSTANT VARCHAR2(1)   := OKL_API.G_FALSE;
G_TRUE                  CONSTANT VARCHAR2(1)   := OKL_API.G_TRUE;
---------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  -- APPLICATION GLOBAL CONSTANTS
  -----------------------------------------------------------------------------
  G_API_VERSION          CONSTANT NUMBER        := 1;
  G_DB_ERROR             CONSTANT VARCHAR2(12)  := 'OKL_DB_ERROR';
  G_PROG_NAME_TOKEN      CONSTANT VARCHAR2(9)   := 'PROG_NAME';
  G_SQLCODE_TOKEN        CONSTANT VARCHAR2(7)   := 'SQLCODE';
  G_SQLERRM_TOKEN        CONSTANT VARCHAR2(7)   := 'SQLERRM';
  G_RET_STS_SUCCESS      CONSTANT VARCHAR2(1)   := OKL_API.G_RET_STS_SUCCESS;
  G_RET_STS_UNEXP_ERROR  CONSTANT VARCHAR2(1)   := OKL_API.G_RET_STS_UNEXP_ERROR;
  G_RET_STS_ERROR        CONSTANT VARCHAR2(1)   := OKL_API.G_RET_STS_ERROR;


TYPE tradein_rec_type is record
(
     id               okc_k_lines_b.id%type,
     asset_id         okc_k_lines_b.id%type,
     asset_number     OKC_K_LINES_TL.name%type,
     tradein_amount   okl_k_lines.tradein_amount%type
 );
TYPE tradein_tbl_type is table of tradein_rec_type INDEX BY BINARY_INTEGER;

TYPE asset_rec_type IS RECORD (       fin_asset_id   NUMBER,
                                      amount         NUMBER,
                                      asset_number   VARCHAR2(15));

TYPE asset_tbl_type IS TABLE OF asset_rec_type INDEX BY BINARY_INTEGER;

TYPE cle_id_rec_type IS RECORD (cle_id NUMBER);

TYPE cle_id_tbl_type IS TABLE OF cle_id_rec_type INDEX BY BINARY_INTEGER;

TYPE link_asset_rec_type IS RECORD (link_line_id   NUMBER,
                                      link_item_id   NUMBER,
                                      fin_asset_id   NUMBER,
                                      amount         NUMBER,
                                      asset_number   VARCHAR2(15));

TYPE link_asset_tbl_type IS TABLE OF link_asset_rec_type INDEX BY BINARY_INTEGER;

 PROCEDURE create_tradein(
            p_api_version    	     IN  NUMBER,
            p_init_msg_list          IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status          OUT NOCOPY VARCHAR2,
            x_msg_count              OUT NOCOPY NUMBER,
            x_msg_data               OUT NOCOPY VARCHAR2,
            p_chr_id                 IN  okl_k_headers.id%TYPE,
            p_tradein_rec            IN  tradein_rec_type,
            x_tradein_rec            OUT NOCOPY tradein_rec_type
 );

PROCEDURE create_tradein(
	    p_api_version                  IN NUMBER,
	    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
	    x_return_status                OUT NOCOPY VARCHAR2,
	    x_msg_count                    OUT NOCOPY NUMBER,
	    x_msg_data                     OUT NOCOPY VARCHAR2,
            p_chr_id                       IN  okl_k_headers.id%TYPE,
	    p_tradein_tbl                  IN  tradein_tbl_type,
	    x_tradein_tbl                  OUT NOCOPY tradein_tbl_type
 );

 PROCEDURE delete_tradein(
            p_api_version    	     IN  NUMBER,
            p_init_msg_list          IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status          OUT NOCOPY VARCHAR2,
            x_msg_count              OUT NOCOPY NUMBER,
            x_msg_data               OUT NOCOPY VARCHAR2,
            p_chr_id                 IN  okl_k_headers.id%TYPE,
            p_tradein_rec            IN  tradein_rec_type,
            x_tradein_rec            OUT NOCOPY tradein_rec_type
 );

PROCEDURE delete_tradein(
	    p_api_version                  IN NUMBER,
	    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
	    x_return_status                OUT NOCOPY VARCHAR2,
	    x_msg_count                    OUT NOCOPY NUMBER,
	    x_msg_data                     OUT NOCOPY VARCHAR2,
            p_chr_id                       IN  okl_k_headers.id%TYPE,
	    p_tradein_tbl                  IN  tradein_tbl_type,
	    x_tradein_tbl                  OUT NOCOPY tradein_tbl_type
 );

PROCEDURE update_contract(
            p_api_version    	     IN  NUMBER,
            p_init_msg_list          IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status          OUT NOCOPY VARCHAR2,
            x_msg_count              OUT NOCOPY NUMBER,
            x_msg_data               OUT NOCOPY VARCHAR2,
            p_chr_id                 IN  okl_k_headers.id%TYPE,
            p_tradein_date           IN  okl_k_headers.DATE_TRADEIN%TYPE,
            p_tradein_amount         IN  okl_k_headers.tradein_amount%TYPE,
            p_tradein_desc           IN  okl_k_headers.tradein_description%TYPE
 );

PROCEDURE allocate_amount(p_api_version         IN         NUMBER,
            p_init_msg_list       IN         VARCHAR2 DEFAULT G_FALSE,
            p_transaction_control IN         VARCHAR2 DEFAULT G_TRUE,
            p_cle_id              IN         NUMBER,
            p_chr_id              IN         NUMBER,
            p_capitalize_yn       IN         VARCHAR2,
            x_cle_id              OUT NOCOPY NUMBER,
            x_chr_id              OUT NOCOPY NUMBER,
            x_return_status       OUT NOCOPY VARCHAR2,
            x_msg_count           OUT NOCOPY NUMBER,
            x_msg_data            OUT NOCOPY VARCHAR2);


 PROCEDURE allocate_amount_tradein (
            p_api_version    	     IN  NUMBER,
            p_init_msg_list          IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status          OUT NOCOPY VARCHAR2,
            x_msg_count              OUT NOCOPY NUMBER,
            x_msg_data               OUT NOCOPY VARCHAR2,
            p_chr_id                 IN  NUMBER,
            p_derive_assoc_amt       IN VARCHAR2
);

PROCEDURE delete_contract(
            p_api_version    	     IN  NUMBER,
            p_init_msg_list          IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status          OUT NOCOPY VARCHAR2,
            x_msg_count              OUT NOCOPY NUMBER,
            x_msg_data               OUT NOCOPY VARCHAR2,
            p_chr_id                 IN  okl_k_headers.id%TYPE
 );

END OKL_LA_TRADEIN_PVT;

/
