--------------------------------------------------------
--  DDL for Package JTF_PERZ_DDF_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_PERZ_DDF_PVT" AUTHID CURRENT_USER as
/* $Header: jtfzvdds.pls 120.2 2005/11/02 22:19:22 skothe ship $ */
--
--
-- Start of Comments
--
-- NAME
--   jtf_perz_ddf_pvt
--
-- PURPOSE
--   Public API for creating, getting, updating and deleteing data defaults
-- 	 in the Personalization Framework.
--
-- NOTES
--   This is a pulicly accessible pacakge.  It should be used by all
--   sources for creating, getting, updating and deleting personalized data defaults
-- 	 in the Personalization Framework.
--
-- HISTORY
--	09/10/99	SMATTEGU	Created and documented the following
--					save_data_default()
--					create_data_default()
--					get_data_default()
--					update_data_default()
--					delete_data_default()
--
-- End of Comments
--
--
-- *****************************************************************************

-- Start of Comments
--
--	API name 	: save_data_default
--	Type		: Public
--	Function	: Create or update if exists, a personalized data default
--
--	Parameters	:
--	IN		:
--			p_api_version_number	IN NUMBER	Required
--   			p_init_msg_list		IN VARCHAR2	Optional
-- 			p_commit		IN VARCHAR	Optional
--
-- 			p_application_id	IN NUMBER	Required

-- 			p_profile_id		IN NUMBER	Required
-- 			p_profile_name		IN VARCHAR2	Optional
-- 			p_profile_type		IN VARCHAR2	Optional
-- 			p_profile_attrib	IN JTF_PERZ_PROFILE_PUB.PROFILE_ATTRIB_TBL_TYPE Optional
--
-- 			p_perz_ddf_id		IN NUMBER	Optional
-- 			p_perz_ddf_context	IN VARCHAR2	Required
-- 			p_gui_object_name	IN VARCHAR2	Required
-- 			p_gui_object_id		IN NUMBER	Optional
-- 			p_ddf_value		IN VARCHAR2	Required
-- 			p_ddf_value_type	IN VARCHAR2	Required
--
-- OUT 	:
--			x_perz_ddf_id	    OUT  NUMBER
-- 			x_return_status	 OUT  VARCHAR2
-- 			x_msg_count	 OUT  NUMBER
-- 			x_msg_data	 OUT  VARCHAR2
--
--
--	Version	:	Current version	1.0
--			Initial version 1.0
--
--	Notes:
--		Data Default is used a single value tied to any given GUI object
--		This Association can be identified by ddf_name. The same GUI object
--		can have different values in different (profile_id, application_id)
--		combination.
--		The perz_ddf_context is used to store under what context the GUI
--		object will have the assigned value for any given profile_id
--		application id combination
--
--
-- *****************************************************************************
--
-- USAGE NOTES :
--
--	1. This API creates or updates if it already exists, a Personalized data
--		default in the personalization framework.
--	2. Of the input parameters p_profile_id (or the name of the profile
--		p_profile_name p_profile_type and its attributes p_Profile_Attrib)
--		is a required field.
--	3. The other required fields are :
--	  3.1	p_application_id (the application id of the caller)
--	  3.2	p_perz_ddf_context
--		This field has to be unique for that profile id and application id, or
--		the API will return an error. This field also has to be made of
--		characters with no spaces (underscores allowed).
--	  3.3	p_gui_object_name (Gui object to which the value is associated with)
--	4. Rest of the parameters are optional. p_perz_ddf_id, p_gui_object_id
--		if available, may be provided.
--	5. p_ddf_value will hold the personalized value for that ddf_name.
--	   p_ddf_value_type will hold the data type that of the value.
--
--
--	6. The main out parameter for this API is x_perz_ddf_id.
--	   This returns the data default id for the saved data default.
--	   Another important out parameter is x_return_status which returns
--		FND_API.G_RETURN_SUCCESS when the API completes successfully
--		FND_API.G_RETURN_UNEXPECTED when the API reaches a unxpected state
--		FND_API.G_RETURN_ERROR when the API hits an error
--
-- *****************************************************************************
--
PROCEDURE save_data_default
( 	p_api_version_number	IN	NUMBER,
  	p_init_msg_list		IN	VARCHAR2 	:= FND_API.G_FALSE,
	p_commit		IN 	VARCHAR		:= FND_API.G_FALSE,

	p_application_id	IN 	NUMBER,

	p_profile_id        	IN 	NUMBER,
	p_profile_name      	IN 	VARCHAR2,
	p_profile_type      	IN 	VARCHAR2,
	p_profile_attrib    	IN JTF_PERZ_PROFILE_PUB.PROFILE_ATTRIB_TBL_TYPE
				:= JTF_PERZ_PROFILE_PUB.G_MISS_PROFILE_ATTRIB_TBL,

	p_perz_ddf_id		IN NUMBER	,
	p_perz_ddf_context	IN VARCHAR2	,

	p_gui_object_name	IN VARCHAR2	,
	p_gui_object_id		IN NUMBER	,
	p_ddf_value		IN VARCHAR2	,
	p_ddf_value_type	IN VARCHAR2	,

	x_perz_ddf_id	    OUT NOCOPY /* file.sql.39 change */ NUMBER,

	x_return_status	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_msg_count	 OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_msg_data	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);

