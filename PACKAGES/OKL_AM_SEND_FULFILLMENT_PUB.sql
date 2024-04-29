--------------------------------------------------------
--  DDL for Package OKL_AM_SEND_FULFILLMENT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_AM_SEND_FULFILLMENT_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPSFWS.pls 115.3 2002/07/23 20:59:26 rmunjulu noship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
  ---------------------------------------------------------------------------
  G_PKG_NAME         CONSTANT VARCHAR2(200) := 'OKL_AM_SEND_FULFILLMENT_PUB';
  G_APP_NAME         CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  G_UNEXPECTED_ERROR CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN    CONSTANT VARCHAR2(200) := 'SQLERRM';
  G_SQLCODE_TOKEN    CONSTANT VARCHAR2(200) := 'SQLCODE';

  SUBTYPE full_rec_type IS OKL_AM_SEND_FULFILLMENT_PVT.full_rec_type;
  SUBTYPE full_tbl_type IS OKL_AM_SEND_FULFILLMENT_PVT.full_tbl_type;
  SUBTYPE qtev_rec_type IS OKL_AM_SEND_FULFILLMENT_PVT.qtev_rec_type;
  SUBTYPE q_party_uv_tbl_type IS OKL_AM_SEND_FULFILLMENT_PVT.q_party_uv_tbl_type;

  PROCEDURE send_fulfillment (
           p_api_version                 IN  NUMBER,
           p_init_msg_list               IN  VARCHAR2,
           x_return_status               OUT NOCOPY VARCHAR2,
           x_msg_count                   OUT NOCOPY NUMBER,
           x_msg_data                    OUT NOCOPY VARCHAR2,
           p_send_rec                    IN  full_rec_type,
           x_send_rec                    OUT NOCOPY full_rec_type);

  PROCEDURE send_fulfillment (
           p_api_version                 IN  NUMBER,
           p_init_msg_list               IN  VARCHAR2,
           x_return_status               OUT NOCOPY VARCHAR2,
           x_msg_count                   OUT NOCOPY NUMBER,
           x_msg_data                    OUT NOCOPY VARCHAR2,
           p_send_tbl                    IN  full_tbl_type,
           x_send_tbl                    OUT NOCOPY full_tbl_type);

  PROCEDURE send_terminate_quote (
           p_api_version                 IN  NUMBER,
           p_init_msg_list               IN  VARCHAR2,
           x_return_status               OUT NOCOPY VARCHAR2,
           x_msg_count                   OUT NOCOPY NUMBER,
           x_msg_data                    OUT NOCOPY VARCHAR2,
           p_party_tbl                   IN  q_party_uv_tbl_type,
           x_party_tbl                   OUT NOCOPY q_party_uv_tbl_type,
           p_qtev_rec                    IN  qtev_rec_type,
           x_qtev_rec                    OUT NOCOPY qtev_rec_type);

  PROCEDURE send_repurchase_quote (
           p_api_version                 IN  NUMBER,
           p_init_msg_list               IN  VARCHAR2,
           x_return_status               OUT NOCOPY VARCHAR2,
           x_msg_count                   OUT NOCOPY NUMBER,
           x_msg_data                    OUT NOCOPY VARCHAR2,
           p_send_tbl                    IN  full_tbl_type,
           x_send_tbl                    OUT NOCOPY full_tbl_type,
           p_qtev_rec                    IN  qtev_rec_type,
           x_qtev_rec                    OUT NOCOPY qtev_rec_type);

  PROCEDURE send_restructure_quote (
           p_api_version                 IN  NUMBER,
           p_init_msg_list               IN  VARCHAR2,
           x_return_status               OUT NOCOPY VARCHAR2,
           x_msg_count                   OUT NOCOPY NUMBER,
           x_msg_data                    OUT NOCOPY VARCHAR2,
           p_send_tbl                    IN  full_tbl_type,
           x_send_tbl                    OUT NOCOPY full_tbl_type,
           p_qtev_rec                    IN  qtev_rec_type,
           x_qtev_rec                    OUT NOCOPY qtev_rec_type);

  PROCEDURE send_consolidate_quote (
           p_api_version                 IN  NUMBER,
           p_init_msg_list               IN  VARCHAR2,
           x_return_status               OUT NOCOPY VARCHAR2,
           x_msg_count                   OUT NOCOPY NUMBER,
           x_msg_data                    OUT NOCOPY VARCHAR2,
           p_send_tbl                    IN  full_tbl_type,
           x_send_tbl                    OUT NOCOPY full_tbl_type,
           p_qtev_rec                    IN  qtev_rec_type,
           x_qtev_rec                    OUT NOCOPY qtev_rec_type);


END OKL_AM_SEND_FULFILLMENT_PUB;

 

/
