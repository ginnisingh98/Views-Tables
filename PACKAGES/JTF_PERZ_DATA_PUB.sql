--------------------------------------------------------
--  DDL for Package JTF_PERZ_DATA_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_PERZ_DATA_PUB" AUTHID CURRENT_USER as
/* $Header: jtfzppds.pls 120.2 2005/11/02 03:59:11 skothe ship $ */
--
--
-- Start of Comments
--
-- NAME
--   JTF_PERZ_DATA_PUB
--
-- PURPOSE
--   Public API for creating, getting and updating personalized data objects
-- 	 in the Personalization Framework.
--
-- NOTES
--   This is a pulicly accessible pacakge.  It should be used by all
--   sources for creating, getting and updating personalized data objects
-- 	 in the Personalization Framework.
--
-- HISTORY
--	05/26/99	CCHANDRA	Created
--	05/26/99	CCHANDRA	Added Create, get, update APIs
--	05/26/99	SMATTEGU	updated create, get and update APIs
--	06/20/99	CCHANDRA	updated APIs, renamed package
--	07/28/99	CCHANDRA	added documentation, user notes.
--	09/20/99	SMATTEGU	Changed
--					DATA_ATTRIB_REC_TYPE, DATA_OUT_REC_TYPE
--					save, create and get_perz_data APIs
--	09/27/99	SMATTEGU	Documenting the entire package
--	01/24/00	SMATTEGU	Documenting the entire package
--      02/03/2000      SMATTEGU        Enhancement #1181062 changing the
--                                      perz_data_name size from 60 to 120
--
-- End of Comments
--
-- *****************************************************************************
-- *****************************************************************************
-- Start of Comments
--
--	DATA_ATTRIB_REC_TYPE Rec
--
--	This record is used to set the data attributes associated
--	with a personalized data object.
--
-- End of Comments

TYPE DATA_ATTRIB_REC_TYPE	IS RECORD
(
 	PERZ_DATA_ATTRIB_ID	NUMBER        	:= NULL,
 	PERZ_DATA_ID		NUMBER        	:= NULL,
	ATTRIBUTE_NAME		VARCHAR2(60)	:= NULL,
	ATTRIBUTE_TYPE		VARCHAR2(30)	:= NULL,
	ATTRIBUTE_VALUE		VARCHAR2(300)	:= NULL,
	ATTRIBUTE_CONTEXT 	VARCHAR2(360)	:= NULL
);

-- Start of Comments
--
--      DATA_ATTRIB_REC_TYPE Table: DATA_ATTRIB_TBL_TYPE
--
--
-- End of Comments

TYPE DATA_ATTRIB_TBL_TYPE	IS TABLE OF DATA_ATTRIB_REC_TYPE
				INDEX BY BINARY_INTEGER;

-- G_MISS definition for table
G_MISS_DATA_ATTRIB_TBL		DATA_ATTRIB_TBL_TYPE;

-- *****************************************************************************
-- DATA_OUT_REC_TYPE
--
-- This record defines the out record for a get performed on the database.
-- The table of results returned from Get_Perz_Data(..) will be a table
-- of this record type.
--
--
-- End of Comments

TYPE DATA_OUT_REC_TYPE		IS RECORD
(
 	PERZ_DATA_ID		NUMBER      	:= NULL,
	PROFILE_ID		NUMBER      	:= NULL,
	APPLICATION_ID		NUMBER      	:= NULL,
	PERZ_DATA_NAME		VARCHAR2(120)	:= NULL,
	PERZ_DATA_TYPE		VARCHAR2(30)	:= NULL,
	PERZ_DATA_DESC		VARCHAR2(240)	:= NULL
);

-- Start of Comments
--
--      DATA_OUT_TBL_TYPE Table: DATA_OUT_REC_TYPE
--
--
-- End of Comments

TYPE DATA_OUT_TBL_TYPE		IS TABLE OF DATA_OUT_REC_TYPE
				INDEX BY BINARY_INTEGER;
-- *****************************************************************************
-- *****************************************************************************

