--------------------------------------------------------
--  DDL for Package IBC_DATA_SECURITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBC_DATA_SECURITY_PVT" AUTHID CURRENT_USER AS
/* $Header: ibcdsecs.pls 120.1 2005/05/31 23:20:02 appldev  $ */
  /*#
   * This is the private API for OCM Data Security. These methods are
   * exposed as Java APIs in DataSecurityManager.class
   * @rep:scope private
   * @rep:product IBC
   * @rep:displayname Oracle Content Manager Data Security Private API
   * @rep:category BUSINESS_ENTITY IBC_DATA_SECURITY
   */

  /*#
   *  This procedure establishes inheritance hierarchy, it must be kept
   *  in sync with directory nodes hierarchy tree.  It creates an
   *  inheritance link between an instance (child) and its container (parent).
   *  This procedure must be called for each container (i.e. directory node)
   *  create to define a hierarchy of containment and inheritance
   *
   *  @param p_instance_object_id  ID for object definition id found in FND_OBJECTS
   *                               for this particular instance
   *  @param p_instance_pk1_value  value 1 for instance's primary key
   *  @param p_instance_pk2_value  value 2 for instance's primary key
   *  @param p_instance_pk3_value  value 3 for instance's primary key
   *  @param p_instance_pk4_value  value 4 for instance's primary key
   *  @param p_instance_pk5_value  value 5 for instance's primary key
   *  @param p_container_object_id ID for object definition id found in FND_OBJECTS
   *                               for the container
   *  @param p_container_pk1_value value 1 for container's primary key
   *  @param p_container_pk2_value value 2 for container's primary key
   *  @param p_container_pk3_value value 3 for container's primary key
   *  @param p_container_pk4_value value 4 for container's primary key
   *  @param p_container_pk5_value value 5 for container's primary key
   *  @param p_inheritance_type    type of inheritance (FOLDER, HIDDEN-FOLDER,
   *                               WORKSPACE and WSFOLDER). Currently supported
   *                               in OCM only FOLDER and HIDDEN-FOLDER.
   *  @param p_commit              Indicates whether to commit or not at the end
   *                               of procedure
   *  @param p_api_version         standard parm - API Version
   *  @param p_init_msg_list       standard parm - Initialize message list
   *  @param x_return_status       standard parm - Return Status
   *  @param x_msg_count           standard parm - Message Count
   *  @param x_msg_data            standard parm - Message Data
   *
   *  @rep:displayname establish_inheritance
   *
   */
  PROCEDURE establish_inheritance(
    p_instance_object_id     IN NUMBER
    ,p_instance_pk1_value    IN VARCHAR2
    ,p_instance_pk2_value    IN VARCHAR2 DEFAULT NULL
    ,p_instance_pk3_value    IN VARCHAR2 DEFAULT NULL
    ,p_instance_pk4_value    IN VARCHAR2 DEFAULT NULL
    ,p_instance_pk5_value    IN VARCHAR2 DEFAULT NULL
    ,p_container_object_id   IN NUMBER   DEFAULT NULL
    ,p_container_pk1_value   IN VARCHAR2 DEFAULT NULL
    ,p_container_pk2_value   IN VARCHAR2 DEFAULT NULL
    ,p_container_pk3_value   IN VARCHAR2 DEFAULT NULL
    ,p_container_pk4_value   IN VARCHAR2 DEFAULT NULL
    ,p_container_pk5_value   IN VARCHAR2 DEFAULT NULL
    ,p_inheritance_type      IN VARCHAR2
    ,p_commit                IN  VARCHAR2 DEFAULT FND_API.g_false
    ,p_api_version           IN  NUMBER   DEFAULT 1.0
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT fnd_api.g_false
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
  );

  /*#
   *  This procedure establishes inheritance hierarchy, it must be kept
   *  in sync with directory nodes hierarchy tree.  It creates an
   *  inheritance link between an instance (child) and its container (parent).
   *  This procedure must be called for each container (i.e. directory node)
   *  create to define a hierarchy of containment and inheritance.
   *  This is overloaded of establish_inheritance without inheritance type parm.
   *
   *  @param p_instance_object_id  ID for object definition id found in FND_OBJECTS
   *                               for this particular instance
   *  @param p_instance_pk1_value  value 1 for instance's primary key
   *  @param p_instance_pk2_value  value 2 for instance's primary key
   *  @param p_instance_pk3_value  value 3 for instance's primary key
   *  @param p_instance_pk4_value  value 4 for instance's primary key
   *  @param p_instance_pk5_value  value 5 for instance's primary key
   *  @param p_container_object_id ID for object definition id found in FND_OBJECTS
   *                               for the container
   *  @param p_container_pk1_value value 1 for container's primary key
   *  @param p_container_pk2_value value 2 for container's primary key
   *  @param p_container_pk3_value value 3 for container's primary key
   *  @param p_container_pk4_value value 4 for container's primary key
   *  @param p_container_pk5_value value 5 for container's primary key
   *  @param p_commit              Indicates whether to commit or not at the end
   *                               of procedure
   *  @param p_api_version         standard parm - API Version
   *  @param p_init_msg_list       standard parm - Initialize message list
   *  @param x_return_status       standard parm - Return Status
   *  @param x_msg_count           standard parm - Message Count
   *  @param x_msg_data            standard parm - Message Data
   *
   *  @rep:displayname establish_inheritance
   *
   */
  PROCEDURE establish_inheritance(
    p_instance_object_id     IN NUMBER
    ,p_instance_pk1_value    IN VARCHAR2
    ,p_instance_pk2_value    IN VARCHAR2 DEFAULT NULL
    ,p_instance_pk3_value    IN VARCHAR2 DEFAULT NULL
    ,p_instance_pk4_value    IN VARCHAR2 DEFAULT NULL
    ,p_instance_pk5_value    IN VARCHAR2 DEFAULT NULL
    ,p_container_object_id   IN NUMBER   DEFAULT NULL
    ,p_container_pk1_value   IN VARCHAR2 DEFAULT NULL
    ,p_container_pk2_value   IN VARCHAR2 DEFAULT NULL
    ,p_container_pk3_value   IN VARCHAR2 DEFAULT NULL
    ,p_container_pk4_value   IN VARCHAR2 DEFAULT NULL
    ,p_container_pk5_value   IN VARCHAR2 DEFAULT NULL
    ,p_commit                IN  VARCHAR2 DEFAULT FND_API.g_false
    ,p_api_version           IN  NUMBER   DEFAULT 1.0
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT fnd_api.g_false
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
  );

  /*#
   *  It sets inheritance type of an instance already existing in data
   *  security inheritance tree.
   *
   *  @param p_instance_object_id  ID for object definition id found in FND_OBJECTS
   *                               for this particular instance
   *  @param p_instance_pk1_value  value 1 for instance's primary key
   *  @param p_instance_pk2_value  value 2 for instance's primary key
   *  @param p_instance_pk3_value  value 3 for instance's primary key
   *  @param p_instance_pk4_value  value 4 for instance's primary key
   *  @param p_instance_pk5_value  value 5 for instance's primary key
   *  @param p_inheritance_type    type of inheritance (FOLDER, HIDDEN-FOLDER,
   *                               WORKSPACE and WSFOLDER). Currently supported
   *                               in OCM only FOLDER and HIDDEN-FOLDER.
   *  @param p_commit              Indicates whether to commit or not at the end
   *                               of procedure
   *  @param p_api_version         standard parm - API Version
   *  @param p_init_msg_list       standard parm - Initialize message list
   *  @param x_return_status       standard parm - Return Status
   *  @param x_msg_count           standard parm - Message Count
   *  @param x_msg_data            standard parm - Message Data
   *
   *  @rep:displayname set_inheritance_type
   *
   */
  PROCEDURE set_inheritance_type(
    p_instance_object_id     IN  NUMBER
    ,p_instance_pk1_value    IN  VARCHAR2
    ,p_instance_pk2_value    IN  VARCHAR2 DEFAULT NULL
    ,p_instance_pk3_value    IN  VARCHAR2 DEFAULT NULL
    ,p_instance_pk4_value    IN  VARCHAR2 DEFAULT NULL
    ,p_instance_pk5_value    IN  VARCHAR2 DEFAULT NULL
    ,p_inheritance_type      IN  VARCHAR2
    ,p_commit                IN  VARCHAR2 DEFAULT FND_API.g_false
    ,p_api_version           IN  NUMBER   DEFAULT 1.0
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT FND_API.g_false
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
  );

  /*#
   *  It removes an instance from data security inheritance tree. This procedure
   *  should be called when the directory node gets removed from the system as well,
   *  to keep inheritance information accurate.
   *
   *  @param p_instance_object_id  ID for object definition id found in FND_OBJECTS
   *                               for this particular instance
   *  @param p_instance_pk1_value  value 1 for instance's primary key
   *  @param p_instance_pk2_value  value 2 for instance's primary key
   *  @param p_instance_pk3_value  value 3 for instance's primary key
   *  @param p_instance_pk4_value  value 4 for instance's primary key
   *  @param p_instance_pk5_value  value 5 for instance's primary key
   *  @param p_commit              Indicates whether to commit or not at the end
   *                               of procedure
   *  @param p_api_version         standard parm - API Version
   *  @param p_init_msg_list       standard parm - Initialize message list
   *  @param x_return_status       standard parm - Return Status
   *  @param x_msg_count           standard parm - Message Count
   *  @param x_msg_data            standard parm - Message Data
   *
   *  @rep:displayname Remove_Instance
   *
   */
  PROCEDURE Remove_Instance(
    p_instance_object_id     IN  NUMBER
    ,p_instance_pk1_value    IN  VARCHAR2
    ,p_instance_pk2_value    IN  VARCHAR2 DEFAULT NULL
    ,p_instance_pk3_value    IN  VARCHAR2 DEFAULT NULL
    ,p_instance_pk4_value    IN  VARCHAR2 DEFAULT NULL
    ,p_instance_pk5_value    IN  VARCHAR2 DEFAULT NULL
    ,p_commit                IN  VARCHAR2 DEFAULT FND_API.g_false
    ,p_api_version           IN  NUMBER   DEFAULT 1.0
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT FND_API.g_false
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
  );


  /*#
   *  It Resets all permissions, and makes the instance to inherit
   *  all permissions from parent. This procedure gets called when
   *  in the UI the user selects "Inherit"
   *
   *  @param p_instance_object_id  ID for object definition id found in FND_OBJECTS
   *                               for this particular instance
   *  @param p_instance_pk1_value  value 1 for instance's primary key
   *  @param p_instance_pk2_value  value 2 for instance's primary key
   *  @param p_instance_pk3_value  value 3 for instance's primary key
   *  @param p_instance_pk4_value  value 4 for instance's primary key
   *  @param p_instance_pk5_value  value 5 for instance's primary key
   *  @param p_commit              Indicates whether to commit or not at the end
   *                               of procedure
   *  @param p_api_version         standard parm - API Version
   *  @param p_init_msg_list       standard parm - Initialize message list
   *  @param x_return_status       standard parm - Return Status
   *  @param x_msg_count           standard parm - Message Count
   *  @param x_msg_data            standard parm - Message Data
   *
   *  @rep:displayname reset_permissions
   *
   */
  PROCEDURE reset_permissions(
    p_instance_object_id     IN NUMBER
    ,p_instance_pk1_value    IN VARCHAR2
    ,p_instance_pk2_value    IN VARCHAR2 DEFAULT NULL
    ,p_instance_pk3_value    IN VARCHAR2 DEFAULT NULL
    ,p_instance_pk4_value    IN VARCHAR2 DEFAULT NULL
    ,p_instance_pk5_value    IN VARCHAR2 DEFAULT NULL
    ,p_commit                IN  VARCHAR2 DEFAULT FND_API.g_false
    ,p_api_version           IN  NUMBER   DEFAULT 1.0
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT fnd_api.g_false
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
  );


  /*#
   *  It breaks inheritance of an instance form its parent, and copies
   *  all permissions from container with the intention of "isolating"
   *  instance's permissions from any modification to its container's
   *  permissions.  This procedure gets called from UI when User clicks
   *  on "Override", and it is useful so even though the user doesn't
   *  make any other modification, the inheritance is already broken
   *  and can be saved as such.
   *
   *  @param p_instance_object_id  ID for object definition id found in FND_OBJECTS
   *                               for this particular instance
   *  @param p_instance_pk1_value  value 1 for instance's primary key
   *  @param p_instance_pk2_value  value 2 for instance's primary key
   *  @param p_instance_pk3_value  value 3 for instance's primary key
   *  @param p_instance_pk4_value  value 4 for instance's primary key
   *  @param p_instance_pk5_value  value 5 for instance's primary key
   *  @param p_commit              Indicates whether to commit or not at the end
   *                               of procedure
   *  @param p_api_version         standard parm - API Version
   *  @param p_init_msg_list       standard parm - Initialize message list
   *  @param x_return_status       standard parm - Return Status
   *  @param x_msg_count           standard parm - Message Count
   *  @param x_msg_data            standard parm - Message Data
   *
   *  @rep:displayname override_permissions
   *
   */
  PROCEDURE override_permissions(
    p_instance_object_id     IN NUMBER
    ,p_instance_pk1_value    IN VARCHAR2
    ,p_instance_pk2_value    IN VARCHAR2 DEFAULT NULL
    ,p_instance_pk3_value    IN VARCHAR2 DEFAULT NULL
    ,p_instance_pk4_value    IN VARCHAR2 DEFAULT NULL
    ,p_instance_pk5_value    IN VARCHAR2 DEFAULT NULL
    ,p_commit                IN  VARCHAR2 DEFAULT FND_API.g_false
    ,p_api_version           IN  NUMBER   DEFAULT 1.0
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT fnd_api.g_false
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
  );

  /*#
   *  Given the object name it returns corrsponding object id
   *  from FND_OBJECTS
   *
   *  @param p_object_name Object Name in FND_OBJECTS
   *  @return Object Id
   *
   *  @rep:displayname get_object_id
   *
   */
  FUNCTION get_object_id(
    p_object_name        IN VARCHAR2
  ) RETURN NUMBER;

  /*#
   *  Given an object id it returns the lookup type used
   *  to validate especific permissions for the object
   *  instances corresponding to such object id.
   *
   *  @param p_object_id Object Id
   *  @return permission's lookup type
   *
   *  @rep:displayname get_perms_lookup_type
   *
   */
  FUNCTION get_perms_lookup_type(
    p_object_id              IN NUMBER
  ) RETURN VARCHAR2;


  /*#
   *  Grants a permission on a particular object instance (or contained objects)
   *  to a user.
   *
   *  @param p_instance_object_id  ID for object definition id found in FND_OBJECTS
   *                               for this particular instance
   *  @param p_instance_pk1_value  value 1 for instance's primary key
   *  @param p_instance_pk2_value  value 2 for instance's primary key
   *  @param p_instance_pk3_value  value 3 for instance's primary key
   *  @param p_instance_pk4_value  value 4 for instance's primary key
   *  @param p_instance_pk5_value  value 5 for instance's primary key
   *  @param p_action              either ALLOW(permissions) or
   *                               RESTRICT (exclusions)
   *  @param p_permission_object_id Object ID of object which permission is
   *                                being granted
   *  @param p_permission_code     Permission being granted
   *  @param p_grantee_user_id     User receiving permission, If not especified it
   *                               means ANYBODY
   *  @param p_container_object_id ID for object definition id found in FND_OBJECTS
   *                               for the container
   *  @param p_container_pk1_value value 1 for container's primary key
   *  @param p_container_pk2_value value 2 for container's primary key
   *  @param p_container_pk3_value value 3 for container's primary key
   *  @param p_container_pk4_value value 4 for container's primary key
   *  @param p_container_pk5_value value 5 for container's primary key
   *  @param p_cascade_flag        Indicates if permission should be carried over
   *                               to contained objects
   *  @param p_commit              Indicates whether to commit or not at the end
   *                               of procedure
   *  @param p_api_version         standard parm - API Version
   *  @param p_init_msg_list       standard parm - Initialize message list
   *  @param x_return_status       standard parm - Return Status
   *  @param x_msg_count           standard parm - Message Count
   *  @param x_msg_data            standard parm - Message Data
   *
   *  @rep:displayname grant_permission
   *
   */
  PROCEDURE grant_permission(
    p_instance_object_id     IN NUMBER
    ,p_instance_pk1_value    IN VARCHAR2
    ,p_instance_pk2_value    IN VARCHAR2 DEFAULT NULL
    ,p_instance_pk3_value    IN VARCHAR2 DEFAULT NULL
    ,p_instance_pk4_value    IN VARCHAR2 DEFAULT NULL
    ,p_instance_pk5_value    IN VARCHAR2 DEFAULT NULL
    ,p_action                IN VARCHAR2
    ,p_permission_object_id  IN NUMBER
    ,p_permission_code       IN VARCHAR2
    ,p_grantee_user_id       IN NUMBER
    ,p_container_object_id   IN NUMBER   DEFAULT NULL
    ,p_container_pk1_value   IN VARCHAR2 DEFAULT NULL
    ,p_container_pk2_value   IN VARCHAR2 DEFAULT NULL
    ,p_container_pk3_value   IN VARCHAR2 DEFAULT NULL
    ,p_container_pk4_value   IN VARCHAR2 DEFAULT NULL
    ,p_container_pk5_value   IN VARCHAR2 DEFAULT NULL
    ,p_cascade_flag          IN VARCHAR2 DEFAULT FND_API.g_false
    ,p_commit                IN  VARCHAR2 DEFAULT FND_API.g_false
    ,p_api_version           IN  NUMBER   DEFAULT 1.0
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT fnd_api.g_false
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
  );


  /*#
   *  Grants a permission on a particular object instance
   *  (or contained objects) to ANYBODY (if p_grantee_resource_id and
   *  type are not passed) or a particular resource.
   *
   *  @param p_instance_object_id  ID for object definition id found in FND_OBJECTS
   *                               for this particular instance
   *  @param p_instance_pk1_value  value 1 for instance's primary key
   *  @param p_instance_pk2_value  value 2 for instance's primary key
   *  @param p_instance_pk3_value  value 3 for instance's primary key
   *  @param p_instance_pk4_value  value 4 for instance's primary key
   *  @param p_instance_pk5_value  value 5 for instance's primary key
   *  @param p_action              either ALLOW(permissions) or
   *                               RESTRICT (exclusions)
   *  @param p_permission_object_id Object ID of object which permission is
   *                                being granted
   *  @param p_permission_code     Permission being granted
   *  @param p_grantee_resource_id Resource Id
   *  @param p_grantee_resource_type Resource Type. Resource receiving permission
   *                                 if not especified it means ANYBODY
   *  @param p_container_object_id ID for object definition id found in FND_OBJECTS
   *                               for the container
   *  @param p_container_pk1_value value 1 for container's primary key
   *  @param p_container_pk2_value value 2 for container's primary key
   *  @param p_container_pk3_value value 3 for container's primary key
   *  @param p_container_pk4_value value 4 for container's primary key
   *  @param p_container_pk5_value value 5 for container's primary key
   *  @param p_cascade_flag        Indicates if permission should be carried over
   *                               to contained objects
   *  @param p_commit              Indicates whether to commit or not at the end
   *                               of procedure
   *  @param p_api_version         standard parm - API Version
   *  @param p_init_msg_list       standard parm - Initialize message list
   *  @param x_return_status       standard parm - Return Status
   *  @param x_msg_count           standard parm - Message Count
   *  @param x_msg_data            standard parm - Message Data
   *
   *  @rep:displayname grant_permission
   *
   */
  PROCEDURE grant_permission(
    p_instance_object_id     IN NUMBER
    ,p_instance_pk1_value    IN VARCHAR2
    ,p_instance_pk2_value    IN VARCHAR2 DEFAULT NULL
    ,p_instance_pk3_value    IN VARCHAR2 DEFAULT NULL
    ,p_instance_pk4_value    IN VARCHAR2 DEFAULT NULL
    ,p_instance_pk5_value    IN VARCHAR2 DEFAULT NULL
    ,p_action                IN VARCHAR2
    ,p_permission_object_id  IN NUMBER
    ,p_permission_code       IN VARCHAR2
    ,p_grantee_resource_id   IN NUMBER   DEFAULT NULL
    ,p_grantee_resource_type IN VARCHAR2 DEFAULT NULL
    ,p_container_object_id   IN NUMBER   DEFAULT NULL
    ,p_container_pk1_value   IN VARCHAR2 DEFAULT NULL
    ,p_container_pk2_value   IN VARCHAR2 DEFAULT NULL
    ,p_container_pk3_value   IN VARCHAR2 DEFAULT NULL
    ,p_container_pk4_value   IN VARCHAR2 DEFAULT NULL
    ,p_container_pk5_value   IN VARCHAR2 DEFAULT NULL
    ,p_cascade_flag          IN VARCHAR2 DEFAULT FND_API.g_false
    ,p_commit                IN  VARCHAR2 DEFAULT FND_API.g_false
    ,p_api_version           IN  NUMBER   DEFAULT 1.0
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT fnd_api.g_false
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
  );


  /*#
   *  Revokes a especific permission already given, do not confuse this
   *  with a grant to RESTRICT a permission.
   *
   *  @param p_instance_object_id  ID for object definition id found in FND_OBJECTS
   *                               for this particular instance
   *  @param p_instance_pk1_value  value 1 for instance's primary key
   *  @param p_instance_pk2_value  value 2 for instance's primary key
   *  @param p_instance_pk3_value  value 3 for instance's primary key
   *  @param p_instance_pk4_value  value 4 for instance's primary key
   *  @param p_instance_pk5_value  value 5 for instance's primary key
   *  @param p_action              either ALLOW(permissions) or
   *                               RESTRICT (exclusions)
   *  @param p_permission_object_id Object ID of object to which permission was granted
   *  @param p_permission_code     Permission code
   *  @param p_grantee_user_id     User to which permission was originally granted,
   *                               if not especified it means ANYBODY
   *  @param p_commit              Indicates whether to commit or not at the end
   *                               of procedure
   *  @param p_api_version         standard parm - API Version
   *  @param p_init_msg_list       standard parm - Initialize message list
   *  @param x_return_status       standard parm - Return Status
   *  @param x_msg_count           standard parm - Message Count
   *  @param x_msg_data            standard parm - Message Data
   *
   *  @rep:displayname revoke_permission
   *
   */
  PROCEDURE revoke_permission(
    p_instance_object_id     IN NUMBER
    ,p_instance_pk1_value    IN VARCHAR2
    ,p_instance_pk2_value    IN VARCHAR2 DEFAULT NULL
    ,p_instance_pk3_value    IN VARCHAR2 DEFAULT NULL
    ,p_instance_pk4_value    IN VARCHAR2 DEFAULT NULL
    ,p_instance_pk5_value    IN VARCHAR2 DEFAULT NULL
    ,p_action                IN VARCHAR2
    ,p_permission_object_id  IN NUMBER
    ,p_permission_code       IN VARCHAR2
    ,p_grantee_user_id       IN NUMBER
    ,p_commit                IN  VARCHAR2 DEFAULT FND_API.g_false
    ,p_api_version           IN  NUMBER   DEFAULT 1.0
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT fnd_api.g_false
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
  );

  /*#
   *  Revokes a especific permission already given, do not confuse this
   *  with a grant to RESTRICT a permission.
   *
   *  @param p_instance_object_id  ID for object definition id found in FND_OBJECTS
   *                               for this particular instance
   *  @param p_instance_pk1_value  value 1 for instance's primary key
   *  @param p_instance_pk2_value  value 2 for instance's primary key
   *  @param p_instance_pk3_value  value 3 for instance's primary key
   *  @param p_instance_pk4_value  value 4 for instance's primary key
   *  @param p_instance_pk5_value  value 5 for instance's primary key
   *  @param p_action              either ALLOW(permissions) or
   *                               RESTRICT (exclusions)
   *  @param p_permission_object_id Object ID of object to which permission was granted
   *  @param p_permission_code     Permission code
   *  @param p_grantee_resource_id Resource to which permission was originally
   *                               granted, if not especified it means ANYBODY
   *  @param p_grantee_resource_type Resource Type
   *  @param p_commit              Indicates whether to commit or not at the end
   *                               of procedure
   *  @param p_api_version         standard parm - API Version
   *  @param p_init_msg_list       standard parm - Initialize message list
   *  @param x_return_status       standard parm - Return Status
   *  @param x_msg_count           standard parm - Message Count
   *  @param x_msg_data            standard parm - Message Data
   *
   *  @rep:displayname revoke_permission
   *
   */
  PROCEDURE revoke_permission(
    p_instance_object_id     IN NUMBER
    ,p_instance_pk1_value    IN VARCHAR2
    ,p_instance_pk2_value    IN VARCHAR2 DEFAULT NULL
    ,p_instance_pk3_value    IN VARCHAR2 DEFAULT NULL
    ,p_instance_pk4_value    IN VARCHAR2 DEFAULT NULL
    ,p_instance_pk5_value    IN VARCHAR2 DEFAULT NULL
    ,p_action                IN VARCHAR2
    ,p_permission_object_id  IN NUMBER
    ,p_permission_code       IN VARCHAR2
    ,p_grantee_resource_id   IN NUMBER   DEFAULT NULL
    ,p_grantee_resource_type IN VARCHAR2 DEFAULT NULL
    ,p_commit                IN  VARCHAR2 DEFAULT FND_API.g_false
    ,p_api_version           IN  NUMBER   DEFAULT 1.0
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT fnd_api.g_false
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
  );


  /*#
   *  Checks whether an user has a particular permission on an
   *  object instance
   *
   *  @param p_instance_object_id  ID for object definition id found in FND_OBJECTS
   *                               for this particular instance
   *  @param p_instance_pk1_value  value 1 for instance's primary key
   *  @param p_instance_pk2_value  value 2 for instance's primary key
   *  @param p_instance_pk3_value  value 3 for instance's primary key
   *  @param p_instance_pk4_value  value 4 for instance's primary key
   *  @param p_instance_pk5_value  value 5 for instance's primary key
   *  @param p_permission_code     Permission Code
   *  @param p_container_pk1_value value 1 for container's primary key
   *  @param p_container_pk2_value value 2 for container's primary key
   *  @param p_container_pk3_value value 3 for container's primary key
   *  @param p_container_pk4_value value 4 for container's primary key
   *  @param p_container_pk5_value value 5 for container's primary key
   *  @param p_current_user_id     Current User Id
   *  @return Whether user has (FND_API.g_true) or not (FND_API.g_false) such
   *          permission
   *
   *  @rep:displayname has_permission
   *
   */
  FUNCTION has_permission(
    p_instance_object_id     IN NUMBER
    ,p_instance_pk1_value    IN VARCHAR2
    ,p_instance_pk2_value    IN VARCHAR2 DEFAULT NULL
    ,p_instance_pk3_value    IN VARCHAR2 DEFAULT NULL
    ,p_instance_pk4_value    IN VARCHAR2 DEFAULT NULL
    ,p_instance_pk5_value    IN VARCHAR2 DEFAULT NULL
    ,p_permission_code       IN VARCHAR2
    ,p_container_object_id   IN NUMBER   DEFAULT NULL
    ,p_container_pk1_value   IN VARCHAR2 DEFAULT NULL
    ,p_container_pk2_value   IN VARCHAR2 DEFAULT NULL
    ,p_container_pk3_value   IN VARCHAR2 DEFAULT NULL
    ,p_container_pk4_value   IN VARCHAR2 DEFAULT NULL
    ,p_container_pk5_value   IN VARCHAR2 DEFAULT NULL
    ,p_current_user_id       IN NUMBER   DEFAULT NULL
  ) RETURN VARCHAR2;

  PRAGMA RESTRICT_REFERENCES(has_permission, WNDS, WNPS, TRUST);

  /*#
   *  Returns the list of permissions a user has on an object instance
   *  as a string (comma separated and bracket delimited)
   *
   *  @param p_instance_object_id  ID for object definition id found in FND_OBJECTS
   *                               for this particular instance
   *  @param p_instance_pk1_value  value 1 for instance's primary key
   *  @param p_instance_pk2_value  value 2 for instance's primary key
   *  @param p_instance_pk3_value  value 3 for instance's primary key
   *  @param p_instance_pk4_value  value 4 for instance's primary key
   *  @param p_instance_pk5_value  value 5 for instance's primary key
   *  @param p_container_object_id ID for container. Found in FND_OBJECTS
   *  @param p_container_pk1_value value 1 for container's primary key
   *  @param p_container_pk2_value value 2 for container's primary key
   *  @param p_container_pk3_value value 3 for container's primary key
   *  @param p_container_pk4_value value 4 for container's primary key
   *  @param p_container_pk5_value value 5 for container's primary key
   *  @param p_current_user_id     Current User Id
   *
   *  @rep:displayname get_permissions_as_string
   *
   */
    FUNCTION get_permissions_as_string(
    p_instance_object_id     IN NUMBER
    ,p_instance_pk1_value    IN VARCHAR2
    ,p_instance_pk2_value    IN VARCHAR2 DEFAULT NULL
    ,p_instance_pk3_value    IN VARCHAR2 DEFAULT NULL
    ,p_instance_pk4_value    IN VARCHAR2 DEFAULT NULL
    ,p_instance_pk5_value    IN VARCHAR2 DEFAULT NULL
    ,p_container_object_id   IN NUMBER   DEFAULT NULL
    ,p_container_pk1_value   IN VARCHAR2 DEFAULT NULL
    ,p_container_pk2_value   IN VARCHAR2 DEFAULT NULL
    ,p_container_pk3_value   IN VARCHAR2 DEFAULT NULL
    ,p_container_pk4_value   IN VARCHAR2 DEFAULT NULL
    ,p_container_pk5_value   IN VARCHAR2 DEFAULT NULL
    ,p_current_user_id       IN NUMBER   DEFAULT NULL
  ) RETURN VARCHAR2;

  PRAGMA RESTRICT_REFERENCES(get_permissions_as_string, WNDS, WNPS, TRUST);

  /*#
   *  Returns the list of permissions a user has on an object instance
   *
   *  @param p_instance_object_id  ID for object definition id found in FND_OBJECTS
   *                               for this particular instance
   *  @param p_instance_pk1_value  value 1 for instance's primary key
   *  @param p_instance_pk2_value  value 2 for instance's primary key
   *  @param p_instance_pk3_value  value 3 for instance's primary key
   *  @param p_instance_pk4_value  value 4 for instance's primary key
   *  @param p_instance_pk5_value  value 5 for instance's primary key
   *  @param p_container_object_id ID for container. Found in FND_OBJECTS
   *  @param p_container_pk1_value value 1 for container's primary key
   *  @param p_container_pk2_value value 2 for container's primary key
   *  @param p_container_pk3_value value 3 for container's primary key
   *  @param p_container_pk4_value value 4 for container's primary key
   *  @param p_container_pk5_value value 5 for container's primary key
   *  @param p_current_user_id     Current User Id
   *  @param x_permission_tbl      Output pl/sql table containing all
   *                               different permission codes.
   *  @param p_api_version         standard parm - API Version
   *  @param p_init_msg_list       standard parm - Initialize message list
   *  @param x_return_status       standard parm - Return Status
   *  @param x_msg_count           standard parm - Message Count
   *  @param x_msg_data            standard parm - Message Data
   *
   *  @rep:displayname get_permissions
   *
   */
  PROCEDURE get_permissions(
    p_instance_object_id     IN NUMBER
    ,p_instance_pk1_value    IN VARCHAR2
    ,p_instance_pk2_value    IN VARCHAR2 DEFAULT NULL
    ,p_instance_pk3_value    IN VARCHAR2 DEFAULT NULL
    ,p_instance_pk4_value    IN VARCHAR2 DEFAULT NULL
    ,p_instance_pk5_value    IN VARCHAR2 DEFAULT NULL
    ,p_container_object_id   IN NUMBER   DEFAULT NULL
    ,p_container_pk1_value   IN VARCHAR2 DEFAULT NULL
    ,p_container_pk2_value   IN VARCHAR2 DEFAULT NULL
    ,p_container_pk3_value   IN VARCHAR2 DEFAULT NULL
    ,p_container_pk4_value   IN VARCHAR2 DEFAULT NULL
    ,p_container_pk5_value   IN VARCHAR2 DEFAULT NULL
    ,p_current_user_id       IN NUMBER   DEFAULT NULL
    ,x_permission_tbl        OUT NOCOPY jtf_varchar2_table_100
    ,p_api_version           IN  NUMBER   DEFAULT 1.0
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT fnd_api.g_false
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
  );

  /*#
   *  Procedure to obtain a list of users which has a particular
   *  permission on a object's instance. The result is returned comma
   *  separated.
   *
   *  @param p_instance_object_id  ID for object definition id found in FND_OBJECTS
   *                               for this particular instance
   *  @param p_instance_pk1_value  value 1 for instance's primary key
   *  @param p_instance_pk2_value  value 2 for instance's primary key
   *  @param p_instance_pk3_value  value 3 for instance's primary key
   *  @param p_instance_pk4_value  value 4 for instance's primary key
   *  @param p_instance_pk5_value  value 5 for instance's primary key
   *  @param p_permission_code     Permission Code
   *  @param p_container_pk1_value value 1 for container's primary key
   *  @param p_container_pk2_value value 2 for container's primary key
   *  @param p_container_pk3_value value 3 for container's primary key
   *  @param p_container_pk4_value value 4 for container's primary key
   *  @param p_container_pk5_value value 5 for container's primary key
   *  @param p_include_global      whether to include "global" user in the list
   *  @param p_global_value        Value to be used as "global" user, by default
   *                               it is 'All'.
   *  @param x_usernames           Output string containing all users with
   *                               permission on object's instance
   *  @param p_api_version         standard parm - API Version
   *  @param p_init_msg_list       standard parm - Initialize message list
   *  @param x_return_status       standard parm - Return Status
   *  @param x_msg_count           standard parm - Message Count
   *  @param x_msg_data            standard parm - Message Data
   *
   *  @rep:displayname get_grantee_usernames
   *
   */
  PROCEDURE get_grantee_usernames(
    p_instance_object_id     IN NUMBER
    ,p_instance_pk1_value    IN VARCHAR2
    ,p_instance_pk2_value    IN VARCHAR2 DEFAULT NULL
    ,p_instance_pk3_value    IN VARCHAR2 DEFAULT NULL
    ,p_instance_pk4_value    IN VARCHAR2 DEFAULT NULL
    ,p_instance_pk5_value    IN VARCHAR2 DEFAULT NULL
    ,p_permission_code       IN VARCHAR2
    ,p_container_object_id   IN NUMBER   DEFAULT NULL
    ,p_container_pk1_value   IN VARCHAR2 DEFAULT NULL
    ,p_container_pk2_value   IN VARCHAR2 DEFAULT NULL
    ,p_container_pk3_value   IN VARCHAR2 DEFAULT NULL
    ,p_container_pk4_value   IN VARCHAR2 DEFAULT NULL
    ,p_container_pk5_value   IN VARCHAR2 DEFAULT NULL
    ,p_include_global        IN  VARCHAR2 DEFAULT fnd_api.g_false
    ,p_global_value          IN  VARCHAR2 DEFAULT 'All'
    ,x_usernames             OUT NOCOPY VARCHAR2
    ,p_api_version           IN  NUMBER   DEFAULT 1.0
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT fnd_api.g_false
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
  );

  /*#
   *  returns the list of grantee user ids who have a specific permission
   *  on a given object instance.  This doesn't include permissions given
   *  to everybody (no grantee in particular) nor "RESTRICT" grants.
   *
   *  @param p_instance_object_id  ID for object definition id found in FND_OBJECTS
   *                               for this particular instance
   *  @param p_instance_pk1_value  value 1 for instance's primary key
   *  @param p_instance_pk2_value  value 2 for instance's primary key
   *  @param p_instance_pk3_value  value 3 for instance's primary key
   *  @param p_instance_pk4_value  value 4 for instance's primary key
   *  @param p_instance_pk5_value  value 5 for instance's primary key
   *  @param p_permission_code     Permission Code
   *  @param p_container_pk1_value value 1 for container's primary key
   *  @param p_container_pk2_value value 2 for container's primary key
   *  @param p_container_pk3_value value 3 for container's primary key
   *  @param p_container_pk4_value value 4 for container's primary key
   *  @param p_container_pk5_value value 5 for container's primary key
   *  @param x_userids             Output table containing all users with
   *                               permission on object's instance
   *  @param p_api_version         standard parm - API Version
   *  @param p_init_msg_list        standard parm - Initialize message list
   *  @param x_return_status       standard parm - Return Status
   *  @param x_msg_count           standard parm - Message Count
   *  @param x_msg_data            standard parm - Message Data
   *
   *  @rep:displayname get_grantee_userids
   *
   */
  PROCEDURE get_grantee_userids(
    p_instance_object_id     IN NUMBER
    ,p_instance_pk1_value    IN VARCHAR2
    ,p_instance_pk2_value    IN VARCHAR2 DEFAULT NULL
    ,p_instance_pk3_value    IN VARCHAR2 DEFAULT NULL
    ,p_instance_pk4_value    IN VARCHAR2 DEFAULT NULL
    ,p_instance_pk5_value    IN VARCHAR2 DEFAULT NULL
    ,p_permission_code       IN VARCHAR2
    ,p_container_object_id   IN NUMBER   DEFAULT NULL
    ,p_container_pk1_value   IN VARCHAR2 DEFAULT NULL
    ,p_container_pk2_value   IN VARCHAR2 DEFAULT NULL
    ,p_container_pk3_value   IN VARCHAR2 DEFAULT NULL
    ,p_container_pk4_value   IN VARCHAR2 DEFAULT NULL
    ,p_container_pk5_value   IN VARCHAR2 DEFAULT NULL
    ,x_userids               OUT NOCOPY JTF_NUMBER_TABLE
    ,p_api_version           IN  NUMBER   DEFAULT 1.0
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT fnd_api.g_false
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
  );

  /*#
   *  Returns information about inheritance, particularly the type of
   *  inheritance, and if in fact this instance has its own permissions
   *  or is still inheriting from parent container.
   *
   *  @param p_instance_object_id  ID for object definition id found in FND_OBJECTS
   *                               for this particular instance
   *  @param p_instance_pk1_value  value 1 for instance's primary key
   *  @param p_instance_pk2_value  value 2 for instance's primary key
   *  @param p_instance_pk3_value  value 3 for instance's primary key
   *  @param p_instance_pk4_value  value 4 for instance's primary key
   *  @param p_instance_pk5_value  value 5 for instance's primary key
   *  @param p_container_object_id ID for container. Found in FND_OBJECTS
   *  @param p_container_pk1_value value 1 for container's primary key
   *  @param p_container_pk2_value value 2 for container's primary key
   *  @param p_container_pk3_value value 3 for container's primary key
   *  @param p_container_pk4_value value 4 for container's primary key
   *  @param p_container_pk5_value value 5 for container's primary key
   *  @param p_api_version         standard parm - API Version
   *  @param p_init_msg_list       standard parm - Initialize message list
   *  @param x_inherited_flag      Whether instance is inheriting (T) or Not (F)
   *  @param x_inheritance_type    Inheritance Type
   *  @param x_return_status       standard parm - Return Status
   *  @param x_msg_count           standard parm - Message Count
   *  @param x_msg_data            standard parm - Message Data
   *
   *  @rep:displayname get_inheritance_info
   *
   */
  PROCEDURE get_inheritance_info (
    p_instance_object_id     IN NUMBER
    ,p_instance_pk1_value    IN VARCHAR2
    ,p_instance_pk2_value    IN VARCHAR2
    ,p_instance_pk3_value    IN VARCHAR2
    ,p_instance_pk4_value    IN VARCHAR2
    ,p_instance_pk5_value    IN VARCHAR2
    ,p_container_object_id   IN NUMBER
    ,p_container_pk1_value   IN VARCHAR2
    ,p_container_pk2_value   IN VARCHAR2
    ,p_container_pk3_value   IN VARCHAR2
    ,p_container_pk4_value   IN VARCHAR2
    ,p_container_pk5_value   IN VARCHAR2
    ,p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2
    ,x_inherited_flag        OUT NOCOPY VARCHAR2
    ,x_inheritance_type      OUT NOCOPY VARCHAR2
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
  );

END;

 

/
