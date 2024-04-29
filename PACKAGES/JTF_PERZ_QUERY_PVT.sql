--------------------------------------------------------
--  DDL for Package JTF_PERZ_QUERY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_PERZ_QUERY_PVT" AUTHID CURRENT_USER AS
/* $Header: jtfzvpqs.pls 120.2 2005/11/02 22:46:59 skothe ship $ */
--
--
--
-- Start of Comments
--
-- NAME
--   JTF_PERZ_QUERY_PVT
--
-- PURPOSE
--   Public API for
--
-- NOTES
--   This is a pulicly accessible pacakge.  It should be used by all
--   sources for
--
-- HISTORY
--	04/18/2000	SMATTEGU	Created
--
-- End of Comments
--
--

-- ****************************************************************************
--******************************************************************************
--
--	APIS
--
--1. Create_Perz_Query
--2. Get_Perz_Query
--3. Get_Perz_Query_Summary
--4. Update_Perz_Query
--5. Delete_Perz_Query
--7. save_perz_query
-- ****************************************************************************
--******************************************************************************

-- Start of Comments
--
--	API name 	: Create_Perz_Query
--	Type		: Public
--	Function	: Create Query and associated field map with values
--
--	Paramaeters	:
--	IN		:
-- 		p_api_version_number	IN NUMBER 		Required
--   	p_init_msg_list		IN VARCHAR2		Optional
-- 		p_commit				IN VARCHAR2		Optional
--
-- 		p_application_id		IN NUMBER		Required
-- 		p_profile_id        	IN NUMBER		Optional
-- 		p_profile_name      	IN VARCHAR2		Optional
--
--		p_query_id			IN NUMBER Optional
-- 		p_query_name         	IN VARCHAR2		Required
-- 		p_query_type         	IN VARCHAR2		Optional
-- 		p_query_desc		 	IN VARCHAR2		Optional
-- 		p_query_data_source		IN VARCHAR2	Optional
--
--		p_query_param_tbl	 IN Jtf_Perz_Query_Pub.QUERY_PARAMETER_TBL_TYPE
--				 := Jtf_Perz_Query_Pub.G_MISS_QUERY_PARAMETER_TBL,
--    	p_query_order_by_tbl IN Jtf_Perz_Query_Pub.QUERY_ORDER_BY_TBL_TYPE
--				:= Jtf_Perz_Query_Pub.G_MISS_QUERY_ORDER_BY_TBL,
--    	p_query_raw_sql_rec	 IN Jtf_Perz_Query_Pub.QUERY_RAW_SQL_REC_TYPE
--

-- OUT  :
--		x_query_id	   	 OUT  NUMBER
-- 		x_return_status	 OUT 	VARCHAR2
-- 		x_msg_count	 OUT  	NUMBER
-- 		x_msg_data	 OUT  	VARCHAR2
--
--
--	Version	:	Current version	1.0
--		 	Initial version 	1.0
--
--	Notes:

--******************************************************************************
PROCEDURE Create_Perz_Query
( 	p_api_version_number	IN NUMBER,
  	p_init_msg_list		IN VARCHAR2 	:= Fnd_Api.G_FALSE,
	p_commit		IN VARCHAR2	:= Fnd_Api.G_FALSE,

	p_application_id	IN NUMBER,
	p_profile_id		IN NUMBER,
	p_profile_name		IN VARCHAR2,

	p_query_id		IN NUMBER,
	p_query_name		IN VARCHAR2,
	p_query_type		IN VARCHAR2,
	p_query_desc		IN VARCHAR2,
	p_query_data_source	IN VARCHAR2,

	p_query_param_tbl	IN Jtf_Perz_Query_Pub.QUERY_PARAMETER_TBL_TYPE
			:= Jtf_Perz_Query_Pub.G_MISS_QUERY_PARAMETER_TBL,
    	p_query_order_by_tbl 	IN Jtf_Perz_Query_Pub.QUERY_ORDER_BY_TBL_TYPE
			:= Jtf_Perz_Query_Pub.G_MISS_QUERY_ORDER_BY_TBL,
    	p_query_raw_sql_rec	 IN Jtf_Perz_Query_Pub.QUERY_RAW_SQL_REC_TYPE,

	x_query_id             OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_msg_count	 OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_msg_data	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);


-- ****************************************************************************
--******************************************************************************


-- Start of Comments
--
--	API name 	: Get_Perz_Query
--	Type		: Public
--	Function	: Get personalized query from query store
--
--	Paramaeters	:
--	IN	:
-- 		p_api_version_number	IN NUMBER 		Required
--   		p_init_msg_list		IN VARCHAR2		Optional
--
-- 		p_application_id	IN NUMBER		Required
-- 		p_profile_id        	IN NUMBER		Optional
-- 		p_profile_name      	IN VARCHAR2		Optional
--
--		p_query_id        	IN NUMBER		Optional
-- 		p_query_name         	IN VARCHAR2(100)	Optional
-- 		p_query_type         	IN VARCHAR2		Optional

