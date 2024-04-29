--------------------------------------------------------
--  DDL for Package JTF_PERZ_LF_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_PERZ_LF_PUB" AUTHID CURRENT_USER as
/* $Header: jtfzplfs.pls 120.2 2005/11/02 03:42:04 skothe ship $ */
--
--
-- Start of Comments
--
-- NAME
--   JTF_PERZ_LF_PUB
--
-- PURPOSE
--   Public API for creating, getting and updatingthe look and feel objects
--	 in the Personalization Framework.
--
-- NOTES
--   This is a pulicly accessible pacakge.  It should be used by all
--   sources for creating, getting and updating look and feel objects
-- 	in the Personalization framework.
--
--
-- HISTORY
--   05/25/99   SMATTEGU	Created
--	 05/26/99   CCHANDRA	reorganized, added get, update APIs
--	 05/26/99   SMATTEGU	updated create, get and update APIs
--	 06/01/99   SMATTEGU	updated create, get and update APIs
--						to incorporate the active inactive flag
--	 06/15/99   SMATTEGU	Changed the record structures of attribute
--	 					value record to reflect the schema changes.
--	 06/24/99   SMATTEGU	Changed the record structures of attribute
--	 					value record, object record.
--						Changed the p_object_tbl parameter in
--						get_lf_object to a IN OUT paramater
--	 07/28/99	CCHANDRA	Re-organised documentation
--	 07/29/99	CCHANDRA	Changed specs
--	 08/08/99	SMATTEGU	Changed the specs of personalize, create, update and get
--					to incorporate Object context
--	 08/08/99	SMATTEGU	Changed the OBJ_ATTRIB_REC_TYPE Record structure
--					to include object comtext
--					to exclude object_child_flag
--	 08/08/99	SMATTEGU	Changed the documentation
--	 08/17/99	SMATTEGU	Changed the following
--					1. LF_OBJECT_OUT_REC_TYPE
--					2. personalize_lf_object() to include
--						object_type_desc, object_type_id and
--						excluded context_id, context_name
--					3. create_lf_object() to include
--						object_type_id and excluded context_id,
--						context_name, attrobute_tbl
--	 08/18/99	SMATTEGU	Added the following
--					1. create_lf_object_type()
--					2. get_lf_object_type()
--					3. attrib_rec_type
--					Changed the following
--					1. get_lf_object()
--					2. LF_OBJECT_OUT_REC_TYPE to include object_type_id
--					this is needed because, this is an IN OUT parameter
--					for get_lf_object
--					3. update_lf_object() to exclude context_id, name
--					and object_description. Included object_type_id
--	 08/31/99	SMATTEGU	Added the following
--					1. save_lf_object_type()
--					2. OBJ_TYPE_MAP_REC_TYPE and corresponding table type
--					Deleted create_lf_object_type() as save does both
--					create and update.
--
--	 09/01/99	SMATTEGU, CCHANDRA	Changed
--					1. get_lf_object_type()
--					2. save_lf_object()
--					   (renamed personalize_lf_object to save_lf_object)
--					3. ATTRIB_VALUE_REC_TYPE
--						removed the active_flag
--					4. LF_OBJECT_OUT_REC_TYPE
--
--
-- End of Comments
--
-- *****************************************************************************
-- Start of Comments
--
--	ATTRIB_Rec
--
--	Parameters
--
--	ATTRIBUTE ID 		NUMBER
--	ATTRIBUTE NAME 		VARCHAR2(60)
--	ATTRIBUTE TYPE 		VARCHAR2(60)
--
-- End of Comments

TYPE ATTRIB_REC_TYPE		IS RECORD
(
	ATTRIBUTE_ID		NUMBER      	:= FND_API.G_MISS_NUM,
	ATTRIBUTE_NAME		VARCHAR2(30)	:= FND_API.G_MISS_CHAR,
	ATTRIBUTE_TYPE		VARCHAR2(30)	:= FND_API.G_MISS_CHAR
);

-- Start of Comments
--
--      Attrib_Rec Table: Attrib_rec_tbl_type
--
--
-- End of Comments

