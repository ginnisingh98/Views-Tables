--------------------------------------------------------
--  DDL for Package OKL_CS_CREATE_QUOTE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CS_CREATE_QUOTE_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRCTQS.pls 115.3 2003/01/02 19:14:23 rvaduri noship $ */


  SUBTYPE  quot_tbl_type IS okl_qte_pvt.qtev_tbl_type;
  SUBTYPE  qpyv_tbl_type IS OKL_QUOTE_PARTIES_PUB.qpyv_tbl_type;

  G_EMPTY_QPYV_TBL      qpyv_tbl_type;

  ---------------------------------------------------------------------------
  -- PROCEDURES
  ---------------------------------------------------------------------------

  PROCEDURE create_terminate_quote(
    p_api_version                  IN 	NUMBER,
    p_init_msg_list                IN 	VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT 	NOCOPY VARCHAR2,
    x_msg_count                    OUT 	NOCOPY NUMBER,
    x_msg_data                     OUT 	NOCOPY VARCHAR2,
    p_quot_tbl                     IN 	quot_tbl_type,
    p_assn_tbl			   IN 	OKL_AM_CREATE_QUOTE_PUB.assn_tbl_type,
    p_qpyv_tbl                     IN   qpyv_tbl_type DEFAULT G_EMPTY_QPYV_TBL,
    x_quot_tbl                     OUT 	NOCOPY quot_tbl_type,
    x_tqlv_tbl			   OUT 	NOCOPY OKL_AM_CREATE_QUOTE_PUB.tqlv_tbl_type,
    x_assn_tbl			   OUT 	NOCOPY OKL_AM_CREATE_QUOTE_PUB.assn_tbl_type);

  PROCEDURE fetch_rule_quote_parties (
        p_api_version           IN  NUMBER,
        p_init_msg_list         IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
        x_msg_count             OUT NOCOPY NUMBER,
        x_msg_data              OUT NOCOPY VARCHAR2,
        x_return_status         OUT NOCOPY VARCHAR2,
        p_qtev_tbl              IN  quot_tbl_type,
        x_qpyv_tbl              OUT NOCOPY okl_quote_parties_pub.qpyv_tbl_type,
        x_q_party_uv_tbl        OUT NOCOPY okl_am_parties_pvt.q_party_uv_tbl_type,
        x_record_count          OUT NOCOPY NUMBER);

  PROCEDURE submit_for_approval(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_term_tbl                     IN  quot_tbl_type,
    x_term_tbl                     OUT NOCOPY quot_tbl_type);

 PROCEDURE send_terminate_quote (
           p_api_version                 IN  NUMBER,
           p_init_msg_list               IN  VARCHAR2,
           x_return_status               OUT NOCOPY VARCHAR2,
           x_msg_count                   OUT NOCOPY NUMBER,
           x_msg_data                    OUT NOCOPY VARCHAR2,
           p_party_tbl                   IN  okl_am_parties_pvt.q_party_uv_tbl_type,
           x_party_tbl                   OUT NOCOPY okl_am_parties_pvt.q_party_uv_tbl_type,
           p_qtev_tbl                    IN  quot_tbl_type,
           x_qtev_tbl                    OUT NOCOPY quot_tbl_type);


END OKL_CS_CREATE_QUOTE_PVT;

 

/
