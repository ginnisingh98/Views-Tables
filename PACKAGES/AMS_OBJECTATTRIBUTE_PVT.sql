--------------------------------------------------------
--  DDL for Package AMS_OBJECTATTRIBUTE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_OBJECTATTRIBUTE_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvobas.pls 115.11 2001/12/17 16:15:21 pkm ship    $ */


---------------------------------------------------------------------
-- PROCEDURE
--    create_object_attributes
--
-- PURPOSE
--    Create all the attributes used by an object (campaign/event/event offering)
--
-- PARAMETERS
--    p_object_type : the four letter indicator for the object (Campaign / event / offering)
--    p_object_id : Unique identifier that identifies the object
--    p_setup_id  : identifier of the setup type used to create the object
--
-- NOTES
--    1.  Check if object type and setup type are valid.
--    2.  select all the attributes available for this setup type from ams_custom_setup_attr and
--          insert it in to ams_object_attributes
--    3.   Insert the mandatory general attribute with the display sequence no 0.
--          (This general attribute is mandatory for all objects and should be displayed first. This
--      attribute will also have the defined flag checked as details are filled during object creation.)

--  USAGE
--    Use this procedure whenever a new object (campaign/event/event offering) is created.
--    This will insert all the available attributes for this object and setup combination.
---------------------------------------------------------------------
PROCEDURE create_object_attributes(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT VARCHAR2,
   x_msg_count         OUT NUMBER,
   x_msg_data          OUT VARCHAR2,

   p_object_type       IN  VARCHAR2,
   p_object_id         IN  NUMBER,
   p_setup_id          IN  NUMBER
);


---------------------------------------------------------------------
-- PROCEDURE
--    modify_object_attribute
--
-- PURPOSE
--    Create all the attributes used by an object (campaign/event/event offering)
--
-- PARAMETERS
--    p_object_type : the four letter indicator for the object (Campaign / event / offering)
--    p_object_id : Unique identifier that identifies the object
--    p_attr  : identifier of the setup type used to create the object
--    p_attr_defined_flag  : flag to indicate if values are defined for the attribute or not (Y/N)
--
-- NOTES
--    1. Check if object type and and attribute are  valid.
--    2. Update the attribute defined flag

--  USAGE
--    Use this procedure whenever values are entered for an object atribute.
--     (ex. If a Product is defined for a campaign call this procedure and pass the attr_defined_flag as 'Y'.
--            This would tell the user that a product has already been defined for the campaign.)
--    Use this procedure when all the values are deleted for an object attribute
--     (ex. If all Products for a campaign are deleted, call this procedure and pass the attr_defined_flag as 'N'.
--            This would tell the user that no product has been defined for the campaign.)
--
--
---------------------------------------------------------------------
PROCEDURE modify_object_attribute(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT VARCHAR2,
   x_msg_count         OUT NUMBER,
   x_msg_data          OUT VARCHAR2,

   p_object_type        IN  VARCHAR2,
   p_object_id          IN  NUMBER,
   p_attr               IN  VARCHAR2,
   p_attr_defined_flag  IN  VARCHAR2
);


---------------------------------------------------------------------
-- FUNCTION
--    check_object_attribute
--
-- PURPOSE
--    Check if an attribute can be attached to the specified object.
---------------------------------------------------------------------
FUNCTION check_object_attribute(
   p_obj_type    IN  VARCHAR2,
   p_obj_id      IN  NUMBER,
   p_attribute   IN  VARCHAR2
)
RETURN VARCHAR2;  --FND_API.g_true/g_false


END AMS_ObjectAttribute_PVT;

 

/
