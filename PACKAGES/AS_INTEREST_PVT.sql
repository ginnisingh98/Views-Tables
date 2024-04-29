--------------------------------------------------------
--  DDL for Package AS_INTEREST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_INTEREST_PVT" AUTHID CURRENT_USER as
/* $Header: asxvints.pls 115.17 2003/11/13 10:11:14 gbatra ship $ */

--
-- NAME
--   AS_INTEREST_PVT
--
-- PURPOSE
--   This is a private API used to create interests (Company Classifications,
--  Contact Interests, or Lead Classifications).
--
-- NOTES
--   Create_Interest is a private OSM routine, that should not be called by modules
--   outside of OSM
--
--   Although multiple interest records can be passed to the create_interest API,
--   all of the interest records in an interest table must be of the same interest type
--   (i.e. all company classifications).
--
--
-- HISTORY
--   11/12/96   JKORNBER                Created
--   08/28/98   AWU         Add update_interest
--                  Add interest_id, customer_id, address_id,
--                  contact_id and lead_id into
--                  interest record
--                  Changed interest rec default value NULL to
--                  FND_API.G_MISS for update purpose
--   11/03/03   GBATRA                Product Hierarchy Uptake
--


-- Start of Comments
--
--  Interest Record (Account Classification, Contact Interest, Lead Classification): interest_rec_type
--
--  Parameters:
--      Product Category Id         Valid category_id from eni_prod_den_hrchy_parents_v denonted as
--                                  correct classification product category
--      Product Category Set Id     Valid category_set_id from from eni_prod_den_hrchy_parents_v
--      Status Code                 Valid status code from as_interest_statuses
--      Description                 Free format text
--
--  Required
--      Product Category Id and Product Category Set Id
--
--
-- End of Comments

TYPE interest_rec_type      IS RECORD
    (   interest_id         NUMBER      := FND_API.G_MISS_NUM,
        customer_id         NUMBER      := FND_API.G_MISS_NUM,
        address_id          NUMBER      := FND_API.G_MISS_NUM,
        contact_id          NUMBER      := FND_API.G_MISS_NUM,
        lead_id             NUMBER      := FND_API.G_MISS_NUM,
        interest_type_id        NUMBER      := FND_API.G_MISS_NUM,
        last_update_date            DATE            := FND_API.G_MISS_DATE,
        last_updated_by            NUMBER            := FND_API.G_MISS_NUM,
        creation_date                DATE            := FND_API.G_MISS_DATE,
        created_by                    NUMBER            := FND_API.G_MISS_NUM,
        last_update_login           NUMBER            := FND_API.G_MISS_NUM,
        primary_interest_code_id    NUMBER      := FND_API.G_MISS_NUM,
        secondary_interest_code_id  NUMBER      := FND_API.G_MISS_NUM,
        status_code         VARCHAR2(30)    := FND_API.G_MISS_CHAR,
        status              VARCHAR2(80)    := FND_API.G_MISS_CHAR,
        description         VARCHAR2(240)   := FND_API.G_MISS_CHAR,
        ATTRIBUTE_CATEGORY      VARCHAR2(30)    := FND_API.G_MISS_CHAR,
        ATTRIBUTE1          VARCHAR2(150)   := FND_API.G_MISS_CHAR,
        ATTRIBUTE2          VARCHAR2(150)   := FND_API.G_MISS_CHAR,
        ATTRIBUTE3          VARCHAR2(150)   := FND_API.G_MISS_CHAR,
        ATTRIBUTE4          VARCHAR2(150)   := FND_API.G_MISS_CHAR,
        ATTRIBUTE5          VARCHAR2(150)   := FND_API.G_MISS_CHAR,
        ATTRIBUTE6          VARCHAR2(150)   := FND_API.G_MISS_CHAR,
        ATTRIBUTE7          VARCHAR2(150)   := FND_API.G_MISS_CHAR,
        ATTRIBUTE8          VARCHAR2(150)   := FND_API.G_MISS_CHAR,
        ATTRIBUTE9          VARCHAR2(150)   := FND_API.G_MISS_CHAR,
        ATTRIBUTE10         VARCHAR2(150)   := FND_API.G_MISS_CHAR,
        ATTRIBUTE11         VARCHAR2(150)   := FND_API.G_MISS_CHAR,
        ATTRIBUTE12         VARCHAR2(150)   := FND_API.G_MISS_CHAR,
        ATTRIBUTE13         VARCHAR2(150)   := FND_API.G_MISS_CHAR,
        ATTRIBUTE14         VARCHAR2(150)   := FND_API.G_MISS_CHAR,
        ATTRIBUTE15         VARCHAR2(150)   := FND_API.G_MISS_CHAR,
        product_category_id             NUMBER      := FND_API.G_MISS_NUM,
        product_cat_set_id              NUMBER      := FND_API.G_MISS_NUM
    );

