--------------------------------------------------------
--  DDL for Package EGO_PARTY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_PARTY_PUB" AUTHID CURRENT_USER AS
/*$Header: EGOPRTYS.pls 120.1 2006/04/12 04:23:56 srajapar noship $ */

--------------------------------------------------------------------------
--         START: Record Types for reference from HZ_PARTY_PUB          --
--------------------------------------------------------------------------

G_MISS_CONTENT_SOURCE_TYPE    VARCHAR2(60) := 'USER_ENTERED';

TYPE party_rec_type IS RECORD(
  party_id                NUMBER,
  party_number            VARCHAR2(30),
  validated_flag          VARCHAR2(1),
  orig_system_reference   VARCHAR2(240),
  status                  VARCHAR2(1),
  category_code           VARCHAR2(30),
  salutation              VARCHAR2(60),
  attribute_category      VARCHAR2(30),
  attribute1      VARCHAR2(150),
  attribute2      VARCHAR2(150),
  attribute3      VARCHAR2(150),
  attribute4      VARCHAR2(150),
  attribute5      VARCHAR2(150),
  attribute6      VARCHAR2(150),
  attribute7      VARCHAR2(150),
  attribute8      VARCHAR2(150),
  attribute9      VARCHAR2(150),
  attribute10     VARCHAR2(150),
  attribute11     VARCHAR2(150),
  attribute12     VARCHAR2(150),
  attribute13     VARCHAR2(150),
  attribute14     VARCHAR2(150),
  attribute15     VARCHAR2(150),
  attribute16     VARCHAR2(150),
  attribute17     VARCHAR2(150),
  attribute18     VARCHAR2(150),
  attribute19     VARCHAR2(150),
  attribute20     VARCHAR2(150),
  attribute21     VARCHAR2(150),
  attribute22     VARCHAR2(150),
  attribute23     VARCHAR2(150),
  attribute24     VARCHAR2(150)
  );

g_miss_party_rec       PARTY_REC_TYPE;


TYPE group_rec_type IS RECORD(
  group_name         VARCHAR2(255),
  group_type         VARCHAR2(30),
  created_by_module  VARCHAR2(150),
  application_id     NUMBER,
  wh_update_date     DATE,
  party_rec          PARTY_REC_TYPE := g_miss_party_rec
);

G_MISS_GROUP_REC  GROUP_REC_TYPE;

TYPE relationship_rec_type IS RECORD(
  relationship_id     NUMBER,
  subject_id          NUMBER,
  subject_type        VARCHAR2(30),
  subject_table_name  VARCHAR2(30),
  object_id           NUMBER,
  object_type         VARCHAR2(30),
  object_table_name   VARCHAR2(30),
  relationship_code   VARCHAR2(30),
  relationship_type   VARCHAR2(30),
  comments            VARCHAR2(240),
  start_date          DATE,
  end_date            DATE,
  status              VARCHAR2(1),
  content_source_type VARCHAR2(30),
  attribute_category  VARCHAR2(30),
  attribute1          VARCHAR2(150),
  attribute2          VARCHAR2(150),
  attribute3          VARCHAR2(150),
  attribute4          VARCHAR2(150),
  attribute5          VARCHAR2(150),
  attribute6          VARCHAR2(150),
  attribute7          VARCHAR2(150),
  attribute8          VARCHAR2(150),
  attribute9          VARCHAR2(150),
  attribute10         VARCHAR2(150),
  attribute11         VARCHAR2(150),
  attribute12         VARCHAR2(150),
  attribute13         VARCHAR2(150),
  attribute14         VARCHAR2(150),
  attribute15         VARCHAR2(150),
  attribute16         VARCHAR2(150),
  attribute17         VARCHAR2(150),
  attribute18         VARCHAR2(150),
  attribute19         VARCHAR2(150),
  attribute20         VARCHAR2(150),
  created_by_module   VARCHAR2(150),
  application_id      NUMBER,
  party_rec           PARTY_REC_TYPE,
  additional_information1   VARCHAR2(150),
  additional_information2   VARCHAR2(150),
  additional_information3   VARCHAR2(150),
  additional_information4   VARCHAR2(150),
  additional_information5   VARCHAR2(150),
  additional_information6   VARCHAR2(150),
  additional_information7   VARCHAR2(150),
  additional_information8   VARCHAR2(150),
  additional_information9   VARCHAR2(150),
  additional_information10  VARCHAR2(150),
  additional_information11  VARCHAR2(150),
  additional_information12  VARCHAR2(150),
  additional_information13  VARCHAR2(150),
  additional_information14  VARCHAR2(150),
  additional_information15  VARCHAR2(150),
  additional_information16  VARCHAR2(150),
  additional_information17  VARCHAR2(150),
  additional_information18  VARCHAR2(150),
  additional_information19  VARCHAR2(150),
  additional_information20  VARCHAR2(150),
  additional_information21  VARCHAR2(150),
  additional_information22  VARCHAR2(150),
  additional_information23  VARCHAR2(150),
  additional_information24  VARCHAR2(150),
  additional_information25  VARCHAR2(150),
  additional_information26  VARCHAR2(150),
  additional_information27  VARCHAR2(150),
  additional_information28  VARCHAR2(150),
  additional_information29  VARCHAR2(150),
  additional_information30  VARCHAR2(150),
  percentage_ownership      NUMBER
  );

