--------------------------------------------------------
--  DDL for Package AS_INTEREST_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_INTEREST_PUB" AUTHID CURRENT_USER as
/* $Header: asxpints.pls 115.16 2003/11/06 13:58:28 gbatra ship $ */

--
-- NAME
--   AS_INTEREST_PUB
--
-- PURPOSE
--   Provide public interest record and table type to be used by APIs that
--   import interests/classifications into OSM
--
--   Convert the public interest records into private interest records for use by
--   the AS_INTEREST_PVT.Create_Interest routine
--
--   Procedures:
--   Convert_Values_To_Ids (
--                p_interest_tbl          IN INTEREST_TBL_TYPE,
--                p_pvt_interest_tbl      OUT NOCOPY AS_INTEREST_PVT.INTEREST_TBL_TYPE)
--
--   Convert_Interest_Values_To_Ids (
--                p_interest_type                         IN VARCHAR2,
--                p_interest_type_id                      IN NUMBER,
--                p_primary_interest_code                 IN VARCHAR2,
--                p_primary_interest_code_id              IN NUMBER,
--                p_secondary_interest_code               IN VARCHAR2,
--                p_secondary_interest_code_id            IN NUMBER,
--                p_return_status                         OUT NOCOPY VARCHAR2,
--                p_out_interest_type_id                  OUT NOCOPY NUMBER,
--                p_out_primary_interest_code_id          OUT NOCOPY NUMBER,
--                p_out_second_interest_code_id           OUT NOCOPY NUMBER)
--
--
-- NOTES
--   The procedures in this package are not supported for use by anyone outside
--   of OSM.  The procedures are called from the necessary API's to convert the
--   number into the table type excepted by the Private Interest API routine
--   (create_interest)
--
-- HISTORY
--   11/12/96 JKORNBER    Created
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
--  Interest Record  (Account Classification, Contact Interest, Lead Classification): interest_rec_type
--
--  Parameters:
--      Product Category Id         Valid category_id from eni_prod_den_hrchy_parents_v denonted as
--                                  correct classification product category
--      Product Category Set Id     Valid category_set_id from from eni_prod_den_hrchy_parents_v
--      Status Code                 Valid status code from as_interest_statuses
--      Status                      Valid status (from as_interest_statuses)
--      Description                 Free format text
--      Attibute Category           No validation
--      Attibute 1 -15              No validation
--
--  Required
--      Product Category Id and Product Category Set Id
--
--
-- End of Comments

