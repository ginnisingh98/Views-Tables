--------------------------------------------------------
--  DDL for Package AHL_RA_SETUPS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_RA_SETUPS_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVRASS.pls 120.1 2005/07/05 03:43 sagarwal noship $*/

-------------------------------------------------------------------
-- Define Record Type for AHL_RA_SETUPS --
-------------------------------------------------------------------
TYPE RA_SETUP_DATA_REC_TYPE IS RECORD (
        RA_SETUP_ID                    AHL_RA_SETUPS.RA_SETUP_ID%TYPE,
        SETUP_CODE                     AHL_RA_SETUPS.SETUP_CODE%TYPE,
        STATUS_ID                      AHL_RA_SETUPS.STATUS_ID%TYPE,
        REMOVAL_CODE                   AHL_RA_SETUPS.REMOVAL_CODE%TYPE,
        OPERATION_FLAG                 VARCHAR2(1),
        OBJECT_VERSION_NUMBER          AHL_RA_SETUPS.OBJECT_VERSION_NUMBER%TYPE,
        SECURITY_GROUP_ID              AHL_RA_SETUPS.SECURITY_GROUP_ID%TYPE,
        CREATION_DATE                  AHL_RA_SETUPS.CREATION_DATE%TYPE,
        CREATED_BY                     AHL_RA_SETUPS.CREATED_BY%TYPE,
        LAST_UPDATE_DATE               AHL_RA_SETUPS.LAST_UPDATE_DATE%TYPE,
        LAST_UPDATED_BY                AHL_RA_SETUPS.LAST_UPDATED_BY%TYPE,
        LAST_UPDATE_LOGIN              AHL_RA_SETUPS.LAST_UPDATE_LOGIN%TYPE,
        ATTRIBUTE_CATEGORY             AHL_RA_SETUPS.ATTRIBUTE_CATEGORY%TYPE,
        ATTRIBUTE1                     AHL_RA_SETUPS.ATTRIBUTE1%TYPE,
        ATTRIBUTE2                     AHL_RA_SETUPS.ATTRIBUTE2%TYPE,
        ATTRIBUTE3                     AHL_RA_SETUPS.ATTRIBUTE3%TYPE,
        ATTRIBUTE4                     AHL_RA_SETUPS.ATTRIBUTE4%TYPE,
        ATTRIBUTE5                     AHL_RA_SETUPS.ATTRIBUTE5%TYPE,
        ATTRIBUTE6                     AHL_RA_SETUPS.ATTRIBUTE6%TYPE,
        ATTRIBUTE7                     AHL_RA_SETUPS.ATTRIBUTE7%TYPE,
        ATTRIBUTE8                     AHL_RA_SETUPS.ATTRIBUTE8%TYPE,
        ATTRIBUTE9                     AHL_RA_SETUPS.ATTRIBUTE9%TYPE,
        ATTRIBUTE10                    AHL_RA_SETUPS.ATTRIBUTE10%TYPE,
        ATTRIBUTE11                    AHL_RA_SETUPS.ATTRIBUTE11%TYPE,
        ATTRIBUTE12                    AHL_RA_SETUPS.ATTRIBUTE12%TYPE,
        ATTRIBUTE13                    AHL_RA_SETUPS.ATTRIBUTE13%TYPE,
        ATTRIBUTE14                    AHL_RA_SETUPS.ATTRIBUTE14%TYPE,
        ATTRIBUTE15                    AHL_RA_SETUPS.ATTRIBUTE15%TYPE
        );


