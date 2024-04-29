--------------------------------------------------------
--  DDL for Package OKL_SETUPPQVALUES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SETUPPQVALUES_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPSUVS.pls 120.6 2008/02/29 10:15:32 veramach ship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_UNEXPECTED_ERROR          CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_DATES_MISMATCH	          CONSTANT VARCHAR2(200) := 'OKL_DATES_MISMATCH';
  G_SQLERRM_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLERRM';
  G_SQLCODE_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLCODE';
  G_PAST_RECORDS	  		  CONSTANT VARCHAR2(200) := 'OKL_PAST_RECORDS';
  G_START_DATE				  CONSTANT VARCHAR2(200) := 'OKL_START_DATE';
  G_INVALID_DATES             CONSTANT VARCHAR2(200) := 'OKL_INVALID_DATES';
  G_PARENT_TABLE_TOKEN	      CONSTANT VARCHAR2(100) := OKL_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN	      CONSTANT VARCHAR2(100) := OKL_API.G_CHILD_TABLE_TOKEN;

  G_APP_NAME	              CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  G_PKG_NAME                  CONSTANT VARCHAR2(30)  := 'OKL_SETUPPQVALUES_PUB';

  G_EXCEPTION_HALT_PROCESSING EXCEPTION;


  SUBTYPE pqvv_rec_type IS OKL_SETUPPQVALUES_PVT.pqvv_rec_type;
  SUBTYPE pqvv_tbl_type IS OKL_SETUPPQVALUES_PVT.pqvv_tbl_type;

  -- PRODUCT QUALITY
  SUBTYPE pqyv_rec_type IS OKL_SETUPPQVALUES_PVT.pqyv_rec_type;
  SUBTYPE pqyv_tbl_type IS OKL_SETUPPQVALUES_PVT.pqyv_tbl_type;

  -- PRODUCT
  SUBTYPE pdtv_rec_type IS OKL_SETUPPQVALUES_PVT.pdtv_rec_type;
  SUBTYPE pdtv_tbl_type IS OKL_SETUPPQVALUES_PVT.pdtv_tbl_type;

  PROCEDURE get_rec (
    p_pqvv_rec			  IN pqvv_rec_type,
    x_return_status		  OUT NOCOPY VARCHAR2,
	x_msg_data			  OUT NOCOPY VARCHAR2,
    x_no_data_found       OUT NOCOPY BOOLEAN,
	x_pqvv_rec			  OUT NOCOPY pqvv_rec_type);

  PROCEDURE insert_pqvalues(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pqyv_rec                     IN  pqyv_rec_type,
    p_pdtv_rec                     IN  pdtv_rec_type,
    p_pqvv_rec                     IN  pqvv_rec_type,
    x_pqvv_rec                     OUT NOCOPY pqvv_rec_type
    );
             PROCEDURE insert_pqvalues(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
  	p_pqyv_rec         IN  pqyv_rec_type,
		p_pdtv_rec         IN  pdtv_rec_type,
			p_pqvv_tbl         IN  pqvv_tbl_type,
   	x_pqvv_tbl         OUT NOCOPY pqvv_tbl_type);

  PROCEDURE update_pqvalues(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pqyv_rec                     IN  pqyv_rec_type,
    p_pdtv_rec                     IN  pdtv_rec_type,
    p_pqvv_rec                     IN  pqvv_rec_type,
    x_pqvv_rec                     OUT NOCOPY pqvv_rec_type
    );
    PROCEDURE update_pqvalues(p_api_version      IN  NUMBER,
                            p_init_msg_list    IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                        	x_return_status    OUT NOCOPY VARCHAR2,
                        	x_msg_count        OUT NOCOPY NUMBER,
                        	x_msg_data         OUT NOCOPY VARCHAR2,
                        	p_pqyv_rec         IN  pqyv_rec_type,
							p_pdtv_rec         IN  pdtv_rec_type,
							p_pqvv_tbl         IN  pqvv_tbl_type,
                        	x_pqvv_tbl         OUT NOCOPY pqvv_tbl_type
						    );


END OKL_SETUPPQVALUES_PUB;

/