G_MISS_INTEREST_REC     interest_rec_type;

-- Start of Comments
--
--  Interest Table: interest_tbl_type
--
-- End of Comments

TYPE interest_tbl_type      IS TABLE OF interest_rec_type
                INDEX BY BINARY_INTEGER;

G_MISS_INTEREST_TBL     interest_tbl_type;



-- Start of Comments
--
--  Interest Out Record: interest_out_rec_type
--
--
-- End of Comments

TYPE interest_out_rec_type  IS RECORD
    (   interest_id         NUMBER,
        return_status           VARCHAR2(1)
    );


-- Start of Comments
--
--  Interest Out Table: interest_out_tbl_type
--
--
-- End of Comments

TYPE interest_out_tbl_type  IS TABLE OF interest_out_rec_type
                INDEX BY BINARY_INTEGER;


-- Start of Comments
--
--  API name    : Create Interest
--  Type        : Private
--  Function    : Create Account, Contact, or Lead Classification Interest
--  Pre-reqs    : Account, contact, or lead exists
--  Parameters
--  IN      :
--          p_api_version_number    IN  NUMBER      Required
--          p_init_msg_list     IN  VARCHAR2    Optional
--              Default = FND_API.G_FALSE
--          p_commit            IN  VARCHAR2    Optional
--              Default = FND_API.G_FALSE
--          p_validation_level  IN  NUMBER      Optional
--              Default = FND_API.G_VALID_LEVEL_FULL
--          p_interest_tbl      IN INTEREST_TBL_TYPE    Optional
--          p_customer_id       IN  NUMBER      Required
--          p_address_id        IN  NUMBER      Required
--          p_contact_id        IN  NUMBER      Optional
--          p_lead_id       IN  NUMBER      Optional
--          p_interest_use_code IN  VARCHAR2    Required
--              (LEAD_CLASSIFICATION, COMPANY_CLASSIFICATION,
--               CONTACT_INTEREST)
--
--  OUT     :
--          p_return_status     OUT VARCHAR2(1)
--          p_msg_count     OUT NUMBER
--          p_msg_data      OUT VARCHAR2(2000)
--          p_interest_out_tbl  OUT INTEREST_OUT_TBL_TYPE
--
--
--  Version :   Current version 1.0
--              Initial Version
--           Initial version    1.0
--
--  Notes:      OSM API to load interests.
--          Validation proceeds as follows:
--              For lead classification: lead_id, customer_id,
--                  address_id must exist
--              For contact interest: contact_id, customer_id,
--                  address_id must exists
--              For account interest: customer_id, address_id must exists
--          For each interest, the interest type must be denoted properly
--              (i.e. for inserting lead classifications, the interest
--              type must be denoted as a lead classification interest)
--
--
-- End of Comments

PROCEDURE Create_Interest
(   p_api_version_number    IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2    := FND_API.G_FALSE,
    p_commit            IN      VARCHAR2    := FND_API.G_FALSE,
    p_validation_level  IN  NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    p_interest_tbl      IN  INTEREST_TBL_TYPE := G_MISS_INTEREST_TBL,
    p_customer_id       IN  NUMBER,
    p_address_id        IN  NUMBER,
    p_contact_id        IN  NUMBER,
    p_lead_id       IN  NUMBER,
    p_interest_use_code IN  VARCHAR2,
    p_check_access_flag  IN VARCHAR2,
    p_admin_flag         IN VARCHAR2,
    p_admin_group_id     IN NUMBER,
    p_identity_salesforce_id IN NUMBER,
    p_access_profile_rec  IN  AS_ACCESS_PUB.ACCESS_PROFILE_REC_TYPE,
    p_return_status     OUT NOCOPY  VARCHAR2,
    p_msg_count     OUT NOCOPY  NUMBER,
    p_msg_data      OUT NOCOPY  VARCHAR2,
    p_interest_out_tbl  OUT NOCOPY  INTEREST_OUT_TBL_TYPE
);


