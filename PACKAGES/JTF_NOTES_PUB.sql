--------------------------------------------------------
--  DDL for Package JTF_NOTES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_NOTES_PUB" AUTHID CURRENT_USER as
/* $Header: jtfnotes.pls 120.9 2006/06/28 09:55:13 mpadhiar ship $ */
/*#
 * A public interface that can be used to create, update, and delete notes for various business entities such as Service Request, Task, Customer, etc.
 *
 * @rep:scope public
 * @rep:product CAC
 * @rep:displayname Notes Management
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY CAC_NOTE
 * @rep:category BUSINESS_ENTITY CS_SERVICE_REQUEST
 * @rep:category BUSINESS_ENTITY AS_OPPORTUNITY
 * @rep:category BUSINESS_ENTITY AMS_LEAD
 */


TYPE jtf_note_contexts_rec_type IS
RECORD( NOTE_CONTEXT_ID        NUMBER
      , JTF_NOTE_ID            NUMBER
      , NOTE_CONTEXT_TYPE      VARCHAR2(240)
      , NOTE_CONTEXT_TYPE_ID   NUMBER
      , LAST_UPDATE_DATE       DATE
      , LAST_UPDATED_BY        NUMBER(15)
      , CREATION_DATE          DATE
      , CREATED_BY             NUMBER
      , LAST_UPDATE_LOGIN      NUMBER
      );

TYPE jtf_note_contexts_tbl_type IS
TABLE of jtf_note_contexts_rec_type
INDEX BY BINARY_INTEGER;

jtf_note_contexts_tab      jtf_note_contexts_tbl_type;
jtf_note_contexts_tab_dflt jtf_note_contexts_tbl_type;


PROCEDURE Create_note
-- --------------------------------------------------------------------------
-- Start of notes
--  API Name    : Create_Note
--  Type        : Public
--  Description : Insert a Note into JTF_NOTES table
--  Pre-reqs    :
--  Parameters  :
--     p_parent_note_id           IN     NUMBER     Optional Default = FND_API.G_MISS_NUM
--     p_jtf_note_id              IN     NUMBER     Optional Default = FND_API.G_MISS_NUM
--     p_api_version              IN     NUMBER     Required
--     p_init_msg_list            IN     VARCHAR2   Optional Default = FND_API.G_FALSE
--     p_commit                   IN     VARCHAR2   Optional Default = FND_API.G_FALSE
--     p_validation_level         IN     NUMBER     Optional Default = FND_API.G_VALID_LEVEL_FULL
--                                                  This parameter should always be
--                                                  FND_API.G_VALID_LEVEL_FULL if the api is called from external apis
--     p_return_status               OUT VARCHAR2   Required Length  = 1
--     p_msg_count                   OUT NUMBER     Required
--     p_msg_data                    OUT VARCHAR2   Required Length  = 2000
--     p_source_object_id         IN     NUMBER     (eg  request_id for Service Request)
--     p_source_object_code       IN     VARCHAR2   (eg  INC for Service Request)
--     p_notes                    IN     VARCHAR2   Required
--     p_notes_detail             IN     VARCHAR2   Optional Default NULL
--     p_note_status              IN     VARCHAR2   Default 'I'
--     p_entered_by               IN     NUMBER     Required
--     p_entered_date             IN     DATE       Required
--     p_jtf_note_id                 OUT NUMBER     Required
--     p_last_update_date         IN     DATE       Required
--     p_last_updated_by          IN     NUMBER     Optional Default fnd_global.user_id
--     p_creation_date            IN     DATE       Required
--     p_created_by               IN     NUMBER     Optional Default fnd_global.user_id
--     p_last_update_login        IN     NUMBER     Optional Default fnd_global.login_id
--     p_attribute1               IN     VARCHAR2   Optional Default NULL
--     p_attribute2               IN     VARCHAR2   Optional Default NULL
--     p_attribute3               IN     VARCHAR2   Optional Default NULL
--     p_attribute4               IN     VARCHAR2   Optional Default NULL
--     p_attribute5               IN     VARCHAR2   Optional Default NULL
--     p_attribute6               IN     VARCHAR2   Optional Default NULL
--     p_attribute7               IN     VARCHAR2   Optional Default NULL
--     p_attribute8               IN     VARCHAR2   Optional Default NULL
--     p_attribute9               IN     VARCHAR2   Optional Default NULL
--     p_attribute10              IN     VARCHAR2   Optional Default NULL
--     p_attribute11              IN     VARCHAR2   Optional Default NULL
--     p_attribute12              IN     VARCHAR2   Optional Default NULL
--     p_attribute13              IN     VARCHAR2   Optional Default NULL
--     p_attribute14              IN     VARCHAR2   Optional Default NULL
--     p_attribute15              IN     VARCHAR2   Optional Default NULL
--     p_context                  IN     VARCHAR2   Optional Default NULL
--
--  Version     : Initial Version     1.0
--
--  Notes       :
--
-- p_note_type      IN VARCHAR2 Optional Default = NULL
--
-- Version : Revision   1.1
--
--  Notes       :
--
--  Added the context table as a PL/SQL table type
--
-- End of notes
-- --------------------------------------------------------------------------