-- OUT  :
--
--		x_query_id	 OUT  NUMBER,
--		x_query_name	 OUT  VARCHAR2(100),
--		x_query_type	 OUT  VARCHAR2,
--		x_query_desc	    OUT VARCHAR2,

--		x_query_param_tbl  OUT Jtf_Perz_Query_Pub.QUERY_PARAMETER_TBL_TYPE,
--		x_query_order_by_tbl OUT  Jtf_Perz_Query_Pub.QUERY_ORDER_BY_TBL_TYPE,
--		x_query_raw_sql_rec OUT  Jtf_Perz_Query_Pub.QUERY_RAW_SQL_REC_TYPE,

-- 		x_return_status	 OUT  VARCHAR2
-- 		x_msg_count	 OUT  NUMBER
-- 		x_msg_data	 OUT  VARCHAR2
--
--	Version	:Current version	1.0
--		Initial version 	1.0
--
--	Notes:	Sending in IDs will greatly improve performance.
--
--******************************************************************************



PROCEDURE Get_Perz_Query
( 	p_api_version_number	IN NUMBER,
	p_init_msg_list		IN VARCHAR2 	:= Fnd_Api.G_FALSE,

	p_application_id	IN NUMBER,
	p_profile_id           IN NUMBER,
	p_profile_name         IN VARCHAR2,

	p_query_id             IN NUMBER,
	p_query_name           IN VARCHAR2,
	p_query_type         IN VARCHAR2,

	x_query_id             OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_query_name           OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_query_type	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_query_desc		   OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_query_data_source    OUT NOCOPY /* file.sql.39 change */ VARCHAR2,

	x_query_param_tbl OUT NOCOPY /* file.sql.39 change */ Jtf_Perz_Query_Pub.QUERY_PARAMETER_TBL_TYPE,
    x_query_order_by_tbl   OUT NOCOPY /* file.sql.39 change */ Jtf_Perz_Query_Pub.QUERY_ORDER_BY_TBL_TYPE,
    x_query_raw_sql_rec	   OUT NOCOPY /* file.sql.39 change */ Jtf_Perz_Query_Pub.QUERY_RAW_SQL_REC_TYPE,

	x_return_status	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_msg_count	 OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_msg_data	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);

-- ****************************************************************************
--******************************************************************************


PROCEDURE Get_Perz_Query_Summary
( 	p_api_version_number   IN NUMBER,
	p_init_msg_list		IN VARCHAR2 	:= Fnd_Api.G_FALSE,

	p_application_id	IN NUMBER,
	p_profile_id           IN NUMBER,
	p_profile_name         IN VARCHAR2,

	p_query_id             IN NUMBER,
	p_query_name           IN VARCHAR2,
	p_query_type         IN VARCHAR2,

    x_query_out_tbl	   OUT NOCOPY /* file.sql.39 change */ Jtf_Perz_Query_Pub.QUERY_OUT_TBL_TYPE,

	x_return_status	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_msg_count	 OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_msg_data	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);

-- ****************************************************************************
--******************************************************************************

-- Start of Comments
--
--	API name 	: Update_Perz_Query
--	Type		: Public
--	Function	: Updates the personalized query header and associated field-map
--			  	for a given query and profile.
--
--	Paramaeters	:
--	IN		:
-- 		p_api_version_number	IN NUMBER	Required
--   		p_init_msg_list		IN VARCHAR2	Optional
-- 		p_commit		IN VARCHAR2	Optional
--
-- 		p_application_id	IN NUMBER	Required
-- 		p_profile_id        	IN NUMBER	Required
--
-- 		p_query_id	   	IN NUMBER	Optional
-- 		p_query_name         	IN VARCHAR2	Required
-- 		p_query_type         IN VARCHAR2		Optional
-- 		p_query_desc	        IN VARCHAR2	Optional
-- 		p_query_data_source	IN VARCHAR2	Optional
--
--	p_query_param_tbl	 IN Jtf_Perz_Query_Pub.QUERY_PARAMETER_TBL_TYPE
--				 := Jtf_Perz_Query_Pub.G_MISS_QUERY_PARAMETER_TBL,
--    p_query_order_by_tbl IN Jtf_Perz_Query_Pub.QUERY_ORDER_BY_TBL_TYPE
--				:= Jtf_Perz_Query_Pub.G_MISS_QUERY_ORDER_BY_TBL,
--    p_query_raw_sql_rec	 IN Jtf_Perz_Query_Pub.QUERY_RAW_SQL_REC_TYPE
--
-- OUT 	:
--		x_query_id	    OUT  NUMBER
-- 		x_return_status	 OUT VARCHAR2
-- 		x_msg_count	 OUT  NUMBER
-- 		x_msg_data	 OUT  VARCHAR2
--
--	Version	:Current version	1.0
--		Initial version 	1.0
--
--	Notes:
--
--
--******************************************************************************


