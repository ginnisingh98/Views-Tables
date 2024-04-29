--------------------------------------------------------
--  DDL for Package OKL_INTEREST_MAINT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_INTEREST_MAINT_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPINMS.pls 115.1 2002/02/06 20:28:41 pkm ship       $ */


SUBTYPE ivev_rec_type         IS OKL_INTEREST_MAINT_PVT.ivev_rec_type;
SUBTYPE ivev_tbl_type         IS OKL_INTEREST_MAINT_PVT.ivev_tbl_type;

SUBTYPE idxv_rec_type         IS OKL_INTEREST_MAINT_PVT.idxv_rec_type;
SUBTYPE idxv_tbl_type         IS OKL_INTEREST_MAINT_PVT.idxv_tbl_type;


PROCEDURE INT_HDR_INS_UPDT(p_api_version           IN      NUMBER,
                           p_init_msg_list                    IN      VARCHAR2,
                           x_return_status                    OUT     NOCOPY VARCHAR2,
                           x_msg_count                        OUT     NOCOPY NUMBER,
                           x_msg_data                         OUT     NOCOPY VARCHAR2,
                           p_idxv_rec                         IN      idxv_rec_type);


PROCEDURE INT_HDR_INS_UPDT(p_api_version           IN      NUMBER,
                    p_init_msg_list                    IN      VARCHAR2,
                    x_return_status                    OUT     NOCOPY VARCHAR2,
                    x_msg_count                        OUT     NOCOPY NUMBER,
                    x_msg_data                         OUT     NOCOPY VARCHAR2,
                    p_idxv_tbl                         IN      idxv_tbl_type);


PROCEDURE INT_DTL_INS_UPDT(p_api_version           IN      NUMBER,
                    p_init_msg_list                    IN      VARCHAR2,
                    x_return_status                    OUT     NOCOPY VARCHAR2,
                    x_msg_count                        OUT     NOCOPY NUMBER,
                    x_msg_data                         OUT     NOCOPY VARCHAR2,
                    p_ivev_rec                         IN      ivev_rec_type);


PROCEDURE INT_DTL_INS_UPDT(p_api_version           IN      NUMBER,
                        p_init_msg_list                IN      VARCHAR2,
                        x_return_status                OUT     NOCOPY VARCHAR2,
                        x_msg_count                    OUT     NOCOPY NUMBER,
                        x_msg_data                     OUT     NOCOPY VARCHAR2,
                        p_ivev_tbl                     IN      ivev_tbl_type);


G_PKG_NAME CONSTANT VARCHAR2(200)     := 'OKL_INTEREST_MAINT_PUB' ;
G_APP_NAME CONSTANT VARCHAR2(3)       :=  OKL_API.G_APP_NAME;


END OKL_INTEREST_MAINT_PUB;

 

/
