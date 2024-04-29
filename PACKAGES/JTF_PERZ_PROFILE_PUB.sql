--------------------------------------------------------
--  DDL for Package JTF_PERZ_PROFILE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_PERZ_PROFILE_PUB" AUTHID CURRENT_USER as
/* $Header: jtfzppfs.pls 120.2 2005/11/02 04:34:03 skothe ship $ */
--
--
-- Start of Comments
--
-- NAME
--   JTF_PERZ_PROFILE_PUB
--
-- PURPOSE
--   Public API for creating, getting and updating profiles in the Personalization
-- 	 framework.
--
-- NOTES
--   This is a pulicly accessible pacakge.  It should be used by all
--   sources for creating, getting and updating profiles in the Personalization
-- 	 framework. A profile is a mechanism that is used to tag a personalization
--	 construct to a user, application, template etc. In essence defining the
--	 audience for that personalization construct.
--

-- HISTORY
--   05/25/99   CCHANDRA	Created
-- 09/30/99	SMATTEGU	Changed update_profile()
--
--
-- End of Comments

--
--******************************************************************************
--
-- Start of Comments
--
--	PROFILE_ATTRIBUTE_REC_TYPE
--
--	This record is used to set the profile atibutes. If one is setting a
--	profile attribute, the columns PROFILE_ATTRIBUTE, ATTRIBUTE_TYPE and
--	ATTRIBUTE_VALUE are required.
--
--	Parameters
--
--  ATTRIBUTE_ID		NUMBER		OPTIONAL
--  PROFILE_ID		  	NUMBER		REQUIRED
--  PROFILE_ATTRIBUTE 		VARCHAR2(60)	REQUIRED
--  ATTRIBUTE_TYPE		VARCHAR2(30)    REQUIRED
--  ATTRIBUTE_VALUE 		VARCHAR2(30)	REQUIRED
--
-- End of Comments


TYPE PROFILE_ATTRIB_REC_TYPE		IS RECORD (

	ATTRIBUTE_ID		NUMBER		:= FND_API.G_MISS_NUM,
	PROFILE_ID		NUMBER 		:= FND_API.G_MISS_NUM,
	PROFILE_ATTRIBUTE	VARCHAR2(100) 	:= FND_API.G_MISS_CHAR,
	ATTRIBUTE_TYPE		VARCHAR2(100) 	:= FND_API.G_MISS_CHAR,
	ATTRIBUTE_VALUE		VARCHAR2(100) 	:= FND_API.G_MISS_CHAR
);

-- Start of Comments
--
--      Profile_Attribute Table: PROFILE_ATTRIB_TBL_TYPE
--
-- End of Comments

TYPE PROFILE_ATTRIB_TBL_TYPE	IS TABLE OF PROFILE_ATTRIB_REC_TYPE
				INDEX BY BINARY_INTEGER;


-- Defining G_MISS type for the table
G_MISS_PROFILE_ATTRIB_TBL	PROFILE_ATTRIB_TBL_TYPE;

-- Start of Comments
--
-- PROFILE_ATTRIB_OUT_REC_TYPE
--
-- This record defines the out record for a get performed on the database.
-- The table of results returned from a Get_Profile(..) will be a table of this
-- record type.
--
-- End of Comments


TYPE PROFILE_OUT_REC_TYPE IS RECORD (

	 	PROFILE_ID		NUMBER	  	:= NULL,
		PROFILE_NAME		VARCHAR2(60)  := NULL,
		PROFILE_TYPE		VARCHAR2(30)  := NULL,
		PROFILE_DESCRIPTION	VARCHAR2(240) := NULL,
		ACTIVE_FLAG		VARCHAR2(1)   := NULL,
		PROFILE_ATTRIBUTE	VARCHAR2(100)  := NULL,
		ATTRIBUTE_TYPE		VARCHAR2(100)  := NULL,
		ATTRIBUTE_VALUE		VARCHAR2(100)  := NULL
);


-- Defining Table of records
TYPE PROFILE_OUT_TBL_TYPE	IS TABLE OF PROFILE_OUT_REC_TYPE
				INDEX BY BINARY_INTEGER;