( p_parent_note_id        IN            NUMBER   DEFAULT 9.99E125
, p_jtf_note_id           IN            NUMBER   DEFAULT 9.99E125
, p_api_version           IN            NUMBER
, p_init_msg_list         IN            VARCHAR2 DEFAULT 'F'
, p_commit                IN            VARCHAR2 DEFAULT 'F'
, p_validation_level      IN            NUMBER   DEFAULT 100
, x_return_status            OUT NOCOPY VARCHAR2
, x_msg_count                OUT NOCOPY NUMBER
, x_msg_data                 OUT NOCOPY VARCHAR2
, p_org_id                IN            NUMBER   DEFAULT NULL
, p_source_object_id      IN            NUMBER   DEFAULT 9.99E125
, p_source_object_code    IN            VARCHAR2 DEFAULT CHR(0)
, p_notes                 IN            VARCHAR2 DEFAULT CHR(0)
, p_notes_detail          IN            VARCHAR2 DEFAULT NULL
, p_note_status           IN            VARCHAR2 DEFAULT 'I'
, p_entered_by            IN            NUMBER   DEFAULT FND_GLOBAL.USER_ID
, p_entered_date          IN            DATE     DEFAULT TO_DATE('1','j')
, x_jtf_note_id              OUT NOCOPY NUMBER
, p_last_update_date      IN            DATE     DEFAULT TO_DATE('1','j')
, p_last_updated_by       IN            NUMBER   DEFAULT FND_GLOBAL.USER_ID
, p_creation_date         IN            DATE     DEFAULT TO_DATE('1','j')
, p_created_by            IN            NUMBER   DEFAULT FND_GLOBAL.USER_ID
, p_last_update_login     IN            NUMBER   DEFAULT FND_GLOBAL.LOGIN_ID
, p_attribute1            IN            VARCHAR2 DEFAULT NULL
, p_attribute2            IN            VARCHAR2 DEFAULT NULL
, p_attribute3            IN            VARCHAR2 DEFAULT NULL
, p_attribute4            IN            VARCHAR2 DEFAULT NULL
, p_attribute5            IN            VARCHAR2 DEFAULT NULL
, p_attribute6            IN            VARCHAR2 DEFAULT NULL
, p_attribute7            IN            VARCHAR2 DEFAULT NULL
, p_attribute8            IN            VARCHAR2 DEFAULT NULL
, p_attribute9            IN            VARCHAR2 DEFAULT NULL
, p_attribute10           IN            VARCHAR2 DEFAULT NULL
, p_attribute11           IN            VARCHAR2 DEFAULT NULL
, p_attribute12           IN            VARCHAR2 DEFAULT NULL
, p_attribute13           IN            VARCHAR2 DEFAULT NULL
, p_attribute14           IN            VARCHAR2 DEFAULT NULL
, p_attribute15           IN            VARCHAR2 DEFAULT NULL
, p_context               IN            VARCHAR2 DEFAULT NULL
, p_note_type             IN            VARCHAR2 DEFAULT NULL
, p_jtf_note_contexts_tab IN            jtf_note_contexts_tbl_type
                                           DEFAULT jtf_note_contexts_tab_dflt
);


PROCEDURE Update_note
-- --------------------------------------------------------------------------
-- Start of notes
--  API Name  : Update_Note
--  Type      : Public
--  Usage     : Updates a note record in the table JTF_NOTES
--  Pre-reqs  : None
--  Parameters  :
--    p_api_version           IN    NUMBER     Required
--    p_init_msg_list         IN    VARCHAR2   Optional Default = FND_API.G_FALSE
--    p_commit                IN    VARCHAR2   Optional Default = FND_API.G_FALSE
--    p_validation_level      IN    NUMBER     Optional Default = FND_API.G_VALID_LEVEL_FULL
--    x_return_status           OUT VARCHAR2   Required
--    x_msg_count               OUT NUMBER     Required
--    x_msg_data                OUT VARCHAR2   Required
--    p_jtf_note_id           IN    NUMBER     Required Primary key of the note record
--    p_last_updated_by       IN    NUMBER     Required Corresponds to the column USER_ID in the table FND_USER, and
--                                                      identifies the Oracle Applications user who updated this record
--    p_last_update_date      IN    DATE       Optional Date on which this record is updated
--    p_last_update_login     IN    NUMBER     Optional Corresponds to the column LOGIN_ID in the table FND_LOGINS,
--                                                      and identifies the login session of the user
--    p_notes                 IN    VARCHAR2   Optional Updated note max 2000 Characters
--    p_notes_detail          IN    VARCHAR2   Optional Updated note detail max 32Kb
--    p_append_flag           IN    VARCHAR2   Optional DEFAULT 'F'
--    p_note_status           IN    VARCHAR2   Optional Indicates the status of the note.
--                                                      Whether it is 'P'rivate/'I'Public/'P'ublish
--                                                      'I' Public is the default
--    p_note_type             IN    VARCHAR2   Optional Type of the Note
--    p_jtf_note_contexts_tab IN    jtf_note_contexts_tbl_type
--                                             Optional Default  jtf_note_contexts_tab_dflt
--
--  Version     : Initial version        1.0
--
--
-- End of notes
-- --------------------------------------------------------------------------
( p_api_version           IN            NUMBER
, p_init_msg_list         IN            VARCHAR2 DEFAULT 'F'
, p_commit                IN            VARCHAR2 DEFAULT 'F'
, p_validation_level      IN            NUMBER   DEFAULT 100
, x_return_status            OUT NOCOPY VARCHAR2
, x_msg_count                OUT NOCOPY NUMBER
, x_msg_data                 OUT NOCOPY VARCHAR2
, p_jtf_note_id           IN            NUMBER
, p_entered_by            IN            NUMBER   DEFAULT FND_GLOBAL.USER_ID
, p_last_updated_by       IN            NUMBER
, p_last_update_date      IN            DATE     DEFAULT SYSDATE
, p_last_update_login     IN            NUMBER   DEFAULT NULL
, p_notes                 IN            VARCHAR2 DEFAULT CHR(0)
, p_notes_detail          IN            VARCHAR2 DEFAULT CHR(0)
, p_append_flag           IN            VARCHAR2 DEFAULT CHR(0)
, p_note_status           IN            VARCHAR2 DEFAULT 'I'
, p_note_type             IN            VARCHAR2 DEFAULT CHR(0)
, p_jtf_note_contexts_tab IN            jtf_note_contexts_tbl_type
                                          DEFAULT jtf_note_contexts_tab_dflt
);