G_MISS_PARTY_REL_REC  RELATIONSHIP_REC_TYPE;

--------------------------------------------------------------------------
--          END: Record Types for reference from HZ_PARTY_PUB           --
--------------------------------------------------------------------------

--------------------------------------------------------------------------
--       START: Record Types for reference from HZ_CONTACT_POINT        --
--------------------------------------------------------------------------
TYPE contact_point_rec_type IS RECORD (
    contact_point_id       NUMBER,
    contact_point_type     VARCHAR2(30),
    status                 VARCHAR2(30),
    owner_table_name       VARCHAR2(30),
    owner_table_id         NUMBER,
    primary_flag           VARCHAR2(1),
    orig_system_reference  VARCHAR2(240),
    content_source_type    VARCHAR2(30) := HZ_PARTY_V2PUB.G_MISS_CONTENT_SOURCE_TYPE,
    attribute_category     VARCHAR2(30),
    attribute1             VARCHAR2(150),
    attribute2             VARCHAR2(150),
    attribute3             VARCHAR2(150),
    attribute4             VARCHAR2(150),
    attribute5             VARCHAR2(150),
    attribute6             VARCHAR2(150),
    attribute7             VARCHAR2(150),
    attribute8             VARCHAR2(150),
    attribute9             VARCHAR2(150),
    attribute10            VARCHAR2(150),
    attribute11            VARCHAR2(150),
    attribute12            VARCHAR2(150),
    attribute13            VARCHAR2(150),
    attribute14            VARCHAR2(150),
    attribute15            VARCHAR2(150),
    attribute16            VARCHAR2(150),
    attribute17            VARCHAR2(150),
    attribute18            VARCHAR2(150),
    attribute19            VARCHAR2(150),
    attribute20            VARCHAR2(150),
    contact_point_purpose  VARCHAR2(30),
    primary_by_purpose     VARCHAR2(1),
    created_by_module      VARCHAR2(150),
    application_id         NUMBER
    );

TYPE edi_rec_type IS RECORD (
    edi_transaction_handling    VARCHAR2(25),
    edi_id_number               VARCHAR2(30),
    edi_payment_method          VARCHAR2(30),
    edi_payment_format          VARCHAR2(30),
    edi_remittance_method       VARCHAR2(30),
    edi_remittance_instruction  VARCHAR2(30),
    edi_tp_header_id            NUMBER,
    edi_ece_tp_location_code    VARCHAR2(40)
    );

G_MISS_EDI_REC                              EDI_REC_TYPE;

TYPE email_rec_type IS RECORD (
    email_format      VARCHAR2(30),
    email_address     VARCHAR2(2000)
    );

G_MISS_EMAIL_REC                            EMAIL_REC_TYPE;

TYPE phone_rec_type IS RECORD (
    phone_calling_calendar  VARCHAR2(30),
    last_contact_dt_time    DATE,
    timezone_id             NUMBER,
    phone_area_code         VARCHAR2(10),
    phone_country_code      VARCHAR2(10),
    phone_number            VARCHAR2(40),
    phone_extension         VARCHAR2(20),
    phone_line_type         VARCHAR2(30),
    raw_phone_number        VARCHAR2(60)
    );