TYPE interest_rec_type    IS RECORD
   (
        interest_id     NUMBER      := FND_API.G_MISS_NUM,
        customer_id     NUMBER      := FND_API.G_MISS_NUM,
        address_id          NUMBER      := FND_API.G_MISS_NUM,
        contact_id          NUMBER      := FND_API.G_MISS_NUM,
        lead_id         NUMBER      := FND_API.G_MISS_NUM,
        interest_type_id           NUMBER          := FND_API.G_MISS_NUM,
                last_update_date            DATE            := FND_API.G_MISS_DATE,
        last_updated_by            NUMBER            := FND_API.G_MISS_NUM,
        creation_date                DATE            := FND_API.G_MISS_DATE,
        created_by                    NUMBER            := FND_API.G_MISS_NUM,
        last_update_login            NUMBER            := FND_API.G_MISS_NUM,
        interest_type              VARCHAR2(80)    := FND_API.G_MISS_CHAR,
        primary_interest_code_id   NUMBER          := FND_API.G_MISS_NUM,
        primary_interest_code      VARCHAR2(100)   := FND_API.G_MISS_CHAR,
        secondary_interest_code_id NUMBER          := FND_API.G_MISS_NUM,
        secondary_interest_code    VARCHAR2(100)   := FND_API.G_MISS_CHAR,
        status_code                VARCHAR2(30)    := FND_API.G_MISS_CHAR,
        status                     VARCHAR2(80)    := FND_API.G_MISS_CHAR,
        description                VARCHAR2(240)   := FND_API.G_MISS_CHAR,
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
--  Interest Table:    interest_tbl_type
--
--
-- End of Comments

TYPE interest_tbl_type      IS TABLE OF interest_rec_type
          INDEX BY BINARY_INTEGER;
G_MISS_INTEREST_TBL     interest_tbl_type;

-- Start of Comments
--
--  Interest Code Record  (Account Classification, Contact Interest, Lead Classification): interest_rec_type
--
--  Parameters:
--    interest_code_id            Interest Code identifier
--    code                        A code to identify an interest item
--    interest_type_id            Type of interest
--    enabled_flag                A flag indicating whether code is enabled
--    parent_interest_code_id     Parent interest code identifier
--    category_id                 category identifier
--    category_set_id             category set identifier
--    org_id                      operating unit that performed the transaction
--    pf_item_id                  product family identifier
--    pf_organization_id          product familiy organization identifier
--    price                       price of secondary interest code
--    currency_code               currency code for the product family.
--    Description                 Free format text, if null then
--                                description of most detailed interest
--                                (i.e. secondary, if no secondary then
--                                primary, ...)
--    Attibute Category       No validation
--    Attibute 1 -15          No validation
--
--  Required
--    Interest_code_ID
--
--
-- End of Comments

TYPE interest_code_rec_type    IS RECORD
   ( interest_code_id           NUMBER        := FND_API.G_MISS_NUM,
     code                       VARCHAR2(100) := FND_API.G_MISS_CHAR,
     interest_type_id           NUMBER        := FND_API.G_MISS_NUM,
     revenue_class_id       NUMBER        := FND_API.G_MISS_NUM,
     enabled_flag               VARCHAR2(1)   := FND_API.G_MISS_CHAR,
     parent_interest_code_id    NUMBER        := FND_API.G_MISS_NUM,
     description                VARCHAR2(240) := FND_API.G_MISS_CHAR,
     category_id                NUMBER        := FND_API.G_MISS_NUM,
     category_set_id            NUMBER        := FND_API.G_MISS_NUM,
     org_id                     NUMBER        := FND_API.G_MISS_NUM,
     pf_item_id                 NUMBER        := FND_API.G_MISS_NUM,
     pf_organization_id         NUMBER        := FND_API.G_MISS_NUM,
     price                      NUMBER        := FND_API.G_MISS_NUM,
     currency_code              VARCHAR2(15)  := FND_API.G_MISS_CHAR,
     attribute_category         VARCHAR2(30),
     attribute1                 VARCHAR2(150),
     attribute2                 VARCHAR2(150),
     attribute3                 VARCHAR2(150),
     attribute4                 VARCHAR2(150),
     attribute5                 VARCHAR2(150),
     attribute6                 VARCHAR2(150),
     attribute7                 VARCHAR2(150),
     attribute8                 VARCHAR2(150),
     attribute9                 VARCHAR2(150),
     attribute10                VARCHAR2(150),
     attribute11                VARCHAR2(150),
     attribute12                VARCHAR2(150),
     attribute13                VARCHAR2(150),
     attribute14                VARCHAR2(150),
     attribute15                VARCHAR2(150),
     product_category_id        NUMBER      := FND_API.G_MISS_NUM,
     product_cat_set_id         NUMBER      := FND_API.G_MISS_NUM
   );


-- Start of Comments
--
--  Interest Table:    interest_code_tbl_type
--
--
-- End of Comments

TYPE interest_code_tbl_type      IS TABLE OF interest_code_rec_type
          INDEX BY BINARY_INTEGER;
G_MISS_INTEREST_CODE_REC     INTEREST_CODE_REC_TYPE;
G_MISS_INTEREST_code_TBL     interest_code_tbl_type;


-- Start of Comments
--
--  API name  : Create_Interest
--  Type      : Public
--  Function  : Create an interest for an existing account/contact/lead.
--  Pre-reqs  : If associating to customer, account, or opportunity, then
--        each must exist
--  Parameters :
--  IN    :
--      p_api_version_number  IN NUMBER   Required
--      p_init_msg_list   IN VARCHAR2     Optional
--          Default = FND_API.G_FALSE
--      p_commit        IN VARCHAR2   Optional
--          Default = FND_API.G_FALSE
--      p_interest_tbl    IN INTEREST_REC_TYPE  Optional
--
--  OUT   :
--      p_return_status   OUT VARCHAR2(1)
--      p_msg_count   OUT NUMBER
--      p_msg_data    OUT VARCHAR2(2000)
--      p_interest_id OUT NUMBER
--
--
--
--  Version :  Current version  1.0
--        Initial Version
--        Initial version  1.0
--
--  Notes:    OSM API to create interests
--
-- End of Comments
--
Procedure create_interest(p_api_version_number  in  number
                         ,p_init_msg_list       in  varchar2 := fnd_api.g_false
                         ,p_commit              in  varchar2 := fnd_api.g_false
             ,p_validation_level    IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
                         ,p_interest_rec        in  interest_rec_type
                         ,p_customer_id         in  number
                         ,p_address_id          in  number
                         ,p_contact_id          in  number
                         ,p_lead_id             in  number
                         ,p_interest_use_code   in  varchar2
                    ,p_check_access_flag   in  varchar2
                    ,p_admin_flag          in  varchar2
                    ,p_admin_group_id      in  number
                    ,p_identity_salesforce_id  in number
                    ,p_access_profile_rec  IN  AS_ACCESS_PUB.ACCESS_PROFILE_REC_TYPE
                         ,p_return_status       OUT NOCOPY varchar2
                         ,p_msg_count           OUT NOCOPY number
                         ,p_msg_data            OUT NOCOPY varchar2
             ,p_interest_out_id OUT NOCOPY number);


-- Start of Comments
--
--  API name    : Update Interest
--  Type        : Public
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
--  Version :   Current version 1.0
--              Initial Version
--           Initial version    1.0
--
--
--
-- End of Comments
--

PROCEDURE Update_Interest
(   p_api_version_number    IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2    := FND_API.G_FALSE,
    p_commit            IN      VARCHAR2    := FND_API.G_FALSE,
    p_validation_level  IN  NUMBER      :=FND_API.G_VALID_LEVEL_FULL,
        p_identity_salesforce_id  IN    NUMBER := NULL,
    p_interest_rec      IN  INTEREST_REC_TYPE := G_MISS_INTEREST_REC,
    p_interest_use_code IN  VARCHAR2,
     p_check_access_flag   in  varchar2,
     p_admin_flag          in  varchar2,
     p_admin_group_id      in  number,
     p_access_profile_rec  IN  AS_ACCESS_PUB.ACCESS_PROFILE_REC_TYPE,
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count     OUT NOCOPY  NUMBER,
    x_msg_data      OUT NOCOPY  VARCHAR2,
    x_interest_id       OUT NOCOPY     NUMBER
);

-- Start of Comments
--
-- NAME
--   Convert_Values_To_Ids
--
-- PURPOSE
--   Procedure converts public interest record into a private interest
--   record for use by the private create_interest API.
--
-- NOTES
--    This procedure is public so that it can be called by other API's.
--    It should not be called from sources outside of OSM
--
--
-- End of Comments

PROCEDURE Convert_Values_To_Ids ( p_interest_tbl    IN INTEREST_TBL_TYPE,
                                  p_pvt_interest_tbl  OUT NOCOPY AS_INTEREST_PVT.INTEREST_TBL_TYPE
                                  );



-- Start of Comments
--
-- NAME
--    Convert_Interest_Values_To_Ids
--
-- PURPOSE
--    Procedure converts interest type, primary, and secondar values to ids
--
-- NOTES
--    This procedure is public so that it can be called by other API's.
--    Currently this procedure is used by the Create_Opportunity API to
--    convert the expected purchase values to ids and from the interest
--    Convert value to Ids routine found above
--
--
-- End of Comments
PROCEDURE Convert_Interest_Values_To_Ids (  p_interest_type                 IN  VARCHAR2,
                                            p_interest_type_id              IN  NUMBER,
                                            p_primary_interest_code         IN  VARCHAR2,
                                            p_primary_interest_code_id      IN  NUMBER,
                                            p_secondary_interest_code       IN  VARCHAR2,
                                            p_secondary_interest_code_id    IN  NUMBER,
                            p_description           IN  VARCHAR2,
                                            p_return_status                 OUT NOCOPY VARCHAR2,
                                            p_out_interest_type_id          OUT NOCOPY NUMBER,
                                            p_out_primary_interest_code_id  OUT NOCOPY NUMBER,
                                            p_out_second_interest_code_id   OUT NOCOPY NUMBER,
                        p_out_description           OUT NOCOPY VARCHAR2
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

END AS_INTEREST_PUB;

 

/