PROCEDURE Validate_note_type
-- --------------------------------------------------------------------------
-- Start of notes
--  API Name  : Validate_note_type
--  Type      : Private
--  Usage     : This procedure accepts the note_type as input and checks
--              whether it is present at the fnd_LOOKUPS table for the
--              lookup_type of 'JTF_note_type'
-- --------------------------------------------------------------------------
( p_api_name        IN            VARCHAR2
, p_parameter_name  IN            VARCHAR2
, p_note_type       IN            VARCHAR2
, x_return_status      OUT NOCOPY VARCHAR2
);


PROCEDURE Create_note_context
-- --------------------------------------------------------------------------
-- Start of notes
--  API Name  : Create_note_context
--  Type      : Private
--  Usage     : This procedure will create a record in the jtf_note_contexts
--              table. If the context record already exists it will not be
--              created.
-- --------------------------------------------------------------------------
( p_validation_level     IN            NUMBER   DEFAULT 100
, x_return_status           OUT NOCOPY VARCHAR2
, p_jtf_note_id          IN            NUMBER
, p_last_update_date     IN            DATE
, p_last_updated_by      IN            NUMBER
, p_creation_date        IN            DATE
, p_created_by           IN            NUMBER   DEFAULT FND_GLOBAL.USER_ID
, p_last_update_login    IN            NUMBER   DEFAULT FND_GLOBAL.LOGIN_ID
, p_note_context_type_id IN            NUMBER   DEFAULT 9.99E125
, p_note_context_type    IN            VARCHAR2 DEFAULT CHR(0)
, x_note_context_id         OUT NOCOPY NUMBER
);

PROCEDURE Update_note_context
-- --------------------------------------------------------------------------
-- Start of notes
--  API Name  : Update_note_context
--  Type      : Private
--  Usage     : This procedure will update a record in the jtf_note_contexts
--              table.
-- --------------------------------------------------------------------------
( p_validation_level     IN            NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL
, x_return_status           OUT NOCOPY VARCHAR2
, p_note_context_id      IN            NUMBER
, p_jtf_note_id          IN            NUMBER
, p_note_context_type_id IN            NUMBER
, p_note_context_type    IN            VARCHAR2
, p_last_updated_by      IN            NUMBER
, p_last_update_date     IN            DATE     DEFAULT SYSDATE
, p_last_update_login    IN            NUMBER   DEFAULT NULL
);

PROCEDURE Add_Invalid_Argument_Msg
-- --------------------------------------------------------------------------
-- Start of notes
--  API Name  : Add_Invalid_Argument_Msg
--  Type      : Private
--  Usage     : do not use
-- --------------------------------------------------------------------------
( p_token_an  IN   VARCHAR2
, p_token_v   IN   VARCHAR2
, p_token_p   IN   VARCHAR2
);


PROCEDURE Add_Missing_Param_Msg
-- --------------------------------------------------------------------------
-- Start of notes
--  API Name  : Add_Missing_Param_Msg
--  Type      : Private
--  Usage     : do not use
-- --------------------------------------------------------------------------
( p_token_an  IN  VARCHAR2
, p_token_mp  IN  VARCHAR2
);


PROCEDURE Add_Null_Parameter_Msg
-- --------------------------------------------------------------------------
-- Start of notes
--  API Name  : Add_Null_Parameter_Msg
--  Type      : Private
--  Usage     : do not use
-- --------------------------------------------------------------------------
( p_token_an  IN  VARCHAR2
, p_token_np  IN  VARCHAR2
);


PROCEDURE Trunc_String_length
-- --------------------------------------------------------------------------
-- Start of notes
--  API Name  : Trunc_String_length
--  Type      : Private
--  Usage     : do not use
-- --------------------------------------------------------------------------
( p_api_name       IN            VARCHAR2
, p_parameter_name IN            VARCHAR2
, p_str            IN            VARCHAR2
, p_len            IN            NUMBER
, x_str               OUT NOCOPY VARCHAR2
);

PROCEDURE Validate_object
-- --------------------------------------------------------------------------
-- Start of notes
--  API Name  : Validate_object
--  Type      : Private
--  Usage     : do not use
-- --------------------------------------------------------------------------
( p_api_name         IN            VARCHAR2
, p_object_type_code IN            VARCHAR2
, p_object_type_id   IN            NUMBER
, x_return_status       OUT NOCOPY VARCHAR2
);