-------------------------------------------------------------------
-- Define Record Type for AHL_RA_DEFINITION_HDR --
-------------------------------------------------------------------
TYPE RA_DEFINITION_HDR_REC_TYPE IS RECORD (
        RA_DEFINITION_HDR_ID           AHL_RA_DEFINITION_HDR.RA_DEFINITION_HDR_ID%TYPE,
        MC_HEADER_ID                   AHL_RA_DEFINITION_HDR.MC_HEADER_ID%TYPE,
        INVENTORY_ITEM_ID              AHL_RA_DEFINITION_HDR.INVENTORY_ITEM_ID%TYPE,
        INVENTORY_ORG_ID               AHL_RA_DEFINITION_HDR.INVENTORY_ORG_ID%TYPE,
        ITEM_REVISION                  AHL_RA_DEFINITION_HDR.ITEM_REVISION%TYPE,
        RELATIONSHIP_ID                AHL_RA_DEFINITION_HDR.RELATIONSHIP_ID%TYPE,
        OPERATION_FLAG                 VARCHAR2(1),
        OBJECT_VERSION_NUMBER          AHL_RA_DEFINITION_HDR.OBJECT_VERSION_NUMBER%TYPE,
        SECURITY_GROUP_ID              AHL_RA_DEFINITION_HDR.SECURITY_GROUP_ID%TYPE,
        CREATION_DATE                  AHL_RA_DEFINITION_HDR.CREATION_DATE%TYPE,
        CREATED_BY                     AHL_RA_DEFINITION_HDR.CREATED_BY%TYPE,
        LAST_UPDATE_DATE               AHL_RA_DEFINITION_HDR.LAST_UPDATE_DATE%TYPE,
        LAST_UPDATED_BY                AHL_RA_DEFINITION_HDR.LAST_UPDATED_BY%TYPE,
        LAST_UPDATE_LOGIN              AHL_RA_DEFINITION_HDR.LAST_UPDATE_LOGIN%TYPE,
        ATTRIBUTE_CATEGORY             AHL_RA_DEFINITION_HDR.ATTRIBUTE_CATEGORY%TYPE,
        ATTRIBUTE1                     AHL_RA_DEFINITION_HDR.ATTRIBUTE1%TYPE,
        ATTRIBUTE2                     AHL_RA_DEFINITION_HDR.ATTRIBUTE2%TYPE,
        ATTRIBUTE3                     AHL_RA_DEFINITION_HDR.ATTRIBUTE3%TYPE,
        ATTRIBUTE4                     AHL_RA_DEFINITION_HDR.ATTRIBUTE4%TYPE,
        ATTRIBUTE5                     AHL_RA_DEFINITION_HDR.ATTRIBUTE5%TYPE,
        ATTRIBUTE6                     AHL_RA_DEFINITION_HDR.ATTRIBUTE6%TYPE,
        ATTRIBUTE7                     AHL_RA_DEFINITION_HDR.ATTRIBUTE7%TYPE,
        ATTRIBUTE8                     AHL_RA_DEFINITION_HDR.ATTRIBUTE8%TYPE,
        ATTRIBUTE9                     AHL_RA_DEFINITION_HDR.ATTRIBUTE9%TYPE,
        ATTRIBUTE10                    AHL_RA_DEFINITION_HDR.ATTRIBUTE10%TYPE,
        ATTRIBUTE11                    AHL_RA_DEFINITION_HDR.ATTRIBUTE11%TYPE,
        ATTRIBUTE12                    AHL_RA_DEFINITION_HDR.ATTRIBUTE12%TYPE,
        ATTRIBUTE13                    AHL_RA_DEFINITION_HDR.ATTRIBUTE13%TYPE,
        ATTRIBUTE14                    AHL_RA_DEFINITION_HDR.ATTRIBUTE14%TYPE,
        ATTRIBUTE15                    AHL_RA_DEFINITION_HDR.ATTRIBUTE15%TYPE
        );


-------------------------------------------------------------------
-- Define Record Type for AHL_RA_DEFINITION_DTLS --
-------------------------------------------------------------------
TYPE RA_DEFINITION_DTLS_REC_TYPE IS RECORD (
        RA_DEFINITION_DTL_ID          AHL_RA_DEFINITION_DTLS.RA_DEFINITION_DTL_ID%TYPE,
        RA_DEFINITION_HDR_ID          AHL_RA_DEFINITION_DTLS.RA_DEFINITION_HDR_ID%TYPE,
        COUNTER_ID                    AHL_RA_DEFINITION_DTLS.COUNTER_ID%TYPE,
        MTBF_VALUE                   AHL_RA_DEFINITION_DTLS.MTBF_VALUE%TYPE,
        OPERATION_FLAG                VARCHAR2(1),
        OBJECT_VERSION_NUMBER         AHL_RA_DEFINITION_DTLS.OBJECT_VERSION_NUMBER%TYPE,
        SECURITY_GROUP_ID             AHL_RA_DEFINITION_DTLS.SECURITY_GROUP_ID%TYPE,
        CREATION_DATE                 AHL_RA_DEFINITION_DTLS.CREATION_DATE%TYPE,
        CREATED_BY                    AHL_RA_DEFINITION_DTLS.CREATED_BY%TYPE,
        LAST_UPDATE_DATE              AHL_RA_DEFINITION_DTLS.LAST_UPDATE_DATE%TYPE,
        LAST_UPDATED_BY               AHL_RA_DEFINITION_DTLS.LAST_UPDATED_BY%TYPE,
        LAST_UPDATE_LOGIN             AHL_RA_DEFINITION_DTLS.LAST_UPDATE_LOGIN%TYPE,
        ATTRIBUTE_CATEGORY            AHL_RA_DEFINITION_DTLS.ATTRIBUTE_CATEGORY%TYPE,
        ATTRIBUTE1                    AHL_RA_DEFINITION_DTLS.ATTRIBUTE1%TYPE,
        ATTRIBUTE2                    AHL_RA_DEFINITION_DTLS.ATTRIBUTE2%TYPE,
        ATTRIBUTE3                    AHL_RA_DEFINITION_DTLS.ATTRIBUTE3%TYPE,
        ATTRIBUTE4                    AHL_RA_DEFINITION_DTLS.ATTRIBUTE4%TYPE,
        ATTRIBUTE5                    AHL_RA_DEFINITION_DTLS.ATTRIBUTE5%TYPE,
        ATTRIBUTE6                    AHL_RA_DEFINITION_DTLS.ATTRIBUTE6%TYPE,
        ATTRIBUTE7                    AHL_RA_DEFINITION_DTLS.ATTRIBUTE7%TYPE,
        ATTRIBUTE8                    AHL_RA_DEFINITION_DTLS.ATTRIBUTE8%TYPE,
        ATTRIBUTE9                    AHL_RA_DEFINITION_DTLS.ATTRIBUTE9%TYPE,
        ATTRIBUTE10                   AHL_RA_DEFINITION_DTLS.ATTRIBUTE10%TYPE,
        ATTRIBUTE11                   AHL_RA_DEFINITION_DTLS.ATTRIBUTE11%TYPE,
        ATTRIBUTE12                   AHL_RA_DEFINITION_DTLS.ATTRIBUTE12%TYPE,
        ATTRIBUTE13                   AHL_RA_DEFINITION_DTLS.ATTRIBUTE13%TYPE,
        ATTRIBUTE14                   AHL_RA_DEFINITION_DTLS.ATTRIBUTE14%TYPE,
        ATTRIBUTE15                   AHL_RA_DEFINITION_DTLS.ATTRIBUTE15%TYPE
        );