G_MISS_PHONE_REC                            PHONE_REC_TYPE;

TYPE telex_rec_type IS RECORD (
    telex_number      VARCHAR2(50)
    );

G_MISS_TELEX_REC                            TELEX_REC_TYPE;

TYPE web_rec_type IS RECORD (
    web_type          VARCHAR2(60),
    url               VARCHAR2(2000)
    );

G_MISS_WEB_REC                              WEB_REC_TYPE;

HZ_FAIL_EXCEPTION EXCEPTION;

OWNER_TABLE_NAME      CONSTANT  VARCHAR2(30)  := 'HZ_PARTIES';
PRIMARY_FLAG          CONSTANT  VARCHAR2(1)   := 'Y';
CONTENT_SOURCE_TYPE   CONSTANT  VARCHAR2(30)  := 'USER_ENTERED';
APPLICATION_ID        CONSTANT  NUMBER        := 431;
CREATED_BY_MODULE     CONSTANT  VARCHAR2(30)  := 'EGO';
OBJECT_VERSION_NUMBER CONSTANT  NUMBER        := 0;
ACTIVE_STATUS         CONSTANT  VARCHAR2(1)   := 'A';

--------------------------------------------------------------------------
--        END: Record Types for reference from HZ_CONTACT_POINT         --
--------------------------------------------------------------------------

----------------------------------------------------------------------------
-- 0. Get_Application_id
----------------------------------------------------------------------------
FUNCTION get_application_id  RETURN NUMBER;
   ------------------------------------------------------------------------
   -- Start of comments
   -- API name  : GET_APPLICATION_ID
   -- TYPE      : Public
   -- Pre-reqs  : None
   -- FUNCTION  : Returns the application id of Engineering Groups
   --             If no application id is found, returns -1
   --
   -- Parameters:
   --     IN    :  NONE
   --
   --     OUT   :  NONE
   --
   -- Version: Current Version 1.0
   -- Previous Version :  None
   -- Notes  :
   --
   -- END OF comments
   ------------------------------------------------------------------------


----------------------------------------------------------------------------
-- 1. Create_Group
----------------------------------------------------------------------------
PROCEDURE create_group (
   p_api_version     IN NUMBER,
   p_init_msg_list   IN VARCHAR2,
   p_commit          IN VARCHAR2,
   p_group_name      IN VARCHAR2,
   p_group_type      IN VARCHAR2,
   p_description     IN VARCHAR2,
   p_email_address   IN VARCHAR2,
   p_creator_person_id  IN     NUMBER,
   x_return_status  OUT NOCOPY VARCHAR2,
   x_msg_count      OUT NOCOPY NUMBER,
   x_msg_data       OUT NOCOPY VARCHAR2,
   x_group_id       OUT NOCOPY NUMBER
   );
   ------------------------------------------------------------------------
   -- Start of comments
   -- API name  : Create_Group
   -- TYPE      : Public
   -- Pre-reqs  : None
   -- FUNCTION  : Create a People Group.
   --             If this operation fails then the category is not
   --              created and error code is returned.
   --
   -- Parameters:
   --     IN    : p_api_version   IN  NUMBER  (required)
   --     API Version of this procedure
   --             p_init_msg_level  IN  VARCHAR2  (optional)
   --                  DEFAULT = FND_API.G_FALSE
   --                  Indicates whether the message stack needs to be cleared
   --             p_commit    IN  VARCHAR2  (optional)
   --                  DEFAULT = FND_API.G_FALSE
   --                  Indicates whether the data should be committed
   --             p_group_name    IN  VARCHAR2  (required)
   --     Group name for the Group being created, updateable
   --             p_group_type    IN  VARCHAR2  (required)
   --     Group type - 'GROUP' for current purposes, non-updateable
   --     This value is stored in HZ_PARTIES.party_name
   --     The row created in HZ_PARTIES also has PARTY_TYPE = 'GROUP'
   --             p_description   IN  VARCHAR2  (optional)
   --     Group description, updateable
   --             p_email_address IN  VARCHAR2  (optional)
   --     Email address of the group, updateable
   --                  This value is inserted into hz_contact_points
   --                  The value is also stored in HZ_PARTIES (through API)
   --             p_create_person_id  IN  NUMBER  (required)
   --     creator of the group.
   --                   this is used to create membership
   --
   --     OUT   : x_return_status OUT  NUMBER
   --     Result of all the operations
   --                    FND_API.G_RET_STS_SUCCESS if success
   --                    FND_API.G_RET_STS_ERROR if error
   --                    FND_API.G_RET_STS_UNEXP_ERROR if unexpected error
   --             x_msg_count   OUT  NUMBER,
   --     number of messages in the message list
   --             x_msg_data    OUT  VARCHAR2,
   --       if number of messages is 1, then this parameter
   --     contains the message itself
   --             x_group_id    OUT  NUMBER
   --     new Group_Id that has been created.
   --
   --
   -- Version: Current Version 1.0
   -- Previous Version :  None
   -- Notes  :
   --
   -- END OF comments
   ------------------------------------------------------------------------