TYPE ATTRIB_REC_TBL_TYPE		IS TABLE OF ATTRIB_REC_TYPE
				INDEX BY BINARY_INTEGER;

-- G_MISS definition for table
G_MISS_ATTRIB_REC_TBL		ATTRIB_REC_TBL_TYPE;

-- *****************************************************************************
-- *****************************************************************************


-- Start of Comments
--
--	ATTRIB_VALUE Rec
--
--	Parameters
--
--	ATTRIBUTE ID 		NUMBER
--	ATTRIBUTE NAME 		VARCHAR2(60)
--	ATTRIBUTE VALUE 	VARCHAR2(60)
--	ATTRIBUTE TYPE 		VARCHAR2(60)
--	ACTIVE FLAG		VARCHAR2(1)
--	PRIORITY 		NUMBER
--
-- End of Comments

TYPE ATTRIB_VALUE_REC_TYPE		IS RECORD
(
	ATTRIBUTE_ID		NUMBER      	:= FND_API.G_MISS_NUM,
	ATTRIBUTE_NAME		VARCHAR2(30)	:= FND_API.G_MISS_CHAR,
	ATTRIBUTE_TYPE		VARCHAR2(30)	:= FND_API.G_MISS_CHAR,
	ATTRIBUTE_VALUE		VARCHAR2(100)	:= FND_API.G_MISS_CHAR,
 	PRIORITY            	NUMBER		:= FND_API.G_MISS_NUM
);

-- Start of Comments
--
--      Attrib_Value Table: Attrib_Value_tbl_type
--
--
-- End of Comments

TYPE ATTRIB_VALUE_TBL_TYPE		IS TABLE OF ATTRIB_VALUE_REC_TYPE
				INDEX BY BINARY_INTEGER;

-- G_MISS definition for table
G_MISS_ATTRIB_VALUE_TBL		ATTRIB_VALUE_TBL_TYPE;


-- *****************************************************************************
-- *****************************************************************************
-- Start of Comments
--
--      LF_OBJECT_OUT Record: This record will define the OUT record from a
--		'get' operation on the LF data store.
--
-- End of Comments
/*
-- profile_id must also be part of LF_OBJECT_OUT_REC_TYPE.
-- please make the change. Srikanth - 9-2-1999.
*/

TYPE LF_OBJECT_OUT_REC_TYPE		IS RECORD
(
 		PARENT_ID		NUMBER      	:= NULL,
 		OBJECT_ID		NUMBER      	:= NULL,
 		APPLICATION_ID		NUMBER      	:= NULL,
		OBJECT_NAME		VARCHAR2(60)	:= NULL,
		OBJECT_DESCRIPTION	VARCHAR2(240)	:= NULL,
 		OBJECT_TYPE_ID		NUMBER      	:= NULL,
		OBJECT_TYPE		VARCHAR2(60)	:= NULL,
		ATTRIBUTE_ID		NUMBER      	:= NULL,
		ATTRIBUTE_NAME		VARCHAR2(30)	:= NULL,
		ATTRIBUTE_TYPE		VARCHAR2(30)	:= NULL,
		ATTRIBUTE_VALUE		VARCHAR2(100)	:= NULL,
		ACTIVE_FLAG		VARCHAR2(1)	:= NULL,
 		PRIORITY            	NUMBER		:= NULL
);
-- *****************************************************************************

-- Start of Comments
--
--      LF_OBJECT_OUT_REC Table: LF_OBJECT_OUT_TBL_TYPE
--
--
-- End of Comments

TYPE LF_OBJECT_OUT_TBL_TYPE		IS TABLE OF LF_OBJECT_OUT_REC_TYPE
				INDEX BY BINARY_INTEGER;

