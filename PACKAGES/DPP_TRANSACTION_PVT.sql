--------------------------------------------------------
--  DDL for Package DPP_TRANSACTION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."DPP_TRANSACTION_PVT" AUTHID CURRENT_USER AS
/* $Header: dppvtxns.pls 120.8.12010000.3 2009/08/17 10:31:25 rvkondur ship $ */
    TYPE txn_header_rec IS RECORD
    (
    TRANSACTION_HEADER_ID               NUMBER,
    TRANSACTION_INT_HEADER_ID           NUMBER,
    TRANSACTION_NUMBER                  VARCHAR2(40),
    REF_DOCUMENT_NUMBER                 VARCHAR2(40),
    CONTACT_EMAIL_ADDRESS               VARCHAR2(2000),
    CONTACT_PHONE                       VARCHAR2(40),
    TRANSACTION_SOURCE                  VARCHAR2(40),
    TRANSACTION_CREATION_DATE           DATE,
    EFFECTIVE_START_DATE                DATE,
    DAYS_COVERED                        NUMBER,
    TRANSACTION_STATUS                  VARCHAR2(20),
    ORG_ID                              VARCHAR2(150),
    ORIG_SYS_DOCUMENT_REF               VARCHAR2(40),
    CREATION_DATE                       DATE,
    CREATED_BY                          NUMBER,
    LAST_UPDATE_DATE                    DATE,
    LAST_UPDATED_BY                     NUMBER,
    LAST_UPDATE_LOGIN                   NUMBER,
    REQUEST_ID                          NUMBER,
    PROGRAM_APPLICATION_ID              NUMBER,
    PROGRAM_ID                          NUMBER,
    PROGRAM_UPDATE_DATE                 DATE,
    ATTRIBUTE_CATEGORY                  VARCHAR2(30),
    ATTRIBUTE1                          VARCHAR2(150),
    ATTRIBUTE2                          VARCHAR2(150),
    ATTRIBUTE3                          VARCHAR2(150),
    ATTRIBUTE4                          VARCHAR2(150),
    ATTRIBUTE5                          VARCHAR2(150),
    ATTRIBUTE6                          VARCHAR2(150),
    ATTRIBUTE7                          VARCHAR2(150),
    ATTRIBUTE8                          VARCHAR2(150),
    ATTRIBUTE9                          VARCHAR2(150),
    ATTRIBUTE10                         VARCHAR2(150),
    ATTRIBUTE11                         VARCHAR2(150),
    ATTRIBUTE12                         VARCHAR2(150),
    ATTRIBUTE13                         VARCHAR2(150),
    ATTRIBUTE14                         VARCHAR2(150),
    ATTRIBUTE15                         VARCHAR2(150),
    ATTRIBUTE16                         VARCHAR2(150),
    ATTRIBUTE17                         VARCHAR2(150),
    ATTRIBUTE18                         VARCHAR2(150),
    ATTRIBUTE19                         VARCHAR2(150),
    ATTRIBUTE20                         VARCHAR2(150),
    ATTRIBUTE21                         VARCHAR2(150),
    ATTRIBUTE22                         VARCHAR2(150),
    ATTRIBUTE23                         VARCHAR2(150),
    ATTRIBUTE24                         VARCHAR2(150),
    ATTRIBUTE25                         VARCHAR2(150),
    ATTRIBUTE26                         VARCHAR2(150),
    ATTRIBUTE27                         VARCHAR2(150),
    ATTRIBUTE28                         VARCHAR2(150),
    ATTRIBUTE29                         VARCHAR2(150),
    ATTRIBUTE30                         VARCHAR2(150),
    VENDOR_ID                           VARCHAR2(150),
    VENDOR_CONTACT_ID                   VARCHAR2(150),
    VENDOR_SITE_ID                      VARCHAR2(150),
    LAST_REFRESHED_BY                   NUMBER,
    TRX_CURRENCY                        VARCHAR2(30),
    LAST_REFRESHED_DATE                 DATE,
    OPERATING_UNIT_NAME                 VARCHAR2(150),
    VENDOR_NAME                         VARCHAR2(150),
    VENDOR_SITE_CODE                    VARCHAR2(150),
    VENDOR_CONTACT_NAME                 VARCHAR2(50),
    SUPPLIER_APPROVED_BY                VARCHAR2(100),
    SUPPLIER_APPROVAL_DATE              DATE,
    SUPP_DIST_CLAIM_ID            VARCHAR2(150),
    SUPP_DIST_CLAIM_NUMBER              VARCHAR2(150),
    INTERFACE_STATUS                    VARCHAR2(1),
    ERROR_CODE                           VARCHAR2(30),
    INVENTORY_ORGANIZATION_ID            NUMBER,
    FUNCTIONAL_CURRENCY                 VARCHAR2(150)
    );

    TYPE txn_lines_rec IS RECORD
    (
    TRANSACTION_HEADER_ID               NUMBER,
    TRANSACTION_LINE_ID                 NUMBER,
    TRANSACTION_INT_LINE_ID             NUMBER,
    TRANSACTION_INT_HEADER_ID           NUMBER,
    SUPPLIER_PART_NUM                   VARCHAR2(240),
    LINE_NUMBER                         NUMBER,
    PRIOR_PRICE                         NUMBER,
    CHANGE_TYPE                         VARCHAR2(30),
    CHANGE_VALUE                        NUMBER,
    PRICE_CHANGE                        NUMBER,
    COVERED_INVENTORY                   NUMBER,
    APPROVED_INVENTORY                  NUMBER,
    UOM                                 VARCHAR2(3),
    ORG_ID                              VARCHAR2(150),
    ORIG_SYS_DOCUMENT_LINE_REF          VARCHAR2(40),
    LINE_STATUS                         VARCHAR2(40),
    CREATION_DATE                       DATE,
    CREATED_BY                          NUMBER,
    LAST_UPDATE_DATE                    DATE,
    LAST_UPDATED_BY                     NUMBER,
    LAST_UPDATE_LOGIN                   NUMBER,
    REQUEST_ID                          NUMBER,
    PROGRAM_APPLICATION_ID              NUMBER,
    PROGRAM_ID                          NUMBER,
    PROGRAM_UPDATE_DATE                 DATE,
    ATTRIBUTE_CATEGORY                  VARCHAR2(30),
    ATTRIBUTE1                          VARCHAR2(150),
    ATTRIBUTE2                          VARCHAR2(150),
    ATTRIBUTE3                          VARCHAR2(150),
    ATTRIBUTE4                          VARCHAR2(150),
    ATTRIBUTE5                          VARCHAR2(150),
    ATTRIBUTE6                          VARCHAR2(150),
    ATTRIBUTE7                          VARCHAR2(150),
    ATTRIBUTE8                          VARCHAR2(150),
    ATTRIBUTE9                          VARCHAR2(150),
    ATTRIBUTE10                         VARCHAR2(150),
    ATTRIBUTE11                         VARCHAR2(150),
    ATTRIBUTE12                         VARCHAR2(150),
    ATTRIBUTE13                         VARCHAR2(150),
    ATTRIBUTE14                         VARCHAR2(150),
    ATTRIBUTE15                         VARCHAR2(150),
    ATTRIBUTE16                         VARCHAR2(150),
    ATTRIBUTE17                         VARCHAR2(150),
    ATTRIBUTE18                         VARCHAR2(150),
    ATTRIBUTE19                         VARCHAR2(150),
    ATTRIBUTE20                         VARCHAR2(150),
    ATTRIBUTE21                         VARCHAR2(150),
    ATTRIBUTE22                         VARCHAR2(150),
    ATTRIBUTE23                         VARCHAR2(150),
    ATTRIBUTE24                         VARCHAR2(150),
    ATTRIBUTE25                         VARCHAR2(150),
    ATTRIBUTE26                         VARCHAR2(150),
    ATTRIBUTE27                         VARCHAR2(150),
    ATTRIBUTE28                         VARCHAR2(150),
    ATTRIBUTE29                         VARCHAR2(150),
    ATTRIBUTE30                         VARCHAR2(150),
    INVENTORY_ITEM_ID                   VARCHAR2(150),
    SUPPLIER_NEW_PRICE                  NUMBER,
    LAST_CALCULATED_BY                  NUMBER,
    LAST_CALCULATED_DATE                DATE,
    CLAIM_AMOUNT                        NUMBER,
    SUPP_DIST_CLAIM_ID                  VARCHAR2(150),
    UPDATE_PURCHASING_DOCS              VARCHAR2(1),
    NOTIFY_PURCHASING_DOCS              VARCHAR2(1),
    UPDATE_INVENTORY_COSTING            VARCHAR2(1),
    UPDATE_ITEM_LIST_PRICE              VARCHAR2(1),
    SUPP_DIST_CLAIM_STATUS              VARCHAR2(1),
    ONHAND_INVENTORY                    NUMBER,
    MANUALLY_ADJUSTED                   VARCHAR2(1) ,
    NOTIFY_INBOUND_PRICELIST            VARCHAR2(1),
    NOTIFY_OUTBOUND_PRICELIST           VARCHAR2(1),
    SUPPLIER_APPROVED_BY                VARCHAR2(100),
    SUPPLIER_APPROVAL_DATE              DATE,
    NOTIFY_PROMOTIONS_PRICELIST         VARCHAR2(1),
    ITEM_NUMBER                         VARCHAR2(240),
    INTERFACE_STATUS                    VARCHAR2(1),
    ERROR_CODE                           VARCHAR2(30),
    LIST_PRICE                              NUMBER
    );

    TYPE  txn_lines_tbl      IS TABLE OF txn_lines_rec INDEX BY BINARY_INTEGER;

    PROCEDURE create_transaction(
                                errbuf                      OUT NOCOPY VARCHAR2
                            ,   retcode                     OUT NOCOPY VARCHAR2
                            ,   p_operating_unit           IN VARCHAR2 DEFAULT NULL
                            ,   p_supplier_name            IN VARCHAR2
                            ,   p_supplier_site            IN VARCHAR2 DEFAULT NULL
                            ,   p_document_reference_number IN VARCHAR2 DEFAULT NULL
                            );

    ---------------------------------------------------------------------
     -- PROCEDURE
     --    Insert_Transaction
     --
     -- PURPOSE
     --    It calls different procedure which validates and inserts
     --    records in to dpp transaction header and lines table.
     --
     -- PARAMETERS
     --   p_transaction_int_header_id
     -- NOTES
     --    1.
     --    2.
     ----------------------------------------------------------------------
    PROCEDURE Insert_Transaction(
                            p_api_version        IN       NUMBER
                        ,   p_init_msg_list      IN       VARCHAR2     := FND_API.G_FALSE
                        ,   p_commit             IN       VARCHAR2     := FND_API.G_FALSE
                        ,   p_validation_level   IN       NUMBER       := FND_API.G_VALID_LEVEL_FULL
                        ,   p_transaction_int_header_id IN NUMBER
                        ,   p_operating_unit     IN VARCHAR2 DEFAULT NULL
                        ,   x_return_status      OUT NOCOPY   VARCHAR2
                        ,   x_msg_count          OUT NOCOPY   NUMBER
                        ,   x_msg_data           OUT NOCOPY   VARCHAR2
                        );


    PROCEDURE Raise_OutBoundEvent(
                          p_api_version         IN      NUMBER
                         ,p_init_msg_list       IN      VARCHAR2     := FND_API.G_FALSE
                         ,p_commit              IN      VARCHAR2     := FND_API.G_FALSE
                         ,p_validation_level    IN      NUMBER       := FND_API.G_VALID_LEVEL_FULL
                         ,p_party_id            IN      VARCHAR2
                         ,p_party_site_id       IN      VARCHAR2
                         ,p_claim_id            IN      VARCHAR2
                         ,p_party_type          IN      VARCHAR2
                         ,x_return_status       OUT NOCOPY  VARCHAR2
                         ,x_msg_count           OUT NOCOPY  NUMBER
                         ,x_msg_data            OUT NOCOPY  VARCHAR2
                         );

    PROCEDURE inbound_transaction(
            p_distributor_operating_unit   IN VARCHAR2,
            p_document_reference           IN VARCHAR2,
            p_supplier_name                IN VARCHAR2,
            p_supplier_site                IN VARCHAR2,
            p_supplier_contact             IN VARCHAR2,
            p_supplier_contact_phone       IN VARCHAR2,
            p_supplier_contact_email       IN VARCHAR2,
            p_effective_date               IN DATE,
            p_days_covered                 IN NUMBER,
            p_currency                     IN VARCHAR2,
            p_hdrattributecontext          IN VARCHAR2,
            p_hdrattribute1                IN VARCHAR2,
            p_hdrattribute2                IN VARCHAR2,
            p_hdrattribute3                IN VARCHAR2,
            p_hdrattribute4                IN VARCHAR2,
            p_hdrattribute5                IN VARCHAR2,
            p_hdrattribute6                IN VARCHAR2,
            p_hdrattribute7                IN VARCHAR2,
            p_hdrattribute8                IN VARCHAR2,
            p_hdrattribute9                IN VARCHAR2,
            p_hdrattribute10               IN VARCHAR2,
            p_hdrattribute11               IN VARCHAR2,
            p_hdrattribute12               IN VARCHAR2,
            p_hdrattribute13               IN VARCHAR2,
            p_hdrattribute14               IN VARCHAR2,
            p_hdrattribute15               IN VARCHAR2,
            p_hdrattribute16               IN VARCHAR2,
            p_hdrattribute17               IN VARCHAR2,
            p_hdrattribute18               IN VARCHAR2,
            p_hdrattribute19               IN VARCHAR2,
            p_hdrattribute20               IN VARCHAR2,
            p_hdrattribute21               IN VARCHAR2,
            p_hdrattribute22               IN VARCHAR2,
            p_hdrattribute23               IN VARCHAR2,
            p_hdrattribute24               IN VARCHAR2,
            p_hdrattribute25               IN VARCHAR2,
            p_hdrattribute26               IN VARCHAR2,
            p_hdrattribute27               IN VARCHAR2,
            p_hdrattribute28               IN VARCHAR2,
            p_hdrattribute29               IN VARCHAR2,
            p_hdrattribute30               IN VARCHAR2,
            p_supplier_part_num            IN VARCHAR2,
            p_item_number                  IN VARCHAR2,
            p_change_type                  IN VARCHAR2,
            p_change_value                 IN NUMBER,
            p_uom                          IN VARCHAR2,
            p_dtlattributecontext          IN VARCHAR2,
            p_dtlattribute1                IN VARCHAR2,
            p_dtlattribute2                IN VARCHAR2,
            p_dtlattribute3                IN VARCHAR2,
            p_dtlattribute4                IN VARCHAR2,
            p_dtlattribute5                IN VARCHAR2,
            p_dtlattribute6                IN VARCHAR2,
            p_dtlattribute7                IN VARCHAR2,
            p_dtlattribute8                IN VARCHAR2,
            p_dtlattribute9                IN VARCHAR2,
            p_dtlattribute10               IN VARCHAR2,
            p_dtlattribute11               IN VARCHAR2,
            p_dtlattribute12               IN VARCHAR2,
            p_dtlattribute13               IN VARCHAR2,
            p_dtlattribute14               IN VARCHAR2,
            p_dtlattribute15               IN VARCHAR2,
            p_dtlattribute16               IN VARCHAR2,
            p_dtlattribute17               IN VARCHAR2,
            p_dtlattribute18               IN VARCHAR2,
            p_dtlattribute19               IN VARCHAR2,
            p_dtlattribute20               IN VARCHAR2,
            p_dtlattribute21               IN VARCHAR2,
            p_dtlattribute22               IN VARCHAR2,
            p_dtlattribute23               IN VARCHAR2,
            p_dtlattribute24               IN VARCHAR2,
            p_dtlattribute25               IN VARCHAR2,
            p_dtlattribute26               IN VARCHAR2,
            p_dtlattribute27               IN VARCHAR2,
            p_dtlattribute28               IN VARCHAR2,
            p_dtlattribute29               IN VARCHAR2,
            p_dtlattribute30               IN VARCHAR2
            );


    PROCEDURE create_webadi_transaction(
                                p_document_reference_number IN VARCHAR2
                            ,   p_supplier_name             IN VARCHAR2
                            ,   p_supplier_site             IN VARCHAR2
                            ,   p_operating_unit            IN VARCHAR2
                            ,   x_return_status            OUT NOCOPY VARCHAR2
                            ,   x_msg_data                 OUT NOCOPY VARCHAR2
                            );

    PROCEDURE inbound_approval(
            p_distributor_operating_unit   IN VARCHAR2,
            p_document_reference           IN VARCHAR2,
            p_supplier_name                IN VARCHAR2,
            p_supplier_site                IN VARCHAR2,
            p_supplier_contact             IN VARCHAR2,
            p_supplier_contact_phone       IN VARCHAR2,
            p_supplier_contact_email       IN VARCHAR2,
            p_effective_date               IN DATE,
            p_days_covered                 IN NUMBER,
            p_currency                     IN VARCHAR2,
            p_supplier_approved_by         IN VARCHAR2,
            p_supplier_approval_date       IN DATE,
            p_supp_dist_claim_number       IN VARCHAR2,
            p_hdrattributecontext          IN VARCHAR2,
            p_hdrattribute1                IN VARCHAR2,
            p_hdrattribute2                IN VARCHAR2,
            p_hdrattribute3                IN VARCHAR2,
            p_hdrattribute4                IN VARCHAR2,
            p_hdrattribute5                IN VARCHAR2,
            p_hdrattribute6                IN VARCHAR2,
            p_hdrattribute7                IN VARCHAR2,
            p_hdrattribute8                IN VARCHAR2,
            p_hdrattribute9                IN VARCHAR2,
            p_hdrattribute10               IN VARCHAR2,
            p_hdrattribute11               IN VARCHAR2,
            p_hdrattribute12               IN VARCHAR2,
            p_hdrattribute13               IN VARCHAR2,
            p_hdrattribute14               IN VARCHAR2,
            p_hdrattribute15               IN VARCHAR2,
            p_hdrattribute16               IN VARCHAR2,
            p_hdrattribute17               IN VARCHAR2,
            p_hdrattribute18               IN VARCHAR2,
            p_hdrattribute19               IN VARCHAR2,
            p_hdrattribute20               IN VARCHAR2,
            p_hdrattribute21               IN VARCHAR2,
            p_hdrattribute22               IN VARCHAR2,
            p_hdrattribute23               IN VARCHAR2,
            p_hdrattribute24               IN VARCHAR2,
            p_hdrattribute25               IN VARCHAR2,
            p_hdrattribute26               IN VARCHAR2,
            p_hdrattribute27               IN VARCHAR2,
            p_hdrattribute28               IN VARCHAR2,
            p_hdrattribute29               IN VARCHAR2,
            p_hdrattribute30               IN VARCHAR2,
            p_supplier_part_num            IN VARCHAR2,
            p_item_number                  IN VARCHAR2,
            p_change_type                  IN VARCHAR2,
            p_change_value                 IN NUMBER,
            p_uom                          IN VARCHAR2,
            p_approved_inventory           IN NUMBER,
            p_dtlattributecontext          IN VARCHAR2,
            p_dtlattribute1                IN VARCHAR2,
            p_dtlattribute2                IN VARCHAR2,
            p_dtlattribute3                IN VARCHAR2,
            p_dtlattribute4                IN VARCHAR2,
            p_dtlattribute5                IN VARCHAR2,
            p_dtlattribute6                IN VARCHAR2,
            p_dtlattribute7                IN VARCHAR2,
            p_dtlattribute8                IN VARCHAR2,
            p_dtlattribute9                IN VARCHAR2,
            p_dtlattribute10               IN VARCHAR2,
            p_dtlattribute11               IN VARCHAR2,
            p_dtlattribute12               IN VARCHAR2,
            p_dtlattribute13               IN VARCHAR2,
            p_dtlattribute14               IN VARCHAR2,
            p_dtlattribute15               IN VARCHAR2,
            p_dtlattribute16               IN VARCHAR2,
            p_dtlattribute17               IN VARCHAR2,
            p_dtlattribute18               IN VARCHAR2,
            p_dtlattribute19               IN VARCHAR2,
            p_dtlattribute20               IN VARCHAR2,
            p_dtlattribute21               IN VARCHAR2,
            p_dtlattribute22               IN VARCHAR2,
            p_dtlattribute23               IN VARCHAR2,
            p_dtlattribute24               IN VARCHAR2,
            p_dtlattribute25               IN VARCHAR2,
            p_dtlattribute26               IN VARCHAR2,
            p_dtlattribute27               IN VARCHAR2,
            p_dtlattribute28               IN VARCHAR2,
            p_dtlattribute29               IN VARCHAR2,
            p_dtlattribute30               IN VARCHAR2,
            x_return_status                OUT NOCOPY VARCHAR2
            );

END DPP_TRANSACTION_PVT;

/
