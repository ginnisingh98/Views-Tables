--------------------------------------------------------
--  DDL for Package OKL_ACCT_GEN_RULE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_ACCT_GEN_RULE_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRACGS.pls 115.6 2002/12/18 12:45:45 kjinger noship $ */


SUBTYPE aulv_rec_type IS OKL_ACC_GEN_RULE_PUB.AULV_REC_TYPE;
SUBTYPE aulv_tbl_type IS OKL_ACC_GEN_RULE_PUB.AULV_TBL_TYPE;
SUBTYPE agrv_rec_type IS OKL_ACC_GEN_RULE_PUB.AGRV_REC_TYPE;

TYPE acct_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    SEGMENT                        OKL_ACCT_GEN_RULES_V.SEGMENT%TYPE := OKC_API.G_MISS_CHAR,
    SEGMENT_DESC                   OKL_ACCT_GEN_RULES_V.SEGMENT_DESC%TYPE
                                                         := OKC_API.G_MISS_CHAR,
    segment_number                 NUMBER := OKC_API.G_MISS_NUM,
    agr_id                         NUMBER := OKC_API.G_MISS_NUM,
    AE_LINE_TYPE                   OKL_ACCT_GEN_RULES_V.SOURCE%TYPE := OKC_API.G_MISS_CHAR,
    source                         OKL_ACCT_GEN_RULES_V.SOURCE%TYPE := OKC_API.G_MISS_CHAR,
    constants                      OKL_ACCT_GEN_RULES_V.CONSTANTS%TYPE := OKC_API.G_MISS_CHAR,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    attribute_category             OKL_ACCT_GEN_RULES_V.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR,
    attribute1                     OKL_ACCT_GEN_RULES_V.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR,
    attribute2                     OKL_ACCT_GEN_RULES_V.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR,
    attribute3                     OKL_ACCT_GEN_RULES_V.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR,
    attribute4                     OKL_ACCT_GEN_RULES_V.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR,
    attribute5                     OKL_ACCT_GEN_RULES_V.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR,
    attribute6                     OKL_ACCT_GEN_RULES_V.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR,
    attribute7                     OKL_ACCT_GEN_RULES_V.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR,
    attribute8                     OKL_ACCT_GEN_RULES_V.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR,
    attribute9                     OKL_ACCT_GEN_RULES_V.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
    attribute10                    OKL_ACCT_GEN_RULES_V.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    attribute11                    OKL_ACCT_GEN_RULES_V.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    attribute12                    OKL_ACCT_GEN_RULES_V.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    attribute13                    OKL_ACCT_GEN_RULES_V.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    attribute14                    OKL_ACCT_GEN_RULES_V.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    attribute15                    OKL_ACCT_GEN_RULES_V.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKL_ACCT_GEN_RULES_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKL_ACCT_GEN_RULES_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM);

TYPE acct_tbl_type    IS table of acct_rec_type INDEX BY BINARY_INTEGER;

 G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
 G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLerrm';
 G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLcode';



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


G_PKG_NAME CONSTANT VARCHAR2(200)     := 'OKL_ACCT_GEN_RULE_PVT' ;
G_APP_NAME CONSTANT VARCHAR2(3)       :=  OKL_API.G_APP_NAME;

END OKL_ACCT_GEN_RULE_PVT;

 

/
