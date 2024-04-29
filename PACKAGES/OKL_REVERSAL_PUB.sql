--------------------------------------------------------
--  DDL for Package OKL_REVERSAL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_REVERSAL_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPREVS.pls 115.5 2002/12/18 12:32:48 kjinger noship $ */


SUBTYPE SOURCE_ID_TBL_TYPE IS OKL_REVERSAL_PVT.SOURCE_ID_TBL_TYPE;



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


G_PKG_NAME CONSTANT VARCHAR2(200)     := 'OKL_REVERSAL_PUB' ;
G_APP_NAME CONSTANT VARCHAR2(3)       :=  OKL_API.G_APP_NAME;


END OKL_REVERSAL_PUB;

 

/
