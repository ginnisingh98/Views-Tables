--------------------------------------------------------
--  DDL for Package IMC_OBJECT_METADATA_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IMC_OBJECT_METADATA_PUB" AUTHID CURRENT_USER AS
/* $Header: imcomds.pls 115.4 2002/11/12 21:52:47 tsli noship $ */

TYPE ref_cursor_obj_metadata IS REF CURSOR;

g_module CONSTANT VARCHAR2(30) := 'IMC_OBJECT_METADATA';

/* Messages */
g_invalid_object_type CONSTANT VARCHAR2(30) := 'IMC_INVALID_OBJ_TYPE';
g_metadata_api_others_ex CONSTANT VARCHAR2(30) := 'IMC_METADATA_API_OTHERS_EX';
g_no_metadata_for_obj_type CONSTANT VARCHAR2(30) := 'IMC_NO_METADATA_FOR_OBJ_TYPE';

/* Profiles */

/* Profile defaults */

---------------------------------------------------------------------------------
--
-- API name  : Add_Object_Metadata
--
-- TYPE      : Public
--
-- FUNCTION  : Add metadata for an object. If a record already exists for
--             this object, update fields. Otherwise, create a fresh entry.
--
-- Parameters:
--
--     IN    :
--             p_object_type IN VARCHAR2 (required)
--             Type of Object for which metadata should be created.
--
--             p_description IN VARCHAR2 (optional)
--             Description of the metadata being added.
--
--             p_function_name IN VARCHAR2 (optional)
--             Function name.
--
--             p_parameter_name IN VARCHAR2 (optional)
--             Parameter name for function.
--
--             p_enabled IN VARCHAR2 (optional)
--             Application recording metadata for object.
--             Defaulted to 'Y'.
--
--             p_application_id IN VARCHAR2 (optional)
--             Application recording metadata for object.
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
PROCEDURE Add_Object_Metadata (
  p_object_type			IN IMC_OBJECT_METADATA.object_type%TYPE,
  p_description			IN IMC_OBJECT_METADATA.description%TYPE,
  p_function_name		IN IMC_OBJECT_METADATA.function_name%TYPE,
  p_parameter_name		IN IMC_OBJECT_METADATA.parameter_name%TYPE,
  p_enabled			IN IMC_OBJECT_METADATA.enabled%TYPE,
  p_application_id		IN IMC_OBJECT_METADATA.application_id%TYPE,
  p_additional_value1		IN IMC_OBJECT_METADATA.additional_value1%TYPE,
  p_additional_value2		IN IMC_OBJECT_METADATA.additional_value2%TYPE,
  p_additional_value3		IN IMC_OBJECT_METADATA.additional_value3%TYPE,
  p_additional_value4		IN IMC_OBJECT_METADATA.additional_value4%TYPE,
  p_additional_value5		IN IMC_OBJECT_METADATA.additional_value5%TYPE,
  x_return_status		OUT NOCOPY VARCHAR2,
  x_msg_count			OUT NOCOPY VARCHAR2,
  x_msg_data			OUT NOCOPY VARCHAR2
);

---------------------------------------------------------------------------------
--
-- API name  : Remove_Object_Metadata
--
-- TYPE      : Public
--
-- FUNCTION  : Remove metadata for an object. If a record doesn't exist for
--             this object, return success but with message.
--
-- Parameters:
--
--     IN    :
--             p_object_type IN VARCHAR2 (required)
--             Type of Object for which metadata should be created.
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
PROCEDURE Remove_Object_Metadata (
  p_object_type			IN IMC_OBJECT_METADATA.object_type%TYPE,
  x_return_status		OUT NOCOPY VARCHAR2,
  x_msg_count			OUT NOCOPY VARCHAR2,
  x_msg_data			OUT NOCOPY VARCHAR2
);

