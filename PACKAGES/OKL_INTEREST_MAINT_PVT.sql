--------------------------------------------------------
--  DDL for Package OKL_INTEREST_MAINT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_INTEREST_MAINT_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRINMS.pls 115.2 2002/03/01 16:06:03 pkm ship       $ */


SUBTYPE ivev_rec_type         IS OKL_INDICES_PUB.ivev_rec_type;
SUBTYPE ivev_tbl_type         IS OKL_INDICES_PUB.ivev_tbl_type;

SUBTYPE idxv_rec_type         IS OKL_INDICES_PUB.idxv_rec_type;
SUBTYPE idxv_tbl_type         IS OKL_INDICES_PUB.idxv_tbl_type;


FUNCTION  OVERLAP_EXISTS  (p_idx_type                  IN VARCHAR2,
                           p_idx_name                  IN VARCHAR2,
                           p_datetime_valid            IN DATE,
                           p_datetime_invalid          IN DATE)
                           RETURN VARCHAR2;


FUNCTION  OVERLAP_EXISTS  (p_idx_id                    IN NUMBER,
                           p_datetime_valid            IN DATE,
                           p_datetime_invalid          IN DATE)
                           RETURN VARCHAR2;



PROCEDURE INT_HDR_INS_UPDT(p_api_version           IN      NUMBER,
                    p_init_msg_list                    IN      VARCHAR2,
                    x_return_status                    OUT     NOCOPY VARCHAR2,
                    x_msg_count                        OUT     NOCOPY NUMBER,
                    x_msg_data                         OUT     NOCOPY VARCHAR2,
                    p_idxv_rec                         IN      idxv_rec_type);


PROCEDURE INT_HDR_INS_UPDT(p_api_version           IN      NUMBER,
                           p_init_msg_list         IN      VARCHAR2,
                           x_return_status         OUT     NOCOPY VARCHAR2,
                           x_msg_count             OUT     NOCOPY NUMBER,
                           x_msg_data              OUT     NOCOPY VARCHAR2,
                           p_idxv_tbl              IN      idxv_tbl_type);


PROCEDURE INT_DTL_INS_UPDT(p_api_version           IN      NUMBER,
                           p_init_msg_list         IN      VARCHAR2,
                           x_return_status         OUT     NOCOPY VARCHAR2,
                           x_msg_count             OUT     NOCOPY NUMBER,
                           x_msg_data              OUT     NOCOPY VARCHAR2,
                           p_ivev_rec              IN      ivev_rec_type);


PROCEDURE INT_DTL_INS_UPDT(p_api_version           IN      NUMBER,
                           p_init_msg_list         IN      VARCHAR2,
                           x_return_status         OUT     NOCOPY VARCHAR2,
                           x_msg_count             OUT     NOCOPY NUMBER,
                           x_msg_data              OUT     NOCOPY VARCHAR2,
                           p_ivev_tbl              IN      ivev_tbl_type);



G_PKG_NAME CONSTANT VARCHAR2(200)      := 'OKL_INTEREST_MAINT_PVT' ;
G_APP_NAME CONSTANT VARCHAR2(3)        :=  OKL_API.G_APP_NAME;

G_REQUIRED_VALUE                 CONSTANT VARCHAR2(200) := OKL_API.G_REQUIRED_VALUE;
G_INVALID_VALUE                  CONSTANT VARCHAR2(200) := OKL_API.G_INVALID_VALUE;
G_SQLERRM_TOKEN                  CONSTANT VARCHAR2(200) := 'OKL_SQLerrm';
G_SQLCODE_TOKEN                  CONSTANT VARCHAR2(200) := 'OKL_SQLcode';
G_UNEXPECTED_ERROR               CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
G_UPPERCASE_REQUIRED             CONSTANT VARCHAR2(200) := 'OKL_UPPER_CASE_REQUIRED';
G_COL_NAME_TOKEN                 CONSTANT VARCHAR2(200) := OKL_API.G_COL_NAME_TOKEN;

END;

 

/
