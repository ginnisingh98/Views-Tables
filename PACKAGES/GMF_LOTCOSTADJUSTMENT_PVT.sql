--------------------------------------------------------
--  DDL for Package GMF_LOTCOSTADJUSTMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_LOTCOSTADJUSTMENT_PVT" AUTHID CURRENT_USER AS
/* $Header: GMFVLCAS.pls 120.2.12000000.2 2007/05/11 12:41:26 pmarada ship $ */
PROCEDURE Create_LotCost_Adjustment
(
p_api_version                   IN                              NUMBER
,p_init_msg_list                IN                              VARCHAR2 := FND_API.G_FALSE
,x_return_status                OUT             NOCOPY          VARCHAR2
,x_msg_count                    OUT             NOCOPY          NUMBER
,x_msg_data                     OUT             NOCOPY          VARCHAR2
,p_header_rec                   IN OUT          NOCOPY          GMF_LotCostAdjustment_PUB.Lc_Adjustment_Header_Rec_Type
,p_dtl_Tbl                      IN OUT          NOCOPY          GMF_LotCostAdjustment_PUB.Lc_adjustment_dtls_Tbl_Type
,p_user_id                      IN                              NUMBER
);

PROCEDURE Update_LotCost_Adjustment
(
p_api_version                   IN                              NUMBER
,p_init_msg_list                IN                              VARCHAR2 := FND_API.G_FALSE
,x_return_status                OUT             NOCOPY          VARCHAR2
,x_msg_count                    OUT             NOCOPY          NUMBER
,x_msg_data                     OUT             NOCOPY          VARCHAR2
,p_header_rec                   IN OUT          NOCOPY          GMF_LotCostAdjustment_PUB.Lc_Adjustment_Header_Rec_Type
,p_dtl_Tbl                      IN OUT          NOCOPY          GMF_LotCostAdjustment_PUB.Lc_adjustment_dtls_Tbl_Type
,p_user_id                      IN                              NUMBER
);

PROCEDURE Delete_LotCost_Adjustment
(
p_api_version                   IN                              NUMBER
,p_init_msg_list                IN                              VARCHAR2 := FND_API.G_FALSE
,x_return_status                OUT             NOCOPY          VARCHAR2
,x_msg_count                    OUT             NOCOPY          NUMBER
,x_msg_data                     OUT             NOCOPY          VARCHAR2
,p_header_rec                   IN OUT          NOCOPY          GMF_LotCostAdjustment_PUB.Lc_Adjustment_Header_Rec_Type
,p_dtl_Tbl                      IN OUT          NOCOPY          GMF_LotCostAdjustment_PUB.Lc_adjustment_dtls_Tbl_Type
);

PROCEDURE Get_LotCost_Adjustment
(
p_api_version                   IN                              NUMBER
,p_init_msg_list                IN                              VARCHAR2 := FND_API.G_FALSE
,x_return_status                OUT             NOCOPY          VARCHAR2
,x_msg_count                    OUT             NOCOPY          NUMBER
,x_msg_data                     OUT             NOCOPY          VARCHAR2
,p_header_rec                   IN OUT          NOCOPY          GMF_LotCostAdjustment_PUB.Lc_Adjustment_Header_Rec_Type
,p_dtl_Tbl                      OUT             NOCOPY          GMF_LotCostAdjustment_PUB.Lc_adjustment_dtls_Tbl_Type
);

END GMF_LotCostAdjustment_PVT ;

 

/
