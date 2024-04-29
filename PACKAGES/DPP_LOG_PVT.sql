--------------------------------------------------------
--  DDL for Package DPP_LOG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."DPP_LOG_PVT" AUTHID CURRENT_USER AS
/* $Header: dppvlogs.pls 120.3.12010000.2 2009/08/17 10:27:31 rvkondur ship $ */
TYPE dpp_cst_hdr_rec_type IS RECORD
(
LOG_MODE																	VARCHAR2(1),
TRANSACTION_HEADER_ID                     NUMBER,
TRANSACTION_NUMBER                        VARCHAR2(40),
REF_DOCUMENT_NUMBER                       VARCHAR2(40),
CONTACT_EMAIL_ADDRESS                              VARCHAR2(2000),
CONTACT_PHONE                                      VARCHAR2(40),
TRANSACTION_SOURCE                        VARCHAR2(40),
TRANSACTION_CREATION_DATE                 DATE,
EFFECTIVE_START_DATE                      DATE,
DAYS_COVERED                              NUMBER,
TRANSACTION_STATUS                        VARCHAR2(20),
ORG_ID                                             NUMBER,
ORIG_SYS_DOCUMENT_REF                              VARCHAR2(40),
CREATION_DATE                             DATE,
CREATED_BY                                NUMBER,
LAST_UPDATE_DATE                          DATE,
LAST_UPDATED_BY                           NUMBER,
LAST_UPDATE_LOGIN                         NUMBER,
ATTRIBUTE_CATEGORY                        VARCHAR2(30),
ATTRIBUTE1                                VARCHAR2(150),
ATTRIBUTE2                                VARCHAR2(150),
ATTRIBUTE3                                VARCHAR2(150),
ATTRIBUTE4                                VARCHAR2(150),
ATTRIBUTE5                                VARCHAR2(150),
ATTRIBUTE6                                VARCHAR2(150),
ATTRIBUTE7                                VARCHAR2(150),
ATTRIBUTE8                                VARCHAR2(150),
ATTRIBUTE9                                VARCHAR2(150),
ATTRIBUTE10                               VARCHAR2(150),
ATTRIBUTE11                               VARCHAR2(150),
ATTRIBUTE12                               VARCHAR2(150),
ATTRIBUTE13                               VARCHAR2(150),
ATTRIBUTE14                               VARCHAR2(150),
ATTRIBUTE15                               VARCHAR2(150),
ATTRIBUTE16                               VARCHAR2(150),
ATTRIBUTE17                               VARCHAR2(150),
ATTRIBUTE18                               VARCHAR2(150),
ATTRIBUTE19                               VARCHAR2(150),
ATTRIBUTE20                               VARCHAR2(150),
ATTRIBUTE21                               VARCHAR2(150),
ATTRIBUTE22                               VARCHAR2(150),
ATTRIBUTE23                               VARCHAR2(150),
ATTRIBUTE24                               VARCHAR2(150),
ATTRIBUTE25                               VARCHAR2(150),
ATTRIBUTE26                               VARCHAR2(150),
ATTRIBUTE27                               VARCHAR2(150),
ATTRIBUTE28                               VARCHAR2(150),
ATTRIBUTE29                               VARCHAR2(150),
ATTRIBUTE30                               VARCHAR2(150),
VENDOR_ID                                 VARCHAR2(150),
VENDOR_CONTACT_ID                         VARCHAR2(150),
VENDOR_SITE_ID                            VARCHAR2(150),
LAST_REFRESHED_BY                         NUMBER,
LAST_REFRESHED_DATE												DATE,
TRX_CURRENCY                              VARCHAR2(3),
VENDOR_CONTACT_NAME                                VARCHAR2(50)
);

