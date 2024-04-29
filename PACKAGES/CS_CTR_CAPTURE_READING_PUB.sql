--------------------------------------------------------
--  DDL for Package CS_CTR_CAPTURE_READING_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_CTR_CAPTURE_READING_PUB" AUTHID CURRENT_USER as
-- $Header: csxpcrds.pls 120.0.12010000.1 2008/07/24 18:45:15 appldev ship $
-- Start of Comments
-- Package name     : CS_CTR_CAPTURE_READING_PUB
-- Purpose          : Capture Reading for Counters
-- History          :
-- NOTE             :
-- End of Comments

-- Default number of records fetch per call
--G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;

/**
  * Counter Group Log Record type
  **/
TYPE CTR_GRP_LOG_Rec_Type IS RECORD
(
       COUNTER_GRP_LOG_ID        NUMBER := FND_API.G_MISS_NUM,
       COUNTER_GROUP_ID          NUMBER := FND_API.G_MISS_NUM,
       VALUE_TIMESTAMP           DATE := FND_API.G_MISS_DATE,
       SOURCE_TRANSACTION_ID     NUMBER := FND_API.G_MISS_NUM,
       SOURCE_TRANSACTION_CODE   VARCHAR2(30) := FND_API.G_MISS_CHAR,
       ATTRIBUTE1                VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE2                VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE3                VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE4                VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE5                VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE6                VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE7                VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE8                VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE9                VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE10               VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE11               VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE12               VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE13               VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE14               VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE15               VARCHAR2(150) := FND_API.G_MISS_CHAR,
       CONTEXT                   VARCHAR2(30) := FND_API.G_MISS_CHAR
);

G_MISS_CTR_GRP_LOG_REC          CTR_GRP_LOG_Rec_Type;
--TYPE CTR_GRP_LOG_Tbl_Type       IS TABLE OF CTR_GRP_LOG_Rec_Type
--                                INDEX BY BINARY_INTEGER;
--G_MISS_CTR_GRP_LOG_TBL          CTR_GRP_LOG_Tbl_Type;

/**
  * Counter Reading Record type
  **/
TYPE CTR_RDG_Rec_Type IS RECORD
(
       COUNTER_VALUE_ID          NUMBER := FND_API.G_MISS_NUM,
       COUNTER_ID                NUMBER := FND_API.G_MISS_NUM,
       VALUE_TIMESTAMP           DATE := FND_API.G_MISS_DATE,
       COUNTER_READING           NUMBER := FND_API.G_MISS_NUM,
       RESET_FLAG                VARCHAR2(1) := FND_API.G_FALSE,
       RESET_REASON              VARCHAR2(255) := FND_API.G_MISS_CHAR,
       PRE_RESET_LAST_RDG        NUMBER := FND_API.G_MISS_NUM,
       POST_RESET_FIRST_RDG      NUMBER := FND_API.G_MISS_NUM,
       MISC_READING_TYPE         VARCHAR2(20) := FND_API.G_MISS_CHAR,
       MISC_READING              NUMBER := FND_API.G_MISS_NUM,
       OBJECT_VERSION_NUMBER     NUMBER  := FND_API.G_MISS_NUM,  --Required from Update Reading only
       ATTRIBUTE1                VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE2                VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE3                VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE4                VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE5                VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE6                VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE7                VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE8                VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE9                VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE10               VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE11               VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE12               VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE13               VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE14               VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE15               VARCHAR2(150) := FND_API.G_MISS_CHAR,
       CONTEXT                   VARCHAR2(30) := FND_API.G_MISS_CHAR,
       VALID_FLAG		 VARCHAR2(1)  := FND_API.G_MISS_CHAR,
       OVERRIDE_VALID_FLAG	 VARCHAR2(1)   := FND_API.G_MISS_CHAR,
       COMMENTS                  VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       FILTER_READING_COUNT      NUMBER        := FND_API.G_MISS_NUM
);
G_MISS_CTR_RDG_REC          CTR_RDG_Rec_Type;
TYPE CTR_RDG_Tbl_Type       IS TABLE OF CTR_RDG_Rec_Type
                              INDEX BY BINARY_INTEGER;
G_MISS_CTR_RDG_TBL          CTR_RDG_Tbl_Type;

/**
  * Counter Property Reading Record type
  **/
TYPE PROP_RDG_Rec_Type IS RECORD
(
       COUNTER_PROP_VALUE_ID     NUMBER := FND_API.G_MISS_NUM,
       COUNTER_PROPERTY_ID       NUMBER := FND_API.G_MISS_NUM,
       VALUE_TIMESTAMP           DATE := FND_API.G_MISS_DATE,
       PROPERTY_VALUE            VARCHAR2(240) := FND_API.G_MISS_CHAR,
       OBJECT_VERSION_NUMBER     NUMBER  := FND_API.G_MISS_NUM,  --Required from Update Reading only
       ATTRIBUTE1                VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE2                VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE3                VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE4                VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE5                VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE6                VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE7                VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE8                VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE9                VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE10               VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE11               VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE12               VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE13               VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE14               VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE15               VARCHAR2(150) := FND_API.G_MISS_CHAR,
       CONTEXT                   VARCHAR2(30) := FND_API.G_MISS_CHAR
);