-- *****************************************************************************

-- Start of Comments
--
--	API name 	: create_data_default
--	Type		: Public
--	Function	: Create a data default for a given profile and application id.
--
--	Parameters	:
--	IN		:
--			p_api_version_number	IN NUMBER	Required
--   			p_init_msg_list		IN VARCHAR2	Optional
-- 			p_commit		IN VARCHAR	Optional
--
-- 			p_application_id	IN NUMBER	Required

-- 			p_profile_id		IN NUMBER	Required
-- 			p_profile_name		IN VARCHAR2	Optional
--
-- 			p_perz_ddf_id		IN NUMBER	Optional
-- 			p_perz_ddf_context	IN VARCHAR2	Required
-- 			p_gui_object_name	IN VARCHAR2	Required
-- 			p_gui_object_id		IN NUMBER	Optional
-- 			p_ddf_value		IN VARCHAR2	Required
-- 			p_ddf_value_type	IN VARCHAR2	Required
--
-- OUT  	:
--			x_perz_ddf_id	    OUT  NUMBER
-- 			x_return_status	 OUT  VARCHAR2
-- 			x_msg_count	 OUT NUMBER
-- 			x_msg_data	 OUT VARCHAR2
--
--
--	Version	:	Current version	1.0
--			Initial version 1.0
--
--	Notes:
--		This API is used to create a Data Default. A data default is
--		associated with a GUI object, default value and type.
--		The same GUI object can have different values in different
--		(profile_id, application_id, ddf_context) combination.
--
--		Also, for the same profile, applicatin and contgext,
--		different data defaults can be associated with the same
--		GUI object, if one GUI object has GUI Object ID and other
--		does not. If this is not allowed, this can be fixed by
--		creating the unique keyindex on profile id, application id,
--		gui object name
--
-- *****************************************************************************
--
-- USAGE NOTES :
--
--	1. This API creates a Personalized data default in the personalization
--		framework.
--	2. Of the input parameters p_profile_id (or the name) is a required field.
--	3. The other required fields are :
--	  3.1	p_application_id (the application id of the caller)
--	  3.2	p_perz_ddf_context
--		This field has to be unique for that profile id and application id,
--		or the API will return an error. This field also has to be made of
--		characters with no spaces (underscores allowed).
--	  3.3	p_gui_object_name (to which the value is associated with)
--	4. Rest of the parameters are optional. p_perz_ddf_id, p_gui_object_id
--		if available, may be provided.
--	5. p_ddf_value will hold the personalized value for that ddf_name.
--	   p_ddf_value_type will hold the data type that of the value.
--
--
--	6. The main out parameter for this API is x_perz_ddf_id.
--	   This returns the data default id for the created data default object.
--	   Another important out parameter is x_return_status which returns
--		FND_API.G_RETURN_SUCCESS when the API completes successfully
--		FND_API.G_RETURN_UNEXPECTED when the API reaches a unxpected state
--		FND_API.G_RETURN_ERROR when the API hits an error
--
-- *****************************************************************************