PROCEDURE Update_Perz_Query
(	p_api_version_number	IN	NUMBER,
  	p_init_msg_list		IN	VARCHAR2 	:= Fnd_Api.G_FALSE,
	p_commit		IN VARCHAR2		:= Fnd_Api.G_FALSE,

	p_application_id	IN NUMBER,
	p_profile_id        IN NUMBER,

	p_query_id           IN NUMBER,
	p_query_name         IN VARCHAR2,
	p_query_type         IN VARCHAR2,
	p_query_desc		 IN VARCHAR2,
	p_query_data_source  IN VARCHAR2,

	p_query_param_tbl	 IN Jtf_Perz_Query_Pub.QUERY_PARAMETER_TBL_TYPE
				 := Jtf_Perz_Query_Pub.G_MISS_QUERY_PARAMETER_TBL,
    p_query_order_by_tbl IN Jtf_Perz_Query_Pub.QUERY_ORDER_BY_TBL_TYPE
				:= Jtf_Perz_Query_Pub.G_MISS_QUERY_ORDER_BY_TBL,
    p_query_raw_sql_rec	 IN Jtf_Perz_Query_Pub.QUERY_RAW_SQL_REC_TYPE ,

	x_query_id          OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_msg_count	 OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_msg_data	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);

-- ****************************************************************************
--******************************************************************************

-- Start of Comments
--
--	API name 	: Delete_Perz_Query
--	Type		: Public
--	Function	: Deletes a personalized query in the personalization framework.
--
--	Paramaeters	:
--	IN	:
-- 		p_api_version_number	IN NUMBER	Required
--   		p_init_msg_list			IN VARCHAR2	Optional
-- 		p_commit				IN VARCHAR2	Optional
--
-- 		p_application_id	IN NUMBER		Required
-- 		p_profile_id        IN NUMBER		Required
-- 		p_query_id           IN NUMBER		Required
--
-- OUT  :
-- 		x_return_status	 OUT  VARCHAR2
-- 		x_msg_count	 OUT  NUMBER
-- 		x_msg_data	 OUT  VARCHAR2
--
--	Version	:Current version	1.0
--		Initial version 1.0
--
--	Notes:
--
--******************************************************************************



PROCEDURE Delete_Perz_Query
(	p_api_version_number	IN	NUMBER,
  	p_init_msg_list		IN	VARCHAR2 	:= Fnd_Api.G_FALSE,
	p_commit		IN VARCHAR2		:= Fnd_Api.G_FALSE,

	p_application_id	IN NUMBER,
	p_profile_id        IN NUMBER,
	p_query_id            IN NUMBER,

	x_return_status	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_msg_count	 OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_msg_data	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);

-- ****************************************************************************
--******************************************************************************

PROCEDURE Save_Perz_Query
( 	p_api_version_number	IN NUMBER,
  	p_init_msg_list		IN VARCHAR2 	:= Fnd_Api.G_FALSE,
	p_commit		IN VARCHAR2	:= Fnd_Api.G_FALSE,
	p_application_id	IN NUMBER,
	p_profile_id        	IN NUMBER,
	p_profile_name      	IN VARCHAR2,
	p_profile_type      	IN VARCHAR2,
	p_Profile_Attrib    	IN Jtf_Perz_Profile_Pub.PROFILE_ATTRIB_TBL_TYPE
			:= Jtf_Perz_Profile_Pub.G_MISS_PROFILE_ATTRIB_TBL,
	p_query_id		IN NUMBER,
	p_query_name         	IN VARCHAR2,
	p_query_type		IN VARCHAR2,
	p_query_desc		IN VARCHAR2,
	p_query_data_source  	IN VARCHAR2,

	p_query_param_tbl	IN Jtf_Perz_Query_Pub.QUERY_PARAMETER_TBL_TYPE
			:= Jtf_Perz_Query_Pub.G_MISS_QUERY_PARAMETER_TBL,
    	p_query_order_by_tbl 	IN Jtf_Perz_Query_Pub.QUERY_ORDER_BY_TBL_TYPE
			:= Jtf_Perz_Query_Pub.G_MISS_QUERY_ORDER_BY_TBL,
    	p_query_raw_sql_rec	 IN Jtf_Perz_Query_Pub.QUERY_RAW_SQL_REC_TYPE,

	x_query_id	    OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_msg_count	 OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_msg_data	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);
-- ****************************************************************************
--******************************************************************************
END  JTF_PERZ_QUERY_PVT;

 

/