PROCEDURE writeLobToData
-- --------------------------------------------------------------------------
-- Start of notes
--  API Name  : writeLobToData
--  Type      : Private
--  Usage     : do not use
-- --------------------------------------------------------------------------
( x_jtf_note_id               NUMBER
, x_buffer         OUT NOCOPY VARCHAR2
);

PROCEDURE writeDatatoLob
-- --------------------------------------------------------------------------
-- Start of notes
--  API Name  : writeDatatoLob
--  Type      : Private
--  Usage     : do not use
-- --------------------------------------------------------------------------
( x_jtf_note_id       NUMBER
, x_buffer            VARCHAR2
);

PROCEDURE validate_entered_by
-- --------------------------------------------------------------------------
-- Start of notes
--  API Name  : validate_entered_by
--  Type      : Private
--  Usage     : do not use
-- --------------------------------------------------------------------------
( p_entered_by      IN            NUMBER
, x_return_status      OUT NOCOPY VARCHAR2
, x_entered_by         OUT NOCOPY NUMBER
);

/*#
 * Deletes an existing note while applying appropriate security policies.
 *
 * @param p_jtf_note_id Unique note identifier, identifies which note record is to be deleted.
 * @param p_api_version Standard API version number.
 * @param p_init_msg_list Standard API flag allows API callers to request that the API does the initialization of the message list on their behalf. By default, the message list will not be initialized.
 * @param p_commit Optional Standard API flag is used by API callers to ask the API to commit on their behalf after performing its function. By default, the commit will not be performed.
 * @param p_validation_level This value determines whether validation should occur or not. This variable is checked against FND_API.G_VALID_LEVEL_NONE and if it is greater than the latter, validation occurs.
 * @param x_return_status Result of all the operations performed by the API. This will have one of the following values:
 * <LI><Code>FND_API.G_RET_STS_SUCCESS</Code> - If the API processed the data successfully.
 * <LI><Code>FND_API.G_RET_STS_ERROR</Code> - If there was an expected error in API processing.
 * <LI><Code>FND_API.G_RET_STS_UNEXP_ERROR</Code> If there was an unexpected error in API processing.
 * @param x_msg_count Number of messages returned in the API message list.
 * @param x_msg_data Returned message data in an encoded format if <code>x_msg_count</code> returns non-zero value.
 * @param p_use_AOL_security AOL Security Flag, Optional Default FND_API.G_TRUE.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Delete Note
 * @rep:metalink 249665.1 Oracle Common Application Calendar - API Reference Guide
 * @rep:category BUSINESS_ENTITY CS_SERVICE_REQUEST
 * @rep:category BUSINESS_ENTITY AS_OPPORTUNITY
 * @rep:category BUSINESS_ENTITY AMS_LEAD
 */

PROCEDURE Secure_Delete_note
-- --------------------------------------------------------------------------
-- Start of notes
--  API Name  : Delete_Note will only work when the user is granted the
--              JTF_NOTE_DELETE privilege through AOL security framework
--  Type      : Public
--  Usage     : Deletes a note record in the table JTF_NOTES_B/JTF_NOTES_TL and JTF_NOTE_CONTEXTS
--  Pre-reqs  : None
--  Parameters  :
--    p_api_version           IN    NUMBER     Required
--    p_init_msg_list         IN    VARCHAR2   Optional Default = FND_API.G_FALSE
--    p_commit                IN    VARCHAR2   Optional Default = FND_API.G_FALSE
--    p_validation_level      IN    NUMBER     Optional Default = FND_API.G_VALID_LEVEL_FULL
--    x_return_status           OUT VARCHAR2   Required
--    x_msg_count               OUT NUMBER     Required
--    x_msg_data                OUT VARCHAR2   Required
--    p_jtf_note_id           IN    NUMBER     Required Primary key of the note record
--    p_use_AOL_security      IN    VARCHAR2   Optional Default FND_API.G_TRUE
--
--  Version     : Initial version        1.0
--
--
-- End of notes
-- --------------------------------------------------------------------------
( p_api_version           IN            NUMBER
, p_init_msg_list         IN            VARCHAR2 DEFAULT 'F'
, p_commit                IN            VARCHAR2 DEFAULT 'F'
, p_validation_level      IN            NUMBER   DEFAULT 100
, x_return_status            OUT NOCOPY VARCHAR2
, x_msg_count                OUT NOCOPY NUMBER
, x_msg_data                 OUT NOCOPY VARCHAR2
, p_jtf_note_id           IN            NUMBER
, p_use_AOL_security      IN            VARCHAR2 DEFAULT 'T'
);

