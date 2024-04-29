--------------------------------------------------------
--  DDL for Package OKL_ACCT_GEN_RULE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_ACCT_GEN_RULE_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPACGS.pls 115.6 2002/12/18 12:07:57 kjinger noship $ */


SUBTYPE aulv_rec_type IS OKL_ACCT_GEN_RULE_PVT.AULV_REC_TYPE;
SUBTYPE aulv_tbl_type IS OKL_ACCT_GEN_RULE_PVT.AULV_TBL_TYPE;
SUBTYPE agrv_rec_type IS OKL_ACCT_GEN_RULE_PVT.AGRV_REC_TYPE;
SUBTYPE acct_tbl_type IS OKL_ACCT_GEN_RULE_PVT.ACCT_TBL_TYPE;



PROCEDURE GET_RULE_LINES_COUNT(p_api_version        IN     NUMBER,
                               p_init_msg_list      IN     VARCHAR2,
                               x_return_status      OUT    NOCOPY VARCHAR2,
                               x_msg_count          OUT    NOCOPY NUMBER,
                               x_msg_data           OUT    NOCOPY VARCHAR2,
            	               p_ae_line_type       IN     VARCHAR2,
                               x_line_count         OUT NOCOPY    NUMBER);


PROCEDURE GET_RULE_LINES(p_api_version        IN     NUMBER,
                         p_init_msg_list      IN     VARCHAR2,
                         x_return_status      OUT    NOCOPY VARCHAR2,
                         x_msg_count          OUT    NOCOPY NUMBER,
                         x_msg_data           OUT    NOCOPY VARCHAR2,
          	         p_ae_line_type       IN     VARCHAR2,
                         x_acc_lines          OUT NOCOPY    ACCT_TBL_TYPE);



PROCEDURE UPDT_RULE_LINES(p_api_version       IN     NUMBER,
                          p_init_msg_list     IN     VARCHAR2,
                          x_return_status     OUT    NOCOPY VARCHAR2,
                          x_msg_count         OUT    NOCOPY NUMBER,
                          x_msg_data          OUT    NOCOPY VARCHAR2,
                          p_acc_lines         IN     ACCT_TBL_TYPE,
                          x_acc_lines         OUT NOCOPY    ACCT_TBL_TYPE);


G_PKG_NAME CONSTANT VARCHAR2(200)     := 'OKL_ACCT_GEN_RULE_PUB' ;
G_APP_NAME CONSTANT VARCHAR2(3)       :=  OKL_API.G_APP_NAME;

END OKL_ACCT_GEN_RULE_PUB;

 

/
