--------------------------------------------------------
--  DDL for Package HZ_PARTY_SITE_V2PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_PARTY_SITE_V2PUB" AUTHID CURRENT_USER AS
/*$Header: ARH2PSSS.pls 120.12 2006/08/17 10:14:29 idali noship $ */
/*#
 * This package includes the create and update procedures for all party site information.
 * @rep:scope public
 * @rep:product HZ
 * @rep:displayname Party Site
 * @rep:category BUSINESS_ENTITY HZ_ADDRESS
 * @rep:lifecycle active
 * @rep:doccd 120hztig.pdf Party Site APIs, Oracle Trading Community Architecture Technical Implementation Guide
 */

TYPE party_site_rec_type IS RECORD(
    party_site_id                   NUMBER,
    party_id                        NUMBER,
    location_id                     NUMBER,
    party_site_number               VARCHAR2(30),
    orig_system_reference           VARCHAR2(240),
    orig_system                     VARCHAR2(30),
    mailstop                        VARCHAR2(60),
    identifying_address_flag        VARCHAR2(1),
    status                          VARCHAR2(1),
    party_site_name                 VARCHAR2(240),
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
    language                        VARCHAR2(4),
    addressee                       VARCHAR2(150),
    created_by_module               VARCHAR2(150),
    application_id                  NUMBER,
    global_location_number          VARCHAR2(40),
    duns_number_c                   VARCHAR2(30)
);

TYPE party_site_use_rec_type IS RECORD(
    party_site_use_id               NUMBER,
    comments                        VARCHAR2(240),
    site_use_type                   VARCHAR2(30),
    party_site_id                   NUMBER,
    primary_per_type                VARCHAR2(1),
    status                          VARCHAR2(1),
    created_by_module               VARCHAR2(150),
    application_id                  NUMBER
);

-------------------------------------------------------------------------
/*#
 * Use this routine to create a party site for a party. A party site relates
 * an existing party from the HZ_PARTIES table with an address location in the
 * HZ_LOCATIONS table. This API creates a record in the HZ_PARTY_SITES table. You
 * can create multiple party sites with multiple locations and mark one of those
 * party sites as the identifying party site for that party. The identifying party site
 * address components are denormalized into the HZ_PARTIES table. If orig_system is
 * passed in, then the API also creates a record in the HZ_ORIG_SYS_REFERENCES table
 * to store the mapping between the source system reference and the TCA primary
 * key.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Party Site
 * @rep:businessevent oracle.apps.ar.hz.PartySite.create
 * @rep:doccd 120hztig.pdf Party Site APIs, Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE create_party_site (
    p_init_msg_list                 IN          VARCHAR2 := FND_API.G_FALSE,
    p_party_site_rec                IN          PARTY_SITE_REC_TYPE,
    x_party_site_id                 OUT NOCOPY         NUMBER,
    x_party_site_number             OUT NOCOPY         VARCHAR2,
    x_return_status                 OUT NOCOPY         VARCHAR2,
    x_msg_count                     OUT NOCOPY         NUMBER,
    x_msg_data                      OUT NOCOPY         VARCHAR2
);

/*#
 * Use this routine to update a party site. This API updates a record in the
 * HZ_PARTY_SITES table. You cannot change an identifying address flag to `N' to unmark
 * the party site as identifying. You must set the flag for another site to be the
 * identifying site. This makes any other party site for that party to be non-
 * identifying. The identifying party site address components are denormalized
 * into the HZ_PARTIES table. If the primary key is not passed in, then get the
 * primary key from the HZ_ORIG_SYS_REFERENCES table, based the unique and not null
 * orig_system and orig_system_reference.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Party Site
 * @rep:businessevent oracle.apps.ar.hz.PartySite.update
 * @rep:doccd 120hztig.pdf Party Site APIs, Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE update_party_site (
    p_init_msg_list                 IN          VARCHAR2 := FND_API.G_FALSE,
    p_party_site_rec                IN          PARTY_SITE_REC_TYPE,
    p_object_version_number         IN OUT NOCOPY      NUMBER,
    x_return_status                 OUT NOCOPY         VARCHAR2,
    x_msg_count                     OUT NOCOPY         NUMBER,
    x_msg_data                      OUT NOCOPY         VARCHAR2
);

/*#
 * Use this routine to create a use for a party site. This API creates a record in the
 * HZ_PARTY_SITE_USES table. A party site use defines a business purpose, such as `BILL_TO'
 * or `SHIP_TO' for a party site. You can create a party site use for a party site stored
 * in the HZ_PARTY_SITES table.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Party Site Use
 * @rep:businessevent oracle.apps.ar.hz.PartySiteUse.create
 * @rep:doccd 120hztig.pdf Party Site APIs, Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE create_party_site_use (
    p_init_msg_list                 IN          VARCHAR2 := FND_API.G_FALSE,
    p_party_site_use_rec            IN          PARTY_SITE_USE_REC_TYPE,
    x_party_site_use_id             OUT NOCOPY         NUMBER,
    x_return_status                 OUT NOCOPY         VARCHAR2,
    x_msg_count                     OUT NOCOPY         NUMBER,
    x_msg_data                      OUT NOCOPY         VARCHAR2
);

/*#
 * Use this routine to update a party site use. This API updates records in
 * the HZ_PARTY_SITE_USES table.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Party Site Use
 * @rep:businessevent oracle.apps.ar.hz.PartySiteUse.update
 * @rep:doccd 120hztig.pdf Party Site APIs, Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE update_party_site_use (
    p_init_msg_list                 IN          VARCHAR2 := FND_API.G_FALSE,
    p_party_site_use_rec            IN          PARTY_SITE_USE_REC_TYPE,
    p_object_version_number         IN OUT NOCOPY      NUMBER,
    x_return_status                 OUT NOCOPY         VARCHAR2,
    x_msg_count                     OUT NOCOPY         NUMBER,
    x_msg_data                      OUT NOCOPY         VARCHAR2
);

PROCEDURE get_party_site_rec (
    p_init_msg_list                 IN          VARCHAR2 := FND_API.G_FALSE,
    p_party_site_id                 IN          NUMBER,
    x_party_site_rec                OUT         NOCOPY PARTY_SITE_REC_TYPE,
    x_return_status                 OUT NOCOPY         VARCHAR2,
    x_msg_count                     OUT NOCOPY         NUMBER,
    x_msg_data                      OUT NOCOPY         VARCHAR2
);

PROCEDURE get_party_site_use_rec (
    p_init_msg_list                 IN          VARCHAR2 := FND_API.G_FALSE,
    p_party_site_use_id             IN          NUMBER,
    x_party_site_use_rec            OUT         NOCOPY PARTY_SITE_USE_REC_TYPE,
    x_return_status                 OUT NOCOPY         VARCHAR2,
    x_msg_count                     OUT NOCOPY         NUMBER,
    x_msg_data                      OUT NOCOPY         VARCHAR2
);

END HZ_PARTY_SITE_V2PUB;

 

/