-- Start of Comments
--
--	API name 	: save_lf_object
--	Type		: Public
--	Function	: Create and update if exists, attribute value pairs for
--			a given object and profile in an application_id domain.
--
--	Paramaeters	:
--	IN	:
--		p_api_version_number	IN NUMBER	Required
--		p_init_msg_list		IN VARCHAR2 	Optional
--					Default = FND_API.G_FALSE
--		p_commit		IN VARCHAR2	Optional
--		p_application_id	IN NUMBER	Required
--		p_profile_id		IN NUMBER	Required
--		p_profile_name		IN VARCHAR2	Optional
--		p_profile_type          IN VARCHAR2,
--		p_profile_attrib_tbl	IN JTF_PERZ_PROFILE_PUB.PROFILE_ATTRIB_TBL_TYPE	Optional
--		p_parent_id		IN NUMBER	Required
--		p_object_id		IN NUMBER	Optional
--		p_object_name		IN VARCHAR2	Required
--		p_object_description	IN VARCHAR2	Optional
--		p_object_type_id	IN NUMBER	Optional
--		p_object_type		IN VARCHAR2	Required
--		p_active_flag		IN VARCHAR2	Optional
--					Default = NO
--        	p_attrib_value_tbl	IN JTF_PERZ_LF_PUB.ATTRIB_VALUE_TBL_TYPE
--             := JTF_PERZ_LF_PUB.G_MISS_ATTRIB_VALUE_TBL   Optional
--
-- OUT :
--		x_object_id	 OUT NUMBER
--		x_return_status	 OUT VARCHAR2(1)
--		x_msg_count	 OUT NUMBER
--		x_msg_data	 OUT VARCHAR2(2000)
--
--
--	Version	:	Current version	1.0
--			 	Initial version 	1.0
--
--	Notes:
--
-- *****************************************************************************
--
-- USAGE NOTES :
--
-- This procedure is the only one needed to personalize a look and feel object.
-- Essentially, there are 5 main parameter sets that get passed to the procedure :
--
-- 1. The object name (or object id) [ p_object_name, p_object_id ]
-- 2. The object attributes and their values [ p_attrib_value_tbl ]
-- 3. The profile name (or profile id, attributes etc)
--		[ p_profile_name, p_profile_id ]. One of them must be given.
-- 4. The application id of the calling program [ p_application_id ]
-- 5. The object type (or object id) [p_object_type, p_object_type_id]
--
-- Based on this this information the procedure does the following :
--
-- 1.Looks up the the profile for the give profile data.
--	 It is highly recommended for performance reasons to query the user's
--	 PERSONALIZATION profile_id at log on time using
--	 PERZ_PROFILE_PUB.Get_Profile() by passing the PERSONALIZATION <tag> and
--	 user_id.
--
-- 2.The procedure will then check if a personalized LF object with the
--	 specified name exists. Again, specifying object_id will improve
--	 performance. The name of the object should be continious characters with
--	 allowed underscores.
--
-- 3.If there is such an object, then it is updated with the values specified
--	 in the attribute/value table and values made active. This also implies that
--	 ther can be only one object with that name for a given application and
--	 profile ID.
--
-- 4.If no object was found then, check if the give object type exists.
--	If, yes, create the object and the associated attributes value/profile pairs
--	for each attribute specified.
--
-- 	If no object type was found then an object type with the specified
--	name/attributes is created, an object is created and value/profile pairs
--	are created for each attribute specified.
--
--	 Once a parent object (for a given profile and application id) is set to
--	 inactive then, all it's children will also be set to inactive for that
--	 domain.
-- *****************************************************************************
--

PROCEDURE save_lf_object
( 	p_api_version_number	IN NUMBER,
  	p_init_msg_list		IN VARCHAR2 	:= FND_API.G_FALSE,
	p_commit		IN VARCHAR2 := FND_API.G_FALSE,

	p_profile_id            IN NUMBER,
	p_profile_name          IN VARCHAR2,
	p_profile_type          IN VARCHAR2,
	p_profile_attrib_tbl	IN JTF_PERZ_PROFILE_PUB.PROFILE_ATTRIB_TBL_TYPE
				:= JTF_PERZ_PROFILE_PUB.G_MISS_PROFILE_ATTRIB_TBL,

	p_application_id	IN NUMBER,
	p_parent_id		IN NUMBER,
	p_object_type_id	IN NUMBER,
	p_object_type           IN VARCHAR2,

	p_object_id             IN NUMBER,
	p_object_name           IN VARCHAR2,
	p_object_description	IN VARCHAR2,

	p_active_flag		IN VARCHAR2,
	p_attrib_value_tbl	IN JTF_PERZ_LF_PUB.ATTRIB_VALUE_TBL_TYPE
				:= JTF_PERZ_LF_PUB.G_MISS_ATTRIB_VALUE_TBL,

	x_object_id	 OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_msg_count	 OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_msg_data	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);

