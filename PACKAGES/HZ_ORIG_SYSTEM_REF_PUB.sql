--------------------------------------------------------
--  DDL for Package HZ_ORIG_SYSTEM_REF_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_ORIG_SYSTEM_REF_PUB" AUTHID CURRENT_USER AS
/*$Header: ARHPOSRS.pls 120.10 2006/08/17 10:18:02 idali noship $ */
/*#
 * This package contains the public APIs related to source systems.
 * @rep:scope public
 * @rep:product HZ
 * @rep:displayname Source System Management
 * @rep:category BUSINESS_ENTITY HZ_EXTERNAL_REFERENCE
 * @rep:lifecycle active
 * @rep:doccd 120hztig.pdf Source System Management APIs, Oracle Trading Community Architecture Technical Implementation Guide
 */

--------------------------------------
-- declaration of record type
--------------------------------------
TYPE orig_sys_entity_map_rec_type IS RECORD (
    orig_system                             VARCHAR2(30),
    owner_table_name                        VARCHAR2(30),
    status                                  VARCHAR2(1),
    multiple_flag                           VARCHAR2(1),
--raji
    multi_osr_flag                          VARCHAR2(1),
    created_by_module                       VARCHAR2(150),
    application_id                          NUMBER,
    attribute_category                      VARCHAR2(30),
    attribute1                              VARCHAR2(150),
    attribute2                              VARCHAR2(150),
    attribute3                              VARCHAR2(150),
    attribute4                              VARCHAR2(150),
    attribute5                              VARCHAR2(150),
    attribute6                              VARCHAR2(150),
    attribute7                              VARCHAR2(150),
    attribute8                              VARCHAR2(150),
    attribute9                              VARCHAR2(150),
    attribute10                             VARCHAR2(150),
    attribute11                             VARCHAR2(150),
    attribute12                             VARCHAR2(150),
    attribute13                             VARCHAR2(150),
    attribute14                             VARCHAR2(150),
    attribute15                             VARCHAR2(150),
    attribute16                             VARCHAR2(150),
    attribute17                             VARCHAR2(150),
    attribute18                             VARCHAR2(150),
    attribute19                             VARCHAR2(150),
    attribute20                             VARCHAR2(150)
);

TYPE orig_sys_reference_rec_type IS RECORD (
    orig_system_ref_id                      NUMBER,
    orig_system                             VARCHAR2(30),
    orig_system_reference                   VARCHAR2(255),
    owner_table_name                        VARCHAR2(30),
    owner_table_id                          NUMBER,
--raji
    party_id                                NUMBER,
    status                                  VARCHAR2(1),
    reason_code                             VARCHAR2(30),
    old_orig_system_reference                VARCHAR2(255),
    start_date_active                       DATE,
    end_date_active                         DATE,
    created_by_module                       VARCHAR2(150),
    application_id                          NUMBER,
    attribute_category                      VARCHAR2(30),
    attribute1                              VARCHAR2(150),
    attribute2                              VARCHAR2(150),
    attribute3                              VARCHAR2(150),
    attribute4                              VARCHAR2(150),
    attribute5                              VARCHAR2(150),
    attribute6                              VARCHAR2(150),
    attribute7                              VARCHAR2(150),
    attribute8                              VARCHAR2(150),
    attribute9                              VARCHAR2(150),
    attribute10                             VARCHAR2(150),
    attribute11                             VARCHAR2(150),
    attribute12                             VARCHAR2(150),
    attribute13                             VARCHAR2(150),
    attribute14                             VARCHAR2(150),
    attribute15                             VARCHAR2(150),
    attribute16                             VARCHAR2(150),
    attribute17                             VARCHAR2(150),
    attribute18                             VARCHAR2(150),
    attribute19                             VARCHAR2(150),
    attribute20                             VARCHAR2(150)
);

--------------------------------------
-- declaration of procedures and functions
--------------------------------------

PROCEDURE get_orig_sys_entity_map_rec (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_orig_system			    in varchar2,
    p_owner_table_name			    in varchar2,
    x_orig_sys_entity_map_rec               OUT    NOCOPY ORIG_SYS_ENTITY_MAP_REC_TYPE,
    x_return_status                         OUT    NOCOPY VARCHAR2,
    x_msg_count                             OUT    NOCOPY NUMBER,
    x_msg_data                              OUT    NOCOPY VARCHAR2
);

PROCEDURE get_orig_sys_reference_rec (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_orig_system_ref_id		    in number,
    x_orig_sys_reference_rec               OUT    NOCOPY ORIG_SYS_REFERENCE_REC_TYPE,
    x_return_status                         OUT    NOCOPY VARCHAR2,
    x_msg_count                             OUT    NOCOPY NUMBER,
    x_msg_data                              OUT    NOCOPY VARCHAR2
);

/*#
 * Use this routine to create a mapping between a source system reference and a TCA
 * owner_table_id.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Original System Reference
 * @rep:businessevent oracle.apps.ar.hz.origSystemRef.create
 * @rep:doccd 120hztig.pdf Source System Management APIs, Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE create_orig_system_reference(
    p_init_msg_list           	IN      	VARCHAR2 := FND_API.G_FALSE,
    p_orig_sys_reference_rec	  IN      ORIG_SYS_REFERENCE_REC_TYPE,
    x_return_status   	OUT     NOCOPY	VARCHAR2,
    x_msg_count 	OUT     NOCOPY	NUMBER,
    x_msg_data	OUT     NOCOPY 	VARCHAR2
);


/*#
 * Use this routine to re-map or update source system references.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Original System Reference
 * @rep:businessevent oracle.apps.ar.hz.origSystemRef.update
 * @rep:doccd 120hztig.pdf Source System Management APIs, Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE update_orig_system_reference(
    p_init_msg_list           	IN      	VARCHAR2 := FND_API.G_FALSE,
    p_orig_sys_reference_rec       IN      ORIG_SYS_REFERENCE_REC_TYPE,
    p_object_version_number   	IN OUT   NOCOPY NUMBER,
    x_return_status   	OUT     NOCOPY	VARCHAR2,
    x_msg_count 	OUT     NOCOPY	NUMBER,
    x_msg_data	OUT     NOCOPY 	VARCHAR2
);


/*#
 * Use this routine to re-map the owner_table_id from an existing owner table id to a
 * new owner table id for any system and to inactivate existing mapping with a reason code.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Remap Internal Identifier
 * @rep:doccd 120hztig.pdf Source System Management APIs, Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE  remap_internal_identifier(
    p_init_msg_list           	IN      	VARCHAR2 := FND_API.G_FALSE,
    p_old_owner_table_id     IN  NUMBER,
    p_new_owner_table_id     IN  NUMBER,
    p_owner_table_name  IN VARCHAR2,
    p_orig_system IN VARCHAR2,
    p_orig_system_reference IN VARCHAR2,
    p_reason_code IN VARCHAR2,
    x_return_status   	OUT     NOCOPY	VARCHAR2,
    x_msg_count 	OUT     NOCOPY	NUMBER,
    x_msg_data		OUT     NOCOPY 	VARCHAR2
);

procedure get_owner_table_id(p_orig_system in varchar2,
			p_orig_system_reference in varchar2,
			p_owner_table_name in varchar2,
			x_owner_table_id out nocopy number,
			x_return_status out nocopy varchar2);


END HZ_ORIG_SYSTEM_REF_PUB;

 

/
