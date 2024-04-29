--------------------------------------------------------
--  DDL for Package Body JTF_PERZ_QUERY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_PERZ_QUERY_PUB" AS
/* $Header: jtfzppqb.pls 120.2 2005/11/02 04:38:14 skothe ship $ */

-- NAME
--   Jtf_PERZ_QUERY_PUB

-- PURPOSE
--   Public API for saving, retrieving and updating personalized queries.
--
-- NOTES
--   This is a pulicly accessible pacakge.  It should be used by all
--   sources for saving, retrieving and updating personalized queries
--	 within the personalization framework.
-- HISTORY
--   04/18/2000	SMATTEGU	Created
--   06/26/2000 CCHANDRA        modified

-- *****************************************************************************
G_PKG_NAME  	CONSTANT VARCHAR2(30):='Jtf_Perz_Query_Pub';
G_FILE_NAME   	CONSTANT VARCHAR2(12):='jtfzppqb.pls';
-- *****************************************************************************


PROCEDURE Save_Perz_Query
( 	p_api_version_number	IN NUMBER,
  	p_init_msg_list		IN VARCHAR2 	:= Fnd_Api.G_FALSE,
	p_commit		IN VARCHAR2	:= Fnd_Api.G_FALSE,

	p_application_id	IN NUMBER,
	p_profile_id        IN NUMBER,
	p_profile_name      IN VARCHAR2,
	p_profile_type      IN VARCHAR2,
	p_Profile_Attrib    IN Jtf_Perz_Profile_Pub.PROFILE_ATTRIB_TBL_TYPE
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
    	p_query_raw_sql_rec	 IN Jtf_Perz_Query_Pub.QUERY_RAW_SQL_REC_TYPE
			:= Jtf_Perz_Query_Pub.G_MISS_QUERY_RAW_SQL_REC,

	x_query_id	    OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_msg_count	 OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_msg_data	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2

)IS
l_api_version_number	NUMBER 	:= p_api_version_number;
l_api_name		CONSTANT VARCHAR2(30)	:= 'Save Query';

BEGIN

       -- ******* Standard Begins ********

      -- Standard Start of API savepoint
      SAVEPOINT	SAVE_JTF_PERZ_QUERY_PUB;

      -- Standard call to check for call compatibility.
--       IF NOT FND_API.Compatible_API_Call (
--		l_api_version_number, p_api_version_number, l_api_name, G_PKG_NAME)
--       THEN
--           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
--       END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF Fnd_Api.to_Boolean( p_init_msg_list )
      THEN
          Fnd_Msg_Pub.initialize;
      END IF;

  	  -- Initialize API return status to success
      x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

Jtf_Perz_Query_Pvt.Save_Perz_Query

( 	p_api_version_number,
	p_init_msg_list,
	p_commit,
	p_application_id,
	p_profile_id,
	p_profile_name,
	p_profile_type,
	p_Profile_Attrib,
	p_query_id,
	p_query_name,
	p_query_type,
	p_query_desc,
	p_query_data_source,
	p_query_param_tbl,
    	p_query_order_by_tbl,
  	p_query_raw_sql_rec,
	x_query_id,
	x_return_status,
	x_msg_count,
	x_msg_data
);
	 -- ******** Standard Ends ***********
	  --
      -- End of API body.
      --
--	7.	Commit the whole thing

      -- Standard check of p_commit.
      IF Fnd_Api.To_Boolean ( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      -- Debug Message
      -- Standard call to get message count and if count is 1, get message info.
      Fnd_Msg_Pub.Count_And_Get
    	 (
	p_count         	=>      x_msg_count,
       	p_data          	=>      x_msg_data
    	 );


  EXCEPTION

      WHEN Fnd_Api.G_EXC_ERROR THEN

	  ROLLBACK TO SAVE_JTF_PERZ_QUERY_PUB;
	  x_return_status := Fnd_Api.G_RET_STS_ERROR ;

	  Fnd_Msg_Pub.Count_And_Get
    		( p_count         	=>      x_msg_count,
        	  p_data          	=>      x_msg_data
    		);

	  IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR )
	  THEN
    	      Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    	  END IF;

      WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN

	  ROLLBACK TO SAVE_JTF_PERZ_QUERY_PUB;
	  x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR ;

	  Fnd_Msg_Pub.Count_And_Get
    		( p_count         	=>      x_msg_count,
        	  p_data          	=>      x_msg_data
    		);

	  IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR )
	  THEN
    	      Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    	  END IF;

      WHEN OTHERS THEN

	  ROLLBACK TO SAVE_JTF_PERZ_QUERY_PUB;
	  x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR ;

	  Fnd_Msg_Pub.Count_And_Get
    		( p_count        	=>      x_msg_count,
        	  p_data          	=>      x_msg_data
    		);

	  IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR )
	  THEN
    	      Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    	  END IF;
