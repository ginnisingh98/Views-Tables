--------------------------------------------------------
--  DDL for Package AMS_ACCESS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_ACCESS_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvaccs.pls 115.25 2002/12/18 09:42:29 cgoyal ship $ */

TYPE access_rec_type IS RECORD(
  ACTIVITY_ACCESS_ID                                    NUMBER,
 LAST_UPDATE_DATE                                       DATE,
 LAST_UPDATED_BY                                        NUMBER,
 CREATION_DATE                                          DATE,
 CREATED_BY                                             NUMBER,
 LAST_UPDATE_LOGIN                                      NUMBER,
 OBJECT_VERSION_NUMBER                                  NUMBER,
 ACT_ACCESS_TO_OBJECT_ID                                NUMBER,
 ARC_ACT_ACCESS_TO_OBJECT                               VARCHAR2(30),
 USER_OR_ROLE_ID                                        NUMBER,
 ARC_USER_OR_ROLE_TYPE                                  VARCHAR2(30),
 ACTIVE_FROM_DATE                                       DATE,
 ADMIN_FLAG                                             VARCHAR2(1),
 APPROVER_FLAG                                          VARCHAR2(1),
 ACTIVE_TO_DATE                                         DATE,
 OWNER_FLAG                                             VARCHAR2(1),
 DELETE_FLAG                                            VARCHAR2(1)
  );
---------------------------------------------------------------------
-- PROCEDURE
--    create_access
--
-- PURPOSE
--    Create a new access.
--
-- PARAMETERS
--    p_access_rec: the new record to be inserted
--    x_access_id: return the access_id of the new access
--
-- NOTES
--    1. object_version_number will be set to 1.
--    2. If access_id is passed in, the uniqueness will be checked.
--       Raise exception in case of duplicates.
--    3. If access_id is not passed in, generate a unique one from
--       the sequence.
--    4. If a flag column is passed in, check if it is 'Y' or 'N'.
--       Raise exception for invalid flag.
--    5. If a flag column is not passed in, default it to 'Y' or 'N'.
--    6. Please don't pass in any FND_API.g_mess_char/num/date.
---------------------------------------------------------------------
PROCEDURE create_access(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_access_rec          IN  access_rec_type,
   x_access_id           OUT NOCOPY NUMBER
);


---------------------------------------------------------------------
-- PROCEDURE
--   check_function_security
--
-- PURPOSE
--    Check the availability of the function in the security  model
--
-- PARAMETERS
--    p_function_name: Name of the function
--    x_access_id: return the access
--
-- DESCRIPTION
--  This is the wrapper function over fnd_function.test
---------------------------------------------------------------------
FUNCTION check_function_security( p_function_name IN VARCHAR2 )
RETURN NUMBER;
--------------------------------------------------------------------
-- PROCEDURE
--    delete_access
--
-- PURPOSE
--    Delete a access.
--
-- PARAMETERS
--    p_access_id: the access_id
--    p_object_version: the object_version_number
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--------------------------------------------------------------------
PROCEDURE delete_access(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2 := FND_API.g_false,
   p_commit            IN  VARCHAR2 := FND_API.g_false,
   p_validation_level  IN  NUMBER   := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_access_id           IN  NUMBER,
   p_object_version    IN  NUMBER
);


-------------------------------------------------------------------
-- PROCEDURE
--    lock_access
--
-- PURPOSE
--    Lock a access.
--
-- PARAMETERS
--    p_access_id: the access_id
--    p_object_version: the object_version_number
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--------------------------------------------------------------------
PROCEDURE lock_access(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2 := FND_API.g_false,
   p_validation_level  IN  NUMBER   := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_access_id           IN  NUMBER,
   p_object_version    IN  NUMBER
);


---------------------------------------------------------------------
-- PROCEDURE
--    update_access
--
-- PURPOSE
--    Update a access.
--
-- PARAMETERS
--    p_access_rec: the record with new items
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--    2. If an attribute is passed in as FND_API.g_miss_char/num/date,
--       that column won't be updated.
----------------------------------------------------------------------
PROCEDURE update_access(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,
   p_access_rec        IN  access_rec_type
);


---------------------------------------------------------------------
-- PROCEDURE
--    update_object_owner
--
-- PURPOSE
--    Update a access.
--
-- PARAMETERS
--    p_access_rec: the record with new items
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--    2. If an attribute is passed in as FND_API.g_miss_char/num/date,
--       that column won't be updated.
----------------------------------------------------------------------
PROCEDURE update_object_owner(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,
   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,
   p_object_type       IN VARCHAR2,
   p_object_id         IN NUMBER,
   p_resource_id       IN NUMBER,
   p_old_resource_id   IN NUMBER
);

---------------------------------------------------------------------
-- PROCEDURE
--    validate_access
--
-- PURPOSE
--    Validate a access record.
--
-- PARAMETERS
--    p_access_rec: the access record to be validated
--
-- NOTES
--    1. p_access_rec should be the complete access record. There
--       should not be any FND_API.g_miss_char/num/date in it.
----------------------------------------------------------------------
PROCEDURE validate_access(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,
   p_access_rec        IN  access_rec_type
);