/*#
 * Creates a note for a given business entity while applying appropriate security policies.
 *
 * @param p_parent_note_id This parameter is Obsolete.
 * @param p_jtf_note_id Unique note identifier. It will be generated from the sequence <code>JTF_NOTES_S</code> when not passed.
 * @param p_api_version Standard API version number.
 * @param p_init_msg_list Standard API flag allows API callers to request that the API does the initialization of the message list on their behalf. By default, the message list will not be initialized.
 * @param p_commit Optional Standard API flag is used by API callers to ask the API to commit on their behalf after performing its function. By default, the commit will not be performed.
 * @param x_return_status Result of all the operations performed by the API. This will have one of the following values:
 * <LI><Code>FND_API.G_RET_STS_SUCCESS</Code> - If the API processed the data successfully.
 * <LI><Code>FND_API.G_RET_STS_ERROR</Code> - If there was an expected error in API processing.
 * <LI><Code>FND_API.G_RET_STS_UNEXP_ERROR</Code> If there was an unexpected error in API processing.
 * @param p_validation_level This value determines whether validation should occur or not. This variable is checked against FND_API.G_VALID_LEVEL_NONE and if it is greater than the latter, validation occurs.
 * @param x_msg_count Number of messages returned in the API message list.
 * @param x_msg_data Returned message data in an encoded format if <code>x_msg_count</code> returns non-zero value.
 * @param p_org_id An identifier for the organization.
 * @param p_source_object_id Dependent on parameter p_source_object_code; for example, if the source business object is a service request, this is the service request number.
 * @param p_source_object_code The source business object for the note; for example, this could be TASK if the source object is a task, or ESC if the source object is an escalated document.
 * @param p_notes The actual note text, passed from the source application.
 * @param p_notes_detail This parameter is used to store larger notes of up to 32k.
 * @param p_note_status Indicates the status of the note. Choices are:
 * <LI><Code>Private (E)</Code>
 * <LI><Code>Public  (I)</Code>
 * <LI><Code>Publish (P)</Code>
 * This value must be either E, I, or P. If it is not, an error is raised. If none is provided, I is used.
 * @param p_entered_by Identifies the Oracle Applications user who entered this record. If a valid user identifier is not provided, an error is raised.
 * @param p_entered_date The date that the record was entered. If not provided, SYSDATE is used.
 * @param x_jtf_note_id The unique note identifier. This value is the same as p_jtf_note_id.
 * @param p_last_update_date The date that this record was last updated. If not provided, SYSDATE is used.
 * @param p_last_updated_by Identifies the Oracle Applications user who last updated this record.
 * @param p_creation_date The date on which this note was first created. If not provided, SYSDATE is used.
 * @param p_created_by Identifies the Oracle Applications user who first created this record.
 * @param p_last_update_login Identifies the login session of the Oracle Applications user that last updated the note.
 * @param p_attribute1 Descriptive Flexfield Segment.
 * @param p_attribute2 Descriptive Flexfield Segment.
 * @param p_attribute3 Descriptive Flexfield Segment.
 * @param p_attribute4 Descriptive Flexfield Segment.
 * @param p_attribute5 Descriptive Flexfield Segment.
 * @param p_attribute6 Descriptive Flexfield Segment.
 * @param p_attribute7 Descriptive Flexfield Segment.
 * @param p_attribute8 Descriptive Flexfield Segment.
 * @param p_attribute9 Descriptive Flexfield Segment.
 * @param p_attribute10 Descriptive Flexfield Segment.
 * @param p_attribute11 Descriptive Flexfield Segment.
 * @param p_attribute12 Descriptive Flexfield Segment.
 * @param p_attribute13 Descriptive Flexfield Segment.
 * @param p_attribute14 Descriptive Flexfield Segment.
 * @param p_attribute15 Descriptive Flexfield Segment.
 * @param p_context This is a short description field.
 * @param p_note_type The type of note, based on the source business object; for example, this could be SR_PROBLEM, if the note concerns a service request problem. If this value is not valid, an error is raised.
 * @param p_jtf_note_contexts_tab Table of PL/SQL records used to specify the note context. For details see: Oracle Common Application Calendar - API Reference Guide.
 * @param p_use_AOL_security AOL Security Flag, Optional Default FND_API.G_TRUE.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Note
 * @rep:metalink 249665.1 Oracle Common Application Calendar - API Reference Guide
 * @rep:category BUSINESS_ENTITY CS_SERVICE_REQUEST
 * @rep:category BUSINESS_ENTITY AS_OPPORTUNITY
 * @rep:category BUSINESS_ENTITY AMS_LEAD
 */

