--------------------------------------------------------
--  DDL for Package CN_SRP_ROLLOVER_QUOTA_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_SRP_ROLLOVER_QUOTA_PVT" AUTHID CURRENT_USER AS
  /*$Header: cnvsrs.pls 115.2 2002/12/04 02:37:01 fting noship $*/

-- DEFINE PACKAGE_NAME="CN_SRP_ROLLOVER_QUOTA_PVT";
-- plan element
TYPE srp_rollover_quota_rec_type IS RECORD
  (
    SRP_ROLLOVER_QUOTA_ID  NUMBER := FND_API.G_MISS_NUM,
    SRP_QUOTA_ASSIGN_ID  NUMBER := FND_API.G_MISS_NUM,
    ROLLOVER_QUOTA_ID  NUMBER := FND_API.G_MISS_NUM,
    QUOTA_ID            NUMBER := FND_API.G_MISS_NUM,
    SOURCE_QUOTA_ID      NUMBER := FND_API.G_MISS_NUM,
    ROLLOVER             cn_srp_rollover_quotas.rollover%TYPE := FND_API.G_MISS_NUM,
    ATTRIBUTE_CATEGORY        cn_srp_rollover_quotas.attribute_category%TYPE      := cn_api.g_miss_char,
    ATTRIBUTE1  cn_srp_rollover_quotas.attribute1%TYPE := cn_api.g_miss_char,
    ATTRIBUTE2  cn_srp_rollover_quotas.attribute2%TYPE := cn_api.g_miss_char,
    ATTRIBUTE3  cn_srp_rollover_quotas.attribute3%TYPE := cn_api.g_miss_char,
    ATTRIBUTE4  cn_srp_rollover_quotas.attribute4%TYPE := cn_api.g_miss_char,
    ATTRIBUTE5  cn_srp_rollover_quotas.attribute5%TYPE := cn_api.g_miss_char,
    ATTRIBUTE6  cn_srp_rollover_quotas.attribute6%TYPE := cn_api.g_miss_char,
    ATTRIBUTE7  cn_srp_rollover_quotas.attribute7%TYPE := cn_api.g_miss_char,
    ATTRIBUTE8  cn_srp_rollover_quotas.attribute8%TYPE := cn_api.g_miss_char,
    ATTRIBUTE9  cn_srp_rollover_quotas.attribute9%TYPE := cn_api.g_miss_char,
    ATTRIBUTE10  cn_srp_rollover_quotas.attribute10%TYPE := cn_api.g_miss_char,
    ATTRIBUTE11  cn_srp_rollover_quotas.attribute11%TYPE := cn_api.g_miss_char,
    ATTRIBUTE12  cn_srp_rollover_quotas.attribute12%TYPE := cn_api.g_miss_char,
    ATTRIBUTE13  cn_srp_rollover_quotas.attribute13%TYPE := cn_api.g_miss_char,
    ATTRIBUTE14  cn_srp_rollover_quotas.attribute14%TYPE := cn_api.g_miss_char,
    ATTRIBUTE15  cn_srp_rollover_quotas.attribute15%TYPE := cn_api.g_miss_char,

    OBJECT_VERSION_NUMBER   CN_SRP_ROLLOVER_QUOTAS.OBJECT_VERSION_NUMBER%TYPE := NULL
    ) ;

TYPE srp_rollover_quota_tbl_type IS
   TABLE OF srp_rollover_quota_rec_type INDEX BY BINARY_INTEGER ;

-- Global variable that represent missing values.

G_MISS_SRP_ROLL_QUOTA_REC  srp_rollover_quota_rec_type;
G_MISS_SRP_ROLL_QUOTA_REC_TB  srp_rollover_quota_tbl_type;


-- Start of comments
--      API name        : Update_SRP_ROLLOVER_QUOTA
--      Type            : Private.
--      Function        :
--      Pre-reqs        : None.
--      Parameters      :
-- End of comments

PROCEDURE Update_Srp_Rollover_Quota
  (p_api_version                 IN      NUMBER,
   p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level            IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,
   p_srp_rollover_quota              IN      srp_rollover_quota_rec_type,
   x_return_status               OUT NOCOPY    VARCHAR2,
   x_msg_count                   OUT NOCOPY    NUMBER,
   x_msg_data                    OUT NOCOPY    VARCHAR2 );




END CN_SRP_ROLLOVER_QUOTA_PVT;


 

/