---------------------------------------------------------------------
-- FUNCTION
--    check_owner
-- PURPOSE
--    check whether the input user is the owner of the activity.
---------------------------------------------------------------------
FUNCTION check_owner(
    p_object_id         IN  NUMBER,
    p_object_type       IN  VARCHAR2,
    p_user_or_role_id   IN  NUMBER,
    p_user_or_role_type IN  VARCHAR2
)
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(check_owner, WNDS);
---------------------------------------------------------------------
-- PROCEDURE
--    check_update_access
--
-- PURPOSE
--    return the access of a user or a group
--     F : FULL: User can update sensitive metric data
--     R : RESTRICTED : User can only update data other than sensitive metric data
--     N : NULL : User is not in the access list
-- PARAMETERS
--    p_access_rec: the access record to be validated
--    Only following PARAM are req.
--    p_access_rec.act_access_to_object_id ,
--    p_access_rec.arc_act_access_to_object ,
--    p_access_rec.user_or_role_id ,
--    p_access_rec.arc_user_or_role_type
--
--
----------------------------------------------------------------------
FUNCTION check_update_access(
    p_object_id         IN  NUMBER,
    p_object_type       IN  VARCHAR2,
    p_user_or_role_id   IN  NUMBER,
    p_user_or_role_type IN  VARCHAR2
)
RETURN  VARCHAR2;


---------------------------------------------------------------------
-- PROCEDURE
--    check_view_access
--
-- PURPOSE
--    return the access of a user or a group
--     Y : User can view the object i.e CAMP, EVEN or DELIV
--     N : User cannot view the object i.e CAMP, EVEN or DELIV

-- PARAMETERS
--    p_access_rec: the access record to be validated
--    Only following PARAM are req.
--    p_access_rec.act_access_to_object_id ,
--    p_access_rec.arc_act_access_to_object ,
--    p_access_rec.user_or_role_id ,
--    p_access_rec.arc_user_or_role_type
-- NOTES
----------------------------------------------------------------------
FUNCTION check_view_access(
    p_object_id         IN  NUMBER,
    p_object_type       IN  VARCHAR2,
    p_user_or_role_id   IN  NUMBER,
    p_user_or_role_type IN  VARCHAR2
)
RETURN  VARCHAR2;

PRAGMA RESTRICT_REFERENCES(check_view_access, WNDS);


FUNCTION get_source_code(
   p_object_type IN    VARCHAR2,
   p_object_id   IN    NUMBER
  )
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(get_source_code, WNDS);


---------------------------------------------------------------------
-- PROCEDURE
--    check_access_items
--
-- PURPOSE
--    Perform the item level checking including unique keys,
--    required columns, foreign keys, domain constraints.
--
-- PARAMETERS
--    p_access_rec: the record to be validated
--    p_validation_mode: JTF_PLSQL_API.g_create/g_update
---------------------------------------------------------------------
PROCEDURE check_access_items(
   p_access_rec        IN  access_rec_type,
   p_validation_mode IN  VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status   OUT NOCOPY VARCHAR2
);


---------------------------------------------------------------------
-- PROCEDURE
--    check_access_record
--
-- PURPOSE
--    Check the record level business rules.
--
-- PARAMETERS
--    p_access_rec: the record to be validated; may contain attributes
--       as FND_API.g_miss_char/num/date
--    p_complete_rec: the complete record after all "g_miss" items
--       have been replaced by current database values
---------------------------------------------------------------------
PROCEDURE check_access_record(
   p_access_rec         IN  access_rec_type,
   p_complete_rec     IN  access_rec_type := NULL,
   x_return_status    OUT NOCOPY VARCHAR2
);


---------------------------------------------------------------------
-- PROCEDURE
--    init_access_rec
--
-- PURPOSE
--    Initialize all attributes to be FND_API.g_miss_char/num/date.
---------------------------------------------------------------------
PROCEDURE init_access_rec(
   x_access_rec         OUT NOCOPY  access_rec_type
);


---------------------------------------------------------------------
-- PROCEDURE
--    complete_access_rec
--
-- PURPOSE
--    For update_access, some attributes may be passed in as
--    FND_API.g_miss_char/num/date if the user doesn't want to
--    update those attributes. This procedure will replace the
--    "g_miss" attributes with current database values.
--
-- PARAMETERS
--    p_access_rec: the record which may contain attributes as
--       FND_API.g_miss_char/num/date
--    x_complete_rec: the complete record after all "g_miss" items
--       have been replaced by current database values
---------------------------------------------------------------------
PROCEDURE complete_access_rec(
   p_access_rec       IN  access_rec_type,
   x_complete_rec   OUT NOCOPY access_rec_type
);

--=========================================================================
-- PROCEDURE
--   Check_Admin_access
-- PURPOSE
--   To give the Admin user full previledges for the security
-- PARAMETER
--   p_resource_id   ID of the person loggin in
--   output TRUE  if the resource has the admin previledges
--          FALSE if the resource doesn't have the admin previledges
-- Notes
--   Ref Bug#1387652
-- HISTORY
--=========================================================================
FUNCTION Check_Admin_access(
   p_resource_id    IN NUMBER )
RETURN BOOLEAN ;
PRAGMA RESTRICT_REFERENCES(Check_Admin_access, WNDS);
END AMS_access_PVT;

 

/
