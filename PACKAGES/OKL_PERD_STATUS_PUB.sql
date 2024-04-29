--------------------------------------------------------
--  DDL for Package OKL_PERD_STATUS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_PERD_STATUS_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPPSMS.pls 115.1 2002/02/06 20:29:03 pkm ship       $ */


SUBTYPE period_rec_type IS OKL_PERD_STATUS_PVT.period_rec_type;
SUBTYPE period_tbl_type IS OKL_PERD_STATUS_PVT.period_tbl_type;


PROCEDURE SEARCH_PERIOD_STATUS(p_api_version        IN       NUMBER,
                               p_init_msg_list      IN       VARCHAR2,
                               x_return_status      OUT      NOCOPY VARCHAR2,
                               x_msg_count          OUT      NOCOPY NUMBER,
                               x_msg_data           OUT      NOCOPY VARCHAR2,
                               p_period_rec         IN       PERIOD_REC_TYPE,
                               x_period_tbl         OUT      NOCOPY PERIOD_TBL_TYPE);


PROCEDURE UPDATE_PERIOD_STATUS(p_api_version      IN       NUMBER,
                               p_init_msg_list    IN       VARCHAR2,
                               x_return_status    OUT      NOCOPY VARCHAR2,
                               x_msg_count        OUT      NOCOPY NUMBER,
                               x_msg_data         OUT      NOCOPY VARCHAR2,
                               p_period_tbl       IN       PERIOD_TBL_TYPE);


G_PKG_NAME CONSTANT VARCHAR2(200)     := 'OKL_PERD_STATUS_PUB' ;
G_APP_NAME CONSTANT VARCHAR2(3)       :=  OKL_API.G_APP_NAME;


END OKL_PERD_STATUS_PUB;

 

/
