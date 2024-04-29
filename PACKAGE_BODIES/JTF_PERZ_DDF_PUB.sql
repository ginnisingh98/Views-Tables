--------------------------------------------------------
--  DDL for Package Body JTF_PERZ_DDF_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_PERZ_DDF_PUB" as
/* $Header: jtfzpddb.pls 120.2 2005/11/02 03:03:43 skothe ship $ */
--
--
-- Start of Comments
--
-- NAME
--   jtf_perz_ddf_pub
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
--	09/14/99	SMATTEGU	Created and documented the following
--					save_data_default()
--					create_data_default()
--					get_data_default()
--					update_data_default()
--					delete_data_default()
--
-- End of Comments
--
G_PKG_NAME  	CONSTANT VARCHAR2(30):='JTF_PERZ_DDF_PUB';
G_FILE_NAME   	CONSTANT VARCHAR2(12):='jtfppddb.pls';


-- ****************************************************************************

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
)IS

      -- ******* save_data_default Local Variables ********
--	Following variables are needed to adhere to standards
	l_api_version_number	NUMBER 	:= p_api_version_number;
     	l_api_name		CONSTANT VARCHAR2(30)	:= 'save_data_default';
--	Following variables are needed for implementation
	--l_return_status    	VARCHAR2(240) := FND_API.G_RET_STS_SUCCESS;

BEGIN


-- ******* save_data_default Standard Begins ********

      -- Standard Start of API savepoint
      SAVEPOINT	SAVE_PERZ_DDF_PUB;

      -- Standard call to check for call compatibility.
--       IF NOT FND_API.Compatible_API_Call (
--		l_api_version_number,
--		p_api_version_number,
--		l_api_name,
--		G_PKG_NAME)
--       THEN
--           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
--       END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

  	  -- Initialize API return status to success
      x_return_status := FND_API.G_RET_STS_SUCCESS;

JTF_PERZ_DDF_PVT.save_data_default
( 	p_api_version_number	,
  	p_init_msg_list		,
	p_commit		,

	p_application_id	,

	p_profile_id        	,
	p_profile_name      	,
	p_profile_type      	,
	p_profile_attrib    	,

	p_perz_ddf_id		,
	p_perz_ddf_context	,

	p_gui_object_name	,
	p_gui_object_id		,
	p_ddf_value		,
	p_ddf_value_type	,

	x_perz_ddf_id	   	,

	x_return_status		,
	x_msg_count		,
	x_msg_data
);



	 -- ******** Standard Ends ***********
	  --
      -- End of API body.
      --
--	7.	Commit the whole thing

      -- Standard check of p_commit.
      IF FND_API.To_Boolean ( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      -- Debug Message
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
    	 (
	p_count         	=>      x_msg_count,
       	p_data          	=>      x_msg_data
    	 );


  EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN

	  ROLLBACK TO SAVE_PERZ_DDF_PUB;
	  x_return_status := FND_API.G_RET_STS_ERROR ;

	  FND_MSG_PUB.Count_And_Get
    		( p_count         	=>      x_msg_count,
        	  p_data          	=>      x_msg_data
    		);

	  IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
	  THEN
    	      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    	  END IF;

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	  ROLLBACK TO SAVE_PERZ_DDF_PUB;
	  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	  FND_MSG_PUB.Count_And_Get
    		( p_count         	=>      x_msg_count,
        	  p_data          	=>      x_msg_data
    		);

	  IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
	  THEN
    	      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    	  END IF;

      WHEN OTHERS THEN

	  ROLLBACK TO SAVE_PERZ_DDF_PUB;
	  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	  FND_MSG_PUB.Count_And_Get
    		( p_count        	=>      x_msg_count,
        	  p_data          	=>      x_msg_data
    		);

	  IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
	  THEN
    	      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    	  END IF;

END save_data_default;
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
)IS
      -- ******* save_data_default Local Variables ********
--	Following variables are needed to adhere to standards
	l_api_version_number	NUMBER 	:= p_api_version_number;
     	l_api_name		CONSTANT VARCHAR2(30)	:= 'save_data_default';
--	Following variables are needed for implementation
	--l_return_status    	VARCHAR2(240) := FND_API.G_RET_STS_SUCCESS;

BEGIN


-- ******* save_data_default Standard Begins ********

      -- Standard Start of API savepoint
      SAVEPOINT	CREATE_PERZ_DDF_PUB;

      -- Standard call to check for call compatibility.
--       IF NOT FND_API.Compatible_API_Call (
--		l_api_version_number,
--		p_api_version_number,
--		l_api_name,
--		G_PKG_NAME)
--       THEN
--           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
--       END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

  	  -- Initialize API return status to success
      x_return_status := FND_API.G_RET_STS_SUCCESS;

