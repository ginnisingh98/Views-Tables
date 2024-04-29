--------------------------------------------------------
--  DDL for Package HZ_RELATIONSHIP_V2PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_RELATIONSHIP_V2PUB" AUTHID CURRENT_USER AS
/*$Header: ARH2RESS.pls 120.10 2007/10/23 09:36:29 rgokavar ship $ */
/*#
 * This package contains the public APIs for party relationships.
 * @rep:scope public
 * @rep:product HZ
 * @rep:displayname Party Relationship
 * @rep:category BUSINESS_ENTITY HZ_ORGANIZATION
 * @rep:category BUSINESS_ENTITY HZ_PERSON
 * @rep:category BUSINESS_ENTITY HZ_PARTY
 * @rep:category BUSINESS_ENTITY HZ_RELATIONSHIP
 * @rep:lifecycle active
 * @rep:doccd 120hztig.pdf Relationship APIs, Oracle Trading Community Architecture Technical Implementation Guide
 */

G_MISS_CONTENT_SOURCE_TYPE          CONSTANT VARCHAR2(30) := 'USER_ENTERED';

TYPE relationship_rec_type IS RECORD(
    relationship_id                 NUMBER,
    subject_id                      NUMBER,
    subject_type                    VARCHAR2(30),
    subject_table_name              VARCHAR2(30),
    object_id                       NUMBER,
    object_type                     VARCHAR2(30),
    object_table_name               VARCHAR2(30),
    relationship_code               VARCHAR2(30),
    relationship_type               VARCHAR2(30),
    comments                        VARCHAR2(240),
    start_date                      DATE ,
    end_date                        DATE,
    status                          VARCHAR2(1),
    content_source_type             VARCHAR2(30) := G_MISS_CONTENT_SOURCE_TYPE,
    attribute_category              VARCHAR2(30),
    attribute1                      VARCHAR2(150),
    attribute2                      VARCHAR2(150),
    attribute3                      VARCHAR2(150),
    attribute4                      VARCHAR2(150),
    attribute5                      VARCHAR2(150),
    attribute6                      VARCHAR2(150),
    attribute7                      VARCHAR2(150),
    attribute8                      VARCHAR2(150),
    attribute9                      VARCHAR2(150),
    attribute10                     VARCHAR2(150),
    attribute11                     VARCHAR2(150),
    attribute12                     VARCHAR2(150),
    attribute13                     VARCHAR2(150),
    attribute14                     VARCHAR2(150),
    attribute15                     VARCHAR2(150),
    attribute16                     VARCHAR2(150),
    attribute17                     VARCHAR2(150),
    attribute18                     VARCHAR2(150),
    attribute19                     VARCHAR2(150),
    attribute20                     VARCHAR2(150),
    created_by_module               VARCHAR2(150),
    application_id                  NUMBER,
    party_rec                       HZ_PARTY_V2PUB.PARTY_REC_TYPE := HZ_PARTY_V2PUB.G_MISS_PARTY_REC,
    additional_information1         VARCHAR2(150),
    additional_information2         VARCHAR2(150),
    additional_information3         VARCHAR2(150),
    additional_information4         VARCHAR2(150),
    additional_information5         VARCHAR2(150),
    additional_information6         VARCHAR2(150),
    additional_information7         VARCHAR2(150),
    additional_information8         VARCHAR2(150),
    additional_information9         VARCHAR2(150),
    additional_information10        VARCHAR2(150),
    additional_information11        VARCHAR2(150),
    additional_information12        VARCHAR2(150),
    additional_information13        VARCHAR2(150),
    additional_information14        VARCHAR2(150),
    additional_information15        VARCHAR2(150),
    additional_information16        VARCHAR2(150),
    additional_information17        VARCHAR2(150),
    additional_information18        VARCHAR2(150),
    additional_information19        VARCHAR2(150),
    additional_information20        VARCHAR2(150),
    additional_information21        VARCHAR2(150),
    additional_information22        VARCHAR2(150),
    additional_information23        VARCHAR2(150),
    additional_information24        VARCHAR2(150),
    additional_information25        VARCHAR2(150),
    additional_information26        VARCHAR2(150),
    additional_information27        VARCHAR2(150),
    additional_information28        VARCHAR2(150),
    additional_information29        VARCHAR2(150),
    additional_information30        VARCHAR2(150),
    percentage_ownership            NUMBER,
    actual_content_source           VARCHAR2(30)
);

G_MISS_REL_REC                              RELATIONSHIP_REC_TYPE;

-------------------------------------------------------------------------

