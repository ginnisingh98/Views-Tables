--------------------------------------------------------
--  DDL for Package HZ_DSS_SETUP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_DSS_SETUP_PUB" AUTHID CURRENT_USER AS
/* $Header: ARHPDSTS.pls 115.4 2002/11/21 20:51:53 sponnamb noship $ */

--------------------------------------
-- declaration of record type
--------------------------------------

TYPE dss_entity_profile_type IS RECORD (
    entity_id			hz_dss_entities.entity_id%TYPE,
    object_id			hz_dss_entities.object_id%TYPE,
    instance_set_id		hz_dss_entities.instance_set_id%TYPE,
    parent_entity_id		hz_dss_entities.parent_entity_id%TYPE,
    status		        hz_dss_entities.status%TYPE DEFAULT 'A',
    parent_fk_column1		hz_dss_entities.parent_fk_column1%TYPE,
    parent_fk_column2		hz_dss_entities.parent_fk_column2%TYPE,
    parent_fk_column3		hz_dss_entities.parent_fk_column3%TYPE,
    parent_fk_column4		hz_dss_entities.parent_fk_column4%TYPE,
    parent_fk_column5		hz_dss_entities.parent_fk_column5%TYPE,
    group_assignment_level	hz_dss_entities.group_assignment_level%TYPE

);

TYPE dss_scheme_function_type IS RECORD (
    security_scheme_code hz_dss_scheme_functions.security_scheme_code%TYPE,
    data_operation_code  hz_dss_scheme_functions.data_operation_code%TYPE,
    function_id          hz_dss_scheme_functions.function_id%TYPE,
    status               hz_dss_scheme_functions.status%TYPE  DEFAULT 'A'
);

--------------------------------------
--------------------------------------
-- declaration of procedures
--------------------------------------
--------------------------------------


-------------------------------------
-- CREATE_ENTITY_PROFILE - Signature
-------------------------------------

PROCEDURE create_entity_profile (
-- input parameters
    p_init_msg_list		IN  VARCHAR2  DEFAULT FND_API.G_FALSE,
    p_dss_entity_profile	IN  dss_entity_profile_type,
-- output parameters
    x_entity_id			OUT NOCOPY NUMBER,
    x_return_status		OUT NOCOPY VARCHAR2,
    x_msg_count			OUT NOCOPY NUMBER,
    x_msg_data			OUT NOCOPY VARCHAR2
);


-------------------------------------
-- UPDATE_ENTITY_PROFILE - Signature
-------------------------------------
PROCEDURE update_entity_profile (
-- input parameters
  p_init_msg_list		IN  VARCHAR2  DEFAULT FND_API.G_FALSE,
  p_dss_entity_profile		IN  dss_entity_profile_type,
-- in/out parameters
  x_object_version_number	IN OUT NOCOPY NUMBER,
-- output parameters
  x_return_status		OUT NOCOPY VARCHAR2,
  x_msg_count			OUT NOCOPY NUMBER,
  x_msg_data			OUT NOCOPY VARCHAR2
);



-------------------------------------
-- CREATE_SCHEME_FUNCTION - Signature
-------------------------------------

PROCEDURE create_scheme_function (
-- input parameters
    p_init_msg_list			IN  VARCHAR2  DEFAULT FND_API.G_FALSE,
    p_dss_scheme_function		IN  dss_scheme_function_type,
-- output parameters
    x_return_status			OUT NOCOPY VARCHAR2,
    x_msg_count				OUT NOCOPY NUMBER,
    x_msg_data				OUT NOCOPY VARCHAR2
);


-------------------------------------
-- UPDATE_SCHEME_FUNCTION - Signature
-------------------------------------

PROCEDURE update_scheme_function (
-- input parameters
  p_init_msg_list          IN  VARCHAR2  DEFAULT FND_API.G_FALSE,
  p_dss_scheme_function    IN  dss_scheme_function_type,
-- in/out parameters
  x_object_version_number  IN OUT NOCOPY NUMBER,
-- output parameters
  x_return_status          OUT NOCOPY VARCHAR2,
  x_msg_count              OUT NOCOPY NUMBER,
  x_msg_data               OUT NOCOPY VARCHAR2
);



END HZ_DSS_SETUP_PUB ;

 

/