-- *****************************************************************************
--
-- START API SPECIFICATIONS
--
--	API NAME 	: Create_Profile
--	TYPE		: Public
--	FUNCTION	: This API is used to create a profile, given a profile name
--				  profile type and set of attributes/values.
--
--	PARAMETERS	:
--
--	IN		:
--			p_api_version_number	IN NUMBER	Required
--			p_init_msg_list		IN VARCHAR2 	Optional
--			p_commit		IN VARCHAR2	Optional
--			p_profile_id            IN NUMBER	Optional
--			p_profile_name          IN VARCHAR2	Required
--			p_profile_type		IN VARCHAR2 	Required
--			p_profile_desc		IN VARCHAR2 	Optional
--			p_profile_attrib_tbl	IN JTF_PERZ_PROFILE_PUB.PROFILE_ATTRIB_TBL_TYPE,
--
-- OUT :
--			x_return_status	 OUT VARCHAR2(1)
--			x_msg_count	 OUT NUMBER
--			x_msg_data	 OUT VARCHAR2(2000)
--
--
--
--	VERSION	:	Current version	1.0
--			 	Initial version 1.0
--
--	NOTES	:	Personalization Framework API to create a profile,
--				This API will create a profile based on profile name,
--				profile type, profile attributes and values.
--
-- *****************************************************************************
--
-- USAGE NOTES :
--
--	1. This API creates a profile in the profile store. Of the input parameters
--	p_profile_name (the name of the profile) is a required field. This field has to
--	be unique or the API will return an error. This field also has to be made of
--	characters with no spaces (underscores allowed).
--
--	2. The p_profile_type is the type of profile this is where the caller can specify
--	the type of profile (like USER, TEMPLATE, APPLICATION etc.) these type are defined
--	in FND_LOOKUPS under PERSONALIZATION_PROFILE_TYPES.
--
--	3. A description for the profile is passed via p_profile_desc
--
--	4. The p_profile_attrib_tbl is the table that holds the attributes and values
--	associated with a profile. The PROFILE_ATTRIBUTE field holds the name/tag
--	associated with a profile. The ATTRIBUTE_VALUE field holds the value for this
--	profile attribute. The ATTRIBUTE_TYPE is used to store the type of attribute
--	value being stored. For example, one could have a record like :
--	[PERSONALIZATION, 235, USER_ID]. this essentially says that the attribute is
--	for the user with id 235 and used for personalization.
--
--	5. The main out parameter for this API is x_return_status which returns
--	FND_API.G_RETURN_SUCCESS when the API completes successfully
--	FND_API.G_RETURN_UNEXPECTED when the API reaches a unxpected state
--	FND_API.G_RETURN_ERROR when the API hits an error
--
-- *****************************************************************************
--

PROCEDURE Create_Profile
( 	p_api_version_number	IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
	p_commit		IN	VARCHAR2 := FND_API.G_FALSE,
	p_profile_id            IN	NUMBER,
	p_profile_name          IN	VARCHAR2 := NULL,
	p_profile_type		IN 	VARCHAR2 := NULL,
	p_profile_desc		IN 	VARCHAR2 := NULL,
	p_profile_attrib_tbl	IN	JTF_PERZ_PROFILE_PUB.PROFILE_ATTRIB_TBL_TYPE
					:= JTF_PERZ_PROFILE_PUB.G_MISS_PROFILE_ATTRIB_TBL,

	x_profile_name       OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_profile_id         OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_msg_count	 OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_msg_data	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);


-- Start of Comments
--
--	API name 	: Get_Profile
--	Type		: Public
--	Function	: Return a profile(s) for a given set of parameters
--
--	Parameters	:
--	IN		:
--			p_api_version_number	IN NUMBER			Required
--			p_init_msg_list		IN VARCHAR2 			Optional
--			p_profile_id            IN NUMBER			Optional
--			p_profile_name          IN VARCHAR2			Optional
--			p_profile_type		IN VARCHAR2 			Optional
--			p_profile_attrib_tbl	IN	JTF_PERZ_PROFILE_PUB.PROFILE_ATTRIB_TBL_TYPE,
--
-- OUT :
--			x_profile_tbl OUT JTF_PERZ_PROFILE_PUB.PROFILE_OUT_TBL,
--			x_return_status OUT VARCHAR2(1)
--			x_msg_count	 OUT NUMBER
--			x_msg_data	 OUT VARCHAR2(2000)
--
--
--
--	Version	:	Current version	    1.0
--		 	Initial version 	1.0
--
--
-- *****************************************************************************
--
-- USAGE NOTES :
--
--	1. This API gets/queries a profile and its attributes in the profile store.
--	Of the input parameters p_profile_name (the name of the profile) is a required field or the
--	profile_id.
--
--	2. The x_profile_tbl holds the output set from the query. this is a table of type
--	JTF_PERZ_PROFILE_PUB.PROFILE_OUT_TBL.
--
--	2. The other out parameter for this API is x_return_status which returns
--	FND_API.G_RETURN_SUCCESS when the API completes successfully
--	FND_API.G_RETURN_UNEXPECTED when the API reaches a unxpected state
--	FND_API.G_RETURN_ERROR when the API hits an error
--
-- *****************************************************************************
--