-- *****************************************************************************
-- *****************************************************************************

-- Start of Comments
--
--	API name 	: save_lf_object_type
--	Type		: Public
--	Function	: This procedure will create or update the given lf
--				object type.
--
--	Paramaeters	:
--	IN	:
--		p_api_version_number	IN NUMBER	Required
--		p_init_msg_list		IN VARCHAR2 	Optional
--					Default = FND_API.G_FALSE
--		p_commit		IN VARCHAR2	Optional

--		p_object_type_id	IN NUMBER	Optional
--		p_object_type		IN VARCHAR2	Optional
--		p_object_type_desc	IN VARCHAR2	Optional

--		p_attribute_rec_tbl	IN JTF_PERZ_LF_PUB.ATTRIB_REC_TBL_TYPE Required
--
-- OUT :
--		x_object_type_id OUT NUMBER
--		x_return_status	 OUT VARCHAR2
--		x_msg_count	 OUT NUMBER
--		x_msg_data	 OUT VARCHAR2(2000)
--
--
--	Version	:	Current version	1.0
--			 	Initial version 1.0
--
--	Notes:
--
-- *****************************************************************************

-- USAGE NOTES :
--
-- This procedure is used to create or update a look and feel object type in the
-- personalization framework.Essentially, there are 2 main parameter sets that
-- get passed to the procedure :
--
-- 1. the object type (or object_type id) [ p_object_type, p_object_type_id ]
-- 2. the object attributes and their values [ p_attrib_value_tbl ]
--
-- based on this this information the procedure does the following :
--
-- 1. the procedure will check if the object type already exists or not.
--
-- 2. If the object type already exists, then each attribute supplied,
--	will be compared against the existing attributes for that object type.
--	If there are any new attribute supplied, then they will be created in
--	along with the map to object type.
--
-- 3. If the object type does not exist, Then object type will be created.
--	Then each attribute supplied, an object type - attribute map will be created
--	If any attribute supplied does not exist in the attribute store, then
--	they will be created.
--
-- *****************************************************************************
PROCEDURE save_lf_object_type
( 	p_api_version_number	IN	NUMBER,
  	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
	p_commit		IN	VARCHAR2 := FND_API.G_FALSE,

	p_object_type_id        IN 	NUMBER,
	p_object_type           IN 	VARCHAR2,
	p_object_type_desc	IN 	VARCHAR2,

	p_attrib_rec_tbl	IN	JTF_PERZ_LF_PUB.ATTRIB_REC_TBL_TYPE
				:= JTF_PERZ_LF_PUB.G_MISS_ATTRIB_REC_TBL,

	x_object_type_id OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_msg_count	 OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_msg_data	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);

-- *****************************************************************************
-- *****************************************************************************

-- Start of Comments
--
--	API name 	: Create_lf_object
--	Type		: Public
--	Function	: Create attribute value pairs for a given object and profile
--
--	Paramaeters	:
--	IN	:
--		p_api_version_number	IN NUMBER	Required
--		p_init_msg_list		IN VARCHAR2 	Optional
--					Default = FND_API.G_FALSE
--		p_commit		IN VARCHAR2	Optional

--		p_profile_id		IN NUMBER	Optional
--		p_profile_name		IN VARCHAR2	Required

--		p_application_id	IN NUMBER	Required
--		p_parent_id		IN NUMBER	Optional
--		p_object_id		IN NUMBER	Optional
--		p_object_name		IN VARCHAR2	Required

--		p_object_type_id	IN NUMBER	Optional
--		p_object_type		IN VARCHAR2	Optional

--		p_attrib_value_tbl	IN	JTF_PERZ_LF_PUB.ATTRIB_VALUE_TBL_TYPE
--				:= JTF_PERZ_LF_PUB.G_MISS_ATTRIB_VALUE_TBL