JTF_PERZ_DDF_PVT.create_data_default
(
	p_api_version_number	,
	p_init_msg_list		,
	p_commit		,

	p_application_id	,

	p_profile_id		,
	p_profile_name		,

	p_perz_ddf_id		,
	p_perz_ddf_context	,

	p_gui_object_name	,
	p_gui_object_id		,
	p_ddf_value		,
	p_ddf_value_type	,

	x_perz_ddf_id	   	,

	x_return_status		,
	x_msg_count		,
	x_msg_data
);



	 -- ******** Standard Ends ***********
	  --
      -- End of API body.
      --
--	7.	Commit the whole thing

      -- Standard check of p_commit.
      IF FND_API.To_Boolean ( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      -- Debug Message
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
    	 (
	p_count         	=>      x_msg_count,
       	p_data          	=>      x_msg_data
    	 );


  EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN

	  ROLLBACK TO CREATE_PERZ_DDF_PUB;
	  x_return_status := FND_API.G_RET_STS_ERROR ;

	  FND_MSG_PUB.Count_And_Get
    		( p_count         	=>      x_msg_count,
        	  p_data          	=>      x_msg_data
    		);

	  IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
	  THEN
    	      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    	  END IF;

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	  ROLLBACK TO CREATE_PERZ_DDF_PUB;
	  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	  FND_MSG_PUB.Count_And_Get
    		( p_count         	=>      x_msg_count,
        	  p_data          	=>      x_msg_data
    		);

	  IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
	  THEN
    	      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    	  END IF;

      WHEN OTHERS THEN

	  ROLLBACK TO CREATE_PERZ_DDF_PUB;
	  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	  FND_MSG_PUB.Count_And_Get
    		( p_count        	=>      x_msg_count,
        	  p_data          	=>      x_msg_data
    		);

	  IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
	  THEN
    	      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    	  END IF;

END create_data_default;

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
)IS
      -- ******* save_data_default Local Variables ********
--	Following variables are needed to adhere to standards
	l_api_version_number	NUMBER 	:= p_api_version_number;
     	l_api_name		CONSTANT VARCHAR2(30)	:= 'save_data_default';
--	Following variables are needed for implementation
	--l_return_status    	VARCHAR2(240) := FND_API.G_RET_STS_SUCCESS;

BEGIN


-- ******* save_data_default Standard Begins ********

      -- Standard call to check for call compatibility.
--       IF NOT FND_API.Compatible_API_Call (
--		l_api_version_number,
--		p_api_version_number,
--		l_api_name,
--		G_PKG_NAME)
--       THEN
--           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
--       END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

  	  -- Initialize API return status to success
      x_return_status := FND_API.G_RET_STS_SUCCESS;

JTF_PERZ_DDF_PVT.get_data_default
( 	p_api_version_number	,
	p_init_msg_list		,

	p_application_id	,

	p_profile_id		,
	p_profile_name		,

	p_perz_ddf_id		,
	p_perz_ddf_context	,

	p_gui_object_name	,
	p_gui_object_id		,

	p_ddf_value		,
	p_ddf_value_type	,

	x_ddf_out_tbl	   	,
	x_return_status		,
	x_msg_count		,
	x_msg_data
);

	 -- ******** Standard Ends ***********
	  --
      -- End of API body.
      --
--
      -- Debug Message
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
    	 (
	p_count         	=>      x_msg_count,
       	p_data          	=>      x_msg_data
    	 );


  EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN

	  x_return_status := FND_API.G_RET_STS_ERROR ;

	  FND_MSG_PUB.Count_And_Get
    		( p_count         	=>      x_msg_count,
        	  p_data          	=>      x_msg_data
    		);

	  IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
	  THEN
    	      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    	  END IF;

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	  FND_MSG_PUB.Count_And_Get
    		( p_count         	=>      x_msg_count,
        	  p_data          	=>      x_msg_data
    		);

	  IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
	  THEN
    	      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    	  END IF;

      WHEN OTHERS THEN

	  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	  FND_MSG_PUB.Count_And_Get
    		( p_count        	=>      x_msg_count,
        	  p_data          	=>      x_msg_data
    		);

	  IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
	  THEN
    	      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    	  END IF;

END get_data_default;
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
)IS
      -- ******* save_data_default Local Variables ********
--	Following variables are needed to adhere to standards
	l_api_version_number	NUMBER 	:= p_api_version_number;
     	l_api_name		CONSTANT VARCHAR2(30)	:= 'save_data_default';
--	Following variables are needed for implementation
	--l_return_status    	VARCHAR2(240) := FND_API.G_RET_STS_SUCCESS;

BEGIN


-- ******* save_data_default Standard Begins ********

      -- Standard Start of API savepoint
      SAVEPOINT	UPDATE_PERZ_DDF_PUB;

      -- Standard call to check for call compatibility.