PROCEDURE create_data_default
(
	p_api_version_number	IN NUMBER,
	p_init_msg_list		IN VARCHAR2,
	p_commit		IN VARCHAR,

	p_application_id	IN NUMBER,

	p_profile_id		IN NUMBER,
	p_profile_name		IN VARCHAR2,

	p_perz_ddf_id		IN NUMBER,
	p_perz_ddf_context	IN VARCHAR2,

	p_gui_object_name	IN VARCHAR2,
	p_gui_object_id		IN NUMBER,
	p_ddf_value		IN VARCHAR2,
	p_ddf_value_type	IN VARCHAR2,

	x_perz_ddf_id	    OUT NOCOPY /* file.sql.39 change */ NUMBER,

	x_return_status	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_msg_count	 OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_msg_data	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);

-- *****************************************************************************
-- Start of Comments
--
--	API name 	: get_data_default
--	Type		: Public
--	Function	: Get personalized data default object, and associated
--				values for a given personalized data object and
--				profile and app id.
--
--	Parameters	:
--	IN		:
--			p_api_version_number	IN NUMBER	Required
--   			p_init_msg_list		IN VARCHAR2	Optional
--
-- 			p_application_id	IN NUMBER	Required

-- 			p_profile_id		IN NUMBER	Required
-- 			p_profile_name		IN VARCHAR2	Optional
--
-- 			p_perz_ddf_id		IN NUMBER	Optional
-- 			p_perz_ddf_context	IN VARCHAR2	Required
-- 			p_gui_object_name	IN VARCHAR2	Required
-- 			p_gui_object_id		IN NUMBER	Optional
-- 			p_ddf_value		IN VARCHAR2	Required
-- 			p_ddf_value_type	IN VARCHAR2	Required
--
-- OUT  	:
--			x_ddf_out_tbl	    OUT JTF_PERZ_DDF_PUB.DDF_OUT_TBL_TYPE
-- 			x_return_status	 OUT VARCHAR2
-- 			x_msg_count	 OUT  NUMBER
-- 			x_msg_data	 OUT VARCHAR2
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
--	1. This API gets a Personalized data default from the personalization
--		framework.
--	2. Of the input parameters p_profile_id (or the name) is a required field.
--	3. The other required fields are :
--	  3.1	p_application_id (the application id of the caller)
--	  3.2	p_perz_ddf_context
--	4. Rest of the parameters are optional. p_perz_ddf_id, p_gui_object_id
--		if available, may be provided.
--
--	5. The main out parameter is p_ddf_out_tbl which holds all the details
--		of the data default object(s)
--
--	6. Another important out parameter is x_return_status which returns
--		FND_API.G_RETURN_SUCCESS when the API completes successfully
--		FND_API.G_RETURN_UNEXPECTED when the API reaches a unxpected state
--		FND_API.G_RETURN_ERROR when the API hits an error
--
--	This API can be used in two ways,
--	1. To get the table of DDF by supplying profile id/name, application_id,
--		gui_object_id/name and dddf_context
--		(In this case out put table will have only one row) OR
--	2. To get the table of DDF by supplying profile id/name, application_id,
--		gui_object_id/name .
-- *****************************************************************************

PROCEDURE get_data_default
( 	p_api_version_number	IN	NUMBER,
	p_init_msg_list		IN VARCHAR2,

	p_application_id	IN NUMBER,

	p_profile_id		IN NUMBER,
	p_profile_name		IN VARCHAR2,

	p_perz_ddf_id		IN NUMBER,
	p_perz_ddf_context	IN VARCHAR2,

	p_gui_object_name	IN VARCHAR2,
	p_gui_object_id		IN NUMBER,

	p_ddf_value		IN VARCHAR2,
	p_ddf_value_type	IN VARCHAR2,

	x_ddf_out_tbl	    OUT NOCOPY /* file.sql.39 change */ jtf_perz_ddf_pub.DDF_OUT_TBL_TYPE,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_msg_count	 OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_msg_data	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);

-- *****************************************************************************


-- Start of Comments
--
--	API name 	: update_data_default
--	Type		: Public
--	Function	: Update data default object in the Framework.
--
--	Parameters	:
--	IN		:
--			p_api_version_number	IN NUMBER	Required
--   			p_init_msg_list		IN VARCHAR2	Optional
-- 			p_commit		IN VARCHAR	Optional
--
-- 			p_application_id	IN NUMBER	Optional