END Save_Perz_Query;
-- ****************************************************************************
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
    	p_query_raw_sql_rec	 IN Jtf_Perz_Query_Pub.QUERY_RAW_SQL_REC_TYPE
			:= Jtf_Perz_Query_Pub.G_MISS_QUERY_RAW_SQL_REC,

	x_query_id             OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_msg_count	 OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_msg_data	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)IS

       -- ******* Local Variables ********

	l_api_version_number	NUMBER 	:= p_api_version_number;
     l_api_name		CONSTANT VARCHAR2(30)	:= 'Create Perz Query';

BEGIN

       -- ******* Standard Begins ********

      -- Standard Start of API savepoint
      SAVEPOINT	CREATE_JTF_PERZ_QUERY_PUB;

      -- Standard call to check for call compatibility.
--       IF NOT FND_API.Compatible_API_Call ( l_api_version_number, p_api_version_number, l_api_name, G_PKG_NAME)
--       THEN
--           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
--       END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF Fnd_Api.to_Boolean( p_init_msg_list )
      THEN
          Fnd_Msg_Pub.initialize;
      END IF;

  	  -- Initialize API return status to success
      x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

Jtf_Perz_Query_Pvt.Create_Perz_Query
( 	p_api_version_number,
  	p_init_msg_list,
	p_commit,
	p_application_id,
	p_profile_id,
	p_profile_name,
	p_query_id,
	p_query_name,
	p_query_type,
	p_query_desc,
	p_query_data_source,
	p_query_param_tbl,
	p_query_order_by_tbl,
	p_query_raw_sql_rec,
	x_query_id,
	x_return_status,
	x_msg_count,
	x_msg_data
);

	 -- ******** Standard Ends ***********
	  --
      -- End of API body.
      --
--	7.	Commit the whole thing

      -- Standard check of p_commit.
      IF Fnd_Api.To_Boolean ( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      -- Debug Message
      -- Standard call to get message count and if count is 1, get message info.
      Fnd_Msg_Pub.Count_And_Get
    	 (
	p_count         	=>      x_msg_count,
       	p_data          	=>      x_msg_data
    	 );


  EXCEPTION

      WHEN Fnd_Api.G_EXC_ERROR THEN

	  ROLLBACK TO CREATE_JTF_PERZ_QUERY_PUB;
	  x_return_status := Fnd_Api.G_RET_STS_ERROR ;

	  Fnd_Msg_Pub.Count_And_Get
    		( p_count         	=>      x_msg_count,
        	  p_data          	=>      x_msg_data
    		);

	  IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR )
	  THEN
    	      Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    	  END IF;

      WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN

	  ROLLBACK TO CREATE_JTF_PERZ_QUERY_PUB;
	  x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR ;

	  Fnd_Msg_Pub.Count_And_Get
    		( p_count         	=>      x_msg_count,
        	  p_data          	=>      x_msg_data
    		);

	  IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR )
	  THEN
    	      Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    	  END IF;

      WHEN OTHERS THEN

	  ROLLBACK TO CREATE_JTF_PERZ_QUERY_PUB;
	  x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR ;

	  Fnd_Msg_Pub.Count_And_Get
    		( p_count        	=>      x_msg_count,
        	  p_data          	=>      x_msg_data
    		);

	  IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR )
	  THEN
    	      Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    	  END IF;

END Create_Perz_Query;
-- ****************************************************************************

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
)IS
       -- ******* Local Variables ********

	l_api_version_number	NUMBER 	:= p_api_version_number;
     l_api_name		CONSTANT VARCHAR2(30)	:= 'Create Perz Query';

BEGIN

       -- ******* Standard Begins ********

      -- Standard call to check for call compatibility.
--       IF NOT FND_API.Compatible_API_Call ( l_api_version_number, p_api_version_number, l_api_name, G_PKG_NAME)
--       THEN
--           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
--       END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF Fnd_Api.to_Boolean( p_init_msg_list )
      THEN
          Fnd_Msg_Pub.initialize;
      END IF;

  	  -- Initialize API return status to success
      x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