-- OUT :
--		x_object_id	 OUT NUMBER
--		x_return_status	 OUT VARCHAR2(1)
--		x_msg_count	 OUT NUMBER
--		x_msg_data	 OUT VARCHAR2(2000)
--
--
--	Version	:	Current version	1.0
--			 	Initial version 1.0
--
--	Notes:	Personalization Framework API to create the Object attrib-
--			Value pair with their corresponding profile.
--
--
-- *****************************************************************************
--
-- USAGE NOTES :
--
-- This procedure is used to create a look and feel object in the
-- personalization framework.Essentially, there are 6 main parameter sets that
-- get passed to the procedure :
--
-- 1. the object name (or object id) [ p_object_name, p_object_id ]
-- 2. the object attributes and their values [ p_attrib_value_tbl ]
-- 3. the profile name (or profile id )
--	 [ p_profile_name, p_profile_id ]
-- 4. the application id of the calling program [ p_application_id ]
-- 5. the ID of the parent if this object has a parent (like a screen/form etc)
-- 6. The object type (or object id) [p_object_type, p_object_id]
--
-- based on this this information the procedure does the following :
--
-- 1. looks up the the profile for the give profile data.
--	 It is highly recommended for performance reasons to bring the user's
--	 PERSONALIZATION profile at log on time using
--	 JTF_PERZ_PROFILE_PUB.Get_Profile() by passing the PERSONALIZATION <tag> and
--	  user_id.
-- 2. looks up the object type, if it exists
-- 3. the procedure will then create a LF object in the framework
--
-- 4. The parent id specified has to be an object
--	 that already exists in the personalization framework.
--
--	Object creation will default the object attribute avlues active for
--	that profile.
--
-- *****************************************************************************
--
PROCEDURE Create_lf_object
( 	p_api_version_number	IN	NUMBER,
  	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
	p_commit		IN	VARCHAR2 := FND_API.G_FALSE,

	p_profile_id            IN 	NUMBER,
	p_profile_name          IN 	VARCHAR2,

	p_application_id	IN 	NUMBER,
	p_parent_id		IN 	NUMBER,
	p_object_id             IN 	NUMBER,
	p_object_name           IN 	VARCHAR2,

	p_object_type_id           	IN 	NUMBER,
	p_object_type           IN 	VARCHAR2,

	p_attrib_value_tbl	IN	JTF_PERZ_LF_PUB.ATTRIB_VALUE_TBL_TYPE
				:= JTF_PERZ_LF_PUB.G_MISS_ATTRIB_VALUE_TBL,

	x_object_id	 OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_msg_count	 OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_msg_data	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);

-- *****************************************************************************
-- *****************************************************************************

-- Start of Comments
--
--	API name 	: Get_lf_object_type
--	Type		: Public
--	Function	: Get attribute pairs for a given LF object_type
--
--	Paramaeters	:
--	IN	:
--		p_api_version_number	IN	NUMBER		Required
--		p_init_msg_list		IN	VARCHAR2 		Optional
--						Default = FND_API.G_FALSE
--
--		p_object_type		IN	VARCHAR2	Optional
--		p_object_type_id	IN	NUMBER	Optional
--
-- OUT :
--		x_object_type_id OUT NUMBER
--		x_object_type_desc OUT VARCHAR,

--		x_attrib_rec_tbl OUT JTF_PERZ_LF_PUB.ATTRIB_REC_TBL_TYPE

--		x_return_status	 OUT VARCHAR2(1)
--		x_msg_count	 OUT NUMBER
--		x_msg_data	 OUT VARCHAR2(2000)
--
--
--
--	Version	:	Current version	1.0
--			 Initial version 1.0
--
--	Notes:
--
-- *****************************************************************************
--
-- USAGE NOTES :
--
-- This procedure is used to get a LF object type from the personalization
-- framework.Essentially, there are 2 main parameter sets that get passed to
-- the procedure :
--
-- 1. the object type (or object_type_id) [ p_object_type, p_object_type_id ]
-- 2. The attribute_rec_tbl [x_attribute_rec_tbl]
--
-- based on this this information the procedure does the following :
--
-- 1. the procedure will then check if a personalized LF object_type with the
--	 specified name and attributes exists. Again, specifying ids
--	will improve performance.
-- 2. if there is such an object, then it's attributes are returned as an
-- out table.
--
--
-- *****************************************************************************
--

