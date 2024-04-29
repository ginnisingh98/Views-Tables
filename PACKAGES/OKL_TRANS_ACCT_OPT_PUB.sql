--------------------------------------------------------
--  DDL for Package OKL_TRANS_ACCT_OPT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_TRANS_ACCT_OPT_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPTACS.pls 115.1 2002/02/06 20:30:40 pkm ship       $ */


SUBTYPE taov_rec_type IS OKL_TRANS_ACCT_OPT_PVT.taov_rec_type;


PROCEDURE GET_TRX_ACCT_OPT(p_api_version        IN     NUMBER,
                           p_init_msg_list      IN     VARCHAR2,
                           x_return_status      OUT    NOCOPY VARCHAR2,
                           x_msg_count          OUT    NOCOPY NUMBER,
                           x_msg_data           OUT    NOCOPY VARCHAR2,
                           p_taov_rec           IN     taov_rec_type,
                           x_taov_rec           OUT    NOCOPY taov_rec_type);

PROCEDURE UPDT_TRX_ACCT_OPT(p_api_version       IN     NUMBER,
                            p_init_msg_list     IN     VARCHAR2,
                            x_return_status     OUT    NOCOPY VARCHAR2,
                            x_msg_count         OUT    NOCOPY NUMBER,
                            x_msg_data          OUT    NOCOPY VARCHAR2,
                            p_taov_rec          IN     taov_rec_type,
                            x_taov_rec          OUT    NOCOPY taov_rec_type);

G_PKG_NAME CONSTANT VARCHAR2(200)     := 'OKL_TRANS_ACCT_OPT_PUB' ;
G_APP_NAME CONSTANT VARCHAR2(3)       :=  OKL_API.G_APP_NAME;

END OKL_TRANS_ACCT_OPT_PUB;




 

/