TYPE dpp_txn_line_rec_type IS RECORD
(
 LOG_MODE		VARCHAR2(1),
 TRANSACTION_HEADER_ID                              NUMBER,
 TRANSACTION_LINE_ID                       NUMBER,
 SUPPLIER_PART_NUM                                  VARCHAR2(240),
 LINE_NUMBER                                        NUMBER,
 PRIOR_PRICE                                        NUMBER,
 CHANGE_TYPE                                        VARCHAR2(30),
 CHANGE_VALUE                                       NUMBER,
 PRICE_CHANGE                                       NUMBER,
 COVERED_INVENTORY                                  NUMBER,
 APPROVED_INVENTORY                                 NUMBER,
 ORG_ID                                             NUMBER,
 CREATION_DATE                             DATE,
 CREATED_BY                                NUMBER,
 LAST_UPDATE_DATE                          DATE,
 LAST_UPDATED_BY                           NUMBER,
 LAST_UPDATE_LOGIN                         NUMBER,
 ATTRIBUTE_CATEGORY                                 VARCHAR2(30),
 ATTRIBUTE1                                         VARCHAR2(150),
 ATTRIBUTE2                                         VARCHAR2(150),
 ATTRIBUTE3                                         VARCHAR2(150),
 ATTRIBUTE4                                         VARCHAR2(150),
 ATTRIBUTE5                                         VARCHAR2(150),
 ATTRIBUTE6                                         VARCHAR2(150),
 ATTRIBUTE7                                         VARCHAR2(150),
 ATTRIBUTE8                                         VARCHAR2(150),
 ATTRIBUTE9                                         VARCHAR2(150),
 ATTRIBUTE10                                        VARCHAR2(150),
 ATTRIBUTE11                                        VARCHAR2(150),
 ATTRIBUTE12                                        VARCHAR2(150),
 ATTRIBUTE13                                        VARCHAR2(150),
 ATTRIBUTE14                                        VARCHAR2(150),
 ATTRIBUTE15                                        VARCHAR2(150),
 ATTRIBUTE16                               VARCHAR2(150),
 ATTRIBUTE17                               VARCHAR2(150),
 ATTRIBUTE18                               VARCHAR2(150),
 ATTRIBUTE19                               VARCHAR2(150),
 ATTRIBUTE20                               VARCHAR2(150),
 ATTRIBUTE21                               VARCHAR2(150),
 ATTRIBUTE22                               VARCHAR2(150),
 ATTRIBUTE23                               VARCHAR2(150),
 ATTRIBUTE24                               VARCHAR2(150),
 ATTRIBUTE25                               VARCHAR2(150),
 ATTRIBUTE26                               VARCHAR2(150),
 ATTRIBUTE27                               VARCHAR2(150),
 ATTRIBUTE28                               VARCHAR2(150),
 ATTRIBUTE29                               VARCHAR2(150),
 ATTRIBUTE30                               VARCHAR2(150),
 INVENTORY_ITEM_ID                                  VARCHAR2(150),
 SUPPLIER_NEW_PRICE                                 NUMBER,
 LAST_CALCULATED_BY                                 NUMBER,
 LAST_CALCULATED_DATE                               DATE,
 CLAIM_AMOUNT                                       NUMBER,
 SUPP_DIST_CLAIM_ID                                 VARCHAR2(150),
 UPDATE_PURCHASING_DOCS                    VARCHAR2(1),
 NOTIFY_PURCHASING_DOCS                    VARCHAR2(1),
 UPDATE_INVENTORY_COSTING                  VARCHAR2(1),
 UPDATE_ITEM_LIST_PRICE                    VARCHAR2(1),
 SUPP_DIST_CLAIM_STATUS                             VARCHAR2(1),
 ONHAND_INVENTORY                                   NUMBER,
 MANUALLY_ADJUSTED                                  VARCHAR2(1),
 NOTIFY_INBOUND_PRICELIST                  VARCHAR2(1),
 NOTIFY_OUTBOUND_PRICELIST                 VARCHAR2(1),
 NOTIFY_PROMOTIONS_PRICELIST                 VARCHAR2(1),
 SUPPLIER_APPROVED_BY                               VARCHAR2(100),
 SUPPLIER_APPROVAL_DATE                             DATE,
 CREATE_ON_HAND_CLAIM                      VARCHAR2(1),
 CREATE_VEND_CUST_CLAIM                    VARCHAR2(1)
);
G_dpp_txn_line_rec    dpp_txn_line_rec_type;
TYPE  dpp_txn_line_tbl_type      IS TABLE OF dpp_txn_line_rec_type INDEX BY BINARY_INTEGER;