---------------------------------------------------------------------------------
--
-- API name  : Get_Object_Metadata
--
-- TYPE      : Public
--
-- FUNCTION  : Retrieve metadata for an object. The description, function name,
--             parameter name, and enabled flag are returned.
--
-- Parameters:
--
--     IN    :
--             p_object_type IN VARCHAR2 (required)
--             Object for which metadata information should be retrieved.
--
--     OUT NOCOPY   :
--             x_metadata_info
--             A reference cursor returns the description, function name,
--             parameter name, and enabled flag, application id and
--             additional values (1 thru 5) for this object.
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
PROCEDURE Get_Object_Metadata (
  p_object_type                 IN IMC_OBJECT_METADATA.object_type%TYPE,
  x_metadata_info		OUT NOCOPY ref_cursor_obj_metadata,
  x_return_status		OUT NOCOPY VARCHAR2,
  x_msg_count			OUT NOCOPY VARCHAR2,
  x_msg_data			OUT NOCOPY VARCHAR2
);

---------------------------------------------------------------------------------
--
-- API name  : Get_Function_Name
--
-- TYPE      : Public
--
-- FUNCTION  : Fetch the function name for an object.
--
-- Parameters:
--
--     IN    :
--             p_object_type IN VARCHAR2 (required)
--             Object type for which function name should be retrieved.
--             If object type is invalid or if the function name has not been
--             set for the object type, NULL is returned.
--
--     OUT NOCOPY   :
--
-- Version: Current Version 1.0
-- Previous Version :  None
--
-- Notes     :
--
---------------------------------------------------------------------------------
FUNCTION Get_Function_Name (
  p_object_type			IN IMC_OBJECT_METADATA.object_type%TYPE
) RETURN IMC_OBJECT_METADATA.function_name%TYPE;

---------------------------------------------------------------------------------
--
-- API name  : Get_Parameter_Name
--
-- TYPE      : Public
--
-- FUNCTION  : Fetch the parameter name for an object.
--
-- Parameters:
--
--     IN    :
--             p_object_type IN VARCHAR2 (required)
--             Object type for which parameter name should be retrieved.
--             If object type is invalid or if the parameter name has not been
--             set for the object type, NULL is returned.
--
--     OUT NOCOPY   :
--
-- Version: Current Version 1.0
-- Previous Version :  None
--
-- Notes     :
--
---------------------------------------------------------------------------------
FUNCTION Get_Parameter_Name (
  p_object_type			IN IMC_OBJECT_METADATA.object_type%TYPE
) RETURN IMC_OBJECT_METADATA.parameter_name%TYPE;

---------------------------------------------------------------------------------
--
-- API name  : Get_Additional_Value
--
-- TYPE      : Public
--
-- FUNCTION  : Fetch the value of the "ADDITIONAL_VALUE" column (specified by
--             index -- there are five additional value columns) for this object
--             type.
--
-- Parameters:
--
--     IN    :
--             p_object_type IN VARCHAR2 (required)
--             Object type for which additional value should be retrieved.
--             If object type is invalid or if the function name has not been
--             set for the object type, NULL is returned.
--
--             p_index
--             Number (1-5) of the additional value column.
--
--     OUT NOCOPY   :
--
-- Version: Current Version 1.0
-- Previous Version :  None
--
-- Notes     :
--
---------------------------------------------------------------------------------
FUNCTION Get_Additional_Value (
  p_object_type                 IN IMC_OBJECT_METADATA.object_type%TYPE,
  p_index                       IN NUMBER
) RETURN VARCHAR2;

---------------------------------------------------------------------------------
--
-- API name  : Get_File_Name
--
-- TYPE      : Public
--
-- FUNCTION  : Fetch the name of the file corresponding to the function name
--             stored for this object.
--
-- Parameters:
--
--     IN    :
--             p_object_type IN VARCHAR2 (required)
--             Object type for which file name should be retrieved.
--             If object type is invalid or if the function name has not been
--             set for the object type, NULL is returned.
--
--     OUT NOCOPY   :
--
-- Version: Current Version 1.0
-- Previous Version :  None
--
-- Notes     :
--
---------------------------------------------------------------------------------
FUNCTION Get_File_Name (
  p_object_type			IN IMC_OBJECT_METADATA.object_type%TYPE
) RETURN VARCHAR2;

END IMC_OBJECT_METADATA_PUB;

 

/