PROCEDURE Secure_Create_note
-- --------------------------------------------------------------------------
-- Start of notes
--  API Name    : Create_Note (Overloaded version with AOL security support)
--  Type        : Public
--  Description : Insert a Note into JTF_NOTES table
--  Pre-reqs    :
--  Parameters  :
--     p_parent_note_id           IN     NUMBER     Optional Default = FND_API.G_MISS_NUM
--     p_jtf_note_id              IN     NUMBER     Optional Default = FND_API.G_MISS_NUM
--     p_api_version              IN     NUMBER     Required
--     p_init_msg_list            IN     VARCHAR2   Optional Default = FND_API.G_FALSE
--     p_commit                   IN     VARCHAR2   Optional Default = FND_API.G_FALSE
--     p_validation_level         IN     NUMBER     Optional Default = FND_API.G_VALID_LEVEL_FULL
--                                                  This parameter should always be
--                                                  FND_API.G_VALID_LEVEL_FULL if the api is called from external apis
--     p_return_status               OUT VARCHAR2   Required Length  = 1
--     p_msg_count                   OUT NUMBER     Required
--     p_msg_data                    OUT VARCHAR2   Required Length  = 2000
--     p_source_object_id         IN     NUMBER     (eg  request_id for Service Request)
--     p_source_object_code       IN     VARCHAR2   (eg  INC for Service Request)
--     p_notes                    IN     VARCHAR2   Required
--     p_notes_detail             IN     VARCHAR2   Optional Default NULL
--     p_note_status              IN     VARCHAR2   Default 'I'
--     p_entered_by               IN     NUMBER     Required
--     p_entered_date             IN     DATE       Required
--     p_jtf_note_id                 OUT NUMBER     Required
--     p_last_update_date         IN     DATE       Required
--     p_last_updated_by          IN     NUMBER     Optional Default fnd_global.user_id
--     p_creation_date            IN     DATE       Required
--     p_created_by               IN     NUMBER     Optional Default fnd_global.user_id
--     p_last_update_login        IN     NUMBER     Optional Default fnd_global.login_id
--     p_attribute1               IN     VARCHAR2   Optional Default NULL
--     p_attribute2               IN     VARCHAR2   Optional Default NULL
--     p_attribute3               IN     VARCHAR2   Optional Default NULL
--     p_attribute4               IN     VARCHAR2   Optional Default NULL
--     p_attribute5               IN     VARCHAR2   Optional Default NULL
--     p_attribute6               IN     VARCHAR2   Optional Default NULL
--     p_attribute7               IN     VARCHAR2   Optional Default NULL
--     p_attribute8               IN     VARCHAR2   Optional Default NULL
--     p_attribute9               IN     VARCHAR2   Optional Default NULL
--     p_attribute10              IN     VARCHAR2   Optional Default NULL
--     p_attribute11              IN     VARCHAR2   Optional Default NULL
--     p_attribute12              IN     VARCHAR2   Optional Default NULL
--     p_attribute13              IN     VARCHAR2   Optional Default NULL
--     p_attribute14              IN     VARCHAR2   Optional Default NULL
--     p_attribute15              IN     VARCHAR2   Optional Default NULL
--     p_context                  IN     VARCHAR2   Optional Default NULL
--     p_use_AOL_security         IN     VARCHAR2   Optional Default FND_API.G_TRUE
--
--  Version     : Initial Version     1.0
--
--  Notes       :
--
-- p_note_type      IN VARCHAR2 Optional Default = NULL
--
-- Version : Revision   1.1
--
--  Notes       :
--  - Added AOL security parameter
--
-- End of notes
-- --------------------------------------------------------------------------
( p_parent_note_id        IN            NUMBER   DEFAULT 9.99E125
, p_jtf_note_id           IN            NUMBER   DEFAULT 9.99E125
, p_api_version           IN            NUMBER
, p_init_msg_list         IN            VARCHAR2 DEFAULT 'F'
, p_commit                IN            VARCHAR2 DEFAULT 'F'
, p_validation_level      IN            NUMBER   DEFAULT 100
, x_return_status            OUT NOCOPY VARCHAR2
, x_msg_count                OUT NOCOPY NUMBER
, x_msg_data                 OUT NOCOPY VARCHAR2
, p_org_id                IN            NUMBER   DEFAULT NULL
, p_source_object_id      IN            NUMBER   DEFAULT 9.99E125
, p_source_object_code    IN            VARCHAR2 DEFAULT CHR(0)
, p_notes                 IN            VARCHAR2 DEFAULT CHR(0)
, p_notes_detail          IN            VARCHAR2 DEFAULT NULL
, p_note_status           IN            VARCHAR2 DEFAULT 'I'
, p_entered_by            IN            NUMBER   DEFAULT FND_GLOBAL.USER_ID
, p_entered_date          IN            DATE     DEFAULT TO_DATE('1','j')
, x_jtf_note_id              OUT NOCOPY NUMBER
, p_last_update_date      IN            DATE     DEFAULT TO_DATE('1','j')
, p_last_updated_by       IN            NUMBER   DEFAULT FND_GLOBAL.USER_ID
, p_creation_date         IN            DATE     DEFAULT TO_DATE('1','j')
, p_created_by            IN            NUMBER   DEFAULT FND_GLOBAL.USER_ID
, p_last_update_login     IN            NUMBER   DEFAULT FND_GLOBAL.LOGIN_ID
, p_attribute1            IN            VARCHAR2 DEFAULT NULL
, p_attribute2            IN            VARCHAR2 DEFAULT NULL
, p_attribute3            IN            VARCHAR2 DEFAULT NULL
, p_attribute4            IN            VARCHAR2 DEFAULT NULL
, p_attribute5            IN            VARCHAR2 DEFAULT NULL
, p_attribute6            IN            VARCHAR2 DEFAULT NULL
, p_attribute7            IN            VARCHAR2 DEFAULT NULL
, p_attribute8            IN            VARCHAR2 DEFAULT NULL
, p_attribute9            IN            VARCHAR2 DEFAULT NULL
, p_attribute10           IN            VARCHAR2 DEFAULT NULL
, p_attribute11           IN            VARCHAR2 DEFAULT NULL
, p_attribute12           IN            VARCHAR2 DEFAULT NULL
, p_attribute13           IN            VARCHAR2 DEFAULT NULL
, p_attribute14           IN            VARCHAR2 DEFAULT NULL
, p_attribute15           IN            VARCHAR2 DEFAULT NULL
, p_context               IN            VARCHAR2 DEFAULT NULL
, p_note_type             IN            VARCHAR2 DEFAULT NULL
, p_jtf_note_contexts_tab IN            jtf_note_contexts_tbl_type
                                           DEFAULT jtf_note_contexts_tab_dflt
, p_use_AOL_security      IN            VARCHAR2 DEFAULT 'T'
);

