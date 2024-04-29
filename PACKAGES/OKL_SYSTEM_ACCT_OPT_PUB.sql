--------------------------------------------------------
--  DDL for Package OKL_SYSTEM_ACCT_OPT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SYSTEM_ACCT_OPT_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPSYOS.pls 120.1.12010000.1 2008/07/25 08:41:38 appldev ship $ */


SUBTYPE saov_rec_type IS OKL_SYSTEM_ACCT_OPT_PVT.saov_rec_type;


PROCEDURE GET_SYSTEM_ACCT_OPT(p_api_version        IN    NUMBER,
                              p_init_msg_list      IN    VARCHAR2,
                              x_return_status      OUT   NOCOPY VARCHAR2,
                              x_msg_count          OUT   NOCOPY NUMBER,
                              x_msg_data           OUT   NOCOPY VARCHAR2,
                              p_set_of_books_id    IN    NUMBER,
                              x_saov_rec           OUT   NOCOPY saov_rec_type);

PROCEDURE UPDT_SYSTEM_ACCT_OPT(p_api_version       IN    NUMBER,
                               p_init_msg_list     IN    VARCHAR2,
                               x_return_status     OUT   NOCOPY VARCHAR2,
                               x_msg_count         OUT   NOCOPY NUMBER,
                               x_msg_data          OUT   NOCOPY VARCHAR2,
                               p_saov_rec          IN    saov_rec_type,
                               x_saov_rec          OUT   NOCOPY saov_rec_type);


G_PKG_NAME CONSTANT VARCHAR2(200)     := 'OKL_SYSTEM_ACCT_OPT_PUB' ;
G_APP_NAME CONSTANT VARCHAR2(3)       :=  OKL_API.G_APP_NAME;


END OKL_SYSTEM_ACCT_OPT_PUB;

/
