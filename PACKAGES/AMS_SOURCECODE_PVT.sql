--------------------------------------------------------
--  DDL for Package AMS_SOURCECODE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_SOURCECODE_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvscgs.pls 115.17 2002/11/22 23:38:58 dbiswas ship $ */


-----------------------------------------------------------------
-- FUNCTION
--    is_source_code_unique(p_source_code)
--
-- PURPOSE
--    Check whether the source code is unique or not.
--
-- NOTES
--    1. Return FND_API.g_true or FND_API.g_false.
-----------------------------------------------------------------
FUNCTION is_source_code_unique(
   p_source_code  IN VARCHAR2
)
RETURN VARCHAR2;


-------------------------------------------------------------------
-- FUNCTION
--    get_new_source_code (p_object_type, p_custsetup_id, p_global_flag)
--
-- PURPOSE
--    Generate a unique source code for a campaign, event offer,
--    or offer.
--
-- PARAMETERS
--    p_object_type: any object type which requires a source code.
--    p_custsetup_id: the ID of the custom setup.
--    p_global_flag: indicates whether the object was created
--                   for a global audience.
--
-- NOTES
--    1. Raise FND_API.g_exc_error for invalid profile values.
--
--------------------------------------------------------------------
FUNCTION get_new_source_code (
   p_object_type IN VARCHAR2,
   p_custsetup_id IN NUMBER,
   p_global_flag IN VARCHAR2 := FND_API.g_false
)
RETURN VARCHAR2;


-------------------------------------------------------------------
-- FUNCTION
--    get_source_code(p_arc_object, p_type_code)
--
-- PURPOSE
--    Generate a unique source code for a campaign, event offer,
--    or offer. The prefix will be based on the type code. If no
--    type code passed in, use the p_arc_object as the prefix.
--
-- PARAMETERS
--    p_arc_object: must be one of 'CAMP' / 'EVEH' / 'OFFR'.
--    p_type_code: can be either null or a valid lookup_code from
--       AMS_CAMPAIGN_TYPE / AMS_EVENT_TYPE / AMS_OFFER_TYPE.
--
-- NOTES
--    1. Raise FND_API.g_exc_error for invalid input parameters.
--
-- EXAMPLE
--    get_source_code('CAMP', 'PRODUCT_LAUNCH') --> PROD10032
--------------------------------------------------------------------
FUNCTION get_source_code(
   p_arc_object  IN VARCHAR2,
   p_type_code   IN VARCHAR2
)
RETURN VARCHAR2;


--------------------------------------------------------------------
-- FUNCTION
--    get_source_code(p_category_id, p_arc_object)
--
-- PURPOSE
--    Generate a unique source code for a fund
--    The category id should be valid for a fund
-- PARAMAETERS
--    p_arc_object: must be one of 'FUND'.
--    p_category_id: --    The category id should be valid for a fund
--
-- NOTES
--    1. Raise FND_API.g_exc_error for invalid input parameters.
--
-- EXAMPLE
--    get_source_code(10021, 'FUND') --> MDF10034
--------------------------------------------------------------------
FUNCTION get_source_code(
   p_category_id   IN NUMBER,
   p_arc_object_for  IN VARCHAR2
)
RETURN VARCHAR2;

--------------------------------------------------------------------
-- FUNCTION
--    get_source_code(p_parent_id, p_arc_object)
--
-- PURPOSE
--    Generate a unique source code for a campaign schedule or event
--    offer. The parent id need to passed in to get a correct prifix
--    based on the parent campaign type or event header type.
--
-- PARAMAETERS
--    p_arc_object: must be one of 'CSCH' / 'EVEO'.
--    p_parent_id: the parent campaign id or event header id.
--
-- NOTES
--    1. Raise FND_API.g_exc_error for invalid input parameters.
--
-- EXAMPLE
--    get_source_code(10021, 'CSCH') --> PROD10033
--------------------------------------------------------------------
FUNCTION get_source_code(
   p_parent_id   IN NUMBER,
   p_arc_object  IN VARCHAR2
)
RETURN VARCHAR2;

--------------------------------------------------------------------
-- FUNCTION
--    get_source_code
--
-- PURPOSE
--    Generate a unique numeric source code without any prefix.
--------------------------------------------------------------------
FUNCTION get_source_code RETURN VARCHAR2;


 ---------------------------------------------------------------------
-- PROCEDURE
--    create_sourcecode
--
-- PURPOSE
--    Create a unique source code for a campaign/offer/campaign schedule.
--
-- PARAMETERS
--    p_sourcecode : the source code to be created
--    p_sourcecode_for : the object which uses the source code (Campaign/offer/campaign schedule
--                                                                                                                  Event / Event offer)
--    p_sourcecode_for_id : Unique identifier that identifies the object
--    x_sourcecode_id   :  The return value - the id of the source code record
--
-- NOTES
--    1.  Check for source code uniqueness. Insert source code if it is unique.
--    2.  If source code already exists, check if it is active.
--    3.  If the source code is active, return an error.
--    4.  If the source code is inactive, modify the source code rec with the new object parameters.

--  USAGE
--    Use this procedure whenever a new source code is being created. Even if an
--    existing campaign is modifying the source code, it is in effect creating a new source code.
--    Do not use this api to modify the source code after the campaign/ promotion goes active.
---------------------------------------------------------------------
PROCEDURE create_sourcecode(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_sourcecode         IN  VARCHAR2,
   p_sourcecode_for	   IN  VARCHAR2,
   p_sourcecode_for_id  IN  NUMBER,
   p_related_sourcecode    IN  VARCHAR2 := NULL,
   p_releated_sourceobj    IN  VARCHAR2 := NULL,
   p_related_sourceid      IN  NUMBER   := NULL,
   x_sourcecode_id      OUT NOCOPY NUMBER
);


 ---------------------------------------------------------------------
-- PROCEDURE
--    revoke_sourcecode
--
-- PURPOSE
--    Invalidate the source code.
--
-- PARAMETERS
--    p_sourcecode : the source code to be revoked

--
-- NOTES
--     update the active flag to 'N'

-- USAGE
--     Use this procedure to invalidate a source code. Source can be invalidate
--     because the campaign is cancelled or the campaign source code is modified.
--     CAUTION : Do not revoke a source code after a campaign goes to active stage.
--                          Even if the campaign has been in an active stage at some point of time
--                          and completed, do not revoke the source code as this source code
--                          can have referring orders / interactions.
---------------------------------------------------------------------
 PROCEDURE revoke_sourcecode(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_sourcecode        IN  VARCHAR2
);

PROCEDURE modify_sourcecode(
  p_source_code                IN  VARCHAR2,
  p_object_type                 IN  VARCHAR2,
  p_object_id		     IN   NUMBER,
  p_sourcecode_id          IN NUMBER,
  p_related_sourcecode    IN  VARCHAR2 := NULL,
  p_releated_sourceobj    IN  VARCHAR2 := NULL,
  p_related_sourceid      IN  NUMBER   := NULL,

  x_return_status     OUT NOCOPY VARCHAR2
) ;

END AMS_SourceCode_PVT;

 

/