/*#
 * Updates an existing note while applying appropriate security policies.
 *
 * @param p_jtf_note_id Unique note identifier, identifies which note record is to be updated.
 * @param p_api_version Standard API version number.
 * @param p_init_msg_list Standard API flag allows API callers to request that the API does the initialization of the message list on their behalf. By default, the message list will not be initialized.
 * @param p_commit Optional Standard API flag is used by API callers to ask the API to commit on their behalf after performing its function. By default, the commit will not be performed.
 * @param p_validation_level This value determines whether validation should occur or not. This variable is checked against FND_API.G_VALID_LEVEL_NONE and if it is greater than the latter, validation occurs.
 * @param x_return_status Result of all the operations performed by the API. This will have one of the following values:
 * <LI><Code>FND_API.G_RET_STS_SUCCESS</Code> - If the API processed the data successfully.
 * <LI><Code>FND_API.G_RET_STS_ERROR</Code> - If there was an expected error in API processing.
 * <LI><Code>FND_API.G_RET_STS_UNEXP_ERROR</Code> If there was an unexpected error in API processing.
 * @param x_msg_count Number of messages returned in the API message list.
 * @param x_msg_data Returned message data in an encoded format if <code>x_msg_count</code> returns non-zero value.
 * @param p_notes The updated note text.
 * @param p_notes_detail Used to create larger notes of up to 32K. If p_append_flag is set to Yes, then p_notes_detail is appended to p_notes.
 * @param p_note_status Indicates the status of the note. Choices are:
 * <LI><Code>Private (E)</Code>
 * <LI><Code>Public  (I)</Code>
 * <LI><Code>Publish (P)</Code>
 * This value must be either E, I, or P. If it is not, an error is raised. If none is provided, I is used.
 * @param p_entered_by Identifies the Oracle Applications user who entered this record. If a valid user identifier is not provided, an error is raised.
 * @param p_last_update_date The date that this record was last updated. If not provided, SYSDATE is used.
 * @param p_last_updated_by Identifies the Oracle Applications user who last updated this record.
 * @param p_last_update_login Identifies the login session of the Oracle Applications user that last updated the note.
 * @param p_append_flag  Boolean value: Used to specify if p_notes_detail is to be appended to the existing p_notes_detail:
 * <LI><Code>TRUE: Append p_notes_detail to p_notes_detail.</Code>
 * <LI><Code>FALSE: Do not append p_notes_detail to p_notes_detail.</Code>
 * @param p_note_type The type of note, based on the source business object; for example, this could be SR_PROBLEM, if the note concerns a service request problem. If this value is not valid, an error is raised.
 * @param p_jtf_note_contexts_tab Table of PL/SQL records used to specify the note context. For details see: Oracle Common Application Calendar - API Reference Guide.
 * @param p_attribute1 Descriptive Flexfield Segment.
 * @param p_attribute2 Descriptive Flexfield Segment.
 * @param p_attribute3 Descriptive Flexfield Segment.
 * @param p_attribute4 Descriptive Flexfield Segment.
 * @param p_attribute5 Descriptive Flexfield Segment.
 * @param p_attribute6 Descriptive Flexfield Segment.
 * @param p_attribute7 Descriptive Flexfield Segment.
 * @param p_attribute8 Descriptive Flexfield Segment.
 * @param p_attribute9 Descriptive Flexfield Segment.
 * @param p_attribute10 Descriptive Flexfield Segment.
 * @param p_attribute11 Descriptive Flexfield Segment.
 * @param p_attribute12 Descriptive Flexfield Segment.
 * @param p_attribute13 Descriptive Flexfield Segment.
 * @param p_attribute14 Descriptive Flexfield Segment.
 * @param p_attribute15 Descriptive Flexfield Segment.
 * @param p_context This is a short description field.
 * @param p_use_AOL_security AOL Security Flag.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Note
 * @rep:metalink 249665.1 Oracle Common Application Calendar - API Reference Guide
 * @rep:category BUSINESS_ENTITY CS_SERVICE_REQUEST
 * @rep:category BUSINESS_ENTITY AS_OPPORTUNITY
 * @rep:category BUSINESS_ENTITY AMS_LEAD
 */

