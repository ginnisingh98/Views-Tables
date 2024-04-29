--------------------------------------------------------
--  DDL for Package HZ_MERGE_ENTITY_ATTRI_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_MERGE_ENTITY_ATTRI_PVT" AUTHID CURRENT_USER AS
/*$Header: ARHMPATS.pls 115.4 2002/11/21 21:01:25 sponnamb noship $ */



--------------------------------------
-- declaration of public procedures and functions
--------------------------------------

/* This procedure will be called in party merge concurrent program.
Entity name supported are 'HZ_ORGANIZATION_PROFILES'
and 'HZ_PERSON_PROFILES'.
*/

PROCEDURE do_profile_attribute_merge(
        p_merge_batch_id        IN      NUMBER,
        p_merge_to_party_id     IN      NUMBER,
        p_entity_name           IN	VARCHAR2,
        x_return_status         OUT NOCOPY     VARCHAR2
) ;

PROCEDURE create_merge_attributes(
        p_merge_batch_id        IN      NUMBER,
        p_merge_to_party_id     IN      NUMBER,
        p_entity_name           IN VARCHAR2,
        x_return_status         OUT NOCOPY          VARCHAR2,
        x_msg_count            	OUT NOCOPY     	NUMBER,
        x_msg_data              OUT NOCOPY     	VARCHAR2
);

/* sync up attribute values in hz_merge_entity_attributes and hz_organization/person_profiles*/
PROCEDURE sync_merge_attributes(
        p_merge_batch_id        IN      NUMBER,
        p_merge_to_party_id     IN      NUMBER,
        p_entity_name           IN VARCHAR2,
        x_return_status         OUT NOCOPY          VARCHAR2,
        x_msg_count            	OUT NOCOPY     	NUMBER,
        x_msg_data              OUT NOCOPY     	VARCHAR2
);

PROCEDURE update_merge_attribute (
	p_merge_batch_id          IN      NUMBER,
        p_merge_to_party_id       IN      NUMBER,
	p_attribute_name	  IN	  VARCHAR2,
	p_attribute_value	  IN      VARCHAR2,
	p_attribute_party_id	  IN      NUMBER,
	p_entity_name		  IN      VARCHAR2,
	px_object_version_number  IN OUT NOCOPY    NUMBER,
        x_return_status           OUT NOCOPY     VARCHAR2,
	x_msg_count               OUT NOCOPY     NUMBER,
	x_msg_data                OUT NOCOPY     VARCHAR2
);

/* This function is called in profile attribute merge UI */
function get_attri_value_meaning(p_profile_type in varchar2, p_attri_name in
varchar2, p_attri_value in varchar2) return varchar2;

END HZ_MERGE_ENTITY_ATTRI_PVT;

 

/