----------------------------------------------------------------------------
-- 2. Update_Group
----------------------------------------------------------------------------
procedure Update_Group (
   p_api_version     IN NUMBER,
   p_init_msg_list   IN VARCHAR2,
   p_commit          IN VARCHAR2,
   p_group_id        IN NUMBER,
   p_group_name      IN VARCHAR2,
   p_description     IN VARCHAR2,
   p_email_address   IN VARCHAR2,
 --  p_owner_person_id       IN      NUMBER,
   p_object_version_no_group  IN OUT  NOCOPY NUMBER,
  -- p_object_version_no_owner_rel   IN OUT  NOCOPY NUMBER,
   x_return_status  OUT NOCOPY VARCHAR2,
   x_msg_count      OUT NOCOPY NUMBER,
   x_msg_data       OUT NOCOPY VARCHAR2
   );
   ------------------------------------------------------------------------
   -- Start of comments
   -- API name  : Update_Group
   -- TYPE      : Public
   -- Pre-reqs  : Group should have been created
   -- FUNCTION  : Update a Group.
   --             Looks for the following relationships
   --                 If the Group Owner has changed
   --               update the owner relationship record
   --                 If the new Group Owner is not a member
   --               create a new member record
   --             If this operation fails then the category is not
   --              updated and error code is returned.
   --
   -- Parameters:
   --     IN    : p_api_version   IN  NUMBER  (required)
   --     API Version of this procedure
   --             p_init_msg_level  IN  VARCHAR2  (optional)
   --                  DEFAULT = FND_API.G_FALSE
   --                  Indicates whether the message stack needs to be cleared
   --             p_commit    IN  VARCHAR2  (optional)
   --                  DEFAULT = FND_API.G_FALSE
   --                  Indicates whether the data should be committed
   --             p_group_id    IN  NUMBER  (required)
   --     Group Id for the Group to be Updated
   --             p_description   IN  VARCHAR2  (optional)
   --     Group description to be implemented
   --             p_contact_point_id  IN  NUMBER  (required)
   --     As the contact point needs to be updated
   --             p_email_address IN  VARCHAR2  (optional)
   --     Email address that needs to be made effective
   --             p_owner_person_id IN  NUMBER  (required)
   --     Owner of the group
   --
   --     IN OUT: p_object_version_no_group IN OUT  NUMBER  (required)
   --     the version of group when the record is queried
   --     the new version is returned after successful update
   --             p_object_version_no_rel IN OUT  NUMBER  (required)
   --     the version of relation when the record is queried
   --     the new version is returned after successful update
   --             p_object_version_no_contact IN OUT  NUMBER  (required)
   --     the version of contact point when the record is queried
   --     the new version is returned after successful update
   --
   --     OUT   : x_return_status OUT  NUMBER
   --     Result of all the operations
   --                    FND_API.G_RET_STS_SUCCESS if success
   --                    FND_API.G_RET_STS_ERROR if error
   --                    FND_API.G_RET_STS_UNEXP_ERROR if unexpected error
   --             x_msg_count   OUT  NUMBER,
   --     number of messages in the message list
   --             x_msg_data    OUT  VARCHAR2,
   --       if number of messages is 1, then this parameter
   --     contains the message itself
   --
   --
   -- Version: Current Version 1.0
   -- Previous Version :  None
   -- Notes  :
   --
   -- END OF comments
   ------------------------------------------------------------------------


