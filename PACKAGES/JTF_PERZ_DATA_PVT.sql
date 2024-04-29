--------------------------------------------------------
--  DDL for Package JTF_PERZ_DATA_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_PERZ_DATA_PVT" AUTHID CURRENT_USER as
/* $Header: jtfzvpds.pls 120.2 2005/11/02 22:31:03 skothe ship $ */
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
--
--	09/20/99	SMATTEGU	Created
--
-- End of Comments
--
--
-- *****************************************************************************
--
--

PROCEDURE Save_Perz_Data
( 	p_api_version_number	IN	NUMBER,
  	p_init_msg_list		IN	VARCHAR2 	:= FND_API.G_FALSE,
	p_commit		IN VARCHAR		:= FND_API.G_FALSE,

	p_application_id	IN NUMBER,
	p_profile_id        IN NUMBER,
	p_profile_name      IN VARCHAR2,
	p_profile_type      IN VARCHAR2,
	p_profile_attrib    IN JTF_PERZ_PROFILE_PUB.PROFILE_ATTRIB_TBL_TYPE
			:= JTF_PERZ_PROFILE_PUB.G_MISS_PROFILE_ATTRIB_TBL,
	p_perz_data_id		IN NUMBER,
	p_perz_data_name          IN VARCHAR2,
	p_perz_data_type		IN VARCHAR2,
	p_perz_data_desc	IN VARCHAR2,
	p_data_attrib_tbl	IN JTF_PERZ_DATA_PUB.DATA_ATTRIB_TBL_TYPE
				:= JTF_PERZ_DATA_PUB.G_MISS_DATA_ATTRIB_TBL,

	x_perz_data_id	    OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_msg_count	 OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_msg_data	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);


-- *****************************************************************************
--

PROCEDURE Create_Perz_Data
( 	p_api_version_number	IN	NUMBER,
  	p_init_msg_list		IN	VARCHAR2 	:= FND_API.G_FALSE,
	p_commit		IN VARCHAR		:= FND_API.G_FALSE,

	p_application_id	IN NUMBER,
	p_profile_id            IN NUMBER,
	p_profile_name          IN VARCHAR2,
	p_perz_data_id		IN NUMBER,
    	p_perz_data_name             IN VARCHAR2,
	p_perz_data_type		IN VARCHAR2,
	p_perz_data_desc	IN VARCHAR2,
	p_data_attrib_tbl	IN JTF_PERZ_DATA_PUB.DATA_ATTRIB_TBL_TYPE
				:= JTF_PERZ_DATA_PUB.G_MISS_DATA_ATTRIB_TBL,

	x_perz_data_id	    OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_msg_count	 OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_msg_data	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);


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

PROCEDURE Get_Perz_Data_Summary
( 	p_api_version_number	IN	NUMBER,
  	p_init_msg_list		IN VARCHAR2 	:= FND_API.G_FALSE,

	p_application_id	IN NUMBER,
	p_profile_id       	IN	NUMBER,
	p_profile_name     	IN	VARCHAR2,
	p_perz_data_id          IN NUMBER,
	p_perz_data_name        IN VARCHAR2,
	p_perz_data_type	IN VARCHAR2 := NULL,

	x_data_out_tbl OUT NOCOPY /* file.sql.39 change */ JTF_PERZ_DATA_PUB.DATA_OUT_TBL_TYPE,

	x_return_status	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_msg_count	 OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_msg_data	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);
-- *****************************************************************************
--

PROCEDURE Update_Perz_Data
(	p_api_version_number	IN NUMBER,
  	p_init_msg_list		IN VARCHAR2 	:= FND_API.G_FALSE,
	p_commit		IN VARCHAR	:= FND_API.G_FALSE,

	p_application_id	IN NUMBER,
	p_profile_id   		IN NUMBER,

	p_perz_data_id          IN NUMBER,
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
--

PROCEDURE Delete_Perz_Data
(	p_api_version_number	IN	NUMBER,
  	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
	p_commit		IN VARCHAR	 := FND_API.G_FALSE,

	p_application_id	IN NUMBER,
	p_profile_id        	IN NUMBER,
	p_perz_data_id          IN NUMBER,

	x_return_status	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_msg_count	 OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_msg_data	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);

-- *****************************************************************************
-- *****************************************************************************
END  JTF_PERZ_DATA_PVT;

 

/