/*#
 * Use this routine to create a relationship between two parties or entities. This API
 * creates records in the HZ_RELATIONSHIPS table. The record defines the relationship that
 * exists between Parties of type PERSON, ORGANIZATION, and other entities that are
 * defined in the FND_OBJECT_INSTANCE_SETS table.
 * You can view relationships in either direction, because an additional relationship
 * record is created to store the reverse relationship. The relationship code,
 * relationship type, subject and object types must be a valid combination already defined
 * in the HZ_RELATIONSHIP_TYPES table. The two relationship records have the same
 * relationship_id, but you can distinguish between them by the directional_flag column.
 * If you use a hierarchical relationship type (hierarchical_flag = Y) to create a
 * relationship, then the relationship information is denormalized to the
 * HZ_HIERARCHY_NODES table with the level, effective date, and so on. The API ensures
 * that no circular relationship is created, so that all of the relationships using that
 * relationship type are hierarchical.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Relationship
 * @rep:businessevent oracle.apps.ar.hz.Relationship.create
 * @rep:doccd 120hztig.pdf Relationship APIs, Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE create_relationship (
    p_init_msg_list               IN      VARCHAR2:= FND_API.G_FALSE,
    p_relationship_rec            IN      RELATIONSHIP_REC_TYPE,
    x_relationship_id             OUT NOCOPY     NUMBER,
    x_party_id                    OUT NOCOPY     NUMBER,
    x_party_number                OUT NOCOPY     VARCHAR2,
    x_return_status               OUT NOCOPY     VARCHAR2,
    x_msg_count                   OUT NOCOPY     NUMBER,
    x_msg_data                    OUT NOCOPY     VARCHAR2,
    p_create_org_contact          IN      VARCHAR2
);

-- bug 3801870. Overloaded the procedure create_relationship to
-- support backward compatibility.
-- Bug 6521493 Annotation added
/*#
    * Use this routine to create a relationship between two parties or entities. This API
    * creates records in the HZ_RELATIONSHIPS table. The record defines the relationship that
    * exists between Parties of type PERSON, ORGANIZATION, and other entities that are
    * defined in the FND_OBJECT_INSTANCE_SETS table.
    * You can view relationships in either direction, because an additional relationship
    * record is created to store the reverse relationship. The relationship code,
    * relationship type, subject and object types must be a valid combination already defined
    * in the HZ_RELATIONSHIP_TYPES table. The two relationship records have the same
    * relationship_id, but you can distinguish between them by the directional_flag column.
    * If you use a hierarchical relationship type (hierarchical_flag = Y) to create a
    * relationship, then the relationship information is denormalized to the
    * HZ_HIERARCHY_NODES table with the level, effective date, and so on. The API ensures
    * that no circular relationship is created, so that all of the relationships using that
    * relationship type are hierarchical. This signature of API internally calls
    * overloaded API signature with p_create_org_contact parameter value as 'Y'.
    * @rep:scope public
    * @rep:lifecycle active
    * @rep:displayname Create Relationship
    * @rep:businessevent oracle.apps.ar.hz.Relationship.create
    * @rep:doccd 115hztig.pdf Relationship APIs, Oracle Trading Community Architecture Technical Implementation Guide
    */
PROCEDURE create_relationship (
    p_init_msg_list               IN      VARCHAR2:= FND_API.G_FALSE,
    p_relationship_rec            IN      RELATIONSHIP_REC_TYPE,
    x_relationship_id             OUT NOCOPY     NUMBER,
    x_party_id                    OUT NOCOPY     NUMBER,
    x_party_number                OUT NOCOPY     VARCHAR2,
    x_return_status               OUT NOCOPY     VARCHAR2,
    x_msg_count                   OUT NOCOPY     NUMBER,
    x_msg_data                    OUT NOCOPY     VARCHAR2
);


/**
 * PROCEDURE create_relationship_with_usg
 *
 * DESCRIPTION
 *     Creates relationship with party usages.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_relationship_rec             Relationship record.
 *     p_contact_party_id             Contact party Id.
 *     p_contact_party_usage_code     Contact party usage code.
 *     p_create_org_contact           Decide if we need to create org contact or not.
 *   IN/OUT:
 *   OUT:
 *     x_relationship_id              Relationship ID.
 *     x_party_id                     Relationship party Id.
 *     x_party_number                 Party number.
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                    Number of messages in message stack.
 *     x_msg_data                     Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   05-15-2005    Jianying Huang   o Created.
 *
 */

PROCEDURE create_relationship_with_usg (
    p_init_msg_list               IN     VARCHAR2:= FND_API.G_FALSE,
    p_relationship_rec            IN     RELATIONSHIP_REC_TYPE,
    p_contact_party_id            IN     NUMBER,
    p_contact_party_usage_code    IN     VARCHAR2,
    p_create_org_contact          IN     VARCHAR2 DEFAULT NULL,
    x_relationship_id             OUT    NOCOPY NUMBER,
    x_party_id                    OUT    NOCOPY NUMBER,
    x_party_number                OUT    NOCOPY VARCHAR2,
    x_return_status               OUT    NOCOPY VARCHAR2,
    x_msg_count                   OUT    NOCOPY NUMBER,
    x_msg_data                    OUT    NOCOPY VARCHAR2
);


/*#
 * Use this routine to update a relationship. Because there are forward and backward
 * records for each relationship, the API updates two records in the HZ_RELATIONSHIPS
 * table. You can also update the denormalized party record for the relationship (if it is
 * present) by passing the party's id and object version number.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Relationship
 * @rep:businessevent oracle.apps.ar.hz.Relationship.update
 * @rep:doccd 120hztig.pdf Relationship APIs, Oracle Trading Community Architecture Technical Implementation Guide
 */
 PROCEDURE update_relationship (
    p_init_msg_list               IN      VARCHAR2:= FND_API.G_FALSE,
    p_relationship_rec            IN      RELATIONSHIP_REC_TYPE,
    p_object_version_number       IN OUT NOCOPY  NUMBER,
    p_party_object_version_number IN OUT NOCOPY  NUMBER,
    x_return_status               OUT NOCOPY     VARCHAR2,
    x_msg_count                   OUT NOCOPY     NUMBER,
    x_msg_data                    OUT NOCOPY     VARCHAR2
);

PROCEDURE get_relationship_rec (
    p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
    p_relationship_id             IN      NUMBER,
    p_directional_flag            IN      VARCHAR2 := 'F',
    x_rel_rec                     OUT     NOCOPY RELATIONSHIP_REC_TYPE,
    x_return_status               OUT NOCOPY     VARCHAR2,
    x_msg_count                   OUT NOCOPY     NUMBER,
    x_msg_data                    OUT NOCOPY     VARCHAR2
);

END HZ_RELATIONSHIP_V2PUB;

/
