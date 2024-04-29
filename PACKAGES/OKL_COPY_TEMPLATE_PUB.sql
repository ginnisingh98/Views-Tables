--------------------------------------------------------
--  DDL for Package OKL_COPY_TEMPLATE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_COPY_TEMPLATE_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPTLCS.pls 115.1 2002/02/06 20:30:50 pkm ship       $ */


PROCEDURE COPY_TEMPLATES(p_api_version                IN         NUMBER,
                         p_init_msg_list              IN         VARCHAR2,
                         x_return_status              OUT        NOCOPY VARCHAR2,
                         x_msg_count                  OUT        NOCOPY NUMBER,
                         x_msg_data                   OUT        NOCOPY VARCHAR2,
						 p_aes_id_from                IN         NUMBER,
						 p_aes_id_to                  IN         NUMBER);



G_PKG_NAME CONSTANT VARCHAR2(200)     := 'OKL_COPY_TEMPLATE_PUB' ;
G_APP_NAME CONSTANT VARCHAR2(3)       :=  OKL_API.G_APP_NAME;

END OKL_COPY_TEMPLATE_PUB;


 

/
