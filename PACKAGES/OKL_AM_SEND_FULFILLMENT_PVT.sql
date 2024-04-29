--------------------------------------------------------
--  DDL for Package OKL_AM_SEND_FULFILLMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_AM_SEND_FULFILLMENT_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRSFWS.pls 115.4 2002/08/13 17:58:42 rmunjulu noship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
  ---------------------------------------------------------------------------
  G_PKG_NAME         CONSTANT VARCHAR2(200) := 'OKL_AM_SEND_FULFILLMENT_PVT';
  G_APP_NAME         CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  G_UNEXPECTED_ERROR CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN    CONSTANT VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN    CONSTANT VARCHAR2(200) := 'SQLcode';
  G_REQUIRED_VALUE   CONSTANT VARCHAR2(200) := OKL_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE	   CONSTANT VARCHAR2(200) := OKL_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN   CONSTANT VARCHAR2(200) := OKL_API.G_COL_NAME_TOKEN;

--  p_ptm_code       : From OKL_PROCESS_TMPLTS_V
--  p_agent_id       : Created by
--  p_transaction_id : Quote_Id, Rmk_Id etc
--  p_recipient_type : Party(P),
--                     Party Contact (PC),
--                     Party Site (PS),
--                     Vendor(V),
--                     Vendor Contact(VC),
--                     Vendor Site (VS)
--  p_recipient_id   :


  TYPE full_rec_type IS RECORD (
           p_ptm_code                    VARCHAR2(200)  := OKL_API.G_MISS_CHAR,
           p_agent_id                    NUMBER         := OKL_API.G_MISS_NUM,
           p_transaction_id              NUMBER         := OKL_API.G_MISS_NUM,
           p_recipient_type              VARCHAR2(200)  := OKL_API.G_MISS_CHAR,
           p_recipient_id                VARCHAR2(200)  := OKL_API.G_MISS_CHAR,
           p_expand_roles                VARCHAR2(200)  := OKL_API.G_MISS_CHAR,
           p_subject_line                VARCHAR2(200)  := OKL_API.G_MISS_CHAR,
           p_sender_email                VARCHAR2(200)  := OKL_API.G_MISS_CHAR,
           p_recipient_email             VARCHAR2(200)  := OKL_API.G_MISS_CHAR);

  TYPE full_tbl_type IS TABLE OF full_rec_type INDEX BY BINARY_INTEGER;

  SUBTYPE qtev_rec_type IS OKL_TRX_QUOTES_PUB.qtev_rec_type;
  SUBTYPE q_party_uv_tbl_type IS OKL_AM_PARTIES_PVT.q_party_uv_tbl_type;


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

END OKL_AM_SEND_FULFILLMENT_PVT;

 

/