-------------------------------------------------------------------
-- Define Record Type for AHL_RA_CTR_ASSOCIATIONS --
-------------------------------------------------------------------
TYPE RA_COUNTER_ASSOC_REC_TYPE IS RECORD (
        RA_COUNTER_ASSOCIATION_ID      AHL_RA_CTR_ASSOCIATIONS.RA_COUNTER_ASSOCIATION_ID%TYPE,
        SINCE_NEW_COUNTER_ID           AHL_RA_CTR_ASSOCIATIONS.SINCE_NEW_COUNTER_ID%TYPE,
        SINCE_OVERHAUL_COUNTER_ID      AHL_RA_CTR_ASSOCIATIONS.SINCE_OVERHAUL_COUNTER_ID%TYPE,
        DESCRIPTION                    AHL_RA_CTR_ASSOCIATIONS.DESCRIPTION%TYPE,
        OPERATION_FLAG                 VARCHAR2(1),
        OBJECT_VERSION_NUMBER          AHL_RA_CTR_ASSOCIATIONS.OBJECT_VERSION_NUMBER%TYPE,
        SECURITY_GROUP_ID              AHL_RA_CTR_ASSOCIATIONS.SECURITY_GROUP_ID%TYPE,
        CREATION_DATE                  AHL_RA_CTR_ASSOCIATIONS.CREATION_DATE%TYPE,
        CREATED_BY                     AHL_RA_CTR_ASSOCIATIONS.CREATED_BY%TYPE,
        LAST_UPDATE_DATE               AHL_RA_CTR_ASSOCIATIONS.LAST_UPDATE_DATE%TYPE,
        LAST_UPDATED_BY                AHL_RA_CTR_ASSOCIATIONS.LAST_UPDATED_BY%TYPE,
        LAST_UPDATE_LOGIN              AHL_RA_CTR_ASSOCIATIONS.LAST_UPDATE_LOGIN%TYPE,
        ATTRIBUTE_CATEGORY             AHL_RA_CTR_ASSOCIATIONS.ATTRIBUTE_CATEGORY%TYPE,
        ATTRIBUTE1                     AHL_RA_CTR_ASSOCIATIONS.ATTRIBUTE1%TYPE,
        ATTRIBUTE2                     AHL_RA_CTR_ASSOCIATIONS.ATTRIBUTE2%TYPE,
        ATTRIBUTE3                     AHL_RA_CTR_ASSOCIATIONS.ATTRIBUTE3%TYPE,
        ATTRIBUTE4                     AHL_RA_CTR_ASSOCIATIONS.ATTRIBUTE4%TYPE,
        ATTRIBUTE5                     AHL_RA_CTR_ASSOCIATIONS.ATTRIBUTE5%TYPE,
        ATTRIBUTE6                     AHL_RA_CTR_ASSOCIATIONS.ATTRIBUTE6%TYPE,
        ATTRIBUTE7                     AHL_RA_CTR_ASSOCIATIONS.ATTRIBUTE7%TYPE,
        ATTRIBUTE8                     AHL_RA_CTR_ASSOCIATIONS.ATTRIBUTE8%TYPE,
        ATTRIBUTE9                     AHL_RA_CTR_ASSOCIATIONS.ATTRIBUTE9%TYPE,
        ATTRIBUTE10                    AHL_RA_CTR_ASSOCIATIONS.ATTRIBUTE10%TYPE,
        ATTRIBUTE11                    AHL_RA_CTR_ASSOCIATIONS.ATTRIBUTE11%TYPE,
        ATTRIBUTE12                    AHL_RA_CTR_ASSOCIATIONS.ATTRIBUTE12%TYPE,
        ATTRIBUTE13                    AHL_RA_CTR_ASSOCIATIONS.ATTRIBUTE13%TYPE,
        ATTRIBUTE14                    AHL_RA_CTR_ASSOCIATIONS.ATTRIBUTE14%TYPE,
        ATTRIBUTE15                    AHL_RA_CTR_ASSOCIATIONS.ATTRIBUTE15%TYPE
        );