PROCEDURE Secure_Update_note
-- --------------------------------------------------------------------------
-- Start of notes
--  API Name  : Secure_Update_Note
--  Type      : Public
--  Usage     : Updates a note record in the table JTF_NOTES
--  Pre-reqs  : None
--  Parameters  :
--    p_api_version           IN    NUMBER     Required
--    p_init_msg_list         IN    VARCHAR2   Optional Default = FND_API.G_FALSE
--    p_commit                IN    VARCHAR2   Optional Default = FND_API.G_FALSE
--    p_validation_level      IN    NUMBER     Optional Default = FND_API.G_VALID_LEVEL_FULL
--    x_return_status           OUT VARCHAR2   Required
--    x_msg_count               OUT NUMBER     Required
--    x_msg_data                OUT VARCHAR2   Required
--    p_jtf_note_id           IN    NUMBER     Required Primary key of the note record
--    p_last_updated_by       IN    NUMBER     Required Corresponds to the column USER_ID in the table FND_USER, and
--                                                      identifies the Oracle Applications user who updated this record
--    p_last_update_date      IN    DATE       Optional Date on which this record is updated
--    p_last_update_login     IN    NUMBER     Optional Corresponds to the column LOGIN_ID in the table FND_LOGINS,
--                                                      and identifies the login session of the user
--    p_notes                 IN    VARCHAR2   Optional Updated note max 2000 Characters
--    p_notes_detail          IN    VARCHAR2   Optional Updated note detail max 32Kb
--    p_append_flag           IN    VARCHAR2   Optional DEFAULT 'F'
--    p_note_status           IN    VARCHAR2   Optional Indicates the status of the note.
--                                                      Whether it is 'P'rivate/'I'Public/'P'ublish
--                                                      'I' Public is the default
--    p_attribute1            IN     VARCHAR2           DEFAULT CHR(0)
--    p_attribute2            IN     VARCHAR2           DEFAULT CHR(0)
--    p_attribute3            IN     VARCHAR2           DEFAULT CHR(0)
--    p_attribute4            IN     VARCHAR2           DEFAULT CHR(0)
--    p_attribute5            IN     VARCHAR2           DEFAULT CHR(0)
--    p_attribute6            IN     VARCHAR2           DEFAULT CHR(0)
--    p_attribute7            IN     VARCHAR2           DEFAULT CHR(0)
--    p_attribute8            IN     VARCHAR2           DEFAULT CHR(0)
--    p_attribute9            IN     VARCHAR2           DEFAULT CHR(0)
--    p_attribute10           IN     VARCHAR2           DEFAULT CHR(0)
--    p_attribute11           IN     VARCHAR2           DEFAULT CHR(0)
--    p_attribute12           IN     VARCHAR2           DEFAULT CHR(0)
--    p_attribute13           IN     VARCHAR2           DEFAULT CHR(0)
--    p_attribute14           IN     VARCHAR2           DEFAULT CHR(0)
--    p_attribute15           IN     VARCHAR2           DEFAULT CHR(0)
--    p_context               IN     VARCHAR2           DEFAULT CHR(0)
--    p_note_type             IN     VARCHAR2   Optional Type of the Note
--    p_jtf_note_contexts_tab IN    jtf_note_contexts_tbl_type
--                                             Optional Default  jtf_note_contexts_tab_dflt
--    p_use_AOL_security      IN     VARCHAR2   Optional Default FND_API.G_TRUE
--
--  Version     : Initial version        1.0
--
--  Notes       :
--  - Added AOL security parameter
--
-- End of notes
-- --------------------------------------------------------------------------
( p_api_version           IN            NUMBER
, p_init_msg_list         IN            VARCHAR2 DEFAULT 'F'
, p_commit                IN            VARCHAR2 DEFAULT 'F'
, p_validation_level      IN            NUMBER   DEFAULT 100
, x_return_status            OUT NOCOPY VARCHAR2
, x_msg_count                OUT NOCOPY NUMBER
, x_msg_data                 OUT NOCOPY VARCHAR2
, p_jtf_note_id           IN            NUMBER
, p_entered_by            IN            NUMBER   DEFAULT FND_GLOBAL.USER_ID
, p_last_updated_by       IN            NUMBER
, p_last_update_date      IN            DATE     DEFAULT SYSDATE
, p_last_update_login     IN            NUMBER   DEFAULT NULL
, p_notes                 IN            VARCHAR2 DEFAULT CHR(0)
, p_notes_detail          IN            VARCHAR2 DEFAULT CHR(0)
, p_append_flag           IN            VARCHAR2 DEFAULT CHR(0)
, p_note_status           IN            VARCHAR2 DEFAULT 'I'
, p_note_type             IN            VARCHAR2 DEFAULT CHR(0)
, p_jtf_note_contexts_tab IN            jtf_note_contexts_tbl_type
                                          DEFAULT jtf_note_contexts_tab_dflt
, p_attribute1            IN            VARCHAR2 DEFAULT CHR(0)
, p_attribute2            IN            VARCHAR2 DEFAULT CHR(0)
, p_attribute3            IN            VARCHAR2 DEFAULT CHR(0)
, p_attribute4            IN            VARCHAR2 DEFAULT CHR(0)
, p_attribute5            IN            VARCHAR2 DEFAULT CHR(0)
, p_attribute6            IN            VARCHAR2 DEFAULT CHR(0)
, p_attribute7            IN            VARCHAR2 DEFAULT CHR(0)
, p_attribute8            IN            VARCHAR2 DEFAULT CHR(0)
, p_attribute9            IN            VARCHAR2 DEFAULT CHR(0)
, p_attribute10           IN            VARCHAR2 DEFAULT CHR(0)
, p_attribute11           IN            VARCHAR2 DEFAULT CHR(0)
, p_attribute12           IN            VARCHAR2 DEFAULT CHR(0)
, p_attribute13           IN            VARCHAR2 DEFAULT CHR(0)
, p_attribute14           IN            VARCHAR2 DEFAULT CHR(0)
, p_attribute15           IN            VARCHAR2 DEFAULT CHR(0)
, p_context               IN            VARCHAR2 DEFAULT CHR(0)
, p_use_AOL_security      IN            VARCHAR2 DEFAULT 'T'
);

END JTF_NOTES_PUB;

 

/