-- Start of Comments
--
--	API name 	: Save_Perz_Data
--	Type		: Public
--	Function	: Create or update if exists, a personalized data object and
--			  associated data attributes with values.
--
--	Parameters	:
--	IN		:
-- 		p_api_version_number	IN NUMBER	Required
--   		p_init_msg_list		IN VARCHAR2	Optional
-- 		p_commit		IN VARCHAR	Optional
--
-- 		p_application_id	IN NUMBER	Required

-- 		p_profile_id        	IN NUMBER	Optional
-- 		p_profile_name      	IN VARCHAR2	Optional
-- 		p_profile_type      	IN VARCHAR2	Optional
-- 		p_profile_attrib    	IN PERZ_PROFILE_PUB.PROFILE_ATTRIB_TBL_TYPE
--							Optional
-- 		p_perz_data_id		IN NUMBER	Optional
-- 		p_perz_data_name        IN VARCHAR2	Required
-- 		p_perz_data_type	IN VARCHAR2	Required
-- 		p_perz_data_desc	IN VARCHAR2 Optional
-- 		p_data_attrib_tbl	IN JTF_PERZ_DATA_PUB.DATA_ATTRIB_TBL_TYPE
--
-- OUT :
--		x_perz_data_id	    OUT NUMBER
-- 		x_return_status	 OUT VARCHAR2
-- 		x_msg_count	 OUT NUMBER
-- 		x_msg_data	 OUT VARCHAR2
--
--
--	Version	:	Current version	1.0
--			Initial version 1.0
--
--	Notes: This API createsor Updates the PerzData Object. If Profile is
--	not existing and necessary information is given, this API can create
--	the profile on the fly.
--
--
-- *****************************************************************************
--
-- USAGE NOTES :
--
--	1. This API creates or updates if it already exists, a PerzData Object in
--	the personalization framework.
--
--	Of the input parameters p_profile_id (or the name of the profile
--	[p_profile_name] and its attributes p_Profile_Attrib) is a required field.
--	The other required fields are p_application_id, p_perz_data_name
--	p_perz_data_type (like BOOKMARKS, SHOPPING_TEMPLATE, etc.).
--	The  PerzData Name and Type have to be unique for a given
--	profile id and application id, or the API will return an error.
--	The PerzData Name has to be made of characters with no spaces.
--
--	2. The p_perz_data_desc is the description (free text) of Personalized data
--	object being saved. If PerzData Id is given, it must be unique at
--	the database. Otherwise, the API will return an error.
--
--	3. The p_data_attrib_tbl is the table that holds the fields and values
--	associated with a PerzData. The ATTRIBUTE_NAME field holds the name/tag of the
--	attribute associated with a data object. The ATTRIBUTE_TYPE field holds the
--	type for this data attribute. The ATTRIBUTE_VALUE is used to store the
--	value of the data attribute. The ATTRIBUTE_CONTEXT is the context for that
--	value. For example, one could have a record like :
--	[BOOKMARK1, STRING, http://www.cnn.com, NULL].
--
--	4. The main out parameter for this API is x_return_status which returns
--	FND_API.G_RETURN_SUCCESS when the API completes successfully
--	FND_API.G_RETURN_UNEXPECTED when the API reaches a unxpected state
--	FND_API.G_RETURN_ERROR when the API hits an error
--
-- *****************************************************************************
--

PROCEDURE Save_Perz_Data
( 	p_api_version_number	IN	NUMBER,
  	p_init_msg_list		IN	VARCHAR2 	:= FND_API.G_FALSE,
	p_commit		IN VARCHAR		:= FND_API.G_FALSE,

	p_application_id	IN NUMBER,
	p_profile_id        	IN NUMBER,
	p_profile_name      	IN VARCHAR2,
	p_profile_type      	IN VARCHAR2,
	p_profile_attrib    	IN JTF_PERZ_PROFILE_PUB.PROFILE_ATTRIB_TBL_TYPE
				:= JTF_PERZ_PROFILE_PUB.G_MISS_PROFILE_ATTRIB_TBL,
	p_perz_data_id		IN NUMBER,
	p_perz_data_name        IN VARCHAR2,
	p_perz_data_type	IN VARCHAR2,
	p_perz_data_desc	IN VARCHAR2,
	p_data_attrib_tbl	IN JTF_PERZ_DATA_PUB.DATA_ATTRIB_TBL_TYPE
				:= JTF_PERZ_DATA_PUB.G_MISS_DATA_ATTRIB_TBL,

	x_perz_data_id	    OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_msg_count	 OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_msg_data	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);
-- *****************************************************************************


-- Start of Comments
--
--	API name 	: Create_Perz_Data
--	Type		: Public
--	Function	: Create a PerzData Object and associated data attributes
--			and values, for a given profile and application id.
--
--	Parameters	:
--	IN		:
-- 		p_api_version_number	IN NUMBER	Required
--   		p_init_msg_list			IN VARCHAR2	Optional
-- 		p_commit		IN VARCHAR	Optional
--
-- 		p_application_id	IN NUMBER	Required
-- 		p_profile_id        	IN NUMBER	Optional
-- 		p_profile_name      	IN VARCHAR2	Optional
--
-- 		p_perz_data_id		IN NUMBER	Optional
-- 		p_perz_data_name        IN VARCHAR2	Required
-- 		p_perz_data_type	IN VARCHAR2	Required
-- 		p_perz_data_desc	IN VARCHAR2 Optional
-- 		p_data_attrib_tbl	IN JTF_PERZ_DATA_PUB.DATA_ATTRIB_TBL_TYPE
--
-- OUT :
--		x_perz_data_id	    OUT NUMBER
-- 		x_return_status	 OUT VARCHAR2
-- 		x_msg_count	 OUT NUMBER
-- 		x_msg_data	 OUT VARCHAR2
--
--
--	Version	:Current version	1.0
--		 Initial version 	1.0
--
--	Notes:
--
--
--
-- ******************************************************************************
--
--
-- USAGE NOTES :
--
--	1. This API creates a PerzData Object in the personalization framework.
--
--	Of the input parameters p_profile_id (or the name of the profile
--	[p_profile_name] and its attributes p_Profile_Attrib) is a required field.
--	The other required fields are p_application_id, p_perz_data_name
--	p_perz_data_type (like BOOKMARKS, SHOPPING_TEMPLATE, etc.).
--	The  PerzData Name and Type have to be unique for a given
--	profile id and application id, or the API will return an error.
--	The PerzData Name has to be made of characters with no spaces.
--
--	2. The p_perz_data_desc is the description (free text) of Personalized
--	data object being saved. If PerzData Id is given, it must be unique at
--	the database. Otherwise, the API will return an error.
--
--	3. The p_data_attrib_tbl is the table that holds the fields and values
--	associated with a PerzData. The ATTRIBUTE_NAME field holds the name/tag
--	of the attribute associated with a data object. The ATTRIBUTE_TYPE field
--	holds the type for this data attribute. The ATTRIBUTE_VALUE is used to
--	store the value of the data attribute. The ATTRIBUTE_CONTEXT is the context
--	for that value. For example, one could have a record like :
--	[BOOKMARK1, STRING, http://www.cnn.com, NULL].
--
--	4. The main out parameter for this API is x_return_status which returns
--	FND_API.G_RETURN_SUCCESS when the API completes successfully
--	FND_API.G_RETURN_UNEXPECTED when the API reaches a unxpected state
--	FND_API.G_RETURN_ERROR when the API hits an error
-- *******************************************************************************

PROCEDURE Create_Perz_Data
( 	p_api_version_number	IN	NUMBER,
  	p_init_msg_list		IN	VARCHAR2 	:= FND_API.G_FALSE,
	p_commit		IN VARCHAR		:= FND_API.G_FALSE,

	p_application_id	IN NUMBER,
	p_profile_id            IN NUMBER,
	p_profile_name          IN VARCHAR2,
	p_perz_data_id		IN NUMBER,
    	p_perz_data_name        IN VARCHAR2,
	p_perz_data_type	IN VARCHAR2,
	p_perz_data_desc	IN VARCHAR2,
	p_data_attrib_tbl	IN JTF_PERZ_DATA_PUB.DATA_ATTRIB_TBL_TYPE
				:= JTF_PERZ_DATA_PUB.G_MISS_DATA_ATTRIB_TBL,

	x_perz_data_id	    OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_msg_count	 OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_msg_data	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);

-- *****************************************************************************


-- Start of Comments
--
--	API name 	: Get_Perz_Data
--	Type		: Public
--	Function	: Get personalized data object, attribute value pairs
--				  for a given personalized data object and profile and app id.
--
--	Parameters	:
--	IN	:
-- 		p_api_version_number	IN NUMBER 	Required
--   		p_init_msg_list		IN VARCHAR2	Optional
--
-- 		p_application_id	IN NUMBER	Required
-- 		p_profile_id        	IN NUMBER	Optional
-- 		p_profile_name      	IN VARCHAR2	Optional
--
--		p_perz_data_id        	IN NUMBER	Optional
-- 		p_perz_data_name        IN VARCHAR2	Optional
-- 		p_perz_data_type      	IN VARCHAR2	Optional

-- OUT :
--		x_perz_data_id          OUT NUMBER,
--		x_perz_data_name        OUT VARCHAR2,
--		x_perz_data_type OUT VARCHAR2,
--		x_perz_data_desc OUT VARCHAR2,
--		x_data_attrib_tbl OUT JTF_PERZ_DATA_PUB.DATA_ATTRIB_TBL_TYPE,
--
-- 		x_return_status	 OUT VARCHAR2
-- 		x_msg_count	 OUT NUMBER
-- 		x_msg_data	 OUT VARCHAR2
--
--	Version	:Current version	1.0
--		 Initial version 	1.0
--
--	Notes:
--
--
--
-- *****************************************************************************
--
-- USAGE NOTES :
--
--	1. This API gets/queries a personalized data object from the personalization
--	framework. Of the input parameters p_profile_id (or the name of the profile
--	p_profile_name) the application id (p_application_id), the name of the
--	data object p_perz_data_name and type  are required fields. Sending in the
--	data id (p_perz_data_id) will improve performance.
--
--	2. x_perz_data_id, x_perz_data_name, x_perz_data_type and x_perz_data_desc
--	holds the query header details.
--
--	3. The x_data_attrib_tbl holds the output set from the PerzData Attributes.
--	This is a table of type	JTF_PERZ_DATA_PUB.DATA_ATTRIB_TBL_TYPE.
--
--	4. The other out parameter for this API is x_return_status which returns
--	FND_API.G_RETURN_SUCCESS when the API completes successfully
--	FND_API.G_RETURN_UNEXPECTED when the API reaches a unxpected state
--	FND_API.G_RETURN_ERROR when the API hits an error
--
--	5. This API will only return one PerzData and it's details.
-- 	If there are more than one retrieved then, this results in an error

-- *****************************************************************************

PROCEDURE Get_Perz_Data
( 	p_api_version_number	IN	NUMBER,
  	p_init_msg_list		IN VARCHAR2 	:= FND_API.G_FALSE,

	p_application_id	IN NUMBER,
	p_profile_id       	IN	NUMBER,
	p_profile_name     	IN	VARCHAR2,
	p_perz_data_id          IN NUMBER,
	p_perz_data_name        IN VARCHAR2,
	p_perz_data_type	IN VARCHAR2 := NULL,

    	x_perz_data_id          OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_perz_data_name        OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_perz_data_type OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_perz_data_desc OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_data_attrib_tbl OUT NOCOPY /* file.sql.39 change */ JTF_PERZ_DATA_PUB.DATA_ATTRIB_TBL_TYPE,

	x_return_status	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_msg_count	 OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_msg_data	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);
-- *****************************************************************************
--
-- Start of Comments
--
--	API name 	: Get_Perz_Data_Summary
--	Type		: Public
--	Function	: Get PerzData object
--
--
--	Parameters	:
--	IN	:
-- 		p_api_version_number	IN NUMBER 	Required
--   		p_init_msg_list		IN VARCHAR2	Optional
--
-- 		p_application_id	IN NUMBER	Required
-- 		p_profile_id        	IN NUMBER	Optional
-- 		p_profile_name      	IN VARCHAR2	Optional
--
--		p_perz_data_id        	IN NUMBER	Optional
-- 		p_perz_data_name        IN VARCHAR2	Optional
-- 		p_perz_data_type      	IN VARCHAR2	Optional

-- OUT :
--		x_perz_data_id          OUT NUMBER,
--		x_perz_data_name        OUT VARCHAR2,
--		x_perz_data_type OUT VARCHAR2,
--		x_perz_data_desc OUT VARCHAR2,
--		x_data_attrib_tbl OUT JTF_PERZ_DATA_PUB.DATA_ATTRIB_TBL_TYPE,
--
-- 		x_return_status	 OUT VARCHAR2
-- 		x_msg_count	 OUT NUMBER
-- 		x_msg_data	 OUT VARCHAR2
--
--	Version	:Current version	1.0
--		 Initial version 	1.0
--
--	Notes:
--
--
--
-- *****************************************************************************
--
-- USAGE NOTES :
--
--	1. This API gets/queries a PerzData object from the personalization
--	framework. Of the input parameters p_profile_id (or the name of the
--	profile p_profile_name) the application id (p_application_id), the
--	name and type of the data object are required fields.
--	Sending in the data id (p_perz_data_id) will improve performance.
--
--	3. The x_data_out_tbl holds the output set from the PerzData.
--	This is a table of type	JTF_PERZ_DATA_PUB.DATA_OUT_TBL_TYPE.
--
--	4. The other out parameter for this API is x_return_status which returns
--	FND_API.G_RETURN_SUCCESS when the API completes successfully
--	FND_API.G_RETURN_UNEXPECTED when the API reaches a unxpected state
--	FND_API.G_RETURN_ERROR when the API hits an error
--
-- *****************************************************************************


PROCEDURE Get_Perz_Data_Summary
( 	p_api_version_number	IN	NUMBER,
  	p_init_msg_list		IN VARCHAR2 	:= FND_API.G_FALSE,

	p_application_id	IN NUMBER,
	p_profile_id       	IN	NUMBER,
	p_profile_name     	IN	VARCHAR2,
	p_perz_data_id          IN NUMBER,
	p_perz_data_name        IN VARCHAR2,
	p_perz_data_type	IN VARCHAR2 := NULL,

	x_data_out_tbl	 OUT NOCOPY /* file.sql.39 change */ JTF_PERZ_DATA_PUB.DATA_OUT_TBL_TYPE,

	x_return_status	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_msg_count	 OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_msg_data	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);
-- *****************************************************************************
-- Start of Comments
--
--	API name 	: Update_Perz_Data
--	Type		: Public
--	Function	: Update PerzData object
--
--	Parameters	:
--	IN		:
-- 		p_api_version_number	IN NUMBER	Required
--   		p_init_msg_list		IN VARCHAR2	Optional
-- 		p_commit		IN VARCHAR	Optional
--
-- 		p_application_id	IN NUMBER	Required
-- 		p_profile_id        	IN NUMBER	Required
--
-- 		p_perz_data_id        	IN NUMBER	Optional
-- 		p_perz_data_name        IN VARCHAR2	Required
-- 		p_perz_data_type	IN VARCHAR2	Required
-- 		p_perz_data_desc	IN VARCHAR2 	Optional
-- 		p_data_attrib_tbl	IN JTF_PERZ_DATA_PUB.DATA_ATTRIB_TBL_TYPE
--
-- OUT :
--		x_perz_data_id	    OUT NUMBER
-- 		x_return_status	 OUT VARCHAR2
-- 		x_msg_count	 OUT NUMBER
-- 		x_msg_data	 OUT VARCHAR2
--
--
--
--	Version	:Current version	1.0
--	 	Initial version 	1.0
--
--	Notes:
--
-- *****************************************************************************
--
--
-- USAGE NOTES :
--
--	1. This API updates a PerzData Object in the personalization framework.
--
--	The required fields are profile_id,p_application_id, p_perz_data_name
--	or id, p_perz_data_type. The PerzData Name and Type have to be unique
--	for a given profile id and application id, or
--	the API will return an error.
--
--	2. The p_perz_data_desc is the description of Personalized data
--	object saved. If PerzData Id is given, it must be unique at
--	the database. Otherwise, the API will return an error.
--
--	3. The p_data_attrib_tbl is the table that holds the fields and values
--	associated with a PerzData. The ATTRIBUTE_NAME field holds the name/tag of the
--	attribute associated with a data object. The ATTRIBUTE_TYPE field holds the
--	type for this data attribute. The ATTRIBUTE_VALUE is used to store the
--	value of the data attribute. The ATTRIBUTE_CONTEXT is the context for that
--	value. For example, one could have a record like :
--	[BOOKMARK1, STRING, http://www.cnn.com, NULL].
--
--	5. The main out parameter for this API is x_return_status which returns
--	FND_API.G_RETURN_SUCCESS when the API completes successfully
--	FND_API.G_RETURN_UNEXPECTED when the API reaches a unxpected state
--	FND_API.G_RETURN_ERROR when the API hits an error
--
-- *****************************************************************************
--

PROCEDURE Update_Perz_Data
(	p_api_version_number	IN NUMBER,
  	p_init_msg_list		IN VARCHAR2 	:= FND_API.G_FALSE,
	p_commit		IN VARCHAR	:= FND_API.G_FALSE,

	p_application_id	IN NUMBER,
	p_profile_id        	IN NUMBER,

	p_perz_data_id      	IN NUMBER,
	p_perz_data_name        IN VARCHAR2,
	p_perz_data_type	IN VARCHAR2 := NULL,
	p_perz_data_desc	IN VARCHAR2,
	p_data_attrib_tbl	IN JTF_PERZ_DATA_PUB.DATA_ATTRIB_TBL_TYPE
				:= JTF_PERZ_DATA_PUB.G_MISS_DATA_ATTRIB_TBL,

	x_perz_data_id	    OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_msg_count	 OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_msg_data	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);
-- *****************************************************************************

-- Start of Comments
--
--	API name 	: Delete_Perz_Data
--	Type		: Public
--	Function	: Deletes a PerzData object
--
--	Paramaeters	:
--	IN	:
-- 		p_api_version_number	IN NUMBER	Required
--   		p_init_msg_list		IN VARCHAR2	Optional
-- 		p_commit		IN VARCHAR	Optional
--
-- 		p_application_id	IN NUMBER		Required
-- 		p_profile_id        	IN NUMBER		Required
-- 		p_perz_data_id          IN NUMBER		Required
--
-- OUT :
-- 		x_return_status	 OUT VARCHAR2
-- 		x_msg_count	 OUT NUMBER
-- 		x_msg_data	 OUT VARCHAR2
--
--
--
--	Version	:	Current version	1.0
--			Initial version 1.0
--
--	Notes:
--
-- *****************************************************************************
--
-- USAGE NOTES :
--
--	1. This API deletes a personalized data object from the personalization framework.
--	Of the input parameters p_profile_id (or the name of the profile p_profile_name)
--	the application id (p_application_id) and the data id p_perz_data_id are
--	required fields.
--
--	2. The out parameter for this API is x_return_status which returns
--	FND_API.G_RETURN_SUCCESS when the API completes successfully
--	FND_API.G_RETURN_UNEXPECTED when the API reaches a unxpected state
--	FND_API.G_RETURN_ERROR when the API hits an error
--
-- *****************************************************************************

PROCEDURE Delete_Perz_Data
(	p_api_version_number	IN	NUMBER,
  	p_init_msg_list		IN	VARCHAR2 	:= FND_API.G_FALSE,
	p_commit		IN VARCHAR		:= FND_API.G_FALSE,

	p_application_id	IN NUMBER,
	p_profile_id        	IN NUMBER,
	p_perz_data_id          IN NUMBER,

	x_return_status	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_msg_count	 OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_msg_data	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);

-- *****************************************************************************
-- *****************************************************************************
END  JTF_PERZ_DATA_PUB;

 

/
