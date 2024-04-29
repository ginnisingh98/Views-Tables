--------------------------------------------------------
--  DDL for Package JTF_PERZ_LF_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_PERZ_LF_PVT" AUTHID CURRENT_USER as
/* $Header: jtfzvlfs.pls 120.2 2005/11/02 22:31:47 skothe ship $ */
--
--
-- Start of Comments
--
-- NAME
--   JTF_PERZ_LF_PVT
--
-- PURPOSE
--   Private API for  the look and feel objects.
--
-- NOTES
--   This is a pulicly accessible pacakge.  It should be used by all
--   sources for creating, getting and updating look and feel objects
-- 	in the Personalization framework.
--
--
-- HISTORY
--
--
--	 06/15/99   SMATTEGU	Created
--	 08/10/99   SMATTEGU	Modified Personalize and Update APIs to remove
--				object_child_flag and include active_flag,
--				p_context_id, p_context  as IN parameters
--	 08/11/99   SMATTEGU	Modified Create API to remove
--				object_child_flag and include p_context_id,
--				p_context  as IN parameters
--	 08/11/99   SMATTEGU	Modified Get API to include p_context_id,
--				p_context  as IN parameters
--	 08/18/99   SMATTEGU	Added
--				create_lf_object_type()
--				get_lf_object_type()
--	 08/18/99   SMATTEGU	Changed
--				update_lf_object() to reflect pub spec changes
--				personalize_lf_object() to reflect pub spec changes
--				create_lf_object()to reflect pub spec changes
--				get_le_object()to reflect pub spec changes
--
--	 08/31/99   SMATTEGU	added
--				save_lf_object_type()  method
--
--
--	 09/01/99	SMATTEGU, CCHANDRA	Changed
--					1. get_lf_object_type()
--					2. save_lf_object()
--					   (renamed personalize_lf_object to save_lf_object)
--
--
--
-- End of Comments
--
-- *****************************************************************************
-- Start of Comments
--
--	OBJ_TYPE_MAP_REC_TYPE
--
--	Parameters
--
--	TYPE_MAP_ID		NUMBER
--	OBJECT_TYPE_ID		NUMBER
--	ATTRIBUTE ID 		NUMBER
--
-- End of Comments

TYPE OBJ_TYPE_MAP_REC_TYPE		IS RECORD
(
	TYPE_MAP_ID		NUMBER	:= FND_API.G_MISS_NUM,
	OBJECT_TYPE_ID		NUMBER	:= FND_API.G_MISS_NUM,
	ATTRIBUTE_ID		NUMBER  := FND_API.G_MISS_NUM
);

-- Start of Comments
--
--      OBJ_TYPE_MAP_REC_TYPE 	Table: OBJ_TYPE_MAP_TBL_TYPE
--
TYPE OBJ_TYPE_MAP_TBL_TYPE IS TABLE OF OBJ_TYPE_MAP_REC_TYPE
				INDEX BY BINARY_INTEGER;

-- G_MISS definition for table
G_MISS_OBJ_TYPE_MAP_TBL		OBJ_TYPE_MAP_TBL_TYPE ;

--
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
-- OUT  :
--		x_object_id	 OUT  NUMBER
--		x_return_status	 OUT  VARCHAR2(1)
--		x_msg_count	 OUT  NUMBER
--		x_msg_data	 OUT  VARCHAR2(2000)
--
--
--
--	Version	:	Current version	1.0
--			 	Initial version 1.0
--
--	Notes: 	Object id or name must be specified.
--			Profile id or name must be specified.
--
-- *****************************************************************************

