--------------------------------------------------------
--  DDL for Package IMC_RECENT_OBJECT_ACCESS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IMC_RECENT_OBJECT_ACCESS_PUB" AUTHID CURRENT_USER AS
/* $Header: imcroas.pls 115.7 2002/11/12 21:53:35 tsli noship $ */

TYPE ref_cursor_rec_obj_acc IS REF CURSOR;

g_module CONSTANT VARCHAR2(30) := 'IMC_RECENT_OBJECT_ACCESS';

/* Messages */
g_invalid_user_id CONSTANT VARCHAR2(30) := 'IMC_INVALID_USER_ID';
g_invalid_object_type CONSTANT VARCHAR2(30) := 'IMC_INVALID_OBJ_TYPE';
g_invalid_object_id CONSTANT VARCHAR2(30) := 'IMC_INVALID_OBJ_ID';
g_invalid_object_name CONSTANT VARCHAR2(30) := 'IMC_INVALID_OBJ_NAME';
g_recent_api_others_ex CONSTANT VARCHAR2(30) := 'IMC_RECENT_API_OTHERS_EX';
g_no_objs_recently_accessed CONSTANT VARCHAR2(30) := 'IMC_NO_OBJS_RECY_ACCD';
g_could_not_delete_entry CONSTANT VARCHAR2(30) := 'IMC_COULD_NOT_DEL_ENTRY';

/* Profiles */
-- g_maintenance_profile CONSTANT VARCHAR2(30) := 'IMC_MAINTAIN_REC_OBJ_ACC';
-- g_store_max_profile CONSTANT VARCHAR2(30) := 'IMC_MAX_STORE_REC_OBJ_ACC';
g_display_max_profile CONSTANT VARCHAR2(30) := 'IMC_MAX_DISPLAY_REC_OBJ_ACC';

/* Object types supported currently */
g_object_type_org CONSTANT VARCHAR2(30) := 'PARTY_ORGANIZATION';
g_object_type_per CONSTANT VARCHAR2(30) := 'PARTY_PERSON';
g_object_type_con CONSTANT VARCHAR2(30) := 'PARTY_CONTACT_RELATIONSHIP';

/* Default object version number */
g_object_version_number CONSTANT NUMBER := 1;

/* Profile defaults */
-- g_default_maintenance CONSTANT VARCHAR2(1) := 'Y';
-- g_default_max_store CONSTANT NUMBER := 50;
g_default_max_display CONSTANT NUMBER := 10;

---------------------------------------------------------------------------------
--
-- API name  : Add_Recently_Accessed_Object
--
-- TYPE      : Public
--
-- FUNCTION  : Add a recent object access for a user. For now, the object can be
--             an organization, a contact relationship or a person. If a record
--             already exists for this object and user on this date, do nothing.
--             Else, check profile option IMC_MAX_DISPLAY_REC_OBJ_ACC. If limit
--             is not reached, insert new record; else, update the record for
--             least recently accessed object by this user with details of the
--             new object access.
--
-- Parameters:
--
--     IN    :
--             p_user_id IN NUMBER (required)
--             User for whom the object access will be added.
--
--             p_object_type IN VARCHAR2 (required)
--             Type of Object that is going to be recorded as accessed by user.
--             Valid Values (now): PARTY_ORGANIZATION, PARTY_C0NTACT_RELATIONSHIP,
--             PARTY_PERSON.
--
--             p_object_id IN NUMBER (required)
--             Object that is going to be recorded as accessed by user.
--
--             p_object_name IN VARCHAR2 (optional)
--             User-friendly name of the object accessed by user.
--
--             p_application_id IN VARCHAR2 (optional)
--             Application recording object access by user.
--
--             p_additional_value1 IN VARCHAR2 (optional)
--             Additional value for this entry.
--
--             p_additional_value2 IN VARCHAR2 (optional)
--             Additional value for this entry.
--
--             p_additional_value3 IN VARCHAR2 (optional)
--             Additional value for this entry.
--
--             p_additional_value4 IN VARCHAR2 (optional)
--             Additional value for this entry.
--
--             p_additional_value5 IN VARCHAR2 (optional)
--             Additional value for this entry.
--
--             p_object_version_number IN NUMBER (optional)
--             Version number for concurrency control. Defaulted to 1.
--
--     OUT NOCOPY   :
--             x_return_status
--             1 byte result code:
--                'S'  Success  (FND_API.G_RET_STS_SUCCESS)
--                'E'  Error  (FND_API.G_RET_STS_ERROR)
--                'U'  Unexpected Error (FND_API.G_RET_STS_UNEXP_ERROR)
--
--             x_msg_count
--             Number of messages in message stack.
--             If 'E' or 'U' is returned, there will be an error message on the
--             FND_MESSAGE stack which can be retrieved with
--             FND_MESSAGE.GET_ENCODED().
--
--             x_msg_data
--             The first message in the FND_MESSAGE stack
--
-- Version: Current Version 1.0
-- Previous Version :  None
--
-- Notes     :
--
---------------------------------------------------------------------------------
PROCEDURE Add_Recently_Accessed_Object (
  p_user_id			IN IMC_RECENT_ACCESSED_OBJ.user_id%TYPE,
  p_object_type			IN IMC_RECENT_ACCESSED_OBJ.object_type%TYPE,
  p_object_id			IN IMC_RECENT_ACCESSED_OBJ.object_id%TYPE,
  p_object_name			IN IMC_RECENT_ACCESSED_OBJ.object_name%TYPE,
  p_application_id		IN IMC_RECENT_ACCESSED_OBJ.application_id%TYPE,
  p_additional_value1		IN IMC_RECENT_ACCESSED_OBJ.additional_value1%TYPE,
  p_additional_value2		IN IMC_RECENT_ACCESSED_OBJ.additional_value2%TYPE,
  p_additional_value3		IN IMC_RECENT_ACCESSED_OBJ.additional_value3%TYPE,
  p_additional_value4		IN IMC_RECENT_ACCESSED_OBJ.additional_value4%TYPE,
  p_additional_value5		IN IMC_RECENT_ACCESSED_OBJ.additional_value5%TYPE,
  p_object_version_number	IN IMC_RECENT_ACCESSED_OBJ.object_version_number%TYPE,
  x_return_status		OUT NOCOPY VARCHAR2,
  x_msg_count			OUT NOCOPY VARCHAR2,
  x_msg_data			OUT NOCOPY VARCHAR2
);