PROCEDURE Get_lf_object_type
( 	p_api_version_number	IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2 	:= FND_API.G_FALSE,

	p_Object_type		IN	VARCHAR,
	p_Object_type_Id	IN 	NUMBER,

	x_Object_type_Id OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_object_type_desc OUT NOCOPY /* file.sql.39 change */ 	VARCHAR2,

	x_attrib_rec_tbl OUT NOCOPY /* file.sql.39 change */ JTF_PERZ_LF_PUB.ATTRIB_REC_TBL_TYPE,

	x_return_status	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_msg_count	 OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_msg_data	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);


-- *****************************************************************************
-- *****************************************************************************

-- Start of Comments
--
--	API name 	: Get_lf_object
--	Type		: Public
--	Function	: Get attribute value pairs for a given LF object and profile
--
--	Paramaeters	:
--	IN	:
--		p_api_version_number	IN NUMBER		Required
--		p_init_msg_list		IN VARCHAR2 		Optional
--					Default = FND_API.G_FALSE
--		p_profile_id		IN NUMBER	Optional
--		p_profile_name		IN VARCHAR2	Optional
--		p_parent_id		IN NUMBER	Optional
--		p_object_id		IN NUMBER	Optional
--		p_object_name		IN VARCHAR2	Optional
--		p_obj_active_flag	IN VARCHAR2	Optional
--		p_get_children_flag	IN VARCHAR2	Optional
--
-- OUT :
--		x_Object_Tbl	 OUT JTF_PERZ_LF_PUB.LF_OBJECT_OUT_TBL_TYPE
--		x_return_status	 OUT VARCHAR2(1)
--		x_msg_count	 OUT NUMBER
--		x_msg_data	 OUT VARCHAR2(2000)
--
--
--
--	Version	:	Current version	1.0
--			 	Initial version 1.0
--
--	Notes:
--
-- *****************************************************************************
--
-- USAGE NOTES :
--
-- This procedure is used to get a look and feel object from the personalization
-- framework.Essentially, there are 4 main parameter sets that get passed to
-- the procedure :
--
-- 1. the object name (or object id) [ p_object_name, p_object_id ]
-- 2. the profile name (or profile id)
--    [ p_profile_name, p_profile_id ]
-- 3. the application id of the calling program [ p_application_id ]
-- 4. LF_OBJECT_OUT_TBL_TYPE [x_Object_Tbl] which has parent_id etc.
--
-- based on this this information the procedure does the following :
--
-- 1. looks up the the profile for the give profile data. It is highly
--	 recommended for performance reasons to bring the user's
-- 	 PERSONALIZATION profile at log on time using
--	 JTF_PERZ_PROFILE_PUB.Get_Profile() by passing the PERSONALIZATION <tag> and
--	  user_id.
-- 2. the procedure will then check if a personalized LF object with the
--	 specified name exists. Again, specifying object_id will improve
--	 performance.
-- 3. if there is such an object, then it's attributes and values associated
--	 with the profile specified are returned as an out table for that profile.
-- 4. Get_children_flag is used to indicate whether the api must get details of
-- 	the immediate children or not. If the flag is set to FND_API.G_TRUE then,
--	the API gets the attributes and their associated value pairs for all the
--	immediate children of the given object. If the flag is set to FND_API.G_FALSE,
--	then the object is only the given object's details will be obtained.
-- 5. by default only the active objects will be fetched
-- 6. if a parent (or given object) is inactive for a profile,
--	 all it's children will not be fetched.
--
--
--
--
-- *****************************************************************************
--

PROCEDURE Get_lf_object
( 	p_api_version_number	IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2 	:= FND_API.G_FALSE,

	p_application_id	IN 	NUMBER,
	p_priority		IN 	NUMBER,
	p_profile_id            IN	NUMBER,
	p_profile_name          IN	VARCHAR2,
	P_Object_Id		IN	NUMBER,
	p_Object_Name		IN	VARCHAR,
	p_obj_active_flag	IN 	VARCHAR2,
	p_get_children_flag	IN	VARCHAR2,
	x_Object_Tbl	 OUT NOCOPY /* file.sql.39 change */ JTF_PERZ_LF_PUB.LF_OBJECT_OUT_TBL_TYPE,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_msg_count	 OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_msg_data	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);