PROCEDURE Update_lf_object
( 	p_api_version_number	IN	NUMBER,
 	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
	p_commit		IN	VARCHAR2 := FND_API.G_FALSE,

	p_profile_id            IN	NUMBER,
	p_profile_name          IN	VARCHAR2 := NULL,

	p_application_id	IN 	NUMBER,
	p_parent_id		IN 	NUMBER := NULL,
	p_object_Id		IN	NUMBER,
	p_object_name		IN 	VARCHAR2 := NULL,
	p_active_flag		IN 	VARCHAR2,

	p_object_type_id	IN 	NUMBER,
	p_object_type		IN 	VARCHAR2 := NULL,

	p_attrib_value_tbl	IN   	JTF_PERZ_LF_PUB.ATTRIB_VALUE_TBL_TYPE
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
--	API name 	: save_lf_object
--	Type		: Public
--	Function	: Create and update if exists, attribute value pairs for
--				  a given object and profile in an application_id domain.
--
--	Paramaeters	:
--	IN	:
--		p_api_version_number	IN NUMBER		Required
--		p_init_msg_list		IN VARCHAR2 		Optional
--								Default = FND_API.G_FALSE
--		p_application_id	IN NUMBER		Required
--		p_profile_id		IN NUMBER		Required
--		p_profile_name		IN VARCHAR2		Optional
--		p_profile_type          IN VARCHAR2,
--		p_profile_attrib_tbl	IN JTF_PERZ_PROFILE_PUB.PROFILE_ATTRIB_TBL_TYPE	Optional
--		p_parent_id		IN NUMBER		Required
--		p_object_id		IN NUMBER		Optional
--		p_object_name		IN VARCHAR2		Required
--		p_object_description	IN VARCHAR2		Optional
--		p_object_type_id	IN NUMBER		Optional
--		p_object_type		IN VARCHAR2		Required
--		p_active_flag		IN VARCHAR2		Optional
--								Default = NO
--        p_attrib_value_tbl	IN JTF_PERZ_LF_PUB.ATTRIB_VALUE_TBL_TYPE
--             := JTF_PERZ_LF_PUB.G_MISS_ATTRIB_VALUE_TBL   Optional
--		p_commit		IN VARCHAR2	Optional
--
-- OUT  :
--		x_object_id	 OUT  NUMBER
--		x_return_status	 OUT  VARCHAR2(1)
--		x_msg_count	 OUT  NUMBER
--		x_msg_data	 OUT  VARCHAR2(2000)
--
--
--	Version	:	Current version	1.0
--			 	Initial version 	1.0
--
--	Notes:
--
-- *****************************************************************************

PROCEDURE save_lf_object
( 	p_api_version_number	IN NUMBER,
  	p_init_msg_list		IN VARCHAR2 := FND_API.G_FALSE,
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

-- OUT  :
--		x_object_id	 OUT  NUMBER
--		x_return_status	 OUT  VARCHAR2(1)
--		x_msg_count	 OUT  NUMBER
--		x_msg_data	 OUT  VARCHAR2(2000)
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

	p_object_type_id        IN 	NUMBER,
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
--		x_object_id OUT NUMBER	Optional
--		x_Object_Tbl	 OUT JTF_PERZ_LF_PUB.LF_OBJECT_OUT_TBL_TYPE,
--		x_return_status	 OUT VARCHAR2(1)
--		x_msg_count	 OUT  NUMBER
--		x_msg_data	 OUT  VARCHAR2(2000)
--
--
--
--	Version	:	Current version	1.0
--			 	Initial version 1.0
--
--	Notes:
--
-- *****************************************************************************

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
--	API name 	: Get_lf_object_type
--	Type		: Public
--	Function	: Get attribute pairs for a given LF object_type
--
--	Paramaeters	:
--	IN	:
--		p_api_version_number	IN 	NUMBER		Required
--		p_init_msg_list		IN 	VARCHAR2 		Optional
--						Default = FND_API.G_FALSE
--
--		p_object_type		IN 	VARCHAR2	Optional
--		p_object_type_desc	IN 	VARCHAR2	Optional
--		p_object_type_id	IN 	NUMBER	Optional
--

-- OUT  :
--		x_object_type_id OUT  	NUMBER
--		x_object_type_desc OUT 	VARCHAR,
--		x_attrib_rec_tbl OUT JTF_PERZ_LF_PUB.ATTRIB_REC_TBL_TYPE
--		x_return_status	 OUT  VARCHAR2(1)
--		x_msg_count	 OUT  NUMBER
--		x_msg_data	 OUT  VARCHAR2(2000)
--
--
--
--	Version	:	Current version	1.0
--			 	Initial version 1.0
--
--	Notes:
--
-- *****************************************************************************

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
-- OUT  :
--		x_object_type_id OUT  NUMBER
--		x_obj_type_map_tbl OUT  JTF_PERZ_LF_PUB.OBJ_TYPE_MAP_TBL_TYPE
--		x_return_status	 OUT  VARCHAR2
--		x_msg_count	 OUT  NUMBER
--		x_msg_data	 OUT VARCHAR2(2000)
--
--
--	Version	:	Current version	1.0
--			 	Initial version 1.0
--
--	Notes:
--
-- *****************************************************************************

PROCEDURE save_lf_object_type
( 	p_api_version_number	IN	NUMBER,
  	p_init_msg_list		IN	VARCHAR2 	:= FND_API.G_FALSE,
	p_commit		IN	VARCHAR2 := FND_API.G_FALSE,

	p_object_type_id        IN 	NUMBER,
	p_object_type           IN 	VARCHAR2,
	p_object_type_desc	IN 	VARCHAR2,

	p_attrib_rec_tbl	IN	JTF_PERZ_LF_PUB.ATTRIB_REC_TBL_TYPE
				:= JTF_PERZ_LF_PUB.G_MISS_ATTRIB_REC_TBL,

	x_object_type_id OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_obj_type_map_tbl OUT NOCOPY /* file.sql.39 change */ JTF_PERZ_LF_PVT.OBJ_TYPE_MAP_TBL_TYPE,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_msg_count	 OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_msg_data	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);
-- *****************************************************************************
END  JTF_PERZ_LF_PVT ;

 

/
