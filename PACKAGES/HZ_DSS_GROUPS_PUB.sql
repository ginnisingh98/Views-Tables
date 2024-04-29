--------------------------------------------------------
--  DDL for Package HZ_DSS_GROUPS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_DSS_GROUPS_PUB" AUTHID CURRENT_USER AS
/*$Header: ARHPDSSS.pls 115.4 2003/01/08 07:15:00 jypandey noship $ */

--------------------------------------
-- declaration of record types
--------------------------------------

TYPE dss_group_rec_type IS RECORD (
  dss_group_code			hz_dss_groups_b.dss_group_code%TYPE,
  order_before_group_code		hz_dss_groups_b.dss_group_code%TYPE,
  bes_enable_flag			hz_dss_groups_b.bes_enable_flag%TYPE DEFAULT 'N',
  status				hz_dss_groups_b.status%TYPE DEFAULT 'A',
  dss_group_name			hz_dss_groups_tl.dss_group_name%TYPE,
  description				hz_dss_groups_tl.description%TYPE
);


TYPE dss_secured_class_type IS RECORD (
    secured_item_id	hz_dss_criteria.secured_item_id%TYPE,
    dss_group_code	hz_dss_criteria.dss_group_code%TYPE,
    class_category	hz_class_categories.class_category%TYPE,
    class_code		hz_code_assignments.class_code%TYPE,
    status		hz_dss_criteria.status%TYPE DEFAULT 'A'
);


TYPE dss_secured_rel_type IS RECORD (
    secured_item_id      hz_dss_criteria.secured_item_id%TYPE,
    dss_group_code       hz_dss_criteria.dss_group_code%TYPE,
    relationship_type_id hz_relationship_types.relationship_type_id%TYPE,
    status		 hz_dss_criteria.status%TYPE DEFAULT 'A'
);

--Bug 2624549
TYPE dss_secured_module_type IS RECORD (
    secured_item_id             hz_dss_criteria.secured_item_id%TYPE,
    dss_group_code              hz_dss_criteria.dss_group_code%TYPE,
    created_by_module           hz_dss_criteria.owner_table_id2%TYPE,
    status                      hz_dss_criteria.status%TYPE  DEFAULT 'A'
);


TYPE dss_assignment_type IS RECORD (
    dss_group_code		hz_dss_groups_b.dss_group_code%TYPE,
    assignment_id		hz_dss_assignments.dss_group_code%TYPE,
    owner_table_name		hz_dss_assignments.owner_table_name%TYPE,
    owner_table_id1		hz_dss_assignments.owner_table_id1%TYPE,
    owner_table_id2		hz_dss_assignments.owner_table_id2%TYPE,
    owner_table_id3		hz_dss_assignments.owner_table_id3%TYPE,
    owner_table_id4		hz_dss_assignments.owner_table_id4%TYPE,
    owner_table_id5		hz_dss_assignments.owner_table_id5%TYPE,
    status			hz_dss_assignments.status%TYPE DEFAULT 'A'

);

TYPE dss_secured_entity_type IS RECORD (
    dss_group_code	hz_dss_groups_b.dss_group_code%TYPE,
    entity_id		hz_dss_entities.entity_id%TYPE,
    status		hz_dss_groups_b.status%TYPE DEFAULT 'A'
);


TYPE dss_secured_criterion_type IS RECORD (
    secured_item_id		hz_dss_criteria.secured_item_id%TYPE,
    dss_group_code		hz_dss_criteria.dss_group_code%TYPE,
    owner_table_name		hz_dss_criteria.owner_table_name%TYPE,
    owner_table_id1		hz_dss_criteria.owner_table_id1%TYPE,
    owner_table_id2		hz_dss_criteria.owner_table_id2%TYPE,
    owner_table_id3		hz_dss_criteria.owner_table_id3%TYPE,
    owner_table_id4		hz_dss_criteria.owner_table_id4%TYPE,
    owner_table_id5		hz_dss_criteria.owner_table_id5%TYPE,
    status			hz_dss_criteria.status%TYPE  DEFAULT 'A'
);




------------------------------------
-- declaration of procedures
------------------------------------

PROCEDURE create_group (
-- input parameters
    p_init_msg_list		IN  VARCHAR2  DEFAULT FND_API.G_FALSE,
    p_dss_group			IN  dss_group_rec_type,
-- output parameters
    x_return_status		OUT NOCOPY VARCHAR2,
    x_msg_count			OUT NOCOPY NUMBER,
    x_msg_data			OUT NOCOPY VARCHAR2
);

PROCEDURE update_group (
-- input parameters
    p_init_msg_list		IN  VARCHAR2  DEFAULT FND_API.G_FALSE,
    p_dss_group			IN  dss_group_rec_type,
-- in/out parameters
    x_object_version_number	IN OUT NOCOPY NUMBER,
-- output parameters
    x_return_status		OUT NOCOPY VARCHAR2,
    x_msg_count			OUT NOCOPY NUMBER,
    x_msg_data			OUT NOCOPY VARCHAR2
);


PROCEDURE create_secured_criterion (
-- input parameters
    p_init_msg_list		IN  VARCHAR2  DEFAULT FND_API.G_FALSE,
    p_dss_secured_criterion	IN  dss_secured_criterion_type,
-- output parameters
    x_secured_item_id		OUT NOCOPY NUMBER,
    x_return_status		OUT NOCOPY VARCHAR2,
    x_msg_count			OUT NOCOPY NUMBER,
    x_msg_data			OUT NOCOPY VARCHAR2
);