---------------------------------------------------------------------------------
--
-- API name  : Get_Recently_Accessed_Objects
--
-- TYPE      : Public
--
-- FUNCTION  : Retrieve objects that have been recently accessed by a user. If
--             no type is specified, all objects are returned. Else, only those
--             recently accessed objects matching the specified type are
--             returned. The number of records returned is controlled by the
--             profile option IMC_MAX_DISPLAY_REC_OBJ_ACC.
--
-- Parameters:
--
--     IN    :
--             p_user_id IN NUMBER (required)
--             User for whom the recently accessed objects are requested.
--
--             p_object_type IN VARCHAR2 (optional)
--             Type of objects that have been accessed by user.
--             Valid Values (now): PARTY_ORGANIZATION, PARTY_C0NTACT_RELATIONSHIP,
--             PARTY_PERSON.
--             If NULL, all valid values (above) are included.
--
--             p_application_id IN NUMBER (optional)
--             Application requesting recent object access for user. Ignored if
--             NULL.
--
--             p_object_version_number IN NUMBER (optional)
--             Version number for concurrency control. Ignored if NULL.
--
--     OUT NOCOPY   :
--             x_object_info
--             A reference cursor returns the type, id and name of objects
--             recently accessed by the user. Returns NULL if no objects
--             have been recently accessed by the user.
--
--             x_return_status
--             1 byte result code:
--                'S'  Success  (FND_API.G_RET_STS_SUCCESS)
--                'E'  Error  (FND_API.G_RET_STS_ERROR)
--                'U'  Unexpected Error (FND_API.G_RET_STS_UNEXP_ERROR)
--
--             x_msg_count
--             Number of messages in message stack.
--             If 'E' or 'U' is returned, there will be an error message on the
--             FND_MESSAGE stack which can be retrieved with
--             FND_MESSAGE.GET_ENCODED().
--
--             x_msg_data
--             The first message in the FND_MESSAGE stack
--
-- Version: Current Version 1.0
-- Previous Version :  None
--
-- Notes     :
--
---------------------------------------------------------------------------------
PROCEDURE Get_Recently_Accessed_Objects (
  p_user_id                     IN IMC_RECENT_ACCESSED_OBJ.user_id%TYPE,
  p_object_type                 IN IMC_RECENT_ACCESSED_OBJ.object_type%TYPE,
  p_application_id              IN IMC_RECENT_ACCESSED_OBJ.application_id%TYPE,
  p_object_version_number       IN IMC_RECENT_ACCESSED_OBJ.object_version_number%TYPE,
  x_object_info			OUT NOCOPY ref_cursor_rec_obj_acc,
  x_return_status		OUT NOCOPY VARCHAR2,
  x_msg_count			OUT NOCOPY VARCHAR2,
  x_msg_data			OUT NOCOPY VARCHAR2
);

---------------------------------------------------------------------------------
--
-- API name  : Flush
--
-- TYPE      : Public
--
-- FUNCTION  : Remove all records for a user that are over the number specified
--             in the profile IMC_MAX_DISPLAY_REC_OBJ_ACC.
--
-- Parameters:
--
--     IN    :
--             p_user_id IN NUMBER (required)
--             User for whom the recently accessed objects are requested.
--
--     OUT NOCOPY   :
--             x_flush_count
--             Number of records deleted for this user to keep at profile
--             specified limit.
--
--             x_return_status
--             1 byte result code:
--                'S'  Success  (FND_API.G_RET_STS_SUCCESS)
--                'E'  Error  (FND_API.G_RET_STS_ERROR)
--                'U'  Unexpected Error (FND_API.G_RET_STS_UNEXP_ERROR)
--
--             x_msg_count
--             Number of messages in message stack.
--             If 'E' or 'U' is returned, there will be an error message on the
--             FND_MESSAGE stack which can be retrieved with
--             FND_MESSAGE.GET_ENCODED().
--
--             x_msg_data
--             The first message in the FND_MESSAGE stack
--
-- Version: Current Version 1.0
-- Previous Version :  None
--
-- Notes     :
--
---------------------------------------------------------------------------------
PROCEDURE Flush (
  p_user_id			IN IMC_RECENT_ACCESSED_OBJ.user_id%TYPE,
  x_flush_count			OUT NOCOPY NUMBER,
  x_return_status		OUT NOCOPY VARCHAR2,
  x_msg_count			OUT NOCOPY VARCHAR2,
  x_msg_data			OUT NOCOPY VARCHAR2
);

END IMC_RECENT_OBJECT_ACCESS_PUB;

 

/