PROCEDURE Get_Profile
( 	p_api_version_number	IN	NUMBER,
	p_init_msg_list			IN	VARCHAR2  := FND_API.G_FALSE,

	p_profile_id           	IN	NUMBER,
	p_profile_name          IN	VARCHAR2,
	p_profile_type			IN 	VARCHAR2,
	p_profile_attrib_tbl	IN	JTF_PERZ_PROFILE_PUB.PROFILE_ATTRIB_TBL_TYPE
						:= JTF_PERZ_PROFILE_PUB.G_MISS_PROFILE_ATTRIB_TBL,

	x_profile_tbl	 OUT NOCOPY /* file.sql.39 change */ JTF_PERZ_PROFILE_PUB.PROFILE_OUT_TBL_TYPE,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_msg_count		 OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_msg_data		 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);


-- Start of Comments
--
--	API name 	: Update_Profile
--	Type		: Public
--	Function	: Update a profile with a given set of parameters
--
--	Parameters	:
--	IN		:
--			p_api_version_number	IN NUMBER				Required
--			p_init_msg_list			IN VARCHAR2 			Optional
--			p_profile_id            IN	NUMBER				Optional
--			p_profile_name          IN	VARCHAR2			Optional
--			p_profile_type			IN VARCHAR2 			Optional
--			p_profile_desc			IN VARCHAR2 			Optional
--			p_profile_attrib_tbl	IN	JTF_PERZ_PROFILE_PUB.PROFILE_ATTRIB_TBL_TYPE,
--
-- OUT :
--			x_Profile_Tbl OUT JTF_PERZ_PROFILE_PUB.PROFILE_OUT_TBL,
--			x_return_status OUT VARCHAR2(1)
--			x_msg_count	 OUT NUMBER
--			x_msg_data	 OUT VARCHAR2(2000)
--
--
--
--	Version	:	Current version	1.0
--			 	Initial version 1.0
--
-- *****************************************************************************
--
-- USAGE NOTES :
--
--	1. This API updates a profile in the profile store. Of the input parameters
--	p_profile_name (the name of the profile) is a required field or the profile_id.
--
--	2. The p_profile_type is the type of profile this is where the caller can specify
--	the type of profile (like USER, TEMPLATE, APPLICATION etc.) these type are defined
--	in FND_LOOKUPS under PERSONALIZATION_PROFILE_TYPES. The existing profile will be updated
--	with this new profile_type.
--
--	3. A description for the profile is passed via p_profile_desc
--
--	4. The p_profile_attrib_tbl can hold the attribute-value pairs that need to be
--	update. if an attribute being sent in does not exist another attribute is inserted
--	against the existing profile.
--
--	5. The main out parameter for this API are x_profile_id and x_return_status which returns
--	FND_API.G_RETURN_SUCCESS when the API completes successfully
--	FND_API.G_RETURN_UNEXPECTED when the API reaches a unxpected state
--	FND_API.G_RETURN_ERROR when the API hits an error
--
-- *****************************************************************************
--

PROCEDURE Update_Profile
( 	p_api_version_number	IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
	p_commit		IN	VARCHAR2 := FND_API.G_FALSE,

	p_profile_id            IN	NUMBER,
	p_profile_name          IN	VARCHAR2,
	p_profile_type		IN 	VARCHAR2,
	p_profile_desc		IN	VARCHAR2,
	p_active_flag		IN 	VARCHAR2,
	p_profile_attrib_tbl	IN	JTF_PERZ_PROFILE_PUB.PROFILE_ATTRIB_TBL_TYPE
				:= JTF_PERZ_PROFILE_PUB.G_MISS_PROFILE_ATTRIB_TBL,

	x_profile_id	 OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_msg_count	 OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_msg_data	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);

-- *****************************************************************************
-- *****************************************************************************
END  JTF_PERZ_PROFILE_PUB ;

 

/
