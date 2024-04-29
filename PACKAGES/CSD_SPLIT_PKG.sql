--------------------------------------------------------
--  DDL for Package CSD_SPLIT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_SPLIT_PKG" AUTHID CURRENT_USER as
/* $Header: csdsplts.pls 120.1 2005/09/19 16:46:57 takwong noship $ */
-- Start of Comments
-- Package name     : CSD_SPLIT_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


PROCEDURE Split_Repair_Order (
    p_api_version               IN              NUMBER,
    p_init_msg_list             IN              VARCHAR2,
    p_commit                    IN              VARCHAR2,
    p_validation_level          IN              NUMBER,
    x_return_status             OUT     NOCOPY  VARCHAR2,
    x_msg_count                 OUT     NOCOPY  NUMBER,
    x_msg_data                  OUT     NOCOPY  VARCHAR2,
    p_original_repair_line_id   IN              NUMBER,
    p_split_option              IN              NUMBER,
    p_copy_attachment           IN              VARCHAR2,
    p_attachment_counts         IN              NUMBER,
    p_new_quantity              IN              NUMBER,
    p_repair_type_id            IN              NUMBER
);

PROCEDURE Build_Repln_Record (
    p_repair_line_id    IN              NUMBER,
    x_Repln_Rec         OUT     NOCOPY  CSD_REPAIRS_PUB.Repln_Rec_Type,
    x_return_status     OUT     NOCOPY  VARCHAR2
);

PROCEDURE Build_Product_TXN_Record (
    p_product_txn_id    IN              NUMBER,
    x_product_txn_Rec   OUT     NOCOPY  CSD_PROCESS_PVT.PRODUCT_TXN_REC,
    x_return_status     OUT     NOCOPY  VARCHAR2
);

PROCEDURE Is_Split_Repair_Order_Allow (
    p_repair_line_id    IN      NUMBER,
    x_return_status     OUT     NOCOPY  VARCHAR2,
    x_msg_count         OUT     NOCOPY  NUMBER,
    x_msg_data          OUT     NOCOPY  VARCHAR2
);

PROCEDURE Set_Error_Message (
    p_msg_code          IN              VARCHAR2,
    x_return_status     OUT     NOCOPY  VARCHAR2,
    x_msg_count         OUT     NOCOPY  NUMBER,
    x_msg_data          OUT     NOCOPY  VARCHAR2
);


PROCEDURE Create_New_Repair_Order (
    p_api_version               IN              NUMBER,
    p_init_msg_list             IN              VARCHAR2,
    p_commit                    IN              VARCHAR2,
    p_validation_level          IN              NUMBER,
    x_return_status             OUT     NOCOPY  VARCHAR2,
    x_msg_count                 OUT     NOCOPY  NUMBER,
    x_msg_data                  OUT     NOCOPY  VARCHAR2,
    x_repair_line_id            OUT     NOCOPY  NUMBER,
    p_copy_attachment           IN              VARCHAR2,
    p_original_repair_line_id   IN              NUMBER,
    p_rep_line_rec              IN              CSD_REPAIRS_PUB.REPLN_REC_TYPE
);

PROCEDURE Copy_Repair_History (
    p_api_version               IN              NUMBER,
    p_init_msg_list             IN              VARCHAR2,
    p_commit                    IN              VARCHAR2,
    p_validation_level          IN              NUMBER,
    x_return_status             OUT     NOCOPY  VARCHAR2,
    x_msg_count                 OUT     NOCOPY  NUMBER,
    x_msg_data                  OUT     NOCOPY  VARCHAR2,
    p_original_repair_line_id   IN              NUMBER,
    p_new_repair_line_id        IN              NUMBER
);

PROCEDURE Build_Repair_History_Record (
    p_original_repair_history_id    IN              NUMBER,
    x_repair_history_Rec            OUT     NOCOPY  CSD_REPAIR_HISTORY_PVT.REPH_Rec_Type,
    x_return_status                 OUT     NOCOPY  VARCHAR2
);


PROCEDURE Copy_JTF_Notes (
    p_api_version               IN              NUMBER,
    p_init_msg_list             IN              VARCHAR2,
    p_commit                    IN              VARCHAR2,
    p_validation_level          IN              NUMBER,
    x_return_status             OUT     NOCOPY  VARCHAR2,
    x_msg_count                 OUT     NOCOPY  NUMBER,
    x_msg_data                  OUT     NOCOPY  VARCHAR2,
    p_original_repair_line_id   IN              NUMBER,
    p_new_repair_line_id        IN              NUMBER
);

PROCEDURE Build_Ship_Prod_Txn_Tbl
( p_repair_line_id      IN	    NUMBER,
  x_prod_txn_tbl        OUT     NOCOPY	CSD_PROCESS_PVT.PRODUCT_TXN_TBL,
  x_return_status       OUT     NOCOPY	VARCHAR2
);

End CSD_SPLIT_PKG;

 

/
