--------------------------------------------------------
--  DDL for Package OKL_COPY_TEMPLATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_COPY_TEMPLATE_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRTLCS.pls 115.1 2002/02/06 20:34:46 pkm ship       $ */


SUBTYPE avlv_rec_type IS OKL_TMPT_SET_PUB.avlv_rec_type;
SUBTYPE avlv_tbl_type IS OKL_TMPT_SET_PUB.avlv_tbl_type;

SUBTYPE atlv_rec_type IS OKL_TMPT_SET_PUB.atlv_rec_type;
SUBTYPE atlv_tbl_type IS OKL_TMPT_SET_PUB.atlv_tbl_type;



PROCEDURE COPY_TEMPLATES(p_api_version                IN         NUMBER,
                         p_init_msg_list              IN         VARCHAR2,
                         x_return_status              OUT        NOCOPY VARCHAR2,
                         x_msg_count                  OUT        NOCOPY NUMBER,
                         x_msg_data                   OUT        NOCOPY VARCHAR2,
						 p_aes_id_from                IN         NUMBER,
						 p_aes_id_to                  IN         NUMBER);


G_PKG_NAME              VARCHAR2(30) := 'OKL_COPY_TEMPLATE_PVT';
G_APP_NAME	            CONSTANT VARCHAR2(3)   := OKL_API.G_APP_NAME;
G_REQUIRED_VALUE		CONSTANT VARCHAR2(200) := OKL_API.G_REQUIRED_VALUE;
G_INVALID_VALUE			CONSTANT VARCHAR2(200) := OKL_API.G_INVALID_VALUE;
G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := OKL_API.G_COL_NAME_TOKEN;


END OKL_COPY_TEMPLATE_PVT;

 

/
