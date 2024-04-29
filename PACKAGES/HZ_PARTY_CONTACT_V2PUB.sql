--------------------------------------------------------
--  DDL for Package HZ_PARTY_CONTACT_V2PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_PARTY_CONTACT_V2PUB" AUTHID CURRENT_USER AS
/*$Header: ARH2PCSS.pls 120.9 2006/08/17 10:12:43 idali noship $ */
/*#
 * This package includes the create and update procedures for contacts and contact roles.
 * @rep:scope public
 * @rep:product HZ
 * @rep:displayname Party Contact
 * @rep:category BUSINESS_ENTITY HZ_CONTACT
 * @rep:lifecycle active
 * @rep:doccd 120hztig.pdf Party Contact APIs, Oracle Trading Community Architecture Technical Implementation Guide
 */

TYPE org_contact_rec_type IS RECORD(
    org_contact_id                  NUMBER,
    comments                        VARCHAR2(240),
    contact_number                  VARCHAR2(30),
    department_code                 VARCHAR2(30),
    department                      VARCHAR2(60),
    title                           VARCHAR2(30),
    job_title                       VARCHAR2(100),
    decision_maker_flag             VARCHAR2(1),
    job_title_code                  VARCHAR2(30),
    reference_use_flag              VARCHAR2(1),
    rank                            VARCHAR2(30),
    party_site_id                   NUMBER,
    orig_system_reference           VARCHAR2(240),
    orig_system			    VARCHAR2(30),
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
    attribute21                     VARCHAR2(150),
    attribute22                     VARCHAR2(150),
    attribute23                     VARCHAR2(150),
    attribute24                     VARCHAR2(150),
    created_by_module               VARCHAR2(150),
    application_id                  NUMBER,
    party_rel_rec                   HZ_RELATIONSHIP_V2PUB.relationship_rec_type:= HZ_RELATIONSHIP_V2PUB.G_MISS_REL_REC
);


TYPE org_contact_role_rec_type IS RECORD(
    org_contact_role_id             NUMBER,
    role_type                       VARCHAR2(30),
    primary_flag                    VARCHAR2(1),
    org_contact_id                  NUMBER,
    orig_system_reference           VARCHAR2(240),
    orig_system			    VARCHAR2(30),
    role_level                      VARCHAR2(30),
    primary_contact_per_role_type   VARCHAR2(1),
    status                          VARCHAR2(1),
    created_by_module               VARCHAR2(150),
    application_id                  NUMBER
);