-------------------------------------------------------------------
-- Define Record Type for AHL_RA_FCT_ASSOCIATIONS --
-------------------------------------------------------------------
TYPE RA_FCT_ASSOC_REC_TYPE IS RECORD (
        RA_FCT_ASSOCIATION_ID          AHL_RA_FCT_ASSOCIATIONS.RA_FCT_ASSOCIATION_ID%TYPE,
        FORECAST_DESIGNATOR            AHL_RA_FCT_ASSOCIATIONS.FORECAST_DESIGNATOR%TYPE,
        ASSOCIATION_TYPE_CODE          AHL_RA_FCT_ASSOCIATIONS.ASSOCIATION_TYPE_CODE%TYPE,
        ORGANIZATION_ID                AHL_RA_FCT_ASSOCIATIONS.ORGANIZATION_ID%TYPE,
        PROBABILITY_FROM               AHL_RA_FCT_ASSOCIATIONS.PROBABILITY_FROM%TYPE,
        PROBABILITY_TO                 AHL_RA_FCT_ASSOCIATIONS.PROBABILITY_TO%TYPE,
        OPERATION_FLAG                 VARCHAR2(1),
        OBJECT_VERSION_NUMBER          AHL_RA_FCT_ASSOCIATIONS.OBJECT_VERSION_NUMBER%TYPE,
        SECURITY_GROUP_ID              AHL_RA_FCT_ASSOCIATIONS.SECURITY_GROUP_ID%TYPE,
        CREATION_DATE                  AHL_RA_FCT_ASSOCIATIONS.CREATION_DATE%TYPE,
        CREATED_BY                     AHL_RA_FCT_ASSOCIATIONS.CREATED_BY%TYPE,
        LAST_UPDATE_DATE               AHL_RA_FCT_ASSOCIATIONS.LAST_UPDATE_DATE%TYPE,
        LAST_UPDATED_BY                AHL_RA_FCT_ASSOCIATIONS.LAST_UPDATED_BY%TYPE,
        LAST_UPDATE_LOGIN              AHL_RA_FCT_ASSOCIATIONS.LAST_UPDATE_LOGIN%TYPE,
        ATTRIBUTE_CATEGORY             AHL_RA_FCT_ASSOCIATIONS.ATTRIBUTE_CATEGORY%TYPE,
        ATTRIBUTE1                     AHL_RA_FCT_ASSOCIATIONS.ATTRIBUTE1%TYPE,
        ATTRIBUTE2                     AHL_RA_FCT_ASSOCIATIONS.ATTRIBUTE2%TYPE,
        ATTRIBUTE3                     AHL_RA_FCT_ASSOCIATIONS.ATTRIBUTE3%TYPE,
        ATTRIBUTE4                     AHL_RA_FCT_ASSOCIATIONS.ATTRIBUTE4%TYPE,
        ATTRIBUTE5                     AHL_RA_FCT_ASSOCIATIONS.ATTRIBUTE5%TYPE,
        ATTRIBUTE6                     AHL_RA_FCT_ASSOCIATIONS.ATTRIBUTE6%TYPE,
        ATTRIBUTE7                     AHL_RA_FCT_ASSOCIATIONS.ATTRIBUTE7%TYPE,
        ATTRIBUTE8                     AHL_RA_FCT_ASSOCIATIONS.ATTRIBUTE8%TYPE,
        ATTRIBUTE9                     AHL_RA_FCT_ASSOCIATIONS.ATTRIBUTE9%TYPE,
        ATTRIBUTE10                    AHL_RA_FCT_ASSOCIATIONS.ATTRIBUTE10%TYPE,
        ATTRIBUTE11                    AHL_RA_FCT_ASSOCIATIONS.ATTRIBUTE11%TYPE,
        ATTRIBUTE12                    AHL_RA_FCT_ASSOCIATIONS.ATTRIBUTE12%TYPE,
        ATTRIBUTE13                    AHL_RA_FCT_ASSOCIATIONS.ATTRIBUTE13%TYPE,
        ATTRIBUTE14                    AHL_RA_FCT_ASSOCIATIONS.ATTRIBUTE14%TYPE,
        ATTRIBUTE15                    AHL_RA_FCT_ASSOCIATIONS.ATTRIBUTE15%TYPE
        );



    --  Start of Comments  --
    --
    --  Procedure name      : CREATE_SETUP_DATA
    --  Type                : Private
    --  Function            : This API would create the setup data for Reliability Framework in AHL_RA_SETUPS table
    --  Pre-reqs            :
    --
    --  Standard IN  Parameters :
    --      p_api_version                   IN      NUMBER                Required
    --      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
    --      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
    --      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
    --
    --  Standard OUT Parameters :
    --      x_return_status                 OUT     VARCHAR2              Required
    --      x_msg_count                     OUT     NUMBER                Required
    --      x_msg_data                      OUT     VARCHAR2              Required
    --
    --  CREATE_SETUP_DATA Parameters :
    --      p_x_setup_data_rec          IN OUT  RA_SETUP_DATA_REC_TYPE  Required
    --
    --  Version :
    --      Initial Version   1.0
    --
    --  End of Comments  --
    PROCEDURE CREATE_SETUP_DATA (
        p_api_version         IN               NUMBER,
        p_init_msg_list       IN               VARCHAR2  := FND_API.G_FALSE,
        p_commit              IN               VARCHAR2  := FND_API.G_FALSE,
        p_validation_level    IN               NUMBER    := FND_API.G_VALID_LEVEL_FULL,
        p_module_type         IN               VARCHAR2,
        x_return_status       OUT      NOCOPY  VARCHAR2,
        x_msg_count           OUT      NOCOPY  NUMBER,
        x_msg_data            OUT      NOCOPY  VARCHAR2,
        p_x_setup_data_rec    IN  OUT  NOCOPY  AHL_RA_SETUPS_PVT.RA_SETUP_DATA_REC_TYPE);



    --  Start of Comments  --
    --
    --  Procedure name      : DELETE_SETUP_DATA
    --  Type                : Private
    --  Function            : This API would dalete the setup data for Reliability Framework in AHL_RA_SETUPS table
    --  Pre-reqs            :
    --
    --  Standard IN  Parameters :
    --      p_api_version                   IN      NUMBER                Required
    --      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
    --      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
    --      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
    --
    --  Standard OUT Parameters :
    --      x_return_status                 OUT     VARCHAR2              Required
    --      x_msg_count                     OUT     NUMBER                Required
    --      x_msg_data                      OUT     VARCHAR2              Required
    --
    --  DELETE_SETUP_DATA Parameters :
    --       p_setup_data_rec               IN      RA_SETUP_DATA_REC_TYPE  Required
    --
    --  Version :
    --      Initial Version   1.0
    --
    --  End of Comments  --
    PROCEDURE DELETE_SETUP_DATA (
        p_api_version         IN         NUMBER,
        p_init_msg_list       IN         VARCHAR2  := FND_API.G_FALSE,
        p_commit              IN         VARCHAR2  := FND_API.G_FALSE,
        p_validation_level    IN         NUMBER    := FND_API.G_VALID_LEVEL_FULL,
        p_module_type         IN         VARCHAR2,
        x_return_status       OUT NOCOPY VARCHAR2,
        x_msg_count           OUT NOCOPY NUMBER,
        x_msg_data            OUT NOCOPY VARCHAR2,
        p_setup_data_rec      IN         AHL_RA_SETUPS_PVT.RA_SETUP_DATA_REC_TYPE);




    --  Start of Comments  --
    --
    --  Procedure name      : CREATE_RELIABILITY_DATA
    --  Type                : Private
    --  Function            : This API would create the setup data for Reliability Framework in AHL_RA_DEFINITION_HDR
    --  Pre-reqs            :
    --
    --  Standard IN  Parameters :
    --      p_api_version                   IN      NUMBER                Required
    --      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
    --      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
    --      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
    --
    --  Standard OUT Parameters :
    --      x_return_status                 OUT     VARCHAR2              Required
    --      x_msg_count                     OUT     NUMBER                Required
    --      x_msg_data                      OUT     VARCHAR2              Required
    --
    --  CREATE_RELIABILITY_DATA Parameters :
    --      p_x_reliability_data_rec        IN OUT  RA_DEFINITION_HDR_REC_TYPE  Required
    --
    --  Version :
    --      Initial Version   1.0
    --
    --  End of Comments  --
    PROCEDURE CREATE_RELIABILITY_DATA (
        p_api_version               IN               NUMBER,
        p_init_msg_list             IN               VARCHAR2  := FND_API.G_FALSE,
        p_commit                    IN               VARCHAR2  := FND_API.G_FALSE,
        p_validation_level          IN               NUMBER    := FND_API.G_VALID_LEVEL_FULL,
        p_module_type               IN               VARCHAR2,
        x_return_status             OUT      NOCOPY  VARCHAR2,
        x_msg_count                 OUT      NOCOPY  NUMBER,
        x_msg_data                  OUT      NOCOPY  VARCHAR2,
        p_x_reliability_data_rec    IN  OUT  NOCOPY  AHL_RA_SETUPS_PVT.RA_DEFINITION_HDR_REC_TYPE);


    --  Start of Comments  --
    --
    --  Procedure name      : DELETE_RELIABILITY_DATA
    --  Type                : Private
    --  Function            : This API would delete the setup data for Reliability Framework in AHL_RA_DEFINITION_HDR
    --  Pre-reqs            :
    --
    --  Standard IN  Parameters :
    --      p_api_version                   IN      NUMBER                Required
    --      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
    --      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
    --      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
    --
    --  Standard OUT Parameters :
    --      x_return_status                 OUT     VARCHAR2              Required
    --      x_msg_count                     OUT     NUMBER                Required
    --      x_msg_data                      OUT     VARCHAR2              Required
    --
    --  DELETE_RELIABILITY_DATA Parameters :
    --      p_reliability_data_rec        IN OUT  RA_DEFINITION_HDR_REC_TYPE  Required
    --
    --  Version :
    --      Initial Version   1.0
    --
    --  End of Comments  --
    PROCEDURE DELETE_RELIABILITY_DATA (
        p_api_version               IN               NUMBER,
        p_init_msg_list             IN               VARCHAR2  := FND_API.G_FALSE,
        p_commit                    IN               VARCHAR2  := FND_API.G_FALSE,
        p_validation_level          IN               NUMBER    := FND_API.G_VALID_LEVEL_FULL,
        p_module_type               IN               VARCHAR2,
        x_return_status             OUT      NOCOPY  VARCHAR2,
        x_msg_count                 OUT      NOCOPY  NUMBER,
        x_msg_data                  OUT      NOCOPY  VARCHAR2,
        p_reliability_data_rec      IN               AHL_RA_SETUPS_PVT.RA_DEFINITION_HDR_REC_TYPE);


    --  Start of Comments  --
    --
    --  Procedure name      : CREATE_MTBF_DATA
    --  Type                : Private
    --  Function            : This API would create the setup data for Reliability Framework in AHL_RA_DEFINITION_DTLS
    --  Pre-reqs            :
    --
    --  Standard IN  Parameters :
    --      p_api_version                   IN      NUMBER                Required
    --      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
    --      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
    --      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
    --
    --  Standard OUT Parameters :
    --      x_return_status                 OUT     VARCHAR2              Required
    --      x_msg_count                     OUT     NUMBER                Required
    --      x_msg_data                      OUT     VARCHAR2              Required
    --
    --  CREATE_MTBF_DATA Parameters :
    --      p_x_mtbf_data_rec               IN OUT  RA_DEFINITION_DTLS_REC_TYPE  Required
    --
    --  Version :
    --      Initial Version   1.0
    --
    --  End of Comments  --
    PROCEDURE CREATE_MTBF_DATA (
        p_api_version               IN               NUMBER,
        p_init_msg_list             IN               VARCHAR2  := FND_API.G_FALSE,
        p_commit                    IN               VARCHAR2  := FND_API.G_FALSE,
        p_validation_level          IN               NUMBER    := FND_API.G_VALID_LEVEL_FULL,
        p_module_type               IN               VARCHAR2,
        x_return_status             OUT      NOCOPY  VARCHAR2,
        x_msg_count                 OUT      NOCOPY  NUMBER,
        x_msg_data                  OUT      NOCOPY  VARCHAR2,
        p_x_reliability_data_rec    IN  OUT  NOCOPY  AHL_RA_SETUPS_PVT.RA_DEFINITION_HDR_REC_TYPE,
        p_x_mtbf_data_rec           IN  OUT  NOCOPY  AHL_RA_SETUPS_PVT.RA_DEFINITION_DTLS_REC_TYPE);



    --  Start of Comments  --
    --
    --  Procedure name      : UPDATE_MTBF_DATA
    --  Type                : Private
    --  Function            : This API would update the setup data for Reliability Framework in AHL_RA_DEFINITION_DTLS
    --  Pre-reqs            :
    --
    --  Standard IN  Parameters :
    --      p_api_version                   IN      NUMBER                Required
    --      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
    --      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
    --      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
    --
    --  Standard OUT Parameters :
    --      x_return_status                 OUT     VARCHAR2              Required
    --      x_msg_count                     OUT     NUMBER                Required
    --      x_msg_data                      OUT     VARCHAR2              Required
    --
    --  UPDATE_MTBF_DATA Parameters :
    --      p_x_mtbf_data_rec                 IN OUT  RA_DEFINITION_DTLS_REC_TYPE  Required
    --
    --  Version :
    --      Initial Version   1.0
    --
    --  End of Comments  --
    PROCEDURE UPDATE_MTBF_DATA (
        p_api_version               IN               NUMBER,
        p_init_msg_list             IN               VARCHAR2  := FND_API.G_FALSE,
        p_commit                    IN               VARCHAR2  := FND_API.G_FALSE,
        p_validation_level          IN               NUMBER    := FND_API.G_VALID_LEVEL_FULL,
        p_module_type               IN               VARCHAR2,
        x_return_status             OUT      NOCOPY  VARCHAR2,
        x_msg_count                 OUT      NOCOPY  NUMBER,
        x_msg_data                  OUT      NOCOPY  VARCHAR2,
        p_x_reliability_data_rec    IN  OUT  NOCOPY  AHL_RA_SETUPS_PVT.RA_DEFINITION_HDR_REC_TYPE,
        p_x_mtbf_data_rec           IN  OUT  NOCOPY  AHL_RA_SETUPS_PVT.RA_DEFINITION_DTLS_REC_TYPE);



    --  Start of Comments  --
    --
    --  Procedure name      : DELETE_MTBF_DATA
    --  Type                : Private
    --  Function            : This API would delete the setup data for Reliability Framework in AHL_RA_DEFINITION_DTLS
    --  Pre-reqs            :
    --
    --  Standard IN  Parameters :
    --      p_api_version                   IN      NUMBER                Required
    --      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
    --      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
    --      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
    --
    --  Standard OUT Parameters :
    --      x_return_status                 OUT     VARCHAR2              Required
    --      x_msg_count                     OUT     NUMBER                Required
    --      x_msg_data                      OUT     VARCHAR2              Required
    --
    --  DELETE_MTBF_DATA Parameters :
    --      p_mtbf_data_rec                IN OUT  RA_DEFINITION_DTLS_REC_TYPE  Required
    --
    --  Version :
    --      Initial Version   1.0
    --
    --  End of Comments  --
    PROCEDURE DELETE_MTBF_DATA (
        p_api_version               IN               NUMBER,
        p_init_msg_list             IN               VARCHAR2  := FND_API.G_FALSE,
        p_commit                    IN               VARCHAR2  := FND_API.G_FALSE,
        p_validation_level          IN               NUMBER    := FND_API.G_VALID_LEVEL_FULL,
        p_module_type               IN               VARCHAR2,
        x_return_status             OUT      NOCOPY  VARCHAR2,
        x_msg_count                 OUT      NOCOPY  NUMBER,
        x_msg_data                  OUT      NOCOPY  VARCHAR2,
        p_x_reliability_data_rec    IN  OUT  NOCOPY  AHL_RA_SETUPS_PVT.RA_DEFINITION_HDR_REC_TYPE,
        p_mtbf_data_rec             IN               AHL_RA_SETUPS_PVT.RA_DEFINITION_DTLS_REC_TYPE);

    --  Start of Comments  --
    --
    --  Procedure name      : CREATE_COUNTER_ASSOC
    --  Type                : Private
    --  Function            : This API would create the setup data for Reliability Framework in AHL_RA_CTR_ASSOCIATIONS
    --  Pre-reqs            :
    --
    --  Standard IN  Parameters :
    --      p_api_version                   IN      NUMBER                Required
    --      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
    --      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
    --      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
    --
    --  Standard OUT Parameters :
    --      x_return_status                 OUT     VARCHAR2              Required
    --      x_msg_count                     OUT     NUMBER                Required
    --      x_msg_data                      OUT     VARCHAR2              Required
    --
    --  CREATE_COUNTER_ASSOC Parameters :
    --      p_x_counter_assoc_rec               IN OUT  RA_COUNTER_ASSOC_REC_TYPE  Required
    --
    --  Version :
    --      Initial Version   1.0
    --
    --  End of Comments  --
    PROCEDURE CREATE_COUNTER_ASSOC (
        p_api_version               IN               NUMBER,
        p_init_msg_list             IN               VARCHAR2  := FND_API.G_FALSE,
        p_commit                    IN               VARCHAR2  := FND_API.G_FALSE,
        p_validation_level          IN               NUMBER    := FND_API.G_VALID_LEVEL_FULL,
        p_module_type               IN               VARCHAR2,
        x_return_status             OUT      NOCOPY  VARCHAR2,
        x_msg_count                 OUT      NOCOPY  NUMBER,
        x_msg_data                  OUT      NOCOPY  VARCHAR2,
        p_x_counter_assoc_rec       IN  OUT  NOCOPY  AHL_RA_SETUPS_PVT.RA_COUNTER_ASSOC_REC_TYPE);



    --  Start of Comments  --
    --
    --  Procedure name      : DELETE_COUNTER_ASSOC
    --  Type                : Private
    --  Function            : This API would delete the setup data for Reliability Framework in AHL_RA_CTR_ASSOCIATIONS
    --  Pre-reqs            :
    --
    --  Standard IN  Parameters :
    --      p_api_version                   IN      NUMBER                Required
    --      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
    --      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
    --      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
    --
    --  Standard OUT Parameters :
    --      x_return_status                 OUT     VARCHAR2              Required
    --      x_msg_count                     OUT     NUMBER                Required
    --      x_msg_data                      OUT     VARCHAR2              Required
    --
    --  DELETE_COUNTER_ASSOC Parameters :
    --      p_counter_assoc_rec                IN OUT  RA_COUNTER_ASSOC_REC_TYPE  Required
    --
    --  Version :
    --      Initial Version   1.0
    --
    --  End of Comments  --
    PROCEDURE DELETE_COUNTER_ASSOC (
        p_api_version               IN               NUMBER,
        p_init_msg_list             IN               VARCHAR2  := FND_API.G_FALSE,
        p_commit                    IN               VARCHAR2  := FND_API.G_FALSE,
        p_validation_level          IN               NUMBER    := FND_API.G_VALID_LEVEL_FULL,
        p_module_type               IN               VARCHAR2,
        x_return_status             OUT      NOCOPY  VARCHAR2,
        x_msg_count                 OUT      NOCOPY  NUMBER,
        x_msg_data                  OUT      NOCOPY  VARCHAR2,
        p_counter_assoc_rec         IN               AHL_RA_SETUPS_PVT.RA_COUNTER_ASSOC_REC_TYPE);



    --  Start of Comments  --
    --
    --  Procedure name      : CREATE_FCT_ASSOC_DATA
    --  Type                : Private
    --  Function            : This API would create the setup data for Reliability Framework in AHL_RA_FCT_ASSOCIATIONS
    --  Pre-reqs            :
    --
    --  Standard IN  Parameters :
    --      p_api_version                   IN      NUMBER                Required
    --      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
    --      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
    --      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
    --
    --  Standard OUT Parameters :
    --      x_return_status                 OUT     VARCHAR2              Required
    --      x_msg_count                     OUT     NUMBER                Required
    --      x_msg_data                      OUT     VARCHAR2              Required
    --
    --  CREATE_FCT_ASSOC_DATA Parameters :
    --      p_x_fct_assoc_rec               IN OUT  RA_FCT_ASSOC_REC_TYPE  Required
    --
    --  Version :
    --      Initial Version   1.0
    --
    --  End of Comments  --
    PROCEDURE CREATE_FCT_ASSOC_DATA (
        p_api_version               IN               NUMBER,
        p_init_msg_list             IN               VARCHAR2  := FND_API.G_FALSE,
        p_commit                    IN               VARCHAR2  := FND_API.G_FALSE,
        p_validation_level          IN               NUMBER    := FND_API.G_VALID_LEVEL_FULL,
        p_module_type               IN               VARCHAR2,
        x_return_status             OUT      NOCOPY  VARCHAR2,
        x_msg_count                 OUT      NOCOPY  NUMBER,
        x_msg_data                  OUT      NOCOPY  VARCHAR2,
        p_x_fct_assoc_rec           IN  OUT  NOCOPY  AHL_RA_SETUPS_PVT.RA_FCT_ASSOC_REC_TYPE);



    --  Start of Comments  --
    --
    --  Procedure name      : UPDATE_FCT_ASSOC_DATA
    --  Type                : Private
    --  Function            : This API would update the setup data for Reliability Framework in AHL_RA_FCT_ASSOCIATIONS
    --  Pre-reqs            :
    --
    --  Standard IN  Parameters :
    --      p_api_version                   IN      NUMBER                Required
    --      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
    --      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
    --      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
    --
    --  Standard OUT Parameters :
    --      x_return_status                 OUT     VARCHAR2              Required
    --      x_msg_count                     OUT     NUMBER                Required
    --      x_msg_data                      OUT     VARCHAR2              Required
    --
    --  UPDATE_FCT_ASSOC_DATA Parameters :
    --      p_x_fct_assoc_rec                 IN OUT  RA_FCT_ASSOC_REC_TYPE  Required
    --
    --  Version :
    --      Initial Version   1.0
    --
    --  End of Comments  --
    PROCEDURE UPDATE_FCT_ASSOC_DATA (
        p_api_version               IN               NUMBER,
        p_init_msg_list             IN               VARCHAR2  := FND_API.G_FALSE,
        p_commit                    IN               VARCHAR2  := FND_API.G_FALSE,
        p_validation_level          IN               NUMBER    := FND_API.G_VALID_LEVEL_FULL,
        p_module_type               IN               VARCHAR2,
        x_return_status             OUT      NOCOPY  VARCHAR2,
        x_msg_count                 OUT      NOCOPY  NUMBER,
        x_msg_data                  OUT      NOCOPY  VARCHAR2,
        p_x_fct_assoc_rec             IN  OUT  NOCOPY  AHL_RA_SETUPS_PVT.RA_FCT_ASSOC_REC_TYPE);



    --  Start of Comments  --
    --
    --  Procedure name      : DELETE_FCT_ASSOC_DATA
    --  Type                : Private
    --  Function            : This API would delete the setup data for Reliability Framework in AHL_RA_FCT_ASSOCIATIONS
    --  Pre-reqs            :
    --
    --  Standard IN  Parameters :
    --      p_api_version                   IN      NUMBER                Required
    --      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
    --      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
    --      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
    --
    --  Standard OUT Parameters :
    --      x_return_status                 OUT     VARCHAR2              Required
    --      x_msg_count                     OUT     NUMBER                Required
    --      x_msg_data                      OUT     VARCHAR2              Required
    --
    --  DELETE_FCT_ASSOC_DATA Parameters :
    --      p_fct_assoc_rec                IN OUT  RA_FCT_ASSOC_REC_TYPE  Required
    --
    --  Version :
    --      Initial Version   1.0
    --
    --  End of Comments  --
    PROCEDURE DELETE_FCT_ASSOC_DATA (
        p_api_version               IN               NUMBER,
        p_init_msg_list             IN               VARCHAR2  := FND_API.G_FALSE,
        p_commit                    IN               VARCHAR2  := FND_API.G_FALSE,
        p_validation_level          IN               NUMBER    := FND_API.G_VALID_LEVEL_FULL,
        p_module_type               IN               VARCHAR2,
        x_return_status             OUT      NOCOPY  VARCHAR2,
        x_msg_count                 OUT      NOCOPY  NUMBER,
        x_msg_data                  OUT      NOCOPY  VARCHAR2,
        p_fct_assoc_rec             IN               AHL_RA_SETUPS_PVT.RA_FCT_ASSOC_REC_TYPE);

END AHL_RA_SETUPS_PVT;

 

/