TYPE dpp_claim_line_rec_type IS RECORD
(
LOG_MODE		VARCHAR2(1),
TRANSACTION_HEADER_ID                              NUMBER,
CUSTOMER_INV_LINE_ID                               NUMBER,
LINE_NUMBER                                        NUMBER,
LAST_PRICE                                         NUMBER,
SUPPLIER_NEW_PRICE                                 NUMBER,
CUSTOMER_NEW_PRICE                                 NUMBER,
REPORTED_INVENTORY                                 NUMBER,
CALCULATED_INVENTORY                               NUMBER,
CUST_CLAIM_AMT                                     NUMBER,
DEBIT_MEMO_NUMBER                                  VARCHAR2(30),
CUSTOMER_CLAIM_ID                                  NUMBER,
CUSTOMER_CLAIM_CREATED                             VARCHAR2(1),
SUPPLIER_CLAIM_CREATED                               VARCHAR2(1),
CREATION_DATE                              DATE,
CREATED_BY                                 NUMBER,
LAST_UPDATE_DATE                           DATE,
LAST_UPDATED_BY                           NUMBER,
LAST_UPDATE_LOGIN                          NUMBER(15),
ATTRIBUTE_CATEGORY                                 VARCHAR2(30),
ATTRIBUTE1                                         VARCHAR2(150),
ATTRIBUTE2                                         VARCHAR2(150),
ATTRIBUTE3                                         VARCHAR2(150),
ATTRIBUTE4                                         VARCHAR2(150),
ATTRIBUTE5                                         VARCHAR2(150),
ATTRIBUTE6                                         VARCHAR2(150),
ATTRIBUTE7                                         VARCHAR2(150),
ATTRIBUTE8                                         VARCHAR2(150),
ATTRIBUTE9                                         VARCHAR2(150),
ATTRIBUTE10                                        VARCHAR2(150),
ATTRIBUTE11                                        VARCHAR2(150),
ATTRIBUTE12                                        VARCHAR2(150),
ATTRIBUTE13                                        VARCHAR2(150),
ATTRIBUTE14                                        VARCHAR2(150),
ATTRIBUTE15                                        VARCHAR2(150),
ATTRIBUTE16                               VARCHAR2(150),
ATTRIBUTE17                               VARCHAR2(150),
ATTRIBUTE18                               VARCHAR2(150),
ATTRIBUTE19                               VARCHAR2(150),
ATTRIBUTE20                               VARCHAR2(150),
ATTRIBUTE21                               VARCHAR2(150),
ATTRIBUTE22                               VARCHAR2(150),
ATTRIBUTE23                               VARCHAR2(150),
ATTRIBUTE24                               VARCHAR2(150),
ATTRIBUTE25                               VARCHAR2(150),
ATTRIBUTE26                               VARCHAR2(150),
ATTRIBUTE27                               VARCHAR2(150),
ATTRIBUTE28                               VARCHAR2(150),
ATTRIBUTE29                               VARCHAR2(150),
ATTRIBUTE30                               VARCHAR2(150),
INVENTORY_ITEM_ID                                  VARCHAR2(150),
SUPP_CLAIM_AMT                                     NUMBER,
SUPP_CUST_CLAIM_ID                                 NUMBER,
CUST_ACCOUNT_ID																		 VARCHAR2(150),
ORG_ID                                             VARCHAR2(150),
TRX_CURRENCY															VARCHAR2(15)
);
G_dpp_claim_line_rec    dpp_claim_line_rec_type;
TYPE  dpp_claim_line_tbl_type      IS TABLE OF dpp_claim_line_rec_type INDEX BY BINARY_INTEGER;
--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name :   Insert_HeaderLog
--   Type     :   Private
--   Pre-Req  :		None
--	 Function :		Inserts records into Headers Log Table
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_NONE
--       p_txn_hdr_rec       IN OUT  dpp_pl_notify_rec_type  Required
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--
--   End of Comments
--   ==============================================================================
PROCEDURE Insert_HeaderLog(
    p_api_version   	 IN 	  NUMBER
   ,p_init_msg_list	     IN 	  VARCHAR2     := FND_API.G_FALSE
   ,p_commit	         IN 	  VARCHAR2     := FND_API.G_FALSE
   ,p_validation_level	 IN 	  NUMBER       := FND_API.G_VALID_LEVEL_FULL
   ,x_return_status	     OUT 	NOCOPY  VARCHAR2
   ,x_msg_count	         OUT 	NOCOPY  NUMBER
   ,x_msg_data	         OUT 	NOCOPY  VARCHAR2
   ,p_txn_hdr_rec	     IN    dpp_cst_hdr_rec_type
);

PROCEDURE Insert_LinesLog(
    p_api_version   	 IN 	  NUMBER
   ,p_init_msg_list	     IN 	  VARCHAR2     := FND_API.G_FALSE
   ,p_commit	         IN 	  VARCHAR2     := FND_API.G_FALSE
   ,p_validation_level	 IN 	  NUMBER       := FND_API.G_VALID_LEVEL_FULL
   ,x_return_status	     OUT 	NOCOPY  VARCHAR2
   ,x_msg_count	         OUT 	NOCOPY  NUMBER
   ,x_msg_data	         OUT 	NOCOPY  VARCHAR2
   ,p_txn_lines_tbl	     IN    dpp_txn_line_tbl_type
);

PROCEDURE Insert_ClaimsLog(
    p_api_version   	 IN 	  NUMBER
   ,p_init_msg_list	     IN 	  VARCHAR2     := FND_API.G_FALSE
   ,p_commit	         IN 	  VARCHAR2     := FND_API.G_FALSE
   ,p_validation_level	 IN 	  NUMBER       := FND_API.G_VALID_LEVEL_FULL
   ,x_return_status	     OUT 	NOCOPY  VARCHAR2
   ,x_msg_count	         OUT 	NOCOPY  NUMBER
   ,x_msg_data	         OUT 	NOCOPY  VARCHAR2
   ,p_claim_lines_tbl	     IN    dpp_claim_line_tbl_type
);

END DPP_LOG_PVT;

/