-- Start of Comments
--
--  API name    : Update Interest
--  Type        : Private
--  Function    : Update Account, Contact, or Lead Classification Interest
--  Pre-reqs    : Account, contact, or lead exists
--  Parameters
--  IN      :
--          p_api_version_number    IN  NUMBER      Required
--          p_init_msg_list     IN  VARCHAR2    Optional
--              Default = FND_API.G_FALSE
--          p_commit            IN  VARCHAR2    Optional
--              Default = FND_API.G_FALSE
--          p_validation_level  IN  NUMBER      Optional
--              Default = FND_API.G_VALID_LEVEL_FULL
--          p_identity_salesforce_id  IN    NUMBER      Optional
--          p_interest_rec      IN INTEREST_REC_TYPE    Required
--          p_interest_use_code IN  VARCHAR2    Required
--              (LEAD_CLASSIFICATION, COMPANY_CLASSIFICATION,
--               CONTACT_INTEREST)
--
--  OUT     :
--          x_return_status     OUT VARCHAR2(1)
--          x_msg_count     OUT NUMBER
--          x_msg_data      OUT VARCHAR2(2000)
--          x_interest_id       OUT NUMBER
--
--
--  Version :   Current version 1.0
--              Initial Version
--           Initial version    1.0
--
--
PROCEDURE Update_Interest
(   p_api_version_number    IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2    := FND_API.G_FALSE,
    p_commit            IN      VARCHAR2    := FND_API.G_FALSE,
    p_validation_level  IN  NUMBER      :=FND_API.G_VALID_LEVEL_FULL,
        p_identity_salesforce_id  IN    NUMBER      := NULL,
    p_interest_rec      IN  INTEREST_REC_TYPE := G_MISS_INTEREST_REC,
    p_interest_use_code IN  VARCHAR2,
    p_check_access_flag  IN VARCHAR2,
    p_admin_flag         IN VARCHAR2,
    p_admin_group_id     IN NUMBER,
    p_access_profile_rec  IN  AS_ACCESS_PUB.ACCESS_PROFILE_REC_TYPE,
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count     OUT NOCOPY  NUMBER,
    x_msg_data      OUT NOCOPY  VARCHAR2,
    x_interest_id       OUT NOCOPY     NUMBER
);

PROCEDURE Delete_Interest
(   p_api_version_number    IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2    := FND_API.G_FALSE,
    p_commit            IN      VARCHAR2    := FND_API.G_FALSE,
    p_validation_level  IN  NUMBER      :=FND_API.G_VALID_LEVEL_FULL,
        p_identity_salesforce_id  IN    NUMBER,
    p_interest_rec      IN  INTEREST_REC_TYPE := G_MISS_INTEREST_REC,
    p_interest_use_code IN  VARCHAR2,
     p_check_access_flag   in  varchar2,
     p_admin_flag          in  varchar2,
     p_admin_group_id      in  number,
     p_access_profile_rec  IN  AS_ACCESS_PUB.ACCESS_PROFILE_REC_TYPE,
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count     OUT NOCOPY  NUMBER,
    x_msg_data      OUT NOCOPY  VARCHAR2
);


PROCEDURE Validate_party_id (
          p_init_msg_list       IN       VARCHAR2 := FND_API.G_FALSE,
          p_party_id            IN       NUMBER,
          x_return_status       OUT NOCOPY      VARCHAR2,
          x_msg_count           OUT NOCOPY      NUMBER,
          x_msg_data            OUT NOCOPY      VARCHAR2
);

-- NOTES
-- Procedure validates interest type ids and returns SUCCESS if all ids are
-- valid, ERROR otherwise
-- Procedure assumes that at least the interest type exists
--
--   Currently not accessible by sources outside of OSM
--
PROCEDURE Validate_Int_Type_Fields (
    p_interest_type_id      IN NUMBER,
    p_primary_interest_code_id  IN NUMBER,
    p_secondary_interest_code_id    IN NUMBER,
    p_return_status         OUT NOCOPY VARCHAR2
  );

-- Procedure validates interest status and returns SUCCESS if status is
-- valid, ERROR otherwise
-- Procedure assumes that at least the interest type exists
--
PROCEDURE Validate_Int_Status (  p_interest_type_id            IN  NUMBER,
                                 p_primary_interest_code_id    IN  NUMBER,
                                 p_secondary_interest_code_id  IN  NUMBER,
                                 p_interest_status_code        IN  VARCHAR2,
                                 p_return_status               OUT NOCOPY VARCHAR2
                              );

-- Procedure validates interest status for product catalog and returns SUCCESS if status is
-- valid, ERROR otherwise
-- Procedure assumes that at least the product category exists
--
PROCEDURE Validate_Int_Status_For_PC (  p_product_category_id         IN  NUMBER,
                                        p_product_cat_set_id          IN  NUMBER,
                                        p_interest_status_code        IN  VARCHAR2,
                                        p_return_status               OUT NOCOPY VARCHAR2
                                      );

END AS_INTEREST_PVT;

 

/