Jtf_Perz_Query_Pvt.Get_Perz_Query
( 	p_api_version_number,
  	p_init_msg_list,

	p_application_id,
	p_profile_id,
	p_profile_name,

	p_query_id,
	p_query_name,
	p_query_type,

	x_query_id    ,
	x_query_name ,
	x_query_type,
	x_query_desc,
	x_query_data_source,

	x_query_param_tbl,
	x_query_order_by_tbl,
	x_query_raw_sql_rec,

	x_return_status,
	x_msg_count,
	x_msg_data
);

	 -- ******** Standard Ends ***********
	  --
      -- End of API body.

      -- Debug Message
      -- Standard call to get message count and if count is 1, get message info.
      Fnd_Msg_Pub.Count_And_Get
    	 (
	p_count         	=>      x_msg_count,
       	p_data          	=>      x_msg_data
    	 );


  EXCEPTION

      WHEN Fnd_Api.G_EXC_ERROR THEN

	  x_return_status := Fnd_Api.G_RET_STS_ERROR ;

	  Fnd_Msg_Pub.Count_And_Get
    		( p_count         	=>      x_msg_count,
        	  p_data          	=>      x_msg_data
    		);

	  IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR )
	  THEN
    	      Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    	  END IF;

      WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN

	  x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR ;

	  Fnd_Msg_Pub.Count_And_Get
    		( p_count         	=>      x_msg_count,
        	  p_data          	=>      x_msg_data
    		);

	  IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR )
	  THEN
    	      Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    	  END IF;

      WHEN OTHERS THEN


	  x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR ;

	  Fnd_Msg_Pub.Count_And_Get
    		( p_count        	=>      x_msg_count,
        	  p_data          	=>      x_msg_data
    		);

	  IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR )
	  THEN
    	      Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    	  END IF;


END Get_Perz_Query;

-- ****************************************************************************
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
)IS

       -- ******* Local Variables ********

	l_api_version_number	NUMBER 	:= p_api_version_number;
     l_api_name		CONSTANT VARCHAR2(30)	:= 'Create Perz Query';

BEGIN

       -- ******* Standard Begins ********

      -- Standard call to check for call compatibility.
--       IF NOT FND_API.Compatible_API_Call ( l_api_version_number, p_api_version_number, l_api_name, G_PKG_NAME)
--       THEN
--           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
--       END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF Fnd_Api.to_Boolean( p_init_msg_list )
      THEN
          Fnd_Msg_Pub.initialize;
      END IF;

  	  -- Initialize API return status to success
      x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

Jtf_Perz_Query_Pvt.Get_Perz_Query_Summary
( 	p_api_version_number,
  	p_init_msg_list,

	p_application_id,
	p_profile_id,
	p_profile_name,
	p_query_id,
	p_query_name,
	p_query_type,

	x_query_out_tbl,


	x_return_status,
	x_msg_count,
	x_msg_data
);


	 -- ******** Standard Ends ***********
	  --
      -- End of API body.

      -- Debug Message
      -- Standard call to get message count and if count is 1, get message info.
      Fnd_Msg_Pub.Count_And_Get
    	 (
	p_count         	=>      x_msg_count,
       	p_data          	=>      x_msg_data
    	 );


  EXCEPTION

      WHEN Fnd_Api.G_EXC_ERROR THEN

	  x_return_status := Fnd_Api.G_RET_STS_ERROR ;

	  Fnd_Msg_Pub.Count_And_Get
    		( p_count         	=>      x_msg_count,
        	  p_data          	=>      x_msg_data
    		);

	  IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR )
	  THEN
    	      Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    	  END IF;

      WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN

	  x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR ;

	  Fnd_Msg_Pub.Count_And_Get
    		( p_count         	=>      x_msg_count,
        	  p_data          	=>      x_msg_data
    		);

	  IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR )
	  THEN
    	      Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    	  END IF;

      WHEN OTHERS THEN


	  x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR ;

	  Fnd_Msg_Pub.Count_And_Get
    		( p_count        	=>      x_msg_count,
        	  p_data          	=>      x_msg_data
    		);

	  IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR )
	  THEN
    	      Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    	  END IF;
END Get_Perz_Query_Summary;
-- *****************************************************************************
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
	p_query_raw_sql_rec	 IN Jtf_Perz_Query_Pub.QUERY_RAW_SQL_REC_TYPE
			:= Jtf_Perz_Query_Pub.G_MISS_QUERY_RAW_SQL_REC,

	x_query_id          OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_msg_count	 OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_msg_data	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)IS

       -- ******* Local Variables ********

	l_api_version_number	NUMBER 	:= p_api_version_number;
     l_api_name		CONSTANT VARCHAR2(30)	:= 'Create Perz Query';

BEGIN

       -- ******* Standard Begins ********

      -- Standard Start of API savepoint
      SAVEPOINT	UPDATE_JTF_PERZ_QUERY_PUB;

      -- Standard call to check for call compatibility.
--       IF NOT FND_API.Compatible_API_Call ( l_api_version_number, p_api_version_number, l_api_name, G_PKG_NAME)
--       THEN
--           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
--       END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF Fnd_Api.to_Boolean( p_init_msg_list )
      THEN
          Fnd_Msg_Pub.initialize;
      END IF;

  	  -- Initialize API return status to success
      x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