G_MISS_PROP_RDG_REC          PROP_RDG_Rec_Type;
TYPE PROP_RDG_Tbl_Type      IS TABLE OF PROP_RDG_Rec_Type
                             INDEX BY BINARY_INTEGER;
G_MISS_PROP_RDG_TBL          PROP_RDG_Tbl_Type;

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  CAPTURE_COUNTER_READING
--   Type    :  Private
--   Pre-Req :  None
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       P_CTR_RDG_Rec             IN CTR_RDG_Rec_Type  Required
--       p_COUNTER_GRP_LOG_ID      IN   NUMBER Required
--       p_internal_level          IN   NUMBER Not to be passed, Internal Use.
--   OUT:
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Description :
--      This API is used to capture reading of a REGULAR counter.  Prerequisite of this API is PRE_CAPTURE_COUNTER_READING.
--      You must have counter group log ID to call this API.  Capture counter reading can only be called once for each
--      counter in the counter group of counter group log id.
--   End of Comments
--
PROCEDURE CAPTURE_COUNTER_READING(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    p_CTR_GRP_LOG_Rec            IN   CTR_GRP_LOG_Rec_Type  := G_MISS_CTR_GRP_LOG_Rec,
    p_CTR_RDG_Tbl                IN   CTR_RDG_Tbl_Type  := G_MISS_CTR_RDG_TBL,
    p_PROP_RDG_Tbl               IN   PROP_RDG_Tbl_Type  := G_MISS_PROP_RDG_TBL,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  UPDATE_COUNTER_READING
--   Type    :  Private
--   Pre-Req :  None
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       P_CTR_RDG_Rec             IN CTR_RDG_Rec_Type  Required
--       p_COUNTER_GRP_LOG_ID      IN   NUMBER Required
--       p_object_version_number   IN   NUMBER Required
--       p_internal_level          IN   NUMBER Not to be passed, Internal Use.
--   OUT:
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Description :
--      This API is used to update existing reading of a REGULAR counter. You must have counter group log ID and
--      object_version_number to call this API, currect counter reading view should be used to find out the
--      counter group log id of the counter id. Only most recent reading is allowed to be updated. If counter group
--      log id passed is not the most recent counter group log id of counter id then an exception is raised.
--   End of Comments
--
PROCEDURE UPDATE_COUNTER_READING(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    p_CTR_GRP_LOG_ID             IN   NUMBER,
    p_CTR_RDG_Tbl                IN   CTR_RDG_Tbl_Type  := G_MISS_CTR_RDG_TBL,
    p_PROP_RDG_Tbl               IN   PROP_RDG_Tbl_Type  := G_MISS_PROP_RDG_TBL,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2
  );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name: CAPTURE_COUNTER_READING
--   Type    : Private
--   Pre-Req :  None
--   Parameters:
--   IN
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_CTR_RDG_Rec             IN   CTR_RDG_Rec_Type Required
--       p_COUNTER_GRP_LOG_ID      IN   NUMBER     Required
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Description :
--      This API is used to capture reading of a REGULAR counter.  Prerequisite of this API is PRE_CAPTURE_COUNTER_READING.
--      You must have counter group log ID to call this API.  Capture counter reading can only be called once for each
--      counter in the counter group of counter group log id.
--   End of Comments
--
PROCEDURE CAPTURE_COUNTER_READING(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    p_CTR_RDG_Rec                IN   CTR_RDG_Rec_Type := G_MISS_CTR_RDG_REC,
    p_COUNTER_GRP_LOG_ID         IN   NUMBER,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2
   );
--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name: UPDATE_COUNTER_READING
--   Type    : Private
--   Pre-Req :  None
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_CTR_RDG_Rec             IN   CTR_RDG_Rec_Type  Required
--       p_COUNTER_GRP_LOG_ID      IN   NUMBER     Required
--       p_object_version_number   IN   NUMBER
--   OUT:
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Description :
--      This API is used to update existing reading of a REGULAR counter. You must have counter group log ID and
--      object_version_number to call this API, currect counter reading view should be used to find out the
--      counter group log id of the counter id. Only most recent reading is allowed to be updated. If counter group
--      log id passed is not the most recent counter group log id of counter id then an exception is raised.
--   End of Comments
--
PROCEDURE UPDATE_COUNTER_READING(
    p_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    p_CTR_RDG_Rec                IN   CTR_RDG_Rec_Type  := G_MISS_CTR_RDG_REC,
    p_COUNTER_GRP_LOG_ID         IN   NUMBER,
    p_object_version_number      IN   NUMBER,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2
   );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name: PRE_CAPTURE_CTR_READING
--   Type    : Private
--   Pre-Req :  None
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       P_CTR_GRP_LOG_Rec         IN CTR_GRP_LOG_Rec_Type  Required
--   OUT:
--       x_CTR_GRP_LOG_ID          OUT  NUMBER
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Description :
--       This API is the first step to start capturing counter reading. This API must and only be called once
--       for NEW counter reading before calling any other capture reading API. This API will return a reference
--       (Counter Group Log ID) to counter reading group which will be used to call other capture reading APIs.
--
--   End of Comments
--
PROCEDURE PRE_CAPTURE_CTR_READING(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_CTR_GRP_LOG_Rec            IN   CTR_GRP_LOG_Rec_Type  := G_MISS_CTR_GRP_LOG_REC,
    X_COUNTER_GRP_LOG_ID         IN OUT  NOCOPY NUMBER,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2
    );
--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  CAPTURE_CTR_PROP_READING
--   Type    :  Private
--   Pre-Req :  None
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       P_PROP_RDG_Rec            IN   PROP_RDG_Rec_Type  Required
--       p_COUNTER_GRP_LOG_ID      IN   NUMBER Required
--   OUT:
--       x_return_status           OUT  NOCOPY VARCHAR2
--       x_msg_count               OUT  NOCOPY NUMBER
--       x_msg_data                OUT  NOCOPY VARCHAR2
--   Version : Current version 1.0
--   Description :
--      This API is used to capture reading for properties of REGULAR counters.  Prerequisite of this API is
--      PRE_CAPTURE_COUNTER_READING and reading of the counter must be captured before calling this API.
--      You must have counter group log ID to call this API.  Capture counter property reading can only be
--      called once for each counter property in the counter.
--
--   End of Comments
--
PROCEDURE CAPTURE_CTR_PROP_READING(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    p_PROP_RDG_Rec               IN   PROP_RDG_Rec_Type  := G_MISS_PROP_RDG_REC,
    p_COUNTER_GRP_LOG_ID         IN   NUMBER,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2
    );
--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  POST_CAPTURE_CTR_READING
--   Type    :  Private
--   Pre-Req :  None
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_READING_UPDATED         IN   NUMBER Optional      Default = FND_API.G_FLASE

--       p_COUNTER_GRP_LOG_ID      IN   NUMBER Required
--   OUT:
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Description : --      This API is used to do processing required after the all reading for one group have been captured.
--      This API calculates all formula/group operation counters effected from captured reading counters under
--      the passed counter group log id.  After computing non regular counters this API calls event APIs.
--   End of Comments
--
PROCEDURE POST_CAPTURE_CTR_READING(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    p_COUNTER_GRP_LOG_ID         IN   NUMBER,
    P_READING_UPDATED            IN   VARCHAR2     := FND_API.G_FALSE,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2
    );
--    Start of Comments
--   *******************************************************
--   API Name:  UPDATE_CTR_PROP_READING
--   Type    :  Private
--   Pre-Req :  None
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       P_PROP_RDG_Rec            IN PROP_RDG_Rec_Type  Required
--       p_COUNTER_GRP_LOG_ID      IN   NUMBER Required
--       p_object_version_number   IN   NUMBER Required
--   OUT:
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Description :
--      This API is used to update existing value of a properties of REGULAR counter. You must have counter group log
--      ID and object_version_number to call this API, current counter property reading view should be used to find out the
--      counter group log id of the counter property. Only most recent values are allowed to be updated. If counter group
--      log id passed is not the most recent counter group log id of counter id then an exception is raised.
--
--   End of Comments
--
PROCEDURE UPDATE_CTR_PROP_READING(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    p_PROP_RDG_Rec               IN   PROP_RDG_Rec_Type  := G_MISS_PROP_RDG_REC,
    p_COUNTER_GRP_LOG_ID         IN   NUMBER,
    p_object_version_number      IN   NUMBER,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2
    );
/*
PROCEDURE ESTIMATE_COUNTER_READING(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    p_counter_id                 IN   NUMBER,
    p_estimation_period_start_date IN DATE,
    p_estimation_period_end_date IN   DATE,
    p_avg_calculation_start_date  IN    DATE,
    p_number_of_readings         IN   NUMBER,
    x_estimated_usage_qty        OUT  NOCOPY NUMBER,
    x_estimated_meter_reading    OUT  NOCOPY NUMBER,
    x_estimated_period_start_rdg OUT  NOCOPY NUMBER,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2
    );
*/

End CS_CTR_CAPTURE_READING_PUB;

/