--Bug 2624549
PROCEDURE create_secured_module (
-- input parameters
    p_init_msg_list             IN  VARCHAR2  DEFAULT FND_API.G_FALSE,
    p_dss_secured_module        IN  dss_secured_module_type,
-- output parameters
    x_secured_item_id           OUT NOCOPY NUMBER,
    x_return_status             OUT NOCOPY VARCHAR2,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2
);

--Bug 2624549
PROCEDURE update_secured_module (
-- input parameters
    p_init_msg_list             IN  VARCHAR2  DEFAULT FND_API.G_FALSE,
    p_dss_secured_module        IN  dss_secured_module_type,
-- in/out parameters
    x_object_version_number     IN OUT NOCOPY NUMBER,
-- output parameters
    x_return_status             OUT NOCOPY VARCHAR2,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2
);


PROCEDURE create_secured_classification (
-- input parameters
    p_init_msg_list		IN  VARCHAR2  DEFAULT FND_API.G_FALSE,
    p_dss_secured_class		IN  dss_secured_class_type,
-- output parameters
    x_secured_item_id		OUT NOCOPY NUMBER,
    x_return_status		OUT NOCOPY VARCHAR2,
    x_msg_count			OUT NOCOPY NUMBER,
    x_msg_data			OUT NOCOPY VARCHAR2
);

PROCEDURE update_secured_criterion (
-- input parameters
    p_init_msg_list		IN  VARCHAR2  DEFAULT FND_API.G_FALSE,
    p_dss_secured_criterion	IN  dss_secured_criterion_type,
-- in/out parameters
    x_object_version_number	IN OUT NOCOPY NUMBER,
-- output parameters
    x_return_status		OUT NOCOPY VARCHAR2,
    x_msg_count			OUT NOCOPY NUMBER,
    x_msg_data			OUT NOCOPY VARCHAR2
);

PROCEDURE update_secured_classification (
-- input parameters
    p_init_msg_list		IN  VARCHAR2  DEFAULT FND_API.G_FALSE,
    p_dss_secured_class		IN  dss_secured_class_type,
-- in/out parameters
    x_object_version_number	IN OUT NOCOPY NUMBER,
-- output parameters
    x_return_status		OUT NOCOPY VARCHAR2,
    x_msg_count			OUT NOCOPY NUMBER,
    x_msg_data			OUT NOCOPY VARCHAR2
);


PROCEDURE create_secured_rel_type (
-- input parameters
    p_init_msg_list		IN  VARCHAR2  DEFAULT FND_API.G_FALSE,
    p_dss_secured_rel_type	IN  dss_secured_rel_type,
-- output parameters
    x_secured_item_id		OUT NOCOPY NUMBER,
    x_return_status		OUT NOCOPY VARCHAR2,
    x_msg_count			OUT NOCOPY NUMBER,
    x_msg_data			OUT NOCOPY VARCHAR2
);



PROCEDURE update_secured_rel_type (
-- input parameters
    p_init_msg_list		IN  VARCHAR2  DEFAULT FND_API.G_FALSE,
    p_dss_secured_rel_type	IN  dss_secured_rel_type,
-- in/out parameters
    x_object_version_number	IN OUT NOCOPY NUMBER,
-- output parameters
    x_return_status		OUT NOCOPY VARCHAR2,
    x_msg_count			OUT NOCOPY NUMBER,
    x_msg_data			OUT NOCOPY VARCHAR2
);


PROCEDURE create_assignment (
-- input parameters
    p_init_msg_list	IN  VARCHAR2  DEFAULT FND_API.G_FALSE,
    p_dss_assignment	IN  dss_assignment_type,
-- output parameters
    x_assignment_id	OUT NOCOPY NUMBER,
    x_return_status	OUT NOCOPY VARCHAR2,
    x_msg_count		OUT NOCOPY NUMBER,
    x_msg_data		OUT NOCOPY VARCHAR2
);


PROCEDURE delete_assignment (
-- input parameters
    p_init_msg_list	IN  VARCHAR2  DEFAULT FND_API.G_FALSE,
    p_assignment_id	IN  NUMBER,
-- output parameters
    x_return_status	OUT NOCOPY VARCHAR2,
    x_msg_count		OUT NOCOPY NUMBER,
    x_msg_data		OUT NOCOPY VARCHAR2
);


PROCEDURE create_secured_entity (
-- input parameters
    p_init_msg_list		IN  VARCHAR2  DEFAULT FND_API.G_FALSE,
    p_dss_secured_entity	IN  dss_secured_entity_type,
-- output parameters
    x_dss_instance_set_id	OUT NOCOPY NUMBER,
    x_return_status		OUT NOCOPY VARCHAR2,
    x_msg_count			OUT NOCOPY NUMBER,
    x_msg_data			OUT NOCOPY VARCHAR2
);


PROCEDURE update_secured_entity (
-- input parameters
    p_init_msg_list		IN  VARCHAR2  DEFAULT FND_API.G_FALSE,
    p_dss_secured_entity	IN  dss_secured_entity_type,
-- in/out parameters
    x_object_version_number	IN OUT NOCOPY NUMBER,
-- output parameters
    x_return_status		OUT NOCOPY VARCHAR2,
    x_msg_count			OUT NOCOPY NUMBER,
    x_msg_data			OUT NOCOPY VARCHAR2
);

END HZ_DSS_GROUPS_PUB ;

 

/