--       IF NOT FND_API.Compatible_API_Call (
--		l_api_version_number,
--		p_api_version_number,
--		l_api_name,
--		G_PKG_NAME)
--       THEN
--           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
--       END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

  	  -- Initialize API return status to success
      x_return_status := FND_API.G_RET_STS_SUCCESS;

JTF_PERZ_DDF_PVT.update_data_default
(
	p_api_version_number	,
	p_init_msg_list		,
	p_commit		,

	p_application_id	,

	p_profile_id		,
	p_profile_name		,

	p_perz_ddf_id		,
	p_perz_ddf_context	,

	p_gui_object_name	,
	p_gui_object_id		,
	p_ddf_value		,
	p_ddf_value_type	,

	x_perz_ddf_id	   	,

	x_return_status		,
	x_msg_count		,
	x_msg_data
);


	 -- ******** Standard Ends ***********
	  --
      -- End of API body.
      --
--	7.	Commit the whole thing

      -- Standard check of p_commit.
      IF FND_API.To_Boolean ( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      -- Debug Message
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
    	 (
	p_count         	=>      x_msg_count,
       	p_data          	=>      x_msg_data
    	 );


  EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN

	  ROLLBACK TO UPDATE_PERZ_DDF_PUB;
	  x_return_status := FND_API.G_RET_STS_ERROR ;

	  FND_MSG_PUB.Count_And_Get
    		( p_count         	=>      x_msg_count,
        	  p_data          	=>      x_msg_data
    		);

	  IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
	  THEN
    	      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    	  END IF;

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	  ROLLBACK TO UPDATE_PERZ_DDF_PUB;
	  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	  FND_MSG_PUB.Count_And_Get
    		( p_count         	=>      x_msg_count,
        	  p_data          	=>      x_msg_data
    		);

	  IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
	  THEN
    	      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    	  END IF;

      WHEN OTHERS THEN

	  ROLLBACK TO UPDATE_PERZ_DDF_PUB;
	  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	  FND_MSG_PUB.Count_And_Get
    		( p_count        	=>      x_msg_count,
        	  p_data          	=>      x_msg_data
    		);

	  IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
	  THEN
    	      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    	  END IF;


END update_data_default;

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
)IS
      -- ******* save_data_default Local Variables ********
--	Following variables are needed to adhere to standards
	l_api_version_number	NUMBER 	:= p_api_version_number;
     	l_api_name		CONSTANT VARCHAR2(30)	:= 'save_data_default';
--	Following variables are needed for implementation
	--l_return_status    	VARCHAR2(240) := FND_API.G_RET_STS_SUCCESS;

BEGIN


-- ******* save_data_default Standard Begins ********

      -- Standard Start of API savepoint
      SAVEPOINT	UPDATE_PERZ_DDF_PUB;

      -- Standard call to check for call compatibility.
--       IF NOT FND_API.Compatible_API_Call (
--		l_api_version_number,
--		p_api_version_number,
--		l_api_name,
--		G_PKG_NAME)
--       THEN
--           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
--       END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

  	  -- Initialize API return status to success
      x_return_status := FND_API.G_RET_STS_SUCCESS;

JTF_PERZ_DDF_PVT.delete_data_default
(	p_api_version_number	,
  	p_init_msg_list		,
	p_commit		,

	p_application_id	,
	p_profile_id        	,
	p_perz_ddf_id           ,

	x_return_status		,
	x_msg_count		,
	x_msg_data
);

	 -- ******** Standard Ends ***********
	  --
      -- End of API body.
      --
--	7.	Commit the whole thing

      -- Standard check of p_commit.
      IF FND_API.To_Boolean ( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      -- Debug Message
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
    	 (
	p_count         	=>      x_msg_count,
       	p_data          	=>      x_msg_data
    	 );


  EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN

	  ROLLBACK TO DELETE_PERZ_DDF_PUB;
	  x_return_status := FND_API.G_RET_STS_ERROR ;

	  FND_MSG_PUB.Count_And_Get
    		( p_count         	=>      x_msg_count,
        	  p_data          	=>      x_msg_data
    		);

	  IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
	  THEN
    	      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    	  END IF;

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	  ROLLBACK TO DELETE_PERZ_DDF_PUB;
	  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	  FND_MSG_PUB.Count_And_Get
    		( p_count         	=>      x_msg_count,
        	  p_data          	=>      x_msg_data
    		);

	  IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
	  THEN
    	      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    	  END IF;

      WHEN OTHERS THEN

	  ROLLBACK TO DELETE_PERZ_DDF_PUB;
	  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	  FND_MSG_PUB.Count_And_Get
    		( p_count        	=>      x_msg_count,
        	  p_data          	=>      x_msg_data
    		);

	  IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
	  THEN
    	      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    	  END IF;

END delete_data_default;

-- *****************************************************************************
-- *****************************************************************************
END  jtf_perz_ddf_pub;

/
