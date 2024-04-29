--------------------------------------------------------
--  DDL for Package OKL_AM_CONSOLIDATED_QTE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_AM_CONSOLIDATED_QTE_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPCNQS.pls 115.0 2002/06/07 15:45:23 pkm ship        $ */

  ---------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
  ---------------------------------------------------------------------------
  G_PKG_NAME         CONSTANT VARCHAR2(200) := 'OKL_AM_CONSOLIDATED_QTE_PUB';
  G_APP_NAME         CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;

  SUBTYPE qtev_rec_type IS OKL_AM_CONSOLIDATED_QTE_PVT.qtev_rec_type;
  SUBTYPE qtev_tbl_type IS OKL_AM_CONSOLIDATED_QTE_PVT.qtev_tbl_type;

  PROCEDURE create_consolidate_quote (
           p_api_version                 IN  NUMBER,
           p_init_msg_list               IN  VARCHAR2,
           x_return_status               OUT NOCOPY VARCHAR2,
           x_msg_count                   OUT NOCOPY NUMBER,
           x_msg_data                    OUT NOCOPY VARCHAR2,
           p_qtev_tbl                    IN  qtev_tbl_type,
           x_cons_rec                    OUT NOCOPY qtev_rec_type);

  PROCEDURE update_consolidate_quote (
           p_api_version                 IN  NUMBER,
           p_init_msg_list               IN  VARCHAR2,
           x_return_status               OUT NOCOPY VARCHAR2,
           x_msg_count                   OUT NOCOPY NUMBER,
           x_msg_data                    OUT NOCOPY VARCHAR2,
           p_cons_rec                    IN  qtev_rec_type,
           x_cons_rec                    OUT NOCOPY qtev_rec_type,
           x_qtev_tbl                    OUT NOCOPY qtev_tbl_type);


END OKL_AM_CONSOLIDATED_QTE_PUB;

 

/
