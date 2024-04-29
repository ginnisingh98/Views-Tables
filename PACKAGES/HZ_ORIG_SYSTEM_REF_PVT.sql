--------------------------------------------------------
--  DDL for Package HZ_ORIG_SYSTEM_REF_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_ORIG_SYSTEM_REF_PVT" AUTHID CURRENT_USER AS
/*$Header: ARHMOSRS.pls 120.6 2006/05/31 12:20:51 idali noship $ */

--  SSM SST Integration and Extension Project
TYPE orig_sys_rec_type IS RECORD (
    orig_system_id			    NUMBER,
    orig_system                             VARCHAR2(30),
    orig_system_name		            VARCHAR2(80),
    description				    VARCHAR2(240),
    orig_system_type			    VARCHAR2(30),
    sst_flag				    VARCHAR2(1),
    status                                  VARCHAR2(1),
    created_by_module                       VARCHAR2(150),
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


/* This is private API and should be only called in HTML admin UI */
PROCEDURE create_orig_sys_entity_mapping(
    p_init_msg_list           	IN      	VARCHAR2 := FND_API.G_FALSE,
    p_validation_level	IN NUMBER	:= FND_API.G_VALID_LEVEL_FULL,
    p_orig_sys_entity_map_rec	IN      HZ_ORIG_SYSTEM_REF_PUB.ORIG_SYS_ENTITY_MAP_REC_TYPE,
    x_return_status   	OUT     NOCOPY	VARCHAR2,
    x_msg_count 	OUT     NOCOPY	NUMBER,
    x_msg_data	OUT     NOCOPY 	VARCHAR2
);

/* This is private API and should be only called in HTML admin UI */
PROCEDURE update_orig_sys_entity_mapping(
    p_init_msg_list           	IN      VARCHAR2 := FND_API.G_FALSE,
    p_validation_level	IN NUMBER	:= FND_API.G_VALID_LEVEL_FULL,
    p_orig_sys_entity_map_rec	IN      HZ_ORIG_SYSTEM_REF_PUB.ORIG_SYS_ENTITY_MAP_REC_TYPE,
    p_object_version_number   	IN OUT   NOCOPY NUMBER,
    x_return_status   	OUT     NOCOPY	VARCHAR2,
    x_msg_count 	OUT     NOCOPY	NUMBER,
    x_msg_data	OUT     NOCOPY 	VARCHAR2
);


PROCEDURE create_orig_system_reference(
    p_init_msg_list           	IN      	VARCHAR2 := FND_API.G_FALSE,
    p_validation_level	IN NUMBER	:= FND_API.G_VALID_LEVEL_FULL,
    p_orig_sys_reference_rec	  IN      HZ_ORIG_SYSTEM_REF_PUB.ORIG_SYS_REFERENCE_REC_TYPE,
    x_return_status   	OUT     NOCOPY	VARCHAR2,
    x_msg_count 	OUT     NOCOPY	NUMBER,
    x_msg_data	OUT     NOCOPY 	VARCHAR2
);

PROCEDURE update_orig_system_reference(
    p_init_msg_list           	IN      	VARCHAR2 := FND_API.G_FALSE,
    p_validation_level	IN NUMBER	:= FND_API.G_VALID_LEVEL_FULL,
    p_orig_sys_reference_rec       IN    HZ_ORIG_SYSTEM_REF_PUB.ORIG_SYS_REFERENCE_REC_TYPE,
    p_object_version_number   	IN OUT   NOCOPY NUMBER,
    x_return_status   	OUT     NOCOPY	VARCHAR2,
    x_msg_count 	OUT     NOCOPY	NUMBER,
    x_msg_data	OUT     NOCOPY 	VARCHAR2
);

/* only called in hz_customer_acct_merge_v2pvt, bypassed validation */
PROCEDURE create_mosr_for_merge(
    p_init_msg_list    IN   VARCHAR2 := FND_API.G_FALSE,
    p_owner_table_name IN VARCHAR2,
    p_owner_table_id   IN NUMBER,
    x_return_status   	OUT     NOCOPY	VARCHAR2,
    x_msg_count 	OUT     NOCOPY	NUMBER,
    x_msg_data	OUT     NOCOPY 	VARCHAR2
);

PROCEDURE  remap_internal_identifier(
    p_init_msg_list           	IN      	VARCHAR2 := FND_API.G_FALSE,
    p_validation_level	IN NUMBER	:= FND_API.G_VALID_LEVEL_FULL,
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

PROCEDURE get_orig_sys_reference_rec (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_orig_system_ref_id		    in number,
    x_orig_sys_reference_rec               OUT    NOCOPY HZ_ORIG_SYSTEM_REF_PUB.ORIG_SYS_REFERENCE_REC_TYPE,
    x_return_status                         OUT    NOCOPY VARCHAR2,
    x_msg_count                             OUT    NOCOPY NUMBER,
    x_msg_data                              OUT    NOCOPY VARCHAR2
);

--raji
PROCEDURE get_party_id( p_owner_table_id IN NUMBER,
                        p_owner_table_name IN VARCHAR2,
                        x_party_id OUT NOCOPY NUMBER
                       );

--This function is invoked in Request Summary, Address, relationships UI to display the Source system count
FUNCTION get_source_system_count( p_owner_table_name IN VARCHAR2,
                       p_owner_table_id IN NUMBER) return Number;


--  SSM SST Integration and Extension Project

PROCEDURE create_orig_system(
    p_init_msg_list           	IN      	VARCHAR2 := FND_API.G_FALSE,
    p_validation_level	IN NUMBER	:= FND_API.G_VALID_LEVEL_FULL,
    p_orig_sys_rec	  IN      ORIG_SYS_REC_TYPE,
    x_return_status   	OUT     NOCOPY	VARCHAR2,
    x_msg_count 	OUT     NOCOPY	NUMBER,
    x_msg_data	OUT     NOCOPY 	VARCHAR2
);

PROCEDURE update_orig_system(
    p_init_msg_list           	IN      	VARCHAR2 := FND_API.G_FALSE,
    p_validation_level	IN NUMBER	:= FND_API.G_VALID_LEVEL_FULL,
    p_orig_sys_rec       IN    ORIG_SYS_REC_TYPE,
    p_object_version_number   	IN OUT   NOCOPY NUMBER,
    x_return_status   	OUT     NOCOPY	VARCHAR2,
    x_msg_count 	OUT     NOCOPY	NUMBER,
    x_msg_data	OUT     NOCOPY 	VARCHAR2
);


END HZ_ORIG_SYSTEM_REF_PVT;

 

/