-- *****************************************************************************
-- *****************************************************************************


-- Start of Comments
--
--	API name 	: Update_lf_object
--	Type		: Public
--	Function	: Update attribute-value pairs for a given LF object and profile
--
--	Paramaeters	:
--	IN	:
--		p_api_version_number	IN 	NUMBER		Required
--		p_init_msg_list		IN 	VARCHAR2 	Optional
--						Default = FND_API.G_FALSE
--		p_commit		IN 	VARCHAR2
--						Default = FND_API.G_FALSE
--
--		p_profile_id		IN 	NUMBER		Optional
--		p_profile_name		IN 	VARCHAR2	Optional
--
--		p_application_id	IN 	NUMBER		Required
--		p_parent_id		IN 	NUMBER		Required
--		p_object_id		IN 	NUMBER		Optional
--		p_object_name		IN 	VARCHAR2	Optional
--		p_active_flag		IN 	VARCHAR2	Optional

--		p_object_type_id	IN 	NUMBER		Optional
--		p_object_type		IN 	VARCHAR2	Optional
--        	p_attrib_value_tbl	IN JTF_PERZ_LF_PUB.ATTRIB_VALUE_TBL_TYPE
--             		:= JTF_PERZ_LF_PUB.G_MISS_ATTRIB_VALUE_TBL   Optional
--
-- OUT :
--		x_object_id	 OUT NUMBER
--		x_return_status	 OUT VARCHAR2(1)
--		x_msg_count	 OUT NUMBER
--		x_msg_data	 OUT VARCHAR2(2000)
--
--
--
--	Version	:	Current version	1.0
--			 	Initial version 1.0
--
--	Notes: 	Object id or name must be specified.
--			Profile id or name must be specified.
--
--
-- *****************************************************************************
--
-- USAGE NOTES :
--
-- This procedure is used to update a look and feel object in the personalization framework.
-- Essentially, there are 5 main parameter sets that get passed to the procedure :
--
-- 1. the object id (or object id) [ p_object_id ]
-- 2. the object attributes and their values [ p_attrib_value_tbl ]
-- 3. the profile id ( p_profile id) [ p_profile_id ]
-- 4. the application id of the calling program [ p_application_id ]
-- 5. the ID of the parent if this object has a parent (like a screen/form etc)
--
-- based on this this information the procedure does the following :
--
-- 1. looks to see if object exists in framework
-- 2. the procedure will then update the LF object in the framework and will
--	 update attribute/value/profile tuples with the given attributes/values.
-- 3. The parent id specified has to be an object that already exists in the object store.
-- 4. Updating the object attribute/value pair will automatically makes the
--	 object active with an exception of updating the active flag to inactive. In
--	 which case that object will be made inactive for that profile-application id.
--
-- *****************************************************************************
--
PROCEDURE Update_lf_object
( 	p_api_version_number	IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
	p_commit		IN	VARCHAR2 := FND_API.G_FALSE,

	p_profile_id            IN	NUMBER,
	p_profile_name          IN	VARCHAR2,

	p_application_id	IN 	NUMBER,
	p_parent_id		IN 	NUMBER,
	p_object_Id		IN	NUMBER,
	p_object_name		IN 	VARCHAR2,
	p_active_flag		IN 	VARCHAR2,

	p_object_type_id	IN 	NUMBER,
	p_object_type		IN 	VARCHAR2,

	p_attrib_value_tbl	IN   	JTF_PERZ_LF_PUB.ATTRIB_VALUE_TBL_TYPE
					:= JTF_PERZ_LF_PUB.G_MISS_ATTRIB_VALUE_TBL,

	x_object_id	 OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_msg_count	 OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_msg_data	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);

-- *****************************************************************************
-- *****************************************************************************
END  JTF_PERZ_LF_PUB ;

 

/