----------------------------------------------------------------------------
-- 3. Delete_Group
----------------------------------------------------------------------------
procedure delete_group (
   p_api_version     IN NUMBER,
   p_init_msg_list   IN VARCHAR2,
   p_commit          IN VARCHAR2,
   p_group_id        IN NUMBER,
   p_object_version_no_group  IN OUT  NOCOPY NUMBER,
   x_return_status  OUT NOCOPY VARCHAR2,
   x_msg_count      OUT NOCOPY NUMBER,
   x_msg_data       OUT NOCOPY VARCHAR2
   );
   ------------------------------------------------------------------------
   -- Start of comments
   -- API name  : Delete_Group
   -- TYPE      : Public
   -- Pre-reqs  : None
   -- FUNCTION  : Delete a Group.
   --
   -- Parameters:
   --     IN    : p_api_version     IN  NUMBER  (required)
   --     API Version of this procedure
   --             p_init_msg_level    IN  VARCHAR2  (optional)
   --                  DEFAULT = FND_API.G_FALSE
   --                  Indicates whether the message stack needs to be cleared
   --             p_commit      IN  VARCHAR2  (optional)
   --                  DEFAULT = FND_API.G_FALSE
   --                  Indicates whether the data should be committed
   --             p_group_id      IN  NUMBER  (required)
   --     Group Id for the Group to be Deleted
   --
   --     IN OUT: p_object_version_number IN OUT  NUMBER  (required)
   --     version number of the record to be Deleted
   --
   --     OUT   : x_return_status   OUT  NUMBER
   --     Result of all the operations
   --                    FND_API.G_RET_STS_SUCCESS if success
   --                    FND_API.G_RET_STS_ERROR if error
   --                    FND_API.G_RET_STS_UNEXP_ERROR if unexpected error
   --             x_msg_count     OUT  NUMBER,
   --     number of messages in the message list
   --             x_msg_data      OUT  VARCHAR2,
   --       if number of messages is 1, then this parameter
   --     contains the message itself
   --
   --
   -- Version: Current Version 1.0
   -- Previous Version :  None
   -- Notes  :
   --
   -- END OF comments
   ------------------------------------------------------------------------


----------------------------------------------------------------------------
-- 4. Add_Group_Member
----------------------------------------------------------------------------
procedure add_group_member (
   p_api_version       IN NUMBER,
   p_init_msg_list     IN VARCHAR2,
   p_commit            IN VARCHAR2,
   p_member_id         IN NUMBER,
   p_group_id          IN NUMBER,
   p_start_date        IN DATE,
   p_end_date          IN DATE,
   x_return_status    OUT NOCOPY VARCHAR2,
   x_msg_count        OUT NOCOPY NUMBER,
   x_msg_data         OUT NOCOPY VARCHAR2,
   x_relationship_id  OUT NOCOPY NUMBER
   );
   ------------------------------------------------------------------------
   -- Start of comments
   -- API name  : Add_Group_Member
   -- TYPE      : Public
   -- Pre-reqs  : Group Exists and the current person is not an already
   --             existing member of the group
   -- FUNCTION  : Add a member to a Group.
   --             A member that could be added is a Group itself
   --             (or) a Person (or) Both
   --
   --             If this operation fails then the category is not
   --              created and error code is returned.
   --
   -- Parameters:
   --     IN    : p_api_version   IN  NUMBER  (required)
   --     API Version of this procedure
   --             p_init_msg_level  IN  VARCHAR2  (optional)
   --                  DEFAULT = FND_API.G_FALSE
   --                  Indicates whether the message stack needs to be cleared
   --             p_commit    IN  VARCHAR2  (optional)
   --                  DEFAULT = FND_API.G_FALSE
   --                  Indicates whether the data should be committed
   --             p_group_id    IN  NUMBER  (required)
   --     Group Id for which the member is added.
   --             p_member_id   IN  NUMBER  (required)
   --     Member Id  which should be added to the group.
   --             p_start_date    IN  DATE  (optional)
   --                   To indicate the effective date of the relationship
   --             p_end_date    IN  DATE  (optional)
   --                   To indicate the end date of the relationship
   --
   --     OUT   : x_return_status OUT  NUMBER
   --     Result of all the operations
   --                    FND_API.G_RET_STS_SUCCESS if success
   --                    FND_API.G_RET_STS_ERROR if error
   --                    FND_API.G_RET_STS_UNEXP_ERROR if unexpected error
   --             x_msg_count   OUT  NUMBER
   --     number of messages in the message list
   --             x_msg_data    OUT  VARCHAR2
   --       if number of messages is 1, then this parameter
   --     contains the message itself
   --             x_relationship_id OUT  NUMBER
   --     Relationship_Id created between Group AND member
   --     These valuee is stored at
   --     hz_relationships.PARTY_RELATIONSHIP_ID
   --
   --
   -- Version: Current Version 1.0
   -- Previous Version :  None
   -- Notes  :
   --
   -- END OF comments
   ------------------------------------------------------------------------

