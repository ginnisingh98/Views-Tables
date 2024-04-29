--------------------------------------------------------
--  DDL for Package OKL_REVERSAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_REVERSAL_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRREVS.pls 115.6 2002/12/18 12:50:57 kjinger noship $ */


TYPE    SOURCE_ID_TBL_TYPE IS TABLE OF NUMBER INDEX BY  BINARY_INTEGER;


PROCEDURE REVERSE_ENTRIES(p_errbuf                     OUT NOCOPY VARCHAR2,
                          p_retcode                    OUT NOCOPY NUMBER,
                          p_period                     IN  VARCHAR2);


PROCEDURE SUBMIT_PERIOD_REVERSAL(p_api_version         IN         NUMBER,
                                 p_init_msg_list       IN         VARCHAR2,
                                 x_return_status       OUT        NOCOPY VARCHAR2,
                                 x_msg_count           OUT        NOCOPY NUMBER,
                                 x_msg_data            OUT        NOCOPY VARCHAR2,
                                 p_period              IN         VARCHAR2,
                                 x_request_id          OUT NOCOPY        NUMBER);

PROCEDURE REVERSE_ENTRIES(p_api_version                IN         NUMBER,
                          p_init_msg_list              IN         VARCHAR2,
                          x_return_status              OUT        NOCOPY VARCHAR2,
                          x_msg_count                  OUT        NOCOPY NUMBER,
                          x_msg_data                   OUT        NOCOPY VARCHAR2,
                          p_source_id                  IN         NUMBER,
		          p_source_table               IN         VARCHAR2,
			  p_acct_date                  IN         DATE);

PROCEDURE REVERSE_ENTRIES(p_api_version                IN         NUMBER,
                          p_init_msg_list              IN         VARCHAR2,
                          x_return_status              OUT        NOCOPY VARCHAR2,
                          x_msg_count                  OUT        NOCOPY NUMBER,
                          x_msg_data                   OUT        NOCOPY VARCHAR2,
                          p_source_table               IN         VARCHAR2,
			  p_acct_date                  IN         DATE,
			  p_source_id_tbl              IN         SOURCE_ID_TBL_TYPE);


G_PKG_NAME              VARCHAR2(30) := 'OKL_REVERSAL_PVT';
G_APP_NAME	        CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
G_REQUIRED_VALUE	CONSTANT VARCHAR2(200) := OKC_API.G_REQUIRED_VALUE;
G_INVALID_VALUE		CONSTANT VARCHAR2(200) := OKL_API.G_INVALID_VALUE;
G_COL_NAME_TOKEN	CONSTANT VARCHAR2(200) := OKL_API.G_COL_NAME_TOKEN;


END OKL_REVERSAL_PVT;

 

/