-------------------------------------------------------------------------
/*#
 * Use this routine to create a contact person for an organization or person. This API
 * creates a record in the HZ_ORG_CONTACTS table. It also creates a relationship record in
 * the HZ_RELATIONSHIPS table using the contact person as the subject, the organization or
 * person as the object, and the relationship type and code passed by the caller. At the
 * same time, the API creates a reverse relationship record. Depending on the relationship
 * type set up for the relationship being used for the organization contact, the API creates a
 * denormalized party record.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Organization Contact
 * @rep:businessevent oracle.apps.ar.hz.OrgContact.create
 * @rep:doccd 120hztig.pdf Party Contact APIs, Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE create_org_contact (
    p_init_msg_list                    IN       VARCHAR2 := FND_API.G_FALSE,
    p_org_contact_rec                  IN       ORG_CONTACT_REC_TYPE,
    x_org_contact_id                   OUT NOCOPY      NUMBER,
    x_party_rel_id                     OUT NOCOPY      NUMBER,
    x_party_id                         OUT NOCOPY      NUMBER,
    x_party_number                     OUT NOCOPY      VARCHAR2,
    x_return_status                    OUT NOCOPY      VARCHAR2,
    x_msg_count                        OUT NOCOPY      NUMBER,
    x_msg_data                         OUT NOCOPY      VARCHAR2
);

/*#
 * Use this routine to update a contact person. This API updates the contact record in the
 * HZ_ORG_CONTACTS table. Optionally, you can call this API to update the relevant
 * relationship record in the HZ_RELATIONSHIPS table and the underlying party record in the
 * HZ_PARTIES table. To perform these updates you must pass the corresponding id and object
 * version number.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Organization Contact
 * @rep:businessevent oracle.apps.ar.hz.OrgContact.update
 * @rep:doccd 120hztig.pdf Party Contact APIs, Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE update_org_contact (
    p_init_msg_list                    IN       VARCHAR2:= FND_API.G_FALSE,
    p_org_contact_rec                  IN       ORG_CONTACT_REC_TYPE,
    p_cont_object_version_number       IN OUT NOCOPY   NUMBER,
    p_rel_object_version_number        IN OUT NOCOPY   NUMBER,
    p_party_object_version_number      IN OUT NOCOPY   NUMBER,
    x_return_status                    OUT NOCOPY      VARCHAR2,
    x_msg_count                        OUT NOCOPY      NUMBER,
    x_msg_data                         OUT NOCOPY      VARCHAR2
);

/*#
 * Use this routine to create a contact role for a contact person. This API
 * creates a record in the HZ_ORG_CONTACT_ROLES table. You can create multiple
 * role records for an organization contact. For an organization contact, you can
 * identify one of the organization contact role records as Primary. There can be
 * one role record per role type. For an organization or person, among all its
 * organization contacts, you can mark one role record per role type as primary.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Organization Contact Role
 * @rep:businessevent oracle.apps.ar.hz.OrgContactRole.create
 * @rep:doccd 120hztig.pdf Party Contact APIs, Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE create_org_contact_role (
    p_init_msg_list                    IN       VARCHAR2:= FND_API.G_FALSE,
    p_org_contact_role_rec             IN       ORG_CONTACT_ROLE_REC_TYPE,
    x_org_contact_role_id              OUT NOCOPY      NUMBER,
    x_return_status                    OUT NOCOPY      VARCHAR2,
    x_msg_count                        OUT NOCOPY      NUMBER,
    x_msg_data                         OUT NOCOPY      VARCHAR2
);

/*#
 * Use this routine to update a contact role record. The API updates records in the
 * HZ_ORG_CONTACT_ROLES table.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Organization Contact Role
 * @rep:businessevent oracle.apps.ar.hz.OrgContactRole.update
 * @rep:doccd 120hztig.pdf Party Contact APIs, Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE update_org_contact_role (
    p_init_msg_list                    IN       VARCHAR2:= FND_API.G_FALSE,
    p_org_contact_role_rec             IN       ORG_CONTACT_ROLE_REC_TYPE,
    p_object_version_number            IN OUT NOCOPY   NUMBER,
    x_return_status                    OUT NOCOPY      VARCHAR2,
    x_msg_count                        OUT NOCOPY      NUMBER,
    x_msg_data                         OUT NOCOPY      VARCHAR2
);


PROCEDURE get_org_contact_rec (
    p_init_msg_list                    IN      VARCHAR2 := FND_API.G_FALSE,
    p_org_contact_id                   IN      NUMBER,
    x_org_contact_rec                  OUT     NOCOPY ORG_CONTACT_REC_TYPE,
    x_return_status                    OUT NOCOPY     VARCHAR2,
    x_msg_count                        OUT NOCOPY     NUMBER,
    x_msg_data                         OUT NOCOPY     VARCHAR2
);

PROCEDURE get_org_contact_role_rec (
    p_init_msg_list                    IN      VARCHAR2 := FND_API.G_FALSE,
    p_org_contact_role_id              IN      NUMBER,
    x_org_contact_role_rec             OUT     NOCOPY ORG_CONTACT_ROLE_REC_TYPE,
    x_return_status                    OUT NOCOPY     VARCHAR2,
    x_msg_count                        OUT NOCOPY     NUMBER,
    x_msg_data                         OUT NOCOPY     VARCHAR2
);

END HZ_PARTY_CONTACT_V2PUB;

 

/