----------------------------------------------------------------------------
-- 5. Remove_Group_Member
----------------------------------------------------------------------------
procedure remove_group_member (
   p_api_version       IN NUMBER,
   p_init_msg_list     IN VARCHAR2,
   p_commit            IN VARCHAR2,
   p_relationship_id   IN NUMBER,
   p_object_version_no_rel  IN OUT  NOCOPY NUMBER,
   x_return_status    OUT NOCOPY VARCHAR2,
   x_msg_count        OUT NOCOPY NUMBER,
   x_msg_data         OUT NOCOPY VARCHAR2
   );
   ------------------------------------------------------------------------
   -- Start of comments
   -- API name  : Remove_Group_Member
   -- TYPE      : Public
   -- Pre-reqs  : Group Exists and the current person is an already
   --             existing member of the group
   -- FUNCTION  : Remove member from the Group
   --             The status of the record is made 'I', Inactive
   --
   -- Parameters:
   --     IN    : p_api_version   IN  NUMBER  (required)
   --     API Version of this procedure
   --             p_init_msg_level  IN  VARCHAR2  (optional)
   --                  DEFAULT = FND_API.G_FALSE
   --                  Indicates whether the message stack needs to be cleared
   --             p_commit    IN  VARCHAR2  (optional)
   --                  DEFAULT = FND_API.G_FALSE
   --                  Indicates whether the data should be committed
   --             p_relationship_id IN   NUMBER (required
   --     Relationship_Id that has been created between Group_id.
   --     and the Member_Id which needs to be deleted (which is
   --     eventually deleted from hz_relationships)
   --
   --     IN OUT: p_object_version_no_rel IN OUT  NUMBER  (required)
   --     the version of group when the record is queried
   --     the new version is returned after successful update
   --
   --     OUT   : x_return_status OUT  NUMBER
   --     Result of all the operations
   --                    FND_API.G_RET_STS_SUCCESS if success
   --                    FND_API.G_RET_STS_ERROR if error
   --                    FND_API.G_RET_STS_UNEXP_ERROR if unexpected error
   --             x_msg_count   OUT  NUMBER
   --     number of messages in the message list
   --             x_msg_data    OUT  VARCHAR2
   --       if number of messages is 1, then this parameter
   --     contains the message itself
   --             x_relationship_id OUT  NUMBER
   --     Relationship_Id created between Group AND member
   --     These valuee is stored at
   --     hz_relationships.PARTY_RELATIONSHIP_ID
   --
   --
   -- Version: Current Version 1.0
   -- Previous Version :  None
   -- Notes  :
   --
   -- END OF comments
   ------------------------------------------------------------------------

-------------------------------------------------------------------------
-- 6. Get_Email_Address (party_id can be person / group Id)
----------------------------------------------------------------------------
procedure Get_Email_Address (
  p_api_version     IN NUMBER,
  p_init_msg_list   IN VARCHAR2,
  p_commit          IN VARCHAR2,
  p_party_id        IN NUMBER,
  x_return_status  OUT NOCOPY VARCHAR2,
  x_msg_count      OUT NOCOPY NUMBER,
  x_msg_data       OUT NOCOPY VARCHAR2,
  x_email_address  OUT NOCOPY VARCHAR2
  );

   ------------------------------------------------------------------------
   -- Start of comments
   -- API name  : Get_Email_Address
   -- TYPE      : Public
   -- Pre-reqs  : An existing Group
   -- FUNCTION  : Returns the email addresses of all the members of the group
   --             if group_id is passed.  If person_id is passed, then
   --             email address of the person is returned back.
   --
   -- Parameters:
   --     IN    : p_api_version   IN  NUMBER  (required)
   --     API Version of this procedure
   --             p_init_msg_level  IN  VARCHAR2  (optional)
   --                  DEFAULT = FND_API.G_FALSE
   --                  Indicates whether the message stack needs to be cleared
   --             p_commit    IN  VARCHAR2  (optional)
   --                  DEFAULT = FND_API.G_FALSE
   --                  Indicates whether the data should be committed
   --             p_group_id    IN  NUMBER  (required)
   --     The group for which the email address list is required
   --
   --     OUT   : x_return_status OUT  NUMBER
   --     Result of all the operations
   --                    FND_API.G_RET_STS_SUCCESS if success
   --                    FND_API.G_RET_STS_ERROR if error
   --                    FND_API.G_RET_STS_UNEXP_ERROR if unexpected error
   --             x_msg_count   OUT  NUMBER
   --     number of messages in the message list
   --             x_msg_data    OUT  VARCHAR2
   --       if number of messages is 1, then this parameter
   --     contains the message itself
   --             x_email_address OUT  VARCHAR2
   --       Contains the email address of all the members
   --
   -- Version: Current Version 1.0
   -- Previous Version :  None
   -- Notes  :
   --
   -- END OF comments
   ------------------------------------------------------------------------

----------------------------------------------------------------------------
-- 7. Create_Code_Assignment
----------------------------------------------------------------------------
PROCEDURE create_code_assignment (
  p_api_version     IN NUMBER,
  p_init_msg_list   IN VARCHAR2,
  p_commit          IN VARCHAR2,
  p_party_id        IN NUMBER,
  p_category        IN VARCHAR2,
  p_code            IN VARCHAR2,
  x_msg_count      OUT NOCOPY NUMBER,
  x_return_status  OUT NOCOPY VARCHAR2,
  x_msg_data       OUT NOCOPY VARCHAR2,
  x_assignment_id  OUT NOCOPY NUMBER
);
   ------------------------------------------------------------------------
   -- Start of comments
   -- API name  : create_code_assignment
   -- TYPE      : Public
   -- Pre-reqs  : The class category, p_category, the class code, p_code, and
   --             the person, p_party_id exists.
   -- FUNCTION  : Assigns the hz_code_assignment p_category, p_code to the party_id
   --
   -- Parameters:
   --     IN    : p_api_version   IN  NUMBER  (required)
   --     API Version of this procedure
   --             p_init_msg_level  IN  VARCHAR2  (optional)
   --                  DEFAULT = FND_API.G_FALSE
   --                  Indicates whether the message stack needs to be cleared
   --             p_commit    IN  VARCHAR2  (optional)
   --                  DEFAULT = FND_API.G_FALSE
   --                  Indicates whether the data should be committed
   --             p_relationship_id IN   NUMBER (required
   --     Relationship_Id that has been created between Group_id.
   --     and the Member_Id which needs to be deleted (which is
   --     eventually deleted from hz_relationships)
   --
   --     IN OUT: p_object_version_no_rel IN OUT  NUMBER  (required)
   --     the version of group when the record is queried
   --     the new version is returned after successful update
   --
   --     OUT   : x_return_status OUT  NUMBER
   --     Result of all the operations
   --                    FND_API.G_RET_STS_SUCCESS if success
   --                    FND_API.G_RET_STS_ERROR if error
   --                    FND_API.G_RET_STS_UNEXP_ERROR if unexpected error
   --             x_msg_count   OUT  NUMBER
   --     number of messages in the message list
   --             x_msg_data    OUT  VARCHAR2
   --       if number of messages is 1, then this parameter
   --     contains the message itself
   --             x_relationship_id OUT  NUMBER
   --     Relationship_Id created between Group AND member
   --     These valuee is stored at
   --     hz_relationships.PARTY_RELATIONSHIP_ID
   --
   --
   -- Version: Current Version 1.0
   -- Previous Version :  None
   -- Notes  :
   --
   -- END OF comments
   ------------------------------------------------------------------------

----------------------------------------------------------------------------
-- 8. Update_Code_Assignment
----------------------------------------------------------------------------
PROCEDURE update_code_assignment (
  p_api_version     IN NUMBER,
  p_init_msg_list   IN VARCHAR2,
  p_commit          IN VARCHAR2,
  p_party_id        IN NUMBER,
  p_category        IN VARCHAR2,
  p_code            IN VARCHAR2,
  x_return_status  OUT NOCOPY VARCHAR2,
  x_msg_count      OUT NOCOPY NUMBER,
  x_msg_data       OUT NOCOPY VARCHAR2
);
   ------------------------------------------------------------------------
   -- Start of comments
   -- API name  : create_code_assignment
   -- TYPE      : Public
   -- Pre-reqs  : The class category, p_category, the class code, p_code, and
   --             the person, p_party_id exists.
   -- FUNCTION  : Assigns the hz_code_assignment p_category, p_code to the party_id
   --
   -- Parameters:
   --     IN    : p_api_version   IN  NUMBER  (required)
   --     API Version of this procedure
   --             p_init_msg_level  IN  VARCHAR2  (optional)
   --                  DEFAULT = FND_API.G_FALSE
   --                  Indicates whether the message stack needs to be cleared
   --             p_commit    IN  VARCHAR2  (optional)
   --                  DEFAULT = FND_API.G_FALSE
   --                  Indicates whether the data should be committed
   --             p_relationship_id IN   NUMBER (required
   --     Relationship_Id that has been created between Group_id.
   --     and the Member_Id which needs to be deleted (which is
   --     eventually deleted from hz_relationships)
   --
   --     IN OUT: p_object_version_no_rel IN OUT  NUMBER  (required)
   --     the version of group when the record is queried
   --     the new version is returned after successful update
   --
   --     OUT   : x_return_status OUT  NUMBER
   --     Result of all the operations
   --                    FND_API.G_RET_STS_SUCCESS if success
   --                    FND_API.G_RET_STS_ERROR if error
   --                    FND_API.G_RET_STS_UNEXP_ERROR if unexpected error
   --             x_msg_count   OUT  NUMBER
   --     number of messages in the message list
   --             x_msg_data    OUT  VARCHAR2
   --       if number of messages is 1, then this parameter
   --     contains the message itself
   --             x_relationship_id OUT  NUMBER
   --     Relationship_Id created between Group AND member
   --     These valuee is stored at
   --     hz_relationships.PARTY_RELATIONSHIP_ID
   --
   --
   -- Version: Current Version 1.0
   -- Previous Version :  None
   -- Notes  :
   --
   -- END OF comments


------------------------------------------------------------------------
-- 9. Set-up Company relationship for internal people
------------------------------------------------------------------------
   PROCEDURE setup_enterprise_user(p_company_id     IN NUMBER
                                  ,x_return_status OUT NOCOPY VARCHAR2
                                  ,x_msg_count     OUT NOCOPY NUMBER
                                  ,x_msg_data      OUT NOCOPY VARCHAR2
                                  );
   ------------------------------------------------------------------------
   -- Start of comments
   -- API name  : setup_enterprise_user
   -- TYPE      : Public
   -- Parameters:
   --   IN    :
   --     p_company_id    NUMBER  (required)
   --       Company for which grant is being created
   --   OUT   :
   --     x_return_status
   --     x_msg_count
   --     x_msg_data
   --       Standard out parameters for status
   ------------------------------------------------------------------------

------------------------------------------------------------------------
-- 10. Concurrent Program to setup enterprise users
------------------------------------------------------------------------
   PROCEDURE setup_enterprise_user_CP
       (x_errbuff   OUT NOCOPY VARCHAR2
       ,x_retcode   OUT NOCOPY VARCHAR2
       );
   ------------------------------------------------------------------------
   -- Start of comments
   -- API name  : setup_enterprise_user
   -- TYPE      : PRIVATE
   -- Version   :
   --    Current  : 1.0
   --    Previous : None
   -- Notes  :
   --    This is the concurrent program to setup the users
   --    This concurrent program will be called whenever user exists
   --    without having their default organization set.
   -- END OF comments
   ------------------------------------------------------------------------
END EGO_PARTY_PUB;

 

/