Jtf_Perz_Query_Pvt.Update_Perz_Query
( 	p_api_version_number,
  	p_init_msg_list,
	p_commit,
	p_application_id,
	p_profile_id,
	p_query_id,
	p_query_name,
	p_query_type,
	p_query_desc,
	p_query_data_source,
	p_query_param_tbl,
	p_query_order_by_tbl,
	p_query_raw_sql_rec,
	x_query_id,
	x_return_status,
	x_msg_count,
	x_msg_data
);


	 -- ******** Standard Ends ***********
	  --
      -- End of API body.
      --
--	7.	Commit the whole thing

      -- Standard check of p_commit.
      IF Fnd_Api.To_Boolean ( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      -- Debug Message
      -- Standard call to get message count and if count is 1, get message info.
      Fnd_Msg_Pub.Count_And_Get
    	 (
	p_count         =>      x_msg_count,
       	p_data          =>      x_msg_data
    	 );


  EXCEPTION

      WHEN Fnd_Api.G_EXC_ERROR THEN

	  ROLLBACK TO UPDATE_JTF_PERZ_QUERY_PUB;
	  x_return_status := Fnd_Api.G_RET_STS_ERROR ;

	  Fnd_Msg_Pub.Count_And_Get
    		( p_count        =>      x_msg_count,
        	  p_data         =>      x_msg_data
    		);

	  IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR )
	  THEN
    	      Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    	  END IF;

      WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN

	  ROLLBACK TO UPDATE_JTF_PERZ_QUERY_PUB;
	  x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR ;

	  Fnd_Msg_Pub.Count_And_Get
    		( p_count        =>      x_msg_count,
        	  p_data         =>      x_msg_data
    		);

	  IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR )
	  THEN
    	      Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    	  END IF;

      WHEN OTHERS THEN

	  ROLLBACK TO UPDATE_JTF_PERZ_QUERY_PUB;
	  x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR ;

	  Fnd_Msg_Pub.Count_And_Get
    		( p_count        =>      x_msg_count,
        	  p_data         =>      x_msg_data
    		);

	  IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR )
	  THEN
    	      Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    	  END IF;


END Update_Perz_Query;
-- *****************************************************************************
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
)IS


       -- ******* Local Variables ********

	l_api_version_number	NUMBER 	:= p_api_version_number;
     l_api_name		CONSTANT VARCHAR2(30)	:= 'Create Perz Query';

BEGIN

       -- ******* Standard Begins ********

      -- Standard Start of API savepoint
      SAVEPOINT	DELETE_JTF_PERZ_QUERY_PUB;

      -- Standard call to check for call compatibility.
--       IF NOT FND_API.Compatible_API_Call ( l_api_version_number, p_api_version_number, l_api_name, G_PKG_NAME)
--       THEN
--           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
--       END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF Fnd_Api.to_Boolean( p_init_msg_list )
      THEN
          Fnd_Msg_Pub.initialize;
      END IF;

  	  -- Initialize API return status to success
      x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
Jtf_Perz_Query_Pvt.Delete_Perz_Query
( 	p_api_version_number,
  	p_init_msg_list,
	p_commit,
	p_application_id,
	p_profile_id,
	p_query_id,

	x_return_status,
	x_msg_count,
	x_msg_data
);


	 -- ******** Standard Ends ***********
	  --
      -- End of API body.
      --
--	7.	Commit the whole thing

      -- Standard check of p_commit.
      IF Fnd_Api.To_Boolean ( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      -- Debug Message
      -- Standard call to get message count and if count is 1, get message info.
      Fnd_Msg_Pub.Count_And_Get
    	 (
	p_count         =>      x_msg_count,
       	p_data          =>      x_msg_data
    	 );


  EXCEPTION

      WHEN Fnd_Api.G_EXC_ERROR THEN

	  ROLLBACK TO DELETE_JTF_PERZ_QUERY_PUB;
	  x_return_status := Fnd_Api.G_RET_STS_ERROR ;

	  Fnd_Msg_Pub.Count_And_Get
    		( p_count        =>      x_msg_count,
        	  p_data         =>      x_msg_data
    		);

	  IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR )
	  THEN
    	      Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    	  END IF;

      WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN

	  ROLLBACK TO DELETE_JTF_PERZ_QUERY_PUB;
	  x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR ;

	  Fnd_Msg_Pub.Count_And_Get
    		( p_count        =>      x_msg_count,
        	  p_data         =>      x_msg_data
    		);

	  IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR )
	  THEN
    	      Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    	  END IF;

      WHEN OTHERS THEN

	  ROLLBACK TO DELETE_JTF_PERZ_QUERY_PUB;
	  x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR ;

	  Fnd_Msg_Pub.Count_And_Get
    		( p_count        =>      x_msg_count,
        	  p_data         =>      x_msg_data
    		);

	  IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR )
	  THEN
    	      Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    	  END IF;



END Delete_Perz_Query;

END Jtf_Perz_Query_Pub;

/