-- 			p_profile_id		IN NUMBER	Optional
-- 			p_profile_name		IN VARCHAR2	Optional
--
-- 			p_perz_ddf_id		IN NUMBER	Optional
-- 			p_perz_ddf_context	IN VARCHAR2	Required
-- 			p_gui_object_name	IN VARCHAR2	Required
-- 			p_gui_object_id		IN NUMBER	Optional
-- 			p_ddf_value		IN VARCHAR2	Required
-- 			p_ddf_value_type	IN VARCHAR2	Required
--
-- OUT 	:
--			x_perz_ddf_id	    OUT  NUMBER
-- 			x_return_status	 OUT  VARCHAR2
-- 			x_msg_count	 OUT  NUMBER
-- 			x_msg_data	 OUT VARCHAR2
--
--
--	Version	:	Current version	1.0
--			Initial version 1.0
--
--	Notes:
--		For a given data default object, this API only updates
--		associated value and type fields only.
--
--
-- *****************************************************************************
--
-- USAGE NOTES :
--
--	1. This API updates a Personalized data default in the personalization
--		framework.
--	2. The required fields are :
--	  3.1	p_perz_ddf_context
--	  3.2	p_gui_object_name (to which the value is associated with)
--	4. Rest of the parameters are optional. Wherever available ids may be
--		provided.
--	5. p_ddf_value will hold the personalized value for that ddf_name.
--	   p_ddf_value_type will hold the data type that of the value.
--
--	6. The main out  parameter for this API is x_perz_ddf_id.
--	   This returns the data default id for the created data default object.
--	   Another important out parameter is x_return_status which returns
--		FND_API.G_RETURN_SUCCESS when the API completes successfully
--		FND_API.G_RETURN_UNEXPECTED when the API reaches a unxpected state
--		FND_API.G_RETURN_ERROR when the API hits an error
--
-- *****************************************************************************

PROCEDURE update_data_default
(
	p_api_version_number	IN NUMBER,
	p_init_msg_list		IN VARCHAR2,
	p_commit		IN VARCHAR,

	p_application_id	IN NUMBER,

	p_profile_id		IN NUMBER,
	p_profile_name		IN VARCHAR2,

	p_perz_ddf_id		IN NUMBER,
	p_perz_ddf_context	IN VARCHAR2,

	p_gui_object_name	IN VARCHAR2,
	p_gui_object_id		IN NUMBER,
	p_ddf_value		IN VARCHAR2,
	p_ddf_value_type	IN VARCHAR2,

	x_perz_ddf_id	    OUT NOCOPY /* file.sql.39 change */ NUMBER,

	x_return_status	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_msg_count	 OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_msg_data	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);
-- *****************************************************************************

-- Start of Comments
--
--	API name 	: delete_data_default
--	Type		: Public
--	Function	: Deletes a data dafault object in the framework.
--
--	Paramaeters	:
--	IN		:
-- 			p_api_version_number	IN NUMBER	Required
--   			p_init_msg_list		IN VARCHAR2	Optional
-- 			p_commit		IN VARCHAR	Optional
--
-- 			p_application_id	IN NUMBER	Required
-- 			p_profile_id        	IN NUMBER	Required
-- 			p_perz_ddf_id           IN NUMBER	Required
--
-- OUT  	:
-- 			x_return_status	 OUT VARCHAR2
-- 			x_msg_count	 OUT NUMBER
-- 			x_msg_data	 OUT VARCHAR2
--
--
--
--	Version	:	Current version	1.0
--			Initial version 1.0
--
--	Notes:
--		This API accepts only the ids - profile id, application id
--		and perz_ddf_id to delete the data default object.
--
-- *****************************************************************************
--
-- USAGE NOTES :
--
--	1. This API deletes the data default object from the framework.
--	2. The required fields are:
--		application_id
--		profile_id
--		perz_ddf_id
--	3. The out parameter for this API is x_return_status which returns
--	FND_API.G_RETURN_SUCCESS when the API completes successfully
--	FND_API.G_RETURN_UNEXPECTED when the API reaches a unxpected state
--	FND_API.G_RETURN_ERROR when the API hits an error
--
-- *****************************************************************************

PROCEDURE delete_data_default
(	p_api_version_number	IN	NUMBER,
  	p_init_msg_list		IN	VARCHAR2 	:= FND_API.G_FALSE,
	p_commit		IN 	VARCHAR		:= FND_API.G_FALSE,

	p_application_id	IN NUMBER,
	p_profile_id        	IN NUMBER,
	p_perz_ddf_id           IN NUMBER,

	x_return_status	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_msg_count	 OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_msg_data	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);

END  jtf_perz_ddf_pvt;

 

/
